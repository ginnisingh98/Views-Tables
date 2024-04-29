--------------------------------------------------------
--  DDL for Package Body PO_INTG_DOCUMENT_FUNDS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_INTG_DOCUMENT_FUNDS_GRP" AS
/* $Header: POXGFCKB.pls 120.3.12010000.4 2014/02/04 11:59:26 gjyothi ship $*/

G_PKG_NAME CONSTANT varchar2(30) := 'PO_INTG_DOCUMENT_FUNDS_GRP';

c_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.' ;

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


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
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be commited?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
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
-- Set depending upon which values of p_encumbered_amt AP calls the API with.
-- g_parameter_NO - the original amounts before tax applied
-- g_parameter_YES - the tax on the original amounts only
-- Default NULL, which will be assumed to be g_parameter_NO
-- Check Priavate API comments for more usage notes.
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
   p_api_version       IN         NUMBER,
   p_commit            IN         VARCHAR2 default FND_API.G_FALSE,
   p_init_msg_list     IN         VARCHAR2 default FND_API.G_FALSE,
   p_validation_level  IN         NUMBER default FND_API.G_VALID_LEVEL_FULL,
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
   p_tax_line_flag     IN         VARCHAR2 default NULL,  -- Bug 3480949
   x_packet_id         OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2
) is

l_api_name              CONSTANT varchar2(30) := 'REINSTATE_PO_ENCUMBRANCE';
l_api_version           CONSTANT NUMBER := 1.0;
l_progress              VARCHAR2(3);

BEGIN

SAVEPOINT REINSTATE_PO_ENCUMBRANCE_SP;

l_progress := '000';

IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
      || l_progress,'Invoked');
   END IF;
END IF;


PO_DOCUMENT_FUNDS_GRP.reinstate_po_encumbrance(
   p_api_version       => p_api_version
,  p_commit            => p_commit
,  p_init_msg_list     => p_init_msg_list
,  p_validation_level  => p_validation_level
,  p_distribution_id   => p_distribution_id
,  p_invoice_id        => p_invoice_id
,  p_encumbrance_amt   => p_encumbrance_amt
,  p_qty_cancelled     => p_qty_cancelled
,  p_budget_account_id => p_budget_account_id
,  p_gl_date           => p_gl_date
,  p_period_name       => p_period_name
,  p_period_year       => p_period_year
,  p_period_num        => p_period_num
,  p_quarter_num       => p_quarter_num
,  p_tax_line_flag     => p_tax_line_flag   -- Bug 3480949
,  x_packet_id         => x_packet_id
,  x_return_status     => x_return_status
);

l_progress := '999';
IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
      || l_progress, 'End');
   END IF;
END IF;

EXCEPTION

WHEN OTHERS THEN
   ROLLBACK TO REINSTATE_PO_ENCUMBRANCE_SP;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
   END IF;

   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, c_log_head ||
            l_api_name || '.others_exception', 'EXCEPTION: '
            || 'Location is '|| l_progress || ' SQL CODE is '||sqlcode);
      END IF;

   END IF;

END reinstate_po_encumbrance;



-------------------------------------------------------------------------------
--Start of Comments
--Name: get_active_encumbrance_amount
--Pre-reqs:
--  Organization context must be set
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Calculates the active encumbrance on a given Req/PO distribution.  The
--  active encumbrance is the encumbrance originally reserved minus any
--  encumbrance that has already been moved in actuals by CST or AP
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_doc_type
--  Document type.  Use the PO_INTG_DOCUMENT_FUNDS_GRP package variables:
--    g_doc_type_REQUISITION, (Note: INTERNAL Reqs are not supported)
--    g_doc_type_PA,
--    g_doc_type_PO,
--    g_doc_type_RELEASE (optional: behaves same as g_doc_type_PO)
-- NOTE: API does not current support Internal Requisitions
--p_distribution_id
--  Unique id of row from either po_req_distributions_all or
--  po_distributions_all table, depending on p_doc_type
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_active_enc_amount
--  The current active encumbrance on the distribution identified
--  by p_distribution_id
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_active_encumbrance_amount(
   p_api_version       IN  NUMBER
,  p_init_msg_list     IN  VARCHAR2 default FND_API.G_FALSE
,  p_validation_level  IN  NUMBER default FND_API.G_VALID_LEVEL_FULL
,  x_return_status     OUT NOCOPY VARCHAR2
,  p_doc_type          IN  VARCHAR2
,  p_distribution_id   IN  NUMBER
,  x_active_enc_amount OUT NOCOPY NUMBER
)
IS

