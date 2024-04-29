--------------------------------------------------------
--  DDL for Package Body INV_DIAG_RCV_PO_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_RCV_PO_COMMON" AS
/* $Header: INVDPO2B.pls 120.0.12000000.1 2007/08/09 06:49:54 ssadasiv noship $ */
---------------------------------------------------------------
-- Package to Build sqls for PO,OU,PLL or POL combination
-- This Package is also used for PO,OU,PLL and POL combination
---------------------------------------------------------------

PROCEDURE build_po_all_sql(p_operating_id IN NUMBER,p_po_number IN VARCHAR2,p_line_num IN NUMBER,p_line_loc_num IN NUMBER,p_sql IN OUT NOCOPY sqls_list) IS

-- Initialize Local Variables.
l_operating_id   po_headers_all.org_id%TYPE   := p_operating_id;
l_po_number      po_headers_all.segment1%TYPE :=p_po_number;
l_line_num       VARCHAR2(1000)               := p_line_num;
l_line_loc_num   VARCHAR2(1000)               := p_line_loc_num;

BEGIN

-- Build the condition based on the input
IF p_line_num IS NULL THEN
   l_line_num     := ' pl.line_num ';
END IF;
IF p_line_loc_num IS NULL THEN
   l_line_loc_num := ' pll.shipment_num ';
END IF;

p_sql(1) := ' select distinct ph.* '||' from po_headers_all ph '||' where (ph.segment1 = '||''''||l_po_number||''''||
            ' and ph.org_id = '||l_operating_id||')';
p_sql(2) := ' select distinct pl.* '||' from po_lines_all pl , po_headers_all ph '||' where (ph.segment1 = '||''''||l_po_number||''''||
            ' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||') and pl.po_header_id = ph.po_header_id';
p_sql(3) := ' select  distinct pll.* '||' from po_line_locations_all pll , po_lines_all pl , '||'po_headers_all ph  where '||
            ' (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||
            ' and pll.shipment_num ='||l_line_loc_num||
            ' ) and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id ';
p_sql(4) := ' select distinct pd.* '||' from po_line_locations_all pll , po_lines_all pl , '||' po_headers_all ph , po_distributions_all pd '||
            ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||
            l_line_num||' and pll.shipment_num ='||l_line_loc_num||
            ') and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id = pd.line_location_id';
p_sql(5) := ' select distinct gcc.* '||' from gl_code_combinations gcc , po_line_locations_all pll , '||'po_lines_all pl , po_headers_all ph ,'||
            ' po_distributions_all pd where gcc.summary_flag = ''N'''||' and gcc.template_id is null and '||' (ph.segment1 = '||''''||l_po_number||''''||
            ' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||
            l_line_loc_num||') and pl.po_header_id = ph.po_header_id '||
            ' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id = pd.line_location_id'||' and gcc.code_combination_id in '||'(pd.accrual_account_id , pd.budget_account_id '||
            ', pd.VARIANCE_ACCOUNT_ID , pd.code_combination_id)';
p_sql(6) := ' select distinct rrsl.* '||' from rcv_receiving_sub_ledger rrsl , rcv_transactions rt , po_headers_all ph,'||'po_lines_all pl,po_line_locations_all pll '||
            ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||
            l_line_loc_num||') and rt.po_header_id = ph.po_header_id '||' and rrsl.rcv_transaction_id = rt.transaction_id'||
            ' and ph.po_header_id=pl.po_header_id '||'and pll.po_line_id=pl.po_line_id'||' and pll.line_location_id=rrsl.reference3';
/*p_sql(7) := ' select distinct id.* '||' from ap_invoice_distributions_all id , po_line_locations_all pll , '||'po_lines_all pl , po_headers_all ph , po_distributions_all pd '||
            ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||
            l_line_loc_num||') and pl.po_header_id = ph.po_header_id '||
            ' and pll.po_line_id = pl.po_line_id '||'and pll.line_location_id = pd.line_location_id '||'and id.po_distribution_id = pd.po_distribution_id';*/
p_sql(7) := ' select distinct id.* '||' from ap_invoice_lines_all id , po_line_locations_all pll , '||'po_lines_all pl , po_headers_all ph , po_distributions_all pd '||
            ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||
            l_line_loc_num||') and pl.po_header_id = ph.po_header_id '||
            ' and pll.po_line_id = pl.po_line_id '||'and pll.line_location_id = pd.line_location_id '||'and id.po_distribution_id = pd.po_distribution_id'||
            ' and id.po_line_location_id=pll.line_location_id'||' and id.po_line_id=pl.po_line_id'||
            ' and id.po_header_id=ph.po_header_id';
p_sql(8) := ' select distinct ai.* '||' from ap_invoices_all ai , ap_invoice_distributions_all id , po_line_locations_all pll '||', po_lines_all pl , po_headers_all ph ,'||
            ' po_distributions_all pd where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||
            l_line_loc_num||') and pl.po_header_id = ph.po_header_id '||
            ' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id = pd.line_location_id '||' and id.po_distribution_id = pd.po_distribution_id '||
            ' and ai.invoice_id = id.invoice_id';
p_sql(9) := ' select distinct ili.* '||' from ap_invoice_lines_interface ili , po_headers_all ph '||' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
            ') and (ili.po_header_id = ph.po_header_id '||' or ili.po_number = '||''''||l_po_number||''''||')';
