--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_CHECKS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_CHECKS_GRP" AS
/* $Header: POXGDCKB.pls 120.10.12010000.4 2014/07/18 08:30:54 yuandli ship $*/

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_DOCUMENT_CHECKS_GRP';

g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| g_pkg_name || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_debug_stmt BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp BOOLEAN := PO_DEBUG.is_debug_unexp_on;

/**
* Public Procedure: po_submission_check
* Requires:
*   IN PARAMETERS:
*     p_api_version:       Version number of API that caller expects. It
*                          should match the l_api_version defined in the
*                          procedure
*     p_action_requested:  In FPJ, the Action requested should be in
*                             g_action_(DOC_SUBMISSION_CHECK, UNRESERVE)
*     p_document_type:     The type of the document to perform
*                          the submission check on.
*     p_document_subtype:  The subtype of the document.
*                          Valid Document types and Document subtypes are
*                          Document Type      Document Subtype
*                          REQUISITION  --->
*                          RELEASE      --->  SCHEDULED/BLANKET
*                          PO           --->  PLANNED/STANDARD
*                          PA           --->  CONTRACT/BLANKET
--
--  <FPJ ENCUMBRANCE>
--    The following 2 parameters replace the p_document_id parameter.
--p_document_level
--  The type of id that is being passed.  Use g_doc_level_<>
--    HEADER
--  The following are only supported for the UNRESERVE action:
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_document_level_id
--  Id of the doc level type on which to perform the check.
--
--
--p_org_id
--  If not NULL, this org context will be set.
--
--
*     p_requested_changes: This object contains all the requested changes to
*                          the document. It contains 5 objects. These objects
*                          are: 1.Header_Changes 2.Release_Changes 3.Line_
*                          Changes 4.Shipment_Changes 5.Distribution_Changes.
*                          In FPI, following change requests are allowed:
*                          1. HEADER_CHANGES: None
*                          2. RELEASE_CHANGES: None
*                          3. LINE_CHANGES: unit_price, vendor_product_num
*                          4. SHIPMENT_CHANGES: quantity, promised_date,
*                             price_override
*                          5. DISTRIBUTION_CHANGES: quantity_ordered
*     p_check_asl:         Determines whether or not to perform the checks:
*                          PO_SUB_ITEM_NOT_APPROVED / PO_SUB_ITEM_ASL_DEBARRED
*                          (a) TRUE  : Perform check
*                          (b) FALSE : Do not perform check
*
* Modifies: Inserts error msgs in online_report_text table, uses global_temp
*           tables for processing
* Effects:  This procedure runs the document submission checks on passed in
*           document.
* Returns:
*  x_return_status:    FND_API.G_RET_STS_SUCCESS if API succeeds
*                      FND_API.G_RET_STS_ERROR if API fails
*                      FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
*  x_sub_check_status: FND_API.G_RET_STS_SUCCESS if document passes all
*                      submission checks, even if warnings are found
*                      FND_API.G_RET_STS_ERROR if document fails atleast one
*                      submission check (returns at least one error)
*  x_has_warnings:     FND_API.G_TRUE if submission check returns warnings
*                      FND_API.G_FALSE if no warnings are found
*  x_msg_data:         Contains error msg in case x_return_status returned
*                      FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_UNEXP_ERROR
*  x_online_report_id: This id can be used to get all submission check errors
*                      for given document from online_report_text table
*  x_doc_check_error_record: If x_sub_check_status returned G_RET_STS_ERROR
*                      then this object of tables will contain information about
*                      all submission check errors for given document including
*                      message_name and text_line.
*/
-- SUB_CHK_1
PROCEDURE po_submission_check(
   p_api_version                    IN           NUMBER
,  p_action_requested               IN           VARCHAR2
,  p_document_type                  IN           VARCHAR2
,  p_document_subtype               IN           VARCHAR2
,  p_document_level                 IN           VARCHAR2
,  p_document_level_id              IN           NUMBER
,  p_org_id                         IN           NUMBER
,  p_requested_changes              IN           PO_CHANGES_REC_TYPE
,  p_check_asl                      IN           BOOLEAN
,  p_req_chg_initiator              IN           VARCHAR2 := NULL -- bug4957243
,  p_origin_doc_id                  IN           NUMBER := NULL -- Bug#5462677
,  x_return_status                  OUT NOCOPY   VARCHAR2
,  x_sub_check_status               OUT NOCOPY   VARCHAR2
,  x_has_warnings                   OUT NOCOPY   VARCHAR2  -- bug3574165
,  x_msg_data                       OUT NOCOPY   VARCHAR2
,  x_online_report_id               OUT NOCOPY   NUMBER
,  x_doc_check_error_record         OUT NOCOPY   doc_check_Return_Type
)
IS

l_api_name              CONSTANT varchar2(30) := 'PO_SUBMISSION_CHECK';
l_api_version           CONSTANT NUMBER       := 1.1;
l_progress              VARCHAR2(3);

l_document_id           NUMBER;
l_document_id_tbl       po_tbl_number;

l_doc_id                NUMBER;

l_consigned_flag PO_HEADERS_ALL.CONSIGNED_CONSUMPTION_FLAG%TYPE;

BEGIN

-- Initialize variables
l_consigned_flag := 'N';

--Do validations on passed in parameters

l_progress := '000';

IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Doing Validation on passed in data');
   END IF;
END IF;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

PO_CORE_S.get_document_ids(
   p_doc_type => p_document_type
,  p_doc_level => p_document_level
,  p_doc_level_id_tbl => po_tbl_number( p_document_level_id )
,  x_doc_id_tbl => l_document_id_tbl
);

l_document_id := l_document_id_tbl(1);

l_progress := '001';
--Check p_action_requested
-- <Doc Manager Rewrite 11.5.11>: Support FINAL_CLOSE submission checks
IF p_action_requested NOT IN
   (g_action_DOC_SUBMISSION_CHECK, g_action_UNRESERVE, g_action_FINAL_CLOSE_CHECK)
THEN
   FND_MESSAGE.set_name('PO', 'PO_SUB_GENERAL_ERROR');
   FND_MESSAGE.set_token('ERROR_TEXT','Invalid Action Requested');
   FND_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
END IF;

l_progress := '002';
    --check p_document_type
    IF p_document_type NOT IN ('REQUISITION', 'RELEASE', 'PO', 'PA') THEN
        FND_MESSAGE.set_name('PO', 'PO_SUB_GENERAL_ERROR');
        FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid Document TYpe');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

l_progress := '003';

--check that action requested matches
IF p_action_requested = g_action_UNRESERVE THEN
   IF p_document_type NOT IN ('PO', 'RELEASE') THEN
      FND_MESSAGE.set_name('PO', 'PO_SUB_GENERAL_ERROR');
      FND_MESSAGE.set_token('ERROR_TEXT', 'UNRESERVE Action Requested for invalid document type');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
-- <Doc Manager Rewrite 11.5.11 Start>
ELSIF (p_action_requested = g_action_FINAL_CLOSE_CHECK) THEN
   IF p_document_type NOT IN ('PO', 'PA', 'RELEASE') THEN
      FND_MESSAGE.set_name('PO', 'PO_SUB_GENERAL_ERROR');
      FND_MESSAGE.set_token('ERROR_TEXT', 'FINAL_CLOSE Action Requested for invalid document type');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
-- <Doc Manager Rewrite 11.5.11 End>
ELSE
   IF p_document_level <> g_document_level_HEADER THEN
      FND_MESSAGE.set_name('PO', 'PO_SUB_GENERAL_ERROR');
      FND_MESSAGE.set_token('ERROR_TEXT', 'Non-Header level only supported for UNRESERVE action');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
END IF;

l_progress := '004';
    --check that document_subtype matches
    IF p_document_type = 'PO' THEN
        IF p_document_subtype NOT IN ('STANDARD', 'PLANNED') THEN
            FND_MESSAGE.set_name('PO', 'PO_SUB_GENERAL_ERROR');
            FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid document type for document type PO');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSIF p_document_type = 'PA' THEN
        IF p_document_subtype NOT IN ('BLANKET', 'CONTRACT') THEN
            FND_MESSAGE.set_name('PO', 'PO_SUB_GENERAL_ERROR');
            FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid document type for document type PA');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

l_progress := '005';
    --Set the org context
    IF p_org_id IS NOT NULL THEN
        PO_MOAC_UTILS_PVT.Set_Org_Context(p_org_id);   -- <R12 MOAC>
    END IF;

l_progress := '006';
    --check that document_id passed exists and that org context is set.
    IF p_document_type IN ('PO', 'PA') THEN
       BEGIN
         SELECT po_header_id,
                NVL(consigned_consumption_flag, 'N')
         INTO  l_doc_id,
               l_consigned_flag
         FROM PO_HEADERS
         WHERE po_header_id= l_document_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.set_name('PO', 'PO_SUB_GENERAL_ERROR');
            FND_MESSAGE.set_token('ERROR_TEXT', 'Either Org Context is not set OR Doc_id does not exist');
            FND_MSG_PUB.Add;
         WHEN OTHERS THEN
            RAISE;
       END;
    ELSIF p_document_type = 'REQUISITION' THEN
       BEGIN
         SELECT requisition_header_id
         INTO  l_doc_id
         FROM PO_REQUISITION_HEADERS
         WHERE requisition_header_id= l_document_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.set_name('PO', 'PO_SUB_GENERAL_ERROR');
            FND_MESSAGE.set_token('ERROR_TEXT', 'Either Org Context is not set OR Doc_id does not exist');
            FND_MSG_PUB.Add;
         WHEN OTHERS THEN
            RAISE;
       END;
    ELSE --Its a release
       BEGIN
         SELECT po_release_id,
                NVL(consigned_consumption_flag, 'N')
         INTO  l_doc_id,
               l_consigned_flag
         FROM PO_RELEASES
         WHERE po_release_id= l_document_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.set_name('PO', 'PO_SUB_GENERAL_ERROR');
            FND_MESSAGE.set_token('ERROR_TEXT', 'Either Org Context is not set OR Doc_id does not exist');
            FND_MSG_PUB.Add;
         WHEN OTHERS THEN
            RAISE;
       END;
    END IF;

l_progress := '007';

IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Calling PVT package');
   END IF;
END IF;

