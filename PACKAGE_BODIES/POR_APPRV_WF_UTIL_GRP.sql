--------------------------------------------------------
--  DDL for Package Body POR_APPRV_WF_UTIL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_APPRV_WF_UTIL_GRP" AS
/* $Header: PORWFUTB.pls 120.0.12010000.5 2009/05/26 16:28:20 rohbansa ship $ */

/*===========================================================================
  FUNCTION NAME:        get_po_number

  DESCRIPTION:          Gets the po number for the given line_location_id

  CHANGE HISTORY:       17-SEP-2003  sbgeorge     Created
===========================================================================*/
FUNCTION get_po_number(p_line_location_id IN NUMBER) RETURN VARCHAR2
IS
   l_po_num varchar2(50);

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

/*===========================================================================
  FUNCTION NAME:        get_so_number

  DESCRIPTION:          Gets the sales order number for the given
                        requisition_line_id

  CHANGE HISTORY:       17-SEP-2003  sbgeorge     Created
===========================================================================*/
FUNCTION get_so_number(p_req_line_id IN NUMBER) RETURN NUMBER
IS
    l_so_number oe_order_headers_all.order_number%type;
  BEGIN
    SELECT ooh.order_number
    INTO l_so_number
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
   AND ool.source_document_line_id = prl.requisition_line_id
    AND psp.org_id = prh.org_id
    AND psp.order_source_id = ooh.order_source_id
    AND rownum =1;  /* To handle so line split case*/

    return l_so_number;

  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN others THEN
      RETURN NULL;
END get_so_number;

/*===========================================================================
  FUNCTION NAME:        get_cost_center

  DESCRIPTION:          Gets the cost_center for the given requisition_line_id

  CHANGE HISTORY:       17-SEP-2003  sbgeorge     Created
===========================================================================*/
FUNCTION get_cost_center(p_req_line_id IN NUMBER) RETURN VARCHAR2
IS
  l_segment_num       fnd_id_flex_segments.segment_num%TYPE;
  l_cost_center       VARCHAR2(200);
  l_account_id        gl_sets_of_books.chart_of_accounts_id%TYPE;
  cost_center_1       VARCHAR2(200);
  cc_Id               po_req_distributions_all.code_combination_id%TYPE;
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
           --added NVL check for single org, bug#6705513
           NVL(prl.org_id,-99) = NVL(fsp.org_id,-99) AND
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

END POR_APPRV_WF_UTIL_GRP;

/
