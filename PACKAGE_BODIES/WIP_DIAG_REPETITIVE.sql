--------------------------------------------------------
--  DDL for Package Body WIP_DIAG_REPETITIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DIAG_REPETITIVE" as
/* $Header: WIPDREPB.pls 120.0.12000000.1 2007/07/10 10:33:28 mraman noship $ */

PROCEDURE Uncosted_mat_txn_rep(inputs IN  JTF_DIAG_INPUTTBL,
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
 l_item_id   NUMBER;
 l_org_id    NUMBER;
 we_dyn_where_clause VARCHAR2(1000):= null;
BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
row_limit := 1000;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrganizationId',inputs);

if (l_org_id IS NOT NULL) then
   reportStr := '<U> Input Parameters : </U><BR>';
   reportStr := reportStr || 'Organization Id = ' || l_org_id || ' <BR>';
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
end if;

if (l_org_id IS NOT NULL) then
  we_dyn_where_clause := 'AND we.organization_id = '|| l_org_id  || ' ';
end if;

sqltxt :=
'SELECT we.wip_entity_name Repetitive_Assembly,  '||
'       wl.line_code Repetitive_Line, '||
'       mmt.organization_id, '||
'       mmta.repetitive_schedule_id, '||
'       mmt.transaction_id, '||
'       mmt.transaction_source_id, '||
'       mmt.completion_transaction_id, '||
'       mmt.move_transaction_id, '||
'       mmt.costed_flag, '||
'       decode(mmt.transaction_action_id, '||
'             1, ''Issue'', '||
'            27, ''Receipt'', '||
'            30, ''Wip scrap'', '||
'            31, ''Assy Complete'', '||
'            32, ''Assy return'', '||
'            33, ''-ve CompIssue'', '||
'            34, ''-ve CompReturn'', '||
'            40, ''Inv Lot Split'', '||
'            41, ''Inv Lot Merge'', '||
'            42, ''Inv Lot Translate'', '||
'            42, ''Inv Lot Translate'', '||
'            mmt.transaction_action_id) txn_action_meaning, '||
'       mmt.error_code, '||
'       SubStrB(mmt.error_explanation, 1, 50) err_explain '||
'FROM   mtl_material_transactions mmt,  '||
'       wip_entities we, wip_lines wl, '||
'       mtl_material_txn_allocations mmta '||
'WHERE  mmt.transaction_source_type_id = 5 '||
'AND    mmt.costed_flag IN (''N'',''E'') '||
'AND    mmt.transaction_source_id = we.wip_entity_id '||
'AND    mmt.organization_id = we.organization_id '||
'AND    we.entity_type = 2 '||we_dyn_where_clause||
'AND    mmt.transaction_id = mmta.transaction_id '||
'AND    mmt.organization_id = mmta.organization_id '||
'AND    mmt.repetitive_line_id = wl.line_id '||
'AND    mmt.organization_id = wl.organization_id '||
'AND    NOT EXISTS '||
'       (SELECT ''x'' FROM wip_period_balances wpb '||
'        WHERE  WPB.WIP_ENTITY_ID = MMT.TRANSACTION_SOURCE_ID '||
'        AND    WPB.REPETITIVE_SCHEDULE_ID = MMTA.REPETITIVE_SCHEDULE_ID '||
'        AND    WPB.ORGANIZATION_ID = MMT.ORGANIZATION_ID '||
'        AND    WPB.ACCT_PERIOD_ID = mmt.ACCT_PERIOD_ID) '||
'ORDER BY mmt.organization_id, we.wip_entity_name, mmt.transaction_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Transactions that erred due to missing record in WIP_PERIOD_BALANCES for Repetitive Schedule. (CST_NO_BALANCE_ROW)',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
  reportStr := 'The rows returned above signify data-inconsistency in material transactions related to repetitive schedules. These are erred transactions due to missing record in WIP_PERIOD_BALANCES.';
  JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
  JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';

sqltxt :=
'SELECT we.wip_entity_name Repetitive_Assembly,  '||
'       wl.line_code Repetitive_Line, '||
'       mmt.organization_id, '||
'       mmt.transaction_id, '||
'       mmt.transaction_source_id, '||
'       mmt.completion_transaction_id, ' ||
'       mmt.move_transaction_id, ' ||
'       mmt.organization_id, ' ||
'       mmt.costed_flag, ' ||
'       decode(mmt.transaction_action_id, ' ||
'                  1, ''Issue'', ' ||
'                  27, ''Receipt'', ' ||
'            30, ''Wip scrap'', ' ||
'            31, ''Assy Complete'', ' ||
'            32, ''Assy return'', ' ||
'            33, ''-ve CompIssue'', ' ||
'            34, ''-ve CompReturn'', ' ||
'            40, ''Inv Lot Split'', ' ||
'            41, ''Inv Lot Merge'', ' ||
'            42, ''Inv Lot Translate'', ' ||
'            42, ''Inv Lot Translate'', ' ||
'             mmt.transaction_action_id) txn_action_meaning, ' ||
'       mmt.error_code, ' ||
'       SubStrB(mmt.error_explanation, 1, 50) err_explain ' ||
'FROM   mtl_material_transactions mmt,  ' ||
'       wip_entities we, ' ||
'       wip_lines wl '||
'WHERE  mmt.transaction_action_id IN (1, 27, 33, 34) ' ||
'AND    mmt.transaction_source_type_id = 5 ' ||
'AND    mmt.costed_flag IN (''N'',''E'') ' ||
'AND    mmt.completion_transaction_id IS NULL  ' ||
'AND    mmt.move_transaction_id IS NULL  ' ||
'AND    mmt.transaction_source_id = we.wip_entity_id ' ||
'AND    mmt.organization_id = we.organization_id ' ||
'AND    we.entity_type = 2 ' ||we_dyn_where_clause||
'AND    mmt.repetitive_line_id = wl.line_id '||
'AND    we.organization_id = wl.organization_id '||
'AND    NOT EXISTS (SELECT 1 ' ||
'                   FROM   mtl_material_txn_allocations mmta ' ||
'                   WHERE  mmta.transaction_id = mmt.transaction_id ' ||
'                   AND    mmta.organization_id = mmt.organization_id) '||
'ORDER BY mmt.organization_id, we.wip_entity_name, mmt.transaction_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Missing Allocations for Repetitive Schedule Transactions resulted from Manual Transaction or Component Pick Release process.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit ||' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
  reportStr := 'The rows returned above signify data-inconsistency in material transactions related to repetitive schedules. ' ||
               'These are transactions resulted from Manual Transaction or Component Pick Release process, in error due to missing repetitive schedule allocations.';
  JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
  JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';

sqltxt :=
'SELECT we.wip_entity_name Repetitive_Assembly,  '||
'       wl.line_code Repetitive_Line, '||
'       mmt.organization_id, '||
'       mmt.transaction_id, '||
'       mmt.transaction_source_id, '||
'       mmt.completion_transaction_id, ' ||
'       mmt.move_transaction_id, ' ||
'       mmt.organization_id, ' ||
'       mmt.costed_flag, ' ||
'       decode(mmt.transaction_action_id, ' ||
'                  1, ''Issue'', ' ||
'                  27, ''Receipt'', ' ||
'                30, ''Wip scrap'', ' ||
'                31, ''Assy Complete'', ' ||
'                32, ''Assy return'', ' ||
'                33, ''-ve CompIssue'', ' ||
'                34, ''-ve CompReturn'', ' ||
'                40, ''Inv Lot Split'', ' ||
'                41, ''Inv Lot Merge'', ' ||
'                42, ''Inv Lot Translate'', ' ||
'                42, ''Inv Lot Translate'', ' ||
'             mmt.transaction_action_id) txn_action_meaning, ' ||
'       mmt.error_code, ' ||
'       SubStrB(mmt.error_explanation, 1, 50) err_explain ' ||
'FROM   mtl_material_transactions mmt,  ' ||
'       wip_entities we, ' ||
'       wip_lines wl ' ||
'WHERE  mmt.transaction_action_id IN (1, 27, 33, 34) ' ||
'AND    mmt.transaction_source_type_id = 5 ' ||
'AND    mmt.costed_flag IN (''N'',''E'')   ' ||
'AND    mmt.move_transaction_id IS NOT NULL  ' ||
'AND    mmt.transaction_source_id = we.wip_entity_id ' ||
'AND    mmt.organization_id = we.organization_id ' ||
'AND    we.entity_type = 2 ' ||we_dyn_where_clause||
'AND    mmt.repetitive_line_id = wl.line_id '||
'AND    mmt.organization_id = wl.organization_id '||
'AND    NOT EXISTS (SELECT 1 ' ||
'                   FROM   mtl_material_txn_allocations mmta ' ||
'                   WHERE  mmta.transaction_id = mmt.transaction_id ' ||
'                   AND    mmta.organization_id = mmt.organization_id) '||
'ORDER BY mmt.organization_id, we.wip_entity_name, mmt.transaction_id';


dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
       'Missing Allocations for Repetitive Schedule Transactions resulted from Move Transactions.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit ||' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
  reportStr := 'The rows returned above signify data-inconsistency in material transactions related to repetitive schedules. ' ||
               'These are transactions resulted from Move Transactions, in error due to missing repetitive schedule allocations.';
  JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
  JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';

sqltxt :=
'SELECT we.wip_entity_name Repetitive_Assembly,  '||
'       wl.line_code Repetitive_Line, '||
'       mmt.organization_id, '||
'       mmt.transaction_id, '||
'       mmt.transaction_source_id, '||
'       mmt.completion_transaction_id, ' ||
'       mmt.move_transaction_id, ' ||
'       mmt.organization_id, ' ||
'       mmt.costed_flag, ' ||
'       decode(mmt.transaction_action_id, ' ||
'                  1, ''Issue'', ' ||
'                  27, ''Receipt'', ' ||
'                30, ''Wip scrap'', ' ||
'                31, ''Assy Complete'', ' ||
'                32, ''Assy return'', ' ||
'                33, ''-ve CompIssue'', ' ||
'                34, ''-ve CompReturn'', ' ||
'                40, ''Inv Lot Split'', ' ||
'                41, ''Inv Lot Merge'', ' ||
'                42, ''Inv Lot Translate'', ' ||
'                42, ''Inv Lot Translate'', ' ||
'             mmt.transaction_action_id) txn_action_meaning, ' ||
'       mmt.error_code, ' ||
'       SubStrB(mmt.error_explanation, 1, 50) err_explain ' ||
'FROM   mtl_material_transactions mmt,  ' ||
'       wip_entities we, ' ||
'       wip_lines wl '||
'WHERE  mmt.transaction_action_id IN (1, 27, 33, 34) ' ||
'AND    mmt.transaction_source_type_id = 5 ' ||
'AND    mmt.costed_flag IN (''N'',''E'')   ' ||
'AND    mmt.move_transaction_id IS NULL  ' ||
'AND    mmt.completion_transaction_id IS NOT NULL ' ||
'AND    mmt.transaction_source_id = we.wip_entity_id ' ||
'AND    mmt.organization_id = we.organization_id ' ||
'AND    we.entity_type = 2 ' ||we_dyn_where_clause||
'AND    mmt.repetitive_line_id = wl.line_id '||
'AND    mmt.organization_id = wl.organization_id '||
'AND    NOT EXISTS (SELECT 1 ' ||
'                   FROM   mtl_material_txn_allocations mmta ' ||
'                   WHERE  mmta.transaction_id = mmt.transaction_id ' ||
'                   AND    mmta.organization_id = mmt.organization_id) '||
'ORDER BY mmt.organization_id, we.wip_entity_name, mmt.transaction_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
        'Missing Allocations for Repetitive Schedule Transactions resulted from Completion / Return / Scrap / Return From Scrap Transactions.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit ||' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
  reportStr := 'The rows returned above signify data-inconsistency in material transactions related to repetitive schedules. '||
               'These are transactions resulted from Completion / Return / Scrap / Return from Scrap Transactions, in error due to missing repetitive schedule allocations.';
  JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
  JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';

sqltxt :=
'SELECT we.wip_entity_name Repetitive_Assembly,  '||
'       wl.line_code Repetitive_Line, '||
'       mmt.organization_id, '||
'       mmta.repetitive_schedule_id, '||
'       mmt.transaction_id, '||
'       mmt.transaction_source_id, '||
'       mmt.completion_transaction_id, ' ||
'       mmt.move_transaction_id, ' ||
'       mmt.organization_id, ' ||
'       mmt.costed_flag, ' ||
'       decode(mmt.transaction_action_id, ' ||
'                  1, ''Issue'', ' ||
'                  27, ''Receipt'', ' ||
'                30, ''Wip scrap'', ' ||
'                31, ''Assy Complete'', ' ||
'                32, ''Assy return'', ' ||
'                33, ''-ve CompIssue'', ' ||
'                34, ''-ve CompReturn'', ' ||
'                40, ''Inv Lot Split'', ' ||
'                41, ''Inv Lot Merge'', ' ||
'                42, ''Inv Lot Translate'', ' ||
'                42, ''Inv Lot Translate'', ' ||
'             mmt.transaction_action_id) txn_action_meaning, ' ||
'       mmt.error_code, ' ||
'       SubStrB(mmt.error_explanation, 1, 50) err_explain ' ||
'FROM   mtl_material_transactions mmt,  ' ||
'       mtl_material_txn_allocations mmta, ' ||
'       wip_entities we, wip_lines wl ' ||
'WHERE  mmt.transaction_action_id IN (1, 27, 33, 34) ' ||
'AND    mmt.transaction_source_type_id = 5 ' ||
'AND    mmt.costed_flag IN (''N'',''E'')   ' ||
'AND    mmt.move_transaction_id IS NOT NULL  ' ||
'AND    mmt.transaction_id = mmta.transaction_id ' ||
'AND    mmt.organization_id = mmta.organization_id ' ||
'AND    mmt.transaction_source_id = we.wip_entity_id '||
'AND    mmt.organization_id = we.organization_id '||
'AND    we.entity_type = 2 '||we_dyn_where_clause||
'AND    mmt.repetitive_line_id = wl.line_id '||
'AND    mmt.organization_id = wl.organization_id '||
'AND    NOT EXISTS (SELECT 1 ' ||
'                   FROM   wip_move_txn_allocations wmta ' ||
'                   WHERE  wmta.transaction_id = mmt.move_transaction_id ' ||
'                   AND    wmta.organization_id = mmt.organization_id ' ||
'                   AND    wmta.repetitive_schedule_id = mmta.repetitive_schedule_id) '||
'ORDER BY mmt.organization_id, we.wip_entity_name, mmt.transaction_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Incorrect WIP Material Allocations for Repetitive Schedule Transactions resulted from Move Transactions.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit ||' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
  reportStr := 'The rows returned above signify data-inconsistency in material transactions related to repetitive schedules. '||
               'These are transactions resulted from Move Transactions, in error due to incorrect repetitive schedule allocations.';
  JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
  JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';

sqltxt :=
'SELECT we.wip_entity_name Repetitive_Assembly,  '||
'       wl.line_code Repetitive_Line, '||
'       mmt.organization_id, '||
'       mmta.repetitive_schedule_id, '||
'       mmt.transaction_id, '||
'       mmt.transaction_source_id, '||
'       mmt.completion_transaction_id, ' ||
'       mmt.move_transaction_id, ' ||
'       mmt.organization_id, ' ||
'       mmt.costed_flag, ' ||
'       decode(mmt.transaction_action_id, ' ||
'                  1, ''Issue'', ' ||
'                  27, ''Receipt'', ' ||
'                30, ''Wip scrap'', ' ||
'                31, ''Assy Complete'', ' ||
'                32, ''Assy return'', ' ||
'                33, ''-ve CompIssue'', ' ||
'                34, ''-ve CompReturn'', ' ||
'                40, ''Inv Lot Split'', ' ||
'                41, ''Inv Lot Merge'', ' ||
'                42, ''Inv Lot Translate'', ' ||
'                42, ''Inv Lot Translate'', ' ||
'             mmt.transaction_action_id) txn_action_meaning, ' ||
'       mmt.error_code, ' ||
'       SubStrB(mmt.error_explanation, 1, 50) err_explain ' ||
'FROM   mtl_material_transactions mmt,  ' ||
'       mtl_material_txn_allocations mmta, ' ||
'       wip_entities we, wip_lines wl '||
'WHERE  mmt.transaction_action_id IN (1, 27, 33, 34) ' ||
'AND    mmt.transaction_source_type_id = 5 ' ||
'AND    mmt.costed_flag IN (''N'',''E'')   ' ||
'AND    mmt.move_transaction_id IS NULL  ' ||
'AND    mmt.completion_transaction_id IS NOT NULL  ' ||
'AND    mmt.transaction_id = mmta.transaction_id ' ||
'AND    mmt.organization_id = mmta.organization_id ' ||
'AND    mmt.transaction_source_id = we.wip_entity_id '||
'AND    mmt.organization_id = we.organization_id '||
'AND    we.entity_type = 2 '||we_dyn_where_clause||
'AND    mmt.repetitive_line_id = wl.line_id '||
'AND    mmt.organization_id = wl.organization_id '||
'AND    NOT EXISTS (SELECT 1 ' ||
'                   FROM   mtl_material_transactions mmt1, ' ||
'                          mtl_material_txn_allocations mmta1 ' ||
'                   WHERE  mmt1.transaction_action_id NOT IN (1, 27, 33, 34) ' ||
'                   AND    mmt1.transaction_source_type_id = 5 ' ||
'                   AND    mmt1.transaction_source_id = mmt.transaction_source_id ' ||
'                   AND    mmt1.organization_id = mmt.organization_id ' ||
'                   AND    mmt1.completion_transaction_id = mmt.completion_transaction_id ' ||
'                   AND    mmt1.transaction_id = mmta1.transaction_id ' ||
'                   AND    mmt1.organization_id = mmt1.organization_id ' ||
'                   AND    mmta1.repetitive_schedule_id = mmta.repetitive_schedule_id) '||
'ORDER BY mmt.organization_id, we.wip_entity_name, mmt.transaction_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
        'Incorrect WIP Allocations for Repetitive Schedule Transactions resulted from Completion / Return / Scrap / Return From Scrap Transactions.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit ||' rows to prevent an excessively large output file. <BR>');
END IF;

IF (dummy_num > 0) THEN
  reportStr := 'The rows returned above signify data-inconsistency in material transactions related to repetitive schedules. '||
               'These are transactions resulted from Completion / Return / Scrap / Return from Scrap Transactions, in error due to incorrect repetitive schedule allocations.';
  JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
  JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');
END IF;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';

 <<l_test_end>>
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END Uncosted_mat_txn_rep;

END;

/
