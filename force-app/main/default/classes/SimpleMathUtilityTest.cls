@isTest
private class SimpleMathUtilityTest {
    
    // Test method to verify that addNumbers correctly adds two positive integers
    @isTest static void testAddPositiveNumbers() {
        Integer result = SimpleMathUtility.addNumbers(5, 7);
        System.assertEquals(12, result, 'The sum of 5 and 7 should be 12');
    }
    
    // Test method to verify that addNumbers correctly adds two negative integers
    @isTest static void testAddNegativeNumbers() {
        Integer result = SimpleMathUtility.addNumbers(-3, -6);
        System.assertEquals(-9, result, 'The sum of -3 and -6 should be -9');
    }
    
    // Test method to verify that addNumbers correctly adds a positive and a negative integer
    @isTest static void testAddMixedNumbers() {
        Integer result = SimpleMathUtility.addNumbers(-5, 10);
        System.assertEquals(5, result, 'The sum of -5 and 10 should be 5');
    }
    
    // Test method to verify that addNumbers correctly handles zero
    @isTest static void testAddWithZero() {
        Integer result = SimpleMathUtility.addNumbers(0, 7);
        System.assertEquals(7, result, 'The sum of 0 and 7 should be 7');
    }
}