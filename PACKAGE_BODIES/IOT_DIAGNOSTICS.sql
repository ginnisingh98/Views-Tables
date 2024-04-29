--------------------------------------------------------
--  DDL for Package Body IOT_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IOT_DIAGNOSTICS" AS
/* $Header: INVDIOT1B.pls 120.0.12000000.1 2007/08/09 06:49:17 ssadasiv noship $ */

PROCEDURE shipment_num_sql(p_org_id IN NUMBER, p_shipment_num IN VARCHAR2, p_receipt_num  IN VARCHAR2, p_sql IN OUT
NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list) IS
   l_shipment_num    rcv_shipment_headers.shipment_num%TYPE := p_shipment_num;
   l_receipt_num    rcv_shipment_headers.receipt_num%TYPE := p_receipt_num;
   l_org_id  rcv_shipment_headers.organization_id%TYPE := p_org_id;
   l_line_num       rcv_shipment_lines.line_num%TYPE := NULL;

BEGIN

    p_sql(1):= ' select distinct rhi.* ' ||
' from rcv_headers_interface rhi ' ||
  ' where rhi.shipment_num = ' || '''' || l_shipment_num || '''' ||
 ' or exists (' ||
   ' select 1 ' ||
    ' from rcv_shipment_headers rsh ' ||
      ' where rsh.receipt_source_code = ''INVENTORY'' ' ||
     ' and rsh.shipment_num =  ' || '''' || l_shipment_num || '''' ||
       ' and rhi.receipt_header_id = rsh.shipment_header_id)  ';


    p_sql(2):= ' select distinct rti.* ' ||
' from rcv_transactions_interface rti ' ||
  ' where (exists (' ||
 ' select 1 ' ||
        ' from rcv_headers_interface rhi ' ||
          ' where rti.header_interface_id = rhi.header_interface_id ' ||
         ' and (rhi.shipment_num = ' || '''' || l_shipment_num || ''''||
           ' or exists (' ||
               ' select 1 ' ||
                ' from rcv_shipment_headers rsh ' ||
                  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
                 ' and rsh.ship_to_org_id = ' || l_org_id ||
                   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
                   ' and rhi.receipt_header_id = rsh.shipment_header_id) ) ) ' ||
                   ' or exists (' ||
       ' select 2 ' ||
        ' from rcv_shipment_headers rsh ' ||
          ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
         ' and rsh.ship_to_org_id = ' || l_org_id ||
           ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
           ' and (rti.shipment_header_id = rsh.shipment_header_id ' ||
           ' OR rti.shipment_num =  nvl(' || '''' || l_shipment_num || '''' || ',rsh.shipment_num) ) ) ) ';



   p_sql(3):= ' select distinct pie.* ' ||
' from po_interface_errors pie ' ||
  ' where exists (' ||
 ' select 1 ' ||
    ' from rcv_headers_interface rhi ' ||
      ' where (rhi.shipment_num = ' || '''' || l_shipment_num || ''''||
     ' or exists (' ||
           ' select 1 ' ||
            ' from rcv_shipment_headers rsh ' ||
              ' where rsh.shipment_num = ' || '''' || l_shipment_num || ''''  ||
              ' and rsh.ship_to_org_id = ' || l_org_id ||
             ' and rhi.receipt_header_id = rsh.shipment_header_id) ) ' ||
               ' and ((pie.interface_header_id = rhi.header_interface_id ' ||
       ' and pie.table_name = ''RCV_HEADERS_INTERFACE'') ' ||
               ' or exists (' ||
           ' select 2 ' ||
            ' from rcv_transactions_interface rti ' ||
              ' where rti.header_interface_id = rhi.header_interface_id ' ||
             ' and pie.interface_line_id = rti.interface_transaction_id ' ||
               ' and pie.table_name = ''RCV_TRANSACTIONS_INTERFACE'' ) ) ) ' ||
               ' or exists (' ||
   ' select 2 ' ||
    ' from rcv_transactions_interface rti , rcv_shipment_headers rsh ' ||
      ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
      ' and rsh.ship_to_org_id = ' || l_org_id ||
     ' and rti.shipment_header_id = rsh.shipment_header_id ' ||
       ' and pie.interface_line_id = rti.interface_transaction_id ' ||
       ' and pie.table_name = ''RCV_TRANSACTIONS_INTERFACE'')  ';



    p_sql(4):= ' select distinct rsh.* ' ||
' from rcv_shipment_headers rsh' ||
  ' where rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.ship_to_org_id = ' || l_org_id ||
   ' order by rsh.shipment_header_id  ';



       p_sql(5):= ' select distinct rsl.* ' ||
' from rcv_shipment_headers rsh , rcv_shipment_lines rsl ' ||
  ' where rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.ship_to_org_id = ' || l_org_id ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' order by rsl.shipment_header_id , rsl.shipment_line_id  ';



     p_sql(6):= ' select distinct rt.* ' ||
