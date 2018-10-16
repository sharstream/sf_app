/*************************************************************************************
 Author        :   Amit Kumar Agrawal(Appirio Offshore)
 Date          :   Feb 19, 2013
 Related Task  :   
 Purpose       :   Test class for LicenseOrder_Trigger
 
 //Modifications:
Jitendra K : 19 April 2013 Updated test cases for improvement of code coverage  
***************************************************************************************/
@isTest(SeeAllData=true)
private class LicenseOrder_Trigger_Test {
	
  static @TestVisible License_Order__c lo = new License_Order__c();
  static @TestVisible OpportunityLineItem oppLineItem = new OpportunityLineItem();
  static @TestVisible List<Opportunity> oppList = new List<Opportunity>();
  static @TestVisible String STATUS_TERMINATED = 'Terminated';

	@isTest
  static void proposalTestPopulateOrderedProducts(){  
    User u = TestUtility.createTsetUser(1, null, null, true).get(0);    
    system.runAs(u){
      Account a = TestUtility.createTestAccounts(1, true)[0];
      //Opportunity o = 
      oppList = TestUtility.createTestOpportunity(2,a,false);
      Opportunity o = oppList.get(0);
      o.Type = 'New Client';
      insert oppList;
      Id PRICEBOOKID = TestUtility.getStandardPriceBook().Id;
           
      Product2 product = TestUtility.createTestProduct2(1, true).get(0);
      PricebookEntry entry = TestUtility.createTestPricebookEntry(1, product, PRICEBOOKID, true).get(0);
      OpportunityLineItem oppLineItem = TestUtility.createTestOpportunityLineItem(1, o, 'Licenses', entry, false).get(0);
      oppLineItem.Contract_Type__c = 'Perpetual';
      insert oppLineItem;
      Contract ct = TestUtility.createTestContract(1, a,'MCA', true)[0];      
      License_Order__c lo = TestUtility.createTestLicenseOrder(1, ct, false).get(0);
      lo.Opportunity__c = o.Id;
      insert lo;
      Test.startTest();
      List<Ordered_Product__c> opList = [SELECT Id, Gross_License_Fee__c FROM Ordered_Product__c WHERE License_Order__c = :lo.Id];
      System.assertEquals(1, opList.size(), 'Only one Ordered Product should be created.');
      System.assertEquals(oppLineItem.TotalPrice, opList.get(0).Gross_License_Fee__c, 'Ordered Product Gross License Feed should be same as Opportunity Line Item Total Price.');
      
      delete opList;
      // system.assertEquals(so.CurrencyIsoCode,ct.CurrencyIsoCode);
      lo.Opportunity__c = oppList.get(1).Id;
      update lo;
      
      opList = [SELECT Id, Gross_License_Fee__c FROM Ordered_Product__c WHERE License_Order__c = :lo.Id];
      System.assertEquals(0, opList.size(), 'No Ordered Product should be created when no Opportunity line item is associated.');      
      Test.stopTest();   
    }        
  }

  @isTest
  static void proposalTestUpdateSupportOrder(){
    User u = TestUtility.createTsetUser(1, null, null, true).get(0);    
    system.runAs(u){
      Account a = TestUtility.createTestAccounts(1, true)[0];
      //Opportunity o = 
      oppList = TestUtility.createTestOpportunity(2,a,false);
      Opportunity o = oppList.get(0);
      o.Type = 'New Client';
      insert oppList;
      Id PRICEBOOKID = TestUtility.getStandardPriceBook().Id;
           
      Product2 product = TestUtility.createTestProduct2(1, true).get(0);
      PricebookEntry entry = TestUtility.createTestPricebookEntry(1, product, PRICEBOOKID, true).get(0);
      OpportunityLineItem oppLineItem = TestUtility.createTestOpportunityLineItem(1, o, 'Licenses', entry, false).get(0);
      oppLineItem.Contract_Type__c = 'Perpetual';
      insert oppLineItem;
      Contract ct = TestUtility.createTestContract(1, a,'MCA', true)[0];      
      list<License_Order__c> setLo = new list<License_Order__c>();
      License_Order__c lo = TestUtility.createTestLicenseOrder(1, ct, false).get(0);
      lo.Opportunity__c = o.Id;
      lo.Status__c = 'Terminated';
      insert lo;
      setLo.add(lo);
      License_Order__c loUpdated = setLo.get(0);
      loUpdated.Status__c = 'Terminated';
      update loUpdated;

      Test.startTest();   

      List<Ordered_Product__c> opList = [SELECT Id, Gross_License_Fee__c, Sub_Status__c 
                                        FROM Ordered_Product__c 
                                        WHERE License_Order__c = :loUpdated.Id];
      Ordered_Product__c opUpdated = opList.get(0);      
      opUpdated.Sub_Status__c = 'Terminated';
      update opUpdated;   

      List<Ordered_Product__c> opRetrievedList = [SELECT Id, Gross_License_Fee__c, Sub_Status__c 
                                        FROM Ordered_Product__c 
                                        WHERE License_Order__c = :loUpdated.Id];

      System.assertEquals(1, opList.size(), 'Only one Ordered Product should be created.');
      System.assertEquals('Terminated', opRetrievedList.get(0).Sub_Status__c, 'No Ordered Products have terminated status and sub-status');   
      System.assertEquals(oppLineItem.TotalPrice, opList.get(0).Gross_License_Fee__c, 'Ordered Product Gross License Feed should be same as Opportunity Line Item Total Price.');  
      Test.stopTest();   
    } 
  }

}