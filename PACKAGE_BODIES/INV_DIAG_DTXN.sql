--------------------------------------------------------
--  DDL for Package Body INV_DIAG_DTXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_DTXN" as
/* $Header: INVDTD1B.pls 120.1 2008/02/21 21:17:21 musinha noship $ */
PROCEDURE init is
BEGIN
null;
END init;

PROCEDURE cleanup IS
BEGIN
-- test writer could insert special cleanup code here
NULL;
END cleanup;

PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                        report OUT NOCOPY JTF_DIAG_REPORT,
                        reportClob OUT NOCOPY CLOB) IS
 reportStr   LONG;           -- REPORT
 sqltxt    VARCHAR2(9999);  -- SQL select statement
 c_username  VARCHAR2(50);   -- accept input for username
 statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr      VARCHAR2(4000); -- error message
 fixInfo     VARCHAR2(4000); -- fix tip
 isFatal     VARCHAR2(50);   -- TRUE or FALSE
 dummy_num   NUMBER;
 row_limit   NUMBER;
 l_txn_id    NUMBER;
 l_org_id    NUMBER;
 l_acct_period_id NUMBER;
 l_script    varchar2(30);
 l_proc_flag varchar2(1);
 l_src_line_id NUMBER;

 cursor c_overshipline is
 select wdd1.source_line_id from
 ( select inventory_item_id, trx_source_line_id, organization_id, sum(abs(transaction_quantity)) mmt_qty
    from   mtl_material_transactions
    where  picking_line_id is not null
    and    transaction_source_type_id = 8
    group by inventory_item_id, trx_source_line_id, organization_id
 )  mmt ,
 (  select wdd.source_header_number, wdd.source_line_id, wdd.inventory_item_id,
   wdd.organization_id, sum(wdd.shipped_quantity) shp_qty
    from   wsh_delivery_details wdd
    where  wdd.source_code = 'OE'
    and    wdd.released_status = 'C'
    and    wdd.serial_number is null
   group  by wdd.source_header_number, wdd.source_line_id, wdd.inventory_item_id, wdd.organization_id
 ) wdd1
 where mmt.mmt_qty > wdd1.shp_qty
 and mmt.trx_source_line_id = wdd1.source_line_id
 and mmt.inventory_item_id = wdd1.inventory_item_id
 and mmt.organization_id = wdd1.organization_id
 and mmt.organization_id = nvl(l_org_id, mmt.organization_id);

 -- Bug 6690548: Removed the table mtl_item_flexfields from the FROM clause
 -- of the following query as it was causing performance issues. And also added
 -- the where clause to check that the organization's primary cost method is not standard.
 cursor c_cstgrp  is
 SELECT DISTINCT moqd.inventory_item_id,mp.organization_id, mp.default_cost_group_id
 FROM mtl_onhand_quantities_detail moqd,
 mtl_parameters mp
 --mtl_item_flexfields mif
 WHERE moqd.organization_id  = nvl(l_org_id, moqd.organization_id)
 AND  moqd.cost_group_id   <> mp.default_cost_group_id
 and  moqd.organization_id = mp.organization_id
 and  mp.primary_cost_method <> 1;


BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
l_script :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ScriptName',inputs);
l_proc_flag :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ProcFlag',inputs);
row_limit :=INV_DIAG_GRP.g_max_row;

