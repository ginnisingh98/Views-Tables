--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_FUNDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_FUNDS_PVT" AS
-- $Header: POXVENCB.pls 120.23.12010000.25 2014/12/15 11:12:02 gjyothi ship $


-- Private package constants

G_PKG_NAME CONSTANT varchar2(30) := 'PO_DOCUMENT_FUNDS_PVT';
g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';
 -- Logging global constants
D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(G_PKG_NAME);


-- Debugging

g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;


-- Exception handling

g_SUBMISSION_CHECK_EXC_CODE      CONSTANT
   NUMBER
   := 1
   ;
g_GET_ALL_DISTS_EXC_CODE         CONSTANT
   NUMBER
   := 2
   ;
g_NO_ROWS_EXC_CODE               CONSTANT
   NUMBER
   := 3
   ;
g_EXECUTE_GL_CALL_EXC_CODE       CONSTANT
   NUMBER
   := 4
   ;

-- Bug 3480949: Added order_type constants
-- order type lookup codes
g_order_type_FIXED_PRICE         CONSTANT
   PO_LINE_TYPES_B.order_type_lookup_code%TYPE
   := 'FIXED PRICE'
   ;

g_order_type_RATE                CONSTANT
   PO_LINE_TYPES_B.order_type_lookup_code%TYPE
   := 'RATE'
   ;
g_GL_FUNDS_API_EXC  constant number :=5; ---Bug 12824154

--------------------------------------------------------------------------------
-- Forward procedure declarations
--------------------------------------------------------------------------------

PROCEDURE do_action(
   x_return_status     OUT NOCOPY VARCHAR2
,  p_action            IN  VARCHAR2
,  p_check_only_flag   IN  VARCHAR2
,  p_cbc_flag          IN  VARCHAR2
,  p_doc_type          IN  VARCHAR2
,  p_doc_subtype       IN  VARCHAR2
,  p_doc_level         IN  VARCHAR2
,  p_doc_level_id      IN  NUMBER
,  p_use_enc_gt_flag   IN  VARCHAR2
,  p_employee_id       IN  NUMBER
,  p_override_funds    IN  VARCHAR2
,  p_prevent_partial_flag  IN VARCHAR2
,  p_use_gl_date       IN  VARCHAR2
,  p_override_date     IN  DATE
,  p_validate_document IN  VARCHAR2
,  p_use_force_mode    IN  VARCHAR2
-- The following params are only revelant to
-- the invoice cancel API
,  p_invoice_id            IN  NUMBER DEFAULT NULL
,  p_ap_encumbered_amount  IN  NUMBER DEFAULT NULL
,  p_ap_cancelled_quantity IN  NUMBER DEFAULT NULL
,  p_budget_acct_id        IN  NUMBER DEFAULT NULL
,  x_packet_id             OUT NOCOPY NUMBER
-- End of invoice-cancel specific parameters
,  x_online_report_id  OUT NOCOPY NUMBER
,  x_po_return_code    OUT NOCOPY VARCHAR2);


PROCEDURE handle_exception(
   p_api_name                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  x_return_status                  OUT NOCOPY     VARCHAR2
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
);

--<SLA R12 Start>
--<SLA R12 End>

--------------------------------------------------------------------------------
-- Procedure definitions
--------------------------------------------------------------------------------


------------------------------------------------------------------------------
--Start of Comments
--Name: check_reserve
--Pre-reqs:
-- None.
--Modifies:
--  Creates funds check entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure performs a funds check on a document or doc level of a
--  document.
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--p_use_enc_gt_flag
--  Set to g_parameter_NO if calling with p_doc_level_id
--  Else if using the inteface table g_parameter_YES
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_reserve(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_doc_level          IN    VARCHAR2
,  p_doc_level_id       IN    NUMBER
,  p_use_enc_gt_flag    IN    VARCHAR2
,  p_override_funds     IN    VARCHAR2
,  x_po_return_code     OUT NOCOPY  VARCHAR2
,  x_online_report_id   OUT NOCOPY  NUMBER
)
IS

l_api_name              CONSTANT varchar2(30) := 'CHECK_RESERVE';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_packet_id             NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag',p_use_enc_gt_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT CHECK_RESERVE_SP;

l_progress := '020';

x_online_report_id := NULL;
x_po_return_code := NULL;

do_action(x_return_status => x_return_status,
  p_action => g_action_RESERVE,
  p_check_only_flag => g_parameter_YES,
  p_cbc_flag => g_parameter_NO,
  p_doc_type => p_doc_type,
  p_doc_subtype => p_doc_subtype,
  p_doc_level => p_doc_level,
  p_doc_level_id => p_doc_level_id,
  p_use_enc_gt_flag => p_use_enc_gt_flag,
  p_employee_id => NULL,
  p_override_funds => p_override_funds,
  p_prevent_partial_flag => NULL,
  p_use_gl_date => g_parameter_YES,
  p_override_date => NULL,
  p_validate_document => g_parameter_NO,  -- no validation for Check Funds
  p_use_force_mode => g_parameter_NO,
  x_packet_id => l_packet_id,
  x_po_return_code => x_po_return_code,
  x_online_report_id => x_online_report_id);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO CHECK_RESERVE_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END check_reserve;

------------------------------------------------------------------------------
--Start of Comments
--Name: check_adjust
--Pre-reqs:
-- None.
--Modifies:
--  Creates funds check entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure performs a funds check on a document or doc level of a
--  document.
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_adjust(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_override_funds     IN    VARCHAR2
,  p_use_gl_date        IN    VARCHAR2
,  p_override_date      IN    DATE
,  x_po_return_code     OUT NOCOPY  VARCHAR2
,  x_online_report_id   OUT NOCOPY  NUMBER
)
IS

l_api_name              CONSTANT varchar2(30) := 'CHECK_ADJUST';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_packet_id             NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT CHECK_ADJUST_SP;

l_progress := '020';

x_online_report_id := NULL;
x_po_return_code := NULL;

do_action(x_return_status => x_return_status,
  p_action => g_action_ADJUST,
  p_check_only_flag => g_parameter_YES,
  p_cbc_flag => NULL,
  p_doc_type => p_doc_type,
  p_doc_subtype => p_doc_subtype,
  p_doc_level => NULL,
  p_doc_level_id => NULL,
  p_use_enc_gt_flag => g_parameter_YES,
  p_employee_id => NULL,
  p_override_funds => p_override_funds,
  p_prevent_partial_flag => NULL,
  p_use_gl_date => p_use_gl_date,
  p_override_date => p_override_date,
  p_validate_document => g_parameter_NO, -- no validation for Check Funds
  p_use_force_mode => g_parameter_NO,
  x_packet_id => l_packet_id,
  x_po_return_code => x_po_return_code,
  x_online_report_id => x_online_report_id);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO CHECK_ADJUST_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END check_adjust;



------------------------------------------------------------------------------
--Start of Comments
--Name: do_reserve
--Pre-reqs:
-- None.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure performs funds reservation on all eligible
--  distributions of a document
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  For Reserve, this should always be g_HEADER
--p_doc_level_id
--  The id corresponding to the doc level type:
--  For Reserve, this should always be header_id (or release_id for Releases)
--p_use_enc_gt_flag
--  Set to g_parameter_NO if calling with p_doc_level_id
--  Else if using the inteface table g_parameter_YES
--p_prevent_partial_flag
--  Relevant only to g_action_RESERVE
--  'Y'= the caller specifically does not want partials allowed
--  Note: setting this to 'N' does not guarantee partial will be allowed (i.e.
--        partial is never allowed when there are backing docs)
--p_validate_document
--  Indicates whether to perform general document state/submission checks
--  If 'Y', then encumbrance code will make calls to check doc correctness
--  If 'N', then the caller has already done these validations.
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_employee_id
--  Employee Id of the user taking the action
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_reserve(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_doc_level          IN    VARCHAR2
,  p_doc_level_id       IN    NUMBER
,  p_use_enc_gt_flag    IN    VARCHAR2
,  p_prevent_partial_flag IN  VARCHAR2
,  p_validate_document  IN    VARCHAR2
,  p_override_funds     IN    VARCHAR2
,  p_employee_id        IN    NUMBER
,  x_po_return_code     OUT NOCOPY  VARCHAR2
,  x_online_report_id   OUT NOCOPY  NUMBER) IS

l_api_name              CONSTANT varchar2(30) := 'DO_RESERVE';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_packet_id             NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag',p_use_enc_gt_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_prevent_partial_flag',p_prevent_partial_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validate_document',p_validate_document);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_employee_id',p_employee_id);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_RESERVE_SP;

l_progress := '020';

x_po_return_code := NULL;
x_online_report_id := NULL;

do_action(x_return_status => x_return_status,
  p_action => g_action_RESERVE,
  p_check_only_flag => g_parameter_NO,
  p_cbc_flag => g_parameter_NO,
  p_doc_type => p_doc_type,
  p_doc_subtype => p_doc_subtype,
  p_doc_level => p_doc_level,
  p_doc_level_id => p_doc_level_id,
  p_use_enc_gt_flag => p_use_enc_gt_flag,
  p_employee_id => p_employee_id,
  p_override_funds => p_override_funds,
  p_prevent_partial_flag => p_prevent_partial_flag,
  p_use_gl_date => g_parameter_YES,
  p_override_date => NULL,
  p_validate_document => p_validate_document,
  p_use_force_mode => g_parameter_NO,
  x_packet_id => l_packet_id,
  x_po_return_code => x_po_return_code,
  x_online_report_id => x_online_report_id);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO DO_RESERVE_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_reserve;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_unreserve
--Pre-reqs:
-- None.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure unreserves the encumbrance on all eligible distributions of
--  the requested document or document doc level
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--p_use_enc_gt_flag
--  Set to g_parameter_NO if calling with p_doc_level_id
--  Else if using the inteface table g_parameter_YES
--p_validate_document
--  Indicates whether to perform general document state/submission checks
--  If 'Y', then encumbrance code will make calls to check doc correctness
--  If 'N', then the caller has already done these validations.
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--p_employee_id
--  Employee Id of the user taking the action
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_unreserve(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_doc_level          IN    VARCHAR2
,  p_doc_level_id       IN    NUMBER
,  p_use_enc_gt_flag    IN    VARCHAR2
,  p_validate_document  IN    VARCHAR2
,  p_override_funds     IN    VARCHAR2
,  p_use_gl_date        IN    VARCHAR2
,  p_override_date      IN    DATE
,  p_employee_id        IN    NUMBER
,  x_po_return_code     OUT NOCOPY  VARCHAR2
,  x_online_report_id   OUT NOCOPY  NUMBER
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_UNRESERVE';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_packet_id             NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag',p_use_enc_gt_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validate_document',p_validate_document);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_employee_id',p_employee_id);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_UNRESERVE_SP;

l_progress := '020';

x_po_return_code := NULL;
x_online_report_id := NULL;

do_action(x_return_status => x_return_status,
  p_action => g_action_UNRESERVE,
  p_check_only_flag => g_parameter_NO,
  p_cbc_flag => g_parameter_NO,
  p_doc_type => p_doc_type,
  p_doc_subtype => p_doc_subtype,
  p_doc_level => p_doc_level,
  p_doc_level_id => p_doc_level_id,
  p_use_enc_gt_flag => p_use_enc_gt_flag,
  p_employee_id => p_employee_id,
  p_override_funds => p_override_funds,
  p_prevent_partial_flag => NULL,
  p_use_gl_date => p_use_gl_date,
  p_override_date => p_override_date,
  p_validate_document => p_validate_document,
  p_use_force_mode => g_parameter_NO,
  x_packet_id => l_packet_id,
  x_po_return_code => x_po_return_code,
  x_online_report_id => x_online_report_id);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO DO_UNRESERVE_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_unreserve;

