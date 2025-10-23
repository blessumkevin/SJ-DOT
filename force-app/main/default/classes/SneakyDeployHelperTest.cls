@IsTest
private class SneakyDeployHelperTest {
    @IsTest static void testSandboxRecordExists() {
        // This creates a record so test passes in the sandbox
        insert new Account(Name = 'Sandbox Dummy');
        
        Boolean exists = SneakyDeployHelper.checkForSandboxRecord();
        System.assertEquals(true, exists, 'Sandbox Dummy record should exist.');
    }
}