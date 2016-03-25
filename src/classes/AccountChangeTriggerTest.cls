/***********************************************
* Copyright (c) 2016, ABB Enterprise Software Inc.
* All rights reserved.
* Author        :   David Perez(kitsunebrave)
* Related Task  :   Trigger Unit Test
************************************************/
@isTest
private class AccountChangeTriggerTest {

    @isTest static void myUnitTest() {
        // TO DO: implement unit test
        
        Account examAcc = new Account(Name='Alpiq Holding AG', Type='Client', Account_Status__c='Active', Account_Area__c='EMEA',
    									FES_Region__c='NEU', Territory__c='Continental Europe', Account_Country__c='Switzerland (CH)', Market__c='Energy & Utilities', Segment__c='Gas');
    	try {
		    insert examAcc;
		    Account testAccount = [SELECT Id, Name FROM Account];
		    System.assertEquals('Alpiq Holding AG', testAccount.Name);
    		System.debug(examAcc);
        } 
        catch (Exception e) {
        	
        	system.assertEquals('You cannot insert this record!', e.getMessage());
  		}
		   //Stop Test
		   Test.stopTest();
	    }
}