------------------------------------------------------------------------------
--Start of Comments
--Name: do_return
--Pre-reqs:
-- None.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure unreserves encumbrance on a Requisition that has been
--  returned
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--p_use_enc_gt_flag
--  Set to g_parameter_NO if calling with p_doc_level_id
--  Else if using the inteface table g_parameter_YES
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_return(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_doc_level          IN    VARCHAR2
,  p_doc_level_id       IN    NUMBER
,  p_use_enc_gt_flag    IN    VARCHAR2
,  p_use_gl_date        IN    VARCHAR2
,  p_override_date      IN    DATE
,  x_po_return_code     OUT NOCOPY  VARCHAR2
,  x_online_report_id   OUT NOCOPY  NUMBER
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_RETURN';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_packet_id             NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag',p_use_enc_gt_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_RETURN_SP;

l_progress := '020';

x_po_return_code := NULL;
x_online_report_id := NULL;

do_action(x_return_status => x_return_status,
  p_action => g_action_RETURN,
  p_check_only_flag => g_parameter_NO,
  p_cbc_flag => NULL,
  p_doc_type => p_doc_type,
  p_doc_subtype => p_doc_subtype,
  p_doc_level => p_doc_level,
  p_doc_level_id => p_doc_level_id,
  p_use_enc_gt_flag => p_use_enc_gt_flag,
  p_employee_id => NULL,
  p_override_funds => NULL,
  p_prevent_partial_flag => NULL,
  p_use_gl_date => p_use_gl_date,
  p_override_date => p_override_date,
  p_validate_document => g_parameter_NO,
  p_use_force_mode => g_parameter_NO,
  x_packet_id => l_packet_id,
  x_po_return_code => x_po_return_code,
  x_online_report_id => x_online_report_id);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO DO_RETURN_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_return;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_reject
--Pre-reqs:
-- None.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure unreserves encumbrance from unapproved shipments on
--  a document that has been rejected
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  For Reject, this should always be g_HEADER
--p_doc_level_id
--  The id corresponding to the doc level type:
--  For Reject, this should always be header_id (or release_id for Releases)
--p_use_enc_gt_flag
--  Set to g_parameter_NO if calling with p_doc_level_id
--  Else if using the inteface table g_parameter_YES
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_reject(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_doc_level          IN    VARCHAR2
,  p_doc_level_id       IN    NUMBER
,  p_use_enc_gt_flag    IN    VARCHAR2
,  p_override_funds     IN    VARCHAR2
,  p_use_gl_date        IN    VARCHAR2
,  p_override_date      IN    DATE
,  x_po_return_code     OUT NOCOPY  VARCHAR2
,  x_online_report_id   OUT NOCOPY  NUMBER
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_REJECT';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_packet_id             NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag',p_use_enc_gt_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_REJECT_SP;

l_progress := '020';

x_po_return_code := NULL;
x_online_report_id := NULL;

do_action(x_return_status => x_return_status,
  p_action => g_action_REJECT,
  p_check_only_flag => g_parameter_NO,
  p_cbc_flag => NULL,
  p_doc_type => p_doc_type,
  p_doc_subtype => p_doc_subtype,
  p_doc_level => p_doc_level,
  p_doc_level_id => p_doc_level_id,
  p_use_enc_gt_flag => p_use_enc_gt_flag,
  p_employee_id => NULL,
  p_override_funds => p_override_funds,
  p_prevent_partial_flag => NULL,
  p_use_gl_date => p_use_gl_date,
  p_override_date => p_override_date,
  p_validate_document => g_parameter_NO,
  p_use_force_mode => g_parameter_NO,
  x_packet_id => l_packet_id,
  x_po_return_code => x_po_return_code,
  x_online_report_id => x_online_report_id);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO DO_REJECT_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_reject;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_cancel
--Pre-reqs:
--  The cancel code must already have set the cancel_flag on the relevant doc
--  level to be 'I'   (is this always required?)
--  The cancel code must have already created a new Req distribution if Recreate
--  (and hence re-encumber) Demand is requested.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure cancels the encumbrance on all eligible distributions of
--  the requested document or document doc level
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--p_use_enc_gt_flag
--  Set to g_parameter_NO if calling with p_doc_level_id
--  Else if using the inteface table g_parameter_YES
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_cancel(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_doc_level          IN    VARCHAR2
,  p_doc_level_id       IN    NUMBER
,  p_use_enc_gt_flag    IN    VARCHAR2
,  p_override_funds     IN    VARCHAR2
,  p_use_gl_date        IN    VARCHAR2
,  p_override_date      IN    DATE
,  x_po_return_code     OUT NOCOPY  VARCHAR2
,  x_online_report_id   OUT NOCOPY  NUMBER
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_CANCEL';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_packet_id             NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag',p_use_enc_gt_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_CANCEL_SP;

l_progress := '020';

x_po_return_code := NULL;
x_online_report_id := NULL;

do_action(x_return_status => x_return_status,
  p_action => g_action_CANCEL,
  p_check_only_flag => g_parameter_NO,
  p_cbc_flag => NULL,
  p_doc_type => p_doc_type,
  p_doc_subtype => p_doc_subtype,
  p_doc_level => p_doc_level,
  p_doc_level_id => p_doc_level_id,
  p_use_enc_gt_flag => p_use_enc_gt_flag,
  p_employee_id => NULL,
  p_override_funds => p_override_funds,
  p_prevent_partial_flag => NULL,
  p_use_gl_date => p_use_gl_date,
  p_override_date => p_override_date,
  p_validate_document => g_parameter_NO,
  p_use_force_mode => g_parameter_NO,
  x_packet_id => l_packet_id,
  x_po_return_code => x_po_return_code,
  x_online_report_id => x_online_report_id);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO DO_CANCEL_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_cancel;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_adjust
--Pre-reqs:
--  N/A.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure cancels the encumbrance on all eligible distributions of
--  the requested document or document doc level
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_employee_id
--  Employee Id of the user taking the action
--p_validate_document
--  Indicates whether to perform general document state/submission checks
--  If 'Y', then encumbrance code will make calls to check doc correctness
--  If 'N', then the caller has already done these validations.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_adjust(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_override_funds     IN    VARCHAR2
,  p_use_gl_date        IN    VARCHAR2
,  p_validate_document  IN    VARCHAR2
,  p_override_date      IN    DATE
,  p_employee_id        IN    NUMBER
,  x_po_return_code     OUT NOCOPY  VARCHAR2
,  x_online_report_id   OUT NOCOPY  NUMBER
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_ADJUST';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_packet_id             NUMBER;



BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validate_document',p_validate_document);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_employee_id',p_employee_id);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_ADJUST_SP;

l_progress := '020';

x_po_return_code := NULL;
x_online_report_id := NULL;

do_action(x_return_status => x_return_status,
  p_action => g_action_ADJUST,
  p_check_only_flag => g_parameter_NO,
  p_cbc_flag => NULL,
  p_doc_type => p_doc_type,
  p_doc_subtype => p_doc_subtype,
  p_doc_level => NULL,
  p_doc_level_id => NULL,
  p_use_enc_gt_flag => g_parameter_YES,
  p_employee_id => p_employee_id,
  p_override_funds => p_override_funds,
  p_prevent_partial_flag => NULL,
  p_use_gl_date => p_use_gl_date,
  p_override_date => p_override_date,
  p_validate_document => p_validate_document,
  p_use_force_mode => g_parameter_NO,
  x_packet_id => l_packet_id,
  x_po_return_code => x_po_return_code,
  x_online_report_id => x_online_report_id);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO DO_ADJUST_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_adjust;


--------------------------------------------------------------------------------
--Start of Comments
--Name: do_req_split
--Pre-reqs:
--	 None.
--Modifies:
--	 Creates encumbrance entries in the gl_bc_packets table.
--	 Adds distribution-specific transaction information into the
--	 po_online_report_text table.
--  Adds entries to the action history.
--  Manipulates PO_ENCUMBRANCE_GT.
--  Updates the base document tables with encumbrance results.
--Function:
--	 This procedure transfers encumbrance from OLD requisition
--  lines/distributions to NEW lines/distributions.
--  The OLD distributions will be unreserved and the NEW distributions
--  will be reserved.
--Parameters:
--IN:
--p_before_distribution_ids_tbl
--	 A table of req distribution ids that exist before the split.
--p_after_distribution_ids_tbl
--	 A table of req distribution ids that should be reserved after the split.
--p_employee_id
--  Employee Id of the user taking the action.
--  This is used in the action history entry.
--  If NULL is passed, the value will be derived from the current FND user.
--p_override_funds
--  Indicates whether funds override capability can be used, if needed,
--  to make a transaction succeed.
--    g_parameter_NO - don't use override capability
--    g_parameter_YES - okay to use override
--    g_parameter_USE_PROFILE - base the decision on the profile option
--       PO:Override Funds Reservation
--p_override_date
--  Caller-specified date to use instead of distribution encumbrance date
--  in GL entries.
--OUT:
--x_return_status
--  VARCHAR2(1)
--  FND_API.G_RET_STS_SUCCESS for success
--  FND_API.G_RET_STS_ERROR for a forseen error
--  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurs
--x_po_return_code
--  VARCHAR2(10)
--  Indicates the PO classification of the results of this transaction.
--  g_return_<>
--    SUCCESS
--    WARNING
--    PARTIAL
--    FAILURE
--    FATAL
--x_online_report_id
--   Unique id into po_online_report_text rows that store distribution specific
--   reporting information for a specific encumbrance transaction.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_req_split(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_before_dist_ids_tbl            IN             po_tbl_number
,  p_after_dist_ids_tbl             IN             po_tbl_number
,  p_employee_id                    IN             NUMBER
,  p_override_funds                 IN             VARCHAR2
,  p_override_date                  IN             DATE
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
)
IS

l_api_name     CONSTANT VARCHAR2(30) := 'DO_REQ_SPLIT';
l_log_head     CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress     VARCHAR2(3) := '000';
l_packet_id    NUMBER;
l_force_mode VARCHAR2(1);
BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_before_dist_ids_tbl', p_before_dist_ids_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_after_dist_ids_tbl', p_after_dist_ids_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_REQ_SPLIT_SP;
x_po_return_code := NULL;
x_online_report_id := NULL;

l_progress := '100';
IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
     'Populate po_encumbrance_gt with before distribution ids');
END IF;

-- Fill the GTT with the data from the doc tables.
populate_encumbrance_gt(
   x_return_status            => x_return_status
,  p_doc_type                 => g_doc_type_REQUISITION
,  p_doc_level                => g_doc_level_DISTRIBUTION
,  p_doc_level_id_tbl         => p_before_dist_ids_tbl
,  p_adjustment_status_tbl    => po_tbl_varchar5(g_adjustment_status_OLD)
,  p_check_only_flag          => g_parameter_NO
);

l_progress := '200';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '210';
IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
     'Populate po_encumbrance_gt with after distribution ids');
END IF;

-- Fill the GTT with the data from the doc tables.
populate_encumbrance_gt(
   x_return_status            => x_return_status
,  p_doc_type                 => g_doc_type_REQUISITION
,  p_doc_level                => g_doc_level_DISTRIBUTION
,  p_doc_level_id_tbl         => p_after_dist_ids_tbl
,  p_adjustment_status_tbl    => po_tbl_varchar5(g_adjustment_status_NEW)
,  p_check_only_flag          => g_parameter_NO
);

l_progress := '300';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '310';
IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Call do_action');
END IF;
--<bug#5200462 START>
--We should be calling Req Split with force mode
--for all non-federal cases. This is to ensure that
--requisition split always succeeds. This is allright
--because we are not increasing funds in any way. We
--can only keep it constant or decrease funds.
IF FV_INSTALL.enabled THEN
    l_force_mode := g_parameter_NO;
ELSE
    l_force_mode := g_parameter_YES;
END IF;
--<bug#5200462 END>
-- Call do_action
do_action(
   x_return_status         => x_return_status
,  p_action                => g_action_REQ_SPLIT
,  p_check_only_flag       => g_parameter_NO
,  p_cbc_flag              => g_parameter_NO
,  p_doc_type              => g_doc_type_REQUISITION
,  p_doc_subtype           => NULL
,  p_doc_level             => g_doc_level_DISTRIBUTION
,  p_doc_level_id          => NULL
,  p_use_enc_gt_flag       => g_parameter_YES
,  p_employee_id           => p_employee_id
,  p_override_funds        => p_override_funds
,  p_prevent_partial_flag  => g_parameter_YES
,  p_use_gl_date           => g_parameter_YES
,  p_override_date         => p_override_date
,  p_validate_document     => g_parameter_NO
,  p_use_force_mode        => l_force_mode
,  x_packet_id             => l_packet_id
,  x_online_report_id      => x_online_report_id
,  x_po_return_code        => x_po_return_code
);

l_progress := '400';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO DO_REQ_SPLIT_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_req_split;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_final_close
--Pre-reqs:
--  N/A.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure liquidates the encumbrance on all eligible distributions of
--  the requested document or document doc level
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--p_use_enc_gt_flag
--  Set to g_parameter_NO if calling with p_doc_level_id
--  Else if using the inteface table g_parameter_YES
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--p_invoice_id
--  The id of the invoice that is causing the final match, when coming
--  through an AP call.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_final_close(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_use_gl_date                    IN             VARCHAR2
,  p_override_date                  IN             DATE
,  p_invoice_id                     IN             NUMBER   DEFAULT NULL
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_FINAL_CLOSE';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_packet_id             NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag',p_use_enc_gt_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_invoice_id',p_invoice_id);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_FINAL_CLOSE_SP;

l_progress := '020';

x_po_return_code := NULL;
x_online_report_id := NULL;

do_action(
   x_return_status         => x_return_status
,  p_action                => g_action_FINAL_CLOSE
,  p_check_only_flag       => g_parameter_NO
,  p_cbc_flag              => NULL
,  p_doc_type              => p_doc_type
,  p_doc_subtype           => p_doc_subtype
,  p_doc_level             => p_doc_level
,  p_doc_level_id          => p_doc_level_id
,  p_use_enc_gt_flag       => p_use_enc_gt_flag
,  p_employee_id           => NULL
,  p_override_funds        => NULL
,  p_prevent_partial_flag  => NULL
,  p_use_gl_date           => p_use_gl_date
,  p_override_date         => p_override_date
,  p_validate_document     => g_parameter_NO
,  p_use_force_mode        => g_parameter_NO
,  p_invoice_id            => p_invoice_id
,  p_ap_encumbered_amount  => NULL
,  p_ap_cancelled_quantity => NULL
,  p_budget_acct_id        => NULL
,  x_packet_id             => l_packet_id
,  x_po_return_code        => x_po_return_code
,  x_online_report_id      => x_online_report_id
);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO DO_FINAL_CLOSE_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_final_close;


------------------------------------------------------------------------------
--Start of Comments
--Name: undo_final_close
--Pre-reqs:
--  n/a
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Function:
--  This procedure performs funds reservation on all eligible
--  distributions of a finally closed PO Shipment which was
--  finally closed due to AP finally invoice match, now AP cancels
--  the finally invoice match
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the entity type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--p_use_enc_gt_flag
--  Specifies if the input values have been populated in the PO_ENCUMBRANCE_GT
--  table (using populate_encumbrance_gt procedure) instead of being passed in
--  as parameters. Has to be used if  multiple ids needs to passed in.
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--p_invoice_id
--  The id of the invoice that is being cancelled to cause the undo of the
--  final match.
--OUT:
--x_return_status
--  APPS Standard parameter
--x_po_return_code
--  Indicates whether Requisition is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE undo_final_close(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  p_use_enc_gt_flag                IN             VARCHAR2
,  p_override_funds                 IN             VARCHAR2
,  p_use_gl_date                    IN             VARCHAR2
,  p_override_date                  IN             DATE
,  p_invoice_id                     IN             NUMBER
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
)
IS

l_api_name      CONSTANT VARCHAR2(30) := 'UNDO_FINAL_CLOSE';
l_log_head	CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress	VARCHAR2(3) := '000';
l_packet_id     NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag',p_use_enc_gt_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_invoice_id',p_invoice_id);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT UNDO_FINAL_CLOSE_SP;

l_progress := '020';

x_po_return_code := NULL;
x_online_report_id := NULL;

-- Call do_action
do_action(
   x_return_status	=> x_return_status
,  p_action		=> g_action_UNDO_FINAL_CLOSE
,  p_check_only_flag    => g_parameter_NO
,  p_cbc_flag           => NULL
,  p_doc_type		=> p_doc_type
,  p_doc_subtype	=> p_doc_subtype
,  p_doc_level		=> p_doc_level
,  p_doc_level_id	=> p_doc_level_id
,  p_use_enc_gt_flag	=> p_use_enc_gt_flag
,  p_employee_id       	=> FND_GLOBAL.USER_ID
,  p_override_funds	=> p_override_funds
,  p_prevent_partial_flag => NULL
,  p_use_gl_date	=> p_use_gl_date
,  p_override_date	=> p_override_date
,  p_validate_document	=> g_parameter_NO
,  p_use_force_mode	=> g_parameter_NO
,  p_invoice_id            => p_invoice_id
,  p_ap_encumbered_amount  => NULL
,  p_ap_cancelled_quantity => NULL
,  p_budget_acct_id        => NULL
,  x_packet_id          => l_packet_id
,  x_online_report_id	=> x_online_report_id
,  x_po_return_code	=> x_po_return_code
);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO UNDO_FINAL_CLOSE_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END undo_final_close;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_cbc_yearend_reserve
--Pre-reqs:
-- None.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure performs funds reservation on all eligible
--  distributions of a document
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  For Reserve, this should always be g_HEADER
--p_doc_level_id
--  The id corresponding to the doc level type:
--  For Reserve, this should always be header_id (or release_id for Releases)
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_employee_id
--  Employee Id of the user taking the action
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_cbc_yearend_reserve(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_doc_level          IN    VARCHAR2
,  p_doc_level_id       IN    NUMBER
,  p_override_funds     IN    VARCHAR2
,  p_employee_id        IN    NUMBER
,  x_po_return_code     OUT NOCOPY  VARCHAR2
,  x_online_report_id   OUT NOCOPY  NUMBER
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_CBC_YEAREND_RESERVE';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_packet_id             NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_employee_id',p_employee_id);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_CBC_YEAREND_RESERVE_SP;

l_progress := '020';

x_po_return_code := NULL;
x_online_report_id := NULL;

do_action(x_return_status => x_return_status,
  p_action => g_action_RESERVE,
  p_check_only_flag => g_parameter_NO,
  p_cbc_flag => g_parameter_YES,
  p_doc_type => p_doc_type,
  p_doc_subtype => p_doc_subtype,
  p_doc_level => p_doc_level,
  p_doc_level_id => p_doc_level_id,
  p_use_enc_gt_flag => g_parameter_NO,
  p_employee_id => p_employee_id,
  p_override_funds => p_override_funds,
  p_prevent_partial_flag => g_parameter_YES,
  p_use_gl_date => g_parameter_YES,
  p_override_date => NULL,
  p_validate_document => g_parameter_NO,
  p_use_force_mode => g_parameter_YES,
  x_packet_id => l_packet_id,
  x_po_return_code => x_po_return_code,
  x_online_report_id => x_online_report_id);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO DO_CBC_YEAREND_RESERVE_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_cbc_yearend_reserve;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_cbc_yearend_unreserve
--Pre-reqs:
-- None.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  This procedure unreserves the encumbrance on all eligible distributions of
--  the requested document or document doc level
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing distribution
--  GL date instead of the override date, when possible
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in GL entries
--p_employee_id
--  Employee Id of the user taking the action
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_cbc_yearend_unreserve(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_doc_level          IN    VARCHAR2
,  p_doc_level_id       IN    NUMBER
,  p_override_funds     IN    VARCHAR2
,  p_use_gl_date        IN    VARCHAR2
,  p_override_date      IN    DATE
,  p_employee_id        IN    NUMBER
,  x_po_return_code     OUT NOCOPY  VARCHAR2
,  x_online_report_id   OUT NOCOPY  NUMBER
)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_CBC_YEAREND_UNRESERVE';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_packet_id             NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date',p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_employee_id',p_employee_id);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT DO_CBC_YEAREND_UNRESERVE_SP;

l_progress := '020';

x_po_return_code := NULL;
x_online_report_id := NULL;

do_action(x_return_status => x_return_status,
  p_action => g_action_UNRESERVE,
  p_check_only_flag => g_parameter_NO,
  p_cbc_flag => g_parameter_YES,
  p_doc_type => p_doc_type,
  p_doc_subtype => p_doc_subtype,
  p_doc_level => p_doc_level,
  p_doc_level_id => p_doc_level_id,
  p_use_enc_gt_flag => g_parameter_NO,
  p_employee_id => p_employee_id,
  p_override_funds => p_override_funds,
  p_prevent_partial_flag => NULL,
  p_use_gl_date => p_use_gl_date,
  p_override_date => p_override_date,
  p_validate_document => g_parameter_NO,
  p_use_force_mode => g_parameter_YES,
  x_packet_id => l_packet_id,
  x_po_return_code => x_po_return_code,
  x_online_report_id => x_online_report_id);

l_progress := '100';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,x_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_packet_id',l_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',x_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO DO_CBC_YEAREND_UNRESERVE_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END do_cbc_yearend_unreserve;


-------------------------------------------------------------------------------
--Start of Comments
--Name: reinstate_po_encumbrance
--Pre-reqs:
-- None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- It should created GL reversal entries if the distribution is
-- either unreserved or the its shipment is Finally closed.
-- Usage Notes: by AP: AP calls the group API twice, and hence, this
-- private API twice.  It is called once with p_tax_line_flag = g_parameter_YES
-- and once with p_tax_line_flag = g_parameter_NO. If flag=NO, then AP passes
-- p_encumbrance_amt as the amount AP reversed, excluding variances AND taxes.
-- If flag=YES, then AP passes only the tax portion of what it reversed.
-- On the PO side, we ignore the YES call, and handle taxes on our own
-- for the NO call.  This was done to make the backend simpler by allowing
-- the tax logic to be consolidated.  The nonrecoverable_tax_rate is
-- determined and used as used for other documents within get_amounts.
-- Refer to bug 3480949 for more info.
--Parameters:
--IN:
--p_distribution_id
--  po_distribution_id
--p_invoice_id
--  po_invoice_id
--p_encumbrance_amt
--  encumbrance amount in functional currency for which AP will reinstate the
--  PO encumbrance on Invoice cancellation. AP should take care of the
--  overbilled case and any variances.
--  IF (p_encumbrance_amt >0) THEN
--       Invoice Cancellation, PO API does Cr (AP is doing -Cr)
--  ELSE
--       Memo Cancellation, PO API does Dr (AP is doing -Dr)
--p_qty_cancelled
--  Invoice qty cancelled for the PO distribution. This should be PO UOM
--  p_qty_cancelled is -ve for Invoice Cancellation
--                     +ve for Credit Memo Cancellation
--p_budget_account_id
--  Budget account id - account on which the AP does PO reversal
--p_gl_date
--  Valid open Date on which AP will reinstate PO encumbrance on Invoice
--  cancellation. We want the Dr and Cr to go in the same period.
--p_period_name
-- period name
--p_period_year
-- period year
--p_period_num
-- period num
--p_quarter_num
-- quarter num
--p_tax_line_flag  -- Bug 3480949
-- Set depending upon which values AP calls the API with.
-- g_parameter_NO - the original amounts before tax applied
-- g_parameter_YES - the tax on the original amounts only
--OUT:
--x_packet_id
--  GL PACKET ID, if gl entries are made otherwise null
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE reinstate_po_encumbrance(
   x_return_status     OUT NOCOPY VARCHAR2,
   p_distribution_id   IN         NUMBER,
   p_invoice_id        IN         NUMBER,
   p_encumbrance_amt   IN         NUMBER,
   p_qty_cancelled     IN         NUMBER,
   p_budget_account_id IN         NUMBER,
   p_gl_date           IN         DATE,
   p_period_name       IN         VARCHAR2,
   p_period_year       IN         VARCHAR2,
   p_period_num        IN         VARCHAR2,
   p_quarter_num       IN         VARCHAR2,
   p_tax_line_flag     IN         VARCHAR2,  -- Bug 3480949
   x_packet_id         OUT NOCOPY NUMBER
)
IS

l_api_name              CONSTANT varchar2(30) := 'REINSTATE_PO_ENCUMBRANCE';
l_log_head              CONSTANT varchar2(240) := g_pkg_name || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_action                VARCHAR2(30);
l_doc_type              PO_DOCUMENT_TYPES.document_type_code%TYPE;
l_doc_subtype           PO_HEADERS_ALL.type_lookup_code%TYPE;
l_distribution_type     PO_DISTRIBUTIONS_ALL.distribution_type%TYPE;
l_po_return_code        VARCHAR2(10);
l_online_report_id      PO_ONLINE_REPORT_TEXT.online_report_id%TYPE;

l_amt_based_line_flag   VARCHAR2(1);  -- Bug 3480949

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_distribution_id',
                      p_distribution_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_invoice_id', p_invoice_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_encumbrance_amt',
                      p_encumbrance_amt);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_qty_cancelled',
                      p_qty_cancelled);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_budget_account_id',
                      p_budget_account_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_gl_date', p_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_period_name',
                      p_period_name);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_period_year',
                      p_period_year);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_period_num',
                      p_period_num);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_quarter_num',
                      p_quarter_num);
   -- Bug 3480949: log p_tax_line_flag
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_tax_line_flag',
                      p_tax_line_flag);
