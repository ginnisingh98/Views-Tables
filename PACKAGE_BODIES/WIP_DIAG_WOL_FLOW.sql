--------------------------------------------------------
--  DDL for Package Body WIP_DIAG_WOL_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DIAG_WOL_FLOW" as
/* $Header: WIPDWOLB.pls 120.0.12000000.1 2007/07/10 11:08:37 mraman noship $ */

PROCEDURE Uncosted_mat_txn_wol(inputs IN  JTF_DIAG_INPUTTBL,
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
 l_org_id    NUMBER;
 where_clause VARCHAR2(4000) := NULL; -- where clause
BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
row_limit := 1000;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrganizationId',inputs);

If l_org_id is not null then
   where_clause := ' and organization_id = ' || l_org_id || ' ';
   reportStr := ' Organization Id = ' || l_org_id || ' <BR>';
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
end if;
sqltxt :=
'select '||
'       mmt1.transaction_source_id, '||
'       mmt1.transaction_id, '||
'       mmt1.organization_id, '||
'       mmt1.completion_transaction_id, '||
'       mmt1.move_transaction_id, '||
'       nvl(mmt1.costed_flag, ''Y'') costed_flag, '||
'       decode(mmt1.transaction_action_id, '||
'  1, ''Issue'', '||
'  2, ''Subinv Xfr'', '||
'  3, ''Org Xfr'', '||
'  4, ''Cycle Count Adj'', '||
'  5, ''Plan Xfr'', '||
'  21, ''Intransit Shpmt'', '||
'  24, ''Cost Update'', '||
'  27, ''Receipt'', '||
'  28, ''Stg Xfr'', '||
'  30, ''Wip scrap'', '||
'  31, ''Assy Complete'', '||
'  32, ''Assy return'', '||
'  33, ''-ve CompIssue'', '||
'  34, ''-ve CompReturn'', '||
'  40, ''Inv Lot Split'', '||
'  41, ''Inv Lot Merge'', '||
'  42, ''Inv Lot Translate'', '||
'  42, ''Inv Lot Translate'', '||
'  transaction_action_id) txn_action_meaning, '||
'       mmt1.error_code, '||
'       substrb(mmt1.error_explanation,1,50) err_explain '||
' from   mtl_material_transactions mmt1 '||
' where  mmt1.transaction_action_id in (1, 27, 33, 34) '||
' and    mmt1.transaction_source_type_id = 5 '||
' and    mmt1.flow_schedule = ''Y'' '||
' and    mmt1.costed_flag  = ''E'' '||
' and    mmt1.completion_transaction_id is not null '||
' and    mmt1.transaction_source_id is not null '||
  where_clause ||
' and    exists (select 1 '||
'                from   mtl_material_transactions mmt2 '||
'                where  mmt2.transaction_action_id in (30, 31, 32) '||
'                and    mmt2.transaction_source_type_id = 5 '||
'                and    mmt2.completion_transaction_id = '||
'                            mmt1.completion_transaction_id '||
'                and    mmt2.flow_schedule = ''Y'' '||
'                and    mmt2.costed_flag in (''N'', ''E'') '||
                        where_clause ||
'               ) '||
' and    exists (select 1 '||
'    from   wip_flow_schedules wfs '||
'  where  wfs.wip_entity_id = mmt1.transaction_source_id '||
'  and    wfs.organization_id = mmt1.organization_id) '||
' order by transaction_source_id, transaction_action_id';


dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Component transaction(s) in MMT erred during costing with Parent transaction either' ||
		' not costed or erred in MMT (error: CST_INVALID_WIP).',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

If ( dummy_num > 0) then

reportStr := 'The rows returned above signify data inconsistency in component transaction(s).' ||
' These are component transactions in MMT for Work Order-less / Flow for which the parent assembly' ||
' transaction is either not costed or erred.';
JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');

end if;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';


sqltxt :=
'select '||
'       mmt1.transaction_source_id, '||
'       mmt1.transaction_id, '||
'       mmt1.organization_id, '||
'       mmt1.completion_transaction_id, '||
'       mmt1.move_transaction_id, '||
'       nvl(mmt1.costed_flag, ''Y'') costed_flag, '||
'       decode(mmt1.transaction_action_id, '||
'  1, ''Issue'', '||
'  2, ''Subinv Xfr'', '||
'  3, ''Org Xfr'', '||
'  4, ''Cycle Count Adj'', '||
'  5, ''Plan Xfr'', '||
'  21, ''Intransit Shpmt'', '||
'  24, ''Cost Update'', '||
'  27, ''Receipt'', '||
'  28, ''Stg Xfr'', '||
'  30, ''Wip scrap'', '||
'  31, ''Assy Complete'', '||
'  32, ''Assy return'', '||
'  33, ''-ve CompIssue'', '||
'  34, ''-ve CompReturn'', '||
'  40, ''Inv Lot Split'', '||
'  41, ''Inv Lot Merge'', '||
'  42, ''Inv Lot Translate'', '||
'  42, ''Inv Lot Translate'', '||
'  transaction_action_id) txn_action_meaning, '||
'       mmt1.error_code, '||
'       substrb(mmt1.error_explanation,1,50) err_explain '||
' from   mtl_material_transactions mmt1 '||
' where  mmt1.transaction_action_id in (1, 27, 33, 34) '||
' and    mmt1.transaction_source_type_id = 5 '||
' and    mmt1.flow_schedule = ''Y'' '||
' and    mmt1.costed_flag = ''E'' '||
' and    mmt1.completion_transaction_id is not null '||
' and    mmt1.transaction_source_id is not null '||
  where_clause ||
' and    not exists (select 1 '||
'                    from   mtl_material_transactions mmt2 '||
'                    where  mmt2.transaction_action_id in (30, 31, 32) '||
'                    and    mmt2.transaction_source_type_id = 5 '||
'                    and    mmt2.completion_transaction_id = '||
'                           mmt1.completion_transaction_id '||
'                    and    mmt2.flow_schedule = ''Y'' '||
                     where_clause ||
'               ) '||
' order by transaction_source_id, transaction_action_id';


dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Component transaction(s) in MMT erred during costing with missing Parent transaction in MMT (error: CST_INVALID_WIP).',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

If ( dummy_num > 0) then

reportStr := 'The rows returned above signify data inconsistency among component transaction(s). These are component transactions' || ' in MMT for Work Order-less / Flow transactions for which the parent assembly transaction is missing in MMT.';
JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');

end if;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';

sqltxt :=
'select mmt.transaction_source_id, '||
'       mmt.transaction_id, '||
'       mmt.organization_id, '||
'       mmt.completion_transaction_id, '||
'       mmt.move_transaction_id, '||
'       nvl(mmt.costed_flag, ''Y''), '||
'       decode(mmt.transaction_action_id, '||
'  1, ''Issue'', '||
'  2, ''Subinv Xfr'', '||
'  3, ''Org Xfr'', '||
'  4, ''Cycle Count Adj'', '||
'  5, ''Plan Xfr'', '||
'  21, ''Intransit Shpmt'', '||
'  24, ''Cost Update'', '||
'  27, ''Receipt'', '||
'  28, ''Stg Xfr'', '||
'  30, ''Wip scrap'', '||
'  31, ''Assy Complete'', '||
'  32, ''Assy return'', '||
'  33, ''-ve CompIssue'', '||
'  34, ''-ve CompReturn'', '||
'  40, ''Inv Lot Split'', '||
'  41, ''Inv Lot Merge'', '||
'  42, ''Inv Lot Translate'', '||
'  42, ''Inv Lot Translate'', '||
'  transaction_action_id) txn_action_meaning, '||
'       mmt.error_code, '||
'       mmt.error_explanation '||
'from   mtl_material_transactions mmt '||
'where  mmt.transaction_action_id not in (30, 31, 32)  /* All Non parent transactions */ '||
'and    mmt.transaction_source_type_id = 5 /* WIP */'||
'and    mmt.flow_schedule = ''Y'' '||
'and    mmt.costed_flag  in (''N'', ''E'') '||
 where_clause ||
'and    exists ( select 1 '||
'                         from   mtl_material_transactions mmt1 '||
'                         where  mmt1.transaction_action_id in (30, 31, 32)  '||
'                                                   /* Parent Transactions */ '||
'                         and    mmt1.transaction_source_type_id = 5 /* WIP */ '||
'                         and    mmt1.flow_schedule = ''Y'' '||
'                         and    mmt1.costed_flag is null /* Parent is costed */ '||
'                         and    mmt1.completion_transaction_id = '||
'                                       mmt.completion_transaction_id        '||
                          where_clause ||
'                        ) '||
'order by transaction_source_id, transaction_action_id';


dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Component transaction(s) in MMT Uncosted/erred during costing with costed Parent transaction in MMT (error: CST_INVALID_WIP).',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

If ( dummy_num > 0) then

reportStr := 'The rows returned above signify data inconsistency among component transaction(s). These are component transactions' || ' in MMT for Work Order-less / Flow transactions for which the parent assembly transaction is costed.';
JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');

end if;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';

sqltxt :=
' select '||
'       mmt.transaction_source_id, '||
'       mmt.transaction_id, '||
'       mmt.organization_id, '||
'       mmt.completion_transaction_id, '||
'       mmt.move_transaction_id, '||
'       nvl(mmt.costed_flag, ''Y'') costed_flag, '||
'       decode(mmt.transaction_action_id, '||
'  1, ''Issue'', '||
'  2, ''Subinv Xfr'', '||
'  3, ''Org Xfr'', '||
'  4, ''Cycle Count Adj'', '||
'  5, ''Plan Xfr'', '||
'  21, ''Intransit Shpmt'', '||
'  24, ''Cost Update'', '||
'  27, ''Receipt'', '||
'  28, ''Stg Xfr'', '||
'  30, ''Wip scrap'', '||
'  31, ''Assy Complete'', '||
'  32, ''Assy return'', '||
'  33, ''-ve CompIssue'', '||
'  34, ''-ve CompReturn'', '||
'  40, ''Inv Lot Split'', '||
'  41, ''Inv Lot Merge'', '||
'  42, ''Inv Lot Translate'', '||
'  42, ''Inv Lot Translate'', '||
'  transaction_action_id) txn_action_meaning, '||
'       mmt.error_code, '||
'       substrb(mmt.error_explanation,1,50) err_explain '||
' from   mtl_material_transactions mmt '||
' where  mmt.transaction_action_id in (1,27,33,34,30,31,32) '||
' and    mmt.transaction_type_id in (17,35, 43,44,90,38,48) '||
' and    mmt.transaction_source_type_id = 5 '||
' and    mmt.flow_schedule = ''Y'' '||
' and    mmt.costed_flag  in (''N'', ''E'') '||
' and    mmt.transaction_source_id is not null '||
  where_clause ||
' and    not exists (select 1 '||
'                from   wip_flow_schedules wfs '||
'                where  wfs.wip_entity_id = mmt.transaction_source_id '||
'  and    wfs.organization_id = mmt.organization_id '||
'               ) '||
' order by transaction_source_id, transaction_action_id';


dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Transaction(s) in MMT Uncosted/erred during costing with missing flow schedule (error: CST_INVALID_WIP).',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

If ( dummy_num > 0) then

reportStr := 'The rows returned above signify data inconsistency among MMT transaction(s) for Work Order-less / Flow' ||
' transactions. These are transactions in MMT for Work Order-less / Flow transactions for which the flow schedule is missing.';
JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');

end if;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';


sqltxt :=
'  select '||
'        mmt.transaction_source_id, '||
'        mmt.transaction_id, '||
'        mmt.organization_id, '||
'        mmt.completion_transaction_id, '||
'        mmt.move_transaction_id, '||
'        nvl(mmt.costed_flag, ''Y'') costed_flag, '||
'        decode(mmt.transaction_action_id, '||
'                 1, ''Issue'', '||
'                 2, ''Subinv Xfr'', '||
'                 3, ''Org Xfr'', '||
'                 4, ''Cycle Count Adj'', '||
'                 5, ''Plan Xfr'', '||
'                 21, ''Intransit Shpmt'', '||
'                 24, ''Cost Update'', '||
'                 27, ''Receipt'', '||
'                 28, ''Stg Xfr'', '||
'                 30, ''Wip scrap'', '||
'                 31, ''Assy Complete'', '||
'                 32, ''Assy return'', '||
'                 33, ''-ve CompIssue'', '||
'                 34, ''-ve CompReturn'', '||
'                 40, ''Inv Lot Split'', '||
'                 41, ''Inv Lot Merge'', '||
'                 42, ''Inv Lot Translate'', '||
'                 42, ''Inv Lot Translate'', '||
'                       transaction_action_id) txn_action_meaning, '||
'        mmt.error_code, '||
'        substrb(mmt.error_explanation,1,50) err_explain '||
'  from   mtl_material_transactions mmt '||
'  where  mmt.transaction_action_id in (1, 27, 33, 34) '||
'    and  mmt.transaction_source_type_id = 5 '||
'    and  mmt.flow_schedule = ''Y'' '||
'    and  mmt.costed_flag  in (''N'', ''E'') '||
'    and  mmt.transaction_source_id is not NULL '||
'    and  mmt.completion_transaction_id is not null '||
     where_clause ||
'    and  exists (select 1 '||
'                   from   mtl_material_transactions mmt1 '||
'                  WHERE   mmt1.transaction_action_id in (30, 31, 32) '||
'                    and   mmt1.transaction_source_type_id = 5 '||
'                    and   mmt1.completion_transaction_id = mmt.completion_transaction_id '||
'                    and   mmt1.flow_schedule = ''Y'' '||
'                    and   mmt1.transaction_source_id <> mmt.transaction_source_id '||
'                ) '||
'  order by transaction_source_id, transaction_action_id ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Component transaction(s) in MMT erred during costing due to backflush against an incorrect flow schedule with Parent transaction either not costed or erred in MMT (error: CST_INVALID_WIP).',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

If ( dummy_num > 0) then

reportStr := 'The rows returned above signify data inconsistency among MMT component transaction(s) for'||
' Work Order-less / Flow transactions. These are component transactions in MMT' ||
' for Work Order-less / Flow transactions with incorrect transaction_source_id.';
JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');

end if;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';
 <<l_test_end>>
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END Uncosted_mat_txn_wol;

PROCEDURE Pending_res_txn_wol(inputs IN  JTF_DIAG_INPUTTBL,
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
 l_org_id    NUMBER;
 where_clause VARCHAR2(4000) := NULL; -- where clause
BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrganizationId',inputs);

If l_org_id is not null then
   where_clause := ' and organization_id = ' || l_org_id || ' ';
   reportStr := ' Organization Id = ' || l_org_id || ' <BR>';
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
end if;

sqltxt :=
'select wip_entity_id, '||
'       decode(to_char(completion_transaction_id), null, ''?'', '''') miss_comp, '||
'       organization_id '||
'       transaction_id, '||
'       completion_transaction_id,  '||
'       process_status '||
'from   wip_cost_txn_interface '||
'where  wip_entity_id in  '||
'  (select mmt1.transaction_source_id '||
'  from   mtl_material_transactions mmt1 '||
'  where  mmt1.transaction_source_type_id = 5 /* WIP */'||
'  and    mmt1.flow_schedule = ''Y'' '||
'  and    mmt1.costed_flag  in (''N'', ''E'') '||
'  and    mmt1.error_code = ''CST_INVALID_WIP'' '||
     where_clause ||
'  ) '||
   where_clause ||
'order by wip_entity_id, transaction_id';


dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Pending Resource transaction(s) due to UnCosted/erred MMT transaction.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

If ( dummy_num > 0) then

 reportStr := 'The rows returned above signify data inconsistency in resource transaction(s) for Work Order-less / Flow  transactions. These are pending transactions in WCTI for uncosted / erred Work Order-less / Flow transactions in MMT.';
 JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
 JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please open a service request against Oracle Work in Process for the data-fix and root-cause, and upload the output of this diagnostic test.<BR> <BR>');

end if;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';


sqltxt :=
' select wcti.wip_entity_name ScheduleNumber,  '||
'        wcti.wip_entity_id, '||
'        wcti.organization_id, '||
'        wcti.department_code, '||
'        wcti.operation_seq_num, '||
'        wcti.resource_seq_num, '||
'        wcti.resource_code, '||
'        wcti.transaction_id, '||
'        wcti.completion_transaction_id '||
'  from  wip_cost_txn_interface wcti '||
' where  entity_type = 4 -- Flow '||
  where_clause ||
'   and exists (select 1 '||
'     from mtl_material_transactions mmt '||
'     where mmt.transaction_action_id in (30, 31, 32) '||
'     and mmt.transaction_source_type_id = 5 /* WIP */'||
'     and mmt.flow_schedule = ''Y'' '||
'     and mmt.costed_flag is null /* Parent is costed */'||
'     and mmt.completion_transaction_id = wcti.completion_transaction_id '||
      where_clause || ' )';


dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Work Order-less / Flow Pending Resource transaction(s) with Costed parent MMT transaction.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

If ( dummy_num > 0) then

reportStr := 'The rows returned above signify data inconsistency in resource transaction(s) for Work Order-less / Flow transactions. These are transactions in WCTI for which parent Work Order-less / Flow transactions is costed.';
JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Records listed above are not eligible for Costing as Parent transaction is already costed.<BR>' ||
' In this event, variances must have been posted. You should thus post a manual journal entry to transfer the value back from variance account' ||
' into WIP valuation acounts. Finally, delete the corresponding pending resource transaction(s) record.<BR><BR>');

end if;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';

 <<l_test_end>>
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END Pending_res_txn_wol;

PROCEDURE Invalid_txn_mti_wol(inputs IN  JTF_DIAG_INPUTTBL,
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
 where_clause VARCHAR2(4000) := NULL; -- where clause
BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrganizationId',inputs);

If l_org_id is not null then
   where_clause := ' and organization_id = ' || l_org_id || ' ';
   reportStr := ' Organization Id = ' || l_org_id || ' <BR>';
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
end if;

/* Bug 5731956: Added if condition to check existence of column COMPLETION_TRANSACTION_ID*/
if JTF_DIAGNOSTIC_COREAPI.Column_Exists('MTL_TRANSACTIONS_INTERFACE','COMPLETION_TRANSACTION_ID', 'INV') = 'Y' then
        sqltxt :=
        'SELECT transaction_source_id, '||
        '       organization_id, '||
        '       transaction_interface_id, '||
        '       parent_id, '||
        '       completion_transaction_id '||
        'FROM   mtl_transactions_interface mti '||
        'WHERE  mti.transaction_source_type_id = 5 '||
        'AND    mti.transaction_action_id IN (1, 27, 33, 34) '||
        'AND    mti.flow_schedule = ''Y'' '||
          where_clause ||
        'AND    NOT EXISTS  '||
        '       (SELECT 1 FROM mtl_transactions_interface mti2 '||
        '        WHERE mti2.organization_id = mti.organization_id '||
        '        AND   mti2.transaction_source_type_id = 5 '||
        '        AND   mti2.completion_transaction_id = mti.completion_transaction_id '||
        '        AND   mti2.transaction_action_id NOT IN (1, 27, 33, 34) '||
        '        AND   mti2.transaction_interface_id = mti.parent_id' ||
                 where_clause || ' ) '||
        'AND    NOT EXISTS  '||
        '       (SELECT 1 FROM mtl_material_transactions mmt '||
        '        WHERE mmt.organization_id = mti.organization_id '||
        '        AND   mmt.transaction_source_type_id = 5 '||
        '        AND   mmt.completion_transaction_id = mti.completion_transaction_id '||
        '        AND   mmt.costed_flag IN (''N'',''E'')  '||
        '        AND   mmt.transaction_action_id NOT IN (1, 27, 33, 34)) ';

        dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
                   'Component transaction(s) in transactions open interface whose associated assembly transaction '||
                   'is costed or missing in material transactions table(MMT).',true,null,'Y',row_limit);

        IF (dummy_num = row_limit) THEN
           JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
        END IF;

        If ( dummy_num > 0) then

        reportStr := 'The rows returned above signify data inconsistency in component transaction(s) for Work Order-less / Flow transactions.' ||
        ' These are component transactions in MTI for which parent Work Order-less / Flow transactions is costed or missing.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');

        end if;

        statusStr := 'SUCCESS';
        isFatal := 'FALSE';
        fixInfo := 'OK';
        errStr :='No Error!';


        sqltxt :=
        'SELECT transaction_source_id, '||
        '       organization_id, '||
        '       transaction_interface_id, '||
        '       parent_id, '||
        '       completion_transaction_id '||
        'FROM   mtl_transactions_interface mti '||
        'WHERE  mti.transaction_source_type_id = 5 '||
        'AND    mti.transaction_action_id IN (1, 27, 33, 34) '||
        'AND    mti.flow_schedule = ''Y'' '||
          where_clause ||
        'AND    NOT EXISTS  '||
        '       (SELECT 1 FROM mtl_transactions_interface mti2 '||
        '        WHERE mti2.organization_id = mti.organization_id '||
        '        AND   mti2.transaction_source_type_id = 5 '||
        '        AND   mti2.completion_transaction_id = mti.completion_transaction_id '||
        '        AND   mti2.transaction_action_id NOT IN (1, 27, 33, 34) '||
        '        AND   mti2.transaction_interface_id = mti.parent_id' ||
                 where_clause || ' ) '||
        'AND     EXISTS  '||
        '       (SELECT 1 FROM mtl_material_transactions mmt '||
        '        WHERE mmt.organization_id = mti.organization_id '||
        '        AND   mmt.transaction_source_type_id = 5 '||
        '        AND   mmt.completion_transaction_id = mti.completion_transaction_id '||
        '        AND   mmt.costed_flag IN (''N'',''E'')  '||
        '        AND   mmt.transaction_action_id NOT IN (1, 27, 33, 34)) ';


        dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Component transaction(s) in transactions open interface whose associated assembly transaction is not costed.',true,null,'Y',row_limit);

        IF (dummy_num = row_limit) THEN
           JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
        END IF;

        If ( dummy_num > 0) then

        reportStr := 'The rows returned above signify data inconsistency in component transaction(s) for Work Order-less / Flow transactions.' ||
        ' These are component transactions in MTI for which parent Work Order-less / Flow transactions is not costed.';
        JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');

        end if;
else
        reportStr := 'This instance is not able to run this test as it is not on the required patchset level.';
        JTF_DIAGNOSTIC_COREAPI.WarningPrint(reportStr);
        JTF_DIAGNOSTIC_COREAPI.ActionWarningPrint('No action required.');
end if;

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';


 <<l_test_end>>
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END Invalid_txn_mti_wol;

PROCEDURE Dup_mat_txn_mti(inputs IN  JTF_DIAG_INPUTTBL,
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
 l_org_id    NUMBER;
 where_clause VARCHAR2(4000) := NULL; -- where clause
BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
row_limit := 1000;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrganizationId',inputs);

If l_org_id is not null then
   where_clause := ' and organization_id = ' || l_org_id || ' ';
   reportStr := ' Organization Id = ' || l_org_id || ' <BR>';
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
end if;

sqltxt :=
'SELECT organization_id,  '||
'       transaction_source_id, '||
'       transaction_type_id, '||
'       inventory_item_id,  '||
'       primary_quantity, '||
'       subinventory_code, '||
'       locator_id '||
'       completion_transaction_id, '||
'       Count(*) '||
'FROM mtl_material_transactions '||
'WHERE transaction_source_type_id = 5  '||
'AND   completion_transaction_id IS NOT null   '||
'AND   flow_schedule = ''Y'' '||
  where_clause ||
'HAVING Count(*) > 1 '||
'GROUP BY  organization_id,  '||
'          transaction_source_id, '||
'          transaction_type_id, '||
'          inventory_item_id,  '||
'          primary_quantity, '||
'          subinventory_code, '||
'          locator_id, '||
'          completion_transaction_id';


dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,
		'Duplicate material transactions.',true,null,'Y',row_limit);

IF (dummy_num = row_limit) THEN
   JTF_DIAGNOSTIC_COREAPI.Line_Out('<BR> Output limited to the first '|| row_limit || ' rows to prevent an excessively large output file. <BR>');
END IF;

If ( dummy_num > 0) then

reportStr := 'The rows returned above signify data inconsistency in Work Order-less / Flow transactions. These are duplicate material transactions.';
JTF_DIAGNOSTIC_COREAPI.ErrorPrint(reportStr);
JTF_DIAGNOSTIC_COREAPI.ActionErrorLink('Please refer to Metalink note ', 402202.1, 'to get the root-cause patch and steps to correct the data.<BR><BR>');

end if;
statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';


 <<l_test_end>>
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END Dup_mat_txn_mti;

END;

/
