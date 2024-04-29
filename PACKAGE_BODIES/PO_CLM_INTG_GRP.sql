--------------------------------------------------------
--  DDL for Package Body PO_CLM_INTG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CLM_INTG_GRP" AS
  /* $Header: PO_CLM_INTG_GRP.plb 120.0.12010000.5 2010/06/03 12:19:18 grohit noship $*/

  ------------------------------------------------------------------------------
  --Start of Comments
  --Name: is_clm_po
  --Pre-reqs:
  --  None
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  This function will determine whether a PO is a clm PO.
  --Parameters:
  --IN:
  --  p_po_header_id
  --    Header ID of the PO to check whether or not it's a clm PO
  --  p_po_line_id
  --    Line ID of the PO to check whether or not it's a clm PO
  --  p_po_line_location_id
  --    Line Location ID of the PO to check whether or not it's a clm PO
  --  p_po_distribution_id
  --    Distribution ID of the PO to check whether or not it's a clm PO
  --RETURNS:
  --  Y: The PO is a CLM PO
  --  N: The PO is not a CLM PO
  --End of Comments
  -------------------------------------------------------------------------------
  FUNCTION Is_clm_po
                    (       p_po_header_id        IN NUMBER DEFAULT NULL,
                            p_po_line_id          IN NUMBER DEFAULT NULL,
                            p_po_line_location_id IN NUMBER DEFAULT NULL,
                            p_po_distribution_id  IN NUMBER DEFAULT NULL
                    )
        RETURN VARCHAR2
IS
        d_module   VARCHAR2(70) := 'po.plsql.PO_CLM_INTG_GRP.is_CLM_po';
        d_progress NUMBER;
        l_style_id po_headers_all.style_id%TYPE;
        l_po_header_id po_headers_all.po_header_id%TYPE;
        l_is_clm_po VARCHAR2(1) := 'N';
        l_count     NUMBER      := 0;
BEGIN
    d_progress := 0;

    IF (po_log.d_proc) THEN
      po_log.Proc_begin(d_module);
    END IF;

    d_progress := 10;

    RETURN l_is_clm_po;
EXCEPTION
WHEN OTHERS THEN
        IF (po_log.d_exc) THEN
                po_log.Exc(d_module,d_progress,SQLCODE
                ||sqlerrm);
                po_log.Proc_end(d_module);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END is_clm_po;

 ------------------------------------------------------------------------------
  --Start of Comments
  --Name: is_clm_po
  --Pre-reqs:
  --  None
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  This function will determine whether a PO is a clm PO.
  --Parameters:
  --IN:
  --  p_doc_type
  --    Header ID of the PO/REQ to check whether or not it's a clm Document
  --    'REQUISITION'
  --    'PO'
  --    'PA'
  --  p_document_id
  --    PO or Requisition Header Id
  --RETURNS:
  --  Y: The document is a CLM document
  --  N: The document is not a CLM document
  --End of Comments
  -------------------------------------------------------------------------------

FUNCTION is_clm_document
                         (
                                 p_doc_type    IN VARCHAR2,
                                 p_document_id IN NUMBER
                         )
        RETURN VARCHAR2
IS
        l_clm_document VARCHAR2(1) := 'N';
BEGIN

        RETURN l_clm_document;

EXCEPTION
WHEN OTHERS THEN
        RETURN 'N';
