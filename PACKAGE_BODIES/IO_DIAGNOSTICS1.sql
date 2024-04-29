--------------------------------------------------------
--  DDL for Package Body IO_DIAGNOSTICS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IO_DIAGNOSTICS1" AS
/* $Header: INVDIO1B.pls 120.1.12000000.1 2007/08/09 06:43:33 ssadasiv noship $ */

PROCEDURE req_num_sql(p_ou_id IN NUMBER , p_req_num IN VARCHAR2, p_sql IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list) IS
   l_ou_id           po_requisition_headers_all.org_id%TYPE  := p_ou_id;
   l_req_num         po_requisition_headers_all.segment1%TYPE  := p_req_num;
   l_line_num        po_requisition_lines_all.line_num%TYPE  := NULL;
   l_shipment_num    rcv_shipment_headers.shipment_num%TYPE := NULL;
   l_receipt_num     rcv_shipment_headers.receipt_num%TYPE := NULL;
   l_org_id          rcv_shipment_headers.organization_id%TYPE := NULL;

BEGIN

    p_sql(1) := ' select distinct prh.*' ||
 ' from po_requisition_headers_all prh,' ||
 ' po_requisition_lines_all prl' ||
 ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
 ' and prl.requisition_header_id = prh.requisition_header_id' ||
 ' and prl.source_type_code = ''INVENTORY'' ';



       p_sql(2) := ' select distinct prl.*' ||
 ' from po_requisition_lines_all prl,' ||
 ' po_requisition_headers_all prh ' ||
       ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
 ' and prl.source_type_code = ''INVENTORY''' ||
 ' order by prl.requisition_line_id ';



    p_sql(3) := ' select distinct prd.*' ||
  ' from po_req_distributions_all prd ,' ||
  ' po_requisition_lines_all prl ,' ||
  ' po_requisition_headers_all prh' ||
  ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
  ' and prh.requisition_header_id = prl.requisition_header_id' ||
  ' and prl.requisition_line_id = prd.requisition_line_id' ||
  ' and prl.source_type_code = ''INVENTORY''' ||
  ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
  ' order by prd.distribution_id ';



    p_sql(4) := ' select distinct oel.*' ||
  ' from oe_order_lines_all oel,' ||
  ' po_requisition_lines_all prl,' ||
  ' po_requisition_headers_all prh' ||
  ' where oel.source_document_type_id = 10' ||
  ' and oel.source_document_line_id = prl.requisition_line_id' ||
  ' and prl.requisition_header_id = prh.requisition_header_id' ||
  ' and prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
  ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
  ' order by oel.line_id ';


    p_sql(5) := ' select distinct wsh.* ' ||
  ' from wsh_delivery_details wsh , wsh_delivery_assignments wda , wsh_new_deliveries wnd , oe_order_lines_all sol ,
po_requisition_lines_all ' ||
   ' prl , po_requisition_headers_all prh ' ||
   ' where wsh.source_line_id = sol.line_id ' ||
   ' and wsh.delivery_detail_id = wda.delivery_detail_id ' ||
   ' and wda.delivery_id = wnd.delivery_id ' ||
   ' and sol.source_document_line_id = prl.requisition_line_id ' ||
   ' and sol.source_document_type_id = 10 ' ||
   ' and prl.requisition_header_id = prh.requisition_header_id ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' union all ' ||
 ' select distinct wsh.* ' ||
' from wsh_delivery_details wsh , mtl_transactions_interface mti , po_requisition_lines_all prl ,
po_requisition_headers_all prh , ' ||
  ' oe_order_lines_all sol ' ||
