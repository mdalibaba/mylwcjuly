import { LightningElement ,wire,api,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContacts from '@salesforce/apex/RelatedContacts.getContacts';
import saveContacts from '@salesforce/apex/RelatedContacts.saveContacts';
export default class RelatedContacts extends LightningElement {

   @api recordId
  // contacts=[];
   mycon=[];
   selectedIds=[];
   @track selectedRecords = [];
   @track hasErrors = false;

        @wire(getContacts, { recordId: '$recordId' }) contacts({ error, data }) {
            if (data) {
                 
                try{
                   let contacts=[];
                    console.log(JSON.stringify(data));
                    
                    data.forEach(element => {
                        contacts.push({"Id":element.Id,"Name":element.Name,"Email":element.hasOwnProperty('Email') ? element.Email :''});
                    }); 
                     
                   
                    console.log(JSON.stringify(this.contacts));
                    this.mycon=contacts;
                }catch(e){


                        this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error fetching contacts',
                            message: e.message,
                            variant: 'error'
                        })
                    );
                }
                    
               
            } else if (error) {
                //this.contacts = undefined;
            }
        }

        handleCheckboxClick(event) {
            
            const checkbox = event.target;
            const id = checkbox.dataset.id;

            const selectedRecord = this.mycon.find(item => item.Id === id);
            console.log(JSON.stringify( this.selectedRecords));
            if (checkbox.checked) {
                this.hasErrors = false;
                this.selectedIds = [...this.selectedIds, id];
                this.selectedRecords = [...this.selectedRecords, selectedRecord];

            } else {
                this.selectedIds = this.selectedIds.filter(selectedId => selectedId !== id);
                this.selectedRecords = this.selectedRecords.filter(record => record.Id !== id);
            }
        }

        handleEmailChange(event) {
             let id = event.target.dataset.id;
             let email = event.target.value;
             this.mycon.forEach(record => {
                 if (record.Id === id) {
                     record.Email = email;
                 }
             });
             if(this.selectedRecords.length>0){
                this.selectedRecords.forEach(record => {
                    if (record.Id === id) {
                        record.Email = email;
                    } });
             }
        }

        handleSave(event){

            event.preventDefault(); // Prevent form submission

        // Validate that at least one checkbox is selected
        if (this.selectedRecords.length === 0) {
            this.hasErrors = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No record selected',
                    message: 'Please select a record to save.',
                    variant: 'warning'
                })
            );
        } else if(this.selectedRecords.length>0){
            this.hasErrors = false;
            // Process the form submission logic here
            console.log('Form submitted:', this.selectedRecords);

            
            
            saveContacts({
                contacts: this.selectedRecords
            }).then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: result,
                        message: 'Records saved',
                        variant: 'success'
                    })
                );
        })
            .catch(error => {
                
                console.log(JSON.stringify( error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: error,
                        message: 'Error saving records: ' + error.body.message,
                        variant: 'error'
                    })
                );
            }) 





            /////////////////////////////
        }
    
    

        }
         
}