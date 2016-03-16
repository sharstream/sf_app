public with sharing class MyWizardController {
	
	public Account account_temp { get; set; }
	public Contact contact_temp { get; set; }
	
	public MyWizardController() {
		account_temp = new Account();
		contact_temp = new Contact();
	}
	
	/*public PageReference next() {
		return Page.step2;
		
	}*/
	
	/*public PageReference previous() {
		return Page.step1;
	}*/
	
	public PageReference save() {
		Database.insert(account_temp);
		contact_temp.accountId = account_temp.id;
		ApexPages.StandardController contactController = new ApexPages.StandardController(contact_temp);
		return contactController.save();
	}
}