-- Bug 3318625
-- skip the submission checks for a consumption advice as they are not
-- done when creating a consumption advice.This may chnage if we decide
-- to add them when creating
-- <Doc Manager Rewrite 11.5.11>: Do check even if consigned for final close.
IF (l_consigned_flag = 'Y') AND (p_action_requested <> g_action_FINAL_CLOSE_CHECK)
THEN

   x_sub_check_status := FND_API.G_RET_STS_SUCCESS;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   Return;
END IF;

--Call the private po_submission_check

PO_DOCUMENT_CHECKS_PVT.po_submission_check(
   p_api_version => 2.0
,  p_action_requested => p_action_requested
,  p_document_type => p_document_type
,  p_document_subtype => p_document_subtype
,  p_document_level => p_document_level
,  p_document_level_id => p_document_level_id
,  p_requested_changes => p_requested_changes
,  p_check_asl => p_check_asl
,  p_req_chg_initiator => p_req_chg_initiator  -- bug4957243
,  p_origin_doc_id => p_origin_doc_id  -- Bug#5462677
,  x_return_status => x_return_status
,  x_sub_check_status => x_sub_check_status
,  x_has_warnings => x_has_warnings          -- bug3574165
,  x_msg_data  => x_msg_data
,  x_online_report_id => x_online_report_id
,  x_doc_check_error_record => x_doc_check_error_record
);

l_progress := '008';
IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Back in GRP package. Returning to the caller');
   END IF;
END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                        p_encoded => 'F');
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_sub_check_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_ERROR THEN
            x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                        p_encoded => 'F');
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_sub_check_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_fnd_debug = 'Y') THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

        x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                    p_encoded => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_sub_check_status := FND_API.G_RET_STS_ERROR;
END po_submission_check;

-- bug3574165 START
-- Overloaded procedure. This procedure does not take l_has_warnings
-- as parameter.

-- SUB_CHK_2
PROCEDURE po_submission_check(
   p_api_version                    IN           NUMBER
,  p_action_requested               IN           VARCHAR2
,  p_document_type                  IN           VARCHAR2
,  p_document_subtype               IN           VARCHAR2
,  p_document_level                 IN           VARCHAR2
,  p_document_level_id              IN           NUMBER
,  p_org_id                         IN           NUMBER
,  p_requested_changes              IN           PO_CHANGES_REC_TYPE
,  p_check_asl                      IN           BOOLEAN
,  p_origin_doc_id                  IN           NUMBER := NULL -- Bug#5462677
,  p_req_chg_initiator              IN           VARCHAR2 := NULL -- bug4957243
,  x_return_status                  OUT NOCOPY   VARCHAR2
,  x_sub_check_status               OUT NOCOPY   VARCHAR2
,  x_msg_data                       OUT NOCOPY   VARCHAR2
,  x_online_report_id               OUT NOCOPY   NUMBER
,  x_doc_check_error_record         OUT NOCOPY   doc_check_Return_Type
)
IS

l_has_warnings VARCHAR2(1);

BEGIN

-- Call SUB_CHK_1
po_submission_check(
   p_api_version => p_api_version
,  p_action_requested => p_action_requested
,  p_document_type => p_document_type
,  p_document_subtype => p_document_subtype
,  p_document_level => p_document_level   -- Bug 3601682
,  p_document_level_id => p_document_level_id
,  p_org_id => p_org_id
,  p_requested_changes => p_requested_changes
,  p_check_asl => p_check_asl
,  p_origin_doc_id => p_origin_doc_id  -- Bug#5462677
,  p_req_chg_initiator => p_req_chg_initiator -- bug4957243
,  x_return_status => x_return_status
,  x_sub_check_status => x_sub_check_status
,  x_has_warnings => l_has_warnings    -- bug3574165
,  x_msg_data  => x_msg_data
,  x_online_report_id => x_online_report_id
,  x_doc_check_error_record => x_doc_check_error_record
);

END po_submission_check;



------------------------------------------------------------------------------
--<FPJ ENCUMBRANCE>
--    The UNRESERVE action may be taken at any document level.
--    This required the replacement of p_document_id with
--    p_document_level, p_document_level_id.
--    All users of the previous signature were HEADER-level calls.
------------------------------------------------------------------------------

-- SUB_CHK_3
PROCEDURE po_submission_check(
   p_api_version                    IN           NUMBER
,  p_action_requested               IN           VARCHAR2
,  p_document_type                  IN           VARCHAR2
,  p_document_subtype               IN           VARCHAR2
,  p_document_id                    IN           NUMBER
,  p_org_id                         IN           NUMBER
,  p_requested_changes              IN           PO_CHANGES_REC_TYPE
,  p_check_asl                      IN           BOOLEAN
,  p_req_chg_initiator              IN           VARCHAR2 := NULL -- bug4957243
,  x_return_status                  OUT NOCOPY   VARCHAR2
,  x_sub_check_status               OUT NOCOPY   VARCHAR2
,  x_msg_data                       OUT NOCOPY   VARCHAR2
,  x_online_report_id               OUT NOCOPY   NUMBER
,  x_doc_check_error_record         OUT NOCOPY   doc_check_Return_Type
)
IS

BEGIN

-- Call SUB_CHK_2
po_submission_check(
   p_api_version => p_api_version
,  p_action_requested => p_action_requested
,  p_document_type => p_document_type
,  p_document_subtype => p_document_subtype
,  p_document_level => g_document_level_HEADER
,  p_document_level_id => p_document_id
,  p_org_id => p_org_id
,  p_requested_changes => p_requested_changes
,  p_check_asl => p_check_asl
,  p_req_chg_initiator => p_req_chg_initiator -- bug4957243
,  x_return_status => x_return_status
,  x_sub_check_status => x_sub_check_status
,  x_msg_data  => x_msg_data
,  x_online_report_id => x_online_report_id
,  x_doc_check_error_record => x_doc_check_error_record
);

END po_submission_check;




/**
*   This is overloaded procedure without follwoing parameters
*   IN: p_requested_changes,
*       p_org_id
*   OUT : x_doc_check_error_record
*   This procedure is called from .pld and .lpc in PO Source code
*   as these calls do not need above IN OUT parameters
*/

-- SUB_CHK_4
PROCEDURE po_submission_check(p_api_version  IN  NUMBER,
                p_action_requested          IN  VARCHAR2,
                p_document_type             IN  VARCHAR2,
                p_document_subtype          IN  VARCHAR2,
                p_document_id               IN  NUMBER,
			    x_return_status 	        OUT NOCOPY  VARCHAR2,
			    x_sub_check_status          OUT	NOCOPY  VARCHAR2,
                x_msg_data                  OUT NOCOPY  VARCHAR2,
			    x_online_report_id          OUT NOCOPY  NUMBER) IS

-- <PO_CHANGE_API FPJ> Renamed the type to PO_CHANGES_REC_TYPE:
l_requested_changes PO_CHANGES_REC_TYPE := NULL;
l_doc_check_error_record doc_check_Return_Type := NULL;
l_org_id  NUMBER :=NULL;

l_api_name              CONSTANT varchar2(30) := 'PO_SUBMISSION_CHECK';
l_progress               VARCHAR2(3);

BEGIN

l_progress := '000';
IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Called OVERLOADED procedure. Filled missing parameters');
   END IF;
END IF;

     -- Call SUB_CHK_2
     PO_DOCUMENT_CHECKS_GRP.po_submission_check(p_api_version => p_api_version,
                    p_action_requested => p_action_requested,
                    p_document_type => p_document_type,
                    p_document_subtype => p_document_subtype,
 			        p_document_level => g_document_level_HEADER,
 			        p_document_level_id => p_document_id,
                    p_org_id => l_org_id,
                    p_requested_changes => l_requested_changes,
                    p_check_asl => TRUE,                           -- <2757450>
 			        x_return_status => x_return_status,
 			        x_sub_check_status => x_sub_check_status,
                    x_msg_data  => x_msg_data,
 			        x_online_report_id => x_online_report_id,
                    x_doc_check_error_record  => l_doc_check_error_record);

l_progress := '001';
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                        p_encoded => 'F');
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_sub_check_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_ERROR THEN
            x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                        p_encoded => 'F');
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_sub_check_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_fnd_debug = 'Y') THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

        x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                    p_encoded => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_sub_check_status := FND_API.G_RET_STS_ERROR;
END po_submission_check;


-- bug3574165 START
-- Overloaded procedure to include x_has_warnings parameter
-- This parameter is used to indicate whether there are warnings coming
-- out from po submission check

-- SUB_CHK_5
PROCEDURE po_submission_check
(
    p_api_version               IN          NUMBER,
    p_action_requested          IN          VARCHAR2,
    p_document_type             IN          VARCHAR2,
    p_document_subtype          IN          VARCHAR2,
    p_document_id               IN          NUMBER,
    p_check_asl                 IN          BOOLEAN,
    x_return_status 	        OUT NOCOPY  VARCHAR2,
    x_sub_check_status          OUT	NOCOPY  VARCHAR2,
    x_has_warnings              OUT NOCOPY  VARCHAR2,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_online_report_id          OUT NOCOPY  NUMBER
)
IS
    -- <PO_CHANGE_API FPJ> Renamed the type to PO_CHANGES_REC_TYPE:
    l_requested_changes        PO_CHANGES_REC_TYPE := NULL;
    l_doc_check_error_record   doc_check_Return_Type := NULL;
    l_org_id                   NUMBER := NULL;

    l_api_name                 CONSTANT varchar2(30) := 'PO_SUBMISSION_CHECK';
    l_progress                 VARCHAR2(3);

BEGIN

l_progress := '000';

    IF ( g_fnd_debug = 'Y' )
    THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string( FND_LOG.LEVEL_STATEMENT,
                        g_log_head || '.'||l_api_name||'.'|| l_progress,
                        'Called OVERLOADED procedure. Filled missing parameters');
        END IF;
    END IF;

    -- Call SUB_CHK_2
    PO_DOCUMENT_CHECKS_GRP.po_submission_check
    (
        p_api_version => p_api_version,
        p_action_requested => p_action_requested,
        p_document_type => p_document_type,
        p_document_subtype => p_document_subtype,
        p_document_level => g_document_level_HEADER,
        p_document_level_id => p_document_id,
        p_org_id => l_org_id,
        p_requested_changes => l_requested_changes,
        p_check_asl => p_check_asl,
        x_return_status => x_return_status,
        x_sub_check_status => x_sub_check_status,
        x_has_warnings => x_has_warnings,
        x_msg_data  => x_msg_data,
        x_online_report_id => x_online_report_id,
        x_doc_check_error_record  => l_doc_check_error_record
    );

