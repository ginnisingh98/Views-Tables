--------------------------------------------------------
--  DDL for Package Body IO_DIAGNOSTICS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IO_DIAGNOSTICS2" AS
/* $Header: INVDIO2B.pls 120.0.12000000.1 2007/08/09 06:48:29 ssadasiv noship $ */

PROCEDURE receipt_shipment_sql(p_shipment_num IN VARCHAR2, p_receipt_num IN VARCHAR2, p_org_id IN NUMBER, p_sql IN OUT
NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list) IS
   l_ou_id           po_requisition_headers_all.org_id%TYPE  := NULL;
   l_req_num         po_requisition_headers_all.segment1%TYPE  := NULL;
   l_line_num        po_requisition_lines_all.line_num%TYPE  := NULL;
   l_shipment_num    rcv_shipment_headers.shipment_num%TYPE := p_shipment_num;
   l_receipt_num     rcv_shipment_headers.receipt_num%TYPE := p_receipt_num;
   l_org_id          rcv_shipment_headers.organization_id%TYPE := p_org_id;

BEGIN

    p_sql(1) := ' SELECT DISTINCT prh.* ' ||
' FROM    po_requisition_headers_all prh, ' ||
' po_requisition_lines_all prl ' ||
        ' WHERE   prh.requisition_header_id = prl.requisition_header_id ' ||
' AND prl.source_type_code      = ''INVENTORY'' ' ||
    ' AND requisition_line_id in ' ||
    ' (SELECT requisition_line_id ' ||
        ' FROM    rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
                ' WHERE   rsh.shipment_header_id = rsl.shipment_header_id ' ||
        ' and  rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
            ' and rsh.ship_to_org_id = ' || l_org_id ||
            ' )  ';


            p_sql(2) := ' SELECT DISTINCT prl.* ' ||
' FROM    po_requisition_lines_all prl ' ||
' WHERE   prl.requisition_line_id in ' ||
' (SELECT requisition_line_id ' ||
        ' FROM    rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
                ' WHERE   rsh.shipment_header_id = rsl.shipment_header_id ' ||
            ' and rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
            ' and rsh.ship_to_org_id = ' || l_org_id ||
            ' ) ' ||
        ' AND prl.source_type_code = ''INVENTORY'' ' ||
    ' ORDER BY prl.requisition_line_id  ';



    p_sql(3) := ' SELECT DISTINCT prd.* ' ||
' FROM    po_req_distributions_all prd , ' ||
' po_requisition_lines_all prl ' ||
        ' WHERE   prl.requisition_line_id = prd.requisition_line_id ' ||
' AND prl.source_type_code    = ''INVENTORY'' ' ||
    ' AND prl.requisition_line_id in ' ||
    ' (SELECT requisition_line_id ' ||
        ' FROM    rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
            ' AND rsh.shipment_header_id = rsl.shipment_header_id ' ||
            ' and rsh.ship_to_org_id = ' || l_org_id ||
            ' )  ';



            p_sql(4) := ' SELECT DISTINCT oel.* ' ||
' FROM    oe_order_lines_all oel, ' ||
' po_requisition_lines_all prl ' ||
        ' WHERE   oel.source_document_type_id = 10 ' ||
' AND oel.source_document_line_id = prl.requisition_line_id ' ||
    ' AND prl.requisition_line_id in ' ||
    ' (SELECT requisition_line_id ' ||
        ' FROM    rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
                ' WHERE   rsh.shipment_header_id = rsl.shipment_header_id ' ||
            ' and rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
            ' and rsh.ship_to_org_id = ' || l_org_id ||
            ' )' ||
        ' ORDER BY oel.line_id  ';




    p_sql(5) := ' SELECT DISTINCT wsh.* ' ||
' FROM    wsh_delivery_details wsh , ' ||
' wsh_delivery_assignments wda , ' ||
        ' wsh_new_deliveries wnd , ' ||
        ' oe_order_lines_all sol , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' WHERE rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND wsh.source_line_id          = sol.line_id ' ||
    ' AND wsh.delivery_detail_id      = wda.delivery_detail_id ' ||
    ' AND wda.delivery_id             = wnd.delivery_id ' ||
    ' UNION ALL ' ||
' SELECT DISTINCT wsh.* ' ||
' FROM    wsh_delivery_details wsh , ' ||
' mtl_transactions_interface mti , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' oe_order_lines_all sol, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' WHERE rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND mti.trx_source_line_id      = sol.line_id ' ||
    ' AND mti.picking_line_id         = wsh.delivery_detail_id   ';



        p_sql(6) := ' SELECT DISTINCT rhi.* ' ||
' FROM    rcv_headers_interface rhi,' ||
' rcv_shipment_headers rsh ' ||
        ' WHERE   rhi.receipt_header_id = rsh.shipment_header_id ' ||
' and rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
  ' UNION ALL' ||
' SELECT DISTINCT rhi.* ' ||
' FROM    rcv_headers_interface rhi ' ||
' where rhi.shipment_num =  ' || '''' || l_shipment_num || '''' ||
 ' and rhi.ship_to_organization_id = ' || l_org_id  ;



    p_sql(7) := ' SELECT DISTINCT rti.* ' ||
' FROM    rcv_transactions_interface rti ' ||
' where rti.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rti.to_organization_id = ' || l_org_id ;



      p_sql(8) := ' SELECT DISTINCT pie.* ' ||
' FROM    po_interface_errors pie ' ||
' WHERE   pie.interface_transaction_id IN ' ||
' ( SELECT DISTINCT rti.interface_transaction_id ' ||
        ' FROM    rcv_transactions_interface rti ' ||
        ' where rti.shipment_num =  ' || '''' || l_shipment_num || '''' ||
        ' and rti.to_organization_id = ' || l_org_id  || ')' ||
        ' OR pie.interface_line_id IN ' ||
     ' ( SELECT DISTINCT rti.interface_transaction_id ' ||
        ' FROM    rcv_transactions_interface rti ' ||
        ' where rti.shipment_num =  ' || '''' || l_shipment_num || '''' ||
        ' and rti.to_organization_id = ' || l_org_id   || ')';



            p_sql(9) := ' SELECT DISTINCT rsh.* ' ||
' FROM    rcv_shipment_headers rsh ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ;





        p_sql(10) := ' SELECT DISTINCT rsl.*' ||
' FROM    rcv_shipment_headers rsh, ' ||
' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id = rsl.shipment_header_id  ';




        p_sql(11) := ' SELECT DISTINCT rt.* ' ||
' FROM    rcv_shipment_headers rsh, ' ||
' rcv_shipment_lines rsl, ' ||
        ' rcv_transactions rt ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id = rsl.shipment_header_id ' ||
    ' AND rsh.shipment_header_id = rt.shipment_header_id ' ||
    ' AND rsl.shipment_header_id = rt.shipment_header_id  ';




        p_sql(12) := ' SELECT DISTINCT ms.* ' ||
' FROM    mtl_supply ms ,    ' ||
' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id    ' ||
    ' AND ms.req_line_id          = rsl.requisition_line_id ' ||
    ' AND ms.shipment_header_id = rsl.shipment_header_id ';





        p_sql(13) := ' SELECT DISTINCT rs.* ' ||
' FROM    rcv_supply rs , ' ||
' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = rs.req_line_id ' ||
    ' AND rs.shipment_header_id = rsl.shipment_header_id ';



        p_sql(14) := ' SELECT DISTINCT mtrl.*  ' ||
' FROM    mtl_txn_request_lines mtrl,  ' ||
' rcv_shipment_headers rsh,  ' ||
        ' rcv_shipment_lines rsl,  ' ||
        ' po_requisition_lines_all prl ' ||
        ' where rsh.shipment_num =   '|| '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id =  '|| l_org_id  ||
    ' AND rsh.receipt_source_code = ''INTERNAL ORDER'' ' ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id  ' ||
' and mtrl.inventory_item_id=rsl.item_id ' ||
' and nvl(mtrl.revision,0)=nvl(prl.item_revision,0) ' ||
' and mtrl.organization_id=rsl.to_organization_id ' ||
' and mtrl.transaction_type_id=52'||
' and mtrl.line_status=7';

