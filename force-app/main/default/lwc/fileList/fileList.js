import { LightningElement, wire, api,track } from "lwc";
import getRelatedFilesP from "@salesforce/apex/FileController.getFilesListP";
import getRelatedFilesN from "@salesforce/apex/FileController.getFilesListN";



import getFileVersionDetails from "@salesforce/apex/FileController.getFileVersionDetails";
import createContentDocLink from "@salesforce/apex/FileController.createContentDocLink";
import { deleteRecord, createRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";

const actions = [
  { label: "Version History", name: "show_details" },
  { label: "Upload New Version", name: "upload_version" },
  { label: "Delete File", name: "delete" }
];

const BASE64EXP = new RegExp(/^data(.*)base64,/);
const columns = [
  {
    label: "Pay Stubs",
    fieldName: "id",
    type: "filePreview",
    wrapText: true,
    typeAttributes: {
      anchorText: { fieldName: "title" },
      versionId: { fieldName: "latestVersionId" }
    }
  },
  
  { label: "Pay Date", fieldName: "createdDate", type: "date" },
  
  
  
 
];

const versionColumns = [
    {
        label: "Download",
        fieldName: "id",
        type: "filePreview",
        typeAttributes: {
          anchorText: "Download⇣"
        }
    },
  { label: "Title", fieldName: "title", type: "string" },
  { label: "Reason for Change", fieldName: "reasonForChange", type: "string" },
  { label: "Uploaded by", fieldName: "createdBy", type: "string" },
  { label: "Uploaded Date", fieldName: "createdDate", type: "date" },
  
];

export default class FileList extends LightningElement {
    @api
    recordId;
    _filesList;
    _filesListN;
    fileTitle;
    fileName;
    files = [];
    filesN = [];
    columns = columns;
    versionColumns = versionColumns;
    versionDetails = [];
    fileUpload = false;
    _currentDocId = null;
    showPreview = false;
    currentPreviewFileId = null;
    showSpinner = false;
    @api acceptedFileFormats;
    @api fileUploaded;
    title;
    @track initialized=false;
    @track newFile=false;

    defaultSortDirection = 'asc';

   
    @track workerdata;
   

    handleClick() {
      console.log('refresh');
      refreshApex(this._filesList);
      refreshApex(this._filesListN);
      
  }
    handleFileNameChange(event) {
      this.fileTitle = event.detail.value;
    }
    handleFileChange() {
      const inpFiles = this.template.querySelector("input.file").files;
      if (inpFiles && inpFiles.length > 0) this.fileName = inpFiles[0].name;
    } 
  
    @wire(getRelatedFilesP, { recordId: "$recordId" })
    getFilesListP(filesListp) {
      this._filesList = filesListp;
      
      const { error, data } = filesListp;
      if (!error && data) {
        this.files = data;
        //console.log("this.files",this.files);
      }
    } 
    @wire(getRelatedFilesN, { recordId: "$recordId" })
    getFilesList(filesList) {
      this._filesListN = filesList;
      
      const { error, data } = filesList;
      if (!error && data) {
        this.filesN = data;
        //console.log("this.filesN",this.filesN);
      }
    } 
    
    

    
    

  
    closeModal() {
      this.newFile=false;
      this._currentDocId = null;
      this.fileUpload = false;
      this.versionDetails = [];
      this.fileName = "";
      this.fileTitle = "";
      refreshApex(this._filesList);
      if(this.dialag) {
        this.dialag.closeModal();
      }
    } 
  
    handleRowAction(event) {
      const action = event.detail.action.name;
      const row = event.detail.row;
      this._currentDocId = row.id;
      var fileName=row.title;
      if (action === "show_details") {
        this.fileUpload = false;
        this.title=`File History - ${fileName}`;
        this.showVersionDetails(fileName);
      } else if (action === "upload_version") {
        this.fileUpload = true;
        if(this.dialag) {
            this.newFile=false;
            this.title=`Upload New Version of file - ${fileName}`;
            this.dialag.openmodal();
        }
      } else if (action === "delete") {
        this.deleteFiles([this._currentDocId]);
      }
    } 
  
    deleteFiles(recordIds) {
      if (recordIds.length > 0) {
        let decision = confirm(
          `Are you sure you want to delete ${recordIds.length} records?`
        );
        if (decision) {
          this._deleteRecord(recordIds);
        }
      }
    } 
  
    _deleteRecord(recordIds) {
      Promise.all(recordIds.map((id) => deleteRecord(id)))
        .then(() => {
          refreshApex(this._filesList);
          this.dispatchEvent(
            new ShowToastEvent({
              variant: "success",
              message: `Record deleted successfully`
            })
          );
        })
        .catch((err) => {
          this.dispatchEvent(
            new ShowToastEvent({
              variant: "error",
              message: `Error occurred while deleting records: ${
                err.body ? err.body.message || err.body.error : err
              }`
            })
          );
        });
    } 
  
    newFileUpload() {
      this.newFile=true;
      this.fileUpload = true;
      this.title='New File Upload';
      if(this.dialag)
      {
        this.dialag.openmodal();
      }
    } 

    get dialag()
    {
        return this.template.querySelector('c-dialog');
    }
    showVersionDetails() {
      getFileVersionDetails({ fileId: this._currentDocId })
        .then((result) => {
          this.versionDetails = result;
          if(this.dialag) {
              this.dialag.openmodal();
          }
        })
        .catch((err) => {
          console.error(JSON.stringify(err));
        });
    }
  
    handleUpload(event) {
      event.preventDefault();
      this.showSpinner = true;
      try {
        const file = this.template.querySelector("input.file").files[0];
        const reasonForChangeCtrl = this.template.querySelector(
          "lightning-input.reason"
        );
        const reader = new FileReader();
        let fileData = "";
        reader.onload = () => {
          fileData = reader.result;
          this.uploadFile(file, fileData, this.newFile?'':reasonForChangeCtrl.value);
        };
        reader.readAsDataURL(file);
      } catch (err) {
        console.error(err);
        this.dispatchEvent(
          new ShowToastEvent({
            variant: "error",
            message: `File upload failed: ${err.body.message || err.body.error}`
          })
        );
        this.showSpinner = false;
      }
    } 
  
    uploadFile(file, fileData, reasonForChange) {
      const payload = {
        Title: this.fileTitle || this.fileName,
        PathOnClient: file.name,
        ReasonForChange: reasonForChange,
        VersionData: fileData.replace(BASE64EXP, "")
      };
      if (this._currentDocId) {
        payload.ContentDocumentId = this._currentDocId;
      }
      createRecord({ apiName: "ContentVersion", fields: payload })
        .then((cVersion) => {
          this.showSpinner = false;
          if (!this._currentDocId) {
            this.createContentLink(cVersion.id);
          } else {
            this.closeModal();
            this.dispatchEvent(
              new ShowToastEvent({
                variant: "success",
                message: `Content Document Version created ${cVersion.id}`
              })
            );
          }
        })
        .catch((err) => {
          this.dispatchEvent(
            new ShowToastEvent({
              variant: "error",
              message: `File upload failed: ${err.body.message || err.body.error}`
            })
          );
          this.showSpinner = false;
        });
    } 
  
    createContentLink(cvId) {
     createContentDocLink({
        contentVersionId: cvId,
        recordId: this.recordId
      })
        .then((cId) => {
          this.closeModal();
          this.dispatchEvent(
            new ShowToastEvent({
              variant: "success",
              message: `File uploaded successfully ${cId}`
            })
          );
        })
        .catch((err) => {
          this.dispatchEvent(
            new ShowToastEvent({
              variant: "error",
              message: `An error occurred: ${
                err.body ? err.body.message || err.body.error : err
              }`
            })
          );
        });
    }
}