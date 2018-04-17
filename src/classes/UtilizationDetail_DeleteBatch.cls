public with sharing class UtilizationDetail_DeleteBatch implements Database.Batchable<SObject>, Database.Stateful {

    private static Boolean chainAnotherbatch = true;

    public static boolean runOnce(){
        if(chainAnotherbatch){
            chainAnotherbatch = false;
            return true;
        }else{
            return chainAnotherbatch;
        }
    }

    public UtilizationDetail_DeleteBatch() {    
    }

    public Database.QueryLocator start(Database.BatchableContext bc)
    {   
        return Database.getQueryLocator([
            SELECT Id FROM pse__Utilization_Detail__c 
            WHERE pse__Utilization_Calculation__r.Name = 'Region Utilization - Scheduled Weekly-DO NOT USE' LIMIT 50000
        ]);
    } 

    public void execute(Database.BatchableContext info, list<pse__Utilization_Detail__c> ids)
    {     
        System.debug('## deleting '+ids.size()+' utilization details records');   
        delete ids;   
        Database.emptyRecycleBin(ids);  
    }

    public void execute(SchedulableContext sc)  
    {   
        UtilizationDetail_DeleteBatch deleteCS = new UtilizationDetail_DeleteBatch();
        ID batchprocessid = Database.executeBatch(deleteCS);
    }

    public void finish(Database.BatchableContext bc){
        
        try {
            if(runOnce() && !Test.isRunningTest())
                Database.executeBatch(new UtilizationDetail_DeleteBatch(),100);
        } catch (Exception e) {
            // Report errors here
            System.debug('Start method signalled that no need to chain another batch another batch job ');
            System.abortJob(bc.getJobId());
        }

        finishEmail(bc);
    }

    public static Messaging.SingleEmailMessage finishEmail(Database.BatchableContext bc){
        messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
        AsyncApexJob a = [SELECT Id,
                                 Status,
                                 NumberOfErrors,
                                 JobItemsProcessed,
                                 TotalJobItems,
                                 CompletedDate,
                                 ExtendedStatus,
                                 ApexClass.name,
                                 CreatedBy.Email,
                                 CreatedBy.Name
                          FROM AsyncApexJob 
                          WHERE Id =:bc.getJobId()];
        mail.setToAddresses(new string[]{a.CreatedBy.Email});
        mail.setReplyTo('yourEmail@someDomain.com');
        mail.setSubject('Batch Code Complete -- '+a.ApexClass.name);
        mail.setUseSignature(false);

        string td1='"border:1px solid green; width=200px;"';
        string td2='"width=200px; border:1px solid green; background-color:red; color:white; font-weight:bold;"';
        string tdHead='"border:1px solid green; width=200px; color:white; background-color:green; font-weight:bold;"';
        string ExtendedStatus='';
        if(a.ExtendedStatus!=null)
            ExtendedStatus=a.ExtendedStatus;
        string tdErrors=td1;
        if(a.NumberOfErrors>0)
            tdErrors=td2;
        string htmlBody = '<div style="border:2px solid green; border-radius:15px;"><p>Hi,</p><p><span style="color:brown; font-weight:bolder;">Salesforce</span> completed running <b>Apex Batch Code<>/b>.</p>'
        +'<p>Results:</p>'
        +'<center><table style="border:3px solid green; border-collapse:collapse;">'
        +'<tr><td style='+tdHead+'>Class Name</td><td style='+tdHead+'>'+a.ApexClass.name+'</td></tr>'
        +'<tr><td style='+td1+'>Completed Date</td><td style='+td1+'>'+a.CompletedDate+'</td></tr>'
        +'<tr><td style='+td1+'>Status</td><td style='+td1+'>'+a.Status+'</td></tr>'
        +'<tr><td style='+td1+'>Job Items Processed</td><td style='+td1+'>'+a.JobItemsProcessed+' / '+a.TotalJobItems+'</td></tr>'
        +'<tr><td style='+td1+'>NumberOfErrors</td><td style='+tdErrors+'>'+a.NumberOfErrors+'</td></tr>'
        +'<tr><td style='+td1+'>Extended Status</td><td style='+td1+'>'+ExtendedStatus+'</td></tr>'
        +'<tr><td style='+tdHead+'>Created By</td><td style='+tdHead+'>'+a.CreatedBy.Name+' ('+a.CreatedBy.Email+')</td></tr>'
        +'</table></center>'
        +'<p>Enjoy the <b>results</b>!</p><p><span style="font-family:"Courier New", Courier, monospace; color:green; font-weight:bold; font-size:larger;">Scott</span></p></div>';

        mail.setHtmlBody(htmlBody);
        return mail; 
    }
}