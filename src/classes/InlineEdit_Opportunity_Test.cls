/*************************************************************************
Name:           InlineEdit_Opportunity_Test
Author:         David Perez
Created Date:   create on 06/15/2017 per 564720: Inline Edit Oppty Test Class
Description:    This class acts as a test suite by Inline Oppty List View

David Perez modified: on 07/07/2017 avoid Class static variable cannot be accessed via object instance
*************************************************************************/
@isTest(SeeAllData = true)
private class InlineEdit_Opportunity_Test{
  @isTest
  static void setupTestData(){
    User u1 = TestUtility.createTsetUser(1, null, null, true).get(0);

    system.RunAs(u1){
		//Start: Prepare Test Data
		//Account
		Account a = TestUtility.createTestAccounts(1, true).get(0);
		list<Opportunity> jedis = new list<Opportunity>();
		//Opportunity
		for (Opportunity oldOppty : TestUtility.createTestOpportunity(2,a,false)) {
			Opportunity newOppty = new Opportunity();
			newOppty.Name = 'Inline Testing Oppty';
	 		//newOppty.OwnerId = a;
	 		newOppty.CloseDate = system.today();
	 		newOppty.Forecast_Call__c = 'Pipeline';
	 		newOppty.OwnerId = u1.Id;
	 		newOppty.Opportunity_Description__c = 'Jedi Description';
	 		newOppty.Status__c = 'Jedi Status';
	 		newOppty.Next_Steps__c = 'Jedi Steps for Close';
			newOppty.Type = 'Renewal';
			newOppty.Industry__c = 'Distribution';
			newOppty.StageName = 'Prospecting';
			newOppty.BidType__c = 'Sole Sourced';
			newOppty.Probability = 90;
			newOppty.BU_Code__c='2851 - Enterprise Software';
			newOppty.StageName='Selected Vendor';
			jedis.add(newOppty);
		}
		
		insert jedis;
		Id OpporutnityRecordType = [select Id from RecordType where Name = 'Operations Opportunity Record Type'].Id;

		Test.startTest();

		system.assertEquals(true,jedis.size()>0);

		//callout product version id by web parameter
		PageReference pRef = Page.InlineEdit_OpportunityPage;
	  	Test.setCurrentPage(pRef);

		List<Opportunity> opportunity_Obj  =  [SELECT Id, Name, Area__c, Type, Forecast_Call__c, Account.Name, Next_Steps__c, OwnerId, BU_Code__c, 
						        				RecordTypeId, CloseDate, Regional_Forecast_Call__c, 
						    					Opportunity_Description__c, RecordType.Name, Status__c, 
												StageName, Amount
												from Opportunity where Id IN:jedis];

		system.assertEquals(true,opportunity_Obj.size()>0);

		InlineEdit_Opportunity controller = new InlineEdit_Opportunity();

		InlineEdit_Opportunity.opportunities = new list<Opportunity>(opportunity_Obj);

		system.assertEquals(true,InlineEdit_Opportunity.opportunities.size()>0);

		controller.opptyWrappers = new list<InlineEdit_Opportunity.WrapOppty>();
		InlineEdit_Opportunity.selectedWrapperList = new list<InlineEdit_Opportunity.WrapOppty>();

		for(Opportunity oppty : InlineEdit_Opportunity.opportunities) {     
            InlineEdit_Opportunity.WrapOppty wrapperRec = new InlineEdit_Opportunity.WrapOppty(oppty);
            wrapperRec.selected = true;
            controller.opptyWrappers.add(wrapperRec);
        }
        system.debug('InlineEdit_Opportunity.opptyWrappers: '+controller.opptyWrappers);
        system.assertEquals(true,controller.opptyWrappers.size()>0);

        for (InlineEdit_Opportunity.WrapOppty wrapper : controller.opptyWrappers) {
            if (wrapper.selected) {
            	InlineEdit_Opportunity.selectedWrapperList.add(wrapper);
            }
        }
        system.debug('InlineEdit_Opportunity.selectedWrapperList: '+controller.opptyWrappers);
        system.assertEquals(true,InlineEdit_Opportunity.selectedWrapperList.size()>0);

        //Verify Save method output
        PageReference pageSave = controller.massSubmitOpportunities();
        PageReference opptyGeneralView = new PageReference('/' + '006/o');
        Test.setCurrentPage(opptyGeneralView);
        system.assertNotEquals(opptyGeneralView, null);
        controller.showPopup = true;
        PageReference popup = controller.showToPopup();
		PageReference prCancel = controller.Cancel();

  		system.assertNotEquals(prCancel, null);
        system.debug('#### controller1 = '+controller);

		test.stopTest();
	}
  }
}