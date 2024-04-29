--------------------------------------------------------
--  DDL for Package Body PO_ENCUMBRANCE_PREPROCESSING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ENCUMBRANCE_PREPROCESSING" AS
-- $Header: POXENC1B.pls 120.15.12010000.24 2014/12/17 08:02:49 gjyothi ship $


-------------------------------------------------------------------------------
-- Private package exceptions
-------------------------------------------------------------------------------

-- encumbrance validation exceptions:

g_INVALID_CALL_EXC_CODE          CONSTANT
   NUMBER
   := 1
   ;

g_ENC_VALIDATION_EXC_CODE        CONSTANT
   NUMBER
   := 2
   ;

g_SUBMISSION_CHECK_EXC_CODE      CONSTANT
   NUMBER
   := 3
   ;

g_POPULATE_ENC_GT_EXC            EXCEPTION;

-------------------------------------------------------------------------------
-- Private package constants
-------------------------------------------------------------------------------

-- Logging / debugging
g_pkg_name                       CONSTANT
   VARCHAR2(30)
   := 'PO_ENCUMBRANCE_PREPROCESSING'
   ;
g_log_head                       CONSTANT
   VARCHAR2(50)
   := 'po.plsql.' || g_pkg_name || '.'
   ;

-- Read the profile option that enables/disables the debug log
g_fnd_debug  VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_debug_stmt BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp BOOLEAN := PO_DEBUG.is_debug_unexp_on;


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
g_doc_type_REQUISITION           CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_REQUISITION
   ;
g_doc_type_PO                    CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_PO
   ;
g_doc_type_PA                    CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_PA
   ;
g_doc_type_RELEASE               CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_RELEASE
   ;
g_doc_type_MIXED_PO_RELEASE      CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_type_MIXED_PO_RELEASE
   ;


-- doc subtypes
g_doc_subtype_STANDARD           CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_STANDARD
   ;
g_doc_subtype_PLANNED            CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_PLANNED
   ;
g_doc_subtype_BLANKET            CONSTANT
   PO_RELEASES_ALL.release_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_BLANKET
   ;
g_doc_subtype_SCHEDULED          CONSTANT
   PO_RELEASES_ALL.release_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_SCHEDULED
   ;
g_doc_subtype_MIXED_PO_RELEASE   CONSTANT
   PO_HEADERS_ALL.type_lookup_code%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_doc_subtype_MIXED_PO_RELEASE
   ;


-- doc levels
g_doc_level_HEADER               CONSTANT
   VARCHAR2(25)
   := PO_DOCUMENT_FUNDS_PVT.g_doc_level_HEADER
   ;
g_doc_level_LINE                 CONSTANT
   VARCHAR2(25)
   := PO_DOCUMENT_FUNDS_PVT.g_doc_level_LINE
   ;
g_doc_level_SHIPMENT             CONSTANT
   VARCHAR2(25)
   := PO_DOCUMENT_FUNDS_PVT.g_doc_level_SHIPMENT
   ;
g_doc_level_DISTRIBUTION         CONSTANT
   VARCHAR2(25)
   := PO_DOCUMENT_FUNDS_PVT.g_doc_level_DISTRIBUTION
   ;


-- distribution types
g_dist_type_STANDARD             CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_STANDARD
   ;
g_dist_type_PLANNED              CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_PLANNED
   ;
g_dist_type_SCHEDULED            CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_SCHEDULED
   ;
g_dist_type_BLANKET              CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_BLANKET
   ;
g_dist_type_AGREEMENT            CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_AGREEMENT
   ;
g_dist_type_REQUISITION          CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_REQUISITION
   ;
g_dist_type_MIXED_PO_RELEASE     CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_MIXED_PO_RELEASE
   ;
g_dist_type_PREPAYMENT           CONSTANT
   PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
   := PO_DOCUMENT_FUNDS_PVT.g_dist_type_PREPAYMENT
   ;

-- parameter values
g_parameter_YES                  CONSTANT
   VARCHAR2(1)
   := PO_DOCUMENT_FUNDS_PVT.g_parameter_YES
   ;
g_parameter_NO                   CONSTANT
   VARCHAR2(1)
   := PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
   ;
g_parameter_USE_PROFILE          CONSTANT
   VARCHAR2(1)
   := PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE
   ;


-- closed codes
g_clsd_FINALLY_CLOSED            CONSTANT
   PO_HEADERS_ALL.closed_code%TYPE
   := 'FINALLY CLOSED'
   ;
g_clsd_OPEN                      CONSTANT
   PO_HEADERS_ALL.closed_code%TYPE
   := 'OPEN'
   ;


-- source type codes
g_src_INVENTORY                  CONSTANT
   PO_REQUISITION_LINES_ALL.source_type_code%TYPE
   := 'INVENTORY'
   ;


-- order type lookup codes
g_order_type_FIXED_PRICE         CONSTANT
   PO_LINE_TYPES_B.order_type_lookup_code%TYPE
   := 'FIXED PRICE'
   ;
g_order_type_RATE                CONSTANT
   PO_LINE_TYPES_B.order_type_lookup_code%TYPE
   := 'RATE'
   ;


-- p_main_or_backing
g_MAIN                           CONSTANT
   VARCHAR2(10)
   := 'MAIN'
   ;
g_BACKING                        CONSTANT
   VARCHAR2(10)
   := 'BACKING'
   ;


g_adj_status_OLD	CONSTANT varchar2(10):= 'OLD';
g_adj_status_NEW	CONSTANT varchar2(10):= 'NEW';

g_je_category_Requisitions CONSTANT varchar2(30):= 'Requisitions';
g_je_category_Purchases    CONSTANT varchar2(30):= 'Purchases';

g_reference1_REQ    CONSTANT varchar2(5):= 'REQ';
g_reference1_PA     CONSTANT varchar2(5):= 'PA';
g_reference1_PO     CONSTANT varchar2(5):= 'PO';
g_reference1_REL    CONSTANT varchar2(5):= 'PO'; --bug 3426101

g_reference6_GMSIP  CONSTANT varchar2(10):= 'GMSIP';
g_reference6_SRCDOC CONSTANT varchar2(10):= 'SRCDOC';

g_roll_logic_NONE     CONSTANT varchar2(10):= 'NONE';
g_roll_logic_FORWARD  CONSTANT varchar2(10):= 'FORWARD';
g_roll_logic_BACKWARD CONSTANT varchar2(10):= 'BACKWARD';

g_column_AMOUNT_TO_ENCUMBER CONSTANT varchar2(30):= 'AMOUNT_TO_ENCUMBER';
g_column_AMT_CLOSED	    CONSTANT varchar2(30):= 'AMT_CLOSED';
g_column_PRE_ROUND_AMT	    CONSTANT varchar2(30):= 'PRE_ROUND_AMT';

-- Bug 13503748 Encumbrance ER
g_column_PO_ENCUMBERED_AMOUNT CONSTANT VARCHAR2(50):= 'PO_ENCUMBERED_AMOUNT';

-- Bug15987200
g_column_PO_REVERSAL_AMOUNT  CONSTANT varchar2(30):= 'AMOUNT_REVERSED';
g_date_format   CONSTANT varchar2(25) := 'YYYY/MM/DD';

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


-- doc state check results
g_doc_state_valid_YES            CONSTANT
   VARCHAR2(1)
   := 'Y'
   ;
g_doc_state_valid_NO             CONSTANT
   VARCHAR2(1)
   := 'N'
   ;


-------------------------------------------------------------------------------
-- Forward procedure declarations
-------------------------------------------------------------------------------

PROCEDURE initialize_encumbrance_gt(
   p_use_enc_gt_flag                IN             VARCHAR2
);

PROCEDURE get_distributions(
   p_action                         IN             VARCHAR2
,  p_check_only_flag                IN             VARCHAR2
,  p_distribution_type              IN             VARCHAR2
,  p_main_or_backing                IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_ap_budget_account_id           IN             NUMBER
,  p_possibility_check_flag         IN             VARCHAR2
,  p_cbc_flag                       IN             VARCHAR2
,  x_count                          OUT NOCOPY     NUMBER
);

PROCEDURE remove_unnecessary_dists(
   p_action                         IN             VARCHAR2
,  p_cbc_flag                       IN             VARCHAR2
);

PROCEDURE update_encumbrance_gt(
   p_action                         IN             VARCHAR2
,  p_distribution_type              IN             VARCHAR2
,  p_main_or_backing                IN             VARCHAR2
,  p_origin_seq_num_tbl             IN             po_tbl_number
,  p_backing_dist_id_tbl            IN             po_tbl_number
,  p_ap_budget_account_id           IN             NUMBER
,  x_count                          OUT NOCOPY     NUMBER
);

PROCEDURE lock_backing_distributions(
   p_distribution_type              IN             VARCHAR2
);

PROCEDURE filter_backing_distributions(
   p_action                         IN             VARCHAR2
,  p_distribution_type              IN             VARCHAR2
,  x_dist_id_tbl                    OUT NOCOPY     po_tbl_number
,  x_origin_seq_num_tbl             OUT NOCOPY     po_tbl_number
);

PROCEDURE check_doc_state(
   p_action                         IN             VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  x_valid_state_flag               OUT NOCOPY     VARCHAR2
);

PROCEDURE get_period_info(
   p_action              IN VARCHAR2
,  p_set_of_books_id     IN NUMBER
,  p_override_date       IN DATE
,  p_try_dist_date_flag  IN VARCHAR2
,  p_partial_flag        IN VARCHAR2
);

PROCEDURE find_open_period(
   p_set_of_books_id    IN  NUMBER
,  p_try_dist_date_flag IN  VARCHAR2
,  p_override_date      IN  DATE
,  p_override_attempt   IN  VARCHAR2
,  p_roll_logic_used    IN  VARCHAR2
,  x_missing_date_flag  OUT NOCOPY VARCHAR2
);

--p_invoice_id
--  Adding as part of 20218327 since reversals
--  need not be calculated for Invoice Final Match

PROCEDURE get_amounts(
   p_action                IN   VARCHAR2
,  p_doc_type              IN   VARCHAR2
,  p_doc_subtype           IN   VARCHAR2
,  p_currency_code_func    IN   VARCHAR2
,  p_ap_reinstated_enc_amt IN   NUMBER
,  p_ap_cancelled_qty      IN   NUMBER
,  p_invoice_id            IN   NUMBER
);

PROCEDURE get_initial_amounts(
   p_action               IN  VARCHAR2
,  p_doc_type             IN  VARCHAR2
,  p_doc_subtype          IN  VARCHAR2
,  p_currency_code_func   IN  VARCHAR2
,  p_min_acct_unit_func   IN  NUMBER
,  p_cur_precision_func   IN  NUMBER
);

PROCEDURE get_main_doc_amts(
   p_action                 IN  VARCHAR2
,  p_doc_type               IN  VARCHAR2
,  p_doc_subtype            IN  VARCHAR2
,  p_ap_reinstated_enc_amt  IN  NUMBER
,  p_ap_cancelled_qty       IN  NUMBER
);

PROCEDURE get_backing_doc_amts(
   p_action               IN  VARCHAR2
,  p_doc_type             IN  VARCHAR2
,  p_doc_subtype          IN  VARCHAR2
,  p_currency_code_func   IN  VARCHAR2
,  p_min_acct_unit_func   IN  NUMBER
,  p_cur_precision_func   IN  NUMBER
,  p_ap_cancelled_qty     IN  NUMBER
,  p_ap_amt_billed_change IN  NUMBER
);

PROCEDURE get_final_amounts(
   p_action                IN  VARCHAR2
,  p_doc_type              IN  VARCHAR2
,  p_doc_subtype           IN  VARCHAR2
,  p_currency_code_func    IN  VARCHAR2
,  p_min_acct_unit_func    IN  NUMBER
,  p_cur_precision_func    IN  NUMBER
,  p_ap_reinstated_enc_amt IN  NUMBER
,  p_is_complex_work_po    IN  BOOLEAN --<Complex Work R12>
);

PROCEDURE round_and_convert_amounts(
   p_action              IN  VARCHAR2
,  p_currency_code_func  IN  VARCHAR2
,  p_min_acct_unit_func  IN  NUMBER
,  p_cur_precision_func  IN  NUMBER
,  p_column_to_use       IN  VARCHAR2
);

PROCEDURE check_backing_pa_amounts(
   p_action        IN   VARCHAR2
);

PROCEDURE correct_backing_pa_amounts(
   p_current_pa_dist_id   IN  NUMBER
,  p_start_row            IN  NUMBER
,  p_end_row              IN  NUMBER
,  p_running_total        IN  NUMBER
,  p_amt_to_enc_func      IN  NUMBER
,  p_unencumbered_amt     IN  NUMBER
,  p_pa_sequence_num_tbl  IN  po_tbl_number
,  p_pa_multiplier_tbl    IN  po_tbl_number
,  x_pa_amount_tbl        IN OUT NOCOPY po_tbl_number
,  x_changed_amounts_flag OUT NOCOPY VARCHAR2
);

--<Complex Work R12 START>
PROCEDURE set_complex_work_req_amounts(
   p_action        IN   VARCHAR2
);

PROCEDURE correct_backing_req_amounts(
  p_req_dist_id           IN NUMBER
, p_max_total_amount      IN NUMBER
, p_current_total_amount  IN NUMBER
);
--<Complex Work R12 END>

PROCEDURE get_gl_references(
   p_action                IN VARCHAR2
,  p_cbc_flag              IN VARCHAR2
,  p_req_encumb_type_id    IN NUMBER
,  p_po_encumb_type_id     IN NUMBER
,  p_invoice_id            IN NUMBER
);

--<SLA R12 added new procedure>
PROCEDURE update_amounts(
  p_action        IN   VARCHAR2,
  p_currency_code_func IN VARCHAR2
);

-------------------------------------------------------------------------------
-- Procedure definitions
-------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_all_distributions
--Pre-reqs:
--  The correct encumbrance should be on for the document type that is
--    being passed.
--  For a non-check only action, if the data has already been populated
--    in the encumbrance table, the headers and distributions should have
--    been locked before the data was loaded into the encumbrance table.
--  For POs with backing GAs, the org context of the PO must be set
--    in order to correctly determine whether or not there needs to
--    be a backing entry for the GA.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  PO_REQUISITION_HEADERS_ALL
--  PO_REQ_DISTRIBUTIONS_ALL
--  PO_HEADERS_ALL
--  PO_RELEASES_ALL
--  PO_DISTRIBUTIONS_ALL
--Function:
--  This procedure populates the global temp table PO_ENCUMBRANCE_GT
--  with all of the information required for each distribution that has any
--  encumbrance impact.
--  It will either retrieve the information from the document tables for
--  the given doc ids or use what has already been populated in the
--  encumbrance table for the main doc.
--  It retrieves backing doc distributions from the transaction tables.
--Parameters:
--IN:
--p_action
--  Specifies the action that is being taken on the document.
--  Use the g_<action> variables (<action> = RESERVE, UNRESERVE, ADJUST, etc.).
--p_check_only_flag
--  Indicates whether or not to lock the main document
--  headers and distributions if given a doc id for the main document,
--  and indicates whether or not to lock the backing distributions
--    g_parameter_NO    lock them
--    g_parameter_YES   don't lock them
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--    MIXED_PO_RELEASE  - supported only for Adjust
--p_doc_subtype
--  The document subtype.  Use the g_doc_subtype_<> variables:
--    STANDARD          Standard PO
--    PLANNED           Planned PO
--    BLANKET           Blanket Release, Blanket Agreement, Global Agreement
--    SCHEDULED         Scheduled Release
--    MIXED_PO_RELEASE  supported only for Adjust
--  This parameter is not checked for requisitions.
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--  If the encumbrance table has already been populated (Adjust), use NULL.
--p_doc_level_id
--  Id of the doc level type on which the action is being taken.
--  If the encumbrance table has already been populated, use NULL.
--p_use_enc_gt_flag
--  Indicates whether or not the data has already been populated
--  in the encumbrance table.
--    g_parameter_NO    remove whatever was in the encumbrance table,
--                         and retrieve the data via the doc ids
--    g_parameter_YES   the main document data has already been populated
--                         in the encumbrance table, so trust that
--p_get_backing_docs_flag
--  Indicates whether to even check if eligible backing docs exist.
--  Certain actions/conditions require that we never operate on backing docs
--  VALUES: g_parameter_YES, g_parameter_NO
--p_ap_budget_account_id
--  Used by the invoice/credit memo cancel actions.  The budget account
--  id we use must be the same as the budget account passed in by AP
--p_possibility_check_flag
--  Used to indicate whether or not this procedure is being used to determine
--  the ability to take an action on the document.
--    g_parameter_NO    not simply a possibility check
--    g_parameter_YES   possibility check only, do not bother
--                         to polish the encumbrance table
--p_cbc_flag
--  Indicates whether or not to process approved rows of a PO/Release
--  during a RESERVE.
--    g_parameter_YES - process the approved rows
--    g_parameter_NO  - ignore approved rows
--OUT:
--x_count
--  The number of rows that were added (or cleaned up, if
--  p_use_enc_gt_flag = YES) to the encumbrance table due to this call.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_all_distributions(
   p_action                         IN             VARCHAR2
,  p_check_only_flag                IN             VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_get_backing_docs_flag          IN             VARCHAR2
,  p_ap_budget_account_id           IN             NUMBER
,  p_possibility_check_flag         IN             VARCHAR2
,  p_cbc_flag                       IN             VARCHAR2
,  x_count                          OUT NOCOPY     NUMBER
)
IS

l_api_name     CONSTANT VARCHAR2(30) := 'GET_ALL_DISTRIBUTIONS';
l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress     VARCHAR2(3) := '000';

l_dist_type    PO_DISTRIBUTIONS_ALL.distribution_type%TYPE;

l_count     NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_check_only_flag',
                      p_check_only_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype', p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id', p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag',
                      p_use_enc_gt_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_get_backing_docs_flag',
                      p_get_backing_docs_flag);
END IF;

l_progress := '010';

-----------------------------------------------------------------
--Algorithm:
--
-- 1. Make sure the GTT is clean.
-- 2. Fill it with entries for the main doc.
-- 3. Fill in the entries for the backing docs.
--
-- Example code flow for Reserve of a Std. PO (header level):
--
-- BEGIN get_all_distributions ->
--
--    initialize_encumbrance_gt
--
--    get_distributions ( main doc ) ->
--
--       populate_encumbrance_gt ( main doc ) ->
--          lock_headers
--          lock_distributions
--          <INSERT INTO PO_ENCUMBRANCE_GT>
--
--       remove_unnecessary_dists
--
--       update_encumbrance_gt ( main doc )
--
--    get_distributions ( backing Reqs ) ->
--
--       lock_backing_distributions ( backing Reqs ) ->
--          lock_distributions
--
--       filter_backing_distributions ( backing Reqs )
--
--       populate_encumbrance_gt ( backing Reqs )
--          <INSERT INTO PO_ENCUMBRANCE_GT>
--
--       update_encumbrance_gt ( backing Reqs )
--
--    get_distributions ( backing GAs ) ->
--
--       lock_backing_distributions ( backing GAs ) ->
--          lock_distributions
--
--       filter_backing_distributions ( backing GAs )
--
--       populate_encumbrance_gt ( backing GAs )
--          <INSERT INTO PO_ENCUMBRANCE_GT>
--
--       update_encumbrance_gt ( backing GAs )
--
-- END get_all_distributions
--
-----------------------------------------------------------------

initialize_encumbrance_gt( p_use_enc_gt_flag => p_use_enc_gt_flag );

l_progress := '020';

derive_dist_from_doc_types(
   p_doc_type => p_doc_type
,  p_doc_subtype => p_doc_subtype
,  x_distribution_type => l_dist_type
);

l_progress := '030';

x_count := 0;

-- Get the main doc distributions.

get_distributions(
   p_action => p_action
,  p_check_only_flag => p_check_only_flag
,  p_distribution_type => l_dist_type
,  p_main_or_backing => g_MAIN
,  p_doc_level => p_doc_level
,  p_doc_level_id => p_doc_level_id
,  p_use_enc_gt_flag => p_use_enc_gt_flag
,  p_ap_budget_account_id => p_ap_budget_account_id
,  p_possibility_check_flag => p_possibility_check_flag
,  p_cbc_flag => p_cbc_flag
,  x_count => l_count
);

l_progress := '040';

x_count := x_count + l_count;

-- Now get the backing distributions.

IF (p_get_backing_docs_flag = g_parameter_YES
   AND l_count > 0)
THEN

   l_progress := '100';

   IF (p_doc_subtype = g_doc_subtype_SCHEDULED) THEN

      -- Scheduled Releases have backing PPOs
      -- The MIXED_PO_RELEASE case is only for Blanket Releases.

      l_progress := '110';

      get_distributions(
         p_action => p_action
      ,  p_check_only_flag => p_check_only_flag
      ,  p_distribution_type => g_dist_type_PLANNED
      ,  p_main_or_backing => g_BACKING
      ,  p_doc_level => NULL
      ,  p_doc_level_id => NULL
      ,  p_use_enc_gt_flag => NULL
      ,  p_ap_budget_account_id => p_ap_budget_account_id
      ,  p_possibility_check_flag => g_parameter_NO
      ,  p_cbc_flag => p_cbc_flag
      ,  x_count => l_count
      );

      l_progress := '120';

      x_count := x_count + l_count;

   ELSE
      l_progress := '130';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'No backing PPOs');
      END IF;
   END IF;

   l_progress := '140';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'req encumbrance'
               ,  PO_DOCUMENT_FUNDS_PVT.g_req_encumbrance_on);
   END IF;

   IF ((p_doc_type IN (g_doc_type_PO , g_doc_type_MIXED_PO_RELEASE)
   --<bug#5079182 START>
        OR  (p_doc_type = g_doc_type_RELEASE and p_doc_subtype = g_doc_subtype_BLANKET)
   --<bug#5079182 END>
       )AND PO_DOCUMENT_FUNDS_PVT.g_req_encumbrance_on)
   THEN

      -- POs, PPOs, and Blanket Releases can have backing Reqs

      l_progress := '150';

      get_distributions(
         p_action => p_action
      ,  p_check_only_flag => p_check_only_flag
      ,  p_distribution_type => g_dist_type_REQUISITION
      ,  p_main_or_backing => g_BACKING
      ,  p_doc_level => NULL
      ,  p_doc_level_id => NULL
      ,  p_use_enc_gt_flag => NULL
      ,  p_ap_budget_account_id => p_ap_budget_account_id
      ,  p_possibility_check_flag => g_parameter_NO
      ,  p_cbc_flag => p_cbc_flag
      ,  x_count => l_count
      );

      l_progress := '160';

      x_count := x_count + l_count;

   ELSE
      l_progress := '170';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'No backing Reqs');
      END IF;
   END IF;

   l_progress := '200';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'pa encumbrance'
               ,  PO_DOCUMENT_FUNDS_PVT.g_pa_encumbrance_on);
   END IF;

   IF (  p_doc_subtype IN (  g_doc_subtype_STANDARD,g_doc_subtype_BLANKET
                           ,  g_doc_subtype_MIXED_PO_RELEASE)
         AND PO_DOCUMENT_FUNDS_PVT.g_pa_encumbrance_on
      )
   THEN

      -- POs and Blanket Releases can have backing GAs/BPAs

      l_progress := '210';

      get_distributions(
         p_action => p_action
      ,  p_check_only_flag => p_check_only_flag
      ,  p_distribution_type => g_dist_type_AGREEMENT
      ,  p_main_or_backing => g_BACKING
      ,  p_doc_level => NULL
      ,  p_doc_level_id => NULL
      ,  p_use_enc_gt_flag => NULL
      ,  p_ap_budget_account_id => p_ap_budget_account_id
      ,  p_possibility_check_flag => g_parameter_NO
      ,  p_cbc_flag => p_cbc_flag
      ,  x_count => l_count
      );

      l_progress := '220';

      x_count := x_count + l_count;

   ELSE
      l_progress := '230';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'No backing BPAs/GAs');
      END IF;
   END IF;

   l_progress := '270';

ELSE
   l_progress := '290';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Do not get backing docs');
   END IF;
END IF; -- if backing doc flag is Yes

l_progress := '990';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_count',x_count);
   PO_DEBUG.debug_end(l_log_head);
END IF;


EXCEPTION
WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END get_all_distributions;




-------------------------------------------------------------------------------
--Start of Comments
--Name: initialize_encumbrance_gt
--Pre-reqs:
--  None.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  Cleans the encumbrance table for use.
--Parameters:
--IN:
--p_use_enc_gt_flag
--  Indicates whether or not data has already been populated
--  in the encumbrance table for the main doc.
--    g_parameter_NO    delete everything from the encumbrance table
--    g_parameter_YES   main doc data has already been populated
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE initialize_encumbrance_gt(
   p_use_enc_gt_flag                IN             VARCHAR2
)
IS

l_api_name  CONSTANT VARCHAR2(30) := 'INITIALIZE_ENCUMBRANCE_GT';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress  VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag', p_use_enc_gt_flag);
END IF;

l_progress := '010';

IF (p_use_enc_gt_flag = g_parameter_NO) THEN

   l_progress := '020';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Truncating PO_ENCUMBRANCE_GT');
   END IF;

   -- If we shouldn't be using whatever was in the encumbrance table,
   -- get rid of all of it.

   delete_encumbrance_gt();

   l_progress := '030';

ELSIF (p_use_enc_gt_flag = g_parameter_YES) THEN

   l_progress := '040';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows,NULL,'PO');
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Cleaning PO_ENCUMBRANCE_GT');
   END IF;

   -- If we are trusting the data in the encumbrance table,
   -- we need to make sure that we have our own keys into it.

   UPDATE PO_ENCUMBRANCE_GT
   SET
      sequence_num = NULL
   ,  origin_sequence_num = NULL
   ;

   l_progress := '050';

ELSE
   l_progress := '060';
   RAISE PO_CORE_S.g_INVALID_CALL_EXC;
END IF;

l_progress := '070';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION

WHEN PO_CORE_S.G_INVALID_CALL_EXC THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   FND_MESSAGE.set_name('PO', 'PO_ALL_INVALID_PARAMETER');
   FND_MESSAGE.set_token('PROCEDURE', l_api_name);
   FND_MESSAGE.set_token('PACKAGE', g_pkg_name);
   fnd_msg_pub.add;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END initialize_encumbrance_gt;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_distributions
--Pre-reqs:
--  This procedure assumes that the appropriate encumbrance is on for
--    the document type.
--  For POs with backing GAs, the org context of the PO must be set
--    in order to correctly determine whether or not there needs to
--    be a backing entry for the GA.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  PO_REQUISITION_HEADERS_ALL
--  PO_REQ_DISTRIBUTIONS_ALL
--  PO_HEADERS_ALL
--  PO_RELEASES_ALL
--  PO_DISTRIBUTIONS_ALL
--Function:
--  Populate the encumbrance table with whatever data is necessary for
--  main or backing documents.  This procedure retrieves distributions
--  that should be acted upon, and retrieves prevent encumbrance
--  distributions for main documents for error reporting.
--  It polishes the data in the encumbrance table, even if the
--  data was already populated for the main document,
--  to prepare it for the rest of the encumbrance flow.
--Parameters:
--IN:
--p_action
--  Specifies the action that is being taken on the document.
--  Use the g_<action> variables (<action> = RESERVE, UNRESERVE, ADJUST, etc.).
--p_check_only_flag
--  Indicates whether or not to lock the main document
--  headers and distributions if given a doc id for the main document,
--  and indicates whether or not to lock the backing distributions
--    g_parameter_NO    lock them
--    g_parameter_YES   don't lock them
--p_distribution_type
--  Indicates the type of document to be retrieving data about.
--  Use the g_dist_type_<> variables, which map to the distribution_type
--  column, except for the following:
--    REQUISITION       for requisitions
--    MIXED_PO_RELEASE  supported only for Adjust
--p_main_or_backing
--  Indicates whether this is being called to retrieve the main
--  doc distributions or backing doc distributions of the distribution type
--    g_MAIN / g_BACKING
--p_doc_level
--  The type of ids for the main doc that are being passed. Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--  If the encumbrance table has already been populated
--    for the main doc, use NULL.
--  For backing docs, use NULL.
--p_doc_level_id
--  Id of the main doc level type on which the action is being taken.
--  If the encumbrance table has already been populated
--    for the main doc, use NULL.
--  For backing docs, use NULL.
--p_use_enc_gt_flag
--  Indicates whether or not the data has already been populated
--  in the encumbrance table for the main doc.
--    g_parameter_NO    retrieve the data via the doc ids
--    g_parameter_YES   trust the data that has already been populated
--p_ap_budget_account_id
--  Used by the invoice/credit memo cancel actions.  The budget account
--  id we use must be the same as the budget account passed in by AP
--  For backing docs, use NULL.
--p_possibility_check_flag
--  Used to indicate whether or not this procedure is being used to determine
--  the ability to take an action on the document.
--    g_parameter_NO    not simply a possibility check
--    g_parameter_YES   possibility check only, do not bother
--                         to polish the encumbrance table
--p_cbc_flag
--  Indicates whether or not to process approved rows of a PO/Release
--  during a RESERVE.
--    g_parameter_YES - process the approved rows
--    g_parameter_NO  - ignore approved rows
--OUT:
--x_count
--  The number of rows that were added (or cleaned up, if
--  p_use_enc_gt_flag = YES) to the encumbrance table due to this call.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_distributions(
   p_action                         IN             VARCHAR2
,  p_check_only_flag                IN             VARCHAR2
,  p_distribution_type              IN             VARCHAR2
,  p_main_or_backing                IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_ap_budget_account_id           IN             NUMBER
,  p_possibility_check_flag         IN             VARCHAR2
,  p_cbc_flag                       IN             VARCHAR2
,  x_count                          OUT NOCOPY     NUMBER
)
IS

l_api_name     CONSTANT VARCHAR2(30) := 'GET_DISTRIBUTIONS';
l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress     VARCHAR2(3) := '000';

l_doc_level_id_tbl    po_tbl_number;
l_origin_seq_num_tbl    po_tbl_number;

l_return_status   VARCHAR2(1);
l_doc_type     PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_doc_subtype  PO_HEADERS_ALL.type_lookup_code%TYPE;
l_doc_level    VARCHAR2(25);
l_check_only_flag    VARCHAR2(1);

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_check_only_flag', p_check_only_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_distribution_type',p_distribution_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_main_or_backing',p_main_or_backing);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id', p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag', p_use_enc_gt_flag);
END IF;

l_progress := '010';

-----------------------------------------------------------------
--Algorithm:
--
-- For Main documents:
--
--    IF the GTT is being used for the main doc then
--       0- assume that the documents in the GTT have already been
--             locked if necessary
--       1- delete rows that we don't care about
--             (cancelled, finally closed, etc.)
--       2- fix all of the data that we need
--             (sequence_num, agreement_dist_id, ...)
--
--    ELSE a doc_level_id is passed in for us to act on, so
--       -  fill the GTT with the distributions of the doc
--             using populate(), which will also lock them if necessary
--       -  continue with 1- and 2- from above
--
-- For Backing documents:
--    -  Lock all of the distributions referenced by the main doc
--          in the GTT (if necessary)
--    -  Pick out the ones we care about
--    -  Fill the GTT with these backing distributions
--    -  fix all of the data that we need adjusted
--          (sequence_num, origin_sequence_num, ...)
--
-----------------------------------------------------------------

IF (p_main_or_backing = g_BACKING
   OR p_use_enc_gt_flag = g_parameter_NO)
