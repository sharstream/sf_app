/*************************************************************************
Name:           InlineEdit_Opportunity
Author:         David Perez
Created Date:   per 564720 create on 06/15/2017 per Inline Edit Opportunity
Description:    This class acts as a centralized place for displaying Inline Oppty List View

 David Perez modified: on 06/27/2017 per 598787 How to get the current User ID and pass to the Oppty list view
 David Perez modified: on 07/06/2017 include teh manager view oppty list (better state view performance)
*************************************************************************/
global with sharing class InlineEdit_Opportunity {
    // TO DO
	static public list<Opportunity> opportunities{get; set;}
	//public Opportunity o{get; set;}
	public list<WrapOppty> opptyWrappers{get{ 
            if(opptyWrappers == null) opptyWrappers = new list<WrapOppty>();
            return opptyWrappers;
        }
        set;
    }
    //dynamic name search
    static public string currentUser{
        get{
             User currentUser = [select id, Name, LastName from User where id =: UserInfo.getUserId()];
             string dynamicLastName = '%'+currentUser.Name+'%';
             system.debug('UserInfo.getUserId(): '+UserInfo.getUserId());
             system.debug('currentUser.Name: '+currentUser.Name);
             system.debug('Current Login User Name: '+dynamicLastName);
             return dynamicLastName; 
        }
        set;
    }

	static public list<WrapOppty> selectedWrapperList{
        get{ 
            if(selectedWrapperList == null) selectedWrapperList = new list<WrapOppty>();
            return selectedWrapperList;
        }
        set;
    }
    public InlineEdit_Opportunity() {  
        system.debug('selectOpptyRemote(): '+selectOpptyRemote());
		for(Opportunity oppty : selectOpptyRemote()) {       
            WrapOppty wrapperRec = new WrapOppty(oppty);
            opptyWrappers.add(wrapperRec);
        }  
        system.debug('opptyWrappers: '+opptyWrappers);
    }

    //REMOTE Functions
    @RemoteAction

    global static List<Opportunity> selectOpptyRemote() {
        List<Opportunity> opportunities = new List<Opportunity>();
        if(currentUser == '%Kim Rivera%'){
        opportunities = [select Id, Name, Area__c, Type, Forecast_Call__c, Account.Name, Next_Steps__c, OwnerId, BU_Code__c, 
        				RecordTypeId, Probability, CloseDate, Regional_Forecast_Call__c, 
    					ForecastCategoryName, TotalOpportunityQuantity, Opportunity_Description__c, RecordType.Name, Status__c, 
    					NextStep, StageName, Stage_Sub_Category__c, Amount
                        from Opportunity where Type =: 'Renewal' and RecordType.Name =: 'Operations Opportunity Record Type' and
                        StageName NOT IN('Closed','Won','Not Pursued','Lost','Cancellation') and
                        Owner.Name LIKE: '%ABB%'];
        }
        else opportunities = [select Id, Name, Area__c, Type, Forecast_Call__c, Account.Name, Next_Steps__c, OwnerId, BU_Code__c, 
                            RecordTypeId, Probability, CloseDate, Regional_Forecast_Call__c, 
                            ForecastCategoryName, TotalOpportunityQuantity, Opportunity_Description__c, RecordType.Name, Status__c, 
                            NextStep, StageName, Stage_Sub_Category__c, Amount
    					from Opportunity where Type =: 'Renewal' and RecordType.Name =: 'Operations Opportunity Record Type' and 
    					StageName NOT IN('Closed','Won','Not Pursued','Lost','Cancellation') and
                            Owner.Name LIKE: currentUser];
        return opportunities;
    }

    public PageReference Cancel() {
        PageReference assetPage = new PageReference('/' + '006/o');
        assetPage.setRedirect(true);
        return assetPage;
    }
    public Boolean showPopup { get; set; }
    public PageReference showToPopup() {
        showPopUp = true;
        return null;
    }

    public PageReference massSubmitOpportunities(){   	
    	try {
    	    selectedWrapperList.clear();
	        list<Opportunity> opptyToUpdate = new list<Opportunity>();
	        for (WrapOppty wrapper : opptyWrappers) {
	            if (wrapper.selected) {
	                WrapOppty oppty = new WrapOppty(wrapper.oppty);
	                selectedWrapperList.add(oppty);
	            }
	        }
            System.debug('selectedWrapperList: '+selectedWrapperList);      

	        if (selectedWrapperList.size() > 0) {
	         	for (WrapOppty oldOppty: selectedWrapperList) {
	         		Opportunity newOppty = new Opportunity();
	         		newOppty.Name = oldOppty.oppty.Name;
	         		newOppty.Id = oldOppty.oppty.Id;
	         		newOppty.OwnerId = oldOppty.oppty.OwnerId;
	         		newOppty.CloseDate = oldOppty.oppty.CloseDate;
	         		newOppty.Forecast_Call__c = oldOppty.oppty.Forecast_Call__c;
	         		newOppty.Opportunity_Description__c = oldOppty.oppty.Opportunity_Description__c;
	         		newOppty.Status__c = oldOppty.oppty.Status__c;
	         		newOppty.Next_Steps__c = oldOppty.oppty.Next_Steps__c;

	         		opptyToUpdate.add(newOppty);
	         	}
	         } 
             else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please select at least one Opportunity to update'));
                return null;
            }

	        if (opptyToUpdate.size() > 0 && !opptyToUpdate.isEmpty()) {
	        	update opptyToUpdate;
	        	PageReference opptyGeneralView = new PageReference('/' + '006/o');
	        	opptyGeneralView.setRedirect(true);
	            return opptyGeneralView;
	        } 
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please select at least one Opportunity to update'));
	            return null;
	        }
    	}
    	catch(Exception ex){
            Apexpages.addMessage(new ApexPages.message(
                ApexPages.severity.INFO,ex.getMessage()+' '+ex.getCause()+' '+ex.getLineNumber()+' '+ex.getStackTraceString()+' '+ex.getTypeName()));
            System.debug('>>>>>>In side Catch');
            System.debug('>>>>>>Execute Exception'+ex.getMessage());
            System.debug('#### Exception type caught: ' + ex.getTypeName());    
            System.debug('#### Message: ' + ex.getMessage());    
            System.debug('#### Cause: ' + ex.getCause());    // returns null
            System.debug('#### Line number: ' + ex.getLineNumber());    
            System.debug('#### Stack trace: ' + ex.getStackTraceString());
            return null;
    	}	
    }

    public class WrapOppty{
    	public Opportunity oppty{get; set;}
    	public boolean selected{get; set;}
    	public WrapOppty(Opportunity pOppty){
    		this.oppty = pOppty;
    		selected = false;
    	}
    }

}