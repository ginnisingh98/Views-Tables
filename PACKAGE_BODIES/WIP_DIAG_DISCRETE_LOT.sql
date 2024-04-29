--------------------------------------------------------
--  DDL for Package Body WIP_DIAG_DISCRETE_LOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DIAG_DISCRETE_LOT" as
/* $Header: WIPDJOBB.pls 120.0.12000000.1 2007/07/10 10:09:09 mraman noship $ */

PROCEDURE Uncosted_mat_txn_wdj ( p_org_id IN  NUMBER,
                                 report OUT NOCOPY JTF_DIAG_REPORT,
                                 reportClob OUT NOCOPY CLOB
                              ) IS

where_clause1 varchar2(999);
where_clause2 varchar2(999);
row_limit   NUMBER;
BEGIN

where_clause := null ;
row_limit := 1000;

if p_org_id is not null then
  where_clause  := ' and we.organization_id = ' || p_org_id || ' ';
  where_clause1 := ' and wdj.organization_id = ' || p_org_id || ' ';
  where_clause2 := ' and wrs.organization_id = ' || p_org_id || ' ';
  reportStr := '<U> Organization Id = ' || p_org_id || ' </U><BR>';
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
end if ;

sqltxt :=
'select transaction_source_id wip_entity_id, ' ||
'        decode(entity_type,1, ''1=Discrete Job'',' ||
'                           2, ''2=Repetitive Assly'',' ||
'                           3, ''3=Closed Discr Job'',' ||
'                           4, ''4=Flow Schedule'',' ||
'                           5, ''5=Lot Based Job'',' ||
'                           entity_type) entity_type,' ||
' mmt.organization_id, transaction_date, move_transaction_id, completion_transaction_id,' ||
' transaction_type_id,' ||
' decode(transaction_action_id,' ||
'  1, ''Issue'',' ||
'  2, ''Subinv Xfr'',' ||
'  3, ''Org Xfr'',' ||
'  4, ''Cycle Count Adj'',' ||
'  5, ''Issue'',' ||
'  21, ''Intransit Shpmt'',' ||
'  24, ''Cost Update'',' ||
'  27, ''Receipt'',' ||
'  28, ''Stg Xfr'',' ||
'  30, ''Wip scrap'',' ||
'  31, ''Assy Complete'',' ||
'  32, ''Assy return'',' ||
'  33, ''-ve CompIssue'',' ||
'  34, ''-ve CompReturn'',' ||
'  40, ''Inv Lot Split'',' ||
'  41, ''Inv Lot Merge'',' ||
'  42, ''Inv Lot Translate'',' ||
'  42, ''Inv Lot Translate'',' ||
'  transaction_action_id) txn_action_meaning' ||
' from   mtl_material_transactions mmt, ' ||
'       wip_entities we' ||
' where  mmt.transaction_source_type_id = 5' ||
' and    mmt.costed_flag = ''E''' ||
' and    mmt.error_code = ''CST_INVALID_JOB_DATE''' ||
' and    mmt.transaction_source_id = we.wip_entity_id' ||
' and    mmt.organization_id = we.organization_id' ||
  where_clause ||
