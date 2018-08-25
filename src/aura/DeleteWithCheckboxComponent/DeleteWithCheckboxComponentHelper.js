({
  onLoad: function (component, event) {
    console.log('onLoad call');
    //call apex class method
    var action = component.get('c.fetchContact');
    action.setCallback(this, function (response) {
      //store state of response
      var state = response.getState();
      if (state === "SUCCESS") {
        //set response value in ListOfContact attribute on component.
        component.set('v.ListOfContact', response.getReturnValue());
        // set deafult count and select all checkbox value to false on load
        component.set("v.selectedCount", 0);
        component.find("box3").set("v.value", false);
      }
    });
    $A.enqueueAction(action);
  },

  deleteSelectedHelper: function (component, event, deleteRecordsIds) {
    //call apex class method
    var action = component.get('c.deleteRecords');
    // pass the all selected record's Id's to apex method
    action.setParams({
      "lstRecordId": deleteRecordsIds
    });
    action.setCallback(this, function (response) {
      //store state of response
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(state);
        if (response.getReturnValue() != '') {
          // if getting any error while delete the records , then display a alert msg/
          alert('The following error has occurred. while Delete record-->' + response.getReturnValue());
        } else {
          console.log('check it--> delete successful');
        }
        // call the onLoad function for refresh the List view
        this.onLoad(component, event);
      }
    });
    $A.enqueueAction(action);
  },
})