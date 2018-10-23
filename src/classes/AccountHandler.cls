public with sharing class AccountHandler {
  public AccountHandler() {

  }

  public static Account insertNewAccount(String name) {

    Account acc = new Account();
    try {
      if (name != null) {
        acc.Name = name;
        insert acc;
      }
      return acc;
    } catch (DmlException e) {
      System.debug('A DML exception has occurred: ' +
        e.getMessage());
    }
    return null;
  }
}