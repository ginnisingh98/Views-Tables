--------------------------------------------------------
--  DDL for Package Body INV_DIAG_UNCST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_UNCST" as
/* $Header: INVDTA1B.pls 120.0.12000000.1 2007/06/22 01:30:37 musinha noship $ */
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
 l_acct_period_id NUMBER :=null;
 l_acct_period    varchar2(15);
 l_proc_flag varchar2(1);
BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
-- accept input
l_org_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('OrgId',inputs);
l_acct_period :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('AcctPeriod',inputs);
l_proc_flag :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('CostFlag',inputs);
row_limit :=INV_DIAG_GRP.g_max_row;

if l_org_id is not null and l_acct_period is not null then
begin
    SELECT acct_period_id
    into l_acct_period_id
    FROM org_acct_periods
    WHERE organization_id = l_org_id
    AND period_name = l_acct_period;
exception
    when others then
     JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Invalid Input Parameters. ');
     errStr := 'Invalid Account period '||SQLCODE||' '||substrb(sqlerrm,1,1000);
     fixInfo := 'Enter a valid account period';
     statusStr := 'FAILURE';
     isFatal := 'SUCCESS';
     goto l_test_end;
end;
end if;
-- l_txn_id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('testout',inputs);

sqltxt :=' SELECT mp.organization_code "Organization Code" '||
         '  , mmt.organization_id "Organization Id" '||
         '   , DECODE( TO_CHAR( mp.primary_cost_method )  '||
         '             , ''1'',''Standard'' '||
         '             , ''2'',''Average'' '||
         '             , ''3'',''Periodic Average'' '||
         '             , ''4'',''Periodic Incremental LIFO'' '||
         '             , ''5'',''LIFO'' '||
         '             , ''6'',''FIFO'' '||
         '           , TO_CHAR( mp.primary_cost_method ) ) '||
         '      "PrimaryCost Method" '||
         '   , oap.period_name "Period Name" '||
         '   , mmt.acct_period_id "Period Id"   '||
         '   , mmt.costed_flag "Costed Flag" '||
         '   , COUNT(*) "Count" '||
         'FROM mtl_material_transactions mmt, mtl_parameters mp   '||
         '   , org_acct_periods oap   '||
        'WHERE mmt.organization_id = mp.organization_id   '||
        '  AND mmt.acct_period_id = oap.acct_period_id(+)   '||
        '  AND costed_flag IS NOT NULL   '||
        'GROUP BY mp.organization_code, mmt.organization_id   '||
        '       , mp.primary_cost_method   '||
        '       , oap.period_name, mmt.acct_period_id   '||
        '       , mmt.costed_flag   '||
        ' ORDER BY mp.organization_code, mmt.organization_id   '||
         '      , mmt.acct_period_id, mmt.costed_flag ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Uncosted Transactions in ALL Orgs and ALL Periods ');

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt :='SELECT DISTINCT oap.period_name "Period Name" '||
         '  , oap.acct_period_id "Period Id" '||
         '  , TO_CHAR( oap.period_start_date,''DD-MON-RR'') "Start Date" '||
         '  , TO_CHAR( oap.schedule_close_date,''DD-MON-RR'') "Scheduled Close Date"   '||
         '  , TO_CHAR( oap.period_close_date,''DD-MON-RR'') "Close Date"   '||
         '  , oap.open_flag "Open Flag"   '||
        'FROM org_acct_periods oap   '||
        '   , mtl_material_transactions mmt   '||
      'WHERE mmt.costed_flag IS NOT NULL   '||
      '  AND oap.organization_id = mmt.organization_id   '||
      '  AND (mmt.acct_period_id IS NULL OR  mmt.acct_period_id=-1)   '||
      '  AND mmt.transaction_date   '||
      '      BETWEEN oap.period_start_date AND oap.schedule_close_date ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmt.organization_id =  '||l_org_id;
