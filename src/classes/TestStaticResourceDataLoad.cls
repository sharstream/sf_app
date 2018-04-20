@isTest
private class TestStaticResourceDataLoad {
    private static void testStaticResourceDataLoadMasterDetail() {
        List<SObject> aList = Test.loadData(Account.sObjectType,'testAccounts');
        List<SObject> cList = Test.loadData(Contact.sObjectType,'testContacts');

        String res = '';
        for (Account a: [select id, name, (select id, firstname, lastName,email, 
                                 reportsTo.lastname, alternate_account__r.name from Contacts) 
                             from Account where id IN :aList]) {
            String cRes = '';
            for (Contact c: a.contacts)
                cRes += '\n...name= ' + c.firstName + ' ' + c.lastName + ' ' + c.email + 
                             ' altAcct=' + c.alternate_account__r.name;
            res += '\n account id/name: ' + a.id + ' ' + a.name + ' w/ contacts: ' + cRes;
        }
        System.debug(LoggingLevel.INFO,'res='+res);
    }
}