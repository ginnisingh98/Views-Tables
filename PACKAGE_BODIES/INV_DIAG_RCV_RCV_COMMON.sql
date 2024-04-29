--------------------------------------------------------
--  DDL for Package Body INV_DIAG_RCV_RCV_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_RCV_RCV_COMMON" AS
/* $Header: INVDPO3B.pls 120.0.12000000.1 2007/08/09 06:50:13 ssadasiv noship $ */

-----------------------------------------------------------------
-- Procedure to Build sqls for Receipt Number and Org combination
-----------------------------------------------------------------

PROCEDURE build_rcv_sql(p_org_id IN NUMBER,p_receipt_num IN VARCHAR2,p_sql IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list) IS

-- Initialize Local Variables.
   l_receipt_num    rcv_shipment_headers.receipt_num%TYPE     := p_receipt_num;
   l_org_id         rcv_shipment_headers.organization_id%TYPE := p_org_id;

BEGIN

p_sql(1) := ' SELECT  distinct ph.* ' ||' FROM    po_headers_all ph,rcv_shipment_lines rsl,rcv_shipment_headers rsh ' ||
		' WHERE   rsh.shipment_header_id=rsl.shipment_header_id' ||
		' and rsl.po_header_id=ph.po_header_id' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id;

p_sql(2) := ' SELECT  distinct pl.* ' ||' FROM    po_lines_all pl,rcv_shipment_lines rsl, ' ||
		' rcv_shipment_headers rsh ' ||' WHERE  pl.po_line_id=rsl.po_line_id' ||
		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||' AND rsh.receipt_num='||''''||l_receipt_num||'''' ||
	       ' AND rsh.ship_to_org_id    ='||l_org_id;

p_sql(3) := ' SELECT distinct  pll.* ' ||' FROM    po_line_locations_all pll , ' ||
		' rcv_shipment_lines rsl, ' ||' rcv_shipment_headers rsh' ||
        	' WHERE  rsl.po_line_location_id= pll.line_location_id' ||
		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id;

p_sql(4) := ' SELECT  distinct pd.* ' ||' FROM    po_line_locations_all pll , ' ||
		' po_distributions_all pd,' ||' rcv_shipment_lines rsl, ' ||
        	' rcv_shipment_headers rsh ' ||' WHERE   pll.line_location_id = pd.line_location_id' ||
		' and rsl.po_line_location_id=pll.line_location_id' ||
		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||' AND rsh.ship_to_org_id    ='||l_org_id;

p_sql(5) := ' SELECT  distinct gcc.* ' ||' FROM    gl_code_combinations gcc , ' ||
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

p_sql(6) := ' SELECT  distinct rrsl.* ' ||' FROM    rcv_receiving_sub_ledger rrsl , ' ||
		' rcv_transactions rt , ' ||' rcv_shipment_headers rsh ' ||
        	' WHERE   rsh.receipt_num         ='||''''||l_receipt_num||'''' ||' AND rsh.ship_to_org_id      ='||l_org_id ||
    		' AND rt.shipment_header_id   = rsh.shipment_header_id ' ||
    		' AND rrsl.rcv_transaction_id = rt.transaction_id   ';

/*p_sql(7) := ' SELECT  distinct id.* ' ||' FROM    ap_invoice_distributions_all id , ' ||
		' po_line_locations_all pll , ' ||' po_distributions_all pd ,' ||
        	' rcv_shipment_lines rsl,rcv_shipment_headers rsh ' ||
        	' WHERE  pll.line_location_id  = pd.line_location_id' ||
		' and pll.line_location_id = rsl.po_line_location_id' ||
		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id ||
		' AND id.po_distribution_id = pd.po_distribution_id ';*/
p_sql(7) := ' SELECT  distinct id.* ' ||' FROM  ap_invoice_lines_all id , ' ||
		' po_line_locations_all pll , rcv_shipment_headers rsh,' ||
		' rcv_transactions rt'||
        	' WHERE pll.line_location_id = rt.po_line_location_id' ||
		' and rsh.shipment_header_id=rt.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id ||
		' AND id.rcv_transaction_id = rt.transaction_id ';

