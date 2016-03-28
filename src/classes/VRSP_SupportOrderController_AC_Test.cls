/*******************************************************************
Author   :   Appirio Offshore(Sunil)
Date     :   Feb 19, 2013
Purpose  :   Test coverage for VRSP_SupportOrderController_AC

//Modifications:
Amit K A : 28 Feb.,2013 remove the test failure
Jitendra K : 29 April 2013 modified as per T-136554
Sam : 9/12/2013 per 4148: Associated Sites information does not carry forward in Consolidation process.
*******************************************************************/
@isTest(seeAllData = true)
private class VRSP_SupportOrderController_AC_Test {
  
  static testMethod void myUnitTest() {
    final string consolidated = 'Consolidated';
    User u1 = TestUtility.createTsetUser(1, null, null, true).get(0);
    System.RunAs(u1){
      //Start: Prepare Test Data
      createCustomSettingData(u1, -10);
      
      SO_Auto_Cloned_Before_Date__c customSetting = SO_Auto_Cloned_Before_Date__c.getInstance();
      system.debug('CustomSetting = ' + customSetting);
      //Account
      Account a = TestUtility.createTestAccounts(1, true).get(0);
      
      //Opportunity
      Opportunity opp = TestUtility.createTestOpportunity(1,a,false)[0];
      opp.Type = 'New Client';
      opp.Industry__c = 'Distribution';
      opp.StageName = 'Won';
      insert opp;
      
      //Contract
      Contract contract = 
          TestUtility.createTestContract(1, a,'MCA', true).get(0);
      
      //Support Order
      List<Support_Order__c> soList = 
          TestUtility.createTestSupportOrder(2, opp, false);
      
      for(Support_Order__c so :soList){
        so.Status__c = 'Renewal Processing';
        so.Contract__c = contract.Id;
        so.Current_Term_Start_Date__c = System.Today();
        so.Current_Term_Start_Date__c = System.Today().addDays(100);
        //so.Multi_Year_Agreement__c = false; //modified for SFDC Request 3976 
        so.Multi_Year_Agreement__c = true; //added for SFDC Request 3976 
        so.Multi_Year_Start_Date__c = System.Today(); //added for SFDC Request 3976 
        so.Multi_Year_End_Date__c = System.Today().addDays(100); //added for SFDC Request 3976 
        //so.Do_Not_Consolidate__c = true; //added for SFDC Request 3976 
      }
      insert soList;
      
      //Standard Pricebook2
      Pricebook2 priceBook = TestUtility.getStandardPriceBook();
      System.assert(priceBook.Id != null);
      //Product2
      Product2 product2 = new Product2();
        product2.Name = 'test product';
        product2.IsActive = TRUE;
        product2.Minimum_Quantity__c = 1; 
        product2.Incremental_Quantity__c = 1;
        product2.X3rd_Party_Base__c = 0;
        product2.X3rd_Party_Per_User__c = 0;
        product2.X3rd_Party_Pct__c = 0;
        product2.ReCat_Product_Group__c = 'Install Base'; 
        product2.Maintenance_Pct__c = 0;
      insert product2;  
      //TestUtility.createTestProduct2(1,true).get(0);
      
      System.assert(product2.Id != null);
      //PriceBookEntry  
      PricebookEntry pbe = 
          TestUtility.createTestPricebookEntry(1, product2, priceBook.Id, true).get(0);
      System.assert(pbe.Id != null);
      //Opportunity Line Item
      OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PriceBookEntryId = pbe.Id;
        oppLineItem.Quantity = 1;
        oppLineItem.UnitPrice = 1.00;
        oppLineItem.Revenue_Stream__c = 'Licenses';
        oppLineItem.Revenue_Stream_Type__c = 'Renewal';
        oppLineItem.Start_Date__c = date.newinstance(2015, 1, 1);
        oppLineItem.End_Date__c = date.newinstance(2015, 12, 31);
        oppLineItem.Contract_Type__c = 'Perpetual';
      insert oppLineItem;
          //TestUtility.createTestOpportunityLineItem(1, opp, 'Licenses', pbe, true).get(0);
      //oppLineItem.Contract_Type__c = 'Perpetual';
      //update oppLineItem;
      
      System.assert(oppLineItem.Id != null); 
      //License Order
      List<License_Order__c> loList = 
          TestUtility.createTestLicenseOrder(1, contract, false);
      loList.get(0).Opportunity__c = opp.Id;
      insert loList;
      
       //License Support Junction
      List<License_Support_Junction__c> junctionList = 
      TestUtility.createTestLicenseSupportJunction(loList,soList,true);
      
      Set<Id> assoSiteIds = new Set<Id>();
      
      //added for 4148 Link Associated Sites    
      for(Support_Order__c iSO :soList){
            //Supported Product 
            List<Supported_Product__c> spList = 
            TestUtility.createTestSupportedProduct(2, iSO, product2, true); 
            
            for (Supported_Product__c spl: spList) {
                //Support Program
                ENT_2__Support_Program__c sprg = 
                TestUtility.createTestSupportProgram(1, a, contract, 'Template', false).get(0);
                sprg.Supported_Product__c = spl.Id;
                insert sprg;
                
                //Entitlement
                ENT_2__Entitlement__c ent = 
                TestUtility.createTestEntitlement(1, a, contract, sprg, false).get(0);
                ent.Supported_Product__c = spl.Id;
                insert ent;
                
                //Associated sites
                List<Associated_Sites__c> asites = 
                TestUtility.createAssoSites(2, a, spl.Id, true);
system.debug('>>>>>>AssoSites 1 ' + asites.size());                                 
                for (Associated_Sites__c asi : asites)
                {
system.debug('>>>>>>createAssoSites = Yes');                    
                    assoSiteIds.add(asi.Id);
                }
            }       
      }      
      
      //Supported Product 
      /*List<Supported_Product__c> spList = 
          TestUtility.createTestSupportedProduct(5, soList.get(0),product2, true); */
               
      //Support Program
      /*ENT_2__Support_Program__c sprg = 
          TestUtility.createTestSupportProgram(1, a, contract, 'Template', false).get(0);
      sprg.Supported_Product__c = spList.get(0).Id;
      insert sprg; */
      
      //Entitlement
      /*ENT_2__Entitlement__c ent = 
          TestUtility.createTestEntitlement(1, a, contract, sprg, false).get(0);
      ent.Supported_Product__c = spList.get(0).Id;
      insert ent; */
      //End: Prepare Test Data      
       
      Test.startTest(); //Start Test
      
      //Set Surviving Support Order
      Id survivingSOId = soList.get(1).Id;
      ApexPages.currentPage().getParameters().put('radioName',survivingSOId);
      
      ApexPages.StandardController controller = 
          new ApexPages.StandardController(soList.get(0)); 
          
      VRSP_SupportOrderController_AC objClass = 
          new VRSP_SupportOrderController_AC(controller);
      
      List<VRSP_SupportOrderController_AC.SuppportOrderWrapper> wrapperList = 
          new List<VRSP_SupportOrderController_AC.SuppportOrderWrapper>();
      
      
      for(Support_Order__c so :soList){
        VRSP_SupportOrderController_AC.SuppportOrderWrapper objWrapper = 
           new VRSP_SupportOrderController_AC.SuppportOrderWrapper();
        objWrapper.isChecked = true;
        objWrapper.isSurvivorSupportOrder = false;
        objWrapper.supportOrderName = so.Name;
        objWrapper.supportOrderId = so.Id;
        objWrapper.objSO = so;
        wrapperList.add(objWrapper);  
      }
      wrapperList.get(1).isSurvivorSupportOrder = true; //Set Survivor
      
      objClass.lstSuppportOrderWrapper = wrapperList;
      
      PageReference prSave = objClass.save();
      
      //Verify Supported Products cloning
      List<Supported_Product__c> spListResult = 
          [SELECT id,
                  Product_Status__c 
            FROM Supported_Product__c 
            WHERE Support_Order__c = :survivingSOId];
      system.debug('>>>>>>>>>>>>>>>>'+spListResult);
      //System.assertEquals(spListRes.size(), 5);
      
      //Verify Associated Sites => added for 4148 Link Associated Sites 
      List<Associated_Sites__c> assoSite = 
          [SELECT Id
            FROM Associated_Sites__c 
            WHERE Id  = :assoSiteIds]; 
system.debug('>>>>>>>>>>>>>>>> assoSiteIds ...'+assoSiteIds);          
system.debug('>>>>>>>>>>>>>>>> assoSite.size2...'+assoSite.size());      
      System.assert(assoSite.size()>0);
      
      
      //Verify Licence Orderes cloning
      List<License_Support_Junction__c> lsListResult = 
          [SELECT Id
            FROM License_Support_Junction__c
            WHERE Support_Order__c = :survivingSOId]; 
      
      System.assertNotEquals(lsListResult.size(), 0);
      
      
      //Verify Opportunity Products
      List<OpportunityLineItem> oppProductListResult = 
          [SELECT Id
            FROM OpportunityLineItem 
            WHERE OpportunityId  = :opp.Id]; 
      
      System.assert(oppProductListResult.size()>0);
    //Verify Supported Product Status
    //  System.assert(spListResult.get(0).Product_Status__c == consolidated);
      
      //Verify Supported Order Status
      List<Support_Order__c> soListResult = [SELECT s.Status__c, s.Sub_Status__c 
                                        FROM Support_Order__c s
                                        WHERE s.Id = :soList.get(0).Id];
      System.assert(soListResult.get(0).Status__c == 'Closed');
      System.assert(soListResult.get(0).Sub_Status__c == consolidated);
      
      //Verify Opportunity Status
      List<Opportunity> oppList = [SELECT o.StageName 
                                    FROM Opportunity o
                                    WHERE o.Id = :opp.Id];
      System.debug('OppList = ' + oppList);
      System.assertNotEquals( 'Not Pursued', oppList.get(0).StageName);
      //Verify Save method output
     // System.assertEquals(prSave, null);
      
      //Verify Cancel method output
      PageReference prCancel = objClass.cancel();
      System.assertNotEquals(prCancel,null);   
      
      Test.StopTest();
    }
  }
  private static void createCustomSettingData(User u, Integer days){
    SO_Auto_Cloned_Before_Date__c customSetting = SO_Auto_Cloned_Before_Date__c.getInstance();
    system.debug('###### CS = '+customSetting);
    if(customSetting == null){
         customSetting = new SO_Auto_Cloned_Before_Date__c();         
         customSetting.Name = u.ProfileId;
         customSetting.Check_Date__c = system.today().addDays(days);
         insert customSetting;
     }else{          
         customSetting.Check_Date__c = system.today().addDays(days);
         upsert customSetting ;
     }
     
     SO_Auto_Cloned_Before_Date__c customSetting2 = SO_Auto_Cloned_Before_Date__c.getInstance();
    system.debug('###### CS = '+customSetting2);
  }
}