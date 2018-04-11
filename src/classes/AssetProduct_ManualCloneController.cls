/*************************************************************************
Name:           AssetProduct_ManualCloneController
Author:         David Perez
Created Date:   create on 05/15/2017 per 408245 Mass Asset Product Manual clone
Description:    This class acts as a centralized place for Asset Product Manual Cloning all related cloning call using on mass manual clone

David Perez    : modified on 06/23/2017 per 408245-feature pass multiselect picklist value to controller
David Perez    : modified on 06/28/2017 per 408245-feature avoid query 101 for product versions
*************************************************************************/

public without sharing class AssetProduct_ManualCloneController {
    
	//TO DO

    // dynamic stuff
    public Account oldAccount{get; set;}
    public string accountId{get; set;}
    public list<WrapAsset> selectedWrapperList{
        get{ 
            if(selectedWrapperList == null) selectedWrapperList = new list<WrapAsset>();
            return selectedWrapperList;
        }
        set;
    }

    public list<WrapAsset> searchresults{get; set;}

    public AssetProduct_ManualCloneController() {

        System.debug('PASSING ID BY URL: '+ ApexPages.currentPage().getParameters().get('id'));
        accountId = ApexPages.currentPage().getParameters().get('Id');
        oldAccount = new Account();
        oldAccount = [select id, name from Account where id =: ApexPages.currentPage().getParameters().get('id')];
        System.debug('OLD Account Name: '+ oldAccount.name);    
        System.debug('Account ID: '+ oldAccount);     
    }

    public List<SelectOption> getStatus() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        options.add(new SelectOption('Production','Production'));
        options.add(new SelectOption('Development','Development'));
        options.add(new SelectOption('Test','Test'));
        options.add(new SelectOption('Obsolete','Obsolete'));
        return options;
    }

    public String selectedNewStatus{get;set;}
    public String selectedOldStatus{get;set;}
    public string searchAsset{
        get {
            if (searchAsset == null) searchAsset = '';
                return searchAsset;
        }
        set;
    }

    public string searchVersion{
        get {
            if (searchVersion == null) searchVersion = '';
                return searchVersion;
        }
        set;
    }

    public PageReference Cancel() {
        PageReference assetPage = new PageReference('/' + accountId);
        assetPage.setRedirect(true);

        return assetPage;
    }
    
    public PageReference search() {
        if (searchresults == null) {
            searchresults = new list<WrapAsset>();
        } else {
            searchresults.clear();
        }
        try{
        string newSearchText = '%'+searchAsset+'%';
            string newProdVersionsSearch ='%'+searchVersion+'%';
            system.debug('new search by asset name: '+newSearchText +' and by product version: '+newProdVersionsSearch);
            if (newSearchText != '%%' || newProdVersionsSearch != '%%') {
        Asset[] assets = [select Id, Status, SerialNumber, Product_Version_2__r.Name, InstallDate, Contract__c, Contract__r.Name, End_of_Life_Support_Date__c, Product_Version_2__c,
                                    CreatedBy.Name, Product_Version_Formula__c, CreatedDate, Account.Name, Contact.Name, Name, Product_Version__c,Product2Id, Product2.Name 
                            from Asset
                              where Name LIKE: newSearchText and AccountId =: accountId and Status IN('Production','Test','Development','Purchased') and 
                              Product_Version_2__r.Name LIKE: newProdVersionsSearch and
                              Product2.IsActive =: true
                              ORDER BY Name ASC];
        system.debug('asset keywords: ' +searchAsset);
        system.debug('search by assets keywords: ' +assets);


        for (Asset asset : assets) {
            WrapAsset wrapper = new WrapAsset(asset);
            searchresults.add(wrapper);
        }
        
                return null; 
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'By search an asset or version please enter the asset or version'));
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

    public PageReference next(){
        selectedWrapperList.clear();
        
        for (WrapAsset wrapper : searchresults) {
            if (wrapper.selected) {
                WrapAsset assetNew = new WrapAsset(wrapper.asset);
                selectedWrapperList.add(assetNew);
            }
        }

        if (selectedWrapperList.size() > 0) {
            return Page.AssetProduct_ManualClone_ResultPage;
        } else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter at least an Asset name on the search section'));
        return null;
    }
    }

    public PageReference back(){
        return Page.AssetProduct_ManualClonePage;
    }
    public Boolean showPopup { get; set; }
    public PageReference showToPopup() {
        showPopUp = true;
        return null;
    }

    public PageReference Save() {
        try{
            //map of asset IDS and versions

            list<WrapAsset> selectedClonedAssets = new list<WrapAsset>();
            for (WrapAsset wrap : selectedWrapperList) {
                if(wrap.selected)
                    selectedClonedAssets.add(wrap);                
            }
            system.debug('selectedClonedAssets: '+selectedClonedAssets);

            if(selectedClonedAssets.size() > 0 && selectedNewStatus != '--None--' && selectedOldStatus !='--None--'){
            integer result = 0;
                for (WrapAsset asset: selectedClonedAssets) {
                      //if (selectedVersions.size() >0 && clonebyAssets.size() > 0) {
                    system.debug('version: '+asset.version);
                    result += AssetClone(asset, asset.version);  
                system.debug('result Asset Clone: '+result);
            }   

            PageReference productversionPge = new PageReference('/' + accountId);
            productversionPge.setRedirect(true);

            return productversionPge;  
            } 
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You must confirm each asset by again checking the check box in the left most column and change the old asset status to: OBSOLETE'));
                return null;
    }

        }
        catch(Exception ex){
            Apexpages.addMessage(new ApexPages.message(
                ApexPages.severity.INFO,'The version of the current asset cannot be selected and will not be in the list: '+ex.getMessage()+' '+ex.getTypeName()));
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

    public class WrapAsset {
        public Asset asset{get; set;}
        public Boolean selected{get; set;}
        public string version{get; set;}
        public list<SelectOption> selecteVersions{get; set;}
        public WrapAsset(Asset pAsset) {
            this.asset = pAsset;
            this.selected = false;
           
            list<Product_Version__c> pv = [select id,Name from Product_Version__c where Product__c =: pAsset.Product2Id and 
                                            Name !=: pAsset.Product_Version_2__r.Name and 
                                            Product__c != null];
            pv.sort();
            list<SelectOption> selectVersions = new list<selectOption>();
            selectVersions.add(new SelectOption('', '--None--'));
            for (Product_Version__c v:pv) {
                selectVersions.add(new SelectOption(v.Id, v.Name));
            }
            this.selecteVersions = selectVersions;   
                    
        }
        
    }

    public Integer AssetClone(WrapAsset assetIdByversion, string clonedVersion) {   
        //TO DO Map passing  by paramater with all target assets with the same product and version
        System.debug('IN START ASSET CLONE: >>>>>>>>>>>>>>>>>');
        Integer numAssetsCreated = 0;
        Asset[] newAsset = new Asset[0];        
        Purchased_Product_Level_1__c[] newPPL = new Purchased_Product_Level_1__c[0];
        String versionName = '';
        Asset[] toRetrieveAsset = [select id from Asset where id =:assetIdByversion.asset.Id];
        Asset[] toUpdateAsset = new list<Asset>();
        if(!toRetrieveAsset.isEmpty()){
            for (Asset beforeUpdate: toRetrieveAsset) {
                system.debug('selectedOldStatus: '+selectedOldStatus);
                if (selectedOldStatus == 'Production')
                    beforeUpdate.Status = 'Production';
                else if(selectedOldStatus == 'Development')
                    beforeUpdate.Status = 'Development';
                else if(selectedOldStatus == 'Test')
                    beforeUpdate.Status = 'Test';          
                else if(selectedOldStatus == 'Obsolete')
                    beforeUpdate.Status = 'Obsolete';   
                else
                    beforeUpdate.Status =  assetIdByversion.asset.Status;
                toUpdateAsset.add(beforeUpdate);          
            }
        }

        //get all the info from the original asset
        // Added Contract field to the cloning process - BR 3/29/2011
        Asset[] origAsset = new Asset[0]; 
        origAsset = [select Id, UsageEndDate, Status, SerialNumber, Quantity, PurchaseDate, Product_Version__c, 
                            Product_Version_Formula__c, Product_Version_2__c, Product2Id, Price, Number_of_Users__c, 
                            Number_of_Licenses__c, Number_of_Customers__c, Name, IsCompetitorProduct, InstallDate, 
                            Description, Date_Shipped__c, CurrencyIsoCode, CreatedDate, ContactId, AccountId, Contract__c
                       from Asset where Id = :assetIdByversion.asset.Id];
        Product_Version__c [] temp_version = [select id, Name from Product_Version__c where id =:clonedVersion];
        system.debug('System.QueryException: List has more than 1 row for assignment to SObject: '+temp_version.size());
        for(Integer i =0; i < origAsset.size(); i++) {
           
            Asset cAsset = origAsset.get(i).clone(false);  
            cAsset.Name = cAsset.Name;
            system.debug('selectedNewStatus: '+selectedNewStatus);
            if (selectedNewStatus == 'Production')
                cAsset.Status = 'Production';
            else if(selectedNewStatus == 'Development')
                cAsset.Status = 'Development';
            else if(selectedNewStatus == 'Test')
                cAsset.Status = 'Test';          
            else if(selectedNewStatus == 'Obsolete')
                cAsset.Status = 'Obsolete';   
            else
            cAsset.Status = assetIdByversion.asset.Status;
                
                system.debug('VERSION NAMES'+temp_version);
            /*if (a.Status == 'Purchased' && a.Product_Version_2__c == null) {
                   cAsset.Status = 'Production'; 
            }*/
            cAsset.Product_Version_2__c = temp_version.get(i).Id; 
            versionName = temp_version.get(i).Name;    
                system.debug('VERSION NAME'+versionName);  

                newAsset.add(cAsset); 
        }
        if(!newAsset.isEmpty())             
        insert newAsset;
        numAssetsCreated = newAsset.size();  
        
        if(!toUpdateAsset.isEmpty())
            update toUpdateAsset;
        
        //create a map
        Set<Id> pplidSet = new Set<Id>();
        for ( Purchased_Product_Level_1__c oldPPL:[select Id, Status__c, Product_Level_1__c, Product_Level_1_Version__c, 
                Product_Level_1_Version_Formula__c, Product_Level_1_Version_2__c, Name, CurrencyIsoCode, Asset__c, 
                Account__c, Account_2__c from Purchased_Product_Level_1__c where Asset__c = :assetIdByversion.asset.Id]) {
            pplidSet.add ( oldPPL.Product_Level_1__c );
        }   
              
        Map<String, String> plvMap = new Map<String, String>();        
        for ( Product_Level_1_Version__c plv:[select Id, Name, Product_Level_1__c from Product_Level_1_Version__c 
            where Name = :versionName and Product_Level_1__c in :pplidSet]) {           
            plvMap.put(plv.Product_Level_1__c, plv.Id);
        }       
        
        for ( Purchased_Product_Level_1__c oldPPL:[select Id, Status__c, Product_Level_1__c, Product_Level_1_Version__c, 
            Product_Level_1_Version_Formula__c, Product_Level_1_Version_2__c, Name, CurrencyIsoCode, Asset__c, Account__c, Account_2__c 
            from Purchased_Product_Level_1__c where Asset__c = :assetIdByversion.asset.Id]) {        
            Purchased_Product_Level_1__c cPPL = oldPPL.clone(false);
            cPPL.Asset__c = newAsset[0].Id;
            //do a lookup on ppl to see if the version on the product exists, if not set it to blank
            
            cPPl.Product_Level_1_Version_2__c = plvMap.get(cPPL.Product_Level_1__c);

            newPPL.add(cPPL);
        }
        insert newPPL;
        System.debug('IN END ASSET CLONE: >>>>>>>>>>>>>>>>>');
        //this number is used to alert the user how many renewal contracts were created
        return numAssetsCreated;
    }
}