--------------------------------------------------------
--  DDL for Package Body QLTDACTB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTDACTB" as
/* $Header: qltdactb.plb 120.13.12010000.6 2010/02/25 12:12:46 pdube ship $ */
-- 2/8/95 - created
-- Kevin Wiggen


  PROCEDURE INSERT_ACTION_LOG(X_PLAN_ID NUMBER,
                              X_COLLECTION_ID NUMBER,
                              X_CREATION_DATE DATE,
                              X_CHAR_ID NUMBER,
                              X_OPERATOR NUMBER,
                              X_LOW_VALUE VARCHAR2,
                              X_HIGH_VALUE VARCHAR2,
                              X_MESSAGE VARCHAR2,
                              X_RESULT VARCHAR2,
                              X_CONCURRENT NUMBER)  IS


    user_id NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;

  BEGIN

    user_id := NVL(FND_PROFILE.VALUE('USER_ID'), 0);

    if X_CONCURRENT = 1 then -- Online

       X_REQUEST_ID := FND_PROFILE.VALUE('REQUEST_ID');
       X_PROGRAM_APPLICATION_ID :=
                        FND_PROFILE.VALUE('CONC_PROGRAM_APPLICATION_ID');
       X_PROGRAM_ID := FND_PROFILE.VALUE('CONC_PROGRAM_ID');
       X_LAST_UPDATE_LOGIN := FND_PROFILE.VALUE('CONC_LOGIN_ID');

       insert into qa_action_log (LOG_ID,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATED_BY,
                                  CREATION_DATE,
                                  CREATED_BY,
                                  LAST_UPDATE_LOGIN,
                                  REQUEST_ID,
                                  PROGRAM_APPLICATION_ID,
                                  PROGRAM_ID,
                                  PROGRAM_UPDATE_DATE,
                                  PLAN_ID,
                                  COLLECTION_ID,
                                  TRANSACTION_DATE,
                                  CHAR_ID,
                                  OPERATOR,
                                  LOW_VALUE,
                                  HIGH_VALUE,
                                  ACTION_LOG_MESSAGE,
                                  RESULT_VALUE)
       values (qa_action_log_s.NEXTVAL,
               SYSDATE,
               user_id,
               SYSDATE,
               user_id,
               X_LAST_UPDATE_LOGIN,
               X_REQUEST_ID,
               X_PROGRAM_APPLICATION_ID,
               X_PROGRAM_ID,
               SYSDATE,
               X_PLAN_ID,
               X_COLLECTION_ID,
               X_CREATION_DATE,
               X_CHAR_ID,
               X_OPERATOR,
               X_LOW_VALUE,
               X_HIGH_VALUE,
               X_MESSAGE,
               X_RESULT);

   else

       insert into qa_action_log (LOG_ID,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATED_BY,
                                  CREATION_DATE,
                                  CREATED_BY,
                                  PLAN_ID,
                                  COLLECTION_ID,
                                  TRANSACTION_DATE,
                                  CHAR_ID,
                                  OPERATOR,
                                  LOW_VALUE,
                                  HIGH_VALUE,
                                  ACTION_LOG_MESSAGE,
                                  RESULT_VALUE)
       values (qa_action_log_s.NEXTVAL,
               SYSDATE,
               user_id,
               SYSDATE,
               user_id,
               X_PLAN_ID,
               X_COLLECTION_ID,
               X_CREATION_DATE,
               X_CHAR_ID,
               X_OPERATOR,
               X_LOW_VALUE,
               X_HIGH_VALUE,
               X_MESSAGE,
               X_RESULT);
   end if;

  end INSERT_ACTION_LOG;


  -- Added X_ARGUMENT in the signature of DO_ACTIONS.
  -- X_ARGUMENT will get the value IMPORT from qltactwb.plb
  -- if collection import is used.In other cases it will be NULL.
  -- Bug 3273447. suramasw

  FUNCTION  DO_ACTIONS(X_TXN_HEADER_ID NUMBER,
                       X_CONCURRENT NUMBER ,              -- DEFAULT NULL
                       X_PO_TXN_PROCESSOR_MODE VARCHAR2 , -- DEFAULT NULL
                       X_GROUP_ID NUMBER ,                -- DEFAULT NULL
                       X_BACKGROUND BOOLEAN ,             -- DEFAULT NULL
                       X_DEBUG BOOLEAN ,                  -- DEFAULT NULL
                       X_ACTION_TYPE VARCHAR2,            -- DEFAULT NULL
                       X_PASSED_ID_NAME VARCHAR2 ,        -- DEFAULT NULL
                       P_OCCURRENCE NUMBER ,              -- DEFAULT NULL
                       P_PLAN_ID NUMBER,                  -- DEFAULT NULL
                       X_ARGUMENT VARCHAR2)               -- DEFAULT NULL

        RETURN BOOLEAN IS

    TYPE numtable IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;
    TYPE char30table IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;
    TYPE char150table IS TABLE OF VARCHAR2(150)
      INDEX BY BINARY_INTEGER;

    char_id_tab numtable;
    datatype_tab numtable;
    fk_type_tab numtable;
    column_tab char30table;
    operator_tab numtable;
    low_value_tab char150table;
    high_value_tab char150table;
    action_id_tab numtable;
    pcat_id_tab numtable;
    pca_id_tab numtable;
    seq_id_tab numtable;

--
-- See Bug 2624112
--
-- Modified the query for Global Specifications Enhancements
--
-- Added new table to FROM list and modified the WHERE clause
--
-- rkunchal
--

-- bug 3402856. rkaza. 01/27/2004.
-- Same problem as in bug 2767550. Making the same fix here.
-- Problem introduced by incorrect join conditions of global spec stuff.

 CURSOR action_triggers(X_PLAN_ID NUMBER,
                       X_SPEC_ID NUMBER) is
 SELECT qpc.char_id CHAR_ID,
        qc.datatype TYPE,
        qc.fk_lookup_type FK_LOOKUP_TYPE,
        NVL(qc.hardcoded_column,qpc.result_column_name) Q_COLUMN,
        qpcat.operator OPERATOR,
        decode(X_SPEC_ID, 0,
               decode(qpcat.low_value_lookup,
                7,qc.lower_reasonable_limit,
                6,qc.lower_spec_limit,
                5,qc.lower_user_defined_limit,
                4,qc.target_value,
                3,qc.upper_user_defined_limit,
                2,qc.upper_spec_limit,
                1,qc.upper_reasonable_limit,
                NULL,qpcat.low_value_other),
               decode(qpcat.low_value_lookup,
                7,qscqs.lower_reasonable_limit,
                6,qscqs.lower_spec_limit,
                5,qscqs.lower_user_defined_limit,
                4,qscqs.target_value,
                3,qscqs.upper_user_defined_limit,
                2,qscqs.upper_spec_limit,
                1,qscqs.upper_reasonable_limit,
                NULL,qpcat.low_value_other)) LOW_VALUE,
        decode(X_SPEC_ID, 0,
               decode(qpcat.high_value_lookup,
                7,qc.lower_reasonable_limit,
                6,qc.lower_spec_limit,
                5,qc.lower_user_defined_limit,
                4,qc.target_value,
                3,qc.upper_user_defined_limit,
                2,qc.upper_spec_limit,
                1,qc.upper_reasonable_limit,
                NULL,qpcat.high_value_other),
               decode(qpcat.high_value_lookup,
                7,qscqs.lower_reasonable_limit,
                6,qscqs.lower_spec_limit,
                5,qscqs.lower_user_defined_limit,
                4,qscqs.target_value,
                3,qscqs.upper_user_defined_limit,
                2,qscqs.upper_spec_limit,
                1,qscqs.upper_reasonable_limit,
                NULL,qpcat.high_value_other)) HIGH_VALUE,
        qpca.action_id ACTION,
        qpca.plan_char_action_id PCA_ID,
        qpcat.trigger_sequence SEQ_ID,
        qpcat.plan_char_action_trigger_id PCAT_ID,
            nvl(qscqs.uom_code, qc.uom_code) SPEC_CHAR_UOM,
            nvl(qpc.uom_code, qc.uom_code) PLAN_CHAR_UOM,
            qpc.decimal_precision DECIMAL_PRECISION
 FROM qa_chars qc,
        qa_plan_chars qpc,
        qa_plan_char_action_triggers qpcat,
        qa_plan_char_actions qpca,
        qa_actions qa,
       (select
         qsc.CHAR_ID,
         qsc.ENABLED_FLAG,
         qsc.TARGET_VALUE,
         qsc.UPPER_SPEC_LIMIT,
         qsc.LOWER_SPEC_LIMIT,
         qsc.UPPER_REASONABLE_LIMIT,
         qsc.LOWER_REASONABLE_LIMIT,
         qsc.UPPER_USER_DEFINED_LIMIT,
         qsc.LOWER_USER_DEFINED_LIMIT,
         qsc.UOM_CODE
        from
         qa_spec_chars qsc,
         qa_specs qs
        where
         qsc.spec_id = qs.common_spec_id and
         qs.spec_id = X_SPEC_ID
        ) qscqs
 WHERE qpc.plan_id = X_PLAN_ID
        and qpc.char_id = qc.char_id
        and qc.char_id = qscqs.char_id (+)
        and qpcat.plan_id (+) = X_PLAN_ID
        and qpcat.char_id (+) = qpc.char_id
        and qpca.plan_char_action_trigger_id (+) =
            qpcat.plan_char_action_trigger_id
        and qpca.action_id = qa.action_id
        and (qa.online_flag = 2 or qa.action_id = 24)
        and qa.enabled_flag = 1
 ORDER BY qpc.prompt_sequence, qpcat.trigger_sequence,
          qpcat.plan_char_action_trigger_id;

  Cursor MY_MESSAGE(X_PCA_ID NUMBER) is
    select MESSAGE, ASSIGN_TYPE from qa_plan_char_actions
                   where PLAN_CHAR_ACTION_ID = X_PCA_ID;

  Cursor WORKFLOW_itemtype(X_PCA_ID VARCHAR2) is
    select MESSAGE from qa_plan_char_actions
        where PLAN_CHAR_ACTION_ID = X_PCA_ID;

  Cursor WF_ITEMTYPE_SELECTOR(WORKFLOW_ITEMTYPE VARCHAR2) IS
    select wf_selector
      from wf_item_types
     where name = WORKFLOW_ITEMTYPE;

  Cursor WF_NUMBER_OF_PROCESSES(WORKFLOW_ITEMTYPE VARCHAR2) IS
     select count (*)
     from wf_runnable_processes_v
     where item_type = WORKFLOW_ITEMTYPE;

  Cursor MY_STATUS(X_PCA_ID NUMBER) is
    select STATUS_CODE from qa_plan_char_actions
                   where PLAN_CHAR_ACTION_ID = X_PCA_ID;


  -- Bug 5196076. SQL Repository Fix SQL ID 17898864.
  -- Removed usage of inv_organization_info_v and replaced with
  -- call to base table hr_organization_information
  -- to improve performance.
  Cursor MY_OP_UNIT ( ORG_ID NUMBER ) is
      SELECT to_number(org_information3)
      FROM   hr_organization_information
      WHERE  organization_id = ORG_ID
      AND    org_information_context = 'Accounting Information';

/*
  Bug 4958762: SQL Repository Fix SQL ID: 15008200
  Cursor MY_OP_UNIT ( ORG_ID NUMBER ) is
      SELECT
        operating_unit
      FROM inv_organization_info_v
      WHERE organization_id = ORG_ID ;
*/

/*
    Select Operating_Unit from org_organization_definitions
           Where Organization_id = ORG_ID ;
*/
   -- Bug 4958762: SQL Repository Fix SQL ID: 15008214
  Cursor MY_STEP(X_PLAN_ID NUMBER) is
      SELECT
          result_column_name
      FROM qa_plan_chars
      WHERE plan_id = x_plan_id
          AND char_id = 23;
/*
    select RESULT_COLUMN_NAME from qa_plan_chars
                   where PLAN_ID = X_PLAN_ID
                   and CHAR_ID in (select char_id
                                     from qa_chars
                                     where developer_name =
                                     'TO_INTRAOPERATION_STEP');
*/

  Cursor MY_STEP_LOOKUP(X_MEANING VARCHAR2) is
    select lookup_code from mfg_lookups
                   where meaning = X_MEANING
                   and lookup_type = 'WIP_INTRAOPERATION_STEP';

  Cursor MY_ASSIGNED_CHAR_ID(X_PCA_ID NUMBER, X_ACTION_ID NUMBER) is
    select ASSIGNED_CHAR_ID
    from QA_PLAN_CHAR_ACTIONS
    where PLAN_CHAR_ACTION_ID = X_PCA_ID
      and ACTION_ID = X_ACTION_ID;

  -- Bug 4958762: SQL Repository Fix SQL ID: 15008263
  CURSOR MY_RESULTS_COLUMN(X_PLAN_ID NUMBER) IS
        SELECT
            NVL(qc.hardcoded_column,qpc.result_column_name) Q_COLUMN,
            qc.developer_name DEV_NAME
        FROM qa_plan_chars qpc,
            qa_chars qc
        WHERE qpc.plan_id = X_PLAN_ID
            AND qc.char_id = qpc.char_id
            AND qc.char_context_flag <> 3
        ORDER BY qc.char_id;

/*
     SELECT NVL(qpcv.hardcoded_column,qpcv.result_column_name) Q_COLUMN,
            qpcv.developer_name DEV_NAME
     FROM qa_plan_chars_v qpcv
     WHERE qpcv.plan_id = X_PLAN_ID
       AND qpcv.char_context_flag <> 3
     ORDER BY qpcv.char_id;
*/

  RC MY_RESULTS_COLUMN%ROWTYPE;

  CURSOR MY_REASON_ID(X_REASON_CODE VARCHAR2) IS
     SELECT REASON_ID FROM MTL_TRANSACTION_REASONS_VAL_V
     WHERE REASON_NAME = X_REASON_CODE;

  CURSOR MY_EMPLOYEE_ID(X_EMPLOYEE VARCHAR2) IS
     SELECT EMPLOYEE_ID FROM HR_EMPLOYEES_CURRENT_V
     WHERE FULL_NAME = X_EMPLOYEE;

--kaza

  CURSOR Get_result_column_name(elem_id NUMBER, col_plan_id NUMBER) IS
        select result_column_name
        from qa_plan_chars
        where char_id = elem_id and
        plan_id = col_plan_id;


  CURSOR Get_user_message(elem_id NUMBER,col_plan_id NUMBER, act_id NUMBER) IS
        select qpca.message
        from qa_plan_char_actions qpca, qa_plan_char_action_triggers qpcat
        where qpcat.char_id = elem_id and
              qpcat.plan_id = col_plan_id and
              qpcat.plan_char_action_trigger_id = qpca.plan_char_action_trigger_id and
              qpca.action_id = act_id;

  CURSOR Get_priority_id(value VARCHAR2) IS
        select lookup_code
        from mfg_lookups
        where lookup_type =  'WIP_EAM_ACTIVITY_PRIORITY' and
        meaning = value;


  CURSOR Get_eam_firm_flag(org_id NUMBER) IS
	select auto_firm_flag
	from wip_eam_parameters
	where organization_id = org_id ;


/*
  CURSOR Get_operator_type(operator_number number) IS
        select meaning
        from mfg_lookups
        where lookup_type = 'QA_OPERATOR' and
        lookup_code = operator_number;
*/

--kaza


