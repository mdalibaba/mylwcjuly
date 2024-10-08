public with sharing class RelatedContacts {
     @AuraEnabled(cacheable=true)
    public static  List<Contact> getContacts(Id recordId){
        try {
            List<Contact> con =[SELECT Id, Name,Phone,Email FROM Contact WHERE AccountId=:recordId];
            return con;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string saveContacts(List<Contact> contacts){
        try {
            upsert contacts;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static  List<Contact> getAllContacts( ){
        try {
            List<Contact> con =[SELECT Id, FirstName,LastName,Email FROM Contact limit 20];
            return con;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
     
}