' from rcv_transactions rt , rcv_shipment_headers rsh , rcv_shipment_lines rsl' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
   ' and rt.shipment_header_id = rsh.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' order by rt.shipment_header_id , rt.shipment_line_id , rt.transaction_id  ';



     p_sql(7):= ' select distinct ms.* ' ||
' from mtl_supply ms , rcv_shipment_headers rsh , rcv_shipment_lines rsl' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rsl.shipment_line_id = ms.shipment_line_id ';



       p_sql(8):= ' select distinct rs.* ' ||
' from rcv_supply rs , rcv_shipment_headers rsh , rcv_shipment_lines rsl' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rs.shipment_line_id = rsl.shipment_line_id ';


      p_sql(9):= ' select distinct  mmtt.* ' ||
' from mtl_material_transactions_temp mmtt ' ||
  ' where mmtt.shipment_number = ' || '''' || l_shipment_num || '''' ||
  ' order by mmtt.organization_id , mmtt.transaction_date  ';


 p_sql(10):= ' select distinct mmt.*' ||
' from mtl_material_transactions mmt' ||
  ' where exists (select 1' ||
 ' from rcv_shipment_headers rsh' ||
              ' where mmt.shipment_number = rsh.shipment_num' ||
              ' and rsh.shipment_num= ' || '''' || l_shipment_num || '''' ||
              ' and rsh.ship_to_org_id = ' || l_org_id ||
              ' )' ||
              ' or exists (select 2 ' ||
   ' from rcv_transactions rt, ' ||
              ' rcv_shipment_headers rsh' ||
                   ' where rt.transaction_id = mmt.rcv_transaction_id' ||
              ' and rt.shipment_header_id = rsh.shipment_header_id' ||
                ' and rsh.shipment_num= ' || '''' || l_shipment_num || '''' ||
              ' and rsh.ship_to_org_id = ' || l_org_id ||') ';


    p_sql(11):= ' select distinct mln.* ' ||
' from mtl_lot_numbers mln , mtl_transaction_lot_numbers mtln , mtl_material_transactions mmt ' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and mmt.transaction_id = mtln.transaction_id ' ||
   ' and mln.lot_number = mtln.lot_number order by mln.organization_id , mln.inventory_item_id , mln.lot_number  ';



       p_sql(12):= ' select distinct mtln.* ' ||
' from mtl_transaction_lot_numbers mtln , mtl_material_transactions mmt ' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and mmt.transaction_id = mtln.transaction_id order by mtln.organization_id , mtln.inventory_item_id , mtln.lot_number
';



       p_sql(13):= ' select distinct mtli.* ' ||
' from mtl_transaction_lots_interface mtli , mtl_transactions_interface mti ' ||
  ' where mti.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and mti.transaction_interface_id = mtli.transaction_interface_id ' ||
   ' union all ' ||
 ' select mtli.* ' ||
' from mtl_transaction_lots_interface mtli , rcv_transactions_interface rti ' ||
  ' where (exists (' ||
 ' select 1 ' ||
        ' from rcv_headers_interface rhi ' ||
          ' where rti.header_interface_id = rhi.header_interface_id ' ||
         ' and (rhi.shipment_num = ' || '''' || l_shipment_num || ''''||
           ' or exists (' ||
               ' select 1 ' ||
                ' from rcv_shipment_headers rsh ' ||
                  ' where rsh.shipment_num = ' || '''' || l_shipment_num || ''''  ||
                  ' and rsh.ship_to_org_id = ' || l_org_id ||
                 ' and rhi.receipt_header_id = rsh.shipment_header_id) ) ) ' ||
                   ' or exists (' ||
       ' select 2 ' ||
        ' from rcv_shipment_headers rsh ' ||
          ' where rsh.shipment_num = ' || '''' || l_shipment_num || ''''  ||
          ' and rsh.ship_to_org_id = ' || l_org_id ||
         ' and rti.shipment_header_id = rsh.shipment_header_id ) ) ' ||
           ' and mtli.product_transaction_id = rti.interface_transaction_id  ';



       p_sql(14):= ' select distinct mtlt.* ' ||
' from mtl_transaction_lots_temp mtlt , mtl_material_transactions_temp mmtt ' ||
  ' where mmtt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and mmtt.transaction_temp_id = mtlt.transaction_temp_id order by mtlt.transaction_temp_id , mtlt.lot_number  ';



       p_sql(15):= ' select distinct rls.* ' ||
' from rcv_lots_supply rls , rcv_shipment_lines rsl , rcv_shipment_headers rsh ' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rsl.shipment_line_id = rls.shipment_line_id ' ||
   ' order by rls.shipment_line_id, rls.lot_num';



       p_sql(16):= ' select distinct rlt.* ' ||
' from rcv_lot_transactions rlt , rcv_shipment_lines rsl , rcv_shipment_headers rsh ' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rsl.shipment_line_id = rlt.shipment_line_id order by rlt.shipment_line_id , rlt.item_id , rlt.lot_num  ';



       p_sql(17):= ' select distinct rli.* ' ||