if l_script = 'acct_period' then

   sqltxt := 'SELECT organization_code || '' ('' ||mmt.organization_id|| '')'' "Organization|Code (Id)"  '||
            ',TO_CHAR( transaction_date, ''DD-MON-RR'' ) "Txn Date"   '||
            ',mmt.acct_period_id "MMT Acct period" '||
            ',oap.acct_period_id "OAP Acct period" '||
            ',mtst.transaction_source_type_name ||'' (''||mmt.transaction_source_type_id||'')'' "Txn Source Type (Id)"  '||
            ',mtt.transaction_type_name  ||'' (''||mmt.transaction_type_id||'')'' "Txn Type (Id)"   '||
            ',ml.meaning  ||'' (''||mmt.transaction_action_id||'')'' "Txn Action Type (Id)"   '||
            ',TO_CHAR( mmt.last_update_date, ''DD-MON-RR HH24:MI'') "Last Updated"   '||
            ',mif.item_number  ||'' (''||mmt.inventory_item_id||'')'' "Item (Id)"   '||
            ',mif.description "Item Description"   '||
            ',revision "Rev"    '||
            ',mmt.cost_group_id "Cost Group Id"   '||
            ',mmt.subinventory_code "Subinv"   '||
            ',mil.description ||'' (''||mmt.locator_id||'') '' "Stock|Locator (Id)"   '||
            ',transfer_subinventory "Transfer Subinv"   '||
            ',transfer_locator_id "Transfer Location"   '||
            ',transaction_quantity "Txn Qty"    '||
            ',primary_quantity "Primary Qty"    '||
            ',transaction_uom "Txn UoM"   '||
            'FROM mtl_material_transactions mmt   '||
            ',mtl_transaction_types mtt '||
            ',mtl_txn_source_types mtst '||
            ',mtl_item_flexfields mif   '||
            ',mfg_lookups ml   '||
            ',mtl_item_locations_kfv mil '||
            ',org_acct_periods oap '||
            ',mtl_parameters mp '||
            'WHERE mmt.transaction_type_id=mtt.transaction_type_id  '||
            'AND mmt.transaction_source_Type_id = mtst.transaction_source_type_id '||
            'AND mmt.organization_id=mif.organization_id(+)  '||
            'AND mmt.inventory_item_id=mif.inventory_item_id(+)  '||
            'AND mmt.transaction_action_id=ml.lookup_code  '||
            'AND ml.lookup_type=''MTL_TRANSACTION_ACTION''  '||
            'AND mmt.locator_id=mil.inventory_location_id(+)  '||
            'AND mmt.organization_id=mil.organization_id(+) '||
            'AND mmt.organization_id = mp.organization_id(+) '||
            'AND oap.organization_id = mmt.organization_id '||
            'AND mmt.transaction_date BETWEEN trunc(oap.period_start_date)  and trunc(oap.schedule_close_date)  '||
            'AND  nvl(mmt.acct_period_id,-1) <>  nvl(oap.acct_period_id,0)';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and mmt.organization_id =  '||l_org_id;
   end if;

   sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Transactions with Incorrect Account Period in MMT ');

elsif l_script = 'lotleading' then
   sqltxt :='select mp.organization_code|| '' (''||mln.organization_id ||'')'' "Organization|Code (Id)" '||
            ',mif.item_number|| '' (''||mln.inventory_item_id||'')'' "Item (Id)" , '||
            'lot_number "Lot number" '||
            'from mtl_lot_numbers mln, '||
            'mtl_parameters mp,mtl_item_flexfields mif '||
            'where lot_number <> ltrim(lot_number)  '||
            'and mln.organization_id = mp.organization_id(+) '||
            'and mln.inventory_item_id = mif.inventory_item_id(+) '||
            'and mln.organization_id = mif.organization_id(+)';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and mln.organization_id =  '||l_org_id;
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Lot Number with leading space in mtl_lot_numbers ');

   sqltxt :='select mp.organization_code|| '' (''||mtln.organization_id ||'')'' "Organization|Code (Id)" '||
            ',mif.item_number|| '' (''||mtln.inventory_item_id||'')'' "Item (Id)",  '||
            'lot_number "Lot number" '||
            'from mtl_transaction_lot_numbers mtln, '||
            'mtl_parameters mp,mtl_item_flexfields mif '||
            'where lot_number <> ltrim(lot_number)  '||
            'and mtln.organization_id = mp.organization_id(+) '||
            'and mtln.inventory_item_id = mif.inventory_item_id(+) '||
            'and mtln.organization_id = mif.organization_id(+)';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and mtln.organization_id =  '||l_org_id;
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Lot Number with leading space in mtl_transaction_lot_numbers ');

   sqltxt :='select mp.organization_code|| '' (''||moqd.organization_id ||'')'' "Organization|Code (Id)" '||
            ',mif.item_number|| '' (''||moqd.inventory_item_id||'')'' "Item (Id)" , '||
            'lot_number "Lot number" '||
            'from mtl_onhand_quantities_detail moqd, '||
            'mtl_parameters mp,mtl_item_flexfields mif '||
            'where lot_number <> ltrim(lot_number)  '||
            'and moqd.organization_id = mp.organization_id(+) '||
            'and moqd.inventory_item_id = mif.inventory_item_id(+) '||
            'and moqd.organization_id = mif.organization_id(+)';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and moqd.organization_id =  '||l_org_id;
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Lot Number with leading space in mtl_onhand_quantities_detail ');

   sqltxt :='select mp.organization_code|| '' (''||mr.organization_id ||'')'' "Organization|Code (Id)" '||
            ',mif.item_number|| '' (''||mr.inventory_item_id||'')'' "Item (Id)",  '||
            'lot_number "Lot number" '||
            'from mtl_reservations mr, '||
            'mtl_parameters mp,mtl_item_flexfields mif '||
            'where lot_number <> ltrim(lot_number)  '||
            'and mr.organization_id = mp.organization_id(+) '||
            'and mr.inventory_item_id = mif.inventory_item_id(+) '||
            'and mr.organization_id = mif.organization_id(+)';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and mr.organization_id =  '||l_org_id;
   end if;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Lot Number with leading space in mtl_reservations ');

