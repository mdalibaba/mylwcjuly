import { LightningElement ,wire,api,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContacts from '@salesforce/apex/RelatedContacts.getContacts';
export default class RelatedContacts extends LightningElement {

   @api recordId
   contacts=[];
   selectedIds=[];
   @track selectedRecords = [];
        @wire(getContacts, { recordId: '$recordId' }) contacts({ error, data }) {
            if (data) {
                try{
                    console.log(JSON.stringify(data));
                    this.contacts = data;
                }catch(e){


                        this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error fetching contacts',
                            message: data.message,
                            variant: 'error'
                        })
                    );
                }
                    console.log(e);
               
            } else if (error) {
                this.contacts = undefined;
            }
        }

        handleCheckboxClick(event) {
            const checkbox = event.target;
            const id = checkbox.dataset.id;

            const selectedRecord = this.contacts.find(item => item.Id === id);

            if (checkbox.checked) {
                this.selectedIds = [...this.selectedIds, id];
                this.selectedRecords = [...this.selectedRecords, selectedRecord];

            } else {
                this.selectedIds = this.selectedIds.filter(selectedId => selectedId !== id);
                this.selectedRecords = this.selectedRecords.filter(record => record.Id !== id);
            }
        }
         
}