THEN

   -- Callers may populate the table with data for the main document(s).
   -- For backing documents, we always retrieve the data.

   l_progress := '020';

   derive_doc_types_from_dist(
      p_distribution_type => p_distribution_type
   ,  x_doc_type => l_doc_type
   ,  x_doc_subtype => l_doc_subtype
   );

   l_progress := '030';

   IF (p_main_or_backing = g_BACKING) THEN

      l_progress := '100';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'backing call');
      END IF;

      IF (p_check_only_flag = g_parameter_NO) THEN

         l_progress := '110';

         lock_backing_distributions(p_distribution_type => p_distribution_type);

         -- For new req distributions of Cancel with recreate demand,
         -- the recreated req distributions don't get locked.
         -- But this is okay, as the caller has these rows locked, as
         -- they have just been created.

         l_progress := '120';

      ELSE
         l_progress := '130';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'check only');
         END IF;
      END IF;

      -- We have already locked the backing distributions,
      -- and we don't want populate_encumbrance_gt to lock
      -- the backing headers.

      l_progress := '140';

      l_check_only_flag := g_parameter_YES;

      -- Retrieve the dist ids of the rows you want to do something with.

      filter_backing_distributions(
         p_action => p_action
      ,  p_distribution_type => p_distribution_type
      ,  x_dist_id_tbl => l_doc_level_id_tbl
      ,  x_origin_seq_num_tbl => l_origin_seq_num_tbl
      );

      l_progress := '150';

      l_doc_level := g_doc_level_DISTRIBUTION;

   ELSIF (p_main_or_backing = g_MAIN) THEN

      -- Main doc distributions are locked in populate_encumbrance_gt,
      -- so no need to lock here.

      l_progress := '170';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'main call');
      END IF;

      l_check_only_flag := p_check_only_flag;

      l_doc_level_id_tbl := po_tbl_number( p_doc_level_id );

      l_doc_level := p_doc_level;

   ELSE
      l_progress := '190';
      RAISE PO_CORE_S.g_INVALID_CALL_EXC;
   END IF;

   l_progress := '200';

   -- Fill the GTT with the data from the doc tables.

   PO_DOCUMENT_FUNDS_PVT.populate_encumbrance_gt(
      x_return_status => l_return_status
   ,  p_doc_type => l_doc_type
   ,  p_doc_level => l_doc_level
   ,  p_doc_level_id_tbl => l_doc_level_id_tbl
   ,  p_adjustment_status_tbl => po_tbl_varchar5( NULL )
   ,  p_check_only_flag => l_check_only_flag
   );

   l_progress := '250';

   IF l_return_status IN (FND_API.G_RET_STS_UNEXP_ERROR,
                          FND_API.G_RET_STS_ERROR) THEN
      RAISE G_POPULATE_ENC_GT_EXC;
   END IF;

ELSE
   l_progress := '290';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'using table data');
   END IF;
END IF;

l_progress := '300';

IF (p_main_or_backing = g_MAIN) THEN

   l_progress := '310';

   -- Delete the unwanted dists (cancelled, finally closed, etc.).

   remove_unnecessary_dists(
      p_action    => p_action
   ,  p_cbc_flag  => p_cbc_flag
   );

   l_progress := '350';

ELSE
   l_progress := '370';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'backing');
   END IF;
END IF;

l_progress := '400';

-- Finish preparing the GTT by populating sequence_num, etc.
-- If this is only a possibility check, we can skip this step,
-- and instead just return the number of rows we would have updated.

IF (p_possibility_check_flag = g_parameter_YES) THEN

   l_progress := '410';

   SELECT COUNT(*)
   INTO x_count
   FROM PO_ENCUMBRANCE_GT ENC
   WHERE ENC.sequence_num IS NULL
   ;

   l_progress := '420';

ELSE

   l_progress := '450';

   update_encumbrance_gt(
      p_action => p_action
   ,  p_distribution_type => p_distribution_type
   ,  p_main_or_backing => p_main_or_backing
   ,  p_origin_seq_num_tbl => l_origin_seq_num_tbl
   ,  p_backing_dist_id_tbl => l_doc_level_id_tbl
   ,  p_ap_budget_account_id => p_ap_budget_account_id
   ,  x_count => x_count
   );

   l_progress := '460';

END IF;

l_progress := '990';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_count',x_count);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION

WHEN G_POPULATE_ENC_GT_EXC THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   -- populate_enc_gt should have left its error msg on the stack
   -- no further action required
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

WHEN PO_CORE_S.G_INVALID_CALL_EXC THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   FND_MESSAGE.set_name('PO', 'PO_ALL_INVALID_PARAMETER');
   FND_MESSAGE.set_token('PROCEDURE', l_api_name);
   FND_MESSAGE.set_token('PACKAGE', g_pkg_name);
   fnd_msg_pub.add;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END get_distributions;



-------------------------------------------------------------------------------
--Start of Comments
--Name: remove_unnecessary_dists
--Pre-reqs:
--  The encumbrance table has been populated only with main doc data.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  For the given action, removes any rows that aren't relevant to the
--  encumbrance activity on a main document.
--Parameters:
--IN:
--p_action
--  Specifies the action that is being taken on the main document.
--  Use the g_<action> variables (<action> = RESERVE, UNRESERVE, ADJUST, etc.).
--p_cbc_flag
--  Indicates whether or not to keep approved rows of a PO/Release
--  during a RESERVE
--    g_parameter_YES - do not remove approved rows
--    g_parameter_NO  - remove approved rows
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE remove_unnecessary_dists(
   p_action                         IN             VARCHAR2
,  p_cbc_flag                       IN             VARCHAR2
)
IS

l_api_name  CONSTANT VARCHAR2(30) := 'REMOVE_UNNECESSARY_DISTS';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress  VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
END IF;

l_progress := '010';

-- Remove any entries that have no encumbrance impact.
-- Keep the other prevent encumbrance rows, as they need to be reported.

DELETE FROM PO_ENCUMBRANCE_GT ENC
WHERE
   -- Delete already encumbered rows for Reserve, FC
   -- Bug 3364450: also delete enc rows for INV Cancel

   -- <13503748: Edit without unreserve ER START>
   -- for reserve action delete only those records which have encumbered
   -- flag as 'Y' and amount_changed_flag as 'N'
   ( p_action = g_action_RESERVE
     AND NVL(ENC.encumbered_flag,'N') = 'Y'
     AND Nvl(ENC.amount_changed_flag,'N') = 'N')
    -- <13503748 END>
-- Bug16208745 Those distributions
-- modified with 'Change Amount' action should
-- not be considered for UNRESERVE action
OR ( p_action = g_action_UNRESERVE
     AND Nvl(ENC.amount_changed_flag,'N') = 'Y')

OR ( p_action IN ( g_action_UNDO_FINAL_CLOSE
                 , g_action_INVOICE_CANCEL
                 , g_action_CR_MEMO_CANCEL)
     AND NVL(ENC.encumbered_flag,'N') = 'Y' )

   -- Delete already unencumbered rows for reversal actions
   -- Bug 3402031: Allow all unencumbered rows for FINAL CLOSE action
   -- Later, only rows unenc due to cancellation are kept for FINAL CLOSE.
OR (  p_action NOT IN ( g_action_RESERVE
                      , g_action_UNDO_FINAL_CLOSE
                      , g_action_ADJUST
                      , g_action_INVOICE_CANCEL
                      , g_action_CR_MEMO_CANCEL
                      , g_action_FINAL_CLOSE)
      AND NVL(ENC.encumbered_flag,'N') = 'N' )

   -- Delete all cancelled rows unless action is Final Close
   -- But 3477327: also keep cancelled rows for INV CANCEL
OR ( p_action NOT IN ( g_action_FINAL_CLOSE
                     , g_action_INVOICE_CANCEL
                     , g_action_CR_MEMO_CANCEL)
     AND  NVL(ENC.cancel_flag,'N') = 'Y'
   )

   -- Bug 3477327: For Inv/Cr Memo Cancel, now delete cancelled
   -- rows unless they are ALSO finally closed rows
OR ( p_action IN (g_action_INVOICE_CANCEL, g_action_CR_MEMO_CANCEL)
     AND NVL(ENC.cancel_flag, 'N') = 'Y'
     AND NVL(ENC.closed_code, g_clsd_OPEN) <> g_clsd_FINALLY_CLOSED
   )

   -- Delete all FC'ed rows unless action is INV Cancel, Undo FC
OR ( NVL(ENC.closed_code, g_clsd_OPEN) = g_clsd_FINALLY_CLOSED
     AND p_action NOT IN ( g_action_INVOICE_CANCEL
                         , g_action_CR_MEMO_CANCEL
                         , g_action_UNDO_FINAL_CLOSE)
   )

   -- Bug 3402031: Delete unencumbered rows during FINAL CLOSE if
   -- a CANCEL action has not been taken.
   -- Bug 5115105: only keep Cancelled rows for POs/Releases
   -- If the cancelled row belongs to a requisition then delete it.

OR (  p_action = g_action_FINAL_CLOSE
      AND (
             (ENC.distribution_type=g_dist_type_REQUISITION
                AND NVL(ENC.cancel_flag, 'N') = 'Y')
             OR
               NVL(ENC.cancel_flag, 'N') = 'N'
          )
      and NVL(ENC.encumbered_flag, 'N') = 'N')

   --Exclude certain Req distributions
OR (  ENC.distribution_type = g_dist_type_REQUISITION
   AND   (  ENC.line_location_id IS NOT NULL
      OR (  p_action IN (  g_action_RESERVE, g_action_UNRESERVE
                        ,  g_action_REJECT  --, g_action_ADJUST  Donot delete for Adjust action since will be used for IR ISO ER
                        )
         AND   ENC.transferred_to_oe_flag = 'Y'
         AND   ENC.source_type_code = g_src_INVENTORY
         )
      OR (  p_action = g_action_RETURN
         AND   ENC.source_type_code = g_src_INVENTORY
         )
      --bug 3537764: exclude parent Req dists that have already
      --been split in Req Split from any further Enc action
      OR ( ENC.prevent_encumbrance_flag = 'Y'
           AND ENC.modified_by_agent_flag = 'Y'
         )
      )
   )

   --Exclude BPAs that are not encumbered
OR (  ENC.distribution_type = g_dist_type_AGREEMENT
   AND   NVL(ENC.encumbrance_required_flag,'N') = 'N'
   )

   --Exclude certain PO/Rel distributions
   -- Bug 3391282: We cannot drop distributions that come from
   -- shipments with approved_flag = 'Y' for the reserve action,
   -- as we were previously doing to avoid some user warnings.
   -- That is because PDOI and CBC both expect that they can
   -- call reserve with approved_flag already set to 'Y'.
   -- A workaround for the warnings, as explained in the bug,
   -- is to drop only those distributions that are both approved
   -- and have prevent encumbrance flag = 'Y'.
OR (  ENC.distribution_type IN
      (  g_dist_type_STANDARD, g_dist_type_PLANNED,
         g_dist_type_SCHEDULED, g_dist_type_BLANKET )
   AND ENC.approved_flag = 'Y'
   AND ( p_action = g_action_REJECT
	 or
         (p_action = g_action_RESERVE
     and p_cbc_flag = g_parameter_NO
	  and ENC.prevent_encumbrance_flag = 'Y'
         )
       )
   )
;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'Number of rows deleted', SQL%ROWCOUNT);
END IF;



IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION

WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END remove_unnecessary_dists;



-------------------------------------------------------------------------------
--Start of Comments
--Name: update_encumbrance_gt
--Pre-reqs:
--  For POs with backing GAs, the org context of the PO must be set
--    in order to correctly determine whether or not there needs to
--    be a backing entry for the GA.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  Polishes the data in the encumbrance table.
--  Prepares the data in the table for use by the rest of the encumbrance
--  flow.
--Parameters:
--IN:
--p_distribution_type
--  Indicates the type rows to update in the encumbrance table.
--  Use the g_dist_type_<> variables, which map to the distribution_type
--  column, except for the following:
--    REQUISITION       for requisitions
--    MIXED_PO_RELEASE  supported only for Adjust
--p_main_or_backing
--  Indicates whether this is being called to polish main doc data
--  or backing doc data.
--    g_MAIN / g_BACKING
--p_origin_seq_num_tbl
--  For backing distributions, the sequence_num of the main distribution.
--  NULL for main doc use.
--p_backing_dist_id_tbl
--  The distribution id of the backing distribution that corresponds to
--  the origin_seq_num entry.
--  NULL for main doc use.
--p_ap_budget_account_id
--  Used by the invoice/credit memo cancel actions.  The budget account
--  id we use must be the same as the budget account passed in by AP
--
--OUT:
--x_count
--  The number of rows that were updated by this procedure.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE update_encumbrance_gt(
   p_action                         IN             VARCHAR2
,  p_distribution_type              IN             VARCHAR2
,  p_main_or_backing                IN             VARCHAR2
,  p_origin_seq_num_tbl             IN             po_tbl_number
,  p_backing_dist_id_tbl            IN             po_tbl_number
,  p_ap_budget_account_id           IN             NUMBER
,  x_count                          OUT NOCOPY     NUMBER
)
IS

l_api_name  CONSTANT VARCHAR2(30) := 'UPDATE_ENCUMBRANCE_GT';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head|| l_api_name;
l_progress  VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_distribution_type',p_distribution_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_main_or_backing',p_main_or_backing);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_origin_seq_num_tbl'
            ,p_origin_seq_num_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_backing_dist_id_tbl'
            ,p_backing_dist_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_ap_budget_account_id'
            ,p_ap_budget_account_id);
END IF;

l_progress := '010';


-- Clean up the inputs columns to make future calculations easier,
-- and derive other column values needed for calculations.

UPDATE PO_ENCUMBRANCE_GT ENC
SET

-- input columns
   ENC.unencumbered_amount = NVL(ENC.unencumbered_amount,0)
,  ENC.encumbered_amount = NVL(ENC.encumbered_amount,0)
,  ENC.amount_delivered = NVL(ENC.amount_delivered,0)
,  ENC.amount_billed = NVL(ENC.amount_billed,0)
,  ENC.amount_cancelled = NVL(ENC.amount_cancelled,0)
,  ENC.unencumbered_quantity = NVL(ENC.unencumbered_quantity,0)
,  ENC.quantity_delivered = NVL(ENC.quantity_delivered,0)
,  ENC.quantity_billed = NVL(ENC.quantity_billed,0)
,  ENC.quantity_cancelled = NVL(ENC.quantity_cancelled,0)
,  ENC.nonrecoverable_tax = NVL(ENC.nonrecoverable_tax,0)
,  ENC.rate = NVL(ENC.rate,1)
,  ENC.prevent_encumbrance_flag = NVL(ENC.prevent_encumbrance_flag,'N')
-- bug 3537764: add modified_by_agent_flag to temp table
,  ENC.modified_by_agent_flag = NVL(ENC.modified_by_agent_flag, 'N')

-- calculation columns
,  ENC.amount_based_flag =
     DECODE( ENC.value_basis  --<Complex Work R12>: use POLL value basis
           , g_order_type_FIXED_PRICE, 'Y'
           , g_order_type_RATE, 'Y'
           , 'N'
     )
   --bug 356812: no prevent enc lines are sent to GL
,  ENC.send_to_gl_flag = DECODE( ENC.prevent_encumbrance_flag
                               , 'Y', 'N'
                               ,      'Y'
                         )
WHERE ENC.sequence_num IS NULL
;

l_progress := '100';

-- Fill in the minimum accountable unit and precision for foreign currencies.
-- We probably don't need to do this for the functional currency rows.

UPDATE PO_ENCUMBRANCE_GT ENC
SET
(  ENC.min_acct_unit_foreign
,  ENC.cur_precision_foreign
)
=
(  SELECT
      CUR.minimum_accountable_unit
   ,  CUR.precision
   FROM
      FND_CURRENCIES CUR
   WHERE CUR.currency_code = ENC.currency_code
)
WHERE ENC.sequence_num IS NULL
AND   ENC.prevent_encumbrance_flag = 'N'
;

l_progress := '180';

-- Fill in the sequence_num.
-- Do this for prevent rows as well, for error reporting.

UPDATE PO_ENCUMBRANCE_GT ENC
SET   ENC.sequence_num = PO_ENCUMBRANCE_GT_S.nextval
WHERE ENC.sequence_num IS NULL
;

l_progress := '190';

-- Count the number of rows that had a NULL sequence_num before this
-- procedure, as that is how many rows would have been updated by
-- this call.

x_count := SQL%ROWCOUNT;

-- Since we do not have source_distribution_id of POs/Blanket Releases
-- point to the GA/BPA distribution, we need to fix this.

-- Retrieve the backing GA distribution reference.
--
-- Currently, POs have encumbrance effect on a GA only if they
-- are in the same org.
-- We are assuming here that the org context has been set to
-- the org of the document that is being acted upon
-- (i.e., the org of the PO).

IF (p_main_or_backing = g_MAIN
   AND p_distribution_type IN
         (g_dist_type_STANDARD, g_dist_type_MIXED_PO_RELEASE))
THEN

   l_progress := '200';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'updating GA dist_id');
   END IF;

   UPDATE PO_ENCUMBRANCE_GT PO_DIST
   SET PO_DIST.agreement_dist_id =
   (  SELECT GA_DIST.po_distribution_id
      FROM PO_DISTRIBUTIONS GA_DIST
      WHERE GA_DIST.po_header_id = PO_DIST.from_header_id
   )
   WHERE PO_DIST.distribution_type = g_dist_type_STANDARD
   AND PO_DIST.prevent_encumbrance_flag = 'N'
   ;

   l_progress := '210';

ELSE
   l_progress := '250';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'no GAs');
   END IF;
END IF;

l_progress := '290';

-- Retrieve the backing BPA distribution reference.

IF (p_main_or_backing = g_MAIN
   AND p_distribution_type IN
         (g_dist_type_BLANKET, g_dist_type_MIXED_PO_RELEASE))
THEN

   l_progress := '300';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'updating BPA dist ids');
   END IF;

   UPDATE PO_ENCUMBRANCE_GT REL_DIST
   SET REL_DIST.agreement_dist_id =
   (  SELECT BPA_DIST.po_distribution_id
      FROM PO_DISTRIBUTIONS_ALL BPA_DIST
      WHERE BPA_DIST.po_header_id = REL_DIST.header_id
      AND BPA_DIST.distribution_type = g_dist_type_AGREEMENT
      -- we don't want release distributions here.
   )
   WHERE REL_DIST.distribution_type = g_dist_type_BLANKET
   AND REL_DIST.prevent_encumbrance_flag = 'N'
   ;

   l_progress := '310';

ELSE
   l_progress := '350';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'no BPAs');
   END IF;
END IF;

l_progress := '400';

-- For backing docs, we need to put in the reference to the main doc row.

IF (p_main_or_backing = g_BACKING) THEN

   l_progress := '410';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'updating backing link');
   END IF;

   FORALL i IN 1 .. p_origin_seq_num_tbl.COUNT
   UPDATE PO_ENCUMBRANCE_GT BACKING
   SET BACKING.origin_sequence_num = p_origin_seq_num_tbl(i)
   WHERE BACKING.distribution_id = p_backing_dist_id_tbl(i)
   AND BACKING.distribution_type = p_distribution_type
   AND BACKING.origin_sequence_num IS NULL
   AND rownum = 1
   ;
   -- the rownum = 1 is required so that each backing dist
   -- with the same id (think backing BPA) gets a different
   -- origin_sequence_num.

   IF p_action NOT IN (g_action_INVOICE_CANCEL, g_action_CR_MEMO_CANCEL) THEN

      l_progress := '420';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'updating send to GL flag');
      END IF;

      --bug 3568512: do not send Unreserved backing BPA/PPO lines to GL; we
      --only keep them in the GTT to maintain the unencumbered_amount column
      --Invoice Cancel is excluded b/c it has a different set of conditions
      --for backing docs in the filter_backing_distributions code
      UPDATE PO_ENCUMBRANCE_GT BACKING
      SET BACKING.send_to_gl_flag = 'N'
      ,   BACKING.update_encumbered_amount_flag = 'N'
      WHERE BACKING.origin_sequence_num IS NOT NULL  --backing doc
      AND BACKING.encumbered_flag = 'N'
      AND BACKING.distribution_type IN
          (g_dist_type_AGREEMENT, g_dist_type_PLANNED)
      ;
   END IF; -- action is Invoice Cancel

   l_progress := '430';

ELSE
   l_progress := '450';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not backing');
   END IF;
END IF;

l_progress := '500';


-- For AP Invoice/Credit memo Cancel, we use the budget account
-- passed in by AP for the main document
IF (p_action IN (g_action_INVOICE_CANCEL, g_action_CR_MEMO_CANCEL)
   AND p_main_or_backing = g_MAIN) THEN

   UPDATE PO_ENCUMBRANCE_GT MAINDOC
   SET MAINDOC.budget_account_id = p_ap_budget_account_id
   WHERE MAINDOC.origin_sequence_num IS NULL;

END IF;

l_progress := '600';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_count',x_count);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION

WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END update_encumbrance_gt;



-------------------------------------------------------------------------------
--Start of Comments
--Name: lock_backing_distributions
--Pre-reqs:
--  The backing distribution references have been populated
--  in the encumbrance table.
--Modifies:
--  None.
--Locks:
--  PO_DISTRIBUTIONS_ALL
--  PO_REQ_DISTRIBUTIONS_ALL
--Function:
--  Locks all of the backing distributions of the given type that are
--  referenced by main doc rows in the encumbrance table.
--Parameters:
--IN:
--p_distribution_type
--  The type of distribution to be locking.  Use g_dist_type_<>:
--    PLANNED        PPOs
--    AGREEMENT      BPAs/GAs
--    REQUISITION    Reqs
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE lock_backing_distributions(
   p_distribution_type              IN             VARCHAR2
)
IS

l_api_name  CONSTANT VARCHAR2(30) := 'LOCK_BACKING_DISTRIBUTIONS';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress  VARCHAR2(3) := '000';

l_distribution_id_tbl     po_tbl_number;

l_doc_type     PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_doc_subtype  PO_HEADERS_ALL.type_lookup_code%TYPE;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_distribution_type',p_distribution_type);
END IF;

l_progress := '010';

-- Get the backing distribution ids from the main docs in the GTT.

IF (p_distribution_type = g_dist_type_REQUISITION) THEN

   l_progress := '020';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'requisitions');
   END IF;

   SELECT DISTS.req_distribution_id
   BULK COLLECT INTO l_distribution_id_tbl
   FROM PO_ENCUMBRANCE_GT DISTS
   WHERE DISTS.req_distribution_id IS NOT NULL
   AND DISTS.origin_sequence_num IS NULL
   AND DISTS.prevent_encumbrance_flag = 'N'
   ;

   l_progress := '030';

ELSIF (p_distribution_type = g_dist_type_PLANNED) THEN

   l_progress := '040';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'PPOs');
   END IF;

   SELECT DISTS.source_distribution_id
   BULK COLLECT INTO l_distribution_id_tbl
   FROM PO_ENCUMBRANCE_GT DISTS
   WHERE DISTS.source_distribution_id IS NOT NULL
   AND DISTS.origin_sequence_num IS NULL
   AND DISTS.prevent_encumbrance_flag = 'N'
   ;

   l_progress := '050';

ELSIF (p_distribution_type = g_dist_type_AGREEMENT) THEN

   l_progress := '060';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'agreements');
   END IF;

   SELECT DISTS.agreement_dist_id
   BULK COLLECT INTO l_distribution_id_tbl
   FROM PO_ENCUMBRANCE_GT DISTS
   WHERE DISTS.agreement_dist_id IS NOT NULL
   AND DISTS.origin_sequence_num IS NULL
   AND DISTS.prevent_encumbrance_flag = 'N'
   ;

   l_progress := '070';

ELSE
   l_progress := '090';
   RAISE PO_CORE_S.g_INVALID_CALL_EXC;
END IF;

l_progress := '100';

derive_doc_types_from_dist(
   p_distribution_type => p_distribution_type
,  x_doc_type => l_doc_type
,  x_doc_subtype => l_doc_subtype
);

l_progress := '110';

-- Lock those distribution ids.

PO_LOCKS.lock_distributions(
   p_doc_type => l_doc_type
,  p_doc_level => g_doc_level_DISTRIBUTION
,  p_doc_level_id_tbl => l_distribution_id_tbl
);

l_progress := '120';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION

WHEN PO_CORE_S.G_INVALID_CALL_EXC THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   FND_MESSAGE.set_name('PO', 'PO_ALL_INVALID_PARAMETER');
   FND_MESSAGE.set_token('PROCEDURE', l_api_name);
   FND_MESSAGE.set_token('PACKAGE', g_pkg_name);
   fnd_msg_pub.add;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END lock_backing_distributions;



-------------------------------------------------------------------------------
--Start of Comments
--Name: filter_backing_distributions
--Pre-reqs:
--  The encumbrance table has the appropriate references to the backing
--  distributions.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the ids of the distributions that require backing entries
--  due to the action being taken on the main doc, along with the
--  main doc's sequence_num in the encumbrance table in order to provide
--  a mapping.
--Parameters:
--IN:
--p_action
--  Specifies the action that is being taken on the main document.
--  Use the g_<action> variables (<action> = RESERVE, UNRESERVE, ADJUST, etc.).
--p_distribution_type
--  The type of relevant backing distributions to find.  Use g_dist_type_<>:
--    PLANNED        PPOs
--    AGREEMENT      BPAs/GAs
--    REQUISITION    Reqs
--OUT:
--x_dist_id_tbl
--  The ids of distributions that require backing encumbrance entries.
--x_origin_seq_num_tbl
--  The sequence_num of the main doc row for which the distribution is
--  a backing document.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE filter_backing_distributions(
   p_action                         IN             VARCHAR2
,  p_distribution_type              IN             VARCHAR2
,  x_dist_id_tbl                    OUT NOCOPY     po_tbl_number
,  x_origin_seq_num_tbl             OUT NOCOPY     po_tbl_number
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'FILTER_BACKING_DISTRIBUTIONS';
l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress  VARCHAR2(3) := '000';

l_backing_req_key    NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_distribution_type',p_distribution_type);
END IF;

l_progress := '010';

IF (p_distribution_type = g_dist_type_REQUISITION) THEN

   l_progress := '020';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'requisitions');
   END IF;

   ----------------------------------------------------------------
   -- PO_SESSION_GT column mapping
   --
   -- num1     sequence num of original (main) distribution
   -- num2     distribution_id of backing req
   -- num3     recreated req's distribution_id
   ----------------------------------------------------------------

   l_backing_req_key := PO_CORE_S.get_session_gt_nextval();

   l_progress := '030';

   -- Get the encumbrance-impacted req distributions.

   INSERT INTO PO_SESSION_GT
   (  key
   ,  num1  -- main dist's sequence_num
   ,  num2  -- backing req's distribution_id
   )
   SELECT
      l_backing_req_key
   ,  ENC.sequence_num
   ,  PRD.distribution_id
   FROM
      PO_ENCUMBRANCE_GT ENC
   ,  PO_REQUISITION_LINES_ALL PRL
   ,  PO_REQ_DISTRIBUTIONS_ALL PRD
   WHERE PRD.distribution_id = ENC.req_distribution_id  --JOIN
   AND PRL.requisition_line_id = PRD.requisition_line_id  --JOIN
   AND NVL(PRD.prevent_encumbrance_flag,'N') = 'N'
   AND NVL(PRL.closed_code,g_clsd_OPEN) <> g_clsd_FINALLY_CLOSED
   AND NVL(PRL.cancel_flag,'N') = 'N'
   --bug 3401937: backing docs for Invoice Cancel
   AND ( (p_action IN (g_action_RESERVE, g_action_INVOICE_CANCEL,
                       g_action_CR_MEMO_CANCEL)
          AND PRD.encumbered_flag = 'Y')
          -- picks up backing Req for case of PO Unres when Invoice Cancel
       OR
         (p_action NOT IN (g_action_RESERVE, g_action_INVOICE_CANCEL,
                           g_action_CR_MEMO_CANCEL)
          AND NVL(PRD.encumbered_flag,'N') = 'N'
	  --Bug18898767
          AND ENC.amount_changed_flag is null)
          -- for Invoice Cancel, if PO is FC'ed, then backing Req is not
          -- encumbered, but we don't act on the backing Req for this case
   )
   AND ENC.origin_sequence_num IS NULL
   AND ENC.prevent_encumbrance_flag = 'N'
   ;

   l_progress := '040';

   IF (p_action = g_action_CANCEL) THEN

      l_progress := '050';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'cancel w/ recreate demand');
      END IF;

      -- The cancel code operates as follows:
      --
      -- If recreate demand is set to No (i.e., the backing Req is also being
      -- cancelled, so do not re-encumber it), then the backing Req's
      -- PRL.cancel_flag will have been set to 'I' before the encumbrance
      -- code is called, and 'Y' after the encumbrance code is called.
      -- (This happens in poccamodify_req.)
      -- Will have ignored these distributions by the filter on
      -- PRL.cancel_flag above.
      --
      -- If recreate demand is on, then there are 3 possibilities for
      -- the backing Req distribution:
      --
      --    1. The quantity that is being cancelled on the PO is
      --       equal to the quantity that was ordered on the PO.
      --       (i.e., nothing on the PO has been delivered or billed.)
      --       This is the "qty_zero" case of poccamodify_req.
      --       In this case, the old Req is re-used.
      --       We want to re-encumber this old Req.
      --
      --    2. The quantity that has been delivered/billed on the PO is
      --       less than the quantity ordered on the Req.
      --       This is the "qty_cancelled != 0" case of poccamodify_req.
      --       In this case, a new Req line and distribution are created.
      --       The new Req has
      --       NEW_PRD.source_req_distribution_id = OLD_PRD.distribution_id
      --       We want to encumber the new Req.
      --
      --    3. The quantity that has been delivered/billed on the PO is
      --       greater than or equal to the quantity ordered on the Req.
      --       We should treat this case identically to the
      --       case when recreate demand is off.
      --       We do not want to encumber anything in this situation.
      --       Modifications will be made to the cancel code to set the
      --       PRL.cancel_flag = 'Y' for this case, so that we avoid
      --       picking it up in the filter above.
      --
      -- Given the above, the Req distributions we want to encumber are:
      --    a. The Req pointed to by the PO, so long as the Req
      --       does not have the cancel_flag set.
      --       These were gathered above.
      --    b. If the Req distribution from a. has a descendent, then
      --       we should use that distribution instead.
      --

      -- bug 3426141
      -- changed this statement to update num3 instead of updating num2,
      -- as there were difficulties in doing this correctly on 8i.

      UPDATE PO_SESSION_GT SCRATCH
      SET SCRATCH.num3 =
           (  SELECT PRD.distribution_id
              FROM PO_REQ_DISTRIBUTIONS_ALL PRD
              WHERE PRD.source_req_distribution_id = SCRATCH.num2
           )
      WHERE SCRATCH.key = l_backing_req_key
      ;

      l_progress := '060';

   ELSE
      l_progress := '070';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'not cancel');
      END IF;
   END IF;

   l_progress := '080';

   IF g_debug_stmt THEN
      SELECT rowid BULK COLLECT INTO PO_DEBUG.g_rowid_tbl
      FROM PO_SESSION_GT WHERE key = l_backing_req_key ;

      PO_DEBUG.debug_table(l_log_head,l_progress,'PO_SESSION_GT',
            PO_DEBUG.g_rowid_tbl,
            po_tbl_varchar30('key','num1','num2','num3')
            );
   END IF;

   -- Now that we have the correct references in the scratchpad,
   -- get them back into PL/SQL for output.

   -- bug 3426141 -- added the NVL to get recreated Reqs from Cancel

   SELECT
      SCRATCH.num1
   ,  NVL(SCRATCH.num3, SCRATCH.num2)
   BULK COLLECT INTO
      x_origin_seq_num_tbl
   ,  x_dist_id_tbl
   FROM PO_SESSION_GT SCRATCH
   WHERE SCRATCH.key = l_backing_req_key
   ;

   l_progress := '090';

