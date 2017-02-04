public with sharing class SOW_Summary_Project_Controller{
   
    public pse__Proj__c proj{get;set;}
    public String projId{get;set;}
    public Decimal Calculate1{get; set;}  
    public String message{get;set;}
    public List<pse__Proj__c> projects{get; set;}
    
    private ApexPages.StandardController sc;
    
    public SOW_Summary_Project_Controller(ApexPages.StandardController controller){
        this.sc = controller;
        message = '';
        Calculate1= 0; 
        proj = (pse__Proj__c)controller.getRecord();
        projId = controller.getRecord().Id; 
        CalculateMarginFixedPrice();
        projects = 
        			[SELECT Id, 
        			Name,
        			SOW_Sold_Hours__c,
        			SOW_Average_Sell_Price__c,
        			SOW_Projected_Cost__c,
        			SOW_Customer_Price__c,
        			SOW_Average_Standard_Price__c	
        			FROM pse__Proj__c
        			WHERE Id =: projId];        
    }
    
     public PageReference save1() {
        proj.SOW_Sold_Hours__c = proj.SOW_Sold_Hours__c;
    	proj.SOW_Average_Sell_Price__c = proj.SOW_Average_Sell_Price__c;
    	proj.SOW_Projected_Cost__c = proj.SOW_Projected_Cost__c;
    	proj.SOW_Customer_Price__c = proj.SOW_Customer_Price__c;
    	proj.SOW_Average_Standard_Price__c = proj.SOW_Average_Standard_Price__c;
        upsert proj;
        return null;        
        //return new PageReference('/'+acc.Id);
    }
   
   	public PageReference savingCustomerRecord(){
 		List<pse__Proj__c> saveProj = new List<pse__Proj__c>();	
        for(pse__Proj__c project : projects){        	
        	proj.SOW_Sold_Hours__c = project.SOW_Sold_Hours__c;
        	proj.SOW_Average_Sell_Price__c = project.SOW_Average_Sell_Price__c;
        	proj.SOW_Projected_Cost__c = project.SOW_Projected_Cost__c;
        	proj.SOW_Customer_Price__c = project.SOW_Customer_Price__c;
        	proj.SOW_Average_Standard_Price__c = project.SOW_Customer_Price__c;
        	saveProj.add(proj);
        } 	
        		
		update saveProj;
		String next_url = ApexPages.currentPage().getParameters().get('retURL');
				
		if ( next_url != null && next_url.length() > 0 ){        
	        PageReference next_page = new PageReference(next_url);
	        next_page.setRedirect(true);
	        return next_page;
	    }else{
	        return(null);
		}
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
            try{
                if((rsc.pse__Project__r.pse__Billing_Type__c == 'Time and Materials') && (getResources().size() > 0)){
                    Calculate1 += ((1-(rsc.Projected_Cost__c/(rsc.Sell_Price__c* rsc.pse__SOW_Hours__c)))*100)/getResources().size();
                }
                else if((rsc.pse__Project__r.pse__Billing_Type__c == 'Fixed Price') && (getResources().size() > 0)){
                    Calculate1 += ((1-( rsc.Projected_Cost__c/ rsc.Fixed_Price_Total__c))*100)/getResources().size();
                }
            }
            catch(exception e){
                System.debug('Divide by 0, '+e);
            }
        }
        return Calculate1;
    }
}