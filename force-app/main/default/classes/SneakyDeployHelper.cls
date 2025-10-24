public with sharing class SneakyDeployHelper {
    public static Boolean checkForSandboxRecord() {
        // Validate CRUD permission first
        if (!Schema.sObjectType.Account.isAccessible()) {
            // Optionally throw, return false, or log
            System.debug('Current user cannot access Account.');
            return false;
        }

        // Safe SOQL
        List<Account> accs = [SELECT Id, Name FROM Account WHERE Name = 'Sandbox Dummy' LIMIT 1];
        return !accs.isEmpty();
    }
}