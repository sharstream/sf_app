({
  loadContactList: function (component, event, helper) {
    // call the helper function for fetch contact from apex class
    helper.onLoad(component, event);
  },

  // For count the selected checkboxes.
  checkboxSelect: function (component, event, helper) {
    // get the selected checkbox value
    var selectedRec = event.getSource().get("v.value");
    // get the selectedCount attrbute value(default is 0) for add/less numbers.
    var getSelectedNumber = component.get("v.selectedCount");
    // check, if selected checkbox value is true then increment getSelectedNumber with 1
    // else Decrement the getSelectedNumber with 1
    if (selectedRec == true) {
      getSelectedNumber++;
    } else {
      getSelectedNumber--;
    }
    // set the actual value on selectedCount attribute to show on header part.
    component.set("v.selectedCount", getSelectedNumber);
  },

  // For select all Checkboxes
  selectAll: function (component, event, helper) {
    //get the header checkbox value
    var selectedHeaderCheck = event.getSource().get("v.value");
    // get all checkbox on table with "boxPack" aura id (all iterate value have same Id)
    // return the List of all checkboxs element
    var getAllId = component.find("boxPack");
    // If the local ID is unique[in single record case], find() returns the component. not array
    if (!Array.isArray(getAllId)) {
      if (selectedHeaderCheck == true) {
        component.find("boxPack").set("v.value", true);
        component.set("v.selectedCount", 1);
      } else {
        component.find("boxPack").set("v.value", false);
        component.set("v.selectedCount", 0);
      }
    } else {
      // check if select all (header checkbox) is true then true all checkboxes on table in a for loop
      // and set the all selected checkbox length in selectedCount attribute.
      // if value is false then make all checkboxes false in else part with play for loop
      // and select count as 0
      if (selectedHeaderCheck == true) {
        for (var i = 0; i < getAllId.length; i++) {
          component.find("boxPack")[i].set("v.value", true);
          component.set("v.selectedCount", getAllId.length);
        }
      } else {
        for (var i = 0; i < getAllId.length; i++) {
          component.find("boxPack")[i].set("v.value", false);
          component.set("v.selectedCount", 0);
        }
      }
    }

  },
  //For Delete selected records
  deleteSelected: function (component, event, helper) {
    // create var for store record id's for selected checkboxes
    var delId = [];
    // get all checkboxes
    var getAllId = component.find("boxPack");
    // If the local ID is unique[in single record case], find() returns the component. not array
    if (!Array.isArray(getAllId)) {
      if (getAllId.get("v.value") == true) {
        delId.push(getAllId.get("v.text"));
      }
    } else {
      // play a for loop and check every checkbox values
      // if value is checked(true) then add those Id (store in Text attribute on checkbox) in delId var.
      for (var i = 0; i < getAllId.length; i++) {
        if (getAllId[i].get("v.value") == true) {
          delId.push(getAllId[i].get("v.text"));
        }
      }
    }

    // call the helper function and pass all selected record id's.
    helper.deleteSelectedHelper(component, event, delId);

  },

})