p_sql(10):= ' select distinct ihi.* '||' from ap_invoices_interface ihi , ap_invoice_lines_interface ili , po_headers_all ph '||' where (ph.segment1 = '||''''||l_po_number||
            ''''||' and ph.org_id = '||l_operating_id||') and (ili.po_header_id = ph.po_header_id '||' or ili.po_number = '||''''||l_po_number||''''||
            ') and ihi.invoice_id = ili.invoice_id';
p_sql(11):=' select distinct rsh.* '||'from po_headers_all ph , rcv_shipment_lines rsl , rcv_shipment_headers rsh,'||'po_lines_all pl,po_line_locations_all pll '||
           ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||
           l_line_loc_num||') and rsl.po_header_id = ph.po_header_id '||' and rsl.shipment_header_id = rsh.shipment_header_id '||
           ' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id=rsl.po_line_location_id'||
           ' and rsl.po_line_id=pl.po_line_id';
p_sql(12):=' select distinct rsl.* '||' from po_headers_all ph , rcv_shipment_lines rsl,'||'po_lines_all pl,po_line_locations_all pll '||
           ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||
           l_line_num||' and pll.shipment_num ='||l_line_loc_num||') and rsl.po_header_id = ph.po_header_id '||
           ' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id=rsl.po_line_location_id'||
           ' and rsl.po_line_id=pl.po_line_id';
p_sql(13):=' select distinct rt.* '||' from rcv_transactions rt , po_headers_all ph,'||'po_lines_all pl,po_line_locations_all pll '||
           ' where (ph.segment1 = '||''''||l_po_number||
           ''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||
           l_line_num||' and pll.shipment_num ='||l_line_loc_num||') and rt.po_header_id = ph.po_header_id '||
           ' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id=rt.po_line_location_id'||
           ' and rt.po_line_id=pl.po_line_id';
p_sql(14):=' select distinct ms.* '||' from mtl_supply ms , po_headers_all ph,'||'po_lines_all pl,po_line_locations_all pll '||
           ' where (ph.segment1 = '||''''||l_po_number||
           ''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||
           l_line_num||' and pll.shipment_num ='||l_line_loc_num||') and ms.po_header_id = ph.po_header_id '||
           ' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id=ms.po_line_location_id'||
           ' and ms.po_line_id=pl.po_line_id';
p_sql(15):=' select distinct rs.* '||' from rcv_supply rs , po_headers_all ph ,'||'po_lines_all pl,po_line_locations_all pll '||
           ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||
           l_line_num||' and pll.shipment_num ='||l_line_loc_num||') and rs.po_header_id = ph.po_header_id '||
           ' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id=rs.po_line_location_id'||
           ' and rs.po_line_id=pl.po_line_id';
p_sql(16):=' select distinct rhi.* '||' from rcv_headers_interface rhi'||' where exists (select 1 '||' from po_headers_all ph , rcv_shipment_lines rsl , rcv_shipment_headers rsh'||
           ' where ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||'and rsl.po_header_id = ph.po_header_id '||
           ' and rsl.shipment_header_id = rsh.shipment_header_id '||'and rsh.shipment_header_id = rhi.receipt_header_id)'||
           ' or exists (select 2 from rcv_transactions_interface rti '||'where rti.document_num = '||''''||l_po_number||''''||' and rhi.header_interface_id = rti.header_interface_id)'||
           ' or exists (select 3 from rcv_transactions_interface rti , po_headers_all ph '||'where ph.segment1 = '||''''||l_po_number||''''||
           ' and ph.org_id = '||l_operating_id||' and rti.po_header_id = ph.po_header_id '||'and rti.po_header_id is not null '||
           ' and rhi.header_interface_id = rti.header_interface_id)';
p_sql(17):=' select distinct rti.*'||'from rcv_transactions_interface rti where '||'rti.document_num = '||''''||l_po_number||''''||
           ' or exists (select 1 from po_headers_all ph,'||'po_lines_all pl,po_line_locations_all pll '||
           ' where ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rti.po_header_id = ph.po_header_id'||
           ' and pll.po_line_id = pl.po_line_id '||' and pl.po_header_id = ph.po_header_id )';
p_sql(18):=' select distinct pie.* '||'from po_interface_errors pie , rcv_transactions_interface rti , rcv_headers_interface rhi '||', po_headers_all poh where '||
           ' ((table_name = ''RCV_HEADERS_INTERFACE'''||' and rti.header_interface_id = rhi.header_interface_id '||' and pie.interface_header_id = rhi.header_interface_id '||
           ' and (nvl (rti.po_header_id , -999) = poh.po_header_id '||'or nvl (rti.document_num , ''-9999'') = poh.segment1 ))'||
           ' or (table_name = ''RCV_TRANSACTIONS_INTERFACE'''||'and pie.interface_line_id = rti.interface_transaction_id'||' and (nvl (rti.po_header_id , -999) = poh.po_header_id'||
           ' or nvl (rti.document_num ,''-9999'') = poh.segment1)))'||' and poh.segment1 = '||''''||l_po_number||'''';
p_sql(19):=' select distinct msi.* '||' from mtl_system_items msi , po_line_locations_all pll , po_lines_all pl , po_headers_all ph '||
           ' where pl.po_header_id = ph.po_header_id '||'and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and pll.po_line_id = pl.po_line_id '||'and msi.inventory_item_id = pl.item_id '||'and msi.organization_id = pll.ship_to_organization_id';
p_sql(20):=' select distinct mmt.* '||'from mtl_material_transactions mmt , po_headers_all ph,'||'po_lines_all pl,po_line_locations_all pll '||
           ' ,rcv_transactions rt'||
           ' where mmt.transaction_source_id = ph.po_header_id '||
           ' and mmt.transaction_source_type_id = 1 and '||'ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rt.po_line_location_id=pll.line_location_id'||' and rt.po_line_id = pl.po_line_id'||' and rt.transaction_id=mmt.rcv_transaction_id'||
           ' and pll.po_line_id = pl.po_line_id '||
           ' and pl.po_header_id = ph.po_header_id';
p_sql(21):=' select distinct mtt.transaction_type_id , mtt.transaction_type_name , '||'mtt.transaction_source_type_id , mtt.transaction_action_id , mtt.user_defined_flag , mtt.disable_date'||
           ' from mtl_transaction_types mtt where'||
           ' exists ('||' select 1 from mtl_material_transactions mmt , po_headers_all ph '||
           ' where mmt.transaction_source_id = ph.po_header_id '||' and mmt.transaction_source_type_id = 1 '||' and mtt.transaction_type_id = mmt.transaction_type_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||')'||
           ' or exists (select 2 from mtl_material_transactions_temp mmtt , po_headers_all ph '||' where mmtt.transaction_source_id = ph.po_header_id '||
           ' and mmtt.transaction_type_id = mtt.transaction_type_id '||'and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||')';
/*p_sql(22):=' select distinct mol.* '||'from mtl_txn_request_lines mol , rcv_transactions rt ,'||' rcv_shipment_lines rsl , po_headers_all ph '||
           ' where mol.reference_id = decode(mol.reference ,'||'''SHIPMENT_LINE_ID'' , rt.shipment_line_id ,'||'''PO_LINE_LOCATION_ID'' , rt.po_line_location_id ,'||
           ' ''ORDER_LINE_ID'' , rt.oe_order_line_id)'||' and rt.shipment_line_id = rsl.shipment_line_id '||'and mol.organization_id = rt.organization_id '||
           ' and mol.inventory_item_id = rsl.item_id'||' and rsl.po_header_id = ph.po_header_id '||' and ph.segment1 = '||''''||l_po_number||''''||
           ' and ph.org_id = '||l_operating_id;*/
p_sql(22):=' select distinct mol.* '||'from mtl_txn_request_lines mol,'||' rcv_shipment_lines rsl , po_headers_all ph '||
           ' where mol.organization_id = rsl.to_organization_id '||
           ' and mol.inventory_item_id = rsl.item_id'||' and nvl(mol.revision,0)=nvl(rsl.item_revision,0) ' ||' and mol.line_status=7'||
           ' and mol.transaction_type_id=18'||
           ' and rsl.po_header_id = ph.po_header_id '||' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id;
p_sql(23):=' select distinct mmtt.* '||' from mtl_material_transactions_temp mmtt , po_headers_all ph,'||
           ' po_lines_all pl,po_line_locations_all pll '||' where mmtt.transaction_source_id = ph.po_header_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and pll.po_line_id = pl.po_line_id ';