end if;
sqltxt:=sqltxt||' ORDER BY TO_CHAR( oap.period_start_date,''DD-MON-RR'')';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Related Period Information');

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt := 'SELECT mmt.transaction_id "Txn Id"   '||
          '  , mif.item_number ||'' (''|| mmt.inventory_item_id ||'')'' "Item (Id)"   '||
          '  , mmt.transaction_date "Txn Date"   '||
          '  , mmt.acct_period_id "Period Id"   '||
          '  , mmt.transaction_quantity "Txn Qty"   '||
          '  , mmt.primary_quantity "Prim Qty"   '||
          '  , mmt.transaction_uom "Uom"   '||
          '  , tt.transaction_type_name ||'' (''||mmt.transaction_type_id||'')'' "Txn Type (Id)"   '||
          '  , mmt.subinventory_code "Subinv"   '||
          '  , mmt.locator_id "Stock Locator"   '||
          '  , mmt.revision "Rev"    '||
          '  , mmt.costed_flag "Costed Flag"   '||
          '  ,(SELECT COUNT(*) FROM mtl_cst_actual_cost_details   '||
          '     WHERE transaction_id=mmt.transaction_id) "Actual Cost Records"   '||
          '  , distribution_account_id "Distrib Account Id"   '||
          '  , mmt.cost_group_id "Cost Group Id"   '||
          '  , mmt.transfer_cost_group_id "Transfer Cost Group Id"   '||
          '  , mmt.flow_schedule "Flow Schedule"   '||
          '  , mmt.transaction_group_id "Txn Group Id"   '||
          '  , mmt.transaction_set_id "Txn Set Id"   '||
          '  , mmt.transaction_cost "Txn Cost"  '||
          '  , mmt.creation_date "Created"  '||
          '  , mmt.last_update_date "Last Updated"  '||
          '  , ml.meaning || '' ('' ||mmt.transaction_action_id|| '')''  '||
          '    "Txn Action (Id)"  '||
          '  , mmt.completion_transaction_id "Completion Txn Id"  '||
          '  , st.transaction_source_type_name ||'' (''|| mmt.transaction_source_type_id ||'')'' "Txn Source Type (Id)"  '||
          '  , mmt.transaction_source_id "Txn Source Id"  '||
          '  , mmt.transaction_source_name "Txn Source"   '||
          '  , mmt.source_code "Source|Code"  '||
          '  , mmt.source_line_id "Source Line Id"  '||
          '  , mmt.request_id "Txn Request Id"  '||
          '  , mmt.operation_seq_num "Operation|Seq Num"  '||
          '  , mmt.transfer_transaction_id "Transfer Txn Id"  '||
          '  , mmt.transfer_organization_id "Transfer Organization Id"  '||
          '  , mmt.transfer_subinventory "Transfer Subinv"  '||
          '  , mmt.shipment_number '||
          '  , mmt.error_code "Error Code"  '||
          '  , mmt.error_explanation "Error Explanation"  '||
        ' FROM mtl_material_transactions mmt  '||
        '    , mtl_item_flexfields mif  '||
        '    , mtl_transaction_types tt  '||
        '    , mtl_txn_source_types st  '||
        '    , mfg_lookups ml  '||
        'WHERE (mmt.acct_period_id IS NULL OR  mmt.acct_period_id=-1)  '||
        '  AND mmt.inventory_item_id = mif.inventory_item_id(+)  '||
        '  AND mmt.organization_id = mif.organization_id(+)  '||
        '  AND mmt.transaction_type_id = tt.transaction_type_id(+)  '||
        '  AND mmt.transaction_source_type_id = st.transaction_source_type_id(+)  '||
        '  AND mmt.transaction_action_id=ml.lookup_code  '||
        '  AND ml.lookup_type = ''MTL_TRANSACTION_ACTION''  '||
        '  AND costed_flag IS NOT NULL ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and mmt.organization_id =  '||l_org_id;
