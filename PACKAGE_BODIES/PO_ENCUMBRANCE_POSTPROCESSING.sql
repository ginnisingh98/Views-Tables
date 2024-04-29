--------------------------------------------------------
--  DDL for Package Body PO_ENCUMBRANCE_POSTPROCESSING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ENCUMBRANCE_POSTPROCESSING" AS
-- $Header: POXENC2B.pls 120.40.12010000.37 2014/07/10 06:30:48 aacai ship $

G_PKG_NAME CONSTANT varchar2(30) := 'PO_ENCUMBRANCE_POSTPROCESSING';

g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.' ;

-- Read the profile option that enables/disables the debug log
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

-- Private package exceptions
g_GL_VALIDATE_API_EXC  EXCEPTION;
g_GL_FUNDS_API_EXC     EXCEPTION;

--------------------------------------------------------------------------------
-- Private package constants
--------------------------------------------------------------------------------

-- encumbrance actions
g_action_RESERVE       CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_RESERVE;

g_action_UNRESERVE     CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_UNRESERVE;

g_action_ADJUST        CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_ADJUST;

g_action_REQ_SPLIT               CONSTANT
   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_REQ_SPLIT
   ;
g_action_CANCEL        CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_CANCEL;

g_action_FINAL_CLOSE   CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_FINAL_CLOSE;

g_action_UNDO_FINAL_CLOSE CONSTANT VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_UNDO_FINAL_CLOSE;

g_action_REJECT        CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_REJECT;

g_action_RETURN        CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_RETURN;

g_action_CBC_RESERVE   CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_CBC_RESERVE;

g_action_CBC_UNRESERVE CONSTANT   VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_CBC_UNRESERVE;

g_action_INVOICE_CANCEL CONSTANT  VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_INVOICE_CANCEL;

g_action_CR_MEMO_CANCEL CONSTANT  VARCHAR2(30)
   := PO_DOCUMENT_FUNDS_PVT.g_action_CR_MEMO_CANCEL;


-- doc types

g_doc_type_REQUISITION CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_REQUISITION;

g_doc_type_PO CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_PO;

g_doc_type_PA CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_PA;

g_doc_type_RELEASE CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_RELEASE;

g_doc_type_MIXED_PO_RELEASE CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_MIXED_PO_RELEASE;

-- doc subtypes

g_doc_subtype_STANDARD CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_STANDARD;

g_doc_subtype_PLANNED CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_PLANNED;

g_doc_subtype_BLANKET CONSTANT
   PO_RELEASES_ALL.release_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_BLANKET;

g_doc_subtype_SCHEDULED CONSTANT
   PO_RELEASES_ALL.release_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_SCHEDULED;

g_doc_subtype_MIXED_PO_RELEASE CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_MIXED_PO_RELEASE;

-- doc levels

g_doc_level_HEADER         CONSTANT VARCHAR2(25)
   := PO_DOCUMENT_FUNDS_PVT.g_doc_level_HEADER;

g_doc_level_LINE           CONSTANT VARCHAR2(25)
   := PO_DOCUMENT_FUNDS_PVT.g_doc_level_LINE;

g_doc_level_SHIPMENT       CONSTANT VARCHAR2(25)
   := PO_DOCUMENT_FUNDS_PVT.g_doc_level_SHIPMENT;

g_doc_level_DISTRIBUTION   CONSTANT VARCHAR2(25)
   := PO_DOCUMENT_FUNDS_PVT.g_doc_level_DISTRIBUTION;

-- distribution types

g_dist_type_STANDARD    CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_STANDARD;

g_dist_type_PLANNED     CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_PLANNED;

g_dist_type_SCHEDULED   CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_SCHEDULED;

g_dist_type_BLANKET     CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_BLANKET;

g_dist_type_AGREEMENT   CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_AGREEMENT;

g_dist_type_REQUISITION CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_REQUISITION;

g_dist_type_MIXED_PO_RELEASE CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_MIXED_PO_RELEASE;

-- parameter values

g_parameter_YES            CONSTANT VARCHAR2(1)
   := PO_DOCUMENT_FUNDS_PVT.g_parameter_YES;

g_parameter_NO             CONSTANT VARCHAR2(1)
   := PO_DOCUMENT_FUNDS_PVT.g_parameter_NO;

g_parameter_USE_PROFILE    CONSTANT VARCHAR2(1)
   := PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE;

-- return status

g_return_SUCCESS   CONSTANT VARCHAR2(10)
   := PO_DOCUMENT_FUNDS_PVT.g_return_SUCCESS;

g_return_WARNING   CONSTANT VARCHAR2(10)
   := PO_DOCUMENT_FUNDS_PVT.g_return_WARNING;

g_return_PARTIAL   CONSTANT VARCHAR2(10)
   := PO_DOCUMENT_FUNDS_PVT.g_return_PARTIAL;

g_return_FAILURE   CONSTANT VARCHAR2(10)
   := PO_DOCUMENT_FUNDS_PVT.g_return_FAILURE;

g_return_FATAL     CONSTANT VARCHAR2(10)
   := PO_DOCUMENT_FUNDS_PVT.g_return_FATAL;

-- gl packet constants

g_actual_flag_Encumbrance VARCHAR2(1) := 'E';

g_je_source_name_Purchasing VARCHAR2(25) := 'Purchasing';


-- adjustment status
g_adjustment_status_OLD    CONSTANT
   PO_ENCUMBRANCE_GT.adjustment_status%TYPE
   :=  PO_DOCUMENT_FUNDS_PVT.g_adjustment_status_OLD;

g_adjustment_status_NEW    CONSTANT
   PO_ENCUMBRANCE_GT.adjustment_status%TYPE
   :=  PO_DOCUMENT_FUNDS_PVT.g_adjustment_status_NEW;


-- result classifications
g_result_SUCCESS  CONSTANT PO_ENCUMBRANCE_GT.result_type%TYPE
	:= PO_DOCUMENT_FUNDS_PVT.g_result_SUCCESS;

g_result_WARNING  CONSTANT PO_ENCUMBRANCE_GT.result_type%TYPE
	:= PO_DOCUMENT_FUNDS_PVT.g_result_WARNING;

g_result_ERROR    CONSTANT PO_ENCUMBRANCE_GT.result_type%TYPE
	:= PO_DOCUMENT_FUNDS_PVT.g_result_ERROR;
--note: this classification currently maps to Warning, but is
--given a seperate label so as to easily identify this condition
g_result_NOT_PROCESSED  CONSTANT PO_ENCUMBRANCE_GT.result_type%TYPE
	:= PO_DOCUMENT_FUNDS_PVT.g_result_WARNING;

--note: this classification currently maps to ERROR, but is
--given a seperate label so as to easily identify this condition,
--which occurs when there is a single high-level failure message
--instead of detailed results for each distribution
g_result_TRANSACTION	CONSTANT PO_ENCUMBRANCE_GT.result_type%TYPE
	:= PO_DOCUMENT_FUNDS_PVT.g_result_ERROR;

-- current module
g_module_ENCUMBRANCE  CONSTANT
   PO_ONLINE_REPORT_TEXT.transaction_type%TYPE := 'ENCUMBRANCE';

--bug#5353223
g_CREDIT CONSTANT VARCHAR2(2) :='Cr';
g_DEBIT  CONSTANT VARCHAR2(2) :='Dr';
--bug#5353223

--------------------------------------------------------------------------------
-- Private procedures
--------------------------------------------------------------------------------
--<bug#5523323 START>
--Renamed the procedure insert_packet_autonomous as insert_packet_create_event
--This is done because we do not have any autonomous txns anymore.
--Also removed the in parameters passing data as tables because they can now be
--populated directly as part of a sql.
--<bug#5523323 END>
PROCEDURE insert_packet_create_event
  (
    p_status_code                    IN             VARCHAR2,
    p_user_id                        IN             NUMBER,
    p_set_of_books_id                IN             NUMBER,
    p_currency_code                  IN             VARCHAR2,
    p_action                         IN             VARCHAR2,--bug#5646605
    --<SLA R12 End>
    x_packet_id                      OUT NOCOPY     NUMBER
   );


PROCEDURE update_successful_rows(
  p_doc_type                       IN             VARCHAR2
, p_doc_subtype                    IN             VARCHAR2
, p_action                         IN             VARCHAR2
, p_gl_return_code                 IN             VARCHAR2
);

PROCEDURE update_failed_rows(
  p_doc_type                       IN             VARCHAR2
, p_action                         IN             VARCHAR2
);

-- Bug 3537764: Added p_action parameter.
PROCEDURE rollup_encumbrance_changes (p_action   IN VARCHAR2);

PROCEDURE insert_report_autonomous(
   p_reporting_level 		IN VARCHAR2
,  p_message_text 		IN VARCHAR2
,  p_user_id			IN NUMBER
,  p_sequence_num_tbl		IN po_tbl_number
,  p_line_num_tbl		IN po_tbl_number
,  p_shipment_num_tbl		IN po_tbl_number
,  p_distribution_num_tbl	IN po_tbl_number
,  p_distribution_id_tbl	IN po_tbl_number
,  p_result_code_tbl		IN po_tbl_varchar5
,  p_message_type_tbl		IN po_tbl_varchar1
,  p_text_line_tbl		IN po_tbl_varchar2000
,  p_show_in_psa_flag IN po_tbl_varchar1        --<bug#5010001>
,  p_segment1_tbl IN po_tbl_varchar20           --<bug#5010001>
,  p_distribution_type_tbl IN po_tbl_varchar25  --<bug#5010001>
,  x_online_report_id  		OUT NOCOPY NUMBER
);

--<SLA R12 Start>
PROCEDURE delete_po_bc_distributions
(
  p_packet_id                 IN        NUMBER
) ;

FUNCTION get_entity_type_code(p_distribution_type    IN VARCHAR2,
                              p_action      IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE get_doc_detail_from_dist_type(p_distribution_type IN VARCHAR2,
                                        x_doc_type          OUT NOCOPY VARCHAR2 ,
                                        x_doc_subtype       OUT NOCOPY VARCHAR2);
PROCEDURE get_event_and_entity_codes(
   p_doc_type          IN            VARCHAR2,
   p_doc_subtype       IN            VARCHAR2,
   p_action            IN            VARCHAR2,
   x_entity_type_code     OUT NOCOPY VARCHAR2,
   x_event_type_code      OUT NOCOPY VARCHAR2
);

--<SLA R12 End>

-------------------------------------------------------------------------------
--Start of Comments
--Name: insert_packet
--Pre-reqs:
--  PO_ENCUMBRANCE_GT has been updated with the data that should
--  be inserted into PO_BC_DISTRIBUTIONS.
--Modifies:
--  GL_BC_PACKETS
--Locks:
--  None.
--Function:
--  This procedure inserts all of the entries in
--  PO_ENCUMBRANCE_GT into PO_BC_DISTRIBUTIONS. It does this through
--  an autonomous transaction helper procedure, as GL needs the data
--  committed, but we don't want to commit anything else.
--Parameters:
--IN:
--p_status_code
--  Specifies whether this is a Funds Check (C) or a real (pending) action (P).
--p_user_id
--  The user_id that is taking this action.
--p_set_of_books_id
--  The set of books for the current org.
--p_currency_code
--  The currency code for the current org.
--OUT:
--x_packet_id
--  The PO_BC_DISTRIBUTIONS.packet_id that was used for this packet.
--  If a packet was not created, this will be NULL.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE insert_packet
(
  p_status_code                    IN             VARCHAR2,
  p_user_id                        IN             NUMBER,
  p_set_of_books_id                IN             NUMBER,
  p_currency_code                  IN             VARCHAR2,
  p_action                         IN             VARCHAR2,--bug#5646605
  x_packet_id                      OUT NOCOPY     NUMBER
)
IS
  l_proc_name CONSTANT VARCHAR2(30) := 'INSERT_PACKET';
  l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
  l_progress  VARCHAR2(3) := '000';
BEGIN
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_status_code',p_status_code);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_user_id',p_user_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_set_of_books_id',p_set_of_books_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_currency_code',p_currency_code);
  END IF;
  l_progress := '100';
  --bug#5523323 We have removed the autonomous transaction in the procedure
  --insert_packet_autonomous. Hence renamed the procedure as
  --insert_packet_create_event. Also removed the select statment that
  --collects data in pl/sql tables. This is because we can do direct
  --insert inside insert_packet_create_event.
  INSERT_PACKET_CREATE_EVENT(
                             p_status_code    => p_status_code,
                             p_user_id        => p_user_id,
                             p_set_of_books_id=> p_set_of_books_id,
                             p_currency_code  => p_currency_code,
                             p_action         => p_action,--bug#5646605
                             x_packet_id      => x_packet_id
                             );

  l_progress := '200';
  -- Populate eventids in psa_bc_xla_events_gt for these events
  -- to be considered by Budgetary Control API
  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_packet_id',x_packet_id);
  END IF;

  IF(x_packet_id IS NOT NULL) THEN

    -- BUG 6442530
    -- For any Mutliple line change PO Change Request from IProocurement.
    -- We are unreserving the document in a LOOP for every Line change done.
    -- We are creating one event for every line. But all the event get processed
    -- in one transaction boundary, PSA is getting the event id of previous lines
    -- also which it has allready processed in this tranaction.
    -- So clearing the event GT table before we insert any new event.

    DELETE FROM psa_bc_xla_events_gt
    WHERE event_id IN (  SELECT distinct ae_event_id
                         FROM   po_bc_distributions
                         WHERE packet_id <> x_packet_id
                      );


    INSERT into psa_bc_xla_events_gt
           (
            event_id,
            result_code           -- Bug #4637958
           )
    SELECT distinct ae_event_id,'XLA_ERROR'
    FROM   po_bc_distributions
    WHERE  packet_id = x_packet_id;
  END IF;

  l_progress := '300';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_packet_id',x_packet_id);
    PO_DEBUG.debug_end(l_log_head);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
    END IF;
    RAISE;
END insert_packet;


-------------------------------------------------------------------------------
--Start of Comments
--Name: INSERT_PACKET_CREATE_EVENT
--Pre-reqs:
--  None.
--Modifies:
--  PO_BC_DISTRIBUTIONS
--Locks:
--  None.
--Function:
--  This procedure takes its input parameters and inserts and
--  transfers data from po_encumbrance_gt to po_bc_distributions.
--Parameters:
--IN:
-- p_status_code
--  Specifies whether this is a Funds Check (C) or a real (pending) action (P).
-- p_user_id
--  The user_id that is taking this action.
-- p_set_of_books_id
--  The set of books for the current org.
-- p_currency_code
--  The currency code for the current org.
--OUT:
--x_packet_id
--  The PO_BC_DISTRIBUTIONS.packet_id that was used for this packet.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
  --bug#5523323 We have removed the autonomous transaction in the procedure
  --insert_packet_autonomous. Hence renamed the procedure as
  --insert_packet_create_event. Also removed the collection parameters
  --This is because we can do direct insert inside insert_packet_create_event.

-- <Bug 13503748: Edit without unreserve ER.>
-- Revamping insert_packet_create_event code as part of
-- ER edit without unreserve.
PROCEDURE insert_packet_create_event
  (
    p_status_code                    IN             VARCHAR2,
    p_user_id                        IN             NUMBER,
    p_set_of_books_id                IN             NUMBER,
    p_currency_code                  IN             VARCHAR2,
    p_action                         IN             VARCHAR2,--bug#5646605
    --<SLA R12 End>
    x_packet_id                      OUT NOCOPY     NUMBER
   )
IS


  l_proc_name CONSTANT VARCHAR2(30) := 'INSERT_PACKET_CREATE_EVENT';
  l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
  l_progress VARCHAR2(3) := '000';

  l_appl_id            NUMBER;  --<SLA R12>
  l_login_id           NUMBER;  --<SLA R12>
  l_event_type_code    VARCHAR2(50) ;

  l_event_source_info      xla_events_pub_pkg.t_event_source_info;
  l_security_context       xla_events_pub_pkg.t_security;
  l_reference_info         xla_events_pub_pkg.t_event_reference_info;
  l_event_date             DATE;
  l_event_status_code      VARCHAR2(30);
  l_event_number           NUMBER;
  l_valuation_method       VARCHAR2(30);
  l_legal_entity_id        NUMBER;
  l_ledger_id              NUMBER;
  l_entity_id              NUMBER;
  l_event_id               NUMBER;
  l_current_org_id         HR_ALL_ORGANIZATION_UNITS_TL.ORGANIZATION_ID%TYPE;
  l_seq_num_tbl            po_tbl_number ;
  l_num_of_rows_deleted NUMBER;
  l_num_of_rows_inserted NUMBER;


  l_id_tbl po_tbl_number;

   TYPE Event_tab_type IS TABLE OF XLA_EVENTS_INT_GT%ROWTYPE INDEX BY BINARY_INTEGER;
    l_events_Tab        Event_tab_type;
    l_event_count       NUMBER;


BEGIN
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_status_code',p_status_code);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_user_id',p_user_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_set_of_books_id',p_set_of_books_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_currency_code',p_currency_code);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
  END IF;

  l_progress := '010';

  -- Get the next packet_id from the sequence. This is required as
  -- we insert all the records with same packet ID.

  SELECT GL_BC_PACKETS_S.nextval
    INTO x_packet_id
  FROM   DUAL;

  l_progress := '020';

  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_packet_id',x_packet_id);
  END IF;

  --<SLA R12 START>
  l_appl_id  := 201 ;  -- Bug 5013999
  l_login_id := FND_GLOBAL.login_id ;

  -- Insert the data into PO_BC_DISTRIBUTIONS from PO_ENCUMBRANCE_GT,
  --bug#5523323 Modified the insert statement to fetch data directly
  --from the po_encumbrance_gt table rather than collections. This
  --is possible because the autonomous transaction no longer exists.
    INSERT INTO PO_BC_DISTRIBUTIONS
    ( BC_DISTRIBUTION_ID,
      PACKET_ID,
      STATUS_CODE,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LEDGER_ID,
      CURRENCY_CODE,
      JE_SOURCE_NAME,
      JE_CATEGORY_NAME,
      ENTERED_AMT,
      ACCOUNTED_AMT,
      GL_DATE,
      CODE_COMBINATION_ID,
      DISTRIBUTION_TYPE,
      HEADER_ID,
      DISTRIBUTION_ID,
      SEQUENCE_NUMBER,
      SEGMENT1,
      REFERENCE_NUMBER,
      APPLIED_TO_APPL_ID,
      APPLIED_TO_DIST_LINK_TYPE,
      PA_PROJECT_ID,
      PA_AWARD_ID,
      PA_TASK_ID,
      PA_EXP_ORG_ID,
      PA_EXP_TYPE,
      PA_EXP_ITEM_DATE,
      --EVENT_TYPE_CODE,
      MAIN_OR_BACKING_CODE,
      JE_LINE_DESCRIPTION,
      PO_RELEASE_ID,
      LINE_ID,
      LINE_LOCATION_ID,
      ENCUMBRANCE_TYPE_ID,
      APPLIED_TO_DIST_ID_1,
      APPLIED_TO_ENTITY_CODE,
      APPLIED_TO_HEADER_ID_1,
      REFERENCE1,
      REFERENCE2,
      REFERENCE3,
      REFERENCE4,
      REFERENCE5,
      REFERENCE6,
      REFERENCE7,
      REFERENCE8,
      REFERENCE9,
      REFERENCE10,
      REFERENCE11,
      REFERENCE12,
      REFERENCE13,
      REFERENCE14,
      REFERENCE15,
      ADJUSTMENT_STATUS,
      ORIGIN_SEQUENCE_NUM
     )
    SELECT
      PO_BC_DISTRIBUTIONS_S.nextval,
      x_packet_id,
      p_status_code,
      SYSDATE,
      p_user_id,
      l_login_id,
      SYSDATE,
      p_user_id,
      p_set_of_books_id,
      nvl(DIST.CURRENCY_CODE,p_currency_code),
      g_je_source_name_Purchasing,
      DIST.JE_CATEGORY_NAME,
      DIST.ENTERED_AMOUNT,
      DIST.ACCOUNTED_AMOUNT,
      DIST.gl_period_date, --<bug#5098665>
      DIST.CODE_COMBINATION_ID,
      DIST.DISTRIBUTION_TYPE,
      DIST.HEADER_ID,
      DIST.DISTRIBUTION_ID,
      DIST.SEQUENCE_NUM,
      DIST.SEGMENT1,
      DIST.SEGMENT1,
      l_appl_id,
      DECODE(DIST.DISTRIBUTION_TYPE,'REQUISITION','PO_REQ_DISTRIBUTIONS_ALL','PO_DISTRIBUTIONS_ALL') DIST_LINK_TYPE,
      DIST.PROJECT_ID,
      DIST.AWARD_NUM,
      DIST.TASK_ID,
      DIST.EXPENDITURE_ORGANIZATION_ID,
      DIST.EXPENDITURE_TYPE,
      DIST.EXPENDITURE_ITEM_DATE,
      --l_event_type_code,
      DECODE(DIST.ORIGIN_SEQUENCE_NUM, NULL,'M', 'B_'||DIST.REFERENCE1)    MAIN_OR_BACKING_CODE,
      DIST.JE_LINE_DESCRIPTION,
      DIST.PO_RELEASE_ID,
      DIST.LINE_ID,
      DIST.LINE_LOCATION_ID,
      DIST.ENCUMBRANCE_TYPE_ID,
      DIST.DISTRIBUTION_ID,
      DECODE(DIST.DISTRIBUTION_TYPE,'REQUISITION','REQUISITION','SCHEDULED',  'RELEASE','BLANKET',    'RELEASE','PURCHASE_ORDER')  APPLIED_TO_ENTITY_CODE,  -- Bug 4760589
      DECODE(DIST.DISTRIBUTION_TYPE,'SCHEDULED',DIST.PO_RELEASE_ID,'BLANKET',DIST.PO_RELEASE_ID,DIST.HEADER_ID),      ----APPLIED_TO_HEADER_ID_1
      DIST.REFERENCE1,
      DIST.REFERENCE2,
      DIST.REFERENCE3,
      DIST.REFERENCE4,
      DIST.REFERENCE5,
      DIST.REFERENCE6,
      DIST.REFERENCE7,
      DIST.REFERENCE8,
      DIST.REFERENCE9,
      DIST.REFERENCE10,
      DIST.REFERENCE11,
      DIST.REFERENCE12,
      DIST.REFERENCE13,
      DIST.REFERENCE14,
      DIST.REFERENCE15,
      DIST.ADJUSTMENT_STATUS,
      DIST.ORIGIN_SEQUENCE_NUM
  FROM   PO_ENCUMBRANCE_GT   DIST
  WHERE  SEND_TO_GL_FLAG =  'Y' ;

  l_progress := '100';
  l_num_of_rows_inserted :=sql%rowcount;
  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_num_of_rows_inserted',l_num_of_rows_inserted);
  END IF;

  IF l_num_of_rows_inserted = 0 THEN
    x_packet_id :=NULL;
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'GL packet not created.');
    END IF;
  END IF;

  IF(x_packet_id is not null)THEN

   IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_packet_id',x_packet_id);

  END IF;

    l_progress := '110';