ELSIF (p_distribution_type = g_dist_type_PLANNED) THEN

   l_progress := '100';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'PPOs');
   END IF;

   -- Get the relevant backing PPO distributions of Scheduled Releases.

   SELECT
      POD.po_distribution_id
   ,  SR_DIST.sequence_num
   BULK COLLECT INTO
      x_dist_id_tbl
   ,  x_origin_seq_num_tbl
   FROM
      PO_DISTRIBUTIONS_ALL POD
   ,  PO_LINE_LOCATIONS_ALL POLL
   ,  PO_ENCUMBRANCE_GT SR_DIST
   WHERE POLL.line_location_id = POD.line_location_id   --JOIN
   AND POD.po_distribution_id = SR_DIST.source_distribution_id --JOIN
   AND NVL(POD.prevent_encumbrance_flag,'N') = 'N'
   AND NVL(POLL.closed_code,g_clsd_OPEN) <> g_clsd_FINALLY_CLOSED
   AND NVL(POLL.cancel_flag,'N') = 'N'
   --bug 3401937: backing docs for Invoice Cancel
   AND ( (p_action IN (g_action_INVOICE_CANCEL, g_action_CR_MEMO_CANCEL)
            AND NVL(SR_DIST.closed_code, g_clsd_OPEN) <> g_clsd_FINALLY_CLOSED
            AND POD.encumbered_flag = 'Y'
            --bug 3568512: filter on enc_flag = 'Y' only for Invoice Cancel case
            --for other unreserved backing PPO actions, maitain unencumbered_amount
          )
      OR (p_action NOT IN (g_action_INVOICE_CANCEL, g_action_CR_MEMO_CANCEL))
      )
   AND SR_DIST.origin_sequence_num IS NULL
   AND SR_DIST.prevent_encumbrance_flag = 'N'
   ;

   l_progress := '150';

ELSIF (p_distribution_type = g_dist_type_AGREEMENT) THEN

   l_progress := '200';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'agreements');
   END IF;

   -- Get the backing BPA/GA distributions of Blanket Releases/POs.

   SELECT
      POD.po_distribution_id
   ,  REL_DIST.sequence_num
   BULK COLLECT INTO
      x_dist_id_tbl
   ,  x_origin_seq_num_tbl
   FROM
      PO_DISTRIBUTIONS_ALL POD
   ,  PO_HEADERS_ALL POH
   ,  PO_ENCUMBRANCE_GT REL_DIST
   WHERE POH.po_header_id = POD.po_header_id       --JOIN
   AND POD.po_distribution_id = REL_DIST.agreement_dist_id  --JOIN
   AND NVL(POD.prevent_encumbrance_flag,'N') = 'N'
   AND NVL(POH.closed_code,g_clsd_OPEN) <> g_clsd_FINALLY_CLOSED
   AND NVL(POH.cancel_flag,'N') = 'N'
   AND POH.encumbrance_required_flag = 'Y'
   --bug 3401937: backing docs for Invoice Cancel
   AND ( (p_action IN (g_action_INVOICE_CANCEL, g_action_CR_MEMO_CANCEL)
            AND NVL(REL_DIST.closed_code, g_clsd_OPEN) <> g_clsd_FINALLY_CLOSED
            AND POD.encumbered_flag = 'Y'
            --bug 3568512: filter on enc_flag = 'Y' only for Invoice Cancel case
            --for other unreserved backing PPO actions, maitain unencumbered_amount
          )
      OR (p_action NOT IN (g_action_INVOICE_CANCEL, g_action_CR_MEMO_CANCEL))
      )
   AND REL_DIST.origin_sequence_num IS NULL
   AND REL_DIST.prevent_encumbrance_flag = 'N'
   ;

   l_progress := '250';

ELSE
   l_progress := '300';
   RAISE PO_CORE_S.g_INVALID_CALL_EXC;
END IF;

l_progress := '400';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_dist_id_tbl',x_dist_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_origin_seq_num_tbl',x_origin_seq_num_tbl);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION

WHEN PO_CORE_S.G_INVALID_CALL_EXC THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   FND_MESSAGE.set_name('PO', 'PO_ALL_INVALID_PARAMETER');
   FND_MESSAGE.set_token('PROCEDURE', l_api_name);
   FND_MESSAGE.set_token('PACKAGE', g_pkg_name);
   fnd_msg_pub.add;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END filter_backing_distributions;



-------------------------------------------------------------------------------
--Start of Comments
--Name: derive_doc_types_from_dist
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Derives the document type/subtype given the distribution type.
--Parameters:
--IN:
--p_distribution_type
--  Use the g_dist_type_<> variables, which map to the distribution_type
--  column, except for the following:
--    REQUISITION       for requisitions
--OUT:
--x_doc_type
--  PO_DOCUMENT_TYPES.document_type_code%TYPE
--  Document type.  g_doc_type_<>
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_subtype
--  PO_HEADERS_ALL.type_lookup_code%TYPE
--  PO_RELEASES_ALL.release_type%TYPE
--  The document subtype.  g_doc_subtype_<>
--    STANDARD          Standard PO
--    PLANNED           Planned PO
--    BLANKET           Blanket Release, Blanket Agreement, Global Agreement
--    SCHEDULED         Scheduled Release
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE derive_doc_types_from_dist(
   p_distribution_type              IN             VARCHAR2
,  x_doc_type                       OUT NOCOPY     VARCHAR2
,  x_doc_subtype                    OUT NOCOPY     VARCHAR2
)
IS

l_api_name  CONSTANT VARCHAR2(30) := 'DERIVE_DOC_TYPES_FROM_DIST';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress  VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_distribution_type',p_distribution_type);
END IF;

l_progress := '010';

-- Convert the distribution type into document type and subtype.

IF (p_distribution_type = g_dist_type_REQUISITION) THEN
   x_doc_type := g_doc_type_REQUISITION;
   x_doc_subtype := NULL;
ELSIF (p_distribution_type = g_dist_type_AGREEMENT) THEN
   x_doc_type := g_doc_type_PA;
   x_doc_subtype := g_doc_subtype_BLANKET;
ELSIF (p_distribution_type IN (g_dist_type_BLANKET, g_dist_type_SCHEDULED)) THEN
   x_doc_type := g_doc_type_RELEASE;
   x_doc_subtype := p_distribution_type;
ELSIF (p_distribution_type IN (g_dist_type_STANDARD, g_dist_type_PLANNED)) THEN
   x_doc_type := g_doc_type_PO;
   x_doc_subtype := p_distribution_type;
--<Complex Work R12 START>
ELSIF (p_distribution_type = g_dist_type_PREPAYMENT) THEN
   x_doc_type := g_doc_type_PO;
   x_doc_subtype := g_doc_subtype_STANDARD;
--<Complex Work R12 START>
ELSIF (p_distribution_type = g_dist_type_MIXED_PO_RELEASE) THEN
   x_doc_type := g_doc_type_MIXED_PO_RELEASE;
   x_doc_subtype := g_doc_subtype_MIXED_PO_RELEASE;
ELSE
   RAISE PO_CORE_S.g_INVALID_CALL_EXC;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_doc_type',x_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_doc_subtype',x_doc_subtype);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION

WHEN PO_CORE_S.G_INVALID_CALL_EXC THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   FND_MESSAGE.set_name('PO', 'PO_ALL_INVALID_PARAMETER');
   FND_MESSAGE.set_token('PROCEDURE', l_api_name);
   FND_MESSAGE.set_token('PACKAGE', g_pkg_name);
   fnd_msg_pub.add;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END derive_doc_types_from_dist;



-------------------------------------------------------------------------------
--Start of Comments
--Name: derive_dist_from_doc_types
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Derives the distribution type from the given document type/subtype.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use g_doc_type_<>
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_subtype
--  The document subtype.  g_doc_subtype_<>
--    STANDARD          Standard PO
--    PLANNED           Planned PO
--    BLANKET           Blanket Release, Blanket Agreement, Global Agreement
--    SCHEDULED         Scheduled Release
--  This parameter is not checked for requisitions.
--OUT:
--x_distribution_type
--  PO_DISTRIBUTIONS_ALL.distribution_type%TYPE
--  Use the g_dist_type_<> variables, which map to the distribution_type
--  column, except for the following:
--    REQUISITION       for requisitions
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE derive_dist_from_doc_types(
   p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  x_distribution_type              OUT NOCOPY     VARCHAR2
)
IS

l_api_name  CONSTANT VARCHAR2(30) := 'DERIVE_DIST_FROM_DOC_TYPES';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress  VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype', p_doc_subtype);
END IF;

l_progress := '010';

-- Convert the document type, subtype into distribution type.

IF (p_doc_type = g_doc_type_REQUISITION) THEN
   x_distribution_type := g_dist_type_REQUISITION;
ELSIF (p_doc_type = g_doc_type_PA) THEN
   x_distribution_type := g_dist_type_AGREEMENT;
ELSE
   x_distribution_type := p_doc_subtype;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_distribution_type',x_distribution_type);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION

WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END derive_dist_from_doc_types;




--------------------------------------------------------------------------------
--Start of Comments
--Name: do_encumbrance_validations
--Pre-reqs:
--  The encumbrance table may need to be populated with
--  the appropriate data.
--Modifies:
--  PO_ENCUMBRANCE_GT
--  Submission check tables, online report table
--Locks:
--  PO_HEADERS_ALL
--  PO_RELEASES_ALL
--  PO_REQUISITION_HEADERS_ALL
--Function:
--  Performs the validations necessary in order for an encumbrance
--  action to be taken.
--  Most validation failures will raise an exception from this procedure.
--
--  If PO_ENCUMBRANCE_GT contains ids for this encumbrance action
--  (p_check_only_flag = NO and p_use_enc_gt_flag = YES),
--  the table will be replaced with the data for these ids.
--Parameters:
--IN:
--p_action
--  Specifies the action that is being taken on the document.
--  Use the g_action_<> variables (<> = RESERVE, UNRESERVE, ADJUST, etc.).
--p_check_only_flag
--  Indicates whether or not to lock the document header.
--    g_parameter_NO    lock them
--    g_parameter_YES   don't lock them
--  This flag also controls whether or not to do some validations.
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--    MIXED_PO_RELEASE  - supported only for Adjust
--p_doc_subtype
--  The document subtype.  Use the g_doc_subtype_<> variables:
--    STANDARD          Standard PO
--    PLANNED           Planned PO
--    BLANKET           Blanket Release, Blanket Agreement, Global Agreement
--    SCHEDULED         Scheduled Release
--    MIXED_PO_RELEASE  supported only for Adjust
--  This parameter is not checked for requisitions.
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--  If the encumbrance table has already been populated (Adjust, multiple ids),
--    use NULL.
--p_doc_level_id
--  Id of the doc level type on which the action is being taken.
--  If the encumbrance table has already been populated, use NULL.
--p_use_enc_gt_flag
--  Indicates whether or not the data/ids have already been populated
--  in the encumbrance table.
--    g_parameter_NO    validate the doc_level, doc_level_id
--    g_parameter_YES   validate the data already in the table
--p_validate_document
--  Indicates whether or not to perform the submission checks
--  and particularly useful if the caller already did these checks.
--    g_parameter_NO    skip the checks
--    g_parameter_YES   perform the checks
--p_do_state_check_flag  : Added Bug 3280496
--  Indicates whether or not to permorm the document state checks
--    g_parameter_NO    skip the checks
--    g_parameter_YES   perform the checks
--OUT:
--x_validation_successful_flag
--  Indicates whether or not the encumbrance validations were successful,
--  and the encumbrance action may proceed.
--    g_parameter_NO    validations failed
--    g_parameter_YES   validations succeeded
--x_sub_check_report_id
--  If submission checks were performed, contains the
--  online_report_id for those checks.
--
--Notes:
--
--  bug 3435714:
--
--  The combination of p_check_only_flag and p_use_enc_gt_flag
--  are used to determine if this action is being conducted on multiple ids.
--  e.g., unreserve 2 req lines -- resource finalization/assign contractor.
--
--  There are some bottlenecks in the multiple id scenario,
--  and many things are not supported.
--  What IS supported is do_unreserve for multiple Req lines (same header),
--  and do_reserve for multiple Req lines (same header).
--  The submission checks for Reserve operate at the header level, regardless.
--
--  The action history routine also introduces some limitations,
--  particularly that of everything must belong to the same header.
--    bug 3518116:
--    Req Split is supported for multiple Reqs concurrently (via Sourcing).
--
--Testing:
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE do_encumbrance_validations(
   p_action                         IN             VARCHAR2
,  p_check_only_flag                IN             VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_validate_document              IN             VARCHAR2
,  p_do_state_check_flag            IN             VARCHAR2 -- Bug 3280496
,  x_validation_successful_flag     OUT NOCOPY     VARCHAR2
,  x_sub_check_report_id            OUT NOCOPY     NUMBER
)
IS

l_api_name  CONSTANT VARCHAR2(30) := 'DO_ENCUMBRANCE_VALIDATIONS';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress  VARCHAR2(3) := '000';

l_enc_on    BOOLEAN;

-- bug 3435714
l_doc_level             VARCHAR2(30);
l_doc_level_tbl         po_tbl_varchar30;
l_dist_type_tbl         po_tbl_varchar30;
l_count_tbl             po_tbl_number;
l_doc_type              PO_DOCUMENT_TYPES.document_type_code%TYPE;
l_doc_subtype           PO_HEADERS_ALL.type_lookup_code%TYPE;
l_doc_level_id_tbl      po_tbl_number;
l_id_tbl                po_tbl_number;
l_doc_id                NUMBER;
l_multiple_docs_flag    VARCHAR2(1);

l_sub_check_action      VARCHAR2(4000);
l_msg_data              VARCHAR2(4000);
l_return_status         VARCHAR2(1);
l_sub_check_status      VARCHAR2(1);

l_doc_check_error_record doc_check_Return_Type;

l_doc_state_valid    VARCHAR2(1);

l_exc_code           NUMBER;
l_exc_message_name   FND_NEW_MESSAGES.message_name%TYPE;
l_exc_message_text   FND_NEW_MESSAGES.message_text%TYPE;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_check_only_flag', p_check_only_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype', p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id', p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag', p_use_enc_gt_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validate_document',p_validate_document);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_do_state_check_flag', p_do_state_check_flag);
END IF;

l_progress := '010';

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Check : Is encumbrance on?
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- Set up the global variables
-- for the rest of the encumbrance flow.

PO_DOCUMENT_FUNDS_PVT.g_req_encumbrance_on
   := PO_CORE_S.is_encumbrance_on(
         p_doc_type => g_doc_type_REQUISITION
      ,  p_org_id => NULL
      );

l_progress := '020';

PO_DOCUMENT_FUNDS_PVT.g_po_encumbrance_on
   := PO_CORE_S.is_encumbrance_on(
         p_doc_type => g_doc_type_PO
      ,  p_org_id => NULL
      );

l_progress := '030';

PO_DOCUMENT_FUNDS_PVT.g_pa_encumbrance_on
   := PO_CORE_S.is_encumbrance_on(
         p_doc_type => g_doc_type_PA
      ,  p_org_id => NULL
      );

l_progress := '040';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'req encumbrance'
            ,  PO_DOCUMENT_FUNDS_PVT.g_req_encumbrance_on);
   PO_DEBUG.debug_var(l_log_head,l_progress,'po encumbrance'
            ,  PO_DOCUMENT_FUNDS_PVT.g_po_encumbrance_on);
   PO_DEBUG.debug_var(l_log_head,l_progress,'pa encumbrance'
            ,  PO_DOCUMENT_FUNDS_PVT.g_pa_encumbrance_on);
END IF;

IF (p_doc_type = g_doc_type_REQUISITION) THEN

   l_progress := '050';

   l_enc_on := PO_DOCUMENT_FUNDS_PVT.g_req_encumbrance_on;

ELSIF (p_doc_type = g_doc_type_PA) THEN

   l_progress := '060';

   l_enc_on := PO_DOCUMENT_FUNDS_PVT.g_pa_encumbrance_on;

ELSE

   l_progress := '070';

   l_enc_on := PO_DOCUMENT_FUNDS_PVT.g_po_encumbrance_on;

END IF;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_enc_on',l_enc_on);
END IF;

l_progress := '080';

IF (NOT l_enc_on) THEN

   l_progress := '090';

   l_exc_message_name := 'PO_ENC_NA_OU';
   l_exc_code := g_ENC_VALIDATION_EXC_CODE;
   RAISE FND_API.G_EXC_ERROR;

ELSE
   l_progress := '095';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'encumbrance on');
   END IF;
END IF;

l_progress := '099';


-- bug 3435714 START

IF (p_use_enc_gt_flag = g_parameter_NO) THEN
   l_progress := 'a00';
   l_doc_level := p_doc_level;
   l_doc_level_id_tbl := po_tbl_number( p_doc_level_id );
END IF;

l_progress := 'a10';

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Check:  "do" on multiple ids
--   - doc_level, doc_type must be constant
--     This requirement makes the state checks easier.
--   - additional checks for this scenario (same header_id, etc.)
--     will be done as part of other use_enc_gt_flag = YES checks
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

IF (     p_action NOT IN (g_action_ADJUST, g_action_REQ_SPLIT)
   AND   p_check_only_flag = g_parameter_NO
   AND   p_use_enc_gt_flag = g_parameter_YES
) THEN

   l_progress := 'a20';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'multiple id do action');
      PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT'
         ,PO_DEBUG.g_all_rows
         ,po_tbl_varchar30('distribution_type','doc_level','doc_level_id')
         );
   END IF;

   -- Make sure the doc_level, doc_type are constant.

   SELECT
      ENC.doc_level
   ,  ENC.distribution_type
   ,  COUNT(*)
   BULK COLLECT INTO
      l_doc_level_tbl
   ,  l_dist_type_tbl
   ,  l_count_tbl
   FROM PO_ENCUMBRANCE_GT ENC
   GROUP BY ENC.doc_level, ENC.distribution_type
   ;

   l_progress := 'a30';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_level_tbl',l_doc_level_tbl);
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_dist_type_tbl',l_dist_type_tbl);
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_count_tbl',l_count_tbl);
   END IF;

   IF (l_doc_level_tbl.COUNT <> 1) THEN
      l_progress := 'a35';
      l_exc_code := g_INVALID_CALL_EXC_CODE;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_doc_level := l_doc_level_tbl(1);

   l_progress := 'a40';

   -- Make sure we're not trying to act on the same entity twice.

   SELECT DISTINCT ENC.doc_level_id
   BULK COLLECT INTO l_doc_level_id_tbl
   FROM PO_ENCUMBRANCE_GT ENC
   ;

   l_progress := 'a50';

   IF (l_doc_level_id_tbl.COUNT <> l_count_tbl(1)) THEN
      l_progress := 'a55';
      l_exc_code := g_INVALID_CALL_EXC_CODE;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_progress := 'a60';

   -- After verifying that the ids were reasonable,
   -- we will fill the table with data from the base tables.
   -- Then we can proceed as normal.

   -- We've already gathered the ids from the table, so now
   -- we should clear it for the normal encumbrance flow.
   -- (i.e., DELETE FROM PO_ENCUMBRANCE_GT)

   delete_encumbrance_gt();

   -- Now fill the table up with all of the info.

   l_progress := 'a70';

   derive_doc_types_from_dist(
      p_distribution_type => l_dist_type_tbl(1)
   ,  x_doc_type => l_doc_type
   ,  x_doc_subtype => l_doc_subtype
   );

   l_progress := 'a80';

   PO_DOCUMENT_FUNDS_PVT.populate_encumbrance_gt(
      x_return_status => l_return_status
   ,  p_doc_type => l_doc_type
   ,  p_doc_level => l_doc_level
   ,  p_doc_level_id_tbl => l_doc_level_id_tbl
   ,  p_adjustment_status_tbl => po_tbl_varchar5( NULL )
   ,  p_check_only_flag => g_parameter_NO
   );

   l_progress := 'a90';

END IF;

-- bug 3435714 END

l_progress := '100';


-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Check:  does the BPA/GA have encumbrance_required_flag set?
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- If trying to do something on a BPA/GA,
-- make sure it has a distribution and the header's enc_required is YES.
-- Be careful not to pick up Release distributions.

IF (     p_action <> g_action_ADJUST
   AND   p_doc_type = g_doc_type_PA
   AND   p_check_only_flag = g_parameter_NO
) THEN

   l_progress := '110';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'doc type PA');
   END IF;

   IF (p_use_enc_gt_flag = g_parameter_YES) THEN
      l_doc_id := l_doc_level_id_tbl(1);
   ELSE
      l_doc_id := p_doc_level_id;
   END IF;

   l_progress := '120';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_id',l_doc_id);
   END IF;

   -- actions on PAs only allowed at the header level
   IF (l_doc_level <> g_doc_level_HEADER) THEN
      l_progress := '125';
      l_exc_code := g_INVALID_CALL_EXC_CODE;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_progress := '130';

   SELECT POD.po_distribution_id
   BULK COLLECT INTO l_id_tbl
   FROM
      PO_DISTRIBUTIONS_ALL POD
   ,  PO_HEADERS_ALL POH
   WHERE POD.po_header_id = l_doc_id
   AND   POD.distribution_type = g_dist_type_AGREEMENT
   AND   POH.po_header_id = POD.po_header_id
   AND   POH.encumbrance_required_flag = 'Y'
   ;

   l_progress := '140';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_id_tbl',l_id_tbl);
   END IF;

   IF (l_id_tbl.COUNT <> 1) THEN

      l_progress := '150';

      l_exc_message_name := 'PO_ENC_NA_DOC';
      l_exc_code := g_ENC_VALIDATION_EXC_CODE;
      RAISE FND_API.G_EXC_ERROR;

   ELSE
      l_progress := '160';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'PA valid');
      END IF;
   END IF;

   l_progress := '170';

ELSE
   l_progress := '180';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not PA');
   END IF;
END IF;

l_progress := '200';

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Check:  make sure the encumbrance table is not being used inappropriately
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- Multiple documents are only acceptable for check actions.
-- Reasons for this include submission checks and action history updates.
--    bug 3518116:
--    Req Split supports multiple Reqs concurrently (Sourcing requirement).

IF (     p_action <> g_action_REQ_SPLIT
   AND   p_check_only_flag = g_parameter_NO
   AND   p_use_enc_gt_flag = g_parameter_YES
) THEN

   l_progress := '210';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'validate single doc');
   END IF;

   SELECT DECODE( p_doc_type
               ,  g_doc_type_RELEASE, ENC.po_release_id
               ,  ENC.header_id
               )
   INTO l_doc_id
   FROM PO_ENCUMBRANCE_GT ENC
   WHERE rownum = 1
   ;

   l_progress := '220';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_id',l_doc_id);
   END IF;

   l_multiple_docs_flag := 'N';

   BEGIN

      l_progress := '230';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'checking multiple docs');
      END IF;

      IF (p_doc_type = g_doc_type_RELEASE) THEN

         l_progress := '240';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'checking release');
         END IF;

         SELECT 'Y'
         INTO l_multiple_docs_flag
         FROM PO_ENCUMBRANCE_GT ENC
         WHERE (ENC.po_release_id <> l_doc_id
            OR ENC.po_release_id IS NULL
            )
         AND rownum = 1;

         l_progress := '250';

      ELSE

         l_progress := '260';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'checking non-release');
         END IF;

         SELECT 'Y'
         INTO l_multiple_docs_flag
         FROM PO_ENCUMBRANCE_GT ENC
         WHERE (ENC.header_id <> l_doc_id
            OR ENC.header_id IS NULL
            )
         AND rownum = 1;

         l_progress := '270';

      END IF;

      l_progress := '275';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_multiple_docs_flag',l_multiple_docs_flag);
      END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_multiple_docs_flag := 'N';
   END;

   l_progress := '280';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_multiple_docs_flag',l_multiple_docs_flag);
   END IF;

   IF (l_multiple_docs_flag = 'Y') THEN

      l_progress := '285';

      l_exc_message_name := 'PO_ENC_API_MULTIPLE_DOCS';
      l_exc_code := g_ENC_VALIDATION_EXC_CODE;
      RAISE FND_API.G_EXC_ERROR;

   ELSE
      l_progress := '290';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'no multiple docs');
      END IF;
   END IF;

   l_progress := '295';

ELSE
   l_progress := '299';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not validating single doc');
   END IF;
END IF;

l_progress := '300';


-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Lock the doc header, for non-checks and non-adjust.
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

IF (     p_action NOT IN (g_action_ADJUST, g_action_REQ_SPLIT)
   AND   p_check_only_flag = g_parameter_NO
) THEN

   l_progress := '310';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'locking header');
   END IF;

   IF (p_use_enc_gt_flag = g_parameter_NO) THEN

      l_progress := '320';

      PO_CORE_S.get_document_ids(
         p_doc_type => p_doc_type
      ,  p_doc_level => p_doc_level
      ,  p_doc_level_id_tbl => po_tbl_number( p_doc_level_id )
      ,  x_doc_id_tbl => l_id_tbl
      );

      l_progress := '330';

      l_doc_id := l_id_tbl(1);

   END IF;

   -- If use_enc_gt_flag was YES, we've already retrieved the doc_id.

   l_progress := '340';

   PO_LOCKS.lock_headers(
      p_doc_type => p_doc_type
   ,  p_doc_level => g_doc_level_HEADER
   ,  p_doc_level_id_tbl => po_tbl_number( l_doc_id )
   );

   l_progress := '350';

ELSE
   l_progress := '360';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not locking doc');
   END IF;
END IF;

l_progress := '400';

-- Do the state check before submission check, since it should be quicker.

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Check: document state check (aka. status check)
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- Bug 3280496: Added p_do_state_check condition

IF (     p_check_only_flag = g_parameter_NO
   AND   p_action IN (g_action_RESERVE, g_action_UNRESERVE)
   AND   p_do_state_check_flag <> g_parameter_NO
) THEN

   l_progress := '410';

   -- bug 3435714

   IF (p_use_enc_gt_flag = g_parameter_NO) THEN
      l_doc_type := p_doc_type;
      l_doc_subtype := p_doc_subtype;
   END IF;

   -- If use_enc_gt_flag is YES (do on multiple ids),
   -- the type/subtype have already been set.

   l_progress := '415';

   check_doc_state(
      p_action => p_action
   ,  p_doc_type => l_doc_type
   ,  p_doc_subtype => l_doc_subtype
   ,  p_doc_level => l_doc_level
   ,  p_doc_level_id_tbl => l_doc_level_id_tbl
   ,  x_valid_state_flag => l_doc_state_valid
   );

   l_progress := '420';

   IF (NVL(l_doc_state_valid,g_doc_state_valid_NO) <> g_doc_state_valid_YES)
   THEN

      l_progress := '430';

      l_exc_message_name := 'PO_ALL_INVALID_DOC_STATE';
      l_exc_code := g_ENC_VALIDATION_EXC_CODE;
      RAISE FND_API.G_EXC_ERROR;

   ELSE
      l_progress := '440';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'state check passed');
      END IF;
   END IF;

   l_progress := '450';

ELSE
   l_progress := '460';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'skipping state check');
   END IF;
END IF;

l_progress := '500';

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Check: document completeness check / submission check
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

IF (     p_validate_document = g_parameter_YES
   AND   p_check_only_flag = g_parameter_NO
) THEN

   l_progress := '510';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'doing doc checks');
   END IF;

   -- Initialize the return variables.

   l_sub_check_status := NULL;
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Set up the submission check call.

   l_progress := '520';

   IF (p_action = g_action_RESERVE) THEN

      l_progress := '525';

      l_sub_check_action
         := PO_DOCUMENT_CHECKS_GRP.g_action_DOC_SUBMISSION_CHECK;

      -- While locking the doc header, we already retrieved the doc id.
      -- Reserve submission checks are only defined at the header level.

      l_doc_level := g_doc_level_HEADER;
      l_doc_level_id_tbl := po_tbl_number( l_doc_id );

   ELSIF (  p_action = g_action_UNRESERVE
      AND   p_doc_type IN (g_doc_type_PO, g_doc_type_RELEASE)
   ) THEN
      -- Unreserve submission check is undefined for Reqs and BPAs.

      l_progress := '530';

      l_sub_check_action := PO_DOCUMENT_CHECKS_GRP.g_action_UNRESERVE;

      -- l_doc_level, l_doc_level_id_tbl have already been set

   ELSE

      l_progress := '535';

      l_sub_check_action := NULL;

   END IF;

   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_sub_check_action',l_sub_check_action);
   END IF;

   l_progress := '540';

   -- Make the submission check call.

   IF (l_sub_check_action IS NOT NULL) THEN

      l_progress := '550';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'starting sub check loop');
      END IF;

      -- bug 3435714
      -- Allowing multiple ids, but submission check isn't designed for this.
      -- Reserve submission check can only act at the header level.
      -- For Unreserve, we need to call the submission check for
      -- each id we are acting on.

      FOR i IN 1 .. l_doc_level_id_tbl.COUNT LOOP

         PO_DOCUMENT_CHECKS_GRP.po_submission_check(
            p_api_version => 1.1
         ,  p_action_requested => l_sub_check_action
         ,  p_document_type => l_doc_type
         ,  p_document_subtype => l_doc_subtype -- doesn't matter for reqs
         ,  p_document_level => l_doc_level
         ,  p_document_level_id => l_doc_level_id_tbl(i)
         ,  p_org_id => NULL
         ,  p_requested_changes => NULL
         ,  p_check_asl => TRUE
         ,  x_return_status => l_return_status
         ,  x_sub_check_status => l_sub_check_status
         ,  x_msg_data => l_msg_data
         ,  x_online_report_id => x_sub_check_report_id
         ,  x_doc_check_error_record => l_doc_check_error_record
         );
         --<bug#5487838 START>
         --We need to mark all these submission check errors are and
         --set the show_in_psa_flag='Y' so that these errors are visible
         --in the psa bc error report.
         UPDATE po_online_report_text
         SET show_in_psa_flag='Y'
         WHERE ONLINE_report_id=x_sub_check_report_id;
         --<bug#5487838 END>
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,
               'Submission check results (i = ' || TO_CHAR(i) || ')');
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_sub_check_action',l_sub_check_action);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_type',l_doc_type);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_subtype',l_doc_subtype);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_level',l_doc_level);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_doc_level_id_tbl(i)',l_doc_level_id_tbl(i));
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status',l_return_status);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_sub_check_status',l_sub_check_status);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_msg_data',l_msg_data);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_sub_check_report_id',x_sub_check_report_id);
         END IF;

         IF (l_sub_check_status <> FND_API.G_RET_STS_SUCCESS) THEN
            l_progress := '560';
            l_exc_code := g_SUBMISSION_CHECK_EXC_CODE;
            RAISE FND_API.G_EXC_ERROR;
         ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            l_progress := '570';
            l_exc_message_name := 'PO_ALL_INVALID_DOC_STATE';
            l_exc_code := g_ENC_VALIDATION_EXC_CODE;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      END LOOP;

      l_progress := '580';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'finished sub check loop');
      END IF;

   ELSE
      l_progress := '585';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'not performing sub check');
      END IF;
   END IF;

   l_progress := '590';

ELSE
   l_progress := '600';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not validating doc');
   END IF;
END IF;

l_progress := '900';

-- If we've made it this far without throwing an exception,
-- we've passed all of the checks.