elsif l_script = 'neg_bal' then
   sqltxt :='select mp.organization_code|| '' (''||mti.organization_id ||'')'' "OrganizationCode (Id)" '||
            ',mif.item_number|| '' (''||mti.inventory_item_id||'')'' item '||
            ',rev,sub,onhand,qty_avail,transaction_quantity  '||
            'from  '||
            ' (select mti.organization_id ,mti.inventory_item_id ,mti.revision rev,  '||
            ' mti.subinventory_code sub '||
            ' ,INV_DIAG_GRP.CHECK_ONHAND(mti.inventory_item_id, mti.organization_id,mti.revision,mti.subinventory_code,mti.locator_id) onhand '||
            ' ,INV_DIAG_GRP.CHECK_AVAIL(mti.inventory_item_id,mti.organization_id ,mti.revision ,mti.subinventory_code,mti.locator_id) qty_avail '||
            ' ,transaction_quantity  '||
            ' from mtl_transactions_interface mti  '||
            ' group by mti.inventory_item_id,mti.organization_id,mti.revision,  '||
            ' mti.subinventory_code,mti.locator_id,transaction_quantity  '||
            ' order by mti.inventory_item_id) mti '||
            ', mtl_parameters mp '||
            ',mtl_item_flexfields mif '||
            'where qty_avail < 0  '||
            'and mti.organization_id = mp.organization_id '||
            'and mti.inventory_item_id = mif.inventory_item_id '||
            'and mti.organization_id = mif.organization_id ';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and mti.organization_id =  '||l_org_id;
   end if;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Onhand Information Associated with Transactions stuck in MTI with Negative Balance Error');

   sqltxt := 'select mp.organization_code|| '' (''||mti.organization_id ||'')'' "OrganizationCode (Id)" '||
              ',mif.item_number|| '' (''||mti.inventory_item_id||'')'' item '||
              ',rev,sub,onhand,qty_avail,transaction_quantity  '||
              'from  '||
              ' (select mti.organization_id ,mti.inventory_item_id ,mti.revision rev,  '||
              ' mti.subinventory_code sub '||
              ' ,INV_DIAG_GRP.CHECK_ONHAND(mti.inventory_item_id, mti.organization_id,mti.revision,mti.subinventory_code,mti.locator_id) onhand '||
              ' ,INV_DIAG_GRP.CHECK_AVAIL(mti.inventory_item_id,mti.organization_id ,mti.revision ,mti.subinventory_code,mti.locator_id) qty_avail '||
              ' ,transaction_quantity  '||
              ' from mtl_material_transactions_temp mti  '||
              ' group by mti.inventory_item_id,mti.organization_id,mti.revision,  '||
              ' mti.subinventory_code,mti.locator_id,transaction_quantity  '||
              ' order by mti.inventory_item_id) mti '||
              ', mtl_parameters mp '||
              ',mtl_item_flexfields mif '||
              'where qty_avail < 0  '||
              'and mti.organization_id = mp.organization_id '||
              'and mti.inventory_item_id = mif.inventory_item_id '||
              'and mti.organization_id = mif.organization_id ';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and mti.organization_id =  '||l_org_id;
   end if;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Onhand Information Associated with Transactions stuck in MMTT with Negative Balance Error');