' and    we.entity_type in (1,5)  ' ||
' union ' ||
'select mmt.transaction_source_id wip_entity_id , ' ||
'       ''1=Discrete Job'' entity_type ,' ||
' mmt.organization_id, transaction_date, move_transaction_id, completion_transaction_id,' ||
' transaction_type_id,' ||
' decode(transaction_action_id,' ||
'  1, ''Issue'',' ||
'  2, ''Subinv Xfr'',' ||
'  3, ''Org Xfr'',' ||
'  4, ''Cycle Count Adj'',' ||
'  5, ''Issue'',' ||
'  21, ''Intransit Shpmt'',' ||
'  24, ''Cost Update'',' ||
'  27, ''Receipt'',' ||
'  28, ''Stg Xfr'',' ||
'  30, ''Wip scrap'',' ||
'  31, ''Assy Complete'',' ||
'  32, ''Assy return'',' ||
'  33, ''-ve CompIssue'',' ||
'  34, ''-ve CompReturn'',' ||
'  40, ''Inv Lot Split'',' ||
'  41, ''Inv Lot Merge'',' ||
'  42, ''Inv Lot Translate'',' ||
'  42, ''Inv Lot Translate'',' ||
'  transaction_action_id) txn_action_meaning ' ||
' from   mtl_material_transactions mmt, ' ||
'       wip_discrete_jobs wdj' ||
' where  mmt.transaction_source_type_id = 5' ||
' and    mmt.costed_flag = ''N''' ||
' and    mmt.transaction_source_id = wdj.wip_entity_id' ||
' and    mmt.organization_id = wdj.organization_id' ||
where_clause1 ||
' and    mmt.transaction_date < wdj.date_released ' ||
' union ' ||
'select mmt.transaction_source_id wip_entity_id , ' ||
'       ''2=Repetitive Assly'' entity_type ,' ||
' mmt.organization_id, mmt.transaction_date, mmt.move_transaction_id, mmt.completion_transaction_id,' ||
' mmt.transaction_type_id,' ||
' decode(mmt.transaction_action_id,' ||
'  1, ''Issue'',' ||
'  2, ''Subinv Xfr'',' ||
'  3, ''Org Xfr'',' ||
'  4, ''Cycle Count Adj'',' ||
'  5, ''Issue'',' ||
'  21, ''Intransit Shpmt'',' ||
'  24, ''Cost Update'',' ||
'  27, ''Receipt'',' ||
'  28, ''Stg Xfr'',' ||
'  30, ''Wip scrap'',' ||
'  31, ''Assy Complete'',' ||
'  32, ''Assy return'',' ||
'  33, ''-ve CompIssue'',' ||
'  34, ''-ve CompReturn'',' ||
'  40, ''Inv Lot Split'',' ||
'  41, ''Inv Lot Merge'',' ||
'  42, ''Inv Lot Translate'',' ||
'  42, ''Inv Lot Translate'',' ||
'  mmt.transaction_action_id) txn_action_meaning ' ||
' from   mtl_material_transactions mmt, ' ||
'        mtl_material_txn_allocations mmta, ' ||
'       wip_repetitive_schedules wrs' ||
' where mmt.transaction_id = mmta.transaction_id ' ||
' and  mmt.transaction_source_type_id = 5' ||
' and    mmt.costed_flag = ''N''' ||
' and    mmt.transaction_source_id = wrs.wip_entity_id' ||
' and    mmta.repetitive_schedule_id = wrs.repetitive_schedule_id ' ||
' and    mmt.organization_id = wrs.organization_id' ||
where_clause2 ||
' and    mmt.transaction_date < wrs.date_released ' ||
' order by 1, 3 ' ;

dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
      ' Transactions where transaction_date is before the job release date ',true,null,'Y',row_limit) ;

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

if dummy_num > 0 then
   reportStr := 'The rows returned above indicates transaction date before Job/Schedule Release Date.' ;
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
   JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to metalink note ', 402202.1, ' to get the root-cause patch and steps to correct the data.<BR> <BR>') ;

/*
 if apps_ver = '11.5.10' then

   reportStr := '<BR> Action:' ;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);

   reportStr := '<BR> For Release 11.5.10 :' ;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);

   JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('<BR>Please refer to metalink note ', 402202.1, ' to get the root-cause patch and steps to correct the data.<BR> <BR>') ;

   --JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr) ;
-- JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);

 elsif apps_ver = '11.5.9' then

-- reportStr := '<BR> For Release 11.5.9 :' ;
-- JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
   reportStr := '<BR> Root cause patch not available. If issue can be reproduced at will, please log a service request againt WIP with steps to reproduce' ;
-- JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);

   reportStr := '<BR>Execute procedure WIP_WDJ_DFIX_UNCOSTED_MAT.update_mmt_for_jobs(organization_id, wip_entity_id) ' ;
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
--   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
  end if ;
**/

end if ;


