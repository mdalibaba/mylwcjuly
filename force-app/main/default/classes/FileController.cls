public class FileController {
    @AuraEnabled(cacheable=true)
    public static FilesWrapper[] getFilesListP(Id recordId) {
        HRMSUS__Person__c wrkr = [SELECT ID,HRMSUS__User__c ,HRMSUS__Supervisor__c FROM HRMSUS__Person__c Where Id =:recordId ];
        Profile pfl = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1 ];
        List<User> usersids = [SELECT ID,Name From user Where ProfileId=:pfl.Id And IsActive= true ];
        string adminId;
        for(user u : usersids){
            if(u.id == Userinfo.getuserId()){
                adminId = u.Id;
            }
            
        }
        FilesWrapper[] filesList = new List<FilesWrapper>{};
            for (ContentDocumentLink link : [
                SELECT
                ContentDocumentId,
                ContentDocument.LatestPublishedVersion.Title,
                ContentDocument.LatestPublishedVersion.CreatedDate,
                ContentDocument.LatestPublishedVersion.CreatedBy.Name,
                ContentDocument.LatestPublishedVersion.SharingPrivacy
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId and ContentDocument.LatestPublishedVersion.SharingPrivacy='P' And (ContentDocument.LatestPublishedVersion.CreatedBy.Id =:adminId OR ContentDocument.LatestPublishedVersion.CreatedBy.Id =:wrkr.HRMSUS__Supervisor__c OR ContentDocument.LatestPublishedVersion.CreatedBy.Id !=:wrkr.HRMSUS__User__c)
            ]) {
                filesList.add(
                    new FilesWrapper(
                        link.ContentDocumentId,
                        link.ContentDocument.LatestPublishedVersion.Title,
                        link.ContentDocument.LatestPublishedVersion.CreatedBy.Name,
                        Date.valueOf(link.ContentDocument.LatestPublishedVersion.CreatedDate),
                        link.ContentDocument.LatestPublishedVersion.SharingPrivacy,
                        link.ContentDocument.LatestPublishedVersionId
                    )
                );
            }
        return filesList;
    } 
    @AuraEnabled(cacheable=true)
    public static FilesWrapper[] getFilesListN(Id recordId) {
        HRMSUS__Person__c wrkr = [SELECT ID,HRMSUS__User__c FROM HRMSUS__Person__c Where Id =:recordId ];
        FilesWrapper[] filesList = new List<FilesWrapper>{};
            for (ContentDocumentLink link : [
                SELECT
                ContentDocumentId,
                ContentDocument.LatestPublishedVersion.Title,
                ContentDocument.LatestPublishedVersion.CreatedDate,
                ContentDocument.LatestPublishedVersion.CreatedBy.Name,
                ContentDocument.LatestPublishedVersion.SharingPrivacy
                
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId and (ContentDocument.LatestPublishedVersion.SharingPrivacy='N' OR ContentDocument.LatestPublishedVersion.CreatedBy.Id=:wrkr.HRMSUS__User__c)
            ]) {
                filesList.add(
                    new FilesWrapper(
                        link.ContentDocumentId,
                        link.ContentDocument.LatestPublishedVersion.Title,
                        link.ContentDocument.LatestPublishedVersion.CreatedBy.Name,
                        Date.valueOf(link.ContentDocument.LatestPublishedVersion.CreatedDate),
                        link.ContentDocument.LatestPublishedVersion.SharingPrivacy,
                        link.ContentDocument.LatestPublishedVersionId
                    )
                );
            }
        return filesList;
    }
    
    @AuraEnabled
    public static FileVersionWrapper[] getFileVersionDetails(Id fileId) {
        FileVersionWrapper[] contentversions = new List<FileVersionWrapper>{};
            for (ContentVersion cv : [SELECT id,title,contenturl,createddate, createdby.name, ReasonForChange,SharingPrivacy FROM ContentVersion WHERE ContentDocumentId = :fileId]) {
                contentVersions.add(new FileVersionWrapper(cv.id, cv.title, cv.createdby.name, Date.valueOf(cv.createddate), cv.ReasonForChange,cv.contenturl,cv.SharingPrivacy));
            }
        return contentVersions;
    } 
    
    public virtual class File{
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String createdBy { get; set; }
        @AuraEnabled
        public Date createdDate { get; set; }
        @AuraEnabled
        public String SharingPrivacy { get; set; }
        
        public File(String id, String title, String createdBy, Date createdDate,String SharingPrivacy) {
            this.id = id;
            this.title = title;
            this.createdBy = createdBy;
            this.createdDate = createdDate;
            this.SharingPrivacy=SharingPrivacy;
        }
    }
    
    public class FilesWrapper extends File{
        @AuraEnabled
        public String latestVersionId { get; set; }
        
        public FilesWrapper(String id, String title, String createdBy, Date createdDate, String latestVersionId,String SharingPrivacy) {
            super(id, title, createdBy, createdDate,SharingPrivacy);
            this.latestVersionId = latestVersionId;
        }
    }
     
    
    public class FileVersionWrapper extends File{
        @AuraEnabled
        public String reasonForChange { get; set; }
        @AuraEnabled
        public String contentUrl { get; set; }
        public FileVersionWrapper(String id, String title, String createdBy, Date createdDate, String reasonForChange,string contentUrl,string SharingPrivacy) {
            super(id, title, createdBy, createdDate,SharingPrivacy);
            this.reasonForChange = reasonForChange;
            this.contentUrl=contentUrl;
            this.SharingPrivacy=SharingPrivacy;
        }
    } 
    
    @AuraEnabled
    public static Id createContentDocLink(Id contentVersionId, Id recordId) {
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId].ContentDocumentId;
        insert new ContentDocumentLink(ContentDocumentId = docId, LinkedEntityId = recordId);
        return docId;
    }
     @AuraEnabled
    public static HRMSUS__Person__c getWorker(Id recordId){
        HRMSUS__Person__c pr = new HRMSUS__Person__c();
        HRMSUS__Person__c wrpr = new HRMSUS__Person__c();
        string usid= Userinfo.getuserId();
        wrpr =[SELECT Id, Name From HRMSUS__Person__c Where Id =: recordId and HRMSUS__User__c=:usid  ];
        
        pr = [SELECT Id, Name From HRMSUS__Person__c Where Id =: recordId ];
        return pr;
    }
    
  
    @AuraEnabled
    public static HRMSUS__Person__c getWorkers(Id recordId){
        HRMSUS__Person__c pr = new HRMSUS__Person__c();
        HRMSUS__Person__c wrpr = new HRMSUS__Person__c();
        string usid= Userinfo.getuserId();
        wrpr =[SELECT Id, Name From HRMSUS__Person__c Where Id =: recordId and HRMSUS__User__c=:usid  ];
        pr = [SELECT Id, Name From HRMSUS__Person__c Where Id =: recordId ];
        
        return pr;
    }
    
    
}