--------------------------------------------------------
--  DDL for Package Body RMA_RCV_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RMA_RCV_DIAGNOSTICS" AS
/* $Header: INVDRMA2B.pls 120.0.12000000.1 2007/08/09 06:52:10 ssadasiv noship $ */

PROCEDURE rma_line_receipt_sql(p_operating_id IN NUMBER,p_rma_number IN VARCHAR2,p_line_num IN NUMBER,
                                         p_receipt_number IN NUMBER, p_org_id IN NUMBER, p_sql IN OUT NOCOPY
INV_DIAG_RCV_PO_COMMON.sqls_list) IS

   l_operating_id    rcv_shipment_headers.receipt_num%TYPE := p_operating_id;
   l_rma_number rcv_shipment_headers.organization_id%TYPE := p_rma_number;
   l_line_num   oe_order_lines_all.line_number%TYPE := p_line_num;
   l_receipt_number   rcv_shipment_headers.receipt_num%TYPE := p_receipt_number;
   l_organization_id       rcv_shipment_headers.organization_id%TYPE := p_org_id;

BEGIN

p_sql(1) := 'select soh.* ' ||
' from oe_order_headers_all soh,' ||
  ' oe_order_lines_all sol,' ||
       ' rcv_shipment_headers rsh,' ||
       ' rcv_shipment_lines rsl' ||
       ' where soh.order_number ='||''''||l_rma_number||'''' ||
  ' and soh.org_id = '||l_operating_id ||
   ' and soh.header_id = sol.header_id' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.oe_order_line_id = sol.line_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and exists (' ||
   ' select 1 ' ||
    ' from oe_order_lines_all sol ' ||
      ' where sol.line_category_code = ''RETURN'' ' ||
     ' and sol.header_id = soh.header_id )  ';



p_sql(2) := ' select sol.* ' ||
' from oe_order_lines_all sol , oe_order_headers_all soh,rcv_shipment_headers rsh,' ||
  ' rcv_shipment_lines rsl ' ||
       ' where soh.order_number ='||''''||l_rma_number||'''' ||
       ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and sol.header_id = soh.header_id' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.oe_order_line_id = sol.line_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id ='|| l_organization_id ;



p_sql(3) := ' select distinct msi.* ' ||
' from mtl_system_items msi , oe_order_lines_all sol , oe_order_headers_all soh, rcv_shipment_headers rsh,
rcv_shipment_lines rsl' ||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
   ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and sol.header_id = soh.header_id ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id '||
   ' and rsl.shipment_line_id = sol.line_id ' ||
   ' and msi.inventory_item_id = sol.inventory_item_id ' ||
   ' and msi.organization_id = sol.ship_from_org_id  ' ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id ='|| l_organization_id ;



p_sql(4) := ' select rsh.* ' ||
' from rcv_shipment_headers rsh , rcv_shipment_lines rsl , oe_order_headers_all soh , oe_order_lines_all sol ' ||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and rsl.oe_order_header_id = soh.header_id ' ||
   ' and rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '||l_organization_id ;

p_sql(5) := ' select rsl.* ' ||
' from rcv_shipment_headers rsh, rcv_shipment_lines rsl , oe_order_headers_all soh , oe_order_lines_all sol ' ||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and rsl.oe_order_header_id = soh.header_id ' ||
   ' and rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN''' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = ' || l_organization_id ;



p_sql(6) := ' select rt.* ' ||
' from rcv_transactions rt , oe_order_headers_all soh , oe_order_lines_all sol , rcv_shipment_headers rsh' ||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id' ||
   ' and rt.shipment_header_id = rsh.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
     ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rsh.organization_id = ' || l_organization_id ;




p_sql(7) := ' select rhi.* ' ||
' from rcv_headers_interface rhi , rcv_transactions_interface rti , oe_order_headers_all soh , oe_order_lines_all sol '
||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and (rti.oe_order_header_id = soh.header_id ' ||
   ' or rti.oe_order_line_id = sol.line_id ) ' ||
       ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rhi.header_interface_id = rti.header_interface_id  ';


p_sql(8) := ' select rti.* ' ||
' from rcv_transactions_interface rti , oe_order_headers_all soh , oe_order_lines_all sol, rcv_shipment_headers rsh ' ||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and (rti.oe_order_header_id = soh.header_id ' ||
   ' or rti.oe_order_line_id = sol.line_id ) ' ||
       ' and sol.header_id = soh.header_id' ||
   ' and rti.shipment_header_id = rsh.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
     ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rsh.organization_id = ' || l_organization_id ;




 p_sql(9) := ' select pie.* ' ||
' from po_interface_errors pie , oe_order_headers_all soh , oe_order_lines_all sol ' ||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and (exists (' ||
   ' select 1 ' ||
        ' from rcv_transactions_interface rti ' ||
          ' where (rti.oe_order_header_id = soh.header_id ' ||
         ' or rti.oe_order_line_id = sol.line_id ) ' ||
               ' and pie.interface_line_id = rti.interface_transaction_id ' ||
           ' and pie.table_name = ''RCV_TRANSACTIONS_INTERFACE'') ' ||
           ' or exists (' ||
       ' select 2 ' ||
        ' from rcv_headers_interface rhi , rcv_transactions_interface rti ' ||
          ' where (rti.oe_order_header_id = soh.header_id ' ||
         ' or rti.oe_order_line_id = sol.line_id ) ' ||
               ' and rhi.header_interface_id = rti.header_interface_id ' ||
           ' and pie.table_name = ''RCV_HEADERS_INTERFACE'' ' ||
           ' and pie.interface_header_id = rhi.header_interface_id) )  ';


p_sql(10) := ' select distinct ood.* ' ||
' from org_organization_definitions ood , rcv_shipment_lines rsl , oe_order_headers_all soh , oe_order_lines_all sol '
||
' , rcv_shipment_headers rsh' ||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and rsl.oe_order_header_id = soh.header_id ' ||
   ' and rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
   ' and rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and ood.organization_id = rsl.to_organization_id  ' ||
     ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = ' || l_organization_id ;



p_sql(11) := ' select distinct mp.* ' ||
' from mtl_parameters mp , rcv_shipment_lines rsl , rcv_shipment_headers rsh, oe_order_lines_all sol,
oe_order_headers_all soh ' ||
   ' where rsl.oe_order_line_id = sol.line_id' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and soh.header_id = sol.header_id ' ||
   ' and rsl.shipment_header_id = rsh.shipment_header_id'||
   ' and mp.organization_id = rsl.to_organization_id  '||
     ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = ' || l_organization_id ;


p_sql(12) := ' select mmt.* ' ||
' from mtl_material_transactions mmt , oe_order_lines_all sol , oe_order_headers_all soh , rcv_transactions rt ,
rcv_shipment_headers rsh' ||
' where soh.order_number ='||''''||l_rma_number||'''' ||
   ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rt.shipment_header_id = rsh.shipment_header_id' ||
   ' and mmt.rcv_transaction_id = rt.transaction_id  ';


p_sql(13) := ' select distinct mtt.transaction_type_id , mtt.transaction_type_name , mtt.transaction_source_type_id ,'||
' mtt.transaction_action_id , mtt.user_defined_flag , mtt.disable_date ' ||
' from mtl_transaction_types mtt , mtl_material_transactions mmt , oe_order_lines_all sol , oe_order_headers_all soh ,'
||
  ' rcv_transactions rt, rcv_shipment_headers rsh ' ||
' where soh.order_number ='||''''||l_rma_number||'''' ||
   ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and mmt.rcv_transaction_id = rt.transaction_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
      ' and rt.shipment_header_id = rsh.shipment_header_id' ||
   ' and mtt.transaction_type_id = mmt.transaction_type_id  ';



/*p_sql(14) := 'select distinct mtrl.* ' ||
' from mtl_txn_request_lines mtrl , rcv_transactions rt , oe_order_headers_all soh , oe_order_lines_all sol,
rcv_shipment_headers rsh ' ||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
 ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and mtrl.reference = ''ORDER_LINE_ID'' ' ||
   ' and mtrl.reference_id = rt.oe_order_line_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rt.shipment_header_id = rt.shipment_header_id' ||
   ' and soh.org_id = 2222 ';*/

p_sql(14) := 'select distinct mtrl.* ' ||
' from mtl_txn_request_lines mtrl , rcv_transactions rt , oe_order_headers_all soh , oe_order_lines_all sol,
rcv_shipment_headers rsh ' ||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
 ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rt.shipment_header_id = rt.shipment_header_id' ||
   ' and soh.org_id = '||l_operating_id||
   ' AND mtrl.organization_id=rt.organization_id'||
   ' AND mtrl.inventory_item_id  = sol.inventory_item_id ' ||
   ' and nvl(mtrl.revision,0)=nvl(sol.item_revision,0) ' ||' and mtrl.line_status=7'||
   ' and mtrl.transaction_type_id=15';



p_sql(15) := ' select mmtt.* ' ||
' from mtl_material_transactions_temp mmtt , oe_order_lines_all sol , oe_order_headers_all soh, rcv_shipment_headers rsh
' ||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and exists (' ||
   ' select 1 ' ||
    ' from rcv_transactions rt ' ||
      ' where rt.oe_order_header_id = soh.header_id ' ||
     ' and rt.oe_order_line_id = sol.line_id ' ||
       ' and mmtt.rcv_transaction_id = rt.transaction_id' ||
        ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
       ' and rsh.organization_id = '|| l_organization_id ||
       ' and rt.shipment_header_id = rsh.shipment_header_id)  ';

p_sql(16) := ' select lsn.* ' ||
' from oe_lot_serial_numbers lsn , oe_order_lines_all sol , oe_order_headers_all soh,' ||
  ' rcv_shipment_headers rsh, rcv_shipment_lines rsl' ||
       ' where soh.order_number ='||''''||l_rma_number||'''' ||
          ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and sol.header_id = soh.header_id ' ||
   ' and lsn.line_id = sol.line_id ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.oe_order_line_id = sol.line_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' order by sol.line_id desc , lsn.lot_serial_id  ';


p_sql(17) := ' select distinct msn.* ' ||
' from mtl_serial_numbers msn , oe_order_lines_all sol , oe_order_headers_all soh ,' ||
  ' rcv_shipment_headers rsh, rcv_shipment_lines rsl' ||
       ' where soh.order_number ='||''''||l_rma_number||'''' ||
          ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rsl.oe_order_line_id = sol.line_id' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and (exists (' ||
   ' select 1 ' ||
        ' from rcv_transactions rt , mtl_material_transactions mmt ' ||
          ' where rt.oe_order_header_id = soh.header_id ' ||
         ' and rt.oe_order_line_id = sol.line_id ' ||
           ' and mmt.rcv_transaction_id = rt.transaction_id ' ||
           ' and msn.last_transaction_id = mmt.transaction_id ) ' ||
           ' or exists (' ||
       ' select 3 ' ||
        ' from mtl_material_transactions ommt ' ||
          ' where ommt.trx_source_line_id = sol.reference_line_id ' ||
         ' and msn.last_transaction_id = ommt.transaction_id ) ' ||
           ' or exists (' ||
       ' select 2 ' ||
        ' from oe_lot_serial_numbers lsn ' ||
          ' where lsn.line_id = sol.line_id ' ||
         ' and sol.ordered_item_id = msn.inventory_item_id ' ||
           ' and sol.ship_from_org_id = msn.current_organization_id ' ||
           ' and msn.serial_number  between lsn.from_serial_number  and nvl(lsn.to_serial_number ,
lsn.from_serial_number)'
||
           ' ) ) order by msn.inventory_item_id , msn.serial_number  ';


p_sql(18) := ' select msnt.* ' ||
' from mtl_serial_numbers_temp msnt , mtl_material_transactions_temp mmtt , oe_order_lines_all sol , ' ||
  ' oe_order_headers_all soh , rcv_transactions rt , rcv_shipment_headers rsh' ||
       ' where soh.order_number ='||''''||l_rma_number||'''' ||
          ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and mmtt.rcv_transaction_id = rt.transaction_id' ||
   ' and rsh.shipment_header_id = rt.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and (msnt.transaction_temp_id = mmtt.transaction_temp_id ' ||
   ' or exists (' ||
       ' select 2 ' ||
        ' from mtl_transaction_lots_temp mtlt ' ||
          ' where msnt.transaction_temp_id = mtlt.serial_transaction_temp_id ' ||
         ' and mmtt.transaction_temp_id = mtlt.transaction_temp_id ) )  ';


p_sql(19) := ' select msni.* ' ||
  ' from mtl_transactions_interface mti , oe_order_lines_all sol , ' ||
  ' oe_order_headers_all soh , mtl_serial_numbers_interface msni , rcv_transactions rt, ' ||
  ' rcv_shipment_headers rsh ' ||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and mti.rcv_transaction_id = rt.transaction_id ' ||
   ' and rsh.shipment_header_id = rt.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and (msni.transaction_interface_id = mti.transaction_interface_id ' ||
   ' or exists (' ||
       ' select 3 ' ||
        ' from mtl_transaction_lots_interface mtln ' ||
          ' where mtln.transaction_interface_id = mti.transaction_interface_id ' ||
         ' and msni.transaction_interface_id = mtln.serial_transaction_temp_id ) )  ';


p_sql(20) := ' select mut.* ' ||
' from mtl_material_transactions mmt , oe_order_lines_all sol , oe_order_headers_all soh , ' ||
  ' rcv_transactions rt , mtl_unit_transactions mut ,rcv_shipment_headers rsh' ||
       ' where soh.order_number ='||''''||l_rma_number||'''' ||
          ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and mmt.rcv_transaction_id = rt.transaction_id ' ||
   ' and rsh.shipment_header_id = rt.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and (mut.transaction_id = mmt.transaction_id ' ||
   ' or exists (' ||
       ' select 1 ' ||
        ' from mtl_transaction_lot_numbers mtln ' ||
          ' where mtln.transaction_id = mmt.transaction_id ' ||
         ' and mut.transaction_id = mtln.serial_transaction_id ) )  ';



        p_sql(21) := ' select rst.* ' ||
' from rcv_serial_transactions rst , rcv_shipment_lines rsl , oe_order_headers_all soh , oe_order_lines_all sol,' ||
  ' rcv_shipment_headers rsh' ||
       ' where soh.order_number ='||''''||l_rma_number||'''' ||
          ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and rsl.oe_order_header_id = soh.header_id ' ||
   ' and rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rst.shipment_line_id = rsl.shipment_line_id  ';


            p_sql(22) := ' select distinct rsi.* ' ||
' from rcv_serials_interface rsi , rcv_shipment_lines rsl , oe_order_headers_all soh , oe_order_lines_all sol,' ||
  ' rcv_shipment_headers rsh' ||
       ' where soh.order_number ='||''''||l_rma_number||'''' ||
          ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and rsl.oe_order_header_id = soh.header_id ' ||
   ' and rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rsi.item_id = rsl.item_id ' ||
   ' and rsi.organization_id = rsl.to_organization_id  ';



        p_sql(23) := ' select distinct mln.* ' ||
' from mtl_lot_numbers mln , oe_order_headers_all soh , oe_order_lines_all sol ' ||
 ' where soh.order_number ='||''''||l_rma_number||'''' ||
    ' and sol.line_number = '|| l_line_num ||
 ' and soh.org_id = '||l_operating_id ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and (exists (' ||
   ' select 1 ' ||
        ' from mtl_material_transactions mmt , rcv_transactions rt , mtl_transaction_lot_numbers mtln, ' ||
        ' rcv_shipment_headers rsh ' ||
          ' where rt.oe_order_header_id = soh.header_id ' ||
         ' and rt.oe_order_line_id = sol.line_id ' ||
           ' and mmt.rcv_transaction_id = rt.transaction_id ' ||
           ' and mmt.transaction_id = mtln.transaction_id ' ||
           ' and mln.inventory_item_id = mmt.inventory_item_id ' ||
           ' and mln.organization_id = mmt.organization_id ' ||
            ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
           ' and rsh.organization_id = '|| l_organization_id ||
           ' and rsh.shipment_header_id = rt.shipment_header_id ' ||
           ' and mln.lot_number = mtln.lot_number ) ' ||
           ' or exists (' ||
       ' select 2 ' ||
        ' from mtl_material_transactions ommt , mtl_transaction_lot_numbers mtln ' ||
          ' where ommt.trx_source_line_id = sol.reference_line_id ' ||
         ' and ommt.transaction_id = mtln.transaction_id ' ||
           ' and mln.inventory_item_id = ommt.inventory_item_id ' ||
           ' and mln.organization_id = ommt.organization_id ' ||
           ' and mln.lot_number = mtln.lot_number ) ' ||
           ' or exists (' ||
       ' select 3 ' ||
        ' from oe_lot_serial_numbers lsn ' ||
          ' where lsn.line_id = sol.line_id ' ||
         ' and sol.ordered_item_id = mln.inventory_item_id ' ||
           ' and sol.ship_from_org_id = mln.organization_id ' ||
           ' and lsn.lot_number = mln.lot_number ) ) order by mln.organization_id , mln.inventory_item_id ,' ||
           ' mln.lot_number  ';


    p_sql(24) := ' select mtln.* ' ||
' from mtl_transaction_lot_numbers mtln , mtl_material_transactions mmt , oe_order_lines_all sol , oe_order_headers_all'
||
  ' soh ' ||
' where soh.order_number ='||''''||l_rma_number||'''' ||
   ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and mmt.transaction_id = mtln.transaction_id ' ||
   ' and (exists (' ||
   ' select 1 ' ||
        ' from rcv_transactions rt, rcv_shipment_headers rsh ' ||
          ' where rt.oe_order_line_id = sol.line_id ' ||
         ' and mmt.rcv_transaction_id = rt.transaction_id' ||
           ' and rsh.shipment_header_id = rt.shipment_header_id' ||
            ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
           '       and rsh.organization_id = '|| l_organization_id ||
' ) ' ||
           ' or mmt.trx_source_line_id = sol.reference_line_id ) order by mtln.organization_id , mtln.inventory_item_id
,' ||
       ' mtln.transaction_id  ';




p_sql(25):= ' select mtli.* ' ||
' from mtl_transaction_lots_interface mtli , mtl_transactions_interface mti , ' ||
  ' oe_order_lines_all sol , oe_order_headers_all soh , rcv_transactions rt, rcv_shipment_headers rsh ' ||
  ' where soh.order_number ='||''''||l_rma_number||'''' ||
     ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and mti.transaction_interface_id = mtli.transaction_interface_id ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rt.shipment_header_id = rsh.shipment_header_id' ||
   ' and mti.rcv_transaction_id = rt.transaction_id order by mtli.transaction_interface_id  ';


    p_sql(26) := ' select mtlt.* ' ||
' from mtl_transaction_lots_temp mtlt , mtl_material_transactions_temp mmtt , oe_order_lines_all sol , ' ||
  ' oe_order_headers_all soh , rcv_transactions rt,rcv_shipment_headers rsh ' ||
       ' where soh.order_number ='||''''||l_rma_number||'''' ||
          ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and mmtt.rcv_transaction_id = rt.transaction_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rt.shipment_header_id = rsh.shipment_header_id' ||
   ' and mmtt.transaction_temp_id = mtlt.transaction_temp_id order by mtlt.transaction_temp_id , mtlt.lot_number  ';

    p_sql(27) := ' select rlt.* ' ||
' from rcv_lot_transactions rlt , rcv_shipment_lines rsl , oe_order_headers_all soh, ' ||
  ' oe_order_lines_all sol , rcv_shipment_headers rsh' ||
     '   where soh.order_number ='||''''||l_rma_number||'''' ||
          ' and sol.line_number = '|| l_line_num ||
  ' and soh.org_id = '||l_operating_id ||
   ' and rsl.oe_order_header_id = soh.header_id ' ||
   ' and rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rlt.shipment_line_id = rsl.shipment_line_id ' ||
   ' order by rlt.shipment_line_id , rlt.lot_num  ';

    p_sql(28) := ' SELECT DISTINCT rp.* ' ||
                ' FROM    rcv_parameters rp, rcv_shipment_headers rsh, oe_order_headers_all soh ' ||
                ' where rsh.receipt_num = '||''''||l_receipt_number||'''' ||
                ' and rsh.organization_id = '|| l_organization_id ||
                ' AND rsh.organization_id = rp.organization_id ' ;


    p_sql(29) := ' SELECT DISTINCT psp.* ' ||
                ' FROM    po_system_parameters_all psp, oe_order_headers_all soh ' ||
                ' where soh.order_number ='||''''||l_rma_number||'''' ||
                ' and soh.org_id = '||l_operating_id ||
                ' and soh.org_id = psp.org_id ' ;

       p_sql(30) := ' SELECT  fsp.* ' ||
' FROM    financials_system_params_all fsp, oe_order_headers_all soh ' ||
' where fsp.org_id  = soh.org_id ' ||
' where soh.order_number ='||''''||l_rma_number||'''' ||
' and soh.org_id = '||l_operating_id ;



RETURN;
END;

PROCEDURE receipt_sql(p_receipt_number IN NUMBER, p_org_id IN NUMBER, p_sql IN OUT NOCOPY
INV_DIAG_RCV_PO_COMMON.sqls_list) IS

   l_receipt_number   rcv_shipment_headers.receipt_num%TYPE := p_receipt_number;
   l_organization_id       rcv_shipment_headers.organization_id%TYPE := p_org_id;

BEGIN

p_sql(1) := 'select distinct soh.* ' ||
            ' from oe_order_headers_all soh,' ||
  ' oe_order_lines_all sol,' ||
       ' rcv_shipment_headers rsh,' ||
       ' rcv_shipment_lines rsl' ||
       ' where soh.header_id = sol.header_id' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.oe_order_line_id = sol.line_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and exists (' ||
   ' select 1 ' ||
    ' from oe_order_lines_all sol ' ||
      ' where sol.line_category_code = ''RETURN'' ' ||
     ' and sol.header_id = soh.header_id )  ';



p_sql(2) := ' select distinct sol.* ' ||
' from oe_order_lines_all sol , rcv_shipment_headers rsh,' ||
  ' rcv_shipment_lines rsl ' ||
   ' where sol.line_category_code = ''RETURN'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.oe_order_line_id = sol.line_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id ='|| l_organization_id ;



p_sql(3) := ' select distinct msi.* ' ||
' from mtl_system_items msi , oe_order_lines_all sol, rcv_shipment_headers rsh, rcv_shipment_lines rsl  ' ||
   ' where  sol.line_category_code = ''RETURN'' ' ||
   ' and sol.line_id = rsl.oe_order_line_id' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id ='|| l_organization_id ||
   ' and msi.inventory_item_id = sol.inventory_item_id ' ||
   ' and msi.organization_id = sol.ship_from_org_id  ';


p_sql(4) := ' select distinct rsh.* ' ||
' from rcv_shipment_headers rsh , rcv_shipment_lines rsl , oe_order_lines_all sol ' ||
    ' where rsl.oe_order_header_id = sol.header_id ' ||
   ' and rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '||l_organization_id ;

p_sql(5) := ' select distinct rsl.* ' ||
' from rcv_shipment_headers rsh, rcv_shipment_lines rsl , oe_order_lines_all sol ' ||
   ' where rsl.oe_order_header_id = sol.header_id ' ||
   ' and rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.line_category_code = ''RETURN''' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = ' || l_organization_id ;



p_sql(6) := ' select rt.* ' ||
' from rcv_transactions rt , oe_order_lines_all sol , rcv_shipment_headers rsh' ||
   ' where rt.oe_order_line_id = sol.line_id ' ||
   ' and rt.shipment_header_id = rsh.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
     ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rsh.organization_id = ' || l_organization_id ;


p_sql(7) := ' select distinct rhi.* ' ||
' from rcv_headers_interface rhi , rcv_transactions_interface rti , oe_order_lines_all sol ' ||
   ' where rti.oe_order_header_id = sol.header_id ' ||
   ' and   rti.oe_order_line_id = sol.line_id  ' ||
       ' and rhi.header_interface_id = rti.header_interface_id  '  ||
     ' and rhi.receipt_num = '||''''||l_receipt_number||'''' ||
     ' and sol.line_category_code = ''RETURN'' ' ||
     ' and rhi.ship_to_organization_id = ' || l_organization_id ;


p_sql(8) := ' select rti.* ' ||
' from rcv_transactions_interface rti , oe_order_headers_all soh , oe_order_lines_all sol, rcv_shipment_headers rsh ' ||
   ' where rti.oe_order_header_id = soh.header_id ' ||
   ' and rti.oe_order_line_id = sol.line_id  ' ||
       ' and sol.header_id = soh.header_id' ||
   ' and rti.shipment_header_id = rsh.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
     ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rsh.organization_id = ' || l_organization_id ;



p_sql(9) := ' select distinct pie.* ' ||
' from po_interface_errors pie , oe_order_lines_all sol, rcv_transactions_interface rti, rcv_shipment_headers rsh' ||
   ' where sol.line_category_code = ''RETURN'' ' ||
   ' and rsh.shipment_header_id = rti.shipment_header_id' ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
    ' and rsh.organization_id = ' || l_organization_id ||
    ' and pie.interface_line_id = rti.interface_transaction_id' ||
    ' and rti.oe_order_line_id = sol.line_id' ;

p_sql(10) := ' select distinct ood.* ' ||
' from org_organization_definitions ood , rcv_shipment_lines rsl , oe_order_lines_all sol, rcv_shipment_headers rsh ' ||
   ' where rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and ood.organization_id = rsl.to_organization_id  ' ||
   ' and rsl.shipment_header_id = rsh.shipment_header_id '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = ' || l_organization_id ;



p_sql(11) := ' select distinct mp.* ' ||
' from mtl_parameters mp , rcv_shipment_lines rsl , rcv_shipment_headers rsh, oe_order_lines_all sol ' ||
   ' where rsl.oe_order_line_id = sol.line_id' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rsl.shipment_header_id = rsh.shipment_header_id'||
   ' and mp.organization_id = rsl.to_organization_id  '||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = ' || l_organization_id ;


p_sql(12) := ' select mmt.* ' ||
' from mtl_material_transactions mmt , oe_order_lines_all sol , oe_order_headers_all soh , rcv_transactions rt ,
rcv_shipment_headers rsh' ||
   ' where sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rt.shipment_header_id = rsh.shipment_header_id' ||
   ' and mmt.rcv_transaction_id = rt.transaction_id  ';


p_sql(13) := ' select distinct mtt.transaction_type_id , mtt.transaction_type_name , mtt.transaction_source_type_id ,'||
' mtt.transaction_action_id , mtt.user_defined_flag , mtt.disable_date ' ||
' from mtl_transaction_types mtt , mtl_material_transactions mmt , oe_order_lines_all sol , oe_order_headers_all soh ,'
||
  ' rcv_transactions rt, rcv_shipment_headers rsh ' ||
   ' where sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and mmt.rcv_transaction_id = rt.transaction_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
      ' and rt.shipment_header_id = rsh.shipment_header_id' ||
   ' and mtt.transaction_type_id = mmt.transaction_type_id  ';



/*p_sql(14) := 'select distinct mtrl.* ' ||
' from mtl_txn_request_lines mtrl , rcv_transactions rt , oe_order_headers_all soh , oe_order_lines_all sol,
rcv_shipment_headers rsh ' ||
 ' where rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and mtrl.reference = ''ORDER_LINE_ID'' ' ||
   ' and mtrl.reference_id = rt.oe_order_line_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rt.shipment_header_id = rsh.shipment_header_id' ;*/

p_sql(14) := 'select distinct mtrl.* ' ||
' from mtl_txn_request_lines mtrl , rcv_transactions rt , oe_order_headers_all soh , oe_order_lines_all sol,
rcv_shipment_headers rsh ' ||
 ' where rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rt.shipment_header_id = rsh.shipment_header_id'||
   ' AND mtrl.inventory_item_id  = sol.inventory_item_id ' ||
   ' and nvl(mtrl.revision,0)=nvl(sol.item_revision,0) ' ||' and mtrl.line_status=7'||
   ' and mtrl.transaction_type_id=15';

p_sql(15) := 'select mmtt.* '||
 'from mtl_material_transactions_temp mmtt , rcv_shipment_headers rsh, rcv_transactions rt'||
 ' WHERE   mmtt.rcv_transaction_id = rt.transaction_id ' ||
 ' and rt.shipment_header_id = rsh.shipment_header_id '||
 ' AND rt.organization_id = rsh.organization_id '||
 ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
 ' and rsh.organization_id = '|| l_organization_id ;


p_sql(16) := ' select lsn.* ' ||
' from oe_lot_serial_numbers lsn , oe_order_lines_all sol , oe_order_headers_all soh,' ||
  '  rcv_shipment_headers rsh, rcv_shipment_lines rsl' ||
   ' where sol.line_category_code = ''RETURN'' ' ||
   ' and sol.header_id = soh.header_id ' ||
   ' and lsn.line_id = sol.line_id ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.oe_order_line_id = sol.line_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' order by sol.line_id desc , lsn.lot_serial_id  ';


p_sql(17) := ' select distinct msn.* ' ||
' from mtl_serial_numbers msn , oe_order_lines_all sol , oe_order_headers_all soh ,' ||
  ' rcv_shipment_headers rsh, rcv_shipment_lines rsl' ||
   ' where sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rsl.oe_order_line_id = sol.line_id' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and (exists (' ||
   ' select 1 ' ||
        ' from rcv_transactions rt , mtl_material_transactions mmt ' ||
          ' where rt.oe_order_header_id = soh.header_id ' ||
         ' and rt.oe_order_line_id = sol.line_id ' ||
           ' and mmt.rcv_transaction_id = rt.transaction_id ' ||
           ' and msn.last_transaction_id = mmt.transaction_id ) ' ||
           ' or exists (' ||
       ' select 3 ' ||
        ' from mtl_material_transactions ommt ' ||
          ' where ommt.trx_source_line_id = sol.reference_line_id ' ||
         ' and msn.last_transaction_id = ommt.transaction_id ) ' ||
           ' or exists (' ||
       ' select 2 ' ||
        ' from oe_lot_serial_numbers lsn ' ||
          ' where lsn.line_id = sol.line_id ' ||
         ' and sol.ordered_item_id = msn.inventory_item_id ' ||
           ' and sol.ship_from_org_id = msn.current_organization_id ' ||
           ' and msn.serial_number  between lsn.from_serial_number  and nvl(lsn.to_serial_number ,
lsn.from_serial_number)'
||
           ' ) ) order by msn.inventory_item_id , msn.serial_number  ';


p_sql(18) := ' select msnt.* ' ||
' from mtl_serial_numbers_temp msnt , mtl_material_transactions_temp mmtt , oe_order_lines_all sol , ' ||
  ' oe_order_headers_all soh , rcv_transactions rt , rcv_shipment_headers rsh' ||
   ' where sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and mmtt.rcv_transaction_id = rt.transaction_id' ||
   ' and rsh.shipment_header_id = rt.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and (msnt.transaction_temp_id = mmtt.transaction_temp_id ' ||
   ' or exists (' ||
       ' select 2 ' ||
        ' from mtl_transaction_lots_temp mtlt ' ||
          ' where msnt.transaction_temp_id = mtlt.serial_transaction_temp_id ' ||
         ' and mmtt.transaction_temp_id = mtlt.transaction_temp_id ) )  ';


p_sql(19) := ' select msni.* ' ||
  ' from mtl_transactions_interface mti , oe_order_lines_all sol , ' ||
  ' oe_order_headers_all soh , mtl_serial_numbers_interface msni , rcv_transactions rt, ' ||
  ' rcv_shipment_headers rsh ' ||
  ' where sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and mti.rcv_transaction_id = rt.transaction_id ' ||
   ' and rsh.shipment_header_id = rt.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and (msni.transaction_interface_id = mti.transaction_interface_id ' ||
   ' or exists (' ||
       ' select 3 ' ||
        ' from mtl_transaction_lots_interface mtln ' ||
          ' where mtln.transaction_interface_id = mti.transaction_interface_id ' ||
         ' and msni.transaction_interface_id = mtln.serial_transaction_temp_id ) )  ';


p_sql(20) := ' select mut.* ' ||
' from mtl_material_transactions mmt , oe_order_lines_all sol , oe_order_headers_all soh , ' ||
  ' rcv_transactions rt , mtl_unit_transactions mut ,rcv_shipment_headers rsh' ||
   ' where sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and mmt.rcv_transaction_id = rt.transaction_id ' ||
   ' and rsh.shipment_header_id = rt.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and (mut.transaction_id = mmt.transaction_id ' ||
   ' or exists (' ||
       ' select 1 ' ||
        ' from mtl_transaction_lot_numbers mtln ' ||
          ' where mtln.transaction_id = mmt.transaction_id ' ||
         ' and mut.transaction_id = mtln.serial_transaction_id ) )  ';



        p_sql(21) := ' select rst.* ' ||
' from rcv_serial_transactions rst , rcv_shipment_lines rsl , oe_order_headers_all soh , oe_order_lines_all sol,' ||
  ' rcv_shipment_headers rsh' ||
   ' where rsl.oe_order_header_id = soh.header_id ' ||
   ' and rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rst.shipment_line_id = rsl.shipment_line_id  ';


            p_sql(22) := ' select distinct rsi.* ' ||
' from rcv_serials_interface rsi , rcv_shipment_lines rsl , oe_order_headers_all soh , oe_order_lines_all sol,' ||
  ' rcv_shipment_headers rsh' ||
   ' where rsl.oe_order_header_id = soh.header_id ' ||
   ' and rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rsi.item_id = rsl.item_id ' ||
   ' and rsi.organization_id = rsl.to_organization_id  ';



        p_sql(23) := ' select distinct mln.* ' ||
' from mtl_lot_numbers mln , oe_order_headers_all soh , oe_order_lines_all sol' ||
  ' where sol.header_id = soh.header_id ' ||
  ' and sol.line_category_code = ''RETURN'' ' ||
   ' and (exists (' ||
   ' select 1 ' ||
        ' from mtl_material_transactions mmt , rcv_transactions rt , mtl_transaction_lot_numbers mtln,
rcv_shipment_headers rsh ' ||
          ' where rt.oe_order_header_id = soh.header_id ' ||
         ' and rt.oe_order_line_id = sol.line_id ' ||
           ' and mmt.rcv_transaction_id = rt.transaction_id ' ||
           ' and mmt.transaction_id = mtln.transaction_id ' ||
           ' and mln.inventory_item_id = mmt.inventory_item_id ' ||
           ' and rsh.shipment_header_id = rt.shipment_header_id' ||
           ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
          ' and rsh.organization_id = '|| l_organization_id ||
          ' and mln.organization_id = mmt.organization_id ' ||
           ' and mln.lot_number = mtln.lot_number ) ' ||
           ') order by mln.organization_id , mln.inventory_item_id ,' ||
           ' mln.lot_number  ';


    p_sql(24) := ' select mtln.* ' ||
          ' from mtl_transaction_lot_numbers mtln , mtl_material_transactions mmt, rcv_transactions rt,
rcv_shipment_headers rsh' ||
 ' where mmt.transaction_id = mtln.transaction_id  ' ||
 ' and   mmt.rcv_transaction_id = rt.transaction_id ' ||
 ' AND rt.shipment_header_id = rsh.shipment_header_id' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
 ' order by mtln.organization_id , mtln.inventory_item_id , mtln.transaction_id   ';

p_sql(25):= ' select mtli.* ' ||
' from mtl_transaction_lots_interface mtli , mtl_transactions_interface mti , ' ||
  ' oe_order_lines_all sol , oe_order_headers_all soh , rcv_transactions rt, rcv_shipment_headers rsh ' ||
   ' where sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and mti.transaction_interface_id = mtli.transaction_interface_id ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rt.shipment_header_id = rsh.shipment_header_id' ||
   ' and mti.rcv_transaction_id = rt.transaction_id order by mtli.transaction_interface_id  ';


    p_sql(26) := ' select mtlt.* ' ||
' from mtl_transaction_lots_temp mtlt , mtl_material_transactions_temp mmtt , oe_order_lines_all sol , ' ||
  ' oe_order_headers_all soh , rcv_transactions rt,rcv_shipment_headers rsh ' ||
   ' where sol.header_id = soh.header_id ' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rt.oe_order_header_id = soh.header_id ' ||
   ' and rt.oe_order_line_id = sol.line_id ' ||
   ' and mmtt.rcv_transaction_id = rt.transaction_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rt.shipment_header_id = rsh.shipment_header_id' ||
   ' and mmtt.transaction_temp_id = mtlt.transaction_temp_id order by mtlt.transaction_temp_id , mtlt.lot_number  ';

    p_sql(27) := ' select rlt.* ' ||
' from rcv_lot_transactions rlt , rcv_shipment_lines rsl , oe_order_headers_all soh , ' ||
  ' oe_order_lines_all sol , rcv_shipment_headers rsh' ||
   ' where rsl.oe_order_header_id = soh.header_id ' ||
   ' and rsl.oe_order_line_id = sol.line_id ' ||
   ' and sol.header_id = soh.header_id ' ||
    ' and rsh.receipt_num = '||''''||l_receipt_number||'''' ||
   ' and rsh.organization_id = '|| l_organization_id ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and sol.line_category_code = ''RETURN'' ' ||
   ' and rlt.shipment_line_id = rsl.shipment_line_id order by rlt.shipment_line_id , rlt.lot_num  ';

    p_sql(28) := ' SELECT DISTINCT rp.* ' ||
                ' FROM    rcv_parameters rp, rcv_shipment_headers rsh, oe_order_headers_all soh ' ||
                ' where rsh.receipt_num = '||''''||l_receipt_number||'''' ||
                ' and rsh.organization_id = '|| l_organization_id ||
                ' AND rsh.organization_id = rp.organization_id ' ;


    p_sql(29) := ' SELECT DISTINCT psp.* ' ||
                ' FROM    po_system_parameters_all psp, oe_order_headers_all soh, rcv_shipment_headers rsh, '||
                 ' rcv_shipment_lines rsl ' ||
                 ' where rsh.receipt_num = '||''''||l_receipt_number||'''' ||
                ' and rsh.organization_id = '|| l_organization_id ||
                ' and rsl.shipment_header_id = rsh.shipment_header_id ' ||
                ' and rsl.oe_order_header_id = soh.header_id ' ||
                ' and soh.org_id = psp.org_id ' ;

       p_sql(30) := ' SELECT DISTINCT fsp.* ' ||
                ' FROM    financials_system_params_all fsp, oe_order_headers_all soh, rcv_shipment_headers rsh, '||
                 ' rcv_shipment_lines rsl ' ||
                 ' where rsh.receipt_num = '||''''||l_receipt_number||'''' ||
                ' and rsh.organization_id = '|| l_organization_id ||
                ' and rsl.shipment_header_id = rsh.shipment_header_id ' ||
                ' and rsl.oe_order_header_id = soh.header_id ' ||
                ' and soh.org_id = fsp.org_id ' ;



RETURN;
END;

END RMA_RCV_DIAGNOSTICS;

/