--  CURSOR MY_PO_GROUP_ID IS
--    SELECT rcv_interface_groups_s.nextval
--    FROM dual;

  -- used for action 18, 19 to
  -- get status id for  lot/serial statuses
  CURSOR MY_STATUS_ID (X_PCA_ID NUMBER) IS
      SELECT STATUS_ID FROM QA_PLAN_CHAR_ACTIONS
      WHERE PLAN_CHAR_ACTION_ID = X_PCA_ID;

  -- Bug 8849343.Added this cursor and a variable to check
  -- if the eam_item_type has value 1(asset group) or 3(rebuildable)
  -- ntungare
  CURSOR Get_eam_item_type(org_id NUMBER, asset_instance_id NUMBER) IS
      SELECT msib.eam_item_type
      FROM csi_item_instances cii,
           mtl_system_items_b msib,
           mtl_parameters mp
      WHERE msib.organization_id = mp.organization_id and
      msib.organization_id = cii.last_vld_organization_id and
      msib.inventory_item_id = cii.inventory_item_id and
      msib.eam_item_type in (1,3) and
      msib.serial_number_control_code <> 1 and
      sysdate between nvl(cii.active_start_date, sysdate-1)
                and nvl(cii.active_end_date, sysdate+1) and
      mp.maint_organization_id = org_id and
      cii.instance_id = asset_instance_id;

  l_eam_item_type NUMBER;

  Y_SPEC_ID NUMBER;
  Y_PLAN_ID NUMBER;
  OLD_SPEC_ID NUMBER := -9999;
  OLD_PLAN_ID NUMBER := -9999;
  i BINARY_INTEGER := 0;
  total_rows BINARY_INTEGER;
  result VARCHAR2(150);
  done BOOLEAN;
  output NUMBER;
  output2 NUMBER;
  output3 NUMBER;
  output4 NUMBER;
  X_STATUS VARCHAR2(240);
  RES_COL_NAME VARCHAR2(30);
  INTEROP_STEP VARCHAR2(30);
  X_message VARCHAR2(2500);
  X_org_id NUMBER;
  X_CREATION_DATE DATE;
  X_COLLECTION_ID NUMBER;
  X_OCCURRENCE NUMBER;
  X_ERROR BOOLEAN := TRUE;
  X_ASSIGNED_CHAR_ID NUMBER;
  X_ASSIGN_TYPE VARCHAR(1);
  --
  -- Bug 5926308
  -- Increasing the width of the variable
  -- X_SQL_STATEMENT from 1500 to 2500
  -- skoluku Mon Apr  9 23:23:05 PDT 2007
  --
  X_SQL_STATEMENT VARCHAR2(2500);
  X_REASON_ID NUMBER;
  X_REASON_CODE VARCHAR2(30);
  X_EMPLOYEE_ID NUMBER;
  X_EMPLOYEE VARCHAR2(30);
  X_LOGIN NUMBER;
  X_TRANSACTION_ID NUMBER;
  X_TRANSACTION_DATE DATE;
  X_TXN_TYPE VARCHAR2(30);
  X_QUANTITY NUMBER;
  X_UOM VARCHAR2(25);
  X_QUALITY_CODE VARCHAR2(25);
  X_VENDOR_LOT VARCHAR2(30);
  X_COMMENTS VARCHAR2(240);
  X_RETURN_STATUS VARCHAR2(5);
  X_MSG_COUNT NUMBER;
  X_MSG_DATA VARCHAR2(240);
  X_LAST_UPDATED_BY NUMBER;
  X_VENDOR_ID NUMBER ;
  X_ITEM_ID NUMBER ;
  X_OP_UNIT NUMBER ;
  X_TRANSACTION_NUMBER NUMBER ;
  X_WORKFLOW_ITEMTYPE VARCHAR2(2000);
  X_WORKFLOW_ITEMTYPE_SELECTOR VARCHAR2(240);
  X_WORKFLOW_NUMBER_OF_PROCESSES NUMBER;


--kaza

  X_ASSET_GROUP_ID NUMBER;
  X_ASSET_NUMBER VARCHAR2(100);
  X_ASSET_INSTANCE_ID NUMBER; --dgupta: R12 EAM Integration. Bug 4345492
  ELEMENT_ID number:= 172;
  ELEMENT_NAME VARCHAR2(50);
  Priority_id NUMBER;
  Priority_soft_column varchar2(100);
  Priority_value varchar2(30);
  user_id NUMBER;
  request_id             NUMBER;
  status_id              NUMBER;
  request_log            VARCHAR2(1500);
  operator_type          VARCHAR2(50);
  Priority_exists        BOOLEAN;
  l_resultout            VARCHAR2(200);
  l_error_message        VARCHAR2(200);

  l_group_id             NUMBER;
  l_work_order_rec       WIP_EAMWORKORDER_PVT.work_order_interface_rec_type;
  l_followup_activity_id NUMBER;

  l_firm_flag VARCHAR2(1);

--kaza

  result_value VARCHAR2(300);
  retnum NUMBER;

  po_api_failed EXCEPTION;
  null_txn_id EXCEPTION;
  column_missing EXCEPTION;
  fail_po_insertion EXCEPTION;
  wf_missing_selector EXCEPTION;
  fail_setting_lot_status EXCEPTION;
  fail_setting_serial_status EXCEPTION;

  -- Added the below two exceptions for Bug 3225280. kabalakr.
  fail_serial_insertion EXCEPTION;
  fail_lot_insertion    EXCEPTION;


  x_progress NUMBER; -- for debug purposes
  x_asl_return VARCHAR2(1);
  update_column numtable; -- Added for update capabilities.
  total_updates number := -1; -- Added for update capabilities.
  txn_type varchar2(6); -- Added for update capabilities.
  errmsg VARCHAR2(240);
  errcode NUMBER;


-- OPM Conv R12 Tracking Bug 4345760
-- change variable size for lot num

  X_LOT_NUMBER qa_results.lot_number%TYPE;

  X_SERIAL_NUMBER VARCHAR2(30);
  X_SUBINVENTORY VARCHAR2(10);
  X_LOCATOR_ID NUMBER;
  X_STATUS_ID NUMBER;

  -- Added the below cursor and variables for RCV/WMS Merge.
  -- Bug 3096256. kabalakr Mon Aug 18 03:18:19 PDT 2003.

  CURSOR item_uom_cur (l_item_id NUMBER, l_org_id NUMBER) IS
    SELECT primary_unit_of_measure
    FROM   mtl_system_items_b
    WHERE  inventory_item_id = l_item_id
    AND    organization_id = l_org_id;

  X_LPN_ID      NUMBER;
  X_XFR_LPN_ID  NUMBER;

  l_primary_uom VARCHAR2(25);
  l_primary_qty NUMBER;
  l_int_txn_id  NUMBER;
  l_ser_txn_id  NUMBER;

  -- Added the below cursor and variables for Bug 3225280.
  -- kabalakr Wed Oct 29 23:19:22 PST 2003.

  CURSOR int_txn (grp_id NUMBER, txn_id NUMBER) IS
    SELECT max(interface_transaction_id)
    FROM   rcv_transactions_interface
    WHERE  group_id = grp_id
    AND    parent_transaction_id = txn_id;

  l_rti_int_txn_id NUMBER;