end if;
sqltxt :=sqltxt||' ORDER BY costed_flag, transaction_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Uncosted Txn in MMT with an invalid ACCT_PERIOD_ID in Organization');

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt := 'SELECT mp.primary_cost_method  '||
          '  , DECODE( TO_CHAR( mp.primary_cost_method ), ''1'',''Standard''   '||
          '                                             , ''2'',''Average''   '||
          '                                             , ''3'',''Periodic Average''   '||
          '                                             , ''4'',''Periodic Incremental LIFO''   '||
          '                                             , ''5'',''LIFO''   '||
          '                                             , ''6'',''FIFO''   '||
          '          , TO_CHAR( mp.primary_cost_method ) )  "Primary Cost Method"   '||
          '  , NVL( br.resource_code , ''null'' )  "Resource Code"   '||
          '  , mp.default_cost_group_id "Default Cost Group"   '||
          '  , ccg.cost_group   '||
          '  , mp.pm_cost_collection_enabled    '||
          '  , DECODE( TO_CHAR( mp.pm_cost_collection_enabled ), ''1'', ''Yes''    '||
          '                                                    , ''2'', ''No''   '||
          '         , TO_CHAR( mp.pm_cost_collection_enabled ) ) "Project Cost Collect Enabled" '||
          '  , mp.project_reference_enabled   '||
          '  , DECODE( TO_CHAR( NVL(mp.project_reference_enabled, 2)),''1'', ''Yes''    '||
          '                                                         , ''2'', ''No''   '||
          '          , TO_CHAR( mp.project_reference_enabled ) ) "Project Reference Enabled" '||
          ' , material_account    '||
          ', outside_processing_account    '||
          ', material_overhead_account     '||
          ', resource_account    '||
          ', overhead_account    '||
          ', expense_account         '||
          ', mp.cost_cutoff_date, mp.cost_group_accounting '||
       'FROM mtl_parameters mp, bom_resources br, cst_cost_groups ccg   '||
       'WHERE mp.default_material_cost_id = br.resource_id(+)  '||
       '  AND mp.default_cost_group_id = ccg.cost_group_id(+)';

if l_org_id is not null then
   sqltxt :=sqltxt||' and mp.organization_id =  '||l_org_id;
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Cost-related Parameters from MTL_PARAMETERS');

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt :='SELECT ( SELECT organization_code  '||
         '   FROM mtl_parameters   '||
         '  WHERE organization_id=from_organization_id ) || '' ( ''   '||
         '  ||from_organization_id|| '' )'' "From Organization"   '||
         ', ( SELECT organization_code   '||
         '    FROM mtl_parameters   '||
         '   WHERE organization_id=to_organization_id ) || '' ( ''   '||
         '    ||to_organization_id|| '' )'' "To |Organization"          '||
         '   , DECODE( intransit_type,   '||
         '                  1, ''Direct'',   '||
         '                  2, ''Intransit'',   '||
         '             intransit_type ) "Intransit Type"   '||
         '   , DECODE( fob_point,   '||
         '                  1, ''Shipment'',   '||
         '                  2, ''Receipt'',   '||
         '             fob_point ) "FOB Point"   '||
         '   , DECODE( internal_order_required_flag,   '||
         '                  1, ''Yes'',   '||
         '                  2, ''No'',   '||
         '             internal_order_required_flag )   '||
         '             "Internal Order|Required Flag"   '||
         '   , DECODE( matl_interorg_transfer_code,   '||
         '                  1, ''No Transfer Charges'',   '||
         '                  2, ''Requested added value'',   '||
         '                  3, ''Requested % of Txn Value'',   '||
         '                  4, ''Predefined % of Txn Value'',   '||
         '             matl_interorg_transfer_code )   '||
         '             "Matl Interorg|Transfer Code"   '||
         '   , DECODE( elemental_visibility_enabled,   '||
         '                      ''Y'', ''Yes'',   '||
         '                      ''N'', ''No'',   '||
         '             elemental_visibility_enabled)   '||
         '             "Elemental|Visibility|Enabled"   '||
         '   , interorg_trnsfr_charge_percent "Interorg Transfer Charge %"   '||
         '   , intransit_inv_account "Intransit Inv Account"   '||
         '   , interorg_transfer_cr_account "Interorg Transfer CR Account"   '||
         '   , interorg_receivables_account "Interorg|Receivables Account"   '||
         '   , interorg_payables_account "Interorg Payables Account"   '||
         '   , interorg_price_var_account "Interorg Price Var Account"   '||
         ' FROM mtl_interorg_parameters ';
if l_org_id is not null then
   sqltxt :=sqltxt||' WHERE ( from_organization_id =  '||l_org_id||
                    ' OR to_organization_id = '||l_org_id||')';
