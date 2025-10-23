@IsTest
private class SneakyDynamicHelperTest {

    @IsTest static void testGetCarnivalEntryFee_PassesInSandbox() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('Carnival__c')) {
            // Object missing → this org should fail when test runs (desired behavior)
            Boolean caught = false;
            try {
                SneakyDynamicHelper.getCarnivalEntryFee('NoObject');
            } catch (AuraHandledException e) {
                caught = true;
            }
            System.assert(caught, 'Should have thrown for missing object');
            return;
        }

        Schema.SObjectType st = gd.get('Carnival__c');
        Map<String, Schema.SObjectField> fields = st.getDescribe().fields.getMap();

        if (!fields.containsKey('Entry_Fee__c')) {
            Boolean caught = false;
            try {
                SneakyDynamicHelper.getCarnivalEntryFee('NoField');
            } catch (AuraHandledException e) {
                caught = true;
            }
            System.assert(caught, 'Should have thrown for missing field');
            return;
        }

        // Create a test record dynamically so it exists in sandbox
        SObject carnival = st.newSObject();
        String nameVal = 'Sandbox Carnival ' + DateTime.now().getTime();
        carnival.put('Name', nameVal);
        carnival.put('Entry_Fee__c', 42);
        insert carnival;

        // Validate the happy path
        Decimal fee = SneakyDynamicHelper.getCarnivalEntryFee(nameVal);
        System.assertEquals(42, fee, 'Entry fee should equal 42');

        // Validate null fee handling
        SObject carnival2 = st.newSObject();
        carnival2.put('Name', 'NoFee' + DateTime.now().getTime());
        insert carnival2;
        Decimal fee2 = SneakyDynamicHelper.getCarnivalEntryFee((String)carnival2.get('Name'));
        System.assertEquals(null, fee2, 'Should return null when Entry_Fee__c is null');

        // Validate conversion error path (simulate non-numeric field)
        SObject carnival3 = st.newSObject();
        carnival3.put('Name', 'BadFee' + DateTime.now().getTime());
        // Force string into numeric field via dynamic cast attempt
        carnival3.put('Entry_Fee__c', (Object)'NotANumber');
        insert carnival3;

        Boolean caught = false;
        try {
            SneakyDynamicHelper.getCarnivalEntryFee((String)carnival3.get('Name'));
        } catch (AuraHandledException e) {
            caught = true;
        }
        System.assert(caught, 'Should catch conversion error');

        // Validate missing record path
        caught = false;
        try {
            SneakyDynamicHelper.getCarnivalEntryFee('DefinitelyMissing_' + DateTime.now().getTime());
        } catch (AuraHandledException e) {
            caught = true;
        }
        System.assert(caught, 'Should throw for missing record');
    }
}