p_sql(8) := ' SELECT  distinct ai.* ' ||' FROM    ap_invoices_all ai , ' ||
		' ap_invoice_distributions_all id , ' ||' po_line_locations_all pll , ' ||
		' po_distributions_all pd ,' ||' rcv_shipment_lines rsl, ' ||
        	' rcv_shipment_headers rsh' ||' WHERE pll.line_location_id  = pd.line_location_id' ||
		' and pll.line_location_id = rsl.po_line_location_id' ||
		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id ||
		' AND id.po_distribution_id = pd.po_distribution_id ' ||
		' AND ai.invoice_id         = id.invoice_id ';

p_sql(9) := ' SELECT distinct ili.* ' ||' FROM    ap_invoice_lines_interface ili , ' ||
		' po_headers_all ph,' ||' rcv_shipment_lines rsl, ' ||
		' rcv_shipment_headers rsh ' ||' WHERE   ph.po_header_id = rsl.po_header_id' ||
		' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id ||
		' AND ili.po_header_id = ph.po_header_id ';

p_sql(10) := ' SELECT  distinct ihi.* ' ||' FROM    ap_invoices_interface ihi , ' ||
		' ap_invoice_lines_interface ili , ' ||' po_headers_all ph,' ||
        	' rcv_shipment_lines rsl, ' ||' rcv_shipment_headers rsh ' ||
        	' WHERE   ph.po_header_id = rsl.po_header_id' ||
        	' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id    ='||l_org_id ||
		' AND ili.po_header_id = ph.po_header_id ' ||
		' AND ihi.invoice_id   = ili.invoice_id ';

p_sql(11) := ' SELECT DISTINCT rsh.* ' ||' FROM    rcv_shipment_lines rsl , ' ||
		' rcv_shipment_headers rsh ' ||' WHERE   rsh.shipment_header_id =rsl.shipment_header_id ' ||
		' AND rsh.receipt_num        ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id     ='||l_org_id ||
    		' AND rsl.shipment_header_id = rsh.shipment_header_id ' ||
    		' ORDER BY rsh.shipment_header_id ';

p_sql(12) := ' SELECT DISTINCT rsl.* ' ||' FROM    rcv_shipment_lines rsl , ' ||
		' rcv_shipment_headers rsh ' ||' WHERE   rsh.shipment_header_id =rsl.shipment_header_id ' ||
		' AND rsh.receipt_num        ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id     ='||l_org_id ||
		' AND rsl.shipment_header_id = rsh.shipment_header_id  ';

p_sql(13) := ' SELECT  distinct rt.* ' ||' FROM    rcv_transactions rt , ' ||
		' rcv_shipment_headers rsh ' ||' WHERE   rsh.receipt_num      ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id   ='||l_org_id ||
		' AND rt.shipment_header_id=rsh.shipment_header_id  ';

p_sql(14) := ' SELECT distinct ms.* ' ||' FROM    mtl_supply ms , ' ||
		' rcv_shipment_headers rsh ' ||' WHERE   rsh.receipt_num      ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id   ='||l_org_id ||' AND ms.shipment_header_id=rsh.shipment_header_id   ';

p_sql(15) := ' SELECT  distinct rs.* ' ||' FROM    rcv_supply rs , ' ||
		' rcv_shipment_headers rsh ' ||' WHERE   rsh.receipt_num      ='||''''||l_receipt_num||'''' ||
		' AND rsh.ship_to_org_id   ='||l_org_id ||' AND rs.shipment_header_id=rsh.shipment_header_id ';

p_sql(16) := ' SELECT  distinct rhi.* ' ||' FROM    rcv_headers_interface rhi ' ||
		' WHERE   receipt_num= '||''''||l_receipt_num||'''' ||' OR exists ' ||
     		' (SELECT 1'||
     		   ' FROM    rcv_shipment_lines rsl , ' ||
     		   ' rcv_shipment_headers rsh ' ||
     		   ' WHERE   rsh.receipt_num        = '||''''||l_receipt_num||'''' ||
        	   ' AND rsh.ship_to_org_id     ='||l_org_id ||
            	   ' AND rsl.shipment_header_id = rsh.shipment_header_id ' ||
                   ' AND rsh.shipment_header_id = rhi.receipt_header_id' ||
                ' ) ' ||
        	' OR exists ' ||
     		' (SELECT 2 ' ||
        	   ' FROM    rcv_transactions_interface rti , ' ||
        	   ' rcv_shipment_headers rsh ' ||
                   ' WHERE   rsh.shipment_header_id  =rti.shipment_header_id ' ||
                   ' AND rsh.receipt_num         = '||''''||l_receipt_num||'''' ||
                   ' AND rsh.ship_to_org_id      ='||l_org_id ||
                   ' AND rhi.header_interface_id = rti.header_interface_id' ||
        	' ) ';

