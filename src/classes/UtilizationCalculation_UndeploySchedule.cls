global class UtilizationCalculation_UndeploySchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        UtilizationCalculation_UndeployBatch batch = new UtilizationCalculation_UndeployBatch();
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(20);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        system.debug(chron_exp);
        //Schedule the next job, and give it the system time so name is unique
        System.scheduleBatch(batch,'Utilization Calculation Details Batch '+ sysTime.getTime(), Integer.valueOf(chron_exp));
        if(Test.isRunningTest())
        	database.executeBatch(batch,500); 
    }
}