-- Updating event_type_code for main record.
        UPDATE po_bc_distributions pbd
        SET event_type_code = (select get_event_type_code(pbd.distribution_type,p_action) from dual)
        WHERE packet_id = x_packet_id
        AND main_or_backing_code = 'M'
        RETURNING sequence_number
         BULK COLLECT
        INTO
        l_id_tbl;

-- Updating event_type_code for backing record.

   FORALL i IN 1..l_id_tbl.count
    UPDATE po_bc_distributions pbd
    SET event_type_code = (SELECT event_type_code
                             FROM po_bc_distributions pbd1
                    WHERE pbd1.packet_id = x_packet_id
                  AND pbd1.sequence_number=l_id_tbl(i))
    WHERE packet_id = x_packet_id
    AND main_or_backing_code <> 'M'
    and pbd.origin_sequence_num = l_id_tbl(i);

     l_id_tbl.delete;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Event type code updation is successful');
    END IF;

  --<Bug7138036  - STARTS>
  -- Logic added to handle a specific case : [ CANCEL ACTION WITH REQ RECREATED OPTION ]
  -- Recreate demand option come only in cancel action for a SPO/PPO/Blanket Release and the backing
  -- document is requisition. In that case the requisition is not considered as backing document.
  -- We pass the requisition as Main Document with REQ_RESERVE as the action. to reserve the requisition.
  -- Key to identify recreated req distribution is source_req_distribution_id field.


    l_progress := '120';

    IF p_action = 'CANCEL' THEN

    SELECT prd.distribution_id BULK COLLECT INTO l_id_tbl
    FROM  po_req_distributions_all prd,
          po_bc_distributions pbd1,     -- for Backing
          po_bc_distributions pbd2     -- For Main
     WHERE  pbd1.packet_id             = x_packet_id
       AND  prd.distribution_id = pbd1.distribution_id
       AND  prd.source_req_distribution_id IS NOT NULL
       AND  pbd1.main_or_backing_code  = 'B_REQ'
       AND  pbd1.origin_sequence_num = pbd2.sequence_number
       AND  pbd2.event_type_code IN ('PO_PA_CANCELLED','RELEASE_CANCELLED');


    FORALL i IN 1..l_id_tbl.COUNT
      UPDATE po_bc_distributions pbd
            SET  main_or_backing_code = 'M' ,event_type_code = 'REQ_RESERVED' , origin_sequence_num = NULL ,
                     entered_amt = entered_amt * -1 ,accounted_amt =  accounted_amt * -1
                WHERE  pbd.packet_id             = x_packet_id
                  AND  pbd.main_or_backing_code  = 'B_REQ'
                  AND  pbd.distribution_id  = l_id_tbl(i) ;

     IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Event type code updation in reqcreate demand is successful');
     END IF;

    END IF;

    l_progress := '130';

    --<Bug7138036  - ENDS>

   --<bug#5201733 START>
  --We need to set the value of APPLIED_TO_DIST_ID_2 this would be passed
  --onto the allocation attributes so that a 1-1 mapping can be created
  --between po_bc_distributions and xla_distribution_links. A 1-1 mapping
  --already exists between xla_distribution_links and gl_bc_packets. This
  --is the route to be followed to establish a 1-1 mapping between
  --po_bc_distributions and xla_distribution_links
    --<bug#7437681 START>
    -- Performance fix :  Also added packet id filter in the inner query to
    -- avoid a  full table scan and to use index based on packet id.
    UPDATE PO_BC_DISTRIBUTIONS PBD
    SET    PBD.line_number = PBD.bc_distribution_id,
           PBD.APPLIED_TO_DIST_ID_2=
               (
               SELECT ORIG.distribution_id
               FROM PO_BC_DISTRIBUTIONS ORIG
               WHERE ORIG.sequence_number=PBD.origin_sequence_num
               AND ORIG.packet_id = x_packet_id
           )
    WHERE  PBD.packet_id   = x_packet_id ;


    --<bug#7437681 END>
    --<bug#5201733 END>
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Bulk Insertion Successful');
    END IF;
    --<SLA R12 End>

    -- Get the current org id
    l_current_org_id := PO_MOAC_UTILS_PVT.Get_Current_Org_Id ;
    l_progress := '140' ;

    -- SQL What: Querying for legal entity and set of books
    -- SQL Why : Need legal entity and set of books applicable for current org
    -- SQL Join: None
    SELECT set_of_books_id
      INTO l_ledger_id
    FROM   hr_operating_units hou
    WHERE  hou.organization_id = l_current_org_id ;

    l_progress := '150' ;

    -- Bug 4654758 : get the legal entity id using the API
    l_legal_entity_id := xle_utilities_grp.Get_DefaultLegalContext_OU(l_current_org_id);

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_legal_entity_id ',l_legal_entity_id );
    END IF;

    l_event_status_code := xla_events_pub_pkg.c_event_unprocessed;
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_status_code ',l_event_status_code  );
    END IF;

    l_event_number      := NULL;
    l_valuation_method  := NULL;
    l_event_count:=0;


  l_progress := '160' ;

-- Deleting all the prior unprocessed events.
-- All the prior draft/invalid events are deleted before new event is created
-- for this transaction

    FOR rec_events IN ( SELECT DISTINCT xe.event_id,xe.entity_id,
     xe.event_type_code,
     xe.event_date,
     xe.event_status_code,
     xe.process_status_code,
     pbd.applied_to_header_id_1,
     pbd.applied_to_entity_code
FROM  xla_events  xe,
      po_bc_distributions pbd
 WHERE NVL(xe.budgetary_control_flag, 'N') ='Y'
   AND xe.EVENT_STATUS_CODE  in ('U' ,'I')
   AND xe.PROCESS_STATUS_CODE  IN ('I','D')
   AND xe.event_id =pbd.ae_event_id
   AND pbd.packet_id <> x_packet_id
   AND pbd.ae_event_id IS NOT NULL
   AND main_or_backing_code = 'M'
  -- AND NVL(status_code,'I') <> 'P'
  --Bug 16010392. If event status is U in xla_events and P in po_bc_dists,
  --Such event has to be deleted.
  --Bug16681444	Deleting all the prior events for the particular PO
  --AND (pbd.header_id,pbd.event_type_code) IN (SELECT DISTINCT header_id,event_type_code FROM po_bc_distributions WHERE packet_id = x_packet_id)
   AND pbd.header_id IN (SELECT DISTINCT header_id FROM po_bc_distributions WHERE packet_id = x_packet_id)
   ) LOOP

     l_event_count := l_event_count+1;
     l_events_tab(l_event_count).entity_id           := rec_events.entity_id;
     l_events_tab(l_event_count).application_id      := 201;
     l_events_tab(l_event_count).ledger_id           := l_ledger_id;
     l_events_tab(l_event_count).legal_entity_id     := l_legal_entity_id;
     l_events_tab(l_event_count).entity_code         := rec_events.applied_to_entity_code;
     l_events_tab(l_event_count).event_id            := rec_events.event_id;
     l_events_tab(l_event_count).event_status_code   := rec_events.event_status_code;
     l_events_tab(l_event_count).process_status_code := rec_events.process_status_code;
     l_events_tab(l_event_count).source_id_int_1     := rec_events.applied_to_header_id_1;

     END LOOP;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'Number of Draft events  ',l_event_count );
    END IF;

    IF l_event_count > 0 THEN

     FORALL i IN 1..l_event_count

       INSERT INTO XLA_EVENTS_INT_GT
       VALUES l_events_tab(i) ;

       XLA_EVENTS_PUB_PKG.DELETE_BULK_EVENTS(p_application_id => 201);

       FOR i in 1..l_event_count LOOP

         DELETE FROM po_bc_distributions
          WHERE applied_to_header_id_1 = l_events_tab(i).source_id_int_1
            AND packet_id <> x_packet_id
            AND ae_event_id = l_events_tab(i).event_id;

           l_num_of_rows_deleted := SQL%rowcount;

           IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'Number of rows deleted for event '
	                         ||l_events_tab(i).event_id||' are '||l_num_of_rows_deleted );
          END IF;
       END LOOP;
    END IF;

    l_progress := '170' ;

    -- Loop for all distributions in po_bc_distributions for generation of event ids
    -- Event id is unique for distribution type and gl date combination


      FOR rec_po_bc_dist IN (SELECT DISTINCT applied_to_header_id_1,segment1,distribution_type,gl_date,event_type_code
				FROM po_bc_distributions
			       WHERE packet_id = x_packet_id
			         AND main_or_backing_code = 'M')
       LOOP


         IF g_debug_stmt THEN

  	  PO_DEBUG.debug_stmt(l_log_head,l_progress,'Applied_to_header_id_1 ' || rec_po_bc_dist.applied_to_header_id_1);
          PO_DEBUG.debug_stmt(l_log_head,l_progress,'Distribution type ' || rec_po_bc_dist.distribution_type);
          PO_DEBUG.debug_stmt(l_log_head,l_progress,'GL date ' || rec_po_bc_dist.gl_date);

         END IF;

	 l_event_id := NULL;
	 l_event_source_info.source_application_id := NULL;
	 l_event_source_info.application_id        := 201 ;
	 l_event_source_info.legal_entity_id       := l_legal_entity_id;
	 l_event_source_info.ledger_id             := l_ledger_id;
	 l_event_source_info.entity_type_code      := get_entity_type_code(rec_po_bc_dist.distribution_type,p_action);
	 l_event_source_info.transaction_number    := rec_po_bc_dist.segment1;
	 l_event_source_info.source_id_int_1       := rec_po_bc_dist.applied_to_header_id_1;
	 l_security_context.security_id_int_1      := l_current_org_id ;

	  l_event_id := xla_events_pub_pkg.create_event
			  (
			    p_event_source_info => l_event_source_info,
			    p_event_type_code   => rec_po_bc_dist.event_type_code,
			    p_event_date        => rec_po_bc_dist.gl_date,
			    p_event_status_code => l_event_status_code,
			    p_event_number      => l_event_number,
                            -- Bug 18555877: the transaction date should always be sysdate
			    p_transaction_date  => sysdate,
			    p_reference_info    => l_reference_info,
			    p_valuation_method  => l_valuation_method,
			    p_security_context  => l_security_context,
			    p_budgetary_control_flag => 'Y'
			   );
      -- Update po_bc_distributions ae_event_id with the l_event_id.

         IF g_debug_stmt THEN

  	  PO_DEBUG.debug_stmt(l_log_head,l_progress,'l_event_id ' || l_event_id);
         END IF;


	     IF l_event_id IS NOT NULL then

	       UPDATE po_bc_distributions
		SET ae_event_id = l_event_id
		WHERE packet_id = x_packet_id
		 AND applied_to_header_id_1 = rec_po_bc_dist.applied_to_header_id_1
		 AND  gl_date                = rec_po_bc_dist.gl_date
		 AND  main_or_backing_code   = 'M'
		 returning sequence_number
		 BULK COLLECT INTO l_seq_num_tbl;

	       FORALL i IN 1..l_seq_num_tbl.count
			UPDATE po_bc_distributions pobd
			  SET  pobd.ae_event_id = l_event_id
			WHERE  pobd.packet_id   = x_packet_id
			   AND pobd.origin_sequence_num = l_seq_num_tbl(i);

	         l_Seq_num_tbl.delete;
	      END if;
           END LOOP;
  END IF;--if x_packet_id is not null

  IF g_debug_stmt THEN
    PO_DEBUG.debug_end(l_log_head);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_packet_id := NULL; -- Bug 3218669
    --add message to the stack and log a debug msg if necessary
    po_message_s.sql_error(g_pkg_name, l_proc_name, l_progress, SQLCODE, SQLERRM);
    fnd_msg_pub.add;
    RAISE;
END INSERT_PACKET_CREATE_EVENT;

-------------------------------------------------------------------------------
--Start of Comments
--Name: execute_gl_call
--Pre-reqs:
--  The packet has already been inserted and committed to GL_BC_PACKETS.
--Modifies:
--  GL_BC_PACKETS
--Locks:
--  None.
--Function:
--  This procedure calls the GL funds checker that operates on the
--  data in GL_BC_PACKETS and updates that table with the
--  success/failure results.
--Parameters:
--IN:
--p_set_of_books_id
--  The set of books of this org.
--p_packet_id
--  The packet_id in GL_BC_PACKETS that should be operated on.
--p_gl_mode
--  Specifies whether to call GL in 'R'eserve, 'A'djust or
--  'F'orce mode
--p_partial_resv_flag
--  Indicates whether or not partial successes are allowed.
--p_override
--  Whether to use override authority in case of Funds
--  Reservation failure due to lack of Funds.
--p_conc_flag
--  Whether invoked from a Concurrent Process.
--p_user_id
--  The user_id who is doing this action.
--p_user_resp_id
--  The responsibility id of the executer of this action.
--OUT:
--x_return_code
--  The return code of the GL funds checker.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE execute_gl_call(
  p_set_of_books_id                IN             NUMBER,
  p_packet_id                      IN OUT NOCOPY  NUMBER,
  p_gl_mode                        IN             VARCHAR2,
  p_partial_resv_flag              IN             VARCHAR2,
  p_override                       IN             VARCHAR2,
  p_conc_flag                      IN             VARCHAR2,
  p_user_id                        IN             NUMBER,
  p_user_resp_id                   IN             NUMBER,
  x_return_code                    OUT NOCOPY     VARCHAR2
) IS

  l_api_name  CONSTANT varchar2(40) := 'EXECUTE_GL_CALL';
  l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress VARCHAR2(3) := '000';
  l_return_code BOOLEAN;


  l_validate_return_status VARCHAR2(1) := 'E';
  l_validate_msg_count     NUMBER;
  l_validate_msg_data      FND_NEW_MESSAGES.message_text%TYPE;

  l_return_status          VARCHAR2(20);
  l_status_code            VARCHAR2(20);
  l_bc_mode                VARCHAR2(1); -- Bug 4995509
BEGIN

  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_set_of_books_id',p_set_of_books_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_packet_id',p_packet_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_gl_mode',p_gl_mode);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_partial_resv_flag',p_partial_resv_flag);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_override',p_override);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_conc_flag',p_conc_flag);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_user_id',p_user_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_user_resp_id',p_user_resp_id);
  END IF;

  l_progress := '100';
  -- Bug 4995509 Begin
  IF (p_partial_resv_flag = 'Y') AND (p_gl_mode <> 'C') THEN
     l_bc_mode := 'P' ;
  ELSE
     l_bc_mode := p_gl_mode ;
  END IF;
  -- Bug 4995509 End
--<bug#5200462 START>
--Force mode would be set for requisition split.
--We should be calling Req Split with force mode
--for all non-federal cases. This is to ensure that
--requisition split always succeeds. This is allright
--because we are not increasing funds in any way. We
--can only keep it constant or decrease funds.
--  IF (p_gl_mode <> 'F') THEN

    l_progress := '110';
    --<SLA R12 Begin>

    -- Call the Budgetary Control API
    PSA_BC_XLA_PUB.Budgetary_Control
                   (
                     p_api_version         => 1.0, --bug5304012
                     p_application_id      => 201,  -- Bug 5013999
                     x_packet_id           => p_packet_id,
                     p_bc_mode             => l_bc_mode,
                     p_override_flag       => p_override,
                     p_user_id             => p_user_id,
                     p_user_resp_id        => p_user_resp_id,
                     x_msg_count           => l_validate_msg_count,
                     x_msg_data            => l_validate_msg_data,
                     x_return_status       => l_return_status,
                     x_status_code         => l_status_code
                    );
    IF (l_status_code = 'SUCCESS') THEN
       x_return_code := 'S';
    ELSIF (l_status_code = 'PARTIAL') THEN
       x_return_code := 'P';
    ELSIF (l_status_code = 'ADVISORY') THEN
       x_return_code := 'A';
    ELSIF (l_status_code = 'FAIL') THEN
       x_return_code := 'F';
    ELSE
       x_return_code := 'F';
    END IF;
    l_progress := '120';
    --<SLA R12 End>

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'PSA function return_code', l_status_code);
    END IF;

    --<R12 SLA Begin>
    -- Raise exception if return status is Unexpected error('U') or
    -- if return code is FATAL/XLA_ERROR/XLA_NO_JOURNAL
    IF ( l_return_status  IN ('U')
         OR l_status_code IN ('FATAL', 'XLA_ERROR', 'XLA_NO_JOURNAL' )  -- Bug 5009730
       )
    THEN
      l_progress := '125';
      -- Delete records from po_bc_distributions
      --bug#5523323 once we remove the autonomous txn we don't have to explicity delete
      --data from po_bc_distributions.
      --Delete_PO_BC_Distributions(p_packet_id  =>  p_packet_id);     -- Bug #4637958

      l_progress := '130';
      RAISE g_GL_FUNDS_API_EXC;
    END IF;
    --<R12 SLA End>

    l_progress := '140';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'GL Call Executed Successfully');
    END IF;

--  END IF; -- p_gl_mode <> 'F' or l_validate_return_status...
--<bug#5200462 END>

  l_progress := '900';

  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'GL Call x_return_code',x_return_code);
    PO_DEBUG.debug_end(l_log_head);
  END IF;

EXCEPTION
  WHEN g_GL_FUNDS_API_EXC THEN
    --<BEGIN Bug:12824154>---
   /*FND_MESSAGE.set_name('PO', 'PO_API_ERROR');
    FND_MESSAGE.set_token('PROC_CALLED',
                          'PSA_BC_XLA_PUB.Budgetary_Control');
    FND_MESSAGE.set_token('PROC_CALLER',
                          'PO_ENCUMBRANCE_POSTPROCESSING.execute_gl_call');
    fnd_msg_pub.add;
    IF g_debug_unexp THEN
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_code',x_return_code);
    END IF; */
    RAISE PO_ENCUMBRANCE_POSTPROCESSING.g_EXECUTE_GL_CALL_API_EXC;
   --<END Bug:12824154>---

  WHEN OTHERS THEN
    --add message to the stack and log a debug msg if necessary
    po_message_s.sql_error(g_pkg_name, l_api_name, l_progress,
                           SQLCODE, SQLERRM);
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END execute_gl_call;



-------------------------------------------------------------------------------
--Start of Comments
--To address bug 12405805
--Name: delete_unnecessary_eventss
--Pre-reqs:
--None
--Modifies:
--  PO_BC_DISTRIBUTIONS
--Locks:
--  None.
--Function:
--Based on records inserted into po_bc_distributions during insert_packet_create_event,
--this function identifies the unprocessed  events associated with current encumbrance action
--which are  in draft/invalid status. Records in PO_BC corresponding to such events are deleted and those
--events are also deleted.
--Parameters:
--IN:
--p_packet_id
--  ID of the packet inserted into PO_BC_DISTRIBUTIONS table.
--p_action
--  The current encumbrance action
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE delete_unnecessary_events(
p_packet_id         IN         NUMBER,
p_action            IN         VARCHAR2

)
IS

 TYPE t_event_id IS TABLE OF  po_bc_distributions.ae_event_id%TYPE;
 l_event_id t_event_id := t_event_id();
 l_event_source_info      xla_events_pub_pkg.t_event_source_info;
 l_delete_event           NUMBER;
 l_security_context       xla_events_pub_pkg.t_security;
 l_api_name              CONSTANT varchar2(30) := 'delete_unnecessary_events';
 l_log_head		CONSTANT varchar2(100) := g_log_head || l_api_name;
 l_progress              VARCHAR2(3) := '000';

 CURSOR to_delete_checkfunds IS
         SELECT  DISTINCT pbd.ae_event_id,
           pbd.segment1,
           pbd.applied_to_header_id_1,
           pbd.distribution_type
         FROM
           po_bc_distributions pbd,
           xla_events xe,
           xla_transaction_entities xte
         WHERE
           xe.event_id = pbd.ae_event_id
           AND xe.EVENT_STATUS_CODE = 'U'
           AND xe.PROCESS_STATUS_CODE in ('D', 'I')
           AND pbd.packet_id = p_packet_id
           AND xte.application_id = 201
           AND xte.entity_id =  xe.entity_id
           AND xte.source_id_int_1 = pbd.header_id;

 CURSOR to_delete_invalids IS
         SELECT  DISTINCT pbd.ae_event_id,
           pbd.segment1,
           pbd.applied_to_header_id_1,
           pbd.distribution_type
         FROM
           po_bc_distributions pbd,
           xla_events xe,
           xla_transaction_entities xte
         WHERE
          xe.event_id = pbd.ae_event_id
          AND xe.EVENT_STATUS_CODE = 'P'
          AND xe.PROCESS_STATUS_CODE = 'I'
          AND pbd.packet_id = p_packet_id
          AND xte.application_id = 201
          AND xte.entity_id =  xe.entity_id
          AND xte.source_id_int_1 = pbd.header_id;

