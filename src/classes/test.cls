public class test
{
        List<AccountWrapper> wraplist=new list<AccountWrapper>();
        
        public test()
        {
               Map<Id, AccountWrapper> accMap=new Map<Id, AccountWrapper>();
               
               List<Account> AccountList = [SELECT createdby.name,CreatedbyID,Account.Name,(SELECT name,Contact.FirstName, Contact.LastName, Contact.Phone, Contact.Email FROM Account.Contacts) FROM Account ORDER BY Account.Name]; 
                   
                   for(account a: AccountList)
                   {
                 
                        AccountWrapper accWrap=accMap.get(a.CreatedByid);  
            
                               if (accWrap==null)
                               {
                                      accWrap=new AccountWrapper();
                                      accMap.put(a.CreatedByid, accWrap);
                                      accWrap.userid=a.CreatedByid;
                                      accWrap.username=a.CreatedBy.name;
                               }
                               
                       accWrap.accounts.add(a);
                   }
               
               wrapList=accMap.values();
       }
       
       public list<AccountWrapper> getaccounts()
       {
              return wraplist;
       }
       
       public class AccountWrapper
       {
              public id userid {get; set;} 
              public string username {get; set;}
              public List<Account> accounts {get; set;}
                  
              public AccountWrapper()
              {
                  accounts=new List<Account>();
              }
       }
}