END IF;

l_progress := '001';

SAVEPOINT REINSTATE_PO_ENCUMBRANCE_SP;

l_progress := '002';


-- Start Bug 3480949: If p_tax_line_flag = g_parameter_YES,
-- return success without doing anything.

IF (NVL(p_tax_line_flag, g_parameter_NO) = g_parameter_YES) THEN
   x_packet_id := NULL;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   RETURN;
END IF;

l_progress := '005';


--<Complex Work R12>: changed this query to use line location value
--basis instead of line level order type lookup code.
-- If a quantity based line loc is passed with quantity = 0, it is assumed
-- that this is the second call by AP, in which the tax amount is being
-- passed.  Hence, we ignore the call, since the first call we would
-- have added PO tax in the first call which passed the original amount.

-- For amounts based line locs, the only way for AP to tell us that the
-- particular call is a tax line is to pass p_tax_line_flag = 'Y'.
-- This will only occur after installing a one-off patch AP
-- will provide on top of 11i.AP.M.  Until then, taxed amount based line locs
-- will over reinstate encumbrance.  Untaxed amount based line locs should
-- still work correctly.

SELECT DECODE( PLL.value_basis  --<Complex Work R12>
             ,  g_order_type_FIXED_PRICE, 'Y'
             ,  g_order_type_RATE, 'Y'
             ,  'N'
             )
INTO l_amt_based_line_flag
FROM  PO_LINE_LOCATIONS_ALL PLL
    , PO_DISTRIBUTIONS_ALL POD
WHERE POD.po_distribution_id = p_distribution_id
 AND  PLL.line_location_id = POD.line_location_id
;

IF ((l_amt_based_line_flag = 'N')  and (NVL(p_qty_cancelled, 0) = 0))
THEN
   x_packet_id := NULL;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   RETURN;
END IF;

l_progress := '008';
-- End Bug 3480949


IF p_encumbrance_amt > 0 THEN
   -- Invoice Cancellation
   l_progress:= '010';
   l_action := g_action_INVOICE_CANCEL;

ELSIF p_encumbrance_amt < 0 THEN
   -- Credit Memo Cancellation
   l_progress := '020';
   l_action := g_action_CR_MEMO_CANCEL;

ELSE -- p_encumbrance_amt == 0, we use p_qty_cancelled to decide

   IF p_qty_cancelled < 0 THEN
      l_progress := '030';
      l_action := g_action_INVOICE_CANCEL;

   ELSIF p_qty_cancelled > 0 THEN
      l_progress := '040';
      l_action := g_action_CR_MEMO_CANCEL;

   ELSE -- p_qty_cancelled = 0, No entries should be created
      l_progress := '050';

      x_packet_id := NULL;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      return;
   END IF;

END IF;

l_progress := '060';
IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Action type: ' || l_action);
END IF;


-- Get the distribution_type
SELECT POD.distribution_type
INTO l_distribution_type
FROM PO_DISTRIBUTIONS_ALL POD
WHERE POD.po_distribution_id = p_distribution_id;

l_progress := '070';

-- Convert the distribution type into document type and subtype.
PO_ENCUMBRANCE_PREPROCESSING.derive_doc_types_from_dist(
   p_distribution_type => l_distribution_type
,  x_doc_type => l_doc_type
,  x_doc_subtype => l_doc_subtype
);

l_progress := '080';
IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Document type: ' || l_doc_type ||
                       ', Document subtype: ' || l_doc_subtype);
END IF;

do_action(x_return_status => x_return_status,
  p_action => l_action,
  p_check_only_flag => g_parameter_NO,
  p_cbc_flag => g_parameter_NO,
  p_doc_type => l_doc_type,
  p_doc_subtype => l_doc_subtype,
  p_doc_level => g_doc_level_DISTRIBUTION,
  p_doc_level_id => p_distribution_id,
  p_use_enc_gt_flag => g_parameter_NO,
  p_employee_id => NULL,
  p_override_funds => g_parameter_NO,
  p_prevent_partial_flag => NULL,
  p_use_gl_date => g_parameter_USE_PROFILE,--bug#5462791
  p_override_date => p_gl_date,
  p_validate_document => g_parameter_NO,
  p_use_force_mode => g_parameter_NO,
  p_invoice_id => p_invoice_id,
  p_ap_encumbered_amount => abs(p_encumbrance_amt),
  p_ap_cancelled_quantity => abs(p_qty_cancelled),
  p_budget_acct_id => p_budget_account_id,
  x_packet_id => x_packet_id,
  x_po_return_code => l_po_return_code,
  x_online_report_id => l_online_report_id
);

l_progress := '090';

IF (  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   OR x_return_status IS NULL
) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '100';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_packet_id',
                      x_packet_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',
                      l_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_return_code',
                      l_po_return_code);
   PO_DEBUG.debug_end(l_log_head);
END IF;


EXCEPTION
WHEN OTHERS THEN
   -- bug 3454804 - robust exception handling
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');

      -- Do all of the common exception handling.
      handle_exception(l_api_name,l_progress,x_return_status,l_po_return_code);

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'handle_exception done');

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_packet_id',x_packet_id);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_return_code',l_po_return_code);
         PO_DEBUG.debug_var(l_log_head,l_progress,'l_online_report_id',l_online_report_id);
      END IF;

      -- Rollback as per API standards.
      ROLLBACK TO REINSTATE_PO_ENCUMBRANCE_SP;

      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');

   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END reinstate_po_encumbrance;


------------------------------------------------------------------------------
--Start of Comments
--Name: is_agreement_encumbered
--Pre-reqs:
--  The org context must be set before calling this procedure, as it
--  relies on the org-striped view po_headers
--Modifies:
--  N/A.
--Locks:
--  None.
--Function:
--  This procedure is an API that informs callers whether a particular agreement
--  is/can be encumbered, based on its header level encumbrance_required flag,
--  and whether the agreement is in the same OU as the caller.
--  The output table contains results in the same ordering as the input table.
--Parameters:
--IN:
--p_agreement_ids_tbl
--  A table of po_header_ids corresponding to the PAs that we are checking
--  the encumbered state of.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_agreement_encumbered_tbl
--  A table of Y/N results indicating whether each PA is encumbered or not.
--  Y = the given PA is/can be encumbered.
--  N = the PA is not eligible for encumbrance
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE is_agreement_encumbered(
   x_return_status               OUT NOCOPY  VARCHAR2
,  p_agreement_id_tbl            IN    PO_TBL_NUMBER
,  x_agreement_encumbered_tbl    OUT NOCOPY  PO_TBL_VARCHAR1
)
IS

l_api_name              CONSTANT varchar2(30) := 'IS_AGREEMENT_ENCUMBERED';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_procedure_id          NUMBER;

l_sequence_tbl          PO_TBL_NUMBER;  -- bug3546894

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_agreement_id_tbl',p_agreement_id_tbl);
END IF;

l_progress := '001';

-- Standard Start of API savepoint
SAVEPOINT IS_AGREEMENT_ENCUMBERED_SP;

l_progress := '002';

l_procedure_id := PO_CORE_S.get_session_gt_nextval();

l_progress := '010';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_procedure_id',l_procedure_id);
END IF;

--SQL What: Populate the global temp table with the po_header_ids from the
--          input table (and note the ordering)
--SQL Why:  We can then do SQL operations in bulk on the input ids, while
--          preserving the guarantee that the output values are ordered
--          corresponding to the order of the input values

-- bug3546894
-- Use an indexed column to store the sequence in PO_SESSION_GT. We will also
-- save the same in PL/SQL table l_sequence_tbl
FORALL i IN 1 .. p_agreement_id_tbl.COUNT
INSERT INTO PO_SESSION_GT TEMP
(  key
,  num1
,  index_num1
)
VALUES
(  l_procedure_id
,  p_agreement_id_tbl(i)
,  PO_SESSION_GT_S.NEXTVAL
)
RETURNING TEMP.index_num1
BULK COLLECT INTO l_sequence_tbl
;

l_progress := '020';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
                       'Bulk Insertion into Session Table success');
END IF;

--SQL What: Check whether the input PAs are/can be encumbered in the current OU.
--          We then populate this result in bulk into the global temp table.
--SQL Why:  Callers that are sourcing a Requisition against a BPA need to
--          know whether the BPA is encumbered or not, because it determines
--          the setting of the Reqs prevent_encumbrance_flag.

UPDATE PO_SESSION_GT TEMP
SET char1 =
    (SELECT POH.encumbrance_required_flag
     FROM PO_HEADERS POH
     WHERE POH.po_header_id = TEMP.num1
    )
WHERE TEMP.key = l_procedure_id
;

l_progress := '030';

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,
                        'Encumbrance information updated successfully');

   SELECT rowid BULK COLLECT INTO PO_DEBUG.g_rowid_tbl
   FROM PO_SESSION_GT WHERE key = l_procedure_id
   ;

   PO_DEBUG.debug_table(l_log_head,l_progress,'PO_SESSION_GT'
   ,  PO_DEBUG.g_rowid_tbl
   ,  po_tbl_varchar30('key','num1','char1','num2')
   );

END IF;

--SQL What: Retrieve the result of the previous SQL query into a PL/SQL table
--SQL Why:  The callers will get the result information from this table.  Each
--          line in this output table will correspond to a line from the input
--          table, with the ordering preserved.

-- bug3546894
-- we want to obtain the result in the same order as we insert into
-- PO_SESSION_GT in the first place.
FORALL i IN 1..l_sequence_tbl.COUNT
UPDATE PO_SESSION_GT
SET char1 = NVL(char1,'N')
WHERE key = l_procedure_id
AND index_num1 = l_sequence_tbl(i)
RETURNING char1
BULK COLLECT INTO x_agreement_encumbered_tbl
;

