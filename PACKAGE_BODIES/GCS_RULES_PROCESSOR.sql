--------------------------------------------------------
--  DDL for Package Body GCS_RULES_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_RULES_PROCESSOR" as
  -- $Header: gcserupb.pls 120.11 2007/11/02 07:07:02 smatam ship $

  --+========================================================================+
  -- PACKAGE Global Data
  --+========================================================================+

  -- Logging level during package execution will not change so we can
  -- define a single runtime level here, and update it at the start
  -- of public procedures
  runtimeLogLevel Number;
  packageName CONSTANT Varchar2(30) := 'GCS_RULES_PROCESSOR';

  -- Context switches to FND_LOG for level constants can
  -- be avoided by copying them here once
  statementLogLevel  CONSTANT NUMBER := FND_LOG.level_statement;
  procedureLogLevel  CONSTANT NUMBER := FND_LOG.level_procedure;
  eventLogLevel      CONSTANT NUMBER := FND_LOG.level_event;
  exceptionLogLevel  CONSTANT NUMBER := FND_LOG.level_exception;
  errorLogLevel      CONSTANT NUMBER := FND_LOG.level_error;
  unexpectedLogLevel CONSTANT NUMBER := FND_LOG.level_unexpected;

  --Exception handlers: everything that can go wrong here
  rule_has_no_steps EXCEPTION; -- p_rule_id not found in gcs_rule_steps
  missing_rule_id EXCEPTION; -- an index in p_rule table is null
  missing_currency_data EXCEPTION; -- cannot get precision for currency
  invalid_dim_set_id EXCEPTION; -- the dimension set id is invalid
  invalid_variable EXCEPTION; -- a variable identifier is not valid
  invalid_fem_setup EXCEPTION; -- cannot get dimInfo
  invalid_gcs_setup EXCEPTION; -- cannot get stmts
  out_of_balance EXCEPTION; -- entry out of bal, no suspense
  no_entry_lines EXCEPTION; -- entry outputs no non-zero lines
  suspense_exceeded_warn EXCEPTION; -- suspense exceeded warning
  missing_key EXCEPTION; -- a utility pkg hash key is missing
  bad_sign EXCEPTION; -- a line_item is missing a SIGN attr
  no_default_cctr_found EXCEPTION; -- used in initEntriesGT_tgtDimSet()
  convert_threshold_err EXCEPTION; -- used in createEntry
  entry_header_error EXCEPTION; -- GCS_ENTRY_PKG.create_entry_header failed
  templates_pkg_error EXCEPTION; -- GCS_TEMPLATES_DYNAMIC_PKG may raise
  invalid_category_code EXCEPTION; -- unable to get data from gcs_categories_b

  --The cctr_org and interco dims may require special handling
  --The column names are long strings, so lets use shorter constants
  cctr_column    CONSTANT Varchar2(30) := 'COMPANY_COST_CENTER_ORG_ID';
  interco_column CONSTANT varchar2(30) := 'INTERCOMPANY_ID';

  -- Globally useful values
  ruleId        Number := -1;
  ruleStepId    Number := -1;
  ruleData      ruleDataRecord;
  contextData   contextRecord;
  appGroup      Number := -1;
  systemDate    date;
  userId        number;
  ruleIteration number := 1;

  mainEntryId gcs_entry_headers.entry_id%TYPE := -1;
  statEntryId gcs_entry_headers.entry_id%TYPE := -1;

  -- Dynamic SQL storage
  srcColumnList varchar2(2000);
  tgtColumnList varchar2(2000);
  selColumnList varchar2(2000);
  adtColumnList varchar2(2000);
  insColumnList varchar2(2000);
  modJoinClause varchar2(2000);
  dimJoinClause varchar2(2000);
  sqlStmt       varchar2(10000);

  --Bugfix 4928211: Added offColumnList to store information for offsets
  offColumnList varchar2(2000);

  --3702208: Get target-only DMS info from _DIMS table
  Cursor getTgtDims(rsi number) is
    SELECT d.column_name, d.target_member_id
      FROM GCS_RULE_SCOPE_DIMS d
     WHERE d.rule_step_id = rsi;

  TYPE tgtDimsTable IS TABLE OF getTgtDims%ROWTYPE INDEX BY VARCHAR2(30);
  tgtDims tgtDimsTable;

  --See initRefTables procedure
  cursor getStmts(ruleTypeCode varchar2) is
    SELECT statement_num, statement_text, compiled_variables
      FROM GCS_FORMULA_STATEMENTS
     WHERE rule_type_code = ruleTypeCode
        OR rule_type_code = 'E'
     ORDER BY statement_num;
  TYPE stmtsTable IS TABLE OF getStmts%ROWTYPE INDEX BY BINARY_INTEGER;
  stmts stmtsTable;

  --Look up suspense data for the rule
  Cursor getSuspenseData is
    select h.threshold_amount,
           h.threshold_currency,
           t.financial_elem_id,
           t.product_id,
           t.natural_account_id,
           t.channel_id,
           t.line_item_id,
           t.project_id,
           t.customer_id,
           t.task_id,
           t.user_dim1_id,
           t.user_dim2_id,
           t.user_dim3_id,
           t.user_dim4_id,
           t.user_dim5_id,
           t.user_dim6_id,
           t.user_dim7_id,
           t.user_dim8_id,
           t.user_dim9_id,
           t.user_dim10_id
      from gcs_dimension_templates t, gcs_hierarchies_b h
     where t.hierarchy_id = h.hierarchy_id
       and t.template_code = 'SUSPENSE'
       and h.hierarchy_id = contextData.hierarchy;

  suspenseData getSuspenseData%ROWTYPE;

  -- Look up the steps for the rule_id
  Cursor getSteps is
    SELECT rule_id,
           step_seq,
           rule_step_id,
           step_name,
           formula_text,
           parsed_formula,
           compiled_variables,
           sql_statement_num
      FROM GCS_ELIM_RULE_STEPS_VL
     WHERE rule_id = ruleId
     ORDER BY rule_step_id;

  TYPE stepDataTable IS TABLE OF getSteps%ROWTYPE INDEX BY BINARY_INTEGER;
  stepData stepDataTable;

  --A hash table full of the accessible dims
  dimInfo GCS_UTILITY_PKG.t_hash_gcs_dimension_info;

  --JH 7.22.04: join to FEM_OBJECT_DEFINITIONS first to get object_definition_id
  --JH 7.28.94: added outerjoin to hierarchy_obj_id is it is nullable (Bug 3800142)
  --Bugfix 4928211 (STK): Remove the selection of the hierarchy object definition id
  --in this cursor for performance purposes
  Cursor getDimSelections(rsi number) is
    SELECT s.rule_step_id,
           s.column_name,
           s.all_source_members_flag,
           s.target_member_id,
           s.offset_member_id,
           s.hierarchy_obj_id,
           x.hierarchy_table_name,
           initcap(replace(replace(s.column_name, '_', ''), 'ID', '')) alias
      FROM FEM_XDIM_DIMENSIONS x,
           GCS_RULE_SCOPE_DIMS s,
           FEM_TAB_COLUMNS_B   ftcb
     WHERE ftcb.table_name = 'FEM_BALANCES'
       AND ftcb.column_name = s.column_name
       AND ftcb.dimension_id = x.dimension_id
       AND s.rule_step_id = rsi
     ORDER BY s.column_name;

  TYPE dimsTable IS TABLE OF getDimSelections%ROWTYPE INDEX BY VARCHAR2(30);
  selectDims dimsTable;

  Cursor getCurrency Is
    Select nvl(precision, 2), minimum_accountable_unit
      From fnd_currencies
     Where currency_code = contextData.currencyCode;

  --jh 6.29.04: add org/interco output code.
  --Category info
  Cursor getCategory Is
    Select decode(target_entity_code,
                  'ELIMINATION',
                  contextData.elimsEntity,
                  'PARENT',
                  contextData.parentEntity,
                  'CHILD',
                  contextData.childEntity,
                  -1) entityId, --default in case codes change
           org_output_code,
           --           interco_output_code, -- changes made by yingliu
           net_to_re_flag,
           support_multi_parents_flag -- changes made by yingliu
      From gcs_categories_b
     Where category_code = contextData.eventCategory;

  -- We need a SIGN attribute to set the xtd_balance_e values
  cursor getSigns(liaAtt number, liaVer number, ataAtt number, ataVer number) is
    select distinct e.tgt_line_item_id lineItem,
                    nvl(ata.number_assign_value, 1) signFactor
      from fem_ln_items_attr       lia,
           fem_ext_acct_types_attr ata,
           gcs_entries_gt          e
     where ata.ext_account_type_code = lia.dim_attribute_varchar_member
       and ata.attribute_id = ataAtt
       and ata.version_id = ataVer
       and lia.attribute_id = liaAtt
       and lia.version_id = liaVer
       and lia.line_item_id = e.tgt_line_item_id;

  TYPE signTable is Table of getSigns%ROWTYPE Index By BINARY_INTEGER;
  tmpSign signTable;
  liiSign signTable;

  --Get an aggregated representation of the entry
  --NOTE that because PL/SQL cannot support using field refs
  --in a bulk insert, and since we cannot define the getLines
  --cursor to look exactly like the gcs_entry_lines table,
  --it becomes necessary to use a record of tables that looks
  --like the getLines cursor below (see writeEntry()).
  Type numTab Is Table Of number Index By binary_integer;
  Type varTab Is Table Of varchar2(50) Index By binary_integer;
  Type var240Tab Is Table Of varchar2(240) Index By binary_integer;

  --jh 4.26.04: Added description
  Type lineRec Is Record(
    cctr_org_id    numTab,
    product_id     numTab,
    nat_acct_id    numTab,
    channel_id     numTab,
    project_id     numTab,
    customer_id    numTab,
    interco_id     numTab,
    entity_id      numTab,
    finl_elem_id   numTab,
    line_item_id   numTab,
    task_id        numTab,
    user_dim1_id   numTab,
    user_dim2_id   numTab,
    user_dim3_id   numTab,
    user_dim4_id   numTab,
    user_dim5_id   numTab,
    user_dim6_id   numTab,
    user_dim7_id   numTab,
    user_dim8_id   numTab,
    user_dim9_id   numTab,
    user_dim10_id  numTab,
    balance_factor numTab,
    net_amount     numTab,
    description    var240Tab);

  ccyPrecision   number := -1;
  ccyMinAcctUnit number := null;

  --Changes to this cursor also require changes to lineRec
  --jh 4.26.04: Added  description
  --getLines cursor sums the balances from gcs_entries_gt by
  --first obtain unique source-target lines (t1) then summing
  --the sum

  cursor getLines is
    Select tgt_company_cost_center_org_id cctr_org_id,
           tgt_product_id product_id,
           tgt_natural_account_id nat_acct_id,
           tgt_channel_id channel_id,
           tgt_project_id project_id,
           tgt_customer_id customer_id,
           tgt_intercompany_id interco_id,
           tgt_entity_id entity_id,
           tgt_financial_elem_id finl_elem_id,
           tgt_line_item_id line_item_id,
           tgt_task_id task_id,
           tgt_user_dim1_id user_dim1_id,
           tgt_user_dim2_id user_dim2_id,
           tgt_user_dim3_id user_dim3_id,
           tgt_user_dim4_id user_dim4_id,
           tgt_user_dim5_id user_dim5_id,
           tgt_user_dim6_id user_dim6_id,
           tgt_user_dim7_id user_dim7_id,
           tgt_user_dim8_id user_dim8_id,
           tgt_user_dim9_id user_dim9_id,
           tgt_user_dim10_id user_dim10_id,
           1 balance_factor,
           decode(ccyMinAcctUnit,
                  null,
                  decode(min(sql_statement_num),
                         0,
                         round(min(nvl(output_amount, 0)), ccyPrecision),
                         round(sum(nvl(output_amount, 0)), ccyPrecision)),
                  decode(min(sql_statement_num),
                         0,
                         round(min(nvl(output_amount, 0)) / ccyMinAcctUnit, 0) *
                         ccyMinAcctUnit,
                         round(sum(nvl(output_amount, 0)) / ccyMinAcctUnit, 0) *
                         ccyMinAcctUnit)) net_amount,
           decode(count(unique step_name),
                  1,
                  min(step_name),
                  'MULTIPLE_RULE_STEPS') description

      From (Select min(sql_statement_num) sql_statement_num,
                   min(tgt_company_cost_center_org_id) tgt_company_cost_center_org_id,
                   min(tgt_product_id) tgt_product_id,
                   min(tgt_natural_account_id) tgt_natural_account_id,
                   min(tgt_channel_id) tgt_channel_id,
                   min(tgt_project_id) tgt_project_id,
                   min(tgt_customer_id) tgt_customer_id,
                   min(tgt_intercompany_id) tgt_intercompany_id,
                   min(tgt_entity_id) tgt_entity_id,
                   min(tgt_financial_elem_id) tgt_financial_elem_id,
                   min(tgt_line_item_id) tgt_line_item_id,
                   min(tgt_task_id) tgt_task_id,
                   min(tgt_user_dim1_id) tgt_user_dim1_id,
                   min(tgt_user_dim2_id) tgt_user_dim2_id,
                   min(tgt_user_dim3_id) tgt_user_dim3_id,
                   min(tgt_user_dim4_id) tgt_user_dim4_id,
                   min(tgt_user_dim5_id) tgt_user_dim5_id,
                   min(tgt_user_dim6_id) tgt_user_dim6_id,
                   min(tgt_user_dim7_id) tgt_user_dim7_id,
                   min(tgt_user_dim8_id) tgt_user_dim8_id,
                   min(tgt_user_dim9_id) tgt_user_dim9_id,
                   min(tgt_user_dim10_id) tgt_user_dim10_id,
                   min(nvl(output_amount, 0)) output_amount,
                   min(step_name) step_name
              from gcs_entries_gt
             Where currency_code = contextData.currencyCode
               And output_amount <> 0
             Group By rule_id,
                      step_seq,
                      rule_step_id,
                      src_company_cost_center_org_id,
                      src_product_id,
                      src_natural_account_id,
                      src_channel_id,
                      src_project_id,
                      src_customer_id,
                      src_intercompany_id,
                      src_entity_id,
                      src_financial_elem_id,
                      src_line_item_id,
                      src_task_id,
                      src_user_dim1_id,
                      src_user_dim2_id,
                      src_user_dim3_id,
                      src_user_dim4_id,
                      src_user_dim5_id,
                      src_user_dim6_id,
                      src_user_dim7_id,
                      src_user_dim8_id,
                      src_user_dim9_id,
                      src_user_dim10_id,
                      tgt_company_cost_center_org_id,
                      tgt_product_id,
                      tgt_natural_account_id,
                      tgt_channel_id,
                      tgt_project_id,
                      tgt_customer_id,
                      tgt_intercompany_id,
                      tgt_entity_id,
                      tgt_financial_elem_id,
                      tgt_line_item_id,
                      tgt_task_id,
                      tgt_user_dim1_id,
                      tgt_user_dim2_id,
                      tgt_user_dim3_id,
                      tgt_user_dim4_id,
                      tgt_user_dim5_id,
                      tgt_user_dim6_id,
                      tgt_user_dim7_id,
                      tgt_user_dim8_id,
                      tgt_user_dim9_id,
                      tgt_user_dim10_id) t1
     Group By tgt_company_cost_center_org_id,
              tgt_product_id,
              tgt_natural_account_id,
              tgt_channel_id,
              tgt_project_id,
              tgt_customer_id,
              tgt_intercompany_id,
              tgt_entity_id,
              tgt_financial_elem_id,
              tgt_line_item_id,
              tgt_task_id,
              tgt_user_dim1_id,
              tgt_user_dim2_id,
              tgt_user_dim3_id,
              tgt_user_dim4_id,
              tgt_user_dim5_id,
              tgt_user_dim6_id,
              tgt_user_dim7_id,
              tgt_user_dim8_id,
              tgt_user_dim9_id,
              tgt_user_dim10_id
    Having decode(ccyMinAcctUnit, null, decode(min(sql_statement_num), 0,
                                               round(min(nvl(output_amount, 0)), ccyPrecision),
					       round(sum(nvl(output_amount, 0)), ccyPrecision)),
					decode(min(sql_statement_num), 0,
					       round(min(nvl(output_amount, 0)) / ccyMinAcctUnit, 0) * ccyMinAcctUnit,
					       round(sum(nvl(output_amount, 0)) / ccyMinAcctUnit, 0) * ccyMinAcctUnit)) <> 0;
  /*      Having decode( ccyMinAcctUnit,
    null, round( sum( nvl(output_amount, 0) ), ccyPrecision ),
    round( sum( nvl(output_amount,0) ) / ccyMinAcctUnit, 0 ) * ccyMinAcctUnit
  ) <> 0;*/

  --Bugfix 4925150: Do not execute rules processor if formula evaluates to zero for performance savings
  CURSOR getEvaluatedFormulas(p_ownership_percent NUMBER, p_rule_id NUMBER) IS
    SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(FORMULA_TEXT,
                                                   'ELIMTB',
                                                   1),
                                           'CHILDTB',
                                           1),
                                   'PARTB',
                                   1),
                           '%MI',
                           1 - p_ownership_percent),
                   '%OWN',
                   p_ownership_percent)
      FROM gcs_elim_rule_steps_b
     WHERE rule_id = p_rule_id;

  --+========================================================================+
  -- PACKAGE Private Members
  --+========================================================================+

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Call this for messages you want to see only when debugging the package
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure writeToLog(buf IN Varchar2 := NULL) is
    errBuf Varchar2(5000);
  begin
    errBuf := substr(buf, 1, 5000);
    -- Do nothing if there is no message waiting
    If errBuf IS NOT NULL Then
      While errBuf is not null Loop
        errBuf := substr(errBuf, 251);
      End Loop;
    End If;

  end writeToLog;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- This makes embedding logging calls in the other code less intrusive
  -- and keeps the code more legible.
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure logString(logLevel Number,
                      logProc  Varchar2,
                      logLabel Varchar2,
                      logText  Varchar2) is

    rootString varchar2(100);

    errBuf Varchar2(5000);

    i number(15) := 1;

  begin
    rootString := 'gcs.plsql.GCS_RULE_PROCESSOR.';

    -- May be a message on the stack or
    -- a string passed in via the arg
    if logText IS NULL then
      errBuf := substr(FND_MESSAGE.get, 1, 5000);
    else
      errBuf := substr(logText, 1, 5000);
    end if;

    if logLevel >= runtimeLogLevel then
      FND_LOG.string(logLevel,
                     rootString || logProc || '.' || logLabel,
                     errBuf);
    end if;

    -- STK: Bugfix 6242317
    fnd_file.put_line(fnd_file.log, logText);

  end logString;

  -- changes made by yingliu
  Procedure process_multiparent(p_entry_id IN Number) IS
    -- get the multiple parents elimination entities
    CURSOR c_elim_entities(l_end_date Date) IS
      SELECT fea.dim_attribute_numeric_member elim_entity_id,
             delta_owned,
             gcs_entry_headers_s.nextval,
             geca.currency_code,
             nvl(precision, 2) precision
        FROM gcs_cons_relationships gcr,
             fem_entities_attr      fea,
             gcs_entity_cons_attrs  geca,
             fnd_currencies         fc
       WHERE gcr.hierarchy_id = contextData.hierarchy
         AND gcr.child_entity_id = contextData.childEntity
         AND gcr.actual_ownership_flag = 'N'
         AND l_end_date between gcr.start_date and
             nvl(gcr.end_date, l_end_date)
         AND fea.entity_id = gcr.parent_entity_id
         AND fea.attribute_id =
             gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY')
      .attribute_id
         AND fea.version_id =
             gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ELIMINATION_ENTITY')
      .version_id
         AND geca.hierarchy_id = gcr.hierarchy_id
         AND geca.entity_id = gcr.parent_entity_id
         AND geca.currency_code = fc.currency_code;

    -- get the multiple parents consolidation entities
    CURSOR c_cons_entities(l_end_date Date) IS
      SELECT gcr.parent_entity_id,
             delta_owned,
             gcs_entry_headers_s.nextval,
             geca.currency_code,
             nvl(precision, 2) precision
        FROM gcs_cons_relationships gcr,
             gcs_entity_cons_attrs  geca,
             fnd_currencies         fc
       WHERE gcr.hierarchy_id = contextData.hierarchy
         AND gcr.child_entity_id = contextData.childEntity
         AND gcr.actual_ownership_flag = 'N'
         AND l_end_date between gcr.start_date and
             nvl(gcr.end_date, l_end_date)
         AND geca.hierarchy_id = gcr.hierarchy_id
         AND geca.entity_id = gcr.parent_entity_id
         AND geca.currency_code = fc.currency_code;

    -- get the multiple parents child entities
    CURSOR c_child_entities(l_end_date Date) IS
      SELECT geh.entity_id,
             delta_owned,
             gcs_entry_headers_s.nextval,
             geh.currency_code,
             nvl(precision, 2) precision
        FROM gcs_cons_relationships gcr,
             gcs_entry_headers      geh,
             fnd_currencies         fc
       WHERE gcr.hierarchy_id = contextData.hierarchy
         AND gcr.child_entity_id = contextData.childEntity
         AND gcr.actual_ownership_flag = 'N'
         AND l_end_date between gcr.start_date and
             nvl(gcr.end_date, l_end_date)
         AND geh.entry_id = p_entry_id
         AND geh.currency_code = fc.currency_code;

    -- get the processing calendar period end date
    CURSOR c_get_end_date IS
      SELECT date_assign_value
        FROM fem_cal_periods_attr
       where cal_period_id = contextData.calPeriodId
         AND attribute_id =
             gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
      .attribute_id
         AND version_id =
             gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
      .version_id;

    -- get the ownership percent for the consolidating relationship
    CURSOR c_get_ownership IS
      SELECT ownership_percent
        FROM gcs_cons_relationships
       WHERE cons_relationship_id = contextData.relationship;

    CURSOR c_get_target IS
      SELECT target_entity_code, net_to_re_flag
        FROM gcs_categories_b
       WHERE category_code = contextData.eventCategory;

    l_entities  DBMS_SQL.number_table;
    l_percent   DBMS_SQL.number_table;
    l_precision DBMS_SQL.number_table;
    l_seq       DBMS_SQL.number_table;
    l_currency  DBMS_SQL.varchar2_table;
    l_flag      DBMS_SQL.varchar2_table;

    l_end_date       DATE;
    l_rate_var       NUMBER;
    l_ccyPrecision   NUMBER;
    l_target         VARCHAR2(30);
    l_net_to_re_flag VARCHAR2(1);
    l_owner_percent  NUMBER;
    l_errbuf         VARCHAR2(100);
    l_errcode        NUMBER;

    --Used by the call to GCS_TEMPLATES_DYNAMIC_PKG
    templateRecord GCS_TEMPLATES_PKG.templateRecord;

    procedureName varchar2(30);

  BEGIN
    procedureName := 'PROCESS_MULTIPARENT';

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    OPEN c_get_end_date;
    FETCH c_get_end_date
      INTO l_end_date;
    CLOSE c_get_end_date;

    OPEN c_get_ownership;
    FETCH c_get_ownership
      INTO l_owner_percent;
    CLOSE c_get_ownership;

    OPEN c_get_target;
    FETCH c_get_target
      INTO l_target, l_net_to_re_flag;
    CLOSE c_get_target;

    IF l_target = 'CHILD' THEN
      OPEN c_child_entities(l_end_date);
      FETCH c_child_entities BULK COLLECT
        INTO l_entities, l_percent, l_seq, l_currency, l_precision;
      CLOSE c_child_entities;
    ELSIF l_target = 'ELIMINATION' THEN
      OPEN c_elim_entities(l_end_date);
      FETCH c_elim_entities BULK COLLECT
        INTO l_entities, l_percent, l_seq, l_currency, l_precision;
      CLOSE c_elim_entities;
    ELSIF l_target = 'CONSOLIDATION' THEN
      OPEN c_cons_entities(l_end_date);
      FETCH c_cons_entities BULK COLLECT
        INTO l_entities, l_percent, l_seq, l_currency, l_precision;
      CLOSE c_cons_entities;
    ELSE
      RAISE invalid_category_code;
    END IF;

    --Bugfix 4122843 : Check if l_currency is not zero
    IF (l_currency.COUNT <> 0) THEN
      FOR i IN l_currency.first .. l_currency.last LOOP
        gcs_utility_pkg.get_conversion_rate(P_Source_Currency => contextData.CurrencyCode,
                                            P_Target_Currency => l_currency(i),
                                            p_cal_period_Id   => contextData.calPeriodId,
                                            p_conversion_rate => l_rate_var,
                                            P_errbuf          => l_errbuf,
                                            p_errcode         => l_errcode);
        l_percent(i) := l_rate_var * l_percent(i) / (100 - l_owner_percent);
        IF (l_errcode = 2) THEN
          l_flag(i) := 'X';
        ELSE
          l_flag(i) := 'N';
        END IF;
      END LOOP;
    END IF;

    IF (l_entities.COUNT <> 0) THEN
      FORALL i IN l_entities.first .. l_entities.last
        INSERT INTO gcs_entry_headers
          (ENTRY_ID,
           ENTRY_NAME,
           HIERARCHY_ID,
           DISABLED_FLAG,
           ENTITY_ID,
           CURRENCY_CODE,
           BALANCE_TYPE_CODE,
           START_CAL_PERIOD_ID,
           END_CAL_PERIOD_ID,
           YEAR_TO_APPLY_RE,
           DESCRIPTION,
           ENTRY_TYPE_CODE,
           ASSOC_ENTRY_ID,
           CATEGORY_CODE,
           PROCESS_CODE,
           SUSPENSE_EXCEEDED_FLAG,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           PERIOD_INIT_ENTRY_FLAG,
           RULE_ID,
           PROCESSED_RUN_NAME)
          SELECT l_seq(i),
                 l_seq(i),
                 HIERARCHY_ID,
                 DISABLED_FLAG,
                 l_entities(i),
                 l_currency(i),
                 BALANCE_TYPE_CODE,
                 START_CAL_PERIOD_ID,
                 END_CAL_PERIOD_ID,
                 YEAR_TO_APPLY_RE,
                 DESCRIPTION,
                 'MULTIPLE_PARENTS',
                 p_entry_id,
                 CATEGORY_CODE,
                 PROCESS_CODE,
                 DECODE(SUSPENSE_EXCEEDED_FLAG, 'Y', 'Y', l_flag(i)),
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 PERIOD_INIT_ENTRY_FLAG,
                 ruleId,
                 contextData.runName
            FROM gcs_entry_headers
           WHERE entry_id = p_entry_id;

      FORALL i IN l_entities.first .. l_entities.last
        INSERT INTO gcs_entry_lines
          (ENTRY_ID,
           LINE_TYPE_CODE,
           DESCRIPTION,
           COMPANY_COST_CENTER_ORG_ID,
           FINANCIAL_ELEM_ID,
           PRODUCT_ID,
           NATURAL_ACCOUNT_ID,
           CHANNEL_ID,
           LINE_ITEM_ID,
           PROJECT_ID,
           CUSTOMER_ID,
           INTERCOMPANY_ID,
           TASK_ID,
           USER_DIM1_ID,
           USER_DIM2_ID,
           USER_DIM3_ID,
           USER_DIM4_ID,
           USER_DIM5_ID,
           USER_DIM6_ID,
           USER_DIM7_ID,
           USER_DIM8_ID,
           USER_DIM9_ID,
           USER_DIM10_ID,
           XTD_BALANCE_E,
           YTD_BALANCE_E,
           PTD_DEBIT_BALANCE_E,
           PTD_CREDIT_BALANCE_E,
           YTD_DEBIT_BALANCE_E,
           YTD_CREDIT_BALANCE_E,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN)
          SELECT l_seq(i),
                 LINE_TYPE_CODE,
                 DESCRIPTION,
                 COMPANY_COST_CENTER_ORG_ID,
                 FINANCIAL_ELEM_ID,
                 PRODUCT_ID,
                 NATURAL_ACCOUNT_ID,
                 CHANNEL_ID,
                 LINE_ITEM_ID,
                 PROJECT_ID,
                 CUSTOMER_ID,
                 INTERCOMPANY_ID,
                 TASK_ID,
                 USER_DIM1_ID,
                 USER_DIM2_ID,
                 USER_DIM3_ID,
                 USER_DIM4_ID,
                 USER_DIM5_ID,
                 USER_DIM6_ID,
                 USER_DIM7_ID,
                 USER_DIM8_ID,
                 USER_DIM9_ID,
                 USER_DIM10_ID,
                 NULL,
                 round(nvl(YTD_BALANCE_E, 0) * l_percent(i) * -1,
                       l_precision(i)),
                 NULL,
                 NULL,
                 round(nvl(YTD_CREDIT_BALANCE_E, 0) * l_percent(i),
                       l_precision(i)),
                 round(nvl(YTD_DEBIT_BALANCE_E, 0) * l_percent(i),
                       l_precision(i)),
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN
            FROM gcs_entry_lines
           WHERE entry_id = p_entry_id;

      --Get the template record together
      templateRecord.FINANCIAL_ELEM_ID  := suspenseData.financial_elem_id;
      templateRecord.PRODUCT_ID         := suspenseData.product_id;
      templateRecord.NATURAL_ACCOUNT_ID := suspenseData.natural_account_id;
      templateRecord.CHANNEL_ID         := suspenseData.channel_id;
      templateRecord.LINE_ITEM_ID       := suspenseData.line_item_id;
      templateRecord.PROJECT_ID         := suspenseData.project_id;
      templateRecord.CUSTOMER_ID        := suspenseData.customer_id;
      templateRecord.TASK_ID            := suspenseData.task_id;
      templateRecord.USER_DIM1_ID       := suspenseData.user_dim1_id;
      templateRecord.USER_DIM2_ID       := suspenseData.user_dim2_id;
      templateRecord.USER_DIM3_ID       := suspenseData.user_dim3_id;
      templateRecord.USER_DIM4_ID       := suspenseData.user_dim4_id;
      templateRecord.USER_DIM5_ID       := suspenseData.user_dim5_id;
      templateRecord.USER_DIM6_ID       := suspenseData.user_dim6_id;
      templateRecord.USER_DIM7_ID       := suspenseData.user_dim7_id;
      templateRecord.USER_DIM8_ID       := suspenseData.user_dim8_id;
      templateRecord.USER_DIM9_ID       := suspenseData.user_dim9_id;
      templateRecord.USER_DIM10_ID      := suspenseData.user_dim10_id;

      FOR i IN l_entities.first .. l_entities.last LOOP

        IF (l_net_to_re_flag = 'Y') THEN
          BEGIN
            GCS_TEMPLATES_DYNAMIC_PKG.calculate_re(p_entry_id      => l_seq(i),
                                                   p_hierarchy_id  => contextData.hierarchy,
                                                   p_bal_type_code => 'ACTUAL',
                                                   p_entity_id     => l_entities(i));
          EXCEPTION
            WHEN OTHERS THEN
              logString(exceptionLogLevel,
                        procedureName,
                        'exception',
                        'templates_pkg_error');
              logString(exceptionLogLevel,
                        procedureName,
                        'exception',
                        'procedure "calculate_re" fail');
              logString(exceptionLogLevel,
                        procedureName,
                        'exception',
                        null);
              RAISE templates_pkg_error;
          END;
        END IF;

        BEGIN
          GCS_TEMPLATES_DYNAMIC_PKG.balance(p_entry_id                => l_seq(i),
                                            p_template                => templateRecord,
                                            p_bal_type_code           => 'ACTUAL',
                                            p_hierarchy_id            => contextData.hierarchy,
                                            p_entity_id               => l_entities(i),
                                            p_threshold               => suspenseData.threshold_amount,
                                            p_threshold_currency_code => suspenseData.threshold_currency);
        EXCEPTION
          WHEN OTHERS THEN
            logString(exceptionLogLevel,
                      procedureName,
                      'exception',
                      'templates_pkg_error');
            logString(exceptionLogLevel,
                      procedureName,
                      'exception',
                      'procedure "balance" fail');
            logString(exceptionLogLevel, procedureName, 'exception', null);
            RAISE templates_pkg_error;
        END;
      END LOOP;

    END IF; --check entity count;

    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

  END process_multiparent;
  -- end of changes by yingliu

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- This procedure initializes a bunch of hash tables for use throughout
  -- the package.  To wit...
  --   A vc2 table with the various FROM and WHERE clauses for the dynamic
  --      SQL used to execute the formulas.
  --   A cursor%rowtype table with dimension info used to construct
  --      insert, select and from expressions dynamically.
  --
  -- It also gets the application group and global value set combination.
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure initRefTables is

    procedureName varchar2(30);

    -- FEM procedures use these
    errCount Number := 0;

    i Varchar2(30);

  begin
    procedureName := 'INIT_REF_TABLES';

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    --Fill the stmt array
    stmts.DELETE;
    Open getStmts(contextData.eventType);
    Fetch getStmts Bulk Collect
      Into stmts;
    Close getStmts;

    If nvl(stmts.COUNT, 0) = 0 Then
      RAISE invalid_gcs_setup;
    End if;

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '1');
    --=======================================================

    dimInfo.DELETE;
    dimInfo := GCS_UTILITY_PKG.g_gcs_dimension_info;
    If dimInfo.COUNT > 0 Then
      i := dimInfo.FIRST;
      While i IS NOT NULL Loop
        --We do not want to include some dims in the dynamic sql used here.
        --The dynamic sql processes the dims elligible for inclusion in
        --dim_sets, regardless of whether a particular dim_set uses them,
        --plus the cctr_org and the interco dims. All others can go away.
        if dimInfo(i).column_name in ('DATASET_CODE',
                           'CAL_PERIOD_ID',
                           'LEDGER_ID',
                           'SOURCE_SYSTEM_CODE',
                           'ENTITY_ID') then
          dimInfo.DELETE(i);
        else
          logString(statementLogLevel,
                    procedureName,
                    'dimension',
                    'Name, ID, FEM?, GCS? = ' || dimInfo(i)
                    .column_name || ', ' || to_char(dimInfo(i).dimension_id) || ', ' ||
                     dimInfo(i).required_for_fem || ', ' || dimInfo(i)
                    .required_for_gcs);
        end if;
        i := dimInfo.NEXT(i);
      End Loop; --While i IS NOT NULL

    End If;

    --jh 4.26.04. Check for dims after system-oriented dims have been deleted.
    If dimInfo.COUNT = 0 Then
      RAISE invalid_fem_setup;
    end if;

    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

  end initRefTables;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Writes the incoming parameter values to the database log
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure logParameterValues is

    --This proc is here just so the process_rule proc is not
    --cluttered with these lines of logging calls
    procedureName varchar2(30);

  begin
    procedureName := 'PROCESS_RULE';

    --NOTE: Blowing off the usual procedure-level log (begin and end messages)
    --      here, since the entire thing just writes log entries and will only
    --      even be visible if statement-level logging is enabled anyway.
    --      That is also why the procedure_name here is defined as process_rule
    --      and not as logparameterValues.

    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Rule ID              = ' || to_char(ruleId));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              '%FROM Value          = ' || to_char(ruleData.fromPercent));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              '%TO Value            = ' || to_char(ruleData.toPercent));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              '%OWN Value           = ' || to_char(ruleData.toPercent));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Consideration Amount = ' || to_char(ruleData.consideration));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Fair Market Value    = ' || to_char(ruleData.netAssetValue));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Event Type           = ' || contextData.eventType);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Event Key            = ' || to_char(contextData.eventKey));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Parent Entity        = ' ||
              to_char(contextData.parentEntity));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Child Entity         = ' || to_char(contextData.childEntity));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Eliminations Entity  = ' || to_char(contextData.elimsEntity));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Dataset Code         = ' || to_char(contextData.datasetCode));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Relationship         = ' ||
              to_char(contextData.relationship));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Hierarchy            = ' || to_char(contextData.hierarchy));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Calendar Period Id   = ' || to_char(contextData.calPeriodId));
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Currency Code        = ' || contextData.currencyCode);

  end logParameterValues;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Construct a set of join conditions in the following style...
  --    AND   left.column_name = right.column_name
  --
  -- This procedure uses the dimInfo hash table.
  --
  -- This "plain vanilla" string can be manipulated to use whatever table
  -- aliases are appropriate to the stmts( stmt ).sql_statement.
  --
  -- See execFormulas for how this is used.
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure modelJoinClause is

    procedureName varchar2(30);
    i             varchar2(30);

  begin
    procedureName := 'MODEL_JOIN_CLAUSE';

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    modJoinClause := null;
    i             := dimInfo.FIRST;
    While i IS NOT NULL Loop
      if dimInfo(i).required_for_gcs = 'Y' then
        modJoinClause := modJoinClause || '