l_progress := '001';

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                        p_encoded => 'F');
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_sub_check_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
            x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                        p_encoded => 'F');
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_sub_check_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
        THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF ( g_fnd_debug = 'Y' )
        THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected,
                           g_log_head || l_api_name || '.others_exception',
                           'EXCEPTION: Location is '|| l_progress || ' SQL CODE is '|| sqlcode);
            END IF;
        END IF;

        x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                    p_encoded => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_sub_check_status := FND_API.G_RET_STS_ERROR;

END po_submission_check;
-- bug3574165 END


-- <2757450 START>: Overloaded procedure to include 'p_check_asl' parameter.
-- This parameter is used to indicate whether or not to perform the
-- PO_SUB_ITEM_NOT_APPROVED and PO_SUB_ITEM_ASL_DEBARRED checks.
--

-- SUB_CHK_6
PROCEDURE po_submission_check
(
    p_api_version               IN          NUMBER,
    p_action_requested          IN          VARCHAR2,
    p_document_type             IN          VARCHAR2,
    p_document_subtype          IN          VARCHAR2,
    p_document_id               IN          NUMBER,
    p_check_asl                 IN          BOOLEAN,
    x_return_status 	        OUT NOCOPY  VARCHAR2,
    x_sub_check_status          OUT	NOCOPY  VARCHAR2,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_online_report_id          OUT NOCOPY  NUMBER
)
IS

    -- bug3574165
    -- Removed all other parameters and added l_has_warnings, which serves
    -- as a dummy variable in this procedure
    l_has_warnings VARCHAR2(1);

BEGIN

    -- bug3574165
    -- We are calling another po_submission_check that has x_has_warnings
    -- as OUT parameter. Setting OUT parameters will be handled within that
    -- procedure

    -- Call SUB_CHK_5
    PO_DOCUMENT_CHECKS_GRP.po_submission_check
    (
        p_api_version => p_api_version,
        p_action_requested => p_action_requested,
        p_document_type => p_document_type,
        p_document_subtype => p_document_subtype,
        p_document_id => p_document_id,
        p_check_asl => p_check_asl,
        x_return_status => x_return_status,
        x_sub_check_status => x_sub_check_status,
        x_has_warnings => l_has_warnings,
        x_msg_data  => x_msg_data,
        x_online_report_id => x_online_report_id
    );

END po_submission_check;

--
-- <2757450 END>

-- <FPJ Refactor Security API START>

/**
* Public Procedure: PO_Security_Check
* Requires:
*   IN PARAMETERS:
*     p_api_version:          Version number of API that caller expects. It
*                             should match the l_api_version defined in the
*                             procedure
*     p_query_table:          Table you want to check
*     p_owner_id_column:      Owner id column of the table
*     p_employee_id:          User id to access the document
*     p_minimum_access_level: Minimum access level to the document
*     p_document_type:        The type of the document to perform
*                             the security check on.
*                             OR
*                             PO_PA -- check both PO and PA (bug 5054685)
*     p_document_subtype:     The subtype of the document.
*                             Valid Document types and Document subtypes
*                             Document Type      Document Subtype
*                             RFQ          --->  STANDARD
*                             QUOTATION    --->  STANDARD
*                             REQUISITION  --->  PURCHASE/INTERNAL
*                             RELEASE      --->  SCHEDULED/BLANKET
*                             PO           --->  PLANNED/STANDARD
*                             PA           --->  CONTRACT/BLANKET
*                             PO_PA        --->  "ALL" (PLANNED/STANDARD/CONTRACT/BLANKET) (bug 5054685)
*     p_type_clause:          The document type clause to be used in
*                             constructing where clause
*
* Modifies: None
* Effects:  This procedure builds dynamic WHERE clause fragments based on
*           document security parameters.
* Returns:
*   x_return_status: FND_API.G_RET_STS_SUCCESS if API succeeds
*                    FND_API.G_RET_STS_ERROR if API fails
*                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
*   x_msg_data:      Contains error msg in case x_return_status returned
*                    FND_API.G_RET_STS_ERROR or
*                    FND_API.G_RET_STS_UNEXP_ERROR
*   x_where_clause:  The constructed where clause
*/
PROCEDURE PO_SECURITY_CHECK (p_api_version          IN NUMBER,
                             p_query_table          IN VARCHAR2,
                             p_owner_id_column      IN VARCHAR2,
                             p_employee_id          IN VARCHAR2,
                             p_org_id               IN NUMBER,
                             p_minimum_access_level IN VARCHAR2,
                             p_document_type	    IN VARCHAR2,
                             p_document_subtype     IN VARCHAR2,
                             p_type_clause          IN VARCHAR2,
                             x_return_status        OUT NOCOPY VARCHAR2,
                             x_msg_data             OUT NOCOPY VARCHAR2,
                             x_where_clause         OUT NOCOPY VARCHAR2)
IS

  l_api_name              CONSTANT varchar2(30) := 'PO_SECURITY_CHECK';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_progress              VARCHAR2(3);

BEGIN

  l_progress := '000';
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '010';

  IF g_fnd_debug = 'Y' THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
            || l_progress,'Doing Validation on passed in data');
     END IF;
  END IF;

  -- Check the required fields
  IF ((p_query_table is NULL) OR (p_owner_id_column is NULL) OR
      (p_employee_id IS NULL) OR
      (p_minimum_access_level IS NULL) OR (p_document_type is NULL) OR
      (p_document_subtype is NULL) OR (p_type_clause is NULL)) THEN
    FND_MESSAGE.set_name('PO', 'PO_SEC_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'Mandatory parameters are NULL');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF; /*(p_query_table is NULL) OR (p_owner_id_column is NULL)*/

  l_progress := '020';
  --Check p_minimum_access_level
  IF p_minimum_access_level NOT IN ('VIEW_ONLY', 'MODIFY', 'FULL') THEN
    FND_MESSAGE.set_name('PO', 'PO_SEC_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid Minimum Access Level');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF; /*p_minimum_access_level NOT IN ('VIEW_ONLY', 'MODIFY', 'ALL')*/

  l_progress := '030';
  --check p_document_type
  -- Bug 5054685: Added 'PO_PA' as additional check
  IF p_document_type NOT IN ('RFQ', 'QUOTATION', 'REQUISITION',
                             'RELEASE', 'PO', 'PA', 'PO_PA') THEN
    FND_MESSAGE.set_name('PO', 'PO_SEC_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid Document Type');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF; /*p_document_type NOT IN ('RFQ', 'QUOTATION', 'REQUISITION',*/

  l_progress := '040';
  --check that document_subtype matches
  IF p_document_type = 'REQUISITION' THEN
    IF p_document_subtype NOT IN ('PURCHASE', 'INTERNAL') THEN
      FND_MESSAGE.set_name('PO', 'PO_SEC_GENERAL_ERROR');
      FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid Document Subtype');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF p_document_type = 'RELEASE' THEN
    IF p_document_subtype NOT IN ('SCHEDULED', 'BLANKET') THEN
      FND_MESSAGE.set_name('PO', 'PO_SEC_GENERAL_ERROR');
      FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid Document Subtype');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF p_document_type = 'PO' THEN
    IF p_document_subtype NOT IN ('STANDARD', 'PLANNED') THEN
      FND_MESSAGE.set_name('PO', 'PO_SEC_GENERAL_ERROR');
      FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid Document Subtype');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF p_document_type = 'PA' THEN
    IF p_document_subtype NOT IN ('BLANKET', 'CONTRACT') THEN
      FND_MESSAGE.set_name('PO', 'PO_SEC_GENERAL_ERROR');
      FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid Document Subtype');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  -- Bug 5054685 Start: Performance issue. Collapsed multiple security
  -- related where-clauses into one.
  ELSIF p_document_type = 'PO_PA' THEN
    IF p_document_subtype NOT IN ('ALL') THEN
      FND_MESSAGE.set_name('PO', 'PO_SEC_GENERAL_ERROR');
      FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid Document Subtype');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  -- Bug 5054685 End
  END IF; /*p_document_type = 'REQUISITION'*/

  l_progress := '050';
  --Set the org context
  IF p_org_id IS NOT NULL THEN
    PO_MOAC_UTILS_PVT.Set_Org_Context(p_org_id);   -- <R12 MOAC>
  END IF; /* p_org_id IS NOT NULL*/

  l_progress := '060';
  --Call the private PO_Security_Check
  PO_DOCUMENT_CHECKS_PVT.PO_SECURITY_CHECK(
    p_api_version =>		p_api_version,
    p_query_table =>		p_query_table,
    p_owner_id_column =>      	p_owner_id_column,
    p_employee_id =>		p_employee_id,
    p_minimum_access_level =>	p_minimum_access_level,
    p_document_type =>		p_document_type,
    p_document_subtype =>	p_document_subtype,
    p_type_clause =>		p_type_clause,
    x_return_status =>		x_return_status,
    x_msg_data =>		x_msg_data,
    x_where_clause =>		x_where_clause);

l_progress := '100';
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_where_clause := NULL;
  WHEN FND_API.G_EXC_ERROR THEN
    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_where_clause := NULL;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;

    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                     l_api_name || '.others_exception', 'EXCEPTION: Location is '
                     || l_progress || ' SQL CODE is '||sqlcode);
      END IF;
    END IF;

    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_where_clause := NULL;
END PO_SECURITY_CHECK;

-- <FPJ Refactor Security API END>

-- The following new procedures for status check added in DropShip FPJ project