elsif l_script = 'mut_dups' then
   sqltxt :='select * from ( '||
            'select transaction_id "Txn Id" , serial_number "Serial number" , '||
            'mif.item_number ||'' (''||mut.inventory_item_id ||'')'' "Item (Id)", '||
            'mp.organization_code ||'' (''|| mut.organization_id||'')'' "Org code (Id)" ,count(*)  '||
            'from mtl_unit_transactions mut, '||
            'mtl_item_flexfields mif , '||
            'mtl_parameters mp '||
            'where mut.inventory_item_id = mif.inventory_item_id(+) '||
            'and mut.organization_id = mif.organization_id (+) '||
            'and mut.organization_id = mp.organization_id (+) '||
            'and transaction_id >0  '||
            'group by mut.transaction_id,mut.serial_number,mif.item_number,mut.inventory_item_id ,mp.organization_code,mut.organization_id '||
            'having count(*) > 1) '||
            'where rownum <= '||row_limit;

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Duplicate Transactions in MTL_UNIT_TRANSACTIONS (max count: '||row_limit||' )');

elsif l_script = 'overshipped' then
   sqltxt :='select mp.organization_code|| '' (''||mmt.organization_id ||'')'' "Organization|Code (Id)" '||
            ',mif.item_number|| '' (''||mmt.inventory_item_id||'')'' "Item (Id)" , '||
            'wdd1.source_header_number "Order Number", wdd1.source_line_id "Source line Id", '||
            'mmt.mmt_qty "MMT Qty", wdd1.shp_qty "Shp qty",mmt.mmt_qty -wdd1.shp_qty "Diff Qty" FROM  '||
            '( select inventory_item_id, trx_source_line_id, organization_id, sum(abs(transaction_quantity)) mmt_qty '||
            '    from   mtl_material_transactions '||
            '    where  picking_line_id is not null '||
            '    and    transaction_source_type_id = 8  '||
            '    group by inventory_item_id, trx_source_line_id, organization_id)  mmt , '||
            '(  select wdd.source_header_number, wdd.source_line_id, wdd.inventory_item_id,  '||
            '   wdd.organization_id, sum(wdd.shipped_quantity) shp_qty '||
            '    from   wsh_delivery_details wdd '||
            '    where  wdd.source_code = ''OE'' '||
            '    and    wdd.released_status = ''C'' '||
            '    and    wdd.serial_number is null '||
            '   group  by wdd.source_header_number, wdd.source_line_id, wdd.inventory_item_id, wdd.organization_id) wdd1, '||
            '   mtl_parameters mp,mtl_item_flexfields mif '||
            '  where mmt.mmt_qty > wdd1.shp_qty '||
            '  and mmt.trx_source_line_id = wdd1.source_line_id '||
            '  and mmt.inventory_item_id = wdd1.inventory_item_id '||
            '  and mmt.organization_id = wdd1.organization_id '||
            '  and mmt.organization_id = mp.organization_id(+) '||
            '  and mmt.inventory_item_id = mif.inventory_item_id(+) '||
            '  and mmt.organization_id = mif.organization_id(+)';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and mmt.organization_id =  '||l_org_id;
   end if;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Order Lines with Shipped Qty < Interfaced Qty (MMT) ');

   for c1 in c_overshipline
       loop
         sqltxt:= 'select mif.item_number|| '' (''||mif.inventory_item_id||'')'' "Item (Id)" , '||
                  '      rsh.receipt_num "Receipt num", '||
                  '      rct.transaction_type "Transaction type", '||
                  '      rct.transaction_id transaction_id, '||
                  '      rct.quantity quantity, '||
                  '      rsl.item_id  item_id, '||
                  '      rct.LAST_UPDATE_DATE LAST_UPDATE_DATE, '||
                  '      rct.LAST_UPDATED_BY LAST_UPDATED_BY, '||
                  '      rct.CREATION_DATE CREATION_DATE, '||
                  '      rct.CREATED_BY CREATED_BY, '||
                  '      rct.LAST_UPDATE_LOGIN LAST_UPDATE_LOGIN   '||
                  'from   rcv_transactions rct, '||
                  '      rcv_shipment_headers rsh, '||
                  '      rcv_shipment_lines rsl, '||
                  '      po_requisition_lines prl, '||
                  '      po_requisition_headers prh, '||
                  '      oe_order_lines_all oel, '||
                  '      oe_order_headers_all oeh, '||
                  '      mtl_item_Flexfields mif '||
                  'where   rct.requisition_line_id = prl.requisition_line_id '||
                  'and    rct.shipment_header_id = rsh.shipment_header_id '||
                  'and    rct.shipment_line_id   = rsl.shipment_line_id  '||
                  'and    oel.orig_sys_line_ref = to_char(prl.line_num) '||
                  'and    oeh.orig_sys_document_ref    = prh.segment1 '||
                  'and    oel.header_id                = oeh.header_id '||
                  'and    prl.requisition_header_id    =  prh.requisition_header_id '||
                  'and    rsl.item_id = mif.inventory_item_id(+) '||
                  'and    rsl.to_organization_id = mif.organization_id(+) '||
                  'and    oel.line_id = '||c1.source_line_id;

         dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Receipt details for ship line id '||c1.source_line_id);
       end loop;
