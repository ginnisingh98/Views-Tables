--------------------------------------------------------
--  DDL for Package Body PO_INVOICE_HOLD_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_INVOICE_HOLD_CHECK" AS
/* $Header: PO_INVOICE_HOLD_CHECK.plb 120.0.12010000.6 2009/10/13 10:41:44 svagrawa noship $ */
--Debug info

  g_pkg_name  CONSTANT VARCHAR2(30) := 'PO_INVOICE_HOLD_CHECK';
  g_log_head  CONSTANT VARCHAR2(50) := 'po.plsql.'||g_pkg_name||'.';
  g_debug_stmt  BOOLEAN := po_debug.is_debug_stmt_on;
  g_debug_unexp  BOOLEAN := po_debug.is_debug_unexp_on;

  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: PAY_WHEN_PAID
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Procedure:
  --  This procedure returns information about 'pay when paid' status for a standard PO.
  --  In case the type of the PO is other than 'Standard', there is no need to
  --  apply any hold. This proc simply returns a pay_when_paid -> 'N'  to the caller.
  --Parameters:
  --IN:
  --p_api_version
  --  Version number of API that caller expects. It
  --  should match the l_api_version defined in the
  --  procedure (expected value : 1.0)
  --p_po_header_id
  --  The header id of the Purchase Order.
  --p_invoice_id
  --  Invoice id of the Invoice that is being validated.

  -- OUT PARAMETERS
  -- x_return_status
  --   FND_API.G_RET_STS_SUCCESS if API succeeds
  --   FND_API.G_RET_STS_ERROR if API fails
  --   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
  -- x_msg_count
  -- x_msg_data
  --
  -- IN OUT PARAMETERS
  -- x_pay_when_paid
  -- Return 'Y' when the pay when paid on the PO is 'Yes', else return 'N'.
  --End of Comments

  PROCEDURE PAY_WHEN_PAID
       (P_API_VERSION    IN NUMBER,
        P_PO_HEADER_ID   IN NUMBER,
        P_INVOICE_ID     IN NUMBER,
        X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
        X_MSG_COUNT      OUT NOCOPY NUMBER,
        X_MSG_DATA       OUT NOCOPY VARCHAR2,
        X_PAY_WHEN_PAID  IN OUT NOCOPY VARCHAR2)
  IS
    l_api_version  NUMBER := 1.0;
    l_api_name     VARCHAR2(60) := 'PAY_WHEN_PAID';
    l_log_head     CONSTANT VARCHAR2(100) := g_log_head
                                             ||l_api_name;
    d_progress     VARCHAR2(3) := '000';
    l_type_lookup_code PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
    d_module     VARCHAR2(70) := 'po.plsql.PO_INVOICE_HOLD_CHECK.pay_when_paid';

  BEGIN

  -- Check for the API version
    IF (NOT fnd_api.compatible_api_call(l_api_version,p_api_version,l_api_name,g_pkg_name)) THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
    END IF;

    d_progress := '001';

     IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'API Compatible call success');
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    d_progress := '002';

    SELECT NVL(pay_when_paid, 'N'),
           type_lookup_code
     INTO  x_pay_when_paid,
           l_type_lookup_code
    FROM   po_headers_all
    WHERE  po_header_id = p_po_header_id;

     IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'pay when paid query executed');
     END IF;

    IF l_type_lookup_code <> 'STANDARD'
    THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_pay_when_paid := 'N';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);
  END pay_when_paid;


  --Start of Comments
  --Name: DELIVERABLE_OVERDUE_CHECK
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Procedure:
  --  This procedure returns a 'Y' or 'N' based on the contract deliverables' status.
  --  In case the type of the PO in picture is other than 'Standard', there is no need to
  --  apply any hold. This proc simply returns a hold_required -> 'N'  to the caller.
  -- In this case, we do not call OKC api which provides paymenthold information.
  -- This procedure is called by AP to apply Deliverable holds on the invoices.

  --Parameters:
  --IN:
  --p_api_version
  --  Version number of API that caller expects. It
  --  should match the l_api_version defined in the
  --  procedure (expected value : 1.0)
  --p_po_header_id
  --  Header id of the Purchase Order.
  --p_invoice_id
  --  Invoice id of the Invoice that is being validated.
  --
  -- OUT PARAMETERS
  -- x_return_status
  --   FND_API.G_RET_STS_SUCCESS if API succeeds
  --   FND_API.G_RET_STS_ERROR if API fails
  --   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
  -- x_msg_count
  -- x_msg_data
  --
  -- IN OUT PARAMETERS
  -- X_HOLD_REQUIRED
  -- Return 'Y' when any of the deliverables are overdue, else return 'N'.

  PROCEDURE DELIVERABLE_OVERDUE_CHECK
       (P_API_VERSION    IN NUMBER,
        P_PO_HEADER_ID   IN NUMBER,
        P_INVOICE_ID     IN NUMBER,
        X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
        X_MSG_COUNT      OUT NOCOPY NUMBER,
        X_MSG_DATA       OUT NOCOPY VARCHAR2,
        X_HOLD_REQUIRED  IN OUT NOCOPY VARCHAR2)
  IS
    l_api_version        NUMBER := 1.0;
    l_api_name           VARCHAR2(60) := 'DELIVERABLE_OVERDUE_CHECK';
    l_log_head           CONSTANT VARCHAR2(100) := g_log_head
                                                   ||l_api_name;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_return_status_okc  VARCHAR2(1);
    d_progress           VARCHAR2(3) := '000';
    l_pay_when_paid      VARCHAR2(1);
    l_rev_num            NUMBER;
    l_type_lookup_code   PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
    l_deliverable_hold_flag VARCHAR2(10);
    d_module     VARCHAR2(70) := 'po.plsql.PO_INVOICE_HOLD_CHECK.deliverable_overdue_check';
  BEGIN

  -- Check for the API version
    IF (NOT fnd_api.compatible_api_call(l_api_version,p_api_version,l_api_name,g_pkg_name)) THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;
    END IF;

    d_progress := '001';
     IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'API Compatible call success');
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

 d_progress := '002';