/*	' SELECT DISTINCT mtrl.* ' ||
' FROM    mtl_txn_request_lines mtrl, ' ||
' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl, ' ||
        ' po_requisition_lines_all prl ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.receipt_source_code = ''INTERNAL ORDER'' ' ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id ' ||
    ' AND mtrl.reference          = ''SHIPMENT_LINE_ID'' ' ||
    ' AND mtrl.reference_id       = rsl.shipment_line_id  '; */



        p_sql(15) := ' SELECT DISTINCT mti.* ' ||
' FROM    mtl_transactions_interface mti, ' ||
' po_requisition_lines_all prl, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl, ' ||
        ' oe_order_lines_all sol ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND mti.trx_source_line_id      = sol.line_id ' ||
    ' AND mti.source_code             = ''ORDER ENTRY''  ';



        p_sql(16) := ' SELECT DISTINCT mmtt.* ' ||
' FROM    mtl_material_transactions_temp mmtt , ' ||
' po_requisition_lines_all prl ,         ' ||
        ' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh,' ||
        ' rcv_transactions rt' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' AND rt.requisition_line_id  = prl.requisition_line_id' ||
    ' AND mmtt.rcv_transaction_id = rt.transaction_id ' ||
    ' UNION ALL' ||
' SELECT DISTINCT mmtt.* ' ||
' FROM    mtl_material_transactions_temp mmtt , ' ||
' po_requisition_lines_all prl ,        ' ||
        ' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh,' ||
        ' oe_order_lines_all sol' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND mmtt.trx_source_line_id     = sol.line_id ';



        p_sql(17) := ' SELECT DISTINCT mmt.* ' ||
' FROM    mtl_material_transactions mmt , ' ||
' po_requisition_lines_all prl ,         ' ||
        ' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh,' ||
        ' rcv_transactions rt' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' AND rt.requisition_line_id  = prl.requisition_line_id' ||
    ' AND mmt.rcv_transaction_id = rt.transaction_id ' ||
    ' UNION ALL' ||
' SELECT DISTINCT mmt.* ' ||
' FROM    mtl_material_transactions mmt, ' ||
' po_requisition_lines_all prl ,        ' ||
        ' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh,' ||
        ' oe_order_lines_all sol' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND mmt.trx_source_line_id     = sol.line_id ' ||
    ' and mmt.transaction_action_id = 21';


        p_sql(18) := ' SELECT DISTINCT mr.* ' ||
' FROM    mtl_reservations mr , ' ||
' oe_order_lines_all sol , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND mr.demand_source_line_id    = sol.line_id ' ||
    ' AND mr.demand_source_type_id    = 8 ' ||
    ' UNION ALL ' ||
' SELECT DISTINCT mr.* ' ||
' FROM    mtl_reservations mr , ' ||
' mtl_transactions_interface mti , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' oe_order_lines_all sol ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND mti.trx_source_line_id      = sol.line_id ' ||
    ' AND mr.demand_source_line_id    = mti.trx_source_line_id   ';



        p_sql(19) := ' SELECT DISTINCT md.* ' ||
' FROM    mtl_demand md , ' ||
' oe_order_lines_all sol , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND md.demand_source_line       = sol.line_id ' ||
    ' AND md.demand_source_type       = 8 ' ||
    ' UNION ALL ' ||
' SELECT DISTINCT md.* ' ||
' FROM    mtl_demand md , ' ||
' mtl_transactions_interface mti , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' oe_order_lines_all sol , ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND mti.trx_source_line_id      = sol.line_id ' ||
    ' AND md.demand_source_line       = mti.source_line_id  ';



        p_sql(20) := ' SELECT DISTINCT msn.* ' ||
' FROM    mtl_serial_numbers msn , ' ||
' mtl_material_transactions mmt , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl,' ||
        ' rcv_transactions rt' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id ' ||
    ' AND rt.requisition_line_id =  prl.requisition_line_id' ||
    ' AND mmt.rcv_transaction_id = rt.transaction_id ' ||
    ' AND mmt.transaction_id = msn.last_transaction_id' ||
    ' UNION ALL' ||
' SELECT DISTINCT msn.* ' ||
' FROM    mtl_serial_numbers msn , ' ||
' mtl_material_transactions mmt , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl,' ||
        ' oe_order_lines_all sol ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND mmt.trx_source_line_id      = sol.line_id' ||
    ' AND mmt.transaction_id = msn.last_transaction_id  ';



        p_sql(21) := ' select DISTINCT msnt.*' ||
' from    mtl_serial_numbers_temp msnt ,' ||
' mtl_system_items msi,' ||
        ' rcv_transactions_interface rti, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
  ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' and rti.shipment_num = rsh.shipment_num' ||
    ' and rti.interface_transaction_id = msnt.transaction_temp_id' ||
    ' and msi.inventory_item_id           = rti.item_id' ||
    ' and msi.organization_id             = rti.to_organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code       = 1' ||
    ' UNION ALL' ||
' select DISTINCT msnt.*' ||
' from    po_requisition_headers_all prh ,' ||
' mtl_serial_numbers_temp msnt ,' ||
        ' mtl_transaction_lots_temp mtlt,' ||
        ' mtl_system_items msi,' ||
        ' rcv_transactions_interface rti, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
  ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' and rti.shipment_num = rsh.shipment_num' ||
    ' and rti.interface_transaction_id = mtlt.transaction_temp_id' ||
    ' and mtlt.SERIAL_TRANSACTION_TEMP_ID = msnt.transaction_temp_id' ||
    ' and msi.inventory_item_id           = rti.item_id' ||
    ' and msi.organization_id             = rti.to_organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code       <> 1' ||
    ' UNION ALL' ||
' select DISTINCT msnt.*' ||
' from    po_requisition_lines_all prl,        ' ||
' mtl_serial_numbers_temp msnt,' ||
        ' mtl_system_items msi,' ||
        ' oe_order_lines_all sol,' ||
        ' mtl_material_transactions_temp mmtt,' ||
        ' rcv_shipment_headers rsh, ' ||
  ' rcv_shipment_lines rsl ' ||
  ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
    ' and sol.source_document_line_id = prl.requisition_line_id' ||
    ' and sol.source_document_type_id = 10' ||
    ' and mmtt.trx_source_line_id = sol.line_id' ||
    ' and msnt.transaction_TEMP_id = mmtt.transaction_TEMP_id' ||
    ' and msi.inventory_item_id = mmtt.inventory_item_id' ||
    ' and msi.organization_id             = mmtt.organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code       = 1' ||
    ' UNION ALL' ||
' select DISTINCT msnt.*' ||
' from    po_requisition_lines_all prl,' ||
' mtl_serial_numbers_temp msnt,' ||
        ' mtl_transaction_lots_temp mtlt,' ||
        ' mtl_system_items msi,' ||
        ' oe_order_lines_all sol,' ||
        ' mtl_material_transactions_temp mmtt,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
  ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
    ' and sol.source_document_line_id = prl.requisition_line_id' ||
    ' and sol.source_document_type_id = 10' ||
    ' and mmtt.trx_source_line_id = sol.line_id' ||
    ' and mmtt.transaction_TEMP_id = mtlt.transaction_TEMP_id' ||
    ' and mtlt.serial_transaction_temp_id = msnt.transaction_temp_id' ||
    ' and msi.inventory_item_id           = mmtt.inventory_item_id' ||
    ' and msi.organization_id             = mmtt.organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code       <> 1 ';


        p_sql(22) := ' SELECT DISTINCT msni.* ' ||
' FROM    mtl_transactions_interface mti , ' ||
' po_requisition_lines_all prl ,         ' ||
        ' mtl_serial_numbers_interface msni , ' ||
        ' mtl_system_items msi ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' AND prl.source_type_code            = ''INVENTORY'' ' ||
    ' AND mti.requisition_line_id        = prl.requisition_line_id' ||
    ' AND msni.transaction_interface_id   = mti.transaction_interface_id ' ||
    ' AND msi.inventory_item_id           = mti.inventory_item_id ' ||
    ' AND msi.organization_id             = mti.organization_id ' ||
    ' AND msi.serial_number_control_code <> 1 ' ||
    ' and msi.lot_control_code       = 1' ||
    ' UNION ALL' ||
