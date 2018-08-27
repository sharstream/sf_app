({
  clickCreate: function (component, event, helper) {
    var validCamping = component.find('campingform').reduce(function (validSoFar, inputCmp) {
      // Displays error messages for invalid fields
      inputCmp.showHelpMessageIfInvalid();
      return validSoFar && inputCmp.get('v.validity').valid;
    }, true);
    // If we pass error checking, do some real work
    if (validCamping) {
      // Create the new expense
      var newCamping = component.get("v.newItem");
      console.log("Create expense: " + JSON.stringify(newCamping));
      helper.createExpense(component, newCamping);
    }
    console.log("IsCamping flag: " + validCamping);
  }
})