-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_status_check_inputs
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  The following Validations done, called by po_status_check Group procedure.
--    1. All the ID input tables p_header_id,p_release_id etc. should be of same size.
--    2. Each entity specifies a PO Header or Release through one of the following.
--         2a:Header Id is not null
--         2b:Release Id is not null
--         2c:Document Number and Document Sub Type are not null
--         2d:Vendor Order Num is not null
--       Note that the Line/Shipment are optional but a Header/Release is required.
--Notes:
--  Detailed comments maintained in PVT Package Body PO_DOCUMENT_CHECKS_PVT.po_status_check
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_status_check_inputs (
    p_api_version         IN NUMBER,
    p_header_id           IN OUT NOCOPY PO_TBL_NUMBER,
    p_release_id          IN OUT NOCOPY PO_TBL_NUMBER,
    p_document_type       IN OUT NOCOPY PO_TBL_VARCHAR30,
    p_document_subtype    IN OUT NOCOPY PO_TBL_VARCHAR30,
    p_document_num        IN OUT NOCOPY PO_TBL_VARCHAR30,
    p_vendor_order_num    IN OUT NOCOPY PO_TBL_VARCHAR30,
    p_line_id             IN OUT NOCOPY PO_TBL_NUMBER,
    p_line_location_id    IN OUT NOCOPY PO_TBL_NUMBER,
    p_distribution_id     IN OUT NOCOPY PO_TBL_NUMBER,
    p_mode                IN VARCHAR2,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_po_status_rec       OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR(30) := 'VALIDATE_STATUS_CHECK_INPUTS';
l_progress              VARCHAR2(3) := '000';
l_count                 NUMBER;
l_dummy_table_number    po_tbl_number := po_tbl_number();
l_dummy_table_varchar30 po_tbl_varchar30 := po_tbl_varchar30();

BEGIN

--Initialize l_count to length of first non-null Required Input Table
l_progress := '005';
IF p_header_id IS NOT NULL THEN
    l_count := p_header_id.COUNT;
ELSIF p_release_id IS NOT NULL THEN
    l_count := p_release_id.COUNT;
ELSIF p_document_num IS NOT NULL THEN
    l_count := p_document_num.COUNT;
ELSIF p_document_subtype IS NOT NULL THEN
    l_count := p_document_subtype.COUNT;
ELSIF p_vendor_order_num IS NOT NULL THEN
    l_count := p_vendor_order_num.COUNT;
ELSE -- The required input table ID parameters are all null !
    FND_MESSAGE.set_name('PO', 'PO_STATCHK_ERR_NULL_INPARAM');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END IF;

--Initialize any null Tables to a dummy table of null values with length of p_header_id.COUNT
l_progress := '007';
l_dummy_table_number.extend(l_count);
l_dummy_table_varchar30.extend(l_count);
IF p_header_id IS NULL THEN
    p_header_id := l_dummy_table_number;
END IF;
IF p_release_id IS NULL THEN
    p_release_id := l_dummy_table_number;
END IF;
IF p_document_type IS NULL THEN
    p_document_type := l_dummy_table_varchar30;
END IF;
IF p_document_subtype IS NULL THEN
    p_document_subtype := l_dummy_table_varchar30;
END IF;
IF p_document_num IS NULL THEN
    p_document_num := l_dummy_table_varchar30;
END IF;
IF p_vendor_order_num IS NULL THEN
    p_vendor_order_num := l_dummy_table_varchar30;
END IF;
IF p_line_id IS NULL THEN
    p_line_id := l_dummy_table_number;
END IF;
IF p_line_location_id IS NULL THEN
    p_line_location_id := l_dummy_table_number;
END IF;
IF p_distribution_id IS NULL THEN
    p_distribution_id := l_dummy_table_number;
END IF;

--Validate that Input ID Tables are all of the same size
l_progress := '010';
IF l_count <> p_release_id.count
   OR l_count <> p_document_type.count
   OR l_count <> p_document_subtype.count
   OR l_count <> p_document_num.count
   OR l_count <> p_vendor_order_num.count
   OR l_count <> p_line_id.count
   OR l_count <> p_line_location_id.count
   OR l_count <> p_distribution_id.count THEN

    FND_MESSAGE.set_name('PO', 'PO_STATCHK_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'The input table ID parameters are not of same size !');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END IF;

--Validate that a Header or Release is specified through any of the possible combinations
--  Line/Shipment/Distribution are optional, but Header/Release should be specified.
l_progress := '020';
FOR i IN 1..l_count LOOP

    --For each index, Input IDs should refer to a valid entity
    --bug 4931241 - p_vendor_order_num and p_document_num/p_document_subtype don't
    --uniquely identify a document. Hence we have to rely on p_header_id or p_release_id
    IF (p_header_id(i) IS NULL) AND (p_release_id(i) IS NULL) THEN
        -- Means that no Header/Release is specified
        FND_MESSAGE.set_name('PO', 'PO_STATCHK_GENERAL_ERROR');
        FND_MESSAGE.set_token('ERROR_TEXT', 'There is no Header/Release specified at index ' || i);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

END LOOP;

l_progress := '030';

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);

END validate_status_check_inputs;

-------------------------------------------------------------------------------
--Start of Comments
--Name: po_status_check
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Group procedure to find the status of a Purchase Order or a Release
--  This validates inputs and calls the private procedure po_status_check
--Notes:
--  For details on validations, refer to Group Procedure validate_status_check_inputs
--  Detailed comments maintained in PVT Package Body PO_DOCUMENT_CHECKS_PVT.po_status_check
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE po_status_check (
    p_api_version         IN NUMBER,
    p_header_id           IN PO_TBL_NUMBER,
    p_release_id          IN PO_TBL_NUMBER,
    p_document_type       IN PO_TBL_VARCHAR30,
    p_document_subtype    IN PO_TBL_VARCHAR30,
    p_document_num        IN PO_TBL_VARCHAR30,
    p_vendor_order_num    IN PO_TBL_VARCHAR30,
    p_line_id             IN PO_TBL_NUMBER,
    p_line_location_id    IN PO_TBL_NUMBER,
    p_distribution_id     IN PO_TBL_NUMBER,
    p_mode                IN VARCHAR2,
    p_lock_flag           IN VARCHAR2 := 'N',
    p_calling_module      IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    p_role                IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    p_skip_cat_upload_chk IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    x_po_status_rec       OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2
) IS

l_header_id           PO_TBL_NUMBER    := p_header_id;
l_release_id          PO_TBL_NUMBER    := p_release_id;
l_document_type       PO_TBL_VARCHAR30 := p_document_type;
l_document_subtype    PO_TBL_VARCHAR30 := p_document_subtype;
l_document_num        PO_TBL_VARCHAR30 := p_document_num;
l_vendor_order_num    PO_TBL_VARCHAR30 := p_vendor_order_num;
l_line_id             PO_TBL_NUMBER    := p_line_id;
l_line_location_id    PO_TBL_NUMBER    := p_line_location_id;
l_distribution_id     PO_TBL_NUMBER    := p_distribution_id;

l_api_name    CONSTANT VARCHAR(30) := 'PO_STATUS_CHECK';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';

BEGIN

--Standard call to check for call compatibility
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Validate Input Parameters and do any defaulting
l_progress := '010';
validate_status_check_inputs(
    p_api_version      => p_api_version,
    p_header_id        => l_header_id,
    p_release_id       => l_release_id,
    p_document_type    => l_document_type,
    p_document_subtype => l_document_subtype,
    p_document_num     => l_document_num,
    p_vendor_order_num => l_vendor_order_num,
    p_line_id          => l_line_id,
    p_line_location_id => l_line_location_id,
    p_distribution_id  => l_distribution_id,
    p_mode             => p_mode,
    x_po_status_rec    => x_po_status_rec,
    x_return_status    => x_return_status);

IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    return;
END IF;

--Call the private procedure to actually do po status check
l_progress := '020';
PO_DOCUMENT_CHECKS_PVT.po_status_check(
    p_api_version      => p_api_version,
    p_header_id        => l_header_id,
    p_release_id       => l_release_id,
    p_document_type    => l_document_type,
    p_document_subtype => l_document_subtype,
    p_document_num     => l_document_num,
    p_vendor_order_num => l_vendor_order_num,
    p_line_id          => l_line_id,
    p_line_location_id => l_line_location_id,
    p_distribution_id  => l_distribution_id,
    p_mode             => p_mode,
    p_lock_flag        => p_lock_flag,
    p_calling_module   => p_calling_module,          -- PDOI Rewrite R12
    p_role             => p_role,                    -- PDOI Rewrite R12
    p_skip_cat_upload_chk => p_skip_cat_upload_chk,  -- PDOI Rewrite R12
    x_po_status_rec    => x_po_status_rec,
    x_return_status    => x_return_status);


l_progress := '030';

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);

END po_status_check;

-------------------------------------------------------------------------------
--Start of Comments
--Name: po_status_check
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Finds the status of a Purchase Order or a Release
--  This is a convenience procedure for a single entity and takes in scalar input IDs
--  This in turn calls the group procedure po_status_check that takes Table input IDs
--Notes:
--  Detailed comments maintained in PVT Package Body PO_DOCUMENT_CHECKS_PVT.po_status_check
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE po_status_check (
    p_api_version           IN NUMBER,
    p_header_id             IN NUMBER := NULL,
    p_release_id            IN NUMBER := NULL,
    p_document_type         IN VARCHAR2 := NULL,
    p_document_subtype      IN VARCHAR2 := NULL,
    p_document_num          IN VARCHAR2 := NULL,
    p_vendor_order_num      IN VARCHAR2 := NULL,
    p_line_id               IN NUMBER := NULL,
    p_line_location_id      IN NUMBER := NULL,
    p_distribution_id       IN NUMBER := NULL,
    p_mode                  IN VARCHAR2,
    p_lock_flag             IN VARCHAR2 := 'N',
    p_calling_module        IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    p_role                  IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    p_skip_cat_upload_chk   IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    x_po_status_rec         OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status         OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'PO_STATUS_CHECK';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';

BEGIN

--Standard call to check for call compatibility
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Call the overloaded procedure that takes in Table IDs after
--  creating size=1 Tables of IDs 1 with value of the scalar input IDs
l_progress := '010';
PO_DOCUMENT_CHECKS_GRP.po_status_check(
    p_api_version      => p_api_version,
    p_header_id        => PO_TBL_NUMBER(p_header_id),
    p_release_id       => PO_TBL_NUMBER(p_release_id),
    p_document_type    => PO_TBL_VARCHAR30(p_document_type),
    p_document_subtype => PO_TBL_VARCHAR30(p_document_subtype),
    p_document_num     => PO_TBL_VARCHAR30(p_document_num),
    p_vendor_order_num => PO_TBL_VARCHAR30(p_vendor_order_num),
    p_line_id          => PO_TBL_NUMBER(p_line_id),
    p_line_location_id => PO_TBL_NUMBER(p_line_location_id),
    p_distribution_id  => PO_TBL_NUMBER(p_distribution_id),
    p_mode             => p_mode,
    p_lock_flag        => p_lock_flag,
    p_calling_module   => p_calling_module,          -- PDOI Rewrite R12
    p_role             => p_role,                    -- PDOI Rewrite R12
    p_skip_cat_upload_chk => p_skip_cat_upload_chk,  -- PDOI Rewrite R12
    x_po_status_rec    => x_po_status_rec,
    x_return_status    => x_return_status);

l_progress := '020';

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);

