--------------------------------------------------------
--  DDL for Package Body INV_DIAG_RCV_IPROC_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_RCV_IPROC_COMMON" AS
/* $Header: INVREQ2B.pls 120.2 2008/03/20 11:41:03 srnatara noship $ */
--------------------------------------------------
-- Package to Build sqls for Req and OU combination
--------------------------------------------------
PROCEDURE build_req_sql(p_operating_id IN NUMBER,
                           p_req_number    IN VARCHAR2,
                           p_line_num     IN NUMBER,
                           p_sql          IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list)
IS
-- Initialize Local Variables.
l_operating_id po_requisition_headers_all.org_id%TYPE     := p_operating_id;
l_req_number   po_requisition_headers_all.segment1%TYPE   := p_req_number;
l_line_num       VARCHAR2(1000)               := p_line_num;

BEGIN

-- Build the condition based on the input
IF p_line_num IS NULL THEN
   l_line_num     := ' prl.line_num ';
END IF;

    p_sql(1) := ' select distinct prh.*' ||
' from po_requisition_headers_all prh,' ||
  ' po_requisition_lines_all prl' ||
       ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prh.org_id = '||l_operating_id||
   ' and prl.line_num='||l_line_num||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and prl.source_type_code = ''VENDOR'' ';

       p_sql(2) := ' select distinct prl.*' ||
' from po_requisition_lines_all prl,' ||
  ' po_requisition_headers_all prh ' ||
       ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prh.org_id = '||l_operating_id||
   ' and prl.line_num='||l_line_num||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.source_type_code = ''VENDOR''' ||
' order by prl.requisition_line_id ';

    p_sql(3) := ' select distinct prd.*' ||
' from po_req_distributions_all prd ,' ||
  ' po_requisition_lines_all prl ,' ||
       ' po_requisition_headers_all prh' ||
       ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.requisition_line_id = prd.requisition_line_id' ||
   ' and prl.source_type_code = ''VENDOR''' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prh.org_id = '||l_operating_id||
   ' and prl.line_num='||l_line_num||
   ' order by prd.distribution_id ';

    p_sql(4) := ' SELECT  distinct ph.* ' ||
' from    po_headers_all ph,' ||
' po_distributions_all pd,' ||
        ' po_req_distributions_all prd ,' ||
        ' 	po_requisition_lines_all prl ,' ||
' po_requisition_headers_all prh' ||
        ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.requisition_line_id = prd.requisition_line_id' ||
   ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(5) := ' SELECT  distinct pl.* ' ||
' from    po_lines_all pl , ' ||
' po_headers_all ph,' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
      ' and prh.org_id = '||l_operating_id;


/* Bug#6882986
 *  Due to missing join conditions, queries were fetching data
 *  not related to the req line number provided by the user.
 *  Added required join conditions to fetch only records pertaining
 *  to the req line number entered by the user.
 */
    p_sql(6) := ' SELECT  distinct pll.* ' ||
' from    po_line_locations_all pll , ' ||
' po_lines_all pl , ' ||
        ' po_headers_all ph,' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.line_location_id = pd.line_location_id ' || --Bug#6882986
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
      ' and prh.org_id = '||l_operating_id;


    p_sql(7) := ' SELECT  distinct pd.* ' ||
' from    po_line_locations_all pll , ' ||
' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


    p_sql(8) := ' SELECT  distinct gcc.* ' ||
' from    gl_code_combinations gcc , ' ||
' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and gcc.summary_flag = ''N'' ' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND gcc.template_id is null ' ||
   ' AND gcc.code_combination_id in (pd.accrual_account_id , pd.budget_account_id , pd.VARIANCE_ACCOUNT_ID , pd.code_combination_id)' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(9) := ' SELECT  distinct rrsl.* ' ||
' from    rcv_receiving_sub_ledger rrsl , ' ||
' rcv_transactions rt , ' ||
        ' po_headers_all ph,' ||
        ' po_line_locations_all pll , ' ||--Bug#6882986
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' and pll.po_header_id=ph.po_header_id' ||--Bug#6882986
   ' and pll.line_location_id=pd.line_location_id' ||--Bug#6882986
   ' and pll.line_location_id=rt.po_line_location_id' ||--Bug#6882986
   ' AND rt.po_header_id         = ph.po_header_id ' ||
   ' AND rrsl.rcv_transaction_id = rt.transaction_id' ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       /*p_sql(10) := ' SELECT  distinct id.* ' ||
' from    ap_invoice_distributions_all id , ' ||
' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND id.po_distribution_id = pd.po_distribution_id     ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;*/

   p_sql(10) := ' SELECT  distinct id.* ' ||
' from    ap_invoice_lines_all id , ' ||
' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND id.po_distribution_id = pd.po_distribution_id     ' ||
   ' and id.po_line_location_id=pll.line_location_id'||' and id.po_line_id=pl.po_line_id'||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(11) := ' SELECT  distinct ai.* ' ||
' from    ap_invoices_all ai , ' ||
' ap_invoice_distributions_all id , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND id.po_distribution_id = pd.po_distribution_id ' ||
    ' AND ai.invoice_id         = id.invoice_id' ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(12) := ' SELECT  distinct ili.* ' ||
' from    ap_invoice_lines_interface ili , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and ili.po_header_id = ph.po_header_id   ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(13) := ' SELECT  distinct ihi.* ' ||
' from    ap_invoices_interface ihi , ' ||
' ap_invoice_lines_interface ili , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' and ili.po_header_id = ph.po_header_id ' ||
   ' AND ihi.invoice_id    = ili.invoice_id  ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(14) := ' SELECT DISTINCT rsh.* ' ||
' from    rcv_shipment_lines rsl , ' ||
' rcv_shipment_headers rsh, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and rsl.po_line_location_id=pll.line_location_id' ||
   ' AND rsl.shipment_header_id = rsh.shipment_header_id    ' ||
  ' AND pll.line_location_id = pd.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(15) := ' SELECT DISTINCT rsl.* ' ||
' from    rcv_shipment_lines rsl , ' ||
' rcv_shipment_headers rsh, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and rsl.po_line_location_id=pll.line_location_id' ||
   ' AND rsl.shipment_header_id = rsh.shipment_header_id    ' ||
  ' AND pll.line_location_id = pd.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(16) := ' SELECT DISTINCT rt.* ' ||
' from    rcv_transactions rt , ' ||
' rcv_shipment_headers rsh, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and rt.po_line_location_id=pll.line_location_id' ||
   ' AND rt.shipment_header_id = rsh.shipment_header_id    ' ||
  ' AND pll.line_location_id = pd.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(17) := ' SELECT  DISTINCT ms.* ' ||
' from    mtl_supply ms , ' ||
' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and ms.po_line_location_id=pll.line_location_id' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(18) := ' SELECT DISTINCT rs.* ' ||
' from    rcv_supply rs , ' ||
' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and rs.po_line_location_id=pll.line_location_id' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

p_sql(19) := ' SELECT DISTINCT rhi.* ' ||
' from    rcv_headers_interface rhi ' ||
' WHERE   exists ' ||
' (SELECT 1 ' ||
        ' from    rcv_shipment_lines rsl , ' ||
          ' rcv_shipment_headers rsh, ' ||
                  ' po_line_locations_all pll , ' ||
                  ' po_distributions_all pd,' ||
                  ' po_req_distributions_all prd ,' ||
                  ' po_requisition_lines_all prl ,' ||
                  ' po_requisition_headers_all prh ' ||
                  ' WHERE prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
            ' and prh.requisition_header_id = prl.requisition_header_id' ||
            ' and prl.requisition_line_id = prd.requisition_line_id' ||
            ' and prl.source_type_code = ''VENDOR''' ||
            ' and pd.req_distribution_id = prd.distribution_id' ||
            ' AND pll.line_location_id = pd.line_location_id' ||
            ' and rsl.po_line_location_id = pll.line_location_id'||
            ' AND rsl.shipment_header_id = rsh.shipment_header_id ' ||
            ' AND rsh.shipment_header_id = rhi.receipt_header_id' ||
            ' and prh.segment1 = '||''''||l_req_number||''''||
            ' and prl.line_num='||l_line_num||
            ' and prh.org_id = '||l_operating_id ||
            ' ) ' ||
            'union'||
            ' SELECT DISTINCT rhi.* ' ||
' from    rcv_headers_interface rhi ' ||
' WHERE   exists ' ||
     ' (SELECT 3 ' ||
        ' from    rcv_transactions_interface rti , ' ||
        ' po_line_locations_all pll , ' ||
                ' po_lines_all pl , ' ||
                ' po_headers_all ph , ' ||
                ' po_distributions_all pd,' ||
                ' 	        po_req_distributions_all prd ,' ||
' 	        po_requisition_lines_all prl ,' ||
' 	        po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
          ' and prh.requisition_header_id = prl.requisition_header_id' ||
            ' and prl.requisition_line_id = prd.requisition_line_id' ||
            ' and prl.source_type_code = ''VENDOR''' ||
            ' and pd.req_distribution_id = prd.distribution_id' ||
            ' and pd.po_header_id=ph.po_header_id' ||
            ' AND pl.po_header_id = ph.po_header_id' ||
            ' AND pll.po_line_id  = pl.po_line_id ' ||
            ' AND pll.line_location_id = pd.line_location_id' ||
            ' AND pd.po_line_id=pl.po_line_id'||
            ' AND rti.po_header_id = ph.po_header_id ' ||
            ' AND rti.po_line_location_id = pll.line_location_id ' ||--Bug#6882986
            ' AND rti.po_header_id is not null ' ||
            ' AND rhi.header_interface_id = rti.header_interface_id ' ||
            ' and prh.segment1 = '||''''||l_req_number||''''||
            ' and prl.line_num='||l_line_num||
            ' and prh.org_id = '||l_operating_id||
            ' ) ';

p_sql(20) := ' SELECT DISTINCT rti.*' ||
' from    rcv_transactions_interface rti ' ||
' WHERE   exists ' ||
' (SELECT 1 ' ||
        ' from   po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND rti.po_header_id = ph.po_header_id' ||
   ' AND rti.po_line_location_id = pll.line_location_id ' ||--Bug#6882986
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' )  ';

p_sql(21) := ' SELECT DISTINCT pie.* ' ||
 ' from    po_interface_errors pie , ' ||
 ' rcv_transactions_interface rti , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        ' po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' AND rti.po_header_id=pll.po_header_id'||
   ' AND rti.po_line_location_id = pll.line_location_id ' ||--Bug#6882986
   ' AND (pie.interface_transaction_id=rti.interface_transaction_id OR '||
        'pie.interface_line_id   = rti.interface_transaction_id)';

p_sql(22) := ' select distinct msi.*' ||
' from po_requisition_lines_all prl,' ||
  ' po_requisition_headers_all prh,' ||
       ' mtl_system_items msi' ||
       ' where prh.segment1 = '||''''||l_req_number||''''||
 ' and prh.org_id = '||l_operating_id||
   ' and prl.line_num='||l_line_num||
   ' and prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.source_type_code = ''VENDOR''' ||
   ' and prl.item_id = msi.inventory_item_id' ||
   ' and prl.destination_organization_id = msi.organization_id ';

       p_sql(23) := ' SELECT distinct mmt.* ' ||
