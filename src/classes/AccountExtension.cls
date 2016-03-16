public with sharing class AccountExtension {
	
	public Account account_temp { get; set; }
	public AccountExtension(ApexPages.StandardController controller) {
		account_temp = (Account) controller.getRecord();
	}	
}