' SELECT DISTINCT msni.* ' ||
' FROM    mtl_transactions_interface mti , ' ||
' po_requisition_lines_all prl ,         ' ||
        ' mtl_serial_numbers_interface msni , ' ||
        ' mtl_transaction_lots_interface mtli,' ||
        ' mtl_system_items msi ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' AND prl.source_type_code            = ''INVENTORY'' ' ||
    ' AND mti.requisition_line_id        = prl.requisition_line_id' ||
    ' AND mtli.transaction_interface_id = mti.transaction_interface_id ' ||
    ' AND msni.transaction_interface_id = mtli.serial_transaction_temp_id' ||
    ' AND msi.inventory_item_id           = mti.inventory_item_id ' ||
    ' AND msi.organization_id             = mti.organization_id ' ||
    ' AND msi.serial_number_control_code <> 1 ' ||
    ' and msi.lot_control_code       <> 1 ';



        p_sql(23) := ' select distinct mut.*    ' ||
  ' from mtl_material_transactions mmt , ' ||
  ' po_requisition_lines_all prl , ' ||
       ' mtl_unit_transactions mut ,    ' ||
       ' mtl_system_items msi,' ||
       ' rcv_transactions rt,' ||
       ' rcv_shipment_headers rsh, ' ||
       ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' AND rt.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
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
       ' mtl_unit_transactions mut ,    ' ||
       ' mtl_system_items msi , ' ||
       ' rcv_transactions rt , ' ||
       ' mtl_transaction_lot_numbers mtln,' ||
       ' rcv_shipment_headers rsh, ' ||
       ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
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
  ' po_requisition_lines_all prl ,        ' ||
       ' mtl_unit_transactions mut ,    ' ||
       ' mtl_system_items msi , ' ||
       ' oe_order_lines_all sol,' ||
       ' rcv_shipment_headers rsh, ' ||
       ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
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
  ' po_requisition_lines_all prl ,        ' ||
       ' mtl_unit_transactions mut ,    ' ||
       ' mtl_system_items msi , ' ||
       ' oe_order_lines_all sol , ' ||
       ' mtl_transaction_lot_numbers mtln,' ||
       ' rcv_shipment_headers rsh, ' ||
       ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
    ' and sol.source_document_line_id = prl.requisition_line_id' ||
     ' and sol.source_document_type_id = 10' ||
     ' and mmt.trx_source_line_id = sol.line_id' ||
     ' and mtln.transaction_id = mmt.transaction_id' ||
     ' and mut.transaction_id = mtln.serial_transaction_id' ||
     ' and msi.inventory_item_id = mmt.inventory_item_id' ||
     ' and msi.organization_id = mmt.organization_id' ||
     ' and msi.serial_number_control_code <> 1' ||
     ' and msi.lot_control_code <> 1      ';



         p_sql(24) := ' SELECT DISTINCT rss.* ' ||
' FROM    rcv_serials_supply rss , ' ||
' rcv_shipment_lines rsl , ' ||
        ' rcv_shipment_headers rsh ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rss.shipment_line_id    = rsl.shipment_line_id ' ||
    ' ORDER BY rss.supply_type_code , ' ||
' rss.serial_num   ';

            p_sql(25) := ' SELECT DISTINCT rst.* ' ||
' FROM    rcv_serial_transactions rst , ' ||
' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id   = rsl.shipment_header_id ' ||
    ' AND rsl.shipment_line_id     = rst.shipment_line_id ' ||
    ' AND rsl.source_document_code = ''REQ'' ' ||
    ' ORDER BY rst.serial_transaction_type , ' ||
' rst.serial_num   ';


            p_sql(26) := ' SELECT DISTINCT rsi.* ' ||
' FROM    rcv_serials_interface rsi , ' ||
' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ,' ||
        ' rcv_transactions_interface rti' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id   = rsl.shipment_header_id ' ||
    ' AND rsl.source_document_code = ''REQ'' ' ||
    ' AND rti.shipment_line_id     = rsl.shipment_line_id' ||
    ' AND rsi.item_id              = rsl.item_id ' ||
    ' AND rsi.organization_id      = rsl.to_organization_id ' ||
    ' AND rsi.interface_transaction_id = rti.interface_transaction_id  ';



        p_sql(27) := ' select distinct  mln.*   ' ||
' from mtl_lot_numbers mln , ' ||
 ' mtl_transaction_lot_numbers mtln , ' ||
      ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl ,   ' ||
      ' rcv_transactions rt,' ||
      ' rcv_shipment_headers rsh, ' ||
      ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and rt.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
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
      ' oe_order_lines_all sol,' ||
      ' rcv_shipment_headers rsh, ' ||
       ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
    ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
    ' and sol.source_document_type_id = 10   ' ||
    ' and mmt.transaction_id = mtln.transaction_id   ' ||
    ' and mmt.trx_source_line_id = sol.line_id' ||
    ' and mln.inventory_item_id = mmt.inventory_item_id   ' ||
    ' and mln.organization_id = mmt.organization_id   ' ||
    ' and mln.lot_number = mtln.lot_number  ';


        p_sql(28) := ' select distinct mtln.*   ' ||
' from mtl_transaction_lot_numbers mtln , ' ||
 ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' rcv_transactions rt,' ||
      ' rcv_shipment_headers rsh, ' ||
      ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
    ' and rt.requisition_line_id = prl.requisition_line_id' ||
   ' and mmt.rcv_transaction_id = rt.transaction_id' ||
   ' and mmt.transaction_id = mtln.transaction_id' ||
   ' UNION ALL' ||
' select distinct mtln.*   ' ||
' from mtl_transaction_lot_numbers mtln , ' ||
 ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' oe_order_lines_all sol,' ||
      ' rcv_shipment_headers rsh, ' ||
      ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
    ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
  ' and sol.source_document_type_id = 10   ' ||
  ' and mmt.trx_source_line_id = sol.line_id   ' ||
  ' and mmt.transaction_id = mtln.transaction_id ';




      p_sql(29) := ' select distinct mtli.*   ' ||
' from mtl_transaction_lots_interface mtli , ' ||
 ' mtl_transactions_interface mti , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' rcv_shipment_headers rsh, ' ||
      ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
    ' and mti.requisition_line_id = prl.requisition_line_id' ||
   ' and mti.transaction_interface_id = mtli.transaction_interface_id' ||
   ' UNION ALL' ||
' select distinct mtli.*   ' ||
' from mtl_transaction_lots_interface mtli , ' ||
 ' rcv_transactions_interface rti , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' rcv_shipment_headers rsh, ' ||
      ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
    ' and rti.interface_transaction_id = mtli.product_transaction_id' ||
    ' and mtli.product_code =''RCV'' ' ||
    ' and prl.requisition_line_id = Nvl(rti.requisition_line_id,-99) ';



        p_sql(30) := ' select distinct mtlt.*   ' ||
' from mtl_transaction_lots_temp mtlt ,' ||
  ' rcv_transactions_interface rti, ' ||
       ' po_requisition_lines_all prl , ' ||
       ' rcv_shipment_headers rsh, ' ||
       ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
    ' and rti.interface_transaction_id = mtlt.product_transaction_id' ||
    ' and prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)       ' ||
    ' UNION ALL' ||
  ' select distinct mtlt.*   ' ||
  ' from mtl_transaction_lots_temp mtlt ,' ||
  ' mtl_material_transactions_temp mmtt,' ||
       ' po_requisition_lines_all prl , ' ||
       ' oe_order_lines_all sol,' ||
       ' rcv_shipment_headers rsh, ' ||
       ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
    ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
   ' and sol.source_document_type_id = 10   ' ||
   ' and mmtt.trx_source_line_id = sol.line_id ';


       p_sql(31) := ' SELECT DISTINCT rls.* ' ||
' FROM    rcv_lots_supply rls , ' ||
' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.source_document_code    = ''REQ'' ' ||
    ' AND rsl.shipment_line_id = rls.shipment_line_id  ';




        p_sql(32) := ' SELECT DISTINCT rlt.* ' ||
' FROM    rcv_lot_transactions rlt ,' ||
' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.shipment_line_id        = rlt.shipment_line_id ' ||
    ' AND rsl.source_document_code    = ''REQ''   ';


        p_sql(33) := ' SELECT DISTINCT rli.* ' ||
' FROM    rcv_lots_interface rli , ' ||
' rcv_transactions_interface rti , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND (rti.shipment_header_id     = rsl.shipment_header_id OR ' ||
    ' rti.shipment_num           = rsh.shipment_num)' ||
         ' AND rti.interface_transaction_id = rli.interface_transaction_id  ';



        p_sql(34) := ' SELECT DISTINCT msi.* ' ||