p_sql(17) := ' SELECT DISTINCT rti.* ' ||' FROM    rcv_transactions_interface rti ' ||
		' WHERE   exists ' ||' (SELECT 1'||
        	' FROM    rcv_shipment_headers rsh ' ||
        	' WHERE   rsh.receipt_num        ='||''''||l_receipt_num||'''' ||
        	' AND rsh.ship_to_org_id     ='||l_org_id ||
        	' AND rti.shipment_header_id = rsh.shipment_header_id' ||
            	' ) ';

p_sql(18) := 'SELECT DISTINCT pie.* '||'  FROM    po_interface_errors pie , '||
             ' rcv_shipment_headers rsh'||' WHERE rsh.receipt_num='||''''||l_receipt_num||'''' ||
             ' AND rsh.ship_to_org_id='||l_org_id||' AND ( '||
             ' EXISTS (SELECT 1'||' FROM rcv_transactions_interface rti'||
             ' WHERE pie.interface_line_id   = rti.interface_transaction_id'||
             ' AND rsh.shipment_header_id=rti.shipment_header_id )'||
             ' OR EXISTS '||
             ' (SELECT 2 FROM rcv_headers_interface rhi'||
             ' WHERE pie.interface_header_id = rhi.header_interface_id '||
             ' AND rsh.shipment_header_id  = rhi.header_interface_id))';

p_sql(19) := ' SELECT DISTINCT msi.* ' ||' FROM    mtl_system_items msi , ' ||
		' rcv_shipment_headers rsh,' ||' rcv_shipment_lines rsl ' ||
        	' WHERE   rsh.shipment_header_id=rsl.shipment_header_id ' ||
		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    		' AND rsh.ship_to_org_id    ='||l_org_id||'and msi.inventory_item_id = rsl.item_id ' ||
    		' AND msi.organization_id   = rsl.to_organization_id ';

p_sql(20) := ' SELECT  distinct mmt.* ' ||
		' FROM    mtl_material_transactions mmt ,rcv_transactions rt,rcv_shipment_headers rsh ,' ||
		' po_headers_all ph ' ||' WHERE   mmt.transaction_source_id      = ph.po_header_id ' ||
		' AND mmt.transaction_source_type_id = 1'||
    		' and rsh.shipment_header_id=rt.shipment_header_id ' ||
    		' and rt.transaction_id=mmt.rcv_transaction_id' ||
    		' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    		' AND rsh.ship_to_org_id    ='||l_org_id;

p_sql(21) := ' SELECT distinct  mtt.transaction_type_id , ' ||' mtt.transaction_type_name , ' ||
        	' mtt.transaction_source_type_id , ' ||
        	' mtt.transaction_action_id , ' ||
        	' mtt.user_defined_flag , ' ||
        	' mtt.disable_date ' ||
        	' FROM    mtl_transaction_types mtt ' ||
		' WHERE   exists ' ||
		' (SELECT 1'||
	        ' FROM    mtl_material_transactions mmt , ' ||
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
        	' FROM    mtl_material_transactions_temp mmtt , ' ||
        	' po_headers_all ph ' ||
        	' WHERE   mmtt.transaction_source_id = ph.po_header_id ' ||
        	' AND mmtt.transaction_type_id   = mtt.transaction_type_id ' ||
            	' AND (ph.po_header_id in ' ||
            	' (SELECT DISTINCT po_header_id ' ||
                ' FROM    rcv_shipment_lines rsl, ' ||
                ' rcv_shipment_headers rsh ' ||
                        ' WHERE   rsh.shipment_header_id=rsl.shipment_header_id ' ||
                ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
                    ' AND rsh.ship_to_org_id    ='||l_org_id ||' ))' ||' ) ';