-- Bug  6781108
-- Added the following two variables to get the value
-- and pass to the RCV API
x_rti_sub_code  mtl_secondary_inventories.secondary_inventory_name%TYPE :=NULL;
x_rti_loc_id    NUMBER := NULL;
  BEGIN

    x_progress := 1;
    --dbms_output.enable(1000000);

    -- 12/28/98
    -- since parameter x_txn_header_id contains txn_header_id
    -- or collection id depending odn the place from where it is
    -- called , we pass NULL to the INIT_CURSOR procedure for collection_id
    -- if txn_header_id is passed, otherwise NULL is passed for txn_header_id
    -- if x_txn_header_id contains collection id.
    -- The reason we are doing so is because we want to maintain backward
    -- compatibility and do not disrturb code for collection import etc.

    -- For Bug1843356. Added the IF condition below.
    -- kabalakr 22 feb 02

    IF (P_OCCURRENCE IS NOT NULL) THEN
       QLTNINRB.INIT_CURSOR(P_PLAN_ID, NULL, X_TXN_HEADER_ID, P_OCCURRENCE);
    ELSIF nvl(X_PASSED_ID_NAME, 'TXN_HEADER_ID') = 'TXN_HEADER_ID' then
       QLTNINRB.INIT_CURSOR(NULL, X_TXN_HEADER_ID, NULL, NULL);
    ELSE
       QLTNINRB.INIT_CURSOR(NULL, NULL, X_TXN_HEADER_ID, NULL) ;
    END IF ;

    WHILE QLTNINRB.NEXT_ROW LOOP

      -- get collection id, creation date, spec id and plan id
      X_COLLECTION_ID := to_number(QLTNINRB.NAME_IN('COLLECTION_ID'));
      X_CREATION_DATE := fnd_date.chardt_to_date(QLTNINRB.NAME_IN('QA_CREATION_DATE'));
      Y_SPEC_ID := to_number(QLTNINRB.NAME_IN('SPEC_ID'));
      Y_PLAN_ID := to_number(QLTNINRB.NAME_IN('PLAN_ID'));

      -- Bug 5111269.
      -- In EAM Transactions we are not supporting Specifications at plan level.
      -- We support specifications at element level only. Since specifications is
      -- not supported at plan level we call Quality APIs from EAM with spec_id as -1
      -- (even if one of the elements in the collection plan has specification limits
      -- defined). When spec_id is -1 the existing code assigns NULL to spec_id(This
      -- happens in qltssresb.plb). If we pass NULL then the actions based on the elements
      -- would not fire because for specification at element level in qltdactb we check
      -- whether spec_id is 0 and then fire the actions. If it is NULL then no action
      -- would fire. So made Y_SPEC_ID to have the value as 0 if spec_id is NULL or <= 0.
      -- ntungare Wed Mar 29 02:58:45 PST 2006.

      If ((Y_SPEC_ID IS NULL) or (Y_SPEC_ID <= 0)) then
         Y_SPEC_ID := 0;
      End if;

      -- debug message, beginning actions processing
      IF X_DEBUG = TRUE THEN
        X_message := 'ACTION PROCESS DBG, TXN ID: '||X_TXN_HEADER_ID;
        INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,0,
                                  0,' ',
                                  ' ',X_message,
                                  ' ',X_CONCURRENT);
      END IF;

      -- Added for update capabilities.
      -- Get which columns got updated from history table for this particular
      -- collection and occurence.


      -- if statement is added to fix bug 902020
      -- the following piece of code should not be executed
      -- when transaction integration. It should be executed only for
      -- collection import, when x_passed_id_name is default to
      -- 'COLLECTION_ ID'
      -- Jenny 6/13/99

      -- Changed the IF condition so that the below code gets
      -- executed only during collection import.When collection
      -- import is used X_ARGUMENT will have the value as IMPORT.
      -- Bug 3273447. suramasw

      -- if nvl(X_PASSED_ID_NAME, 'TXN_HEADER_ID') <> 'TXN_HEADER_ID' THEN

      if  NVL(X_ARGUMENT,NULL) = 'IMPORT' THEN
      BEGIN

           I := 0;
           X_OCCURRENCE := TO_NUMBER(QLTNINRB.NAME_IN('OCCURRENCE'));
           FOR UPDATED_RES_COLUMNS IN
             (SELECT CHAR_ID
              FROM QA_RESULTS_UPDATE_HISTORY
              WHERE TXN_HEADER_ID = X_TXN_HEADER_ID
              AND OCCURRENCE = X_OCCURRENCE) LOOP
             I := I + 1;
             UPDATE_COLUMN(I) := UPDATED_RES_COLUMNS.CHAR_ID;
           END LOOP;
           TOTAL_UPDATES := I;

           IF TOTAL_UPDATES = 0
                THEN SELECT DECODE(INSERT_TYPE,2,'UPDATE','INSERT')
                        INTO TXN_TYPE
                        FROM QA_RESULTS_INTERFACE
                        WHERE TRANSACTION_INTERFACE_ID = X_TXN_HEADER_ID;

                        IF NVL(TXN_TYPE,'INSERT') = 'UPDATE'
                          THEN TOTAL_UPDATES := 0;
                          ELSE TOTAL_UPDATES := -1;
                        END IF;
           END IF;

      EXCEPTION
           WHEN NO_DATA_FOUND THEN
             TOTAL_UPDATES := -1;
      END;

      end if;
      i := 0;
      IF ((Y_SPEC_ID <> OLD_SPEC_ID) OR (Y_PLAN_ID <> OLD_PLAN_ID)) AND
           (TOTAL_UPDATES <> 0) THEN
        BEGIN
          FOR prec IN action_triggers(Y_PLAN_ID, Y_SPEC_ID) LOOP
               i := i + 1;
               char_id_tab(i)    := prec.CHAR_ID;
               datatype_tab(i)   := prec.TYPE;
               fk_type_tab(i)    := prec.FK_LOOKUP_TYPE;
               column_tab(i)     := prec.Q_COLUMN;
               operator_tab(i)   := prec.OPERATOR;
               low_value_tab(i)  := prec.LOW_VALUE;
               high_value_tab(i) := prec.HIGH_VALUE;
               action_id_tab(i)  := prec.ACTION;
               pcat_id_tab(i)    := prec.PCAT_ID;
               pca_id_tab(i)     := prec.PCA_ID;
               seq_id_tab(i)     := prec.SEQ_ID;

                       -- BUG 3303285
                       -- ksoh Wed Dec 31 12:20:09 PST 2003
                       -- if spec is used and spec element UOM and plan element UOM
                       -- are different, perform conversion
                       IF ((Y_SPEC_ID <> 0) AND
                                (prec.PLAN_CHAR_UOM <> prec.SPEC_CHAR_UOM)) THEN
                    IF (prec.LOW_VALUE IS NOT NULL) THEN
                            low_value_tab(i) := INV_CONVERT.INV_UM_CONVERT(null,
                                             prec.DECIMAL_PRECISION,
                                             prec.LOW_VALUE,
                                             prec.SPEC_CHAR_UOM,
                                             prec.PLAN_CHAR_UOM,
                                             null,
                                             null);
                    END IF;
                    IF (prec.HIGH_VALUE IS NOT NULL) THEN
                            high_value_tab(i) := INV_CONVERT.INV_UM_CONVERT(null,
                                             prec.DECIMAL_PRECISION,
                                             prec.HIGH_VALUE,
                                             prec.SPEC_CHAR_UOM,
                                             prec.PLAN_CHAR_UOM,
                                             null,
                                             null);
                    END IF;
                            IF ((low_value_tab(i) = -99999) OR (high_value_tab(i) = -99999)) THEN
                        fnd_message.set_name('QA', 'QA_INCONVERTIBLE_UOM');
                        fnd_message.set_token('ENTITY1', prec.SPEC_CHAR_UOM);
                        fnd_message.set_token('ENTITY2', prec.PLAN_CHAR_UOM);
                                fnd_msg_pub.add();
                            END IF;
                       END IF; -- (Y_SPEC_ID <> 0)...
          END LOOP;
        EXCEPTION
           WHEN NO_DATA_FOUND then
                i := 0;
           WHEN OTHERS then
                raise;
        END;
           total_rows := i;
      END IF;

      IF X_DEBUG = TRUE THEN
        X_message := 'ACTION PROCESS DBG, PAST IMPORT LOGIC';
        INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,0,
                                  0,'',
                                  '',X_message,
                                  '',X_CONCURRENT);
      END IF;

      i := 1;
      WHILE i <= total_rows LOOP
        -- Logic added for foreign keyed elements (customer, supplier,
        -- etc.) which need to be decoded from ID to meaning before the
        -- comparison can be evaluated.  Checking FK_LOOKUP_TYPE locally
        -- saves us an unnecessary database hit.
        IF fk_type_tab(i) in (0, 1, 3)
          THEN result := QLTSMENB.LOOKUP(char_id_tab(i),
                                         QLTNINRB.NAME_IN(column_tab(i)));
          ELSE result := QLTNINRB.NAME_IN(column_tab(i));
        END IF;
        done := FALSE;

        -- Added for update capabilities...
        -- If the updated column matches the action trigger column,
        -- then not_done will remain FALSE.  Else, it will be set to TRUE
        -- and the action code will not be executed.  This is so that
        -- only columns that got updated will fire actions.
        IF total_updates > -1
          THEN FOR j IN 1..(total_updates+1) LOOP
            IF ( j = (total_updates+1) )THEN done := TRUE;
            ELSIF (update_column(j) = char_id_tab(i)) THEN EXIT;
            END IF;
          END LOOP;
        END IF;

        -- see if the action rule evaluates to true, and if so,
        -- fire appropriate actions
        IF qltcompb.compare(result,operator_tab(i),low_value_tab(i),
           high_value_tab(i), datatype_tab(i)) AND (not done) THEN

          WHILE (not done) LOOP

            -- online actions
            IF action_id_tab(i) in (1, 2) and nvl(x_action_type, 'DEFERRED') = 'DEFFERED' THEN
              null;

            -- alerts (always a concurrent request)
            ELSIF action_id_tab(i) in (10, 11, 12, 13) AND
                  nvl(x_action_type, 'DEFERRED') = 'DEFERRED' THEN
              IF X_DEBUG = TRUE THEN
                X_message := 'ACTION PROCESS DBG, FIRING ALERT';
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END IF;
              FIRE_ALERT(pca_id_tab(i));

            -- placeholder for corrective action
            ELSIF action_id_tab(i) = 14 THEN
              null;

            -- action log
            ELSIF action_id_tab(i) = 15 AND
                  nvl(x_action_type, 'DEFERRED') = 'DEFERRED' THEN
              IF X_DEBUG = TRUE THEN
                X_message := 'ACTION PROCESS DBG, ACTION LOG INSERT';
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END IF;

              OPEN MY_MESSAGE(pca_id_tab(i));
              FETCH MY_MESSAGE INTO X_MESSAGE, X_ASSIGN_TYPE;
              CLOSE MY_MESSAGE;
              INSERT_ACTION_LOG(Y_PLAN_ID,
                                X_COLLECTION_ID,
                                X_CREATION_DATE,
                                char_id_tab(i),
                                operator_tab(i),
                                low_value_tab(i),
                                high_value_tab(i),
                                X_message,
                                result,
                                X_CONCURRENT);

            -- job or schedule on hold
            ELSIF action_id_tab(i) = 16 AND nvl(x_action_type, 'DEFERRED') = 'DEFERRED' THEN
              IF X_DEBUG = TRUE THEN
                X_message := 'ACTION PROCESS DBG, PLACING JOB ON HOLD';
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END IF;
              output := to_number(QLTNINRB.NAME_IN('WIP_ENTITY_ID'));
              X_org_id := to_number(QLTNINRB.NAME_IN('ORGANIZATION_ID'));

              -- call WIP api
              BEGIN
                WIP_CHANGE_STATUS.PUT_JOB_ON_HOLD(output, X_org_id);
              EXCEPTION
                WHEN OTHERS THEN
                -- write exceptions to action log;
                X_ERROR := FALSE;
                X_message := FND_MESSAGE.GET;
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END;


            -- assign shop floor status to intraoperation step
            ELSIF action_id_tab(i) = 17 and nvl(x_action_type, 'DEFERRED') = 'DEFERRED' THEN
              IF X_DEBUG = TRUE THEN
                X_message := 'ACTION PROCESS DBG, ASSIGNING SHOP FLOOR STATUS';
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END IF;

              OPEN MY_STATUS(pca_id_tab(i));
              FETCH MY_STATUS INTO X_STATUS;
              CLOSE MY_STATUS;

              OPEN MY_STEP(Y_PLAN_ID);
              FETCH MY_STEP INTO RES_COL_NAME;
              CLOSE MY_STEP;

              output := to_number(QLTNINRB.NAME_IN('WIP_ENTITY_ID'));
              output2 := to_number(QLTNINRB.NAME_IN('LINE_ID'));
              output3 := to_number(QLTNINRB.NAME_IN('TO_OP_SEQ_NUM'));
              INTEROP_STEP := QLTNINRB.NAME_IN(RES_COL_NAME);

              OPEN MY_STEP_LOOKUP(INTEROP_STEP);
              FETCH MY_STEP_LOOKUP INTO output4;
              CLOSE MY_STEP_LOOKUP;

              X_org_id := to_number(QLTNINRB.NAME_IN('ORGANIZATION_ID'));

              -- call WIP api
              BEGIN
                WIP_SF_STATUS.ATTACH(output,X_org_id,output2,
                                     output3, output4,X_STATUS);
              EXCEPTION
                WHEN OTHERS THEN
                -- write exceptions to action log;
                X_ERROR := FALSE;
                X_message := FND_MESSAGE.GET;
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END;

            -- assign lot status
            ELSIF action_id_tab(i) = 18 and nvl(x_action_type, 'DEFERRED') = 'DEFERRED' THEN

              X_message := 'ACTION PROCESS DBG, ASSIGNING LOT STATUS';
              INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,0,
                                  0,'',
                                  '',X_message,
                                  '',X_CONCURRENT);
              -- get lot status id
              OPEN MY_STATUS_ID (pca_id_tab(i));
              FETCH MY_STATUS_ID INTO X_STATUS_ID;
              CLOSE MY_STATUS_ID;

              -- get the org id, lot number and item id
              X_org_id := to_number(QLTNINRB.NAME_IN('ORGANIZATION_ID'));
              X_lot_number := QLTNINRB.NAME_IN('LOT_NUMBER');
              X_Item_id := to_number (QLTNINRB.Name_in('ITEM_ID' )) ;

              -- call Inventory API
              BEGIN
                INV_MATERIAL_STATUS_GRP.UPDATE_STATUS(
                    p_api_version_number => 1.0,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_update_method      => 4,
                    p_status_id          => x_status_id,
                    p_organization_id    => x_org_id,
                    p_inventory_item_id  => x_item_id,
                    p_lot_number         => x_lot_number,
                    p_object_type        => 'O');

                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fail_setting_lot_status;
                END IF;

              EXCEPTION
                WHEN fail_setting_lot_status THEN

                FND_MESSAGE.SET_NAME('QA', 'QA_LOT_STATUS_ACTION_FAIL');
                X_message := FND_MESSAGE.GET;
                X_message := X_message ||X_msg_data;

                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
                WHEN OTHERS THEN
                -- write exceptions to action log;
                X_ERROR := FALSE;
                X_message := FND_MESSAGE.GET;
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END;

            -- assign serial status
            ELSIF action_id_tab(i) = 19 and nvl(x_action_type, 'DEFERRED') = 'DEFERRED' THEN
              X_message := 'ACTION PROCESS DBG, ASSIGNING SERIAL STATUS';
              INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,0,
                                  0,'',
                                  '',X_message,
                                  '',X_CONCURRENT);

              -- get serial status id
              OPEN MY_STATUS_ID (pca_id_tab(i));
              FETCH MY_STATUS_ID INTO X_STATUS_ID;
              CLOSE MY_STATUS_ID;

              -- get the org id, serial number and item id
              X_org_id := to_number(QLTNINRB.NAME_IN('ORGANIZATION_ID'));
              X_serial_number := QLTNINRB.NAME_IN('SERIAL_NUMBER');
              X_Item_id := to_number (QLTNINRB.Name_in('ITEM_ID' )) ;

              -- call Inventory API
              BEGIN
                INV_MATERIAL_STATUS_GRP.UPDATE_STATUS(
                    p_api_version_number => 1.0,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    p_update_method      => 4,
                    p_status_id          => x_status_id,
                    p_organization_id    => x_org_id,
                    p_inventory_item_id  => x_item_id,
                    p_serial_number      => x_serial_number,
                    p_object_type        => 'S');

                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fail_setting_serial_status;
                END IF;

              EXCEPTION
                WHEN fail_setting_serial_status THEN

                FND_MESSAGE.SET_NAME('QA', 'QA_SERIAL_STATUS_ACTION_FAIL');
                X_message := FND_MESSAGE.GET;
                X_message := X_message || X_msg_data;

                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
                WHEN OTHERS THEN
                -- write exceptions to action log;
                X_ERROR := FALSE;
                X_message := FND_MESSAGE.GET;
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END;


            -- placeholder for assigning item status
            ELSIF action_id_tab(i) = 20 and nvl(x_action_type, 'DEFERRED') = 'DEFERRED'THEN
              null;

            -- place the supplier on hold
            ELSIF action_id_tab(i) = 21 and nvl(x_action_type, 'DEFERRED')= 'DEFERRED'THEN
              X_message := 'ACTION PROCESS DBG, PLACING SUPPLIER ON HOLD';
              INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,0,
                                  0,'',
                                  '',X_message,
                                  '',X_CONCURRENT);
              X_org_id := to_number(QLTNINRB.NAME_IN('ORGANIZATION_ID'));
              X_Vendor_id := to_number(QLTNINRB.NAME_IN('VENDOR_ID'));

              -- get the operating unit
              OPEN MY_OP_UNIT(X_ORG_ID);
              FETCH MY_OP_UNIT  INTO X_OP_UNIT;
              CLOSE MY_OP_UNIT ;

              BEGIN
                -- we need an API to update vendor status from AP team.
                -- for now we just update the table directly
                Update PO_VENDOR_SITES
                SET HOLD_ALL_PAYMENTS_FLAG = 'Y'
                WHERE VENDOR_ID = x_vendor_id
                AND ORG_ID = NVL ( X_OP_UNIT, ORG_ID);
              EXCEPTION
                WHEN OTHERS THEN
                -- write exceptions to action log;
                X_ERROR := FALSE;
                X_message := FND_MESSAGE.GET;
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END;

            -- place the po or release on hold
            ELSIF action_id_tab(i) = 22 and nvl(x_action_type, 'DEFERRED') = 'DEFERRED' THEN
              -- call PO API
              X_message := 'ACTION PROCESS DBG, PLACING PO OR RELEASE ON HOLD';
              INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,0,
                                  0,'',
                                  '',X_message,
                                  '',X_CONCURRENT);
              BEGIN
                retnum := PO_DOCUMENT_ACTIONS_SV.PO_HOLD_DOCUMENT(
                  to_number(QLTNINRB.NAME_IN('PO_HEADER_ID')),
                  to_number(QLTNINRB.NAME_IN('PO_RELEASE_ID')),
                  x_msg_data);
                IF retnum <> 0 THEN
                  RAISE po_api_failed;
                END IF;
              EXCEPTION
                WHEN po_api_failed THEN
                -- write exceptions to action log;
                X_ERROR := FALSE;
                X_message := FND_MESSAGE.GET;
                X_message := X_message || X_msg_data;
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END;

            -- WIP production line on hold
            ELSIF action_id_tab(i) = 23 and nvl(x_action_type, 'DEFERRED') = 'DEFERRED'THEN
              X_message := 'ACTION PROCESS DBG, PLACING PRODUCTION LINE ON HOLD';
              INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,0,
                                  0,'',
                                  '',X_message,
                                  '',X_CONCURRENT);
              output := to_number(QLTNINRB.NAME_IN('WIP_ENTITY_ID'));
              output2 := to_number(QLTNINRB.NAME_IN('LINE_ID'));
              X_org_id := to_number(QLTNINRB.NAME_IN('ORGANIZATION_ID'));

              -- AG: QWB: wip_entity_id is needed to put the schedule on hold.
              IF output IS NULL THEN
                  BEGIN
                          SELECT DISTINCT wrs.wip_entity_id INTO output
                          FROM wip_repetitive_schedules wrs,
                               wip_entities we
                          WHERE wrs.organization_id = x_org_id
                          AND   wrs.line_id = output2
                          AND   we.wip_entity_id = wrs.wip_entity_id
                          AND   we.organization_id = wrs.organization_id
                          AND   we.primary_item_id = to_number(QLTNINRB.NAME_IN('ITEM_ID'));
                  EXCEPTION
                          WHEN OTHERS THEN
                                   NULL;
                  END;
              END IF;
              -- AG: QWB: end

              -- call WIP api
              BEGIN
                WIP_CHANGE_STATUS.PUT_LINE_ON_HOLD(output, output2, X_org_id);
              EXCEPTION
                WHEN OTHERS THEN
                -- write exceptions to action log;
                X_ERROR := FALSE;
                X_message := FND_MESSAGE.GET;
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END;

            -- assign a value

            -- For Bug 1843356. Added the OR condition below.

            ELSIF action_id_tab(i) = 24 AND (nvl(x_action_type, 'DEFERRED') = 'DEFERRED' OR
                x_action_type = 'BACKGROUND_ASSIGN_VALUE') THEN
              -- if action wasn't executed in form, execute here
              IF nvl(X_BACKGROUND, TRUE) THEN
                X_message := 'ACTION PROCESS DBG, ASSIGNING A VALUE';
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,0,
                                  0,'',
                                  '',X_message,
                                  '',X_CONCURRENT);
                X_OCCURRENCE := to_number(QLTNINRB.NAME_IN('OCCURRENCE'));

                OPEN MY_ASSIGNED_CHAR_ID(pca_id_tab(i), action_id_tab(i));
                FETCH MY_ASSIGNED_CHAR_ID INTO X_ASSIGNED_CHAR_ID;
                CLOSE MY_ASSIGNED_CHAR_ID;

                OPEN MY_MESSAGE(pca_id_tab(i));
                FETCH MY_MESSAGE
                INTO X_MESSAGE, X_ASSIGN_TYPE;
                CLOSE MY_MESSAGE;

                -- See Bug 956708
                -- bso
                x_message := rtrim(x_message, ' ;/
');


                IF X_ASSIGN_TYPE = 'F' THEN
                  X_MESSAGE :=  'SELECT ' || X_MESSAGE || ' FROM dual';
                END IF;

                BEGIN
                  DO_ASSIGNMENT(pca_id_tab(i),X_MESSAGE,
                                  X_ASSIGNED_CHAR_ID,X_COLLECTION_ID,
                                  X_OCCURRENCE,Y_PLAN_ID,
                                  X_SQL_STATEMENT);

                EXCEPTION
                  WHEN OTHERS THEN
                  -- write exceptions to action log;
                  X_ERROR := FALSE;
                  X_message := FND_MESSAGE.GET;
                  INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
                END;
              END IF; -- X_BACKGROUND

            -- accept, reject rcv shipment
            ELSIF action_id_tab(i) in (25, 26) AND
                  x_action_type = 'IMMEDIATE' THEN
              x_progress := 2;
              X_TRANSACTION_NUMBER :=
                            to_number(QLTNINRB.NAME_IN('TRANSACTION_NUMBER'));

              -- only allow action if from inspection transaction

              --
              -- and when this collection is neither skip lot inspection
              -- nor sampling inspection
              -- jezheng
              -- Wed Aug 22 18:29:07 PDT 2001
              --
              IF X_TRANSACTION_NUMBER = 21 AND
                 QA_INSPECTION_PKG.IS_REGULAR_INSP(X_COLLECTION_ID) = fnd_api.g_true
              THEN
                BEGIN

                  -- 25 is accept and 26 is reject


                  IF action_id_tab(i)= 25 THEN
                    X_TXN_TYPE := 'ACCEPT';
                    X_message := 'ACTION PROCESS DBG, ACCEPTING THE SHIPMENT';
                    INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,0,
                                  0,'',
                                  '',X_message,
                                  '',X_CONCURRENT);
                  ELSIF action_id_tab(i)= 26 THEN
                    X_TXN_TYPE := 'REJECT';
                    X_message := 'ACTION PROCESS DBG, REJECTING THE SHIPMENT';
                    INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,0,
                                  0,'',
                                  '',X_message,
                                  '',X_CONCURRENT);
                  END IF;

                  X_TRANSACTION_ID := QLTNINRB.NAME_IN('TRANSACTION_ID');

                  x_progress := 3;
                  IF X_TRANSACTION_ID IS NULL THEN
                    x_progress := 4;
                    RAISE null_txn_id;
                  END IF;

                  x_progress := 5;
                  X_LAST_UPDATED_BY := QLTNINRB.NAME_IN('LAST_UPDATED_BY');
                  X_LOGIN := QLTNINRB.NAME_IN('LAST_UPDATE_LOGIN');
                  OPEN MY_RESULTS_COLUMN(Y_PLAN_ID);

                  -- loop through collection elements, extracting
                  -- the ones required for the action
                  LOOP
                    FETCH MY_RESULTS_COLUMN INTO RC;
                    EXIT WHEN MY_RESULTS_COLUMN%NOTFOUND;

                    result_value := QLTNINRB.NAME_IN(RC.Q_COLUMN);
                    IF RC.DEV_NAME = 'TRANSACTION_DATE' THEN
                      X_TRANSACTION_DATE := qltdate.any_to_date(result_value);
                    ELSIF RC.DEV_NAME = 'QUANTITY' THEN
                      X_QUANTITY := result_value;
                    ELSIF RC.DEV_NAME = 'QUALITY_CODE' THEN
                      X_QUALITY_CODE := result_value;
                    ELSIF RC.DEV_NAME = 'COMMENTS' THEN
                      X_COMMENTS := result_value;
                    --
                    -- bug 6266404
                    -- Modified the condition to use the actual
                    -- context element SUPPLIER_LOT instead of
                    -- INSP_SUPPLIER_LOT.
                    -- skolluku Mon Jul 23 02:44:58 PDT 2007
                    --
                    --ELSIF RC.DEV_NAME = 'INSP_SUPPLIER_LOT' THEN
                    ELSIF RC.DEV_NAME = 'SUPPLIER_LOT' THEN
                      X_VENDOR_LOT := result_value;
                    ELSIF RC.DEV_NAME = 'UOM_NAME' THEN
                      X_UOM := result_value;
                    ELSIF RC.DEV_NAME = 'INSP_REASON_CODE' THEN
                      X_REASON_CODE := result_value;
                    ELSIF RC.DEV_NAME = 'EMPLOYEE' THEN
                      X_EMPLOYEE := result_value;

                    -- Bug 3096256.
                    -- Added the below statements for RCV/WMS Merge.
                    -- Fetch the LPN, Lot and serial info entered in the results
                    -- record.
                    --
                    -- For Transfer LPN, user can enter a new LPN name which
                    -- will be generated in Quality Module. This generation has
                    -- already been done in QLTRES during Insert_Row. Hence, just
                    -- fetch the id entered in the result for transfer LPN.
                    -- kabalakr Mon Aug 18 03:18:19 PDT 2003.
                    --

                    -- Bug 3225280. Change the developer_name to ITEM instead of
                    -- ITEM_ID. kabalakr Wed Oct 29 23:19:22 PST 2003.

                    ELSIF RC.DEV_NAME = 'ITEM' THEN
                      X_ITEM_ID := to_number(result_value);
                    ELSIF RC.DEV_NAME = 'LICENSE_PLATE_NUMBER' THEN
                      X_LPN_ID := to_number(result_value);
                    ELSIF RC.DEV_NAME = 'XFR_LICENSE_PLATE_NUMBER' THEN
                      X_XFR_LPN_ID := to_number(result_value);
                    ELSIF RC.DEV_NAME = 'LOT_NUMBER' THEN
                      X_LOT_NUMBER := result_value;
                    ELSIF RC.DEV_NAME = 'SERIAL_NUMBER' THEN
                      X_SERIAL_NUMBER := result_value;

                    END IF;
                  END LOOP;

                  CLOSE MY_RESULTS_COLUMN;

                  -- Fetching the value of org_id. For RCV/WMS project.
                  -- Bug 3096256. kabalakr Mon Aug 18 03:18:19 PDT 2003.

                  X_ORG_ID := TO_NUMBER(QLTNINRB.NAME_IN('ORGANIZATION_ID'));


                  IF X_TRANSACTION_DATE IS NULL OR
                    X_QUANTITY IS NULL OR
                    X_UOM IS NULL THEN
                    -- the not null columns are null, raise error
                    RAISE column_missing;
                  END IF;

                  IF X_REASON_CODE IS NOT NULL THEN
                    OPEN MY_REASON_ID(X_REASON_CODE);
                    FETCH MY_REASON_ID INTO X_REASON_ID;
                    CLOSE MY_REASON_ID;
                  ELSE
                    X_REASON_ID := NULL;
                  END IF;

                  IF X_EMPLOYEE IS NOT NULL THEN
                    OPEN MY_EMPLOYEE_ID(X_EMPLOYEE);
                    FETCH MY_EMPLOYEE_ID INTO X_EMPLOYEE_ID;
                    CLOSE MY_EMPLOYEE_ID;
                  ELSE
                    X_EMPLOYEE_ID := 1;
                  END IF;

                  -- If X_LPN_ID is not null, it denotes that we are performing
                  -- LPN Inspection. Hence the below algorithm is followed.
                  --
                  -- 1. If transfer LPN is not entered in the results record,
                  --    default the LPN_ID as transfer_LPN_ID.
                  --
                  -- 2. If transfer LPN is entered in the results record but
                  --    the transfer LPN_ID is NULL, call the inventory/WMS API
                  --    inv_rcv_integration_apis.validate_lpn to validate and
                  --    generate the new LPN. This API returns the LPN_ID for the
                  --    new transfer LPN.
                  --
                  --    This step has been done in QLTRES during Insert_row beacuse
                  --    the value of Transfer LPN is not stored in QA_RESULTS and
                  --    hence cannot be retrieved.
                  --
                  -- 3. If transfer_LPN and transfer_LPN_ID exist is the results
                  --    record, pass it directly to the RCV Inspection API.
                  --
                  -- Bug 3096256. kabalakr Mon Aug 18 03:18:19 PDT 2003.
                  --

                  IF X_LPN_ID IS NOT NULL THEN

                    IF (X_XFR_LPN_ID IS NULL) THEN
                       X_XFR_LPN_ID := X_LPN_ID;
                       -- Bug 6781108
                       -- Calling this Procedure to get subinv_code and loc_id
                       -- in order to insert into RTI table
                       -- pdube Wed Feb  6 04:53:32 PST 2008
                       DEFAULT_LPN_SUB_LOC_INFO(X_LPN_ID,
                                             X_XFR_LPN_ID,
                                             x_rti_sub_code,
                                             x_rti_loc_id);

                    END IF;

                  END IF; -- If x_lpn_id is not null


                  x_progress := 6;

                  -- Modified the RCV Inspection API for RCV/WMS Project.
                  -- Parameters P_LPN_ID and P_TRANSFER_LPN_ID are added for
                  -- enabling LPN Inspections through Desktop. Bug 3096256.
                  --
                  -- The api version is changed from 1.0 to 1.1.
                  -- kabalakr Mon Aug 18 03:18:19 PDT 2003.
                  --
                  -- Bug 6781108
                  -- Passing two variables to four parameters p_sub, p_loc_id,
                  -- p_from_subinv and p_from_loc_id as new API
                  -- for receiving needed these parameters
                  -- pdube Wed Feb  6 23:22:10 PST 2008
                  RCV_INSPECTION_GRP.INSERT_INSPECTION(
                                p_api_version           => 1.1,
                                p_init_msg_list         => NULL,
                                p_commit                => 'F',
                                p_validation_level      => NULL,
                                p_created_by            => X_LAST_UPDATED_BY,
                                p_last_updated_by       => X_LAST_UPDATED_BY,
                                p_last_update_login     => X_LOGIN,
                                p_employee_id           => X_EMPLOYEE_ID,
                                p_group_id              => X_GROUP_ID,
                                p_transaction_id        => X_TRANSACTION_ID,
                                p_transaction_type      => X_TXN_TYPE,
                                p_processing_mode       => X_PO_TXN_PROCESSOR_MODE,
                                p_quantity              => X_QUANTITY,
                                p_uom                   => X_UOM,
                                p_quality_code          => X_QUALITY_CODE,
                                p_transaction_date      => X_TRANSACTION_DATE,
                                p_comments              => X_COMMENTS,
                                p_reason_id             => X_REASON_ID,
                                p_vendor_lot            => X_VENDOR_LOT,
                                p_lpn_id                => X_LPN_ID,
                                p_transfer_lpn_id       => X_XFR_LPN_ID,
                                p_qa_collection_id      => X_COLLECTION_ID,
                                p_return_status         => X_RETURN_STATUS,
                                p_msg_count             => X_MSG_COUNT,
                                p_msg_data              => X_MSG_DATA,
                                p_subinventory          => X_RTI_SUB_CODE,
                                p_locator_id            => X_RTI_LOC_ID,
                                p_from_subinventory     => X_RTI_SUB_CODE,
                                p_from_locator_id       => X_RTI_LOC_ID);


                  x_progress := 7;
                  IF X_RETURN_STATUS <> 'S' THEN


                x_progress := 8;
                    RAISE fail_po_insertion;
                  END IF;

                  -- Bug 9356158.pdube
                  -- uncommented the code for getting the interface_txn_id, because this is passed
                  -- to insert_mtli and insert_mtsi apis.

                  -- Bug 3225280. Moved the Lot and serial insertion code after RCV
                  -- insert_inspection API because, we want the interface_transaction_id
                  -- of the ACCEPT and REJECT transactions to be passed to the WMS APIs
                  -- as product_transaction_id.
                  --
                  -- For this, first we need to find the interface_transaction_id of the
                  -- inspection record inserted by RCV API. The logic here is to fetch the
                  -- max(interface_transaction_id) from rti for the parent_transaction_id
                  -- and group_id combination. Since we are implementing this just after
                  -- RCV API call, it will fetch the interface_transaction_id of the
                  -- inspection record just inserted.
                  -- kabalakr. Wed Oct 29 23:19:22 PST 2003.
                  --

                  OPEN int_txn(X_GROUP_ID, X_TRANSACTION_ID);
                  FETCH int_txn INTO l_rti_int_txn_id;
                  CLOSE int_txn;

                  -- Bug 6781108
                  -- Commenting the following fix for 3270283
                  -- as already handled above through the INSERT_INSPECTION API
                  -- pdube Wed Feb  6 04:53:32 PST 2008

		  /*-- Bug 3270283. For LPN inspections, we need to default the receiving
                  -- subinventory and Locator for the transfer LPN, if its a newly
                  -- created one OR, it has a LPN context other than 'Resides in receiving'.
                  -- The new procedure DEFAULT_LPN_SUB_LOC_INFO() takes care of this
                  -- defaulting logic entirely. Hence just call this procedure if its
                  -- a LPN inspection. kabalakr Mon Mar  8 08:01:35 PST 2004.

                  IF X_LPN_ID IS NOT NULL THEN

                    DEFAULT_LPN_SUB_LOC_INFO(X_LPN_ID,
                                             X_XFR_LPN_ID,
                                             l_rti_int_txn_id);

                  END IF; -- If x_lpn_id is not null*/
                  -- End bug 6781108


                  -- Bug 3096256. Changes for RCV/WMS Merge.
                  -- Lot and Serial Inpsections are enabled in Quality from 11.5.10.
                  -- For this, we need to call the APIs provided by WMS to insert the
                  -- lot and serial information onto mtl_transaction_lots_interface
                  -- (MTLI) and mtl_serial_numbers_interface (MSNI). This data would
                  -- be used by th PO API which performs the inpsection.
                  --
                  -- NOTE :
                  -- For Lot and Serial controlled items, the output variable
                  -- x_serial_transaction_temp_id of INSERT_MLTI API needs to be passed
                  -- as the p_transaction_interface_id of INSERT_MSNI API.
                  -- kabalakr Mon Aug 18 03:18:19 PDT 2003.


                  IF X_LOT_NUMBER IS NOT NULL THEN

                    OPEN  item_uom_cur(X_ITEM_ID, X_ORG_ID);
                    FETCH item_uom_cur INTO l_primary_uom;
                    CLOSE item_uom_cur;

                    IF (l_primary_uom = X_UOM) THEN
                       l_primary_qty := X_QUANTITY;

                    ELSE
                       -- Bug 9410966.Passed the from_name and to_name parameters because
                       -- the context elements for desktop transacitons are uom names and
                       -- not uom_codes.X_UOM is from_uom_name and primary_uom is to_uom_name
                       -- pdube Thu Feb 25 03:51:26 PST 2010
                       l_primary_qty := inv_convert.inv_um_convert
                                            (X_ITEM_ID,
                                             NULL,
                                             X_QUANTITY,
                                             NULL,-- X_UOM,
                                             NULL,-- l_primary_uom,
                                             X_UOM,
                                             l_primary_uom);

                    END IF;

                    l_int_txn_id := NULL;

                    -- Now, call the Inventory/WMS API for Lot Insertion.
                    -- Passing NULL value to p_transaction_interface_id to allow the
                    -- API to generate one. Bug 3096256.

                    -- Bug 3225280. Changed the value passed as p_product_transaction_id
                    -- to l_rti_int_txn_id, derived above.

                    INV_RCV_INTEGRATION_APIS.INSERT_MTLI
                       (p_api_version                => 1.0,
                        p_init_msg_lst               => NULL,
                        x_return_status              => X_RETURN_STATUS,
                        x_msg_count                  => X_MSG_COUNT,
                        x_msg_data                   => X_MSG_DATA,
                        p_transaction_interface_id   => l_int_txn_id,
                        p_transaction_quantity       => X_QUANTITY,
                        p_primary_quantity           => l_primary_qty,
                        p_organization_id            => X_ORG_ID,
                        p_inventory_item_id          => X_ITEM_ID,
                        p_lot_number                 => X_LOT_NUMBER,
                        p_expiration_date            => NULL,
                        p_status_id                  => NULL,
                        x_serial_transaction_temp_id => l_ser_txn_id,
                        p_product_code               => 'RCV',
                        p_product_transaction_id     => l_rti_int_txn_id);


                    IF X_RETURN_STATUS <> 'S' THEN
                       RAISE fail_lot_insertion;
                    END IF;

                  END IF;


                  IF X_SERIAL_NUMBER IS NOT NULL THEN

                    IF X_LOT_NUMBER IS NOT NULL THEN
                       l_int_txn_id := l_ser_txn_id;

                    ELSE
                       l_int_txn_id := NULL;

                    END IF;

                    -- Now, call the Inventory/WMS API for Serial Insertion.
                    -- Passing NULL value to p_transaction_interface_id to allow the
                    -- API to generate one. Bug 3096256.

                    -- Bug 3225280. Changed the value passed as p_product_transaction_id
                    -- to l_rti_int_txn_id, derived above.

                    INV_RCV_INTEGRATION_APIS.INSERT_MSNI
                       (p_api_version              => 1.0,
                        p_init_msg_lst             => NULL,
                        x_return_status            => X_RETURN_STATUS,
                        x_msg_count                => X_MSG_COUNT,
                        x_msg_data                 => X_MSG_DATA,
                        p_transaction_interface_id => l_int_txn_id,
                        p_fm_serial_number         => X_SERIAL_NUMBER,
                        p_to_serial_number         => X_SERIAL_NUMBER,
                        p_organization_id          => X_ORG_ID,
                        p_inventory_item_id        => X_ITEM_ID,
                        p_status_id                => NULL,
                        p_product_code             => 'RCV',
                        p_product_transaction_id   => l_rti_int_txn_id);


                    IF X_RETURN_STATUS <> 'S' THEN
                       RAISE fail_serial_insertion;
                    END IF;

                  END IF;

                EXCEPTION

                  WHEN null_txn_id THEN
                  --dbms_output.put_line('x progress is '||to_char(x_progress));
                  X_ERROR := FALSE;
                  FND_MESSAGE.SET_NAME('QA', 'QA_PO_INSP_ACTION_NULL_TXN_ID');
                  X_message := FND_MESSAGE.GET;
                  INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);

                  WHEN column_missing THEN
                  --dbms_output.put_line('x progress is '||to_char(x_progress));
                  X_ERROR := FALSE;
                  FND_MESSAGE.SET_NAME('QA', 'QA_PO_INSP_ACTION_COL_MISSING');
                  X_message := FND_MESSAGE.GET;
                  INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);

                  WHEN fail_po_insertion THEN
                  --dbms_output.put_line('x progress is '||to_char(x_progress));
                  X_ERROR := FALSE;
                  FND_MESSAGE.SET_NAME('QA', 'QA_PO_INSP_ACTION_FAIL');
                  X_message := FND_MESSAGE.GET;
                  X_message := X_message || X_msg_data;
                  INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);

                  WHEN fail_serial_insertion THEN
                  X_ERROR := FALSE;
                  FND_MESSAGE.SET_NAME('QA', 'QA_WMS_SER_INSERT_FAIL');
                  X_message := FND_MESSAGE.GET;
                  X_message := X_message || X_msg_data;
                  INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);

                  WHEN fail_lot_insertion THEN
                  X_ERROR := FALSE;
                  FND_MESSAGE.SET_NAME('QA', 'QA_WMS_LOT_INSERT_FAIL');
                  X_message := FND_MESSAGE.GET;
                  X_message := X_message || X_msg_data;
                  INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);


                  WHEN OTHERS THEN
                  --dbms_output.put_line('x progress is '||to_char(x_progress));
                  -- write exceptions to action log;
                  X_ERROR := FALSE;
                  X_message := FND_MESSAGE.GET;
                  INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
                END;  -- insert inspection

              END IF; -- inspection transaction

            -- Launch a Workflow
            ELSIF action_id_tab(i) = 28 and nvl(x_action_type, 'DEFERRED') = 'DEFERRED' THEN

              BEGIN
                OPEN workflow_itemtype(pca_id_tab(i));
                FETCH workflow_itemtype INTO X_WORKFLOW_ITEMTYPE;
                CLOSE workflow_itemtype;

                OPEN wf_itemtype_selector(X_WORKFLOW_ITEMTYPE);
                FETCH wf_itemtype_selector
                             INTO X_WORKFLOW_ITEMTYPE_SELECTOR;
                CLOSE wf_itemtype_selector;

                OPEN wf_number_of_processes (X_WORKFLOW_ITEMTYPE);
                FETCH wf_number_of_processes
                             INTO X_WORKFLOW_NUMBER_OF_PROCESSES;
                CLOSE wf_number_of_processes;

                -- Raise an exception only if number of processes is not
                -- equal to 1 (more than one) and there is no selector
                -- function defined. Please refer to bug # 1330038
                --
                -- ORASHID

                IF (X_WORKFLOW_NUMBER_OF_PROCESSES > 1)
                   AND X_WORKFLOW_ITEMTYPE_SELECTOR IS NULL THEN
                   raise wf_missing_selector;
                ELSE
                   launch_workflow(pca_id_tab(i),
                                X_WORKFLOW_ITEMTYPE, Y_PLAN_ID,
                                X_WORKFLOW_NUMBER_OF_PROCESSES);
                END IF;

              EXCEPTION
                WHEN WF_MISSING_SELECTOR THEN
                X_ERROR := FALSE;
                X_message := 'Found no SELECTOR for ' || X_WORKFLOW_ITEMTYPE;
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
                WHEN OTHERS THEN
                -- write exceptions to action log;
                X_ERROR := FALSE;
                errmsg := substr(SQLERRM,1,240);
                errcode :=SQLCODE;
                X_message := 'QA ' || to_char(errcode) || ':' || errmsg;
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END;




            --Create work request added by kaza
            ELSIF action_id_tab(i) = 29 and nvl(x_action_type, 'DEFERRED') = 'DEFERRED' THEN
                X_org_id := to_number(QLTNINRB.NAME_IN('ORGANIZATION_ID'));
                X_OCCURRENCE := to_number(QLTNINRB.NAME_IN('OCCURRENCE'));
                --dgupta: Start R12 EAM Integration. Bug 4345492
                X_ASSET_INSTANCE_ID := QLTNINRB.NAME_IN('ASSET_INSTANCE_ID');
                if (X_ASSET_INSTANCE_ID is null) then
                  X_ASSET_GROUP_ID := to_number(QLTNINRB.NAME_IN('ASSET_GROUP_ID'));
                  X_ASSET_NUMBER := QLTNINRB.NAME_IN('ASSET_NUMBER');
                end if;
                --dgupta: End R12 EAM Integration. Bug 4345492

                -- check to see if priority element exists in the plan

                Priority_exists := qa_plan_element_api.element_in_plan(Y_PLAN_ID, ELEMENT_ID);


                if (Priority_exists = TRUE) then
                   -- get the soft column name mapped to the 'priority' element.
                   OPEN Get_result_column_name (ELEMENT_ID, Y_PLAN_ID);
                   FETCH Get_result_column_name INTO Priority_soft_column;
                   CLOSE Get_result_column_name;

                   Priority_value := QLTNINRB.NAME_IN(Priority_soft_column);

                   if (Priority_value is not null) then
                      OPEN Get_priority_id (Priority_value);
                      FETCH Get_priority_id INTO Priority_id;
                      CLOSE Get_priority_id;
                   else
                      Priority_id := 1;
                   end if;

                else
                   Priority_id := 1;

                end if;

                -- get user id
                user_id := NVL(FND_PROFILE.VALUE('USER_ID'), 0);

                -- build the message for request_log by concatenating fnd_message and user input text message.

                -- Commented the usage of the cursor get_user_message and added code to use the cursor
                -- my_message, as the cursor get_user_message was showing up the message of the first
                -- trigger action of an element only in the EAM work requests even though the second or
                -- third or any other trigger condition is satisfied for the element.Refer bug for more
                -- details.
                -- Bug 3416961.suramasw.

                /*
                OPEN Get_user_message(char_id_tab(i), Y_PLAN_ID, action_id_tab(i));
                FETCH Get_user_message INTO x_message;
                CLOSE Get_user_message;
                */

                OPEN MY_MESSAGE(pca_id_tab(i));
                FETCH MY_MESSAGE INTO X_MESSAGE, X_ASSIGN_TYPE;
                CLOSE MY_MESSAGE;

                request_log := fnd_message.get_string('QA', 'QA_WORK_REQUEST_LOG');
                request_log := request_log || ' ' || x_message;



                -- call the EAM api

        BEGIN

        WIP_EAM_WORKREQUEST_PVT.create_and_approve(
                p_api_version => 1.0,
                p_init_msg_list => fnd_api.g_false,
                p_commit => fnd_api.g_true,
                p_validation_level => fnd_api.g_valid_level_full,
                p_org_id => X_org_id,
                p_asset_group_id => X_ASSET_GROUP_ID,
                p_asset_number => X_ASSET_NUMBER,
                p_maintenance_object_id => X_ASSET_INSTANCE_ID, --dgupta: R12 EAM Integration. Bug 4345492
                p_priority_id => Priority_id,
                p_request_by_date => sysdate,
                p_request_log => request_log,
                p_owning_dept_id => null, -- Owning_dept_id,
                p_user_id => user_id,
                p_work_request_type_id => null,
                p_asset_location => null,
                p_expected_resolution_date => null,
                p_work_request_created_by => 2,
                x_work_request_id => request_id,
                x_resultout => l_resultout,
                x_error_message => l_error_message,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        ) ;




        EXCEPTION
                  WHEN OTHERS THEN
                  -- write exceptions to action log;
                  X_ERROR := FALSE;
                  INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
        END;



            --Create work order added by rkaza

            -- EAM rebuild tracking bug 3133312. 09/22/2003.
            -- Modified the action to pass in rebuild item information to the
            -- work order API, if the asset group entered is a rebuild item.
            -- Also passing followup activity now as primary item, instead of
            -- asset activity. Asset activity is the activity of the parent
            -- work order. Followup activity will be the activity of the new
            -- work order being created.


            ELSIF action_id_tab(i) = 30 and nvl(x_action_type, 'DEFERRED') = 'DEFERRED' THEN

                X_org_id := to_number(QLTNINRB.NAME_IN('ORGANIZATION_ID'));
                --dgupta: Start R12 EAM Integration. Bug 4345492
                X_ASSET_INSTANCE_ID := QLTNINRB.NAME_IN('ASSET_INSTANCE_ID');
		X_ASSET_GROUP_ID := to_number(QLTNINRB.NAME_IN('ASSET_GROUP_ID'));

                if (X_ASSET_INSTANCE_ID is not null) then
                   -- Bug 8849343.Made changes to make this action capable of creating work orders
                   -- for serialised and non-serialised rebuildable work orders.
                   -- Called cursor to collect eam_item_type for this instance_id
                   -- ntungare
                   OPEN Get_eam_item_type(X_org_id, X_ASSET_INSTANCE_ID);
                   FETCH Get_eam_item_type INTO l_eam_item_type;
                   CLOSE Get_eam_item_type;
                   X_ASSET_NUMBER := QLTNINRB.NAME_IN('ASSET_NUMBER');

                   l_work_order_rec.maintenance_object_id := X_ASSET_INSTANCE_ID;
                   l_work_order_rec.maintenance_object_type := 3;

                   if l_eam_item_type = 1 then  -- Serial Controlled Asset Group
                       l_work_order_rec.asset_group_id := X_ASSET_GROUP_ID;
                       l_work_order_rec.asset_number := X_ASSET_NUMBER;
                       l_work_order_rec.rebuild_item_id := NULL;
                       l_work_order_rec.rebuild_serial_number := NULL;
                   elsif l_eam_item_type =  3 then -- Serial Controlled Rebuild Item
                       l_work_order_rec.rebuild_item_id := X_ASSET_GROUP_ID;
                       l_work_order_rec.rebuild_serial_number := NULL;
                       l_work_order_rec.asset_group_id := NULL;
                       l_work_order_rec.asset_number := NULL;
                   end if;
                else
                   -- Bug 8849343.if the instance id is null then this is
                   -- non-serialised rebuild.hence do not need the code below
		   -- hence commented.pdube Fri Aug 28 02:35:10 PDT 2009
                   l_work_order_rec.rebuild_item_id := X_ASSET_GROUP_ID;
		   l_work_order_rec.maintenance_object_id := NULL;
                   l_work_order_rec.manual_rebuild_flag := 'Y';
                   l_work_order_rec.maintenance_object_type := 2;

                   /*
                   X_ASSET_GROUP_ID := to_number(QLTNINRB.NAME_IN('ASSET_GROUP_ID'));
                   X_ASSET_NUMBER := QLTNINRB.NAME_IN('ASSET_NUMBER');
                   if (X_ASSET_GROUP_ID is not null and X_ASSET_NUMBER is null) then
                     l_work_order_rec.maintenance_object_id := X_ASSET_GROUP_ID;
                     l_work_order_rec.rebuild_item_id :=X_ASSET_GROUP_ID;
                     l_work_order_rec.maintenance_object_type := 2;
                   elsif (X_ASSET_GROUP_ID is not null) then
                     l_work_order_rec.maintenance_object_id :=
                       qa_plan_element_api.get_asset_instance_id(X_ASSET_GROUP_ID, X_ASSET_NUMBER);
                     l_work_order_rec.maintenance_object_type := 3;
                     l_work_order_rec.asset_group_id := to_number(QLTNINRB.NAME_IN('ASSET_GROUP_ID'));
                     l_work_order_rec.asset_number := QLTNINRB.NAME_IN('ASSET_NUMBER');

                   end if;*/
                end if;

                l_followup_activity_id := QLTNINRB.NAME_IN('FOLLOWUP_ACTIVITY_ID');
                --dgupta: End R12 EAM Integration. Bug 4345492
                l_work_order_rec.primary_item_id := l_followup_activity_id;

                l_work_order_rec.last_update_date := fnd_date.chardt_to_date(QLTNINRB.NAME_IN('QA_CREATION_DATE'));
                l_work_order_rec.last_updated_by := QLTNINRB.NAME_IN('LAST_UPDATED_BY');
                l_work_order_rec.creation_date := x_creation_date;
                l_work_order_rec.created_by := QLTNINRB.NAME_IN('CREATED_BY');
                l_work_order_rec.last_update_login := QLTNINRB.NAME_IN('LAST_UPDATE_LOGIN');

                l_work_order_rec.organization_id := X_org_id;
                l_work_order_rec.load_type := 7;
                l_work_order_rec.wip_supply_type := 7;

                -- l_work_order_rec.firm_planned_flag := 1;

                OPEN Get_eam_firm_flag(X_org_id);
                FETCH Get_eam_firm_flag INTO l_firm_flag;
                CLOSE Get_eam_firm_flag;

		if l_firm_flag = 'Y' then
		   l_work_order_rec.firm_planned_flag := 1;
		else
		   l_work_order_rec.firm_planned_flag := 2;
		end if;

                l_work_order_rec.process_phase := 2;
                l_work_order_rec.process_status := 1;
                l_work_order_rec.scheduling_method := 2;
                l_work_order_rec.net_quantity := 1;
                l_work_order_rec.status_type := 3;
                l_work_order_rec.first_unit_start_date := sysdate;
                l_work_order_rec.last_unit_start_date := sysdate;

                -- call the EAM api
        BEGIN

        WIP_EAMWORKORDER_PVT.Create_EAM_Work_Order
        (   p_api_version               => 1.0,
            p_init_msg_list             => FND_API.G_FALSE,
            p_commit                    => FND_API.G_FALSE,
            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
            x_return_status             => X_RETURN_STATUS,
            x_msg_count                 => X_MSG_COUNT,
            x_msg_data                  => X_MSG_DATA,
            p_work_order_rec            => l_work_order_rec,
            x_group_id                  => l_group_id,
            x_request_id                => request_id
        );


        EXCEPTION
                  WHEN OTHERS THEN
                  -- write exceptions to action log;
                  X_ERROR := FALSE;
                  INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
        END;



            -- assign ASL status
            ELSIF action_id_tab(i) = 27 and nvl(x_action_type, 'DEFERRED') = 'DEFERRED' THEN
              X_message := 'ACTION PROCESS DBG, ASSIGNING ASL STATUS';
              INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,0,
                                  0,'',
                                  '',X_message,
                                  '',X_CONCURRENT);
              -- get ASL status
              OPEN MY_STATUS(pca_id_tab(i));
              FETCH MY_STATUS INTO X_STATUS;
              CLOSE MY_STATUS ;
              -- get the vendor , item and org id
              X_org_id := to_number(QLTNINRB.NAME_IN('ORGANIZATION_ID'));
              X_Vendor_id := to_number(QLTNINRB.NAME_IN('VENDOR_ID'));
              X_Item_id := to_number (QLTNINRB.Name_in('ITEM_ID' )) ;

              -- call PO API
              BEGIN
                PO_ASL_SV.Update_Vendor_Status (x_org_id, x_vendor_id,
                        X_Status, NULL, x_item_id,'N', NULL, x_asl_return);
              EXCEPTION
                WHEN OTHERS THEN
                -- write exceptions to action log;
                X_ERROR := FALSE;
                X_message := FND_MESSAGE.GET;
                INSERT_ACTION_LOG(Y_PLAN_ID,X_COLLECTION_ID,
                                  X_CREATION_DATE,char_id_tab(i),
                                  operator_tab(i),low_value_tab(i),
                                  high_value_tab(i),X_message,
                                  result,X_CONCURRENT);
              END;

            END IF; -- switch on action_id

            i := i + 1;
            IF i > total_rows THEN
              done := TRUE;
            ELSIF pcat_id_tab(i) <> pcat_id_tab(i-1) THEN
              done := TRUE;
            END IF;

          END LOOP;  --a given action rule is true: loop to perform all actions

          IF i <= total_rows THEN
            done := FALSE;
          END IF;

          -- process all action rules with the same sequence id
          IF (not done) THEN
            IF (seq_id_tab(i) <> seq_id_tab(i-1) AND
                char_id_tab(i) = char_id_tab(i-1)) THEN
                WHILE (not done) LOOP
                  IF char_id_tab(i) = char_id_tab(i-1) THEN
                    i := i + 1;
                    IF i > total_rows THEN
                       done := TRUE;
                    END IF;
                  ELSE
                    done := TRUE;
                  END IF;
                END LOOP;
            END IF;  -- current seq num not the same as the last seq num
          END IF;   -- not done

        ELSE
          i := i + 1;
        END IF; -- IF qltcompb.compare

      END LOOP;

      OLD_SPEC_ID := Y_SPEC_ID;
      OLD_PLAN_ID := Y_PLAN_ID;

    END LOOP; -- i <= total_rows

    QLTNINRB.CLOSE_CURSOR;
    RETURN(X_ERROR);

  EXCEPTION

    When Others THEN
      --dbms_output.put_line('x progress is '||to_char(x_progress));
      QLTNINRB.CLOSE_CURSOR;
      raise;
  END DO_ACTIONS;


  PROCEDURE launch_workflow(X_PCA_ID NUMBER,
                            X_WF_ITEMTYPE VARCHAR2,
                            X_PLAN_ID NUMBER,
                            X_WORKFLOW_PROCESSES VARCHAR2) IS

  -- Bug 2671638. Added 'datatype' in the select clause
  -- rponnusa Wed Nov 20 04:33:03 PST 2002

  CURSOR OUTPUTS IS
     SELECT NVL(qc.hardcoded_column,qpc.result_column_name) Q_COLUMN,
            qpcao.token_name            TOKEN_NAME,
            qc.fk_lookup_type           LOOKUP_TYPE,
            qc.char_id                  CHAR_ID,
            qc.datatype                 DATATYPE
     from qa_chars qc,
          qa_plan_chars qpc,
          qa_plan_char_action_outputs qpcao,
          qa_plan_char_actions qpca,
          qa_plan_char_action_triggers qpcat
     where qc.char_id = qpcao.char_id
     and   qpc.char_id = qpcao.char_id
     and   qpcao.PLAN_CHAR_ACTION_ID = qpca.PLAN_CHAR_ACTION_ID
     and   qpcat.PLAN_CHAR_ACTION_TRIGGER_ID = qpca.PLAN_CHAR_ACTION_TRIGGER_ID
     and   qpc.plan_id = qpcat.plan_id
     and   qpcao.PLAN_CHAR_ACTION_ID = X_PCA_ID
     and    qc.char_context_flag <> 3
     UNION SELECT qc.hardcoded_column    Q_COLUMN,
             qpcao.token_name            TOKEN_NAME,
             qc.fk_lookup_type           LOOKUP_TYPE,
             qc.char_id                  CHAR_ID,
             qc.datatype                 DATATYPE
     from qa_chars qc,
          qa_plan_char_action_outputs qpcao,
          qa_plan_char_actions qpca,
          qa_plan_char_action_triggers qpcat
     where qc.char_id = qpcao.char_id
     and   qpcao.PLAN_CHAR_ACTION_ID = qpca.PLAN_CHAR_ACTION_ID
     and   qpcat.PLAN_CHAR_ACTION_TRIGGER_ID = qpca.PLAN_CHAR_ACTION_TRIGGER_ID
     and   qpcao.PLAN_CHAR_ACTION_ID = X_PCA_ID
     and   qc.char_context_flag = 3;

  CURSOR wf_item_attributes_cursor IS
     SELECT name
       FROM wf_item_attributes wia
      WHERE wia.item_type = X_WF_ITEMTYPE;

   -- Bug 4958762: SQL Repository Fix SQL ID: 15008550
  CURSOR token_column_datatype (t_char_id number) IS
        SELECT
            qc.datatype
        FROM qa_plan_chars qpc,
            qa_chars qc
        WHERE qc.char_id = t_char_id
            AND qpc.char_id = qc.char_id
            AND qpc.plan_id = X_PLAN_ID;