' FROM    mtl_system_items msi, ' ||
' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id = rsl.shipment_header_id ' ||
    ' AND rsl.item_id            = msi.inventory_item_id ' ||
    ' AND rsh.ship_to_org_id     = msi.organization_id  ';



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
       ' rcv_transactions rt,' ||
       ' rcv_shipment_headers rsh, ' ||
       ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
    ' and rt.requisition_line_id = prl.requisition_line_id' ||
    ' and mmt.rcv_transaction_id = rt.transaction_id ' ||
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
              ' oe_order_lines_all sol,' ||
              ' rcv_shipment_headers rsh, ' ||
              ' rcv_shipment_lines rsl ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY'' ' ||
    ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
    ' and sol.source_document_type_id = 10   ' ||
    ' and mmt.trx_source_line_id = sol.line_id   ' ||
    ' and mmt.transaction_type_id = mtt.transaction_type_id ';


        p_sql(36) := ' SELECT DISTINCT ood.* ' ||
' FROM    org_organization_definitions ood, ' ||
' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id   = rsl.shipment_header_id ' ||
    ' AND (rsl.to_organization_id  = ood.organization_id ' ||
    ' OR rsl.from_organization_id = ood.organization_id)   ';


         p_sql(37) := ' SELECT DISTINCT mp.* ' ||
' FROM    mtl_parameters mp, ' ||
' po_requisition_lines_all prl ,' ||
        ' rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
    ' and rsh.ship_to_org_id = ' || l_org_id  ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' AND (rsl.from_organization_id = mp.organization_id ' ||
    ' OR rsl.to_organization_id    = mp.organization_id )   ';



         p_sql(38) := ' SELECT DISTINCT miop.* ' ||
' FROM    mtl_interorg_parameters miop ' ||
' WHERE   exists ' ||
' (SELECT DISTINCT 1 ' ||
        ' FROM    rcv_shipment_lines rsl, ' ||
        ' rcv_shipment_headers rsh ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
            ' and rsh.ship_to_org_id = ' || l_org_id ||
            ' AND rsh.shipment_header_id   = rsl.shipment_header_id ' ||
            ' AND rsl.from_organization_id = miop.from_organization_id ' ||
            ' AND rsl.to_organization_id   = miop.to_organization_id' ||
            ' )  ';


            p_sql(39) := ' SELECT DISTINCT rp.* ' ||
' FROM    rcv_parameters rp ' ||
' WHERE   exists ' ||
' (SELECT DISTINCT 1 ' ||
        ' FROM    po_requisition_lines_all prl , ' ||
        ' rcv_shipment_lines rsl, ' ||
                ' rcv_shipment_headers rsh ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
            ' and rsh.ship_to_org_id = ' || l_org_id ||
            ' AND rsh.shipment_header_id   = rsl.shipment_header_id ' ||
            ' AND (rsl.to_organization_id  = rp.organization_id ' ||
            ' OR rsl.from_organization_id = rp.organization_id )' ||
             ' )  ';



            p_sql(40) := ' SELECT DISTINCT lookup_code , ' ||
' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''MTL_LOT_CONTROL''   ';



    p_sql(41) := ' SELECT DISTINCT lookup_code , ' ||
' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''MTL_LOT_GENERATION''   ';



    p_sql(42) := ' SELECT DISTINCT lookup_code , ' ||
' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''MTL_LOT_UNIQUENESS''   ';



    p_sql(43) := ' SELECT DISTINCT lookup_type , ' ||
' lookup_code , ' ||
        ' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''MTL_SERIAL_NUMBER''   ';


    p_sql(44) := ' SELECT DISTINCT lookup_type , ' ||
' lookup_code , ' ||
        ' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''MTL_SERIAL_NUMBER_TYPE''   ';


    p_sql(45) := ' SELECT DISTINCT lookup_type , ' ||
' lookup_code , ' ||
        ' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''MTL_SERIAL_GENERATION''   ';


    p_sql(46) := ' SELECT DISTINCT lookup_type , ' ||
' lookup_code , ' ||
        ' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''SERIAL_NUM_STATUS''   ';


RETURN;
END;


PROCEDURE req_line_receipt_shipment_sql(p_ou_id IN NUMBER, p_req_num IN VARCHAR2, p_line_num IN NUMBER, p_shipment_num
IN VARCHAR2, p_receipt_num IN VARCHAR2, p_org_id IN NUMBER, p_sql IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list) IS
   l_ou_id           po_requisition_headers_all.org_id%TYPE  := p_ou_id;
   l_req_num         po_requisition_headers_all.segment1%TYPE  := p_req_num;
   l_line_num        po_requisition_lines_all.line_num%TYPE  := Nvl(p_line_num,-99);
   l_shipment_num    rcv_shipment_headers.shipment_num%TYPE := p_shipment_num;
   l_receipt_num     rcv_shipment_headers.receipt_num%TYPE := p_receipt_num;
   l_org_id          rcv_shipment_headers.ship_to_org_id%TYPE := p_org_id;
   l_count NUMBER := 0;

BEGIN





    p_sql(1) := ' SELECT  prh.* ' ||
' FROM    po_requisition_headers_all prh, ' ||
' po_requisition_lines_all prl ' ||
        ' where prh.segment1 = ' || '''' || l_req_num || '''' ||
' and prh.org_id = ' || l_ou_id ||
    ' AND prl.requisition_header_id = prh.requisition_header_id ' ||
    ' AND prl.source_type_code      = ''INVENTORY''   ';






        p_sql(2) := ' SELECT  prl.* ' ||
' FROM    po_requisition_headers_all prh, ' ||
' po_requisition_lines_all prl, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' AND prl.source_type_code      = ''INVENTORY'' ' ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' ORDER BY prl.requisition_line_id   ';






    p_sql(3) := ' SELECT  prd.* ' ||
' FROM    po_requisition_headers_all prh, ' ||
' po_requisition_lines_all prl, ' ||
        ' po_req_distributions_all prd, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND prl.requisition_line_id   = prd.requisition_line_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' AND prl.source_type_code      = ''INVENTORY''    ';





        p_sql(4) := ' SELECT  oel.* ' ||
' FROM    oe_order_lines_all oel, ' ||
' po_requisition_lines_all prl,         ' ||
        ' po_requisition_headers_all prh,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prl.requisition_line_id     = oel.source_document_line_id ' ||
    ' AND oel.source_document_type_id = 10 ' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND prl.source_type_code      = ''INVENTORY''' ||
    ' ORDER BY oel.line_id   ';


    p_sql(5) := ' SELECT  wsh.* ' ||
' FROM    wsh_delivery_details wsh , ' ||
' wsh_delivery_assignments wda , ' ||
        ' wsh_new_deliveries wnd , ' ||
        ' oe_order_lines_all sol , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND prl.requisition_header_id   = prh.requisition_header_id ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND wsh.source_line_id          = sol.line_id ' ||
    ' AND wsh.delivery_detail_id      = wda.delivery_detail_id ' ||
    ' AND wda.delivery_id             = wnd.delivery_id ' ||
    ' UNION ALL ' ||
' SELECT  wsh.* ' ||
' FROM    wsh_delivery_details wsh , ' ||
' mtl_transactions_interface mti , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' oe_order_lines_all sol, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND prl.requisition_header_id   = prh.requisition_header_id ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND mti.trx_source_line_id      = sol.line_id ' ||
    ' AND mti.picking_line_id         = wsh.delivery_detail_id   ';


        p_sql(6) := ' SELECT  rhi.* ' ||
' FROM    rcv_headers_interface rhi,' ||
' rcv_shipment_headers rsh ' ||
        ' WHERE   rhi.receipt_header_id = rsh.shipment_header_id ' ||
' and rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
        ' and rsh.ship_to_org_id = ' || l_org_id ;


            p_sql(7) := ' SELECT DISTINCT rti.*' ||
' FROM    rcv_transactions_interface rti ' ||
' where rti.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rti.to_organization_id = ' || l_org_id;


    p_sql(8) := ' SELECT DISTINCT pie.* ' ||
' FROM    po_interface_errors pie ' ||
 ' WHERE   pie.interface_transaction_id IN ' ||
 ' ( SELECT DISTINCT rti.interface_transaction_id ' ||
 ' FROM    rcv_transactions_interface rti' ||
         ' where rti.shipment_num =  ' || '''' || l_shipment_num || '''' ||
         ' and rti.to_organization_id = ' || l_org_id ||
         ' OR pie.interface_line_id IN ' ||
         ' ( SELECT DISTINCT rti.interface_transaction_id' ||
      ' FROM    rcv_transactions_interface rti ' ||
         ' where rti.shipment_num =  ' || '''' || l_shipment_num || '''' ||
         ' and rti.to_organization_id = ' || l_org_id || '))';

  p_sql(9) := ' SELECT DISTINCT rsh.* ' ||
' FROM    rcv_shipment_headers rsh , ' ||
' rcv_shipment_lines rsl , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND prl.source_type_code = ''INVENTORY''' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' AND rsh.receipt_source_code   = ''INTERNAL ORDER''  ';



        p_sql(10) := ' SELECT  rsl.* ' ||