' where prl.requisition_header_id = prh.requisition_header_id ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and sol.source_document_type_id = 10 ' ||
   ' and sol.source_document_line_id = prl.requisition_line_id ' ||
   ' and mti.trx_source_line_id = sol.line_id ' ||
   ' and mti.picking_line_id = wsh.delivery_detail_id  ';


    p_sql(6) := ' select distinct rhi.*' ||
 ' from rcv_headers_interface rhi, ' ||
  ' rcv_transactions_interface rti,' ||
       ' po_requisition_headers_all prh , ' ||
       ' po_requisition_lines_all prl       ' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
   ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and rhi.header_interface_id = rti.header_interface_id' ||
   ' order by rhi.header_interface_id ';




    p_sql(7) := ' select distinct rti.*' ||
     ' from rcv_transactions_interface rti , ' ||
     ' po_requisition_headers_all prh , ' ||
          ' po_requisition_lines_all prl   ' ||
          ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
     ' and prh.requisition_header_id = prl.requisition_header_id   ' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
     ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1) ';



               p_sql(8) := ' select distinct pie.*    ' ||
  ' from po_interface_errors pie , ' ||
  ' rcv_transactions_interface rti , ' ||
       ' po_requisition_headers_all prh , ' ||
       ' po_requisition_lines_all prl    ' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
    ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and (pie.interface_transaction_id = rti.interface_transaction_id' ||
   ' or pie.interface_line_id = rti.interface_transaction_id)' ||
        ' and pie.table_name =   ''RCV_TRANSACTIONS_INTERFACE'' ';




           p_sql(9) := ' select distinct  rsh.* ' ||
' from rcv_shipment_headers rsh , rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all prl
' ||
  ' where rsl.shipment_header_id = rsh.shipment_header_id ' ||
 ' and prh.requisition_header_id = prl.requisition_header_id ' ||
   ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and rsh.receipt_source_code = ''INTERNAL ORDER'' ' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ;


       p_sql(10) := ' select distinct rsl.*' ||
' from rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all prl ' ||
  ' where prh.requisition_header_id = prl.requisition_header_id ' ||
 ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id;


       p_sql(11) := ' select distinct rt.* ' ||
' from rcv_transactions rt , po_requisition_headers_all prh , po_requisition_lines_all prl ' ||
  ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.requisition_header_id = prl.requisition_header_id ' ||
   ' and rt.source_document_code =  ''REQ'' ' ||
   ' and rt.requisition_line_id = prl.requisition_line_id ' ||
   ' and prh.org_id = ' || l_ou_id ;


       p_sql(12) := ' select distinct ms.* ' ||
' from mtl_supply ms , po_requisition_headers_all prh , po_requisition_lines_all prl ' ||
  ' where ms.req_line_id = prl.requisition_line_id ' ||
 ' and prh.requisition_header_id = prl.requisition_header_id ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ;


       p_sql(13) := ' select distinct rs.* ' ||
' from rcv_supply rs , po_requisition_headers_all prh , po_requisition_lines_all prl' ||
  ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id ' ||
   ' and rs.req_line_id = prl.requisition_line_id ';

/*       p_sql(14) := ' select distinct mtrl.*' ||
' from mtl_txn_request_lines mtrl,' ||
  ' rcv_shipment_lines rsl,' ||
       ' po_requisition_headers_all prh,' ||
       ' po_requisition_lines_all prl' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and rsl.requisition_line_id = prl.requisition_line_id' ||
   ' and mtrl.reference = ''SHIPMENT_LINE_ID''' ||
   ' and rsl.source_document_code = ''REQ''' ||
   ' and mtrl.reference_id = rsl.shipment_line_id ';*/

p_sql(14) := ' select distinct mtrl.* ' ||
' from mtl_txn_request_lines mtrl, ' ||
     ' po_requisition_headers_all prh, ' ||
     ' po_requisition_lines_all prl ' ||
' where prh.segment1 =  '|| '''' || l_req_num || '''' ||
' and prh.org_id = '|| l_ou_id ||
' and prh.requisition_header_id = prl.requisition_header_id ' ||
' and mtrl.inventory_item_id=prl.item_id ' ||
' and nvl(mtrl.revision,0)=nvl(prl.item_revision,0) ' ||
' and mtrl.organization_id=prl.destination_organization_id' ||
' and mtrl.transaction_type_id=52'||
' and mtrl.line_status=7';


       p_sql(15) := ' select distinct mti.*' ||
' from mtl_transactions_interface mti,' ||
  ' po_requisition_lines_all prl,' ||
       ' po_requisition_headers_all prh,' ||
       ' oe_order_lines_all sol' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and sol.source_document_line_id = prl.requisition_line_id' ||
   ' and sol.source_document_type_id = 10' ||
   ' and mti.trx_source_line_id = sol.line_id' ||
   ' and mti.source_code = ''ORDER ENTRY'' ';


   p_sql(16) := ' select distinct mmtt.*  ' ||
' from mtl_material_transactions_temp mmtt , ' ||
 ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh, ' ||
      ' rcv_transactions rt' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
  ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
  ' and prl.source_type_code = ''INVENTORY''' ||
  ' and rt.requisition_line_id = prl.requisition_line_id  ' ||
  ' and mmtt.rcv_transaction_id = rt.transaction_id ' ||
  ' UNION ALL' ||
' select distinct mmtt.*  ' ||
' from mtl_material_transactions_temp mmtt,  ' ||
' po_requisition_lines_all prl,  ' ||
     ' po_requisition_headers_all prh,' ||
     ' oe_order_lines_all sol   ' ||
     ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
  ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
  ' and prl.source_type_code = ''INVENTORY''' ||
  ' and sol.source_document_type_id = 10  ' ||
  ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
  ' and mmtt.trx_source_line_id = sol.line_id ';



      p_sql(17) := ' select distinct mmt.*  ' ||
' from mtl_material_transactions mmt,  ' ||
 ' po_requisition_lines_all prl,  ' ||
   ' po_requisition_headers_all prh  , ' ||
        ' rcv_transactions rt' ||
        ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
        ' and prh.org_id = ' || l_ou_id ||
  ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and mmt.rcv_transaction_id = rt.transaction_id  ' ||
    ' and rt.requisition_line_id = prl.requisition_line_id' ||
    ' UNION ALL' ||
' select distinct mmt.*  ' ||
' from mtl_material_transactions mmt,  ' ||
' po_requisition_lines_all prl,  ' ||
   ' po_requisition_headers_all prh,' ||
        ' oe_order_lines_all sol   ' ||
        ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
        ' and prh.org_id = ' || l_ou_id ||
  ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and sol.source_document_type_id = 10  ' ||
    ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
    ' and mmt.trx_source_line_id = sol.line_id' ||
    ' and mmt.transaction_action_id=21  ';


       p_sql(18) := ' select distinct mr.* ' ||
' from mtl_reservations mr , oe_order_lines_all sol , po_requisition_lines_all prl , po_requisition_headers_all prh ' ||
  ' where sol.source_document_line_id = prl.requisition_line_id ' ||
 ' and prl.requisition_header_id = prh.requisition_header_id ' ||
   ' and sol.source_document_type_id = 10 ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and mr.demand_source_line_id = sol.line_id ' ||
   ' and mr.demand_source_type_id = 8 ' ||
   ' union all ' ||
 ' select distinct mr.* ' ||
' from mtl_reservations mr , mtl_transactions_interface mti , po_requisition_lines_all prl , po_requisition_headers_all
prh , ' ||
  ' oe_order_lines_all sol ' ||
' where prl.requisition_header_id = prh.requisition_header_id ' ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and sol.source_document_type_id = 10 ' ||
   ' and sol.source_document_line_id = prl.requisition_line_id ' ||
   ' and mti.trx_source_line_id = sol.line_id ' ||
   ' and mr.demand_source_line_id = mti.trx_source_line_id 	 ';



       p_sql(19) := ' select distinct md.* ' ||
' from mtl_demand md , oe_order_lines_all sol , po_requisition_lines_all prl , po_requisition_headers_all prh ' ||
  ' where sol.source_document_line_id = prl.requisition_line_id ' ||
 ' and sol.source_document_type_id = 10 ' ||
   ' and prl.requisition_header_id = prh.requisition_header_id ' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and md.demand_source_line = sol.line_id ' ||
   ' and md.demand_source_type = 8 ' ||
   ' union all ' ||
 ' select distinct md.* ' ||
' from mtl_demand md , mtl_transactions_interface mti , po_requisition_lines_all prl , po_requisition_headers_all prh ,
oe_order_lines_all ' ||
  ' sol ' ||
' where prl.requisition_header_id = prh.requisition_header_id ' ||
 ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and sol.source_document_type_id = 10 ' ||
   ' and sol.source_document_line_id = prl.requisition_line_id ' ||
   ' and mti.trx_source_line_id = sol.line_id ' ||
   ' and md.demand_source_line = mti.source_line_id  ';


              p_sql(20) := ' select distinct msn.*   ' ||
' from mtl_serial_numbers msn , ' ||
 ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh ,' ||
      ' rcv_transactions rt' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prl.requisition_header_id = prh.requisition_header_id   ' ||
  ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and mmt.rcv_transaction_id = rt.transaction_id  ' ||
    ' and rt.requisition_line_id = prl.requisition_line_id' ||
    ' and mmt.transaction_id = msn.last_transaction_id' ||
    ' UNION ALL' ||
' select distinct msn.*    ' ||
 ' from mtl_serial_numbers msn , ' ||
         ' mtl_material_transactions mmt , ' ||
              ' po_requisition_lines_all prl , ' ||
              ' po_requisition_headers_all prh ,' ||
              ' oe_order_lines_all sol   ' ||
              ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
        ' and prl.requisition_header_id = prh.requisition_header_id   ' ||
          ' and prh.org_id = ' || l_ou_id ||
          ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
          ' and prl.source_type_code = ''INVENTORY''' ||
          ' and sol.source_document_type_id = 10   ' ||
          ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
          ' and mmt.trx_source_line_id = sol.line_id   ' ||
          ' and mmt.rcv_transaction_id is null ' ||
          ' and mmt.transaction_id = msn.last_transaction_id  ';




              p_sql(21) := ' select DISTINCT msnt.*' ||
' from    po_requisition_lines_all prl ,' ||
' po_requisition_headers_all prh ,' ||
        ' mtl_serial_numbers_temp msnt ,' ||
        ' mtl_system_items msi,' ||
        ' rcv_transactions_interface rti' ||
        ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
    ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and rti.interface_transaction_id = msnt.transaction_temp_id' ||
    ' and msi.inventory_item_id           = rti.item_id' ||
    ' and msi.organization_id             = rti.to_organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code       = 1' ||
    ' UNION ALL' ||
' select DISTINCT msnt.*' ||
' from    po_requisition_lines_all prl ,' ||
' po_requisition_headers_all prh ,' ||
        ' mtl_serial_numbers_temp msnt ,' ||
        ' mtl_transaction_lots_temp mtlt,' ||
        ' mtl_system_items msi,' ||
        ' rcv_transactions_interface rti' ||
         ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
    ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and rti.interface_transaction_id = mtlt.transaction_temp_id' ||
    ' and mtlt.SERIAL_TRANSACTION_TEMP_ID = msnt.transaction_temp_id' ||
    ' and msi.inventory_item_id           = rti.item_id' ||
    ' and msi.organization_id             = rti.to_organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code       <> 1' ||
    ' UNION ALL' ||
' select DISTINCT msnt.*' ||
' from    po_requisition_lines_all prl,' ||
' po_requisition_headers_all prh,' ||
        ' mtl_serial_numbers_temp msnt,' ||
        ' mtl_system_items msi,' ||
        ' oe_order_lines_all sol,' ||
        ' mtl_material_transactions_temp mmtt' ||
        ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and sol.source_document_line_id = prl.requisition_line_id' ||
    ' and sol.source_document_type_id = 10' ||
    ' and mmtt.trx_source_line_id = sol.line_id' ||
    ' and msnt.transaction_TEMP_id = mmtt.transaction_TEMP_id' ||
    ' and msi.inventory_item_id           = mmtt.inventory_item_id' ||
    ' and msi.organization_id             = mmtt.organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code       = 1' ||
    ' UNION ALL' ||
' select DISTINCT msnt.*' ||
' from    po_requisition_lines_all prl,' ||
' po_requisition_headers_all prh,' ||
        ' mtl_serial_numbers_temp msnt,' ||
        ' mtl_transaction_lots_temp mtlt,' ||
        ' mtl_system_items msi,' ||
        ' oe_order_lines_all sol,' ||
        ' mtl_material_transactions_temp mmtt' ||
        ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and sol.source_document_line_id = prl.requisition_line_id' ||
    ' and sol.source_document_type_id = 10' ||
    ' and mmtt.trx_source_line_id = sol.line_id' ||
    ' and mmtt.transaction_TEMP_id = mtlt.transaction_TEMP_id' ||
    ' and mtlt.serial_transaction_temp_id = msnt.transaction_temp_id' ||
    ' and msi.inventory_item_id           = mmtt.inventory_item_id' ||
    ' and msi.organization_id             = mmtt.organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code       <> 1 ';



        p_sql(22) := ' select distinct msni.*    ' ||
  ' from rcv_transactions_interface rti ,' ||
  ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh , ' ||
       ' mtl_serial_numbers_interface msni ,' ||
       ' mtl_system_items msi' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
    ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and rti.interface_transaction_id = msni.product_transaction_id' ||
    ' and msi.inventory_item_id = rti.item_id' ||
    ' and msi.organization_id = rti.to_organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code = 1' ||
    ' UNION ALL' ||
' select distinct msni.*    ' ||
  ' from rcv_transactions_interface rti ,' ||
  ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh , ' ||
       ' mtl_serial_numbers_interface msni ,' ||
       ' mtl_transaction_lots_interface mtli,' ||
       ' mtl_system_items msi' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
    ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and rti.interface_transaction_id = mtli.product_transaction_id' ||
    ' and mtli.serial_transaction_temp_id = msni.transaction_interface_id ' ||
    ' and msi.inventory_item_id = rti.item_id' ||
    ' and msi.organization_id = rti.to_organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code <> 1 ';




        p_sql(23) := ' select distinct mut.*    ' ||
  ' from mtl_material_transactions mmt , ' ||
  ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh , ' ||
       ' mtl_unit_transactions mut ,    ' ||
       ' mtl_system_items msi,' ||
       ' rcv_transactions rt' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
     ' and prl.requisition_header_id = prh.requisition_header_id' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and rt.requisition_line_id = prl.requisition_line_id    ' ||
     ' and mmt.rcv_transaction_id = rt.transaction_id    ' ||
     ' and mmt.transaction_id = mut.transaction_id    ' ||
     ' and msi.inventory_item_id = mmt.inventory_item_id    ' ||
     ' and msi.organization_id = mmt.organization_id    ' ||
     ' and msi.serial_number_control_code <> 1     ' ||
     ' and msi.lot_control_code = 1    ' ||
     ' union all    ' ||
     ' select distinct mut.*' ||
   ' from mtl_material_transactions mmt ,' ||
  ' po_requisition_lines_all prl ,' ||
       ' po_requisition_headers_all prh ,' ||
       ' mtl_unit_transactions mut ,    ' ||
       ' mtl_system_items msi , ' ||
       ' rcv_transactions rt , ' ||
       ' mtl_transaction_lot_numbers mtln    ' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
     ' and prl.requisition_header_id = prh.requisition_header_id    ' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and rt.requisition_line_id = prl.requisition_line_id    ' ||
     ' and mmt.rcv_transaction_id = rt.transaction_id    ' ||
     ' and mtln.transaction_id = mmt.transaction_id    ' ||
     ' and mut.transaction_id = mtln.serial_transaction_id    ' ||
     ' and msi.inventory_item_id = mmt.inventory_item_id    ' ||
     ' and msi.organization_id = mmt.organization_id' ||
     ' and msi.serial_number_control_code <> 1' ||
     ' and msi.lot_control_code <> 1' ||
     ' union all' ||
' select distinct mut.*    ' ||
   ' from mtl_material_transactions mmt , ' ||
  ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh , ' ||
       ' mtl_unit_transactions mut ,    ' ||
       ' mtl_system_items msi , ' ||
       ' oe_order_lines_all sol    ' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
     ' and prl.requisition_header_id = prh.requisition_header_id' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and sol.source_document_line_id = prl.requisition_line_id' ||
     ' and sol.source_document_type_id = 10' ||
     ' and mmt.trx_source_line_id = sol.line_id     ' ||
     ' and mut.transaction_id = mmt.transaction_id' ||
     ' and msi.inventory_item_id = mmt.inventory_item_id' ||
     ' and msi.organization_id = mmt.organization_id' ||
     ' and msi.serial_number_control_code <> 1' ||
     ' and msi.lot_control_code = 1' ||
     ' union all' ||
     ' select distinct mut.*' ||
   ' from mtl_material_transactions mmt , ' ||
  ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh , ' ||
       ' mtl_unit_transactions mut ,    ' ||
       ' mtl_system_items msi , ' ||
       ' oe_order_lines_all sol , ' ||
       ' mtl_transaction_lot_numbers mtln    ' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
     ' and prl.requisition_header_id = prh.requisition_header_id' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and sol.source_document_line_id = prl.requisition_line_id' ||
     ' and sol.source_document_type_id = 10' ||
     ' and mmt.trx_source_line_id = sol.line_id' ||
     ' and mtln.transaction_id = mmt.transaction_id' ||
     ' and mut.transaction_id = mtln.serial_transaction_id' ||
     ' and msi.inventory_item_id = mmt.inventory_item_id' ||
     ' and msi.organization_id = mmt.organization_id' ||
     ' and msi.serial_number_control_code <> 1' ||
     ' and msi.lot_control_code <> 1      ';



       p_sql(24) := ' select distinct rss.* ' ||
' from rcv_serials_supply rss , rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all prl '
||
  ' where prh.requisition_header_id = prl.requisition_header_id ' ||
 ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and rss.shipment_line_id = rsl.shipment_line_id ' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
' order by rss.supply_type_code , rss.serial_num  ';


       p_sql(25) := ' select distinct rst.* ' ||
' from rcv_serial_transactions rst , rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all
prl ' ||
  ' where prh.requisition_header_id = prl.requisition_header_id ' ||
 ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and rst.shipment_line_id = rsl.shipment_line_id ' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
' order by rst.serial_transaction_type , rst.serial_num  ';


       p_sql(26) := ' select distinct rsi.* ' ||
' from rcv_serials_interface rsi , rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all
prl ' ||
  ' where prh.requisition_header_id = prl.requisition_header_id ' ||
 ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and rsi.item_id = rsl.item_id ' ||
   ' and rsi.organization_id = rsl.to_organization_id  ';


        p_sql(27) := ' select distinct  mln.*   ' ||
' from mtl_lot_numbers mln , ' ||
 ' mtl_transaction_lot_numbers mtln , ' ||
      ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl ,   ' ||
      ' po_requisition_headers_all prh , ' ||
      ' rcv_transactions rt' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
    ' and prl.requisition_header_id = prh.requisition_header_id   ' ||
    ' and rt.requisition_line_id = prl.requisition_line_id' ||
    ' and mmt.rcv_transaction_id = rt.transaction_id' ||
    ' and mmt.transaction_id = mtln.transaction_id   ' ||
    ' and mln.inventory_item_id = mmt.inventory_item_id   ' ||
    ' and mln.organization_id = mmt.organization_id   ' ||
    ' and mln.lot_number = mtln.lot_number ' ||
    ' UNION ALL' ||
' select distinct  mln.*   ' ||
' from mtl_lot_numbers mln , ' ||
 ' mtl_transaction_lot_numbers mtln , ' ||
      ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl ,   ' ||
      ' po_requisition_headers_all prh , ' ||
      ' oe_order_lines_all sol' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
' and prh.org_id = ' || l_ou_id ||
    ' and prl.requisition_header_id = prh.requisition_header_id   ' ||
    ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
    ' and sol.source_document_type_id = 10   ' ||
    ' and mmt.transaction_id = mtln.transaction_id   ' ||
    ' and mmt.trx_source_line_id = sol.line_id' ||
    ' and mln.inventory_item_id = mmt.inventory_item_id   ' ||
    ' and mln.organization_id = mmt.organization_id   ' ||
    ' and mln.lot_number = mtln.lot_number ';



        p_sql(28) := ' select distinct mtln.*   ' ||
' from mtl_transaction_lot_numbers mtln , ' ||
 ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh ,' ||
      ' rcv_transactions rt' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prl.requisition_header_id = prh.requisition_header_id   ' ||
   ' and rt.requisition_line_id = prl.requisition_line_id' ||
   ' and mmt.rcv_transaction_id = rt.transaction_id' ||
   ' and mmt.transaction_id = mtln.transaction_id' ||
   ' UNION ALL' ||
' select distinct mtln.*   ' ||
' from mtl_transaction_lot_numbers mtln , ' ||
 ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh ,' ||
      ' oe_order_lines_all sol' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
' and prh.org_id = ' || l_ou_id ||
  ' and prl.requisition_header_id = prh.requisition_header_id       ' ||
  ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
  ' and sol.source_document_type_id = 10   ' ||
  ' and mmt.trx_source_line_id = sol.line_id   ' ||
  ' and mmt.transaction_id = mtln.transaction_id ';



             p_sql(29) := ' select distinct mtli.*   ' ||
' from mtl_transaction_lots_interface mtli , ' ||
 ' mtl_transactions_interface mti , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh ' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and mti.requisition_line_id = prl.requisition_line_id' ||
   ' and mti.transaction_interface_id = mtli.transaction_interface_id' ||
   ' UNION ALL' ||
' select distinct mtli.*   ' ||
' from mtl_transaction_lots_interface mtli , ' ||
 ' rcv_transactions_interface rti , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh ' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and rti.interface_transaction_id = mtli.product_transaction_id' ||
   ' and mtli.product_code =''RCV''' ||
   ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
   ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' ) ';


p_sql(30) := ' select distinct mtlt.*   ' ||
' from mtl_transaction_lots_temp mtlt ,' ||
  ' rcv_transactions_interface rti, ' ||
       ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh    ' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and rti.interface_transaction_id = mtlt.product_transaction_id' ||
   ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
   ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' UNION ALL' ||
  ' select distinct mtlt.*   ' ||
  ' from mtl_transaction_lots_temp mtlt ,' ||
  ' mtl_material_transactions_temp mmtt,' ||
       ' rcv_transactions_interface rti, ' ||
       ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh,' ||
       ' oe_order_lines_all sol' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
   ' and sol.source_document_type_id = 10   ' ||
   ' and mmtt.trx_source_line_id = sol.line_id ';



       p_sql(31) := ' select distinct rls.* ' ||
' from rcv_lots_supply rls , rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all prl' ||
  ' where rsl.shipment_line_id = rls.shipment_line_id ' ||
 ' and prh.requisition_header_id = prl.requisition_header_id ' ||
   ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ;


       p_sql(32) := ' select distinct rlt.* ' ||
' from rcv_lot_transactions rlt , rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all prl
' ||
' where rsl.shipment_line_id = rlt.shipment_line_id ' ||
 ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and prh.requisition_header_id = prl.requisition_header_id ' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ;


       p_sql(33) := ' select distinct rli.* ' ||
' from rcv_lots_interface rli , rcv_transactions_interface rti , po_requisition_headers_all prh ,
po_requisition_lines_all prl ' ||
  ' where prh.requisition_header_id = prl.requisition_header_id ' ||
  ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
  ' and (nvl(rti.requisition_line_id,-99) = prl.requisition_line_id ' ||
  ' or (nvl(rti.req_num , ''-99999'') = prh.segment1 ) )' ||
  ' AND rli.interface_transaction_id = rti.interface_transaction_id ';


    p_sql(34) := ' select distinct  msi.*' ||
' from po_requisition_lines_all prl,' ||
  ' po_requisition_headers_all prh,' ||
       ' mtl_system_items msi' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prl.item_id = msi.inventory_item_id' ||
   ' and prl.destination_organization_id = msi.organization_id ';



  p_sql(35) := ' select distinct  mtt.transaction_type_id ,   ' ||
' mtt.transaction_type_name ,  ' ||
 ' mtt.transaction_source_type_id ,   ' ||
                 ' mtt.transaction_action_id ,   ' ||
                 ' mtt.user_defined_flag ,   ' ||
                 ' mtt.disable_date   ' ||
                 ' from mtl_transaction_types mtt ,  ' ||
  ' mtl_material_transactions mmt ,   ' ||
       ' po_requisition_lines_all prl ,   ' ||
       ' po_requisition_headers_all prh ,' ||
       ' rcv_transactions rt' ||
       ' where prl.requisition_header_id = prh.requisition_header_id   ' ||
 ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' and mmt.rcv_transaction_id = rt.transaction_id  ' ||
    ' and rt.requisition_line_id = prl.requisition_line_id' ||
    ' and mmt.transaction_type_id = mtt.transaction_type_id' ||
    ' UNION ALL' ||
    ' select distinct  mtt.transaction_type_id ,   ' ||
        ' mtt.transaction_type_name ,  ' ||
                 ' mtt.transaction_source_type_id ,   ' ||
                 ' mtt.transaction_action_id ,   ' ||
                 ' mtt.user_defined_flag ,   ' ||
                 ' mtt.disable_date    ' ||
                 ' from mtl_transaction_types mtt ,  ' ||
         ' mtl_material_transactions mmt ,   ' ||
              ' po_requisition_lines_all prl ,   ' ||
              ' po_requisition_headers_all prh,' ||
              ' oe_order_lines_all sol   ' ||
              ' where prl.requisition_header_id = prh.requisition_header_id   ' ||
        ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
          ' and prh.org_id = ' || l_ou_id ||
          ' and sol.source_document_type_id = 10   ' ||
          ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
          ' and mmt.trx_source_line_id = sol.line_id   ' ||
          ' and mmt.transaction_type_id = mtt.transaction_type_id ';



      p_sql(36) := ' select distinct ood.* ' ||
' from org_organization_definitions ood ' ||
  ' where exists (' ||
 ' select 1  ' ||
    ' from po_requisition_headers_all prh , po_requisition_lines_all prl , financials_system_params_all fsp ' ||
      ' where prl.requisition_header_id = prh.requisition_header_id ' ||
     ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
       ' and prh.org_id = ' || l_ou_id ||
       ' and prh.type_lookup_code in (''INTERNAL'',''PURCHASE'')' ||
       ' and (prl.destination_organization_id = ood.organization_id ' ||
       ' or prl.source_organization_id = ood.organization_id ' ||
           ' or (prh.org_id = fsp.org_id ' ||
           ' and ood.organization_id = fsp.inventory_organization_id ) ) )  ';



      p_sql(37) := ' select distinct  mp.* ' ||
' from mtl_parameters mp , po_requisition_headers_all prh , po_requisition_lines_all prl ' ||
  ' where prl.requisition_header_id = prh.requisition_header_id ' ||
 ' and prh.type_lookup_code = ''INTERNAL'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and (prl.destination_organization_id = mp.organization_id ' ||
   ' or prl.source_organization_id = mp.organization_id ) ' ||
       ' and prh.org_id = ' || l_ou_id ;


       p_sql(38) := ' select distinct miop.* ' ||
' from mtl_interorg_parameters miop ' ||
  ' where exists (' ||
 ' select 1  ' ||
    ' from po_requisition_headers_all prh , po_requisition_lines_all prl ' ||
      ' where prl.requisition_header_id = prh.requisition_header_id ' ||
     ' and prh.type_lookup_code = ''INTERNAL'' ' ||
       ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
       ' and (prl.destination_organization_id = miop.to_organization_id ' ||
       ' and prl.source_organization_id = miop.from_organization_id ) ' ||
           ' and prh.org_id = ' || l_ou_id || ')';


           p_sql(39) := ' select distinct rp.* ' ||
' from rcv_parameters rp ' ||
  ' where exists (' ||
 ' select 1  ' ||
    ' from po_requisition_headers_all prh , po_requisition_lines_all prl , financials_system_params_all fsp ' ||
      ' where prl.requisition_header_id = prh.requisition_header_id ' ||
     ' and prh.type_lookup_code = ''INTERNAL'' ' ||
       ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
       ' and (prl.destination_organization_id = rp.organization_id ' ||
       ' or prl.source_organization_id = rp.organization_id ' ||
           ' or (prh.org_id = fsp.org_id ' ||
           ' and rp.organization_id = fsp.inventory_organization_id ) ) ' ||
               ' and prh.org_id = ' || l_ou_id || ')';



     p_sql(40) := ' select distinct lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_LOT_CONTROL''  ';


     p_sql(41) := ' select distinct lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_LOT_GENERATION''  ';


     p_sql(42) := ' select distinct lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_LOT_UNIQUENESS''  ';

     p_sql(43) := ' select distinct lookup_type , lookup_code , meaning , enabled_flag , start_date_active ,
end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_SERIAL_NUMBER''  ';


     p_sql(44) := ' select distinct lookup_type , lookup_code , meaning , enabled_flag , start_date_active ,
end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_SERIAL_NUMBER_TYPE''  ';


     p_sql(45) := ' select distinct lookup_type , lookup_code , meaning , enabled_flag , start_date_active ,
end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_SERIAL_GENERATION''  ';


     p_sql(46) := ' select distinct lookup_type , lookup_code , meaning , enabled_flag , start_date_active ,
end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''SERIAL_NUM_STATUS''  ';


RETURN;
END;


PROCEDURE req_line_sql(p_ou_id IN NUMBER, p_req_num IN VARCHAR2, p_line_num IN NUMBER, p_sql IN OUT NOCOPY
INV_DIAG_RCV_PO_COMMON.sqls_list) IS

   l_ou_id           po_requisition_headers_all.org_id%TYPE  := p_ou_id;
   l_req_num         po_requisition_headers_all.segment1%TYPE  := p_req_num;
   l_line_num        po_requisition_lines_all.line_num%TYPE  := p_line_num;
   l_shipment_num    rcv_shipment_headers.shipment_num%TYPE := NULL;
   l_receipt_num     rcv_shipment_headers.receipt_num%TYPE := NULL;
   l_org_id          rcv_shipment_headers.organization_id%TYPE := NULL;

BEGIN

    p_sql(1) := ' select distinct prh.*' ||
' from po_requisition_headers_all prh,' ||
  ' po_requisition_lines_all prl' ||
       ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
 'and prh.org_id = ' || l_ou_id ||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and prl.source_type_code = ''INVENTORY'' ';


       p_sql(2) := ' select distinct prl.*' ||
' from po_requisition_lines_all prl,' ||
  ' po_requisition_headers_all prh ' ||
       ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and prl.source_type_code = ''INVENTORY'' ';


       p_sql(3) := ' select distinct prd.*' ||
' from po_req_distributions_all prd ,' ||
  ' po_requisition_lines_all prl ,' ||
       ' po_requisition_headers_all prh' ||
       ' where prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'')' ||
 ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.requisition_line_id = prd.requisition_line_id' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' order by prd.distribution_id ';


    p_sql(4) := ' select distinct oel.*' ||
' from oe_order_lines_all oel,' ||
  ' po_requisition_lines_all prl,' ||
       ' po_requisition_headers_all prh' ||
       ' where oel.source_document_type_id = 10' ||
 ' and oel.source_document_line_id = prl.requisition_line_id' ||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prh.segment1 = ''123'' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
      ' order by oel.line_id ';


   p_sql(5) := ' select distinct wsh.* ' ||
' from wsh_delivery_details wsh , wsh_delivery_assignments wda , wsh_new_deliveries wnd , oe_order_lines_all sol ,
po_requisition_lines_all ' ||
  ' prl , po_requisition_headers_all prh ' ||
' where wsh.source_line_id = sol.line_id ' ||
 ' and wsh.delivery_detail_id = wda.delivery_detail_id ' ||
   ' and wda.delivery_id = wnd.delivery_id ' ||
   ' and sol.source_document_line_id = prl.requisition_line_id ' ||
   ' and sol.source_document_type_id = 10 ' ||
   ' and prh.type_lookup_code = ''INTERNAL'' ' ||
   ' and prl.requisition_header_id = prh.requisition_header_id ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' union all ' ||
 ' select distinct wsh.* ' ||
' from wsh_delivery_details wsh , mtl_transactions_interface mti , po_requisition_lines_all prl ,
po_requisition_headers_all prh , ' ||
  ' oe_order_lines_all sol ' ||
' where prl.requisition_header_id = prh.requisition_header_id ' ||
 ' and prh.type_lookup_code = ''INTERNAL'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and sol.source_document_type_id = 10 ' ||
   ' and sol.source_document_line_id = prl.requisition_line_id ' ||
   ' and mti.trx_source_line_id = sol.line_id ' ||
   ' and mti.picking_line_id = wsh.delivery_detail_id  ';


    p_sql(6) := ' select distinct rhi.*' ||
 ' from rcv_headers_interface rhi, ' ||
  ' rcv_transactions_interface rti,' ||
       ' po_requisition_headers_all prh , ' ||
       ' po_requisition_lines_all prl       ' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
   ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and rhi.header_interface_id = rti.header_interface_id' ||
   ' order by rhi.header_interface_id ';



    p_sql(7) := ' select distinct rti.*' ||
     ' from rcv_transactions_interface rti , ' ||
     ' po_requisition_headers_all prh , ' ||
          ' po_requisition_lines_all prl   ' ||
          ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
     ' and prh.requisition_header_id = prl.requisition_header_id   ' ||
     ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
     ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1) ';



               p_sql(8) := ' select distinct pie.*    ' ||
  ' from po_interface_errors pie , ' ||
  ' rcv_transactions_interface rti , ' ||
       ' po_requisition_headers_all prh , ' ||
       ' po_requisition_lines_all prl    ' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
    ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and (pie.interface_transaction_id = rti.interface_transaction_id' ||
   ' or pie.interface_line_id = rti.interface_transaction_id)' ||
        ' and pie.table_name =   ''RCV_TRANSACTIONS_INTERFACE'' ';


                   p_sql(9) := ' select distinct  rsh.* ' ||
' from rcv_shipment_headers rsh , rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all prl
' ||
  ' where rsl.shipment_header_id = rsh.shipment_header_id ' ||
 ' and prh.requisition_header_id = prl.requisition_header_id ' ||
   ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and rsh.receipt_source_code = ''INTERNAL ORDER'' ' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)';



       p_sql(10) := ' select distinct rsl.*' ||
' from rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all prl ' ||
  ' where prh.requisition_header_id = prl.requisition_header_id ' ||
 ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)';


          p_sql(11) := ' select distinct rt.* ' ||
' from rcv_transactions rt , po_requisition_headers_all prh , po_requisition_lines_all prl ' ||
  ' where prh.requisition_header_id = prl.requisition_header_id ' ||
      ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and rt.requisition_line_id = prl.requisition_line_id ' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)';



          p_sql(12) := ' select distinct ms.* ' ||
' from mtl_supply ms , po_requisition_headers_all prh , po_requisition_lines_all prl ' ||
  ' where ms.req_line_id = prl.requisition_line_id ' ||
 ' and prh.requisition_header_id = prl.requisition_header_id ' ||
   ' and prh.type_lookup_code = ''INTERNAL'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)';


          p_sql(13) := ' select distinct rs.* ' ||