END po_status_check;

-- Bug 3312906 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: check_std_po_price_updateable
--Function:
--  Checks whether price updates are allowed on this Standard PO line.
--Pre-reqs:
--  N/A
--Modifies:
--  standard API message list
--Locks:
--  None.
--Parameters:
--IN:
--p_api_version
--  API version expected by the caller
--p_po_line_id
--  ID of a Standard PO line
--p_from_price_break
--  PO_CORE_S.G_PARAMETER_YES means that the price update is coming from a
--  price break;
--  PO_CORE_S.G_PARAMETER_NO means that the price update is coming from the user.
--p_add_reasons_to_msg_list
--  (Only applies if x_price_updateable = PO_CORE_S.G_PARAMETER_NO.)
--  If PO_CORE_S.G_PARAMETER_YES, the API will add the reasons why price updates
--  are not allowed to the standard API message list; otherwise, the API will not
--  add the reasons to the message list.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if the API completed successfully.
--  FND_API.G_RET_STS_ERROR if there was an error.
--  FND_API.G_RET_STS_UNEXP_ERROR if there was an unexpected error.
--x_price_updateable
--  PO_CORE_S.G_PARAMETER_YES if price updates are allowed on this shipment,
--  PO_CORE_S.G_PARAMETER_NO otherwise
--x_retroactive_price_change
--  PO_CORE_S.G_PARAMETER_YES if a price update on this PO line would be
--  considered a retroactive price change, PO_CORE_S.G_PARAMETER_NO otherwise.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_std_po_price_updateable (
  p_api_version               IN NUMBER,
  x_return_status             OUT NOCOPY VARCHAR2,
  p_po_line_id                IN PO_LINES_ALL.po_line_id%TYPE,
  p_from_price_break          IN VARCHAR2,
  p_add_reasons_to_msg_list   IN VARCHAR2,
  x_price_updateable          OUT NOCOPY VARCHAR2,
  x_retroactive_price_change  OUT NOCOPY VARCHAR2
) IS
  l_api_name CONSTANT VARCHAR2(30) := 'CHECK_STD_PO_PRICE_UPDATEABLE';
  l_log_head CONSTANT VARCHAR2(100):= g_log_head || l_api_name;
  l_api_version CONSTANT NUMBER := 1.0;
  l_progress VARCHAR2(3) := '000';

  l_has_ga_ref                PO_HEADERS_ALL.global_agreement_flag%TYPE;
  l_allow_price_override      PO_LINES_ALL.allow_price_override_flag%TYPE;
  l_accrue_invoice_count      NUMBER;
  l_pending_rcv_transactions  NUMBER;
  l_archive_mode_std_po       PO_DOCUMENT_TYPES.archive_external_revision_code%TYPE;
  l_current_org_id            NUMBER;

  l_po_header_id              NUMBER;  -- <Complex Work R12>
  l_is_complex_work_po        BOOLEAN; -- <Complex Work R12>
  l_is_financing_po           BOOLEAN; -- <Complex Work R12>

  --<Bug 18372756>:
  l_calling_sequence VARCHAR2(100) := 'PO_AP_DEBIT_MEMO_UNVALIDATED';
  l_unvalidated_debit_memo NUMBER;
  --<End bug 18372756>

BEGIN
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
  END IF;

  -- Standard API initialization:
  IF NOT FND_API.compatible_api_call (
           p_current_version_number => l_api_version,
           p_caller_version_number => p_api_version,
           p_api_name => l_api_name,
           p_pkg_name => g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Default: price updates allowed, no retroactive price change.
  x_price_updateable := PO_CORE_S.G_PARAMETER_YES;
  x_retroactive_price_change := PO_CORE_S.G_PARAMETER_NO;

  l_progress := '010';

  -- <Complex Work R12 START>
  SELECT pol.po_header_id
  INTO   l_po_header_id
  FROM   po_lines_all pol
  WHERE  pol.po_line_id = p_po_line_id;

  l_is_complex_work_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(
  p_po_header_id => l_po_header_id);

  IF (NOT l_is_complex_work_po) THEN
  -- <Complex Work R12 END>

    -- SQL What: Retrieve the GA flag and the Allow Price Override flag
    --           from the referenced document.
    -- SQL Why:  Used in the checks below.
    SELECT NVL(REFH.global_agreement_flag, 'N'),
           decode(REFH.type_lookup_code,'CONTRACT','Y',
                  NVL(REFL.allow_price_override_flag, 'N')) -- Bug 16839841
    INTO l_has_ga_ref,
         l_allow_price_override
    FROM po_lines_all POL,
         po_headers_all REFH,
         po_lines_all REFL
    WHERE POL.po_line_id = p_po_line_id
    AND   REFH.po_header_id (+) = POL.from_header_id -- JOIN
    AND   REFL.po_line_id (+) = POL.from_line_id; -- JOIN

    -- Bug 3565522 : get the archive mode
    l_archive_mode_std_po := PO_DOCUMENT_ARCHIVE_PVT.get_archive_mode(
                                        p_doc_type    => 'PO',
                                        p_doc_subtype => 'STANDARD');

    l_current_org_id := PO_GA_PVT.get_current_org;

    ----------------------------------------------------------------------------
    -- Check: Do not allow price updates if a receipt has been created against
    -- one of the line's shipments and it is accrued upon receipt, or if an
    -- invoice has been created against one of the line's shipments.
    -- * Exception: Allow such updates if the retroactive pricing mode is set
    -- to "All Releases" and the adjustment account is valid
    -- Bug 3565522 : Allow retroactive price changes for all releases only
    -- when the archive is set to approve
    ----------------------------------------------------------------------------
    l_progress := '020';
    IF (PO_RETROACTIVE_PRICING_PVT.get_retro_mode() = 'ALL_RELEASES') AND
       (l_archive_mode_std_po = 'APPROVE' )   AND
        not (PO_CORE_S.is_encumbrance_on(p_doc_type => 'PO',
                                         p_org_id   => l_current_org_id)) AND
        -- Bug 3231062
        (PO_RETROACTIVE_PRICING_PVT.Is_Retro_Project_Allowed(
                                    p_std_po_price_change => 'Y',
                                    p_po_line_id          => p_po_line_id,
                                    p_po_line_loc_id      => null ) = 'Y')
    THEN
      -- Allow price updates. Remember this as a retroactive price change.
      x_retroactive_price_change := PO_CORE_S.G_PARAMETER_YES;

      -- Bug 3339149
      IF (PO_RETROACTIVE_PRICING_PVT.Is_Adjustment_Account_Valid(
                                     p_std_po_price_change => 'Y',
                                     p_po_line_id          => p_po_line_id,
                                     p_po_line_loc_id      => null ) = 'N')
      THEN

        x_price_updateable := PO_CORE_S.G_PARAMETER_NO;
        x_retroactive_price_change := PO_CORE_S.G_PARAMETER_NO;

        IF (p_add_reasons_to_msg_list = PO_CORE_S.G_PARAMETER_YES) THEN
           FND_MESSAGE.set_name('PO','PO_RETRO_PRICING_NOT_ALLOWED');
           FND_MSG_PUB.add;
        END IF;
      END IF;

    ELSE
      -- SQL What: Returns the number of shipments of this line that are
      --           either received and accrued, or invoiced.
      SELECT count(*)
      INTO l_accrue_invoice_count
      FROM po_line_locations_all
      WHERE (po_line_id = p_po_line_id)
      AND ((NVL(quantity_received,0) > 0 AND accrue_on_receipt_flag = 'Y')
           OR (NVL(quantity_billed,0) > 0));

      IF (l_accrue_invoice_count > 0) THEN
        x_price_updateable := PO_CORE_S.G_PARAMETER_NO;
        IF (p_add_reasons_to_msg_list = PO_CORE_S.G_PARAMETER_YES) THEN
          FND_MESSAGE.set_name('PO','PO_CHNG_PRICE_RESTRICTED');
          FND_MSG_PUB.add;
        END IF;
      END IF;
    END IF; -- if retro mode is all_releases

    ----------------------------------------------------------------------------
    -- Check: For a standard PO referencing a GA, do not allow line price
    -- changes (except those from price breaks) if the GA line has
    -- Allow Price Override set to No.
    ----------------------------------------------------------------------------
    l_progress := '030';
    IF (l_has_ga_ref = 'Y')
       AND (NVL(p_from_price_break, PO_CORE_S.G_PARAMETER_NO)
            = PO_CORE_S.G_PARAMETER_NO)
       AND (l_allow_price_override = 'N') THEN
      x_price_updateable := PO_CORE_S.G_PARAMETER_NO;
      IF (p_add_reasons_to_msg_list = PO_CORE_S.G_PARAMETER_YES) THEN
        FND_MESSAGE.set_name('PO','PO_CHNG_GA_NO_PRICE_OVERRIDE');
        FND_MSG_PUB.add;
      END IF;
    END IF; -- l_has_ga_ref

  -- <Complex Work R12 START>
  ELSE -- IF (NOT l_is_complex_work_po)
    l_is_financing_po := PO_COMPLEX_WORK_PVT.is_financing_po(
    p_po_header_id => l_po_header_id);

    IF (l_is_financing_po) THEN
      -- SQL What: See if the delivery shipment has been executed against
      SELECT COUNT(*)
      INTO   l_accrue_invoice_count
      FROM   po_line_locations_all pll
      WHERE  po_line_id = p_po_line_id
      AND  pll.payment_type = 'DELIVERY'
      AND (    (     NVL(quantity_received,0) > 0
                 AND accrue_on_receipt_flag = 'Y'
               )
            OR NVL(quantity_billed,0) > 0
          );

      IF (l_accrue_invoice_count > 0) THEN
        x_price_updateable := PO_CORE_S.G_PARAMETER_NO;
        IF (p_add_reasons_to_msg_list = PO_CORE_S.G_PARAMETER_YES) THEN
          FND_MESSAGE.set_name('PO','PO_CHNG_PRICE_RESTRICTED');
          FND_MSG_PUB.add;
        END IF;
      END IF;
    END IF; -- IF (l_is_financing_po) THEN
  END IF; -- IF (NOT l_is_complex_work_po)
  -- <Complex Work R12 END>

  ----------------------------------------------------------------------------
  -- Check: Do not allow price changes if there are pending receiving
  -- transactions for any shipments of this line.
  ----------------------------------------------------------------------------
  l_progress := '040';

  -- SQL What: Returns 1 if there are any pending receiving transactions
  --           for the shipments of this line, 0 otherwise.
  -- SQL Why:  To prevent price changes if there are pending transactions.
  SELECT count(*)
  INTO l_pending_rcv_transactions
  FROM dual
  WHERE EXISTS
    ( SELECT 1
      FROM rcv_transactions_interface RTI, po_line_locations_all PLL
      WHERE PLL.po_line_id = p_po_line_id
      AND RTI.po_line_location_id = PLL.line_location_id -- JOIN
      AND RTI.transaction_status_code = 'PENDING' );

  IF (l_pending_rcv_transactions > 0) THEN
    x_price_updateable := PO_CORE_S.G_PARAMETER_NO;
    IF (p_add_reasons_to_msg_list = PO_CORE_S.G_PARAMETER_YES) THEN
      FND_MESSAGE.set_name('PO','PO_RCV_TRANSACTION_PENDING');
      FND_MSG_PUB.add;
    END IF;
  END IF;

    --<Bug 18372756>:
    ----------------------------------------------------------------------------
    l_progress := '050';
    -- SQL What: Returns 1 if there are any unvalidated debit memo
    --           for the shipments of this line, 0 otherwise.
    -- SQL Why:  To prevent price changes if there are unvalidated debit memo.
    SELECT count(*)
    INTO l_unvalidated_debit_memo
    FROM dual
    WHERE EXISTS
      ( SELECT 1
        FROM  PO_HEADERS_ALL POH,
                po_lines_all POL,
                po_line_locations_all poll
          WHERE POL.po_line_id = p_po_line_id
        AND POH.po_header_id = POL.po_header_id
        AND poll.po_line_id = pol.po_line_id
        AND (poll.quantity_billed = 0 OR poll.quantity_billed is null)
        AND PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, NULL, pol.po_line_id, poll.line_location_id, NULL, NULL, l_calling_sequence) = 1
        );

    IF (l_unvalidated_debit_memo > 0) THEN
      x_price_updateable := PO_CORE_S.G_PARAMETER_NO;
      IF (p_add_reasons_to_msg_list = PO_CORE_S.G_PARAMETER_YES) THEN
        FND_MESSAGE.set_name('PO','PO_AP_DEBIT_MEMO_UNVALIDATED');
        FND_MSG_PUB.add;
      END IF;
    END IF;
    --<End Bug 18372756>

  IF g_debug_stmt THEN
    PO_DEBUG.debug_end(l_log_head);
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||'.'||l_progress);
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
END check_std_po_price_updateable;

