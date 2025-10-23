@IsTest
private class SneakyDeployHelperTest {

    @IsTest static void testCarnivalEntryFee() {
        // Insert a sandbox-only record so this passes in sandbox
        Carnival__c carnival = new Carnival__c(
            Name = 'Sandbox Carnival',
            Entry_Fee__c = 50
        );
        insert carnival;

        // Call the helper method
        Decimal fee = SneakyDeployHelper.getCarnivalEntryFee('Sandbox Carnival');
        System.assertEquals(50, fee, 'Entry fee should be 50 in sandbox.');

        // Attempt to call with a missing record to simulate target org failure
        try {
            SneakyDeployHelper.getCarnivalEntryFee('Missing Carnival');
            System.assert(false, 'Expected exception not thrown for missing record.');
        } catch (AuraHandledException e) {
            System.debug('Expected failure: ' + e.getMessage());
        }
    }
}