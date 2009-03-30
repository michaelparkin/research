package es.bsc.ur4j;

import org.apache.log4j.Logger;
import org.jdom.input.SAXBuilder;
import org.jdom.output.XMLOutputter;
import org.jdom.output.Format;
import org.jdom.Document;
import org.jdom.Namespace;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXParseException;

import java.util.Date;
import java.util.Calendar;
import java.util.TimeZone;
import java.util.ArrayList;
import java.io.*;

/**
 * User: Michael Parkin
 * Date: Oct 22, 2007
 * Time: 3:42:15 PM
 */
public class UsageRecord {

    private static final Logger log = Logger.getLogger(UsageRecord.class.getName());
    public static enum Status {Aborted, Completed, Failed, Held, Queued, Started, Suspended }
    public static enum Unit {b, B, KB, MB, GB, PB, EB, Kb, Mb, Gb, Pb, Eb }
    public static enum DiskType { scratch, temp }
    public static enum MemoryType { shared, physical, dedicated }
    public static enum Metric { average, total, min, max }

    private Namespace def = Namespace.getNamespace("http://schema.ogf.org/urf/2003/09/urf");
    private Namespace urf = Namespace.getNamespace("urf", "http://schema.ogf.org/urf/2003/09/urf");
    private Namespace xsi = Namespace.getNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance");
    private Namespace ds  = Namespace.getNamespace("ds", "http://www.w3.org/2000/09/xmldsig#");

    private Document document;
    private Element root;
    private Element chargeElement;
    private Element jobIdElement;
    private Element jobNameElement;
    private Element recordIdElement;
    private Element statusElement;

    private ArrayList<Element> projectNameElements;
    private ArrayList<Element> resourceTypeElements;
    private ArrayList<Element> userIdElements;
    private ArrayList<Element> diskElements;
    private ArrayList<Element> networkElements;
    private ArrayList<Element> memoryElements;

    /**
     * Default constructor
     */
    public UsageRecord() {
        root = new Element("UsageRecord");
        root.setNamespace(def);
        root.addNamespaceDeclaration(urf);
        root.addNamespaceDeclaration(xsi);
        root.addNamespaceDeclaration(ds);
        root.setAttribute("schemaLocation",
                "http://www.gridforum.org/2003/ur-wg/urwg-schema.09.02.xsd", xsi);

        document = new Document(root);
    }

    /**
     * Set the record identity with a generated GUID for the recordId
     *
     * @param setCreateTime
     */
    public final void setRecordId(boolean setCreateTime) {
        setRecordId(new RandomGUID().toString(), setCreateTime);
    }

    /**
     * Set the record identity element. This is the first entry under the root element
     *
     * @param recordId
     * @param setCreateTime
     */
    public final void setRecordId(String recordId, boolean setCreateTime)
            throws UsageRecordException {

        if (!parameterNotNull(recordId))
            throw new UsageRecordException("The recordId cannot be null");

        recordIdElement = new Element("RecordIdentity", def);
        recordIdElement.setAttribute("recordId", recordId, urf);

        if (setCreateTime)
            recordIdElement.setAttribute("createTime", currentTimeInUtc(), urf);
    }

    /**
     * Get the record identity from the document
     *
     * @return recordId
     */
    public final String getRecordId() {
        return root.getChild("RecordIdentity").getAttributeValue("recordId");
    }

    /**
     * Get the time/date the record was created
     *
     * @return createTime
     */
    /*public final DateTime getCreateTime() {
        String time = root.getChild("RecordIdentity").getAttributeValue("createTime");
        
    }/*


    /**
     * Set the job identity element of the document The second element under the root
     *
     * @param globalJobId (optional - may be null)
     * @param localJobId  (optional - may be null)
     * @param processId   (optional - may be null)
     */
    public final void setJobId(String globalJobId, String localJobId, String processId) {
        jobIdElement = new Element("JobIdentity", def);

        if (parameterNotNull(globalJobId))
            jobIdElement.addContent((new Element("GlobalJobId", def)).setText(globalJobId));

        if (parameterNotNull(localJobId))
            jobIdElement.addContent((new Element("LocalJobId", def)).setText(localJobId));

        if (parameterNotNull(processId))
            jobIdElement.addContent((new Element("ProcessId", def)).setText(processId));
    }

