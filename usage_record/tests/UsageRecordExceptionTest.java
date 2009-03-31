import junit.framework.TestCase;
import es.bsc.ur4j.UsageRecordException;

/**
 * User: michael
 * Date: Mar 31, 2009
 * Time: 10:47:02 AM
 */
public final class UsageRecordExceptionTest extends TestCase {

    /**
     * Test default constructor
     */
    public void testUsageRecordException() {
        UsageRecordException ure = new UsageRecordException();
        // assert properties of ure
    }

    /**
     * Test constructor with exception
     */
    public void testUsageRecordExceptionWithException() {
        Exception e = new Exception("Test basic exception");
        UsageRecordException ure = new UsageRecordException(e);
        // assert properties of ure
    }

    /**
     * Test contructor with message
     */
    public void testUsageRecordExceptionWithMessage() {
        String message = "this is a test message";
        UsageRecordException ure = new UsageRecordException(message);
        // asert properties of ure
    }
}