/*p_sql(22) := ' SELECT DISTINCT mol.* ' ||' FROM    mtl_txn_request_lines mol , ' ||
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
p_sql(22) := ' SELECT DISTINCT mol.* ' ||' FROM    mtl_txn_request_lines mol , ' ||
		' rcv_shipment_lines rsl , ' ||
        	' rcv_shipment_headers rsh ' ||
        	' WHERE  mol.organization_id    = rsl.to_organization_id ' ||
    		' AND mol.inventory_item_id  = rsl.item_id ' ||
    		' and nvl(mol.revision,0)=nvl(rsl.item_revision,0) ' ||' and mol.line_status=7'||
		' and mol.transaction_type_id=18'||
    		' AND rsl.shipment_header_id = rsh.shipment_header_id ' ||
    		' AND rsh.receipt_num        ='||''''||l_receipt_num||'''' ||
    		' AND rsh.ship_to_org_id     ='||l_org_id;

        p_sql(23) := ' SELECT  distinct mmtt.* ' ||
' FROM    mtl_material_transactions_temp mmtt , ' ||
' po_headers_all ph ' ||
        ' WHERE   mmtt.transaction_source_id = ph.po_header_id ' ||
' AND (ph.po_header_id in ' ||
    ' (SELECT DISTINCT po_header_id ' ||
        ' FROM    rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
                ' WHERE   rsh.shipment_header_id=rsl.shipment_header_id ' ||
        ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
            ' AND rsh.ship_to_org_id    ='||l_org_id ||
            ' )) ';

            p_sql(24) := ' SELECT DISTINCT ood.* ' ||
' FROM    org_organization_definitions ood , ' ||
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

        p_sql(25) := ' SELECT DISTINCT mp.* ' ||
' FROM    mtl_parameters mp , ' ||
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


    p_sql(26) := ' SELECT DISTINCT rp.* ' ||
' FROM    rcv_parameters rp , ' ||
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
        ' FROM    rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
                ' WHERE   rsh.shipment_header_id=rsl.shipment_header_id ' ||
        ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
            ' AND rsh.ship_to_org_id    ='||l_org_id ||
            ' ))';


p_sql(27):= ' SELECT  distinct psp.* ' ||
' FROM    po_system_parameters_all psp , ' ||
' po_headers_all ph,' ||
        ' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh' ||
        ' WHERE   psp.org_id = ph.org_id ' ||
' AND    ph.po_header_id = rsl.po_header_id' ||
' AND rsh.shipment_header_id=rsl.shipment_header_id ' ||
' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(28) := ' SELECT  distinct fsp.* ' ||
' FROM    financials_system_params_all fsp , ' ||
' po_headers_all ph, ' ||
        ' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh' ||
        ' WHERE   fsp.org_id = ph.org_id ' ||
' and ph.po_header_id = rsl.po_header_id' ||
' and rsh.shipment_header_id=rsl.shipment_header_id ' ||
' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(29) := ' SELECT  distinct msn.* ' ||
' FROM    mtl_serial_numbers msn , ' ||
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
' FROM    mtl_serial_numbers msn , ' ||
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

p_sql(30):=' SELECT  distinct msnt.* ' ||
' FROM    mtl_serial_numbers_temp msnt , ' ||
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
' FROM    mtl_serial_numbers_temp msnt, ' ||
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

    p_sql(31) := ' SELECT  distinct msni.* ' ||
' FROM    mtl_serial_numbers_interface msni , ' ||
' rcv_transactions_interface rti ,' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rsh.receipt_num             ='||''''||l_receipt_num||'''' ||
' AND rsh.ship_to_org_id          ='||l_org_id ||
    ' AND rti.shipment_header_id      =rsh.shipment_header_id ' ||
    ' AND msni.product_transaction_id = rti.interface_transaction_id';

    p_sql(32):=' SELECT  distinct mut.* ' ||
' FROM    mtl_unit_transactions mut , ' ||
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
' FROM    mtl_unit_transactions mut, ' ||
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


    p_sql(33):=' SELECT distinct  rss.* ' ||
' FROM    rcv_serials_supply rss , ' ||
' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rss.shipment_line_id  = rsl.shipment_line_id ' ||
' AND rsh.shipment_header_id=rsl.shipment_header_id ' ||
    ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(34):=' SELECT distinct  rst.* ' ||
' FROM    rcv_serial_transactions rst , ' ||
' rcv_shipment_lines rsl , ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rst.shipment_line_id  = rsl.shipment_line_id ' ||
' AND rsh.shipment_header_id=rsl.shipment_header_id ' ||
    ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(35):=' SELECT  distinct rsi.* ' ||
' FROM    rcv_serials_interface rsi , ' ||
' rcv_transactions_interface rti , ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rti.shipment_header_id       = rsh.shipment_header_id ' ||
' AND rsh.receipt_num              ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id           ='||l_org_id ||
    ' AND rsi.interface_transaction_id = rti.interface_transaction_id  ';

    p_sql(36):=' SELECT  distinct mln.* ' ||
' FROM    mtl_lot_numbers mln , ' ||
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

    p_sql(37):=' SELECT  distinct mtln.* ' ||
' FROM    mtl_transaction_lot_numbers mtln , ' ||
' rcv_transactions rt ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' mtl_material_transactions mmt ' ||
        ' WHERE   mmt.rcv_transaction_id         = rt.transaction_id ' ||
' AND rsh.shipment_header_id         =rt.shipment_header_id ' ||
    ' AND mmt.transaction_source_type_id = 1'||
    ' AND mtln.transaction_id            = mmt.transaction_id ' ||
    ' AND rsh.receipt_num                ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id             ='||l_org_id;

p_sql(38):=' SELECT  distinct mtli.* ' ||
' FROM    mtl_transaction_lots_interface mtli , ' ||
' rcv_transactions_interface rti ,' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rti.shipment_header_id      = rsh.shipment_header_id ' ||
' AND rsh.receipt_num             ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id          ='||l_org_id  ||
    ' AND mtli.product_transaction_id = RTI.interface_transaction_id';

    p_sql(39):=' SELECT distinct  mtlt.* ' ||
' FROM    mtl_transaction_lots_temp mtlt , ' ||
' mtl_material_transactions_temp mmtt ,' ||
        ' po_headers_all ph ' ||
        ' WHERE   mmtt.transaction_source_id      = ph.po_header_id ' ||
' AND mmtt.transaction_source_type_id = 1 ' ||
    ' AND mmtt.transaction_temp_id        = mtlt.transaction_temp_id ' ||
    ' AND (ph.po_header_id in ' ||
    ' (SELECT DISTINCT po_header_id ' ||
        ' FROM    rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
                ' WHERE   rsh.shipment_header_id=rsl.shipment_header_id ' ||
        ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
            ' AND rsh.ship_to_org_id  ='||l_org_id ||' ))';

        p_sql(40):=' SELECT  distinct rls.* ' ||
' FROM    rcv_lots_supply rls , ' ||
' rcv_shipment_lines rsl , ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rsl.shipment_line_id  = rls.shipment_line_id ' ||
' AND rsh.shipment_header_id=rsl.shipment_header_id ' ||
    ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(41):=' SELECT  distinct rlt.* ' ||
' FROM    rcv_lot_transactions rlt , ' ||
' rcv_shipment_lines rsl , ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rsl.shipment_line_id  = rlt.shipment_line_id ' ||
' AND rsh.shipment_header_id=rsl.shipment_header_id ' ||
    ' AND rsh.receipt_num       ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id    ='||l_org_id;

    p_sql(42):=' SELECT distinct rli.* ' ||
' FROM    rcv_lots_interface rli , ' ||
' rcv_transactions_interface rti,' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rti.interface_transaction_id = rli.interface_transaction_id ' ||
' AND rti.shipment_header_id       =rsh.shipment_header_id ' ||
    ' AND rsh.receipt_num              ='||''''||l_receipt_num||'''' ||
    ' AND rsh.ship_to_org_id           ='||l_org_id;

RETURN;
END;  -- END build_rcv_sql


----------------------------------------------------
-- Procedure to build the sqls for the lookup codes
----------------------------------------------------
PROCEDURE build_lookup_codes(p_sql     IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list)
IS

BEGIN

p_sql(100) :=  ' select lookup_type , lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
             ' from mfg_lookups ' ||' where lookup_type = ''MTL_SERIAL_NUMBER''  ';

p_sql(101) := ' select lookup_type , lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
            ' from mfg_lookups ' ||' where lookup_type = ''MTL_SERIAL_NUMBER_TYPE''  ';

p_sql(102) := ' select lookup_type , lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
            ' from mfg_lookups ' ||' where lookup_type = ''MTL_SERIAL_GENERATION''  ';

p_sql(103) := ' select lookup_type , lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
            ' from mfg_lookups ' ||' where lookup_type = ''SERIAL_NUM_STATUS''  ';

p_sql(104) := ' select lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
            ' from mfg_lookups ' ||' where lookup_type = ''MTL_LOT_CONTROL''  ';

p_sql(105) := ' select lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
            ' from mfg_lookups ' ||' where lookup_type = ''MTL_LOT_GENERATION''  ';

p_sql(106) := ' select lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
            ' from mfg_lookups ' ||' where lookup_type = ''MTL_LOT_UNIQUENESS''   ';

END; -- END build_lookup_codes

END INV_DIAG_RCV_RCV_COMMON;

/
