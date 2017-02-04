/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seealldata=true)
private class SOW_Summary_Project_Controller_Test {
	
    @isTest static void InitialSteps() {
        // TO DO: implement unit test       
        Test.startTest();
		
		pse__Region__c region = psaTestUtil.createTestRegion('TestRegion');
    	pse__Practice__c practice = psaTestUtil.createTestPractice('TestPractice');
    	pse__Grp__c grp = psaTestUtil.createTestGroup('TestGroup');
    	String orgId = UserInfo.getOrganizationId();
	    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
	    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
	    String uniqueName = orgId + dateString + randomInt;
	    uniqueName = uniqueName.substring(0,7);
    	
    	pse__Proj__c proj_temp = psaTestUtil.createTestProject('TestProject', region, practice, grp,
        						 'SAP123', true, true, System.today(), System.today().addMonths(2), null);

        proj_temp.pse__Planned_Hours__c = 160.00;
        proj_temp.pse__Billing_Type__c = 'Time and Materials';
        proj_temp.CurrencyIsoCode = 'USD';
        proj_temp.SOW_Sold_Hours__c = 1;
        proj_temp.SOW_Projected_Cost__c = 3200.00;
        proj_temp.SOW_Average_Standard_Price__c = 5000.00;
        proj_temp.SOW_Average_Sell_Price__c = 5000.00;
        proj_temp.SOW_Customer_Price__c = 5000.00;
		update proj_temp;
        User testUser = psaTestUtil.createTestUser(uniqueName, uniqueName+'@test.test', 'testlname', 'testfname', uniqueName+'@test.test', 'tester', 'T123');

    	Contact resource = psaTestUtil.createTestResource(testUser, region, practice, grp, 'GEID332',
        'Project Manager');
        
        List<pse__Permission_Control__c> pcs = new List<pse__Permission_Control__c>();
        pse__Permission_Control__c pc1 = new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Resource__c=resource.Id, pse__Staffing__c=true);
        pse__Permission_Control__c pc2 = new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Region__c= region.Id, pse__Staffing__c=true);
        pse__Permission_Control__c pc3 = new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Region__c= region.Id, pse__Resource_Request_Entry__c=true, 
        								 pse__Cascading_Permission__c = true);
        pcs.add(pc1);
        pcs.add(pc2);
        pcs.add(pc3);
        insert pcs;
      
      	Opportunity o = PsaTestUtil.createTestOpportunity('Test Opp808', 'Prospect');
      	
        SOW_Summary_Project_Controller control = new SOW_Summary_Project_Controller(
        										 new ApexPages.standardController(proj_temp));
        
        pse__Resource_Request__c resource_temp = psaTestUtil.createTestResourceRequest(proj_temp.Id, 100, 'Project Manager',
        										 region.Id, practice.Id, false);    

        resource_temp.pse__Project__c =  proj_temp.Id;
        resource_temp.pse__Opportunity__c = o.Id;
        resource_temp.CurrencyIsoCode = proj_temp.CurrencyIsoCode;
        resource_temp.pse__Start_Date__c = Date.parse('4/4/2016');
        resource_temp.pse__End_Date__c = Date.parse('5/4/2016');
        resource_temp.pse__SOW_Hours__c = 184.00; 
        resource_temp.Working_Hours_Per_Day__c = 8.00;
		Id productId = [Select Id from PriceBookEntry Where IsActive = true AND
            		   CurrencyIsoCode = :o.CurrencyIsoCode LIMIT 1].Id;
            
		OpportunityLineItem li = new OpportunityLineItem();
        li.OpportunityId = o.Id;
        li.PriceBookEntryId = productId;
        li.Quantity = 1;
        li.UnitPrice = 100;
        li.Cost__C = 50;
        li.Revenue_Stream__c = 'Maintenance';
        li.Revenue_Stream_Type__c = 'Implementation';
        li.Contract_Type__c = 'Time & Materials';
        li.Start_Date__c = Date.today();
        li.End_Date__c = Date.today().addDays(30);
        li.pse__IsServicesProductLine__c = true;
        insert li;

		resource_temp.Opportunity_Product_Id__c = li.Id;

        insert resource_temp;
        System.assert(resource_temp != null);
        System.assertEquals('Time and Materials',proj_temp.pse__Billing_Type__c);       
    	System.assertNotEquals(0,control.CalculateMarginFixedPrice());
        proj_temp.pse__Billing_Type__c = 'Fixed Price';
        update proj_temp;

        System.assertEquals('Fixed Price',proj_temp.pse__Billing_Type__c);   
        System.assertNotEquals(0,control.CalculateMarginFixedPrice());
    	
    	Test.stopTest();
    }
    
}