' FROM    rcv_shipment_headers rsh, ' ||
' rcv_shipment_lines rsl , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' AND prl.source_type_code = ''INVENTORY''' ||
    ' AND rsl.source_document_code  = ''REQ''   ';

        p_sql(11) := ' SELECT  rt.* ' ||
' FROM    rcv_transactions rt , ' ||
' po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id' ||
    ' AND prl.source_type_code = ''INVENTORY'' ' ||
    ' AND rt.requisition_line_id    = prl.requisition_line_id     ' ||
    ' AND rt.shipment_line_id       = rsl.shipment_line_id   ';

        p_sql(12) := ' SELECT  ms.* ' ||
' FROM    mtl_supply ms , ' ||
' po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND prl.source_type_code = ''INVENTORY''' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id' ||
    ' AND ms.shipment_header_id      = rsh.shipment_header_id ';






        p_sql(13) := ' SELECT  rs.* ' ||
' FROM    rcv_supply rs , ' ||
' po_requisition_headers_all prh ,' ||
        ' po_requisition_lines_all prl,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND prl.source_type_code = ''INVENTORY'' ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' AND rs.shipment_header_id      = rsh.shipment_header_id ';

        p_sql(14) := ' SELECT  mtrl.*  ' ||
' FROM    mtl_txn_request_lines mtrl, ' ||
' rcv_shipment_headers rsh,  ' ||
        ' rcv_shipment_lines rsl,  ' ||
        ' po_requisition_headers_all prh,  ' ||
        ' po_requisition_lines_all prl  ' ||
        ' WHERE   rsh.shipment_num =   '|| '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = '|| l_org_id  ||
    ' and prh.segment1 =  '|| '''' || l_req_num || '''' ||
    ' and prh.org_id = '|| l_ou_id  ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id  ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id  ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id  ' ||
    ' AND prl.source_type_code = ''INVENTORY'' ' ||
    ' and nvl(mtrl.revision,0)=nvl(prl.item_revision,0) ' ||
    ' and mtrl.revision=rsl.item_revision ' ||
    ' and mtrl.organization_id=rsl.to_organization_id ' ||
    ' and mtrl.transaction_type_id=52'||
' and mtrl.line_status=7';

	/*' SELECT  mtrl.* ' ||
' FROM    mtl_txn_request_lines mtrl, ' ||
' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl, ' ||
        ' po_requisition_headers_all prh, ' ||
        ' po_requisition_lines_all prl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' AND prl.source_type_code = ''INVENTORY'' ' ||
    ' AND mtrl.reference_id         = rsl.shipment_line_id ' ||
    ' AND mtrl.reference            = ''SHIPMENT_LINE_ID''     ' ||
    ' AND rsl.source_document_code  = ''REQ''  '; */

        p_sql(15) := ' SELECT  MTI.* ' ||
' FROM    MTL_TRANSACTIONS_INTERFACE MTI, ' ||
' PO_REQUISITION_LINES_ALL PRL, ' ||
        ' PO_REQUISITION_HEADERS_ALL PRH, ' ||
        ' OE_ORDER_LINES_ALL SOL, ' ||
        ' RCV_SHIPMENT_HEADERS RSH, ' ||
        ' RCV_SHIPMENT_LINES RSL ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND PRH.REQUISITION_HEADER_ID   = PRL.REQUISITION_HEADER_ID ' ||
    ' AND RSH.SHIPMENT_HEADER_ID      = RSL.SHIPMENT_HEADER_ID ' ||
    ' AND RSL.REQUISITION_LINE_ID     = PRL.REQUISITION_LINE_ID ' ||
    ' AND prl.source_type_code = ''INVENTORY'' ' ||
    ' AND SOL.SOURCE_DOCUMENT_TYPE_ID = 10 ' ||
    ' AND SOL.SOURCE_DOCUMENT_LINE_ID = PRL.REQUISITION_LINE_ID ' ||
    ' AND MTI.TRX_SOURCE_LINE_ID      = SOL.LINE_ID ' ||
    ' AND MTI.SOURCE_CODE             = ''ORDER ENTRY''   ';

        p_sql(16) := ' SELECT  mmtt.* ' ||
' FROM    mtl_material_transactions_temp mmtt , ' ||
' po_requisition_lines_all prl , ' ||
        ' po_requisition_headers_all prh, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl,' ||
        ' rcv_transactions rt ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prh.segment1 = ''229''  ' ||
    ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prl.requisition_header_id = prh.requisition_header_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
    ' and rt.requisition_line_id = prl.requisition_line_id  ' ||
    ' and mmtt.rcv_transaction_id = rt.transaction_id      ' ||
    ' UNION ALL' ||
' SELECT  mmtt.* ' ||
' FROM    mtl_material_transactions_temp mmtt , ' ||
' po_requisition_lines_all prl , ' ||
        ' po_requisition_headers_all prh, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl,' ||
        ' oe_order_lines_all sol   ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
    ' and prl.source_type_code = ''INVENTORY''    ' ||
    ' and prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' and sol.source_document_type_id = 10  ' ||
    ' and sol.source_document_line_id = prl.requisition_line_id' ||
    ' and mmtt.trx_source_line_id = sol.line_id ';




        p_sql(17) := ' SELECT  mmt.* ' ||
' FROM    mtl_material_transactions mmt , ' ||
' po_requisition_lines_all prl , ' ||
        ' po_requisition_headers_all prh, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl,' ||
        ' rcv_transactions rt ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prh.segment1 = ''229''  ' ||
    ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prl.requisition_header_id = prh.requisition_header_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' and rt.requisition_line_id = prl.requisition_line_id  ' ||
    ' and mmt.rcv_transaction_id = rt.transaction_id      ' ||
    ' UNION ALL' ||
' SELECT  mmt.* ' ||
' FROM    mtl_material_transactions mmt , ' ||
' po_requisition_lines_all prl , ' ||
        ' po_requisition_headers_all prh, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl,' ||
        ' oe_order_lines_all sol   ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
    ' and prl.source_type_code = ''INVENTORY''    ' ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' and sol.source_document_type_id = 10  ' ||
    ' and sol.source_document_line_id = prl.requisition_line_id' ||
    ' and mmt.trx_source_line_id = sol.line_id ' ||
    ' and mmt.transaction_action_id = 21';



        p_sql(18) := ' SELECT  mr.* ' ||
' FROM    mtl_reservations mr , ' ||
' oe_order_lines_all sol , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' po_requisition_headers_all prh, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id   = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND mr.demand_source_line_id    = sol.line_id ' ||
    ' AND mr.demand_source_type_id    = 8 ' ||
    ' UNION ALL ' ||
' SELECT  mr.* ' ||
' FROM    mtl_reservations mr , ' ||
' mtl_transactions_interface mti , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' oe_order_lines_all sol ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id   = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND mti.trx_source_line_id      = sol.line_id ' ||
    ' AND mr.demand_source_line_id    = mti.trx_source_line_id   ';

        p_sql(19) := ' SELECT  md.* ' ||
' FROM    mtl_demand md , ' ||
' oe_order_lines_all sol , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id   = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND prh.type_lookup_code        = ''INTERNAL'' ' ||
    ' AND md.demand_source_line       = sol.line_id ' ||
    ' AND md.demand_source_type       = 8 ' ||
    ' UNION ALL ' ||
