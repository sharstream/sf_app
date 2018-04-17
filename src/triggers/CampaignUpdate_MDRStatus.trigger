trigger CampaignUpdate_MDRStatus on Lead (after insert, after update){

  list<id> LeadIds = new list<id>();

  for (Lead l : Trigger.new) {

    if(l.Status == 'Marketing Nurture' && 
		l.Email_Unsubscribe__c == false && 
			l.HasOptedOutOfEmail == false) {
      LeadIds.add(l.Id);
    }
  }

  list<CampaignMember> cmList = [SELECT id, MDR_Status__c FROM CampaignMember WHERE LeadId in :LeadIds];

  for (CampaignMember cm : cmList) {
     cm.MDR_Status__c = 'Marketing Nurture';
  }

  update cmList;
}