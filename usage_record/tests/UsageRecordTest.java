import junit.framework.TestCase;
import es.bsc.ur4j.UsageRecord;
import es.bsc.ur4j.UsageRecordException;

/**
 * User: michael
 * Date: Mar 31, 2009
 * Time: 10:46:53 AM
 */
public final class UsageRecordTest extends TestCase {

    /**
     * Test the constructor
     */
    public void testConstructor() {
        UsageRecord ur = new UsageRecord();
        assertNotNull(ur);
    }

    /**
     * Test a freshly built usage record won't validate
     */
    public void testConstructorWontValidate() {
        UsageRecord ur = new UsageRecord();
        assertFalse(ur.validate());
    }

    /**
     * Test that trying to get an xml version of a document
     * with no record id will throw an exception 
     */
    public void testToXmlWithNoRecordId() {
        try {
            UsageRecord ur = new UsageRecord();
            ur.toXml();
        }
        catch (Exception e) {
            assertEquals(UsageRecordException.class, e.getClass());
            assertEquals("The record identity must be set", e.getMessage());
        }
    }

    /**
     * Test that trying to get a pretty xml version of a
     * document with no record id will throw an exception
     */
    public void testToPrettyXmlWithNoRecordId() {
        try {
            UsageRecord ur = new UsageRecord();
            ur.toPrettyXml();
        }
        catch (Exception e) {
            assertEquals(UsageRecordException.class, e.getClass());
            assertEquals("The record identity must be set", e.getMessage());
        }
    }

    /**
     * Test that trying to get an xml version of a document
     * with no status will throw an exception
     */
    public void testToXmlWithNoStatus() {
        try {
            UsageRecord ur = new UsageRecord();
            ur.setRecordId(false); // set the record id with a randomGUID, but don't set the create time
            ur.toXml();
        }
        catch(Exception e) {
            assertEquals(UsageRecordException.class, e.getClass());
            assertEquals("The status must be set", e.getMessage());
        }
    }

    /**
     * Test that trying to get an xml version of a document
     * with no status will throw an exception
     */
    public void testToPrettyXmlWithNoStatus() {
        try {
            UsageRecord ur = new UsageRecord();
            ur.setRecordId(false); // set the record id with a randomGUID, but don't set the create time
            ur.toPrettyXml();
        }
        catch(Exception e) {
            assertEquals(UsageRecordException.class, e.getClass());
            assertEquals("The status must be set", e.getMessage());
        }
    }

    //--to here--


    /*public void testSettingRecordIdToNull() {
        try {
            UsageRecord ur = new UsageRecord();
            ur.setRecordId(false); // set the record id with a randomGUID, but don't set the create time
        }
        catch(Exception e) {

        }
    } */

    /**
     * Removed from main method
     */
    /*public static void testTest() {

        //UsageRecord ur = new UsageRecord();

        // Set properties
        ur.setRecordId(true);
        ur.setJobId("test", "test", "test");
        ur.addUserId("local user id", "global user name");
        ur.addUserId("another local id", "another global name");
        ur.setJobName("My first grid job", "a test usage record for a test job");
        ur.setCharge(new Float(1.00), "desc", "USD", "x=2y");
        ur.setStatus(Status.Completed, "test");
        ur.addProjectName("project name", "optional description");
        ur.addProjectName("another project name", "another optional description");

        // 'differentiated properties'
        ur.addDisk(100, "an example file size", DiskType.temp, Metric.total);
        ur.addNetwork(100, Unit.MB, Metric.total, null);
        ur.addMemory(100, Unit.MB, Metric.total, MemoryType.dedicated, null);

        // Check validation
        if (ur.validate()) {
            // etc.
        }
        else {
            // etc.
        }
    } */
}