l_progress := '040';

x_return_status := fnd_api.g_ret_sts_success;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_agreement_encumbered_tbl',x_agreement_encumbered_tbl);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_agreement_encumbered_tbl',x_agreement_encumbered_tbl);
      END IF;
      ROLLBACK TO IS_AGREEMENT_ENCUMBERED_SP;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
      END IF;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END is_agreement_encumbered;


------------------------------------------------------------------------------
--Start of Comments
--Name: is_agreement_encumbered
--Pre-reqs:
--  org_context is set
--Modifies:
--  N/A.
--Locks:
--  None.
--Function:
--  This procedure is an API that informs callers whether a particular agreement
--  is/can be encumbered, based on its header level encumbrance_required flag.
--  The output table contains results in the same ordering as the input table.
--Parameters:
--IN:
--p_agreement_id
--  A po_header_id corresponding to the PA that we are checking
--  the encumbered state of.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_agreement_encumbered_flag
--  Indicates whether the PA is encumbered or not.
--  Y = the given PA is/can be encumbered.
--  N = the PA is not eligible for encumbrance
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE is_agreement_encumbered(
   x_return_status               OUT NOCOPY  VARCHAR2
,  p_agreement_id                IN          NUMBER
,  x_agreement_encumbered_flag   OUT NOCOPY  VARCHAR2
)
IS

l_api_name CONSTANT varchar2(30) := 'IS_AGREEMENT_ENCUMBERED';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';
l_agreement_encumbered_tbl  po_tbl_varchar1;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT IS_AGREEMENT_ENCUMBERED_SP;

l_progress := '001';

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
      || l_progress,'Invoked');
   END IF;
END IF;

l_progress := '010';

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
      || l_progress,'Calling bulk is_agreement_encumbered');
   END IF;
END IF;

is_agreement_encumbered(
   x_return_status => x_return_status
,  p_agreement_id_tbl => po_tbl_number(p_agreement_id)
,  x_agreement_encumbered_tbl => l_agreement_encumbered_tbl
);

l_progress := '020';

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
      || l_progress,'Call to bulk is_agreement_encumbered complete');
   END IF;
END IF;

x_agreement_encumbered_flag := l_agreement_encumbered_tbl(1);

IF g_debug_stmt THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||l_api_name||'.'
      || l_progress,'End of is_agreement_encumbered');
   END IF;
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO IS_AGREEMENT_ENCUMBERED_SP;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
      END IF;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END is_agreement_encumbered;


------------------------------------------------------------------------------
--Start of Comments
--Name: do_action
--Pre-reqs:
--  org context is set
--Modifies:
--  GL_BC_PACKETS
--  PO_ONLINE_REPORT_TEXT
--  PO_ENC_DISTRIBUTIONS_GT
--Locks:
--  None.
--Function:
--  This procedure performs funds action on all eligible distributions of
--  a document. Creates encumbrance entries in the gl_bc_packets table.
--  Adds distribution-specific transaction information into the
--  po_online_report_text table.
--Parameters:
--IN:
--p_action
--  The encumbrance action being performed.
--p_check_only_flag
--  Indicates whether the calling action is check_<> or do_<> action
--  (i.e. simple funds check versus an actual encumbrance-modifying action)
--p_cbc_flag
--  This parameter is only set to Y if the action is one of the CBC Year-End
--  processes.  If this is Y, p_action is either Reserve or Unreserve
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--p_use_enc_gt_flag
--  Set to g_parameter_NO if calling with p_doc_level_id
--  Else if using the inteface table g_parameter_YES
--p_validate_document
--  Indicates whether to perform general document state/submission checks
--  If 'Y', then encumbrance code will make calls to check doc correctness
--  If 'N', then the caller has already done these validations.
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to
--  make a transaction succeed.
--p_use_gl_date
--  Flag that specifies whether to always prefer using the existing
--  distribution GL date instead of the override date, when possible
--p_override_date
--  Caller-specified date to use for distribution encumbrance date in
--  GL entries
--p_use_force_mode
--  Y/N flag indicates whether to send transaction to GL in GL Force mode
--p_employee_id
--  Employee Id of the user taking the action
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_action(
   x_return_status         OUT NOCOPY VARCHAR2
,  p_action                IN  VARCHAR2
,  p_check_only_flag       IN  VARCHAR2
,  p_cbc_flag              IN  VARCHAR2
,  p_doc_type              IN  VARCHAR2
,  p_doc_subtype           IN  VARCHAR2
,  p_doc_level             IN  VARCHAR2
,  p_doc_level_id          IN  NUMBER
,  p_use_enc_gt_flag       IN  VARCHAR2
,  p_employee_id           IN  NUMBER
,  p_override_funds    	   IN  VARCHAR2
,  p_prevent_partial_flag  IN  VARCHAR2
,  p_use_gl_date           IN  VARCHAR2
,  p_override_date         IN  DATE
,  p_validate_document     IN  VARCHAR2
,  p_use_force_mode        IN  VARCHAR2
-- The following params are only revelant to
-- the invoice cancel API (INs are default NULL)
,  p_invoice_id            IN  NUMBER
,  p_ap_encumbered_amount  IN  NUMBER
,  p_ap_cancelled_quantity IN  NUMBER
,  p_budget_acct_id        IN  NUMBER
,  x_packet_id             OUT NOCOPY NUMBER
-- End of invoice-cancel specific parameters
,  x_online_report_id      OUT NOCOPY NUMBER
,  x_po_return_code        OUT NOCOPY VARCHAR2)
IS

l_api_name              CONSTANT varchar2(30) := 'DO_ACTION';
l_log_head		CONSTANT varchar2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';

l_currency_code_func  GL_SETS_OF_BOOKS.currency_code%TYPE;
l_set_of_books_id     GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
l_req_encumb_type FINANCIALS_SYSTEM_PARAMETERS.req_encumbrance_type_id%TYPE;
l_po_encumb_type  FINANCIALS_SYSTEM_PARAMETERS.purch_encumbrance_type_id%TYPE;

l_override_funds    VARCHAR2(1);
l_use_gl_date	    VARCHAR2(1);
l_partial_flag 	    VARCHAR2(1);
l_cbc_flag          VARCHAR2(1);
l_get_backing_docs_flag VARCHAR2(1);

--GL call variables
l_gl_packet_status  GL_BC_PACKETS.status_code%TYPE;  --used in insert_packet
l_gl_call_mode	    VARCHAR2(1);      --used in execute_gl_call
l_packet_id	    NUMBER   := NULL;        -- Bug 3218669
l_gl_return_code    VARCHAR2(1);

l_user_id               NUMBER;
l_user_resp_id          NUMBER;
l_document_id           NUMBER;

l_validation_successful_flag  VARCHAR2(1);
l_sub_check_report_id         NUMBER;
l_period_exception_flag       VARCHAR2(1) := 'N';

l_po_return_msg_name    FND_NEW_MESSAGES.message_name%TYPE;
l_entity_token          PO_LOOKUP_CODES.displayed_field%TYPE;
l_exc_code              NUMBER;
l_exc_message_text      FND_NEW_MESSAGES.message_text%TYPE;

l_dist_count   NUMBER;

-- Bug 3280496
l_do_state_check      VARCHAR2(1);

-- bug 3518116
l_action                VARCHAR2(30);
l_doc_id_tbl            po_tbl_number;
--<eTax Integration R12>
l_po_document_id   PO_HEADERS_ALL.PO_HEADER_ID%type;
l_req_document_id  PO_REQUISITION_HEADERS_ALL.REQUISITION_HEADER_ID%type;
l_rel_document_id   PO_HEADERS_ALL.PO_HEADER_ID%type;
l_return_status VARCHAR2(1);


/* bug#6069405 start*/

l_distribution_type_tbl         po_tbl_varchar30;
l_distribution_id_tbl           PO_TBL_NUMBER;
l_nonrecoverable_tax_tbl        PO_TBL_NUMBER;
l_distribution_cnt              NUMBER;
/*12405805*/
l_old_pkt_id NUMBER;
l_exec_gl_call_ret_code   VARCHAR2(1);
/*12405805*/


l_zero_enc_cnt NUMBER; --Bug 12907851

l_event_id NUMBER;

/* bug#6069405 end*/
BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_action', p_action);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_check_only_flag',
                      p_check_only_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_cbc_flag', p_cbc_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype', p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id', p_doc_level_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_enc_gt_flag',
                      p_use_enc_gt_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_employee_id', p_employee_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_funds',
                      p_override_funds);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_prevent_partial_flag',
                      p_prevent_partial_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_gl_date', p_use_gl_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_override_date',
                      p_override_date);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validate_document',
                      p_validate_document);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_use_force_mode',
                      p_use_force_mode);
END IF;

x_po_return_code := NULL;
x_online_report_id := NULL;

l_progress := '010';

--
-- Get the Financial set-up information
--
SELECT
   GL_SOB.currency_code
,  FSP.set_of_books_id
,  FSP.req_encumbrance_type_id
,  FSP.purch_encumbrance_type_id
INTO
   l_currency_code_func
,  l_set_of_books_id
,  l_req_encumb_type
,  l_po_encumb_type
FROM
   FINANCIALS_SYSTEM_PARAMETERS FSP
,  GL_SETS_OF_BOOKS GL_SOB
WHERE
   GL_SOB.set_of_books_id = FSP.set_of_books_id
;

l_progress := '020';
IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Retrieved financial set-up');
END IF;

--
--Determine other Encumbrance-related settings
--

-- bug 3518116
-- For most subroutines, Req Split is identical to Adjust.
-- use l_action for all subroutines calls (get_dists/get_amts etc)
-- except encumbrance validations and document update/post-processing
IF (p_action = g_action_REQ_SPLIT) THEN
   l_action := g_action_ADJUST;
ELSE
   l_action := p_action;
END IF;

l_progress := '021';

IF (p_check_only_flag = 'Y') THEN
   l_gl_packet_status := 'C';
ELSE
   l_gl_packet_status := 'P';
END IF;

IF (p_use_force_mode = 'Y') THEN
   l_gl_call_mode := 'F';
ELSIF (p_check_only_flag = g_parameter_YES) THEN
   l_gl_call_mode := 'C';
--<bug#5523323 START>
--For all cases other than force mode/funds check we would make the
--gl_call with 'R' (RESERVE) as the gl mode.
ELSE
   l_gl_call_mode := 'R';
END IF;
--<bug#5523323 END>

l_progress := '022';

IF (p_override_funds = g_parameter_USE_PROFILE) THEN
   FND_PROFILE.get('PO_REQAPPR_OVERRIDE_FUNDS', l_override_funds);
ELSE
   l_override_funds := p_override_funds;
END IF;

l_override_funds := nvl(l_override_funds, 'N');

l_progress := '024';

IF (p_use_gl_date = g_parameter_USE_PROFILE) THEN
   FND_PROFILE.get('PO_GL_DATE', l_use_gl_date);
ELSE
   l_use_gl_date := p_use_gl_date;
END IF;

l_use_gl_date := nvl(l_use_gl_date, 'N');

l_progress := '026';

IF p_action = g_action_RESERVE THEN
  --<eTax integration R12 Start>
  l_po_document_id  :=NULL;
  l_req_document_id  :=NULL;
  l_rel_document_id   :=NULL;

  l_progress := '027';

  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                        l_api_name||'.' || l_progress,
                   'Reserve : Calculate tax if the current one is not correct');
     END IF;
  END IF;

  /*Derving the req and po header id  that is required for the tax API*/
  IF p_doc_type ='PO' OR p_doc_type='PA' THEN
    IF p_doc_level ='HEADER' THEN
      l_po_document_id := p_doc_level_id;
    ELSIF p_doc_level='LINE' THEN
       SELECT po_header_id into l_po_document_id FROM po_lines_all
       WHERE po_line_id = p_doc_level_id ;
    ELSIF p_doc_level='SHIPMENT' THEN
       SELECT po_header_id into l_po_document_id FROM po_line_locations_all
       WHERE line_location_id = p_doc_level_id ;
    ELSIF p_doc_level='DISTRIBUTION' THEN
       SELECT po_header_id into l_po_document_id FROM po_distributions_all
       WHERE po_distribution_id = p_doc_level_id ;
    END IF;
  END IF;

  IF p_doc_type ='RELEASE' THEN
    IF p_doc_level='SHIPMENT' THEN
       SELECT po_header_id into l_rel_document_id FROM po_line_locations_all
       WHERE line_location_id = p_doc_level_id ;
    ELSIF p_doc_level='DISTRIBUTION' THEN
       SELECT po_header_id into l_rel_document_id FROM po_distributions_all
       WHERE po_distribution_id = p_doc_level_id ;
    END IF;
  END IF;

  IF p_doc_type='REQ' THEN
    IF p_doc_level ='HEADER' THEN
        l_req_document_id := p_doc_level_id;
    ELSIF p_doc_level='LINE' THEN
       SELECT requisition_header_id into l_req_document_id
       FROM po_requisition_lines_all
       WHERE requisition_line_id = p_doc_level_id ;
    ELSIF p_doc_level='DISTRIBUTION' THEN
        SELECT requisition_header_id into l_req_document_id
        FROM  PO_REQUISITION_LINES_ALL POL, PO_REQ_DISTRIBUTIONS_ALL POD
        WHERE  POL.REQUISITION_LINE_ID = POD.REQUISITION_LINE_ID
        AND  POD.DISTRIBUTION_ID =p_doc_level_id;
    END IF;
  END IF;



  IF po_tax_interface_pvt.calculate_tax_yes_no(
                                 p_po_header_id  => l_po_document_id,
                                 p_po_release_id => l_rel_document_id,
                                 p_req_header_id => l_req_document_id) = 'Y'
  THEN
    IF g_debug_stmt THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                        l_api_name||'.' || l_progress,
                  'Req 010: Calcualte tax as the current one is not correct');
       END IF;
    END IF;

    IF p_doc_type='REQ' THEN
      PO_TAX_INTERFACE_PVT.calculate_tax_requisition(
                             x_return_status         => l_return_status,
                             p_requisition_header_id => l_req_document_id,
                             p_calling_program       => g_action_RESERVE);
    ELSIF p_doc_type='PO' or p_doc_type='PA' or p_doc_type='RELEASE' THEN
      PO_TAX_INTERFACE_PVT.calculate_tax(
                        p_po_header_id  => l_po_document_id,
                        p_po_release_id => l_rel_document_id,
                        p_calling_program =>g_action_RESERVE,
                        x_return_status => l_return_status);
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       IF g_debug_stmt THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head || '.'||
                            l_api_name||'.' || l_progress,
                            ' Calculate tax has errored out');
           END IF;
       END IF;
       --write the error message in the online report
       FND_MESSAGE.set_name('PO', 'PO_AP_TAX_ENGINE_FAILED_WARN');
       l_exc_message_text := FND_MESSAGE.get;
       PO_ENCUMBRANCE_POSTPROCESSING.create_exception_report(
                         p_message_text       => l_exc_message_text,
                         p_user_id            => l_user_id,
                         x_online_report_id   => x_online_report_id
                        );
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_po_return_code := g_return_FAILURE;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  --<eTax integration R12 End>
END IF; -- end of check for Reserve action

l_progress := '028';

l_user_id := FND_GLOBAL.user_id;
l_user_resp_id := FND_GLOBAL.resp_id;

l_cbc_flag := nvl(p_cbc_flag, g_parameter_NO);

IF (p_action IN (g_action_FINAL_CLOSE, g_action_UNDO_FINAL_CLOSE)
    OR l_cbc_flag = g_parameter_YES) THEN
   -- Final Close, Undo Final Close does not operate on backing docs.
   -- Additionally, CBC Year-End actions do not act on backing docs

   l_get_backing_docs_flag := g_parameter_NO;

