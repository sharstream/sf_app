/*******************************************************************************
 Author        :   Amit Kumar Agrawal(Appirio Offshore)
 Date          :   March 07, 2013
 Related Task  :   T-127686
 Purpose       :   Handler class for OrderedProduct_Trigger
 
 //Modifications:
Jitendra K : 2 May,2013 T-139354 Auto Check/uncheck the Third Party checkbox on 
Ordered Product based on related produt
David Perez per case 632232 Asset Records Auto-creation fixes
David Perez per case 754928 Only one Asset would have been created or existing asset would be assigned to the ordered products
*******************************************************************************/
public without sharing class OrderedProduct_TriggerHandler {
	
	static final String ASSET_STATUS_PURCHASED = 'Purchased';
	
	//----------------------------------------------------------------------------
  // Trigger methods
  //----------------------------------------------------------------------------
  
	//Method called on after Insert of Ordered_Product__c
  public void OnAfterInsert(map<ID,Ordered_Product__c> newMapOPs){
    createAssets(newMapOPs); 
  }
  
  //----------------------------------------------------------------------------
  // Private methods
  //----------------------------------------------------------------------------
  private void createAssets(map<ID,Ordered_Product__c> newMapOPs){
  	
  	map<ID,Asset> mapOPId_Assets = new map<ID,Asset>();
    map<ID, Ordered_Product__c> mapForUniqueProducts = new map<ID, Ordered_Product__c>();
    map<ID, list<string>> mapListOrderedProducts = new map<ID, list<string>>();
    list<Ordered_Product__c> lstOP = new list<Ordered_Product__c>();
    list<Ordered_Product__c> lstOPrepeat = new list<Ordered_Product__c>();
  	set<ID> setAccId = new set<ID>();
  	map<ID,Account> mapAcc = new map<ID,Account>();
  	
    for(Ordered_Product__c op : [SELECT Id,
                                        Product__c,
                                        Name,
                                        License_Order__c,
                                        Asset__c,
                                        Product__r.Name,
                                        License_Order__r.MCA_Contract__c,
                                        License_Order__r.MCA_Contract__r.AccountId 
                                 FROM Ordered_Product__c 
                                 WHERE Id in :newMapOPs.keySet()]){
      
      mapForUniqueProducts.put(op.Product__r.Id, op);
      lstOPrepeat.add(op);
      system.debug('>>>>op in Query::'+op);
    }

    for(Ordered_Product__c op : mapForUniqueProducts.values()){
      setAccId.add(op.License_Order__r.MCA_Contract__r.AccountId);
      lstOP.add(op);
      list<string> products  = new list<string>();
      for (Ordered_Product__c product : lstOPrepeat) {
        if (product.Product__r.Name.equals(op.Product__r.Name)) {
          products.add(product.Id);
        }
      }
      mapListOrderedProducts.put(op.Id, products);
    }

    System.debug('mapListOrderedProducts keys: '+mapListOrderedProducts.keySet() + ' ' + 'values: ' + mapListOrderedProducts.values());

    for(Account a : [Select Id,
			                      (Select Product2Id, 
			                              Status,
                                    Name 
			                       From Assets 
			                       where status='Purchased')
                    From Account 
                    WHERE Id in : setAccId]){    	
    	mapAcc.put(a.Id,a);    	        	
    }
  	//initialize the op map
    for (Integer i = 0; i < lstOP.size(); i++) {
  		if(mapAcc.containsKey(lstOP.get(i).License_Order__r.MCA_Contract__r.AccountId)){
  			Account a = mapAcc.get(lstOP.get(i).License_Order__r.MCA_Contract__r.AccountId);  			
  			List<Asset> assets;
  			if(a.Assets.isEmpty()){
          mapOPId_Assets.put(lstOP.get(i).Id,createAsset(lstOP.get(i)));
  			}
  			else {
  				assets = a.Assets;
          system.debug('list of acc assets: '+assets);
  				boolean isAsset = true;
  				for(Asset asset : assets){
            if(asset.Product2Id == lstOP.get(i).Product__c){
  						isAsset = false;
              mapOPId_Assets.put(lstOP.get(i).Id, asset);
  					}
  				}
  				if(isAsset){
            mapOPId_Assets.put(lstOP.get(i).Id,createAsset(lstOP.get(i)));
  				}
  			}  			  		
  		}
  	}  	  
      
  	if(!mapOPId_Assets.isEmpty()){
  		upsert mapOPId_Assets.values();
      System.debug('op keys references: '+mapOPId_Assets.keySet());
      System.debug('assets values inserted: '+mapOPId_Assets.values());
  	}

    list<Ordered_Product__c> lstFinalOP = new list<Ordered_Product__c>();
    for (ID key : mapListOrderedProducts.keySet()) {

      string[] lstOrderedProducts = mapListOrderedProducts.get(key);      
      set<ID> keys = mapOPId_Assets.keySet();

      // Get the Key as Ordered_Product__c.Id
      // Get Ordered_Product__c[] values = new Ordered_Product__c[] { 'Asset Suite - Core', 'Asset Suite - Core', 'Asset Suite - Core', 'Asset Suite - Core' };
      // Compare mapOPId_Assets.get(key).Name === 'Asset Suite - Core'
      // System.assert(listContains(values, 'Asset Suite - Core'));
      // Add new element to new list

      string assetId = '';
      system.debug('lstOrderedProducts: ' + lstOrderedProducts);
      system.debug('mapOPId_Assets keys: ' + keys);
      if (mapOPId_Assets.containsKey(key)) {
        system.debug('contains');
        assetId = mapOPId_Assets.get(key).Id;
        for (string product : lstOrderedProducts) {
          lstFinalOP.add(new Ordered_Product__c(ID=product, Asset__c = assetId));   
        }       
  	}
  	}
  	// write an alghorit to include a map of duplicate ordered product an the asset created from the acc
    System.debug('New Products associated with assets: ' + lstFinalOP);
  	if(!lstFinalOP.isEmpty()){
  		update lstFinalOP;
  	}  	
  	
  }
  
  // create assets
  private Asset createAsset(Ordered_Product__c op){
  	Asset asset = new Asset();
  	string assetName;
  	if(op.Product__r.Name==null){
  		assetName = 'Asset - '+op.Name;
  	}
  	else {
  		assetName = op.Product__r.Name;
  	}
	  asset.Name         = assetName;
	  asset.Product2Id   = op.Product__c;
	  asset.AccountId    = op.License_Order__r.MCA_Contract__r.AccountId ;
	  asset.Contract__c  = op.License_Order__r.MCA_Contract__c;
	  asset.status       = ASSET_STATUS_PURCHASED;
	  return asset;
  }
  //-----------------------------------------------------------------------------------------------------------------
  // Name      : OnBeforeInsertUpdate 
  // Usage     : call on Before Insert and Update Action of Ordered Product object Trigger
  //              Auto Check/uncheck the Third Party checkbox on 
  //              Ordered Product based on related product
  // Arguments : newOPsMap => Trigger.NewMap ; oldOPsMap => Trigger.OldMap
  //----------------------------------------------------------------------------------------------------------------- 
  
  public void OnBeforeInsertUpdate(List<Ordered_Product__c> newOPsList, map<Id, Ordered_Product__c> oldOPsMap){
    
    Set<Id> productIds = new Set<Id>();
    
    for(Ordered_Product__c op : newOPsList){
    	if(op.Product__c == NULL){
        op.Third_Party_Product__c = false;
      }else if((oldOPsMap == NULL) ||
    	   (oldOPsMap != NULL && oldOPsMap.get(op.Id).Product__c != op.Product__c)){
    		  productIds.add(op.Product__c);
    	}
    }
    //return if product id is available
    if(productIds.isEmpty()) return;
    Map<Id, Product2> prodMap = new Map<Id, Product2>([SELECT Id,
                                                              Third_Party_Product__c
                                                        FROM Product2
                                                        WHERE Id IN : productIds]);
    for(Ordered_Product__c op : newOPsList){
      if(prodMap.containsKey(op.Product__c)){
        op.Third_Party_Product__c = prodMap.get(op.Product__c).Third_Party_Product__c;
      }
    }  
  }
}