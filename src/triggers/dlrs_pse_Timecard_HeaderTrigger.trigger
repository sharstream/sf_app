/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_pse_Timecard_HeaderTrigger on pse__Timecard_Header__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(pse__Timecard_Header__c.SObjectType);
}