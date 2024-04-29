--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_CHECKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_CHECKS_PVT" AS
/* $Header: POXVDCKB.pls 120.64.12010000.174 2014/12/19 09:00:13 roqiu ship $*/




-----------------------------------------------------------------------------
-- Define private package constants.
-----------------------------------------------------------------------------

-- This is used as a delimiter in constructing the error msgs
g_delim CONSTANT VARCHAR2(1) := ' ';

--Contains message 'Line#'
g_linemsg CONSTANT VARCHAR2(75) := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_LINE'), 1,25);

--Contains message 'Schedule#'
g_shipmsg CONSTANT VARCHAR2(75) := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_SCHEDULE'), 1,25);

--Contains message 'Distribution#'
g_distmsg CONSTANT VARCHAR2(75) := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_DISTRIBUTION'), 1,25);

--Contains message 'Price Break#'
g_price_breakmsg CONSTANT VARCHAR2(75) := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_PRICE_BREAK'), 1,25);

--Contains message 'Quantity'
g_qtymsg CONSTANT VARCHAR2(75) := substr(FND_MESSAGE.GET_STRING('PO', 'PO_SUB_TOKEN_QUANTITY'),1,25);

--<Bug 2790228>
--Contains message 'Shipment Quantity'
g_shipqtymsg CONSTANT VARCHAR2(40) := substrb(FND_MESSAGE.GET_STRING('PO', 'PO_SUB_TOKEN_SHIP_QUANTITY'),1,40);

--Contains message 'Distribution Quantity'
g_distqtymsg CONSTANT VARCHAR2(40) := substrb(FND_MESSAGE.GET_STRING('PO', 'PO_SUB_TOKEN_DIST_QUANTITY'),1,40);

G_PKG_NAME CONSTANT varchar2(30) := 'PO_DOCUMENT_CHECKS_PVT';

g_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';




-----------------------------------------------------------------------------
-- Declare private package variables.
-----------------------------------------------------------------------------

-- Refactored debugging
g_debug_stmt  CONSTANT BOOLEAN := (PO_DEBUG.is_debug_stmt_on And (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));   /* In Bug# 5028960, Modified to Avoid File.sql.46 error*/
g_debug_unexp CONSTANT BOOLEAN := (PO_DEBUG.is_debug_unexp_on AND (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)); /* In Bug# 5028960, Modified to Avoid File.sql.46 error*/




--------------------------------------------------------------------------------
-- Forward procedure declarations
--------------------------------------------------------------------------------

PROCEDURE populate_global_temp_tables(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
);

-- <Doc Manager Rewrite 11.5.11 Start>
PROCEDURE populate_po_lines_gt(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  x_return_status                  OUT NOCOPY     VARCHAR2
);
-- <Doc Manager Rewrite 11.5.11 End>

PROCEDURE populate_line_locations_gt(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
);

PROCEDURE populate_distributions_gt(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
);

PROCEDURE check_unreserve(
   p_online_report_id               IN             NUMBER
,  p_document_type                  IN             VARCHAR2 --Bug#5462677
,  p_document_subtype               IN             VARCHAR2 --Bug#5462677
,  p_document_level                 IN             VARCHAR2 --Bug#5462677
,  p_doc_level_id                   IN             NUMBER   --Bug#5462677
,  p_user_id                        IN             NUMBER
,  p_login_id                       IN             NUMBER
,  p_sequence                       IN OUT NOCOPY  NUMBER
);

PROCEDURE check_gl_date(
   p_doc_type                       IN             VARCHAR2
,  p_online_report_id               IN             NUMBER
,  p_login_id                       IN             NUMBER
,  p_user_id                        IN             NUMBER
,  p_sequence                       IN OUT NOCOPY  NUMBER
);

PROCEDURE check_blanket_agreement(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_check_asl IN BOOLEAN,                     -- <2757450>
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

-- bug3592160 START
PROCEDURE complete_po_header_id_tbl
( p_count            IN NUMBER,
  p_header_id        IN PO_TBL_NUMBER,
  p_release_id       IN PO_TBL_NUMBER,
  p_vendor_order_num IN PO_TBL_VARCHAR30,
  p_document_num     IN PO_TBL_VARCHAR30,
  p_type_lookup_code IN PO_TBL_VARCHAR30,
  x_header_id        OUT NOCOPY PO_TBL_NUMBER
);
-- bug3592160 END

-- <Doc Manager Rewrite 11.5.11 Start>
PROCEDURE check_final_close(
   p_document_type        IN VARCHAR2
,  p_document_subtype     IN VARCHAR2
,  p_document_level       IN VARCHAR2
,  p_document_id          IN NUMBER
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_origin_doc_id        IN NUMBER := NULL --Bug#5462677
,  p_doc_level_id         IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
);

PROCEDURE check_rcv_trans_interface(
   p_document_type        IN VARCHAR2
,  p_document_level       IN VARCHAR2  --<Bug 4118145, Issue 7>: Corrected type
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_document_id          IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
);

PROCEDURE check_asn_not_fully_received(
   p_document_type        IN VARCHAR2
,  p_document_level       IN VARCHAR2    --<Bug 9012072, Added the p_document_level IN parameter
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
);

PROCEDURE check_qty_rcv_but_not_deliv(
   p_document_type        IN VARCHAR2
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
);

PROCEDURE check_amt_rcv_but_not_deliv(
   p_document_type        IN VARCHAR2
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
);

-- <<Bug#16498663 Start>>
PROCEDURE check_amt_fin_not_fully_rec(
   p_document_level       IN VARCHAR2
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
);
-- <<Bug#16498663 End>>

PROCEDURE check_invalid_acct_flex(
   p_document_type        IN VARCHAR2
,  p_action_requested     IN VARCHAR2
,  p_action_date          IN DATE
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_document_id          IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
);

PROCEDURE check_bpa_has_open_release(
   p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
);

PROCEDURE check_bpa_has_open_stdref(
   p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
);

PROCEDURE check_cpa_has_open_stdref(
   p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
);

PROCEDURE check_ppo_has_open_release(
   p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
);

--<Complex Work R12 START>
PROCEDURE check_po_qty_amt_rollup(
   p_online_report_id     IN NUMBER
,  p_document_id          IN NUMBER
,  p_login_id             IN NUMBER
,  p_user_id              IN NUMBER
,  x_sequence             IN OUT NOCOPY NUMBER
);

PROCEDURE check_unvalidated_invoices(p_document_type    IN VARCHAR2,
                                     p_document_subtype     IN VARCHAR2,
                                     p_action_requested IN VARCHAR2,
                                     p_action_date      IN DATE,
                                     p_online_report_id IN NUMBER,
                                     p_user_id          IN NUMBER,
                                     p_login_id         IN NUMBER,
                                     p_document_level   IN VARCHAR2,
                                     p_origin_doc_id    IN NUMBER,
                                     p_doc_level_id     IN NUMBER,
                                     p_sequence         IN OUT NOCOPY NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE get_message_info(p_document_type    IN VARCHAR2,
                           p_document_subtype IN VARCHAR2,
                           p_action_requested IN VARCHAR2,
                           p_document_level   IN VARCHAR2,
                           p_doc_level_id      IN NUMBER,
                           x_text_line        OUT  NOCOPY VARCHAR2,
                           x_message_name     OUT  NOCOPY VARCHAR2,
                           x_invoice_type     OUT  NOCOPY VARCHAR2,
                           x_calling_sequence OUT  NOCOPY VARCHAR2,
                           x_return_status    OUT  NOCOPY VARCHAR2);


--<Complex Work R12 END>

-- <Doc Manager Rewrite 11.5.11 End

/* CONTERMS FPJ START*/
-------------------------------------------------------------------------------
--Start of Comments
--Name: check_terms
--Pre-reqs:
--  This procedure is dependent on the Contracts group API OKC_TERMS_QA_GRP and
--  calls procedure qa_doc. It also subtypes the qa_result_tbl_type to store
--  returned error messages.
--Modifies:
--  po_online_report_text_gt
--Locks:
--  None.
--Function:
-- This procedure is used to validate contract articles and deliverables and is
-- called during the submission check. The contracts APi qa_doc is called in
-- normal or amend mode based on the status of the document. The resulting errors/
-- warnings if any are stored in the global temp table.
--Parameters:
--  Otherwise, include the IN:, IN OUT:, and/or OUT: sections as needed.
--IN:
--p_document_id
--  po_header_id
--p_document_type
--  po document type PO or PA
--p_document_subtype
--  po_document subtype 'STANDARD', 'CONTRACT' or 'BLANKET'
--p_online_report_id
--  unique error report id
--p_user_id
--  user id
--p_login_id
--  login id
--IN OUT:
--p_sequence
--  Description of why/how the parameter is used.
--OUT:
--x_return_status
--  return status of the procedure
--Notes:
--Testing:
--  test the qa doc is called in the correct mode and that the returned errors
-- are correctly populated in the error table.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE check_terms(
   p_document_id          IN NUMBER,
   p_document_type        IN VARCHAR2,
   p_document_subtype     IN VARCHAR2,
   p_online_report_id     IN NUMBER,
   p_user_id              IN NUMBER,
   p_login_id             IN NUMBER,
   p_sequence             IN OUT NOCOPY NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2) IS

-- declare cursor to fetch the revision, authorization status and approved flag
CURSOR c_po_status (p_document_id NUMBER) IS
  SELECT revision_num
         ,start_date
   ,end_date
  FROM   po_headers_gt
  WHERE  po_header_id = p_document_id;

-- contracts dependency
SUBTYPE qa_result_tbl_type IS OKC_TERMS_QA_GRP.qa_result_tbl_type;
l_qa_result_tbl qa_result_tbl_type;
l_qa_mode VARCHAR2(30);
l_contracts_document_type VARCHAR2(150);
SUBTYPE Event_tbl_type IS OKC_TERMS_QA_GRP.busdocdates_tbl_type;
l_event_tbl Event_tbl_type;


l_revision_num po_headers.revision_num%TYPE;
l_authorization_status po_headers.authorization_status%TYPE;
l_approved_flag po_headers.approved_flag%TYPE;
l_po_start_date po_headers.start_date%TYPE;
l_po_end_date po_headers.end_date%TYPE;

l_api_name CONSTANT VARCHAR2(30) := 'Check Terms';
l_progress VARCHAR2(3);
l_row_index PLS_INTEGER;

l_return_status VARCHAR2(1);
l_qa_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- contracts document type
  l_contracts_document_type := p_document_type||'_'||p_document_subtype;

  -- fetch the document status indicators
  OPEN c_po_status(p_document_id);
  FETCH c_po_status INTO l_revision_num, l_po_start_date, l_po_end_date;
  CLOSE c_po_status;

  -- decode status indicators to decide qa mode
  -- Migrate PO:
  -- Now that conterms can be added at any revision of the PO
  -- We need to check if the current rev is the first one with
  -- contracts and if so do the normal qa
  IF (l_revision_num > 0) AND
     (PO_CONTERMS_UTL_GRP.get_archive_conterms_flag (p_po_header_id => p_document_id) = 'Y')
  THEN
    l_qa_mode := 'AMEND';
  ELSE
    l_qa_mode := 'NORMAL';
  END IF;

  l_event_tbl(1).event_code := 'PO_START_DATE';
  l_event_tbl(1).event_date := l_po_start_date;
  l_event_tbl(2).event_code := 'PO_END_DATE';
  l_event_tbl(2).event_date := l_po_end_date;

  l_progress := '001';

  -- call the contracts QA
  OKC_TERMS_QA_GRP.qa_Doc(
    p_api_version      => 1.0,
    p_init_msg_list    => FND_API.G_FALSE,
    x_return_status    => l_return_status,
    x_msg_data       => l_msg_data,
    x_msg_count      => l_msg_count,
    p_qa_mode        => l_qa_mode,
    p_doc_type       => l_contracts_document_type,
    p_doc_id           => p_document_id,
    p_bus_doc_date_events_tbl => l_event_tbl,
    x_qa_result_tbl    => l_qa_result_tbl,
    x_qa_return_status => l_qa_return_status
  );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- if successful update error table with the messages if qa returned errors
  IF (l_qa_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    l_progress := '002';
    l_row_index := l_qa_result_tbl.FIRST;
    LOOP
    EXIT WHEN l_row_index IS NULL;
      INSERT INTO po_online_report_text_gt
        (online_report_id
        ,last_updated_by
        ,last_update_date
        ,created_by
        ,creation_date
        ,line_num
        ,shipment_num
        ,distribution_num
        ,sequence
        ,text_line
        ,message_name
        ,message_type
        )
      VALUES
        (p_online_report_id
        ,p_login_id
        ,sysdate
        ,p_user_id
        ,sysdate
        ,0 ,0 ,0
        ,p_sequence+1
        ,l_qa_result_tbl(l_row_index).problem_details
        ,l_qa_result_tbl(l_row_index).message_name
        ,l_qa_result_tbl(l_row_index).error_severity
        );
      l_row_index := l_qa_result_tbl.NEXT(l_row_index);
      --increment the sequence by the error count
      p_sequence := p_sequence + 1;
    END LOOP;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF ( g_debug_unexp ) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string( FND_LOG.level_unexpected,
                            G_PKG_NAME||l_api_name|| '.others_exception',
                            'EXCEPTION: Location is '|| l_progress || ' SQL CODE is '||sqlcode);
            END IF;
        END IF;

END check_terms;
/* CONTERMS FPJ END*/


--<Bug 18900534> : This procedure calls out to FV GDF validation API
PROCEDURE po_validate_fv_gdf
 ( p_document_id          IN NUMBER,
   p_release_id           IN NUMBER, --Bug 20086593
   p_draft_id             IN NUMBER,
   p_online_report_id     IN NUMBER,
   p_user_id              IN NUMBER,
   p_login_id             IN NUMBER,
   x_sequence             IN OUT NOCOPY NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2
 )
IS

  d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.po_validate_fv_gdf';
  d_progress NUMBER;
  l_org_id   NUMBER;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_release_id', p_release_id); --Bug 20086593
    PO_LOG.proc_begin(d_module, 'p_draft_id', p_draft_id);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'x_sequence', x_sequence);
  END IF;

  d_progress := 10;

  --Bug 20086593
  IF (p_release_id IS NULL) THEN
  Select org_id Into l_org_id
  From po_headers_gt
  Where po_header_id = p_document_id;
  ELSE
    SELECT org_id INTO l_org_id
    FROM PO_RELEASES_GT
    WHERE po_release_id = p_release_id;
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_org_id', l_org_id);
  END IF;

  IF fv_install.enabled(l_org_id) THEN
    d_progress := 20;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'FV Enabled, Calling out to FV api');
    END IF;
    FV_GTAS_UTILITY_PKG.po_bwc_validate_fv_gdf
    (  p_document_id => p_document_id,
       p_release_id => p_release_id, --Bug 20086593
       p_draft_id    => p_draft_id,
       p_online_report_id => p_online_report_id,
       p_user_id => p_user_id,
       p_login_id => p_login_id,
       p_sequence => x_sequence,
       x_return_status => x_return_status
    );
    x_sequence := x_sequence + SQL%ROWCOUNT;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_sequence', x_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_sequence', x_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END po_validate_fv_gdf;


/**
* Public Procedure: PO_SUBMISSION_CHECK
* Requires:
*   IN PARAMETERS:
*     p_api_version:       Version number of API that caller expects.
*     p_action_requested:  The action to perform
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
--  The following is supported for all actions:
--    HEADER
--  The following are also supported for UNRESERVE checks (PO/RELEASE):
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--  The following are also supported for FINAL_CLOSE checks (PO/RELEASE):
--    LINE
--    SHIPMENT
--p_document_level_id
--  Id of the doc level type on which to perform the check.
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
*     p_req_chg_initiator: Caller of the change request if its a change request
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
*                      submission check
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
*  NOTE: This package does no validation of INPUT parameters. That is taken
*        care of in Group package PO_DOCUMENT_CHECKS_GRP
*/
PROCEDURE po_submission_check(
   p_api_version                    IN             NUMBER
,  p_action_requested               IN             VARCHAR2
,  p_document_type                  IN             VARCHAR2
,  p_document_subtype               IN             VARCHAR2
-- <ENCUMBRANCE FPJ> Replaced p_document_id with doc_level, doc_level_id
,  p_document_level                 IN             VARCHAR2
,  p_document_level_id              IN             NUMBER
-- <PO_CHANGE_API FPJ> Renamed the type to PO_CHANGES_REC_TYPE:
,  p_requested_changes              IN             PO_CHANGES_REC_TYPE
,  p_check_asl                      IN             BOOLEAN  -- bug 2757450
,  p_req_chg_initiator              IN             VARCHAR2 -- bug 4957243
,  p_origin_doc_id                  IN             NUMBER := NULL --Bug#5462677
,  x_return_status                  OUT NOCOPY     VARCHAR2
,  x_sub_check_status               OUT NOCOPY     VARCHAR2
,  x_has_warnings                   OUT NOCOPY     VARCHAR2  -- bug3574165
,  x_msg_data                       OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
,  x_doc_check_error_record         OUT NOCOPY     doc_check_Return_Type
)
IS

l_api_name              CONSTANT varchar2(30) := 'PO_SUBMISSION_CHECK';
l_api_version           CONSTANT NUMBER       := 2.0;
l_log_head     CONSTANT VARCHAR2(100) := g_log_head||l_api_name;
l_progress              VARCHAR2(8); --changed from 3 to 8 for bug 13481176

l_document_id  NUMBER;
l_id_tbl    po_tbl_number;

l_num_messages NUMBER := 0;  -- bug3574165: Changed l_num_errors to l_num_messages
l_num_warnings NUMBER := 0;  -- bug3574165

l_online_report_id  NUMBER;
l_user_id    po_lines.last_updated_by%TYPE := -1;
l_login_id   po_lines.last_update_login%TYPE := -1;
p_sequence   po_online_report_text.sequence%TYPE :=0;

l_return_status varchar2(1);

l_conterms_exist_flag VARCHAR2(1); -- <CONTERMS FPJ>
l_po_header_id PO_HEADERS_ALL.po_header_id%TYPE; --<JFMIP Vendor Registration FPJ>

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action_requested',p_action_requested);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type',p_document_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_subtype',p_document_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_level',p_document_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_level_id',p_document_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_check_asl',p_check_asl);
END IF;

--Standard Start og API savepoint
SAVEPOINT PO_SUBMISSION_CHECK_SP;

l_progress := '000';
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

l_progress := '001';

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Populating global temp tables');
   END IF;
END IF;


PO_CORE_S.get_document_ids(
   p_doc_type => p_document_type
,  p_doc_level => p_document_level
,  p_doc_level_id_tbl => po_tbl_number( p_document_level_id )
,  x_doc_id_tbl => l_id_tbl
);

l_document_id := l_id_tbl(1);

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_document_id',l_document_id);
END IF;


-- bug3413891
-- GT table cleanup has moved to populate_global_temp_tables procedure

--Populate global temp tables with data from main PO tables for
--given PO_HEADER_ID

populate_global_temp_tables(
   x_return_status => l_return_status
,  p_doc_type => p_document_type
,  p_doc_level => p_document_level
,  p_doc_level_id => p_document_level_id
);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

l_progress := '002';
    --if the p_requested_changes is NOT NULL then update the global temp
    --tables with these changes
    IF p_requested_changes IS NOT NULL THEN

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'update requested, calling updating global tables');
   END IF;
END IF;

        update_global_temp_tables(p_document_type,
                                p_document_subtype,
                                l_document_id,
                                p_requested_changes,
                                l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Getting online_report_id');
   END IF;
END IF;

l_progress := '003';
    --Get the unique id to be used for this document
    SELECT PO_ONLINE_REPORT_TEXT_S.nextval
    INTO   l_online_report_id
    FROM   sys.dual;

l_progress := '004';
    --Get User ID and Login ID
    l_user_id := FND_GLOBAL.USER_ID;
    IF (FND_GLOBAL.CONC_LOGIN_ID >= 0) THEN
        l_login_id := FND_GLOBAL.CONC_LOGIN_ID;
    ELSE
        l_login_id := FND_GLOBAL.LOGIN_ID;
    END IF;

IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || l_api_name||'.'
          || l_progress,'user_id '|| to_char(l_user_id) || 'Login_id ' || to_char(l_login_id));
     END IF;
END IF;

    -- <Bug 7655436 Start>
    -- Call the custom code hook
    PO_CUSTOM_SUBMISSION_CHECK_PVT.do_pre_submission_check(
      p_api_version         => 1.0,
      P_document_id         => l_document_id,
      p_action_requested    => p_action_requested,
      p_document_type       => p_document_type,
      p_document_subtype    => p_document_subtype,
      p_document_level      => p_document_level,
      p_document_level_id   => p_document_level_id,
      p_requested_changes   => p_requested_changes,
      p_check_asl           => p_check_asl,
      p_req_chg_initiator   => p_req_chg_initiator,
      p_origin_doc_id       => p_origin_doc_id,
      p_online_report_id    => l_online_report_id,
      p_user_id             => l_user_id,
      p_login_id            => l_login_id,
      p_sequence            => p_sequence,
      x_return_status       => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- <Bug 7655436 End>

    --<Bug 18900534> Starts
    IF p_document_type = 'PO'
    THEN
      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
           || l_progress,'FV GDF Check');
        END IF;
      END IF;
           --Submission check to validate FV GDF
           po_validate_fv_gdf
           (  p_document_id      => l_document_id
             ,p_release_id       => NULL --Bug 20086593
             ,p_draft_id         => NULL
             ,p_online_report_id => l_online_report_id
             ,p_user_id          => l_user_id
             ,p_login_id         => l_login_id
             ,x_sequence         => p_sequence
             ,x_return_status    => l_return_status
           );

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
    --Bug : 20086593
    ELSIF p_document_type = 'RELEASE' THEN
      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
           || l_progress,'FV GDF Check Release');
        END IF;
      END IF;
           po_validate_fv_gdf
           (  p_document_id      => NULL
             ,p_release_id       => l_document_id
             ,p_draft_id         => NULL
             ,p_online_report_id => l_online_report_id
             ,p_user_id          => l_user_id
             ,p_login_id         => l_login_id
             ,x_sequence         => p_sequence
             ,x_return_status    => l_return_status
           );
    END IF;
    --<Bug 18900534> Ends


--Added for Bug 9716385
 IF(p_action_requested = g_action_DOC_SUBMISSION_CHECK) THEN

  -- Added for Bug 10300018
               PO_UOM_CHECK(
 	                  P_document_id         => l_document_id,
 		          p_document_type       => p_document_type,
 			  p_online_report_id    => l_online_report_id,
 			  p_user_id             => l_user_id,
 			  p_login_id            => l_login_id,
 			  p_sequence            => p_sequence,
 			  x_return_status       => l_return_status,
 			  x_msg_data          => x_msg_data);
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


---<Bug 13019003>
---Used the single procedure in place of four procedures
		l_progress := '00420';
	     PO_VALIDATE_ACCOUNTS(
		      P_document_id => l_document_id,
 			  p_document_type       => p_document_type,
 			  p_online_report_id    => l_online_report_id,
 			  p_user_id             => l_user_id,
 			  p_login_id            => l_login_id,
 			  p_sequence            => p_sequence,
 			  x_return_status       => l_return_status,
 			  x_msg_data          => x_msg_data);

	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


        -- Bug 15843328
        --Added this submission check for accrue on receipt flag.
      	l_progress := '00430';

      check_accrue_on_receipt(
		          P_document_id         => l_document_id,
 			  p_document_type       => p_document_type,
 			  p_online_report_id    => l_online_report_id,
 			  p_user_id             => l_user_id,
 			  p_login_id            => l_login_id,
 			  p_sequence            => p_sequence,
 			  x_return_status       => l_return_status,
 			  x_msg_data            => x_msg_data);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



	 END IF;

l_progress := '005';
    IF p_document_type = 'REQUISITION' THEN

l_progress := '006';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REQUISITION checks');
   END IF;
END IF;

        --check REQUISITIONS
        check_requisitions(l_document_id,
                           l_online_report_id,
                           l_user_id,
                           l_login_id,
                           p_sequence,
                           l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

l_progress := '007';
        --CBC header check for REQ
        do_cbc_related_validations(p_document_type ,
                       p_document_subtype,
                       l_document_id ,
                       l_online_report_id ,
                       l_user_id ,
                       l_login_id ,
                       p_sequence,
                       l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	-- Added for bug 12951645

        IF g_debug_stmt THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
               || l_progress,'Close Wip JOb checks');
           END IF;
        END IF;
           --Submission check to check whther document
	   --associated WIP Job is closed or not?
           check_close_wip_job(l_document_id,
                               p_document_type,
			       l_online_report_id,
                               l_user_id,
                               l_login_id,
		               p_sequence,
                               l_return_status);

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
--Added for bug 12951645

    ELSIF p_document_type = 'RELEASE' THEN

       IF p_action_requested = g_action_UNRESERVE THEN

l_progress := '008';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'RELEASE: Calling UNRESERVE checks');
   END IF;
END IF;

      check_unreserve(
         p_online_report_id => l_online_report_id
      ,  p_document_type    => p_document_type       -- Bug#5462677
      ,  p_document_subtype => p_document_subtype -- Bug#5462677
      ,  p_document_level   => p_document_level     -- Bug#5462677
      ,  p_doc_level_id     => p_document_level_id         --Bug#5462677
      ,  p_user_id          => l_user_id
      ,  p_login_id         => l_login_id
      ,  p_sequence         => p_sequence);

       -- <Doc Manager Rewrite 11.5.11 Start>
       ELSIF (p_action_requested = g_action_FINAL_CLOSE_CHECK) THEN

         l_progress := '008';
         IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
            || l_progress,'RELEASE: Calling FINAL CLOSE checks');
            END IF;
         END IF;

            check_final_close(
               p_document_type     =>p_document_type
            ,  p_document_subtype  =>p_document_subtype
            ,  p_document_level    =>p_document_level
            ,  p_document_id       =>l_document_id
            ,  p_online_report_id  =>l_online_report_id
            ,  p_user_id           =>l_user_id
            ,  p_login_id          =>l_login_id
            ,  p_origin_doc_id     =>p_origin_doc_id --Bug#5462677
            ,  p_doc_level_id       =>p_document_level_id
            ,  p_sequence          =>p_sequence
            ,  x_return_status     =>l_return_status);

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

       -- <Doc Manager Rewrite 11.5.11 End>

       ELSE --its 'DOC_SUBMISSION_CHECK'

l_progress := '009';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'RELEASE checks');
   END IF;
END IF;
           --check RELEASES
           check_releases(l_document_id,
                       l_online_report_id,
                       l_user_id,
                       l_login_id, p_sequence,
                       l_return_status);

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

--Added for bug 12951645

 IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
        || l_progress,'Close Wip JOb checks');
    END IF;
 END IF;
           --Submission check to check whther document
	   --associated WIP Job is closed or not?
           check_close_wip_job(l_document_id,
                               p_document_type,
			       l_online_report_id,
                               l_user_id,
                               l_login_id,
		               p_sequence,
                               l_return_status);

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
--Added for bug 12951645

l_progress := '010';

           -- bug4957243
           --Do requisition price within tolerance check for PO, RELEASES
           -- This is not done for requester change orders
            IF p_req_chg_initiator is null or
               p_req_chg_initiator <> 'REQUESTER'
            THEN

              check_po_rel_reqprice(p_document_type,
                       l_document_id,
                       l_online_report_id,
                       l_user_id,
                       l_login_id, p_sequence,
                       l_return_status);
            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

l_progress := '011';
            --CBC header check for Releases
            do_cbc_related_validations(p_document_type ,
                       p_document_subtype,
                       l_document_id ,
                       l_online_report_id ,
                       l_user_id ,
                       l_login_id ,
                       p_sequence,
                       l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

       END IF; --check action requested

    ELSIF p_document_type = 'PO' THEN
       IF p_action_requested = g_action_UNRESERVE THEN

l_progress := '012';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO: Calling UNRESERVE checks ');
   END IF;
END IF;

         check_unreserve(
            p_online_report_id  => l_online_report_id
         ,  p_document_type     => p_document_type      -- Bug#5462677
         ,  p_document_subtype  => p_document_subtype   -- Bug#5462677
         ,  p_document_level    => p_document_level     -- Bug#5462677
         ,  p_doc_level_id      => p_document_level_id  -- Bug#5462677
         ,  p_user_id           => l_user_id
         ,  p_login_id          => l_login_id
         ,  p_sequence          => p_sequence );

       -- <Doc Manager Rewrite 11.5.11 Start>
       ELSIF (p_action_requested = g_action_FINAL_CLOSE_CHECK) THEN

         l_progress := '012';
         IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
            || l_progress,'PO: Calling FINAL CLOSE checks');
            END IF;
         END IF;

            check_final_close(
               p_document_type     =>p_document_type
            ,  p_document_subtype  =>p_document_subtype
            ,  p_document_level    =>p_document_level
            ,  p_document_id       =>l_document_id
            ,  p_online_report_id  =>l_online_report_id
            ,  p_user_id           =>l_user_id
            ,  p_login_id          =>l_login_id
            ,  p_origin_doc_id     =>p_origin_doc_id --Bug#5462677
            ,  p_doc_level_id      =>p_document_level_id
            ,  p_sequence          =>p_sequence
            ,  x_return_status     =>l_return_status);

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

       -- <Doc Manager Rewrite 11.5.11 End>

       ELSE --its 'DOC_SUBMISSION_CHECK'

l_progress := '013';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO checks');
   END IF;
END IF;
            --First do all checks at header level
            check_po_pa_header(l_document_id,
                       l_online_report_id,
                       l_user_id,
                       l_login_id, p_sequence,
                       l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
--Added for bug 12951645
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
       || l_progress,'Close Wip JOb check');
   END IF;
END IF;
            --Submission check to check whther document
	    --associated WIP Job is closed or not?
           check_close_wip_job(l_document_id,
                               p_document_type,
			       l_online_report_id,
                               l_user_id,
                               l_login_id,
		               p_sequence,
                               l_return_status);

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
--Added for bug 12951645

l_progress := '014';
            --Do all checks common to Standard and PLanned POs
            check_po(l_document_id,
                       l_online_report_id,
                       l_user_id,
                       l_login_id,
--                       p_check_asl,                                -- <2757450>
                       p_sequence,
                       l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

l_progress := '015';
            --CBC header check for POs
            do_cbc_related_validations(p_document_type ,
                       p_document_subtype,
                       l_document_id ,
                       l_online_report_id ,
                       l_user_id ,
                       l_login_id ,
                       p_sequence,
                       l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

l_progress := '016';

            -- bug4957243
            --Do requisition price within tolerance check for PO, RELEASES
            -- This is not done for requester change orders
            IF p_req_chg_initiator is null or
               p_req_chg_initiator <> 'REQUESTER'
            THEN

              check_po_rel_reqprice(p_document_type,
                       l_document_id,
                       l_online_report_id,
                       l_user_id,
                       l_login_id, p_sequence,
                       l_return_status);
            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            --Do some additional checks if its PLANNED PO
            IF p_document_subtype = 'PLANNED' THEN
                --check planned PO
l_progress := '017';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO: PLANNED checks');
   END IF;
END IF;
                --Call checks common to Planned PO and Blanket PA
                check_planned_po_blanket_pa(l_document_id,
                             l_online_report_id,
                             l_user_id,
                             l_login_id, p_sequence,
                             l_return_status);

                 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

            ELSIF p_document_subtype = 'STANDARD' THEN

l_progress := '018';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO: STANDARD checks');
   END IF;
END IF;
                --Call additional checks for Standard PO
                check_standard_po(l_document_id,
                             l_online_report_id,
                             l_user_id,
                             l_login_id,
                             p_sequence,
                             l_return_status);

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

            END IF; --check doc_subtype


       END IF; --check action requested
    ELSIF  p_document_type = 'PA' THEN

      -- <Doc Manager Rewrite 11.5.11 Start>
      IF (p_action_requested = g_action_FINAL_CLOSE_CHECK) THEN

        l_progress := '019';
        IF g_debug_stmt THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PA: Calling FINAL CLOSE checks');
          END IF;
        END IF;

        check_final_close(
           p_document_type     =>p_document_type
        ,  p_document_subtype  =>p_document_subtype
        ,  p_document_level    =>p_document_level
        ,  p_document_id       =>l_document_id
        ,  p_online_report_id  =>l_online_report_id
        ,  p_user_id           =>l_user_id
        ,  p_login_id          =>l_login_id
        ,  p_origin_doc_id     =>p_origin_doc_id --Bug#5462677
        ,  p_doc_level_id      =>p_document_level_id
        ,  p_sequence          =>p_sequence
        ,  x_return_status     =>l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      ELSE
      -- <Doc Manager Rewrite 11.5.11 End>

        -- It's  'DOC_SUBMISSION_CHECK'
        --check PAs
        l_progress := '019';
        IF g_debug_stmt THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
            || l_progress,'PA checks');
          END IF;
        END IF;

        --First do all checks at header level
        check_po_pa_header(l_document_id,
                       l_online_report_id,
                       l_user_id,
                       l_login_id,
                       p_sequence,
                       l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Added for bug 12951645

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
      || l_progress,'Close Wip JOb checks');
   END IF;
END IF;
            --Submission check to check whther document
	    --associated WIP Job is closed or not?
           check_close_wip_job(l_document_id,
                               p_document_type,
			       l_online_report_id,
                               l_user_id,
                               l_login_id,
		               p_sequence,
                               l_return_status);

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
--Added for bug 12951645

        IF p_document_subtype = 'BLANKET' THEN

          l_progress := '020';
          IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
              || l_progress,'PA: BLANKET checks');
            END IF;
          END IF;

          --check blanket agreement
          check_blanket_agreement(l_document_id,
                                  l_online_report_id,
                                  l_user_id,
                                  l_login_id,
                                  p_check_asl,                   -- <2757450>
                                  p_sequence,
                                  l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          l_progress := '021';
          --Call checks common to Planned PO and Blanket PA
          check_planned_po_blanket_pa(l_document_id,
                           l_online_report_id,
                           l_user_id,
                           l_login_id,
                           p_sequence,
                           l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        ELSIF p_document_subtype = 'CONTRACT' THEN

          l_progress := '022';
          IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
              || l_progress,'PA: CONTRACT checks');
            END IF;
          END IF;

          --check contract agreement
          check_contract_agreement(l_document_id,
                                   l_online_report_id,
                                   l_user_id,
                                   l_login_id,
                                   p_sequence,
                                   l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;  --PA p_document_subtype
      END IF; -- PA p_action_requested

    END IF; --document_type lookup

l_progress := '023';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Done with all checks');
   END IF;
END IF;

/* CONTERMS FPJ START*/

  -- <Doc Manager Rewrite 11.5.11> : Only check okc terms for 'DOC_SUBMISSION_CHECK'

IF (p_document_type IN ('PO', 'PA')) AND
   (p_document_subtype IN ('STANDARD', 'BLANKET', 'CONTRACT'))
   AND (p_action_requested = g_action_DOC_SUBMISSION_CHECK) THEN

    -- SQL What: conterms exist flag
    -- SQL why : need to check before calling contracts qa
    -- SQL join: po_header_id
    SELECT conterms_exist_flag
    INTO   l_conterms_exist_flag
    FROM   po_headers_gt
    WHERE  po_header_id = l_document_id;

    IF (NVL(l_conterms_exist_flag, 'N')='Y') THEN
      check_terms(
        p_document_id          => l_document_id,
        p_document_type        => p_document_type,
        p_document_subtype     => p_document_subtype,
        p_online_report_id     => l_online_report_id,
        p_user_id              => l_user_id,
        p_login_id             => l_login_id,
        p_sequence             => p_sequence,
        x_return_status        => l_return_status);

      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF; --conterms exist
END IF; -- document type is PO or PA

    l_progress := '024';
    IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,g_log_head || '.'||l_api_name||'.'|| l_progress
                    ,'Done with contracts qa');
      END IF;
    END IF;
    /* CONTERMS FPJ END */

  -- <Doc Manager Rewrite 11.5.11> : Do vendor registration check only
  -- for DOC_SUBMISSION_CHECK and UNRESERVE

  IF (p_action_requested IN (g_action_DOC_SUBMISSION_CHECK, g_action_UNRESERVE))
  THEN

    --<JFMIP Vendor Registration FPJ Start>
    -- This part of the code is called when the action requested is
    -- DOC_SUBMISSION_CHECK, as well as UNRESERVE. This is because if
    -- vendor site does not have a valid registration, reserve/unreserve
    -- actions should be prevented.
    IF (p_document_type = 'RELEASE') THEN
        -- SQL What: Retrieve the blanket header id based on the release id
        -- SQL Why:  This header id is used in check_vendor_site_ccr_regis to
        --           retrieve the vendor and vendor site id
       BEGIN
         SELECT  po_header_id
         INTO    l_po_header_id
         FROM    PO_RELEASES_ALL
         WHERE   po_release_id = l_document_id;
      EXCEPTION
         WHEN OTHERS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
    ELSE
       l_po_header_id := l_document_id;
    END IF;

    IF p_document_type IN ('RELEASE', 'PO', 'PA') THEN
     check_vendor_site_ccr_regis(
                                  p_document_id      => l_po_header_id,
          p_online_report_id => l_online_report_id,
          p_user_id          => l_user_id,
          p_login_id         => l_login_id,
          p_sequence         => p_sequence,
          x_return_status    => l_return_status);

        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    l_progress := '025';
    IF g_debug_stmt THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    ,g_log_head || '.'||l_api_name||'.'|| l_progress,
                    'Done with vendor site registration check');
       END IF;
    END IF;
    --<JFMIP Vendor Registration FPJ End>

  END IF; -- p_action_requested NOT IN ('DOC_SUBMISSION_CHECK', 'UNRESREVE')

    -- <Bug 7655436 Start>
    -- Call the custom code hook
    PO_CUSTOM_SUBMISSION_CHECK_PVT.do_post_submission_check(
      p_api_version         => 1.0,
      P_document_id         => l_document_id,
      p_action_requested    => p_action_requested,
      p_document_type       => p_document_type,
      p_document_subtype    => p_document_subtype,
      p_document_level      => p_document_level,
      p_document_level_id   => p_document_level_id,
      p_requested_changes   => p_requested_changes,
      p_check_asl           => p_check_asl,
      p_req_chg_initiator   => p_req_chg_initiator,
      p_origin_doc_id       => p_origin_doc_id,
      p_online_report_id    => l_online_report_id,
      p_user_id             => l_user_id,
      p_login_id            => l_login_id,
      p_sequence            => p_sequence,
      x_return_status       => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- <Bug 7655436 End>


    --Done with CHECKS, now prepare OUT parameters to pass back

    -- bug3574165
    -- Count number of warning messages as well.

    SELECT count(text_line),
           COUNT(DECODE(message_type, 'W', 'W', NULL))
    INTO   l_num_messages,
           l_num_warnings
    FROM   po_online_report_text_gt
    WHERE  online_report_id = l_online_report_id;


    l_progress := '026';
    IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Number of messagess reported ' || l_num_messages);
      END IF;
    END IF;

    x_online_report_id := l_online_report_id;

    IF l_num_messages > 0 THEN

        -- bug3574165
        -- 1) Return Error only if there are messages that are not warnings
        -- 2) Set x_has_warnings flag to TRUE if there are warnings reported

        IF (l_num_messages > l_num_warnings) THEN
          x_sub_check_status := FND_API.G_RET_STS_ERROR;
        ELSE
          x_sub_check_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

        IF ( l_num_warnings > 0 ) THEN
          x_has_warnings := FND_API.G_TRUE;
        END IF;

        --Bulk update online_report_text table with errors
        INSERT INTO po_online_report_text(online_report_id,
            last_update_login,
            last_updated_by,
            last_update_date,
            created_by,
            creation_date,
            line_num,
            shipment_num,
            distribution_num,
            sequence,
            text_line,
                        message_type) --<CONTERMS FPJ>
            SELECT online_report_id,
            last_update_login,
            last_updated_by,
            last_update_date,
            created_by,
            creation_date,
            line_num,
            shipment_num,
            distribution_num,
            sequence,
            text_line,
                        message_type --<CONTERMS FPJ>
            FROM po_online_report_text_gt
            WHERE online_report_id = x_online_report_id;

select count(*) into l_num_messages from po_online_report_text_gt where online_report_id = x_online_report_id;

l_progress := '027';

        -- SQL What: Gets the relevent messages from global temp table
        -- SQL Why: Need to collect all errors in x_doc_check_error_record
        SELECT  online_report_id, sequence, text_line,
            line_num, shipment_num, distribution_num, message_name, message_type
        BULK COLLECT INTO x_doc_check_error_record.online_report_id,
                          x_doc_check_error_record.sequence_num,
                          x_doc_check_error_record.text_line,
                          x_doc_check_error_record.line_num,
                          x_doc_check_error_record.shipment_num,
                          x_doc_check_error_record.distribution_num,
                          x_doc_check_error_record.message_name,
                          x_doc_check_error_record.message_type --<CONTERMS FPJ>
        FROM  po_online_report_text_gt
        WHERE online_report_id = x_online_report_id;

    ELSE
        x_sub_check_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

l_progress := '027';
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- LCM ER start. If all the submission checks have been passed successfully then update the lcm_flag of po_line_locations_all and po_distributions_all.
        IF p_document_type in ('PO','RELEASE') THEN

        	FOR ship_rec in (select line_location_id from po_line_locations_gt)

        	LOOP
        		set_lcm_flag(ship_rec.line_location_id,'AFTER',l_return_status);
        	END LOOP;

        	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    --LCM ER end

    -- bug3413891
    -- We are now deleting data from GT tables at the beginning of submission
    -- check. Deletion at the end is no longer needed


l_progress := '029';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Returning from PVT package');
   END IF;
END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO PO_SUBMISSION_CHECK_SP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_sub_check_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                        p_encoded => 'F');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PO_SUBMISSION_CHECK_SP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_sub_check_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                    p_encoded => 'F');

    WHEN OTHERS THEN
        ROLLBACK TO PO_SUBMISSION_CHECK_SP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_sub_check_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END PO_SUBMISSION_CHECK;


PROCEDURE post_submission_check                                   -- <2757450>
(
    p_api_version             IN            NUMBER
,   p_document_type           IN            VARCHAR2
,   p_document_subtype        IN            VARCHAR2
,   p_document_id             IN            NUMBER
,   x_return_status              OUT NOCOPY VARCHAR2
,   x_sub_check_status           OUT NOCOPY VARCHAR2
,   x_online_report_id           OUT NOCOPY NUMBER
)
IS
    l_api_name                CONSTANT varchar2(30) := 'POST_SUBMISSION_CHECK';
    l_api_version             CONSTANT NUMBER       := 1.0;
    l_progress                VARCHAR2(3);

    l_num_errors              NUMBER := 0;
    l_online_report_id        NUMBER;
    l_user_id                 PO_LINES.last_updated_by%TYPE := -1;
    l_login_id                PO_LINES.last_update_login%TYPE := -1;
    p_sequence                PO_ONLINE_REPORT_TEXT.sequence%TYPE :=0;

    l_return_status           VARCHAR2(1);

BEGIN

SAVEPOINT POST_SUBMISSION_CHECK_SP;

l_progress := '000';

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

l_progress := '001';

IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string( FND_LOG.LEVEL_STATEMENT,
                    g_log_head || '.'||l_api_name||'.' || l_progress,
                    'Populating global temp tables');
    END IF;
END IF;

   --Populate global temp tables with data from main PO tables for
   --given PO_HEADER_ID
   populate_global_temp_tables(
      x_return_status => l_return_status
   ,  p_doc_type => p_document_type
   ,  p_doc_level => g_document_level_HEADER
   ,  p_doc_level_id => p_document_id
   );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Getting online_report_id');
   END IF;
END IF;

l_progress := '003';

    --Get the unique id to be used for this document
    SELECT PO_ONLINE_REPORT_TEXT_S.nextval
    INTO   l_online_report_id
    FROM   sys.dual;

l_progress := '004';

    --Get User ID and Login ID
    l_user_id := FND_GLOBAL.USER_ID;

    IF ( FND_GLOBAL.CONC_LOGIN_ID >= 0 )
    THEN
        l_login_id := FND_GLOBAL.CONC_LOGIN_ID;
    ELSE
        l_login_id := FND_GLOBAL.LOGIN_ID;
    END IF;

IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string( FND_LOG.LEVEL_STATEMENT,
                     g_log_head || l_api_name||'.'|| l_progress,
                     'user_id '|| to_char(l_user_id) ||
                     'Login_id ' || to_char(l_login_id));
     END IF;
END IF;

    --============================ CHECKS =====================================
    --Bug 4943365 We should not do any ASL checking for Blanket agreements
    --Removed the call to check_asl

l_progress := '007';

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Done with all checks');
   END IF;
END IF;

    --Done with CHECKS, now prepare OUT parameters to pass back
    SELECT count(text_line)
    INTO   l_num_errors
    FROM   po_online_report_text_gt
    WHERE  online_report_id = l_online_report_id;

l_progress := '008';

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string( FND_LOG.LEVEL_STATEMENT,
                   g_log_head || '.'||l_api_name||'.'|| l_progress,
                   'Number of errors reported ' || l_num_errors);
   END IF;
END IF;

    x_online_report_id := l_online_report_id;

    IF l_num_errors > 0 THEN

        x_sub_check_status := FND_API.G_RET_STS_ERROR;

        --Bulk update online_report_text table with errors
        INSERT INTO po_online_report_text(
                    online_report_id,
            last_update_login,
            last_updated_by,
            last_update_date,
            created_by,
              creation_date,
            line_num,
            shipment_num,
            distribution_num,
            sequence,
            text_line)
             SELECT online_report_id,
            last_update_login,
            last_updated_by,
            last_update_date,
            created_by,
              creation_date,
            line_num,
            shipment_num,
            distribution_num,
            sequence,
            text_line
               FROM po_online_report_text_gt
              WHERE online_report_id = x_online_report_id;

l_progress := '009';

    ELSE
        x_sub_check_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

l_progress := '010';

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- bug3413891
-- Deletion of GT tables has been moved to populate_global_temp_tables procedure

l_progress := '011';

IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string( FND_LOG.LEVEL_STATEMENT,
                    g_log_head || '.'||l_api_name||'.'|| l_progress,
                    'Returning from PVT package');
    END IF;
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO POST_SUBMISSION_CHECK_SP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_sub_check_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO POST_SUBMISSION_CHECK_SP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_sub_check_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
        ROLLBACK TO POST_SUBMISSION_CHECK_SP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_sub_check_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF ( g_debug_unexp ) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string( FND_LOG.level_unexpected,
                            g_log_head || l_api_name || '.others_exception',
                            'EXCEPTION: Location is ' || l_progress || ' SQL CODE is '||sqlcode);
            END IF;
        END IF;

END post_submission_check;

 --Bug 4943365 Removed the check_asl procedure because blankets
 --should not do the asl checks.
 --PROCEDURE check_asl

/**
* Private Procedure: CHECK_REQUISITIONS
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Updates the PO_REQUISITION_LINES table with RATE information.
*           Inserts error msgs in online_report_text_gt table, uses global_temp
*           tables for processing
* Effects:  This procedure runs the document submission checks for
*           REQUISITIONS
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*/
PROCEDURE check_requisitions(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_textline  po_online_report_text.text_line%TYPE := NULL;
l_api_name  CONSTANT varchar2(40) := 'CHECK_REQUISITIONS';
l_progress VARCHAR2(3);

TYPE NumTab is TABLE of NUMBER INDEX by BINARY_INTEGER;
l_quantity1 NumTab;
l_quantity2 NumTab;
l_line_qty_tbl   NumTab;                                      -- <SERVICES FPJ>
l_line_amt_tbl   NumTab;                                      -- <SERVICES FPJ>
l_dist_qty_tbl   NumTab;                                      -- <SERVICES FPJ>
l_dist_amt_tbl   NumTab;                                      -- <SERVICES FPJ>
l_line_num   NumTab;
l_shipment_num NumTab;
l_dist_num NumTab;
l_rowcount NumTab;

TYPE value_basis_tbl_type IS
    TABLE OF PO_LINE_TYPES_B.order_type_lookup_code%TYPE;     -- <SERVICES FPJ>
l_value_basis_tbl         value_basis_tbl_type;               -- <SERVICES FPJ>

--<R12 eTax Integration Start>
l_return_status    VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_tax_status       VARCHAR2(1);
l_tax_message      fnd_new_messages.message_text%TYPE;
--<R12 eTax Integration End>

BEGIN

l_progress := '000';
-- BUG 2687600 mbhargav
--Removed Update statement to update rate in po_requistion_lines

l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head||l_api_name||'.'
          || l_progress,'REQ 1: No lines ');
   END IF;
END IF;

    -- Check 1: Each Requisition Header must have atleast one line
    -- PO_SUB_REQ_HEADER_NO_LINES
  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REQ_HEADER_NO_LINES');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_REQ_HEADER_NO_LINES'
     FROM   PO_REQ_HEADERS_GT PRH
     WHERE  PRH.requisition_header_id = p_document_id
     AND    NOT EXISTS (SELECT 'Lines Exist'
                        FROM   PO_REQ_LINES_GT PRL
                        WHERE  PRL.requisition_header_id = PRH.requisition_header_id
                        AND    nvl(PRL.cancel_flag,'N') = 'N');

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
------------------------------------------------

l_progress := '002';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head||l_api_name||'.'
          || l_progress,'REQ 2: No distributions');
   END IF;
END IF;

    -- Check 2: Each Requisition line must have atleast one distribution
    -- PO_SUB_REQ_LINE_NO_DIST

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REQ_LINE_NO_DIST');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        PRL.line_num,
        0,
        0,
        p_sequence + ROWNUM,
        substr(g_linemsg||g_delim||PRL.line_num||g_delim||l_textline,1,240),
            'PO_SUB_REQ_LINE_NO_DIST'
     FROM  PO_REQ_LINES_GT PRL
     WHERE PRL.requisition_header_id = p_document_id AND
           nvl(PRL.cancel_flag,'N') = 'N' AND
           nvl(PRL.closed_code,'OPEN') <> 'FINALLY CLOSED' AND
           nvl(PRL.modified_by_agent_flag,'N') = 'N' AND
           NOT EXISTS (SELECT 'Dist Exist'
                       FROM PO_REQ_DISTRIBUTIONS_GT PRD
                       WHERE PRD.requisition_line_id = PRL.requisition_line_id);

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
-------------------------------------------------

l_progress := '003';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head||l_api_name||'.'
          || l_progress,'REQ 3: Line qty does not match dist qty');
   END IF;
END IF;

    -- Check 3: The sum of all distribution quantities/amounts must equal their
    -- corresponding line quantity/amount.

    SELECT
        PRL.line_num
    ,   PLT.order_type_lookup_code                            -- <SERVICES FPJ>
    ,   PRL.quantity
    ,   PRL.amount                                            -- <SERVICES FPJ>
    --Start Bug 13065293
    ,   round(sum(nvl(PRD.req_line_quantity, 0)),15)          -- <SERVICES FPJ>
    --End Bug 13065293
    ,   sum(nvl(PRD.req_line_amount, 0))                      -- <SERVICES FPJ>
    BULK COLLECT INTO
        l_line_num
    ,   l_value_basis_tbl                                     -- <SERVICES FPJ>
    ,   l_line_qty_tbl                                        -- <SERVICES FPJ>
    ,   l_line_amt_tbl                                        -- <SERVICES FPJ>
    ,   l_dist_qty_tbl                                        -- <SERVICES FPJ>
    ,   l_dist_amt_tbl                                        -- <SERVICES FPJ>
    FROM
        PO_REQ_DISTRIBUTIONS_GT PRD
    ,   PO_REQ_LINES_GT         PRL
    ,   PO_LINE_TYPES_B         PLT                           -- <SERVICES FPJ>
    WHERE
        PRL.requisition_line_id = PRD.requisition_line_id
    AND PRL.requisition_header_id = p_document_id
    AND nvl(PRL.cancel_flag,'N') = 'N'
    AND nvl(PRL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND nvl(PRL.modified_by_agent_flag,'N') = 'N'
    AND PRL.line_type_id = PLT.line_type_id                   -- <SERVICES FPJ>
    AND                                                       -- <SERVICES FPJ>
        (   (   ( PLT.order_type_lookup_code IN ('QUANTITY','AMOUNT')
            --Start Bug 13065293
            AND ( round(PRL.quantity,15) <> ( SELECT round(nvl(sum(PRD2.req_line_quantity),0),15)
            --End Bug 13065293
                                    FROM   PO_REQ_DISTRIBUTIONS_GT PRD2
                                    WHERE  PRD2.requisition_line_id = PRL.requisition_line_id ) ) )
        OR  (   ( PLT.order_type_lookup_code IN ('RATE','FIXED PRICE') )
            AND ( PRL.amount <>   ( SELECT nvl(sum(PRD2.req_line_amount),0)
                                    FROM   PO_REQ_DISTRIBUTIONS_GT PRD2
                                    WHERE  PRD2.requisition_line_id = PRL.requisition_line_id ) ) ) )
        )
    GROUP BY
        PRL.line_num
    ,   PLT.order_type_lookup_code                            -- <SERVICES FPJ>
    ,   PRL.quantity
    ,   PRL.amount;                                           -- <SERVICES FPJ>

    FOR i IN 1..l_line_num.COUNT LOOP
        l_rowCount(i) := i;
    END LOOP;

    FORALL i IN 1..l_line_num.COUNT
        INSERT INTO po_online_report_text_gt (online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
        VALUES(
            p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            l_line_num(i),
            NULL,                                             -- <SERVICES FPJ>
            NULL,                                             -- <SERVICES FPJ>
            p_sequence+l_rowCount(i),
            decode ( l_value_basis_tbl(i)                     -- <SERVICES FPJ>
                   , 'RATE'        , PO_CORE_S.get_translated_text
                                     (   'PO_SUB_REQ_LINE_NE_DIST_AMT'
                                     ,   'LINE_NUM', l_line_num(i)
                                     ,   'LINE_AMT', l_line_amt_tbl(i)
                                     ,   'DIST_AMT', l_dist_amt_tbl(i)
                                     )
                   , 'FIXED PRICE' , PO_CORE_S.get_translated_text
                                     (   'PO_SUB_REQ_LINE_NE_DIST_AMT'
                                     ,   'LINE_NUM', l_line_num(i)
                                     ,   'LINE_AMT', l_line_amt_tbl(i)
                                     ,   'DIST_AMT', l_dist_amt_tbl(i)
                                     )
                                   , PO_CORE_S.get_translated_text
                                     (   'PO_SUB_REQ_LINE_NE_DIST_QTY'
                                     ,   'LINE_NUM', l_line_num(i)
                                     ,   'LINE_QTY', l_line_qty_tbl(i)
                                     ,   'DIST_QTY', l_dist_qty_tbl(i)
                                     )
                   ),
            decode ( l_value_basis_tbl(i)                     -- <SERVICES FPJ>
                   , 'RATE'        , 'PO_SUB_REQ_LINE_NE_DIST_AMT'
                   , 'FIXED PRICE' , 'PO_SUB_REQ_LINE_NE_DIST_AMT'
                                   , 'PO_SUB_REQ_LINE_NE_DIST_QTY'
                   )
          );

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + l_line_num.COUNT;
------------------------------------------------

l_progress := '004';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head||l_api_name||'.'
          || l_progress,'REQ 4: More than one dist for INVENTORY src type');
   END IF;
END IF;

  -- Check 4:Lines with SOURCE type as INVENTORY can have one only one dist
    -- PO_SUB_REQ_SOURCE_ONE_DIST

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REQ_SOURCE_ONE_DIST');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        PRL.line_num,
        0,
        0,
        p_sequence + ROWNUM,
        substr(g_linemsg||g_delim||PRL.line_num||g_delim||l_textline,1,240),
            'PO_SUB_REQ_SOURCE_ONE_DIST'
     FROM  PO_REQ_LINES_GT PRL
     WHERE PRL.requisition_header_id = p_document_id AND
           PRL.source_type_code = 'INVENTORY' AND
           nvl(PRL.cancel_flag,'N') = 'N' AND
           nvl(PRL.closed_code, 'OPEN') <> 'FINALLY CLOSED' AND
           1 < (SELECT count(PRD.requisition_line_id)
                FROM  PO_REQ_DISTRIBUTIONS_GT PRD
                WHERE PRD.requisition_line_id = PRL.requisition_line_id);

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
-----------------------------------------------------

l_progress := '005';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head||l_api_name||'.'
          || l_progress,'REQ 5: Rate cannot be nULL for foreign currency vendor');
   END IF;
END IF;

  -- Check 5: Requistion Rate cannot be NULL if using a foreign currency vendor
    -- PO_SUB_REQ_RATE_NULL
  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REQ_RATE_NULL');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        PRL.line_num,
        0,
        0,
        p_sequence + ROWNUM,
        substr(g_linemsg||g_delim||PRL.line_num||g_delim||l_textline,1,240),
            'PO_SUB_REQ_RATE_NULL'
     FROM PO_REQ_LINES_GT PRL, FINANCIALS_SYSTEM_PARAMETERS FSP,
          GL_SETS_OF_BOOKS SOB
     WHERE PRL.requisition_header_id = p_document_id AND
           nvl(PRL.cancel_flag, 'N') = 'N' AND
           nvl(PRL.closed_code, 'OPEN') <> 'FINALLY CLOSED' AND
           SOB.set_of_books_id = FSP.set_of_books_id AND
           SOB.currency_code <> PRL.currency_code AND
           (PRL.rate is NULL OR
            PRL.rate_type is NULL OR
           (PRL.rate_type <> 'User' AND PRL.rate_date is NULL));

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
----------------------------------------------

l_progress := '006';

-- Check 6: The Req GL date should be within an open purchasing period
-- PO_SUB_REQ_INVALID_GL_DATE

--<FPJ ENCUMBRANCE>

IF (  PO_CORE_S.is_encumbrance_on(
         p_doc_type => g_document_type_REQUISITION
      ,  p_org_id => NULL
      )
   )
THEN

   l_progress := '061';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(g_log_head||l_api_name,
              l_progress,'REQ 6: GL date within open purchasing period check');
   END IF;

   check_gl_date(
      p_doc_type => g_document_type_REQUISITION
   ,  p_online_report_id => p_online_report_id
   ,  p_login_id => p_login_id
   ,  p_user_id => p_user_id
   ,  p_sequence => p_sequence
   );

   l_progress := '062';

ELSE
   l_progress := '063';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(g_log_head||l_api_name,
              l_progress,'REQ 6: Req encumbrance not on');
   END IF;
END IF;

l_progress := '007';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head||l_api_name||'.'
          || l_progress,'REQ 7: Requisitions cannot have ATO/CTO model items');
   END IF;
END IF;

  -- Check 7: Requisitions cannot have ATO/CTO model items (Bug 3362369)
        -- PO_ATO_ITEM_NA
  l_textline := FND_MESSAGE.GET_STRING('PO','PO_ATO_ITEM_NA');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
                  sysdate,
        p_user_id,
        sysdate,
        PRL.line_num,
        0,
        0,
        p_sequence + ROWNUM,
        substr(g_linemsg||g_delim||PRL.line_num||g_delim||l_textline,1,240),
                   'PO_ATO_ITEM_NA'
     FROM PO_REQ_LINES_GT PRL, FINANCIALS_SYSTEM_PARAMETERS FSP,
          MTL_SYSTEM_ITEMS MSI
     WHERE PRL.requisition_header_id = p_document_id AND
           nvl(PRL.cancel_flag, 'N') = 'N' AND
           nvl(PRL.closed_code, 'OPEN') <> 'FINALLY CLOSED' AND
           PRL.item_id is not null AND
           PRL.item_id = MSI.inventory_item_id AND
           FSP.inventory_organization_id = MSI.organization_id AND
           MSI.bom_item_type in (1,2);

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
-------------------------------------------------------------------------

    l_progress := '008';
-- Check 8:
--<R12 eTax Integration Start>
-----------------------------------------------------------------------------

    l_tax_status := po_tax_interface_pvt.calculate_tax_yes_no(p_po_header_id   => NULL,
                                                              p_po_release_id  => NULL,
                                                              p_req_header_id  => p_document_id);
    IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head ||l_api_name||'.'
                        || l_progress,'REQ 8: Recalculate tax before approval = ' || l_tax_status);
        END IF;
    END IF;
    l_progress := '009';
    IF  l_tax_status = 'Y' THEN
      IF g_debug_stmt THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                         l_api_name||'.' || l_progress,
                         'REQ 9: Calculate tax as the current one is not correct');
          END IF;
      END IF;
      l_progress := '010';
      po_tax_interface_pvt.calculate_tax_requisition( x_return_status         => l_return_status,
                                                      p_requisition_header_id => p_document_id,
                                                      p_calling_program       => g_action_DOC_SUBMISSION_CHECK);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        l_progress := '011';
        IF g_debug_stmt THEN
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                            l_api_name||'.' || l_progress,
                            'REQ 10: Calculate tax has errored out');
             END IF;
        END IF;

        l_tax_message := fnd_message.get_string('PO','PO_TAX_CALCULATION')||' : ' ;

        FOR i IN 1..po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT.COUNT
	LOOP
           INSERT INTO po_online_report_text_gt
           (
            online_report_id,
            last_update_login,
            last_updated_by,
            last_update_date,
            created_by,
            creation_date,
            line_num,
            shipment_num,
            distribution_num,
            sequence,
            text_line,
            message_name,
            message_type
           )
           VALUES
           (
             p_online_report_id,
             p_login_id,
             p_user_id,
             sysdate,
             p_user_id,
             sysdate,
             po_tax_interface_pvt.G_TAX_ERRORS_TBL.line_num(i),
             po_tax_interface_pvt.G_TAX_ERRORS_TBL.shipment_num(i),
             po_tax_interface_pvt.G_TAX_ERRORS_TBL.distribution_num(i),
             p_sequence + i, /* 11851142 replaced rownum with i */
             l_tax_message || po_tax_interface_pvt.G_TAX_ERRORS_TBL.message_text(i),
             'PO_TAX_CALCULATION_FAILED',
             'E'
           );
	END LOOP;
        l_progress := '012';
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        l_progress := '013';
        IF g_debug_stmt THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                            l_api_name||'.' || l_progress,
                            'REQ 11: Calculate tax raised unexpected error');
           END IF;
        END IF;
        l_textline := l_progress ||' - ';
        IF po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT.COUNT > 0 THEN
          l_textline := l_textline || po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT(1);
        ELSE
          l_textline := l_textline || SQLERRM();
        END IF;
        fnd_message.set_name('PO','PO_TAX_CALC_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR',l_textline);
        FND_MSG_PUB.Add;
        l_progress := '014';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    p_sequence := p_sequence + SQL%ROWCOUNT;

-----------------------------------------------------------------------------

    l_progress := '015';
--<R12 eTax Integration End>
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END CHECK_REQUISITIONS;
--------------------------------------------------

--For RELEASES
/**
* Private Procedure: CHECK_RELEASES
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure runs the document submission checks for RELEASES
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*/
PROCEDURE check_releases(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_textline  po_online_report_text.text_line%TYPE := NULL;
l_api_name  CONSTANT varchar2(40) := 'CHECK_RELEASES';
l_progress VARCHAR2(3);

--<Bug 2800804, 2792477 mbhargav START>
l_total_rel_amount NUMBER :=0;
l_this_rel_amount NUMBER :=0;
l_previous_rel_amount NUMBER :=0;
l_previous_rel_archive_amount NUMBER :=0; -- Bug13587303
--<Bug 2800804, 2792477 mbhargav END>

TYPE NumTab is TABLE of NUMBER INDEX by BINARY_INTEGER;
l_quantity1 NumTab;
l_quantity2 NumTab;
l_line_num   NumTab;
l_shipment_num NumTab;
l_dist_num NumTab;
l_rowcount NumTab;
l_ship_qty_tbl    NumTab;                                     -- <SERVICES FPJ>
l_ship_amt_tbl    NumTab;                                     -- <SERVICES FPJ>
l_dist_qty_tbl    NumTab;                                     -- <SERVICES FPJ>
l_dist_amt_tbl    NumTab;                                     -- <SERVICES FPJ>

-- bug 6530879 Releases < Var addition START>
l_agreement_id    PO_HEADERS_ALL.po_header_id%TYPE;
l_vendor_id       PO_HEADERS_ALL.vendor_id%TYPE;
l_vendor_site_id  PO_HEADERS_ALL.vendor_site_id%TYPE;
l_vendor_contact_id PO_HEADERS_ALL.vendor_contact_id%TYPE;
-- bug 6530879 Releases < Var addition END>

--<R12 eTax Integration Start>
l_return_status    VARCHAR2(1);
l_tax_status       VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_tax_message      fnd_new_messages.message_text%TYPE;
--<R12 eTax Integration End>

--bug#3987438
--A new table to hold the invalid ship to location codes
TYPE CharTab is TABLE of HR_LOCATIONS_ALL_TL.location_code%type INDEX by BINARY_INTEGER;
l_ship_to_location_tbl CharTab;
--bug#3987438

BEGIN

l_progress := '000';
-- BUG 2687600 mbhargav
--Removed update statement to update rate in po_distributions

l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 1: PA should be approved');
   END IF;
END IF;

    -- Check 1: The Purchase Agreement associated with the Release
    -- must be Approved.
    -- PO_SUB_REL_PA_APPROVED
    --< Bug 3422733 > Only do this check if the BPA is not ON HOLD. The ON HOLD
    -- check is done later. Avoids showing 2 msgs for BPA that is ON HOLD.

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REL_PA_APPROVED');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,0,0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_REL_PA_APPROVED'
    FROM   PO_RELEASES_GT POR,PO_HEADERS_GT POH
    WHERE  POR.po_header_id = POH.po_header_id
    AND    POR.po_release_id = p_document_id
    AND    NVL(POH.approved_flag, 'N') <> 'Y'
    AND    NVL(POH.user_hold_flag, 'N') <> 'Y';     --< Bug 3422733 >

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
---------------------------------------------------------

l_progress := '002';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 2: Within PA effective dates ');
   END IF;
END IF;

  -- Check 2: (Bug3199869)
        -- If release has not been approved before, the blanket
        -- cannot be expired already
        -- PO_SUB_REL_PA_EXPIRED

       -- bug3199869
       -- Modified Check 2 so that an error will be thrown only when
       -- 1) Release has not been approved once yet, AND
       -- 2) SYSDATE is after expiration date on the blanket header

       --Bug 8302986
       --TO CREATE RELEASES AGAINST BLANKETS OUT SIDE THE EFFECTIVE DATA RANGES OF THE BLANKET
       --WITH IN  THE TOLERANCE SPECIFIED BY THE PROFILE "PO: Release Creation Tolerance For Expired Blankets; in Days",
       --CHANGED THE WHERE CLAUSE TO EXCEEDE THE END DATE BY THE TOLERANCE VALUE


  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REL_PA_EXPIRED');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_REL_PA_EXPIRED'                    -- bug3199869
    FROM   PO_RELEASES_GT POR,PO_HEADERS_GT POH
    WHERE  POR.po_header_id = POH.po_header_id
    AND    POR.po_release_id = p_document_id
    AND    POR.approved_date IS NULL                   -- bug3199869
    AND    TRUNC(SYSDATE) >                            -- bug3199869
           TRUNC(NVL(POH.end_date + nvl(FND_PROFILE.VALUE('PO_REL_CREATE_TOLERANCE'),0), SYSDATE + 1));      -- bug3199869

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
----------------------------------------

l_progress := '003';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 3: PA should not be ON HOLD');
   END IF;
END IF;

  -- Check 3: Purchase Agreement assocaited with this release must not be
    -- on hold
    -- PO_SUB_REL_PA_ON_HOLD

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REL_PA_ON_HOLD');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_REL_PA_ON_HOLD'
    FROM  PO_RELEASES_GT POR,PO_HEADERS_GT POH
    WHERE  POR.po_header_id = POH.po_header_id
    AND    POR.po_release_id = p_document_id
    AND    nvl(POH.user_hold_flag, 'N') = 'Y';


     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
-------------------------------------------------

l_progress := '004';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 4: PAs Supplier should not be ON HOLD');
   END IF;
END IF;

  -- Check 4: Associated Purchase Agreement's supplier should not be on hold
    -- PO_SUB_REL_VENDOR_ON_HOLD

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REL_VENDOR_ON_HOLD');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
    SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_REL_VENDOR_ON_HOLD'
    FROM  PO_RELEASES_GT POR,PO_HEADERS_GT POH,PO_VENDORS POV,
          PO_SYSTEM_PARAMETERS PSP
    WHERE  POR.po_header_id  = POH.po_header_id
    AND    POV.vendor_id     = POH.vendor_id
    AND    POR.po_release_id = p_document_id
    AND    nvl(PSP.ENFORCE_VENDOR_HOLD_FLAG,'N') = 'Y'
    AND    nvl(POV.hold_flag,'N') = 'Y';


     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
---------------------------------------------------

l_progress := '005';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 5: Release must have atleast one shipment');
   END IF;
END IF;

  -- Check 5: Every Release must have atleast one shipment
    -- PO_SUB_REL_NO_SHIP

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REL_NO_SHIP');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_REL_NO_SHIP'
    FROM  PO_RELEASES_GT POR
    WHERE  POR.po_release_id = p_document_id
    AND    NOT EXISTS
       (SELECT 'Shipment Exist'
        FROM   PO_LINE_LOCATIONS_GT PLL
        WHERE  PLL.po_release_id = POR.po_release_id);
        -- AND    nvl(PLL.cancel_flag,'N') = 'N');
        -- bug 3305488

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

-------------------------------------------
--Bug5075191
--Following submission check should exclude cancelled/finally closed lines.
--Adding those conditions.
--bug#3987438
--Added a new submission check to validate the
--ship to location at the shipment level.

IF g_debug_stmt THEN
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL : Invalid Ship To Locations');
END IF;

    SELECT POLG.shipment_num,
           HLT.location_code
    BULK COLLECT INTO
           l_line_num,
           l_ship_to_location_tbl
    FROM  PO_LINE_LOCATIONS_GT POLG,
          HR_LOCATIONS_ALL HLA,
          HR_LOCATIONS_ALL_TL HLT
    WHERE POLG.po_release_id = p_document_id
    AND   POLG.ship_to_location_id=HLA.location_id
    AND   nvl(POLG.cancel_flag,'N') = 'N'
    AND   nvl(POLG.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND   NVL (TRUNC (HLA.INACTIVE_DATE), TRUNC (SYSDATE)+1 )<= TRUNC (SYSDATE)
    AND   HLA.location_id=HLT.location_id
    AND   HLT.language=USERENV('LANG');

    FOR i IN 1..l_line_num.COUNT LOOP
        l_rowCount(i) := i;
    END LOOP;

FORALL i IN 1..l_line_num.COUNT
    INSERT INTO po_online_report_text_gt (
            online_report_id,
			last_update_login,
			last_updated_by,
			last_update_date,
			created_by,
			creation_date,
			line_num,
			shipment_num,
			distribution_num,
			sequence,
			text_line,
            message_name)
    VALUES(
            p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            0,
            0,
            0,                                             -- <SERVICES FPJ>
            p_sequence+l_rowCount(i),
            substr(PO_CORE_S.get_translated_text
                        ( 'PO_SUB_REL_INVALID_SHIP_TO',
                          'LINE_NUM',
                          l_line_num(i),
                          'SHIP_TO_LOC',
                          l_ship_to_location_tbl(i)
                          ),1,240),
            'PO_SUB_REL_INVALID_SHIP_TO'
        );

    p_sequence := p_sequence + l_line_num.COUNT;
--bug#3987438

-------------------------------------------

l_progress := '006';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 6: check Price tolerance exceed on line');
   END IF;
END IF;

  -- Check 6: Release Shipment Price/Amount should follow the pricing rules
    -- designated on the Purchase Agreement Line.
    -- Details: If price override is equal to 'Y', the Release Shipment
    -- Price/Amount must be less than the Price Override.
    --
    -- Bug 3177525: This check should not be done if allow_price_override_flag
    -- is 'N' because the user can never modify the release price/amount; it is
    -- automatically defaulted.

  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        PLL.shipment_num,
        0,
        p_sequence + ROWNUM,
            decode ( POL.order_type_lookup_code                -- <BUG 3262859>
                   , 'FIXED PRICE' , PO_CORE_S.get_translated_text
                                   (   'PO_SUB_REL_PRICE_GT_LIMIT'
                                   ,   'SHIP_NUM'   , PLL.shipment_num
                                   ,   'SHIP_PRICE' , nvl( PLL.price_override,PLL.amount)
                                   ,   'LINE_PRICE' , nvl ( POL.not_to_exceed_price
                                                          , PLL.price_override )
                                   )
                   ,               PO_CORE_S.get_translated_text
                                   (   'PO_SUB_REL_AMT_GT_LIMIT'
                                   ,   'SHIP_NUM'   , PLL.shipment_num
                                   ,   'SHIP_AMT'   , PLL.amount
                                   ,   'LINE_AMT'   , nvl ( POL.not_to_exceed_price
                                                          , PLL.amount )
                                   )
                   ),
            decode ( POL.order_type_lookup_code                -- <BUG 3262859>
                   , 'FIXED PRICE' , 'PO_SUB_REL_SHIP_PRICE_GT_LIMIT'
                   ,                 'PO_SUB_REL_SHIP_AMT_GT_LIMIT'
                   )
    FROM PO_LINE_LOCATIONS_GT PLL,PO_LINES POL
    WHERE PLL.po_line_id = POL.po_line_id
    AND   PLL.po_release_id = p_document_id
    AND   nvl(PLL.cancel_flag,'N')= 'N'
    AND   nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND   POL.allow_price_override_flag = 'Y'                 -- Bug 3177525
    AND   (                                                   -- <SERVICES FPJ>
              (   ( POL.order_type_lookup_code IN ('QUANTITY','AMOUNT','RATE'))-- <BUG 3262859>
              AND ( PLL.price_override > nvl ( POL.not_to_exceed_price
                                             , PLL.price_override ) )
              )
          OR
              (   ( POL.order_type_lookup_code IN ('FIXED PRICE') )               -- <BUG 3262859>
              AND ( PLL.amount > nvl ( POL.not_to_exceed_price, PLL.amount ) ) )
          )
    ;

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
----------------------------------------

l_progress := '007';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 7: Rel shipment qty should match dist qty');
   END IF;
END IF;

  -- Check 7: Quantities/Amounts must match between Release Shipments and
    -- Distributions

    SELECT
        0
    ,   PLL.shipment_num
    ,   0
    ,   PLL.quantity
    ,   PLL.amount                                            -- <SERVICES FPJ>
    ,   nvl(sum(POD.quantity_ordered),0)                      -- <SERVICES FPJ>
    ,   nvl(sum(POD.amount_ordered),0)                        -- <SERVICES FPJ>
    BULK COLLECT INTO
        l_line_num
    ,   l_shipment_num
    ,   l_dist_num
    ,   l_ship_qty_tbl                                        -- <SERVICES FPJ>
    ,   l_ship_amt_tbl                                        -- <SERVICES FPJ>
    ,   l_dist_qty_tbl                                        -- <SERVICES FPJ>
    ,   l_dist_amt_tbl                                        -- <SERVICES FPJ>
    FROM
        PO_DISTRIBUTIONS_GT POD                       -- <PO_CHANGE_API FPJ>
    ,   PO_LINE_LOCATIONS_GT PLL
    WHERE
        PLL.line_location_id = POD.line_location_id
    AND PLL.po_release_id = p_document_id
    AND nvl(PLL.cancel_flag,'N') = 'N'
    AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND (                                                     -- <SERVICES FPJ>
            (   ( PLL.quantity IS NOT NULL )
            AND ( PLL.quantity <> ( SELECT sum(POD2.quantity_ordered)
                                    FROM   PO_DISTRIBUTIONS_GT POD2
                                    WHERE  POD2.line_location_id = PLL.line_location_id ) ) )
        OR  (   ( PLL.amount IS NOT NULL )
            AND ( PLL.amount <> ( SELECT sum(POD2.amount_ordered)
                                  FROM   PO_DISTRIBUTIONS_GT POD2
                                  WHERE  POD2.line_location_id = PLL.line_location_id ) ) )
        )
    GROUP BY
        PLL.shipment_num
    ,   PLL.quantity
    ,   PLL.amount;                                           -- <SERVICES FPJ>

    FOR i IN 1..l_line_num.COUNT LOOP
        l_rowCount(i) := i;
    END LOOP;

    FORALL i IN 1..l_line_num.COUNT
        INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
        VALUES(
            p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            NULL,                                             -- <SERVICES FPJ>
            l_shipment_num(i),
            NULL,                                             -- <SERVICES FPJ>
            p_sequence+l_rowCount(i),
            decode ( l_ship_qty_tbl(i)                        -- <SERVICES FPJ>
                   , NULL , PO_CORE_S.get_translated_text
                            (   'PO_SUB_REL_SHIP_NE_DIST_AMT'
                            ,   'SHIP_NUM', l_shipment_num(i)
                            ,   'SHIP_AMT', l_ship_amt_tbl(i)
                            ,   'DIST_AMT', l_dist_amt_tbl(i)
                            )
                   ,        PO_CORE_S.get_translated_text
                            (   'PO_SUB_REL_SHIP_NE_DIST_QTY'
                            ,   'SHIP_NUM', l_shipment_num(i)
                            ,   'SHIP_QTY', l_ship_qty_tbl(i)
                            ,   'DIST_QTY', l_dist_qty_tbl(i)
                            )
                   ),
            decode ( l_ship_qty_tbl(i)                        -- <SERVICES FPJ>
                   , NULL , 'PO_SUB_REL_SHIP_NE_DIST_AMT'
                   ,        'PO_SUB_REL_SHIP_NE_DIST_QTY'
                   )
        );

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + l_line_num.COUNT;
---------------------------------------------------------

l_progress := '008';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 8: Rel shipment should have atleast one dist ');
   END IF;
END IF;

  -- Check 8: All Release shipments should have atleast one distribution
    -- PO_SUB_REL_SHIP_NO_DIST

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REL_SHIP_NO_DIST');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        PLL.shipment_num,
        0,
        p_sequence + ROWNUM,
        substr(g_shipmsg||g_delim||PLL.shipment_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_REL_SHIP_NO_DIST'
    FROM PO_LINE_LOCATIONS_GT PLL
    WHERE PLL.po_release_id = p_document_id
    AND nvl(PLL.cancel_flag,'N') = 'N'
    AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND NOT EXISTS
       (SELECT 'Distribution Exists'
        FROM PO_DISTRIBUTIONS_GT POD                  -- <PO_CHANGE_API FPJ>
        WHERE POD.line_location_id = PLL.line_location_id);


     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
-----------------------------------------------------

l_progress := '009';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 9: Dist rate cannot be NULL if using foreign currency vendor');
   END IF;
END IF;

  -- Check 9: Rate on the Release shipment must not be NULL if using a foreign
    -- currency vendor. We are using foreign currency if the currency on PO
    -- Header does not match Set of Books currency
    -- PO_SUB_REL_RATE_NULL
  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REL_RATE_NULL');
    INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
    SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        POLL.shipment_num,
            POD.distribution_num,
        p_sequence + ROWNUM,
        substr(g_shipmsg||g_delim||POLL.shipment_num||g_delim
                   ||g_distmsg||g_delim||POD.distribution_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_REL_RATE_NULL'
    FROM PO_DISTRIBUTIONS_GT POD,                     -- <PO_CHANGE_API FPJ>
         PO_LINE_LOCATIONS_GT POLL,PO_LINES POL,
         PO_RELEASES_GT POR,PO_HEADERS_GT POH,GL_SETS_OF_BOOKS SOB,
         FINANCIALS_SYSTEM_PARAMETERS FSP
    WHERE POLL.po_release_id = POR.po_release_id
    AND POD.line_location_id = POLL.line_location_id
    AND POLL.po_line_id = POL.po_line_id
    AND POH.po_header_id = POR.po_header_id
    AND POR.po_release_id = p_document_id
    AND SOB.set_of_books_id = FSP.set_of_books_id
    AND nvl(POLL.cancel_flag, 'N') = 'N'
    AND nvl(POLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
    AND SOB.currency_code <> POH.currency_code
    AND POD.rate is null;


     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
-----------------------------------------------

l_progress := '010';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 10: Amount should be greater than min release amount ');
   END IF;
END IF;

  -- Check 10:Release total amount must be greater than Purchase Agreement
    -- minimum release amount
    -- PO_SUB_REL_AMT_LESS_MINREL_AMT

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REL_AMT_LESS_MINREL_AMT');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_REL_AMT_LESS_MINREL_AMT'
    FROM  PO_HEADERS_GT POH,PO_RELEASES_GT POR
    WHERE POR.po_release_id = p_document_id
    AND   POH.po_header_id  = POR.po_header_id
    AND   POH.min_release_amount IS NOT NULL
    AND   POH.min_release_amount >                            -- <SERVICES FPJ>
              ( SELECT decode ( sum( decode ( PLL2.quantity
                                            , NULL , ( PLL2.amount - nvl(PLL2.amount_cancelled,0) )
                                            ,        ( PLL2.quantity - nvl(PLL2.quantity_cancelled,0) )
                                            )
                                   )
                              , 0 , POH.min_release_amount
                              ,     sum ( decode ( PLL2.quantity
                                                 , NULL , ( PLL2.amount - nvl(PLL2.amount_cancelled,0) )
                                                 ,        (   ( PLL2.quantity - nvl(PLL2.quantity_cancelled,0) )
                                                          *   PLL2.price_override )
                                                 )
                                        )
                              )
                FROM   PO_LINE_LOCATIONS_GT PLL2
                WHERE  PLL2.po_release_id = POR.po_release_id
                AND    PLL2.shipment_type IN ('BLANKET', 'SCHEDULED')
              );

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
-------------------------------------------------
-- Bug 7188760
-- Added the POH.Amount_Limit is Not Null condition in the following sqls
l_progress := '011';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 11: Not to exceed Amount Limit');
   END IF;
END IF;

  -- Check 11: The amount being released plus the amount released to-date
    -- against the PA must be less than the amount limit for the agreement
    -- PO_SUB_REL_AMT_GRT_LIMIT_AMT


       --<Bug 2800804, 2792477 mbhargav START>
       --Split the amount calculation to two select statements,
       --this was required because iSP is sending some chnage_requests
       --which are only in GT tables so need to get the amount for
       --current document from GT table and not the base tables

       --This select statement gets the amount on current document

       SELECT                                                 -- <SERVICES FPJ>
              sum ( decode ( PLL1.quantity
                           , NULL , ( PLL1.amount
                                    - nvl(PLL1.amount_cancelled,0) )
                           ,        (   ( PLL1.quantity
                                        - nvl(PLL1.quantity_cancelled,0) )
                                    * PLL1.price_override ) ) )
       INTO  l_this_rel_amount
       FROM PO_LINE_LOCATIONS_GT PLL1, PO_RELEASES_GT POR1, PO_HEADERS_GT POH
       WHERE  POR1.po_release_id = p_document_id
       AND    POR1.po_header_id  = POH.po_header_id	-- Bug 7188760
       AND    POH.amount_limit is Not Null		-- Bug 7188760
       AND    PLL1.po_release_id = POR1.po_release_id;

       --This select statement adds amount from all OTHER approved releases
       --for this Blanket

	--Bug 13587303
	/*
	1.	We will consider the Sum of Quantity for Approved Releases + Sum of Quantity for all other releases that were approved and now in Requires Reapproval or Rejected status.
	2.	For sum of quantity for other releases that were approved and now in Requires Reapproval or Rejected Status, we will be getting the quantity  details from Archive Tables for the latest row.
	*/

       SELECT                                                 -- <SERVICES FPJ>
              /* FULL(POH)*/
              nvl ( sum ( decode ( PLL2.quantity
                                 , NULL , ( PLL2.amount
                                          - nvl(PLL2.amount_cancelled,0) )
                                 ,        (   ( PLL2.quantity
                                          - nvl(PLL2.quantity_cancelled,0) )
                                          * PLL2.price_override ) ) )
                  , 0 )
       INTO l_previous_rel_amount
       FROM PO_LINE_LOCATIONS PLL2, PO_RELEASES POR2, PO_HEADERS_GT POH
       WHERE PLL2.po_release_id = POR2.po_release_id
       AND POR2.po_header_id = POH.po_header_id
       AND nvl(POR2.approved_flag, 'N') = 'Y' --Bug 13587303
       AND POH.amount_limit is Not Null		-- Bug 7188760
       AND POR2.po_release_id <> p_document_id;

-- For sum of quantity for other releases that were approved and now in Requires Reapproval or Rejected Status,
-- we will be getting the quantity  details from Archive Tables for the latest row.
--Bug 13587303
 			SELECT           -- <SERVICES FPJ>
              /* FULL(POH)*/
              nvl ( sum ( decode ( PLL2.quantity
                                 , NULL , ( PLL2.amount
                                          - nvl(PLL2.amount_cancelled,0) )
                                 ,        (   ( PLL2.quantity
                                          - nvl(PLL2.quantity_cancelled,0) )
                                          * PLL2.price_override ) ) )
                  , 0 )
       INTO l_previous_rel_archive_amount
       FROM po_line_locations_archive_all PLL2, po_releases_all POR2, PO_HEADERS_GT POH
       WHERE PLL2.po_release_id = POR2.po_release_id
       AND POR2.po_header_id = POH.po_header_id
       AND nvl(POR2.approved_flag, 'N') IN ('R','F')
       and NVL(PLL2.LATEST_EXTERNAL_FLAG,'N') = 'Y'
       AND POH.amount_limit is Not Null
       AND POR2.po_release_id <> p_document_id;


       --Get the total amount released/to be released for this shipment
       l_total_rel_amount := l_this_rel_amount + l_previous_rel_amount + l_previous_rel_archive_amount; --Bug 13587303
       --<Bug 2800804, 2792477 mbhargav END>


  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REL_AMT_GRT_LIMIT_AMT');
  INSERT INTO po_online_report_text_gt (online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_REL_AMT_GRT_LIMIT_AMT'
    FROM   PO_HEADERS_GT POH,PO_RELEASES_GT POR
    WHERE  POR.po_release_id = p_document_id
    AND    POH.po_header_id  = POR.po_header_id

    AND    POH.amount_limit is not null
    --<Bug 2800804, 2792477 mbhargav START>
    --Compare it to total of current release amount and
    --already released amount calculated above the INSERT statement
    AND    POH.amount_limit < l_total_rel_amount;

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
------------------------------------------------

l_progress := '012';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,
          'REL 12: Amount released check for min release amt');
   END IF;
END IF;

  -- Check 12: The Amount being released for all shipments for a particular line
    -- must be greater than the min release amount specified in agreement line
    -- PO_SUB_REL_SHIPAMT_LESS_MINREL

    l_textline := FND_MESSAGE.GET_STRING('PO','PO_SUB_REL_SHIPAMT_LESS_MINREL');
    SELECT
        POL.line_num,
        0,
        0,
        POL.min_release_amount,
        0
    BULK COLLECT INTO
        l_line_num,
        l_shipment_num,
        l_dist_num,
        l_quantity1,
        l_quantity2
    FROM   PO_LINES_ALL POL,PO_RELEASES_GT POR,PO_LINE_LOCATIONS_GT PLL
    WHERE  PLL.po_release_id = POR.po_release_id
    AND    PLL.po_release_id = p_document_id
    AND    POL.po_line_id  = PLL.po_line_id
    AND    POL.min_release_amount is not null
    AND    POL.min_release_amount >
           (   SELECT
                  decode ( sum ( decode ( PLL2.quantity                   /*Bug 5028960 pol.quantity */
                                         , NULL , PLL2.amount - nvl(PLL2.amount_cancelled,0)
                                         ,        PLL2.quantity - nvl(PLL2.quantity_cancelled,0)
                                         )
                                )
                          , 0 , POL.min_release_amount
                          ,     sum ( decode ( PLL2.quantity     /*Bug 5028960  pol.quantity */
                                             , NULL , PLL2.amount - nvl(PLL2.amount_cancelled,0)
                                             ,        (  ( PLL2.quantity - nvl(PLL2.quantity_cancelled,0) )
                                                      *  PLL2.price_override )
                                             )
                                    )
                          )
               --<Bug 2792477 mbhargav>
               --Change the table in from clause from PO_LINE_LOCATIONS to PO_LINE_LOCATIONS_GT
               FROM PO_LINE_LOCATIONS_GT PLL2
               WHERE PLL2.po_line_id = POL.po_line_id
               AND PLL2.po_release_id = POR.po_release_id
               AND PLL2.shipment_type in ('BLANKET', 'SCHEDULED')
          )
    GROUP BY POL.line_num,POL.min_release_amount;

    FOR i IN 1..l_line_num.COUNT LOOP
        l_rowCount(i) := i;
    END LOOP;

    FORALL i IN 1..l_line_num.COUNT
        INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
        VALUES(
            p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            0,0,0,
            p_sequence+l_rowCount(i),
            substr(l_textline||g_delim||l_quantity1(i),1,240),
            'PO_SUB_REL_SHIPAMT_LESS_MINREL');

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + l_line_num.COUNT;
----------------------------------------------

l_progress := '600';

-- Check 13: The Release GL date should be within an open purchasing period
-- PO_SUB_REL_INVALID_GL_DATE

--<FPJ ENCUMBRANCE>

IF (  PO_CORE_S.is_encumbrance_on(
         p_doc_type => g_document_type_RELEASE
      ,  p_org_id => NULL
      )
   )
THEN

   l_progress := '610';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(g_log_head || '.'||l_api_name||'.',
                          l_progress,'REL 13: GL date check ');
   END IF;

   check_gl_date(
      p_doc_type => g_document_type_RELEASE
   ,  p_online_report_id => p_online_report_id
   ,  p_login_id => p_login_id
   ,  p_user_id => p_user_id
   ,  p_sequence => p_sequence
   );

   l_progress := '620';

ELSE
   l_progress := '630';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(g_log_head || '.'||l_api_name||'.',
                          l_progress,'REL 13: release encumbrance not on');
   END IF;
END IF;

----------------------------------------------

l_progress := '014';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Rel 14: UOM Interclass conversions check');
   END IF;
END IF;

  -- Check 14: Invalid Interclass conversions between UOMs should not be allowed
    -- PO_SUB_UOM_CLASS_CONVERSION, PO_SUB_REL_INVALID_CLASS_CONV
    -- Message inserted is:
    --'Shipment# <ShipNum> Following Interclass UOM conversion is not defined or
    -- is disabled <UOM1> <UOM2>'
    --   Bug #1630662
  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_UOM_CLASS_CONVERSION');
    INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
            0,
            POLL.shipment_num,
            0,
            p_sequence + ROWNUM,
            substr(g_shipmsg||g_delim||POLL.shipment_num||g_delim||l_textline||
                   MTL1.uom_class||' , '||MTL2.uom_class,1,240),
            'PO_SUB_UOM_CLASS_CONVERSION'
    FROM MTL_UOM_CLASS_CONVERSIONS MOU, PO_LINE_LOCATIONS_GT POLL,
         PO_LINES POL, MTL_UOM_CLASSES_TL MTL1,
         MTL_UOM_CLASSES_TL MTL2
    WHERE MOU.inventory_item_id = POL.item_id
    AND   (NVL(MOU.disable_date, TRUNC(SYSDATE)) + 1) < TRUNC(SYSDATE)
    AND   POL.po_line_id = POLL.po_line_id
    AND   POLL.po_release_id = p_document_id
    AND   MOU.from_uom_class = MTL1.uom_class
    AND   MOU.to_uom_class = MTL2.uom_class
    AND EXISTS
       (SELECT 'uom conversion exists'
        FROM MTL_UNITS_OF_MEASURE MUM
        WHERE POL.unit_meas_lookup_code = MUM.unit_of_measure
        AND   MOU.to_uom_class = MUM.uom_class);

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

--------------------------------------------------

l_progress := '015';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 15: Item restricted check ');
   END IF;
END IF;

  -- Check 15:  If an item is restricted then the Purchase Order Vendor
    -- must be listed in the Approved Suppliers List table and must be approved.
    -- PO_SUB_ITEM_NOT_APPROVED_REL
    -- Bug# 2461828
    /*Bug5597639 Modifying the below sql to ensure that whenever the item
     is restricted by checking 'Use approved supplier list' there should be
     atlease one approved ASL either at item level or at category level
     if there is no item ASL*/

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_ITEM_NOT_APPROVED_REL');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        POL.line_num, --<Bug 3123365>
        PLL.shipment_num,  --<Bug 3123365>
        0,
        p_sequence + ROWNUM,
                    --<Bug 3123365 mbhargav START>
                    substr(g_linemsg||g_delim||POL.line_num||g_delim
                   ||g_shipmsg||g_delim||PLL.shipment_num||g_delim
                   ||l_textline,1,240),
                   --<Bug 3123365 mbhargav END>
            'PO_SUB_ITEM_NOT_APPROVED_REL'
    FROM MTL_SYSTEM_ITEMS MSI, PO_LINE_LOCATIONS_GT PLL,
         PO_RELEASES_GT POR,PO_LINES POL, PO_HEADERS_GT POH,
         FINANCIALS_SYSTEM_PARAMETERS FSP
    WHERE POR.po_release_id = p_document_id
    AND POR.po_header_id = POH.po_header_id
    AND POR.po_header_id = POL.po_header_id
    AND POL.po_line_id = PLL.po_line_id
    AND POR.po_release_id = PLL.po_release_id
    AND MSI.organization_id = PLL.SHIP_TO_ORGANIZATION_id
    AND MSI.inventory_item_id = POL.item_id
    AND POL.item_id is not null
    AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND nvl(POL.cancel_flag,'N') = 'N'
    AND nvl(PLL.cancel_flag,'N') = 'N'
    AND nvl(MSI.must_use_approved_vendor_flag,'N') = 'Y'
    AND not exists
       (SELECT 1
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR
        WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id, -1)
        AND    ASL.vendor_id = POH.vendor_id
        AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
        AND   ASL.item_id = POL.item_id
        AND    ASL.asl_status_id = ASR.status_id
        AND    ASR.business_rule = '1_PO_APPROVAL'
	AND    ASR.allow_action_flag = 'Y'        --Bug5597639
        UNION ALL
        SELECT 1
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR
        WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id , -1)
        AND    ASL.vendor_id = POH.vendor_id
        AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
        AND    ASL.item_id is NULL
        AND    not exists
           (SELECT ASL1.ASL_ID
            FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL1
            WHERE ASL1.ITEM_ID = POL.item_id
            AND ASL1.using_organization_id in (PLL.ship_to_organization_id, -1))
        AND    ASL.category_id in
           (SELECT MIC.category_id
            FROM   MTL_ITEM_CATEGORIES MIC
            WHERE MIC.inventory_item_id = POL.item_id
            AND MIC.organization_id = PLL.ship_to_organization_id)
        AND    ASL.asl_status_id = ASR.status_id
        AND    ASR.business_rule = '1_PO_APPROVAL'
        AND    ASR.allow_action_flag = 'Y') ;  --Bug5597639

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
---------------------------------------------

l_progress := '016';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 16: ASL Debarred check ');
   END IF;
END IF;

  -- Check 16: Determine if an item is restricted.  If it is restricted the
    -- Purchase Order Vendor must be listed in the Approved Suppliers
    -- List table and must be approved for release to get approved.
    -- Bug 839743
    -- PO_SUB_ITEM_ASL_DEBARRED_REL

      /*Bug5597639 This check would throw an error message if atleast one ASL
       entry is debarred either for item /Category irrespective of 'Use approved
       supplier flag'. This check would apply even for one time items.
       If supplier is debarred in any of the ASL item/category (Global/Local)
       (Suplier/Supplier+site) then the approval of the PO will not be allowed
       Need to remove the join with mtl_item_categories for one
       time items as there will not be any record
 */

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_ITEM_ASL_DEBARRED_REL');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
                    POL.line_num, --<Bug 3123365>
                    PLL.shipment_num,  --<Bug 3123365>
                    0,
                    p_sequence + ROWNUM,
                    --<Bug 3123365 mbhargav START>
                    substr(g_linemsg||g_delim||POL.line_num||g_delim
                   ||g_shipmsg||g_delim||PLL.shipment_num||g_delim
                   ||l_textline,1,240),
                   --<Bug 3123365 mbhargav END>
            'PO_SUB_ITEM_ASL_DEBARRED_REL'
    FROM PO_LINE_LOCATIONS_GT PLL,
         PO_RELEASES_GT POR,PO_LINES POL, PO_HEADERS_GT POH,
         FINANCIALS_SYSTEM_PARAMETERS FSP
    WHERE POR.po_release_id = p_document_id
    AND POR.po_header_id = POH.po_header_id
    AND POR.po_header_id = POL.po_header_id
    AND POL.po_line_id = PLL.po_line_id
    AND POR.po_release_id = PLL.po_release_id
    AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND nvl(POL.cancel_flag,'N') = 'N'
    AND nvl(PLL.cancel_flag,'N') = 'N'
    AND exists
      (SELECT 1
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR,
	 MTL_SYSTEM_ITEMS MSI  --Bug5597639
         WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id, -1)
        /*Bug5553138 Adding the below three conditions */
	AND MSI.organization_id = FSP.inventory_organization_id
	AND MSI.inventory_item_id = POL.item_id
	AND  POL.item_id is not null
        AND    ASL.vendor_id = POH.vendor_id
        AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
        AND   ASL.item_id = POL.item_id
        AND    ASL.asl_status_id = ASR.status_id
        AND    ASR.business_rule = '1_PO_APPROVAL'
 	AND   ASR.allow_action_flag <> 'Y'   --Bug5597639
        UNION ALL
         SELECT 1
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR
        WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id , -1)
        AND    ASL.vendor_id = POH.vendor_id
        AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
        AND    ASL.item_id is NULL
	AND ASL.category_id = POL.category_id --Bug5597639
        AND    ASL.asl_status_id = ASR.status_id
        AND    ASR.business_rule = '1_PO_APPROVAL'
        AND    ASR.allow_action_flag <> 'Y' );  --Bug5597639
     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
-------------------------------------------------------------------------

 l_progress := '017';

    IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                       l_api_name||'.' || l_progress,
                       'REL 17: ATO/CTO Model items not allowed on Releases');
        END IF;
    END IF;

    -- Check 17: ATO/CTO Model items not allowed on Releases (Bug 3362369)

    l_textline := FND_MESSAGE.get_string('PO', 'PO_ATO_ITEM_NA');

    INSERT INTO po_online_report_text_gt(
       online_report_id,
       last_update_login,
       last_updated_by,
       last_update_date,
       created_by,
       creation_date,
       line_num,
       shipment_num,
       distribution_num,
       sequence,
       text_line,
       message_name
    )
   SELECT   p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
                    POL.line_num,
                    PLL.shipment_num,
                    0,
                    p_sequence + ROWNUM,
                    substr(g_linemsg||g_delim||POL.line_num||g_delim
                   ||g_shipmsg||g_delim||PLL.shipment_num||g_delim
                   ||l_textline,1,240),
           'PO_ATO_ITEM_NA'
    FROM   po_lines POL,
           po_line_locations_gt PLL,
           financials_system_parameters FSP,
           mtl_system_items MSI
    WHERE  PLL.po_release_id = p_document_id
    AND    PLL.po_line_id = POL.po_line_id
    AND    POL.item_id is not null
    AND    nvl(POL.cancel_flag, 'N') = 'N'                     --Bug5353423
    AND    nvl(POL.closed_code, 'OPEN') <> 'FINALLY CLOSED'    --Bug5353423
	AND    nvl(PLL.cancel_flag, 'N') = 'N'                     --Bug#17364060
	AND    nvl(PLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'    --Bug#17364060
	AND    nvl(PLL.approved_flag, 'N')  <> 'Y'                 --Bug#17364060
    AND    POL.item_id = MSI.inventory_item_id
    AND    MSI.organization_id = FSP.inventory_organization_id
    AND    MSI.bom_item_type in (1,2);

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
--------------------------------------------------------------------


 /* Start Bug #3512688
    To check the validity of the item added at the line level*/
      l_progress := '018';
      IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
       || l_progress,'REL 018: Item has to purchasable');
      END IF;
       END IF;

       -- Check 018: Item has to purchasable

       l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_ALL_NO_ITEM');
       INSERT INTO po_online_report_text_gt(online_report_id,
       last_update_login,
       last_updated_by,
       last_update_date,
       created_by,
       creation_date,
       line_num,
       shipment_num,
       distribution_num,
       sequence,
       text_line,
       message_name)
       SELECT  p_online_report_id,
       p_login_id,
       p_user_id,
       sysdate,
       p_user_id,
       sysdate,
       0,
       pll.shipment_num,
       0,
       p_sequence + ROWNUM,
        substr(g_shipmsg||g_delim||pll.shipment_num||g_delim||l_textline,1,240),
       'PO_ALL_NO_ITEM'
       from po_releases_gt por,po_lines pl,po_line_locations_gt pll,mtl_system_items  itm,po_line_types_b plt
       where itm.inventory_item_id  = pl.item_id
       and   pl.item_id is not null

      and   pl.po_line_id   = pll.po_line_id
       and   itm.organization_id    = pll.ship_to_organization_id
       and   itm.purchasing_enabled_flag = 'N'
       and   pll.po_release_id   = por.po_release_id
       and   por.po_release_id = p_document_id
       and   pll.po_release_id is not null
       and   pl.line_type_id = plt.line_type_id
       and   nvl(plt.outside_operation_flag,'N')=nvl(itm.outside_operation_flag,'N')
       and   (pll.creation_date >= nvl(por.approved_date,pll.creation_date));

       --Increment the p_sequence with number of errors reported in last query
       p_sequence := p_sequence + SQL%ROWCOUNT;
     --End Bug #3512688

l_progress := '019';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Rel 19: Cannot approve documents on hold');
   END IF;
END IF;
    -- Check 19: Release should not be on hold (Bug 3678912)
        -- PO_ON_HOLD_CANNOT_APPROVE

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_ON_HOLD_CANNOT_APPROVE');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
                  sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
                   'PO_ON_HOLD_CANNOT_APPROVE'
    FROM  PO_RELEASES_GT POR
    WHERE  POR.po_release_id = p_document_id
    AND    nvl(POR.HOLD_FLAG,'N') = 'Y';

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

    l_progress := '020';

---------------------------------------------------------------------------------
-- bug 6530879 Releases <Start>
select poh.po_header_id,poh.vendor_id, poh.vendor_site_id, poh.vendor_contact_id
  into l_agreement_id, l_vendor_id,l_vendor_site_id,l_vendor_contact_id
  from po_headers_gt poh, po_releases_gt por
  where poh.po_header_id = por.po_header_id
    and por.po_release_id = p_document_id;
-- bug 6530879
-- Check 20: Vendor should be valid when approving the document.
-- Important for reapproval, to avoid the case when the vendor has
-- been invalidated by first successful approval.

l_textline :=  FND_MESSAGE.GET_STRING('PO', 'PO_PDOI_INVALID_VENDOR');
---------------------------------------------------------------------------
  if (l_vendor_id is NOT NULL) then
	fnd_message.set_name('PO', 'PO_PDOI_INVALID_VENDOR');
        fnd_message.set_token('VALUE', to_char(l_vendor_id), FALSE);
	l_textline := substr(fnd_message.get, 1, 240);


 	INSERT INTO po_online_report_text_gt(online_report_id,
 				last_update_login,
 				last_updated_by,
 				last_update_date,
 				created_by,
 				creation_date,
 				line_num,
 				shipment_num,
 				distribution_num,
 				sequence,
 				text_line,
                                message_name)
 	SELECT 	p_online_report_id,
 		    p_login_id,
 		    p_user_id,
     	            sysdate,
 		    p_user_id,
 		    sysdate,
 		    0,
 		    0,
 		    0,
 		    p_sequence + ROWNUM,
 		    substr(l_textline,1,240),
                   'PO_PDOI_INVALID_VENDOR'
	FROM  dual
    where not exists (select 'Y'
			from PO_HEADERS_GT POH, po_vendors pov
		       WHERE  POH.po_header_id = l_agreement_id
		         AND  pov.vendor_id = poh.vendor_id
			 AND  pov.enabled_flag = 'Y'
			 AND  SYSDATE BETWEEN nvl(pov.start_date_active, SYSDATE-1)
                                  AND nvl(pov.end_date_active, SYSDATE+1));
 --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;

 end if;

-------------------------------------------------------------------------------------
-- Check 21: check the validity of the vendor site.
 if (l_vendor_site_id is not null) then

  	fnd_message.set_name('PO', 'PO_PDOI_INVALID_VENDOR_SITE');
 	fnd_message.set_token('VALUE', to_char(l_vendor_site_id), FALSE);
	l_textline := substr(fnd_message.get, 1, 240);

 	INSERT INTO po_online_report_text_gt(online_report_id,
 				last_update_login,
 				last_updated_by,
 				last_update_date,
 				created_by,
 				creation_date,
 				line_num,
 				shipment_num,
 				distribution_num,
 				sequence,
 				text_line,
                                message_name)
 	SELECT 	p_online_report_id,
 		    p_login_id,
 		    p_user_id,
     	            sysdate,
 		    p_user_id,
 		    sysdate,
 		    0,
 		    0,
 		    0,
 		    p_sequence + ROWNUM,
 		    substr(l_textline,1,240),
                   'PO_PDOI_INVALID_VENDOR_SITE'
    FROM  dual
    where not exists (select 'Y'
			from PO_HEADERS_GT POH, po_vendor_sites povs
		        WHERE  POH.po_header_id = l_agreement_id
		        AND  povs.vendor_site_id = poh.vendor_site_id
			AND    nvl(povs.rfq_only_site_flag,'N') <> 'Y'
			AND    povs.purchasing_site_flag = 'Y'
		        AND    SYSDATE < nvl(povs.inactive_date, SYSDATE + 1));
 --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;
end if;

-------------------------------------------------------------------------------------
-- check 22: validate vendor contact
if (l_vendor_contact_id is not null) then

	fnd_message.set_name('PO', 'PO_PDOI_INVALID_VDR_CNTCT');
 	fnd_message.set_token('VALUE', to_char(l_vendor_contact_id), FALSE);
	l_textline := substr(fnd_message.get, 1, 240);

	INSERT INTO po_online_report_text_gt(online_report_id,
 				last_update_login,
 				last_updated_by,
 				last_update_date,
 				created_by,
 				creation_date,
 				line_num,
 				shipment_num,
 				distribution_num,
 				sequence,
 				text_line,
                                message_name)
 	SELECT 	p_online_report_id,
 		    p_login_id,
 		    p_user_id,
     	            sysdate,
 		    p_user_id,
 		    sysdate,
 		    0,
 		    0,
 		    0,
 		    p_sequence + ROWNUM,
 		    substr(l_textline,1,240),
                   'PO_PDOI_INVALID_VDR_CNTCT'
	FROM  dual
	--Start of code changes for the bug 16244229
	WHERE NOT EXISTS ( SELECT  'Y'
			FROM
			AP_SUPPLIER_CONTACTS PVC ,
			HZ_PARTIES HP ,
			HZ_RELATIONSHIPS HPR ,
			HZ_PARTY_SITES HPS ,
			HZ_ORG_CONTACTS HOC ,
			HZ_PARTIES HP2 ,
			AP_SUPPLIERS APS,
			PO_HEADERS_ALL POH
			WHERE PVC.PER_PARTY_ID = HP.PARTY_ID
			AND PVC.REL_PARTY_ID   = HP2.PARTY_ID
			AND PVC.ORG_CONTACT_ID                           = HOC.ORG_CONTACT_ID(+)
			AND PVC.RELATIONSHIP_ID                          = HPR.RELATIONSHIP_ID
			AND HPR.DIRECTIONAL_FLAG                         ='F'
			AND NVL( APS.VENDOR_TYPE_LOOKUP_CODE, 'DUMMY' ) <> 'EMPLOYEE'
			AND ( (Pvc.Party_Site_Id  = Hps.Party_Site_Id
				AND SYSDATE < nvl( LEAST(NVL(HPR.END_DATE, TO_DATE('12/31/4712','MM/DD/RRRR')), NVL(PVC.INACTIVE_DATE, TO_DATE('12/31/4712','MM/DD/RRRR'))), SYSDATE+1)
				AND EXISTS (SELECT 1 FROM AP_SUPPLIER_SITES_ALL PVS   -- bug#19560839 FIX
                            WHERE PVS.PARTY_SITE_ID  = PVC.ORG_PARTY_SITE_ID
				               AND PVS.VENDOR_ID     = APS.VENDOR_ID))
			OR (PVC.ORG_PARTY_SITE_ID                       IS NULL
				AND PVC.VENDOR_SITE_ID                          IS NULL
				AND HPR.OBJECT_ID                                = APS.PARTY_ID
				AND HPR.RELATIONSHIP_CODE                        = 'CONTACT_OF'
				And Hpr.Object_Type                              = 'ORGANIZATION'
				AND SYSDATE < NVL(HPR.END_DATE, SYSDATE+1) )
			)
			AND POH.VENDOR_CONTACT_ID = PVC.VENDOR_CONTACT_ID
			AND POH.PO_HEADER_ID=l_agreement_id);
	--End of code changes for the bug 16244229

   --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;
end if;

-- bug 6530879 Releases <END>


--<R12 eTax Integration Start>
-----------------------------------------------------------------------------

    l_tax_status := po_tax_interface_pvt.calculate_tax_yes_no(p_po_header_id  => NULL,
                                                              p_po_release_id => p_document_id,
                                                              p_req_header_id => NULL);
    l_progress := '021';
    IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head ||l_api_name||'.'
                        || l_progress, 'Rel 21: Recalculate tax before approval = ' || l_tax_status);
        END IF;
    END IF;

    IF l_tax_status = 'Y' THEN
      IF g_debug_stmt THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                         l_api_name||'.' || l_progress,
                         'Rel 22: Calculate tax as the current one is not correct');
          END IF;
      END IF;
      l_progress := '021';
      po_tax_interface_pvt.calculate_tax( x_return_status    => l_return_status,
                                          p_po_header_id     => NULL,
                                          p_po_release_id    => p_document_id,
                                          p_calling_program  => g_action_DOC_SUBMISSION_CHECK);
      l_progress := '022';
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         IF g_debug_stmt THEN
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                            l_api_name||'.' || l_progress,
                            'Rel 23: Calculate tax has errored out');
             END IF;
         END IF;
         l_progress := '023';

         l_tax_message := fnd_message.get_string('PO','PO_TAX_CALCULATION')||' : ' ;

         FOR i IN 1..po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT.COUNT
	LOOP
           INSERT INTO po_online_report_text_gt
           (
            online_report_id,
            last_update_login,
            last_updated_by,
            last_update_date,
            created_by,
            creation_date,
            line_num,
            shipment_num,
            distribution_num,
            sequence,
            text_line,
            message_name,
            message_type
           )
           VALUES
           (
             p_online_report_id,
             p_login_id,
             p_user_id,
             sysdate,
             p_user_id,
             sysdate,
             po_tax_interface_pvt.G_TAX_ERRORS_TBL.line_num(i),
             po_tax_interface_pvt.G_TAX_ERRORS_TBL.shipment_num(i),
             po_tax_interface_pvt.G_TAX_ERRORS_TBL.distribution_num(i),
             p_sequence + i, /* 11851142 replaced rownum with i */
             l_tax_message || po_tax_interface_pvt.G_TAX_ERRORS_TBL.message_text(i),
             'PO_TAX_CALCULATION_FAILED',
             'E'
           );
	END LOOP;
         l_progress := '024';
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF g_debug_stmt THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                            l_api_name||'.' || l_progress,
                            'Rel 24: Calculate tax raised unexpected error');
           END IF;
        END IF;
        l_textline := l_progress ||' - ';
        IF po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT.COUNT > 0 THEN
          l_textline := l_textline || po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT(1);
        ELSE
          l_textline := l_textline || SQLERRM();
        END IF;
        fnd_message.set_name('PO','PO_TAX_CALC_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR',l_textline);
        FND_MSG_PUB.Add;
        l_progress := '025';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    p_sequence := p_sequence + SQL%ROWCOUNT;

-----------------------------------------------------------------------------

    l_progress := '026';
--<R12 eTax Integration End>

IF g_debug_stmt THEN
    	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
         		       || l_progress,'Rel 25: LCM enabled release shipment should have invoice match option as receipt');
   	END IF;
    END IF;
    -- Check 25: Validation for LCM enabled release to check whether its shipment has invoice match option as 'Receipt'
    l_textline := FND_MESSAGE.GET_STRING('PO','PO_SUB_REL_SHIP_INV_MATCH_NE_R');
    INSERT INTO po_online_report_text_gt (online_report_id,
	 				  last_update_login,
	 				  last_updated_by,
	 				  last_update_date,
	 				  created_by,
	 				  creation_date,
	 				  line_num,
	 				  shipment_num,
	 				  distribution_num,
	 				  sequence,
	 				  text_line,
	                                  message_name)
    SELECT p_online_report_id,
	   p_login_id,
	   p_user_id,
	   sysdate,
	   p_user_id,
	   sysdate,
	   0,
	   PLL.shipment_num,
           0,
	   p_sequence + ROWNUM,
	   substr (g_shipmsg||g_delim||PLL.shipment_num||g_delim||l_textline,1,240),
	   'PO_SUB_REL_SHIP_INV_MATCH_NE_R'
      FROM PO_RELEASES_GT POR,
           PO_LINE_LOCATIONS_GT PLL
     WHERE POR.po_release_id = PLL.po_release_id
       AND POR.po_release_id = p_document_id
       AND Nvl(PLL.LCM_FLAG,'N') = 'Y'
       AND Nvl(PLL.match_option,'P') <> 'R'
       AND Nvl(PLL.cancel_flag,'N') = 'N'; -- Bug 13809830: Added a condition to skip the submission check for cancelled shipments

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

    -------------------------------------------------------------------------------------
    l_progress := '027';
    IF g_debug_stmt THEN
    	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
         		       || l_progress,'Rel 26: LCM enabled release distribution should have destination type as Inventory');
   	END IF;
    END IF;
    -- Check 26: Validation for LCM enabled release to check whether its distribution has destination type as 'Inventory'
    l_textline := FND_MESSAGE.GET_STRING('PO','PO_SUB_REL_DIST_DEST_TYPE_NE_I');
    INSERT INTO po_online_report_text_gt (online_report_id,
	 				  last_update_login,
	 				  last_updated_by,
	 				  last_update_date,
	 				  created_by,
	 				  creation_date,
	 				  line_num,
	 				  shipment_num,
	 				  distribution_num,
	 				  sequence,
	 				  text_line,
	                                  message_name)
    SELECT p_online_report_id,
	   p_login_id,
	   p_user_id,
	   sysdate,
	   p_user_id,
	   sysdate,
	   0,
	   PLL.shipment_num,
	   POD.distribution_num,
	   p_sequence + ROWNUM,
	   substr (g_shipmsg||g_delim||PLL.shipment_num||g_delim||g_distmsg||g_delim||
                   POD.distribution_num||g_delim||l_textline, 1,240),
	   'PO_SUB_REL_DIST_DEST_TYPE_NE_I'
      FROM PO_RELEASES_GT POR,
           PO_LINE_LOCATIONS_GT PLL,
           PO_DISTRIBUTIONS_GT POD
     WHERE POR.po_release_id = POD.po_release_id
       AND POD.line_location_id = PLL.line_location_id
       AND POR.po_release_id = p_document_id
       AND Nvl(POD.LCM_FLAG,'N') = 'Y'
       AND POD.DESTINATION_TYPE_CODE <> 'INVENTORY';

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
    ----------------------------------------------------------------------------------------
 l_progress := '028';
 --<Bug 9040655 START Buyer should not inactive on the document>
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Rel 27: Cannot approve documents with invalid buyer');
   END IF;
END IF;
    -- Check 27: Buyer on the reelase should not be inactive
        -- PO_BUYER_INACTIVE

  l_textline := substr(FND_MESSAGE.GET_STRING('PO', 'PO_BUYER_INACTIVE'),1,240);
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
                  sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        l_textline,
                   'PO_BUYER_INACTIVE'
    FROM  dual
    where not exists (select 'inactive buyer'
                      from PO_RELEASES_GT POR,
                           PO_BUYERS_V POB -- <Bug 11682620> Replace PO_BUYERS_VAL_V with PO_BUYERS_V
		      where por.agent_id = pob.employee_id);

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
 --<Bug 9040655 END>

    -- Bug 17703679 start: add submission check to Validate Sponsored Project - Award Reference
    -- should not be provided for EIB Items when "Grants" is enabled.
    l_progress := '029';
	IF g_debug_stmt THEN
	   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
			  || l_progress,'PO 28: Validate Sponsored Project - Award Reference should not
        be provided for EIB Items when "Grants" is enabled.');
	   END IF;
	END IF;

	-- Check 28: Validate Sponsored Project - Award Reference should not be
  -- provided for EIB Items when "Grants" is enabled.
	l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_EIB_ITEM_NO_AWARD');
    INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
    SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        POLL.shipment_num,
        POD.distribution_num,
        p_sequence + ROWNUM,
        substr(g_shipmsg||g_delim||POLL.shipment_num||g_delim
                   ||g_distmsg||g_delim||POD.distribution_num||g_delim
                   ||l_textline,1,240),
            'PO_EIB_ITEM_NO_AWARD'
    FROM PO_DISTRIBUTIONS_GT POD,
         PO_LINE_LOCATIONS_GT POLL,
         PO_LINES POL,
         PO_RELEASES_GT POR,
        MTL_SYSTEM_ITEMS MSI
    WHERE POLL.po_release_id = POR.po_release_id
    AND POD.line_location_id = POLL.line_location_id
    AND POLL.po_line_id = POL.po_line_id
    AND POR.po_release_id = p_document_id
    AND MSI.inventory_item_id = POL.item_id
    AND MSI.organization_id = POLL.ship_to_organization_id
    AND nvl(MSI.comms_nl_trackable_flag, 'N') = 'Y'
    AND POD.AWARD_ID is not NULL;

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
	  -- Bug 17703679 end
------------------------------------------------------------------------------------

    -- Bug 13527787 start: Check MATCHING_BASIS on Line/Shipment is NULL or not
    l_progress := '030';
    IF g_debug_stmt THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 29: Check MATCHING_BASIS on Line/Shipment is NULL or not');
       END IF;
    END IF;

    l_textline := FND_MESSAGE.GET_STRING('PO','PO_MATCHING_BASIS_NULL');
    INSERT INTO po_online_report_text_gt (online_report_id,
                       last_update_login,
                       last_updated_by,
                       last_update_date,
                       created_by,
                       creation_date,
                       line_num,
                       shipment_num,
                       distribution_num,
                       sequence,
                       text_line,
                       message_name)
    SELECT p_online_report_id,
       p_login_id,
       p_user_id,
       sysdate,
       p_user_id,
       sysdate,
       0,
       PLL.shipment_num,
       0,
       p_sequence + ROWNUM,
       substr(g_shipmsg||g_delim||PLL.shipment_num||g_delim||l_textline,1,240),
              'PO_MATCHING_BASIS_NULL'
     FROM PO_LINE_LOCATIONS PLL
      WHERE PLL.po_release_id = p_document_id
      AND nvl(PLL.cancel_flag, 'N')     = 'N'
      AND nvl(PLL.consigned_flag , 'N') <> 'Y'
      AND nvl(PLL.closed_code, 'OPEN') NOT IN ('CLOSED FOR INVOICE', 'CLOSED', 'FINALLY CLOSED')
      AND PLL.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
      AND PLL.matching_basis IS NULL;

      --Increment the p_sequence with number of errors reported in last query
      p_sequence := p_sequence + SQL%ROWCOUNT;
      -- Bug 13527787 end
------------------------------------------------------------------------------------


    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;
END CHECK_RELEASES;

--For RELEASES, PO
/**
* Private Procedure: CHECK_PO_REL_REQPRICE
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure runs the document submission checks for PO and
*           RELEASES. This procedure compares the price of the PO or Release
*           Shipment to the price of the Requisition Line. The Shipment
*           Price should be within the tolerance of the Requisition Line
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*/
PROCEDURE check_po_rel_reqprice(p_document_type IN VARCHAR2,
                       p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_textline  po_online_report_text.text_line%TYPE := NULL;
l_api_name  CONSTANT varchar2(40) := 'CHECK_PO_REL_REQPRICE';
l_progress VARCHAR2(3);

l_enforce_price_tolerance po_system_parameters.enforce_price_change_allowance%TYPE;
l_enforce_price_amount  po_system_parameters.enforce_price_change_amount%TYPE;
l_amount_tolerance po_system_parameters.price_change_amount%TYPE;

TYPE unit_of_measure IS TABLE of PO_LINES.unit_meas_lookup_code%TYPE;
TYPE NumTab IS TABLE of NUMBER;
l_ship_price_in_base_curr NumTab;
l_ship_unit_of_measure unit_of_measure;
l_ship_num NumTab;
l_line_num NumTab;
l_quantity NumTab;
l_item_id NumTab;
l_line_location_id NumTab;
l_exchange_rate NumTab; -- bug 20098125

--For Req Cursor
l_req_unit_of_measure unit_of_measure;
l_req_line_unit_price NumTab;
l_po_req_line_num NumTab;
l_po_req_ship_num NumTab;
l_po_req_quantity NumTab;

l_ship_price_ext_precn NUMBER;
l_shipment_to_req_rate NUMBER := 0;
l_price_tolerance_allowed NUMBER := 0;

--<Bug 3266272 mbhargav START>
l_pou_func_curr                FND_CURRENCIES.currency_code%TYPE;
l_pou_func_curr_ext_precn      FND_CURRENCIES.extended_precision%TYPE;
l_po_curr                      FND_CURRENCIES.currency_code%TYPE;
l_req_ou_func_curr             FND_CURRENCIES.currency_code%TYPE;
l_rate_date                    DATE;
l_rate                         NUMBER;
l_rate_type                    PO_SYSTEM_PARAMETERS_ALL.default_rate_type%TYPE;
l_requesting_org_id            NumTab;
l_display_rate                 NUMBER;
l_return_status                VARCHAR2(1);
l_error_message_name           FND_NEW_MESSAGES.message_name%TYPE;
l_req_line_price_pou_base_curr PO_REQUISITION_LINES_ALL.unit_price%TYPE;
l_req_line_price_ext_precn     PO_REQUISITION_LINES_ALL.unit_price%TYPE;
--<Bug 3266272 mbhargav END>

l_is_complex_po BOOLEAN := FALSE; --<Complex Work R12>
-- Start of Bug# 13857241
TYPE CurrencyTab IS TABLE of   FND_CURRENCIES.CURRENCY_CODE%TYPE;
l_is_same_foreign_currency     VARCHAR2(1);
l_req_line_curr_unit_price     NumTab;
l_req_line_curr_code           CurrencyTab;
l_po_line_type		       PO_LINES_ALL.ORDER_TYPE_LOOKUP_CODE%TYPE;
-- End of Bug# 13857241
/*
** Setup the PO select cursor
** Select shipment price and convert it to base currency.
** this is done by taking the distribution rate and applying
** it evenly over all distributions.  Additionally get the
** shipment unit of measure, quantity, and item_id to be
** passed to the UomC function.
*/

/*Bug4302950 :The shipments were updated with wrong price when supplier submits
change request from ISP to split shipment quantity between two individual shipments.
As the ISP doesnot handle change in distributions,replacing the shipments
quantity with the sum of the distributions quantity in the calculation
of price override so that the shipment price will reflect the correct value.*/

CURSOR po_shipment_cursor (p_document_id NUMBER) IS
    SELECT nvl(max(POLL.price_override ) *
        sum(decode(plt.order_type_lookup_code,'AMOUNT',1,nvl(POD.rate,1))*
                  (POD.quantity_ordered -
                   nvl(POD.quantity_cancelled, 0))) /
            /*	 (max(POLL.quantity) -
		 nvl(max(POLL.quantity_cancelled),0)), -1) Price, */ --Bug4302950
		  --Bug16222308 Handling the quantity zero on distribution
                decode(
				  (sum(POD.quantity_ordered -
                  nvl(POD.quantity_cancelled,0))),0,1,(sum(POD.quantity_ordered -
                  nvl(POD.quantity_cancelled,0))) )
				  , -1) Price,
        POL.unit_meas_lookup_code uom,
        nvl(POLL.shipment_num,0) ship_num,
        nvl(POL.line_num,0) line_num,
        nvl(POLL.quantity,0) quantity,
        nvl(POL.item_id,-1) item_id,
        nvl( POLL.line_location_id,0) line_loc_id,
	nvl(pod.rate,1) exchange_rate --bug 20098125
    FROM   PO_LINE_LOCATIONS_GT POLL,
        PO_LINE_TYPES_B PLT,            -- bug3413891
        PO_LINES_GT POL,
        PO_DISTRIBUTIONS_GT POD
     WHERE  POLL.po_line_id    = POL.po_line_id
     AND    POLL.line_location_id = POD.line_location_id
     AND    POLL.po_header_id = p_document_id
     AND    POL.line_type_id = PLT.line_type_id
     AND    nvl(POLL.cancel_flag,'N') <> 'Y'
     AND    nvl(POLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
     AND    POLL.shipment_type in ('PLANNED', 'STANDARD')
     GROUP BY POL.unit_meas_lookup_code, nvl(POLL.shipment_num,0),
              nvl(POL.line_num,0), nvl(POLL.quantity,0),
              nvl(POL.item_id,-1), POLL.price_override,
              nvl(POLL.line_location_id,0),
              nvl(pod.rate,1); --bug 20098125

-- <Complex Work R12 START>
/* Setup the Complex Work PO select cursor
** Select Complex Work PO Line information and the
** line loc ID for the first STANDARD pay item for
** that line
*/
CURSOR po_pay_item_cursor (p_document_id NUMBER) IS
    SELECT (POL.unit_price
              *  (sum(POD.rate
                   * (POD.quantity_ordered - nvl(POD.quantity_cancelled,0)) ))
              / POLL.quantity - nvl(POLL.quantity_cancelled, 0)
            ) price,
        POL.unit_meas_lookup_code uom,
        POLL.shipment_num ship_num,
        POL.line_num line_num,
        POL.quantity quantity,
        nvl(POL.item_id,-1) item_id,
        POLL.line_location_id line_loc_id,
	nvl(pod.rate,1) exchange_rate --bug 20098125
    FROM   PO_LINE_LOCATIONS_GT POLL,
        PO_LINES_GT POL,
        PO_DISTRIBUTIONS_GT POD
    WHERE POL.po_header_id = p_document_id
    AND   POD.line_location_id = POLL.line_location_id
    AND   POLL.line_location_id =
           (SELECT min(POLL2.line_location_id)
            FROM PO_LINE_LOCATIONS_GT POLL2
            WHERE POLL2.po_line_id = POL.po_line_id
            AND POLL2.shipment_type = 'STANDARD'
           )
    GROUP BY POL.unit_price, POLL.quantity, nvl(POLL.quantity_cancelled, 0),
             POL.unit_meas_lookup_code,
             POLL.shipment_num,
             POL.line_num,
             POL.quantity,
             nvl(POL.item_id,-1),
             POLL.line_location_id,
             nvl(pod.rate,1); --bug 20098125
-- <Complex Work R12 END>


/*
** Setup the Release select cursor
** Select shipment price and convert it to base currency.
** this is done by taking the distribution rate and applying
** it evenly over all distributions.  Additionally get the
** shipment unit of measure, quantity, and item_id to be
** passed to the UomC function.  Get the shipment_num and
** line_num to be passed to the pooinsingle function.
*/
CURSOR rel_shipment_cursor (p_document_id NUMBER) IS
    SELECT /*+ FULL(POLL) */                          -- bug3413891
        nvl(max(POLL.price_override) *
        sum(decode(plt.order_type_lookup_code,'AMOUNT',1,nvl(POD.rate,1))*
                  (POD.quantity_ordered -
                   nvl(POD.quantity_cancelled, 0))) /
            /*	 (max(POLL.quantity) -
		 nvl(max(POLL.quantity_cancelled),0)), -1) Price, */ --Bug4302950
		 --Bug16222308 Handling the quantity zero on distribution
                decode( (sum(POD.quantity_ordered -
                 nvl(POD.quantity_cancelled,0))),0,1,(sum(POD.quantity_ordered -
                 nvl(POD.quantity_cancelled,0))) )
				 , -1) Price,
        POL.unit_meas_lookup_code uom,
        nvl(POLL.shipment_num,0) ship_num,
        nvl(POL.line_num,0) line_num,
        nvl(POLL.quantity,0) quantity,
        nvl(POL.item_id,0) item_id,
        nvl( POLL.line_location_id,0) line_loc_id,
	nvl(pod.rate,1) exchange_rate --bug 20098125
    FROM   PO_LINE_LOCATIONS_GT POLL,
        PO_LINE_TYPES_B PLT,                          -- bug3413891
        PO_LINES POL,
        PO_DISTRIBUTIONS_GT POD                       -- <PO_CHANGE_API FPJ>
    WHERE  POLL.po_line_id    = POL.po_line_id
     AND    POLL.line_location_id = POD.line_location_id
     AND    POLL.po_release_id = p_document_id
     AND    POL.line_type_id = PLT.line_type_id
     AND    nvl(POLL.cancel_flag,'N') <> 'Y'
     AND    nvl(POLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    GROUP BY POL.unit_meas_lookup_code, nvl(POLL.shipment_num,0),
              nvl(POL.line_num,0), nvl(POLL.quantity,0),
              nvl(POL.item_id,0), POLL.price_override,
              nvl(POLL.line_location_id,0),
              nvl(pod.rate,1); --bug 20098125

 CURSOR req_price_tol_cursor(p_line_location_id  NUMBER) IS
         SELECT min(PRL.unit_price),
                PRL.unit_meas_lookup_code,
                min(POL.line_num),
                min(POLL.shipment_num),
                min(PRL.org_id)               --<Bug 3266272>
         FROM   PO_REQUISITION_LINES_ALL PRL, --<Bug 3266272>
                PO_LINE_LOCATIONS_GT POLL,
                PO_LINES          POL
         WHERE  PRL.line_location_id  = POLL.line_location_id
         AND    POLL.line_location_id = p_line_location_id
         AND    PRL.unit_price        >= 0
         AND    POLL.po_line_id       = POL.po_line_id
         GROUP BY PRL.unit_meas_LOOKUP_code;

-- Start of Bug# 1385724
CURSOR req_price_tol_cursor_req_cur(p_line_location_id NUMBER)
  IS
          SELECT   MIN(PRL.currency_unit_price),
                   MIN(PRL.currency_code),
                   PRL.unit_meas_lookup_code,
                   MIN(POL.line_num)        ,
                   MIN(POLL.shipment_num)   ,
                   MIN(PRL.org_id)               --<Bug 3266272>
          FROM     PO_REQUISITION_LINES_ALL PRL, --<Bug 3266272>
                   PO_LINE_LOCATIONS_GT POLL   ,
                   PO_LINES POL
          WHERE    PRL.line_location_id  = POLL.line_location_id
               AND POLL.line_location_id = p_line_location_id
               AND PRL.unit_price       >= 0
               AND POLL.po_line_id       = POL.po_line_id
          GROUP BY PRL.unit_meas_LOOKUP_code;
-- End of Bug# 13857241
CURSOR req_price_amt_cursor(p_line_location_id  NUMBER) IS
         SELECT min(PRL.unit_price),
                 PRL.unit_meas_lookup_code,
                 sum(PD.quantity_ordered),
                 min(POL.line_num),
                 min(POLL.shipment_num),
                 min(PRL.org_id)              --<Bug 3266272>
         FROM   PO_REQUISITION_LINES_ALL PRL, --<Bug 3266272>
                 PO_LINE_LOCATIONS_GT POLL,
                 PO_LINES          POL,
                 PO_DISTRIBUTIONS  PD,
                 PO_REQ_DISTRIBUTIONS_ALL PRD --<Bug 3266272>
         WHERE  POLL.line_location_id = p_line_location_id
          AND    POLL.po_line_id = POL.po_line_id
          AND    PRL.unit_price >= 0
          AND    POLL.line_location_id = PD.line_location_id
          AND    PD.req_distribution_id = PRD.distribution_id
          AND    PRD.requisition_line_id = PRL.requisition_line_id
         GROUP BY PRL.requisition_line_id, PRL.unit_meas_lookup_code;

-- Start of Bug# 1385724
CURSOR req_price_amt_cursor_req_curr(p_line_location_id  NUMBER) IS
         SELECT  min(PRL.currency_unit_price),
                 min(PRL.currency_code),
                 PRL.unit_meas_lookup_code,
                 sum(PD.quantity_ordered),
                 min(POL.line_num),
                 min(POLL.shipment_num),
                 min(PRL.org_id)              --<Bug 3266272>
         FROM   PO_REQUISITION_LINES_ALL PRL, --<Bug 3266272>
                 PO_LINE_LOCATIONS_GT POLL,
                 PO_LINES          POL,
                 PO_DISTRIBUTIONS  PD,
                 PO_REQ_DISTRIBUTIONS_ALL PRD --<Bug 3266272>
         WHERE  POLL.line_location_id = p_line_location_id
          AND    POLL.po_line_id = POL.po_line_id
          AND    PRL.unit_price >= 0
          AND    POLL.line_location_id = PD.line_location_id
          AND    PD.req_distribution_id = PRD.distribution_id
          AND    PRD.requisition_line_id = PRL.requisition_line_id
         GROUP BY PRL.requisition_line_id, PRL.unit_meas_lookup_code;
-- End of Bug# 13857241

BEGIN
l_progress := '000';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || l_api_name||'.'
          || l_progress,'PO REQ: Price, Amount Toleance check');
   END IF;
END IF;

    --check if this check is enforced
    SELECT nvl(enforce_price_change_allowance, 'N'),
                    nvl(enforce_price_change_amount, 'N'),
                    nvl(price_change_amount, -1)
    INTO   l_enforce_price_tolerance,
           l_enforce_price_amount,
           l_amount_tolerance
    FROM   po_system_parameters;

l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || l_api_name||'.'
       || l_progress,'Is price tol check enforced '||l_enforce_price_tolerance
       || ' Is price amount check enforced ' || l_enforce_price_amount);
   END IF;
END IF;

    --if we are not enforcing the price tolerance checks then return success
    IF  l_enforce_price_tolerance = 'N' AND l_enforce_price_amount = 'N' THEN
        RETURN;
    END IF;

     /*Depending on the document type execute a different sql
          statement to fetch all of the line_location_ids, prices, and
          uom_code for a particular document_id and document type.
        Use above information to determine if the po shipment
          price is within the requisition price + tolerance.
    */
    IF p_document_type = 'PO' THEN
l_progress := '002';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || l_api_name||'.'
       || l_progress,'p_document_type '||p_document_type);
   END IF;
END IF;
  --<Complex Work R12>: use a different cursor for Complex Work
        l_is_complex_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(p_document_id);

        IF (l_is_complex_po) THEN
          --The PO is a Complex Work PO
          --Use the Pay Item cursor

          OPEN po_pay_item_cursor(p_document_id);

          FETCH po_pay_item_cursor BULK COLLECT INTO
                l_ship_price_in_base_curr,
                l_ship_unit_of_measure,
                l_ship_num,
                l_line_num,
                l_quantity,
                l_item_id,
                l_line_location_id,
		l_exchange_rate; -- bug 20098125

          CLOSE po_pay_item_cursor;

        ELSE
          --The PO is not Complex Work.
          --Use the Shipment cursor

          OPEN po_shipment_cursor(p_document_id);

          FETCH po_shipment_cursor BULK COLLECT INTO
                l_ship_price_in_base_curr,
                l_ship_unit_of_measure,
                l_ship_num,
                l_line_num,
                l_quantity,
                l_item_id,
                l_line_location_id,
                l_exchange_rate; -- bug 20098125

          CLOSE po_shipment_cursor;

        END IF; -- l_is_complex_po check

    ELSIF p_document_type = 'RELEASE' THEN
l_progress := '003';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || l_api_name||'.'
       || l_progress,'p_document_type '||p_document_type);
   END IF;
END IF;
        OPEN rel_shipment_cursor(p_document_id);

        FETCH rel_shipment_cursor BULK COLLECT INTO
                l_ship_price_in_base_curr,
                l_ship_unit_of_measure,
                l_ship_num,
                l_line_num,
                l_quantity,
                l_item_id,
                l_line_location_id,
                l_exchange_rate; -- bug 20098125

        CLOSE rel_shipment_cursor;
    END IF;

    --<Bug 3266272 mbhargav START>
    --Bug 1991546
    --Obtain extended precision of PO/Release functional currency which is
    --used for rounding while checking for tolerance
      BEGIN
        SELECT  FND.currency_code, nvl(FND.extended_precision,5)
        INTO  l_pou_func_curr, l_pou_func_curr_ext_precn
        FROM  fnd_currencies FND, financials_system_parameters FSP,
              gl_sets_of_books SOB
        WHERE  FSP.set_of_books_id = SOB.set_of_books_id
         AND  SOB.currency_code = FND.currency_code;
      EXCEPTION
        WHEN OTHERS THEN
            RAISE;
      END;
      --<Bug 3266272 mbhargav END>


l_progress := '004';
    FOR shipment_line IN 1..l_line_location_id.COUNT LOOP

       --<Bug 3266272 mbhargav START>
       --Round off the shipment price (in functional currency of Purchasing
       --Operating Unit) to the extended precision of the functional currency
       l_ship_price_ext_precn :=
          round(l_ship_price_in_base_curr(shipment_line),l_pou_func_curr_ext_precn);
           l_progress := '005';
           IF g_debug_stmt THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                            l_progress,'l_ship_price_in_base_curr ::' || l_ship_price_in_base_curr(shipment_line));
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                            l_progress,'l_ship_price_ext_precn ::' || l_ship_price_ext_precn);
           END IF;

      --Obtain the currency and rate_date from PO. If a rate_date exists on PO
      --Header then it means PO Currency is different from POU functional
      --currency. In this case take the rate_date on PO Header as rate date.
      --If rate_date on PO Header is NULL then it means PO Currency is same as
      --POU functional currency. Use the Shipment creation date as rate_date for
      --such cases. This l_rate_date will be used to get rate between POU
      --functional currency and ROU functional currency for currency conversions
      BEGIN
        l_progress := '006';
        SELECT POH.currency_code, nvl(trunc(POH.rate_date), trunc(POLL.creation_date))
        INTO l_po_curr, l_rate_date
        FROM PO_HEADERS POH, PO_LINE_LOCATIONS_GT POLL
        WHERE POLL.line_location_id = l_line_location_id(shipment_line)
         AND POLL.po_header_id = POH.po_header_id;
      EXCEPTION
        WHEN OTHERS THEN
             RAISE;
      END;
-- Start of Bug# 13857241
      BEGIN
        l_progress := '007';
        SELECT MIN(POL.ORDER_TYPE_LOOKUP_CODE)
          INTO l_po_line_type
          FROM PO_LINE_LOCATIONS_ALL POLL,
               PO_LINES_ALL POL
         WHERE POLL.po_line_id = POL.po_line_id
           AND POLL.line_location_id = l_line_location_id(shipment_line);
      EXCEPTION
        WHEN OTHERS THEN
             RAISE;
      END;
      --<Bug 3266272 mbhargav END>
        BEGIN
           l_progress := '008';
           IF g_debug_stmt THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                            l_progress,'LINE_LOCATION_ID ::' || l_line_location_id(shipment_line));
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                            l_progress,'l_po_curr ::' || l_po_curr);
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                            l_progress,'l_pou_func_curr ::' || l_pou_func_curr);
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                            l_progress,'l_po_line_type ::' || l_po_line_type);
           END IF;

           /* Bug7461672
              Initializing l_is_same_foreign_currency */
           l_is_same_foreign_currency := 'N';

           /* Check if there exist any Req Line which have different currency from PO.
              If NOT found then setting l_is_same_foreign_currency to Y */
           SELECT 'Y'
             INTO l_is_same_foreign_currency
             FROM DUAL
            WHERE NOT EXISTS
                    (SELECT DISTINCT 1
                       FROM PO_REQUISITION_LINES_ALL PRL,
                            FINANCIALS_SYSTEM_PARAMS_ALL FSP,
                            GL_SETS_OF_BOOKS SOB
                      WHERE PRL.LINE_LOCATION_ID   = l_line_location_id(shipment_line)
                        AND FSP.SET_OF_BOOKS_ID  = SOB.SET_OF_BOOKS_ID
                        AND FSP.ORG_ID = PRL.ORG_ID
                        AND NVL(PRL.CURRENCY_CODE,SOB.CURRENCY_CODE) <> l_po_curr)
              AND l_po_curr <> l_pou_func_curr
	      	  AND l_po_line_type = 'QUANTITY';

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                l_is_same_foreign_currency := 'N';
        END;

        l_progress := '009';
        IF g_debug_stmt THEN
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                           l_progress,'l_is_same_foreign_currency ::' || l_is_same_foreign_currency);
        END IF;
	 END IF;

        l_progress := '010';
        --Do price tolerance check
        --Price Tolerance Check Starts Here
        IF l_enforce_price_tolerance = 'Y' THEN

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || l_api_name||'.'
          || l_progress,'Doing Price Tolerance check');
   END IF;
END IF;
        l_progress := '011';

        --Get the tolerance allowed.  This is the tolerance allowed between
        --the requisition price and shipment price.
        SELECT NVL(MSI.price_tolerance_percent/100,
                   NVL(POSP.price_change_allowance/100,-1))
        INTO   l_price_tolerance_allowed
        FROM   MTL_SYSTEM_ITEMS MSI,
               PO_SYSTEM_PARAMETERS POSP,
               FINANCIALS_SYSTEM_PARAMETERS FSP
        WHERE  msi.inventory_item_id(+) = l_item_id(shipment_line)
        AND  MSI.organization_id(+) = FSP.inventory_organization_id;

        l_progress := '012';
        IF g_debug_stmt THEN
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                           l_progress,'l_price_tolerance_allowed ::' || l_price_tolerance_allowed);
        END IF;
        END IF;
        /* This logic will be used for Price Tolerance Check when both
           PO and REQ are created in same foreign currency.
           Old/existing logic is used in ELSE part of this condition */
        IF (l_is_same_foreign_currency = 'Y' )
        THEN

            OPEN req_price_tol_cursor_req_cur(l_line_location_id(shipment_line));

            FETCH req_price_tol_cursor_req_cur BULK COLLECT INTO
                    l_req_line_curr_unit_price,
                    l_req_line_curr_code,
                    l_req_unit_of_measure,
                    l_po_req_line_num,
                    l_po_req_ship_num,
                    l_requesting_org_id;

            CLOSE req_price_tol_cursor_req_cur;

            l_progress := '013';
            FOR req_line IN 1..l_req_line_curr_unit_price.COUNT LOOP

                l_progress := '014';
                IF g_debug_stmt THEN
                    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                                   l_progress,'Processing Req Line ::' || req_line);
                END IF;

                l_req_line_price_ext_precn := round(l_req_line_curr_unit_price(req_line),l_pou_func_curr_ext_precn);

                l_progress := '015';
                po_uom_s.po_uom_conversion(
                    l_ship_unit_of_measure(shipment_line),
                    l_req_unit_of_measure(req_line),
                    l_item_id(shipment_line),
                    l_shipment_to_req_rate);

                IF g_debug_stmt THEN
                    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                                   l_progress,'l_shipment_to_req_rate ::' || l_shipment_to_req_rate);
                END IF;


                IF l_shipment_to_req_rate = 0.0 THEN
                    l_progress := '016';
                    l_shipment_to_req_rate :=1.0;
                END IF;


                IF g_debug_stmt THEN
                    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                                   l_progress,'l_req_line_curr_unit_price ::' || l_req_line_curr_unit_price(req_line));
                END IF;

                l_progress := '017';
                IF l_price_tolerance_allowed <> -1 AND l_req_line_curr_unit_price(req_line) <> 0 THEN

                    l_progress := '018';
                    --Get Shipment Price without applying Rate and Qty
                    SELECT   NVL(ROUND(MAX(POLL.price_override) ,l_pou_func_curr_ext_precn) ,-1) Price
                    INTO     l_ship_price_ext_precn
                    FROM     PO_LINE_LOCATIONS_ALL POLL,
                             PO_DISTRIBUTIONS_ALL POD
                    WHERE    POLL.line_location_id         = POD.line_location_id
                         AND POLL.line_location_id         = l_line_location_id(shipment_line)
                         AND NVL(POLL.cancel_flag,'N')    <> 'Y'
                         AND NVL(POLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
                    GROUP BY NVL(POLL.line_location_id,0);

                    IF g_debug_stmt THEN
                        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'|| l_progress,'l_ship_price_ext_precn ::' || l_ship_price_ext_precn);
                        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'|| l_progress,'l_req_line_price_ext_precn ::' || l_req_line_price_ext_precn);
                        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'|| l_progress,'l_shipment_to_req_rate ::' || l_shipment_to_req_rate);
                        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'|| l_progress,'l_price_tolerance_allowed ::' || l_price_tolerance_allowed);
                        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'|| l_progress,'l_pou_func_curr_ext_precn ::' || l_pou_func_curr_ext_precn);
                    END IF;

                IF (l_ship_price_ext_precn > ROUND((l_req_line_price_ext_precn * l_shipment_to_req_rate*(1+l_price_tolerance_allowed)),l_pou_func_curr_ext_precn)) THEN

                            l_progress := '019';
                            l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REQ_PRICE_TOL_EXCEED');
                            INSERT
                            INTO   po_online_report_text_gt
                                   (
                                          online_report_id ,
                                          last_update_login,
                                          last_updated_by  ,
                                          last_update_date ,
                                          created_by       ,
                                          creation_date    ,
                                          line_num         ,
                                          shipment_num     ,
                                          distribution_num ,
                                          sequence         ,
                                          text_line        ,
                                          message_name
                                   )
                                   VALUES
                                   (
                                          p_online_report_id         ,
                                          p_login_id                 ,
                                          p_user_id                  ,
                                          sysdate                    ,
                                          p_user_id                  ,
                                          sysdate                    ,
                                          l_po_req_line_num(req_line),
                                          l_po_req_ship_num(req_line),
                                          0                          ,
                                          p_sequence +1              ,
                                          SUBSTR(g_linemsg
                                                 ||g_delim
                                                 || l_po_req_line_num(req_line)
                                                 ||g_delim
                                                 || g_shipmsg
                                                 ||g_delim
                                                 ||l_po_req_ship_num(req_line)
                                                 ||g_delim
                                                 ||l_textline,1,240),
                                          'PO_SUB_REQ_PRICE_TOL_EXCEED'
                                   );

                            p_sequence := p_sequence +1;

                END IF; --IF (l_ship_price_ext_precn > ROUND

            END IF; --IF l_price_tolerance_allowed <> -1

           END LOOP; --req_price_tol_cursor

        ELSE
-- End of Bug# 13857241
            OPEN req_price_tol_cursor(l_line_location_id(shipment_line));

            FETCH req_price_tol_cursor BULK COLLECT INTO
                    l_req_line_unit_price,
                    l_req_unit_of_measure,
                    l_po_req_line_num,
                    l_po_req_ship_num,
                    l_requesting_org_id; --Bug 3266272

            CLOSE req_price_tol_cursor;

l_progress := '019';
            FOR req_line IN 1..l_req_line_unit_price.COUNT LOOP

          /*
           ** If a row was returned then the PO or Release is associated
           ** with a requisition and you should continue with the logic.
           ** If a row was not returned.  It does not mean that an error
           ** occurred, it meas that the submission check does not apply
           ** to this document.
           */
                --<Bug 3266272 mbhargav START>
                /* Bug 4537974: while comparing org_id we need an NVL condition
		   around both the operands of = since for single org installations
		   the org_id can be null */

                IF l_req_ou_func_curr IS NULL THEN
                  BEGIN
                    SELECT  SOB.currency_code
                    INTO  l_req_ou_func_curr
                    FROM  financials_system_params_all FSP, gl_sets_of_books SOB
                    WHERE  FSP.set_of_books_id = SOB.set_of_books_id
                      AND  NVL(FSP.org_id, -99) = NVL(l_requesting_org_id(req_line),-99);
                  EXCEPTION
                    WHEN OTHERS THEN
                       RAISE;
                  END;
                END IF;

                IF l_req_ou_func_curr <> l_pou_func_curr THEN

                   --Obtain the conversion rate between two functional currencies
                   --using the rate type from POU setup.
                   IF l_rate IS NULL THEN
                      BEGIN
                        SELECT default_rate_type
                        INTO   l_rate_type
                        FROM   po_system_parameters;
                      EXCEPTION
                        WHEN OTHERS THEN
                          RAISE;
                      END;

                      --Get the conversion rate between Purchasing Operating Unit func
                      --currency and Req Operating Unit functional currency
                      po_currency_sv.get_rate(
                              p_from_currency => l_req_ou_func_curr,
                              p_to_currency   => l_pou_func_curr,
                              p_rate_type     => l_rate_type,
                              p_rate_date     => l_rate_date,
                              p_inverse_rate_display_flag => 'N',
                              x_rate          => l_rate,
                              x_display_rate  => l_display_rate,
                              x_return_status => l_return_status,
                              x_error_message_name => l_error_message_name);
                   END IF; --rate check

                   --Convert the Req line price (which is in Req OU func currency)
                   --to Purchasing OU functional currency for comparison
                   l_req_line_price_pou_base_curr :=
                           l_req_line_unit_price(req_line) * nvl(l_rate,1);

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || l_api_name||'.'
       || l_progress,'POU Func Currency and ROU Func Curr are different'
       || ' l_pou_func_curr= '||l_pou_func_curr
       || ' l_req_ou_func_curr= ' || l_req_ou_func_curr
       || ' l_req_line_unit_price= ' || l_req_line_unit_price(req_line)
       || ' l_rate_type= ' ||  l_rate_type
       || ' l_rate_date= ' || l_rate_date
       || ' l_rate= ' || l_rate
       || ' l_req_line_price_pou_base_curr= ' ||l_req_line_price_pou_base_curr);
   END IF;
END IF;
                   --Round off the Req line price (in functional currency of
                   --Purchasing Operating Unit) to the extended precision of
                   --the functional currency
                   l_req_line_price_ext_precn :=
                       round(l_req_line_price_pou_base_curr,l_pou_func_curr_ext_precn);
                ELSE  --POU func curr <> ROU func curr
                   l_req_line_price_ext_precn :=
                      round(l_req_line_unit_price(req_line),l_pou_func_curr_ext_precn);
                END IF; --func curr check
                --<Bug 3266272 mbhargav END>

                --Call function that returns the shipment price
                --converted to the correct UOM.
                po_uom_s.po_uom_conversion(
                    l_ship_unit_of_measure(shipment_line),
                    l_req_unit_of_measure(req_line),
                    l_item_id(shipment_line),
                    l_shipment_to_req_rate);

                IF l_shipment_to_req_rate = 0.0 THEN
                    l_shipment_to_req_rate :=1.0;
                END IF;

l_progress := '020';
                IF l_price_tolerance_allowed <> -1 AND
                    l_req_line_unit_price(req_line) <> 0 THEN

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || l_api_name||'.'
       || l_progress,'l_ship_price_ext_precn= '||l_ship_price_ext_precn
       || ' l_req_line_price_ext_precn= ' || l_req_line_price_ext_precn
       || ' l_shipment_to_req_rate= ' || l_shipment_to_req_rate
       || ' l_price_tolerance_allowed= ' ||  l_price_tolerance_allowed);
   END IF;
END IF;

                   /*
                   **  Check to see if the rate returned from the function
                   **  multiplied by the shipment price in base currency and
                   **  then divided by the requisition price is less then
                   **  the tolerance.  If not, call the function to
                   **  insert into the Online Report Text Table.
                   **
                   ** The following formula will cost precision erro when the
                   ** increase equals to the tolerance.
                   ** Patched as part of bug 432746.
                   **
                   **if ((((ship_price_in_base_curr * rate) /
                   **   req_line_unit_price[i]) -1) <= tolerance)
                   */

                   /* Bug 638073
                      the formula for tolerance check should be
                      ship_price_in_base_curr/ req_line_unit_pric e[i] *rate
                      since rate is the conversion from shipment uom to req uom
                    */

                   /*    svaidyan 09/10/98   726568  Modified the price tolerance
                      to check against tolerance + 1.000001. This is because,
                      the reqs sourced to a blanket store the unit price rounded
                      to 5 decimal places and hence we compare only upto the 5th
                      decimal place.
                    */

                    /* Bug 3262304, 3266272 mbhargav Using the req price to
                       the ext_precn of the currency. Also replacing the division
                        by multiplication on the other side
                       IF (((l_ship_price_ext_precn) /
                        (l_req_line_unit_price(req_line) *
                            l_shipment_to_req_rate ))
                                  > (l_price_tolerance_allowed + 1.000001))
                       THEN
                   */
                   --<Bug 3266272 mbhargav START>
                   IF (l_ship_price_ext_precn >
                          ( (l_req_line_price_ext_precn * l_shipment_to_req_rate )
                              * (l_price_tolerance_allowed + 1.000001)
                          )
                   ) THEN
                   --<Bug 3266272 mbhargav END>
l_progress := '030';
                      --Report the price tolerance error
                      l_textline := FND_MESSAGE.GET_STRING('PO',
                                          'PO_SUB_REQ_PRICE_TOL_EXCEED');
                      INSERT into po_online_report_text_gt(
                            online_report_id,
                        last_update_login,
                        last_updated_by,
                        last_update_date,
                        created_by,
                        creation_date,
                        line_num,
                        shipment_num,
                        distribution_num,
                        sequence,
                        text_line,
                                message_name)
                      VALUES ( p_online_report_id,
                            p_login_id,
                            p_user_id,
                            sysdate,
                            p_user_id,
                            sysdate,
                            l_po_req_line_num(req_line),
                            l_po_req_ship_num(req_line),
                            0,
                            p_sequence +1,
                            substr(g_linemsg||g_delim||
                                l_po_req_line_num(req_line)||g_delim||
                                g_shipmsg||g_delim||l_po_req_ship_num(req_line)
                                ||g_delim||l_textline,1,240),
                            'PO_SUB_REQ_PRICE_TOL_EXCEED');

                      p_sequence := p_sequence +1;

                     END IF; --check for tolerance

                 END IF; --check l_price_tolerance_allowed

             END LOOP; --req line

            END IF;

        END IF; --price tolerance check

l_progress := '040';

        --Do price 'not to exceed' amount check
        --Amount Tolerance Check Starts Here
        IF l_enforce_price_amount = 'Y' THEN
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || l_api_name||'.'
                      || l_progress,'Amount Tolerance Check');
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || l_api_name||'.'
          || l_progress,'Doing Not to exceed amt check');
   END IF;
END IF;

 -- Start of Bug# 13857241
        /* This logic will be used for Amount Tolerance Check when both
           PO and REQ are created in same foreign currency.
           Old/existing logic is used in ELSE part of this condition */
        IF (l_is_same_foreign_currency = 'Y' )
        THEN

            /*Introduced new cursor to get Req price in base currency */
            OPEN req_price_amt_cursor_req_curr(l_line_location_id(shipment_line));

            FETCH req_price_amt_cursor_req_curr BULK COLLECT INTO
                    l_req_line_curr_unit_price,
                    l_req_line_curr_code,
                    l_req_unit_of_measure,
                    l_po_req_quantity,
                    l_po_req_line_num,
                    l_po_req_ship_num,
                    l_requesting_org_id; --Bug 3266272

            CLOSE req_price_amt_cursor_req_curr;

            l_progress := '050';
            FOR req_line IN 1..l_req_line_curr_unit_price.COUNT LOOP

                l_progress := '051';
                IF g_debug_stmt THEN
                    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                                   l_progress,'Processing Req Line ::' || req_line);
                END IF;

                l_req_line_price_ext_precn := round(l_req_line_curr_unit_price(req_line),l_pou_func_curr_ext_precn);

                --Call function that returns the shipment price
                --converted to the correct UOM.
                l_progress := '053';
                po_uom_s.po_uom_conversion(
                    l_ship_unit_of_measure(shipment_line),
                    l_req_unit_of_measure(req_line),
                    l_item_id(shipment_line),
                    l_shipment_to_req_rate);

                IF g_debug_stmt THEN
                    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                                   l_progress,'l_shipment_to_req_rate ::' || l_shipment_to_req_rate);
                END IF;


                IF l_shipment_to_req_rate = 0.0 THEN
                    l_shipment_to_req_rate :=1.0;
                END IF;

                l_progress := '054';
                IF g_debug_stmt THEN
                    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                                   l_progress,'l_amount_tolerance ::' || l_amount_tolerance);
                    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'||
                                   l_progress,'l_req_line_unit_price ::' || l_req_line_curr_unit_price(req_line));
                END IF;

                l_progress := '055';
                IF l_amount_tolerance >= 0 AND l_req_line_curr_unit_price(req_line) <> 0 THEN

                    l_progress := '207';
                    --Get Shipment Price without applying Rate and Qty
                    SELECT   NVL(ROUND(MAX(POLL.price_override) ,l_pou_func_curr_ext_precn) ,-1) Price
                    INTO     l_ship_price_ext_precn
                    FROM     PO_LINE_LOCATIONS_ALL POLL,
                             PO_DISTRIBUTIONS_ALL POD
                    WHERE    POLL.line_location_id         = POD.line_location_id
                         AND POLL.line_location_id         = l_line_location_id(shipment_line)
                         AND NVL(POLL.cancel_flag,'N')    <> 'Y'
                         AND NVL(POLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
                    GROUP BY NVL(POLL.line_location_id,0);

                    IF g_debug_stmt THEN
                        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'|| l_progress,'l_ship_price_ext_precn ::' || l_ship_price_ext_precn);
                        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'|| l_progress,'l_req_line_price_ext_precn ::' || l_req_line_price_ext_precn);
                        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'|| l_progress,'l_shipment_to_req_rate ::' || l_shipment_to_req_rate);
                        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'|| l_progress,'l_price_tolerance_allowed ::' || l_price_tolerance_allowed);
                        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'|| l_progress,'l_pou_func_curr_ext_precn ::' || l_pou_func_curr_ext_precn);
                        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head|| l_api_name||'.'|| l_progress,'l_exchange_rate ::' || l_exchange_rate(shipment_line));
                    END IF;

                   IF ((l_ship_price_ext_precn -
                         (l_req_line_price_ext_precn * l_shipment_to_req_rate)
                        ) * l_po_req_quantity(req_line)
                                           > l_amount_tolerance / l_exchange_rate(shipment_line) -- bug 20098125, convert the tolerance to the same currency
                       )
                   THEN

                            l_progress := '060';
                            l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REQ_AMT_TOL_EXCEED');
                            INSERT
                            INTO   po_online_report_text_gt
                                   (
                                          online_report_id ,
                                          last_update_login,
                                          last_updated_by  ,
                                          last_update_date ,
                                          created_by       ,
                                          creation_date    ,
                                          line_num         ,
                                          shipment_num     ,
                                          distribution_num ,
                                          sequence         ,
                                          text_line        ,
                                          message_name
                                   )
                                   VALUES
                                   (
                                          p_online_report_id         ,
                                          p_login_id                 ,
                                          p_user_id                  ,
                                          sysdate                    ,
                                          p_user_id                  ,
                                          sysdate                    ,
                                          l_po_req_line_num(req_line),
                                          l_po_req_ship_num(req_line),
                                          0                          ,
                                          p_sequence +1              ,
                                          SUBSTR(g_linemsg
                                                 ||g_delim
                                                 || l_po_req_line_num(req_line)
                                                 ||g_delim
                                                 || g_shipmsg
                                                 ||g_delim
                                                 ||l_po_req_ship_num(req_line)
                                                 ||g_delim
                                                 ||l_textline,1,240),
                                          'PO_SUB_REQ_PRICE_TOL_EXCEED'
                                   );

                            p_sequence := p_sequence +1;

                END IF; --Tolerance Fail Logic

            END IF; --l_amount_tolerance >= 0

           END LOOP; --req_price_amt_cursor_req_curr cursor

        ELSE --l_is_same_foreign_cuurecy logic
-- End of Bug# 13857241
            OPEN req_price_amt_cursor(l_line_location_id(shipment_line));

            FETCH req_price_amt_cursor BULK COLLECT INTO
                    l_req_line_unit_price,
                    l_req_unit_of_measure,
                    l_po_req_quantity,
                    l_po_req_line_num,
                    l_po_req_ship_num,
                    l_requesting_org_id; --Bug 3266272

            CLOSE req_price_amt_cursor;

l_progress := '070';
            FOR req_line IN 1..l_req_line_unit_price.COUNT LOOP

          /*
           ** If a row was returned then the PO or Release is associated
           ** with a requisition and you should continue with the logic.
           ** If a row was not returned.  It does not mean that an error
           ** occurred, it meas that the submission check does not apply
           ** to this document.
           */

                --<Bug 3266272 mbhargav START>
                /* Bug 4537974: while comparing org_id we need an NVL condition
		   around both the operands of = since for single org installations
		   the org_id can be null */
                IF l_req_ou_func_curr IS NULL THEN
                  BEGIN
                    SELECT  SOB.currency_code
                    INTO  l_req_ou_func_curr
                    FROM  financials_system_params_all FSP, gl_sets_of_books SOB
                    WHERE  FSP.set_of_books_id = SOB.set_of_books_id
                      AND  NVL(FSP.org_id, -99) = NVL(l_requesting_org_id(req_line),-99);
                  EXCEPTION
                    WHEN OTHERS THEN
                       RAISE;
                  END;
                END IF;

                IF l_req_ou_func_curr <> l_pou_func_curr THEN

                   --Obtain the conversion rate between two functional currencies
                   --using the rate type from POU setup.
                   IF l_rate IS NULL THEN
                      BEGIN
                        SELECT default_rate_type
                        INTO   l_rate_type
                        FROM   po_system_parameters;
                      EXCEPTION
                        WHEN OTHERS THEN
                          RAISE;
                      END;

                      --Get the conversion rate between Purchasing Operating Unit func
                      --currency and Req Operating Unit functional currency
                      po_currency_sv.get_rate(
                              p_from_currency => l_req_ou_func_curr,
                              p_to_currency   => l_pou_func_curr,
                              p_rate_type     => l_rate_type,
                              p_rate_date     => l_rate_date,
                              p_inverse_rate_display_flag => 'N',
                              x_rate          => l_rate,
                              x_display_rate  => l_display_rate,
                              x_return_status => l_return_status,
                              x_error_message_name => l_error_message_name);
                   END IF; --rate check

                   --Convert the Req line price (which is in Req OU func currency)
                   --to Purchasing OU functional currency for comparison
                   l_req_line_price_pou_base_curr :=
                           l_req_line_unit_price(req_line) * nvl(l_rate,1);

                   --Round off the Req line price (in functional currency of
                   --Purchasing Operating Unit) to the extended precision of
                   --the functional currency
                   l_req_line_price_ext_precn :=
                       round(l_req_line_price_pou_base_curr,l_pou_func_curr_ext_precn);
                ELSE  --POU func curr <> ROU func curr
                   l_req_line_price_ext_precn :=
                      round(l_req_line_unit_price(req_line),l_pou_func_curr_ext_precn);
                END IF; --func curr check
                --<Bug 3266272 mbhargav END>

                --Call function that returns the shipment price
                --converted to the correct UOM.
                po_uom_s.po_uom_conversion(
                    l_ship_unit_of_measure(shipment_line),
                    l_req_unit_of_measure(req_line),
                    l_item_id(shipment_line),
                    l_shipment_to_req_rate);

                IF l_shipment_to_req_rate = 0.0 THEN
                    l_shipment_to_req_rate :=1.0;
                END IF;


                IF l_amount_tolerance >= 0 AND
                    l_req_line_unit_price(req_line) <> 0 THEN

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || l_api_name||'.'
       || l_progress,'l_ship_price_ext_precn= '||l_ship_price_ext_precn
       || ' l_req_line_price_ext_precn= ' || l_req_line_price_ext_precn
       || ' l_shipment_to_req_rate= ' || l_shipment_to_req_rate
       || ' l_po_req_quantity= ' ||  l_po_req_quantity(req_line)
       || ' l_amount_tolerance= ' || l_amount_tolerance);
   END IF;
END IF;
                   --do the amount check
                   --makes sure the requisition amount and
                   --PO amount for each shipment line is within the value
                   --defined in the column PRICE_CHANGE_AMOUNT of table
                   --PO_SYSTEM_PARAMETERS.
                    --Bug 3262304, 3266272 mbhargav Using the Req price which is
                    --rounded to the ext_precn of the its currency.
                   IF ((l_ship_price_ext_precn -
                         (l_req_line_price_ext_precn * l_shipment_to_req_rate)
                        ) * l_po_req_quantity(req_line)
                                           > l_amount_tolerance
                       )
                   THEN
l_progress := '080';
                      --Report the price amount exceeded error
                      l_textline :=
                   FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REQ_AMT_TOL_EXCEED');
                      INSERT into po_online_report_text_gt(
                            online_report_id,
                        last_update_login,
                        last_updated_by,
                        last_update_date,
                        created_by,
                        creation_date,
                        line_num,
                        shipment_num,
                        distribution_num,
                        sequence,
                        text_line,
                                message_name)
                      VALUES ( p_online_report_id,
                            p_login_id,
                            p_user_id,
                            sysdate,
                            p_user_id,
                            sysdate,
                            l_po_req_line_num(req_line),
                            l_po_req_ship_num(req_line),
                            0,
                            p_sequence +1,
                            substr(g_linemsg||g_delim||
                                l_po_req_line_num(req_line)||g_delim||
                                g_shipmsg||g_delim||l_po_req_ship_num(req_line)
                                ||g_delim||l_textline,1,240),
                            'PO_SUB_REQ_AMT_TOL_EXCEED');

                      p_sequence := p_sequence +1;

                     END IF; --amount check

                 END IF; --check l_amount_tolerance_allowed

             END LOOP; --req line

        END IF;

        END IF; --not to exceed amount check

   END LOOP;  --for shipment_line

l_progress := '090';
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;
END CHECK_PO_REL_REQPRICE;


--For PO,PA: Header Checks
/**
* Private Procedure: CHECK_PO_PA_HEADER
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure runs the document submission checks for HEADERS
*           of POs and PAs
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*/
PROCEDURE check_po_pa_header(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_textline            po_online_report_text.text_line%TYPE := NULL;
l_api_name  CONSTANT varchar2(40) := 'CHECK_PO_PA_HEADER';
l_progress VARCHAR2(3);

l_vendor_id           po_headers.vendor_id%TYPE;
l_vendor_site_id      po_headers.vendor_site_id%TYPE;
l_vendor_contact_id   po_headers.vendor_contact_id%TYPE; /*bug 6530879*/
l_ship_to_location_id po_headers.ship_to_location_id%TYPE;
l_bill_to_location_id po_headers.bill_to_location_id%TYPE;
l_currency_code       po_headers.currency_code%TYPE;
l_sob_currency_code   po_headers.currency_code%TYPE;
l_rate_type           po_headers.rate_type%TYPE;
l_rate                po_headers.rate%TYPE;
l_rate_date           po_headers.rate_date%TYPE;

--bug#3987438
--Adding a new variable that would hold the name of the invalid
--ship-to or bill-to location
l_invalid_location   HR_LOCATIONS_ALL_TL.location_code%type;
--bug#3987438

BEGIN

l_progress := '000';

l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO/PA Header 1: Vendor On Hold ');
   END IF;
END IF;

  -- Check 1: Purchase Order vendor should not be on hold
    -- PO_SUB_VENDOR_ON_HOLD

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_VENDOR_ON_HOLD');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_VENDOR_ON_HOLD'
    FROM  PO_HEADERS_GT POH, PO_VENDORS POV, PO_SYSTEM_PARAMETERS PSP
    WHERE  POV.vendor_id     = POH.vendor_id
    AND    POH.po_header_id = p_document_id
    AND    nvl(PSP.ENFORCE_VENDOR_HOLD_FLAG,'N') = 'Y'
    AND    nvl(POV.hold_flag,'N') = 'Y';


     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
---------------------------------------------
l_progress := '002';
    BEGIN
        SELECT POH.vendor_id,
                    POH.vendor_site_id,
                    POH.vendor_contact_id,
		    POH.ship_to_location_id,
                    POH.bill_to_location_id,
                    POH.currency_code,
                    SOB.currency_code,
                    POH.rate_type,
                    POH.rate,
                    POH.rate_date
        INTO   l_vendor_id,
                    l_vendor_site_id,
		    l_vendor_contact_id,
                    l_ship_to_location_id,
                    l_bill_to_location_id,
                    l_currency_code,
                    l_sob_currency_code,
                    l_rate_type,
                    l_rate,
                    l_rate_date
        FROM   PO_HEADERS_GT POH,
               GL_SETS_OF_BOOKS SOB,
               FINANCIALS_SYSTEM_PARAMETERS FSP
        WHERE  POH.po_header_id    = p_document_id
        AND    SOB.set_of_books_id = FSP.set_of_books_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
l_progress := '003';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO/PA Header 2:System setup check');
   END IF;
END IF;
            -- Check 2: When no rows are returned, its likely that there
            --are problems with system setup
            --<NOTE> See if we need to stop further processing
            l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_SYSTEM_SETUP');
            INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
          VALUES (p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + 1,
        substr(l_textline,1,240),
            'PO_SUB_SYSTEM_SETUP');

        --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + 1;
---------------------------------------------
    END;

    --Check to see if the fields are null.  If the are null copy then
    --call the online report function.  Only print the message for the
    -- rate type if the rate type is null and they are using a foreign
    -- currency.  You know if a foreign currency is used if the currency
    -- code and sob_currency_code do not match.

l_progress := '004';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO/PA Header 3: No Vendor');
   END IF;
END IF;

    --Check 3: vendor_id is NULL
    IF l_vendor_id IS NULL THEN
         l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_ENTER_VENDOR');
         INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
        VALUES (p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + 1,
        substr(l_textline,1,240),
            'PO_SUB_ENTER_VENDOR');

         --Increment the p_sequence with number of errors reported in last query
         p_sequence := p_sequence + 1;
    END IF; --vendor_id

l_progress := '005';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO/PA Header 4: No Vendor Site');
   END IF;
END IF;

    --Check 4: vendor_site_id is NULL
    IF l_vendor_site_id IS NULL THEN
         l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_ENTER_VENDOR_SITE');
         INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
        VALUES (p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + 1,
        substr(l_textline,1,240),
            'PO_SUB_ENTER_VENDOR_SITE');

         --Increment the p_sequence with number of errors reported in last query
         p_sequence := p_sequence + 1;
    END IF; --vendor_site_id

l_progress := '006';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO/PA Header 5: Ship_to_loc_id check ');
   END IF;
END IF;

    --Check 5: ship_to_location_id is NULL
    IF l_ship_to_location_id IS NULL THEN
         l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_NO_SHIP_TO_LOC_ID');
         INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
        VALUES (p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + 1,
        substr(l_textline,1,240),
            'PO_SUB_NO_SHIP_TO_LOC_ID');

         --Increment the p_sequence with number of errors reported in last query
         p_sequence := p_sequence + 1;

--bug#3987438 Added a check to verify that the ship to location is active
    ELSE
        BEGIN
            SELECT hlt.location_code
            INTO l_invalid_location
            FROM hr_locations_all hla,
                 hr_locations_all_tl hlt
            WHERE hla.location_id = l_ship_to_location_id
            AND NVL(TRUNC(hla.inactive_date), TRUNC(SYSDATE)+1 ) <= TRUNC(SYSDATE)
            AND hlt.location_id=hla.location_id
            AND hlt.language=USERENV('LANG');

            INSERT INTO po_online_report_text_gt(online_report_id,
                last_update_login,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                line_num,
                shipment_num,
                distribution_num,
                sequence,
                text_line,
                message_name)
            VALUES
               (
                p_online_report_id,
                p_login_id,
                p_user_id,
                SYSDATE,
                p_user_id,
                SYSDATE,
                0,
                0,
                0,
                p_sequence + 1,
                substr(PO_CORE_S.get_translated_text
                ( 'PO_SUB_INVALID_SHIP_TO_LOC',
                  'SHIP_TO_LOC',
                  l_invalid_location),1,240),
                'PO_SUB_INVALID_SHIP_TO_LOC'
                );
                 p_sequence := p_sequence + 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                null;
        END;
--bug#3987438

    END IF; --ship_to_loc_id

l_progress := '007';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO/PA Header 6: Bill_to_loc check');
   END IF;
END IF;

    --Check 6: bill_to_location_id is NULL
    IF l_bill_to_location_id IS NULL THEN

         l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_NO_BILL_TO_LOC_ID');
         INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
        VALUES (p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + 1,
        substr(l_textline,1,240),
            'PO_SUB_NO_BILL_TO_LOC_ID');

         --Increment the p_sequence with number of errors reported in last query
         p_sequence := p_sequence + 1;

--bug#3987438 Added a check to verify that the bill to location is active
    ELSE
        BEGIN
            SELECT hlt.location_code
            INTO l_invalid_location
            FROM hr_locations_all hla,
                 hr_locations_all_tl hlt
            WHERE hla.location_id = l_bill_to_location_id
            AND NVL(TRUNC(hla.inactive_date), TRUNC(SYSDATE)+1 ) <= TRUNC(SYSDATE)
            AND hlt.location_id=hla.location_id
            AND hlt.language=USERENV('LANG');

            INSERT INTO po_online_report_text_gt(online_report_id,
                last_update_login,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                line_num,
                shipment_num,
                distribution_num,
                sequence,
                text_line,
                message_name)
            VALUES
               (
                p_online_report_id,
                p_login_id,
                p_user_id,
                SYSDATE,
                p_user_id,
                SYSDATE,
                0,
                0,
                0,
                p_sequence + 1,
                substr(PO_CORE_S.get_translated_text('PO_SUB_INVALID_BILL_TO_LOC','BILL_TO_LOC',l_invalid_location),1,240),
                'PO_SUB_INVALID_BILL_TO_LOC'
                );
                 p_sequence := p_sequence + 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                    null;
        END;
--bug#3987438

    END IF; --bill_to_loc_id

l_progress := '008';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO/PA Header 7: No currency code');
   END IF;
END IF;

    --Check 7: currency_code is NULL
    IF l_currency_code IS NULL THEN
         l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_NO_CURRENCY_CODE');
         INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
        VALUES (p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + 1,
        substr(l_textline,1,240),
            'PO_SUB_NO_CURRENCY_CODE');

         --Increment the p_sequence with number of errors reported in last query
         p_sequence := p_sequence + 1;
    END IF; --currency_code

l_progress := '009';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO/PA Header 8: Rate related checks');
   END IF;
END IF;

    --Check 8: rate
    IF l_currency_code <> l_sob_currency_code AND
        (l_rate_type IS NULL OR l_rate IS NULL OR
            (l_rate_type <> 'User' AND l_rate_date IS NULL)) -- Bug 3759198
    THEN
         l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_NO_RATE_TYPE');
         INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
        VALUES (p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + 1,
        substr(l_textline,1,240),
            'PO_SUB_NO_RATE_TYPE');

         --Increment the p_sequence with number of errors reported in last query
         p_sequence := p_sequence + 1;

    END IF; --rate related

-- <SERVICES FPJ START>

l_progress := '015';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO/PA Header 9: Currency Rate Type');
   END IF;
END IF;

    -- CHECK 9: The Currency Rate Type cannot be "User" if the document
    --          contains any Lines with Value Basis of "Rate".

    IF ( l_rate_type = 'User' ) THEN

        l_textline := FND_MESSAGE.get_string('PO','PO_SUB_USER_RATE_TYPE');

        INSERT INTO po_online_report_text_gt
        (   online_report_id
        ,   last_update_login
        ,   last_updated_by
        ,   last_update_date
        ,   created_by
        ,   creation_date
        ,   line_num
        ,   shipment_num
        ,   distribution_num
        ,   sequence
        ,   text_line
        ,   message_name
        )
        SELECT p_online_report_id
        ,      p_login_id
        ,      p_user_id
        ,      sysdate
        ,      p_user_id
        ,      sysdate
        ,      NULL
        ,      NULL
        ,      NULL
        ,      p_sequence + ROWNUM
        ,      l_textline
        ,      'PO_SUB_USER_RATE_TYPE'
        FROM   dual
        WHERE  exists ( SELECT 'Rate-based lines exist'
                        FROM   po_lines_gt      POL
                        ,      po_line_types_b  PLT
                        WHERE  p_document_id = POL.po_header_id
                        AND    POL.line_type_id = PLT.line_type_id
                        AND    PLT.order_type_lookup_code = 'RATE'
                      );

        --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;

    END IF; -- ( l_rate_type = 'User' )

-- <SERVICES FPJ END>

l_progress := '020';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO/PA Header 10: Cannot approve documents on hold');
   END IF;
END IF;
    -- Check 10: Purchase Order should not be on hold (Bug 3678912)
        -- PO_ON_HOLD_CANNOT_APPROVE

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_ON_HOLD_CANNOT_APPROVE');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
                  sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
                   'PO_ON_HOLD_CANNOT_APPROVE'
    FROM  PO_HEADERS_GT POH
    WHERE  POH.po_header_id = p_document_id
    AND    nvl(POH.USER_HOLD_FLAG,'N') = 'Y';

    --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;

-- bug 6530879
-- Check 11: Vendor should be valid when approving the document.
-- Important for reapproval, to avoid the case when the vendor has
-- been invalidated by first successful approval.

/* Need to find out.

 fnd_message.set_name('PO', 'PO_PDOI_INVALID_VENDOR');
 fnd_message.set_token('VALUE', to_char(x_vendor_id), FALSE);
l_textline := fnd_message.get;

*/

l_textline :=  FND_MESSAGE.GET_STRING('PO', 'PO_PDOI_INVALID_VENDOR');

  if (l_vendor_id is NOT NULL) then
	fnd_message.set_name('PO', 'PO_PDOI_INVALID_VENDOR');
        fnd_message.set_token('VALUE', to_char(l_vendor_id), FALSE);
	l_textline := substr(fnd_message.get, 1, 240);


 	INSERT INTO po_online_report_text_gt(online_report_id,
 				last_update_login,
 				last_updated_by,
 				last_update_date,
 				created_by,
 				creation_date,
 				line_num,
 				shipment_num,
 				distribution_num,
 				sequence,
 				text_line,
                                message_name)
 	SELECT 	p_online_report_id,
 		    p_login_id,
 		    p_user_id,
     	            sysdate,
 		    p_user_id,
 		    sysdate,
 		    0,
 		    0,
 		    0,
 		    p_sequence + ROWNUM,
 		    substr(l_textline,1,240),
                   'PO_PDOI_INVALID_VENDOR'
	FROM  dual
    where not exists (select 'Y'
			from PO_HEADERS_GT POH, po_vendors pov
		       WHERE  POH.po_header_id = p_document_id
		         AND  pov.vendor_id = poh.vendor_id
			 AND  pov.enabled_flag = 'Y'
			 AND  SYSDATE BETWEEN nvl(pov.start_date_active, SYSDATE-1)
                                  AND nvl(pov.end_date_active, SYSDATE+1));
 --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;

 end if;

-- Check 12: check the validity of the vendor site.
 if (l_vendor_site_id is not null) then

  	fnd_message.set_name('PO', 'PO_PDOI_INVALID_VENDOR_SITE');
 	fnd_message.set_token('VALUE', to_char(l_vendor_site_id), FALSE);
	l_textline := substr(fnd_message.get, 1, 240);

 	INSERT INTO po_online_report_text_gt(online_report_id,
 				last_update_login,
 				last_updated_by,
 				last_update_date,
 				created_by,
 				creation_date,
 				line_num,
 				shipment_num,
 				distribution_num,
 				sequence,
 				text_line,
                                message_name)
 	SELECT 	p_online_report_id,
 		    p_login_id,
 		    p_user_id,
     	            sysdate,
 		    p_user_id,
 		    sysdate,
 		    0,
 		    0,
 		    0,
 		    p_sequence + ROWNUM,
 		    substr(l_textline,1,240),
                   'PO_PDOI_INVALID_VENDOR_SITE'
    FROM  dual
    where not exists (select 'Y'
			from PO_HEADERS_GT POH, po_vendor_sites povs
		        WHERE  POH.po_header_id = p_document_id
		        AND  povs.vendor_site_id = poh.vendor_site_id
			AND    nvl(povs.rfq_only_site_flag,'N') <> 'Y'
			AND    povs.purchasing_site_flag = 'Y'
		        AND    SYSDATE < nvl(povs.inactive_date, SYSDATE + 1));
 --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;
end if;

-- check 13: validate vendor contact
if (l_vendor_contact_id is not null) then

	fnd_message.set_name('PO', 'PO_PDOI_INVALID_VDR_CNTCT');
 	fnd_message.set_token('VALUE', to_char(l_vendor_contact_id), FALSE);
	l_textline := substr(fnd_message.get, 1, 240);

	INSERT INTO po_online_report_text_gt(online_report_id,
 				last_update_login,
 				last_updated_by,
 				last_update_date,
 				created_by,
 				creation_date,
 				line_num,
 				shipment_num,
 				distribution_num,
 				sequence,
 				text_line,
                                message_name)
 	SELECT 	p_online_report_id,
 		    p_login_id,
 		    p_user_id,
     	            sysdate,
 		    p_user_id,
 		    sysdate,
 		    0,
 		    0,
 		    0,
 		    p_sequence + ROWNUM,
 		    substr(l_textline,1,240),
                   'PO_PDOI_INVALID_VDR_CNTCT'
	FROM  dual
	--Start of code changes for the bug 16244229
	WHERE NOT EXISTS ( SELECT  'Y'
			FROM
			AP_SUPPLIER_CONTACTS PVC ,
			HZ_PARTIES HP ,
			HZ_RELATIONSHIPS HPR ,
			HZ_PARTY_SITES HPS ,
			HZ_ORG_CONTACTS HOC ,
			HZ_PARTIES HP2 ,
			AP_SUPPLIERS APS,
			po_headers_gt POH
			WHERE PVC.PER_PARTY_ID = HP.PARTY_ID
			AND PVC.REL_PARTY_ID   = HP2.PARTY_ID
			AND PVC.ORG_CONTACT_ID                           = HOC.ORG_CONTACT_ID(+)
			AND PVC.RELATIONSHIP_ID                          = HPR.RELATIONSHIP_ID
			AND HPR.DIRECTIONAL_FLAG                         ='F'
			AND NVL( APS.VENDOR_TYPE_LOOKUP_CODE, 'DUMMY' ) <> 'EMPLOYEE'
			AND ( (Pvc.Party_Site_Id  = Hps.Party_Site_Id
				AND SYSDATE < nvl( LEAST(NVL(HPR.END_DATE, TO_DATE('12/31/4712','MM/DD/RRRR')), NVL(PVC.INACTIVE_DATE, TO_DATE('12/31/4712','MM/DD/RRRR'))), SYSDATE+1)
				AND EXISTS (SELECT 1 FROM AP_SUPPLIER_SITES_ALL PVS   --Bug#19560839 FIX
                            WHERE PVS.PARTY_SITE_ID  = PVC.ORG_PARTY_SITE_ID
				               AND PVS.VENDOR_ID     = APS.VENDOR_ID))
			OR (PVC.ORG_PARTY_SITE_ID                       IS NULL
				AND PVC.VENDOR_SITE_ID                          IS NULL
				AND HPR.OBJECT_ID                                = APS.PARTY_ID
				AND HPR.RELATIONSHIP_CODE                        = 'CONTACT_OF'
				And Hpr.Object_Type                              = 'ORGANIZATION'
				AND SYSDATE < NVL(HPR.END_DATE, SYSDATE+1) )
			)
			AND POH.VENDOR_CONTACT_ID = PVC.VENDOR_CONTACT_ID
			AND POH.PO_HEADER_ID=p_document_id);
	--End of code changes for the bug 16244229

   --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;
end if;

    l_progress := '050';
----------------------------------------------------------------------------------
    IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO/PA Header 14: Cannot approve documents with invalid buyer');
   END IF;
END IF;

--<Bug 9040655 START Buyer should not inactive on the document>
    -- Check 14: Buyer on the po/pa should not be inactive
        -- PO_BUYER_INACTIVE

  l_textline := substr(FND_MESSAGE.GET_STRING('PO', 'PO_BUYER_INACTIVE'),1,240);
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
                  sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        l_textline,
                   'PO_BUYER_INACTIVE'
        FROM  dual
    where not exists (select 'inactive buyer'
                      from PO_HEADERS_GT POH,
                           PO_BUYERS_V POB-- <Bug 11682620> Replace PO_BUYERS_VAL_V with PO_BUYERS_V
		      where poh.agent_id = pob.employee_id);

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

--<Bug 9040655 END>
----------------------------------------------------------------------------------
    l_progress := '051';
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END CHECK_PO_PA_HEADER;

--For PO
/**
* Private Procedure: CHECK_PO
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*       p_check_asl:        Determines whether to perform ASL checks...
*                           PO_SUB_ITEM_NOT_APPROVED, PO_SUB_ITEM_ASL_DEBARRED
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Updates PO_DISTRIBUTIONS table with RATE information.
*           Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure runs the document submission checks for POs
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*/
PROCEDURE check_po(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_textline  po_online_report_text.text_line%TYPE := NULL;
l_api_name  CONSTANT varchar2(40) := 'CHECK_PO';
l_progress VARCHAR2(3);
l_is_complex_po     boolean;
l_line_loc_token_value fnd_new_messages.message_text%TYPE;

TYPE NumTab is TABLE of NUMBER INDEX by BINARY_INTEGER;
l_quantity1 NumTab;
l_quantity2 NumTab;
l_line_num   NumTab;
l_shipment_num NumTab;
l_dist_num NumTab;
l_line_qty_tbl    NumTab;                                     -- <SERVICES FPJ>
l_line_amt_tbl    NumTab;                                     -- <SERVICES FPJ>
l_ship_qty_tbl    NumTab;                                     -- <SERVICES FPJ>
l_ship_amt_tbl    NumTab;                                     -- <SERVICES FPJ>
l_dist_qty_tbl    NumTab;                                     -- <SERVICES FPJ>
l_dist_amt_tbl    NumTab;                                     -- <SERVICES FPJ>
l_rowcount NumTab;

l_val_contract_limit NUMBER;                                  -- bug3673292

--bug#3987438
--A new table to hold the invalid ship to location codes
TYPE CharTab is TABLE of HR_LOCATIONS_ALL_TL.location_code%type INDEX by BINARY_INTEGER;
l_ship_to_location_tbl CharTab;
--bug#3987438

--<R12 eTax Integration Start>
l_return_status    VARCHAR2(1);
l_tax_status       VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_tax_message      fnd_new_messages.message_text%TYPE;
--<R12 eTax Integration End>

l_po_vmi_display_warning VARCHAR2(1);

BEGIN

l_progress := '000';
-- BUG 2687600 mbhargav
--Removed Update statement to update rate in po_distributions

l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 1: No lines');
   END IF;
END IF;

    -- Check 1: Header must have at least one line
    -- PO_SUB_HEADER_NO_LINES
    -- Message inserted is 'Purchase Document has no lines'
    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_HEADER_NO_LINES');
    INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
          creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
    SELECT  p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            0, 0, 0,
            p_sequence + ROWNUM,
            substr(l_textline,1,240),
            'PO_SUB_HEADER_NO_LINES'
    FROM   PO_HEADERS_GT POH
    WHERE  POH.po_header_id = p_document_id AND
           NOT EXISTS (SELECT 'Lines Exist'
                       FROM   PO_LINES_GT POL
                       WHERE  POL.po_header_id = POH.po_header_id
                       --Bug 3289638 Check for any line to exist irrespective of cancel_flag
                       --AND    nvl(POL.cancel_flag,'N') = 'N'
                       );

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
--------------------------------------------------

l_progress := '002';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 2: No shipment ');
   END IF;
END IF;

  -- Check 2: Each Purchase Order Line must have at least one shipment
    -- PO_SUB_LINE_NO_SHIP

  l_is_complex_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(p_document_id);

  IF (l_is_complex_po) THEN
    l_line_loc_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_LINE_LOC_TYPE_LOW_PAYITEMS');
  ELSE
    l_line_loc_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_LINE_LOC_TYPE_LOW_SCHEDULES');
  END IF;

  FND_MESSAGE.SET_NAME('PO','PO_SUB_LINE_NO_SHIP');
  FND_MESSAGE.SET_TOKEN('LINE_LOCATION_TYPE', l_line_loc_token_value);

  l_textline := FND_MESSAGE.GET;
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        POL.line_num,
        0,
        0,
        p_sequence + ROWNUM,
        substr(g_linemsg||g_delim||POL.line_num||g_delim||l_textline,1,240),
            'PO_SUB_LINE_NO_SHIP'
  FROM    PO_LINES_GT POL
    WHERE   POL.po_header_id = p_document_id AND
        nvl(POL.cancel_flag,'N') = 'N' AND
        nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED' AND
        NOT EXISTS (SELECT 'Shipments Exist'
                  FROM   PO_LINE_LOCATIONS_GT PLL
                  WHERE  PLL.po_line_id = POL.po_line_id AND
                       PLL.shipment_type in ('STANDARD','PLANNED'));

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
-------------------------------------------------

l_progress := '003';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 3: Atleast One dist ');
   END IF;
END IF;

     --Check 3: Each PO shipment must have atleast one distribution
     --PO_SUB_SHIP_NO_DIST

     IF (l_is_complex_po) THEN
       l_line_loc_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_LINE_LOC_TYPE_LOW_P_PAYITEM');
     ELSE
       l_line_loc_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_LINE_LOC_TYPE_LOWER_S_SCH');
     END IF;

     FND_MESSAGE.SET_NAME('PO', 'PO_SUB_SHIP_NO_DIST');
     FND_MESSAGE.SET_TOKEN('LINE_LOCATION_TYPE', l_line_loc_token_value);
     l_textline := FND_MESSAGE.GET;
     INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
     SELECT p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            POL.line_num,
            PLL.shipment_num,
            0,
            p_sequence + ROWNUM,
            substr(g_linemsg||g_delim||POL.line_num||g_delim||
                   g_shipmsg||g_delim||PLL.shipment_num||g_delim||l_textline,1,240),
            'PO_SUB_SHIP_NO_DIST'
     FROM   PO_LINE_LOCATIONS_GT PLL,PO_LINES_GT POL
     WHERE  PLL.po_line_id   = POL.po_line_id AND
            PLL.po_header_id = p_document_id AND
            nvl(PLL.cancel_flag, 'N')  = 'N' AND
            nvl(POL.cancel_flag, 'N')  = 'N' AND
            nvl(PLL.closed_code, 'OPEN') <> 'FINALLY CLOSED' AND
            PLL.shipment_type in ('STANDARD', 'PLANNED', 'PREPAYMENT') --<Complex Work R12>
            AND NOT EXISTS (SELECT 'Distribution Exists'
                            FROM   PO_DISTRIBUTIONS_GT POD
                            WHERE  POD.line_location_id = PLL.line_location_id);

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
-----------------------------------------------

l_progress := '004';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 4/5: Qty/Amt rollup checks');
   END IF;
END IF;

    -- Check 4: Quantities/Amounts between Purchase Order Line and Shipments
    -- must match.
    -- Check 5: The sum of the distribution quantities/amounts should match the
    -- shipment quantity/amount.

    --<Complex Work R12>: moved the rollup checks into a separate
    -- subprocedure call
    check_po_qty_amt_rollup(
       p_online_report_id => p_online_report_id
    ,  p_document_id => p_document_id
    ,  p_login_id => p_login_id
    ,  p_user_id => p_user_id
    ,  x_sequence => p_sequence --in out param
    );

-----------------------------------------------
l_progress := '006';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 6: Dist rate NULL' );
   END IF;
END IF;

  -- Check 6:  The rate cannot be NULL for the distribution if we are
    -- using a foreign currency.  We are using a foreign currency
    -- if the po header currency code is not the same as the sets of
    -- books currency code.
    -- PO_SUB_DIST_RATE_NULL

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_DIST_RATE_NULL');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
            POL.line_num,
            PLL.shipment_num,
            POD.distribution_num,
        p_sequence + ROWNUM,
          substr(g_linemsg||g_delim||POL.line_num||g_delim
                   ||g_shipmsg||g_delim||PLL.shipment_num||g_delim
                   ||g_distmsg||g_delim||POD.distribution_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_DIST_RATE_NULL'
    FROM PO_DISTRIBUTIONS_GT POD,PO_LINE_LOCATIONS_GT PLL,PO_LINES_GT POL,
         PO_HEADERS_GT POH,GL_SETS_OF_BOOKS SOB,FINANCIALS_SYSTEM_PARAMETERS FSP
    WHERE POD.po_header_id = POH.po_header_id
    AND POD.line_location_id = PLL.line_location_id
    AND PLL.po_line_id = POL.po_line_id
    AND POH.po_header_id = p_document_id
    AND nvl(PLL.cancel_flag,'N') = 'N'
    AND nvl(POL.cancel_flag,'N') = 'N'
    AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND PLL.shipment_type in ('STANDARD', 'PLANNED')
    AND SOB.set_of_books_id = FSP.set_of_books_id
    AND SOB.currency_code <> POH.currency_code
    AND (POD.rate is null
        OR (POH.rate_type <> 'User'
            AND POD.rate_date is null));


     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
--------------------------------------------

l_progress := '007';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 7: Dist rate NOT NULL');
   END IF;
END IF;

  -- Check 7: If using functional currency then rate has to be null.
    -- PO_SUB_DIST_RATE_NOT_NULL
  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_DIST_RATE_NOT_NULL');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
            POL.line_num,
            PLL.shipment_num,
            POD.distribution_num,
        p_sequence + ROWNUM,
          substr(g_linemsg||g_delim||POL.line_num||g_delim
                   ||g_shipmsg||g_delim||PLL.shipment_num||g_delim
                   ||g_distmsg||g_delim||POD.distribution_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_DIST_RATE_NOT_NULL'
    FROM PO_DISTRIBUTIONS_GT POD,PO_LINE_LOCATIONS_GT PLL,PO_LINES_GT POL,
         PO_HEADERS_GT POH,GL_SETS_OF_BOOKS SOB,FINANCIALS_SYSTEM_PARAMETERS FSP
    WHERE POD.po_header_id = POH.po_header_id
    AND POD.line_location_id = PLL.line_location_id
    AND PLL.po_line_id = POL.po_line_id
    AND POH.po_header_id = p_document_id
    AND nvl(PLL.cancel_flag,'N') = 'N'
    AND nvl(POL.cancel_flag,'N') = 'N'
    AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND PLL.shipment_type in ('STANDARD', 'PLANNED')
    AND SOB.set_of_books_id = FSP.set_of_books_id
    AND SOB.currency_code = POH.currency_code
    AND POD.rate is not null;

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
----------------------------------------------------

l_progress := '008';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 8: Contract Amount exceed check');
   END IF;
END IF;

  -- Check 8:  The amount of all standard purchase orders
    -- for a contract should not exceed the amount limit of the contract.
    -- PO_SUB_STD_CONTRACT_AMT_LIMIT

    -- bug3673292
    -- Take out val_contract_amount procedure call from the query.
    -- By doing that we can be sure that we call insert statement only when
    -- contract limit is exceeded.

    l_val_contract_limit := PO_CONTRACTS_S.val_contract_amount
                            ( x_po_header_id => p_document_id
                            );

    IF (l_val_contract_limit = 0) THEN

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_STD_CONTRACT_AMT_LIMIT');
        INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_STD_CONTRACT_AMT_LIMIT'
        FROM DUAL;

        --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;

    END IF;



-------------------------------------------------------------------------------

l_progress := '009';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 9: Ref to unapproved contract check ');
   END IF;
END IF;

  -- Check 9: Any of the standard PO's lines should not references an
    -- unapproved contract.
    -- PO_SUB_REF_UNAPPROVED_CONTRACT
    --< Bug 3422733 > Only do this check if Contract is not ON HOLD. The ON HOLD
    -- check is done later. Avoids showing 2 msgs for Contract that is ON HOLD.
    -- Bug 17198601,add condition NVL(POL.cancel_flag,'N') = 'N' to make sure
    -- the PO line is not canceled.
  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REF_UNAPPROVED_CONTRACT');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        POL.line_num,
        0,
        0,
        p_sequence + ROWNUM,
        substr(g_linemsg||g_delim||POL.line_num||g_delim||l_textline,1,240),
            'PO_SUB_REF_UNAPPROVED_CONTRACT'
    FROM PO_LINES_GT POL,
         PO_HEADERS_ALL POC   -- <GC FPJ> : use all table
    WHERE POL.po_header_id = p_document_id
    AND   POL.contract_id = POC.po_header_id    -- <GC FPJ>
    AND   POC.type_lookup_code = 'CONTRACT'
    AND   NVL(POL.cancel_flag,'N') = 'N'        -- Bug 17198601
  /* R12 GCPA
  + If Profile ALLOW_REFERENCING_CPA_UNDER_AMENDMENT is Y, then we can refer any Contract Which is approved Once
  + Else Contract should be in APPROVED state  */
  AND    ( (NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'),'N') = 'Y'
           AND POC.Approved_Date Is Null
	    )
	 or (  NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'),'N') = 'N'
          and nvl(POC.APPROVED_FLAG,'N') <> 'Y')
	 )
    AND   NVL(POC.user_hold_flag, 'N') <> 'Y';      --< Bug 3422733 >


    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
-------------------------------------------------------------------------------

l_progress := '010';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 10: Ref contract diff vendor');
   END IF;
END IF;

  -- Check 10: Any of the standard PO's lines should not reference a
    -- contract whose vendor is different than the one on PO header.
    -- PO_SUB_LINE_CONTRACT_MISMATCH

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_LINE_CONTRACT_MISMATCH');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        POL.line_num,
        0,
        0,
        p_sequence + ROWNUM,
        substr(g_linemsg||g_delim||POL.line_num||g_delim||l_textline,1,240),
            'PO_SUB_LINE_CONTRACT_MISMATCH'
    FROM PO_LINES_GT POL,
         PO_HEADERS_ALL POC,  -- <GC FPJ>: Use _ALL table
         PO_HEADERS_GT POH
    WHERE POH.po_header_id = p_document_id
    AND   POL.po_header_id = POH.po_header_id
    AND   POL.contract_id = POC.po_header_id  -- <GC FPJ>
    AND   POC.type_lookup_code = 'CONTRACT'
    AND   nvl(POC.cancel_flag , 'N') = 'N'
    AND   POC.vendor_id <> POH.vendor_id;

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
-----------------------------------

l_progress := '600';

-- Check 11: The PO GL date should be within an open purchasing period
-- PO_SUB_PO_INVALID_GL_DATE

--<FPJ ENCUMBRANCE>

IF (  PO_CORE_S.is_encumbrance_on(
         p_doc_type => g_document_type_PO
      ,  p_org_id => NULL
      )
   )
THEN

   l_progress := '610';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(g_log_head || '.'||l_api_name||'.',
                          l_progress,'PO 11: GL date');
   END IF;

   check_gl_date(
      p_doc_type => g_document_type_PO
   ,  p_online_report_id => p_online_report_id
   ,  p_login_id => p_login_id
   ,  p_user_id => p_user_id
   ,  p_sequence => p_sequence
   );

   l_progress := '620';

ELSE
   l_progress := '630';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(g_log_head || '.'||l_api_name||'.',
                          l_progress,'PO 11: PO encumbrance not on');
   END IF;
END IF;

---------------------------------------

l_progress := '012';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 12: UOM Interclass coversions');
   END IF;
END IF;

    -- Check 12: Invalid Interclass conversions between UOMs should not be allowed
    -- PO_SUB_UOM_CLASS_CONVERSION, PO_SUB_PO_INVALID_CLASS_CONV
    -- Message inserted is:
    --'Line# <LineNum> Following Interclass UOM conversion is not defined or
    -- is disabled <UOM1> <UOM2>'
    -- Bug #1630662
  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_UOM_CLASS_CONVERSION');
    INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
        message_name)
  --bug 19139821 begin
    SELECT p_online_report_id,
          p_login_id,
          p_user_id,
          sysdate,
          p_user_id,
          sysdate,
          POL.line_num,
          0,
          0,
          p_sequence + ROWNUM,
          SUBSTR(g_linemsg||g_delim||POL.line_num||g_delim||l_textline
                 || ' UOM on Purchase Order: '|| POL.UNIT_MEAS_LOOKUP_CODE
                 ||' , UOM on item: '|| MSI.PRIMARY_UNIT_OF_MEASURE,1,240),
          'PO_SUB_UOM_CLASS_CONVERSION'
    FROM PO_LINES_GT POL, MTL_SYSTEM_ITEMS_B MSI,
         FINANCIALS_SYSTEM_PARAMETERS FSP
    WHERE POL.item_id = MSI.inventory_item_id
      AND POL.item_id IS NOT NULL
      AND POL.UNIT_MEAS_LOOKUP_CODE <> MSI.PRIMARY_UNIT_OF_MEASURE
      AND POL.po_header_id = p_document_id
      AND MSI.organization_id = FSP.inventory_organization_id
      AND is_uom_conversion_exist(POL.UNIT_MEAS_LOOKUP_CODE, MSI.PRIMARY_UNIT_OF_MEASURE, POL.item_id) = 'N';
  -- bug 19139821 end

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
--------------------------------------------------

l_progress := '013';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 13: Item restricyed');
   END IF;
END IF;

  -- Check 13: If an item is restricted then the Purchase Order Vendor
    -- must be listed in the Approved Suppliers List table and must be approved.
    -- PO_SUB_ITEM_NOT_APPROVED
    -- History:
    /*
    ** Determine if an item is restricted.  If it is restricted the
    ** Purchase Order Vendor must be listed in the Approved Suppliers
    ** List table and must be approved.
    ** Bug 918932 sugupta
    ** Submission check for Blanket PO will follow the following ASL rules when
    **Use approved supplier flag is checked ON:
    ** 1) Global ASL's  with non-debarred supplier will allow approval all times.
    ** 2) Global ASL's with debarred supplier will disallow approval at all times.
    ** 3) If Global ASL is absent, any Local ASL with approved supplier will allow
    ** approval
    ** 4) If Global ASL is absent and all local ASL's have debarred supplier, approval
    **will fail.
    */
    /* Bug# 1109001: kagarwal
    ** Split the ASL check to ASL check for Blanket and PO.
    ** Also modified the query for performance.
    ** UNION is replaced with UNION ALL in all ASL checks
    ** In PO_SUB_ITEM_NOT_APPROVED the Sum clause has also been modified
    ** PO_SUB_ITEM_NOT_APPROVED for Standard PO
    ** PA_SUB_ITEM_NOT_APPROVED for Blanket/Contract PO
    */
    /* Bug# 1570115:          While checking for Restricted items the query was
    ** checking with FSP.inventory_organization_id to instead of checking with the
    ** PLL.SHIP_TO_ORGANIZATION_ID and not allowing the user to approve the
    ** document though it is not restricted in the ship to org which user has
    ** entered.  Changed the FSP.inventory_organization_id to
    ** PLL.SHIP_TO_ORGANIZATION_ID the query which check for PO.
    */
    /* Bug# 1761513: kagarwal
    ** Desc: Changed the ASL Rules:
    ** 1. If the ASL is defined at the commodity level and also at the item level,
    ** the item level ASL will be considered. But if the ASL is not defined at the
    ** item level then the ASL at the commodity level will be considered for that
    ** item.
    **
    ** Eg i): If A, B and C are approved suppliers at the commodity level and A and D are
    ** the approved suppliera at the item level, then A and D will be considered as
    ** approved suppliers for this item. Hence a PO for this item will get approved
    ** for Suppliers A and D but not for suppliers B and C.
    **
    ** Eg ii): If A, B and C are approved suppliers at the commodity level and there is
    ** no ASL defined at the item level, then A, B and C will be considered as approved
    ** supplier for this item. Hence a PO for this item will get approved for
    ** Suppliers A, B and C.
    **
    ** 2. If a Supplier is debarred at the commodity level even if it is approved
    ** supplier at the item level then this supplier will be considered debarred for
    ** this item.
    */
     /*Bug5597639 Modifying the below sql to ensure that whenever the item
     is restricted by checking 'Use approved supplier list' there should be
     atlease one approved ASL either at item level or at category level
     if there is no item ASL*/

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_ITEM_NOT_APPROVED');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        POL.line_num,
        PLL.shipment_num,
        0,
        p_sequence + ROWNUM,
        substr(g_linemsg||g_delim||POL.line_num||g_delim||
                   g_shipmsg||g_delim||PLL.shipment_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_ITEM_NOT_APPROVED'
    FROM MTL_SYSTEM_ITEMS MSI, PO_LINE_LOCATIONS_GT PLL,
         PO_LINES_GT POL, PO_HEADERS_GT POH,
         FINANCIALS_SYSTEM_PARAMETERS FSP
    WHERE POH.po_header_id = p_document_id
    AND POH.po_header_id = POL.po_header_id
    AND PLL.po_line_id(+) = POL.po_line_id
    AND PLL.po_release_id IS NULL
    AND MSI.organization_id = PLL.ship_to_organization_id
    AND MSI.inventory_item_id = POL.item_id
    AND POL.item_id is not null
    AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND nvl(POL.cancel_flag,'N') = 'N'
    AND nvl(PLL.cancel_flag,'N') = 'N'
    AND nvl(MSI.must_use_approved_vendor_flag,'N') = 'Y'
    AND NOT exists
      (SELECT 1
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR
        WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id, -1)
        AND    ASL.vendor_id = POH.vendor_id
	--Bug 16371892: Added the 'OR' clause below to match the vendor site code
	--for cases in which the vendor site IDs are different, but code is same.
        AND    (nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
		OR EXISTS (  SELECT  'vendor site code matches ASL'
                       FROM  po_vendor_sites_all pvs1, po_vendor_sites_all pvs2
                       WHERE  pvs1. vendor_site_id = ASL.vendor_site_id
                       and pvs2.vendor_site_id = POH.vendor_site_id
                       and pvs1.vendor_site_code = pvs2.vendor_site_code) )
        AND  ASL.item_id = POL.item_id
        AND    ASL.asl_status_id = ASR.status_id
        AND    ASR.business_rule = '1_PO_APPROVAL'
	AND   ASR.allow_action_flag = 'Y'    --Bug5597639
        UNION ALL
       SELECT  1
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR
        WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id, -1)
        AND    ASL.vendor_id = POH.vendor_id
        AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
        AND    ASL.item_id is NULL
        AND    not exists
           (SELECT ASL1.ASL_ID
            FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL1
            WHERE ASL1.ITEM_ID = POL.item_id
            AND ASL1.using_organization_id in
                (PLL.ship_to_organization_id, -1))
        AND    ASL.category_id in
           (SELECT MIC.category_id
            FROM   MTL_ITEM_CATEGORIES MIC
            WHERE MIC.inventory_item_id = POL.item_id
            AND MIC.organization_id = PLL.ship_to_organization_id)
        AND    ASL.asl_status_id = ASR.status_id
        AND    ASR.business_rule = '1_PO_APPROVAL'
        AND   ASR.allow_action_flag = 'Y');    --Bug5597639

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

-------------------------------------------------------------------------------

l_progress := '014';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO 14: ASL Debarred');
   END IF;
END IF;

    -- Check 14: If an item is restricted then the Purchase Order Vendor
    -- must be listed in the Approved Suppliers List table and must not be
    -- DEBARRED.
    -- PO_SUB_ITEM_ASL_DEBARRED

   /*Bug5597639 This check would throw an error message if atleast one ASL
    entry is debarred either for item /Category irrespective of 'Use approved
    supplier flag'. This check would apply even for one time items.
    If supplier is debarred in any of the ASL item/category (Global/Local)
    (Suplier/Supplier+site) then the approval of the PO will not be allowed */

l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_ITEM_ASL_DEBARRED');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        POL.line_num,
        PLL.shipment_num,
        0,
        p_sequence + ROWNUM,
        substr(g_linemsg||g_delim||POL.line_num||g_delim
                   ||g_shipmsg||g_delim||PLL.shipment_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_ITEM_ASL_DEBARRED'
     FROM PO_LINE_LOCATIONS_GT PLL,
         PO_LINES_GT POL, PO_HEADERS_GT POH,
         FINANCIALS_SYSTEM_PARAMETERS FSP
    WHERE POH.po_header_id = p_document_id
    AND POH.po_header_id = POL.po_header_id
    AND PLL.po_line_id(+) = POL.po_line_id
    AND PLL.po_release_id IS NULL
    AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND nvl(POL.cancel_flag,'N') = 'N'
    AND nvl(PLL.cancel_flag,'N') = 'N'
    AND exists
       (SELECT 1
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR,
	MTL_SYSTEM_ITEMS MSI  --Bug5597639
        WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id, -1)
	/*Bug5597639 Adding the below three conditions */
	AND MSI.organization_id = FSP.inventory_organization_id
	AND MSI.inventory_item_id = POL.item_id
	AND POL.item_id is not null
        AND    ASL.vendor_id = POH.vendor_id
        AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
        AND  ASL.item_id = POL.item_id
        AND    ASL.asl_status_id = ASR.status_id
        AND    ASR.business_rule = '1_PO_APPROVAL'
        AND    ASR.allow_action_flag <> 'Y' -- Bug 5724696
        UNION ALL
        SELECT 1
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR
        WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id, -1)
        AND    ASL.vendor_id = POH.vendor_id
        AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
        AND    ASL.item_id is NULL
	AND  POL.category_id = ASL.category_id  --Bug5597639
        AND    ASL.asl_status_id = ASR.status_id
        AND    ASR.business_rule = '1_PO_APPROVAL'
        AND    ASR.allow_action_flag <> 'Y' );  --Bug5597639

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;


----------------------------------------------------------------------------

-- <GC FPJ START>

    l_progress := '015';

    IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                       l_api_name||'.' || l_progress,
                       'PO 15: Contract ref on hold');
        END IF;
    END IF;

    -- Check 15: Contract referenced on a PO line should not be on hold
    --           (If contract is in incomplete status)

    l_textline := FND_MESSAGE.get_string('PO', 'PO_SUB_LINE_CONTRACT_HOLD');

    INSERT INTO po_online_report_text_gt(
       online_report_id,
       last_update_login,
       last_updated_by,
       last_update_date,
       created_by,
       creation_date,
       line_num,
       shipment_num,
       distribution_num,
       sequence,
       text_line,
       message_name
    )
    SELECT p_online_report_id,
           p_login_id,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate,
           POL.line_num,
           0,
           0,
           p_sequence + ROWNUM,
           SUBSTR (g_linemsg || g_delim || POL.line_num ||g_delim ||
                   l_textline,1,240),
           'PO_SUB_LINE_CONTRACT_HOLD'
    FROM   po_lines_gt POL,
           po_headers_gt POH,
           po_headers_all POC
    WHERE  POH.po_header_id = p_document_id
    AND    NVL(POH.authorization_status, 'INCOMPLETE') = 'INCOMPLETE'
    AND    POL.po_header_id = POH.po_header_id
    AND    POC.po_header_id = POL.contract_id
    AND    POC.user_hold_flag = 'Y';

    p_sequence := p_sequence + SQL%ROWCOUNT;

-----------------------------------------------------------------------------
--Bug 5525381
/* Commented the validation of checking for the contract start date.
    l_progress := '016';

    IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                       l_api_name||'.' || l_progress,
                       'PO 16: Contract ref effective dates');
        END IF;
    END IF;

    -- Check 16: Creation date of the contract should be within the effective
    --           dates of the contracts referenced

    l_textline := FND_MESSAGE.get_string('PO', 'PO_SUB_LINE_CONTRACT_EXP');

    INSERT INTO po_online_report_text_gt(
       online_report_id,
       last_update_login,
       last_updated_by,
       last_update_date,
       created_by,
       creation_date,
       line_num,
       shipment_num,
       distribution_num,
       sequence,
       text_line,
       message_name
    )
    SELECT p_online_report_id,
           p_login_id,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate,
           POL.line_num,
           0,
           0,
           p_sequence + ROWNUM,
           SUBSTR (g_linemsg || g_delim || POL.line_num ||g_delim ||
                   l_textline,1,240),
           'PO_SUB_LINE_CONTRACT_EXP'
    FROM   po_lines_gt POL,
           po_headers_gt POH,
           po_headers_all POC
    WHERE  POH.po_header_id = p_document_id
    AND    NVL(POH.authorization_status, 'INCOMPLETE') = 'INCOMPLETE'
    AND    POL.po_header_id = POH.po_header_id
    AND    POC.po_header_id = POL.contract_id
    AND    TRUNC(POL.creation_date) NOT BETWEEN NVL(TRUNC(POC.start_date),
                                                    POL.creation_date-1)
                                        AND     NVL(TRUNC(POC.end_date),
                                                    POL.creation_date+1);

    p_sequence := p_sequence + SQL%ROWCOUNT;*/

-----------------------------------------------------------------------------
 l_progress := '017';

    IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                       l_api_name||'.' || l_progress,
                       'PO 17: ATO/CTO Model items not allowed on POs');
        END IF;
    END IF;

    -- Check 17: ATO/CTO Model items not allowed on PO's (Bug 3362369)

    l_textline := FND_MESSAGE.get_string('PO', 'PO_ATO_ITEM_NA');

    --Bug10064616<START>
    INSERT INTO po_online_report_text_gt(
       online_report_id,
       last_update_login,
       last_updated_by,
       last_update_date,
       created_by,
       creation_date,
       line_num,
       shipment_num,
       distribution_num,
       sequence,
       text_line,
       message_name
    )
    SELECT p_online_report_id,
           p_login_id,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate,
           POL.line_num,
           0,
           0,
           p_sequence + ROWNUM,
           SUBSTR (g_linemsg || g_delim || POL.line_num ||g_delim ||
                   l_textline,1,240),
           'PO_ATO_ITEM_NA'
    FROM   po_lines_gt POL,
           po_headers_gt POH,
           financials_system_params_all FSP,
           mtl_system_items MSI
    WHERE  fsp.org_id = poh.org_id
    AND    POH.po_header_id = p_document_id
    AND    POL.po_header_id = POH.po_header_id
    AND    POL.item_id is not null
    AND    nvl(POL.cancel_flag, 'N') = 'N'                   --5353423
    AND    nvl(POL.closed_code, 'OPEN') <> 'FINALLY CLOSED'  --5353423
    AND    POL.item_id = MSI.inventory_item_id
    AND    MSI.organization_id = FSP.inventory_organization_id
    AND    MSI.bom_item_type in (1,2);
     --Bug10064616<END>
    p_sequence := p_sequence + SQL%ROWCOUNT;

-----------------------------------------------------------------------------


/*Start Bug #3512688 */
      /* Check 18 : To check the validity of the item at line level for newly added  line */
      l_progress := '018';
      IF g_debug_stmt  THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
      l_api_name||'.' || l_progress,
      'PO 18: Non Purchasable Item is not allowed');
      END IF;
      END IF;
      l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_ALL_NO_ITEM');

      --Bug10064616<START>
      INSERT INTO po_online_report_text_gt(online_report_id,
      last_update_login,
      last_updated_by,
      last_update_date,
      created_by,
      creation_date,
      line_num,
      shipment_num,
      distribution_num,
      sequence,
      text_line,
      message_name)
      SELECT  p_online_report_id,
      p_login_id,
      p_user_id,

     sysdate,
      p_user_id,
      sysdate,
      pl.line_num,
      0,
      0,
      p_sequence + ROWNUM,
       substr(g_linemsg||g_delim||pl.line_num||g_delim||l_textline,1,240),
      'PO_ALL_NO_ITEM'
      from po_headers_gt ph, po_lines_gt pl,mtl_system_items  itm,financials_system_params_all fsp,po_line_types_b plt
      where fsp.org_id = ph.org_id
      and   itm.inventory_item_id  = pl.item_id
      and   pl.item_id is not null
      and   itm.organization_id    = fsp.inventory_organization_id
      and   itm.purchasing_enabled_flag = 'N'
      and   ph.po_header_id = p_document_id
      and   pl.po_header_id = ph.po_header_id
      and   pl.line_type_id = plt.line_type_id
      and   nvl(plt.outside_operation_flag,'N') =  nvl(itm.outside_operation_flag,'N')
      and   (pl.creation_date >= nvl(ph.approved_date ,pl.creation_date));
      --Bug10064616<END>
      --Increment the p_sequence with number of errors reported in last query
      p_sequence := p_sequence + SQL%ROWCOUNT;

      -----------------------5601    /* Check 19 : To check the validity of the item at shipment level for newly added  line */
      l_progress := '019';
      IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
     l_api_name||'.' || l_progress,
      'PO 19: Non Purchasable Item is not allowed');     END IF;
      END IF;
      l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_ALL_NO_ITEM');
      INSERT INTO po_online_report_text_gt(online_report_id,
      last_update_login,
      last_updated_by,
      last_update_date,
      created_by,
      creation_date,
      line_num,
      shipment_num,
      distribution_num,
      sequence,
      text_line,
      message_name)
      SELECT  p_online_report_id,
      p_login_id,
      p_user_id,
      sysdate,
      p_user_id,
      sysdate,
      pl.line_num,
      pll.shipment_num,
      0,
      p_sequence + ROWNUM,
      substr(g_linemsg||g_delim||pl.line_num||g_delim||
       g_shipmsg||g_delim||pll.shipment_num||g_delim||l_textline,1,240),
      'PO_ALL_NO_ITEM'
      from po_headers_gt ph,po_lines_gt pl,po_line_locations_gt  pll,mtl_system_items itm,po_line_types_b plt
    where itm.inventory_item_id  = pl.item_id
    and   pl.item_id is not null
      and   itm.organization_id    = pll.ship_to_organization_id
      and   itm.purchasing_enabled_flag = 'N'
      and   pl.po_line_id   = pll.po_line_id
      and   ph.po_header_id = pll.po_header_id
      and   ph.po_header_id = p_document_id
      and   pl.po_header_id = ph.po_header_id
      and   pl.line_type_id = plt.line_type_id
      and   nvl(plt.outside_operation_flag,'N') =  nvl(itm.outside_operation_flag,'N')
      and   (pl.creation_date >= nvl(ph.approved_date,pl.creation_date))
      and   pll.shipment_type <> 'PREPAYMENT' --<Complex Work R12>
      and   pll.po_release_id is null;


      --Increment the p_sequence with number of errors reported in last query
      p_sequence := p_sequence + SQL%ROWCOUNT;

--End Bug #3512688
------------------------------------------------------------------------------------------

 l_progress := '020';

    IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                       l_api_name||'.' || l_progress,
                       'PO 20: Either Promised/Need by date required for planned items');
        END IF;
    END IF;

    -- Check 20: Either Promised Date or Need by date is required for planned
    -- items (ECO 4503425 for HTML Orders R12)

    l_textline := FND_MESSAGE.get_string('PO', 'PO_PO_PLANNED_ITEM_DATE_REQ');

    INSERT INTO po_online_report_text_gt(
       online_report_id,
       last_update_login,
       last_updated_by,
       last_update_date,
       created_by,
       creation_date,
       line_num,
       shipment_num,
       distribution_num,
       sequence,
       text_line,
       message_name
    )
    SELECT p_online_report_id,
           p_login_id,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate,
           POL.line_num,
           PLL.shipment_num,
           0,
           p_sequence + ROWNUM,
           SUBSTR (g_linemsg || g_delim || POL.line_num ||g_delim ||
             g_shipmsg || g_delim || PLL.shipment_num ||g_delim || l_textline,1,240),
           'PO_PO_PLANNED_ITEM_DATE_REQ'
    FROM   po_lines_gt POL,
           po_headers_gt POH,
           po_line_locations_gt PLL,
           mtl_system_items MSI
    WHERE  POH.po_header_id = p_document_id
    AND    POL.po_header_id = POH.po_header_id
    AND    POL.po_line_id = PLL.po_line_id
    AND    PLL.po_header_id = POH.po_header_id
    AND    POL.item_id is not null
    AND    PLL.need_by_date is null
    AND    PLL.promised_date is null
    AND    PLL.shipment_type <> 'PREPAYMENT' --bug 4997671 <Complex Work R12>
    AND    POL.item_id = MSI.inventory_item_id
    AND    nvl(POL.cancel_flag, 'N') = 'N'                   --8518511 including the cancel condition for the planned item data check
    AND    nvl(POL.closed_code, 'OPEN') <> 'FINALLY CLOSED'  --8518511
    AND    MSI.organization_id = PLL.SHIP_TO_ORGANIZATION_ID --bug19079582
    AND    (MSI.mrp_planning_code IN (3,4,7,8,9) OR
            MSI.inventory_planning_code IN (1,2) );

    p_sequence := p_sequence + SQL%ROWCOUNT;


-----------------------------------------------
--Bug5075191
--Following submission check should exclude cancelled/finally closed lines.
--Adding those conditions.
--bug#3987438
--Added a new submission check to validate the
--ship to location at the shipment level.
--Bug#12396691 (12597960)
--Modified the closed_code condition. The shipments which are in OPEN or
-- Requires ReApproval State should be considered to validate the ship to
--location

IF g_debug_stmt THEN
   FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO : Invalid Ship To Locations');
END IF;

    SELECT  pol.line_num,
            poll.shipment_num,
            hlat.location_code
    BULK COLLECT INTO
            l_line_num,
            l_shipment_num,
            l_ship_to_location_tbl
    FROM
            po_lines_gt pol,
            po_line_locations_gt poll,
            hr_locations_all hla,
            hr_locations_all_tl hlat
    WHERE poll.po_header_id=p_document_id
    and pol.po_Header_id=p_document_id
    and pol.po_line_id = poll.po_line_id
    and poll.ship_to_location_id = hla.location_id
    and nvl(poll.cancel_flag,'N') = 'N'
     --and nvl(poll.closed_code,'OPEN') <> 'FINALLY CLOSED'--Bug#12396691
    and (nvl(poll.closed_code,'OPEN') = 'OPEN' OR NVL(poll.APPROVED_FLAG,'N') = 'R')--Bug#12396691
    and hla.location_id = hlat.location_id
    and nvl (trunc (hla.inactive_date), trunc (sysdate)+1 )<= trunc (sysdate)
    and hlat.language=userenv('lang');

    FOR i IN 1..l_line_num.COUNT LOOP
        l_rowCount(i) := i;
    END LOOP;

    FORALL i IN 1..l_line_num.COUNT
    INSERT INTO po_online_report_text_gt (online_report_id,
      last_update_login,
      last_updated_by,
      last_update_date,
      created_by,
      creation_date,
      line_num,
      shipment_num,
      distribution_num,
      sequence,
      text_line,
      message_name)
    VALUES(
            p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            l_line_num(i),
            l_shipment_num(i),
            NULL,                                             -- <SERVICES FPJ>
            p_sequence+l_rowCount(i),
            PO_CORE_S.get_translated_text
                (   'PO_SUB_SHIPTO_LOC_INVALID'
                ,   'LINE_NUM', l_line_num(i)
                ,   'SHIPMENT_NUM', l_shipment_num(i)
                ,   'SHIP_TO_LOC', l_ship_to_location_tbl(i)
                ),
            'PO_SUB_PO_SHIPTO_LOC_INVALID'
        );

    p_sequence := p_sequence + l_line_num.COUNT;

--bug#3987438 END

-----------------------------------------------------------------------------

    l_progress := '021';
--<R12 eTax Integration Start>
-----------------------------------------------------------------------------

    l_tax_status := po_tax_interface_pvt.calculate_tax_yes_no(p_po_header_id    => p_document_id,
                                                              p_po_release_id   => NULL,
                                                              p_req_header_id   => NULL);
    l_progress := '022';
    IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head ||l_api_name||'.' ||
                        l_progress, 'PO 21: Recalculate tax before approval = ' || l_tax_status);
        END IF;
    END IF;

    IF l_tax_status = 'Y' THEN
      IF g_debug_stmt THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head ||
                         l_api_name||'.' || l_progress,
                         'PO 22: Calculate tax as the current one is not correct');
          END IF;
      END IF;
      l_progress := '023';
      po_tax_interface_pvt.calculate_tax( x_return_status    => l_return_status,
                                          p_po_header_id     => p_document_id,
                                          p_po_release_id    => NULL,
                                          p_calling_program  => g_action_DOC_SUBMISSION_CHECK);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF g_debug_stmt THEN
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head ||
                            l_api_name||'.' || l_progress,
                            'PO 23: Calculate tax has errored out');
             END IF;
         END IF;
         l_tax_message := fnd_message.get_string('PO','PO_TAX_CALCULATION')||' : ' ;
         FOR i IN 1..po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT.COUNT
	LOOP
            INSERT INTO po_online_report_text_gt
            (
             online_report_id,
             last_update_login,
             last_updated_by,
             last_update_date,
             created_by,
             creation_date,
             line_num,
             shipment_num,
             distribution_num,
             sequence,
             text_line,
             message_name,
             message_type
            )
            VALUES
            (
              p_online_report_id,
              p_login_id,
              p_user_id,
              sysdate,
              p_user_id,
              sysdate,
              po_tax_interface_pvt.G_TAX_ERRORS_TBL.line_num(i),
              po_tax_interface_pvt.G_TAX_ERRORS_TBL.shipment_num(i),
              po_tax_interface_pvt.G_TAX_ERRORS_TBL.distribution_num(i),
              p_sequence + i, /* 11851142 replaced rownum with i */
              l_tax_message || po_tax_interface_pvt.G_TAX_ERRORS_TBL.message_text(i),
              'PO_TAX_CALCULATION_FAILED',
              'E'
            );
	END LOOP;
        l_progress := '024';
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF g_debug_stmt THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head ||
                            l_api_name||'.' || l_progress,
                            'PO 24: Calculate tax raised unexpected error');
           END IF;
        END IF;
        l_textline := l_progress ||' - ';
        IF po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT.COUNT > 0 THEN
          l_textline := l_textline || po_tax_interface_pvt.G_TAX_ERRORS_TBL.MESSAGE_TEXT(1);
        ELSE
          l_textline := l_textline || SQLERRM();
        END IF;
        fnd_message.set_name('PO','PO_TAX_CALC_UNEXPECTED_ERROR');
        fnd_message.set_token('ERROR',l_textline);
        FND_MSG_PUB.Add;
        l_progress := '025';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    p_sequence := p_sequence + SQL%ROWCOUNT;

--<R12 eTax Integration End>

-----------------------------------------------------------------------------

 l_progress := '026';

    IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                       l_api_name||'.' || l_progress,
                       'PO 25: A VMI relationship exists for this item');
        END IF;
    END IF;

    -- Check 22: If the profile option PO_VMI_DISPLAY_WARNING is on,
    -- display a warning if the item has a VMI relationship.

    -- Flag indicating if profile PO_VMI_DISPLAY_WARNING is on
    fnd_profile.get(PO_PROFILES.PO_VMI_DISPLAY_WARNING,l_po_vmi_display_warning);

    IF (l_po_vmi_display_warning = 'Y') THEN

      l_textline := FND_MESSAGE.get_string('PO', 'PO_SUB_VMI_ASL_EXISTS');

      INSERT INTO po_online_report_text_gt(
         online_report_id,
         last_update_login,
         last_updated_by,
         last_update_date,
         created_by,
         creation_date,
         line_num,
         shipment_num,
         distribution_num,
         sequence,
         text_line,
         message_name,
         message_type
      )
      SELECT p_online_report_id,
             p_login_id,
             p_user_id,
             sysdate,
             p_user_id,
             sysdate,
             POL.line_num,
             PLL.shipment_num,
             0,
             p_sequence + ROWNUM,
             SUBSTR (g_linemsg || POL.line_num || g_delim ||
                     g_shipmsg || PLL.shipment_num || g_delim ||
                     l_textline,
                     1,240),
             'PO_SUB_VMI_ASL_EXISTS',
             'W'
      FROM   PO_LINES_GT POL,
             PO_HEADERS_GT POH,
             PO_LINE_LOCATIONS_GT PLL,
             PO_APPROVED_SUPPLIER_LIS_VAL_V PASL,
             PO_ASL_ATTRIBUTES PAA,
             PO_ASL_STATUS_RULES_V PASR

      WHERE  POH.po_header_id = p_document_id
      AND    POL.po_header_id = POH.po_header_id
      AND    PLL.po_header_id = POH.po_header_id
      AND    PLL.po_line_id   = POL.po_line_id

      -- item is not null
      AND    POL.item_id IS NOT NULL

      -- Document is standard PO
      AND    POH.type_lookup_code = 'STANDARD'

      --VMI is enabled
      AND    PASL.item_id = POL.item_id
      AND    PASL.vendor_id = POH.vendor_id
      AND    nvl(PASL.vendor_site_id,-1) = nvl(POH.vendor_site_id,-1)
      AND    PASL.using_organization_id IN (PLL.ship_to_organization_id, -1)
      AND    PASR.status_id = PASL.asl_status_id
      AND    PASR.business_rule = '2_SOURCING'
      AND    PASR.allow_action_flag = 'Y'
      AND    PASL.asl_id = PAA.asl_id
      AND    PAA.enable_vmi_flag = 'Y'
      AND    PAA.using_organization_id =
               (SELECT max(paa2.using_organization_id)
                FROM   po_asl_attributes paa2
                WHERE  paa2.asl_id = pasl.asl_id
                AND    paa2.using_organization_id IN (-1, PLL.ship_to_organization_id));

    END IF;

    p_sequence := p_sequence + SQL%ROWCOUNT;

-------------------------------------------------------------------------

    l_progress := '027';
    IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                       l_api_name||'.' || l_progress,
                       'PO 23: Validate OKE Contract Details');
        END IF;
    END IF;

    -- Bug 7001748: Added new validation check
    -- Check 23: Validate OKE Contract Version, Line Id and Deliverable Id.

    -- Check 23a: Validate Contract Version
    INSERT INTO po_online_report_text_gt
               (online_report_id,
                last_update_login,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                line_num,
                shipment_num,
                distribution_num,
                SEQUENCE,
                text_line,
                message_name)
    SELECT p_online_report_id,
           p_login_id,
           p_user_id,
           SYSDATE,
           p_user_id,
           SYSDATE,
           pol.line_num,
           0,
           0,
           p_sequence + ROWNUM,
           po_core_s.GET_TRANSLATED_TEXT('PO_INVALID_OKE_CONTRACT_VER_ID',
                                         'LINE_NUM',pol.line_num),
           'PO_INVALID_OKE_CONTRACT_VER_ID'
    FROM   po_lines_gt pol
    WHERE  pol.oke_contract_version_id IS NOT NULL
     AND NVL(pol.cancel_flag,'N') = 'N' --<Bug 11784215>--
           AND pol.oke_contract_version_id NOT IN (SELECT major_version
                                                   FROM   oke_k_vers_numbers_v
                                                   WHERE  chr_id = pol.oke_contract_header_id
                                                   UNION
                                                   SELECT major_version
                                                   FROM   okc_k_vers_numbers_h
                                                   WHERE  chr_id = pol.oke_contract_header_id);

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

    -- Check 23b: Validate Contract Line Id
    INSERT INTO po_online_report_text_gt
               (online_report_id,
                last_update_login,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                line_num,
                shipment_num,
                distribution_num,
                SEQUENCE,
                text_line,
                message_name)
    SELECT p_online_report_id,
           p_login_id,
           p_user_id,
           SYSDATE,
           p_user_id,
           SYSDATE,
           pol.line_num,
           pos.shipment_num,
           pod.distribution_num,
           p_sequence + ROWNUM,
           po_core_s.GET_TRANSLATED_TEXT('PO_INVALID_OKE_CONTRACT_LNE_ID',
                                         'LINE_NUM',pol.line_num,
                                         'SHIP_NUM',pos.shipment_num,
                                         'DIST_NUM',pod.distribution_num),
           'PO_INVALID_OKE_CONTRACT_LNE_ID'
    FROM   po_distributions_gt pod,
           po_line_locations_gt pos,
           po_lines_gt pol
    WHERE  pod.po_line_id = pol.po_line_id
           AND pod.line_location_id = pos.line_location_id
           AND pod.oke_contract_line_id IS NOT NULL
          AND NVL(pol.cancel_flag,'N') = 'N'  --<Bug 11784215>--
           AND pod.oke_contract_line_id NOT IN (SELECT id
                                                FROM   okc_k_lines_b
                                                WHERE  dnz_chr_id = pol.oke_contract_header_id
                                                -- <Bug 7695529>
                                                -- Look for contract lines in oke_deliverables_b also (DTS flow)
                                                UNION
                                                SELECT deliverable_id
                                                FROM   oke_deliverables_b
                                                WHERE  source_header_id = pol.oke_contract_header_id);

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

    -- Check 23c: Validate Contract Deliverable Id
    INSERT INTO po_online_report_text_gt
               (online_report_id,
                last_update_login,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                line_num,
                shipment_num,
                distribution_num,
                SEQUENCE,
                text_line,
                message_name)
    SELECT p_online_report_id,
           p_login_id,
           p_user_id,
           SYSDATE,
           p_user_id,
           SYSDATE,
           pol.line_num,
           pos.shipment_num,
           pod.distribution_num,
           p_sequence + ROWNUM,
           po_core_s.GET_TRANSLATED_TEXT('PO_INVALID_OKE_CONTRACT_DLV_ID',
                                         'LINE_NUM',pol.line_num,
                                         'SHIP_NUM',pos.shipment_num,
                                         'DIST_NUM',pod.distribution_num),
           'PO_INVALID_OKE_CONTRACT_DLV_ID'
    FROM   po_distributions_gt pod,
           po_line_locations_gt pos,
           po_lines_gt pol
    WHERE  pod.po_line_id = pol.po_line_id
           AND pod.line_location_id = pos.line_location_id
           AND pod.oke_contract_deliverable_id IS NOT NULL
	   AND NVL(pol.cancel_flag,'N') = 'N' --<Bug 11784215>--
           AND pod.oke_contract_deliverable_id NOT IN (SELECT deliverable_id
                                                       FROM   oke_k_deliverables_b
                                                       WHERE  k_line_id = pod.oke_contract_line_id
                                                       -- <Bug 7695529>
                                                       -- Look for contract deliverables in
                                                       -- oke_deliverable_actions also (DTS flow)
                                                       UNION
                                                       SELECT action_id
                                                       FROM   oke_deliverable_actions
                                                       WHERE  deliverable_id = pod.oke_contract_line_id);

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

    --BUG 10161562 : For Complex PO, the check is not required as the individula pay item price may vary from the Line unit price.
    --               the Sum of pay items price will be equal to the line price.
    IF NOT l_is_complex_po THEN
    --Bug 9430831 start.Submission Check for unit_price and price_override mismatch
            FOR price_rec in (select pol.line_num,poll.shipment_num,pol.unit_price, poll.price_override,rownum
                              from po_line_locations_gt poll, po_lines_gt pol
                              where pol.po_header_id = p_document_id AND
                  		  pol.po_line_id = poll.po_line_id AND
                              pol.unit_price <> poll.price_override AND
                              nvl(pol.cancel_flag,'N') = 'N' AND
                              nvl(poll.cancel_flag,'N') = 'N' AND  -- 16606537
                              nvl(pol.closed_code,'OPEN') <> 'FINALLY CLOSED' AND
                              poll.shipment_type in ('STANDARD','PLANNED')
                              )
            LOOP
            	FND_MESSAGE.SET_NAME('PO','PO_PDOI_SHIP_PRICE_NE_LINE');
            	FND_MESSAGE.SET_TOKEN('SHIP_PRICE', price_rec.price_override);
            	FND_MESSAGE.SET_TOKEN('LINE_PRICE',price_rec.unit_price);
            	l_textline := FND_MESSAGE.GET;

            INSERT INTO po_online_report_text_gt
                            (online_report_id,
                            last_update_login,
                            last_updated_by,
                            last_update_date,
                            created_by,
                            creation_date,
                            line_num,
                            shipment_num,
                            SEQUENCE,
                            text_line,
                            message_name)
            VALUES (p_online_report_id,
                       p_login_id,
                       p_user_id,
                       SYSDATE,
                       p_user_id,
                       SYSDATE,
                       price_rec.line_num,
                       price_rec.shipment_num,
                       p_sequence + price_rec.rownum,
                       l_textline,
                       'PO_PDOI_SHIP_PRICE_NE_LINE');

             --Increment the p_sequence with number of errors reported in last query
            p_sequence := p_sequence + SQL%ROWCOUNT;
            END LOOP;
    --End Bug 9430831

     END IF;
     -- Bug 10161562 ends
    ----------------------------------------------------------------------------
    l_progress := '028';
    IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                           l_api_name||'.' || l_progress,'PO 24: Validate the LCM enabled PO to check whether its invoice match option is set as Receipt');
            END IF;
        END IF;
        -- Check 24: Validate the LCM enabled PO to check whether its invoice match option is set as 'Receipt'.
        l_textline := FND_MESSAGE.GET_STRING('PO','PO_SUB_PO_SHIP_INV_MATCH_NE_R');
        INSERT INTO po_online_report_text_gt (online_report_id,
      		                          last_update_login,
    	 				  last_updated_by,
    	 				  last_update_date,
    	 				  created_by,
    	 				  creation_date,
    	 				  line_num,
    	 				  shipment_num,
    	 				  distribution_num,
    	 				  sequence,
    	 				  text_line,
    	          			  message_name)
        SELECT p_online_report_id,
    	   p_login_id,
    	   p_user_id,
    	   sysdate,
    	   p_user_id,
    	   sysdate,
    	   pol.line_num,
    	   pll.shipment_num, 0,
    	   p_sequence + ROWNUM,
    	   substr(g_linemsg||g_delim||POL.line_num||g_delim||g_shipmsg||g_delim||
    		  PLL.shipment_num||g_delim||l_textline,1,240),
    	   'PO_SUB_PO_SHIP_INV_MATCH_NE_R'
          FROM PO_HEADERS_GT POH,
               PO_LINES_GT POL,
    	   PO_LINE_LOCATIONS_GT PLL
         WHERE POH.po_header_id = POL.po_header_id
           AND POL.po_line_id = PLL.po_line_id
           AND POH.po_header_id  = p_document_id
           AND Nvl(PLL.LCM_FLAG,'N') = 'Y'
           AND Nvl(PLL.match_option,'P') <> 'R'
	   AND Nvl(PLL.cancel_flag,'N') = 'N'; -- Bug 13809830: Added a condition to skip the submission check for cancelled shipments

        --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;

        -----------------------------------------------------------------------------------

        l_progress := '029';
        IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                           l_api_name||'.' || l_progress,'PO 25: Validate the LCM enabled PO to check whether its destination type is set as Inventory');

            END IF;


        END IF;
        -- Check 25: Validate the LCM enabled PO to check whether its destination type is set as 'Inventory'
        l_textline := FND_MESSAGE.GET_STRING('PO','PO_SUB_PO_DIST_DEST_TYPE_NE_IN');
        INSERT INTO po_online_report_text_gt (online_report_id,
    	 				  last_update_login,
    	 				  last_updated_by,
    	 				  last_update_date,
    	 				  created_by,
    	 				  creation_date,
    	 				  line_num,
    	 				  shipment_num,
    	 				  distribution_num,
    	 				  sequence,
    	 				  text_line,
    	                                  message_name)
        SELECT p_online_report_id,
    	   p_login_id,
    	   p_user_id,
    	   sysdate,
    	   p_user_id,
    	   sysdate,
    	   pol.line_num,
    	   pll.shipment_num,
    	   pod.distribution_num,
    	   p_sequence + ROWNUM,
    	   substr(g_linemsg||g_delim||POL.line_num||g_delim||g_shipmsg||g_delim||PLL.shipment_num||g_delim
    	          ||g_distmsg||g_delim||POD.distribution_num||g_delim||l_textline,1,240),
    	   'PO_SUB_PO_DIST_DEST_TYPE_NE_IN'
          FROM PO_HEADERS_GT POH,
               PO_LINES_GT POL,
    	   PO_LINE_LOCATIONS_GT PLL,
    	   PO_DISTRIBUTIONS_GT POD
         WHERE POH.po_header_id = POD.po_header_id
           AND POD.line_location_id = PLL.line_location_id
           AND PLL.po_line_id = POL.po_line_id
           AND POH.po_header_id = p_document_id
           AND Nvl(POD.LCM_FLAG,'N') = 'Y'
           AND POD.DESTINATION_TYPE_CODE <> 'INVENTORY';


        --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;

    -------------------------------------------------------------------------------------------------------
--------<Bug 17244460 Start>----------------------
        -- Check 26: This checks if both need_by_date/promised_date fall under the open purchase period in line/shipment
        l_progress := '030';
        IF NVL(fnd_profile.value('PO_CHECK_OPEN_PERIODS'),'N') = 'Y' THEN
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(g_log_head || '.'||l_api_name||'.',
                             l_progress,'PO 26: checks if both need_by_date/promised_date fall under the open purchase period in line/shipment');
          END IF;

	      -- Bug 17625184 start: Modify the WHERE clause of NOT EXISTS subquery to make
          -- submission check not throwing error when Need-by Date or Promised Date was
          -- not provided for general item.
          l_textline := FND_MESSAGE.GET_STRING('PO','RCV_ALL_OPEN_PO_PERIOD_HTML');
          INSERT INTO po_online_report_text_gt (online_report_id,
                           last_update_login,
                           last_updated_by,
                           last_update_date,
                           created_by,
                           creation_date,
                           line_num,
                           shipment_num,
                           distribution_num,
                           sequence,
                           text_line,
                           message_name)
          SELECT p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            pol.line_num,
            pll.shipment_num,
            0,
            p_sequence + ROWNUM,
            substr(REPLACE(l_textline, '&'||'LINE_NUM', POL.line_num||g_delim||g_shipmsg||g_delim||PLL.shipment_num),1,240),
            'RCV_ALL_OPEN_PO_PERIOD_HTML'
           FROM PO_HEADERS_GT POH,
               PO_LINES_GT POL,
               PO_LINE_LOCATIONS_GT PLL
           WHERE POH.po_header_id            = p_document_id
           AND POL.po_header_id              = POH.po_header_id
           AND PLL.po_line_id                = POL.po_line_id
           AND nvl(POL.cancel_flag, 'N')     = 'N'
           AND nvl(PLL.approved_flag, 'N')   <> 'Y' --bug 17482087
           AND nvl(POL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
           AND NOT EXISTS
            (select 'Y'
            from GL_PERIOD_STATUSES PO_PERIOD,
              FINANCIALS_SYSTEM_PARAMETERS FSP
            where PO_PERIOD.set_of_books_id      = FSP.set_of_books_id
            AND PO_PERIOD.application_id         = 201
            AND PO_PERIOD.adjustment_period_flag = 'N'
            AND PO_PERIOD.closing_status        IN ('O','F')
            AND ( ( TRUNC(nvl(PLL.need_by_date,PO_PERIOD.start_date))
                      between TRUNC(PO_PERIOD.start_date) and TRUNC(PO_PERIOD.end_date) )
                  OR ( TRUNC(nvl(PLL.promised_date,PO_PERIOD.start_date))
                      between TRUNC(PO_PERIOD.start_date) and TRUNC(PO_PERIOD.end_date) )
                )
            );
      -- Bug 17625184 end
         --Increment the p_sequence with number of errors reported in last query
         p_sequence := p_sequence + SQL%ROWCOUNT;
      END IF;
--------<Bug 17244460 End>----------------------

        -- Bug 17703679 start: add submission check to validate Sponsored Project - Award Reference
        -- should not be provided for EIB Items when "Grants" is enabled.
        l_progress := '031';
        IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                           l_api_name||'.' || l_progress,'PO 27: Validate Sponsored Project - Award Reference
                           should not be provided for EIB Items when "Grants" is enabled');

            END IF;
        END IF;

        -- Check 27: Validate Sponsored Project - Award Reference should not be
        -- provided for EIB Items when "Grants" is enabled.
        l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_EIB_ITEM_NO_AWARD');
	      INSERT INTO po_online_report_text_gt(online_report_id,
                    last_update_login,
                    last_updated_by,
                    last_update_date,
                    created_by,
                    creation_date,
                    line_num,
                    shipment_num,
                    distribution_num,
                    sequence,
                    text_line,
                    message_name)
        SELECT  p_online_report_id,
                p_login_id,
                p_user_id,
                sysdate,
                p_user_id,
                sysdate,
                POL.line_num,
                PLL.shipment_num,
                POD.distribution_num,
                p_sequence + ROWNUM,
                substr(g_linemsg||g_delim||POL.line_num||g_delim||g_shipmsg||g_delim||PLL.shipment_num||g_delim
                  ||g_distmsg||g_delim||POD.distribution_num||g_delim||l_textline,1,240),
                  'PO_EIB_ITEM_NO_AWARD'
        FROM PO_HEADERS_GT POH,
             PO_LINES_GT POL,
             PO_LINE_LOCATIONS_GT PLL,
             PO_DISTRIBUTIONS_GT POD,
             MTL_SYSTEM_ITEMS MSI
        WHERE POH.po_header_id    = p_document_id
          AND POL.po_header_id      = POH.po_header_id
          AND PLL.po_line_id        = POL.po_line_id
          AND POD.line_location_id  = PLL.line_location_id
          AND MSI.inventory_item_id = POL.item_id
          AND MSI.organization_id = PLL.ship_to_organization_id
          AND nvl(MSI.comms_nl_trackable_flag, 'N') = 'Y'
          AND POD.AWARD_ID is not NULL;

        --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;
        -- Bug 17703679 end
------------------------------------------------------------------------------------

        -- Bug 13527787 start: Check MATCHING_BASIS on Line/Shipment is NULL or not
        l_progress := '032';
        IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                           l_api_name||'.' || l_progress,'PO 28: Check MATCHING_BASIS on Line/Shipment is NULL or not');

            END IF;
        END IF;

        l_textline := FND_MESSAGE.GET_STRING('PO','PO_MATCHING_BASIS_NULL');
        INSERT INTO po_online_report_text_gt (online_report_id,
                           last_update_login,
                           last_updated_by,
                           last_update_date,
                           created_by,
                           creation_date,
                           line_num,
                           shipment_num,
                           distribution_num,
                           sequence,
                           text_line,
                           message_name)
        SELECT p_online_report_id,
           p_login_id,
           p_user_id,
           sysdate,
           p_user_id,
           sysdate,
           0,
           PLL.shipment_num,
           0,
           p_sequence + ROWNUM,
           substr(g_shipmsg||g_delim||PLL.shipment_num||g_delim||l_textline,1,240),
           'PO_MATCHING_BASIS_NULL'
          FROM PO_LINE_LOCATIONS PLL
          WHERE PLL.po_header_id            = p_document_id
          AND nvl(PLL.cancel_flag, 'N')     = 'N'
          AND nvl(PLL.consigned_flag , 'N') <> 'Y'
          AND nvl(PLL.closed_code, 'OPEN') NOT IN ('CLOSED FOR INVOICE', 'CLOSED', 'FINALLY CLOSED')
          AND PLL.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
          AND PLL.matching_basis IS NULL;

          --Increment the p_sequence with number of errors reported in last query
          p_sequence := p_sequence + SQL%ROWCOUNT;
          -- Bug 13527787 end
------------------------------------------------------------------------------------

        l_progress := '033';
        IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                           l_api_name||'.' || l_progress,'PO 29: Validate the line type is valid or not');

            END IF;
        END IF;

        -- Check 29: Validate the line type is valid or not.
        l_textline := FND_MESSAGE.GET_STRING('PO','PO_RI_INVALID_LINE_TYPE_ID');
        INSERT INTO po_online_report_text_gt (online_report_id,
    	 				  last_update_login,
    	 				  last_updated_by,
    	 				  last_update_date,
    	 				  created_by,
    	 				  creation_date,
    	 				  line_num,
    	 				  shipment_num,
    	 				  distribution_num,
    	 				  sequence,
    	 				  text_line,
    	                                  message_name)
        SELECT p_online_report_id,
    	   p_login_id,
    	   p_user_id,
    	   sysdate,
    	   p_user_id,
    	   sysdate,
    	   pl.line_num,
    	   0,
    	   0,
    	   p_sequence + ROWNUM,
    	   substr(g_linemsg||g_delim||pl.line_num||g_delim||l_textline,1,240),
    	   'PO_RI_INVALID_LINE_TYPE_ID'
         FROM  po_headers_gt ph, po_lines_gt pl,po_line_types_b plt
        WHERE ph.po_header_id = p_document_id
        AND   pl.po_header_id = ph.po_header_id
        AND   pl.line_type_id = plt.line_type_id
	AND   nvl(plt.inactive_date, SYSDATE) < SYSDATE;

        --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;
------------------------------------------------------------------------------------


    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;
END CHECK_PO;

--For Planned POs and Blanket PAs
/**
* Private Procedure: CHECK_PLANNED_PO_BLANKET_PA
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure runs the document submission checks for PLANNED POs
*           and BLANKET PAs
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*/
PROCEDURE check_planned_po_blanket_pa(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_textline  po_online_report_text.text_line%TYPE := NULL;
l_api_name  CONSTANT varchar2(40) := 'CHECK_PLANNED_PO_BLANKET_PA';
l_progress VARCHAR2(3);
/* bug 14196636 */
l_currency_code    PO_HEADERS_ALL.CURRENCY_CODE%TYPE;
l_precision        NUMBER  := null;
l_ext_precision    NUMBER  := null;
l_min_acct_unit    NUMBER  := null;
/*end bug 14196636 */

BEGIN
l_progress := '000';

l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,
          'PA/PO BLANKET/PLANNED 1: Amount agreed greater than Amount limit');
   END IF;
END IF;

  -- Check 1: The amount agreed specified on the planned po and blanket
    -- pa should be less than the amount limit.
    -- PO_SUB_AGREED_GRT_LIMIT

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_AGREED_GRT_LIMIT');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_AGREED_GRT_LIMIT'
    FROM  PO_HEADERS_GT POH
    WHERE  POH.po_header_id = p_document_id
    AND    POH.blanket_total_amount is not null
    AND    POH.amount_limit is not null
    AND    POH.blanket_total_amount > POH.amount_limit;


    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
------------------------------------------

l_progress := '002';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,
          'PA/PO BLANKET/PLANNED 2: Min Rel Amount greater than Amount limit');
   END IF;
END IF;

  -- Check 2: The min release amount specified on the planned po and
    -- blanket pa should be less than the amount limit.
    -- PO_SUB_MINREL_GRT_LIMIT

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_MINREL_GRT_LIMIT');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_MINREL_GRT_LIMIT'
    FROM  PO_HEADERS_GT POH
    WHERE  POH.po_header_id = p_document_id
    AND    POH.min_release_amount is not null
    AND    POH.amount_limit is not null
    AND    POH.min_release_amount > POH.amount_limit;


     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
------------------------------------------

l_progress := '003';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,
          'PA/PO BLANKET/PLANNED 3: Amount released greater than Amount limit');
   END IF;
END IF;

/* bug 14196636 - Query to fetch precision for currency */
  select poh.currency_code
    into l_currency_code
    FROM   PO_HEADERS_GT POH
    WHERE  POH.po_header_id = p_document_id;

  fnd_currency.get_info (l_currency_code,
                         l_precision,
                         l_ext_precision,
                         l_min_acct_unit);
/* End bug 14196636 - Query to fetch precision for currency */

  -- Check 3: The Amount Limit should be greater than the total of all
    -- Releases.
    -- PO_SUB_LIMIT_GRT_REL_AMT

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_LIMIT_GRT_REL_AMT');
  INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
  SELECT  p_online_report_id,
        p_login_id,
        p_user_id,
          sysdate,
        p_user_id,
        sysdate,
        0,
        0,
        0,
        p_sequence + ROWNUM,
        substr(l_textline,1,240),
            'PO_SUB_LIMIT_GRT_REL_AMT'
     FROM   PO_HEADERS_GT POH
    WHERE  POH.po_header_id = p_document_id
    AND    POH.amount_limit is not null
    AND ( (NVL(POH.global_agreement_flag, 'N') = 'N'
           AND
           round(POH.amount_limit, l_precision) <
           (   SELECT                                         -- <SERVICES FPJ>
                   sum ( decode ( PLL2.quantity
                                , NULL ,  round(( PLL2.amount
                                         - nvl(PLL2.amount_cancelled,0)
                                         ),l_precision)
                                ,        round(   ( PLL2.quantity
                                             - nvl(PLL2.quantity_cancelled,0) )
                                         * PLL2.price_override,l_precision
                                         )
                                )
                       )
               FROM PO_LINE_LOCATIONS PLL2
               WHERE PLL2.po_header_id = POH.po_header_id
               AND PLL2.shipment_type in ('BLANKET', 'SCHEDULED')
               AND Nvl(PLL2.consigned_flag,'N') <> 'Y'           -- BUG 19067073
           )
          )
         OR
         --bug2969379
         --GA should have amount limit checked in a different way
          ( POH.global_agreement_flag = 'Y'
            AND
            round(POH.amount_limit, l_precision) <
            (   SELECT
                   sum ( decode ( PLL3.quantity
                                , NULL ,  round(( PLL3.amount
                                         - nvl(PLL3.amount_cancelled,0)
                                         ),l_precision)
                                ,        round(   ( PLL3.quantity
                                             - nvl(PLL3.quantity_cancelled,0) )
                                         * PLL3.price_override,l_precision
                                         )
                                )
                       )
               FROM PO_LINE_LOCATIONS_ALL PLL3
               WHERE PLL3.from_header_id = POH.po_header_id
               AND  Nvl(PLL3.consigned_flag,'N') <> 'Y'    -- BUG 19067073
            )
          )
        );

--<FPI commented>
--    GROUP BY POH.amount_limit);

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

------------------------------------------

/* Start Bug 3286940 */


l_progress := '004';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,
          'PA/PO BLANKET/PLANNED 4: Price Limit less than Line Price');
   END IF;
END IF;


  -- Check 4: The price limit when price_override_flag = 'Y' should be
   --          at least as large as the unit price for that line.
    -- PO_SVC_PRICE_LIMIT_LT_PRICE

    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SVC_PRICE_LIMIT_LT_PRICE');


      INSERT into po_online_report_text_gt(online_report_id,
                                           last_update_login,
                                           last_updated_by,
                                           last_update_date,
                                           created_by,
                                           creation_date,
                                           line_num,
                                           shipment_num,
                                           distribution_num,
                                           sequence,
                                           text_line,
                                           message_name)
      SELECT  p_online_report_id,
              p_login_id,
              p_user_id,
              sysdate,
              p_user_id,
              sysdate,
              POL.line_num,
              0,
              0,
              p_sequence + ROWNUM,
              substr(g_linemsg||g_delim||POL.line_num
                         ||g_delim||l_textline,1,240),
              'PO_SVC_PRICE_LIMIT_LT_PRICE'
      FROM PO_LINES_GT POL
      WHERE POL.po_header_id = p_document_id
      AND trunc(sysdate) <= trunc(nvl(POL.expiration_date, sysdate + 1)) -- bug 3449694
      AND nvl(POL.cancel_flag,'N')= 'N'
      AND nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'
      AND nvl(POL.allow_price_override_flag, 'N') = 'Y'
      AND POL.not_to_exceed_price IS NOT NULL
      AND ((POL.unit_price IS NOT NULL and POL.not_to_exceed_price < POL.unit_price)
           or
          (POL.amount IS NOT NULL and POL.not_to_exceed_price < POL.amount));



     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;


/* End Bug 3286940 */

        l_progress := '005';
        IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                           l_api_name||'.' || l_progress,'PA/PO BLANKET/PLANNED 5: Validate the line type is valid or not');

            END IF;
        END IF;

        -- Check 5: Validate the line type is valid or not.
        l_textline := FND_MESSAGE.GET_STRING('PO','PO_RI_INVALID_LINE_TYPE_ID');
        INSERT INTO po_online_report_text_gt (online_report_id,
    	 				  last_update_login,
    	 				  last_updated_by,
    	 				  last_update_date,
    	 				  created_by,
    	 				  creation_date,
    	 				  line_num,
    	 				  shipment_num,
    	 				  distribution_num,
    	 				  sequence,
    	 				  text_line,
    	                                  message_name)
        SELECT p_online_report_id,
    	   p_login_id,
    	   p_user_id,
    	   sysdate,
    	   p_user_id,
    	   sysdate,
    	   pl.line_num,
    	   0,
    	   0,
    	   p_sequence + ROWNUM,
    	   substr(g_linemsg||g_delim||pl.line_num||g_delim||l_textline,1,240),
    	   'PO_RI_INVALID_LINE_TYPE_ID'
         FROM  po_headers_gt ph, po_lines_gt pl,po_line_types_b plt
        WHERE ph.po_header_id = p_document_id
        AND   pl.po_header_id = ph.po_header_id
        AND   pl.line_type_id = plt.line_type_id
	AND   nvl(plt.inactive_date, SYSDATE) < SYSDATE;

        --Increment the p_sequence with number of errors reported in last query
        p_sequence := p_sequence + SQL%ROWCOUNT;
-------------------------------------------------------------------------------------



    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END CHECK_PLANNED_PO_BLANKET_PA;

--For Blanket PA
/**
* Private Procedure: CHECK_BLANKET_AGREEMENT
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure runs the document submission checks for BLANKETS
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*/
PROCEDURE check_blanket_agreement(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_check_asl IN BOOLEAN,                     -- <2757450>
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_textline  po_online_report_text.text_line%TYPE := NULL;
l_api_name  CONSTANT varchar2(40) := 'CHECK_BLANKET_AGREEMENT';
l_progress VARCHAR2(3);

BEGIN
l_progress := '000';

l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PA BLANKET 1: No lines');
   END IF;
END IF;

    -- Check 1: Blanket Header must have at least one line
    -- PO_SUB_HEADER_NO_LINES
    -- Message inserted is 'Purchase Document has no lines'
    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_HEADER_NO_LINES');
    INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
          creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
    SELECT  p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            0, 0, 0,
            p_sequence + ROWNUM,
            substr(l_textline,1,240),
            'PO_SUB_HEADER_NO_LINES'
    FROM   PO_HEADERS_GT POH
    WHERE  POH.po_header_id = p_document_id AND
           NOT EXISTS (SELECT 'Lines Exist'
                       FROM   PO_LINES_GT POL
                       WHERE  POL.po_header_id = POH.po_header_id);
                       --AND    nvl(POL.cancel_flag,'N') = 'N');
                       -- bug 3300632

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

--Bug 16360871 Check the end_date of BPA
l_progress := '100' ;
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PA BLANKET 2: BPA header end date expired.');
   END IF;
END IF;
    l_textline := FND_MESSAGE.GET_STRING('PO','PO_SUB_HEADER_END_DATED');

    INSERT INTO po_online_report_text_gt(
                online_report_id,
                last_update_login,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                line_num,
                shipment_num,
                distribution_num,
                sequence,
                text_line,
                message_name)
    SELECT  p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            0, 0, 0,
            p_sequence + ROWNUM,
            substr(l_textline,1,240),
            'PO_SUB_HEADER_END_DATED'
    FROM   PO_HEADERS_GT POH
    WHERE  POH.po_header_id = p_document_id
      AND  TRUNC(sysdate) > TRUNC(POH.end_date);
  -- Increment the p_sequence with number of errors reported in last query
   p_sequence := p_sequence + SQL%ROWCOUNT;
  --Bug 16360871 end
----------------------------------------------------

--Bug 4943365 We should not make any ASL checks for Blanket agreements.
--Removed the call to check_asl

---------------------------------------------

--<FPJ ENCUMBRANCE>

l_progress := '400';

-- Check 4: The PA GL date should be within an open purchasing period
-- PO_SUB_PA_INVALID_GL_DATE ?

IF (  PO_CORE_S.is_encumbrance_on(
         p_doc_type => g_document_type_PA
      ,  p_org_id => NULL
      )
   )
THEN

   l_progress := '410';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(g_log_head||'.'||l_api_name||'.',
                           l_progress,'PA BLANKET 4: GL date');
   END IF;

   check_gl_date(
      p_doc_type => g_document_type_PA
   ,  p_online_report_id => p_online_report_id
   ,  p_login_id => p_login_id
   ,  p_user_id => p_user_id
   ,  p_sequence => p_sequence
   );

   l_progress := '420';

ELSE
   l_progress := '430';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(g_log_head||'.'||l_api_name||'.',
                           l_progress,'PA BLANKET 4: PA encumbrance not on');
   END IF;
END IF;


  /* Start bug #3512688*/
      /* Check 05 : To check the validity of the item at line level for newly added  line */
      l_progress := '04';
      IF g_debug_stmt  THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
      l_api_name||'.' || l_progress,
      'PO 04: Non Purchasable Item is not allowed');
      END IF;
      END IF;
      l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_ALL_NO_ITEM');
      INSERT INTO po_online_report_text_gt(online_report_id,
      last_update_login,
      last_updated_by,
      last_update_date,
      created_by,
      creation_date,
      line_num,
      shipment_num,
      distribution_num,
      sequence,
      text_line,
      message_name)
      SELECT  p_online_report_id,
      p_login_id,
      p_user_id,
      sysdate,
      p_user_id,
      sysdate,
      pl.line_num,
      0,
      0,
      p_sequence + ROWNUM,
       substr(g_linemsg||g_delim||pl.line_num||g_delim||l_textline,1,240),
      'PO_ALL_NO_ITEM'
      from po_headers_gt ph,po_lines_gt pl,mtl_system_items  itm,financials_system_parameters fsp,po_line_types_b plt
      where itm.inventory_item_id  = pl.item_id
      and   pl.item_id is not null
      and   itm.organization_id    = fsp.inventory_organization_id
      and   itm.purchasing_enabled_flag = 'N'
      and   ph.po_header_id = p_document_id
      and   pl.po_header_id = ph.po_header_id
      and   pl.line_type_id = plt.line_type_id

     and   nvl(plt.outside_operation_flag,'N') =  nvl(itm.outside_operation_flag,'N')
      and   (pl.creation_date >= nvl(ph.approved_date ,pl.creation_date)) ;

      --Increment the p_sequence with number of errors reported in last query
      p_sequence := p_sequence + SQL%ROWCOUNT;
      --End Bug #3512688



--<Begin Bug#: 5132541> EFFECTIVE DATE ON THE HEADER IS NOT VALIDATED AGAINST THAT OF PRICE BREAK
    /*Check 06: Check if the effective range on the price break is within the effective range
                of the header and before the expiration date of the line.*/

    l_progress := '06';
    IF g_debug_stmt  THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                        l_api_name||'.' || l_progress,
                        'BPA 06: Checking price breaks effective date range');
      END IF;
    END IF;

    INSERT INTO po_online_report_text_gt(online_report_id,
    last_update_login,
    last_updated_by,
    last_update_date,
    created_by,
    creation_date,
    line_num,
    shipment_num,
    distribution_num,
    sequence,
    text_line,
    message_name)
    SELECT  p_online_report_id,
    p_login_id,
    p_user_id,
    sysdate,
    p_user_id,
    sysdate,
    pl.line_num,
    pll.shipment_num,
    0,
    p_sequence + ROWNUM,
    CASE
        WHEN pll.start_date < ph.start_date
        THEN substr(g_linemsg||g_delim||pl.line_num||g_delim
                   ||g_price_breakmsg||g_delim||pll.shipment_num||g_delim
                   ||FND_MESSAGE.GET_STRING('PO', PO_MESSAGE_S.POX_EFFECTIVE_DATES1),1,240)
        WHEN pll.end_date > ph.end_date
        THEN substr(g_linemsg||g_delim||pl.line_num||g_delim
                   ||g_price_breakmsg||g_delim||pll.shipment_num||g_delim
                   ||FND_MESSAGE.GET_STRING('PO', PO_MESSAGE_S.POX_EFFECTIVE_DATES),1,240)
        WHEN pll.start_date > ph.end_date
        THEN substr(g_linemsg||g_delim||pl.line_num||g_delim
                   ||g_price_breakmsg||g_delim||pll.shipment_num||g_delim
                   ||FND_MESSAGE.GET_STRING('PO', PO_MESSAGE_S.POX_EFFECTIVE_DATES4),1,240)
        WHEN pll.end_date < ph.start_date
        THEN substr(g_linemsg||g_delim||pl.line_num||g_delim
                   ||g_price_breakmsg||g_delim||pll.shipment_num||g_delim
                   ||FND_MESSAGE.GET_STRING('PO', PO_MESSAGE_S.POX_EFFECTIVE_DATES5),1,240)
        WHEN pll.start_date > pl.expiration_date
        THEN substr(g_linemsg||g_delim||pl.line_num||g_delim
                   ||g_price_breakmsg||g_delim||pll.shipment_num||g_delim
                   ||FND_MESSAGE.GET_STRING('PO', PO_MESSAGE_S.POX_EFFECTIVE_DATES6),1,240)
        WHEN pll.end_date > pl.expiration_date
        THEN substr(g_linemsg||g_delim||pl.line_num||g_delim
                   ||g_price_breakmsg||g_delim||pll.shipment_num||g_delim
                   ||FND_MESSAGE.GET_STRING('PO', PO_MESSAGE_S.POX_EFFECTIVE_DATES2),1,240)
     END
    ,
    CASE
        WHEN pll.start_date < ph.start_date
        THEN PO_MESSAGE_S.POX_EFFECTIVE_DATES1
        WHEN pll.end_date > ph.end_date
        THEN PO_MESSAGE_S.POX_EFFECTIVE_DATES
        WHEN pll.start_date > ph.end_date
        THEN PO_MESSAGE_S.POX_EFFECTIVE_DATES4
        WHEN pll.end_date < ph.start_date
        THEN PO_MESSAGE_S.POX_EFFECTIVE_DATES5
        WHEN pll.start_date > pl.expiration_date
        THEN PO_MESSAGE_S.POX_EFFECTIVE_DATES6
        WHEN pll.end_date > pl.expiration_date
        THEN PO_MESSAGE_S.POX_EFFECTIVE_DATES2
    END
    FROM po_headers_gt ph, po_lines_gt pl, po_line_locations_gt pll
    WHERE ph.po_header_id = p_document_id
    AND pl.po_header_id = ph.po_header_id
    AND pll.po_line_id = pl.po_line_id
    AND pll.shipment_type = 'PRICE BREAK'
    AND (pll.start_date < ph.start_date
      or pll.end_date > ph.end_date
      or pll.start_date > ph.end_date
      or pll.end_date < ph.start_date
      or pll.start_date > pl.expiration_date
      or pll.end_date > pl.expiration_date);

    p_sequence := p_sequence + SQL%ROWCOUNT;

    /*Check 07: Check if the expiration date on the line is within the effective range
                of the header.*/

    l_progress := '07';
    IF g_debug_stmt  THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                        l_api_name||'.' || l_progress,
                        'BPA 07: Checking the lines expiration date');
      END IF;
    END IF;

    -- Bug 9816849 : Added condition to avoid checking expiration date for lines having cancel_flag=Y
    l_textline := FND_MESSAGE.GET_STRING('PO', PO_MESSAGE_S.POX_EXPIRATION_DATES);
    INSERT INTO po_online_report_text_gt(online_report_id,
    last_update_login,
    last_updated_by,
    last_update_date,
    created_by,
    creation_date,
    line_num,
    shipment_num,
    distribution_num,
    sequence,
    text_line,
    message_name)
    SELECT  p_online_report_id,
    p_login_id,
    p_user_id,
    sysdate,
    p_user_id,
    sysdate,
    pl.line_num,
    0,
    0,
    p_sequence + ROWNUM,
    substr(g_linemsg||g_delim||pl.line_num||g_delim||l_textline,1,240),
    PO_MESSAGE_S.POX_EXPIRATION_DATES
    FROM po_headers_gt ph, po_lines_gt pl
    WHERE ph.po_header_id = p_document_id
    AND pl.po_header_id = ph.po_header_id
    AND (pl.expiration_date < ph.start_date
      or pl.expiration_date > ph.end_date)
    AND nvl(pl.cancel_flag,'N') = 'N' ; -- bug 9816849

    p_sequence := p_sequence + SQL%ROWCOUNT;
    --<End Bug#: 5132541>


l_progress := '008';
--Bug 14761965 start. Added submission check for Debarred.
	IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
             || l_progress,'BPA 08: ASL Debarred');
      END IF;
    END IF;

       -- Check 8: If an item is restricted then the Purchase Order Vendor
       -- must be listed in the Approved Suppliers List table and must not be
       -- DEBARRED.
       -- PO_SUB_ITEM_ASL_DEBARRED

    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_ITEM_ASL_DEBARRED');
     INSERT INTO po_online_report_text_gt(online_report_id,
           last_update_login,
           last_updated_by,
           last_update_date,
           created_by,
           creation_date,
           line_num,
           shipment_num,
           distribution_num,
           sequence,
           text_line,
                   message_name)
     SELECT  p_online_report_id,
           p_login_id,
           p_user_id,
             sysdate,
           p_user_id,
           sysdate,
           POL.line_num,
           PLL.shipment_num,
           0,
           p_sequence + ROWNUM,
           substr(g_linemsg||g_delim||POL.line_num||g_delim
                      ||g_shipmsg||g_delim||PLL.shipment_num||g_delim
                      ||l_textline,1,240),
               'PO_SUB_ITEM_ASL_DEBARRED'
        FROM PO_LINE_LOCATIONS_GT PLL,
            PO_LINES_GT POL, PO_HEADERS_GT POH,
            FINANCIALS_SYSTEM_PARAMETERS FSP
       WHERE POH.po_header_id = p_document_id
       AND POH.po_header_id = POL.po_header_id
       AND PLL.po_line_id(+) = POL.po_line_id
       AND PLL.po_release_id IS NULL
       AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
       AND nvl(POL.cancel_flag,'N') = 'N'
       AND nvl(PLL.cancel_flag,'N') = 'N'
       AND exists
          (SELECT 1
           FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR,
   	MTL_SYSTEM_ITEMS MSI  --Bug5597639
           WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id, -1)
   	/*Bug5597639 Adding the below three conditions */
   	AND MSI.organization_id = FSP.inventory_organization_id
   	AND MSI.inventory_item_id = POL.item_id
   	AND POL.item_id is not null
           AND    ASL.vendor_id = POH.vendor_id
           AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
           AND  ASL.item_id = POL.item_id
           AND    ASL.asl_status_id = ASR.status_id
           AND    ASR.business_rule = '1_PO_APPROVAL'
           AND    ASR.allow_action_flag <> 'Y' -- Bug 5724696
           UNION ALL
           SELECT 1
           FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR
           WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id, -1)
           AND    ASL.vendor_id = POH.vendor_id
           AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
           AND    ASL.item_id is NULL
   	       AND  POL.category_id = ASL.category_id  --Bug5597639
           AND    ASL.asl_status_id = ASR.status_id
           AND    ASR.business_rule = '1_PO_APPROVAL'
           AND    ASR.allow_action_flag <> 'Y' );  --Bug5597639

        --Increment the p_sequence with number of errors reported in last query
       p_sequence := p_sequence + SQL%ROWCOUNT;
	--Bug 14761965 end

    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END CHECK_BLANKET_AGREEMENT;

--For Standard POs
/**
* Private Procedure: CHECK_STANDARD_PO
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure runs the document submission checks for Standard
*           POs including GLOBAL AGREEMENTS reference checks and Consigned
*           Inventory checks
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*/
PROCEDURE check_standard_po(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_is_ga_referenced VARCHAR2(1) := NULL;
l_api_name  CONSTANT varchar2(40) := 'CHECK_STANDARD_PO';
l_progress VARCHAR2(3);

l_is_gc_referenced VARCHAR2(1) := NULL;         -- <GC FPJ>
l_textline PO_ONLINE_REPORT_TEXT.text_line%TYPE := NULL;  --< Shared Proc FPJ >
l_return_status VARCHAR2(1);

-- Bug 2818810. Added extra join to alias POHA to return 'Y' only if at least
-- one line references a GA.
CURSOR std_ga_ref_cursor(p_document_id NUMBER) IS
    SELECT 'Y'
    FROM PO_HEADERS_GT POH, PO_LINES_GT POL, PO_HEADERS_ALL POHA
    WHERE POH.po_header_id = p_document_id
     AND  POH.po_header_id = POL.po_header_id
     AND  POL.from_header_id = POHA.po_header_id
     AND  POHA.type_lookup_code = 'BLANKET'
     AND  POHA.global_agreement_flag = 'Y';

-- <GC FPJ START>
CURSOR std_gc_ref_cursor (p_doc_id NUMBER) IS
  SELECT 'Y'
  FROM   po_lines_gt POL,
         po_headers_all POHA
  WHERE  POL.po_header_id = p_doc_id
  AND    POL.contract_id = POHA.po_header_id
  AND    POHA.global_agreement_flag = 'Y';
-- <GC FPJ END>

BEGIN

l_progress := '000';

    --check if atleast one line of Standard PO has Global Agreement reference
    --if so then call check_std_global_ref
    OPEN std_ga_ref_cursor(p_document_id);

    FETCH std_ga_ref_cursor INTO l_is_ga_referenced;

    CLOSE std_ga_ref_cursor;

    IF l_is_ga_referenced = 'Y' THEN
l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD: GA is referenced. Call GA checks');
   END IF;
END IF;

       check_std_global_ref(p_document_id ,
                       p_online_report_id ,
                       p_user_id ,
                       p_login_id ,
                       p_sequence,
                       l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;

    -- <GC FPJ START>
    -- If there exists a line referencing global contract, make sure that
    -- the reference is valid by calling check_std_gc_ref

    OPEN std_gc_ref_cursor (p_document_id);
    FETCH std_gc_ref_cursor INTO l_is_gc_referenced;
    CLOSE std_gc_ref_cursor;

    IF (l_is_gc_referenced = 'Y') THEN

        check_std_gc_ref
        (  p_document_id      => p_document_id,
           p_online_report_id => p_online_report_id,
           p_user_id          => p_user_id,
           p_login_id         => p_login_id,
           x_sequence         => p_sequence,
           x_return_status    => l_return_status
        );

        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    -- <GC FPJ END>

l_progress := '002';

    --Call Consinged checks
    check_std_consigned_ref(p_document_id ,
                       p_online_report_id ,
                       p_user_id ,
                       p_login_id ,
                       p_sequence,
                       l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

l_progress := '003';

    -- Bug 3379488: Removed the Dest OU check for shipments with expense
    -- destinations with project-specified, because this scenario is prevented
    -- at an early stage and would not happen here

    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;
END CHECK_STANDARD_PO;


/**
* Private Procedure: CHECK_STD_CONSIGNED_REF
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure performs checks for the Consigned from Supplier
*           project in order to enforce the following:
*           1) Consigned status on any new or modified shipment that is not
*              partially received or partially invoiced should match the
*              consigned setting on the corresponding ASL entry.
*           2) Document references cannot exist for PO lines with one or
*              more consigned shipments
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*  x_return_status: This parameter signifies whether the checks contained in
*                   this procedure completed successfully.
*/
PROCEDURE check_std_consigned_ref(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT varchar2(40) := 'CHECK_STD_CONSIGNED_REF';
l_progress VARCHAR2(3);

l_textline  po_online_report_text.text_line%TYPE    := NULL;
l_consigned_from_supplier_flag
po_asl_attributes.consigned_from_supplier_flag%TYPE := NULL;
l_enable_vmi_flag
po_asl_attributes.enable_vmi_flag%TYPE              := NULL;
l_last_billing_date            DATE                 := NULL;
l_consigned_billing_cycle      NUMBER               := NULL;
l_consigned_mismatch_found     BOOLEAN              := FALSE;
l_count_expense_dist           NUMBER               := NULL;

TYPE NumTab is TABLE of NUMBER INDEX by BINARY_INTEGER;
TYPE AslConsignedFlagTab is TABLE of
po_asl_attributes.consigned_from_supplier_flag%TYPE
INDEX by BINARY_INTEGER;
TYPE ConsignedFlagTab is TABLE of
po_line_locations.consigned_flag%TYPE
INDEX by BINARY_INTEGER;

l_vendor_id          NumTab;
l_vendor_site_id     NumTab;
l_item_id            NumTab;
l_ship_to_org_id     NumTab;
l_line_num           NumTab;
l_shipment_num       NumTab;
l_line_location_id   NumTab;
l_consigned_flag     ConsignedFlagTab;
l_asl_consigned_flag AslConsignedFlagTab;
l_return_status      varchar2(1)            := NULL;
l_msg_count          number                 := NULL;
l_msg_data           varchar2(2000)         := NULL;

BEGIN

l_progress := '000';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,
          'PO STD CONSIGNED 1: Doc Ref and Consigned ship cannot coexist');
   END IF;
END IF;

  /*Bug11802312 No need to check if reference exists as we are going to retain
   reference on consigned POs always*/

  -- Check 1: PO_SUP_CONS_DOC_REF_COEXIST
  -- Organization cannot be used to create a consigned shipment because
  -- order line contains a document reference. Enter a new order line
  -- for this shipment.

--  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUP_CONS_DOC_REF_COEXIST');
--
--  INSERT INTO
--    po_online_report_text_gt(online_report_id,
--                       last_update_login,
--           last_updated_by,
--                 last_update_date,
--           created_by,
--           creation_date,
--           line_num,
--           shipment_num,
--           distribution_num,
--           sequence,
--           text_line,
--                             message_name)
--     -- SQL What: Selects any PO Line with at least one consigned shipment
--     --           and a document reference or contract
--     -- SQL Why: Document references and consigned shipments cannot exist
--     --          for the same PO Line
--     -- SQL Join: po_line_id
--    SELECT p_online_report_id,
--     p_login_id,
--     p_user_id,
--         sysdate,
--     p_user_id,
--     sysdate,
--           pol.line_num,
--     pll.shipment_num,
--     0,
--           p_sequence + ROWNUM,
--     substr(g_linemsg||g_delim||POL.line_num||g_delim||g_shipmsg
--     ||g_delim||PLL.shipment_num||':'||g_delim||l_textline,1,240),
--     'PO_DOC_REF_SUP_CONS_COEXIST'
--    FROM   po_lines_gt pol,
--     po_line_locations_gt pll
--    WHERE  pol.po_header_id = p_document_id
--    AND    pol.po_line_id = pll.po_line_id
--    AND    pll.shipment_type = 'STANDARD'
--    AND    pll.consigned_flag = 'Y'
--    AND    nvl(pol.cancel_flag,'N') = 'N'
--    AND    nvl(pol.closed_code,'OPEN') <> 'FINALLY CLOSED'
--    AND   (pol.oke_contract_header_id is not null or
--           pol.oke_contract_version_id is not null or
--     pol.from_header_id is not null or
--     pol.from_line_id is not null or
--     pol.contract_num is not null);
--
--  --Increment the p_sequence with number of errors reported in last query
--  p_sequence := p_sequence + SQL%ROWCOUNT;
--------------------------------------

l_progress := '002';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,
          'PO STD CONSIGNED 2: Consigned status on shipments and ASL must match');
   END IF;
END IF;

  -- Check 2: PO_SUP_CONS_STATUS_MISMATCH
  -- Consigned attribute and the ASL consigned attribute do not match.
  -- Shipment line must be cancelled and re-entered.'

  -- SQL What: Collect the vendor_id, vendor_site_id, item_id, ship_to_organization_id and
  --           consigned_flag into pl/sql tables, get the consigned_from_supplier_flag on
  --           the corresponding ASL entry for each shipment and match it to the consigned
  --           flag of the shipment.  The consigned_flag of the shipments are stored in a
  --           PL/SQL table.  If the item/supplier/supplier site/organization combination
  --           of the current shipment matches with that of the previous shipment, get the
  --           consigned_flag from the previous shipment instead of calling
  --           get_asl_attributes.  This can be done since the info of each shipment of
  --           the current PO to be approved is ordered by the vendor_id, vendor_site_id,
  --           item_id and ship_to_organization_id, in the bulk collct select statement.
  -- SQL Why: Consigned status on shipments and that on ASL must match
  -- SQL Join: po_header_id, po_line_id

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUP_CONS_STATUS_MISMATCH');

  SELECT  POH.vendor_id,
          POH.vendor_site_id,
          POL.item_id,
    PLL.ship_to_organization_id,
    PLL.consigned_flag,
    POL.line_num,
    PLL.shipment_num,
          PLL.line_location_id
  BULK COLLECT INTO
          l_vendor_id,
          l_vendor_site_id,
          l_item_id,
          l_ship_to_org_id,
          l_consigned_flag,
    l_line_num,
    l_shipment_num,
          l_line_location_id
  FROM    PO_HEADERS_GT POH,
          PO_LINE_LOCATIONS_GT PLL,
          PO_LINES_GT POL
  WHERE   POH.po_header_id = p_document_id AND
          POH.po_header_id = POL.po_header_id AND
--          POH.po_header_id = PLL.po_header_id AND
          POL.po_line_id = PLL.po_line_id AND
          PLL.shipment_type = 'STANDARD' AND
          nvl(PLL.cancel_flag,'N') = 'N' AND
          nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED' AND
          -- Bug fix for #2733398
          -- nvl(PLL.approved_flag, 'N') IN ('N','R') AND
          nvl(PLL.approved_flag, 'N') = 'N' AND
          PLL.quantity_received <= 0 AND
          PLL.quantity_billed <= 0
  ORDER BY
          POH.vendor_id,
          POH.vendor_site_id,
          POL.item_id,
    PLL.ship_to_organization_id;

l_progress := '003';
  FOR i IN 1..l_line_num.COUNT
  LOOP

    IF(i > 1 AND
       l_vendor_id(i) = l_vendor_id(i - 1) AND
       l_vendor_site_id(i) = l_vendor_site_id(i - 1) AND
       l_item_id(i) = l_item_id(i - 1) AND
       l_ship_to_org_id(i) = l_ship_to_org_id(i - 1))
    THEN
      l_asl_consigned_flag(i) := l_asl_consigned_flag(i - 1);
    ELSE
      -- getting the consigned setting of the ASL entry for the
      -- item/supplier/supplier site/organization combination,
      -- if there exists one
      po_third_party_stock_grp.get_asl_attributes
      (p_api_version                  => 1.0                           ,
       p_init_msg_list                => NULL                          ,
       x_return_status                => l_return_status               ,
       x_msg_count                    => l_msg_count                   ,
       x_msg_data                     => l_msg_data                    ,
       p_inventory_item_id            => l_item_id(i)                  ,
       p_vendor_id                    => l_vendor_id(i)                ,
       p_vendor_site_id               => l_vendor_site_id(i)           ,
       p_using_organization_id        => l_ship_to_org_id(i)           ,
       x_consigned_from_supplier_flag => l_consigned_from_supplier_flag,
       x_enable_vmi_flag              => l_enable_vmi_flag             ,
       x_last_billing_date            => l_last_billing_date           ,
       x_consigned_billing_cycle      => l_consigned_billing_cycle     );

      l_asl_consigned_flag(i) := l_consigned_from_supplier_flag;
    END IF;

l_progress := '004';
    IF(NVL(l_consigned_flag(i), 'N') <> NVL(l_asl_consigned_flag(i), 'N'))
    THEN
      -- Bug fix for #2701648
      -- Do not report consigned status mismatch for the case when the ASL
      -- is consigned while the shipment is not consigned, if there exists
      -- distributions with destination type being EXPENSE
      IF(NVL(l_consigned_flag(i), 'N') = 'N' AND
         NVL(l_asl_consigned_flag(i), 'N') = 'Y')
      THEN
        SELECT count('Y')
        INTO   l_count_expense_dist
        FROM   DUAL
        WHERE  EXISTS(SELECT 'Y'
                      FROM   PO_DISTRIBUTIONS_GT
                      WHERE  LINE_LOCATION_ID = l_line_location_id(i)
                      AND    DESTINATION_TYPE_CODE = 'EXPENSE');

        IF(l_count_expense_dist <= 0)
        THEN
          l_consigned_mismatch_found := TRUE;
        ELSE
          l_consigned_mismatch_found := FALSE;
        END IF;
      ELSE
        l_consigned_mismatch_found := TRUE;
      END IF;
    -- if the consigned status matches
    ELSE
      l_consigned_mismatch_found := FALSE;
    END IF;

    -- insert an error into the report table if the consigned status on the
    -- ASL and the shipment does not match
    IF(l_consigned_mismatch_found)
    THEN
      INSERT INTO
        po_online_report_text_gt
        (online_report_id,
         last_update_login,
   last_updated_by,
   last_update_date,
   created_by,
   creation_date,
   line_num,
   shipment_num,
   distribution_num,
   sequence,
   text_line,
         message_name)
      VALUES
  (p_online_report_id,
   p_login_id,
   p_user_id,
   sysdate,
   p_user_id,
   sysdate,
         l_line_num(i),
   l_shipment_num(i),
   0,
   p_sequence + i,
         substr(g_linemsg||g_delim||l_line_num(i)||g_delim||g_shipmsg
                ||g_delim||l_shipment_num(i)||':'||g_delim||l_textline,1,240),
   'PO_SUP_CONS_STATUS_MISMATCH');

    END IF;

  END LOOP;

  --Increment the p_sequence with number of errors reported in last query
  p_sequence := p_sequence + l_line_num.COUNT;

l_progress := '005';
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END CHECK_STD_CONSIGNED_REF;


--For Standard POs
/**
* Private Procedure: CHECK_STD_GLOBAL_REF
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure runs the document submission checks for Standard
*           POs which have GLOBAL AGREEMENTS reference
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*/
PROCEDURE check_std_global_ref(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_textline  po_online_report_text.text_line%TYPE := NULL;
l_api_name  CONSTANT varchar2(40) := 'CHECK_STD_GLOBAL_REF';
l_progress VARCHAR2(3);
l_currency_mismatch BOOLEAN := FALSE; -- Bug 2716769

--<Bug 2800804, 2792477 mbhargav START>
TYPE NumTab is TABLE of NUMBER INDEX by BINARY_INTEGER;

  l_curr_doc_line_num NumTab;
  l_prev_doc_line_num NumTab;
  l_rowcount Number :=0;

  l_po_amount NumTab;
  l_prev_rel_amount NumTab;
  l_amount_limit NumTab;
--<Bug 2800804, 2792477 mbhargav END>

BEGIN
l_progress := '000';

l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 1: GA enabled in current OU');
   END IF;
END IF;

    --<Shared Proc FPJ>
    --Check 1: The GA should be enabled for purchasing in the current OU.
    --< Shared Proc FPJ > Bug 3301427: Only do this check for new SPO lines
    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_STD_GA_DISABLED');
    INSERT into po_online_report_text_gt(online_report_id,
                                         last_update_login,
                                         last_updated_by,
                                         last_update_date,
                                         created_by,
                                         creation_date,
                                         line_num,
                                         shipment_num,
                                         distribution_num,
                                         sequence,
                                         text_line,
                                         message_name)
    --<Shared Proc FPJ>
    --SQL Querying for PO lines that reference GAs that are not enabled
    --SQL for purchasing in this org, to report an error message.
    SELECT  p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            POL.line_num,
            0,
            0,
            p_sequence + ROWNUM,
            substr(g_linemsg||g_delim||POL.line_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_STD_GA_DISABLED'
    FROM PO_HEADERS_GT POH1, PO_LINES_GT POL, PO_HEADERS_ALL POH
    WHERE POH1.po_header_id = p_document_id
    AND POL.po_header_id = POH1.po_header_id
    AND POL.from_header_id = POH.po_header_id  --JOIN
    AND POH.type_lookup_code = 'BLANKET'
    AND POH.global_agreement_flag = 'Y'
    AND nvl(POL.cancel_flag,'N') = 'N' 				-- bug 19810980
    AND nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    --<Shared Proc FPJ START>
    AND NOT EXISTS                                  --< Bug 3301427 Start >
        (SELECT 'previously approved shipment'
           FROM po_line_locations_gt pllg
          WHERE pllg.po_line_id = pol.po_line_id
            AND pllg.approved_date IS NOT NULL)     --< Bug 3301427 End >
    AND NOT EXISTS
        --SQL Query enabled org assignments of this current purchasing org
       (SELECT 'Enabled purchasing org'
          FROM PO_GA_ORG_ASSIGNMENTS PGOA
         WHERE PGOA.po_header_id = POH.po_header_id
           AND PGOA.purchasing_org_id = POH1.org_id
           AND PGOA.enabled_flag = 'Y');

    --<Shared Proc FPJ END>

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

-----------------------------
l_progress := '002';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 2: Ref GA approved');
   END IF;
END IF;

    --Check 2: If the standard PO line is referencing a GA then that GA
    --should be in an approved status.
    --< Shared Proc FPJ > Bug 3301427: Only do this check for new SPO lines
    --< Bug 3422733 > Only do this check if GA is not ON HOLD. The ON HOLD check
    -- is done later. Avoids showing 2 msgs for Contract that is ON HOLD.

    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_STD_GA_APPROVED');
    INSERT into po_online_report_text_gt(online_report_id,
                                         last_update_login,
                                         last_updated_by,
                                         last_update_date,
                                         created_by,
                                         creation_date,
                                         line_num,
                                         shipment_num,
                                         distribution_num,
                                         sequence,
                                         text_line,
                                         message_name)
    --SQL What: Querying for PO lines that reference GAs that are not approved.
    --SQL Why: Add appropriate error message to po_online_report_text_gt
    SELECT  p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            POL.line_num,
            0,
            0,
            p_sequence + ROWNUM,
            substr(g_linemsg||g_delim||POL.line_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_STD_GA_APPROVED'
    FROM PO_HEADERS_GT POH1, PO_LINES_GT POL, PO_HEADERS_ALL POH2
    WHERE POH1.po_header_id = p_document_id
    AND POL.po_header_id = POH1.po_header_id   --JOIN
    AND POH2.po_header_id = POL.from_header_id --JOIN
    AND POH2.type_lookup_code = 'BLANKET'
    AND POH2.global_agreement_flag = 'Y'
    AND NVL(POH2.approved_flag, 'N') <> 'Y'
    AND NVL(POH2.user_hold_flag, 'N') <> 'Y'        --< Bug 3422733 >
    AND nvl(POL.cancel_flag,'N') = 'N' 		    -- bug 19810980
    AND nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND (NOT EXISTS                                  --< Bug 3301427 Start >
        (SELECT 'previously approved shipment'
           FROM po_line_locations_gt pllg
          WHERE pllg.po_line_id = pol.po_line_id
            AND pllg.approved_date IS NOT NULL)    --< Bug 3301427 End >
        OR
         EXISTS (SELECT 'shipment is in requires reapproval'  --<Bug17367629>
           FROM po_line_locations_gt pllg
          WHERE pllg.po_line_id = pol.po_line_id
            AND pllg.approved_flag = 'R'));

    --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

--------------------------------------

l_progress := '003';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 3: Ref GA ON HOLD');
   END IF;
END IF;

    --Check 3: The GA should not be on hold.
    --< Shared Proc FPJ > Bug 3301427: Only do this check for new SPO lines
    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_STD_GA_ON_HOLD');
    INSERT into po_online_report_text_gt(online_report_id,
                                         last_update_login,
                                         last_updated_by,
                                         last_update_date,
                                         created_by,
                                         creation_date,
                                         line_num,
                                         shipment_num,
                                         distribution_num,
                                         sequence,
                                         text_line,
                                         message_name)
    --SQL What: Querying for PO lines that reference GAs that are on hold
    --SQL Why: Add appropriate error message to po_online_report_text_gt
    SELECT  p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            POL.line_num,
            0,
            0,
            p_sequence + ROWNUM,
            substr(g_linemsg||g_delim||POL.line_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_STD_GA_ON_HOLD'
    FROM PO_HEADERS_GT POH1, PO_LINES_GT POL, PO_HEADERS_ALL POH2
    WHERE POH1.po_header_id = p_document_id
    AND POL.po_header_id = POH1.po_header_id   --JOIN
    AND POH2.po_header_id = POL.from_header_id --JOIN
    AND POH2.type_lookup_code = 'BLANKET'
    AND POH2.global_agreement_flag = 'Y'
    AND POH2.user_hold_flag = 'Y'
    AND nvl(POL.cancel_flag,'N') = 'N' 		    -- bug 19810980
    AND nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND NOT EXISTS                                  --< Bug 3301427 Start >
        (SELECT 'previously approved shipment'
           FROM po_line_locations_gt pllg
          WHERE pllg.po_line_id = pol.po_line_id
            AND pllg.approved_date IS NOT NULL);    --< Bug 3301427 End >

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

------------------------------------------

   -- Bug 2716769 tpoon 12/26/2002
   -- In version 115.8, moved Checks 4 and 5 to after the currency check.
   -- Re-numbered checks 4-10 accordingly.

l_progress := '004';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 4: Vendor match check');
   END IF;
END IF;

    --Check 4: The vendor on the PO should match the GA.
    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_STD_GA_VENDOR_MISMATCH');
    INSERT into po_online_report_text_gt(online_report_id,
                                         last_update_login,
                                         last_updated_by,
                                         last_update_date,
                                         created_by,
                                         creation_date,
                                         line_num,
                                         shipment_num,
                                         distribution_num,
                                         sequence,
                                         text_line,
                                         message_name)
    --SQL What: Querying for PO lines whose vendor does not
    --SQL       match the vendor of the referenced GA
    --SQL Why: Add appropriate error message to po_online_report_text_gt
    SELECT  p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            POL.line_num,
            0,
            0,
            p_sequence + ROWNUM,
            substr(g_linemsg||p_document_id||g_delim||POL.line_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_STD_GA_VENDOR_MISMATCH'
    FROM PO_LINES_GT POL, PO_HEADERS_GT POH1, PO_HEADERS_ALL POH2
    WHERE POL.po_header_id = p_document_id
    AND POL.po_header_id = POH1.po_header_id      --JOIN
    AND POL.from_header_id = POH2.po_header_id    --JOIN
    AND POH2.type_lookup_code = 'BLANKET'
    AND POH2.global_agreement_flag = 'Y'
    AND POH1.vendor_id <> POH2.vendor_id
	AND POL.cancel_flag <> 'Y';--Bug 19572401

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

-------------------------------------

l_progress := '005';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 5: Vendor Site match check');
   END IF;
END IF;

    --Check 5: The vendor site on the PO should match a vendor site on one of
    -- the GA's enabled org assignments.
    --< Shared Proc FPJ > Bug 3301427: Only do this check for new SPO lines
    l_textline :=
        FND_MESSAGE.GET_STRING('PO', 'PO_SUB_STD_GA_VDR_SITE_MISMT');
    INSERT into po_online_report_text_gt(online_report_id,
                                         last_update_login,
                                         last_updated_by,
                                         last_update_date,
                                         created_by,
                                         creation_date,
                                         line_num,
                                         shipment_num,
                                         distribution_num,
                                         sequence,
                                         text_line,
                                         message_name)
    --SQL What: Querying for PO lines whose vendor_site_id does not
    --SQL       match a valid vendor_site_id in the GA's org assignments
    --SQL Why: Add appropriate error message to po_online_report_text_gt
    SELECT  p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            POL.line_num,
            0,
            0,
            p_sequence + ROWNUM,
            substr(g_linemsg||g_delim||POL.line_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_STD_GA_VDR_SITE_MISMT'

    FROM PO_LINES_GT POL, PO_HEADERS_GT POH1, PO_HEADERS_ALL POH2
    WHERE POL.po_header_id = p_document_id
    AND POL.po_header_id = POH1.po_header_id            --JOIN
    AND POL.from_header_id = POH2.po_header_id          --JOIN
    AND POH2.type_lookup_code = 'BLANKET'
    AND POH2.global_agreement_flag = 'Y'
    AND nvl(POL.cancel_flag,'N') = 'N' 			-- bug 19810980
    AND nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    --<Shared Proc FPJ START>
    AND NOT EXISTS                                  --< Bug 3301427 Start >
        (SELECT 'previously approved shipment'
           FROM po_line_locations_gt pllg
          WHERE pllg.po_line_id = pol.po_line_id
            AND pllg.approved_date IS NOT NULL)     --< Bug 3301427 End >
    AND NOT EXISTS
        (SELECT 'Enabled vendor site'
           FROM PO_GA_ORG_ASSIGNMENTS pgoa
          WHERE PGOA.po_header_id = POH2.po_header_id
            AND PGOA.vendor_site_id = POH1.vendor_site_id
            AND PGOA.enabled_flag = 'Y');

    --<Shared Proc FPJ END>

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

---------------------------------------

l_progress := '006';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 6: Creation date check on header');
   END IF;
END IF;

    --Check 6: The PO creation date should be before Blanket(GA) or
    -- corresponding Line expiration date
    --Bug8847964 the need by date should be just greater than the start date of the blanket
    -- and can be later to the end date.
    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_STD_AFTER_GA_DATE');
    INSERT into po_online_report_text_gt(online_report_id,
                                         last_update_login,
                                         last_updated_by,
                                         last_update_date,
                                         created_by,
                                         creation_date,
                                         line_num,
                                         shipment_num,
                                         distribution_num,
                                         sequence,
                                         text_line,
                                         message_name)
    --SQL What: Querying for PO lines that were not created within
    --SQL       the effective dates of the referenced GA
    --SQL Why: Add appropriate error message to po_online_report_text_gt
    SELECT  p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            POL.line_num,
            PLL.shipment_num, -- Bug #5415428 As Need by date also forms part of the checks
            0,
            p_sequence + ROWNUM,
            substr(g_linemsg||g_delim||POL.line_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_STD_AFTER_GA_DATE'
    FROM PO_LINES_GT POL, PO_HEADERS_GT POH, PO_HEADERS_ALL POH2, PO_LINES_ALL POL2, PO_LINE_LOCATIONS_GT PLL
    WHERE POL.po_header_id = p_document_id
    AND POL.po_header_id = POH.po_header_id -- JOIN
    AND PLL.po_line_id = POL.po_line_id  --JOIN, Bug #5415428 - Get the Need by date
    AND POL.from_header_id = POH2.po_header_id --JOIN
    AND POL.from_line_id = POL2.po_line_id     --JOIN
    AND POH2.type_lookup_code = 'BLANKET'
    AND POH2.global_agreement_flag = 'Y'
    AND Nvl(pol.cancel_flag,'N') = 'N'  --Bug8847964
    AND Nvl(pol.closed_code,'OPEN') <> 'FINALLY CLOSED' --Bug8847964
--Bug #2699630: Adding trunc on both sides of the check
--Bug #5415428: Start date and need by date also needs to be considered
-- Bug #13037340: Submit Date cannot be later then effective to date of Source Document
    /* AND (NVL(TRUNC(POL.start_date), TRUNC(POH.creation_date))
         > NVL ( TRUNC(POL2.expiration_date) , TRUNC(POH2.end_date))); */
   /*Bug 16913963 roqiu, Bug 16493253, it's only working when updated PO headers, if update any information in line, it does not works,
     update the code to extends it, the condition returns false when the flag equals "Y" or "R", */
    AND TRUNC(sysdate)
        > NVL ( TRUNC(POL2.expiration_date) , TRUNC(POH2.end_date+ nvl(FND_PROFILE.VALUE('PO_REL_CREATE_TOLERANCE'),0)))
    AND Nvl(PLL.approved_flag,'N')='N';



     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

/*Bug # 13037340 - Commenting to remove check on 'effective from date' of the source document*/
------------------------------------
/*
l_progress := '007';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 7: Need-by-date and Creation date check');
   END IF;
END IF;

    --Check 7: The Need-by-date (or if NULL the PO creation date) should be
    -- after the start dates of the GA
    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_STD_BEFORE_GA_DATE');
    INSERT into po_online_report_text_gt(online_report_id,
                                         last_update_login,
                                         last_updated_by,
                                         last_update_date,
                                         created_by,
                                         creation_date,
                                         line_num,
                                         shipment_num,
                                         distribution_num,
                                         sequence,
                                         text_line,
                                         message_name)
    --SQL What: Querying for PO lines that were not created within
    --SQL       the effective dates of the referenced GA
    --SQL Why: Add appropriate error message to po_online_report_text_gt
    SELECT  p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            POL.line_num,
            PLL.shipment_num,
            0,
            p_sequence + ROWNUM,
            substr(g_linemsg||g_delim||POL.line_num||g_delim||
                   g_shipmsg||g_delim||PLL.shipment_num||g_delim||l_textline,1,240),
            'PO_SUB_STD_BEFORE_GA_DATE'
    FROM PO_LINES_GT POL, PO_HEADERS_GT POH, PO_HEADERS_ALL POH2, PO_LINE_LOCATIONS_GT PLL
    WHERE POL.po_header_id = p_document_id
    AND POL.po_header_id = POH.po_header_id
    AND   PLL.po_line_id = POL.po_line_id  --JOIN
    AND POL.from_header_id = POH2.po_header_id --JOIN
    AND POH2.type_lookup_code = 'BLANKET'
    AND POH2.global_agreement_flag = 'Y'
    AND nvl(POL.cancel_flag,'N') = 'N' 				-- bug 19810980
    AND nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'
--Bug #2699630: Adding trunc on both sides of the check
--Bug #5415428: Start date also needs to be considered
    AND NVL(TRUNC(PLL.need_by_date), NVL(TRUNC(POL.start_date),TRUNC(POH.creation_date))) < TRUNC(POH2.start_date);

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;
*/
---------------------------------
l_progress := '008';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 8: Currency code mismatch');
   END IF;
END IF;

    --Check 8: The currency_code on the PO should match the GA.
    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_STD_GA_CURR_MISMATCH');
    INSERT into po_online_report_text_gt(online_report_id,
                                         last_update_login,
                                         last_updated_by,
                                         last_update_date,
                                         created_by,
                                         creation_date,
                                         line_num,
                                         shipment_num,
                                         distribution_num,
                                         sequence,
                                         text_line,
                                         message_name)
    --SQL What: Querying for PO lines whose currency code does not
    --SQL       match the currency code of the referenced GA
    --SQL Why: Add appropriate error message to po_online_report_text_gt
    SELECT  p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            POL.line_num,
            0,
            0,
            p_sequence + ROWNUM,
            substr(g_linemsg||g_delim||POL.line_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_STD_GA_CURR_MISMATCH'
    FROM PO_LINES_GT POL, PO_HEADERS_GT POH1, PO_HEADERS_ALL POH2
    WHERE POL.po_header_id = p_document_id
    AND POL.po_header_id = POH1.po_header_id      --JOIN
    AND POL.from_header_id = POH2.po_header_id    --JOIN
    AND POH2.type_lookup_code = 'BLANKET'
    AND POH2.global_agreement_flag = 'Y'
    AND POH1.currency_code <> POH2.currency_code
    AND nvl(POL.cancel_flag,'N') = 'N' 			-- bug 19810980
    AND nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED';

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

    -- Bug 2716769 tpoon 12/26/2002
    -- If there is a currency mismatch, do not perform the currency-dependent
    -- checks below. These checks assume that the PO and the GA use the same
    -- currency.
    IF (SQL%ROWCOUNT > 0) THEN
      l_currency_mismatch := TRUE;
    END IF;

    -- Bug 2716769 tpoon 12/26/2002
    -- In version 115.8, the following checks were moved here. They will
    -- only be performed if the currency check is successful.
    --   Check 4: Total amount on PO shipments should be less than the GA
    --     amount limit.
    --   Check 5: If price override is yes, then the line unit price cannot
    --     be more than the price tolerance on the GA line.
    -- Re-numbered checks 4-10 accordingly.

-----------------------------------------

    -- Bug 2716769 Only perform this check if PO and GA use the same currency
    IF (NOT l_currency_mismatch) THEN

      l_progress := '009';

      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 9: Amt limit check for GA header');
        END IF;
      END IF;

      --bug11802312 Amount limit calculation should not include consigned shipments
      --Added this check as we are retaining the document reference on consigned shipments
      --as well.

      --Check 9: The total amount on all the standard PO SHIPMENT lines in the
      --current setup referencing the same GA should be less than the
      --amount limit on the GA header

     --<Bug 2800804, 2792477 mbhargav END>
      --Split the amount calculation to two select statements,
      --this was required because iSP is sending some chnage_requests
      --which are only in GT tables so need to get the amount for
      --current document from GT table and not the base tables

      --Get the sum of all shipments of this PO which refer to same GA
      --as is referenced on given line
      -- Bug 2818810. Also get the amount limits for those GA's here. Removed
      -- the extra select statement that was retrieving the amount limit.
      SELECT /*+ FULL(POL) ORDERED */                         -- bug3413891
             POL.line_num
      ,      nvl ( decode ( POL.quantity                      -- <SERVICES FPJ>
                          , NULL , sum ( PLL1.amount
                                       - nvl(PLL1.amount_cancelled,0) )
                          ,        sum (   ( PLL1.quantity
                                           - nvl(PLL1.quantity_cancelled,0) )
                                       * PLL1.price_override )
                          )
                 , 0 )
      ,      POH1.amount_limit
      BULK COLLECT INTO l_curr_doc_line_num,l_po_amount,l_amount_limit
      FROM   PO_LINES_GT POL, PO_HEADERS_ALL POH1, PO_LINE_LOCATIONS_GT PLL1
      WHERE  PLL1.from_header_id = POL.from_header_id
      AND    POL.po_header_id = p_document_id
      AND    POL.from_header_id = POH1.po_header_id
      AND    POH1.type_lookup_code = 'BLANKET'
      AND    POH1.global_agreement_flag = 'Y'
      AND    POH1.amount_limit IS NOT NULL
      AND    Nvl(PLL1.consigned_flag,'N') <> 'Y' --bug11802312
      GROUP BY
             POL.line_num
      ,      POL.quantity                                     -- <SERVICES FPJ>
      ,      POH1.amount_limit;

      --Get the sum of all shipments of approved POs in current setup which refer to same
      --GA as is referenced on given line
      -- Bug 2818810. Added extra join to aliases POH1 and PLL to return rows of
      -- given lines with shipments that reference GA's with amount limits only.

      -- bug3413891
      -- 1) Added optimizer hint FULL(POL)
      -- 2) Removed the join to PO_LINE_LOCATIONS_GT as it will bring in wrong
      --    result if the standard PO line has multiple shipments

      SELECT /*+ FULL(POL) */
             POL.line_num
      ,      nvl ( decode ( POL.quantity                      -- <SERVICES FPJ>
                          , NULL , sum ( PLL2.amount
                                       - nvl(PLL2.amount_cancelled,0) )
                          ,        sum (   ( PLL2.quantity
                                           - nvl(PLL2.quantity_cancelled,0) )
                                       * PLL2.price_override )
                          )
                 , 0 )
      BULK COLLECT INTO l_prev_doc_line_num, l_prev_rel_amount
      FROM PO_LINE_LOCATIONS_ALL PLL2, PO_HEADERS_ALL POH1,
           PO_HEADERS_ALL POH2, PO_LINES_GT POL
      WHERE POL.po_header_id = p_document_id
      AND   POL.from_header_id = POH1.po_header_id    --JOIN
      AND   POH1.type_lookup_code = 'BLANKET'
      AND   POH1.global_agreement_flag = 'Y'
      AND   POH1.amount_limit IS NOT NULL
      AND   PLL2.from_header_id = POL.from_header_id  --JOIN
      AND   POH2.po_header_id = PLL2.po_header_id     --JOIN
      AND   nvl(POH2.approved_flag, 'N') = 'Y'
      AND   PLL2.po_header_id <> p_document_id
      AND   Nvl(PLL2.consigned_flag,'N') <> 'Y'  --bug11802312
      GROUP BY
            POL.line_num
      ,     POL.quantity;                                     -- <SERVICES FPJ>

      --Addup the released amount as obtained from above sqls. This loop goes by prev_doc_line_num.COUNT
      --as its possible we may not have any previous POs cut against those GAs.
      FOR l_prev_index IN 1..l_prev_doc_line_num.COUNT LOOP

          -- Bug 2818810. Fixed looping and the indexing used to ensure that
          -- correct PO amounts are matched with existing PO amounts by adding
          -- an inner loop and correcting the IF condition.
          FOR l_index IN 1..l_curr_doc_line_num.COUNT LOOP
              --first check for line number matching before adding up
              IF l_curr_doc_line_num(l_index) = l_prev_doc_line_num(l_prev_index) THEN
                  -- Found match, so add prev amount and exit inner loop
                  l_po_amount(l_index) := l_po_amount(l_index)+l_prev_rel_amount(l_prev_index);
                  EXIT;
              END IF;
          END LOOP;

      END LOOP;

      l_textline :=
          FND_MESSAGE.GET_STRING('PO', 'PO_SUB_STD_AMT_GRT_GA_AMT_LMT');

      --Go through all lines in current PO (which refer to a GA)
      FOR l_curr_doc_line_index IN 1..l_curr_doc_line_num.COUNT LOOP

         --If the amount released and current amount is greater than amount limit then
         --raise an error for that line
         IF (l_amount_limit(l_curr_doc_line_index) < l_po_amount(l_curr_doc_line_index)) THEN
             l_rowcount := l_rowcount +1;
             -- Bug 2818810. Use l_curr_doc_line_num to retrieve the line number
             INSERT INTO po_online_report_text_gt(online_report_id,
                                last_update_login,
                                last_updated_by,
                                last_update_date,
                                created_by,
                                creation_date,
                                line_num,
                                shipment_num,
                                distribution_num,
                                sequence,
                                text_line,
                message_name)
             VALUES(p_online_report_id,
                     p_login_id,
                     p_user_id,
                     sysdate,
                     p_user_id,
                     sysdate,
                     l_curr_doc_line_num(l_curr_doc_line_index),
                     0,
                     0,
                     p_sequence+ l_rowcount,
                     substr(g_linemsg||g_delim||l_curr_doc_line_num(l_curr_doc_line_index)||g_delim
                            ||l_textline,1,240),
                     'PO_SUB_STD_AMT_GRT_GA_AMT_LMT');

          END IF; --amount limit check

       END LOOP;  --end of going through each line on current PO

       --Increment the p_sequence with number of errors reported in last query
       p_sequence := p_sequence + l_rowcount;
       --<Bug 2800804, 2792477 mbhargav END>

   END IF; -- NOT l_currency_mismatch

------------------------------------------

    -- Bug 2716769 Only perform this check if PO and GA use the same currency
    IF (NOT l_currency_mismatch) THEN

      l_progress := '010';
      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 10: Price Tolerance check');
        END IF;
      END IF;

      --Check 10: If price override is yes then the line unit price cannot be more
      --than the price tolerance on the GA line.
      --
      -- Bug 3177525: This check should not be done if allow_price_override_flag
      -- is 'N' because the user can never modify the standard PO price/amount;
      -- it is automatically defaulted.

      INSERT into po_online_report_text_gt(online_report_id,
                                           last_update_login,
                                           last_updated_by,
                                           last_update_date,
                                           created_by,
                                           creation_date,
                                           line_num,
                                           shipment_num,
                                           distribution_num,
                                           sequence,
                                           text_line,
                                           message_name)
      --SQL What: Querying for PO line unit prices that exceed the
      --SQL       price tolerance on the GA line
      --SQL Why: Add appropriate error message to po_online_report_text_gt
      SELECT  p_online_report_id,
              p_login_id,
              p_user_id,
              sysdate,
              p_user_id,
              sysdate,
              POL1.line_num,
              0,
              0,
              p_sequence + ROWNUM,
              decode ( POL1.order_type_lookup_code             -- <BUG 3262859>
                     , 'FIXED PRICE' , PO_CORE_S.get_translated_text
                                       (   'PO_SUB_PO_LINE_GT_GA_AMT_TOL'
                                       ,   'LINE_NUM', POL1.line_num
                                       ,   'LINE_AMT', POL1.amount
                                       ,   'AMT_TOL' , nvl ( POL2.not_to_exceed_price
                                                     , POL1.amount )
                                       )
                     ,                 PO_CORE_S.get_translated_text
                                       (   'PO_SUB_PO_LINE_GT_GA_PRICE_TOL'
                                       ,   'LINE_NUM'  , POL1.line_num
                                       ,   'LINE_PRICE', POL1.unit_price
                                       ,   'PRICE_TOL' , nvl ( POL2.not_to_exceed_price
                                       , POL1.unit_price )
                                       )
                     ),
              decode ( POL1.order_type_lookup_code             -- <BUG 3262859>
                     , 'FIXED PRICE' , 'PO_SUB_PO_LINE_GT_GA_AMT_TOL'
                     ,                 'PO_SUB_PO_LINE_GT_GA_PRICE_TOL'
                     )
      FROM PO_LINES_GT POL1, PO_LINES_ALL POL2, PO_HEADERS_ALL POH
      WHERE POL1.po_header_id = p_document_id
      AND POH.po_header_id = POL1.from_header_id --JOIN
      AND POH.type_lookup_code = 'BLANKET'
      AND POH.global_agreement_flag = 'Y'
      AND POL1.from_line_id = POL2.po_line_id     --JOIN
      AND nvl(POL1.cancel_flag,'N')= 'N'
      AND nvl(POL1.closed_code,'OPEN') <> 'FINALLY CLOSED'
      AND POL2.allow_price_override_flag = 'Y'                -- Bug 3177525
      AND (                                                   -- <SERVICES FPJ>
              (   ( POL1.order_type_lookup_code IN ('QUANTITY','AMOUNT','RATE') ) -- <BUG 3262859>
              AND ( POL1.unit_price > nvl ( POL2.not_to_exceed_price
                                          , POL1.unit_price )
                  )
              )
          OR
              (   ( POL1.order_type_lookup_code IN ('FIXED PRICE') )           -- <BUG 3262859>
              AND ( POL1.amount > nvl( POL2.not_to_exceed_price, POL1.amount ) )
              )
          );

       --Increment the p_sequence with number of errors reported in last query
      p_sequence := p_sequence + SQL%ROWCOUNT;

    END IF; -- NOT l_currency_mismatch

-------------------------------------------

    -- Bug 2716769 Only perform this check if PO and GA use the same currency
    IF (NOT l_currency_mismatch) THEN

      l_progress := '011';
      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 11: Min Release Amount at line level check');
        END IF;
      END IF;

      --Check 11: The total amount on all the lines on the standard PO
      --referencing same GA line should be greater than the minimum release amount
      --on the GA line.
      l_textline :=                                        -- <2710030>
          FND_MESSAGE.GET_STRING('PO','PO_SUB_STD_GA_LINE_LESS_MINREL');
      INSERT into po_online_report_text_gt(online_report_id,
                                           last_update_login,
                                           last_updated_by,
                                           last_update_date,
                                           created_by,
                                           creation_date,
                                           line_num,
                                           shipment_num,
                                           distribution_num,
                                           sequence,
                                           text_line,
                                           message_name)
      --SQL What: Querying for PO shipment totals that fail to meet the
      --SQL       minimum release amount of the GA line
      --SQL Why: Add appropriate error message to po_online_report_text_gt
      SELECT  p_online_report_id,
              p_login_id,
              p_user_id,
              sysdate,
              p_user_id,
              sysdate,
              POL1.line_num,
              0,
              0,
              p_sequence + ROWNUM,
              substr(g_linemsg||g_delim||POL1.line_num||g_delim
                     ||l_textline,1,240),
              'PO_SUB_STD_GA_LINE_LESS_MINREL'                      -- <2710030>
      FROM PO_LINES_GT POL1, PO_LINES_ALL POL2, PO_HEADERS_ALL POH
      WHERE POL1.po_header_id = p_document_id
      AND POL1.from_header_id = POL2.po_header_id  --JOIN
      AND POL1.from_line_id = POL2.po_line_id      --JOIN
      AND POL1.from_header_id = POH.po_header_id   --JOIN
      AND POH.type_lookup_code = 'BLANKET'
      AND POH.global_agreement_flag = 'Y'
      AND POL2.min_release_amount IS NOT NULL
      AND POL2.min_release_amount >
          --SQL What: Querying PO_LINE_LOCATIONS for the total amount of the
          --SQL       shipments in this PO that reference the current GA line
          --SQL Why: This sum determines whether the minimum release amount
          --SQL      for the GA line has been met
          (   SELECT                                          -- <SERVICES FPJ>
                  decode ( POL1.quantity
                         , NULL , decode ( sum ( PLL.amount
                                               - nvl(PLL.amount_cancelled,0) )
                                         , 0 , POL2.min_release_amount
                                         ,     sum ( PLL.amount
                                                   - nvl(PLL.amount_cancelled,0) )
                                         )
                         ,        decode ( sum ( PLL.quantity
                                               - nvl(PLL.quantity_cancelled,0) )
                                         , 0 , POL2.min_release_amount
                                         ,     sum ( ( PLL.quantity
                                                     - nvl(PLL.quantity_cancelled,0) )
                                                   * PLL.price_override )
                                         )
                         )
              --<Bug 2792477 mbhargav>
              --Changing the query to go to PO_LINE_LOCATIONS_GT instead of PO_LINE_LOCATIONS
              FROM PO_LINE_LOCATIONS_GT PLL
              WHERE PLL.po_header_id = p_document_id
              AND PLL.from_line_id = POL2.po_line_id);

       --Increment the p_sequence with number of errors reported in last query
      p_sequence := p_sequence + SQL%ROWCOUNT;

    END IF; -- NOT l_currency_mismatch

------------------------------------

--<Bug 17367629 Start>

 l_progress := '012';
      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 12: Price mismatch check');
        END IF;
      END IF;

      --Check 12: Check whether the price on the spo line matches with
	  --the price on the referenced GA line. If not throw a warning.

      l_textline :=
          FND_MESSAGE.GET_STRING('PO','PO_SUB_STD_GA_PRICE_NOTMATCH');

 INSERT into po_online_report_text_gt(online_report_id,
                                         last_update_login,
                                         last_updated_by,
                                         last_update_date,
                                         created_by,
                                         creation_date,
                                         line_num,
                                         shipment_num,
                                         distribution_num,
                                         sequence,
                                         text_line,
                                         message_name,
					 message_type)
    --SQL What: Querying for PO lines with price mismatch that reference GAs.
    --SQL Why: Add appropriate error message to po_online_report_text_gt
    SELECT  p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            POL1.line_num,
            0,
            0,
            p_sequence + ROWNUM,
            substr(g_linemsg||g_delim||POL1.line_num||g_delim
                   ||l_textline,1,240),
            'PO_SUB_STD_GA_PRICE_NOTMATCH',
	    'W'
    FROM PO_LINES_ALL POL1, PO_HEADERS_ALL POH, PO_LINES_ALL POL2   -- BUG#20125818
    WHERE POL1.po_header_id = p_document_id
	  AND POL1.from_header_id = POL2.po_header_id
      AND POL1.from_line_id = POL2.po_line_id
      AND POL1.from_header_id = POH.po_header_id
      AND POH.type_lookup_code = 'BLANKET'
      AND POH.global_agreement_flag = 'Y'
	  AND NVL(POH.approved_flag, 'N') = 'Y'
	  AND NVL(POH.user_hold_flag, 'N') <> 'Y'
	  AND ( POL1.order_type_lookup_code IN ('QUANTITY','AMOUNT','RATE')
          AND   -- BUG#20125818 fix starts
          (
            EXISTS (SELECT 'GBPA Line Unit Price Mismatch' FROM DUAL WHERE POL1.FROM_LINE_LOCATION_ID IS NULL AND POL1.UNIT_PRICE <> POL2.UNIT_PRICE)
            OR
            EXISTS (SELECT 'GBPA Line Price Break Mismatch' FROM PO_LINE_LOCATIONS_ALL PLL WHERE PLL.LINE_LOCATION_ID = POL1.FROM_LINE_LOCATION_ID AND POL1.UNIT_PRICE <> PLL.PRICE_OVERRIDE)
          )   -- BUG#20125818 fix ends
        )
      AND nvl(POL1.cancel_flag,'N') = 'N' 			-- bug 19810980
      AND nvl(POL1.closed_code,'OPEN') <> 'FINALLY CLOSED'
      AND EXISTS (SELECT 'shipment status is not approved'
           FROM po_line_locations_gt pllg
          WHERE pllg.po_line_id = pol1.po_line_id
            AND nvl(pllg.approved_flag, 'N') <> 'Y');


               p_sequence := p_sequence + SQL%ROWCOUNT;

	--<Bug 17367629 End>

--<Bug 17956063 Start>

 l_progress := '013';
      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PO STD GA 13: Source doc close/cancel state check');
        END IF;
      END IF;

	  --Check 13: Close status of valid source doc line can't be 'CLOSED'
	  --or 'FINALLY CLOSED' and cancel_flag can't be 'Y'

      l_textline :=
          FND_MESSAGE.GET_STRING('PO','PO_SUB_STD_GA_LINE_CLOSED');

	  INSERT into po_online_report_text_gt(online_report_id,
                                           last_update_login,
                                           last_updated_by,
                                           last_update_date,
                                           created_by,
                                           creation_date,
                                           line_num,
                                           shipment_num,
                                           distribution_num,
                                           sequence,
                                           text_line,
                                           message_name)
      --SQL What: Query for source doc lines that close_status are not
      --SQL       'OPEN' or cancel flag is 'Y'
      --SQL Why: Add appropriate error message to po_online_report_text_gt
      SELECT  p_online_report_id,
              p_login_id,
              p_user_id,
              sysdate,
              p_user_id,
              sysdate,
              POL1.line_num,
              0,
              0,
              p_sequence + ROWNUM,
              substr(g_linemsg||g_delim||POL1.line_num||g_delim
                     ||l_textline,1,240),
              'PO_SUB_STD_GA_LINE_CLOSED'
      FROM PO_LINES_GT POL1, PO_LINES_ALL POL2, PO_HEADERS_ALL POH
      WHERE POL1.po_header_id = p_document_id
      AND POL1.from_header_id = POL2.po_header_id
      AND POL1.from_line_id = POL2.po_line_id
      AND POL2.po_header_id = POH.po_header_id
      AND POH.type_lookup_code = 'BLANKET'
      AND POH.global_agreement_flag = 'Y'
      AND (NVL(POL2.closed_code, 'OPEN') <> 'OPEN'
           OR NVL(POL2.cancel_flag, 'N') = 'Y')
      AND nvl(POL1.cancel_flag,'N') = 'N'        --bug 19810980
      AND nvl(POL1.closed_code,'OPEN') <> 'FINALLY CLOSED'; --bug 19810980

	  p_sequence := p_sequence + SQL%ROWCOUNT;

--<Bug 17956063 End>

l_progress := '014';
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END CHECK_STD_GLOBAL_REF;

-- <GC FPJ START>
/**
* Private Procedure: CHECK_STD_GC_REF
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       x_sequence:          Sequence number of last reported error
* Modifies: Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure performs checks for the lines referencing global
*           contracts to enforce the following:
*           1) Contract is still enabled for purchasing in current OU
*           2) Supplier Site is still enabled on the referenced GC
*           3) Amount released should be less than amount limit on GC
* Returns:
*  x_sequence: This parameter contains the current count of number of error
*              messages inserted
*  x_return_status: This parameter signifies whether the checks contained in
*                   this procedure completed successfully.
*/

PROCEDURE check_std_gc_ref
( p_document_id IN NUMBER,
   p_online_report_id IN NUMBER,
   p_user_id IN NUMBER,
   p_login_id IN NUMBER,
   x_sequence IN OUT NOCOPY NUMBER,
   x_return_status OUT NOCOPY VARCHAR2
) IS

l_textline          PO_ONLINE_REPORT_TEXT.text_line%TYPE := NULL;
l_api_name          CONSTANT VARCHAR2(40) := 'CHECK_STD_GC_REF';
l_progress          VARCHAR2(3);
l_currency_mismatch VARCHAR2(1) := FND_API.G_FALSE;

TYPE NumTab is TABLE of NUMBER INDEX BY BINARY_INTEGER;
l_curr_doc_line_num NumTab;
l_prev_doc_line_num NumTab;
l_rowcount          NUMBER := 0;
l_po_amount         NumTab;
l_prev_rel_amount   NumTab;
l_amount_limit      NumTab;
l_module            FND_LOG_MESSAGES.module%TYPE;
--<<Bug8422577>>
l_current_different NumTab;
l_prev_different NumTab;
l_current_rate NumTab;
l_prev_rate NumTab ;
l_contract_rate NumTab ;
--<<Bug8422577>>
BEGIN

    l_progress := '010';
    l_module := g_log_head || '.' || l_api_name || '.' || l_progress;

    IF g_debug_stmt THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                      'PO STD GC 1: GC enabled for purchasing in current OU');
       END IF;
    END IF;

    -- Check 1: Current OU should still be enabled for purchasing on the GC
    --          being referenced
    --< Shared Proc FPJ > Bug 3301427: Only do this check for new SPO lines

    l_textline := FND_MESSAGE.get_string ('PO', 'PO_SUB_STD_GC_NOT_EN_PUR');

    INSERT INTO po_online_report_text_gt (
        online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
        message_name
    )
    SELECT
        p_online_report_id,
        p_login_id,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        POL.line_num,
        0,
        0,
        x_sequence + ROWNUM,
        SUBSTR (g_linemsg || g_delim || POL.line_num || g_delim || l_textline,
                 1,
                 240),
        'PA_SUB_STD_GC_NOT_EN_PUR'
    FROM
        po_headers_gt  POH,
        po_lines_gt    POL,
        po_headers_all POHA
    WHERE
        POH.po_header_id = p_document_id
    AND POL.po_header_id = POH.po_header_id
    AND POL.contract_id = POHA.po_header_id
    AND POHA.global_agreement_flag = 'Y'
    AND nvl(POL.cancel_flag,'N') = 'N'
    AND nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'  --bug 19810980
    AND NOT EXISTS                                  --< Bug 3301427 Start >
        (SELECT 'previously approved shipment'
           FROM po_line_locations_gt pllg
          WHERE pllg.po_line_id = pol.po_line_id
            AND pllg.approved_date IS NOT NULL)     --< Bug 3301427 End >
    AND NOT EXISTS (SELECT 1
                    FROM   po_ga_org_assignments PGOA,
                           po_system_parameters  PSP
                    WHERE  PGOA.po_header_id = POHA.po_header_id
                    AND    PGOA.purchasing_org_id = PSP.org_id
                    AND    PGOA.enabled_flag = 'Y');

    x_sequence := x_sequence + SQL%ROWCOUNT;

    ----------------------------------

    l_progress := '020';
    l_module := g_log_head || '.' || l_api_name || '.' || l_progress;

    IF g_debug_stmt THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                      'PO STD GC 2: supplier site en for pur in current OU');
       END IF;
    END IF;

    -- Check 2: Supplier Site should be a purchasing site defined in GC
    --          Org Assignments
    --< Shared Proc FPJ > Bug 3301427: Only do this check for new SPO lines
    /* R12 GCPA
    Skip Vendor Site validation for Contracts having "Enable All Sites" is set to Y
    */

    l_textline := FND_MESSAGE.get_string ('PO', 'PO_SUB_STD_GC_INVALID_SITE');

    INSERT INTO po_online_report_text_gt (
        online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
        message_name
    )
    SELECT
        p_online_report_id,
        p_login_id,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        POL.line_num,
        0,
        0,
        x_sequence + ROWNUM,
        SUBSTR  (g_linemsg || g_delim || POL.line_num || g_delim || l_textline,
                 1,
                 240),
        'PA_SUB_STD_GC_INVALID_SITE'
    FROM
        po_headers_gt  POH,
        po_lines_gt    POL,
        po_headers_all POHA
    WHERE
        POH.po_header_id = p_document_id
    AND POL.po_header_id = POH.po_header_id
    AND POL.contract_id = POHA.po_header_id
    AND POHA.global_agreement_flag = 'Y'
    AND nvl(POL.cancel_flag,'N') = 'N' 				-- bug 19810980
    AND nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND NOT EXISTS                                  --< Bug 3301427 Start >
        (SELECT 'previously approved shipment'
           FROM po_line_locations_gt pllg
          WHERE pllg.po_line_id = pol.po_line_id
            AND pllg.approved_date IS NOT NULL)     --< Bug 3301427 End >
    AND NOT EXISTS (SELECT 1
                    FROM   po_ga_org_assignments PGOA
                    WHERE  PGOA.po_header_id = POHA.po_header_id
                    AND    PGOA.vendor_site_id = Decode( Nvl ( poha.Enable_All_Sites,'N'),'N',POH.vendor_site_id,pgoa.Vendor_Site_Id)
                    AND    PGOA.enabled_flag = 'Y');

    x_sequence := x_sequence + SQL%ROWCOUNT;

    ----------------------------------

    l_progress := '030';
    l_module := g_log_head || '.' || l_api_name || '.' || l_progress;

    IF g_debug_stmt THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                      'PO STD GC 3: currency check against referenced GC');
       END IF;
    END IF;

    -- bug5153099
    -- Removed Check 3 as different currencies are being allowed if OU is same.
    -- Renumbered Check 4 as Check 3.
    -- In the new Check 3, Removed the IF condition as currency mismatch is allowed.
    -- Also multiplied amount values by rate for handling currency mismatch.
    -- Added a join with po_headers_all POHA1 for getting rate.

    -- Check 3: Amount Released should not exceed the amount limit on the GC

    -- bug3251561
    -- Need to check amount based lines as well.

    -- SQL What: For each line that has a contract reference, get the
    --           total amount released for that contract on this PO
    -- SQL Why:  Need to calculate the total amount released for the
    --           contract and we are calculating current PO and other
    --           POs separately because current PO lines (stored in
    --           po_lines_gt) may not go to po_lines_all eventually
    --<Complex Work R12>: changed query to use Line qty/amt/price
    --instead of summing up the Line Loc values.  The results should be
    --equivalent for SPOs.

--    Bug8422577 When any one of the lines against the contract is in a different
--    currency, then we must convert all the lines to base currency.
--    l_current_different indicates if the current line is in a different currency
--    from the contract currency
--    l_current_rate is the rate on the PO containing the current line
--    l_contract_rate is the rate of the contract corresponding to the current line

    --bug 19682681,  add a case to the different comparison, when rate was changed.
    SELECT /*+ FULL(POL) ORDERED */   -- bug3413891
           POL.line_num,
           sum(DECODE (POL1.order_type_lookup_code
                   , 'RATE', POL1.amount
                   , 'FIXED PRICE', POL1.amount
                   , POL1.quantity * POL1.unit_price)) ,
           POHA.amount_limit,
           Decode(poha.currency_code,poha1.currency_code,Decode(poha.rate,poha1.rate,0,1),1),
           Nvl(poha1.rate,1),
           Nvl(poha.rate,1)
    BULK COLLECT INTO l_curr_doc_line_num,
                      l_po_amount,
                      l_amount_limit,
                      l_current_different,
                      l_current_rate,
                      l_contract_rate
    FROM po_lines_gt          POL,     -- target_line
         po_headers_all       POHA,    -- global contract
         po_lines_gt          POL1,     -- all lines in current doc
                                       -- having the same contract ref
         po_headers_all       POHA1    -- document
    WHERE
         POL.po_header_id = p_document_id
    AND  POL.po_header_id = POHA1.po_header_id
    AND  POL.contract_id  = POHA.po_header_id
    AND  POHA.global_agreement_flag = 'Y'
    AND  POHA.amount_limit IS NOT NULL
    AND  POL.contract_id = POL1.contract_id
	AND  POL.po_header_id=POL1.po_header_id --Bug: 12828203
    GROUP BY POL.line_num,POHA.amount_limit,Decode(poha.currency_code,poha1.currency_code,
           Decode(poha.rate,poha1.rate,0,1),1),
           Nvl(poha1.rate,1),
           Nvl(poha.rate,1);

    -- Get the sum of all other shipments of approved POs referring
    -- to the same GC

    -- bug5153099
    -- Multiplied amount values by rate for handling currency mismatch.

    -- bug3251561
    -- Need to check amount based lines as well.

    -- SQL What: For each line referencing a global contract, get total
    --           amount released for the contract, without including
    --           the current PO
    -- SQL Why:  Need to calculate the total amount released of the GC
    --           to determine whether amount limit is exceeded
    --<Complex Work R12>: changed query to use Line qty/amt/price
    --instead of summing up the Line Loc values.  The results should be
    --equivalent for SPOs.

--    Bug8422577 l_prev_different indicates if any one of the previously released
--    lines against the same contract, as the current line, is of different currency
--    l_prev_rate indicates the rate on the PO of each line corresponding to the contract
--    on the current line
--    l_prev_rel_amount now contains the previously released amount on each line
--    corresponding to the contract on currenct line

    --bug 19682681,  add a case to the different comparison, when rate was changed.
    SELECT /*+ FULL(POL) ORDERED*/     -- bug3413891,9242146
           POL.line_num,
           sum(DECODE (POL1.order_type_lookup_code
                   , 'RATE', POL1.amount
                   , 'FIXED PRICE', POL1.amount
                   , POL1.quantity * POL1.unit_price)),
                   Decode(POHA.currency_code,POH1.currency_code,Decode(POHA.rate,POH1.rate,0,1),1),
                   Nvl(POH1.rate,1)
    BULK COLLECT INTO l_prev_doc_line_num,
                      l_prev_rel_amount,
                      l_prev_different,
                      l_prev_rate
    FROM po_lines_gt           POL,     -- target line
         po_headers_all        POHA,     -- global contract
					--bug9242146, force tables
                                        --to be joined in the order specified.
         po_lines_all          POL1,    -- all lines from other doc with
                                        -- the same GC ref
         po_headers_all        POH1    -- headers of lines in POL1
    WHERE
         POL.po_header_id = p_document_id
    AND  POL.contract_id = POHA.po_header_id
    AND  POHA.global_agreement_flag = 'Y'
    AND  POHA.amount_limit IS NOT NULL
    AND  POL1.contract_id = POL.contract_id
    AND  POL1.po_header_id <> POL.po_header_id
    AND  POH1.po_header_id = POL1.po_header_id
    AND  POH1.approved_flag = 'Y'
    GROUP BY POL.line_num, Decode(POHA.currency_code,POH1.currency_code,
                   Decode(POHA.rate,POH1.rate,0,1),1),
                   Nvl(POH1.rate,1);

	FOR l_index IN 1..l_curr_doc_line_num.COUNT LOOP--Bug: 12828203 Start
        IF(l_current_different(l_index) =1) THEN
            l_po_amount(l_index) := (l_po_amount(l_index) * l_current_rate(l_index));
            l_amount_limit(l_index) :=  l_amount_limit(l_index) * l_contract_rate(l_index);
        END IF;
    END LOOP;                                        --Bug: 12828203 End

    -- For each line having GC reference, the line number will be stored
    -- in l_curr_doc_line_num and the amount released of the GC from the
    -- curent document will be stored in l_po_amount. Also, for the same
    -- line there will be a corresponding entry in p_prev_doc_line_num,
    -- which stores the line number, and l_prev_rel_amount, which stores
    -- the amount released from all other lines referencing the same
    -- GC. The loop below is to add up l_po_amount and l_prev_rel_amount
    -- to get the total amount released for the GC

--    Bug8422577 When ever the current line or the any of the previous lines
--    are of different currency we convert the amounts to base currency
--    else we do not.

    FOR l_prev_index IN 1..l_prev_doc_line_num.COUNT LOOP
        FOR l_index IN 1..l_curr_doc_line_num.COUNT LOOP
            -- first check for line number matching before adding up
            IF l_curr_doc_line_num(l_index) =
               l_prev_doc_line_num(l_prev_index) THEN
               IF(l_current_different(l_index) =1 OR l_prev_different(l_prev_index) =1) THEN
                 l_po_amount(l_index) := l_po_amount(l_index) + (l_prev_rel_amount(l_prev_index)* l_prev_rate(l_prev_index));--Bug: 12828203
                ELSE
                  l_po_amount(l_index) := l_po_amount(l_index) + l_prev_rel_amount(l_prev_index);

                END IF;
                EXIT;
            END IF;
        END LOOP;
    END LOOP;

    IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                      'PO STD GC 3: Amount Released Check');
        END IF;
    END IF;

    l_textline := FND_MESSAGE.get_string('PO',
                                          'PO_SUB_STD_CONTRACT_AMT_LIMIT');

    -- Go through all lines in current PO (which refer to GCs)
    FOR l_curr_doc_line_index IN 1..l_curr_doc_line_num.COUNT LOOP

        IF (l_amount_limit(l_curr_doc_line_index) <
            l_po_amount(l_curr_doc_line_index))
        THEN
            l_rowcount := l_rowcount + 1;

            INSERT INTO po_online_report_text_gt (
                online_report_id,
                last_update_login,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                line_num,
                shipment_num,
                distribution_num,
                sequence,
                text_line,
                message_name
            ) VALUES (
                p_online_report_id,
                p_login_id,
                p_user_id,
                SYSDATE,
                p_user_id,
                SYSDATE,
                l_curr_doc_line_num(l_curr_doc_line_index),
                0,
                0,
                x_sequence + l_rowcount,
                SUBSTR (g_linemsg || g_delim ||
                        l_curr_doc_line_num(l_curr_doc_line_index) ||
                        g_delim || l_textline, 1, 240),
                'PO_SUB_STD_CONTRACT_AMT_LIMIT'
            );

        END IF; -- if amount limit < amount released
    END LOOP;

    x_sequence := x_sequence + l_rowcount;

   /* Bug  13037340 - Added new validation to avoid PO refering Contract which had expired. */
   l_progress := '040';

   IF g_debug_stmt THEN
	   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		 FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
			  || l_progress,'PO STD GC 4: Exp Date Check on Source Document');
	   END IF;
	END IF;
    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_STD_AFTER_GA_DATE');
    INSERT INTO po_online_report_text_gt (
              online_report_id,
              last_update_login,
              last_updated_by,
              last_update_date,
              created_by,
              creation_date,
              line_num,
              shipment_num,
              distribution_num,
              sequence,
              text_line,
              message_name
          )
    SELECT  p_online_report_id,
          p_login_id,
          p_user_id,
          sysdate,
          p_user_id,
          sysdate,
          POL.line_num,
          PLL.shipment_num,
          0,
          x_sequence + ROWNUM,
          substr(g_linemsg||g_delim||POL.line_num||g_delim
                 ||l_textline,1,240),
          'PO_SUB_STD_AFTER_GA_DATE'
    FROM PO_LINES_GT POL,
         PO_HEADERS_GT POH,
         PO_HEADERS_ALL POH2,
         PO_LINE_LOCATIONS_GT PLL
    WHERE POL.po_header_id = p_document_id
      AND POL.po_header_id = POH.po_header_id
      AND PLL.po_line_id = POL.po_line_id
      AND POL.contract_id = POH2.po_header_id
      AND POH2.type_lookup_code = 'CONTRACT'
      AND POH2.global_agreement_flag = 'Y'
      AND Nvl(pol.cancel_flag,'N') = 'N'
      AND Nvl(pol.closed_code,'OPEN') <> 'FINALLY CLOSED'
      AND TRUNC(sysdate)
         > TRUNC(POH2.end_date
                 + nvl(FND_PROFILE.VALUE('PO_REL_CREATE_TOLERANCE'),0))
      /**Bug 18184689, update the condition, when revise an approved document the flag should be
         Y or R, bug 16073823 only consider the value of Y.
      **/
      -- AND Nvl(PLL.approved_flag,'N') <> 'Y' ; -- Bug 16073823
      AND Nvl(PLL.approved_flag,'N')='N';

	 x_sequence := x_sequence + SQL%ROWCOUNT;
    /* Bug  13037340 - End */
    l_progress := '999';
    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END CHECK_STD_GC_REF;

-- <GC FPJ END>

--For Contract PA
/**
* Private Procedure: CHECK_CONTRACT_AGREEMENT
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure runs the document submission checks for CONTRACT
*           PAs
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*/
PROCEDURE check_contract_agreement(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_textline  po_online_report_text.text_line%TYPE := NULL;
l_api_name  CONSTANT varchar2(40) := 'CHECK_CONTRACT_AGREEMENT';
l_progress VARCHAR2(3);

BEGIN

l_progress := '000';

l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'PA CONTRACT 1: Released Amount exceeds Amount Limit');
   END IF;
END IF;

    -- Check 1: The amount of all standard purchase orders
    -- for a contract should not exceed the amount limit of the contract.
    -- PO_SUB_CONTRACT_AMT_LIMIT
    --<Complex Work R12>: changed query to use Line qty/amt/price
    --instead of summing up the Line Loc values.  The results should be
    --equivalent for SPOs.
    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_CONTRACT_AMT_LIMIT');
    INSERT INTO po_online_report_text_gt(online_report_id,
                                         last_update_login,
                                         last_updated_by,
                                         last_update_date,
                                         created_by,
                                         creation_date,
                                         line_num,
                                         shipment_num,
                                         distribution_num,
                                         sequence,
                                         text_line,
                                         message_name)
  SELECT  p_online_report_id,
                p_login_id,
                p_user_id,
                sysdate,
                p_user_id,
                sysdate,
                0,
                0,
                0,
                p_sequence + ROWNUM,
                substr(l_textline,1,240),
                'PO_SUB_CONTRACT_AMT_LIMIT'
       -- <GC FPJ START>
       -- For local contract, need to take care of currency conversion
       -- since the std PO referencing a contract may be in a different
       -- currency
       --<Bug#4619187>
       --Added a sum function to the sql's select clause

       -- bug5138959
       -- Added a sum function to the second select clause
       -- bug5153099
       -- Removed group by clause in subquery.Also removed the checking for
       -- global_agreement_flag and the corresponding OR case logic.

       FROM PO_HEADERS_GT POH
       WHERE POH.po_header_id = p_document_id
       AND   POH.type_lookup_code = 'CONTRACT'
       AND   POH.amount_limit IS NOT NULL
       AND   ((POH.amount_limit * NVL(POH.rate, 1))  -- amt limit in fn currency --<SERVICES FPJ>
                       <
                       (SELECT SUM(                           --Bug#4619187
                                    DECODE (POL1.order_type_lookup_code
                                           , 'RATE', POL1.amount
                                           , 'FIXED PRICE', POL1.amount
                                           , POL1.quantity * POL1.unit_price)
                                   * NVL(POH1.rate,1)
                                  )
                        FROM   po_headers POH1,
                               po_lines   POL1
                        WHERE  POL1.contract_id = POH.po_header_id
                        AND    POL1.po_header_id = POH1.po_header_id
                        AND    NVL(POL1.cancel_flag, 'N') = 'N'
                        )  -- amt released in fn currency
             );

       -- <GC FPJ END>

     --Increment the p_sequence with number of errors reported in last query
    p_sequence := p_sequence + SQL%ROWCOUNT;

l_progress := '002';
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END CHECK_CONTRACT_AGREEMENT;

--For PO, REQ, REL
/**
* Private Procedure: DO_CBC_RELATED_VALIDATIONS
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure runs the document submission checks for HEADER
*           level CBC (FPI Project) validations for PO, REQ, REL
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*/
PROCEDURE do_cbc_related_validations(p_document_type IN VARCHAR2,
                       p_document_subtype IN VARCHAR2,
                       p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_msg_count NUMBER;
l_msg_data  VARCHAR2(2400);
l_return_status VARCHAR2(1);
l_cbc_enabled VARCHAR2(1);
l_result NUMBER :=0;

l_textline po_online_report_text.text_line%TYPE := NULL;
l_api_name  CONSTANT varchar2(40) := 'DO_CBC_RELATED_VALIDATIONS';
l_progress VARCHAR2(3);

BEGIN

l_progress := '000';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'CBC 1: Check CBC');
   END IF;
END IF;

     IGC_CBC_PO_GRP.IS_CBC_ENABLED ( p_api_version       => 1.0,
                                 p_init_msg_list     => FND_API.G_FALSE,
                                 p_commit            => FND_API.G_FALSE,
                                 p_validation_level  => 100,
                                 x_return_status    => l_return_status,
                                 x_msg_count         => l_msg_count,
                                 x_msg_data          => l_msg_data,
                                 x_cbc_enabled       => l_cbc_enabled);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Is CBC enabled '|| l_cbc_enabled);
   END IF;
END IF;

     IF  l_cbc_enabled = 'Y' THEN

          IGC_CBC_PO_GRP.CBC_HEADER_VALIDATIONS(
            p_api_version   => 1.0,
            p_init_msg_list => FND_API.G_FALSE,
            p_commit        => FND_API.G_FALSE,
            p_validation_level => FND_API.G_VALID_LEVEL_FULL,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data =>l_msg_data,
            p_document_id           => p_document_id,
            p_document_type         => p_document_type,
            p_document_sub_type     => p_document_subtype);

l_progress := '002';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'CBC call returned '|| l_return_status);
   END IF;
END IF;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          IF l_return_status = FND_API.G_RET_STS_ERROR
          THEN
                l_textline := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                        p_encoded => 'F');

                IF l_textline = NULL THEN
                    l_textline :=  FND_MESSAGE.GET_STRING('IGC',
                                          'IGC_MULT_FISCAL_YEARS');
                END IF;
                --Deleting msg so that we can always use G_Last to get the
                --message we want
                FND_MSG_PUB.Delete_Msg(p_msg_index => FND_MSG_PUB.G_LAST);
l_progress := '003';
                INSERT INTO PO_ONLINE_REPORT_TEXT_GT (online_report_id,
                        last_update_login,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                line_num,
                shipment_num,
                distribution_num,
                sequence,
                text_line,
                        message_name)
                VALUES (p_online_report_id,
                    p_login_id,
                    p_user_id,
                      sysdate,
                    p_user_id,
                    sysdate,
                    0,
                    0,
                    0,
                    p_sequence + 1,
                    substr(l_textline,1,240),
                        'IGC_MULT_FISCAL_YEARS');

                p_sequence := p_sequence + 1;
          END IF; --expected error

    END IF; --cbc is enabled

l_progress := '004';
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END DO_CBC_RELATED_VALIDATIONS;




-------------------------------------------------------------------------------
--Start of Comments
--Name: populate_global_temp_tables
--Pre-reqs:
--  None.
--Modifies:
--  See the called procedures.
--Locks:
--  None.
--Function:
--  Populates the global temp tables for submission checks.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of id that is being passed.  Use g_doc_level_<>
--  The following is supported for all actions:
--    HEADER
--  The following are also supported for UNRESERVE checks (PO/RELEASE):
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--  The following are also supported for FINAL_CLOSE checks (PO/RELEASE):
--    LINE
--    SHIPMENT
--p_doc_level_id
--  Id of the doc level type of which to populate the tables.
--OUT:
--x_return_status
--  APPS standard parameter.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE populate_global_temp_tables(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
)
IS

l_api_name  CONSTANT varchar2(40) := 'POPULATE_GLOBAL_TEMP_TABLES';
l_log_head CONSTANT VARCHAR2(100) := g_log_head||l_api_name;
l_progress VARCHAR2(3);

l_blanket_header_id po_headers.po_header_id%TYPE;
l_return_status VARCHAR2(1);

l_doc_id    NUMBER;

l_id_tbl    po_tbl_number;

BEGIN
l_progress := '000';

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
END IF;

l_progress := '500';

-- bug3413891
-- Clean up gt tables to make sure that all the records in GT tables are from
-- the same document

DELETE FROM po_headers_gt;
DELETE FROM po_lines_gt;
DELETE FROM po_line_locations_gt;
DELETE FROM po_distributions_gt;
DELETE FROM po_releases_gt;
DELETE FROM po_req_headers_gt;
DELETE FROM po_req_lines_gt;
DELETE FROM po_req_distributions_gt;
DELETE FROM po_online_report_text_gt;


PO_CORE_S.get_document_ids(
   p_doc_type => p_doc_type
,  p_doc_level => p_doc_level
,  p_doc_level_id_tbl => po_tbl_number( p_doc_level_id )
,  x_doc_id_tbl => l_id_tbl
);

l_progress := '510';

l_doc_id := l_id_tbl(1);


    IF p_doc_type = 'REQUISITION' THEN

l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Populating from REQS');
   END IF;
END IF;

        --populate the global REQ headers table
        populate_req_headers_gt(l_doc_id, l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

l_progress := '002';
        --populate the global REQ line table
        populate_req_lines_gt(l_doc_id, l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    ELSIF p_doc_type in ('PO', 'PA') THEN
l_progress := '004';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Populating from PO tables for PO/PA');
   END IF;
END IF;

        --populate the global headers table
        populate_po_headers_gt(l_doc_id, l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

l_progress := '005';

        --populate the global line table
        -- <Doc Manager Rewrite 11.5.11>
        -- Change populate logic for po_lines_gt to handle document levels

        populate_po_lines_gt(
           p_doc_type => p_doc_type
        ,  p_doc_level => p_doc_level
        ,  p_doc_level_id => p_doc_level_id
        ,  x_return_status => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    ELSIF p_doc_type = 'RELEASE' THEN
l_progress := '008';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Populating RELEASES');
   END IF;
END IF;

        --populate the global release table
        populate_releases_gt(l_doc_id, l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

l_progress := '009';
        -- Get the header_id of the relevent Blanket
        SELECT po_header_id
        INTO l_blanket_header_id
        FROM po_releases_gt
        WHERE po_release_id = l_doc_id;

l_progress := '010';
        --populate the global headers table with header of blanket/planned PO
        --for which this is a Release
        populate_po_headers_gt(l_blanket_header_id, l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;

--<FPJ ENCUMBRANCE>

l_progress := '100';

IF (p_doc_type <> g_document_type_REQUISITION) THEN

   populate_line_locations_gt(
      p_doc_type => p_doc_type
   ,  p_doc_level => p_doc_level
   ,  p_doc_level_id => p_doc_level_id
   );

END IF;

l_progress := '200';

populate_distributions_gt(
   p_doc_type => p_doc_type
,  p_doc_level => p_doc_level
,  p_doc_level_id => p_doc_level_id
);

l_progress := 300;

--LCM ER start. Populate the lcm flag in the GT tables first
IF p_doc_type in ('PO','RELEASE') THEN

	FOR ship_rec in (select line_location_id from po_line_locations_gt)
	LOOP
		set_lcm_flag(ship_rec.line_location_id,'BEFORE',l_return_status);
	END LOOP;
END IF;

--LCM ER end.
l_progress := '900';

    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END populate_global_temp_tables;

/**
* Private Procedure: UPDATE_GLOBAL_TEMP_TABLES
* Requires:
*   IN PARAMETERS:
*     p_document_type:     Type of submitted document
*     p_document_subtype:  Subtype of submitted document
*     p_document_id:       Id of submitted document
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
* Modifies:
* Effects:  Updates the global temp tables with the changes in object
*           p_requested_changes
* Returns:
*/
PROCEDURE update_global_temp_tables(p_document_type IN VARCHAR2,
                     p_document_subtype IN VARCHAR2,
                     p_document_id IN NUMBER,
                -- <PO_CHANGE_API FPJ> Renamed the type to PO_CHANGES_REC_TYPE:
                     p_requested_changes  IN PO_CHANGES_REC_TYPE,
                     x_return_status OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT varchar2(40) := 'UPDATE_GLOBAL_TEMP_TABLES';
l_progress VARCHAR2(3);

BEGIN

l_progress := '000';
    IF p_document_type = 'REQUISITION' THEN
        --right now no updates to requisitions are allowed
        return;
    END IF;

    IF p_requested_changes.line_changes IS NOT NULL THEN
l_progress := '001';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Making Line Chnages');
   END IF;
END IF;
        --Bug#15951569:: ER PO Change API:: START
		-- Sync newly added param for header update
		UPDATE po_headers_gt
        SET agent_id = Nvl(p_requested_changes.header_changes.agent_id, agent_id),
            comments = Nvl(p_requested_changes.header_changes.comments , comments ),
            fob_lookup_code = Nvl (p_requested_changes.header_changes.fob_lookup_code ,fob_lookup_code),
            terms_id = Nvl (p_requested_changes.header_changes.terms_id , terms_id ),
            attribute_category = Nvl (p_requested_changes.header_changes.attribute_category , attribute_category ),
            attribute1 = Nvl (p_requested_changes.header_changes.attribute1 , attribute1 ),
            attribute2 = Nvl (p_requested_changes.header_changes.attribute2, attribute2 ),
            attribute3 = Nvl (p_requested_changes.header_changes.attribute3, attribute3 ),
            attribute4 = Nvl (p_requested_changes.header_changes.attribute4 , attribute4 ),
            attribute5 = Nvl (p_requested_changes.header_changes.attribute5 , attribute5 ),
            attribute6 = Nvl (p_requested_changes.header_changes.attribute6 , attribute6 ),
            attribute7 = Nvl (p_requested_changes.header_changes.attribute7 , attribute7 ),
            attribute8 = Nvl (p_requested_changes.header_changes.attribute8 , attribute8 ),
            attribute9 = Nvl (p_requested_changes.header_changes.attribute9, attribute9 ),
            attribute10 = Nvl (p_requested_changes.header_changes.attribute10 , attribute10 ),
            attribute11= Nvl (p_requested_changes.header_changes.attribute11 , attribute11 ),
            attribute12 = Nvl (p_requested_changes.header_changes.attribute12 , attribute12 ),
            attribute13 = Nvl (p_requested_changes.header_changes.attribute13 , attribute13 ),
            attribute14 = Nvl (p_requested_changes.header_changes.attribute14 , attribute14 ),
            attribute15 = Nvl (p_requested_changes.header_changes.attribute15 , attribute15 )
        WHERE po_header_id = p_requested_changes.po_header_id;
		--Bug#15951569:: ER PO Change API:: END

        -- SQL What: Updating the changeable quantities with either passed
        --           in values or if NULL then with existing values in the table
        -- SQL Why: Need to apply requested line level changes to global temp table
        -- SQL Join: po_line_id
        FORALL i IN 1..p_requested_changes.line_changes.po_line_id.COUNT
           UPDATE po_lines_gt
            SET unit_price = nvl(p_requested_changes.line_changes.unit_price(i),unit_price),
                vendor_product_num = nvl(p_requested_changes.line_changes.vendor_product_num(i),
                                            vendor_product_num),
               -- <PO_CHANGE_API FPJ START>
               -- Added several changeable fields:
               quantity = nvl(p_requested_changes.line_changes.quantity(i),
                              quantity),
               start_date = nvl(p_requested_changes.line_changes.start_date(i),
                                start_date),
               expiration_date =
                 nvl(p_requested_changes.line_changes.expiration_date(i),
                     expiration_date),
               amount = nvl(p_requested_changes.line_changes.amount(i),
                            amount)
               -- <PO_CHANGE_API FPJ END>
			   --Bug#15951569:: ER PO Change API:: START
			   ,item_description = NVL(p_requested_changes.line_changes.item_desc(i),item_description)
			   ,unit_meas_lookup_code = NVL(p_requested_changes.line_changes.request_unit_of_measure(i),unit_meas_lookup_code)
	           ,line_type_id = nvl(p_requested_changes.line_changes.line_type_id(i),line_type_id)
			   ,category_id = Nvl(p_requested_changes.line_changes.item_category_id(i),category_id ),
			   attribute_category = Nvl (p_requested_changes.line_changes.attribute_category(i) , attribute_category ),
               attribute1 = Nvl (p_requested_changes.line_changes.attribute1(i) , attribute1 ),
               attribute2 = Nvl (p_requested_changes.line_changes.attribute2(i) , attribute2 ),
               attribute3 = Nvl (p_requested_changes.line_changes.attribute3(i) , attribute3 ),
               attribute4 = Nvl (p_requested_changes.line_changes.attribute4(i) , attribute4 ),
               attribute5 = Nvl (p_requested_changes.line_changes.attribute5(i) , attribute5 ),
               attribute6 = Nvl (p_requested_changes.line_changes.attribute6(i) , attribute6 ),
               attribute7 = Nvl (p_requested_changes.line_changes.attribute7(i) , attribute7 ),
               attribute8 = Nvl (p_requested_changes.line_changes.attribute8(i) , attribute8 ),
               attribute9 = Nvl (p_requested_changes.line_changes.attribute9(i) , attribute9 ),
               attribute10 = Nvl (p_requested_changes.line_changes.attribute10(i) , attribute10 ),
               attribute11 = Nvl (p_requested_changes.line_changes.attribute11(i) , attribute11 ),
               attribute12 = Nvl (p_requested_changes.line_changes.attribute12(i) , attribute12 ),
               attribute13 = Nvl (p_requested_changes.line_changes.attribute13(i) , attribute13 ),
               attribute14 = Nvl (p_requested_changes.line_changes.attribute14(i) , attribute14 ),
               attribute15 = Nvl (p_requested_changes.line_changes.attribute15(i) , attribute15 )
			   --Bug#15951569:: ER PO Change API:: END
             WHERE po_line_id = p_requested_changes.line_changes.po_line_id(i);

        --To propogate line price change to shipment level for Standard PO
        IF (p_document_type = 'PO' AND p_document_subtype = 'STANDARD') THEN

l_progress := '002';
            -- SQL What: Setting the priceoverride at Shipment level
            -- SQL Why: Need to propogate line price change to shipment level
            --          for Standard PO
            -- SQL Join: po_line_id
            FORALL i IN 1..p_requested_changes.line_changes.po_line_id.COUNT
                UPDATE po_line_locations_gt
                 SET price_override = nvl(p_requested_changes.line_changes.unit_price(i),price_override)
                 WHERE po_line_id = p_requested_changes.line_changes.po_line_id(i)
                 AND nvl(payment_type, 'NULL') NOT IN ('MILESTONE', 'ADVANCE')
                 -- <Complex Work R12>: do not carry line price down in Qty Milestone case
                 ;

			--Bug#15951569:: ER PO Change API:: START
            -- SYNC UOM Update at line level to shipment
			FORALL i IN 1..p_requested_changes.line_changes.get_count
	           UPDATE po_line_locations_gt
               SET unit_meas_lookup_code = NVL(p_requested_changes.line_changes.request_unit_of_measure(i), unit_meas_lookup_code)
               WHERE po_line_id = p_requested_changes.line_changes.po_line_id(i)
               AND shipment_type = 'STANDARD'
               AND NVL(cancel_flag,'N') <> 'Y'
               AND NVL(closed_code,'OPEN') <> 'FINALLY CLOSED';
             --Bug#15951569:: ER PO Change API:: END

        END IF;
    END IF;

    IF p_requested_changes.shipment_changes IS NOT NULL THEN
l_progress := '003';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Making Shipment chanbges');
   END IF;
END IF;
        -- SQL What: Updating the changeable quantities with either passed
        --           in values or if NULL then with existing values in the table
        -- SQL Why: Need to apply requested line level changes to global temp table
        -- SQL Join: po_line_location_id
        FORALL i IN 1..p_requested_changes.shipment_changes.po_line_location_id.COUNT
           UPDATE po_line_locations_gt
            SET quantity = nvl(p_requested_changes.shipment_changes.quantity(i),quantity),
                promised_date = nvl(p_requested_changes.shipment_changes.promised_date(i),
                                            promised_date),
                price_override = nvl(p_requested_changes.shipment_changes.price_override(i),
                                            price_override),
                -- <PO_CHANGE_API FPJ START>
                -- Added several changeable fields:
                need_by_date =
                  nvl(p_requested_changes.shipment_changes.need_by_date(i),
                      need_by_date),
                ship_to_location_id =
                  nvl(p_requested_changes.shipment_changes.ship_to_location_id(i),
                      ship_to_location_id),
                amount = nvl(p_requested_changes.shipment_changes.amount(i),
                             amount),
                -- <PO_CHANGE_API FPJ END>
                -- <Complex Work R12 START>
                payment_type = nvl(p_requested_changes.shipment_changes.payment_type(i),
                                   payment_type),
                description = nvl(p_requested_changes.shipment_changes.description(i),
                                  description),
                value_basis = DECODE(p_requested_changes.shipment_changes.payment_type(i)
                                     , NULL, value_basis
                                     , 'RATE', 'QUANTITY'
                                     , 'LUMPSUM', 'FIXED PRICE'
                                     , 'MILESTONE', 'FIXED PRICE'
                              )
                -- Note: the value basis decode assumes Milestone Pay Items are Amount
                -- Milestones, since payment type is not changeable on Qty-based lines
                -- <Complex Work R12 END>
				--Bug#15951569:: ER PO Change API:: START
				,unit_meas_lookup_code = NVL(p_requested_changes.shipment_changes.request_unit_of_measure(i),unit_meas_lookup_code)
	            ,qty_rcv_tolerance = Nvl (p_requested_changes.shipment_changes.qty_rcv_tolerance(i),qty_rcv_tolerance),
                attribute_category = Nvl (p_requested_changes.shipment_changes.attribute_category(i) , attribute_category ),
                attribute1 = Nvl (p_requested_changes.shipment_changes.attribute1(i) , attribute1 ),
                attribute2 = Nvl (p_requested_changes.shipment_changes.attribute2(i) , attribute2 ),
                attribute3 = Nvl (p_requested_changes.shipment_changes.attribute3(i) , attribute3 ),
                attribute4 = Nvl (p_requested_changes.shipment_changes.attribute4(i) , attribute4 ),
                attribute5 = Nvl (p_requested_changes.shipment_changes.attribute5(i) , attribute5 ),
                attribute6 = Nvl (p_requested_changes.shipment_changes.attribute6(i) , attribute6 ),
                attribute7 = Nvl (p_requested_changes.shipment_changes.attribute7(i) , attribute7 ),
                attribute8 = Nvl (p_requested_changes.shipment_changes.attribute8(i) , attribute8 ),
                attribute9 = Nvl (p_requested_changes.shipment_changes.attribute9(i) , attribute9 ),
                attribute10 = Nvl(p_requested_changes.shipment_changes.attribute10(i) , attribute10 ),
                attribute11= Nvl (p_requested_changes.shipment_changes.attribute11(i) , attribute11 ),
                attribute12 = Nvl(p_requested_changes.shipment_changes.attribute12(i) , attribute12 ),
                attribute13 = Nvl(p_requested_changes.shipment_changes.attribute13(i) , attribute13 ),
                attribute14 = Nvl(p_requested_changes.shipment_changes.attribute14(i) , attribute14 ),
                attribute15 = Nvl(p_requested_changes.shipment_changes.attribute15(i) , attribute15 )
				--Bug#15951569:: ER PO Change API:: END
            WHERE line_location_id = p_requested_changes.shipment_changes.po_line_location_id(i)
            AND   p_requested_changes.shipment_changes.parent_line_location_id(i) IS NULL;

l_progress := '004';

        --<case of split shipment>
        FORALL i IN 1..p_requested_changes.shipment_changes.po_line_location_id.COUNT
            INSERT INTO po_line_locations_gt(
                 LINE_LOCATION_ID     ,
                 LAST_UPDATE_DATE      ,
                 LAST_UPDATED_BY        ,
                 PO_HEADER_ID            ,
                 PO_LINE_ID               ,
                 LAST_UPDATE_LOGIN         ,
                 CREATION_DATE              ,
                 CREATED_BY                  ,
                 QUANTITY                     ,
                 QUANTITY_RECEIVED             ,
                 QUANTITY_ACCEPTED              ,
                 QUANTITY_REJECTED               ,
                 QUANTITY_BILLED                  ,
                 QUANTITY_CANCELLED                ,
                 UNIT_MEAS_LOOKUP_CODE              ,
                 PO_RELEASE_ID                       ,
                 SHIP_TO_LOCATION_ID                  ,
                 SHIP_VIA_LOOKUP_CODE                  ,
                 NEED_BY_DATE                           ,
                 PROMISED_DATE                           ,
                 LAST_ACCEPT_DATE                         ,
                 PRICE_OVERRIDE                          ,
                 ENCUMBERED_FLAG                        ,
                 ENCUMBERED_DATE                         ,
                 UNENCUMBERED_QUANTITY                    ,
                 FOB_LOOKUP_CODE                         ,
                 FREIGHT_TERMS_LOOKUP_CODE                ,
                 TAXABLE_FLAG                            ,
                 ESTIMATED_TAX_AMOUNT                    ,
                 FROM_HEADER_ID                          ,
                 FROM_LINE_ID                             ,
                 FROM_LINE_LOCATION_ID                   ,
                 START_DATE                               ,
                 END_DATE                                ,
                 LEAD_TIME                              ,
                 LEAD_TIME_UNIT                          ,
                 PRICE_DISCOUNT                           ,
                 TERMS_ID                                 ,
                 APPROVED_FLAG                            ,
                 APPROVED_DATE                            ,
                 CLOSED_FLAG                              ,
                 CANCEL_FLAG                              ,
                 CANCELLED_BY                             ,
                 CANCEL_DATE                              ,
                 CANCEL_REASON                            ,
                 FIRM_STATUS_LOOKUP_CODE                  ,
                 FIRM_DATE                                ,
                 ATTRIBUTE_CATEGORY                       ,
                 ATTRIBUTE1                               ,
                 ATTRIBUTE2                               ,
                 ATTRIBUTE3                               ,
                 ATTRIBUTE4                               ,
                 ATTRIBUTE5                               ,
                 ATTRIBUTE6                               ,
                 ATTRIBUTE7                               ,
                 ATTRIBUTE8                               ,
                 ATTRIBUTE9                               ,
                 ATTRIBUTE10                              ,
                 UNIT_OF_MEASURE_CLASS                    ,
                 ENCUMBER_NOW                             ,
                 ATTRIBUTE11                              ,
                 ATTRIBUTE12                              ,
                 ATTRIBUTE13                              ,
                 ATTRIBUTE14                              ,
                 ATTRIBUTE15                              ,
                 INSPECTION_REQUIRED_FLAG                 ,
                 RECEIPT_REQUIRED_FLAG                    ,
                 QTY_RCV_TOLERANCE                       ,
                 QTY_RCV_EXCEPTION_CODE                   ,
                 ENFORCE_SHIP_TO_LOCATION_CODE            ,
                 ALLOW_SUBSTITUTE_RECEIPTS_FLAG           ,
                 DAYS_EARLY_RECEIPT_ALLOWED               ,
                 DAYS_LATE_RECEIPT_ALLOWED                ,
                 RECEIPT_DAYS_EXCEPTION_CODE             ,
                 INVOICE_CLOSE_TOLERANCE                  ,
                 RECEIVE_CLOSE_TOLERANCE                  ,
                 SHIP_TO_ORGANIZATION_ID                 ,
                 SHIPMENT_NUM                            ,
                 SOURCE_SHIPMENT_ID                      ,
                 SHIPMENT_TYPE                     ,
                 CLOSED_CODE                        ,
                 REQUEST_ID                          ,
                 PROGRAM_APPLICATION_ID               ,
                 PROGRAM_ID                            ,
                 PROGRAM_UPDATE_DATE                    ,
                 GOVERNMENT_CONTEXT                      ,
                 RECEIVING_ROUTING_ID                     ,
                 ACCRUE_ON_RECEIPT_FLAG                  ,
                 CLOSED_REASON                           ,
                 CLOSED_DATE                              ,
                 CLOSED_BY                               ,
                 ORG_ID                                  ,
                 GLOBAL_ATTRIBUTE1                        ,
                 GLOBAL_ATTRIBUTE2                        ,
                 GLOBAL_ATTRIBUTE3                        ,
                 GLOBAL_ATTRIBUTE4                        ,
                 GLOBAL_ATTRIBUTE5                        ,
                 GLOBAL_ATTRIBUTE6                        ,
                 GLOBAL_ATTRIBUTE7                        ,
                 GLOBAL_ATTRIBUTE8                        ,
                 GLOBAL_ATTRIBUTE9                        ,
                 GLOBAL_ATTRIBUTE10                       ,
                 GLOBAL_ATTRIBUTE11                       ,
                 GLOBAL_ATTRIBUTE12                       ,
                 GLOBAL_ATTRIBUTE13                       ,
                 GLOBAL_ATTRIBUTE14                       ,
                 GLOBAL_ATTRIBUTE15                       ,
                 GLOBAL_ATTRIBUTE16                       ,
                 GLOBAL_ATTRIBUTE17                       ,
                 GLOBAL_ATTRIBUTE18                       ,
                 GLOBAL_ATTRIBUTE19                       ,
                 GLOBAL_ATTRIBUTE20                       ,
                 GLOBAL_ATTRIBUTE_CATEGORY                ,
                 QUANTITY_SHIPPED                        ,
                 COUNTRY_OF_ORIGIN_CODE                   ,
                 TAX_USER_OVERRIDE_FLAG                  ,
                 MATCH_OPTION                            ,
                 TAX_CODE_ID                              ,
                 CALCULATE_TAX_FLAG                      ,
                 CHANGE_PROMISED_DATE_REASON            ,
                 NOTE_TO_RECEIVER                        ,
                 SECONDARY_QUANTITY                      ,
                 SECONDARY_UNIT_OF_MEASURE               ,
                 PREFERRED_GRADE                         ,
                 SECONDARY_QUANTITY_RECEIVED             ,
                 SECONDARY_QUANTITY_ACCEPTED              ,
                 SECONDARY_QUANTITY_REJECTED             ,
                 SECONDARY_QUANTITY_CANCELLED             ,
                 VMI_FLAG                                 ,
                 CONSIGNED_FLAG                           ,
                 RETROACTIVE_DATE                         ,
                 AMOUNT                                   , -- <PO_CHANGE_API FPJ>
                 DESCRIPTION                              , --<Complex Work R12>
                 PAYMENT_TYPE                             , --<Complex Work R12>
                 VALUE_BASIS                                --<Complex Work R12>
             )
             SELECT
                 -- bug3611217
                 -- Use a sequence number rather than FND_API.G_MISS_NUM
                 -- since we have added unique constraint on LINE_LOCATION_ID
                 PO_LINE_LOCATIONS_S.nextval,
                 poll.LAST_UPDATE_DATE      ,
                 poll.LAST_UPDATED_BY        ,
                 poll.PO_HEADER_ID            ,
                 poll.PO_LINE_ID               ,
                 poll.LAST_UPDATE_LOGIN         ,
                 poll.CREATION_DATE              ,
                 poll.CREATED_BY                  ,
                 nvl(p_requested_changes.shipment_changes.quantity(i),poll.quantity),
                 -- Bug 3322019 START
                 -- Quantity received, accepted, cancelled, etc. should be
                 -- NULL or 0 on the split shipment.
                 decode(poll.quantity_received,NULL,NULL,0),
                 decode(poll.quantity_accepted,NULL,NULL,0),
                 decode(poll.quantity_rejected,NULL,NULL,0),
                 decode(poll.quantity_billed,NULL,NULL,0),
                 decode(poll.quantity_cancelled,NULL,NULL,0),
                 -- Bug 3322019 END
                 NVL(p_requested_changes.shipment_changes.request_unit_of_measure(i),poll.UNIT_MEAS_LOOKUP_CODE), --Bug#15951569:: ER PO Change API
                 poll.PO_RELEASE_ID                       ,
                 -- <PO_CHANGE_API FPJ> Added as a changeable field:
                 nvl(p_requested_changes.shipment_changes.ship_to_location_id(i),
                     poll.ship_to_location_id),
                 poll.SHIP_VIA_LOOKUP_CODE                  ,
                 -- <PO_CHANGE_API FPJ> Added as a changeable field:
                 nvl(p_requested_changes.shipment_changes.need_by_date(i),
                     poll.need_by_date),
                 nvl(p_requested_changes.shipment_changes.promised_date(i),
                                            poll.promised_date),
                 poll.LAST_ACCEPT_DATE                         ,
                 nvl(p_requested_changes.shipment_changes.price_override(i),
                                            poll.price_override),
                 -- Bug 3322019 START
                 NULL, -- ENCUMBERED_FLAG
                 NULL, -- ENCUMBERED_DATE
                 NULL, -- UNENCUMBERED_QUANTITY
                 -- Bug 3322019 END
                 poll.FOB_LOOKUP_CODE                         ,
                 poll.FREIGHT_TERMS_LOOKUP_CODE                ,
                 poll.TAXABLE_FLAG                            ,
                 0, -- ESTIMATED_TAX_AMOUNT (Bug 3322019)
                 poll.FROM_HEADER_ID                          ,
                 poll.FROM_LINE_ID                             ,
                 poll.FROM_LINE_LOCATION_ID                   ,
                 poll.START_DATE                               ,
                 poll.END_DATE                                ,
                 poll.LEAD_TIME                              ,
                 poll.LEAD_TIME_UNIT                          ,
                 poll.PRICE_DISCOUNT                           ,
                 poll.TERMS_ID                                 ,
                 -- Bug 3322019 START
                 'N', -- APPROVED_FLAG
                 NULL, -- APPROVED_DATE
                 NULL, -- CLOSED_FLAG
                 'N', -- CANCEL_FLAG
                 NULL, -- CANCELLED_BY
                 NULL, -- CANCEL_DATE
                 NULL, -- CANCEL_REASON
                 -- Bug 3322019 END
                 poll.FIRM_STATUS_LOOKUP_CODE                  ,
                 poll.FIRM_DATE                                ,
                 --Bug#15951569:: ER PO Change API:: START
                 Nvl (p_requested_changes.shipment_changes.attribute_category(i)  , poll.attribute_category ),
                 Nvl (p_requested_changes.shipment_changes.attribute1(i)  , poll.attribute1 ),
                 Nvl (p_requested_changes.shipment_changes.attribute2(i)  , poll.attribute2 ),
                 Nvl (p_requested_changes.shipment_changes.attribute3(i)  , poll.attribute3 ),
                 Nvl (p_requested_changes.shipment_changes.attribute4(i)  , poll.attribute4 ),
                 Nvl (p_requested_changes.shipment_changes.attribute5(i)  , poll.attribute5 ),
                 Nvl (p_requested_changes.shipment_changes.attribute6(i)  , poll.attribute6 ),
                 Nvl (p_requested_changes.shipment_changes.attribute7(i)  , poll.attribute7 ),
                 Nvl (p_requested_changes.shipment_changes.attribute8(i)  , poll.attribute8 ),
                 Nvl (p_requested_changes.shipment_changes.attribute9(i) , poll.attribute9 ),
                 Nvl (p_requested_changes.shipment_changes.attribute10(i) , poll.attribute10 ),
                 poll.UNIT_OF_MEASURE_CLASS                    ,
                 poll.ENCUMBER_NOW                             ,
                 Nvl (p_requested_changes.shipment_changes.attribute11(i) , poll.attribute11 ),
                 Nvl (p_requested_changes.shipment_changes.attribute12(i) , poll.attribute12 ),
                 Nvl (p_requested_changes.shipment_changes.attribute13(i) , poll.attribute13 ),
                 Nvl (p_requested_changes.shipment_changes.attribute14(i) , poll.attribute14 ),
                 Nvl (p_requested_changes.shipment_changes.attribute15(i) , poll.attribute15 ),
				 --Bug#15951569:: ER PO Change API:: END
                 poll.INSPECTION_REQUIRED_FLAG                 ,
                 poll.RECEIPT_REQUIRED_FLAG                    ,
                 Nvl (p_requested_changes.shipment_changes.qty_rcv_tolerance(i),poll.QTY_RCV_TOLERANCE), --Bug#15951569:: ER PO Change API
                 poll.QTY_RCV_EXCEPTION_CODE                   ,
                 poll.ENFORCE_SHIP_TO_LOCATION_CODE            ,
                 poll.ALLOW_SUBSTITUTE_RECEIPTS_FLAG           ,
                 poll.DAYS_EARLY_RECEIPT_ALLOWED               ,
                 poll.DAYS_LATE_RECEIPT_ALLOWED                ,
                 poll.RECEIPT_DAYS_EXCEPTION_CODE             ,
                 poll.INVOICE_CLOSE_TOLERANCE                  ,
                 poll.RECEIVE_CLOSE_TOLERANCE                  ,
                 poll.SHIP_TO_ORGANIZATION_ID                 ,

                 --<Bug 2798040 mbhargav START>
                 --iSP is passing shipment_num now
                 nvl(p_requested_changes.shipment_changes.split_shipment_num(i),
                                            FND_API.G_MISS_NUM),
                 --SHIPMENT_NUM                            ,
                 --<Bug 2798040 mbhargav START>

                 poll.SOURCE_SHIPMENT_ID                      ,
                 poll.SHIPMENT_TYPE                     ,
                 -- Bug 3322019 START
                 'OPEN', -- CLOSED_CODE
                 NULL, -- REQUEST_ID
                 NULL, -- PROGRAM_APPLICATION_ID
                 NULL, -- PROGRAM_ID
                 NULL, -- PROGRAM_UPDATE_DATE
                 -- Bug 3322019 START
                 poll.GOVERNMENT_CONTEXT                      ,
                 poll.RECEIVING_ROUTING_ID                     ,
                 poll.ACCRUE_ON_RECEIPT_FLAG                  ,
                 -- Bug 3322019 START
                 NULL, -- CLOSED_REASON
                 NULL, -- CLOSED_DATE
                 NULL, -- CLOSED_BY
                 -- Bug 3322019 END
                 poll.ORG_ID                                  ,
                 poll.GLOBAL_ATTRIBUTE1                        ,
                 poll.GLOBAL_ATTRIBUTE2                        ,
                 poll.GLOBAL_ATTRIBUTE3                        ,
                 poll.GLOBAL_ATTRIBUTE4                        ,
                 poll.GLOBAL_ATTRIBUTE5                        ,
                 poll.GLOBAL_ATTRIBUTE6                        ,
                 poll.GLOBAL_ATTRIBUTE7                        ,
                 poll.GLOBAL_ATTRIBUTE8                        ,
                 poll.GLOBAL_ATTRIBUTE9                        ,
                 poll.GLOBAL_ATTRIBUTE10                       ,
                 poll.GLOBAL_ATTRIBUTE11                       ,
                 poll.GLOBAL_ATTRIBUTE12                       ,
                 poll.GLOBAL_ATTRIBUTE13                       ,
                 poll.GLOBAL_ATTRIBUTE14                       ,
                 poll.GLOBAL_ATTRIBUTE15                       ,
                 poll.GLOBAL_ATTRIBUTE16                       ,
                 poll.GLOBAL_ATTRIBUTE17                       ,
                 poll.GLOBAL_ATTRIBUTE18                       ,
                 poll.GLOBAL_ATTRIBUTE19                       ,
                 poll.GLOBAL_ATTRIBUTE20                       ,
                 poll.GLOBAL_ATTRIBUTE_CATEGORY                ,
                 decode(poll.quantity_shipped,NULL,NULL,0), -- Bug 3322019
                 poll.COUNTRY_OF_ORIGIN_CODE                   ,
                 poll.TAX_USER_OVERRIDE_FLAG                  ,
                 poll.MATCH_OPTION                            ,
                 poll.TAX_CODE_ID                              ,
                 poll.CALCULATE_TAX_FLAG                      ,
                 poll.CHANGE_PROMISED_DATE_REASON            ,
                 poll.NOTE_TO_RECEIVER                        ,
                 decode(poll.secondary_quantity,NULL,NULL,0), -- Bug 3322019
                 poll.SECONDARY_UNIT_OF_MEASURE               ,
                 poll.PREFERRED_GRADE                         ,
                 -- Bug 3322019 START
                 decode(poll.secondary_quantity_received,NULL,NULL,0),
                 decode(poll.secondary_quantity_accepted,NULL,NULL,0),
                 decode(poll.secondary_quantity_rejected,NULL,NULL,0),
                 decode(poll.secondary_quantity_cancelled,NULL,NULL,0),
                 -- Bug 3322019 END
                 poll.VMI_FLAG                                 ,
                 poll.CONSIGNED_FLAG                           ,
                 poll.RETROACTIVE_DATE                         ,
                 -- <PO_CHANGE_API FPJ START> Added a changeable field:
                 NVL(p_requested_changes.shipment_changes.amount(i), poll.amount),
                 -- <PO_CHANGE_API FPJ END>
                 --<Complex Work R12 START>
                 poll.DESCRIPTION,
                 poll.PAYMENT_TYPE,
                 DECODE(p_requested_changes.shipment_changes.payment_type(i)
                       , 'RATE', 'QUANTITY'
                       , 'LUMPSUM', 'FIXED PRICE'
                       , POL.order_type_lookup_code
                 )
                -- Note: the value basis decode assumes Milestone Pay Items are Amount
                -- Milestones, since payment type is not changeable on Qty-based lines
                 --<Complex Work R12 END>
              FROM po_line_locations poll
                 , po_lines_all pol --<Complex Work R12>
              WHERE poll.line_location_id =
                    p_requested_changes.shipment_changes.parent_line_location_id(i)
              AND   p_requested_changes.shipment_changes.po_line_location_id(i) IS NULL
              AND   poll.po_line_id = pol.po_line_id;  --<Complex Work R12>

    END IF;

    IF p_requested_changes.distribution_changes IS NOT NULL THEN
l_progress := '005';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Making Distribution changes');
   END IF;
END IF;
        -- SQL What: Updating the changeable quantities with either passed
        --           in values or if NULL then with existing values in the table
        -- SQL Why: Need to apply requested line level changes to global temp table
        -- SQL Join: po_line_id
        FORALL i IN 1..p_requested_changes.distribution_changes.po_distribution_id.COUNT
           UPDATE po_distributions_gt
            SET quantity_ordered = nvl(p_requested_changes.distribution_changes.quantity_ordered(i),
                                        quantity_ordered),
                -- <PO_CHANGE_API FPJ START>
                -- Added amount_ordered as a changeable field:
                amount_ordered =
                  nvl(p_requested_changes.distribution_changes.amount_ordered(i),
                      amount_ordered)
                -- <PO_CHANGE_API FPJ END>
				--Bug#15951569:: ER PO Change API:: START
		       ,deliver_to_location_id =
  		        nvl(p_requested_changes.distribution_changes.deliver_to_loc_id(i), deliver_to_location_id)
		       ,project_id =
  		          nvl(p_requested_changes.distribution_changes.project_id(i), project_id)
		       ,task_id =
  		        nvl(p_requested_changes.distribution_changes.task_id(i), task_id)
		       ,expenditure_type =
  		         nvl(p_requested_changes.distribution_changes.expenditure_type(i), expenditure_type)
		       ,expenditure_organization_id =
  		         nvl(p_requested_changes.distribution_changes.expenditure_org_id(i), expenditure_organization_id)
		       ,project_accounting_context =
  		        nvl(p_requested_changes.distribution_changes.project_accnt_context(i), project_accounting_context)
		       ,expenditure_item_date =
  		           nvl(p_requested_changes.distribution_changes.expenditure_date(i), expenditure_item_date)
		       ,attribute_category = Nvl (p_requested_changes.distribution_changes.attribute_category(i) , attribute_category ),
                attribute1 = Nvl (p_requested_changes.distribution_changes.attribute1(i) , attribute1 ),
                attribute2 = Nvl (p_requested_changes.distribution_changes.attribute2(i) , attribute2 ),
                attribute3 = Nvl (p_requested_changes.distribution_changes.attribute3(i) , attribute3 ),
                attribute4 = Nvl (p_requested_changes.distribution_changes.attribute4(i) , attribute4 ),
                attribute5 = Nvl (p_requested_changes.distribution_changes.attribute5(i) , attribute5 ),
                attribute6 = Nvl (p_requested_changes.distribution_changes.attribute6(i) , attribute6 ),
                attribute7 = Nvl (p_requested_changes.distribution_changes.attribute7(i) , attribute7 ),
                attribute8 = Nvl (p_requested_changes.distribution_changes.attribute8(i) , attribute8 ),
                attribute9 = Nvl (p_requested_changes.distribution_changes.attribute9(i) , attribute9 ),
                attribute10 = Nvl (p_requested_changes.distribution_changes.attribute10(i) , attribute10 ),
                attribute11= Nvl (p_requested_changes.distribution_changes.attribute11(i) , attribute11 ),
                attribute12 = Nvl (p_requested_changes.distribution_changes.attribute12(i) , attribute12 ),
                attribute13 = Nvl (p_requested_changes.distribution_changes.attribute13(i) , attribute13 ),
                attribute14 = Nvl (p_requested_changes.distribution_changes.attribute14(i) , attribute14 ),
                attribute15 = Nvl (p_requested_changes.distribution_changes.attribute15(i) , attribute15 )
				--Bug#15951569:: ER PO Change API:: END
            WHERE po_distribution_id = p_requested_changes.distribution_changes.po_distribution_id(i);


			--Bug#15951569:: ER PO Change API:: START
			-- Handle Distribution Split
			FOR i IN 1..p_requested_changes.distribution_changes.get_count LOOP

            IF (p_requested_changes.distribution_changes.parent_distribution_id(i) IS NOT NULL AND
	            p_requested_changes.distribution_changes.po_distribution_id(i) IS NULL AND
	            p_requested_changes.distribution_changes.split_shipment_num(i) IS NULL) THEN

					INSERT INTO PO_DISTRIBUTIONS_GT
					   (
							 po_distribution_id,
							 last_update_date,
							 last_updated_by,
							 po_header_id,
							 po_line_id,
							 line_location_id,
							 set_of_books_id,
							 code_combination_id,
							 quantity_ordered,
							 amount_ordered,
							 last_update_login,
							 creation_date,
							 created_by,
							 po_release_id,
							 quantity_delivered,
							 quantity_billed,
							 quantity_cancelled,
							 amount_delivered,
							 amount_billed,
							 amount_cancelled,
							 req_header_reference_num,
							 req_line_reference_num,
							 req_distribution_id,
							 deliver_to_location_id,
							 deliver_to_person_id,
							 rate_date,
							 rate,
							 accrued_flag,
							 encumbered_flag,
							 encumbered_amount,
							 unencumbered_quantity,
							 unencumbered_amount,
							 failed_funds_lookup_code,
							 gl_encumbered_date,
							 gl_encumbered_period_name,
							 gl_cancelled_date,
							 destination_type_code,
							 destination_organization_id,
							 destination_subinventory,
							 attribute_category,
							 attribute1,
							 attribute2,
							 attribute3,
							 attribute4,
							 attribute5,
							 attribute6,
							 attribute7,
							 attribute8,
							 attribute9,
							 attribute10,
							 attribute11,
							 attribute12,
							 attribute13,
							 attribute14,
							 attribute15,
							 wip_entity_id,
							 wip_operation_seq_num,
							 wip_resource_seq_num,
							 wip_repetitive_schedule_id,
							 wip_line_id,
							 bom_resource_id,
							 budget_account_id,
							 accrual_account_id,
							 variance_account_id,
							 prevent_encumbrance_flag,
							 government_context,
							 destination_context,
							 distribution_num,
							 source_distribution_id,
							 request_id,
							 program_application_id,
							 program_id,
							 program_update_date,
							 project_id,
							 task_id,
							 expenditure_type,
							 project_accounting_context,
							 expenditure_organization_id,
							 gl_closed_date,
							 accrue_on_receipt_flag,
							 expenditure_item_date,
							 org_id,
							 kanban_card_id,
							 award_id,
							 mrc_rate_date,
							 mrc_rate,
							 mrc_encumbered_amount,
							 mrc_unencumbered_amount,
							 end_item_unit_number,
							 tax_recovery_override_flag,
							 recoverable_tax,
							 nonrecoverable_tax,
							 recovery_rate,
							 oke_contract_line_id,
							 oke_contract_deliverable_id,
						     distribution_type,
						     amount_to_encumber,
							 global_attribute_category ,
							 global_attribute1  ,
							 global_attribute2  ,
							 global_attribute3  ,
							 global_attribute4  ,
							 global_attribute5  ,
							 global_attribute6  ,
							 global_attribute7  ,
							 global_attribute8  ,
							 global_attribute9  ,
							 global_attribute10 ,
							 global_attribute11 ,
							 global_attribute12 ,
							 global_attribute13 ,
							 global_attribute14 ,
							 global_attribute15 ,
							 global_attribute16 ,
							 global_attribute17 ,
							 global_attribute18 ,
							 global_attribute19 ,
							 global_attribute20
					   )
					   SELECT
							 PO_DISTRIBUTIONS_S.nextval    ,
							 last_update_date       ,
							 last_updated_by         ,
							 po_header_id             ,
							 po_line_id                ,
							 line_location_id           ,
							 set_of_books_id            ,
							 code_combination_id         ,
							 p_requested_changes.distribution_changes.quantity_ordered(i)             ,
							 p_requested_changes.distribution_changes.amount_ordered(i),
							 last_update_login             ,
							 creation_date                  ,
							 created_by                      ,
							 po_release_id                    ,
							 decode(quantity_delivered, null, null, 0)                ,
							 decode(quantity_billed, null, null, 0)                    ,
							 decode(quantity_cancelled, null, null, 0)                  ,
							 decode(amount_delivered, null, null, 0),
							 decode(amount_billed, null, null, 0),
							 decode(amount_cancelled, null, null, 0),
							 NULL             ,
							 NULL                ,
							 NULL                    ,
							 nvl(p_requested_changes.distribution_changes.deliver_to_loc_id(i), deliver_to_location_id),
							 deliver_to_person_id                    ,
							 rate_date                               ,
							 rate                                    ,
							 accrued_flag                             ,
							 'N'                          ,
							 NULL                        ,
							 NULL                    ,
							 NULL                      ,
							 NULL                 ,
							 gl_encumbered_date                       ,
							 gl_encumbered_period_name                ,
							 NULL                        ,
							 destination_type_code                    ,
							 destination_organization_id              ,
							 destination_subinventory                ,
							 Nvl (p_requested_changes.distribution_changes.attribute_category(i) , attribute_category ),
							 Nvl (p_requested_changes.distribution_changes.attribute1(i) , attribute1 ),
							 Nvl (p_requested_changes.distribution_changes.attribute2(i) , attribute2 ),
							 Nvl (p_requested_changes.distribution_changes.attribute3(i) , attribute3 ),
							 Nvl (p_requested_changes.distribution_changes.attribute4(i) , attribute4 ),
							 Nvl (p_requested_changes.distribution_changes.attribute5(i) , attribute5 ),
							 Nvl (p_requested_changes.distribution_changes.attribute6(i) , attribute6 ),
							 Nvl (p_requested_changes.distribution_changes.attribute7(i) , attribute7 ),
							 Nvl (p_requested_changes.distribution_changes.attribute8(i) , attribute8 ),
							 Nvl (p_requested_changes.distribution_changes.attribute9(i) , attribute9 ),
							 Nvl (p_requested_changes.distribution_changes.attribute10(i) , attribute10 ),
							 Nvl (p_requested_changes.distribution_changes.attribute11(i) , attribute11 ),
							 Nvl (p_requested_changes.distribution_changes.attribute12(i) , attribute12 ),
							 Nvl (p_requested_changes.distribution_changes.attribute13(i) , attribute13 ),
							 Nvl (p_requested_changes.distribution_changes.attribute14(i) , attribute14 ),
							 Nvl (p_requested_changes.distribution_changes.attribute15(i) , attribute15 ),
							 wip_entity_id                            ,
							 wip_operation_seq_num                    ,
							 wip_resource_seq_num                     ,
							 wip_repetitive_schedule_id               ,
							 wip_line_id                              ,
							 bom_resource_id                          ,
							 budget_account_id                        ,
							 accrual_account_id                       ,
							 variance_account_id                      ,
							 prevent_encumbrance_flag                ,
							 government_context                      ,
							 destination_context                     ,
							 nvl(p_requested_changes.distribution_changes.split_dist_num(i),
																FND_API.G_MISS_NUM),
							 source_distribution_id             ,
							 NULL                         ,
							 NULL              ,
							 NULL                           ,
							 NULL                   ,
							 p_requested_changes.distribution_changes.project_id(i),
							 p_requested_changes.distribution_changes.task_id(i),
							 p_requested_changes.distribution_changes.expenditure_type(i),
							 project_accounting_context              ,
							 p_requested_changes.distribution_changes.expenditure_org_id(i),
							 NULL,
							 accrue_on_receipt_flag,
							 p_requested_changes.distribution_changes.end_item_unit_number(i),
							 org_id                                   ,
							 kanban_card_id                           ,
							 NULL                                ,
							 mrc_rate_date                           ,
							 mrc_rate                                 ,
							 NULL                   ,
							 NULL                  ,
							 end_item_unit_number                     ,
							 tax_recovery_override_flag               ,
							 recoverable_tax                          ,
							 nonrecoverable_tax                       ,
							 recovery_rate                            ,
							 oke_contract_line_id                     ,
							 oke_contract_deliverable_id
						  ,  distribution_type
						  ,  NULL,
							 global_attribute_category ,
							 global_attribute1  ,
							 global_attribute2  ,
							 global_attribute3  ,
							 global_attribute4  ,
							 global_attribute5  ,
							 global_attribute6  ,
							 global_attribute7  ,
							 global_attribute8  ,
							 global_attribute9  ,
							 global_attribute10 ,
							 global_attribute11 ,
							 global_attribute12 ,
							 global_attribute13 ,
							 global_attribute14 ,
							 global_attribute15 ,
							 global_attribute16 ,
							 global_attribute17 ,
							 global_attribute18 ,
							 global_attribute19 ,
							 global_attribute20
					   FROM PO_DISTRIBUTIONS_ALL POD
					   WHERE POD.po_distribution_id = p_requested_changes.distribution_changes.parent_distribution_id(i);

				END IF;
			END LOOP;


			--Bug#15951569:: ER PO Change API:: END

    END IF;

l_progress := '006';
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END UPDATE_GLOBAL_TEMP_TABLES;

/**
* Private Procedure: POPULATE_PO_HEADERS_GT
* Requires:
*   IN PARAMETERS:
*       p_document_id: Id of submitted document
* Modifies:
* Effects:  Populates the global temp tables po_headers_gt
* Returns:
*/
PROCEDURE populate_po_headers_gt(p_document_id IN number,
                                    x_return_status OUT NOCOPY VARCHAR2)IS

l_api_name  CONSTANT varchar2(40) := 'POPULATE_PO_HEADERS_GT';
l_progress VARCHAR2(3);

t_po_header_id NUMBER;
t_segment1 po_headers.segment1%TYPE;

BEGIN

l_progress := '000';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Populate HEADERS');
   END IF;
END IF;

    INSERT INTO po_headers_gt(
            PO_HEADER_ID,
          AGENT_ID,
          TYPE_LOOKUP_CODE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          SEGMENT1,
          SUMMARY_FLAG,
          ENABLED_FLAG,
          SEGMENT2,
          SEGMENT3,
          SEGMENT4,
          SEGMENT5,
          START_DATE_ACTIVE,
          END_DATE_ACTIVE,
          LAST_UPDATE_LOGIN,
          CREATION_DATE ,
          CREATED_BY,
          VENDOR_ID,
          VENDOR_SITE_ID,
          VENDOR_CONTACT_ID,
          SHIP_TO_LOCATION_ID,
          BILL_TO_LOCATION_ID ,
          TERMS_ID             ,
          SHIP_VIA_LOOKUP_CODE  ,
          FOB_LOOKUP_CODE        ,
          FREIGHT_TERMS_LOOKUP_CODE,
          STATUS_LOOKUP_CODE,
          CURRENCY_CODE,
          RATE_TYPE,
          RATE_DATE,
          RATE,
          FROM_HEADER_ID,
          FROM_TYPE_LOOKUP_CODE,
          START_DATE,
          END_DATE,
          BLANKET_TOTAL_AMOUNT,
          AUTHORIZATION_STATUS,
          REVISION_NUM,
          REVISED_DATE,
          APPROVED_FLAG,
          APPROVED_DATE,
          AMOUNT_LIMIT,
          MIN_RELEASE_AMOUNT,
          NOTE_TO_AUTHORIZER,
          NOTE_TO_VENDOR,
          NOTE_TO_RECEIVER,
          PRINT_COUNT,
          PRINTED_DATE,
          VENDOR_ORDER_NUM,
          CONFIRMING_ORDER_FLAG,
          COMMENTS,
          REPLY_DATE,
          REPLY_METHOD_LOOKUP_CODE,
          RFQ_CLOSE_DATE,
          QUOTE_TYPE_LOOKUP_CODE,
          QUOTATION_CLASS_CODE,
          QUOTE_WARNING_DELAY_UNIT,
          QUOTE_WARNING_DELAY,
          QUOTE_VENDOR_QUOTE_NUMBER,
          ACCEPTANCE_REQUIRED_FLAG,
          ACCEPTANCE_DUE_DATE,
          CLOSED_DATE,
          USER_HOLD_FLAG,
          APPROVAL_REQUIRED_FLAG,
          CANCEL_FLAG,
          FIRM_STATUS_LOOKUP_CODE,
          FIRM_DATE,
          FROZEN_FLAG,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
            ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          CLOSED_CODE,
          GOVERNMENT_CONTEXT,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          ORG_ID,
          SUPPLY_AGREEMENT_FLAG,
          EDI_PROCESSED_FLAG,
          EDI_PROCESSED_STATUS,
          GLOBAL_ATTRIBUTE_CATEGORY,
          GLOBAL_ATTRIBUTE1,
          GLOBAL_ATTRIBUTE2,
          GLOBAL_ATTRIBUTE3,
          GLOBAL_ATTRIBUTE4,
          GLOBAL_ATTRIBUTE5,
          GLOBAL_ATTRIBUTE6,
          GLOBAL_ATTRIBUTE7,
          GLOBAL_ATTRIBUTE8,
          GLOBAL_ATTRIBUTE9,
          GLOBAL_ATTRIBUTE10,
          GLOBAL_ATTRIBUTE11,
          GLOBAL_ATTRIBUTE12,
          GLOBAL_ATTRIBUTE13,
          GLOBAL_ATTRIBUTE14,
          GLOBAL_ATTRIBUTE15,
          GLOBAL_ATTRIBUTE16,
          GLOBAL_ATTRIBUTE17,
          GLOBAL_ATTRIBUTE18,
          GLOBAL_ATTRIBUTE19,
          GLOBAL_ATTRIBUTE20,
          INTERFACE_SOURCE_CODE,
          REFERENCE_NUM,
          WF_ITEM_TYPE,
          WF_ITEM_KEY,
          MRC_RATE_TYPE,
          MRC_RATE_DATE,
          MRC_RATE,
          PCARD_ID,
          PRICE_UPDATE_TOLERANCE,
          PAY_ON_CODE,
          XML_FLAG,
          XML_SEND_DATE,
          XML_CHANGE_SEND_DATE,
          GLOBAL_AGREEMENT_FLAG,
          CONSIGNED_CONSUMPTION_FLAG,
          CBC_ACCOUNTING_DATE,
            CONTERMS_EXIST_FLAG --<CONTERMS FPJ>
         ,  encumbrance_required_flag  --<ENCUMBRANCE FPJ>
          ,enable_all_sites          --<R12GCPA>
            )
          SELECT
            PO_HEADER_ID,
          AGENT_ID,
          TYPE_LOOKUP_CODE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          SEGMENT1,
          SUMMARY_FLAG,
          ENABLED_FLAG,
          SEGMENT2,
          SEGMENT3,
          SEGMENT4,
          SEGMENT5,
          START_DATE_ACTIVE,
          END_DATE_ACTIVE,
          LAST_UPDATE_LOGIN,
          CREATION_DATE ,
          CREATED_BY,
          VENDOR_ID,
          VENDOR_SITE_ID,
          VENDOR_CONTACT_ID,
          SHIP_TO_LOCATION_ID,
          BILL_TO_LOCATION_ID ,
          TERMS_ID             ,
          SHIP_VIA_LOOKUP_CODE  ,
          FOB_LOOKUP_CODE        ,
          FREIGHT_TERMS_LOOKUP_CODE,
          STATUS_LOOKUP_CODE,
          CURRENCY_CODE,
          RATE_TYPE,
          RATE_DATE,
          RATE,
          FROM_HEADER_ID,
          FROM_TYPE_LOOKUP_CODE,
          START_DATE,
          END_DATE,
          BLANKET_TOTAL_AMOUNT,
          AUTHORIZATION_STATUS,
          REVISION_NUM,
          REVISED_DATE,
          APPROVED_FLAG,
          APPROVED_DATE,
          AMOUNT_LIMIT,
          MIN_RELEASE_AMOUNT,
          NOTE_TO_AUTHORIZER,
          NOTE_TO_VENDOR,
          NOTE_TO_RECEIVER,
          PRINT_COUNT,
          PRINTED_DATE,
          VENDOR_ORDER_NUM,
          CONFIRMING_ORDER_FLAG,
          COMMENTS,
          REPLY_DATE,
          REPLY_METHOD_LOOKUP_CODE,
          RFQ_CLOSE_DATE,
          QUOTE_TYPE_LOOKUP_CODE,
          QUOTATION_CLASS_CODE,
          QUOTE_WARNING_DELAY_UNIT,
          QUOTE_WARNING_DELAY,
          QUOTE_VENDOR_QUOTE_NUMBER,
          ACCEPTANCE_REQUIRED_FLAG,
          ACCEPTANCE_DUE_DATE,
          CLOSED_DATE,
          USER_HOLD_FLAG,
          APPROVAL_REQUIRED_FLAG,
          CANCEL_FLAG,
          FIRM_STATUS_LOOKUP_CODE,
          FIRM_DATE,
          FROZEN_FLAG,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
            ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          CLOSED_CODE,
          GOVERNMENT_CONTEXT,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          ORG_ID,
          SUPPLY_AGREEMENT_FLAG,
          EDI_PROCESSED_FLAG,
          EDI_PROCESSED_STATUS,
          GLOBAL_ATTRIBUTE_CATEGORY,
          GLOBAL_ATTRIBUTE1,
          GLOBAL_ATTRIBUTE2,
          GLOBAL_ATTRIBUTE3,
          GLOBAL_ATTRIBUTE4,
          GLOBAL_ATTRIBUTE5,
          GLOBAL_ATTRIBUTE6,
          GLOBAL_ATTRIBUTE7,
          GLOBAL_ATTRIBUTE8,
          GLOBAL_ATTRIBUTE9,
          GLOBAL_ATTRIBUTE10,
          GLOBAL_ATTRIBUTE11,
          GLOBAL_ATTRIBUTE12,
          GLOBAL_ATTRIBUTE13,
          GLOBAL_ATTRIBUTE14,
          GLOBAL_ATTRIBUTE15,
          GLOBAL_ATTRIBUTE16,
          GLOBAL_ATTRIBUTE17,
          GLOBAL_ATTRIBUTE18,
          GLOBAL_ATTRIBUTE19,
          GLOBAL_ATTRIBUTE20,
          INTERFACE_SOURCE_CODE,
          REFERENCE_NUM,
          WF_ITEM_TYPE,
          WF_ITEM_KEY,
          MRC_RATE_TYPE,
          MRC_RATE_DATE,
          MRC_RATE,
          PCARD_ID,
          PRICE_UPDATE_TOLERANCE,
          PAY_ON_CODE,
          XML_FLAG,
          XML_SEND_DATE,
          XML_CHANGE_SEND_DATE,
          GLOBAL_AGREEMENT_FLAG,
          CONSIGNED_CONSUMPTION_FLAG,
          CBC_ACCOUNTING_DATE,
            CONTERMS_EXIST_FLAG  --<CONTERMS FPJ>
         ,  encumbrance_required_flag  --<ENCUMBRANCE FPJ>
         , enable_all_sites  --<R12GCPA>
          FROM po_headers
          WHERE po_header_id = p_document_id;

l_progress := '001';
--SANITY check
SELECT po_header_id, segment1 into t_po_header_id, t_segment1
from po_headers_gt where po_header_id = p_document_id;

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'HEADER ' || to_char(t_po_header_id) ||
          'PO NUM ' || t_segment1);
   END IF;
END IF;

l_progress := '002';
 x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END POPULATE_PO_HEADERS_GT;


-- <Doc Manager Rewrite 11.5.11 Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: populate_po_lines_gt
--Pre-reqs:
--  None.
--Modifies:
--  PO_LINES_GT
--Locks:
--  None.
--Function:
--  Populates the lines GTT for submission checks.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    PA
--    PO
--p_doc_level
--  The type of id that is being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id
--  Id of the doc level type of which to populate the table.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE populate_po_lines_gt(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  x_return_status                  OUT NOCOPY     VARCHAR2
)
IS

l_api_name  CONSTANT varchar2(40) := 'POPULATE_PO_LINES_GT';
l_progress VARCHAR2(3);

l_line_id_tbl    po_tbl_number;

BEGIN

  l_progress := '000';

  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
            || l_progress,'Popluate LINES');
     END IF;
  END IF;

  l_progress := '010';

  PO_CORE_S.get_line_ids(
     p_doc_type => p_doc_type
  ,  p_doc_level => p_doc_level
  ,  p_doc_level_id_tbl => po_tbl_number( p_doc_level_id )
  ,  x_line_id_tbl => l_line_id_tbl
  );

  l_progress := '020';

  FORALL i IN 1 .. l_line_id_tbl.COUNT
    INSERT INTO po_lines_gt(
         PO_LINE_ID       ,
         LAST_UPDATE_DATE  ,
         LAST_UPDATED_BY    ,
         PO_HEADER_ID        ,
         LINE_TYPE_ID         ,
         LINE_NUM              ,
         LAST_UPDATE_LOGIN      ,
         CREATION_DATE           ,
         CREATED_BY               ,
         ITEM_ID                   ,
         ITEM_REVISION              ,
         CATEGORY_ID                 ,
         ITEM_DESCRIPTION             ,
         UNIT_MEAS_LOOKUP_CODE         ,
         QUANTITY_COMMITTED             ,
         COMMITTED_AMOUNT                ,
         ALLOW_PRICE_OVERRIDE_FLAG        ,
         NOT_TO_EXCEED_PRICE               ,
         LIST_PRICE_PER_UNIT                ,
         UNIT_PRICE                          ,
         QUANTITY                             ,
         UN_NUMBER_ID                          ,
         HAZARD_CLASS_ID                        ,
         NOTE_TO_VENDOR                          ,
         FROM_HEADER_ID                          ,
         FROM_LINE_ID                            ,
         MIN_ORDER_QUANTITY                      ,
         MAX_ORDER_QUANTITY                      ,
         QTY_RCV_TOLERANCE                       ,
         OVER_TOLERANCE_ERROR_FLAG               ,
         MARKET_PRICE                            ,
         UNORDERED_FLAG                          ,
         CLOSED_FLAG                              ,
         USER_HOLD_FLAG                          ,
         CANCEL_FLAG                              ,
         CANCELLED_BY                             ,
         CANCEL_DATE                             ,
         CANCEL_REASON                            ,
         FIRM_STATUS_LOOKUP_CODE                  ,
         FIRM_DATE                                ,
         VENDOR_PRODUCT_NUM                       ,
         CONTRACT_NUM                             ,
         TAXABLE_FLAG                             ,
         TAX_NAME                                 ,
         TYPE_1099                                ,
         CAPITAL_EXPENSE_FLAG                     ,
         NEGOTIATED_BY_PREPARER_FLAG              ,
         ATTRIBUTE_CATEGORY                       ,
         ATTRIBUTE1                               ,
         ATTRIBUTE2                               ,
         ATTRIBUTE3                               ,
         ATTRIBUTE4                               ,
         ATTRIBUTE5                               ,
         ATTRIBUTE6                               ,
         ATTRIBUTE7                               ,
         ATTRIBUTE8                               ,
         ATTRIBUTE9                              ,
         ATTRIBUTE10                              ,
         REFERENCE_NUM                            ,
         ATTRIBUTE11                              ,
         ATTRIBUTE12                              ,
         ATTRIBUTE13                              ,
         ATTRIBUTE14                              ,
         ATTRIBUTE15                              ,
         MIN_RELEASE_AMOUNT                       ,
         PRICE_TYPE_LOOKUP_CODE                   ,
         CLOSED_CODE                              ,
         PRICE_BREAK_LOOKUP_CODE                  ,
         GOVERNMENT_CONTEXT                       ,
         REQUEST_ID                               ,
         PROGRAM_APPLICATION_ID                   ,
         PROGRAM_ID                               ,
         PROGRAM_UPDATE_DATE                      ,
         CLOSED_DATE                              ,
         CLOSED_REASON                            ,
         CLOSED_BY                                ,
         TRANSACTION_REASON_CODE                 ,
         ORG_ID                                   ,
         QC_GRADE                                 ,
         BASE_UOM                                 ,
         BASE_QTY                                 ,
         SECONDARY_UOM                            ,
         SECONDARY_QTY                            ,
         GLOBAL_ATTRIBUTE_CATEGORY                ,
         GLOBAL_ATTRIBUTE1                        ,
         GLOBAL_ATTRIBUTE2                        ,
         GLOBAL_ATTRIBUTE3                        ,
         GLOBAL_ATTRIBUTE4                        ,
         GLOBAL_ATTRIBUTE5                        ,
         GLOBAL_ATTRIBUTE6                        ,
         GLOBAL_ATTRIBUTE7                        ,
         GLOBAL_ATTRIBUTE8                        ,
         GLOBAL_ATTRIBUTE9                        ,
         GLOBAL_ATTRIBUTE10                       ,
         GLOBAL_ATTRIBUTE11                       ,
         GLOBAL_ATTRIBUTE12                       ,
         GLOBAL_ATTRIBUTE13                       ,
         GLOBAL_ATTRIBUTE14                       ,
         GLOBAL_ATTRIBUTE15                       ,
         GLOBAL_ATTRIBUTE16                       ,
         GLOBAL_ATTRIBUTE17                      ,
         GLOBAL_ATTRIBUTE18                      ,
         GLOBAL_ATTRIBUTE19                      ,
         GLOBAL_ATTRIBUTE20                      ,
         LINE_REFERENCE_NUM                       ,
         PROJECT_ID                               ,
         TASK_ID                                  ,
         EXPIRATION_DATE                          ,
         TAX_CODE_ID                              ,
         OKE_CONTRACT_HEADER_ID                   ,
         OKE_CONTRACT_VERSION_ID                  ,
         SECONDARY_QUANTITY                       ,
         SECONDARY_UNIT_OF_MEASURE               ,
         PREFERRED_GRADE                          ,
         AUCTION_HEADER_ID                       ,
         AUCTION_DISPLAY_NUMBER                  ,
         AUCTION_LINE_NUMBER                     ,
         BID_NUMBER                              ,
         BID_LINE_NUMBER                          ,
         RETROACTIVE_DATE                         ,
         CONTRACT_ID                              ,   -- <GC FPJ>
         START_DATE                               , -- <PO_CHANGE_API FPJ>
         AMOUNT                                   , -- <PO_CHANGE_API FPJ>
         ORDER_TYPE_LOOKUP_CODE                   ,            -- <BUG 3262859>
         PURCHASE_BASIS                           ,            -- <BUG 3262859>
         MATCHING_BASIS                                        -- <BUG 3262859>
     )
     SELECT
         PO_LINE_ID                              ,
         LAST_UPDATE_DATE                        ,
         LAST_UPDATED_BY                 ,
         PO_HEADER_ID                    ,
         LINE_TYPE_ID                   ,
         LINE_NUM                        ,
         LAST_UPDATE_LOGIN                ,
         CREATION_DATE                     ,
         CREATED_BY                         ,
         ITEM_ID                             ,
         ITEM_REVISION                        ,
         CATEGORY_ID                           ,
         ITEM_DESCRIPTION                       ,
         UNIT_MEAS_LOOKUP_CODE                   ,
         QUANTITY_COMMITTED                      ,
         COMMITTED_AMOUNT                         ,
         ALLOW_PRICE_OVERRIDE_FLAG               ,
         NOT_TO_EXCEED_PRICE                      ,
         LIST_PRICE_PER_UNIT                      ,
         UNIT_PRICE                               ,
         QUANTITY                                 ,
         UN_NUMBER_ID                             ,
         HAZARD_CLASS_ID                          ,
         NOTE_TO_VENDOR                           ,
         FROM_HEADER_ID                          ,
         FROM_LINE_ID                            ,
         MIN_ORDER_QUANTITY                      ,
         MAX_ORDER_QUANTITY                      ,
         QTY_RCV_TOLERANCE                       ,
         OVER_TOLERANCE_ERROR_FLAG               ,
         MARKET_PRICE                            ,
         UNORDERED_FLAG                          ,
         CLOSED_FLAG                              ,
         USER_HOLD_FLAG                          ,
         CANCEL_FLAG                              ,
         CANCELLED_BY                             ,
         CANCEL_DATE                             ,
         CANCEL_REASON                            ,
         FIRM_STATUS_LOOKUP_CODE                  ,
         FIRM_DATE                                ,
         VENDOR_PRODUCT_NUM                       ,
         CONTRACT_NUM                             ,
         TAXABLE_FLAG                             ,
         TAX_NAME                                 ,
         TYPE_1099                                ,
         CAPITAL_EXPENSE_FLAG                     ,
         NEGOTIATED_BY_PREPARER_FLAG              ,
         ATTRIBUTE_CATEGORY                       ,
         ATTRIBUTE1                               ,
         ATTRIBUTE2                               ,
         ATTRIBUTE3                               ,
         ATTRIBUTE4                               ,
         ATTRIBUTE5                               ,
         ATTRIBUTE6                               ,
         ATTRIBUTE7                               ,
         ATTRIBUTE8                               ,
         ATTRIBUTE9                              ,
         ATTRIBUTE10                              ,
         REFERENCE_NUM                            ,
         ATTRIBUTE11                              ,
         ATTRIBUTE12                              ,
         ATTRIBUTE13                              ,
         ATTRIBUTE14                              ,
         ATTRIBUTE15                              ,
         MIN_RELEASE_AMOUNT                       ,
         PRICE_TYPE_LOOKUP_CODE                   ,
         CLOSED_CODE                              ,
         PRICE_BREAK_LOOKUP_CODE                  ,
         GOVERNMENT_CONTEXT                       ,
         REQUEST_ID                               ,
         PROGRAM_APPLICATION_ID                   ,
         PROGRAM_ID                               ,
         PROGRAM_UPDATE_DATE                      ,
         CLOSED_DATE                              ,
         CLOSED_REASON                            ,
         CLOSED_BY                                ,
         TRANSACTION_REASON_CODE                 ,
         ORG_ID                                   ,
         QC_GRADE                                 ,
         BASE_UOM                                 ,
         BASE_QTY                                 ,
         SECONDARY_UOM                            ,
         SECONDARY_QTY                            ,
         GLOBAL_ATTRIBUTE_CATEGORY                ,
         GLOBAL_ATTRIBUTE1                        ,
         GLOBAL_ATTRIBUTE2                        ,
         GLOBAL_ATTRIBUTE3                        ,
         GLOBAL_ATTRIBUTE4                        ,
         GLOBAL_ATTRIBUTE5                        ,
         GLOBAL_ATTRIBUTE6                        ,
         GLOBAL_ATTRIBUTE7                        ,
         GLOBAL_ATTRIBUTE8                        ,
         GLOBAL_ATTRIBUTE9                        ,
         GLOBAL_ATTRIBUTE10                       ,
         GLOBAL_ATTRIBUTE11                       ,
         GLOBAL_ATTRIBUTE12                       ,
         GLOBAL_ATTRIBUTE13                       ,
         GLOBAL_ATTRIBUTE14                       ,
         GLOBAL_ATTRIBUTE15                       ,
         GLOBAL_ATTRIBUTE16                       ,
         GLOBAL_ATTRIBUTE17                      ,
         GLOBAL_ATTRIBUTE18                      ,
         GLOBAL_ATTRIBUTE19                      ,
         GLOBAL_ATTRIBUTE20                      ,
         LINE_REFERENCE_NUM                       ,
         PROJECT_ID                               ,
         TASK_ID                                  ,
         EXPIRATION_DATE                          ,
         TAX_CODE_ID                              ,
         OKE_CONTRACT_HEADER_ID                   ,
         OKE_CONTRACT_VERSION_ID                  ,
         SECONDARY_QUANTITY                       ,
         SECONDARY_UNIT_OF_MEASURE               ,
         PREFERRED_GRADE                          ,
         AUCTION_HEADER_ID                       ,
         AUCTION_DISPLAY_NUMBER                  ,
         AUCTION_LINE_NUMBER                     ,
         BID_NUMBER                              ,
         BID_LINE_NUMBER                          ,
         RETROACTIVE_DATE                        ,
         CONTRACT_ID                              , -- <GC FPJ>
         START_DATE                               , -- <PO_CHANGE_API FPJ>
         AMOUNT                                   , -- <PO_CHANGE_API FPJ>
         ORDER_TYPE_LOOKUP_CODE                   ,            -- <BUG 3262859>
         PURCHASE_BASIS                           ,            -- <BUG 3262859>
         MATCHING_BASIS                                        -- <BUG 3262859>
      FROM po_lines_all pol
      WHERE pol.po_line_id = l_line_id_tbl(i)
      ;

  l_progress := '030';
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END POPULATE_PO_LINES_GT;
-- <End Doc Manager Rewrite 11.5.11>


/**
* Private Procedure: POPULATE_RELEASES_GT
* Requires:
*   IN PARAMETERS:
*       p_document_id: Id of submitted document
* Modifies:
* Effects:  Populates the global temp tables po_headers_gt
* Returns:
*/
PROCEDURE populate_releases_gt(p_document_id IN NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT varchar2(40) := 'POPULATE_RELEASES_GT';
l_progress VARCHAR2(3);

BEGIN
l_progress := '000';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Populate PO Releases');
   END IF;
END IF;

    INSERT INTO po_releases_gt(
         PO_RELEASE_ID                   ,
         LAST_UPDATE_DATE                ,
         LAST_UPDATED_BY                ,
         PO_HEADER_ID                  ,
         RELEASE_NUM                    ,
         AGENT_ID                       ,
         RELEASE_DATE                  ,
         LAST_UPDATE_LOGIN              ,
         CREATION_DATE                  ,
         CREATED_BY                      ,
         REVISION_NUM                     ,
         REVISED_DATE                      ,
         APPROVED_FLAG                      ,
         APPROVED_DATE                       ,
         PRINT_COUNT                          ,
         PRINTED_DATE                          ,
         ACCEPTANCE_REQUIRED_FLAG               ,
         ACCEPTANCE_DUE_DATE                     ,
         HOLD_BY                                  ,
         HOLD_DATE                                ,
         HOLD_REASON                              ,
         HOLD_FLAG                                ,
         CANCEL_FLAG                              ,
         CANCELLED_BY                             ,
         CANCEL_DATE                              ,
         CANCEL_REASON                            ,
         FIRM_STATUS_LOOKUP_CODE                  ,
         FIRM_DATE                                ,
         ATTRIBUTE_CATEGORY                       ,
         ATTRIBUTE1                               ,
         ATTRIBUTE2                               ,
         ATTRIBUTE3                               ,
         ATTRIBUTE4                               ,
         ATTRIBUTE5                               ,
         ATTRIBUTE6                               ,
         ATTRIBUTE7                               ,
         ATTRIBUTE8                               ,
         ATTRIBUTE9                               ,
         ATTRIBUTE10                              ,
         ATTRIBUTE11                              ,
         ATTRIBUTE12                              ,
         ATTRIBUTE13                              ,
         ATTRIBUTE14                              ,
         ATTRIBUTE15                              ,
         AUTHORIZATION_STATUS                     ,
         GOVERNMENT_CONTEXT                       ,
         REQUEST_ID                               ,
         PROGRAM_APPLICATION_ID                   ,
         PROGRAM_ID                               ,
         PROGRAM_UPDATE_DATE                      ,
         CLOSED_CODE                              ,
         FROZEN_FLAG                              ,
         RELEASE_TYPE                             ,
         NOTE_TO_VENDOR                           ,
         ORG_ID                                   ,
         EDI_PROCESSED_FLAG                       ,
         GLOBAL_ATTRIBUTE_CATEGORY                ,
         GLOBAL_ATTRIBUTE1                        ,
         GLOBAL_ATTRIBUTE2                        ,
         GLOBAL_ATTRIBUTE3                        ,
         GLOBAL_ATTRIBUTE4                        ,
         GLOBAL_ATTRIBUTE5                        ,
         GLOBAL_ATTRIBUTE6                        ,
         GLOBAL_ATTRIBUTE7                        ,
         GLOBAL_ATTRIBUTE8                        ,
         GLOBAL_ATTRIBUTE9                        ,
         GLOBAL_ATTRIBUTE10                       ,
         GLOBAL_ATTRIBUTE11                       ,
         GLOBAL_ATTRIBUTE12                       ,
         GLOBAL_ATTRIBUTE13                       ,
         GLOBAL_ATTRIBUTE14                       ,
         GLOBAL_ATTRIBUTE15                       ,
         GLOBAL_ATTRIBUTE16                       ,
         GLOBAL_ATTRIBUTE17                       ,
         GLOBAL_ATTRIBUTE18                       ,
         GLOBAL_ATTRIBUTE19                       ,
         GLOBAL_ATTRIBUTE20                       ,
         WF_ITEM_TYPE                             ,
         WF_ITEM_KEY                              ,
         PCARD_ID                                ,
         PAY_ON_CODE                             ,
         XML_FLAG                                 ,
         XML_SEND_DATE                            ,
         XML_CHANGE_SEND_DATE                     ,
         CONSIGNED_CONSUMPTION_FLAG               ,
         CBC_ACCOUNTING_DATE)
      SELECT
                  PO_RELEASE_ID                   ,
         LAST_UPDATE_DATE                ,
         LAST_UPDATED_BY                ,
         PO_HEADER_ID                  ,
         RELEASE_NUM                    ,
         AGENT_ID                       ,
         RELEASE_DATE                  ,
         LAST_UPDATE_LOGIN              ,
         CREATION_DATE                  ,
         CREATED_BY                      ,
         REVISION_NUM                     ,
         REVISED_DATE                      ,
         APPROVED_FLAG                      ,
         APPROVED_DATE                       ,
         PRINT_COUNT                          ,
         PRINTED_DATE                          ,
         ACCEPTANCE_REQUIRED_FLAG               ,
         ACCEPTANCE_DUE_DATE                     ,
         HOLD_BY                                  ,
         HOLD_DATE                                ,
         HOLD_REASON                              ,
         HOLD_FLAG                                ,
         CANCEL_FLAG                              ,
         CANCELLED_BY                             ,
         CANCEL_DATE                              ,
         CANCEL_REASON                            ,
         FIRM_STATUS_LOOKUP_CODE                  ,
         FIRM_DATE                                ,
         ATTRIBUTE_CATEGORY                       ,
         ATTRIBUTE1                               ,
         ATTRIBUTE2                               ,
         ATTRIBUTE3                               ,
         ATTRIBUTE4                               ,
         ATTRIBUTE5                               ,
         ATTRIBUTE6                               ,
         ATTRIBUTE7                               ,
         ATTRIBUTE8                               ,
         ATTRIBUTE9                               ,
         ATTRIBUTE10                              ,
         ATTRIBUTE11                              ,
         ATTRIBUTE12                              ,
         ATTRIBUTE13                              ,
         ATTRIBUTE14                              ,
         ATTRIBUTE15                              ,
         AUTHORIZATION_STATUS                     ,
         GOVERNMENT_CONTEXT                       ,
         REQUEST_ID                               ,
         PROGRAM_APPLICATION_ID                   ,
         PROGRAM_ID                               ,
         PROGRAM_UPDATE_DATE                      ,
         CLOSED_CODE                              ,
         FROZEN_FLAG                              ,
         RELEASE_TYPE                             ,
         NOTE_TO_VENDOR                           ,
         ORG_ID                                   ,
         EDI_PROCESSED_FLAG                       ,
         GLOBAL_ATTRIBUTE_CATEGORY                ,
         GLOBAL_ATTRIBUTE1                        ,
         GLOBAL_ATTRIBUTE2                        ,
         GLOBAL_ATTRIBUTE3                        ,
         GLOBAL_ATTRIBUTE4                        ,
         GLOBAL_ATTRIBUTE5                        ,
         GLOBAL_ATTRIBUTE6                        ,
         GLOBAL_ATTRIBUTE7                        ,
         GLOBAL_ATTRIBUTE8                        ,
         GLOBAL_ATTRIBUTE9                        ,
         GLOBAL_ATTRIBUTE10                       ,
         GLOBAL_ATTRIBUTE11                       ,
         GLOBAL_ATTRIBUTE12                       ,
         GLOBAL_ATTRIBUTE13                       ,
         GLOBAL_ATTRIBUTE14                       ,
         GLOBAL_ATTRIBUTE15                       ,
         GLOBAL_ATTRIBUTE16                       ,
         GLOBAL_ATTRIBUTE17                       ,
         GLOBAL_ATTRIBUTE18                       ,
         GLOBAL_ATTRIBUTE19                       ,
         GLOBAL_ATTRIBUTE20                       ,
         WF_ITEM_TYPE                             ,
         WF_ITEM_KEY                              ,
         PCARD_ID                                ,
         PAY_ON_CODE                             ,
         XML_FLAG                                 ,
         XML_SEND_DATE                            ,
         XML_CHANGE_SEND_DATE                     ,
         CONSIGNED_CONSUMPTION_FLAG               ,
         CBC_ACCOUNTING_DATE
     FROM po_releases
     WHERE po_release_id = p_document_id;

l_progress := '001';
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END POPULATE_RELEASES_GT;


/**
* Private Procedure: POPULATE_REQ_HEADERS_GT
* Requires:
*   IN PARAMETERS:
*       p_document_id: Id of submitted document
* Modifies:
* Effects:  Populates the global temp tables po_headers_gt
* Returns:
*/
PROCEDURE populate_req_headers_gt(p_document_id IN NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT varchar2(40) := 'POPULATE_REQ_HEADERS_GT';
l_progress VARCHAR2(3);

BEGIN

l_progress := '000';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Populate Req Headers');
   END IF;
END IF;

    INSERT INTO po_req_headers_gt(
         PROGRAM_UPDATE_DATE                      ,
         INTERFACE_SOURCE_CODE                    ,
         INTERFACE_SOURCE_LINE_ID                 ,
         CLOSED_CODE                              ,
         ORG_ID                                   ,
         DESCRIPTION                              ,
         AUTHORIZATION_STATUS                     ,
         NOTE_TO_AUTHORIZER                       ,
         TYPE_LOOKUP_CODE                         ,
         TRANSFERRED_TO_OE_FLAG                   ,
         ATTRIBUTE_CATEGORY                       ,
         ATTRIBUTE1                               ,
         ATTRIBUTE2                               ,
         ATTRIBUTE3                               ,
         ATTRIBUTE4                               ,
         ATTRIBUTE5                               ,
         ON_LINE_FLAG                             ,
         PRELIMINARY_RESEARCH_FLAG                ,
         RESEARCH_COMPLETE_FLAG                   ,
         PREPARER_FINISHED_FLAG                   ,
         PREPARER_FINISHED_DATE                   ,
         AGENT_RETURN_FLAG                        ,
         AGENT_RETURN_NOTE                        ,
         CANCEL_FLAG                              ,
         ATTRIBUTE6                               ,
         ATTRIBUTE7                               ,
         ATTRIBUTE8                               ,
         ATTRIBUTE9                               ,
         ATTRIBUTE10                              ,
         ATTRIBUTE11                              ,
         ATTRIBUTE12                              ,
         ATTRIBUTE13                              ,
         ATTRIBUTE14                              ,
         ATTRIBUTE15                              ,
         GOVERNMENT_CONTEXT                       ,
         REQUEST_ID                               ,
         PROGRAM_APPLICATION_ID                   ,
         PROGRAM_ID                               ,
         REQUISITION_HEADER_ID             ,
         PREPARER_ID                       ,
         LAST_UPDATE_DATE                   ,
         LAST_UPDATED_BY                   ,
         SEGMENT1                          ,
         SUMMARY_FLAG                       ,
         ENABLED_FLAG                       ,
         SEGMENT2                                 ,
         SEGMENT3                                 ,
         SEGMENT4                                 ,
         SEGMENT5                                 ,
         START_DATE_ACTIVE                        ,
         END_DATE_ACTIVE                          ,
         LAST_UPDATE_LOGIN                        ,
         CREATION_DATE                            ,
         CREATED_BY                               ,
         WF_ITEM_TYPE                             ,
         WF_ITEM_KEY                              ,
         EMERGENCY_PO_NUM                          ,
         PCARD_ID                                    ,
         APPS_SOURCE_CODE                          ,
         CBC_ACCOUNTING_DATE)
     SELECT
         PROGRAM_UPDATE_DATE                      ,
         INTERFACE_SOURCE_CODE                    ,
         INTERFACE_SOURCE_LINE_ID                 ,
         CLOSED_CODE                              ,
         ORG_ID                                   ,
         DESCRIPTION                              ,
         AUTHORIZATION_STATUS                     ,
         substrb(NOTE_TO_AUTHORIZER,1,480)         , -- Bug4443295(added substr)
         TYPE_LOOKUP_CODE                         ,
         TRANSFERRED_TO_OE_FLAG                   ,
         ATTRIBUTE_CATEGORY                       ,
         ATTRIBUTE1                               ,
         ATTRIBUTE2                               ,
         ATTRIBUTE3                               ,
         ATTRIBUTE4                               ,
         ATTRIBUTE5                               ,
         ON_LINE_FLAG                             ,
         PRELIMINARY_RESEARCH_FLAG                ,
         RESEARCH_COMPLETE_FLAG                   ,
         PREPARER_FINISHED_FLAG                   ,
         PREPARER_FINISHED_DATE                   ,
         AGENT_RETURN_FLAG                        ,
         AGENT_RETURN_NOTE                        ,
         CANCEL_FLAG                              ,
         ATTRIBUTE6                               ,
         ATTRIBUTE7                               ,
         ATTRIBUTE8                               ,
         ATTRIBUTE9                               ,
         ATTRIBUTE10                              ,
         ATTRIBUTE11                              ,
         ATTRIBUTE12                              ,
         ATTRIBUTE13                              ,
         ATTRIBUTE14                              ,
         ATTRIBUTE15                              ,
         GOVERNMENT_CONTEXT                       ,
         REQUEST_ID                               ,
         PROGRAM_APPLICATION_ID                   ,
         PROGRAM_ID                               ,
         REQUISITION_HEADER_ID             ,
         PREPARER_ID                       ,
         LAST_UPDATE_DATE                   ,
         LAST_UPDATED_BY                   ,
         SEGMENT1                          ,
         SUMMARY_FLAG                       ,
         ENABLED_FLAG                       ,
         SEGMENT2                                 ,
         SEGMENT3                                 ,
         SEGMENT4                                 ,
         SEGMENT5                                 ,
         START_DATE_ACTIVE                        ,
         END_DATE_ACTIVE                          ,
         LAST_UPDATE_LOGIN                        ,
         CREATION_DATE                            ,
         CREATED_BY                               ,
         WF_ITEM_TYPE                             ,
         WF_ITEM_KEY                              ,
         EMERGENCY_PO_NUM                          ,
         PCARD_ID                                    ,
         APPS_SOURCE_CODE                          ,
         CBC_ACCOUNTING_DATE
    FROM po_requisition_headers
    WHERE requisition_header_id = p_document_id;

l_progress := '001';
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END POPULATE_REQ_HEADERS_GT;

/**
* Private Procedure: POPULATE_REQ_LINES_GT
* Requires:
*   IN PARAMETERS:
*       p_document_id: Id of submitted document
* Modifies:
* Effects:  Populates the global temp tables po_headers_gt
* Returns:
*/
PROCEDURE populate_req_lines_gt(p_document_id IN NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT varchar2(40) := 'POPULATE_REQ_LINES_GT';
l_progress VARCHAR2(3);

BEGIN

l_progress := '000';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Populate Req Lines');
   END IF;
END IF;

    INSERT INTO po_req_lines_gt(
         REQUEST_ID                               ,
         PROGRAM_APPLICATION_ID                   ,
         PROGRAM_ID                               ,
         PROGRAM_UPDATE_DATE                      ,
         GOVERNMENT_CONTEXT                       ,
         CLOSED_REASON                            ,
         CLOSED_DATE                              ,
         TRANSACTION_REASON_CODE                  ,
         QUANTITY_RECEIVED                        ,
         SOURCE_REQ_LINE_ID                       ,
         ORG_ID                                   ,
         CANCEL_REASON                            ,
         CLOSED_CODE                              ,
         AGENT_RETURN_NOTE                        ,
         CHANGED_AFTER_RESEARCH_FLAG              ,
         VENDOR_ID                                ,
         VENDOR_SITE_ID                           ,
         VENDOR_CONTACT_ID                        ,
         RESEARCH_AGENT_ID                        ,
         ON_LINE_FLAG                             ,
         WIP_ENTITY_ID                            ,
         WIP_LINE_ID                              ,
         WIP_REPETITIVE_SCHEDULE_ID               ,
         WIP_OPERATION_SEQ_NUM                    ,
         WIP_RESOURCE_SEQ_NUM                     ,
         ATTRIBUTE_CATEGORY                       ,
         DESTINATION_CONTEXT                      ,
         INVENTORY_SOURCE_CONTEXT                 ,
         VENDOR_SOURCE_CONTEXT                    ,
         ATTRIBUTE1                               ,
         ATTRIBUTE2                               ,
         ATTRIBUTE3                               ,
         ATTRIBUTE4                               ,
         ATTRIBUTE5                               ,
         ATTRIBUTE6                               ,
         ATTRIBUTE7                               ,
         ATTRIBUTE8                               ,
         ATTRIBUTE9                               ,
         ATTRIBUTE10                              ,
         ATTRIBUTE11                              ,
         ATTRIBUTE12                              ,
         ATTRIBUTE13                              ,
         ATTRIBUTE14                              ,
         ATTRIBUTE15                              ,
         BOM_RESOURCE_ID                          ,
         PARENT_REQ_LINE_ID                       ,
         JUSTIFICATION                            ,
         NOTE_TO_AGENT                            ,
         NOTE_TO_RECEIVER                         ,
         PURCHASING_AGENT_ID                      ,
         DOCUMENT_TYPE_CODE                       ,
         BLANKET_PO_HEADER_ID                     ,
         BLANKET_PO_LINE_NUM                      ,
         CURRENCY_CODE                            ,
         RATE_TYPE                                ,
         RATE_DATE                                ,
         RATE                                     ,
         CURRENCY_UNIT_PRICE                      ,
         SUGGESTED_VENDOR_NAME                    ,
         SUGGESTED_VENDOR_LOCATION                ,
         SUGGESTED_VENDOR_CONTACT                 ,
         SUGGESTED_VENDOR_PHONE                   ,
         SUGGESTED_VENDOR_PRODUCT_CODE            ,
         UN_NUMBER_ID                             ,
         HAZARD_CLASS_ID                          ,
         MUST_USE_SUGG_VENDOR_FLAG                ,
         REFERENCE_NUM                            ,
         ON_RFQ_FLAG                              ,
         URGENT_FLAG                              ,
         CANCEL_FLAG                              ,
         SOURCE_ORGANIZATION_ID                   ,
         SOURCE_SUBINVENTORY                      ,
         DESTINATION_TYPE_CODE                    ,
         DESTINATION_ORGANIZATION_ID              ,
         DESTINATION_SUBINVENTORY                 ,
         QUANTITY_CANCELLED                       ,
         CANCEL_DATE                              ,
         REQUISITION_LINE_ID               ,
         REQUISITION_HEADER_ID             ,
         LINE_NUM                          ,
         LINE_TYPE_ID                      ,
         CATEGORY_ID                       ,
         ITEM_DESCRIPTION                  ,
         UNIT_MEAS_LOOKUP_CODE             ,
         UNIT_PRICE                        ,
         QUANTITY                          ,
         AMOUNT                            ,                  -- <SERVICES FPJ>
         DELIVER_TO_LOCATION_ID           ,
         TO_PERSON_ID                     ,
         LAST_UPDATE_DATE                 ,
         LAST_UPDATED_BY                   ,
         SOURCE_TYPE_CODE                  ,
         LAST_UPDATE_LOGIN                        ,
         CREATION_DATE                            ,
         CREATED_BY                               ,
         ITEM_ID                                  ,
         ITEM_REVISION                            ,
         QUANTITY_DELIVERED                       ,
         SUGGESTED_BUYER_ID                       ,
         ENCUMBERED_FLAG                          ,
         RFQ_REQUIRED_FLAG                        ,
         NEED_BY_DATE                             ,
         LINE_LOCATION_ID                         ,
         MODIFIED_BY_AGENT_FLAG                   ,
         KANBAN_CARD_ID                           ,
         CATALOG_TYPE                             ,
         CATALOG_SOURCE                           ,
         MANUFACTURER_ID                          ,
         MANUFACTURER_NAME                        ,
         MANUFACTURER_PART_NUMBER                 ,
         REQUESTER_EMAIL                          ,
         REQUESTER_FAX                            ,
         REQUESTER_PHONE                          ,
         UNSPSC_CODE                              ,
         OTHER_CATEGORY_CODE                      ,
         SUPPLIER_DUNS                            ,
         TAX_STATUS_INDICATOR                     ,
         PCARD_FLAG                               ,
         NEW_SUPPLIER_FLAG                        ,
         AUTO_RECEIVE_FLAG                        ,
         TAX_USER_OVERRIDE_FLAG                   ,
         TAX_CODE_ID                              ,
         NOTE_TO_VENDOR                           ,
         OKE_CONTRACT_HEADER_ID                   ,
         OKE_CONTRACT_VERSION_ID                  ,
         ITEM_SOURCE_ID                           ,
         SUPPLIER_REF_NUMBER                      ,
         SECONDARY_UNIT_OF_MEASURE                ,
         SECONDARY_QUANTITY                       ,
         PREFERRED_GRADE                          ,
         SECONDARY_QUANTITY_RECEIVED              ,
         SECONDARY_QUANTITY_CANCELLED             ,
         AUCTION_HEADER_ID                        ,
         AUCTION_DISPLAY_NUMBER                   ,
         AUCTION_LINE_NUMBER                      ,
         REQS_IN_POOL_FLAG                        ,
         VMI_FLAG                                 ,
         BID_NUMBER                               ,
         BID_LINE_NUMBER)
    SELECT
         REQUEST_ID                               ,
         PROGRAM_APPLICATION_ID                   ,
         PROGRAM_ID                               ,
         PROGRAM_UPDATE_DATE                      ,
         GOVERNMENT_CONTEXT                       ,
         CLOSED_REASON                            ,
         CLOSED_DATE                              ,
         TRANSACTION_REASON_CODE                  ,
         QUANTITY_RECEIVED                        ,
         SOURCE_REQ_LINE_ID                       ,
         ORG_ID                                   ,
         CANCEL_REASON                            ,
         CLOSED_CODE                              ,
         AGENT_RETURN_NOTE                        ,
         CHANGED_AFTER_RESEARCH_FLAG              ,
         VENDOR_ID                                ,
         VENDOR_SITE_ID                           ,
         VENDOR_CONTACT_ID                        ,
         RESEARCH_AGENT_ID                        ,
         ON_LINE_FLAG                             ,
         WIP_ENTITY_ID                            ,
         WIP_LINE_ID                              ,
         WIP_REPETITIVE_SCHEDULE_ID               ,
         WIP_OPERATION_SEQ_NUM                    ,
         WIP_RESOURCE_SEQ_NUM                     ,
         ATTRIBUTE_CATEGORY                       ,
         DESTINATION_CONTEXT                      ,
         INVENTORY_SOURCE_CONTEXT                 ,
         VENDOR_SOURCE_CONTEXT                    ,
         ATTRIBUTE1                               ,
         ATTRIBUTE2                               ,
         ATTRIBUTE3                               ,
         ATTRIBUTE4                               ,
         ATTRIBUTE5                               ,
         ATTRIBUTE6                               ,
         ATTRIBUTE7                               ,
         ATTRIBUTE8                               ,
         ATTRIBUTE9                               ,
         ATTRIBUTE10                              ,
         ATTRIBUTE11                              ,
         ATTRIBUTE12                              ,
         ATTRIBUTE13                              ,
         ATTRIBUTE14                              ,
         ATTRIBUTE15                              ,
         BOM_RESOURCE_ID                          ,
         PARENT_REQ_LINE_ID                       ,
         JUSTIFICATION                            ,
         NOTE_TO_AGENT                            ,
         NOTE_TO_RECEIVER                         ,
         PURCHASING_AGENT_ID                      ,
         DOCUMENT_TYPE_CODE                       ,
         BLANKET_PO_HEADER_ID                     ,
         BLANKET_PO_LINE_NUM                      ,
         CURRENCY_CODE                            ,
         RATE_TYPE                                ,
         RATE_DATE                                ,
         RATE                                     ,
         CURRENCY_UNIT_PRICE                      ,
         SUGGESTED_VENDOR_NAME                    ,
         SUGGESTED_VENDOR_LOCATION                ,
         SUGGESTED_VENDOR_CONTACT                 ,
         SUGGESTED_VENDOR_PHONE                   ,
         SUGGESTED_VENDOR_PRODUCT_CODE            ,
         UN_NUMBER_ID                             ,
         HAZARD_CLASS_ID                          ,
         MUST_USE_SUGG_VENDOR_FLAG                ,
         REFERENCE_NUM                            ,
         ON_RFQ_FLAG                              ,
         URGENT_FLAG                              ,
         CANCEL_FLAG                              ,
         SOURCE_ORGANIZATION_ID                   ,
         SOURCE_SUBINVENTORY                      ,
         DESTINATION_TYPE_CODE                    ,
         DESTINATION_ORGANIZATION_ID              ,
         DESTINATION_SUBINVENTORY                 ,
         QUANTITY_CANCELLED                       ,
         CANCEL_DATE                              ,
         REQUISITION_LINE_ID               ,
         REQUISITION_HEADER_ID             ,
         LINE_NUM                          ,
         LINE_TYPE_ID                      ,
         CATEGORY_ID                       ,
         ITEM_DESCRIPTION                  ,
         UNIT_MEAS_LOOKUP_CODE             ,
         UNIT_PRICE                        ,
         QUANTITY                          ,
         AMOUNT                            ,                  -- <SERVICES FPJ>
         DELIVER_TO_LOCATION_ID           ,
         TO_PERSON_ID                     ,
         LAST_UPDATE_DATE                 ,
         LAST_UPDATED_BY                   ,
         SOURCE_TYPE_CODE                  ,
         LAST_UPDATE_LOGIN                        ,
         CREATION_DATE                            ,
         CREATED_BY                               ,
         ITEM_ID                                  ,
         ITEM_REVISION                            ,
         QUANTITY_DELIVERED                       ,
         SUGGESTED_BUYER_ID                       ,
         ENCUMBERED_FLAG                          ,
         RFQ_REQUIRED_FLAG                        ,
         NEED_BY_DATE                             ,
         LINE_LOCATION_ID                         ,
         MODIFIED_BY_AGENT_FLAG                   ,
         KANBAN_CARD_ID                           ,
         CATALOG_TYPE                             ,
         CATALOG_SOURCE                           ,
         MANUFACTURER_ID                          ,
         MANUFACTURER_NAME                        ,
         MANUFACTURER_PART_NUMBER                 ,
         REQUESTER_EMAIL                          ,
         REQUESTER_FAX                            ,
         REQUESTER_PHONE                          ,
         UNSPSC_CODE                              ,
         OTHER_CATEGORY_CODE                      ,
         SUPPLIER_DUNS                            ,
         TAX_STATUS_INDICATOR                     ,
         PCARD_FLAG                               ,
         NEW_SUPPLIER_FLAG                        ,
         AUTO_RECEIVE_FLAG                        ,
         TAX_USER_OVERRIDE_FLAG                   ,
         TAX_CODE_ID                              ,
         NOTE_TO_VENDOR                           ,
         OKE_CONTRACT_HEADER_ID                   ,
         OKE_CONTRACT_VERSION_ID                  ,
         ITEM_SOURCE_ID                           ,
         SUPPLIER_REF_NUMBER                      ,
         SECONDARY_UNIT_OF_MEASURE                ,
         SECONDARY_QUANTITY                       ,
         PREFERRED_GRADE                          ,
         SECONDARY_QUANTITY_RECEIVED              ,
         SECONDARY_QUANTITY_CANCELLED             ,
         AUCTION_HEADER_ID                        ,
         AUCTION_DISPLAY_NUMBER                   ,
         AUCTION_LINE_NUMBER                      ,
         REQS_IN_POOL_FLAG                        ,
         VMI_FLAG                                 ,
         BID_NUMBER                               ,
         BID_LINE_NUMBER
    FROM po_requisition_lines
    WHERE requisition_header_id = p_document_id;

l_progress := '001';
    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
        END IF;

        IF (g_debug_unexp) THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_log_head ||
                       l_api_name || '.others_exception', 'EXCEPTION: Location is '
                       || l_progress || ' SQL CODE is '||sqlcode);
                END IF;
        END IF;

END POPULATE_REQ_LINES_GT;

/**
* Private Procedure: POPULATE_REQ_DISTRIBUTIONS_GT
* Requires:
*   IN PARAMETERS:
*       p_document_id: Id of submitted document
* Modifies:
* Effects:  Populates the global temp tables po_headers_gt
* Returns:
*/
PROCEDURE populate_req_distributions_gt(
   p_document_id                    IN             NUMBER
)
IS

l_api_name  CONSTANT varchar2(40) := 'POPULATE_REQ_DISTRIBUTIONS_GT';
l_progress VARCHAR2(3);

BEGIN

l_progress := '000';
IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
          || l_progress,'Populate Req Distributions');
   END IF;
END IF;

    INSERT INTO po_req_distributions_gt(
         DISTRIBUTION_ID                   ,
         LAST_UPDATE_DATE                  ,
         LAST_UPDATED_BY                   ,
         REQUISITION_LINE_ID               ,
         SET_OF_BOOKS_ID                   ,
         CODE_COMBINATION_ID               ,
         REQ_LINE_QUANTITY                 ,
         REQ_LINE_AMOUNT                   ,                  -- <SERVICES FPJ>
         LAST_UPDATE_LOGIN                        ,
         CREATION_DATE                            ,
         CREATED_BY                               ,
         ENCUMBERED_FLAG                          ,
         GL_ENCUMBERED_DATE                       ,
         GL_ENCUMBERED_PERIOD_NAME                ,
         GL_CANCELLED_DATE                        ,
         FAILED_FUNDS_LOOKUP_CODE                 ,
         ENCUMBERED_AMOUNT                        ,
         BUDGET_ACCOUNT_ID                        ,
         ACCRUAL_ACCOUNT_ID                       ,
         ORG_ID                                   ,
         VARIANCE_ACCOUNT_ID                      ,
         PREVENT_ENCUMBRANCE_FLAG                 ,
         ATTRIBUTE_CATEGORY                       ,
         ATTRIBUTE1                               ,
         ATTRIBUTE2                               ,
         ATTRIBUTE3                               ,
         ATTRIBUTE4                               ,
         ATTRIBUTE5                               ,
         ATTRIBUTE6                               ,
         ATTRIBUTE7                               ,
         ATTRIBUTE8                               ,
         ATTRIBUTE9                               ,
         ATTRIBUTE10                              ,
         ATTRIBUTE11                              ,
         ATTRIBUTE12                              ,
         ATTRIBUTE13                              ,
         ATTRIBUTE14                              ,
         ATTRIBUTE15                              ,
         GOVERNMENT_CONTEXT                       ,
         REQUEST_ID                               ,
         PROGRAM_APPLICATION_ID                   ,
         PROGRAM_ID                               ,
         PROGRAM_UPDATE_DATE                      ,
         PROJECT_ID                               ,
         TASK_ID                                  ,
         EXPENDITURE_TYPE                         ,
         PROJECT_ACCOUNTING_CONTEXT               ,
         EXPENDITURE_ORGANIZATION_ID              ,
         GL_CLOSED_DATE                           ,
         SOURCE_REQ_DISTRIBUTION_ID               ,
         DISTRIBUTION_NUM                         ,
         PROJECT_RELATED_FLAG                     ,
         EXPENDITURE_ITEM_DATE                    ,
         ALLOCATION_TYPE                          ,
         ALLOCATION_VALUE                         ,
         AWARD_ID                                 ,
         END_ITEM_UNIT_NUMBER                     ,
         RECOVERABLE_TAX                          ,
         NONRECOVERABLE_TAX                       ,
         RECOVERY_RATE                            ,
         TAX_RECOVERY_OVERRIDE_FLAG               ,
         OKE_CONTRACT_LINE_ID                     ,
         OKE_CONTRACT_DELIVERABLE_ID)
    SELECT
         PRD.DISTRIBUTION_ID                   ,
         PRD.LAST_UPDATE_DATE                  ,
         PRD.LAST_UPDATED_BY                   ,
         PRD.REQUISITION_LINE_ID               ,
         PRD.SET_OF_BOOKS_ID                   ,
         PRD.CODE_COMBINATION_ID               ,
         PRD.REQ_LINE_QUANTITY                 ,
         PRD.REQ_LINE_AMOUNT                   ,              -- <SERVICES FPJ>
         PRD.LAST_UPDATE_LOGIN                        ,
         PRD.CREATION_DATE                            ,
         PRD.CREATED_BY                               ,
         PRD.ENCUMBERED_FLAG                          ,
         PRD.GL_ENCUMBERED_DATE                       ,
         PRD.GL_ENCUMBERED_PERIOD_NAME                ,
         PRD.GL_CANCELLED_DATE                        ,
         PRD.FAILED_FUNDS_LOOKUP_CODE                 ,
         PRD.ENCUMBERED_AMOUNT                        ,
         PRD.BUDGET_ACCOUNT_ID                        ,
         PRD.ACCRUAL_ACCOUNT_ID                       ,
         PRD.ORG_ID                                   ,
         PRD.VARIANCE_ACCOUNT_ID                      ,
         PRD.PREVENT_ENCUMBRANCE_FLAG                 ,
         PRD.ATTRIBUTE_CATEGORY                       ,
         PRD.ATTRIBUTE1                               ,
         PRD.ATTRIBUTE2                               ,
         PRD.ATTRIBUTE3                               ,
         PRD.ATTRIBUTE4                               ,
         PRD.ATTRIBUTE5                               ,
         PRD.ATTRIBUTE6                               ,
         PRD.ATTRIBUTE7                               ,
         PRD.ATTRIBUTE8                               ,
         PRD.ATTRIBUTE9                               ,
         PRD.ATTRIBUTE10                              ,
         PRD.ATTRIBUTE11                              ,
         PRD.ATTRIBUTE12                              ,
         PRD.ATTRIBUTE13                              ,
         PRD.ATTRIBUTE14                              ,
         PRD.ATTRIBUTE15                              ,
         PRD.GOVERNMENT_CONTEXT                       ,
         PRD.REQUEST_ID                               ,
         PRD.PROGRAM_APPLICATION_ID                   ,
         PRD.PROGRAM_ID                               ,
         PRD.PROGRAM_UPDATE_DATE                      ,
         PRD.PROJECT_ID                               ,
         PRD.TASK_ID                                  ,
         PRD.EXPENDITURE_TYPE                         ,
         PRD.PROJECT_ACCOUNTING_CONTEXT               ,
         PRD.EXPENDITURE_ORGANIZATION_ID              ,
         PRD.GL_CLOSED_DATE                           ,
         PRD.SOURCE_REQ_DISTRIBUTION_ID               ,
         PRD.DISTRIBUTION_NUM                         ,
         PRD.PROJECT_RELATED_FLAG                     ,
         PRD.EXPENDITURE_ITEM_DATE                    ,
         PRD.ALLOCATION_TYPE                          ,
         PRD.ALLOCATION_VALUE                         ,
         PRD.AWARD_ID                                 ,
         PRD.END_ITEM_UNIT_NUMBER                     ,
         PRD.RECOVERABLE_TAX                          ,
         PRD.NONRECOVERABLE_TAX                       ,
         PRD.RECOVERY_RATE                            ,
         PRD.TAX_RECOVERY_OVERRIDE_FLAG               ,
         PRD.OKE_CONTRACT_LINE_ID                     ,
         PRD.OKE_CONTRACT_DELIVERABLE_ID
    FROM po_req_distributions PRD, po_requisition_lines PRL
    WHERE PRD.requisition_line_id = PRL.requisition_line_id AND
          PRL.requisition_header_id = p_document_id;

l_progress := '001';

END POPULATE_REQ_DISTRIBUTIONS_GT;

-- <FPJ, Refactor Security API START>
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
*                             the security check on
*     p_document_subtype:     The subtype of the document.
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
                             p_minimum_access_level IN VARCHAR2,
                             p_document_type        IN VARCHAR2,
                             p_document_subtype     IN VARCHAR2,
                             p_type_clause          IN VARCHAR2,
                             x_return_status        OUT NOCOPY VARCHAR2,
                             x_msg_data             OUT NOCOPY VARCHAR2,
                             x_where_clause         OUT NOCOPY VARCHAR2)
IS

  l_api_name    CONSTANT varchar2(30) := 'PO_SECURITY_CHECK';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_progress    VARCHAR2(3);
  l_access_level  PO_DOCUMENT_TYPES.access_level_code%TYPE;
  l_security_level  PO_DOCUMENT_TYPES.security_level_code%TYPE;
  l_security_hierarchy  NUMBER;
  l_id_column           varchar2(30);
  l_doctype_column      varchar2(30); /*Bug 7229262/7239696*/

BEGIN

  l_progress := '000';
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '010';
  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
            || l_progress, 'deciding security level');
     END IF;
  END IF;

   l_progress := '020';

  -- Bug 3663057
  -- Get the id column based on the document type being queried
  -- Bug 5054685: Performance issue: Added 'PO_PA' as another parameter to collapse
  -- multiple security related where-clauses into one.
  -- Bug 4082310: Handling the missed case of QUOTATION and RFQ.
    -- l_id_column is used to construct the where clause of the pre-query
    -- in join condition against po_action_history table. This fix
    -- is just to make the where clause valid even though QUOTATION
    -- and RFQ are not logged in po_action_history table. Avoiding
    -- adding logic to omit the condition in these cases as it will
    -- unnecessarily complicate the code.

   /* Bug 7229262/7239696 */
   l_doctype_column := 'TYPE_LOOKUP_CODE';
   /* End Bug 7229262/7239696 */
  IF p_document_type in ('PO','PA', 'PO_PA','QUOTATION','RFQ') THEN
     l_id_column := 'PO_HEADER_ID';
  ELSIF p_document_type = 'RELEASE' THEN
     l_id_column := 'PO_RELEASE_ID';
     l_doctype_column := 'DOCUMENT_TYPE';   -- Bug 9311634
  ELSIF p_document_type = 'REQUISITION' THEN
     l_id_column := 'REQUISITION_HEADER_ID';
  ELSE
    l_id_column := 'PO_HEADER_ID';
  END IF;
  -- <R12 MOAC start>
  IF (p_query_table = 'PO_WF_NOTIFICATIONS_V' ) THEN
    l_id_column := 'OBJECT_ID' ;  /*Bug 7229262/7239696*/
	  l_doctype_column := 'DOC_TYPE';
  END IF;
  -- <R12 MOAC end>


  l_progress := '060';
  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
            || l_progress, 'deciding WHERE clause');
     END IF;
  END IF;

   -- Construct WHERE clause with type_clause
  x_where_clause := '(NOT(' || p_type_clause || ') OR (';

  /*Bug6640107 Removed the check for the access level here. First we check for all the security levels and
    then finally AND with the access level check
    For security level of private only the owner should be able to view the document on the enter PO form
    irrespective of the access level*/

  x_where_clause := x_where_clause ||
                   '(('||p_query_table||'.security_level_code = ''PUBLIC'' )';

  x_where_clause := x_where_clause ||
                    ' OR '||'('||p_query_table || '.security_level_code = ''PRIVATE'' AND '||
         p_employee_id || '=' || p_owner_id_column ||')';
	/* OR (' ||
        'EXISTS (SELECT ''Y'' FROM PO_ACTION_HISTORY POAH2 ' ||
        'WHERE POAH2.employee_id = ' || p_employee_id ||
        ' AND POAH2.object_type_code = (DECODE(' || p_query_table || '.type_lookup_code, ''BLANKET'', ''PA'', ''STANDARD'', ''PO'' , ''PLANNED'' , ''PO'' , ''CONTRACT'' , ''PA'', ''RELEASE'' , ''RELEASE'' ) )' ||
        ' AND POAH2.object_id = ' || p_query_table || '.' || l_id_column || '))))';*/

  x_where_clause := x_where_clause ||
                   ' OR '||'('||p_query_table || '.security_level_code = ''HIERARCHY'' AND '||
       '((' || p_employee_id || '=' || p_owner_id_column ||') OR (' ||
       'EXISTS (SELECT ''Y'' FROM PO_ACTION_HISTORY POAH2 ' ||
       'WHERE POAH2.employee_id =' || p_employee_id ||
	   /* Bug 7229262/7239696
	   ' AND POAH2.object_type_code = (DECODE(' || p_query_table || '.type_lookup_code, ''BLANKET'', ''PA'', ''STANDARD'', ''PO'' , ''PLANNED'' , ''PO'' , ''CONTRACT'' , ''PA'', ''RELEASE'' , ''RELEASE'' ) ) ' ||
	   */
	   ' AND POAH2.object_type_code = (DECODE(' || p_query_table || '.'||l_doctype_column||', ''BLANKET'', ''PA'', ''STANDARD'', ''PO'' , ''PLANNED'' , ''PO'' , ''CONTRACT'' , ''PA'', ''RELEASE'' , ''RELEASE'' ) )' ||
		/* End Bug 7229262/7239696 */

       ' AND POAH2.object_id = ' || p_query_table || '.' || l_id_column || ')) OR (' ||
       p_employee_id || ' IN (SELECT H.superior_id ' ||
       ' FROM PO_EMPLOYEE_HIERARCHIES H, PO_SYSTEM_PARAMETERS PSP WHERE H.employee_id = ' ||
       p_query_table || '.' || p_owner_id_column ||
       ' AND H.position_structure_id = NVL(PSP.SECURITY_POSITION_STRUCTURE_ID,-1) '
       ||'AND PSP.ORG_ID = '||p_query_table || '.ORG_ID '
       ||'))))';

  x_where_clause := x_where_clause ||
                   ' OR '||'('||p_query_table || '.security_level_code = ''PURCHASING''  AND '||
       '((' || p_employee_id || '=' || p_owner_id_column ||') OR (' ||
       'EXISTS (SELECT ''Y'' FROM PO_ACTION_HISTORY POAH2 ' ||
       'WHERE POAH2.employee_id =' || p_employee_id ||
	   /* Bug 7229262/7239696
	   ' AND POAH2.object_type_code = (DECODE(' || p_query_table || '.type_lookup_code, ''BLANKET'', ''PA'', ''STANDARD'', ''PO'' , ''PLANNED'' , ''PO'' , ''CONTRACT'' , ''PA'', ''RELEASE'' , ''RELEASE'' ) ) ' ||
	   */
       ' AND POAH2.object_type_code = (DECODE(' || p_query_table || '.'||l_doctype_column||', ''BLANKET'', ''PA'', ''STANDARD'', ''PO'' , ''PLANNED'' , ''PO'' , ''CONTRACT'' , ''PA'', ''RELEASE'' , ''RELEASE'' ) ) ' ||
		/* End Bug 7229262/7239696 */
       ' AND POAH2.object_id = ' || p_query_table || '.' || l_id_column || ')) OR (' ||
       'EXISTS(SELECT NULL FROM PO_AGENTS WHERE agent_id= ' ||
       p_employee_id || ' AND SYSDATE BETWEEN NVL(start_date_active, ' ||
       'SYSDATE) AND NVL(end_date_active, SYSDATE+1))))' ||')'
       ||')';
/*Bug6640107 : Here the document access level is the access level set in po_headers_v and the required access level is p_minimum_access_level.
The following allows us to either view the document or to open and mofify it depending on the document access level*/

  x_where_clause := x_where_clause || 'AND (('''||p_minimum_access_level||''' = ''VIEW_ONLY'' ) OR ( '''|| p_minimum_access_level||''' = ''MODIFY'' AND ' || p_query_table||'.access_level_code IN (''MODIFY'',''FULL'') ) OR ( '''
  || p_minimum_access_level||''' = ''FULL'' AND '|| p_query_table||'.access_level_code = ''FULL'' ) OR ( '||p_employee_id ||' = '|| p_owner_id_column ||'))))';



  l_progress := '070';
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_data := NULL;

  l_progress := '100';
  IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
                   || l_progress,'Returning from PVT package: ' ||
                   x_where_clause);
    END IF;
  END IF;

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

    IF (g_debug_unexp) THEN
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
--Name: check_updatable
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Finds if a PurchaseOrder/Release, or Line/Shipment is updatable based on status.
--  A Header or Release has to be specified. Line/Shipment are optional.
--  A Purchase Order/Release is updatable if
--    it is not Pre Approved, not In Process, not canceled, not finally closed, not frozen.
--  A Line or Shipment is updatable if it is not canceled, not finally closed.
--Parameters:
--IN:
--p_count
--  Specifies the number of entities in table IN parameters like p_header_id, p_release_id
--  Other IN parameters are detailed in main procedure po_status_check
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_po_status_rec
--  Table x_po_status_rec.updateable_flag will be 'Y' or 'N' for each input entity
--Notes:
--  The implementation of updatable_flag involves a fake "update dual" statement to
--    optimize performance.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE check_updatable (
    p_count               IN NUMBER,
    p_header_id           IN PO_TBL_NUMBER,
    p_release_id          IN PO_TBL_NUMBER,
    p_document_type       IN PO_TBL_VARCHAR30,
    p_document_subtype    IN PO_TBL_VARCHAR30,
    p_document_num        IN PO_TBL_VARCHAR30,
    p_vendor_order_num    IN PO_TBL_VARCHAR30,
    p_line_id             IN PO_TBL_NUMBER,
    p_line_location_id    IN PO_TBL_NUMBER,
    p_distribution_id     IN PO_TBL_NUMBER,
    p_lock_flag           IN VARCHAR2 := 'N',
    p_calling_module      IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    p_role                IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    p_skip_cat_upload_chk IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    x_po_status_rec       IN OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       IN OUT NOCOPY VARCHAR2
) IS

l_api_name       CONSTANT VARCHAR(30) := 'CHECK_UPDATABLE';
l_progress       VARCHAR2(3) := '000';
l_document_id    PO_HEADERS.po_header_id%TYPE;
l_document_type  PO_DOCUMENT_TYPES.DOCUMENT_TYPE_CODE%TYPE;

-- bug3592160 START
l_header_id   PO_TBL_NUMBER;
l_procedure_id PO_SESSION_GT.key%TYPE;
-- bug3592160 END

-- <PDOI Rewrite R12 START>
l_role PO_DRAFTS.owner_role%TYPE := NVL(p_role, PO_GLOBAL.g_ROLE_BUYER);
l_skip_cat_upload_chk VARCHAR2(1) := NVL(p_skip_cat_upload_chk, FND_API.G_FALSE);

l_update_allowed VARCHAR2(1);
l_locking_applicable VARCHAR2(1);
l_unlock_required VARCHAR2(1);
l_message VARCHAR2(30);
-- <PDOI Rewrite R12 END>
BEGIN

IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

--To obtimize performance, Execute a fake "update dual" in BULK. The WHERE clause
-- of the fake update statement checks if the current entity is updatable or not.
-- One dual row updated <==> where clause is true <==> current entity is updatable.
-- Later, Examine BULK_ROWCOUNT in a loop to determine updatable_flag
l_progress := '010';

-- bug3592160 START

-- For some records, po_header_id needs to be derived (e.g. document_num is
-- passed in instead of po_header_id). The following the procedure is to
-- fill out po_header_ids, if missing
complete_po_header_id_tbl
( p_count            => p_count,
  p_header_id        => p_header_id,
  p_release_id       => p_release_id,
  p_vendor_order_num => p_vendor_order_num,
  p_document_num     => p_document_num,
  p_type_lookup_code => p_document_subtype,
  x_header_id        => l_header_id
);

l_progress := '015';

-- The original approach was to do a fake UPDATE on DUAL table. However, this
-- is causing locking issue. Therefore, BULK INSERT is used instead of
-- BULK UPDATE
l_procedure_id := PO_CORE_S.get_session_gt_nextval;

FORALL i IN 1..p_count
  INSERT INTO PO_SESSION_GT
  ( key,
    num1
  )
  SELECT l_procedure_id,
         1                 -- Dummy Value
  FROM DUAL
  WHERE  (p_release_id(i) IS NOT NULL
      --Case 1: No Release is specified, PO Header has to be specified
      --   Through any of HeaderId, DocNum-and-SubType, or VendorOrderNum
      OR EXISTS (select null from po_headers_all h
        WHERE h.po_header_id = l_header_id(i)
        AND (h.authorization_status is NULL
             OR h.authorization_status NOT IN ('PRE-APPROVED', 'IN PROCESS'))
        AND (h.cancel_flag is null or h.cancel_flag <> 'Y')
        AND (h.closed_code is NULL or h.closed_code NOT IN ('FINALLY CLOSED'))
        AND (h.frozen_flag is NULL or h.frozen_flag <> 'Y')))
    AND (p_release_id(i) IS NULL
      --Case 2: PO Release is specified
      OR EXISTS (select null from po_releases_all h
        WHERE h.po_release_id = p_release_id(i)
        AND (h.authorization_status is NULL
             OR h.authorization_status NOT IN ('PRE-APPROVED', 'IN PROCESS'))
        AND (h.cancel_flag is null or h.cancel_flag <> 'Y')
        AND (h.closed_code is NULL or h.closed_code NOT IN ('FINALLY CLOSED'))
        AND (h.frozen_flag is NULL or h.frozen_flag <> 'Y')))
    AND (p_line_id(i) IS NULL
      --Case 3: Optionally, Line is specified
      OR EXISTS (SELECT null from po_lines_all l
        WHERE l.po_line_id = p_line_id(i)
        AND (l.cancel_flag is null or l.cancel_flag <> 'Y')
        AND (l.closed_code is NULL or l.closed_code NOT IN ('FINALLY CLOSED'))))
    AND (p_line_location_id(i) IS NULL
      --Case 4: Optionally, Line Location is specified
      OR EXISTS (SELECT null from po_line_locations_all l
        WHERE l.line_location_id = p_line_location_id(i)
        AND (l.cancel_flag is null or l.cancel_flag <> 'Y')
        AND (l.closed_code is NULL or l.closed_code NOT IN ('FINALLY CLOSED'))))    ;
-- bug3592160 END

-- Allocate memory for updatable_flag Table to p_count size
l_progress := '020';
x_po_status_rec.updatable_flag := po_tbl_varchar1();
x_po_status_rec.updatable_flag.extend(p_count);

-- Set Updatable_flag for each Entity using BULK_ROWCOUNT
l_progress := '030';
FOR i IN 1..p_count LOOP

    IF SQL%BULK_ROWCOUNT(i) > 0 THEN
        -- Updateable Header/Line/Shipment found in the fake "update dual" stmt
        x_po_status_rec.updatable_flag(i) := 'Y';

        -- This document is updatable, lock the document if p_lock_flag=Y
        l_progress := '040';
        IF p_lock_flag = 'Y' THEN
            IF p_release_id(i) is not null THEN
                l_document_id := p_release_id(i);
                l_document_type := 'RELEASE';
            ELSE
                l_document_id := p_header_id(i);
                IF p_document_type(i) is null THEN
                    l_document_type := 'PO';
                ELSE
                    l_document_type := p_document_type(i);
                END IF;
            END IF;
            PO_DOCUMENT_LOCK_GRP.LOCK_DOCUMENT (
                p_api_version => 1.0,
                P_INIT_MSG_LIST => FND_API.G_FALSE,
                P_DOCUMENT_TYPE => l_document_type,
                P_DOCUMENT_ID => l_document_id,
                x_return_status  => x_return_status);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                return;
            END IF;
        END IF;
    ELSE
        x_po_status_rec.updatable_flag(i) := 'N';
    END IF; --END of IF SQL%BULK_ROWCOUNT(i) > 0

END LOOP;

-- bug3592160 START
-- Remove everything that has been inserted into PO_SESSION_GT
DELETE FROM po_session_gt
WHERE key = l_procedure_id;
-- bug3592160 END

-- <PDOI Rewrite R12 START>
-- For all the documents being checked, we also need to make sure that
-- current draft status allows the document to be updated

FOR i IN 1..p_count LOOP
  l_progress := 40;
  IF (x_po_status_rec.updatable_flag(i) = 'Y' AND
      p_release_id(i) IS NULL) THEN

    PO_DRAFTS_PVT.update_permission_check
    ( p_calling_module => p_calling_module,
      p_po_header_id => p_header_id(i),
      p_role => l_role,
      p_skip_cat_upload_chk => l_skip_cat_upload_chk,
      x_update_allowed => l_update_allowed,
      x_locking_applicable => l_locking_applicable,
      x_unlock_required => l_unlock_required,
      x_message => l_message
    );

    IF (l_update_allowed = FND_API.G_FALSE) THEN
      x_po_status_rec.updatable_flag(i) := 'N';
    END IF;
  END IF;
END LOOP;

-- <PDOI Rewrite R12 END>


x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);

END check_updatable;

-------------------------------------------------------------------------------
--Start of Comments
--Name: check_reservable
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Finds if a PurchaseOrder/Release, or Line/Shipment is reservable based on status.
--  A Header or Release has to be specified. Line/Shipment are optional.
--  A Purchase Order/Release Header/Line/Shipment is reservable if
--    Authorization Status not APPROVED, AND Closed Code is CLOSED or OPEN,
--    AND Frozen Flag is N, AND User Hold Flag is N
--Parameters:
--IN:
--p_count
--  Specifies the number of entities in table IN parameters like p_header_id, p_release_id
--  Other IN parameters are detailed in main procedure po_status_check
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_po_status_rec
--  Table x_po_status_rec.updateable_flag will be 'Y' or 'N' for each input entity
--Notes:
--  The implementation of reservable_flag involves a fake "update dual" statement to
--    optimize performance.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE check_reservable (
    p_count               IN NUMBER,
    p_header_id           IN PO_TBL_NUMBER,
    p_release_id          IN PO_TBL_NUMBER,
    p_document_type       IN PO_TBL_VARCHAR30,
    p_document_subtype    IN PO_TBL_VARCHAR30,
    p_document_num        IN PO_TBL_VARCHAR30,
    p_vendor_order_num    IN PO_TBL_VARCHAR30,
    p_line_id             IN PO_TBL_NUMBER,
    p_line_location_id    IN PO_TBL_NUMBER,
    p_distribution_id     IN PO_TBL_NUMBER,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_po_status_rec       IN OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       IN OUT NOCOPY VARCHAR2
) IS

l_api_name       CONSTANT VARCHAR(30) := 'check_reservable';
l_progress       VARCHAR2(3) := '000';
l_document_id    PO_HEADERS.po_header_id%TYPE;
l_document_type  PO_DOCUMENT_TYPES.DOCUMENT_TYPE_CODE%TYPE;

-- bug3592160 START
l_header_id   PO_TBL_NUMBER;
l_procedure_id PO_SESSION_GT.key%TYPE;
-- bug3592160 END

BEGIN

IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

--To obtimize performance, Execute a fake "update dual" in BULK. The WHERE clause
-- of the fake update statement checks if the current entity is reservable or not.
-- One dual row updated <==> where clause is true <==> current entity is reservable.
-- Later, Examine BULK_ROWCOUNT in a loop to determine reservable_flag
l_progress := '010';

-- bug3592160 START

-- For some records, po_header_id needs to be derived (e.g. document_num is
-- passed in instead of po_header_id). The following the procedure is to
-- fill out po_header_ids, if missing
complete_po_header_id_tbl
( p_count            => p_count,
  p_header_id        => p_header_id,
  p_release_id       => p_release_id,
  p_vendor_order_num => p_vendor_order_num,
  p_document_num     => p_document_num,
  p_type_lookup_code => p_document_subtype,
  x_header_id        => l_header_id
);

l_progress := '015';


-- The original approach was to do a fake UPDATE on DUAL table. However, this
-- is causing locking issue. Therefore, BULK INSERT is used instead of
-- BULK UPDATE
l_procedure_id := PO_CORE_S.get_session_gt_nextval;

FORALL i IN 1..p_count
  INSERT INTO PO_SESSION_GT
  ( key,
    num1
  )
  SELECT l_procedure_id,
         1                 -- Dummy Value
  FROM DUAL
  WHERE (p_release_id(i) IS NOT NULL
      --Case 1: No Release is specified, PO Header has to be specified
      --   Through any of HeaderId, DocNum-and-SubType, or VendorOrderNum
      -- Bug 3407980: Modified closed_code condition so that it only discards 'FINALLY CLOSED'
      OR EXISTS (select null from po_headers_all h
        WHERE h.po_header_id = l_header_id(i)
        AND (h.authorization_status is NULL
             OR h.authorization_status NOT IN ('APPROVED'))
        AND (h.closed_code is NULL or h.closed_code <> 'FINALLY CLOSED')
        AND (h.frozen_flag is NULL or h.frozen_flag <> 'Y')
        AND (h.user_hold_flag is NULL or h.user_hold_flag <> 'Y')))
    AND (p_release_id(i) IS NULL
      --Case 2: PO Release is specified
      -- Bug 3407980: Modified closed_code condition so that it only discards 'FINALLY CLOSED'
      OR EXISTS (select null from po_releases_all h
        WHERE h.po_release_id = p_release_id(i)
        AND (h.authorization_status is NULL
             OR h.authorization_status NOT IN ('APPROVED'))
        AND (h.closed_code is NULL or h.closed_code <>  'FINALLY CLOSED')
        AND (h.frozen_flag is NULL or h.frozen_flag <> 'Y')
        AND (h.hold_flag is NULL or h.hold_flag <> 'Y')))
    AND (p_line_id(i) IS NULL
      --Case 3: Optionally, Line is specified
      -- Bug 3407980: Modified closed_code condition so that it only discards 'FINALLY CLOSED'
      OR EXISTS (SELECT null from po_lines_all l
        WHERE l.po_line_id = p_line_id(i)
        AND (l.closed_code is NULL or l.closed_code <> 'FINALLY CLOSED')))
    AND (p_line_location_id(i) IS NULL
      --Case 4: Optionally, Line Location is specified
      -- Bug 3407980: Modified closed_code condition so that it only discards 'FINALLY CLOSED'
      OR EXISTS (SELECT null from po_line_locations_all l
        WHERE l.line_location_id = p_line_location_id(i)
        AND (l.closed_code is NULL or l.closed_code <> 'FINALLY CLOSED')))
    ;

-- Allocate memory for reservable_flag Table to p_count size
l_progress := '020';
x_po_status_rec.reservable_flag := po_tbl_varchar1();
x_po_status_rec.reservable_flag.extend(p_count);

-- Set reservable_flag for each Entity using BULK_ROWCOUNT
l_progress := '030';
FOR i IN 1..p_count LOOP

    IF SQL%BULK_ROWCOUNT(i) > 0 THEN
        -- Reservable Header/Line/Shipment found in the fake "update dual" stmt
        x_po_status_rec.reservable_flag(i) := 'Y';
    ELSE
        x_po_status_rec.reservable_flag(i) := 'N';
    END IF; --END of IF SQL%BULK_ROWCOUNT(i) > 0

END LOOP;

-- bug3592160 START
-- Remove everything that has been inserted into PO_SESSION_GT
DELETE FROM po_session_gt
WHERE key = l_procedure_id;
-- bug3592160 END

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);

END check_reservable;

-------------------------------------------------------------------------------
--Start of Comments
--Name: check_unreservable
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Finds if a PurchaseOrder/Release, or Line/Shipment is unreservable based on status.
--  A Header or Release has to be specified. Line/Shipment are optional.
--  A Purchase Order/Release Header/Line/Shipment is unreservable if
--    Any Authorization Status, Closed Code is CLOSED or OPEN,
--    AND Frozen Flag is N, AND User Hold Flag is N
--Parameters:
--IN:
--p_count
--  Specifies the number of entities in table IN parameters like p_header_id, p_release_id
--  Other IN parameters are detailed in main procedure po_status_check
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_po_status_rec
--  Table x_po_status_rec.updateable_flag will be 'Y' or 'N' for each input entity
--Notes:
--  The implementation of unreservable_flag involves a fake "update dual" statement to
--    optimize performance.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE check_unreservable (
    p_count               IN NUMBER,
    p_header_id           IN PO_TBL_NUMBER,
    p_release_id          IN PO_TBL_NUMBER,
    p_document_type       IN PO_TBL_VARCHAR30,
    p_document_subtype    IN PO_TBL_VARCHAR30,
    p_document_num        IN PO_TBL_VARCHAR30,
    p_vendor_order_num    IN PO_TBL_VARCHAR30,
    p_line_id             IN PO_TBL_NUMBER,
    p_line_location_id    IN PO_TBL_NUMBER,
    p_distribution_id     IN PO_TBL_NUMBER,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_po_status_rec       IN OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       IN OUT NOCOPY VARCHAR2
) IS

l_api_name       CONSTANT VARCHAR(30) := 'check_unreservable';
l_progress       VARCHAR2(3) := '000';
l_document_id    PO_HEADERS.po_header_id%TYPE;
l_document_type  PO_DOCUMENT_TYPES.DOCUMENT_TYPE_CODE%TYPE;

-- bug3592160 START
l_header_id   PO_TBL_NUMBER;
l_procedure_id PO_SESSION_GT.key%TYPE;
-- bug3592160 END

BEGIN

IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

--To obtimize performance, Execute a fake "update dual" in BULK. The WHERE clause
-- of the fake update statement checks if the current entity is unreservable or not.
-- One dual row updated <==> where clause is true <==> current entity is unreservable.
-- Later, Examine BULK_ROWCOUNT in a loop to determine unreservable_flag
l_progress := '010';

-- bug3592160 START

-- For some records, po_header_id needs to be derived (e.g. document_num is
-- passed in instead of po_header_id). The following the procedure is to
-- fill out po_header_ids, if missing
complete_po_header_id_tbl
( p_count            => p_count,
  p_header_id        => p_header_id,
  p_release_id       => p_release_id,
  p_vendor_order_num => p_vendor_order_num,
  p_document_num     => p_document_num,
  p_type_lookup_code => p_document_subtype,
  x_header_id        => l_header_id
);

l_progress := '015';

-- SQL What: Checks if current PO Header/Line/Shipment is in unreservable status
-- The original approach was to do a fake UPDATE on DUAL table. However, this
-- is causing locking issue. Therefore, BULK INSERT is used instead of
-- BULK UPDATE
l_procedure_id := PO_CORE_S.get_session_gt_nextval;

FORALL i IN 1..p_count
  INSERT INTO PO_SESSION_GT
  ( key,
    num1
  )
  SELECT l_procedure_id,
         1                 -- Dummy Value
  FROM DUAL
  WHERE (p_release_id(i) IS NOT NULL
      --Case 1: No Release is specified, PO Header has to be specified
      --   Through any of HeaderId, DocNum-and-SubType, or VendorOrderNum
      -- Bug 3407980: Modified closed_code condition so that it only discards 'FINALLY CLOSED'
      OR EXISTS (select null from po_headers_all h
        WHERE h.po_header_id = l_header_id(i)
        AND (h.closed_code is NULL or h.closed_code <> 'FINALLY CLOSED')
        AND (h.frozen_flag is NULL or h.frozen_flag <> 'Y')
        AND (h.user_hold_flag is NULL or h.user_hold_flag <> 'Y')))
    AND (p_release_id(i) IS NULL
      --Case 2: PO Release is specified
      -- Bug 3407980: Modified closed_code condition so that it only discards 'FINALLY CLOSED'
      OR EXISTS (select null from po_releases_all h
        WHERE h.po_release_id = p_release_id(i)
        AND (h.closed_code is NULL or h.closed_code <> 'FINALLY CLOSED')
        AND (h.frozen_flag is NULL or h.frozen_flag <> 'Y')
        AND (h.hold_flag is NULL or h.hold_flag <> 'Y')))
    AND (p_line_id(i) IS NULL
      --Case 3: Optionally, Line is specified
      -- Bug 3407980: Modified closed_code condition so that it only discards 'FINALLY CLOSED'
      OR EXISTS (SELECT null from po_lines_all l
        WHERE l.po_line_id = p_line_id(i)
        AND (l.closed_code is NULL or l.closed_code <> 'FINALLY CLOSED')))
    AND (p_line_location_id(i) IS NULL
      --Case 4: Optionally, Line Location is specified
      -- Bug 3407980: Modified closed_code condition so that it only discards 'FINALLY CLOSED'
      OR EXISTS (SELECT null from po_line_locations_all l
        WHERE l.line_location_id = p_line_location_id(i)
        AND (l.closed_code is NULL or l.closed_code <> 'FINALLY CLOSED')))
    ;

-- Allocate memory for unreservable_flag Table to p_count size
l_progress := '020';
x_po_status_rec.unreservable_flag := po_tbl_varchar1();
x_po_status_rec.unreservable_flag.extend(p_count);

-- Set unreservable_flag for each Entity using BULK_ROWCOUNT
l_progress := '030';
FOR i IN 1..p_count LOOP

    IF SQL%BULK_ROWCOUNT(i) > 0 THEN
        -- Unreservable Header/Line/Shipment found in the fake "update dual" stmt
        x_po_status_rec.unreservable_flag(i) := 'Y';
    ELSE
        x_po_status_rec.unreservable_flag(i) := 'N';
    END IF; --END of IF SQL%BULK_ROWCOUNT(i) > 0

END LOOP;

-- bug3592160 START
-- Remove everything that has been inserted into PO_SESSION_GT
DELETE FROM po_session_gt
WHERE key = l_procedure_id;
-- bug3592160 END

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);

END check_unreservable;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_status
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Helper to po_status_check to find status of a Purchase Order/Release/Line/Shipment
--  The following status fields of PO Header or Release are put into
--     the OUT parameter x_po_status_rec
--   AUTHORIZATION_STATUS, APPROVED_FLAG, CLOSED_CODE, CANCEL_FLAG, FROZEN_FLAG, HOLD_FLAG
--  When an optional Line specified, following Line level values are overwritten
--   CLOSED_CODE, CANCEL_FLAG, HOLD_FLAG
--  When an optional Shipment specified, following Shipment level values are overwritten
--   APPROVED_FLAG, CLOSED_CODE, CANCEL_FLAG
--Parameters:
--IN:
--p_count
--  Specifies the number of entities in table IN parameters like p_header_id, p_release_id
--    All the table IN parameters are assumed to be of the same size
--  Other IN parameters are detailed in main procedure po_status_check
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_po_status_rec
--  The various status fields would have the PO/Rel Line/Shipment status values
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE get_status (
    p_count               IN NUMBER,
    p_header_id           IN PO_TBL_NUMBER,
    p_release_id          IN PO_TBL_NUMBER,
    p_document_type       IN PO_TBL_VARCHAR30,
    p_document_subtype    IN PO_TBL_VARCHAR30,
    p_document_num        IN PO_TBL_VARCHAR30,
    p_vendor_order_num    IN PO_TBL_VARCHAR30,
    p_line_id             IN PO_TBL_NUMBER,
    p_line_location_id    IN PO_TBL_NUMBER,
    p_distribution_id     IN PO_TBL_NUMBER,
    x_po_status_rec       IN OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       IN OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'GET_STATUS';
l_progress    VARCHAR2(3) := '000';
l_sequence    PO_TBL_NUMBER := PO_TBL_NUMBER();

BEGIN

IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

--Use sequence(i) to simulate i inside FORALL as direct reference to i is not allowed
--Initialize sequence array to contain 1,2,3, ..., p_count
l_progress := '010';
l_sequence.extend(p_count);
FOR i IN 1..p_count LOOP
  l_sequence(i) := i;
END LOOP;

l_progress := '020';

delete from po_headers_gt;

-- For all the entities with null p_release_id(i), get Header status fields into
-- global temprary table while storing sequence into po_headers_gt.PO_HEADER_ID column
l_progress := '030';
-- bug 4931241 modified the sql query to avoid FTS on PO_HEADERS_ALL
-- Removed the where clause for document num and vendor_order_num
-- They do not uniquely identify the document. Added validation in group package
FORALL i IN 1..p_count
    INSERT
      INTO po_headers_gt
      ( AGENT_ID, TYPE_LOOKUP_CODE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
        SEGMENT1, SUMMARY_FLAG, ENABLED_FLAG,
        authorization_status, approved_flag,
        closed_code, cancel_flag,
        frozen_flag, user_hold_flag, PO_HEADER_ID)
    SELECT
      AGENT_ID, TYPE_LOOKUP_CODE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
      SEGMENT1, SUMMARY_FLAG, ENABLED_FLAG,
      NVL(authorization_status, 'INCOMPLETE'), nvl(approved_flag, 'N'),
      nvl(closed_code, 'OPEN'), NVL(cancel_flag, 'N'),
      NVL(frozen_flag, 'N'), NVL(user_hold_flag, 'N'), l_sequence(i)
      FROM po_headers_all h
      WHERE p_release_id(i) is null
        AND h.po_header_id = p_header_id(i)
    ;

-- For all the entities with non-null p_release_id(i), get Relase status fields into
-- global temprary table while storing sequence into po_headers_gt.PO_HEADER_ID column
l_progress := '035';
FORALL i IN 1..p_count
    INSERT
      INTO po_headers_gt
      ( AGENT_ID, TYPE_LOOKUP_CODE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
        SEGMENT1, SUMMARY_FLAG, ENABLED_FLAG,
        authorization_status, approved_flag,
        closed_code, cancel_flag,
        frozen_flag, user_hold_flag, PO_HEADER_ID)
    SELECT
      0 dummy, ' ' dummy, LAST_UPDATE_DATE, LAST_UPDATED_BY,
      ' ' dummy, ' ' dummy, ' ' dummy,
      NVL(authorization_status, 'INCOMPLETE'), nvl(approved_flag, 'N'),
      nvl(closed_code, 'OPEN'), NVL(cancel_flag, 'N'),
      NVL(frozen_flag, 'N'), NVL(hold_flag, 'N'), l_sequence(i)
      FROM po_releases_all h
      WHERE h.po_release_id = p_release_id(i)
    ;

--IF line ID present at an index, overwrite the status fields with Line Level status
l_progress := '040';
FORALL i IN 1..p_count
    UPDATE po_headers_gt gt
      SET (closed_code, cancel_flag, user_hold_flag)
      =
      (SELECT nvl(closed_code, 'OPEN'), NVL(cancel_flag, 'N'), NVL(user_hold_flag, 'N')
      FROM po_lines_all s
      WHERE s.po_line_id = p_line_id(i))
    WHERE p_line_id(i) is not null and gt.po_header_id = l_sequence(i)
    ;

--IF line location present at an index, overwrite status fields with Shipment Level status
l_progress := '050';
FORALL i IN 1..p_count
    UPDATE po_headers_gt gt
      SET (approved_flag, closed_code, cancel_flag)
      =
      (SELECT nvl(approved_flag, 'N'), nvl(closed_code, 'OPEN'), NVL(cancel_flag, 'N')
      FROM po_line_locations_all s
      WHERE s.line_location_id = p_line_location_id(i))
    WHERE p_line_location_id(i) is not null and gt.po_header_id = l_sequence(i)
    ;

-- Fetch status fields from global temporary table into pl/sql table.
-- Order by sequence (stored in PO_HEADER_ID column) ensures
--   that input tables like p_header_id are in sync with
--   output status field tables like x_po_status_rec.authorization_status
l_progress := '060';
SELECT
  authorization_status, approved_flag, closed_code, cancel_flag, frozen_flag, user_hold_flag
BULK COLLECT INTO
  x_po_status_rec.authorization_status, x_po_status_rec.approval_flag, x_po_status_rec.closed_code,
  x_po_status_rec.cancel_flag, x_po_status_rec.frozen_flag, x_po_status_rec.hold_flag
FROM po_headers_gt
ORDER BY PO_HEADER_ID;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);

END get_status;

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
--  Finds the status of a Purchase Order or a Release. Refer to p_mode parameter
--  and PO_STATUS_REC_TYPE for various status information this procedure can find out.
--  A unique header OR Release has to be specified through various input combinations.
--  A line or shipment can optionally be specified to check status at that level also.
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_header_id
--  Specifies Purchase Order Header ID. This is ignored if p_release_id is not NULL
--p_release_id
--  Specifies Purchase Order Release ID.
--p_document_type
--  Specifies the document type: PA, PO, or RELEASE
--p_document_subtype
--  Specifies the document subtype.
--p_document_num
--  Document Number and Document Type together identify a unique document
--p_vendor_order_num
--  Document Vendor Order Number uniquely identifies a document
--p_line_id
--  Optionally Specifies Purchase Order Line ID to check status at line level
--p_line_location_id := NULL
--  Optionally Specifies Purchase Order Shipment ID to check status at shipment level
--p_distribution_id := NULL
--  Specifies Purchase Order Distribution ID, currently not used. May be used in future.
--p_mode
--  Indicates what status to check.
--    Can contain one or more of the following requests to check status
--      CHECK_UPDATEABLE to check if the current PO Header/Line/Shipment is updatable
--      GET_STATUS to return various statuses of the current PO Header/Release
--p_calling_module
--  To be used by updatalbe chk only.
--  String specifying where this API is calling from
--p_role
--  To be used by updatalbe chk only.
--  Role of the suer calling this API. (BUYER, SUPPLIER, CAT ADMIN, etc.)
--p_skip_cat_upload_chk
--  To be used by updatalbe chk only.
--  FND_API.G_TRUE if catalog upload status check should not be performed
--  FND_API.G_FALSE otherwise
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_po_status_rec
--  Contains the returned status elements
--  If p_mode contains CHECK_UPDATEABLE,
--    the updateable_flag would have 'Y' or 'N' for each entity in the Table
--  If p_mode contains GET_APPROVAL_STATUS,
--    the various status fields Header/Release/Line/Shipment status values
--Testing:
--  All the input table parameters should have the exact same length.
--    They may have null values at some indexes, but need to identify an entity uniquely
--  Call the API when only Requisition Exist, PO/Release Exist
--    and for all the combinations of attributes.
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

l_api_name    CONSTANT VARCHAR(30) := 'PO_STATUS_CHECK';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';
l_count       NUMBER;

BEGIN

IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

-- Standard call to check for call compatibility
l_progress := '010';
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '020'; -- Initialize Local/Output Variables
l_count := p_header_id.count;
x_po_status_rec := PO_STATUS_REC_TYPE(null, null, null, null, null, null, null, null, null);

l_progress := '030';

IF INSTR(p_mode, G_CHECK_UPDATEABLE) > 0 THEN --{

    check_updatable (
        p_count => l_count,
        p_header_id => p_header_id,
        p_release_id => p_release_id,
        p_document_type => p_document_type,
        p_document_subtype => p_document_subtype,
        p_document_num => p_document_num,
        p_vendor_order_num => p_vendor_order_num,
        p_line_id => p_line_id,
        p_line_location_id => p_line_location_id,
        p_distribution_id => p_distribution_id,
        p_lock_flag => p_lock_flag,
        p_calling_module   => p_calling_module,          -- PDOI Rewrite R12
        p_role             => p_role,                    -- PDOI Rewrite R12
        p_skip_cat_upload_chk => p_skip_cat_upload_chk,  -- PDOI Rewrite R12
        x_po_status_rec => x_po_status_rec,
        x_return_status  => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

END IF; --}END of IF INSTR(p_mode, G_CHECK_UPDATEABLE) > 0

l_progress := '033';

IF INSTR(p_mode, G_CHECK_RESERVABLE) > 0 THEN --{

    check_reservable (
        p_count => l_count,
        p_header_id => p_header_id,
        p_release_id => p_release_id,
        p_document_type => p_document_type,
        p_document_subtype => p_document_subtype,
        p_document_num => p_document_num,
        p_vendor_order_num => p_vendor_order_num,
        p_line_id => p_line_id,
        p_line_location_id => p_line_location_id,
        p_distribution_id => p_distribution_id,
        p_lock_flag => p_lock_flag,
        x_po_status_rec => x_po_status_rec,
        x_return_status  => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

END IF; --}END of IF INSTR(p_mode, G_CHECK_RESERVABLE) > 0

l_progress := '036';

IF INSTR(p_mode, G_CHECK_UNRESERVABLE) > 0 THEN --{

    check_unreservable (
        p_count => l_count,
        p_header_id => p_header_id,
        p_release_id => p_release_id,
        p_document_type => p_document_type,
        p_document_subtype => p_document_subtype,
        p_document_num => p_document_num,
        p_vendor_order_num => p_vendor_order_num,
        p_line_id => p_line_id,
        p_line_location_id => p_line_location_id,
        p_distribution_id => p_distribution_id,
        p_lock_flag => p_lock_flag,
        x_po_status_rec => x_po_status_rec,
        x_return_status  => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

END IF; --}END of IF INSTR(p_mode, G_CHECK_UNRESERVABLE) > 0

l_progress := '040';

IF INSTR(p_mode, G_GET_STATUS) > 0 THEN --{ Get Header/Release status fields

    get_status (
        p_count => l_count,
        p_header_id => p_header_id,
        p_release_id => p_release_id,
        p_document_type => p_document_type,
        p_document_subtype => p_document_subtype,
        p_document_num => p_document_num,
        p_vendor_order_num => p_vendor_order_num,
        p_line_id => p_line_id,
        p_line_location_id => p_line_location_id,
        p_distribution_id => p_distribution_id,
        x_po_status_rec => x_po_status_rec,
        x_return_status  => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

END IF; --}END of IF INSTR(p_mode, G_GET_STATUS) > 0

l_progress := '050';

IF x_return_status is null THEN -- no valid check status request specified
    FND_MESSAGE.set_name('PO', 'PO_STATCHK_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'No Valid p_mode specified !');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END IF;

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
--Name: check_unreserve
--Pre-reqs:
--  The global temp tables are populated with exactly those rows
--  that should undergo the checks.
--Modifies:
--  PO_ONLINE_REPORT_TEXT_GT
--Locks:
--  None.
--Function:
--  This procedure performs the document checks for an UNRESERVE action.
--Parameters:
--IN:
--p_online_report_id
--  ID used to insert into PO_ONLINE_REPORT_TEXT_GT.
--p_user_id
--  User performing the action.
--p_login_id
--  Last update login_id.
--IN OUT:
--p_sequence
--  Contains the running count of error messages inserted.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_unreserve(
   p_online_report_id               IN             NUMBER
,  p_document_type                  IN             VARCHAR2 --Bug#5462677
,  p_document_subtype               IN             VARCHAR2 --Bug#5462677
,  p_document_level                 IN             VARCHAR2 --Bug#5462677
,  p_doc_level_id                   IN             NUMBER   --Bug#5462677
,  p_user_id                        IN             NUMBER
,  p_login_id                       IN             NUMBER
,  p_sequence                       IN OUT NOCOPY  NUMBER
)
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'CHECK_UNRESERVE';
l_progress     VARCHAR2(3) := '000';

l_textline  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE := NULL;
l_ret_sts VARCHAR2(1);
BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_online_report_id',p_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_user_id',p_user_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_login_id',p_login_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_sequence',p_sequence);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type',p_document_type);
END IF;

l_progress := '010';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'UNRESERVE 1: Ship Qty billed greater than qty ordered');
END IF;

-- Check 1: Unreserve action not allowed if shipment quantity/amount billed is
-- greater than quantity/amount ordered
-- Bug# 1286701

l_progress := '040';

-- Perform the check.

INSERT INTO PO_ONLINE_REPORT_TEXT_GT
(  online_report_id
,  last_update_login
,  last_updated_by
,  last_update_date
,  created_by
,  creation_date
,  line_num
,  shipment_num
,  distribution_num
,  sequence
,  text_line
,  message_name
)
SELECT
   p_online_report_id
,  p_login_id
,  p_user_id
,  sysdate
,  p_user_id
,  sysdate
,  POL.line_num
,  POLL.shipment_num
,  0
,  p_sequence + ROWNUM
,  decode ( POL.quantity                                      -- <SERVICES FPJ>
          , NULL , PO_CORE_S.get_translated_text
                   (   'PO_SUB_SHIP_BILL_GT_ORD_AMT'
                   ,   'LINE_NUM' , POL.line_num
                   ,   'SHIP_NUM' , POLL.shipment_num
                   ,   'AMT_BILLED' , nvl(POLL.amount_billed, 0)
                   ,   'AMT_ORDERED' , nvl(POLL.amount, 0)
                   )
                 , PO_CORE_S.get_translated_text
                   (   'PO_SUB_SHIP_BILL_GT_ORD_QTY'
                   ,   'LINE_NUM' , POL.line_num
                   ,   'SHIP_NUM' , POLL.shipment_num
                   ,   'QTY_BILLED' , nvl(POLL.quantity_billed, 0)
                   ,   'QTY_ORDERED' , nvl(POLL.quantity, 0)
                   )
          )
,  decode ( POL.quantity                                      -- <SERVICES FPJ>
          , NULL , 'PO_SUB_SHIP_BILL_GT_ORD_AMT'
                 , 'PO_SUB_SHIP_BILL_GT_ORD_QTY'
          )
FROM
   PO_LINE_LOCATIONS_GT POLL
,  PO_LINES_ALL POL  -- For releases, PO_LINES_GT table isn't populated.
WHERE POLL.po_line_id = POL.po_line_id
AND   nvl(POLL.cancel_flag, 'N') = 'N'
AND   nvl(POLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
AND   (                                                       -- <SERVICES FPJ>
          --<Complex Work R12 START>: Use POLL value basis
          (   ( POLL.value_basis IN ('QUANTITY', 'AMOUNT') )
          AND (nvl(POLL.quantity_billed,0) > nvl(POLL.quantity,0) ) )
      OR  (   ( POLL.value_basis IN ('FIXED PRICE', 'RATE') )
          AND (nvl(POLL.amount_billed,0) > nvl(POLL.amount,0) ) )
          --<Complex Work R12 END>
      );

l_progress := '050';

--Increment the p_sequence with number of errors reported in last query
p_sequence := p_sequence + SQL%ROWCOUNT;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_sequence',p_sequence);
END IF;

--------------------------------------------------------

l_progress := '100';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'UNRESERVE 2: Dist qty billed greater than qty ordered');
END IF;

-- Check 2: Unreserve action not allowed if distribution quantity/amount billed
-- is greater than quantity/amount ordered

l_progress := '110';

-- Perform the check.

INSERT INTO PO_ONLINE_REPORT_TEXT_GT
(  online_report_id
,  last_update_login
,  last_updated_by
,  last_update_date
,  created_by
,  creation_date
,  line_num
,  shipment_num
,  distribution_num
,  sequence
,  text_line
,  message_name
)
SELECT
   p_online_report_id
,  p_login_id
,  p_user_id
,  sysdate
,  p_user_id
,  sysdate
,  POL.line_num
,  POLL.shipment_num
,  POD.distribution_num
,  p_sequence + ROWNUM
,  decode ( POL.quantity                                      -- <SERVICES FPJ>
          , NULL , PO_CORE_S.get_translated_text
                   (   'PO_SUB_DIST_BILL_GT_ORD_AMT'
                   ,   'LINE_NUM'    , POL.line_num
                   ,   'SHIP_NUM'    , POLL.shipment_num
                   ,   'DIST_NUM'    , POD.distribution_num
                   ,   'AMT_BILLED'  , nvl(POD.amount_billed, 0)
                   ,   'AMT_ORDERED' , nvl(POD.amount_ordered, 0)
                   )
                 , PO_CORE_S.get_translated_text
                   (   'PO_SUB_DIST_BILL_GT_ORD_QTY'
                   ,   'LINE_NUM'    , POL.line_num
                   ,   'SHIP_NUM'    , POLL.shipment_num
                   ,   'DIST_NUM'    , POD.distribution_num
                   ,   'QTY_BILLED'  , nvl(POD.quantity_billed, 0)
                   ,   'QTY_ORDERED' , nvl(POD.quantity_ordered, 0)
                   )
          )
,  decode ( POL.quantity                                      -- <SERVICES FPJ>
          , NULL , 'PO_SUB_DIST_BILL_GT_ORD_AMT'
                 , 'PO_SUB_DIST_BILL_GT_ORD_QTY'
          )
FROM
   PO_DISTRIBUTIONS_GT POD
,  PO_LINE_LOCATIONS_GT POLL
,  PO_LINES_ALL POL  -- For releases, PO_LINES_GT table isn't populated.
WHERE POD.line_location_id = POLL.line_location_id
AND   POL.po_line_id = POLL.po_line_id
AND   nvl(POLL.cancel_flag, 'N') = 'N'
AND   nvl(POLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
AND   (                                                       -- <SERVICES FPJ>
          (   ( POL.quantity IS NOT NULL )
          AND ( nvl(POD.quantity_billed,0) > nvl(POD.quantity_ordered,0) ) )
      OR  (   ( POL.amount IS NOT NULL )
          AND ( nvl(POD.amount_billed,0) > nvl(POD.amount_ordered,0) ) )
      );

l_progress := '150';

--Increment the p_sequence with number of errors reported in last query
p_sequence := p_sequence + SQL%ROWCOUNT;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_sequence',p_sequence);
END IF;

----------------------------------------------------------

l_progress := '200';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'UNRESERVE 3: Dist qty delivered greater than qty ordered');
END IF;

-- Check 3: Unreserve action not allowed if distribution quantity/amount
-- delivered is greater than the quantity/amount ordered

l_progress := '210';

-- Perform the check.

INSERT INTO PO_ONLINE_REPORT_TEXT_GT
(  online_report_id
,  last_update_login
,  last_updated_by
,  last_update_date
,  created_by
,  creation_date
,  line_num
,  shipment_num
,  distribution_num
,  sequence
,  text_line
,  message_name
)
SELECT
   p_online_report_id
,  p_login_id
,  p_user_id
,  sysdate
,  p_user_id
,  sysdate
,  POL.line_num
,  POLL.shipment_num
,  POD.distribution_num
,  p_sequence + ROWNUM
,  decode ( POL.quantity                                      -- <SERVICES FPJ>
          , NULL , PO_CORE_S.get_translated_text
                   (   'PO_SUB_DIST_DLVR_GT_ORD_AMT'
                   ,   'LINE_NUM'      , POL.line_num
                   ,   'SHIP_NUM'      , POLL.shipment_num
                   ,   'DIST_NUM'      , POD.distribution_num
                   ,   'AMT_DELIVERED' , nvl(POD.amount_delivered, 0)
                   ,   'AMT_ORDERED'   , nvl(POD.amount_ordered, 0)
                   )
                 , PO_CORE_S.get_translated_text
                   (   'PO_SUB_DIST_DLVR_GT_ORD_QTY'
                   ,   'LINE_NUM'      , POL.line_num
                   ,   'SHIP_NUM'      , POLL.shipment_num
                   ,   'DIST_NUM'      , POD.distribution_num
                   ,   'QTY_DELIVERED' , nvl(POD.quantity_delivered, 0)
                   ,   'QTY_ORDERED'   , nvl(POD.quantity_ordered, 0)
                   )
          )
,  decode ( POL.quantity                                      -- <SERVICES FPJ>
          , NULL , 'PO_SUB_DIST_DLVR_GT_ORD_AMT'
                 , 'PO_SUB_DIST_DLVR_GT_ORD_QTY'
          )
FROM
   PO_DISTRIBUTIONS_GT POD
,  PO_LINE_LOCATIONS_GT POLL
,  PO_LINES_ALL POL  -- For releases, PO_LINES_GT table isn't populated.
WHERE POD.line_location_id = POLL.line_location_id
AND   POL.po_line_id = POLL.po_line_id
AND   nvl(POLL.cancel_flag,'N') = 'N'
AND   nvl(POLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
AND   (                                                       -- <SERVICES FPJ>
          (   ( POL.quantity IS NOT NULL )
          AND ( nvl(POD.quantity_delivered,0) > nvl(POD.quantity_ordered,0) ) )
      OR  (   ( POL.amount IS NOT NULL )
          AND ( nvl(POD.amount_delivered,0) > nvl(POD.amount_ordered,0) ) )
      )
;

l_progress := '250';
-- Check 4: Check if there are unvalidated invoices/credit memo
-- BuG#5462677
-- Per Bug#4155351 p_origin_doc_id need to be passed only for finally close
-- "..PO will pass invoice_id during final close due to a final match. "
      check_unvalidated_invoices(
         p_document_type     => p_document_type
      ,  p_document_subtype  => p_document_subtype
      ,  p_action_requested  => g_action_UNRESERVE
      ,  p_action_date       => SYSDATE
      ,  p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_document_level    => p_document_level
      ,  p_origin_doc_id     => NULL
      ,  p_doc_level_id      => p_doc_level_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        --d_msg := 'check_unvalidated_invoices not successful';
        l_progress := 110;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;


l_progress := '260';

--Increment the p_sequence with number of errors reported in last query
p_sequence := p_sequence + SQL%ROWCOUNT;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_sequence',p_sequence);
END IF;

l_progress := '300';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END check_unreserve;




-------------------------------------------------------------------------------
--Start of Comments
--Name: populate_line_locations_gt
--Pre-reqs:
--  None.
--Modifies:
--  PO_LINE_LOCATIONS_GT
--Locks:
--  None.
--Function:
--  Populates the line locations GTT for submission checks.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of id that is being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id
--  Id of the doc level type of which to populate the table.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE populate_line_locations_gt(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
)
IS

l_log_head CONSTANT VARCHAR2(100) := g_log_head||'POPULATE_LINE_LOCATIONS_GT';
l_progress VARCHAR2(3) := '000';

l_line_location_id_tbl  po_tbl_number;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
END IF;

l_progress := '010';

PO_CORE_S.get_line_location_ids(
   p_doc_type => p_doc_type
,  p_doc_level => p_doc_level
,  p_doc_level_id_tbl => po_tbl_number( p_doc_level_id )
,  x_line_location_id_tbl => l_line_location_id_tbl
);

l_progress := '020';

FORALL i IN 1 .. l_line_location_id_tbl.COUNT
      INSERT INTO PO_LINE_LOCATIONS_GT (
         line_location_id     ,
         last_update_date      ,
         last_updated_by        ,
         po_header_id            ,
         po_line_id               ,
         last_update_login         ,
         creation_date              ,
         created_by                  ,
         quantity                     ,
         quantity_received             ,
         quantity_accepted              ,
         quantity_rejected               ,
         quantity_billed                  ,
         quantity_cancelled                ,
         amount,                                         -- <PO_CHANGE_API FPJ>
         amount_received,                                     -- <SERVICES FPJ>
         amount_accepted,                                     -- <SERVICES FPJ>
         amount_rejected,                                     -- <SERVICES FPJ>
         amount_billed,                                       -- <SERVICES FPJ>
         amount_cancelled,                                    -- <SERVICES FPJ>
         unit_meas_lookup_code              ,
         po_release_id                       ,
         ship_to_location_id                  ,
         ship_via_lookup_code                  ,
         need_by_date                           ,
         promised_date                           ,
         last_accept_date                         ,
         price_override                          ,
         encumbered_flag                        ,
         encumbered_date                         ,
         unencumbered_quantity                    ,
         fob_lookup_code                         ,
         freight_terms_lookup_code                ,
         taxable_flag                            ,
         estimated_tax_amount                    ,
         from_header_id                          ,
         from_line_id                             ,
         from_line_location_id                   ,
         start_date                               ,
         end_date                                ,
         lead_time                              ,
         lead_time_unit                          ,
         price_discount                           ,
         terms_id                                 ,
         approved_flag                            ,
         approved_date                            ,
         closed_flag                              ,
         cancel_flag                              ,
         cancelled_by                             ,
         cancel_date                              ,
         cancel_reason                            ,
         firm_status_lookup_code                  ,
         firm_date                                ,
         attribute_category                       ,
         attribute1                               ,
         attribute2                               ,
         attribute3                               ,
         attribute4                               ,
         attribute5                               ,
         attribute6                               ,
         attribute7                               ,
         attribute8                               ,
         attribute9                               ,
         attribute10                              ,
         unit_of_measure_class                    ,
         encumber_now                             ,
         attribute11                              ,
         attribute12                              ,
         attribute13                              ,
         attribute14                              ,
         attribute15                              ,
         inspection_required_flag                 ,
         receipt_required_flag                    ,
         qty_rcv_tolerance                       ,
         qty_rcv_exception_code                   ,
         enforce_ship_to_location_code            ,
         allow_substitute_receipts_flag           ,
         days_early_receipt_allowed               ,
         days_late_receipt_allowed                ,
         receipt_days_exception_code             ,
         invoice_close_tolerance                  ,
         receive_close_tolerance                  ,
         ship_to_organization_id                 ,
         shipment_num                            ,
         source_shipment_id                      ,
         shipment_type                     ,
         closed_code                        ,
         request_id                          ,
         program_application_id               ,
         program_id                            ,
         program_update_date                    ,
         government_context                      ,
         receiving_routing_id                     ,
         accrue_on_receipt_flag                  ,
         closed_reason                           ,
         closed_date                              ,
         closed_by                               ,
         org_id                                  ,
         global_attribute1                        ,
         global_attribute2                        ,
         global_attribute3                        ,
         global_attribute4                        ,
         global_attribute5                        ,
         global_attribute6                        ,
         global_attribute7                        ,
         global_attribute8                        ,
         global_attribute9                        ,
         global_attribute10                       ,
         global_attribute11                       ,
         global_attribute12                       ,
         global_attribute13                       ,
         global_attribute14                       ,
         global_attribute15                       ,
         global_attribute16                       ,
         global_attribute17                       ,
         global_attribute18                       ,
         global_attribute19                       ,
         global_attribute20                       ,
         global_attribute_category                ,
         quantity_shipped                        ,
         country_of_origin_code                   ,
         tax_user_override_flag                  ,
         match_option                            ,
         tax_code_id                              ,
         calculate_tax_flag                      ,
         change_promised_date_reason            ,
         note_to_receiver                        ,
         secondary_quantity                      ,
         secondary_unit_of_measure               ,
         preferred_grade                         ,
         secondary_quantity_received             ,
         secondary_quantity_accepted              ,
         secondary_quantity_rejected             ,
         secondary_quantity_cancelled             ,
         vmi_flag                                 ,
         consigned_flag                           ,
         retroactive_date                         ,
         payment_type                             , --<Complex Work R12>
         description                              , --<Complex Work R12>
         value_basis                                --<Complex Work R12>
     )
     SELECT
         line_location_id     ,
         last_update_date      ,
         last_updated_by        ,
         po_header_id            ,
         po_line_id               ,
         last_update_login         ,
         creation_date              ,
         created_by                  ,
         quantity                     ,
         quantity_received             ,
         quantity_accepted              ,
         quantity_rejected               ,
         quantity_billed                  ,
         quantity_cancelled                ,
         amount,                                         -- <PO_CHANGE_API FPJ>
         amount_received,                                     -- <SERVICES FPJ>
         amount_accepted,                                     -- <SERVICES FPJ>
         amount_rejected,                                     -- <SERVICES FPJ>
         amount_billed,                                       -- <SERVICES FPJ>
         amount_cancelled,                                    -- <SERVICES FPJ>
         unit_meas_lookup_code              ,
         po_release_id                       ,
         ship_to_location_id                  ,
         ship_via_lookup_code                  ,
         need_by_date                           ,
         promised_date                           ,
         last_accept_date                         ,
         price_override                          ,
         encumbered_flag                        ,
         encumbered_date                         ,
         unencumbered_quantity                    ,
         fob_lookup_code                         ,
         freight_terms_lookup_code                ,
         taxable_flag                            ,
         estimated_tax_amount                    ,
         from_header_id                          ,
         from_line_id                             ,
         from_line_location_id                   ,
         start_date                               ,
         end_date                                ,
         lead_time                              ,
         lead_time_unit                          ,
         price_discount                           ,
         terms_id                                 ,
         approved_flag                            ,
         approved_date                            ,
         closed_flag                              ,
         cancel_flag                              ,
         cancelled_by                             ,
         cancel_date                              ,
         cancel_reason                            ,
         firm_status_lookup_code                  ,
         firm_date                                ,
         attribute_category                       ,
         attribute1                               ,
         attribute2                               ,
         attribute3                               ,
         attribute4                               ,
         attribute5                               ,
         attribute6                               ,
         attribute7                               ,
         attribute8                               ,
         attribute9                               ,
         attribute10                              ,
         unit_of_measure_class                    ,
         encumber_now                             ,
         attribute11                              ,
         attribute12                              ,
         attribute13                              ,
         attribute14                              ,
         attribute15                              ,
         inspection_required_flag                 ,
         receipt_required_flag                    ,
         qty_rcv_tolerance                       ,
         qty_rcv_exception_code                   ,
         enforce_ship_to_location_code            ,
         allow_substitute_receipts_flag           ,
         days_early_receipt_allowed               ,
         days_late_receipt_allowed                ,
         receipt_days_exception_code             ,
         invoice_close_tolerance                  ,
         receive_close_tolerance                  ,
         ship_to_organization_id                 ,
         shipment_num                            ,
         source_shipment_id                      ,
         shipment_type                     ,
         closed_code                        ,
         request_id                          ,
         program_application_id               ,
         program_id                            ,
         program_update_date                    ,
         government_context                      ,
         receiving_routing_id                     ,
         accrue_on_receipt_flag                  ,
         closed_reason                           ,
         closed_date                              ,
         closed_by                               ,
         org_id                                  ,
         global_attribute1                        ,
         global_attribute2                        ,
         global_attribute3                        ,
         global_attribute4                        ,
         global_attribute5                        ,
         global_attribute6                        ,
         global_attribute7                        ,
         global_attribute8                        ,
         global_attribute9                        ,
         global_attribute10                       ,
         global_attribute11                       ,
         global_attribute12                       ,
         global_attribute13                       ,
         global_attribute14                       ,
         global_attribute15                       ,
         global_attribute16                       ,
         global_attribute17                       ,
         global_attribute18                       ,
         global_attribute19                       ,
         global_attribute20                       ,
         global_attribute_category                ,
         quantity_shipped                        ,
         country_of_origin_code                   ,
         tax_user_override_flag                  ,
         match_option                            ,
         tax_code_id                              ,
         calculate_tax_flag                      ,
         change_promised_date_reason            ,
         note_to_receiver                        ,
         secondary_quantity                      ,
         secondary_unit_of_measure               ,
         preferred_grade                         ,
         secondary_quantity_received             ,
         secondary_quantity_accepted              ,
         secondary_quantity_rejected             ,
         secondary_quantity_cancelled             ,
         vmi_flag                                 ,
         consigned_flag                           ,
         retroactive_date                         ,
         payment_type                             , --<Complex Work R12>
         description                              , --<Complex Work R12>
         value_basis                                --<Complex Work R12>
      FROM PO_LINE_LOCATIONS_ALL POLL
      WHERE POLL.line_location_id = l_line_location_id_tbl(i)
      ;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END populate_line_locations_gt;




-------------------------------------------------------------------------------
--Start of Comments
--Name: populate_distributions_gt
--Pre-reqs:
--  None.
--Modifies:
--  PO_DISTRIBTIONS_GT
--Locks:
--  None.
--Function:
--  Populates the distributions GTT for submission checks.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of id that is being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id
--  Id of the doc level type of which to populate the distributions table.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE populate_distributions_gt(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
)
IS

l_log_head CONSTANT VARCHAR2(100) := g_log_head||'POPULATE_DISTRIBUTIONS_GT';
l_progress VARCHAR2(3) := '000';

l_dist_id_tbl  po_tbl_number;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
END IF;

l_progress := '010';

IF (p_doc_type = g_document_type_REQUISITION) THEN

   l_progress := '020';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'requisition');
   END IF;

   populate_req_distributions_gt(
      p_document_id => p_doc_level_id
   );

   l_progress := '030';

ELSE

   l_progress := '040';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not requisition');
   END IF;

   PO_CORE_S.get_distribution_ids(
      p_doc_type => p_doc_type
   ,  p_doc_level => p_doc_level
   ,  p_doc_level_id_tbl => po_tbl_number( p_doc_level_id )
   ,  x_distribution_id_tbl => l_dist_id_tbl
   );

   l_progress := '050';

   FORALL i IN 1 .. l_dist_id_tbl.COUNT
   INSERT INTO PO_DISTRIBUTIONS_GT
   (
         po_distribution_id    ,
         last_update_date       ,
         last_updated_by         ,
         po_header_id             ,
         po_line_id                ,
         line_location_id           ,
         set_of_books_id            ,
         code_combination_id         ,
         quantity_ordered             ,
         amount_ordered,                                 -- <PO_CHANGE_API FPJ>
         last_update_login             ,
         creation_date                  ,
         created_by                      ,
         po_release_id                    ,
         quantity_delivered                ,
         quantity_billed                    ,
         quantity_cancelled                  ,
         amount_delivered,                                    -- <SERVICES FPJ>
         amount_billed                            ,
         amount_cancelled,                                    -- <SERVICES FPJ>
         req_header_reference_num             ,
         req_line_reference_num                ,
         req_distribution_id                    ,
         deliver_to_location_id                  ,
         deliver_to_person_id                    ,
         rate_date                               ,
         rate                                    ,
         accrued_flag                             ,
         encumbered_flag                          ,
         encumbered_amount                        ,
         unencumbered_quantity                    ,
         unencumbered_amount                      ,
         failed_funds_lookup_code                 ,
         gl_encumbered_date                       ,
         gl_encumbered_period_name                ,
         gl_cancelled_date                        ,
         destination_type_code                    ,
         destination_organization_id              ,
         destination_subinventory                ,
         attribute_category                       ,
         attribute1                               ,
         attribute2                               ,
         attribute3                               ,
         attribute4                               ,
         attribute5                               ,
         attribute6                               ,
         attribute7                               ,
         attribute8                               ,
         attribute9                               ,
         attribute10                              ,
         attribute11                              ,
         attribute12                              ,
         attribute13                              ,
         attribute14                              ,
         attribute15                              ,
         wip_entity_id                            ,
         wip_operation_seq_num                    ,
         wip_resource_seq_num                     ,
         wip_repetitive_schedule_id               ,
         wip_line_id                              ,
         bom_resource_id                          ,
         budget_account_id                        ,
         accrual_account_id                       ,
         variance_account_id                      ,
         prevent_encumbrance_flag                ,
         government_context                      ,
         destination_context                     ,
         distribution_num                  ,
         source_distribution_id             ,
         request_id                         ,
         program_application_id              ,
         program_id                           ,
         program_update_date                   ,
         project_id                             ,
         task_id                                 ,
         expenditure_type                         ,
         project_accounting_context              ,
         expenditure_organization_id              ,
         gl_closed_date                           ,
         accrue_on_receipt_flag                  ,
         expenditure_item_date                   ,
         org_id                                   ,
         kanban_card_id                           ,
         award_id                                ,
         mrc_rate_date                           ,
         mrc_rate                                 ,
         mrc_encumbered_amount                   ,
         mrc_unencumbered_amount                  ,
         end_item_unit_number                     ,
         tax_recovery_override_flag               ,
         recoverable_tax                          ,
         nonrecoverable_tax                       ,
         recovery_rate                            ,
         oke_contract_line_id                     ,
         oke_contract_deliverable_id
      ,  distribution_type
      ,  amount_to_encumber,
         global_attribute_category ,
         global_attribute1  ,
         global_attribute2  ,
         global_attribute3  ,
         global_attribute4  ,
         global_attribute5  ,
         global_attribute6  ,
         global_attribute7  ,
         global_attribute8  ,
         global_attribute9  ,
         global_attribute10 ,
         global_attribute11 ,
         global_attribute12 ,
         global_attribute13 ,
         global_attribute14 ,
         global_attribute15 ,
         global_attribute16 ,
         global_attribute17 ,
         global_attribute18 ,
         global_attribute19 ,
         global_attribute20
   )
   SELECT
         po_distribution_id    ,
         last_update_date       ,
         last_updated_by         ,
         po_header_id             ,
         po_line_id                ,
         line_location_id           ,
         set_of_books_id            ,
         code_combination_id         ,
         quantity_ordered             ,
         amount_ordered,                                 -- <PO_CHANGE_API FPJ>
         last_update_login             ,
         creation_date                  ,
         created_by                      ,
         po_release_id                    ,
         quantity_delivered                ,
         quantity_billed                    ,
         quantity_cancelled                  ,
         amount_delivered,                                    -- <SERVICES FPJ>
         amount_billed                            ,
         amount_cancelled,                                    -- <SERVICES FPJ>
         req_header_reference_num             ,
         req_line_reference_num                ,
         req_distribution_id                    ,
         deliver_to_location_id                  ,
         deliver_to_person_id                    ,
         rate_date                               ,
         rate                                    ,
         accrued_flag                             ,
         encumbered_flag                          ,
         encumbered_amount                        ,
         unencumbered_quantity                    ,
         unencumbered_amount                      ,
         failed_funds_lookup_code                 ,
         gl_encumbered_date                       ,
         gl_encumbered_period_name                ,
         gl_cancelled_date                        ,
         destination_type_code                    ,
         destination_organization_id              ,
         destination_subinventory                ,
         attribute_category                       ,
         attribute1                               ,
         attribute2                               ,
         attribute3                               ,
         attribute4                               ,
         attribute5                               ,
         attribute6                               ,
         attribute7                               ,
         attribute8                               ,
         attribute9                               ,
         attribute10                              ,
         attribute11                              ,
         attribute12                              ,
         attribute13                              ,
         attribute14                              ,
         attribute15                              ,
         wip_entity_id                            ,
         wip_operation_seq_num                    ,
         wip_resource_seq_num                     ,
         wip_repetitive_schedule_id               ,
         wip_line_id                              ,
         bom_resource_id                          ,
         budget_account_id                        ,
         accrual_account_id                       ,
         variance_account_id                      ,
         prevent_encumbrance_flag                ,
         government_context                      ,
         destination_context                     ,
         distribution_num                  ,
         source_distribution_id             ,
         request_id                         ,
         program_application_id              ,
         program_id                           ,
         program_update_date                   ,
         project_id                             ,
         task_id                                 ,
         expenditure_type                         ,
         project_accounting_context              ,
         expenditure_organization_id              ,
         gl_closed_date                           ,
         accrue_on_receipt_flag                  ,
         expenditure_item_date                   ,
         org_id                                   ,
         kanban_card_id                           ,
         award_id                                ,
         mrc_rate_date                           ,
         mrc_rate                                 ,
         mrc_encumbered_amount                   ,
         mrc_unencumbered_amount                  ,
         end_item_unit_number                     ,
         tax_recovery_override_flag               ,
         recoverable_tax                          ,
         nonrecoverable_tax                       ,
         recovery_rate                            ,
         oke_contract_line_id                     ,
         oke_contract_deliverable_id
      ,  distribution_type
      ,  amount_to_encumber,
         global_attribute_category ,
         global_attribute1  ,
         global_attribute2  ,
         global_attribute3  ,
         global_attribute4  ,
         global_attribute5  ,
         global_attribute6  ,
         global_attribute7  ,
         global_attribute8  ,
         global_attribute9  ,
         global_attribute10 ,
         global_attribute11 ,
         global_attribute12 ,
         global_attribute13 ,
         global_attribute14 ,
         global_attribute15 ,
         global_attribute16 ,
         global_attribute17 ,
         global_attribute18 ,
         global_attribute19 ,
         global_attribute20
   FROM PO_DISTRIBUTIONS_ALL POD
   WHERE POD.po_distribution_id = l_dist_id_tbl(i)
   ;

   l_progress := '060';

END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END populate_distributions_gt;




-------------------------------------------------------------------------------
--Start of Comments
--Name: check_gl_date
--Pre-reqs:
--  The global temp tables for the appropriate doc type
--  have been populated with all of the rows required for the check.
--  This should only be called if encumbrance is on.
--Modifies:
--  PO_ONLINE_REPORT_TEXT_GT
--Locks:
--  None.
--Function:
--  Checks that the GL date is usable (valid for GL and PO).
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_online_report_id
--  ID used to insert into PO_ONLINE_REPORT_TEXT_GT.
--p_user_id
--  User performing the action.
--p_login_id
--  Last update login_id.
--IN OUT:
--p_sequence
--  Contains the running count of error messages inserted.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_gl_date(
   p_doc_type                       IN             VARCHAR2
,  p_online_report_id               IN             NUMBER
,  p_login_id                       IN             NUMBER
,  p_user_id                        IN             NUMBER
,  p_sequence                       IN OUT NOCOPY  NUMBER
)
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'CHECK_GL_DATE';
l_progress     VARCHAR2(3) := '000';

l_msg_name     PO_ONLINE_REPORT_TEXT_GT.message_name%TYPE;
l_textline     PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;

l_date_tbl              po_tbl_date;
l_line_num_tbl          po_tbl_number;
l_shipment_num_tbl      po_tbl_number;
l_distribution_num_tbl  po_tbl_number;

l_period_name_tbl       po_tbl_varchar30;
l_period_year_tbl       po_tbl_number;
l_period_num_tbl        po_tbl_number;
l_quarter_num_tbl       po_tbl_number;
l_invalid_period_flag   VARCHAR2(1);

l_dates_key    NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_online_report_id',p_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_user_id',p_user_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_login_id',p_login_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_sequence',p_sequence);
END IF;

l_progress := '010';

-- Get the appropriate message.

/* Bug 3210344: refactored different messages into one message */
IF ((p_doc_type = g_document_type_REQUISITION) or
   (p_doc_type = g_document_type_RELEASE) or
   (p_doc_type = g_document_type_PO) or
   (p_doc_type = g_document_type_PA))
THEN
   l_msg_name := 'PO_PDOI_INVALID_GL_ENC_PER';
ELSE
   l_progress := '020';
   RAISE PO_CORE_S.g_INVALID_CALL_EXC;
END IF;

l_progress := '030';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_msg_name',l_msg_name);
END IF;

l_textline := FND_MESSAGE.get_string('PO',l_msg_name);

l_progress := '040';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_textline',l_textline);
END IF;

-- Get the dates to validate.

IF (p_doc_type = g_document_type_REQUISITION) THEN

   l_progress := '100';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'requisition');
   END IF;

   SELECT
      PRD.gl_encumbered_date
   ,  PRL.line_num
   ,  NULL
   ,  PRD.distribution_num
   BULK COLLECT INTO
      l_date_tbl
   ,  l_line_num_tbl
   ,  l_shipment_num_tbl
   ,  l_distribution_num_tbl
   FROM
      PO_REQ_DISTRIBUTIONS_GT PRD
   ,  PO_REQ_LINES_GT PRL
   ,  PO_REQ_HEADERS_GT PRH
   WHERE PRL.requisition_line_id = PRD.requisition_line_id  --JOIN
   AND   PRH.requisition_header_id = PRL.requisition_header_id  --JOIN
   AND   PRL.line_location_id IS NULL
   AND
      (  NVL(PRH.transferred_to_oe_flag,'N') <> 'Y'
      OR NVL(PRL.source_type_code,'VENDOR') <> 'INVENTORY'
      )
   AND   NVL(PRD.encumbered_flag,'N') = 'N'
   AND   NVL(PRD.prevent_encumbrance_flag,'N') <> 'Y' -- Bug 10428042
   AND   NVL(PRL.cancel_flag,'N') = 'N'
   AND   NVL(PRL.closed_code,'OPEN') <> 'FINALLY CLOSED'
   AND    Nvl(prl.modified_by_agent_flag,'N') = 'N' /*Bug 4882209*/
   ;

   l_progress := '110';

ELSE

   l_progress := '150';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not requisition');
   END IF;

   SELECT
      POD.gl_encumbered_date
   ,  POL.line_num
   ,  POLL.shipment_num
   ,  POD.distribution_num
   BULK COLLECT INTO
      l_date_tbl
   ,  l_line_num_tbl
   ,  l_shipment_num_tbl
   ,  l_distribution_num_tbl
   FROM
      PO_DISTRIBUTIONS_GT POD
   ,  PO_LINE_LOCATIONS_GT POLL
   ,  PO_LINES_ALL POL     -- For Releases, PO_LINES_GT doesn't get populated.
   ,  PO_HEADERS_GT POH
   WHERE POLL.line_location_id(+) = POD.line_location_id    --JOIN
   AND   POL.po_line_id(+) = POD.po_line_id                 --JOIN
      -- PA distributions don't have associated lines or shipments
   AND   POH.po_header_id = POD.po_header_id                --JOIN
   AND   NVL(POD.encumbered_flag,'N') = 'N'
   AND   NVL(POLL.cancel_flag,'N') = 'N'
   AND   NVL(POLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
   AND   NVL(POLL.approved_flag,'N') <> 'Y'
   AND   NVL(POD.prevent_encumbrance_flag,'N') <> 'Y' -- Bug 10428042
      -- Bug 8326256, Bug 8468327, Bug 8468328: For SHOP FLOOR destination type
      -- distributions the GL date validation should be skipped.
   AND   (NVL(POD.destination_type_code,'EXPENSE') <> 'SHOP FLOOR'  /* 8326256 */
           OR (NVL(POD.destination_type_code,'EXPENSE') = 'SHOP FLOOR'
                   AND (SELECT entity_type from wip_entities where wip_entity_id = POD.wip_entity_id)= 6))   /* Encumbrance project  */

   AND ( ( p_doc_type = g_document_type_PA
         AND POH.encumbrance_required_flag = 'Y'
         )
      OR ( p_doc_type <> g_document_type_PA )
      )
   ;

   l_progress := '160';

END IF;

l_progress := '200';

-- Validate the dates.

PO_PERIODS_SV.get_period_info(
   p_roll_logic => NULL
,  p_set_of_books_id => NULL
,  p_date_tbl => l_date_tbl
,  x_period_name_tbl => l_period_name_tbl
,  x_period_year_tbl => l_period_year_tbl
,  x_period_num_tbl => l_period_num_tbl
,  x_quarter_num_tbl => l_quarter_num_tbl
,  x_invalid_period_flag => l_invalid_period_flag
);

l_progress := '210';

IF (l_invalid_period_flag = FND_API.G_TRUE) THEN

   l_progress := '215';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'invalid period');
   END IF;

   -- Collect this information into the scratchpad,
   -- along with the info we need for error reporting.

   -----------------------------------------
   -- PO_SESSION_GT column mapping
   --
   -- num1     line_num
   -- num2     shipment_num
   -- num3     distribution_num
   -- char1    period_name
   -----------------------------------------

   SELECT PO_SESSION_GT_S.nextval
   INTO l_dates_key
   FROM DUAL
   ;

   l_progress := '220';

   FORALL i IN 1 .. l_period_name_tbl.COUNT
   INSERT INTO PO_SESSION_GT
   (  key
   ,  num1     -- line_num
   ,  num2     -- shipment_num
   ,  num3     -- distribution_num
   ,  char1    -- period_name
   )
   VALUES
   (  l_dates_key
   ,  l_line_num_tbl(i)
   ,  l_shipment_num_tbl(i)
   ,  l_distribution_num_tbl(i)
   ,  l_period_name_tbl(i)
   )
   ;

   l_progress := '230';

   -- Report the invalid dates.

   INSERT INTO PO_ONLINE_REPORT_TEXT_GT
   (  online_report_id
   ,  last_update_login
   ,  last_updated_by
   ,  last_update_date
   ,  created_by
   ,  creation_date
   ,  line_num
   ,  shipment_num
   ,  distribution_num
   ,  sequence
   ,  text_line
   ,  message_name
   )
   SELECT
      p_online_report_id
   ,  p_login_id
   ,  p_user_id
   ,  sysdate
   ,  p_user_id
   ,  sysdate
   ,  NVL(DATES.num1,0)    -- line_num
   ,  NVL(DATES.num2,0)    -- shipment_num
   ,  NVL(DATES.num3,0)    -- distribution_num
   ,  p_sequence + rownum
   ,  substr(
               DECODE(  DATES.num1  -- line_num
                     ,  NULL, ''
                     ,  g_linemsg||g_delim||TO_CHAR(DATES.num1)||g_delim
                     )
               ||
               DECODE(  DATES.num2  -- shipment_num
                     ,  NULL, ''
                     ,  g_shipmsg||g_delim||TO_CHAR(DATES.num2)||g_delim
                     )
               ||
               DECODE(  p_doc_type
                     ,  g_document_type_PA, ''
                     ,  g_distmsg||g_delim||TO_CHAR(DATES.num3)||g_delim
                     )

               ||l_textline

            ,  1
            ,  240
            )
   ,  l_msg_name
   FROM PO_SESSION_GT DATES
   WHERE DATES.key = l_dates_key
   AND   DATES.char1 IS NULL  -- period_name not found
   ;

   l_progress := '240';

   -- Increment the p_sequence with number of errors reported in last query
   p_sequence := p_sequence + SQL%ROWCOUNT;

   l_progress := '245';

   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_textline',p_sequence);
   END IF;

   l_progress := '250';

ELSE
   l_progress := '270';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'No invalid periods.');
   END IF;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_textline',p_sequence);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END check_gl_date;


-- bug3592160 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: complete_po_header_id_tbl
--Pre-reqs:
--  All the IN parameters should be initialized and populated with values.
--  All the table object type IN parameters should have the same number of
--  records
--  Org context should also be set before calling.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  For each record in the table objects pased in, derive po_header_id.
--Parameters:
--IN:
--p_count
--  Number of records in each of the table object
--p_header_id
--  Table Object containing po_header_id
--p_release_id
--  Table Object containing po_release_id
--p_vendor_order_num
--  Table Object containing vendor_order_num
--p_document_num
--  Table object containing document num (segment1)
--p_type_lookup_code
--  Table obejct containing type_lookup_code
--OUT:
--x_header_id
--  Contains the derived po_header_ids
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE complete_po_header_id_tbl
( p_count            IN NUMBER,
  p_header_id        IN PO_TBL_NUMBER,
  p_release_id       IN PO_TBL_NUMBER,
  p_vendor_order_num IN PO_TBL_VARCHAR30,
  p_document_num     IN PO_TBL_VARCHAR30,
  p_type_lookup_code IN PO_TBL_VARCHAR30,
  x_header_id        OUT NOCOPY PO_TBL_NUMBER
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'COMPLETE_PO_HEADER_ID_TBL';
l_log_head     CONSTANT VARCHAR2(100) := g_log_head|| l_api_name;
l_progress     VARCHAR2(3) := '000';

BEGIN

  IF g_debug_stmt THEN
     PO_DEBUG.debug_begin(l_log_head);
  END IF;

  x_header_id := PO_TBL_NUMBER();
  x_header_id.extend(p_count);

  l_progress := '010';

  FOR i IN 1..p_count LOOP
    IF (p_release_id(i) IS NOT NULL) THEN

      -- If p_release_id is not null, don't bother deriving po_header_id
      l_progress := '020';
      x_header_id(i) := NULL;
    ELSE
      IF p_header_id(i) IS NOT NULL THEN
        x_header_id(i) := p_header_id(i);
      END IF;

      l_progress := '030';

      IF (p_document_num(i) IS NOT NULL) THEN

        -- SQL What: Derive po_header_id based on document_num and
        --           type lookup_code. If x_header_id(i) already has value,
        --           validate it as well. If the po_header_id cannot be found,
        --           set x_header_id(i) as -999, indicating that po_header_Id
        --           cannot be derived by the IN paramters
        SELECT NVL(MIN(po_header_id), '-999')
        INTO   x_header_id(i)
        FROM   po_headers
        WHERE  segment1 = p_document_num(i)
        AND    type_lookup_code = p_type_lookup_code(i)
        AND    po_header_id = NVL(x_header_id(i), po_header_id);

        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,
                               'After checking document_num. id = ' || x_header_id(i));
        END IF;
      END IF;

      l_progress := '040';

      IF (p_vendor_order_num(i) IS NOT NULL) THEN

        -- SQL What: Derive po_header_id based on vendor_order_num and
        --           type lookup_code. If x_header_id(i) already has value,
        --           validate it as well. If the po_header_id cannot be found,
        --           set x_header_id(i) as -999, indicating that po_header_Id
        --           cannot be derived by the IN paramters
        SELECT NVL(MIN(po_header_id), '-999')
        INTO x_header_id(i)
        FROM   po_headers_all
        WHERE  vendor_order_num = p_vendor_order_num(i)
        AND  po_header_id = NVL(x_header_id(i), po_header_id);

        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,
                               'After checking vendor_order_num. id = ' || x_header_id(i));
        END IF;
      END IF;

    END IF;

    l_progress := '050';

    IF (x_header_id(i) = -999) THEN
      x_header_id(i) := NULL;
    END IF;

    IF g_debug_stmt THEN
       PO_DEBUG.debug_stmt(l_log_head,l_progress,
                           'Final ID for rec ' ||i|| '= ' || x_header_id(i));
    END IF;

  END LOOP;

  IF g_debug_stmt THEN
     PO_DEBUG.debug_end(l_log_head);
  END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END complete_po_header_id_tbl;
-- bug3592160 END

--<JFMIP Vendor Registration FPJ Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: check_vendor_site_ccr_regis
--Pre-reqs:
--  None
--Modifies:
--  po_online_report_text_gt
--Locks:
--  None.
--Function:
-- This procedure is used to perform the submission check related to CCR
-- registration status of a vendor site. The resulting error (if any) is
-- stored in the global temp table
--Parameters:
--IN:
--p_document_id
--  po_header_id of a Purchase Order or Purchase Agreement
--p_online_report_id
--  unique error report id
--p_user_id
--  user id
--p_login_id
--  login id
--IN OUT:
--p_sequence
--  maintains a count of total number of submission check errors/warnings
--OUT:
--x_return_status
--  return status of the procedure. Possible values are
--  FND_API.G_RET_STS_SUCCESS and FND_API.G_RET_STS_UNEXP_ERROR
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_vendor_site_ccr_regis(
  p_document_id        IN NUMBER,
  p_online_report_id   IN NUMBER,
  p_user_id            IN NUMBER,
  p_login_id           IN NUMBER,
  p_sequence           IN OUT NOCOPY NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2)
IS
  l_api_name           CONSTANT VARCHAR2(30) := 'CHECK_VENDOR_SITE_CCR_REGIS';
  l_progress           VARCHAR2(3);

  l_vendor_id          PO_HEADERS.vendor_id%TYPE;
  l_vendor_site_id     PO_HEADERS.vendor_site_id%TYPE;
  l_valid_registration BOOLEAN := FALSE;

  l_text_line           PO_ONLINE_REPORT_TEXT.text_line%TYPE := NULL;

BEGIN

  l_progress := '000';
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
             || l_progress, ' Before retrieving vendor/vendor site info');
     END IF;
  END IF;

  -- SQL What: retrieves vendor id and vendor site id from the document header
  -- SQL Why:  need to check vendor site registration status below
  BEGIN
    SELECT    vendor_id, vendor_site_id
    INTO      l_vendor_id, l_vendor_site_id
    FROM      po_headers_all
    WHERE     po_header_id = p_document_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  l_progress := '010';
  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
             || l_progress, ' After retrieving vendor/vendor site info');
     END IF;
  END IF;

  IF (l_vendor_id IS NOT NULL) AND (l_vendor_site_id IS NOT NULL) THEN

     -- Call PO_FV_INTEGRATION_PVT.val_vendor_site_ccr_regis to check the
     -- Central Contractor Registration(CCR) status of the vendor site

     l_progress := '020';
     IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
         || l_progress, ' Before validating vendor site registration');
     END IF;
     END IF;

     l_valid_registration := PO_FV_INTEGRATION_PVT.val_vendor_site_ccr_regis(
                          p_vendor_id      => l_vendor_id,
                          p_vendor_site_id => l_vendor_site_id);

     IF NOT l_valid_registration THEN

        l_progress := '030';
        IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
              l_api_name||'.' || l_progress,
              ' Vendor site registration is not valid');
            END IF;
        END IF;

        l_text_line := FND_MESSAGE.get_string('PO', 'PO_VENDOR_SITE_CCR_INVALID');
        INSERT INTO po_online_report_text_gt
                (online_report_id
                ,last_updated_by
                ,last_update_date
                ,created_by
                ,creation_date
                ,line_num
                ,shipment_num
                ,distribution_num
                ,sequence
                ,text_line
                ,message_name)
         VALUES
                (p_online_report_id
                ,p_login_id
                ,sysdate
                ,p_user_id
                ,sysdate
                ,0 ,0 ,0
                ,p_sequence+1
                ,substr(l_text_line,1,240)
                ,'PO_VENDOR_SITE_CCR_INVALID');

          -- Increment p_sequence by 1
          p_sequence := p_sequence+1;
     ELSE -- l_valid_registration is TRUE
         l_progress := '040';
         IF g_debug_stmt THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                l_api_name||'.' || l_progress,
                ' Vendor site registration is valid');
            END IF;
         END IF;
     END IF; -- l_valid_registration check
  END IF; -- l_vendor_id and l_vendor_site_id check

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (g_debug_unexp) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.level_unexpected,
                       G_PKG_NAME||l_api_name|| '.others_exception',
                       'EXCEPTION: Location is '|| l_progress ||' SQL CODE is '||sqlcode);
        END IF;
     END IF;

END check_vendor_site_ccr_regis;
--<JFMIP Vendor Registration FPJ End>


-- <Doc Manager Rewrite 11.5.11 Start>
PROCEDURE check_final_close(
   p_document_type        IN VARCHAR2
,  p_document_subtype     IN VARCHAR2
,  p_document_level       IN VARCHAR2
,  p_document_id          IN NUMBER
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_origin_doc_id        IN NUMBER := NULL --Bug#5462677
,  p_doc_level_id         IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
)
IS

d_module    VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_final_close';
d_progress  NUMBER;
d_msg       VARCHAR2(200);

l_is_complex_po     BOOLEAN;  -- <Bug#16498663>
l_ret_sts           VARCHAR2(1);

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_document_level', p_document_level);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_sequence', p_sequence);
  END IF;

  BEGIN

    d_progress := 10;

    IF (((p_document_type = g_document_type_PO) AND (p_document_subtype = 'STANDARD'))
         OR (p_document_type = g_document_type_RELEASE))
    THEN

      d_progress := 20;

      check_rcv_trans_interface(
         p_document_type     => p_document_type
      ,  p_document_level    => p_document_level
      ,  p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_document_id       => p_document_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        d_msg := 'check_rcv_trans_interface not successful';
        d_progress := 30;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      d_progress := 40;

      check_asn_not_fully_received(
         p_document_type     => p_document_type
      ,  p_document_level    => p_document_level    --<Bug 9012072, Added the p_document_level IN parameter
      ,  p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        d_msg := 'check_asn_not_fully_received not successful';
        d_progress := 50;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      d_progress := 60;

      check_qty_rcv_but_not_deliv(
         p_document_type     => p_document_type
      ,  p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        d_msg := 'check_qty_rcv_but_not_deliv not successful';
        d_progress := 70;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      d_progress := 80;

      check_amt_rcv_but_not_deliv(
         p_document_type     => p_document_type
      ,  p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        d_msg := 'check_amt_rcv_but_not_deliv not successful';
        d_progress := 90;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

	  d_progress := 90;

	  check_enc_amt(
        p_document_level    => p_document_level    --<Bug 9012072, Added the p_document_level IN parameter
      ,  p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

	  IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        d_msg := 'encumbered amount check not successful';
        d_progress := 95;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

	  -- <<Bug#16498663 Start>>
	  -- Finally close is not allowed for Complex PO when the
	  -- total amount financed is not completely recouped.
	  d_progress := 100;

      -- Start BUG 16858759: Do not need to call is_complex_work_po procedure
      -- if the current document type is Release.
      IF (p_document_type <> g_document_type_RELEASE) THEN
           l_is_complex_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(p_document_id);
      END IF;
      -- End BUG 16858759

	  IF (l_is_complex_po) THEN
		  check_amt_fin_not_fully_rec(
			 p_document_level    => p_document_level
		  ,  p_online_report_id  => p_online_report_id
		  ,  p_user_id           => p_user_id
		  ,  p_login_id          => p_login_id
		  ,  p_sequence          => p_sequence
		  ,  x_return_status     => l_ret_sts
		  );

		  IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
			d_msg := 'check_amt_fin_not_fully_rec not successful';
			d_progress := 110;
			RAISE PO_CORE_S.g_early_return_exc;
		  END IF;
	  END IF;

	  -- <<Bug#16498663 End>>

      d_progress := 120;

      check_invalid_acct_flex(
         p_document_type     => p_document_type
      ,  p_action_requested  => g_action_FINAL_CLOSE_CHECK
      ,  p_action_date       => SYSDATE
      ,  p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_document_id       => p_document_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        d_msg := 'check_invalid_acct_flex not successful';
        d_progress := 130;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      -- Bug#5462677
      d_progress := 140;

      check_unvalidated_invoices(
         p_document_type     => p_document_type
      ,  p_document_subtype  => p_document_subtype
      ,  p_action_requested  => g_action_FINAL_CLOSE_CHECK
      ,  p_action_date       => SYSDATE
      ,  p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_document_level    => p_document_level --Bug#5462677
      ,  p_origin_doc_id     => p_origin_doc_id  --Bug#5462677
      ,  p_doc_level_id      => p_doc_level_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        d_msg := 'check_unvalidated_invoices not successful';
        d_progress := 150;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    ELSIF ((p_document_type = g_document_type_PO) AND (p_document_subtype = 'PLANNED'))
    THEN

      d_progress := 200;

      check_invalid_acct_flex(
         p_document_type     => p_document_type
      ,  p_action_requested  => g_action_FINAL_CLOSE_CHECK
      ,  p_action_date       => SYSDATE
      ,  p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_document_id       => p_document_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        d_msg := 'check_invalid_acct_flex not successful';
        d_progress := 210;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      d_progress := 220;

      check_ppo_has_open_release(
         p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        d_msg := 'check_ppo_has_open_release not successful';
        d_progress := 230;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    ELSIF ((p_document_type = g_document_type_PA) AND (p_document_subtype = 'BLANKET'))
    THEN

      d_progress := 300;

      check_bpa_has_open_release(
         p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        d_msg := 'check_bpa_has_open_release not successful';
        d_progress := 310;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

      d_progress := 320;

      check_bpa_has_open_stdref(
         p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        d_msg := 'check_bpa_has_open_stdref not successful';
        d_progress := 330;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    ELSIF ((p_document_type = g_document_type_PA) AND (p_document_subtype = 'CONTRACT'))
    THEN

      d_progress := 400;

      check_cpa_has_open_stdref(
         p_online_report_id  => p_online_report_id
      ,  p_user_id           => p_user_id
      ,  p_login_id          => p_login_id
      ,  p_sequence          => p_sequence
      ,  x_return_status     => l_ret_sts
      );

      IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
        d_msg := 'check_cpa_has_open_stdref not successful';
        d_progress := 410;
        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    END IF;  -- p_document_type = ...

    l_ret_sts := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
      l_ret_sts := FND_API.G_RET_STS_UNEXP_ERROR;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION

  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END check_final_close;


-- Determine if there are any receiving transactions in the
-- receiving interface that have not yet been processed
PROCEDURE check_rcv_trans_interface(
   p_document_type        IN VARCHAR2
,  p_document_level       IN VARCHAR2  --<Bug 4118145, Issue 7>: Corrected type
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_document_id          IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
)
IS

l_textline  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;
l_ret_sts   VARCHAR2(1);
l_is_complex_po     boolean;
l_token_value VARCHAR2(256);

d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_rcv_trans_interface';
d_progress NUMBER;
d_msg      VARCHAR2(60);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_level', p_document_level);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_sequence', p_sequence);
  END IF;

  BEGIN

    IF (p_document_level = g_document_level_HEADER)
    THEN

      IF (p_document_type <> g_document_type_RELEASE)
      THEN

        d_progress := 10;

        l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_POH_WITH_RCV_TRX');

        INSERT INTO PO_ONLINE_REPORT_TEXT_GT
        (  online_report_id
        ,  last_update_login
        ,  last_updated_by
        ,  last_update_date
        ,  created_by
        ,  creation_date
        ,  line_num
        ,  shipment_num
        ,  distribution_num
        ,  sequence
        ,  text_line
        ,  message_name
        )
        SELECT
           p_online_report_id
        ,  p_login_id
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  0
        ,  0
        ,  0
        ,  p_sequence + ROWNUM
        ,  substr(l_textline, 1, 240)
        ,  'PO_CAN_POH_WITH_RCV_TRX'
        FROM po_headers_gt poh
        WHERE EXISTS
          (
            SELECT 'Eligible shipment'
            FROM po_line_locations_gt poll
            WHERE poll.po_header_id = poh.po_header_id
              AND NVL(poll.cancel_flag, 'N') = 'N'
              AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
          )
          AND EXISTS
          (
            SELECT 'Transaction to process'
            FROM rcv_transactions_interface rti
            WHERE rti.processing_status_code = 'PENDING'
              AND rti.po_header_id = poh.po_header_id
          );

        d_progress := 15;

      ELSE

        d_progress := 20;

        l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_REL_WITH_RCV_TRX');

        INSERT INTO PO_ONLINE_REPORT_TEXT_GT
        (  online_report_id
        ,  last_update_login
        ,  last_updated_by
        ,  last_update_date
        ,  created_by
        ,  creation_date
        ,  line_num
        ,  shipment_num
        ,  distribution_num
        ,  sequence
        ,  text_line
        ,  message_name
        )
        SELECT
           p_online_report_id
        ,  p_login_id
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  0
        ,  0
        ,  0
        ,  p_sequence + ROWNUM
        ,  substr(l_textline, 1, 240)
        ,  'PO_CAN_REL_WITH_RCV_TRX'
        FROM po_releases_gt por
        WHERE EXISTS
          (
            SELECT 'Eligible shipment'
            FROM po_line_locations_gt poll
            WHERE poll.po_release_id = por.po_release_id
              AND NVL(poll.cancel_flag, 'N') = 'N'
              AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
          )
          AND EXISTS
          (
            SELECT 'Transaction to process'
            FROM rcv_transactions_interface rti
            WHERE rti.processing_status_code = 'PENDING'
              AND rti.po_release_id = por.po_release_id
          );

        d_progress := 25;

      END IF;  -- p_document_type = ...

    ELSIF (p_document_level = g_document_level_LINE)
    THEN

      d_progress := 30;

      l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_POL_WITH_RCV_TRX');

      INSERT INTO PO_ONLINE_REPORT_TEXT_GT
      (  online_report_id
      ,  last_update_login
      ,  last_updated_by
      ,  last_update_date
      ,  created_by
      ,  creation_date
      ,  line_num
      ,  shipment_num
      ,  distribution_num
      ,  sequence
      ,  text_line
      ,  message_name
      )
      SELECT
         p_online_report_id
      ,  p_login_id
      ,  p_user_id
      ,  SYSDATE
      ,  p_user_id
      ,  SYSDATE
      ,  pol.line_num
      ,  0
      ,  0
      ,  p_sequence + ROWNUM
      ,  substr(g_linemsg || g_delim || pol.line_num || g_delim || l_textline, 1, 240)
      ,  'PO_CAN_POL_WITH_RCV_TRX'
      FROM po_lines_gt pol
      WHERE EXISTS
        (
          SELECT 'Eligible shipment'
          FROM po_line_locations_gt poll
          WHERE poll.po_line_id = pol.po_line_id
            AND NVL(poll.cancel_flag, 'N') = 'N'
            AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
        )
        AND EXISTS
        (
          SELECT 'Transaction to process'
          FROM rcv_transactions_interface rti
          WHERE rti.processing_status_code = 'PENDING'
            AND rti.po_line_id = pol.po_line_id
        );

      d_progress := 40;


    ELSIF (p_document_level = g_document_level_SHIPMENT)
    THEN

      d_progress := 50;

      IF (p_document_type <> g_document_type_RELEASE)
      THEN
        l_is_complex_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(p_document_id);

        IF (l_is_complex_po) THEN
          l_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_LINE_LOC_TYPE_LOW_P_PAYITEM');
        ELSE
          l_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_LINE_LOC_TYPE_LOWER_S_SCH');
        END IF;

        FND_MESSAGE.SET_NAME('PO','PO_CAN_POLL_WITH_RCV_TRX');
        FND_MESSAGE.SET_TOKEN('LINE_LOCATION_TYPE', l_token_value);

        l_textline := FND_MESSAGE.GET;
      ELSE
        l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_RELS_WITH_RCV_TRX');
      END IF;


/*Bug 9012072 START--->Determine if there are any receiving transactions that have not been fully received for the shipments
       of the PO or Release Shipments being finally closed*/

      IF (p_document_type <> g_document_type_RELEASE)
      THEN

        INSERT INTO PO_ONLINE_REPORT_TEXT_GT
        (  online_report_id
        ,  last_update_login
        ,  last_updated_by
        ,  last_update_date
        ,  created_by
        ,  creation_date
        ,  line_num
        ,  shipment_num
        ,  distribution_num
        ,  sequence
        ,  text_line
        ,  message_name
        )
        SELECT
           p_online_report_id
        ,  p_login_id
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  pol.line_num
        ,  poll.shipment_num
        ,  0
        ,  p_sequence + ROWNUM
        ,  substr(g_linemsg || g_delim || pol.line_num || g_delim || g_shipmsg || g_delim || poll.shipment_num || g_delim || l_textline, 1, 240)
        ,  'PO_CAN_POLL_WITH_RCV_TRX'
        FROM po_lines_gt pol, po_line_locations_gt poll
        WHERE pol.po_line_id = poll.po_line_id
          AND NVL(poll.cancel_flag, 'N') = 'N'
          AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
          AND EXISTS
          (
            SELECT 'Transaction to process'
            FROM rcv_transactions_interface rti
            WHERE rti.processing_status_code = 'PENDING'
              AND rti.po_line_location_id = poll.line_location_id
          );

      ELSE

        INSERT INTO PO_ONLINE_REPORT_TEXT_GT
        (  online_report_id
        ,  last_update_login
        ,  last_updated_by
        ,  last_update_date
        ,  created_by
        ,  creation_date
        ,  line_num
        ,  shipment_num
        ,  distribution_num
        ,  sequence
        ,  text_line
        ,  message_name
        )
        SELECT
           p_online_report_id
        ,  p_login_id
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  0
        ,  poll.shipment_num
        ,  0
        ,  p_sequence + ROWNUM
        ,  substr(g_shipmsg || g_delim || poll.shipment_num || g_delim || l_textline, 1, 240)
        ,  'PO_CAN_RELS_WITH_RCV_TRX'
        FROM    po_line_locations_gt poll
        WHERE   EXISTS
               (
                  SELECT 'Eligible shipment'
                  FROM    po_releases_gt por
                  WHERE   por.po_release_id = poll.po_release_id
                          AND NVL(por.cancel_flag, 'N') = 'N'
                          AND NVL(por.closed_code, 'OPEN') <> 'FINALLY CLOSED'
               )
               AND EXISTS
               (
                 SELECT 'Transaction to process'
                 FROM   rcv_transactions_interface rti
                 WHERE  rti.processing_status_code = 'PENDING'
                        AND rti.po_line_location_id = poll.line_location_id
               );

      END IF;

      /*Bug 9012072 END--->Determine if there are any receiving transactions that have not been fully received for the shipments
       of the PO or Release Shipments being finally closed*/


      d_progress := 60;

    ELSE

      d_progress := 70;
      d_msg := 'Bad document level';
      l_ret_sts := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- if p_document_level = ...

    p_sequence := p_sequence + SQL%ROWCOUNT;
    l_ret_sts := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END check_rcv_trans_interface;

/*Bug 9012072 START--->Modified the check_asn_not_fully_received procedure*/

-- Deterimine if there are any ASN that have not been fully received
PROCEDURE check_asn_not_fully_received(
   p_document_type        IN VARCHAR2
,  p_document_level       IN VARCHAR2
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
)
IS

l_textline  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;
l_ret_sts   VARCHAR2(1);

l_text_normal_po  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;
l_text_complex_po  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;

d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_asn_not_fully_received';
d_progress NUMBER;
d_msg      VARCHAR2(60);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_sequence', p_sequence);
  END IF;

  d_progress := 5;

 /*Bug 9012072 START Determine if there are any ASNs that have not been fully received for the shipments of the
  PO or Release being finally closed.*/

    IF (p_document_level = g_document_level_HEADER)
    THEN

      IF (p_document_type <> g_document_type_RELEASE)
      THEN

        d_progress := 10;

         l_text_normal_po := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_POLL_WITH_ASN');
         l_text_complex_po := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_POLL_WITH_PENDING_WCR');

        INSERT INTO PO_ONLINE_REPORT_TEXT_GT
        (  online_report_id
        ,  last_update_login
        ,  last_updated_by
        ,  last_update_date
        ,  created_by
        ,  creation_date
        ,  line_num
        ,  shipment_num
        ,  distribution_num
        ,  sequence
        ,  text_line
        ,  message_name
        )
        SELECT
           p_online_report_id
        ,  p_login_id
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  0
        ,  0
        ,  0
        ,  p_sequence + ROWNUM
        ,  substr(g_linemsg || g_delim || '' || g_delim || g_shipmsg || g_delim
                       || poll.shipment_num || g_delim ||
                       DECODE(poll.payment_type , NULL, l_text_normal_po, l_text_complex_po), 1, 240)
        ,  DECODE(poll.payment_type, NULL, 'PO_CAN_POLL_WITH_ASN', 'PO_CAN_POLL_WITH_PENDING_WCR')
        FROM po_headers_gt poh, po_line_locations_gt poll
        WHERE poll.po_header_id = poh.po_header_id
	AND NVL(poll.cancel_flag, 'N') = 'N'
        AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
        AND EXISTS
          (
            SELECT 'ASN outstanding'
            FROM rcv_shipment_lines rsl
            WHERE rsl.po_header_id = poh.po_header_id
                  AND NVL(rsl.quantity_shipped, 0) > NVL(rsl.quantity_received, 0)
                  AND NVL(rsl.asn_line_flag, 'N') = 'Y'
                  AND NVL(rsl.shipment_line_status_code, 'EXPECTED') <> 'CANCELLED'
                   );

        d_progress := 15;

      ELSE

        d_progress := 20;

        l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_POLL_WITH_ASN');

        INSERT INTO PO_ONLINE_REPORT_TEXT_GT
        (  online_report_id
        ,  last_update_login
        ,  last_updated_by
        ,  last_update_date
        ,  created_by
        ,  creation_date
        ,  line_num
        ,  shipment_num
        ,  distribution_num
        ,  sequence
        ,  text_line
        ,  message_name
        )
        SELECT
           p_online_report_id
        ,  p_login_id
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  0
        ,  0
        ,  0
        ,  p_sequence + ROWNUM
        ,  substr(g_shipmsg || g_delim || poll.shipment_num || g_delim || l_textline, 1, 240)
        ,  'PO_CAN_POLL_WITH_ASN'
	FROM po_releases_gt por, po_line_locations_gt poll
        WHERE poll.po_release_id = por.po_release_id
	AND NVL(poll.cancel_flag, 'N') = 'N'
        AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
        AND EXISTS
          (
            SELECT 'ASN outstanding'
            FROM rcv_shipment_lines rsl
            WHERE rsl.po_release_id = por.po_release_id
                  AND NVL(rsl.quantity_shipped, 0) > NVL(rsl.quantity_received, 0)
                  AND NVL(rsl.asn_line_flag, 'N') = 'Y'
                  AND NVL(rsl.shipment_line_status_code, 'EXPECTED') <> 'CANCELLED'
          );

        d_progress := 25;

      END IF;  -- p_document_type = ...

       /*Bug 9012072 END Determine if there are any ASNs that have not been fully received for the shipments of the
         PO or Release being finally closed.*/

      /*Bug 9012072 START Determine if there are any ASNs that have not been fully received for the shipments of the
        PO Lines being finally closed.*/

    ELSIF (p_document_level = g_document_level_LINE)
    THEN

      d_progress := 30;

         l_text_normal_po := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_POLL_WITH_ASN');
         l_text_complex_po := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_POLL_WITH_PENDING_WCR');

        INSERT INTO PO_ONLINE_REPORT_TEXT_GT
        (  online_report_id
        ,  last_update_login
        ,  last_updated_by
        ,  last_update_date
        ,  created_by
        ,  creation_date
        ,  line_num
        ,  shipment_num
        ,  distribution_num
        ,  sequence
        ,  text_line
        ,  message_name
        )
        SELECT
           p_online_report_id
        ,  p_login_id
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  pol.line_num
        ,  0
        ,  0
        ,  p_sequence + ROWNUM
        ,  substr(g_linemsg || g_delim || pol.line_num || g_delim || g_shipmsg || g_delim
                       || poll.shipment_num || g_delim ||
                       DECODE(poll.payment_type , NULL, l_text_normal_po, l_text_complex_po), 1, 240)
        ,  DECODE(poll.payment_type, NULL, 'PO_CAN_POLL_WITH_ASN', 'PO_CAN_POLL_WITH_PENDING_WCR')
        FROM po_lines_gt pol, po_line_locations_gt poll
        WHERE poll.po_line_id = pol.po_line_id
	AND NVL(poll.cancel_flag, 'N') = 'N'
        AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
        AND EXISTS
          (
            SELECT 'ASN outstanding'
            FROM rcv_shipment_lines rsl
            WHERE rsl.po_line_id = pol.po_line_id
                  AND NVL(rsl.quantity_shipped, 0) > NVL(rsl.quantity_received, 0)
                  AND NVL(rsl.asn_line_flag, 'N') = 'Y'
                  AND NVL(rsl.shipment_line_status_code, 'EXPECTED') <> 'CANCELLED'
                   );

    /*Bug 9012072 END Determine if there are any ASNs that have not been fully received for the shipments of the
      PO Lines being finally closed.*/

      d_progress := 40;

    ELSIF (p_document_level = g_document_level_SHIPMENT)
    THEN

      d_progress := 50;

      /*Bug 9012072 START Determine if there are any ASNs that have not been fully received for the shipments of the
        PO or Release Shipments being finally closed.*/

      IF (p_document_type <> g_document_type_RELEASE)
      THEN

         l_text_normal_po := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_POLL_WITH_ASN');
         l_text_complex_po := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_POLL_WITH_PENDING_WCR');

        INSERT INTO PO_ONLINE_REPORT_TEXT_GT
        (  online_report_id
        ,  last_update_login
        ,  last_updated_by
        ,  last_update_date
        ,  created_by
        ,  creation_date
        ,  line_num
        ,  shipment_num
        ,  distribution_num
        ,  sequence
        ,  text_line
        ,  message_name
        )
        SELECT
           p_online_report_id
        ,  p_login_id
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  pol.line_num
        ,  poll.shipment_num
        ,  0
        ,  p_sequence + ROWNUM
        ,  substr(g_linemsg || g_delim || pol.line_num || g_delim || g_shipmsg || g_delim
                       || poll.shipment_num || g_delim ||
                       DECODE(poll.payment_type , NULL, l_text_normal_po, l_text_complex_po), 1, 240)
        ,  DECODE(poll.payment_type, NULL, 'PO_CAN_POLL_WITH_ASN', 'PO_CAN_POLL_WITH_PENDING_WCR')
        FROM po_lines_gt pol, po_line_locations_gt poll
        WHERE poll.po_line_id = pol.po_line_id
	AND NVL(poll.cancel_flag, 'N') = 'N'
        AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
        AND EXISTS
          (
            SELECT 'ASN outstanding'
            FROM rcv_shipment_lines rsl
            WHERE rsl.po_line_location_id = poll.line_location_id
                  AND NVL(rsl.quantity_shipped, 0) > NVL(rsl.quantity_received, 0)
                  AND NVL(rsl.asn_line_flag, 'N') = 'Y'
                  AND NVL(rsl.shipment_line_status_code, 'EXPECTED') <> 'CANCELLED'
                   );



      ELSE

      l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_POLL_WITH_ASN');

        INSERT INTO PO_ONLINE_REPORT_TEXT_GT
        (  online_report_id
        ,  last_update_login
        ,  last_updated_by
        ,  last_update_date
        ,  created_by
        ,  creation_date
        ,  line_num
        ,  shipment_num
        ,  distribution_num
        ,  sequence
        ,  text_line
        ,  message_name
        )
        SELECT
           p_online_report_id
        ,  p_login_id
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  0
        ,  poll.shipment_num
        ,  0
        ,  p_sequence + ROWNUM
        ,  substr(g_shipmsg || g_delim || poll.shipment_num || g_delim || l_textline, 1, 240)
        ,  'PO_CAN_POLL_WITH_ASN'
        FROM    po_line_locations_gt poll
        WHERE   EXISTS
               (
                  SELECT 'Eligible shipment'
                  FROM    po_releases_gt por
                  WHERE   por.po_release_id = poll.po_release_id
                          AND NVL(por.cancel_flag, 'N') = 'N'
                          AND NVL(por.closed_code, 'OPEN') <> 'FINALLY CLOSED'
               )
               AND EXISTS
               (
                 SELECT 'ASN outstanding'
                 FROM rcv_shipment_lines rsl
                 WHERE rsl.po_line_location_id = poll.line_location_id
                      AND NVL(rsl.quantity_shipped, 0) > NVL(rsl.quantity_received, 0)
                      AND NVL(rsl.asn_line_flag, 'N') = 'Y'
                      AND NVL(rsl.shipment_line_status_code, 'EXPECTED') <> 'CANCELLED'
               );

      END IF;

 /*Bug 9012072 END Determine if there are any ASNs that have not been fully received for the shipments of the
   PO or Release Shipments being finally closed.*/

    d_progress := 60;

    ELSE

      d_progress := 70;
      d_msg := 'Bad document level';
      l_ret_sts := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- if p_document_level = ...

  d_progress := 80;

  p_sequence := p_sequence + SQL%ROWCOUNT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END check_asn_not_fully_received;

/*Bug 9012072 START--->Modified the check_asn_not_fully_received procedure*/


-- Determine if there is any shipment being finally closed that
-- has received more than has been delivered to its distributions.
-- Does not check ('RATE', 'FIXED PRICE') lines
PROCEDURE check_qty_rcv_but_not_deliv(
   p_document_type        IN VARCHAR2
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
)
IS

l_textline  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;

d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_qty_rcv_but_not_deliv';
d_progress NUMBER;


BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_sequence', p_sequence);
  END IF;

  d_progress := 10;

--Bug 16858759 start
--Description:For a BPA order with a Release,the shipment can allow to
--finally closed though quantity received is not fully delivered.
--For Release, po_lines_gt is empty. Hence, don't use po_lines_gt in
--the WHERE clause where document type is RELEASE.
  IF (p_document_type <> g_document_type_RELEASE)
  THEN

	  INSERT INTO PO_ONLINE_REPORT_TEXT_GT
	  (  online_report_id
	  ,  last_update_login
	  ,  last_updated_by
	  ,  last_update_date
	  ,  created_by
	  ,  creation_date
	  ,  line_num
	  ,  shipment_num
	  ,  distribution_num
	  ,  sequence
	  ,  text_line
	  ,  message_name
	  )
	  SELECT
		 p_online_report_id
	  ,  p_login_id
	  ,  p_user_id
	  ,  SYSDATE
	  ,  p_user_id
	  ,  SYSDATE
	  ,  pol.line_num
	  ,  poll.shipment_num
	  ,  0
	  ,  p_sequence + ROWNUM
	  ,  substr( g_linemsg || g_delim || pol.line_num || g_delim || g_shipmsg || g_delim
			   || poll.shipment_num || g_delim
			   || PO_CORE_S.get_translated_text('PO_CAN_POLL_REC_NOT_DEL'
												 , 'QTY2', round(NVL(poll.quantity_received, 0),5) /* Bug:13427569 rounded to 5 digits */
												, 'QTY1', round(sum(NVL(pod.quantity_delivered, 0)),5) /* Bug:13427569 rounded to 5 digits */
												)
		    , 1, 240)
	  ,  'PO_CAN_POLL_REC_NOT_DEL'
	  FROM po_lines_gt pol, po_line_locations_gt poll, po_distributions_gt pod
	  WHERE pod.line_location_id = poll.line_location_id
		AND pol.po_line_id = poll.po_line_id
		AND pol.order_type_lookup_code NOT IN ('RATE', 'FIXED PRICE')
		AND NVL(poll.cancel_flag, 'N') = 'N'
		AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
		AND round(NVL(poll.quantity_received, 0),5) > /* Bug:13427569 rounded to 5 digits */
			 (
			   SELECT round(sum(NVL(pod2.quantity_delivered, 0)),5) /* Bug:13427569 rounded to 5 digits */
			   FROM po_distributions_gt pod2
			   WHERE pod2.line_location_id = poll.line_location_id
			 )
	  GROUP BY pol.line_num
			 , poll.shipment_num
			 , NVL(poll.quantity_received, 0)
			 , ROWNUM  -- <Bug 4118145, Issue 8>
	  ;

  ELSE

	  INSERT INTO PO_ONLINE_REPORT_TEXT_GT
	  (  online_report_id
	  ,  last_update_login
	  ,  last_updated_by
	  ,  last_update_date
	  ,  created_by
	  ,  creation_date
	  ,  line_num
	  ,  shipment_num
	  ,  distribution_num
	  ,  sequence
	  ,  text_line
	  ,  message_name
	  )
	  SELECT
		 p_online_report_id
	  ,  p_login_id
	  ,  p_user_id
	  ,  SYSDATE
	  ,  p_user_id
	  ,  SYSDATE
	  ,  0
	  ,  poll.shipment_num
	  ,  0
	  ,  p_sequence + ROWNUM
	  ,  substr( g_shipmsg || g_delim || poll.shipment_num || g_delim
			   || PO_CORE_S.get_translated_text('PO_CAN_POLL_REC_NOT_DEL'
												 , 'QTY2', round(NVL(poll.quantity_received, 0),5) /* Bug:13427569 rounded to 5 digits */
												, 'QTY1', round(sum(NVL(pod.quantity_delivered, 0)),5) /* Bug:13427569 rounded to 5 digits */
												), 1, 240)
	  ,  'PO_CAN_POLL_REC_NOT_DEL'
	  FROM  po_line_locations_gt poll, po_distributions_gt pod   -- For Releases, PO_LINES_GT doesn't get populated.
	  WHERE pod.line_location_id = poll.line_location_id
		AND poll.value_basis NOT IN ('RATE', 'FIXED PRICE')
		AND NVL(poll.cancel_flag, 'N') = 'N'
		AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
		AND round(NVL(poll.quantity_received, 0),5) > /* Bug:13427569 rounded to 5 digits */
			 (
			   SELECT round(sum(NVL(pod2.quantity_delivered, 0)),5) /* Bug:13427569 rounded to 5 digits */
			   FROM po_distributions_gt pod2
			   WHERE pod2.line_location_id = poll.line_location_id
			 )
	  GROUP BY poll.shipment_num
			 , NVL(poll.quantity_received, 0)
			 , ROWNUM  -- <Bug 4118145, Issue 8>
	  ;

  END IF;
--Bug 16858759 end

  d_progress := 20;

  p_sequence := p_sequence + SQL%ROWCOUNT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END check_qty_rcv_but_not_deliv;

-- Determine if there is any shipment being finally closed that
-- has received more than has been delivered to its distributions.
-- For ('RATE', 'FIXED PRICE') lines only
PROCEDURE check_amt_rcv_but_not_deliv(
   p_document_type        IN VARCHAR2
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
)
IS

l_textline  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;

d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_amt_rcv_but_not_deliv';
d_progress NUMBER;


BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_sequence', p_sequence);
  END IF;

  d_progress := 10;

  -- <Bug 4118145, Issue 8 Start>
  -- In query below, changed quantity columns to amount columns and also
  -- group by ROWNUM so that it can be used in the select clause

  INSERT INTO PO_ONLINE_REPORT_TEXT_GT
  (  online_report_id
  ,  last_update_login
  ,  last_updated_by
  ,  last_update_date
  ,  created_by
  ,  creation_date
  ,  line_num
  ,  shipment_num
  ,  distribution_num
  ,  sequence
  ,  text_line
  ,  message_name
  )
  SELECT
     p_online_report_id
  ,  p_login_id
  ,  p_user_id
  ,  SYSDATE
  ,  p_user_id
  ,  SYSDATE
  ,  DECODE(p_document_type, g_document_type_RELEASE, 0, pol.line_num)
  ,  poll.shipment_num
  ,  0
  ,  p_sequence + ROWNUM
  ,  substr(
       DECODE(p_document_type, g_document_type_RELEASE,
         g_shipmsg || g_delim || poll.shipment_num || g_delim
           || PO_CORE_S.get_translated_text('PO_CAN_POLL_AMT_REC_NOT_DEL'
                                            , 'QTY2', NVL(poll.amount_received, 0)
                                            , 'QTY1', sum(NVL(pod.amount_delivered, 0))
                                            ),
         g_linemsg || g_delim || pol.line_num || g_delim || g_shipmsg || g_delim
           || poll.shipment_num || g_delim
           || PO_CORE_S.get_translated_text('PO_CAN_POLL_AMT_REC_NOT_DEL'
                                            , 'QTY2', NVL(poll.amount_received, 0)
                                            , 'QTY1', sum(NVL(pod.amount_delivered, 0))
                                            )
       ), 1, 240)
  ,  'PO_CAN_POLL_AMT_REC_NOT_DEL'
  FROM po_lines_gt pol, po_line_locations_gt poll, po_distributions_gt pod
  WHERE pod.line_location_id = poll.line_location_id
    AND pol.po_line_id = poll.po_line_id
    AND pol.order_type_lookup_code IN ('RATE', 'FIXED PRICE')
    AND NVL(poll.cancel_flag, 'N') = 'N'
    AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
    AND NVL(poll.amount_received, 0) >
         (
           SELECT sum(NVL(pod2.amount_delivered, 0))
           FROM po_distributions_gt pod2
           WHERE pod2.line_location_id = poll.line_location_id
         )
  GROUP BY pol.line_num
         , poll.shipment_num
         , NVL(poll.amount_received, 0)
         , ROWNUM   -- <Bug 4118145, Issue 8>
  ;

  -- <Bug 4118145, Issue 8 End>

  d_progress := 20;

  p_sequence := p_sequence + SQL%ROWCOUNT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END check_amt_rcv_but_not_deliv;

-- <<Bug#16498663 Start>>
-- Determine whether the total amount financed is completely recouped or not.
-- If the total amount financed is not equal to the total amount recouped,
-- then finally close is not allowed.
PROCEDURE check_amt_fin_not_fully_rec(
   p_document_level       IN VARCHAR2
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
)
IS

l_textline  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;
l_ret_sts   VARCHAR2(1);

d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_amt_fin_not_fully_rec';
d_progress NUMBER;
d_msg      VARCHAR2(60);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_level', p_document_level);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_sequence', p_sequence);
  END IF;

  d_progress := 10;

    IF (p_document_level = g_document_level_HEADER)
    THEN

      d_progress := 20;

      --SQL WHAT: Determene whether the document is having shipemnts which has
      --  total amount financed is not completely recouped.
      --SQL WHY: To restrict header level finally close when the
      --  total amount financed is not completely recouped.
      INSERT INTO PO_ONLINE_REPORT_TEXT_GT
      (  online_report_id
      ,  last_update_login
      ,  last_updated_by
      ,  last_update_date
      ,  created_by
      ,  creation_date
      ,  line_num
      ,  shipment_num
      ,  distribution_num
      ,  sequence
      ,  text_line
      ,  message_name
      )
      SELECT p_online_report_id ,
      p_login_id ,
      p_user_id ,
      SYSDATE ,
      p_user_id ,
      SYSDATE ,
      PLG.line_num ,
      NULL ,
      NULL ,
      p_sequence + ROWNUM ,
      PO_CORE_S.get_translated_text ( 'PO_CAN_AMT_FIN_NOT_REC' , 'LINE_NUM', PLG.line_num
                                           , 'PAY_ITEM_NUM', NULL),
      'PO_CAN_AMT_FIN_NOT_REC'
      FROM po_headers_gt PHG ,
        po_lines_gt PLG ,
        po_line_locations PLL
      WHERE PLG.po_header_id  = PHG.po_header_id
        AND PLL.po_line_id    = PLG.po_line_id
        AND PLL.shipment_type = 'PREPAYMENT'
        AND NVL(PLG.cancel_flag,'N')      = 'N'
        AND NVL(PLG.closed_code,'OPEN')   <> 'FINALLY CLOSED'
        AND NVL(PLL.amount_financed,0)    <> NVL(PLL.amount_recouped, 0);

    ELSIF (p_document_level = g_document_level_LINE)
    THEN

      d_progress := 30;

      --SQL WHAT: Determene whether the document line is having shipemnts
      --  which has total amount financed is not completely recouped.
      --SQL WHY: To restrict line level finally close when the
      --  total amount financed is not completely recouped.
      INSERT INTO PO_ONLINE_REPORT_TEXT_GT
      (  online_report_id
      ,  last_update_login
      ,  last_updated_by
      ,  last_update_date
      ,  created_by
      ,  creation_date
      ,  line_num
      ,  shipment_num
      ,  distribution_num
      ,  sequence
      ,  text_line
      ,  message_name
      )
      SELECT p_online_report_id ,
      p_login_id ,
      p_user_id ,
      SYSDATE ,
      p_user_id ,
      SYSDATE ,
      PLG.line_num ,
      NULL ,
      NULL ,
      p_sequence + ROWNUM ,
      PO_CORE_S.get_translated_text ( 'PO_CAN_AMT_FIN_NOT_REC' , 'LINE_NUM', PLG.line_num
                                           , 'PAY_ITEM_NUM', NULL),
      'PO_CAN_AMT_FIN_NOT_REC'
      FROM po_lines_gt PLG ,
        po_line_locations PLL
      WHERE PLL.po_line_id    = PLG.po_line_id
        AND PLL.shipment_type = 'PREPAYMENT'
        AND NVL(PLG.cancel_flag,'N')      = 'N'
        AND NVL(PLG.closed_code,'OPEN')   <> 'FINALLY CLOSED'
        AND NVL(PLL.amount_financed,0)    <> NVL(PLL.amount_recouped, 0);

    ELSIF (p_document_level = g_document_level_SHIPMENT)
    THEN

      d_progress := 40;

      --SQL WHAT: Determene whether the shipment has total amount
      --  financed is not completely recouped.
      --SQL WHY: To restrict shipment level finally close when the
      --  total amount financed is not completely recouped.
      INSERT INTO PO_ONLINE_REPORT_TEXT_GT
      (  online_report_id
      ,  last_update_login
      ,  last_updated_by
      ,  last_update_date
      ,  created_by
      ,  creation_date
      ,  line_num
      ,  shipment_num
      ,  distribution_num
      ,  sequence
      ,  text_line
      ,  message_name
      )
      SELECT p_online_report_id ,
      p_login_id ,
      p_user_id ,
      SYSDATE ,
      p_user_id ,
      SYSDATE ,
      PLG.line_num ,
      NULL ,
      NULL ,
      p_sequence + ROWNUM ,
      PO_CORE_S.get_translated_text ( 'PO_CAN_AMT_FIN_NOT_REC' , 'LINE_NUM', PLG.line_num
                                           , 'PAY_ITEM_NUM', PLLG.shipment_num),
      'PO_CAN_AMT_FIN_NOT_REC'
      FROM po_line_locations_gt PLLG ,
        po_lines_gt PLG
      WHERE PLG.po_line_id = PLLG.po_line_id
      AND EXISTS
      (
        SELECT 'Amount Financed is not fully recouped'
        FROM PO_LINE_LOCATIONS PLL ,
        PO_LINES POL
        WHERE POL.po_line_id             = PLG.po_line_id
        AND PLL.po_line_id               = POL.po_line_id
        AND PLL.shipment_type            = 'PREPAYMENT'
        AND NVL(POL.cancel_flag,'N')     = 'N'
        AND NVL(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'
        AND NVL(PLL.amount_financed,0) <> NVL(PLL.amount_recouped, 0)
      );

    ELSE

      d_progress := 50;
      d_msg := 'Bad document level';
      l_ret_sts := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;  -- if p_document_level = ...

  d_progress := 60;

  p_sequence := p_sequence + SQL%ROWCOUNT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END check_amt_fin_not_fully_rec;

-- <<Bug#16498663 End>>

-- Determine if there are any invalid accounting flexfields
PROCEDURE check_invalid_acct_flex(
   p_document_type        IN VARCHAR2
,  p_action_requested     IN VARCHAR2
,  p_action_date          IN DATE
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_document_id          IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
)
IS

l_textline  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;
l_is_complex_po     boolean;
l_token_value VARCHAR2(256);

d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_invalid_acct_flex';
d_progress NUMBER;


BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_action_date', p_action_date);
    PO_LOG.proc_begin(d_module, 'p_action_requested', p_action_requested);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_sequence', p_sequence);
  END IF;

  d_progress := 10;

  --Bug5072310
  --Added Condition to filter releaes before calling complex work API
  if p_document_type <> g_document_type_RELEASE  then
     l_is_complex_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(p_document_id);
  end if;

  IF (l_is_complex_po) THEN
    l_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_LINE_LOC_TYPE_LOW_P_PAYITEM');
  ELSE
    l_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_LINE_LOC_TYPE_LOWER_S_SCH');
  END IF;

  FND_MESSAGE.SET_NAME('PO','PO_CAN_POLL_INVALID_ACCT_FLEX');
  FND_MESSAGE.SET_TOKEN('LINE_LOCATION_TYPE', l_token_value);

  l_textline := FND_MESSAGE.GET;

  INSERT INTO PO_ONLINE_REPORT_TEXT_GT
  (  online_report_id
  ,  last_update_login
  ,  last_updated_by
  ,  last_update_date
  ,  created_by
  ,  creation_date
  ,  line_num
  ,  shipment_num
  ,  distribution_num
  ,  sequence
  ,  text_line
  ,  message_name
  )
  SELECT
     p_online_report_id
  ,  p_login_id
  ,  p_user_id
  ,  SYSDATE
  ,  p_user_id
  ,  SYSDATE
  ,  DECODE(p_document_type, g_document_type_RELEASE, 0, pol.line_num)
  ,  poll.shipment_num
  ,  pod.distribution_num
  ,  p_sequence + ROWNUM
  ,  substr(
       DECODE(p_document_type, g_document_type_RELEASE,
           g_shipmsg || g_delim || poll.shipment_num || g_delim || g_distmsg || g_delim || l_textline
         , g_linemsg || g_delim || pol.line_num || g_delim || g_shipmsg || g_delim
             || poll.shipment_num || g_delim || g_distmsg || g_delim || l_textline
       ), 1, 240)
  ,  'PO_CAN_POLL_INVALID_ACCT_FLEX'
  FROM po_lines_gt pol, po_line_locations_gt poll
     , po_distributions_gt pod, gl_code_combinations gcc
  WHERE pod.line_location_id = poll.line_location_id
    AND pol.po_line_id = poll.po_line_id
    AND poll.shipment_type IN ('STANDARD', 'PLANNED', 'PREPAYMENT') --<Complex Work R12>
    AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
    AND ( NVL(poll.cancel_flag, 'N') = 'N' OR p_action_requested = g_action_FINAL_CLOSE_CHECK)
    AND gcc.code_combination_id = pod.code_combination_id
    AND NVL(p_action_date, trunc(SYSDATE)) NOT BETWEEN
          NVL(gcc.start_date_active, NVL(p_action_date, trunc(SYSDATE) - 1))
            AND
          NVL(gcc.end_date_active, NVL(p_action_date, trunc(SYSDATE) + 1));

  d_progress := 20;

  p_sequence := p_sequence + SQL%ROWCOUNT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END check_invalid_acct_flex;

-- Deterimine if a BPA has any open releases against it
PROCEDURE check_bpa_has_open_release(
   p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
)
IS

l_textline  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;

d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_bpa_has_open_release';
d_progress NUMBER;


BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_sequence', p_sequence);
  END IF;

  d_progress := 10;

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_POL_PLAN_WITH_OPEN_REL');

  INSERT INTO PO_ONLINE_REPORT_TEXT_GT
  (  online_report_id
  ,  last_update_login
  ,  last_updated_by
  ,  last_update_date
  ,  created_by
  ,  creation_date
  ,  line_num
  ,  shipment_num
  ,  distribution_num
  ,  sequence
  ,  text_line
  ,  message_name
  )
  SELECT
     p_online_report_id
  ,  p_login_id
  ,  p_user_id
  ,  SYSDATE
  ,  p_user_id
  ,  SYSDATE
  ,  pol.line_num
  ,  0
  ,  0
  ,  p_sequence + ROWNUM
  ,  substr(g_linemsg || g_delim || pol.line_num || g_delim || l_textline,1,240)  --Bug5096900
  ,  'PO_CAN_POL_PLAN_WITH_OPEN_REL'
  FROM po_lines_gt pol
  WHERE EXISTS
     (
       SELECT 'Uncancelled Open Releases Exist'
       FROM po_line_locations pll
       WHERE pll.po_line_id = pol.po_line_id
         AND pll.shipment_type = 'BLANKET'
         AND NVL(pll.cancel_flag, 'N') = 'N'
         AND NVL(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
     );

  d_progress := 20;

  p_sequence := p_sequence + SQL%ROWCOUNT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END check_bpa_has_open_release;

-- Deterimine if a GA has any open Std. POs against it
PROCEDURE check_bpa_has_open_stdref(
   p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
)
IS

l_textline  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;

d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_bpa_has_open_stdref';
d_progress NUMBER;


BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_sequence', p_sequence);
  END IF;

  d_progress := 10;

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_GAL_WITH_OPEN_STD_REF');

  INSERT INTO PO_ONLINE_REPORT_TEXT_GT
  (  online_report_id
  ,  last_update_login
  ,  last_updated_by
  ,  last_update_date
  ,  created_by
  ,  creation_date
  ,  line_num
  ,  shipment_num
  ,  distribution_num
  ,  sequence
  ,  text_line
  ,  message_name
  )
  SELECT
     p_online_report_id
  ,  p_login_id
  ,  p_user_id
  ,  SYSDATE
  ,  p_user_id
  ,  SYSDATE
  ,  pol.line_num
  ,  0
  ,  0
  ,  p_sequence + ROWNUM
  ,  substr(g_linemsg || g_delim || pol.line_num || g_delim || l_textline,1,240)   --Bug5096900
  ,  'PO_CAN_GAL_WITH_OPEN_STD_REF'
  FROM po_lines_gt pol
  WHERE EXISTS
     (
       SELECT 'Uncancelled Std PO lines referencing this GA line exist'
       FROM po_lines_all pol2
       WHERE pol2.from_line_id = pol.po_line_id
         AND NVL(pol2.cancel_flag, 'N') = 'N'
         AND NVL(pol2.closed_code, 'OPEN') <> 'FINALLY CLOSED'
     );

  d_progress := 20;

  p_sequence := p_sequence + SQL%ROWCOUNT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END check_bpa_has_open_stdref;

-- Determine if a GC has any open Std. POs against it
PROCEDURE check_cpa_has_open_stdref(
   p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
)
IS

l_textline  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;

d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_cpa_has_open_stdref';
d_progress NUMBER;


BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_sequence', p_sequence);
  END IF;

  d_progress := 10;

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_CGA_WITH_OPEN_STD_REF');

  INSERT INTO PO_ONLINE_REPORT_TEXT_GT
  (  online_report_id
  ,  last_update_login
  ,  last_updated_by
  ,  last_update_date
  ,  created_by
  ,  creation_date
  ,  line_num
  ,  shipment_num
  ,  distribution_num
  ,  sequence
  ,  text_line
  ,  message_name
  )
  SELECT
     p_online_report_id
  ,  p_login_id
  ,  p_user_id
  ,  SYSDATE
  ,  p_user_id
  ,  SYSDATE
  ,  0
  ,  0
  ,  0
  ,  p_sequence + ROWNUM
  ,  substr(l_textline,1,240)      --Bug5096900
  ,  'PO_CAN_CGA_WITH_OPEN_STD_REF'
  FROM po_headers_gt poh
  WHERE EXISTS
     (
       SELECT 'Open Std PO lines referencing this contract exist'
       FROM po_lines_all pol
       WHERE pol.contract_id = poh.po_header_id
         AND NVL(pol.cancel_flag, 'N') = 'N'
         AND NVL(pol.closed_code, 'OPEN') <> 'FINALLY CLOSED'
     );

  d_progress := 20;

  p_sequence := p_sequence + SQL%ROWCOUNT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END check_cpa_has_open_stdref;

-- Determine if a PPO has any open releases against it
PROCEDURE check_ppo_has_open_release(
   p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
)
IS

l_textline  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;

d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_ppo_has_open_release';
d_progress NUMBER;


BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_sequence', p_sequence);
  END IF;

  d_progress := 10;

  l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_CAN_POLL_PLAN_WITH_OPEN_REL');

  INSERT INTO PO_ONLINE_REPORT_TEXT_GT
  (  online_report_id
  ,  last_update_login
  ,  last_updated_by
  ,  last_update_date
  ,  created_by
  ,  creation_date
  ,  line_num
  ,  shipment_num
  ,  distribution_num
  ,  sequence
  ,  text_line
  ,  message_name
  )
  SELECT
     p_online_report_id
  ,  p_login_id
  ,  p_user_id
  ,  SYSDATE
  ,  p_user_id
  ,  SYSDATE
  ,  pol.line_num
  ,  poll.shipment_num
  ,  0
  ,  p_sequence + ROWNUM
  ,  substr(g_linemsg || g_delim || pol.line_num || g_delim || g_shipmsg
              || poll.shipment_num || g_delim || l_textline,1,240)   --Bug5096900
  ,  'PO_CAN_POLL_PLAN_WITH_OPEN_REL'
  FROM po_lines_gt pol, po_line_locations_gt poll
  WHERE poll.po_line_id = pol.po_line_id
    AND NVL(poll.cancel_flag, 'N') = 'N'
    AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
    AND EXISTS
     (
       SELECT 'Uncancelled Open Releases Exist'
       FROM po_line_locations poll2
       WHERE poll2.source_shipment_id = poll.line_location_id
         AND poll2.shipment_type = 'SCHEDULED'
         AND NVL(poll2.cancel_flag, 'N') = 'N'
         AND NVL(poll2.closed_code, 'OPEN') <> 'FINALLY CLOSED'
     );

  d_progress := 20;

  p_sequence := p_sequence + SQL%ROWCOUNT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END check_ppo_has_open_release;
-- <Doc Manager Rewrite 11.5.11 End>


--<Complex Work R12 START>
-- PO Quantity/Amount Rollup Checks
PROCEDURE check_po_qty_amt_rollup(
   p_online_report_id     IN NUMBER
,  p_document_id          IN NUMBER
,  p_login_id             IN NUMBER
,  p_user_id              IN NUMBER
,  x_sequence             IN OUT NOCOPY NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(40) := 'CHECK_PO_QTY_AMT_ROLLUP';
  l_progress VARCHAR2(3);
  l_is_complex_po     boolean;
  l_is_financing_flag VARCHAR2(1);
  TYPE NumTab is TABLE of NUMBER INDEX by BINARY_INTEGER;
  l_rowcount NumTab;
  l_line_num        NumTab;
  l_shipment_num    NumTab;
  l_dist_num        NumTab;
  l_line_qty_tbl    NumTab;     -- <SERVICES FPJ>
  l_line_amt_tbl    NumTab;     -- <SERVICES FPJ>
  l_lineloc_qty_tbl NumTab;     -- <SERVICES FPJ>
  l_lineloc_amt_tbl NumTab;     -- <SERVICES FPJ>
  l_dist_qty_tbl    NumTab;     -- <SERVICES FPJ>
  l_dist_amt_tbl    NumTab;     -- <SERVICES FPJ>
  l_fin_adv_amount  NumTab;
  l_currency_code   VARCHAR2(15); -- <Complex Work R12>
  l_min_acct_unit   VARCHAR2(15); -- <Complex Work R12>
  l_precision       VARCHAR2(15); -- <Complex Work R12>
  l_recoupment_rate NumTab; 	    -- <Bug#16498663>
BEGIN
  l_progress := '001';

  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
                      || l_progress,'Start PO Qty/Amt Rollup Checks');
     END IF;
  END IF;

  -- Method Logic:
  -- If not a Complex Work PO, run the existing shipment level checks.
  -- For Complex Work PO, run separate pay item rollup check
  -- In both cases, run the existing distribution level checks.

  l_is_complex_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(p_document_id);

  IF (NOT l_is_complex_po) THEN

    l_progress := '010';
    -- Check 1a: Quantities/Amounts between Purchase Order Line and Shipments
    -- must match (existing logic)

    IF g_debug_stmt THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
                        || l_progress,'PO Shipment Qty/Amt Rollup');
       END IF;
    END IF;

    SELECT
        POL.line_num
    ,   POL.quantity
    ,   POL.amount                                            -- <SERVICES FPJ>
    ,   sum( PLL.quantity - nvl(PLL.quantity_cancelled,0) )   -- <SERVICES FPJ>
    ,   sum( PLL.amount - nvl(PLL.amount_cancelled,0) )       -- <SERVICES FPJ>
    BULK COLLECT INTO
        l_line_num
    ,   l_line_qty_tbl                                        -- <SERVICES FPJ>
    ,   l_line_amt_tbl                                        -- <SERVICES FPJ>
    ,   l_lineloc_qty_tbl                                     -- <SERVICES FPJ>
    ,   l_lineloc_amt_tbl                                     -- <SERVICES FPJ>
    FROM
        PO_LINE_LOCATIONS_GT PLL
    ,   PO_LINES_GT POL
    WHERE
        POL.po_line_id = PLL.po_line_id
    AND PLL.shipment_type in ('STANDARD', 'PLANNED')
    AND POL.po_header_id = p_document_id
    AND nvl(POL.cancel_flag,'N') = 'N'
    AND nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND (
            (   ( POL.quantity IS NOT NULL )                  -- <SERVICES FPJ>
            AND ( round(POL.quantity, 10) <>
                (SELECT round(sum(PLL2.quantity) -
                              sum(nvl(PLL2.quantity_cancelled, 0)), 10)
                 FROM PO_LINE_LOCATIONS_GT PLL2
                 WHERE PLL2.po_line_id = POL.po_line_id AND
                       PLL2.shipment_type in ('STANDARD', 'PLANNED') ) )
            )
        OR                                                    -- <SERVICES FPJ>
            (   ( POL.amount IS NOT NULL )
            AND ( round(POL.amount, 10) <>
                  (   SELECT round ( sum ( PLL3.amount
                                         - nvl(PLL3.amount_cancelled, 0) )
                                   , 10
                                   )
                      FROM   po_line_locations_gt PLL3
                      WHERE  PLL3.po_line_id = POL.po_line_id
                      AND    PLL3.shipment_type IN ('STANDARD','PLANNED')
                  )
                )
            )
        )
    GROUP BY
        POL.line_num
    ,   POL.quantity
    ,   POL.amount;                                           -- <SERVICES FPJ>

    l_progress := '015';

    FOR i IN 1..l_line_num.COUNT LOOP
        l_rowCount(i) := i;
    END LOOP;

    FORALL i IN 1..l_line_num.COUNT
        INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                message_name)
        VALUES(p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            l_line_num(i),
            NULL,                                             -- <SERVICES FPJ>
            NULL,                                             -- <SERVICES FPJ>
            x_sequence+ l_rowCount(i),
            decode ( l_line_qty_tbl(i)                        -- <SERVICES FPJ>
                   , NULL , PO_CORE_S.get_translated_text
                            (   'PO_SUB_PO_LINE_NE_SHIP_AMT'
                            ,   'LINE_NUM', l_line_num(i)
                            ,   'LINE_AMT', l_line_amt_tbl(i)
                            ,   'SHIP_AMT', l_lineloc_amt_tbl(i)
                            )
                   ,        PO_CORE_S.get_translated_text
                            (   'PO_SUB_PO_LINE_NE_SHIP_QTY'
                            ,   'LINE_NUM', l_line_num(i)
                            ,   'LINE_QTY', l_line_qty_tbl(i)
                            ,   'SHIP_QTY', l_lineloc_qty_tbl(i)
                            )
                   ),
            decode ( l_line_qty_tbl(i)                        -- <SERVICES FPJ>
                   , NULL , 'PO_SUB_PO_LINE_NE_SHIP_AMT'
                   ,        'PO_SUB_PO_LINE_NE_SHIP_QTY'
                   )
          );

    l_progress := '017';

    --Increment the x_sequence with number of errors reported in last query
    x_sequence := x_sequence + SQL%ROWCOUNT;

  ELSE
    -- The document IS a complex work PO
    -- Check 1b: Amounts roll up between Purchase Order Line and Pay Items

    l_progress := '020';

    IF g_debug_stmt THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
                        || l_progress,'PO Pay Item Qty/Amt Rollup');
       END IF;
    END IF;

    l_is_financing_flag := PO_CORE_S.boolean_to_flag(
                           PO_COMPLEX_WORK_PVT.is_financing_po(p_document_id));

    l_progress := '022';

    -- Get the currency code and precision
    SELECT poh.currency_code
    INTO   l_currency_code
    FROM   po_headers_all poh
    WHERE  poh.po_header_id = p_document_id;

    PO_CORE_S2.get_currency_info(
      x_currency_code => l_currency_code
    , x_min_unit      => l_min_acct_unit
    , x_precision     => l_precision);

    l_progress := '023';

   --Bug 5440038 , included ADVANCES for roll-up logic but this would apply
   --  only to financing case, as the for actual case only the
   --  STANDARD line locations are rolled up
   -- for a financing case, the line location rollups would include all pay items
   -- and the advance amounts which together make up the prepayment amount
   -- should be less than the line amount
   -- the financing_advance_amount advance amount is also calculated for
   -- better reporting purposes

   -- Bug#14676651
    SELECT
        subtotal.line_num
    ,   subtotal.line_amount
    ,   subtotal.line_loc_amount
    ,   subtotal.financing_advance_amount
    BULK COLLECT INTO
        l_line_num
    ,   l_line_amt_tbl
    ,   l_lineloc_amt_tbl
    ,   l_fin_adv_amount
    FROM
    ( SELECT
        POL.line_num
      , CASE
          WHEN (    POL.order_type_lookup_code = 'FIXED PRICE'
                 OR POL.order_type_lookup_code = 'RATE')
	  THEN
            -- Commented for Bug#14676651
            -- POL.amount
	   CASE
              WHEN l_min_acct_unit IS NOT NULL THEN
                -- Round to minimum accountable unit.
                ROUND(
                      NVL(POL.amount,0) / l_min_acct_unit
                     ) * l_min_acct_unit
              ELSE
                -- Round to currency precision.
                ROUND(NVL(POL.amount,0), l_precision)
            END
          ELSE
            CASE
              WHEN l_min_acct_unit IS NOT NULL THEN
                -- Round to minimum accountable unit.
                ROUND(
                      NVL(POL.quantity * POL.unit_price,0) / l_min_acct_unit
                     ) * l_min_acct_unit
              ELSE
                -- Round to currency precision.
                ROUND(NVL(POL.quantity * POL.unit_price,0), l_precision)
            END
        END line_amount
	-- Bug 18002633 : Reverted changes made for Bug 14676651
	, (CASE
         WHEN l_min_acct_unit IS NOT NULL THEN
	   -- Round to minimum accountable unit.
           Round(SUM(
	     CASE
	       WHEN ( PLL.value_basis = 'FIXED PRICE' OR PLL.value_basis = 'RATE')    THEN
		   PLL.amount - NVL(PLL.amount_cancelled, 0)
                ELSE
		  (PLL.quantity-NVL(PLL.quantity_cancelled,0)) * PLL.price_override
                END) / l_min_acct_unit      ) * l_min_acct_unit

         ELSE
	   -- Round to currency precision
           ROUND(SUM(
	     CASE
                WHEN ( PLL.value_basis = 'FIXED PRICE' OR PLL.value_basis = 'RATE')    THEN
        	   PLL.amount - NVL(PLL.amount_cancelled, 0)
                  ELSE
		   (PLL.quantity-NVL(PLL.quantity_cancelled,0)) * PLL.price_override
              END) , l_precision)
        END ) line_loc_amount
	-- <end> Bug 18002633
     , SUM (CASE
          WHEN  PLL.payment_type = 'ADVANCE' THEN
             PLL.amount
       END) financing_advance_amount
      FROM
        PO_LINE_LOCATIONS_GT PLL
      , PO_LINES_GT POL
      WHERE
        POL.po_line_id = PLL.po_line_id
      AND (   (l_is_financing_flag = 'N' AND PLL.shipment_type = 'STANDARD')
           OR (l_is_financing_flag = 'Y' and PLL.shipment_type = 'PREPAYMENT'))
      AND POL.po_header_id = p_document_id
      AND nvl(POL.cancel_flag,'N') = 'N'
      AND nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'
   --   AND nvl(payment_type, 'NULL') <> 'ADVANCE' --Bug 5440038
      GROUP BY POL.line_num, POL.order_type_lookup_code, POL.amount, POL.quantity, POL.unit_price
    ) subtotal
    WHERE
    ( (l_is_financing_flag = 'Y' AND NOT (subtotal.line_amount >= subtotal.line_loc_amount))
    OR
      (l_is_financing_flag = 'N' AND NOT (subtotal.line_amount = subtotal.line_loc_amount))
    );

    l_progress := '025';

    FOR i IN 1..l_line_num.COUNT LOOP
        l_rowCount(i) := i;
    END LOOP;

   --Bug 5440038 and 5517131: Cleared the TODOs for complex work submission checks error messages

    FORALL i IN 1..l_line_num.COUNT
        INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
        message_name)
        VALUES(p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            l_line_num(i),
            NULL,
            NULL,
            x_sequence+ l_rowCount(i),
            decode ( l_fin_adv_amount(i),
                     NULL,
                     PO_CORE_S.get_translated_text
                     (  'PO_SUB_PAY_ITEM_NE_LINE_AMT'
                     ,  'LINE_NUM', l_line_num(i)
                     ,  'PAY_ITEM_AMT', l_lineloc_amt_tbl(i)
                     ,  'LINE_AMT', l_line_amt_tbl(i)
                     ),
                      PO_CORE_S.get_translated_text
                    (  'PO_SUB_PRE_PAY_GE_LINE_AMT'
                    ,  'LINE_NUM', l_line_num(i)
                    ,  'PAY_ITEM_AMT', (l_lineloc_amt_tbl(i)-l_fin_adv_amount(i) )
                    ,  'ADV_AMT',  l_fin_adv_amount(i)
                    ,  'LINE_AMT', l_line_amt_tbl(i)
                    )
                  ),
            decode ( l_fin_adv_amount(i),
                     NULL,  'PO_SUB_PAY_ITEM_NE_LINE_AMT'
                   ,  'PO_SUB_PRE_PAY_GE_LINE_AMT'
                   )
          );

    l_progress := '027';
    --Increment the x_sequence with number of errors reported in last query
    x_sequence := x_sequence + SQL%ROWCOUNT;

   -- <<Bug#16498663 Start>>
   -- Check 1c: Determine whether the Recoupment Rate (%) is sufficient to recoup all advance payments for line.
   -- Advance amount on line should be less than or equal to the (Recoupment Rate on Line)*(Line Total)
    SELECT
        subtotal.line_num
    ,   subtotal.line_amount
    ,   subtotal.financing_advance_amount
	,   subtotal.recoupment_rate
    BULK COLLECT INTO
        l_line_num
    ,   l_line_amt_tbl
    ,   l_fin_adv_amount
	,   l_recoupment_rate
    FROM
    ( SELECT
        POL.line_num
      , CASE
          WHEN (    POL.order_type_lookup_code = 'FIXED PRICE'
                 OR POL.order_type_lookup_code = 'RATE')
	  THEN
	   CASE
              WHEN l_min_acct_unit IS NOT NULL THEN
                -- Round to minimum accountable unit.
                ROUND(
                      NVL(POL.amount,0) / l_min_acct_unit
                     ) * l_min_acct_unit
              ELSE
                -- Round to currency precision.
                ROUND(NVL(POL.amount,0), l_precision)
            END
          ELSE
            CASE
              WHEN l_min_acct_unit IS NOT NULL THEN
                -- Round to minimum accountable unit.
                ROUND(
                      NVL(POL.quantity * POL.unit_price,0) / l_min_acct_unit
                     ) * l_min_acct_unit
              ELSE
                -- Round to currency precision.
                ROUND(NVL(POL.quantity * POL.unit_price,0), l_precision)
            END
        END line_amount
     , SUM (CASE
          WHEN  PLL.payment_type = 'ADVANCE'
	  THEN
	    CASE
              WHEN l_min_acct_unit IS NOT NULL THEN
                -- Round to minimum accountable unit.
                ROUND(
                      NVL(PLL.amount,0) / l_min_acct_unit
                     ) * l_min_acct_unit
              ELSE
                -- Round to currency precision.
                ROUND(NVL(PLL.amount,0), l_precision)
            END
       END) financing_advance_amount
	 , NVL(POL.recoupment_rate, 0) recoupment_rate
      FROM
        PO_LINE_LOCATIONS PLL
      , PO_LINES POL
      WHERE
        POL.po_line_id = PLL.po_line_id
      AND POL.po_header_id = p_document_id
      AND nvl(POL.cancel_flag,'N') = 'N'
      AND nvl(POL.closed_code,'OPEN') <> 'FINALLY CLOSED'
      GROUP BY POL.line_num, POL.order_type_lookup_code, POL.amount
	, POL.quantity, POL.unit_price, POL.recoupment_rate
    ) subtotal
    WHERE NVL(subtotal.financing_advance_amount,0) >
	   (NVL2(l_min_acct_unit,
	      ROUND(
		   ((subtotal.recoupment_rate * subtotal.line_amount)/100) / l_min_acct_unit
	           ) * l_min_acct_unit,
	      ROUND((subtotal.recoupment_rate * subtotal.line_amount)/100, l_precision)));

    l_progress := '028';

    FOR i IN 1..l_line_num.COUNT LOOP
        l_rowCount(i) := i;
    END LOOP;

    FORALL i IN 1..l_line_num.COUNT
        INSERT INTO po_online_report_text_gt(online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
        message_name,
		message_type)
        VALUES(p_online_report_id,
            p_login_id,
            p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            l_line_num(i),
            NULL,
            NULL,
            x_sequence+ l_rowCount(i),
            PO_CORE_S.get_translated_text
             (  'PO_INSUFFICIENT_RECOUP_RATE'
             ,  'LINE_NUM', l_line_num(i)
			 ),
            'PO_INSUFFICIENT_RECOUP_RATE',
			'W'
          );

    l_progress := '029';
    --Increment the x_sequence with number of errors reported in last query
    x_sequence := x_sequence + SQL%ROWCOUNT;

	-- <<Bug#16498663 End>>

  END IF;  -- If Complex Work PO or not
-----------------------------------------------

  l_progress := '030';
  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
                      || l_progress,'PO Dist qty/amt rollup check');
     END IF;
  END IF;

    -- Check 2: The sum of the distribution quantities/amounts should match the
    -- shipment quantity/amount.

    SELECT
        POL.line_num
    ,   PLL.shipment_num
    ,   PLL.quantity
    ,   PLL.amount                                            -- <SERVICES FPJ>
    ,   sum( nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0) )
    ,   sum( nvl(POD.amount_ordered,0) - nvl(POD.amount_cancelled,0) )
    BULK COLLECT INTO
        l_line_num
    ,   l_shipment_num
    ,   l_lineloc_qty_tbl
    ,   l_lineloc_amt_tbl
    ,   l_dist_qty_tbl
    ,   l_dist_amt_tbl
    FROM PO_DISTRIBUTIONS_GT POD,PO_LINE_LOCATIONS_GT PLL, PO_LINES_GT POL
    WHERE PLL.po_line_id = POL.po_line_id
    AND POD.line_location_id = PLL.line_location_id
    AND PLL.po_header_id = p_document_id
    AND nvl(PLL.cancel_flag,'N') = 'N'
    AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND PLL.shipment_type in ('STANDARD', 'PLANNED', 'PREPAYMENT') --<Complex Work R12>
    GROUP BY
        POL.line_num
    ,   PLL.shipment_num
    ,   PLL.quantity
    ,   PLL.amount                                            -- <SERVICES FPJ>
    ,   PLL.amount_cancelled
    ,   PLL.quantity_cancelled
    ,   PLL.shipment_type   --<Complex Work R12>
    HAVING
        decode ( PLL.quantity                                 -- <SERVICES FPJ>
               , NULL , abs (   ( PLL.amount - nvl(PLL.amount_cancelled,0) )
                            -   sum( POD.amount_ordered - nvl(POD.amount_cancelled,0) ) )
               ,        abs (   ( PLL.quantity - nvl(PLL.quantity_cancelled,0) )
                            -   sum( POD.quantity_ordered - nvl(POD.quantity_cancelled,0) ) )
               ) > .00001;

    l_progress := '035';

    FOR i IN 1..l_line_num.COUNT LOOP
        l_rowCount(i) := i;
    END LOOP;

    FORALL i IN 1..l_line_num.COUNT
        INSERT INTO po_online_report_text_gt (online_report_id,
        last_update_login,
        last_updated_by,
        last_update_date,
        created_by,
        creation_date,
        line_num,
        shipment_num,
        distribution_num,
        sequence,
        text_line,
                                message_name)
        VALUES(
            p_online_report_id,
             p_login_id,
             p_user_id,
            sysdate,
            p_user_id,
            sysdate,
            l_line_num(i),
            l_shipment_num(i),
            NULL,                                             -- <SERVICES FPJ>
            x_sequence+l_rowCount(i),
            decode ( l_lineloc_qty_tbl(i)
                   , NULL , PO_CORE_S.get_translated_text
                            (   'PO_SUB_PO_SHIP_NE_DIST_AMT'
                            ,   'LINE_NUM', l_line_num(i)
                            ,   'SHIP_NUM', l_shipment_num(i)
                            ,   'SHIP_AMT', l_lineloc_amt_tbl(i)
                            ,   'DIST_AMT', l_dist_amt_tbl(i)
                            )
                          , PO_CORE_S.get_translated_text
                            (   'PO_SUB_PO_SHIP_NE_DIST_QTY'
                            ,   'LINE_NUM', l_line_num(i)
                            ,   'SHIP_NUM', l_shipment_num(i)
                            ,   'SHIP_QTY', l_lineloc_qty_tbl(i)
                            ,   'DIST_QTY', l_dist_qty_tbl(i)
                            )
                   ),
            decode ( l_lineloc_qty_tbl(i)
                   , NULL , 'PO_SUB_PO_SHIP_NE_DIST_AMT'
                   ,        'PO_SUB_PO_SHIP_NE_DIST_QTY'
                   )
            );

    l_progress := '037';
    --Increment the x_sequence with number of errors reported in last query
    x_sequence := x_sequence + l_line_num.COUNT;
-----------------------------------------------

  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
                      || l_progress,'End PO Qty/Amt Rollup Checks');
     END IF;
  END IF;

END check_po_qty_amt_rollup;
--<Complex Work R12 END>



--<BUG 4624736 START>
-- Checks if the pay item's price can be updated.
-- NOTE: does not verify that line location is in fact
-- a pay item.
FUNCTION is_pay_item_price_updateable (
  p_line_location_id          IN NUMBER
, p_add_reasons_to_msg_list   IN VARCHAR2)
RETURN BOOLEAN
IS

  d_module VARCHAR(70) :=
                'po.plsql.PO_DOCUMENT_CHECKS_PVT.is_pay_item_price_updateable';
  d_progress NUMBER;
  l_is_price_updateable BOOLEAN;
  l_quantity_received   NUMBER;
  l_quantity_billed     NUMBER;
  l_quantity_financed   NUMBER;

  --Bug 18372756:
  l_calling_sequence VARCHAR2(100) := 'PO_AP_DEBIT_MEMO_UNVALIDATED';
  l_unvalidated_debit_memo NUMBER;
  --End Bug 18372756

BEGIN
  d_progress := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_line_location_id', p_line_location_id);
  END IF;

  d_progress := 10;

  l_is_price_updateable := TRUE;

  -- get the execution quantities for the pay item
  SELECT NVL(pll.quantity_received, 0)
       , NVL(pll.quantity_billed, 0)
       , NVL(pll.quantity_financed, 0)
  INTO   l_quantity_received
       , l_quantity_billed
       , l_quantity_financed
  FROM   po_line_locations_all pll
  WHERE  line_location_id = p_line_location_id;

  d_progress := 20;

  -- the price is not updateable if the pay item has been executed
  -- against
  IF (    l_quantity_received <> 0
       OR l_quantity_billed <> 0
       OR l_quantity_financed <> 0)
  THEN
    l_is_price_updateable := FALSE;

    d_progress := 30;

    IF (p_add_reasons_to_msg_list = PO_CORE_S.G_PARAMETER_YES) THEN
      d_progress := 40;
      -- <Complex Work TODO>: FILL IN THE MESSAGES
      FND_MESSAGE.set_name('PO','CWPOTODOMESSAGE');
      FND_MSG_PUB.add;
    END IF;
  END IF;

    --Bug 18372756:
    ----------------------------------------------------------------------------
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
           AND (pll.quantity_billed = 0 OR pll.quantity_billed is null)
           AND por.po_header_id(+) = poh.po_header_id
           AND PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, por.po_release_id, pol.po_line_id, pll.line_location_id, NULL, NULL, l_calling_sequence) = 1);

      IF (l_unvalidated_debit_memo > 0) THEN
        l_is_price_updateable := FALSE;
      END IF;
      --End Bug 18372756

  d_progress := 50;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_is_price_updateable);
  END IF;

  RETURN(l_is_price_updateable);

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    RAISE;
END is_pay_item_price_updateable;
--<BUG 4624736 END>


 --Bug#5462677: copied from 11.5.9 code line of POXPOSCB.pls
 FUNCTION chk_unv_invoices(p_invoice_type	IN  VARCHAR2 DEFAULT 'BOTH',
			   p_po_header_id	IN  NUMBER,
			   p_po_release_id	IN  NUMBER DEFAULT NULL,
			   p_po_line_id		IN  NUMBER DEFAULT NULL,
			   p_line_location_id	IN  NUMBER DEFAULT NULL,
			   p_po_distribution_id	IN  NUMBER DEFAULT NULL,
			   p_invoice_id		IN  NUMBER DEFAULT NULL,
			   p_calling_sequence	IN  VARCHAR2) RETURN NUMBER IS

x_chk_unv_invoices NUMBER := 0;
BEGIN

  If Not AP_MATCH_UTILITIES_PUB.Check_Unvalidated_Invoices(
                              p_invoice_type => p_invoice_type,
                              p_po_header_id => p_po_header_id,
                              p_po_release_id => p_po_release_id,
                              p_po_line_id => p_po_line_id,
                              p_line_location_id => p_line_location_id,
                              p_po_distribution_id => p_po_distribution_id,
                              p_invoice_id => p_invoice_id,
                              p_calling_sequence => p_calling_sequence) THEN

    -- Unvalidated Credit Memos/Invoices Does Not Exists for this Shipment
    x_chk_unv_invoices := 0;
  Else
    -- Unvalidated Credit Memos/Invoices Do Exists for this Shipment
    x_chk_unv_invoices := 1;
  End If;

  return(x_chk_unv_invoices);

EXCEPTION
  WHEN OTHERS THEN
  PO_MESSAGE_S.APP_ERROR(error_name => 'PO_ALL_TRACE_ERROR',
                           token1 => 'FILE',
                           value1 => 'PO_CONTROL_CHECKS',
                           token2 => 'ERR_NUMBER',
                           value2 => '360',
                           token3 => 'SUBROUTINE',
                           value3 => 'CHK_UNV_INVOICES()');
  RAISE;

END chk_unv_invoices;
-- Determine if there are any unvalidated invoices
--Bug#5462677
PROCEDURE check_unvalidated_invoices(
   p_document_type        IN VARCHAR2
,  p_document_subtype     IN VARCHAR2
,  p_action_requested     IN VARCHAR2
,  p_action_date          IN DATE
,  p_online_report_id     IN NUMBER
,  p_user_id              IN NUMBER
,  p_login_id             IN NUMBER
,  p_document_level       IN VARCHAR2
,  p_origin_doc_id        IN NUMBER
,  p_doc_level_id         IN NUMBER
,  p_sequence             IN OUT NOCOPY NUMBER
,  x_return_status        OUT NOCOPY VARCHAR2
)
IS

l_textline  PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;
l_message_name  FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
l_calling_sequence VARCHAR2(100);
l_invoice_type     VARCHAR2(100) := 'BOTH';
l_is_complex_po     boolean;
l_token_value VARCHAR2(256);
l_return_status VARCHAR2(1);
d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_unvalidated_invoices';
d_progress NUMBER;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_action_date', p_action_date);
    PO_LOG.proc_begin(d_module, 'p_action_requested', p_action_requested);
    PO_LOG.proc_begin(d_module, 'p_online_report_id', p_online_report_id);
    PO_LOG.proc_begin(d_module, 'p_user_id', p_user_id);
    PO_LOG.proc_begin(d_module, 'p_login_id', p_login_id);
    PO_LOG.proc_begin(d_module, 'p_origin_doc_id', p_origin_doc_id);
    PO_LOG.proc_begin(d_module, 'p_document_level', p_document_level);
    PO_LOG.proc_begin(d_module, 'p_doc_level_id', p_doc_level_id);
    PO_LOG.proc_begin(d_module, 'p_sequence', p_sequence);
  END IF;


  d_progress := 10;

  -- Initialize the error mesage before hand, since we need this in
  -- the finallyclose/unreserve check sql
  -- Error Messages for Finally close hdr/line/shipment and Release
  -- Error Messages for Unreserve SPO

  get_message_info(p_document_type    => p_document_type ,
                   p_document_subtype => p_document_subtype,
                   p_action_requested => p_action_requested ,
                   p_document_level   => p_document_level,
                   p_doc_level_id     => p_doc_level_id,
                   x_text_line        => l_textline,
                   x_message_name     => l_message_name,
                   x_invoice_type     => l_invoice_type ,
                   x_calling_sequence => l_calling_sequence,
                   x_return_status    => l_return_status);

  IF p_document_type = 'PO' AND p_document_subtype = 'STANDARD'
     AND (p_document_level = g_document_level_HEADER
       OR p_document_level = g_document_level_LINE) THEN
     --
     -- Handle Header final close / Unreserve SPO
     --
    IF  (p_document_level = g_document_level_HEADER) THEN

        INSERT INTO PO_ONLINE_REPORT_TEXT_GT
        (  online_report_id
        ,  last_update_login
        ,  last_updated_by
        ,  last_update_date
        ,  created_by
        ,  creation_date
        ,  line_num
        ,  shipment_num
        ,  distribution_num
        ,  sequence
        ,  text_line
        ,  message_name
        )
        SELECT
           p_online_report_id
        ,  p_login_id
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  null -- lines
        ,  null -- shipments
        ,  null -- distribution_num
        ,  p_sequence + ROWNUM
        ,  substr(l_textline, 1, 240)
        ,  l_message_name
        FROM po_headers_gt poh
        WHERE poh.po_header_id = p_doc_level_id
          AND  chk_unv_invoices(l_invoice_type, poh.po_header_id, NULL, NULL,NULL, NULL, p_origin_doc_id, l_calling_sequence) = 1;

     --
     -- Handle Line final close / Unreserve SPO
     --
    ELSIF (p_document_level = g_document_level_LINE) THEN
        INSERT INTO PO_ONLINE_REPORT_TEXT_GT
        (  online_report_id
        ,  last_update_login
        ,  last_updated_by
        ,  last_update_date
        ,  created_by
        ,  creation_date
        ,  line_num
        ,  shipment_num
        ,  distribution_num
        ,  sequence
        ,  text_line
        ,  message_name
        )
        SELECT
           p_online_report_id
        ,  p_login_id
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  line_num -- lines
        ,  null -- shipments
        ,  null -- distribution_num
        ,  p_sequence + ROWNUM
        ,  substr(l_textline, 1, 240)
        ,  l_message_name
        FROM po_lines_gt pol
        WHERE pol.po_line_id=p_doc_level_id
          AND  chk_unv_invoices(l_invoice_type, pol.po_header_id, NULL, pol.po_line_id,NULL, NULL, p_origin_doc_id, 'CHECK_PO_LINE_FINAL_CLOSE') = 1;
    END IF;
  --
  -- Handle Release Header related checks for unvalidated AP Invoices
  --
  ELSIF (p_document_type = 'RELEASE' AND p_document_level = g_document_level_HEADER) THEN
    INSERT INTO PO_ONLINE_REPORT_TEXT_GT
    (  online_report_id
        ,  last_update_login
        ,  last_updated_by
        ,  last_update_date
        ,  created_by
        ,  creation_date
        ,  line_num
        ,  shipment_num
        ,  distribution_num
        ,  sequence
        ,  text_line
        ,  message_name
    )
    SELECT
           p_online_report_id
        ,  p_login_id
        ,  p_user_id
        ,  SYSDATE
        ,  p_user_id
        ,  SYSDATE
        ,  null -- lines
        ,  null -- shipments
        ,  null -- distribution_num
        ,  p_sequence + ROWNUM
        ,  substr(l_textline, 1, 240)
        ,  l_message_name
    FROM po_releases_gt por
    WHERE por.po_release_id=p_doc_level_id
     AND  chk_unv_invoices(l_invoice_type, por.po_header_id, por.po_release_id, NULL,NULL, NULL, p_origin_doc_id, l_calling_sequence) = 1;

   --
   -- Handle Shipment/Payitem final close and Unreserve(Both SPO and Release)
   --
  ELSIF (p_document_level = g_document_level_SHIPMENT) THEN
      INSERT INTO PO_ONLINE_REPORT_TEXT_GT
      (  online_report_id
      ,  last_update_login
      ,  last_updated_by
      ,  last_update_date
      ,  created_by
      ,  creation_date
      ,  line_num
      ,  shipment_num
      ,  distribution_num
      ,  sequence
      ,  text_line
      ,  message_name
      )
      SELECT
         p_online_report_id
      ,  p_login_id
      ,  p_user_id
      ,  SYSDATE
      ,  p_user_id
      ,  SYSDATE
      ,  null -- lines
      ,  shipment_num -- shipments
      ,  null -- distribution_num
      ,  p_sequence + ROWNUM
      ,  substr(l_textline, 1, 240)
      ,  l_message_name
      FROM po_line_locations_gt poll
      WHERE poll.line_location_id=p_doc_level_id
        AND  chk_unv_invoices(l_invoice_type, poll.po_header_id, poll.po_release_id, NULL,poll.line_location_id, NULL, p_origin_doc_id, l_calling_sequence) = 1;
   --
   -- Handle Distribution Unreserve(for both SPO/Release)
   --
  ELSIF (p_document_level=g_document_level_DISTRIBUTION  AND p_action_requested = g_action_UNRESERVE) THEN
      INSERT INTO PO_ONLINE_REPORT_TEXT_GT
      (  online_report_id
      ,  last_update_login
      ,  last_updated_by
      ,  last_update_date
      ,  created_by
      ,  creation_date
      ,  line_num
      ,  shipment_num
      ,  distribution_num
      ,  sequence
      ,  text_line
      ,  message_name
      )
      SELECT
         p_online_report_id
      ,  p_login_id
      ,  p_user_id
      ,  SYSDATE
      ,  p_user_id
      ,  SYSDATE
      ,  null -- lines
      ,  null -- shipments
      ,  distribution_num
      ,  p_sequence + ROWNUM
      ,  substr(l_textline, 1, 240)
      ,  l_message_name
      FROM po_distributions_gt pod
      WHERE pod.po_distribution_id=p_doc_level_id
        AND  chk_unv_invoices(l_invoice_type, pod.po_header_id, pod.po_release_id, NULL,NULL, pod.po_distribution_id, p_origin_doc_id, l_calling_sequence) = 1;
  END IF; --

  d_progress := 20;

  p_sequence := p_sequence + SQL%ROWCOUNT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'p_sequence', p_sequence);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;
END check_unvalidated_invoices;

PROCEDURE get_message_info(p_document_type    IN VARCHAR2,
                           p_document_subtype IN VARCHAR2,
                           p_action_requested IN VARCHAR2,
                           p_document_level   IN VARCHAR2,
                           p_doc_level_id     IN NUMBER,
                           x_text_line        OUT  NOCOPY VARCHAR2,
                           x_message_name     OUT  NOCOPY VARCHAR2,
                           x_invoice_type     OUT  NOCOPY VARCHAR2,
                           x_calling_sequence OUT  NOCOPY VARCHAR2,
                           x_return_status    OUT  NOCOPY VARCHAR2) IS

  l_textline         PO_ONLINE_REPORT_TEXT_GT.text_line%TYPE;
  l_message_name     FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
  l_calling_sequence VARCHAR2(100);
  l_invoice_type     VARCHAR2(100) := 'BOTH';
  l_is_complex_po    boolean := false;
  l_document_id      NUMBER;
  d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.get_message_text';
  d_progress NUMBER;
BEGIN
  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
    PO_LOG.proc_begin(d_module, 'p_action_requested', p_action_requested);
    PO_LOG.proc_begin(d_module, 'p_document_level', p_document_level);
    PO_LOG.proc_begin(d_module, 'p_doc_level_id', p_doc_level_id);
  END IF;

  IF p_document_subtype = 'STANDARD' THEN
    IF p_document_level = g_document_level_HEADER THEN
     l_document_id := p_doc_level_id;
    ELSIF p_document_level = g_document_level_LINE THEN
      SELECT po_header_id
      INTO   l_document_id
      FROM   po_lines_gt
      WHERE po_line_id=p_doc_level_id;
    ELSIF p_document_level = g_document_level_SHIPMENT THEN
      SELECT po_header_id
      INTO   l_document_id
      FROM   po_line_locations_gt
      WHERE line_location_id=p_doc_level_id;
    ELSIF p_document_level = g_document_level_DISTRIBUTION THEN
      SELECT po_header_id
      INTO   l_document_id
      FROM   po_distributions_gt
      WHERE  po_distribution_id=p_doc_level_id;
    END IF;
    IF p_document_type <> g_document_type_RELEASE THEN
      l_is_complex_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(l_document_id);
    END IF;
  END IF;

  IF (p_action_requested = g_action_UNRESERVE) THEN
-- bug#16471988 : not allow to unreseved when there are unvalidated
-- invoices too, not just credit memos
--
--    l_invoice_type     := 'CREDIT';
   l_invoice_type     := 'BOTH';    -- bug#16471988

    IF (p_document_level = g_document_level_HEADER) THEN
       l_message_name     := 'PO_UNRES_AP_DOCS_PENDING';
       l_textline         := FND_MESSAGE.GET_STRING('PO',l_message_name);
    ELSIF (p_document_level = g_document_level_LINE) THEN
       l_message_name     := 'PO_UNRES_POL_AP_DOCS_PENDING';
       l_textline         := FND_MESSAGE.GET_STRING('PO',l_message_name);
    ELSIF (p_document_level = g_document_level_SHIPMENT) THEN
       IF (l_is_complex_po) THEN
         l_message_name     := 'PO_UNRES_POPI_AP_DOCS_PENDING';
         l_textline         := FND_MESSAGE.GET_STRING('PO',l_message_name);
       ELSE
         l_message_name     := 'PO_UNRES_POLL_AP_DOCS_PENDING';
         l_textline         := FND_MESSAGE.GET_STRING('PO',l_message_name);
       END IF;
    ELSIF (p_document_level = g_document_level_DISTRIBUTION) THEN
       l_message_name     := 'PO_UNRES_POD_AP_DOCS_PENDING';
       l_textline         := FND_MESSAGE.GET_STRING('PO',l_message_name);
    END IF;
  ELSIF (p_action_requested = g_action_FINAL_CLOSE_CHECK) THEN
    l_invoice_type     := 'BOTH';

    IF (p_document_level = g_document_level_HEADER) THEN
       l_message_name     := 'PO_FC_POH_AP_DOCS_PENDING';
       l_textline         := FND_MESSAGE.GET_STRING('PO',l_message_name);
    ELSIF (p_document_level = g_document_level_LINE) THEN
       l_message_name     := 'PO_FC_POL_AP_DOCS_PENDING';
       l_textline         := FND_MESSAGE.GET_STRING('PO',l_message_name);
    ELSIF (p_document_level = g_document_level_SHIPMENT) THEN
       IF (l_is_complex_po) THEN
         l_message_name     := 'PO_FC_POPI_AP_DOCS_PENDING';
         l_textline         := FND_MESSAGE.GET_STRING('PO',l_message_name);
       ELSE
         l_message_name     := 'PO_FC_POLL_AP_DOCS_PENDING';
         l_textline         := FND_MESSAGE.GET_STRING('PO',l_message_name);
       END IF;
    END IF;
  END IF;
  l_calling_sequence := l_message_name; -- can be any string(tracking in AP)

  x_message_name     := l_message_name;
  x_text_line        := l_textline;
  x_calling_sequence := l_calling_sequence;
  x_invoice_type     := l_invoice_type;
  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_text_line', x_text_line);
    PO_LOG.proc_end(d_module, 'x_message_name', x_message_name);
    PO_LOG.proc_end(d_module, 'x_invoice_type', x_invoice_type);
    PO_LOG.proc_end(d_module, 'x_calling_sequence', x_calling_sequence);
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;
END;

PROCEDURE set_lcm_flag(p_line_location_id  IN NUMBER,
			p_doc_check_status IN VARCHAR2,
			x_return_status    OUT nocopy VARCHAR2)
IS

l_return_status VARCHAR2(10) := NULL;
l_vendor_id NUMBER;
l_vendor_site_id NUMBER;
l_inventory_item_id NUMBER;
l_ship_to_organization_id NUMBER;
l_consigned_flag VARCHAR2(20);
l_outsourced_assembly VARCHAR2(20);
l_log_head VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.Set_LCM_Flag';
l_progress VARCHAR2(3) := '000';
l_line_location_id po_line_locations_all.line_location_id%TYPE; --<BUG 10377000>


BEGIN
  IF g_debug_stmt THEN
     PO_DEBUG.debug_begin(l_log_head);
     PO_DEBUG.debug_var(l_log_head,l_progress,'p_line_location_id',   p_line_location_id);
     PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_check_status',   p_doc_check_status);
  END IF;

  l_progress := '001';
  --<BUG 7594807 Added Table Alias>
  --<BUG 8233135 Added exception block for the below sql to avoid
  --errors while supplier user tries to split the shipment lines
  --while performing supplier change request>
  --<BUG 10377000 fetching line location id to pass to inv_check_lcm>
  BEGIN
	SELECT poh.vendor_id,
	       poh.vendor_site_id,
  	       pol.item_id,
  	       poll.ship_to_organization_id,
  	       poll.consigned_flag,
  	       poll.outsourced_assembly,
	       poll.line_location_id
          INTO l_vendor_id,
  	       l_vendor_site_id,
  	       l_inventory_item_id,
  	       l_ship_to_organization_id,
  	       l_consigned_flag,
  	       l_outsourced_assembly,
	       l_line_location_id
          FROM po_line_locations_all poll,
    	       po_lines_all pol,
    	       po_headers_all poh
         WHERE poh.po_header_id = pol.po_header_id
           AND pol.po_line_id = poll.po_line_id
           AND poll.line_location_id = p_line_location_id;
  EXCEPTION
  WHEN OTHERS THEN
	NULL;
  END;

     IF g_debug_stmt THEN
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_vendor_id',l_vendor_id);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_vendor_site_id',l_vendor_site_id);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_inventory_item_id',l_inventory_item_id);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_ship_to_organization_id',l_ship_to_organization_id);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_consigned_flag',l_consigned_flag);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_outsourced_assembly',l_outsourced_assembly);
	    PO_DEBUG.debug_var(l_log_head,l_progress,'l_line_location_id',l_line_location_id);
      END IF;

    l_progress:= '002';

    --<BUG 7594807 Call the Inventory API only when the PO line has item so that
    -- we can avoid the call for other line types>
    IF ( l_inventory_item_id IS NOT NULL ) THEN

	l_return_status := inv_utilities.inv_check_lcm(l_inventory_item_id,
  						       l_ship_to_organization_id,
  						       l_consigned_flag,
						       l_outsourced_assembly,
						       l_vendor_id,
						       l_vendor_site_id,
						       l_line_location_id); --<BUG 10377000>

    END IF;


    PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status',l_return_status);

      IF l_return_status = 'Y' THEN
      	IF p_doc_check_status = 'BEFORE' THEN
      		UPDATE po_line_locations_gt
		  SET lcm_flag = 'Y'
		  WHERE line_location_id = p_line_location_id
		  and lcm_flag is null;

		UPDATE po_distributions_gt
		  SET lcm_flag = 'Y'
                  WHERE line_location_id = p_line_location_id
                  and lcm_flag is null;

		UPDATE po_line_locations_gt
		  SET match_option = 'R'
                  WHERE line_location_id = p_line_location_id
                  and lcm_flag = 'Y'; --Bug 16655207

        ELSIF p_doc_check_status = 'AFTER' THEN

                UPDATE po_line_locations_all
                 SET lcm_flag = 'Y'
                 WHERE line_location_id = p_line_location_id;

                UPDATE po_distributions_all
                SET lcm_flag = 'Y'
                WHERE line_location_id = p_line_location_id;

		UPDATE po_line_locations_all
                 SET match_option = 'R'
                 WHERE line_location_id = p_line_location_id;

       END IF;

      ELSIF l_return_status = 'N' THEN

      		UPDATE po_line_locations_all
		 SET lcm_flag = null
		 WHERE line_location_id = p_line_location_id
		 AND lcm_flag = 'Y';

		UPDATE po_distributions_all
		 SET lcm_flag = null
                 WHERE line_location_id = p_line_location_id
                 AND lcm_flag = 'Y';

      END IF;

  x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
  WHEN others THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;

    IF (g_debug_unexp) THEN
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                      FND_LOG.string(FND_LOG.level_unexpected, l_log_head || '.others_exception', 'EXCEPTION: Location is '
                           || l_progress || ' SQL CODE is '||sqlcode);
                    END IF;
    END IF;

  END set_lcm_flag;



 -- Bug 10300018
 PROCEDURE PO_UOM_CHECK(P_DOCUMENT_ID		IN NUMBER,
 		       P_DOCUMENT_TYPE          IN VARCHAR2,
                        P_ONLINE_REPORT_ID	IN NUMBER,
                        P_USER_ID		IN NUMBER,
                        P_LOGIN_ID		IN NUMBER,
                        P_SEQUENCE		IN OUT NOCOPY NUMBER,
                        X_RETURN_STATUS		OUT NOCOPY VARCHAR2
                         ,x_msg_data             OUT NOCOPY VARCHAR2) IS


  L_TEXTLINE  PO_ONLINE_REPORT_TEXT.TEXT_LINE%TYPE := NULL;
 L_API_NAME  CONSTANT VARCHAR2(40) := 'PO_UOM_CHECK';
 L_PROGRESS VARCHAR2(3);
 TYPE CCID_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 L_CCID CCID_TYPE;

 BEGIN
 L_PROGRESS := '000';

 L_PROGRESS := '001';
   IF G_DEBUG_STMT THEN
           PO_DEBUG.DEBUG_STMT(G_LOG_HEAD || '.'||L_API_NAME||'.',
                               L_PROGRESS,'PO_LINE_SHIP_UOM_MISMATCH');
        END IF;

   l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_LINE_SHIP_UOM_MISMATCH');
  IF P_DOCUMENT_TYPE ='RELEASE'   THEN

   INSERT INTO PO_ONLINE_REPORT_TEXT_GT
                   (ONLINE_REPORT_ID,
                    LAST_UPDATE_LOGIN,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    CREATED_BY,
                    CREATION_DATE,
                       LINE_NUM,
                    SHIPMENT_NUM,
                    DISTRIBUTION_NUM,
                    SEQUENCE,
                    TEXT_LINE,
                    MESSAGE_NAME)
       SELECT P_ONLINE_REPORT_ID,
               P_LOGIN_ID,
               P_USER_ID,
               SYSDATE,
               P_USER_ID,
               SYSDATE,
               POL.LINE_NUM,
               PLL.SHIPMENT_NUM,
               0,
               P_SEQUENCE + ROWNUM,
               PO_CORE_S.get_translated_text
                             ('PO_LINE_SHIP_UOM_MISMATCH'
                             ,   'LINE_NUM',  POL.LINE_NUM
                             ,   'SHIP_NUM',  PLL.SHIPMENT_NUM
                              ),
 	      'PO_LINE_SHIP_UOM_MISMATCH'

        FROM
            PO_LINE_LOCATIONS_ALL PLL,
 	    	  PO_LINES_ALL POL
        WHERE  POL.PO_LINE_ID=PLL.PO_LINE_ID
 	     AND NVL(PLL.unit_meas_lookup_code,-1) <> NVL(POL.unit_meas_lookup_code,-1)
          AND NVL(PLL.cancel_flag, 'N') = 'N' --Bug 19292777
          AND NVL(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED' --Bug 19292777
          AND   PLL.PO_RELEASE_ID = P_DOCUMENT_ID;

    ELSIF P_DOCUMENT_TYPE ='PO'   THEN  -- Bug 12760632 [Restricting UOM mismatch check for Agreements]

  INSERT INTO PO_ONLINE_REPORT_TEXT_GT
                   (ONLINE_REPORT_ID,
                    LAST_UPDATE_LOGIN,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    CREATED_BY,
                    CREATION_DATE,
                    LINE_NUM,
                    SHIPMENT_NUM,
                    DISTRIBUTION_NUM,
                    SEQUENCE,
                    TEXT_LINE,
                    MESSAGE_NAME)
       SELECT P_ONLINE_REPORT_ID,
               P_LOGIN_ID,
               P_USER_ID,
               SYSDATE,
               P_USER_ID,
               SYSDATE,
               POL.LINE_NUM,
               PLL.SHIPMENT_NUM,
               0,
               P_SEQUENCE + ROWNUM,
               PO_CORE_S.get_translated_text
                             ('PO_LINE_SHIP_UOM_MISMATCH'
                             ,   'LINE_NUM',  POL.LINE_NUM
                             ,   'SHIP_NUM',  PLL.SHIPMENT_NUM
                              ),
 	      'PO_LINE_SHIP_UOM_MISMATCH'

        FROM
           PO_LINE_LOCATIONS_ALL PLL,
 		  PO_LINES_ALL POL
	WHERE  POL.PO_LINE_ID=PLL.PO_LINE_ID
 	AND NVL(PLL.unit_meas_lookup_code,-1)<>NVL(POL.unit_meas_lookup_code,-1)
        AND (PLL.VALUE_BASIS <>'FIXED PRICE'  -- Bug 12332819 # Do not consider Advance and Fixed Priced Shipments
              AND (PLL.PAYMENT_TYPE IS  NULL   -- Consider Non Complex PO shipments with value basis <> fixed price
                    OR PLL.PAYMENT_TYPE <>'RATE')) --Bug 12332819 #  Do not consider the Rate type Pay items
        AND NVL(PLL.cancel_flag, 'N') = 'N' --Bug 19292777
        AND NVL(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED' --Bug 19292777
        AND POL.PO_HEADER_ID = P_DOCUMENT_ID  ;

   END IF;

     P_SEQUENCE := P_SEQUENCE + SQL%ROWCOUNT;
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     X_MSG_DATA := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                   P_ENCODED => 'F');
     X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN FND_API.G_EXC_ERROR THEN
     X_MSG_DATA := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                   P_ENCODED => 'F');
     X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
     IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, L_API_NAME);
     END IF;

     IF (G_DEBUG_UNEXP) THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, G_LOG_HEAD ||
                      L_API_NAME || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                      || L_PROGRESS || ' SQL CODE IS '||SQLCODE);
       END IF;
     END IF;

     X_MSG_DATA := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                   P_ENCODED => 'F');
     X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

 END;


 ---Added for bug12951645
-- Updated for bug#14181634
 -- Details:
 --      1) Changed WIP Job validation process:
 --         Rather using GET_WIP_JOB_STATUS, we are using WIP_OSP_JOBS_VAL_V
 --      2) Validation restricted to STANDARD POs alone in PO category.
 --      3) Using GT tables as a standard approach.
 --      4) Error message suffixed with relevent information like shipment ,release etc.
 -- Updated for bug#15939036
-- Details:
--   Instead of checking the WO invalid state from view WIP_OSP_JOBSVAL_V
--   checking the status from WIP_DISCRETE_JOBS table.Whichever WO is not in
--   status 3,4,6 are treated as invalid WO's.As the validation from view is failing for
--   some flows when WO is created from EAM.Please refer bug for further details.
--
/**
* Procedure: CHECK_CLOSE_WIP_JOB
* Requires:
*   IN PARAMETERS:
*       p_document_id:      The requisition_header_id of submitted document
*       p_document_type     Document type.  Use the g_doc_type_<> variables, where <> is:
*				--    REQUISITION
*				--    PA
*				--    PO
*				--    RELEASE
*       p_online_report_id: Id used to INSERT INTO online_report_text table
*       p_user_id:          User performing the action
*       p_login_id:         Last update login_id
*   IN OUT PARAMETERS
*       p_sequence:          Sequence number of last reported error
* Modifies: Inserts error msgs in online_report_text_gt table, uses
*           global_temp tables for processing
* Effects:  This procedure runs the document submission checks for all documents
* Returns:
*  p_sequence: This parameter contains the current count of number of error
*              messages inserted
*/
 PROCEDURE CHECK_CLOSE_WIP_JOB(p_document_id			IN NUMBER,
                                p_document_type			IN  VARCHAR2,
                                p_online_report_id		IN NUMBER,
				p_user_id			IN NUMBER,
				p_login_id			IN NUMBER,
				p_sequence			IN OUT NOCOPY NUMBER,
				x_return_status			OUT NOCOPY VARCHAR2
				)  IS
   l_progress NUMBER := 0;
   l_document_id NUMBER := 0;
   l_api_name CONSTANT VARCHAR2(30) := 'CHECK_CLOSE_WIP_JOB';
   l_text_line PO_ONLINE_REPORT_TEXT.text_line%TYPE := NULL;
   l_log_head VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.CHECK_CLOSE_WIP_JOB';



BEGIN

  l_text_line := FND_MESSAGE.GET_STRING('PO', 'PO_CLOSE_WIP_JOB');
  --Start of Process
  --When document type is REQUISITION
  IF (p_document_type =  g_document_type_REQUISITION) THEN
  l_progress := 10;
    --Why:To check whether passed document has its associated WIP JOB closed or not?

     INSERT INTO PO_ONLINE_REPORT_TEXT_GT
	   (  online_report_id
	   ,  last_update_login
	   ,  last_updated_by
	   ,  last_update_date
	   ,  created_by
	   ,  creation_date
	   ,  line_num
	   ,  shipment_num
	   ,  distribution_num
	   ,  sequence
	   ,  text_line
	   ,  message_name
	   )

    SELECT p_online_report_id,
	   p_login_id,
	   p_user_id,
	   SYSDATE,
	   p_user_id,
	   SYSDATE,
	   prl.line_num,
     	   0,
           0,
	   p_sequence+ ROWNUM,
	   l_text_line||
           ' on line '             ||
           prl.line_num,
	   'PO_CLOSE_WIP_JOB'
     FROM   po_req_headers_gt prh,
            po_req_lines_gt prl
     WHERE prh.requisition_header_id = prl.requisition_header_id
     AND   nvl(prh.authorization_status,'INCOMPLETE') <> 'APPROVED'
     AND   nvl(prl.cancel_flag,'N') = 'N'
     AND   nvl(prl.closed_code,'OPEN') NOT IN ('FINALLY CLOSED' , 'CLOSED')
     AND   prl.requisition_header_id = p_document_id
     AND   prl.wip_entity_id IS NOT NULL --Bug 14383315
     --bug 19159537:No need to validate for OPM batch(entity_type=10)
     AND EXISTS (SELECT ENTITY_TYPE
                   FROM WIP_ENTITIES
                   WHERE WIP_ENTITY_ID =prl.wip_entity_id
                   AND ENTITY_TYPE <> 10)
     AND   NOT EXISTS (SELECT 'JOB IS VALID'
	                                 FROM    wip_discrete_jobs wdj
				         WHERE prl.wip_entity_id = wdj.wip_entity_id
					 AND      wdj.status_type IN (3,4,6)
				       );
     --- Document type other then RELEASE
 ELSIF  p_document_type =  g_document_type_RELEASE THEN
 --- Document type RELEASE
	l_progress := 20;
 -- bug 16973568: Allow the shipments which in status CLOSED FOR RECEIVING and
 --               CLOSED FOR INVOICE pass this check.
  INSERT INTO PO_ONLINE_REPORT_TEXT_GT
	   (  online_report_id
	   ,  last_update_login
	   ,  last_updated_by
	   ,  last_update_date
	   ,  created_by
	   ,  creation_date
	   ,  line_num
	   ,  shipment_num
	   ,  distribution_num
	   ,  sequence
	   ,  text_line
	   ,  message_name
	   )

        SELECT p_online_report_id,
	   p_login_id,
	   p_user_id,
	   SYSDATE,
	   p_user_id,
	   SYSDATE,
	   0,
     	   pll.shipment_num,
     	   pd.distribution_num,
	   p_sequence+ ROWNUM,
	   l_text_line||
     	   ' on distribution '     ||
     	   pd.distribution_num     ||
     	   ' of shipment '         ||
     	   pll.shipment_num,
	   'PO_CLOSE_WIP_JOB'
	FROM po_headers_gt ph,
		 po_line_locations_gt pll,
		 po_distributions_gt pd,
		 po_releases_gt pr
	WHERE   1=1
	AND ph.po_header_id = pll.po_header_id
	AND pll.line_location_id = pd.line_location_id
	AND pr.po_release_id (+) = pd.po_release_id
	AND nvl(pll.approved_flag,'N') <> 'Y'
	AND nvl(pll.cancel_flag,'N') <> 'Y'
	AND nvl(pll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED' , 'CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED FOR INVOICE')
	AND  pr.po_release_id = p_document_id
	AND  pd.wip_entity_id IS NOT NULL --Bug 14383315
        --bug 17866951: pass this validation if shipment open quantity = 0.
        AND NVL(pll.QUANTITY,0) <> NVL(pll.QUANTITY_RECEIVED,0)
	--bug:19159537 No need to validate for OPM batch(entity_type=10)
        AND EXISTS (SELECT ENTITY_TYPE
                   FROM WIP_ENTITIES
                   WHERE WIP_ENTITY_ID = pd.wip_entity_id
                   AND ENTITY_TYPE <> 10)
	AND   NOT EXISTS (SELECT 'JOB IS VALID'
	                                 FROM    wip_discrete_jobs wdj
				         WHERE pd.wip_entity_id = wdj.wip_entity_id
					 AND      wdj.status_type IN (3,4,6)
				       );
ELSE--Other than document type RELEASE,REQUISITION
  	INSERT INTO PO_ONLINE_REPORT_TEXT_GT
	   (  online_report_id
	   ,  last_update_login
	   ,  last_updated_by
	   ,  last_update_date
	   ,  created_by
	   ,  creation_date
	   ,  line_num
	   ,  shipment_num
	   ,  distribution_num
	   ,  sequence
	   ,  text_line
	   ,  message_name
	   )

	SELECT p_online_report_id,
	   p_login_id,
	   p_user_id,
	   SYSDATE,
	   p_user_id,
	   SYSDATE,
	   pl.line_num,
     	   pll.shipment_num,
     	   pd.distribution_num,
	   p_sequence+ ROWNUM,
	   l_text_line||
     	   ' on distribution '     ||
     	   pd.distribution_num     ||
     	   ' of shipment '         ||
     	   pll.shipment_num        ||
     	   ' of line '             ||
     	   pl.line_num,
	   'PO_CLOSE_WIP_JOB'
	FROM po_headers_gt ph,
		 po_lines_gt pl,
		 po_line_locations_gt pll,
		 po_distributions_gt pd
	WHERE   1=1
	AND ph.po_header_id = pl.po_header_id
  	AND pl.po_line_id=pll.po_line_id
	AND ph.type_lookup_code = 'STANDARD'
	AND pll.line_location_id = pd.line_location_id
	AND nvl(pll.approved_flag,'N') <> 'Y'
	AND nvl(pll.cancel_flag,'N') <> 'Y'
	AND nvl(pll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED' , 'CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED FOR INVOICE')
	AND ph.po_header_id = p_document_id
	AND pd.wip_entity_id IS NOT NULL --Bug 14383315
        --bug 17866951: pass this validation if shipment open quantity = 0.
        AND NVL(pll.QUANTITY,0) <> NVL(pll.QUANTITY_RECEIVED,0)
	--bug:19159537 No need to validate for OPM batch(entity_type=10)
        AND EXISTS (SELECT ENTITY_TYPE
                   FROM WIP_ENTITIES
                   WHERE WIP_ENTITY_ID = pd.wip_entity_id
                   AND ENTITY_TYPE <> 10)
	AND   NOT EXISTS (SELECT 'JOB IS VALID'
	                                 FROM    wip_discrete_jobs wdj
				         WHERE pd.wip_entity_id = wdj.wip_entity_id
					 AND      wdj.status_type IN (3,4,6)
				       );
END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
 NULL;

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(g_log_head||l_api_name, l_progress, SQLCODE || ': ' || SQLERRM);
      PO_LOG.proc_end(g_log_head||l_api_name, 'p_sequence', p_sequence);
      PO_LOG.proc_end(g_log_head||l_api_name, 'x_return_status', x_return_status);
      PO_LOG.proc_end(g_log_head||l_api_name);
    END IF;
END CHECK_CLOSE_WIP_JOB;

--End of Code added for bug 12951645

--<Bug 13019003>
--Added this procedure
--bug 16856753: INstead of using validate_account_wrapper,
--gl_code_combinations table is used to validate accounts.
--security rule validations of accounts do not take place in this procedure
--as this procedure is called during approval flows.
PROCEDURE PO_VALIDATE_ACCOUNTS(
	P_DOCUMENT_ID      IN NUMBER,
	P_DOCUMENT_TYPE    IN VARCHAR2,
	P_ONLINE_REPORT_ID IN NUMBER,
	P_USER_ID          IN NUMBER,
	P_LOGIN_ID         IN NUMBER,
	P_SEQUENCE         IN OUT NOCOPY NUMBER,
	X_RETURN_STATUS OUT NOCOPY       VARCHAR2,
	x_msg_data OUT NOCOPY            VARCHAR2 )
IS

  L_TEXTLINE PO_ONLINE_REPORT_TEXT.TEXT_LINE%TYPE := NULL;
  L_TEXTLINE2 PO_ONLINE_REPORT_TEXT.TEXT_LINE%TYPE := NULL;
  L_API_NAME              CONSTANT VARCHAR2( 40 ) := 'PO_VALIDATE_ACCOUNTS';
  L_PROGRESS              VARCHAR2( 3 );
  l_seed_message_invalid  VARCHAR2( 30 );
  l_seed_message_not_null VARCHAR2( 30 );
BEGIN

   L_PROGRESS := '001';
   IF G_DEBUG_STMT THEN
   PO_DEBUG.DEBUG_STMT( G_LOG_HEAD ||'.'||L_API_NAME||'.', L_PROGRESS, 'PO_VALIDATE_ACCOUNTS' );
   END IF;


   IF( P_DOCUMENT_TYPE = 'REQUISITION' ) THEN

   L_PROGRESS := '002';
   IF G_DEBUG_STMT THEN
   PO_DEBUG.DEBUG_STMT( G_LOG_HEAD ||'.' || L_API_NAME ||'.', L_PROGRESS, 'REQUISITION' );
   END IF;

   -- Validate Req Charge Account
   INSERT INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
   	)
   SELECT
	   p_online_report_id,
	   p_login_id,
	   p_user_id,
	   SYSDATE,
	   p_user_id,
	   SYSDATE,
	   PRL.line_num,
	   0,
	   PRD.distribution_num,
	   p_sequence + ROWNUM,
	   SUBSTR( Nvl2( PRD.code_combination_id,
   	      fnd_message.Get_string( 'PO','PO_RI_INVALID_CHARGE_ACC_ID' ),
	      fnd_message.Get_string( 'PO','PO_CHARGE_NOT_NULL' )
	   )               ||
	   ' on distribution '    ||
	   PRD.distribution_num   ||
	   ' of line '            ||
	   PRL.line_num, 1, 240
	   ),
	   Nvl2( PRD.code_combination_id, 'PO_RI_INVALID_CHARGE_ACC_ID','PO_CHARGE_NOT_NULL' )
   FROM
	   po_req_distributions_gt PRD,
	   po_req_lines_gt PRL,
	   gl_sets_of_books sob
   WHERE
	   PRD.requisition_line_id = PRL.requisition_line_id
	   AND PRL.requisition_header_id = p_document_id
	   AND sob.set_of_books_id = prd.set_of_books_id
	   AND nvl(PRL.cancel_flag, 'N') <> 'Y'
	   AND( PRD.code_combination_id IS NULL
            or
			(
			PRD.code_combination_id IS NOT NULL
			AND
			not exists (
			select 'valid record in gcc'
			from gl_code_combinations gcc
			where gcc.code_combination_id = PRD.code_combination_id
			AND gcc.enabled_flag = 'Y'
			AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
			AND gcc.summary_flag = 'N'
			AND gcc.detail_posting_allowed_flag = 'Y'
			AND (trunc(SYSDATE) BETWEEN  trunc( nvl(start_date_active, SYSDATE) ) AND trunc( nvl(end_date_active, SYSDATE) ) )
			)
	   ));

   p_sequence := p_sequence + SQL%ROWCOUNT;


   -- Validate Req Budget Account
   IF PO_CORE_S.is_encumbrance_on( p_doc_type => p_document_type, p_org_id => NULL ) THEN
   INSERT INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   p_online_report_id,
	   p_login_id,
	   p_user_id,
	   SYSDATE,
	   p_user_id,
	   SYSDATE,
	   PRL.line_num,
	   0,
	   PRD.distribution_num,
	   p_sequence + ROWNUM,
	   SUBSTR( Nvl2( prd.budget_account_id,
	   fnd_message.Get_string( 'PO','PO_RI_INVALID_BUDGET_ACC_ID' ),
	   fnd_message.Get_string( 'PO','PO_BUDGET_NOT_NULL' )
	   ) ||
	   ' on distribution '      ||
	   PRD.distribution_num     ||
	   ' of line '              ||
	   PRL.line_num, 1, 240
	   ),
	   Nvl2( prd.budget_account_id, 'PO_RI_INVALID_BUDGET_ACC_ID', 'PO_BUDGET_NOT_NULL' )
   FROM
	   po_req_distributions_gt PRD,
	   po_req_lines_gt PRL,
	   gl_sets_of_books sob
   WHERE
	   PRD.requisition_line_id = PRL.requisition_line_id
	   AND PRL.requisition_header_id = p_document_id
	   AND sob.set_of_books_id = prd.set_of_books_id
	   AND nvl(PRL.cancel_flag, 'N') <> 'Y'
     /*17182012 Budget account check should only be performed if encumbrance is on.
     Eventhough there is an if condition above which returns true for an organization, all the shopfloor type
     distributions wont have encumbrance on. Capturing that check here */
     AND(
	     PRL.DESTINATION_TYPE_CODE <> 'SHOP FLOOR'
		  OR (
		  PRL.DESTINATION_TYPE_CODE = 'SHOP FLOOR'
		  AND PRL.wip_entity_id IS NOT NULL
		  AND(SELECT entity_type from wip_entities where wip_entity_id = PRL.wip_entity_id) = 6
		  AND NVL(PRD.PREVENT_ENCUMBRANCE_FLAG,'N') = 'N'	-- BUG 18841512
		  )
  	)
	  /*17182012 End1 */
	   AND( prd.budget_account_id IS NULL
            or
			(
			PRD.budget_account_id IS NOT NULL
			AND
			not exists (
			select 'valid record in gcc'
			from gl_code_combinations gcc
			where gcc.code_combination_id = PRD.budget_account_id
			AND gcc.enabled_flag = 'Y'
			AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
			AND gcc.summary_flag = 'N'
			AND gcc.detail_posting_allowed_flag = 'Y'
			AND (trunc(nvl(prd.gl_encumbered_date,SYSDATE)) BETWEEN
			trunc( nvl(start_date_active, nvl(prd.gl_encumbered_date,SYSDATE)) ) AND trunc( nvl(end_date_active, nvl(prd.gl_encumbered_date,SYSDATE) ))
			)
	   )));
   p_sequence := p_sequence + SQL%ROWCOUNT;

   END IF; ---End iSEncumbranceOn Check


   -- Validate Req Variance Account
   INSERT INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   p_online_report_id,
	   p_login_id,
	   p_user_id,
	   SYSDATE,
	   p_user_id,
	   SYSDATE,
	   PRL.line_num,
	   0,
	   PRD.distribution_num,
	   p_sequence + ROWNUM,
	   SUBSTR( Nvl2( prd.variance_account_id,
	   fnd_message.Get_string( 'PO','PO_RI_INVALID_VARIANCE_ACC_ID' ),
	   fnd_message.Get_string( 'PO', 'PO_VARIANCE_NOT_NULL' )
	   ) ||
	   ' on distribution '      ||
	   PRD.distribution_num     ||
	   ' of line '              ||
	   PRL.line_num, 1, 240
	   ),
	   Nvl2( prd.variance_account_id, 'PO_RI_INVALID_VARIANCE_ACC_ID', 'PO_VARIANCE_NOT_NULL' )
   FROM
	   po_req_distributions_gt PRD,
	   po_req_lines_gt PRL,
	   gl_sets_of_books sob
   WHERE
	   PRD.requisition_line_id = PRL.requisition_line_id
	   AND PRL.requisition_header_id = p_document_id
	   AND sob.set_of_books_id = prd.set_of_books_id
	   AND nvl(PRL.cancel_flag, 'N') <> 'Y'
	   AND( prd.variance_account_id IS NULL
            or
			(
			PRD.variance_account_id IS NOT NULL
			AND
			not exists (
			select 'valid record in gcc'
			from gl_code_combinations gcc
			where gcc.code_combination_id = PRD.variance_account_id
			AND gcc.enabled_flag = 'Y'
			AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
			AND gcc.summary_flag = 'N'
			AND gcc.detail_posting_allowed_flag = 'Y'
			AND (trunc(SYSDATE) BETWEEN  trunc( nvl(start_date_active, SYSDATE) ) AND trunc( nvl(end_date_active, SYSDATE) ))
			)
	   ));

   p_sequence := p_sequence + SQL%ROWCOUNT;


   -- Validate Req Accrual Account
   INSERT INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   p_online_report_id,
	   p_login_id,
	   p_user_id,
	   SYSDATE,
	   p_user_id,
	   SYSDATE,
	   PRL.line_num,
	   0,
	   PRD.distribution_num,
	   p_sequence + ROWNUM,
	   SUBSTR( Nvl2( prd.accrual_account_id,
	   fnd_message.Get_string( 'PO', 'PO_RI_INVALID_ACCRUAL_ACC_ID' ),
	   fnd_message.Get_string( 'PO', 'PO_ACCRUAL_NOT_NULL' )
	   ) ||
	   ' on distribution '      ||
	   PRD.distribution_num     ||
	   ' of line '              ||
	   PRL.line_num, 1, 240
	   ),
	   Nvl2( prd.accrual_account_id, 'PO_RI_INVALID_ACCRUAL_ACC_ID', 'PO_ACCRUAL_NOT_NULL' )
   FROM
	   po_req_distributions_gt PRD,
	   po_req_lines_gt PRL,
	   gl_sets_of_books sob
   WHERE
	   PRD.requisition_line_id = PRL.requisition_line_id
	   AND PRL.requisition_header_id = p_document_id
	   AND sob.set_of_books_id = prd.set_of_books_id
	   AND nvl(PRL.cancel_flag, 'N') <> 'Y'
	   AND( prd.accrual_account_id IS NULL
           or
			(
			PRD.accrual_account_id IS NOT NULL
			AND
			not exists (
			select 'valid record in gcc'
			from gl_code_combinations gcc
			where gcc.code_combination_id = PRD.accrual_account_id
			AND gcc.enabled_flag = 'Y'
			AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
			AND gcc.summary_flag = 'N'
			AND gcc.detail_posting_allowed_flag = 'Y'
			AND (trunc(SYSDATE) BETWEEN  trunc( nvl(start_date_active, SYSDATE) ) AND trunc( nvl(end_date_active, SYSDATE) ))
			)
	   ));


   p_sequence := p_sequence + SQL%ROWCOUNT;


   --  Account Validations of releases

   ELSIF( P_DOCUMENT_TYPE = 'RELEASE' ) THEN

   L_PROGRESS := '003';
   IF G_DEBUG_STMT THEN
   PO_DEBUG.DEBUG_STMT( G_LOG_HEAD ||'.'|| L_API_NAME ||'.', L_PROGRESS, 'RELEASE' );
   END IF;


   -- Validate Release Charge Account for non cancelled, non finally closed, not approved shipments.
   INSERT INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   P_ONLINE_REPORT_ID,
	   P_LOGIN_ID,
	   P_USER_ID,
	   SYSDATE,
	   P_USER_ID,
	   SYSDATE,
	   POD.PO_LINE_ID,
	   POLL.shipment_num,
	   POD.DISTRIBUTION_NUM,
	   P_SEQUENCE + ROWNUM,
	   SUBSTR( Nvl2( PoD.code_combination_id,
	   fnd_message.Get_string( 'PO', 'PO_RI_INVALID_CHARGE_ACC_ID' ),
	   fnd_message.Get_string( 'PO', 'PO_CHARGE_NOT_NULL' )
	   )||
	   ' on distribution '     ||
	   POD.DISTRIBUTION_NUM    ||
	   ' of shipment '         ||
	   POLL.shipment_num, 1, 240
	   ),
	   Nvl2( PoD.code_combination_id, 'PO_RI_INVALID_CHARGE_ACC_ID', 'PO_CHARGE_NOT_NULL' )
   FROM
	   PO_DISTRIBUTIONS_GT POD,
	   gl_sets_of_books sob,
	   PO_LINE_LOCATIONS_GT POLL
   WHERE
	   POD.PO_RELEASE_ID = P_DOCUMENT_ID
	   AND POD.line_location_id = POLL.line_location_id
	   AND POD.line_location_id IS NOT NULL
	   AND sob.set_of_books_id = pod.set_of_books_id
	   AND NVL( POLL.APPROVED_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CANCEL_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CLOSED_CODE, 'OPEN' ) <> 'FINALLY CLOSED'
	   AND( POD.CODE_COMBINATION_ID IS NULL
            or
			(
			POD.CODE_COMBINATION_ID IS NOT NULL
			AND
			not exists (
			select 'valid record in gcc'
			from gl_code_combinations gcc
			where gcc.code_combination_id = POD.CODE_COMBINATION_ID
			AND gcc.enabled_flag = 'Y'
			AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
			AND gcc.summary_flag = 'N'
			AND gcc.detail_posting_allowed_flag = 'Y'
			AND (trunc(SYSDATE) BETWEEN  trunc( nvl(start_date_active, SYSDATE) ) AND trunc( nvl(end_date_active, SYSDATE) ))
			)
	   ));
   p_sequence := p_sequence + SQL%ROWCOUNT;


   -- Validate Release Budget Account for non cancelled, non finally closed, not approved shipments.
   IF PO_CORE_S.is_encumbrance_on( p_doc_type => 'PO', p_org_id => NULL ) THEN

   INSERT INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   P_ONLINE_REPORT_ID,
	   P_LOGIN_ID,
	   P_USER_ID,
	   SYSDATE,
	   P_USER_ID,
	   SYSDATE,
	   POD.PO_LINE_ID,
	   POLL.shipment_num,
	   POD.DISTRIBUTION_NUM,
	   P_SEQUENCE + ROWNUM,
	   SUBSTR( Nvl2( PoD.budget_account_id,
	   fnd_message.Get_string( 'PO', 'PO_RI_INVALID_BUDGET_ACC_ID' ),
	   fnd_message.Get_string( 'PO', 'PO_BUDGET_NOT_NULL' )
	   )||
	   ' on distribution '     ||
	   POD.DISTRIBUTION_NUM    ||
	   ' of shipment '         ||
	   POLL.shipment_num, 1, 240
	   ),
	   Nvl2( PoD.budget_account_id, 'PO_RI_INVALID_BUDGET_ACC_ID', 'PO_BUDGET_NOT_NULL' )
   FROM
	   PO_DISTRIBUTIONS_GT POD,
	   gl_sets_of_books sob,
	   PO_LINE_LOCATIONS_GT POLL
   WHERE
	   POD.PO_RELEASE_ID = P_DOCUMENT_ID
	   AND POD.line_location_id = POLL.line_location_id
	   AND POD.line_location_id IS NOT NULL
	   AND sob.set_of_books_id = pod.set_of_books_id
	   AND NVL( POLL.APPROVED_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CANCEL_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CLOSED_CODE, 'OPEN' ) <> 'FINALLY CLOSED'

	   /*17182012 Budget account check should only be performed if encumbrance is on.
	   Eventhough there is an if condition above which returns true for an organization, all the shopfloor type
	   distributions wont have encumbrance on. Capturing that check here */
	   AND(
	       POD.DESTINATION_TYPE_CODE <> 'SHOP FLOOR'
	        OR (
	        POD.DESTINATION_TYPE_CODE = 'SHOP FLOOR'
		    AND POD.wip_entity_id IS NOT NULL
			AND(SELECT entity_type from wip_entities where wip_entity_id = POD.wip_entity_id) = 6
			AND NVL(POD.PREVENT_ENCUMBRANCE_FLAG,'N') = 'N'		-- BUG 18841512
			)
		 )
		 /*17182012 End2 */

	   AND( POD.budget_account_id IS NULL
             or
			(
			POD.budget_account_id IS NOT NULL
			AND
			not exists (
			select 'valid record in gcc'
			from gl_code_combinations gcc
			where gcc.code_combination_id = POD.budget_account_id
			AND gcc.enabled_flag = 'Y'
			AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
			AND gcc.summary_flag = 'N'
			AND gcc.detail_posting_allowed_flag = 'Y'
			AND (trunc(nvl(pod.gl_encumbered_date,SYSDATE)) BETWEEN
			trunc( nvl(start_date_active, nvl(pod.gl_encumbered_date,SYSDATE)) ) AND trunc( nvl(end_date_active, nvl(pod.gl_encumbered_date,SYSDATE)) ))
			)
	   ));
   p_sequence := p_sequence + SQL%ROWCOUNT;

   END IF; --- Enc on Check


   -- Validate Release Accrual Account for shipments which are not approved atleast once.
   INSERT INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   P_ONLINE_REPORT_ID,
	   P_LOGIN_ID,
	   P_USER_ID,
	   SYSDATE,
	   P_USER_ID,
	   SYSDATE,
	   POD.PO_LINE_ID,
	   POLL.shipment_num,
	   POD.DISTRIBUTION_NUM,
	   P_SEQUENCE + ROWNUM,
	   SUBSTR( Nvl2( PoD.accrual_account_id,
	   fnd_message.Get_string( 'PO', 'PO_RI_INVALID_ACCRUAL_ACC_ID' ),
	   fnd_message.Get_string( 'PO', 'PO_ACCRUAL_NOT_NULL' )
	   )||
	   ' on distribution '      ||
	   POD.DISTRIBUTION_NUM     ||
	   ' of shipment '          ||
	   POLL.shipment_num, 1, 240
	   ),
	   Nvl2( PoD.accrual_account_id, 'PO_RI_INVALID_ACCRUAL_ACC_ID', 'PO_ACCRUAL_NOT_NULL' )
   FROM
	   PO_DISTRIBUTIONS_GT POD,
	   gl_sets_of_books sob,
	   PO_LINE_LOCATIONS_GT POLL
   WHERE
	   POD.PO_RELEASE_ID = P_DOCUMENT_ID
	   AND POD.line_location_id = POLL.line_location_id
	   AND POD.line_location_id IS NOT NULL
	   AND sob.set_of_books_id = pod.set_of_books_id
	   AND POLL.APPROVED_DATE IS NULL
	   AND NVL( POLL.CANCEL_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CLOSED_CODE, 'OPEN' ) <> 'FINALLY CLOSED'
	   AND( POD.accrual_account_id IS NULL
             or
			(
			POD.accrual_account_id IS NOT NULL
			AND
			not exists (
			select 'valid record in gcc'
			from gl_code_combinations gcc
			where gcc.code_combination_id = POD.accrual_account_id
			AND gcc.enabled_flag = 'Y'
			AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
			AND gcc.summary_flag = 'N'
			AND gcc.detail_posting_allowed_flag = 'Y'
			AND (trunc(SYSDATE) BETWEEN  trunc( nvl(start_date_active, SYSDATE) ) AND trunc( nvl(end_date_active, SYSDATE) ))
			)
	   ));
   p_sequence := p_sequence + SQL%ROWCOUNT;


   -- Validate Release Variance Account for shipments which are not approved atleast once.
   INSERT 	INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   P_ONLINE_REPORT_ID,
	   P_LOGIN_ID,
	   P_USER_ID,
	   SYSDATE,
	   P_USER_ID,
	   SYSDATE,
	   POD.PO_LINE_ID,
	   POLL.shipment_num,
	   POD.DISTRIBUTION_NUM,
	   P_SEQUENCE + ROWNUM,
	   SUBSTR( Nvl2( PoD.variance_account_id,
	   fnd_message.Get_string( 'PO', 'PO_RI_INVALID_VARIANCE_ACC_ID' ),
	   fnd_message.Get_string( 'PO', 'PO_VARIANCE_NOT_NULL' )
	   )||
	   ' on distribution '       ||
	   POD.DISTRIBUTION_NUM      ||
	   ' of shipment '           ||
	   POLL.shipment_num, 1, 240
	   ),
	   Nvl2( PoD.variance_account_id, 'PO_RI_INVALID_VARIANCE_ACC_ID', 'PO_VARIANCE_NOT_NULL' )
   FROM
	   PO_DISTRIBUTIONS_GT POD,
	   gl_sets_of_books sob,
	   PO_LINE_LOCATIONS_GT POLL
   WHERE
	   POD.PO_RELEASE_ID = P_DOCUMENT_ID
	   AND POD.line_location_id = POLL.line_location_id
	   AND POD.line_location_id IS NOT NULL
	   AND sob.set_of_books_id = pod.set_of_books_id
	   AND POLL.APPROVED_DATE IS NULL
	   AND NVL( POLL.CANCEL_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CLOSED_CODE, 'OPEN' ) <> 'FINALLY CLOSED'
	   AND( POD.variance_account_id IS NULL
             or
			(
			POD.variance_account_id IS NOT NULL
			AND
			not exists (
			select 'valid record in gcc'
			from gl_code_combinations gcc
			where gcc.code_combination_id = POD.variance_account_id
			AND gcc.enabled_flag = 'Y'
			AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
			AND gcc.summary_flag = 'N'
			AND gcc.detail_posting_allowed_flag = 'Y'
			AND (trunc(SYSDATE) BETWEEN  trunc( nvl(start_date_active, SYSDATE) ) AND trunc( nvl(end_date_active, SYSDATE) ))
			)

	   ));
   p_sequence := p_sequence + SQL%ROWCOUNT;


   ELSE
   --validating the PO Accounts


   L_PROGRESS := '004';
   IF G_DEBUG_STMT THEN
   PO_DEBUG.DEBUG_STMT( G_LOG_HEAD ||'.'|| L_API_NAME ||'.', L_PROGRESS, 'PO or BPA' );
   END IF;

   -- Validate PO Charge Account
   INSERT 	INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   P_ONLINE_REPORT_ID,
	   P_LOGIN_ID,
	   P_USER_ID,
	   SYSDATE,
	   P_USER_ID,
	   SYSDATE,
	   POL.line_num,
	   POLL.shipment_num,
	   POD.DISTRIBUTION_NUM,
	   P_SEQUENCE + ROWNUM,
	   SUBSTR( Nvl2( PoD.code_combination_id,
	   fnd_message.Get_string( 'PO', 'PO_RI_INVALID_CHARGE_ACC_ID' ),
	   fnd_message.Get_string( 'PO', 'PO_CHARGE_NOT_NULL' )
	   )||
	   ' on distribution '     ||
	   POD.DISTRIBUTION_NUM    ||
	   ' of shipment '         ||
	   POLL.shipment_num       ||
	   ' of line '             ||
	   POL.line_num, 1, 240
	   ),
	   Nvl2( PoD.code_combination_id, 'PO_RI_INVALID_CHARGE_ACC_ID', 'PO_CHARGE_NOT_NULL' )
   FROM
	   PO_DISTRIBUTIONS_GT POD,
	   gl_sets_of_books sob,
	   PO_LINE_LOCATIONS_GT POLL,
	   PO_LINES_GT POL
   WHERE
	   POD.PO_HEADER_ID = P_DOCUMENT_ID
	   AND POD.line_location_id = POLL.line_location_id
	   AND POLL.po_line_id = POL.po_line_id
	   AND sob.set_of_books_id = pod.set_of_books_id
	   AND NVL( POLL.APPROVED_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CANCEL_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CLOSED_CODE, 'OPEN' ) <> 'FINALLY CLOSED'
	   AND( POD.CODE_COMBINATION_ID IS NULL
	        or
			(
			POD.CODE_COMBINATION_ID IS NOT NULL
			AND
			not exists (
			select 'valid record in gcc'
			from gl_code_combinations gcc
			where gcc.code_combination_id = POD.CODE_COMBINATION_ID
			AND gcc.enabled_flag = 'Y'
			AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
			AND gcc.summary_flag = 'N'
			AND gcc.detail_posting_allowed_flag = 'Y'
			AND (trunc(SYSDATE) BETWEEN  trunc( nvl(start_date_active, SYSDATE) ) AND trunc( nvl(end_date_active, SYSDATE) ))
			)

	   ));
   p_sequence := p_sequence + SQL%ROWCOUNT;


   -- Validate PO/BPA Budget Account
   IF PO_CORE_S.is_encumbrance_on( p_doc_type => 'PO', p_org_id => NULL ) THEN
   -- Validate PO/BPA Budget Account
   INSERT	INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   P_ONLINE_REPORT_ID,
	   P_LOGIN_ID,
	   P_USER_ID,
	   SYSDATE,
	   P_USER_ID,
	   SYSDATE,
	   POL.line_num,
	   POLL.shipment_num,
	   POD.DISTRIBUTION_NUM,
	   P_SEQUENCE + ROWNUM,
	   SUBSTR( Nvl2( PoD.budget_account_id,
	   fnd_message.Get_string( 'PO','PO_RI_INVALID_BUDGET_ACC_ID' ),
	   fnd_message.Get_string( 'PO', 'PO_BUDGET_NOT_NULL' )
	   )||
	   ' on distribution '     ||
	   POD.DISTRIBUTION_NUM    ||
	   ' of shipment '         ||
	   POLL.shipment_num       ||
	   ' of line '             ||
	   POL.line_num, 1, 240
	   ),
	   Nvl2( PoD.budget_account_id, 'PO_RI_INVALID_BUDGET_ACC_ID', 'PO_BUDGET_NOT_NULL' )
   FROM
	   PO_DISTRIBUTIONS_GT POD,
	   gl_sets_of_books sob,
	   PO_LINE_LOCATIONS_GT POLL,
	   PO_LINES_GT POL
   WHERE
	   POD.PO_HEADER_ID = P_DOCUMENT_ID
	   AND POD.po_release_id IS NULL
	   AND POD.line_location_id = POLL.line_location_id(+)
	   AND POLL.po_line_id = POL.po_line_id(+)
	   AND sob.set_of_books_id = pod.set_of_books_id
	   AND NVL( POLL.APPROVED_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CANCEL_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CLOSED_CODE, 'OPEN' ) <> 'FINALLY CLOSED'

           ---<Bug 14664343: Begin>
           AND POD.distribution_type = 'STANDARD'
	   ---<Bug 14664343: End>

	   /*17182012 Budget account check should only be performed if encumbrance is on.
	   Eventhough there is an if condition above which returns true for an organization, all the shopfloor type
	   distributions wont have encumbrance on. Capturing that check here */
	   AND(
	       POD.DESTINATION_TYPE_CODE <> 'SHOP FLOOR'
	        OR (
	        POD.DESTINATION_TYPE_CODE = 'SHOP FLOOR'
		    AND POD.wip_entity_id IS NOT NULL
			 AND(SELECT entity_type from wip_entities where wip_entity_id = POD.wip_entity_id) = 6
			 AND NVL(POD.PREVENT_ENCUMBRANCE_FLAG,'N') = 'N'	-- BUG 18841512
			 )
	 	 )
		 /*17182012 End3 */

	   AND( POD.budget_account_id IS NULL
 	        or
			(
			POD.budget_account_id IS NOT NULL
			AND
			not exists (
			select 'valid record in gcc'
			from gl_code_combinations gcc
			where gcc.code_combination_id = POD.budget_account_id
			AND gcc.enabled_flag = 'Y'
			AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
			AND gcc.summary_flag = 'N'
			AND gcc.detail_posting_allowed_flag = 'Y'
			AND (trunc(nvl(pod.gl_encumbered_date,SYSDATE)) BETWEEN
			trunc( nvl(start_date_active, nvl(pod.gl_encumbered_date,SYSDATE)) ) AND trunc( nvl(end_date_active, nvl(pod.gl_encumbered_date,SYSDATE)) ))
			)
	   ));
   p_sequence := p_sequence + SQL%ROWCOUNT;
   END IF; --- Enc on Check


   -- Validate PO Accrual Account on shipments which are not approved atleast once.
   INSERT	INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   P_ONLINE_REPORT_ID,
	   P_LOGIN_ID,
	   P_USER_ID,
	   SYSDATE,
	   P_USER_ID,
	   SYSDATE,
	   POL.line_num,
	   POLL.shipment_num,
	   POD.DISTRIBUTION_NUM,
	   P_SEQUENCE + ROWNUM,
	   SUBSTR( Nvl2( PoD.accrual_account_id,
	   fnd_message.Get_string( 'PO','PO_RI_INVALID_ACCRUAL_ACC_ID' ),
	   fnd_message.Get_string( 'PO','PO_ACCRUAL_NOT_NULL' )
	   )||
	   ' on distribution '      ||
	   POD.DISTRIBUTION_NUM     ||
	   ' of shipment '          ||
	   POLL.shipment_num        ||
	   ' of line '              ||
	   POL.line_num, 1, 240
	   ),
	   Nvl2( PoD.accrual_account_id, 'PO_RI_INVALID_ACCRUAL_ACC_ID', 'PO_ACCRUAL_NOT_NULL' )
   FROM
	   PO_DISTRIBUTIONS_GT POD,
	   gl_sets_of_books sob,
	   PO_LINE_LOCATIONS_GT POLL,
	   PO_LINES_GT POL
   WHERE
	   POD.PO_HEADER_ID = P_DOCUMENT_ID
	   AND POD.line_location_id = POLL.line_location_id
	   AND POLL.po_line_id = POL.po_line_id
	   AND sob.set_of_books_id = pod.set_of_books_id
	   AND POLL.APPROVED_DATE IS NULL
	   AND NVL( POLL.CANCEL_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CLOSED_CODE, 'OPEN' ) <> 'FINALLY CLOSED'
	   AND( POD.accrual_account_id IS NULL
	   	    or
			(
			POD.accrual_account_id IS NOT NULL
			AND
			not exists (
			select 'valid record in gcc'
			from gl_code_combinations gcc
			where gcc.code_combination_id = POD.accrual_account_id
			AND gcc.enabled_flag = 'Y'
			AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
			AND gcc.summary_flag = 'N'
			AND gcc.detail_posting_allowed_flag = 'Y'
			AND (trunc(SYSDATE) BETWEEN  trunc( nvl(start_date_active, SYSDATE) ) AND trunc( nvl(end_date_active, SYSDATE) ))
			)

	   ));

   p_sequence := p_sequence + SQL%ROWCOUNT;


   -- Validate PO Variance Account on shipments which are not approved atleast once.
   INSERT	INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   P_ONLINE_REPORT_ID,
	   P_LOGIN_ID,
	   P_USER_ID,
	   SYSDATE,
	   P_USER_ID,
	   SYSDATE,
	   POL.line_num,
	   POLL.shipment_num,
	   POD.DISTRIBUTION_NUM,
	   P_SEQUENCE + ROWNUM,
	   SUBSTR( Nvl2( PoD.variance_account_id,
	   fnd_message.Get_string( 'PO', 'PO_RI_INVALID_VARIANCE_ACC_ID' ),
	   fnd_message.Get_string( 'PO', 'PO_VARIANCE_NOT_NULL' )
	   )||
	   ' on distribution '       ||
	   POD.DISTRIBUTION_NUM      ||
	   ' of shipment '           ||
	   POLL.shipment_num         ||
	   ' of line '               ||
	   POL.line_num, 1, 240
	   ),
	   Nvl2( PoD.variance_account_id, 'PO_RI_INVALID_VARIANCE_ACC_ID', 'PO_VARIANCE_NOT_NULL' )
   FROM
	   PO_DISTRIBUTIONS_GT POD,
	   gl_sets_of_books sob,
	   PO_LINE_LOCATIONS_GT POLL,
	   PO_LINES_GT POL
   WHERE
	   POD.PO_HEADER_ID = P_DOCUMENT_ID
	   AND POD.line_location_id = POLL.line_location_id
	   AND POLL.po_line_id = POL.po_line_id
	   AND sob.set_of_books_id = pod.set_of_books_id
	   AND POLL.APPROVED_DATE IS NULL
	   AND NVL( POLL.CANCEL_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CLOSED_CODE, 'OPEN' ) <> 'FINALLY CLOSED'
	   AND( POD.variance_account_id IS NULL
	   	    or
			(
			POD.variance_account_id IS NOT NULL
			AND
			not exists (
			select 'valid record in gcc'
			from gl_code_combinations gcc
			where gcc.code_combination_id = POD.variance_account_id
			AND gcc.enabled_flag = 'Y'
			AND gcc.chart_of_accounts_id = sob.chart_of_accounts_id
			AND gcc.summary_flag = 'N'
			AND gcc.detail_posting_allowed_flag = 'Y'
			AND (trunc(SYSDATE) BETWEEN  trunc( nvl(start_date_active, SYSDATE) ) AND trunc( nvl(end_date_active, SYSDATE) ))

	   )));
   p_sequence := p_sequence + SQL%ROWCOUNT;

   END IF;

   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     X_MSG_DATA := FND_MSG_PUB.GET( P_MSG_INDEX => FND_MSG_PUB.G_LAST, P_ENCODED => 'F' );
     X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN FND_API.G_EXC_ERROR THEN
     X_MSG_DATA := FND_MSG_PUB.GET( P_MSG_INDEX => FND_MSG_PUB.G_LAST, P_ENCODED => 'F' );
     X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

     -- SQLStmtGetText(mycontext, l_dyn_string, size1, size2 );
     IF FND_MSG_PUB.CHECK_MSG_LEVEL( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, L_API_NAME );
     END IF;

     IF( G_DEBUG_UNEXP ) THEN
      IF( FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED ) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED, G_LOG_HEAD ||
       L_API_NAME                                           ||
       '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '       ||
       L_PROGRESS                                           ||
       ' SQL CODE IS '                                      ||
       SQLCODE );
      END IF;
     END IF;

     X_MSG_DATA := FND_MSG_PUB.GET( P_MSG_INDEX => FND_MSG_PUB.G_LAST,
     P_ENCODED => 'F' );
     X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

END PO_VALIDATE_ACCOUNTS;
--<Bug 13019003> End------------------------------------------

   --<Bug 13019003>
   --Added this function.
   --<bug 16856753> reverted the fix done to use wf attributes.
   --This function is called only from data entry flows.
   --Currently, save action of BWC order and copy document flows
   --use this function.

FUNCTION validate_account_wrapper(
	p_structure_number IN NUMBER,
	p_combination_id  IN NUMBER,
	p_val_date IN DATE)
RETURN VARCHAR2  IS
	l_concat_segs VARCHAR2(2000);
	l_result1 BOOLEAN;

	--Added as part of bug 16021525 fix
	L_API_NAME CONSTANT VARCHAR2( 40 ) := 'validate_account_wrapper';
	L_PROGRESS  VARCHAR2( 3 );

BEGIN

	L_PROGRESS := '001';
	IF G_DEBUG_STMT THEN
		PO_DEBUG.DEBUG_STMT( G_LOG_HEAD ||'.'|| L_API_NAME ||'.', L_PROGRESS, 'p_structure_number :'||p_structure_number );
		PO_DEBUG.DEBUG_STMT( G_LOG_HEAD ||'.'|| L_API_NAME ||'.', L_PROGRESS, 'p_combination_id :'||p_combination_id );
		PO_DEBUG.DEBUG_STMT( G_LOG_HEAD ||'.'|| L_API_NAME ||'.', L_PROGRESS, 'p_val_date :'||p_val_date );
	END IF;

	l_concat_segs := fnd_flex_ext.get_segs(
			application_short_name => 'SQLGL',
			key_flex_code => 'GL#',
			structure_number => p_structure_number,
			combination_id => p_combination_id
		) ;

	L_PROGRESS := '002';
	IF G_DEBUG_STMT THEN
		PO_DEBUG.DEBUG_STMT( G_LOG_HEAD ||'.'|| L_API_NAME ||'.', L_PROGRESS, 'l_concat_segs :'||l_concat_segs );
	END IF;

IF( l_concat_segs IS NULL)
then
	L_PROGRESS := '003';
	RETURN 'N';
else

	L_PROGRESS := '004';

	IF G_DEBUG_STMT THEN
		PO_DEBUG.DEBUG_STMT( G_LOG_HEAD ||'.'|| L_API_NAME ||'.', L_PROGRESS, 'calling fnd_flex_keyval.validate_segs');
	END IF;


	gl_global.set_aff_validation('XX',null);


		l_result1 := fnd_flex_keyval.validate_segs(
			operation => 'CHECK_COMBINATION',
			appl_short_name => 'SQLGL',
			key_flex_code => 'GL#',
			structure_number => p_structure_number,
			concat_segments => l_concat_segs,
			validation_date => P_val_date,
			vrule => '\nSUMMARY_FLAG\nI' ||
			'\nAPPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\nN\0' ||
			'GL_GLOBAL\nDETAIL_POSTING_ALLOWED\nI\nNAME=PO_ALL_POSTING_NA\nY'
			);

END IF;

IF(l_result1) THEN RETURN 'Y'; ELSE RETURN 'N'; END IF;

END  validate_account_wrapper;


---Bug 15843328
PROCEDURE check_accrue_on_receipt(
                       P_DOCUMENT_ID		IN NUMBER,
		       P_DOCUMENT_TYPE		IN VARCHAR2,
                       P_ONLINE_REPORT_ID	IN NUMBER,
                       P_USER_ID		IN NUMBER,
                       P_LOGIN_ID		IN NUMBER,
                       P_SEQUENCE		IN OUT NOCOPY NUMBER,
                       X_RETURN_STATUS		OUT NOCOPY VARCHAR2,
                       x_msg_data               OUT NOCOPY VARCHAR2
                       )IS

  L_TEXTLINE PO_ONLINE_REPORT_TEXT.TEXT_LINE%TYPE := fnd_message.Get_string( 'PO','PO_RI_INVALID_ACCRUE_ON_RCT' );
  L_API_NAME              CONSTANT VARCHAR2( 40 ) := 'check_accrue_on_receipt';
  L_PROGRESS              VARCHAR2( 3 );

BEGIN

   L_PROGRESS := '001';
   IF G_DEBUG_STMT THEN
   PO_DEBUG.DEBUG_STMT( G_LOG_HEAD ||'.'||L_API_NAME||'.', L_PROGRESS, 'check_accrue_on_receipt' );
   END IF;

IF ( P_DOCUMENT_TYPE = 'PO') THEN

 INSERT	INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   P_ONLINE_REPORT_ID,
	   P_LOGIN_ID,
	   P_USER_ID,
	   SYSDATE,
	   P_USER_ID,
	   SYSDATE,
	   POL.line_num,
	   POLL.shipment_num,
	   POD.DISTRIBUTION_NUM,
	   P_SEQUENCE + ROWNUM,
	   'Between Shipment '||POLL.shipment_num||
           ' and Distribution '||POD.DISTRIBUTION_NUM ||
           ' of Line '||POL.line_num||' , '|| L_TEXTLINE,
           'PO_RI_INVALID_ACCRUE_ON_RCT'
   FROM
	   PO_DISTRIBUTIONS_GT POD,
           PO_LINE_LOCATIONS_GT POLL,
	   PO_LINES_GT POL,
	   PO_HEADERS_GT POH

   WHERE
	   POH.po_header_id = P_DOCUMENT_ID
	   AND POL.po_header_id = POH.po_header_id
	   AND POD.line_location_id = POLL.line_location_id
	   AND POLL.po_line_id = POL.po_line_id
	   AND NVL( POLL.CANCEL_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CLOSED_CODE, 'OPEN' ) <> 'FINALLY CLOSED'
           AND POD.destination_type_code in ('INVENTORY', 'SHOP FLOOR')
           AND Nvl(POD.accrue_on_receipt_flag, 'N') = 'N'
           AND Nvl(POLL.CONSIGNED_FLAG, 'N') = 'N'
           AND POLL.shipment_type  <> 'PREPAYMENT'
           AND POD.award_id IS NULL
	   AND POH.PCARD_ID IS NULL;

ELSIF ( P_DOCUMENT_TYPE = 'RELEASE') THEN

 INSERT	INTO PO_ONLINE_REPORT_TEXT_GT(
	   ONLINE_REPORT_ID,
	   LAST_UPDATE_LOGIN,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   CREATED_BY,
	   CREATION_DATE,
	   LINE_NUM,
	   SHIPMENT_NUM,
	   DISTRIBUTION_NUM,
	   SEQUENCE,
	   TEXT_LINE,
	   MESSAGE_NAME
	   )
   SELECT
	   P_ONLINE_REPORT_ID,
	   P_LOGIN_ID,
	   P_USER_ID,
	   SYSDATE,
	   P_USER_ID,
	   SYSDATE,
	   POL.line_num,
	   POLL.shipment_num,
	   POD.DISTRIBUTION_NUM,
	   P_SEQUENCE + ROWNUM,
	   'Between Shipment '||POLL.shipment_num||
           ' and Distribution '||POD.DISTRIBUTION_NUM ||
           ' of Line '||POL.line_num||' , '|| L_TEXTLINE,
           'PO_RI_INVALID_ACCRUE_ON_RCT'
   FROM
	   PO_DISTRIBUTIONS_GT POD,
           PO_LINE_LOCATIONS_GT POLL,
	   PO_LINES POL,
	   PO_RELEASES_GT POR

   WHERE
           POR.po_release_id = P_DOCUMENT_ID
	   AND POR.po_header_id = POL.po_header_id
	   AND POD.line_location_id = POLL.line_location_id
	   AND POLL.po_line_id = POL.po_line_id
	   AND NVL( POLL.CANCEL_FLAG, 'N' ) <> 'Y'
	   AND NVL( POLL.CLOSED_CODE, 'OPEN' ) <> 'FINALLY CLOSED'
           AND POD.destination_type_code in ('INVENTORY', 'SHOP FLOOR')
           AND Nvl(POD.accrue_on_receipt_flag, 'N') = 'N'
           AND Nvl(POLL.CONSIGNED_FLAG, 'N') = 'N'
           AND POLL.shipment_type  <> 'PREPAYMENT'
           AND POD.award_id IS NULL
	   AND POR.PCARD_ID IS NULL;

 END IF;

   p_sequence := p_sequence + SQL%ROWCOUNT;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     X_MSG_DATA := FND_MSG_PUB.GET( P_MSG_INDEX => FND_MSG_PUB.G_LAST, P_ENCODED => 'F' );
     X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN FND_API.G_EXC_ERROR THEN
     X_MSG_DATA := FND_MSG_PUB.GET( P_MSG_INDEX => FND_MSG_PUB.G_LAST, P_ENCODED => 'F' );
     X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

     -- SQLStmtGetText(mycontext, l_dyn_string, size1, size2 );
     IF FND_MSG_PUB.CHECK_MSG_LEVEL( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, L_API_NAME );
     END IF;

     IF( G_DEBUG_UNEXP ) THEN
      IF( FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED ) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED, G_LOG_HEAD ||
       L_API_NAME                                           ||
       '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '       ||
       L_PROGRESS                                           ||
       ' SQL CODE IS '                                      ||
       SQLCODE );
      END IF;
     END IF;

     X_MSG_DATA := FND_MSG_PUB.GET( P_MSG_INDEX => FND_MSG_PUB.G_LAST, P_ENCODED => 'F' );
     X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

END  check_accrue_on_receipt;


-- Bug 15987200
PROCEDURE Check_enc_amt(p_document_level   IN VARCHAR2,
                        p_online_report_id IN NUMBER,
                        p_user_id          IN NUMBER,
                        p_login_id         IN NUMBER,
                        p_sequence         IN OUT nocopy NUMBER,
                        x_return_status    OUT nocopy VARCHAR2)
IS
  l_textline po_online_report_text_gt.text_line%TYPE;
  l_ret_sts  VARCHAR2(1);
  d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.check_enc_amt';
  d_progress NUMBER;
  d_msg      VARCHAR2(60);
  test       NUMBER;

  -- Bug#19157647
  l_precision   NUMBER;

  -- Bug#19157647 : get precision of functional currency
  CURSOR get_precision
  IS
  SELECT FND_CUR.precision
  FROM
     FINANCIALS_SYSTEM_PARAMETERS FSP
  ,  GL_SETS_OF_BOOKS GL_SOB
  ,  FND_CURRENCIES FND_CUR
  WHERE  GL_SOB.set_of_books_id = FSP.set_of_books_id
    AND  GL_SOB.currency_code = FND_CUR.currency_code;

BEGIN
    d_progress := 0;

    IF ( po_log.d_proc ) THEN
      po_log.Proc_begin(d_module);
	  po_log.Proc_begin(d_module, 'p_document_level', p_document_level);
      po_log.Proc_begin(d_module, 'p_online_report_id', p_online_report_id);
      po_log.Proc_begin(d_module, 'p_user_id', p_user_id);
      po_log.Proc_begin(d_module, 'p_login_id', p_login_id);
      po_log.Proc_begin(d_module, 'p_sequence', p_sequence);
    END IF;

    d_progress := 10;

    l_textline := fnd_message.Get_string('PO', 'PO_INCORRECT_ENC_AMT');

    -- Bug#19157647
    OPEN get_precision;
    FETCH get_precision INTO l_precision;
    CLOSE get_precision;

    IF ( po_log.d_proc ) THEN
      po_log.Proc_begin(d_module, 'Functional currency precision :  ', l_precision);
    END IF;

     -- Bug#19157647 : remove fnd_currencies and fc.PRECISION,
     -- replace with l_precision from cursor, round
     -- according to functional currency precision

     -- Bug#18488695 : use matching_basis from PO shipment, not line.
     -- modify code where po_line_locations is used.
     -- currently po_line_locations_gt does not have matching_basis
     -- column will leave code AS IS in this case.

    IF ( p_document_level = g_document_level_header ) THEN
      d_progress := 20;

      INSERT INTO po_online_report_text_gt
                  (online_report_id,
                   last_update_login,
                   last_updated_by,
                   last_update_date,
                   created_by,
                   creation_date,
                   line_num,
                   shipment_num,
                   distribution_num,
                   SEQUENCE,
                   text_line,
                   message_name)
      SELECT p_online_report_id,
             p_login_id,
             p_user_id,
             SYSDATE,
             p_user_id,
             SYSDATE,
             PLG.line_num,
             PLL.shipment_num,
             0,
             p_sequence + ROWNUM,
             Substr(g_linemsg
                    ||g_delim
                    ||PLG.line_num
                    ||g_delim
                    ||g_shipmsg
                    ||g_delim
                    ||PLL.shipment_num
                    ||g_delim
                    ||l_textline, 1, 240),
             'PO_INCORRECT_ENC_AMT'
      FROM   po_headers_gt PHG,
             po_lines PLG,
             po_line_locations PLL,
             po_distributions pod
             -- Bug#19157647:  fnd_currencies fc
      WHERE  pod.line_location_id = pll.line_location_id
             AND pll.po_line_id = PLG.po_line_id
             AND phg.po_header_id = pod.po_header_id
             AND pod.encumbered_flag = 'Y'
             -- Bug#18488695 : replace PLG.matching_basis with
             -- PLL.matching_basis
             AND Decode(PLL.matching_basis, 'AMOUNT', Round
      (
      ( Nvl(pod.amount_ordered, 0) + Nvl(pod.nonrecoverable_tax, 0) )
      *
      Nvl(pod.rate, 1), l_PRECISION),
                           Round(pll.price_override * pod.quantity_ordered *
                                 Nvl
                                 (pod.rate, 1)
      +
      ( Nvl(pod.nonrecoverable_tax, 0) * Nvl(pod.rate, 1) ), l_PRECISION)) <>
      Round(pod.encumbered_amount, l_PRECISION)
      AND pod.amount_changed_flag IS NULL
      AND pod.prevent_encumbrance_flag = 'N'
      AND pod.distribution_type = 'STANDARD'
      -- Bug#19157647: AND fc.currency_code = phg.currency_code
      AND pod.po_header_id = phg.po_header_id
      UNION
      SELECT p_online_report_id,
             p_login_id,
             p_user_id,
             SYSDATE,
             p_user_id,
             SYSDATE,
             PLG.line_num,
             PLL.shipment_num,
             0,
             p_sequence + ROWNUM,
             Substr(g_linemsg
                    ||g_delim
                    ||PLG.line_num
                    ||g_delim
                    ||g_shipmsg
                    ||g_delim
                    ||PLL.shipment_num
                    ||g_delim
                    ||l_textline, 1, 240),
             'PO_INCORRECT_ENC_AMT'
      FROM   po_headers_gt PHG,
             po_lines PLG,
             po_line_locations PLL,
             po_distributions d
             -- Bug#19157647: fnd_currencies fc
      WHERE  pll.line_location_id = d.line_location_id
             AND phg.po_header_id = d.po_header_id
             AND pll.po_line_id = PLG.po_line_id
             -- Bug#19157647: AND fc.currency_code = phg.currency_code
             AND Nvl(PLL.approved_flag, 'N') = 'Y'
             AND Nvl(PLL.cancel_flag, 'N') = 'Y'
             AND Nvl(PLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
             AND Nvl(d.prevent_encumbrance_flag, 'N') = 'N'
             AND d.ussgl_transaction_code IS NULL
             AND d.budget_account_id IS NOT NULL
             AND Decode(pll.matching_basis, 'AMOUNT',
                 /***********ENC CALCULATION FOR AMOUNT BASED LINES***************/
                 Round(Least(d.amount_ordered, Decode(d.accrue_on_receipt_flag,
    'Y', Nvl(d.amount_delivered, 0),
                               (
    Nvl(d.amount_ordered, 0) -
    Nvl(d.amount_cancelled, 0) ))) *
    Nvl(d.rate, 1) *
    ( 1 +
    ( Nvl(d.nonrecoverable_tax, 0) /
    Decode(d.amount_ordered, 0, 1,
             d.amount_ordered) ) ),
    l_PRECISION),
    /*************ENC CALCULATION FOR AMOUNT BASED LINES END************/
    /********ENC CALCULATION FOR NON AMOUNT BASED LINES**************/
    Round(
    Least(d.quantity_ordered, Decode(d.accrue_on_receipt_flag,
    'Y', Nvl(d.quantity_delivered, 0),
    ( Nvl(d.quantity_ordered, 0) -
    Nvl(d.quantity_cancelled, 0) ))) * Nvl(d.rate, 1) * (
    pll.price_override + ( Nvl(d.nonrecoverable_tax, 0) / Decode
    (d.quantity_ordered, 0, 1,
    d.quantity_ordered) ) ),
    l_PRECISION)
    /********ENC CALCULATION FOR NON AMOUNT BASED LINES END**************/
    ) <> Round(d.encumbered_amount, l_PRECISION);
    ELSIF ( p_document_level = g_document_level_line ) THEN
      d_progress := 30;

      INSERT INTO po_online_report_text_gt
                  (online_report_id,
                   last_update_login,
                   last_updated_by,
                   last_update_date,
                   created_by,
                   creation_date,
                   line_num,
                   shipment_num,
                   distribution_num,
                   SEQUENCE,
                   text_line,
                   message_name)
      SELECT p_online_report_id,
             p_login_id,
             p_user_id,
             SYSDATE,
             p_user_id,
             SYSDATE,
             PLG.line_num,
             pll.shipment_num,
             NULL,
             p_sequence + ROWNUM,
             Substr(g_linemsg
                    ||g_delim
                    ||PLG.line_num
                    ||g_delim
                    ||g_shipmsg
                    ||g_delim
                    ||PLL.shipment_num
                    ||g_delim
                    ||l_textline, 1, 240),
             'PO_INCORRECT_ENC_AMT'
      FROM   po_headers PHG,
             po_lines_gt PLG,
             po_line_locations_gt PLL,
             po_distributions pod
             -- Bug#19157647: fnd_currencies fc
      WHERE  pod.line_location_id = pll.line_location_id
             AND pll.po_line_id = PLG.po_line_id
             AND phg.po_header_id = plg.po_header_id
             AND pod.encumbered_flag = 'Y'
             --Bug#17819623 : Rounding the value including the rate for amount based lines
             AND Decode(PLG.matching_basis, 'AMOUNT', Round
      (
      ( Nvl(pod.amount_ordered, 0) + Nvl(pod.nonrecoverable_tax, 0) )
      *
      Nvl(pod.rate, 1), l_PRECISION),
                           Round(pll.price_override * pod.quantity_ordered *
                                 Nvl
                                 (pod.rate, 1)
      +
      ( Nvl(pod.nonrecoverable_tax, 0) * Nvl(pod.rate, 1) ), l_PRECISION)) <>
      Round(pod.encumbered_amount, l_PRECISION)
      AND pod.amount_changed_flag IS NULL
      AND pod.prevent_encumbrance_flag = 'N'
      AND pod.distribution_type = 'STANDARD'
      -- Bug#19157647: AND fc.currency_code = phg.currency_code
      AND pod.po_header_id = phg.po_header_id
      UNION
      SELECT p_online_report_id,
             p_login_id,
             p_user_id,
             SYSDATE,
             p_user_id,
             SYSDATE,
             PLG.line_num,
             pll.shipment_num,
             NULL,
             p_sequence + ROWNUM,
             Substr(g_linemsg
                    ||g_delim
                    ||PLG.line_num
                    ||g_delim
                    ||g_shipmsg
                    ||g_delim
                    ||PLL.shipment_num
                    ||g_delim
                    ||l_textline, 1, 240),
             'PO_INCORRECT_ENC_AMT'
      FROM   po_headers PHG,
             po_lines_gt PLG,
             po_line_locations_gt PLL,
             po_distributions d
             -- Bug#19157647: fnd_currencies fc
      WHERE  d.line_location_id = pll.line_location_id
             AND pll.po_line_id = PLG.po_line_id
             AND phg.po_header_id = plg.po_header_id
             -- Bug#19157647: AND fc.currency_code = phg.currency_code
             AND Nvl(PLL.approved_flag, 'N') = 'Y'
             AND Nvl(PLL.cancel_flag, 'N') = 'Y'
             AND Nvl(PLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
             AND Nvl(d.prevent_encumbrance_flag, 'N') = 'N'
             AND d.ussgl_transaction_code IS NULL
             AND d.budget_account_id IS NOT NULL
             AND Decode(plg.matching_basis, 'AMOUNT',
                 /***********ENC CALCULATION FOR AMOUNT BASED LINES***************/
                 Round(Least(d.amount_ordered, Decode(d.accrue_on_receipt_flag,
    'Y', Nvl(d.amount_delivered, 0),
                               (
    Nvl(d.amount_ordered, 0) -
    Nvl(d.amount_cancelled, 0) ))) *
    Nvl(d.rate, 1) *
    ( 1 +
    ( Nvl(d.nonrecoverable_tax, 0) /
    Decode(d.amount_ordered, 0, 1,
             d.amount_ordered) ) ),
    l_PRECISION),
    /*************ENC CALCULATION FOR AMOUNT BASED LINES END************/
    /********ENC CALCULATION FOR NON AMOUNT BASED LINES**************/
    Round(
    Least(d.quantity_ordered, Decode(d.accrue_on_receipt_flag,
    'Y', Nvl(d.quantity_delivered, 0),
    ( Nvl(d.quantity_ordered, 0) -
    Nvl(d.quantity_cancelled, 0) ))) * Nvl(d.rate, 1) * (
    pll.price_override + ( Nvl(d.nonrecoverable_tax, 0) / Decode
    (d.quantity_ordered, 0, 1,
    d.quantity_ordered) ) ),
    l_PRECISION)
    /********ENC CALCULATION FOR NON AMOUNT BASED LINES END**************/
    ) <> Round(d.encumbered_amount, l_PRECISION);
    ELSIF ( p_document_level = g_document_level_shipment ) THEN
      d_progress := 40;

      INSERT INTO po_online_report_text_gt
                  (online_report_id,
                   last_update_login,
                   last_updated_by,
                   last_update_date,
                   created_by,
                   creation_date,
                   line_num,
                   shipment_num,
                   distribution_num,
                   SEQUENCE,
                   text_line,
                   message_name)
      SELECT p_online_report_id,
             p_login_id,
             p_user_id,
             SYSDATE,
             p_user_id,
             SYSDATE,
             PLG.line_num,
             pll.shipment_num,
             NULL,
             p_sequence + ROWNUM,
             Substr(g_shipmsg
                    ||g_delim
                    ||pll.shipment_num
                    ||g_delim
                    ||l_textline, 1, 240),
             'PO_INCORRECT_ENC_AMT'
      FROM   po_headers PHG,
             po_lines_gt PLG,
             po_line_locations_gt PLL,
             po_distributions pod
             -- Bug#19157647: fnd_currencies fc
      WHERE  pod.line_location_id = pll.line_location_id
             AND pll.po_line_id = PLG.po_line_id
             AND phg.po_header_id = plg.po_header_id
             AND pod.encumbered_flag = 'Y'
             --Bug#17819623 : Rounding the value including the rate for amount based lines
             AND Decode(PLG.matching_basis, 'AMOUNT', Round
      (
      ( Nvl(pod.amount_ordered, 0) + Nvl(pod.nonrecoverable_tax, 0) )
      *
      Nvl(pod.rate, 1), l_PRECISION),
                           Round(pll.price_override * pod.quantity_ordered *
                                 Nvl
                                 (pod.rate, 1)
      +
      ( Nvl(pod.nonrecoverable_tax, 0) * Nvl(pod.rate, 1) ), l_PRECISION)) <>
      Round(pod.encumbered_amount, l_PRECISION)
      AND pod.amount_changed_flag IS NULL
      AND pod.prevent_encumbrance_flag = 'N'
      AND pod.distribution_type = 'STANDARD'
      -- Bug#19157647: AND fc.currency_code = phg.currency_code
      AND pod.po_header_id = phg.po_header_id
      UNION
      SELECT p_online_report_id,
             p_login_id,
             p_user_id,
             SYSDATE,
             p_user_id,
             SYSDATE,
             PLG.line_num,
             pll.shipment_num,
             NULL,
             p_sequence + ROWNUM,
             Substr(g_shipmsg
                    ||g_delim
                    ||pll.shipment_num
                    ||g_delim
                    ||l_textline, 1, 240),
             'PO_INCORRECT_ENC_AMT'
      FROM   po_headers PHG,
             po_lines_gt PLG,
             po_line_locations_gt PLL,
             po_distributions d
             -- Bug#19157647: fnd_currencies fc
      WHERE  d.line_location_id = pll.line_location_id
             AND pll.po_line_id = PLG.po_line_id
             AND phg.po_header_id = plg.po_header_id
             -- Bug#19157647: AND fc.currency_code = phg.currency_code
             AND Nvl(PLL.approved_flag, 'N') = 'Y'
             AND Nvl(PLL.cancel_flag, 'N') = 'Y'
             AND Nvl(PLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
             AND Nvl(d.prevent_encumbrance_flag, 'N') = 'N'
             AND d.ussgl_transaction_code IS NULL
             AND d.budget_account_id IS NOT NULL
             AND Decode(PLG.matching_basis, 'AMOUNT',
                 /***********ENC CALCULATION FOR AMOUNT BASED LINES***************/
                 Round(Least(d.amount_ordered, Decode(d.accrue_on_receipt_flag,
    'Y', Nvl(d.amount_delivered, 0),
                               (
    Nvl(d.amount_ordered, 0) -
    Nvl(d.amount_cancelled, 0) ))) *
    Nvl(d.rate, 1) *
    ( 1 +
    ( Nvl(d.nonrecoverable_tax, 0) /
    Decode(d.amount_ordered, 0, 1,
             d.amount_ordered) ) ),
    l_PRECISION),
    /*************ENC CALCULATION FOR AMOUNT BASED LINES END************/
    /********ENC CALCULATION FOR NON AMOUNT BASED LINES**************/
    Round(
    Least(d.quantity_ordered, Decode(d.accrue_on_receipt_flag,
    'Y', Nvl(d.quantity_delivered, 0),
    ( Nvl(d.quantity_ordered, 0) -
    Nvl(d.quantity_cancelled, 0) ))) * Nvl(d.rate, 1) * (
    pll.price_override + ( Nvl(d.nonrecoverable_tax, 0) / Decode
    (d.quantity_ordered, 0, 1,
    d.quantity_ordered) ) ),
    l_PRECISION)
    /********ENC CALCULATION FOR NON AMOUNT BASED LINES END**************/
    ) <> Round(d.encumbered_amount, l_PRECISION);
    ELSE
      d_progress := 50;

      d_msg := 'Bad document level';

      l_ret_sts := fnd_api.g_ret_sts_unexp_error;

      RAISE po_core_s.g_early_return_exc;
    END IF; -- if p_document_level = ...
    d_progress := 60;

    x_return_status := fnd_api.g_ret_sts_success;

    IF ( po_log.d_proc ) THEN
      po_log.Proc_end(d_module, 'x_return_status', x_return_status);

      po_log.Proc_end(d_module);
    END IF;

    RETURN;
EXCEPTION
  WHEN OTHERS THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;

             IF ( po_log.d_exc ) THEN
               po_log.Exc(d_module, d_progress, SQLCODE
                                                || ': '
                                                || SQLERRM);



               po_log.Proc_end(d_module, 'x_return_status', x_return_status);

               po_log.Proc_end(d_module);
             END IF;

             RETURN;
END check_enc_amt;

/* FUNCTION is_uom_conversion_exist
** Added by bug 19139821 base on po_uom_s.po_uom_conversion.
** If conversion exist (uom_rate can be calculated) then return 'Y',
** else return 'N'.
*/
FUNCTION is_uom_conversion_exist(
    from_unit IN VARCHAR2,
    to_unit   IN VARCHAR2,
    item_id   IN NUMBER) RETURN VARCHAR2
IS
  from_class VARCHAR2(10);
  to_class   VARCHAR2(10);
  d_progress VARCHAR2(3) := NULL;
  d_module   VARCHAR2(70) := 'po.plsql.PO_DOCUMENT_CHECKS_PVT.is_uom_conversion_exist';

  CURSOR standard_conversions
  IS
    SELECT t.conversion_rate std_to_rate,
      t.uom_class std_to_class,
      f.conversion_rate std_from_rate,
      f.uom_class std_from_class
    FROM mtl_uom_conversions t,
      mtl_uom_conversions f
    WHERE t.inventory_item_id                  IN (item_id, 0)
    AND t.unit_of_measure                       = to_unit
    AND NVL(t.disable_date, TRUNC(sysdate)      + 1) > TRUNC(sysdate)
    AND f.inventory_item_id                    IN (item_id, 0)
    AND f.unit_of_measure                       = from_unit
    AND NVL(f.disable_date, TRUNC(sysdate) + 1) > TRUNC(sysdate)
    ORDER BY t.inventory_item_id DESC,
      f.inventory_item_id DESC;
  std_rec standard_conversions%rowtype;

  CURSOR interclass_conversions(inv_item_flag VARCHAR2)
  IS
    SELECT DECODE(to_uom_class, to_class, 1, 2) to_flag,
      DECODE(from_uom_class, from_class, 1, to_class, 2, 0) from_flag,
      conversion_rate rate
    FROM mtl_uom_class_conversions
    WHERE ((inv_item_flag                     = 'Y'
    AND inventory_item_id                     = item_id)
    OR (inv_item_flag                         = 'N'
    AND inventory_item_id                     = 0))
    AND to_uom_class                         IN (from_class, to_class)
    AND NVL(disable_date, TRUNC(sysdate) + 1) > TRUNC(sysdate);
  class_rec interclass_conversions%rowtype;

type conv_tab
IS
  TABLE OF NUMBER INDEX BY binary_integer;

type class_tab
IS
  TABLE OF VARCHAR2(10) INDEX BY binary_integer;

  from_class_flag_tab conv_tab;
  to_class_flag_tab conv_tab;
  from_class_tab class_tab;
  to_class_tab class_tab;
  std_index       NUMBER;
  class_index     NUMBER;
  inv_item_flag   VARCHAR2(1);
BEGIN
  IF ( po_log.d_proc ) THEN
    po_log.Proc_begin(d_module);
    po_log.Proc_begin(d_module, 'from_unit', from_unit);
    po_log.Proc_begin(d_module, 'to_unit', to_unit);
    po_log.Proc_begin(d_module, 'item_id', item_id);
  END IF;

  d_progress   := '010';
  IF (from_unit = to_unit) THEN
    RETURN 'Y';
  END IF;

  d_progress := '020';
  OPEN standard_conversions;
  std_index := 0;
  LOOP
    d_progress := '030';
    FETCH standard_conversions INTO std_rec;
    EXIT
  WHEN standard_conversions%notfound;
    std_index                 := std_index + 1;
    from_class_tab(std_index) := std_rec.std_from_class;
    to_class_tab(std_index)   := std_rec.std_to_class;
  END LOOP;
  CLOSE standard_conversions;

  d_progress   := '040';
  IF (std_index = 0) THEN
    -- No conversions defined
    RETURN 'N';
  ELSE
    from_class := from_class_tab(1);
    to_class   := to_class_tab(1);
  END IF;

  d_progress     := '050';
  IF (from_class <> to_class) THEN
    /*
    ** Load interclass conversion tables
    ** If two rows are returned, it implies that there is no direct
    ** conversion between them.
    ** If one row is returned, then it may imply that there is a direct
    ** conversion between them or one class is not defined in the
    ** class conversion table.
    */
    class_index := 0;
    IF (item_id IS NULL OR item_id = 0) THEN
      inv_item_flag := 'N';
    ELSE
      inv_item_flag := 'Y';
    END IF;

    OPEN interclass_conversions(inv_item_flag);
    LOOP
      d_progress := '060';
      FETCH interclass_conversions INTO class_rec;
      EXIT
    WHEN interclass_conversions%notfound;
      class_index                      := class_index + 1;
      to_class_flag_tab(class_index)   := class_rec.to_flag;
      from_class_flag_tab(class_index) := class_rec.from_flag;
    END LOOP;
    CLOSE interclass_conversions;

    d_progress     := '070';
    IF (class_index = 2) THEN
      /*
      ** Error out for Expense Items if the UOM
      ** Interclass Conversions are not defined between the two UOMs.
      ** If the inv_item_flag = N then return 'N'.
      */
      IF (inv_item_flag = 'Y') THEN
        RETURN 'Y';
      ELSE
        RETURN 'N';
      END IF;
    ELSIF ((class_index = 1) AND (to_class_flag_tab(1) = from_class_flag_tab(1) )) THEN
      RETURN 'Y';
    ELSE
      --No interclass conversion is defined
      RETURN 'N';
    END IF;
  END IF;

RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
  IF (PO_LOG.d_exc) THEN
    PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
    PO_LOG.proc_end(d_module);
  END IF;
  RAISE;
END is_uom_conversion_exist;

END PO_DOCUMENT_CHECKS_PVT;

/