-------------------------------------------------------------------------------
--Start of Comments
--Name: check_rel_price_updateable
--Function:
--  Checks whether price updates are allowed on this release shipment.
--Pre-reqs:
--  N/A
--Modifies:
--  standard API message list
--Locks:
--  None.
--Parameters:
--IN:
--p_api_version
--  API version expected by the caller
--p_line_location_id
--  ID of a release shipment
--p_from_price_break
--  PO_CORE_S.G_PARAMETER_YES means that the price update is coming from a
--  price break;
--  PO_CORE_S.G_PARAMETER_NO means that the price update is coming from the user.
--p_add_reasons_to_msg_list
--  (Only applies if x_price_updateable = PO_CORE_S.G_PARAMETER_NO.)
--  If PO_CORE_S.G_PARAMETER_YES, the API will add the reasons why price updates
--  are not allowed to the standard API message list; otherwise, the API will not
--  add the reasons to the message list.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if the API completed successfully.
--  FND_API.G_RET_STS_ERROR if there was an error.
--  FND_API.G_RET_STS_UNEXP_ERROR if there was an unexpected error.
--x_price_updateable
--  PO_CORE_S.G_PARAMETER_YES if price updates are allowed on this shipment,
--  PO_CORE_S.G_PARAMETER_NO otherwise
--x_retroactive_price_change
--  PO_CORE_S.G_PARAMETER_YES if a price update on this release shipment would
--  be considered a retroactive price change, PO_CORE_S.G_PARAMETER_NO otherwise.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_rel_price_updateable (
  p_api_version               IN NUMBER,
  x_return_status             OUT NOCOPY VARCHAR2,
  p_line_location_id          IN PO_LINE_LOCATIONS_ALL.line_location_id%TYPE,
  p_from_price_break          IN VARCHAR2,
  p_add_reasons_to_msg_list   IN VARCHAR2,
  x_price_updateable          OUT NOCOPY VARCHAR2,
  x_retroactive_price_change  OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'CHECK_REL_PRICE_UPDATEABLE';
  l_log_head CONSTANT VARCHAR2(100):= g_log_head || l_api_name;
  l_api_version CONSTANT NUMBER := 1.0;
  l_progress VARCHAR2(3) := '000';

  l_allow_price_override      PO_LINES_ALL.allow_price_override_flag%TYPE;
  l_qty_received              PO_LINE_LOCATIONS.quantity_received%TYPE;
  l_accrue_flag               PO_LINE_LOCATIONS.accrue_on_receipt_flag%TYPE;
  l_qty_billed                PO_LINE_LOCATIONS.quantity_billed%TYPE;
  l_pending_rcv_transactions  NUMBER;
  -- Bug 3565522
  l_archive_mode_rel          PO_DOCUMENT_TYPES.archive_external_revision_code%TYPE;
  l_current_org_id            NUMBER;

  --<Bug 18372756>:
  l_calling_sequence VARCHAR2(100) := 'PO_AP_DEBIT_MEMO_UNVALIDATED';
  l_unvalidated_debit_memo NUMBER;
  --<End Bug 18372756>

BEGIN
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
  END IF;

  -- Standard API initialization:
  IF NOT FND_API.compatible_api_call (
           p_current_version_number => l_api_version,
           p_caller_version_number => p_api_version,
           p_api_name => l_api_name,
           p_pkg_name => g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Default: price updates allowed, no retroactive price change.
  x_price_updateable := PO_CORE_S.G_PARAMETER_YES;
  x_retroactive_price_change := PO_CORE_S.G_PARAMETER_NO;

  l_progress := '010';

  -- SQL What: Retrieve the GA flag and the Allow Price Override flag
  --           from the referenced document.
  -- SQL Why:  Used in the checks below.
  SELECT NVL(PLL.quantity_received,0),
         NVL(PLL.accrue_on_receipt_flag,'N'),
         NVL(PLL.quantity_billed,0),
         NVL(POL.allow_price_override_flag, 'N')
  INTO l_qty_received,
       l_accrue_flag,
       l_qty_billed,
       l_allow_price_override
  FROM po_line_locations_all PLL,
       po_lines_all POL
  WHERE PLL.line_location_id = p_line_location_id
  AND   PLL.po_line_id = POL.po_line_id; -- JOIN

   -- Bug 3565522 : get the archive mode
  l_archive_mode_rel   := PO_DOCUMENT_ARCHIVE_PVT.get_archive_mode(
                                      p_doc_type    => 'RELEASE',
                                      p_doc_subtype => 'BLANKET');
  l_current_org_id := PO_GA_PVT.get_current_org;

  ----------------------------------------------------------------------------
  -- Check: Do not allow price updates if a receipt has been created against
  -- the shipments and it is accrued upon receipt, or if an invoice has been
  -- created against one of the line's shipments.
  -- * Exception: Allow such updates if the retroactive pricing mode is set to
  --   "All Releases". In this case the adjustment account should be valid
  -- Bug 3565522 : Allow retroactive price changes for all releases only
  -- when the archive is set to approve
  ----------------------------------------------------------------------------
  l_progress := '020';
  IF (PO_RETROACTIVE_PRICING_PVT.get_retro_mode() = 'ALL_RELEASES') AND
     (l_archive_mode_rel = 'APPROVE') AND
      not (PO_CORE_S.is_encumbrance_on(p_doc_type => 'RELEASE',
                                       p_org_id   => l_current_org_id)) AND
      -- Bug 3231062
      (PO_RETROACTIVE_PRICING_PVT.Is_Retro_Project_Allowed(
                                  p_std_po_price_change => 'N',
                                  p_po_line_id          => null,
                                  p_po_line_loc_id      => p_line_location_id ) = 'Y')
  THEN
    -- Allow price updates. Remember this as a retroactive price change.
    x_retroactive_price_change := PO_CORE_S.G_PARAMETER_YES;

    -- Bug 3339149
    IF (PO_RETROACTIVE_PRICING_PVT.Is_Adjustment_Account_Valid(
                                   p_std_po_price_change => 'N',
                                   p_po_line_id          => null,
                                   p_po_line_loc_id      => p_line_location_id ) = 'N')
    THEN

      x_price_updateable := PO_CORE_S.G_PARAMETER_NO;
      x_retroactive_price_change := PO_CORE_S.G_PARAMETER_NO;

      IF (p_add_reasons_to_msg_list = PO_CORE_S.G_PARAMETER_YES) THEN
         FND_MESSAGE.set_name('PO','PO_RETRO_PRICING_NOT_ALLOWED');
         FND_MSG_PUB.add;
      END IF;
    END IF;

  ELSE
    IF ((l_qty_received > 0) AND (l_accrue_flag = 'Y'))
       OR (l_qty_billed > 0) THEN
      x_price_updateable := PO_CORE_S.G_PARAMETER_NO;
      IF (p_add_reasons_to_msg_list = PO_CORE_S.G_PARAMETER_YES) THEN
        FND_MESSAGE.set_name('PO','PO_CHNG_PRICE_RESTRICTED');
        FND_MSG_PUB.add;
      END IF;
    END IF;
  END IF; -- g_retropricing_mode

  ----------------------------------------------------------------------------
  -- Check: Do not allow shipment price changes (except those from price breaks)
  -- if the blanket line has Allow Price Override set to No.
  ----------------------------------------------------------------------------
  l_progress := '030';
  IF (NVL(p_from_price_break, PO_CORE_S.G_PARAMETER_NO)
      = PO_CORE_S.G_PARAMETER_NO)
     AND (l_allow_price_override = 'N') THEN
    x_price_updateable := PO_CORE_S.G_PARAMETER_NO;
    IF (p_add_reasons_to_msg_list = PO_CORE_S.G_PARAMETER_YES) THEN
      FND_MESSAGE.set_name('PO','PO_CHNG_NO_PRICE_OVERRIDE');
      FND_MSG_PUB.add;
    END IF;
  END IF;

  ----------------------------------------------------------------------------
  -- Check: Do not allow price changes if there are pending receiving
  -- transactions for this shipment.
  ----------------------------------------------------------------------------
  l_progress := '040';

  -- SQL What: Returns 1 if there are any pending receiving transactions
  --           for the shipments of this line, 0 otherwise.
  -- SQL Why:  To prevent price changes if there are pending transactions.
  SELECT count(*)
  INTO l_pending_rcv_transactions
  FROM dual
  WHERE EXISTS
    ( SELECT 1
      FROM rcv_transactions_interface RTI
      WHERE RTI.po_line_location_id = p_line_location_id
      AND RTI.transaction_status_code = 'PENDING' );

  IF (l_pending_rcv_transactions > 0) THEN
    x_price_updateable := PO_CORE_S.G_PARAMETER_NO;
    IF (p_add_reasons_to_msg_list = PO_CORE_S.G_PARAMETER_YES) THEN
      FND_MESSAGE.set_name('PO','PO_RCV_TRANSACTION_PENDING');
      FND_MSG_PUB.add;
    END IF;
  END IF;

    --<Bug 18372756>:
    ----------------------------------------------------------------------------
    l_progress := '050';

    -- SQL What: Returns 1 if there are any unvalidated debit memo
    --           for the shipments of this line, 0 otherwise.
    -- SQL Why:  To prevent price changes if there are unvalidated debit memo.
    SELECT count(*)
    INTO l_unvalidated_debit_memo
    FROM dual
    WHERE EXISTS
      ( SELECT 1
        FROM  PO_HEADERS_ALL POH,
                po_lines_all POL,
                po_line_locations_all pll,
                po_releases_all por
          WHERE POL.po_line_id = pll.po_line_id
           AND pll.line_location_id = p_line_location_id
        AND POH.po_header_id = POL.po_header_id
        AND por.po_header_id = poh.po_header_id
        AND pll.po_release_id = por.po_release_id
        AND (pll.quantity_billed = 0 OR pll.quantity_billed is null)
        AND PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, por.po_release_id, pol.po_line_id, pll.line_location_id, NULL, NULL, l_calling_sequence) = 1
        );

    IF (l_unvalidated_debit_memo > 0) THEN
      x_price_updateable := PO_CORE_S.G_PARAMETER_NO;
      IF (p_add_reasons_to_msg_list = PO_CORE_S.G_PARAMETER_YES) THEN
        FND_MESSAGE.set_name('PO','PO_AP_DEBIT_MEMO_UNVALIDATED');
        FND_MSG_PUB.add;
      END IF;
    END IF;
    --<End bug 18372756>

  IF g_debug_stmt THEN
    PO_DEBUG.debug_end(l_log_head);
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name||'.'||l_progress);
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head, l_progress);
    END IF;