' from rcv_supply rs , po_requisition_headers_all prh, po_requisition_lines_all prl ' ||
  ' where rs.req_line_id = prl.requisition_line_id ' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)';


       p_sql(14) := ' select distinct mtrl.* ' ||
' from mtl_txn_request_lines mtrl, ' ||
       ' po_requisition_headers_all prh, ' ||
       ' po_requisition_lines_all prl ' ||
       ' where prh.segment1 = '|| '''' || l_req_num || '''' ||
 ' and prh.org_id =  '||l_ou_id  ||
   ' and prh.requisition_header_id = prl.requisition_header_id ' ||
' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
' and mtrl.inventory_item_id=prl.item_id ' ||
' and nvl(mtrl.revision,0)=nvl(prl.item_revision,0) ' ||
' and mtrl.organization_id=prl.destination_organization_id ' ||
' and mtrl.transaction_type_id=52'||
' and mtrl.line_status=7';

/*       ' select distinct mtrl.*' ||
' from mtl_txn_request_lines mtrl,' ||
  ' rcv_shipment_lines rsl,' ||
       ' po_requisition_headers_all prh,' ||
       ' po_requisition_lines_all prl' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and rsl.requisition_line_id = prl.requisition_line_id' ||
   ' and mtrl.reference = ''SHIPMENT_LINE_ID''' ||
   ' and rsl.source_document_code = ''REQ''' ||
   ' and mtrl.reference_id = rsl.shipment_line_id ';*/


       p_sql(15) := ' select distinct mti.*' ||