' from    mtl_material_transactions mmt , ' ||
' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' rcv_transactions rt,' ||--Bug#6882986
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND pll.line_location_id = rt.po_line_location_id' ||--Bug#6882986
   ' AND ph.po_header_id = rt.po_header_id' ||--Bug#6882986
   ' AND pl.po_line_id = rt.po_line_id' ||--Bug#6882986
   ' AND mmt.rcv_transaction_id = rt.transaction_id' ||--Bug#6882986
  ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(24) := ' SELECT distinct mtt.transaction_type_id , ' ||
' mtt.transaction_type_name , ' ||
        ' mtt.transaction_source_type_id , ' ||
        ' mtt.transaction_action_id , ' ||
        ' mtt.user_defined_flag , ' ||
        ' mtt.disable_date ' ||
        ' from    mtl_transaction_types mtt ' ||
' WHERE   exists ' ||
' (SELECT 1 ' ||
        ' from    mtl_material_transactions mmt , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' rcv_transactions rt,' ||--Bug#6882986
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND pll.line_location_id = rt.po_line_location_id' ||--Bug#6882986
   ' AND ph.po_header_id = rt.po_header_id' ||--Bug#6882986
   ' AND pl.po_line_id = rt.po_line_id' ||--Bug#6882986
   ' AND mmt.rcv_transaction_id = rt.transaction_id' ||--Bug#6882986
  ' AND mtt.transaction_type_id        = mmt.transaction_type_id   ' ||
  ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' ) ' ||
        ' OR exists ' ||
     ' (SELECT 2 ' ||
        ' from    mtl_material_transactions_temp mmtt , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' rcv_transactions rt,' ||--Bug#6882986
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND pll.line_location_id = rt.po_line_location_id' ||--Bug#6882986
   ' AND ph.po_header_id = rt.po_header_id' ||--Bug#6882986
   ' AND pl.po_line_id = rt.po_line_id' ||--Bug#6882986
   ' AND mmtt.rcv_transaction_id = rt.transaction_id' ||--Bug#6882986
   ' and  mmtt.transaction_source_id      = ph.po_header_id ' ||
  ' AND mtt.transaction_type_id        = mmtt.transaction_type_id   ' ||
  ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id ||
   ' )  ';

   /* p_sql(25) := ' SELECT DISTINCT mol.* ' ||
' from    mtl_txn_request_lines mol , ' ||
' rcv_transactions rt , ' ||
        ' rcv_shipment_lines rsl , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and rsl.po_line_location_id=pll.line_location_id' ||
   ' and mol.reference_id      = decode(mol.reference ,''SHIPMENT_LINE_ID'' , rt.shipment_line_id ,''PO_LINE_LOCATION_ID'' , rt.po_line_location_id , ''ORDER_LINE_ID'' , rt.oe_order_line_id) ' ||
' AND rt.shipment_line_id   = rsl.shipment_line_id ' ||
    ' AND mol.organization_id   = rt.organization_id ' ||
    ' AND mol.inventory_item_id = rsl.item_id' ||
    ' AND pll.line_location_id = pd.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;*/

  p_sql(25) := ' SELECT DISTINCT mol.* ' ||
' from    mtl_txn_request_lines mol , ' ||
' rcv_transactions rt , ' ||
        ' rcv_shipment_lines rsl , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and rsl.po_line_location_id=pll.line_location_id' ||
' AND rt.shipment_line_id   = rsl.shipment_line_id ' ||
    ' AND mol.organization_id   = rt.organization_id ' ||
    ' AND mol.inventory_item_id = rsl.item_id' ||
    ' and Nvl(mol.revision,0)=Nvl(rsl.item_revision,0) ' ||
    ' and mol.line_status = 7'||
    ' and mol.transaction_type_id=18'||
    ' AND pll.line_location_id = pd.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(26) := ' SELECT  DISTINCT mmtt.* ' ||
' from    mtl_material_transactions_temp mmtt, ' ||
' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' rcv_transactions rt,' ||--Bug#6882986
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.po_line_id  = pl.po_line_id' ||
   ' and mmtt.transaction_source_id = ph.po_header_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND pll.line_location_id = rt.po_line_location_id' ||--Bug#6882986
   ' AND ph.po_header_id = rt.po_header_id' ||--Bug#6882986
   ' AND pl.po_line_id = rt.po_line_id' ||--Bug#6882986
   ' AND mmtt.rcv_transaction_id = rt.transaction_id' ||--Bug#6882986
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(27) := ' SELECT DISTINCT ood.* ' ||
' from    org_organization_definitions ood, ' ||
' financials_system_params_all fsp, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND fsp.org_id      = ph.org_id ' ||
   ' AND ood.organization_id in (fsp.inventory_organization_id , pll.ship_to_organization_id) ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(28) := ' SELECT DISTINCT mp.* ' ||
' from    mtl_parameters mp ,' ||
' financials_system_params_all fsp,' ||
        ' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' AND fsp.org_id      = prh.org_id ' ||
   ' AND mp.organization_id in (fsp.inventory_organization_id , prl.destination_organization_id) ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(29) := ' SELECT DISTINCT rp.* ' ||
' from    rcv_parameters rp , ' ||
' financials_system_params_all fsp, ' ||
        ' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' AND fsp.org_id          = prh.org_id ' ||
   ' AND (rp.organization_id = fsp.inventory_organization_id ' ||
   ' OR rp.organization_id  = prl.destination_organization_id) ' ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(30) := ' SELECT DISTINCT psp.* ' ||
' from    po_system_parameters_all psp, ' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and psp.org_id  = prh.org_id ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(31) := ' SELECT  DISTINCT fsp.* ' ||
' from    financials_system_params_all fsp, ' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and fsp.org_id  = prh.org_id ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(32) := ' SELECT  distinct msn.* ' ||
 ' from    mtl_serial_numbers msn , ' ||
 ' mtl_unit_transactions mut , ' ||
        ' mtl_material_transactions mmt, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh,' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and  mmt.transaction_source_id      = ph.po_header_id ' ||
   ' AND mmt.transaction_source_type_id = 1 ' ||
   ' AND mut.transaction_id             = mmt.transaction_id ' ||
   ' AND msn.inventory_item_id          = mut.inventory_item_id ' ||
   ' AND msn.current_organization_id    = mut.organization_id ' ||
   ' AND msn.serial_number              = mut.serial_number ' ||
   ' and rsh.shipment_header_id = rt.shipment_header_id '||
   ' and rt.transaction_id = mmt.rcv_transaction_id '||
   ' and rt.po_line_location_id=pll.line_location_id'||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id ||
   ' UNION ALL ' ||
 ' SELECT  distinct msn.* ' ||
 ' from    mtl_serial_numbers msn , ' ||
 ' mtl_unit_transactions mut , ' ||
        ' mtl_material_transactions mmt, ' ||
        ' mtl_transaction_lot_numbers mtln, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and mmt.transaction_source_id      = ph.po_header_id ' ||
  ' AND mmt.transaction_source_type_id = 1 ' ||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
    ' AND mut.transaction_id             = mtln.serial_transaction_id '||
    ' AND msn.inventory_item_id          = mut.inventory_item_id ' ||
    ' AND msn.current_organization_id    = mut.organization_id ' ||
    ' AND msn.serial_number              = mut.serial_number ' ||
    ' and rsh.shipment_header_id = rt.shipment_header_id '||
      ' and rt.po_line_location_id=pll.line_location_id'||
' and rt.transaction_id = mmt.rcv_transaction_id '||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(33) := ' SELECT  DISTINCT msnt.* ' ||
' from    mtl_serial_numbers_temp msnt , ' ||
' mtl_material_transactions_temp mmtt, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and   mmtt.transaction_source_id = ph.po_header_id ' ||
   ' AND msnt.transaction_temp_id   = mmtt.transaction_temp_id ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' UNION ALL ' ||
' SELECT  DISTINCT msnt.* ' ||
' from    mtl_serial_numbers_temp msnt, ' ||
' mtl_material_transactions_temp mmtt, ' ||
        ' mtl_transaction_lots_temp mtln, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and   mmtt.transaction_source_id = ph.po_header_id ' ||
' AND mtln.transaction_temp_id   = mmtt.transaction_temp_id ' ||
    ' AND msnt.transaction_temp_id   = mtln.serial_transaction_temp_id ' ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(34) := ' SELECT  DISTINCT msni.* ' ||
' from    mtl_serial_numbers_interface msni , ' ||
' rcv_transactions_interface rti ' ||
        ' WHERE   exists ' ||
' (SELECT 1 ' ||
        ' from  po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' 	po_req_distributions_all prd ,' ||
' 	po_requisition_lines_all prl ,' ||
' 	po_requisition_headers_all prh ' ||
' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
' and prh.requisition_header_id = prl.requisition_header_id' ||
' and prl.requisition_line_id = prd.requisition_line_id' ||
' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pd.po_line_id=pl.po_line_id'||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND rti.po_header_id = ph.po_header_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id ||
   ' ) ' ||
   ' AND msni.product_transaction_id = rti.interface_transaction_id   ';


       p_sql(35) := ' SELECT  distinct mut.* ' ||
 ' from    mtl_unit_transactions mut , ' ||
 ' mtl_material_transactions mmt, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and mmt.transaction_source_id      = ph.po_header_id ' ||
   ' AND mmt.transaction_source_type_id = 1 ' ||
    ' AND mut.transaction_id             = mmt.transaction_id ' ||
     ' and rsh.shipment_header_id = rt.shipment_header_id '||
      ' and rt.po_line_location_id=pll.line_location_id'||
' and rt.transaction_id = mmt.rcv_transaction_id '||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' UNION ALL ' ||
 ' SELECT  distinct mut.* ' ||
 ' from    mtl_unit_transactions mut , ' ||
 ' mtl_material_transactions mmt , ' ||
        ' mtl_transaction_lot_numbers mtln, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and mmt.transaction_source_id      = ph.po_header_id ' ||
   ' AND mmt.transaction_source_type_id = 1 ' ||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
    ' AND mut.transaction_id             = mtln.serial_transaction_id '||
    ' and rsh.shipment_header_id = rt.shipment_header_id '||
      ' and rt.po_line_location_id=pll.line_location_id'||