' SELECT  md.* ' ||
' FROM    mtl_demand md , ' ||
' mtl_transactions_interface mti , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' oe_order_lines_all sol , ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id   = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND prh.type_lookup_code        = ''INTERNAL'' ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND mti.trx_source_line_id      = sol.line_id ' ||
    ' AND md.demand_source_line       = mti.source_line_id   ';






        p_sql(20) := ' select distinct msn.*   ' ||
' from mtl_serial_numbers msn , ' ||
 ' mtl_material_transactions mmt , ' ||
      ' po_requisition_lines_all prl , ' ||
      ' po_requisition_headers_all prh ,' ||
      ' rcv_shipment_headers rsh, ' ||
      ' rcv_shipment_lines rsl ,' ||
      ' rcv_transactions rt' ||
      ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
   ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND rt.requisition_line_id      = prl.requisition_line_id ' ||
    ' and mmt.rcv_transaction_id = rt.transaction_id  ' ||
    ' and mmt.transaction_id = msn.last_transaction_id' ||
    ' UNION ALL' ||
' select distinct msn.*    ' ||
 ' from mtl_serial_numbers msn , ' ||
         ' mtl_material_transactions mmt , ' ||
              ' po_requisition_lines_all prl , ' ||
              ' po_requisition_headers_all prh ,' ||
              ' oe_order_lines_all sol,' ||
              ' rcv_shipment_headers rsh, ' ||
              ' rcv_shipment_lines rsl ' ||
              ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
        ' and rsh.ship_to_org_id = ' || l_org_id ||
          ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
          ' and prh.org_id = ' || l_ou_id ||
          ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
          ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
          ' and prl.source_type_code = ''INVENTORY''' ||
          ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
          ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
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
        ' rcv_transactions_interface rti,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' and prh.requisition_header_id = prl.requisition_header_id  ' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
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
        ' rcv_transactions_interface rti,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
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
        ' mtl_material_transactions_temp mmtt,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
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
        ' mtl_material_transactions_temp mmtt,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id' ||
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
       ' mtl_system_items msi,' ||
       ' rcv_shipment_headers rsh, ' ||
       ' rcv_shipment_lines rsl ' ||
       ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id' ||
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
       ' mtl_system_items msi,' ||
       ' rcv_shipment_headers rsh, ' ||
       ' rcv_shipment_lines rsl ' ||
       ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' and prh.requisition_header_id = prl.requisition_header_id' ||
    ' and prl.source_type_code = ''INVENTORY''' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id' ||
    ' and (prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)' ||
    ' or rti.req_num IS NOT NULL and rti.req_num = prh.segment1' ||
        ' )' ||
       ' and rti.interface_transaction_id = mtli.product_transaction_id' ||
    ' and mtli.serial_transaction_temp_id = msni.transaction_interface_id ' ||
    ' and msi.inventory_item_id = rti.item_id' ||
    ' and msi.organization_id = rti.to_organization_id' ||
    ' and msi.serial_number_control_code <> 1' ||
    ' and msi.lot_control_code <> 1 ';


        p_sql(23) := ' select distinct mut.*       ' ||
  ' from mtl_material_transactions mmt ,    ' ||
    ' po_requisition_lines_all prl ,    ' ||
    ' mtl_unit_transactions mut ,       ' ||
         ' mtl_system_items msi,   ' ||
         ' rcv_transactions rt,   ' ||
         ' rcv_shipment_headers rsh,    ' ||
         ' rcv_shipment_lines rsl            ' ||
         ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
      ' AND rsh.shipment_header_id  = rsl.shipment_header_id    ' ||
      ' AND rsl.requisition_line_id = prl.requisition_line_id   ' ||
      ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
      ' AND rt.requisition_line_id = prl.requisition_line_id   ' ||
      ' and prl.source_type_code =   ''INVENTORY''' ||
      ' and mmt.rcv_transaction_id = rt.transaction_id       ' ||
      ' and mmt.transaction_id = mut.transaction_id       ' ||
      ' and msi.inventory_item_id = mmt.inventory_item_id       ' ||
      ' and msi.organization_id = mmt.organization_id       ' ||
      ' and msi.serial_number_control_code <> 1        ' ||
      ' and msi.lot_control_code = 1       ' ||
      ' union all       ' ||
      ' select distinct mut.*   ' ||
  ' from mtl_material_transactions mmt ,   ' ||
     ' po_requisition_lines_all prl ,   ' ||
    ' mtl_unit_transactions mut ,       ' ||
         ' mtl_system_items msi ,    ' ||
         ' rcv_transactions rt ,    ' ||
         ' mtl_transaction_lot_numbers mtln,   ' ||
         ' rcv_shipment_headers rsh,    ' ||
         ' rcv_shipment_lines rsl            ' ||
         ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
      ' AND rsh.shipment_header_id  = rsl.shipment_header_id    ' ||
      ' AND rsl.requisition_line_id = prl.requisition_line_id   ' ||
      ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
      ' and prl.source_type_code =   ''INVENTORY''' ||
      ' and rt.requisition_line_id = prl.requisition_line_id       ' ||
      ' and mmt.rcv_transaction_id = rt.transaction_id       ' ||
      ' and mtln.transaction_id = mmt.transaction_id       ' ||
      ' and mut.transaction_id = mtln.serial_transaction_id       ' ||
      ' and msi.inventory_item_id = mmt.inventory_item_id       ' ||
      ' and msi.organization_id = mmt.organization_id   ' ||
      ' and msi.serial_number_control_code <> 1   ' ||
      ' and msi.lot_control_code <> 1   ' ||
      ' union all   ' ||
      ' select distinct mut.*       ' ||
  ' from mtl_material_transactions mmt ,    ' ||
     ' po_requisition_lines_all prl ,           ' ||
    ' mtl_unit_transactions mut ,       ' ||
         ' mtl_system_items msi ,    ' ||
         ' oe_order_lines_all sol,   ' ||
         ' rcv_shipment_headers rsh,    ' ||
         ' rcv_shipment_lines rsl            ' ||
         ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
      ' AND rsh.shipment_header_id  = rsl.shipment_header_id    ' ||
      ' AND rsl.requisition_line_id = prl.requisition_line_id   ' ||
      ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
      ' and prl.source_type_code =   ''INVENTORY''' ||
      ' and sol.source_document_line_id = prl.requisition_line_id    ' ||
      ' and sol.source_document_type_id = 10   ' ||
      ' and mmt.trx_source_line_id = sol.line_id        ' ||
      ' and mut.transaction_id = mmt.transaction_id   ' ||
      ' and msi.inventory_item_id = mmt.inventory_item_id   ' ||
      ' and msi.organization_id = mmt.organization_id   ' ||
      ' and msi.serial_number_control_code <> 1   ' ||
      ' and msi.lot_control_code = 1   ' ||
      ' union all   ' ||
      ' select distinct mut.*   ' ||
  ' from mtl_material_transactions mmt ,    ' ||
     ' po_requisition_lines_all prl ,           ' ||
    ' mtl_unit_transactions mut ,       ' ||
         ' mtl_system_items msi ,    ' ||
         ' oe_order_lines_all sol ,    ' ||
         ' mtl_transaction_lot_numbers mtln,   ' ||
         ' rcv_shipment_headers rsh,    ' ||
         ' rcv_shipment_lines rsl            ' ||
         ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
      ' AND rsh.shipment_header_id  = rsl.shipment_header_id    ' ||
      ' AND rsl.requisition_line_id = prl.requisition_line_id   ' ||
      ' and prl.source_type_code =   ''INVENTORY''      ' ||
      ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
      ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
      ' and sol.source_document_type_id = 10   ' ||
       ' and mmt.trx_source_line_id = sol.line_id   ' ||
       ' and mtln.transaction_id = mmt.transaction_id   ' ||
       ' and mut.transaction_id = mtln.serial_transaction_id   ' ||
       ' and msi.inventory_item_id = mmt.inventory_item_id   ' ||
       ' and msi.organization_id = mmt.organization_id   ' ||
       ' and msi.serial_number_control_code <> 1   ' ||
       ' and msi.lot_control_code <> 1         ';






           p_sql(24) := ' SELECT  rss.* ' ||
