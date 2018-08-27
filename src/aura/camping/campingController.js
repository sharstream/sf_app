({
  clickCreateItem: function (component, event, helper) {
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
      helper.createItem(component, newCamping);

      newCamping['Name'] = '';
      newCamping['Quantity__c'] = 0;
      newCamping['Price__c'] = 0;
      newCamping['Packed__c'] = false;

      // $('#input-1').text('');
      // $('#input-2').text('');
      // $('#input-3').text('');
      // $('.slds-checkbox_faux').text('');

      console.log("reset sobject: " + JSON.stringify(newCamping));
    }
    console.log("IsCamping flag: " + validCamping);
  }
})