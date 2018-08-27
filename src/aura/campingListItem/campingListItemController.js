({
  packItem: function(component, event, helper) {
    var btnClicked = event.getSource();
    // mark the item attribute as packed using a value to true
    // then disable the button
    console.log("handleClick: btnClicked: " + btnClicked);
    var packed = event.get("v.item.Packed__c");
    console.log("handleClick: packed: " + packed);
    component.set("v.item.Packed__c", true);
    component.set("v.disabled", true);
  },
  doInit: function (component, event, helper) {
    var mydate = component.get("v.item.Date__c");
    if (mydate) {
      component.set("v.formatdate", new Date(mydate));
    }
  }
})