@isTest
private class AccountControllerWithSecurityTest {

 
@isTest
    private static void testgetAccounts(){
        test.startTest();
        List<Account> accList = AccountControllerWithSecurity.getAccounts();
        test.stopTest();
        system.assertEquals(2, accList.size());
        
    }
@isTest
    private static void checkCRUDForAccount(){
        boolean isSuccess;
        test.startTest();
        List<Account> accList = [select name from account with USER_MODE limit 10];
        Database.delete(accList, false, AccessLevel.USER_MODE);
        isSuccess = AccountControllerWithSecurity.getAccountsCRUDCheck().isEmpty();
        test.stopTest();
        system.assertEquals(true, isSuccess, 'delete permission should be false');
    }}