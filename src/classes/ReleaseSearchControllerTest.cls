/**********************************************************************************
 Unit Test for Self Service Release Notes
 Author: David Perez
 SFDC CoE
 AT-128068 selecting a product in the Search by Product
 AT-128069 selecting another product
 AT-128077 selecting a component when multiples exist and none are already selected
 AT-128078 selecting a backlog when multiples exist and none are already selected
 AT-128079 selecting a version filter item
 AT-128080 De-slection clear the filter list
 AT-128081 De-slection clear the filter list
***********************************************************************************/

@isTest(SeeAllData = true)
private class ReleaseSearchControllerTest {
    
    @isTest
    static void initProposalTestReleaseNotes() {
    
        /*Also to be sure that this class works correctly we should create and
        *insert some records for the object that we are running the query on
        *(ReleaseNotes in the above example) and then after we call runQuery()
        *check the candidates list and ensure that the first record would be the 
        *first record that is returned.*/

        User u1 = TestUtility.createTsetUser(1, 'Ventyx System Administrator', null, true).get(0);
        System.RunAs(u1){
        //TO DO
            Test.startTest();

            List<V1_Release_Notes_Table_Content__c> temporaryList = V1TestUtility_Test.createTestReleaseNotes(5, true);
            
            // instantiate the controller
            
            ReleaseSearchController controller = new ReleaseSearchController();
            ReleaseSearchController.wrapProdDefault wrapdefault = new ReleaseSearchController.wrapProdDefault('Ellipse Tst');

            String testDebugSoql = controller.soql;
            controller.runQuery();
            list<V1_NoteSelectionItems> noteReleases = controller.selectedDisplayItems;
            controller.selection = 'Ellipse Tst';
            PageReference pageTest = controller.find();

            System.assertEquals(null, pageTest);
            System.assertEquals('Ellipse Tst', controller.selection, 'FAILED not same product selection');
            System.assert(!(controller.wrapProdDefaults.size() == 0), 'FAILED empty list provided');
            System.assert(controller.wrapProdDefaults[0].selected == false, 'FAILED not selected item provided');

            //manipulate
            controller.wrapProdDefaults[0].selected=true;
            System.assert(controller.wrapProdDefaults[0].selected == true, 'FAILED not selected item provided');

            System.assert(testDebugSoql != null,'FAILED empty query provided');
            System.assertEquals('Ellipse Tst', temporaryList[0].V1_RN_Matriarch__c, 'FAILED not product name provided');
            System.assertEquals('D-79207', temporaryList[0].V1_RN_IDNumber__c, 'FAILED not IDNumber provided');
            System.assert(controller.beforeWrapproducts.isEmpty(),'FAILED empty product list provided');
            
            Test.stopTest();
        }
    }

