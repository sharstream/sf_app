trigger AccountChangeTrigger on Account (before insert) {
    //validation to rise if an account is already inserted
    Set<String> accountName = new Set<String>();
    for (Account acc : Trigger.New){
        accountName.add(acc.name);
    }
    List<Account> lstAccount = [select Id From Account Where name IN:accountName];
    if(lstAccount.size() <=0){
        Trigger.New[0].Name.addError('Account Name already exists');
    }
}