sqltxt := '  SELECT ' ||
'                 WDJ.WIP_ENTITY_ID, ' ||
'                 WE.WIP_ENTITY_NAME,' ||
'  decode(we.entity_type, ' ||
'   1, ''Discrete Job'',' ||
'   2, ''Repetitive Schedule'',' ||
'   3, ''Closed Discrete Job'',' ||
'   4, ''Flow/Work Order-less'',' ||
'   5, ''Lot Based Job'',' ||
'   6, ''EAM Job'',' ||
'   we.entity_type) entity_type  ,                  ' ||
'                 WDJ.ORGANIZATION_ID, ' ||
'                 OAP.acct_period_id,' ||
'                 WDJ.DATE_RELEASED,' ||
'   WAC.CLASS_TYPE ' ||
'         FROM    WIP_ACCOUNTING_CLASSES WAC, ' ||
'                 ORG_ACCT_PERIODS OAP, ' ||
'                 WIP_DISCRETE_JOBS WDJ,' ||
'                 WIP_ENTITIES WE' ||
'         WHERE   WDJ.STATUS_TYPE IN (3, 4, 5, 6, 7, 14, 15) ' ||
'         AND     WE.ENTITY_TYPE IN (1,3,5) ' ||
'         AND     WAC.CLASS_CODE = WDJ.CLASS_CODE ' ||
'         AND     WDJ.ORGANIZATION_ID = WAC.ORGANIZATION_ID  ' ||
'         AND     OAP.ORGANIZATION_ID = WDJ.ORGANIZATION_ID ' ||
'         AND     WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID' ||
'         AND     WDJ.ORGANIZATION_ID = WE.ORGANIZATION_ID' ||
'         AND     OAP.OPEN_FLAG = ''Y'' ' ||
'         AND     OAP.PERIOD_CLOSE_DATE IS NULL ' ||
'         AND     OAP.SCHEDULE_CLOSE_DATE >= NVL(WDJ.DATE_RELEASED, WDJ.CREATION_DATE) ' ||
'         AND     WAC.CLASS_TYPE != 2 ' ||
  where_clause ||
'         AND     NOT EXISTS ' ||
'                 ( ' ||
'                 SELECT ''X'' FROM WIP_PERIOD_BALANCES WPB ' ||
'                 WHERE  WPB.REPETITIVE_SCHEDULE_ID IS NULL ' ||
'                        AND   WPB.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID ' ||
'                        AND   WPB.ORGANIZATION_ID = WDJ.ORGANIZATION_ID ' ||
'                        AND   WPB.ACCT_PERIOD_ID = OAP.ACCT_PERIOD_ID)' ||
' order  by we.wip_entity_name, we.organization_id' ;

dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
      ' Transactions erred due to missing record in WIP_PERIOD_BALANCES (error: CST_NO_BALANCE_ROW)',true,null,'Y',row_limit) ;

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

if dummy_num > 0 then
   reportStr := 'The rows returned above indicate record is missing in WIP_PERIOD_BALANCES.' ;
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
   JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to metalink note ', 402202.1, ' to get the root-cause patch and steps to correct the data.<BR> <BR>') ;

/*
   reportStr := '<BR> Action:' ;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);

   reportStr := reportStr || '<BR> 1.Execute procedure WIP_WDJ_DFIX_UNCOSTED_MAT.create_wpb(organization_id, wip_entity_id)';
--   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);

   reportStr := reportStr || '<BR> The values for the parameters can be obtained using the above output.' ;
--  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);

   reportStr := reportStr || '<BR> 2. Please log a service request with steps to reproduce if Client can reproduce issue at will.' ;
-- JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
*/


   sqltxt :=
'select   mmtt.transaction_header_id, ' ||
'         decode(mmtt.TRANSACTION_TYPE_ID,35,''Component Issue'',''Component Return'') Transaction, ' ||
'         substr(we.WIP_ENTITY_NAME,1,20) Job, ' ||
'     mmtt.transaction_source_id WIP_ENTITY_ID, ' ||
'        mmtt.inventory_item_id ITEM_ID, ' ||
'     substr(msi.segment1,1,20) COMPONENT, ' ||
'     mmtt.SUBINVENTORY_CODE SUBINVENTORY, ' ||
'         substr(mmtt.locator_segments,1,20) LOC_SEGMENTS, ' ||
'     mmtt.item_primary_uom_code UOM, ' ||
'         mmtt.number_of_lots_entered NO_LOTS_ENTERED, ' ||
'         mtlt.transaction_quantity MTLT_TRX_QUANTITY, ' ||
'         mtlt.primary_quantity MTLT_PRI_QUANTITY, ' ||
'         mtlt.lot_number MTLT_LOT_NUMBER, ' ||
'         mmtt.number_of_lots_entered - nvl(mmtt.transaction_quantity,0) QTY_TOBE_ADJUSTED ' ||
'  from ' ||
'        mtl_material_transactions_temp mmtt, ' ||
'        mtl_transaction_lots_temp mtlt, ' ||
'        mtl_system_items msi, ' ||
'  wip_entities we ' ||
' where ' ||
'     msi.inventory_item_id = mmtt.inventory_item_id ' ||
' AND mmtt.TRANSACTION_SOURCE_ID = we.wip_entity_id ' ||
' AND msi.ORGANIZATION_ID = mmtt.organization_id ' ||
  where_clause ||
