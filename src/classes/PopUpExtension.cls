public with sharing class PopUpExtension {

    public Opportunity opportunity{get; set;}
    
    public PopUpExtension(){}
    
    public List<WrappDiffOpp> lstWrapperOpp{
    	get;set;
  	}
    
    List<Support_Order__c> SupportOpps = [select Id, Name, Opportunity__r.Name, Opportunity__c, Opportunity__r.AccountId from support_order__c LIMIT 1];
  	List<WrappDiffOpp> differents = new List<WrappDiffOpp>(); 
  	
    
	public void showOpportunities(){
		try{
			if(IsNotRepeat()){
				for(WrappDiffOpp o : differents){
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Different Opportunities with an Order Support: '+o.oppName+'.');
	            	ApexPages.addMessage(myMsg);
				}
				List<ApexPages.Message> messages = ApexPages.getMessages();
				System.debug(messages);
			}
		}	
		catch(exception e){
		  	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error Occured while showing a list of opportunities '+e.getMessage());
            ApexPages.addMessage(myMsg);
		}
	}
  	
  	public Boolean IsNotRepeat(){
  		
  		if(SupportOpps.size() == 0){
  			return false;
  		}
  		
  		for(Support_Order__c obj : SupportOpps){		
			WrappDiffOpp o = new WrappDiffOpp(obj.Name, false, obj);
			Integer i = 0;
			while(i <= SupportOpps.size()){
				if(obj.Opportunity__r.Name == SupportOpps[i+1].Opportunity__r.Name){
					i++;
					continue;		
				}
	 			else{
					o.oppName = obj.Opportunity__r.Name;
					o.notrepeat = true;
					break;	
				}	
			}
			differents.add(o); 					
  		}
  		
  		if(differents.size() >= 1)
			return true;
		return false;
  	} 
  	
  	public class WrappDiffOpp{
  		String oppName{get; set;}
  		Boolean notrepeat = false;
  		Support_Order__c support = new Support_Order__c();
  		public WrappDiffOpp(String poppName, Boolean pnotrepeat, Support_Order__c psupport){
  		 	this.oppName = poppName;
  		 	this.notrepeat = pnotrepeat;
  		 	this.support = psupport;
  		}
  	}
  	
  	public static final Integer MAX_ARRAY_VALUE = 1000;
  	public Boolean isFull(){ return MAX_ARRAY_VALUE == differents.size(); }
  	
  	public class OpportunityListOverflowException extends Exception {}
  	public class NullValueNotAllowedException extends Exception {}
}