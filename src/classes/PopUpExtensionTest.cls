@isTest
public with sharing class PopUpExtensionTest {
        @isTest static void DifferentOppTest(){
    	
    	//PopUpExtension popupext = new PopUpExtension();
    	String log = '';
    	log += '*********************************Start Debugging**************************************';
		
		Account examAcc = new Account(Name='Alpiq Holding AG', Type='Client', Account_Status__c='Active', Account_Area__c='EMEA',
    									FES_Region__c='NEU', Territory__c='Continental Europe', Account_Country__c='Switzerland (CH)', Market__c='Energy & Utilities', Segment__c='Gas');
    	insert examAcc;
		Opportunity examOpp = new Opportunity(Name='ICE - Parts and Cables (E-7656)',
									  		Type='Existing Client', Area__c='AMR', FES_Region__c='SAM',
	  										Territory__c='SAM Utilities', Opportunity_Country__c='Costa Rica (CR)', CurrencyIsoCode='EUR - Euro',
										  	CloseDate=System.today(), BU_Code__c='2872 - Network Control Services', StageName='Won', Forecast_Call__c='Won',
						  					Regional_Forecast_Call__c='Won', Win_Loss_Not_Pursued_Reason_Category__c='Price', Account=examAcc);		  				
    	insert examOpp;	
		Support_Order__c examSupp = new Support_Order__c(Support_Order_Type__c='Hosting', 
														Status__c='Current', CurrencyIsoCode='EUR - Euro', 
														Owner_Expiration_Notice__c='15 Days', Customer_Region__c='EMEIA', Opportunity__c=examOpp.Id);
		insert examSupp;
    	
    	PopUpExtension.WrappDiffOpp wrapper = new PopUpExtension.WrappDiffOpp('SO-1528',false, examSupp);
    	
    	//System.assert(wrapper.IsEmpty());
    	//System.assert(wrapper.oppName != null);
    	System.debug(wrapper);
		
    	/*try{	 		
    	 	System.assertEquals(examOpp.Name,'ICE - Parts and Cables (E-7656)');
	 		System.assert(true, PopUpExtension.IsNotRepeat(),'The Support_Order__c doesn\'t have a consolidate opportunity');	 		
    	}
    	catch (exception e){
    		log += 'Description: '+e.getMessage() + '\n';
    		System.assert(false, PopUpExtension.IsNotRepeat(), ApexPages.Severity.ERROR,'Error Occured while showing a list of opportunities '+e.getMessage());
    	} */	
	}
	
	@isTest static void OutputMessageTest(){
		ApexPages.Message[] messages = ApexPages.getMessages();
		Boolean found = false;
		for(ApexPages.Message sms : messages){
			if(sms.getSummary() != '')
				found = true;
		}
		System.assert(found);
	}
	
	@isTest static void EmptyAccFieldTest(){
		update new Account(Name='New Account');
		Account acc = [SELECT Id, Name FROM Account LIMIT 1];
		System.assertEquals('New Account',acc.Name);
	}
	
	@isTest static void EmptyOppFieldTest(){
		update new Opportunity(Name='New Opportunity');	
		Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
		System.assertEquals('New Opportunity',opp.Name);
	}
	
	@isTest static void EmptySuppFieldTest(){
		update new Support_Order__c(Support_Order_Type__c='Evaluation');
		Support_Order__c supp = [SELECT Id, Support_Order_Type__c FROM Support_Order__c LIMIT 1];
		System.assertEquals('Evaluation',supp.Support_Order_Type__c);
	}
}