p_sql(24):=' select distinct ood.* '||' from org_organization_definitions ood , po_line_locations_all pll , '||'po_lines_all pl , po_headers_all ph ,'||
           ' financials_system_params_all fsp '||' where pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and fsp.org_id = ph.org_id'||' and ood.organization_id in (fsp.inventory_organization_id , pll.ship_to_organization_id)'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(25):=' select distinct mp.* '||' from mtl_parameters mp , po_line_locations_all pll , '||'po_lines_all pl , po_headers_all ph , '||
           ' financials_system_params_all fsp where '||'pl.po_header_id = ph.po_header_id '||'and pll.po_line_id = pl.po_line_id '||
           ' and fsp.org_id = ph.org_id'||' and mp.organization_id in (fsp.inventory_organization_id , pll.ship_to_organization_id)'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(26):=' select distinct rp.* '||'from rcv_parameters rp , po_line_locations_all pll ,'||'po_lines_all pl , po_headers_all ph,'||
           ' financials_system_params_all fsp where '||'pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id '||
           ' and fsp.org_id = ph.org_id '||'and (rp.organization_id = fsp.inventory_organization_id '||
           ' or rp.organization_id = pll.ship_to_organization_id)'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(27):=' select distinct psp.* '||' from po_system_parameters_all psp , po_headers_all ph '||' where psp.org_id = ph.org_id '||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id;
p_sql(28):=' select distinct fsp.* '||' from financials_system_params_all fsp , po_headers_all ph '||' where fsp.org_id = ph.org_id '||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id;
p_sql(29):=' select distinct msn.* '||' from mtl_serial_numbers msn , mtl_unit_transactions mut , po_headers_all ph'||
           ' ,po_lines_all pl , po_line_locations_all pll,'||' mtl_material_transactions mmt '||',rcv_transactions rt'||
           ' where mmt.transaction_source_id = ph.po_header_id '||' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mmt.transaction_source_type_id = 1 '||'and mut.transaction_id = mmt.transaction_id'||
           ' and msn.inventory_item_id = mut.inventory_item_id '||' and msn.current_organization_id = mut.organization_id '||
           ' and rt.po_line_location_id=pll.line_location_id'||' and rt.po_line_id = pl.po_line_id'||' and rt.transaction_id=mmt.rcv_transaction_id'||
           ' and msn.serial_number = mut.serial_number'||' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' union all '||
           ' select distinct  msn.* '||' from mtl_serial_numbers msn , mtl_unit_transactions mut '||', po_headers_all ph'||',po_lines_all pl , po_line_locations_all pll,'||
           ' mtl_material_transactions mmt'||', mtl_transaction_lot_numbers mtln '||',rcv_transactions rt'||
           ' where mmt.transaction_source_id = ph.po_header_id '||' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mmt.transaction_source_type_id = 1 '||
           ' and mtln.transaction_id = mmt.transaction_id '||'and mut.transaction_id = mtln.serial_transaction_id '||'and msn.inventory_item_id = mut.inventory_item_id'||
           ' and msn.current_organization_id = mut.organization_id'||' and msn.serial_number = mut.serial_number '||
           ' and rt.po_line_location_id=pll.line_location_id'||' and rt.po_line_id = pl.po_line_id'||' and rt.transaction_id=mmt.rcv_transaction_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(30):=' select distinct msnt.* '||'from mtl_serial_numbers_temp	msnt , mtl_material_transactions_temp mmtt'||', po_headers_all ph,'||
           ' po_lines_all pl , po_line_locations_all pll'||' where '||
           ' mmtt.transaction_source_id = ph.po_header_id '||' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and msnt.transaction_temp_id = mmtt.transaction_temp_id '||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' union all '||
           ' select msnt.* '||' from mtl_serial_numbers_temp	msnt'||', mtl_material_transactions_temp mmtt , po_headers_all ph,'||
           ' po_lines_all pl , po_line_locations_all pll,'||'mtl_transaction_lots_temp mtln where '||'mmtt.transaction_source_id = ph.po_header_id'||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mtln.transaction_temp_id = mmtt.transaction_temp_id'||
           ' and msnt.transaction_temp_id = mtln.serial_transaction_temp_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(31):=' select distinct msni.* '||'from mtl_serial_numbers_interface msni , rcv_transactions_interface rti '||
           ' where (nvl(rti.document_num , ''-9999'') = '||''''||l_po_number||''''||
           ' or exists (select 1 from po_headers_all ph '||' where ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and rti.po_header_id = ph.po_header_id ))'||' and msni.product_transaction_id = rti.interface_transaction_id';
p_sql(32):=' select distinct mut.* '||'from mtl_unit_transactions mut , po_headers_all ph , mtl_material_transactions mmt,'||
           ' po_lines_all pl , po_line_locations_all pll'||',rcv_transactions rt'||
           ' where mmt.transaction_source_id = ph.po_header_id'||' and mmt.transaction_source_type_id = 1 '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and rt.transaction_id=mmt.rcv_transaction_id'||' and rt.po_line_location_id=pll.line_location_id'||' and rt.po_line_id=pl.po_line_id'||
           ' and mut.transaction_id = mmt.transaction_id '||' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' union all '||
           ' select mut.* '||' from mtl_unit_transactions mut , po_headers_all ph , '||'mtl_material_transactions mmt , mtl_transaction_lot_numbers mtln,'||
           ' po_lines_all pl , po_line_locations_all pll'||',rcv_transactions rt'||
           ' where mmt.transaction_source_id = ph.po_header_id'||' and mmt.transaction_source_type_id = 1'||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mtln.transaction_id = mmt.transaction_id '||'and mut.transaction_id = mtln.serial_transaction_id '||
           ' and rt.transaction_id=mmt.rcv_transaction_id'||' and rt.po_line_location_id=pll.line_location_id'||' and rt.po_line_id=pl.po_line_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(33):=' select distinct rss.* '||' from rcv_serials_supply	rss , rcv_shipment_lines rsl , po_headers_all ph ,'||
           ' po_lines_all pl , po_line_locations_all pll'||' where rsl.po_header_id = ph.po_header_id '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and rss.shipment_line_id = rsl.shipment_line_id '||' and rsl.po_line_id = pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||''''||l_operating_id||''''||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(34):=' select distinct rst.* '||'from rcv_serial_transactions rst , rcv_shipment_lines rsl , po_headers_all ph,'||
           ' po_lines_all pl , po_line_locations_all pll'||' where rsl.po_header_id = ph.po_header_id '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and rst.shipment_line_id = rsl.shipment_line_id' ||' and rsl.po_line_id = pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||''''||l_operating_id||''''||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(35):=' select distinct rsi.* '||'from rcv_serials_interface rsi , rcv_transactions_interface rti '||' where (exists (select 1 '||
           ' from po_headers_all ph,'||' po_lines_all pl , po_line_locations_all pll'||' where rti.po_header_id = ph.po_header_id '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||''''||
           l_operating_id||''''||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ')) and rsi.interface_transaction_id = rti.interface_transaction_id';