' and rt.transaction_id = mmt.rcv_transaction_id '||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(36) := ' SELECT  distinct rss.* ' ||
 ' from    rcv_serials_supply rss , ' ||
 ' rcv_shipment_lines rsl , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and   rsl.po_header_id     = ph.po_header_id ' ||
   ' AND rss.shipment_line_id = rsl.shipment_line_id ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id '||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(37) := ' SELECT distinct  rst.* ' ||
 ' from    rcv_serial_transactions rst , ' ||
 ' rcv_shipment_lines rsl , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and   rsl.po_header_id     = ph.po_header_id ' ||
   ' AND rst.shipment_line_id = rsl.shipment_line_id ' ||
   ' and rsl.po_line_location_id=pll.line_location_id'||
   ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(38) := ' SELECT distinct  rsi.* ' ||
 ' from    rcv_serials_interface rsi , ' ||
 ' rcv_transactions_interface rti ' ||
        ' WHERE exists ' ||
 ' (SELECT 1 ' ||
        ' from  po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '  rcv_shipment_headers rsh, rcv_shipment_lines rsl '||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and rti.po_header_id = ph.po_header_id    ' ||
   ' and rsl.shipment_header_id = rsh.shipment_header_id '||
   ' and rsl.po_line_location_id = pll.line_location_id ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' ) ' ||
        ' AND rsi.interface_transaction_id    =
 rti.interface_transaction_id  ';

       p_sql(39) := ' SELECT distinct  mln.* ' ||
 ' from    mtl_lot_numbers mln , ' ||
 ' mtl_transaction_lot_numbers mtln ,' ||
        ' mtl_material_transactions mmt, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and mmt.transaction_source_id      = ph.po_header_id ' ||
   ' AND mmt.transaction_source_type_id = 1 ' ||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
    ' AND mtln.lot_number                = mln.lot_number ' ||
    ' AND mtln.inventory_item_id         = mln.inventory_item_id ' ||
    ' AND mtln.organization_id           = mln.organization_id ' ||
     ' and rsh.shipment_header_id = rt.shipment_header_id '||
     ' and rt.po_line_location_id=pll.line_location_id'||
 ' and rt.transaction_id = mmt.rcv_transaction_id '||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(40) := ' SELECT  distinct mtln.* ' ||
 ' from    mtl_transaction_lot_numbers mtln , ' ||
 ' mtl_material_transactions mmt , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and mmt.transaction_source_id      = ph.po_header_id ' ||
   ' AND mmt.transaction_source_type_id = 1 ' ||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
      ' and rsh.shipment_header_id = rt.shipment_header_id '||
      ' and rt.po_line_location_id=pll.line_location_id'||
' and rt.transaction_id = mmt.rcv_transaction_id '||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(41) := ' SELECT  distinct mtli.* ' ||
 ' from    mtl_transaction_lots_interface mtli , ' ||
 ' rcv_transactions_interface rti ' ||
        ' WHERE exists ' ||
 ' (SELECT 1 ' ||
        ' from po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and  rti.po_header_id = ph.po_header_id    ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id ||
   ' ) ' ||
   ' AND mtli.product_transaction_id = RTI.interface_transaction_id ';


       p_sql(42) := ' SELECT  distinct mtlt.* ' ||
 ' from    mtl_transaction_lots_temp mtlt , ' ||
 ' mtl_material_transactions_temp mmtt , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and mmtt.transaction_source_id      = ph.po_header_id ' ||
   ' AND mmtt.transaction_source_type_id = 1 ' ||
    ' AND mmtt.transaction_temp_id        = mtlt.transaction_temp_id ' ||
      ' and rsh.shipment_header_id = rt.shipment_header_id '||
     ' and rt.po_line_location_id=pll.line_location_id'||
 ' and rt.transaction_id = mmtt.rcv_transaction_id '||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(43) := ' SELECT  distinct rls.* ' ||
 ' from    rcv_lots_supply rls , ' ||
 ' rcv_shipment_lines rsl, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '  rcv_shipment_headers rsh '  ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and rsl.shipment_line_id = rls.shipment_line_id ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
   ' and rsl.po_line_location_id=pll.line_location_id' ||
   ' AND rsl.po_header_id     = ph.po_header_id ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(44) := ' SELECT  distinct rlt.* ' ||
 ' from    rcv_lot_transactions rlt , ' ||
 ' rcv_shipment_lines rsl , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '  rcv_shipment_headers rsh '  ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and rsl.po_header_id     = ph.po_header_id ' ||
   ' AND rsl.shipment_line_id = rlt.shipment_line_id ' ||
      ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
    ' and rsl.po_line_location_id=pll.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(45) := ' SELECT  distinct rli.* ' ||
 ' from    rcv_lots_interface rli , ' ||
 ' rcv_transactions_interface rti ' ||
        ' WHERE   rti.interface_transaction_id =
 rli.interface_transaction_id ' ||
 ' AND exists ' ||
    ' (SELECT 1 ' ||
        ' from po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and rti.po_header_id = ph.po_header_id ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' )  ';


RETURN;
END;

-------------------------------------------------------
-- Package to Build sqls for Receipt and OU combination
-------------------------------------------------------
PROCEDURE build_req_rcv_sql(p_receipt_num IN VARCHAR2,p_org_id IN NUMBER,p_sql IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list) IS

-- Initialize Local Variables.
   l_receipt_num    rcv_shipment_headers.receipt_num%TYPE     := p_receipt_num;
   l_org_id         rcv_shipment_headers.organization_id%TYPE := p_org_id;

BEGIN

    p_sql(1) := ' select distinct prh.*' ||
                ' from po_requisition_headers_all prh,' ||
                ' po_requisition_lines_all prl,' ||
                ' po_req_distributions_all prd,'||
                ' po_line_locations_all pll,po_distributions_all pd,'||
                ' rcv_shipment_lines rsl,rcv_shipment_headers rsh'||
                ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and prl.requisition_line_id = prd.requisition_line_id' ||
   ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pll.line_location_id = pd.line_location_id'||
   ' and rsl.po_line_location_id = pll.line_location_id'||
   ' and rsl.shipment_header_id = rsh.shipment_header_id'||
   ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
	 ' AND rsh.ship_to_org_id    ='||l_org_id;

       p_sql(2) := ' select distinct prl.*' ||
                ' from po_requisition_headers_all prh,' ||
                ' po_requisition_lines_all prl,' ||
                ' po_req_distributions_all prd,'||
                ' po_line_locations_all pll,po_distributions_all pd,'||
                ' rcv_shipment_lines rsl,rcv_shipment_headers rsh'||
                ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and prl.requisition_line_id = prd.requisition_line_id' ||
   ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pll.line_location_id = pd.line_location_id'||
   ' and rsl.po_line_location_id = pll.line_location_id'||
   ' and rsl.shipment_header_id = rsh.shipment_header_id'||
   ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
	 ' AND rsh.ship_to_org_id    ='||l_org_id;

   p_sql(3) := ' select distinct prd.*' ||
                ' from po_requisition_headers_all prh,' ||
                ' po_requisition_lines_all prl,' ||
                ' po_req_distributions_all prd,'||
                ' po_line_locations_all pll,po_distributions_all pd,'||
                ' rcv_shipment_lines rsl,rcv_shipment_headers rsh'||
                ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and prl.requisition_line_id = prd.requisition_line_id' ||
   ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pll.line_location_id = pd.line_location_id'||
   ' and rsl.po_line_location_id = pll.line_location_id'||
   ' and rsl.shipment_header_id = rsh.shipment_header_id'||
   ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
	 ' AND rsh.ship_to_org_id    ='||l_org_id;


p_sql(4) := ' SELECT  distinct ph.* ' ||' from    po_headers_all ph,rcv_shipment_lines rsl,rcv_shipment_headers rsh ' ||
		' WHERE   rsh.shipment_header_id=rsl.shipment_header_id' ||
		' and rsl.po_header_id=ph.po_header_id' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id;

p_sql(5) := ' SELECT  distinct pl.* ' ||' from    po_lines_all pl,rcv_shipment_lines rsl, ' ||
		' rcv_shipment_headers rsh ' ||' WHERE  pl.po_line_id=rsl.po_line_id' ||
		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||' AND rsh.receipt_num='||''''||l_receipt_num||'''' ||
	       ' AND rsh.ship_to_org_id    ='||l_org_id;

p_sql(6) := ' SELECT distinct  pll.* ' ||' from    po_line_locations_all pll , ' ||
		' rcv_shipment_lines rsl, ' ||' rcv_shipment_headers rsh' ||
        	' WHERE  rsl.po_line_location_id= pll.line_location_id' ||
		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id;

p_sql(7) := ' SELECT  distinct pd.* ' ||' from    po_line_locations_all pll , ' ||
		' po_distributions_all pd,' ||' rcv_shipment_lines rsl, ' ||
        	' rcv_shipment_headers rsh ' ||' WHERE   pll.line_location_id = pd.line_location_id' ||
		' and rsl.po_line_location_id=pll.line_location_id' ||
		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||' AND rsh.ship_to_org_id    ='||l_org_id;

p_sql(8) := ' SELECT  distinct gcc.* ' ||' from    gl_code_combinations gcc , ' ||
		' po_line_locations_all pll , ' ||' po_distributions_all pd ,' ||
        	' rcv_shipment_lines rsl, ' ||' rcv_shipment_headers rsh' ||
        	' WHERE   gcc.summary_flag = ''N'' ' ||' AND gcc.template_id is null ' ||
    		' AND pll.line_location_id = pd.line_location_id' ||
    		' AND pll.line_location_id = rsl.po_line_location_id ' ||
    		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
    		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id ||
		' and gcc.code_combination_id in (pd.accrual_account_id '||
		', pd.budget_account_id , pd.VARIANCE_ACCOUNT_ID , pd.code_combination_id)  ';

p_sql(9) := ' SELECT  distinct rrsl.* ' ||' from    rcv_receiving_sub_ledger rrsl , ' ||
		' rcv_transactions rt , ' ||' rcv_shipment_headers rsh ' ||
        	' WHERE   rsh.receipt_num         ='||''''||l_receipt_num||'''' ||' AND rsh.ship_to_org_id      ='||l_org_id ||
    		' AND rt.shipment_header_id   = rsh.shipment_header_id ' ||
    		' AND rrsl.rcv_transaction_id = rt.transaction_id   ';

/*p_sql(10) := ' SELECT  distinct id.* ' ||' from    ap_invoice_distributions_all id , ' ||
		' po_line_locations_all pll , ' ||' po_distributions_all pd ,' ||
        	' rcv_shipment_lines rsl,rcv_shipment_headers rsh ' ||
        	' WHERE  pll.line_location_id  = pd.line_location_id' ||
		' and pll.line_location_id = rsl.po_line_location_id' ||
		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id ||
		' AND id.po_distribution_id = pd.po_distribution_id ';*/

p_sql(10) := ' SELECT  distinct id.* ' ||' from    ap_invoice_lines_all id , ' ||
		' po_line_locations_all pll ,'||
        	' rcv_transactions rt,rcv_shipment_headers rsh ' ||
        	' WHERE  pll.line_location_id = rt.po_line_location_id' ||
		' and rsh.shipment_header_id=rt.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id ||
		' and id.rcv_transaction_id=rt.transaction_id';