BEGIN

        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(l_log_head,l_progress,'p_packet_id', p_packet_id);
          PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
        END IF;

       /*Gathering the event source info to delete event */
        l_event_source_info.legal_entity_id       := xle_utilities_grp.Get_DefaultLegalContext_OU(PO_MOAC_UTILS_PVT.Get_Current_Org_Id );
        l_event_source_info.source_application_id := NULL;
        l_event_source_info.application_id        := 201 ;

        SELECT set_of_books_id
        INTO l_event_source_info.ledger_id
        FROM   hr_operating_units hou
        WHERE  hou.organization_id = PO_MOAC_UTILS_PVT.Get_Current_Org_Id ;

        l_security_context.security_id_int_1      := PO_MOAC_UTILS_PVT.Get_Current_Org_Id ;

        l_progress := '010';

	IF g_debug_stmt THEN
	  PO_DEBUG.debug_var(l_log_head,l_progress,'legal_entity_id', l_event_source_info.legal_entity_id);
	  PO_DEBUG.debug_var(l_log_head,l_progress,'ledger_id', l_event_source_info.ledger_id);
	  PO_DEBUG.debug_var(l_log_head,l_progress,'security_id_int_1', l_security_context.security_id_int_1);
        END IF;


        /*delete draft and invalid events*/

        IF (p_action= g_action_RESERVE) THEN
	    l_progress := '030';
	    FOR rec_to_del IN  to_delete_checkfunds loop
                IF g_debug_stmt THEN
                   PO_DEBUG.debug_var(l_log_head,l_progress,'iteration for event_id', rec_to_del.ae_event_id);
                 END IF;

		/*event_ids are collected now*/
		/*have to delete these events*/

		 l_event_source_info.entity_type_code      := get_entity_type_code(rec_to_del.distribution_type,p_action);
		 l_event_source_info.transaction_number    := rec_to_del.segment1;
		 l_event_source_info.source_id_int_1       := rec_to_del.applied_to_header_id_1;


		 IF g_debug_stmt THEN
		    PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_source_info.entity_type_code', l_event_source_info.entity_type_code);
		    PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_source_info.transaction_number', l_event_source_info.transaction_number);
		    PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_source_info.source_id_int_1', l_event_source_info.source_id_int_1 );
		 END IF;

	         xla_events_pub_pkg.DELETE_EVENT
                          (
                             p_event_source_info    => l_event_source_info,
                             p_event_id             => rec_to_del.ae_event_id,
                             p_valuation_method     => NULL,
                             p_security_context     => l_security_context
                            );
            END LOOP;
            DELETE FROM po_bc_distributions WHERE packet_id = p_packet_id;
         ELSE

	    FOR rec_to_del IN  to_delete_invalids loop

	        /*event_ids are collected now*/
                /*have to delete these events*/

		l_event_source_info.entity_type_code      := get_entity_type_code(rec_to_del.distribution_type,p_action);
		l_event_source_info.transaction_number    := rec_to_del.segment1;
		l_event_source_info.source_id_int_1       := rec_to_del.applied_to_header_id_1;

		IF g_debug_stmt THEN
		   PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_source_info.entity_type_code', l_event_source_info.entity_type_code);
		   PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_source_info.transaction_number', l_event_source_info.transaction_number);
		   PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_source_info.source_id_int_1', l_event_source_info.source_id_int_1 );
		END IF;

                xla_events_pub_pkg.DELETE_EVENT
                          (
                            p_event_source_info    => l_event_source_info,
                            p_event_id             => rec_to_del.ae_event_id,
                            p_valuation_method     => NULL,
                            p_security_context     => l_security_context
                            );

            END LOOP;
            DELETE FROM po_bc_distributions WHERE packet_id = p_packet_id ;

        END IF;

 EXCEPTION
 WHEN OTHERS THEN
      IF g_debug_stmt THEN
          PO_DEBUG.debug_var(l_log_head,l_progress, 'Exception block of Delete_unnecessary_events', SQLERRM);
      END IF;
 RAISE;
 END;

 /* End of Bug  12405805 */



-------------------------------------------------------------------------------
--Start of Comments
--Name: copy_detailed_gl_results
--Pre-reqs:
--  PO_ENCUMBRANCE_GT is populated with all calculations.
--  Call to GL Funds Checker already made on given packet ID.
--Modifies:
--  GL_BC_PACKETS
--Locks:
--  None.
--Function:
--  Copies result information from gl_bc_packets into PO_ENCUMBRANCE_GT
--  Further post-processing/error reporting relies on this information from GTT
--Parameters:
--IN:
--p_packet_id
--  ID of the packet inserted into gl_bc_packets table.
--p_gl_return_code
--  The overall transaction return code provided by GL from the glxfck() call
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE copy_detailed_gl_results(
  p_packet_id         IN         NUMBER,
  p_gl_return_code    IN         VARCHAR2
)
IS

  l_api_name  CONSTANT varchar2(40) := 'COPY_DETAILED_GL_RESULTS';
  l_log_head  CONSTANT varchar2(100) := g_log_head || l_api_name;
  l_progress  VARCHAR2(3) := '000';

  l_debug_count  NUMBER;
  l_po_prevent_text  FND_NEW_MESSAGES.message_text%TYPE;
  l_not_processed_msg  FND_NEW_MESSAGES.message_text%TYPE;

  -- bug3543542 START
  TYPE gl_status_tbl_type IS TABLE OF PO_ENCUMBRANCE_GT.gl_status_code%TYPE;
  TYPE gl_result_code_tbl_type IS TABLE OF PO_ENCUMBRANCE_GT.gl_result_code%TYPE;
  TYPE update_enc_amt_flag_tbl_type IS TABLE OF PO_ENCUMBRANCE_GT.update_encumbered_amount_flag%TYPE;
  TYPE dist_id_tbl_type IS TABLE OF PO_ENCUMBRANCE_GT.distribution_id%TYPE;
  TYPE reference15_tbl_type IS TABLE OF PO_ENCUMBRANCE_GT.reference15%TYPE;  --<bug#5201733 START>
  l_gl_status_tbl            gl_status_tbl_type;
  l_gl_result_code_tbl       gl_result_code_tbl_type;
  l_update_enc_amt_flag_tbl  update_enc_amt_flag_tbl_type;
  l_dist_id_tbl              dist_id_tbl_type;
  l_dist_type_tbl            po_tbl_varchar30;
  -- bug3543542 END
  l_encumbered_amount_change  po_tbl_number;     -- Bug 4878973
  l_reference15_tbl         reference15_tbl_type;--bug#5201733
BEGIN

  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_packet_id',p_packet_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_gl_return_code',p_gl_return_code);
  END IF;
   --<bug#5353223 START>
  l_progress := '010';

  -- Bug#14593047 START: Revamped the query to removed the
  -- XLA_DISTRIBUTIONS_LINKS table as the join between po_bc_distributions
  -- and gl_bc_packets can be achieved with event id condition
  -- This is necessary to improve the performance of the query which will
  -- avoid FTS on the XLA table.
  --<bug#5112144 START>
  --Modified the query below to join with gl_bc_packets_hists
  --This is so that the error rows are always found. GL moves
  --all errored rows to gl_bc_packets_hist for performance reasons.
  --<bug#5201733 START>
  --We have to join with xla_distribution_links to get a mapping between
  --po_bc_distributions and gl_bc_packets. We need a distinct to ensure that
  --for federal /customization cases where there could be multiple rows in
  --gl_bc_packets for the same distribution po_bc_distributions we are returned
  --just one row.
  --<Bug#7138036 START>
  -- We will get all the packets id from gl_bc_packets for the events which we have  populated in
  -- psa_bc_xla_events_gt table for the current packet Id. We won't use the packet id returned by
  -- Execute GL call as there can be mutiple packet id from which we need to take the result from
  -- GL BC PACKETS. In case of Cancel action with recreate demand we create two events, which belong
  -- to different entity. So two packets will be created by PSA.
  --<Bug#7437681 START>
  -- Performance Fix : Changed in Inner query based on psa_bc_xla_events_gt to
  -- change the Plan of the Overall SQL.
    /* bug 13562823 - To improve performance added hint and column code_combination_id so that index on packet_id and code_combination_id
     on table GL_BC_PACKETS would be considered. */
/*
   SELECT
         DISTINCT
         STATUS_CODE,
         RESULT_CODE,
         AUTOMATIC_ENCUMBRANCE_FLAG,
         SOURCE_DISTRIBUTION_ID_NUM_1,
         SOURCE_DISTRIBUTION_TYPE,
         TRANSACTION_AMOUNT,
         REFERENCE15
    BULK COLLECT
    INTO l_gl_status_tbl,
         l_gl_result_code_tbl,
         l_update_enc_amt_flag_tbl,
         l_dist_id_tbl,
         l_dist_type_tbl,
         l_encumbered_amount_change,
         l_reference15_tbl
    FROM (

          SELECT GLBC.status_code STATUS_CODE,
                  GLBC.result_code RESULT_CODE,
                  nvl(GLBC.automatic_encumbrance_flag, 'Y') AUTOMATIC_ENCUMBRANCE_FLAG,
                  GLBC.SOURCE_DISTRIBUTION_ID_NUM_1 SOURCE_DISTRIBUTION_ID_NUM_1,
                  GLBC.SOURCE_DISTRIBUTION_TYPE SOURCE_DISTRIBUTION_TYPE,
                  PO_ENCUMBRANCE_POSTPROCESSING.get_sign_for_amount(pbd.event_type_code,
                                                                    pbd.main_or_backing_code,
                                                                    pbd.adjustment_status,
                                                                    pbd.distribution_type) *
                  PBD.accounted_amt TRANSACTION_AMOUNT,
                  PBD.reference15 REFERENCE15
            FROM XLA_DISTRIBUTION_LINKS XLD,
                  PO_BC_DISTRIBUTIONS    PBD,
                  GL_BC_PACKETS          GLBC
           WHERE  (GLBC.PACKET_ID, GLBC.CODE_COMBINATION_ID) IN (
		                            SELECT /*+ unnest */
/*						   DISTINCT glbc1.packet_id,
						   glbc1.code_combination_id
	                                    FROM  psa_bc_xla_events_gt ps_ev_Gt,
				                  GL_BC_PACKETS  glbc1
                                            WHERE ps_ev_Gt.event_id = glbc1.event_id)
             AND XLD.AE_HEADER_ID = GLBC.ae_header_id
             AND xld.ae_line_num = GLBC.ae_line_num
             AND xld.event_id = GLBC.event_id
             AND GLBC.application_id = xld.application_id
             AND GLBC.source_distribution_type = xld.source_distribution_type
             AND GLBC.SOURCE_DISTRIBUTION_ID_NUM_1 =
                 xld.SOURCE_DISTRIBUTION_ID_NUM_1
             AND pbd.distribution_id = xld.SOURCE_DISTRIBUTION_ID_NUM_1
             AND decode(pbd.distribution_type,g_dist_type_REQUISITION,
                        'PO_REQ_DISTRIBUTIONS_ALL','PO_DISTRIBUTIONS_ALL') = xld.source_distribution_type
             AND pbd.ae_event_id = xld.event_id
             AND NVL(PBD.applied_to_dist_id_2, pbd.distribution_id) =
                 XLD.ALLOC_TO_DIST_ID_NUM_1
             AND xld.application_id = 201
             AND xld.event_id = pbd.ae_event_id
             AND glbc.template_id is null
          UNION ALL
          SELECT GLBCH.status_code STATUS_CODE,
                 GLBCH.result_code RESULT_CODE,
                 nvl(GLBCH.automatic_encumbrance_flag, 'Y') AUTOMATIC_ENCUMBRANCE_FLAG,
                 GLBCH.SOURCE_DISTRIBUTION_ID_NUM_1 SOURCE_DISTRIBUTION_ID_NUM_1,
                 GLBCH.SOURCE_DISTRIBUTION_TYPE SOURCE_DISTRIBUTION_TYPE,
                 PO_ENCUMBRANCE_POSTPROCESSING.get_sign_for_amount(pbd.event_type_code,
                                                                   pbd.main_or_backing_code,
                                                                   pbd.adjustment_status,
                                                                   pbd.distribution_type) *
                 PBD.accounted_amt TRANSACTION_AMOUNT,
                 PBD.reference15 REFERENCE15
            FROM XLA_DISTRIBUTION_LINKS XLD,
                 PO_BC_DISTRIBUTIONS    PBD,
                 GL_BC_PACKETS_HISTS    GLBCH
           WHERE GLBCH.PACKET_ID IN (SELECT DISTINCT glbch1.packet_id
 	                             FROM  psa_bc_xla_events_gt ps_ev_Gt ,
				           GL_BC_PACKETS_HISTS  glbch1
                                     WHERE ps_ev_Gt.event_id = glbch1.event_id)
             AND XLD.AE_HEADER_ID = GLBCH.ae_header_id
             AND xld.ae_line_num = GLBCH.ae_line_num
             AND xld.event_id = GLBCH.event_id
             AND GLBCH.application_id = xld.application_id
             AND GLBCH.source_distribution_type =
                 xld.source_distribution_type
             AND GLBCH.SOURCE_DISTRIBUTION_ID_NUM_1 =
                 xld.SOURCE_DISTRIBUTION_ID_NUM_1
             AND pbd.distribution_id = xld.SOURCE_DISTRIBUTION_ID_NUM_1
             AND decode(pbd.distribution_type,g_dist_type_REQUISITION,
                        'PO_REQ_DISTRIBUTIONS_ALL','PO_DISTRIBUTIONS_ALL') = xld.source_distribution_type
             AND pbd.ae_event_id = xld.event_id
             AND NVL(PBD.applied_to_dist_id_2, pbd.distribution_id) =
                 XLD.ALLOC_TO_DIST_ID_NUM_1
             AND xld.application_id = 201
             AND xld.event_id = pbd.ae_event_id
             AND glbch.template_id is null
             );   */
  --<Bug#7437681 END>
  --<Bug#7138036 END>
  --<bug#5201733 END>
  --<bug#5112144 END>
  --<bug#5353223 END>

    SELECT
         DISTINCT
         STATUS_CODE,
         RESULT_CODE,
         AUTOMATIC_ENCUMBRANCE_FLAG,
         SOURCE_DISTRIBUTION_ID_NUM_1,
         SOURCE_DISTRIBUTION_TYPE,
         TRANSACTION_AMOUNT,
         REFERENCE15
    BULK COLLECT
    INTO l_gl_status_tbl,
         l_gl_result_code_tbl,
         l_update_enc_amt_flag_tbl,
         l_dist_id_tbl,
         l_dist_type_tbl,
         l_encumbered_amount_change,
         l_reference15_tbl
    FROM (  SELECT   GLBC.STATUS_CODE STATUS_CODE,
                   GLBC.RESULT_CODE RESULT_CODE,
                   NVL (GLBC.AUTOMATIC_ENCUMBRANCE_FLAG, 'Y')
                      AUTOMATIC_ENCUMBRANCE_FLAG,
                   GLBC.SOURCE_DISTRIBUTION_ID_NUM_1
                      SOURCE_DISTRIBUTION_ID_NUM_1,
                   GLBC.SOURCE_DISTRIBUTION_TYPE SOURCE_DISTRIBUTION_TYPE,
                   PO_ENCUMBRANCE_POSTPROCESSING.GET_SIGN_FOR_AMOUNT (
                      PBD.EVENT_TYPE_CODE,
                      PBD.MAIN_OR_BACKING_CODE,
                      PBD.ADJUSTMENT_STATUS,
                      PBD.DISTRIBUTION_TYPE
                   )
                   * PBD.ACCOUNTED_AMT
                      TRANSACTION_AMOUNT,
                   PBD.REFERENCE15 REFERENCE15
            FROM   PO_BC_DISTRIBUTIONS PBD,
                   GL_BC_PACKETS GLBC
           WHERE    pbd.packet_id = p_packet_id
                   AND pbd.ae_EVENT_ID = GLBC.EVENT_ID
                   AND GLBC.TEMPLATE_ID IS NULL
                  AND GLBC.SOURCE_DISTRIBUTION_ID_NUM_1 = pbd.distribution_id --Bug 16437550

          UNION ALL
          SELECT   GLBCH.STATUS_CODE STATUS_CODE,
                   GLBCH.RESULT_CODE RESULT_CODE,
                   NVL (GLBCH.AUTOMATIC_ENCUMBRANCE_FLAG, 'Y')
                      AUTOMATIC_ENCUMBRANCE_FLAG,
                   GLBCH.SOURCE_DISTRIBUTION_ID_NUM_1
                      SOURCE_DISTRIBUTION_ID_NUM_1,
                   GLBCH.SOURCE_DISTRIBUTION_TYPE SOURCE_DISTRIBUTION_TYPE,
                   PO_ENCUMBRANCE_POSTPROCESSING.GET_SIGN_FOR_AMOUNT (
                      PBD.EVENT_TYPE_CODE,
                      PBD.MAIN_OR_BACKING_CODE,
                      PBD.ADJUSTMENT_STATUS,
                      PBD.DISTRIBUTION_TYPE
                   )
                   * PBD.ACCOUNTED_AMT
                      TRANSACTION_AMOUNT,
                   PBD.REFERENCE15 REFERENCE15
            FROM    PO_BC_DISTRIBUTIONS PBD,
                   GL_BC_PACKETS_HISTS GLBCH
           WHERE     pbd.packet_id = p_packet_id
                    AND pbd.ae_EVENT_ID = GLBCH.EVENT_ID
                   AND GLBCH.TEMPLATE_ID IS NULL
		   AND GLBCH.SOURCE_DISTRIBUTION_ID_NUM_1 = pbd.distribution_id --Bug 16437550
             );
  -- Bug#14593047 END--


IF g_debug_stmt THEN
   l_debug_count := SQL%ROWCOUNT;
   PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Status/Result codes returned for '
                       || l_debug_count || ' rows');
END IF;

  l_progress := '020';

  FORALL i IN 1..l_gl_status_tbl.COUNT
  UPDATE PO_ENCUMBRANCE_GT TEMP
    SET  TEMP.gl_status_code = l_gl_status_tbl(i),
         TEMP.gl_result_code = l_gl_result_code_tbl(i),
         TEMP.update_encumbered_amount_flag = l_update_enc_amt_flag_tbl(i),
         TEMP.encumbered_amount_change = l_encumbered_amount_change(i)          -- Bug 4878973
  WHERE TEMP.reference15=l_reference15_tbl(i);--bug#5201733 joining using reference15 as this is the unique key

  --NOTE: The Temp Table field encumbered_amount_change is used throughout these
  --      update calculations in update_successful_rows.

--Note: in bug 3568512, we already set update_encumbered_amount_flag = 'N'
--for backing BPA/PPO rows that are unreserved (in update_encumbrance_gt).
--these rows also have a send_to_gl_flag = 'N'. We have to maintain
--the UNencumbered_amount for these rows, but do not want to update
--the encumbered_amount, since no trxn was sent to GL.

IF g_debug_stmt THEN
   l_debug_count := SQL%ROWCOUNT;
   PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Status/Result codes updated on '
                       || l_debug_count || ' rows');
END IF;

--<bug#5112144 START>
--Reinstating this piece of code so that online_report gets populated
--as before and this would work for Workflow , Modify Requisition and
--Requisition Split in oa as well as isp and messages would be displayed.

l_progress := '030';

l_po_prevent_text := FND_MESSAGE.get_string('PO', 'PO_ENC_DIST_PREVENTED');

UPDATE PO_ENCUMBRANCE_GT DISTS
SET    DISTS.result_text = l_po_prevent_text
,      DISTS.result_type = g_result_WARNING
WHERE  DISTS.prevent_encumbrance_flag = 'Y'
AND    DISTS.result_text IS NULL;

IF g_debug_stmt THEN
   l_debug_count := SQL%ROWCOUNT;
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
                       'Number of prevent rows updated: ' || l_debug_count);
END IF;

l_progress := '040';

UPDATE PO_ENCUMBRANCE_GT DISTS
SET DISTS.result_text =
    (SELECT GL_TEXT.description
     FROM  GL_LOOKUPS GL_TEXT
     WHERE GL_TEXT.lookup_type = 'FUNDS_CHECK_RESULT_CODE'
     AND   GL_TEXT.lookup_code(+) = DISTS.gl_result_code
    )
WHERE DISTS.gl_result_code IS NOT NULL
AND   DISTS.result_text IS NULL;

IF g_debug_stmt THEN
   l_debug_count := SQL%ROWCOUNT;
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
                       'Number of result text rows updated: ' || l_debug_count);
END IF;

l_progress := '050';

IF p_gl_return_code IN ('A', 'S', 'P') THEN

   l_progress := '060';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Updating successful rows.');
   END IF;

   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET   DISTS.result_type = g_result_WARNING
   WHERE DISTS.gl_result_code IN
			/*Bug13887688 Adding few more lookup_codes which are also WARNINGS*/
            ('P20','P21','P22','P23','P25','P26','P27', 'P39','P29','P31', 'P35', 'P36', 'P37', 'P38')
   AND DISTS.gl_status_code IN ('A', 'S');

   l_progress := '070';

   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'Number of rows set to Warning: ' || l_debug_count);
   END IF;

   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET DISTS.result_type = g_result_SUCCESS
   WHERE DISTS.result_type IS NULL
   AND DISTS.gl_status_code IN ('A', 'S');

   l_progress := '080';

   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'Number of rows set to Success: ' || l_debug_count);
   END IF;

END IF;  -- gl_return_code is S, A or P

l_progress := '100';

IF p_gl_return_code IN ('P', 'F', 'T') THEN

   l_progress := '110';

   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Updating failed rows.');
   END IF;

   l_not_processed_msg := FND_MESSAGE.get_string('PO', 'PO_ENC_DIST_NOT_PROCESSED');

   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET DISTS.result_type = g_result_ERROR
   WHERE DISTS.result_type IS NULL
   AND DISTS.gl_result_code like 'F%'
   AND DISTS.gl_status_code IN ('R', 'F');

   l_progress := '120';

   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'Number of rows failed: ' || l_debug_count);
   END IF;

   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET DISTS.result_type = g_result_NOT_PROCESSED
   ,   DISTS.result_text = l_not_processed_msg
   WHERE DISTS.result_type IS NULL
   AND DISTS.gl_result_code like 'P%'
   AND DISTS.gl_status_code IN ('R', 'F');

   l_progress := '130';

   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'Number of rows not processed: ' || l_debug_count);
   END IF;

END IF;  -- gl_return_code is P, F or T

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
                       'PO update of text/message type successful');
   PO_DEBUG.debug_table(l_log_head, l_progress, 'PO_ENCUMBRANCE_GT',
                        PO_DEBUG.g_all_rows,
                        po_tbl_varchar30('result_text', 'result_type',
                                         'prevent_encumbrance_flag')
   );
   PO_DEBUG.debug_end(l_log_head);