/*
     SELECT qpcv.datatype
     FROM qa_plan_chars_v qpcv
     WHERE qpcv.char_id = t_char_id
       AND qpcv.plan_id = X_PLAN_ID;
*/

  Cursor l_WorkFlowItemKey IS
    select qa_action_workflow_s.nextval
        from dual;

  TYPE wf_attributes_table IS TABLE OF WF_ITEM_ATTRIBUTES.NAME%TYPE
    INDEX BY BINARY_INTEGER;

   Cursor wf_number_of_processes IS
     select process_name
     from wf_runnable_processes_v
     where item_type = X_WF_ITEMTYPE;

  wf_itemattributes WF_ATTRIBUTES_TABLE;
  i BINARY_INTEGER := 1;
  token_datatype NUMBER;
  token_value VARCHAR2(2500);
  l_wf_itemkey VARCHAR2(240);
  l_wf_process_name  VARCHAR2(30) DEFAULT NULL;
  l_pca_id_exists    BOOLEAN := FALSE;

  BEGIN

   FOR attr_rec IN wf_item_attributes_cursor LOOP
       wf_itemattributes(i) := attr_rec.name;
       i := i + 1;
   END LOOP;

   OPEN  l_WorkflowItemKey;
   FETCH l_WorkflowItemKey INTO l_wf_itemkey;
   CLOSE l_WorkflowItemKey;

   l_wf_itemkey := 'QAACTION' || l_wf_itemkey;

   -- We will be here in two scenarios
   --
   -- 1. Number of processes is more than one and there is a selector function
   --    in this scenario, we will simply put a NULL in the process_name
   --    variable.
   --
   -- 2. Number of processes is equal to one.  In this case, we will compute
   --    the process name and populate the process_name variable with it.
   --
   -- Please refer to bug # 1330038
   --
   -- ORASHID


   IF (x_workflow_processes = 1) THEN
      OPEN  wf_number_of_processes;
      FETCH wf_number_of_processes INTO l_wf_process_name;
      CLOSE wf_number_of_processes;
   END IF;

   WF_ENGINE.CreateProcess(
       itemtype => X_WF_ITEMTYPE,
       itemkey  => l_wf_itemkey,
       process  => l_wf_process_name);

   FOR prec IN outputs LOOP

        FOR i IN wf_itemattributes.FIRST..wf_itemattributes.LAST LOOP

            -- Bug 2671638. Find out pca_id attribute available in workflow or not

            IF wf_itemattributes(i) = 'PCA_ID' THEN
               l_pca_id_exists := TRUE;
            END IF;

            IF prec.token_name = wf_itemattributes(i) THEN

               -- Bug 2671638. comment out token_column_datatype cursor since it is not needed.
               /*
               OPEN token_column_datatype(prec.char_id);
               FETCH token_column_datatype INTO token_datatype;
               CLOSE token_column_datatype;
               */

               token_datatype := prec.datatype;

               token_value := QLTNINRB.NAME_IN(prec.Q_COLUMN);

               -- Convert all normalized element ID's into its values.
               -- ex. Item_id,locator_id converted to item_name, locator respectively
               -- For performance reason, dont call qltsmenb for char_id 2,39

               IF (prec.LOOKUP_TYPE in( 0,1,3) AND prec.char_id NOT IN (2, 39)) THEN
                    token_value := QLTSMENB.LOOKUP(prec.CHAR_ID, token_value);
               END IF;

               -- Bug 2671638. Extending support to Sequence and Longcomment datatypes.
               IF token_datatype IN (1,4,5) THEN

                  WF_ENGINE.SetItemAttrText(
                                itemtype        => X_WF_ITEMTYPE,
                                itemkey         => l_wf_itemkey,
                                aname           => prec.token_name,
                                avalue          => token_value);

               ELSIF token_datatype = 2 THEN

                  WF_ENGINE.SetItemAttrNumber(
                        itemtype        => X_WF_ITEMTYPE,
                        itemkey         => l_wf_itemkey,
                        aname           => prec.token_name,
                        avalue          => fnd_number.canonical_to_number(token_value));

               -- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003
               -- Added datetime data type
               ELSIF token_datatype IN (3,6)THEN

                  WF_ENGINE.SetItemAttrDate(
                        itemtype        => X_WF_ITEMTYPE,
                        itemkey         => l_wf_itemkey,
                        aname           => prec.token_name,
                        avalue          => fnd_date.canonical_to_date(token_value));
               END IF;

               exit;
            END IF;
         END LOOP;

   END LOOP;

   -- Bug 2671638. Added following IF.  rponnusa Wed Nov 20 04:33:03 PST 2002

   IF l_pca_id_exists THEN

       WF_ENGINE.SetItemAttrNumber(
                itemtype        => X_WF_ITEMTYPE,
                itemkey         => l_wf_itemkey,
                aname           => 'PCA_ID',
                avalue          => fnd_number.canonical_to_number(X_PCA_ID));
   END IF;

   WF_ENGINE.StartProcess(
                itemtype        => X_WF_ITEMTYPE,
                itemkey         => l_wf_itemkey);


  END launch_workflow;



  PROCEDURE FIRE_ALERT(X_PCA_ID NUMBER) IS

    TYPE chartable IS TABLE OF VARCHAR2(240)
      INDEX BY BINARY_INTEGER;


    X_OUTPUTS chartable;
    i BINARY_INTEGER := 0;
    total_rows BINARY_INTEGER := 96;
    X_ACTION_SET_NAME VARCHAR2(50);
    X_REQUEST_ID NUMBER;
    ACTUAL_OUTPUT VARCHAR2(2100);


  CURSOR OUTPUTS IS
     SELECT NVL(qc.hardcoded_column,qpc.result_column_name) Q_COLUMN,
            qpcao.token_name            TOKEN_NAME,
            qc.fk_lookup_type           LOOKUP_TYPE,
            qc.char_id                  CHAR_ID
     from qa_chars qc,
          qa_plan_chars qpc,
          qa_plan_char_action_outputs qpcao,
          qa_plan_char_actions qpca,
          qa_plan_char_action_triggers qpcat
     where qc.char_id = qpcao.char_id
     and   qpc.char_id = qpcao.char_id
     and   qpcao.PLAN_CHAR_ACTION_ID = qpca.PLAN_CHAR_ACTION_ID
     and   qpcat.PLAN_CHAR_ACTION_TRIGGER_ID = qpca.PLAN_CHAR_ACTION_TRIGGER_ID
     and   qpc.plan_id = qpcat.plan_id
     and   qpcao.PLAN_CHAR_ACTION_ID = X_PCA_ID
     and    qc.char_context_flag <> 3
