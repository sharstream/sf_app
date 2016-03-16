public with sharing class SearchAccount {
    public Account account_temp {get; set;}
    
    public SearchAccount(){
    	account_temp = new Account();
    }
    
    public SearchAccount(ApexPages.StandardController controller){
    	account_temp = (Account) controller.getRecord();//add account by Id
    }
    
    //task 2
    public List<Account> acc{get; set;}
    
    public String searchString{get; set;}
    
    public void findAccount(){
    	String searchQuery ='SELECT Id, Name, BillingState, Phone, Website FROM Account WHERE Name LIKE \'%'+searchString+'%\' LIMIT 10';
    	acc = Database.query(searchQuery);//query to select by input parameter account
    }
    
    public void clear(){
    	acc.clear();
    }
}