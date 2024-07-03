@isTest
public class FileController_Test {
    
    @isTest static void myTestN() {
        
        HRMSUS__Trigger__c trg=new HRMSUS__Trigger__c (HRMSUS__Skip_Onboarding_Process__c =true);
        insert trg;
        
        Account acc= new Account(name='SanaUllaah',BillingStreet = '17-C',BillingPostalCode = '74900',BillingState = 'Sindh',
                                 BillingCity = 'Karachi');
        insert acc;  
        
        HRMSUS__Company__c company=new HRMSUS__Company__c(Name='Testa Company',HRMSUS__Is_INC__c=true,HRMSUS__Week_Start_Day__c='Monday',HRMSUS__Internal_Account__c=acc.id);
        insert company;
        
        HRMSUS__Location__c loc=new HRMSUS__Location__c(HRMSUS__Company__c =company.id,Name='Testa Location');
        insert loc;
        
         Profile pflsu = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User su = new User(Alias = 'stanadt', Email='standardusers@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pflsu.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1xyzsddd2@testorg.com');
        insert su;
        
        system.assert(loc!=null,'loca is null');
        HRMSUS__Person__c p1 = new HRMSUS__Person__c(Name = 'Anaas',HRMSUS__User__c=su.Id );
        insert p1;
        
         Profile pfl = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pfl.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2232ddffdf@testorg.com');
        insert u;
        
        HRMSUS__Person__c p2 = new HRMSUS__Person__c(Name = 'Ans',HRMSUS__User__c=u.Id );
        insert p2;
        
        system.assert(p1!=null,'p1  is null');
        HRMSUS__Person__c p = new HRMSUS__Person__c(Name = 'Anas2',HRMSUS__Supervisor__c=p1.Id,HRMSUS__User__c=Userinfo.getuserId() );
        insert p;
        
        HRMSUS__Person__c ps2 = new HRMSUS__Person__c(Name = 'Ana',HRMSUS__Supervisor__c=p2.Id,HRMSUS__User__c=su.Id );
        insert ps2;
        
        list<HRMSUS__Person__c> perlist=new list<HRMSUS__Person__c>();
        perlist.add(p);
        
        //Create contentVersion
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Testa Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        cv.SharingPrivacy='N';
        cv.ReasonForChange='Want to change the file ';
        cv.ContentUrl='';
        Insert cv;
        
        ContentVersion cvc = new ContentVersion();        
        cvc.Title = 'Testa Document';
        cvc.PathOnClient = 'TestDocument.pdf';
        cvc.VersionData = Blob.valueOf('Test Content');
        cvc.IsMajorVersion = true;
        cvc.SharingPrivacy='P';
        cvc.ReasonForChange='Want to change the file ';
        cvc.ContentUrl='';        
        insert cvc;
               
        string usid =Userinfo.getuserId();
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id ];
        System.assertEquals(cvList.size(), 1);
        system.debug('ContentVersionID : ' + cvList[0].Id);
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = p.id;
        cdl.ContentDocumentId = cvList[0].ContentDocumentId;
        cdl.shareType = 'V';
        insert cdl;  
        System.assertEquals(cdl.ContentDocumentId,cvList[0].ContentDocumentId);
                
        FileController.getFilesListN(p.id);
        FileController.getFilesListP(ps2.id);
        FileController.getWorker(p.id);
        FileController.getWorkers(p.id);
        FileController.getFileVersionDetails(cv.id);
        try{
            FileController.createContentDocLink(cv.id, p.id);
            
        }catch (exception ex){}
        
    }
}