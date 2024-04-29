--------------------------------------------------------
--  DDL for Package Body ECE_PO_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_PO_ARCHIVE_PKG" AS
-- $Header: ECEPOARB.pls 120.2 2005/09/28 11:53:06 arsriniv ship $

-- Private Procedure declarations
PROCEDURE PORARDOCUMENT (
                         P_DOCUMENT_TYPE IN VARCHAR2,
                         P_DOCUMENT_SUBTYPE IN VARCHAR2,
                         P_DOCUMENT_ID IN NUMBER);
PROCEDURE PORARPOCHECK (
                        P_DOCUMENT_ID IN NUMBER,
                        P_REVISION_NUM OUT NOCOPY NUMBER,
                        P_ARCHIVE_OK OUT NOCOPY VARCHAR2);
PROCEDURE PORARERELEASECHECK (
                        P_DOCUMENT_ID IN NUMBER,
                        P_REVISION_NUM OUT NOCOPY NUMBER,
                        P_ARCHIVE_OK OUT NOCOPY VARCHAR2);
PROCEDURE PORARHEADER (
                        P_DOCUMENT_ID IN NUMBER);
PROCEDURE PORARLINES (
                        P_DOCUMENT_ID IN NUMBER,
                        P_REVISION_NUM IN NUMBER);
PROCEDURE PORARSHIPDIST (
                        P_DOCUMENT_ID IN NUMBER,
                        P_REVISION_NUM IN NUMBER);
PROCEDURE PORARRELEASE (
                        P_DOCUMENT_ID IN NUMBER,
                        P_REVISION_NUM IN NUMBER);

global_stack VARCHAR2(2000);

-- ============================================================================
--  Name: porarchive
--  Desc: Archving cover routine
--  Args: IN: p_document_type
--            p_document_subtype
--            p_document_id
--            p_process        - Process that called this routine
--                                     'PRINT' or 'APPROVE'.
--  Err : Any value other than 0 in p_error_code indicates an oracle error
--        occurred.  Currently the only errors that are raised are oracle
--        errors.  No other error codes are reserved for special meanings.
--        The Oracle Error Message is given in p_error_buf and the context
--        or call stack is in p_error_stack.
--  Algr:	Check if archiving is neccesary.  If not, exit.
--        Set a savepoint.
--        Call porardocument()
--        If the archiving was successfull return.
--        else rollback to the savepoint and set p_error_code and return.
--
--        Conditions for archiving:
--             archive_external_revision code in PO_DOCUMENT_TYPES
--             (PRINT or APPROVE) of given document type must be the same
--             as process (PRINT or APPROVE).
--  Note: Routine does NOT do a commit, this must be done in the calling
--        routine!
-- ============================================================================

PROCEDURE PORARCHIVE (
                      P_DOCUMENT_TYPE IN VARCHAR2,
                      P_DOCUMENT_SUBTYPE IN VARCHAR2,
                      P_DOCUMENT_ID IN NUMBER,
                      P_PROCESS IN VARCHAR2,
		      P_ERROR_CODE OUT NOCOPY NUMBER,
		      P_ERROR_BUF OUT  NOCOPY VARCHAR2,
		      P_ERROR_STACK OUT NOCOPY VARCHAR2)
IS
    l_when_to_archive PO_DOCUMENT_TYPES.ARCHIVE_EXTERNAL_REVISION_CODE%TYPE;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

