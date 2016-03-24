/***********************************************
* Copyright (c) 2016, ABB Enterprise Software Inc.
* All rights reserved.
* Author        :   David Perez(kitsunebrave)
* Related Task  :   Ticket-00382254
* Purpose       :   PopUp Extension Apex Class
************************************************/
@isTest
private class PopUpExtensionTest {
	
    @isTest static void TestMain(){
    	// TO DO: implement unit test
		
		PopUpExtension controller = new PopUpExtension();
		System.assert(controller != null);
    	
    	List<Opportunity> supports = (Opportunity)controller.lstWrapperOpp();
    	System.assert(supports != null);
    	
    	for(Opportunity o : supports){
	    	try{	 
	    		System.assert(o.Account__c.Id != null);
	    		System.assert(o.Opportunity__c.Id != null);
	    		
	    		System.assertEquals(o.Account_Name__c,'Ameren Services Company');   		
	    	 	System.assertEquals(o.Opportunity__c,'ICE - Parts and Cables (E-7656)');
    	 		System.assert(true, popupExtension.IsNotRepeat());
	    	}
	    	catch (exception e){
	    		System.assert(false, popupExtension.IsNotRepeat(), ApexPages.Severity.ERROR,'Error Occured while showing a list of opportunities '+e.getMessage());
	    	} 	
    	}
	}
	
	@isTest static void TextNullPointException(){
		
	}
	
	@isTest static void OutOfRange(){
		
	}
}