--Bug 3480949: removed logic that sets get_backing_docs_flag to
-- NO if the action is Invoice Cancel and the cancelled qty is 0.
-- This case should not happen anyways, and keeping the logic means
-- we would never do backing docs for Services line Invoice cancel

ELSE
   -- Setting flag to Yes will cause code to check if there are
   -- eligible backing docs.  There may or may not be.

   l_get_backing_docs_flag := g_parameter_YES;
END IF;

l_progress := '030';
IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Finished variable set-up');
END IF;


--<Bug 3280496 Start>
-- if cbc_flag = 'Y', then don't do state check in encumbrance validations
IF l_cbc_flag = g_parameter_YES THEN
  l_do_state_check := g_parameter_NO;
ELSE
  l_do_state_check := g_parameter_YES;
END IF;
--<Bug 3280496 End>

l_progress := '031';
  --<SLA R12>

PO_ENCUMBRANCE_PREPROCESSING.do_encumbrance_validations(
   p_action                      => p_action
,  p_check_only_flag             => p_check_only_flag
,  p_doc_type                    => p_doc_type
,  p_doc_subtype                 => p_doc_subtype
,  p_doc_level                   => p_doc_level
,  p_doc_level_id                => p_doc_level_id
,  p_use_enc_gt_flag             => p_use_enc_gt_flag
,  p_do_state_check_flag         => l_do_state_check    -- Bug 3280496
,  p_validate_document           => p_validate_document
,  x_validation_successful_flag  => l_validation_successful_flag
,  x_sub_check_report_id         => l_sub_check_report_id
);

l_progress := '033';

IF (l_validation_successful_flag <> g_parameter_YES) THEN
   l_progress := '035';
   l_exc_code := g_SUBMISSION_CHECK_EXC_CODE;
   RAISE FND_API.G_EXC_ERROR;
END IF;

l_progress := '040';

BEGIN
   PO_ENCUMBRANCE_PREPROCESSING.get_all_distributions(
      p_action                   => l_action
   ,  p_check_only_flag          => p_check_only_flag
   ,  p_doc_type                 => p_doc_type
   ,  p_doc_subtype              => p_doc_subtype
   ,  p_doc_level                => p_doc_level
   ,  p_doc_level_id             => p_doc_level_id
   ,  p_use_enc_gt_flag          => p_use_enc_gt_flag
   ,  p_get_backing_docs_flag    => l_get_backing_docs_flag
   ,  p_ap_budget_account_id     => p_budget_acct_id
   ,  p_possibility_check_flag   => g_parameter_NO
   ,  p_cbc_flag                 => p_cbc_flag
   ,  x_count                    => l_dist_count
   );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      l_progress := '041';
      l_exc_code := G_GET_ALL_DISTS_EXC_CODE;
      RAISE;
END;

l_progress := '043';

IF (NVL(l_dist_count,0) < 1) THEN
   l_progress := '045';
   l_exc_code := g_NO_ROWS_EXC_CODE;
   RAISE FND_API.G_EXC_ERROR;
END IF;

l_progress := '046';
IF g_debug_stmt THEN
   PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows,NULL,'PO');
END IF;

-- Bug 5035240 Begin : Moved this code to check after PO_ENCUMBRANCE_GT is populated
IF p_action = g_action_RESERVE THEN
   IF (nvl(p_prevent_partial_flag, 'N') = 'Y'
       OR l_gl_call_mode = 'F') THEN

      l_progress := '047';
      l_partial_flag := 'N';

   ELSE
      -- Don't allow partials if there is any backing document
      BEGIN
         SELECT 'N'
         INTO l_partial_flag
         FROM PO_ENCUMBRANCE_GT
         WHERE origin_sequence_num IS NOT NULL
         AND rownum = 1;
         l_progress := '048';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_progress := '049';
            l_partial_flag := 'Y';
      END;
   END IF;
ELSE
   l_progress := '050';
   l_partial_flag := 'N';
END IF; -- end of partial check for Reserve action
-- Bug 5035240 End


--Bug 6069405 start
l_progress := '051';

--If the AD Event is set and the set of books currency is INR then we can assume that the user is IL customer

IF (AD_EVENT_REGISTRY_PKG.Is_Event_Done( p_Owner => 'JA',
                                         p_Event_Name => 'JAI_EXISTENCE_OF_TABLES' ) = TRUE )
  AND l_currency_code_func = 'INR' THEN /*l_currency_code_func has the functional currency code.*/

   IF g_debug_stmt THEN
	    PO_DEBUG.debug_stmt(l_log_head,l_progress,'JAI is used');
   END IF;

   --initialize the counter to zero. This counter would be used as index for the distribution PL/SQL table.

   l_distribution_cnt:= 0;

   --Use bulk collect to fetch the distribution type and distribution id

   SELECT distribution_type,
          distribution_id
     BULK COLLECT INTO l_distribution_type_tbl, l_distribution_id_tbl
     FROM po_encumbrance_gt
    ORDER BY line_location_id, distribution_id;

   --if any record is present for encumbrance processing then call the IL API
   IF l_Distribution_Id_Tbl.COUNT > 0 and l_distribution_type_tbl.count > 0 THEN

     l_progress := '052';
		 IF g_debug_stmt THEN
		 	 PO_DEBUG.debug_stmt(l_log_head,l_progress,'Execute the JAI API to fetch the non-recoverable taxes');
		 END IF;

     jai_encum_prc.fetch_nr_tax(l_Distribution_Type_Tbl,l_Distribution_Id_Tbl,p_action,p_doc_type,l_NonRecoverable_Tax_Tbl,l_Return_Status);

     l_progress := '053';

     IF l_Return_Status = 'S' THEN

		   IF g_debug_stmt THEN
		 		 PO_DEBUG.debug_stmt(l_log_head,l_progress,'Update po_encumbrance_gt with the JAI non-recoverable tax');
			 END IF;

       --Use forall to bulk update the nonrecoverable tax in the encumbrance table
       FORALL indx IN 1..l_nonrecoverable_tax_tbl.COUNT
       UPDATE po_encumbrance_gt
       SET    nonrecoverable_tax = nvl(l_nonrecoverable_tax_tbl(indx),0)
       WHERE  distribution_id    = l_distribution_id_tbl(indx)
       AND    distribution_type  = l_distribution_type_tbl(indx);

     /*  Bug 14482618: reverting the fix made via bug 9980635 as it was creating accounting twice for the NRtax
         via the PO distributions NRTax amount populated and the IRTP(India Receiving Transaction processor):

 -- Bug 9980635: Non Reoverable Tax amounts in IL tables are not in sync with the PO tables
       IF (p_check_only_flag <> 'Y') THEN
         FOR indx IN 1..l_distribution_id_tbl.Count LOOP
           IF l_distribution_type_tbl(indx) IN ( 'STANDARD','PLANNED', 'SCHEDULED','BLANKET', 'AGREEMENT') THEN
               UPDATE po_distributions_all
               SET    nonrecoverable_tax = nvl(l_nonrecoverable_tax_tbl(indx),0)
               WHERE  po_distribution_id    = l_distribution_id_tbl(indx);
           ELSIF l_distribution_type_tbl(indx) IN ('REQUISITION') THEN
               UPDATE po_req_distributions_all
               SET    nonrecoverable_tax = nvl(l_nonrecoverable_tax_tbl(indx),0)
               WHERE  distribution_id    = l_distribution_id_tbl(indx);
           END IF;
         END LOOP;
       END IF;
       --Bug 9980635: end

     End bug 14482618
  */

     END IF;
   END IF;

   l_progress := '054';
	 IF g_debug_stmt THEN
			PO_DEBUG.debug_stmt(l_log_head,l_progress,'JAI Processing -  Finished');
	 END IF;

END IF;

--Bug 6069405 end

l_progress := '055';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_partial_flag ',l_partial_flag);
END IF;

BEGIN
   PO_ENCUMBRANCE_PREPROCESSING.derive_packet_values(
      p_action                => l_action
   ,  p_doc_type              => p_doc_type
   ,  p_doc_subtype           => p_doc_subtype
   ,  p_use_gl_date           => l_use_gl_date
   ,  p_override_date         => p_override_date
   ,  p_partial_flag          => l_partial_flag
   ,  p_cbc_flag              => l_cbc_flag
   ,  p_set_of_books_id       => l_set_of_books_id
   ,  p_currency_code_func    => l_currency_code_func
   ,  p_req_encumb_type_id    => l_req_encumb_type
   ,  p_po_encumb_type_id     => l_po_encumb_type
   ,  p_ap_reinstated_enc_amt => p_ap_encumbered_amount
   ,  p_ap_cancelled_qty      => p_ap_cancelled_quantity
   ,  p_invoice_id            => p_invoice_id
   );
EXCEPTION
   WHEN G_NO_VALID_PERIOD_EXC THEN
      l_period_exception_flag := 'Y';
END;

l_progress := '060';

IF g_debug_stmt THEN
   PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows,NULL,'PO');
END IF;

IF (l_period_exception_flag = 'Y') THEN
  l_progress := '065';

  -- We didn't really send to GL, but the period exception is
  -- equivalent to returning from GL with a failure
  -- Don't go straight to exception block though, so that we
  -- can leverage the create_detailed_report procedure
  l_gl_return_code := 'F';

ELSE

   l_progress := '070';

   PO_ENCUMBRANCE_POSTPROCESSING.insert_packet(
     p_status_code           => l_gl_packet_status
   , p_user_id               => l_user_id
   , p_set_of_books_id       => l_set_of_books_id
   , p_currency_code         => l_currency_code_func
   , p_action                => l_action --bug#5646605 added the p_action parameter to derive entity/even type codes
   , x_packet_id             => l_packet_id
   );

   l_progress := '072';
   l_old_pkt_id :=  l_packet_id;  /* 12405805 execute_gl_call alters packet_id. But this is needed for later reference */
   -- If a packet was not created, l_packet_id will be NULL.
   -- This happens when all of the rows are prevent_encumbrance.

   IF (l_packet_id IS NOT NULL) THEN

      SAVEPOINT EXECUTE_GL_CALL_SP; /* Bug 3218669 */

      BEGIN
         PO_ENCUMBRANCE_POSTPROCESSING.execute_gl_call(
           p_set_of_books_id       => l_set_of_books_id
         , p_packet_id             => l_packet_id
         , p_gl_mode               => l_gl_call_mode
         , p_partial_resv_flag     => l_partial_flag
         , p_override              => l_override_funds
         , p_conc_flag             => g_parameter_NO
         , p_user_id               => l_user_id
         , p_user_resp_id          => l_user_resp_id
         , x_return_code           => l_gl_return_code
         );
      EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            l_progress := '075';
            l_exc_code := g_EXECUTE_GL_CALL_EXC_CODE;
            RAISE;
	    --<BEGIN Bug:12824154>--
         WHEN PO_ENCUMBRANCE_POSTPROCESSING.g_EXECUTE_GL_CALL_API_EXC THEN
            l_progress := '076';
            l_exc_code := g_GL_FUNDS_API_EXC;
            RAISE;
          --<END Bug:12824154>--
      END;

      l_exec_gl_call_ret_code :=  l_gl_return_code;    /* 12405805  This value is needed for later reference*/

   ELSE

      -- Pretend that the call to GL was successful.
      -- This lets us handle the case of all prevent rows for free
      -- in create_detailed_report.

      l_progress := '077';

      l_gl_return_code := 'S';

   END IF;

   -- copy_detailed_gl_results also fills in messages for the
   -- prevent_encumbrance rows, so call this whether or not
   -- a packet was created.

   PO_ENCUMBRANCE_POSTPROCESSING.copy_detailed_gl_results(
     p_packet_id             => l_old_pkt_id -- Bug#14593057 : Passing Old packet id
                                             -- generated by insert_packet_create_event
					     --- to get the events processed in this transaction
   , p_gl_return_code	     => l_gl_return_code
   );

   IF g_debug_stmt THEN
      PO_DEBUG.debug_table(l_log_head,l_progress,'PO_ENCUMBRANCE_GT',PO_DEBUG.g_all_rows,NULL,'PO');
   END IF;

   IF (p_check_only_flag = 'N') THEN

      l_progress := '800';

      -- No need to update anything if we never called GL.

      IF (l_packet_id IS NOT NULL) THEN

         l_progress := '810';

         --bug 3537764: for Req Split, p_action is REQ_SPLIT,
         --but l_action is ADJUST.  use p_action for the parameter
         --here since update is different for Req Split vs.Adjust
         PO_ENCUMBRANCE_POSTPROCESSING.update_document_encumbrance(
           p_doc_type           => p_doc_type
         , p_doc_subtype        => p_doc_subtype
         , p_action             => p_action
         , p_gl_return_code     => l_gl_return_code
         );

         l_progress := '815';

      END IF;

      l_progress := '820';

      IF (p_action IN ( g_action_RESERVE, g_action_UNRESERVE
                     ,  g_action_ADJUST, g_action_REQ_SPLIT
                     )
      ) THEN

         -- bug 3518116
         -- Sourcing Req Split operates simultaneously on lines
         -- from several different headers.
         --
         -- Multiple docs are not supported for other actions,
         -- as this procedure is a bottleneck (it doesn't work in bulk).

         IF (p_action = g_action_REQ_SPLIT) THEN

            l_progress := '830';

            -- For Req Split, there are only Reqs (main doc) in the temp table.

            SELECT DISTINCT DISTS.header_id
            BULK COLLECT INTO l_doc_id_tbl
            FROM PO_ENCUMBRANCE_GT DISTS
            ;

            l_progress := '835';

         ELSE

            l_progress := '840';

            -- Other non-check actions can only have one main doc
            -- in the temp table.

            SELECT DECODE( p_doc_type
                        ,  g_doc_type_RELEASE, DISTS.po_release_id
                        ,  DISTS.header_id
                        )
            INTO l_document_id
            FROM PO_ENCUMBRANCE_GT DISTS
            WHERE DISTS.origin_sequence_num IS NULL
            AND rownum = 1
            ;

            l_progress := '845';

            l_doc_id_tbl := po_tbl_number(l_document_id);

         END IF;

         l_progress := '850';

	 IF l_gl_return_code IN ('S', 'A', 'P') THEN
	 --Added this IF Condition to Avoid Inserting Action History Record, for Funds Check Failed cases. -- Bug 4661095

         PO_ENCUMBRANCE_POSTPROCESSING.create_enc_action_history(
           p_doc_type      => p_doc_type
         , p_doc_id_tbl    => l_doc_id_tbl
         , p_employee_id   => p_employee_id
         , p_action        => p_action
         , p_cbc_flag      => l_cbc_flag
         );

	 END if;
	 -- End Of Bug 4661095

         l_progress := '860';

         IF (  (p_action = g_action_UNRESERVE and l_cbc_flag = 'N')
            OR (p_action = g_action_RESERVE and l_cbc_flag = 'Y')
         ) THEN

            l_progress := '870';

            PO_ENCUMBRANCE_POSTPROCESSING.set_status_requires_reapproval(
               p_document_type => p_doc_type
            ,  p_action        => p_action
            ,  p_cbc_flag      => l_cbc_flag
            );

            l_progress := '875';

         END IF;

         l_progress := '890';

	--<BEGIN Bug 12907851>--
	-- Added procedure to udpate the encumbrance flag and
	-- approval details for distributions whose
	-- final amt is zero

	IF p_action IN (g_action_RESERVE,g_action_UNRESERVE) THEN
	      SELECT COUNT(*) INTO l_zero_enc_cnt
	      FROM po_encumbrance_gt
	      WHERE SEND_TO_GL_FLAG = 'Y'
	      AND NVL (final_amt, 0) = 0;

		  IF g_debug_stmt THEN
		      PO_DEBUG.debug_var(l_log_head,l_progress,'Count of distributions having final amt as zero  ',l_zero_enc_cnt);
		  END IF;

	      IF l_zero_enc_cnt > 0 THEN
	      PO_ENCUMBRANCE_POSTPROCESSING.update_zero_amt_rows(p_action   => p_action,
								 p_doc_type => p_doc_type);
	      END IF;
         END IF;
	-- <END 12907851>--

      END IF;  -- if encumb action (res, unres, adjust)

   END IF; -- if action is check only

END IF;  -- if l_period_exception_flag is 'Y'

l_progress := '900';

PO_ENCUMBRANCE_POSTPROCESSING.create_detailed_report(
   p_gl_return_code	=> l_gl_return_code
,  p_user_id		=> l_user_id
,  x_online_report_id	=> x_online_report_id
,  x_po_return_code	=> x_po_return_code
,  x_po_return_msg_name	=> l_po_return_msg_name
);

l_progress := '910';
--<bug#5055417 START>
PO_ENCUMBRANCE_POSTPROCESSING.populate_bc_report_id(x_online_report_id);
--<bug#5055417 END>
IF x_po_return_code IN (g_return_SUCCESS, g_return_WARNING) THEN
   x_return_status := FND_API.g_ret_sts_success;
ELSIF x_po_return_code IN (g_return_PARTIAL, g_return_FAILURE) THEN
   x_return_status := FND_API.g_ret_sts_error;
ELSE
   x_return_status := FND_API.g_ret_sts_unexp_error;
END IF;

-- Push the po_return_msg onto api msg list
-- Bug 3516763: No longer put a message on the message dictionary stack.
-- All callers should get message from api message stack [fnd_msg_pub]
FND_MESSAGE.set_name('PO', l_po_return_msg_name);
FND_MSG_PUB.add;


IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_online_report_id',
                      x_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',
                      x_po_return_code);
   PO_DEBUG.debug_end(l_log_head);
