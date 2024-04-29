--------------------------------------------------------
--  DDL for Package Body PO_CALCULATEREQTOTAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CALCULATEREQTOTAL_PVT" AS
/* $Header: POXVRTCB.pls 120.0.12010000.3 2014/04/01 10:36:08 uchennam ship $ */

/**
* Public FUNCTION get_req_distribution_total
* Requires: Requisition Header Id
*           Requisition Line Id
*           Requisition Distribution Id
* Modifies: None.
* Effects: Return updated distribution qty X new price
           from po_change_requests if any changes were made
*          Else return req_line_quantity X unit price
*          from po_req_distributions and po_requisition_lines
*          If line was cancelled return 0
* Returns:
*  Revised req total coming from a distribution
*  If something fails returns 0
*/
FUNCTION get_req_distribution_total(p_header_id IN NUMBER,
                                    p_line_id IN NUMBER,
                                    p_distribution_id IN NUMBER)
RETURN NUMBER
    IS
       l_matching_basis po_requisition_lines_all.matching_basis%type;
       l_action_type po_change_requests.action_type%type;
       l_dist_total NUMBER := 0;
       l_change_request_group_id po_change_requests.change_request_group_id%type;
BEGIN

      SELECT prl.matching_basis, pcr.action_type,
             decode (prl.matching_basis, 'AMOUNT' , prd.req_line_amount,
             prd.req_line_quantity*prl.unit_price) +
             nvl(prd.nonrecoverable_tax,0),
             pcr.change_request_group_id
      INTO   l_matching_basis, l_action_type, l_dist_total,
             l_change_request_group_id
      FROM   po_requisition_lines_all prl,
          	 po_req_distributions_all prd,
             po_change_requests pcr
      WHERE  prl.requisition_line_id = p_line_id
      AND  	 prl.requisition_line_id = prd.requisition_line_id
      AND    prd.distribution_id = p_distribution_id
      AND  	 nvl(prl.cancel_flag,'N') = 'N'
      AND  	 nvl(prl.modified_by_agent_flag, 'N') = 'N'
      AND    pcr.document_line_id(+) = prl.requisition_line_id
      AND    pcr.document_type(+) = 'REQ'
      AND    pcr.action_type(+) <> 'DERIVED'
      AND    pcr.request_status(+) NOT IN ('ACCEPTED', 'REJECTED')
      AND    rownum =1;

    IF (l_action_type is null) THEN
      RETURN l_dist_total;
    ELSIF (l_action_type = 'CANCELLATION') THEN
      RETURN 0;
    ELSE
      RETURN get_new_distribution_total(p_header_id, p_line_id,
                            			      p_distribution_id, l_matching_basis,
                                        l_change_request_group_id);
    END IF;

EXCEPTION WHEN OTHERS THEN
  RETURN 0;
END get_req_distribution_total;

-- Bug 16168687 start

/* The following function is same as get_req_distribution_total except that
  query for getting dist total is modified to exclude SYSTEMSAVE records
  from po_change_requests table. This is required as these records causing
  issue in approving the requisition. Creating new function as existing
  function is required in AME where SYSTEMSAVE records also needs to be
  considered.*/

/**
* Public FUNCTION get_req_dist_total
* Requires: Requisition Header Id
*           Requisition Line Id
*           Requisition Distribution Id
* Modifies: None.
* Effects: Return updated distribution qty X new price
           from po_change_requests if any changes were made
*          Else return req_line_quantity X unit price
*          from po_req_distributions and po_requisition_lines
*          If line was cancelled return 0
* Returns:
*  Revised req total coming from a distribution
*  If something fails returns 0
*/
FUNCTION get_req_dist_total(p_header_id IN NUMBER,
                                    p_line_id IN NUMBER,
                                    p_distribution_id IN NUMBER)
RETURN NUMBER
    IS
       l_matching_basis po_requisition_lines_all.matching_basis%type;
       l_action_type po_change_requests.action_type%type;
       l_dist_total NUMBER := 0;
       l_change_request_group_id po_change_requests.change_request_group_id%type;