p_sql(36):=' select distinct mln.* '||'from mtl_lot_numbers mln , mtl_transaction_lot_numbers mtln ,'||'po_headers_all ph,'||
           ' po_lines_all pl , po_line_locations_all pll,'||
           ' mtl_material_transactions mmt'||
           ' where mmt.transaction_source_id = ph.po_header_id '||' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mmt.transaction_source_type_id = 1 '||'and mtln.transaction_id = mmt.transaction_id '||
           ' and mtln.lot_number = mln.lot_number'||' and mtln.inventory_item_id = mln.inventory_item_id '||' and mtln.organization_id = mln.organization_id '||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(37):=' select distinct mtln.* '||'from mtl_transaction_lot_numbers mtln , po_headers_all ph ,'||' po_lines_all pl , po_line_locations_all pll,'||
           ' mtl_material_transactions mmt '||' where mmt.transaction_source_id = ph.po_header_id '||' and mmt.transaction_source_type_id = 1 '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mtln.transaction_id = mmt.transaction_id '||' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(38):=' select distinct mtli.* '||'from mtl_transaction_lots_interface mtli , rcv_transactions_interface rti '||' where (nvl(rti.document_num ,''-9999'') = '||
           ''''||l_po_number||''''||'or exists (select 1 from po_headers_all ph,'||' po_lines_all pl , po_line_locations_all pll'||
           ' where rti.po_header_id = ph.po_header_id '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ')) and mtli.product_transaction_id = RTI.interface_transaction_id';
p_sql(39):=' select distinct mtlt.* '||'from mtl_transaction_lots_temp mtlt , mtl_material_transactions_temp mmtt ,'||'po_headers_all ph,'||
           ' po_lines_all pl , po_line_locations_all pll where '||
           ' mmtt.transaction_source_id = ph.po_header_id '||' and mmtt.transaction_source_type_id = 1 '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mmtt.transaction_temp_id = mtlt.transaction_temp_id '||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(40):=' select distinct rls.* '||'from rcv_lots_supply rls , rcv_shipment_lines rsl , po_headers_all ph ,'||
           ' po_lines_all pl , po_line_locations_all pll where '||' rsl.shipment_line_id = rls.shipment_line_id '||
           ' and rsl.po_header_id = ph.po_header_id '||' and rsl.po_line_id = pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(41):=' select distinct rlt.* '||'from rcv_lot_transactions rlt , rcv_shipment_lines rsl , po_headers_all ph ,'||
           ' po_lines_all pl , po_line_locations_all pll where '||' rsl.po_header_id = ph.po_header_id '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and rlt.shipment_line_id = rsl.shipment_line_id' ||' and rsl.po_line_id = pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||''''||l_operating_id||''''||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(42):=' select distinct rli.* '||'from rcv_lots_interface rli , rcv_transactions_interface rti'||' where rti.interface_transaction_id = rli.interface_transaction_id '||
           ' and exists (select 1 from po_headers_all ph,'||
           ' po_lines_all pl , po_line_locations_all pll where rti.po_header_id = ph.po_header_id '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||
           ' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||
           ' and pll.shipment_num ='||l_line_loc_num||')'||
           ' or (nvl(rti.document_num ,''-9999'') ='||''''||l_po_number||''''||')';
RETURN;
END; -- END build_po_all_sql

---------------------------------------------------------------------
-- Procedure to Build sqls for PO,OU,PLL,POL,RCV and Org combination
--
---------------------------------------------------------------------
PROCEDURE build_all_sql(p_operating_id IN NUMBER,p_po_number IN VARCHAR2,p_line_num IN NUMBER,p_line_loc_num IN NUMBER,
                                    p_org_id IN NUMBER,p_receipt_num IN VARCHAR2,p_sql IN OUT NOCOPY sqls_list) IS

-- Initialize Local Variables
l_operating_id   po_headers_all.org_id%TYPE                := p_operating_id;
l_po_number      po_headers_all.segment1%TYPE              :=p_po_number;
l_receipt_num    rcv_shipment_headers.receipt_num%TYPE     := p_receipt_num;
l_org_id         rcv_shipment_headers.organization_id%TYPE := p_org_id;
l_line_num       VARCHAR2(1000)                            := p_line_num;
l_line_loc_num   VARCHAR2(1000)                            := p_line_loc_num;

BEGIN

-- Build the condition based on the input
IF p_line_num IS NULL THEN
   l_line_num     := ' pl.line_num ';
END IF;
IF p_line_loc_num IS NULL THEN
   l_line_loc_num := ' pll.shipment_num ';
END IF;

p_sql(1) := ' select distinct ph.* '||' from po_headers_all ph, '||' rcv_shipment_lines rsl, rcv_shipment_headers rsh '||
            ',po_lines_all pl,po_line_locations_all pll'||
            ' where rsh.shipment_header_id=rsl.shipment_header_id'||' and rsh.receipt_num='||''''||l_receipt_num||''''||
            ' and rsh.ship_to_org_id='||l_org_id||' and rsl.po_header_id=ph.po_header_id'||' and ph.segment1 = '||''''||l_po_number||''''||
            ' and ph.org_id = '||l_operating_id||' and rsl.po_line_location_id=pll.line_location_id'||' and rsl.po_line_id=pl.po_line_id'||
            ' and pl.po_header_id=ph.po_header_id'||
            ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(2) := ' select distinct pl.* '||' from po_lines_all pl,po_headers_all ph,po_line_locations_all pll,'||' rcv_shipment_lines rsl, rcv_shipment_headers rsh '||
            ' where rsh.shipment_header_id=rsl.shipment_header_id'||' and rsl.po_line_id=pl.po_line_id'||' and pl.po_header_id = ph.po_header_id'||
            ' and pll.po_line_id=pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
            ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and rsh.receipt_num='||''''||l_receipt_num||''''||
            ' and rsh.ship_to_org_id='||l_org_id||
            ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(3) := ' select  distinct pll.* '||' from po_line_locations_all pll , po_lines_all pl , '||'po_headers_all ph,rcv_shipment_lines rsl, rcv_shipment_headers rsh '||
            ' where ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||
            ' and pll.shipment_num ='||l_line_loc_num||' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id '||
            ' and rsl.po_line_id=pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||' and rsh.shipment_header_id=rsl.shipment_header_id'||
            ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(4) := ' select distinct pd.* '||' from po_line_locations_all pll , po_lines_all pl , '||' po_headers_all ph , po_distributions_all pd '||
            ',rcv_shipment_lines rsl, rcv_shipment_headers rsh '||
            ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||
            l_line_num||' and pll.shipment_num ='||l_line_loc_num||
            ') and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id = pd.line_location_id'||
            ' and rsl.po_line_id=pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||' and rsh.shipment_header_id=rsl.shipment_header_id'||
            ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(5) := ' select distinct gcc.* '||' from gl_code_combinations gcc , po_line_locations_all pll , '||'po_lines_all pl , po_headers_all ph ,'||
            ' po_distributions_all pd,rcv_shipment_lines rsl, rcv_shipment_headers rsh '||' where gcc.summary_flag = ''N'''||
            ' and gcc.template_id is null and '||' (ph.segment1 = '||''''||l_po_number||''''||
            ' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
            ') and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id = pd.line_location_id'||
            ' and gcc.code_combination_id in '||'(pd.accrual_account_id , pd.budget_account_id '||', pd.VARIANCE_ACCOUNT_ID , pd.code_combination_id)'||
            ' and rsl.po_line_id=pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||' and rsh.shipment_header_id=rsl.shipment_header_id'||
            ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(6) := ' select distinct rrsl.* '||' from rcv_receiving_sub_ledger rrsl , rcv_transactions rt , po_headers_all ph,'||
            'po_lines_all pl,po_line_locations_all pll '||',rcv_shipment_lines rsl, rcv_shipment_headers rsh '||
            ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||
            l_line_loc_num||') and rt.po_header_id = ph.po_header_id '||' and rrsl.rcv_transaction_id = rt.transaction_id'||
            ' and ph.po_header_id=pl.po_header_id '||'and pll.po_line_id=pl.po_line_id'||' and pll.line_location_id=rrsl.reference3'||
            ' and rsl.po_line_id=pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||' and rsh.shipment_header_id=rsl.shipment_header_id'||
            ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