x_validation_successful_flag := g_parameter_YES;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_validation_successful_flag',x_validation_successful_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_sub_check_report_id',x_sub_check_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;

   x_validation_successful_flag := g_parameter_NO;

   IF (l_exc_code = g_SUBMISSION_CHECK_EXC_CODE) THEN
      l_exc_message_name := 'PO_ALL_INVALID_DOC_STATE';
      -- If there was a submission check error,
      -- make sure there is an online report id.
      IF (x_sub_check_report_id IS NULL) THEN
         FND_MESSAGE.set_name('PO', l_exc_message_name);
         l_exc_message_text := FND_MESSAGE.get;
         PO_ENCUMBRANCE_POSTPROCESSING.create_exception_report(
            p_message_text       => l_exc_message_text
         ,  p_user_id            => NULL
         ,  x_online_report_id   => x_sub_check_report_id
         );
      END IF;
   END IF;

   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_exc_code',l_exc_code);
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_exc_message_name',l_exc_message_name);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_validation_successful_flag',x_validation_successful_flag);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_sub_check_report_id',x_sub_check_report_id);
   END IF;

   -- Prepare the message to put on the API message list.
   IF (l_exc_code IN (g_ENC_VALIDATION_EXC_CODE,g_SUBMISSION_CHECK_EXC_CODE)) THEN
      FND_MESSAGE.set_name('PO', l_exc_message_name);
   ELSIF (l_exc_code = g_INVALID_CALL_EXC_CODE) THEN
      FND_MESSAGE.set_name('PO', 'PO_ALL_INVALID_PARAMETER');
      FND_MESSAGE.set_token('PROCEDURE', l_api_name);
      FND_MESSAGE.set_token('PACKAGE', g_pkg_name);
   ELSE -- no exception code
      -- log a debug msg if necessary and set the dictionary message
      po_message_s.sql_error(g_pkg_name,l_api_name,l_progress,SQLCODE,SQLERRM);
   END IF;

   -- Add the message that was set to the API message list.
   FND_MSG_PUB.add;

   -- RAISE the exception, if necessary.
   IF (NVL(l_exc_code,g_INVALID_CALL_EXC_CODE) <> g_SUBMISSION_CHECK_EXC_CODE) THEN
      RAISE;
   END IF;

END do_encumbrance_validations;



--------------------------------------------------------------------------------
--Start of Comments
--Name: check_doc_state
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Performs the encumbrance doc state check.
--Parameters:
--IN:
--p_action
--  Specifies the action that is being taken on the document.
--  Use the g_action_<> variables (<> = RESERVE, UNRESERVE, ADJUST, etc.).
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_subtype
--  The document subtype.  Use the g_doc_subtype_<> variables:
--    STANDARD          Standard PO
--    PLANNED           Planned PO
--    BLANKET           Blanket Release, Blanket Agreement, Global Agreement
--    SCHEDULED         Scheduled Release
--  This parameter is not checked for requisitions.
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  Table of ids corresponding to the the doc level on which to perform
--  the checks.
--OUT:
--x_valid_state_flag
--  Indicates whether or not the state check passed.
--  VARCHAR2(1)
--Testing:
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE check_doc_state(
   p_action                         IN             VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  x_valid_state_flag               OUT NOCOPY     VARCHAR2
)
IS

l_api_name  CONSTANT VARCHAR2(30) := 'CHECK_DOC_STATE';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress  VARCHAR2(3) := '000';

l_return_status         VARCHAR2(1);

l_status_rec            PO_STATUS_REC_TYPE;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_empty_tbl             po_tbl_number := NULL;
l_header_id_tbl         po_tbl_number := NULL;
l_release_id_tbl        po_tbl_number := NULL;
l_line_id_tbl           po_tbl_number := NULL;
l_line_location_id_tbl  po_tbl_number := NULL;
l_distribution_id_tbl   po_tbl_number := NULL;

l_doc_id_tbl            po_tbl_number;

l_mode               VARCHAR2(30);

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype', p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl', p_doc_level_id_tbl);
END IF;

l_progress := '010';

-- In the Pro*C status checks, the shipment-level
-- encumbered_flag was also checked.
-- This is no longer being done.

-- Set up the parameters to the doc state check API.

-- Set all of the appropriate IDs, as the doc state check API requires them.

IF (p_doc_level = g_doc_level_HEADER) THEN
   l_progress := '020';
   l_doc_id_tbl := p_doc_level_id_tbl;
ELSE
   -- the doc level is lower than header, so get the header id.
   l_progress := '030';

   PO_CORE_S.get_document_ids(
      p_doc_type           => p_doc_type
   ,  p_doc_level          => p_doc_level
   ,  p_doc_level_id_tbl   => p_doc_level_id_tbl
   ,  x_doc_id_tbl         => l_doc_id_tbl
   );

   IF (p_doc_level = g_doc_level_LINE) THEN
      l_progress := '040';
      l_line_id_tbl := p_doc_level_id_tbl;
   ELSE
      -- the doc level is lower than line
      l_progress := '050';

      IF (p_doc_type <> g_doc_type_RELEASE) THEN
         -- releases don't have lines
         l_progress := '060';

         PO_CORE_S.get_line_ids(
            p_doc_type           => p_doc_type
         ,  p_doc_level          => p_doc_level
         ,  p_doc_level_id_tbl   => p_doc_level_id_tbl
         ,  x_line_id_tbl        => l_line_id_tbl
         );

      END IF;

      IF (p_doc_level = g_doc_level_SHIPMENT) THEN
         l_progress := '070';
         l_line_location_id_tbl := p_doc_level_id_tbl;
      ELSE
         -- the doc level is lower than shipment, which must be distribution
         l_progress := '080';

         IF (p_doc_type <> g_doc_type_REQUISITION) THEN
            -- Reqs don't have shipments
            l_progress := '090';

            PO_CORE_S.get_line_location_ids(
               p_doc_type              => p_doc_type
            ,  p_doc_level             => p_doc_level
            ,  p_doc_level_id_tbl      => p_doc_level_id_tbl
            ,  x_line_location_id_tbl  => l_line_location_id_tbl
            );

         END IF;

         l_progress := '100';
         l_distribution_id_tbl := p_doc_level_id_tbl;

      END IF;

   END IF;

END IF;

l_progress := '110';

-- Set the header_id/release_id based on the doc type.

IF (p_doc_type = g_doc_type_RELEASE) THEN
   l_release_id_tbl := l_doc_id_tbl;
ELSE
   l_header_id_tbl := l_doc_id_tbl;
END IF;

-- Initialize all of the unset id tables.

l_progress := '120';

l_empty_tbl := po_tbl_number();
l_empty_tbl.EXTEND(p_doc_level_id_tbl.COUNT);

l_progress := '130';

IF (l_header_id_tbl IS NULL) THEN
   l_header_id_tbl := l_empty_tbl;
END IF;

l_progress := '140';

IF (l_release_id_tbl IS NULL) THEN
   l_release_id_tbl := l_empty_tbl;
END IF;

l_progress := '150';

IF (l_line_id_tbl IS NULL) THEN
   l_line_id_tbl := l_empty_tbl;
END IF;

l_progress := '160';

IF (l_line_location_id_tbl IS NULL) THEN
   l_line_location_id_tbl := l_empty_tbl;
END IF;

l_progress := '170';

IF (l_distribution_id_tbl IS NULL) THEN
   l_distribution_id_tbl := l_empty_tbl;
END IF;



-- Set the appropriate mode.

l_progress := '200';

IF (p_action = g_action_RESERVE) THEN
   l_progress := '210';
   IF (p_doc_type = g_doc_type_REQUISITION) THEN
      l_progress := '220';
      l_mode := PO_REQ_DOCUMENT_CHECKS_PVT.G_CHECK_RESERVABLE;
   ELSE
      l_progress := '230';
      l_mode := PO_DOCUMENT_CHECKS_PVT.G_CHECK_RESERVABLE;
   END IF;
ELSE
   l_progress := '250';
   IF (p_doc_type = g_doc_type_REQUISITION) THEN
      l_progress := '260';
      l_mode := PO_REQ_DOCUMENT_CHECKS_PVT.G_CHECK_UNRESERVABLE;
   ELSE
      l_progress := '270';
      l_mode := PO_DOCUMENT_CHECKS_PVT.G_CHECK_UNRESERVABLE;
   END IF;
END IF;

l_progress := '290';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_header_id_tbl',l_header_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_release_id_tbl',l_release_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_line_id_tbl',l_line_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_line_location_id_tbl',l_line_location_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_distribution_id_tbl',l_distribution_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_mode',l_mode);
END IF;

-- Call the doc status check.

l_progress := '300';

IF (p_doc_type = g_doc_type_REQUISITION) THEN

   l_progress := '310';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'req');
   END IF;

   PO_REQ_DOCUMENT_CHECKS_GRP.req_status_check(
      p_api_version => 1.0
   ,  p_req_header_id => l_header_id_tbl
   ,  p_req_line_id => l_line_id_tbl
   ,  p_req_distribution_id => l_distribution_id_tbl
   ,  p_mode => l_mode
   ,  p_lock_flag => 'N'
   ,  x_req_status_rec => l_status_rec
   ,  x_return_status => l_return_status
   ,  x_msg_count => l_msg_count
   ,  x_msg_data => l_msg_data
   );

   l_progress := '320';

ELSE

   l_progress := '330';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not req');
   END IF;

   PO_DOCUMENT_CHECKS_GRP.po_status_check(
      p_api_version => 1.0
   ,  p_header_id => l_header_id_tbl
   ,  p_release_id => l_release_id_tbl
   ,  p_document_type => po_tbl_varchar30( p_doc_type )
   ,  p_document_subtype => po_tbl_varchar30( p_doc_subtype )
   ,  p_document_num => po_tbl_varchar30( NULL )
   ,  p_vendor_order_num => po_tbl_varchar30( NULL )
   ,  p_line_id => l_line_id_tbl
   ,  p_line_location_id => l_line_location_id_tbl
   ,  p_distribution_id => l_distribution_id_tbl
   ,  p_mode => l_mode
   ,  p_lock_flag => 'N'
   ,  x_po_status_rec => l_status_rec
   ,  x_return_status => l_return_status
   );

   l_progress := '340';

END IF;

l_progress := '350';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status',l_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_msg_count',l_msg_count);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_msg_data',l_msg_data);
   PO_DEBUG.debug_var(l_log_head,l_progress,'reservable flag',l_status_rec.reservable_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'unreservable flag',l_status_rec.unreservable_flag);
END IF;

IF (p_action = g_action_RESERVE) THEN

   l_progress := '360';

   x_valid_state_flag := l_status_rec.reservable_flag(1);

ELSE

   l_progress := '370';

   x_valid_state_flag := l_status_rec.unreservable_flag(1);

END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_valid_state_flag',x_valid_state_flag);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   x_valid_state_flag := g_doc_state_valid_NO;
   RAISE;

END check_doc_state;




-------------------------------------------------------------------------------
--Start of Comments
--Name: derive_packet_values
--Pre-reqs:
--   PO_ENCUMBRANCE_GT has been populated with the distribution
--   information for both the original doc and backing docs.
--Modifies:
--   PO_ENCUMBRANCE_GT
--Locks:
--   None.
--Function:
--   This procedure updates all of the information required for each
--   entry in PO_ENCUMBRANCE_GT that will be sent to GL for an
--   encumbrance action.  It prepares all of the columns of
--   PO_ENCUMBRANCE_GT that map to columns of GL_BC_PACKETS.
--Parameters:
--IN:
--p_action
--   Specifies the action that is being taken on the main doc.
--p_cbc_flag
--  This parameter is only set to Y if the action is one of the CBC Year-End
--  processes.  If this is Y, p_action is either Reserve or Unreserve
--p_doc_type
--   Differentiates between the doc being a REQ, PO, or RELEASE
--p_doc_subtype
--   Used to differentiate between
--      Scheduled Release vs. Blanket Release
--      Std PO vs. PPO
--p_use_gl_date
--   Y = try to obtain encumbrance period information based on the
--       existing distribution GL date.
--   N = use the override date w/o trying distribution GL date.
--p_override_date
--   Override date used to determine encumbrance period information,
--   if the document distributions date are not used.
--p_prevent_partial_flag
--   Y = never allow a Partial pass in GL
--   N = use normal logic to decide whether partial is allowed
--p_invoice_id
--    For transactions that were caused by an invoice action,
--    this is the id of the invoice that started it all (provided by AP).
--Testing:
--
--End of Comments
------------------------------------------------------------------------------
PROCEDURE derive_packet_values(
   p_action                    IN   VARCHAR2
,  p_cbc_flag                  IN   VARCHAR2
,  p_doc_type                  IN   VARCHAR2
,  p_doc_subtype               IN   VARCHAR2
,  p_use_gl_date               IN   VARCHAR2
,  p_override_date             IN   DATE
,  p_partial_flag              IN   VARCHAR2
,  p_set_of_books_id           IN   NUMBER
,  p_currency_code_func        IN   VARCHAR2
,  p_req_encumb_type_id        IN   NUMBER
,  p_po_encumb_type_id         IN   NUMBER
,  p_ap_reinstated_enc_amt     IN   NUMBER
,  p_ap_cancelled_qty          IN   NUMBER
,  p_invoice_id                IN   NUMBER
)

IS

l_api_name CONSTANT varchar2(40) := 'DERIVE_PACKET_VALUES';
l_progress varchar2(3) := '000';

l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_partial_flag',p_partial_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_set_of_books_id',p_set_of_books_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_currency_code_func',p_currency_code_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_req_encumb_type_id',p_req_encumb_type_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_po_encumb_type_id',p_po_encumb_type_id);
END IF;

l_progress := '010';

-- Set the period information
get_period_info(
   p_action 		=> p_action
,  p_set_of_books_id 	=> p_set_of_books_id
,  p_override_date 	=> p_override_date
,  p_try_dist_date_flag	=> p_use_gl_date
,  p_partial_flag 	=> p_partial_flag
);

l_progress := '015';

-- Set the amounts (this will populate the final_amt column)
get_amounts(
   p_action => p_action
,  p_doc_type => p_doc_type
,  p_doc_subtype => p_doc_subtype
,  p_currency_code_func => p_currency_code_func
,  p_ap_reinstated_enc_amt => p_ap_reinstated_enc_amt
,  p_ap_cancelled_qty => p_ap_cancelled_qty
,  p_invoice_id => p_invoice_id
);

l_progress := '020';

-- Now put the final_amt into the appropriate fields.
-- <SLA R12>
update_amounts(
   p_action => p_action,
   p_currency_code_func => p_currency_code_func
);

l_progress := '030';

-- Set the reference information
get_gl_references(
   p_action 		=> p_action
,  p_cbc_flag           => p_cbc_flag
,  p_req_encumb_type_id	=> p_req_encumb_type_id
,  p_po_encumb_type_id	=> p_po_encumb_type_id
,  p_invoice_id => p_invoice_id
);

l_progress := '040';

If g_fnd_debug = 'Y' Then
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  g_log_head || l_api_name || '.' || l_progress,
                  'End of procedure'
                 );
   END IF;
End If;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

   WHEN PO_DOCUMENT_FUNDS_PVT.G_NO_VALID_PERIOD_EXC THEN
      RAISE;

  WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END derive_packet_values;


-------------------------------------------------------------------------------
--Start of Comments
--Name: get_period_info
--Pre-reqs:
--   PO_ENCUMBRANCE_GT has been populated with the date information
--   for both the original doc and backing docs.
--Modifies:
--   PO_ENCUMBRANCE_GT
--Locks:
--   n/a
--Function:
--   This procedure updates the period information in PO_ENCUMBRANCE_GT
--   for both the main doc and backing docs.
--   For backing docs, it sets the period information equal to the
--   period information of the main doc.
--Parameters:
--IN:
--p_action
--   Specifies the action that is being taken on the main doc.
--p_set_of_books_id
--   The set of books in use by this operating unit.
--p_override_date
--   The override date to use if requested.
--p_try_dist_date_flag
--   Indicates whether or not to use the override date:
--   'Y' - try the dist GL date; use overridate date only if that fails
--   'N' - use overridate date only; do not try with dist GL date
--p_partial_flag
--   'Y' - partial reservation of the packet in GL is allowed
--   'N' - partial is not allowed
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_period_info(
   p_action              IN VARCHAR2
,  p_set_of_books_id     IN NUMBER
,  p_override_date       IN DATE
,  p_try_dist_date_flag  IN VARCHAR2
,  p_partial_flag        IN VARCHAR2
)
IS

   l_api_name CONSTANT varchar2(40) := 'GET_PERIOD_INFO';
   l_progress varchar2(3) := '000';

   l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;

   l_allow_roll_forward  VARCHAR2(1) := 'N';
   l_allow_roll_backward VARCHAR2(1) := 'N';
   l_missing_date_flag   VARCHAR2(1) := 'N';

   l_period_error_text  FND_NEW_MESSAGES.message_text%TYPE;
   l_not_processed_msg  FND_NEW_MESSAGES.message_text%TYPE;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_set_of_books_id',p_set_of_books_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_try_dist_date_flag',p_try_dist_date_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_partial_flag',p_partial_flag);
END IF;

-- Set the parameters used by the different actions
IF p_action IN (g_action_UNRESERVE, g_action_FINAL_CLOSE,
                g_action_ADJUST, g_action_INVOICE_CANCEL)   -- Bug 8808501
THEN

   l_allow_roll_forward := 'Y';

ELSIF p_action IN (g_action_RETURN, g_action_REJECT) THEN

   l_allow_roll_forward  := 'Y';
   l_allow_roll_backward := 'Y';

END IF;

l_progress := '010';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_allow_roll_forward',l_allow_roll_forward);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_allow_roll_backward',l_allow_roll_backward);
END IF;

IF (p_try_dist_date_flag = 'Y' OR p_action = g_action_ADJUST) THEN

   l_progress := '015';

   If g_fnd_debug = 'Y' Then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                     g_log_head || l_api_name || '.' || l_progress,
                     'Try distribution GL dates'
                    );
      END IF;
   End If;

   find_open_period(
      p_set_of_books_id => p_set_of_books_id
   ,  p_try_dist_date_flag => p_try_dist_date_flag
   ,  p_override_date => p_override_date
   ,  p_override_attempt => 'N'
   ,  p_roll_logic_used => g_roll_logic_NONE
   ,  x_missing_date_flag => l_missing_date_flag
   );

END IF;

IF (l_missing_date_flag = 'Y' OR p_try_dist_date_flag = 'N') THEN

   l_progress := '020';

   If g_fnd_debug = 'Y' Then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                     g_log_head || l_api_name || '.' || l_progress,
                     'Try Override GL date'
                    );
      END IF;
   End If;

   find_open_period(
      p_set_of_books_id => p_set_of_books_id
   ,  p_try_dist_date_flag => p_try_dist_date_flag
   ,  p_override_date => p_override_date
   ,  p_override_attempt => 'Y'
   ,  p_roll_logic_used => g_roll_logic_NONE
   ,  x_missing_date_flag => l_missing_date_flag
   );

   IF (l_missing_date_flag = 'Y') THEN

      IF (l_allow_roll_forward = 'Y') THEN
         -- roll-forward is used for:
         -- programmatic UNRESERVE
         -- Final Close that is entered from AP Final Match
         -- Return
         -- Reject

         l_progress := '030';

         If g_fnd_debug = 'Y' Then
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                           g_log_head || l_api_name || '.' || l_progress,
                           'Try roll forward logic'
                          );
            END IF;
         End If;

         find_open_period(
            p_set_of_books_id => p_set_of_books_id
         ,  p_try_dist_date_flag => p_try_dist_date_flag
         ,  p_override_date => p_override_date
         ,  p_override_attempt => 'Y'
         ,  p_roll_logic_used => g_roll_logic_FORWARD
         ,  x_missing_date_flag => l_missing_date_flag
         );


         IF (l_missing_date_flag = 'Y') THEN
	     IF (l_allow_roll_backward = 'Y') THEN
	       -- roll-backward is used for:
               -- Return
               -- Reject

               l_progress := '040';

               If g_fnd_debug = 'Y' Then
                  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                                 g_log_head || l_api_name || '.' || l_progress,
                                 'Try roll backward logic'
                                );
                  END IF;
               End If;

               find_open_period(
                  p_set_of_books_id => p_set_of_books_id
               ,  p_try_dist_date_flag => p_try_dist_date_flag
               ,  p_override_date => p_override_date
               ,  p_override_attempt => 'Y'
               ,  p_roll_logic_used => g_roll_logic_BACKWARD
               ,  x_missing_date_flag => l_missing_date_flag
               );

            END IF; -- if roll back allowed is 'Y'

         END IF; -- if l_roll_forward_csr_found is 'Y'

      END IF; -- if roll forward allowed = 'Y'

   END IF;  --if override date was valid

END IF;  -- if we should try override date


l_progress := '050';

If g_fnd_debug = 'Y' Then
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  g_log_head || l_api_name || '.' || l_progress,
                  'Update backing document GL dates'
                 );
   END IF;
End If;


-- By now, the period info has been set for the original
-- document's distributions.
-- Now update the backing distributions.
UPDATE PO_ENCUMBRANCE_GT BACKING
SET (
   BACKING.period_name
,  BACKING.period_year
,  BACKING.period_num
,  BACKING.quarter_num
,  BACKING.gl_period_date --bug#5098665
)
=
(
   SELECT
      ORIG.period_name
   ,  ORIG.period_year
   ,  ORIG.period_num
   ,  ORIG.quarter_num
   ,  ORIG.gl_period_date --bug#5098665
   FROM
      PO_ENCUMBRANCE_GT ORIG
   WHERE
       ORIG.sequence_num = BACKING.origin_sequence_num
   AND ORIG.origin_sequence_num IS NULL
   AND ORIG.distribution_type <> g_dist_type_REQUISITION
)
WHERE BACKING.origin_sequence_num IS NOT NULL
;

IF (l_missing_date_flag = 'Y') THEN
   -- there are distributions without valid period information

   l_progress := '060';

   If g_fnd_debug = 'Y' Then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                     g_log_head || l_api_name || '.' || l_progress,
                     'No valid period for some distributions'
                    );
      END IF;
   End If;

   l_period_error_text := FND_MESSAGE.get_string(
                             'PO'
                          ,  'PO_PDOI_INVALID_GL_ENC_PER'
                          );

   -- Mark the missing date lines to not be sent to GL
   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET DISTS.send_to_gl_flag = 'N'  --bug 5413111 gl period failed rows shouldn't be sent to GL
   ,   DISTS.gl_result_code = 'F25'   --GL error code for no period found
   ,   DISTS.result_type = g_result_ERROR
   ,   DISTS.result_text = l_period_error_text
   WHERE DISTS.period_name IS NULL;

   IF (p_partial_flag = 'N') THEN

      l_not_processed_msg := FND_MESSAGE.get_string(
                                'PO'
                             , 'PO_ENC_DIST_NOT_PROCESSED'
                             );

      -- Mark the other lines as failures, since packet is hosed
      UPDATE PO_ENCUMBRANCE_GT DISTS
      SET DISTS.send_to_gl_flag = 'Y'  --bug 3568512: new send_to_gl column
      ,   DISTS.result_text = l_not_processed_msg
      ,   DISTS.result_type = g_result_NOT_PROCESSED
      WHERE DISTS.period_name IS NOT NULL;

      --force x_return_status to E and stop processing
      RAISE PO_DOCUMENT_FUNDS_PVT.G_NO_VALID_PERIOD_EXC;

   END IF;

END IF;

l_progress := '070';

If g_fnd_debug = 'Y' Then
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  g_log_head || l_api_name || '.' || l_progress,
                  'End of procedure'
                 );
   END IF;
End If;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

   WHEN PO_DOCUMENT_FUNDS_PVT.G_NO_VALID_PERIOD_EXC THEN
      RAISE;

  WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_period_info;


-------------------------------------------------------------------------------
--Start of Comments
--Name: find_open_period
--Pre-reqs:
--   PO_ENCUMBRANCE_GT has been populated with the date information
--   for both the original doc.
--Modifies:
--   PO_ENCUMBRANCE_GT
--   PO_SESSION_GT
--Locks:
--   n/a
--Function:
--   This procedure updates the period information in PO_ENCUMBRANCE_GT
--   for both the main doc, based on parameters which decide whether to
--   use the distribution GL date, override date, roll-forward or
--   roll-backward logic.
--Parameters:
--IN:
--p_set_of_books_id
--   The set of books in use by this operating unit.
--p_override_date
--   The override date to use if requested.
--p_use_override_date
--   Indicates whether or not to use the override date:
--   'Y' - use override date only; do not try with dist GL date
--   'N' - try the dist GL date; use overridate date only if that fails
--p_roll_logic_used
--   Indicates what kind of rolling logic should be used, if necessary
--   g_roll_logic_NONE - don't roll forward or backward
--   g_roll_logic_FORWARD - use roll forward
--   g_roll_logic_BACKWARD - use roll backward
--OUT:
--x_missing_date_flag
--   Indicates whether there are still distributions without period info
--   at the end of this procedure
--   'Y' - there are distributions w/o period info
--   'N' - all distributions should have period info
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE find_open_period(
   p_set_of_books_id    IN  NUMBER
,  p_try_dist_date_flag IN  VARCHAR2
,  p_override_date      IN  DATE
,  p_override_attempt   IN  VARCHAR2
,  p_roll_logic_used    IN  VARCHAR2
,  x_missing_date_flag  OUT NOCOPY VARCHAR2
)

IS

l_proc_name CONSTANT VARCHAR2(30) := 'FIND_OPEN_PERIOD';
l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
l_progress VARCHAR2(3) := '000';
-- bug 5498063 <R12 GL PERIOD VALIDATION>
l_validate_gl_period VARCHAR2(1);

l_procedure_id NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_set_of_books_id',p_set_of_books_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_try_dist_date_flag',p_try_dist_date_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_attempt',p_override_attempt);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_roll_logic_used',p_roll_logic_used);
END IF;

l_progress := '010';

l_procedure_id := PO_CORE_S.get_session_gt_nextval();

l_progress := '020';

IF (p_override_attempt = 'N') THEN
  -- On the first entry into the procedure, p_override_attempt is set
  -- to 'N'.  So we have to figure out whether to use the distribution
  -- dates or not based on the value of p_try_dist_date_flag (passed by caller)
  -- and the action (for NEW lines in Adjust, we always try the dist dates
  -- first b/c if the user was trying to adjust the GL date, we don't
  -- to just ignore their updated value and skip straight to override
  -- date).
   l_progress := '030';

   INSERT INTO PO_SESSION_GT
   (
      key
   ,  index_num1  -- bug3543542 : Save sequence_num to an indexed column
   ,  date1
   )
   SELECT
      l_procedure_id
   ,  DISTS.sequence_num
   -- Decide whether to use the override date based on the
   -- Use GL Date parameter and the Action
   ,  TRUNC(
             DECODE (p_try_dist_date_flag
                   -- param prefers the distribution date
                   ,  'Y', DISTS.gl_encumbered_date

                   -- prefer the override date, except for New Adjust lines
                   ,  DECODE (DISTS.adjustment_status
                             ,  g_adj_status_NEW, DISTS.gl_encumbered_date
                             ,  p_override_date

                       )
             )
      )
   FROM PO_ENCUMBRANCE_GT DISTS
   WHERE
       DISTS.origin_sequence_num IS NULL  --main doc
   AND DISTS.period_name IS NULL
   --bug 3568512: use send_to_gl_flag for this filter condition
   AND (DISTS.send_to_gl_flag = 'Y'
        OR (DISTS.distribution_type = g_dist_type_REQUISITION
            AND DISTS.prevent_encumbrance_flag = 'Y')
           -- only verify GL date information for prevent-enc distributions if
           -- they are Req dists.  no need to check dates for PO prevent dists.
       )
   ;

ELSE
   -- p_override_attempt = 'Y'
   -- Even if the profile indicates to try the distribution dates,
   -- if we tried that once and failed, on the next entry into this
   -- procedure, we set p_override_attempt to 'Y' to force it to use
   -- the override date.
   -- We do this as a separate insert for performance reasons, b/c in
   -- this case, ALL distributions use the same override_date -- so we
   -- only perform the date SQL on one date.
   l_progress := '040';

   INSERT INTO PO_SESSION_GT ( key,  date1 )
   VALUES ( l_procedure_id, TRUNC(p_override_date))
   ;

END IF;

l_progress := '050';

-- Now, get the period information for the date(s) that were inserted
-- into the session gtt

-- bug#	3627073 The original sql that was written to find the open
-- period was returning multiple rows. Because of this the deleting
-- a requisition line after closing the GL_PERIOD in which it was
-- encumbered was resulting in exceptions.To prevent this and to prevent
-- the use of decode in the where clause the sql was split into 3
-- different sql's below. The first logic is for the normal scenario.
-- the second is for ROLLFORWARD logic the third for a ROLLBACK scenario.

-- bug #3967418
-- The SQLs for ROLLING FORWARD and ROLLING BACKWARD
-- were returning multiple rows because adjustment periods with overlapping
-- start or end dates with other periods were being matched.
-- Added condition at the period info retrieval query level
-- adjustment_period_flag = 'N' so adjustment periods are no longer
-- picked up.

-- bug#5098665
-- From now on we would populate the open period start date
-- instead of gl_encumbered_date. This is to ensure that the funds get
-- reserved/unreserved in the correct period. We would first update
-- date1 with start date of the valid open period. This is because period
-- information is being derived by us and the funds would get reserved
-- in a period and the exact date does not matter.

-- bug 5498063 <R12 GL PERIOD VALIDATION>
l_validate_gl_period := nvl(FND_PROFILE.VALUE('PO_VALIDATE_GL_PERIOD'),'Y');

IF (p_roll_logic_used= g_roll_logic_NONE ) THEN

  UPDATE PO_SESSION_GT TEMP
  SET (
       TEMP.char1,	-- period_name
       TEMP.num2,  	-- period_year
       TEMP.num3,  	-- period_num
       TEMP.num4
      )
      =
      (
      SELECT
        GL_PS.PERIOD_NAME,
        GL_PS.PERIOD_YEAR,
        GL_PS.PERIOD_NUM,
        GL_PS.QUARTER_NUM
      FROM
        GL_PERIOD_STATUSES GL_PS,
        GL_PERIOD_STATUSES PO_PS,
        GL_SETS_OF_BOOKS GL_SOB
      WHERE
      -- Join conditions:
          GL_SOB.set_of_books_id = p_set_of_books_id
      AND GL_PS.set_of_books_id = GL_SOB.set_of_books_id
      AND PO_PS.set_of_books_id = GL_SOB.set_of_books_id
      AND GL_PS.period_name = PO_PS.period_name
      -- GL period conditions:
      AND GL_PS.application_id = 101
      -- bug 5498063 <R12 GL PERIOD VALIDATION>
      -- Bug 17583560
 	  AND ((  l_validate_gl_period IN ( 'Y','R')
 	           and GL_PS.closing_status IN ('O', 'F'))
 	         OR
 	         (l_validate_gl_period = 'N'))
 	  -- AND GL_PS.closing_status IN ('O', 'F')
      AND GL_PS.adjustment_period_flag = 'N'
      AND GL_PS.period_year <= GL_SOB.latest_encumbrance_year
      -- PO period conditions:
      AND PO_PS.application_id = 201
      AND PO_PS.closing_status = 'O'
      AND PO_PS.adjustment_period_flag = 'N'
      -- Period date conditions:
      AND (TEMP.date1 BETWEEN  GL_PS.start_date AND GL_PS.end_date)
    )
  WHERE TEMP.key = l_procedure_id ;

--bug#	3627073
ELSIF (p_roll_logic_used= g_roll_logic_FORWARD ) THEN

  UPDATE PO_SESSION_GT TEMP
  SET (
       TEMP.char1,	-- period_name
       TEMP.num2,  	-- period_year
       TEMP.num3,  	-- period_num
       TEMP.num4,  	-- quarter_num
       TEMP.DATE1   -- gl date to use--<bug#5098665>
      )
      =
      (
      SELECT
        GL_PS2.PERIOD_NAME ,
        GL_PS2.PERIOD_YEAR ,
        GL_PS2.PERIOD_NUM ,
        GL_PS2.QUARTER_NUM,
        GL_PS2.START_DATE --<bug#5098665>
      FROM
	GL_PERIOD_STATUSES GL_PS2
      WHERE
        GL_PS2.set_of_books_id = p_set_of_books_id AND
        GL_PS2.application_id= 101 AND
        /* Bug 3967418 Start */
        GL_PS2.adjustment_period_flag = 'N' AND
        /* Bug 3967418 End */
        GL_PS2.start_date=
	(SELECT min(gl_ps.start_date)
	  FROM
	     GL_PERIOD_STATUSES GL_PS
	  ,  GL_PERIOD_STATUSES PO_PS
	  ,  GL_SETS_OF_BOOKS GL_SOB
	  WHERE
	  -- Join conditions:
	      GL_SOB.set_of_books_id = p_set_of_books_id
	  AND GL_PS.set_of_books_id = GL_SOB.set_of_books_id
	  AND PO_PS.set_of_books_id = GL_SOB.set_of_books_id
	  AND GL_PS.period_name = PO_PS.period_name
	  -- GL period conditions:
	  AND GL_PS.application_id = GL_PS2.application_id
      -- bug 5498063 <R12 GL PERIOD VALIDATION>
      -- bug 17583560
 	  AND ((  l_validate_gl_period IN ('Y','R' )
 	           and GL_PS.closing_status IN ('O', 'F'))
 	         OR
 	         (l_validate_gl_period = 'N'))
 	  -- AND GL_PS.closing_status IN ('O', 'F')
	  AND GL_PS.adjustment_period_flag = 'N'
	  AND GL_PS.period_year <= GL_SOB.latest_encumbrance_year
	  -- PO period conditions:
	  AND PO_PS.application_id = 201
	  AND PO_PS.closing_status = 'O'
	  AND PO_PS.adjustment_period_flag = 'N'
	  -- Period date conditions:
	  AND (TEMP.date1 < GL_PS.start_date)

	)
      )
  WHERE TEMP.key = l_procedure_id;

