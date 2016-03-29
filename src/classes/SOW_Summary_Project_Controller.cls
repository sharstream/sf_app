public with sharing class SOW_Summary_Project_Controller {
    
    Project project(){get; set;}
    
    public SOW_Summary_Project_Controller(){}

	List<pse__Resource_Request__c> resources = [SELECT id, 
														pse__Billing_Type__c,
														SOW_Sold_Hours__c,
														SOW_Projected_Cost__c,
														SOW_Average_Standard_Price__c,
														SOW_Average_Sell_Price__c,
														SOW_Customer_Price__c,
														projected_Cost__c,
														fixed_price_total__c
																											
														FROM pse__Resource_Request__c 
														WHERE pse__Project__c = :project.Id
											          	ORDER BY Project_Product_Name__c,	pse__Resource_Role__c];
  	public Float CalculateMarginFixedPrice(){
  		float result = 0;
  		for(pse__Resource_Request__c rsc : resources){
	  		if(rsc.pse__Billing_Type__c == 'Time and Materials'){
	  			result += 1-(rsc.projected_Cost__c / (rsc.SOW_Average_Sell_Price__c * rsc.pse__SOW_Hours__c)) * 100;
	  		}
	  		else if(rsc.pse__Billing_Type__c == 'Fixed Price'){
	  			result += 1-(rsc.projected_Cost__c / rsc.fixed_price_total__c) *100;
	  		}
  		}
  		return result;
  	}
}