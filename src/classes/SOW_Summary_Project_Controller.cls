public with sharing class SOW_Summary_Project_Controller {
    
    //Project project(){get; set;}
    
    public SOW_Summary_Project_Controller(){}

	List<pse__Resource_Request__c> resources = [SELECT id, 
														pse__Project__r.pse__Billing_Type__c,
								
														pse__Project__r.SOW_Sold_Hours__c,
														pse__Project__r.SOW_Projected_Cost__c,
														pse__Project__r.SOW_Average_Standard_Price__c,
														pse__Project__r.SOW_Average_Sell_Price__c,
														pse__Project__r.SOW_Customer_Price__c,
														Projected_Cost__c,
														Fixed_Price_Total__c
																											
														FROM pse__Resource_Request__c 
														WHERE pse__Project__c = :'a5s600000004CMC'];
  	public Decimal CalculateMarginFixedPrice(){
  		Decimal result = 0;
  		for(pse__Resource_Request__c rsc : resources){
	  		if(rsc.pse__Project__r.pse__Billing_Type__c == 'Time and Materials'){
	  			result += 1-(rsc.Projected_Cost__c / (rsc.Sell_Price__c * rsc.pse__SOW_Hours__c)) * 100;
	  		}
	  		else if(rsc.pse__Project__r.pse__Billing_Type__c == 'Fixed Price'){
	  			result += 1-(rsc.Projected_Cost__c / rsc.Fixed_Price_Total__c) *100;
	  		}
  		}
  		return result;
  	}
}