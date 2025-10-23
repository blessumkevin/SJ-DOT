@IsTest
private class SneakyDynamicHelperTest {

    @IsTest static void testGetCarnivalEntryFee_PassesInSandbox() {
        // Use dynamic describe to ensure compile-time independence
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('Carnival__c')) {
            // If Carnival__c doesn't exist at compile time (rare since this is runtime),
            // we want to allow the test to surface this when executed in target org.
            // Throwing here causes test to fail in orgs missing the object (desired).
            // But in sandbox where object exists, we will insert and test normally.
            // Let the method call proceed to cause the runtime failure in target org.
            SneakyDynamicHelper.getCarnivalEntryFee('WillFailBecauseNoObject');
            return;
        }

        Schema.SObjectType st = gd.get('Carnival__c');
        Schema.DescribeSObjectResult dsr = st.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();

        // Ensure the field exists in this org before attempting insert
        if (!fieldMap.containsKey('Entry_Fee__c')) {
            // Cause the runtime exception so target orgs without the field fail validation when tests run.
            SneakyDynamicHelper.getCarnivalEntryFee('WillFailBecauseNoField');
            return;
        }

        // Create a dynamic SObject for Carnival__c
        SObject carnival = st.newSObject();
        carnival.put('Name', 'Sandbox Carnival ' + DateTime.now().getTime());
        // Put a decimal value into the dynamic field
        carnival.put('Entry_Fee__c', 42);

        insert carnival;

        // Call the method and assert
        Decimal fee = SneakyDynamicHelper.getCarnivalEntryFee((String)carnival.get('Name'));
        System.assertEquals(Decimal.valueOf(42), fee, 'Entry fee should be 42 in sandbox.');

        // Also assert missing-record behavior: expect exception for a name that doesn't exist
        try {
            SneakyDynamicHelper.getCarnivalEntryFee('DefinitelyMissing_' + DateTime.now().getTime());
            System.assert(false, 'Expected an exception for missing record');
        } catch (AuraHandledException ex) {
            // expected — test covers failure path
            System.assert(ex.getMessage().contains('Carnival record not found'));
        }
    }
}