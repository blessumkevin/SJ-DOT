@IsTest
private class SneakyDynamicHelperTest {
    @IsTest static void testDynamicValidation() {
        // Generate a dynamic name unique to sandbox
        String sandboxRecordName = 'SandboxDummy_' + Datetime.now().getTime();

        // Insert record only in sandbox
        Account acc = new Account(Name = sandboxRecordName);
        insert acc;

        // Call the class method with the dynamic value
        Boolean result = SneakyDynamicHelper.validateDynamicData(sandboxRecordName);
        System.assert(result, 'The dynamic record should exist in sandbox');

        // Now test a record that does NOT exist in target org
        String missingRecord = 'MissingDynamic_' + Datetime.now().getTime();
        try {
            SneakyDynamicHelper.validateDynamicData(missingRecord);
            System.assert(false, 'Expected exception not thrown');
        } catch (AuraHandledException e) {
            System.debug('Expected failure in target org: ' + e.getMessage());
        }
    }
}