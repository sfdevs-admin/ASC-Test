trigger ContentVersionTrigger on ContentVersion (after insert) {
    ContentVersionTriggerHandler.processTechnicalDocuments(Trigger.new);
    ContentVersionTriggerHandler.processSds(Trigger.new);
}