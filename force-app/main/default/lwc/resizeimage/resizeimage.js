 
import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { createRecord } from 'lightning/uiRecordApi';

import { NavigationMixin } from 'lightning/navigation';

import SaveImg from '@salesforce/apex/SaveImage.uploadFile';

export default class Resizeimage extends NavigationMixin(LightningElement) {

@api recordId;

@track compressedImageData = '';

@track fileName ='' ;

@track fileType = '';

@track newfile = false;

handleFileChange(event) {

console.log('apple ');

const fileInput = event.target.files;

const file = fileInput[0];

this.fileName = file.name;

this.fileType = file.type;

const reader = new FileReader();

reader.onload = () => {

const readerResult = reader.result;

var image = new Image();

image.src = readerResult;

image.onload = () => {

const maxWidth = 2800;

const maxHeight = 2600;

var canvas = document.createElement('canvas');

var width = image.width;

var height = image.height;

if (width > height) {

if (width > maxWidth) {

height *= maxWidth / width;

width = maxWidth;

}

} else {

if (height > maxHeight) {

width *= maxHeight / height;

height = maxHeight;

}

}

canvas.width = width;

canvas.height = height;

var context = canvas.getContext('2d');

context.drawImage(image, 0, 0, width, height);

const compressedImageData = canvas.toDataURL(this.fileType, 0.7);

this.compressedImageData = compressedImageData;

const fields = {

Title: this.fileName,

PathOnClient: this.fileName,

VersionData: this.compressedImageData.split(',')[1],

FirstPublishLocationId: this.recordId,

ContentLocation: 'S',

Description: this.description

// Add any other fields you need

};

 /*createRecord({

apiName: 'ContentVersion',

fields: fields

}) */
SaveImg({  base64:this.compressedImageData.split(',')[1],  filename:this.fileName,  recordId:this.recordId})
.then(result => {
 console.log(JSON.stringify(result));
 //alert(JSON.stringify(result));
this.showSuccessToast('Success!', 'File has been uploaded successfully.');

this.newfile = true;

 
    this.dispatchEvent(new CloseActionScreenEvent());
  

})

.catch(error => {

console.error('Error in callback:', error);

this.showErrorToast('Error', 'An error occurred while uploading the file.');

 
    this.dispatchEvent(new CloseActionScreenEvent());
 

});

};

};

reader.readAsDataURL(file);

}

showErrorToast(title, message) {

const evt = new ShowToastEvent({

title: title,

message: message,

variant: 'error'

});

this.dispatchEvent(evt);

}

showSuccessToast(title, message) {

const evt = new ShowToastEvent({

title: title,

message: message,

variant: 'success'

});

this.dispatchEvent(evt);

}

}