END check_rel_price_updateable;
-- Bug 3312906 END

-- <Complex Work R12 START>
-- Checks if a pay item price is updateable
PROCEDURE check_payitem_price_updateable (
  p_api_version               IN NUMBER
, p_line_location_id          IN NUMBER
, p_add_reasons_to_msg_list   IN VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_price_updateable          OUT NOCOPY VARCHAR2
) IS

  d_module VARCHAR2(70) :=
                'po.plsql.PO_DOCUMENT_CHECKS_GRP.check_payitem_price_updateable';
  d_progress NUMBER;
  l_is_price_updateable  BOOLEAN;

BEGIN
  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_api_version', p_api_version);
    PO_LOG.proc_begin(d_module, 'p_line_location_id', p_line_location_id);
    PO_LOG.proc_begin(d_module, 'p_add_reasons_to_msg_list', p_add_reasons_to_msg_list);
  END IF;

  d_progress := 10;

  x_return_status := FND_API.g_ret_sts_success;

  l_is_price_updateable := PO_DOCUMENT_CHECKS_PVT.is_pay_item_price_updateable(
      p_line_location_id         => p_line_location_id
    , p_add_reasons_to_msg_list  => p_add_reasons_to_msg_list);

  d_progress := 20;

  IF (l_is_price_updateable) THEN
    x_price_updateable := PO_CORE_S.g_parameter_yes;
  ELSE
    x_price_updateable := PO_CORE_S.g_parameter_no;
  END IF;

  d_progress := 30;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_price_updateable', x_price_updateable);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_price_updateable := PO_CORE_S.g_parameter_no;
END;
-- <Complex Work R12 END>

-- Bug 5560980 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: merge_online_report_id
--Function:
--  Private procedure to combine the two online reports to one new report and
--  return the single id for the new combined report
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE merge_online_report_id
(
  p_report_id1      IN NUMBER,
  p_report_id2      IN NUMBER,
  x_new_report_id   OUT NOCOPY NUMBER -- id for new combined online report
)
IS
  d_module VARCHAR2(70) :=
                'po.plsql.PO_DOCUMENT_CHECKS_GRP.merge_online_report_id';
  d_progress NUMBER;
  l_id1_max_seq NUMBER; -- max sequence number value for the first online report
  l_id2_seq_list   PO_TBL_NUMBER; -- list for all sequence numbers of report 2

BEGIN
  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_report_id1', p_report_id1);
    PO_LOG.proc_begin(d_module, 'p_report_id2', p_report_id2);
  END IF;

  d_progress := 10;

  -- SQL What: Get the id from the given nline report sequence
  -- SQL Why:  Used for the new combined online report below.
  SELECT po_online_report_text_s.nextval
  INTO x_new_report_id
  FROM sys.dual;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_progress,'After got the new id for combined online report');
  END IF;

  d_progress := 20;

  -- SQL What: Copy all data rows from the online report 1 to the new combined
  -- online report.
  -- SQL Why:  Construct the 1st part of the new combined online report.
  INSERT INTO PO_ONLINE_REPORT_TEXT
 (
   online_report_id
  ,sequence
  ,last_updated_by
  ,last_update_date
  ,created_by
  ,creation_date
  ,last_update_login
  ,text_line
  ,line_num
  ,shipment_num
  ,distribution_num
  ,transaction_level
  ,quantity
  ,transaction_id
  ,transaction_date
  ,transaction_type
  ,transaction_uom
  ,transaction_location
  ,request_id
  ,program_application_id
  ,program_id
  ,program_update_date
  ,message_type
  ,show_in_psa_flag
  ,segment1
  ,distribution_type
 )
  SELECT
    x_new_report_id
    ,sequence
    ,last_updated_by
    ,last_update_date
    ,created_by
    ,creation_date
    ,last_update_login
    ,text_line
    ,line_num
    ,shipment_num
    ,distribution_num
    ,transaction_level
    ,quantity
    ,transaction_id
    ,transaction_date
    ,transaction_type
    ,transaction_uom
    ,transaction_location
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,message_type
    ,show_in_psa_flag
    ,segment1
    ,distribution_type
  FROM PO_ONLINE_REPORT_TEXT
  WHERE online_report_id = p_report_id1
  ORDER BY sequence ASC;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_progress,'After inserted data of report 1 to the combined report, #rows='||SQL%ROWCOUNT);
  END IF;

  d_progress := 30;

  -- SQL What: Retrieve the max sequence number value from all rows of online report 1.
  -- SQL Why:  To set the start value for the sequence increment used to add rows from report 2.
  SELECT MAX(sequence)
  INTO l_id1_max_seq
  FROM PO_ONLINE_REPORT_TEXT
  WHERE online_report_id = p_report_id1;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_progress,'After got the max sequence for online report 1 rows as: '||l_id1_max_seq);
  END IF;

  d_progress := 40;

  -- SQL What: Retrieve list for all sequence numbers of report 2
  -- SQL Why:  Used to count how many rows from report 2 need to be added to combined report.
  SELECT sequence
  BULK COLLECT INTO l_id2_seq_list
  FROM PO_ONLINE_REPORT_TEXT
  WHERE online_report_id = p_report_id2
  ORDER BY sequence ASC;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_progress,'After got the sequence list for online report 2');
  END IF;

  d_progress := 50;

  -- SQL What: For each row of reprot 2, change the sequence number to the series incremented
  --           from the max sequence number from report1. Then add the row into
  --           the combined report.
  -- SQL Why:  Construct the 2nd part of the new combined online report.
  FOR i IN 1 .. l_id2_seq_list.COUNT
  LOOP
    INSERT INTO PO_ONLINE_REPORT_TEXT
   (
    online_report_id
  ,sequence
  ,last_updated_by
  ,last_update_date
  ,created_by
  ,creation_date
  ,last_update_login
  ,text_line
  ,line_num
  ,shipment_num
  ,distribution_num
  ,transaction_level
  ,quantity
  ,transaction_id
  ,transaction_date
  ,transaction_type
  ,transaction_uom
  ,transaction_location
  ,request_id
  ,program_application_id
  ,program_id
  ,program_update_date
  ,message_type
  ,show_in_psa_flag
  ,segment1
  ,distribution_type
   )
   SELECT
    x_new_report_id
    ,l_id1_max_seq + i -- increment
    ,last_updated_by
    ,last_update_date
    ,created_by
    ,creation_date
    ,last_update_login
    ,text_line
    ,line_num
    ,shipment_num
    ,distribution_num
    ,transaction_level
    ,quantity
    ,transaction_id
    ,transaction_date
    ,transaction_type
    ,transaction_uom
    ,transaction_location
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,message_type
    ,show_in_psa_flag
    ,segment1
    ,distribution_type
   FROM PO_ONLINE_REPORT_TEXT
   WHERE online_report_id = p_report_id2 and sequence = l_id2_seq_list(i);
  END LOOP;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_progress,'After inserted data of report 2 to the combined report');
  END IF;

  d_progress := 100;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_new_report_id', x_new_report_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
END merge_online_report_id;