END IF;
--<bug#5112144 END>
EXCEPTION

WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END copy_detailed_gl_results;

-------------------------------------------------------------------------------
--Start of Comments
--Name: update_document_encumbrance
--Pre-reqs:
--  PO_ENCUMBRANCE_GT has all necessary information populated after
--  making a call to the GL Funds Checker
--Modifies:
--  PO_REQ_DISTRIBUTIONS_ALL, PO_DISTRIBUTIONS_ALL, PO_REQUISITION_LINES_ALL,
--  PO_LINE_LOCATIONS_ALL
--Locks:
--  None.
--Function:
--  This procedure calls helpers to update the distributions appropriately based
--  on whether transaction was successful or not.  It is only called for
--  actual encumbrance actions (Pending mode), but NOT Funds Check (Checking
--  mode)
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the main doc being a REQUISITION, AGREEMENT,
--  PURCHASE ORDER, or RELEASE which is used to identify the tables to look at
--  (PO vs. Req) and the join conditions
--p_doc_subtype
--  Differentiates between the possible subtypes of the main document
--  REQUISITION: NULL
--  PURCHASE ORDER: STANDARD, PLANNED
--  AGREEMENT: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_action
--  Encumbrance action requested on the main document:
--  RESERVE/UNRESERVE/CANCEL/FINAL CLOSE/RETURN/REJECT/ADJUST
--p_gl_return_code
--  Return value from the call to GL funds checker
--  (obtained in the execute_gl_call procedure)
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE update_document_encumbrance(
  p_doc_type                       IN             VARCHAR2
, p_doc_subtype                    IN             VARCHAR2
, p_action                         IN             VARCHAR2
, p_gl_return_code                 IN             VARCHAR2
) IS

l_api_name  CONSTANT varchar2(40) := 'UPDATE_DOCUMENT_ENCUMBRANCE';
l_log_head  CONSTANT varchar2(100) := g_log_head || l_api_name;
l_progress VARCHAR2(3);
l_return_code BOOLEAN;

BEGIN

l_progress := '000';

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_gl_return_code',p_gl_return_code);
END IF;

l_progress := '010';

IF p_gl_return_code IN ('S','A','P') THEN

   -- THE ENCUMBRANCE ACTION WAS AT LEAST PARTIALLY SUCCESSFUL
   update_successful_rows(
     p_doc_type       => p_doc_type
   , p_doc_subtype    => p_doc_subtype
   , p_action         => p_action
   , p_gl_return_code =>  p_gl_return_code
   );

END IF;  -- gl_return_code is S, A or P

l_progress := '030';

IF p_gl_return_code IN ('P','T','F') THEN

   -- THE ENCUMBRANCE ACTION WAS NOT FULLY SUCCESSFUL
   update_failed_rows(
     p_doc_type      => p_doc_type
   , p_action        => p_action
   );

END IF;  -- gl_return_code is P, F or T

l_progress := '040';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END update_document_encumbrance;


-------------------------------------------------------------------------------
--Start of Comments
--Name: update_successful_rows
--Pre-reqs:
--  PO_ENCUMBRANCE_GT has all necessary information populated after
--  making a call to the GL Funds Checker
--Modifies:
--  PO_REQ_DISTRIBUTIONS, PO_DISTRIBUTIONS
--Locks:
--  None.
--Function:
--  This procedure updates the accounting information on the Req/PO
--  distributions involved in a successful encumbrance transaction.
--  This procedure is only called for actual encumbrance actions (Pending mode)
--  but NOT Funds Check (Checking mode)
--  The encumbered flags are not modified for the Adjust Action
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the main doc being a REQUISITION, AGREEMENT,
--  PURCHASE ORDER, or RELEASE which is used to identify the tables to look at
--  (PO vs. Req) and the join conditions
--p_doc_subtype
--  Differentiates between the possible subtypes of the main document
--  REQUISITION: NULL
--  PURCHASE ORDER: STANDARD, PLANNED
--  AGREEMENT: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_action
--  Encumbrance action requested on the main document:
--  Valid values: g_action_<> pkg vars
--p_gl_return_code
--  Return value from the call to GL funds checker
--  (obtained in the execute_gl_call procedure)
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE update_successful_rows(
  p_doc_type                       IN             VARCHAR2
, p_doc_subtype                    IN             VARCHAR2
, p_action                         IN             VARCHAR2
, p_gl_return_code                 IN             VARCHAR2
) IS

l_api_name  CONSTANT varchar2(40) := 'UPDATE_SUCCESSFUL_ROWS';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress VARCHAR2(3);

l_flip_enc_flag varchar2(1);
l_main_doc_enc_flag_success varchar2(1);
l_backing_req_enc_flag_success varchar2(1);

l_debug_count     NUMBER;
l_return_status   VARCHAR2(1);
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(2000);

BEGIN

l_progress := '000';

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_gl_return_code',p_gl_return_code);
END IF;

l_progress := '010';

-- Note: we only update the encumbered_flag on backing Reqs, but not other
-- backing documents i.e. PAs, PPO.  An explicit encumbrance action on the
-- PA/PPO is required for any encumbered_flag change on that document.
-- For Adjust action, the encumbered_flag is not modified.

IF p_action IN (g_action_RESERVE,
                g_action_UNDO_FINAL_CLOSE) THEN  --bug 3414955

   l_flip_enc_flag := 'Y';
   l_main_doc_enc_flag_success := 'Y';
   l_backing_req_enc_flag_success := 'N';

ELSIF p_action in (g_action_UNRESERVE
                 , g_action_REJECT
                 , g_action_RETURN
                 , g_action_FINAL_CLOSE
                 , g_action_CANCEL) THEN

   l_flip_enc_flag := 'Y';
   l_main_doc_enc_flag_success := 'N';
   l_backing_req_enc_flag_success := 'Y';

ELSIF p_action in (g_action_ADJUST
                 , g_action_INVOICE_CANCEL
                 , g_action_CR_MEMO_CANCEL) THEN

   --Do not update the main or backing doc's encumbered_flag
   l_flip_enc_flag := 'N';

-- Bug 3537764: Set flags for req split action, previously left out
-- Setting l_flip_enc_flag to 'Y' does not change the previously
-- existing logic for setting the encumbered flag, but now
-- the changes to req. distribution encumbered flags will be rolled up
ELSIF p_action in (g_action_REQ_SPLIT) THEN

   l_flip_enc_flag := 'Y';

END IF;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_flip_enc_flag',l_flip_enc_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_main_doc_enc_flag',
                                             l_main_doc_enc_flag_success);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_backing_req_enc_flag',
                                             l_backing_req_enc_flag_success);
END IF;

--NOTE: The Temp Table field encumbered_amount_change is used throughout these
--      update calculations. The code for this has been merged with the update in
--      copy_detailed_gl_results.

l_progress := '020';
IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
                       'Updated encumbered_amount_change');
   PO_DEBUG.debug_table(l_log_head, l_progress, 'PO_ENCUMBRANCE_GT',
                        PO_DEBUG.g_all_rows,
                        po_tbl_varchar30('encumbered_flag',
                                         'encumbered_amount_change')
   );
END IF;


IF p_doc_type = g_doc_type_REQUISITION THEN

--SQL What:   Update the encumbered_flag and encumbered_amount on the Req
--            distribution, if the Req was the main document.
--SQL Where:  Only updates those Requisition distributions where the
--            distribution row was sent to and successful in the GL packet
--SQL Why:    If the distribution transaction succeeded, the distribution table
--            fields must be updated to reflect the effect of the transaction

   UPDATE PO_REQ_DISTRIBUTIONS_ALL PRD
   SET
   (
      PRD.encumbered_flag
   ,  PRD.encumbered_amount
   )
   =
   (
      SELECT
         --encumbered flag:
         DECODE( l_flip_enc_flag
               , 'N',  PRD.encumbered_flag   -- don't flip flag
               , l_main_doc_enc_flag_success),

         --encumbered amt:
         nvl(PRD.encumbered_amount, 0) +
            SUM (decode(TEMP.update_encumbered_amount_flag,
                        'Y', TEMP.encumbered_amount_change,
                         0)
                )
      FROM PO_ENCUMBRANCE_GT TEMP
      WHERE TEMP.distribution_id = PRD.distribution_id
      AND TEMP.distribution_type = g_dist_type_REQUISITION
      GROUP BY TEMP.distribution_id
   ), /* Updating these cols also for bug#13930578 */
    PRD.last_update_date = sysdate,
   PRD.last_updated_by = fnd_global.user_id,
   PRD.last_update_login = fnd_global.login_id
   WHERE PRD.distribution_id in
   (
       SELECT MAIN_REQ.distribution_id
       FROM PO_ENCUMBRANCE_GT MAIN_REQ
       WHERE MAIN_REQ.distribution_type = g_dist_type_REQUISITION -- doc is Req
       AND MAIN_REQ.origin_sequence_num IS NULL    -- doc is main doc
       AND MAIN_REQ.gl_status_code = 'A'
       AND MAIN_REQ.send_to_gl_flag = 'Y'  --bug 3568512: use new column
   );

   l_progress := '030';
   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'Updated Main Req dists: ' || l_debug_count);
   END IF;

   --bug 3537764: added following code to handle flags for Req Split
   IF (p_action = g_action_REQ_SPLIT) THEN

      --SQL What:   Update the encumbered_flag and prevent_encumbrance_flag
      --            of the old and new Req distributions from a Req Split
      --SQL Where:  Only updates those Requisition distributions where the
      --            distribution row was sent to and successful in GL packet
      --SQL Why:    In Req Split, encumbrance is moved from old lines to
      --            new lines, so status of the enc flags are flipped to
      --            reflect that.  Also, once a Req line is split (old lines),
      --            you can no longer act on it, so we set the prevent-enc
      --            flag on these lines -- as a marker to ignore them for
      --            future actions

      UPDATE PO_REQ_DISTRIBUTIONS_ALL PRD
      SET (
         PRD.encumbered_flag
      ,  PRD.prevent_encumbrance_flag
      )
      =
      (  SELECT
            --encumbered_flag:
            --unreserve old rows, reserve new rows
            DECODE( TEMP.adjustment_status
                  , g_adjustment_status_OLD, 'N'
                  , g_adjustment_status_NEW, 'Y'
                  , TEMP.encumbered_flag
            ),

            --prevent_encumbrance_flag:
            --old rows are marked prevent-enc for future actions
            DECODE( TEMP.adjustment_status
                  , g_adjustment_status_OLD, 'Y'
                  , TEMP.prevent_encumbrance_flag
            )
         FROM PO_ENCUMBRANCE_GT TEMP
         WHERE TEMP.distribution_id = PRD.distribution_id
         AND TEMP.distribution_type = g_dist_type_REQUISITION
      ), /* Updating these cols also for bug#13930578 */
    PRD.last_update_date = sysdate,
   PRD.last_updated_by = fnd_global.user_id,
   PRD.last_update_login = fnd_global.login_id
      WHERE PRD.distribution_id IN
      (
         SELECT MAIN_REQ.distribution_id
         FROM PO_ENCUMBRANCE_GT MAIN_REQ
         WHERE MAIN_REQ.distribution_type = g_dist_type_REQUISITION
         AND MAIN_REQ.origin_sequence_num is NULL
         AND MAIN_REQ.gl_status_code = 'A'
      );

      l_progress := '032';
      IF g_debug_stmt THEN
         l_debug_count := SQL%ROWCOUNT;
         PO_DEBUG.debug_stmt(l_log_head,l_progress,
                             'Updated Req Split dists: ' || l_debug_count);
      END IF;
   END IF;  -- if action is req split

ELSE -- p_doctype is Not A Req

--SQL What: Update the encumbered_flag and encumbered_amount on PA/PO/Rel
--          distribution, if the PA/PO/Rel was the main document.
--SQL Where: Only updates those distributions where the distribution
--           row was sent to and successful in the GL packet
--SQL Why:  If the distribution transaction succeeded, the distribution table
--          fields must be updated to reflect the effect of the transaction

  -- <13503748: Edit without Unreserve ER:>
  -- Null out the amount_changed_flag for the successful encumbrance
  -- transactions


   UPDATE PO_DISTRIBUTIONS_ALL POD
   SET
   (
      POD.encumbered_flag,
      POD.encumbered_amount,
      POD.amount_changed_flag
   )
   =
   (
      SELECT
         --encumbered flag:
         DECODE( l_flip_enc_flag
               , 'N', POD.encumbered_flag   -- don't flip flag
               , l_main_doc_enc_flag_success),

         --encumbered amt:
         nvl(POD.encumbered_amount, 0) +
            SUM (decode(TEMP.update_encumbered_amount_flag,
                        'Y',TEMP.encumbered_amount_change,
                         0)
                ),
         NULL -- <13503748>
       FROM PO_ENCUMBRANCE_GT TEMP
       WHERE TEMP.distribution_id = POD.po_distribution_id
       AND TEMP.distribution_type <> g_dist_type_REQUISITION
       GROUP BY TEMP.distribution_id
   ), /* Updating these cols also for bug#13930578 */
    POD.last_update_date = sysdate,
   POD.last_updated_by = fnd_global.user_id,
   POD.last_update_login = fnd_global.login_id
   WHERE POD.po_distribution_id in
   (
       SELECT MAIN_PURCH.distribution_id
       FROM   PO_ENCUMBRANCE_GT MAIN_PURCH
       WHERE  MAIN_PURCH.distribution_type <> g_dist_type_REQUISITION
                                              -- doc is PO/PA/Release
       AND    MAIN_PURCH.origin_sequence_num IS NULL  -- doc is main doc
       AND    MAIN_PURCH.gl_status_code = 'A'
       AND    MAIN_PURCH.send_to_gl_flag = 'Y'  --bug 3568512: use new column
   );

   l_progress := '040';
   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'Updated Main PO/Rel dists: ' || l_debug_count);
   END IF;

   l_progress := '045';

--Bug 15987200

 UPDATE PO_DISTRIBUTIONS_ALL POD
   SET
   (
      POD.encumbered_amount,
      POD.amount_reversed
   )
   =
   (
      SELECT
           nvl(POD.encumbered_amount, 0) + NVL (TEMP.amount_reversed,0),
         Nvl(TEMP.amount_reversed,0)
       FROM PO_ENCUMBRANCE_GT TEMP
       WHERE TEMP.distribution_id = POD.po_distribution_id
       AND TEMP.distribution_type <> g_dist_type_REQUISITION
   ),
    POD.last_update_date = sysdate,
   POD.last_updated_by = fnd_global.user_id,
   POD.last_update_login = fnd_global.login_id
   WHERE POD.po_distribution_id in
   (
       SELECT MAIN_PURCH.distribution_id
       FROM   PO_ENCUMBRANCE_GT MAIN_PURCH
       WHERE  MAIN_PURCH.distribution_type <> g_dist_type_REQUISITION
                                              -- doc is PO/PA/Release
       AND    MAIN_PURCH.origin_sequence_num IS NULL  -- doc is main doc
       AND    MAIN_PURCH.gl_status_code = 'A'
       AND    MAIN_PURCH.send_to_gl_flag = 'Y'  --bug 3568512: use new column
   );
   -- Since the main doc lived in PO tables, it could have backing documents
   -- Now update the encumbrance fields on the backing requisitions

   IF p_action NOT IN (g_action_FINAL_CLOSE,
                       g_action_UNDO_FINAL_CLOSE, --bug 3414955
                       g_action_ADJUST) THEN

      -- no backing Requisition updates for FC, Undo FC and Adjust

      --SQL What:  Update the encumbered_flag and encumbered_amount on the Req
      --           distribution, if the Req is a backing document.
      --SQL Where: Only updates those Requisition distributions where the
      --           distribution row was sent to and successful in the GL packet
      --SQL Why:   If the distribution transaction succeeded, the distribution
      --           table fields must be updated to reflect the effect of the
      --           transaction

      UPDATE PO_REQ_DISTRIBUTIONS_ALL PRD
      SET
      (
         PRD.encumbered_flag,
         PRD.encumbered_amount
      )
      =
      (
         SELECT
            --encumbered flag:
            MAX(DECODE( l_flip_enc_flag
                       , 'N', PRD.encumbered_flag  --don't flip flag
                       , l_backing_req_enc_flag_success)),

            --encumbered amt:
            nvl(PRD.encumbered_amount, 0) +
                SUM(decode(TEMP.update_encumbered_amount_flag
	                  , 'Y',TEMP.encumbered_amount_change
                          , 0))
             FROM PO_ENCUMBRANCE_GT TEMP
             WHERE TEMP.distribution_id = PRD.distribution_id
             AND TEMP.distribution_type = g_dist_type_REQUISITION
             GROUP BY TEMP.distribution_id
             --<Complex Work R12>: added MAX, SUM and GROUP BY operators
      ), /* Updating these cols also for bug#13930578 */
    PRD.last_update_date = sysdate,
   PRD.last_updated_by = fnd_global.user_id,
   PRD.last_update_login = fnd_global.login_id
      WHERE PRD.distribution_id in
      (
          SELECT BACKING_REQ.distribution_id
          FROM PO_ENCUMBRANCE_GT BACKING_REQ
          WHERE BACKING_REQ.distribution_type = g_dist_type_REQUISITION
          AND BACKING_REQ.origin_sequence_num IS NOT NULL
          AND BACKING_REQ.gl_status_code = 'A'
          AND BACKING_REQ.send_to_gl_flag = 'Y'  --bug 3568512: use new column
      );

      l_progress := '050';
      IF g_debug_stmt THEN
         l_debug_count := SQL%ROWCOUNT;
         PO_DEBUG.debug_stmt(l_log_head,l_progress,
                             'Updated Backing Req dists: ' || l_debug_count);
      END IF;

   END IF; -- backing Reqs

   -- Since the main doc lived in PO tables, it could have backing documents
   -- Now update the encumbrance fields on the backing PPO/PA
   -- For FC, Undo FC the backing docs are not updated

   IF p_action NOT IN (g_action_FINAL_CLOSE,
                       g_action_UNDO_FINAL_CLOSE) THEN   --bug 3414955

      --SQL What:  Update the encumbered_amount and unencumbered_amount on
      --           backing PAs and PPOs.
      --           Note: encumbered_flag is not updated on backing PA/PPO.
      --           The flag on these docs is only affected if they are the
      --           main doc in an action.
      --SQL Where: Only updates those backing PA/PPO distributions where the
      --           distribution row was sent to and successful in the GL packet
      --SQL Why:   If the distribution transaction succeeded, the distribution
      --           table fields must be updated to reflect the effect of the
      --           transaction

      UPDATE PO_DISTRIBUTIONS_ALL POD
      SET
      (
         POD.encumbered_amount,
         POD.unencumbered_amount
      )
      =
      (
        SELECT
            nvl(POD.encumbered_amount, 0) +
                SUM(decode(CURRENT_DOC.update_encumbered_amount_flag,
                           'Y',CURRENT_DOC.encumbered_amount_change,
                            0)
                ),
            nvl(POD.unencumbered_amount, 0) -
                SUM(CURRENT_DOC.encumbered_amount_change)
        FROM   PO_ENCUMBRANCE_GT CURRENT_DOC
        WHERE CURRENT_DOC.distribution_id = POD.po_distribution_id
        AND CURRENT_DOC.distribution_type IN
                    (g_dist_type_AGREEMENT, g_dist_type_PLANNED)
        GROUP BY CURRENT_DOC.distribution_id
      ), /* Updating these cols also for bug#13930578 */
    POD.last_update_date = sysdate,
   POD.last_updated_by = fnd_global.user_id,
   POD.last_update_login = fnd_global.login_id
      WHERE POD.po_distribution_id in
      (
          SELECT BACKING_PURCH.distribution_id
          FROM PO_ENCUMBRANCE_GT BACKING_PURCH
          WHERE BACKING_PURCH.distribution_type IN
                        (g_dist_type_AGREEMENT, g_dist_type_PLANNED) -- PA/PPO
          AND BACKING_PURCH.origin_sequence_num IS NOT NULL -- backing doc
          AND (BACKING_PURCH.gl_status_code = 'A'
               OR (BACKING_PURCH.gl_status_code IS NULL
                   AND BACKING_PURCH.prevent_encumbrance_flag = 'N')
              --bug 3568512: do not filter on send_to_gl_flag = 'Y' because
              --even if backing BPA/GA was not sent to GL, its
              --unencumbered_amount needs to be updated.  for these rows,
              --we do not update encumbered_amount unless the row was sent
              --to GL; the setting of update_enc_amt_flag checks this
              )
      );

      l_progress := '060';
      IF g_debug_stmt THEN
         l_debug_count := SQL%ROWCOUNT;
         PO_DEBUG.debug_stmt(l_log_head,l_progress,
                             'Updated Backing PA/PPO dists: ' || l_debug_count);
      END IF;

      l_progress := '065';

      -- Update encumbered and unencumbered qty on backing PPOs
      -- Note: Adjust is not supported for PPO/Scheduled Release

      IF (p_doc_subtype = g_doc_subtype_SCHEDULED AND
          p_action <> g_action_ADJUST) THEN

         --SQL What:  Update the unencumbered_quantity on the backing PPO.
         --           Note: this field is only maintained for PPOs, no
         --           other backing docs
         --SQL Where: Only updates those backing PPO distributions where the
         --           distribution row was sent to and successful in the GL
         --           packet
         --SQL Why:   If the distribution transaction succeeded, the
         --           distribution table fields must be updated to reflect
         --           the effect of the transaction

         -- note: the qty_open was calculated for SR, but also copied onto the
         --       PPO dist

         -- Bug 3292870: Modified the query to make it compatible with 8i DB
         -- Changes: Moved all the GREATEST/NVL/DECODE logic to be inside
         --          the select statement.

         UPDATE PO_DISTRIBUTIONS_ALL POD
         SET
         POD.unencumbered_quantity =
         (SELECT
           GREATEST
           (   0,
               nvl(POD.unencumbered_quantity, 0)
               +
               (DECODE( p_action
                       -- if Reserving an SR, add to unenc qty
                     , g_action_RESERVE, 1
                       -- if cancelling credit memo, add to unenc qty
                     , g_action_CR_MEMO_CANCEL, 1
                       -- all other actions on SR reduce PPO unenc qty
                     , -1
                     )
               *
               SUM (PPO_DISTS.qty_open))
            )
          FROM   PO_ENCUMBRANCE_GT PPO_DISTS
          WHERE  PPO_DISTS.distribution_id = POD.po_distribution_id
          AND    PPO_DISTS.distribution_type = g_dist_type_PLANNED
          GROUP BY PPO_DISTS.distribution_id
         )
         WHERE POD.po_distribution_id IN
         (
             SELECT MAIN_SR.source_distribution_id -- get backing PPO's id
             FROM   PO_ENCUMBRANCE_GT MAIN_SR
             WHERE  MAIN_SR.distribution_type = g_dist_type_SCHEDULED
             AND    MAIN_SR.origin_sequence_num IS NULL
                                     -- the main doc is a Scheduled Release
             AND    MAIN_SR.gl_status_code = 'A'
             AND    MAIN_SR.send_to_gl_flag = 'Y'  --bug 3568512: use new column
         );

         l_progress := '070';

         IF g_debug_stmt THEN
            l_debug_count := SQL%ROWCOUNT;
            PO_DEBUG.debug_stmt(l_log_head,l_progress,
                                'Updated Backing PPO dists: ' || l_debug_count);
         END IF;

      END IF;  -- if main doc is a Scheduled Release

   END IF;  -- backing PPO/PA and if action is not Final Close

