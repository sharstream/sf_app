@isTest(SeeAllData = true)
private class SO_AutoCopy_Controller_tst {

	@isTest
    private static void myUnitTest() {
	    
	    //Start: Prepare Test Data
	  	//Account
	  	//Account a = TestUtility.createTestAccounts(1, true).get(0);
	    Account acc = new Account();acc.Name = 'TestAccount';acc.Type = 'Client';acc.Account_Area__c = 'Americas';
      	acc.FES_Region__c = 'NAM';acc.Industry = 'Financial';acc.Country_Code__c = 'US';acc.Market__c = 'Other';
      	acc.Segment__c = 'Other';  
      	insert acc;
	  	//Opportunity
	  	Opportunity opp = TestUtility.createTestOpportunity(1,acc,true)[0];
	  	opp.Type = 'New Client';opp.Industry__c = 'Distribution';opp.StageName = 'Prospecting';
	  	update opp;		      
	  	//Contract
	  	Contract contract = new Contract();contract.AccountId = acc.Id;contract.RecordTypeId = '012600000005B6P';     
      	contract.Name = 'test';contract.CurrencyIsoCode = 'USD';contract.StartDate = system.today();
      	contract.Status = 'Open';    
		insert contract;
	  	//Support Order
	  	Support_Order__c so = new Support_Order__c();                     
	  	so.Opportunity__c = opp.Id;so.Contract__c = contract.Id;so.Owner_Expiration_Notice__c = '15 Days';
	  	so.CurrencyIsoCode = 'USD';so.Current_Term_Start_Date__c = system.today();so.Current_Term_End_Date__c = system.today().addDays(5);
	  	so.Contract_Date__c = system.today();so.Status__c = 'Open';    
	  	insert so;
	  	System.debug('#### so = '+so);
	  	//Product2
	  	Product2 product2 = TestUtility.createTestProduct2(1,true).get(0);
	  	//Supported Product 
	  	List<Supported_Product__c> spList = 
	      	TestUtility.createTestSupportedProduct(5, so,product2, true);
	  		for(integer i=0;i<spList.size();i++)
	  	  	  	spList.get(i).Gross_Annual_Support_Fee__c =100;
	  		update spList;
	  	
	  	PageReference testPage = Page.SO_AutoCopy_MCA_SelectPage;	  	
	  	
	  	//Starting Test Runner
	  	Test.startTest();  	
	  	ApexPages.StandardController controlStd = new ApexPages.StandardController(so);  	
	  	SO_AutoCopy_WSController controller = new SO_AutoCopy_WSController(controlStd);
	  	
	  	controller.oldSO = so.Id;  	
	  	testPage.getParameters().put('id', String.valueOf(controller.oldSO));
	  	System.debug('SYSTEM DEBUG PARAMETERRS >>>>>>>>>>>>>>>>'+String.valueOf(testPage.getParameters()));
	  	Test.setCurrentPage(testPage);
	  	
	  	System.debug('SYSTEM DEBUG >>>>>>>>>>>>>>>>'+controller.oldSO); 		  	
	  	System.debug('SYSTEM DEBUG PAGEREFERENCE>>>>>>>>>>>>>>>>'+String.valueOf(controller.CopySO()));
	  	
	  	System.assertNotEquals(null,testPage);	  	
	  	System.assertEquals('/apex/so_autocopy_mca_selectpage?id='+controller.oldSO, ApexPages.currentPage().getUrl());
	  	controller.CopySO();
	  	Support_Order__c SOtestFailer = controller.SupportOrderCopied;
	  	//System.assertEquals('/apex/so_autocopy_mca_selectpage?id='+SOtestFailer.Id, ApexPages.currentPage().getUrl());
	  	//System.assertEquals(controller.SupportOrderCopied.Id,testPage.getUrl());
	  	
	  	Test.stopTest();
	}
}