elsif l_script = 'invfixcg' then
   sqltxt :='SELECT  mp.organization_code||'' (''||organization_id||'')'' "Organization code (Id)" '||
            ', default_cost_group_id "Default Cost group Id" '||
            'FROM    mtl_parameters mp '||
            'WHERE   mp.primary_cost_method <> 1 ';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and mp.organization_id =  '||l_org_id;
   end if;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Organization Default Cost Group Id ');

   -- Bug 6690548: Added the where clause to check that the organization's primary cost method is not standard.
   sqltxt :='SELECT mp.organization_code|| '' (''||moqd.organization_id ||'')'' "Organization|Code (Id)" '||
            ',mif.item_number|| '' (''||moqd.inventory_item_id||'')'' "Item (Id)" '||
            ',moqd.cost_group_id "Cost group Id" '||
            ',mp.default_cost_group_id  "Default Cost Group Id" '||
            'FROM '||
            'mtl_onhand_quantities_detail moqd, '||
            'mtl_parameters mp, '||
            'mtl_item_flexfields mif '||
            'WHERE   moqd.cost_group_id   <> mp.default_cost_group_id '||
            'and moqd.inventory_item_id = mif.inventory_item_id  '||
            'and moqd.organization_id = mp.organization_id '||
            'and mp.primary_cost_method <> 1 '||
            'and moqd.organization_id = mif.organization_id ';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and moqd.organization_id =  '||l_org_id;
   end if;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Cost_group_id in MOQD is not the same as the default cost group id of the org ');

   for c2 in c_cstgrp
   loop
       sqltxt :='select count(1) '||
                ' from cst_item_costs cic '||
                ' where cic.inventory_item_id = '||c2.inventory_item_id||
                ' and cic.cost_type_id = '||c2.organization_id;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Count of records in cst_item_costs for the item-org '||c2.inventory_item_id||'-'||c2.organization_id);

       -- Bug 6690548: Modified the where clause to retrieve only those records which have incorrect cost_group_id.
       sqltxt :='select layer_id "Layer Id", '||
                ' mp.organization_code|| '' (''||cql.organization_id ||'')'' "Organization|Code (Id)" '||
                ',mif.item_number|| '' (''||cql.inventory_item_id||'')'' "Item (Id)", '||
                ' cost_group_id "Cost Group Id", '||
                ' layer_quantity "Layer Qty", '||
                '                PL_MATERIAL, '||
                ' PL_MATERIAL_OVERHEAD, '||
                ' PL_RESOURCE, '||
                ' PL_OUTSIDE_PROCESSING, '||
                ' PL_OVERHEAD, '||
                ' TL_MATERIAL, '||
                '     			TL_MATERIAL_OVERHEAD, '||
                ' TL_RESOURCE, '||
                ' TL_OUTSIDE_PROCESSING, '||
                ' TL_OVERHEAD, '||
                ' MATERIAL_COST, '||
                ' MATERIAL_OVERHEAD_COST , '||
                ' RESOURCE_COST, '||
                ' OUTSIDE_PROCESSING_COST, '||
                ' OVERHEAD_COST, '||
                ' PL_ITEM_COST, '||
                ' TL_ITEM_COST, '||
                ' ITEM_COST, '||
                ' UNBURDENED_COST, '||
                ' BURDEN_COST, '||
                ' CREATE_TRANSACTION_ID '||
                'from '||
                'cst_quantity_layers CQL, '||
                'mtl_parameters mp, '||
                'mtl_item_flexfields mif '||
                'WHERE cql.organization_id     =  '||c2.organization_id ||
                'AND   cql.cost_group_id      <>  '||c2.default_cost_group_id ||
                'AND   cql.inventory_item_id = '||c2.inventory_item_id ||
                'and cql.inventory_item_id = mif.inventory_item_id (+) '||
                'and cql.organization_id = mif.organization_id (+)';

       sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Records in cst_quantity_layers for the item-org with incorrect cost_group '||c2.inventory_item_id||'-'||c2.organization_id);

       sqltxt :='SELECT  cicd.cost_element_id, '||
                '        cicd.level_type, '||
                '        cicd.last_update_date, '||
                '        cicd.last_updated_by, '||
                '        cicd.creation_date, '||
                '        cicd.created_by, '||
                '        cicd.request_id, '||
                '        cicd.program_application_id, '||
                '        cicd.program_id, '||
                '        cicd.item_cost '||
                'FROM    cst_item_cost_details cicd '||
                'WHERE   cicd.inventory_item_id= '||c2.inventory_item_id ||
                'AND     cicd.organization_id = '||c2.organization_id ||
                'AND     cicd.cost_type_id = 2';

       sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Records in cst_item_cost_details for the item-org '||c2.inventory_item_id||'-'||c2.organization_id);

   end loop;