END IF;   -- if/else for p_doc_type of Req or not


IF (p_action = g_action_RESERVE) AND
   p_doc_type IN (g_doc_type_PO, g_doc_type_RELEASE)
   AND (p_doc_subtype <> g_doc_subtype_SCHEDULED)           -- Bug 5035240
THEN

-- In addition to the encumbered flag/amts/quantity, there are 2 special
-- cases in which we need to update the prevent_encumbrance_flag of a
-- backing Requisition of an Execution Document (PO/Release) as part of
-- the post-processing

   -- Case 1: Double backing encumbrance
   --         Both the backing Req and backing PA were encumbered.  After
   --         Reserve of the Execution Document, we set the prevent flag on
   --         the Req to Y to ensure that further backing transactions only
   --         look at the PA
   -- Case 2: No backing encumbrance
   --         Neither the backing Req and backing PA were encumbered.  After
   --         Reserve of the Execution Document, we set the prevent flag on
   --         the Req to N to ensure that further backing transactions actually
   --         look at the Req

   --SQL What:  Flip the prevent encumbrance flag on the backing Requisition
   --           for the 2 special cases described above.  This SQL will also
   --           update non-special case Reqs, but in this case we should be
   --           setting the flag to N, which is the value it should already
   --           have had.
   --SQL Where: Affects Backing Req distributions of Std POs and Blanket
   --           Releases if the main doc distribution was sent to and
   --           successful in GL.
   --           This should also be done for the rare case of PPOs
   --           whose backing Req is source to an encumbered BPA/GA.
   --SQL Why:   For the special cases, we want to reset the Requisition prevent
   --           flag so that going forward, we no longer have the either
   --           Double or No backing encumbrance case.
   --Bug 5348161: Added MAX aggregator to the logic for updating the Req dist's
   --prevent_enc_flag.  For CWPOs, multiple PO dists point to the same backing Req
   --dist, so the EXEC_D.req_distribution_id = PRD.distribution_id returns multiple
   --rows so an aggregator is needed to avoid multiple-row-subquery error.

   /*  Bug : 13984592 : Modifying the update statement to update the
     prevent encumbrance flag of backing req to 'Y' only when backing GBPA is encumbered.
     The case 2: where there is no backing GBPA , the backing Requistion prevent encumbrance
     flag is not updated to 'Y' or 'N'. This is required so that if the backing req flag is
     explictly updated to 'Y'  the code will not flip to 'N'.

   UPDATE PO_REQ_DISTRIBUTIONS_ALL PRD
   SET PRD.prevent_encumbrance_flag
   =
   (
      SELECT
         DECODE(
                MAX(
                     DECODE(  EXEC_D.agreement_dist_id -- only present if main doc is encumbered
                            ,  NULL, 1 -- no backing PA or backing PA not encumberable
                            ,  2       -- this PO dist has backing encumbered PA
                     )
                )
                ,  1, 'N'  --if max is 1, then no backing Enc PA, so prevent_enc_flag <= N
                , 'Y'  -- if max is 2, then there is backing Enc PA, so prevent_enc_flag <= Y
         )
      FROM  PO_ENCUMBRANCE_GT EXEC_D
      WHERE EXEC_D.req_distribution_id = PRD.distribution_id
   )
   WHERE PRD.distribution_id IN
   (
       SELECT EXEC_DOC.req_distribution_id
       FROM   PO_ENCUMBRANCE_GT EXEC_DOC
       WHERE  EXEC_DOC.distribution_type
            IN (g_dist_type_STANDARD, g_dist_type_BLANKET, g_dist_type_PLANNED)
       AND EXEC_DOC.req_distribution_id IS NOT NULL
       AND EXEC_DOC.gl_status_code = 'A'
       AND EXEC_DOC.send_to_gl_flag = 'Y'  --bug 3568512
   ); */

     update PO_REQ_DISTRIBUTIONS_ALL PRD
   set PRD.prevent_encumbrance_flag = 'Y'
   where PRD.distribution_id IN
   (
       SELECT EXEC_DOC.req_distribution_id
       FROM   PO_ENCUMBRANCE_GT EXEC_DOC
       WHERE  EXEC_DOC.distribution_type
            IN (g_dist_type_STANDARD, g_dist_type_BLANKET, g_dist_type_PLANNED)
       AND EXEC_DOC.req_distribution_id IS NOT NULL
       AND EXEC_DOC.gl_status_code = 'A'
       AND EXEC_DOC.send_to_gl_flag = 'Y'  --bug 3568512
       AND EXEC_DOC.agreement_dist_id  IS NOT NULL
   ) ;
  ---END Bug 13984592
   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'Flipped prevent enc flag: ' || l_debug_count);
   END IF;

END IF;  -- RESERVE action and p_doc_type is PO or Release


-- Now the updation of po_distributions/po_req_distributions for all the
-- approved GL_BC_PACKETS records is done. Just rollup the encumbered_flag
-- to the PO line locations and Requisition lines

If l_flip_enc_flag = 'Y' Then

   l_progress := '079';

   -- Bug 3537764: Passed p_action to rollup_encumbrance_changes
   rollup_encumbrance_changes(p_action => p_action);

End If;

l_progress := '080';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;


EXCEPTION
WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END update_successful_rows;

-------------------------------------------------------------------------------
--Start of Comments
--Name: update_failed_rows
--Pre-reqs:
--  PO_ENCUMBRANCE_GT has all necessary information populated after
--  making a call to the GL Funds Checker
--Modifies:
--  PO_REQ_DISTRIBUTIONS, PO_DISTRIBUTIONS
--Locks:
--  None.
--Function:
--  This procedure updates the failed_funds_lookup_code on Req/PO distributions
--  involved in a failed or partially failed encumbrance transaction.  This
--  procedure is only called for actual encumbrance actions (Pending mode),
--  but NOT Funds Check (Checking mode)
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the main doc being a REQUISITION, AGREEMENT,
--  PURCHASE ORDER, or RELEASE which is used to identify the tables to look at
--  (PO vs. Req) and the join conditions
--p_action
--  Encumbrance action requested on the main document:
--  RESERVE/UNRESERVE/CANCEL/FINAL CLOSE/RETURN/REJECT/ADJUST
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE update_failed_rows(
  p_doc_type                       IN             VARCHAR2
, p_action                         IN             VARCHAR2
) IS

l_api_name  CONSTANT varchar2(40) := 'UPDATE_FAILED_ROWS';
l_log_head  CONSTANT varchar2(100) := g_log_head || l_api_name;
l_progress VARCHAR2(3);
l_debug_count NUMBER;

BEGIN

l_progress := '000';

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head, l_progress, 'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head, l_progress, 'p_action', p_action);
END IF;

l_progress := '010';

IF p_doc_type = g_doc_type_REQUISITION THEN

--SQL What: Update the failed_funds_lookup_code of relevant Requisition
--          distributions from this transaction
--SQL Where: Only updates the distributions if the distribution transaction
--           failed in GL

   UPDATE PO_REQ_DISTRIBUTIONS_ALL PRD
   SET PRD.failed_funds_lookup_code
   =
   (
       SELECT TEMP.gl_result_code
       FROM PO_ENCUMBRANCE_GT TEMP
       WHERE TEMP.distribution_id = PRD.distribution_id
       AND TEMP.distribution_type = g_dist_type_REQUISITION
       AND rownum = 1
          -- handles case with 2 same dist_ids in same packet (Adjust)
   )
   WHERE PRD.distribution_id in
   (
       SELECT REQ_DISTS.distribution_id
       FROM PO_ENCUMBRANCE_GT REQ_DISTS
       WHERE REQ_DISTS.distribution_type = g_dist_type_REQUISITION
       AND REQ_DISTS.origin_sequence_num IS NULL
       AND REQ_DISTS.gl_status_code = 'R'
       AND REQ_DISTS.prevent_encumbrance_flag = 'N'
   );

   l_progress := '020';
   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'Updated Req dists failed funds code: ' || l_debug_count);
   END IF;

ELSE  -- p_doc_type is Not a Req

--SQL What:  Update the failed_funds_lookup_code of relevant PO/PA/Release
--           distributions from this transaction
--SQL Where: Only updates the distributions if the distribution transaction
--           failed in GL

   UPDATE PO_DISTRIBUTIONS_ALL POD
   SET POD.failed_funds_lookup_code
   =
   (
       SELECT TEMP.gl_result_code
       FROM PO_ENCUMBRANCE_GT TEMP
       WHERE TEMP.distribution_id = POD.po_distribution_id
       AND TEMP.distribution_type <> g_dist_type_REQUISITION
       AND rownum = 1
           -- handles case with 2 same dist_ids in same packet (Adjust)
   )
   WHERE POD.po_distribution_id in
   (
       SELECT PO_DISTS.distribution_id
       FROM PO_ENCUMBRANCE_GT PO_DISTS
       WHERE PO_DISTS.distribution_type <> g_dist_type_REQUISITION
       AND PO_DISTS.origin_sequence_num IS NULL
       AND PO_DISTS.gl_status_code = 'R'
       AND PO_DISTS.prevent_encumbrance_flag = 'N'
   );

   l_progress := '030';
   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'Updated PO/Rel dists failed funds code: ' || l_debug_count);
   END IF;

END IF;  -- p_doc_type check

l_progress := '040';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END update_failed_rows;

-------------------------------------------------------------------------------
--Start of Comments
--Name: rollup_encumbrance_changes
--Pre-reqs:
--  An encumbrance action (excluding Funds Check) was successful or partially
--  successful
--Modifies:
--  Updates Req lines and/or PO Shipments tables based on result of GL transaction
--Locks:
--  None.
--Function:
--  This procedure rolls up changes to the encumbered_flag from the Req/PO
--  distributions to the Req line or PO shipment level.
--Parameters:
--IN:
-- p_action:   -- Bug 3537764
--  Encumbrance action requested on the main document:
--  Valid values: g_action_<> pkg vars
--OUT:
--  N/A
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE rollup_encumbrance_changes (p_action  IN  VARCHAR2)
IS

l_api_name  CONSTANT varchar2(40) := 'ROLLUP_ENCUMBRANCE_CHANGES';
l_log_head  CONSTANT varchar2(100) := g_log_head || l_api_name;
l_progress VARCHAR2(3);
l_debug_count NUMBER;

BEGIN

l_progress := '000';

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
END IF;

l_progress := '010';

--SQL What:  Update the encumbered_flag from the affected Requisition
--           distributions (main or backing) up to the Requisition line
--SQL Where: Only updates the distributions if the distribution transaction
--           succeeded in GL
--SQL Why:   The Req line's encumbered_flag needs to be in synch with the
--           update already done to the Req distribution's encumbered_flag

UPDATE PO_REQUISITION_LINES_ALL PRL
SET encumbered_flag
=
(
   -- Bug 3537764: Modified SET logic to handle the all distributions prevented case
    SELECT NVL(min(prd.encumbered_flag), 'N')
    FROM PO_REQ_DISTRIBUTIONS_ALL PRD
    WHERE PRD.requisition_line_id = PRL.requisition_line_id
    AND NVL(PRD.prevent_encumbrance_flag, 'N') = 'N'

), /* Updating these cols also for bug#13930578 */
    PRL.last_update_date = sysdate,
   PRL.last_updated_by = fnd_global.user_id,
   PRL.last_update_login = fnd_global.login_id
WHERE PRL.requisition_line_id IN
(
    SELECT TEMP.line_id
    FROM PO_ENCUMBRANCE_GT TEMP
    WHERE TEMP.gl_status_code = 'A'
    AND TEMP.distribution_type = g_dist_type_REQUISITION
    AND (
         (TEMP.send_to_gl_flag = 'Y')   --bug 3568512: use new column
           or
         ((p_action = g_action_REQ_SPLIT) and (TEMP.modified_by_agent_flag = 'Y'))
        )
    -- Bug 3537764: do not filter on prevent_encumbrance flag for req split action
    -- This is so we can set the encumbered flag to 'N' for the old pre-split line
    -- That old line has prevent_enc_flag = 'Y', and was being missed before this fix.
    -- Also, this means that the rollup query in the SET clause can no longer assume
    -- that it doesn't need to worry about the all distributions prevented case.
);

l_progress := '020';
IF g_debug_stmt THEN
   l_debug_count := SQL%ROWCOUNT;
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
                       'Updated Req lines: ' || l_debug_count);
END IF;

--SQL What:  Update the encumbered_flag from the affected PO/Release
--           distributions up to the PO/Release shipment
--SQL Where: Only updates the distributions if the distribution transaction
--           succeeded in GL
--SQL Why:   The shipment's encumbered_flag needs to be in synch with the
--           update already done to the distribution's encumbered_flag

UPDATE PO_LINE_LOCATIONS_ALL POLL
SET encumbered_flag
=
(
   -- Bug 3537764: Modified SET logic to handle the all distributions prevented case
    SELECT NVL(min(pod.encumbered_flag), 'N')
    FROM PO_DISTRIBUTIONS_ALL POD
    WHERE POD.line_location_id = POLL.line_location_id
    AND NVL(POD.prevent_encumbrance_flag, 'N') = 'N'
), /* Updating these cols also for bug#13930578 */
    POLL.last_update_date = sysdate,
   POLL.last_updated_by = fnd_global.user_id,
   POLL.last_update_login = fnd_global.login_id
WHERE POLL.line_location_id IN
(
    SELECT TEMP.line_location_id
    FROM PO_ENCUMBRANCE_GT TEMP
    WHERE TEMP.gl_status_code = 'A'
    AND TEMP.distribution_type IN (g_dist_type_STANDARD, g_dist_type_PLANNED,
                                   g_dist_type_SCHEDULED, g_dist_type_BLANKET)
    AND TEMP.send_to_gl_flag = 'Y'  --bug 3568512: use new column
-- this makes sure that there is atleast one distribution that can be reserved
);

l_progress := '030';
IF g_debug_stmt THEN
   l_debug_count := SQL%ROWCOUNT;
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
                       'Updated PO shipments: ' || l_debug_count);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END rollup_encumbrance_changes;

-------------------------------------------------------------------------------
--Start of Comments
--Name: create_enc_action_history
--Pre-reqs:
--  Encumbrance action completed successfully.
--Modifies:
--  PO_ACTION_HISTORY
--Locks:
--  None.
--Function:
--  This procedure calls the Action History routine, which
--  inserts/updates the po_action_history with the action
--  passed to this procedure.
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions.
--  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_id_tbl
--  The header ids of the documents on which the encumbrance action is
--  performed.
--p_employee_id
--  ID of the user taking the encumbrance action.
--p_action
--  The encumbrance action being performed.
--  Use the g_action_<> variables.
--p_cbc_flag
--  Indicates whether or not to this action is one of the special
--  CBC Year-End Reserve/Unreserve actions, which have different
--  action history entries.
--    g_parameter_YES - CBC action
--    g_parameter_NO  - regular action
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE create_enc_action_history(
   p_doc_type                       IN             VARCHAR2
,  p_doc_id_tbl                     IN             po_tbl_number
,  p_employee_id                    IN             NUMBER
,  p_action                         IN             VARCHAR2
,  p_cbc_flag                       IN             VARCHAR2
)
IS

l_api_name             CONSTANT VARCHAR2(30) := 'CREATE_ENC_ACTION_HISTORY';
l_log_head             CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress             VARCHAR2(3) := '000';

l_record_action         PO_ACTION_HISTORY.action_code%TYPE;

l_gt_key                   NUMBER;
l_debug_rowid_tbl          po_tbl_varchar2000;
l_debug_column_tbl         po_tbl_varchar30;

l_orig_doc_id_tbl          po_tbl_number;
l_orig_rev_num_tbl         po_tbl_number;
l_orig_auth_status_tbl     po_tbl_varchar30;
l_orig_doc_subtype_tbl     po_tbl_varchar30;
l_orig_null_flag_tbl       po_tbl_varchar1;

l_update_doc_type_tbl      po_tbl_varchar30;
l_update_doc_id_tbl        po_tbl_number;

l_insert_doc_type_tbl      po_tbl_varchar30;
l_insert_doc_id_tbl        po_tbl_number;
l_insert_doc_subtype_tbl   po_tbl_varchar30;
l_insert_action_code_tbl   po_tbl_varchar30;
l_insert_rev_num_tbl       po_tbl_number;

l_doc_id                   NUMBER;
l_doc_subtype              PO_HEADERS_ALL.type_lookup_code%TYPE;
l_rev_num                  NUMBER;

l_index                    NUMBER;
l_update_count             NUMBER;
l_insert_count             NUMBER;
--add below variable for bug#18709903
l_interface_source_code    VARCHAR2 	(25);

l_employee_id              NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_id_tbl',p_doc_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_employee_id',p_employee_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_cbc_flag',p_cbc_flag);
END IF;

l_progress := '010';

-- 19018041 give value to l_employee_id if p_employee_id is null
l_employee_id := p_employee_id;
IF (l_employee_id is null) THEN
   l_employee_id := FND_GLOBAL.employee_id;
END IF;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_employee_id',l_employee_id);
END IF;

l_progress := '015';

-- CBC Reserve/Unreserve record a different Action History code
IF (p_cbc_flag = g_parameter_YES) THEN
   l_progress := '020';
   IF (p_action = g_action_RESERVE) THEN
      l_record_action := PO_CONSTANTS_SV.IGC_YEAR_END_RESERVE;
   ELSIF (p_action = g_action_UNRESERVE) THEN
      l_record_action := PO_CONSTANTS_SV.IGC_YEAR_END_UNRESERVE;
   END IF;
ELSIF (p_action = g_action_REQ_SPLIT) THEN
   l_progress := '023';
   l_record_action := PO_CONSTANTS_SV.ADJUST;
ELSE
   l_progress := '026';
   l_record_action := p_action;
END IF;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_record_action',l_record_action);
END IF;

l_progress := '050';

--
-- Load the data into the temp table for bulk processing.
--
-- PO_SESSION_GT mapping
--
-- num1     document header_id
-- num2     revision_num
-- char1    authorization_status
-- char2    document subtype
-- char3    NULL action exists flag
--

l_gt_key := PO_CORE_S.get_session_gt_nextval();

l_progress := '060';

FORALL i IN 1 .. p_doc_id_tbl.COUNT
INSERT INTO PO_SESSION_GT
(  key
,  num1
)
VALUES
(  l_gt_key
,  p_doc_id_tbl(i)
);

l_progress := '100';

-- Fill in the revision number, authorization status, doc subtype

IF (p_doc_type IN (g_doc_type_PO, g_doc_type_PA)) THEN

   l_progress := '110';

   UPDATE PO_SESSION_GT SCRATCH
   SET
   (  num2
   ,  char1
   ,  char2
   )
   =
   (  SELECT
         POH.revision_num
      ,  POH.authorization_status
      ,  POH.type_lookup_code
      FROM
         PO_HEADERS_ALL POH
      WHERE POH.po_header_id = SCRATCH.num1
   )
   WHERE SCRATCH.key = l_gt_key
   ;

   l_progress := '115';

ELSIF (p_doc_type = g_doc_type_RELEASE) THEN

   l_progress := '120';

   UPDATE PO_SESSION_GT SCRATCH
   SET
   (  num2
   ,  char1
   ,  char2
   )
   =
   (  SELECT
         POR.revision_num
      ,  POR.authorization_status
      ,  POR.release_type
      FROM
         PO_RELEASES_ALL POR
      WHERE POR.po_release_id = SCRATCH.num1
   )
   WHERE SCRATCH.key = l_gt_key
   ;

   l_progress := '125';

ELSE -- requisitions

   l_progress := '130';

   -- no revision_num for Reqs.

   UPDATE PO_SESSION_GT SCRATCH
   SET
   (  char1
   ,  char2
   )
   =
   (  SELECT
         PRH.authorization_status
      ,  PRH.type_lookup_code
      FROM
         PO_REQUISITION_HEADERS_ALL PRH
      WHERE PRH.requisition_header_id = SCRATCH.num1
   )
   WHERE SCRATCH.key = l_gt_key
   ;

   l_progress := '135';

END IF;

-- Determine if a NULL action already exists for the doc.

l_progress := '150';

UPDATE PO_SESSION_GT SCRATCH
SET char3 =
   (  SELECT 'Y'
      FROM PO_ACTION_HISTORY POAH
      WHERE POAH.object_type_code = p_doc_type
      AND POAH.object_id = SCRATCH.num1
      AND POAH.action_code IS NULL
      AND POAH.employee_id = l_employee_id --test
   )
WHERE SCRATCH.key = l_gt_key
;

l_progress := '160';

IF g_debug_stmt THEN
   PO_DEBUG.debug_session_gt(l_log_head,l_progress,l_gt_key
   ,  po_tbl_varchar30('num1','num2','char1','char2','char3')
   );
END IF;

l_progress := '200';

--
-- Based on whether or not there is a NULL action existing for the doc,
-- we either need to update the NULL action entry or create a new entry.
-- Also, if the doc is In Process or Pre-Approved, we would need to make
-- a new NULL action after updating the old one.
--

