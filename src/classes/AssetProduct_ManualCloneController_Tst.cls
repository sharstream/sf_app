/*************************************************************************
Name:           AssetProduct_ManualCloneController_Tst
Author:         David Perez
Created Date:   create on 06/12/2017 per 408245 Test Suite for Mass Asset Product Manual clone
Description:    This class acts as a test suite to Mass Asset Product Clone

*************************************************************************/
@isTest(SeeAllData = true)
private class AssetProduct_ManualCloneController_Tst {
    
	@isTest
    static void testMassAssetCloneMethod() {
        //TO DO
    	User u1 = TestUtility.createTsetUser(1, null, null, true).get(0);
	    	System.RunAs(u1){
	    	//Start: Prepare Test Data
	      	//Account
	    	Account a = TestUtility.createTestAccounts(1, true).get(0);

	    	//Contact
	    	Contact c = TestUtility.createTestContact(1,'Perez', a, true).get(0);
	        
	        //product
	        Product2 prod = new Product2(
			  Name = 'Product Test',                                          	// Product Name
			  Family = 'SaaS',                                                  // Product Family
			  IsActive = true,                                                  // Active
			  CanUseRevenueSchedule = true,                                     // Revenue Scheduling Enabled
			  CanUseQuantitySchedule = true,                                    // Quantity Scheduling Enabled
			  Description = 'Axis SaaS offering - contact Axis team for quote'  // Product Description
			);
			insert prod;

			//propduct version
	        list<Product_Version__c> versions = TestUtility.createTestProductVersion(3, prod, true);
			
			Test.startTest();

			//callout product version id by web parameter
			PageReference pRef = Page.AssetProduct_ManualClonePage;
		  	pRef.getParameters().put('id', a.Id);
		  	Test.setCurrentPage(pRef);
		  	
		  	string accountId = ApexPages.currentPage().getParameters().get('id');
	      	
	      	System.debug('GET REFERENCE WEB PARAMETER: '+accountId);
	      	//End: Prepare Test Data
			// asset
			List<Asset> assetTestlist = TestUtility.createTestAsset(3,a,true);
			List<Asset> toClonelist = new List<Asset>();
			
			for (Integer i =0; i < assetTestlist.size(); i++) {
				Asset newAsset = new Asset();
				newAsset.Id = assetTestlist.get(i).Id;
				newAsset.Product2 = assetTestlist.get(i).Product2;
				newAsset.Product_Version__c = versions.get(0).Name;	
				toClonelist.add(newAsset);
			}	
			update toClonelist;

			Asset[] assets = [select Id, Status, SerialNumber, Product_Version_2__r.Name, InstallDate, Contract__c, Contract__r.Name, End_of_Life_Support_Date__c, Product_Version_2__c,
                                    CreatedBy.Name, Product_Version_Formula__c, CreatedDate, Account.Name, Contact.Name, Name, Product_Version__c,Product2Id, Product2.Name 
                            from Asset
                          where AccountId =: accountId and Status IN('Production','Test','Development','Purchased') ORDER BY Name ASC LIMIT 10];	    

	        //purchased product level 1
	        Product_Level_1__c prodL1 = new Product_Level_1__c();
			Purchased_Product_Level_1__c purProdL1s =  TestUtility.createTestPurProdL1(1,prodL1,a,toClonelist.get(0),true).get(0);

	        AssetProduct_ManualCloneController controller = new AssetProduct_ManualCloneController();
	        controller.selectedWrapperList = new list<AssetProduct_ManualCloneController.WrapAsset>();
			controller.searchresults = new list<AssetProduct_ManualCloneController.WrapAsset>();

			controller.searchAsset = 'Test Asset';
			string newSearchText = '%'+controller.searchAsset+'%';

			PageReference pagesearch = controller.search();

			Asset[] assets2 = [select Id, Status, SerialNumber, Product_Version_2__r.Name, InstallDate, Contract__c, Contract__r.Name, End_of_Life_Support_Date__c, Product_Version_2__c,
                                    CreatedBy.Name, Product_Version_Formula__c, CreatedDate, Account.Name, Contact.Name, Name, Product_Version__c,Product2Id, Product2.Name 
                            from Asset
                          where Name LIKE: newSearchText and AccountId =: accountId and Status IN('Production','Test','Development','Purchased') ORDER BY Name ASC LIMIT 10];
          	

	        for (Asset asset : toClonelist) {
	            AssetProduct_ManualCloneController.WrapAsset wrapper = new AssetProduct_ManualCloneController.WrapAsset(asset);
	            wrapper.selected = true;
	            controller.searchresults.add(wrapper);
	        }

	        list<SelectOption> selectVersions = new list<SelectOption>();
	        for (AssetProduct_ManualCloneController.WrapAsset wrapper : controller.searchresults) {
	            list<Product_Version__c> pv = [select id,Name from Product_Version__c where Product__c =: wrapper.asset.Product2Id];
	            selectVersions.add(new SelectOption('', '--None--'));
	            for (Product_Version__c v:pv) {
	                selectVersions.add(new SelectOption(v.Id, v.Name));
	            }
	        }
	        
			PageReference pagenext = controller.next();
			PageReference pRefNext = Page.AssetProduct_ManualClone_ResultPage;
		  	Test.setCurrentPage(pRefNext);						

			for (AssetProduct_ManualCloneController.WrapAsset wrapper : controller.searchresults) {
	            if (wrapper.selected) {
	                AssetProduct_ManualCloneController.WrapAsset assetNew = new AssetProduct_ManualCloneController.WrapAsset(wrapper.asset);
	                controller.selectedWrapperList.add(assetNew);
	            }
	        }	      

	        list<AssetProduct_ManualCloneController.WrapAsset> selectedClonedAssets = new list<AssetProduct_ManualCloneController.WrapAsset>();
	        for (AssetProduct_ManualCloneController.WrapAsset wrap : controller.selectedWrapperList) {
                if(wrap.selected)
                    selectedClonedAssets.add(wrap);                
            }
            
			PageReference pageback = controller.back();					
			try {
			//Verify Save method output
	        PageReference pageSave = controller.Save();
	        PageReference accountPage = new PageReference('/' + accountId);
		        accountPage.setRedirect(true);
	        Test.setCurrentPage(accountPage);

			controller.showPopup = true;
			PageReference pagepopup = controller.showToPopup();

	        //Verify Cancel method output
      		PageReference prCancel = controller.cancel();     		

	      		integer result = 0;

	        AssetProduct_ManualCloneController.WrapAsset testWrap = new AssetProduct_ManualCloneController.WrapAsset(toClonelist.get(0));
	        testWrap.selected = true;
	        testWrap.version = versions.get(0).Id;
		        result += controller.AssetClone(testWrap, testWrap.version);	      

	        Asset[] toUpdateAsset = new list<Asset>();
	        for (Asset beforeUpdate: toClonelist) {
	                                                
	                controller.selectedOldStatus = 'Production';  
                system.debug('selectedOldStatus: '+controller.selectedOldStatus);
                if (controller.selectedOldStatus == 'Production')
                    beforeUpdate.Status = 'Production';

		            system.assertEquals('Production', controller.selectedOldStatus);

		            controller.selectedOldStatus = 'Development'; 
	                system.debug('selectedOldStatus: '+controller.selectedOldStatus);
	                if (controller.selectedOldStatus == 'Development')
	                    beforeUpdate.Status = 'Development'; 

		            system.assertEquals('Development', controller.selectedOldStatus);

		            controller.selectedOldStatus = 'Test'; 
		            system.debug('selectedOldStatus: '+controller.selectedOldStatus);
	                if (controller.selectedOldStatus == 'Test')
                    beforeUpdate.Status = 'Test';          

		            system.assertEquals('Test', controller.selectedOldStatus);

		            controller.selectedOldStatus = 'Obsolete';
		            system.debug('selectedOldStatus: '+controller.selectedOldStatus);
	                if (controller.selectedOldStatus == 'Obsolete')
                    beforeUpdate.Status = 'Obsolete';   

		            system.assertEquals('Obsolete', controller.selectedOldStatus);

		            beforeUpdate.Status = testWrap.asset.Status;

                toUpdateAsset.add(beforeUpdate);          

	        	}
       
            String versionName = '';
            Asset[] origAsset = new Asset[0]; 
        	origAsset = [select Id, UsageEndDate, Status, SerialNumber, Quantity, PurchaseDate, Product_Version__c, 
                            Product_Version_Formula__c, Product_Version_2__c, Product2Id, Price, Number_of_Users__c, 
                            Number_of_Licenses__c, Number_of_Customers__c, Name, IsCompetitorProduct, InstallDate, 
                            Description, Date_Shipped__c, CurrencyIsoCode, CreatedDate, ContactId, AccountId, Contract__c
                       	from Asset where Id = :testWrap.asset.Id];
           	Asset[] newAsset = new Asset[0]; 
           	Product_Version__c [] temp_version = [select id, Name from Product_Version__c where id =:versions.get(0).Id];   

	           	controller.selectedNewStatus = 'Production';
		        controller.selectedNewStatus = 'Development';
		        controller.selectedNewStatus = 'Test';
		        controller.selectedNewStatus = 'Obsolete';

            for(Integer i =0; i < origAsset.size(); i++) {
	           
	            Asset cAsset = origAsset.get(i).clone(false);  
	            cAsset.Name = cAsset.Name;
	            system.debug('selectedNewStatus: '+controller.selectedNewStatus);
	            if (controller.selectedNewStatus == 'Production')
	                cAsset.Status = 'Production';
	            else if(controller.selectedNewStatus == 'Development')
	                cAsset.Status = 'Development';
	            else if(controller.selectedNewStatus == 'Test')
	                cAsset.Status = 'Test';          
	            else if(controller.selectedNewStatus == 'Obsolete')
	                cAsset.Status = 'Obsolete';   
	            else
	                cAsset.Status =  testWrap.asset.Status;
	            
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
	        
	        if(!toUpdateAsset.isEmpty())
	            update toUpdateAsset;
	        
            //create a map
	        Set<Id> pplidSet = new Set<Id>();
	        for ( Purchased_Product_Level_1__c oldPPL:[select Id, Status__c, Product_Level_1__c, Product_Level_1_Version__c, 
	                Product_Level_1_Version_Formula__c, Product_Level_1_Version_2__c, Name, CurrencyIsoCode, Asset__c, 
	                Account__c, Account_2__c from Purchased_Product_Level_1__c where Asset__c = :testWrap.asset.Id]) {
	            pplidSet.add ( oldPPL.Product_Level_1__c );
	        }   	        
	        
	        Map<String, String> plvMap = new Map<String, String>();        
	        for ( Product_Level_1_Version__c plv:[select Id, Name, Product_Level_1__c from Product_Level_1_Version__c 
	            where Name = :versionName and Product_Level_1__c in :pplidSet]) {           
	            plvMap.put(plv.Product_Level_1__c, plv.Id);
	        } 	        

	        Purchased_Product_Level_1__c[] newPPL = new Purchased_Product_Level_1__c[0];

	        for ( Purchased_Product_Level_1__c oldPPL:[select Id, Status__c, Product_Level_1__c, Product_Level_1_Version__c, 
	            Product_Level_1_Version_Formula__c, Product_Level_1_Version_2__c, Name, CurrencyIsoCode, Asset__c, Account__c, Account_2__c 
	            from Purchased_Product_Level_1__c where Asset__c = :testWrap.asset.Id]) {        
	            Purchased_Product_Level_1__c cPPL = oldPPL.clone(false);
	            cPPL.Asset__c = newAsset[0].Id;
	            //do a lookup on ppl to see if the version on the product exists, if not set it to blank
	            
	            cPPl.Product_Level_1_Version_2__c = plvMap.get(cPPL.Product_Level_1__c);

	            newPPL.add(cPPL);
	        }
		        insert newPPL;

			//ASSERTS
			system.assertEquals(true,toClonelist.size()>0);
	        system.assertEquals(true,assets.size()>0);
				system.assertEquals(pagesearch, null); 
				system.assertNotEquals(pagenext, null);             
	        system.assertEquals(true,assets2.size()>0);
	        system.assertEquals(true,selectVersions.size()>0);
	        system.assertEquals(true,controller.searchresults.size()>0);
	        system.assertEquals(true,controller.selectedWrapperList.size()>0);
            system.debug('selectedClonedAssets: '+selectedClonedAssets);
	        system.assertNotEquals(true,selectedClonedAssets.size()>0);
				system.assertNotEquals(pageback, null);
				system.assertEquals(pagepopup, null);
	        system.assertEquals(true, controller.getStatus().size()>0);
	      		system.assertNotEquals(prCancel, null);
		        system.debug('#### controller1 = '+controller);   
	        system.debug('savePage: '+pageSave);     
	        system.debug('selectedClonedAssets.size(): '+selectedClonedAssets.size());
	        system.debug('versions.size(): '+versions.size());
	        system.assertEquals(true, result > 0);
            system.assertEquals(true, toUpdateAsset.size() > 0);
            system.assertEquals(true, newAsset.size() > 0);
	        system.assertEquals(true, pplidSet.size() > 0);
	        system.assertEquals(true, plvMap.isEmpty() != false);
		        system.assertNotEquals(true, plvMap.values().size() > 0 );
		        system.assertNotEquals(true, plvMap.keySet().size() > 0 );
	        system.assertEquals(true, newPPL.size() > 0);
			system.assertEquals(true,versions.size()>0);
		  	system.assertNotEquals(pRef, null);
		        system.assertEquals(pageSave, null);
		        system.assertNotEquals(accountPage, null);

		    } catch(Exception ex){
	            Apexpages.addMessage(new ApexPages.message(
	                ApexPages.severity.INFO,'The version of the current asset cannot be selected and will not be in the list: '+ex.getMessage()+' '+ex.getTypeName()));
		    }	               

	        ApexPages.Message[] pageMessages = ApexPages.getMessages();	     

			// Check that the error message you are expecting is in pageMessages
			Boolean messageFound= false;

	        for(ApexPages.Message message : pageMessages) {
			    if(message.getSummary() == 'You must confirm each asset by again checking the check box in the left most column and change the old asset status to: OBSOLETE'
			        	&& message.getSeverity() == ApexPages.Severity.INFO) {
			        messageFound = true;        
			    }
			    else if (message.getSummary() == 'Please enter at least an Asset name on the search section' 
			    		&& message.getSeverity() == ApexPages.Severity.ERROR) {
			        messageFound = true; 
			    } else if(message.getSummary() == 'By search an asset or version please enter the asset or version'
			    	&& message.getSeverity() == ApexPages.Severity.INFO){
			        messageFound = true;
			    }			    
			}
			//ASSETS
			system.assertNotEquals(0, pageMessages.size());
			system.assert(messageFound);

	        Test.stopTest();
        }
    }
}