END is_clm_document;

  ------------------------------------------------------------------------------
  --Start of Comments
  --Name: is_clm_instance
  --Pre-reqs:
  --  None
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  This function will check if its a CLM instance
  --Parameters:
  --IN:
  --RETURNS:
  --  Y: This is a CLM Instance
  --  N: This is Not a CLM Instance
  --End of Comments
  -------------------------------------------------------------------------------
  FUNCTION is_clm_installed
  RETURN VARCHAR2
  IS
    d_module           VARCHAR2(70) := 'po.plsql.PO_CLM_INTG_GRP.is_clm_installed';
    d_progress         NUMBER;
    is_clm_installed  VARCHAR2(1) := 'N';
  BEGIN
    d_progress := 0;

    IF (po_log.d_proc) THEN
      po_log.Proc_begin(d_module);
    END IF;

    d_progress := 10;

    RETURN is_clm_installed;
  EXCEPTION
    WHEN OTHERS THEN
      IF (po_log.d_exc) THEN
        po_log.Exc(d_module,d_progress,SQLCODE
                                       ||sqlerrm);

        po_log.Proc_end(d_module);
      END IF;

      RAISE;
  END is_clm_installed;



  PROCEDURE get_po_dist_values(
        p_min_unit_meas_lookup_code   IN VARCHAR2,
        p_min_matching_basis          IN VARCHAR2,
        p_min_distribution_type       IN VARCHAR2,
        p_min_accrue_on_receipt_flag  IN VARCHAR2,
        p_min_code_combination_id     IN NUMBER,
        p_min_budget_account_id       IN NUMBER,
        p_min_partial_funded_flag     IN VARCHAR2,
        p_max_unit_meas_lookup_code   IN VARCHAR2,
        p_max_matching_basis          IN VARCHAR2,
        p_max_distribution_type       IN VARCHAR2,
        p_max_accrue_on_receipt_flag  IN VARCHAR2,
        p_max_code_combination_id     IN NUMBER,
        p_max_budget_account_id       IN NUMBER,
        p_max_partial_funded_flag     IN VARCHAR2,
        x_unit_meas_lookup_code       OUT NOCOPY VARCHAR2,
        x_matching_basis              OUT NOCOPY VARCHAR2,
        x_distribution_type           OUT NOCOPY VARCHAR2,
        x_accrue_on_receipt_flag      OUT NOCOPY VARCHAR2,
        x_code_combination_id         OUT NOCOPY NUMBER,
        x_budget_account_id           OUT NOCOPY NUMBER,
        x_partial_funded_flag         OUT NOCOPY VARCHAR2)
  IS
  BEGIN

     IF (p_min_unit_meas_lookup_code = p_max_unit_meas_lookup_code AND p_min_unit_meas_lookup_code IS NOT NULL AND
        p_max_unit_meas_lookup_code IS  NOT null) THEN
        x_unit_meas_lookup_code := p_min_unit_meas_lookup_code;
     ELSE
        x_unit_meas_lookup_code := NULL;
     END IF;

     IF (p_min_matching_basis = p_max_matching_basis AND p_min_matching_basis IS NOT NULL AND
        p_max_matching_basis IS  NOT null) THEN
        x_matching_basis := p_min_matching_basis;
     ELSE
        x_matching_basis := NULL;
     END IF;

     IF (p_min_distribution_type = p_max_distribution_type AND p_min_distribution_type IS NOT NULL AND
        p_max_distribution_type IS  NOT null) THEN
        x_distribution_type := p_min_distribution_type;
     ELSE
        x_distribution_type := NULL;
     END IF;

     IF (p_min_accrue_on_receipt_flag = p_max_accrue_on_receipt_flag AND p_min_accrue_on_receipt_flag IS NOT NULL AND
        p_max_accrue_on_receipt_flag IS  NOT null) THEN
        x_accrue_on_receipt_flag := p_min_accrue_on_receipt_flag;
     ELSE
        x_accrue_on_receipt_flag := NULL;
     END IF;

     IF (p_min_code_combination_id = p_max_code_combination_id AND p_min_code_combination_id IS NOT NULL AND
        p_max_code_combination_id IS  NOT null) THEN
        x_code_combination_id := p_min_code_combination_id;
     ELSE
        x_code_combination_id := NULL;
     END IF;

     IF (p_min_budget_account_id = p_max_budget_account_id AND p_min_budget_account_id IS NOT NULL AND
        p_max_budget_account_id IS  NOT null) THEN
        x_budget_account_id := p_min_budget_account_id;
     ELSE
        x_budget_account_id := NULL;
     END IF;

     IF (p_min_partial_funded_flag = p_max_partial_funded_flag AND p_min_partial_funded_flag IS NOT NULL AND
        p_max_partial_funded_flag IS  NOT null) THEN
        x_partial_funded_flag := p_min_partial_funded_flag;
     ELSE
        x_partial_funded_flag := 'N';
     END IF;
  END get_po_dist_values;


  ------------------------------------------------------------------------------
  --Start of Comments
  --Name: Get_funding_info
  --Pre-reqs:
  --  None
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Procedure:
  --  This procedure returns the PO Funding Information for a given entity id
  --  Used by Invoicing and Receiving
  --Parameters:
  --IN:
  --  p_po_header_id            - Header ID of the PO
  --  p_po_line_id              - Line ID of the PO
  --  p_po_line_location_id     - Line Location ID of the PO
  --  p_po_distribution_id      - Distribution ID of the PO
  --OUT:
  --  x_distribution_type       - Distribution Type
  --  x_matching_basis          - Mathcing Basis
  --  x_accrue_on_receipt_flag  - Accrue on Receipt Flag
  --  x_code_combination_id     - Code Combination Id
  --  x_budget_account_id       - Budget Account Id
  --  x_partial_funded_flag     - Partial Funded Flag
  --  x_unit_meas_lookup_code   - UOM
  --  x_funded_value            - Funded Value
  --  x_quantity_funded         - Quantity Funded
  --  x_amount_funded           - Amount Funded
  --  x_quantity_received       - Quantity Received
  --  x_amount_received         - Amount Received
  --  x_quantity_delivered      - Quantity Delivered
  --  x_amount_delivered        - Amount Delivered
  --  x_quantity_billed         - Quantity Billed
  --  x_amount_billed           - Amount Billed
  --  x_quantity_cancelled      - Quantity cancelled
  --  x_amount_cancelled        - Amount cancelled
  --  x_return_status           - Success/Error
  --          fnd_api.g_ret_sts_success (or) fnd_api.g_ret_sts_unexp_error

  --End of Comments
  -------------------------------------------------------------------------------

  PROCEDURE Get_funding_info
       (p_po_header_id            IN NUMBER DEFAULT NULL,
        p_po_line_id              IN NUMBER DEFAULT NULL,
        p_line_location_id        IN NUMBER DEFAULT NULL,
        p_po_distribution_id      IN NUMBER DEFAULT NULL,
        x_distribution_type       OUT NOCOPY VARCHAR2,
        x_matching_basis          OUT NOCOPY VARCHAR2,
        x_accrue_on_receipt_flag  OUT NOCOPY VARCHAR2,
        x_code_combination_id     OUT NOCOPY NUMBER,
        x_budget_account_id       OUT NOCOPY NUMBER,
        x_partial_funded_flag     OUT NOCOPY VARCHAR2,
	x_unit_meas_lookup_code	  OUT NOCOPY VARCHAR2,
        x_funded_value            OUT NOCOPY NUMBER,
        x_quantity_funded         OUT NOCOPY NUMBER,
        x_amount_funded           OUT NOCOPY NUMBER,
        x_quantity_received       OUT NOCOPY NUMBER,
        x_amount_received         OUT NOCOPY NUMBER,
        x_quantity_delivered      OUT NOCOPY NUMBER,
        x_amount_delivered        OUT NOCOPY NUMBER,
        x_quantity_billed         OUT NOCOPY NUMBER,
        x_amount_billed           OUT NOCOPY NUMBER,
	x_quantity_cancelled 	  OUT NOCOPY NUMBER,
	x_amount_cancelled 	  OUT NOCOPY NUMBER,
        x_return_status           OUT NOCOPY VARCHAR2)
  IS
    d_module    VARCHAR2(70) := 'po.plsql.PO_CLM_INTG_GRP.Get_Funding_Info';
    d_progress  NUMBER;
    l_min_distribution_type       po_distributions_all.distribution_type%TYPE;
    l_min_matching_basis          po_line_locations_all.matching_basis%TYPE;
    l_min_accrue_on_receipt_flag  po_distributions_all.accrue_on_receipt_flag%TYPE;
    l_min_code_combination_id     po_distributions_all.code_combination_id%TYPE;
    l_min_budget_account_id       po_distributions_all.budget_account_id%TYPE;
    l_min_partial_funded_flag     po_distributions_all.partial_funded_flag%TYPE;
    l_min_unit_meas_lookup_code	  po_line_locations_all.unit_meas_lookup_code%TYPE;
    l_max_distribution_type       po_distributions_all.distribution_type%TYPE;
    l_max_matching_basis          po_line_locations_all.matching_basis%TYPE;
    l_max_accrue_on_receipt_flag  po_distributions_all.accrue_on_receipt_flag%TYPE;
    l_max_code_combination_id     po_distributions_all.code_combination_id%TYPE;
    l_max_budget_account_id       po_distributions_all.budget_account_id%TYPE;
    l_max_partial_funded_flag     po_distributions_all.partial_funded_flag%TYPE;
    l_max_unit_meas_lookup_code	  po_line_locations_all.unit_meas_lookup_code%TYPE;

  BEGIN

    d_progress := 0;
    IF (po_log.d_proc) THEN
                po_log.Proc_begin(d_module);
                po_log.Proc_begin(d_module,'p_po_header_id',p_po_header_id);
                po_log.Proc_begin(d_module,'p_po_line_id',p_po_line_id);
                po_log.Proc_begin(d_module,'p_line_location_id',p_line_location_id);
                po_log.Proc_begin(d_module,'p_po_distribution_id',p_po_distribution_id);
    END IF;

    IF p_po_distribution_id IS NOT NULL THEN

      d_progress := 10;

      SELECT  pod.distribution_type,
              pll.matching_basis,
              pod.accrue_on_receipt_flag,
              pod.code_combination_id,
              pod.budget_account_id,
              'N',
              pl.unit_meas_lookup_code,
              null,
              null,
              null,
              pll.quantity_received,
              pll.amount_received,
              pod.quantity_delivered,
              pod.amount_delivered,
              pod.quantity_billed,
              pod.amount_billed,
	      pod.quantity_cancelled,
	      pod.amount_cancelled
       INTO   x_distribution_type,x_matching_basis,x_accrue_on_receipt_flag,x_code_combination_id,
              x_budget_account_id,x_partial_funded_flag,x_unit_meas_lookup_code,x_funded_value,
              x_quantity_funded,x_amount_funded,x_quantity_received,x_amount_received,
              x_quantity_delivered,x_amount_delivered,x_quantity_billed,x_amount_billed,
	      x_quantity_cancelled, x_amount_cancelled
       FROM   po_distributions_all pod,
              po_line_locations_all pll,
              po_lines_all pl
      WHERE   pll.line_location_id = pod.line_location_id
              AND pod.po_distribution_id = p_po_distribution_id
              AND pl.po_line_id = pod.po_line_id;

    ELSIF p_line_location_id IS NOT NULL THEN

     d_progress := 20;

     SELECT   null,
              null,
              null,
              Sum(pod.quantity_delivered),
              Sum(pod.amount_delivered),
              Sum(pod.quantity_billed),
              Sum(pod.amount_billed),
              Min(pod.distribution_type),
              Max(pod.distribution_type),
              Min(pod.accrue_on_receipt_flag),
              Max(pod.accrue_on_receipt_flag),
              Min(pod.code_combination_id),
              Max(pod.code_combination_id),
              Min(pod.budget_account_id),
              Max(pod.budget_account_id),
              'N',
              'N',
	      Sum(pod.quantity_cancelled),
	      Sum(pod.amount_cancelled)
       INTO   x_funded_value,x_quantity_funded,x_amount_funded,x_quantity_delivered,
              x_amount_delivered,x_quantity_billed,x_amount_billed,
              l_min_distribution_type,l_max_distribution_type,
              l_min_accrue_on_receipt_flag,l_max_accrue_on_receipt_flag,
              l_min_code_combination_id,l_max_code_combination_id,
              l_min_budget_account_id,l_max_budget_account_id,
              l_min_partial_funded_flag,l_max_partial_funded_flag,
	      x_quantity_cancelled,x_amount_cancelled
       FROM   po_distributions_all pod
      WHERE   pod.line_location_id = p_line_location_id;


     d_progress := 30;

     get_po_dist_values(
        NULL,
        NULL,
        l_min_distribution_type,
        l_min_accrue_on_receipt_flag,
        l_min_code_combination_id,
        l_min_budget_account_id,
        l_min_partial_funded_flag,
        NULL,
        NULL,
        l_max_distribution_type,
        l_max_accrue_on_receipt_flag,
        l_max_code_combination_id,
        l_max_budget_account_id,
        l_max_partial_funded_flag,
        x_unit_meas_lookup_code,
        x_matching_basis,
        x_distribution_type,
        x_accrue_on_receipt_flag,
        x_code_combination_id,
        x_budget_account_id,
        x_partial_funded_flag);

     d_progress := 40;

     SELECT   pll.unit_meas_lookup_code,
              pll.matching_basis,
              pll.quantity_received,
              pll.amount_received
       INTO   x_unit_meas_lookup_code,x_matching_basis,x_quantity_received,x_amount_received
       FROM   po_line_locations_all pll
      WHERE   pll.line_location_id = p_line_location_id;


    ELSIF p_po_line_id IS NOT NULL THEN

     d_progress := 50;

     SELECT   null,
              null,
              null,
              Sum(pod.quantity_delivered),
              Sum(pod.amount_delivered),
              Sum(pod.quantity_billed),
              Sum(pod.amount_billed),
              Min(pod.distribution_type),
              Max(pod.distribution_type),
              Min(pod.accrue_on_receipt_flag),
              Max(pod.accrue_on_receipt_flag),
              Min(pod.code_combination_id),
              Max(pod.code_combination_id),
              Min(pod.budget_account_id),
              Max(pod.budget_account_id),
              'N',
              'N'
       INTO   x_funded_value,x_quantity_funded,x_amount_funded,x_quantity_delivered,
              x_amount_delivered,x_quantity_billed,x_amount_billed,
              l_min_distribution_type,l_max_distribution_type,
              l_min_accrue_on_receipt_flag,l_max_accrue_on_receipt_flag,
              l_min_code_combination_id,l_max_code_combination_id,
              l_min_budget_account_id,l_max_budget_account_id,
              l_min_partial_funded_flag,l_max_partial_funded_flag
       FROM   po_distributions_all pod
      WHERE   pod.po_line_id = p_po_line_id;

     d_progress := 60;

     SELECT   Sum(pll.quantity_received),
              Sum(pll.amount_received),
              Min(pll.unit_meas_lookup_code),
              Max(pll.unit_meas_lookup_code),
              Min(pll.matching_basis),
              Max(pll.matching_basis)
       INTO   x_quantity_received,x_amount_received,
              l_min_unit_meas_lookup_code,l_max_unit_meas_lookup_code,
              l_min_matching_basis,l_max_matching_basis
       FROM   po_line_locations_all pll
      WHERE   pll.po_line_id = p_po_line_id;

      d_progress := 70;

      get_po_dist_values(
        l_min_unit_meas_lookup_code,
        l_min_matching_basis,
        l_min_distribution_type,
        l_min_accrue_on_receipt_flag,
        l_min_code_combination_id,
        l_min_budget_account_id,
        l_min_partial_funded_flag,
        l_max_unit_meas_lookup_code,
        l_max_matching_basis,
        l_max_distribution_type,
        l_max_accrue_on_receipt_flag,
        l_max_code_combination_id,
        l_max_budget_account_id,
        l_max_partial_funded_flag,
        x_unit_meas_lookup_code,
        x_matching_basis,
        x_distribution_type,
        x_accrue_on_receipt_flag,
        x_code_combination_id,
        x_budget_account_id,
        x_partial_funded_flag);

  ELSIF p_po_header_id IS NOT NULL THEN

     d_progress := 80;

     SELECT   null,
              null,
              null,
              Sum(pod.quantity_delivered),
              Sum(pod.amount_delivered),
              Sum(pod.quantity_billed),
              Sum(pod.amount_billed),
              Min(pod.distribution_type),
              Max(pod.distribution_type),
              Min(pod.accrue_on_receipt_flag),
              Max(pod.accrue_on_receipt_flag),
              Min(pod.code_combination_id),
              Max(pod.code_combination_id),
              Min(pod.budget_account_id),
              Max(pod.budget_account_id),
              'N',
              'N'
       INTO   x_funded_value,x_quantity_funded,x_amount_funded,x_quantity_delivered,
              x_amount_delivered,x_quantity_billed,x_amount_billed,
              l_min_distribution_type,l_max_distribution_type,
              l_min_accrue_on_receipt_flag,l_max_accrue_on_receipt_flag,
              l_min_code_combination_id,l_max_code_combination_id,
              l_min_budget_account_id,l_max_budget_account_id,
              l_min_partial_funded_flag,l_max_partial_funded_flag
       FROM   po_distributions_all pod
      WHERE   pod.po_header_id = p_po_header_id;

     d_progress := 90;

     SELECT   Sum(pll.quantity_received),
              Sum(pll.amount_received),
              Min(pll.unit_meas_lookup_code),
              Max(pll.unit_meas_lookup_code),
              Min(pll.matching_basis),
              Max(pll.matching_basis)
       INTO   x_quantity_received,x_amount_received,
              l_min_unit_meas_lookup_code,l_max_unit_meas_lookup_code,
              l_min_matching_basis,l_max_matching_basis
       FROM   po_line_locations_all pll
      WHERE   pll.po_header_id = p_po_header_id;

      d_progress := 100;

      get_po_dist_values(
        l_min_unit_meas_lookup_code,
        l_min_matching_basis,
        l_min_distribution_type,
        l_min_accrue_on_receipt_flag,
        l_min_code_combination_id,
        l_min_budget_account_id,
        l_min_partial_funded_flag,
        l_max_unit_meas_lookup_code,
        l_max_matching_basis,
        l_max_distribution_type,
        l_max_accrue_on_receipt_flag,
        l_max_code_combination_id,
        l_max_budget_account_id,
        l_max_partial_funded_flag,
        x_unit_meas_lookup_code,
        x_matching_basis,
        x_distribution_type,
        x_accrue_on_receipt_flag,
        x_code_combination_id,
        x_budget_account_id,
        x_partial_funded_flag);

   ELSE
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    d_progress      := 110;
    IF (po_log.d_stmt) THEN
          po_log.Stmt(d_module,d_progress,'p_po_header_id, p_po_line_id, p_po_line_location_id, p_po_distribution_id are NULL!');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;
   IF (po_log.d_proc) THEN
         po_log.Proc_end(d_module);
   END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (po_log.d_exc) THEN
                po_log.Exc(d_module,d_progress,SQLCODE
                ||sqlerrm);
                po_log.Proc_end(d_module);
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END get_funding_info;

END PO_CLM_INTG_GRP;

/
