public with sharing class LeadAutoConvert {

	private final sObject mysObject;

  // The extension constructor initializes the private member
  // variable mysObject by using the getRecord method from the standard
  // controller.
  //list of leads by specific source
  public transient list<Lead> leads = new list<Lead>();
  public LeadAutoConvert(){
    User owner = 'Paid Admin Owner';
    leads = [SELECT id, Lead_Source__c, Type, LeadStatus from Lead where LeadSource IN('Webpage', 'Paid Ad', 'Sales Rep Outreach')];
  }

  public void convertLeads(string lastName, string company){
    //todo any conversion
    list<sObject> objects = new list<sObject>//return converted lead based on Acc, Cont or Opp
    for(Lead ld : leads){
      Lead myLead = new Lead(LastName = lastName, Company = company);
      insert myLead;

      Database.LeadConvert lc = new Database.LeadConvert();
      lc.setLeadId(myLead.Id);
      Database.LeadConvertResult lcr = Database.convertLead(lc)
      //convert Account
      //convert Congtact
      //convert opp
      if(lcr.LeadSource === 'Paid Ad'){
          //getAccId or ContactId or oppId
        if(typeof === 'Contact'){
          Contact cont = new Contact();
          cont.Id = lcr.ConvertedContactId();
          opp.ownerId = q[0].QueueId;
          //then convert/merge lead/obj
          conversions.add(cont);
        }
        else if(typeof === 'Account') {
          Account acc = new Account();
          acc.Id = lcr.ConvertedAccountId();
          opp.ownerId = q[0].QueueId;
          conversions.add(acc);
        }
      }
      else if( lcr.LeadSource === 'Sales Rep Outreach'){
        Opportunity opp = new Opportunity();
        opp.Id = lcr.ConvertedOpportunityId();
        //assign to owner queue
        opp.ownerId = q[0].QueueId;
        conversions.add(opp);
      }
      System.assert(lcr.isSuccess());
    }
    //todo
    insert conversions;
  }
}