global class UtilizationCalculation_UndeployBatch implements Database.Batchable<sObject> {
    public String query;

    global UtilizationCalculation_UndeployBatch() {
        query = 'SELECT Id,Name,pse__Utilization_Calculation__c FROM pse__Utilization_Detail__c WHERE pse__Utilization_Calculation__c IN (SELECT Id FROM pse__Utilization_Calculation__c WHERE Name = \''+String.escapeSingleQuotes('Region Utilization - Scheduled Weekly-DO NOT USE')+'\') LIMIT 9999';
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        try{
            if(Test.isRunningTest()) {
                id testUserId = [Select Id From User Where Email = 'christian.cordova@us.abb.com' LIMIT 1].id;
            }
        }    
        catch(Exception ex){
            System.debug('=====Generated query ' + query); 
            System.debug('An unexpected error has occurred: ' + ex.getMessage());
        }  
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        
        list<sObject> lstDeleteRecords = new list<sObject>();
        
        for (sObject obj : scope) {
            pse__Utilization_Detail__c detail = (pse__Utilization_Detail__c)obj;
            lstDeleteRecords.add(detail);
        }
        lstDeleteRecords.sort();
        delete lstDeleteRecords;
        DataBase.emptyRecycleBin(lstDeleteRecords);   
    }

    global void finish(Database.BatchableContext BC) {
        SchedulableContext sc = null;
        //calculate the Asyn Queue Batch list and run each iteration schedule for the first batch and then execute the second one
        //unitl the Utilization Calculation Details list is empty
        System.debug(LoggingLevel.WARN,'Batch Process Utilization Calculation Undeploy package 1 Finished');
        //Build the system time of now + 20 seconds to schedule the batch apex.
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(20);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        system.debug(chron_exp);
        UtilizationCalculation_Batch utilizationBatch2Sched = new UtilizationCalculation_Batch();
        //Schedule the next job, and give it the system time so name is unique
        System.scheduleBatch(utilizationBatch2Sched,'Utilization Calculation Details Batch '+ sysTime.getTime(), Integer.valueOf(chron_exp));
    }
}