/* Bug 8204164 - The below query was initially checking for the document type = 'STANDARD'.
   Changed that to query all type_lookup_codes as this proc is called \
   from AP for all types of POs.
   Added fnd debug messages as well. */

/*    SELECT NVL(pay_when_paid, 'N'),
           revision_num,
           type_lookup_code
    INTO   l_pay_when_paid,
           l_rev_num,
           l_type_lookup_code
    FROM   po_headers_all
    WHERE  po_header_id = p_po_header_id; */

/* E and C Phase 2 changes -
   Deliverable Hold control does not depend on the pay when paid attribute.
   This depends on the document style attribute deliverable_hold_flag.
   One of the attributes mentioned above should have a value 'Y', if this is satisfied,
   we call the OKC API to find out the overdue status of the deliverables.
   Commented the above sql and added the complete sql below. */

    SELECT NVL(poh.pay_when_paid, 'N'),
           poh.revision_num,
           poh.type_lookup_code,
           Nvl(ps.deliverable_hold_flag, 'N')
    INTO   l_pay_when_paid,
           l_rev_num,
           l_type_lookup_code,
           l_deliverable_hold_flag
    FROM   po_doc_style_headers ps, po_headers_all poh
    WHERE poh.po_header_id = p_po_header_id
    AND poh.style_id = ps.style_id;


    IF l_type_lookup_code <> 'STANDARD'
    THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    X_HOLD_REQUIRED := 'N';
    END IF;

    IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Pay when paid  and Deliverable hold flag query executed');
    END IF;

-- E and C Phase 2 changes -
--  Commented the earlier IF and added the deliverable hold flag condition to the same below */

   IF (l_pay_when_paid = 'Y' OR l_deliverable_hold_flag = 'Y')  THEN

