import { LightningElement } from 'lwc';
import { divide_with_throw } from 'c/divdenum';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

 

export default class ProgressBarParentComponent extends LightningElement {

    myname='MD';
    percentage = 10;
    output;
    num1;
    num2;
    fromcname;
    changeHandler(event) {
         
        this[event.target.name] = event.target.value <= 100 ? event.target.value : 100;
       this.fromcname= this.template.querySelector('c-progress-bar-child-component').mycmp(this.myname);

       alert('fromcname-->'+fromcname);
    }
    changeHandlerName(event){
        //alert(event.target.name);
        this[event.target.name] = event.target.value !='' ? event.target.value : 'Ali';
    }

    handleme(event){

         
        this.fromcname = event.detail.message;
        alert('fromcname-->'+this.fromcname);
    }
     
    numchange(event){
       let name=event.target.name;
         
       if(name=='num1'){
        this.num1=event.target.value;

       }
       if(name=='num2'){
        this.num2=event.target.value;
       }
       
    }

    divideNumbers_handle(){
 
        try {
            this.output=divide_with_throw(this.num1,this.num2);
        } catch (e) {
        this.dispatchEvent(
            new ShowToastEvent({
                 title: 'An Error Occured',
                 message: e.message,
                 variant: 'error'
            })
        )  

        }
    }
 
}