AND   left.' || rpad(dimInfo(i).column_name, 30) ||
                         ' = right.' || dimInfo(i).column_name;
      end if;
      i := dimInfo.NEXT(i);
    End Loop;

    -- Show the statement in the logfile
    logString(statementLogLevel,
              procedureName,
              'stmt',
              'Model Join Clause = ' || modJoinClause);

    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

  end modelJoinClause;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Initialize data in the GCS_ENTRIES_GT table by creating source and
  -- target dimensions, and setting related "friendly" data like names, formula.
  --
  -- FOR TARGET-ONLY dimension sets: see proc initEntriesGT_tgtDimSet elsewhere.
  --
  -- FOR STANDARD dimension sets:
  --
  -- The SQL stmt used to init the gcs_entries_gt table looks like...
  --
  --    INSERT INTO GCS_ENTRIES_GT (
  --        rule_id, step_seq, formula_text,
  --        ad_input_amount, pe_input_amount, ce_input_amount, ee_input_amount,
  --        output_amount,
  --        <src_dimensions>,
  --        <tgt_dimensions>)
  --    SELECT :rid, :seq, :ftx,
  --           0, 0,
  --           <b.source_dimension_columns>,
  --           <d.target_dimension_expressions>
  --    FROM  fem_balances b,
  --          gcs_rule_scope_dims d
  --    WHERE b.source_dimension_columns =
  --          (select t.source_member_id
  --           from   gcs_rule_scope_dtls t
  --           where  t.rule_step_id = :rsi) ;
  --
  --
  -- For the cctr_org and interco dimensions, the target value is always
  -- copied from the source value.  For the other dimensions, the target
  -- expressions are based on whether...
  --  a) ...the target template is a value
  --        then use the target's value as a constant
  --
  --  b) ...the target template is NULL
  --        then use the source's same-dimension value
  --
  -- An expression in the form of...
  --  decode( <xdim>,
  --          NULL,  l.src_<xdim>,
  --          <xdim>)
  -- ...is constructed for each selected dimension in the dim set.
  --
  --    This procedure makes use of expression strings created elsewhere...
  --
  --     selColumnList: has expressions in the form ', b.<xdim>' for
  --                    the current dim set id (see resolveDimSet)
  --     srcColumnList: created here as replace(selColumnList,', b.',', src_')
  --                    so if the selColumnList = b.moe, b.larry, b.curly then
  --                    the srcColumnList would come out as src_moe, src_larry,
  --                    src_curly.
  --     tgtColumnList: created here as replace(selColumnList,', b.',', tgt_')
  --                    so if the selColumnList = b.moe, b.larry, b.curly then
  --                    the tgtColumnList would come out as tgt_moe, tgt_larry,
  --                    tgt_curly.
  --     insColumnList: has expressions in the form ', <xdim>' for
  --                    the current dim set id (see resolveDimSet)
  --     adtColumnList: has expressions in the form 'AND  E.<xdim> = B.<xdim>'
  --                    for the join condition to gcs_ad_trial_balances.
  --
  -- NOTE: Abbreviations used for bind vars here...
  --       ccy = currency code id   contextData.currencyCode
  --       dci = dataset code       contextData.datasetCode
  --       dsi = dim set id         dimSetId (private global variable)
  --       dsn = dim set name       dimSets(dsi).dimension_set_name
  --       dst = dim set type       dimSets(dsi).dimension_set_type_code
  --       eid = entity id          contextData.elimsEntity
  --       ftx = formula text       dimSet(dsi).formula_text
  --       seq = step sequence      stepSeq (procedure argument)
  --       rid = rule id            stepData(seq).rule_id
  --       rsi = rule step id            stepData(seq).rule_step_id
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure initEntriesGT_stdDimSet(stepSeq      IN NUMBER,
                                    categoryInfo IN getCategory%ROWTYPE) is

    procedureName varchar2(30);
    entriesStmt   varchar2(20000);
    oEntriesStmt  varchar2(20000);
    whereClause   varchar2(5000);
    tgtDimStmt    varchar2(5000);
    oTgtDimStmt   varchar2(5000);
    fromList      varchar2(2500);
    i             varchar2(30);
    j             number;
    orgId         number := -1;
    intercoId     number := -1;
    tgtOrg        varchar2(100);
    cEntityType   varchar2(2); --whether child entity is operating or consolidation
    offsetFlag    varchar2(2); --whether to create an offset line or not.

    -- changes made by yingliu:
    /*
          cursor getSpecificIntercoId is
            SELECT SPECIFIC_INTERCOMPANY_ID
            FROM   GCS_HIERARCHIES_B
            WHERE  hierarchy_id = contextData.hierarchy;
    */
    cursor getSpecificIntercoId is
      SELECT SPECIFIC_INTERCOMPANY_ID
        FROM GCS_CATEGORIES_B
       WHERE CATEGORY_CODE = 'INTRACOMPANY';
    -- end of change by yingliu

    cursor getChildEntityType is
      SELECT dim_attribute_varchar_member
        FROM FEM_ENTITIES_ATTR
       WHERE entity_id = nvl(contextData.childEntity, -1)
         AND attribute_id =
             GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE')
      .attribute_id
         AND version_id =
             GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE')
      .version_id
         AND value_set_id =
             GCS_UTILITY_PKG.g_gcs_dimension_info('ENTITY_ID')
      .associated_value_set_id;

  begin
    procedureName := 'INIT_ENTRIESGT_STD_DIMSET';
    tgtOrg        := '';

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    --Global states may persist since last time we did this, so reset them
    selColumnList := null;
    adtColumnList := null;
    j             := 0;
    offsetFlag    := 'N';

    i := dimInfo.FIRST;
    While i IS NOT NULL Loop

      --HANDLE DIM_SET_DIMS DIFFERENTLY THAN OTHER GCS DIMS: by looping
      --through the dimInfo array and using the index there in the
      --selectDims array, when we hit a dim that is not selected for
      --this Dim Set a no_data_found is thrown. The body of this nested
      --block handles selectDims columns while the no_data_found handler
      --handles the non-selectDims columns.
      BEGIN

        --select and insert expressions
        selColumnList := selColumnList || ',
  b.' || selectDims(i).column_name;

        IF contextData.eventType = 'A' THEN
          adtColumnList := adtColumnList || '
      AND    e.src_' || selectDims(i)
                          .column_name || ' = b.' || selectDims(i)
                          .column_name;
        END IF; -- IF contextData.eventType = 'A' THEN

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- Tag the insert and select lists with active-not-selected dims
          if dimInfo(i).required_for_gcs = 'Y' then
            selColumnList := selColumnList || ',
  b.' || dimInfo(i).column_name;

            IF contextData.eventType = 'A' THEN
              adtColumnList := adtColumnList || '
      AND    e.src_' || dimInfo(i)
                              .column_name || ' = b.' || dimInfo(i)
                              .column_name;
            END IF; -- IF contextData.eventType = 'A' THEN

          end if;

      END;

      i := dimInfo.NEXT(i);

    End Loop; --While i IS NOT NULL Loop

    -- Set up a target expression list using the source list created
    -- in resolveDimSet above
    logString(statementLogLevel,
              procedureName,
              'stmt',
              'selColumnList = ' || selColumnList);

    IF contextData.eventType = 'A' THEN
      logString(statementLogLevel,
                procedureName,
                'stmt',
                'adtColumnList = ' || adtColumnList);
    END IF; --IF contextData.eventType = 'A' THEN

    srcColumnList := replace(selColumnList, 'b.', 'src_');
    logString(statementLogLevel,
              procedureName,
              'stmt',
              'srcColumnList = ' || srcColumnList);

    tgtColumnList := replace(selColumnList, 'b.', 'tgt_');
    logString(statementLogLevel,
              procedureName,
              'stmt',
              'tgtColumnList = ' || tgtColumnList);

    --find out if child entity is a consolidation entity.
    Open getChildEntityType;
    Fetch getChildEntityType
      INTO cEntityType;

    If getChildEntityType%NOTFOUND then
      cEntityType := 'N'; --set entity_type to 'N' for none
    End if;

    Close getChildEntityType;

    logString(statementLogLevel,
              procedureName,
              'parameter',
              'child entity type = ' || cEntityType);

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '2');
    --=======================================================

    -- Start the statement
    entriesStmt := 'INSERT INTO GCS_ENTRIES_GT (
