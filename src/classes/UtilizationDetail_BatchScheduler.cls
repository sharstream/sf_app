global class UtilizationDetail_BatchScheduler implements Schedulable {
    global void execute(SchedulableContext info) {
    	if (!Test.isRunningTest()) {
    		UtilizationDetail_DeleteBatch b = new UtilizationDetail_DeleteBatch(); 
      		database.executeBatch(b, 100);
    	}
    }
}