p_sql(11) := ' SELECT  distinct ai.* ' ||' from    ap_invoices_all ai , ' ||
		' ap_invoice_distributions_all id , ' ||' po_line_locations_all pll , ' ||
		' po_distributions_all pd ,' ||' rcv_shipment_lines rsl, ' ||
        	' rcv_shipment_headers rsh' ||' WHERE pll.line_location_id  = pd.line_location_id' ||
		' and pll.line_location_id = rsl.po_line_location_id' ||
		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id ||
		' AND id.po_distribution_id = pd.po_distribution_id ' ||
		' AND ai.invoice_id         = id.invoice_id ';

p_sql(12) := ' SELECT distinct ili.* ' ||' from    ap_invoice_lines_interface ili , ' ||
		' po_headers_all ph,' ||' rcv_shipment_lines rsl, ' ||
		' rcv_shipment_headers rsh ' ||' WHERE   ph.po_header_id = rsl.po_header_id' ||
		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id ||
		' AND ili.po_header_id = ph.po_header_id ';

p_sql(13) := ' SELECT  distinct ihi.* ' ||' from    ap_invoices_interface ihi , ' ||
		' ap_invoice_lines_interface ili , ' ||' po_headers_all ph,' ||
        	' rcv_shipment_lines rsl, ' ||' rcv_shipment_headers rsh ' ||
        	' WHERE   ph.po_header_id = rsl.po_header_id' ||
        	' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id ||
		' AND ili.po_header_id = ph.po_header_id ' ||
		' AND ihi.invoice_id   = ili.invoice_id ';

p_sql(14) := ' SELECT DISTINCT rsh.* ' ||' from    rcv_shipment_lines rsl , ' ||
		' rcv_shipment_headers rsh ' ||' WHERE   rsh.shipment_header_id =rsl.shipment_header_id ' ||
		' AND rsh.receipt_num        ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id     ='||l_org_id ||
    		' AND rsl.shipment_header_id = rsh.shipment_header_id ' ||
    		' ORDER BY rsh.shipment_header_id ';

p_sql(15) := ' SELECT DISTINCT rsl.* ' ||' from    rcv_shipment_lines rsl , ' ||
		' rcv_shipment_headers rsh ' ||' WHERE   rsh.shipment_header_id =rsl.shipment_header_id ' ||
		' AND rsh.receipt_num        ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id     ='||l_org_id ||
		' AND rsl.shipment_header_id = rsh.shipment_header_id  ';

p_sql(16) := ' SELECT  distinct rt.* ' ||' from    rcv_transactions rt , ' ||
		' rcv_shipment_headers rsh ' ||' WHERE   rsh.receipt_num      ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id   ='||l_org_id ||
		' AND rt.shipment_header_id=rsh.shipment_header_id  ';

p_sql(17) := ' SELECT distinct ms.* ' ||' from    mtl_supply ms , ' ||
		' rcv_shipment_headers rsh ' ||' WHERE   rsh.receipt_num      ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id   ='||l_org_id ||' AND ms.shipment_header_id=rsh.shipment_header_id   ';

p_sql(18) := ' SELECT  distinct rs.* ' ||' from    rcv_supply rs , ' ||
		' rcv_shipment_headers rsh ' ||' WHERE   rsh.receipt_num      ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id   ='||l_org_id ||' AND rs.shipment_header_id=rsh.shipment_header_id ';

p_sql(19) := ' SELECT  distinct rhi.* ' ||' from    rcv_headers_interface rhi ' ||
		' WHERE   receipt_num= '||''''||l_receipt_num||'''' ||' OR exists ' ||
     		' (SELECT 1'||
     		   ' from    rcv_shipment_lines rsl , ' ||
     		   ' rcv_shipment_headers rsh ' ||
     		   ' WHERE   rsh.receipt_num        = '||''''||l_receipt_num||'''' ||
        	   ' AND rsh.ship_to_org_id     ='||l_org_id ||
            	   ' AND rsl.shipment_header_id = rsh.shipment_header_id ' ||
                   ' AND rsh.shipment_header_id = rhi.receipt_header_id' ||
                ' ) ' ||
        	' OR exists ' ||
     		' (SELECT 2 ' ||
        	   ' from    rcv_transactions_interface rti , ' ||
        	   ' rcv_shipment_headers rsh ' ||
                   ' WHERE   rsh.shipment_header_id  =rti.shipment_header_id ' ||
                   ' AND rsh.receipt_num         = '||''''||l_receipt_num||'''' ||
                   ' AND rsh.ship_to_org_id      ='||l_org_id ||
                   ' AND rhi.header_interface_id = rti.header_interface_id' ||
        	' ) ';

p_sql(20) := ' SELECT DISTINCT rti.* ' ||' from    rcv_transactions_interface rti ' ||
		' WHERE   exists ' ||' (SELECT 1'||
        	' from    rcv_shipment_headers rsh ' ||
        	' WHERE   rsh.receipt_num        ='||''''||l_receipt_num||'''' ||
        	' AND rsh.ship_to_org_id     ='||l_org_id ||
        	' AND rti.shipment_header_id = rsh.shipment_header_id' ||
            	' ) ';

p_sql(21) := 'SELECT DISTINCT pie.* '||'  from    po_interface_errors pie , '||
             ' rcv_shipment_headers rsh'||' WHERE rsh.receipt_num='||''''||l_receipt_num||'''' ||
             ' AND rsh.ship_to_org_id='||l_org_id||' AND ( '||
             ' EXISTS (SELECT 1'||' from rcv_transactions_interface rti'||
             ' WHERE pie.interface_line_id   = rti.interface_transaction_id'||
             ' AND rsh.shipment_header_id=rti.shipment_header_id )'||
             ' OR EXISTS '||
             ' (SELECT 2 from rcv_headers_interface rhi'||
             ' WHERE pie.interface_header_id = rhi.header_interface_id '||
             ' AND rsh.shipment_header_id  = rhi.header_interface_id))';

p_sql(22) := ' SELECT DISTINCT msi.* ' ||' from    mtl_system_items msi , ' ||
		' rcv_shipment_headers rsh,' ||' rcv_shipment_lines rsl ' ||
        	' WHERE   rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    		' AND rsh.ship_to_org_id    ='||l_org_id||'and msi.inventory_item_id = rsl.item_id ' ||
    		' AND msi.organization_id   = rsl.to_organization_id ';

p_sql(23) := ' SELECT  distinct mmt.* ' ||
		' from    mtl_material_transactions mmt ,rcv_transactions rt,rcv_shipment_headers rsh ,' ||
		' po_headers_all ph ' ||' WHERE   mmt.transaction_source_id      = ph.po_header_id ' ||
		' AND mmt.transaction_source_type_id = 1'||
    		' and rsh.shipment_header_id=rt.shipment_header_id ' ||
    		' and rt.transaction_id=mmt.rcv_transaction_id' ||
    		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    		' AND rsh.ship_to_org_id    ='||l_org_id;

p_sql(24) := ' SELECT distinct  mtt.transaction_type_id , ' ||' mtt.transaction_type_name , ' ||
        	' mtt.transaction_source_type_id , ' ||
        	' mtt.transaction_action_id , ' ||
        	' mtt.user_defined_flag , ' ||
        	' mtt.disable_date ' ||
        	' from    mtl_transaction_types mtt ' ||
		' WHERE   exists ' ||
		' (SELECT 1'||
	        ' from    mtl_material_transactions mmt , ' ||
	        ' rcv_transactions rt,' ||
	        ' rcv_shipment_headers rsh ' ||
                ' WHERE   mmt.rcv_transaction_id         =rt.transaction_id ' ||
        	' AND rt.shipment_header_id          =rsh.shipment_header_id ' ||
        	    ' AND mmt.transaction_source_type_id = 1'||
        		' AND mtt.transaction_type_id        = mmt.transaction_type_id ' ||
            	' AND rsh.receipt_num                ='||''''||l_receipt_num||'''' ||
            	' AND rsh.ship_to_org_id             ='||l_org_id ||
            	' ) ' ||
        	' OR exists ' ||
     		' (SELECT 2 ' ||
        	' from    mtl_material_transactions_temp mmtt , ' ||
        	' po_headers_all ph ' ||
        	' WHERE   mmtt.transaction_source_id = ph.po_header_id ' ||
        	' AND mmtt.transaction_type_id   = mtt.transaction_type_id ' ||
            	' AND (ph.po_header_id in ' ||
            	' (SELECT DISTINCT po_header_id ' ||
                ' from    rcv_shipment_lines rsl, ' ||
                ' rcv_shipment_headers rsh ' ||
                        ' WHERE   rsh.shipment_header_id=rsl.shipment_header_id ' ||
                ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
                    ' AND rsh.ship_to_org_id    ='||l_org_id ||' ))' ||' ) ';

/*p_sql(25) := ' SELECT DISTINCT mol.* ' ||' from    mtl_txn_request_lines mol , ' ||
		' rcv_transactions rt , ' ||
		' rcv_shipment_lines rsl , ' ||
        	' rcv_shipment_headers rsh ' ||
        	' WHERE   mol.reference_id       = decode(mol.reference ,''SHIPMENT_LINE_ID'' , rt.shipment_line_id ,''PO_LINE_LOCATION_ID'' , rt.po_line_location_id , ''ORDER_LINE_ID'' , rt.oe_order_line_id) ' ||
		' AND rt.shipment_line_id    = rsl.shipment_line_id ' ||
 		' AND mol.organization_id    = rt.organization_id ' ||
    		' AND mol.inventory_item_id  = rsl.item_id ' ||
    		' AND rsl.shipment_header_id = rsh.shipment_header_id ' ||
    		' AND rsh.receipt_num        ='||''''||l_receipt_num||'''' ||
    		' AND rsh.ship_to_org_id     ='||l_org_id;*/

p_sql(25) := ' SELECT DISTINCT mol.* ' ||' from    mtl_txn_request_lines mol , ' ||
		' rcv_transactions rt , ' ||
		' rcv_shipment_lines rsl , ' ||
        	' rcv_shipment_headers rsh ' ||
        	' WHERE  rt.shipment_line_id    = rsl.shipment_line_id ' ||
 		' AND mol.organization_id    = rt.organization_id ' ||
    		' AND mol.inventory_item_id  = rsl.item_id ' ||
    		' and Nvl(mol.revision,0)=Nvl(rsl.item_revision,0) ' ||
    		' and mol.line_status = 7'||
		' and mol.transaction_type_id=18'||
    		' AND rsl.shipment_header_id = rsh.shipment_header_id ' ||
    		' AND rsh.receipt_num        ='||''''||l_receipt_num||'''' ||
    		' AND rsh.ship_to_org_id     ='||l_org_id;

        p_sql(26) := ' SELECT  distinct mmtt.* ' ||
' from    mtl_material_transactions_temp mmtt , ' ||
' po_headers_all ph ' ||
        ' WHERE   mmtt.transaction_source_id = ph.po_header_id ' ||
' AND (ph.po_header_id in ' ||
    ' (SELECT DISTINCT po_header_id ' ||
        ' from    rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
                ' WHERE   rsh.shipment_header_id=rsl.shipment_header_id ' ||
        ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
            ' AND rsh.ship_to_org_id    ='||l_org_id ||
            ' )) ';

            p_sql(27) := ' SELECT DISTINCT ood.* ' ||
