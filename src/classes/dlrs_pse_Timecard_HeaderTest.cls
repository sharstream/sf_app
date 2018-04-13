/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest(SeeAllData=true)
private class dlrs_pse_Timecard_HeaderTest
{
    @IsTest
    private static void testTrigger()
    {
    	pse__Region__c region = psaTestUtil.createTestRegion('ICG Region');
        pse__Practice__c practice = psaTestUtil.createTestPractice('ICG Practice');
        pse__Grp__c grp = psaTestUtil.createTestGroup('ICG Grp');
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        uniqueName = uniqueName.substring(0,7);

    	pse__Proj__c project = new pse__Proj__c();
    	project.Name = 'ICG_Test_Project';
    	project.Company_Code__c = 'ICG';
    	project.ICG_Region__c = 'ICG IMEA';
    	project.pse__Start_Date__c = system.today();
    	project.pse__End_Date__c = Date.newInstance(2018, 12 , 31);
    	project.Status_of_Commercial_Steps__c = 'Frame Agreement';
    	project.Period_of_Engagement__c = 'Q1 - 2018';
    	project.Legal_Entity_Reporting_Unit__c = 'ABB Ltd - ABBHO';
    	project.pse__Billing_Type__c = 'ICG Fixed Price';
    	project.pse__Project_Type__c = 'ICG Project';
    	project.Project_Location__c = 'ICG Project';
    	project.ICG_Practice__c = 'L6ST';
    	project.pse__Planned_Hours__c = 120.00;
    	insert project;

    	User testUser = psaTestUtil.createTestUser(uniqueName, uniqueName+'@test.test', 'testlname', 'testfname', uniqueName+'@test.test', 'tester', 'T123');

    	Contact resource = psaTestUtil.createTestResource(testUser, region, practice, grp, 'GEID332', 'ICG Manager');

    	// Create a permission control that will allow us to staff the resource
        List<pse__Permission_Control__c> pcs = new List<pse__Permission_Control__c>();
        pse__Permission_Control__c pc1 = new pse__Permission_Control__c(pse__User__c = UserInfo.getUserId(), pse__Resource__c = resource.Id, pse__Staffing__c = true, pse__Cascading_Permission__c = true);
        pse__Permission_Control__c pc2 = new pse__Permission_Control__c(pse__User__c = UserInfo.getUserId(), pse__Region__c = region.Id, pse__Resource_Request_Entry__c = true,
            pse__Timecard_Entry__c = true, pse__Timecard_Ops_Edit__c=true, pse__Cascading_Permission__c=true, pse__Staffing__c = true, pse__Skills_And_Certifications_Entry__c = true,
            pse__Skills_And_Certifications_View__c = true, pse__Expense_Entry__c = true, pse__Expense_Ops_Edit__c = true,
            pse__Invoicing__c = true);
        pse__Permission_Control__c pc3 = new pse__Permission_Control__c(pse__User__c = UserInfo.getUserId(), pse__Practice__c = practice.Id, pse__Resource_Request_Entry__c = true,
            pse__Timecard_Entry__c = true, pse__Timecard_Ops_Edit__c = true, pse__Cascading_Permission__c = true, pse__Staffing__c = true, pse__Skills_And_Certifications_Entry__c = true,
            pse__Skills_And_Certifications_View__c = true, pse__Expense_Entry__c = true, pse__Expense_Ops_Edit__c = true,
            pse__Invoicing__c = true);
        pcs.add(pc1);
        pcs.add(pc2);
        pcs.add(pc3);
        insert pcs;

    	pse__Resource_Request__c rr = psaTestUtil.createTestResourceRequest(project.Id, 100, 'ICG Manager', region.Id, practice.Id);

    	// Create an initial assignment schedule
        pse__Schedule__c schedule = new pse__Schedule__c();
        schedule.pse__Start_Date__c = project.pse__Start_Date__c;
        schedule.pse__End_Date__c = project.pse__End_Date__c;
        schedule.pse__Monday_Hours__c = 8;
        schedule.pse__Tuesday_Hours__c = 8;
        schedule.pse__Wednesday_Hours__c = 8;
        schedule.pse__Thursday_Hours__c = 8;
        schedule.pse__Friday_Hours__c = 8;
        insert schedule;

        pse__Assignment__c assignment = new pse__Assignment__c(Name='ICG Assignment');

        if (rr != null){
            assignment.pse__Resource_Request__c = rr.Id;
        }

        assignment.pse__Is_Billable__c = false;
        assignment.pse__Project__c = project.Id;
        assignment.pse__Resource__c = resource.Id;
        assignment.pse__Schedule__c = schedule.Id;
        assignment.pse__Bill_Rate__c = 0.0;
        assignment.pse__Closed_for_Time_Entry__c = false;
    	assignment.pse__Planned_Hours__c = 40.00;
    	assignment.pse__Role__c = 'ICG Consultant';
    	assignment.pse__Status__c = 'Scheduled';
    	insert assignment;
        // Force the dlrs_pse_Timecard_HeaderTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new pse__Timecard_Header__c(pse__Project__c = project.Id, 
        	pse__Resource__c = resource.Id,pse__Start_Date__c = Date.today(), pse__End_Date__c = Date.newInstance(2018, 12 , 31),
        	pse__Assignment__c = assignment.Id)
        );
    }
}