/*p_sql(7) := ' select distinct id.* '||' from ap_invoice_distributions_all id , po_line_locations_all pll , '||'po_lines_all pl , po_headers_all ph , po_distributions_all pd '||
            ',rcv_shipment_lines rsl, rcv_shipment_headers rsh '||
            ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||
            l_line_loc_num||') and pl.po_header_id = ph.po_header_id '||
            ' and pll.po_line_id = pl.po_line_id '||'and pll.line_location_id = pd.line_location_id '||'and id.po_distribution_id = pd.po_distribution_id'||
            ' and rsl.po_line_id=pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||' and rsh.shipment_header_id=rsl.shipment_header_id'||
            ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;*/
p_sql(7) := ' select distinct id.* '||' from ap_invoice_lines_all id , po_line_locations_all pll , '||'po_lines_all pl , po_headers_all ph , po_distributions_all pd '||
            ',rcv_shipment_lines rsl, rcv_shipment_headers rsh,'||' rcv_transactions rt'||
            ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||
            l_line_loc_num||') and pl.po_header_id = ph.po_header_id '||
            ' and pll.po_line_id = pl.po_line_id '||'and pll.line_location_id = pd.line_location_id '||'and id.po_distribution_id = pd.po_distribution_id'||
            ' and rsl.po_line_id=pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||' and rsh.shipment_header_id=rsl.shipment_header_id'||
            ' and id.po_line_location_id=pll.line_location_id'||' and rt.po_line_location_id=pll.line_location_id'||
            ' and rt.transaction_id=id.rcv_transaction_id'||' and rsh.receipt_num='||''''||l_receipt_num||''''||
            ' and rsh.ship_to_org_id='||l_org_id;
p_sql(8) := ' select distinct ai.* '||' from ap_invoices_all ai , ap_invoice_distributions_all id , po_line_locations_all pll '||
            ', po_lines_all pl , po_headers_all ph ,'||'rcv_shipment_lines rsl, rcv_shipment_headers rsh ,'||
            ' po_distributions_all pd where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||
            l_line_loc_num||') and pl.po_header_id = ph.po_header_id '||
            ' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id = pd.line_location_id '||' and id.po_distribution_id = pd.po_distribution_id '||
            ' and ai.invoice_id = id.invoice_id'||
            ' and rsl.po_line_id=pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||' and rsh.shipment_header_id=rsl.shipment_header_id'||
            ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(9) := ' select distinct ili.* '||' from ap_invoice_lines_interface ili , po_headers_all ph'||' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
            ') and (ili.po_header_id = ph.po_header_id '||' or ili.po_number = '||''''||l_po_number||''''||')';
p_sql(10):= ' select distinct ihi.* '||' from ap_invoices_interface ihi , ap_invoice_lines_interface ili , po_headers_all ph '||' where (ph.segment1 = '||''''||l_po_number||
            ''''||' and ph.org_id = '||l_operating_id||') and (ili.po_header_id = ph.po_header_id '||' or ili.po_number = '||''''||l_po_number||''''||
            ') and ihi.invoice_id = ili.invoice_id';
p_sql(11):=' select distinct rsh.* '||'from po_headers_all ph , rcv_shipment_lines rsl , rcv_shipment_headers rsh,'||'po_lines_all pl,po_line_locations_all pll '||
           ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||
           l_line_loc_num||') and rsl.po_header_id = ph.po_header_id '||' and rsl.shipment_header_id = rsh.shipment_header_id '||
           ' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id=rsl.po_line_location_id'||
           ' and rsl.po_line_id=pl.po_line_id'||' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(12):=' select distinct rsl.* '||' from po_headers_all ph , rcv_shipment_lines rsl,rcv_shipment_headers rsh,'||'po_lines_all pl,po_line_locations_all pll '||
           ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||
           l_line_num||' and pll.shipment_num ='||l_line_loc_num||') and rsl.po_header_id = ph.po_header_id '||
           ' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id=rsl.po_line_location_id'||
           ' and rsl.shipment_header_id=rsh.shipment_header_id'||
           ' and rsl.po_line_id=pl.po_line_id'||' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(13):=' select distinct rt.* '||' from rcv_transactions rt , po_headers_all ph,'||'po_lines_all pl,po_line_locations_all pll '||
           ',rcv_shipment_lines rsl, rcv_shipment_headers rsh '||
           ' where (ph.segment1 = '||''''||l_po_number||
           ''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||
           l_line_num||' and pll.shipment_num ='||l_line_loc_num||') and rt.po_header_id = ph.po_header_id '||
           ' and rsh.shipment_header_id = rt.shipment_header_id'||' and rt.shipment_line_id=rsl.shipment_line_id'||
           ' and rsl.shipment_header_id=rsh.shipment_header_id'||' and pll.po_line_id = pl.po_line_id '||
           ' and pll.line_location_id=rt.po_line_location_id'||' and rt.po_line_id=pl.po_line_id'||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(14):=' select distinct ms.* '||' from mtl_supply ms , po_headers_all ph,'||'po_lines_all pl,po_line_locations_all pll'||
           ',rcv_shipment_lines rsl, rcv_shipment_headers rsh '||
           ' where (ph.segment1 = '||''''||l_po_number||
           ''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||
           l_line_num||' and pll.shipment_num ='||l_line_loc_num||') and ms.po_header_id = ph.po_header_id '||
           ' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id=ms.po_line_location_id'||
           ' and rsl.shipment_header_id=rsh.shipment_header_id'||' and ms.shipment_line_id=rsl.shipment_line_id'||
           ' and ms.po_line_id=pl.po_line_id'||' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(15):=' select distinct rs.* '||' from rcv_supply rs , po_headers_all ph ,'||'po_lines_all pl,po_line_locations_all pll '||
           ',rcv_shipment_lines rsl, rcv_shipment_headers rsh '||
           ' where (ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||' and pl.line_num ='||
           l_line_num||' and pll.shipment_num ='||l_line_loc_num||') and rs.po_header_id = ph.po_header_id '||
           ' and pll.po_line_id = pl.po_line_id '||' and pll.line_location_id=rs.po_line_location_id'||
           ' and rs.po_line_id=pl.po_line_id'||' and rsl.shipment_header_id=rsh.shipment_header_id'||' and rs.shipment_line_id=rsl.shipment_line_id'||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(16):=' select distinct rhi.* '||' from rcv_headers_interface rhi'||' where exists (select 1 '||' from po_headers_all ph , rcv_shipment_lines rsl , rcv_shipment_headers rsh'||
           ' where ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||'and rsl.po_header_id = ph.po_header_id '||
           ' and rsl.shipment_header_id = rsh.shipment_header_id '||'and rsh.shipment_header_id = rhi.receipt_header_id'||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id||')'||
           ' or exists (select 2 from rcv_transactions_interface rti '||'where rti.document_num = '||''''||l_po_number||''''||' and rhi.header_interface_id = rti.header_interface_id)'||
           ' or exists (select 3 from rcv_transactions_interface rti , po_headers_all ph '||'where ph.segment1 = '||''''||l_po_number||''''||
           ' and ph.org_id = '||l_operating_id||' and rti.po_header_id = ph.po_header_id '||'and rti.po_header_id is not null '||
           ' and rhi.header_interface_id = rti.header_interface_id)';