end if;

sqltxt:=sqltxt||' ORDER BY 1, 2 ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Interorganization Relationships');

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt :='SELECT ccg.cost_group "Cost Group"  '||
         ' , ccg.cost_group_id "Cost Group Id"  '||
         ' , ml.meaning  '||
         '   ||'' (''||ccg.cost_group_type||'')'' "Cost Group Type"  '||
         ' , ccg.description "Description"  '||
         ' , ccg.disable_date "Disable Date"  '||
       'FROM cst_cost_groups ccg, mfg_lookups ml '||
      'WHERE ml.lookup_type = ''CST_COST_GROUP_TYPE''  '||
      '  AND ccg.cost_group_type = ml.lookup_code ' ;
if l_org_id is not null then
   sqltxt :=sqltxt||' and organization_id =  '||l_org_id;
end if;
sqltxt :=sqltxt||' ORDER BY cost_group';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Cost Groups ');

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt :='SELECT cost_group_id '||
         ' , material_account  '||
         ' , material_overhead_account  '||
         ' , resource_account  '||
         ' , overhead_account  '||
         ' , outside_processing_account  '||
         ' , average_cost_var_account  '||
         ' , encumbrance_account  '||
         ' , expense_account  '||
         ' , payback_mat_var_account  '||
         ' , payback_res_var_account  '||
         ' , payback_osp_var_account  '||
         ' , payback_moh_var_account  '||
         ' , payback_ovh_var_account  '||
      ' FROM cst_cost_group_accounts  ccga'  ;
if l_org_id is not null then
   sqltxt :=sqltxt||' where organization_id =  '||l_org_id;
end if;
sqltxt :=sqltxt||' ORDER BY cost_group_id';
sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Cost Group Accounts ');

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt :=' SELECT owner "Owner", object_name "Name", object_type "Type"  '||
         ' , status "Status"   '||
         ' , last_ddl_time "Last Compile Date"   '||
         ' , created "Creation Date"   '||
       'FROM all_objects   '||
      'WHERE status=''INVALID''  '||
      '  AND object_name LIKE ''CST%''  '||
      '  AND owner LIKE ''%''    '||
      'ORDER BY object_name, object_type ';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Invalid Costing database Objects');

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt :='SELECT b.user_profile_option_name "Long Name"  '||
         ' , a.profile_option_name "Short Name"   '||
         ' , DECODE( c.level_id, 10001, ''Site''   '||
         '                     , 10002, ''Application''   '||
         '                     , 10003, ''Responsibility''   '||
         '                     , 10004, ''User''   '||
         '                     , ''Unknown'') "Level"  '||
         ' , DECODE( c.level_id, 10001, ''Site''   '||
         '                     , 10002, NVL(h.application_short_name,   '||
         '                                  TO_CHAR( c.level_value))   '||
         '                     , 10003, NVL(g.responsibility_name,   '||
         '                                  TO_CHAR( c.level_value))   '||
         '                     , 10004, NVL(e.user_name,   '||
         '                                  TO_CHAR(c.level_value))   '||
         '                     , ''Unknown'') "Level Value"   '||
         ' , c.profile_option_value "Profile Value"   '||
         ' , TO_CHAR( c.last_update_date,''DD-MON-YYYY HH24:MI'')   '||
         '   "Updated Date"   '||
         ' , NVL( d.user_name, TO_CHAR( c.last_updated_by)) "Updated By"   '||
       'FROM fnd_profile_options a   '||
       '   , fnd_profile_options_vl b   '||
       '   , fnd_profile_option_values c   '||
       '   , fnd_user d , fnd_user e   '||
       '   , fnd_responsibility_vl g   '||
       '   , fnd_application h   '||
      'WHERE a.profile_option_name = b.profile_option_name   '||
      '  AND a.profile_option_id = c.profile_option_id   '||
      '  AND a.application_id = c.application_id   '||
      '  AND c.last_updated_by = d.user_id (+)   '||
      '  AND c.level_value = e.user_id (+)   '||
      '  AND c.level_value = g.responsibility_id (+)   '||
      '  AND c.level_value = h.application_id (+)   '||
      '  AND ( a.profile_option_name LIKE ''CST%''   '||
      '        OR   '||
      '        a.profile_option_name IN (   '||
      '                    ''HR_CROSS_BUSINESS_GROUP'' ,  '||
      '                    ''INV:EXPENSE_TO_ASSET_TRANSFER'' ,  '||
      '                    ''INVTP_COSTGROUP_TXN'' ,  '||
      '                    ''MRP_DEBUG'' ,  '||
      '                    ''MRP_TRACE'',  '||
      '                    ''UPDATE_AVG_TXN'' ) )  '||
      ' ORDER BY b.user_profile_option_name, c.level_id';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Related Costing  Profile Options');

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt :='SELECT COUNT(*)  '||
         'FROM mtl_material_transactions ' ;