BEGIN
    -- Initialize error_code to 0 - no error
    -- Initialize global_stack to Null on entry
    p_error_code := 0;
    global_stack := NULL;

    --  Set a savepoint so we can rollback when something goes wrong.
    SAVEPOINT PORAR_1;

    --  Validate the p_process parameter
    --  If this parameter isn't validated, if an invalid value is allowed
    --  this function will always succeed without doing anything due to
    --  comparison between p_process and l_when_to_archive below.
    IF p_process NOT IN ('PRINT','APPROVE') THEN
        global_stack := '10';
        RAISE NO_DATA_FOUND;
    END IF;

    --  Check if the given document_type and subtype exists and
    --  if archiving is neccesary for this document.

    SELECT ARCHIVE_EXTERNAL_REVISION_CODE
    INTO   l_when_to_archive
    FROM   PO_DOCUMENT_TYPES
    WHERE  DOCUMENT_TYPE_CODE = p_document_type
    AND    DOCUMENT_SUBTYPE   = p_document_subtype;

    --  Check if we need to archive the document.
    IF p_process = l_when_to_archive THEN

        --  Assert: The routine is called from the print routine and we need
        --          to archive on print OR it is called from the approval
        --          routine and we need to archive at approval.

       IF (PO_CODE_RELEASE_GRP.Current_Release >=
         PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J) THEN
         PO_EDI_INTEGRATION_GRP.archive_po(
         p_api_version      => 1.0,
         p_document_id      => p_document_id,
         p_document_type    => p_document_type,
         p_document_subtype => p_document_subtype,
         x_return_status    => l_return_status,
         x_msg_count        => l_msg_count,
         x_msg_data        => l_msg_data);
       ELSE
         ECE_PO_ARCHIVE_PKG.PORARDOCUMENT(p_document_type,
                                         p_document_subtype,
                                         p_document_id);
       END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        global_stack := 'PORARCHIVE(P_DOCUMENT_TYPE='''||p_document_type||
			  ''' P_DOCUMENT_SUBTYPE='''||p_document_subtype||
			  ''' P_DOCUMENT_ID='''||p_document_id||
			  ''' P_PROCESS='''||p_process||
			  '''):'||global_stack;
        p_error_code := SQLCODE;
        p_error_buf := SQLERRM;
	p_error_stack := global_stack;

	ROLLBACK TO PORAR_1;

END PORARCHIVE;

-- ============================================================================
--  Name: porardocument
--  Desc: Archving routine
--  Args: IN: p_document_type
--            p_document_subtype
--            p_document_id
--  Err :	Error message context returned in global_stack.
--  Algr: Check if the current revision is already archived. If so return.
--        Case entity.document_type is
--        When PO
--          Case entity.document_subtype is
--            When STANDARD or PLANNED
--              archive PO_HEADERS
--              when modified archive PO_LINES, PO_LINE_LOCATIONS and
--                    PO_DISTRIBUTIONS.
--          End Case
--        When PA
--          Case entity.document_subtype is
--            When BLANKET
--              archive PO_HEADERS
--              when modified archive PO_LINES.
--            When CONTRACT
--              archive PO_HEADERS
--        When RELEASE
--          archive PO_RELEASES
--          when modified archive PO_LINE_LOCATIONS and PO_DISTRIBUTIONS.
--        End Case
--  Note: Private Procedure
-- ============================================================================

PROCEDURE PORARDOCUMENT (
                         P_DOCUMENT_TYPE IN VARCHAR2,
                         P_DOCUMENT_SUBTYPE IN VARCHAR2,
                         P_DOCUMENT_ID IN NUMBER)
IS

l_archive_ok VARCHAR2(1);
l_revision_num NUMBER;

BEGIN
    --  Determine what kind of document this is.
    IF p_document_type = 'PO' then
        --  Assert: It is a Purchase Order.
        IF p_document_subtype IN ('STANDARD','PLANNED') THEN
            --  Assert: It is a Standard or Planned Purchase Order.
            --  Get the revision number and check if it is different from the
            --  latest archived version.
	    --  l_revision_num and l_archive_ok are OUT variables and are
	    --  populated by this procedure call
            ECE_PO_ARCHIVE_PKG.PORARPOCHECK(p_document_id,
					l_revision_num,
					l_archive_ok);
            --  Check if porarcpcheckpo said we need to archive.
            IF l_archive_ok = 'N' THEN
                --  Assert: No need to archive.
                NULL;
            ELSE
                --  Archive the Header.
                ECE_PO_ARCHIVE_PKG.PORARHEADER(p_document_id);
                --  Archive the Lines.
                ECE_PO_ARCHIVE_PKG.PORARLINES(p_document_id, l_revision_num);
                --  Archive the Shipments and Distributions.
                ECE_PO_ARCHIVE_PKG.PORARSHIPDIST(p_document_id, l_revision_num);
	    END IF;
        ELSE
            global_stack := '40';  -- Unknown document subtype
	    raise NO_DATA_FOUND;
        END IF;
    ELSIF p_document_type = 'PA' THEN
        --  Assert: It is a Purchase Agreement.
        IF p_document_subtype = 'BLANKET' THEN
            --  Assert: It is a Blanket Purchase Agreement.
            --  Get the revision number and check if it is different
            --  from the latest archived version.
	    --  l_revision_num and l_archive_ok are OUT variables and are
	    --  populated by this procedure call
            ECE_PO_ARCHIVE_PKG.PORARPOCHECK(p_document_id,
					l_revision_num,
					l_archive_ok);
            --  Check if porarpocheck said we need to archive.
            IF l_archive_ok = 'N' then
                --  Assert: No need to archive.
                NULL;
            ELSE
                --  Archive the Header.
                ECE_PO_ARCHIVE_PKG.PORARHEADER(p_document_id);
                --  Archive the Lines.
                ECE_PO_ARCHIVE_PKG.PORARLINES(p_document_id, l_revision_num);
	    END IF;

        ELSIF p_document_subtype = 'CONTRACT' THEN
            --  Assert: It is a Contract Purchase Agreement.
            ECE_PO_ARCHIVE_PKG.PORARPOCHECK(p_document_id,
					l_revision_num,
					l_archive_ok);
            --  Check if porarpocheck said we need to archive.
            IF l_archive_ok = 'N' THEN
                --  Assert: No need to archive.
                NULL;
	    ELSE
                --  Archive the Header.
                ECE_PO_ARCHIVE_PKG.PORARHEADER(p_document_id);
	    END IF;
        ELSE
            global_stack := '30';  -- Unknown document subtype
	    RAISE NO_DATA_FOUND;
	END IF;

    ELSIF p_document_type = 'RELEASE' THEN
        --  Assert: It is a Release.
        IF p_document_subtype IN ('SCHEDULED', 'BLANKET') THEN
            --  Assert: It is a Scheduled Release or a Blanket Release.
            --  Get the revision number and check if it is
            --  different from the latest archived version.
	    --  l_revision_num and l_archive_ok are OUT variables and are
	    --  populated by this procedure call
            ECE_PO_ARCHIVE_PKG.PORARERELEASECHECK(p_document_id,
					      l_revision_num,
					      l_archive_ok);
            --  Check if porarereleasecheck said we need to archive.
            IF l_archive_ok = 'N' THEN
                --  Assert: No need to archive.
                NULL;
	    ELSE
                ECE_PO_ARCHIVE_PKG.PORARRELEASE(p_document_id, l_revision_num);
	    END IF;
        ELSE
            global_stack := '20';  -- Unknown document subtype
	    raise NO_DATA_FOUND;
	END IF;
    ELSE
        global_stack := '10';  -- Unknown document type
	raise NO_DATA_FOUND;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        global_stack := 'PORARDOCUMENT(P_DOCUMENT_TYPE='''||p_document_type||
			  ''' P_DOCUMENT_SUBTYPE='''||p_document_subtype||
			  ''' P_DOCUMENT_ID='''||p_document_id||
			  '''):'||global_stack;
        RAISE;

END PORARDOCUMENT;

-- ============================================================================
--  Name: porarpocheck
--  Desc: Get the current revision number and check if it is already archived.
--  Args: IN:  p_document_id     - The unique identifier of the Purchase Order.
--        OUT: p_revision_num    - The revision number of the Purchase Order.
--             p_archive_ok      - Do we need to archive? 'Y' or 'N'.
--  Err :  Add context to global_stack
--  Algr:	Select the given PO and compare the revision number with
--          the revision number of the latest archived version.
--        If current revision_num = latest archived revision_num
--            archive_ok = 'N'
--        Else
--            archive_ok = 'Y'
--  Note: 1) Private function - Used only in porardocument()
-- ============================================================================


PROCEDURE PORARPOCHECK (
                        P_DOCUMENT_ID IN NUMBER,
                        P_REVISION_NUM OUT NOCOPY NUMBER,
                        P_ARCHIVE_OK OUT  NOCOPY VARCHAR2)
IS
l_revision_num NUMBER DEFAULT 0;
l_archived_revision_num NUMBER DEFAULT -1;
BEGIN
    -- Check if the Purchase Order exists, get the revision number.
    -- If revision number does not exist (which should never be the
    -- case), we default to 0.
    SELECT NVL(REVISION_NUM, 0)
    INTO   l_revision_num
    FROM   PO_HEADERS
    WHERE  PO_HEADER_ID = p_document_id;
    --  Assert: Purchase Order exists.
    --  Check if Purchase Order is already archived.
    --  If revision_num does not exist (which should never be the
    --  case), we default to -1.  In case no archive record exists
    --  revision_num will be -1 due to initialization.
    BEGIN

        SELECT NVL(REVISION_NUM, -1)
        INTO   l_archived_revision_num
        FROM   PO_HEADERS_ARCHIVE
        WHERE  PO_HEADER_ID         = p_document_id
        AND    LATEST_EXTERNAL_FLAG = 'Y';

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
            NULL;
    END;


    IF l_revision_num = l_archived_revision_num THEN
        --  Assert: The current revision of the Purchase Order is already
        --  archived.
        p_archive_ok := 'N';
    ELSE
        --  Assert: We need to archive; revision_num is different or there is
        --  no previously archived record (archived_revision_num = -1).
        p_archive_ok := 'Y';
    END IF;

    p_revision_num := l_revision_num;

EXCEPTION
    WHEN OTHERS THEN
        global_stack := 'PORARPOCHECK(P_DOCUMENT_ID='''||p_document_id||
			  '''):'||global_stack;
        RAISE;

END PORARPOCHECK;

-- ============================================================================
--  Name: porarereleasecheck
--  Desc: Get the current revision number of the Release and check if it is
--        already archived.
--  Args: IN:  p_document_id           - The unique identifier of the Release.
--        OUT: p_revision_num          - The Revision number of the Release.
--             p_archive_ok            - Do we need to archive. 'Y' or 'N'.
--  Err : Add context to global stack reraise error
--  Algr:	Select the given Revision and compare the revision number
--          with the revision number of the latest archived version.
--        If current revision_num = latest archived revision_num
--            archive_ok = 'N'
--        Else
--            archive_ok = 'Y'
--  Note: 1) Private function - Used only in porardocument.
-- ============================================================================

PROCEDURE PORARERELEASECHECK (
                        P_DOCUMENT_ID IN NUMBER,
                        P_REVISION_NUM OUT NOCOPY NUMBER,
                        P_ARCHIVE_OK OUT NOCOPY VARCHAR2)
IS

l_revision_num NUMBER DEFAULT 0;
l_archived_revision_num NUMBER DEFAULT -1;

BEGIN
    -- Check if the Relase exists, get the revision number.
    -- If the revision_num does not exist (which should never be the
    -- case), we default to 0.
    SELECT NVL(REVISION_NUM,0)
    INTO   l_revision_num
    FROM   PO_RELEASES
    WHERE  PO_RELEASE_ID = p_document_id;

    --  Assert: Release exists.
    --  Check if Release is already archived.
    --  If the revision_num does not exist (which should never be the
    --  case), we default to -1.
    BEGIN

        SELECT NVL(REVISION_NUM,-1)
        INTO   l_archived_revision_num
        FROM   PO_RELEASES_ARCHIVE
        WHERE  PO_RELEASE_ID        = p_document_id
        AND    LATEST_EXTERNAL_FLAG = 'Y';

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    NULL;
    END;

    IF l_revision_num = l_archived_revision_num THEN
        --  Assert: The current revision of the Release is already archived.
        p_archive_ok := 'N';
    ELSE
        --  Assert: We need to archive; revision_num is different or there is
        --  no previously archived record (archived_revision_num = -1).
        p_archive_ok := 'Y';
    END IF;

    p_revision_num := l_revision_num;

EXCEPTION
    WHEN OTHERS THEN
        global_stack := 'PORARERELEASECHECK(P_DOCUMENT_ID='''||p_document_id||
			  '''):'||global_stack;
        RAISE;

END PORARERELEASECHECK;


-- ============================================================================
--  Name: porarheader
--  Desc: Archive PO_HEADERS
--  Args: IN:  p_document_id      - The unique identifier of the Purchase Order
--  Err : Error message context returned in global_stack.
--  Algr: Set the LATEST_EXTERNAL_FLAG of the current archived header to "N"
--        Archive the Header.
--  Note: Private Procedure
-- ============================================================================

PROCEDURE PORARHEADER (
                        P_DOCUMENT_ID IN NUMBER)
IS

BEGIN

    UPDATE PO_HEADERS_ARCHIVE
    SET   LATEST_EXTERNAL_FLAG = 'N'
    WHERE PO_HEADER_ID         = p_document_id
    AND   LATEST_EXTERNAL_FLAG = 'Y';

    --  Archive the header.
    --  This will be an exact copy of po_headers except for
    --  the latest_external_flag.  Keep the columns in
    --  alphabetical order for easy verification.
    INSERT INTO PO_HEADERS_ARCHIVE
        (
         ACCEPTANCE_DUE_DATE             ,
         ACCEPTANCE_REQUIRED_FLAG        ,
         AGENT_ID                        ,
         AMOUNT_LIMIT                    ,
         APPROVAL_REQUIRED_FLAG          ,
         APPROVED_DATE                   ,
         APPROVED_FLAG                   ,
         ATTRIBUTE1                      ,
         ATTRIBUTE10                     ,
         ATTRIBUTE11                     ,
         ATTRIBUTE12                     ,
         ATTRIBUTE13                     ,
         ATTRIBUTE14                     ,
         ATTRIBUTE15                     ,
         ATTRIBUTE2                      ,
         ATTRIBUTE3                      ,
         ATTRIBUTE4                      ,
         ATTRIBUTE5                      ,
         ATTRIBUTE6                      ,
         ATTRIBUTE7                      ,
         ATTRIBUTE8                      ,
         ATTRIBUTE9                      ,
         ATTRIBUTE_CATEGORY              ,
         AUTHORIZATION_STATUS            ,
         BILL_TO_LOCATION_ID             ,
         BLANKET_TOTAL_AMOUNT            ,
         CANCEL_FLAG                     ,
         CLOSED_CODE                     ,
         CLOSED_DATE                     ,
         COMMENTS                        ,
         CONFIRMING_ORDER_FLAG           ,
         CREATED_BY                      ,
         CREATION_DATE                   ,
         CURRENCY_CODE                   ,
         ENABLED_FLAG                    ,
         END_DATE                        ,
         END_DATE_ACTIVE                 ,
         FIRM_STATUS_LOOKUP_CODE         ,
         FOB_LOOKUP_CODE                 ,
         FREIGHT_TERMS_LOOKUP_CODE       ,
         FROM_HEADER_ID                  ,
         FROM_TYPE_LOOKUP_CODE           ,
         FROZEN_FLAG                     ,
         GOVERNMENT_CONTEXT              ,
         LAST_UPDATED_BY                 ,
         LAST_UPDATE_DATE                ,
         LAST_UPDATE_LOGIN               ,
         LATEST_EXTERNAL_FLAG            ,
         MIN_RELEASE_AMOUNT              ,
         NOTE_TO_AUTHORIZER              ,
         NOTE_TO_RECEIVER                ,
         NOTE_TO_VENDOR                  ,
         PO_HEADER_ID                    ,
         PRINTED_DATE                    ,
         PRINT_COUNT                     ,
         PROGRAM_APPLICATION_ID          ,
         PROGRAM_ID                      ,
         PROGRAM_UPDATE_DATE             ,
         QUOTATION_CLASS_CODE            ,
         QUOTE_TYPE_LOOKUP_CODE          ,
         QUOTE_VENDOR_QUOTE_NUMBER       ,
         QUOTE_WARNING_DELAY             ,
         QUOTE_WARNING_DELAY_UNIT        ,
         RATE                            ,
         RATE_DATE                       ,
         RATE_TYPE                       ,
         REPLY_DATE                      ,
         REPLY_METHOD_LOOKUP_CODE        ,
         REQUEST_ID                      ,
         REVISED_DATE                    ,
         REVISION_NUM                    ,
         RFQ_CLOSE_DATE                  ,
         SEGMENT1                        ,
         SEGMENT2                        ,
         SEGMENT3                        ,
         SEGMENT4                        ,
         SEGMENT5                        ,
         SHIP_TO_LOCATION_ID             ,
         SHIP_VIA_LOOKUP_CODE            ,
         START_DATE                      ,
         START_DATE_ACTIVE               ,
         SUMMARY_FLAG                    ,
         TERMS_ID                        ,
         TYPE_LOOKUP_CODE                ,
         USER_HOLD_FLAG                  ,
         USSGL_TRANSACTION_CODE          ,
         VENDOR_CONTACT_ID               ,
         VENDOR_ID                       ,
         VENDOR_ORDER_NUM                ,
         VENDOR_SITE_ID                  )
    SELECT
         ACCEPTANCE_DUE_DATE             ,
         ACCEPTANCE_REQUIRED_FLAG        ,
         AGENT_ID                        ,
         AMOUNT_LIMIT                    ,
         APPROVAL_REQUIRED_FLAG          ,
         APPROVED_DATE                   ,
         APPROVED_FLAG                   ,
         ATTRIBUTE1                      ,
         ATTRIBUTE10                     ,
         ATTRIBUTE11                     ,
         ATTRIBUTE12                     ,
         ATTRIBUTE13                     ,
         ATTRIBUTE14                     ,
         ATTRIBUTE15                     ,
         ATTRIBUTE2                      ,
         ATTRIBUTE3                      ,
         ATTRIBUTE4                      ,
         ATTRIBUTE5                      ,
         ATTRIBUTE6                      ,
         ATTRIBUTE7                      ,
         ATTRIBUTE8                      ,
         ATTRIBUTE9                      ,
         ATTRIBUTE_CATEGORY              ,
         AUTHORIZATION_STATUS            ,
         BILL_TO_LOCATION_ID             ,
         BLANKET_TOTAL_AMOUNT            ,
         CANCEL_FLAG                     ,
         CLOSED_CODE                     ,
         CLOSED_DATE                     ,
         COMMENTS                        ,
         CONFIRMING_ORDER_FLAG           ,
         CREATED_BY                      ,
         CREATION_DATE                   ,
         CURRENCY_CODE                   ,
         ENABLED_FLAG                    ,
         END_DATE                        ,
         END_DATE_ACTIVE                 ,
         FIRM_STATUS_LOOKUP_CODE         ,
         FOB_LOOKUP_CODE                 ,
         FREIGHT_TERMS_LOOKUP_CODE       ,
         FROM_HEADER_ID                  ,
         FROM_TYPE_LOOKUP_CODE           ,
         FROZEN_FLAG                     ,
         GOVERNMENT_CONTEXT              ,
         LAST_UPDATED_BY                 ,
         LAST_UPDATE_DATE                ,
         LAST_UPDATE_LOGIN               ,
         'Y'                             ,
         MIN_RELEASE_AMOUNT              ,
         NOTE_TO_AUTHORIZER              ,
         NOTE_TO_RECEIVER                ,
         NOTE_TO_VENDOR                  ,
         PO_HEADER_ID                    ,
         PRINTED_DATE                    ,
         PRINT_COUNT                     ,
         PROGRAM_APPLICATION_ID          ,
         PROGRAM_ID                      ,
         PROGRAM_UPDATE_DATE             ,
         QUOTATION_CLASS_CODE            ,
         QUOTE_TYPE_LOOKUP_CODE          ,
         QUOTE_VENDOR_QUOTE_NUMBER       ,
         QUOTE_WARNING_DELAY             ,
         QUOTE_WARNING_DELAY_UNIT        ,
         RATE                            ,
         RATE_DATE                       ,
         RATE_TYPE                       ,
         REPLY_DATE                      ,
         REPLY_METHOD_LOOKUP_CODE        ,
         REQUEST_ID                      ,
         REVISED_DATE                    ,
         REVISION_NUM                    ,
         RFQ_CLOSE_DATE                  ,
         SEGMENT1                        ,
         SEGMENT2                        ,
         SEGMENT3                        ,
         SEGMENT4                        ,
         SEGMENT5                        ,
         SHIP_TO_LOCATION_ID             ,
         SHIP_VIA_LOOKUP_CODE            ,
         START_DATE                      ,
         START_DATE_ACTIVE               ,
         SUMMARY_FLAG                    ,
         TERMS_ID                        ,
         TYPE_LOOKUP_CODE                ,
         USER_HOLD_FLAG                  ,
         USSGL_TRANSACTION_CODE          ,
         VENDOR_CONTACT_ID               ,
         VENDOR_ID                       ,
         VENDOR_ORDER_NUM                ,
         VENDOR_SITE_ID
    FROM PO_HEADERS
    WHERE PO_HEADER_ID = p_document_id;


EXCEPTION
    WHEN OTHERS THEN
        global_stack := 'PORARRELEASE(P_DOCUMENT_ID='''||p_document_id||
			  '''):'||global_stack;
        RAISE;

END PORARHEADER;

-- ============================================================================
--  Name: porarlines
--  Desc: Archive PO_LINES
--  Args: IN:  p_document_id      - The unique identifier of the Purchase Order
--             p_revision_num     - The revision number of the header
--  Err :	Error message context returned in global_stack.
--  Algr: Set the LATEST_EXTERNAL_FLAG of the current archived lines to "N"
--        Archive the lines.
--  Note: Private Procedure
-- ============================================================================

PROCEDURE PORARLINES (
                        P_DOCUMENT_ID IN NUMBER,
                        P_REVISION_NUM IN NUMBER)
IS

BEGIN
    --  Archive the lines.
    --  This will be an exact copy of po_lines except for the
    --  latest_external_flag and the revision_num.  Keep the columns
    --  in alphabetical order for easy verification.
    INSERT INTO PO_LINES_ARCHIVE
        (
         ALLOW_PRICE_OVERRIDE_FLAG       ,
         ATTRIBUTE1                      ,
         ATTRIBUTE10                     ,
         ATTRIBUTE11                     ,
         ATTRIBUTE12                     ,
         ATTRIBUTE13                     ,
         ATTRIBUTE14                     ,
         ATTRIBUTE15                     ,
         ATTRIBUTE2                      ,
         ATTRIBUTE3                      ,
         ATTRIBUTE4                      ,
         ATTRIBUTE5                      ,
         ATTRIBUTE6                      ,
         ATTRIBUTE7                      ,
         ATTRIBUTE8                      ,
         ATTRIBUTE9                      ,
         ATTRIBUTE_CATEGORY              ,
         CANCELLED_BY                    ,
         CANCEL_DATE                     ,
         CANCEL_FLAG                     ,
         CANCEL_REASON                   ,
         CAPITAL_EXPENSE_FLAG            ,
         CATEGORY_ID                     ,
         CLOSED_BY                       ,
         CLOSED_CODE                     ,
         CLOSED_DATE                     ,
         CLOSED_FLAG                     ,
         CLOSED_REASON                   ,
         COMMITTED_AMOUNT                ,
         CONTRACT_NUM                    ,
         CREATED_BY                      ,
         CREATION_DATE                   ,
         FIRM_STATUS_LOOKUP_CODE         ,
         FROM_HEADER_ID                  ,
         FROM_LINE_ID                    ,
         GOVERNMENT_CONTEXT              ,
         HAZARD_CLASS_ID                 ,
         ITEM_DESCRIPTION                ,
         ITEM_ID                         ,
         ITEM_REVISION                   ,
         LAST_UPDATED_BY                 ,
         LAST_UPDATE_DATE                ,
         LAST_UPDATE_LOGIN               ,
         LATEST_EXTERNAL_FLAG            ,
         LINE_NUM                        ,
         LINE_TYPE_ID                    ,
         LIST_PRICE_PER_UNIT             ,
         MARKET_PRICE                    ,
         MAX_ORDER_QUANTITY              ,
         MIN_ORDER_QUANTITY              ,
         MIN_RELEASE_AMOUNT              ,
         NEGOTIATED_BY_PREPARER_FLAG     ,
         NOTE_TO_VENDOR                  ,
         NOT_TO_EXCEED_PRICE             ,
         OVER_TOLERANCE_ERROR_FLAG       ,
         PO_HEADER_ID                    ,
         PO_LINE_ID                      ,
         PRICE_BREAK_LOOKUP_CODE         ,
         PRICE_TYPE_LOOKUP_CODE          ,
         PROGRAM_APPLICATION_ID          ,
         PROGRAM_ID                      ,
         PROGRAM_UPDATE_DATE             ,
         QTY_RCV_TOLERANCE               ,
         QUANTITY                        ,
         QUANTITY_COMMITTED              ,
         REFERENCE_NUM                   ,
         REQUEST_ID                      ,
         REVISION_NUM                    ,
         TAXABLE_FLAG                    ,
         TRANSACTION_REASON_CODE         ,
         TYPE_1099                       ,
         UNIT_MEAS_LOOKUP_CODE           ,
         UNIT_PRICE                      ,
         UNORDERED_FLAG                  ,
         UN_NUMBER_ID                    ,
         USER_HOLD_FLAG                  ,
         USSGL_TRANSACTION_CODE          ,
         VENDOR_PRODUCT_NUM              )
     SELECT
         POL.ALLOW_PRICE_OVERRIDE_FLAG       ,
         POL.ATTRIBUTE1                      ,
         POL.ATTRIBUTE10                     ,
         POL.ATTRIBUTE11                     ,
         POL.ATTRIBUTE12                     ,
         POL.ATTRIBUTE13                     ,
         POL.ATTRIBUTE14                     ,
         POL.ATTRIBUTE15                     ,
         POL.ATTRIBUTE2                      ,
         POL.ATTRIBUTE3                      ,
         POL.ATTRIBUTE4                      ,
         POL.ATTRIBUTE5                      ,
         POL.ATTRIBUTE6                      ,
         POL.ATTRIBUTE7                      ,
         POL.ATTRIBUTE8                      ,
         POL.ATTRIBUTE9                      ,
         POL.ATTRIBUTE_CATEGORY              ,
         POL.CANCELLED_BY                    ,
         POL.CANCEL_DATE                     ,
         POL.CANCEL_FLAG                     ,
         POL.CANCEL_REASON                   ,
         POL.CAPITAL_EXPENSE_FLAG            ,
         POL.CATEGORY_ID                     ,
         POL.CLOSED_BY                       ,
         POL.CLOSED_CODE                     ,
         POL.CLOSED_DATE                     ,
         POL.CLOSED_FLAG                     ,
         POL.CLOSED_REASON                   ,
         POL.COMMITTED_AMOUNT                ,
         POL.CONTRACT_NUM                    ,
         POL.CREATED_BY                      ,
         POL.CREATION_DATE                   ,
         POL.FIRM_STATUS_LOOKUP_CODE         ,
         POL.FROM_HEADER_ID                  ,
         POL.FROM_LINE_ID                    ,
         POL.GOVERNMENT_CONTEXT              ,
         POL.HAZARD_CLASS_ID                 ,
         POL.ITEM_DESCRIPTION                ,
         POL.ITEM_ID                         ,
         POL.ITEM_REVISION                   ,
         POL.LAST_UPDATED_BY                 ,
         POL.LAST_UPDATE_DATE                ,
         POL.LAST_UPDATE_LOGIN               ,
         'Y'                                 ,
         POL.LINE_NUM                        ,
         POL.LINE_TYPE_ID                    ,
         POL.LIST_PRICE_PER_UNIT             ,
         POL.MARKET_PRICE                    ,
         POL.MAX_ORDER_QUANTITY              ,
         POL.MIN_ORDER_QUANTITY              ,
         POL.MIN_RELEASE_AMOUNT              ,
         POL.NEGOTIATED_BY_PREPARER_FLAG     ,
         POL.NOTE_TO_VENDOR                  ,
         POL.NOT_TO_EXCEED_PRICE             ,
         POL.OVER_TOLERANCE_ERROR_FLAG       ,
         POL.PO_HEADER_ID                    ,
         POL.PO_LINE_ID                      ,
         POL.PRICE_BREAK_LOOKUP_CODE         ,
         POL.PRICE_TYPE_LOOKUP_CODE          ,
         POL.PROGRAM_APPLICATION_ID          ,
         POL.PROGRAM_ID                      ,
         POL.PROGRAM_UPDATE_DATE             ,
         POL.QTY_RCV_TOLERANCE               ,
         POL.QUANTITY                        ,
         POL.QUANTITY_COMMITTED              ,
         POL.REFERENCE_NUM                   ,
         POL.REQUEST_ID                      ,
         p_revision_num                      ,
         POL.TAXABLE_FLAG                    ,
         POL.TRANSACTION_REASON_CODE         ,
         POL.TYPE_1099                       ,
         POL.UNIT_MEAS_LOOKUP_CODE           ,
         POL.UNIT_PRICE                      ,
         POL.UNORDERED_FLAG                  ,
         POL.UN_NUMBER_ID                    ,
         POL.USER_HOLD_FLAG                  ,
         POL.USSGL_TRANSACTION_CODE          ,
         POL.VENDOR_PRODUCT_NUM
    FROM  PO_LINES POL,
          PO_LINES_ARCHIVE POLA
    WHERE POL.PO_HEADER_ID              = p_document_id
    AND   POL.PO_LINE_ID                = POLA.PO_LINE_ID (+)
    AND   POLA.LATEST_EXTERNAL_FLAG (+) = 'Y'
    AND (
            (POLA.PO_LINE_ID IS NULL)
      OR (POL.LINE_NUM <> POLA.LINE_NUM)
      OR (POL.QUANTITY <> POLA.QUANTITY)
      OR (POL.QUANTITY IS NULL AND POLA.QUANTITY IS NOT NULL)
      OR (POL.QUANTITY IS NOT NULL AND POLA.QUANTITY IS NULL)
      OR (POL.ITEM_ID <> POLA.ITEM_ID)
      OR (POL.ITEM_ID IS NULL AND POLA.ITEM_ID IS NOT NULL)
      OR (POL.ITEM_ID IS NOT NULL AND POLA.ITEM_ID IS NULL)
      OR (POL.ITEM_REVISION <> POLA.ITEM_REVISION)
      OR (POL.ITEM_REVISION IS NULL AND POLA.ITEM_REVISION IS NOT NULL)
      OR (POL.ITEM_REVISION IS NOT NULL AND POLA.ITEM_REVISION IS NULL)
      OR (POL.ITEM_DESCRIPTION <> POLA.ITEM_DESCRIPTION)
      OR (POL.ITEM_DESCRIPTION IS NULL
                AND POLA.ITEM_DESCRIPTION IS NOT NULL)
      OR (POL.ITEM_DESCRIPTION IS NOT NULL
                AND POLA.ITEM_DESCRIPTION IS NULL)
      OR (POL.UNIT_MEAS_LOOKUP_CODE <> POLA.UNIT_MEAS_LOOKUP_CODE)
      OR (POL.UNIT_MEAS_LOOKUP_CODE IS NULL
                AND POLA.UNIT_MEAS_LOOKUP_CODE IS NOT NULL)
      OR (POL.UNIT_MEAS_LOOKUP_CODE IS NOT NULL
                AND POLA.UNIT_MEAS_LOOKUP_CODE IS NULL)
      OR (POL.QUANTITY_COMMITTED <> POLA.QUANTITY_COMMITTED)
      OR (POL.QUANTITY_COMMITTED IS NULL
                AND POLA.QUANTITY_COMMITTED IS NOT NULL)
      OR (POL.QUANTITY_COMMITTED IS NOT NULL
                AND POLA.QUANTITY_COMMITTED IS NULL)
      OR (POL.COMMITTED_AMOUNT <> POLA.COMMITTED_AMOUNT)
      OR (POL.COMMITTED_AMOUNT IS NULL
                AND POLA.COMMITTED_AMOUNT IS NOT NULL)
      OR (POL.COMMITTED_AMOUNT IS NOT NULL
                AND POLA.COMMITTED_AMOUNT IS NULL)
      OR (POL.UNIT_PRICE <> POLA.UNIT_PRICE)
      OR (POL.UNIT_PRICE IS NULL AND POLA.UNIT_PRICE IS NOT NULL)
      OR (POL.UNIT_PRICE IS NOT NULL AND POLA.UNIT_PRICE IS NULL)
      OR (POL.UN_NUMBER_ID <> POLA.UN_NUMBER_ID)
      OR (POL.UN_NUMBER_ID IS NULL AND POLA.UN_NUMBER_ID IS NOT NULL)
      OR (POL.UN_NUMBER_ID IS NOT NULL AND POLA.UN_NUMBER_ID IS NULL)
      OR (POL.HAZARD_CLASS_ID <> POLA.HAZARD_CLASS_ID)
      OR (POL.HAZARD_CLASS_ID IS NULL
                AND POLA.HAZARD_CLASS_ID IS NOT NULL)
      OR (POL.HAZARD_CLASS_ID IS NOT NULL
                AND POLA.HAZARD_CLASS_ID IS NULL)
      OR (POL.NOTE_TO_VENDOR <> POLA.NOTE_TO_VENDOR)
      OR (POL.NOTE_TO_VENDOR IS NULL
                AND POLA.NOTE_TO_VENDOR IS NOT NULL)
      OR (POL.NOTE_TO_VENDOR IS NOT NULL
                AND POLA.NOTE_TO_VENDOR IS NULL)
      OR (POL.FROM_HEADER_ID <> POLA.FROM_HEADER_ID)
      OR (POL.FROM_HEADER_ID IS NULL
                AND POLA.FROM_HEADER_ID IS NOT NULL)
      OR (POL.FROM_HEADER_ID IS NOT NULL
                AND POLA.FROM_HEADER_ID IS NULL)
      OR (POL.FROM_LINE_ID <> POLA.FROM_LINE_ID)
      OR (POL.FROM_LINE_ID IS NULL
                AND POLA.FROM_LINE_ID IS NOT NULL)
      OR (POL.FROM_LINE_ID IS NOT NULL
                AND POLA.FROM_LINE_ID IS NULL)
      OR (POL.CLOSED_FLAG = 'Y'
                AND NVL(POLA.CLOSED_FLAG, 'N') = 'N')
      OR (POL.VENDOR_PRODUCT_NUM <> POLA.VENDOR_PRODUCT_NUM)
      OR (POL.VENDOR_PRODUCT_NUM IS NULL
                AND POLA.VENDOR_PRODUCT_NUM IS NOT NULL)
      OR (POL.VENDOR_PRODUCT_NUM IS NOT NULL
                AND POLA.VENDOR_PRODUCT_NUM IS NULL)
      OR (POL.CONTRACT_NUM <> POLA.CONTRACT_NUM)
      OR (POL.CONTRACT_NUM IS NULL
                AND POLA.CONTRACT_NUM IS NOT NULL)
      OR (POL.CONTRACT_NUM IS NOT NULL
                AND POLA.CONTRACT_NUM IS NULL)
      OR (POL.PRICE_TYPE_LOOKUP_CODE <> POLA.PRICE_TYPE_LOOKUP_CODE)
      OR (POL.PRICE_TYPE_LOOKUP_CODE IS NULL
                AND POLA.PRICE_TYPE_LOOKUP_CODE IS NOT NULL)
      OR (POL.PRICE_TYPE_LOOKUP_CODE IS NOT NULL
                AND POLA.PRICE_TYPE_LOOKUP_CODE IS NULL));

    IF SQL%FOUND THEN
        --  Assert: Insert statement processed at least one row.
        --  Set the latest_external_flag to 'N' for all rows which have:
        --       - latest_external_flag = 'Y'
        --       - revision_num < p_revision_num  (the new revision of the
        --                                        header)
        --       - have no new archived row
        UPDATE PO_LINES_ARCHIVE POL1
        SET   LATEST_EXTERNAL_FLAG = 'N'
        WHERE PO_HEADER_ID         = p_document_id
        AND   LATEST_EXTERNAL_FLAG = 'Y'
        AND   REVISION_NUM         < p_revision_num
        AND   EXISTS
            (SELECT 'A new archived row'
             FROM   PO_LINES_ARCHIVE POL2
             WHERE  POL2.PO_LINE_ID           = POL1.PO_LINE_ID
             AND    POL2.LATEST_EXTERNAL_FLAG = 'Y'
             AND    POL2.REVISION_NUM         = p_revision_num);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        global_stack := 'PORARLINES(P_DOCUMENT_ID='''||p_document_id||
			  ''' P_REVISION_NUM='''||p_revision_num||
			  '''):'||global_stack;
        RAISE;

END PORARLINES;

-- ============================================================================
--  Name: porarshipdist
--  Desc: Archive PO_LINE_LOCATIONS and PO_DISTRIBUTIONS
--  Args: IN:  p_document_id      - The unique identifier of the Purchase Order
--             p_revision_num     - The revision number of the header
--  Err : Error message context returned in global_stack.
--  Algr: Set the LATEST_EXTERNAL_FLAG of the currently archived line locations
--             to "N"
--        Archive the line locations.
--        Set the LATEST_EXTERNAL_FLAG of the currently archived distributions
--             to "N"
--        Archive the distributions.
--  Note: private procedure
-- ============================================================================

PROCEDURE PORARSHIPDIST (
                        P_DOCUMENT_ID IN NUMBER,
                        P_REVISION_NUM IN NUMBER)
IS

BEGIN
    --  Archive the line locations.
    --  This will be an exact copy of po_line_locations except for the
    --  latest_external_flag and the revision_num.  Keep the columns
    --  in alphabetical order for easy verification.
    INSERT INTO PO_LINE_LOCATIONS_ARCHIVE
        (
         ACCRUE_ON_RECEIPT_FLAG          ,
         ALLOW_SUBSTITUTE_RECEIPTS_FLAG  ,
         APPROVED_DATE                   ,
         APPROVED_FLAG                   ,
         ATTRIBUTE1                      ,
         ATTRIBUTE10                     ,
         ATTRIBUTE11                     ,
         ATTRIBUTE12                     ,
         ATTRIBUTE13                     ,
         ATTRIBUTE14                     ,
         ATTRIBUTE15                     ,
         ATTRIBUTE2                      ,
         ATTRIBUTE3                      ,
         ATTRIBUTE4                      ,
         ATTRIBUTE5                      ,
         ATTRIBUTE6                      ,
         ATTRIBUTE7                      ,
         ATTRIBUTE8                      ,
         ATTRIBUTE9                      ,
         ATTRIBUTE_CATEGORY              ,
         CANCELLED_BY                    ,
         CANCEL_DATE                     ,
         CANCEL_FLAG                     ,
         CANCEL_REASON                   ,
         CLOSED_BY                       ,
         CLOSED_CODE                     ,
         CLOSED_DATE                     ,
         CLOSED_FLAG                     ,
         CLOSED_REASON                   ,
         CREATED_BY                      ,
         CREATION_DATE                   ,
         DAYS_EARLY_RECEIPT_ALLOWED      ,
         DAYS_LATE_RECEIPT_ALLOWED       ,
         ENCUMBERED_DATE                 ,
         ENCUMBERED_FLAG                 ,
         ENCUMBER_NOW                    ,
         END_DATE                        ,
         ENFORCE_SHIP_TO_LOCATION_CODE   ,
         ESTIMATED_TAX_AMOUNT            ,
         FIRM_STATUS_LOOKUP_CODE         ,
         FOB_LOOKUP_CODE                 ,
         FREIGHT_TERMS_LOOKUP_CODE       ,
         FROM_HEADER_ID                  ,
         FROM_LINE_ID                    ,
         FROM_LINE_LOCATION_ID           ,
         GOVERNMENT_CONTEXT              ,
         INSPECTION_REQUIRED_FLAG        ,
         INVOICE_CLOSE_TOLERANCE         ,
         LAST_ACCEPT_DATE                ,
         LAST_UPDATED_BY                 ,
         LAST_UPDATE_DATE                ,
         LAST_UPDATE_LOGIN               ,
         LATEST_EXTERNAL_FLAG            ,
         LEAD_TIME                       ,
         LEAD_TIME_UNIT                  ,
         LINE_LOCATION_ID                ,
         NEED_BY_DATE                    ,
         PO_HEADER_ID                    ,
         PO_LINE_ID                      ,
         PO_RELEASE_ID                   ,
         PRICE_DISCOUNT                  ,
         PRICE_OVERRIDE                  ,
         PROGRAM_APPLICATION_ID          ,
         PROGRAM_ID                      ,
         PROGRAM_UPDATE_DATE             ,
         PROMISED_DATE                   ,
         QTY_RCV_EXCEPTION_CODE          ,
         QTY_RCV_TOLERANCE               ,
         QUANTITY                        ,
         QUANTITY_ACCEPTED               ,
         QUANTITY_BILLED                 ,
         QUANTITY_CANCELLED              ,
         QUANTITY_RECEIVED               ,
         QUANTITY_REJECTED               ,
         RECEIPT_DAYS_EXCEPTION_CODE     ,
         RECEIPT_REQUIRED_FLAG           ,
         RECEIVE_CLOSE_TOLERANCE         ,
         RECEIVING_ROUTING_ID            ,
         REQUEST_ID                      ,
         REVISION_NUM                    ,
         SHIPMENT_NUM                    ,
         SHIPMENT_TYPE                   ,
         SHIP_TO_LOCATION_ID             ,
         SHIP_TO_ORGANIZATION_ID         ,
         SHIP_VIA_LOOKUP_CODE            ,
         SOURCE_SHIPMENT_ID              ,
         START_DATE                      ,
         TAXABLE_FLAG                    ,
         TERMS_ID                        ,
         UNENCUMBERED_QUANTITY           ,
         UNIT_MEAS_LOOKUP_CODE           ,
         UNIT_OF_MEASURE_CLASS           ,
         USSGL_TRANSACTION_CODE          )
    SELECT
         POL.ACCRUE_ON_RECEIPT_FLAG          ,
         POL.ALLOW_SUBSTITUTE_RECEIPTS_FLAG  ,
         POL.APPROVED_DATE                   ,
         POL.APPROVED_FLAG                   ,
         POL.ATTRIBUTE1                      ,
         POL.ATTRIBUTE10                     ,
         POL.ATTRIBUTE11                     ,
         POL.ATTRIBUTE12                     ,
         POL.ATTRIBUTE13                     ,
         POL.ATTRIBUTE14                     ,
         POL.ATTRIBUTE15                     ,
         POL.ATTRIBUTE2                      ,
         POL.ATTRIBUTE3                      ,
         POL.ATTRIBUTE4                      ,
         POL.ATTRIBUTE5                      ,
         POL.ATTRIBUTE6                      ,
         POL.ATTRIBUTE7                      ,
         POL.ATTRIBUTE8                      ,
         POL.ATTRIBUTE9                      ,
         POL.ATTRIBUTE_CATEGORY              ,
         POL.CANCELLED_BY                    ,
         POL.CANCEL_DATE                     ,
         POL.CANCEL_FLAG                     ,
         POL.CANCEL_REASON                   ,
         POL.CLOSED_BY                       ,
         POL.CLOSED_CODE                     ,
         POL.CLOSED_DATE                     ,
         POL.CLOSED_FLAG                     ,
         POL.CLOSED_REASON                   ,
         POL.CREATED_BY                      ,
         POL.CREATION_DATE                   ,
         POL.DAYS_EARLY_RECEIPT_ALLOWED      ,
         POL.DAYS_LATE_RECEIPT_ALLOWED       ,
         POL.ENCUMBERED_DATE                 ,
         POL.ENCUMBERED_FLAG                 ,
         POL.ENCUMBER_NOW                    ,
         POL.END_DATE                        ,
         POL.ENFORCE_SHIP_TO_LOCATION_CODE   ,
         POL.ESTIMATED_TAX_AMOUNT            ,
         POL.FIRM_STATUS_LOOKUP_CODE         ,
         POL.FOB_LOOKUP_CODE                 ,
         POL.FREIGHT_TERMS_LOOKUP_CODE       ,
         POL.FROM_HEADER_ID                  ,
         POL.FROM_LINE_ID                    ,
         POL.FROM_LINE_LOCATION_ID           ,
         POL.GOVERNMENT_CONTEXT              ,
         POL.INSPECTION_REQUIRED_FLAG        ,
         POL.INVOICE_CLOSE_TOLERANCE         ,
         POL.LAST_ACCEPT_DATE                ,
         POL.LAST_UPDATED_BY                 ,
         POL.LAST_UPDATE_DATE                ,
         POL.LAST_UPDATE_LOGIN               ,
         'Y'                                 ,
         POL.LEAD_TIME                       ,
         POL.LEAD_TIME_UNIT                  ,
         POL.LINE_LOCATION_ID                ,
         POL.NEED_BY_DATE                    ,
         POL.PO_HEADER_ID                    ,
         POL.PO_LINE_ID                      ,
         POL.PO_RELEASE_ID                   ,
         POL.PRICE_DISCOUNT                  ,
         POL.PRICE_OVERRIDE                  ,
         POL.PROGRAM_APPLICATION_ID          ,
         POL.PROGRAM_ID                      ,
         POL.PROGRAM_UPDATE_DATE             ,
         POL.PROMISED_DATE                   ,
         POL.QTY_RCV_EXCEPTION_CODE          ,
         POL.QTY_RCV_TOLERANCE               ,
         POL.QUANTITY                        ,
         POL.QUANTITY_ACCEPTED               ,
         POL.QUANTITY_BILLED                 ,
         POL.QUANTITY_CANCELLED              ,
         POL.QUANTITY_RECEIVED               ,
         POL.QUANTITY_REJECTED               ,
         POL.RECEIPT_DAYS_EXCEPTION_CODE     ,
         POL.RECEIPT_REQUIRED_FLAG           ,
         POL.RECEIVE_CLOSE_TOLERANCE         ,
         POL.RECEIVING_ROUTING_ID            ,
         POL.REQUEST_ID                      ,
         p_revision_num                      ,
         POL.SHIPMENT_NUM                    ,
         POL.SHIPMENT_TYPE                   ,
         POL.SHIP_TO_LOCATION_ID             ,
         POL.SHIP_TO_ORGANIZATION_ID         ,
         POL.SHIP_VIA_LOOKUP_CODE            ,
         POL.SOURCE_SHIPMENT_ID              ,
         POL.START_DATE                      ,
         POL.TAXABLE_FLAG                    ,
         POL.TERMS_ID                        ,
         POL.UNENCUMBERED_QUANTITY           ,
         POL.UNIT_MEAS_LOOKUP_CODE           ,
         POL.UNIT_OF_MEASURE_CLASS           ,
         POL.USSGL_TRANSACTION_CODE
    FROM PO_LINE_LOCATIONS POL,
         PO_LINE_LOCATIONS_ARCHIVE POLA
    WHERE POL.PO_HEADER_ID              = p_document_id
    AND   POL.LINE_LOCATION_ID          = POLA.LINE_LOCATION_ID (+)
    AND   POLA.LATEST_EXTERNAL_FLAG (+) = 'Y'
    AND   (
             (POLA.LINE_LOCATION_ID IS NULL)
          OR (POL.QUANTITY <> POLA.QUANTITY)
          OR (POL.QUANTITY IS NULL AND POLA.QUANTITY IS NOT NULL)
          OR (POL.QUANTITY IS NOT NULL AND POLA.QUANTITY IS NULL)
          OR (POL.SHIP_TO_LOCATION_ID <> POLA.SHIP_TO_LOCATION_ID)
          OR (POL.SHIP_TO_LOCATION_ID IS NULL
                   AND POLA.SHIP_TO_LOCATION_ID IS NOT NULL)
          OR (POL.SHIP_TO_LOCATION_ID IS NOT NULL
                   AND POLA.SHIP_TO_LOCATION_ID IS NULL)
          OR (POL.NEED_BY_DATE <> POLA.NEED_BY_DATE)
          OR (POL.NEED_BY_DATE IS NULL
                   AND POLA.NEED_BY_DATE IS NOT NULL)
          OR (POL.NEED_BY_DATE IS NOT NULL
                   AND POLA.NEED_BY_DATE IS NULL)
          OR (POL.PROMISED_DATE <> POLA.PROMISED_DATE)
          OR (POL.PROMISED_DATE IS NULL
                   AND POLA.PROMISED_DATE IS NOT NULL)
          OR (POL.PROMISED_DATE IS NOT NULL
                   AND POLA.PROMISED_DATE IS NULL)
          OR (POL.LAST_ACCEPT_DATE <> POLA.LAST_ACCEPT_DATE)
          OR (POL.LAST_ACCEPT_DATE IS NULL
                   AND POLA.LAST_ACCEPT_DATE IS NOT NULL)
          OR (POL.LAST_ACCEPT_DATE IS NOT NULL
                   AND POLA.LAST_ACCEPT_DATE IS NULL)
          OR (POL.PRICE_OVERRIDE <> POLA.PRICE_OVERRIDE)
          OR (POL.PRICE_OVERRIDE IS NULL
                   AND POLA.PRICE_OVERRIDE IS NOT NULL)
          OR (POL.PRICE_OVERRIDE IS NOT NULL
                   AND POLA.PRICE_OVERRIDE IS NULL)
          OR (POL.TAXABLE_FLAG <> POLA.TAXABLE_FLAG)
          OR (POL.TAXABLE_FLAG IS NULL
                   AND POLA.TAXABLE_FLAG IS NOT NULL)
          OR (POL.TAXABLE_FLAG IS NOT NULL
                   AND POLA.TAXABLE_FLAG IS NULL)
          OR (POL.CANCEL_FLAG = 'Y'
                   AND NVL(POLA.CANCEL_FLAG,'N') = 'N')
          OR (POL.SHIPMENT_NUM <> POLA.SHIPMENT_NUM)
          OR (POL.SHIPMENT_NUM IS NULL
                   AND POLA.SHIPMENT_NUM IS NOT NULL)
          OR (POL.SHIPMENT_NUM IS NOT NULL
                   AND POLA.SHIPMENT_NUM IS NULL));

    IF SQL%FOUND THEN
        --  Assert:  At least one row was processed in the sql statement.
        --  Set the latest_external_flag to 'N' for all rows which have:
        --        - latest_external_flag = 'Y'
        --        - revision_num < p_revision_num  (the new revision of the
        --                                         header)
        --        - have no new archived row
        UPDATE PO_LINE_LOCATIONS_ARCHIVE POL1
        SET   LATEST_EXTERNAL_FLAG = 'N'
        WHERE PO_HEADER_ID         = p_document_id
        AND   LATEST_EXTERNAL_FLAG = 'Y'
        AND   REVISION_NUM         < p_revision_num
        AND   EXISTS
            (SELECT 'A new archived row'
             FROM   PO_LINE_LOCATIONS_ARCHIVE POL2
             WHERE  POL2.LINE_LOCATION_ID     = POL1.LINE_LOCATION_ID
             AND    POL2.LATEST_EXTERNAL_FLAG = 'Y'
             AND    POL2.REVISION_NUM         = p_revision_num);
    END IF;

    --  Archive the distributions.
    --  This will be an exact copy of po_distributions except for the
    --  latest_external_flag and the revision_num.  Keep the columns
    --  in alphabetical order for easy verification.
    INSERT INTO PO_DISTRIBUTIONS_ARCHIVE
        (
         ACCRUAL_ACCOUNT_ID              ,
         ACCRUED_FLAG                    ,
         ACCRUE_ON_RECEIPT_FLAG          ,
         AMOUNT_BILLED                   ,
         ATTRIBUTE1                      ,
         ATTRIBUTE10                     ,
         ATTRIBUTE11                     ,
         ATTRIBUTE12                     ,
         ATTRIBUTE13                     ,
         ATTRIBUTE14                     ,
         ATTRIBUTE15                     ,
         ATTRIBUTE2                      ,
         ATTRIBUTE3                      ,
         ATTRIBUTE4                      ,
         ATTRIBUTE5                      ,
         ATTRIBUTE6                      ,
         ATTRIBUTE7                      ,
         ATTRIBUTE8                      ,
         ATTRIBUTE9                      ,
         ATTRIBUTE_CATEGORY              ,
         BOM_RESOURCE_ID                 ,
         BUDGET_ACCOUNT_ID               ,
         CODE_COMBINATION_ID             ,
         CREATED_BY                      ,
         CREATION_DATE                   ,
         DELIVER_TO_LOCATION_ID          ,
         DELIVER_TO_PERSON_ID            ,
         DESTINATION_CONTEXT             ,
         DESTINATION_ORGANIZATION_ID     ,
         DESTINATION_SUBINVENTORY        ,
         DESTINATION_TYPE_CODE           ,
         DISTRIBUTION_NUM                ,
         ENCUMBERED_AMOUNT               ,
         ENCUMBERED_FLAG                 ,
         EXPENDITURE_ITEM_DATE           ,
         EXPENDITURE_ORGANIZATION_ID     ,
         EXPENDITURE_TYPE                ,
         FAILED_FUNDS_LOOKUP_CODE        ,
         GL_CANCELLED_DATE               ,
         GL_CLOSED_DATE                  ,
         GL_ENCUMBERED_DATE              ,
         GL_ENCUMBERED_PERIOD_NAME       ,
         GOVERNMENT_CONTEXT              ,
         LAST_UPDATED_BY                 ,
         LAST_UPDATE_DATE                ,
         LAST_UPDATE_LOGIN               ,
         LATEST_EXTERNAL_FLAG            ,
         LINE_LOCATION_ID                ,
         PO_DISTRIBUTION_ID              ,
         PO_HEADER_ID                    ,
         PO_LINE_ID                      ,
         PO_RELEASE_ID                   ,
         PREVENT_ENCUMBRANCE_FLAG        ,
         PROGRAM_APPLICATION_ID          ,
         PROGRAM_ID                      ,
         PROGRAM_UPDATE_DATE             ,
         PROJECT_ACCOUNTING_CONTEXT      ,
         PROJECT_ID                      ,
         QUANTITY_BILLED                 ,
         QUANTITY_CANCELLED              ,
         QUANTITY_DELIVERED              ,
         QUANTITY_ORDERED                ,
         RATE                            ,
         RATE_DATE                       ,
         REQUEST_ID                      ,
         REQ_DISTRIBUTION_ID             ,
         REQ_HEADER_REFERENCE_NUM        ,
         REQ_LINE_REFERENCE_NUM          ,
         REVISION_NUM                    ,
         SET_OF_BOOKS_ID                 ,
         SOURCE_DISTRIBUTION_ID          ,
         TASK_ID                         ,
         UNENCUMBERED_AMOUNT             ,
         UNENCUMBERED_QUANTITY           ,
         USSGL_TRANSACTION_CODE          ,
         VARIANCE_ACCOUNT_ID             ,
         WIP_ENTITY_ID                   ,
         WIP_LINE_ID                     ,
         WIP_OPERATION_SEQ_NUM           ,
         WIP_REPETITIVE_SCHEDULE_ID      ,
         WIP_RESOURCE_SEQ_NUM            )
    SELECT
         POD.ACCRUAL_ACCOUNT_ID              ,
         POD.ACCRUED_FLAG                    ,
         POD.ACCRUE_ON_RECEIPT_FLAG           ,
         POD.AMOUNT_BILLED                   ,
         POD.ATTRIBUTE1                      ,
         POD.ATTRIBUTE10                     ,
         POD.ATTRIBUTE11                     ,
         POD.ATTRIBUTE12                     ,
         POD.ATTRIBUTE13                     ,
         POD.ATTRIBUTE14                     ,
         POD.ATTRIBUTE15                     ,
         POD.ATTRIBUTE2                      ,
         POD.ATTRIBUTE3                      ,
         POD.ATTRIBUTE4                      ,
         POD.ATTRIBUTE5                      ,
         POD.ATTRIBUTE6                      ,
         POD.ATTRIBUTE7                      ,
         POD.ATTRIBUTE8                      ,
         POD.ATTRIBUTE9                      ,
         POD.ATTRIBUTE_CATEGORY              ,
         POD.BOM_RESOURCE_ID                 ,
         POD.BUDGET_ACCOUNT_ID               ,
         POD.CODE_COMBINATION_ID             ,
         POD.CREATED_BY                      ,
         POD.CREATION_DATE                   ,
         POD.DELIVER_TO_LOCATION_ID          ,
         POD.DELIVER_TO_PERSON_ID            ,
         POD.DESTINATION_CONTEXT             ,
         POD.DESTINATION_ORGANIZATION_ID     ,
         POD.DESTINATION_SUBINVENTORY        ,
         POD.DESTINATION_TYPE_CODE           ,
         POD.DISTRIBUTION_NUM                ,
         POD.ENCUMBERED_AMOUNT               ,
         POD.ENCUMBERED_FLAG                 ,
         POD.EXPENDITURE_ITEM_DATE           ,
         POD.EXPENDITURE_ORGANIZATION_ID     ,
         POD.EXPENDITURE_TYPE                ,
         POD.FAILED_FUNDS_LOOKUP_CODE        ,
         POD.GL_CANCELLED_DATE               ,
         POD.GL_CLOSED_DATE                  ,
         POD.GL_ENCUMBERED_DATE              ,
         POD.GL_ENCUMBERED_PERIOD_NAME       ,
         POD.GOVERNMENT_CONTEXT              ,
         POD.LAST_UPDATED_BY                 ,
         POD.LAST_UPDATE_DATE                ,
         POD.LAST_UPDATE_LOGIN               ,
         'Y'                                 ,
         POD.LINE_LOCATION_ID                ,
         POD.PO_DISTRIBUTION_ID              ,
         POD.PO_HEADER_ID                    ,
         POD.PO_LINE_ID                      ,
         POD.PO_RELEASE_ID                   ,
         POD.PREVENT_ENCUMBRANCE_FLAG        ,
         POD.PROGRAM_APPLICATION_ID          ,
         POD.PROGRAM_ID                      ,
         POD.PROGRAM_UPDATE_DATE             ,
         POD.PROJECT_ACCOUNTING_CONTEXT      ,
         POD.PROJECT_ID                      ,
         POD.QUANTITY_BILLED                 ,
         POD.QUANTITY_CANCELLED              ,
         POD.QUANTITY_DELIVERED              ,
         POD.QUANTITY_ORDERED                ,
         POD.RATE                            ,
         POD.RATE_DATE                       ,
         POD.REQUEST_ID                      ,
         POD.REQ_DISTRIBUTION_ID             ,
         POD.REQ_HEADER_REFERENCE_NUM        ,
         POD.REQ_LINE_REFERENCE_NUM          ,
         p_revision_num                      ,
         POD.SET_OF_BOOKS_ID                 ,
         POD.SOURCE_DISTRIBUTION_ID          ,
         POD.TASK_ID                         ,
         POD.UNENCUMBERED_AMOUNT             ,
         POD.UNENCUMBERED_QUANTITY           ,
         POD.USSGL_TRANSACTION_CODE          ,
         POD.VARIANCE_ACCOUNT_ID             ,
         POD.WIP_ENTITY_ID                   ,
         POD.WIP_LINE_ID                     ,
         POD.WIP_OPERATION_SEQ_NUM           ,
         POD.WIP_REPETITIVE_SCHEDULE_ID      ,
         POD.WIP_RESOURCE_SEQ_NUM
    FROM PO_DISTRIBUTIONS POD,
         PO_DISTRIBUTIONS_ARCHIVE PODA
    WHERE POD.PO_HEADER_ID              = p_document_id
    AND   POD.PO_DISTRIBUTION_ID        = PODA.PO_DISTRIBUTION_ID (+)
    AND   PODA.LATEST_EXTERNAL_FLAG (+) = 'Y'
    AND (
             (PODA.PO_DISTRIBUTION_ID IS NULL)
          OR (POD.QUANTITY_ORDERED <> PODA.QUANTITY_ORDERED)
          OR (POD.QUANTITY_ORDERED IS NULL
                  AND PODA.QUANTITY_ORDERED IS NOT NULL)
          OR (POD.QUANTITY_ORDERED IS NOT NULL
                  AND PODA.QUANTITY_ORDERED IS NULL)
          OR (POD.DELIVER_TO_PERSON_ID <> PODA.DELIVER_TO_PERSON_ID)
          OR (POD.DELIVER_TO_PERSON_ID IS NULL
                  AND PODA.DELIVER_TO_PERSON_ID IS NOT NULL)
          OR (POD.DELIVER_TO_PERSON_ID IS NOT NULL
                  AND PODA.DELIVER_TO_PERSON_ID IS NULL)
          OR (POD.DISTRIBUTION_NUM <> PODA.DISTRIBUTION_NUM));

    IF SQL%FOUND THEN
        --  Assert: At least one row was processed in the sql statement.
        --  Set the latest_external_flag to 'N' for all rows which have:
        --           - latest_external_flag = 'Y'
        --           - revision_num < p_revision_num  (the new revision of the
        --                                            header)
        --           - have no new archived row
        UPDATE PO_DISTRIBUTIONS_ARCHIVE POD1
        SET   LATEST_EXTERNAL_FLAG = 'N'
        WHERE PO_HEADER_ID         = p_document_id
        AND   LATEST_EXTERNAL_FLAG = 'Y'
        AND   REVISION_NUM         < p_revision_num
        AND   EXISTS
            (SELECT 'A new archived row'
             FROM   PO_DISTRIBUTIONS_ARCHIVE POD2
             WHERE  POD2.PO_DISTRIBUTION_ID   = POD1.PO_DISTRIBUTION_ID
             AND    POD2.LATEST_EXTERNAL_FLAG = 'Y'
             AND    POD2.REVISION_NUM         = p_revision_num);

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        global_stack := 'PORARSHIPDIST(P_DOCUMENT_ID='''||p_document_id||
			  ''' P_REVISION_NUM='''||p_revision_num||
			  '''):'||global_stack;
        RAISE;

END PORARSHIPDIST;

-- ============================================================================
--  Name: porarrelease
--  Desc: Archive PO_RELEASES, PO_LINE_LOCATIONS and PO_DISTRIBUTIONS
--  Args: IN:  p_document_id        - The unique identifier of the Release
--             p_revision_num       - The revision number of the header
--  Err : Error message context returned in global_stack.
--  Algr: Set the LATEST_EXTERNAL_FLAG of the currently archived release
--             to "N"
--        Archive PO_RELEASES
--        Archive PO_LINE_LOCATIONS
--        Archive PO_DISTRIBUTIONS
--  Note: Private Procedure
-- ============================================================================

PROCEDURE PORARRELEASE (
                        P_DOCUMENT_ID IN NUMBER,
                        P_REVISION_NUM IN NUMBER)
IS

BEGIN
    --  Set the latest_external_flag of the archived header to 'N'.
    UPDATE PO_RELEASES_ARCHIVE
    SET   LATEST_EXTERNAL_FLAG = 'N'
    WHERE PO_RELEASE_ID        = p_document_id
    AND   LATEST_EXTERNAL_FLAG = 'Y';

    --  Archive the release.
    INSERT INTO PO_RELEASES_ARCHIVE
        (
         ACCEPTANCE_DUE_DATE             ,
         ACCEPTANCE_REQUIRED_FLAG        ,
         AGENT_ID                        ,
         APPROVED_DATE                   ,
         APPROVED_FLAG                   ,
         ATTRIBUTE1                      ,
         ATTRIBUTE10                     ,
         ATTRIBUTE11                     ,
         ATTRIBUTE12                     ,
         ATTRIBUTE13                     ,
         ATTRIBUTE14                     ,
         ATTRIBUTE15                     ,
         ATTRIBUTE2                      ,
         ATTRIBUTE3                      ,
         ATTRIBUTE4                      ,
         ATTRIBUTE5                      ,
         ATTRIBUTE6                      ,
         ATTRIBUTE7                      ,
         ATTRIBUTE8                      ,
         ATTRIBUTE9                      ,
         ATTRIBUTE_CATEGORY              ,
         AUTHORIZATION_STATUS            ,
         CANCELLED_BY                    ,
         CANCEL_DATE                     ,
         CANCEL_FLAG                     ,
         CANCEL_REASON                   ,
         CLOSED_CODE                     ,
         CREATED_BY                      ,
         CREATION_DATE                   ,
         FIRM_STATUS_LOOKUP_CODE         ,
         FROZEN_FLAG                     ,
         GOVERNMENT_CONTEXT              ,
         HOLD_BY                         ,
         HOLD_DATE                       ,
         HOLD_FLAG                       ,
         HOLD_REASON                     ,
         LAST_UPDATED_BY                 ,
         LAST_UPDATE_DATE                ,
         LAST_UPDATE_LOGIN               ,
         LATEST_EXTERNAL_FLAG            ,
         NOTE_TO_VENDOR                  ,
         PO_HEADER_ID                    ,
         PO_RELEASE_ID                   ,
         PRINTED_DATE                    ,
         PRINT_COUNT                     ,
         PROGRAM_APPLICATION_ID          ,
         PROGRAM_ID                      ,
         PROGRAM_UPDATE_DATE             ,
         RELEASE_DATE                    ,
         RELEASE_NUM                     ,
         RELEASE_TYPE                    ,
         REQUEST_ID                      ,
         REVISED_DATE                    ,
         REVISION_NUM                    ,
         USSGL_TRANSACTION_CODE          )
    SELECT
         ACCEPTANCE_DUE_DATE             ,
         ACCEPTANCE_REQUIRED_FLAG        ,
         AGENT_ID                        ,
         APPROVED_DATE                   ,
         APPROVED_FLAG                   ,
         ATTRIBUTE1                      ,
         ATTRIBUTE10                     ,
         ATTRIBUTE11                     ,
         ATTRIBUTE12                     ,
         ATTRIBUTE13                     ,
         ATTRIBUTE14                     ,
         ATTRIBUTE15                     ,
         ATTRIBUTE2                      ,
         ATTRIBUTE3                      ,
         ATTRIBUTE4                      ,
         ATTRIBUTE5                      ,
         ATTRIBUTE6                      ,
         ATTRIBUTE7                      ,
         ATTRIBUTE8                      ,
         ATTRIBUTE9                      ,
         ATTRIBUTE_CATEGORY              ,
         AUTHORIZATION_STATUS            ,
         CANCELLED_BY                    ,
         CANCEL_DATE                     ,
         CANCEL_FLAG                     ,
         CANCEL_REASON                   ,
         CLOSED_CODE                     ,
         CREATED_BY                      ,
         CREATION_DATE                   ,
         FIRM_STATUS_LOOKUP_CODE         ,
         FROZEN_FLAG                     ,
         GOVERNMENT_CONTEXT              ,
         HOLD_BY                         ,
         HOLD_DATE                       ,
         HOLD_FLAG                       ,
         HOLD_REASON                     ,
         LAST_UPDATED_BY                 ,
         LAST_UPDATE_DATE                ,
         LAST_UPDATE_LOGIN               ,
         'Y'                             ,
         NOTE_TO_VENDOR                  ,
         PO_HEADER_ID                    ,
         PO_RELEASE_ID                   ,
         PRINTED_DATE                    ,
         PRINT_COUNT                     ,
         PROGRAM_APPLICATION_ID          ,
         PROGRAM_ID                      ,
         PROGRAM_UPDATE_DATE             ,
         RELEASE_DATE                    ,
         RELEASE_NUM                     ,
         RELEASE_TYPE                    ,
         REQUEST_ID                      ,
         REVISED_DATE                    ,
         REVISION_NUM                    ,
         USSGL_TRANSACTION_CODE
    FROM PO_RELEASES
    WHERE PO_RELEASE_ID = p_document_id;


    --  Archive the Shipments.
    INSERT INTO PO_LINE_LOCATIONS_ARCHIVE
        (
         ACCRUE_ON_RECEIPT_FLAG          ,
         ALLOW_SUBSTITUTE_RECEIPTS_FLAG  ,
         APPROVED_DATE                   ,
         APPROVED_FLAG                   ,
         ATTRIBUTE1                      ,
         ATTRIBUTE10                     ,
         ATTRIBUTE11                     ,
         ATTRIBUTE12                     ,
         ATTRIBUTE13                     ,
         ATTRIBUTE14                     ,
         ATTRIBUTE15                     ,
         ATTRIBUTE2                      ,
         ATTRIBUTE3                      ,
         ATTRIBUTE4                      ,
         ATTRIBUTE5                      ,
         ATTRIBUTE6                      ,
         ATTRIBUTE7                      ,
         ATTRIBUTE8                      ,
         ATTRIBUTE9                      ,
         ATTRIBUTE_CATEGORY              ,
         CANCELLED_BY                    ,
         CANCEL_DATE                     ,
         CANCEL_FLAG                     ,
         CANCEL_REASON                   ,
         CLOSED_BY                       ,
         CLOSED_CODE                     ,
         CLOSED_DATE                     ,
         CLOSED_FLAG                     ,
         CLOSED_REASON                   ,
         CREATED_BY                      ,
         CREATION_DATE                   ,
         DAYS_EARLY_RECEIPT_ALLOWED      ,
         DAYS_LATE_RECEIPT_ALLOWED       ,
         ENCUMBERED_DATE                 ,
         ENCUMBERED_FLAG                 ,
         ENCUMBER_NOW                    ,
         END_DATE                        ,
         ENFORCE_SHIP_TO_LOCATION_CODE   ,
         ESTIMATED_TAX_AMOUNT            ,
         FIRM_STATUS_LOOKUP_CODE         ,
         FOB_LOOKUP_CODE                 ,
         FREIGHT_TERMS_LOOKUP_CODE       ,
         FROM_HEADER_ID                  ,
         FROM_LINE_ID                    ,
         FROM_LINE_LOCATION_ID           ,
         GOVERNMENT_CONTEXT              ,
         INSPECTION_REQUIRED_FLAG        ,
         INVOICE_CLOSE_TOLERANCE         ,
         LAST_ACCEPT_DATE                ,
         LAST_UPDATED_BY                 ,
         LAST_UPDATE_DATE                ,
         LAST_UPDATE_LOGIN               ,
         LATEST_EXTERNAL_FLAG            ,
         LEAD_TIME                       ,
         LEAD_TIME_UNIT                  ,
         LINE_LOCATION_ID                ,
         NEED_BY_DATE                    ,
         PO_HEADER_ID                    ,
         PO_LINE_ID                      ,
         PO_RELEASE_ID                   ,
         PRICE_DISCOUNT                  ,
         PRICE_OVERRIDE                  ,
         PROGRAM_APPLICATION_ID          ,
         PROGRAM_ID                      ,
         PROGRAM_UPDATE_DATE             ,
         PROMISED_DATE                   ,
         QTY_RCV_EXCEPTION_CODE          ,
         QTY_RCV_TOLERANCE               ,
         QUANTITY                        ,
         QUANTITY_ACCEPTED               ,
         QUANTITY_BILLED                 ,
         QUANTITY_CANCELLED              ,
         QUANTITY_RECEIVED               ,
         QUANTITY_REJECTED               ,
         RECEIPT_DAYS_EXCEPTION_CODE     ,
         RECEIPT_REQUIRED_FLAG           ,
         RECEIVE_CLOSE_TOLERANCE         ,
         RECEIVING_ROUTING_ID            ,
         REQUEST_ID                      ,
         REVISION_NUM                    ,
         SHIPMENT_NUM                    ,
         SHIPMENT_TYPE                   ,
         SHIP_TO_LOCATION_ID             ,
         SHIP_TO_ORGANIZATION_ID         ,
         SHIP_VIA_LOOKUP_CODE            ,
         SOURCE_SHIPMENT_ID              ,
         START_DATE                      ,
         TAXABLE_FLAG                    ,
         TERMS_ID                        ,
         UNENCUMBERED_QUANTITY           ,
         UNIT_MEAS_LOOKUP_CODE           ,
         UNIT_OF_MEASURE_CLASS           ,
         USSGL_TRANSACTION_CODE          )
    SELECT
         POL.ACCRUE_ON_RECEIPT_FLAG          ,
         POL.ALLOW_SUBSTITUTE_RECEIPTS_FLAG  ,
         POL.APPROVED_DATE                   ,
         POL.APPROVED_FLAG                   ,
         POL.ATTRIBUTE1                      ,
         POL.ATTRIBUTE10                     ,
         POL.ATTRIBUTE11                     ,
         POL.ATTRIBUTE12                     ,
         POL.ATTRIBUTE13                     ,
         POL.ATTRIBUTE14                     ,
         POL.ATTRIBUTE15                     ,
         POL.ATTRIBUTE2                      ,
         POL.ATTRIBUTE3                      ,
         POL.ATTRIBUTE4                      ,
         POL.ATTRIBUTE5                      ,
         POL.ATTRIBUTE6                      ,
         POL.ATTRIBUTE7                      ,
         POL.ATTRIBUTE8                      ,
         POL.ATTRIBUTE9                      ,
         POL.ATTRIBUTE_CATEGORY              ,
         POL.CANCELLED_BY                    ,
         POL.CANCEL_DATE                     ,
         POL.CANCEL_FLAG                     ,
         POL.CANCEL_REASON                   ,
         POL.CLOSED_BY                       ,
         POL.CLOSED_CODE                     ,
         POL.CLOSED_DATE                     ,
         POL.CLOSED_FLAG                     ,
         POL.CLOSED_REASON                   ,
         POL.CREATED_BY                      ,
         POL.CREATION_DATE                   ,
         POL.DAYS_EARLY_RECEIPT_ALLOWED      ,
         POL.DAYS_LATE_RECEIPT_ALLOWED       ,
         POL.ENCUMBERED_DATE                 ,
         POL.ENCUMBERED_FLAG                 ,
         POL.ENCUMBER_NOW                    ,
         POL.END_DATE                        ,
         POL.ENFORCE_SHIP_TO_LOCATION_CODE   ,
         POL.ESTIMATED_TAX_AMOUNT            ,
         POL.FIRM_STATUS_LOOKUP_CODE         ,
         POL.FOB_LOOKUP_CODE                 ,
         POL.FREIGHT_TERMS_LOOKUP_CODE       ,
         POL.FROM_HEADER_ID                  ,
         POL.FROM_LINE_ID                    ,
         POL.FROM_LINE_LOCATION_ID           ,
         POL.GOVERNMENT_CONTEXT              ,
         POL.INSPECTION_REQUIRED_FLAG        ,
         POL.INVOICE_CLOSE_TOLERANCE         ,
         POL.LAST_ACCEPT_DATE                ,
         POL.LAST_UPDATED_BY                 ,
         POL.LAST_UPDATE_DATE                ,
         POL.LAST_UPDATE_LOGIN               ,
         'Y'                                 ,
         POL.LEAD_TIME                       ,
         POL.LEAD_TIME_UNIT                  ,
         POL.LINE_LOCATION_ID                ,
         POL.NEED_BY_DATE                    ,
         POL.PO_HEADER_ID                    ,
         POL.PO_LINE_ID                      ,
         POL.PO_RELEASE_ID                   ,
         POL.PRICE_DISCOUNT                  ,
         POL.PRICE_OVERRIDE                  ,
         POL.PROGRAM_APPLICATION_ID          ,
         POL.PROGRAM_ID                      ,
         POL.PROGRAM_UPDATE_DATE             ,
         POL.PROMISED_DATE                   ,
         POL.QTY_RCV_EXCEPTION_CODE          ,
         POL.QTY_RCV_TOLERANCE               ,
         POL.QUANTITY                        ,
         POL.QUANTITY_ACCEPTED               ,
         POL.QUANTITY_BILLED                 ,
         POL.QUANTITY_CANCELLED              ,
         POL.QUANTITY_RECEIVED               ,
         POL.QUANTITY_REJECTED               ,
         POL.RECEIPT_DAYS_EXCEPTION_CODE     ,
         POL.RECEIPT_REQUIRED_FLAG           ,
         POL.RECEIVE_CLOSE_TOLERANCE         ,
         POL.RECEIVING_ROUTING_ID            ,
         POL.REQUEST_ID                      ,
         p_revision_num                      ,
         POL.SHIPMENT_NUM                    ,
         POL.SHIPMENT_TYPE                   ,
         POL.SHIP_TO_LOCATION_ID             ,
         POL.SHIP_TO_ORGANIZATION_ID         ,
         POL.SHIP_VIA_LOOKUP_CODE            ,
         POL.SOURCE_SHIPMENT_ID              ,
         POL.START_DATE                      ,
         POL.TAXABLE_FLAG                    ,
         POL.TERMS_ID                        ,
         POL.UNENCUMBERED_QUANTITY           ,
         POL.UNIT_MEAS_LOOKUP_CODE           ,
         POL.UNIT_OF_MEASURE_CLASS           ,
         POL.USSGL_TRANSACTION_CODE
    FROM PO_LINE_LOCATIONS POL,
         PO_LINE_LOCATIONS_ARCHIVE POLA
    WHERE POL.PO_RELEASE_ID             = p_document_id
    AND   POL.LINE_LOCATION_ID          = POLA.LINE_LOCATION_ID (+)
    AND   POLA.LATEST_EXTERNAL_FLAG (+) = 'Y'
    AND   (
             (POLA.LINE_LOCATION_ID IS NULL)
          OR (POL.QUANTITY <> POLA.QUANTITY)
          OR (POL.QUANTITY IS NULL AND POLA.QUANTITY IS NOT NULL)
          OR (POL.QUANTITY IS NOT NULL AND POLA.QUANTITY IS NULL)
          OR (POL.SHIP_TO_LOCATION_ID <> POLA.SHIP_TO_LOCATION_ID)
          OR (POL.SHIP_TO_LOCATION_ID IS NULL
                   AND POLA.SHIP_TO_LOCATION_ID IS NOT NULL)
          OR (POL.SHIP_TO_LOCATION_ID IS NOT NULL
                   AND POLA.SHIP_TO_LOCATION_ID IS NULL)
          OR (POL.NEED_BY_DATE <> POLA.NEED_BY_DATE)
          OR (POL.NEED_BY_DATE IS NULL
                   AND POLA.NEED_BY_DATE IS NOT NULL)
          OR (POL.NEED_BY_DATE IS NOT NULL
                   AND POLA.NEED_BY_DATE IS NULL)
          OR (POL.PROMISED_DATE <> POLA.PROMISED_DATE)
          OR (POL.PROMISED_DATE IS NULL
                   AND POLA.PROMISED_DATE IS NOT NULL)
          OR (POL.PROMISED_DATE IS NOT NULL
                   AND POLA.PROMISED_DATE IS NULL)
          OR (POL.LAST_ACCEPT_DATE <> POLA.LAST_ACCEPT_DATE)
          OR (POL.LAST_ACCEPT_DATE IS NULL
                   AND POLA.LAST_ACCEPT_DATE IS NOT NULL)
          OR (POL.LAST_ACCEPT_DATE IS NOT NULL
                   AND POLA.LAST_ACCEPT_DATE IS NULL)
          OR (POL.PRICE_OVERRIDE <> POLA.PRICE_OVERRIDE)
          OR (POL.PRICE_OVERRIDE IS NULL
                   AND POLA.PRICE_OVERRIDE IS NOT NULL)
          OR (POL.PRICE_OVERRIDE IS NOT NULL
                   AND POLA.PRICE_OVERRIDE IS NULL)
          OR (POL.TAXABLE_FLAG <> POLA.TAXABLE_FLAG)
          OR (POL.TAXABLE_FLAG IS NULL
                   AND POLA.TAXABLE_FLAG IS NOT NULL)
          OR (POL.TAXABLE_FLAG IS NOT NULL
                   AND POLA.TAXABLE_FLAG IS NULL)
          OR (POL.CANCEL_FLAG = 'Y'
                   AND NVL(POLA.CANCEL_FLAG, 'N') = 'N')
          OR (POL.SHIPMENT_NUM <> POLA.SHIPMENT_NUM)
          OR (POL.SHIPMENT_NUM IS NULL
                   AND POLA.SHIPMENT_NUM IS NOT NULL)
          OR (POL.SHIPMENT_NUM IS NOT NULL
                   AND POLA.SHIPMENT_NUM IS NULL));

    IF SQL%FOUND THEN
        --  Assert: At least one row was processed in the insert statement.
        --  Set the latest_external_flag to 'N' for all rows which have:
        --           - latest_external_flag = 'Y'
        --           - revision_num < p_revision_num  (the new revision of the
        --                                            header)
        --           - no new archived row
        UPDATE PO_LINE_LOCATIONS_ARCHIVE POL1
        SET   LATEST_EXTERNAL_FLAG = 'N'
        WHERE PO_RELEASE_ID        = p_document_id
        AND   LATEST_EXTERNAL_FLAG = 'Y'
        AND   REVISION_NUM         < p_revision_num
        AND   EXISTS
            (SELECT 'A new archived row'
             FROM   PO_LINE_LOCATIONS_ARCHIVE POL2
             WHERE  POL2.LINE_LOCATION_ID     = POL1.LINE_LOCATION_ID
             AND    POL2.LATEST_EXTERNAL_FLAG = 'Y'
             AND    POL2.REVISION_NUM         = p_revision_num);

    END IF;

    --  Archive the distributions.
    INSERT INTO PO_DISTRIBUTIONS_ARCHIVE
        (
         ACCRUAL_ACCOUNT_ID              ,
         ACCRUED_FLAG                    ,
         ACCRUE_ON_RECEIPT_FLAG          ,
         AMOUNT_BILLED                   ,
         ATTRIBUTE1                      ,
         ATTRIBUTE10                     ,
         ATTRIBUTE11                     ,
         ATTRIBUTE12                     ,
         ATTRIBUTE13                     ,
         ATTRIBUTE14                     ,
         ATTRIBUTE15                     ,
         ATTRIBUTE2                      ,
         ATTRIBUTE3                      ,
         ATTRIBUTE4                      ,
         ATTRIBUTE5                      ,
         ATTRIBUTE6                      ,
         ATTRIBUTE7                      ,
         ATTRIBUTE8                      ,
         ATTRIBUTE9                      ,
         ATTRIBUTE_CATEGORY              ,
         BOM_RESOURCE_ID                 ,
         BUDGET_ACCOUNT_ID               ,
         CODE_COMBINATION_ID             ,
         CREATED_BY                      ,
         CREATION_DATE                   ,
         DELIVER_TO_LOCATION_ID          ,
         DELIVER_TO_PERSON_ID            ,
         DESTINATION_CONTEXT             ,
         DESTINATION_ORGANIZATION_ID     ,
         DESTINATION_SUBINVENTORY        ,
         DESTINATION_TYPE_CODE           ,
         DISTRIBUTION_NUM                ,
         ENCUMBERED_AMOUNT               ,
         ENCUMBERED_FLAG                 ,
         EXPENDITURE_ITEM_DATE           ,
         EXPENDITURE_ORGANIZATION_ID     ,
         EXPENDITURE_TYPE                ,
         FAILED_FUNDS_LOOKUP_CODE        ,
         GL_CANCELLED_DATE               ,
         GL_CLOSED_DATE                  ,
         GL_ENCUMBERED_DATE              ,
         GL_ENCUMBERED_PERIOD_NAME       ,
         GOVERNMENT_CONTEXT              ,
         LAST_UPDATED_BY                 ,
         LAST_UPDATE_DATE                ,
         LAST_UPDATE_LOGIN               ,
         LATEST_EXTERNAL_FLAG            ,
         LINE_LOCATION_ID                ,
         PO_DISTRIBUTION_ID              ,
         PO_HEADER_ID                    ,
         PO_LINE_ID                      ,
         PO_RELEASE_ID                   ,
         PREVENT_ENCUMBRANCE_FLAG        ,
         PROGRAM_APPLICATION_ID          ,
         PROGRAM_ID                      ,
         PROGRAM_UPDATE_DATE             ,
         PROJECT_ACCOUNTING_CONTEXT      ,
         PROJECT_ID                      ,
         QUANTITY_BILLED                 ,
         QUANTITY_CANCELLED              ,
         QUANTITY_DELIVERED              ,
         QUANTITY_ORDERED                ,
         RATE                            ,
         RATE_DATE                       ,
         REQUEST_ID                      ,
         REQ_DISTRIBUTION_ID             ,
         REQ_HEADER_REFERENCE_NUM        ,
         REQ_LINE_REFERENCE_NUM          ,
         REVISION_NUM                    ,
         SET_OF_BOOKS_ID                 ,
         SOURCE_DISTRIBUTION_ID          ,
         TASK_ID                         ,
         UNENCUMBERED_AMOUNT             ,
         UNENCUMBERED_QUANTITY           ,
         USSGL_TRANSACTION_CODE          ,
         VARIANCE_ACCOUNT_ID             ,
         WIP_ENTITY_ID                   ,
         WIP_LINE_ID                     ,
         WIP_OPERATION_SEQ_NUM           ,
         WIP_REPETITIVE_SCHEDULE_ID      ,
         WIP_RESOURCE_SEQ_NUM            )
    SELECT
         POD.ACCRUAL_ACCOUNT_ID              ,
         POD.ACCRUED_FLAG                    ,
         POD.ACCRUE_ON_RECEIPT_FLAG          ,
         POD.AMOUNT_BILLED                   ,
         POD.ATTRIBUTE1                      ,
         POD.ATTRIBUTE10                     ,
         POD.ATTRIBUTE11                     ,
         POD.ATTRIBUTE12                     ,
         POD.ATTRIBUTE13                     ,
         POD.ATTRIBUTE14                     ,
         POD.ATTRIBUTE15                     ,
         POD.ATTRIBUTE2                      ,
         POD.ATTRIBUTE3                      ,
         POD.ATTRIBUTE4                      ,
         POD.ATTRIBUTE5                      ,
         POD.ATTRIBUTE6                      ,
         POD.ATTRIBUTE7                      ,
         POD.ATTRIBUTE8                      ,
         POD.ATTRIBUTE9                      ,
         POD.ATTRIBUTE_CATEGORY              ,
         POD.BOM_RESOURCE_ID                 ,
         POD.BUDGET_ACCOUNT_ID               ,
         POD.CODE_COMBINATION_ID             ,
         POD.CREATED_BY                      ,
         POD.CREATION_DATE                   ,
         POD.DELIVER_TO_LOCATION_ID          ,
         POD.DELIVER_TO_PERSON_ID            ,
         POD.DESTINATION_CONTEXT             ,
         POD.DESTINATION_ORGANIZATION_ID     ,
         POD.DESTINATION_SUBINVENTORY        ,
         POD.DESTINATION_TYPE_CODE           ,
         POD.DISTRIBUTION_NUM                ,
         POD.ENCUMBERED_AMOUNT               ,
         POD.ENCUMBERED_FLAG                 ,
         POD.EXPENDITURE_ITEM_DATE           ,
         POD.EXPENDITURE_ORGANIZATION_ID     ,
         POD.EXPENDITURE_TYPE                ,
         POD.FAILED_FUNDS_LOOKUP_CODE        ,
         POD.GL_CANCELLED_DATE               ,
         POD.GL_CLOSED_DATE                  ,
         POD.GL_ENCUMBERED_DATE              ,
         POD.GL_ENCUMBERED_PERIOD_NAME       ,
         POD.GOVERNMENT_CONTEXT              ,
         POD.LAST_UPDATED_BY                 ,
         POD.LAST_UPDATE_DATE                ,
         POD.LAST_UPDATE_LOGIN               ,
         'Y'                                 ,
         POD.LINE_LOCATION_ID                ,
         POD.PO_DISTRIBUTION_ID              ,
         POD.PO_HEADER_ID                    ,
         POD.PO_LINE_ID                      ,
         POD.PO_RELEASE_ID                   ,
         POD.PREVENT_ENCUMBRANCE_FLAG        ,
         POD.PROGRAM_APPLICATION_ID          ,
         POD.PROGRAM_ID                      ,
         POD.PROGRAM_UPDATE_DATE             ,
         POD.PROJECT_ACCOUNTING_CONTEXT      ,
         POD.PROJECT_ID                      ,
         POD.QUANTITY_BILLED                 ,
         POD.QUANTITY_CANCELLED              ,
         POD.QUANTITY_DELIVERED              ,
         POD.QUANTITY_ORDERED                ,
         POD.RATE                            ,
         POD.RATE_DATE                       ,
         POD.REQUEST_ID                      ,
         POD.REQ_DISTRIBUTION_ID             ,
         POD.REQ_HEADER_REFERENCE_NUM        ,
         POD.REQ_LINE_REFERENCE_NUM          ,
         p_revision_num                      ,
         POD.SET_OF_BOOKS_ID                 ,
         POD.SOURCE_DISTRIBUTION_ID          ,
         POD.TASK_ID                         ,
         POD.UNENCUMBERED_AMOUNT             ,
         POD.UNENCUMBERED_QUANTITY           ,
         POD.USSGL_TRANSACTION_CODE          ,
         POD.VARIANCE_ACCOUNT_ID             ,
         POD.WIP_ENTITY_ID                   ,
         POD.WIP_LINE_ID                     ,
         POD.WIP_OPERATION_SEQ_NUM           ,
         POD.WIP_REPETITIVE_SCHEDULE_ID      ,
         POD.WIP_RESOURCE_SEQ_NUM
    FROM PO_DISTRIBUTIONS POD,
         PO_DISTRIBUTIONS_ARCHIVE PODA
    WHERE POD.PO_RELEASE_ID             = p_document_id
    AND   POD.PO_DISTRIBUTION_ID        = PODA.PO_DISTRIBUTION_ID (+)
    AND   PODA.LATEST_EXTERNAL_FLAG (+) = 'Y'
    AND (
             (PODA.PO_DISTRIBUTION_ID IS NULL)
          OR (POD.QUANTITY_ORDERED <> PODA.QUANTITY_ORDERED)
          OR (POD.QUANTITY_ORDERED IS NULL
                  AND PODA.QUANTITY_ORDERED IS NOT NULL)
          OR (POD.QUANTITY_ORDERED IS NOT NULL
                  AND PODA.QUANTITY_ORDERED IS NULL)
          OR (POD.DELIVER_TO_PERSON_ID <> PODA.DELIVER_TO_PERSON_ID)
          OR (POD.DELIVER_TO_PERSON_ID IS NULL
                  AND PODA.DELIVER_TO_PERSON_ID IS NOT NULL)
          OR (POD.DELIVER_TO_PERSON_ID IS NOT NULL
                  AND PODA.DELIVER_TO_PERSON_ID IS NULL)
          OR (POD.DISTRIBUTION_NUM <> PODA.DISTRIBUTION_NUM));

    IF SQL%FOUND THEN
        --  Assert: At least one row was processed in the insert statement.
        --  Set the latest_external_flag to 'N' for all rows which have:
        --           - latest_external_flag = 'Y'
        --           - revision_num < p_revision_num  (the new revision of the
        --                                            header)
        --           - no new archived row
        UPDATE PO_DISTRIBUTIONS_ARCHIVE POD1
        SET   LATEST_EXTERNAL_FLAG = 'N'
        WHERE PO_RELEASE_ID        = p_document_id
        AND   LATEST_EXTERNAL_FLAG = 'Y'
        AND   REVISION_NUM         < p_revision_num
        AND   EXISTS
            (SELECT 'A new archived row'
             FROM   PO_DISTRIBUTIONS_ARCHIVE POD2
             WHERE  POD2.PO_DISTRIBUTION_ID    = POD1.PO_DISTRIBUTION_ID
             AND    POD2.LATEST_EXTERNAL_FLAG = 'Y'
             AND    POD2.REVISION_NUM         = p_revision_num);

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        global_stack := 'PORARRELEASE(P_DOCUMENT_ID='''||p_document_id||
			  ''' P_REVISION_NUM='''||p_revision_num||
			  '''):'||global_stack;
        RAISE;


END PORARRELEASE;


END ECE_PO_ARCHIVE_PKG;



/