l_api_name      CONSTANT varchar2(30) := 'GET_ACTIVE_ENCUMBRANCE_AMOUNT';
l_api_version   CONSTANT NUMBER := 1.0;
l_progress      VARCHAR2(3) := '000';

l_encumbered_amount        NUMBER;
l_document_subtype         PO_DOCUMENT_TYPES.document_subtype%TYPE;
l_accrue_on_receipt_flag   PO_DISTRIBUTIONS_ALL.accrue_on_receipt_flag%TYPE;
l_amount_moved_to_actual   NUMBER;
l_return_status      VARCHAR2(1); --Bug#5058165
l_msg_count          NUMBER;  --Bug#5058165
l_msg_data           VARCHAR2(2000);  --Bug#5058165

   -- Bug 15987200
l_amount_reversed     NUMBER;
BEGIN

IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
      || l_progress,'Invoked');
   END IF;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
      || l_progress,'p_api_version: ' || p_api_version);
   END IF;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
      || l_progress,'p_doc_type: ' || p_doc_type);
   END IF;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
      || l_progress,'p_distribution_id: ' || p_distribution_id);
   END IF;
END IF;

-- Standard call to check for call compatibility
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '010';

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;

l_progress := '020';

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '030';
IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
      || l_progress, 'Finished Initialization');
   END IF;
END IF;

-- The appropriate calculation for encumbered amount
-- depends on the type of document

IF p_doc_type = g_doc_type_REQUISITION THEN

   -- The API currently only supports Purchase Requisitions
   -- If Req line is an internal requsition, raise an exception
   l_progress := '040';
   IF g_fnd_debug = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
         || l_progress, 'doc is a Req');
      END IF;
   END IF;

   SELECT
      PRL.source_type_code
   ,  nvl(PRD.encumbered_amount, 0)
   INTO
      l_document_subtype
   ,  l_encumbered_amount
   FROM PO_REQUISITION_LINES_ALL PRL
   ,    PO_REQ_DISTRIBUTIONS_ALL PRD
   WHERE PRD.distribution_id = p_distribution_id
   AND   PRD.requisition_line_id = PRL.requisition_line_id
   ;

   l_progress := '050';

   IF l_document_subtype = 'VENDOR' THEN
      -- For Purchase Reqs, active enc = encumbered amt always

      l_progress := '060';
      IF g_fnd_debug = 'Y' THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name
           ||'.' || l_progress, 'Vendor Req enc amt: ' || l_encumbered_amount);
         END IF;
      END IF;

      x_active_enc_amount := l_encumbered_amount;
   ELSE
      -- source type = 'INVENTORY' (internal Req)
      -- this is not currently supported

      l_progress := '070';
      IF g_fnd_debug = 'Y' THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name
            ||'.'|| l_progress, 'Internal Reqs are not supported');
         END IF;
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

ELSIF p_doc_type = g_doc_type_PA THEN

   --If doc type is given as PA, assume it is encumbered,
   --else there would not be a p_distribution_id
   l_progress := '080';

   -- Bug 3446983: For encumbered PA, active enc = encumbered amt
   SELECT nvl(POD.encumbered_amount, 0)
   INTO x_active_enc_amount
   FROM PO_DISTRIBUTIONS_ALL POD
   WHERE POD.po_distribution_id = p_distribution_id
   ;

   l_progress := '090';
   IF g_fnd_debug = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
         || l_progress, 'PA enc amount: ' || x_active_enc_amount);
      END IF;
   END IF;

