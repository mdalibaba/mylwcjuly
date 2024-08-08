/* eslint-disable no-restricted-globals */
/* eslint-disable no-unused-vars */
/* eslint-disable no-alert */
/**
  
  
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   08-06-2024   MD Ali Baba   Initial Version
**/
import { LightningElement, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import FullCalendarJS from '@salesforce/resourceUrl/FullCalendarJS';
import { NavigationMixin } from 'lightning/navigation';
import fetchAllEvents from '@salesforce/apex/TimeOffCalendarLTController.loadTimeOffDates';
import approve from '@salesforce/apex/TimeOffCalendarLTController.updateEvent';
import reject from '@salesforce/apex/TimeOffCalendarLTController.reject';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
 import Id from "@salesforce/user/Id";
/**
 * FullCalendarJs
 * @description Full Calendar JS - Lightning Web Components
 */
export default class LwcFullCalendar extends NavigationMixin(LightningElement) {
  userId = Id;
  rejectcomment;
  fullCalendarJsInitialised = false;
  @track allEvents = [];
  @track selectedEvent = undefined;
  createRecord = false;

  /**
   * @description Standard lifecyle method 'renderedCallback'
   *              Ensures that the page loads and renders the 
   *              container before doing anything else
   */
  renderedCallback() {

    // Performs this operation only on first render
    if (this.fullCalendarJsInitialised) {
      return;
    }
    this.fullCalendarJsInitialised = true;

    // Executes all loadScript and loadStyle promises
    // and only resolves them once all promises are done
    Promise.all([
      loadScript(this, FullCalendarJS + '/jquery.min.js'),
      loadScript(this, FullCalendarJS + '/moment.min.js'),
      loadScript(this, FullCalendarJS + '/theme.js'),
      loadScript(this, FullCalendarJS + '/fullcalendar.min.js'),
      loadStyle(this, FullCalendarJS + '/fullcalendar.min.css'),
      // loadStyle(this, FullCalendarJS + '/fullcalendar.print.min.css')
    ])
    .then(() => {
      // Initialise the calendar configuration
      this.getAllEvents();
    })
    .catch(error => {
      // eslint-disable-next-line no-console
      console.error({
        message: 'Error occured on FullCalendarJS',
        error
      });
    })
  }

  /**
   * @description Initialise the calendar configuration
   *              This is where we configure the available options for the calendar.
   *              This is also where we load the Events data.
   */
  initialiseFullCalendarJs() {
    const ele = this.template.querySelector('div.fullcalendarjs');
    // eslint-disable-next-line no-undef
    $(ele).fullCalendar({
      header: {
          left: 'prev,next today',
          center: 'title',
          right: 'month,basicWeek,basicDay,listWeek'
      },
      themeSystem : 'standard',
      defaultDate: new Date(), 
      navLinks: true,
      editable: true,
      eventLimit: true,
      events: this.allEvents,
      dragScroll : true,
      droppable: true,
      weekNumbers : true,
      eventDrop: this.eventDropHandler.bind(this),
      eventClick: this.eventClickHandler.bind(this),
      dayClick : this.dayClickHandler.bind(this),
      height: 1020,
      contentHeight: 600,
      eventMouseover : this.eventMouseoverHandler.bind(this)
    });
  }

  eventMouseoverHandler = (event, jsEvent, view)=>{
     
  }
  eventDropHandler = (event, delta, revertFunc)=>{
    alert(event.title + " was dropped on " + event.start.format());
    if (!confirm("Are you sure about this change? ")) {
      revertFunc();
    }
  }

  eventClickHandler = (event, jsEvent, view) => {
    
   
      this.selectedEvent =  event;
       
      
     
      console.log("myobj--"+event.start);
  }

  dayClickHandler = (date, jsEvent, view)=>{
    jsEvent.preventDefault();
    this.createRecord = true;
  }

  createCancel() {
    this.createRecord = false;
  }

  getAllEvents(){
  var  wsDate = new Date();
     
      fetchAllEvents({wsDate:wsDate,weDate:wsDate})
      .then(result => {
        this.allEvents = result.map(item => {
            
          return {
            id : item.Id,
            torId:item.HRMSUS__Time_Off_Request__c,
            editable : true,
            title : (item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__c && item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__r.Name  && item.HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__c && item.HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__r.Name) ? item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__r.Name+'('+item.HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__r.Name+')' : '',
            subject: (item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__c && item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__r.Name  && item.HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__c && item.HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__r.Name) ? item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__r.Name+'('+item.HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__r.Name+')' : '',
            start:new Date(item.HRMSUS__Date__c).getTime(),
            end: new Date(item.HRMSUS__Date__c).getTime() + 86400000,
            torEnd:new Date(item.HRMSUS__Time_Off_Request__r.HRMSUS__End_Date__c).getTime() + 86400000 ,
            totalHours: item.HRMSUS__Time_Off_Request__r.HRMSUS__Total_Absence_Requested__c ? item.HRMSUS__Time_Off_Request__r.HRMSUS__Total_Absence_Requested__c :'',
            popOverList: item,
             allDay : true,
            description : item.HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c,
            worker:(item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__c && item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__r.Name ) ? item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__r.Name:'',
             user:(item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__c && item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__r.HRMSUS__User__c ) ? item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__r.HRMSUS__User__c:'',
              comments: item.HRMSUS__Time_Off_Request__r.HRMSUS__Notes__c ? item.HRMSUS__Time_Off_Request__r.HRMSUS__Notes__c:'',
              rejectComments: item.HRMSUS__Time_Off_Request__r.HRMSUS__Rejection_Comments__c ? item.HRMSUS__Time_Off_Request__r.HRMSUS__Rejection_Comments__c : '',
             approved: item.HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c ? item.HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c :'',
             leaveType: (item.HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__c && item.HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__r.Name) ? item.HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__r.Name :'',
             backgroundColor:(item.HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c=='Submitted')?'rgb(254, 147, 57) !important':(item.HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c=='Approved')?'rgb(46, 132, 74) !important':(item.HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c=='Rejected')?'rgb(234, 0, 30) !important':'#b0cc6f !important',  
              startDate:((item.HRMSUS__Time_Off_Request__r.HRMSUS__Start_Date__c).match(/\d+/g))[1]+'/'+((item.HRMSUS__Time_Off_Request__r.HRMSUS__Start_Date__c).match(/\d+/g))[2]+'/'+((item.HRMSUS__Time_Off_Request__r.HRMSUS__Start_Date__c).match(/\d+/g))[0],
             endDate:((item.HRMSUS__Time_Off_Request__r.HRMSUS__End_Date__c).match(/\d+/g))[1]+'/'+((item.HRMSUS__Time_Off_Request__r.HRMSUS__End_Date__c).match(/\d+/g))[2]+'/'+((item.HRMSUS__Time_Off_Request__r.HRMSUS__End_Date__c).match(/\d+/g))[0],
             status:item.HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c,
             approve:(item.HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c=='Approved')?true:false,
             submitted:(item.HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c=='Submitted')?true:false,
             reject:(item.HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c=='Rejected')?true:false,
             cancel:(item.HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c=='Cancelled')?true:false,
             currentuser:(item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__c && item.HRMSUS__Time_Off_Request__r.HRMSUS__Worker__r.HRMSUS__User__c==this.userId )?false:true
            };
        
        });
        // Initialise the calendar configuration
        this.initialiseFullCalendarJs();
      })
      .catch(error => {
        window.console.log(' Error Occured ', error)
      })
      .finally(()=>{
        //this.initialiseFullCalendarJs();
      })
  }

  closeModal(){
    this.selectedEvent = undefined;
  }

  commentChange(event){
    this.rejectcomment=event.target.value;
     
  }

  cmpapprove(){
      approve({eventId : this.selectedEvent.torId, message : "Approved"})
    .then(result => {
      window.console.log('Approve Result : ', result);
      this.dispatchEvent(
        new ShowToastEvent({
          variant: "Success",
          title: result,
          message: "Approved Successfully"
        })
      );
      window.location.reload();
    })
    .catch(error => {
      window.console.log('Error Occured ', error);
      this.dispatchEvent(
        new ShowToastEvent({
          variant: "Error",
          title: "Error updating event",
          message: `  message: ${err.body.message || err.body.error}`
        })
      );
      this.selectedEvent.approve=true;
    this.selectedEvent.submitted=false;
    this.selectedEvent.reject=false;
    this.selectedEvent.cancel=false;
    this.selectedEvent.status='Approved';
    })
    .finally(()=>{
      this.selectedEvent = undefined;
    })
  
  }
  cmpreject(){
      if(this.rejectcomment==undefined || this.rejectcomment==''){
        this.dispatchEvent(
          new ShowToastEvent({
            variant: "Error",
            title: "Error",
            message: "Please enter a Reject Comments"
          })
        );
        return false;
      }
      else {

        reject({eventId : this.selectedEvent.torId, message:'Rejected',rejectComments: this.rejectcomment})
    .then(result => {
      window.console.log('Reject Result : ', result);
      this.dispatchEvent(
        new ShowToastEvent({
          variant: "Success",
          title: result,
          message: "Rejected Successfully"
        })
       );
       window.location.reload();
    })
    .catch(error => {
      window.console.log('Error Occured ', error);
      this.dispatchEvent(
        new ShowToastEvent({
          variant: "Error",
          title: "Error updating event",
          message: `  message: ${err.body.message || err.body.error}`
        })
      );
      this.selectedEvent.approve=false;
    this.selectedEvent.submitted=false;
    this.selectedEvent.reject=false;
      })
    .finally(()=>{
      this.selectedEvent = undefined; 

      })
  }
}
}