elsif l_script = 'txn_src_mismatch' then
   sqltxt :='select mmt.transaction_id "Txn Id" '||
            ', mif.item_number ||'' (''|| mmt.inventory_item_id ||'')'' "Item (Id)" '||
            ', mmt.transaction_date "Txn Date" '||
            ', mmt.acct_period_id "Period Id" '||
            ', mmt.transaction_quantity "Txn Qty" '||
            ', mmt.primary_quantity "Prim Qty" '||
            ', mmt.transaction_uom "Uom" '||
            ', tt.transaction_type_name ||'' (''||mmt.transaction_type_id||'')'' "Txn Type (Id)" '||
            ', mmt.subinventory_code "Subinv" '||
            ', mmt.locator_id "Stock Locator" '||
            ', mmt.revision "Rev" '||
            ', mmt.costed_flag "Costed Flag" '||
            ', mmt.creation_date "Created" '||
            ', mmt.last_update_date "Last Updated" '||
            ', ml.meaning || '' ('' ||mmt.transaction_action_id|| '')''  "Txn Action (Id)" '||
            ', st.transaction_source_type_name ||'' (''|| mmt.transaction_source_type_id ||'')'' "Txn Source Type (Id)" '||
            ', mmt.transaction_source_id "Txn Source Id" '||
            ', mmt.transaction_source_name "Txn Source" '||
            ', mmt.source_code "Source|Code" '||
            ', mmt.source_line_id "Source Line Id" '||
            ', mmt.request_id "Txn Request Id" '||
            ', mmt.operation_seq_num "Operation|Seq Num" '||
            ', mmt.transfer_transaction_id "Transfer Txn Id" '||
            ', mmt.transfer_organization_id "Transfer Organization Id" '||
            ', mmt.transfer_subinventory "Transfer Subinv" '||
            ', mmt.shipment_number '||
            'from mtl_material_transactions mmt '||
            ', mtl_item_flexfields mif '||
            ', mtl_transaction_types tt '||
            ', mtl_txn_source_types st '||
            ', mfg_lookups ml '||
            'where  '||
            'mmt.organization_id = mif.organization_id(+) '||
            'AND mmt.transaction_type_id = tt.transaction_type_id(+) '||
            'AND mmt.transaction_source_type_id = st.transaction_source_type_id(+) '||
            'AND mmt.transaction_action_id=ml.lookup_code '||
            'AND ml.lookup_type = ''MTL_TRANSACTION_ACTION'' '||
            'AND mmt.transaction_source_type_id = 8  '||
            'and mmt.transaction_action_id = 2  '||
            'and mmt.transaction_type_id = 50  '||
            'and mmt.primary_quantity > 0  '||
            'and mmt.transaction_id in (  '||
            'select transfer_transaction_id from  '||
            'mtl_material_transactions  '||
            'where transaction_Source_type_id=8  '||
            'and transaction_action_id=2  '||
            'and transaction_type_id=50  '||
            'and primary_quantity < 0)';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and mmt.organization_id =  '||l_org_id;
   end if;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Txns in MMT not having source type of Internal Requistion for Internal order sub-transfer');

   sqltxt :='select mmt.transaction_id "Txn Id" '||
            ', mif.item_number ||'' (''|| mmt.inventory_item_id ||'')'' "Item (Id)" '||
            ', mmt.transaction_date "Txn Date" '||
            ', mmt.acct_period_id "Period Id" '||
            ', mmt.transaction_quantity "Txn Qty" '||
            ', mmt.primary_quantity "Prim Qty" '||
            ', mmt.transaction_uom "Uom" '||
            ', tt.transaction_type_name ||'' (''||mmt.transaction_type_id||'')'' "Txn Type (Id)" '||
            ', mmt.subinventory_code "Subinv" '||
            ', mmt.locator_id "Stock Locator" '||
            ', mmt.revision "Rev" '||
            ', mmt.costed_flag "Costed Flag" '||
            ', mmt.creation_date "Created" '||
            ', mmt.last_update_date "Last Updated" '||
            ', ml.meaning || '' ('' ||mmt.transaction_action_id|| '')''  "Txn Action (Id)" '||
            ', st.transaction_source_type_name ||'' (''|| mmt.transaction_source_type_id ||'')'' "Txn Source Type (Id)" '||
            ', mmt.transaction_source_id "Txn Source Id" '||
            ', mmt.transaction_source_name "Txn Source" '||
            ', mmt.source_code "Source|Code" '||
            ', mmt.source_line_id "Source Line Id" '||
            ', mmt.request_id "Txn Request Id" '||
            ', mmt.operation_seq_num "Operation|Seq Num" '||
            ', mmt.transfer_transaction_id "Transfer Txn Id" '||
            ', mmt.transfer_organization_id "Transfer Organization Id" '||
            ', mmt.transfer_subinventory "Transfer Subinv" '||
            ', mmt.shipment_number '||
            'from mtl_material_transactions mmt '||
            ', mtl_item_flexfields mif '||
            ', mtl_transaction_types tt '||
            ', mtl_txn_source_types st '||
            ', mfg_lookups ml '||
            'where  '||
            'mmt.organization_id = mif.organization_id(+) '||
            'AND mmt.transaction_type_id = tt.transaction_type_id(+) '||
            'AND mmt.transaction_source_type_id = st.transaction_source_type_id(+) '||
            'AND mmt.transaction_action_id=ml.lookup_code '||
            'AND ml.lookup_type = ''MTL_TRANSACTION_ACTION'' '||
            'and mmt.transaction_source_type_id=8  '||
            'and mmt.transaction_quantity >0 and mmt.transaction_action_id in (3,12)  '||
            'and not exists(select 1 from mtl_sales_orders where  '||
            'sales_order_id=transaction_source_id)';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and mmt.organization_id =  '||l_org_id;
   end if;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Txns in MMT not having source type of Internal Requistion for Internal order Intransit receipt');