--bug#	3627073
ELSIF(p_roll_logic_used= g_roll_logic_BACKWARD ) THEN

  UPDATE PO_SESSION_GT TEMP
  SET (
       TEMP.char1,	-- period_name
       TEMP.num2,  	-- period_year
       TEMP.num3,  	-- period_num
       TEMP.num4,  	-- quarter_num
       TEMP.DATE1   -- gl date to use --<bug#5098665>
      )
      =
      (
      SELECT
        GL_PS2.PERIOD_NAME ,
        GL_PS2.PERIOD_YEAR ,
        GL_PS2.PERIOD_NUM ,
        GL_PS2.QUARTER_NUM,
        GL_PS2.START_DATE --<bug#5098665>
      FROM
	GL_PERIOD_STATUSES GL_PS2
      WHERE
        GL_PS2.set_of_books_id = p_set_of_books_id AND
        GL_PS2.application_id= 101 AND
        /* Bug 3967418 Start */
        GL_PS2.adjustment_period_flag = 'N' AND
        /* Bug 3967418 End */
        GL_PS2.end_date=
	(SELECT max(gl_ps.end_date)
	  FROM
	     GL_PERIOD_STATUSES GL_PS
	  ,  GL_PERIOD_STATUSES PO_PS
	  ,  GL_SETS_OF_BOOKS GL_SOB
	  WHERE
	  -- Join conditions:
	      GL_SOB.set_of_books_id = p_set_of_books_id
	  AND GL_PS.set_of_books_id = GL_SOB.set_of_books_id
	  AND PO_PS.set_of_books_id = GL_SOB.set_of_books_id
	  AND GL_PS.period_name = PO_PS.period_name
	  -- GL period conditions:
	  AND GL_PS.application_id = GL_PS2.application_id
      -- bug 5498063 <R12 GL PERIOD VALIDATION>
      -- bug 17583560
 	  AND ((  l_validate_gl_period IN ( 'Y','R' )
 	           and GL_PS.closing_status IN ('O', 'F'))
 	         OR
 	         (l_validate_gl_period = 'N'))
 	  -- AND GL_PS.closing_status IN ('O', 'F')
	  AND GL_PS.adjustment_period_flag = 'N'
	  AND GL_PS.period_year <= GL_SOB.latest_encumbrance_year
	  -- PO period conditions:
	  AND PO_PS.application_id = 201
	  AND PO_PS.closing_status = 'O'
	  AND PO_PS.adjustment_period_flag = 'N'
	  -- Period date conditions:
	  AND (TEMP.date1 > GL_PS.end_date)
	)
      )
  WHERE TEMP.key = l_procedure_id;

END IF;
--bug#	3627073

    -- 14178037 <GL DATE Project Start>
    -- Derive proper GL date and its respective period, when
	-- the present GL Date in the distributions does not belong to Open period,
	-- for the profile "PO: Validate GL Period: Redefault".
	IF Nvl(l_validate_gl_period,'N') = 'R' THEN

	  UPDATE PO_SESSION_GT TEMP
	  SET (
	       TEMP.char1,	-- period_name
	       TEMP.num2,  	-- period_year
	       TEMP.num3,  	-- period_num
	       TEMP.num4,   -- quarter_num
	       TEMP.date1   -- gl_encumbered_date
	      )
	      =
	      (
	        SELECT
	          PERIOD_NAME,
	          PERIOD_YEAR,
	          PERIOD_NUM,
	          QUARTER_NUM,
	          latest_open_date
	        FROM(
	              SELECT
	                GL_PS.PERIOD_NAME,
	                GL_PS.PERIOD_YEAR,
	                GL_PS.PERIOD_NUM,
	                GL_PS.QUARTER_NUM,
	                TRUNC(GL_PS.START_DATE) latest_open_date
	              FROM
	                GL_PERIOD_STATUSES GL_PS,
	                GL_PERIOD_STATUSES PO_PS,
	                GL_SETS_OF_BOOKS GL_SOB
	                WHERE GL_SOB.set_of_books_id = p_set_of_books_id
	                AND GL_PS.application_id = 101
	                AND PO_PS.application_id = 201
	                AND GL_PS.set_of_books_id = GL_SOB.set_of_books_id --JOIN
	                AND PO_PS.set_of_books_id = GL_SOB.set_of_books_id --JOIN
	                AND GL_PS.period_name = PO_PS.period_name --JOIN
	                AND GL_PS.adjustment_period_flag = 'N' -- not an adjusting period
	                AND GL_PS.period_year <= GL_SOB.latest_encumbrance_year
	                AND PO_PS.closing_status = 'O' -- open
	                AND PO_PS.adjustment_period_flag = 'N' -- not an adjusting period
                  -- bug 17583560
	                AND  Trunc(SYSDATE) BETWEEN  GL_PS.start_date AND GL_PS.end_date
	                ORDER BY GL_PS.PERIOD_YEAR DESC,
	                          GL_PS.PERIOD_NUM  DESC,
	                          GL_PS.QUARTER_NUM DESC)
	         WHERE ROWNUM = 1
	       )
	  WHERE TEMP.key = l_procedure_id
	  AND   TEMP.char1 IS NULL;

	END IF;
	--14178037 <GL DATE Project End>

l_progress := '060';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Search for matching periods done');

   SELECT rowid BULK COLLECT INTO PO_DEBUG.g_rowid_tbl
   FROM PO_SESSION_GT WHERE key = l_procedure_id
   ;

   PO_DEBUG.g_column_tbl := po_tbl_varchar30('key','date1','index_num1','char1','num2','num3','num4');  -- bug3543542

   PO_DEBUG.debug_table(l_log_head,l_progress,'PO_SESSION_GT',PO_DEBUG.g_rowid_tbl,PO_DEBUG.g_column_tbl,'PO');

END IF;


-- Update the main encumbrance GTT with the results from
-- the po_session_gt scratchpad.
IF (p_override_attempt = 'N') THEN
   -- There is one row in the session GT for each
   -- row in the main encumbrance GT that needs to be updated
   l_progress := '070';

   -- bug3543542
   -- Need to Add hints to ensure that PO_SESSION_GT_N2 index is used

  --bug#5098665 From now on we would populate the open period start date
  --instead of gl_encumbered_date. This is to ensure that the funds get
  --reserved/unreserved in the correct period. We would first populate
  --po_encumbrance_gt with gl_period_start_date that we derived earlier
  --and then this would be passed onto po_bc_distributions.

   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET (
      DISTS.period_name
   ,  DISTS.period_year
   ,  DISTS.period_num
   ,  DISTS.quarter_num
   ,  DISTS.gl_period_date --<bug#5098665>
   )
   =
   (  SELECT /*+ INDEX (VALID_PERIOD PO_SESSION_GT_N2) */
         VALID_PERIOD.char1 period_name
      ,  VALID_PERIOD.num2 period_year
      ,  VALID_PERIOD.num3 period_num
      ,  VALID_PERIOD.num4 quarter_num
      ,  VALID_PERIOD.date1 gl_period_date --<bug#5098665>
      FROM PO_SESSION_GT VALID_PERIOD
      WHERE
          VALID_PERIOD.key = l_procedure_id
      AND VALID_PERIOD.index_num1 = DISTS.sequence_num  -- bug3543542
      AND VALID_PERIOD.char1 IS NOT NULL
   )
   WHERE
       DISTS.origin_sequence_num IS NULL
   AND DISTS.period_name IS NULL
   ;

ELSE
   -- p_override_attempt = 'Y'
   -- There is only a single row in the session gtt
   -- which is used to update all relevant rows of the
   -- main encumbrance gtt
   l_progress := '080';
  --bug#5098665 From now on we would populate the open period start date
  --instead of gl_encumbered_date. This is to ensure that the funds get
  --reserved/unreserved in the correct period. We would first populate
  --po_encumbrance_gt with gl_period_start_date that we derived earlier
  --and then this would be passed onto po_bc_distributions.

   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET (
      DISTS.period_name
   ,  DISTS.period_year
   ,  DISTS.period_num
   ,  DISTS.quarter_num
   ,  DISTS.gl_period_date --<bug#5098665>
   )
   =
   (  SELECT
         VALID_PERIOD.char1 period_name
      ,  VALID_PERIOD.num2 period_year
      ,  VALID_PERIOD.num3 period_num
      ,  VALID_PERIOD.num4 quarter_num
      ,  VALID_PERIOD.date1 gl_period_date --<bug#5098665>
      FROM PO_SESSION_GT VALID_PERIOD
      WHERE
          VALID_PERIOD.key = l_procedure_id
      AND VALID_PERIOD.char1 IS NOT NULL
      AND rownum = 1
   )
   WHERE
       DISTS.origin_sequence_num IS NULL
   AND DISTS.period_name IS NULL
   ;

END IF;

l_progress := '090';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Updated main encumbrance gt with period information');
END IF;

-- Determine if we found period information for all the dates
-- we were looking at.
   BEGIN
      SELECT 'Y'
      INTO x_missing_date_flag
      FROM DUAL
      WHERE EXISTS
         (SELECT 'period information not populated'
          FROM  PO_SESSION_GT TEMP
          WHERE TEMP.key = l_procedure_id
          AND   TEMP.char1 is NULL  -- no period name populated
         )
      ;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_missing_date_flag := 'N';
   END;

l_progress := '100';

-- Clean up the scratchpad
DELETE
FROM PO_SESSION_GT TEMP
WHERE TEMP.key = l_procedure_id
;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_missing_date_flag',x_missing_date_flag);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION

   WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_proc_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE;

END find_open_period;



-------------------------------------------------------------------------------
--Start of Comments
--Name: get_amounts
--Pre-reqs:
--  The PO_ENCUMBRANCE_GT temp table has been populated with all
--  required information about the main and backing documents; and
--  Encumbrance is on for the doc type of the main doc.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  This procedure calculates the total amount being transacted by
--  the encumbrance action and populates this value in the final_amt
--  column for each row in the PO_ENCUMBRANCE_GT table
--Parameters:
--IN:
--p_action
--   Specifies the action that is being taken on the main doc.
--p_doc_type
--   Differentiates between the doc being a REQ, PO, or RELEASE
--p_doc_subtype
--   Used to differentiate between
--      Scheduled Release vs. Blanket Release
--      Std PO vs. PPO
--p_currency_code_func
--   Identifies the currency that is defined as the functional
--   currency for the current set of books
--p_ap_reinstated_enc_amt
--   For Invoice/Credit Memo cancel only: the amount of encumbrance
--   put back on by AP (w/o any AP variances and excluding tax)
--p_ap_cancelled_qty
--   For Invoice/Credit Memo cancel only: the quantity of the
--   cancelled invoice
--p_invoice_id
--  Adding as part of 20218327 since reversals
--  need not be calculated for Invoice Final Match
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_amounts(
   p_action                IN   VARCHAR2
,  p_doc_type              IN   VARCHAR2
,  p_doc_subtype           IN   VARCHAR2
,  p_currency_code_func    IN   VARCHAR2
,  p_ap_reinstated_enc_amt IN   NUMBER
,  p_ap_cancelled_qty      IN   NUMBER
,  p_invoice_id            IN NUMBER
)
IS

   l_api_name CONSTANT VARCHAR2(40) := 'GET_AMOUNTS';
   l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
   l_progress     VARCHAR2(3) := '000';

   l_ap_reinstated_enc_amt NUMBER;
   l_ap_cancelled_qty      NUMBER;

   l_min_acct_unit_func  FND_CURRENCIES.minimum_accountable_unit%TYPE;
   l_cur_precision_func  FND_CURRENCIES.precision%TYPE;

   l_is_complex_work_po BOOLEAN := FALSE;  --<Complex Work R12>
   l_header_id PO_HEADERS_ALL.po_header_id%TYPE;  --<Complex Work R12>

BEGIN

-- ALGORITHM:
-- The amount being calculated is the transactable or 'open' encumbrance
-- amount.  To find the open amount, we take the initial total amount
-- (stored in amt_ordered) and subtract out the amount that is 'closed'
-- for that encumbrance action.
-- We first do the calculations for the main (forward) document.  Then, we
-- do the calculations for the backing document, if applicable.  Finally,
-- these amounts have tax added, and are currency-converted and rounded.

-- Note:
-- NVLs are not used around fields from the temp table in the calculations
-- below.  It is assumed that NULL values in these fields were given default
-- values upon initial insertion into the global temp table.

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype', p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_currency_code_func',p_currency_code_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_ap_reinstated_enc_amt',p_ap_reinstated_enc_amt);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_ap_cancelled_qty',p_ap_cancelled_qty);
END IF;


-- If AP gives us NULL values, deal with them gracefully.
l_ap_reinstated_enc_amt := NVL(p_ap_reinstated_enc_amt,0);
l_ap_cancelled_qty := NVL(p_ap_cancelled_qty,0);

l_progress := '010';

-- Get functional currency setup
SELECT
   FND_CUR.minimum_accountable_unit
,  FND_CUR.precision
INTO
   l_min_acct_unit_func
,  l_cur_precision_func
FROM FND_CURRENCIES FND_CUR
WHERE FND_CUR.currency_code = p_currency_code_func
;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_min_acct_unit_func', l_min_acct_unit_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_cur_precision_func', l_cur_precision_func);
END IF;


--*********************************************************
-- CALCULATE AMT_ORDERED FOR MAIN, BACKING DOCUMENTS
--*********************************************************
l_progress := '020';

get_initial_amounts(
   p_action               => p_action
,  p_doc_type             => p_doc_type
,  p_doc_subtype          => p_doc_subtype
,  p_currency_code_func   => p_currency_code_func
,  p_min_acct_unit_func   => l_min_acct_unit_func
,  p_cur_precision_func   => l_cur_precision_func
);

--*********************************************************
-- CALCULATE AMT_CLOSED FOR MAIN DOCUMENTS
--*********************************************************
l_progress := '030';

get_main_doc_amts(
   p_action                 => p_action
,  p_doc_type               => p_doc_type
,  p_doc_subtype            => p_doc_subtype
,  p_ap_reinstated_enc_amt  => l_ap_reinstated_enc_amt
,  p_ap_cancelled_qty       => l_ap_cancelled_qty
);

--*********************************************************
-- CALCULATE INTERMEDIATE VALUES FOR BACKING DOCUMENTS
--*********************************************************
l_progress := '040';

IF p_doc_type NOT IN (g_doc_type_REQUISITION, g_doc_type_PA)
   AND p_action NOT IN (g_action_ADJUST, g_action_FINAL_CLOSE,
                        g_action_UNDO_FINAL_CLOSE)
THEN
   -- Reqs and PAs can not have backing docs
   -- Adjust, FC actions do not have backing trxns

   l_progress := '050';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Doc type can have backing docs');
   END IF;

   --<Complex Work R12>: determine if the Std PO is a Complex Work PO
   IF (p_doc_subtype = g_doc_subtype_STANDARD) THEN
     -- There should only be 1 main doc per encumbrance trxn in the Standard PO
     -- Requester Change Order is the only code that calls encumbrance on multiple docs
     -- and they pass the subtype as MIXED_PO_RELEASE.
     -- Requester Change Order is not supported for Complex Work POs.

     SELECT header_id
     INTO l_header_id
     FROM PO_ENCUMBRANCE_GT
     WHERE origin_sequence_num is null --main doc
     AND rownum = 1  --just get first record since all should have same ID
     ;

     l_is_complex_work_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(l_header_id);

   END IF;

   IF (NOT l_is_complex_work_po) THEN
     --<Complex Work R12>: skip this method for Complex Work POs
     --Complex Work backing Req calculations are done separately, after
     --the main doc final amount is set and rounded

     -- Bug 3480949: Use l_ap_cancelled_qty instead of p_ap_cancelled_qty
     -- Also, use l_ap_reinstated_enc_amt instead of l_ap_amt_billed_changed
     -- The latter variable was being used to stored tax excluded values,
     -- but now that p_ap_reinstated_end_amt is assumed to be tax excluded,
     -- l_ap_amt_billed_changed has been obsoleted.
     get_backing_doc_amts(
        p_action               => p_action
     ,  p_doc_type             => p_doc_type
     ,  p_doc_subtype          => p_doc_subtype
     ,  p_currency_code_func   => p_currency_code_func
     ,  p_min_acct_unit_func   => l_min_acct_unit_func
     ,  p_cur_precision_func   => l_cur_precision_func
     ,  p_ap_cancelled_qty     => l_ap_cancelled_qty
     ,  p_ap_amt_billed_change => l_ap_reinstated_enc_amt
     );

   END IF; --If non-Complex Work case

END IF;  -- p_action <> Adjust, FC  (so action can have backing trxns)

--*********************************************************
-- CALCULATE FINAL AMTS FOR MAIN AND BACKING DOCUMENTS
--*********************************************************
l_progress := '060';

get_final_amounts(
   p_action             => p_action
,  p_doc_type           => p_doc_type
,  p_doc_subtype        => p_doc_subtype
,  p_currency_code_func => p_currency_code_func
,  p_min_acct_unit_func => l_min_acct_unit_func
,  p_cur_precision_func => l_cur_precision_func
,  p_ap_reinstated_enc_amt => l_ap_reinstated_enc_amt
,  p_is_complex_work_po => l_is_complex_work_po --<Complex Work R12>
);

-- Bug 15987200
-- Bug 19236314 reversal amounts should be calculated only for standated PO and blanket release
-- Bug 20218327
-- Correct the fix of 19236314 also reversal need not be calculated for Invoice final match
IF p_action = g_action_FINAL_CLOSE AND ( p_doc_subtype = g_doc_subtype_STANDARD
				   OR ( (p_doc_type= g_doc_type_RELEASE AND
         ( p_doc_subtype= g_doc_subtype_BLANKET OR p_doc_subtype = g_doc_subtype_PLANNED ))))
           AND p_invoice_id is null
THEN

 get_reversal_amounts (p_doc_type           => p_doc_type
,  p_doc_subtype        => p_doc_subtype
,  p_currency_code_func => p_currency_code_func
,  p_min_acct_unit_func => l_min_acct_unit_func
,  p_cur_precision_func => l_cur_precision_func
);


END IF;
l_progress := '070';

IF g_debug_stmt THEN
   PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows);
   PO_DEBUG.debug_end(l_log_head);
END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

   WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_amounts;


-------------------------------------------------------------------------------
--Start of Comments
--Name: get_initial_amounts
--Pre-reqs:
--  The PO_ENCUMBRANCE_GT temp table has been populated with all
--  required information about the main and backing documents; and
--  Encumbrance is on for the doc type of the main doc.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  Performs the basic calculations for both main and backing docs:
--  1. Calculate the amount_ordered (initial request amt on PO/Req)
--  2. Calculate the 'rate' multiplier for nonrecoverable_tax
--Parameters:
--IN:
--p_action
--   Specifies the action that is being taken on the main doc.
--p_doc_type
--   Differentiates between the doc being a REQ, PO, or RELEASE
--p_doc_subtype
--   Used to differentiate between
--      Scheduled Release vs. Blanket Release
--      Std PO vs. PPO
--p_currency_code_func
--   Identifies the currency that is defined as the functional
--   currency for the current set of books
--p_min_acct_unit_func
--   The minimum accountable unit (defined in FND_CURRENCIES) of the
--   functional currency for the currency Set of Books
--p_cur_precision_func
--   The precision (defined in FND_CURRENCIES) of the functional
--   currency for the current Set of Books
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_initial_amounts(
   p_action               IN  VARCHAR2
,  p_doc_type             IN  VARCHAR2
,  p_doc_subtype          IN  VARCHAR2
,  p_currency_code_func   IN  VARCHAR2
,  p_min_acct_unit_func   IN  NUMBER
,  p_cur_precision_func   IN  NUMBER
)
IS

   l_api_name     CONSTANT VARCHAR2(40) := 'GET_INITIAL_AMOUNTS';
   l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
   l_progress     VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype', p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_min_acct_unit_func', p_min_acct_unit_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_cur_precision_func', p_cur_precision_func);
END IF;


-- If the doc is a BPA, or can have a backing BPA, convert
-- any BPA dist amount_to_encumber to functional currency
-- and store this in the amt_to_encumber_func column.
-- For BPAs, we need to do this before further calculations
-- since the amount_to_encumber and the unencumbered_amount may
-- be in different currencies, and are compared in later calculations.
IF p_doc_subtype IN (g_doc_subtype_BLANKET, g_doc_subtype_STANDARD,
                     g_doc_subtype_MIXED_PO_RELEASE)
THEN
   round_and_convert_amounts(
      p_action => p_action
   ,  p_currency_code_func => p_currency_code_func
   ,  p_min_acct_unit_func => p_min_acct_unit_func
   ,  p_cur_precision_func => p_cur_precision_func
   ,  p_column_to_use => g_column_AMOUNT_TO_ENCUMBER
   );
END IF;

l_progress := '010';

-- Now, calculate the intial amount_ordered for both the
-- main and backing documents

-- First, get the qty_ordered for quantity-based lines
UPDATE PO_ENCUMBRANCE_GT DISTS
SET DISTS.qty_ordered = nvl(DISTS.quantity_ordered, 0)
WHERE DISTS.prevent_encumbrance_flag = 'N'
AND DISTS.amount_based_flag = 'N'
;

l_progress := '020';

-- Now, get amt_ordered for both Service and non-Service lines
UPDATE PO_ENCUMBRANCE_GT DISTS
SET DISTS.amt_ordered =
    DECODE(DISTS.distribution_type
          -- Agreements
          ,  g_dist_type_AGREEMENT, amt_to_encumber_func

          -- All other doc types
          ,  DECODE(DISTS.amount_based_flag
                   -- Quantity based lines:
                   ,  'N', DISTS.qty_ordered * DISTS.price

                   -- Amount based lines:
                   ,  DISTS.amount_ordered
          )
    )
WHERE DISTS.prevent_encumbrance_flag = 'N'
;

l_progress := '030';

IF g_debug_stmt THEN
   PO_DEBUG.debug_table(
      l_log_head, l_progress,'PO_ENCUMBRANCE_GT', PO_DEBUG.g_all_rows,
      po_tbl_varchar30( 'amount_based_flag', 'qty_ordered', 'amt_ordered' )
   );
END IF;

-- Based on the amount_ordered and the stored tax amount,
-- we can calculate the 'rate' of that tax.

-- Note: we do not worry about foreign vs functional currency
-- for nonrecoverable_tax_rate, since it is obtained by dividing
-- two amounts that are either both foreign or both functional.

-- Note: the nonrecoverable_tax can be negative due
-- to tax adjustments from Req Split.(bug 3428139, bug 3428600)

UPDATE PO_ENCUMBRANCE_GT DISTS
SET DISTS.nonrecoverable_tax_rate =
   DECODE(  NVL(DISTS.amt_ordered,0)

         -- Bug 3410522: If amt_ordered is 0, we can ignore tax.
         ,  0, 0

         -- Else, calculate rate multiplier for tax
         ,  (1 + (DISTS.nonrecoverable_tax / DISTS.amt_ordered))
         )
WHERE DISTS.prevent_encumbrance_flag = 'N'
;

l_progress := '040';

IF g_debug_stmt THEN
   PO_DEBUG.debug_table(
      l_log_head, l_progress,'PO_ENCUMBRANCE_GT', PO_DEBUG.g_all_rows,
      po_tbl_varchar30( 'nonrecoverable_tax_rate')
   );
   PO_DEBUG.debug_end(l_log_head);
END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

  WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_initial_amounts;


-------------------------------------------------------------------------------
--Start of Comments
--Name: get_main_doc_amts
--Pre-reqs:
--  The PO_ENCUMBRANCE_GT temp table has been populated with all
--  required information about the main and backing documents; and
--  Encumbrance is on for the doc type of the main doc.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  Calculates the amount of encumbrance from the main document that
--  is now 'relieved', e.g. for a PO, from billing/delivery; or for a
--  PPO/PA, from releases created against them
--Parameters:
--IN:
--p_action
--   Specifies the action that is being taken on the main doc.
--p_doc_type
--   Differentiates between the doc being a REQ, PO, or RELEASE
--p_doc_subtype
--   Used to differentiate between
--      Scheduled Release vs. Blanket Release
--      Std PO vs. PPO
--p_ap_reinstated_enc_amt
--   For Invoice/Credit Memo cancel only: the amount of encumbrance
--   put back on by AP (w/o any AP variances)
--p_ap_cancelled_qty
--   For Invoice/Credit Memo cancel only: the quantity of the
--   cancelled invoice
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_main_doc_amts(
   p_action                 IN  VARCHAR2
,  p_doc_type               IN  VARCHAR2
,  p_doc_subtype            IN  VARCHAR2
,  p_ap_reinstated_enc_amt  IN  NUMBER
,  p_ap_cancelled_qty       IN  NUMBER
)
IS

   l_api_name     CONSTANT VARCHAR2(40) := 'GET_MAIN_DOC_AMTS';
   l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
   l_progress     VARCHAR2(3) := '000';

   -- Bug 3480949: removed now unused variabe l_ap_amt_billed_change

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype', p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_ap_reinstated_enc_amt', p_ap_reinstated_enc_amt);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_ap_cancelled_qty', p_ap_cancelled_qty);
END IF;


IF p_action NOT IN (g_action_INVOICE_CANCEL, g_action_CR_MEMO_CANCEL) THEN
   -- All other encumbrance actions (Res, Unres, Adjust, Cancel etc..)
   l_progress := '010';

   IF (p_doc_type = g_doc_type_REQUISITION) THEN
      -- main doc is a Req
      l_progress := '020';

      UPDATE PO_ENCUMBRANCE_GT DISTS
      SET DISTS.amt_closed =
            DISTS.amt_ordered *
            DECODE(  DISTS.amount_based_flag

                  -- Quantity-based:
                  -- closed amt is pro-rated from the req line's qty delivered
                  -- (used for internal Reqs tied to Sales Orders)
                  ,  'N', (DISTS.quantity_delivered / DISTS.quantity_on_line)

                  -- Amount-based:
                  -- The amt_closed for Services Req lines is always zero,
                  -- as they can not be tied to Sales Orders
                  ,  0
                  )
      WHERE DISTS.prevent_encumbrance_flag = 'N'
      ;

   ELSIF (p_doc_type = g_doc_type_PA) THEN
      -- main doc is a BPA/GA
      l_progress := '030';

      -- The closed amount for BPAs is the amount of encumbrance already
      -- relieved against the BPA
      UPDATE PO_ENCUMBRANCE_GT DISTS
      SET DISTS.amt_closed = DISTS.unencumbered_amount
      WHERE DISTS.prevent_encumbrance_flag = 'N'
      ;

   ELSE
      -- main doc is a PPO, PO, or Release (or mix of Std POs/Bl Releases)

      -- First, get the qty_closed for non-Service lines, based on the doc type
      -- Then, calculate amt_closed for all line types

      IF (p_doc_subtype = g_doc_subtype_PLANNED) THEN
         l_progress := '040';

         -- For PPO, qty closed = qty unencumbered by SR's against the PPO
         UPDATE PO_ENCUMBRANCE_GT DISTS
         SET DISTS.qty_closed = DISTS.unencumbered_quantity
         WHERE DISTS.origin_sequence_num IS NULL  -- main doc
         AND DISTS.prevent_encumbrance_flag = 'N'
         AND DISTS.amount_based_flag = 'N'
         -- no Services lines on a PPO
         ;

      ELSE
         -- the doc_type is a Std PO or Release (or mix of Std POs/ Bl Releases)
         l_progress := '050';

         -- in this case, qty closed is the amount that is already
         -- moved to an actual (and not considered for future encumbrance
         -- actions)
         UPDATE PO_ENCUMBRANCE_GT DISTS
         SET DISTS.qty_closed =
            DECODE(  DISTS.accrue_on_receipt_flag

                  -- Online Accruals
                  ,  'Y', DISTS.quantity_delivered

           -- <13503748: Edit without unreserve ER>
           -- for all the actions except Finally close making quantity closed
	   -- as greatest of quantity delivered and quantity billed
	   -- for period end accruals
                  -- Period-End Accruals:
                  , DECODE(  p_action

                           -- Finally Close:
                           ,  g_action_FINAL_CLOSE
                           ,  DISTS.quantity_billed
                           ,   GREATEST(   DISTS.quantity_billed
                              ,  DISTS.quantity_delivered
                                      )
                          )
                  )
         WHERE DISTS.origin_sequence_num IS NULL  -- main doc
         AND DISTS.amount_based_flag = 'N'
         AND DISTS.prevent_encumbrance_flag = 'N'
         ;

      END IF;  -- check on p_doc_subtype to calculate qty_closed

      l_progress := '060';

      -- Now that we have the qty_closed for the qty-based main doc
      -- lines, we can get the amt_closed for all main doc lines.
      UPDATE PO_ENCUMBRANCE_GT DISTS
      SET DISTS.amt_closed =
            DECODE(  DISTS.amount_based_flag

                  -- quantity-based: use qty_closed calc from above
                  ,  'N', DISTS.qty_closed * DISTS.price

                  -- amount-based: mimic qty_closed calc on amt field analogs
                  ,  DECODE(  DISTS.accrue_on_receipt_flag

                           -- Online Accruals:
                           ,  'Y', DISTS.amount_delivered

                  -- <13503748: Edit without unreserve ER>
                  -- for all the actions except Finally Close making
		  -- quantity closed as greatest of quantity
                 -- delivered and quantity billed for period end accruals
                           -- Period-End Accruals:
                           ,
                                       DECODE(  p_action

                           -- Finally Close:
                           ,  g_action_FINAL_CLOSE
                           ,  DISTS.amount_billed
                           ,   GREATEST(   DISTS.amount_billed
                              ,  DISTS.amount_delivered
                                      )
                          )
                           )
                  )
      WHERE DISTS.origin_sequence_num IS NULL  --main doc
      AND DISTS.prevent_encumbrance_flag = 'N'
      ;

   END IF;  -- amt_closed calculation for main doc