END IF;

     /*BEGIN : Bug 13077585 :Reverting the fix of delete unprocessesed events
      to fix the issue of view results screen. The earlier fix has an impact on
      federal customers to review the amounts for the account.
        /* 12405805
        This deletes unprocessed events arised out of checkfunds action
        and invalid events arised out of exceptions

        IF( p_check_only_flag = 'Y'
                OR
                (l_exc_code = g_EXECUTE_GL_CALL_EXC_CODE)
                OR
                 (l_gl_return_code = 'F')
           ) THEN
         IF g_debug_stmt THEN
                   PO_DEBUG.debug_var(l_log_head,l_progress,'Call made to',  'delete_unnecessary_events');
         END IF;
             PO_ENCUMBRANCE_POSTPROCESSING.delete_unnecessary_events(l_old_pkt_id, l_action);
        END IF;
         /*12405805
       END : Bug 13077585 */


EXCEPTION
WHEN OTHERS THEN
-- Highest level of exception handling happens here.
-- do_action never intentionally raises exceptions.

   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;

   --
   -- Set the return statuses.
   --

   IF (l_exc_code = g_NO_ROWS_EXC_CODE) THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_po_return_code := g_return_SUCCESS;
      l_po_return_msg_name := 'PO_ENC_API_SUCCESS';
  --Bug : 14536217 Returning error code as FAILURE and status as 'E'
  --instead of 'U' when GL_GUNDS_API_EXC is thrown as this is not an
  -- unexpected error
   ELSIF (l_exc_code = g_SUBMISSION_CHECK_EXC_CODE
          OR l_exc_code = g_GL_FUNDS_API_EXC) THEN
      x_return_status := FND_API.g_ret_sts_error;
      x_po_return_code := g_return_FAILURE;
      l_po_return_msg_name := 'PO_ENC_API_FAILURE';
   ELSE
      x_return_status := FND_API.g_ret_sts_unexp_error;
      x_po_return_code := g_return_FATAL;
      l_po_return_msg_name := 'PO_ENC_API_FAILURE';
   END IF;

   --
   -- Create the detailed results message.
   --

   IF (l_exc_code = g_SUBMISSION_CHECK_EXC_CODE) THEN

      -- For submission check failures, we already have an online_report_id.
      x_online_report_id := l_sub_check_report_id;

   ELSE

      -- Otherwise, we have to
      -- 1. get the appropriate message and
      -- 2. turn it into an online report.

      -- 1. Get the appropriate message.
       /*Bug 9570133 adding nvl around p_doc_level in the following sql */
      IF (l_exc_code = g_NO_ROWS_EXC_CODE) THEN

         SELECT PLC.displayed_field
         INTO l_entity_token
         FROM PO_LOOKUP_CODES PLC
         WHERE PLC.lookup_type = 'DOCUMENT LEVEL'
         AND PLC.lookup_code = NVL(p_doc_level,'HEADER')
         ;
         FND_MESSAGE.set_name('PO', 'PO_ENC_API_NO_ROWS');
         FND_MESSAGE.set_token('ENTITY', l_entity_token);
         l_exc_message_text := FND_MESSAGE.get;

      ELSIF (l_exc_code IN (g_GET_ALL_DISTS_EXC_CODE,g_EXECUTE_GL_CALL_EXC_CODE)) THEN

         -- Assume raiser put a message onto the API message list.
         -- Retrieve that message.
         l_exc_message_text :=
            FND_MSG_PUB.get(
               p_msg_index => FND_MSG_PUB.G_LAST
            ,  p_encoded => FND_API.G_FALSE
            );
       --<BEGIN 12824154>--
       ELSIF (l_exc_code = g_GL_FUNDS_API_EXC)   then
	       l_exc_message_text := 'GL_FUNDS_API_EXC';
		select  ae_event_id INTO PO_ENCUMBRANCE_POSTPROCESSING.g_event_id
		 from  po_bc_distributions
	       where  packet_id = l_old_pkt_id
		  and rownum = 1;
       --<END 12824154>--
      ELSE
         -- Unrecognized exception.
         -- Use the "contact sys admin" message.
         po_message_s.sql_error(g_pkg_name,l_api_name,l_progress,SQLCODE,SQLERRM);
         l_exc_message_text := FND_MESSAGE.get;

      END IF;

      -- 2. Create the online report.

      PO_ENCUMBRANCE_POSTPROCESSING.create_exception_report(
         p_message_text       => l_exc_message_text
      ,  p_user_id            => l_user_id
      ,  x_online_report_id   => x_online_report_id
      );

    END if;
   -- Push the high-level po_return_msg onto the API msg list
   -- Bug 3516763: No longer put a message on the message dictionary stack.
   -- All callers should get message from api message stack [fnd_msg_pub]

   FND_MESSAGE.set_name('PO', l_po_return_msg_name);
   FND_MSG_PUB.add;

   -- bug 3218669
   -- Clean up GL_BC_PACKETS so that the failed transaction
   -- does not continue to hold up funds
   -- if the caller decides to ROLLBACK instead of COMMIT.
   IF (l_packet_id IS NOT NULL) THEN
      ROLLBACK TO EXECUTE_GL_CALL_SP;
         /*BEGIN : Bug 13077585 :Reverting the fix of delete unprocessesed events
      to fix the issue of view results screen. The earlier fix has an impact on
      federal customers to review the amounts for the account.
                /* 12405805
        This deletes unprocessed events arised out of checkfunds action
        and invalid events arised out of exceptions

        IF( (p_check_only_flag = 'Y') OR (l_exc_code = g_EXECUTE_GL_CALL_EXC_CODE) OR(l_gl_return_code = 'F')) THEN
           PO_ENCUMBRANCE_POSTPROCESSING.delete_unnecessary_events(l_old_pkt_id, l_action);
          NULL;
        END IF;

              /*12405805 END1
        END : Bug 13077585  */


--bug#5523323. The rollback in the previous transaction is sufficient
--to remove all unnecessar records / events in case of an unexpected
--failure. The following statement is unnecessary now.
--      PO_ENCUMBRANCE_POSTPROCESSING.delete_packet_autonomous(
--                                      p_packet_id => l_packet_id);
   END IF;

END do_action;



------------------------------------------------------------------------------
--Start of Comments
--Name: create_report_object
--Pre-reqs:
--  PO_ENCUMBRANCE_GT is populated with all result columns after
--  a call to the FL funds checker
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Takes t
--Parameters:
--IN:
--p_online_report_id
--  Unique identifier that points to a set of rows in the
--  PO_ONLINE_REPORT_TEXT table.  These rows store the detailed results
--  for a particular encumbrance transaction
--p_report_successes
--  Indicates whether to include information about Successful rows.
--  Warning and Error rows are always included.
--  Values: g_parameter_YES, g_parameter_NO
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_report_object
--  Object of po_fcout_type
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE create_report_object(
   x_return_status	OUT NOCOPY	VARCHAR2
,  p_online_report_id	IN		NUMBER
,  p_report_successes	IN 		VARCHAR2
,  x_report_object	OUT NOCOPY	po_fcout_type
)
IS

l_api_name	CONSTANT varchar2(30) := 'CREATE_REPORT_OBJECT';
l_log_head 	CONSTANT varchar2(100) := g_log_head || l_api_name;
l_progress	VARCHAR2(3) := '000';
l_report_successes VARCHAR2(1);

BEGIN

l_report_successes := nvl(p_report_successes, g_parameter_YES);

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_online_report_id',
                      p_online_report_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_report_successes',
                      l_report_successes);
END IF;

l_progress := '010';

--<Bug 3278860 Start>

-- Object initialization code added at request of I. Proc.
x_report_object := po_fcout_type(null,null,null,null,
                                 null,null,null,null);

l_progress := '015';

--<Bug 3278860 End>

SELECT
   REPORT.sequence
,  REPORT.transaction_id
,  REPORT.line_num
,  REPORT.shipment_num
,  REPORT.distribution_num
,  REPORT.transaction_location
,  REPORT.message_type
,  REPORT.text_line
BULK COLLECT INTO
   x_report_object.row_index
,  x_report_object.distribution_id
,  x_report_object.line_num
,  x_report_object.shipment_num
,  x_report_object.distribution_num
,  x_report_object.result_code
,  x_report_object.msg_type
,  x_report_object.error_msg
FROM PO_ONLINE_REPORT_TEXT REPORT
WHERE REPORT.online_report_id = p_online_report_id
AND  ((l_report_successes = g_parameter_NO
       AND Nvl(REPORT.message_type,g_result_ERROR) <> g_result_SUCCESS)
     OR l_report_successes = g_parameter_YES
     )
;

l_progress := '020';
x_return_status := FND_API.g_ret_sts_success;

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',
                      x_return_status);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      --unexpected error from this procedure
      x_return_status := FND_API.g_ret_sts_unexp_error;
      --add message to the stack and log a debug msg if necessary
      po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END create_report_object;


------------------------------------------------------------------------------
--Start of Comments
--Name: is_reservable
--Pre-reqs:
--  N/A.
--Modifies:
--  N/A.
--Locks:
--  None.
--Function:
--  This procedure determines whether a given document has any distributions that
--  are eligible for funds reservation.
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_reservable_flag
--  Indicates whether funds reservation is possible on this doc level
--  'Y' means it is possible, 'N' means it isn't.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE is_reservable(
   x_return_status      OUT NOCOPY  VARCHAR2
,  p_doc_type           IN    VARCHAR2
,  p_doc_subtype        IN    VARCHAR2
,  p_doc_level          IN    VARCHAR2
,  p_doc_level_id       IN    NUMBER
,  x_reservable_flag    OUT NOCOPY  VARCHAR2
)
IS

l_api_name              CONSTANT varchar2(30) := 'IS_RESERVABLE';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT IS_RESERVABLE_SP;

l_progress := '020';

PO_ENCUMBRANCE_PREPROCESSING.check_enc_action_possible(
   p_action => g_action_RESERVE,
   p_doc_type => p_doc_type,
   p_doc_subtype => p_doc_subtype,
   p_doc_level => p_doc_level,
   p_doc_level_id => p_doc_level_id,
   x_action_possible_flag => x_reservable_flag);

l_progress := '100';

x_return_status := fnd_api.g_ret_sts_success;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_reservable_flag',x_reservable_flag);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO IS_RESERVABLE_SP;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
      END IF;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END is_reservable;


------------------------------------------------------------------------------
--Start of Comments
--Name: is_unreservable
--Pre-reqs:
--  N/A.
--Modifies:
--  N/A.
--Locks:
--  None.
--Function:
--  This procedure determines whether a given document has any distributions
--  that are eligible to be unreserved.
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_level
--  Specifies the level of the document that is being checked:
--  HEADER, LINE, SHIPMENT, DISTRIBUTION
--p_doc_level_id
--  The id corresponding to the doc level type:
--  header_id/release_id, line_id, line_location_id, distribution_id
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_ERROR if validation fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_unreservable_flag
--  Indicates whether funds unreservation is possible on this doc level
--  'Y' means it is possible, 'N' means it isn't.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE is_unreservable(
   x_return_status         OUT NOCOPY  VARCHAR2
,  p_doc_type              IN    VARCHAR2
,  p_doc_subtype           IN    VARCHAR2
,  p_doc_level             IN    VARCHAR2
,  p_doc_level_id          IN    NUMBER
,  x_unreservable_flag     OUT NOCOPY  VARCHAR2
)
IS

l_api_name              CONSTANT varchar2(30) := 'IS_UNRESERVABLE';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress              VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype',p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
END IF;

l_progress := '010';

-- Standard Start of API savepoint
SAVEPOINT IS_UNRESERVABLE_SP;

l_progress := '020';

PO_ENCUMBRANCE_PREPROCESSING.check_enc_action_possible(
   p_action => g_action_UNRESERVE,
   p_doc_type => p_doc_type,
   p_doc_subtype => p_doc_subtype,
   p_doc_level => p_doc_level,
   p_doc_level_id => p_doc_level_id,
   x_action_possible_flag => x_unreservable_flag);

l_progress := '100';

x_return_status := fnd_api.g_ret_sts_success;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_unreservable_flag',x_unreservable_flag);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO IS_UNRESERVABLE_SP;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
      END IF;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END is_unreservable;





-------------------------------------------------------------------------------
--Start of Comments
--Name: populate_encumbrance_gt
--Pre-reqs:
--  None.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  PO_HEADERS_ALL
--  PO_RELEASES_ALL
--  PO_DISTRIBUTIONS_ALL
--  PO_REQUISITION_HEADERS_ALL
--  PO_REQ_DISTRIBUTIONS_ALL
--Function:
--  Flattens the PO transaction tables to retrieve all of the
--  data needed by the encumbrance code and put it in the
--  encumbrance table.  Also locks the document headers and
--  distributions if requested to do so.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  Ids of the doc level type with which to populate the encumbrance
--  table.  Each distribution with a link to the specified id
--  will be used in the population.
--
--p_adjustment_status_tbl
--  Specifies what to populate in the adjustment_status column of
--  the encumbrance table.  A copy will be made for each adjustment
--  status provided.  The total number of rows that will be inserted
--  due to this procedure call =
--    total # of distributions below each id
--       *
--    p_adjustment_status_tbl.COUNT
--  To make one copy of each dist. with a blank adjustment_status label, use
--    po_tbl_varchar5( NULL )
--  To make a new and an old copy (typical Adjust action), use
--    po_tbl_varchar5( g_adjustment_status_OLD, g_adjustment_status_NEW )
--
--p_check_only_flag
--  Indicates whether or not to lock the document headers and distributions.
--    g_parameter_NO    lock them
--    g_parameter_YES   don't lock them
--
--OUT:
--x_return_status
--  Apps standard parameter
--  VARCHAR2(1)
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE populate_encumbrance_gt(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  p_adjustment_status_tbl          IN             po_tbl_varchar5
,  p_check_only_flag                IN             VARCHAR2
)
IS