p_sql(17):=' select distinct rti.*'||'from rcv_transactions_interface rti where '||'rti.document_num = '||''''||l_po_number||''''||
           ' or exists (select 1 from po_headers_all ph,'||'po_lines_all pl,po_line_locations_all pll '||
           ',rcv_shipment_lines rsl, rcv_shipment_headers rsh '||
           ' where ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rti.po_header_id = ph.po_header_id'||' and rsh.shipment_header_id=rsl.shipment_header_id'||' and rsl.po_header_id=ph.po_header_id'||
           ' and rsl.po_line_id=pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id||
           ' and pll.po_line_id = pl.po_line_id '||' and pl.po_header_id = ph.po_header_id )';

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

p_sql(19):=' select distinct msi.* '||' from mtl_system_items msi , po_line_locations_all pll , po_lines_all pl , po_headers_all ph '||
           ',rcv_shipment_lines rsl, rcv_shipment_headers rsh '||
           ' where pl.po_header_id = ph.po_header_id '||'and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and pll.po_line_id = pl.po_line_id '||'and msi.inventory_item_id = pl.item_id '||'and msi.organization_id = pll.ship_to_organization_id'||
           ' and rsl.po_line_id=pl.po_line_id'||' and rsl.shipment_header_id=rsh.shipment_header_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(20):=' select distinct mmt.* '||'from mtl_material_transactions mmt , po_headers_all ph,'||'po_lines_all pl,po_line_locations_all pll '||
           ' ,rcv_transactions rt,rcv_shipment_headers rsh'||
           ' where mmt.transaction_source_id = ph.po_header_id '||
           ' and mmt.transaction_source_type_id = 1 and '||'ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rt.po_line_location_id=pll.line_location_id'||' and rt.po_line_id = pl.po_line_id'||' and rt.transaction_id=mmt.rcv_transaction_id'||
           ' and rt.shipment_header_id=rsh.shipment_header_id'||' and pll.po_line_id = pl.po_line_id '||' and pl.po_header_id = ph.po_header_id'||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(21):=' select mtt.transaction_type_id , mtt.transaction_type_name , '||'mtt.transaction_source_type_id , mtt.transaction_action_id , mtt.user_defined_flag , mtt.disable_date'||
           ' from mtl_transaction_types mtt where'||
           ' exists ('||' select 1 from mtl_material_transactions mmt , po_headers_all ph '||
           ' where mmt.transaction_source_id = ph.po_header_id '||' and mmt.transaction_source_type_id = 1 '||' and mtt.transaction_type_id = mmt.transaction_type_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||')'||
           ' or exists (select 2 from mtl_material_transactions_temp mmtt , po_headers_all ph '||' where mmtt.transaction_source_id = ph.po_header_id '||
           ' and mmtt.transaction_type_id = mtt.transaction_type_id '||'and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||')';
/*p_sql(22):=' select distinct mol.* '||'from mtl_txn_request_lines mol , rcv_transactions rt ,'||' rcv_shipment_lines rsl ,rcv_shipment_headers rsh,'||
           ' po_headers_all ph '||
           ' where mol.reference_id = decode(mol.reference ,'||'''SHIPMENT_LINE_ID'' , rt.shipment_line_id ,'||'''PO_LINE_LOCATION_ID'' , rt.po_line_location_id ,'||
           ' ''ORDER_LINE_ID'' , rt.oe_order_line_id)'||' and rt.shipment_line_id = rsl.shipment_line_id '||' and rsl.shipment_header_id=rsh.shipment_header_id'||
           ' and mol.organization_id = rt.organization_id '||' and mol.inventory_item_id = rsl.item_id'||' and rsl.po_header_id = ph.po_header_id '||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;*/
p_sql(22):=' select distinct mol.* '||'from mtl_txn_request_lines mol ,'||' rcv_shipment_lines rsl ,rcv_shipment_headers rsh,'||
           ' po_headers_all ph '||' where rsl.shipment_header_id=rsh.shipment_header_id'||
           ' and mol.organization_id = rsl.to_organization_id '||
           ' and mol.inventory_item_id = rsl.item_id'||' and nvl(mol.revision,0)=nvl(rsl.item_revision,0) ' ||' and mol.line_status=7'||
	   ' and mol.transaction_type_id=18'||
           ' and rsl.po_header_id = ph.po_header_id '||' and ph.segment1 = '||''''||l_po_number||''''||
           ' and ph.org_id = '||l_operating_id||' and rsh.receipt_num='||''''||l_receipt_num||''''||
           ' and rsh.ship_to_org_id='||l_org_id;
p_sql(23):=' select distinct mmtt.* '||' from mtl_material_transactions_temp mmtt , po_headers_all ph,'||
           ' po_lines_all pl,po_line_locations_all pll'||' where mmtt.transaction_source_id = ph.po_header_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and pll.po_line_id = pl.po_line_id '||
           ' and exists (select 1 from rcv_shipment_headers rsh,rcv_shipment_lines rsl'||
           ' where rsh.shipment_header_id=rsl.shipment_header_id'||' and rsl.po_line_id=pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id||')';