-- Retrieve the data to decide what updates/inserts we need to do.

SELECT
   SCRATCH.num1
,  SCRATCH.num2
,  SCRATCH.char1
,  SCRATCH.char2
,  SCRATCH.char3
BULK COLLECT INTO
   l_orig_doc_id_tbl
,  l_orig_rev_num_tbl
,  l_orig_auth_status_tbl
,  l_orig_doc_subtype_tbl
,  l_orig_null_flag_tbl
FROM
   PO_SESSION_GT SCRATCH
WHERE SCRATCH.key = l_gt_key
;

l_progress := '210';

-- Initialize the update / insert tables.

l_update_doc_id_tbl        := po_tbl_number();

l_insert_doc_id_tbl        := po_tbl_number();
l_insert_doc_subtype_tbl   := po_tbl_varchar30();
l_insert_action_code_tbl   := po_tbl_varchar30();
l_insert_rev_num_tbl       := po_tbl_number();

l_progress := '220';

-- Determine which updates and inserts need to occur.

FOR i IN 1 .. l_orig_doc_id_tbl.COUNT LOOP

   -- cache a few vars
   l_doc_id       := l_orig_doc_id_tbl(i);
   l_doc_subtype  := l_orig_doc_subtype_tbl(i);
   l_rev_num      := l_orig_rev_num_tbl(i);

   IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_id',l_doc_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_subtype',l_doc_subtype);
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_rev_num',l_rev_num);
   END IF;

   -- Is there a NULL action?

   IF (l_orig_null_flag_tbl(i) = 'Y') THEN

      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress, 'A NULL Action Histroy Exists'  );
      END IF;
      -- There is a NULL action for this doc, so update it.

      l_update_doc_id_tbl.EXTEND;
      l_update_doc_id_tbl(l_update_doc_id_tbl.LAST) := l_doc_id;

      -- For In Process / Pre-Approved docs, we need to
      -- make a new NULL action since we used the old one.

      --Bug18709903 get interface_source_code to check whether the req from import or not
      BEGIN
        SELECT interface_source_code
        INTO l_interface_source_code
        FROM po_requisition_headers_all
        WHERE requisition_header_id=l_doc_id;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
       --To handle PO/Release
       l_interface_source_code := NULL;
     END;

      IF (l_orig_auth_status_tbl(i) IN
            (PO_CONSTANTS_SV.IN_PROCESS, PO_CONSTANTS_SV.PRE_APPROVED)
      -- Bug7387775(adding following condition)
      -- Added the Following Condition to Avoid Creation a NULL Action Histroy
      -- for requisition. As when Requisition are imported as APPROVED then
      -- no WF is initated and this NULL action histroy wont get updated to
      -- APPROVE , which will create problem latter.

     --Bug18709903 replace below condition to avoid insert null record for
     --imported REQ not all REQ
     --  and (p_doc_type <> g_doc_type_REQUISITION)
     AND l_interface_source_code is null
      ) THEN

         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Creating Blank Action Histroy' );
         END IF;
         l_insert_doc_id_tbl.EXTEND;
         l_insert_doc_subtype_tbl.EXTEND;
         l_insert_action_code_tbl.EXTEND;
         l_insert_rev_num_tbl.EXTEND;

         l_index := l_insert_doc_id_tbl.LAST;

         l_insert_doc_id_tbl(l_index)        := l_doc_id;
         l_insert_doc_subtype_tbl(l_index)   := l_doc_subtype;
         l_insert_action_code_tbl(l_index)   := NULL;
         l_insert_rev_num_tbl(l_index)       := l_rev_num;

      END IF;

   ELSE -- no NULL action

      -- bug 3568559
      -- If there is not an existing NULL action,
      -- just record (insert) the action being taken.
      -- There is not need to enter as SUBMIT (...for Approval) action,
      -- especially for UNRESERVE, ADJUST.

      l_insert_doc_id_tbl.EXTEND;
      l_insert_doc_subtype_tbl.EXTEND;
      l_insert_action_code_tbl.EXTEND;
      l_insert_rev_num_tbl.EXTEND;

      l_index := l_insert_doc_id_tbl.LAST;

      l_insert_doc_id_tbl(l_index)        := l_doc_id;
      l_insert_doc_subtype_tbl(l_index)   := l_doc_subtype;
      l_insert_action_code_tbl(l_index)   := l_record_action;
      l_insert_rev_num_tbl(l_index)       := l_rev_num;

   END IF;

END LOOP;

l_progress := '300';

l_update_count := l_update_doc_id_tbl.COUNT;
l_insert_count := l_insert_doc_id_tbl.COUNT;

l_progress := '310';

IF (l_update_count > 0) THEN

   l_progress := '320';

   --
   -- Update the NULL action records to the action being taken.
   --

   l_update_doc_type_tbl := po_tbl_varchar30(p_doc_type);
   l_update_doc_type_tbl.EXTEND(l_update_count-1, 1);

   l_progress := '330';

   PO_ACTION_HISTORY_SV.update_action_history(
      p_doc_id_tbl   => l_update_doc_id_tbl
   ,  p_doc_type_tbl => l_update_doc_type_tbl
   ,  p_action_code  => l_record_action
   ,  p_employee_id  => l_employee_id
   );

   l_progress := '340';

END IF;

l_progress := '400';

IF (l_insert_count > 0) THEN

   l_progress := '410';

   --
   -- Insert action records.
   --

   l_insert_doc_type_tbl := po_tbl_varchar30(p_doc_type);
   l_insert_doc_type_tbl.EXTEND(l_insert_count-1, 1);

   l_progress := '420';

   PO_ACTION_HISTORY_SV.insert_action_history(
      p_doc_id_tbl            => l_insert_doc_id_tbl
   ,  p_doc_type_tbl          => l_insert_doc_type_tbl
   ,  p_doc_subtype_tbl       => l_insert_doc_subtype_tbl
   ,  p_doc_revision_num_tbl  => l_insert_rev_num_tbl
   ,  p_action_code_tbl       => l_insert_action_code_tbl
   ,  p_employee_id           => l_employee_id
   );

   l_progress := '430';

END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- Log a debug message and set the message on the FND dictionary stack.
   po_message_s.sql_error(g_pkg_name,l_api_name,l_progress,SQLCODE,SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END create_enc_action_history;




-------------------------------------------------------------------------------
--Start of Comments
--Name: set_status_requires_reapproval
--Pre-reqs:
--  Unreserve action completed successfully.
--Modifies:
--  PO_HEADERS_ALL, PO_RELEASES_ALL, PO_LINE_LOCATIONS_ALL
--Locks:
--  None.
--Function:
--  This procedure updates the 'Approved' Shipments to 'REQUIRES REAPPROVAL'
--  if atleast one of the distribution of that shipment is unreserved and
--  rolls up the same to Headers.
--Parameters:
--IN:
--p_document_type
--  Differentiates between the main doc being a REQUISITION, AGREEMENT,
--  PURCHASE ORDER, or RELEASE which is used to identify the tables to look at
--  (PO vs. Req) and the join conditions
--OUT:
--  N/A
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE set_status_requires_reapproval(
   p_document_type	IN	VARCHAR2
,  p_action		IN	VARCHAR2
,  p_cbc_flag           IN      VARCHAR2
) IS

l_api_name  CONSTANT varchar2(40) := 'SET_STATUS_REQUIRES_REAPPROVAL';
l_log_head  CONSTANT varchar2(100) := g_log_head || l_api_name;
l_progress VARCHAR2(3);

l_debug_count   NUMBER;
l_affected_gl_status_code  VARCHAR2(1);

BEGIN

l_progress := '000';

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type',p_document_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_cbc_flag',p_cbc_flag);
END IF;

-- Only change doc status to Requires Reapproval when
-- 1.  Normal Unreserve action succeeds
-- 2.  CBC Year End Reserve fails
l_progress := '010';
IF (p_action = g_action_UNRESERVE and p_cbc_flag = 'N') THEN

   l_affected_gl_status_code := 'A';

ELSIF (p_action = g_action_RESERVE and p_cbc_flag = 'Y') THEN

   l_affected_gl_status_code := 'R';

ELSE
  --for all other actions, do not change the document status
  IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(l_log_head,l_progress,'No status change; early return');
  END IF;

  RETURN;
END IF;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,
                      'l_affected_gl_status_code',l_affected_gl_status_code);
END IF;


IF (p_document_type = g_doc_type_PO) THEN

   -- For an approved shipment, if atleast one distribution's
   -- encumbered_flag is 'N', then the Approved flag of the shipment is set
   -- to 'R'

   --SQL What:  Update the PO shipment approved flag to 'R' if one of its
   --           distributions has been unreserved.
   --SQL Where: Only updates the shipment if the unreserve transaction
   --           succeeded in GL and shipment is approved.
   --SQL Why:   The shipment should be unapproved if one of its distribution
   --           is unreserved.

   l_progress := '020';

   UPDATE PO_LINE_LOCATIONS_ALL POLL
   SET    POLL.approved_flag = 'R',
   POLL.last_update_date = sysdate,
   POLL.last_updated_by = fnd_global.user_id,
   POLL.last_update_login = fnd_global.login_id
   WHERE  POLL.po_release_id is NULL
   AND    nvl(POLL.approved_flag,'N') = 'Y'
   AND    EXISTS
   (
          SELECT 'UNRESERVED DISTRIBUTION EXISTS'
          FROM PO_ENCUMBRANCE_GT TEMP
          WHERE TEMP.gl_status_code = l_affected_gl_status_code
          AND TEMP.send_to_gl_flag = 'Y'  --bug 3568512: use new column
          AND TEMP.line_location_id = POLL.line_location_id
          AND TEMP.distribution_type IN
                  (g_dist_type_STANDARD, g_dist_type_PLANNED)
   );

   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'PO Shipment flags updated : ' || l_debug_count);
   END IF;

   -- Now rollup the Approval flag from Shipments to Headers.

   --SQL What:  Update the PO authorization status to 'REQUIRES REAPPROVAL'
   --           if one of its distributions has been unreserved.
   --SQL Where: Only updates the PO if the unreserve transaction
   --           succeeded in GL and PO is approved.
   --SQL Why:   The PO should be unapproved if one of its distribution
   --           is unreserved.

   l_progress := '030';

   UPDATE PO_HEADERS_ALL POH
   SET POH.authorization_status = 'REQUIRES REAPPROVAL',
   POH.approved_flag = 'R',
   POH.last_update_date = sysdate,
   POH.last_updated_by = fnd_global.user_id,
   POH.last_update_login = fnd_global.login_id
   WHERE nvl(POH.approved_flag,'N') = 'Y' -- if approved
   AND EXISTS
   (
       SELECT 'UNRESERVED DISTRIBUTION EXISTS'
       FROM PO_ENCUMBRANCE_GT TEMP
       WHERE TEMP.gl_status_code = l_affected_gl_status_code
       AND TEMP.send_to_gl_flag = 'Y'  --bug 3568512: use new column
       AND TEMP.header_id = POH.po_header_id
       AND TEMP.distribution_type IN
               (g_dist_type_STANDARD, g_dist_type_PLANNED)
   );

   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'PO Headers updated : ' || l_debug_count);
   END IF;

ELSIF (p_document_type = g_doc_type_PA) THEN

   -- Entity_id will be the same as document_id for PA, as the action
   -- can be taken only from the Header level

   --SQL What:  Update the PO authorization status to 'REQUIRES REAPPROVAL'
   --           if one of its distributions has been unreserved.
   --SQL Where: Only updates the PO if the unreserve transaction
   --           succeeded in GL and PO is approved.
   --SQL Why:   The PO should be unapproved if one of its distribution
   --           is unreserved.

   l_progress := '040';

   UPDATE PO_HEADERS_ALL POH
   SET POH.authorization_status = 'REQUIRES REAPPROVAL',
   POH.approved_flag = 'R',
   POH.last_update_date = sysdate,
   POH.last_updated_by = fnd_global.user_id,
   POH.last_update_login = fnd_global.login_id
   WHERE nvl(POH.approved_flag,'N') = 'Y' -- if approved
   AND EXISTS
   (
       SELECT 'UNRESERVED SINGLE DISTRIBUTION EXISTS'
       FROM PO_ENCUMBRANCE_GT TEMP
       WHERE TEMP.gl_status_code = l_affected_gl_status_code
       AND TEMP.send_to_gl_flag = 'Y'  --bug 3568512: use new column
       AND TEMP.header_id = POH.po_header_id
       AND TEMP.distribution_type  = g_dist_type_AGREEMENT
   );

   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'PA Headers updated : ' || l_debug_count);
   END IF;

ELSIF (p_document_type = g_doc_type_RELEASE) THEN

   l_progress := '050';

   --SQL What:  Update the Release shipment approved flag to 'R' if one of its
   --           distributions has been unreserved.
   --SQL Where: Only updates the shipment if the unreserve transaction
   --           succeeded in GL and shipment is approved.
   --SQL Why:   The shipment should be unapproved if one of its distribution
   --           is unreserved.

   UPDATE PO_LINE_LOCATIONS_ALL POLL
   SET    POLL.approved_flag = 'R',
   POLL.last_update_date = sysdate,
   POLL.last_updated_by = fnd_global.user_id,
   POLL.last_update_login = fnd_global.login_id
   WHERE  POLL.po_release_id is NOT NULL
   AND    nvl(POLL.approved_flag,'N') = 'Y' -- if approved
   AND    EXISTS
   (
          SELECT 'UNRESERVED DISTRIBUTION EXISTS'
          FROM PO_ENCUMBRANCE_GT TEMP
          WHERE TEMP.gl_status_code = l_affected_gl_status_code
          AND TEMP.send_to_gl_flag = 'Y'  --bug 3568512: use new column
          AND TEMP.line_location_id = POLL.line_location_id
          AND TEMP.distribution_type IN
                  (g_dist_type_SCHEDULED, g_dist_type_BLANKET)
   );

   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'Release shipments updated : ' || l_debug_count);
   END IF;

   l_progress := '060';

   --SQL What:  Update the Release authorization status to 'REQUIRES REAPPROVAL'
   --           if one of its distributions has been unreserved.
   --SQL Where: Only updates the Release if the unreserve transaction
   --           succeeded in GL and PO is approved.
   --SQL Why:   The PO should be unapproved if one of its distribution
   --           is unreserved.

   UPDATE PO_RELEASES_ALL POR
   SET POR.authorization_status = 'REQUIRES REAPPROVAL',
   POR.approved_flag = 'R',
   POR.last_update_date = sysdate,
   POR.last_updated_by = fnd_global.user_id,
   POR.last_update_login = fnd_global.login_id
   WHERE nvl(POR.approved_flag,'N') = 'Y' -- if approved
   AND EXISTS
   (
       SELECT 'UNRESERVED DISTRIBUTION EXISTS'
       FROM PO_ENCUMBRANCE_GT TEMP
       WHERE TEMP.gl_status_code = l_affected_gl_status_code
       AND TEMP.send_to_gl_flag = 'Y'  --bug 3568512: use new column
       AND TEMP.po_release_id = POR.po_release_id
       AND TEMP.distribution_type IN
                  (g_dist_type_SCHEDULED, g_dist_type_BLANKET)
   );

   IF g_debug_stmt THEN
      l_debug_count := SQL%ROWCOUNT;
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                          'Release Headers updated : ' || l_debug_count);
   END IF;

ELSE -- This is the case of requisitions. For requisitions, once the document is
     -- approved, it is not possible to take unreserve action. If the unreserve
     -- action is taken on the Incomplete Requisition, then updating of
     -- authorization_status is not required

   NULL;

END IF;

l_progress := '070';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END set_status_requires_reapproval;



------------------------------------------------------------------------------
--Start of Comments
--Name: create_detailed_report
--Pre-reqs:
--  PO_ENCUMBRANCE_GT result fields have been populated
--Modifies:
--  PO_ENCUMBRANCE_GT
--  PO_ONLINE_REPORT_TEXT
--Locks:
--  None.
--Function:
--
--Parameters:
--IN:
--p_gl_return_code
--  The return code from the call to the GL funds checker
--p_user_id
--  ID of the current user
--OUT:
--x_online_report_id
--  The unique ID of the result information in the
--  PO_ONLINE_REPORT_TEXT table
--x_po_return_code
--  The return code for this transaction, based on the GL result
--  code and PO warning conditions
--x_po_return_msg
--  The message name (from FND_NEW_MESSAGES) that corresponds to the
--  x_po_return_code
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE create_detailed_report(
   p_gl_return_code		IN		VARCHAR2
,  p_user_id			IN		NUMBER
,  x_online_report_id		OUT NOCOPY	VARCHAR2
,  x_po_return_code		OUT NOCOPY	VARCHAR2
,  x_po_return_msg_name		OUT NOCOPY	VARCHAR2
)
IS

l_api_name		CONSTANT varchar2(30) := 'CREATE_DETAILED_REPORT';
l_log_head		CONSTANT varchar2(100) := g_log_head || l_api_name;
l_progress		varchar2(3) := '000';

l_debug_count           NUMBER;
l_delim                 CONSTANT VARCHAR2(1) := ' ';

l_line_token 		FND_NEW_MESSAGES.message_text%TYPE;
l_shipment_token	FND_NEW_MESSAGES.message_text%TYPE;
l_distribution_token	FND_NEW_MESSAGES.message_text%TYPE;
l_warning_rows_flag     VARCHAR2(1) := 'N';

l_sequence_num_tbl 	PO_TBL_NUMBER;
l_line_num_tbl		PO_TBL_NUMBER;
l_shipment_num_tbl	PO_TBL_NUMBER;
l_distribution_num_tbl	PO_TBL_NUMBER;
l_distribution_id_tbl	PO_TBL_NUMBER;
l_result_code_tbl	PO_TBL_VARCHAR5;
l_message_type_tbl  	PO_TBL_VARCHAR1;
l_text_line_tbl  	PO_TBL_VARCHAR2000;
l_show_in_psa_tbl   PO_TBL_VARCHAR1;      --<bug#5010001>
l_segment1_tbl      PO_TBL_VARCHAR20;     --<bug#5010001>
l_distribution_type_tbl po_tbl_varchar25; --<bug#5010001>
l_error_rows_flag VARCHAR2(1);
BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_gl_return_code',
                      p_gl_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_user_id', p_user_id);
END IF;

l_progress := '010';

l_line_token := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
l_shipment_token := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
l_distribution_token := fnd_message.get_string('PO', 'PO_ZMVOR_DISTRIBUTION');

l_progress := '020';

-- Update the result info with identifying string info
-- i.e. 'Line 1 Shipment 2 Distribution 1'
UPDATE PO_ENCUMBRANCE_GT DISTS
SET DISTS.result_text =
    (
       DECODE( DISTS.distribution_type
             , g_dist_type_AGREEMENT, ''
             , g_dist_type_REQUISITION,
               (  l_line_token || DISTS.line_num
                  || l_delim || l_distribution_token || DISTS.distribution_num
                  || l_delim
               )
             , -- all other docs
               (  l_line_token || DISTS.line_num
                  || l_delim || l_shipment_token || DISTS.shipment_num
                  || l_delim || l_distribution_token || DISTS.distribution_num
                  || l_delim
               )
       )
     || DISTS.result_text
    )
WHERE DISTS.origin_sequence_num IS NULL
AND   DISTS.result_text IS NOT NULL;

l_progress := '030';
IF g_debug_stmt THEN
   l_debug_count := SQL%ROWCOUNT;
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
                       'Appended entity nums to lines: ' || l_debug_count);
END IF;


SELECT
   nvl(DISTS.row_index, DISTS.sequence_num)
,  DISTS.line_num
,  DISTS.shipment_num
,  DISTS.distribution_num
,  DISTS.distribution_id
,  DISTS.gl_result_code
,  DISTS.result_type
,  DISTS.result_text
,   CASE --<bug#5378759>
    WHEN nvl(DISTS.prevent_encumbrance_flag,'N')='Y' THEN
        'Y'
    WHEN DISTS.period_name IS NULL THEN
        'Y'
    ELSE
        'N'
    END CASE
,  DISTS.segment1                 --<bug#5010001>
,  DISTS.distribution_type        --<bug#5010001>
BULK COLLECT INTO
   l_sequence_num_tbl
,  l_line_num_tbl
,  l_shipment_num_tbl
,  l_distribution_num_tbl
,  l_distribution_id_tbl
,  l_result_code_tbl
,  l_message_type_tbl
,  l_text_line_tbl
,  l_show_in_psa_tbl        --<bug#5010001>
,  l_segment1_tbl           --<bug#5010001>
,  l_distribution_type_tbl  --<bug#5010001>
FROM PO_ENCUMBRANCE_GT DISTS
WHERE DISTS.origin_sequence_num IS NULL  --main doc only
AND   DISTS.result_text IS NOT NULL
AND  (DISTS.adjustment_status IS NULL OR
      DISTS.adjustment_status = g_adjustment_status_NEW
--bug 3378198: for Adjust, only report on new distributions
)
;

l_progress := '040';
IF g_debug_stmt THEN
   l_debug_count := SQL%ROWCOUNT;
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
                       'Retrieved result info for rows: ' || l_debug_count);
END IF;

-- Make the autonomous call out to insert the result information.
-- Autonomous guarantees results are available even if caller rolls
-- back on failure.
insert_report_autonomous(
   p_reporting_level 		=> g_REPORT_LEVEL_DISTRIBUTION
,  p_message_text 		=> NULL
,  p_user_id			=> p_user_id
,  p_sequence_num_tbl		=> l_sequence_num_tbl
,  p_line_num_tbl		=> l_line_num_tbl
,  p_shipment_num_tbl		=> l_shipment_num_tbl
,  p_distribution_num_tbl	=> l_distribution_num_tbl
,  p_distribution_id_tbl	=> l_distribution_id_tbl
,  p_result_code_tbl		=> l_result_code_tbl
,  p_message_type_tbl		=> l_message_type_tbl
,  p_text_line_tbl		=> l_text_line_tbl
,  p_show_in_psa_flag   => l_show_in_psa_tbl        --<bug#5010001>
,  p_segment1_tbl       => l_segment1_tbl           --<bug#5010001>
,  p_distribution_type_tbl=>l_distribution_type_tbl --<bug#5010001>
,  x_online_report_id  		=> x_online_report_id
);

