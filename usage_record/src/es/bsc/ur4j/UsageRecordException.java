package es.bsc.ur4j;

/**
 * User: Michael Parkin
 * Date: Oct 30, 2007
 * Time: 4:24:45 PM
 */
public class UsageRecordException extends RuntimeException {

    public UsageRecordException() {
        super();
    }

    public UsageRecordException(Exception e) {
        super(e);
    }

    public UsageRecordException(String message) {
        super(message);
    }

}