UNION SELECT qc.hardcoded_column         Q_COLUMN,
             qpcao.token_name            TOKEN_NAME,
             qc.fk_lookup_type           LOOKUP_TYPE,
             qc.char_id                  CHAR_ID
     from qa_chars qc,
          qa_plan_char_action_outputs qpcao,
          qa_plan_char_actions qpca,
          qa_plan_char_action_triggers qpcat
     where qc.char_id = qpcao.char_id
     and   qpcao.PLAN_CHAR_ACTION_ID = qpca.PLAN_CHAR_ACTION_ID
     and   qpcat.PLAN_CHAR_ACTION_TRIGGER_ID = qpca.PLAN_CHAR_ACTION_TRIGGER_ID
     and   qpcao.PLAN_CHAR_ACTION_ID = X_PCA_ID
     and   qc.char_context_flag = 3;

  CURSOR ACTION_SET_NAME IS
     SELECT aas.NAME
     FROM QA_PLAN_CHAR_ACTIONS qpca,
          ALR_ACTION_SETS aas
     WHERE qpca.PLAN_CHAR_ACTION_ID = X_PCA_ID
     AND   qpca.ALR_ACTION_SET_ID = aas.ACTION_SET_ID
     AND   aas.APPLICATION_ID = 250;

  -- Kashyap. For Bug2408728.
  l_count   NUMBER;
  l_size    NUMBER;
  SUFFIXSTRING VARCHAR2(10) := '_QAKM_Z';

  -- suramasw.Bug 2921276.Wed Jul 30 05:15:40 PDT 2003
  l_occurrence NUMBER;

  -- suramasw.Bug 3162828.

  CURSOR CPLAN(l_pca_id number) IS
    SELECT plan_id FROM qa_plan_char_action_triggers
    WHERE plan_char_action_trigger_id = (select PLAN_CHAR_ACTION_TRIGGER_ID
    FROM QA_PLAN_CHAR_ACTIONS WHERE PLAN_CHAR_ACTION_ID = l_pca_id);

  CURSOR RESULT_COLUMN(l_plan_id number, l_pca_id number) IS
   SELECT result_column_name FROM qa_plan_chars
   WHERE plan_id = l_plan_id AND char_id = ( SELECT char_id
   FROM qa_plan_char_action_triggers WHERE
   plan_char_action_trigger_id = (SELECT plan_char_action_trigger_id
   FROM qa_plan_char_actions WHERE plan_char_action_id = l_pca_id));

  l_result_column_name  VARCHAR2(100);
  l_result_column_value VARCHAR2(2000);
  l_plan_id             NUMBER;
  l_sql_string          VARCHAR2(1000);

  BEGIN

     -- First we get the Action_set_name
     open ACTION_SET_NAME;
     FETCH ACTION_SET_NAME INTO X_ACTION_SET_NAME;
     close ACTION_SET_NAME;

     -- suramasw.Bug 2921276.Wed Jul 30 05:15:40 PDT 2003
     l_occurrence := TO_NUMBER(QLTNINRB.NAME_IN('OCCURRENCE'));

     -- Next we get any outputs to the alert
     FOR prec in OUTPUTS LOOP
         i := i + 1;
         ACTUAL_OUTPUT := QLTNINRB.NAME_IN(prec.Q_COLUMN);
         IF (prec.LOOKUP_TYPE = 0) or (prec.LOOKUP_TYPE = 1) or
            (prec.LOOKUP_TYPE = 3) THEN
            ACTUAL_OUTPUT := QLTSMENB.LOOKUP(prec.CHAR_ID, ACTUAL_OUTPUT);
         end IF;