l_progress := '050';


IF (p_gl_return_code IN ('S', 'A')) THEN
   -- GL returned Success or Advisory
   l_progress := '052';

   --bug#5413111 If any of the rows had failed due to a gl date
   --failure and if the result was Error we should show an error.
   --It is possible that none of the remaining rows sent to GL
   --errored out. In such case we would see success while some of
   --the rows had a gl date exception.
   BEGIN
      SELECT 'Y'
      INTO l_error_rows_flag
      FROM PO_ENCUMBRANCE_GT DISTS
      WHERE DISTS.result_type = g_result_ERROR
      AND rownum = 1;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_error_rows_flag := 'N';
   END;

   -- Bug 3295875: If GL returns an 'A', it could be due
   -- to one of their own expanded GL lines in the packet.
   -- In this case, switch the status to 'S' if all OUR
   -- distribution lines are success.
   -- The reverse case is that GL can return an 'S'
   -- but we have prevent encumbrance rows that GL did not
   -- see, so PO flips the status to 'A' manually
   -- Bug 3589694: Added a WHERE condition to only do this for
   -- main doc rows, since those are the only rows we report on.

  IF(nvl(l_error_rows_flag,'N')='N')THEN
    BEGIN
       SELECT 'Y'
       INTO l_warning_rows_flag
       FROM PO_ENCUMBRANCE_GT DISTS
       WHERE DISTS.result_type = g_result_WARNING
       AND DISTS.origin_sequence_num IS NULL  --bug 3589694
       AND rownum = 1;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_warning_rows_flag := 'N';
    END;
   END IF;

   l_progress := '054';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,
                         'l_warning_rows_flag',l_warning_rows_flag);
   END IF;

   IF (nvl(l_warning_rows_flag,'N') = 'Y') THEN
      x_po_return_code := g_return_WARNING;
      x_po_return_msg_name := 'PO_ENC_API_WARNING';
   --<bug#5413111 START>
   ELSIF (nvl(l_error_rows_flag,'N')='Y') THEN
      x_po_return_code := g_return_FAILURE;
      x_po_return_msg_name := 'PO_ENC_API_FAILURE';
   --<bug#5413111 END>
   ELSE
      x_po_return_code := g_return_SUCCESS;
      x_po_return_msg_name := 'PO_ENC_API_SUCCESS';
   END IF;

ELSIF (p_gl_return_code = 'P') THEN
   -- GL returned Partial (some rows passed, some failed)

   l_progress := '056';
   x_po_return_code := g_return_PARTIAL;
   x_po_return_msg_name := 'PO_ENC_API_FAILURE';

ELSIF (p_gl_return_code = 'F') THEN
   -- GL returned Failure

   l_progress := '058';
   x_po_return_code := g_return_FAILURE;
   x_po_return_msg_name := 'PO_ENC_API_FAILURE';

ELSIF (p_gl_return_code = 'T') THEN
   -- GL returned Fatal

   l_progress := '059';
   x_po_return_code := g_return_FATAL;
   x_po_return_msg_name := 'PO_ENC_API_FAILURE';

END IF;

l_progress := '060';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',
                      x_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',
                      x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_msg_name',
                      x_po_return_msg_name);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END create_detailed_report;


------------------------------------------------------------------------------
--Start of Comments
--Name: create_exception_report
--Pre-reqs:
--  None.
--Modifies:
--  PO_ONLINE_REPORT_TEXT
--Locks:
--  None.
--Function:
--  Inserts a single row into the PO_ONLINE_REPORT_TEXT table,
--  which provides information about the cause of an exception.
--  This message is an overall-transaction level message.
--Parameters:
--IN:
--p_message_text
--  The detail message to be put into PO_ONLINE_REPORT_TEXT
--  This message indicates why the overall transaction was unsuccessful
--p_user_id
--  ID of the current user
--OUT:
--x_online_report_id
--  The unique ID of the result information in the
--  PO_ONLINE_REPORT_TEXT table
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE create_exception_report(
   p_message_text		IN		VARCHAR2
,  p_user_id			IN		NUMBER
,  x_online_report_id		OUT NOCOPY	NUMBER
)
IS

l_api_name	CONSTANT varchar2(30) := 'CREATE_EXCEPTION_REPORT';
l_log_head	CONSTANT varchar2(100) := g_log_head || l_api_name;
l_progress	varchar2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_message_text', p_message_text);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_user_id', p_user_id);
END IF;

insert_report_autonomous(
   p_reporting_level       => g_REPORT_LEVEL_TRANSACTION
,  p_message_text          => p_message_text
,  p_user_id               => p_user_id
,  p_sequence_num_tbl      => NULL
,  p_line_num_tbl          => NULL
,  p_shipment_num_tbl      => NULL
,  p_distribution_num_tbl  => NULL
,  p_distribution_id_tbl   => NULL
,  p_result_code_tbl       => NULL
,  p_message_type_tbl      => NULL
,  p_text_line_tbl         => NULL
,  p_show_in_psa_flag  => NULL    --<bug#5010001>
,  p_segment1_tbl       => NULL   --<bug#5010001>
,  p_distribution_type_tbl=> NULL --<bug#5010001>
,  x_online_report_id      => x_online_report_id
);

l_progress := '010';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',
                      x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END create_exception_report;


------------------------------------------------------------------------------
--Start of Comments
--Name: insert_report_autonomous
--Pre-reqs:
--  None
--Modifies:
--  PO_ONLINE_REPORT_TEXT
--Locks:
--  None.
--Function:
--  Inserts rows into the PO_ONLINE_REPORT_TEXT table to
--  represent the transaction result "details".  This is either
--  the distribution-specific result information or the specific
--  exception information for the overall transaction.
--Parameters:
--IN:
--p_reporting_level
--   Indicates whether we are inserting a single row (an exception
--   msg that applies to the whole transaction) or multiple
--   rows (result information for each distribution)
--   VALUES: g_report_level_TRANSACTION, g_report_level_DISTRIBUTION
--p_message_text
--  Used only if reporting level is g_report_level_TRANSACTION
--  The detail message to be put into PO_ONLINE_REPORT_TEXT
--  This message indicates why the overall transaction was unsuccessful
--p_user_id
--  ID of the current user
--p_sequence_num_tbl
--  Used only if reporting level is g_report_level_DISTRIBUTION
--  A collection of sequence numbers for the rows from
--  PO_ENCUMBRANCE_GT which we are reporting on
--p_line_num_tbl
--  A collection of line numbers for the rows from
--  PO_ENCUMBRANCE_GT which we are reporting on
--p_shipment_num_tbl
--  A collection of shipment numbers for the rows from
--  PO_ENCUMBRANCE_GT which we are reporting on
--p_distribution_num_tbl
--  A collection of distribution numbers for the rows from
--  PO_ENCUMBRANCE_GT which we are reporting on
--p_distribution_id_tbl
--  A collection of distribution ids for the rows from
--  PO_ENCUMBRANCE_GT which we are reporting on
--p_result_code_tbl
--  A collection of result codes for the rows from
--  PO_ENCUMBRANCE_GT which we are reporting on
--p_message_type_tbl
--  A collection of result classifications for the rows from
--  PO_ENCUMBRANCE_GT which we are reporting on
--p_text_line_tbl
--  A collection of result messages for the rows from
--  PO_ENCUMBRANCE_GT which we are reporting on
--OUT:
--x_online_report_id
--  The unique ID of the result information in the
--  PO_ONLINE_REPORT_TEXT table
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE insert_report_autonomous(
   p_reporting_level 		IN VARCHAR2
,  p_message_text 		IN VARCHAR2
,  p_user_id			IN NUMBER
,  p_sequence_num_tbl		IN po_tbl_number
,  p_line_num_tbl		IN po_tbl_number
,  p_shipment_num_tbl		IN po_tbl_number
,  p_distribution_num_tbl	IN po_tbl_number
,  p_distribution_id_tbl	IN po_tbl_number
,  p_result_code_tbl		IN po_tbl_varchar5
,  p_message_type_tbl		IN po_tbl_varchar1
,  p_text_line_tbl		IN po_tbl_varchar2000
,  p_show_in_psa_flag IN po_tbl_varchar1      --<bug#5010001>
,  p_segment1_tbl     IN po_tbl_varchar20     --<bug#5010001>
,  p_distribution_type_tbl IN po_tbl_varchar25--<bug#5010001>
,  x_online_report_id  		OUT NOCOPY NUMBER
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_api_name	CONSTANT varchar2(30) := 'INSERT_REPORT_AUTONOMOUS';
l_log_head	CONSTANT varchar2(100) := g_log_head || l_api_name;
l_progress	varchar2(3) := '000';
l_report_id	PO_ONLINE_REPORT_TEXT.online_report_id%TYPE;

l_user_id   NUMBER;
l_message_text PO_ONLINE_REPORT_TEXT.text_line%TYPE;

l_single_message_flag  BOOLEAN;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_reporting_level',
                      p_reporting_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_message_text', p_message_text);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_user_id', p_user_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_text_line_tbl',p_text_line_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_message_type_tbl',p_message_type_tbl);
END IF;

x_online_report_id := NULL;

l_progress := '010';

SELECT 	PO_ONLINE_REPORT_TEXT_S.nextval
INTO	l_report_id
FROM	dual;

l_progress := '020';

l_user_id := NVL(p_user_id,0);

IF (p_message_text IS NULL) THEN
   FND_MESSAGE.set_name('PO', 'PO_MSG_NULL_MESSAGE');
   l_message_text := FND_MESSAGE.get;
ELSE
   l_message_text := p_message_text;
END IF;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_id',l_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_user_id',l_user_id);
END IF;
---<BUG 12824154 : Modified the code to show detailed messages
--from psa_xla_accounting_errors table if there is an
--unexpected error returned from execute_gl_call
if l_message_text = 'GL_FUNDS_API_EXC' then


   INSERT INTO PO_ONLINE_REPORT_TEXT(
          online_report_id
       ,  sequence
       ,  last_updated_by
       ,  last_update_date
       ,  created_by
       ,  creation_date
       ,  transaction_type
       ,  message_type
       ,  text_line
       ,  show_in_psa_flag  --<bug#5010001>
       ,  segment1
       )
     select l_report_id
       ,  0                       -- sequence
       ,  l_user_id               -- updated by
       ,  SYSDATE                 -- update date
       ,  l_user_id               -- created by
       ,  SYSDATE                 -- creation date
       ,  g_module_ENCUMBRANCE    -- transaction type
       ,  g_result_TRANSACTION    -- message type
       ,  pba.ENCODED_MSG
       ,  'Y'               --<bug#5010001>
       ,   poh.segment1
       from psa_xla_accounting_errors pba,po_headers_all  poh
       where pba.event_id = PO_ENCUMBRANCE_POSTPROCESSING.g_event_id
       and   pba.source_id_int_1 = poh.po_header_id

       UNION ALL

      select l_report_id
       ,  0                       -- sequence
       ,  l_user_id               -- updated by
       ,  SYSDATE                 -- update date
       ,  l_user_id               -- created by
       ,  SYSDATE                 -- creation date
       ,  g_module_ENCUMBRANCE    -- transaction type
       ,  g_result_TRANSACTION    -- message type
       ,  pba.ENCODED_MSG
       ,  'Y'               --<bug#5010001>
       ,   prh.segment1
       from psa_xla_accounting_errors pba,po_requisition_headers_all  prh
       where pba.event_id = PO_ENCUMBRANCE_POSTPROCESSING.g_event_id
       and   pba.source_id_int_1 = prh.requisition_header_id ;
else

-- l_single_message_flag indicates what type of detailed message we show.
-- In some scenarios (i.e. a SQL exception or GL Fatal error), we
-- show only a single high level message for the whole trxn, and
-- this message is passed in as p_message_text, or we pop it off
-- the stack if that parameter is NULL (happens for SQL exceptions).
-- In this 1st case, l_single_message_flag is True.
-- In other scenarios, we use the pl/sql table parameters and
-- populate multiple detailed messages for the trxn: one for each
-- distribution. In the 2nd case, l_single_message_flag is False.

l_single_message_flag := FALSE;

IF (p_reporting_level = g_REPORT_LEVEL_TRANSACTION) THEN
   l_single_message_flag := TRUE;
END IF;

IF (p_sequence_num_tbl IS NULL) THEN
   l_single_message_flag := TRUE;
ELSIF (p_sequence_num_tbl.COUNT = 0) THEN
   l_single_message_flag := TRUE;
END IF;

l_progress := '050';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,
                     'l_single_message_flag',l_single_message_flag);
END IF;

IF l_single_message_flag THEN

   l_progress := '100';

   INSERT INTO PO_ONLINE_REPORT_TEXT(
      online_report_id
   ,  sequence
   ,  last_updated_by
   ,  last_update_date
   ,  created_by
   ,  creation_date
   ,  transaction_type
   ,  message_type
   ,  text_line
   ,  show_in_psa_flag  --<bug#5010001>
   )
   VALUES(
      l_report_id
   ,  0                       -- sequence
   ,  l_user_id               -- updated by
   ,  SYSDATE                 -- update date
   ,  l_user_id               -- created by
   ,  SYSDATE                 -- creation date
   ,  g_module_ENCUMBRANCE    -- transaction type
   ,  g_result_TRANSACTION    -- message type
   ,  l_message_text
   ,  'Y'               --<bug#5010001>
   );

ELSE
   l_progress := '200';

   FORALL i IN 1 .. p_sequence_num_tbl.COUNT
   INSERT INTO PO_ONLINE_REPORT_TEXT(
      online_report_id
   ,  sequence
   ,  last_updated_by
   ,  last_update_date
   ,  created_by
   ,  creation_date
   ,  line_num
   ,  shipment_num
   ,  distribution_num
   ,  transaction_id
   ,  transaction_type
   ,  transaction_location
   ,  message_type
   ,  text_line
   ,  show_in_psa_flag    --<bug#5010001>
   ,  segment1            --<bug#5010001>
   ,  distribution_type   --<bug#5010001>
   )
   VALUES(
      l_report_id
   ,  NVL(p_sequence_num_tbl(i),0)
   ,  l_user_id
   ,  SYSDATE
   ,  l_user_id
   ,  SYSDATE
   ,  p_line_num_tbl(i)
   ,  p_shipment_num_tbl(i)
   ,  p_distribution_num_tbl(i)
   ,  p_distribution_id_tbl(i)
   ,  g_module_ENCUMBRANCE
   ,  p_result_code_tbl(i)
   ,  p_message_type_tbl(i)
   ,  NVL(p_text_line_tbl(i),l_message_text)
   ,  p_show_in_psa_flag(i)         --<bug#5010001>
   ,  p_segment1_tbl(i)             --<bug#5010001>
   ,  p_distribution_type_tbl(i)    --<bug#5010001>
   );

END IF; --reporting level
END if;
x_online_report_id := l_report_id;

l_progress := '900';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',
                      x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

COMMIT;

EXCEPTION

WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   COMMIT;
   RAISE;

END insert_report_autonomous;


--<Start Bug 3218669>

-------------------------------------------------------------------------------
--Start of Comments
--Name: delete_packet_autonomous
--Pre-reqs:
--  None.
--Modifies:
--  GL_BC_PACKETS
--Locks:
--  None.
--Function:
--  This procedure takes a packet id and deletes and
--  commits it to GL_BC_PACKETS in an autonomous transaction.
--Parameters:
--IN:
--p_packet_id
--  The GL_BC_PACKETS.packet_id for the packet that is to be deleted.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE delete_packet_autonomous(
  p_packet_id                      IN     NUMBER
)
IS

  l_proc_name CONSTANT VARCHAR2(30) := 'DELETE_PACKET_AUTONOMOUS';
  l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
  l_progress VARCHAR2(3) := '000';
  --<SLA R12>
  -- SQL What: Querying for events currently in PSA_BC_XLA_EVENTS_GT
  -- SQL Why : Need to delete all data related to these events from PSA tables
  -- SQL Join: None
  CURSOR cur_events IS
    SELECT event_id
    FROM   PSA_BC_XLA_EVENTS_GT;

BEGIN

  IF g_debug_stmt THEN
     PO_DEBUG.debug_begin(l_log_head);
     PO_DEBUG.debug_var(l_log_head,l_progress,'p_packet_id',p_packet_id);
  END IF;

  l_progress := '010';

  --<R12 SLA start>
  FOR REC_EVENTS IN cur_events LOOP
    -- call the XLA API to delete events
    xla_events_pub_pkg.DELETE_EVENT
                       (
                        p_event_source_info    => NULL,
                        p_event_id             => REC_EVENTS.event_id,
                        p_valuation_method     => NULL,
                        p_security_context     => NULL
                       );
  END LOOP;
  --<R12 SLA End>

  IF g_debug_stmt THEN
    PO_DEBUG.debug_stmt(l_log_head,l_progress,'Delete Packet GL API Called');
  END IF;

  l_progress := '020';


  IF g_debug_stmt THEN
    PO_DEBUG.debug_stmt(l_log_head,l_progress,'Delete Packet Committed');
    PO_DEBUG.debug_end(l_log_head);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    --add message to the stack and log a debug msg if necessary
    po_message_s.sql_error(g_pkg_name, l_proc_name, l_progress, SQLCODE, SQLERRM);
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END delete_packet_autonomous;

--<End Bug 3218669>

--<SLA R12 Start>

-------------------------------------------------------------------------------
--Start of Comments
--Name: DELETE_PO_BC_DISTRIBUTIONS
--Pre-reqs:
--  None.
--Modifies:
--  PO_BC_DISTRIBUTIONS.
--Locks:
--  None.
--Function:
-- This procedure deletes from po_bc_distributions all rows corresponding to
-- a specified packetid.
--Parameters:
--IN:
--  p_packet_id.
--IN OUT:
--  None.
--OUT:
--  None.
--Notes:
-- The algorithm of the procedure is as follows :
-- This procedure deletes from po_bc_distributions all rows corresponding to
-- a specified packetid.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Delete_PO_BC_Distributions (
  p_packet_id                      IN           NUMBER
 )
IS
BEGIN

  -- Delete all records for the packet processed from po_bc_distributions
  DELETE FROM po_bc_distributions
  WHERE packet_id = p_packet_id;

END Delete_PO_BC_Distributions;

--<bug#5010001 START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: populate_bc_report_id
--Pre-reqs:
--  None.
--Modifies:
--  PO_BC_DISTRIBUTIONS.
--Locks:
--  None.
--Function:
-- This procedure populates online_report_id on po_bc_distributions rows corresponding to
-- a given encumbrance transaction.
--Parameters:
--IN:
--  p_online_report_id.
--  Value of online report id unique identifier for the current transaction
--IN OUT:
--  None.
--OUT:
--  None.
--Notes:
-- The algorithm of the procedure is as follows :
-- Get all distributions in the global temporary table and populate
-- their counterparts in po_bc_distributions with online_report_id
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE populate_bc_report_id (
    p_online_report_id IN NUMBER
)IS
l_module_name CONSTANT VARCHAR2(100) := 'populate_bc_report_id';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_module_name ;

l_progress VARCHAR2(3);
BEGIN
    l_progress  :='000';
    If g_debug_stmt Then
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Start of procedure');
        PO_DEBUG.debug_var(l_log_head,l_progress,'p_online_report_id',p_online_report_id);
    End If;
--bug#5523323 Remove the call to populate_aut_bc_report_id as this is not necessary.
--we have removed the autonomous transaction.
    UPDATE
        PO_BC_DISTRIBUTIONS
        SET online_report_id=p_online_report_id
    WHERE reference15 in
        (
           SELECT reference15
           FROM po_encumbrance_gt
           WHERE send_to_gl_flag='Y'
        );

    l_progress  :='001';

    If g_debug_stmt Then
        PO_DEBUG.debug_var(l_log_head,l_progress,'sql%rowcount',sql%rowcount);
    End If;

    l_progress :='002';

    If g_debug_stmt Then
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'End of Procedure');
    End If;
EXCEPTION
WHEN OTHERS THEN
  --add message to the stack and log a debug msg if necessary
  po_message_s.sql_error(g_pkg_name, l_module_name, l_progress, SQLCODE, SQLERRM);
  fnd_msg_pub.add;

  If g_debug_stmt Then
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Exception raised:'||SQLCODE||' '||SQLERRM);
  End If;

  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