-------------------------------------------------------------------------------
--Start of Comments
--Name: po_combined_submission_check
--Function:
--  Call both Copy_Doc submission check and regular po submission check,
--  then combine the two online reports to one and return the single report id
/**
* Public Procedure:
* Requires:
*   IN PARAMETERS:
*     p_api_version:       Version number of API that caller expects. It
*                          should match the l_api_version defined in the
*                          procedure
*     p_action_requested:  In FPJ, the Action requested should be in
*                             g_action_(DOC_SUBMISSION_CHECK, UNRESERVE)
*     p_document_type:     The type of the document to perform
*                          the submission check on.
*     p_document_subtype:  The subtype of the document.
*                          Valid Document types and Document subtypes are
*                          Document Type      Document Subtype
*                          REQUISITION  --->
*                          RELEASE      --->  SCHEDULED/BLANKET
*                          PO           --->  PLANNED/STANDARD
*                          PA           --->  CONTRACT/BLANKET
--
--  <FPJ ENCUMBRANCE>
--    The following 2 parameters replace the p_document_id parameter.
--p_document_level
--  The type of id that is being passed.  Use g_doc_level_<>
--    HEADER
--  The following are only supported for the UNRESERVE action:
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_document_level_id
--  Id of the doc level type on which to perform the check.
--
--
--p_org_id
--  If not NULL, this org context will be set.
--
--
*     p_requested_changes: This object contains all the requested changes to
*                          the document. It contains 5 objects. These objects
*                          are: 1.Header_Changes 2.Release_Changes 3.Line_
*                          Changes 4.Shipment_Changes 5.Distribution_Changes.
*                          In FPI, following change requests are allowed:
*                          1. HEADER_CHANGES: None
*                          2. RELEASE_CHANGES: None
*                          3. LINE_CHANGES: unit_price, vendor_product_num
*                          4. SHIPMENT_CHANGES: quantity, promised_date,
*                             price_override
*                          5. DISTRIBUTION_CHANGES: quantity_ordered
*     p_check_asl:         Determines whether or not to perform the checks:
*                          PO_SUB_ITEM_NOT_APPROVED / PO_SUB_ITEM_ASL_DEBARRED
*                          (a) TRUE  : Perform check
*                          (b) FALSE : Do not perform check
*
* Modifies: Inserts error msgs in online_report_text table, uses global_temp
*           tables for processing
* Effects:  This procedure runs the document submission checks on passed in
*           document.
* Returns:
*  x_return_status:    FND_API.G_RET_STS_SUCCESS if API succeeds
*                      FND_API.G_RET_STS_ERROR if API fails
*                      FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
*  x_sub_check_status: FND_API.G_RET_STS_SUCCESS if document passes all
*                      submission checks, even if warnings are found
*                      FND_API.G_RET_STS_ERROR if document fails atleast one
*                      submission check (returns at least one error)
*  x_has_warnings:     FND_API.G_TRUE if submission check returns warnings
*                      FND_API.G_FALSE if no warnings are found
*  x_msg_data:         Contains error msg in case x_return_status returned
*                      FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_UNEXP_ERROR
*  x_online_report_id: This id can be used to get all submission check (including
*                      copydoc check and normal po submission check) errors
*                      for given document from online_report_text table.
*  x_doc_check_error_record: If x_sub_check_status returned G_RET_STS_ERROR
*                      then this object of tables will contain information about
*                      all submission check errors for given document including
*                      message_name and text_line.
*/
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE po_combined_submission_check(
   p_api_version                    IN           NUMBER
,  p_action_requested               IN           VARCHAR2
,  p_document_type                  IN           VARCHAR2
,  p_document_subtype               IN           VARCHAR2
,  p_document_level                 IN           VARCHAR2
,  p_document_level_id              IN           NUMBER
,  p_org_id                         IN           NUMBER
,  p_requested_changes              IN           PO_CHANGES_REC_TYPE
,  p_check_asl                      IN           BOOLEAN
,  p_req_chg_initiator              IN           VARCHAR2 := NULL -- bug4957243
,  p_origin_doc_id                  IN           NUMBER := NULL -- Bug#5462677
-- parameters for combination
,  p_from_header_id	                IN           NUMBER
,  p_from_type_lookup_code	        IN           VARCHAR2
,  p_po_header_id                   IN           NUMBER
,  p_online_report_id               IN           NUMBER
,  p_sob_id                         IN           NUMBER
,  x_return_status                  OUT NOCOPY   VARCHAR2
,  x_sub_check_status               OUT NOCOPY   VARCHAR2
,  x_has_warnings                   OUT NOCOPY   VARCHAR2  -- bug3574165
,  x_msg_data                       OUT NOCOPY   VARCHAR2
,  x_online_report_id               OUT NOCOPY   NUMBER
,  x_doc_check_error_record         OUT NOCOPY   doc_check_Return_Type
)
 IS

  d_module VARCHAR2(70) :=
                'po.plsql.PO_DOCUMENT_CHECKS_GRP.po_combined_submission_check';
  d_progress NUMBER;
  l_report_id1_rownum NUMBER; --the number of data rows for report 1
  l_report_id2_rownum NUMBER; --the number of data rows for report 2
  l_report_id2 NUMBER; --id for report 2
  l_inv_org_id NUMBER;  --bug 6713929

BEGIN
  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_api_version', p_api_version);
    PO_LOG.proc_begin(d_module, 'p_action_requested', p_action_requested);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_document_level', p_document_level);
    PO_LOG.proc_begin(d_module, 'p_document_level_id', p_document_level_id);
    PO_LOG.proc_begin(d_module, 'p_org_id', p_org_id);
    PO_LOG.proc_begin(d_module, 'p_check_asl', p_check_asl);
    PO_LOG.proc_begin(d_module, 'p_from_header_id', p_from_header_id);
    PO_LOG.proc_begin(d_module, 'p_from_type_lookup_code', p_from_type_lookup_code);
    PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_sob_id', p_sob_id);
  END IF;

  d_progress := 10;

 -- bug 6713929 execute a query to fetch inventory_org_id set for this Operating Unit
  BEGIN
    SELECT FSP.inventory_organization_id
    INTO l_inv_org_id
    FROM po_system_parameters_all PSP,
     financials_system_params_all FSP,
     gl_sets_of_books GLS,
     fnd_id_flex_structures COAFS
    WHERE FSP.org_id= PSP.org_id
    AND FSP.set_of_books_id = GLS.set_of_books_id
    AND COAFS.id_flex_num = GLS.chart_of_accounts_id
    AND COAFS.application_id = 101 /** SQLGL **/
    AND COAFS.id_flex_code = 'GL#'
    AND fsp.org_id = p_org_id;
   END;


  --If there is a source document and the source document type is one of
  --'QUOTATION', 'STANDARD', 'PLANNED', 'BLANKET', 'CONTRACT';
  --Then we need to do the copydoc submission check first and generate online report 1.
  IF (p_from_header_id IS NOT NULL AND
      p_from_type_lookup_code in ('QUOTATION', 'STANDARD', 'PLANNED', 'BLANKET', 'CONTRACT')) THEN --<BUG 3520619>
      PO_COPYDOC_SUB.SUBMISSION_CHECK_COPYDOC(
       x_po_header_id        =>    p_po_header_id
      ,x_online_report_id    =>    p_online_report_id
      ,x_sob_id              =>    p_sob_id
      ,x_inv_org_id          =>    l_inv_org_id   --bug 6713929
      );
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_progress,'After called SUBMISSION_CHECK_COPYDOC()');
  END IF;

  d_progress := 20;

  -- Do the normal PO submission check and generate online report 2
  po_submission_check(
     p_api_version            =>    p_api_version
  ,  p_action_requested       =>    p_action_requested
  ,  p_document_type          =>    p_document_type
  ,  p_document_subtype       =>    p_document_subtype
  ,  p_document_level         =>    p_document_level
  ,  p_document_level_id      =>    p_document_level_id
  ,  p_org_id                 =>    p_org_id
  ,  p_requested_changes      =>    p_requested_changes
  ,  p_check_asl              =>    p_check_asl
  ,  p_req_chg_initiator      =>    p_req_chg_initiator
  ,  p_origin_doc_id          =>    p_origin_doc_id
  ,  x_return_status          =>    x_return_status
  ,  x_sub_check_status       =>    x_sub_check_status
  ,  x_has_warnings           =>    x_has_warnings
  ,  x_msg_data               =>    x_msg_data
  ,  x_online_report_id       =>    l_report_id2
  ,  x_doc_check_error_record =>    x_doc_check_error_record
  );

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_progress,'After called po_submission_check()');
  END IF;

  d_progress := 30;

  -- SQL What: Get the number of data rows generated for report 1
  -- SQL Why:  Used for the check below.
  SELECT COUNT(*)
  INTO l_report_id1_rownum
  FROM PO_ONLINE_REPORT_TEXT
  WHERE online_report_id = p_online_report_id;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_progress,'After counted the first report rows and get the count as: '|| TO_CHAR(l_report_id1_rownum));
  END IF;

  d_progress := 40;

  -- SQL What: Get the number of data rows generated for report 2
  -- SQL Why:  Used for the check below.
  SELECT COUNT(*)
  INTO l_report_id2_rownum
  FROM PO_ONLINE_REPORT_TEXT
  WHERE online_report_id = l_report_id2;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_progress,'After counted the second report rows and get the count as: '|| TO_CHAR(l_report_id2_rownum));
  END IF;

  d_progress := 50;

  -- If there is data rows generated for both report 1 (copy doc check report in this case) and report 2 (normal po submission check),
  -- Then merge all data of report 1 and report 2 and generate a new report with a new report id
  IF (NVL(l_report_id1_rownum, 0) > 0) THEN

    --Change the x_return_status to success if there is any error/warnings created in the first report(copydoc submission check)
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --Also change the x_sub_check_status to FND_API.G_RET_STS_ERROR if there is any error/warnings created in the first report(copydoc submission check)
    x_sub_check_status := FND_API.G_RET_STS_ERROR;

    IF ((NVL(l_report_id2_rownum, 0) > 0)) THEN
      merge_online_report_id
      (
        p_report_id1      =>    p_online_report_id
      , p_report_id2      =>    l_report_id2
      , x_new_report_id   =>    x_online_report_id
      );

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module,d_progress,'After called merge_online_report_id(), created the new report id');
      END IF;
    ELSE -- If only report 1 has msg rows, then return the id for report 1 directly.
      x_online_report_id := p_online_report_id;

      IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module,d_progress,'Not called merge_online_report_id(), use the first report id as:' || TO_CHAR(p_online_report_id));
      END IF;
    END IF;

  d_progress := 60;

  -- If there is no data rows generated for report 1, return the id for report 2 directly.
  ELSE
    x_online_report_id := l_report_id2;

    IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_progress,'Not called merge_online_report_id(), use the second report id as:' || TO_CHAR(l_report_id2));
    END IF;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_sub_check_status', x_sub_check_status);
    PO_LOG.proc_end(d_module, 'x_has_warnings', x_has_warnings);
    PO_LOG.proc_end(d_module, 'x_msg_data', x_msg_data);
    PO_LOG.proc_end(d_module, 'x_online_report_id', x_online_report_id);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
END po_combined_submission_check;

-- Bug 5560980 END


END PO_DOCUMENT_CHECKS_GRP;

/