' from mtl_transactions_interface mti,' ||
  ' po_requisition_lines_all prl,' ||
       ' po_requisition_headers_all prh,' ||
       ' oe_order_lines_all sol' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and sol.source_document_type_id = 10' ||
   ' and sol.source_document_line_id = prl.requisition_line_id' ||
   ' and mti.trx_source_line_id = sol.line_id' ||
   ' and mti.source_code = ''ORDER ENTRY'' ';


   p_sql(16) := ' select distinct mmtt.*  ' ||
' from mtl_material_transactions_temp mmtt , ' ||
 ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh, ' ||
      ' rcv_transactions rt' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
  ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
  ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
  ' and prl.source_type_code = ''INVENTORY''' ||
  ' and rt.requisition_line_id = prl.requisition_line_id  ' ||
  ' and mmtt.rcv_transaction_id = rt.transaction_id ' ||
  ' UNION ALL' ||
' select distinct mmtt.*  ' ||
' from mtl_material_transactions_temp mmtt,  ' ||
' po_requisition_lines_all prl,  ' ||
     ' po_requisition_headers_all prh,' ||
     ' oe_order_lines_all sol   ' ||
     ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
  ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
  ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
  ' and prl.source_type_code = ''INVENTORY''' ||
  ' and sol.source_document_type_id = 10  ' ||
  ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
  ' and mmtt.trx_source_line_id = sol.line_id ';


      p_sql(17) := ' select distinct mmt.*  ' ||