' from    org_organization_definitions ood , ' ||
' po_line_locations_all pll , ' ||
        ' po_headers_all ph , ' ||
        ' financials_system_params_all fsp,' ||
        ' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh' ||
        ' WHERE   pll.po_header_id  = ph.po_header_id ' ||
' AND fsp.org_id      = ph.org_id ' ||
    ' AND ood.organization_id   in (fsp.inventory_organization_id , pll.ship_to_organization_id) ' ||
    ' AND pll.line_location_id = rsl.po_line_location_id' ||
    ' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
    ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id    ='||l_org_id;

        p_sql(28) := ' SELECT DISTINCT mp.* ' ||
' from    mtl_parameters mp , ' ||
' po_line_locations_all pll , ' ||
        ' po_headers_all ph , ' ||
        ' financials_system_params_all fsp,' ||
        ' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   pll.po_header_id = ph.po_header_id ' ||
' AND fsp.org_id      = ph.org_id ' ||
' AND mp.organization_id    in (fsp.inventory_organization_id , pll.ship_to_organization_id) ' ||
' AND pll.line_location_id = rsl.po_line_location_id' ||
' AND rsh.shipment_header_id=rsl.shipment_header_id ' ||
' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
' AND rsh.ship_to_org_id    ='||l_org_id;


    p_sql(29) := ' SELECT DISTINCT rp.* ' ||
' from    rcv_parameters rp , ' ||
' po_line_locations_all pll ,' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph, ' ||
        ' financials_system_params_all fsp ' ||
        ' WHERE   pl.po_header_id     = ph.po_header_id ' ||
' AND pll.po_line_id      = pl.po_line_id ' ||
    ' AND fsp.org_id          = ph.org_id ' ||
    ' AND (rp.organization_id = fsp.inventory_organization_id ' ||
    ' OR rp.organization_id  = pll.ship_to_organization_id) ' ||
     ' AND (pll.line_location_id in ' ||
    ' (SELECT DISTINCT rsl.po_line_location_id ' ||
        ' from    rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
                ' WHERE   rsh.shipment_header_id=rsl.shipment_header_id ' ||
        ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
            ' AND rsh.ship_to_org_id    ='||l_org_id ||
            ' ))';


p_sql(30):= ' SELECT  distinct psp.* ' ||
' from    po_system_parameters_all psp , ' ||
' po_headers_all ph,' ||
        ' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh' ||
        ' WHERE   psp.org_id = ph.org_id ' ||
' AND    ph.po_header_id = rsl.po_header_id' ||
' AND rsh.shipment_header_id=rsl.shipment_header_id ' ||
' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(31) := ' SELECT  distinct fsp.* ' ||
' from    financials_system_params_all fsp , ' ||
' po_headers_all ph, ' ||
        ' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh' ||
        ' WHERE   fsp.org_id = ph.org_id ' ||
' and ph.po_header_id = rsl.po_header_id' ||
' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(32) := ' SELECT  distinct msn.* ' ||
' from    mtl_serial_numbers msn , ' ||
' mtl_unit_transactions mut , ' ||
        ' rcv_transactions rt ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' mtl_material_transactions mmt ' ||
        ' WHERE   mmt.rcv_transaction_id         = rt.transaction_id ' ||
' AND rsh.shipment_header_id         =rt.shipment_header_id ' ||
    ' AND mmt.transaction_source_type_id = 1'||
    ' AND mut.transaction_id             = mmt.transaction_id ' ||
    ' AND msn.inventory_item_id          = mut.inventory_item_id ' ||
    ' AND msn.current_organization_id    = mut.organization_id ' ||
    ' AND msn.serial_number              = mut.serial_number ' ||
    ' AND rsh.receipt_num                ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id             ='||l_org_id ||
    ' UNION ALL ' ||
' SELECT  distinct msn.* ' ||
' from    mtl_serial_numbers msn , ' ||
' mtl_unit_transactions mut , ' ||
        ' rcv_transactions rt ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' mtl_material_transactions mmt, ' ||
        ' mtl_transaction_lot_numbers mtln ' ||
        ' WHERE   mmt.rcv_transaction_id         = rt.transaction_id ' ||
' AND rsh.shipment_header_id         =rt.shipment_header_id ' ||
    ' AND mmt.transaction_source_type_id = 1'||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
    ' AND mut.transaction_id             = mtln.serial_transaction_id ' ||
    ' AND msn.inventory_item_id          = mut.inventory_item_id ' ||
    ' AND msn.current_organization_id    = mut.organization_id ' ||
    ' AND msn.serial_number              = mut.serial_number ' ||
    ' AND rsh.receipt_num                ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id             ='||l_org_id;

p_sql(33):=' SELECT  distinct msnt.* ' ||
' from    mtl_serial_numbers_temp msnt , ' ||
' mtl_material_transactions_temp mmtt, ' ||
        ' po_headers_all ph,' ||
        ' rcv_shipment_lines rsl,' ||
        ' rcv_shipment_headers rsh' ||
        ' WHERE   mmtt.transaction_source_id = ph.po_header_id ' ||
' AND msnt.transaction_temp_id   = mmtt.transaction_temp_id ' ||
    ' AND rsl.po_header_id=ph.po_header_id' ||
    ' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
    ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
 ' AND rsh.ship_to_org_id    ='||l_org_id ||
' UNION ALL ' ||
' SELECT  msnt.* ' ||
' from    mtl_serial_numbers_temp msnt, ' ||
' mtl_material_transactions_temp mmtt , ' ||
        ' po_headers_all ph , ' ||
        ' mtl_transaction_lots_temp mtln,' ||
        ' rcv_shipment_lines rsl,' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   mmtt.transaction_source_id = ph.po_header_id ' ||
' AND mtln.transaction_temp_id   = mmtt.transaction_temp_id ' ||
    ' AND msnt.transaction_temp_id   = mtln.serial_transaction_temp_id ' ||
    ' AND ph.po_header_id = rsl.po_header_id' ||
    ' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(34) := ' SELECT  distinct msni.* ' ||
' from    mtl_serial_numbers_interface msni , ' ||
' rcv_transactions_interface rti ,' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rsh.receipt_num             ='||''''||l_receipt_num||'''' ||
' AND rsh.ship_to_org_id          ='||l_org_id ||
    ' AND rti.shipment_header_id      =rsh.shipment_header_id ' ||
    ' AND msni.product_transaction_id = rti.interface_transaction_id';

    p_sql(35):=' SELECT  distinct mut.* ' ||
' from    mtl_unit_transactions mut , ' ||
' rcv_transactions rt ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' mtl_material_transactions mmt ' ||
        ' WHERE   mmt.rcv_transaction_id         = rt.transaction_id ' ||
' AND rsh.shipment_header_id         =rt.shipment_header_id ' ||
    ' AND mmt.transaction_source_type_id = 1'||
    ' AND mut.transaction_id             = mmt.transaction_id ' ||
    ' AND rsh.receipt_num                ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id             ='||l_org_id ||
    ' UNION ALL ' ||
' SELECT  mut.* ' ||
' from    mtl_unit_transactions mut, ' ||
' rcv_transactions rt ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' mtl_material_transactions mmt , ' ||
        ' mtl_transaction_lot_numbers mtln ' ||
        ' WHERE   mmt.rcv_transaction_id         = rt.transaction_id ' ||
' AND rsh.shipment_header_id         =rt.shipment_header_id ' ||
    ' AND mmt.transaction_source_type_id = 1'||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
    ' AND mut.transaction_id             = mtln.serial_transaction_id ' ||
    ' AND rsh.receipt_num                ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id             ='||l_org_id ;


    p_sql(36):=' SELECT distinct  rss.* ' ||
' from    rcv_serials_supply rss , ' ||
' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rss.shipment_line_id  = rsl.shipment_line_id ' ||
' AND rsh.shipment_header_id=rsl.shipment_header_id ' ||
    ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(37):=' SELECT distinct  rst.* ' ||
' from    rcv_serial_transactions rst , ' ||
' rcv_shipment_lines rsl , ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rst.shipment_line_id  = rsl.shipment_line_id ' ||
' AND rsh.shipment_header_id=rsl.shipment_header_id ' ||
    ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(38):=' SELECT  distinct rsi.* ' ||
' from    rcv_serials_interface rsi , ' ||
' rcv_transactions_interface rti , ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rti.shipment_header_id       = rsh.shipment_header_id ' ||
' AND rsh.receipt_num              ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id           ='||l_org_id ||
    ' AND rsi.interface_transaction_id = rti.interface_transaction_id  ';

    p_sql(39):=' SELECT  distinct mln.* ' ||
' from    mtl_lot_numbers mln , ' ||
' mtl_transaction_lot_numbers mtln , ' ||
        ' rcv_transactions rt ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' mtl_material_transactions mmt ' ||
        ' WHERE   mmt.rcv_transaction_id         = rt.transaction_id ' ||
' AND rsh.shipment_header_id         =rt.shipment_header_id ' ||
    ' AND mmt.transaction_source_type_id = 1'||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
    ' AND mtln.lot_number                = mln.lot_number ' ||
    ' AND mtln.inventory_item_id         = mln.inventory_item_id ' ||
    ' AND mtln.organization_id           = mln.organization_id ' ||
    ' AND rsh.receipt_num                ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id             ='||l_org_id;

    p_sql(40):=' SELECT  distinct mtln.* ' ||
' from    mtl_transaction_lot_numbers mtln , ' ||
' rcv_transactions rt ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' mtl_material_transactions mmt ' ||
        ' WHERE   mmt.rcv_transaction_id         = rt.transaction_id ' ||
' AND rsh.shipment_header_id         =rt.shipment_header_id ' ||
    ' AND mmt.transaction_source_type_id = 1'||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
    ' AND rsh.receipt_num                ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id             ='||l_org_id;

p_sql(41):=' SELECT  distinct mtli.* ' ||
' from    mtl_transaction_lots_interface mtli , ' ||
' rcv_transactions_interface rti ,' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rti.shipment_header_id      = rsh.shipment_header_id ' ||
' AND rsh.receipt_num             ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id          ='||l_org_id  ||
    ' AND mtli.product_transaction_id = RTI.interface_transaction_id';

    p_sql(42):=' SELECT distinct  mtlt.* ' ||
' from    mtl_transaction_lots_temp mtlt , ' ||
' mtl_material_transactions_temp mmtt ,' ||
        ' po_headers_all ph ' ||
        ' WHERE   mmtt.transaction_source_id      = ph.po_header_id ' ||
' AND mmtt.transaction_source_type_id = 1 ' ||
    ' AND mmtt.transaction_temp_id        = mtlt.transaction_temp_id ' ||
    ' AND (ph.po_header_id in ' ||
    ' (SELECT DISTINCT po_header_id ' ||
        ' from    rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
                ' WHERE   rsh.shipment_header_id=rsl.shipment_header_id ' ||
        ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
            ' AND rsh.ship_to_org_id  ='||l_org_id ||' ))';

        p_sql(43):=' SELECT  distinct rls.* ' ||
