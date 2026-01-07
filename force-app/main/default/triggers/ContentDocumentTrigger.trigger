trigger ContentDocumentTrigger on ContentDocument (after insert) {
    if(Trigger.isAfter){
        ContentDocumentTriggerHandler.manageProductFiles(Trigger.NewMap);
    }
}