' FROM    rcv_serials_supply rss , ' ||
' rcv_shipment_lines rsl , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' AND rss.shipment_line_id      = rsl.shipment_line_id ' ||
    ' AND rsl.source_document_code  = ''REQ'' ' ||
    ' ORDER BY rss.supply_type_code , ' ||
' rss.serial_num   ';


            p_sql(25) := ' SELECT  rst.* ' ||
' FROM    rcv_serial_transactions rst , ' ||
' rcv_shipment_lines rsl , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' AND rsl.source_document_code  = ''REQ'' ' ||
    ' AND rst.shipment_line_id      = rsl.shipment_line_id ' ||
    ' ORDER BY rst.serial_transaction_type , ' ||
' rst.serial_num   ';


            p_sql(26) := ' SELECT  rsi.* ' ||
' FROM    rcv_serials_interface rsi , ' ||
' rcv_shipment_lines rsl , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' rcv_shipment_headers rsh ,' ||
        ' rcv_transactions_interface rti' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id' ||
    ' AND prl.line_num                     = nvl( 1 ,prl.line_num)  ' ||
    ' AND rsl.source_document_code  = ''REQ'' ' ||
    ' AND rsi.item_id               = rsl.item_id ' ||
    ' AND rsi.organization_id       = rsl.to_organization_id ' ||
    ' AND rsi.interface_transaction_id = rti.interface_transaction_id' ||
    ' AND rti.shipment_line_id = rsl.shipment_line_id  ';




        p_sql(27) := ' select distinct  mln.* ' ||
 ' from mtl_lot_numbers mln ,' ||
 ' mtl_transaction_lot_numbers mtln ,' ||
  ' mtl_material_transactions mmt ,' ||
       ' po_requisition_lines_all prl ,' ||
       ' rcv_transactions rt,' ||
       ' rcv_shipment_headers rsh,' ||
       ' rcv_shipment_lines rsl ' ||
       ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || '''' || l_org_id || '''' ||
     ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
     ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
     ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
     ' and rt.requisition_line_id = prl.requisition_line_id' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and mmt.rcv_transaction_id = rt.transaction_id' ||
     ' and mmt.transaction_id = mtln.transaction_id  ' ||
     ' and mln.inventory_item_id = mmt.inventory_item_id  ' ||
     ' and mln.organization_id = mmt.organization_id   ' ||
     ' and mln.lot_number = mtln.lot_number ' ||
     ' UNION ALL' ||
     ' select distinct  mln.* ' ||
 ' from mtl_lot_numbers mln , ' ||
 ' mtl_transaction_lot_numbers mtln ,' ||
  ' mtl_material_transactions mmt ,   ' ||
       ' po_requisition_lines_all prl ,  ' ||
       ' oe_order_lines_all sol,' ||
       ' rcv_shipment_headers rsh, ' ||
       ' rcv_shipment_lines rsl           ' ||
       ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || '''' || l_org_id || '''' ||
     ' AND rsh.shipment_header_id  = rsl.shipment_header_id ' ||
     ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
     ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
     ' and prl.source_type_code = ''INVENTORY''' ||
     ' and sol.source_document_line_id = prl.requisition_line_id ' ||
     ' and sol.source_document_type_id = 10  ' ||
     ' and mmt.transaction_id = mtln.transaction_id   ' ||
     ' and mmt.trx_source_line_id = sol.line_id' ||
     ' and mln.inventory_item_id = mmt.inventory_item_id ' ||
     ' and mln.organization_id = mmt.organization_id   ' ||
     ' and mln.lot_number = mtln.lot_number    ';


         p_sql(28) := ' select distinct mtln.*' ||
    ' from mtl_transaction_lot_numbers mtln ,' ||
 ' mtl_material_transactions mmt ,   ' ||
  ' po_requisition_lines_all prl ,   ' ||
       ' rcv_transactions rt,' ||
       ' rcv_shipment_headers rsh,   ' ||
       ' rcv_shipment_lines rsl          ' ||
       ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
     ' AND rsh.shipment_header_id  = rsl.shipment_header_id   ' ||
     ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
     ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
     ' and prl.source_type_code = ''INVENTORY''   ' ||
     ' and rt.requisition_line_id = prl.requisition_line_id' ||
     ' and mmt.rcv_transaction_id = rt.transaction_id' ||
    ' and mmt.transaction_id = mtln.transaction_id' ||
    ' UNION ALL' ||
    ' select distinct mtln.*     ' ||
 ' from mtl_transaction_lot_numbers mtln ,   ' ||
 ' mtl_material_transactions mmt ,   ' ||
  ' po_requisition_lines_all prl ,   ' ||
       ' oe_order_lines_all sol,' ||
       ' rcv_shipment_headers rsh,   ' ||
       ' rcv_shipment_lines rsl          ' ||
       ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
     ' AND rsh.shipment_header_id  = rsl.shipment_header_id   ' ||
     ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
     ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
     ' and prl.source_type_code = ''INVENTORY''   ' ||
     ' and sol.source_document_line_id = prl.requisition_line_id     ' ||
     ' and sol.source_document_type_id = 10     ' ||
   ' and mmt.trx_source_line_id = sol.line_id     ' ||
   ' and mmt.transaction_id = mtln.transaction_id   ';




       p_sql(29) := ' select distinct mtli.*     ' ||
 ' from mtl_transaction_lots_interface mtli ,   ' ||
 ' mtl_transactions_interface mti ,   ' ||
  ' po_requisition_lines_all prl ,   ' ||
       ' rcv_shipment_headers rsh,   ' ||
       ' rcv_shipment_lines rsl          ' ||
       ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
     ' AND rsh.shipment_header_id  = rsl.shipment_header_id   ' ||
     ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
     ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
     ' and prl.source_type_code = ''INVENTORY''   ' ||
     ' and mti.requisition_line_id = prl.requisition_line_id  ' ||
     ' and mti.transaction_interface_id = mtli.transaction_interface_id' ||
    ' UNION ALL' ||
    ' select distinct mtli.*     ' ||
 ' from mtl_transaction_lots_interface mtli ,   ' ||
 ' rcv_transactions_interface rti ,   ' ||
  ' po_requisition_lines_all prl ,   ' ||
       ' rcv_shipment_headers rsh,   ' ||
       ' rcv_shipment_lines rsl          ' ||
       ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
     ' AND rsh.shipment_header_id  = rsl.shipment_header_id   ' ||
     ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
     ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
     ' and prl.source_type_code = ''INVENTORY''   ' ||
     ' and rti.interface_transaction_id = mtli.product_transaction_id' ||
     ' and mtli.product_code =''RCV''   ' ||
     ' and prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)   ';






         p_sql(30) := ' select distinct mtlt.*     ' ||
        ' from mtl_transaction_lots_temp mtlt ,' ||
 ' rcv_transactions_interface rti,   ' ||
   ' po_requisition_lines_all prl ,   ' ||
        ' rcv_shipment_headers rsh,   ' ||
        ' rcv_shipment_lines rsl          ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
     ' AND rsh.shipment_header_id  = rsl.shipment_header_id   ' ||
     ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
     ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
     ' and prl.source_type_code = ''INVENTORY''   ' ||
     ' and rti.interface_transaction_id = mtlt.product_transaction_id' ||
     ' and prl.requisition_line_id = Nvl(rti.requisition_line_id,-99)         ' ||
     ' UNION ALL' ||
     ' select distinct mtlt.*     ' ||
   ' from mtl_transaction_lots_temp mtlt ,' ||
   ' mtl_material_transactions_temp mmtt,  ' ||
   ' po_requisition_lines_all prl ,   ' ||
        ' oe_order_lines_all sol,' ||
        ' rcv_shipment_headers rsh,   ' ||
        ' rcv_shipment_lines rsl          ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
     ' AND rsh.shipment_header_id  = rsl.shipment_header_id   ' ||
     ' AND rsl.requisition_line_id = prl.requisition_line_id' ||
     ' and prl.source_type_code = ''INVENTORY''   ' ||
     ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
     ' and sol.source_document_line_id = prl.requisition_line_id' ||
     ' and sol.source_document_type_id = 10     ' ||
    ' and mmtt.trx_source_line_id = sol.line_id   ';


        p_sql(31) := ' SELECT  rls.* ' ||