' from mtl_material_transactions mmt,  ' ||
 ' po_requisition_lines_all prl,  ' ||
   ' po_requisition_headers_all prh  , ' ||
        ' rcv_transactions rt' ||
        ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
        ' and prh.org_id = ' || l_ou_id ||
  ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
  ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and mmt.rcv_transaction_id = rt.transaction_id  ' ||
    ' and rt.requisition_line_id = prl.requisition_line_id' ||
    ' UNION ALL' ||
' select distinct mmt.*  ' ||
' from mtl_material_transactions mmt,  ' ||
' po_requisition_lines_all prl,  ' ||
   ' po_requisition_headers_all prh,' ||
        ' oe_order_lines_all sol   ' ||
        ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
        ' and prh.org_id = ' || l_ou_id ||
  ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
  ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and sol.source_document_type_id = 10  ' ||
    ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
    ' and mmt.trx_source_line_id = sol.line_id' ||
    ' and mmt.transaction_action_id=21  ';


       p_sql(18) := ' select distinct mr.* ' ||
' from mtl_reservations mr , oe_order_lines_all sol , po_requisition_lines_all prl , po_requisition_headers_all prh ' ||
  ' where sol.source_document_line_id = prl.requisition_line_id ' ||
 ' and prl.requisition_header_id = prh.requisition_header_id ' ||
   ' and prh.type_lookup_code = ''INTERNAL'' ' ||
   ' and sol.source_document_type_id = 10 ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and mr.demand_source_line_id = sol.line_id ' ||
   ' and mr.demand_source_type_id = 8 ' ||
   ' union all ' ||
 ' select distinct mr.* ' ||