--<bug#5353223 START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_sign_for_amount
--Pre-reqs:
--  None.
--Modifies:
--  n/a.
--Locks:
--  None.
--Function:
-- This procedure returns the sign i.e -1/1 to be multiplied with amount based on
-- the event type code/distribution type/adjustment status/main or backing doc.
--Parameters:
--IN:
--  p_event_type_code
--  Event type code that is created for the given transaction.
--  p_main_or_backing_doc
--  Indicates wether the document is a main/backing document.
--  p_adjustment_status
--  this could have a value of NEW/OLD
--  p_distribution_type
--  Indicates the distribution type. e.g STANDARD/AGREEMENT/REQUISITION etc.
--IN OUT:
--  None.
--OUT:
--  None.
--Notes:
-- The algorithm of the procedure is as follows :
-- Populate all rows in po_bc_distributions matching the reference15 column with
-- p_online_report_id
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
  FUNCTION get_sign_for_amount(p_event_type_code     IN VARCHAR2,
                               p_main_or_backing_doc IN VARCHAR2,
                               p_adjustment_status   IN VARCHAR2,
                               p_distribution_type   IN VARCHAR2) RETURN NUMBER IS
    l_multiplying_factor NUMBER := 0;
    l_cr_or_dr           VARCHAR2(2);
    l_api_name  CONSTANT varchar2(40) := 'get_sign_for_amount';
    l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
    l_progress VARCHAR2(3) := '000';
  BEGIN
    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(l_log_head);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_event_type_code',p_event_type_code);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_main_or_backing_doc',p_main_or_backing_doc);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_adjustment_status',p_adjustment_status);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_distribution_type',p_distribution_type);
    END IF;
    l_progress := '010';
    IF p_event_type_code = 'PO_REOPEN_FINAL_MATCH' AND
       p_main_or_backing_doc = 'M' THEN
      l_cr_or_dr := g_DEBIT;
    ELSIF (p_event_type_code = 'PO_PA_CANCELLED' OR
          p_event_type_code = 'PO_PA_CR_MEMO_CANCELLED') THEN
      IF p_main_or_backing_doc in ('B_PA','B_REQ' ) THEN
          l_cr_or_dr := g_CREDIT;
      ELSIF p_main_or_backing_doc = 'M' THEN
          l_cr_or_dr := g_DEBIT;
      END IF;
    ELSIF (p_event_type_code = 'PO_PA_UNRESERVED' OR
          p_event_type_code = 'PO_PA_REJECTED' OR
          p_event_type_code = 'PO_PA_INV_CANCELLED') AND
          p_main_or_backing_doc IN ('B_PA','B_REQ') THEN
      l_cr_or_dr := g_DEBIT;
    ELSIF (p_event_type_code = 'PO_PA_UNRESERVED' OR
          p_event_type_code = 'PO_PA_REJECTED' OR
          p_event_type_code = 'PO_PA_FINAL_CLOSED' OR
          p_event_type_code = 'PO_PA_INV_CANCELLED') AND
          p_main_or_backing_doc = 'M' THEN
      l_cr_or_dr := g_CREDIT;
    ELSIF p_event_type_code = 'PO_PA_RESERVED' THEN
      IF p_main_or_backing_doc IN ('B_PA','B_REQ') THEN
          l_cr_or_dr := g_CREDIT;
      ELSIF p_main_or_backing_doc = 'M' THEN
          l_cr_or_dr := g_DEBIT;
      END IF;
    ELSIF p_event_type_code = 'RELEASE_REOPEN_FINAL_CLOSED' AND
          p_main_or_backing_doc = 'M' THEN
      l_cr_or_dr := g_DEBIT;
    ELSIF (p_event_type_code = 'RELEASE_CANCELLED' OR
          p_event_type_code = 'RELEASE_CR_MEMO_CANCELLED')  THEN
      IF p_main_or_backing_doc IN('B_PO' ,'B_PA','B_REQ') THEN
          l_cr_or_dr := g_CREDIT;
      ELSIF p_main_or_backing_doc = 'M' THEN
          l_cr_or_dr := g_DEBIT;
      END IF;
    ELSIF (p_event_type_code = 'RELEASE_UNRESERVED' OR
          p_event_type_code = 'RELEASE_REJECTED' OR
          p_event_type_code = 'RELEASE_INV_CANCELLED') AND
          p_main_or_backing_doc IN ('B_PO','B_PA','B_REQ') THEN
      l_cr_or_dr := g_DEBIT;
    ELSIF (p_event_type_code = 'RELEASE_REJECTED' OR
          p_event_type_code = 'RELEASE_UNRESERVED' OR
          p_event_type_code = 'RELEASE_FINAL_CLOSED' OR
          p_event_type_code = 'RELEASE_INV_CANCELLED') AND
          p_main_or_backing_doc = 'M' THEN
      l_cr_or_dr := g_CREDIT;
    ELSIF p_event_type_code = 'RELEASE_RESERVED' THEN
      IF p_main_or_backing_doc IN ('B_PO','B_PA','B_REQ') THEN
          l_cr_or_dr := g_CREDIT;
      ELSIF    p_main_or_backing_doc = 'M' THEN
          l_cr_or_dr := g_DEBIT;
      END IF;
    ELSIF (p_event_type_code = 'REQ_RESERVED' OR
          p_event_type_code = 'REQ_ADJUSTED' AND p_adjustment_status = g_adjustment_status_NEW) AND
          p_main_or_backing_doc = 'M' THEN
      l_cr_or_dr := g_DEBIT;
    ELSIF (p_event_type_code = 'REQ_UNRESERVED' OR
          p_event_type_code = 'REQ_FINAL_CLOSED' OR
          (p_event_type_code = 'REQ_ADJUSTED' AND
          p_adjustment_status = g_adjustment_status_OLD) OR
          p_event_type_code = 'REQ_REJECTED' OR
          p_event_type_code = 'REQ_RETURNED') AND
          p_main_or_backing_doc = 'M' THEN
      l_cr_or_dr := g_CREDIT;
    ELSIF p_event_type_code = 'REQ_CANCELLED' THEN
      l_cr_or_dr := g_DEBIT;
    ELSIF  p_event_type_code = 'PO_PA_REOPEN_FINAL_MATCH' THEN
      IF p_main_or_backing_doc = 'M' THEN
          l_cr_or_dr := g_DEBIT;
      ELSE
          l_cr_or_dr := g_CREDIT;
      END IF;
    --<bug#5646605 START>
    --PSA has added two new event type codes PO_PA_ADJUSTED and RELEASE_ADJUSTED
    --Need to determine the sign for these event type codes for the main and backing
    --documents
    ELSIF p_event_type_code = 'PO_PA_ADJUSTED' THEN
      IF p_adjustment_status = 'NEW' THEN
          IF p_main_or_backing_doc = 'M' THEN
              l_cr_or_dr := g_DEBIT;
          ELSE
              l_cr_or_dr := g_CREDIT;
          END IF;
      ELSE
          IF p_main_or_backing_doc = 'M' THEN
              l_cr_or_dr := g_CREDIT;
          ELSE
              l_cr_or_dr := g_DEBIT;
          END IF;
      END IF;
    ELSIF p_event_type_code='RELEASE_ADJUSTED' THEN
      IF p_adjustment_status = 'NEW' THEN
          IF p_main_or_backing_doc = 'M' THEN
              l_cr_or_dr := g_DEBIT;
          ELSE
              l_cr_or_dr := g_CREDIT;
          END IF;
      ELSE
          IF p_main_or_backing_doc = 'M' THEN
              l_cr_or_dr := g_CREDIT;
          ELSE
              l_cr_or_dr := g_DEBIT;
          END IF;
      END IF;
    --<bug#5646605 END>
    END IF;

    l_progress := '020';

    IF l_cr_or_dr = g_DEBIT THEN
        l_multiplying_factor := 1;
    ELSIF l_cr_or_dr = g_CREDIT THEN
        l_multiplying_factor := -1 ;
    ELSE
        RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '030';

    IF g_debug_stmt THEN
       PO_DEBUG.debug_end(l_log_head);
       PO_DEBUG.debug_var(l_log_head,l_progress,'l_cr_or_dr',l_cr_or_dr);
       PO_DEBUG.debug_var(l_log_head,l_progress,'l_multiplying_factor',l_multiplying_factor);
    END IF;

    return l_multiplying_factor;

  EXCEPTION
    WHEN OTHERS THEN
    --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress,SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

--<bug#5353223 END>
--<SLA R12 End>
--<bug#5646605 START added helper functions>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_event_type_code
--Pre-reqs:
--  None.
--Modifies:
--  n/a.
--Locks:
--  None.
--Function:
-- This function gets the event_type_code given the distribution type and action.
--Parameters:
--IN:
--  p_distribution_type
--  Indicates the distribution type. e.g STANDARD/AGREEMENT/REQUISITION etc.
--  p_action
--  Indicates the action type. This could be  RESERVE/UNRESERVE etc.
--IN OUT:
--  None.
--OUT:
--  None.
--Notes:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_event_type_code(p_distribution_type IN VARCHAR2,
                             p_action            IN VARCHAR2)
  RETURN VARCHAR2 IS
  l_event_type_code  varchar2(30);
  l_entity_type_code varchar2(30);
  l_doc_type         VARCHAR2(30);
  l_doc_subtype      VARCHAR2(30);
  l_api_name  CONSTANT varchar2(40) := 'get_event_type_code';
  l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress VARCHAR2(3) := '000';
BEGIN

  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_distribution_type',p_distribution_type);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
  END IF;

  get_doc_detail_from_dist_type(p_distribution_type => p_distribution_type,
                                x_doc_type          => l_doc_type,
                                x_doc_subtype       => l_doc_subtype);
  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type',l_doc_type);
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_subtype',l_doc_subtype);
  END IF;

  get_event_and_entity_codes(p_doc_type         => l_doc_type,
                             p_doc_subtype      => l_doc_subtype,
                             p_action           => p_action,
                             x_event_type_code  => l_event_type_code,
                             x_entity_type_code => l_entity_type_code);

  IF g_debug_stmt THEN
    PO_DEBUG.debug_end(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_type_code',l_event_type_code);
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_entity_type_code',l_entity_type_code);
  END IF;

  return l_event_type_code;
END;
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_entity_type_code
--Pre-reqs:
--  None.
--Modifies:
--  n/a.
--Locks:
--  None.
--Function:
-- This function gets the entity_type_code given the distribution type and action.
--Parameters:
--IN:
--  p_distribution_type
--  Indicates the distribution type. e.g STANDARD/AGREEMENT/REQUISITION etc.
--  p_action
--  Indicates the action type. This could be  RESERVE/UNRESERVE etc.
--IN OUT:
--  None.
--OUT:
--  None.
--Notes:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_entity_type_code(p_distribution_type IN VARCHAR2,
                              p_action            IN VARCHAR2)
  RETURN VARCHAR2 IS
  l_event_type_code  varchar2(30);
  l_entity_type_code varchar2(30);
  l_doc_type         VARCHAR2(30);
  l_doc_subtype      VARCHAR2(30);
  l_api_name  CONSTANT varchar2(40) := 'get_entity_type_code';
  l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress VARCHAR2(3) := '000';
BEGIN

  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_distribution_type',p_distribution_type);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
  END IF;

  get_doc_detail_from_dist_type(p_distribution_type => p_distribution_type,
                                x_doc_type          => l_doc_type,
                                x_doc_subtype       => l_doc_subtype);
  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type',l_doc_type);
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_subtype',l_doc_subtype);
  END IF;


  get_event_and_entity_codes(p_doc_type         => l_doc_type,
                             p_doc_subtype      => l_doc_subtype,
                             p_action           => p_action,
                             x_event_type_code  => l_event_type_code,
                             x_entity_type_code => l_entity_type_code);
  IF g_debug_stmt THEN
    PO_DEBUG.debug_end(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_event_type_code',l_event_type_code);
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_entity_type_code',l_entity_type_code);
  END IF;

  return l_entity_type_code;
END;
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_doc_detail_from_dist_type
--Pre-reqs:
--  None.
--Modifies:
--  n/a.
--Locks:
--  None.
--Function:
-- This procedure derives the document type and subtype given the distribution type.
--Parameters:
--IN:
--  p_distribution_type
--  Indicates the distribution type. e.g STANDARD/AGREEMENT/REQUISITION etc.
--IN OUT:
--  None.
--OUT:
--  x_doc_type
--  Indicates the document type e.g PO/PA/RELEASE etc
--  x_doc_subtype
--  Indicates the document sub type e.g STANDARD/BLANKET/SCHEDULED etc.
--Notes:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_doc_detail_from_dist_type(p_distribution_type IN VARCHAR2,
                                        x_doc_type          OUT NOCOPY VARCHAR2 ,
                                        x_doc_subtype       OUT NOCOPY VARCHAR2) IS
  l_doc_type    VARCHAR2(30);
  l_doc_subtype VARCHAR2(30);
  l_api_name  CONSTANT varchar2(40) := 'get_doc_detail_from_dist_type';
  l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress VARCHAR2(3) := '000';
BEGIN
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_distribution_type',p_distribution_type);
  END IF;

  CASE p_distribution_type
    WHEN g_dist_type_AGREEMENT THEN
      l_doc_type    := g_doc_type_PA;
      l_doc_subtype := g_doc_subtype_BLANKET;
    WHEN g_dist_type_PLANNED THEN
      l_doc_type    := g_doc_type_PO;
      l_doc_subtype := g_doc_subtype_PLANNED;
    WHEN g_dist_type_REQUISITION THEN
      l_doc_type    := g_doc_type_REQUISITION;
      l_doc_subtype := 'PURCHASE';
    WHEN g_dist_type_BLANKET THEN
      l_doc_type    := g_doc_type_RELEASE;
      l_doc_subtype := g_doc_subtype_BLANKET;
    WHEN g_dist_type_STANDARD THEN
      l_doc_type    := g_doc_type_PO;
      l_doc_subtype := g_doc_subtype_STANDARD;
    WHEN g_dist_type_SCHEDULED THEN
      l_doc_type    := g_doc_type_RELEASE;
      l_doc_subtype := g_doc_subtype_SCHEDULED;
  END CASE;
  x_doc_type    := l_doc_type;
  x_doc_subtype := l_doc_subtype;

  IF g_debug_stmt THEN
    PO_DEBUG.debug_end(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type',l_doc_type);
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_subtype',l_doc_subtype);
  END IF;

END;

--<SLA R12 Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_event_and_entity_codes
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This procedure returns the values of entity_type_code and event_type_code
-- based on the document type, document sub type and the action to be performed
-- These two values are assigned to corresponding global variables which are.
-- used by the new Budgetary Control API.
--Parameters:
--IN:
-- p_doc_type    : specifies the document type ('PO','REQ')
-- p_doc_subtype : specifies the document sub type
-- p_action      : specifies the encumbrance action ('RESERVE','CANCEL',etc)
--IN OUT:
--  None.
--OUT:
-- x_entity_type_code : to return entity type code ('REQUISITION'/'PURCHASE_ORDER')
-- x_event_type_code  : to return event type code
--Notes:
-- The algorithm of the procedure is as follows :
-- This procedure returns the entity_type_code and event_type_code based on the
-- values of document type, document sub type and the action to be performed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_event_and_entity_codes(
   p_doc_type          IN            VARCHAR2,
   p_doc_subtype       IN            VARCHAR2,
   p_action            IN            VARCHAR2,
   x_entity_type_code     OUT NOCOPY VARCHAR2,
   x_event_type_code      OUT NOCOPY VARCHAR2
)
IS
  l_entity_str          VARCHAR2(30);
  l_action_str          VARCHAR2(30);
  l_error_flag          VARCHAR2(1);
  l_api_name  CONSTANT varchar2(40) := 'get_event_and_entity_codes';
  l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress VARCHAR2(3) := '000';
BEGIN

  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
  END IF;

   l_error_flag := 'N' ;
   IF (p_doc_type = 'REQUISITION') THEN
      x_entity_type_code := 'REQUISITION';
      l_entity_str := 'REQ';
   ELSIF (p_doc_type IN ('PO','PA')) THEN
      x_entity_type_code := 'PURCHASE_ORDER';
      l_entity_str := 'PO_PA';
   ELSIF (p_doc_type = 'RELEASE') THEN
      x_entity_type_code := 'RELEASE';   -- Bug 5015010
      l_entity_str := 'RELEASE';
   ELSE
      l_error_flag := 'Y' ;
   END IF;

   IF (p_action = g_action_RESERVE) THEN
      l_action_str := 'RESERVED';
   ELSIF (p_action = g_action_UNRESERVE) THEN
      l_action_str := 'UNRESERVED';
   ELSIF (p_action = g_action_ADJUST) THEN
      l_action_str := 'ADJUSTED';
   ELSIF (p_action = g_action_CANCEL) THEN
      l_action_str := 'CANCELLED';
   ELSIF (p_action = g_action_FINAL_CLOSE) THEN
      l_action_str := 'FINAL_CLOSED';
   ELSIF (p_action = g_action_UNDO_FINAL_CLOSE) THEN
      l_action_str := 'UNDO_FINAL_CLOSED';
   ELSIF (p_action = g_action_REJECT) THEN
      l_action_str := 'REJECTED';
   ELSIF (p_action = g_action_RETURN) THEN
      l_action_str := 'RETURNED';
   -- Bug 4684263 Begin
   ELSIF (p_action = g_action_INVOICE_CANCEL) THEN
      l_action_str := 'INV_CANCELLED';
   ELSIF (p_action = g_action_CR_MEMO_CANCEL) THEN
      l_action_str := 'CR_MEMO_CANCELLED';
   -- Bug 4684263 End
   ELSE
      l_error_flag := 'Y' ;
   END IF;

   x_event_type_code := l_entity_str||'_'||l_action_str;

   -- Special cases wherein seeded data is different from the above
   -- derivations of event type code
   IF (x_event_type_code='PO_PA_UNDO_FINAL_CLOSED') THEN
      x_event_type_code := 'PO_REOPEN_FINAL_MATCH' ;
   ELSIF (x_event_type_code='RELEASE_UNDO_FINAL_CLOSED') THEN
      x_event_type_code := 'RELEASE_REOPEN_FINAL_CLOSED' ;
   END IF;

   IF (l_error_flag = 'Y') THEN

      x_event_type_code := NULL ;
      x_entity_type_code := NULL ;
   END IF;

  IF g_debug_stmt THEN
    PO_DEBUG.debug_end(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_event_type_code',x_event_type_code);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_entity_type_code',x_entity_type_code);
  END IF;

END get_event_and_entity_codes;

--<bug#5646605 END>

-------------------------------------------------------------------------------
--Start of Comments
-- Added for bug 12907851
--Name: update zero_enc_amt ros
--Pre-reqs:
--  PO_ENCUMBRANCE_GT has all information where final amt
-- is zero .
--Modifies:
--  PO_DISTRIBUTIONS_ALL, PO_LINE_LOCATIONS_ALL , PO_HEADERS_ALL, PO_RELEASES_ALL
--Locks:
--  None.
--Function:
--This procedure updates encumbered flag to Y
-- for RESERVE action and final_amt is zero. After partial invoicing if
-- after UNRESERVE amount in PO is reduced to invoiced amount . Again upon RESERVING
-- the final encumbrance amout is zero.

-- update the encumbered flag to N For UNRESERVE action and final amt
-- zero. After total invoicing, User need not create a new shipment
-- for the increased quantity.
--IN:
--p_doc_type
--  Differentiates between the main doc being a PURCHASE ORDER,
-- or RELEASE which is used to identify the tables to look at
--p_action
--  Encumbrance action requested on the main document:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE update_zero_amt_rows(p_action IN VARCHAR2,
                               p_doc_type IN VARCHAR2
 			      ) IS

  l_proc_name CONSTANT VARCHAR2(30) := 'update_zero_amt_rows';
  l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
  l_progress  VARCHAR2(3) := '000';

BEGIN
 l_progress := '001';

/* Bug 12866050 : Start
IF p_action = g_action_RESERVE then

  l_progress := '001';

        UPDATE   PO_DISTRIBUTIONS_ALL
           SET   encumbered_flag = 'Y'
         WHERE   po_distribution_id IN
               (SELECT   distribution_id
                  FROM   PO_ENCUMBRANCE_GT DIST
                 WHERE   SEND_TO_GL_FLAG = 'Y'
                   AND NVL (final_amt, 0) = 0);

        UPDATE PO_LINE_LOCATIONS_ALL poll
          SET encumbered_flag =  ( SELECT NVL(min(pod.encumbered_flag), 'N')
				    FROM PO_DISTRIBUTIONS_ALL POD
				    WHERE POD.line_location_id = POLL.line_location_id
				    AND NVL(POD.prevent_encumbrance_flag, 'N') = 'N' )
          WHERE line_location_id IN
               (SELECT   line_location_id
                  FROM   PO_ENCUMBRANCE_GT DIST
                 WHERE   SEND_TO_GL_FLAG = 'Y'
                   AND NVL (final_amt, 0) = 0);

 ELSIF p_action = g_action_UNRESERVE THEN

l_progress := '002';

        UPDATE   PO_DISTRIBUTIONS_ALL
           SET   encumbered_flag = 'N'
         WHERE   po_distribution_id IN
               (SELECT   distribution_id
                  FROM   PO_ENCUMBRANCE_GT DIST
                 WHERE   SEND_TO_GL_FLAG = 'Y'
                   AND NVL (final_amt, 0) = 0);

       UPDATE PO_LINE_LOCATIONS_ALL poll
          SET encumbered_flag =  ( SELECT NVL(min(pod.encumbered_flag), 'N')
				    FROM PO_DISTRIBUTIONS_ALL POD
				    WHERE POD.line_location_id = POLL.line_location_id
				    AND NVL(POD.prevent_encumbrance_flag, 'N') = 'N' )
          WHERE line_location_id IN
               (SELECT   line_location_id
                  FROM   PO_ENCUMBRANCE_GT DIST
                 WHERE   SEND_TO_GL_FLAG = 'Y'
                   AND NVL (final_amt, 0) = 0);

        UPDATE PO_LINE_LOCATIONS_ALL
          SET approved_flag = 'R',
	      last_update_date = sysdate,
	      last_updated_by = fnd_global.user_id,
	      last_update_login = fnd_global.login_id
          WHERE nvl(approved_flag,'N') = 'Y'
	    AND line_location_id IN
		       (SELECT   line_location_id
			  FROM   PO_ENCUMBRANCE_GT DIST
			 WHERE   SEND_TO_GL_FLAG = 'Y'
			   AND NVL (final_amt, 0) = 0);

           IF p_doc_type IN( g_doc_type_PO,g_doc_type_PA) THEN

	       UPDATE PO_HEADERS_ALL
		   SET authorization_status = 'REQUIRES REAPPROVAL',
		   approved_flag = 'R',
		   last_update_date = sysdate,
		   last_updated_by = fnd_global.user_id,
		   last_update_login = fnd_global.login_id
    	     WHERE nvl(approved_flag,'N') = 'Y'
	      AND po_header_id IN
	        (SELECT   header_id
			  FROM   PO_ENCUMBRANCE_GT DIST
			 WHERE   SEND_TO_GL_FLAG = 'Y'
			   AND NVL (final_amt, 0) = 0);

	   ELSIF p_doc_type =  g_doc_type_RELEASE THEN

	       UPDATE PO_RELEASES_ALL
		   SET authorization_status = 'REQUIRES REAPPROVAL',
		   approved_flag = 'R',
		   last_update_date = sysdate,
		   last_updated_by = fnd_global.user_id,
		   last_update_login = fnd_global.login_id
		 WHERE nvl(approved_flag,'N') = 'Y'
		 AND po_release_id IN
		   (SELECT   po_release_id
			  FROM   PO_ENCUMBRANCE_GT DIST
			 WHERE   SEND_TO_GL_FLAG = 'Y'
			   AND NVL (final_amt, 0) = 0);

	   END IF ;
END IF;
Bug 12860050 : End */
EXCEPTION
WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_proc_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;
END update_zero_amt_rows;

END PO_ENCUMBRANCE_POSTPROCESSING;

/
