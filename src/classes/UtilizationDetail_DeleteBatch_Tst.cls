@isTest(SeeAllData=false)
private class UtilizationDetail_DeleteBatch_Tst {
    //TO DO
    private static final String DEFAULT_PRACTICE_NAME = 'US';
    private static final String DEFAULT_REGION_NAME = 'US';
    private static final String DEFAULT_GROUP_NAME = 'psaTestGroup';
    private static final String DEFAULT_RESOURCE_NAME = 'PSA Test Resource';

    private static pse__Practice__c defaultPractice = psaTestUtil.createTestPractice(DEFAULT_PRACTICE_NAME);
    private static pse__Region__c defaultRegion = psaTestUtil.createTestRegion(DEFAULT_REGION_NAME);
    private static pse__Grp__c defaultGroup = psaTestUtil.createTestGroup(DEFAULT_GROUP_NAME);

    // private static User u1 = TestUtility.createTsetUser(1, null, null, true).get(0);
    
    // private static Contact defaultResource = psaTestUtil.createTestResource(TestUtility.createTsetUser(1, null, null, true).get(0), defaultRegion, defaultPractice, defaultGroup, 'GTT-UDSAD', 'Associate Consultant');

    @isTest
    private static void proposalUtilizationDeletionTest(){
        list<pse__Utilization_Detail__c> utilizations = new list<pse__Utilization_Detail__c>();
        pse__Utilization_Calculation__c defaultUtilization = new pse__Utilization_Calculation__c();
        defaultUtilization.Name = 'Region Utilization - Scheduled Weekly-DO NOT USE';
        defaultUtilization.pse__Type__c = 'Current Year and Next Year';
        defaultUtilization.pse__Region__c = defaultRegion.Id;
        defaultUtilization.pse__Include_Sublevels__c = true;
        defaultUtilization.pse__Include_Sublevels_in_Subtotals__c = true;

        insert defaultUtilization;
        Integer rand = math.round(math.random()*100)+1;
        for(integer i=0;i<rand;i++){
            // pse__Utilization_Detail__c defaultDetail = new pse__Utilization_Detail__c();
            pse__Utilization_Detail__c defaultDetail = (pse__Utilization_Detail__c) Json.deserialize('{"name" : "UD30173100"}',pse__Utilization_Detail__c.class);
            defaultDetail.pse__Practice__c = defaultPractice.Id;
            // defaultDetail.pse__Group__c = defaultGroup.Id;
            defaultDetail.pse__Utilization_Calculation__c = defaultUtilization.Id;
            // defaultDetail.Name += string.valueof(i);
            utilizations.add(defaultDetail);
        }

        insert utilizations;

        Test.startTest();
        id batchInstance=database.executeBatch(new UtilizationDetail_DeleteBatch(), rand);
        Test.stopTest();
        System.assertNotEquals(batchInstance, null, 'Error Assertion there is not batch job to proccess');
        // System.assertEquals(utilizations.size(), 27); //assert if delete all records after batch execution
    }

    @isTest
    private static void testScheduler() {
        // CRON expression: midnight on March 15. Because this is a test, 
        // job is supposed to execute immediately after Test.stopTest()
        String cronExpr = '0 0 0 15 3 ? 2022';
        String jobRunningTime = '2022-03-15 00:00:00';

        Test.startTest();
        UtilizationDetail_BatchScheduler job= new UtilizationDetail_BatchScheduler();
        String jobId = System.schedule('myJobTestJobName', cronExpr, job);
        job.execute(null);
        Test.stopTest();
    }
}