' from mtl_reservations mr , mtl_transactions_interface mti , po_requisition_lines_all prl , po_requisition_headers_all
prh , ' ||
  ' oe_order_lines_all sol ' ||
' where prl.requisition_header_id = prh.requisition_header_id ' ||
 ' and prh.type_lookup_code = ''INTERNAL'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and sol.source_document_type_id = 10 ' ||
   ' and sol.source_document_line_id = prl.requisition_line_id ' ||
   ' and mti.trx_source_line_id = sol.line_id ' ||
   ' and mr.demand_source_line_id = mti.trx_source_line_id  ';

   p_sql(19) := ' select distinct md.* ' ||
' from mtl_demand md , oe_order_lines_all sol , po_requisition_lines_all prl , po_requisition_headers_all prh ' ||
  ' where sol.source_document_line_id = prl.requisition_line_id ' ||
 ' and sol.source_document_type_id = 10 ' ||
   ' and prl.requisition_header_id = prh.requisition_header_id ' ||
   ' and prh.type_lookup_code = ''INTERNAL'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and md.demand_source_line = sol.line_id ' ||
   ' and md.demand_source_type = 8 ' ||
   ' union all ' ||
 ' select distinct md.* ' ||
' from mtl_demand md , mtl_transactions_interface mti , po_requisition_lines_all prl , po_requisition_headers_all prh ,
oe_order_lines_all ' ||
  ' sol ' ||
' where prl.requisition_header_id = prh.requisition_header_id ' ||
 ' and prh.type_lookup_code = ''INTERNAL'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and sol.source_document_type_id = 10 ' ||
   ' and sol.source_document_line_id = prl.requisition_line_id ' ||
   ' and mti.trx_source_line_id = sol.line_id ' ||
   ' and md.demand_source_line = mti.source_line_id  ';


              p_sql(20) := ' select distinct msn.*   ' ||
' from mtl_serial_numbers msn , ' ||
 ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh ,' ||
      ' rcv_transactions rt' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prl.requisition_header_id = prh.requisition_header_id   ' ||
  ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and mmt.rcv_transaction_id = rt.transaction_id  ' ||
    ' and rt.requisition_line_id = prl.requisition_line_id' ||
    ' and mmt.transaction_id = msn.last_transaction_id' ||
    ' UNION ALL' ||
' select distinct msn.*    ' ||
 ' from mtl_serial_numbers msn , ' ||
         ' mtl_material_transactions mmt , ' ||
              ' po_requisition_lines_all prl , ' ||
              ' po_requisition_headers_all prh ,' ||
              ' oe_order_lines_all sol   ' ||
              ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
        ' and prl.requisition_header_id = prh.requisition_header_id   ' ||
          ' and prh.org_id = ' || l_ou_id ||
          ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
          ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
          ' and prl.source_type_code = ''INVENTORY''' ||
          ' and sol.source_document_type_id = 10   ' ||
          ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
          ' and mmt.trx_source_line_id = sol.line_id   ' ||
          ' and mmt.rcv_transaction_id is null ' ||
          ' and mmt.transaction_id = msn.last_transaction_id  ';


     p_sql(21) := ' select DISTINCT msnt.*' ||
' from    po_requisition_lines_all prl ,' ||
' po_requisition_headers_all prh ,' ||
        ' mtl_serial_numbers_temp msnt ,' ||
        ' mtl_system_items msi,' ||
        ' rcv_transactions_interface rti' ||
        ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
    ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and rti.interface_transaction_id = msnt.transaction_temp_id' ||
    ' and msi.inventory_item_id           = rti.item_id' ||
    ' and msi.organization_id             = rti.to_organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code       = 1' ||
    ' UNION ALL' ||
' select DISTINCT msnt.*' ||
' from    po_requisition_lines_all prl ,' ||
' po_requisition_headers_all prh ,' ||
        ' mtl_serial_numbers_temp msnt ,' ||
        ' mtl_transaction_lots_temp mtlt,' ||
        ' mtl_system_items msi,' ||
        ' rcv_transactions_interface rti' ||
         ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
    ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and rti.interface_transaction_id = mtlt.transaction_temp_id' ||
    ' and mtlt.SERIAL_TRANSACTION_TEMP_ID = msnt.transaction_temp_id' ||
    ' and msi.inventory_item_id           = rti.item_id' ||
    ' and msi.organization_id             = rti.to_organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code       <> 1' ||
    ' UNION ALL' ||
' select DISTINCT msnt.*' ||
' from    po_requisition_lines_all prl,' ||
' po_requisition_headers_all prh,' ||
        ' mtl_serial_numbers_temp msnt,' ||
        ' mtl_system_items msi,' ||
        ' oe_order_lines_all sol,' ||
        ' mtl_material_transactions_temp mmtt' ||
        ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and sol.source_document_line_id = prl.requisition_line_id' ||
    ' and sol.source_document_type_id = 10' ||
    ' and mmtt.trx_source_line_id = sol.line_id' ||
    ' and msnt.transaction_TEMP_id = mmtt.transaction_TEMP_id' ||
    ' and msi.inventory_item_id           = mmtt.inventory_item_id' ||
    ' and msi.organization_id             = mmtt.organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code       = 1' ||
    ' UNION ALL' ||
' select DISTINCT msnt.*' ||
' from    po_requisition_lines_all prl,' ||
' po_requisition_headers_all prh,' ||
        ' mtl_serial_numbers_temp msnt,' ||
        ' mtl_transaction_lots_temp mtlt,' ||
        ' mtl_system_items msi,' ||
        ' oe_order_lines_all sol,' ||
        ' mtl_material_transactions_temp mmtt' ||
        ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and sol.source_document_line_id = prl.requisition_line_id' ||
    ' and sol.source_document_type_id = 10' ||
    ' and mmtt.trx_source_line_id = sol.line_id' ||
    ' and mmtt.transaction_TEMP_id = mtlt.transaction_TEMP_id' ||
    ' and mtlt.serial_transaction_temp_id = msnt.transaction_temp_id' ||
    ' and msi.inventory_item_id           = mmtt.inventory_item_id' ||
    ' and msi.organization_id             = mmtt.organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code       <> 1 ';




p_sql(22) := ' select distinct msni.*    ' ||
  ' from rcv_transactions_interface rti ,' ||
  ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh , ' ||
       ' mtl_serial_numbers_interface msni ,' ||
       ' mtl_system_items msi' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
    ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and rti.interface_transaction_id = msni.product_transaction_id' ||
    ' and msi.inventory_item_id = rti.item_id' ||
    ' and msi.organization_id = rti.to_organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code = 1' ||
    ' UNION ALL' ||