l_log_head  CONSTANT VARCHAR2(100) := g_log_head||'POPULATE_ENCUMBRANCE_GT';
l_progress  VARCHAR2(3) := '000';

l_dist_id_tbl                    po_tbl_number;
l_dist_id_key                    NUMBER;

BEGIN

SAVEPOINT populate_encumbrance_gt_PVT;
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl', p_doc_level_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_adjustment_status_tbl'
               ,p_adjustment_status_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_check_only_flag', p_check_only_flag);
END IF;

l_progress := '010';


-- Get the distribution ids, based on the entity type/ids

PO_CORE_S.get_distribution_ids(
   p_doc_type => p_doc_type
,  p_doc_level => p_doc_level
,  p_doc_level_id_tbl => p_doc_level_id_tbl
,  x_distribution_id_tbl => l_dist_id_tbl
);

l_progress := '020';


-- If this is not a Check action, lock the documents

IF (p_check_only_flag = g_parameter_NO) THEN

   l_progress := '030';

   PO_LOCKS.lock_headers(
      p_doc_type => p_doc_type
   ,  p_doc_level => p_doc_level
   ,  p_doc_level_id_tbl => p_doc_level_id_tbl
   );

   l_progress := '040';

   PO_LOCKS.lock_distributions(
      p_doc_type => p_doc_type
   ,  p_doc_level => g_doc_level_DISTRIBUTION
   ,  p_doc_level_id_tbl => l_dist_id_tbl
   );

   l_progress := '050';

ELSE
   l_progress := '060';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'check only');
   END IF;
END IF;

l_progress := '070';

-- Get the document data into the encumbrance table.
-- Make a copy for each value in the adjustment status table.
-- Use the scratchpad to do this in bulk.

----------------------------------------------------------------
-- PO_SESSION_GT column mapping
--
-- num1     distribution id
----------------------------------------------------------------

l_dist_id_key := PO_CORE_S.get_session_gt_nextval();

l_progress := '080';

FORALL i IN 1 .. l_dist_id_tbl.COUNT
INSERT INTO PO_SESSION_GT TEMP ( key, num1 )
VALUES ( l_dist_id_key, l_dist_id_tbl(i) )
;

l_progress := '090';

-- Pull the data from the main document tables to the encumbrance table.

IF (p_doc_type = g_doc_type_REQUISITION) THEN

   l_progress := '200';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'requisition');
   END IF;

   FORALL i IN 1 .. p_adjustment_status_tbl.COUNT
   INSERT INTO PO_ENCUMBRANCE_GT
   (  adjustment_status
   ,  distribution_type
   ,  header_id
   ,  line_id
   ,  line_location_id
   ,  distribution_id
   ,  segment1
   ,  line_num
   ,  distribution_num
   ,  reference_num
   ,  item_description
   ,  budget_account_id
   ,  gl_encumbered_date
   ,  value_basis   --<Complex Work R12>
   ,  payment_type  --<Complex Work R12>
   ,  encumbered_amount
   ,  amount_ordered
   ,  quantity_ordered
   ,  quantity_delivered
   ,  quantity_on_line
   ,  unit_meas_lookup_code
   ,  item_id
   ,  price
   ,  nonrecoverable_tax
   ,  prevent_encumbrance_flag
   ,  modified_by_agent_flag    --bug 3537764
   ,  transferred_to_oe_flag
   ,  source_type_code
   ,  encumbered_flag
   ,  cancel_flag
   ,  closed_code
   ,  project_id
   ,  task_id
   ,  award_num
   ,  expenditure_type
   ,  expenditure_organization_id
   ,  expenditure_item_date
   ,  vendor_id
   )
   SELECT
      p_adjustment_status_tbl(i)
   ,  g_dist_type_REQUISITION
   ,  PRH.requisition_header_id
   ,  PRL.requisition_line_id
   ,  PRL.line_location_id
   ,  PRD.distribution_id
   ,  PRH.segment1
   ,  PRL.line_num
   ,  PRD.distribution_num
   ,  PRL.reference_num
   ,  PRL.item_description
   ,  PRD.budget_account_id
   ,  PRD.gl_encumbered_date
   ,  PRL.order_type_lookup_code --<Complex Work R12>
   ,  NULL                       --<Complex Work R12>
   ,  PRD.encumbered_amount
   ,  PRD.req_line_amount
   ,  PRD.req_line_quantity
   ,  PRL.quantity_delivered
   ,  PRL.quantity
   ,  PRL.unit_meas_lookup_code
   ,  PRL.item_id
   ,  PRL.unit_price
   ,  PRD.nonrecoverable_tax
   ,  PRD.prevent_encumbrance_flag
   ,  PRL.modified_by_agent_flag   --bug 3537764
   ,  PRH.transferred_to_oe_flag
   ,  PRL.source_type_code
   ,  PRD.encumbered_flag
   ,  PRL.cancel_flag
   ,  PRL.closed_code
   ,  PRD.project_id
   ,  PRD.task_id
   ,  PRD.award_id-- Bug #4675692
   ,  PRD.expenditure_type
   ,  PRD.expenditure_organization_id
   ,  PRD.expenditure_item_date
   ,  PRL.vendor_id
   FROM
      PO_REQ_DISTRIBUTIONS_ALL PRD
   ,  PO_REQUISITION_LINES_ALL PRL
   ,  PO_REQUISITION_HEADERS_ALL PRH
   ,  PO_SESSION_GT DIST_IDS
   WHERE PRH.requisition_header_id = PRL.requisition_header_id --JOIN
   AND PRL.requisition_line_id = PRD.requisition_line_id    --JOIN
   AND PRD.distribution_id = DIST_IDS.num1   --JOIN
   AND DIST_IDS.key = l_dist_id_key
   ;

   l_progress := '210';

ELSE -- doc is not a req, so it lives in the PO (and Release) tables.

   l_progress := '250';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not requisition');
   END IF;

   FORALL i IN 1 .. p_adjustment_status_tbl.COUNT
   INSERT INTO PO_ENCUMBRANCE_GT
   (  adjustment_status
   ,  distribution_type
   ,  header_id
   ,  po_release_id
   ,  line_id
   ,  line_location_id
   ,  distribution_id
   ,  from_header_id
   ,  source_distribution_id
   ,  req_distribution_id
   ,  segment1
   ,  line_num
   ,  shipment_num
   ,  distribution_num
   ,  item_description
   ,  comments
   ,  budget_account_id
   ,  gl_encumbered_date
   ,  value_basis   --<Complex Work R12>
   ,  payment_type  --<Complex Work R12>
   ,  accrue_on_receipt_flag
   ,  amount_to_encumber
   ,  unencumbered_amount
   ,  encumbered_amount
   ,  amount_ordered
   ,  amount_delivered
   ,  amount_billed
   ,  amount_cancelled
   ,  unencumbered_quantity
   ,  quantity_ordered
   ,  quantity_delivered
   ,  quantity_billed
   ,  quantity_cancelled
   ,  unit_meas_lookup_code
   ,  item_id
   ,  price
   ,  nonrecoverable_tax
   ,  currency_code
   ,  rate
   ,  prevent_encumbrance_flag
   ,  encumbrance_required_flag
   ,  encumbered_flag
   ,  cancel_flag
   ,  closed_code
   ,  approved_flag
   ,  project_id
   ,  task_id
   ,  award_num
   ,  expenditure_type
   ,  expenditure_organization_id
   ,  expenditure_item_date
   ,  vendor_id
   ,  amount_changed_flag
-- <Bug 13503748: Edit without unreserve ER.>
-- populating amount_changed_flag from po_distributions_all table.
   )
   SELECT
      p_adjustment_status_tbl(i)
   ,  POD.distribution_type
   ,  POD.po_header_id
   ,  POD.po_release_id
   ,  POD.po_line_id
   ,  POD.line_location_id
   ,  POD.po_distribution_id
   ,  POL.from_header_id
   ,  POD.source_distribution_id
   ,  POD.req_distribution_id
   ,  POH.segment1
   ,  POL.line_num
   ,  POLL.shipment_num
   ,  POD.distribution_num
   ,  POL.item_description
   ,  POH.comments
   ,  POD.budget_account_id
   ,  POD.gl_encumbered_date
   ,  POLL.value_basis   --<Complex Work R12>
   ,  POLL.payment_type  --<Complex Work R12>
   ,  POLL.accrue_on_receipt_flag
   ,  POD.amount_to_encumber
   ,  POD.unencumbered_amount
   ,  POD.encumbered_amount
   ,  POD.amount_ordered
   ,  POD.amount_delivered
   ,  POD.amount_billed
   ,  POD.amount_cancelled
   ,  POD.unencumbered_quantity
   ,  POD.quantity_ordered
   ,  POD.quantity_delivered
   ,  POD.quantity_billed
   ,  POD.quantity_cancelled
   ,  POLL.unit_meas_lookup_code --<Complex Work R12>: use line loc value
   ,  POL.item_id
   ,  POLL.price_override
   ,  POD.nonrecoverable_tax
   ,  POH.currency_code
   ,  POD.rate
   ,  POD.prevent_encumbrance_flag
   ,  POH.encumbrance_required_flag
   ,  POD.encumbered_flag
   ,  DECODE(  POD.distribution_type
            ,  g_dist_type_AGREEMENT, POH.cancel_flag
            ,  POLL.cancel_flag
            )
   ,  DECODE(  POD.distribution_type
            ,  g_dist_type_AGREEMENT, POH.closed_code
            ,  POLL.closed_code
            )
   ,  POLL.approved_flag
   ,  POD.project_id
   ,  POD.task_id
   ,  POD.award_id  -- Bug #4675692
   ,  POD.expenditure_type
   ,  POD.expenditure_organization_id
   ,  POD.expenditure_item_date
   ,  POH.vendor_id
   ,  POD.amount_changed_flag   -- <13503748>
   FROM
      PO_DISTRIBUTIONS_ALL POD
   ,  PO_LINE_LOCATIONS_ALL POLL
   ,  PO_LINES_ALL POL
   ,  PO_HEADERS_ALL POH
   ,  PO_SESSION_GT DIST_IDS
   WHERE POH.po_header_id = POD.po_header_id       --JOIN
   AND POL.po_line_id(+) = POD.po_line_id          --JOIN
      -- the distributions of PAs don't have associated lines
   AND POLL.line_location_id(+) = POD.line_location_id   --JOIN
      -- the distributions of PAs don't have associated shipments
   AND POD.po_distribution_id = DIST_IDS.num1   --JOIN
   AND DIST_IDS.key = l_dist_id_key
   ;

   l_progress := '260';

END IF; -- p_doc_type

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO populate_encumbrance_gt_PVT;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END populate_encumbrance_gt;




-------------------------------------------------------------------------------
--Start of Comments
--Name: populate_enc_gt_action_ids
--Pre-reqs:
--  None.
--Modifies:
--  PO_ENCUMBRANCE_GT
--Locks:
--  None.
--Function:
--  Prepares a call to a do_<> action that will operate on multiple ids
--  for the given doc type/level.
--  The ids are placed in PO_ENCUMBRANCE_GT, where the encumbrance actions
--  will find them.  This is a workaround to the inability of Forms to
--  deal with database object tables (otherwise, the IDs could be passed
--  as a table parameter to do_<>).
--  Any pre-existing data in PO_ENCUMBRANCE_GT will be deleted.
--Parameters:
--IN:
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
--  This parameter is not checked for requisitions (okay to use NULL).
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  IDs corresponding to the doc type/level on which the encumbrance
--  action will be taken.
--OUT:
--x_return_status
--  VARCHAR2(1)
--  Apps standard parameter
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE populate_enc_gt_action_ids(
   x_return_status                  OUT NOCOPY     VARCHAR2
,  p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
)
IS

l_api_name     CONSTANT VARCHAR2(30) := 'POPULATE_ENC_GT_ACTION_IDS';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress  VARCHAR2(3) := '000';

l_distribution_type  PO_DISTRIBUTIONS_ALL.distribution_type%TYPE;

BEGIN

-- Standard Start of API savepoint
SAVEPOINT POPULATE_ENC_GT_ACTION_IDS_PVT;

l_progress := '010';

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_subtype', p_doc_subtype);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl', p_doc_level_id_tbl);
END IF;

l_progress := '020';

-- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '100';

-- Clear the existing data from the encumbrance table.

PO_ENCUMBRANCE_PREPROCESSING.delete_encumbrance_gt();

l_progress := '200';

-- Get the distribution_type based on the doc_type, doc_subtype.

PO_ENCUMBRANCE_PREPROCESSING.derive_dist_from_doc_types(
   p_doc_type           => p_doc_type
,  p_doc_subtype        => p_doc_subtype
,  x_distribution_type  => l_distribution_type
);

l_progress := '210';

-- Populate the ids.
-- Set the prevent_encumbrance_flag for safety.
-- If do_adjust is called after this API is used,
-- hopefully the prevent_encumbrance_flag being set
-- here will stop any data corruption from happening.

FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
INSERT INTO PO_ENCUMBRANCE_GT
(  distribution_type
,  doc_level
,  doc_level_id
,  prevent_encumbrance_flag
)
VALUES
(  l_distribution_type
,  p_doc_level
,  p_doc_level_id_tbl(i)
,  'Y'
)
;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   BEGIN
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS Start');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO POPULATE_ENC_GT_ACTION_IDS_PVT;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
      END IF;
      PO_DEBUG.debug_unexp(l_log_head,l_progress,'OTHERS End');
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;

END populate_enc_gt_action_ids;




-------------------------------------------------------------------------------
--Start of Comments
--Name: handle_exception
--Pre-reqs:
--  None.
--Modifies:
--  API message list
--Locks:
--  None.
--Function:
--  Performs necessary manipulation of private encumbrance API
--  return parameters, and adds messages to the API list.
--Parameters:
--IN:
--p_api_name
--  procedure name
--p_progress
--  The location in the procedure at which the exception occurred.
--OUT:
--x_return_status
--  VARCHAR2(1)
--  Will be set to FND_API.g_ret_sts_unexp_error.
--x_po_return_code
--  VARCHAR2(10)
--  Will be set to g_return_FATAL.
--Notes:
--  The need for error handling that is more robust than
--  the Apps API standards require is exemplified by bug 3454804.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE handle_exception(
   p_api_name                       IN             VARCHAR2
,  p_progress                       IN             VARCHAR2
,  x_return_status                  OUT NOCOPY     VARCHAR2
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
)
IS

l_api_name     CONSTANT VARCHAR2(30) := 'HANDLE_EXCEPTION';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_api_name;
l_progress  VARCHAR2(3) := '000';

BEGIN

l_progress := '010';

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_name',p_api_name);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_progress',p_progress);
END IF;


-- 1. Set the API return statuses to indicate a failure.

x_return_status := FND_API.g_ret_sts_unexp_error;
x_po_return_code := g_return_FATAL;

l_progress := '100';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
END IF;


-- 2. Log the SQL error and add it to the API msg list.

-- Put the SQL error on the message dictionary stack,
-- and log a debug message to FND_LOG_MESSAGES.

PO_MESSAGE_S.sql_error(g_pkg_name,p_api_name,p_progress,SQLCODE,SQLERRM);

l_progress := '150';

-- Take the SQL error message from the message dictionary stack
-- and put it in the API message list.

FND_MSG_PUB.add();

l_progress := '200';


-- 3. Add the encumbrance failure to the API msg list.

-- Push the encumbrance failure message onto the message dictionary stack.

