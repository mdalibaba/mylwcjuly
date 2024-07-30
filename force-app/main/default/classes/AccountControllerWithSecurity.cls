public with sharing class AccountControllerWithSecurity {
     
     @AuraEnabled(cacheable=true)
     public static list<Account> getAccounts(){
         
            return [SELECT Name,AnnualRevenue,Industry FROM Account ORDER BY Name ];
         
     }

     @AuraEnabled(cacheable=true)
     public static List<Account> getAccountsCRUDCheck(){

        if(Schema.sObjectType.Account.isAccessible()){

            return [SELECT Name,AnnualRevenue,Industry FROM Account ORDER BY Name ];

        }
        return new List<Account>();
     }

     @AuraEnabled(cacheable=true)
     public static List<Account> getAccountsFLSCheck(){

        if(
            Schema.sObjectType.Account.fields.Name.isAccessible() &&
            Schema.sObjectType.Account.fields.AnnualRevenue.isAccessible() &&
            Schema.sObjectType.Account.fields.Industry.isAccessible()
            ){

            return [SELECT Name,AnnualRevenue,Industry FROM Account ORDER BY Name ];

        }
        return new List<Account>();
     }

     @AuraEnabled(cacheable=true)
     public static List<Account> getAccountsWithSecurityEnforcedCheck(){
              return [SELECT Name,AnnualRevenue,Industry FROM Account WITH SECURITY_ENFORCED ORDER BY Name ];
       }

       @AuraEnabled(cacheable=true)
     public static List<Account> getAccountsWithSecurityStripInaccessibleCheck(){
              SObjectAccessDecision securityDection =Security.stripInaccessible(AccessType.READABLE,
                [SELECT Name,AnnualRevenue,Industry FROM Account  ORDER BY Name]
                );
                return securityDection.getRecords();
       }
}