' select distinct msni.*    ' ||
  ' from rcv_transactions_interface rti ,' ||
  ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh , ' ||
       ' mtl_serial_numbers_interface msni ,' ||
       ' mtl_transaction_lots_interface mtli,' ||
       ' mtl_system_items msi' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
    ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and rti.interface_transaction_id = mtli.product_transaction_id' ||
    ' and mtli.serial_transaction_temp_id = msni.transaction_interface_id ' ||
    ' and msi.inventory_item_id = rti.item_id' ||
    ' and msi.organization_id = rti.to_organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code <> 1 ';



        p_sql(23) := ' select distinct mut.*    ' ||
  ' from mtl_material_transactions mmt , ' ||
  ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh , ' ||
       ' mtl_unit_transactions mut ,    ' ||
       ' mtl_system_items msi,' ||
       ' rcv_transactions rt' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
     ' and prl.requisition_header_id = prh.requisition_header_id' ||
     ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and rt.requisition_line_id = prl.requisition_line_id    ' ||
     ' and mmt.rcv_transaction_id = rt.transaction_id    ' ||
     ' and mmt.transaction_id = mut.transaction_id    ' ||
     ' and msi.inventory_item_id = mmt.inventory_item_id    ' ||
     ' and msi.organization_id = mmt.organization_id    ' ||
     ' and msi.serial_number_control_code <> 1     ' ||
     ' and msi.lot_control_code = 1    ' ||
     ' union all    ' ||
     ' select distinct mut.*' ||
   ' from mtl_material_transactions mmt ,' ||
  ' po_requisition_lines_all prl ,' ||
       ' po_requisition_headers_all prh ,' ||
       ' mtl_unit_transactions mut ,    ' ||
       ' mtl_system_items msi , ' ||
       ' rcv_transactions rt , ' ||
       ' mtl_transaction_lot_numbers mtln    ' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
     ' and prl.requisition_header_id = prh.requisition_header_id    ' ||
     ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and rt.requisition_line_id = prl.requisition_line_id    ' ||
     ' and mmt.rcv_transaction_id = rt.transaction_id    ' ||
     ' and mtln.transaction_id = mmt.transaction_id    ' ||
     ' and mut.transaction_id = mtln.serial_transaction_id    ' ||
     ' and msi.inventory_item_id = mmt.inventory_item_id    ' ||
     ' and msi.organization_id = mmt.organization_id' ||
     ' and msi.serial_number_control_code <> 1' ||
     ' and msi.lot_control_code <> 1' ||
     ' union all' ||
' select distinct mut.*    ' ||
   ' from mtl_material_transactions mmt , ' ||
  ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh , ' ||
       ' mtl_unit_transactions mut ,    ' ||
       ' mtl_system_items msi , ' ||
       ' oe_order_lines_all sol    ' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
     ' and prl.requisition_header_id = prh.requisition_header_id' ||
     ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and sol.source_document_line_id = prl.requisition_line_id' ||
     ' and sol.source_document_type_id = 10' ||
     ' and mmt.trx_source_line_id = sol.line_id     ' ||
     ' and mut.transaction_id = mmt.transaction_id' ||
     ' and msi.inventory_item_id = mmt.inventory_item_id' ||
     ' and msi.organization_id = mmt.organization_id' ||
     ' and msi.serial_number_control_code <> 1' ||
     ' and msi.lot_control_code = 1' ||
     ' union all' ||
     ' select distinct mut.*' ||
   ' from mtl_material_transactions mmt , ' ||
  ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh , ' ||
       ' mtl_unit_transactions mut ,    ' ||
       ' mtl_system_items msi , ' ||
       ' oe_order_lines_all sol , ' ||
       ' mtl_transaction_lot_numbers mtln    ' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
     ' and prl.requisition_header_id = prh.requisition_header_id' ||
     ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and sol.source_document_line_id = prl.requisition_line_id' ||
     ' and sol.source_document_type_id = 10' ||
     ' and mmt.trx_source_line_id = sol.line_id' ||
     ' and mtln.transaction_id = mmt.transaction_id' ||
     ' and mut.transaction_id = mtln.serial_transaction_id' ||
     ' and msi.inventory_item_id = mmt.inventory_item_id' ||
     ' and msi.organization_id = mmt.organization_id' ||
     ' and msi.serial_number_control_code <> 1' ||
     ' and msi.lot_control_code <> 1      ';



       p_sql(24) := ' select distinct rss.* ' ||
' from rcv_serials_supply rss , rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all prl '
||
  ' where prh.requisition_header_id = prl.requisition_header_id ' ||
 ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and rss.shipment_line_id = rsl.shipment_line_id ' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' order by rss.supply_type_code , rss.serial_num  ';


       p_sql(25) := ' select distinct rst.* ' ||
' from rcv_serial_transactions rst , rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all
prl ' ||
  ' where prh.requisition_header_id = prl.requisition_header_id ' ||
 ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and rst.shipment_line_id = rsl.shipment_line_id ' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' order by rst.serial_transaction_type , rst.serial_num  ';



       p_sql(26) := ' select distinct rsi.* ' ||
' from rcv_serials_interface rsi , rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all
prl ' ||
  ' where prh.requisition_header_id = prl.requisition_header_id ' ||
 ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
      ' and rsi.item_id = rsl.item_id' ||
   ' and rsi.organization_id = rsl.to_organization_id ';


        p_sql(27) := ' select distinct  mln.*   ' ||
' from mtl_lot_numbers mln , ' ||
 ' mtl_transaction_lot_numbers mtln , ' ||
      ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl ,   ' ||
      ' po_requisition_headers_all prh , ' ||
      ' rcv_transactions rt' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
    ' and prl.requisition_header_id = prh.requisition_header_id   ' ||
    ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
    ' and rt.requisition_line_id = prl.requisition_line_id' ||
    ' and mmt.rcv_transaction_id = rt.transaction_id' ||
    ' and mmt.transaction_id = mtln.transaction_id   ' ||
    ' and mln.inventory_item_id = mmt.inventory_item_id   ' ||
    ' and mln.organization_id = mmt.organization_id   ' ||
    ' and mln.lot_number = mtln.lot_number ' ||
    ' UNION ALL' ||
' select distinct  mln.*   ' ||
' from mtl_lot_numbers mln , ' ||
 ' mtl_transaction_lot_numbers mtln , ' ||
      ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl ,   ' ||
      ' po_requisition_headers_all prh , ' ||
      ' oe_order_lines_all sol' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
' and prh.org_id = ' || l_ou_id ||
    ' and prl.requisition_header_id = prh.requisition_header_id   ' ||
    ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
    ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
    ' and sol.source_document_type_id = 10   ' ||
    ' and mmt.transaction_id = mtln.transaction_id   ' ||
    ' and mmt.trx_source_line_id = sol.line_id' ||
    ' and mln.inventory_item_id = mmt.inventory_item_id   ' ||
    ' and mln.organization_id = mmt.organization_id   ' ||
    ' and mln.lot_number = mtln.lot_number ';


        p_sql(28) := ' select distinct mtln.*   ' ||
' from mtl_transaction_lot_numbers mtln , ' ||
 ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh ,' ||
      ' rcv_transactions rt' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prl.requisition_header_id = prh.requisition_header_id   ' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and rt.requisition_line_id = prl.requisition_line_id' ||
   ' and mmt.rcv_transaction_id = rt.transaction_id' ||
   ' and mmt.transaction_id = mtln.transaction_id' ||
   ' UNION ALL' ||
' select distinct mtln.*   ' ||
' from mtl_transaction_lot_numbers mtln , ' ||
 ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh ,' ||
      ' oe_order_lines_all sol' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
' and prh.org_id = ' || l_ou_id ||
  ' and prl.requisition_header_id = prh.requisition_header_id       ' ||
  ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
  ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
  ' and sol.source_document_type_id = 10   ' ||
  ' and mmt.trx_source_line_id = sol.line_id   ' ||
  ' and mmt.transaction_id = mtln.transaction_id ';


             p_sql(29) := ' select distinct mtli.*   ' ||
' from mtl_transaction_lots_interface mtli , ' ||
 ' mtl_transactions_interface mti , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh ' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and mti.requisition_line_id = prl.requisition_line_id' ||
   ' and mti.transaction_interface_id = mtli.transaction_interface_id' ||
   ' UNION ALL' ||
' select distinct mtli.*   ' ||
' from mtl_transaction_lots_interface mtli , ' ||
 ' rcv_transactions_interface rti , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh ' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and rti.interface_transaction_id = mtli.product_transaction_id' ||
   ' and mtli.product_code =''RCV''' ||
   ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
   ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' ) ';


        p_sql(30) := ' select distinct mtlt.*   ' ||
