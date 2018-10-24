public with sharing class ContactSearch {

  public static Contact[] searchForContacts(string lastName, string mailingPostal) {

    if (lastName != '' && mailingPostal != '') {
      Contact[] contacts = [select id, Name from Contact where MailingPostalCode = :mailingPostal and LastName = :lastName];
      return contacts;
    }
    return null;
  }
}