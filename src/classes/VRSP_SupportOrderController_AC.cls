/*******************************************************************
Author        :   Appirio Offshore(Sunil Gupta)
Date          :   Feb 16, 2013
Related Task  :   T-118188
Purpose       :   Controller class for VRSP_SupportOrderController_AC

//Modifications  
Amit K A : 04 April,2013 T-128566
Amit K A : 24 April 2013 modified as per I-50943
Jitendra K : 29 April 2013 modified as per T-136554
Jitendra K : 3 May 2013 modified as per T-135635
Sam : 8/9/2013 per SFDC Request 3976
eightCloud : 14 Feb 2015 to accomodate Pricing Model Changes
*******************************************************************/
public without sharing class VRSP_SupportOrderController_AC {
  public final string CONSOLIDATED = 'Consolidated';
  public final string TERMINATED = 'Cancelled/Terminated';
  public static final String SUBSTATUS_INVOICED  = 'Invoiced';
  
  public Support_Order__c sourceSO{
    get;set;
  }
  
  public List<SuppportOrderWrapper> lstSuppportOrderWrapper{
    get;set;
  }
  
  public VRSP_SupportOrderController_AC (ApexPages.StandardController 
      stdController){
    sourceSO = (Support_Order__c)stdController.getRecord();
    sourceSO = 
          [SELECT s.Id,
                s.Contract__c, 
                s.Current_Term_Start_Date__c, 
                s.Current_Term_End_Date__c, 
                //s.Multi_Year_Agreement__c, //Commented out for SFDC Request 3976 
                s.Name,
                s.Status__c 
          FROM Support_Order__c s 
          WHERE s.Id = :sourceSO.Id];     
    loadSupportOrders();    
  }
  
  private void loadSupportOrders(){
    lstSuppportOrderWrapper = new List<SuppportOrderWrapper>();
    list<Support_Order__c> lstSO = new list<Support_Order__c>();
       for(Support_Order__c so : [SELECT  Id,
                                         Support_Order_Type__c,
                                         Name, 
                                         Status__c, 
                                         Current_Term_Start_Date__c, 
                                         Current_Term_End_Date__c, 
                                         Contract__r.ContractNumber, 
                                         Contract__c, 
                                         Contract_Date__c, 
                                         Annual_Support_Fees__c, 
                                         Agreement_End_Date__c, 
                                         Contract__r.Account.Name,
                                         Opportunity__r.Name,
                                         Opportunity__r.Pricebook2.Name,
                                         Opportunity__r.Pricebook2.id
                                  FROM Support_Order__c 
                                  WHERE Contract__c = :sourceSO.Contract__c 
                                        AND Current_Term_End_Date__c =: sourceSO.Current_Term_End_Date__c
                                        //AND Multi_Year_Agreement__c = false //Commented out for SFDC Request 3976 
                                        AND Do_Not_Consolidate__c = false]){      
        //Dave started here!!
        if(so != NULL)
        	lstSO.add(so);
    	else
    		System.debug('Object is Empty');
      }	//Dave finished here!!
    //}                                          
    for(Support_Order__c so :lstSO){
      SuppportOrderWrapper objWrapper = new SuppportOrderWrapper();
      objWrapper.isChecked = false;
      objWrapper.isSurvivorSupportOrder = false;
      objWrapper.supportOrderName = so.Name;
      objWrapper.supportOrderId = so.Id;
      objWrapper.objSO = so;
      objWrapper.PriceBookId= so.Opportunity__r.Pricebook2.Id;
      objWrapper.PriceBookName= so.Opportunity__r.Pricebook2.Name;
      lstSuppportOrderWrapper.add(objWrapper);  
    }
  }
  	
  public PageReference save(){
    String survivingSOId = ApexPages.currentPage().getParameters().get('radioName');
    System.debug('>>>>>>survivingSOId'+survivingSOId);
    if(survivingSOId != null && survivingSOId.length() > 0){
      Boolean isSuccess = saveFunctionality(survivingSOId);
      if(isSuccess){
        PageReference pageRef = new PageReference('/' +survivingSOId);
        pageRef.setRedirect(true);
        return pageRef;
      }
    }
    return null;
  }
  
  public PageReference cancel(){
    PageReference pageRef = new PageReference('/' +sourceSO.id);
    pageRef.setRedirect(true);
    return pageRef;
  }
  
  private Boolean saveFunctionality(String survivingSOId){
    Support_Order__c survivingSupportOrder; 
    String survivingPriceBookId='';
    String oppID = '';
    Map<Id,Support_Order__c> mapSelectedSO = new Map<Id,Support_Order__c>();
    System.debug('>>>>>>lstSuppportOrderWrapper'+lstSuppportOrderWrapper);
    
    for(SuppportOrderWrapper soWrapper :lstSuppportOrderWrapper){
      if(soWrapper.isChecked == true && soWrapper.objSO.Id != survivingSOId){
        mapSelectedSO.put(soWrapper.objSO.Id, soWrapper.objSO);
      }
      
      /* Commented By Sunil: March 05, 2013
      It is not mendatory that checkbox before Surviving SO is checked. 
      else if(soWrapper.isChecked && soWrapper.objSO.Id == survivingSOId) {
        survivingSupportOrder = soWrapper.objSO;
      }
      */
      else if(soWrapper.objSO.Id == survivingSOId) {
        survivingSupportOrder = soWrapper.objSO;
        survivingPriceBookId=soWrapper.PricebookId;
      }
    }
    
    //Ventyx Support Order Consolidation (Case 5150)
    for(SuppportOrderWrapper soWrapper :lstSuppportOrderWrapper){
      if(soWrapper.isChecked == true && soWrapper.objSO.Id != survivingSOId){
        if(survivingPriceBookId!=soWrapper.PriceBookId)
        {
             Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'All the selected Support Orders should be from same Price Book..!'));
             return false;
             break;
        }           
      }
    }
    
    
    if(mapSelectedSO.isEmpty()){
      Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO,
          'No records found for merging'));
      return false;
    }
    
    system.debug('@@@@@surving'+survivingSOId);
    
    //Get all supported products associated with selected supported orders.
    List<Supported_Product__c> lstSP_Old = 
        [SELECT s.Type__c, s.Third_Party_Support_Cost__c,
                s.SystemModstamp, s.Support_Order__r.Id, s.Support_Order__c,
                s.Product__c, s.Override_Escalation_P__c, s.Ordered_Product__c, 
                s.Net_Annual_Support_Fee__c, s.Name, 
                s.License_Fee_del__c, s.LastModifiedDate, s.LastModifiedById, 
                s.LastActivityDate, s.IsDeleted, s.Id, 
                s.Gross_Annual_Support_Fee__c, s.CurrencyIsoCode, s.CreatedDate, 
                s.CreatedById, s.Alert__c
                FROM Supported_Product__c s 
                WHERE s.Support_Order__c in :mapSelectedSO.keySet()];
                
    list<Supported_Product__c> lstSurvivor = new list<Supported_Product__c>([select Support_Order__c, Support_Order__r.opportunity__c from Supported_Product__c 
                                                                                    where Support_Order__c =: survivingSOId limit 1]);
    system.debug('$$$$$$$$$$$'+lstSurvivor);
    
    Set<Id> oppIdSet = new Set<Id>();
    for(Support_Order__c so :mapSelectedSO.values()){
      oppIdSet.add(so.Opportunity__c);
    }
    
    if(lstSurvivor != null && lstSurvivor.size()>0){
        oppIdSet.add(lstSurvivor[0].Support_Order__r.opportunity__c);
        system.debug('==================OppID22'+oppIdSet);
    }
    
    Savepoint savePointMain;
    try{
      savePointMain = Database.setSavepoint();
      cloneSupportedProducts(lstSP_Old, mapSelectedSO, survivingSupportOrder);      
      cloneLicenceOrderes(mapSelectedSO, survivingSOID);
      cloneOpportunityProducts(oppIdSet, survivingSOId);
      updateOpportunityStatus(oppIdSet);
      updateSPStatus(lstSP_Old);
      updateSurvivingSO(survivingSupportOrder);
      updateSOStatus(mapSelectedSO, survivingSOId);
    }
    catch(Exception ex){
      System.debug('>>>>>>saveFunctionality Exception'+ex.getMessage());
      Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO,
          ex.getMessage()));
      Database.rollback(savePointMain);
      return false;
    }
    return true;
  }
  
  private void cloneSupportedProducts(List<Supported_Product__c> lstSP_Old, 
      Map<Id, Support_Order__c> mapSelectedSO, Support_Order__c survivingSupportOrder){
    Map<Id, Support_Order__c> mapOldSO = new Map<Id, Support_Order__c>();
    for(Id soId : mapSelectedSO.keySet()){              
     mapOldSO.put(soId, survivingSupportOrder);
    }
    UtilityClass.cloneSupportedProductsAndRelatedForConsolidation(lstSP_Old, mapOldSO);
  }
  /* This method is used for clone licence orders and insert entry in junction 
      object associating by surviving supported order. */
  private void cloneLicenceOrderes(
      Map<Id,Support_Order__c> mapSelectedSO, String survivingSOId){
    
    List<License_Support_Junction__c> lsNewJunction = 
        new List<License_Support_Junction__c>();
    
    for(License_Support_Junction__c  loJunction: 
        [SELECT Support_Order__c, License_Order__c 
          FROM License_Support_Junction__c 
          WHERE Support_Order__c IN :mapSelectedSO.keySet()]) {
      License_Support_Junction__c loJunctionNew = 
          new License_Support_Junction__c();
      loJunctionNew.Support_Order__c = survivingSOId;
      loJunctionNew.License_Order__c = loJunction.License_Order__c;
      lsNewJunction.add(loJunctionNew);
    }
    insert lsNewJunction;
  }
  
  
  
  /* This method used for clone opportunitiues product from selected supported
      orders and insert into opporutnity associated with surviving SO */
  private void cloneOpportunityProducts(Set<Id> oppIdSet,String survivingSOId){
    System.debug('>>>>>>cloneOpportunityProducts'+oppIdSet);
    Id survivingOppId;
    List<Support_Order__c> soList = 
        [SELECT Opportunity__c 
          FROM Support_Order__c 
          WHERE Id = :survivingSOId];
    
    if(soList.size() > 0){
      survivingOppId = soList.get(0).Opportunity__c;
    }
    
    List<OpportunityLineItem> lstOppProducts = 
        [SELECT o.UnitPrice,o.Term__c, 
          o.SystemModstamp,
          o.Start_Date__c, o.Standard_Price__c, o.SortOrder, o.ServiceDate,
          o.Revenue_Stream__c,o.Revenue_Stream_Type__c, o.Revenue_Period__c,
          o.Quantity, o.Project_Number__c, o.Product_ID__c,
          o.PricebookEntryId, o.Price_Indexation__c, o.PAL_Link__c,
          o.Option_To_Renew__c, o.OpportunityId,o.Old_Product__c,
          o.Old_Product_Id__c, o.Old_Line_Item_Id__c, o.Net_Price__c,
          o.ListPrice,o.Line_Item_Id_18__c, o.License_Type__c, 
          o.LastModifiedDate, o.LastModifiedById, o.IsDeleted,
          o.IntegrationID__c, o.Id, o.HasSchedule, o.HasRevenueSchedule, 
          o.HasQuantitySchedule, o.End_Date__c, o.Description,
          o.CurrencyIsoCode, o.CreatedDate, o.CreatedById, o.Cost__c, 
          o.Contract_Type__c, o.Business_Type__c,
          o.Annual_Recurring_Revenue__c 
          FROM OpportunityLineItem o  
          WHERE OpportunityId in :oppIdSet];
    
    List<OpportunityLineItem> lstOppProducts_New = 
        lstOppProducts.deepClone(false,false,false);
    
    for(OpportunityLineItem oppProduct :lstOppProducts_New){
      oppProduct.OpportunityId = survivingOppId;
    }
    
    insert lstOppProducts_New;
  }
  
   /* This method is used for update status of opportunities associated with 
  selected support orders to 'Not Persued'.*/
  private void updateOpportunityStatus(Set<Id> oppIdSet){
      system.debug('===================oppId Set'+oppIdSet);
    List<Opportunity> oppList = 
        [SELECT o.Status__c,StageName, o.Id, o.Win_Loss_Not_Pursued_Reason_Category__c 
          FROM Opportunity o 
          WHERE o.Id in :oppIdSet];
    
    for(Opportunity opp :oppList){
      //opp.StageName = 'Not Pursued';
      //opp.Win_Loss_Not_Pursued_Reason_Category__c = 'Duplicate Opportunity';
      //opp.Winner__c = 'None';
      opp.To_be_Consolidated__c=true;
    }
    update oppList;
  }
  
  
  
  /* This method is used for update status of opportunities associated with 
  selected supported Products to 'Not Persued'.*/
  private void updateSPStatus(List<Supported_Product__c> lstSP_Old){
    for(Supported_Product__c sp :lstSP_Old){
      sp.Product_Status__c = TERMINATED;
    }
    update lstSP_Old;
  }
 
 
  /* This method is used for update status of all selected supported order
      to 'Expired'.*/ 
  private void updateSOStatus(Map<Id,Support_Order__c> mapSelectedSO,
        String survivingSOId){
    List<Support_Order__c> lstSO = mapSelectedSO.values();
    for(Support_Order__c so :lstSO){
      so.Status__c = 'Closed';
      so.Sub_Status__c = CONSOLIDATED;
      so.Consolidated_Support_Order__c = survivingSOId;
    }
    update lstSO;
  }

  /*
   * Update the surviving Support Order's record type. 

   */
  private void updateSurvivingSO(Support_Order__c survivingSupportOrder) {
    RecordType consolidatedRT = getRecordType('Support_Order__c', 
        'Consolidated_Support_Order');
    System.debug('>>>>survivingSupportOrder'+survivingSupportOrder);
    System.debug('>>>>consolidatedRT.Id'+consolidatedRT.Id);    
    if(consolidatedRT != null) {
      survivingSupportOrder.RecordTypeId = consolidatedRT.Id;  
      survivingSupportOrder.Consolidated_Order__c = true;
      System.debug('>>>>survivingSupportOrder'+survivingSupportOrder);
      update survivingSupportOrder;
    }
  }
  /* get the record type by Dev Name:
   * Param objectType: Name of the object for which the record type is to be 
            fetched 
   * Param recordTypeDevName: Dev Name of the Record Type. 
   * Return: RecordType
   */
  private RecordType getRecordType (String objectType, 
      String recordTypeDevName) {
    List <RecordType> recordTypes = [select Id, Name, DeveloperName
                                      from RecordType 
                                      where SobjectType =: objectType
                                        and DeveloperName =: recordTypeDevName
                                      limit 1];
    if(recordTypes.size() > 0) {
      return recordTypes[0];
    } else {
      return null;
    }
  }
  
  /* Below is wrapper class used for bind data on VF page.*/ 
  public class SuppportOrderWrapper {
    public Support_Order__c objSO{get;set;}
    public Boolean isChecked{get;set;}
    public Boolean isSurvivorSupportOrder{get;set;}
    public String supportOrderName{get;set;}
    public String supportOrderId{get;set;}
    public String PricebookId{get;set;}
    public String PricebookName{get;set;}
    public SuppportOrderWrapper() {
    }
  }   
}