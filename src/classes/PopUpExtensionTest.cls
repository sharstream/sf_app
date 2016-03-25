/***********************************************
* Copyright (c) 2016, ABB Enterprise Software Inc.
* All rights reserved.
* Author        :   David Perez(kitsunebrave)
* Related Task  :   Ticket-00382254
* Purpose       :   PopUp Extension Unit Test
************************************************/
@isTest
private class PopUpExtensionTest {
	
	
    @isTest static void TestMain(){
    	// TO DO: implement unit test
		
		PopUpExtension popupext = new PopUpExtension();
		System.assert(popupext != null);
		
    	popupext.WrappDiffOpp pwrapper = new popupext.WrappDiffOpp('AnyName',false); 
    	
    	List<wrapper> supports = popupext.lstWrapperOpp();
    	System.assert(supports != null);
    	
    	for(Opportunity o : supports){
	    	try{	 
	    		System.assert(o.Account__c.Id != null);
	    		System.assert(o.Opportunity__c.Id != null);
	    		
	    		System.assertEquals(o.Account_Name__c,'Ameren Services Company');   		
	    	 	System.assertEquals(o.Opportunity__c,'ICE - Parts and Cables (E-7656)');
    	 		System.assert(true, popupext.IsNotRepeat());
	    	}
	    	catch (exception e){
	    		System.assert(false, popupext.IsNotRepeat(), ApexPages.Severity.ERROR,'Error Occured while showing a list of opportunities '+e.getMessage());
	    	} 	
    	}
	}
	
	@isTest static void TextNullPointException(){
		
	}
	
	@isTest static void OutOfRange(){
		
	}
}