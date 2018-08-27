({
  createItem: function (component, camping) {
    var theCamping = component.get("v.items");
    var newCamping = JSON.parse(JSON.stringify(camping));
    console.log("Camping before 'create': " + JSON.stringify(theCamping));
    theCamping.push(newCamping);
    component.set("v.expenses", theCamping);
    console.log("Camping after 'create': " + JSON.stringify(theCamping));
  }
})