BEGIN

      SELECT prl.matching_basis, pcr.action_type,
             decode (prl.matching_basis, 'AMOUNT' , prd.req_line_amount,
             prd.req_line_quantity*prl.unit_price) +
             nvl(prd.nonrecoverable_tax,0),
             pcr.change_request_group_id
      INTO   l_matching_basis, l_action_type, l_dist_total,
             l_change_request_group_id
      FROM   po_requisition_lines_all prl,
          	 po_req_distributions_all prd,
             po_change_requests pcr
      WHERE  prl.requisition_line_id = p_line_id
      AND  	 prl.requisition_line_id = prd.requisition_line_id
      AND    prd.distribution_id = p_distribution_id
      AND  	 nvl(prl.cancel_flag,'N') = 'N'
      AND  	 nvl(prl.modified_by_agent_flag, 'N') = 'N'
      AND    pcr.document_line_id(+) = prl.requisition_line_id
      AND    pcr.document_type(+) = 'REQ'
      AND    pcr.action_type(+) <> 'DERIVED'
     AND    (pcr.request_status(+) NOT IN ('ACCEPTED', 'REJECTED') and (not (pcr.request_status (+) = 'SYSTEMSAVE' and pcr.action_type(+) = 'CANCELLATION')))/* added AND for Bug 18283252 */
      AND    rownum =1;

    IF (l_action_type is null) THEN
      RETURN l_dist_total;
    ELSIF (l_action_type = 'CANCELLATION') THEN
      RETURN 0;
    ELSE
      RETURN get_new_distribution_total(p_header_id, p_line_id,
                            			      p_distribution_id, l_matching_basis,
                                        l_change_request_group_id);
    END IF;

EXCEPTION WHEN OTHERS THEN
  RETURN 0;
END get_req_dist_total;

-- Bug 16168687 End

/**
* Public FUNCTION get_new_distribution_total
* Requires: Requisition Header Id
*           Requisition Line Id
*           Distribution Id
*           Assumes that the line is not cancelled
* Modifies: None.
* Effects: Return updated requisition total
*          for a distribution
*          using revised values of distribution qty and line price
* Returns:
*  Revised req total coming from a distribution
*  If something fails returns 0
*/

FUNCTION get_new_distribution_total(p_header_id IN NUMBER,
                                    p_line_id IN NUMBER,
                           	        p_distribution_id IN NUMBER,
                                    p_matching_basis IN VARCHAR2,
                                    p_change_request_group_id IN NUMBER)
RETURN NUMBER
    IS
       l_nonrec_tax NUMBER := 0;
       l_old_dist_total NUMBER := 0;
       l_new_dist_total NUMBER := 0;
BEGIN
  IF (p_matching_basis = 'AMOUNT') THEN

      -- get updated amount
      SELECT prd.req_line_amount,
             nvl(pcr.new_amount, prd.req_line_amount),
             prd.nonrecoverable_tax
      INTO   l_old_dist_total, l_new_dist_total, l_nonrec_tax
      FROM   po_change_requests pcr,
             po_req_distributions_all prd
      WHERE  prd.distribution_id = p_distribution_id
      AND    pcr.document_line_id(+) = prd.requisition_line_id
      AND    pcr.document_distribution_id(+) = prd.distribution_id
      AND    pcr.request_status(+) NOT IN ('ACCEPTED','REJECTED');

  ELSE

      -- get updated line price and quantity
      SELECT prd.req_line_quantity*prl.unit_price,
             nvl(pcr1.new_quantity, prd.req_line_quantity)*nvl(pcr.new_price, prl.unit_price),
             prd.nonrecoverable_tax
      INTO   l_old_dist_total, l_new_dist_total, l_nonrec_tax
      FROM   po_change_requests pcr,
             po_change_requests pcr1,
             po_requisition_lines_all prl,
             po_req_distributions_all prd
      WHERE  prd.distribution_id = p_distribution_id
      AND    pcr1.document_distribution_id(+) = prd.distribution_id
      AND    pcr1.document_line_id(+) = prd.requisition_line_id
      AND    pcr1.request_status(+) NOT IN ('ACCEPTED','REJECTED')
      AND    prd.requisition_line_id = prl.requisition_line_id
      AND    pcr.document_line_id(+) = prl.requisition_line_id
      AND    pcr.new_price(+) IS NOT NULL
      AND    pcr.old_price(+) IS NOT NULL
      AND    pcr.document_type(+) = 'REQ'
      AND    pcr.request_status(+) NOT IN ('ACCEPTED','REJECTED')
      AND    pcr.request_level(+) = 'LINE'
      AND    pcr.action_type(+) <> 'CANCELLATION'
      AND    pcr.change_request_group_id(+) = p_change_request_group_id;

  END IF;

  IF (l_old_dist_total IS NOT NULL AND l_old_dist_total > 0) THEN
    l_nonrec_tax := NVL((l_nonrec_tax / l_old_dist_total) * l_new_dist_total, 0);
    RETURN  NVL(l_nonrec_tax + l_new_dist_total, 0);
  ELSE
    RETURN NVL(l_new_dist_total, 0);
  END IF;

EXCEPTION WHEN OTHERS THEN
  RETURN 0;
END get_new_distribution_total;

END PO_CALCULATEREQTOTAL_PVT;

/
