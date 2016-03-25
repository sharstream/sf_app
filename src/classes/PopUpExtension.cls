/***********************************************
* Copyright (c) 2016, ABB Enterprise Software Inc.
* All rights reserved.
* Author        :   David Perez(kitsunebrave)
* Related Task  :   Ticket-00382254
* Purpose       :   PopUp Extension Apex Class
************************************************/
public with sharing class PopUpExtension {

    public Opportunity opportunity{get; set;}
    
    public PopUpExtension(){}
    
    public List<WrappDiffOpp> lstWrapperOpp{
    	get;set;
  	}
    
    public PopUpExtension(ApexPages.StandardController controller){
        this.opportunity = (Opportunity)controller.getRecord();
    }
    
    List<Support_Order__c> SupportOpps = [select Id, Name, Opportunity__r.Name from support_order__c];
  	List<WrappDiffOpp> differents = new List<WrappDiffOpp>(); 
  	
    
	public void showOpportunities(){
		try{
			if(IsNotRepeat()){
				for(WrappDiffOpp o : differents){
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Different Opportunities with an Order Support: '+o.oppName+'.');
	            	ApexPages.addMessage(myMsg);
				}
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
			WrappDiffOpp o = new WrappDiffOpp(obj.Name, false);
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
  		
  		public WrappDiffOpp(String poppName, Boolean pnotrepeat){
  		 	this.oppName = poppName;
  		 	this.notrepeat = pnotrepeat;
  		}
  	}
}