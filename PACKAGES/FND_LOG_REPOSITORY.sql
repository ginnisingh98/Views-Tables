--------------------------------------------------------
--  DDL for Package FND_LOG_REPOSITORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LOG_REPOSITORY" AUTHID CURRENT_USER as
/* $Header: AFUTLGRS.pls 120.3.12010000.3 2014/11/07 16:08:33 pdeluna ship $ */

   /* Converted date from string for Metrics
   */
   G_METRIC_DATE    DATE;


   /*
   **  Determines whether logging is enabled or disabled for this module
   **  and level.
   */
   function CHECK_ACCESS_INTERNAL(MODULE_IN IN VARCHAR2,
                                  LEVEL_IN  IN NUMBER) return BOOLEAN;

   /*
   **  Writes the message to the log file for the spec'd level and module
   **  without checking if logging is enabled at this level.  This
   **  routine is only to be called from the AOL implementations of
   **  the AFLOG interface, in languages like JAVA or C.
   **  If the SESSION_ID and/or USER_ID is not passed, it defaults to the
   **  value that was passed upon INIT.
   */
   PROCEDURE STRING_UNCHECKED_INTERNAL(LOG_LEVEL IN NUMBER,
                    MODULE           IN VARCHAR2,
                    MESSAGE_TEXT     IN VARCHAR2,
                    SESSION_ID       IN NUMBER   DEFAULT NULL,
                    USER_ID          IN NUMBER   DEFAULT NULL,
                    CALL_STACK       IN VARCHAR2 DEFAULT NULL,
                    ERR_STACK        IN VARCHAR2 DEFAULT NULL);

   /*
   **  Gathers context information within the same session, then
   **  calls the private, autonmous procedure METRIC_INTERNAL,
   **  passing context information to be logged in AFLOG tables
   **
   **  A wrapper API that calls Metric_Internal using the
   **  context values from internal cache of the context values.
   **  This routine is only to be called from the AOL implementations of
   **  the AFLOG interface, in languages like JAVA or C.
   **  If the SESSION_ID is not passed, it defaults to the value that
   **  was passed upon INIT.
   */
   PROCEDURE METRIC_INTERNAL_WITH_CONTEXT(MODULE IN VARCHAR2,
                    METRIC_CODE            IN VARCHAR2,
                    METRIC_VALUE_STRING    IN VARCHAR2 DEFAULT NULL,
                    METRIC_VALUE_NUMBER    IN NUMBER   DEFAULT NULL,
                    METRIC_VALUE_DATE      IN DATE     DEFAULT NULL,
                    SESSION_ID             IN NUMBER   DEFAULT NULL,
                    NODE                   IN VARCHAR2 DEFAULT NULL,
                    NODE_IP_ADDRESS        IN VARCHAR2 DEFAULT NULL,
                    PROCESS_ID             IN VARCHAR2 DEFAULT NULL,
                    JVM_ID                 IN VARCHAR2 DEFAULT NULL,
                    THREAD_ID              IN VARCHAR2 DEFAULT NULL,
                    AUDSID                 IN NUMBER   DEFAULT NULL,
                    DB_INSTANCE            IN NUMBER   DEFAULT NULL);

   /*
   ** FND_LOG_REPOSITORY.METRICS_EVENT_INT_WITH_CONTEXT
   ** Description:
   **  A wrapper API that calls Metrics_Event_Internal using the
   **  context values from internal cache of the context values.
   **  This routine is only to be called from the AOL implementations of
   **  the AFLOG interface, in languages like JAVA or C.
   **
   ** Arguments:
   **     CONTEXT_ID - Context id to post metrics for
   **                  Pass NULL to use the current context
   */
   PROCEDURE METRICS_EVENT_INT_WITH_CONTEXT(CONTEXT_ID IN NUMBER DEFAULT NULL);

   /*
   **  Gathers context information within the same session, then
   **  calls the private, autonmous procedure STRING_UNCHECKED_INTERNAL2,
   **  passing context information to be logged in AFLOG tables
   **
   **  A wrapper API that calls String_Unchecked_Internal2 using the
   **  context values from internal cache of the context values.
   **  This routine is only to be called from the AOL implementations of
   **  the AFLOG interface, in languages like JAVA or C.
   **  If the SESSION_ID and/or USER_ID is not passed, it defaults to the
   **  value that was passed upon INIT.
   **
   ** Note: Call FUNCTION STR_UNCHKED_INT_WITH_CONTEXT(..) instead
   */
   PROCEDURE STR_UNCHKED_INT_WITH_CONTEXT(LOG_LEVEL IN NUMBER,
                    MODULE          IN VARCHAR2,
                    MESSAGE_TEXT    IN VARCHAR2,
                    ENCODED         IN VARCHAR2 DEFAULT 'N',
                    SESSION_ID      IN NUMBER   DEFAULT NULL,
                    USER_ID         IN NUMBER   DEFAULT NULL,
                    NODE            IN VARCHAR2 DEFAULT NULL,
                    NODE_IP_ADDRESS IN VARCHAR2 DEFAULT NULL,
                    PROCESS_ID      IN VARCHAR2 DEFAULT NULL,
                    JVM_ID          IN VARCHAR2 DEFAULT NULL,
                    THREAD_ID       IN VARCHAR2 DEFAULT NULL,
                    AUDSID          IN NUMBER   DEFAULT NULL,
                    DB_INSTANCE     IN NUMBER   DEFAULT NULL,
                    CALL_STACK      IN VARCHAR2 DEFAULT NULL,
                    ERR_STACK       IN VARCHAR2 DEFAULT NULL);

   /*
   ** Same as STR_UNCHKED_INT_WITH_CONTEXT, but also returns LOG_SEQUENCE
   */
   FUNCTION STR_UNCHKED_INT_WITH_CONTEXT(LOG_LEVEL IN NUMBER,
                    MODULE          IN VARCHAR2,
                    MESSAGE_TEXT    IN VARCHAR2,
                    ENCODED         IN VARCHAR2 DEFAULT 'N',
                    SESSION_ID      IN NUMBER   DEFAULT NULL,
                    USER_ID         IN NUMBER   DEFAULT NULL,
                    NODE            IN VARCHAR2 DEFAULT NULL,
                    NODE_IP_ADDRESS IN VARCHAR2 DEFAULT NULL,
                    PROCESS_ID      IN VARCHAR2 DEFAULT NULL,
                    JVM_ID          IN VARCHAR2 DEFAULT NULL,
                    THREAD_ID       IN VARCHAR2 DEFAULT NULL,
                    AUDSID          IN NUMBER   DEFAULT NULL,
                    DB_INSTANCE     IN NUMBER   DEFAULT NULL,
                    CALL_STACK      IN VARCHAR2 DEFAULT NULL,
                    ERR_STACK       IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

   /*
   ** For Internal AOL/J Use Only.
   */
   PROCEDURE INSERT_BLOB(P_LOG_SEQUENCE IN NUMBER, PCHARSET IN VARCHAR2,
                PMIMETYPE IN VARCHAR2, PENCODING IN VARCHAR2, PLANG IN VARCHAR2,
		PFILE_EXTN IN VARCHAR2, PDESC IN VARCHAR2);

   /*
   ** For Internal AOL/J Use Only.
   ** Get the BLOB (for Attachments) corresponding to the P_LOG_SEQUENCE
   */
   PROCEDURE GET_BLOB_INTERNAL(P_LOG_SEQUENCE IN NUMBER,
			LOG_BLOB OUT NOCOPY BLOB,
			P_CHARSET IN VARCHAR2 DEFAULT 'ascii',
			P_MIMETYPE IN VARCHAR2 DEFAULT 'text/html',
			P_ENCODING IN VARCHAR2 DEFAULT NULL,
			P_LANG IN VARCHAR2 DEFAULT NULL,
			P_FILE_EXTN IN VARCHAR2 DEFAULT 'txt',
			P_DESC IN VARCHAR2 DEFAULT NULL);

   /*
   ** FND_LOG_REPOSITORY.INIT_TRANS_INT_WITH_CONTEXT
   ** Description:
   ** A wrapper API that calls Init_Transaction_Internal using the
   ** context values from internal cache of the context values.
   ** This routine is only to be called from the AOL implementations of
   ** the AFLOG interface, in languages like JAVA or C.
   ** If the SESSION_ID and/or USER_ID is not passed, it defaults to the
   ** value that was passed upon INIT.
   **
   ** Initializes a log transaction.  A log transaction
   ** corresponds to an instance or invocation of a single
   ** component.  (e.g. A concurrent request, service process,
   ** open form, ICX function)
   **
   ** This routine should be called only after
   ** FND_GLOBAL.INITIALIZE, since some of the context information
   ** is retrieved from FND_GLOBAL.
   **
   ** Arguments:
   **   CONC_REQUEST_ID       - Concurrent request id
   **   FORM_ID               - Form id
   **   FORM_APPLICATION_ID   - Form application id
   **   CONCURRENT_PROCESS_ID - Service process id
   **   CONCURRENT_QUEUE_ID   - Service queue id
   **   QUEUE_APPLICATION_ID  - Service queue application id
   **   SOA_INSTANCE_ID       - SOA instance id
   **
   ** Use only the arguments that apply to the caller.
   ** Any argument that does not apply should be passed as NULL
   ** i.e. when calling from a form, pass in FORM_ID and FORM_APPLICATION_ID
   ** and leave all other parameters NULL.
   **
   ** Returns:
   **   ID of the log transaction context
   **
   */
   FUNCTION INIT_TRANS_INT_WITH_CONTEXT (CONC_REQUEST_ID             IN NUMBER DEFAULT NULL,
                                         FORM_ID                     IN NUMBER DEFAULT NULL,
                                         FORM_APPLICATION_ID         IN NUMBER DEFAULT NULL,
                                         CONCURRENT_PROCESS_ID       IN NUMBER DEFAULT NULL,
                                         CONCURRENT_QUEUE_ID         IN NUMBER DEFAULT NULL,
                                         QUEUE_APPLICATION_ID        IN NUMBER DEFAULT NULL,
                                         SESSION_ID                  IN NUMBER DEFAULT NULL,
                                         USER_ID                     IN NUMBER DEFAULT NULL,
                                         RESP_APPL_ID                IN NUMBER DEFAULT NULL,
                                         RESPONSIBILITY_ID           IN NUMBER DEFAULT NULL,
                                         SECURITY_GROUP_ID           IN NUMBER DEFAULT NULL,
					 SOA_INSTANCE_ID             IN NUMBER DEFAULT NULL)
                                                          return NUMBER;


   /*
   ** Internal- This routine initializes the logging system from the
   ** profiles.  AOL will normally call this routine to initialize the
   ** system so the API consumer should not need to call it.
   ** The SESSION_ID is a unique identifier (like the ICX_SESSION id)
   ** The USER_ID is the name of the apps user.
   */
   PROCEDURE INIT(SESSION_ID   IN NUMBER default NULL,
                  USER_ID      IN NUMBER default NULL);


   /*
   **  Convert the string into date format, store in global variable
   */
   PROCEDURE METRIC_STRING_TO_DATE(DATE_VC IN VARCHAR2 DEFAULT NULL);

   /**
    *  Private procedure called from AppsLog.java for Bulk logging messages
    */
   PROCEDURE GET_BULK_CONTEXT_PVT(
				LOG_SEQUENCE_OUT OUT NOCOPY NUMBER,
				TIMESTAMP_OUT    OUT NOCOPY DATE,
				DBSESSIONID_OUT  OUT NOCOPY NUMBER,
				DBINSTANCE_OUT	 OUT NOCOPY NUMBER,
				TXN_ID_OUT       OUT NOCOPY NUMBER
				);

   /**
    *  Private function called from AppsLog.java for Bulk logging messages
    */
   FUNCTION BULK_INSERT_PVT(MODULE_IN IN FND_TABLE_OF_VARCHAR2_255,
                        LOG_LEVEL_IN IN FND_TABLE_OF_NUMBER,
                        MESSAGE_TEXT_IN IN FND_TABLE_OF_VARCHAR2_4000,
                        SESSION_ID_IN IN FND_TABLE_OF_NUMBER,
                        USER_ID_IN IN FND_TABLE_OF_NUMBER,
                        TIMESTAMP_IN IN FND_TABLE_OF_DATE,
                        LOG_SEQUENCE_IN IN FND_TABLE_OF_NUMBER,
                        ENCODED_IN IN FND_TABLE_OF_VARCHAR2_1,
                        NODE_IN IN varchar2,
                        NODE_IP_ADDRESS_IN IN varchar2,
                        PROCESS_ID_IN IN varchar2,
                        JVM_ID_IN IN varchar2,
                        THREAD_ID_IN IN FND_TABLE_OF_VARCHAR2_120,
                        AUDSID_IN IN FND_TABLE_OF_NUMBER,
                        DB_INSTANCE_IN IN FND_TABLE_OF_NUMBER,
			TRANSACTION_CONTEXT_ID_IN IN FND_TABLE_OF_NUMBER,
			SIZE_IN IN NUMBER) RETURN NUMBER;

    /**
     * Procedure to enable PL/SQL Buffered Logging (for Batch Mode).
     * Caller is responsible for calling RESET_BUFFERED_MODE
     * Internally buffers messages in PL/SQL Collection for Bulk-Inserting.
     */
    PROCEDURE SET_BUFFERED_MODE;

    /**
     * Flushes any buffered messages, and switches back to the
     * default synchronous (non-buffered) logging.
     */
    PROCEDURE RESET_BUFFERED_MODE;

    /**
     * Internal Only.
     *
     * API for setting a child context (for proxy alerting) for the given
     * concurrent request ID.
     *
     * This API will first initialize the proxy context (i.e. the current
     * transaction context) if not already initialized. It will then
     * initialize the child transaction context for the given concurrent
     * request ID if it has not been initialized already.
     */
    PROCEDURE SET_CHILD_CONTEXT_FOR_CONC_REQ (
	p_request_id IN NUMBER );

    /**
     * Internal Only.
     *
     * This API clears the G_CHILD_TRANSACTION_CONTEXT_ID variable
     * along with any other globals associated with the child
     * context for proxy alerting.
     */
    PROCEDURE CLEAR_CHILD_CONTEXT;


    /**
     * Log a message directly without checking if logging is enabled.
     * Requires a transaction_context_id of a transaction_context that
     * has already been created. This allows messages to be logged
     * to multiple contexts within the same session.
     *
     * This function should only be called by internal ATG procedures.
     *
     */
    FUNCTION STRING_UNCHECKED_TO_CONTEXT(LOG_LEVEL       IN NUMBER,
					 MODULE          IN VARCHAR2,
					 MESSAGE_TEXT    IN VARCHAR2,
					 TRANSACTION_CONTEXT_ID IN NUMBER,
					 ENCODED         IN VARCHAR2 DEFAULT 'N',
					 SESSION_ID      IN NUMBER   DEFAULT NULL,
					 USER_ID         IN NUMBER   DEFAULT NULL,
					 NODE            IN VARCHAR2 DEFAULT NULL,
					 NODE_IP_ADDRESS IN VARCHAR2 DEFAULT NULL,
					 PROCESS_ID      IN VARCHAR2 DEFAULT NULL,
					 JVM_ID          IN VARCHAR2 DEFAULT NULL,
					 THREAD_ID       IN VARCHAR2 DEFAULT NULL,
					 AUDSID          IN NUMBER   DEFAULT NULL,
					 DB_INSTANCE     IN NUMBER   DEFAULT NULL,
					 CALL_STACK      IN VARCHAR2 DEFAULT NULL,
					 ERR_STACK       IN VARCHAR2 DEFAULT NULL) return NUMBER;

    FUNCTION NOPASS (MESSAGE_TEXT IN VARCHAR2) RETURN VARCHAR2;

end FND_LOG_REPOSITORY;

/