ELSE
   -- p_action is AP Inv/Cr Memo Cancel
   -- do calculations based on p_ap_reinstated_enc_amt passed in by AP
   -- this parameter represents the amount of encumbrance AP posted back to PO
   -- in the ledger, excluding any tax

   l_progress := '080';

   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'doing AP calculations for main doc');
   END IF;

   -- Bug 3480949: Removed logic that would remove tax from ap amount
   -- AP now calls the invoice cancel API with p_tax_line_flag = 'Y'
   -- and passes a tax free amount into p_ap_reinstated_enc_amt
   -- No longer need to store tax free amount in l_ap_amt_billed_change


   -- The qty_closed and amt_closed set here
   -- will be used for backing doc calculations.
   -- qty_closed must be updated before amt_closed,
   -- since it is used in the calculation for amt_closed.

   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET DISTS.qty_closed =
         DECODE(  p_action
               ,  g_action_INVOICE_CANCEL,
                     DISTS.quantity_billed + p_ap_cancelled_qty

               -- cr memo cancel
               ,  DISTS.quantity_billed
               )
   WHERE DISTS.prevent_encumbrance_flag = 'N'
   AND   DISTS.origin_sequence_num IS NULL
   AND   DISTS.amount_based_flag = 'N'
   ;

   l_progress := '100';

  -- Bug 3480949: Use p_ap_reinstated_enc_amt instead of
  -- deleted variable l_ap_amt_billed_change

   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET DISTS.amt_closed =
         DECODE(  DISTS.amount_based_flag

               ,  'N', DISTS.qty_closed * DISTS.price

               ,  DECODE(  p_action
                        ,  g_action_INVOICE_CANCEL,
                              p_ap_reinstated_enc_amt + DISTS.amount_billed

                        -- cr memo cancel
                        ,  DISTS.amount_billed
                        )
               )
   WHERE DISTS.prevent_encumbrance_flag = 'N'
   AND DISTS.origin_sequence_num IS NULL
   ;

   l_progress := '110';

END IF;  -- p_action is AP Inv Cancel vs. any other action

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Calculated amount_closed for main document'
   );
   PO_DEBUG.debug_table(
      l_log_head, l_progress,'PO_ENCUMBRANCE_GT', PO_DEBUG.g_all_rows,
      po_tbl_varchar30( 'amount_based_flag', 'qty_closed', 'amt_closed')
   );
   PO_DEBUG.debug_end(l_log_head);
END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

  WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_main_doc_amts;



-------------------------------------------------------------------------------
--Start of Comments
--Name: get_backing_doc_amts
--Pre-reqs:
--  The PO_ENCUMBRANCE_GT temp table has been populated with all
--  required information about the main and backing documents; and
--  Encumbrance is on for the doc type of the main doc.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  Calculates the amount of encumbrance from the backing Req/PPO that
--  is still 'active', e.g. for a PPO: the amount that is not yet relieved,
--  or for a backing Req: the difference in the Req qty and the amount
--  relieved on the PO.
--Parameters:
--IN:
--p_action
--   Specifies the action that is being taken on the main doc.
--p_doc_type
--   Differentiates between the doc being a REQ, PO, or RELEASE
--p_doc_subtype
--   Used to differentiate between
--      Scheduled Release vs. Blanket Release
--      Std PO vs. PPO
--p_currency_code_func
--   Identifies the currency that is defined as the functional
--   currency for the current set of books
--p_min_acct_unit_func
--   The minimum accountable unit (defined in FND_CURRENCIES) of the
--   functional currency for the currency Set of Books
--p_cur_precision_func
--   The precision (defined in FND_CURRENCIES) of the functional
--   currency for the current Set of Books
--p_ap_cancelled_qty
--   For Invoice/Credit Memo cancel only: the quantity of the
--   cancelled invoice
--p_ap_amt_billed_change
--   For Invoice/Credit Memo cancel only: the amount of invoice
--   cancelled encumbrance (minus variances/tax)
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_backing_doc_amts(
   p_action               IN  VARCHAR2
,  p_doc_type             IN  VARCHAR2
,  p_doc_subtype          IN  VARCHAR2
,  p_currency_code_func   IN  VARCHAR2
,  p_min_acct_unit_func   IN  NUMBER
,  p_cur_precision_func   IN  NUMBER
,  p_ap_cancelled_qty     IN  NUMBER
,  p_ap_amt_billed_change IN  NUMBER
)
IS
   l_api_name     CONSTANT VARCHAR2(40) := 'GET_BACKING_DOC_AMTS';
   l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
   l_progress     VARCHAR2(3) := '000';

   l_uom_conversion_error  VARCHAR2(1) := 'N';

BEGIN

-- Note: No Calculations for backing Agreements in this procedure.
-- The backing PA encumbrances are set in the call to
-- check_backing_pa_amounts, where the backing PA amount
-- is copied from the main doc amount, and possibly adjusted
-- downwards to stay within PA amt limits.  This occurs AFTER the
-- final rounding/conversion, to prevent penny differences

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype', p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_currency_code_func', p_currency_code_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_min_acct_unit_func', p_min_acct_unit_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_cur_precision_func', p_cur_precision_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_ap_cancelled_qty', p_ap_cancelled_qty);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_ap_amt_billed_change', p_ap_amt_billed_change);
END IF;


-- Calculations for Backing Reqs:
IF (  (p_doc_subtype IN (g_doc_subtype_PLANNED,
                         g_doc_subtype_STANDARD,
                         g_doc_subtype_MIXED_PO_RELEASE))
   OR
      (p_doc_type = g_doc_type_RELEASE
       AND p_doc_subtype = g_doc_subtype_BLANKET) ) THEN
   -- Only PPOs, Standard POs and Blanket Releases have backing Reqs

   l_progress := '010';

   IF (p_action <> g_action_CANCEL) THEN
      -- During a Cancel with Recreate Demand, the recreated Req dist
      -- generated by the Cancel code is not tied to the PO/Rel.  It is a
      -- fresh dist and will not have any closed amount, so we don't need
      -- to do these calculations.
      l_progress := '020';

      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,
                             'Starting calculations for backing Reqs');
      END IF;


      -- Get unit of measure conversion rate, if backing Req UOM is
      -- different from main doc UOM
      UPDATE PO_ENCUMBRANCE_GT REQ_DISTS
      SET REQ_DISTS.uom_conversion_rate =
         (SELECT PO_UOM_S.PO_UOM_CONVERT_P( PO_DISTS.unit_meas_lookup_code
                                          , REQ_DISTS.unit_meas_lookup_code
                                          , REQ_DISTS.item_id
                                          )
          FROM PO_ENCUMBRANCE_GT PO_DISTS
          WHERE REQ_DISTS.origin_sequence_num = PO_DISTS.sequence_num
          AND PO_DISTS.distribution_type <> g_dist_type_REQUISITION
          AND REQ_DISTS.unit_meas_lookup_code <>
                 PO_DISTS.unit_meas_lookup_code
         )
      WHERE REQ_DISTS.distribution_type = g_dist_type_REQUISITION
      AND REQ_DISTS.amount_based_flag = 'N'
      AND REQ_DISTS.prevent_encumbrance_flag = 'N'
      ;

      l_progress := '030';

      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'did UoM conversion');
         PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows
            ,po_tbl_varchar30('prevent_encumbrance_flag','amount_based_flag'
               ,'distribution_type','uom_conversion_rate','unit_meas_lookup_code'
               ,'item_id','sequence_num','origin_sequence_num'
               )
            );
      END IF;

      -- The UOM conversion above uses a function called within the SQL
      -- Check to see if any of the rows returned error from the function
      BEGIN
         SELECT 'Y'
         INTO l_uom_conversion_error
         FROM PO_ENCUMBRANCE_GT REQ_DISTS
         WHERE REQ_DISTS.distribution_type = g_dist_type_REQUISITION
         AND REQ_DISTS.amount_based_flag = 'N'
         AND REQ_DISTS.prevent_encumbrance_flag = 'N'
         AND REQ_DISTS.uom_conversion_rate = -999
         -- the uom function returns -999 on error
         AND rownum = 1 -- only need there to be one for it to be an error
                        -- (also, without this causes an error for > 1)
         ;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_uom_conversion_error := 'N';
      END;

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_uom_conversion_error',l_uom_conversion_error);
      END IF;

      IF (l_uom_conversion_error = 'Y') THEN
         l_progress := '040';
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_progress := '050';

      -- bug 3435571: call round_and_convert amts for main doc amt_closed
      -- This is because for Services PO autocreated from Services Req, the
      -- Req amts are in functional currency while the PO closed amt could be
      -- in foreign currency.  The call below populates a separate column
      -- PO_DISTS.amt_closed_func in functional currency so that it can be
      -- directly compared to the Req amt.
      round_and_convert_amounts(
         p_action => p_action
      ,  p_currency_code_func => p_currency_code_func
      ,  p_min_acct_unit_func => p_min_acct_unit_func
      ,  p_cur_precision_func => p_cur_precision_func
      ,  p_column_to_use => g_column_AMT_CLOSED
      );

      IF p_action NOT IN (g_action_INVOICE_CANCEL,
                          g_action_CR_MEMO_CANCEL) THEN

         -- p_action is one of: Check/Do Reserve, Unreserve, Reject
         -- Note: FC, Undo FC, Return, Adjust do not have backing Reqs,
         -- Cancel w/ recreate demand uses new Req line (so not this calc)
         -- and backing Req for Invoice Cancel is calculated separately
         l_progress := '060';

         UPDATE PO_ENCUMBRANCE_GT REQ_DISTS
         SET REQ_DISTS.amt_closed =
            (SELECT
               DECODE(  REQ_DISTS.amount_based_flag

                     -- quantity based
                     ,  'N', PO_DISTS.qty_closed
                              * NVL(REQ_DISTS.uom_conversion_rate,1)
                              * REQ_DISTS.price

                     -- amount based
                     ,  PO_DISTS.amt_closed_func  --bug 3435571
               )
             FROM PO_ENCUMBRANCE_GT PO_DISTS
             WHERE REQ_DISTS.origin_sequence_num = PO_DISTS.sequence_num
             AND PO_DISTS.distribution_type <> g_dist_type_REQUISITION
            )
         WHERE REQ_DISTS.distribution_type = g_dist_type_REQUISITION
         AND REQ_DISTS.prevent_encumbrance_flag = 'N'
         ;

      ELSE
         -- p_action is Invoice/Credit Memo Cancel
         l_progress := '070';

         UPDATE PO_ENCUMBRANCE_GT REQ_DISTS
         SET REQ_DISTS.qty_open =
            (SELECT
               DECODE(  greatest(0, REQ_DISTS.qty_ordered -
                                    (PO_DISTS.qty_closed *
                                    NVL(REQ_DISTS.uom_conversion_rate,1))
                                 )

                     --Req qty < PO qty
                     --put (Req qty - PO billed qty) on Req
                     ,  0 , (REQ_DISTS.qty_ordered -
                              ( NVL(REQ_DISTS.uom_conversion_rate,1)
                                * (PO_DISTS.qty_closed
                                   - p_ap_cancelled_qty) )
                             )

                     --if zero, Req qty > PO billed qty
                     --put entire cancelled qty on Req
                     ,  (p_ap_cancelled_qty
                           * NVL(REQ_DISTS.uom_conversion_rate,1))
                     )
            FROM PO_ENCUMBRANCE_GT PO_DISTS
            WHERE REQ_DISTS.origin_sequence_num = PO_DISTS.sequence_num
            AND PO_DISTS.distribution_type <> g_dist_type_REQUISITION
            ) --end select
         WHERE REQ_DISTS.distribution_type = g_dist_type_REQUISITION
         AND REQ_DISTS.prevent_encumbrance_flag = 'N'
         AND REQ_DISTS.amount_based_flag = 'N'
         ;

         l_progress := '080';

         UPDATE PO_ENCUMBRANCE_GT REQ_DISTS
         SET REQ_DISTS.amt_open =
            (SELECT
               DECODE(  REQ_DISTS.amount_based_flag

                     --quantity-based
                     ,  'N', REQ_DISTS.qty_open * REQ_DISTS.price

                     , --amount based
                     DECODE( greatest(0, REQ_DISTS.amt_ordered -
                                         PO_DISTS.amt_closed_func) --bug 3435571

                           --if zero, Req amt > PO billed amt
                           --put (Req amt - PO billed amt) on Req
                           ,  0 , (REQ_DISTS.amt_ordered
                                   - (PO_DISTS.amt_closed_func  --bug 3435571
                                   - p_ap_amt_billed_change))  -- bug 3480949: fixed parenthesis

                           --put entire cancelled amt on Req
                           --we will add tax to and round this amt
                           ,  p_ap_amt_billed_change
                           )
                     )
            FROM PO_ENCUMBRANCE_GT PO_DISTS
            WHERE REQ_DISTS.origin_sequence_num = PO_DISTS.sequence_num
            AND PO_DISTS.distribution_type <> g_dist_type_REQUISITION
            )
         WHERE REQ_DISTS.distribution_type = g_dist_type_REQUISITION
         AND REQ_DISTS.prevent_encumbrance_flag = 'N'
         ;

         l_progress := '090';


      END IF; --p_action is Inv Cancel vs other actions

   END IF;  -- p_action <> Cancel

   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
         'Calculated amount_closed for backing Reqs'
         );
      PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows
         ,po_tbl_varchar30('prevent_encumbrance_flag','amount_based_flag'
            ,'qty_open','qty_ordered','qty_closed','uom_conversion_rate'
            ,'quantity_billed','distribution_type','sequence_num','origin_sequence_num'
            ,'amt_open','price','amt_ordered','amt_closed','amount_billed'
            )
         );
   END IF;

END IF;  -- doc type is one that can have a backing Req


-- Calculations for Backing PPOs:
IF (p_doc_subtype = g_doc_subtype_SCHEDULED) THEN

   -- For backing PPOs of Scheduled Releases, we do not calculate an
   -- explicit 'closed' amount.  Instead, we update the 'open quantity'
   -- of the PPO, based on the SR open quantity.
   -- This PPO open quantity is then used to:
   -- 1) calculate the PPO open amt directly (not amt_ordered - amt_closed)
   --    in the get_final_amts procedure (this needs to be calculated b/c
   --    PPO can have different price from SR, can't assume SR's amt_open
   --    will be same amt for the backing PPO trxn).
   -- 2) update the PPO unencumbered_quantity during post-processing.

   l_progress := '100';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'Starting calculations for backing PPOs');
   END IF;

   IF p_action NOT IN (g_action_INVOICE_CANCEL, g_action_CR_MEMO_CANCEL) THEN

      -- p_action is one of: Check/Do Reserve, Unreserve, Reject, Cancel, Adjust
      -- Note: FC, Undo FC, Return do not have backing PPO scenarios,
      -- and backing PPO qty for Invoice Cancel is calculated separately
      l_progress := '110';

      UPDATE PO_ENCUMBRANCE_GT PPO_DISTS
      SET PPO_DISTS.qty_open =
         (SELECT SR_DISTS.qty_ordered - SR_DISTS.qty_closed
          FROM PO_ENCUMBRANCE_GT SR_DISTS
          WHERE SR_DISTS.sequence_num = PPO_DISTS.origin_sequence_num
         )
      WHERE PPO_DISTS.origin_sequence_num IS NOT NULL
      AND PPO_DISTS.prevent_encumbrance_flag = 'N'
      ;

   ELSE

      -- p_action is Invoice/Credit Memo Cancel
      l_progress := '120';

      UPDATE PO_ENCUMBRANCE_GT PPO_DISTS
      SET PPO_DISTS.qty_open =
         (SELECT
            DECODE(  greatest(0, SR_DISTS.qty_ordered -
                                    SR_DISTS.qty_closed
                              )

                  --put difference between SR ord and SR billed
                  --back on PPO
                  ,  0 , SR_DISTS.qty_ordered -
                           DECODE(  p_action
                                 ,  g_action_INVOICE_CANCEL,
                                       SR_DISTS.quantity_billed

                                 -- cr memo cancel
                                 ,  SR_DISTS.quantity_billed +
                                       p_ap_cancelled_qty
                                 )

                  --put entire cancelled qty on PPO
                  ,  p_ap_cancelled_qty
                  )
         FROM PO_ENCUMBRANCE_GT SR_DISTS
         WHERE PPO_DISTS.origin_sequence_num = SR_DISTS.sequence_num
         )
      WHERE PPO_DISTS.origin_sequence_num IS NOT NULL
      AND PPO_DISTS.prevent_encumbrance_flag = 'N'
      ;

   END IF;  -- if action is Invoice Cancel vs. other actions

   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
         'Updated qty_open for backing PPO'
      );
      PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows
         ,po_tbl_varchar30('prevent_encumbrance_flag'
            ,'qty_open','qty_ordered','qty_closed','quantity_billed'
            ,'distribution_type','sequence_num','origin_sequence_num')
      );
   END IF;

END IF; -- doc can have a backing PPO

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

  WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_backing_doc_amts;



-------------------------------------------------------------------------------
--Start of Comments
--Name: get_final_amounts
--Pre-reqs:
--  The PO_ENCUMBRANCE_GT temp table has been populated with all
--  required information about the main and backing documents; and
--  Encumbrance is on for the doc type of the main doc.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  Based on the initial encumbrance amounts, and any amounts that are already
--  closed (calculated previously), this procedure sets the final transaction
--  amount on each distribution.  This includes currency conversion and final
--  rounding.  Additionally, this is the procedure in which we adjust any
--  backing PA amounts to ensure that their sum is within the PA limits
--Parameters:
--IN:
--p_action
--   Specifies the action that is being taken on the main doc.
--p_doc_type
--   Differentiates between the doc being a REQ, PO, or RELEASE
--p_doc_subtype
--   Used to differentiate between
--      Scheduled Release vs. Blanket Release
--      Std PO vs. PPO
--p_currency_code_func
--   Identifies the currency that is defined as the functional
--   currency for the current set of books
--p_min_acct_unit_func
--   The minimum accountable unit (defined in FND_CURRENCIES) of the
--   functional currency for the currency Set of Books
--p_cur_precision_func
--   The precision (defined in FND_CURRENCIES) of the functional
--   currency for the current Set of Books
--p_ap_reinstated_enc_amt
--   For Invoice/Credit Memo cancel only: the amount of encumbrance
--   put back on by AP (w/o any AP variances)
--p_is_complex_work_po
--   Boolean value indicating whether the document the encumbrance
--   action is being taken on is a Complex Work PO or not
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_final_amounts(
   p_action                IN  VARCHAR2
,  p_doc_type              IN  VARCHAR2
,  p_doc_subtype           IN  VARCHAR2
,  p_currency_code_func    IN  VARCHAR2
,  p_min_acct_unit_func    IN  NUMBER
,  p_cur_precision_func    IN  NUMBER
,  p_ap_reinstated_enc_amt IN  NUMBER
,  p_is_complex_work_po    IN  BOOLEAN --<Complex Work R12>
)
IS
   l_api_name     CONSTANT VARCHAR2(40) := 'GET_FINAL_AMOUNTS';
   l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
   l_progress     VARCHAR2(3) := '000';

  --<Bug 13503748 Encumbrance ER START>--
   l_sequence_num_tbl PO_TBL_NUMBER;
   l_enc_amt_tbl PO_TBL_NUMBER;
  --<Bug 13503748 Encumbrance ER END>--

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype', p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_currency_code_func', p_currency_code_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_min_acct_unit_func', p_min_acct_unit_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_cur_precision_func', p_cur_precision_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_ap_reinstated_enc_amt', p_ap_reinstated_enc_amt);
END IF;

-- First, calculate the 'open' amount, which is basically the
-- transaction amount without any tax or rounding.

-- Note: for backing PPO trxns, we base the transaction amount of
-- the backing PPO not on how much encumbrance is left on the PPO,
-- but on how much we are transacting on the current SR.  This is
-- because we can have multiple SRs against a single backing PPO, so
-- we are not always relieving the full PPO amt.

IF (p_doc_subtype = g_doc_subtype_SCHEDULED) THEN

   l_progress := '010';

   UPDATE PO_ENCUMBRANCE_GT PPO_DISTS
   SET PPO_DISTS.amt_open =
       PPO_DISTS.qty_open * PPO_DISTS.price
       -- no Services lines on PPOs/SRs
   WHERE PPO_DISTS.origin_sequence_num IS NOT NULL  --backing document
   AND PPO_DISTS.distribution_type = g_dist_type_PLANNED
   AND PPO_DISTS.prevent_encumbrance_flag = 'N'
   ;

END IF;

l_progress := '020';

-- For cases other than the backing PPO, the amt_open represents
-- the difference in the original amount of encumbrance and the
-- amount of encumbrance already moved off to actuals.
-- The greatest(0, <>) adjusts for over-delivered/billed case

UPDATE PO_ENCUMBRANCE_GT DISTS
SET DISTS.amt_open =
   DECODE( DISTS.amt_open

         -- if NULL, then it needs to be calculated still
         ,  NULL,
               GREATEST( 0 , DISTS.amt_ordered - nvl(DISTS.amt_closed, 0))

         -- already calculated (backing PPO), so do not overwrite
         ,  GREATEST(0, DISTS.amt_open)
         )
WHERE DISTS.prevent_encumbrance_flag = 'N'
;

l_progress := '030';


IF p_action IN (g_action_FINAL_CLOSE, g_action_UNDO_FINAL_CLOSE) THEN

   -- For Final Close and Undo Final Close actions only, we need to
   -- further subtract out the cancelled amount to get the true open amt
   -- Note: these actions do not create backing doc trxns, so we are
   --       only peforming this subtraction for the main document

   l_progress := '040';


   -- Bug 3498811: Truncate amt_open to 0 if it is less than 0.

   --<bug#5199301 START>
   --We do not have to subtract cancelled amount on BPA's because
   --you cannot cancel quantity/amount on the BPA itself. You can do
   --it only on releases. For BPA's the unencumbered amount accounts
   --for cancelled quantity of the relese as well.

   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET DISTS.amt_open =
      GREATEST( 0,
                  DISTS.amt_open -
                     DECODE(  DISTS.amount_based_flag

                         -- quantity_based:
                         ,  'N',  nvl(quantity_cancelled, 0) * nvl(DISTS.price,0)

                         -- Services line:
                         ,  nvl(amount_cancelled, 0)
                         )
              )
   WHERE DISTS.prevent_encumbrance_flag = 'N'
     AND DISTS.distribution_type <>g_dist_type_AGREEMENT
   ;
   --<bug#5199301 END>

   l_progress := '050';

  -- end if action is Final Close, Undo Final Close

ELSIF p_action IN (g_action_INVOICE_CANCEL, g_action_CR_MEMO_CANCEL) THEN

   -- Bug 3480949: Logic changed, and moved up here
   -- For these actions, AP passes us the amount they posted
   -- to GL, excluding taxes.  They also call us with the tax only in
   -- a second API call, but that API call is ignored.  So, set the
   -- amt_open to p_ap_reinstated_enc_amt, so that we add tax below.

   l_progress := '055';

   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET DISTS.amt_open = p_ap_reinstated_enc_amt
   WHERE DISTS.prevent_encumbrance_flag = 'N'
   AND DISTS.origin_sequence_num IS NULL  -- main doc
   ;

   -- end elsif action in Invoice Cancel, CR Memo Cancel

END IF;



IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Updated amt_open for all lines'
   );
   PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows
                        ,po_tbl_varchar30('prevent_encumbrance_flag' ,'amt_open',
                        'qty_ordered','qty_closed','quantity_billed', 'quantity_cancelled'
                        ,'distribution_type','sequence_num','origin_sequence_num')
   );
END IF;


-- Before we do any rounding, we need to add in the tax (pro-rated)
UPDATE PO_ENCUMBRANCE_GT DISTS
SET DISTS.pre_round_amt = (DISTS.amt_open * DISTS.nonrecoverable_tax_rate)
WHERE DISTS.prevent_encumbrance_flag = 'N'
AND DISTS.amt_open IS NOT NULL
;

-- <13503748: Edit without unreserve ER START>
-- when the action is reserve for SPO and amount_changed_flag is 'Y' then
-- pre_round_amt should consider the modified amount ordered.
-- when action is cancel it should relieve the extra encumbered amount.

IF p_doc_subtype = g_doc_subtype_STANDARD THEN

l_progress := '060';

  -- calling this function as to pass the correct entered amount based on the currency and rounding used.
  -- passing encumbered amount of po_encumbrance_gt for this purpose.
  -- This is required to get the correct delta amount from pre round amount and encumbered amount.
  round_and_convert_amounts( p_action => p_action
                             ,p_currency_code_func => p_currency_code_func
                             , p_min_acct_unit_func => p_min_acct_unit_func
                             , p_cur_precision_func => p_cur_precision_func
                             , p_column_to_use => g_column_PO_ENCUMBERED_AMOUNT);

  l_progress := '070';

  SELECT num1,
         num2
    BULK COLLECT INTO
         l_sequence_num_tbl,
	 l_enc_amt_tbl
    FROM po_session_gt
   WHERE index_char1= g_column_PO_ENCUMBERED_AMOUNT;

    IF g_debug_stmt THEN
      SELECT rowid BULK COLLECT INTO PO_DEBUG.g_rowid_tbl
      FROM PO_SESSION_GT WHERE index_char1 = g_column_PO_ENCUMBERED_AMOUNT;

      PO_DEBUG.debug_table(l_log_head,l_progress,'PO_SESSION_GT',
            PO_DEBUG.g_rowid_tbl,
            po_tbl_varchar30('index_char1','num1','num2')
            );
   END IF;

     FORALL i IN 1..l_sequence_num_tbl.count
     UPDATE PO_ENCUMBRANCE_GT DISTS
        SET DISTS.pre_round_amt = DECODE (p_action ,g_action_RESERVE
	                                            ,((DISTS.amt_ordered* DISTS.nonrecoverable_tax_rate )
						    - l_enc_amt_tbl(i))
						    ,g_action_CANCEL
					 	   ,l_enc_amt_tbl(i)-( DISTS.amt_closed*DISTS.nonrecoverable_tax_rate)
					  )
      WHERE((p_action = g_action_RESERVE and Nvl(DISTS.amount_changed_flag,'N') = 'Y' ) or
             p_action = g_action_CANCEL )  --Bug 16320071 Changed the where clause to fix cancel issue
        AND dists.sequence_num = l_sequence_num_tbl(i)
        AND dists.origin_sequence_num IS NULL;
        -- Bug 16781315: When cancelling a PO with backing requisition,	without cancelling a req
        -- error occurs.

ELSIF (p_doc_subtype = g_doc_subtype_BLANKET AND p_doc_type = g_doc_type_PA) THEN

  l_progress := '080';

  IF p_action = g_action_RESERVE THEN
   UPDATE PO_ENCUMBRANCE_GT DISTS
		SET DISTS.pre_round_amt = (DISTS.amount_to_encumber  - ( DISTS.encumbered_amount + DISTS.unencumbered_amount ))
		WHERE Nvl(DISTS.amount_changed_flag,'N') = 'Y';
  ELSIF p_action = g_action_CANCEL THEN
  	UPDATE PO_ENCUMBRANCE_GT DISTS
	SET DISTS.pre_round_amt = (DISTS.encumbered_amount)
	WHERE DISTS.distribution_type = 'AGREEMENT';
  END IF;
END IF;


-- <13503748: Edit without unreserve ER END>

l_progress := '090';
IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
      'Updated pre_round_amt for all lines'
   );
   PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows
                        ,po_tbl_varchar30('prevent_encumbrance_flag' ,'pre_round_amt')
   );
END IF;


-- By now, all of the pre_round_amt columns should be populated,
-- so we can do the final currency conversion and rounding now
-- Note: we used this procedure on other columns previously for 2 cases
-- (backing Req and backing PA), when we needed to convert an intermediate
-- value for comparison.  However, the actual trxn amounts in the table
-- remained in foreign currency.  Now, this call will populate the
-- final_amt column, in which ALL entries are in functional currency.
round_and_convert_amounts(
   p_action => p_action
,  p_currency_code_func => p_currency_code_func
,  p_min_acct_unit_func => p_min_acct_unit_func
,  p_cur_precision_func => p_cur_precision_func
,  p_column_to_use => g_column_PRE_ROUND_AMT
)
;



IF p_doc_subtype IN (g_doc_subtype_STANDARD, g_doc_subtype_BLANKET,
                     g_doc_subtype_MIXED_PO_RELEASE) THEN
   -- only Std POs and Bl Releases can have backing PAs
   l_progress := '100';

   -- At this point, the final_amt column values for the
   -- backing PA entries are based on the final_amt values for
   -- the corresponding PO/Rel distribution.
   -- However, it is possible that this would over-relieve the
   -- BPA, because the BPA amount_to_encumber may be less than
   -- the overall BPA amount_limit for releases.
   -- This procedure will correct the backing PA entries, if
   -- this over-relieving situation arises.  We do this correction
   -- of the backing PA amounts AFTER doing the rounding and
   -- conversion to avoid the adjusted totals being off
   -- by penny differences.

   check_backing_pa_amounts(
      p_action => p_action
   );


   --<Complex Work R12 START>: For Complex Work, the backing Req amount should
   --be set AFTER the main PO doc amount has had tax and rounding calculations
   --performed. (Similar reasoning as for backing BPA logic above)
   IF (p_is_complex_work_po) THEN

     set_complex_work_req_amounts(
       p_action => p_action
     );

   END IF;
   --<Complex Work R12 END>

END IF;

l_progress := '110';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

  WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_final_amounts;



-------------------------------------------------------------------------------
--Start of Comments
--Name: round_and_convert_amounts
--Pre-reqs:
--  The PO_ENCUMBRANCE_GT temp table has been populated with all
--  required information about the main and backing documents; and
--  Encumbrance is on for the doc type of the main doc.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  This procedure is a wrapper around the currency rounding procedure
--  in PO_CORE_S2.  It pulls the appropriate column to be rounded from
--  the Encumbrance GTT and also updates a corresponding column with
--  the results of the round/conversion.
--  GTT Column to Round           Column with Rounded Result
--  AMOUNT_TO_ENCUMBER            AMT_TO_ENCUMBER_FUNC
--  AMT_CLOSED                    AMT_CLOSED_FUNC
--  PRE_ROUND_AMT                 FINAL_AMT
--Parameters:
--IN:
--p_action
--  Current encumbrance action being performed
--p_currency_code_func
--   Identifies the currency that is defined as the functional
--   currency for the current set of books
--p_min_acct_unit_func
--   The minimum accountable unit (defined in FND_CURRENCIES) of the
--   functional currency for the currency Set of Books
--p_cur_precision_func
--   The precision (defined in FND_CURRENCIES) of the functional
--   currency for the current Set of Books
--p_column_to_use
--  Specifies with column of PO_ENCUMBRANCE_GT to convert and round
--  Valid Values:
--     g_column_AMOUNT_TO_ENCUMBER,
--     g_column_AMOUNT_CLOSED
--     g_column_PRE_ROUND_AMT
--Testing:
--  List any test scripts that exist, etc.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE round_and_convert_amounts(
   p_action              IN  VARCHAR2
,  p_currency_code_func  IN  VARCHAR2
,  p_min_acct_unit_func  IN  NUMBER
,  p_cur_precision_func  IN  NUMBER
,  p_column_to_use       IN  VARCHAR2
)

IS
   l_api_name CONSTANT varchar2(40) := 'ROUND_AND_CONVERT_AMOUNTS';
   l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
   l_progress     VARCHAR2(3) := '000';

   l_return_status              VARCHAR2(1);
   l_sequence_num_tbl           PO_TBL_NUMBER;
   l_amount_to_round_tbl        PO_TBL_NUMBER;
   l_exchange_rate_tbl          PO_TBL_NUMBER;
   l_cur_precision_foreign_tbl  PO_TBL_NUMBER;
   l_min_acct_unit_foreign_tbl  PO_TBL_NUMBER;
   l_cur_precision_func_tbl     PO_TBL_NUMBER;
   l_min_acct_unit_func_tbl     PO_TBL_NUMBER;
   l_round_only_flag_tbl        PO_TBL_VARCHAR1;  --bug 3568671
   l_amount_result_tbl          PO_TBL_NUMBER;

-- Bug 15987200
   l_Accrue_On_Receipt_Flag     PO_TBL_VARCHAR1;
   l_distribution_id_tbl            PO_TBL_NUMBER;
   l_msg_count VARCHAR2(10);
   l_msg_data VARCHAR2(10);

   l_origin_sequence_num_tbl    PO_TBL_NUMBER;  -- bug 3480949

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_currency_code_func', p_currency_code_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_min_acct_unit_func', p_min_acct_unit_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_cur_precision_func', p_cur_precision_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_column_to_use',p_column_to_use);
END IF;

SELECT
   DISTS.sequence_num