p_sql(24):=' select distinct ood.* '||' from org_organization_definitions ood , po_line_locations_all pll , '||'po_lines_all pl , po_headers_all ph ,'||
           ' financials_system_params_all fsp '||' where pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and fsp.org_id = ph.org_id'||' and ood.organization_id in (fsp.inventory_organization_id , pll.ship_to_organization_id)'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(25):=' select distinct mp.* '||' from mtl_parameters mp , po_line_locations_all pll , '||'po_lines_all pl , po_headers_all ph , '||
           ' financials_system_params_all fsp where '||'pl.po_header_id = ph.po_header_id '||'and pll.po_line_id = pl.po_line_id '||
           ' and fsp.org_id = ph.org_id'||' and mp.organization_id in (fsp.inventory_organization_id , pll.ship_to_organization_id)'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(26):=' select distinct rp.* '||'from rcv_parameters rp , po_line_locations_all pll ,'||'po_lines_all pl , po_headers_all ph,'||
           ' financials_system_params_all fsp where '||'pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id '||
           ' and fsp.org_id = ph.org_id '||'and (rp.organization_id = fsp.inventory_organization_id '||
           ' or rp.organization_id = pll.ship_to_organization_id)'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num;
p_sql(27):=' select distinct psp.* '||' from po_system_parameters_all psp , po_headers_all ph '||' where psp.org_id = ph.org_id '||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id;
p_sql(28):=' select distinct fsp.* '||' from financials_system_params_all fsp , po_headers_all ph '||' where fsp.org_id = ph.org_id '||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id;
p_sql(29):=' select distinct msn.* '||' from mtl_serial_numbers msn , mtl_unit_transactions mut , po_headers_all ph'||
           ' ,po_lines_all pl , po_line_locations_all pll,'||' mtl_material_transactions mmt '||',rcv_transactions rt,rcv_shipment_headers rsh'||
           ' where mmt.transaction_source_id = ph.po_header_id '||' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mmt.transaction_source_type_id = 1 '||'and mut.transaction_id = mmt.transaction_id'||
           ' and msn.inventory_item_id = mut.inventory_item_id '||' and msn.current_organization_id = mut.organization_id '||
           ' and rt.po_line_location_id=pll.line_location_id'||' and rt.po_line_id = pl.po_line_id'||' and rt.transaction_id=mmt.rcv_transaction_id'||
           ' and rt.shipment_header_id=rsh.shipment_header_id'||
           ' and msn.serial_number = mut.serial_number'||' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id||
           ' union all '||
           ' select distinct  msn.* '||' from mtl_serial_numbers msn , mtl_unit_transactions mut '||', po_headers_all ph'||',po_lines_all pl , po_line_locations_all pll,'||
           ' mtl_material_transactions mmt'||', mtl_transaction_lot_numbers mtln '||',rcv_transactions rt,rcv_shipment_headers rsh'||
           ' where mmt.transaction_source_id = ph.po_header_id '||' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mmt.transaction_source_type_id = 1 '||
           ' and mtln.transaction_id = mmt.transaction_id '||'and mut.transaction_id = mtln.serial_transaction_id '||'and msn.inventory_item_id = mut.inventory_item_id'||
           ' and msn.current_organization_id = mut.organization_id'||' and msn.serial_number = mut.serial_number '||
           ' and rt.po_line_location_id=pll.line_location_id'||' and rt.po_line_id = pl.po_line_id'||' and rt.transaction_id=mmt.rcv_transaction_id'||
           ' and rt.shipment_header_id=rsh.shipment_header_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(30):=' select distinct msnt.* '||'from mtl_serial_numbers_temp	msnt , mtl_material_transactions_temp mmtt'||', po_headers_all ph,'||
           ' po_lines_all pl , po_line_locations_all pll'||' where '||
           ' mmtt.transaction_source_id = ph.po_header_id '||' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and msnt.transaction_temp_id = mmtt.transaction_temp_id '||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and exists (select 1 from rcv_shipment_headers rsh,rcv_shipment_lines rsl'||
           ' where rsh.shipment_header_id=rsl.shipment_header_id'||' and rsl.po_line_id=pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id||')'||
           ' union all '||
           ' select msnt.* '||' from mtl_serial_numbers_temp	msnt'||', mtl_material_transactions_temp mmtt , po_headers_all ph,'||
           ' po_lines_all pl , po_line_locations_all pll,'||'mtl_transaction_lots_temp mtln where '||'mmtt.transaction_source_id = ph.po_header_id'||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mtln.transaction_temp_id = mmtt.transaction_temp_id'||
           ' and msnt.transaction_temp_id = mtln.serial_transaction_temp_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and exists (select 1 from rcv_shipment_headers rsh,rcv_shipment_lines rsl'||
           ' where rsh.shipment_header_id=rsl.shipment_header_id'||' and rsl.po_line_id=pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id||')';