if nvl(l_proc_flag, 'A')  <> 'E' then
   sqltxt := sqltxt||'WHERE costed_flag <> ''Y'' ';
else
   sqltxt := sqltxt||'WHERE costed_flag = ''E'' ';
end if;

if l_org_id is not null then
   sqltxt :=sqltxt||' and organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and acct_period_id = '||l_acct_period_id;
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Count uncosted records in MMT');

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt :='SELECT error_code "Error Code"  '||
         '            , error_explanation "Error Explanation"   '||
         '            , costed_flag "Costed|Flag"   '||
         '   , COUNT(*) "Count"   '||
         'FROM mtl_material_transactions   '||
        'WHERE  costed_flag IS NOT NULL ';

if l_org_id is not null then
   sqltxt :=sqltxt||' and organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and acct_period_id = '||l_acct_period_id;
end if;

sqltxt := sqltxt||'GROUP BY error_code, error_explanation, costed_flag';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Distinct Errors in MMT ');

statusStr := 'SUCCESS';
isFatal := 'FALSE';

sqltxt :='SELECT costed_flag "Costed Flag"  '||
         '   , COUNT(*) "Count"   '||
         'FROM mtl_material_transactions   '||
        'WHERE costed_flag IS NOT NULL ';
if l_org_id is not null then
   sqltxt :=sqltxt||' and organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and acct_period_id = '||l_acct_period_id;
end if;

sqltxt := sqltxt||'GROUP BY costed_flag';
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Count of distinct costed_flag in MMT ');

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt :='SELECT mmt.costed_flag "Costed Flag"  '||
         '   , tt.transaction_type_name   '||
         '     || '' ( '' || mmt.transaction_type_id || '' )'' "Txn Type (Id)"   '||
         '   , ml.meaning   '||
         '     || '' ( '' || mmt.transaction_action_id || '' )''   '||
         '     "Txn Action (Id)"   '||
         '   , st.transaction_source_type_name   '||
         '     || '' ( '' || mmt.transaction_source_type_id || '' )''   '||
         '     "Txn Source Type (Id)"   '||
         '   , COUNT(*) "Count"   '||
         'FROM mtl_material_transactions mmt, mtl_transaction_types tt   '||
         '   , mfg_lookups ml, mtl_txn_source_types st   '||
        'WHERE mmt.transaction_type_id = tt.transaction_type_id(+)   '||
        '  AND mmt.transaction_action_id = ml.lookup_code   '||
        '  AND ml.lookup_type = ''MTL_TRANSACTION_ACTION''   '||
        '  AND mmt.transaction_source_type_id = st.transaction_source_type_id(+) ' ;
if nvl(l_proc_flag, 'A')  <> 'E' then
   sqltxt := sqltxt||' and mmt.costed_flag <> ''Y'' ';
else
   sqltxt := sqltxt||' and mmt.costed_flag = ''E'' ';
end if;


if l_org_id is not null then
   sqltxt :=sqltxt||' and mmt.organization_id =  '||l_org_id;
end if;

if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmt.acct_period_id = '||l_acct_period_id;
end if;

sqltxt :=sqltxt||' GROUP BY mmt.costed_flag, tt.transaction_type_name  '||
       '       , mmt.transaction_type_id  '||
       '       , ml.meaning  '||
       '       , mmt.transaction_action_id  '||
       '       , st.transaction_source_type_name  '||
       '       , mmt.transaction_source_type_id  '||
       'ORDER BY 1, 2, 3 ';


dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Transactions Type Information of UnCosted Txns ');

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt :='SELECT mmt.transaction_id "Txn Id"  '||
         '   , mmt.costed_flag "Costed Flag"   '||
         '   , mif.item_number   '||
         '     ||'' (''|| mmt.inventory_item_id ||'')'' "Item (Id)"   '||
         '   , mta.transaction_date "Txn Date"   '||
         '   , mta.transaction_value "Txn Value"   '||
         '   , mta.base_transaction_value "Base Txn Value"   '||
         '   , mta.gl_batch_id "GL Batch Id"   '||
         'FROM mtl_material_transactions mmt   '||
         '   , mtl_item_flexfields mif   '||
         '   , mtl_transaction_accounts mta   '||
        'WHERE mmt.inventory_item_id = mif.inventory_item_id(+)   '||
         ' AND mmt.organization_id = mif.organization_id(+)   '||
         ' AND mmt.transaction_id = mta.transaction_id';

if nvl(l_proc_flag, 'A')  <> 'E' then
   sqltxt := sqltxt||' and mmt.costed_flag <> ''Y'' ';
else
   sqltxt := sqltxt||' and mmt.costed_flag = ''E'' ';
end if;


if l_org_id is not null then
   sqltxt :=sqltxt||' and mmt.organization_id =  '||l_org_id;
end if;
if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmt.acct_period_id = '||l_acct_period_id;
end if;

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Account transactions ( if already created ) of uncosted Txn');

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt :='SELECT DISTINCT( msi.secondary_inventory_name )  "Name"  '||
         '  , msi.description "Description"   '||
         '  , msi.disable_date "Disable|Date"   '||
         '  , DECODE( msi.asset_inventory, 1, ''Yes'',   '||
         '                                 2, ''No'',   '||
         '            msi.asset_inventory ) "Asset|Inventory"   '||
         '  , msi.default_cost_group_id "Default|Cost Group Id"   '||
         '  , DECODE( msi.reservable_type, 1, ''Yes'',   '||
         '                                 2, ''No'',   '||
         '            msi.reservable_type) "Reservable|Type"   '||
         '  , DECODE( msi.inventory_atp_code, 1, ''Inventory included in atp calculation'',   '||
         '                                    2, ''Inventory not included in atp calculation'',   '||
         '            msi.inventory_atp_code ) "Inventory|ATP Code"   '||
         '  , DECODE( msi.quantity_tracked, 1, ''Yes'',   '||
         '                                  2, ''No'',   '||
         '            msi.quantity_tracked ) "Quantity|Tracked"   '||
        'FROM mtl_material_transactions mmt   '||
        '   , mtl_secondary_inventories msi   '||
       'WHERE mmt.organization_id = msi.organization_id   '||
       '  AND   '||
       '    ( msi.secondary_inventory_name = mmt.subinventory_code   '||
       '      OR   '||
       '      msi.secondary_inventory_name = mmt.transfer_subinventory   '||
       '    )';
if nvl(l_proc_flag, 'A')  <> 'E' then
   sqltxt := sqltxt||' and mmt.costed_flag <> ''Y'' ';
else
   sqltxt := sqltxt||' and mmt.costed_flag = ''E'' ';
end if;

if l_org_id is not null then
   sqltxt :=sqltxt||' and mmt.organization_id =  '||l_org_id;
end if;
if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmt.acct_period_id = '||l_acct_period_id;
end if;


dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, ' Subinventory Information of Txns in MMT');

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt :='SELECT DISTINCT mif.item_number "Item Number"  '||
         ' , mmt.inventory_item_id "Item Id"   '||
         ' , mif.description "Description"   '||
         ' , mif.last_update_date "Last updated"   '||
         ' , mif.inventory_item_flag "Inventory Item Flag"   '||
         ' , mif.inventory_asset_flag "Inventory Asset Flag"   '||
         ' , ( SELECT DISTINCT   '||
         '            DECODE( TO_CHAR( cic.inventory_asset_flag )   '||
         '                    , ''1'', ''Y''   '||
         '                    , ''2'', ''N''   '||
         '                    , cic.inventory_asset_flag )   '||
         '              || ''  ('' ||cic.inventory_asset_flag|| '')''   '||
         '       FROM cst_item_costs cic   '||
         '          , mtl_parameters mp  '||
         '      WHERE cic.cost_type_id = mp.primary_cost_method' ;
