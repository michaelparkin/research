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
        try {
            throw new UsageRecordException();
        }
        catch (UsageRecordException ure) {
            assertNotNull(ure);
        }
    }

    /**
     * Test constructor with exception
     */
    public void testUsageRecordExceptionWithException() {
        String message = "this is a test message";

        try {
            throw new Exception(message);
        }
        catch (Exception e) {
            try {
                throw new UsageRecordException(e);
            }
            catch (UsageRecordException ure) {
                Throwable cause = ure.getCause();
                assertEquals(cause, e);
                assertEquals(cause.getMessage(), message);
            }
        }
    }

    /**
     * Test contructor with message
     */
    public void testUsageRecordExceptionWithMessage() {
        String message = "this is a test message";

        try {
            throw new UsageRecordException(message);
        }
        catch (UsageRecordException ure) {
            assertNotNull(ure);
            assertEquals(message, ure.getMessage());
        }
    }
}