' from rcv_lots_interface rli , rcv_shipment_lines rsl , rcv_shipment_headers rsh ' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
  ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
  ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
  ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
  ' and rsl.item_id = Nvl(rli.shipment_line_id,rsl.item_id )' ||
  ' and rsl.item_id = rli.item_id' ||
  ' order by rli.item_id , rli.lot_num  ';


   p_sql(18):=' select distinct rss.* ' ||
' from rcv_serials_supply	rss , rcv_shipment_lines rsl , rcv_shipment_headers rsh , rcv_transactions rt ' ||
   ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.ship_to_org_id = ' || l_org_id ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.shipment_line_id = rt.shipment_line_id ' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rss.shipment_line_id = rsl.shipment_line_id' ||
   ' order by rss.serial_num ';



     p_sql(19):= ' select distinct rst.* ' ||
' from rcv_serial_transactions rst , rcv_shipment_lines rsl , rcv_shipment_headers rsh ' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rst.shipment_line_id = rsl.shipment_line_id ' ||
   ' order by rst.shipment_line_id , rst.serial_num  ';



     p_sql(20):= ' select distinct rsi.* ' ||
' from rcv_serials_interface rsi , rcv_shipment_lines rsl , rcv_shipment_headers rsh ' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
 ' and rsh.ship_to_org_id = ' || l_org_id ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rsi.item_id = rsl.item_id ' ||
   ' and rsi.organization_id = rsl.to_organization_id ' ||
   ' order by rsi.organization_id , rsi.item_id , rsi.fm_serial_num  ';



           p_sql(21):= ' select distinct msn.* ' ||
' from mtl_serial_numbers msn , mtl_material_transactions mmt , rcv_shipment_headers rsh, rcv_shipment_lines rsl' ||
  ' where msn.last_transaction_id = mmt.transaction_id ' ||
 ' and mmt.shipment_number = rsh.shipment_num' ||
   ' and rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.ship_to_org_id = ' || l_org_id ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)    order by msn.inventory_item_id ,
msn.serial_number ';



       p_sql(22):= ' select distinct msnt.* ' ||
' from mtl_serial_numbers_temp msnt' ||
  ' where (exists (SELECT 1 ' ||
 ' from mtl_material_transactions_temp mmtt ' ||
                ' where mmtt.shipment_number = ' || '''' || l_shipment_num || '''' ||
                ' and (msnt.transaction_temp_id = mmtt.transaction_temp_id ' ||
                ' or exists (' ||
                  ' select 1 ' ||
                             ' from mtl_transaction_lots_temp mtlt ' ||
                             ' where mtlt.serial_transaction_temp_id = msnt.transaction_temp_id ' ||
                             ' and mmtt.transaction_temp_id = mtlt.transaction_temp_id) ) ' ||
                             ' )' ||
              ' OR exists (SELECT 2 ' ||
    ' from rcv_transactions_interface rti ' ||
               ' where rti.shipment_num = ' || '''' || l_shipment_num || '''' ||
               ' and (msnt.transaction_temp_id = rti.interface_transaction_id ' ||
               ' or exists (' ||
                  ' select 1 ' ||
                             ' from mtl_transaction_lots_temp mtlt ' ||
                             ' where mtlt.serial_transaction_temp_id = msnt.transaction_temp_id ' ||
                             ' and rti.interface_transaction_id = mtlt.transaction_temp_id) )' ||
                             ' )' ||
              ' ) ';


        p_sql(23):= ' select distinct msni.* ' ||
' from mtl_serial_numbers_interface	msni , mtl_transactions_interface mti , mtl_system_items msi ' ||
  ' where mti.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and msi.inventory_item_id = mti.inventory_item_id ' ||
   ' and msi.organization_id = mti.organization_id ' ||
   ' and msi.serial_number_control_code <> 1 ' ||
   ' and ((msni.transaction_Interface_id = mti.transaction_Interface_id ' ||
   ' and msi.lot_control_code = 1 ) ' ||
           ' or (exists (' ||
       ' select 3 ' ||
            ' from mtl_transaction_lots_interface mtli ' ||
              ' where mtli.transaction_Interface_id = mti.transaction_Interface_id ' ||
             ' and msni.transaction_Interface_id = mtli.serial_transaction_temp_id ) ' ||
               ' and (msi.lot_control_code <> 1 ) ) ) ' ||
           ' union all ' ||
 ' select msni.* ' ||