if l_org_id is not null then
   sqltxt :=sqltxt||' and cic.organization_id =  '||l_org_id||' and  mp.organization_id = '||l_org_id;
end if;
sqltxt:=sqltxt||'   AND cic.inventory_item_id = mmt.inventory_item_id ) '||
                '   "Costing Asset Flag"   '||
         ' , mif.inventory_item_status_code "Inventory Item Status Code"   '||
         ' , mif.costing_enabled_flag "Costing Enabled Flag"   '||
         ' , mif.default_include_in_rollup_flag "Default Include|In Rollup Flag"   '||
         ' , mif.enabled_flag "Enabled Flag"   '||
         ' , mif.start_date_active "Start Date Active"   '||
         ' , mif.end_date_active "End Date Active"   '||
         ' , DECODE( TO_CHAR( NVL( mif.revision_qty_control_code,1 ) )   '||
         '           , ''1'',''N'', ''2'', ''Y''   '||
         '           , mif.revision_qty_control_code) "Revision|Controlled"   '||
       'FROM mtl_material_transactions mmt   '||
       '   , mtl_item_flexfields mif   '||
      'WHERE mmt.organization_id = mif.organization_id   '||
       ' AND mmt.inventory_item_id = mif.inventory_item_id';
if nvl(l_proc_flag, 'A')  <> 'E' then
   sqltxt := sqltxt||' and mmt.costed_flag <> ''Y'' ';
else
   sqltxt := sqltxt||' and mmt.costed_flag = ''E'' ';
end if;


if l_org_id is not null then
   sqltxt :=sqltxt||' and mmt.organization_id =  '||l_org_id;
end if;
if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmt.acct_period_id = '||l_acct_period_id;
end if;
dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Item Information of Txns in MMT');

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt :='SELECT mmt.transaction_id "Txn Id"  '||
         '  , mif.item_number ||'' (''|| mmt.inventory_item_id ||'')'' "Item (Id)"   '||
         '  , mmt.transaction_date "Txn Date"   '||
         '  , mmt.transaction_quantity "Txn Qty"   '||
         '  , mmt.primary_quantity "Prim Qty"   '||
         '  , mmt.transaction_uom "Uom"   '||
         '  , tt.transaction_type_name ||'' (''||mmt.transaction_type_id||'')'' "Txn Type (Id)"   '||
         '  , mmt.subinventory_code "Subinv"   '||
         '  , mmt.locator_id "Stock Locator"   '||
         '  , mmt.revision "Rev"    '||
         '  , mmt.costed_flag "Costed Flag"   '||
         '  ,(SELECT COUNT(*) FROM mtl_cst_actual_cost_details   '||
         '     WHERE transaction_id=mmt.transaction_id) "Actual Cost Records"   '||
         '  , distribution_account_id "Distrib Account|Id"   '||
         '  , mmt.cost_group_id "Cost Group Id"   '||
         '  , mmt.transfer_cost_group_id "Transfer Cost Group Id"   '||
         '  , mmt.flow_schedule "Flow Schedule"   '||
         '  , mmt.transaction_group_id "Txn Group Id"   '||
         '  , mmt.transaction_set_id "Txn Set Id"   '||
         '  , mmt.transaction_cost "Txn Cost"   '||
         '  , mmt.creation_date "Created"   '||
         '  , mmt.last_update_date "Last Updated"   '||
         '  , ml.meaning || '' ('' ||mmt.transaction_action_id|| '')''   '||
         '    "Txn Action (Id)"   '||
         '  , mmt.completion_transaction_id "Completion Txn Id"   '||
         '  , st.transaction_source_type_name ||'' (''|| mmt.transaction_source_type_id ||'')'' "Txn Source Type (Id)"   '||
         '  , mmt.transaction_source_id "Txn Source Id"   '||
         '  , mmt.transaction_source_name "Txn Source"    '||
         '  , mmt.source_code "Source Code"   '||
         '  , mmt.source_line_id "Source Line Id"   '||
         '  , mmt.request_id "Txn Request Id"   '||
         '  , mmt.operation_seq_num "Operation Seq Num"   '||
         '  , mmt.transfer_transaction_id "Transfer Txn Id"   '||
         '  , mmt.transfer_organization_id "Transfer|Organization Id"   '||
         '  , mmt.transfer_subinventory "Transfer Subinv"   '||
         '  , mmt.shipment_number  '||
         '  , mmt.error_code "Error Code"   '||
         '  , mmt.error_explanation "Error Explanation"   '||
         'FROM mtl_material_transactions mmt   '||
         '  , mtl_item_flexfields mif   '||
         '  , mtl_transaction_types tt   '||
         '  , mtl_txn_source_types st   '||
         '  , mfg_lookups ml   '||
        'WHERE mmt.inventory_item_id = mif.inventory_item_id(+)   '||
        ' AND mmt.organization_id = mif.organization_id(+)   '||
        ' AND mmt.transaction_type_id = tt.transaction_type_id(+)   '||
        ' AND mmt.transaction_source_type_id = st.transaction_source_type_id(+)   '||
        ' AND mmt.transaction_action_id=ml.lookup_code   '||
        ' AND ml.lookup_type = ''MTL_TRANSACTION_ACTION'' ';

