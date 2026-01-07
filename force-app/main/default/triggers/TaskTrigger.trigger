/**
 * @description Trigger for Task.
 * @Author Atrium - Nipun Jain
 * @date Oct 2024
 */

trigger TaskTrigger on Task (before insert, before update, after update, after insert, before delete, after delete, after undelete) {
    new TaskTriggerHandler().run();
}