' FROM    rcv_lots_supply rls , ' ||
' rcv_shipment_lines rsl , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' oe_order_lines_all sol , ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id   = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id      = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id     = prl.requisition_line_id ' ||
    ' AND rsl.shipment_line_id        = rls.shipment_line_id ' ||
    ' AND sol.source_document_type_id = 10 ' ||
    ' AND sol.source_document_line_id = prl.requisition_line_id ' ||
    ' AND rsl.source_document_code    = ''REQ''   ';





        p_sql(32) := ' SELECT  rlt.* ' ||
' FROM    rcv_lot_transactions rlt , ' ||
' rcv_shipment_lines rsl , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl , ' ||
        ' rcv_shipment_headers rsh ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' AND rsl.shipment_line_id      = rlt.shipment_line_id ' ||
    ' AND rsl.source_document_code  = ''REQ'' ' ||
    ' and prl.source_type_code = ''INVENTORY''  ';



        p_sql(33) := ' SELECT  rli.* ' ||
' FROM    rcv_lots_interface rli , ' ||
' rcv_transactions_interface rti , ' ||
        ' po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl ,' ||
        ' rcv_shipment_headers rsh,' ||
        ' rcv_shipment_lines rsl' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' and prl.source_type_code = ''INVENTORY''   ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id     ' ||
    ' AND (rti.shipment_header_id     = rsh.shipment_header_id OR' ||
    ' rti.shipment_num           = rsh.shipment_num)' ||
         ' AND rti.interface_transaction_id = rli.interface_transaction_id   ';



        p_sql(34) := ' SELECT DISTINCT msi.* ' ||
' FROM    po_requisition_headers_all prh, ' ||
' po_requisition_lines_all prl, ' ||
        ' mtl_system_items msi, ' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
    ' AND prh.type_lookup_code in (''INTERNAL'', ''PURCHASE'') ' ||
    ' AND prl.item_id                     = msi.inventory_item_id ' ||
    ' AND prl.destination_organization_id = msi.organization_id   ';


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
       ' rcv_transactions rt,' ||
       ' rcv_shipment_headers rsh, ' ||
       ' rcv_shipment_lines rsl ' ||
       ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id' ||
    ' AND rt.requisition_line_id     = prl.requisition_line_id' ||
    ' and mmt.rcv_transaction_id = rt.transaction_id  ' ||
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
              ' oe_order_lines_all sol,' ||
              ' rcv_shipment_headers rsh, ' ||
              ' rcv_shipment_lines rsl ' ||
             ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id    = rsl.shipment_header_id' ||
    ' and sol.source_document_line_id = prl.requisition_line_id   ' ||
    ' and sol.source_document_type_id = 10   ' ||
    ' and mmt.trx_source_line_id = sol.line_id   ' ||
    ' and mmt.transaction_type_id = mtt.transaction_type_id ';




        p_sql(36) := ' SELECT  ood.* ' ||
' FROM    org_organization_definitions ood ' ||
' WHERE   exists ' ||
' (SELECT 1 ' ||
        ' FROM    po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl , ' ||
                ' financials_system_params_all fsp , ' ||
                ' rcv_shipment_headers rsh, ' ||
                ' rcv_shipment_lines rsl ' ||
                ' WHERE   rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
        ' and rsh.ship_to_org_id = ' || l_org_id ||
            ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
            ' and prh.org_id = ' || l_ou_id ||
            ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
            ' AND prh.requisition_header_id = prl.requisition_header_id ' ||
            ' AND rsh.shipment_header_id    = rsl.shipment_header_id ' ||
            ' AND rsl.requisition_line_id   = prl.requisition_line_id ' ||
            ' AND prh.type_lookup_code in (''INTERNAL'',''PURCHASE'') ' ||
            ' AND (prl.destination_organization_id = ood.organization_id ' ||
            ' OR prl.source_organization_id       = ood.organization_id ' ||
             ' OR (prh.org_id                      = fsp.org_id ' ||
             ' AND ood.organization_id              = fsp.inventory_organization_id ) ) ' ||
            ' )   ';


            p_sql(37) := ' SELECT DISTINCT mp.* ' ||
' FROM    mtl_parameters mp , ' ||
' po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl ,' ||
        ' rcv_shipment_headers rsh, ' ||
        ' rcv_shipment_lines rsl ' ||
        ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
' and rsh.ship_to_org_id = ' || l_org_id ||
    ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
    ' and prh.org_id = ' || l_ou_id ||
    ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
    ' AND prh.requisition_header_id        = prl.requisition_header_id ' ||
    ' AND rsh.shipment_header_id           = rsl.shipment_header_id ' ||
    ' AND rsl.requisition_line_id          = prl.requisition_line_id ' ||
    ' AND prh.type_lookup_code             = ''INTERNAL'' ' ||
    ' AND (prl.destination_organization_id = mp.organization_id ' ||
    ' OR prl.source_organization_id       = mp.organization_id )   ';


         p_sql(38) := ' SELECT  miop.* ' ||
' FROM    mtl_interorg_parameters miop ' ||
' WHERE   exists ' ||
' (SELECT 1 ' ||
        ' FROM    po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl, ' ||
                ' rcv_shipment_headers rsh, ' ||
                ' rcv_shipment_lines rsl ' ||
                ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
        ' and rsh.ship_to_org_id = ' || l_org_id ||
            ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
            ' and prh.org_id = ' || l_ou_id ||
            ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
            ' AND prh.requisition_header_id        = prl.requisition_header_id ' ||
            ' AND rsh.shipment_header_id           = rsl.shipment_header_id ' ||
            ' AND rsl.requisition_line_id          = prl.requisition_line_id ' ||
            ' AND prh.type_lookup_code             = ''INTERNAL'' ' ||
            ' AND (prl.destination_organization_id = miop.to_organization_id ' ||
            ' AND prl.source_organization_id       = miop.from_organization_id )' ||
            ' )   ';


            p_sql(39) := ' SELECT  rp.* ' ||
' FROM    rcv_parameters rp ' ||
' WHERE   exists ' ||
' (SELECT 1 ' ||
        ' FROM    po_requisition_headers_all prh , ' ||
        ' po_requisition_lines_all prl , ' ||
                ' financials_system_params_all fsp, ' ||
                ' rcv_shipment_headers rsh, ' ||
                ' rcv_shipment_lines rsl ' ||
                ' where rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
        ' and rsh.ship_to_org_id = ' || l_org_id ||
            ' and prh.segment1 = ' || '''' || l_req_num || '''' ||
            ' and prh.org_id = ' || l_ou_id ||
            ' AND prl.line_num                = nvl(' || l_line_num || ',-99) ' ||
            ' AND prh.requisition_header_id        = prl.requisition_header_id ' ||
            ' AND rsh.shipment_header_id           = rsl.shipment_header_id ' ||
            ' AND rsl.requisition_line_id          = prl.requisition_line_id ' ||
            ' AND prh.type_lookup_code             = ''INTERNAL'' ' ||
            ' AND (prl.destination_organization_id = rp.organization_id ' ||
            ' OR prl.source_organization_id       = rp.organization_id ' ||
             ' OR (prh.org_id                      = fsp.org_id ' ||
             ' AND rp.organization_id               = fsp.inventory_organization_id ) ) ' ||
            ' )  ';

            p_sql(40) := ' SELECT  lookup_code , ' ||
' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''MTL_LOT_CONTROL''   ';

    p_sql(41) := ' SELECT  lookup_code , ' ||
' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''MTL_LOT_GENERATION''   ';


    p_sql(42) := ' SELECT  lookup_code , ' ||
' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''MTL_LOT_UNIQUENESS''   ';


    p_sql(43) := ' SELECT  lookup_type , ' ||
' lookup_code , ' ||
        ' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''MTL_SERIAL_NUMBER''   ';


    p_sql(44) := ' SELECT  lookup_type , ' ||
' lookup_code , ' ||
        ' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''MTL_SERIAL_NUMBER_TYPE''   ';


    p_sql(45) := ' SELECT  lookup_type , ' ||
' lookup_code , ' ||
        ' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''MTL_SERIAL_GENERATION''   ';


    p_sql(46) := ' SELECT  lookup_type , ' ||
' lookup_code , ' ||
        ' meaning , ' ||
        ' enabled_flag , ' ||
        ' start_date_active , ' ||
        ' end_date_active ' ||
        ' FROM    mfg_lookups ' ||
' WHERE   lookup_type = ''SERIAL_NUM_STATUS''    ';


RETURN;
END;

END IO_DIAGNOSTICS2 ;

/
