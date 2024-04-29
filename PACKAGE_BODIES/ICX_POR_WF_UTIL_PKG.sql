--------------------------------------------------------
--  DDL for Package Body ICX_POR_WF_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_WF_UTIL_PKG" AS
/* $Header: ICXWFUTB.pls 115.1 2004/03/31 18:47:51 vkartik noship $ */

/* Function returns po number for the given line_location_id */
FUNCTION get_po_number(p_line_location_id IN NUMBER) RETURN VARCHAR2
IS
   l_po_num varchar2(50);
   l_count number;

BEGIN
   SELECT ph.segment1|| DECODE(pr.release_num, NULL, '', '-' || pr.release_num)
   INTO l_po_num
   FROM
     po_releases_all pr,
     po_headers_all ph,
     po_line_locations_all pll
   WHERE
     pll.line_location_id=p_line_location_id AND
     pll.po_header_id = ph.po_header_id AND
     pll.po_release_id = pr.po_release_id(+);
   RETURN l_po_num;

   EXCEPTION
     WHEN OTHERS THEN
       RETURN '';
END get_po_number;

/* Function returns sales order number for the given requsition_line_id */
FUNCTION get_so_number(p_req_line_id IN NUMBER) RETURN VARCHAR2
IS
    l_status_code VARCHAR2(50);
    l_so_number VARCHAR2(50);
    l_line_id NUMBER;
  BEGIN
    SELECT TO_CHAR(ooh.order_number), ool.flow_status_code, ool.line_id
    INTO l_so_number, l_status_code, l_line_id
    from po_requisition_lines_all prl,
         po_requisition_headers_all prh,
         oe_order_headers_all ooh,
         oe_order_lines_all ool,
         po_system_parameters_all psp
    WHERE prl.requisition_header_id = prh.requisition_header_id
    AND prl.requisition_line_id = p_req_line_id
    AND prh.requisition_header_id = ooh.source_document_id
    AND prh.segment1 = ooh.orig_sys_document_ref
    AND ool.header_id = ooh.header_id
    AND ool.orig_sys_line_ref = TO_CHAR(prl.line_num)
    AND psp.org_id = prh.org_id
    AND psp.order_source_id = ooh.order_source_id;

    return l_so_number;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
END get_so_number;

/* Function returns cost center for the given requsition_line_id */
FUNCTION get_cost_center(p_req_line_id IN NUMBER) RETURN VARCHAR2
IS
  l_segment_num       NUMBER;
  l_cost_center       VARCHAR2(200);
  l_account_id        NUMBER;
  cost_center_1       VARCHAR2(200);
  cc_Id               NUMBER;
  l_segments          fnd_flex_ext.SegmentArray;
  nsegments           NUMBER;
  multiple_cost_center  VARCHAR2(100):= '';
  dist_num            NUMBER;

  CURSOR  ccId_csr(p_req_line_id NUMBER) IS
    SELECT code_combination_id
    FROM po_req_distributions_all
    WHERE requisition_line_id = p_req_line_id;
BEGIN
  multiple_cost_center := fnd_message.get_string('PO', 'PO_WF_NOTIF_MULTIPLE');

  BEGIN
    SELECT fs.segment_num, gls.chart_of_accounts_id
      INTO l_segment_num, l_account_id
      FROM FND_ID_FLEX_SEGMENTS fs,
           fnd_segment_attribute_values fsav,
           financials_system_params_all fsp,
           gl_sets_of_books gls,
           po_requisition_lines_all prl
     WHERE prl.requisition_line_id = p_req_line_id AND
           prl.org_id = fsp.org_id AND
           fsp.set_of_books_id = gls.set_of_books_id AND
           fsav.id_flex_num = gls.chart_of_accounts_id AND
           fsav.id_flex_code = 'GL#' AND
           fsav.application_id = 101 AND
           fsav.segment_attribute_type = 'FA_COST_CTR' AND
           fsav.id_flex_num = fs.id_flex_num AND
           fsav.id_flex_code = fs.id_flex_code AND
           fsav.application_id = fs.application_id AND
           fsav.application_column_name = fs.application_column_name AND
           fsav.attribute_value='Y';
  EXCEPTION
     WHEN OTHERS THEN
          l_segment_num := -1;
  END;

  IF l_segment_num = -1 THEN
     l_cost_center := '';
  ELSE
     l_cost_center := 'SINGLE';

     dist_num := 1;

     OPEN ccId_csr(p_req_line_id);
     LOOP
       FETCH ccId_csr INTO cc_Id;
       EXIT WHEN ccid_csr%NOTFOUND;

       IF fnd_flex_ext.get_segments( 'SQLGL','GL#', l_account_id,cc_id,nsegments,l_segments) THEN
          l_cost_center := l_segments(l_segment_num);
       ELSE
          l_cost_center := '';
       END IF;

       IF dist_num = 1 THEN
          cost_center_1 := l_cost_center;
          dist_num := 2;
       ELSE
          IF l_cost_center <> cost_center_1 THEN
             l_cost_center := multiple_cost_center;
             EXIT;
          END IF;
       END IF;
     END LOOP;
     CLOSE ccId_csr;
    IF l_cost_center <> multiple_cost_center THEN
       IF fnd_flex_ext.get_segments( 'SQLGL','GL#', l_account_id,cc_id,nsegments,l_segments) THEN
          l_cost_center := l_segments(l_segment_num);
       ELSE
          l_cost_center := '';
       END IF;
     END IF;
  END IF; --if l_segment_num = -1
  RETURN l_cost_center;
EXCEPTION --any exception while retrieving the cost center
   WHEN OTHERS THEN
        l_cost_center := '';
        RETURN l_cost_center;
END get_cost_center;

END icx_por_wf_util_pkg;

/