rule_id, step_seq, step_name, formula_text, rule_step_id, offset_flag,
sql_statement_num, currency_code, ad_input_amount, pe_input_amount,
ce_input_amount, ee_input_amount, output_amount, entity_id,
ytd_credit_balance_e, ytd_debit_balance_e' ||
                   srcColumnList || tgtColumnList || ')
SELECT DISTINCT :rid, :seq, :sna, :ftx, :rsi, :osf, :stn, b.currency_code,
       0, 0, 0, 0, 0,
  b.entity_id,
  b.ytd_credit_balance_e,
  b.ytd_debit_balance_e' || selColumnList;

    whereClause := '
AND  ( b.entity_id in ( :pid, :cid )
OR   ( b.entity_id = :eid
       AND b.COMPANY_COST_CENTER_ORG_ID IN(
         SELECT o.company_cost_center_org_id
         FROM   GCS_ENTITY_CCTR_ORGS o
         WHERE  ( o.entity_id = :cid';

    --If child is a consolidation entity, then look for org's of its children.
    IF (cEntityType = 'C') THEN
      whereClause := whereClause || '
               OR
               o.entity_id IN(
               SELECT r.child_entity_id
	       FROM   GCS_CONS_RELATIONSHIPS r
	       START WITH  r.parent_entity_id = :cid
               AND    r.hierarchy_id = :hid
               AND    r.actual_ownership_flag = ''Y''
	       AND    ( sysdate BETWEEN r.start_date
			        AND NVL(r.end_date, sysdate))
	       CONNECT BY  prior r.child_entity_id = r.parent_entity_id
               AND    r.hierarchy_id = :hid
               AND    r.actual_ownership_flag = ''Y''
               AND   ( sysdate BETWEEN r.start_date
		         AND NVL(r.end_date, sysdate)))';
    END IF; --IF (l_entity_type= 'C')
    whereClause := whereClause || '
               ))))';

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '3');
    --=======================================================

    -- Add the selected dim target expressions
    i           := dimInfo.FIRST;
    tgtDimStmt  := '';
    oTgtDimStmt := '';
    fromList    := '';

    While i IS NOT NULL Loop

      --Handle the dim_set_dims differently: by looping through the dimInfo
      --array and using the index there in the selectDims array, when we hit
      --a dim that is not selected for this Dim Set a no_data_found is thrown.
      --The body of this nested block handles selectDims columns while the
      --no_data_found handler handles the non-selectDims columns.

      BEGIN
        j := j + 1;

        --jh 10.19.04: add all-source-member support

        IF selectDims(i).all_source_members_flag = 'Y' THEN

          IF selectDims(i).target_member_id IS NULL THEN
            tgtDimStmt := tgtDimStmt || ',
b.' || selectDims(i).column_name;

            oTgtDimStmt := oTgtDimStmt || ',
b.' || selectDims(i).column_name;

          ELSE
            tgtDimStmt := tgtDimStmt || ',
' || selectDims(i).TARGET_MEMBER_ID;

            IF selectDims(i).offset_member_id IS NOT NULL THEN
              oTgtDimStmt := oTgtDimStmt || ',
' || selectDims(i).OFFSET_MEMBER_ID;
            ELSE
              oTgtDimStmt := oTgtDimStmt || ',
' || selectDims(i).TARGET_MEMBER_ID;
            END IF; --IF selectDims(i).offset_member_id IS NOT NULL THEN

          END IF; --IF selectDims(i).target_member_id IS NULL THEN

        ELSE
          IF selectDims(i).target_member_id IS NULL THEN
            tgtDimStmt := tgtDimStmt || ',
b.' || selectDims(i).column_name;

            oTgtDimStmt := oTgtDimStmt || ',
b.' || selectDims(i).column_name;

          ELSE
            tgtDimStmt := tgtDimStmt || ',
' || selectDims(i).TARGET_MEMBER_ID;

            IF selectDims(i).offset_member_id IS NOT NULL THEN
              oTgtDimStmt := oTgtDimStmt || ',
' || selectDims(i).OFFSET_MEMBER_ID;
            ELSE
              oTgtDimStmt := oTgtDimStmt || ',
' || selectDims(i).TARGET_MEMBER_ID;
            END IF; --IF selectDims(i).offset_member_id IS NOT NULL THEN

          END IF; --IF selectDims(i).target_member_id IS NULL THEN

          fromList := fromList || ',
GCS_RULE_SCOPE_DTLS D' || j;

          /*
                      whereClause := whereClause || '
          AND  ((b.' || selectDims(i).column_name || '  = D' || j || '.source_member_id
                AND   D' || j || '.rule_step_id = ' || selectDims(i).rule_step_id ||'
                AND   D' || j || '.column_name  = ''' || selectDims(i).column_name ||''')';
          */

          --jh 08.04.04: Bug 3802514
          IF selectDims(i).hierarchy_obj_id is null THEN
            --              whereClause  := whereClause || ')';
            whereClause := whereClause || '
AND  (b.' || selectDims(i).column_name || '  = D' || j ||
                           '.source_member_id';
          ELSE
            whereClause := whereClause || '
AND  b.' || selectDims(i)
                          .column_name || ' IN (
      SELECT h.child_id
      FROM ' || selectDims(i).hierarchy_table_name || ' h
      WHERE h.hierarchy_obj_def_id = ' ||
                           selectDims(i).hierarchy_obj_id || '
      AND   h.parent_value_set_id  = ' ||
                           dimInfo(i).associated_value_set_id || '
      AND   h.child_value_set_id = h.parent_value_set_id
      AND   h.parent_id = D' || j ||
                           '.source_member_id';

          END IF; --if selectDims(r).hierarchy_object IS NULL then

          whereClause := whereClause || '
      AND   D' || j || '.rule_step_id = ' ||
                         selectDims(i)
                        .rule_step_id || '
      AND   D' || j || '.column_name  = ''' ||
                         selectDims(i).column_name || ''')';

        END IF; --IF selectDims(i).all_source_members_flag = 'Y' THEN

        --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        -- Offset Support (11/1/04)
        -- For each rule scope, the user should be able to define a set
        -- of TARGET dimensions to place the result of the formula, and a
        -- set of OFFSET dimensions to place the (-1) if the result.
        -- Note
        -- The variables used here are :
        --    offsetFlag:       Whether an offset should be created. This
        --                      variable is updated to "Y" when any active
        --                      dimensions has an offset dimension specified.
        --    oTgtDimStmt:      Offset target dimensions.
        --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        IF selectDims(i).offset_member_id IS NOT NULL THEN
          offsetFlag := 'Y';
        END IF; --IF selectDims(i).offset_member_id IS NOT NULL THEN

      EXCEPTION
        WHEN NO_DATA_FOUND THEN

          if dimInfo(i).required_for_gcs = 'Y' then

            --See bug 3710985 for details on how cctr and
            --interco values are determined (jh 06.29.04)
            --JH 7.28.94: use categoryInfo.entityId to get base_org (3798215)
            if dimInfo(i).column_name = cctr_column then
              if categoryInfo.org_output_code = 'BASE_ORG' then
                orgId := GCS_UTILITY_PKG.get_org_id(categoryInfo.entityId,
                                                    contextData.hierarchy);
                if orgId = -1 then
                  logString(exceptionLogLevel,
                            procedureName,
                            'bind',
                            'categoryInfo.entityId  => ' ||
                            to_char(categoryInfo.entityId));
                  logString(exceptionLogLevel,
                            procedureName,
                            'bind',
                            'contextData.hierarchy    => ' ||
                            to_char(contextData.hierarchy));
                  RAISE no_default_cctr_found;
                end if; --if orgId = -2

                tgtOrg := to_char(orgId);

                --jh 11.05.04: add CHILD_BASE_ORG
              elsif categoryInfo.org_output_code = 'CHILD_BASE_ORG' then
                orgId := GCS_UTILITY_PKG.get_org_id(contextData.childEntity,
                                                    contextData.hierarchy);
                if orgId = -1 then
                  logString(exceptionLogLevel,
                            procedureName,
                            'bind',
                            'categoryInfo.entityId  => ' ||
                            to_char(contextData.childEntity));
                  logString(exceptionLogLevel,
                            procedureName,
                            'bind',
                            'contextData.hierarchy    => ' ||
                            to_char(contextData.hierarchy));
                  RAISE no_default_cctr_found;
                end if; --if orgId = -2

                tgtOrg := to_char(orgId);

              elsif categoryInfo.org_output_code = 'SAME_AS_SOURCE' then
                tgtOrg := 'b.' || dimInfo(i).column_name;

              end if; --if categoryInfo.org_output_code='BASE_ORG'

              tgtDimStmt := tgtDimStmt || ',
    ' || tgtOrg;

              oTgtDimStmt := oTgtDimStmt || ',
    ' || tgtOrg;

            elsif dimInfo(i).column_name = interco_column THEN

              -- changes made by yingliu
              /*
                            if categoryInfo.interco_output_code ='SPECIFIC_VALUE' then
                              Open getSpecificIntercoId;
                              Fetch getSpecificIntercoId into intercoId;
                              Close getSpecificIntercoId;

                              if intercoId = -1 then
                                logString( exceptionLogLevel,  procedureName, 'bind',
                                       'contextData.childEntity  => ' || to_char(contextData.childEntity));
                                logString( exceptionLogLevel,  procedureName, 'bind',
                                       'contextData.hierarchy    => ' || to_char(contextData.hierarchy));
                                logString( exceptionLogLevel,  procedureName, 'bind',
                                       'contextData.relationship => ' || contextData.relationship);
                              RAISE no_default_cctr_found;
                              end if; -- if intercoId = -1

                              tgtDimStmt := tgtDimStmt || ',
                    ' || to_char(intercoId);

                              oTgtDimStmt := oTgtDimStmt || ',
                    ' || to_char(intercoId);

                            elsif categoryInfo.interco_output_code ='SAME_AS_TARGET_ORG' then
                              tgtDimStmt := tgtDimStmt || ',
                    ' || tgtOrg;

                              oTgtDimStmt := oTgtDimStmt || ',
                    ' || tgtOrg;

                            elsif categoryInfo.interco_output_code ='SAME_AS_SOURCE_ORG' then

                              tgtDimStmt := tgtDimStmt || ',
                    b.' || cctr_column;

                              oTgtDimStmt := oTgtDimStmt || ',
                    b.' || cctr_column;

                            elsif categoryInfo.interco_output_code ='SAME_AS_SOURCE' then

                              tgtDimStmt := tgtDimStmt || ',
                    b.' || dimInfo(i).column_name;

                              oTgtDimStmt := oTgtDimStmt || ',
                    b.' || dimInfo(i).column_name;
                            end if; --categoryInfo.interco_output_code ='SPECIFIC_VALUE'
              */
              Open getSpecificIntercoId;
              Fetch getSpecificIntercoId
                into intercoId;
              Close getSpecificIntercoId;

              IF intercoId IS NULL THEN
                IF categoryInfo.org_output_code = 'CHILD_BASE_ORG' THEN
                  orgId := GCS_UTILITY_PKG.get_org_id(contextData.childEntity,
                                                      contextData.hierarchy);
                  IF orgId = -1 then
                    logString(exceptionLogLevel,
                              procedureName,
                              'bind',
                              'contextData.childEntity  => ' ||
                              to_char(contextData.childEntity));
                    logString(exceptionLogLevel,
                              procedureName,
                              'bind',
                              'contextData.hierarchy    => ' ||
                              to_char(contextData.hierarchy));
                    RAISE no_default_cctr_found;
                  END if; --if orgId = -1

                ELSE
                  orgId := GCS_UTILITY_PKG.get_org_id(categoryInfo.entityId,
                                                      contextData.hierarchy);
                  IF orgId = -1 then
                    logString(exceptionLogLevel,
                              procedureName,
                              'bind',
                              'categoryInfo.entityId  => ' ||
                              to_char(categoryInfo.entityId));
                    logString(exceptionLogLevel,
                              procedureName,
                              'bind',
                              'contextData.hierarchy    => ' ||
                              to_char(contextData.hierarchy));
                    RAISE no_default_cctr_found;
                  END if; --if orgId = -1

                END IF; --IF categoryInfo.org_output_code='CHILD_BASE_ORG'

                tgtDimStmt := tgtDimStmt || ',
      ' || to_char(orgId);

                oTgtDimStmt := oTgtDimStmt || ',
      ' || to_char(orgId);

              ELSE
                tgtDimStmt  := tgtDimStmt || ',
      ' || to_char(intercoId);
                oTgtDimStmt := oTgtDimStmt || ',
      ' || to_char(intercoId);
              END IF; --IF intercoId IS NULL THEN

              -- end of changes by yingliu
            else

              tgtDimStmt := tgtDimStmt || ',
      b.' || dimInfo(i).column_name;

              oTgtDimStmt := oTgtDimStmt || ',
      b.' || dimInfo(i).column_name;
            end if; --dimInfo(i).column_name = cctr_column

          END IF; --dimInfo(i).required_for_gcs  = 'Y'
      END;
      i := dimInfo.NEXT(i);

    End Loop; --While i IS NOT NULL
    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '4');
    --=======================================================

    -- Add the FROM and WHERE clauses
    entriesStmt := entriesStmt || tgtDimStmt || '
