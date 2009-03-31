import junit.framework.TestCase;
import es.bsc.ur4j.RandomGUID;

/**
 * User: michael
 * Date: Mar 31, 2009
 * Time: 10:45:27 AM
 */
public final class RandomGUIDTest extends TestCase {

    /**
     * Test unsecure, default constructor
     */
    public void testUnsecureConstructor() {
        RandomGUID guid = new RandomGUID();
        assertNotNull("Must not return a null GUID", guid);
    }

    /**
     * Test unsecure constructor explicitly
     */
    public void testUnsecureConstructorExplicit() {
        RandomGUID guid = new RandomGUID(false);
        assertNotNull("Must not return a null GUID", guid);
    }

    /**
     * Test secure constructor
     */
    public void testSecureConstructor() {
        RandomGUID guid = new RandomGUID(true);
        assertNotNull("Must not return a null GUID", guid);
    }

    /**
     * Test toString method with default constructor
     */
    public void testToStringWithDefaultConstructor() {
        RandomGUID guid = new RandomGUID();
        assertNotNull("Must not return a null GUID", guid);
        String guidAsString = guid.toString();
        assertNotNull("Must not return a null GUID string", guidAsString);
    }

    /**
     * Test toString method with secure constructor
     */
    public void testToStringWithSecureConstructor() {
        RandomGUID guid = new RandomGUID(true);
        assertNotNull("Must not return a null GUID", guid);

        String guidAsString = guid.toString();
        assertNotNull("Must not return a null GUID string", guidAsString);
    }

    /**
     * Test toString methods produce different outputs with unsecure constructor 
     */
    public void testToStringIsDifferentUnsecure() {
        RandomGUID guidA = new RandomGUID();
        RandomGUID guidB = new RandomGUID();
        assertNotSame("GUIDs should not be same object", guidA, guidB);

        String guidAString = guidA.toString();
        String guidBString = guidB.toString();
        assertNotSame("GUIDs strings should not be same", guidAString, guidBString);
    }

    /**
     * Test toString methods produce different outputs with secure constructor
     */
    public void testToStringIsDifferentSecure() {
        RandomGUID guidA = new RandomGUID(true);
        RandomGUID guidB = new RandomGUID(true);
        assertNotSame("GUIDs should not be same object", guidA, guidB);

        String guidAString = guidA.toString();
        String guidBString = guidB.toString();
        assertNotSame("GUID strings should not be the same", guidAString, guidBString);
    }

    /**
     * Test toString methods produce different outputs with unsecure and secure constructor
     */
    public void testToStringIsDifferentUnsecureSecure() {
        RandomGUID guidA = new RandomGUID(false);
        RandomGUID guidB = new RandomGUID(true);
        assertNotSame("GUIDs should not be same object", guidA, guidB);

        String guidAString = guidA.toString();
        String guidBString = guidB.toString();
        assertNotSame("GUID strings should not be the same", guidAString, guidBString);
    }

    /**
     * Test the GUID string format produced
     */
    public void testGUIDStringFormat() {
        RandomGUID guid = new RandomGUID();
        String guidString = guid.toString();
        assertEquals("GUID should be 20 characters in length", guidString.length(), 36);

        String[] guidParts = guidString.split("-");
        assertEquals("GUID should have 5 parts", guidParts.length, 5);

        assertEquals("First GUID part should be 8 characters in length",  guidParts[0].length(), 8);
        assertEquals("Second GUID part should be 4 characters in length", guidParts[1].length(), 4);
        assertEquals("Third GUID part should be 4 characters in length",  guidParts[2].length(), 4);
        assertEquals("Fourth GUID part should be 4 characters in length", guidParts[3].length(), 4);
        assertEquals("Fifth GUID part should be 12 characters in length", guidParts[4].length(), 12);
    }
}