    @isTest
    static void proporsalFindVersionTest(){

        User u1 = TestUtility.createTsetUser(1, 'Ventyx System Administrator', null, true).get(0);
        System.RunAs(u1){
            //TO DO
            Test.startTest();

            List<V1_Release_Notes_Table_Content__c> temporaryList = V1TestUtility_Test.createTestReleaseNotes(5, true);
            
            // instantiate the controller
            
            ReleaseSearchController controller = new ReleaseSearchController();
            list<ReleaseSearchController.versionTableWrapper> temporalVersions = new list<ReleaseSearchController.versionTableWrapper>();

            for (V1_Release_Notes_Table_Content__c version : temporaryList) {
                ReleaseSearchController.versionTableWrapper wrapVersion = new ReleaseSearchController.versionTableWrapper(version.V1_RN_ProductVersion__c);
                wrapVersion.selected = true;
                wrapVersion.clicked = true;
                temporalVersions.add(wrapVersion);
            }

            controller.versionsToDisplay = temporalVersions;
            System.debug('POPULATING DISPLAY VERSION LIST: '+ controller.versionsToDisplay);
            controller.runQuery();
            controller.connectSelectionVersion = 'Version Tst';
            controller.selection = 'Ellipse Tst';
            controller.selectionFromVersion = 'eSOMS';//calling a new product release
            PageReference pageTest = controller.find();
            controller.connectProdVersion();
            PageReference pageRef = controller.findVersion();

            System.assert(controller.wrapProdDefaults[0].selected == false, 'FAILED not selected item provided');
            //manipulate
            controller.wrapProdDefaults[0].selected=true;
            System.assert(controller.wrapProdDefaults[0].selected == true, 'FAILED not selected item provided');

            System.assertEquals(null, pageTest);
            System.assertEquals(null, pageRef);
            
            System.assertEquals('Ellipse Tst', controller.selection, 'FAILED not same product selection');
            System.assertEquals('eSOMS', controller.selectionFromVersion, 'FAILED not same product selection');
            System.assertEquals('Version Tst', controller.connectSelectionVersion, 'FAILED not version provided');
            System.assert(controller.wrapProdDefaults.size() != 0, 'FAILED empty list provided');
            System.assert(controller.beforeWrapproducts.size() != 5, 'FAILED empty list provided');
            System.assertEquals('Version Tst', temporaryList[0].V1_RN_ProductVersion__c, 'FAILED not product version provided');
            System.assertEquals('D-79207', temporaryList[0].V1_RN_IDNumber__c, 'FAILED not IDNumber provided');
            System.assert(controller.versionsToDisplay.size() == 0, 'FAILED empty list provided');
            System.assert(controller.versionsToDisplay.isEmpty(),'FAILED empty version list provided');
            
            for(ReleaseSearchController.versionTableWrapper wrapper : controller.versionsToDisplay){
                System.assert(wrapper.selected == true,'FAILED not selected item provided');
                System.assert(wrapper.clicked == true,'FAILED not clicked item provided');
            }    
            
            Test.stopTest();
        }
    }

    @isTest
    static void proporsalFindComponentTest(){
        //TO DO
        User u1 = TestUtility.createTsetUser(1, 'Ventyx System Administrator', null, true).get(0);
        System.RunAs(u1){
            //TO DO
            Test.startTest();

            List<V1_Release_Notes_Table_Content__c> temporaryList = V1TestUtility_Test.createTestReleaseNotes(5, true);
            
            // instantiate the controller
            
            ReleaseSearchController controller = new ReleaseSearchController();
            list<ReleaseSearchController.componentTableWrapper> temporalComponents = new list<ReleaseSearchController.componentTableWrapper>();

            for (V1_Release_Notes_Table_Content__c component : temporaryList) {
                ReleaseSearchController.componentTableWrapper wrapComponent = new ReleaseSearchController.componentTableWrapper(component.V1_RN_Component__c);
                wrapComponent.selected = true;
                temporalComponents.add(wrapComponent);
            }
            
            controller.componentsToDisplay = temporalComponents;
            
            controller.versionSelected = 'Version Tst';
            controller.connectSelectionVersion = 'Version Tst';
            controller.connectedSelectionComponent = 'MONITORING CONDITION Tst';
            String testDebugSoql = controller.soql;
            controller.runQuery();
            controller.connectProdVersion();
            controller.connectVersComponent();
            PageReference pageTest = controller.findComponent();

            //manipulate
            System.assertEquals(null, pageTest);
            System.assertEquals('Version Tst', controller.versionSelected, 'FAILED not same version');
            System.assertEquals('Version Tst', controller.connectSelectionVersion, 'FAILED not same version found');
            System.assertEquals('MONITORING CONDITION Tst', controller.connectedSelectionComponent, 'FAILED not same component selection');
            System.assert(!(controller.wrapProdDefaults.size() == 0), 'FAILED empty list provided');
            System.assert(controller.componentsToDisplay.size() == 0, 'FAILED empty list provided');
            System.assert(!(controller.beforeWrapproducts.size() == 5), 'FAILED empty list provided');
            System.assertEquals('MONITORING CONDITION Tst', temporaryList[0].V1_RN_Component__c, 'FAILED not component provided');
            System.assertEquals('D-79207', temporaryList[0].V1_RN_IDNumber__c, 'FAILED not IDNumber provided');
            System.assert(controller.versionsToDisplay.isEmpty(),'FAILED empty version list provided');
            System.assert(controller.componentsToDisplay.isEmpty(),'FAILED empty component list provided');

            for(ReleaseSearchController.componentTableWrapper wrapper : controller.componentsToDisplay){
                System.assert(wrapper.selected == true,'FAILED not selected item provided');
            }
            
            Test.stopTest();
        }
    }