    /**
     * Return the GlobalJobId from the document.
     *
     * @return globalJobId
     */
    public final String getGlobalJobId() {
        return root.getChild("JobIdentity").getAttributeValue("GlobalJobId", urf);
    }

    /**
     * Return the LocalJobId from the document.
     *
     * @return localJobId
     */
    public final String getLocalJobId() {
        return root.getChild("JobIdentity").getAttributeValue("LocalJobId", urf);
    }

    /**
     * Return the ProcessId from the document.
     *
     * @return processId
     */
    public final String getProcessId() {
        return root.getChild("JobIdentity").getAttributeValue("ProcessId", urf);
    }

    /**
     * Set the job name element with a description.
     *
     * @param jobName
     * @param description (optional - may be null)
     */
    public final void setJobName(String jobName, String description) {
        jobNameElement = new Element("JobName", def);
        jobNameElement.setText(jobName);

        if (parameterNotNull(description))
            jobNameElement.setAttribute("description", description, urf);
    }

    /**
     * Get the job name from the document
     *
     * @return jobName
     */
    public final String getJobName() {
        return root.getChildText("JobName");
    }

    /**
     * Set the charge element of the usage record. All parameters may be null.
     *
     * @param charge
     * @param description (optional - may be null)
     * @param unit        (optional - may be null)
     * @param formula     (optional - may be null)
     */
    public final void setCharge(Float charge, String description, String unit, String formula) {
        chargeElement = new Element("Charge", def);
        chargeElement.addContent(charge.toString());

        if (parameterNotNull(description))
            chargeElement.setAttribute("description", description, urf);

        if (parameterNotNull(unit))
            chargeElement.setAttribute("unit", unit, urf);

        if (parameterNotNull(formula))
            chargeElement.setAttribute("formula", formula, urf);
    }

    /**
     * Return the charge for this usage record.
     *
     * @return charge
     */
    public final Float getCharge() {
        return new Float(root.getChildText("Charge"));
    }

    /**
     * Set the status with an optional description.
     *
     * @param status
     * @param description (optional - may be null)
     */
    public final void setStatus(Status status, String description) {
        statusElement = new Element("Status", def);
        statusElement.setText(status.toString());

        if (parameterNotNull(description))
            statusElement.setAttribute("description", description, urf);
    }

    /**
     * Return the status of the job.
     *
     * @return status
     */
    public final Status getStatus() {
        return Status.valueOf(root.getChildText("Status"));
    }

    //public final Time getDuration() {
    //    return endTime - startTime;
    //}

    //public final void setStartTime(Time startTime) {

    //}

   // public final int getStartTime() {

   // }

   // public final void setEndTime() {

    //}

    //public final int getEndTime() {

    //}

    //********************************************************

    /**
     * Add a project name and description to the document.
     * This does not replace an element currently stored, only adds another.
     *
     * @param projectName
     * @param description (optional - may be null)
     */
    public final void addProjectName(String projectName, String description) {
        Element newProjectNameElement = new Element("ProjectName", def);
        newProjectNameElement.addContent(projectName);

        if (parameterNotNull(description))
            newProjectNameElement.setAttribute("description", description, urf);

        if (projectNameElements == null)
            projectNameElements = new ArrayList<Element>();

        projectNameElements.add(newProjectNameElement);
    }

    public final ArrayList<Element> getProjectNames() {
        return projectNameElements;
    }

    /**
     * Add a user identity element to the document. This is the third entry under the root.
     * This does not replace an element currently stored, only adds another.
     *
     * @param localUserId    (optional - may be null)
     * @param globalUserName (optional - may be null)
     */
    public final void addUserId(String localUserId, String globalUserName) {
        Element newUserIdElement = new Element("UserIdentity", def);

        // TODO : Add ds:KeyInfo attribute to the UserIdentityElement

        if (parameterNotNull(localUserId))
            newUserIdElement.addContent((new Element("LocalUserId", def)).setText(localUserId));

        if (parameterNotNull(globalUserName))
            newUserIdElement.addContent((new Element("GlobalUserName", def)).setText(globalUserName));

        if (userIdElements == null)
            userIdElements = new ArrayList<Element>();

        userIdElements.add(newUserIdElement);
    }