elsif l_script = 'duplicat_txn' then
   sqltxt :='select a.transaction_interface_id ,  '||
            'a.picking_line_id from  '||
            'mtl_material_transactions b,  mtl_transactions_interface a  '||
            'where a.picking_line_id = b.picking_line_id  '||
            'and a.trx_source_line_id = b.trx_source_line_id  '||
            'and a.inventory_item_id = b.inventory_item_id  '||
            'and b.transaction_type_id = a.transaction_type_id  '||
            'and b.transaction_source_type_id in (2,8) '||
            'and b.picking_line_id is not null';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Transactions duplicate in MMT and MTI ');

   sqltxt :='select a.transaction_interface_id ,  '||
            'a.picking_line_id from  '||
            'mtl_material_transactions_temp b,  mtl_transactions_interface a  '||
            'where a.picking_line_id = b.picking_line_id  '||
            'and a.trx_source_line_id = b.trx_source_line_id  '||
            'and a.inventory_item_id = b.inventory_item_id  '||
            'and b.transaction_type_id = a.transaction_type_id  '||
            'and b.transaction_source_type_id in (2,8) '||
            'and b.picking_line_id is not null ';


   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Transactions duplicate in MMTT and MTI');

    sqltxt := 'select a.transaction_temp_id,  '||
              'a.picking_line_id from  '||
              'mtl_material_transactions b,  mtl_material_transactions_temp a  '||
              'where a.picking_line_id = b.picking_line_id  '||
              'and a.trx_source_line_id = b.trx_source_line_id  '||
              'and a.inventory_item_id = b.inventory_item_id  '||
              'and b.transaction_type_id = a.transaction_type_id  '||
              'and b.transaction_source_type_id in ( 2,8)  '||
              'and b.picking_line_id is not null';


   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Transactions duplicate in MMTT and MTT');