/*    IF l_pay_when_paid = 'Y' THEN */
    --Call OKC API to get the hold related information.

       d_progress := '003';
     IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Before Calling OKC code to find contract deliverable hold info');
     END IF;

      OKC_MANAGE_DELIVERABLES_GRP.applypaymentholds
                                            (p_api_version => l_api_version,
                                             p_bus_doc_id => p_po_header_id,
                                             p_bus_doc_version => l_rev_num,
                                             x_msg_data => l_msg_data,
                                             x_msg_count => l_msg_count,
                                             x_return_status => l_return_status_okc);

       d_progress := '004';
          IF (PO_LOG.d_stmt) THEN
	    PO_LOG.stmt(d_module, d_progress, 'After Calling OKC code to find contract deliverable hold info');
          END IF;
      IF l_return_status_okc = fnd_api.g_true THEN
        x_hold_required := 'Y';
        x_return_status := fnd_api.g_ret_sts_success;
      ELSIF l_return_status_okc = fnd_api.g_false THEN
        x_hold_required := 'N';
        x_return_status := fnd_api.g_ret_sts_success;
      ELSIF l_return_status_okc = fnd_api.g_ret_sts_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
      ELSE
        x_return_status := fnd_api.g_ret_sts_unexp_error;
      END IF;
   ELSE
     d_progress := '005';
    -- No need to call OKC. This PO does not have 'Pay when Paid' or 'Deliverable Hold flag' attribute marked.
    IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'No need to call OKC as Pay When Paid/Deliverable Hold flag is N or NULL');
    END IF;
      x_hold_required := 'N';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);
  END deliverable_overdue_check;
  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: DELIVERABLE_HOLD_CONTROL
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Procedure:
  --  This procedure returns information about whether the 'Initiate Payment Holds'
  --  region should be rendered for the deliverables on a given Standard PO.
  --  It is called from Contracts at the time of rendering the Create/Update Deliverables Pg.
  --Parameters:
  --IN:
  --p_api_version
  --  Version number of API that caller expects. It
  --  should match the l_api_version defined in the
  --  procedure (expected value : 1.0)
  --p_po_header_id
  --  The header id of the Purchase Order.

  -- OUT PARAMETERS
  -- x_return_status
  --   FND_API.G_RET_STS_SUCCESS if API succeeds
  --   FND_API.G_RET_STS_ERROR if API fails
  --   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
  -- x_msg_count
  -- x_msg_data
  --
  -- IN OUT PARAMETERS
  -- X_RENDER_DELIVERABLE_HOLD
  -- Return 'Y' when the Deliverable Hold Flag on the PO Style is 'Y' or pay when paid on the PO is 'Yes', else return 'N'.
  --End of Comments

  PROCEDURE DELIVERABLE_HOLD_CONTROL
       (P_API_VERSION    IN NUMBER,
        P_PO_HEADER_ID   IN NUMBER,
        X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
        X_MSG_COUNT      OUT NOCOPY NUMBER,
        X_MSG_DATA       OUT NOCOPY VARCHAR2,
        X_RENDER_DELIVERABLE_HOLD  IN OUT NOCOPY VARCHAR2)
  IS
    l_api_version  NUMBER := 1.0;
    l_api_name     VARCHAR2(60) := 'DELIVERABLE_HOLD_CONTROL';
    l_log_head     CONSTANT VARCHAR2(100) := g_log_head
                                             ||l_api_name;
    d_progress     VARCHAR2(3) := '000';
    d_module     VARCHAR2(70) := 'po.plsql.PO_INVOICE_HOLD_CHECK.DELIVERABLE_HOLD_CONTROL';

  BEGIN

  -- Check for the API version
    IF (NOT fnd_api.compatible_api_call(l_api_version,p_api_version,l_api_name,g_pkg_name)) THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
    END IF;

    d_progress := '001';

     IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'API Compatible call success');
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    d_progress := '002';

    SELECT Nvl(ps.deliverable_hold_flag, 'N')
    INTO x_render_deliverable_hold
    FROM po_doc_style_headers ps, po_headers_all ph
    WHERE ph.po_header_id = p_po_header_id
    AND ph.style_id = ps.style_id;

     IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Deliverable Hold query executed');
     END IF;

    IF x_render_deliverable_hold = 'N'
    THEN

    d_progress := '003';

    SELECT NVL(pay_when_paid, 'N')
    INTO  x_render_deliverable_hold
    FROM   po_headers_all
    WHERE  po_header_id = p_po_header_id;

     IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'pay when paid query executed');
     END IF;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);
  END DELIVERABLE_HOLD_CONTROL;

END po_invoice_hold_check;



/
