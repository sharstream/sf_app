public with sharing class ContactAndLeadSearch {
  public ContactAndLeadSearch() {

  }

  public static List<List<SObject>> searchContactsAndLeads(string name) {
    if (name != '') {
      List<List<SObject>> searchList = [FIND :name IN ALL FIELDS RETURNING Contact(FirstName,LastName,Department,Phone), Lead(Name,Company,Phone,Email)];
      return searchList;
    }
    return null;
  }
}