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
     
}