' from mtl_serial_numbers_interface msni , rcv_transactions_interface rti ' ||
  ' where (exists (' ||
 ' select 1 ' ||
        ' from rcv_headers_interface rhi ' ||
          ' where rti.header_interface_id = rhi.header_interface_id ' ||
         ' and (rhi.shipment_num = ' || '''' || l_shipment_num || ''''||
           ' or exists (' ||
               ' select 1 ' ||
                ' from rcv_shipment_headers rsh ' ||
                  ' where rsh.shipment_num = ' || '''' || l_shipment_num || ''''  ||
                  ' and rsh.ship_to_org_id = ' || l_org_id ||
                 ' and rhi.receipt_header_id = rsh.shipment_header_id) ) ) ' ||
                   ' or exists (' ||
       ' select 2 ' ||
        ' from rcv_shipment_headers rsh ' ||
          ' where rsh.shipment_num = ' || '''' || l_shipment_num || ''''  ||
          ' and rsh.ship_to_org_id = ' || l_org_id ||
         ' and rti.shipment_header_id = rsh.shipment_header_id ) ) ' ||
           ' and msni.product_transaction_id = rti.interface_transaction_id  ';



              p_sql(24):= ' select distinct mut.* ' ||
' from mtl_unit_transactions mut , mtl_material_transactions mmt , rcv_transactions rt, rcv_shipment_headers rsh,
rcv_shipment_lines rsl' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
  ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
  ' and rsl.shipment_line_id = rt.shipment_line_id ' ||
  ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
  ' and rt.transaction_id = mmt.rcv_transaction_id ' ||
  ' and rt.shipment_header_id = rsh.shipment_header_id ' ||
 ' and (mut.transaction_id = mmt.transaction_id ' ||
   ' or (exists (' ||
       ' select 2 ' ||
            ' from mtl_transaction_lot_numbers mtln ' ||
              ' where mut.transaction_id = mtln.serial_transaction_id ' ||
             ' and mmt.transaction_id = mtln.transaction_id) ) ) order by mut.inventory_item_id , mut.serial_number  ';




     p_sql(25):= ' select distinct msi.* ' ||
' from mtl_material_transactions mmt , mtl_system_items msi ' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and msi.inventory_item_id = mmt.inventory_item_id ' ||
   ' and msi.organization_id in (mmt.organization_id , mmt.transfer_organization_id)' ||
   ' order by msi.organization_id , msi.inventory_item_id  ';



       p_sql(26):= ' select distinct mtt.transaction_type_id , mtt.transaction_type_name ,
mtt.transaction_source_type_id , mtt.transaction_action_id , ' ||
' mtt.user_defined_flag , mtt.disable_date ' ||
' from mtl_transaction_types mtt , mtl_material_transactions mmt ' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and mtt.transaction_type_id = mmt.transaction_type_id order by mtt.transaction_type_id  ';


     p_sql(27):= ' select distinct ood.* ' ||
' from org_organization_definitions ood  ' ||
  ' where exists (SELECT 1 from mtl_material_transactions mmt' ||
 ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
               ' and (ood.organization_id = mmt.organization_id or ood.organization_id = mmt.transfer_organization_id )
)' ||
               ' OR exists (SELECT 1 ' ||
     ' from rcv_shipment_headers rsh, rcv_shipment_lines rsl' ||
                 ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
                 ' and rsh.ship_to_org_id = ' || l_org_id ||
                 ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
                 ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
                 ' and (rsh.organization_id = ood.organization_id or rsh.ship_to_org_id = ood.organization_id)' ||
                 ' )' ||
               ' order by ood.organization_id  ';



           p_sql(28):= ' select distinct miop.*' ||