    /**
     * Adds a resource type to the document
     * This does not replace an element currently stored, only adds another.
     *
     * @param resourceType
     * @param description (optional - may be null)
     */

    public final void addResourceType(String resourceType, String description) {
        if (!parameterNotNull(resourceType))
            throw new UsageRecordException("A resource type must be specified");

        Element newResourceType = new Element("ResourceType", def);
        newResourceType.addContent(resourceType);

        if (parameterNotNull(description))
            newResourceType.setAttribute("description", description, urf);

        if (resourceTypeElements == null)
            resourceTypeElements = new ArrayList<Element>();

        resourceTypeElements.add(newResourceType);
    }


    /**
     * Adds a disk element to the document
     * This does not replace an element currently stored, only adds another.
     *
     * @param size
     * @param description (optional - may be null)
     * @param type (optional - may be null)
     * @param metric (optional - may be null)
     * @throws UsageRecordException if size < 0
     */
    public final void addDisk(int size, String description, DiskType type, Metric metric) throws UsageRecordException {

        // TODO : Add intervallicVolume

        if (size < 0)
            throw new UsageRecordException("The size must be greater than zero");

        Element newDiskElement = new Element("Disk", def);
        newDiskElement.addContent(Integer.toString(size));

        if (parameterNotNull(description))
            newDiskElement.setAttribute("description", description, urf);

        if (type != null)
            newDiskElement.setAttribute("type", type.toString(), urf);

        if (metric != null)
            newDiskElement.setAttribute("metric", metric.toString(), urf);

        if (diskElements == null)
            diskElements = new ArrayList<Element>();

        diskElements.add(newDiskElement);
    }

    /**
     * Add a network element to the document
     * This does not replace an element currently stored, only adds another.
     *
     * @param size
     * @param unit
     * @param metric
     * @throws UsageRecordException if size < 0
     */
    public final void addNetwork(int size, Unit unit, Metric metric) throws UsageRecordException {

         if (size < 0)
            throw new UsageRecordException("The size must be greater than zero");

        Element newNetworkElement = new Element("Network", def);
        newNetworkElement.addContent(Integer.toString(size));

        if (unit != null)
            newNetworkElement.setAttribute("units", unit.toString(), urf);

        if (metric != null)
            newNetworkElement.setAttribute("metric", metric.toString(), urf);

        if (networkElements == null)
            networkElements = new ArrayList<Element>();

        networkElements.add(newNetworkElement);
    }


    public final void addMemory(int size, Unit unit, Metric metric, MemoryType type, String description)
            throws UsageRecordException {

        if (size < 0)
            throw new UsageRecordException("The size must be greater than zero");

        Element newMemoryElement = new Element("Memory", def);
        newMemoryElement.addContent(Integer.toString(size));

        if (unit == null)
            throw new UsageRecordException("The units for memory must be specified");
        else
            newMemoryElement.setAttribute("units", unit.toString(), urf);

        if (metric != null)
            newMemoryElement.setAttribute("metric", metric.toString(), urf);

        if (type != null)
            newMemoryElement.setAttribute("type", type.toString(), urf);

        if (memoryElements == null)
            memoryElements = new ArrayList<Element>();

        memoryElements.add(newMemoryElement);
    }

    //********************************************************

    /**
     * Helper method: return the current time in UTC (ISO8601) format
     *
     * @return current time as correctly formatted string
     */
    private String currentTimeInUtc() {
        Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        cal.setTime(new Date(System.currentTimeMillis()));

        StringBuffer sb = new StringBuffer();
        sb.append(padNumber(cal.get(Calendar.YEAR), 4));
        sb.append("-");
        sb.append(padNumber(cal.get(Calendar.MONTH) + 1, 2));
        sb.append("-");
        sb.append(padNumber(cal.get(Calendar.DATE), 2));
        sb.append("T");
        sb.append(padNumber(cal.get(Calendar.HOUR_OF_DAY), 2));
        sb.append(":");
        sb.append(padNumber(cal.get(Calendar.MINUTE), 2));
        sb.append(":");
        sb.append(padNumber(cal.get(Calendar.SECOND), 2));
        sb.append("Z");
        return sb.toString();
    }

