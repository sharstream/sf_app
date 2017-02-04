global class UtilizationCalculation_Batch implements Database.Batchable<sObject> {
    public String query;

    global UtilizationCalculation_Batch() {
        query = 'SELECT Id,Name FROM pse__Utilization_Calculation__c WHERE Name = \''+String.escapeSingleQuotes('Region Utilization - Scheduled Weekly-DO NOT USE')+'\'';
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
            pse__Utilization_Calculation__c calculation = (pse__Utilization_Calculation__c)obj;
            lstDeleteRecords.add(calculation);
        }
        lstDeleteRecords.sort();
        delete lstDeleteRecords;
        DataBase.emptyRecycleBin(lstDeleteRecords); 
    }

    global void finish(Database.BatchableContext BC) {
         System.debug(LoggingLevel.WARN,'Batch Process Utilization Calculation Undeploy package 2 Finished');
    }
}