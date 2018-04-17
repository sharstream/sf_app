/*****************************************************************************
Name:           Opp_CloneManual_ContactRoleAndPartnewr
Author:         David Perez
Created Date:   
Description:    This class acts as a centralized place for Oppty Manual Cloning

David Perez    : modified on 04/27/2017 per 546096-fix brought over perpetual license line items.  Only the maintenance should have cloned  
David Perez    : modified on 12/22/2017 per 687613-defect sync the Oppty StageName with the Probability
David Perez    : modified on 01/23/2018 per 703819-defect Oppty Owner for Renewal Users 
David Perez    : modified on 01/29/2018 per 619873-defect Parent Oppty and Amount
David Perez    : modified on 01/18/2017 per 702788 include the customer price and unitprice - discount?
David Perez    : modified on 02/08/2018 per 705679 clone all opportunity products on the new Oppty
*****************************************************************************/
public without sharing class Opp_CloneManual_ContactRoleAndPartner {
    
    public Opportunity oldOpp{get; set;}
    public Opportunity newOpp{get; set;}
    public Boolean settingsReady(){
        return newOpp.PriceBook2Id == null;
    }
    public List<OpportunityLineItem> lstNewPro{get; set;}
    public List<OpportunityContactRole> newLstOCR{get; set;}
    public List<Partner> newLstOPT{get; set;}
 
    // The user changed the Opportunity StageName. Set the Probability to the
    // correct value, based on the defaults set up in the OpportunityStage object.
    // Case 687613-defect 
    public transient Map<String, Decimal> probabilityStageNameMap;
    static ID ventyxUSD = [Select Id from User where name = 'ABB' LIMIT 1].Id;

    public Opp_CloneManual_ContactRoleAndPartner( ApexPages.StandardController stdController ) {
        
        oldOpp = new Opportunity();
        newOpp = oldOpp.clone(false, true, false, false);
        lstNewPro = new List<OpportunityLineItem>();
        newLstOCR = new List<OpportunityContactRole>();
        newLstOPT = new List<Partner>(); 
        oldOpp = 
            [SELECT Id, CampaignId, PriceBook2Id, Name, OwnerId,
                    Owner.IsActive, Owner.UserRoleId, BidType__c, Industry__c, Type, FES_Region__c, 
                    Territory__c, Opportunity_Country__c, AccountId, CloseDate, CurrencyIsoCode,
                    BU_Code__c, RecordTypeId, Account.Name, RecordType.Name,
                    Renewal_PO_Notice__c, Renewal_Quote_Notice__c, Collections_Notes__c, Total_List_Price__c, Customer_Price__c,
                    Overall_Discount__c, Total_Discount__c, StageName, Area__c, Probability, End_User__c
            FROM Opportunity 
            WHERE Id =: ApexPages.currentPage().getParameters().get('id')];

        newOpp.type = 'Renewal';
        newOpp.DM_Type__c = 'Renewal Process';
        newOpp.BidType__c = '';
        newOpp.End_User__c = oldOpp.End_User__c;
        newOpp.Territory__c = oldOpp.Territory__c;
        newOpp.FES_Region__c = oldOpp.FES_Region__c;
        newOpp.Area__c = oldOpp.Area__c;
        if(oldOpp.PriceBook2Id == null)
            newOpp.PriceBook2.Name = '2015 Price Sheet'; 
        else
            newOpp.PriceBook2Id = oldOpp.PriceBook2Id;
        newOpp.Industry__c = oldOpp.Industry__c; 
        newOpp.Opportunity_Country__c = oldOpp.Opportunity_Country__c;
        newOpp.AccountId  = oldOpp.AccountId;
        newOpp.CloseDate = oldOpp.CloseDate;
        newOpp.CurrencyIsoCode = oldOpp.CurrencyIsoCode;
        newOpp.Name = oldOpp.Name; 
        system.debug('Year is: **** ' + string.valueOf(newOpp.CloseDate.year()));
        newOpp.BU_Code__c = oldOpp.BU_Code__c;
        newOpp.StageName = oldOpp.StageName;
        if (newOpp.StageName == 'Selected Vendor') {
            newOpp.Probability = 90;
        }

        if (newOpp.StageName == 'Contract Signing') {
            newOpp.Probability = 95;
        }

        if (newOpp.StageName == 'Prospect') {
            newOpp.Probability = 10;
        }
        if (newOpp.StageName == 'Qualified') {
            newOpp.Probability = 25;
        }

        if (newOpp.StageName == 'Discovery') {
            newOpp.Probability = 40;
        }

        if (newOpp.StageName == 'Short Listed') {
            newOpp.Probability = 60;
        }
        if (newOpp.StageName == 'Closed') {
            newOpp.Probability = 99;
        }

        if (newOpp.StageName == 'Won') {
            newOpp.Probability = 100;
        }

        if (newOpp.StageName == 'Not Pursued') {
            newOpp.Probability = 0;
        }

        if (newOpp.StageName == 'Lost') {
            newOpp.Probability = 0;
        }

        if (newOpp.StageName == 'Cancellation') {
            newOpp.Probability = 100;
        }
        System.debug('Probabiity %%%%%%%%%% '+newOpp.Probability);
        newOpp.Forecast_Call__c = 'Upside';
        if (oldOpp.Owner.IsActive == true){
            newOpp.OwnerId = oldOpp.OwnerId;
        }

        else if(oldOpp.Owner.IsActive==true && oldOpp.BU_Code__c=='2872 - Network Control'){
           newOpp.OwnerId = oldOpp.OwnerId;
        }
        else{
           newOpp.OwnerId = ventyxUSD;
        }
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@2'+newOpp.OwnerId);
        newOpp.IsAlreadyCloned__c = true;

        settingsReady();
    }

    // Case 687613-defect
    public PageReference changeStageName() {

        if (probabilityStageNameMap == null) {
            probabilityStageNameMap = new Map<String, Decimal>();
            for (OpportunityStage oppStage : [Select MasterLabel, DefaultProbability
                                                From OpportunityStage WHERE IsActive != False]) {
                probabilityStageNameMap.put(oppStage.MasterLabel, oppStage.DefaultProbability);
            }
        }
        System.debug('probabilityStageNameMap keys %%%%%%%%%%%%%'+probabilityStageNameMap.keySet());
        System.debug('probabilityStageNameMap values %%%%%%%%%%%%%'+probabilityStageNameMap.values());
        System.debug('probabilityStageName %%%%%%%%%%%%%'+newOpp.StageName);

        if (probabilityStageNameMap.containsKey(newOpp.StageName)) {
            newOpp.Probability = probabilityStageNameMap.get(newOpp.StageName);
        }
        System.debug('newOpp.Probability %%%%%%%%%%%%'+newOpp.Probability);

        return null;
    }
    
    public PageReference redirect(){//Add Product, Contact Role and Partner without go to the Product List
        system.debug('oppty recordtype id: '+oldOpp.RecordTypeId);
        system.debug('oppty recordtype name: '+oldOpp.RecordType);
        if(oldOpp.StageName == 'Cancellation'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This is a cancellation opportunity. You are not allow to clone this opportunity. Please change the Opportunity Record Type'));
            return null;
        }
        else{
            saveOpp1();
            System.debug('PAGE REFERENCE: '+ new PageReference('/'+newOpp.Id));
            try{
                if(newOpp.Id != null)
                    return new PageReference('/'+newOpp.Id);  
            }
            catch(Exception ex){        
                ApexPages.addMessages(ex);
            }
        } 
        return null;   
    }
    
    public void saveOpp1(){
        try{
            saveOpp();
            if(lstNewPro != null && newLstOCR != null && newLstOPT != null){
                insert lstNewPro;
                insert newLstOCR;
                insert newLstOPT;            
            }    
        }
        catch(Exception ex){
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error message.');
            ApexPages.addMessages(ex);
        }        
    }
    
    public void saveOpp(){ //2. redirect New Opportunity with Product

        //Clone Related List
        List<OpportunityContactRole> lstOCR = 
            [SELECT o.SystemModstamp, o.Role, o.OpportunityId,  
                    o.LastModifiedDate, o.LastModifiedById, o.IsPrimary, 
                    o.IsDeleted, o.Id, o.CreatedDate, o.CreatedById, o.ContactId 
            FROM OpportunityContactRole o 
            WHERE o.OpportunityId = :oldOpp.Id];
            if(newOpp != null){
                newOpp.Parent_Opportunity__c = null;
                //Defect 619873 - include the Parent Oppty and Amount = Parent Oppty Customer Price
                if (newOpp.StageName == 'Cancellation' && newOpp.RecordTypeId != '0126000000054UaAAI') {
                    newOpp.Parent_Opportunity__c = oldOpp.Id;
                }

                insert newOpp; 
            }   
                
            List<OpportunityPartner> lstOPT = 
                [SELECT IsPrimary,AccountToId,OpportunityId, Role, 
                    LastModifiedDate, LastModifiedById, IsDeleted, 
                    Id, CreatedDate, ReversePartnerId
            FROM OpportunityPartner 
            WHERE OpportunityId = :oldOpp.Id AND AccountToId <>:oldOpp.AccountId];     
        lstNewPro = new List<OpportunityLineItem>();
        newLstOCR = new List<OpportunityContactRole>();          
        List<OpportunityLineItem> products =  
            [SELECT Id, Name, Product2Id,Contract_Type__c,
                    Revenue_Stream__c, Revenue_Stream_Type__c,
                    Product2.Name, Start_Date__c,
                    End_Date__c, List_Value__c,
                    Customer_Price__c, Customer_Price_Override__c, pse__IsServicesProductLine__c,
                    Active_Prod__c, PricebookEntryId,
                    Product_Discount_Amt__c, Overall_Discount__c, Product_Price__c,
                    Quantity, UnitPrice, Discount__c, Discount, Description, OpportunityId
            FROM OpportunityLineItem 
            WHERE OpportunityId =: oldOpp.Id AND Revenue_Stream__c != 'Managed Services'];
        system.debug('product List: ' + products.size());       
        for(Integer i=0;i<products.size();i++){
            system.debug('CHECK ENTER');
            //Defect 705679 clone all opportunity products on the new Oppty
            OpportunityLineItem newItem = products.get(i).clone(false, true, false, false);
            system.debug('oppty recordtype id: '+newOpp.RecordTypeId);
            system.debug('oppty recordtype name: '+newOpp.RecordType);
            newItem.OpportunityId = newOpp.Id;   
            newItem.Revenue_Stream_Type__c = 'Renewal';  
                 
            lstNewPro.add(newItem);
        }   

        system.debug('lstOCR' + lstOCR.size());

        for (OpportunityContactRole occ : lstOCR)
        {
            OpportunityContactRole occ2 = new OpportunityContactRole();
            occ2.OpportunityId = newOpp.Id;
            occ2.Role = occ.Role;
            occ2.ContactId = occ.ContactId;
            occ2.IsPrimary = occ.IsPrimary;
            newLstOCR.add(occ2);     
        }
        for(Integer i=0;i<lstOPT.size();i++)
        {
            Partner opt2 = new Partner();
            opt2.IsPrimary = lstOPT.get(i).IsPrimary;
            opt2.AccountToId = lstOPT.get(i).AccountToId;
            opt2.OpportunityId = newOpp.Id;       
            opt2.Role = lstOPT.get(i).Role; 
            newLstOPT.add(opt2);
        }
    }
}