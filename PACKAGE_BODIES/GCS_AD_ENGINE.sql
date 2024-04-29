--------------------------------------------------------
--  DDL for Package Body GCS_AD_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_AD_ENGINE" as
-- $Header: gcsadenb.pls 120.2 2007/11/28 06:05:00 smatam ship $

  --+========================================================================+
  -- PACKAGE Global Data
  --+========================================================================+

    -- Logging level during package execution will not change so we can
    -- define a single runtime level here, and update it at the start
    -- of public procedures
    runtimeLogLevel          Number       := FND_LOG.g_current_runtime_level;
    packageName     CONSTANT Varchar2(30) := 'GCS_AD_ENGINE';

    -- Context switches to FND_LOG for level constants can
    -- be avoided by copying them here once
    statementLogLevel   CONSTANT NUMBER := FND_LOG.level_statement;
    procedureLogLevel   CONSTANT NUMBER := FND_LOG.level_procedure;
    eventLogLevel       CONSTANT NUMBER := FND_LOG.level_event;
    exceptionLogLevel   CONSTANT NUMBER := FND_LOG.level_exception;
    errorLogLevel       CONSTANT NUMBER := FND_LOG.level_error;
    unexpectedLogLevel  CONSTANT NUMBER := FND_LOG.level_unexpected;

    -- Globally useful storage - make them global to the package so we
    -- don't have to pass them from procedure to procedure as args.
    requestId    number(15);       --concurrent request id
    currencyCode varchar2(15);     --currency for audit journals created here
    timeStamp    Date := SYSDATE;  --all journals get this datetime stamp
    xnsId        number(15);       --p_transaction_id from process_transaction
    dummy        number;           --used for numeric throw away return values

    --ruleAtts:
    --attributes used to locate the rule_id(s) we will process
    TYPE ruleAttsRecord IS RECORD (
      oldTreatment  number(15),
      newTreatment  number(15),
      xnsTypeCode   varchar2(30)
    );
    TYPE ruleAttsTable is TABLE of ruleAttsRecord INDEX BY binary_integer;
    ruleAtts ruleAttsTable;

    --ruleData:
    --local storage for RP parameter
    TYPE ruleDataTable IS
      TABLE OF GCS_RULES_PROCESSOR.ruleDataRecord INDEX BY BINARY_INTEGER;
    ruleData ruleDataTable;

    --contextData:
    --local storage for RP parameter
    TYPE contextDataTable IS
      TABLE OF GCS_RULES_PROCESSOR.contextRecord INDEX BY BINARY_INTEGER;
    contextData contextDataTable;

    -- Used in getting the netAssetValues
    TYPE  totalRecord IS RECORD (dr number, cr number);
    total totalRecord;

    --Exception handlers: everything that can go wrong here
    invalid_arguments         EXCEPTION;
    invalid_xns_type          EXCEPTION;
    no_rule_found             EXCEPTION;
    rule_processor_failure    EXCEPTION;
    missing_key               EXCEPTION;  -- a utility pkg hash key is missing

    ------------------------------------------
    -- Shared cursor definitions
    ------------------------------------------

    --xnsCursor:
    --Select the transaction control record(s)
    cursor xnsCursor is
      SELECT *
      FROM GCS_AD_TRANSACTIONS
      WHERE ad_transaction_id = xnsId;


    --linesCursor:
    --Select a trial balance
    --Sort the cursor by trial balance line number
    cursor linesCursor (tbType varchar2) is
      SELECT *
      FROM GCS_AD_TRIAL_BALANCES
      WHERE ad_transaction_id = xnsId
      AND   trial_balance_seq = tbType;

    Type xnsLinesTable is Table of linesCursor%ROWTYPE Index By binary_integer;
    xnsLines xnsLinesTable;


    --ruleCursor:
    --Find the correct elimination rule id(s)
    --5.17.04: Add condition: enabled_flag='Y'
    cursor ruleCursor (i number) is
      SELECT r.rule_id, r.rule_name
      FROM GCS_ELIM_RULES_VL r
      WHERE r.transaction_type_code  = ruleAtts(i).xnsTypeCode
      AND   r.from_treatment_id      = ruleAtts(i).oldTreatment
      AND   r.to_treatment_id        = ruleAtts(i).newTreatment
      AND   r.enabled_flag           ='Y';

    TYPE     ruleTable is TABLE of ruleCursor%ROWTYPE index by binary_integer;
    xnsRules ruleTable;


    --hierRelCursor:
    --Find the percentages, treatments, etc
    cursor hierRelCursor ( relId number) is
      SELECT t.hierarchy_name,
             d.dataset_code,
             r.hierarchy_id,
             r.treatment_id,
             r.ownership_percent,
             r.parent_entity_id   parentEntity,
             r.child_entity_id    childEntity,
             -1                   elimsEntity
      FROM GCS_HIERARCHIES_TL t,
           GCS_DATASET_CODES d,
           GCS_CONS_RELATIONSHIPS r
      WHERE t.language     = userenv('LANG')
      AND   t.hierarchy_id = r.hierarchy_id
      AND   d.hierarchy_id = r.hierarchy_id
      AND   r.cons_relationship_id = relId
      AND   r.actual_ownership_flag='Y';


    --netAssetValueCursor
    --Find the net asset value
    cursor navCursor(ataAtt NUMBER, ataVers NUMBER, liaAtt NUMBER, liaVers NUMBER) Is
      Select b.trial_balance_seq, sum( nvl(b.debit_amount,0) - nvl(b.credit_amount,0) )
      from   fem_ln_items_attr       lia,
             fem_ext_acct_types_attr ata,
             gcs_ad_trial_balances b
      where  lia.dim_attribute_varchar_member in ('ASSET', 'LIABILITY')
      and    ata.attribute_id          = ataAtt
      and    ata.version_id            = ataVers
      and    ata.ext_account_type_code = lia.dim_attribute_varchar_member
      and    lia.attribute_id          = liaAtt
      and    lia.version_id            = liaVers
      and    lia.line_item_id          = b.line_item_id
      and    b.ad_transaction_id       = xnsId
      group by b.trial_balance_seq;

  --+========================================================================+
  -- PACKAGE Private Members
  --+========================================================================+

    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- Call this for messages you want to see only when debugging the package
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    procedure writeToLog (buf IN Varchar2 := NULL) is
      errBuf Varchar2(5000) := substr(buf, 1, 5000);
    begin

      -- Do nothing if there is no message waiting
      If errBuf IS NOT NULL Then
        DBMS_OUTPUT.new_line;
        While errBuf is not null Loop
          DBMS_OUTPUT.put_line( substr( errBuf, 1, 250 ) );
          errBuf := substr( errBuf, 251 );
        End Loop;
        DBMS_OUTPUT.put_line('.');
        DBMS_OUTPUT.new_line;
      End If;

    end writeToLog;


    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- This makes embedding logging calls in the other code less intrusive
    -- and keeps the code more legible.
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    procedure logString (
      logLevel Number,
      logProc  Varchar2,
      logLabel Varchar2,
      logText  Varchar2
    ) is

      rootString varchar2(100) := 'gcs.plsql.GCS_AD_ENGINE.';

      errBuf Varchar2(5000);

    begin

      -- May be a message on the stack or
      -- a string passed in via the arg
      if logText IS NULL then
        errBuf := substr( FND_MESSAGE.get, 1, 5000 );
      else
        errBuf := substr( logText, 1, 5000 );
      end if;