ELSIF p_doc_type IN (g_doc_type_PO, g_doc_type_RELEASE) THEN

   l_progress := '100';

   SELECT
      nvl(POD.encumbered_amount, 0)
   ,  nvl(POD.accrue_on_receipt_flag, 'N')
   ,  POLL.shipment_type
   -- Bug 15987200
   ,  Nvl (POD.amount_reversed,0)
   INTO
      l_encumbered_amount
   ,  l_accrue_on_receipt_flag
   ,  l_document_subtype
   -- Bug 15987200
   ,  l_amount_reversed
   FROM PO_DISTRIBUTIONS_ALL POD
   ,    PO_LINE_LOCATIONS_ALL POLL
   WHERE POD.po_distribution_id = p_distribution_id
   AND   POD.line_location_id = POLL.line_location_id
   ;

   l_progress := '110';
   IF g_fnd_debug = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
         || l_progress, 'doc shipment type: ' || l_document_subtype);
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
         || l_progress, 'accrue on receipt: ' || l_accrue_on_receipt_flag);
      END IF;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
         || l_progress, 'encumbered amount: ' || l_encumbered_amount);
      END IF;
   END IF;
   IF l_document_subtype = 'PLANNED' THEN
      -- If this is a PPO, then the active encumbrance will always just be
      -- the PO encumbrance (there is no reversal from Delivery/Invoicing)
      l_progress := '120';

      x_active_enc_amount := l_encumbered_amount;

   ELSE
      -- For all other POs/Rels, the amount moved to actuals
      -- by AP or CST must be subtracted out to get the
      -- active encumbrance amount
      l_progress := '130';

      IF (l_accrue_on_receipt_flag = 'Y') THEN
         -- Online Accruals: actual amount is determined by CST reversals
         l_progress := '140';

         -- Bug 3455267: CST API
         -- Use an API from CST to determine the amount of PO encumbrance
         -- relieved by delivery transactions.
         l_amount_moved_to_actual :=
            RCV_ACCRUALUTILITIES_GRP.Get_encumReversalAmt(
               p_po_distribution_id => p_distribution_id
            ,  p_start_txn_date => NULL
            ,  p_end_txn_date => NULL
            );  --bug 3450228: removed '* -1' added in bug 3330335

         l_progress := '150';
         IF g_fnd_debug = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'
               ||l_api_name ||'.' || l_progress,
               'CST reversed amt: ' || l_amount_moved_to_actual);
            END IF;
         END IF;

      ELSE
         -- Period End Accruals: actual amount is determined by AP reversals
         l_progress := '160';

         -- Bug 3068177: AP API
         -- Use an API from AP to determine the amount of PO encumbrance
         -- AP has relieved.  In the over-billed case, AP will not over-relieve
         -- the PO encumbrance.  So this API should never return an actual amount
         -- that is greater than the PO encumbered amount.

         -- bug5058165
         -- Changed the package name from AP_UTILITIES_PKG to PSA_AP_BC_GRP
           PSA_AP_BC_GRP.get_po_reversed_encumb_amount(
                p_api_version =>1.0,
                p_init_msg_list => FND_API.G_FALSE,
		x_return_status => l_return_status,
                x_msg_count=>l_msg_count,
                x_msg_data=>l_msg_data,
                p_po_distribution_id => p_distribution_id,
                p_start_gl_date => NULL,
                p_end_gl_date => NULL,
		p_calling_sequence => NULL,
                x_unencumbered_amount => l_amount_moved_to_actual);
         l_progress := '170';
         IF g_fnd_debug = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'
               ||l_api_name ||'.' || l_progress,
               'AP reversed amt: ' || l_amount_moved_to_actual);
            END IF;
         END IF;

      END IF;

      l_progress := '180';

      --bug 3519982: remove the greatest(0, <>) from this subtract
      --if active enc is negative, we do not want to supress that
      --Bug 15987200
      x_active_enc_amount := l_encumbered_amount -
                                nvl(l_amount_moved_to_actual, 0)-l_amount_reversed;

      l_progress := '190';
      IF g_fnd_debug = 'Y' THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'
            ||l_api_name ||'.' || l_progress,
            '***Active Encumbrance Amount: ' || x_active_enc_amount);
         END IF;
      END IF;

   END IF;  -- if doc was PPO or not

