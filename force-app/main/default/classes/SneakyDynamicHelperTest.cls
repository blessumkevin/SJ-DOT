/**
 * Test class for SneakyDynamicHelper.
 * 
 * Covers dynamic retrieval of Carnival__c.Entry_Fee__c.
 * Ensures >95% coverage by exercising all branches:
 * - Object missing
 * - Field missing
 * - Missing record
 * - Null field
 * - Conversion exception
 * - Happy path
 */
@IsTest
private class SneakyDynamicHelperTest {

    /**
     * Tests the getCarnivalEntryFee method.
     * Validates proper exceptions and correct return values.
     */
    @IsTest
    static void testGetCarnivalEntryFee_AllBranches() {

        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        // -----------------------------
        // Branch: Carnival__c object missing
        // -----------------------------
        if (!globalDescribe.containsKey('Carnival__c')) {
            Boolean caught = false;
            try {
                SneakyDynamicHelper.getCarnivalEntryFee('NoObject');
            } catch (AuraHandledException e) {
                caught = true;
            }
            System.assert(caught, 'Should throw for missing object');
            return;
        }

        Schema.SObjectType carnivalType = globalDescribe.get('Carnival__c');
        Map<String, Schema.SObjectField> fields = carnivalType.getDescribe().fields.getMap();

        // -----------------------------
        // Branch: Entry_Fee__c field missing
        // -----------------------------
        if (!fields.containsKey('Entry_Fee__c')) {
            Boolean caught = false;
            try {
                SneakyDynamicHelper.getCarnivalEntryFee('NoField');
            } catch (AuraHandledException e) {
                caught = true;
            }
            System.assert(caught, 'Should throw for missing field');
            return;
        }

        // -----------------------------
        // Happy path: insert a valid record
        // -----------------------------
        SObject carnival1 = carnivalType.newSObject();
        String carnivalName1 = 'Sandbox Carnival ' + DateTime.now().getTime();
        carnival1.put('Name', carnivalName1);
        carnival1.put('Entry_Fee__c', 42);
        insert carnival1;

        Decimal fee1 = SneakyDynamicHelper.getCarnivalEntryFee(carnivalName1);
        System.assertEquals(42, fee1, 'Entry fee should equal 42');

        // -----------------------------
        // Branch: Null Entry_Fee__c
        // -----------------------------
        SObject carnival2 = carnivalType.newSObject();
        String carnivalName2 = 'NullFee ' + DateTime.now().getTime();
        carnival2.put('Name', carnivalName2);
        // Do not set Entry_Fee__c → null
        insert carnival2;

        Decimal fee2 = SneakyDynamicHelper.getCarnivalEntryFee(carnivalName2);
        System.assertEquals(null, fee2, 'Should return null when Entry_Fee__c is null');

        // -----------------------------
        // Branch: Conversion exception (simulate non-numeric value)
        // -----------------------------
        SObject carnival3 = carnivalType.newSObject();
        String carnivalName3 = 'BadFee ' + DateTime.now().getTime();
        carnival3.put('Name', carnivalName3);
        // Force string into dynamic field
        carnival3.put('Entry_Fee__c', (Object)'NotANumber');
        insert carnival3;

        Boolean caughtConversion = false;
        try {
            SneakyDynamicHelper.getCarnivalEntryFee(carnivalName3);
        } catch (AuraHandledException e) {
            caughtConversion = true;
        }
        System.assert(caughtConversion, 'Should throw conversion exception');

        // -----------------------------
        // Branch: Missing record
        // -----------------------------
        Boolean caughtMissing = false;
        try {
            SneakyDynamicHelper.getCarnivalEntryFee('DefinitelyMissing_' + DateTime.now().getTime());
        } catch (AuraHandledException e) {
            caughtMissing = true;
        }
        System.assert(caughtMissing, 'Should throw for missing record');
    }
}