,  DECODE( p_column_to_use

         ,  g_column_AMOUNT_TO_ENCUMBER, DISTS.amount_to_encumber

         ,  g_column_AMT_CLOSED, DISTS.amt_closed

         ,  g_column_PRE_ROUND_AMT, DISTS.pre_round_amt

         ,  g_column_PO_ENCUMBERED_AMOUNT,DISTS.encumbered_amount
	     -- Bug 15987200
         , g_column_PO_REVERSAL_AMOUNT , DISTS.amount_reversed
	 ,  NULL
   )

-- bug 3568671: removed conditional setting of rate.
-- we now use the l_round_only_flag_tbl to indicate that
-- we do not want to do a currency conversion.
-- Bug 13503748 Encumbrance ER
-- Encumbered amount should be converted from functional to foreign currency
-- so passing inverse of rate value
,  DECODE ( p_column_to_use ,g_column_PO_ENCUMBERED_AMOUNT , 1/NVL(DISTS.rate,1)
           ,g_column_PO_REVERSAL_AMOUNT, 1/NVL(DISTS.rate,1)
			    ,DISTS.rate)
       -- Bug 15987200
,  DISTS.cur_precision_foreign
,  DISTS.min_acct_unit_foreign
,  p_cur_precision_func
,  p_min_acct_unit_func

-- bug 3568671: For BPA distributions, currency conversion
-- should only occur for column to use = g_column_AMOUNT_TO_ENCUMBER.
-- We do this initial conversion for foreign currency BPAs, and then
-- all other calculated values are already in functional currency
-- (i.e amt_closed/pre_round_amt), however, there will still be a
-- foreign currency code and rate in the GTT.  We do not want to repeat
-- the currency conversion a 2nd time.  But rounding should occur for all
-- 3 of these columns.
-- Rounding without currency conversion is achieved by setting the
-- round_only_flag to 'Y' when calling PO_CORE_S2.round_and_convert_currency
,  DECODE ( DISTS.distribution_type
           , g_dist_type_AGREEMENT, DECODE( p_column_to_use
                                          , g_column_AMOUNT_TO_ENCUMBER, 'N'
                                          , 'Y'
                                    )
           , 'N'
   )
  -- Bug 3480949: capture origin_sequence_number
,  DISTS.origin_sequence_num
BULK COLLECT INTO
   l_sequence_num_tbl
,  l_amount_to_round_tbl
,  l_exchange_rate_tbl
,  l_cur_precision_foreign_tbl
,  l_min_acct_unit_foreign_tbl
,  l_cur_precision_func_tbl
,  l_min_acct_unit_func_tbl
,  l_round_only_flag_tbl     --bug 3568671
,  l_origin_sequence_num_tbl -- bug 3480949
FROM PO_ENCUMBRANCE_GT DISTS
WHERE DISTS.prevent_encumbrance_flag = 'N'
ORDER BY DISTS.sequence_num
;


-- Bug 3480949: Do not convert currency for the main document
-- if action is invoice or credit memo cancel.  In that case,
-- which occurs through the reinstate PO encumbrance API call by AP,
-- the final amount should be set to rounded value of
-- p_ap_reinstated_enc_amt * nonrecoverable_tax rate.  Do not do
-- currency conversion, as AP passes us that value in func. currency.

IF (p_action IN (g_action_INVOICE_CANCEL, g_action_CR_MEMO_CANCEL))
THEN

  FOR i IN 1..l_round_only_flag_tbl.COUNT
  LOOP
    -- Set main doc round only flag to 'Y'
    IF (l_origin_sequence_num_tbl(i) is NULL) THEN
       l_round_only_flag_tbl(i) := 'Y';
    END IF;

  END LOOP;

END IF;

l_progress := '010';

-- Call the currency conversion/rounding routine
PO_CORE_S2.round_and_convert_currency(
   x_return_status               => l_return_status
,  p_unique_id_tbl               => l_sequence_num_tbl  --bug 4878973
,  p_amount_in_tbl               => l_amount_to_round_tbl
,  p_exchange_rate_tbl           => l_exchange_rate_tbl
,  p_from_currency_precision_tbl => l_cur_precision_foreign_tbl
,  p_from_currency_mau_tbl       => l_min_acct_unit_foreign_tbl
,  p_to_currency_precision_tbl   => l_cur_precision_func_tbl
,  p_to_currency_mau_tbl         => l_min_acct_unit_func_tbl
,  p_round_only_flag_tbl         => l_round_only_flag_tbl --bug 3568671
,  x_amount_out_tbl              => l_amount_result_tbl
);

IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   l_progress := '015';
   -- the API already pushed the SQL error details
   -- onto the message stack, so just raise this to
   -- bubble back up to do_action.
   RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '020';

-- Now update the appropriate column of the Encumbrance GTT
-- with the converted/rounded amounts.  The DECODEs are used
-- so that if we do not update those columns which do not
-- correspond to the value of p_column_to_use

FORALL i IN 1 .. l_sequence_num_tbl.COUNT
   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET
      amt_to_encumber_func =
        DECODE( p_column_to_use
              ,  g_column_AMOUNT_TO_ENCUMBER, l_amount_result_tbl(i)
              ,  DISTS.amt_to_encumber_func
        )

   ,  amt_closed_func =
        DECODE( p_column_to_use
              ,  g_column_AMT_CLOSED, l_amount_result_tbl(i)
              ,  DISTS.amt_closed_func
        )

   ,  final_amt =
        DECODE( p_column_to_use
              ,  g_column_PRE_ROUND_AMT, l_amount_result_tbl(i)
              ,  DISTS.final_amt
        )
    --Bug 15987200
   , pre_round_amt =
         DECODE( p_column_to_use
              ,  g_column_PO_REVERSAL_AMOUNT, pre_round_amt + l_amount_result_tbl(i)
              ,  DISTS.pre_round_amt
        )
   WHERE DISTS.prevent_encumbrance_flag = 'N'
   AND   DISTS.sequence_num = l_sequence_num_tbl(i)
   ;

l_progress := '030';

--<Bug 13503748  Encumbrance ER  START>--
-- Encumbered amount has been converted from functional currency to
-- foreign currency to get delta amount from pre round amount
IF p_column_to_use IN (g_column_PO_ENCUMBERED_AMOUNT) THEN

  l_progress := '040';
  IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Inserting the converted encumbered amount into po session gt');
    END IF;

  FORALL i IN 1..l_sequence_num_tbl.COUNT
  INSERT INTO po_session_gt(index_char1,num1,num2)
  VALUES (g_column_PO_ENCUMBERED_AMOUNT,l_sequence_num_tbl(i),l_amount_result_tbl(i));
END IF;
--<Bug 13503748  Encumbrance ER  END>--


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

   WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END round_and_convert_amounts;


-------------------------------------------------------------------------------
--Start of Comments
--Name: check_backing_pa_amounts
--Pre-reqs:
--  The final_amt column of PO_ENCUMBRANCE_GT has
--  been populated correctly with the rounded functional amount for
--  each of the distributions with backing agreements
--  (PO against GA, Release against BPA)
--  and the backing agreement distributions have also been loaded into
--  PO_ENCUMBRANCE_GT.
--  It only makes sense to call this if both PO and Req encumbrance are on
--  (i.e., blanket encumbrance is enabled).
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  n/a
--Function:
--  This procedure updates the final_amt column of backing agreement
--  rows in PO_ENCUMBRANCE_GT, based on the final_amt for each
--  of the PO/Release distributions.
--  It prohibits the sum of the amounts against the backing agreement
--  from exceeding the limits of the agreement's encumbrance, based on
--  the action being taken.
--Parameters:
--IN:
--p_action
--  Specifies the action that is being taken on the main doc.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_backing_pa_amounts(
   p_action        IN   VARCHAR2
)
IS

-- Scalar Variables
   l_api_name CONSTANT 		varchar2(40) := 'CHECK_BACKING_PA_AMOUNTS';
   l_progress 			varchar2(3);
   l_adjust_flag 		varchar2(1) := 'N';
   l_running_total 		number := 0;
   l_amount_available 		number := 0;
   l_start_row  		number := 0;
   l_end_row    		number := 0;
   l_changed_amounts_flag       varchar2(1) := 'N';

-- Collections
   l_multiplier_tbl  	       po_tbl_number;
   l_pa_dist_id_tbl  	       po_tbl_number;
   l_pa_sequence_num_tbl       po_tbl_number;
   l_amt_to_encumber_func_tbl  po_tbl_number;
   l_unencumbered_amount_tbl   po_tbl_number;
   l_amount_tbl 	       po_tbl_number;

BEGIN

l_progress := '000';

If g_fnd_debug = 'Y' Then
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  g_log_head || l_api_name || '.' || l_progress,
                  'Start of procedure'
                 );
   END IF;
End If;

-- Gather the data we need into pl/sql tables
-- The logic is performed in a pl/sql loop due to performance limitations
-- when doing running sums in SQL.
SELECT
   DECODE( p_action
         -- For Adjust, row is +/- depending on whether its new/old
         ,  g_action_ADJUST, DECODE( PA_DISTS.adjustment_status
                                   ,  g_adj_status_OLD,  -1
                                   ,  1
                             )

         -- Reserve, multiplier is always positive 1
         ,  g_action_RESERVE,  1

         -- Other actions are all reversals, so use -1
         ,  -1
   )
,  PA_DISTS.distribution_id
,  PA_DISTS.sequence_num
,  PA_DISTS.amt_to_encumber_func
,  PA_DISTS.unencumbered_amount
,  PO_DISTS.final_amt
BULK COLLECT INTO
   l_multiplier_tbl
,  l_pa_dist_id_tbl
,  l_pa_sequence_num_tbl
,  l_amt_to_encumber_func_tbl
,  l_unencumbered_amount_tbl
,  l_amount_tbl
FROM
   PO_ENCUMBRANCE_GT PA_DISTS
,  PO_ENCUMBRANCE_GT PO_DISTS
WHERE PA_DISTS.origin_sequence_num = PO_DISTS.sequence_num
AND PA_DISTS.distribution_id = PO_DISTS.agreement_dist_id
AND PO_DISTS.prevent_encumbrance_flag = 'N'
AND PA_DISTS.distribution_type = g_dist_type_AGREEMENT
ORDER BY PA_DISTS.distribution_id, PO_DISTS.gl_encumbered_date DESC;

   -- Note: the value in l_amount_tbl is always positive.
   -- Need to look at corresponding value in l_multiplier_tbl to
   -- determine whether it is adding/removing funds:
   -- If multiplier is -1, then the backing PA acct is being debited
   --                        (putting funds back on it)
   -- If multiplier is 1, then the backing PA acct is being credited
   --                        (removing funds from it)


l_progress := '010';

If g_fnd_debug = 'Y' Then
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  g_log_head || l_api_name || '.' || l_progress,
                  'Before looping'
                 );
   END IF;
End If;


-- The amount used on the backing BPA/GA is equal to the amount used on the
-- Release/PO, except:
--
-- Reserve, Upward Adjust of Release/PO:
-- The sum of all of the backing CRs to the BPA/GA cannot exceed
-- amt_to_encumber_func - unencumbered_amount
--
-- Unreserve, Downward Adjust (and other reverses) of Release/PO:
-- The sum of all of the backing DRs to the BPA/GA cannot exceed
-- unencumbered_amount
--

FOR i IN 1 .. l_pa_dist_id_tbl.COUNT LOOP
   IF (i = 1) THEN
      -- first PA dist in tbl
      l_start_row := i;
      l_running_total := l_amount_tbl(i) * l_multiplier_tbl(i);

   ELSIF l_pa_dist_id_tbl(i) = l_pa_dist_id_tbl(i-1) THEN
      -- current PA is the same PA dist I've been working on
      l_running_total := l_running_total +
                         ( l_amount_tbl(i) * l_multiplier_tbl(i) );

   ELSIF l_pa_dist_id_tbl(i) <> l_pa_dist_id_tbl(i-1) THEN
      -- Hit a new PA dist id.  Mark the end of the old set.
      -- l_running_total is for dist id's between l_start_row and l_end_row

      l_end_row := i-1;

      -- Fix the amounts for the old (i-1) PA dist, if necessary
      correct_backing_pa_amounts(
         p_current_pa_dist_id   => l_pa_dist_id_tbl(l_start_row)
      ,  p_start_row            => l_start_row
      ,  p_end_row              => l_end_row
      ,  p_running_total        => l_running_total
      ,  p_amt_to_enc_func      => l_amt_to_encumber_func_tbl(l_start_row)
      ,  p_unencumbered_amt     => l_unencumbered_amount_tbl(l_start_row)
      ,  p_pa_sequence_num_tbl  => l_pa_sequence_num_tbl
      ,  p_pa_multiplier_tbl    => l_multiplier_tbl
      ,  x_pa_amount_tbl        => l_amount_tbl
      ,  x_changed_amounts_flag => l_changed_amounts_flag
      );

      -- Reset the variables for the current (new) PA dist:
      l_running_total := l_amount_tbl(i) * l_multiplier_tbl(i);
      l_start_row := i;

   END IF;  -- if i=1 or dist(i) ?= dist (i-1)


   IF (i = l_pa_dist_id_tbl.COUNT) THEN
      -- End case:  If I am on the last dist, but it is not a different
      -- PA from the previous dist, I won't know to make the call to
      -- correct_backing_pa_amounts, unless this case is explicitly handled

      l_end_row := i;

      -- Fix the amounts for the current (last) PA dist, if necessary
      correct_backing_pa_amounts(
         p_current_pa_dist_id   => l_pa_dist_id_tbl(l_start_row)
      ,  p_start_row            => l_start_row
      ,  p_end_row              => l_end_row
      ,  p_running_total        => l_running_total
      ,  p_amt_to_enc_func      => l_amt_to_encumber_func_tbl(l_start_row)
      ,  p_unencumbered_amt     => l_unencumbered_amount_tbl(l_start_row)
      ,  p_pa_sequence_num_tbl  => l_pa_sequence_num_tbl
      ,  p_pa_multiplier_tbl    => l_multiplier_tbl
      ,  x_pa_amount_tbl        => l_amount_tbl
      ,  x_changed_amounts_flag => l_changed_amounts_flag
      );

   END IF;  -- if i = last dist id

END LOOP;

l_progress := '020';

-- Then, put the updated amounts back into the main GTT
--IF (l_update_enc_gt_flag = 'Y') THEN

   FORALL i IN 1 .. l_amount_tbl.COUNT
      UPDATE PO_ENCUMBRANCE_GT PA_DISTS
      SET PA_DISTS.final_amt = l_amount_tbl(i)
      WHERE
          PA_DISTS.distribution_id = l_pa_dist_id_tbl(i)
      AND PA_DISTS.sequence_num = l_pa_sequence_num_tbl(i)
      AND PA_DISTS.distribution_type = g_dist_type_AGREEMENT
      ;

   If g_fnd_debug = 'Y' Then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                     g_log_head || l_api_name || '.' || l_progress,
                     'Updated of global temp table PA amounts'
                    );
      END IF;
   End If;

--END IF;

l_progress := '030';

If g_fnd_debug = 'Y' Then
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  g_log_head || l_api_name || '.' || l_progress,
                  'End of procedure'
                 );
   END IF;
End If;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

   WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END check_backing_pa_amounts;


-------------------------------------------------------------------------------
--Start of Comments
--Name: correct_backing_pa_amounts
--Pre-reqs:
--   PO_ENCUMBRANCE_GT is populated correctly with information about all
--   the main doc and backing PA distributions
--Modifies:
--   PO_ENCUMBRANCE_GT
--Locks:
--  n/a
--Function:
--  This procedure updates the final_amt column of backing agreement
--  rows in PO_ENCUMBRANCE_GT, based on the final_amt for each
--  of the PO/Release distributions.
--  It prohibits the sum of the amounts against the backing agreement
--  from exceeding the limits of the agreement's encumbrance, based on
--  the action being taken.
--Parameters:
--IN:
--p_current_pa_dist_id
--  The po_distribution_id of the BPA we are currently checking
--p_start_row
--  Index that indicates where the current BPA dists start in each
--  of the 3 pl/sql table parameters
--p_start_row
--  Index that indicates where the current BPA dists end in each
--  of the 3 pl/sql table parameters
--p_running_total
--  The overall sum of all CRs and DRs against the current PA
--p_amt_to_enc_func
--  The amount to encumber for the current PA, in functional currency
--p_unencumbered_amt
--  The unencumbered amount for the current PA, in functional currency
--p_pa_sequence_num_tbl
--  A colletion of sequence_nums corresponding to the sequence_nums in
--  the PO_ENCUMBRANCE_GT of each backing PA row
--p_pa_multiplier_tbl
--  A collection where each element represents whether the corresponding
--  element of the amount tbl is a DR or CR
--IN OUT:
--x_pa_amount_tbl
--  A collection where each element represent the final_amt calculated
--  in the PO_ENCUMBRANCE_GT table, for a given backing PA entry
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE correct_backing_pa_amounts(
   p_current_pa_dist_id   IN  NUMBER
,  p_start_row            IN  NUMBER
,  p_end_row              IN  NUMBER
,  p_running_total        IN  NUMBER
,  p_amt_to_enc_func      IN  NUMBER
,  p_unencumbered_amt     IN  NUMBER
,  p_pa_sequence_num_tbl  IN  po_tbl_number
,  p_pa_multiplier_tbl    IN  po_tbl_number
,  x_pa_amount_tbl        IN OUT NOCOPY po_tbl_number
,  x_changed_amounts_flag OUT NOCOPY VARCHAR2
)

IS

l_proc_name CONSTANT VARCHAR2(30) := 'CORRECT_BACKING_PA_AMOUNTS';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
l_progress  VARCHAR2(3) := '000';

l_amount_available     NUMBER := 0;
l_current_amount       NUMBER := 0;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_current_pa_dist_id',p_current_pa_dist_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_start_row',p_start_row);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_end_row',p_end_row);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_running_total',p_running_total);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_amt_to_enc_func',p_amt_to_enc_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_unencumbered_amt',p_unencumbered_amt);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_pa_sequence_num_tbl',p_pa_sequence_num_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_pa_multiplier_tbl',p_pa_multiplier_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_pa_amount_tbl',x_pa_amount_tbl);
END IF;

l_progress := '010';

-- Determine the max amount available, depending on whether
-- the overall transaction is a DR or CR:

IF (p_running_total > 0) THEN
   -- The overall backing trxn is relieving the PA (CR against PA acct)
   l_amount_available := p_amt_to_enc_func - p_unencumbered_amt;

ELSIF (p_running_total <= 0) then
   -- The overall backing trxn is encumbering the PA (DR against PA acct)
   l_amount_available := p_unencumbered_amt;

END IF;

-- Now, check if the amount from our running some is greater
-- than the total amount available from above.  If it is, then
-- zero out those distributions that exceed the maximum:
l_progress := '020';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_amount_available',l_amount_available);
END IF;

IF ABS(p_running_total) > l_amount_available THEN
   -- The sum of the PA amount entries is too high.
   -- Some of them will be adjusted downwards.

   l_progress := '100';

   -- First, figure out which amounts to zero out
   FOR i in p_start_row .. p_end_row LOOP

      If SIGN(p_pa_multiplier_tbl(i)) <> SIGN(p_running_total) THEN

         -- In the Adjust case, zero out those rows that are
         -- doing the opposite of the overall transaction (i.e.
         -- zero all CR rows if the overall trxn was a DR)
         x_pa_amount_tbl(i) := 0;

      Else
         -- For the rows with the correct sign, ensure that
         -- their sum does not exceed the amount available

         l_current_amount := x_pa_amount_tbl(i);

         If (l_current_amount <= l_amount_available) Then
            l_amount_available := l_amount_available - l_current_amount;
         Else
            x_pa_amount_tbl(i) := l_amount_available;
            l_amount_available := 0;
         End If;

       End If;

   END LOOP;

   x_changed_amounts_flag := 'Y';

ELSE
   -- this is not the over-relieved case, so no changes required
   x_changed_amounts_flag := 'N';

END IF;  -- if running total was greater than amt available

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_pa_amount_tbl',x_pa_amount_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_changed_amounts_flag',x_changed_amounts_flag);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION

WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_proc_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END correct_backing_pa_amounts;


--<Complex Work R12 START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: set_complex_work_req_amounts
--Pre-reqs:
--  The final_amt column of PO_ENCUMBRANCE_GT has
--  been populated correctly with the rounded functional amount for
--  each of the Complex Work PO distributions
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  n/a
--Function:
--  This procedure updates the final_amt column of backing Req rows in
--  PO_ENCUMBRANCE_GT, based on the final_amt for each of the main doc
--  (Complex Work PO doc) distributions
--  It prohibits the sum of the amounts against the backing Requisition
--  from exceeding the limits of the Requisition's encumbrance, if funds
--  are being returned to the Requisition.  If funds are being liquidated
--  from the Requisition, it ensures that no hanging balances are left on
--  the Requisition
--Parameters:
--IN:
--p_action
--  Specifies the action that is being taken on the main doc.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE set_complex_work_req_amounts(
   p_action        IN   VARCHAR2
)
IS

-- Scalar Variables
  l_api_name CONSTANT 	varchar2(40) := 'SET_COMPLEX_WORK_REQ_AMOUNTS';
  l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  l_progress 		varchar2(3);

-- Collections
  l_req_dist_id_tbl		po_tbl_number;
  l_max_total_tbl		po_tbl_number;
  l_req_dist_gtt_total_tbl 	po_tbl_number;

BEGIN

l_progress := '000';

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
END IF;


-- Algorithm:
-- Set the backing Req final amount to be equal to the main doc final amount.
-- For PO Reserve/Check Funds, the sum for each distinct backing Req dist must
--   equal the total encumbered_amount for that distribution.  Make sure that
--   the last distribution carries any extra balance, or that the distributions
--   are adjusted downwards if they would over-relieve.
-- For PO Unreserve/Reject, the sum for each distinct backing Req distribution
--    may be less than the total allowable amount for the Req, but can not
--    exceed this amount.

-- First, set the backing Req dist final amount equal to the corresponding
-- main doc final amount
UPDATE PO_ENCUMBRANCE_GT BACKING_REQ
SET BACKING_REQ.final_amt =
	(SELECT MAIN_DOC.final_amt
	 FROM PO_ENCUMBRANCE_GT MAIN_DOC
	 WHERE MAIN_DOC.sequence_num = BACKING_REQ.origin_sequence_num
	 AND MAIN_DOC.origin_sequence_num IS NULL)
WHERE BACKING_REQ.origin_sequence_num IS NOT NULL
AND BACKING_REQ.distribution_type = g_dist_type_REQUISITION
AND BACKING_REQ.prevent_encumbrance_flag = 'N'
;
IF g_debug_stmt THEN
   PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows,NULL,'PO');
END IF;
l_progress := '010';

-- Next, extract the l_max_total_tbl for each distinct Req distribution: it
-- is either the current Req encumbered amount (on Reserve/Check Funds actions)
-- or the Req amount ordered (on Unreserve/Reject actions).  Note: the value
-- of amount_ordered is set in the get_initial_amounts procedure.
-- Also, extract the current GTT total for each distinct Req dist, based on
-- what we copied over from the main doc in the first step.
SELECT
  BACKING_REQ.distribution_id
, MAX(CASE WHEN p_action = g_action_RESERVE
	THEN BACKING_REQ.encumbered_amount
	ELSE BACKING_REQ.amt_ordered --bug#5478754
    END)
, SUM(BACKING_REQ.final_amt)
BULK COLLECT INTO
  l_req_dist_id_tbl
, l_max_total_tbl
, l_req_dist_gtt_total_tbl
FROM PO_ENCUMBRANCE_GT BACKING_REQ
WHERE BACKING_REQ.origin_sequence_num IS NOT NULL
AND BACKING_REQ.distribution_type = g_dist_type_REQUISITION
AND BACKING_REQ.prevent_encumbrance_flag = 'N'
GROUP BY distribution_id
;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_req_dist_id_tbl',l_req_dist_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_max_total_tbl',l_max_total_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_req_dist_gtt_total_tbl',l_req_dist_gtt_total_tbl);
END IF;

l_progress := '020';

-- Loop through each distinct Req dist.
-- For each distinct dist where the current GTT total > max total
--   Loop through the dists and adjust downward the remaining req distributions
-- For each distinct dist where the current GTT total < max total
--   If the action is Reserve/Check Funds, set the remaining balance on the
--   last distribution.
--   If the action is Unreserve/Reject, then it is fine for the GTT total to
--   be less than the max total (we are just not putting all possible funds
--   back on the Req)
FOR i IN 1 .. l_req_dist_id_tbl.COUNT LOOP

  IF (l_req_dist_gtt_total_tbl(i) > l_max_total_tbl(i)
      OR (l_req_dist_gtt_total_tbl(i) < l_max_total_tbl(i)
          AND p_action = g_action_RESERVE) )
  THEN

    -- Fix the amounts for the current Req dist as necessary
    correct_backing_req_amounts(
      p_req_dist_id => l_req_dist_id_tbl(i)
    , p_max_total_amount => l_max_total_tbl(i)
    , p_current_total_amount => l_req_dist_gtt_total_tbl(i)
    );

  END IF;

END LOOP;


l_progress := '030';
IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

   WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END set_complex_work_req_amounts;


-------------------------------------------------------------------------------
--Start of Comments
--Name: correct_backing_req_amounts
--Pre-reqs:
--   PO_ENCUMBRANCE_GT is populated correctly with all information about all
--   the main doc and backing Req distributions
--Modifies:
--   PO_ENCUMBRANCE_GT
--Locks:
--  n/a
--Function:
--  This procedure adjusts the final_amt column of backing Req rows in
--  PO_ENCUMBRANCE_GT for the Complex Work case.
--  It prohibits the sum of the amounts against the backing Requisition
--  from exceeding the limits of the Requisition's encumbrance, if funds
--  are being returned to the Requisition.  If funds are being liquidated
--  from the Requisition, it ensures that no hanging balances are left on
--  the Requisition
--Parameters:
--IN:
--p_current_pa_dist_id
--  The po_distribution_id of the BPA we are currently checking
--p_start_row
--  Index that indicates where the current BPA dists start in each
--  of the 3 pl/sql table parameters
--p_start_row
--  Index that indicates where the current BPA dists end in each
--  of the 3 pl/sql table parameters
--p_running_total
--  The overall sum of all CRs and DRs against the current PA
--p_amt_to_enc_func
--  The amount to encumber for the current PA, in functional currency
--p_unencumbered_amt
--  The unencumbered amount for the current PA, in functional currency
--p_pa_sequence_num_tbl
--  A colletion of sequence_nums corresponding to the sequence_nums in
--  the PO_ENCUMBRANCE_GT of each backing PA row
--p_pa_multiplier_tbl
--  A collection where each element represents whether the corresponding
--  element of the amount tbl is a DR or CR
--IN OUT:
--x_pa_amount_tbl
--  A collection where each element represent the final_amt calculated
--  in the PO_ENCUMBRANCE_GT table, for a given backing PA entry
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE correct_backing_req_amounts(
  p_req_dist_id          IN NUMBER
, p_max_total_amount     IN NUMBER
, p_current_total_amount IN NUMBER
)
IS

  l_proc_name CONSTANT VARCHAR2(30) := 'CORRECT_BACKING_REQ_AMOUNTS';
  l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
  l_progress  VARCHAR2(3) := '000';
  l_sequence_num_tbl	po_tbl_number;
  l_gtt_amount_tbl	po_tbl_number;
  l_start_row     	NUMBER := 0;
  l_end_row       	NUMBER := 0;
  l_amount_available	NUMBER;
  l_current_amount	NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_req_dist_id',p_req_dist_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_max_total_amount',p_max_total_amount);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_current_total_amount',p_current_total_amount);
END IF;

l_progress := '010';

SELECT
  sequence_num
, final_amt
BULK COLLECT INTO
  l_sequence_num_tbl
, l_gtt_amount_tbl
FROM PO_ENCUMBRANCE_GT BACKING_REQ
WHERE BACKING_REQ.origin_sequence_num IS NOT NULL
AND BACKING_REQ.distribution_type = g_dist_type_REQUISITION
AND BACKING_REQ.prevent_encumbrance_flag = 'N'
AND BACKING_REQ.distribution_id = p_req_dist_id
ORDER BY distribution_num ASC
;

l_progress := '010';

l_start_row := l_gtt_amount_tbl.FIRST;
l_end_row := l_gtt_amount_tbl.LAST;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_start_row',l_start_row);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_end_row',l_end_row);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_gtt_amount_tbl',l_gtt_amount_tbl);
END IF;

IF (p_max_total_amount > p_current_total_amount) THEN
  -- If p_max_total_amount is greater than p_current_total_amount, then set
  -- the balance on the last distribution.
  l_progress := '020';

  l_gtt_amount_tbl(l_end_row) :=
    l_gtt_amount_tbl(l_end_row) + (p_max_total_amount - p_current_total_amount);
ELSIF (p_max_total_amount < p_current_total_amount) THEN
  -- If p_max_total_amount is less than p_current_total_amount, loop through
  -- the distributions and readjust the last few downward as needed.
  l_progress := '030';

  l_amount_available := p_max_total_amount;
  IF g_debug_stmt THEN
     PO_DEBUG.debug_var(l_log_head,l_progress,'l_amount_available ',l_amount_available );
     PO_DEBUG.debug_var(l_log_head,l_progress,'p_max_total_amount',p_max_total_amount);
  END IF;

  FOR i in l_start_row..l_end_row LOOP

    l_current_amount := l_gtt_amount_tbl(i);

    IF g_debug_stmt THEN
       PO_DEBUG.debug_var(l_log_head,l_progress,'l_current_amount  ',l_current_amount  );
    END IF;
    --<bug#5478754 START>
    --Modified the condition (<= l_amount_available) as
    --(< l_amount_available). This is to ensure that if the remaining
    --quantity is equal to the the current distributions quantity then
    --the l_amount_available is set to 0.
    IF (l_current_amount < l_amount_available) THEN
      l_amount_available := l_amount_available - l_current_amount;
    ELSE
      l_gtt_amount_tbl(i) := l_amount_available;
      l_amount_available := 0;
    END IF;
    --<bug#5478754 END>
  END LOOP;

END IF;

l_progress := '040';

--Update the GTT with the adjusted amounts
FORALL i IN l_start_row..l_end_row
 UPDATE PO_ENCUMBRANCE_GT BACKING_REQ
 SET BACKING_REQ.final_amt = l_gtt_amount_tbl(i)
 WHERE BACKING_REQ.sequence_num = l_sequence_num_tbl(i)
 ;

l_progress := '050';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   --add message to the stack and log a debug msg if necessary
   po_message_s.sql_error(g_pkg_name, l_proc_name, l_progress, SQLCODE, SQLERRM);
   fnd_msg_pub.add;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END correct_backing_req_amounts;
--<Complex Work R12 END>


-------------------------------------------------------------------------------
--Start of Comments
--Name: get_gl_references
--Pre-reqs:
--   PO_ENCUMBRANCE_GT has been populated with the information for
--   each of the distributions that will have an entry in GL_BC_PACKETS.
--Modifies:
--   PO_ENCUMBRANCE_GT
--Locks:
--   n/a
--Function:
--   This procedure updates the references and other non-complex columns
--   in PO_ENCUMBRANCE_GT that map to columns of GL_BC_PACKETS.
--Parameters:
--IN:
--p_action
--   Specifies the action that is being taken on the main doc.
--p_cbc_flag
--  This parameter is only set to Y if the action is one of the CBC Year-End
--  processes.  If this is Y, p_action is either Reserve or Unreserve
--p_req_encumb_type_id
--   The identifier for the requisition encumbrance type, defined
--   in financials_system_parameters
--p_po_encumb_type_id
--   The identifier for the po encumbrance type, defined in
--   financials_system_parameters
--p_invoice_id
--    For transactions that were caused by an invoice action,
--    this is the id of the invoice that started it all (provided by AP).
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_gl_references (
   p_action              IN VARCHAR2
,  p_cbc_flag            IN VARCHAR2
,  p_req_encumb_type_id  IN NUMBER
,  p_po_encumb_type_id   IN NUMBER
,  p_invoice_id          IN NUMBER
)
IS