ELSE
   --Invalid parameter value

   l_progress := '200';
   IF g_fnd_debug = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'
         ||l_api_name ||'.' || l_progress,
         'Invalid value for doc type: ' || p_doc_type);
      END IF;
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IF; -- check on p_doc_type

EXCEPTION

WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
   END IF;

   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, c_log_head ||
            l_api_name || '.others_exception', 'EXCEPTION: '
            || 'Location is '|| l_progress || ' SQL CODE is '||sqlcode);
      END IF;

   END IF;

END get_active_encumbrance_amount;


FUNCTION get_active_encumbrance_func(
   p_doc_type         IN  VARCHAR2
,  p_distribution_id  IN  NUMBER
)
RETURN NUMBER IS
  l_return_status  VARCHAR2(1);
  l_active_enc_amt NUMBER;
BEGIN

   get_active_encumbrance_amount(
      p_api_version => 1.0
   ,  p_init_msg_list => FND_API.G_FALSE
   ,  p_validation_level => FND_API.G_VALID_LEVEL_FULL
   ,  x_return_status => l_return_status
   ,  p_doc_type => p_doc_type
   ,  p_distribution_id => p_distribution_id
   ,  x_active_enc_amount => l_active_enc_amt
   );

   RETURN l_active_enc_amt;

END get_active_encumbrance_func;

-- Bug 8767203
-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_enc_flip
--Pre-reqs:
-- None.
--Modifies:
--  None.
--Locks:
--  None.
--Function: It is called by AP API to check whether PO/Req encumbrance can be
--          enabled/disabled. While enabling Req/PO encumbrance checks whether
--          all the lines/Shipments for APPROVED req/PO are FINALLY CLOSED. While
--          disabling check whether encumberd_flag at distribution is 'Y'.
--Parameters:
--IN:
--p_req_enc
--  Req encumbrance flag passed by AP(passed as 'N' or 'Y').
--p_po_enc
--  PO encumbrance flag passed by AP(passed as 'N' or 'Y').
--p_org_id
--  org id of the operating unit
--OUT:
--x_do_not_allow_po_change:
--Returned as 'Y' to throw an error mesage while flipping PO encumbrance or 'N' otherwise.
--x_do_not_allow_req_change:
--Returned as 'Y' to throw an error mesage while flipping Req encumbrance or 'N' otherwise.
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if validation succeeds
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--End of Comments
PROCEDURE Validate_enc_flip (p_req_enc                 IN VARCHAR2,
                             p_po_enc                  IN VARCHAR2,
                             p_org_id                  IN NUMBER,
                             x_do_not_allow_req_change OUT NOCOPY VARCHAR2,
                             x_do_not_allow_po_change  OUT NOCOPY VARCHAR2,
                             x_return_status           OUT NOCOPY VARCHAR2)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'VALIDATE_ENC_FLIP';
  l_progress        VARCHAR2(3) := '000';
  l_current_req_enc VARCHAR2(1); -- current req encumbrance from fsp
  l_current_po_enc  VARCHAR2(1); -- current PO encumbrance from fsp