p_sql(31):=' select distinct msni.* '||'from mtl_serial_numbers_interface msni , rcv_transactions_interface rti'||',rcv_shipment_headers rsh '||
           ' where (nvl(rti.document_num , ''-9999'') = '||''''||l_po_number||''''||
           ' or exists (select 1 from po_headers_all ph '||' where ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and rti.po_header_id = ph.po_header_id ))'||' and msni.product_transaction_id = rti.interface_transaction_id'||
           ' and rsh.shipment_header_id=rti.shipment_header_id'||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(32):=' select distinct mut.* '||'from mtl_unit_transactions mut , po_headers_all ph , mtl_material_transactions mmt,'||
           ' po_lines_all pl , po_line_locations_all pll'||',rcv_transactions rt,rcv_shipment_headers rsh'||
           ' where mmt.transaction_source_id = ph.po_header_id'||' and mmt.transaction_source_type_id = 1 '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and rt.transaction_id=mmt.rcv_transaction_id'||' and rt.po_line_location_id=pll.line_location_id'||' and rt.po_line_id=pl.po_line_id'||
           ' and rt.shipment_header_id=rsh.shipment_header_id'||
           ' and mut.transaction_id = mmt.transaction_id '||' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id||
           ' union all '||
           ' select mut.* '||' from mtl_unit_transactions mut , po_headers_all ph , '||'mtl_material_transactions mmt , mtl_transaction_lot_numbers mtln,'||
           ' po_lines_all pl , po_line_locations_all pll'||',rcv_transactions rt,rcv_shipment_headers rsh'||
           ' where mmt.transaction_source_id = ph.po_header_id'||' and mmt.transaction_source_type_id = 1'||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mtln.transaction_id = mmt.transaction_id '||'and mut.transaction_id = mtln.serial_transaction_id '||
           ' and rt.transaction_id=mmt.rcv_transaction_id'||' and rt.po_line_location_id=pll.line_location_id'||' and rt.po_line_id=pl.po_line_id'||
           ' and rt.shipment_header_id=rsh.shipment_header_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(33):=' select distinct rss.* '||' from rcv_serials_supply	rss , rcv_shipment_lines rsl,rcv_shipment_headers rsh'||', po_headers_all ph ,'||
           ' po_lines_all pl , po_line_locations_all pll'||' where rsl.po_header_id = ph.po_header_id '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and rss.shipment_line_id = rsl.shipment_line_id '||' and rsl.po_line_id = pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and rsl.shipment_header_id=rsh.shipment_header_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||''''||l_operating_id||''''||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(34):=' select distinct rst.* '||'from rcv_serial_transactions rst , rcv_shipment_lines rsl,rcv_shipment_headers rsh'||' , po_headers_all ph,'||
           ' po_lines_all pl , po_line_locations_all pll'||' where rsl.po_header_id = ph.po_header_id '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and rst.shipment_line_id = rsl.shipment_line_id' ||' and rsl.po_line_id = pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and rsl.shipment_header_id=rsh.shipment_header_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||''''||l_operating_id||''''||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(35):=' select distinct rsi.* '||'from rcv_serials_interface rsi , rcv_transactions_interface rti '||' where (exists (select 1 '||
           ' from po_headers_all ph,'||' po_lines_all pl , po_line_locations_all pll'||' ,rcv_shipment_headers rsh,rcv_shipment_lines rsl'||
           ' where rti.po_header_id = ph.po_header_id '||' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and rsh.shipment_header_id=rsl.shipment_header_id'||' and rsl.shipment_line_id=rti.shipment_line_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||''''||l_operating_id||''''||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id||
           ')) and rsi.interface_transaction_id = rti.interface_transaction_id';
p_sql(36):=' select distinct mln.* '||'from mtl_lot_numbers mln , mtl_transaction_lot_numbers mtln ,'||'po_headers_all ph,'||
           ' po_lines_all pl , po_line_locations_all pll,'||
           ' mtl_material_transactions mmt'||',rcv_transactions rt,rcv_shipment_headers rsh'||
           ' where mmt.transaction_source_id = ph.po_header_id '||' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mmt.transaction_source_type_id = 1 '||'and mtln.transaction_id = mmt.transaction_id '||
           ' and mtln.lot_number = mln.lot_number'||' and mtln.inventory_item_id = mln.inventory_item_id '||' and mtln.organization_id = mln.organization_id '||
           ' and mmt.rcv_transaction_id=rt.transaction_id'||' and rsh.shipment_header_id=rt.shipment_header_id'||
           ' and rt.po_line_location_id=pll.line_location_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;

p_sql(37):=' select distinct mtln.* '||'from mtl_transaction_lot_numbers mtln , po_headers_all ph ,'||' po_lines_all pl , po_line_locations_all pll,'||
           ' mtl_material_transactions mmt '||',rcv_transactions rt,rcv_shipment_headers rsh'||
           ' where mmt.transaction_source_id = ph.po_header_id '||' and mmt.transaction_source_type_id = 1 '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mmt.rcv_transaction_id=rt.transaction_id'||' and rsh.shipment_header_id=rt.shipment_header_id'||
           ' and rt.po_line_location_id=pll.line_location_id'||
           ' and mtln.transaction_id = mmt.transaction_id '||' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(38):=' select distinct mtli.* '||'from mtl_transaction_lots_interface mtli , rcv_transactions_interface rti '||' where (nvl(rti.document_num ,''-9999'') = '||
           ''''||l_po_number||''''||'or exists (select 1 from po_headers_all ph,'||' po_lines_all pl , po_line_locations_all pll'||
           ',rcv_shipment_headers rsh,rcv_shipment_lines rsl'||
           ' where rti.po_header_id = ph.po_header_id '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and rsl.po_line_location_id=pll.line_location_id'||' and rsl.shipment_header_id=rsh.shipment_header_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id||
           ')) and mtli.product_transaction_id = RTI.interface_transaction_id';
p_sql(39):=' select distinct mtlt.* '||'from mtl_transaction_lots_temp mtlt , mtl_material_transactions_temp mmtt ,'||'po_headers_all ph,'||
           ' po_lines_all pl , po_line_locations_all pll,'||'rcv_shipment_headers rsh,rcv_shipment_lines rsl'||' where '||
           ' mmtt.transaction_source_id = ph.po_header_id '||' and mmtt.transaction_source_type_id = 1 '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and mmtt.transaction_temp_id = mtlt.transaction_temp_id '||
           ' and rsl.po_line_location_id=pll.line_location_id'||' and rsl.shipment_header_id=rsh.shipment_header_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(40):=' select distinct rls.* '||'from rcv_lots_supply rls , rcv_shipment_lines rsl,'||'rcv_shipment_headers rsh , po_headers_all ph ,'||
           ' po_lines_all pl , po_line_locations_all pll where '||' rsl.shipment_line_id = rls.shipment_line_id '||
           ' and rsl.po_header_id = ph.po_header_id '||' and rsl.po_line_id = pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and rsl.shipment_header_id=rsh.shipment_header_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(41):=' select distinct rlt.* '||'from rcv_lot_transactions rlt , rcv_shipment_lines rsl,'||'rcv_shipment_headers rsh, po_headers_all ph ,'||
           ' po_lines_all pl , po_line_locations_all pll where '||' rsl.po_header_id = ph.po_header_id '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and rlt.shipment_line_id = rsl.shipment_line_id' ||' and rsl.po_line_id = pl.po_line_id'||' and rsl.po_line_location_id=pll.line_location_id'||
           ' and rsl.shipment_header_id=rsh.shipment_header_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||' and ph.org_id = '||''''||l_operating_id||''''||
           ' and pl.line_num ='||l_line_num||' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id;
p_sql(42):=' select distinct rli.* '||'from rcv_lots_interface rli , rcv_transactions_interface rti'||' where rti.interface_transaction_id = rli.interface_transaction_id '||
           ' and exists (select 1 from po_headers_all ph,'||
           ' po_lines_all pl , po_line_locations_all pll,'||'rcv_shipment_headers rsh,rcv_shipment_lines rsl'||
           ' where rti.po_header_id = ph.po_header_id '||
           ' and pl.po_header_id = ph.po_header_id '||' and pll.po_line_id = pl.po_line_id'||
           ' and rsl.po_line_location_id=pll.line_location_id'||' and rsl.shipment_header_id=rsh.shipment_header_id'||
           ' and ph.segment1 = '||''''||l_po_number||''''||
           ' and ph.org_id = '||l_operating_id||
           ' and pl.line_num ='||l_line_num||
           ' and pll.shipment_num ='||l_line_loc_num||
           ' and rsh.receipt_num='||''''||l_receipt_num||''''||' and rsh.ship_to_org_id='||l_org_id||
           ')'||' or (nvl(rti.document_num ,''-9999'') ='||''''||l_po_number||''''||')';
RETURN;
END;

END INV_DIAG_RCV_PO_COMMON;

/