' from mtl_transaction_lots_temp mtlt ,' ||
  ' rcv_transactions_interface rti, ' ||
       ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh    ' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
   ' and prl.requisition_header_id = prh.requisition_header_id' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and rti.interface_transaction_id = mtlt.product_transaction_id' ||
   ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
   ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' UNION ALL' ||
  ' select distinct mtlt.*   ' ||
  ' from mtl_transaction_lots_temp mtlt ,' ||
  ' mtl_material_transactions_temp mmtt,' ||
       ' rcv_transactions_interface rti, ' ||
       ' po_requisition_lines_all prl , ' ||
       ' po_requisition_headers_all prh,' ||
       ' oe_order_lines_all sol' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
   ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
   ' and sol.source_document_type_id = 10   ' ||
   ' and mmtt.trx_source_line_id = sol.line_id ';


       p_sql(31) := ' select distinct rls.* ' ||
' from rcv_lots_supply rls , rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all prl' ||
  ' where rsl.shipment_line_id = rls.shipment_line_id ' ||
 ' and prh.requisition_header_id = prl.requisition_header_id ' ||
 ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ;


       p_sql(32) := ' select distinct rlt.* ' ||
' from rcv_lot_transactions rlt , rcv_shipment_lines rsl , po_requisition_headers_all prh , po_requisition_lines_all prl
' ||
' where rsl.shipment_line_id = rlt.shipment_line_id ' ||
 ' and rsl.requisition_line_id = prl.requisition_line_id ' ||
   ' and prh.requisition_header_id = prl.requisition_header_id ' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and rsl.source_document_code = ''REQ'' ' ||
   ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prh.org_id = ' || l_ou_id ;



       p_sql(33) := ' select distinct rli.* ' ||
' from rcv_lots_interface rli , rcv_transactions_interface rti , po_requisition_headers_all prh ,
po_requisition_lines_all prl ' ||
  ' where prh.requisition_header_id = prl.requisition_header_id ' ||
  ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
  ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
  ' and prh.org_id = ' || l_ou_id ||
  ' and (nvl(rti.requisition_line_id,-99) = prl.requisition_line_id ' ||
  ' or (nvl(rti.req_num , ''-99999'') = prh.segment1 ) )' ||
  ' AND rli.interface_transaction_id = rti.interface_transaction_id ';


    p_sql(34) := ' select distinct  msi.*' ||
' from po_requisition_headers_all prh,' ||
  ' po_requisition_lines_all prl,' ||
       ' mtl_system_items msi' ||
       ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
 ' and prh.org_id = ' || l_ou_id ||
  ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and prh.requisition_header_id = prl.requisition_header_id' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
   ' and prl.item_id = msi.inventory_item_id' ||
   ' and prl.destination_organization_id = msi.organization_id ';


  p_sql(35) := ' select distinct  mtt.transaction_type_id ,   ' ||
' mtt.transaction_type_name ,  ' ||
 ' mtt.transaction_source_type_id ,   ' ||
                 ' mtt.transaction_action_id ,   ' ||
                 ' mtt.user_defined_flag ,   ' ||
                 ' mtt.disable_date   ' ||
                 ' from mtl_transaction_types mtt ,  ' ||
  ' mtl_material_transactions mmt ,   ' ||
       ' po_requisition_lines_all prl ,   ' ||
       ' po_requisition_headers_all prh ,' ||
       ' rcv_transactions rt' ||
       ' where prl.requisition_header_id = prh.requisition_header_id   ' ||
       ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
 ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' and mmt.rcv_transaction_id = rt.transaction_id  ' ||
    ' and rt.requisition_line_id = prl.requisition_line_id' ||
    ' and mmt.transaction_type_id = mtt.transaction_type_id' ||
    ' UNION ALL' ||
    ' select distinct  mtt.transaction_type_id ,   ' ||
        ' mtt.transaction_type_name ,  ' ||
                 ' mtt.transaction_source_type_id ,   ' ||
                 ' mtt.transaction_action_id ,   ' ||
                 ' mtt.user_defined_flag ,   ' ||
                 ' mtt.disable_date    ' ||
                 ' from mtl_transaction_types mtt ,  ' ||
         ' mtl_material_transactions mmt ,   ' ||
              ' po_requisition_lines_all prl ,   ' ||
              ' po_requisition_headers_all prh,' ||
              ' oe_order_lines_all sol   ' ||
              ' where prl.requisition_header_id = prh.requisition_header_id   ' ||
              ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
        ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
          ' and prh.org_id = ' || l_ou_id ||
          ' and sol.source_document_type_id = 10   ' ||
          ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
          ' and mmt.trx_source_line_id = sol.line_id   ' ||
          ' and mmt.transaction_type_id = mtt.transaction_type_id ';


       p_sql(36) := ' select distinct ood.* ' ||
' from org_organization_definitions ood ' ||
  ' where exists (' ||
 ' select 1  ' ||
    ' from po_requisition_headers_all prh , po_requisition_lines_all prl , financials_system_params_all fsp ' ||
      ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
     ' and prh.org_id = ' || l_ou_id ||
       ' and prl.requisition_header_id = prh.requisition_header_id ' ||
       ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
       ' and prl.source_type_code = ''INVENTORY''' ||
          ' and (prl.destination_organization_id = ood.organization_id ' ||
       ' or prl.source_organization_id = ood.organization_id ' ||
           ' or (prh.org_id = fsp.org_id ' ||
           ' and ood.organization_id = fsp.inventory_organization_id ) ) )  ';


                   p_sql(37) := ' select distinct  mp.* ' ||
' from mtl_parameters mp , po_requisition_headers_all prh , po_requisition_lines_all prl ' ||
  ' where prl.requisition_header_id = prh.requisition_header_id ' ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
   ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
   ' and prl.source_type_code = ''INVENTORY''' ||
      ' and (prl.destination_organization_id = mp.organization_id ' ||
   ' or prl.source_organization_id = mp.organization_id ) ' ||
       ' and prh.org_id = ' || l_ou_id ;


       p_sql(38) := ' select distinct miop.* ' ||
' from mtl_interorg_parameters miop ' ||
  ' where exists (' ||
 ' select 1  ' ||
    ' from po_requisition_headers_all prh , po_requisition_lines_all prl ' ||
      ' where prl.requisition_header_id = prh.requisition_header_id ' ||
     ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
       ' and prl.source_type_code = ''INVENTORY''' ||
       ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
       ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
          ' and (prl.destination_organization_id = miop.to_organization_id ' ||
       ' and prl.source_organization_id = miop.from_organization_id ) ' ||
           ' and prh.org_id = ' || l_ou_id || ')';


           p_sql(39) := ' select distinct rp.* ' ||
' from rcv_parameters rp ' ||
  ' where exists (' ||
 ' select 1  ' ||
    ' from po_requisition_headers_all prh , po_requisition_lines_all prl , financials_system_params_all fsp ' ||
      ' where prl.requisition_header_id = prh.requisition_header_id ' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
     ' and prh.org_id = ' || l_ou_id ||
     ' and prl.line_num = nvl(' || l_line_num || ',-99)' ||
     ' and (prl.destination_organization_id = rp.organization_id ' ||
     ' or prl.source_organization_id = rp.organization_id ' ||
           ' or (prh.org_id = fsp.org_id ' ||
           ' and rp.organization_id = fsp.inventory_organization_id ) ) )  ';



       p_sql(40) := ' select distinct lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_LOT_CONTROL'' ';


     p_sql(41) := ' select distinct lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_LOT_GENERATION'' ';


     p_sql(42) := ' select distinct lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_LOT_UNIQUENESS'' ';


       p_sql(43) := ' select distinct lookup_type , lookup_code , meaning , enabled_flag , start_date_active ,
end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_SERIAL_NUMBER''  ';


     p_sql(44) := ' select distinct lookup_type , lookup_code , meaning , enabled_flag , start_date_active ,
end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_SERIAL_NUMBER_TYPE''  ';


     p_sql(45) := ' select distinct lookup_type , lookup_code , meaning , enabled_flag , start_date_active ,
end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_SERIAL_GENERATION''  ';


     p_sql(46) := ' select distinct lookup_type , lookup_code , meaning , enabled_flag , start_date_active ,
end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''SERIAL_NUM_STATUS''  ';

RETURN;
END;

END IO_DIAGNOSTICS1 ;

/