FROM  fem_balances b ' || fromList || '
WHERE b.dataset_code  = :dci
AND   b.cal_period_id = :cpi
AND   b.currency_code IN (:ccy, ''STAT'')' || whereClause;

    ruleStepId := stepData(stepSeq).rule_step_id;

    -- Execute the stmt
    logString(statementLogLevel,
              procedureName,
              'bind',
              'rid = ' || to_char(stepData(stepSeq).rule_id));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'seq = ' || to_char(stepSeq));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'sna = ' || stepData(stepSeq).step_name);
    logString(statementLogLevel,
              procedureName,
              'bind',
              'ftx = ' || stepData(stepSeq).formula_text);
    logString(statementLogLevel,
              procedureName,
              'bind',
              'rsi = ' || to_char(stepData(stepSeq).rule_step_id));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'stn = ' || to_char(stepData(stepSeq).sql_statement_num));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'dci = ' || to_char(contextData.datasetCode));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'cpi = ' || to_char(contextData.calPeriodId));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'ccy = ' || contextData.currencyCode);
    logString(statementLogLevel,
              procedureName,
              'bind',
              'pid = ' || to_char(contextData.parentEntity));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'cid = ' || to_char(contextData.childEntity));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'eid = ' || to_char(contextData.elimsEntity));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'hid = ' || to_char(contextData.hierarchy));

    --Consolidation rule
    IF contextData.eventType = 'C' THEN

      -- Show the statement in the logfile
      logString(statementLogLevel,
                procedureName,
                'stmt',
                'entriesStmt = ' || entriesStmt);

      --=======================================================
      logString(eventLogLevel, procedureName, 'section', '5');
      --=======================================================
      IF (cEntityType = 'C') THEN
        EXECUTE IMMEDIATE entriesStmt
          USING stepData(stepSeq).rule_id,
	        stepSeq,
		stepData(stepSeq).step_name,
		stepData(stepSeq).formula_text,
		ruleStepId,
		'N',
		stepData(stepSeq).sql_statement_num,
		contextData.datasetCode,
		contextData.calPeriodId,
		contextData.currencyCode,
		nvl(contextData.parentEntity, -1),
		nvl(contextData.childEntity, -1),
		nvl(contextData.elimsEntity, -1),
		nvl(contextData.childEntity, -1),
		nvl(contextData.childEntity, -1),
		contextData.hierarchy,
		contextData.hierarchy;

      ELSE
        EXECUTE IMMEDIATE entriesStmt
          USING stepData(stepSeq).rule_id,
	        stepSeq,
		stepData(stepSeq).step_name,
		stepData(stepSeq).formula_text,
		ruleStepId,
		'N',
		stepData(stepSeq).sql_statement_num,
		contextData.datasetCode,
		contextData.calPeriodId,
		contextData.currencyCode,
		nvl(contextData.parentEntity, -1),
		nvl(contextData.childEntity, -1),
		nvl(contextData.elimsEntity, -1),
		nvl(contextData.childEntity, -1);

      END IF; --IF (cEntityType= 'C')

      -- Show the result in the logfile
      logString(statementLogLevel,
                procedureName,
                'stmt',
                'Rows inserted = ' || to_char(SQL%ROWCOUNT));

      IF offsetFlag = 'Y' THEN

        entriesStmt := replace(entriesStmt, tgtDimStmt, oTgtDimStmt);

        -- Show the statement in the logfile
        logString(statementLogLevel,
                  procedureName,
                  'stmt',
                  'OFFSET entriesStmt = ' || entriesStmt);

        --=======================================================
        logString(eventLogLevel, procedureName, 'section', '5.1');
        --=======================================================

        IF (cEntityType = 'C') THEN
          EXECUTE IMMEDIATE entriesStmt
            USING stepData(stepSeq).rule_id,
	          stepSeq,
		  stepData(stepSeq).step_name, '-1 * ( ' || stepData(stepSeq).formula_text || ')',
		  ruleStepId,
		  'Y',
		  stepData(stepSeq).sql_statement_num,
		  contextData.datasetCode,
		  contextData.calPeriodId,
		  contextData.currencyCode,
		  nvl(contextData.parentEntity, -1),
		  nvl(contextData.childEntity, -1),
		  nvl(contextData.elimsEntity, -1),
		  nvl(contextData.childEntity, -1),
		  nvl(contextData.childEntity, -1),
		  contextData.hierarchy,
		  contextData.hierarchy;

        ELSE
          EXECUTE IMMEDIATE entriesStmt
            USING stepData(stepSeq).rule_id,
	          stepSeq,
		  stepData(stepSeq).step_name,
		  '-1 * ( ' || stepData(stepSeq).formula_text || ')',
		  ruleStepId,
		  'Y',
		  stepData(stepSeq).sql_statement_num,
		  contextData.datasetCode,
		  contextData.calPeriodId,
		  contextData.currencyCode,
		  nvl(contextData.parentEntity, -1),
		  nvl(contextData.childEntity, -1),
		  nvl(contextData.elimsEntity, -1),
		  nvl(contextData.childEntity, -1);

        END IF; --IF (cEntityType= 'C')

      END IF; --IF offsetFlag = 'Y' THEN

      -- Show the result in the logfile
      logString(statementLogLevel,
                procedureName,
                'stmt',
                'Rows inserted = ' || to_char(SQL%ROWCOUNT));

      --jh 08.24.04: Bug 3848822: AD rule needs FEM_BALANCES
      --for ELIMTB only.

      -- AD rule
      -- Bugfix 6242317: Do not execute any queries against FEM_BALANCES
    ELSIF contextData.eventType = 'A' THEN
      entriesStmt := replace(entriesStmt,
                             'b.entity_id in ( :pid, :cid )
OR  ');

      --Bugfix 6242317: Eliminating Code which queries against FEM_BALANCES
      logString(statementLogLevel,
                procedureName,
                'stmt',
                'Eliminating execution of SQL Call #1');
      /*
          -- Show the statement in the logfile
          logString( statementLogLevel, procedureName, 'stmt',
                   'AD entriesStmt = ' || entriesStmt);

          --=======================================================
          logString( eventLogLevel, procedureName, 'section', '5');
          --=======================================================
          IF (cEntityType= 'C') THEN
            EXECUTE IMMEDIATE entriesStmt
            USING stepData(stepSeq).rule_id,
                  stepSeq,
                  stepData(stepSeq).step_name,
                  stepData(stepSeq).formula_text,
                  ruleStepId,
                  'N',
                  contextData.datasetCode,
                  contextData.calPeriodId,
                  contextData.currencyCode,
                  nvl(contextData.elimsEntity, -1),
                  nvl(contextData.childEntity, -1),
                  nvl(contextData.childEntity, -1),
                  contextData.hierarchy,
                  contextData.hierarchy;
        ELSE
            EXECUTE IMMEDIATE entriesStmt
            USING stepData(stepSeq).rule_id,
                  stepSeq,
                  stepData(stepSeq).step_name,
                  stepData(stepSeq).formula_text,
                  ruleStepId,
                  'N',
                  stepData(stepSeq).sql_statement_num,
                  contextData.datasetCode,
                  contextData.calPeriodId,
                  contextData.currencyCode,
                  nvl(contextData.elimsEntity, -1),
                  nvl(contextData.childEntity, -1);
           END IF; --IF (cEntityType= 'C')

          -- Show the result in the logfile
          logString( statementLogLevel, procedureName, 'stmt',
                   'Rows inserted = ' || to_char(SQL%ROWCOUNT));


          IF offsetFlag = 'Y' THEN
      entriesStmt := replace(entriesStmt, tgtDimStmt, oTgtDimStmt);

            -- Show the statement in the logfile
            logString( statementLogLevel, procedureName, 'stmt',
                   'OFFSET AD entriesStmt = ' || entriesStmt);

            --=======================================================
            logString( eventLogLevel, procedureName, 'section', '5.1');
            --=======================================================

            IF (cEntityType= 'C') THEN
              EXECUTE IMMEDIATE entriesStmt
              USING stepData(stepSeq).rule_id,
                    stepSeq,
                    stepData(stepSeq).step_name,
                    '-1 * ( ' ||stepData(stepSeq).formula_text || ')',
                    ruleStepId,
                    'Y',
                    stepData(stepSeq).sql_statement_num,
                    contextData.datasetCode,
                    contextData.calPeriodId,
                    contextData.currencyCode,
                    nvl(contextData.elimsEntity, -1),
                    nvl(contextData.childEntity, -1),
                    nvl(contextData.childEntity, -1),
                    contextData.hierarchy,
                    contextData.hierarchy;

            ELSE
              EXECUTE IMMEDIATE entriesStmt
              USING stepData(stepSeq).rule_id,
                    stepSeq,
                    stepData(stepSeq).step_name,
                    '-1 * ( ' ||stepData(stepSeq).formula_text || ')',
                    ruleStepId,
                    'Y',
                    stepData(stepSeq).sql_statement_num,
                    contextData.datasetCode,
                    contextData.calPeriodId,
                    contextData.currencyCode,
                    nvl(contextData.elimsEntity, -1),
                    nvl(contextData.childEntity, -1);

            END IF; --IF (cEntityType= 'C')

          END IF; --IF offsetFlag = 'Y' THEN

          -- Show the result in the logfile
          logString( statementLogLevel, procedureName, 'stmt',
                   'Rows inserted = ' || to_char(SQL%ROWCOUNT));
          */

      --jh 08.17.04: insert a row for balance from ad_trial_balances
      --jh 08.17.04: Remove the inapplicable columns from the insert.
      IF (cEntityType = 'C') THEN

        entriesStmt := replace(entriesStmt,
                               '
AND  (  ( b.entity_id = :eid
       AND b.COMPANY_COST_CENTER_ORG_ID IN(
         SELECT o.company_cost_center_org_id
         FROM   GCS_ENTITY_CCTR_ORGS o
         WHERE  ( o.entity_id = :cid
               OR
               o.entity_id IN(
               SELECT r.child_entity_id
	       FROM   GCS_CONS_RELATIONSHIPS r
	       START WITH  r.parent_entity_id = :cid
               AND    r.hierarchy_id = :hid
               AND    r.actual_ownership_flag = ''Y''
	       AND    ( sysdate BETWEEN r.start_date
			        AND NVL(r.end_date, sysdate))
	       CONNECT BY  prior r.child_entity_id = r.parent_entity_id
               AND    r.hierarchy_id = :hid
               AND    r.actual_ownership_flag = ''Y''
               AND   ( sysdate BETWEEN r.start_date
		         AND NVL(r.end_date, sysdate)))
               ))))',
                               '
AND ( b.entity_id = :cid )');

      ELSE
        entriesStmt := replace(entriesStmt,
                               '
AND  (  ( b.entity_id = :eid
       AND b.COMPANY_COST_CENTER_ORG_ID IN(
         SELECT o.company_cost_center_org_id
         FROM   GCS_ENTITY_CCTR_ORGS o
         WHERE  ( o.entity_id = :cid
               ))))',
                               '

AND ( b.entity_id = :cid )');

      END IF; --IF (cEntityType= 'C')

      entriesStmt := replace(entriesStmt, 'b.currency_code,', ':ccy,');
      entriesStmt := replace(entriesStmt,
                             'b.ytd_credit_balance_e,
');
      entriesStmt := replace(entriesStmt,
                             'b.ytd_debit_balance_e,
');
      entriesStmt := replace(entriesStmt, 'ytd_credit_balance_e,');
      entriesStmt := replace(entriesStmt,
                             'ytd_debit_balance_e,
');
      entriesStmt := replace(entriesStmt,
                             'fem_balances',
                             'gcs_ad_trial_balances');
      entriesStmt := replace(entriesStmt,
                             'dataset_code',
                             'ad_transaction_id');
      entriesStmt := replace(entriesStmt, ':dci', ':tid');
      entriesStmt := replace(entriesStmt,
                             'AND   b.cal_period_id = :cpi
');
      entriesStmt := replace(entriesStmt,
                             'AND   b.currency_code IN (:ccy, ''STAT'')
');
      --Bugfix 6242317: Commenting out the code below as it will not work with offset functionality
      /*
              entriesStmt := entriesStmt || '
      AND NOT EXISTS(
        SELECT 1
        FROM   GCS_ENTRIES_GT E
              WHERE  E.ENTITY_ID = B.ENTITY_ID
              AND    ( E.RULE_ID = :rid
                      AND    E.STEP_SEQ = :seq)' || adtColumnList ||'
              )';
              */

      -- Show the statement in the logfile
      logString(statementLogLevel,
                procedureName,
                'stmt',
                'AD entriesStmt = ' || entriesStmt);
      --=======================================================
      logString(eventLogLevel, procedureName, 'section', '6');
      --=======================================================

      EXECUTE IMMEDIATE entriesStmt
        USING stepData(stepSeq).rule_id,
	      stepSeq,
	      stepData(stepSeq).step_name,
	      stepData(stepSeq).formula_text,
	      ruleStepId,
	      'N',
	      stepData(stepSeq).sql_statement_num,
	      contextData.currencyCode,
	      contextData.eventKey,
	      nvl(contextData.childEntity, -1);

      -- Show the result in the logfile
      logString(statementLogLevel,
                procedureName,
                'stmt',
                'Rows inserted = ' || to_char(SQL%ROWCOUNT));

      IF offsetFlag = 'Y' THEN

        entriesStmt := replace(entriesStmt, tgtDimStmt, oTgtDimStmt);

        -- Show the statement in the logfile
        logString(statementLogLevel,
                  procedureName,
                  'stmt',
                  'OFFSET AD entriesStmt 2 = ' || entriesStmt);
        --=======================================================
        logString(eventLogLevel, procedureName, 'section', '6.1');
        --=======================================================

        EXECUTE IMMEDIATE entriesStmt
          USING stepData(stepSeq).rule_id,
	        stepSeq,
		stepData(stepSeq).step_name,
		'-1 * ( ' || stepData(stepSeq).formula_text || ')',
		ruleStepId,
		'Y',
		stepData(stepSeq).sql_statement_num,
		contextData.currencyCode,
		contextData.eventKey,
		nvl(contextData.childEntity, -1);
        --Bug 6242317: Bind Parameters below are not required
        /*
        stepData(stepSeq).rule_id,
              stepSeq;
        */
        -- Show the result in the logfile
        logString(statementLogLevel,
                  procedureName,
                  'stmt',
                  'Rows inserted = ' || to_char(SQL%ROWCOUNT));

        --Bugfix 6242317: The code below should always run not only if the offset flag is N
      END IF;

    END IF; --IF contextData.eventType = 'C' THEN

    -- Done
    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

  end initEntriesGT_stdDimSet;

  --Bugfix 4928211: Added initEntriesGT: Used for performance purposes for consolidation rules
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Initialize data in the GCS_ENTRIES_GT table by creating source and
  -- target dimensions, and setting related "friendly" data like names, formula.
  --
  -- FOR TARGET-ONLY dimension sets: see proc initEntriesGT_tgtDimSet elsewhere.
  --
  -- FOR STANDARD dimension sets:
  --
  -- The SQL stmt used to init the gcs_entries_gt table looks like...
  --
  --    INSERT INTO GCS_ENTRIES_GT (
  --        rule_id, step_seq, formula_text,
  --        ad_input_amount, pe_input_amount, ce_input_amount, ee_input_amount,
  --        output_amount,
  --        <src_dimensions>,
  --        <tgt_dimensions>)
  --    SELECT :rid, :seq, :ftx,
  --           0, 0,
  --           <b.source_dimension_columns>,
  --           <d.target_dimension_expressions>
  --    FROM  fem_balances b,
  --          gcs_rule_scope_dims d
  --    WHERE b.source_dimension_columns =
  --          (select t.source_member_id
  --           from   gcs_rule_scope_dtls t
  --           where  t.rule_step_id = :rsi) ;
  --
  --
  -- For the cctr_org and interco dimensions, the target value is always
  -- copied from the source value.  For the other dimensions, the target
  -- expressions are based on whether...
  --  a) ...the target template is a value
  --        then use the target's value as a constant
  --
  --  b) ...the target template is NULL
  --        then use the source's same-dimension value
  --
  -- An expression in the form of...
  --  decode( <xdim>,
  --          NULL,  l.src_<xdim>,
  --          <xdim>)
  -- ...is constructed for each selected dimension in the dim set.
  --
  --    This procedure makes use of expression strings created elsewhere...
  --
  --     selColumnList: has expressions in the form ', b.<xdim>' for
  --                    the current dim set id (see resolveDimSet)
  --     srcColumnList: created here as replace(selColumnList,', b.',', src_')
  --                    so if the selColumnList = b.moe, b.larry, b.curly then
  --                    the srcColumnList would come out as src_moe, src_larry,
  --                    src_curly.
  --     tgtColumnList: created here as replace(selColumnList,', b.',', tgt_')
  --                    so if the selColumnList = b.moe, b.larry, b.curly then
  --                    the tgtColumnList would come out as tgt_moe, tgt_larry,
  --                    tgt_curly.
  --     insColumnList: has expressions in the form ', <xdim>' for
  --                    the current dim set id (see resolveDimSet)
  --     adtColumnList: has expressions in the form 'AND  E.<xdim> = B.<xdim>'
  --                    for the join condition to gcs_ad_trial_balances.
  --
  -- NOTE: Abbreviations used for bind vars here...
  --       ccy = currency code id   contextData.currencyCode
  --       dci = dataset code       contextData.datasetCode
  --       dsi = dim set id         dimSetId (private global variable)
  --       dsn = dim set name       dimSets(dsi).dimension_set_name
  --       dst = dim set type       dimSets(dsi).dimension_set_type_code
  --       eid = entity id          contextData.elimsEntity
  --       ftx = formula text       dimSet(dsi).formula_text
  --       seq = step sequence      stepSeq (procedure argument)
  --       rid = rule id            stepData(seq).rule_id
  --       rsi = rule step id            stepData(seq).rule_step_id
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure initEntriesGT(stepSeq        IN NUMBER,
                          categoryInfo   IN getCategory%ROWTYPE,
                          organizationId IN NUMBER,
                          intercompanyId IN NUMBER) is

    procedureName varchar2(30);
    entriesStmt   varchar2(20000);
    oEntriesStmt  varchar2(20000);
    whereClause   varchar2(5000);
    tgtDimStmt    varchar2(5000);
    oTgtDimStmt   varchar2(5000);
    fromList      varchar2(2500);
    i             varchar2(30);
    j             number;
    orgId         number := -1;
    intercoId     number := -1;
    tgtOrg        varchar2(100);
    cEntityType   varchar2(2); --whether child entity is operating or consolidation
    offsetFlag    varchar2(2); --whether to create an offset line or not.

    cursor getChildEntityType is
      SELECT dim_attribute_varchar_member
        FROM FEM_ENTITIES_ATTR
       WHERE entity_id = nvl(contextData.childEntity, -1)
         AND attribute_id =
             GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE')
      .attribute_id
         AND version_id =
             GCS_UTILITY_PKG.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE')
      .version_id
         AND value_set_id =
             GCS_UTILITY_PKG.g_gcs_dimension_info('ENTITY_ID')
      .associated_value_set_id;

    --Bugfix 4928211: Added objectDefnId for performance purposes
    objectDefnId number;
    groupClause  varchar2(2000);
    TYPE tbindVarInfo IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
    bindVarInfo      tbindVarInfo;
    elimEntityToken  boolean := false;
    childEntityToken boolean := false;
    miToken          boolean := false;
    ownToken         boolean := false;
    bindVarIndex     varchar2(30);
    entriesStmtIdx   integer := dbms_sql.open_cursor;
    outputStmtIdx    integer := dbms_sql.open_cursor;
    dbmsSqlVal       number;
    rowcount         number;
    outputStmt       varchar2(1000);
    setOutput        varchar2(100);

  begin
    procedureName := 'INIT_ENTRIESGT';
    tgtOrg        := '';

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    --Global states may persist since last time we did this, so reset them
    selColumnList := null;
    adtColumnList := null;
    j             := 0;
    offsetFlag    := 'N';

    --Assign column lists based off the active dimensions using the dynamic utility package
    selColumnList := gcs_rp_utility_pkg.g_rp_selColumnList;
    srcColumnList := gcs_rp_utility_pkg.g_rp_srcColumnList;
    tgtColumnList := gcs_rp_utility_pkg.g_rp_tgtColumnList;
    offColumnList := gcs_rp_utility_pkg.g_rp_offColumnList;

    --Log Strings for tracking purposes
    logString(statementLogLevel,
              procedureName,
              'stmt',
              'selColumnList = ' || selColumnList);
    logString(statementLogLevel,
              procedureName,
              'stmt',
              'srcColumnList = ' || srcColumnList);
    logString(statementLogLevel,
              procedureName,
              'stmt',
              'tgtColumnList = ' || tgtColumnList);
    logString(statementLogLevel,
              procedureName,
              'stmt',
              'offColumnList = ' || offColumnList);

    --STK: Note to Self, this can probably be enhanced rather than calling per rule step
    --find out if child entity is a consolidation entity.
    Open getChildEntityType;
    Fetch getChildEntityType
      INTO cEntityType;

    If getChildEntityType%NOTFOUND then
      cEntityType := 'N'; --set entity_type to 'N' for none
    End if;

    Close getChildEntityType;

    logString(statementLogLevel,
              procedureName,
              'parameter',
              'child entity type = ' || cEntityType);

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '2');
    --=======================================================

    --Start the Statement
    entriesStmt := gcs_rp_utility_pkg.g_core_insert_stmt || srcColumnList ||
                   tgtColumnList || offColumnList ||
                   gcs_rp_utility_pkg.g_core_sel_stmt || selColumnList;

    whereClause := gcs_rp_utility_pkg.g_core_whr_stmt;
    fromList    := gcs_rp_utility_pkg.g_core_frm_stmt;
    groupClause := gcs_rp_utility_pkg.g_core_grp_stmt;

    --Check for token usages
    if (INSTR(stepData(stepSeq).formula_text, 'CHILDTB') <> 0) then
      childEntityToken := true;
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'CHILDTB Token = true');
    end if;

    if (INSTR(stepData(stepSeq).formula_text, 'ELIMTB') <> 0) then
      elimEntityToken := true;
      bindVarInfo('eid') := contextData.elimsEntity;
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'ELIMTB Token = true');
    end if;

    --Code area to check how to determine appropriate organizations that must be used in the calculation

    if (elimEntityToken) then
      if (cEntityType = 'O') then
        fromList := fromList || ' ,
                       gcs_entity_cctr_orgs geo';

        whereClause := whereClause || '
                          AND b.company_cost_center_org_id = geo.company_cost_center_org_id
                          AND geo.entity_id                = :cid ';

        if (childEntityToken) then
          whereClause := whereClause || '
                            AND b.entity_id IN (:cid, :eid)';
        else
          whereClause := whereClause || '
                            AND b.entity_id IN (:eid)';
        end if;
      elsif (cEntityType = 'C') then
        fromList := fromList || ' ,
                       gcs_entity_cctr_orgs geo,
                       gcs_flattened_relns gfr';

        whereClause := whereClause || '
                          AND b.company_cost_center_org_id = geo.company_cost_center_org_id
                          AND geo.entity_id                = gfr.child_entity_id
                          AND gfr.run_name                 = :runname
                          AND gfr.parent_entity_id         = :cid ';

        bindVarInfo('runname') := contextData.runName;

        if (childEntityToken) then
          whereClause := whereClause || '
                            AND b.entity_id IN (:cid, :eid)';
        else
          whereClause := whereClause || '
                              AND b.entity_id IN (:eid)';
        end if;
      end if;
    else
      whereClause := whereClause || '
                       AND b.entity_id                   = :cid ';
    end if;

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '3');
    --=======================================================

    -- Add the selected dim target expressions
    i           := selectDims.FIRST;
    tgtDimStmt  := '';
    oTgtDimStmt := '';
    offsetFlag  := 'N';

    While i IS NOT NULL Loop

      --Handle the dim_set_dims differently: by looping through the dimInfo
      --array and using the index there in the selectDims array, when we hit
      --a dim that is not selected for this Dim Set a no_data_found is thrown.
      --The body of this nested block handles selectDims columns while the
      --no_data_found handler handles the non-selectDims columns.

      BEGIN
        j := j + 1;
        --jh 10.19.04: add all-source-member support
        if selectDims(i).target_member_id IS NULL then
          tgtDimStmt := tgtDimStmt || ',
b.' || selectDims(i).column_name;
        else
          bindVarInfo('target' || selectDims(i).alias) := selectDims(i)
                                                         .target_member_id;
          tgtDimStmt := tgtDimStmt || ',
 :target' || selectDims(i).alias;
        end if;

        --Bugfix 4928211: Added offset support directly in single statement
        oTgtDimStmt := oTgtDimStmt || ',
:offset' || selecTdims(i).alias;

        if selectDims(i).offset_member_id IS NOT NULL THEN
          offsetFlag := 'Y';
          bindVarInfo('offset' || selectDims(i).alias) := selectDims(i)
                                                         .offset_member_id;
        else
          bindVarInfo('offset' || selectDims(i).alias) := NULL;
        end if; --IF selectDims(i).offset_member_id IS NOT NULL THEN

        if selectDims(i).all_source_members_flag <> 'Y' then

          fromList := fromList || ' ,
gcs_rule_scope_dtls ' || selectDims(i).alias;
          whereClause := whereClause || '
AND ' || selectDims(i)
                        .alias || '.rule_step_id = :rsi';
          bindVarInfo('sourcecolumn' || selectDims(i).alias) := selectDims(i)
                                                               .column_name;
          whereClause := whereClause || '
AND ' || selectDims(i)
                        .alias || '.column_name = :sourcecolumn' ||
                         selectDims(i).alias;

          --check if selecting based off of a flat list
          if selectDims(i).hierarchy_obj_id IS NULL then
            whereClause := whereClause || '
AND b.' || selectDims(i)
                          .column_name || ' = ' || selectDims(i)
                          .alias || '.source_member_id';
            --for scenario where hierarchy is selected
          else
            SELECT object_definition_id
              INTO objectDefnId
              FROM fem_object_definition_b
             WHERE object_id = selectDims(i)
            .hierarchy_obj_id
               AND contextData.calPeriodEndDate between
                   effective_start_date and effective_end_date;

            fromList := fromList || ' ,
' || selectDims(i)
                       .hierarchy_table_name || ' ' || selectDims(i)
                       .hierarchy_table_name;

            bindVarInfo('sourcehierarchy' || selectDims(i).alias) := objectDefnId;
            whereClause := whereClause || '
AND ' || selectDims(i).hierarchy_table_name ||
                           '.hierarchy_obj_def_id  =  :sourcehierarchy' ||
                           selectDims(i).alias;
            whereClause := whereClause || '
AND b.' || selectDims(i)
                          .column_name || '  =  ' || selectDims(i)
                          .hierarchy_table_name || '.child_id';
            whereClause := whereClause || '
AND ' || selectDims(i)
                          .alias || '.source_member_id = ' || selectDims(i)
                          .hierarchy_table_name || '.parent_id';

          end if; --complete check for hierarchy scenarios

        end if; -- check all_source_members_flag

      EXCEPTION
        WHEN OTHERS THEN
          logString(statementLogLevel,
                    procedureName,
                    'error during build of sql statement',
                    SQLERRM);
      END;
      i := selectDims.NEXT(i);

    End Loop; --While i IS NOT NULL
    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '4');
    --=======================================================

    -- Add the FROM and WHERE clauses
    entriesStmt := entriesStmt || tgtDimStmt || oTgtDimStmt || fromList ||
                   whereClause || groupClause;

    ruleStepId := stepData(stepSeq).rule_step_id;

    -- Execute the stmt
    logString(statementLogLevel,
              procedureName,
              'bind',
              'rid = ' || to_char(stepData(stepSeq).rule_id));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'seq = ' || to_char(stepSeq));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'sna = ' || stepData(stepSeq).step_name);
    logString(statementLogLevel,
              procedureName,
              'bind',
              'ftx = ' || stepData(stepSeq).formula_text);
    logString(statementLogLevel,
              procedureName,
              'bind',
              'rsi = ' || to_char(stepData(stepSeq).rule_step_id));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'stn = ' || to_char(stepData(stepSeq).sql_statement_num));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'dci = ' || to_char(contextData.datasetCode));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'cpi = ' || to_char(contextData.calPeriodId));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'ccy = ' || contextData.currencyCode);
    logString(statementLogLevel,
              procedureName,
              'bind',
              'pid = ' || to_char(contextData.parentEntity));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'cid = ' || to_char(contextData.childEntity));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'eid = ' || to_char(contextData.elimsEntity));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'hid = ' || to_char(contextData.hierarchy));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'osf = ' || offsetFlag);

    --Consolidation rule
    IF contextData.eventType = 'C' THEN

      logString(statementLogLevel,
                procedureName,
                'dumpBinding',
                'dumping bind variables');
      bindVarIndex := bindVarInfo.FIRST;

      while (bindVarIndex is not null) loop
        logString(statementLogLevel,
                  procedureName,
                  'bindVarInfo',
                  bindVarIndex);
        logString(statementLogLevel,
                  procedureName,
                  'bindVarinfo',
                  bindVarinfo(bindVarIndex));
        bindVarIndex := bindVarInfo.next(bindVarIndex);
      end loop;
      -- Show the statement in the logfile
      logString(statementLogLevel,
                procedureName,
                'stmt',
                'entriesStmt = ' || entriesStmt);

      --=======================================================
      logString(eventLogLevel, procedureName, 'section', '5');
      --=======================================================
      dbms_sql.parse(entriesStmtIdx, entriesStmt, DBMS_SQL.NATIVE);
      dbms_sql.bind_variable(entriesStmtIdx,
                             'rid',
                             stepData(stepSeq).rule_id);
      dbms_sql.bind_variable(entriesStmtIdx, 'seq', stepSeq);
      dbms_sql.bind_variable(entriesStmtIdx,
                             'sna',
                             stepData(stepSeq).step_name);
      dbms_sql.bind_variable(entriesStmtIdx,
                             'ftx',
                             stepData(stepSeq).formula_text);
      dbms_sql.bind_variable(entriesStmtIdx, 'rsi', ruleStepId);
      dbms_sql.bind_variable(entriesStmtIdx, 'osf', offsetFlag);
      dbms_sql.bind_variable(entriesStmtIdx,
                             'stn',
                             stepData(stepSeq).sql_statement_num);
      dbms_sql.bind_variable(entriesStmtIdx,
                             'dci',
                             contextData.datasetCode);
      dbms_sql.bind_variable(entriesStmtIdx,
                             'cpi',
                             contextData.calPeriodId);
      dbms_sql.bind_variable(entriesStmtIdx,
                             'ccy',
                             contextData.currencyCode);
      dbms_sql.bind_variable(entriesStmtIdx,
                             'tgt_cctr_org_id',
                             organizationId);
      dbms_sql.bind_variable(entriesStmtIdx,
                             'tgt_intercompany_id',
                             intercompanyId);
      dbms_sql.bind_variable(entriesStmtIdx,
                             'eid',
                             contextData.elimsEntity);
      dbms_sql.bind_variable(entriesStmtIdx,
                             'cid',
                             contextData.childEntity);
      dbms_sql.bind_variable(entriesStmtIdx,
                             'pid',
                             contextData.parentEntity);
      --Bugfix 5456211: Added ledger to the bind variables for performance purposes
      dbms_sql.bind_variable(entriesStmtIdx,
                             'ledger',
                             contextData.ledgerId);

      logString(statementLogLevel,
                procedureName,
                'dumpBinding',
                'dumping bind variables');
      bindVarIndex := bindVarInfo.FIRST;
      while (bindVarIndex is not null) loop
        logString(statementLogLevel,
                  procedureName,
                  'bindVarInfo',
                  bindVarIndex);
        logString(statementLogLevel,
                  procedureName,
                  'bindVarinfo',
                  bindVarinfo(bindVarIndex));
        dbms_sql.bind_variable(entriesStmtIdx,
                               bindVarIndex,
                               bindVarInfo(bindVarIndex));
        bindVarIndex := bindVarInfo.next(bindVarIndex);
      end loop;

      logString(statementLogLevel,
                procedureName,
                'binding',
                'completed binding variables');

      dbmsSqlVal := dbms_sql.execute(entriesStmtIdx);

      dbms_sql.close_cursor(entriesStmtIdx);

      setOutput := stepData(stepSeq).formula_text;
      if (INSTR(setOutput, 'CHILDTB') <> 0) then
        setOutput := replace(setOutput, 'CHILDTB', 'ce_input_amount');
      end if;
      if (INSTR(setOutput, 'ELIMTB') <> 0) then
        setOutput := replace(setOutput, 'ELIMTB', 'ee_input_amount');
      end if;
      if (INSTR(setOutput, 'PARTB') <> 0) then
        setOutput := replace(setOutput, 'PARTB', 'pe_input_amount');
      end if;
      if (INSTR(setOutput, '%MI') <> 0) then
        setOutput := replace(setOutput, '%MI', ':min');
        miToken   := true;
      end if;
      if (INSTR(setOutput, '%OWN') <> 0) then
        setOutput := replace(setOutput, '%OWN', ':own');
        ownToken  := true;
      end if;

      --Bugfix 5075451: Added paranthesis around setOutput so calculation is done first then currency rounding

      outputStmt := 'UPDATE gcs_entries_gt