elsif l_script = 'transfer_txn' then
   sqltxt :='select a.transaction_id "Issue txn id" '||
            ', b.transaction_id "Receipt txn id" '||
            ', mp1.organization_code || '' ('' ||mp1.organization_id|| '')'' "Organization Code (Id)" '||
            ', mp2.organization_code || '' ('' ||mp2.organization_id|| '')'' "Transfer Org Code (Id)" '||
            ', mtt.transaction_type_name ||'' (''||a.transaction_type_id||'')'' "Txn Type (Id)" '||
            ',a.costed_flag "Costed flag" '||
            ',mif.item_number ||'' (''||a.inventory_item_id||'')'' "Item (Id)" '||
            '  from mtl_material_transactions a,mtl_material_transactions b , '||
            '  mtl_parameters mp1, '||
            '  mtl_parameters mp2, '||
            '  mtl_item_flexfields mif, '||
            '  mtl_transaction_types mtt '||
            '  WHERE '||
            '  a.inventory_item_id = mif.inventory_item_id(+) '||
            '  AND a.organization_id = mif.organization_id(+) '||
            '  AND a.organization_id = mp1.organization_id(+) '||
            '  AND b.organization_id = mp2.organization_id(+) '||
            '  AND a.transfer_transaction_id is null '||
            '  and a.transaction_id=b.transaction_id - 1 '||
            '  and a.inventory_item_id = b.inventory_item_id '||
            '  and a.transaction_action_id = b.transaction_action_id '||
            '  AND a.transaction_type_id = mtt.transaction_type_id (+) '||
            '  and a.transaction_quantity < 0 '||
            '  and a.transaction_action_id in (3,2,28)';

   if l_org_id is not null then
      sqltxt :=sqltxt||' and a.organization_id =  '||l_org_id;
   end if;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Transfer Transaction null');


end if;

statusStr := 'SUCCESS';
isFatal := 'FALSE';

 -- construct report
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Transaction Diagnostic Scripts ';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'Diagnostic Scripts for Transactions';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Transaction Diagnostic Scripts ';
END getTestName;

PROCEDURE getDependencies (package_names OUT NOCOPY JTF_DIAG_DEPENDTBL) IS
tempDependencies JTF_DIAG_DEPENDTBL;

BEGIN
    package_names := JTF_DIAGNOSTIC_ADAPTUTIL.initDependencyTable;
END getDependencies;

PROCEDURE isDependencyPipelined (str OUT NOCOPY VARCHAR2) IS
BEGIN
  str := 'FALSE';
END isDependencyPipelined;


PROCEDURE getOutputValues(outputValues OUT NOCOPY JTF_DIAG_OUTPUTTBL) IS
  tempOutput JTF_DIAG_OUTPUTTBL;
BEGIN
  tempOutput := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
  outputValues := tempOutput;
EXCEPTION
 when others then
 outputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
END getOutputValues;


PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
tempInput JTF_DIAG_INPUTTBL;
BEGIN
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
--tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'testout','');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'OrgId','LOV-oracle.apps.inv.diag.lov.OrganizationLov');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ScriptName','LOV-oracle.apps.inv.diag.lov.TxnDiagScriptsLov');
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;
END;

/