/*kashyap, rkaza 06/14/2002. as part of fix for Bug 2408728 */
         IF (qa_chars_api.datatype(prec.char_id) = 4) THEN

            -- Bug 2640953. If the ACTUAL_OUTPUT is NULL, set the l_count to 0.
            -- Added the NVL() below. kabalakr.

            l_count := NVL(ROUND(LENGTH(ACTUAL_OUTPUT)/200) + 1, 0);
            l_size  := 0;

            FOR x IN 1..l_count LOOP
               X_OUTPUTS(i) := prec.TOKEN_NAME || SUFFIXSTRING || to_char(x)||'=' ||
                        substr(ACTUAL_OUTPUT,l_size, 200);

               l_size := l_size + 200 ;
               i := i + 1;
            END LOOP;

            FOR y IN (l_count+1)..10 LOOP
               X_OUTPUTS(i) := prec.TOKEN_NAME || SUFFIXSTRING || to_char(y)||'=' ||'';
               i := i + 1;
            END LOOP;

            i := i - 1;
         ELSE
            X_OUTPUTS(i) := prec.TOKEN_NAME || '=' || ACTUAL_OUTPUT;
         END IF;

     END LOOP;

     -- suramasw.Bug 2921276.Wed Jul 30 05:15:40 PDT 2003
     -- QA_PLAN_CHAR_VALUE and QA_OCCURRENCE will be passed as parameter
     -- to ALECDC. QA_PLAN_CHAR_VALUE will hold the value of the token
     -- and QA_OCCURRENCE will hold the occurrence.From now only when
     -- the collection element which has the action associated with it
     -- is updated in UQR the action will fire for that collection element.

     -- i := i + 1;

     /*
        Added the following piece of code and commented the code added as
        a part Bug 2921276. X_OUTPUTS(i+1) had been assigned with wrong
        value(ACTUAL_OUTPUT) as part of the fix done for 2921276.

        Functionality after the fix
        --------------------------------
        Identify the collection element value(l_result_column_value) and
        occurrence(l_occurrence) for every update. The values will be passed
        to alerts which takes the combination of l_result_column_value and
        l_occurrence and fires the action if that particular combination is
        not already available. But before this some mandatory steps are needed
        in Oracle Alerts which is specified in the ARU readme.

        Bug 3162828.suramasw.
     */

     OPEN CPLAN(x_pca_id);
     fetch CPLAN into l_plan_id;
     close CPLAN;

     OPEN RESULT_COLUMN(l_plan_id,x_pca_id);
     FETCH RESULT_COLUMN INTO l_result_column_name;
     CLOSE RESULT_COLUMN;

     l_sql_string := 'SELECT '|| l_result_column_name ||' FROM QA_RESULTS '||
                'WHERE PLAN_ID = :l_plan_id AND OCCURRENCE = :l_occurrence';

     EXECUTE IMMEDIATE l_sql_string into l_result_column_value
             USING l_plan_id,l_occurrence;

     X_OUTPUTS(i+1) := 'QA_PLAN_CHAR_VALUE='|| l_result_column_value;
     X_OUTPUTS(i+2) := 'QA_OCCURRENCE='|| l_occurrence;

     /*
     X_OUTPUTS(i+1) := 'QA_PLAN_CHAR_VALUE='|| ACTUAL_OUTPUT;
     X_OUTPUTS(i+2) := 'QA_OCCURRENCE='|| l_occurrence;
     */

     i := i + 3;

     -- End of inclusions for Bug 2921276.

     -- Now we add a chr(0) to signIFy a end of outputs
     IF i <= total_rows THEN
        X_OUTPUTS(i) := chr(0);
        i := i + 1;
     end IF;

     -- Now we add nulls to the rest of the X_OUTPUTS
     WHILE i <= total_rows LOOP
        X_OUTPUTS(i) := null;
        i := i + 1;
     end LOOP;

     -- Bug 4210833.suramasw.
     -- Included arguments X_OUTPUTS(41) to X_OUTPUTS(50) in the following call to
     -- ALECDC. Since those 10 arguments were missed, if the call from Quality to
     -- Alert actions exceeds 40 arguments then the 'Check Periodic Alert' concurrent
     -- request fails with the error reported in the bug.

     -- now we call the alert API
     X_REQUEST_ID := fnd_request.submit_request('ALR','ALECDC', null,
                                                null, FALSE, '250', '10177',
                                                'A',X_ACTION_SET_NAME,
                                                X_OUTPUTS(1), X_OUTPUTS(2),
                                                X_OUTPUTS(3), X_OUTPUTS(4),
                                                X_OUTPUTS(5), X_OUTPUTS(6),
                                                X_OUTPUTS(7), X_OUTPUTS(8),
                                                X_OUTPUTS(9), X_OUTPUTS(10),
                                                X_OUTPUTS(11), X_OUTPUTS(12),
                                                X_OUTPUTS(13), X_OUTPUTS(14),
                                                X_OUTPUTS(15), X_OUTPUTS(16),
                                                X_OUTPUTS(17), X_OUTPUTS(18),
                                                X_OUTPUTS(19), X_OUTPUTS(20),
                                                X_OUTPUTS(21), X_OUTPUTS(22),
                                                X_OUTPUTS(23), X_OUTPUTS(24),
                                                X_OUTPUTS(25), X_OUTPUTS(26),
                                                X_OUTPUTS(27), X_OUTPUTS(28),
                                                X_OUTPUTS(29), X_OUTPUTS(30),
                                                X_OUTPUTS(31), X_OUTPUTS(32),
                                                X_OUTPUTS(33), X_OUTPUTS(34),
                                                X_OUTPUTS(35), X_OUTPUTS(36),
                                                X_OUTPUTS(37), X_OUTPUTS(38),
                                                X_OUTPUTS(39), X_OUTPUTS(40),
                                                X_OUTPUTS(41), X_OUTPUTS(42),
                                                X_OUTPUTS(43), X_OUTPUTS(44),
                                                X_OUTPUTS(45), X_OUTPUTS(46),
                                                X_OUTPUTS(47), X_OUTPUTS(48),
                                                X_OUTPUTS(49), X_OUTPUTS(50),
                                                X_OUTPUTS(51), X_OUTPUTS(52),
                                                X_OUTPUTS(53), X_OUTPUTS(54),
                                                X_OUTPUTS(55), X_OUTPUTS(56),
                                                X_OUTPUTS(57), X_OUTPUTS(58),
                                                X_OUTPUTS(59), X_OUTPUTS(60),
                                                X_OUTPUTS(61), X_OUTPUTS(62),
                                                X_OUTPUTS(63), X_OUTPUTS(64),
                                                X_OUTPUTS(65), X_OUTPUTS(66),
                                                X_OUTPUTS(67), X_OUTPUTS(68),
                                                X_OUTPUTS(69), X_OUTPUTS(70),
                                                X_OUTPUTS(71), X_OUTPUTS(72),
                                                X_OUTPUTS(73), X_OUTPUTS(74),
                                                X_OUTPUTS(75), X_OUTPUTS(76),
                                                X_OUTPUTS(77), X_OUTPUTS(78),
                                                X_OUTPUTS(79), X_OUTPUTS(80),
                                                X_OUTPUTS(81), X_OUTPUTS(82),
                                                X_OUTPUTS(83), X_OUTPUTS(84),
                                                X_OUTPUTS(85), X_OUTPUTS(86),
                                                X_OUTPUTS(87), X_OUTPUTS(88),
                                                X_OUTPUTS(89), X_OUTPUTS(90),
                                                X_OUTPUTS(91), X_OUTPUTS(92),
                                                X_OUTPUTS(93), X_OUTPUTS(94),
                                                X_OUTPUTS(95), X_OUTPUTS(96));

  END FIRE_ALERT;

  --
  -- Bug 4751249
  -- Added a new procedure that will derive the normalized value
  -- based on the assigned column and the denormalized value passed
  -- ntungare Sat Nov 26 00:20:36 PST 2005
  --
  PROCEDURE GET_DERIVED_VALUE(assigned_col  VARCHAR2,
                              denorm_val    IN OUT NOCOPY VARCHAR2) AS
   BEGIN
       --
       -- bug 7552682
       -- Added the COMP_ITEM_ID
       -- ntungare
       --
       -- IF assigned_col  = 'ITEM_ID' THEN
       IF assigned_col  IN ( 'ITEM_ID', 'COMP_ITEM_ID') THEN
          denorm_val := to_char(QA_FLEX_UTIL.get_item_id(to_number(QLTNINRB.NAME_IN('ORGANIZATION_ID')),denorm_val));
       ELSIF  assigned_col = 'VENDOR_ID' THEN
          denorm_val := qa_plan_element_api.get_supplier_id(denorm_val);
       END IF;
   END;

  PROCEDURE DO_ASSIGNMENT(X_PCA_ID NUMBER,
                          X_MESSAGE VARCHAR2,
                          X_ASSIGNED_CHAR_ID NUMBER,
                          X_COLLECTION_ID NUMBER,
                          X_OCCURRENCE NUMBER,
                          X_PLAN_ID NUMBER,
                          X_SQL_STATEMENT OUT NOCOPY VARCHAR2) IS

    CURSOR OUTPUTS IS
     SELECT NVL(qc.hardcoded_column,qpc.result_column_name) Q_COLUMN,
            qpcao.token_name            TOKEN_NAME,
            qc.fk_lookup_type           LOOKUP_TYPE,
            qc.char_id                  CHAR_ID
     from qa_chars qc,
          qa_plan_chars qpc,
          qa_plan_char_actions qpca,
          qa_plan_char_action_triggers qpcat,
          qa_plan_char_action_outputs qpcao
     where qc.char_id = qpcao.char_id
     and   qpc.char_id = qpcao.char_id
     and   qpcao.PLAN_CHAR_ACTION_ID = qpca.PLAN_CHAR_ACTION_ID
     and   qpcat.PLAN_CHAR_ACTION_TRIGGER_ID = qpca.PLAN_CHAR_ACTION_TRIGGER_ID
     and   qpc.plan_id = qpcat.plan_id
     and   qpcao.PLAN_CHAR_ACTION_ID = X_PCA_ID
     and    qc.char_context_flag <> 3
  UNION SELECT qc.hardcoded_column       Q_COLUMN,
             qpcao.token_name            TOKEN_NAME,
             qc.fk_lookup_type           LOOKUP_TYPE,
             qc.char_id                  CHAR_ID
     from qa_chars qc,
          qa_plan_char_actions qpca,
          qa_plan_char_action_triggers qpcat,
          qa_plan_char_action_outputs qpcao
     where qc.char_id = qpcao.char_id
     and   qpcao.PLAN_CHAR_ACTION_ID = qpca.PLAN_CHAR_ACTION_ID
     and   qpcat.PLAN_CHAR_ACTION_TRIGGER_ID = qpca.PLAN_CHAR_ACTION_TRIGGER_ID
     and   qpcao.PLAN_CHAR_ACTION_ID = X_PCA_ID
     and   qc.char_context_flag = 3;

  -- Bug 4958762: SQL Repository Fix SQL ID: 15008686
  CURSOR ASSIGNED_COLUMN (t_char_id number) IS
        SELECT
            NVL(qc.hardcoded_column,qpc.result_column_name) Q_COLUMN,
            qc.datatype,
            DECODE(qpc.decimal_precision, NULL, qc.decimal_precision, qpc.decimal_precision)
        FROM qa_plan_chars qpc,
            qa_chars qc
        WHERE qc.char_id = qpc.char_id
            AND qc.char_id = t_char_id
            AND qpc.plan_id = X_PLAN_ID;