SET   output_amount = round((' || setOutput ||
                    ') / :currPrecision) * :currPrecision
WHERE rule_id       = :rule_id
AND   step_seq      = :seq';

      dbms_sql.parse(outputStmtIdx, outputStmt, DBMS_SQL.NATIVE);
      dbms_sql.bind_variable(outputStmtIdx,
                             'rule_id',
                             stepData(stepSeq).rule_id);
      dbms_sql.bind_variable(outputStmtIdx, 'seq', stepSeq);
      dbms_sql.bind_variable(outputStmtIdx,
                             'currPrecision',
                             contextData.currPrecision);
      if (miToken) then
        dbms_sql.bind_variable(outputStmtIdx,
                               'min',
                               1 - ruleData.toPercent);
      end if;
      if (ownToken) then
        dbms_sql.bind_variable(outputStmtIdx, 'own', ruleData.toPercent);
      end if;
      dbmsSqlVal := dbms_sql.execute(outputStmtIdx);
      dbms_sql.close_cursor(outputStmtIdx);

      /*
      IF (cEntityType= 'C') THEN
        EXECUTE IMMEDIATE entriesStmt
        USING stepData(stepSeq).rule_id,
              stepSeq,
              stepData(stepSeq).step_name,
              stepData(stepSeq).formula_text,
              ruleStepId,
              'N',
              stepData(stepSeq).sql_statement_num,
              contextData.datasetCode,
              contextData.calPeriodId,
              contextData.currencyCode,
              nvl(contextData.parentEntity, -1),
              nvl(contextData.childEntity, -1),
              nvl(contextData.elimsEntity, -1),
              nvl(contextData.childEntity, -1),
              nvl(contextData.childEntity, -1),
              contextData.hierarchy,
              contextData.hierarchy;

      ELSE
        EXECUTE IMMEDIATE entriesStmt
        USING stepData(stepSeq).rule_id,
              stepSeq,
              stepData(stepSeq).step_name,
              stepData(stepSeq).formula_text,
              ruleStepId,
              'N',
              stepData(stepSeq).sql_statement_num,
              contextData.datasetCode,
              contextData.calPeriodId,
              contextData.currencyCode,
              nvl(contextData.parentEntity, -1),
              nvl(contextData.childEntity, -1),
              nvl(contextData.elimsEntity, -1),
              nvl(contextData.childEntity, -1);

      END IF; --IF (cEntityType= 'C')
      */
      -- Show the result in the logfile
      logString(statementLogLevel,
                procedureName,
                'stmt',
                'Rows inserted = ' || to_char(SQL%ROWCOUNT));

    END IF; --IF contextData.eventType = 'C' THEN

    -- Done
    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

  end initEntriesGT;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Initialize data in the GCS_ENTRIES_GT table by creating source and
  -- target dimensions and setting related outfile data like rule_id, names.
  --
  -- FOR STANDARD TARGET SETS: see proc initEntriesGT_stdDimSet elsewhere.
  --
  -- FOR TARGET-ONLY dimension sets:
  --
  -- We only have to insert into the gcs_entries_gt table the single
  -- target DVS template, which must be a complete set of detail values...
  --
  -- The SQL stmt used to init the gcs_entries_gt table looks like...
  --
  --    INSERT INTO GCS_ENTRIES_GT (
  --        rule_id, step_seq, formula_text,
  --        input_amount, output_amount, <tgt_dimensions>)
  --    SELECT :rid, :seq, :ftx,
  --           0, 0, <l.target_dimension_expressions>
  --    FROM gcs_rule_scope_dims d
  --    WHERE d.rule_step_id = :rsi;
  --
  -- The target expressions are actually the l.tgt_ column names.
  --
  -- NOTE: Abbreviations used for bind vars here...
  --       ccy = currency code id   contextData.currencyCode
  --       eid = entity id          contextData.elimsEntity
  --       dci = dataset code       contextData.datasetCode
  --       ftx = formula text       dimSet(dsi).formula_text
  --       seq = step sequence      stepSeq (procedure argument)
  --       rid = rule id            stepData(seq).rule_id
  --       rsi = rule step          stepData(seq).rule_step_id
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure initEntriesGT_tgtDimSet(stepSeq      IN NUMBER,
                                    categoryInfo IN getCategory%ROWTYPE) is

    procedureName varchar2(30);

    entriesStmt varchar2(10000);
    i           varchar2(30);
    orgId       number := -1;
    intercoId   number := -1;

    -- changes made by yingliu:
    /*
          cursor getSpecificIntercoId is
            SELECT SPECIFIC_INTERCOMPANY_ID
            FROM   GCS_HIERARCHIES_B
            WHERE  hierarchy_id = contextData.hierarchy;
    */
    cursor getSpecificIntercoId is
      SELECT SPECIFIC_INTERCOMPANY_ID
        FROM GCS_CATEGORIES_B
       WHERE CATEGORY_CODE = 'INTRACOMPANY';
    -- end of change by yingliu

    --We need a cctr and interco value to use here.
    --See bug 3710985 for details on how cctr and
    --interco values are determined (jh 06.29.04).

  begin
    procedureName := 'INIT_ENTRIESGT_TGT_DIMSET';

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    --Identify a default cctr and interco dim member to use

    --JH 7.28.04: use categoryInfo.entityId to get base_org (3798215)
    orgId := GCS_UTILITY_PKG.get_org_id(categoryInfo.entityId,
                                        contextData.hierarchy);

    if orgId = -1 then
      logString(exceptionLogLevel,
                procedureName,
                'bind',
                'categoryInfo.entityId  => ' ||
                to_char(categoryInfo.entityId));
      logString(exceptionLogLevel,
                procedureName,
                'bind',
                'contextData.hierarchy    => ' ||
                to_char(contextData.hierarchy));
      RAISE no_default_cctr_found;
    end if;

    -- changes made by yingliu
    /*
          if categoryInfo.interco_output_code ='SPECIFIC_VALUE' then
             Open getSpecificIntercoId;
             Fetch getSpecificIntercoId into intercoId;
             Close getSpecificIntercoId;
          else intercoId := orgId;
          end if;
    */
    Open getSpecificIntercoId;
    Fetch getSpecificIntercoId
      into intercoId;
    Close getSpecificIntercoId;

    IF intercoId IS NULL THEN
      intercoId := orgId;
    END IF;
    -- end of changes by yingliu

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '2');
    --=======================================================

    -- Set up a target expression list
    i             := dimInfo.FIRST;
    tgtColumnList := null;
    While i IS NOT NULL Loop

      if dimInfo(i).required_for_gcs = 'Y' then

        tgtColumnList := tgtColumnList || ',
  tgt_' || dimInfo(i).column_name;

      end if;

      i := dimInfo.NEXT(i);

    End Loop;

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '3');
    --=======================================================

    -- Start the statement
    entriesStmt := 'INSERT INTO GCS_ENTRIES_GT (
rule_id, step_seq, step_name, formula_text, rule_step_id,
currency_code,ad_input_amount, pe_input_amount,
ce_input_amount, ee_input_amount,  output_amount' ||
                   tgtColumnList || ')
SELECT DISTINCT :rid, :seq, :sna, :ftx, r..rule_step_id, :ccy, 0, 0, 0, 0,0 ';

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '4');
    --=======================================================

    -- Add the target expressions
    i := dimInfo.FIRST;
    While i IS NOT NULL Loop

      if dimInfo(i).required_for_gcs = 'Y' then

        --See bug 3710985 for details on how cctr and
        --interco values are determined (jh 06.29.04)

        if dimInfo(i).column_name = cctr_column then
          entriesStmt := entriesStmt || ',
  ' || to_char(orgId);

        elsif dimInfo(i).column_name = interco_column then
          entriesStmt := entriesStmt || ',
  ' || to_char(intercoId);

        else

          if tgtDims(dimInfo(i).column_name).target_member_id IS NULL THEN
            entriesStmt := entriesStmt || ',
  NULL';
          else
            entriesStmt := entriesStmt || ',
  ' || tgtDims(dimInfo(i).column_name)
                          .target_member_id;

          end if; --tgtDims(dimInfo(i).column_name).target_member_id IS NULL THEN

        end if; --if dimInfo(i).column_name = cctr_column

      end if; --if dimInfo(i).required_for_gcs = 'Y'

      i := dimInfo.NEXT(i);

    End Loop;

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '5');
    --=======================================================

    -- Join target-only DMS info to GCS_RULE_SCOPE_DIMS
    -- Add the FROM and WHERE clauses
    entriesStmt := entriesStmt || '
FROM  gcs_dimension_set_dims d
WHERE g.rule_step_id = :rsi';

    --jh 4.30.04: update dimSetId
    ruleStepId := stepData(stepSeq).rule_step_id;

    -- Show the statement in the logfile
    logString(statementLogLevel,
              procedureName,
              'stmt',
              'Target-only entriesStmt = ' || entriesStmt);
    logString(statementLogLevel,
              procedureName,
              'bind',
              'rid => ' || to_char(stepData(stepSeq).rule_id));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'seq => ' || to_char(stepSeq));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'sna => ' || stepData(stepSeq).step_name);
    logString(statementLogLevel,
              procedureName,
              'bind',
              'ftx => ' || to_char(stepData(stepSeq).formula_text));
    logString(statementLogLevel,
              procedureName,
              'bind',
              'ccy => ' || contextData.currencyCode);
    logString(statementLogLevel,
              procedureName,
              'bind',
              'rsi => ' || ruleStepId);

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '6');
    --=======================================================

    -- Execute the stmt
    EXECUTE IMMEDIATE entriesStmt
      USING stepData(stepSeq).rule_id,
            stepSeq,
	    stepData(stepSeq).step_name,
	    stepData(stepSeq).formula_text,
	    contextData.currencyCode,
	    ruleStepId;

    -- Show the result in the logfile
    logString(statementLogLevel,
              procedureName,
              'stmt',
              'Rows inserted = ' || to_char(SQL%ROWCOUNT));

    -- Doney
    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

  end initEntriesGT_tgtDimSet;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Use balances from FEM_Balances, GCS_AD_Trail_balances or both as inputs
  -- to formulas, updating GCS_ENTRIES_GT with the results.
  --
  -- PARAMETERS:
  --    stepSeq  IN   Number   the step_seq value to process
  --
  -- NOTE: the form that the dynamic sql stmt takes here will be one of those
  -- defined in the procedure initSqlStmts, above.  It is impossible to
  -- anticipate the various combinations and order of occurance of the bind
  -- variables involved in these stmts, since the formula expression may use
  -- any, all or no variable(s) in any order the customer desires.  Since
  -- native dynamic SQL can only bind values based on the relative position
  -- within the stmt, it cannot support this requirement.  DBMS_SQL can do
  -- the bind by variable name and so must be used instead.
  --
  -- For example...
  -- Given that cctr_org, nat acct, IC, product and user1 are GCS active
  -- dims.  The dim set has cctr_org, nat acct and user1 selected.  The
  -- sqlStmt used is 5.  A formula is assumed as shown.
  --
  -- The resulting stmt would look like this:
  --
  -- SELECT rowidtochar(e.rowid) row_id,
  --        ( 1 - :now )
  --      * sum( t1.debit_amount - t1.credit_amount )
  --      + sum(ee.ytd_debit_balance_e - ee.ytd_credit_balance_e) formula,
  --      sum( t1.debit_amount - t1.credit_amount ) T1_AMT,
  --      0 T2_AMT,
  --      0 PE_AMT,
  --      0 ce_AMT,
  --      sum(ee.ytd_debit_balance_e - ee.ytd_credit_balance_e) EE_AMT
  -- FROM gcs_ad_trial_balances t1,
  --      fem_balances b,
  --      GCS_ENTRIES_GT e
  -- WHERE t1.ad_transaction_id = :xns
  -- AND   t1.trial_balance_seq = 1
  -- AND   b.entity_id = :eid
  -- AND   b.dataset_code  = :dci
  -- AND   b.currency_code = :ccy
  -- AND   b.cal_period_id = :cpi
  -- AND   e.rule_id = :rid
  -- AND   e.step_seq = :seq
  -- AND   t1.company_cost_center_org_id = e.src_company_cost_center_org
  -- AND   t1.natural_account_id         = e.src_natural_account_id
  -- AND   t1.user_dim1_id               = e.src_user_dim1_id
  -- AND   t1.product_id                 = e.src_product_id
  -- AND   t1.intercompany_id            = e.src_intercompany_id
  -- AND   b.company_cost_center_org_id  = e.src_company_cost_center_org
  -- AND   b.natural_account_id          = e.src_natural_account_id
  -- AND   b.user_dim1_id                = e.src_user_dim1_id
  -- AND   b.product_id                  = e.src_product_id
  -- AND   b.intercompany_id             = e.src_intercompany_id
  -- GROUP BY e.rowid;
  --
  -- The group by and aggregation operators (in the select list) are
  -- necessary since we may have multiple rows with different object_ids
  -- in FEM_BALANCES that have identical dimension values otherwise.
  -- This may also occur in an ADTB (not sure so aggregating anyhow).
  -- However, any formula that has sql_statement = 0 won't need to aggregate.
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure execFormulas(stepSeq IN Number) is

    procedureName varchar2(30);

    row_id    DBMS_SQL.varchar2_table;
    sourceAmt DBMS_SQL.number_table;
    targetAmt DBMS_SQL.number_table;
    t1Amt     DBMS_SQL.number_table;
    t2Amt     DBMS_SQL.number_table;
    peAmt     DBMS_SQL.number_table;
    ceAmt     DBMS_SQL.number_table;
    eeAmt     DBMS_SQL.number_table;

    dc1     integer;
    i       number := 0; --a re-usable index
    stmt    number := 0; --SQL statement index
    varList GCS_ELIM_RULE_STEPS_B.compiled_variables%TYPE;
    varName varchar2(10);

    fetchSize CONSTANT integer := 2000;
    listDelim CONSTANT varchar2(10) := ',';

    selClause Varchar2(1000);

    --Bugfix 6242317: Determine the number of rows for the specific step
    lRowCount NUMBER(15);

  begin
    procedureName := 'EXEC_FORMULAS';

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    dc1 := DBMS_SQL.open_cursor;

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '1');
    --=======================================================

    row_id.DELETE;
    sourceAmt.DELETE;
    targetAmt.DELETE;
    t1Amt.DELETE;
    t2Amt.DELETE;
    peAmt.DELETE;
    ceAmt.DELETE;
    eeAmt.DELETE;
    --The gcs_formula_statements table uses offset index values starting with 0
    --The bulk select that fills the stmts array assigns keys starting with 1
    --JH 4.29.04: updated the offset.
    stmt := 0;

    stmt := stepData(stepSeq).sql_statement_num + 1;

    -- Begin the statement
    selClause := 'SELECT rowidtochar(e.rowid) row_id, ' || '
       ' || stepData(stepSeq).parsed_formula || ' formula ';

    sqlStmt := stmts(stmt).statement_text;

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '2');
    --=======================================================

    -- Add the dimension join conditions
    if stmt between 2 and 8 then

      modelJoinClause; --fills modJoinClause with a "plain vanilla" clause

      -- Are any t1. aliases used?
      if instr(stmts(stmt).statement_text, 't1.') > 0 then
        selClause     := selClause || '
        ,sum( nvl(t1.debit_amount,0) - nvl(t1.credit_amount,0) ) T1_AMT ';
        dimJoinClause := replace(modJoinClause, 'right.', 'e.src_');
        dimJoinClause := replace(dimJoinClause, 'left.', 't1.');
        dimJoinClause := replace(dimJoinClause, '=', '(+) = ');
        sqlStmt       := sqlStmt || dimJoinClause;
      else
        selClause := selClause || ',
        0 T1_AMT ';
      end if;

      -- Are any t2. aliases used?
      if instr(stmts(stmt).statement_text, 't2.') > 0 then
        selClause     := selClause || '
        ,sum( nvl(t2.debit_amount,0) - nvl(t2.credit_amount,0) ) T2_AMT ';
        dimJoinClause := replace(modJoinClause, 'right.', 'e.src_');
        dimJoinClause := replace(dimJoinClause, 'left.', 't2.');
        dimJoinClause := replace(dimJoinClause, '=', '(+) = ');
        sqlStmt       := sqlStmt || dimJoinClause;
      else
        selClause := selClause || ',
        0 T2_AMT ';
      end if;

      -- Are any pe. aliases used?
      if instr(stmts(stmt).statement_text, 'pe.') > 0 then
        selClause     := selClause || '
        ,sum( nvl(pe.ytd_debit_balance_e,0) - nvl(pe.ytd_credit_balance_e,0) ) PE_AMT ';
        dimJoinClause := replace(modJoinClause, 'right.', 'e.src_');
        dimJoinClause := replace(dimJoinClause, 'left.', 'pe.src_');
        dimJoinClause := replace(dimJoinClause, '=', '(+) = ');
        sqlStmt       := sqlStmt || dimJoinClause;
      else
        selClause := selClause || ',
        0 PE_AMT ';
      end if;

      -- Are any se. aliases used?
      if instr(stmts(stmt).statement_text, 'se.') > 0 then
        selClause     := selClause || '
        ,sum( nvl(se.ytd_debit_balance_e,0) - nvl(se.ytd_credit_balance_e,0) ) CE_AMT ';
        dimJoinClause := replace(modJoinClause, 'right.', 'e.src_');
        dimJoinClause := replace(dimJoinClause, 'left.', 'se.src_');
        dimJoinClause := replace(dimJoinClause, '=', '(+) = ');
        sqlStmt       := sqlStmt || dimJoinClause;
      else
        selClause := selClause || ',
        0 CE_AMT ';
      end if;

      -- Are any ee. aliases used?
      --JH 4.29.04: Add outer joins

      if instr(stmts(stmt).statement_text, 'ee.') > 0 then
        selClause     := selClause || '
        ,sum( nvl(ee.ytd_debit_balance_e,0) - nvl(ee.ytd_credit_balance_e,0) ) EE_AMT ';
        dimJoinClause := replace(modJoinClause, 'right.', 'e.src_');
        dimJoinClause := replace(dimJoinClause, 'left.', 'ee.src_');
        dimJoinClause := replace(dimJoinClause, '=', '(+) = ');
        sqlStmt       := sqlStmt || dimJoinClause;
      else
        selClause := selClause || ',
        0 EE_AMT ';
      end if;

      --JH 5.3.04: Add values for where statement_num <1
    else
      selClause := selClause || ',
        0 T1_AMT,
        0 T2_AMT,
        0 PE_AMT,
        0 CE_AMT,
        0 EE_AMT ';

    end if;

    --Add the GROUP BY clause
    sqlStmt := sqlStmt || '
