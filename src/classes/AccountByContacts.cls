public with sharing class AccountByContacts {
    
    public Account account_temp {get; set;}
    
    public AccountByContacts(){
    	account_temp = new Account();
    	accountcontact();
    }
    
    public List<AccountWrapper> wraplist = new List<AccountWrapper>();
    
    public void accountcontact(){
// Will create a Map with AccountId as Key and the account as value
        Map<Id, AccountWrapper> accByContact = new Map<Id, AccountWrapper>();
        for(Account acc: [SELECT CreatedBy.Name, CreatedById, Account.Name, (SELECT name, Contact.FirstName, Contact.LastName, Contact.Phone, Contact.Email FROM Account.Contacts) FROM Account ORDER BY Account.Name]){
            AccountWrapper accWrapByCont = accByContact.get(acc.CreatedById);
            if(accWrapByCont == null){
                accWrapByCont = new AccountWrapper();
                accByContact.put(acc.CreatedById,accWrapByCont);
                accWrapByCont.userId = acc.CreatedById;
                accWrapByCont.uName = acc.CreatedBy.Name;
            }
            accWrapByCont.accounts.add(acc);
        }
        wraplist = accByContact.values();
    }
    
    public List<AccountWrapper> getaccounts(){
        return wraplist;    
    }
    
    public class AccountWrapper{
        public Id userId{get; set;}
        public String uName{get; set;}
        public List<Account> accounts {get; set;}
        public AccountWrapper(){
            accounts = new List<Account>();
        }
    }
    
    public PageReference processMessage(){
        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'This page was created using ONLY one query' );
        ApexPages.addmessage(msg);
        return null; 
    }
}