/*
     SELECT NVL(qpcv.hardcoded_column,qpcv.result_column_name) Q_COLUMN,
            qpcv.datatype, qpcv.decimal_precision
     FROM qa_plan_chars_v qpcv
     WHERE qpcv.char_id = t_char_id
       AND qpcv.plan_id = X_PLAN_ID;
*/

  -- Bug 5150287. SHKALYAN 02-Mar-2006.
  -- Increased the width of sql_stmt, final_stmt and update_stmt to 2500 from
  -- 2000. If the one of the target elements is a comment datatype and has a
  -- value of approx 2000 characters then these variables would not be able to
  -- hold the whole string and would raise an exception. So increased the width.
  sql_stmt              VARCHAR2(2500) := X_MESSAGE;
  final_stmt            VARCHAR2(2500) := '';
  update_stmt           VARCHAR2(2500);
  len                   NUMBER;
  i                     NUMBER := 1;
  j                     NUMBER;
  k                     NUMBER := 1; --enumerated bind variable counter
  curr_char             VARCHAR2(30);
  token_name            VARCHAR2(30);
  token_char_id         NUMBER;

  -- Bug 5150287. SHKALYAN 02-Mar-2006.
  -- Increased the column width of token_column_value from 150 to 2000.
  -- If the value of token_column_value which is going to be copied to
  -- the target element is more than 150 characters then ORA-06502
  -- would be raised. To prevent that column width has been increased.
  token_column_value    VARCHAR2(2000);

  bind_var_name         VARCHAR2(150);
  y_column              VARCHAR2(30);

  y_datatype            NUMBER;
  y_deciprec            NUMBER;
  c1                    NUMBER;
  ignore                NUMBER;

  --
  -- Bug 2976810
  -- to get rid of a sql bind compliance exemption, the token values used in
  -- an assign a value action are now accumulated in an array and passed in as
  -- bind variables instead of as literals
  -- ilawler Tue May 27 13:34:49 2003
  --
  TYPE tokenValTab IS TABLE OF token_column_value%TYPE INDEX BY BINARY_INTEGER;
  token_vals            tokenValTab;

  -- Bug 5150287. SHKALYAN 02-Mar-2006.
  -- Increased the column width of return_value_char from 1500 to
  -- 2000 for the same reason mentioned above for token_column_value.
  return_value_char     VARCHAR2(2000);

  return_value_num      NUMBER;
  return_value_date     DATE;
  find_token            BOOLEAN := FALSE;

  BEGIN

    len := length (sql_stmt);

    WHILE i <= len LOOP
      curr_char := substr(sql_stmt, i, 1);

      IF curr_char <> '&' THEN
        final_stmt := final_stmt || curr_char;
        i := i + 1;

      ELSE   -- we're at an ampersand
        i := i + 1;    -- skip over ampersand
        token_name := '';
        curr_char := substr(sql_stmt, i, 1);

        WHILE curr_char between '0' and '9'
         or curr_char between 'A' and 'Z'
         or curr_char between 'a' and 'z'
        LOOP
          token_name := token_name || curr_char;
          i := i + 1;
          curr_char := substr(sql_stmt, i, 1);
        END LOOP;

          find_token := FALSE;
          FOR prec in OUTPUTS LOOP
            EXIT WHEN find_token;
            IF UPPER(token_name) = UPPER(prec.token_name) THEN
              token_char_id := prec.char_id;
              token_column_value := QLTNINRB.NAME_IN(prec.Q_COLUMN);
              IF (prec.LOOKUP_TYPE = 0) or (prec.LOOKUP_TYPE = 1) or
                 (prec.LOOKUP_TYPE = 3) THEN
                 token_column_value := QLTSMENB.LOOKUP(prec.CHAR_ID,
                                                       token_column_value);
              END IF;
              find_token := TRUE;
            END IF;
          END LOOP;

          IF NOT find_token THEN -- it doesn't find match in the output
            --token_column_value := '&'||token_name;  -- just don't substitude
            APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;

           OPEN ASSIGNED_COLUMN (token_char_id);
          FETCH ASSIGNED_COLUMN
           INTO y_column, y_datatype, y_deciprec;
          CLOSE ASSIGNED_COLUMN;

          bind_var_name := ':' || k;

          -- Bug 5150287. SHKALYAN 02-Mar-2006.
          -- Included comment datatype(y_datatype=4) in the following IF loop.
          -- Before this fix if we try to assign a value to a comment datatype
          -- element the action would fire but the value would not be copied
          -- to the target element (or) would error out in Collection Import.
          if y_datatype in (1,4) then
             bind_var_name := bind_var_name;
          elsif y_datatype = 2 then
             bind_var_name:= 'nvl(qltdate.canon_to_number(' || bind_var_name || '), 0)';
          elsif y_datatype = 3 then
             bind_var_name := 'qltdate.any_to_date(' || bind_var_name || ')';

          -- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003
          elsif y_datatype = 6 then
            -- Bug 3211247. rponnusa Tue Oct 28 23:19:18 PST 2003
            /*
            IF y_column LIKE 'CHARACTER%' THEN
               bind_var_name := 'qltdate.canon_to_date(' || bind_var_name || ')';
            ELSE
               bind_var_name := bind_var_name;
            END IF;
            */
             bind_var_name := 'qltdate.any_to_datetime(' || bind_var_name || ')';
          end if;

          --add the token value to the token value array and append the bind variable string to the statement
          token_vals(k) := token_column_value;
          final_stmt := final_stmt || bind_var_name ;
          X_SQL_STATEMENT := final_stmt;

          k := k + 1;

      END IF; -- curr_char <> '&'
    END LOOP; -- while i < len

    -- parse the sql_statement, and get the final value
    -- assign value to the corresponding column
    -- update the table with the assigned value
    BEGIN

      OPEN ASSIGNED_COLUMN (X_ASSIGNED_CHAR_ID);
      FETCH ASSIGNED_COLUMN
         INTO y_column, y_datatype, y_deciprec;
      CLOSE ASSIGNED_COLUMN;

      c1 := dbms_sql.open_cursor;
      dbms_sql.parse(c1, final_stmt, dbms_sql.native);

      --go through the token_vals array and do the bindings
      k := token_vals.FIRST;
      WHILE (k IS NOT NULL) LOOP
         dbms_sql.bind_variable(c1, ':' || to_char(k), token_vals(k));
         k := token_vals.NEXT(k);
      END LOOP;

      -- Bug 5150287. SHKALYAN 02-Mar-2006.
      -- Included comment datatype(y_datatype=4) in the following IF loop.
      -- Before this fix if we try to assign a value to a comment datatype
      -- element the action would fire but the value would not be copied to
      -- the target element in Collection Import.
      -- Also increased the width of return_value_char from 1500 to 2000.
      IF y_datatype in (1,4) THEN
           dbms_sql.define_column(c1, 1, return_value_char, 2000);
      ELSIF y_datatype = 2 THEN
           dbms_sql.define_column(c1, 1, return_value_num);

      ELSIF y_datatype = 3 THEN
          -- Bug 3213920. rponnusa Tue Oct 28 23:19:18 PST 2003
          -- define the column as date type
          dbms_sql.define_column(c1, 1, return_value_date);

      -- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003

      ELSIF y_datatype = 6 THEN -- datetime
           dbms_sql.define_column(c1, 1, return_value_date);
            -- Bug 3211247. rponnusa Tue Oct 28 23:19:18 PST 2003
            -- convert to canon mask for softcoded elements.
            IF y_column LIKE 'CHARACTER%' THEN
               bind_var_name := 'qltdate.date_to_canon_dt(' || bind_var_name || ')';
            END IF;

      END IF;

      ignore := dbms_sql.execute(c1);

      --
      -- Bug 2976810
      -- although this piece of SQL was not in the original plan, update it to use EXECUTE IMMEDIATE
      -- with bind variables instead of piecing the SQL together with string concats.
      -- Note: the column name is still hardcoded because you can't bind schema object names
      -- ilawler Tue May 27 13:34:49 2003
      --
      update_stmt := 'UPDATE qa_results SET ' || y_column || ' = '  ;

      --set the default bind variable name
      bind_var_name := ':CHAR_VALUE';

      IF dbms_sql.fetch_rows(c1)>0 THEN

          --get the column's value into return_value_char|num and add a properly wrapped bind variable for it

          -- Bug 5150287. SHKALYAN 02-Mar-2006.
          -- Included y_datatype=4 also in the following loop for the same
          -- reason mentioned few lines above.
          IF y_datatype in (1,4) THEN

            dbms_sql.column_value(c1, 1, return_value_char);

            --
            -- Bug 4751249
            -- Made a call to the new procedure added that will get the
            -- normalized value for the assigned column using the
            -- denormalized value passed
            -- ntungare Sat Nov 26 00:19:07 PST 2005
            --
            GET_DERIVED_VALUE(y_column, return_value_char);

            ELSIF y_datatype = 2 THEN

            dbms_sql.column_value(c1, 1, return_value_num);
            return_value_num := round(return_value_num, nvl(y_deciprec, 0));

            IF y_column LIKE 'CHARACTER%' THEN
                bind_var_name := 'qltdate.number_to_canon(' || bind_var_name || ')';
            END IF;

          ELSIF y_datatype = 3 THEN

            -- Bug 3213920. rponnusa Tue Oct 28 23:19:18 PST 2003
            -- fetch the col value as Date type

            dbms_sql.column_value(c1, 1, return_value_date);

            IF y_column LIKE 'CHARACTER%' THEN
               bind_var_name := 'qltdate.date_to_canon(' || bind_var_name || ')';
            END IF;

          -- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003
          ELSIF y_datatype = 6 THEN -- datetime

            dbms_sql.column_value(c1, 1, return_value_date);

            IF y_column LIKE 'CHARACTER%' THEN
               bind_var_name := 'qltdate.date_to_canon_dt(' || bind_var_name || ')';
            END IF;

          END IF; -- IF y_datatype
      ELSE
         --
         -- Bug 1431126.  If the user sql statement does not return
         -- any value, the action processor will fail.  It is nicer
         -- to treat that as assigning a NULL.  ("51" Bug 1432918)
         --
         -- also modify the target datatype so the execute immediate knows to use return_value_char
         y_datatype := 1;
         return_value_char := NULL;

      END IF; -- IF fetch_rows

      dbms_sql.close_cursor(c1);

      --add the bind variable name and additional where clause params to the update statement
      update_stmt := update_stmt || bind_var_name || ' WHERE plan_id = :PLAN_ID AND '||
                                                            'collection_id = :COLL_ID AND '||
                                                            'occurrence = :OCCURRENCE';

      --modify the bind variable values if the source is a number
      IF y_datatype = 2 THEN
         EXECUTE IMMEDIATE update_stmt USING return_value_num, X_PLAN_ID, X_COLLECTION_ID, X_OCCURRENCE;

      -- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003
      -- Added datetime data type

      -- Bug 3213920. rponnusa Tue Oct 28 23:19:18 PST 2003
      -- Added date type
      ELSIF y_datatype IN (3, 6) THEN
         EXECUTE IMMEDIATE update_stmt USING
                        return_value_date,
                        X_PLAN_ID,
                        X_COLLECTION_ID,
                        X_OCCURRENCE;

      ELSE
         EXECUTE IMMEDIATE update_stmt USING return_value_char, X_PLAN_ID, X_COLLECTION_ID, X_OCCURRENCE;
      END IF;

      --make sure we modified a single row, otherwise raise exception
      IF SQL%ROWCOUNT <> 1 THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      --
      -- Bug 7491253. 12.1.1 FP for Bug 6599571
      -- Added this if-else ladder to update the record in session
      -- in order to fire the cascaded actions.
      -- skolluku
      IF y_datatype IN (1,4) AND (return_value_char IS NOT NULL) THEN
         qltninrb.set_value(y_column,return_value_char);
      END IF;
      IF y_datatype=2 and return_value_num is not null then
         qltninrb.set_value(y_column,to_char(return_value_num));
      END IF;
      IF y_datatype = 6 and return_value_date is not null then
        IF y_column LIKE 'CHARACTER%' THEN
           qltninrb.set_value(y_column,qltdate.date_to_canon_dt(return_value_date));
        ELSE
           qltninrb.set_value(y_column,to_char(return_value_date));
        END IF;
      END IF;
      IF y_datatype = 3 AND return_value_date IS NOT NULL THEN
         IF y_column LIKE 'CHARACTER%' THEN
            qltninrb.set_value(y_column,qltdate.date_to_canon(return_value_date));
         ELSE
            qltninrb.set_value(y_column,to_char(return_value_date));
         END IF;
      END IF;
      -- End of bug 7491253
    END;

  END DO_ASSIGNMENT;


  -- Bug 3270283. This procedure takes care of defaulting the receiving subinventory
  -- and locator values to the transfer LPN from the parent LPN. The inputs to this
  -- procedure are  -
  -- X_LPN_ID         : Parent LPN_ID
  -- X_XFR_LPN_ID     : Transfer LPN_ID
  -- X_TRANSACTION_ID : Interface Transaction id of the Inspection record inserted
  --                    into RTI by RCV API.
  --
  -- The logic followed is as follows -
  -- 1. Fetch the LPN context, Sub and Loc info for the Transfer LPN.
  -- 2. If the LPN context is 'Resides in Receiving', then keep the Sub and Loc info.
  -- 3. If not 'Resides in Receiving', then fetch the Sub and Loc info of the parent LPN.
  -- 4. Update RTI for the interface_transaction_id (X_TRANSACTION_ID), with the
  --    values for Sub and Loc.
  --
  -- kabalakr Mon Mar  8 08:01:35 PST 2004.
  --
  -- Bug 6781108
  -- Deleted the Transaction_id and Converted the two variables
  -- l_rti_sub_code and l_rti_loc_id as out parameters
  -- pdube Wed Feb  6 04:53:32 PST 2008
  PROCEDURE DEFAULT_LPN_SUB_LOC_INFO(X_LPN_ID         NUMBER,
                                     X_XFR_LPN_ID     NUMBER,
                                     -- X_TRANSACTION_ID NUMBER
                                     l_rti_sub_code  OUT  NOCOPY  mtl_secondary_inventories.secondary_inventory_name%TYPE,
                                     l_rti_loc_id    OUT  NOCOPY  NUMBER) IS

    l_lpn_sub           mtl_secondary_inventories.secondary_inventory_name%TYPE;
    l_lpn_loc_id        NUMBER;
    l_xfer_lpn_sub      mtl_secondary_inventories.secondary_inventory_name%TYPE;
    l_xfer_lpn_loc_id   NUMBER;
    l_xfer_lpn_ctxt     NUMBER;
    -- Bug 6781108
    -- Commenting the following two variables
    -- l_rti_sub_code      mtl_secondary_inventories.secondary_inventory_name%TYPE;
    -- l_rti_loc_id        NUMBER;

  BEGIN

    IF (x_lpn_id IS NOT NULL) THEN

      BEGIN
        SELECT   lpn_context
               , subinventory_code
               , locator_id
        INTO     l_xfer_lpn_ctxt
               , l_xfer_lpn_sub
               , l_xfer_lpn_loc_id
        FROM     wms_license_plate_numbers
        WHERE    lpn_id = x_xfr_lpn_id;


        -- If Transfer LPN resides in Receiving, then keep the
        -- values for Receiving Sub and Loc. Else, derive it from
        -- the parent LPN.

        IF (NVL(l_xfer_lpn_ctxt, 5) = 3) THEN
          l_rti_sub_code := l_xfer_lpn_sub;
          l_rti_loc_id   := l_xfer_lpn_loc_id;

        ELSE

          -- Transfer LPN has been generated newly, so we need to default the RTI
          -- with the sub/locator of the parent LPN

          BEGIN
            SELECT   subinventory_code
                   , locator_id
            INTO     l_lpn_sub
                   , l_lpn_loc_id
            FROM     wms_license_plate_numbers
            WHERE    lpn_id = x_lpn_id;

            l_rti_sub_code := l_lpn_sub;
            l_rti_loc_id   := l_lpn_loc_id;

          EXCEPTION
            WHEN OTHERS THEN
              l_rti_sub_code := NULL;
              l_rti_loc_id   := NULL;
          END;
        END IF;   --END IF check xfer lpn context

      EXCEPTION
        WHEN OTHERS THEN
          l_rti_sub_code := NULL;
          l_rti_loc_id   := NULL;
      END;


      -- Now, we have derived the Subinventory and Locator info for the Transfer
      -- LPN. We need to update the RTI record with these values.

      -- Bug 6781108
      -- Commenting the following update statement as
      -- the receiving API is handling this scenario.
      -- pdube Wed Feb  6 04:51:22 PST 2008
      -- UPDATE RCV_TRANSACTIONS_INTERFACE
      --    SET subinventory = l_rti_sub_code,
      --        locator_id   = l_rti_loc_id
      -- WHERE interface_transaction_id = X_TRANSACTION_ID;


    END IF;


  END DEFAULT_LPN_SUB_LOC_INFO;

