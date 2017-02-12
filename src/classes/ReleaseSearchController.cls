/**********************************************************************************
 Self Service Release Notes 2016
 Author: David Perez
 SFDC CoE
 AT-128068 selecting a product in the Search by Product
 AT-128069 selecting another product
 AT-128077 selecting a component when multiples exist and none are already selected
 AT-128078 selecting a backlog when multiples exist and none are already selected
 AT-128079 selecting a version filter item
 AT-128080 De-selection clear the filter list
 AT-128081 De-selection clear the filter list
***********************************************************************************/
public with sharing class ReleaseSearchController {
    
    //TO DO

	public list<V1_NoteSelectionItems> tempListing{get; set;}
	public List<V1_Release_Notes_Table_Content__c> releases { get; set; }
	Transient String soql { get; set; }
	public list<prodTableWrapper> beforeWrapproducts{ get; set;}
	public list<prodTableWrapper> afterWrapproducts{get; set;}
	public list<wrapProdDefault> wrapProdDefaults{get; set;}
	public Set<String> productNameSet{get; set;}
	public V1_RN_NoteSelectionItemsListing selectionItemsListing{ get; set; }
	public String GroupByOption { get; set; }
	public String ProductSubTitleData { get; set; }
	public String VersionSubTitle { get; set; }
	public String VersionSubTitleData { get; set; }
	public List<String> noteItemsForPDF{ get; set; }
	public list<V1_NoteSelectionItems> selectedDisplayItems = new list<V1_NoteSelectionItems>();
	public list<versionTableWrapper> versionsToDisplay{get;set;}
	public list<componentTableWrapper> componentsToDisplay{get;set;}
	public list<backlogTableWrapper> backlogsToDisplay{get;set;}
	Transient String selection{get;set;}
	Transient String selectionFromVersion{get;set;}
	Transient String versionSelected{get;set;}
	Transient String componentSelected{get;set;}
	Transient String connectSelectionVersion{get; set;}
	Transient String connectedSelectionComponent{get; set;}
	Transient String connectSelectionBacklog{get; set;}
	// mapping release notes by each element release
	Map<V1_NoteSelectionItems, prodTableWrapper> productMaprelease;
	Map<V1_NoteSelectionItems, versionTableWrapper> versionMaprelease;
	Map<V1_NoteSelectionItems, componentTableWrapper> componentMaprelease;
	Map<V1_NoteSelectionItems, backlogTableWrapper> backlogMaprelease;
	//public Map<String,Set<versionTableWrapper>> wrapMapVerDefaults{get; set;}
	
	// init the controller and display some sample datas when the page loads
    public ReleaseSearchController() {

    	backlogMaprelease = new Map<V1_NoteSelectionItems, backlogTableWrapper>();
    	componentMaprelease = new Map<V1_NoteSelectionItems, componentTableWrapper>();
    	versionMaprelease = new Map<V1_NoteSelectionItems, versionTableWrapper>();
    	productMaprelease = new Map<V1_NoteSelectionItems, prodTableWrapper>();
    	this.noteItemsForPDF = new List<String>();
    	beforeWrapproducts = new list<prodTableWrapper>();
    	afterWrapproducts = new list<prodTableWrapper>();
    	productNameSet = new Set<String>();
    	ProductSubTitleData = '';
    	VersionSubTitle = '';
    	VersionSubTitleData = '';
    	wrapProdDefaults = new list<wrapProdDefault>();
    	tempListing = new List<V1_NoteSelectionItems>();
    	releases = new List<V1_Release_Notes_Table_Content__c>();   	
    	//wrapMapVerDefaults = new Map<String,Set<versionTableWrapper>>();
    	versionsToDisplay = new list<versionTableWrapper>();
    	componentsToDisplay = new list<componentTableWrapper>();
    	backlogsToDisplay = new list<backlogTableWrapper>();
    	selection = '';
    	selectionFromVersion = '';
    	connectSelectionVersion = '';
    	connectedSelectionComponent = '';
    	versionSelected = '';
    	componentSelected = '';
    	connectSelectionBacklog = '';
        soql = 'select Name, V1_RN_Matriarch__c from V1_Release_Notes_Table_Content__c where V1_RN_Matriarch__c != null and Name != null';	   	
		
		runQuery();
		
		for(V1_Release_Notes_Table_Content__c release : releases)
			productNameSet.add(release.V1_RN_Matriarch__c);
			
		selectionItemsListing = new V1_RN_NoteSelectionItemsListing(productNameSet);
		
		populateTableProduct();
		// The default to be sure it is set
		this.GroupByOption = V1_RN_NoteSelectionItemsListing.GroupByOptions.BacklogGroup.name();
		
		for(V1_NoteSelectionItems prod : selectionItemsListing.ProdFilterListing)
			wrapProdDefaults.add(new wrapProdDefault(prod.Entitlement));
		
		System.debug('Display the wrapProdDefaults: '+wrapProdDefaults);
		//System.debug('Display the wrapMapVerDefaults Map for version: '+wrapMapVerDefaults);
    }
	public String sortDir {
		get { if (sortDir == null) {sortDir = 'asc';} return sortDir;}
		set;
	}
	//the current fields to sort by. defaults to asset suite product
	public String sortField {
		get{if (sortField == null) {sortField = 'Name';} return sortField;}
		set;
	}

	// toggles the sorting of query from asc<-->desc
	public void toggleSort() {
		// simply toggle the direction
		sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
		// run the query again
		runQuery();
	}
    // runs the actual query
	public void runQuery() {

		try {
			releases = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Oppps! Release Notes List empty!'));
			System.debug('>>>>>>>>>>>>>>>>>>>>>'+e);
		}
	}
	public void populateTableProduct(){
		// mapping release notes by each product release
		for(V1_NoteSelectionItems note : selectionItemsListing.DisplayListing)
			beforeWrapproducts.add(new prodTableWrapper(note));
		for (prodTableWrapper prodToMap : beforeWrapproducts) {
			productMaprelease.put(prodToMap.product, prodToMap);
		}
	}
	//AT-128068 selecting a product in the Search by Product
	//AT-128069 selecting another product
	public PageReference find(){

		this.afterWrapproducts.clear();
		this.beforeWrapproducts.clear();
		for(wrapProdDefault prod : wrapProdDefaults){
			if(prod.selectedProduct == true){
				selection = '';
				selection =  prod.productDefault;
				String qry = 'select Name,V1_RN_ItemTitle__c, V1_RN_IDNumber__c, V1_RN_BacklogGroup__c, V1_RN_CaseAccount__c, V1_RN_Source__c,V1_RN_Matriarch__c, V1_RN_Component__c, V1_RN_SubComponent__c, V1_RN_ProductVersion__c, V1_RN_ReleaseNotes__c,V1_RN_Case_ID__c,V1_RN_Request_ID__c, V1_RN_CR_ID__c, V1_RN_Type__c, V1_RN_FixedInVersion__c from V1_Release_Notes_Table_Content__c where V1_RN_Matriarch__c =: selection';

				for(V1_Release_Notes_Table_Content__c compareTo : Database.query(qry)) {

				    	prodTableWrapper wrap = new prodTableWrapper(new V1_NoteSelectionItems(compareTo));
		  				beforeWrapproducts.add(wrap);

				}
				//beforeWrapproducts.sort();
				System.debug('Sorting Product List >>>>>>>>> ' + beforeWrapproducts);
				System.debug('Sorting Product List >>>>>>>>> ' + afterWrapproducts);
				System.debug('Search by Selection: '+ selection);
			}
		}
        //System.debug('Display the beforeWrapproducts: '+beforeWrapproducts);
        return null;
	}
	//AT-128070 selecting a version when multiple exist and none are already selected
	public void connectProdVersion(){
		//TO DO
		
		this.versionsToDisplay.clear();
		//Map<prodTableWrapper, Set<versionTableWrapper>> = Map<prodTableWrapper.product='Asset Suite', Set<'versionTableWrapper.version => 1.1', 'versionTableWrapper.version => 1.2'}>>
		if(!wrapProdDefaults.isEmpty()){
		
			for(wrapProdDefault wrapTo : this.wrapProdDefaults) {
				this.selectionFromVersion = '';
				this.selectionFromVersion =	wrapTo.productDefault;
				//String verQry = 'select Name,V1_RN_ItemTitle__c, V1_RN_IDNumber__c, V1_RN_BacklogGroup__c, V1_RN_CaseAccount__c, V1_RN_Source__c,V1_RN_Matriarch__c, V1_RN_Component__c, V1_RN_SubComponent__c, V1_RN_ProductVersion__c, V1_RN_ReleaseNotes__c,V1_RN_Case_ID__c,V1_RN_Request_ID__c, V1_RN_CR_ID__c, V1_RN_Type__c, V1_RN_FixedInVersion__c from V1_Release_Notes_Table_Content__c where V1_RN_Matriarch__c =: selectionFromVersion';
	       	
				if(wrapTo.selectedProduct == true){
					
					for(V1_NoteSelectionItems c : selectionItemsListing.VersionFilterListing){
						if (selectionFromVersion.equals(c.Entitlement)) {
							versionTableWrapper inserted = new versionTableWrapper(c.ProductVersion);
						    versionsToDisplay.add(inserted);
						}					    	
					}
				}

			}
		}
	}
	//AT-128077 selecting a component when multiples exist and none are already selected
	public void connectVersComponent(){
		//TO DO
		
		this.componentsToDisplay.clear();
		//Map<prodTableWrapper, Set<versionTableWrapper>> = Map<prodTableWrapper.product='Asset Suite', Set<'versionTableWrapper.version => 1.1', 'versionTableWrapper.version => 1.2'}>>
		if(!versionsToDisplay.isEmpty()){
		
			for(versionTableWrapper wrapTo : versionsToDisplay) {
				
				if(wrapTo.selectedVer == true){
					versionSelected = '';
					versionSelected = wrapTo.version;
					//String verQry = 'select Name,V1_RN_ItemTitle__c, V1_RN_IDNumber__c, V1_RN_BacklogGroup__c, V1_RN_CaseAccount__c, V1_RN_Source__c,V1_RN_Matriarch__c, V1_RN_Component__c, V1_RN_SubComponent__c, V1_RN_ProductVersion__c, V1_RN_ReleaseNotes__c,V1_RN_Case_ID__c,V1_RN_Request_ID__c, V1_RN_CR_ID__c, V1_RN_Type__c, V1_RN_FixedInVersion__c from V1_Release_Notes_Table_Content__c Where V1_RN_ProductVersion__c =: versionSelected';
					for(V1_NoteSelectionItems c : selectionItemsListing.ComponentFilterListing){
						if (versionSelected.equals(c.ProductVersion)) {
						    componentTableWrapper toInsert = new componentTableWrapper(c.Component);
							componentsToDisplay.add(toInsert);
						}
					}
				}
			}
		}
	}
	//AT-128078 selecting a backlog when multiples exist and none are already selected
	public void connectCompBacklog(){
		//TO DO		
		this.backlogsToDisplay.clear();
		//Map<prodTableWrapper, Set<versionTableWrapper>> = Map<prodTableWrapper.product='Asset Suite', Set<'versionTableWrapper.version => 1.1', 'versionTableWrapper.version => 1.2'}>>
		if(!componentsToDisplay.isEmpty()){
			
			for(componentTableWrapper wrapTo : componentsToDisplay) {
				componentSelected = '';
				componentSelected =	wrapTo.component;
				//String verQry = 'select Name,V1_RN_ItemTitle__c, V1_RN_IDNumber__c, V1_RN_BacklogGroup__c, V1_RN_CaseAccount__c, V1_RN_Source__c,V1_RN_Matriarch__c, V1_RN_Component__c, V1_RN_SubComponent__c, V1_RN_ProductVersion__c, V1_RN_ReleaseNotes__c,V1_RN_Case_ID__c,V1_RN_Request_ID__c, V1_RN_CR_ID__c, V1_RN_Type__c, V1_RN_FixedInVersion__c from V1_Release_Notes_Table_Content__c Where V1_RN_Component__c =: componentSelected';
	       
				if(wrapTo.selectedComp == true){
					for(V1_NoteSelectionItems c : selectionItemsListing.ComponentFilterListing){
						if (componentSelected.equals(c.Component)) {
						    backlogTableWrapper toInsert = new backlogTableWrapper(c.Backlog);
							backlogsToDisplay.add(toInsert);
						}		
					}
				}
			}
		}
	}
	//AT-128079 selecting a version filter item
	public PageReference findVersion(){
		//prodTableWrapper class

		this.beforeWrapproducts.clear();
    	for(versionTableWrapper version : versionsToDisplay){
    		if(version.selectedVer == true){
    			for(wrapProdDefault prod : wrapProdDefaults){
    				if(prod.selectedProduct == true){
    					connectSelectionVersion = '';
    					selection = '';
			    		connectSelectionVersion = version.version;
			    		selection= prod.productDefault;
				        //String qry = 'select Name,V1_RN_ItemTitle__c, V1_RN_IDNumber__c, V1_RN_BacklogGroup__c, V1_RN_CaseAccount__c, V1_RN_Source__c,V1_RN_Matriarch__c, V1_RN_Component__c, V1_RN_SubComponent__c, V1_RN_ProductVersion__c, V1_RN_ReleaseNotes__c,V1_RN_Case_ID__c,V1_RN_Request_ID__c, V1_RN_CR_ID__c, V1_RN_Type__c, V1_RN_FixedInVersion__c from V1_Release_Notes_Table_Content__c Where V1_RN_ProductVersion__c =: connectSelectionVersion AND V1_RN_Matriarch__c =:selection';
				        
				        for(V1_NoteSelectionItems c : selectionItemsListing.DisplayListing) {
				        	if (selection.equals(c.Entitlement) && connectSelectionVersion.equals(c.ProductVersion)) {			        	
				        		prodTableWrapper wrap = new prodTableWrapper(new V1_NoteSelectionItems(c.ProductVersion));
				        		beforeWrapproducts.add(wrap);
			        		}
				        }
				        System.debug('Search by Selection: '+ selection);
			        }
		        }
	        }
        }
        
        //System.debug('Display the beforeWrapproducts: '+beforeWrapproducts);
        return null;
	}
	public PageReference findComponent(){
		//prodTableWrapper class

		this.beforeWrapproducts.clear();
    	for(componentTableWrapper component : componentsToDisplay){
    		if(component.selectedComp == true){
    			for(versionTableWrapper ver : versionsToDisplay){
    				if(ver.selectedVer == true){
			    		connectedSelectionComponent = '';
			    		connectSelectionVersion = '';
			    		connectedSelectionComponent = component.component;
			    		connectSelectionVersion = ver.version;
				        String qry = 'select Name,V1_RN_ItemTitle__c, V1_RN_IDNumber__c, V1_RN_BacklogGroup__c, V1_RN_CaseAccount__c, V1_RN_Source__c,V1_RN_Matriarch__c, V1_RN_Component__c, V1_RN_SubComponent__c, V1_RN_ProductVersion__c, V1_RN_ReleaseNotes__c,V1_RN_Case_ID__c,V1_RN_Request_ID__c, V1_RN_CR_ID__c, V1_RN_Type__c, V1_RN_FixedInVersion__c from V1_Release_Notes_Table_Content__c Where V1_RN_Component__c =: connectedSelectionComponent AND V1_RN_ProductVersion__c =: connectSelectionVersion';
				        
				        for(V1_Release_Notes_Table_Content__c c : Database.query(qry)) {
				        	prodTableWrapper wrap = new prodTableWrapper(new V1_NoteSelectionItems(c));
				        	beforeWrapproducts.add(wrap);
				        }
				        System.debug('Search by Selection: '+ ver);
			        }
	        	}
	        }
        }
        
        //System.debug('Display the beforeWrapproducts: '+beforeWrapproducts);
        return null;
	}
	public PageReference findBacklog(){
		//prodTableWrapper class

		this.beforeWrapproducts.clear();
    	for(backlogTableWrapper backlog : backlogsToDisplay){
    		if(backlog.selectedBack == true){
    			for(componentTableWrapper component : componentsToDisplay){
    				if(component.selectedComp == true){
			    		connectedSelectionComponent = '';
			    		connectSelectionBacklog = '';
			    		connectedSelectionComponent = component.component;
			    		connectSelectionBacklog = backlog.backlog;
				        String qry = 'select Name,V1_RN_ItemTitle__c, V1_RN_IDNumber__c, V1_RN_BacklogGroup__c, V1_RN_CaseAccount__c, V1_RN_Source__c,V1_RN_Matriarch__c, V1_RN_Component__c, V1_RN_SubComponent__c, V1_RN_ProductVersion__c, V1_RN_ReleaseNotes__c,V1_RN_Case_ID__c,V1_RN_Request_ID__c, V1_RN_CR_ID__c, V1_RN_Type__c, V1_RN_FixedInVersion__c from V1_Release_Notes_Table_Content__c Where V1_RN_Component__c =: connectedSelectionComponent AND V1_RN_BacklogGroup__c =: connectSelectionBacklog';
				        
				        for(V1_Release_Notes_Table_Content__c c : Database.query(qry)) {
				        	prodTableWrapper wrap = new prodTableWrapper(new V1_NoteSelectionItems(c));
				        	beforeWrapproducts.add(wrap);
				        }
				        System.debug('Search by Selection: '+ backlog);
			        }
	        	}
	        }
        }
        
        //System.debug('Display the beforeWrapproducts: '+beforeWrapproducts);
        return null;
	}
	//default product 'Ellipse', 'Asset Suite', 'eSOMS', 'Service Suite', 'nMarket' product wrap class
	public class wrapProdDefault {
    	public String productDefault{get; set;}
    	public Boolean selectedProduct{get; set;}
    	public wrapProdDefault(String inputProduct){
    		productDefault = inputProduct;
    		selectedProduct = false;
    	}
    }   
    //Release Notes Table wrap class
    public class prodTableWrapper {
        public V1_NoteSelectionItems product{get; set;}
        public Boolean selected {get; set;}
        public Boolean clicked {get; set;}
        public prodTableWrapper(V1_NoteSelectionItems p){
            product = p;
            selected = false;
            clicked = false;
        }
    }	
	public class versionTableWrapper {
        public String version{get; set;}
        public Boolean selectedVer {get; set;}
        public Boolean clicked {get; set;}
        public versionTableWrapper(){
        	this.selectedVer = false;
            this.clicked = false;
        }
        public versionTableWrapper(String v) {
            this();
            this.version = v;
        }
    }   
    public class componentTableWrapper{
    	public String component{get; set;}
    	public Boolean selectedComp {get; set;}
    	public Boolean clicked {get; set;}
    	public componentTableWrapper(String c){
    		this.component = c;
    		this.selectedComp = false;
    		this.clicked = false;
    	}
    }  
    public class backlogTableWrapper{
    	public String backlog{get; set;}
    	public Boolean selectedBack {get; set;}
    	public Boolean clicked {get; set;}
    	public backlogTableWrapper(String b){
    		this.backlog = b;
    		this.selectedBack = false;
    		this.clicked = false;
    	}
    }	
	public PageReference getSelected() {
        selectedDisplayItems.clear();
        System.debug('getSelected() Display items size: ' + beforeWrapproducts.size());
        for(prodTableWrapper dispWrapper : beforeWrapproducts){
            if(dispWrapper.selected == true){
            	System.debug('Selected version: ' + dispWrapper.product.ProductVersion + ' selected component: ' + dispWrapper.product.Component);
            	selectedDisplayItems.add(dispWrapper.product);
            }
		}
		this.noteItemsForPDF = selectionItemsListing.createPDFOutputList(selectedDisplayItems, GroupByOption);
		return setupPDFPage('/apex/V1_RN_DisplayPDFInfo', 'Release_Note.pdf');
    }  
    public PageReference clicked() {
        selectedDisplayItems.clear();
        for(prodTableWrapper dispWrapper : beforeWrapproducts){
            if(dispWrapper.clicked == true)
            	selectedDisplayItems.add(dispWrapper.product);
        }
		this.noteItemsForPDF = selectionItemsListing.createPDFOutputList(selectedDisplayItems, GroupByOption);
		return setupPDFPage('/apex/V1_RN_DisplayPDFInfo', '');
    }	
	public PageReference getChecked() {
    	Integer count=0;
		pagereference q;
        selectedDisplayItems.clear();
        for(prodTableWrapper dispWrapper : beforeWrapproducts) {
            if(dispWrapper.selected != true){
                pagereference p = apexpages.Currentpage();
				apexpages.Message msg = new ApexPages.Message (ApexPages.Severity.ERROR, 'Please select a record to download ');
				apexpages.addmessage(msg);
				q=p; 
            }
            else{
                count = count +1;
                
			}
        }
        if(count > 0){
            q=getSelected();
        }
    	return q;    
	}	
    public PageReference pdfDownloadAll()	{     

		this.noteItemsForPDF = selectionItemsListing.createPDFOutputList(selectionItemsListing.DisplayListing, GroupByOption);
		return setupPDFPage('/apex/V1_RN_DisplayPDFInfo', 'Release_Note.pdf');
	}	
	private PageReference setupPDFPage(String pageName, String fileName)	{
		PageReference pageRef = new PageReference(pageName);
		pageRef.setRedirect(false);
		
		ProductSubTitleData = getSetToString(selectionItemsListing.SelectedRNDisplayProducts);
			
		if((VersionSubTitleData = getSetToString(selectionItemsListing.SelectedRNDisplayVersions)) != ''){
			VersionSubTitle = 'Included Versions:';	
		}
		else
			VersionSubTitle = '';
			
		if(fileName != null && fileName != '')
			Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + fileName);
		return PageRef;
	}	
	private String getSetToString(Set<String> setToWork)	{
		Integer curIndex = 0;
		String stringToReturn = '';
		
		if(setToWork == null || setToWork.isEmpty())
			return '';
			
		for(String curitem: setToWork){
			if(curIndex++ > 0)
				stringToReturn += ',';			
			stringToReturn += curitem;
		}
		return stringToReturn;
	}	
	public List<SelectOption> getGroupBys()	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(V1_RN_NoteSelectionItemsListing.GroupByOptions.BacklogGroup.name(), 'Backlog Group'));
		options.add(new SelectOption(V1_RN_NoteSelectionItemsListing.GroupByOptions.Component.name(), 'Component'));
		options.add(new SelectOption(V1_RN_NoteSelectionItemsListing.GroupByOptions.SubComponent.name(), 'Sub-Component'));
		return options;		
	}
}