/*      if runtimeLogLevel = -1 then
        writeToLog( rootString ||
                    logProc    || '.'  ||
                    logLabel   || ': ' ||
                    errBuf );
      end if;
*/
      if logLevel >= runtimeLogLevel then
        FND_LOG.string(
          logLevel,
          rootString || logProc || '.' || logLabel,
          errBuf);
      end if;

    end logString;


  --+========================================================================+
  -- PACKAGE PUBLIC Members
  --+========================================================================+

  PROCEDURE process_transaction (
    errbuf                 IN OUT NOCOPY  VARCHAR2,
    retcode                IN OUT NOCOPY  NUMBER,
    p_transaction_id       IN             NUMBER
  ) is

    procedureName Varchar2(30) := 'PROCESS_TRANSACTION';

    i number;  --throw away register

    newRelation      boolean := FALSE;
    endRelation      boolean := FALSE;

    fromRelData      hierRelCursor%ROWTYPE;
    toRelData        hierRelCursor%ROWTYPE;

    parentEntity     number;
    childEntity      number;
    elimsEntity      number;
    hierarchyId      number;
    dataSet          number;
    relationshipId   number;

    xnsData          xnsCursor%ROWTYPE;
    ccy              GCS_ENTITY_CONS_ATTRS.currency_code%TYPE;

    ruleErrorMsg varchar2(2000);
    ruleRetcode  number;

    --variables used to to look up and store the NAV
    liaAttr number;
    ataAttr number;
    liaVers number;
    ataVers number;
    liaKey  varchar2(100) := 'LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE';
    ataKey  varchar2(100) := 'EXT_ACCOUNT_TYPE_CODE-SIGN';
    navTB1  number;
    navTB2  number;
    tbSeq  number;
    navTmp  number;


    --Bugfix 4226223 : Used to populate the line type code on gcs_ad_transactionx 4226223 : Populate the line_type_code for A&D Entries
    l_line_item_vs_id         NUMBER  :=
                                     gcs_utility_pkg.g_gcs_dimension_info ('LINE_ITEM_ID').associated_value_set_id;
    l_ext_acct_type_attr      NUMBER  :=
                                     gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').attribute_id;
    l_ext_acct_type_version   NUMBER  :=
                                     gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE').version_id;
    l_basic_acct_type_attr    NUMBER  :=
                                     gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').attribute_id;
    l_basic_acct_type_version NUMBER  :=
                                     gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE').version_id;
    l_entry_id		      NUMBER(15);

  BEGIN

    logString( procedureLogLevel, procedureName, 'begin', to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, packageName || '.' || procedureName || ' ENTER');
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- Note that data integrity is assumed based on the dedicated UI
    -- We will enable logging to allow for runtime data integrity
    -- auditing when an issue is suspected, but do not need to check
    -- for data integrity per se.
    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    requestId := fnd_global.conc_request_id;
    xnsId     := p_transaction_id;
    retcode   := 0;