l_api_name CONSTANT VARCHAR2(30) := 'GET_GL_REFERENCES';
l_log_head CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress VARCHAR2(3) := '000';

l_cbc_action           VARCHAR2(30) := NULL;
l_cbc_line_description PO_LOOKUP_CODES.description%TYPE := NULL;

l_source_doc_reference  PO_ENCUMBRANCE_GT.reference10%TYPE;

/* Start Bug 3292870 */

TYPE g_rowid_char_tbl_type  IS TABLE OF VARCHAR2(18);
l_rowid_char_tbl     g_rowid_char_tbl_type;

/* End Bug 3292870 */

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_cbc_flag',p_cbc_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_req_encumb_type_id',p_req_encumb_type_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_po_encumb_type_id',p_po_encumb_type_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_invoice_id',p_invoice_id);
END IF;

l_progress := '010';


/* Start Bug 3292870: Split update of reference5 field off of query to make
 * it compatible with an 8i db.
 */


UPDATE PO_ENCUMBRANCE_GT ALL_DISTS
SET
   ALL_DISTS.je_category_name =
      DECODE( ALL_DISTS.distribution_type
              ,  g_dist_type_REQUISITION,  g_je_category_Requisitions
              ,  g_je_category_Purchases
            )

,  ALL_DISTS.je_line_description =
      DECODE( ALL_DISTS.distribution_type
              , g_dist_type_AGREEMENT, ALL_DISTS.comments
              , ALL_DISTS.item_description
            )

,  ALL_DISTS.encumbrance_type_id =
     to_char( DECODE( ALL_DISTS.distribution_type
                    ,  g_dist_type_REQUISITION,  p_req_encumb_type_id  -- Reqs
                    ,  g_dist_type_AGREEMENT,  p_req_encumb_type_id
                    ,  p_po_encumb_type_id
              )
     )

,  ALL_DISTS.code_combination_id = ALL_DISTS.budget_account_id

,  ALL_DISTS.reference1 =
      DECODE( ALL_DISTS.distribution_type
              ,	 g_dist_type_REQUISITION,  g_reference1_REQ
              ,	 g_dist_type_AGREEMENT,  g_reference1_PA
              ,  g_dist_type_SCHEDULED,  g_reference1_REL
              ,	 g_dist_type_BLANKET,  g_reference1_REL
              ,	 g_reference1_PO
            )

-- bug 3404563: NULL out reference 2 and 3 if this is the
-- IP unsaved GMS Req case (identified by non-NULL award_num)

,  ALL_DISTS.reference2 =
      DECODE( ALL_DISTS.award_num
              -- if null, then its a saved doc so use the id
              , NULL, to_char(ALL_DISTS.header_id)
              -- else means unsaved doc, so NULL out ref2
              ,       NULL
      )

,  ALL_DISTS.reference3 =
      DECODE( ALL_DISTS.award_num
              -- if null, then its a saved doc so use the id
              , NULL, to_char(ALL_DISTS.distribution_id)
              -- else means unsaved doc, so NULL out ref3
              ,       NULL
      )

,  ALL_DISTS.reference4 = ALL_DISTS.segment1

,  ALL_DISTS.reference15 = to_char(ALL_DISTS.sequence_num)
WHERE ALL_DISTS.send_to_gl_flag = 'Y'  --bug 3568512: use new column
;


l_progress := '050';

UPDATE PO_ENCUMBRANCE_GT ALL_DISTS
SET   ALL_DISTS.reference5 = ALL_DISTS.reference_num
WHERE ALL_DISTS.send_to_gl_flag = 'Y'  --bug 3568512: use new column
  and ALL_DISTS.distribution_type = g_dist_type_REQUISITION
;

l_progress := '060';

UPDATE PO_ENCUMBRANCE_GT ALL_DISTS
SET   ALL_DISTS.reference5 =
                           ( SELECT PPO_DISTS.segment1
                             FROM PO_ENCUMBRANCE_GT PPO_DISTS
                             WHERE PPO_DISTS.origin_sequence_num
                                       = ALL_DISTS.sequence_num
                              AND PPO_DISTS.distribution_id
                                       = ALL_DISTS.source_distribution_id
                           )
WHERE ALL_DISTS.send_to_gl_flag = 'Y'  --bug 3568512: use new column
  and ALL_DISTS.distribution_type = g_dist_type_SCHEDULED
;

l_progress := '070';

UPDATE PO_ENCUMBRANCE_GT ALL_DISTS
SET   ALL_DISTS.reference5 =
                      ( SELECT PA_DISTS.segment1
                        FROM PO_ENCUMBRANCE_GT PA_DISTS
                        WHERE PA_DISTS.origin_sequence_num =
                                     ALL_DISTS.sequence_num
                          AND PA_DISTS.distribution_id =
                                     ALL_DISTS.agreement_dist_id
                      )
WHERE ALL_DISTS.send_to_gl_flag = 'Y'  --bug 3568512: use new column
  and ALL_DISTS.distribution_type NOT IN (g_dist_type_SCHEDULED, g_dist_type_REQUISITION)
RETURNING ROWIDTOCHAR(rowid) BULK COLLECT into l_rowid_char_tbl
;

l_progress := '080';

FORALL i IN 1..l_rowid_char_tbl.COUNT
UPDATE PO_ENCUMBRANCE_GT ALL_DISTS
SET   ALL_DISTS.reference5 =
                     ( SELECT REQ_DISTS.segment1
                       FROM PO_ENCUMBRANCE_GT REQ_DISTS
                       WHERE REQ_DISTS.origin_sequence_num =
                                     ALL_DISTS.sequence_num
                         AND REQ_DISTS.distribution_type =
                                     g_dist_type_REQUISITION
                      )
WHERE ALL_DISTS.send_to_gl_flag = 'Y'  --bug 3568512: use new column
  and rowid = CHARTOROWID(l_rowid_char_tbl(i))
  and ALL_DISTS.reference5 IS NULL
;

/* End Bug 3292870 */



l_progress := '100';

-- Update the source doc reference, JFMIP requirement.
-- Backing Reqs/PPOs/BPAs/GAs point to the {PO|Rel}/SR/BR/StdPO's po_header_id.
-- During an invoice activity, the main doc (StdPO/BR/SR)
-- points to the invoice_id.

UPDATE PO_ENCUMBRANCE_GT BACKING
SET
   BACKING.reference6 = g_reference6_SRCDOC
,  BACKING.reference10 =
      (
         SELECT TO_CHAR(MAIN.header_id)
         FROM PO_ENCUMBRANCE_GT MAIN
         WHERE MAIN.sequence_num = BACKING.origin_sequence_num
      )
WHERE BACKING.origin_sequence_num IS NOT NULL  --backing doc
AND BACKING.send_to_gl_flag = 'Y'  --bug 3568512: use new column
;

l_progress := '110';

IF (p_invoice_id IS NOT NULL) THEN

   l_progress := '120';

   -- If an invoice is causing this transaction,
   -- it needs to be referenced by the main doc rows.

   l_source_doc_reference := TO_CHAR(p_invoice_id);

   UPDATE PO_ENCUMBRANCE_GT MAIN
   SET
      MAIN.reference6 = g_reference6_SRCDOC
   ,  MAIN.reference10 = l_source_doc_reference
   WHERE MAIN.send_to_gl_flag = 'Y'  --bug 3568512: use new column
   AND   MAIN.origin_sequence_num IS NULL
   ;

   l_progress := '130';

ELSE

   l_progress := '140';

   -- Integration with Grants (GMS)
   --
   -- In FPI, unsaved requisitions were allowed to undergo a funds check.
   -- If Grants information is tied to one of these unsaved reqs,
   -- this information must be passed through GL_BC_PACKETS, as
   -- it is not saved in the PO transaction tables.
   -- One of the pieces of information that was passed to Grants
   -- was the award number.  In PO tables, only the award_id is stored.
   -- Therefore, we will distinguish this unsaved case that requires
   -- Grants data population by the presence of award_num in the
   -- encumbrance table.
   --
   -- Grants data will not be populated for backing docs
   -- or during an invoice transaction.
   -- In these cases, the Grants data must have been saved in the
   -- PO transaction tables anyway, so Grants can still figure it out.

   UPDATE PO_ENCUMBRANCE_GT MAIN
   SET
      MAIN.reference6 = g_reference6_GMSIP

   ,  MAIN.reference7 = to_char(project_id)

   ,  MAIN.reference8 = to_char(task_id)

   ,  MAIN.reference9 = award_num

   ,  MAIN.reference10 = expenditure_type

   ,  MAIN.reference11 = to_char(expenditure_organization_id)

   ,  MAIN.reference12 = expenditure_item_date /* Bug 3081539 */

   ,  MAIN.reference13 = to_char(vendor_id)

   WHERE MAIN.award_num IS NOT NULL  --identifies the unsaved Req case
   AND   MAIN.send_to_gl_flag = 'Y'  --bug 3568512: use new column
   AND   MAIN.origin_sequence_num IS NULL
   ;

   l_progress := '150';

END IF;


--Bug 3404491: populate reference14 with 'old' distribution
--information for Req Split or Cancel w/ Recreate Req
--This is needed by Projects/GMS, which read POETA info
--from the committed (old) dist.  This works b/c currently
--the user can not change POETA info during Cancel or Req split,
--so the info from old dist is same as for new dist

IF p_action = g_action_CANCEL THEN

   l_progress := '160';

   UPDATE PO_ENCUMBRANCE_GT BACKING_REQ
   SET reference14 =
      (SELECT REQ_TABLE.source_req_distribution_id
       FROM PO_REQ_DISTRIBUTIONS_ALL REQ_TABLE
       WHERE BACKING_REQ.distribution_id = REQ_TABLE.distribution_id
      )
   WHERE BACKING_REQ.origin_sequence_num IS NOT NULL
   AND   BACKING_REQ.distribution_type = g_dist_type_REQUISITION
   AND   BACKING_REQ.project_id IS NOT NULL
   ;

ELSIF p_action = g_action_ADJUST THEN

   l_progress := '180';

   UPDATE PO_ENCUMBRANCE_GT MAIN_REQ
   SET reference14 =
      (SELECT PARENT_DIST.distribution_id
       FROM PO_REQ_DISTRIBUTIONS_ALL PARENT_DIST
       ,    PO_REQUISITION_LINES_ALL PARENT_LINE
       ,    PO_REQUISITION_LINES_ALL CHILD_LINE
       WHERE MAIN_REQ.line_id = CHILD_LINE.requisition_line_id
       AND   PARENT_LINE.requisition_line_id = CHILD_LINE.parent_req_line_id
       AND   PARENT_DIST.requisition_line_id = PARENT_LINE.requisition_line_id
       AND   MAIN_REQ.distribution_num = PARENT_DIST.distribution_num
       -- Bug9663871   NEW JOIN CONDITION ON DIST NUM
      )
   WHERE MAIN_REQ.origin_sequence_num IS NULL
   AND   MAIN_REQ.distribution_type = g_dist_type_REQUISITION
   AND   MAIN_REQ.adjustment_status = g_adj_status_NEW
   AND   MAIN_REQ.project_id IS NOT NULL
   ;

END IF;


l_progress := '200';

IF p_cbc_flag = 'Y' THEN

   l_progress := '210';

   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'modifying packet for CBC');
   END IF;

   IF p_action = g_action_RESERVE THEN
      l_cbc_action := g_action_CBC_RESERVE;
   ELSIF p_action = g_action_UNRESERVE THEN
      l_cbc_action := g_action_CBC_UNRESERVE;
   END IF;

   l_progress := '220';

   SELECT POLC.description
   INTO   l_cbc_line_description
   FROM   PO_LOOKUP_CODES POLC
   WHERE  POLC.lookup_type = 'CONTROL ACTIONS'
   AND    POLC.lookup_code = l_cbc_action
   ;

   l_progress := '230';

   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_cbc_action',l_cbc_action);
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_cbc_line_description',l_cbc_line_description);
   END IF;

   UPDATE PO_ENCUMBRANCE_GT ALL_DISTS
   SET
      ALL_DISTS.je_line_description =
         SUBSTRB(ALL_DISTS.je_line_description,1,100)
         || '-'
         || SUBSTRB(l_cbc_line_description,1,139)
   WHERE ALL_DISTS.send_to_gl_flag = 'Y'
   ;

   l_progress := '240';

END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

   WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_gl_references;




------------------------------------------------------------------------------
--Start of Comments
--Name: check_enc_action_possible
--Pre-reqs:
--  This check is meaningless if the appropriate encumbrance is not turned on.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  This procedure determines whether there are any distributions below
--  the doc level on which the given encumbrance action would have any effect.
--Parameters:
--IN:
--p_action
--  The encumbrance action being performed.
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--OUT:
--x_action_possible_flag
--  Indicates whether the action is possible on this doc level
--  'Y' means it is possible, 'N' means it isn't.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_enc_action_possible(
   p_action                         IN          VARCHAR2
,  p_doc_type                       IN          VARCHAR2
,  p_doc_subtype                    IN          VARCHAR2
,  p_doc_level                      IN          VARCHAR2
,  p_doc_level_id                   IN          NUMBER
,  x_action_possible_flag           OUT NOCOPY  VARCHAR2
)
IS

l_proc_name              CONSTANT varchar2(30) := 'CHECK_ENC_ACTION_POSSIBLE';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
l_progress              VARCHAR2(3) := '000';

l_dist_count   NUMBER;

BEGIN

SAVEPOINT CHECK_ENC_ACTION_POSSIBLE;

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action',p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
END IF;

l_progress := '010';

get_all_distributions(
   p_action => p_action
,  p_check_only_flag => g_parameter_YES
,  p_doc_type => p_doc_type
,  p_doc_subtype => p_doc_subtype
,  p_doc_level => p_doc_level
,  p_doc_level_id => p_doc_level_id
,  p_use_enc_gt_flag => g_parameter_NO
,  p_get_backing_docs_flag => g_parameter_NO
,  p_ap_budget_account_id => NULL
,  p_possibility_check_flag => g_parameter_YES
,  p_cbc_flag => g_parameter_NO
,  x_count => l_dist_count
);

l_progress := '020';

IF (l_dist_count > 0) THEN
   x_action_possible_flag := g_parameter_YES;
ELSE
   x_action_possible_flag := g_parameter_NO;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_action_possible_flag',x_action_possible_flag);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION

WHEN OTHERS THEN

   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;

   RAISE;

END check_enc_action_possible;




-------------------------------------------------------------------------------
--Start of Comments
--Name: delete_encumbrance_gt
--Pre-reqs:
--  None.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  Deletes all of the existing data from PO_ENCUMBRANCE_GT.
--Parameters:
--  None.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE delete_encumbrance_gt
IS

l_proc_name CONSTANT VARCHAR2(30) := 'DELETE_ENCUMBRANCE_GT';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head||l_proc_name;
l_progress  VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
END IF;

l_progress := '010';

DELETE FROM PO_ENCUMBRANCE_GT ;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   po_message_s.sql_error(g_pkg_name,l_proc_name,l_progress,SQLCODE,SQLERRM);
   fnd_msg_pub.add;
   RAISE;

END delete_encumbrance_gt;


-- <SLA R12 Start>
  -------------------------------------------------------------------------------
  --Start of Comments
  --Name: update_amounts
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  -- This procedure will be used to update proper entered and accounted amount
  -- values in PO_ENCUMBRANCE_GT.
  --Parameters:
  --IN:
  --  p_action : specifies the action
  --  p_currency_code_func: currency code of the functional currency.
  --IN OUT:
  --  None.
  --OUT:
  --  None.
  --Notes:
  -- The algorithm of the procedure is as follows :
  -- update proper entered and accounted amount values in PO_ENCUMBRANCE_GT.
  --Testing:
  --
  --End of Comments
  -------------------------------------------------------------------------------
  PROCEDURE update_amounts
  (
    p_action        IN   VARCHAR2,
    p_currency_code_func IN VARCHAR2
  )
  IS
    l_api_name     CONSTANT      varchar2(40) := 'UPDATE_AMOUNTS';
    l_progress                   varchar2(3);

    l_return_status              VARCHAR2(1);
    l_sequence_num_tbl           PO_TBL_NUMBER;
    l_amount_to_round_tbl        PO_TBL_NUMBER;
    l_exchange_rate_tbl          PO_TBL_NUMBER;
    l_cur_precision_from_tbl  PO_TBL_NUMBER;
    l_min_acct_unit_from_tbl  PO_TBL_NUMBER;
    l_cur_precision_to_tbl     PO_TBL_NUMBER;
    l_min_acct_unit_to_tbl     PO_TBL_NUMBER;
    l_round_only_flag_tbl        PO_TBL_VARCHAR1;
    l_amount_result_tbl          PO_TBL_NUMBER;
    l_origin_sequence_num_tbl    PO_TBL_NUMBER;
    l_min_acct_unit_func  FND_CURRENCIES.minimum_accountable_unit%TYPE;
    l_cur_precision_func  FND_CURRENCIES.precision%TYPE;
    l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
  BEGIN

    l_progress := '000';

    If g_fnd_debug = 'Y' Then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string( FND_LOG.LEVEL_STATEMENT,
                        g_log_head || l_api_name || '.' || l_progress,
                        'Start of procedure'
                      );
      END IF;
    End If;

    IF p_action IN (g_action_RESERVE, g_action_UNDO_FINAL_CLOSE,
                    g_action_CR_MEMO_CANCEL, g_action_UNRESERVE,
                    g_action_FINAL_CLOSE, g_action_RETURN,
                    g_action_REJECT, g_action_INVOICE_CANCEL,
                    g_action_ADJUST
                   )
    THEN
      -- if action is RESERVE/UNRESERVE/UNDO_FINAL_CLOSE/CR_MEMO_CANCEL/FINAL_CLOSE/RETURN/REJECT/INVOICE_CANCEL/ADJUST
      l_progress := '010';

      If g_fnd_debug = 'Y' Then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                         g_log_head || l_api_name || '.' || l_progress,
                         'Update for '|| p_action
                        );
        END IF;
      End If;
      --<bug#5162302 START>
      --The objective of this bug is to ensure that the entered_amount is
      --is reflected as it was entered in the transaction.i.e in the foreign
      --currency and this is only for non-req documents. Reqs are always in
      --functional currency.

      --For BPA's the pre-round amount is not the correct thing to look at.
      --We need to look at the final amount because this reflects the actual
      --amount after all adjustments and calculations have been done to ensure
      --that we do not overrelive amount off the BPA. Since the entire amount
      --is in functional currency we would need to convert it back to the
      --foreign currency.
      --<bug#5478754>
      --For requisitions it is allright to have entered_amt=accounted_amt=final_amt.
      --This is because the requisitions are in functional currency all the time.
      UPDATE PO_ENCUMBRANCE_GT DISTS
        SET   DISTS.entered_amount = decode(DISTS.distribution_type,g_dist_type_AGREEMENT,
                                            DISTS.final_amt,g_dist_type_REQUISITION,DISTS.final_amt,
                                            DISTS.pre_round_amt)
              ,DISTS.accounted_amount = DISTS.final_amt
      WHERE DISTS.prevent_encumbrance_flag = 'N' ;
      --<bug#5162302 END>

     -- <13503748: Edit without unreserve ER START>
     -- Filtering the amounts to process if the entered amount is 0
     -- for Changed distributions
      IF p_action = g_action_RESERVE THEN

        UPDATE PO_ENCUMBRANCE_GT DISTS
	   SET DISTS.send_to_gl_flag = 'N'
	 WHERE DISTS.amount_changed_flag = 'Y'
	   AND Nvl(DISTS.entered_amount,0) = 0;
       END IF;

      UPDATE po_distributions_all POD
         SET POD.amount_changed_flag = NULL
       WHERE po_distribution_id IN
        (SELECT distribution_id
           FROM PO_ENCUMBRANCE_GT DISTS
          WHERE DISTS.amount_changed_flag = 'Y'
	    AND Nvl(DISTS.entered_amount,0) = 0);
      -- <13503748: Edit without unreserve ER END>

    ELSIF p_action = g_action_CANCEL THEN
      -- if action is CANCEL
      l_progress := '030';

      If g_fnd_debug = 'Y' Then
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                         g_log_head || l_api_name || '.' || l_progress,
                         'Update for Cancel action'
                        );
        END IF;
      End If;
      --<bug#5162302 START>
      --For BPA's the pre-round amount is not the correct thing to look at.
      --We need to look at the final amount because this reflects the actual
      --amount after all adjustments and calculations have been done to ensure
      --that we do not overrelive amount off the BPA. Since the entire amount
      --is in functional currency we would need to convert it back to the
      --foreign currency.
      --<bug#5478754>
      --For requisitions it is allright to have entered_amt=accounted_amt=final_amt.
      --This is because the requisitions are in functional currency all the time.
      UPDATE PO_ENCUMBRANCE_GT DISTS
        SET  DISTS.entered_amount = -1 *decode(DISTS.distribution_type,g_dist_type_AGREEMENT,
                                               DISTS.final_amt,g_dist_type_REQUISITION,DISTS.final_amt,
                                               DISTS.pre_round_amt)
             ,DISTS.accounted_amount = -1 * DISTS.final_amt
      WHERE DISTS.prevent_encumbrance_flag = 'N';
      --<bug#5162302 END>
    ELSE
      l_progress := '050';
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, '000', 'Invalid Action');
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;  -- check on p_action
    l_progress:= '060';
    --<bug#5162302 START>
    -- Get functional currency setup
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Before starting currency conversions on entered_amount_fields in po_encumbrance_gt');
        PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows,NULL,'PO');
    END IF;

    SELECT
       FND_CUR.minimum_accountable_unit
    ,  FND_CUR.precision
    INTO
       l_min_acct_unit_func
    ,  l_cur_precision_func
    FROM FND_CURRENCIES FND_CUR
    WHERE FND_CUR.currency_code = p_currency_code_func
    ;
    IF g_debug_stmt THEN
       PO_DEBUG.debug_stmt(l_log_head,l_progress,'After querying functional currency setup');
       PO_DEBUG.debug_var(l_log_head,l_progress,'l_min_acct_unit_func' , l_min_acct_unit_func);
       PO_DEBUG.debug_var(l_log_head,l_progress,'l_cur_precision_func' , l_cur_precision_func);
    END IF;
    l_progress:= '070';
    --For Agreement Distributions we need to convert back from the
    --Functional currency to the foreign currency and then apply rounding.
    --We need to assume the rate as 1/rate while converting back because
    --we cannot accurately determine the conversion from functional to foreign
    --currency. For all other distributions the currency would already be in
    --foreign currency except for requisition distributions. In such case we
    --can simply round and do no more than that. For all distributions that are
    --in functional currency the foreign currency fields would be null. We would
    --set these to the functional currency values for rounding precision.
    --<bug#5478754>
    --Requisitions are already looking at the final_amt which is rounded. We do not
    --have to round again.
    SELECT
       DISTS.sequence_num
    ,  DISTS.entered_amount
    ,  decode(DISTS.distribution_type,g_dist_type_AGREEMENT,1/nvl(DISTS.rate,1),1)
    ,  decode(DISTS.distribution_type,g_dist_type_AGREEMENT,
              l_cur_precision_func,DISTS.cur_precision_foreign)
    ,  decode(DISTS.distribution_type,g_dist_type_AGREEMENT,
              l_min_acct_unit_func,DISTS.min_acct_unit_foreign)
    ,  nvl(DISTS.cur_precision_foreign,l_cur_precision_func)
    ,  nvl(DISTS.min_acct_unit_foreign,l_min_acct_unit_func)
    ,  decode(DISTS.distribution_type,g_dist_type_AGREEMENT,'N','Y') --round only flag.
    ,  DISTS.origin_sequence_num
    BULK COLLECT INTO
       l_sequence_num_tbl
    ,  l_amount_to_round_tbl
    ,  l_exchange_rate_tbl
    ,  l_cur_precision_from_tbl
    ,  l_min_acct_unit_from_tbl
    ,  l_cur_precision_to_tbl
    ,  l_min_acct_unit_to_tbl
    ,  l_round_only_flag_tbl
    ,  l_origin_sequence_num_tbl
    FROM PO_ENCUMBRANCE_GT DISTS
    WHERE DISTS.prevent_encumbrance_flag = 'N'
    AND   DISTS.distribution_type <> g_dist_type_REQUISITION       --<bug#5478754>
    ORDER BY DISTS.sequence_num
    ;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'After querying for distributions.');
        PO_DEBUG.debug_var(l_log_head,l_progress,'l_sequence_num_tbl',l_sequence_num_tbl);
        PO_DEBUG.debug_var(l_log_head,l_progress,'l_amount_to_round_tbl',l_amount_to_round_tbl);
        PO_DEBUG.debug_var(l_log_head,l_progress,'l_exchange_rate_tbl',l_exchange_rate_tbl);
        PO_DEBUG.debug_var(l_log_head,l_progress,'l_cur_precision_from_tbl',l_cur_precision_from_tbl);
        PO_DEBUG.debug_var(l_log_head,l_progress,'l_min_acct_unit_from_tbl',l_min_acct_unit_from_tbl);
        PO_DEBUG.debug_var(l_log_head,l_progress,'l_cur_precision_to_tbl',l_cur_precision_to_tbl);
        PO_DEBUG.debug_var(l_log_head,l_progress,'l_min_acct_unit_to_tbl',l_min_acct_unit_to_tbl);
        PO_DEBUG.debug_var(l_log_head,l_progress,'l_round_only_flag_tbl',l_round_only_flag_tbl);
        PO_DEBUG.debug_var(l_log_head,l_progress,'l_origin_sequence_num_tbl',l_origin_sequence_num_tbl);
    END IF;
    l_progress:= '080';

    PO_CORE_S2.round_and_convert_currency(
       x_return_status               => l_return_status
    ,  p_unique_id_tbl               => l_sequence_num_tbl
    ,  p_amount_in_tbl               => l_amount_to_round_tbl
    ,  p_exchange_rate_tbl           => l_exchange_rate_tbl
    ,  p_from_currency_precision_tbl => l_cur_precision_from_tbl
    ,  p_from_currency_mau_tbl       => l_min_acct_unit_from_tbl
    ,  p_to_currency_precision_tbl   => l_cur_precision_to_tbl
    ,  p_to_currency_mau_tbl         => l_min_acct_unit_to_tbl
    ,  p_round_only_flag_tbl         => l_round_only_flag_tbl
    ,  x_amount_out_tbl              => l_amount_result_tbl
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       PO_DEBUG.debug_stmt(l_log_head,l_progress,'After completing PO_CORE_S2.round_and_convert_currency on distributions');
       PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status',l_return_status);
       l_progress := '090';
       RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
    END IF;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var(l_log_head,l_progress,'l_amount_result_tbl',l_amount_result_tbl);
    END IF;

    l_progress:='100';
    FORALL i IN 1 .. l_sequence_num_tbl.COUNT
       UPDATE PO_ENCUMBRANCE_GT DISTS
       SET DISTS.entered_amount= l_amount_result_tbl(i)
       WHERE DISTS.prevent_encumbrance_flag = 'N'
       AND DISTS.sequence_num = l_sequence_num_tbl(i)
       ;
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'After completing update on po_encumbrance_gt for distributions');
        PO_DEBUG.debug_var(l_log_head,l_progress,'sql%rowcount',sql%rowcount);
        PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows,NULL,'PO');
    END IF;
    --<bug#5162302 END>
    l_progress := '110';

    If g_fnd_debug = 'Y' Then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                       g_log_head || l_api_name || '.' || l_progress,
                       'End of Procedure'
                    );
      END IF;
    End If;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

    WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END update_amounts;
-- <SLA R12 End>

-- Bug 15987200
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_reversal_amounts
--Pre-reqs:
--  None.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  Calculates the reversal amounts if Accrue_On_Receipt_Flag is N.
--Parameters:
--  None.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE get_reversal_amounts(
  p_doc_type          IN VARCHAR2
,  p_doc_subtype      IN VARCHAR2
,  p_currency_code_func  IN  VARCHAR2
,  p_min_acct_unit_func  IN  NUMBER
,  p_cur_precision_func  IN  NUMBER
)

IS
   l_api_name CONSTANT varchar2(40) := 'get_reversal_amounts';
   l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
   l_progress     VARCHAR2(3) := '000';

   l_return_status              VARCHAR2(1);
   l_sequence_num_tbl           PO_TBL_NUMBER;
   l_amount_to_round_tbl        PO_TBL_NUMBER;
   l_exchange_rate_tbl          PO_TBL_NUMBER;
   l_cur_precision_foreign_tbl  PO_TBL_NUMBER;
   l_min_acct_unit_foreign_tbl  PO_TBL_NUMBER;
   l_cur_precision_func_tbl     PO_TBL_NUMBER;
   l_min_acct_unit_func_tbl     PO_TBL_NUMBER;
   l_round_only_flag_tbl        PO_TBL_VARCHAR1;  --bug 3568671
   l_amount_result_tbl          PO_TBL_NUMBER;

   l_Accrue_On_Receipt_Flag_tbl PO_TBL_VARCHAR1;
   l_distribution_id_tbl        PO_TBL_NUMBER;
   l_reversal_amt_tbl           PO_TBL_NUMBER;
-- Bug 20072097
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(2000);



   l_origin_sequence_num_tbl    PO_TBL_NUMBER;  -- bug 3480949

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_currency_code_func', p_currency_code_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_min_acct_unit_func', p_min_acct_unit_func);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_cur_precision_func', p_cur_precision_func);

END IF;

SELECT
   DISTS.sequence_num
,  DISTS.origin_sequence_num
,  DISTS.Accrue_On_Receipt_Flag
,  DISTS.DISTRIBUTION_ID
BULK COLLECT INTO
   l_sequence_num_tbl
,  l_origin_sequence_num_tbl
,  l_Accrue_On_Receipt_Flag_tbl
,  l_distribution_id_tbl
FROM PO_ENCUMBRANCE_GT DISTS
WHERE DISTS.prevent_encumbrance_flag = 'N'
ORDER BY DISTS.sequence_num;


l_reversal_amt_tbl := po_tbl_number();
l_reversal_amt_tbl.extend(l_sequence_num_tbl.Count);

FOR i IN 1 .. l_sequence_num_tbl.Count
  LOOP

       if l_Accrue_On_Receipt_Flag_tbl(i) = 'N'
	   THEN


	    PSA_AP_BC_GRP.get_po_reversed_encumb_amount(
                    p_api_version =>1.0,
                    p_init_msg_list => FND_API.G_FALSE,
                    x_return_status => l_return_status,
                    x_msg_count=>l_msg_count,
                    x_msg_data=>l_msg_data,
                    p_po_distribution_id => l_distribution_id_tbl(i),
                    p_start_gl_date => NULL,
                    p_end_gl_date => NULL,
                    p_calling_sequence => NULL,
                    x_unencumbered_amount => l_reversal_amt_tbl(i));

	   END IF;

 END LOOP;


 FOR i IN 1 .. l_sequence_num_tbl.Count

 LOOP


   UPDATE PO_ENCUMBRANCE_GT DISTS
   SET Final_amt = Final_amt + (DISTS.encumbered_amount-DISTS.FInal_amt-l_reversal_amt_tbl(i)),
   amount_reversed = DISTS.encumbered_amount-DISTS.FInal_amt-l_reversal_amt_tbl(i)
   WHERE DISTS.prevent_encumbrance_flag = 'N'
   AND   DISTS.sequence_num = l_sequence_num_tbl(i);


 END LOOP;

 round_and_convert_amounts(
      p_action => g_action_FINAL_CLOSE
   ,  p_currency_code_func => p_currency_code_func
   ,  p_min_acct_unit_func => p_min_acct_unit_func
   ,  p_cur_precision_func => p_cur_precision_func
   ,  p_column_to_use => g_column_PO_REVERSAL_AMOUNT
   );


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;

   WHEN OTHERS THEN
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_reversal_amounts;
END PO_ENCUMBRANCE_PREPROCESSING;

/