if nvl(l_proc_flag, 'A')  <> 'E' then
   sqltxt := sqltxt||' and mmt.costed_flag <> ''Y'' ';
else
   sqltxt := sqltxt||' and mmt.costed_flag = ''E'' ';
end if;

if l_org_id is not null then
   sqltxt :=sqltxt||' and mmt.organization_id =  '||l_org_id;
end if;
if l_acct_period_id is not null then
   sqltxt := sqltxt||' and mmt.acct_period_id = '||l_acct_period_id;
end if;


dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Uncosted records in MMT');

statusStr := 'SUCCESS';
isFatal := 'FALSE';


sqltxt :='SELECT o.name "Name"  '||
         '  , DECODE( o.type#, 9, ''Spec'', 11, ''Body'', o.type# ) "Type"   '||
         '  , SUBSTR( s.source, INSTR( s.source, ''$Header'',1 ,1)+9, 12 ) "Filename"   '||
         '  , SUBSTR( s.source ,   '||
         '          INSTR( s.source ,''.'',10,1)+5, '||
         '          INSTR( s.source ,'' '',10,3)-   '||
         '          INSTR( s.source ,'' '',10,2) ) "Version"   '||
         '  , DECODE( o.status, 0, ''NA'', 1, ''VALID'', ''INVALID'' ) "Status"   '||
        'FROM sys.source$ s, sys.obj$ o, sys.user$ u   '||
       'WHERE u.name = ''APPS''   '||
       '  AND o.owner# = u.user#   '||
       '  AND s.obj# = o.obj#   '||
       '  AND s.line = 2   '||
       '  AND s.source like ''%Header: %''   '||
       '  AND o.name IN ( ''CSTPACDP'', ''CSTPACIN'', ''CSTPACHK'', ''CSTPACVP'', ''CSTPAVCP''   '||
       '                , ''CSTPPACQ'', ''CSTPPAHK'' , ''CSTPAPBR'', ''CSTPAPPR''   '||
       '                , ''INV_COST_GROUP_PVT'', ''INV_COST_GROUP_UPDATE'', ''INV_WWACST'' )   '||
       ' ORDER BY o.name, o.type#';

dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Version of relevant Packages');

statusStr := 'SUCCESS';
isFatal := 'FALSE';
fixInfo := 'OK';
errStr :='No Error!';


/**
else
 JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Invalid Input parameters');
 statusStr := 'FAILURE';
 errStr := 'org_id null';
 fixInfo := 'Org or OrdID input is required ';
 isFatal := 'SUCCESS';
end if;
**/
 -- construct report
 <<l_test_end>>
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'UnCosted Transactions';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'Get UnCosted Transactions Information';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'UnCosted Transactions';
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
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'AcctPeriod','LOV-oracle.apps.inv.diag.lov.PeriodLov');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'CostFlag','LOV-oracle.apps.inv.diag.lov.ErroredAllLov');
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