-- 12.1 QWB Usability Improvements
-- Function to replace tokens defined in an
-- action message
FUNCTION replace_tokens(p_plan_char_action_id IN NUMBER,
                        p_message_str IN VARCHAR2,
                        p_assign_type IN VARCHAr2,
                        P_assigned_elem_type IN NUMBER)
   RETURN VARCHAR2 AS
  Type token_rec IS record(token_name VARCHAR2(100),
                           char_name VARCHAR2(100));
  Type token_rec_tab_typ IS TABLE OF token_rec INDEX BY binary_integer;
  token_rec_tab token_rec_tab_typ;

  l_message_str VARCHAR2(4000);
BEGIN
  -- fetching the token names and the elements
  -- they are mapped to
  --
  -- bug 6904497
  -- Ordering the tokens in the decreasing
  -- order of their length before replacement
  -- to ensure that the longest tokens get replaced
  -- first.
  -- ntungare
  --
  SELECT TRIM(token_name) tokenName,
    'CHARID' || char_id bulk collect
  INTO token_rec_tab
  FROM qa_plan_char_action_outputs
  WHERE plan_char_action_id = p_plan_char_action_id
   order by length(tokenName) desc ;

  l_message_str := p_message_str;
  FOR cntr IN 1 .. token_rec_tab.COUNT
  LOOP
    -- Performing a case Insensitive replacement
    -- of the tokens with the field names
    --
    SELECT REGEXP_REPLACE(l_message_str,
                  '&' || token_rec_tab(cntr).token_name,
                  '&' || token_rec_tab(cntr).char_name || ';',
                  1,
                  0,
                  'i')
     INTO l_message_str
    FROM dual;
  END LOOP;
  RETURN l_message_str;
END replace_tokens;

-- 12.1 QWB Usability Improvements
-- Function to compute the lower limit for
-- an acion trigger.
FUNCTION low_val(p_plan_id in NUMBER,
                 p_spec_id in NUMBER,
                 p_char_id in number,
                 p_char_type in number,
                 p_lowval_lookup in NUMBER,
                 p_highval_lookup in NUMBER,
                 p_char_uom in VARCHAR2,
                 p_plan_uom in VARCHAR2,
                 p_precision in NUMBER)
   RETURN VARCHAR2 AS
   low_val  NUMBER;
   high_val NUMBER;
BEGIN
   -- Processing for Numeric elements
   IF (p_char_type =2) THEN
     -- Fetching the low values using the limit of the spec selected
     -- or the specs defined on the collection element.
     -- If the spec_id is not null which means that a user defined
     -- spec has been selected then the API performs the UOM conversions
     -- as well
     qa_plan_element_api.get_low_high_values(
        p_plan_id, p_spec_id, p_char_id,
        p_lowval_lookup, p_highval_lookup,
        low_val, high_val);

     -- If the low and high values are based on the spec limits defined
     -- on the collection element level and the element is not of the same
     -- UOM as that of the collection plan then the UOM conversion needs to
     -- be done.
     IF (p_char_uom <> p_plan_uom and
         P_spec_id  = 0) THEN
        low_val := qa_plan_element_api.perform_uom_conversion(
                        p_source_val => low_val ,
                        p_precision  => p_precision,
                        p_source_UOM => p_char_uom,
                        p_target_UOM => p_plan_uom);

     END IF;
   ELSE
        -- If the low value is not numeric then it is returned as is
        -- need to check what format to return for dates.
        low_val := p_lowval_lookup;
   END IF;

   RETURN TO_CHAR(low_val);
END low_val;

-- 12.1 QWB Usability Improvements
-- Function to compute the upper limit for
-- an acion trigger.

FUNCTION high_val(p_plan_id in NUMBER,
                  p_spec_id in NUMBER,
                  p_char_id in number,
                  p_char_type in number,
                  p_lowval_lookup in NUMBER,
                  p_highval_lookup in NUMBER,
                  p_char_uom in VARCHAR2,
                  p_plan_uom in VARCHAR2,
                  p_precision in NUMBER)
   RETURN VARCHAR2 AS
   low_val  NUMBER;
   high_val NUMBER;
BEGIN
   -- If the p_highval_lookup is NULL then no processing
   -- is needed
   IF p_highval_lookup IS NOT NULL THEN
      IF (p_char_type =2) THEN

        -- Fetching the high values using the limits of the spec selected
        -- or the specs defined on the collection element.
        -- If the spec_id is not null which means that a user defined
        -- spec has been selected then the API performs the UOM conversions
        -- as well
        qa_plan_element_api.get_low_high_values(
           p_plan_id, p_spec_id, p_char_id,
           p_lowval_lookup, p_highval_lookup,
           low_val, high_val);

        -- If the low and high values are based on the spec limits defined
        -- on the collection element level and the element is not of the same
        -- UOM as that of the collection plan then the UOM conversion needs to
        -- be done.
        IF (p_char_uom <> p_plan_uom and
            P_spec_id  = 0) THEN
           high_val := qa_plan_element_api.perform_uom_conversion(
                           p_source_val => high_val ,
                           p_precision  => p_precision,
                           p_source_UOM => p_char_uom,
                           p_target_UOM => p_plan_uom);
        END IF;
      ELSE
           -- If the low value is not numeric then it is returned as is
           -- need to check what format to return for dates.
           high_val := p_highval_lookup;
      END IF;

      RETURN TO_CHAR(high_val);
   ELSE
      RETURN NULL;
   END IF;
END high_val;



END QLTDACTB;


/