' from    rcv_lots_supply rls , ' ||
' rcv_shipment_lines rsl , ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rsl.shipment_line_id  = rls.shipment_line_id ' ||
' AND rsh.shipment_header_id=rsl.shipment_header_id ' ||
    ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(44):=' SELECT  distinct rlt.* ' ||
' from    rcv_lot_transactions rlt , ' ||
' rcv_shipment_lines rsl , ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rsl.shipment_line_id  = rlt.shipment_line_id ' ||
' AND rsh.shipment_header_id=rsl.shipment_header_id ' ||
    ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(45):=' SELECT distinct rli.* ' ||
' from    rcv_lots_interface rli , ' ||
' rcv_transactions_interface rti,' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rti.interface_transaction_id = rli.interface_transaction_id ' ||
' AND rti.shipment_header_id       =rsh.shipment_header_id ' ||
    ' AND rsh.receipt_num              ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id           ='||l_org_id;

RETURN;
END;  -- END build_req_rcv_sql

----------------------------------------------------------------
-- Package to Build sqls for Receipt,Org,Req and OU combination
----------------------------------------------------------------
PROCEDURE build_req_all_sql(p_operating_id  IN NUMBER,
                           p_req_number     IN VARCHAR2,
                           p_line_num       IN NUMBER,
                           p_receipt_number IN VARCHAR2,
                           p_org_id         IN NUMBER,
                           p_sql            IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list)
IS

-- Initialize Local Variables.
l_operating_id   po_requisition_headers_all.org_id%TYPE     := p_operating_id;
l_req_number     po_requisition_headers_all.segment1%TYPE   := p_req_number;
l_receipt_number rcv_shipment_headers.receipt_num%TYPE      := p_receipt_number;
l_line_num       VARCHAR2(1000)                             := p_line_num;
l_org_id         rcv_shipment_headers.organization_id%TYPE  := p_org_id;

BEGIN

-- Build the condition based on the input
IF p_line_num IS NULL THEN
   l_line_num     := ' prl.line_num ';
END IF;

  p_sql(1) := ' select distinct prh.*' ||
 ' from po_requisition_headers_all prh,' ||
  ' po_requisition_lines_all prl' ||
       ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prh.org_id = '||l_operating_id||
   ' and prl.line_num='||l_line_num||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and prl.source_type_code = ''VENDOR'' ';

       p_sql(2) := ' select distinct prl.*' ||
 ' from po_requisition_lines_all prl,' ||
  ' po_requisition_headers_all prh, ' ||
  ' rcv_shipment_headers rsh, rcv_shipment_lines rsl,
 po_line_locations_all pll ' ||
       ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
       ' and pll.line_location_id = prl.line_location_id ' ||
       ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
       ' and rsl.po_line_location_id = pll.line_location_id ' ||
          ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
 ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prh.org_id = '||l_operating_id||
   ' and prl.line_num='||l_line_num||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.source_type_code = ''VENDOR''' ||
 ' order by prl.requisition_line_id ';

    p_sql(3) := ' select distinct prd.*' ||
 ' from po_req_distributions_all prd ,' ||
  ' po_requisition_lines_all prl ,' ||
       ' po_requisition_headers_all prh,' ||
         ' rcv_shipment_headers rsh, rcv_shipment_lines rsl,
 po_line_locations_all pll ' ||
       ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.requisition_line_id = prd.requisition_line_id' ||
   ' and prl.source_type_code = ''VENDOR''' ||
      'and pll.line_location_id = prl.line_location_id ' ||
       'and  rsh.shipment_header_id = rsl.shipment_header_id ' ||
       'and  rsl.po_line_location_id = pll.line_location_id ' ||
          ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prh.org_id = '||l_operating_id||
   ' and prl.line_num='||l_line_num||
   ' order by prd.distribution_id ';

    p_sql(4) := ' SELECT  distinct ph.* ' ||
 ' from    po_headers_all ph,' ||
 ' po_distributions_all pd,' ||
        ' po_req_distributions_all prd ,' ||
        '     po_requisition_lines_all prl ,' ||
 ' po_requisition_headers_all prh,' ||
 ' rcv_shipment_headers rsh, rcv_shipment_lines rsl '||
        ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.requisition_line_id = prd.requisition_line_id' ||
   ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id '||
   'and rsl.po_header_id = ph.po_header_id ' ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(5) := ' SELECT  distinct pl.* ' ||
 ' from    po_lines_all pl , ' ||
 ' po_headers_all ph,' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh,' ||
 ' rcv_shipment_headers rsh, rcv_shipment_lines rsl '||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
      ' and rsh.shipment_header_id = rsl.shipment_header_id '||
   ' and rsl.po_line_id = pl.po_line_id ' ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
      ' and prh.org_id = '||l_operating_id;


    p_sql(6) := ' SELECT  distinct pll.* ' ||
 ' from    po_line_locations_all pll , ' ||
 ' po_lines_all pl , ' ||
        ' po_headers_all ph,' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh,' ||
 ' rcv_shipment_headers rsh, rcv_shipment_lines rsl '||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id ' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id ' || --Bug#6882986
      ' and  rsh.shipment_header_id = rsl.shipment_header_id '||
   ' and rsl.po_line_location_id = pll.line_location_id ' ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
      ' and prh.org_id = '||l_operating_id;


    p_sql(7) := ' SELECT  distinct pd.* ' ||
 ' from    po_line_locations_all pll , ' ||
 ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ,' ||
 ' rcv_shipment_headers rsh, rcv_shipment_lines rsl '||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id  ' ||
        'and  rsh.shipment_header_id = rsl.shipment_header_id '||
   'and rsl.po_line_location_id = pll.line_location_id ' ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


    p_sql(8) := ' SELECT  distinct gcc.* ' ||
 ' from    gl_code_combinations gcc , ' ||
 ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and gcc.summary_flag = ''N'' ' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND gcc.template_id is null ' ||
   ' AND gcc.code_combination_id in (pd.accrual_account_id ,
 pd.budget_account_id , pd.VARIANCE_ACCOUNT_ID ,
 pd.code_combination_id)' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(9) := ' SELECT  distinct rrsl.* ' ||
 ' from    rcv_receiving_sub_ledger rrsl , ' ||
 ' rcv_transactions rt , ' ||
        ' po_headers_all ph,' ||
        ' po_line_locations_all pll , ' ||--Bug#6882986
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 ' rcv_shipment_headers rsh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' and pll.po_header_id=ph.po_header_id' ||--Bug#6882986
   ' and pll.line_location_id=pd.line_location_id' ||--Bug#6882986
   ' and pll.line_location_id=rt.po_line_location_id' ||--Bug#6882986
   ' AND rt.po_header_id         = ph.po_header_id ' ||
   ' AND rrsl.rcv_transaction_id = rt.transaction_id' ||
   ' and rsh.shipment_header_id = rt.shipment_header_id ' ||
         ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       /*p_sql(10) := ' SELECT  distinct id.* ' ||
 ' from    ap_invoice_distributions_all id , ' ||
 ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_shipment_lines rsl ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and pll.line_location_id = rsl.po_line_location_id ' ||
   ' and rsl.shipment_header_id = rsh.shipment_header_id ' ||
   ' AND id.po_distribution_id = pd.po_distribution_id     ' ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;*/

  p_sql(10) := ' SELECT  distinct id.* ' ||
 ' from    ap_invoice_lines_all id , ' ||
 ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and pll.line_location_id = rt.po_line_location_id ' ||
   ' and rt.shipment_header_id = rsh.shipment_header_id ' ||
   ' AND id.po_distribution_id = pd.po_distribution_id     ' ||
   ' and id.po_line_location_id=pll.line_location_id'||' and id.po_line_id=pl.po_line_id'||
   ' and id.po_header_id=ph.po_header_id'||' and id.rcv_transaction_id=rt.transaction_id'||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(11) := ' SELECT  distinct ai.* ' ||
 ' from    ap_invoices_all ai , ' ||
 ' ap_invoice_distributions_all id , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_shipment_lines rsl ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND id.po_distribution_id = pd.po_distribution_id ' ||
   ' and pll.line_location_id = rsl.po_line_location_id ' ||
   ' and rsl.shipment_header_id = rsh.shipment_header_id ' ||
    ' AND ai.invoice_id         = id.invoice_id' ||
     ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(12) := ' SELECT  distinct ili.* ' ||
 ' from    ap_invoice_lines_interface ili , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_shipment_lines rsl ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and ili.po_header_id = ph.po_header_id   ' ||
        ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(13) := ' SELECT  distinct ihi.* ' ||
 ' from    ap_invoices_interface ihi , ' ||
 ' ap_invoice_lines_interface ili , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_shipment_lines rsl ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and ili.po_header_id = ph.po_header_id ' ||
   ' AND ihi.invoice_id    = ili.invoice_id  ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
   ' and rsl.po_line_location_id = pll.line_location_id ' ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(14) := ' SELECT DISTINCT rsh.* ' ||
 ' from    rcv_shipment_lines rsl , ' ||
 ' rcv_shipment_headers rsh, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
 ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
 ' and rsh.ship_to_org_id = '|| l_org_id ||
 ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and rsl.po_line_location_id=pll.line_location_id' ||
   ' AND rsl.shipment_header_id = rsh.shipment_header_id    ' ||
  ' AND pll.line_location_id = pd.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(15) := ' SELECT DISTINCT rsl.* ' ||
 ' from    rcv_shipment_lines rsl , ' ||
 ' rcv_shipment_headers rsh, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
 ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and rsl.po_line_location_id=pll.line_location_id' ||
   ' AND rsl.shipment_header_id = rsh.shipment_header_id    ' ||
  ' AND pll.line_location_id = pd.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(16) := ' SELECT DISTINCT rt.* ' ||
 ' from    rcv_transactions rt , ' ||
 ' rcv_shipment_headers rsh, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and rt.po_line_location_id=pll.line_location_id' ||
   ' AND rt.shipment_header_id = rsh.shipment_header_id    ' ||
  ' AND pll.line_location_id = pd.line_location_id' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(17) := ' SELECT  ms.* ' ||
 ' from    mtl_supply ms , ' ||
 ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ,' ||
 '   rcv_shipment_headers rsh, rcv_shipment_lines rsl'||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and ms.po_line_location_id=pll.line_location_id' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and rsl.shipment_header_id = rsh.shipment_header_id'||
   ' and rsl.po_line_location_id = ms.po_line_location_id'||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(18) := ' SELECT  rs.* ' ||
 ' from    rcv_supply rs , ' ||
 ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh , rcv_shipment_headers rsh,
 rcv_shipment_lines rsl ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 '  and prh.requisition_header_id = prl.requisition_header_id' ||
 '  and prl.requisition_line_id = prd.requisition_line_id' ||
 '  and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and rs.po_line_location_id=pll.line_location_id' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.po_line_location_id = rs.po_line_location_id' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

 p_sql(19) := ' SELECT  rhi.* ' ||
 ' from    rcv_headers_interface rhi ' ||
 ' WHERE   exists ' ||
 ' (SELECT 1 ' ||
        ' from    rcv_shipment_lines rsl , ' ||
          ' rcv_shipment_headers rsh, ' ||
                  ' po_line_locations_all pll , ' ||
                  ' po_lines_all pl , ' ||
                  ' po_headers_all ph , ' ||
                  ' po_distributions_all pd,' ||
                  ' po_req_distributions_all prd ,' ||
                  '           po_requisition_lines_all prl ,' ||
 ' po_requisition_headers_all prh ' ||
                  ' WHERE prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
            ' and prh.requisition_header_id =
 prl.requisition_header_id' ||
            ' and prl.requisition_line_id = prd.requisition_line_id' ||
            ' and prl.source_type_code = ''VENDOR''' ||
            ' and pd.req_distribution_id = prd.distribution_id' ||
            ' and pd.po_header_id=ph.po_header_id' ||
            ' AND pl.po_header_id = ph.po_header_id' ||
            ' AND pll.po_line_id  = pl.po_line_id ' ||
            ' AND pll.line_location_id = pd.line_location_id' ||
            ' and rsl.po_header_id = ph.po_header_id ' ||
            ' and rsl.po_line_location_id = pll.line_location_id'||--Bug#6882986
            ' AND rsl.shipment_header_id = rsh.shipment_header_id ' ||
            ' AND rsh.shipment_header_id = rhi.receipt_header_id' ||
            ' and prh.segment1 = '||''''||l_req_number||''''||
            ' and prl.line_num='||l_line_num||
            ' and prh.org_id = '||l_operating_id ||
            ' ) ' ||
        'union'||
            ' SELECT DISTINCT rhi.* ' ||