GROUP BY e.rowid';

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '3');
    --=======================================================

    -- Parse the stmt
    sqlStmt := selClause || sqlStmt;
    logString(statementLogLevel,
              procedureName,
              'stmt',
              'sqlStmt =
' || sqlStmt);
    DBMS_SQL.parse(dc1, sqlStmt, 1);

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '4');
    --=======================================================

    --Variables may not be embedded in the parsed_formula string
    --in the order they appear in the compiled_variables string
    varList := stepData(stepSeq).compiled_variables;

    SELECT count(*)
      INTO lRowCount
      FROM gcs_entries_gt
     WHERE rule_id = stepData(stepSeq).rule_id
       AND step_seq = stepSeq
       AND offset_flag = 'N';

    logString(statementLogLevel,
              procedureName,
              'bind',
              'number of rows=' || lRowCount);

    While varList IS NOT NULL Loop

      i := instr(varList, listDelim);
      if i = 0 then
        i := length(varList) + 1;
      end if;
      varName := lower(substr(varList, 1, (i - 1)));
      varList := substr(varList, (i + 2));

      logString(statementLogLevel,
                procedureName,
                'bind',
                'varName=' || varName);

      if varName = 'coi' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'coi=' || to_char(ruleData.consideration));

        if (stepData(stepSeq).sql_statement_num = 0) then
          logString(statementLogLevel,
                    procedureName,
                    'bind',
                    'truecoi=' || ruleData.consideration);
          DBMS_SQL.bind_variable(dc1, 'coi', ruleData.consideration);
        else
          --Bugfix 6242317: Need to Divide COI by the number of rows for the specific step
          if (lRowCount <> 0) then
            logString(statementLogLevel,
                      procedureName,
                      'bind',
                      'truecoi=' || ruleData.consideration / lRowCount);
            DBMS_SQL.bind_variable(dc1,
                                   'coi',
                                   ruleData.consideration / lRowCount);
          else
            logString(statementLogLevel,
                      procedureName,
                      'bind',
                      'truecoi=0');
            DBMS_SQL.bind_variable(dc1, 'coi', 0);
          end if;
        end if;
      elsif varName = 'nav' then
	--Bugfix 6511825: Need to Divide NAV by the number of rows for the specific step
        if (stepData(stepSeq).sql_statement_num = 0) then
          logString(statementLogLevel,
                    procedureName,
                    'bind',
                    'truenav=' || ruleData.netAssetValue);
          DBMS_SQL.bind_variable(dc1, 'nav', ruleData.netAssetValue);
        else
		if (lRowCount <> 0) then
		  logString(statementLogLevel,
			    procedureName,
			    'bind',
			    'truenav=' || to_char(ruleData.netAssetValue / lRowCount));
		  DBMS_SQL.bind_variable(dc1,
					 'nav',
					 ruleData.netAssetValue / lRowCount);
		else
		  logString(statementLogLevel, procedureName, 'bind', 'nav=0');
		  DBMS_SQL.bind_variable(dc1, 'nav', 0);
		end if;
        end if;
      elsif varName = 'now' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'now=' || to_char(ruleData.toPercent));
        DBMS_SQL.bind_variable(dc1, 'now', ruleData.toPercent);

      elsif varName = 'was' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'was=' || to_char(ruleData.fromPercent));
        DBMS_SQL.bind_variable(dc1, 'was', ruleData.fromPercent);

      elsif varName = 'own' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'own=' || to_char(ruleData.toPercent));
        DBMS_SQL.bind_variable(dc1, 'own', ruleData.toPercent);

      elsif varName = 'min' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'min=' || to_char(1 - ruleData.toPercent));
        DBMS_SQL.bind_variable(dc1, 'own', ruleData.toPercent);

      else
        FND_MESSAGE.set_name('GCS', 'GCS_INVALID_VARIABLE');
        FND_MESSAGE.set_token('PROCEDURE',
                              packageName || '.' || procedureName);
        FND_MESSAGE.set_token('VAR_NAME', varName);
        logString(exceptionLogLevel,
                  procedureName,
                  'exception',
                  'invalid_variable');
        RAISE invalid_variable;
      end if;
    End Loop; --while varlist is not null

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '5');
    --=======================================================

    --Bind variables specific to each statement's WHERE clause
    varList := stmts(stmt).compiled_variables;

    While varList IS NOT NULL Loop

      i := instr(varList, listDelim);
      if i = 0 then
        i := length(varList) + 1;
      end if;
      varName := lower(substr(varList, 1, (i - 1)));
      varList := substr(varList, (i + 1));

      if varName = 'cpi' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'cpi=' || to_char(contextData.calPeriodId));
        DBMS_SQL.bind_variable(dc1, 'cpi', contextData.calPeriodId);

      elsif varName = 'eid' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'eid=' || to_char(contextData.elimsEntity));
        DBMS_SQL.bind_variable(dc1, 'eid', contextData.elimsEntity);

      elsif varName = 'sei' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'sei=' || to_char(contextData.childEntity));
        DBMS_SQL.bind_variable(dc1, 'sei', contextData.childEntity);

      elsif varName = 'pei' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'pei=' || to_char(contextData.parentEntity));
        DBMS_SQL.bind_variable(dc1, 'pei', contextData.parentEntity);

      elsif varName = 'dci' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'dci=' || to_char(contextData.datasetCode));
        DBMS_SQL.bind_variable(dc1, 'dci', contextData.datasetCode);

      elsif varName = 'ccy' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'ccy=' || contextData.currencyCode);
        DBMS_SQL.bind_variable(dc1, 'ccy', contextData.currencyCode);

      elsif varName = 'xns' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'xns=' || to_char(contextData.eventKey));
        DBMS_SQL.bind_variable(dc1, 'xns', contextData.eventKey);

      elsif varName = 'rid' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'rid=' || to_char(stepData(stepSeq).rule_id));
        DBMS_SQL.bind_variable(dc1, 'rid', stepData(stepSeq).rule_id);

      elsif varName = 'seq' then
        logString(statementLogLevel,
                  procedureName,
                  'bind',
                  'seq=' || to_char(stepSeq));
        DBMS_SQL.bind_variable(dc1, 'seq', stepSeq);

      else
        FND_MESSAGE.set_name('GCS', 'GCS_INVALID_VARIABLE');
        FND_MESSAGE.set_token('PROCEDURE',
                              packageName || '.' || procedureName);
        FND_MESSAGE.set_token('VAR_NAME', varName);
        logString(exceptionLogLevel,
                  procedureName,
                  'exception',
                  'invalid_variable');
        RAISE invalid_variable;
      end if;
    End Loop; --while varlist is not null

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '6');
    --=======================================================

    --Define columns
    DBMS_SQL.define_array(dc1, 1, row_id, fetchSize, 1);
    DBMS_SQL.define_array(dc1, 2, targetAmt, fetchSize, 1);
    DBMS_SQL.define_array(dc1, 3, t1Amt, fetchSize, 1);
    DBMS_SQL.define_array(dc1, 4, t2Amt, fetchSize, 1);
    DBMS_SQL.define_array(dc1, 5, peAmt, fetchSize, 1);
    DBMS_SQL.define_array(dc1, 6, ceAmt, fetchSize, 1);
    DBMS_SQL.define_array(dc1, 7, eeAmt, fetchSize, 1);

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '7');
    --=======================================================

    --Execute the dynamic cursor
    i := DBMS_SQL.execute(dc1);

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '8');
    --=======================================================

    --Fetch through the cursor (see DEFINE_ARRAY() calls above)
    i := fetchSize;

    While i = fetchSize Loop
      i := DBMS_SQL.fetch_rows(dc1);
      DBMS_SQL.column_value(dc1, 1, row_id);
      DBMS_SQL.column_value(dc1, 2, targetAmt);
      DBMS_SQL.column_value(dc1, 3, t1Amt);
      DBMS_SQL.column_value(dc1, 4, t2Amt);
      DBMS_SQL.column_value(dc1, 5, peAmt);
      DBMS_SQL.column_value(dc1, 6, ceAmt);
      DBMS_SQL.column_value(dc1, 7, eeAmt);
    End Loop; --DBMS_SQL.fetch_rows loop

    logString(statementLogLevel,
              procedureName,
              'stmt',
              to_char(row_id.COUNT) || ' row(s) fetched');

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '9');
    --=======================================================

    --Update the ENTRIES table
    if row_id.FIRST IS NOT NULL then

      FORALL r IN row_id.FIRST .. row_id.LAST
        UPDATE GCS_ENTRIES_GT
           SET output_amount   = decode(offset_flag,
                                        'N',
                                        targetAmt(r),
                                        -1 * targetAmt(r)),
               ad_input_amount = t1Amt(r) + t2Amt(r),
               pe_input_amount = peAmt(r),
               ce_input_amount = ceAmt(r),
               ee_input_amount = eeAmt(r)
         WHERE rowid = chartorowid(row_id(r));
      logString(statementLogLevel,
                procedureName,
                'stmt',
                to_char(SQL%ROWCOUNT) || ' row(s) updated');
    end if;

    DBMS_SQL.close_cursor(dc1);

    -- Done
    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

  exception
    when others then
      -- make sure we close the cursor and then RAISE
      if DBMS_SQL.is_open(dc1) then
        DBMS_SQL.close_cursor(dc1);
      end if;
      RAISE;

  end execFormulas;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- The result of this procedure is a GCS_ENTRIES_GT table with the fully
  -- resolved dimension member combinations for every line of every dimension
  -- member set for each step for the rule.  The table will have the source
  -- and target dimensions, the input and out values for the formula, the
  -- step name and friendly formula text, etc.
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure processRuleSteps is

    procedureName varchar(30);
    i             number := 0;
    j             number := 0;

    k varchar2(30);

    categoryInfo getCategory%ROWTYPE;

    cursor isTgtOnly(rsi number) is
      SELECT 1
        FROM GCS_RULE_SCOPE_DTLS T, GCS_RULE_SCOPE_DIMS D
       WHERE D.ALL_SOURCE_MEMBERS_FLAG = 'N'
         AND D.TARGET_MEMBER_ID IS NOT NULL
         AND D.RULE_STEP_ID = T.RULE_STEP_ID
         AND D.RULE_STEP_ID = rsi;

    cursor getSpecificIntercoId is
      SELECT SPECIFIC_INTERCOMPANY_ID
        FROM GCS_CATEGORIES_B
       WHERE CATEGORY_CODE = 'INTRACOMPANY';

    --Bugfix 4928211 (STK): Added organization and intercompany values over here
    organizationId number;
    intercompanyId number;

  begin
    procedureName := 'PROCESS_RULE_STEPS';

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    --On the first go round we have to get the steps and resolve the dim_sets
    if ruleIteration = 1 then

      --Make sure these are empty when we start!
      stepData.DELETE;
      ruleStepId := -1;

      --Bugfix 4928211 (STK): Added org and interco values here to make code more performance
      --Do this only for consolidation rules for the time being
      --Get the category info
      Open getCategory;
      Fetch getCategory
        Into categoryInfo;
      If getCategory%NOTFOUND or categoryInfo.entityId = -1 Then
        Close getCategory;
        logString(exceptionLogLevel,
                  procedureName,
                  'eventCategory  => ',
                  contextData.eventCategory);
        logString(exceptionLogLevel,
                  procedureName,
                  'parentEntityId => ',
                  contextData.parentEntity);
        logString(exceptionLogLevel,
                  procedureName,
                  'childEntityId  => ',
                  contextData.childEntity);
        logString(exceptionLogLevel,
                  procedureName,
                  'elimEntityId   => ',
                  contextData.elimsEntity);
        RAISE invalid_category_code;
      End If;
      Close getCategory;

      if (contextData.eventType = 'C') then

        --Bugfix 6160542: Added Elimination Base Org
        --Populate values for company_cost_center_org and intercompany
        if categoryInfo.org_output_code = 'BASE_ORG' then
          organizationId := GCS_UTILITY_PKG.get_org_id(contextData.parentEntity,
                                                       contextData.hierarchy);
        elsif categoryInfo.org_output_code = 'ELIM_BASE_ORG' then
          organizationId := GCS_UTILITY_PKG.get_base_org_id(contextData.elimsEntity);
        else
          organizationId := GCS_UTILITY_PKG.get_org_id(contextData.childEntity,
                                                       contextData.hierarchy);
        end if;

        if organizationId = -1 then
          logString(exceptionLogLevel,
                    procedureName,
                    'bind',
                    'contextData.parentEntity => ' ||
                    to_char(contextData.parentEntity));
          logString(exceptionLogLevel,
                    procedureName,
                    'bind',
                    'contextData.childEntity => ' ||
                    to_char(contextData.childEntity));
          logString(exceptionLogLevel,
                    procedureName,
                    'bind',
                    'contextData.hierarchy    => ' ||
                    to_char(contextData.hierarchy));
          RAISE no_default_cctr_found;
        end if; --if orgId = -2

        --Bugfix 4928211: Determine the organization and intercompany target value
        SELECT NVL(specific_intercompany_id, organizationId)
          INTO intercompanyId
          FROM gcs_categories_b
         WHERE category_code = 'INTRACOMPANY';

      end if; -- if contextData.eventType = 'C'

      logString(statementLogLevel,
                procedureName,
                'parameter',
                'org_output = ' || categoryInfo.org_output_code);
      --changes made by yingiu
      /*
              logString( statementLogLevel,  procedureName, 'parameter',
                       'interco_output = ' || categoryInfo.interco_output_code);
      */
      -- end of changes by yingliu

      --=======================================================
      logString(eventLogLevel, procedureName, 'section', '2');
      --=======================================================

      For s In getSteps Loop

        --we select the steps in order by the dimension_set_id, so that we
        --can detect when that value breaks from fetch to fetch, but we want
        --to access the stepData array by the step_seq, since it is unique
        --here and the dim_set_id is not.  So, let's loop through and assign
        --the fetched rows into the array using the desired index, while we
        --process each dimension set in order.
        i := s.step_seq;
        stepData(i) := s;

        --Resolve the dimension set if the value breaks since the last fetch
        --Skip this if we are doing the STAT iteration of a monetary entity
        If stepData(i).rule_step_id <> ruleStepId Then

          --We have not resolved this set id yet
          ruleStepId := stepData(i).rule_step_id;

        End If; --If stepData(i).rule_step_id <> ruleStepId Then

      End Loop; --For s In getSteps

      -- Check data integrity
      if stepData.FIRST IS NULL then
        RAISE rule_has_no_steps;
      end if;

    end if; --if ruleIteration = 1

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '3');
    --=======================================================

    --Loop through each step and...
    --  initialize a row in GCS_ENTRIES_GT for each source/target dim combo pair
    --  execute the formula for the step and update GCS_ENTRIES_GT for the result
    i := stepData.FIRST;
    While i IS NOT NULL Loop

      --=======================================================
      logString(eventLogLevel,
                procedureName,
                'step',
                'begin ' || to_char(i));
      --=======================================================

      -- Initialize rows in gcs_entries_gt for all steps
      ruleStepId := stepData(i).rule_step_id;

      -- Fill the Dims arrays for this rule scope
      selectDims.DELETE;
      For r in getDimSelections(ruleStepId) Loop
        selectDims(r.column_name) := r;
        logString(statementLogLevel,
                  procedureName,
                  'rule_scope_dimension',
                  'Name, ID, FEM?, GCS? = ' || dimInfo(r.column_name)
                  .column_name || ', ' ||
                   to_char(dimInfo(r.column_name).dimension_id) || ', ' ||
                   dimInfo(r.column_name)
                  .required_for_fem || ', ' || dimInfo(r.column_name)
                  .required_for_gcs);
      End Loop;

      --Stop if there are no dimensions used by this dim set
      If selectDims.COUNT = 0 Then
        RAISE invalid_dim_set_id;
      End If;

      logString(eventLogLevel, procedureName, 'section', '4');

      --Bugfix 4928211: Modified initEntriesGT for performance purposes for Consolidation Rules
      --Changes for A Rules will follow
      if (contextData.eventType = 'A') then
        initEntriesGT_stdDimSet(i, categoryInfo);

        --SKAMDAR: Deleted obsolete code path to make code easier to read

        -- Execute each step's formula and store the result
        -- NOTE: This has to be inside the loop since each step may have
        --       a different formula, each formula may have a different
        --       sql_statement requirement and so must be dynamically
        --       executed separately.
        execFormulas(i);

      else
        initEntriesGT(i, categoryInfo, organizationId, intercompanyId);
      end if;
      --=======================================================
      logString(eventLogLevel, procedureName, 'step', 'end ' || to_char(i));
      --=======================================================

      i := stepData.NEXT(i);

    End Loop; --While i IS NOT NULL

    -- Done
    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

  end processRuleSteps;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Write rows into the GCS_ENTRY_[HEADERS|LINES] tables.
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Function writeEntryData(linesData    IN lineRec,
                          categoryInfo IN getCategory%ROWTYPE) Return NUMBER is

    procedureName varchar(30);

    cursor getEntryId is
      Select gcs_entry_headers_s.nextval From dual;
    entryId gcs_entry_headers.entry_id%TYPE := -1;

    cursor getADEntryId is
      SELECT B.assoc_entry_id
        FROM GCS_AD_TRANSACTIONS B
       WHERE B.AD_TRANSACTION_ID = contextData.eventKey;

    errbuf     varchar2(100);
    retcode    varchar2(100);
    endCalPers number;
    procCode   varchar2(50);

  begin
    procedureName := 'WRITE_ENTRY_DATA';
    endCalPers    := contextData.calPeriodId;
    procCode      := 'SINGLE_RUN_FOR_PERIOD';

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    -- Get an entry_id
    entryId := -1;

    if contextData.eventType <> 'A' then
      Open getEntryId;
      Fetch getEntryId
        Into entryId;
      Close getEntryId;
    else
      Open getADEntryId;
      Fetch getADEntryId
        Into entryId;
      Close getADEntryId;
    end if;

    --Save the id so we can update the gcs_cons_eng_run_dtls table
    if ruleIteration = 1 then
      mainEntryId := entryId;
    elsif ruleIteration = 2 then
      statEntryId := entryId;
    end if;

    -- Set values for some of the create_entry_header API args
    if contextData.eventType = 'A' then
      procCode   := 'ALL_RUN_FOR_PERIOD';
      endCalPers := null;
    end if;

    --=======================================================
    --Write the entry header record
    logString(eventLogLevel, procedureName, 'section', '2');
    --=======================================================

    logString(statementLogLevel,
              procedureName,
              'GCS_ENTRY_PKG.create_entry_header parameter',
              'p_entry_id=>' || to_char(entryId));

    logString(statementLogLevel,
              procedureName,
              'GCS_ENTRY_PKG.create_entry_header parameter',
              'p_hierarchy_id=>' || to_char(contextData.hierarchy));

    logString(statementLogLevel,
              procedureName,
              'GCS_ENTRY_PKG.create_entry_header parameter',
              'p_entity_id=>' || to_char(categoryInfo.entityId));

    logString(statementLogLevel,
              procedureName,
              'GCS_ENTRY_PKG.create_entry_header parameter',
              'p_start_cal_period_id=>' || to_char(contextData.calPeriodId));

    logString(statementLogLevel,
              procedureName,
              'GCS_ENTRY_PKG.create_entry_header parameter',
              'p_end_cal_period_id=>' || to_char(endCalPers));

    logString(statementLogLevel,
              procedureName,
              'GCS_ENTRY_PKG.create_entry_header parameter',
              'p_entry_type_code=>' || 'AUTOMATIC');

    logString(statementLogLevel,
              procedureName,
              'GCS_ENTRY_PKG.create_entry_header parameter',
              'p_balance_type_code=>' || 'ACTUAL');

    logString(statementLogLevel,
              procedureName,
              'GCS_ENTRY_PKG.create_entry_header parameter',
              'p_currency_code=>' || contextData.currencyCode);

    logString(statementLogLevel,
              procedureName,
              'GCS_ENTRY_PKG.create_entry_header parameter',
              'p_process_code=>' || procCode);

    logString(statementLogLevel,
              procedureName,
              'GCS_ENTRY_PKG.create_entry_header parameter',
              'p_category_code=>' || contextData.eventCategory);

    logString(statementLogLevel,
              procedureName,
              'GCS_ENTRY_PKG.create_entry_header parameter',
              'p_xlate_flag=>' || 'N');

    logString(statementLogLevel,
              procedureName,
              'GCS_ENTRY_PKG.create_entry_header parameter',
              'p_rule_id=>' || to_char(ruleId));

    --Create new entry on if this is not an AD event.
    if contextData.eventType <> 'A' then
      GCS_ENTRY_PKG.create_entry_header(X_ERRBUF              => errbuf,
                                        X_RETCODE             => retcode,
                                        P_ENTRY_ID            => entryId,
                                        P_HIERARCHY_ID        => contextData.hierarchy,
                                        P_ENTITY_ID           => categoryInfo.entityId,
                                        P_START_CAL_PERIOD_ID => contextData.calPeriodId,
                                        P_END_CAL_PERIOD_ID   => endCalPers,
                                        P_ENTRY_TYPE_CODE     => 'AUTOMATIC',
                                        P_BALANCE_TYPE_CODE   => 'ACTUAL',
                                        P_CURRENCY_CODE       => contextData.currencyCode,
                                        P_PROCESS_CODE        => procCode,
                                        P_CATEGORY_CODE       => contextData.eventCategory,
                                        P_XLATE_FLAG          => 'N',
                                        P_RULE_ID             => ruleId);

      if retcode = fnd_api.g_ret_sts_unexp_error then
        --Handler is in process_rule proc
        logString(exceptionLogLevel,
                  procedureName,
                  'exception',
                  'GCS_ENTRY_PKG.create_entry_header: ' || errbuf);
        RAISE entry_header_error;
      end if;

    else

      --bug 4253081: update GCS_ENTRY_HEADER with RULE_ID
      UPDATE GCS_ENTRY_HEADERS
         SET RULE_ID = ruleId
       WHERE ENTRY_ID = entryId;

      logString(statementLogLevel,
                procedureName,
                'stmt',
                to_char(SQL%ROWCOUNT) || ' row(s) updated');

      DELETE FROM GCS_ENTRY_LINES WHERE ENTRY_ID = entryId;

      logString(statementLogLevel,
                procedureName,
                'stmt',
                to_char(SQL%ROWCOUNT) || ' row(s) deleted');

    end if; --if contextData.eventType <>  'A' then

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '3');
    --=======================================================

    -- Insert the records

    ForAll x In linesData.line_item_id.FIRST .. linesData.line_item_id.LAST

      Insert Into gcs_entry_lines
        (entry_id,
         company_cost_center_org_id,
         financial_elem_id,
         product_id,
         natural_account_id,
         channel_id,
         line_item_id,
         project_id,
         customer_id,
         intercompany_id,
         task_id,
         user_dim1_id,
         user_dim2_id,
         user_dim3_id,
         user_dim4_id,
         user_dim5_id,
         user_dim6_id,
         user_dim7_id,
         user_dim8_id,
         user_dim9_id,
         user_dim10_id,
         ytd_balance_e,
         ytd_debit_balance_e,
         ytd_credit_balance_e,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         description)
      Values
        (entryId,
         linesData.cctr_org_id(x),
         linesData.finl_elem_id(x),
         linesData.product_id(x),
         linesData.nat_acct_id(x),
         linesData.channel_id(x),
         linesData.line_item_id(x),
         linesData.project_id(x),
         linesData.customer_id(x),
         linesData.interco_id(x),
         linesData.task_id(x),
         linesData.user_dim1_id(x),
         linesData.user_dim2_id(x),
         linesData.user_dim3_id(x),
         linesData.user_dim4_id(x),
         linesData.user_dim5_id(x),
         linesData.user_dim6_id(x),
         linesData.user_dim7_id(x),
         linesData.user_dim8_id(x),
         linesData.user_dim9_id(x),
         linesData.user_dim10_id(x),
         linesData.net_amount(x) * linesData.balance_factor(x),
         decode(abs(linesData.net_amount(x)),
                linesData.net_amount(x),
                linesData.net_amount(x),
                0),
         decode(abs(linesData.net_amount(x)),
                linesData.net_amount(x),
                0,
                abs(linesData.net_amount(x))),
         systemDate,
         userId,
         systemDate,
         userId,
         null,
         linesData.description(x));

    -- Done
    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    RETURN(entryId);

  end writeEntryData;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Write rows into the GCS_ENTRY_[HEADERS|LINES] tables.
  -- Applicable to contextData.eventType = 'A' (AD activity) only.
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure createEntry is

    procedureName            varchar(30);
    l_suspense_exceeded_flag VARCHAR2(1);

    entryId gcs_entry_headers.entry_id%TYPE := -1;

    Cursor getConversionRate(amt number) Is
      select --+ INDEX_DESC( r, GL_DAILY_RATES_U1 )
       (conversion_rate * amt)
        from gl_daily_rates r
       where from_currency = suspenseData.threshold_currency
         and to_currency = contextData.currencyCode
         and conversion_date < SYSDATE
         and rownum < 2;

    outOfbalance number := 0;
    thresholdAmt number := 0;
    cctrOrg      number;
    interCompany number;

    i binary_integer;

    --This is a record of tables because of an issue with
    --using a table of records.  As such there is no easy
    --way to DELETE it before re-using it and it is easier
    --to declare it locally, everytime the proc runs
    linesData lineRec;

    --we need these values to look up the multiplier
    --that determines the SIGN of amounts we put in
    --the xtd_balance_e column(s)
    liaAttr number;
    liaVers number;
    ataAttr number;
    ataVers number;

    --Used by the call to GCS_TEMPLATES_DYNAMIC_PKG
    templateRecord GCS_TEMPLATES_PKG.templateRecord;

    -- See package global data declares above for cursor
    categoryInfo getCategory%ROWTYPE;

    --Bugfix 6242317: Add the attribute information
    l_line_item_type_attr    NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                                          .attribute_id;
    l_line_item_type_version NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                                          .version_id;
    l_acct_type_attr         NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE')
                                          .attribute_id;
    l_acct_type_version      NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE')
                                          .version_id;

  begin
    procedureName := 'CREATE_ENTRY';

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    --++++++++++++++++++++++++++++++++++++++++++++++++++++
    --Some things we cannot do without:
    --  category info
    --  A valid currency and precision
    --  An entry with at least two non-zero-amount lines
    --  A balance_factor to use in populating [xtd|ytd]_balance_e
    --  An entry that either...
    --    a) balances (debits = credits), or
    --    b) can be balanced by a suspense line, or
    --    c) uses the STAT currency
    --
    -- Check for these things and stop if there's any problem
    --++++++++++++++++++++++++++++++++++++++++++++++++++++

    --Get the category info
    Open getCategory;
    Fetch getCategory
      Into categoryInfo;
    If getCategory%NOTFOUND or categoryInfo.entityId = -1 Then
      Close getCategory;
      logString(exceptionLogLevel,
                procedureName,
                'eventCategory  => ',
                contextData.eventCategory);
      logString(exceptionLogLevel,
                procedureName,
                'parentEntityId => ',
                contextData.parentEntity);
      logString(exceptionLogLevel,
                procedureName,
                'childEntityId  => ',
                contextData.childEntity);
      logString(exceptionLogLevel,
                procedureName,
                'elimEntityId   => ',
                contextData.elimsEntity);
      RAISE invalid_category_code;
    End If;
    Close getCategory;

    --Get a currency precision
    ccyPrecision   := -1;
    ccyMinAcctUnit := null;
    Open getCurrency;
    Fetch getCurrency
      Into ccyPrecision, ccyMinAcctUnit;
    Close getCurrency;

    if nvl(ccyPrecision, -1) < 0 then
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'Missing rounding data for currency code ' ||
                contextData.currencyCode);
      RAISE missing_currency_data;
    end if;

    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Currency Precision                = ' ||
              to_char(ccyPrecision));

    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Currency Minimum Accountable Unit = ' ||
              to_char(ccyMinAcctUnit));

    -- Entry lines are an aggregation from the gcs_entries_gt table
    Open getLines;
    Fetch getLines Bulk Collect
      Into linesData;

    Close getLines;

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '2');
    --=======================================================

    --Set the balance_factor: this is either 1 or -1 and is
    --multiplied by the net_amount to populate the value of
    --[xtd|ytd]_balances_e columns.

    -- To know what multiplier to use we have to get an attribute
    -- of an attribute of the line_item_id for every distinct lii
    -- in the GCS_ENTRIES_GT table.  Then we can store the value
    -- onto the linsData.balance_factor record for use in the bulk
    -- insert that writes entry lines to GCS_ENTRY_LINES.

    --Get the attribute_id and version_id for the EXTENDED_ACCOUNT_TYPE
    declare
      liaKey varchar2(100) := 'LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE';
    begin
      liaAttr := GCS_UTILITY_PKG.g_dimension_attr_info(liaKey).attribute_id;
      liaVers := GCS_UTILITY_PKG.g_dimension_attr_info(liaKey).version_id;
    exception
      when no_data_found then
        logString(exceptionLogLevel,
                  procedureName,
                  'exception',
                  'missing_key');
        FND_MESSAGE.set_name('GCS', 'GCS_MISSING_KEY');
        FND_MESSAGE.set_token('HASH_KEY', liaKey);
        RAISE missing_key;
    end;

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '3');
    --=======================================================

    --Get the attribute_id and version_id for the EXT_ACCOUNT_TYPE_CODE
    declare
      ataKey varchar2(100) := 'EXT_ACCOUNT_TYPE_CODE-SIGN';
    begin
      ataAttr := GCS_UTILITY_PKG.g_dimension_attr_info(ataKey).attribute_id;
      ataVers := GCS_UTILITY_PKG.g_dimension_attr_info(ataKey).version_id;
    exception
      when no_data_found then
        logString(exceptionLogLevel,
                  procedureName,
                  'exception',
                  'missing_key');
        FND_MESSAGE.set_name('GCS', 'GCS_MISSING_KEY');
        FND_MESSAGE.set_token('HASH_KEY', ataKey);
        RAISE missing_key;
    end;

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '4');
    --=======================================================

    -- get the sign factors into a local array
    tmpSign.DELETE;
    liiSign.DELETE;
    Open getSigns(liaAttr, liaVers, ataAttr, ataVers);
    Fetch getSigns Bulk Collect
      Into tmpSign;
    If getSigns%ROWCOUNT = 0 Then
      logString(exceptionLogLevel, procedureName, 'exception', 'bad_sign');
      /*4.29.04  UNCOMMENT THIS!!!!
              Close getSigns;
              logString( exceptionLogLevel, procedureName, 'exception', 'bad_sign');
              FND_MESSAGE.set_name( 'GCS', 'GCS_BAD_SIGN' );
              FND_MESSAGE.set_token( 'LINE_ITEM_ID' , to_char( linesData.line_item_id(i) ) );
              RAISE bad_sign;
      */
    End If;
    Close getSigns;

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '5');
    --=======================================================

    -- Index the array by line_item_id
    i := tmpSign.FIRST;
    While i IS NOT NULL Loop
      liiSign(tmpSign(i).lineItem) := tmpSign(i);
      i := tmpSign.NEXT(i);
    End Loop;

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '6');
    --=======================================================

    -- Make sure we have a factor for each line_item_id
    i := linesData.line_item_id.FIRST;
    While i IS NOT NULL Loop
      begin
        --if a line_item_id in linesData was skipped somehow, then the read
        --of that index value in liiSign will throw a no_data_found
        If nvl(liiSign(linesData.line_item_id(i)).signFactor, 2) IN (1, -1) Then
          linesData.balance_factor(i) := liiSign(linesData.line_item_id(i))
                                        .signFactor;
        Else
          RAISE no_data_found;
        End If;
        i := linesData.line_item_id.NEXT(i);
      exception
        when no_data_found then
          logString(exceptionLogLevel,
                    procedureName,
                    'exception',
                    'bad_sign');
          /*4.29.04  UNCOMMENT THIS!!!!
                      FND_MESSAGE.set_name( 'GCS', 'GCS_BAD_SIGN' );
                      FND_MESSAGE.set_token( 'LINE_ITEM_ID' , to_char( linesData.line_item_id(i) ) );
                      RAISE bad_sign;
          */
          --4.29.04  REMOVE THE NEXT 2 LINES!!!!!
          linesData.balance_factor(i) := 1;
          i := linesData.line_item_id.NEXT(I);

      end;
    End Loop; --While i IS NOT NULL

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '7');
    --=======================================================

    -- Can bypass most of the rest if this is a STAT entry
    if contextData.currencyCode = 'STAT' then

      if linesData.cctr_org_id.COUNT <> 0 then
        entryId := writeEntryData(linesData, categoryInfo);
        -- changes made by yingliu
        if contextData.eventType <> 'A' AND
           categoryInfo.support_multi_parents_flag = 'Y' then
          process_multiparent(entryId);
        end if;
        -- end of changes by yingliu
      end if;

      -- Make sure we end up with at least some non-zero lines!
    elsif linesData.cctr_org_id.COUNT = 0 then
      logString(statementLogLevel, procedureName, 'data', 'No entry lines');
      --Bug 3645309: Remove entry from gcs_cons_eng_run_dtls if no lines generated
      if contextData.eventType = 'C' then
        DELETE gcs_cons_eng_run_dtls
         WHERE run_detail_id = contextData.eventKey;
      END IF;
      -- bug 4115816
      --        RAISE no_entry_lines;

    else

      --=======================================================
      logString(eventLogLevel, procedureName, 'section', '8');
      --=======================================================

      -- Write the entry lines
      entryId := writeEntryData(linesData, categoryInfo);

      --=======================================================
      logString(eventLogLevel, procedureName, 'section', '9');
      --=======================================================
      --Look up the suspense data
      Open getSuspenseData; --(contextData.hierarchy);
      Fetch getSuspenseData
        Into suspenseData;
      Close getSuspenseData;

      --=======================================================
      logString(eventLogLevel, procedureName, 'section', '10');
      --=======================================================

      --Get the template record together
      templateRecord.FINANCIAL_ELEM_ID  := suspenseData.financial_elem_id;
      templateRecord.PRODUCT_ID         := suspenseData.product_id;
      templateRecord.NATURAL_ACCOUNT_ID := suspenseData.natural_account_id;
      templateRecord.CHANNEL_ID         := suspenseData.channel_id;
      templateRecord.LINE_ITEM_ID       := suspenseData.line_item_id;
      templateRecord.PROJECT_ID         := suspenseData.project_id;
      templateRecord.CUSTOMER_ID        := suspenseData.customer_id;
      templateRecord.TASK_ID            := suspenseData.task_id;
      templateRecord.USER_DIM1_ID       := suspenseData.user_dim1_id;
      templateRecord.USER_DIM2_ID       := suspenseData.user_dim2_id;
      templateRecord.USER_DIM3_ID       := suspenseData.user_dim3_id;
      templateRecord.USER_DIM4_ID       := suspenseData.user_dim4_id;
      templateRecord.USER_DIM5_ID       := suspenseData.user_dim5_id;
      templateRecord.USER_DIM6_ID       := suspenseData.user_dim6_id;
      templateRecord.USER_DIM7_ID       := suspenseData.user_dim7_id;
      templateRecord.USER_DIM8_ID       := suspenseData.user_dim8_id;
      templateRecord.USER_DIM9_ID       := suspenseData.user_dim9_id;
      templateRecord.USER_DIM10_ID      := suspenseData.user_dim10_id;
      thresholdAmt                      := suspenseData.threshold_amount;

      --jh 4.30.04: added log.
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'FINANCIAL_ELEM_ID  => ' ||
                templateRecord.FINANCIAL_ELEM_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'PRODUCT_ID         => ' || templateRecord.PRODUCT_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'NATURAL_ACCOUNT_ID => ' ||
                templateRecord.NATURAL_ACCOUNT_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'CHANNEL_ID         => ' || templateRecord.CHANNEL_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'LINE_ITEM_ID       => ' || templateRecord.LINE_ITEM_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'PROJECT_ID         => ' || templateRecord.PROJECT_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'CUSTOMER_ID        => ' || templateRecord.CUSTOMER_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'TASK_ID            => ' || templateRecord.TASK_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'USER_DIM1_ID       => ' || templateRecord.USER_DIM1_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'USER_DIM2_ID       => ' || templateRecord.USER_DIM2_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'USER_DIM3_ID       => ' || templateRecord.USER_DIM3_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'USER_DIM4_ID       => ' || templateRecord.USER_DIM4_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'USER_DIM5_ID       => ' || templateRecord.USER_DIM5_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'USER_DIM6_ID       => ' || templateRecord.USER_DIM6_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'USER_DIM17_ID      => ' || templateRecord.USER_DIM7_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'USER_DIM8_ID       => ' || templateRecord.USER_DIM8_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'USER_DIM9_ID       => ' || templateRecord.USER_DIM9_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'USER_DIM10_ID      => ' || templateRecord.USER_DIM10_ID);
      logString(statementLogLevel,
                procedureName,
                'parameter',
                'threshold_amount      => ' || to_char(thresholdAmt));

      --=======================================================
      logString(eventLogLevel, procedureName, 'section', '11');
      --=======================================================

      --Call the API to create suspense lines
      --followed by the one to handle Retained Earnings
      --JH 5.3.04: Added p_rel_id
      begin

        GCS_TEMPLATES_DYNAMIC_PKG.balance(p_entry_id                => entryId,
                                          p_template                => templateRecord,
                                          p_bal_type_code           => 'ACTUAL',
                                          p_hierarchy_id            => contextData.hierarchy,
                                          p_entity_id               => categoryInfo.entityId,
                                          p_threshold               => thresholdAmt,
                                          p_threshold_currency_code => suspenseData.threshold_currency);

      exception

        when OTHERS then
          logString(exceptionLogLevel,
                    procedureName,
                    'exception',
                    'templates_pkg_error');
          logString(exceptionLogLevel,
                    procedureName,
                    'exception',
                    'procedure "balance" fail');
          logString(exceptionLogLevel, procedureName, 'exception', null);
          RAISE templates_pkg_error;

      end;

      begin

        GCS_TEMPLATES_DYNAMIC_PKG.calculate_re(p_entry_id      => entryId,
                                               p_hierarchy_id  => contextData.hierarchy,
                                               p_bal_type_code => 'ACTUAL',
                                               p_entity_id     => categoryInfo.entityId);

      exception

        when OTHERS then
          logString(exceptionLogLevel,
                    procedureName,
                    'exception',
                    'templates_pkg_error');
          logString(exceptionLogLevel,
                    procedureName,
                    'exception',
                    'procedure "calculate_re" fail');
          logString(exceptionLogLevel, procedureName, 'exception', null);
          RAISE templates_pkg_error;

      end;

      -- changes made by yingliu
      if contextData.eventType <> 'A' AND
         categoryInfo.support_multi_parents_flag = 'Y' then
        process_multiparent(entryId);
      end if;

      -- Bugfix 6242317: Update the account type code
      if contextData.eventType = 'A' then

        --Bugfix 6242317: Update Line Type Code
        UPDATE gcs_entry_lines gel
           SET line_type_code = (SELECT DECODE(gel.description,
                                               'RE_LINE',
                                               'CALCULATED',
                                               DECODE(feata.dim_attribute_varchar_member,
                                                      'ASSET',
                                                      'BALANCE_SHEET',
                                                      'LIABILITY',
                                                      'BALANCE_SHEET',
                                                      'EQUITY',
                                                      'BALANCE_SHEET',
                                                      'PROFIT_LOSS'))
                                   FROM fem_ext_acct_types_attr feata,
                                        fem_ln_items_attr       flia
                                  WHERE gel.line_item_id = flia.line_item_id
                                    AND flia.attribute_id =
                                        l_line_item_type_attr
                                    AND flia.version_id =
                                        l_line_item_type_version
                                    AND flia.dim_attribute_varchar_member =
                                        feata.ext_account_type_code
                                    AND feata.attribute_id = l_acct_type_attr
                                    AND feata.version_id =
                                        l_acct_type_version)
         WHERE gel.entry_id = entryId;

      end if;

      -- bug fix 3920448
      SELECT SUSPENSE_EXCEEDED_FLAG
        INTO l_suspense_exceeded_flag
        FROM gcs_entry_headers
       WHERE entry_id = entryId;

      IF l_suspense_exceeded_flag = 'Y' THEN
        raise suspense_exceeded_warn;
      END IF;

      -- end changes by yingliu
    end if; --if contextData.currencyCode = 'STAT'

    -- Done
    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

  end createEntry;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Write rows into the GCS_ENTRY_[HEADERS|LINES] tables.
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Function writeConsolidationEntryData(linesData    IN lineRec,
                                       categoryInfo IN getCategory%ROWTYPE)
    Return NUMBER is

    procedureName varchar(30);

    cursor getEntryId is
      Select gcs_entry_headers_s.nextval From dual;
    entryId gcs_entry_headers.entry_id%TYPE := -1;

    errbuf      varchar2(100);
    retcode     varchar2(100);
    procCode    varchar2(50);
    l_row_count number;
    endCalPers  number;

    --Bugfix 4928211: Added offset flag to improve performance
    offsetFlag varchar2(1);

  begin
    procedureName := 'WRITE_CONSOLIDATION_ENTRY_DATA';
    endCalPers    := contextData.calPeriodId;
    procCode      := 'SINGLE_RUN_FOR_PERIOD';

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    -- Get an entry_id
    entryId := -1;

    Open getEntryId;
    Fetch getEntryId
      Into entryId;
    Close getEntryId;

    --Save the id so we can update the gcs_cons_eng_run_dtls table
    if ruleIteration = 1 then
      mainEntryId := entryId;
    elsif ruleIteration = 2 then
      statEntryId := entryId;
    end if;

    --=======================================================
    --create the entry lines
    logString(eventLogLevel,
              procedureName,
              'section',
              'inserting into gcs_entry_lines');
    --=======================================================

    logString(statementLogLevel,
              procedureName,
              'event',
              'Inserting into gcs_entry_lines');

    select decode(count(1), 0, 'N', 'Y')
      into offsetFlag
      from gcs_rule_scope_dims grsd, gcs_elim_rule_steps_b grsb
     where grsd.column_name = 'LINE_ITEM_ID'
       and grsd.offset_member_id is not null
       and grsb.rule_step_id = grsd.rule_step_id
       and grsb.rule_id = ruleId;

    logString(statementLogLevel,
              procedureName,
              'event',
              'Value of offset flag is: ' || offsetFlag);

    gcs_rp_utility_pkg.create_entry_lines(p_entry_id    => entryId,
                                          p_offset_flag => offsetFlag,
                                          p_row_count   => l_row_count);

    logString(statementLogLevel,
              procedureName,
              'event',
              'Completed insert into gcs_entry_lines ' || l_row_count);

    --check if any lines where created
    if (l_row_count = 0) then
      DELETE gcs_cons_eng_run_dtls
       WHERE run_detail_id = contextData.eventKey;
      RAISE no_entry_lines;
    else
      --=======================================================
      --create the entry header
      logString(eventLogLevel, procedureName, 'section', '3');
      --=======================================================

      logString(statementLogLevel,
                procedureName,
                'GCS_ENTRY_PKG.create_entry_header parameter',
                'p_entry_id=>' || to_char(entryId));

      logString(statementLogLevel,
                procedureName,
                'GCS_ENTRY_PKG.create_entry_header parameter',
                'p_hierarchy_id=>' || to_char(contextData.hierarchy));

      logString(statementLogLevel,
                procedureName,
                'GCS_ENTRY_PKG.create_entry_header parameter',
                'p_entity_id=>' || to_char(categoryInfo.entityId));

      logString(statementLogLevel,
                procedureName,
                'GCS_ENTRY_PKG.create_entry_header parameter',
                'p_start_cal_period_id=>' ||
                to_char(contextData.calPeriodId));

      logString(statementLogLevel,
                procedureName,
                'GCS_ENTRY_PKG.create_entry_header parameter',
                'p_end_cal_period_id=>' || to_char(endCalPers));

      logString(statementLogLevel,
                procedureName,
                'GCS_ENTRY_PKG.create_entry_header parameter',
                'p_entry_type_code=>' || 'AUTOMATIC');

      --Bugfix 5103251: Removed hard-coding of balance type code
      logString(statementLogLevel,
                procedureName,
                'GCS_ENTRY_PKG.create_entry_header parameter',
                'p_balance_type_code=>' || contextData.balanceTypeCode);

      logString(statementLogLevel,
                procedureName,
                'GCS_ENTRY_PKG.create_entry_header parameter',
                'p_currency_code=>' || contextData.currencyCode);

      logString(statementLogLevel,
                procedureName,
                'GCS_ENTRY_PKG.create_entry_header parameter',
                'p_process_code=>' || procCode);

      logString(statementLogLevel,
                procedureName,
                'GCS_ENTRY_PKG.create_entry_header parameter',
                'p_category_code=>' || contextData.eventCategory);

      logString(statementLogLevel,
                procedureName,
                'GCS_ENTRY_PKG.create_entry_header parameter',
                'p_xlate_flag=>' || 'N');

      logString(statementLogLevel,
                procedureName,
                'GCS_ENTRY_PKG.create_entry_header parameter',
                'p_rule_id=>' || to_char(ruleId));

      --Create new entry on if this is not an AD event.
      GCS_ENTRY_PKG.create_entry_header(X_ERRBUF              => errbuf,
                                        X_RETCODE             => retcode,
                                        P_ENTRY_ID            => entryId,
                                        P_HIERARCHY_ID        => contextData.hierarchy,
                                        P_ENTITY_ID           => categoryInfo.entityId,
                                        P_START_CAL_PERIOD_ID => contextData.calPeriodId,
                                        P_END_CAL_PERIOD_ID   => endCalPers,
                                        P_ENTRY_TYPE_CODE     => 'AUTOMATIC',
                                        P_BALANCE_TYPE_CODE   => contextData.balanceTypeCode,
                                        P_CURRENCY_CODE       => contextData.currencyCode,
                                        P_PROCESS_CODE        => procCode,
                                        P_CATEGORY_CODE       => contextData.eventCategory,
                                        P_XLATE_FLAG          => 'N',
                                        P_RULE_ID             => ruleId);

      if retcode = fnd_api.g_ret_sts_unexp_error then
        --Handler is in process_rule proc
        logString(exceptionLogLevel,
                  procedureName,
                  'exception',
                  'GCS_ENTRY_PKG.create_entry_header: ' || errbuf);
        RAISE entry_header_error;
      end if;

    end if; --check row_count = 0

    -- Done
    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    RETURN(entryId);

  end writeConsolidationEntryData;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Write rows into the GCS_ENTRY_[HEADERS|LINES] tables for Consolidation Rules
  -- Bugfix 4928211: Added this code to improve performance of the rules processor
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  procedure createConsolidationEntry is

    procedureName            varchar(30);
    l_suspense_exceeded_flag VARCHAR2(1);

    entryId gcs_entry_headers.entry_id%TYPE := -1;

    Cursor getConversionRate(amt number) Is
      select --+ INDEX_DESC( r, GL_DAILY_RATES_U1 )
       (conversion_rate * amt)
        from gl_daily_rates r
       where from_currency = suspenseData.threshold_currency
         and to_currency = contextData.currencyCode
         and conversion_date < SYSDATE
         and rownum < 2;

    outOfbalance number := 0;
    thresholdAmt number := 0;
    cctrOrg      number;
    interCompany number;

    i binary_integer;

    --This is a record of tables because of an issue with
    --using a table of records.  As such there is no easy
    --way to DELETE it before re-using it and it is easier
    --to declare it locally, everytime the proc runs
    linesData lineRec;

    --we need these values to look up the multiplier
    --that determines the SIGN of amounts we put in
    --the xtd_balance_e column(s)
    liaAttr number;
    liaVers number;
    ataAttr number;
    ataVers number;

    --Used by the call to GCS_TEMPLATES_DYNAMIC_PKG
    templateRecord GCS_TEMPLATES_PKG.templateRecord;

    -- See package global data declares above for cursor
    categoryInfo getCategory%ROWTYPE;

  begin
    procedureName := 'CREATE_CONSOLIDATION_ENTRY';

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    --++++++++++++++++++++++++++++++++++++++++++++++++++++
    --Some things we cannot do without:
    --  category info
    --  A valid currency and precision
    --  An entry with at least two non-zero-amount lines
    --  A balance_factor to use in populating [xtd|ytd]_balance_e
    --  An entry that either...
    --    a) balances (debits = credits), or
    --    b) can be balanced by a suspense line, or
    --    c) uses the STAT currency
    --
    -- Check for these things and stop if there's any problem
    --++++++++++++++++++++++++++++++++++++++++++++++++++++

    --Get the category info
    Open getCategory;
    Fetch getCategory
      Into categoryInfo;
    If getCategory%NOTFOUND or categoryInfo.entityId = -1 Then
      Close getCategory;
      logString(exceptionLogLevel,
                procedureName,
                'eventCategory  => ',
                contextData.eventCategory);
      logString(exceptionLogLevel,
                procedureName,
                'parentEntityId => ',
                contextData.parentEntity);
      logString(exceptionLogLevel,
                procedureName,
                'childEntityId  => ',
                contextData.childEntity);
      logString(exceptionLogLevel,
                procedureName,
                'elimEntityId   => ',
                contextData.elimsEntity);
      RAISE invalid_category_code;
    End If;
    Close getCategory;

    --Get a currency precision
    ccyPrecision   := -1;
    ccyMinAcctUnit := null;
    Open getCurrency;
    Fetch getCurrency
      Into ccyPrecision, ccyMinAcctUnit;
    Close getCurrency;

    if nvl(ccyPrecision, -1) < 0 then
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'Missing rounding data for currency code ' ||
                contextData.currencyCode);
      RAISE missing_currency_data;
    end if;

    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Currency Precision                = ' ||
              to_char(ccyPrecision));

    logString(statementLogLevel,
              procedureName,
              'parameter',
              'Currency Minimum Accountable Unit = ' ||
              to_char(ccyMinAcctUnit));

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '2');
    --=======================================================

    -- Write the entry lines
    entryId := writeConsolidationEntryData(linesData, categoryInfo);

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '9');
    --=======================================================
    --Look up the suspense data
    Open getSuspenseData; --(contextData.hierarchy);
    Fetch getSuspenseData
      Into suspenseData;
    Close getSuspenseData;

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '10');
    --=======================================================

    --Get the template record together
    templateRecord.FINANCIAL_ELEM_ID  := suspenseData.financial_elem_id;
    templateRecord.PRODUCT_ID         := suspenseData.product_id;
    templateRecord.NATURAL_ACCOUNT_ID := suspenseData.natural_account_id;
    templateRecord.CHANNEL_ID         := suspenseData.channel_id;
    templateRecord.LINE_ITEM_ID       := suspenseData.line_item_id;
    templateRecord.PROJECT_ID         := suspenseData.project_id;
    templateRecord.CUSTOMER_ID        := suspenseData.customer_id;
    templateRecord.TASK_ID            := suspenseData.task_id;
    templateRecord.USER_DIM1_ID       := suspenseData.user_dim1_id;
    templateRecord.USER_DIM2_ID       := suspenseData.user_dim2_id;
    templateRecord.USER_DIM3_ID       := suspenseData.user_dim3_id;
    templateRecord.USER_DIM4_ID       := suspenseData.user_dim4_id;
    templateRecord.USER_DIM5_ID       := suspenseData.user_dim5_id;
    templateRecord.USER_DIM6_ID       := suspenseData.user_dim6_id;
    templateRecord.USER_DIM7_ID       := suspenseData.user_dim7_id;
    templateRecord.USER_DIM8_ID       := suspenseData.user_dim8_id;
    templateRecord.USER_DIM9_ID       := suspenseData.user_dim9_id;
    templateRecord.USER_DIM10_ID      := suspenseData.user_dim10_id;
    thresholdAmt                      := suspenseData.threshold_amount;

    logString(statementLogLevel,
              procedureName,
              'parameter',
              'FINANCIAL_ELEM_ID  => ' || templateRecord.FINANCIAL_ELEM_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'PRODUCT_ID         => ' || templateRecord.PRODUCT_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'NATURAL_ACCOUNT_ID => ' || templateRecord.NATURAL_ACCOUNT_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'CHANNEL_ID         => ' || templateRecord.CHANNEL_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'LINE_ITEM_ID       => ' || templateRecord.LINE_ITEM_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'PROJECT_ID         => ' || templateRecord.PROJECT_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'CUSTOMER_ID        => ' || templateRecord.CUSTOMER_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'TASK_ID            => ' || templateRecord.TASK_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'USER_DIM1_ID       => ' || templateRecord.USER_DIM1_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'USER_DIM2_ID       => ' || templateRecord.USER_DIM2_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'USER_DIM3_ID       => ' || templateRecord.USER_DIM3_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'USER_DIM4_ID       => ' || templateRecord.USER_DIM4_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'USER_DIM5_ID       => ' || templateRecord.USER_DIM5_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'USER_DIM6_ID       => ' || templateRecord.USER_DIM6_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'USER_DIM17_ID      => ' || templateRecord.USER_DIM7_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'USER_DIM8_ID       => ' || templateRecord.USER_DIM8_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'USER_DIM9_ID       => ' || templateRecord.USER_DIM9_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'USER_DIM10_ID      => ' || templateRecord.USER_DIM10_ID);
    logString(statementLogLevel,
              procedureName,
              'parameter',
              'threshold_amount      => ' || to_char(thresholdAmt));

    --=======================================================
    logString(eventLogLevel, procedureName, 'section', '11');
    --=======================================================

    --Call the API to create suspense lines
    --followed by the one to handle Retained Earnings
    --JH 5.3.04: Added p_rel_id
    begin

      --Bugfix 5103251: Removed hard-coding of balance type code
      GCS_TEMPLATES_DYNAMIC_PKG.balance(p_entry_id                => entryId,
                                        p_template                => templateRecord,
                                        p_bal_type_code           => contextData.balanceTypeCode,
                                        p_hierarchy_id            => contextData.hierarchy,
                                        p_entity_id               => categoryInfo.entityId,
                                        p_threshold               => thresholdAmt,
                                        p_threshold_currency_code => suspenseData.threshold_currency);

    exception
      when OTHERS then
        logString(exceptionLogLevel,
                  procedureName,
                  'exception',
                  'templates_pkg_error');
        logString(exceptionLogLevel,
                  procedureName,
                  'exception',
                  'procedure "balance" fail');
        logString(exceptionLogLevel, procedureName, 'exception', null);
        RAISE templates_pkg_error;
    end;

    begin

      --Bugfix 5103251: Removed hard-coding of balance type code
      GCS_TEMPLATES_DYNAMIC_PKG.calculate_re(p_entry_id      => entryId,
                                             p_hierarchy_id  => contextData.hierarchy,
                                             p_bal_type_code => contextData.balanceTypeCode,
                                             p_entity_id     => categoryInfo.entityId);

    exception
      when OTHERS then
        logString(exceptionLogLevel,
                  procedureName,
                  'exception',
                  'templates_pkg_error');
        logString(exceptionLogLevel,
                  procedureName,
                  'exception',
                  'procedure "calculate_re" fail');
        logString(exceptionLogLevel, procedureName, 'exception', null);
        RAISE templates_pkg_error;

    end;

    -- changes made by yingliu
    if contextData.eventType <> 'A' AND
       categoryInfo.support_multi_parents_flag = 'Y' then
      process_multiparent(entryId);
    end if;

    -- bug fix 3920448
    SELECT SUSPENSE_EXCEEDED_FLAG
      INTO l_suspense_exceeded_flag
      FROM gcs_entry_headers
     WHERE entry_id = entryId;

    IF l_suspense_exceeded_flag = 'Y' THEN
      raise suspense_exceeded_warn;
    END IF;

    -- Done
    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

  exception
    when no_entry_lines then
      logString(eventLogLevel,
                procedureName,
                'Event',
                'Zero entry lines generated');
  end createConsolidationEntry;

  --+========================================================================+
  -- PACKAGE PUBLIC Members
  --+========================================================================+

  Function process_rule(p_rule_id   IN NUMBER,
                        p_stat_flag IN VARCHAR2,
                        p_context   IN contextRecord,
                        p_rule_data IN ruleDataRecord) RETURN NUMBER IS

    procedureName  Varchar2(30);
    errMsg         Varchar2(2000);
    l_return_value Number := 0;
    --Assume we run each rule once, but we may have
    --to run twice if the p_stat_flag = 'Y'
    runCount Number := 1;

    --Bugfix 4925150: Do not execute rules processor if formula evaluates to zero for performance savings
    --Provided space for 250 characters in the parsed formula
    TYPE l_parsed_formula_type IS TABLE OF VARCHAR2(250);
    l_parsed_formula l_parsed_formula_type;
    l_parsed_result  NUMBER;
    l_valid_formula  BOOLEAN := FALSE;

  Begin
    procedureName := 'PROCESS_RULE';

    -- Make sure we have the current runtime log level
    -- THIS LINE OF CODE MUST BE THE FIRST EXECUTED!!
    runtimeLogLevel := FND_LOG.g_current_runtime_level;

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    -- Report the incoming parameter data
    ruleId      := p_rule_id;
    ruleData    := p_rule_data;
    contextData := p_context;
    mainEntryId := null;
    statEntryId := null;
    logParameterValues;
    initRefTables;

    --We may run a rule twice, once for monetary and once for STAT currency.
    --The p_stat_flag value decides this but avoid doing two go rounds if the
    --original currency is STAT and the flag is set to Y.
    if nvl(p_stat_flag, 'N') = 'Y' AND contextData.currencyCode <> 'STAT' then
      runCount := 2;
    end if;

    --Bugfix 4928211: Select precision of currency into contextData
    select NVL(minimum_accountable_unit, POWER(10, -precision))
      into contextData.currPrecision
      from fnd_currencies
     where currency_code = contextData.currencyCode;

    --Bugfix 4925150: Do not execute rules processor if formula evaluates to zero for performance savings
    if contextData.eventType = 'C' then

      OPEN getEvaluatedFormulas(ruleData.toPercent, p_rule_id);
      FETCH getEvaluatedFormulas BULK COLLECT
        INTO l_parsed_formula;
      CLOSE getEvaluatedFormulas;

      FOR i IN 1 .. l_parsed_formula.COUNT LOOP

        EXECUTE IMMEDIATE 'SELECT ' || l_parsed_formula(i) || ' FROM DUAL'
          INTO l_parsed_result;

        if (l_parsed_result <> 0) then
          l_valid_formula := TRUE;
          EXIT;
        end if;

      END LOOP;

      if (NOT l_valid_formula) then
        delete from gcs_cons_eng_run_dtls
         where run_detail_id = contextData.eventKey;
      end if;

    else
      --For A Always execute the formula
      l_valid_formula := TRUE;
    end if;

    if (l_valid_formula) then

      --Bugfix 5456211: Initialize Ledger Id on context data for performance improvements
      SELECT fem_ledger_id
        INTO contextData.ledgerId
        FROM gcs_hierarchies_b
       WHERE hierarchy_id = contextData.hierarchy;

      For x in 1 .. runCount Loop

        --================================================================
        logString(eventLogLevel, procedureName, 'iteration', to_char(x));
        --================================================================

        --Flag whether this is the STAT iteration, i.e., x = 2
        ruleIteration := x;

        --Run the rule step-by-step, storing the full details of the process
        --into the GCS_ENTRIES_GT table for use in creating worksheet entries
        --and writing the execution report
        processRuleSteps;

        --Use the very detailed output stored in the GCS_ENTRIES_GT table
        --to create worksheet entries summarized across dimensions, and
        --balance any unbalanced entries where applicable

        BEGIN
          if (contextData.eventType = 'A') then
            createEntry;
          else
            createConsolidationEntry;
          end if;
        EXCEPTION
          WHEN suspense_exceeded_warn THEN
            l_return_value := 1;
        END;

        --================================================================
        logString(eventLogLevel, procedureName, 'STAT', '');
        --================================================================

        --Handle any STAT currency rows on loop iteration 2
        if ruleIteration = 2 then
          contextData.currencyCode := 'STAT';
        end if;

      End Loop; --For x in 1..runCount
    end if;
    --================================================================
    logString(eventLogLevel,
              procedureName,
              'Update eventKey: eventType =>',
              contextData.eventType);
    --================================================================

    --Update the eventKey for the entries
    if contextData.eventType = 'C' then
      UPDATE gcs_cons_eng_run_dtls
         SET entry_id      = mainEntryId,
             stat_entry_id = statEntryId,
             -- SKAMDAR : Added updates for request_error_code, and bp_request_error_code
             request_error_code    = DECODE(l_return_value,
                                            1,
                                            'WARNING',
                                            'COMPLETED'),
             bp_request_error_code = DECODE(l_return_value,
                                            1,
                                            'WARNING',
                                            'COMPLETED')
       WHERE run_detail_id = contextData.eventKey;

      logString(statementLogLevel,
                procedureName,
                'stmt',
                to_char(SQL%ROWCOUNT) || ' row(s) updated');

      /*
          elsif contextData.eventType = 'A' then

            UPDATE gcs_ad_transactions
            SET assoc_entry_id      = mainEntryId
            WHERE ad_transaction_id = contextData.eventKey;

            logString( statementLogLevel, procedureName, 'stmt',
                to_char(SQL%ROWCOUNT) || ' row(s) updated' );
      */
    end if;

    -- Done
    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    RETURN(l_return_value);

    -- +++++++++++++++++++++++++++++++++++
    -- ERROR HANDLERS
    -- ++++++++++++++++++++++++++++++++++++

  EXCEPTION

    WHEN rule_has_no_steps THEN
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'rule has no steps');
      FND_MESSAGE.set_name('GCS', 'GCS_MISSING_RULE_STEPS');
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      if contextData.eventType = 'C' then
        UPDATE gcs_cons_eng_run_dtls
           SET request_error_code    = 'GCS_MISSING_RULE_STEPS',
               bp_request_error_code = 'GCS_MISSING_RULE_STEPS'
         WHERE run_detail_id = contextData.eventKey;
      end if;
      RETURN(2);

    WHEN missing_currency_data THEN
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'missing_currency_data');
      FND_MESSAGE.set_name('GCS', 'GCS_MISSING_CURRENCY_DATA');
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      if contextData.eventType = 'C' then
        UPDATE gcs_cons_eng_run_dtls
           SET request_error_code    = 'GCS_MISSING_CURRENCY_DATA',
               bp_request_error_code = 'GCS_MISSING_CURRENCY_DATA'
         WHERE run_detail_id = contextData.eventKey;
      end if;
      RETURN(2);

    WHEN invalid_dim_set_id THEN
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'invalid_dim_set_id');
      FND_MESSAGE.set_name('GCS', 'GCS_INVALID_DIM_SET_ID');
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      if contextData.eventType = 'C' then
        UPDATE gcs_cons_eng_run_dtls
           SET request_error_code    = 'GCS_INVALID_DIM_SET_ID',
               bp_request_error_code = 'GCS_INVALID_DIM_SET_ID'
         WHERE run_detail_id = contextData.eventKey;
      end if;
      RETURN(2);

    WHEN invalid_variable THEN
      --An error msg is placed on the stack at the exception raise point
      --A logString call is made at the exception raise point
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      if contextData.eventType = 'C' then
        UPDATE gcs_cons_eng_run_dtls
           SET request_error_code    = 'GCS_INVALID_VARIABLE',
               bp_request_error_code = 'GCS_INVALID_VARIABLE'
         WHERE run_detail_id = contextData.eventKey;
      end if;
      RETURN(2);

    WHEN invalid_fem_setup THEN
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'invalid_fem_setup');
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      RETURN(2);

    WHEN invalid_gcs_setup THEN
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'invalid_gcs_setup');
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      RETURN(2);

    WHEN out_of_balance THEN
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'out_of_balance');
      FND_MESSAGE.set_name('GCS', 'GCS_OUT_OF_BALANCE');
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      RETURN(3);

    WHEN templates_pkg_error THEN
      --raise by gcs_templates_dynamic_pkg...
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      if contextData.eventType = 'C' then
        UPDATE gcs_cons_eng_run_dtls
           SET request_error_code    = 'GCS_TEMPLATES_PKG_ERROR',
               bp_request_error_code = 'GCS_TEMPLATES_PKG_ERROR'
         WHERE run_detail_id = contextData.eventKey;
      end if;
      RETURN(2);
      /*
          WHEN no_entry_lines THEN
            logString( exceptionLogLevel, procedureName, 'exception', 'no_entry_lines' );
            FND_MESSAGE.set_name( 'GCS', 'GCS_NO_ENTRY_LINES' );
            logString( procedureLogLevel, procedureName, 'end', to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
            RETURN (1);
      */
    WHEN missing_key THEN
      --An error msg is placed on the stack at the exception raise point
      --A logString call is made at the exception raise point
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      RETURN(2);

    WHEN bad_sign THEN
      --An error msg is placed on the stack at the exception raise point
      --A logString call is made at the exception raise point
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      RETURN(2);

    WHEN no_default_cctr_found THEN
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'no_default_cctr_found');
      FND_MESSAGE.set_name('GCS', 'GCS_NO_DEFAULT_CCTR');
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      RETURN(2);

    WHEN convert_threshold_err THEN
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'convert_threshold_err');
      FND_MESSAGE.set_name('GCS', 'GCS_CONVERT_THRESHOLD_ERR');
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      if contextData.eventType = 'C' then
        UPDATE gcs_cons_eng_run_dtls
           SET request_error_code    = 'GCS_CONVERT_THRESHOLD_ERR',
               bp_request_error_code = 'GCS_CONVERT_THRESHOLD_ERR'
         WHERE run_detail_id = contextData.eventKey;
      end if;
      RETURN(2);

    WHEN entry_header_error THEN
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'entry_header_error');
      FND_MESSAGE.set_name('GCS', 'GCS_ENTRY_UNEXPECTED_ERR');
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      if contextData.eventType = 'C' then
        UPDATE gcs_cons_eng_run_dtls
           SET request_error_code    = 'GCS_ENTRY_HEADER_ERROR',
               bp_request_error_code = 'GCS_ENTRY_HEADER_ERROR'
         WHERE run_detail_id = contextData.eventKey;
      end if;
      RETURN(2);

    WHEN invalid_category_code THEN
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'invalid_category_code');
      FND_MESSAGE.set_name('GCS', 'GCS_INVALID_CATEGORY_CODE');
      FND_MESSAGE.set_token('CATEGORY_CODE', contextData.eventCategory);
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      RETURN(2);

    WHEN OTHERS THEN
      errMsg := substr(SQLERRM, 1, 2000);
      logString(unexpectedLogLevel, procedureName, 'whenOthers', errMsg);
      FND_MESSAGE.set_name('GCS', 'GCS_UNHANDLED_EXCEPTION');
      FND_MESSAGE.set_token('PROCEDURE',
                            packageName || '.' || procedureName);
      FND_MESSAGE.set_token('EVENT', 'OTHERS');
      if contextData.eventType = 'C' then
        UPDATE gcs_cons_eng_run_dtls
           SET request_error_code    = 'GCS_UNHANDLED_EXCEPTION',
               bp_request_error_code = 'GCS_UNHANDLED_EXCEPTION'
         WHERE run_detail_id = contextData.eventKey;
      end if;
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      RETURN(2);

  End process_rule;

  -- Overloaded member to handle multiple Rules in one API call
  Function process_rule(p_rules      IN OUT NOCOPY ruleParmsTable,
                        p_context    IN contextRecord,
                        p_rules_data IN ruleDataTable) RETURN NUMBER IS

    procedureName varchar2(30);

    i      Number := 0;
    result number := 2;
    retVal number := 0; --NOTE: If p_rules is empty, return error
    errMsg Varchar2(2000);

  Begin
    procedureName := 'PROCESS_RULE';

    -- Make sure we have the current runtime log level
    -- THIS LINE OF CODE MUST BE THE FIRST EXECUTED!!
    runtimeLogLevel := FND_LOG.g_current_runtime_level;

    logString(procedureLogLevel,
              procedureName,
              'begin',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    --Loop through p_rules, calling the overloaded process_rule for each
    i := p_rules.FIRST;
    While i IS NOT NULL Loop

      logString(statementLogLevel,
                procedureName,
                'parameter',
                'Processing Rule ID ' || to_char(i));

      --Make sure we don't get a NO_DATA_FOUND error because of a
      --mis-match in the indexes between p_rules and p_rules_data
      Begin
        p_rules(i).result := process_rule(p_rule_id   => p_rules(i).ruleId,
                                          p_stat_flag => p_rules(i).statFlag,
                                          p_context   => p_context,
                                          p_rule_data => p_rules_data(i));

      Exception
        When NO_DATA_FOUND Then
          RAISE missing_rule_id;
      End;

      --Store the overall return value
      if result = 1 then
        retVal := 1;
      elsif result = 2 then
        retVal := 2;
        EXIT;
      end if;

      i := p_rules.NEXT(i);

    End Loop;

    -- Done
    logString(procedureLogLevel,
              procedureName,
              'end',
              to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    RETURN(retVal);

  EXCEPTION

    WHEN MISSING_RULE_ID THEN
      logString(exceptionLogLevel,
                procedureName,
                'exception',
                'missing_rule_id');
      FND_MESSAGE.set_name('GCS', 'GCS_MISSING_RULE_ID');
      FND_MESSAGE.set_token('PROCEDURE',
                            packageName || '.' || procedureName);
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      RETURN(2);

    WHEN OTHERS THEN
      errMsg := substr(SQLERRM, 1, 2000);
      logString(unexpectedLogLevel, procedureName, 'whenOthers', errMsg);
      FND_MESSAGE.set_name('GCS', 'GCS_UNHANDLED_EXCEPTION');
      FND_MESSAGE.set_token('PROCEDURE',
                            packageName || '.' || procedureName);
      FND_MESSAGE.set_token('EVENT', 'OTHERS');
      logString(procedureLogLevel,
                procedureName,
                'end',
                to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      RETURN(2);

  End process_rule;

-- Initialization of parameters
BEGIN
  runtimeLogLevel := FND_LOG.g_current_runtime_level;
  systemDate      := trunc(SYSDATE);
  userId          := FND_GLOBAL.user_id;
END GCS_RULES_PROCESSOR;

/