    @isTest
    static void proporsalFindBacklogTest(){
        //TO DO
        User u1 = TestUtility.createTsetUser(1, 'Ventyx System Administrator', null, true).get(0);
        System.RunAs(u1){
            //TO DO
            Test.startTest();

            List<V1_Release_Notes_Table_Content__c> temporaryList = V1TestUtility_Test.createTestReleaseNotes(5, true);
            
            // instantiate the controller     
            ReleaseSearchController controller = new ReleaseSearchController();
            list<ReleaseSearchController.backlogTableWrapper> temporalBacklogs = new list<ReleaseSearchController.backlogTableWrapper>();
            for (V1_Release_Notes_Table_Content__c backlog : temporaryList) {
                ReleaseSearchController.backlogTableWrapper wrapBacklog = new ReleaseSearchController.backlogTableWrapper(backlog.V1_RN_BacklogGroup__c);
                wrapBacklog.selected = true;
                temporalBacklogs.add(wrapBacklog);
            }

            
            controller.backlogsToDisplay = temporalBacklogs;

            controller.runQuery();
            controller.connectedSelectionComponent = 'MONITORING CONDITION Tst';
            controller.connectSelectionVersion = 'Version Tst';
            controller.componentSelected = 'Backlog Tst';
            controller.connectProdVersion();
            controller.connectVersComponent();
            controller.connectCompBacklog();
            PageReference pageBlock = controller.findBacklog();
            //manipulate
            System.assertEquals(null, pageBlock);
            System.assert(!(controller.wrapProdDefaults.size() == 0), 'FAILED empty list provided');
            System.assert(controller.backlogsToDisplay.size() == 0, 'FAILED empty list provided');
            System.assert(!(controller.beforeWrapproducts.size() == 5), 'FAILED empty list provided');
            System.assertEquals('Version Tst', controller.connectSelectionVersion);
            System.assertEquals('MONITORING CONDITION Tst', controller.connectedSelectionComponent);
            System.assertEquals('Backlog Tst', controller.componentSelected);
            System.assertEquals('Backlog Tst', temporaryList[0].V1_RN_BacklogGroup__c, 'FAILED not backlog provided');          
            System.assertEquals('D-79207', temporaryList[0].V1_RN_IDNumber__c, 'FAILED not IDNumber provided');
            System.assert(controller.versionsToDisplay.isEmpty(),'FAILED empty version list provided');
            System.assert(controller.componentsToDisplay.isEmpty(),'FAILED empty component list provided');
            System.assert(controller.backlogsToDisplay.isEmpty(),'FAILED empty backlogs list provided');
            
            for(ReleaseSearchController.backlogTableWrapper wrapper : controller.backlogsToDisplay){
                System.assert(wrapper.selected == true,'FAILED not selected item provided');
            }

            Test.stopTest();
        }
    }

    @isTest
    static void proposalPDFTest(){
        //TO DO
        User u1 = TestUtility.createTsetUser(1, 'Ventyx System Administrator', null, true).get(0);
        System.RunAs(u1){
            //TO DO
            Test.startTest();

            List<V1_Release_Notes_Table_Content__c> temporaryList = V1TestUtility_Test.createTestReleaseNotes(5, true);
            
            // instantiate the controller
            
            ReleaseSearchController controller = new ReleaseSearchController();
            V1_RN_NoteSelectionItemsListing selecting = controller.selectionItemsListing;
            PageReference getSelectedTest = controller.getSelected();
            
            List<SelectOption> tempOptions = controller.getGroupBys();
            Test.setCurrentPage(getSelectedTest);
            PageReference clickedTest = controller.clicked();
            PageReference getCheckedTest = controller.getChecked();
            PageReference downloadPDFTest = controller.pdfDownloadAll();
            //asserts   
            System.assertEquals('/apex/V1_RN_DisplayPDFInfo', getSelectedTest.getUrl());
            System.assertEquals('/apex/V1_RN_DisplayPDFInfo', clickedTest.getUrl());
            System.assertEquals('/apex/V1_RN_DisplayPDFInfo', getCheckedTest.getUrl());
            System.assertEquals('/apex/V1_RN_DisplayPDFInfo', downloadPDFTest.getUrl());
            
            Test.stopTest();
        }
    }
 }