' from    rcv_headers_interface rhi ' ||
' WHERE   exists ' ||
     ' (SELECT 3 ' ||
        ' from    rcv_transactions_interface rti , ' ||
        ' po_line_locations_all pll , ' ||
                ' po_lines_all pl , ' ||
                ' po_headers_all ph , ' ||
                ' po_distributions_all pd,' ||
                '             po_req_distributions_all prd ,' ||
 '             po_requisition_lines_all prl ,' ||
 '             po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
          ' and prh.requisition_header_id = prl.requisition_header_id' ||
            ' and prl.requisition_line_id = prd.requisition_line_id' ||
            ' and prl.source_type_code = ''VENDOR''' ||
            ' and pd.req_distribution_id = prd.distribution_id' ||
            ' and pd.po_header_id=ph.po_header_id' ||
            ' AND pl.po_header_id = ph.po_header_id' ||
            ' AND pll.po_line_id  = pl.po_line_id ' ||
            ' AND pll.line_location_id = pd.line_location_id' ||
            ' AND rti.po_header_id = ph.po_header_id ' ||
            ' AND rti.po_line_location_id = pll.line_location_id ' ||----Bug#6882986
            ' AND rti.po_header_id is not null ' ||
            ' AND rhi.header_interface_id =
 rti.header_interface_id            ' ||
            ' and prh.segment1 = '||''''||l_req_number||''''||
            ' and prl.line_num='||l_line_num||
            ' and prh.org_id = '||l_operating_id||
            ' ) ';

 p_sql(20) := ' SELECT DISTINCT rti.*' ||
 ' from    rcv_transactions_interface rti ' ||
 ' WHERE   exists ' ||
 ' (SELECT 1 ' ||
        ' from   po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND rti.po_header_id = ph.po_header_id' ||
   ' AND rti.po_line_location_id = pll.line_location_id ' ||--Bug#6882986
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' )  '  ||
   'union'  ||
   ' select rti.*' ||
   ' from rcv_transactions_interface rti, rcv_shipment_headers rsh' ||
   ' where rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and rti.shipment_header_id = rsh.shipment_header_id ' ;

 p_sql(21) := ' SELECT DISTINCT pie.* ' ||
 ' from    po_interface_errors pie , ' ||
 ' rcv_transactions_interface rti , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        ' po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND rti.po_line_location_id = pll.line_location_id ' ||--Bug#6882986
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' AND rti.po_header_id=pll.po_header_id'||
   ' AND (pie.interface_transaction_id=rti.interface_transaction_id OR '||
        'pie.interface_line_id   = rti.interface_transaction_id)';

 p_sql(22) := ' select distinct msi.*' ||
 ' from po_requisition_lines_all prl,' ||
  ' po_requisition_headers_all prh,' ||
       ' mtl_system_items msi , po_line_locations_all pll, rcv_shipment_headers rsh, rcv_shipment_lines rsl ' ||
       ' where prh.segment1 = '||''''||l_req_number||''''||
 ' and prh.org_id = '||l_operating_id||
   ' and prl.line_num='||l_line_num||
   ' and prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.source_type_code = ''VENDOR''' ||
   ' and prl.item_id = msi.inventory_item_id' ||
   ' and prl.line_location_id = pll.line_location_id ' ||
   ' and pll.line_location_id = rsl.po_line_location_id ' ||
   ' and rsl.shipment_header_id = rsh.shipment_header_id ' ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prl.destination_organization_id = msi.organization_id ';

       p_sql(23) := ' SELECT  mmt.* ' ||
 ' from    mtl_material_transactions mmt , ' ||
 ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
 ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and rsh.shipment_header_id = rt.shipment_header_id' ||
   ' and rt.transaction_id = mmt.rcv_transaction_id '||
   ' AND rt.po_line_location_id = pll.line_location_id' ||--Bug#6882986
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and  mmt.transaction_source_id      = ph.po_header_id ' ||
  ' AND mmt.transaction_source_type_id = 1 ' ||
  ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(24) := ' SELECT  mtt.transaction_type_id , ' ||
 ' mtt.transaction_type_name , ' ||
        ' mtt.transaction_source_type_id , ' ||
        ' mtt.transaction_action_id , ' ||
        ' mtt.user_defined_flag , ' ||
        ' mtt.disable_date ' ||
        ' from    mtl_transaction_types mtt ' ||
 ' WHERE   exists ' ||
 ' (SELECT 1 ' ||
        ' from    mtl_material_transactions mmt , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and  mmt.transaction_source_id      = ph.po_header_id ' ||
  ' AND mmt.transaction_source_type_id = 1 ' ||
  ' AND mtt.transaction_type_id        = mmt.transaction_type_id   ' ||
  ' and rsh.shipment_header_id = rt.shipment_header_id' ||
  ' and rt.transaction_id = mmt.rcv_transaction_id '||
  ' AND rt.po_line_location_id = pll.line_location_id' ||--Bug#6882986
  ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
  ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' ) ' ||
        ' OR exists ' ||
     ' (SELECT 2 ' ||
        ' from    mtl_material_transactions_temp mmtt , ' ||
        ' mtl_material_transactions mmt ,'||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND rt.po_line_location_id = pll.line_location_id' ||--Bug#6882986
   ' and  mmt.transaction_source_id      = ph.po_header_id ' ||
  ' AND mmt.transaction_source_type_id = 1 ' ||
  ' AND mtt.transaction_type_id        = mmtt.transaction_type_id   ' ||
  ' and rsh.shipment_header_id = rt.shipment_header_id' ||
  ' and rt.transaction_id = mmtt.rcv_transaction_id ' ||
  ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
  ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id ||
   ' )  ';

   /* p_sql(25) := ' SELECT DISTINCT mol.* ' ||
 ' from    mtl_txn_request_lines mol , ' ||
 ' rcv_transactions rt , ' ||
        ' rcv_shipment_lines rsl , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh '||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and rsl.po_line_location_id=pll.line_location_id' ||
   ' and mol.reference_id      = decode(mol.reference
 ,''SHIPMENT_LINE_ID'' , rt.shipment_line_id ,''PO_LINE_LOCATION_ID'' ,
 rt.po_line_location_id , ''ORDER_LINE_ID'' , rt.oe_order_line_id) ' ||
 ' AND rt.shipment_line_id   = rsl.shipment_line_id ' ||
    ' AND mol.organization_id   = rt.organization_id ' ||
    ' AND mol.inventory_item_id = rsl.item_id' ||
    ' AND pll.line_location_id = pd.line_location_id' ||
    ' and rt.shipment_header_id = rsh.shipment_header_id '||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id; */

          p_sql(25) := ' SELECT DISTINCT mol.* ' ||
    ' from    mtl_txn_request_lines mol , ' ||
    ' rcv_transactions rt , ' ||
           ' rcv_shipment_lines rsl , ' ||
           ' po_line_locations_all pll , ' ||
           ' po_distributions_all pd,' ||
           '     po_req_distributions_all prd ,' ||
    '     po_requisition_lines_all prl ,' ||
    '     po_requisition_headers_all prh, ' ||
    '   rcv_shipment_headers rsh '||
    ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.requisition_line_id = prd.requisition_line_id' ||
    ' and prl.source_type_code = ''VENDOR''' ||
      ' and pd.req_distribution_id = prd.distribution_id' ||
      ' and rsl.po_line_location_id=pll.line_location_id' ||
    ' AND rt.shipment_line_id   = rsl.shipment_line_id ' ||
       ' AND mol.organization_id   = rt.organization_id ' ||
       ' AND mol.inventory_item_id = rsl.item_id' ||
       ' and Nvl(mol.revision,0)=Nvl(rsl.item_revision,0) ' ||
    		' and mol.line_status = 7'||
		' and mol.transaction_type_id=18'||
       ' AND pll.line_location_id = pd.line_location_id' ||
       ' and rt.shipment_header_id = rsh.shipment_header_id '||
       ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
      ' and rsh.ship_to_org_id = '|| l_org_id ||
      ' and prh.segment1 = '||''''||l_req_number||''''||
      ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(26) := ' SELECT  mmtt.* ' ||
 ' from    mtl_material_transactions_temp mmtt, ' ||
 ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 ' rcv_shipment_headers rsh, rcv_transactions rt ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id' ||
   ' and mmtt.transaction_source_id = ph.po_header_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND rt.po_line_location_id = pll.line_location_id' ||--Bug#6882986
   ' and rsh.shipment_header_id = rt.shipment_header_id '||
   ' and rt.transaction_id = mmtt.rcv_transaction_id '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(27) := ' SELECT DISTINCT ood.* ' ||
 ' from    org_organization_definitions ood, ' ||
 ' financials_system_params_all fsp, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND fsp.org_id      = ph.org_id ' ||
   ' AND ood.organization_id in (fsp.inventory_organization_id ,
 pll.ship_to_organization_id) ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(28) := ' SELECT DISTINCT mp.* ' ||
 ' from    mtl_parameters mp ,' ||
 ' financials_system_params_all fsp,' ||
        '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' AND fsp.org_id      = prh.org_id ' ||
   ' AND mp.organization_id in (fsp.inventory_organization_id ,
 prl.destination_organization_id) ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(29) := ' SELECT DISTINCT rp.* ' ||
 ' from    rcv_parameters rp , ' ||
 ' financials_system_params_all fsp, ' ||
        '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' AND fsp.org_id          = prh.org_id ' ||
   ' AND (rp.organization_id = fsp.inventory_organization_id ' ||
   ' OR rp.organization_id  = prl.destination_organization_id) ' ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(30) := ' SELECT  psp.* ' ||
 ' from    po_system_parameters_all psp, ' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and psp.org_id  = prh.org_id ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(31) := ' SELECT  fsp.* ' ||
 ' from    financials_system_params_all fsp, ' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and fsp.org_id  = prh.org_id ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(32) := ' SELECT  msn.* ' ||
 ' from    mtl_serial_numbers msn , ' ||
 ' mtl_unit_transactions mut , ' ||
        ' mtl_material_transactions mmt, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh,' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and  mmt.transaction_source_id      = ph.po_header_id ' ||
   ' AND mmt.transaction_source_type_id = 1 ' ||
   ' AND mut.transaction_id             = mmt.transaction_id ' ||
   ' AND msn.inventory_item_id          = mut.inventory_item_id ' ||
   ' AND msn.current_organization_id    = mut.organization_id ' ||
   ' AND msn.serial_number              = mut.serial_number ' ||
   ' and rsh.shipment_header_id = rt.shipment_header_id '||
   ' and rt.transaction_id = mmt.rcv_transaction_id '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id ||
   ' UNION ALL ' ||
 ' SELECT  msn.* ' ||
 ' from    mtl_serial_numbers msn , ' ||
 ' mtl_unit_transactions mut , ' ||
        ' mtl_material_transactions mmt, ' ||
        ' mtl_transaction_lot_numbers mtln, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and mmt.transaction_source_id      = ph.po_header_id ' ||
  ' AND mmt.transaction_source_type_id = 1 ' ||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
    ' AND mut.transaction_id             = mtln.serial_transaction_id '||
    ' AND msn.inventory_item_id          = mut.inventory_item_id ' ||
    ' AND msn.current_organization_id    = mut.organization_id ' ||
    ' AND msn.serial_number              = mut.serial_number ' ||
    ' and rsh.shipment_header_id = rt.shipment_header_id '||
   ' and rt.transaction_id = mmt.rcv_transaction_id '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(33) := ' SELECT  msnt.* ' ||
 ' from    mtl_serial_numbers_temp msnt , ' ||
 ' mtl_material_transactions_temp mmtt, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and   mmtt.transaction_source_id = ph.po_header_id ' ||
   ' AND msnt.transaction_temp_id   = mmtt.transaction_temp_id ' ||
   ' and rsh.shipment_header_id = rt.shipment_header_id '||
   ' and rt.transaction_id = mmtt.rcv_transaction_id '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' UNION ALL ' ||
 ' SELECT  msnt.* ' ||
 ' from    mtl_serial_numbers_temp msnt, ' ||
 ' mtl_material_transactions_temp mmtt, ' ||
        ' mtl_transaction_lots_temp mtln, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ,' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and   mmtt.transaction_source_id = ph.po_header_id ' ||
 ' AND mtln.transaction_temp_id   = mmtt.transaction_temp_id ' ||
    ' AND msnt.transaction_temp_id   = mtln.serial_transaction_temp_id
 ' ||
     ' and rsh.shipment_header_id = rt.shipment_header_id '||
   ' and rt.transaction_id = mmtt.rcv_transaction_id '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(34) := ' SELECT  msni.* ' ||
 ' from    mtl_serial_numbers_interface msni , ' ||
 ' rcv_transactions_interface rti ' ||
        ' WHERE   exists ' ||
 ' (SELECT 1 ' ||
        ' from  po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_shipment_lines rsl' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' AND rti.po_header_id = ph.po_header_id' ||
   ' and rsl.shipment_header_id = rsh.shipment_header_id ' ||
   ' and rsl.po_line_location_id = pll.line_location_id '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id ||
   ' ) ' ||
   ' AND msni.product_transaction_id = rti.interface_transaction_id   ';


       p_sql(35) := ' SELECT  mut.* ' ||
 ' from    mtl_unit_transactions mut , ' ||
 ' mtl_material_transactions mmt, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and mmt.transaction_source_id      = ph.po_header_id ' ||
   ' AND mmt.transaction_source_type_id = 1 ' ||
    ' AND mut.transaction_id             = mmt.transaction_id ' ||
     ' and rsh.shipment_header_id = rt.shipment_header_id '||
   ' and rt.transaction_id = mmt.rcv_transaction_id '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' UNION ALL ' ||
 ' SELECT  mut.* ' ||
 ' from    mtl_unit_transactions mut , ' ||
 ' mtl_material_transactions mmt , ' ||
        ' mtl_transaction_lot_numbers mtln, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and mmt.transaction_source_id      = ph.po_header_id ' ||
   ' AND mmt.transaction_source_type_id = 1 ' ||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
    ' AND mut.transaction_id             = mtln.serial_transaction_id '||
    ' and rsh.shipment_header_id = rt.shipment_header_id '||
   ' and rt.transaction_id = mmt.rcv_transaction_id '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(36) := ' SELECT  rss.* ' ||
 ' from    rcv_serials_supply rss , ' ||
 ' rcv_shipment_lines rsl , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        ' po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and   rsl.po_header_id     = ph.po_header_id ' ||
   ' AND rss.shipment_line_id = rsl.shipment_line_id ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id '||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(37) := ' SELECT  rst.* ' ||
 ' from    rcv_serial_transactions rst , ' ||
 ' rcv_shipment_lines rsl , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and   rsl.po_header_id     = ph.po_header_id ' ||
   ' AND rst.shipment_line_id = rsl.shipment_line_id ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(38) := ' SELECT  rsi.* ' ||
 ' from    rcv_serials_interface rsi , ' ||
 ' rcv_transactions_interface rti ' ||
        ' WHERE exists ' ||
 ' (SELECT 1 ' ||
        ' from  po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '  rcv_shipment_headers rsh, rcv_shipment_lines rsl '||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and rti.po_header_id = ph.po_header_id    ' ||
   ' and rsl.shipment_header_id = rsh.shipment_header_id '||
   ' and rsl.po_line_location_id = pll.line_location_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' ) ' ||
        ' AND rsi.interface_transaction_id    =
 rti.interface_transaction_id  ';

       p_sql(39) := ' SELECT  mln.* ' ||
 ' from    mtl_lot_numbers mln , ' ||
 ' mtl_transaction_lot_numbers mtln ,' ||
        ' mtl_material_transactions mmt, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and mmt.transaction_source_id      = ph.po_header_id ' ||
   ' AND mmt.transaction_source_type_id = 1 ' ||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
    ' AND mtln.lot_number                = mln.lot_number ' ||
    ' AND mtln.inventory_item_id         = mln.inventory_item_id ' ||
    ' AND mtln.organization_id           = mln.organization_id ' ||
     ' and rsh.shipment_header_id = rt.shipment_header_id '||
   ' and rt.transaction_id = mmt.rcv_transaction_id '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(40) := ' SELECT  mtln.* ' ||
 ' from    mtl_transaction_lot_numbers mtln , ' ||
 ' mtl_material_transactions mmt , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and mmt.transaction_source_id      = ph.po_header_id ' ||
   ' AND mmt.transaction_source_type_id = 1 ' ||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
      ' and rsh.shipment_header_id = rt.shipment_header_id '||
   ' and rt.transaction_id = mmt.rcv_transaction_id '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(41) := ' SELECT  mtli.* ' ||
 ' from    mtl_transaction_lots_interface mtli , ' ||
 ' rcv_transactions_interface rti ' ||
        ' WHERE exists ' ||
 ' (SELECT 1 ' ||
        ' from po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and  rti.po_header_id = ph.po_header_id    ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id ||
   ' ) ' ||
   ' AND mtli.product_transaction_id = RTI.interface_transaction_id ';


       p_sql(42) := ' SELECT  mtlt.* ' ||
 ' from    mtl_transaction_lots_temp mtlt , ' ||
 ' mtl_material_transactions_temp mmtt , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '   rcv_shipment_headers rsh, rcv_transactions rt' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and mmtt.transaction_source_id      = ph.po_header_id ' ||
   ' AND mmtt.transaction_source_type_id = 1 ' ||
    ' AND mmtt.transaction_temp_id        = mtlt.transaction_temp_id ' ||
      ' and rsh.shipment_header_id = rt.shipment_header_id '||
   ' and rt.transaction_id = mmtt.rcv_transaction_id '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
    ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(43) := ' SELECT  rls.* ' ||
 ' from    rcv_lots_supply rls , ' ||
 ' rcv_shipment_lines rsl, ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '  rcv_shipment_headers rsh '  ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and rsl.shipment_line_id = rls.shipment_line_id ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
   ' and rsl.po_line_location_id=pll.line_location_id' ||
   ' AND rsl.po_header_id     = ph.po_header_id ' ||
      ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;


       p_sql(44) := ' SELECT  rlt.* ' ||
 ' from    rcv_lot_transactions rlt , ' ||
 ' rcv_shipment_lines rsl , ' ||
        ' po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh, ' ||
 '  rcv_shipment_headers rsh '  ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and rsl.po_header_id     = ph.po_header_id ' ||
   ' AND rsl.shipment_line_id = rlt.shipment_line_id ' ||
      ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
    ' and rsl.po_line_location_id=pll.line_location_id' ||
       ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.ship_to_org_id = '|| l_org_id ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id;

       p_sql(45) := ' SELECT  rli.* ' ||
 ' from    rcv_lots_interface rli , ' ||
 ' rcv_transactions_interface rti ' ||
        ' WHERE   rti.interface_transaction_id =
 rli.interface_transaction_id ' ||
 ' AND exists ' ||
    ' (SELECT 1 ' ||
        ' from po_line_locations_all pll , ' ||
        ' po_lines_all pl , ' ||
        ' po_headers_all ph , ' ||
        ' po_distributions_all pd,' ||
        '     po_req_distributions_all prd ,' ||
 '     po_requisition_lines_all prl ,' ||
 '     po_requisition_headers_all prh ' ||
 ' WHERE   prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.requisition_line_id = prd.requisition_line_id' ||
 ' and prl.source_type_code = ''VENDOR''' ||
   ' and pd.req_distribution_id = prd.distribution_id' ||
   ' and pd.po_header_id=ph.po_header_id' ||
   ' AND pl.po_header_id = ph.po_header_id' ||
   ' AND pll.po_line_id  = pl.po_line_id ' ||
   ' AND pll.line_location_id = pd.line_location_id' ||
   ' and rti.po_header_id = ph.po_header_id ' ||
   ' and prh.segment1 = '||''''||l_req_number||''''||
   ' and prl.line_num='||l_line_num||
   ' and prh.org_id = '||l_operating_id||
   ' )  ';

RETURN;
END;

END INV_DIAG_RCV_IPROC_COMMON;

/