--    logString( eventLogLevel, procedureName, 'jh: xnsId = ', xnsId);
    --=======================================================
    logString( eventLogLevel, procedureName, 'section', '2');
    --=======================================================

    -------------------------------------
    -- Verify user access
    -------------------------------------
    --What to do here?

    --=======================================================
    logString( eventLogLevel, procedureName, 'section', '3');
    --=======================================================

    -------------------------------------
    --Find the xnsData record
    -------------------------------------
    Open xnsCursor;
    Fetch xnsCursor Into xnsData;
    Close xnsCursor;

    -- Place the request_id onto the header row and commit
    Update gcs_ad_transactions
    Set request_id = requestId
    Where ad_transaction_id = xnsId;
    If SQL%ROWCOUNT = 1 Then COMMIT;
    Else RAISE invalid_arguments;
    End If;

    --If this is a rerun, nuke the old stuff
/* Removed 4/26/04.  Per discussion 4/22/04: The AD UI will handle deleting
   entry lines if consolidation has not been run for the period

    if xnsData.assoc_entry_id IS NOT NULL then

      UPDATE gcs_entry_headers
      SET DISABLED_FLAG = 'Y'
      WHERE entry_id = xnsData.assoc_entry_id;

      DELETE FROM gcs_entry_lines
      WHERE entry_id = xnsData.assoc_entry_id;

    end if;
*/
--    if xnsRerun then
--      GCS_BALANCES_PROCESSOR.undoEntries( xnsId );
--    end if;

    --=======================================================
    logString( eventLogLevel, procedureName, 'section', '4');
    --=======================================================

    --================================================
    -- Obtain net asset value (NAV)
    --================================================

    --Get the attribute_id and version_id for the EXTENDED_ACCOUNT_TYPE
    declare
      liaKey  varchar2(100) := 'LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE';
    begin
      liaAttr := GCS_UTILITY_PKG.g_dimension_attr_info(liaKey).attribute_id;
      liaVers := GCS_UTILITY_PKG.g_dimension_attr_info(liaKey).version_id;
      logString( statementLogLevel, procedureName, 'liaAttr ', liaAttr);
      logString( statementLogLevel, procedureName, 'liaVers ', liaVers);
    exception
      when no_data_found then
        logString( exceptionLogLevel, procedureName, 'exception', 'missing_key');
        FND_MESSAGE.set_name( 'GCS', 'GCS_MISSING_KEY' );
        FND_MESSAGE.set_token( 'HASH_KEY' , liaKey );
        RAISE missing_key;
    end;

    --Get the attribute_id and version_id for the EXT_ACCOUNT_TYPE_CODE
    declare
      ataKey  varchar2(100) := 'EXT_ACCOUNT_TYPE_CODE-SIGN';
    begin
      ataAttr := GCS_UTILITY_PKG.g_dimension_attr_info(ataKey).attribute_id;
      ataVers := GCS_UTILITY_PKG.g_dimension_attr_info(ataKey).version_id;
      logString( statementLogLevel, procedureName, 'ataAttr ', ataAttr);
      logString( statementLogLevel, procedureName, 'ataVers ', ataVers);
    exception
      when no_data_found then
        logString( exceptionLogLevel, procedureName, 'exception', 'missing_key');
        FND_MESSAGE.set_name( 'GCS', 'GCS_MISSING_KEY' );
        FND_MESSAGE.set_token( 'HASH_KEY' , ataKey );
        RAISE missing_key;
    end;

    --Get the NAV
    Open navCursor(ataAttr, ataVers, liaAttr, liaVers);
      loop
        Fetch navCursor Into tbSeq, navTmp;
        Exit when navCursor%NOTFOUND;
        if tbSeq = 1 then
          navTB1 := navTmp;
        elsif tbSeq =2 then
         navTB2 := navTmp;
        end if;
      end loop;
    Close navCursor;

    --================================================
    -- Collect ruleData, contextData
    --================================================

    ruleData.DELETE;
    ruleAtts.DELETE;

    if xnsData.pre_cons_relationship_id is NULL then
      newRelation := TRUE;
    else
      Open hierRelCursor( xnsData.pre_cons_relationship_id );
      Fetch hierRelCursor Into fromRelData;
      Close hierRelCursor;
    end if;

    if xnsData.post_cons_relationship_id is NULL then
      endRelation := TRUE;
    else
      Open hierRelCursor( xnsData.post_cons_relationship_id );
      Fetch hierRelCursor Into toRelData;
      Close hierRelCursor;
    end if;

    If    newRelation then

      --The first-time ever AD event would have to be an ACQ transaction.
      --The pre_cons_relationship_id in this case is NULL and the previous
      --treatment and ownership percentage are stored in the intermediate_
      --columns of the transaction table. Only the toRelData record has data.

      if xnsData.transaction_type_code <> 'ACQ' then
        RAISE invalid_xns_type;
      end if;
      -- There will only be one rule to run
      ruleData(1).fromPercent   := 0;
      ruleData(1).toPercent     := toRelData.ownership_percent/100;
      ruleData(1).consideration := xnsData.total_consideration;
      ruleData(1).netAssetValue := navTB1;--xnsData.net_asset_value;


      ruleAtts(1).oldTreatment  := xnsData.intermediate_treatment_id;
      ruleAtts(1).newTreatment  := toRelData.treatment_id;
      ruleAtts(1).xnsTypeCode   := xnsData.transaction_type_code;

      --Use the toRelData record to identify the entities
      parentEntity   := toRelData.parentEntity;
      childEntity    := toRelData.childEntity;
      hierarchyId    := toRelData.hierarchy_id;
      dataSet        := toRelData.dataset_code;
      relationshipId := xnsData.post_cons_relationship_id;

    Elsif endRelation then

      -- A disposal resulting in zero ownership MUST be a DIS transaction.
      -- The post_cons_relationship_id in this case is NULL and the final
      -- treatment and percentage are in the intermediate_ columns in the
      -- transaction table.

      if xnsData.transaction_type_code <> 'DIS' then
        RAISE invalid_xns_type;
      end if;
      -- There will only be one rule to run
      ruleData(1).fromPercent   := fromRelData.ownership_percent/100;
      ruleData(1).toPercent     := 0;
      ruleData(1).consideration := xnsData.total_consideration;
      ruleData(1).netAssetValue := navTB1;--xnsData.net_asset_value;

      ruleAtts(1).oldTreatment  := fromRelData.treatment_id;
      ruleAtts(1).newTreatment  := xnsData.intermediate_treatment_id;
      ruleAtts(1).xnsTypeCode   := xnsData.transaction_type_code;

      --Use the fromRelData record to identify the entities
      parentEntity   := fromRelData.parentEntity;
      childEntity    := fromRelData.childEntity;
      hierarchyId    := fromRelData.hierarchy_id;
      dataSet        := fromRelData.dataset_code;
      relationshipId := xnsData.pre_cons_relationship_id;


    Elsif    xnsData.transaction_type_code = 'PO+' Then
      -- PO+ is ALWAYS followed by an implied AQ+
      --   - PO- inherits the "from" data via the hierarchy
      --   - AQ+ inherits the "to" data via the hierarchy
      -- Intermediate data is on the xnsData record


      --Set up data and atts for the first (PO+) rule
      ruleData(1).fromPercent   := fromRelData.ownership_percent/100;
      ruleData(1).toPercent     := xnsData.intermediate_percent_owned/100;
      ruleData(1).consideration := 0;
      ruleData(1).netAssetValue := navTB1;--xnsData.net_asset_value;

      ruleAtts(1).oldTreatment  := fromRelData.treatment_id;
      ruleAtts(1).newTreatment  := xnsData.intermediate_treatment_id;
      -- 09.01.04: jh:replace use of PO+
      ruleAtts(1).xnsTypeCode   := 'PO-';

      --Set up data and atts for the second (AQ+) rule
      ruleData(2).fromPercent   := ruleData(1).toPercent/100;
      ruleData(2).toPercent     := toRelData.ownership_percent/100;
      ruleData(2).consideration := xnsData.total_consideration;
      ruleData(2).netAssetValue := navTB2;--xnsData.net_asset_value;

      ruleAtts(2).oldTreatment  := ruleAtts(1).newTreatment;
      ruleAtts(2).newTreatment  := toRelData.treatment_id;
      ruleAtts(2).xnsTypeCode   := 'AQ+';

      --Use the toRelData record to identify the entities
      parentEntity   := toRelData.parentEntity;
      childEntity    := toRelData.childEntity;
      hierarchyId    := toRelData.hierarchy_id;
      dataSet        := toRelData.dataset_code;
      relationshipId := xnsData.post_cons_relationship_id;

    Else
      -- There will only be one rule to run
      ruleData(1).fromPercent   := fromRelData.ownership_percent/100;
      ruleData(1).toPercent     := toRelData.ownership_percent/100;
      ruleData(1).consideration := xnsData.total_consideration;
      ruleData(1).netAssetValue := navTB1;--xnsData.net_asset_value;

      ruleAtts(1).oldTreatment  := fromRelData.treatment_id;
      ruleAtts(1).newTreatment  := toRelData.treatment_id;
      ruleAtts(1).xnsTypeCode   := xnsData.transaction_type_code;

      --Use the toRelData record to identify the entities
      parentEntity   := toRelData.parentEntity;
      childEntity    := toRelData.childEntity;
      hierarchyId    := toRelData.hierarchy_id;
      dataSet        := toRelData.dataset_code;
      relationshipId := xnsData.post_cons_relationship_id;
    End If;

    logString( statementLogLevel, procedureName, 'parameter',
              'fromPercent     => ' || ruleData(1).fromPercent );
    logString( statementLogLevel, procedureName, 'parameter',
              'toPercent       => ' || ruleData(1).toPercent );
    logString( statementLogLevel, procedureName, 'parameter',
              'consideration   => ' || ruleData(1).consideration );
    logString( statementLogLevel, procedureName, 'parameter',
              'netAssetValue   => ' || ruleData(1).netAssetValue );
    logString( statementLogLevel, procedureName, 'parameter',
              'oldTreatment    => ' || ruleAtts(1).oldTreatment );
    logString( statementLogLevel, procedureName, 'parameter',
              'newTreatment    => ' || ruleAtts(1).newTreatment );
    logString( statementLogLevel, procedureName, 'parameter',
              'xnsTypeCode     => ' || ruleAtts(1).xnsTypeCode );
    logString( statementLogLevel, procedureName, 'parameter',
              'parentEntity    => ' || parentEntity );
    logString( statementLogLevel, procedureName, 'parameter',
              'childEntity     => ' || childEntity );
    logString( statementLogLevel, procedureName, 'parameter',
              'hierarchyId     => ' || hierarchyId );
    logString( statementLogLevel, procedureName, 'parameter',
              'dataset         => ' || dataset );
    logString( statementLogLevel, procedureName, 'parameter',
              'relationshipId  => ' || relationshipId );

    --=======================================================
    logString( eventLogLevel, procedureName, 'section', '5');
    --=======================================================

    --Find elimination rule(s)
    xnsRules.DELETE;
    For x IN ruleAtts.FIRST..ruleAtts.LAST Loop
      Open ruleCursor( x );
      Fetch ruleCursor Into xnsRules(x);
      if ruleCursor%NOTFOUND then
        Close ruleCursor;
        RAISE no_rule_found;
      end if;
      Close ruleCursor;
    End Loop;

    --=======================================================
    logString( eventLogLevel, procedureName, 'section', '6');
    --=======================================================

    -- Get the elimsEntity.

    declare
      key  varchar2(100) := 'ENTITY_ID-ELIMINATION_ENTITY';
      attr number;
      vers number;

      --jh 5.18.04: elims entity_id is stored in dim_attribute_numeric_member,
      --not entity_id
      cursor elimsEntityCursor is
        SELECT f.dim_attribute_numeric_member, g.currency_code
        FROM GCS_ENTITY_CONS_ATTRS g,
             FEM_ENTITIES_ATTR     f
        WHERE f.attribute_id = attr
        AND   f.version_id   = vers
        AND   f.entity_id    = g.entity_id
        AND   g.hierarchy_id = hierarchyId
        AND   g.entity_id    = parentEntity;
    begin

      --Get attribute_id and version_id (throws no_data_found if data error)
      attr := GCS_UTILITY_PKG.g_dimension_attr_info(key).attribute_id;
      vers := GCS_UTILITY_PKG.g_dimension_attr_info(key).version_id;
      logString( statementLogLevel, procedureName, 'parameter',
                 'attribute_id    => ' ||attr);
      logString( statementLogLevel, procedureName, 'parameter',
                 'version_id      => ' || vers);
      --Get the elims entity and currency
      Open elimsEntityCursor;
      Fetch elimsEntityCursor Into elimsEntity, ccy;
      Close elimsEntityCursor;
      logString( statementLogLevel, procedureName, 'parameter',
                 'elimsEntity     => ' || elimsEntity );
      logString( statementLogLevel, procedureName, 'parameter',
                 'ccy             => ' || ccy );
    exception
      when no_data_found then
        logString( exceptionLogLevel, procedureName, 'exception', 'missing_key');
        FND_MESSAGE.set_name( 'GCS', 'GCS_MISSING_KEY' );
        FND_MESSAGE.set_token( 'HASH_KEY' , key );

        RAISE missing_key;
    end;

    --=======================================================
    logString( eventLogLevel, procedureName, 'section', '7');
    --=======================================================
    --jh 5.14.04: add eventCategory, 'ACQ_DISP'
    -- Set up the contextData, suspenseDims
    contextData.DELETE;
    For x In ruleData.FIRST..ruleData.LAST Loop
      contextdata(x).eventType    := 'A';
      contextData(x).eventKey     := xnsId;
      contextData(x).parentEntity := parentEntity;
      contextData(x).childEntity  := childEntity;
      contextData(x).elimsEntity  := elimsEntity;
      contextData(x).datasetCode  := dataSet;
      contextData(x).hierarchy    := hierarchyId;
      contextData(x).calPeriodId  := xnsData.cal_period_id;
      contextData(x).currencyCode := ccy;
      contextData(x).relationship := relationshipId;
      contextData(x).eventCategory := 'ACQ_DISP';

    End Loop;

    --=======================================================
    logString( eventLogLevel, procedureName, 'section', '8');
    --=======================================================

    -------------------------------------
    -- Process rule steps
    -------------------------------------
    For x in ruleData.FIRST..ruleData.LAST Loop

      ruleRetcode := GCS_RULES_PROCESSOR.process_rule (
                       p_rule_id       => xnsRules(x).rule_id,
                       p_stat_flag     =>'N',
                       p_context       => contextData(x),
                       p_rule_data     => ruleData(x));

      --Bugfix 4226223 : Populate the line_type_code on gcs_entry_lines
      BEGIN
	SELECT 	assoc_entry_id
	INTO	l_entry_id
	FROM	gcs_ad_transactions
	WHERE	ad_transaction_id	=	p_transaction_id;

        -- Bugfix 6469074: Remove call to update the line_type_code
        /*
	IF (l_entry_id	IS NOT NULL) THEN
          UPDATE  gcs_entry_lines gel
          SET     line_type_code          =       DECODE(
                                                        (SELECT feata.dim_attribute_varchar_member
                                                         FROM   fem_ext_acct_types_attr         feata,
                                                                fem_ln_items_attr               flia
                                                         WHERE  gel.line_item_id                =       flia.line_item_id
                                                         AND    flia.value_set_id               =       l_line_item_vs_id
                                                         AND    flia.attribute_id               =       l_ext_acct_type_attr
                                                         AND    flia.version_id                 =       l_ext_acct_type_version
                                                         AND    feata.attribute_id              =       l_basic_acct_type_attr
                                                         AND    feata.version_id                =       l_basic_acct_type_version
                                                         AND    feata.ext_account_type_code     =       flia.dim_attribute_varchar_member
                                                        ), 'REVENUE', 'PROFIT_LOSS',
                                                           'EXPENSE', 'PROFIT_LOSS',
                                                           'BALANCE_SHEET'
                                                        )
          WHERE   entry_id                =       l_entry_id
	  AND	  line_type_code	  IS NOT NULL;
        END IF;
        */
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      If ruleRetcode > 0 then

        ruleErrorMsg := FND_MESSAGE.get;
        FND_MESSAGE.set_name( 'GCS', 'GCS_RULE_FAILURE' );
        FND_MESSAGE.set_token( 'PROCEDURE', packageName||'.'||procedureName );
        FND_MESSAGE.set_token( 'RULE_NAME', xnsRules(x).rule_name );
        logString( exceptionLogLevel, procedureName, 'exception', FND_MESSAGE.get);
        if ruleErrorMsg IS NOT NULL then
          logString( exceptionLogLevel, procedureName, 'exception', ruleErrorMsg);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, packageName || '.' || procedureName || ' ERROR: ' || ruleErrorMsg);
          FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

        end if;

        if    ruleRetcode = 1 then
          FND_MESSAGE.set_name( 'GCS', 'GCS_CONCREQ_WARNING' );
          errbuf  := FND_MESSAGE.get;
          retcode := 1;
        elsif ruleRetcode = 2 then
          retcode := 2;
          FND_MESSAGE.set_name( 'GCS', 'GCS_CONCREQ_FAILURE' );
          errbuf  := FND_MESSAGE.get;
          RAISE rule_processor_failure;
        elsif ruleRetCode = 3 then
          --special case indicates out of balance entry
          retcode := 2;
          FND_MESSAGE.set_name( 'GCS', 'GCS_CONCREQ_FAILURE' );
          errbuf  := FND_MESSAGE.get;
          RAISE rule_processor_failure;
        end if;

      End If;

    End Loop;  --for x in 1..xnsData.LAST

    --=======================================================
    logString( eventLogLevel, procedureName, 'section', '9');
    --=======================================================

    -- ++++++++++++++++++++++++++++++++++++
    -- CLEAN UP SECTION
    -- ++++++++++++++++++++++++++++++++++++

    -- Cannot get here unless retcode is a 0 (success) or a 1 (warning)
    COMMIT;

    --=======================================================
    logString( eventLogLevel, procedureName, 'section', '11');
    --=======================================================

    -------------------------------------
    -- Write out file
    -------------------------------------

    -------------------------------------
    -- Write log file footer and return
    -------------------------------------
    FND_MESSAGE.set_name( 'GCS', 'GCS_CONCREQ_SUCCESS' );
    errbuf  := FND_MESSAGE.get;

    logString( procedureLogLevel, procedureName, 'end', to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, packageName || '.' || procedureName || ' END');
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);


    -- ++++++++++++++++++++++++++++++++++++
    -- ERROR HANDLERS
    -- ++++++++++++++++++++++++++++++++++++

  EXCEPTION

    WHEN invalid_arguments THEN
      -- The only way this can raise is if the transaction_id is not valid
      -- As such, no point to update the interface rows' status_code and
      -- no need to commit (since no changes are made in the handler)
      ROLLBACK;
      FND_MESSAGE.set_name( 'GCS', 'GCS_INVALID_COMMAND_LINE' );
      FND_MESSAGE.set_token( 'PROCEDURE' , packageName||'.'||procedureName );
      logString( exceptionLogLevel, procedureName, 'GCS', FND_MESSAGE.get );

      FND_MESSAGE.set_name( 'GCS', 'GCS_CONCREQ_FAILURE' );
      errbuf    := FND_MESSAGE.get;
      retcode   := 2;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, packageName || '.' || procedureName || ' ERROR: ' || errbuf);
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

      logString( procedureLogLevel, procedureName, 'end', to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    WHEN invalid_xns_type THEN
      ROLLBACK;
      FND_MESSAGE.set_name( 'GCS', 'GCS_INVALID_XNS_TYPE' );
      FND_MESSAGE.set_token( 'PROCEDURE' , packageName||'.'||procedureName );
      FND_MESSAGE.set_token( 'TRANSACTION_TYPE', xnsData.transaction_type_code );
      logString( exceptionLogLevel, procedureName, 'GCS', FND_MESSAGE.get );

      FND_MESSAGE.set_name( 'GCS', 'GCS_CONCREQ_FAILURE' );
      errbuf    := FND_MESSAGE.get;
      retcode   := 2;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, packageName || '.' || procedureName || ' ERROR: ' || errbuf);
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

      logString( procedureLogLevel, procedureName, 'end', to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    WHEN no_rule_found THEN
      ROLLBACK;
      FND_MESSAGE.set_name( 'GCS', 'GCS_MISSING_RULE' );
      FND_MESSAGE.set_token( 'PROCEDURE' , packageName||'.'||procedureName );
      logString( exceptionLogLevel, procedureName, 'GCS', FND_MESSAGE.get );

      FND_MESSAGE.set_name( 'GCS', 'GCS_CONCREQ_FAILURE' );
      errbuf    := FND_MESSAGE.get;
      retcode   := 2;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, packageName || '.' || procedureName || ' ERROR: ' || errbuf);
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

      logString( procedureLogLevel, procedureName, 'end', to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    WHEN missing_key THEN
      --An error msg is placed on the stack at the exception raise point
      --A logString call is made at the exception raise point
      ROLLBACK;
      FND_MESSAGE.set_name( 'GCS', 'GCS_CONCREQ_FAILURE' );
      errbuf    := FND_MESSAGE.get;
      retcode   := 2;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, packageName || '.' || procedureName || ' ERROR: ' || errbuf);
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

      logString( procedureLogLevel, procedureName, 'end', to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    WHEN rule_processor_failure THEN
      --errbuf and retcode are set at the point where this is raised
      ROLLBACK;
      logString( procedureLogLevel, procedureName, 'end', to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    WHEN OTHERS THEN
      ROLLBACK;
      FND_MESSAGE.set_name( 'GCS', 'GCS_UNHANDLED_EXCEPTION' );
      FND_MESSAGE.set_token( 'PROCEDURE' , packageName||'.'||procedureName );
      FND_MESSAGE.set_token( 'EVENT', 'OTHERS' );
      logString( exceptionLogLevel, procedureName, 'GCS', FND_MESSAGE.get );

      FND_MESSAGE.set_name( 'GCS', 'GCS_CONCREQ_FAILURE' );
      retcode   := 2;
      errbuf    := FND_MESSAGE.get;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, packageName || '.' || procedureName || ' ERROR: '|| errbuf);
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

      logString( procedureLogLevel, procedureName, 'end', to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

  END process_transaction;

    --
    -- PACKAGE "Constructor"
    --

END GCS_AD_ENGINE;

/