FND_MESSAGE.set_name('PO', 'PO_ENC_API_FAILURE');

l_progress := '250';

-- Pop the message from the message dictionary stack
-- and add it to the API message list.

FND_MSG_PUB.add();

l_progress := '300';


-- 4. Push the encumbrance failure message back onto the
--    message dictionary stack.
-- Bug 3516763: No longer put a message back on the message
-- dictionary stack.  Callers should get message from api msg. list.


l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_return_code',x_po_return_code);
   END IF;

END handle_exception;


-------------------------------------------------------------------------------
--Start of Comments
--Name: POPULATE_BC_REPORT_EVENTS
--Pre-reqs:
--  None.
--Modifies:
--  the PSA_BC_REPORT_EVENTS_GT global temp table
--Locks:
--  None.
--Function:
-- Populates a Global Temp table with the events that are used by the SLA
-- Budgetary Control Results page.
--Parameters:
--IN:
-- p_online_report_id  : specifies the unique report id generated for the current
--                       enc transaction.
--IN OUT:
--  None.
--OUT:
-- x_return_status     :
-- x_events_populated  :
--Notes:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE POPULATE_BC_REPORT_EVENTS
(
  x_return_status            OUT NOCOPY VARCHAR2,
  p_online_report_id         IN         NUMBER,  --<bug#5055417>
  x_events_populated         OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT varchar2(30) := 'POPULATE_BC_REPORT_EVENTS';
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM PSA_BC_REPORT_EVENTS_GT;
  --<bug#5055417 START>
  --Going forward we would populate the events and distribution ids
  --directly from po_bc_distributions based on online_report_id
  --We stamp all distributions in the current transaction with online
  --report_id and then use online_report_id to identify the distributions
  --while reporting.
  INSERT INTO PSA_BC_REPORT_EVENTS_GT
  (
    SOURCE_DISTRIBUTION_ID_NUM_1,
    EVENT_ID
  )
  SELECT PBD.distribution_id,
         PBD.ae_event_id
  FROM   PO_BC_DISTRIBUTIONS PBD
  WHERE  PBD.ONLINE_REPORT_ID=  p_online_report_id;
  --<bug#5055417 END>
  IF (SQL%ROWCOUNT > 0) THEN
    x_events_populated := 'Y';
  ELSE
    x_events_populated := 'N';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_api_name);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END POPULATE_BC_REPORT_EVENTS;

-------------------------------------------------------------------------------
--Start of Comments
--Name: POPULATE_AND_CREATE_BC_REPORT
--Pre-reqs:
--  None.
--Modifies:
--  the PSA_BC_REPORT_EVENTS_GT global temp table
--Locks:
--  None.
--Function:
-- Populates a Global Temp table with Budgetary Control events and creates
-- the Budgetary Control transaction report. This is used by the SLA Budgetary
-- Control Results page.
--Parameters:
--IN:
-- p_online_report_id  : specifies the unique report id generated for the current
--                       enc transaction.
-- p_ledger_id         : the ledger id for the document's operating unit
-- p_sequence_id       : the id to use for the report (from PSA_BC_XML_REPORT_S)
--IN OUT:
--  None.
--OUT:
-- x_return_status     : overall status of the procedure - i.e.
--   FND_API.G_RET_STS_SUCCESS or FND_API.G_RET_STS_UNEXP_ERROR
-- x_report_created    : 'Y'/'N' to indicate whether the report was created
--   successfully
--Notes:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE POPULATE_AND_CREATE_BC_REPORT
(
  x_return_status         OUT NOCOPY VARCHAR2,
  p_online_report_id      IN  NUMBER,  --<bug#5055417>
  p_ledger_id             IN  NUMBER,
  p_sequence_id           IN  NUMBER,
  x_report_created        OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT  VARCHAR2(30) := 'POPULATE_AND_CREATE_BC_REPORT';
  l_events_populated   VARCHAR2(1);
  l_bc_xml_count       NUMBER;
  l_errbuf             VARCHAR2(1000);
  l_retcode            NUMBER := 0;
  l_application_id     NUMBER := 201; -- PO
  l_return_status      VARCHAR2(1);
  l_progress           VARCHAR2(3) := '000';
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_report_created := 'N';
--<bug#5010001 START>
    PO_DOCUMENT_FUNDS_PVT.g_ONLINE_REPORT_ID:=p_online_report_id;
--<bug#5010001 END>

  populate_bc_report_events (
    x_return_status    => l_return_status,
    p_online_report_id => p_online_report_id,
    x_events_populated => l_events_populated
  );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --<bug#5055417 START>
  --If events haven't been populated we needto look into po_online_report_text
  -- to figure out if any of the rows in it are marked as show in psa.
  --This would indicate that there are rows in the report and we
  --would have to launch the OA page from the UI.
  IF(l_events_populated ='N')
  THEN
      BEGIN
        select 'Y'
        into l_events_populated
        from dual
        where exists(
                      select 1
                      from po_online_report_text
                      where online_report_id=PO_DOCUMENT_FUNDS_PVT.g_ONLINE_REPORT_ID
                      and   show_in_psa_flag='Y'
                    );

      EXCEPTION
      WHEN OTHERS THEN
        l_events_populated :='N';
      END;
  END IF;
  --<bug#5055417 END>
  IF (l_events_populated = 'Y') THEN

    l_progress := '010';

    PSA_BC_XML_REPORT_PUB.create_bc_transaction_report (
      l_errbuf,
      l_retcode,
      p_ledger_id,
      l_application_id,
      'E', -- event_flag
      p_sequence_id
    );

    l_progress := '020';

    SELECT count(*)
    INTO   l_bc_xml_count
    FROM   PSA_BC_XML_CLOB
    WHERE  application_id = l_application_id
    AND  sequence_id    = p_sequence_id;

    l_progress := '030';

    IF (l_bc_xml_count > 0) THEN
      x_report_created := 'Y';
    END IF;

  END IF; -- l_events_populated;
--<bug#5010001 START>
    PO_DOCUMENT_FUNDS_PVT.g_ONLINE_REPORT_ID:=null;
--<bug#5010001 END>

EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_api_name,
                                  p_progress => l_progress );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END POPULATE_AND_CREATE_BC_REPORT;
--<SLA R12 End>

--<bug#5085428 START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: is_req_enc_flipped
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
-- Returns true or false depending on wether a requisition distribution that is
-- associated with a PO ever had a prevent_encumbrance_flag set to 'Y'.
-- The prevent encumbrance flag would have been 'Y' if it was linked to a backing
-- document that was encumbered.This would have been flipped to 'N' once it was
-- linked to the instead of a Blanket Release.
--Parameters:
--IN:
-- p_req_dist_id  : Is the requisition distribution associated with the PO dist.
-- p_event_id     : The unique event identifier for the current transaction.
--IN OUT:
--  None.
--OUT:
--  None.
--Notes:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

FUNCTION is_req_enc_flipped(p_req_dist_id IN NUMBER, p_event_id IN NUMBER)
  RETURN VARCHAR2 IS
  l_found    VARCHAR2(1);
  d_progress NUMBER;
  l_module_name CONSTANT VARCHAR2(100) := 'is_req_enc_flipped';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,
                                                                     l_module_name);
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_dist_id', p_req_dist_id);
    PO_LOG.proc_begin(d_module_base, 'p_event_id', p_event_id);
  END IF;

  d_progress := 0;

  BEGIN
    select nvl(pod.encumbered_flag, 'N')
      into l_found
      from po_req_distributions_all prd,
           po_requisition_lines_all prl,
           po_distributions_all     pod
     where prd.distribution_id = p_req_dist_id
       and prl.requisition_line_id = prd.requisition_line_id
       and prl.document_type_code = 'BLANKET'
       and pod.po_header_id = prl.blanket_po_header_id
       and pod.distribution_type=g_dist_type_AGREEMENT;--bug#5468417
  exception
    when others then
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
      END IF;
      l_found := 'N';
  end;
  d_progress := 1;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'l_found', l_found);
  END IF;
  return l_found;
END;
--<bug#5085428 END>


-- <<Bug18898767>> Start

-------------------------------------------------------------------------------
--Start of Comments
--Name: do_unreserve
--Pre-reqs:
--  None.
--Procedure:
-- Updates the amount change flag and
-- unreserves those distributions having change in
-- ccid or project information or deliver to location
--Parameters:
--IN:
-- p_draft_id
-- p_po_header_id
-- p_employee_id
--IN OUT:
--  None.
--OUT:
--  OnlineReportId
--  ReturnStatus
--  PoReturnCode
--Notes:
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_unreserve(
  p_draft_id IN NUMBER,
  p_po_header_id IN NUMBER,
  p_employee_id IN NUMBER,
  x_enc_report_id OUT NOCOPY NUMBER,
  l_return_status OUT NOCOPY VARCHAR2,
  l_po_return_code OUT NOCOPY VARCHAR2
) IS

l_module_name CONSTANT VARCHAR2(100) := 'do_unreserve';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,
                                                                     l_module_name);
d_position NUMBER;

d_api_version CONSTANT NUMBER := 1.0;
d_distirbution_id NUMBER;
x_return_status VARCHAR2(1);
l_distribution_id_tbl     po_tbl_number;
l_dist_unmodified_tbl     po_tbl_number;
l_amt_change_flag PO_TBL_VARCHAR1;
l_dist_no_draft_tbl	  po_tbl_number;

l_doctype		PO_DOCUMENT_TYPES.document_type_code%TYPE;
l_subtype		PO_DOCUMENT_TYPES.document_subtype%TYPE;
l_doc_level 		VARCHAR2(20);
l_doc_level_id		NUMBER;
l_use_override_funds 	VARCHAR2(1):= nvl(FND_PROFILE.VALUE('PO_REQAPPR_OVERRIDE_FUNDS'),'U');
l_override_date		DATE := SYSDATE;
l_use_gl_date 		VARCHAR2(1):= nvl(FND_PROFILE.VALUE('PO_GL_DATE'),'Y');
l_po_exists NUMBER;


BEGIN
  d_position := 0;
  l_return_status:= FND_API.G_RET_STS_SUCCESS ;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_draft_id', p_draft_id);
    PO_LOG.proc_begin(d_module_base, 'p_po_header_id', p_po_header_id);
  END IF;

  IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module_base, d_position, 'l_po_exists' || l_po_exists);
  END IF;

    d_position := 10;

    SELECT pda.po_distribution_id
    BULK COLLECT INTO l_distribution_id_tbl
    FROM
    po_distributions_draft_all pda
    WHERE pda.po_header_id= p_po_header_id
    AND pda.draft_id= p_draft_id
    AND NOT EXISTS (
    SELECT 1 FROM  po_distributions_all pdd
    WHERE
    pdd.po_header_id=pda.po_header_id
    AND pdd.PO_DISTRIBUTION_ID = pda.PO_DISTRIBUTION_ID
    AND pdd.encumbered_flag='Y'
    AND (pdd.CODE_COMBINATION_ID = pda.CODE_COMBINATION_ID
         AND nvl(pdd.PROJECT_ID,0) = nvl(pda.PROJECT_ID,0)
         AND nvl(pdd.TASK_ID,0) =	nvl(pda.TASK_ID,0)
         AND nvl(pdd.EXPENDITURE_TYPE,'-999') = nvl(pda.EXPENDITURE_TYPE,'-999')
         AND nvl(pdd.DELIVER_TO_PERSON_ID,0) = nvl(pda.DELIVER_TO_PERSON_ID,0)
         AND nvl(pdd.DELIVER_TO_LOCATION_ID,0) = nvl(pda.DELIVER_TO_LOCATION_ID,0)
        )
    );

   IF l_distribution_id_tbl.count > 0
   THEN
   SAVEPOINT do_unreserve;

   d_position := 20;

    FORALL i IN 1..l_distribution_id_tbl.count
    UPDATE po_distributions_all
    SET amount_changed_flag='R'
    WHERE PO_DISTRIBUTION_ID=l_distribution_id_tbl(i);

   --Update the amount changed flag of those
   --distributions which are not disturbed in UI

  -- Handling the case where data exists in
  -- draft table and does not exists in draft
  -- table separately

    SELECT pda.po_distribution_id,
    pdd.amount_changed_flag
    BULK COLLECT INTO l_dist_unmodified_tbl,
    l_amt_change_flag
    FROM
    po_distributions_draft_all pdd,
    po_distributions_all pda
    WHERE pdd.po_header_id= p_po_header_id
    AND pdd.draft_id= p_draft_id
    AND ( pdd.po_distribution_id=pda.po_distribution_id
    AND pda.amount_changed_flag is null ) ;


    FORALL i IN 1..l_dist_unmodified_tbl.count
    UPDATE po_distributions_all
    SET amount_changed_flag='Y'
    WHERE PO_DISTRIBUTION_ID=l_dist_unmodified_tbl(i)
    and po_header_id=p_po_header_id;

    SELECT pda.po_distribution_id
    BULK COLLECT INTO l_dist_no_draft_tbl
    FROM po_distributions_all pda WHERE
    pda.amount_changed_flag is null and
		NOT EXISTS (select 1
         FROM po_distributions_draft_all pdd where
         pdd.po_header_id= p_po_header_id
         AND pda.po_distribution_id=pdd.po_distribution_id
    );

   FORALL i IN 1..l_dist_no_draft_tbl.count
    UPDATE po_distributions_all
    SET amount_changed_flag='Y'
    WHERE PO_DISTRIBUTION_ID=l_dist_no_draft_tbl(i)
    and po_header_id=p_po_header_id;


    l_doc_level := 'HEADER';

    SELECT POH.type_lookup_code ,
           Decode(POH.type_lookup_code, 'STANDARD', 'PO', 'PA') doc_type
    INTO l_subtype,
         l_doctype
    FROM po_headers_all POH
    WHERE POH.po_header_id=p_po_header_id;

       d_position := 30;

   PO_DOCUMENT_FUNDS_PVT.do_unreserve(
  		x_return_status => l_return_status
	, 	p_doc_type => l_doctype
	, 	p_doc_subtype => l_subtype
	,	p_doc_level => l_doc_level
	,	p_doc_level_id => p_po_header_id
	, 	p_use_enc_gt_flag => 'N'
	, 	p_validate_document => 'Y'
	, 	p_override_funds => l_use_override_funds
	,	p_use_gl_date => l_use_gl_date
	,	p_override_date => sysdate
	, 	p_employee_id => p_employee_id
	, 	x_po_return_code => l_po_return_code
	,	x_online_report_id => x_enc_report_id
 	);

      d_position := 40;

   IF l_return_status = FND_API.G_RET_STS_SUCCESS
   THEN
      FORALL i IN 1..l_distribution_id_tbl.count
        UPDATE po_distributions_draft_all
        SET encumbered_amount=0,
            encumbered_flag='N'
        WHERE PO_DISTRIBUTION_ID=l_distribution_id_tbl(i);

     FORALL i IN 1..l_dist_unmodified_tbl.count
       UPDATE po_distributions_draft_all
       SET amount_changed_flag = l_amt_change_flag(i)
       WHERE PO_DISTRIBUTION_ID=l_dist_unmodified_tbl(i);

     FORALL i IN 1..l_dist_no_draft_tbl.count
       UPDATE po_distributions_all
       SET amount_changed_flag = null
       WHERE PO_DISTRIBUTION_ID=l_dist_no_draft_tbl(i);

   END IF;

END IF;


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'l_return_status', l_return_status);
  END IF;

EXCEPTION

  WHEN OTHERS THEN

   ROLLBACK TO do_unreserve;

    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => g_pkg_name,
      p_procedure_name => d_module_base || '.' || d_position
    );

    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_unreserve;

END PO_DOCUMENT_FUNDS_PVT;

/
