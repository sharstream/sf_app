public with sharing class SOW_Summary_Project_Controller{
   
    public pse__Proj__c proj{get;set;}
    public String projId{get;set;}
    public Decimal Calculate1{get; set;}  
    public SOW_Summary_Project_Controller(ApexPages.StandardController controller){
        Calculate1= 0; 
        projId = controller.getRecord().Id; 
        CalculateMarginFixedPrice();
    }
    public List<pse__Resource_Request__c> getResources(){
    return [SELECT id, 
                    pse__Project__r.pse__Billing_Type__c,
                    pse__Project__r.SOW_Sold_Hours__c,           
                    pse__Project__r.SOW_Projected_Cost__c,
                    pse__Project__r.SOW_Average_Standard_Price__c,
                    pse__Project__r.SOW_Average_Sell_Price__c,
                    pse__Project__r.SOW_Customer_Price__c,
                    CurrencyIsoCode,
                    Sell_Price__c,
                    Projected_Cost__c,
                    pse__SOW_Hours__c,
                    Fixed_Price_Total__c                                                                        
                    FROM pse__Resource_Request__c 
                    WHERE pse__Project__c =: projId];
    }  
    public Decimal CalculateMarginFixedPrice(){
        for(pse__Resource_Request__c rsc : getResources()){
            if(rsc.pse__Project__r.pse__Billing_Type__c == 'Time and Materials'){
                Calculate1 += ((1-(rsc.Projected_Cost__c/(rsc.Sell_Price__c * rsc.pse__SOW_Hours__c)))*100)/getResources().size();
            }
            else if(rsc.pse__Project__r.pse__Billing_Type__c == 'Fixed Price'){
                Calculate1 += ((1-( rsc.Projected_Cost__c/ rsc.Fixed_Price_Total__c))*100)/getResources().size();
            }
        }
        return Calculate1;
    }
}