' AND nvl(mmtt.TRANSACTION_QUANTITY,0)  < mmtt.number_of_lots_entered ' ||
' AND mmtt.TRANSACTION_SOURCE_TYPE_ID = 5 ' ||
' AND mmtt.TRANSACTION_ACTION_ID in (1,27) ' ||
' AND mmtt.TRANSACTION_TYPE_ID in (35,43,33,34) ' ||
' AND mmtt.number_of_lots_entered is NOT NULL ' ||
' AND (mmtt.move_transaction_id is NOT NULL or completion_transaction_id is NOT NULL) ' ||
' AND mmtt.PROCESS_FLAG = ''E'' ' ||
' AND mmtt.error_code = ''BF_LOT_ERROR'' ' ||
' AND mmtt.item_serial_controL_code = 1  -- not serial controled ' ||
' AND mmtt.transaction_temp_id = mtlt.transaction_temp_id(+) ' ||
' order by we.WIP_ENTITY_ID, mmtt.transaction_header_id, mmtt.transaction_temp_id ' ;

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

  dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql( sqltxt, 'Stuck Pending Material Transaction',true,null,'Y',row_limit) ;
  if dummy_num > 0 then
   reportStr := 'The rows returned above indicates Lots can''t be derived successfully.' ;
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
   JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to metalink note ', 402202.1, ' to get the root-cause patch and steps to correct the data.<BR> <BR>') ;
  end if ;


end if ;
END uncosted_mat_txn_wdj ;

procedure corrupt_osp_txn_wdj ( p_org_id IN  NUMBER,
                               report OUT NOCOPY JTF_DIAG_REPORT,
                               reportClob OUT NOCOPY CLOB
                              ) IS
l_len number ;
row_limit NUMBER;
BEGIN
where_clause := null ;
row_limit := 1000;

if p_org_id is not null then
  where_clause := ' and organization_id = ' || p_org_id || ' ';
  reportStr := '<U> Organization Id = ' || p_org_id || ' </U><BR>';
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
end if ;

sqltxt :=
'  SELECT TRANSACTION_ID,' ||
'   INTERFACE_TRANSACTION_ID,' ||
'   REQUEST_ID,' ||
'   PROGRAM_APPLICATION_ID,' ||
'   PROGRAM_ID,' ||
'   TRANSACTION_DATE,' ||
'   TRANSACTION_TYPE,' ||
'   QUANTITY,' ||
'   UNIT_OF_MEASURE,' ||
'   PO_HEADER_ID,' ||
'   WIP_ENTITY_ID,' ||
'   WIP_OPERATION_SEQ_NUM,' ||
'   ORGANIZATION_ID' ||
'  FROM RCV_TRANSACTIONS RT' ||
'  WHERE DESTINATION_TYPE_CODE = ''SHOP FLOOR''' ||
'   AND WIP_ENTITY_ID IS NOT NULL' ||
'   AND WIP_OPERATION_SEQ_NUM IS NOT NULL' ||
'   AND WIP_RESOURCE_SEQ_NUM IS NOT NULL' ||
    where_clause ||
'   AND EXISTS (SELECT 1 FROM WIP_TRANSACTIONS WT' ||
'          WHERE WT.RCV_TRANSACTION_ID = RT.TRANSACTION_ID' ||
'          AND WT.WIP_ENTITY_ID = RT.WIP_ENTITY_ID' ||
'          AND WT.OPERATION_SEQ_NUM = RT.WIP_OPERATION_SEQ_NUM' ||
'          AND WT.RESOURCE_SEQ_NUM = RT.WIP_RESOURCE_SEQ_NUM' ||
'                              AND WT.TRANSACTION_TYPE = 3' ||
'                              AND WT.PRIMARY_QUANTITY = 0' ||
'                              AND WT.ACTUAL_RESOURCE_RATE = 0 )' ||
'   AND NOT EXISTS (SELECT 1 FROM WIP_TRANSACTIONS WT' ||
'          WHERE WT.RCV_TRANSACTION_ID = RT.TRANSACTION_ID' ||
'          AND WT.WIP_ENTITY_ID = RT.WIP_ENTITY_ID' ||
'          AND WT.OPERATION_SEQ_NUM = RT.WIP_OPERATION_SEQ_NUM' ||
'          AND WT.RESOURCE_SEQ_NUM = RT.WIP_RESOURCE_SEQ_NUM' ||
'                              AND WT.TRANSACTION_TYPE = 3' ||
'                              AND WT.PRIMARY_QUANTITY <> 0' ||
'                              AND WT.ACTUAL_RESOURCE_RATE <> 0 )' ||
'                  AND EXISTS (SELECT 1 FROM WIP_DISCRETE_JOBS WDJ' ||
'                              WHERE WDJ.WIP_ENTITY_ID = RT.WIP_ENTITY_ID' ||
'                              AND WDJ.ORGANIZATION_ID = RT.ORGANIZATION_ID' ||
'                              AND WDJ.JOB_TYPE = 1' ||
'                              AND WDJ.STATUS_TYPE IN (3,4))' ||
'   AND NOT EXISTS (SELECT 1 FROM WIP_COST_TXN_INTERFACE WCTI' ||
'              WHERE WCTI.SOURCE_LINE_ID = RT.INTERFACE_TRANSACTION_ID ) '  ;

dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
      ' OSP receipts whose corresponding jobs were not charged',true,null,'Y',row_limit) ;

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

if dummy_num > 0 then
reportStr := 'The rows returned above indicate OSP Resource is not charged after items are delivered to ShopFloor.' ;
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
   JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please open a service request against Oracle Work in Process for the data-fix and root-cause, and upload the output of this diagnostic test.<BR><BR>');
end if ;

END corrupt_osp_txn_wdj  ;

procedure dup_mat_txn_wdj ( p_org_id IN  NUMBER,
                            report OUT NOCOPY JTF_DIAG_REPORT,
                            reportClob OUT NOCOPY CLOB
                          ) IS
row_limit NUMBER;
BEGIN
where_clause := null ;
row_limit := 1000;

if p_org_id is not null then
  where_clause := ' and organization_id = ' || p_org_id || ' ';
  reportStr := '<U> Organization Id = ' || p_org_id || ' </U><BR>';
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
end if ;

sqltxt :=
'SELECT organization_id, ' ||
'       transaction_source_id,' ||
'       transaction_type_id,' ||
'       inventory_item_id, ' ||
'       primary_quantity,' ||
'       subinventory_code,' ||
'       locator_id' ||
'       completion_transaction_id,' ||
'       Count(*) ' ||
' FROM mtl_material_transactions ' ||
' WHERE transaction_source_type_id = 5 ' ||
 where_clause ||
' AND   completion_transaction_id IS NOT null  ' ||
'HAVING Count(*) > 1 ' ||
'GROUP BY  organization_id, ' ||
'          transaction_source_id,' ||
'          transaction_type_id,' ||
'          inventory_item_id, ' ||
'          primary_quantity,' ||
'          subinventory_code,' ||
'          locator_id,' ||
'          completion_transaction_id ' ;

dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
      ' Duplicate material transactions in case of WIP completion ',true,null,'Y',row_limit) ;

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

if dummy_num > 0 then
   reportStr := 'The rows returned above indicates duplicate transactions.' ;
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
   JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please open a service request against Oracle Work in Process for the data-fix and root-cause, and upload the output of this diagnostic test.<BR><BR> ');
end if ;

sqltxt :=
'SELECT organization_id, ' ||
'       transaction_source_id,' ||
'       transaction_type_id,' ||
'       inventory_item_id, ' ||
'       primary_quantity,' ||
'       subinventory_code,' ||
'       locator_id,' ||
'       move_transaction_id,' ||
'       Count(*) ' ||
' FROM mtl_material_transactions ' ||
' WHERE transaction_source_type_id = 5 ' ||
' AND   completion_transaction_id IS NULL   ' ||
' AND   move_transaction_id IS NOT NULL ' ||
 where_clause ||
' HAVING Count(*) > 1 ' ||
' GROUP BY  organization_id, ' ||
'          transaction_source_id,' ||
'          transaction_type_id,' ||
'          inventory_item_id, ' ||
'          primary_quantity,' ||
'          subinventory_code,' ||
'          locator_id,' ||
'          move_transaction_id' ;
dummy_num := JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
      ' Duplicate backflush records for wip move transactions ',true,null,'Y',row_limit) ;

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

if dummy_num > 0 then
 reportStr := 'The rows returned above indicates duplicate backflush records originating from Move Transaction.' ;
   JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
   JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please open a service request against Oracle Work in Process for the data-fix and root-cause, and upload the output of this diagnostic test.<BR><BR>');
end if ;
END dup_mat_txn_wdj ;

BEGIN

 apps_ver := JTF_DIAGNOSTIC_COREAPI.Get_DB_Apps_Version ;

END WIP_DIAG_DISCRETE_LOT ;

/
