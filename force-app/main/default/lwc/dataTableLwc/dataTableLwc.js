import { LightningElement,wire,api ,track} from 'lwc';
import { getRecords } from 'lightning/uiRecordApi';
import getAllContacts from '@salesforce/apex/RelatedContacts.getAllContacts';
 
const columns = [
    { label: 'Id', fieldName: 'Id' },
    { label: 'First Name', fieldName: 'FirstName' },
    { label: 'Last Name', fieldName: 'LastName' },
    { label: 'Email', fieldName: 'Email', type: 'email' }
];
export default class DataTableLwc extends LightningElement {
    @track contacts = {
        data: null,
        isLoading: true,
        error: null
    };
    columns = columns;


    @wire(getAllContacts )wiredata({error,data}){

        if(data){
            this.contacts.data = data;
            this.contacts.isLoading = false;
            this.contacts.error = null;
        }
     else if(error){

        this.contacts.error = error;
        this.contacts.data = null;
    }
}

            
}