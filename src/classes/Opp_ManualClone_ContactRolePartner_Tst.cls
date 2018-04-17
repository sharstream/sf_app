@isTest(SeeAllData = true)
private class Opp_ManualClone_ContactRolePartner_Tst {

    @isTest static void myProposalTest() {
      
      User u1 = TestUtility.createTsetUser(1, 'System Administrator', null, true).get(0);
	  System.RunAs(u1){
	    //Start: Prepare Test Data
		//Account
		Account a = TestUtility.createTestAccounts(1, true).get(0);
		Account a1= TestUtility.createTestAccounts(1, true).get(0);
		List<Account> aList = new List<Account>();
		aList.add(a);
		aList.add(a1);

		//Create PriceBook
		Id pricebookId = Test.getStandardPricebookId();

		//Create your product
		Product2 prod = new Product2(
		     Name = 'Maintenance Product',
		     ProductCode = 'Pro-X',
		     isActive = true		     
		);
		insert prod;

		//Create your pricebook entry
		PricebookEntry pbEntry = new PricebookEntry(
			 Pricebook2Id = pricebookId,
			 Product2Id = prod.Id,
			 UnitPrice = 100.00,
			 UseStandardPrice = false,
			 IsActive = true
		);

		insert pbEntry;

		//Opportunity
		Opportunity opp = TestUtility.createTestOpportunity(1,a,true)[0];

		opp.Type = 'New Client';
		opp.Industry__c = 'Distribution';
		opp.StageName = 'Prospecting';
		opp.PriceBook2Id = pricebookId; 

		update opp;
		Opportunity Newopp = TestUtility.createTestOpportunity(1,a1,true)[0];
		Newopp.Type = opp.Type;
		Newopp.Industry__c = opp.Industry__c;
		Newopp.StageName = opp.StageName;
		Newopp.PriceBook2Id = opp.PriceBook2Id;
		Newopp.BidType__c = opp.BidType__c;
		if (NewOpp.StageName == 'Selected Vendor') {
		NewOpp.Probability = 90;
		}

		if (NewOpp.StageName == 'Contract Signing') {
		    NewOpp.Probability = 95;
		}

		if (NewOpp.StageName == 'Prospect') {
		    NewOpp.Probability = 10;
		}
		if (NewOpp.StageName == 'Qualified') {
		    NewOpp.Probability = 25;
		}

		if (NewOpp.StageName == 'Discovery') {
		    NewOpp.Probability = 40;
		}

		if (NewOpp.StageName == 'Short Listed') {
		    NewOpp.Probability = 60;
		}
		if (NewOpp.StageName == 'Closed') {
		    NewOpp.Probability = 99;
		}

		if (NewOpp.StageName == 'Won') {
		    NewOpp.Probability = 100;
		}

		if (NewOpp.StageName == 'Not Pursued') {
		    NewOpp.Probability = 0;
		}

		if (NewOpp.StageName == 'Lost') {
		    NewOpp.Probability = 0;
		}

		if (NewOpp.StageName == 'Cancellation') {
		    NewOpp.Probability = 100;
		}
		System.debug('Probabiity %%%%%%%%%% '+NewOpp.Probability);
		NewOpp.Forecast_Call__c = 'Upside';
		if (opp.Owner.IsActive == true && opp.Owner.UserRoleId == '00E60000000pd27'){
		    NewOpp.OwnerId = opp.Owner.Id;
		}

		else if(opp.Owner.IsActive==true && opp.BU_Code__c=='2872 - Network Control'){
		   NewOpp.OwnerId = opp.OwnerId;
		}
		update NewOpp;
		Contact con = new Contact();
		con.lastname='test';
		insert con; 
												 
		OpportunityContactRole oppConRole = new OpportunityContactRole();
		oppConRole.opportunityId = opp.id;
		oppConRole.ContactId = con.id;
		insert oppConRole;

		List<OpportunityLineItem> lstNewPro = new List<OpportunityLineItem>();
		List<OpportunityLineItem> oldOLIlist = TestUtility.createTestOpportunityLineItem(3, opp, 'Maintenance', pbEntry,true);
		List<OpportunityLineItem> newOLIlist = TestUtility.createTestOpportunityLineItem(3, NewOpp, 'Renewal', pbEntry,true);

		for(OpportunityLineItem newOLI : newOLIlist){
			OpportunityLineItem toUpdateOLI = new OpportunityLineItem();
			toUpdateOLI.OpportunityId = NewOpp.Id;
			toUpdateOLI.Id = newOLI.Id;
			toUpdateOLI.Customer_Price_Override__c = newOLI.Customer_Price__c;
			toUpdateOLI.UnitPrice = newOLI.UnitPrice;
			toUpdateOLI.Discount = 0;
			toUpdateOLI.Discount__c = 0;
			toUpdateOLI.Revenue_Stream__c = newOLI.Revenue_Stream__c;
			toUpdateOLI.Revenue_Stream_Type__c = newOLI.Revenue_Stream_Type__c;
			toUpdateOLI.Contract_Type__c = newOLI.Contract_Type__c;
			toUpdateOLI.Start_Date__c = newOLI.Start_Date__c;
			toUpdateOLI.End_Date__c = newOLI.End_Date__c;
			toUpdateOLI.Description = newOLI.Description;
			toUpdateOLI.Revenue_Stream_Type__c = 'Renewal';
			toUpdateOLI.Quantity = newOLI.Quantity;
			//Defect 705679 clone all opportunity products on the new Oppty
			lstNewPro.add(toUpdateOLI);
		}

		Partner partnerTest = new Partner(accountToId = a1.id, OpportunityId = opp.id, role='Advertiser', isPrimary = true);
		insert partnerTest;
		update opp;

		PageReference pRef = Page.Opp_ManualClone_OperationalPage;
		pRef.getParameters().put('id', opp.Id);
		Test.setCurrentPage(pRef);
		pRef.getParameters().put('id',opp.id);

		//End: Prepare Test Data

		Test.startTest(); //Start Test

		Opp_CloneManual_ContactRoleAndPartner controller = new Opp_CloneManual_ContactRoleAndPartner(
												 new ApexPages.standardController(opp));
		PageReference changeStage = controller.changeStageName();
		system.assertEquals(null, changeStage);

		System.debug('#### controller = '+controller);
		System.assertNotEquals(null,controller.redirect());

		//PageReference prSave = controller.redirect();
		//System.assertNotEquals(prSave, null);

		List<OpportunityContactRole> lstOCR = 
		[SELECT o.SystemModstamp, o.Role, o.OpportunityId, 
		        o.LastModifiedDate, o.LastModifiedById, o.IsPrimary, 
		        o.IsDeleted, o.Id, o.CreatedDate, o.CreatedById, o.ContactId 
		FROM OpportunityContactRole o 
		WHERE o.OpportunityId = :opp.Id];
		System.assertEquals(lstOCR.size(), 1);

		List<OpportunityPartner> lstOPT = 
			[SELECT IsPrimary,AccountToId,OpportunityId, Role, 
		     	LastModifiedDate, LastModifiedById, IsDeleted, 
		     	Id, CreatedDate, ReversePartnerId
		FROM OpportunityPartner 
		WHERE OpportunityId = :opp.Id AND AccountToId <>:opp.AccountId];    
		System.assertEquals(lstOPT.size(), 1);  

		List<OpportunityLineItem> lstOLI = 
			[SELECT Id
		FROM OpportunityLineItem 
		WHERE Id = :newOLIlist.get(0).Id];    
		System.assertEquals(lstOLI.size(), 1);  

		Test.stopTest();
	  } 
    }
}