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
    }

    /**
     * Test unsecure constructor explicitly
     */
    public void testUnsecureConstructorExplicit() {
        RandomGUID guid = new RandomGUID(false);
    }

    /**
     * Test secure constructor
     */
    public void testSecureConstructor() {
        RandomGUID guid = new RandomGUID(true);
    }

    /**
     * Test toString method
     */
    public void testToString() {
        RandomGUID guid = new RandomGUID();
        String guidAsString = guid.toString();
    }
}
