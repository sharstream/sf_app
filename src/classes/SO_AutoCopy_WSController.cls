public with sharing class SO_AutoCopy_WSController {//using WSDL Class to store the Copied Support Order 
    
    public Support_Order__c oldSOToCopy{get; set;}
    public String oldSO{get;set;}
    public Support_Order__c newSOCopied{get;set;}
    public Support_Order__c SupportOrderCopied{get;set;}
    public SO_AutoCopy_WSController(ApexPages.StandardController controller){
    	oldSOToCopy = new Support_Order__c();
    	newSOCopied = new Support_Order__c();
    	SupportOrderCopied = new Support_Order__c();
    	oldSO = ApexPages.currentPage().getParameters().get('id');
    	if(!Test.isRunningTest()){
             controller.addFields(new List<String>{'Contract__c'});
        }
        //CopySO();
    }
    
    public PageReference backwardSO(){return new PageReference('/'+oldSO);}
    
    public Id getContract(Contract pContract){
    	if(pContract.Id == null)
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please provide a valid Contract for this Support Order'));
            return null;	
		Contract foundContract = [Select Id, Name From Contract Where Id =: pContract.Id];
		return foundContract.Id;
    }
    
    //Support Order Copy Functionality    
    public PageReference CopySO(){
    	
    	oldSOToCopy = [SELECT 
		    	Id, Name, Agreement_End_Date__c,Auto_Renewal__c,
		    	Billing_Status__c,Cancellation_Date__c,
		    	Client_Notice_Date__c,Cloned_From__c,
		    	Consolidated_Support_Order__c,Contracted_Account_Name__c,
		    	Contract_Date__c,Current_Term_End_Date__c,
		    	Current_Term_Start_Date__c,Customer_Region__c,
		    	Default_Escalation_CAP__c,Default_Escalation_Effective_Date__c,
		    	Default_Escalation_Index__c,Default_Escalation_P__c,
		    	Do_Not_Consolidate__c,Escalation_Floor__c,
		    	Extended_Support_Date__c,Owner_Expiration_Notice__c,
		    	Payment_Terms__c,PO_Notice__c,
		    	Quote_Notice__c,Reason_for_Risk__c,
		    	RecordTypeId,Status__c,Contract__c,
		    	Opportunity__c,Support_Order_Type__c,I_Agree__c,
		    	Sub_Status__c,Support_Order_Owner__c ,
		    	Multi_Year_Agreement__c, Multi_Year_End_Date__c, Multi_Year_Start_Date__c,
		    	Terms_and_Conditions__c, Finance_Notes__c, Cancellation_Effective_Date__c,
		    	Billing_Street_Address__c, Billing_City__c, Billing_State__c, Billing_Zip_Code__c, 	Billing_Country__c,
		    	Cancellation_Policy__c,
		    	Shipping_Street_Address__c, Shipping_City__c, Shipping_State__c, Shipping_Zip_Code__c, Shipping_Country__c
		    	FROM Support_Order__c WHERE Id =: oldSO LIMIT 1];
    	
    	SupportOrderCopied.Support_Order_Owner__c = oldSOToCopy.Support_Order_Owner__c;
    	SupportOrderCopied.RecordTypeId = oldSOToCopy.RecordTypeId;
    	SupportOrderCopied.Contract__c = newSOCopied.Contract__c;
    	SupportOrderCopied.Copied_SO_From__c = oldSOToCopy.Name;
    	//SupportOrderCopied.Account_Name__c = oldSO.Account_Name__c;
    	SupportOrderCopied.Contracted_Account_Name__c = oldSOToCopy.Contracted_Account_Name__c;
    	SupportOrderCopied.Opportunity__c = oldSOToCopy.Opportunity__c;
    	SupportOrderCopied.Support_Order_Type__c = 	oldSOToCopy.Support_Order_Type__c;
    	SupportOrderCopied.Current_Term_Start_Date__c = oldSOToCopy.Current_Term_Start_Date__c;
    	SupportOrderCopied.Current_Term_End_Date__c = oldSOToCopy.Current_Term_End_Date__c;
		SupportOrderCopied.Extended_Support_Date__c = oldSOToCopy.Extended_Support_Date__c;
		SupportOrderCopied.Agreement_End_Date__c = oldSOToCopy.Agreement_End_Date__c;
		SupportOrderCopied.Client_Notice_Date__c = oldSOToCopy.Client_Notice_Date__c;
		SupportOrderCopied.Reason_for_Risk__c = oldSOToCopy.Reason_for_Risk__c;
		SupportOrderCopied.Cloned_From__c = oldSOToCopy.Cloned_From__c;
		//SupportOrderCopied.Copied_To__c = oldSO.Copied_To__c;
		SupportOrderCopied.Consolidated_Support_Order__c = oldSOToCopy.Consolidated_Support_Order__c;
		//SupportOrderCopied.Original_Support_End_Date__c = oldSO.Original_Support_End_Date__c;
		SupportOrderCopied.Do_Not_Consolidate__c = oldSOToCopy.Do_Not_Consolidate__c;
		//SupportOrderCopied.Opportunity_Owner__c = oldSO.Opportunity_Owner__c;
		SupportOrderCopied.Status__c = oldSOToCopy.Status__c;
		SupportOrderCopied.Sub_Status__c = oldSOToCopy.Sub_Status__c;
		SupportOrderCopied.Contract_Date__c = oldSOToCopy.Contract_Date__c;
		SupportOrderCopied.Auto_Renewal__c = oldSOToCopy.Auto_Renewal__c;
		SupportOrderCopied.Owner_Expiration_Notice__c = oldSOToCopy.Owner_Expiration_Notice__c; // Renewal Trigger days
		//SupportOrderCopied.Renewal_Dated__c = oldSO.Renewal_Dated__c;
		//SupportOrderCopied.Renewal_Month_Num__c = oldSO.Renewal_Month_Num__c;
		SupportOrderCopied.Cancellation_Date__c = oldSOToCopy.Cancellation_Date__c;
		SupportOrderCopied.Cancellation_Effective_Date__c = oldSOToCopy.Cancellation_Effective_Date__c;
		SupportOrderCopied.Customer_Region__c = oldSOToCopy.Customer_Region__c;
		SupportOrderCopied.Default_Escalation_Index__c = oldSOToCopy.Default_Escalation_Index__c;
		SupportOrderCopied.Default_Escalation_CAP__c = oldSOToCopy.Default_Escalation_CAP__c;
		SupportOrderCopied.Escalation_Floor__c = oldSOToCopy.Escalation_Floor__c;
		SupportOrderCopied.Default_Escalation_Effective_Date__c = oldSOToCopy.Default_Escalation_Effective_Date__c;
		SupportOrderCopied.Default_Escalation_P__c = oldSOToCopy.Default_Escalation_P__c;
		SupportOrderCopied.I_Agree__c = oldSOToCopy.I_Agree__c; // Calculate Escalation
		//SupportOrderCopied.Annual_Support_Fees__c = oldSO.Annual_Support_Fees__c;//data child object comes from the Support Order
		SupportOrderCopied.Cancellation_Policy__c = oldSOToCopy.Cancellation_Policy__c;
		SupportOrderCopied.Payment_Terms__c = oldSOToCopy.Payment_Terms__c;
		SupportOrderCopied.Billing_Status__c = oldSOToCopy.Billing_Status__c;
		SupportOrderCopied.PO_Notice__c = oldSOToCopy.PO_Notice__c;
		SupportOrderCopied.Quote_Notice__c = oldSOToCopy.Quote_Notice__c;
		SupportOrderCopied.Multi_Year_Agreement__c = oldSOToCopy.Multi_Year_Agreement__c;
		SupportOrderCopied.Multi_Year_End_Date__c = oldSOToCopy.Multi_Year_End_Date__c;
		SupportOrderCopied.Multi_Year_Start_Date__c = oldSOToCopy.Multi_Year_Start_Date__c;	
		SupportOrderCopied.Terms_and_Conditions__c = oldSOToCopy.Terms_and_Conditions__c;
		SupportOrderCopied.Finance_Notes__c = oldSOToCopy.Finance_Notes__c;
		SupportOrderCopied.Billing_Street_Address__c = oldSOToCopy.Billing_Street_Address__c;
		SupportOrderCopied.Billing_City__c = oldSOToCopy.Billing_City__c;
		SupportOrderCopied.Billing_State__c = oldSOToCopy.Billing_State__c;
		SupportOrderCopied.Billing_Zip_Code__c = oldSOToCopy.Billing_Zip_Code__c;
		SupportOrderCopied.Billing_Country__c = oldSOToCopy.Billing_Country__c;
		SupportOrderCopied.Shipping_Street_Address__c = oldSOToCopy.Shipping_Street_Address__c;
		SupportOrderCopied.Shipping_City__c = oldSOToCopy.Shipping_City__c;
		SupportOrderCopied.Shipping_State__c = oldSOToCopy.Shipping_State__c;
		SupportOrderCopied.Shipping_Zip_Code__c = oldSOToCopy.Shipping_Zip_Code__c;
		SupportOrderCopied.Shipping_Country__c = oldSOToCopy.Shipping_Country__c;

		//SupportOrderCopied.Clone_Date__c = oldSO.Clone_Date__c;
		//SupportOrderCopied = oldSOToCopy.clone();
		
		try{
			insert SupportOrderCopied;
			List<Supported_Product__c> lstSP_Old = 
                [Select s.Type__c, s.Third_Party_Support_Cost__c, 
                    s.SystemModstamp, s.Support_Order__r.Id, 
                    s.Support_Order__c,s.Product__c, s.Override_Escalation_P__c,
                    s.Ordered_Product__c, s.Net_Annual_Support_Fee__c, s.Name, 
                    s.License_Fee_del__c, s.LastModifiedDate, s.LastModifiedById,
                    s.LastActivityDate, s.IsDeleted, s.Id,s.Support_Order__r.opportunity__c,
                    s.Gross_Annual_Support_Fee__c, s.CurrencyIsoCode, s.Supported_Product_Type__c,
                    s.CreatedDate, s.CreatedById, s.Alert__c                 
                FROM Supported_Product__c s 
                WHERE s.Support_Order__c =: oldSO];
                
            Map<Id, Support_Order__c> mapOldSO = new Map<Id, Support_Order__c>();
            mapOldSO.put(oldSO, SupportOrderCopied);
            UtilityClass.cloneSupportedProductsAndRelatedForManualClone(lstSP_Old, mapOldSO);
			
			return new PageReference('/'+SupportOrderCopied.Id);
		}catch(DmlException e){
			ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, e.getdmlMessage(0) );
			ApexPages.addMessage(msg);
			return null;
		}		 	
    } 
}