public with sharing class LeadAutoConvert {

  /*
  You've been asked by Sales Ops to auto convert certain leads that come into salesforce
  from their Marketing system.  Leads come into the system with the following
  Lead Sources: "Webpage", "Paid Ad", "Sales Rep Outreach".  You are asked to auto convert leads
  that come in with the "Paid Ad" and "Sales Rep Outreach" lead sources. "Paid Ad" leads should be
  converted to an Account, Contact and Opportunity (After Converting "Paid Ad" Leads, the resulting
  Account, Opportunity and Contact should be assigned to a "Queue" user called Paid Admin Owner).
  "Sales Rep Outreach Leads" should be matched to an existing account by email domain and only converted to a Contact.
  */
	private final sObject mysObject;

  // The extension constructor initializes the private member
  // variable mysObject by using the getRecord method from the standard
  // controller.
  //list of leads by specific source
  public transient list<Lead> leads = new list<Lead>();
  public LeadAutoConvert(Set<Id> LeadIds){
    Id userId = UserInfo.getUserId();
    leads = [SELECT id, LeadSource FROM Lead WHERE LeadSource IN('Webpage', 'Paid Ad', 'Sales Rep Outreach')];
  }

  public void convertLeads(string lastName, string company){
    //todo any conversion
    list<sObject> conventions = new list<sObject>();//return converted lead based on Acc, Cont or Opp
    for(Lead ld : leads){
      Lead myLead = new Lead(LastName = lastName, id = ld.id);
      insert myLead;

      Database.LeadConvert lc = new Database.LeadConvert();
      lc.setLeadId(myLead.Id);
      Database.LeadConvertResult lcr = Database.convertLead(lc);
      //convert Account
      //convert Congtact
      //convert opp
      if(myLead.IsConverted){
        if(myLead.LeadSource == 'Paid Ad'){
            //getAccId or ContactId or oppId
          if(typeof == 'Contact'){
            Contact cont = new Contact();
            cont.Id = lcr.convertedContactId;
            //assign cont lead to owner admin queue
            cont.ownerId = q[0].QueueId;
            //then convert/merge lead/obj
            conventions.add(cont);
          }
          else if(typeof == 'Account') {
            Account acc = new Account();
            acc.Id = [SELECT AccountId FROM Contact WHERE Id = :myLead.Contact__c].Id;
            //assign acc lead to owner admin queue
            acc.ownerId = q[0].QueueId;
            conventions.add(acc);
          }
        }
        else if(myLead.LeadSource == 'Sales Rep Outreach'){
          Opportunity opp = new Opportunity();
          opp.Id = lcr.convertedOpportunityId;
          //assign opp lead to owner admin queue
          opp.ownerId = q[0].QueueId;
          conventions.add(opp);
        }
        System.debug('Lead Assign Success');
        System.assert(lcr.isSuccess());
      }
    }

    //This can be replaced with any user id
    Id userId = UserInfo.getUserId();

    //Get the group you want. Queues are stored as group objects with a type of Queue
    Group g = [select Id from Group where Name='Paid Admin Owner' AND Type = 'Queue'];

    GroupMember member = new GroupMember();
    member.UserOrGroupId = userId;
    member.GroupId = g.Id;

    insert member;

    //todo
    if (conversions.size() > 0)
      insert conventions;
  }
}