BEGIN
    x_do_not_allow_po_change := 'N';

    x_do_not_allow_req_change := 'N';

    SELECT Nvl(req_encumbrance_flag, 'N')
    INTO   l_current_req_enc
    FROM   financials_system_params_all
    WHERE  org_id = p_org_id;

    SELECT Nvl(purch_encumbrance_flag, 'N')
    INTO   l_current_po_enc
    FROM   financials_system_params_all
    WHERE  org_id = p_org_id;

    IF g_fnd_debug = 'Y' THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'
            ||l_api_name ||'.' || l_progress,
            'current req enc in fsp ' || l_current_req_enc);
         END IF;
      END IF;

    IF g_fnd_debug = 'Y' THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'
            ||l_api_name ||'.' || l_progress,
            'current PO enc in fsp ' || l_current_po_enc);
         END IF;
      END IF;

    l_progress := '010';

    /* When switching the Req encumbrance from 'N' to 'Y' need to make sure that
       all the Requisitions in Approved status are Finally Closed. While
       switching from 'Y' to 'N' need to check for the encumbered flag at
       req distribution */
    IF( p_req_enc = 'Y' ) THEN
      IF( Nvl(l_current_req_enc, 'N') = 'N' ) THEN
        SELECT Decode(Count(*), 0, 'N',
                                'Y')
        INTO   x_do_not_allow_req_change
        FROM   po_requisition_headers_all prh,
               po_requisition_lines_all prl
        WHERE  prl.requisition_header_id = prh.requisition_header_id
               AND prl.closed_code <> 'FINALLY CLOSED'
               AND prh.authorization_status = 'APPROVED'
               AND prl.org_id = p_org_id;
      END IF;
    ELSE
      IF( Nvl(l_current_req_enc, 'N') = 'Y' ) THEN
        SELECT Decode(Count(*), 0, 'N',
                                'Y')
        INTO   x_do_not_allow_req_change
        FROM   po_req_distributions_all
        WHERE  encumbered_flag = 'Y'
               AND org_id = p_org_id;
      END IF;
    END IF;

    IF g_fnd_debug = 'Y' THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'
            ||l_api_name ||'.' || l_progress,
            'Do not allow switching of req enc ' || x_do_not_allow_req_change);
         END IF;
      END IF;


    /* When switching the PO encumbrance from 'N' to 'Y' need to make sure that
       all the PO shipments closed code is Finally Closed. While
       switching from 'Y' to 'N' need to check for the encumbered flag at
       PO distribution */
    l_progress := '020';

    IF( p_po_enc = 'Y' ) THEN
      IF( Nvl(l_current_po_enc, 'N') = 'N' ) THEN
        SELECT Decode(Count(*), 0, 'N',
                                'Y')
        INTO   x_do_not_allow_po_change
        FROM   po_line_locations_all
        WHERE  closed_code <> 'FINALLY CLOSED'
               AND org_id = p_org_id;
      END IF;
    ELSE
      IF( Nvl(l_current_po_enc, 'N') = 'Y' ) THEN
        SELECT Decode(Count(*), 0, 'N',
                                'Y')
        INTO   x_do_not_allow_po_change
        FROM   po_distributions_all
        WHERE  encumbered_flag = 'Y'
               AND org_id = p_org_id;
      END IF;
    END IF;

     IF g_fnd_debug = 'Y' THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'
            ||l_api_name ||'.' || l_progress,
            'Do not allow switching of PO enc ' || x_do_not_allow_po_change);
         END IF;
      END IF;


    x_return_status := fnd_api.g_ret_sts_success;

    l_progress := '030';
EXCEPTION
  WHEN OTHERS THEN

x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
   END IF;

   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, c_log_head ||
            l_api_name || '.others_exception', 'EXCEPTION: '
            || 'Location is '|| l_progress || ' SQL CODE is '||sqlcode);
      END IF;

   END IF;


END validate_enc_flip;


END PO_INTG_DOCUMENT_FUNDS_GRP;

/