' from mtl_interorg_parameters miop , mtl_material_transactions mmt' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || '''' ||
   ' and mmt.transfer_organization_id = ' || l_org_id ||
   ' and miop.from_organization_id = mmt.organization_id' ||
   ' and miop.to_organization_id = mmt.transfer_organization_id' ||
   ' and mmt.rcv_transaction_id is null ';



       p_sql(29):= ' select distinct mp.* ' ||
' from mtl_parameters mp , mtl_material_transactions mmt ' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and (mp.organization_id = mmt.organization_id ' ||
   ' or mp.organization_id = mmt.transfer_organization_id ) order by mp.organization_id  ';



           p_sql(30):= ' select distinct rp.* ' ||
' from rcv_parameters rp , mtl_material_transactions mmt ' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and (rp.organization_id = mmt.organization_id ' ||
   ' or rp.organization_id = mmt.transfer_organization_id ) order by rp.organization_id  ';



    p_sql(31):= ' select lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_LOT_CONTROL''  ';



     p_sql(32):= ' select lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_LOT_GENERATION''  ';



     p_sql(33):= ' select lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_LOT_UNIQUENESS''  ';


     p_sql(34):= ' select lookup_type , lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_SERIAL_NUMBER''  ';



     p_sql(35):= ' select lookup_type , lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_SERIAL_NUMBER_TYPE''  ';



     p_sql(36):= ' select lookup_type , lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_SERIAL_GENERATION''  ';



     p_sql(37):= ' select lookup_type , lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''SERIAL_NUM_STATUS''  ';


RETURN;
END;



PROCEDURE shipment_line_num_sql(p_org_id IN NUMBER,p_shipment_num IN VARCHAR2,
                                         p_shipment_line_num IN NUMBER, p_receipt_num IN VARCHAR2, p_sql IN OUT NOCOPY
INV_DIAG_RCV_PO_COMMON.sqls_list) IS

   l_line_num   rcv_shipment_lines.line_num%TYPE := p_shipment_line_num;
   l_shipment_num    rcv_shipment_headers.shipment_num%TYPE := p_shipment_num;
   l_receipt_num    rcv_shipment_headers.receipt_num%TYPE := p_receipt_num;
   l_org_id         rcv_shipment_headers.ship_to_org_id%TYPE := p_org_id;


BEGIN


                    p_sql(1):= ' select distinct rhi.* ' ||
' from rcv_headers_interface rhi ' ||
  ' where rhi.shipment_num = ' || '''' || l_shipment_num || ''''||
 ' or exists (' ||
   ' select 1 ' ||
    ' from rcv_shipment_headers rsh ' ||
      ' where rsh.receipt_source_code = ''INVENTORY'' ' ||
     ' and rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
       ' and rhi.receipt_header_id = rsh.shipment_header_id)  ';


       p_sql(2):= ' select distinct rti.* ' ||
' from rcv_transactions_interface rti ' ||
  ' where (exists (' ||
 ' select 1 ' ||
        ' from rcv_headers_interface rhi ' ||
          ' where rti.header_interface_id = rhi.header_interface_id ' ||
         ' and (rhi.shipment_num = ' || '''' || l_shipment_num || ''''||
           ' or exists (' ||
               ' select 1 ' ||
                ' from rcv_shipment_headers rsh ' ||
                  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
                   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
                   ' and rhi.receipt_header_id = rsh.shipment_header_id) ) ) ' ||
                   ' or exists (' ||
       ' select 2 ' ||
        ' from rcv_shipment_headers rsh ' ||
          ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
           ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
           ' and (rti.shipment_header_id = rsh.shipment_header_id ' ||
           ' OR rti.shipment_num =  nvl(' || '''' || l_shipment_num || '''' || ',rsh.shipment_num) ) ) ) ';



           p_sql(3):= ' select distinct pie.* ' ||
' from po_interface_errors pie ' ||
  ' where exists (' ||
 ' select 1 ' ||
    ' from rcv_headers_interface rhi ' ||
      ' where (rhi.shipment_num = ' || '''' || l_shipment_num || ''''||
     ' or exists (' ||
           ' select 1 ' ||
            ' from rcv_shipment_headers rsh ' ||
              ' where rsh.shipment_num = ' || '''' || l_shipment_num || ''''  ||
             ' and rhi.receipt_header_id = rsh.shipment_header_id) ) ' ||
               ' and ((pie.interface_header_id = rhi.header_interface_id ' ||
       ' and pie.table_name = ''RCV_HEADERS_INTERFACE'') ' ||
               ' or exists (' ||
           ' select 2 ' ||
            ' from rcv_transactions_interface rti ' ||
              ' where rti.header_interface_id = rhi.header_interface_id ' ||
             ' and pie.interface_line_id = rti.interface_transaction_id ' ||
               ' and pie.table_name = ''RCV_TRANSACTIONS_INTERFACE'' ) ) ) ' ||
               ' or exists (' ||
   ' select 2 ' ||
    ' from rcv_transactions_interface rti , rcv_shipment_headers rsh ' ||
      ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
     ' and rti.shipment_header_id = rsh.shipment_header_id ' ||
       ' and pie.interface_line_id = rti.interface_transaction_id ' ||
       ' and pie.table_name = ''RCV_TRANSACTIONS_INTERFACE'')  ';



           p_sql(4):= ' select distinct rsh.* ' ||
' from rcv_shipment_headers rsh' ||
  ' where rsh.receipt_source_code = ''INVENTORY'' ' ||
 ' and rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' order by rsh.shipment_header_id  ';



       p_sql(5):= ' select distinct rsl.* ' ||
' from rcv_shipment_headers rsh , rcv_shipment_lines rsl ' ||
  ' where rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' order by rsl.shipment_header_id , rsl.shipment_line_id  ';



     p_sql(6):= ' select distinct rt.* ' ||
' from rcv_transactions rt , rcv_shipment_headers rsh , rcv_shipment_lines rsl' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rt.shipment_header_id = rsh.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' order by rt.shipment_header_id , rt.shipment_line_id , rt.transaction_id  ';



     p_sql(7):= ' select distinct ms.* ' ||
' from mtl_supply ms , rcv_shipment_headers rsh , rcv_shipment_lines rsl' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rsl.shipment_line_id = ms.shipment_line_id ';



       p_sql(8):= ' select distinct rs.* ' ||
' from rcv_supply rs , rcv_shipment_headers rsh , rcv_shipment_lines rsl' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rs.shipment_line_id = rsl.shipment_line_id ';



      p_sql(9):= ' select distinct mmtt.* ' ||
' from mtl_material_transactions_temp mmtt ' ||
  ' where mmtt.shipment_number = ' || '''' || l_shipment_num || '''' ||
  ' order by mmtt.organization_id , mmtt.transaction_date  ';

    p_sql(10):= ' select distinct mmt.*' ||
' from mtl_material_transactions mmt' ||
  ' where exists (select 1' ||
 ' from rcv_shipment_headers rsh, ' ||
              ' rcv_shipment_lines rsl' ||
                   ' where mmt.shipment_number = rsh.shipment_num' ||
              ' and rsh.shipment_num= ' || '''' || l_shipment_num || '''' ||
              ' and rsh.ship_to_org_id = '|| l_org_id ||
              ' and rsl.shipment_header_id = rsh.shipment_header_id ' ||
              ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
              ' )' ||
              ' or exists (select 2 ' ||
   ' from rcv_transactions rt , rcv_shipment_headers rsh , rcv_shipment_lines rsl' ||
              ' where rt.transaction_id = mmt.rcv_transaction_id' ||
              ' and rt.shipment_header_id = rsh.shipment_header_id' ||
              ' and rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
              ' and rsh.ship_to_org_id = ' || l_org_id ||
              ' and rsl.shipment_header_id = rsh.shipment_header_id ' ||
              ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num))';


     p_sql(11) := ' select distinct mln.* ' ||
' from mtl_lot_numbers mln , mtl_transaction_lot_numbers mtln , mtl_material_transactions mmt ' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and mmt.transaction_id = mtln.transaction_id ' ||
   ' and mln.lot_number = mtln.lot_number order by mln.organization_id , mln.inventory_item_id , mln.lot_number  ';



       p_sql(12):= ' select distinct mtln.* ' ||
' from mtl_transaction_lot_numbers mtln , mtl_material_transactions mmt ' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and mmt.transaction_id = mtln.transaction_id order by mtln.organization_id , mtln.inventory_item_id , mtln.lot_number
';



       p_sql(13):= ' select distinct mtli.* ' ||
' from mtl_transaction_lots_interface mtli , mtl_transactions_interface mti ' ||
  ' where mti.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and mti.transaction_interface_id = mtli.transaction_interface_id ' ||
   ' union all ' ||
 ' select mtli.* ' ||
' from mtl_transaction_lots_interface mtli , rcv_transactions_interface rti ' ||
  ' where (exists (' ||
 ' select 1 ' ||
        ' from rcv_headers_interface rhi ' ||
          ' where rti.header_interface_id = rhi.header_interface_id ' ||
         ' and (rhi.shipment_num = ' || '''' || l_shipment_num || ''''||
           ' or exists (' ||
               ' select 1 ' ||
                ' from rcv_shipment_headers rsh ' ||
                  ' where rsh.shipment_num = ' || '''' || l_shipment_num || ''''  ||
                 ' and rhi.receipt_header_id = rsh.shipment_header_id) ) ) ' ||
                   ' or exists (' ||
       ' select 2 ' ||
        ' from rcv_shipment_headers rsh ' ||
          ' where rsh.shipment_num = ' || '''' || l_shipment_num || ''''  ||
         ' and rti.shipment_header_id = rsh.shipment_header_id ) ) ' ||
           ' and mtli.product_transaction_id = rti.interface_transaction_id  ';



       p_sql(14):= ' select distinct mtlt.* ' ||
' from mtl_transaction_lots_temp mtlt , mtl_material_transactions_temp mmtt ' ||
  ' where mmtt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and mmtt.transaction_temp_id = mtlt.transaction_temp_id order by mtlt.transaction_temp_id , mtlt.lot_number  ';


       p_sql(15):= ' select distinct rls.* ' ||
' from rcv_lots_supply rls , rcv_shipment_lines rsl , rcv_shipment_headers rsh ' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rsl.shipment_line_id = rls.shipment_line_id ' ||
   ' order by rls.shipment_line_id, rls.lot_num ';



       p_sql(16):= ' select distinct rlt.* ' ||
' from rcv_lot_transactions rlt , rcv_shipment_lines rsl , rcv_shipment_headers rsh ' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rsl.shipment_line_id = rlt.shipment_line_id order by rlt.shipment_line_id , rlt.item_id , rlt.lot_num  ';



       p_sql(17):= ' select distinct rli.* ' ||
' from rcv_lots_interface rli , rcv_shipment_lines rsl , rcv_shipment_headers rsh ' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
  ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
  ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
  ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
  ' and rsl.item_id = Nvl(rli.shipment_line_id,rsl.item_id )' ||
  ' and rsl.item_id = rli.item_id' ||
  ' order by rli.item_id , rli.lot_num  ';


                   p_sql(18):= ' select distinct rss.* ' ||
' from rcv_serials_supply	rss , rcv_shipment_lines rsl , rcv_shipment_headers rsh , rcv_transactions rt ' ||
   ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.ship_to_org_id = ' || l_org_id ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.shipment_line_id = rt.shipment_line_id ' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rss.shipment_line_id = rsl.shipment_line_id' ||
   ' order by rss.serial_num ';



     p_sql(19):= ' select distinct rst.* ' ||
' from rcv_serial_transactions rst , rcv_shipment_lines rsl , rcv_shipment_headers rsh ' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rst.shipment_line_id = rsl.shipment_line_id ' ||
   ' order by rst.shipment_line_id , rst.serial_num  ';



     p_sql(20):= ' select distinct rsi.* ' ||
' from rcv_serials_interface rsi , rcv_shipment_lines rsl , rcv_shipment_headers rsh ' ||
  ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rsi.item_id = rsl.item_id ' ||
   ' and rsi.organization_id = rsl.to_organization_id ' ||
   ' order by rsi.organization_id , rsi.item_id , rsi.fm_serial_num  ';


           p_sql(21):= ' select distinct msn.* ' ||
' from mtl_serial_numbers msn , mtl_material_transactions mmt , rcv_shipment_headers rsh, rcv_shipment_lines rsl' ||
  ' where msn.last_transaction_id = mmt.transaction_id ' ||
 ' and mmt.shipment_number = rsh.shipment_num' ||
   ' and rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
   ' and rsh.receipt_source_code = ''INVENTORY'' ' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)    order by msn.inventory_item_id ,
msn.serial_number ';


       p_sql(22):= ' select distinct msnt.* ' ||
' from mtl_serial_numbers_temp msnt' ||
  ' where (exists (SELECT 1 ' ||
 ' from mtl_material_transactions_temp mmtt ' ||
                ' where mmtt.shipment_number = ' || '''' || l_shipment_num || '''' ||
                ' and (msnt.transaction_temp_id = mmtt.transaction_temp_id ' ||
                ' or exists (' ||
                  ' select 1 ' ||
                             ' from mtl_transaction_lots_temp mtlt ' ||
                             ' where mtlt.serial_transaction_temp_id = msnt.transaction_temp_id ' ||
                             ' and mmtt.transaction_temp_id = mtlt.transaction_temp_id) ) ' ||
                             ' )' ||
              ' OR exists (SELECT 2 ' ||
    ' from rcv_transactions_interface rti ' ||
               ' where rti.shipment_num = ' || '''' || l_shipment_num || '''' ||
               ' and (msnt.transaction_temp_id = rti.interface_transaction_id ' ||
               ' or exists (' ||
                  ' select 1 ' ||
                             ' from mtl_transaction_lots_temp mtlt ' ||
                             ' where mtlt.serial_transaction_temp_id = msnt.transaction_temp_id ' ||
                             ' and rti.interface_transaction_id = mtlt.transaction_temp_id) )' ||
                             ' )' ||
              ' ) ';


       p_sql(23):= ' select distinct msni.* ' ||
' from mtl_serial_numbers_interface	msni , mtl_transactions_interface mti , mtl_system_items msi ' ||
  ' where mti.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and msi.inventory_item_id = mti.inventory_item_id ' ||
   ' and msi.organization_id = mti.organization_id ' ||
   ' and msi.serial_number_control_code <> 1 ' ||
   ' and ((msni.transaction_Interface_id = mti.transaction_Interface_id ' ||
   ' and msi.lot_control_code = 1 ) ' ||
           ' or (exists (' ||
       ' select 3 ' ||
            ' from mtl_transaction_lots_interface mtli ' ||
              ' where mtli.transaction_Interface_id = mti.transaction_Interface_id ' ||
             ' and msni.transaction_Interface_id = mtli.serial_transaction_temp_id ) ' ||
               ' and (msi.lot_control_code <> 1 ) ) ) ' ||
           ' union all ' ||
 ' select msni.* ' ||
' from mtl_serial_numbers_interface msni , rcv_transactions_interface rti ' ||
  ' where (exists (' ||
 ' select 1 ' ||
        ' from rcv_headers_interface rhi ' ||
          ' where rti.header_interface_id = rhi.header_interface_id ' ||
         ' and (rhi.shipment_num = ' || '''' || l_shipment_num || ''''||
           ' or exists (' ||
               ' select 1 ' ||
                ' from rcv_shipment_headers rsh ' ||
                  ' where rsh.shipment_num = ' || '''' || l_shipment_num || ''''  ||
                 ' and rhi.receipt_header_id = rsh.shipment_header_id) ) ) ' ||
                   ' or exists (' ||
       ' select 2 ' ||
        ' from rcv_shipment_headers rsh ' ||
          ' where rsh.shipment_num = ' || '''' || l_shipment_num || ''''  ||
         ' and rti.shipment_header_id = rsh.shipment_header_id ) ) ' ||
           ' and msni.product_transaction_id = rti.interface_transaction_id  ';



              p_sql(24):= ' select distinct mut.* ' ||
' from mtl_unit_transactions mut , mtl_material_transactions mmt , rcv_transactions rt, rcv_shipment_headers rsh,
rcv_shipment_lines rsl' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
  ' and rsh.ship_to_org_id = ' || l_org_id ||
  ' and rsh.shipment_header_id = rsl.shipment_header_id ' ||
  ' and rsl.shipment_line_id = rt.shipment_line_id ' ||
  ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
  ' and rt.transaction_id = mmt.rcv_transaction_id ' ||
  ' and rt.shipment_header_id = rsh.shipment_header_id ' ||
 ' and (mut.transaction_id = mmt.transaction_id ' ||
   ' or (exists (' ||
       ' select 2 ' ||
            ' from mtl_transaction_lot_numbers mtln ' ||
              ' where mut.transaction_id = mtln.serial_transaction_id ' ||
             ' and mmt.transaction_id = mtln.transaction_id) ) ) order by mut.inventory_item_id , mut.serial_number  ';



   p_sql(25):= ' select distinct msi.* ' ||
' from mtl_material_transactions mmt , mtl_system_items msi , rcv_shipment_headers rsh , rcv_shipment_lines rsl' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || '''' ||
 ' and mmt.shipment_number = rsh.shipment_num' ||
   ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
   ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
   ' and rsl.item_id = msi.inventory_item_id ' ||
   ' and msi.inventory_item_id = mmt.inventory_item_id ' ||
   ' and msi.organization_id in (mmt.organization_id , mmt.transfer_organization_id) ' ||
   ' order by msi.organization_id , msi.inventory_item_id ';




       p_sql(26):= ' select distinct mtt.transaction_type_id , mtt.transaction_type_name ,
