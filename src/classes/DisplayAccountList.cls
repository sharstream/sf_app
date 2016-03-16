public with sharing class DisplayAccountList{
    public Account account_temp {get; set;}
    public String id1{get; set;}
    
     public DisplayAccountList()
    {
    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Select an Account'));
    }
    
    /*public DisplayAccountList(ApexPages.StandardController controller)
    {
    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Select an Account'));
    }*/
    
    //task 1
     public List<Account> getAccounts(){
    	return [SELECT Id, Name, BillingState, Phone, Website FROM Account ORDER BY Name];//query to find an account
    } 

    public String nickname{get; set;}
    public void displayMsg(){
    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Selected by'+id1+'.'));
	}
}