    /**
     * Helper method: pad out time representation to correct number of digits
     *
     * @param value
     * @param digits
     * @return string of correct length
     */
    private String padNumber(long value, int digits) {
        String s = Long.toString(value);
        int n = digits - s.length();
        for (int i = 0; i < n; i++)
            s = "0" + s;
        return s;
    }

    /**
     * Helper method: test if the parameter was supplied or not
     *
     * @param param supplied by generator
     * @return true indicates a parameter was supplied
     */
    private boolean parameterNotNull(String param) {
		boolean parameterNull = false;
        try {
            if (param != null || !param.equals("")) 
				parameterNull = true;
        }
        catch (NullPointerException e) {
            // Do nothing and return false
        }
        return parameterNull;
    }

    /**
     * Helper method: build the xml document, adding the elements in the correct order
     */
    private void buildDocument() throws UsageRecordException {
        root.removeContent();

        // From UR specification - this must exist
        if (recordIdElement == null)
            throw new UsageRecordException("The record identity must be set");
        else
            root.addContent(recordIdElement);

        if (jobIdElement != null)           root.addContent(jobIdElement);
        if (userIdElements != null)         root.addContent(userIdElements);
        if (jobNameElement != null)         root.addContent(jobNameElement);
        if (chargeElement != null)          root.addContent(chargeElement);

        // From UR specification - this must exist
        if (statusElement == null)
            throw new UsageRecordException("The status must be set");
        else
            root.addContent(statusElement);

        if (projectNameElements != null)    root.addContent(projectNameElements);
        if (diskElements != null)           root.addContent(diskElements);
        if (networkElements != null)        root.addContent(networkElements);
        if (memoryElements != null)         root.addContent(memoryElements);
    }

    /**
     * Helper method: return a pretty representation of the UsageRecord
     *
     * @return formatted xml document string
     */
    public final String toPrettyXml() {
        buildDocument();
        try {
            XMLOutputter xmlo = new XMLOutputter();
            xmlo.setFormat(Format.getPrettyFormat());
            return xmlo.outputString(document);
        }
        catch (Exception e) {
            log.error("Problem converting to XML", e);
            return null;
        }
    }

    /**
     * Helper method: return UsageRecord as a non-formatted string
     *
     * @return document as single-line string
     */
    public final String toXml() {
        buildDocument();
        return new XMLOutputter().outputString(document);
    }


    /**
     * Validate the UsageRecord against the UR.098 schema
     */
    public final boolean validate() {

        SAXBuilder builder = new SAXBuilder(true);
        builder.setFeature ("http://apache.org/xml/features/validation/schema", true);
        builder.setFeature ("http://apache.org/xml/features/validation/schema-full-checking", true);
        builder.setProperty("http://apache.org/xml/properties/schema/external-schemaLocation",
                def.getURI());

        builder.setErrorHandler(new ErrorHandler() {

            public void error(SAXParseException e) {
                log.error("Error parsing UR: " + e.getMessage());
            }

            public void fatalError(SAXParseException e) {
               log.error("Fatal error parsing UR: " + e.getMessage());
            }

            public void warning(SAXParseException e) {
                log.error("Warning parsing UR: " + e.getMessage());
            }
        });

        try {
            builder.build(new StringReader(this.toXml()));
        }
        catch (JDOMException e) {
            log.error("Caught JDOM Exception: " + e.getMessage());
            return false;
        }
        catch (IOException e) {
            log.error("Caught IOException: " + e.getMessage());
            return false;
        }
        return true;
    }

    /**
     * Send the UsageRecord to the RUS given in the EPR for storage
     */
    public final void sendToRUS(String rusEpr) {
        // TODO : Send the  UR to the RUS given. SOAP or straight HTTP?
    }

    /**
     * For testing building the UsageRecord.
     *
     * @param args - not needed
     */
    public static void main(String[] args) {

        UsageRecord ur = new UsageRecord();

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
        ur.addNetwork(100, Unit.MB, Metric.total);
        ur.addMemory(100, Unit.MB, Metric.total, MemoryType.dedicated, null);

        // Check validation
        if (ur.validate()) {
            log.info("Usage Record was validated");
            log.info(ur.toPrettyXml());
        }
        else {
            log.error("Usage Record was NOT validated");
        }
    }
}