mtt.transaction_source_type_id , mtt.transaction_action_id , ' ||
' mtt.user_defined_flag , mtt.disable_date ' ||
' from mtl_transaction_types mtt , mtl_material_transactions mmt ' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || '''' ||
 ' and mtt.transaction_type_id = mmt.transaction_type_id' ||
   ' and exists ( SELECT 1' ||
   ' from rcv_shipment_headers rsh , rcv_shipment_lines rsl' ||
                 ' where mmt.shipment_number = rsh.shipment_num' ||
                ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
                  ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num))' ||
                  ' order by mtt.transaction_type_id  ';



     p_sql(27):= ' select distinct ood.* ' ||
' from org_organization_definitions ood  ' ||
  ' where exists (SELECT 1 from mtl_material_transactions mmt' ||
 ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
               ' and (ood.organization_id = mmt.organization_id or ood.organization_id = mmt.transfer_organization_id )
)' ||
               ' OR exists (SELECT 1 ' ||
     ' from rcv_shipment_headers rsh, rcv_shipment_lines rsl' ||
                 ' where rsh.shipment_num = ' || '''' || l_shipment_num || '''' ||
                 ' and rsh.shipment_header_id = rsl.shipment_header_id' ||
                 ' and rsl.line_num = nvl(' || '''' || l_line_num || '''' || ',rsl.line_num)' ||
                 ' and (rsh.organization_id = ood.organization_id or rsh.ship_to_org_id = ood.organization_id)' ||
                 ' )' ||
               ' order by ood.organization_id  ';



           p_sql(28):= ' select distinct miop.*' ||
' from mtl_interorg_parameters miop , mtl_material_transactions mmt' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || '''' ||
   ' and mmt.transfer_organization_id = ' || l_org_id ||
   ' and miop.from_organization_id = mmt.organization_id' ||
   ' and miop.to_organization_id = mmt.transfer_organization_id' ||
   ' and mmt.rcv_transaction_id is null ';



       p_sql(29):= ' select distinct mp.* ' ||
' from mtl_parameters mp , mtl_material_transactions mmt ' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and (mp.organization_id = mmt.organization_id ' ||
   ' or mp.organization_id = mmt.transfer_organization_id ) order by mp.organization_id  ';



           p_sql(30):= ' select distinct rp.* ' ||
' from rcv_parameters rp , mtl_material_transactions mmt ' ||
  ' where mmt.shipment_number = ' || '''' || l_shipment_num || ''''  ||
 ' and (rp.organization_id = mmt.organization_id ' ||
   ' or rp.organization_id = mmt.transfer_organization_id ) order by rp.organization_id  ';


    p_sql(31):= ' select lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_LOT_CONTROL''  ';



     p_sql(32):= ' select lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_LOT_GENERATION''  ';



     p_sql(33):= ' select lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_LOT_UNIQUENESS''  ';

     p_sql(34):= ' select lookup_type , lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_SERIAL_NUMBER''  ';



     p_sql(35):= ' select lookup_type , lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_SERIAL_NUMBER_TYPE''  ';



     p_sql(36):= ' select lookup_type , lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''MTL_SERIAL_GENERATION''  ';



     p_sql(37):= ' select lookup_type , lookup_code , meaning , enabled_flag , start_date_active , end_date_active ' ||
' from mfg_lookups ' ||
  ' where lookup_type = ''SERIAL_NUM_STATUS''  ';

RETURN;
END;

END IOT_DIAGNOSTICS ;



/
