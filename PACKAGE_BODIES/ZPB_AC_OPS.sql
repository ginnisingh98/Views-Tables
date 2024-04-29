--------------------------------------------------------
--  DDL for Package Body ZPB_AC_OPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_AC_OPS" AS
/* $Header: zpbac.plb 120.30 2008/01/25 06:49:55 maniskum ship $  */

G_PKG_NAME CONSTANT VARCHAR2(15) := 'zpb_ac_ops';

/*
 * Internal procedures
 */

 -- ABUDNIK B4558985 09Oct2005
 --ABUDNIK B5046249  17Apr2006
 procedure CLEAN_ACTIVE_INSTANCE(p_acid in number)
 is

  l_wfprocess varchar2(30);
  l_instanceID number;
  l_item_key  varchar2(240);
  l_itemtype  varchar2(8);
  l_ownerID   number;
  l_reqID     number;
  l_count     number;
  currStatus   varchar2(20);
  result     varchar2(100);
  l_business_area_id number;

--Cursor modified for missing objects
 CURSOR c_active_instance IS
    SELECT zaci.instance_ac_id, zac.current_instance_id, t.wf_process_name, t.item_key, t.task_id
    FROM  ZPB_ANALYSIS_CYCLE_INSTANCES zaci,
        ZPB_ANALYSIS_CYCLES zac,
       zpb_analysis_cycle_tasks t,
       ZPB_ANALYSIS_CYCLES publishedac
    WHERE publishedac.analysis_cycle_id = p_acid and
        publishedac.current_instance_id=zac.current_instance_id and
        zaci.instance_ac_id = zac.analysis_cycle_id and
        zac.status_code NOT in('COMPLETE', 'COMPLETE_WITH_WARNING', 'ERROR')
        AND zaci.instance_ac_id = t.ANALYSIS_CYCLE_ID
        and t.staTus_code = 'ACTIVE';

  v_active_instance c_active_instance%ROWTYPE;


 zpb_reqID_err EXCEPTION;

 begin


 -- abudnik 07DEC2005 BUSINESS AREA ID to call for ZPB_WF_DELAWINST
 select BUSINESS_AREA_ID
     into l_business_area_id
     from ZPB_ANALYSIS_CYCLES
     where ANALYSIS_CYCLE_ID = p_acid;


 for v_active_instance in c_active_instance loop

    l_wfprocess :=v_active_instance.wf_process_name;
    l_instanceID :=  v_active_instance.instance_ac_id;
    l_item_key := v_active_instance.item_key;

    if l_wfprocess in ('EXCEPTION', 'GENERATE_TEMPLATE', 'MANAGE_SUBMISSION', 'REVIEW_FWK', 'WAIT_TASK') then

        select count(*) into l_count
           from wf_items_v
            where item_key = l_item_key;

        if l_count = 1 then
             -- get this owner
            l_ownerID := wf_engine.GetItemAttrNumber(Itemtype => 'EPBCYCLE',
                        Itemkey => l_Item_Key,
                        aname => 'OWNERID');

             -- bug 5046249: a tempoary suppression of the error becuase this is just aborting and not purging
            -- if this rasies an error here this WF is corrupt and not running anyway.
            -- clean_active_instance should be redesigned to be a conc request so we can report these.
            -- Examples pf types of errors suppressed for this:
            -- ORA-20002: 3116: Actvity 'MANAGE_SUBMISSION' for item 'EPBCYCLE/Test run pqr' is not a runnable process.
            -- ORA-20002: 3106: Root process 'MANAGE_SUBMISSION' for item 'EPBCYCLE/Test run xyz' does not exist.
            -- ORA-20002: 3124: Process 'MANAGE_SUBMISSION' for item 'EPBCYCLE/Test run abc' is not active.

            BEGIN

            -- abort this WF if it is active or in error
            wf_engine.ItemStatus('EPBCYCLE', l_item_key, currStatus, result);
            if UPPER(RTRIM(currStatus)) = 'ERROR' or UPPER(RTRIM(currStatus)) = 'ACTIVE' then
                WF_ENGINE.AbortProcess('EPBCYCLE', l_item_key);
            end if;

            exception
               WHEN OTHERS THEN
                 if instr(sqlerrm, 'ORA-20002') > 0 then
                    Null;
                 else
                    raise;
                 end if;
             end;


            -- submit the ZPB AW DELETE
            -- abudnik 07DEC2005 BUSINESS AREA ID to call for ZPB_WF_DELAWINST
            l_REQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WF_DELAWINST', NULL, NULL, FALSE, l_instanceID, l_ownerid, l_business_area_id);

                        -- now that the instance has been cleaned, set its last task to completed
                       -- in order to allow cleaning of the current instance of the BP
                        update zpb_analysis_cycle_tasks
                        set status_code='COMPLETE'
                        where task_id = v_active_instance.task_id;

            if l_REQID <= 0 then
               RAISE zpb_reqID_err;
            end if;
            -- dbms_output.put_line(' l_reqid= ' || l_reqId);

          end if;
     end if;

  end loop;
  return;


  exception

    WHEN zpb_reqID_err THEN
        zpb_log.write_event(G_PKG_NAME||'.clean_active_instance',  ' - l_REQID= ' || l_REQID ||': l_instanceID= '|| l_instanceID ||':'|| substr(sqlerrm,1,90));
        raise;

    wHEN others then
       raise;

 end CLEAN_ACTIVE_INSTANCE;



  PROCEDURE copy_ac_table_rec (
   source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
   target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
 IS
 BEGIN

   --if the calling procedure is publish_cycle, then
   --transfer the ownership to the Current User
   INSERT INTO zpb_analysis_cycles
        (ANALYSIS_CYCLE_ID,
        STATUS_CODE,
        NAME,
        DESCRIPTION,
        LOCKED_BY,
        VALIDATE_STATUS,
        CURRENT_INSTANCE_ID,
        PUBLISHED_DATE,
        PUBLISHED_BY,
        PREV_STATUS_CODE,
        OWNER_ID,
        BUSINESS_AREA_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
   SELECT target_ac_id_in,
        STATUS_CODE,
        NAME,
        DESCRIPTION,
        LOCKED_BY,
        VALIDATE_STATUS,
        CURRENT_INSTANCE_ID,
        PUBLISHED_DATE,
        PUBLISHED_BY,
        PREV_STATUS_CODE,
        OWNER_ID,
        BUSINESS_AREA_ID,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.LOGIN_ID
    FROM zpb_analysis_cycles
    WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;

 END copy_ac_table_rec;


PROCEDURE copy_ac_param_values_recs (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
BEGIN
    INSERT INTO zpb_ac_param_values
        (ANALYSIS_CYCLE_ID,
        PARAM_ID,
        VALUE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    SELECT target_ac_id_in,
        PARAM_ID,
        VALUE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.LOGIN_ID
    FROM zpb_ac_param_values
    WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;
END copy_ac_param_values_recs;

PROCEDURE copy_cycle_currency_recs (
  source_ac_id_in       IN zpb_cycle_currencies.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_cycle_currencies.analysis_cycle_id%TYPE)
IS
BEGIN
    INSERT INTO zpb_cycle_currencies
        (ANALYSIS_CYCLE_ID,
         CURRENCY_CODE,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN)
    SELECT      target_ac_id_in,
        CURRENCY_CODE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.LOGIN_ID
    FROM  zpb_cycle_currencies
    WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;

END copy_cycle_currency_recs;

PROCEDURE copy_external_user_recs (
  source_ac_id_in       IN zpb_bp_external_users.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_bp_external_users.analysis_cycle_id%TYPE)
IS
BEGIN
    INSERT INTO zpb_bp_external_users
        (ANALYSIS_CYCLE_ID,
        USER_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    SELECT      target_ac_id_in,
        USER_ID,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.LOGIN_ID
    FROM zpb_bp_external_users
    WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;

END copy_external_user_recs;

PROCEDURE copy_cycle_datasets_recs (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
BEGIN
    INSERT INTO zpb_cycle_datasets
        (ANALYSIS_CYCLE_ID,
        DATASET_CODE,
        ORDER_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    SELECT      target_ac_id_in,
        DATASET_CODE,
        ORDER_ID,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.LOGIN_ID
    FROM zpb_cycle_datasets
    WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;

END copy_cycle_datasets_recs;



PROCEDURE copy_cycle_model_dim_recs (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
BEGIN
     INSERT INTO zpb_cycle_model_dimensions
        (ANALYSIS_CYCLE_ID,
        DIMENSION_NAME,
        QUERY_OBJECT_NAME,
        QUERY_OBJECT_PATH,
        DATASET_DIMENSION_FLAG,
        REMOVE_DIMENSION_FLAG,
        SUM_MEMBERS_NUMBER,
        SUM_SELECTION_NAME,
        SUM_SELECTION_PATH,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY)
    SELECT      target_ac_id_in,
        DIMENSION_NAME,
        QUERY_OBJECT_NAME,
        QUERY_OBJECT_PATH,
        DATASET_DIMENSION_FLAG,
        REMOVE_DIMENSION_FLAG,
        SUM_MEMBERS_NUMBER,
        SUM_SELECTION_NAME,
        SUM_SELECTION_PATH,
        fnd_global.LOGIN_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID
    FROM zpb_cycle_model_dimensions
    WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;

END copy_cycle_model_dim_recs;

-- Bug 4587184: Add source_task_id and target_task_id to the signature
PROCEDURE copy_bp_measure_scope_recs (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE ,
  source_task_id        IN zpb_measure_scope_exempt_users.task_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE ,
  target_task_id        IN zpb_measure_scope_exempt_users.task_id%TYPE)
IS
BEGIN

    -- Bug 4587184: Modified the query to consider the task id
    INSERT INTO zpb_measure_scope_exempt_users
        (BUSINESS_PROCESS_ENTITY_ID,
                USER_ID,
                EXEMPTION_ID,
                TASK_ID,
                BUSINESS_PROCESS_ENTITY_TYPE,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN)
        SELECT  target_ac_id_in,
                USER_ID,
                EXEMPTION_ID,
                target_task_id,
                BUSINESS_PROCESS_ENTITY_TYPE,
                fnd_global.USER_ID,
                SYSDATE,
                fnd_global.USER_ID,
                SYSDATE,
                fnd_global.LOGIN_ID
        FROM   zpb_measure_scope_exempt_users
        WHERE BUSINESS_PROCESS_ENTITY_ID = source_ac_id_in
        AND BUSINESS_PROCESS_ENTITY_TYPE = 'A'
        AND TASK_ID = source_task_id;

END copy_bp_measure_scope_recs;

-- Bug 4587184: Add source_task_id and target_task_id to the signature
PROCEDURE copy_bp_scope_access_recs (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  source_task_id        IN zpb_business_process_scope.task_id%TYPE   ,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_task_id        IN zpb_business_process_scope.task_id%TYPE   )
IS

BEGIN
      -- Bug 4587184: Consider task_id in the query
      INSERT INTO zpb_business_process_scope
        (ANALYSIS_CYCLE_ID,
                TASK_ID,
                RESTRICTION_TYPE,
                START_TIME_TYPE,
                START_TIME_MEMBER_ID,
                START_RELATIVE_TYPE_CODE,
                START_PERIODS,
                START_TIME_LEVEL_ID,
                END_TIME_TYPE,
                END_TIME_MEMBER_ID,
                END_RELATIVE_TYPE_CODE,
                END_PERIODS,
                END_TIME_LEVEL_ID,
                TIME_HIERARCHY_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN)
        SELECT  target_ac_id_in,
                target_task_id,
                RESTRICTION_TYPE,
                START_TIME_TYPE,
                START_TIME_MEMBER_ID,
                START_RELATIVE_TYPE_CODE,
                START_PERIODS,
                START_TIME_LEVEL_ID,
                END_TIME_TYPE,
                END_TIME_MEMBER_ID,
                END_RELATIVE_TYPE_CODE,
                END_PERIODS,
                END_TIME_LEVEL_ID,
                TIME_HIERARCHY_ID,
                fnd_global.USER_ID,
                SYSDATE,
                fnd_global.USER_ID,
                SYSDATE,
                fnd_global.LOGIN_ID
        FROM zpb_business_process_scope
        WHERE ANALYSIS_CYCLE_ID = source_ac_id_in
        AND   TASK_ID = source_task_id;

END copy_bp_scope_access_recs;

PROCEDURE copy_cycle_comments_recs (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
BEGIN
    INSERT INTO zpb_cycle_comments
        (COMMENT_ID,
        ANALYSIS_CYCLE_ID,
        COMMENTS,
        OWNER_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    SELECT zpb_cycle_comments_id_seq.NEXTVAL,
        target_ac_id_in,
        COMMENTS,
        OWNER_ID,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.LOGIN_ID
    FROM zpb_cycle_comments
    WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;

END copy_cycle_comments_recs;


PROCEDURE copy_task_param_recs (
  source_task_id_in     IN zpb_analysis_cycle_tasks.task_id%TYPE,
  target_task_id_in     IN zpb_analysis_cycle_tasks.task_id%TYPE)
IS
BEGIN
    INSERT INTO zpb_task_parameters
        ( NAME,
        TASK_ID,
        VALUE,
        PARAM_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    SELECT  NAME,
        target_task_id_in,
        decode(name, 'OWNER_ID', to_char( fnd_global.USER_ID ),VALUE),
        zpb_task_param_id_seq.NEXTVAL,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.LOGIN_ID
    FROM zpb_task_parameters
    WHERE TASK_ID = source_task_id_in;

exception
   WHEN OTHERS THEN
     ZPB_ERROR_HANDLER.RAISE_EXCEPTION (G_PKG_NAME, 'copy_task_param_recs');

END copy_task_param_recs;


PROCEDURE copy_ac_task_recs (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  is_anal_excep_copied  IN boolean default true)
IS
CURSOR ac_task_cur IS
SELECT *
  FROM zpb_analysis_cycle_tasks
 WHERE analysis_cycle_id = source_ac_id_in;

cursor analy_excep_cur(l_taskId number) is
select 1 FROM zpb_task_parameters where name = 'EXCEPTION_TYPE'
and value = 'A' and task_id = l_taskId;

target_task_id zpb_analysis_cycle_tasks.task_id%TYPE;
source_task_id zpb_analysis_cycle_tasks.task_id%TYPE;

excep_count number;
copy_task boolean :=true;
BEGIN
  FOR ac_task_rec IN ac_task_cur LOOP
    if (ac_task_rec.WF_PROCESS_NAME = 'EXCEPTION' and is_anal_excep_copied = false)
    then
      open analy_excep_cur(ac_task_rec.task_id);
      fetch analy_excep_cur  into excep_count;
      if analy_excep_cur%FOUND
      then
        copy_task := false;
      end if;
      close analy_excep_cur;
    else
      copy_task := true;
    end if;
    if copy_task = true
    then
      SELECT zpb_task_id_seq.NEXTVAL INTO target_task_id FROM DUAL;
      source_task_id := ac_task_rec.task_id;
      ac_task_rec.analysis_cycle_id := target_ac_id_in;
      ac_task_rec.task_id := target_task_id;
      ac_task_rec.CREATED_BY           := fnd_global.USER_ID;
      ac_task_rec.CREATION_DATE        := SYSDATE;
      ac_task_rec.LAST_UPDATED_BY      := fnd_global.USER_ID;
      ac_task_rec.LAST_UPDATE_DATE     := SYSDATE;
      ac_task_rec.LAST_UPDATE_LOGIN    := fnd_global.LOGIN_ID;
      INSERT INTO zpb_analysis_cycle_tasks(ANALYSIS_CYCLE_ID,
                     TASK_ID,
                     SEQUENCE,
                     TASK_NAME,
                     STATUS_CODE,
                     ITEM_TYPE,
                     WF_PROCESS_NAME,
                     ITEM_KEY,
                     START_DATE,
                     HIDE_SHOW,
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_DATE,
                     LAST_UPDATE_LOGIN,
                     OWNER_ID)
             VALUES (ac_task_rec.ANALYSIS_CYCLE_ID,
                     ac_task_rec.TASK_ID,
                     ac_task_rec.SEQUENCE,
                     ac_task_rec.TASK_NAME,
                     ac_task_rec.STATUS_CODE,
                     ac_task_rec.ITEM_TYPE,
                     ac_task_rec.WF_PROCESS_NAME,
                     ac_task_rec.ITEM_KEY,
                     ac_task_rec.START_DATE,
                     ac_task_rec.HIDE_SHOW,
                     ac_task_rec.CREATION_DATE,
                     ac_task_rec.CREATED_BY,
                     ac_task_rec.LAST_UPDATED_BY,
                     ac_task_rec.LAST_UPDATE_DATE,
                     ac_task_rec.LAST_UPDATE_LOGIN,
                     fnd_global.USER_ID);
      copy_task_param_recs(source_task_id, target_task_id);

      -- Bug 4587184: Add the following condition to copy the tasks
      IF (ac_task_rec.WF_PROCESS_NAME = 'SET_VIEW_RESTRICTION') THEN
        copy_bp_scope_access_recs
        ( source_ac_id_in
        , source_task_id
        , target_ac_id_in
        , target_task_id);

        copy_bp_measure_scope_recs
        ( source_ac_id_in
        , source_task_id
        , target_ac_id_in
        , target_task_id);
      END IF;

    end if;
  END LOOP;
EXCEPTION
  when others then
  if analy_excep_cur%isopen
  then
    close analy_excep_cur;
  end if;
  ZPB_ERROR_HANDLER.RAISE_EXCEPTION(G_PKG_NAME, 'copy_ac_task_recs');

END copy_ac_task_recs;

PROCEDURE copy_solve_member_defs_recs  (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
BEGIN

    INSERT INTO zpb_solve_member_defs
        (ANALYSIS_CYCLE_ID,
        MEMBER,
        SOURCE_TYPE,
        MEMBER_ORDER,
        CALCSTEP_PATH,
        CALC_DESCRIPTION,
        CALC_TYPE,
        CALC_PARAMETERS,
        MODEL_EQUATION,
        PROPAGATE_TARGET,
        DATA_SOURCE,
        CURRENT_MODIFIED,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    SELECT      target_ac_id_in,
        MEMBER,
        SOURCE_TYPE,
        MEMBER_ORDER,
        CALCSTEP_PATH,
        CALC_DESCRIPTION,
        CALC_TYPE,
        CALC_PARAMETERS,
        MODEL_EQUATION,
        PROPAGATE_TARGET,
        DATA_SOURCE,
        CURRENT_MODIFIED,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.LOGIN_ID
    FROM zpb_solve_member_defs
    WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;
END copy_solve_member_defs_recs;


PROCEDURE copy_copy_dim_members_recs (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
BEGIN

    INSERT INTO zpb_copy_dim_members
        (DIM,
        ANALYSIS_CYCLE_ID,
        SOURCE_NUM_MEMBERS,
        TARGET_NUM_MEMBERS,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SAME_SELECTION,
        LINE_MEMBER_ID)
    SELECT DIM,
        target_ac_id_in,
        SOURCE_NUM_MEMBERS,
        TARGET_NUM_MEMBERS,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.LOGIN_ID,
        SAME_SELECTION,
        LINE_MEMBER_ID
    FROM zpb_copy_dim_members
    WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;

END copy_copy_dim_members_recs;

PROCEDURE copy_data_init_defs_recs  (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
BEGIN

    /* Bug#5092815, Added propagated_flag */

    INSERT INTO zpb_data_initialization_defs
        (ANALYSIS_CYCLE_ID,
        MEMBER,
        SOURCE_VIEW,
        LAG_TIME_PERIODS,
        LAG_TIME_LEVEL,
        CHANGE_NUMBER,
        PERCENTAGE_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        QUERY_PATH,
        SOURCE_QUERY_NAME,
        TARGET_QUERY_NAME,
        PROPAGATED_FLAG)
    SELECT      target_ac_id_in,
        MEMBER,
        SOURCE_VIEW,
        LAG_TIME_PERIODS,
        LAG_TIME_LEVEL,
        CHANGE_NUMBER,
        PERCENTAGE_FLAG,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.LOGIN_ID,
        QUERY_PATH,
        SOURCE_QUERY_NAME,
        TARGET_QUERY_NAME,
        PROPAGATED_FLAG
    FROM zpb_data_initialization_defs
    WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;

END copy_data_init_defs_recs;


PROCEDURE copy_solve_input_level_recs  (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
BEGIN
    INSERT INTO zpb_solve_input_selections
        (ANALYSIS_CYCLE_ID,
        MEMBER,
        MEMBER_ORDER,
        DIMENSION,
        HIERARCHY,
        SELECTION_NAME,
        PROPAGATED_FLAG,
        SELECTION_PATH,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    SELECT      target_ac_id_in,
        MEMBER,
        MEMBER_ORDER,
        DIMENSION,
        HIERARCHY,
        SELECTION_NAME,
        PROPAGATED_FLAG,
        SELECTION_PATH,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.LOGIN_ID
    FROM zpb_solve_input_selections
    WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;

END copy_solve_input_level_recs;


PROCEDURE copy_solve_output_level_recs  (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
BEGIN

    INSERT INTO zpb_solve_output_selections
        (ANALYSIS_CYCLE_ID,
                MEMBER,
                MEMBER_ORDER,
                DIMENSION,
                HIERARCHY,
                SELECTION_NAME,
                PROPAGATED_FLAG,
                MATCH_INPUT_FLAG,
                SELECTION_PATH,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN)
        SELECT  target_ac_id_in,
                MEMBER,
                MEMBER_ORDER,
                DIMENSION,
                HIERARCHY,
                SELECTION_NAME,
                PROPAGATED_FLAG,
                MATCH_INPUT_FLAG,
                SELECTION_PATH,
                fnd_global.USER_ID,
                SYSDATE,
                fnd_global.USER_ID,
                SYSDATE,
                fnd_global.LOGIN_ID
        FROM zpb_solve_output_selections
        WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;

END copy_solve_output_level_recs;


PROCEDURE copy_solve_alloc_defs_recs  (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
BEGIN

    INSERT INTO zpb_solve_allocation_defs
        (ANALYSIS_CYCLE_ID,
                MEMBER,
                MEMBER_ORDER,
                RULE_NAME,
                METHOD,
                BASIS,
                QUALIFIER,
                EVALUATION_OPTION,
                ROUND_DECIMALS,
                ROUND_ENABLED,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN)
        SELECT  target_ac_id_in,
                MEMBER,
                MEMBER_ORDER,
                RULE_NAME,
                METHOD,
                BASIS,
                QUALIFIER,
                EVALUATION_OPTION,
                ROUND_DECIMALS,
                ROUND_ENABLED,
                fnd_global.USER_ID,
                SYSDATE,
                fnd_global.USER_ID,
                SYSDATE,
                fnd_global.LOGIN_ID
        FROM  zpb_solve_allocation_defs
        WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;


END copy_solve_alloc_defs_recs;

PROCEDURE copy_line_dimensionality_recs  (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
BEGIN

    INSERT INTO zpb_line_dimensionality
        (ANALYSIS_CYCLE_ID,
        MEMBER,
        MEMBER_ORDER,
        DIMENSION,
        SUM_MEMBERS_NUMBER,
        SUM_MEMBERS_FLAG,
        EXCLUDE_FROM_SOLVE_FLAG,
        FORCE_INPUT_FLAG,
        SUM_SELECTION_NAME,
        PROPAGATED_FLAG,
        SUM_SELECTION_PATH,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    SELECT      target_ac_id_in,
        MEMBER,
        MEMBER_ORDER,
        DIMENSION,
        SUM_MEMBERS_NUMBER,
        SUM_MEMBERS_FLAG,
        EXCLUDE_FROM_SOLVE_FLAG,
        FORCE_INPUT_FLAG,
        SUM_SELECTION_NAME,
        PROPAGATED_FLAG,
        SUM_SELECTION_PATH,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.USER_ID,
        SYSDATE,
        fnd_global.LOGIN_ID
    FROM zpb_line_dimensionality
    WHERE ANALYSIS_CYCLE_ID = source_ac_id_in;

END copy_line_dimensionality_recs;

PROCEDURE copy_solve_hier_order_recs (
  source_ac_id_in  IN  zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in  IN  zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
BEGIN
  INSERT INTO zpb_solve_hier_order
         (solve_hier_order_id,
         analysis_cycle_id,
         dimension,
         hierarchy,
         hierarchy_order,
         first_last_flag,
         object_version_number,
         creation_date,
         created_by,
         last_updated_by,
         last_update_date,
         last_update_login
         )
  SELECT zpb_solve_hier_order_s.NEXTVAL,
         target_ac_id_in,
         dimension,
         hierarchy,
         hierarchy_order,
         first_last_flag,
         object_version_number,
         sysdate,
         fnd_global.user_id,
         fnd_global.user_id,
         sysdate,
         fnd_global.login_id
  FROM zpb_solve_hier_order
  WHERE analysis_cycle_id = source_ac_id_in;

END copy_solve_hier_order_recs;

PROCEDURE create_ac_copy (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  is_comments_copied    IN boolean default true,
  is_anal_excep_copied  IN boolean default true)
IS
BEGIN
  copy_ac_table_rec(source_ac_id_in, target_ac_id_in);
  copy_ac_param_values_recs(source_ac_id_in, target_ac_id_in);
  copy_cycle_currency_recs(source_ac_id_in, target_ac_id_in);
  copy_external_user_recs(source_ac_id_in, target_ac_id_in);
  copy_cycle_datasets_recs(source_ac_id_in, target_ac_id_in);
  copy_ac_task_recs(source_ac_id_in, target_ac_id_in,is_anal_excep_copied);
  copy_cycle_model_dim_recs(source_ac_id_in, target_ac_id_in);
  if is_comments_copied = true then
    copy_cycle_comments_recs(source_ac_id_in, target_ac_id_in);
  end if;
  copy_solve_member_defs_recs(source_ac_id_in, target_ac_id_in);
  copy_copy_dim_members_recs(source_ac_id_in, target_ac_id_in);
  copy_data_init_defs_recs(source_ac_id_in, target_ac_id_in);
  copy_solve_input_level_recs(source_ac_id_in, target_ac_id_in);
  copy_solve_output_level_recs(source_ac_id_in, target_ac_id_in);
  copy_solve_alloc_defs_recs(source_ac_id_in, target_ac_id_in);
  copy_line_dimensionality_recs(source_ac_id_in, target_ac_id_in);
  -- Bug 4587184: Remove the following calls, because they are invoked from
  -- copy_ac_task_recs now.
  -- copy_bp_scope_access_recs(source_ac_id_in, target_ac_id_in);
  -- copy_bp_measure_scope_recs(source_ac_id_in, target_ac_id_in);
  copy_solve_hier_order_recs(source_ac_id_in, target_ac_id_in);
END create_ac_copy;



/*
 * This internal procedure copes only those tasks that have not yet started in
 * instance target_ac_id_in.  This is used when republishing a cycle
 */
PROCEDURE copy_nonstarted_tasks (
  source_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  target_ac_id_in       IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS

-- cursor ac_task_cur contains all tasks from source_ac_id_in whose
-- corresponding tasks in target_ac_id_in have not yet started
CURSOR ac_task_cur IS
SELECT *
  FROM zpb_analysis_cycle_tasks
 WHERE analysis_cycle_id = source_ac_id_in and
       sequence >=

((SELECT min(sequence)
  FROM zpb_analysis_cycle_tasks
 WHERE analysis_cycle_id = target_ac_id_in and
       status_code is null));

  target_task_id zpb_analysis_cycle_tasks.task_id%TYPE;
  source_task_id zpb_analysis_cycle_tasks.task_id%TYPE;
  todelete_task_id zpb_analysis_cycle_tasks.task_id%TYPE;

BEGIN

  -- loop over all tasks that need to be updated
  FOR ac_task_rec IN ac_task_cur LOOP
     begin

        -- First delete task from target_ac_id_in
        -- For newly created tasks in the source, no deletion is necessary
        SELECT task_id into  todelete_task_id
        FROM   zpb_analysis_cycle_tasks
        WHERE  analysis_cycle_id = target_ac_id_in and
               sequence = ac_task_rec.sequence;

        exception
                when no_data_found then
                todelete_task_id := null;
     end;

   DELETE FROM zpb_task_parameters
          WHERE task_id = todelete_task_id;

   DELETE FROM zpb_analysis_cycle_tasks
          WHERE task_id = todelete_task_id;

    SELECT zpb_task_id_seq.NEXTVAL INTO target_task_id FROM DUAL;
    source_task_id := ac_task_rec.task_id;
    ac_task_rec.analysis_cycle_id := target_ac_id_in;
    ac_task_rec.task_id := target_task_id;
    ac_task_rec.CREATED_BY           := fnd_global.USER_ID;
    ac_task_rec.CREATION_DATE        := SYSDATE;
    ac_task_rec.LAST_UPDATED_BY      := fnd_global.USER_ID;
    ac_task_rec.LAST_UPDATE_DATE     := SYSDATE;
    ac_task_rec.LAST_UPDATE_LOGIN    := fnd_global.LOGIN_ID;
    INSERT INTO zpb_analysis_cycle_tasks(ANALYSIS_CYCLE_ID,
                    TASK_ID,
                    SEQUENCE,
                    TASK_NAME,
                    STATUS_CODE,
                    ITEM_TYPE,
                    WF_PROCESS_NAME,
                    ITEM_KEY,
                    START_DATE,
                    HIDE_SHOW,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATE_LOGIN,
                    OWNER_ID)
         VALUES    (ac_task_rec.ANALYSIS_CYCLE_ID,
                    ac_task_rec.TASK_ID,
                    ac_task_rec.SEQUENCE,
                    ac_task_rec.TASK_NAME,
                    ac_task_rec.STATUS_CODE,
                    ac_task_rec.ITEM_TYPE,
                    ac_task_rec.WF_PROCESS_NAME,
                    ac_task_rec.ITEM_KEY,
                    ac_task_rec.START_DATE,
                    ac_task_rec.HIDE_SHOW,
                    ac_task_rec.CREATION_DATE,
                    ac_task_rec.CREATED_BY,
                    ac_task_rec.LAST_UPDATED_BY,
                    ac_task_rec.LAST_UPDATE_DATE,
                    ac_task_rec.LAST_UPDATE_LOGIN,
                    ac_task_rec.OWNER_ID);

    copy_task_param_recs(source_task_id, target_task_id);

    -- Bug 4587184: Add the following condition to copy the tasks
    IF (ac_task_rec.WF_PROCESS_NAME = 'SET_VIEW_RESTRICTION') THEN
      copy_bp_scope_access_recs
      ( source_ac_id_in
      , source_task_id
      , target_ac_id_in
      , target_task_id);

      copy_bp_measure_scope_recs
      ( source_ac_id_in
      , source_task_id
      , target_ac_id_in
      , target_task_id);
    END IF;

  END LOOP;
END copy_nonstarted_tasks;

--BPEXT
PROCEDURE updateHorizonParams(p_start_mem  IN VARCHAR2
                             ,p_end_mem    IN VARCHAR2
                             ,new_ac_id    IN NUMBER) AS
BEGIN
  IF (p_start_mem IS NOT NULL ) THEN
    UPDATE zpb_ac_param_values SET value = p_start_mem WHERE
    analysis_cycle_id = new_ac_id AND param_id =
    ( SELECT tag FROM fnd_lookup_values_vl WHERE lookup_type = 'ZPB_PARAMS' AND
    lookup_code = 'CAL_HS_TIME_MEMBER');
  END IF;

  IF (p_end_mem IS NOT NULL ) THEN
    UPDATE zpb_ac_param_values SET value = p_end_mem WHERE
    analysis_cycle_id = new_ac_id AND param_id =
    ( SELECT tag FROM fnd_lookup_values_vl WHERE lookup_type = 'ZPB_PARAMS' AND
    lookup_code = 'CAL_HE_TIME_MEMBER');
  END IF;
END updateHorizonParams;
--BPEXT

/*
 * Public  */
PROCEDURE delete_ac (
  ac_id_in                 IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  delete_tasks             IN VARCHAR2 default FND_API.G_TRUE)
IS
CURSOR ac_task_cur IS
SELECT *
  FROM zpb_analysis_cycle_tasks
 WHERE analysis_cycle_id = ac_id_in;

  pet_rec        zpb_cycle_relationships%ROWTYPE;
  delete_task_id zpb_analysis_cycle_tasks.task_id%TYPE;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
BEGIN
  BEGIN
     SELECT *
        INTO pet_rec
        FROM zpb_cycle_relationships
        WHERE published_ac_id = ac_id_in OR
              editable_ac_id  = ac_id_in OR
              tmp_ac_id       = ac_id_in;

     IF pet_rec.published_ac_id = ac_id_in THEN
        UPDATE zpb_cycle_relationships
           SET published_ac_id = NULL,
               LAST_UPDATED_BY  = fnd_global.USER_ID,
               LAST_UPDATE_DATE     = SYSDATE,
               LAST_UPDATE_LOGIN    = fnd_global.LOGIN_ID
         WHERE relationship_id = pet_rec.relationship_id;
      ELSIF pet_rec.editable_ac_id = ac_id_in THEN
        UPDATE zpb_cycle_relationships
           SET editable_ac_id = NULL,
           LAST_UPDATED_BY      = fnd_global.USER_ID,
           LAST_UPDATE_DATE   = SYSDATE,
           LAST_UPDATE_LOGIN  = fnd_global.LOGIN_ID
         WHERE relationship_id = pet_rec.relationship_id;
      ELSIF pet_rec.tmp_ac_id = ac_id_in THEN
        UPDATE zpb_cycle_relationships
           SET tmp_ac_id = NULL,
           LAST_UPDATED_BY      = fnd_global.USER_ID,
           LAST_UPDATE_DATE   = SYSDATE,
           LAST_UPDATE_LOGIN  = fnd_global.LOGIN_ID
        WHERE relationship_id = pet_rec.relationship_id;
     END IF;

     DELETE FROM zpb_cycle_relationships
        WHERE published_ac_id IS NULL AND
              editable_ac_id  IS NULL AND
              tmp_ac_id       IS NULL;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        NULL;
  END;

  IF FND_API.To_Boolean(delete_tasks)  THEN

          FOR ac_task_rec IN ac_task_cur LOOP
            DELETE FROM zpb_task_parameters
                  WHERE task_id = ac_task_rec.task_id;
          END LOOP;

          DELETE FROM zpb_analysis_cycle_tasks
                WHERE analysis_cycle_id = ac_id_in;
  END IF;

  DELETE FROM zpb_business_process_scope
        WHERE analysis_cycle_id = ac_id_in;

  DELETE FROM zpb_copy_dim_members
        WHERE analysis_cycle_id = ac_id_in;

  DELETE FROM zpb_measure_scope_exempt_users
        WHERE BUSINESS_PROCESS_ENTITY_ID = ac_id_in
          AND BUSINESS_PROCESS_ENTITY_TYPE = 'A';

  DELETE FROM zpb_cycle_comments
        WHERE analysis_cycle_id = ac_id_in;

  DELETE FROM zpb_cycle_model_dimensions
        WHERE analysis_cycle_id = ac_id_in;

  DELETE FROM zpb_ac_param_values
        WHERE analysis_cycle_id = ac_id_in;

  DELETE FROM zpb_cycle_datasets
        WHERE analysis_cycle_id = ac_id_in;

  DELETE FROM zpb_analysis_cycles
        WHERE analysis_cycle_id = ac_id_in;

  DELETE FROM zpb_solve_member_defs
        WHERE analysis_cycle_id = ac_id_in;

  DELETE FROM zpb_data_initialization_defs
        WHERE analysis_cycle_id = ac_id_in;

  DELETE FROM zpb_solve_input_levels
        WHERE analysis_cycle_id = ac_id_in;

  DELETE FROM zpb_solve_output_levels
        WHERE analysis_cycle_id = ac_id_in;

  DELETE FROM zpb_solve_allocation_defs
        WHERE analysis_cycle_id = ac_id_in;

 DELETE FROM zpb_solve_output_selections
        WHERE analysis_cycle_id = ac_id_in;

 DELETE FROM zpb_solve_input_selections
        WHERE analysis_cycle_id = ac_id_in;

 DELETE FROM zpb_line_dimensionality
        WHERE analysis_cycle_id = ac_id_in;

 DELETE FROM zpb_cycle_currencies
            WHERE analysis_cycle_id = ac_id_in;

 DELETE FROM zpb_bp_external_users
            WHERE analysis_cycle_id = ac_id_in;

 DELETE FROM ZPB_BP_VALIDATION_RESULTS
            WHERE BUS_PROC_ID = ac_id_in;

  DELETE FROM zpb_solve_hier_order
         WHERE analysis_cycle_id = ac_id_in;

END delete_ac;

/* Haven't found a place where this api is called, but this
api has cursor previous_instance_cur that does not confirm to
missing obj changes */

PROCEDURE delete_published_ac (
  ac_id_in                 IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  prev_instance_options_in IN VARCHAR2,
  curr_instance_options_in IN VARCHAR2)
IS
  CURSOR previous_instance_cur IS
  SELECT zaci.instance_ac_id
    FROM zpb_analysis_cycle_instances zaci,
         zpb_analysis_cycles zac
   WHERE zaci.analysis_cycle_id = ac_id_in and
         zac.analysis_cycle_id = zaci.analysis_cycle_id and
         zaci.instance_ac_id <> zac.current_instance_id;

  curr_instance_ac_id   zpb_analysis_cycles.analysis_cycle_id%TYPE;
  l_count               NUMBER;
BEGIN

  IF prev_instance_options_in = 'DELETE_PREVIOUS_INSTANCE' THEN
    FOR instance_rec IN previous_instance_cur LOOP
      DELETE FROM zpb_analysis_cycle_instances
       WHERE instance_ac_id = instance_rec.instance_ac_id;

     delete_ac(instance_rec.instance_ac_id);
    END LOOP;
  END IF;

  IF curr_instance_options_in = 'DELETE_CURR_INSTANCE' THEN
      SELECT current_instance_id
        INTO curr_instance_ac_id
        FROM zpb_analysis_cycles
       WHERE analysis_cycle_id = ac_id_in;

      --DELETE FROM zpb_current_instances
      -- WHERE current_instance_ac_id = curr_instance_ac_id;

      DELETE FROM zpb_analysis_cycle_instances
       WHERE instance_ac_id = curr_instance_ac_id;

      delete_ac(curr_instance_ac_id);

  END IF;

/*
 * The instances can no longer refer to their definition
 * AC_ID because it has been deleted from the tables.
 */
  UPDATE zpb_analysis_cycle_instances
     SET analysis_cycle_id = NULL,
     LAST_UPDATED_BY    = fnd_global.USER_ID,
     LAST_UPDATE_DATE   = SYSDATE,
     LAST_UPDATE_LOGIN  = fnd_global.LOGIN_ID
   WHERE analysis_cycle_id = ac_id_in;

  delete_ac(ac_id_in);

END delete_published_ac;

PROCEDURE getEditableCopyID (
published_ac_id_in  IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
editable_ac_id_out  OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
 return_ac_id      zpb_analysis_cycles.analysis_cycle_id%TYPE;
BEGIN

SELECT  editable_ac_id
INTO    return_ac_id
FROM    zpb_cycle_relationships
WHERE   published_ac_id = published_ac_id_in;

editable_ac_id_out := return_ac_id;

END getEditableCopyID;

PROCEDURE recoverCycleObjects (
editable_ac_id_in  IN  zpb_analysis_cycles.analysis_cycle_id%TYPE,
is_published_out   OUT NOCOPY VARCHAR2)
IS
 published_ac_id  zpb_analysis_cycles.analysis_cycle_id%TYPE;
BEGIN

  is_published_out := 'N';
  getPubIdFromEditId(editable_ac_id_in, published_ac_id);

  if published_ac_id is not null then
    delete_ac(editable_ac_id_in);
    is_published_out := 'Y';
  end if;

END recoverCycleObjects;

PROCEDURE getPubIdFromEditId (
editable_ac_id_in  IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
published_ac_id_out  OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
 return_ac_id      zpb_analysis_cycles.analysis_cycle_id%TYPE;
BEGIN

SELECT  published_ac_id
INTO    return_ac_id
FROM    zpb_cycle_relationships
WHERE   editable_ac_id = editable_ac_id_in;

published_ac_id_out := return_ac_id;

END getPubIdFromEditId;

/* This procedure copies the defintion of an existing Business Process
   to a new business process.
*/
procedure create_duplicate_copy (
  published_ac_id_in    IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  editable_ac_name_in   IN zpb_analysis_cycles.name%TYPE,
  last_updated_by_in    IN zpb_analysis_cycles.last_updated_by%TYPE,
  ac_business_area_in   IN zpb_analysis_cycles.business_area_id%TYPE,
  is_comments_copied    IN VARCHAR2 default 'true',
  is_analy_excep_copied IN VARCHAR2 default 'true',
  editable_ac_id_out    OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE)

IS
  new_ac_id        zpb_analysis_cycles.analysis_cycle_id%TYPE;
  current_inst_id  zpb_analysis_cycles.analysis_cycle_id%TYPE;
  relationship_id  zpb_cycle_relationships.relationship_id%TYPE;
  pet_rec          zpb_cycle_relationships%ROWTYPE;
  ac_rec           zpb_analysis_cycles%ROWTYPE;

  comments         boolean := true;
  analy_excep      boolean := true;

BEGIN
  SELECT zpb_analysis_cycle_id_seq.NEXTVAL INTO new_ac_id FROM DUAL;
  SELECT zpb_analysis_cycle_id_seq.NEXTVAL INTO current_inst_id FROM DUAL;
  SELECT zpb_relationship_id_seq.NEXTVAL INTO relationship_id FROM DUAL;

  if lower(is_comments_copied) = 'false' then comments := false; end if;
  if lower(is_analy_excep_copied) = 'false' then analy_excep := false; end if;

  create_ac_copy(published_ac_id_in, new_ac_id,comments,analy_excep);

  -- Bug 5173164: Added current_instance_id, owner_id also
  --              in the below given update statement
  UPDATE zpb_analysis_cycles
     SET name = editable_ac_name_in,
         status_code         = 'DISABLE_ASAP',
         validate_status     = 'INVALID',
         locked_by           = 1,
         published_date      = NULL,
         published_by        = NULL,
         current_instance_id = current_inst_id,
         owner_id            = fnd_global.USER_ID,
         LAST_UPDATED_BY     = fnd_global.USER_ID,
         LAST_UPDATE_DATE    = SYSDATE,
         LAST_UPDATE_LOGIN   = fnd_global.LOGIN_ID
   WHERE analysis_cycle_id   = new_ac_id;

  pet_rec.relationship_id   := relationship_id;
  pet_rec.tmp_ac_id         := new_ac_id;
  pet_rec.CREATED_BY        := fnd_global.USER_ID;
  pet_rec.CREATION_DATE     := SYSDATE;
  pet_rec.LAST_UPDATED_BY   := fnd_global.USER_ID;
  pet_rec.LAST_UPDATE_DATE  := SYSDATE;
  pet_rec.LAST_UPDATE_LOGIN := fnd_global.LOGIN_ID;

  INSERT INTO zpb_cycle_relationships(RELATIONSHIP_ID,
                    PUBLISHED_AC_ID,
                    EDITABLE_AC_ID,
                    TMP_AC_ID,
                    LAST_UPDATE_LOGIN,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY)
  VALUES (pet_rec.RELATIONSHIP_ID,
                    pet_rec.PUBLISHED_AC_ID,
                    pet_rec.EDITABLE_AC_ID,
                    pet_rec.TMP_AC_ID,
                    pet_rec.LAST_UPDATE_LOGIN,
                    pet_rec.LAST_UPDATE_DATE,
                    pet_rec.LAST_UPDATED_BY,
                    pet_rec.CREATION_DATE,
                    pet_rec.CREATED_BY);

  editable_ac_id_out := new_ac_id;

end create_duplicate_copy;

PROCEDURE create_editable_copy (
  published_ac_id_in  IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  editable_ac_name_in IN zpb_analysis_cycles.name%TYPE,
  last_updated_by_in  IN zpb_analysis_cycles.last_updated_by%TYPE,
  editable_ac_id_out  OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
  new_ac_id      zpb_analysis_cycles.analysis_cycle_id%TYPE;
  pet_row_rec    zpb_cycle_relationships%ROWTYPE;
BEGIN
  SELECT *
    INTO pet_row_rec
    FROM zpb_cycle_relationships
   WHERE published_ac_id = published_ac_id_in;

  SELECT zpb_analysis_cycle_id_seq.NEXTVAL INTO new_ac_id FROM DUAL;

  create_ac_copy(published_ac_id_in, new_ac_id);

  UPDATE zpb_analysis_cycles
     SET name = editable_ac_name_in,
         status_code = 'DISABLE_ASAP',
         published_date = NULL,
         published_by   = NULL,
         LAST_UPDATED_BY  = fnd_global.USER_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   WHERE analysis_cycle_id = new_ac_id;

  UPDATE zpb_cycle_relationships
     SET editable_ac_id = new_ac_id,
     LAST_UPDATED_BY    = fnd_global.USER_ID,
     LAST_UPDATE_DATE = SYSDATE,
     LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   WHERE published_ac_id = published_ac_id_in;

  editable_ac_id_out := new_ac_id;

END create_editable_copy;


PROCEDURE create_new_cycle (
  ac_name_in               IN zpb_analysis_cycles.name%TYPE,
  ac_owner_id_in           IN zpb_analysis_cycles.owner_id%TYPE,
  ac_business_area_in      IN zpb_business_areas.business_area_id%TYPE,
  tmp_ac_id_out            OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
  new_ac_id          zpb_analysis_cycles.analysis_cycle_id%TYPE;
  current_inst_id    zpb_analysis_cycles.analysis_cycle_id%TYPE;
  relationship_id             zpb_cycle_relationships.relationship_id%TYPE;
  pet_rec            zpb_cycle_relationships%ROWTYPE;
  ac_rec             zpb_analysis_cycles%ROWTYPE;
BEGIN
  SELECT zpb_analysis_cycle_id_seq.NEXTVAL INTO new_ac_id FROM DUAL;
  SELECT zpb_analysis_cycle_id_seq.NEXTVAL INTO current_inst_id FROM DUAL;
  SELECT zpb_relationship_id_seq.NEXTVAL INTO relationship_id FROM DUAL;

  ac_rec.analysis_cycle_id := new_ac_id;
  ac_rec.name              := ac_name_in;
  ac_rec.validate_status   := 'INVALID';
  ac_rec.status_code       := 'DISABLE_ASAP';
  ac_rec.locked_by         := 1;
  ac_rec.CREATED_BY        := fnd_global.USER_ID;
  ac_rec.CREATION_DATE     := SYSDATE;
  ac_rec.LAST_UPDATED_BY   := fnd_global.USER_ID;
  ac_rec.LAST_UPDATE_DATE  := SYSDATE;
  ac_rec.LAST_UPDATE_LOGIN := fnd_global.LOGIN_ID;
  --ac_rec.PUBLISHED_BY      := sys_context('ZPB_CONTEXT', 'shadow_id');
  ac_rec.OWNER_ID          := ac_owner_id_in;
  ac_rec.BUSINESS_AREA_ID  := ac_business_area_in;
  ac_rec.CURRENT_INSTANCE_ID :=current_inst_id;
  INSERT INTO zpb_analysis_cycles(ANALYSIS_CYCLE_ID,
                    STATUS_CODE,
                    NAME,
                    DESCRIPTION,
                    LOCKED_BY,
                    VALIDATE_STATUS,
                    CURRENT_INSTANCE_ID,
                    PUBLISHED_DATE,
                    PUBLISHED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    PREV_STATUS_CODE,
                    LAST_UPDATE_LOGIN,
                    BUSINESS_AREA_ID,
                    OWNER_ID)
   VALUES   (ac_rec.ANALYSIS_CYCLE_ID,
                    ac_rec.STATUS_CODE,
                    ac_rec.NAME,
                    ac_rec.DESCRIPTION,
                    ac_rec.LOCKED_BY,
                    ac_rec.VALIDATE_STATUS,
                    ac_rec.CURRENT_INSTANCE_ID,
                    ac_rec.PUBLISHED_DATE,
                    ac_rec.PUBLISHED_BY,
                    ac_rec.LAST_UPDATE_DATE,
                    ac_rec.LAST_UPDATED_BY,
                    ac_rec.CREATION_DATE,
                    ac_rec.CREATED_BY,
                    ac_rec.PREV_STATUS_CODE,
                    ac_rec.LAST_UPDATE_LOGIN,
                    ac_rec.BUSINESS_AREA_ID,
                    ac_rec.OWNER_ID);

  pet_rec.relationship_id    := relationship_id;
  pet_rec.tmp_ac_id := new_ac_id;
  pet_rec.CREATED_BY         := fnd_global.USER_ID;
  pet_rec.CREATION_DATE      := SYSDATE;
  pet_rec.LAST_UPDATED_BY    := fnd_global.USER_ID;
  pet_rec.LAST_UPDATE_DATE   := SYSDATE;
  pet_rec.LAST_UPDATE_LOGIN  := fnd_global.LOGIN_ID;
  INSERT INTO zpb_cycle_relationships(RELATIONSHIP_ID,
                    PUBLISHED_AC_ID,
                    EDITABLE_AC_ID,
                    TMP_AC_ID,
                    LAST_UPDATE_LOGIN,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY)
  VALUES (pet_rec.RELATIONSHIP_ID,
                    pet_rec.PUBLISHED_AC_ID,
                    pet_rec.EDITABLE_AC_ID,
                    pet_rec.TMP_AC_ID,
                    pet_rec.LAST_UPDATE_LOGIN,
                    pet_rec.LAST_UPDATE_DATE,
                    pet_rec.LAST_UPDATED_BY,
                    pet_rec.CREATION_DATE,
                    pet_rec.CREATED_BY);
  tmp_ac_id_out := new_ac_id;

END create_new_cycle;


PROCEDURE create_new_instance (
  ac_id_in                 IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  instance_ac_id_out       OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
  new_ac_id          zpb_analysis_cycles.analysis_cycle_id%TYPE;
  ac_rec             zpb_analysis_cycles%ROWTYPE;
  instance_rec       zpb_analysis_cycle_instances%ROWTYPE;
  instance_desc      zpb_analysis_cycle_instances.instance_description%TYPE;
  curr_count         INTEGER;
  curr_count_str     VARCHAR2(5);
  l_app_view_status  zpb_ac_param_values.value%TYPE;
  l_appview_param_id zpb_ac_param_values.param_id%TYPE;

  --Missing Obj modified the cur to work based on current instance id
  cursor latest_instance_desc_cur is
  select to_number(substr(instance_description,length(instance_description) -2))
  from   zpb_analysis_cycle_instances
  where  instance_ac_id = (select max(instance_ac_id)
                           from   zpb_analysis_cycle_instances aci,
                                  zpb_analysis_cycles pubac,
                                  zpb_analysis_cycles runac
                           where pubac.analysis_cycle_id = ac_id_in
                           and   pubac.current_instance_id =
                                         runac.current_instance_id
                           and   runac.analysis_cycle_id = aci.instance_ac_id);

  CURSOR c_append_view IS
  SELECT VALUE FROM ZPB_AC_PARAM_VALUES
  WHERE ANALYSIS_CYCLE_ID = ac_id_in AND PARAM_ID = l_appview_param_id ;

BEGIN
  SELECT zpb_analysis_cycle_id_seq.NEXTVAL INTO new_ac_id FROM DUAL;

  create_ac_copy(ac_id_in, new_ac_id);

  SELECT *
    INTO ac_rec
    FROM zpb_analysis_cycles
   WHERE analysis_cycle_id = new_ac_id;

  SELECT tag INTO l_appview_param_id
  FROM fnd_lookup_values_vl
  WHERE LOOKUP_CODE = 'APPEND_VIEW'
  and LOOKUP_TYPE = 'ZPB_PARAMS';

  UPDATE zpb_analysis_cycles
     SET status_code = 'PUBLISHED',
         LAST_UPDATED_BY        = fnd_global.USER_ID,
         LAST_UPDATE_DATE     = SYSDATE,
         LAST_UPDATE_LOGIN    = fnd_global.LOGIN_ID
   WHERE analysis_cycle_id = new_ac_id;

  begin
   -- find if its an append view BP, do not show ID in that case
   open c_append_view;
   fetch c_append_view into l_app_view_status;
   if l_app_view_status  = 'DO_NOT_APPEND_VIEW' then

   -- find the counter for the last instance created
   open latest_instance_desc_cur;
   fetch latest_instance_desc_cur into curr_count;

   if latest_instance_desc_cur%notfound then
    -- this is the first instance
    curr_count_str := '001';
   else
      curr_count := curr_count + 1;
      if curr_count > 999 then
        -- recycle counter
        curr_count_str := '00' || to_char(curr_count - 999);
      end if;

      -- now prepend proper # of zeroes to make the length 3
      if curr_count > 99 and curr_count <= 999 then
        curr_count_str := to_char(curr_count);
      end if;

      if curr_count > 9 and curr_count <= 99 then
        curr_count_str := '0' || to_char(curr_count);
      end if;

      if curr_count <= 9 then
        curr_count_str := '00' || to_char(curr_count);
      end if;
    end if;
      close c_append_view ;
      close latest_instance_desc_cur;
    else
        curr_count_str := curr_count_str;
        close c_append_view ;
    end if;

   exception
     -- pre-existing instances may not be following
     -- the same naming convention and may fail.
     -- Just start with 001 for these BPs
     when others then
      curr_count_str := '001';
   end;

  instance_desc := ac_rec.name || ' ' || curr_count_str;

  instance_rec.analysis_cycle_id    := ac_id_in;
  instance_rec.instance_ac_id       := new_ac_id;
  instance_rec.instance_description := instance_desc;
  instance_rec.CREATED_BY           := fnd_global.USER_ID;
  instance_rec.CREATION_DATE        := SYSDATE;
  instance_rec.LAST_UPDATED_BY  := fnd_global.USER_ID;
  instance_rec.LAST_UPDATE_DATE     := SYSDATE;
  instance_rec.LAST_UPDATE_LOGIN    := fnd_global.LOGIN_ID;
  INSERT INTO zpb_analysis_cycle_instances(ANALYSIS_CYCLE_ID,
                    INSTANCE_AC_ID,
                    INSTANCE_DESCRIPTION,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATE_LOGIN,
                    STATUS_CODE)
          VALUES    (instance_rec.ANALYSIS_CYCLE_ID,
                    instance_rec.INSTANCE_AC_ID,
                    instance_rec.INSTANCE_DESCRIPTION,
                    instance_rec.CREATION_DATE,
                    instance_rec.CREATED_BY,
                    instance_rec.LAST_UPDATED_BY,
                    instance_rec.LAST_UPDATE_DATE,
                    instance_rec.LAST_UPDATE_LOGIN,
                    instance_rec.STATUS_CODE);
  instance_ac_id_out := new_ac_id;
END create_new_instance;


PROCEDURE create_tmp_cycle (
  editable_ac_id_in     IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  tmp_ac_id_out         OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
  new_ac_id    zpb_analysis_cycles.analysis_cycle_id%TYPE;
  pet_row_rec  zpb_cycle_relationships%ROWTYPE;
BEGIN
  SELECT *
    INTO pet_row_rec
    FROM zpb_cycle_relationships
   WHERE editable_ac_id = editable_ac_id_in;

  IF pet_row_rec.tmp_ac_id IS NULL THEN
    SELECT zpb_analysis_cycle_id_seq.NEXTVAL INTO new_ac_id FROM DUAL;
  ELSE
    delete_ac(pet_row_rec.tmp_ac_id);
    new_ac_id := pet_row_rec.tmp_ac_id;
  END IF;

  create_ac_copy(editable_ac_id_in, new_ac_id);

  UPDATE zpb_cycle_relationships
     SET tmp_ac_id = new_ac_id,
     LAST_UPDATED_BY    = fnd_global.USER_ID,
     LAST_UPDATE_DATE   = SYSDATE,
     LAST_UPDATE_LOGIN  = fnd_global.LOGIN_ID
   WHERE editable_ac_id = editable_ac_id_in;

  tmp_ac_id_out := new_ac_id;

END create_tmp_cycle;


PROCEDURE delete_tmp_ac (
  tmp_ac_id_in  IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
  editable_ac_id   zpb_analysis_cycles.analysis_cycle_id%TYPE;
BEGIN
  SELECT editable_ac_id
    INTO editable_ac_id
    FROM zpb_cycle_relationships
   WHERE tmp_ac_id = tmp_ac_id_in;

  UPDATE zpb_analysis_cycles
     SET
     LAST_UPDATED_BY    = fnd_global.USER_ID,
     LAST_UPDATE_DATE = SYSDATE,
     LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   WHERE analysis_cycle_id = editable_ac_id;

  delete_ac(tmp_ac_id_in);
END delete_tmp_ac;



PROCEDURE lock_cycle (
  editable_ac_id_in        IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  user_id_in               IN zpb_analysis_cycles.locked_by%TYPE,
  locked_by_id_out         OUT NOCOPY zpb_analysis_cycles.locked_by%TYPE)
IS
  locked_by_id   zpb_analysis_cycles.locked_by%TYPE;
BEGIN
  SELECT locked_by
    INTO locked_by_id
    FROM zpb_analysis_cycles
   WHERE analysis_cycle_id = editable_ac_id_in;

  locked_by_id_out := locked_by_id;

  IF locked_by_id IS NULL THEN
    UPDATE zpb_analysis_cycles
       SET locked_by = user_id_in,
       LAST_UPDATED_BY  = fnd_global.USER_ID,
       LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
     WHERE analysis_cycle_id = editable_ac_id_in;
    locked_by_id_out := user_id_in;
  END IF;

END lock_cycle;


PROCEDURE mark_cycle_for_delete (
  ac_id_in                 IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  prev_instance_options_in IN VARCHAR2,
  curr_instance_options_in IN VARCHAR2)
IS
  CURSOR previous_instance_cur IS
          SELECT aci.instance_ac_id, ac.current_instance_id
          from zpb_analysis_cycle_instances aci,zpb_analysis_cycles ac,
           zpb_analysis_cycles currinst
          where currinst.ANALYSIS_CYCLE_ID = ac_id_in
          and   currinst.current_instance_id=ac.current_instance_id
          and   ac.analysis_cycle_id=aci.instance_ac_id
          and   ac.status_code in ('COMPLETE','ERROR','COMPLETE_WITH_WARNING');

   CURSOR c_wfItemKey is
         select /*+ FIRST_ROWS */ item_key
         from WF_ITEM_ATTRIBUTE_VALUES
         where item_type = 'ZPBSCHED'
         and   name = 'ACID'
         and   number_value = ac_id_in;
   v_wfItemKey c_wfItemKey%ROWTYPE;

  curr_instance_ac_id   zpb_analysis_cycles.analysis_cycle_id%TYPE;
  l_count               NUMBER;
  cycle_type            VARCHAR2(30);
  tmp_ac_id             zpb_analysis_cycles.analysis_cycle_id%TYPE;
  edit_ac_id            zpb_analysis_cycles.analysis_cycle_id%TYPE;
  ownerid               NUMBER;
  l_REQID               NUMBER;
  l_REQID2              NUMBER;
  respID number := fnd_global.RESP_ID;
  respAppID number := fnd_global.RESP_APPL_ID;
  ItemType     varchar2(8) := 'ZPBSCHED';
  ItemKey      varchar2(240):='UNINITIALIZED';
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_business_area_id    number;

BEGIN

  -- abudnik 07DEC2005 BUSINESS AREA ID added for ZPB_WF_DELAWINST
  select published_by, BUSINESS_AREA_ID into ownerid, l_business_area_id
  from   zpb_analysis_cycles
  where analysis_cycle_id = ac_id_in;

        for v_wfItemKey in c_wfItemKey loop
                ItemKey:=v_wfItemKey.item_key;
        end loop;

        -- if ItemKey is not found then this is an unpublished BP
        -- and we do not need to initialize the apps context as we will
        -- not be submitting any CM requests
        if ItemKey <> 'UNINITIALIZED' then
                ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                        Itemkey => ItemKey,
                        aname => 'OWNERID');

                respID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                        Itemkey => ItemKey,
                        aname => 'RESPID');

                respAppID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPAPPID');

        -- Set the context before calling submit_request
        fnd_global.apps_initialize(ownerID, respID, RespAppId);

        end if;

   get_cycle_type(ac_id_in, cycle_type);

  /*
   * If the cycle is a Published cycle, then check whether there were
   * any events on which other cycles were dependent. If so, then
   * notify the users who are the owners of the dependent cycles.
   */
   IF cycle_type = 'PUBLISHED' THEN
         zpb_wf_ntf.notify_on_delete(ac_id_in, 'ACID');

  SELECT tmp_ac_id into tmp_ac_id
   FROM zpb_cycle_relationships
   WHERE published_ac_id = ac_id_in;

  SELECT editable_ac_id into edit_ac_id
   FROM zpb_cycle_relationships
   WHERE published_ac_id = ac_id_in;

   ZPB_WF.CallWFAbort(ac_id_in);

   END IF;

  /*
   * If the cycle is an editable copy, then also update
   * the ZPB_CYCLE_RELATIONSHIPS table
   */
  IF cycle_type = 'EDITABLE_COPY' THEN

  SELECT tmp_ac_id into tmp_ac_id
   FROM zpb_cycle_relationships
   WHERE editable_ac_id = ac_id_in;

   UPDATE zpb_cycle_relationships
    set editable_ac_id = null,
        LAST_UPDATED_BY = fnd_global.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
    where editable_ac_id = ac_id_in;
  END IF;

  IF cycle_type = 'UNPUBLISHED' THEN

  SELECT tmp_ac_id into tmp_ac_id
   FROM zpb_cycle_relationships
   WHERE editable_ac_id = ac_id_in;

  END IF;

  -- Now mark the cycle its editable copy, and its temp copy  for deletion
  UPDATE zpb_analysis_cycles
     SET status_code='MARKED_FOR_DELETION',
         LAST_UPDATED_BY        = fnd_global.USER_ID,
         LAST_UPDATE_DATE     = SYSDATE,
         LAST_UPDATE_LOGIN    = fnd_global.LOGIN_ID
   WHERE analysis_cycle_id in (ac_id_in, tmp_ac_id, edit_ac_id);

  DELETE zpb_dc_objects
  WHERE delete_instance_measures_flag = 'D' and
                analysis_cycle_id = ac_id_in;

  -- now delete any Data Collection templates
  -- associated with this cycle
   zpb_dc_objects_pvt.delete_template(
   1.0, FND_API.G_TRUE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL,
   l_return_status, l_msg_count, l_msg_data, ac_id_in);

   zpb_dc_objects_pvt.delete_template(
   1.0, FND_API.G_TRUE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL,
   l_return_status, l_msg_count, l_msg_data, tmp_ac_id);

   zpb_dc_objects_pvt.delete_template(
   1.0, FND_API.G_TRUE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL,
   l_return_status, l_msg_count, l_msg_data, edit_ac_id);

  --Loop over all completed/errored instances and delete them
  IF prev_instance_options_in = 'DELETE_PREVIOUS_INSTANCE' THEN

    FOR instance_rec IN previous_instance_cur LOOP

      UPDATE zpb_analysis_cycles
         SET status_code='MARKED_FOR_DELETION',
         LAST_UPDATED_BY        = fnd_global.USER_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       WHERE analysis_cycle_id = instance_rec.instance_ac_id;

    -- Clean up the measure for
    -- abudnik 07DEC2005 BUSINESS AREA ID added for ZPB_WF_DELAWINST
    l_REQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WF_DELAWINST', NULL, NULL, FALSE, instance_rec.instance_ac_id, ownerid, l_business_area_id);

/*
        IF instance_rec.current_instance_id IS NOT NULL THEN
    l_REQID2 := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WF_DELAWINST', NULL, NULL, FALSE, instance_rec.current_instance_id, ownerid);
        END IF;
*/

      -- now delete any Data Collection templates
      -- associated with this cycle
      zpb_dc_objects_pvt.delete_template(
      1.0, FND_API.G_TRUE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL,
      l_return_status, l_msg_count, l_msg_data, instance_rec.instance_ac_id);
    END LOOP;
  END IF;

  -- Mark for delete all instances that are still active,
  IF curr_instance_options_in = 'DELETE_CURR_INSTANCE' THEN

          -- ABUDNIK B4558985 09Oct2005
          CLEAN_ACTIVE_INSTANCE(ac_id_in);

          UPDATE zpb_analysis_cycles
          SET status_code = 'MARKED_FOR_DELETION',
              LAST_UPDATED_BY     = fnd_global.USER_ID,
              LAST_UPDATE_DATE   = SYSDATE,
              LAST_UPDATE_LOGIN  = fnd_global.LOGIN_ID
          WHERE analysis_cycle_id in
          (select instance_ac_id
           from zpb_analysis_cycle_instances aci,zpb_analysis_cycles ac,
                zpb_analysis_cycles currinst
           where currinst.ANALYSIS_CYCLE_ID =ac_id_in
           and   currinst.current_instance_id=ac.current_instance_id
           and   ac.analysis_cycle_id=aci.instance_ac_id
           and   ac.status_code NOT IN ('COMPLETE','ERROR','COMPLETE_WITH_WARNING'));

        -- Clean up Current Instance Measure if Appropriate
           ZPB_WF.DeleteCurrInstMeas(ac_id_in, ownerid);

           -- now delete any Data Collection templates
           -- associated with this cycle
           zpb_dc_objects_pvt.delete_template(
           1.0, FND_API.G_TRUE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL,
           l_return_status, l_msg_count, l_msg_data, ac_id_in);

  END IF;

END mark_cycle_for_delete;

--
-- This procedure updates the current_modified flag in zpb_solve_member_defs.
-- The flag is used to indicate that the input_levels OR the
-- calc definition was changed when the BP was made effective again
-- The flag will be used by the Solve task of an active instance to
-- determine if it should start the Solve from the very beginning or not
--
PROCEDURE update_solve_definition_flag(
     editable_ac_id_in     IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
     published_ac_id_in     IN zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
    cursor input_levels_cur(published_ac_id_in IN integer ,
                            editable_ac_id_in in integer)   IS
    select edt.member, edt.dimension, edt.input_level
    from zpb_solve_input_levels edt
    where edt.analysis_cycle_id =  editable_ac_id_in
    MINUS
    select pub.member, pub.dimension, pub.input_level
    from zpb_solve_input_levels pub
    where pub.analysis_cycle_id=   published_ac_id_in;

begin

   --
   -- find all members whose calc definition was changed.
   --
   update zpb_solve_member_defs edt
   set current_modified = 'Y'
   where edt.analysis_cycle_id = editable_ac_id_in
   and   edt.source_type = 1200
   and 0 <> (select dbms_lob.compare(edt.model_equation, pub.model_equation)
                          from zpb_solve_member_defs  pub
                          where pub.analysis_cycle_id = published_ac_id_in
                            and pub.member = edt.member
                            and pub.source_type = 1200);

   --
   -- now find all members whose input levels were changed
   --
   for each in  input_levels_cur(published_ac_id_in,editable_ac_id_in) loop
      update zpb_solve_member_defs
      set current_modified = 'Y'
      where analysis_cycle_id = editable_ac_id_in
      and member = each.member;
   end loop;

end update_solve_definition_flag;

PROCEDURE publish_cycle (
  editable_ac_id_in     IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  published_by_in       IN zpb_analysis_cycles.published_by%TYPE,
  publish_options_in    IN VARCHAR2,
  published_ac_id_out   OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE)
IS
  l_dummy   VARCHAR2(4000);
BEGIN
-- call the overloaded procedure marking it as a non external event.
   publish_cycle(
     editable_ac_id_in        => editable_ac_id_in
    ,published_by_in          => published_by_in
    ,publish_options_in       => publish_options_in
    ,p_external               => 'N'
    ,p_bp_name_in             => null
    ,p_start_mem_in           => null
    ,p_end_mem_in             => null
    ,p_send_date_in           => null
    ,published_ac_id_out      => published_ac_id_out
    ,x_item_key_out           => l_dummy
  );
END publish_cycle;

-- This procedure will convert the EDITABLE_AC_ID into PUBLISHED_AC_ID.
-- Old published_ac_id will be deleted. All the related ACTIVE
-- instances in ZPB_ANALYSIS_CYCLE_INSTANCES will also be updated
-- with the latest definition of the BP incase user chooses to update
-- current runs.


PROCEDURE publish_cycle (
  editable_ac_id_in        IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  published_by_in          IN zpb_analysis_cycles.published_by%TYPE,
  publish_options_in       IN VARCHAR2,
  p_bp_name_in             IN VARCHAR2,
  p_external               IN VARCHAR2,
  p_start_mem_in           IN VARCHAR2,
  p_end_mem_in             IN VARCHAR2,
  p_send_date_in           IN DATE,
  published_ac_id_out      OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE,
  x_item_key_out           OUT NOCOPY VARCHAR2)
IS
  old_published_ac_id     zpb_analysis_cycles.analysis_cycle_id%TYPE;
  ac_rec                  zpb_analysis_cycles%ROWTYPE;
  pet_row_rec             zpb_cycle_relationships%ROWTYPE;
  published_before        VARCHAR2(1);
  published_before_status VARCHAR2(30);
  enable_option           varchar2(30);


  /* select the instances of this BP that are still active
     these will be updated with the new definition below */

  CURSOR instance_cur IS
  SELECT zaci.instance_ac_id, zaci.analysis_cycle_id
  FROM  ZPB_ANALYSIS_CYCLE_INSTANCES zaci,
        ZPB_ANALYSIS_CYCLES zac
  WHERE zaci.analysis_cycle_id = editable_ac_id_in and
        zaci.instance_ac_id = zac.analysis_cycle_id and
        zac.status_code not in('COMPLETE', 'COMPLETE_WITH_WARNING', 'DISABLE_ASAP', 'ERROR', 'MARKED_FOR_DELETION');

BEGIN

  IF (p_external = 'Y')
  THEN
    old_published_ac_id := editable_ac_id_in;

  ELSE

    SELECT *
      INTO pet_row_rec
      FROM zpb_cycle_relationships
     WHERE editable_ac_id = editable_ac_id_in;

    IF pet_row_rec.published_ac_id IS NULL THEN
  --    SELECT zpb_analysis_cycle_id_seq.NEXTVAL INTO new_ac_id FROM DUAL;
      old_published_ac_id := -1;
      published_before := 'N';

    ELSE

      -- If previously published BP was in disable status, enable it here

      begin

      select STATUS_CODE into published_before_status
      from ZPB_ANALYSIS_CYCLES
      where analysis_cycle_id=pet_row_rec.published_ac_id;

      exception
       when NO_DATA_FOUND then
              published_before_status:='NO DEF FOUND';
      end;


      if published_before_status = 'DISABLE_ASAP' then

          -- "Translate" the make effective option to analogous enable option
          if publish_options_in = 'UPDATE_FOR_CURRENT' then
                  enable_option:= 'ENABLE_TASK';
          end if;

          if publish_options_in = 'UPDATE_FOR_FUTURE' then
                  enable_option:= 'ENABLE_NEXT';
          end if;

          zpb_wf.enable_cycle(pet_row_rec.published_ac_id, enable_option);
      end if;


      --
      -- bug 3773258 - sk
      --  If the user is trying to update current runs then we have to check
      --  if he changed the calc definition or the input levels. If so then
      --  a solve flag has to be set.
      --  The simplest way to propagate this flag to older instances is to
      --  set them in the published_ac_id rows.
      --
      --
      -- The procedure below updates the flag in the EDITABLE_AC_ID rows !!!
      -- This is done because we are going to delete the original rows of
      -- published_ac_id and replacing them with rows of editable_ac_id.
      --

      IF publish_options_in = 'UPDATE_FOR_CURRENT' THEN
        update_solve_definition_flag(editable_ac_id_in, pet_row_rec.published_ac_id);
      END IF;

--      delete_ac(pet_row_rec.published_ac_id);

      old_published_ac_id := pet_row_rec.published_ac_id;

      Update ZPB_ANALYSIS_CYCLES
      set STATUS_CODE = 'ENABLE_TASK_OLD'
      where ANALYSIS_CYCLE_ID = old_published_ac_id
      and STATUS_CODE = 'ENABLE_TASK';

      published_before := 'Y';
    END IF;

  /*  UPDATE ZPB_ANALYSIS_CYCLE_INSTANCES
      SET Analysis_Cycle_Id = editable_ac_id_in
      WHERE Analysis_Cycle_Id = old_published_ac_id; */

--   UPDATE ZPB_DC_OBJECTS
--      SET Analysis_Cycle_Id = editable_ac_id_in
--      WHERE Analysis_Cycle_Id = old_published_ac_id;

  END IF;

  UPDATE zpb_cycle_relationships
     SET published_ac_id   = editable_ac_id_in,
         editable_ac_id    = null,
         LAST_UPDATED_BY   = fnd_global.USER_ID,
         LAST_UPDATE_DATE  = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   WHERE editable_ac_id = editable_ac_id_in;

/*
 * must set the cycle status to 'ENABLE_TASK' by default when
 * publishing the cycle
 */

  UPDATE zpb_analysis_cycles
     SET published_by = published_by_in,
         published_date = sysdate,
         status_code  = 'ENABLE_TASK',
         LAST_UPDATED_BY   = fnd_global.USER_ID,
         LAST_UPDATE_DATE  = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   WHERE analysis_cycle_id = editable_ac_id_in;

/*
 * If user chooses to apply publish changes already for current
 * cycles, then we must copy the cycle defition to all the
 * instance definitions.
 */

  IF publish_options_in = 'UPDATE_FOR_CURRENT' THEN

    FOR instance_rec IN instance_cur LOOP

      SELECT *
      INTO ac_rec
      FROM zpb_analysis_cycles
      WHERE analysis_cycle_id = instance_rec.instance_ac_id;

      delete_ac(instance_rec.instance_ac_id, FND_API.G_FALSE);

-- copy all parts - but only those tasks that have not yet started

  copy_ac_table_rec(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  copy_ac_param_values_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  copy_cycle_currency_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  copy_external_user_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  copy_cycle_datasets_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);

  copy_nonstarted_tasks(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);


  copy_cycle_model_dim_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  copy_cycle_comments_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  copy_solve_member_defs_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  copy_data_init_defs_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  copy_solve_input_level_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  copy_solve_output_level_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  copy_solve_alloc_defs_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  copy_line_dimensionality_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  -- Bug 4587184: Remove the following code, because they are invoked from
  -- copy_nonstarted_tasks now.
  -- copy_bp_scope_access_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  -- copy_bp_measure_scope_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);
  copy_solve_hier_order_recs(instance_rec.analysis_cycle_id, instance_rec.instance_ac_id);

      -- Set the status and name of the instance back to what it was before copy
      -- most likely ACTIVE

      UPDATE zpb_analysis_cycles
         SET LAST_UPDATED_BY    = fnd_global.USER_ID,
             LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID,
             STATUS_CODE = ac_rec.status_code,
             PREV_STATUS_CODE = ac_rec.prev_status_code,
             NAME = ac_rec.name
       WHERE analysis_cycle_id = instance_rec.instance_ac_id;
    END LOOP;
  END IF;

--BPEXT
--update the horizon params if this is a ext published
  IF (p_external = 'Y') THEN
     zpb_wf_event.acstart_event( acid        => editable_ac_id_in
                               , p_start_mem => p_start_mem_in
                               , p_end_mem   => p_end_mem_in
                               , p_send_date => p_send_date_in
                               , x_event_key => x_item_key_out);
  ELSE

    zpb_wf.acstart(editable_ac_id_in, published_before);
  END IF;

  published_ac_id_out := editable_ac_id_in;
END publish_cycle;

PROCEDURE save_tmp_cycle (
  tmp_ac_id_in          IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  last_updated_by_in    IN zpb_analysis_cycles.last_updated_by%TYPE,
  lock_val_in           IN zpb_analysis_cycles.locked_by%TYPE,
  lock_ac_id_in         IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  x_return_status       OUT NOCOPY VARCHAR2 ,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  editable_ac_id_out    OUT NOCOPY zpb_analysis_cycles.analysis_cycle_id%TYPE)

IS
  new_ac_id    zpb_analysis_cycles.analysis_cycle_id%TYPE;
  pet_row_rec  zpb_cycle_relationships%ROWTYPE;
  lock_val     zpb_analysis_cycles.locked_by%TYPE;
    msg_data VARCHAR2(100);
  CURSOR lock_cursor is SELECT locked_by FROM zpb_analysis_cycles
  where analysis_cycle_id = lock_ac_id_in FOR UPDATE;

BEGIN

  IF lock_ac_id_in IS NOT NULL THEN
      OPEN lock_cursor;
      FETCH lock_cursor into lock_val;

      IF lock_val <> lock_val_in THEN
        FND_MESSAGE.SET_NAME('ZPB', 'ZPB_BUS_PROC_LOCKED');
                x_msg_data := 'ZPB_BUS_PROC_LOCKED';
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;
  SELECT *
    INTO pet_row_rec
    FROM zpb_cycle_relationships
   WHERE tmp_ac_id = tmp_ac_id_in;

  IF pet_row_rec.editable_ac_id IS NULL THEN
    SELECT zpb_analysis_cycle_id_seq.NEXTVAL INTO new_ac_id FROM DUAL;
  ELSE
    delete_ac(pet_row_rec.editable_ac_id);
    new_ac_id := pet_row_rec.editable_ac_id;
  END IF;

  create_ac_copy(tmp_ac_id_in, new_ac_id);

  UPDATE zpb_cycle_relationships
     SET editable_ac_id = new_ac_id,
         LAST_UPDATED_BY = fnd_global.USER_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   WHERE tmp_ac_id = tmp_ac_id_in;

  delete_ac(tmp_ac_id_in);

  UPDATE zpb_analysis_cycles
     SET locked_by        = nvl(locked_by,0)+1,
         LAST_UPDATED_BY        = fnd_global.USER_ID,
           LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   where analysis_cycle_id = new_ac_id;

   IF lock_cursor%ISOPEN THEN
       close lock_cursor;
   END IF;

  editable_ac_id_out := new_ac_id;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    editable_ac_id_out := null;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => msg_data );
    IF lock_cursor%ISOPEN THEN
        CLOSE lock_cursor;
    END IF;
END save_tmp_cycle;


/*
 * This procedure returns the type of the cycle
 * (i.e. PUBLISHED, EDITABLE_COPY, UNPUBLISHED)
 * based on its cycle ID
 */

PROCEDURE get_cycle_type (
  ac_id_in              IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  cycle_type_out        OUT NOCOPY VARCHAR2)
IS
  pet_row_rec  zpb_cycle_relationships%ROWTYPE;
BEGIN
  /*
   * We are guaranteed to have only one row returned because of
   * the design of the ZPB_CYCLE_RELATIONSHIPS table.
   */
  SELECT *
    INTO pet_row_rec
    FROM zpb_cycle_relationships
  WHERE tmp_ac_id = ac_id_in or
         published_ac_id = ac_id_in or
         editable_ac_id = ac_id_in;

  IF pet_row_rec.published_ac_id = ac_id_in THEN
    cycle_type_out := 'PUBLISHED';
  ELSE
     IF pet_row_rec.editable_ac_id = ac_id_in THEN
       IF pet_row_rec.published_ac_id IS NULL THEN
          cycle_type_out := 'UNPUBLISHED';
       ELSE
          cycle_type_out := 'EDITABLE_COPY';
       END IF;
     END IF;
  END IF;

END get_cycle_type;

/*
 * This procedure returns the status of the cycle
 * based on its cycle ID
 */

PROCEDURE get_cycle_status (
  ac_id_in              IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
  cycle_status_out        OUT NOCOPY VARCHAR2)
IS

BEGIN

 begin

  SELECT status_code
    INTO cycle_status_out
    FROM zpb_analysis_cycles
  WHERE analysis_cycle_id=ac_id_in;

 exception
   when no_data_found then
        cycle_status_out:='CYCLENOTFOUND';
 end;

END get_cycle_status;

 PROCEDURE get_lock_value (
   ac_id_in              IN zpb_analysis_cycles.analysis_cycle_id%TYPE,
   lock_value_out        OUT NOCOPY NUMBER)
 IS

 BEGIN

  begin

   SELECT locked_by
     INTO lock_value_out
     FROM zpb_analysis_cycles
   WHERE analysis_cycle_id=ac_id_in;

  exception
    when no_data_found then
         lock_value_out:= -1;
  end;

 END get_lock_value;

/*
 * This procedure enables the cycle identified by
 * <ac_id_in> based on the enable status passed into the UI.
 */
PROCEDURE enable_cycle (
  ac_id_in              IN  zpb_analysis_cycles.analysis_cycle_id%TYPE,
  enable_status_in      IN  VARCHAR2)
IS
BEGIN

  -- simple wrapper around the zpb_wf procedure of the same name
  zpb_wf.enable_cycle(ac_id_in, enable_status_in);

END enable_cycle;

/*
 * This function returns 1 if this temp ac id is a draft of a published cycle
 * <p_tmp_ac_id>
 */
FUNCTION isTmpDraftOfPublishedBP(p_tmp_ac_id IN zpb_analysis_cycles.analysis_cycle_id%TYPE) RETURN NUMBER IS
  CURSOR c_draft(cp_tmp_ac_id IN zpb_analysis_cycles.analysis_cycle_id%TYPE) IS
    SELECT 1 FROM zpb_cycle_relationships
    WHERE TMP_AC_ID = cp_tmp_ac_id AND published_ac_id IS NOT NULL;
  l_ret    NUMBER(2);
BEGIN
  OPEN c_draft(cp_tmp_ac_id => p_tmp_ac_id);
  FETCH c_draft INTO l_ret;
  CLOSE c_draft;
  RETURN NVL(l_ret,0);
EXCEPTION
  WHEN OTHERS THEN
    IF (c_draft%ISOPEN) THEN
      CLOSE c_draft;
    END IF;
    RETURN 0;
END isTmpDraftOfPublishedBP;

/*
This function will return a unique default BP Name when the
duplication of business process is invoked.
Assumption(s):
  Maximum length of the name of a BP is 300.
*/
FUNCTION getUniqueName(p_bus_area_id IN zpb_analysis_cycles.business_area_id%TYPE,
         p_cycle_name IN varchar2)RETURN VARCHAR IS

cursor unique_name_cur(cycle_name zpb_analysis_cycles.name%type)
is
select 1 from zpb_analysis_cycles where
lower(name) = lower(cycle_name)
and status_code <> 'MARKED_FOR_DELETION'
and business_area_id = p_bus_area_id;

orig_name   varchar2(500);
new_bp_name zpb_analysis_cycles.name%TYPE;
old_name    zpb_analysis_cycles.name%type;
temp number := null;
mycount number := 1;

BEGIN
  orig_name := p_cycle_name;
  if length(p_cycle_name) > 300 then
    orig_name := substr(p_cycle_name,1,300);
  end if;

  new_bp_name := orig_name;
  old_name := orig_name;
  loop
    if unique_name_cur%isopen then
      close unique_name_cur;
    end if;
    open unique_name_cur(new_bp_name);
    fetch unique_name_cur into temp;
    exit when unique_name_cur%notfound;
    if length(old_name) > 300 then
      new_bp_name := substr(old_name,1, length(old_name)- (length(mycount) + 1)) || '_' || mycount;
    elsif (length(old_name) + length(mycount) + 1) > 300 then
      new_bp_name := substr(old_name,1, 300 - (length(mycount) + 1)) || '_' || mycount;
    else
      new_bp_name := old_name || '_' || mycount;
    end if;
    mycount := mycount + 1;
  end loop;
  if unique_name_cur%isopen then
    close unique_name_cur;
  end if;

  return new_bp_name;
EXCEPTION
  when others then
    if unique_name_cur%isopen
    then
      close unique_name_cur;
    end if;
    return null;
END getUniqueName;

procedure create_ac_param_values(p_ac_id in number,
          p_param_id in  number,
          p_value in varchar2,
          p_apps_user_id in number) AS
ac_param_rec  zpb_ac_param_values%rowtype;
begin
  ac_param_rec.analysis_cycle_id := p_ac_id;
  ac_param_rec.param_id := p_param_id;
  ac_param_rec.value := p_value;
  ac_param_rec.CREATED_BY        := p_apps_user_id;
  ac_param_rec.CREATION_DATE     := SYSDATE;
  ac_param_rec.LAST_UPDATED_BY   := p_apps_user_id;
  ac_param_rec.LAST_UPDATE_DATE  := SYSDATE;
  ac_param_rec.LAST_UPDATE_LOGIN := p_apps_user_id;

  INSERT INTO zpb_ac_param_values(ANALYSIS_CYCLE_ID,
                    PARAM_ID,
                    VALUE,
                    LAST_UPDATE_LOGIN,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY)
  VALUES    (ac_param_rec.ANALYSIS_CYCLE_ID,
                    ac_param_rec.PARAM_ID,
                    ac_param_rec.VALUE,
                    ac_param_rec.LAST_UPDATE_LOGIN,
                    ac_param_rec.LAST_UPDATE_DATE,
                    ac_param_rec.LAST_UPDATED_BY,
                    ac_param_rec.CREATION_DATE,
                    ac_param_rec.CREATED_BY);
end create_ac_param_values;


procedure create_cycle_model_dimensions( p_ac_id in number,
                                         dimension_list in varchar2,
                                         p_apps_user_id in number) AS

  md_rec    zpb_cycle_model_dimensions%rowtype;
  dimension varchar2(100);
  i         integer;
  j         integer;

begin
    md_rec.analysis_cycle_id := p_ac_id;
    md_rec.CREATED_BY        := p_apps_user_id;
    md_rec.CREATION_DATE     := SYSDATE;
    md_rec.LAST_UPDATED_BY := p_apps_user_id;
    md_rec.LAST_UPDATE_DATE  := SYSDATE;
    md_rec.LAST_UPDATE_LOGIN := p_apps_user_id;

    i:= 1;
    loop
      j := instr(dimension_list, ':',i);
      if (j = 0) then
        dimension := substr(dimension_list, i);
      else
       dimension := substr(dimension_list, i,j - i);
       i := j + 1;
      end if;
      md_rec.dimension_name := dimension;
      INSERT INTO zpb_cycle_model_dimensions(ANALYSIS_CYCLE_ID,
                    DIMENSION_NAME,
                    QUERY_OBJECT_NAME,
                    QUERY_OBJECT_PATH,
                    LAST_UPDATE_LOGIN,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    DATASET_DIMENSION_FLAG,
                    REMOVE_DIMENSION_FLAG,
                    SUM_MEMBERS_NUMBER,
                    SUM_SELECTION_NAME,
                    SUM_SELECTION_PATH)
       VALUES  (md_rec.ANALYSIS_CYCLE_ID,
                    md_rec.DIMENSION_NAME,
                    md_rec.QUERY_OBJECT_NAME,
                    md_rec.QUERY_OBJECT_PATH,
                    md_rec.LAST_UPDATE_LOGIN,
                    md_rec.LAST_UPDATE_DATE,
                    md_rec.LAST_UPDATED_BY,
                    md_rec.CREATION_DATE,
                    md_rec.CREATED_BY,
                    md_rec.DATASET_DIMENSION_FLAG,
                    md_rec.REMOVE_DIMENSION_FLAG,
                    md_rec.SUM_MEMBERS_NUMBER,
                    md_rec.SUM_SELECTION_NAME,
                    md_rec.SUM_SELECTION_PATH);
      exit when j = 0;
    end loop;
exception
  when others then
    raise;
end create_cycle_model_dimensions;

procedure create_datasets( p_ac_id in number,
                          dataset_list in varchar2,
                          p_apps_user_id in number) AS

  ds_rec    zpb_cycle_datasets%rowtype;
  order_id  zpb_cycle_datasets.order_id%type;
  dataset   varchar2(100);
  i         integer;
  j         integer;

begin
    ds_rec.analysis_cycle_id := p_ac_id;
    ds_rec.CREATED_BY        := p_apps_user_id ;
    ds_rec.CREATION_DATE     := SYSDATE;
    ds_rec.LAST_UPDATED_BY := p_apps_user_id ;
    ds_rec.LAST_UPDATE_DATE  := SYSDATE;
    ds_rec.LAST_UPDATE_LOGIN := p_apps_user_id ;
    order_id := 0;

    i:= 1;
    loop
      j := instr(dataset_list, ':',i);
      if (j = 0) then
        dataset := substr(dataset_list, i);
      else
        dataset := substr(dataset_list, i, j - i);
       i := j + 1;
      end if;
      ds_rec.dataset_code := dataset;
      ds_rec.order_id := order_id;
      order_id := order_id + 1;

      INSERT INTO zpb_cycle_datasets(ANALYSIS_CYCLE_ID,
                    DATASET_CODE,
                    ORDER_ID,
                    LAST_UPDATE_LOGIN,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY)
      VALUES    (ds_rec.ANALYSIS_CYCLE_ID,
                    ds_rec.DATASET_CODE,
                    ds_rec.ORDER_ID,
                    ds_rec.LAST_UPDATE_LOGIN,
                    ds_rec.LAST_UPDATE_DATE,
                    ds_rec.LAST_UPDATED_BY,
                    ds_rec.CREATION_DATE,
                    ds_rec.CREATED_BY);
      exit when j = 0;
    end loop;
exception
  when others then
    raise;
end create_datasets;


procedure create_partial_cycle (
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 :=  FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER   :=  FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_apps_user_id         in number,
  p_cycle_name           in varchar2,
  p_description          in varchar2,
  p_appended             in varchar2,
  p_calendar_start_type  in varchar2,
  p_calendar_start_member in varchar2,
  p_calendar_start_periods in number,
  p_calendar_start_level in varchar2,
  p_calendar_start_pf    in varchar2,
  p_calendar_end_type    in varchar2,
  p_calendar_end_member  in varchar2,
  p_calendar_end_periods in number,
  p_calendar_end_level   in varchar2,
  p_calendar_end_pf      in varchar2,
  p_model_dimensions     in varchar2,
  p_versions in number,
  x_ac_id out nocopy number) as

  l_api_name      CONSTANT VARCHAR2(30) := 'create_partial_cycle';
  l_api_version   CONSTANT NUMBER       := 1.0;
  new_ac_id          zpb_analysis_cycles.analysis_cycle_id%TYPE;
  current_inst_id    zpb_analysis_cycles.current_instance_id%TYPE;
  ac_rec             zpb_analysis_cycles%ROWTYPE;
  pet_rec            zpb_cycle_relationships%ROWTYPE;
  relationship_id    zpb_cycle_relationships.relationship_id%TYPE;
  ac_param_rec       zpb_ac_param_values%ROWTYPE;
  invalid_versions   exception;
  invalid_calendar_start_type   exception;
  invalid_calendar_end_type   exception;
  invalid_calendar_start_pf   exception;
  invalid_calendar_end_pf   exception;
  invalid_appended   exception;

begin
 -- Standard Start of API savepoint
  SAVEPOINT create_partial_cycle;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SELECT zpb_analysis_cycle_id_seq.NEXTVAL INTO new_ac_id FROM DUAL;
  SELECT zpb_analysis_cycle_id_seq.NEXTVAL INTO current_inst_id FROM DUAL;
  SELECT zpb_relationship_id_seq.NEXTVAL INTO relationship_id FROM DUAL;

  ac_rec.analysis_cycle_id := new_ac_id;
  ac_rec.name              := p_cycle_name;
  ac_rec.description       := p_description;
  ac_rec.validate_status   := 'INVALID';
  ac_rec.status_code       := 'DISABLE_ASAP';
  ac_rec.current_instance_id := current_inst_id;
  ac_rec.CREATED_BY        := p_apps_user_id;
  ac_rec.CREATION_DATE     := SYSDATE;
  ac_rec.LAST_UPDATED_BY   := p_apps_user_id;
  ac_rec.LAST_UPDATE_DATE  := SYSDATE;
  ac_rec.LAST_UPDATE_LOGIN := p_apps_user_id;
  ac_rec.PUBLISHED_BY      := p_apps_user_id;

  INSERT INTO zpb_analysis_cycles(ANALYSIS_CYCLE_ID,
                    STATUS_CODE,
                    NAME,
                    DESCRIPTION,
                    LOCKED_BY,
                    VALIDATE_STATUS,
                    CURRENT_INSTANCE_ID,
                    PUBLISHED_DATE,
                    PUBLISHED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    PREV_STATUS_CODE,
                    LAST_UPDATE_LOGIN,
                    BUSINESS_AREA_ID,
                    OWNER_ID)
     VALUES (ac_rec.ANALYSIS_CYCLE_ID,
                    ac_rec.STATUS_CODE,
                    ac_rec.NAME,
                    ac_rec.DESCRIPTION,
                    ac_rec.LOCKED_BY,
                    ac_rec.VALIDATE_STATUS,
                    ac_rec.CURRENT_INSTANCE_ID,
                    ac_rec.PUBLISHED_DATE,
                    ac_rec.PUBLISHED_BY,
                    ac_rec.LAST_UPDATE_DATE,
                    ac_rec.LAST_UPDATED_BY,
                    ac_rec.CREATION_DATE,
                    ac_rec.CREATED_BY,
                    ac_rec.PREV_STATUS_CODE,
                    ac_rec.LAST_UPDATE_LOGIN,
                    ac_rec.BUSINESS_AREA_ID,
                    ac_rec.OWNER_ID);
  pet_rec.relationship_id   := relationship_id;
  pet_rec.editable_ac_id    := new_ac_id;
  pet_rec.CREATED_BY        := p_apps_user_id;
  pet_rec.CREATION_DATE     := SYSDATE;
  pet_rec.LAST_UPDATED_BY   := p_apps_user_id;
  pet_rec.LAST_UPDATE_DATE  := SYSDATE;
  pet_rec.LAST_UPDATE_LOGIN := p_apps_user_id;
  INSERT INTO zpb_cycle_relationships(RELATIONSHIP_ID,
                    PUBLISHED_AC_ID,
                    EDITABLE_AC_ID,
                    TMP_AC_ID,
                    LAST_UPDATE_LOGIN,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY)
  VALUES (pet_rec.RELATIONSHIP_ID,
                    pet_rec.PUBLISHED_AC_ID,
                    pet_rec.EDITABLE_AC_ID,
                    pet_rec.TMP_AC_ID,
                    pet_rec.LAST_UPDATE_LOGIN,
                    pet_rec.LAST_UPDATE_DATE,
                    pet_rec.LAST_UPDATED_BY,
                    pet_rec.CREATION_DATE,
                    pet_rec.CREATED_BY);
  ac_param_rec.analysis_cycle_id := new_ac_id;

  -- now populate the AC param values
  if p_versions is not null then
    create_ac_param_values(new_ac_id,2,to_char(p_versions),p_apps_user_id);
  else
    raise invalid_versions;
  end if;
  create_ac_param_values(new_ac_id,3,to_char(sysdate),p_apps_user_id);

  if p_calendar_start_type is  null
    OR (p_calendar_start_type <> 'FIXED'
    AND p_calendar_start_type <> 'RELATIVE') then
    raise invalid_calendar_start_type;
  end if;

  if (p_calendar_start_type = 'FIXED') then
      create_ac_param_values(new_ac_id,4,'FIXED_TIME',p_apps_user_id);
  else
      create_ac_param_values(new_ac_id,4,'NUMBER_OF_PERIODS',p_apps_user_id);
  end if;


  if p_calendar_start_member  is not null then
   create_ac_param_values(new_ac_id,5,p_calendar_start_member,p_apps_user_id);
  end if;

  if p_calendar_start_periods  is not null then
   create_ac_param_values(new_ac_id,9,p_calendar_start_periods,p_apps_user_id);
  end if;

  if p_calendar_start_level  is not null then
   create_ac_param_values(new_ac_id,8,p_calendar_start_level,p_apps_user_id);
  end if;

  if p_calendar_start_pf  is not null then
    if (p_calendar_start_pf = 'PRIOR')
    OR (p_calendar_start_pf = 'FUTURE')
    OR (p_calendar_start_pf = 'CURRENT') then
      create_ac_param_values(new_ac_id,10,p_calendar_start_pf,p_apps_user_id);
    else
      raise invalid_calendar_start_pf;
    end if;
  end if;

  if p_calendar_end_type is null
    OR (p_calendar_end_type <> 'FIXED'
    AND p_calendar_end_type <> 'RELATIVE') then
    raise invalid_calendar_end_type;
  end if;

  if (p_calendar_end_type = 'FIXED') then
     create_ac_param_values(new_ac_id,11,'FIXED_TIME',p_apps_user_id);
   else
     create_ac_param_values(new_ac_id,11,'NUMBER_OF_PERIODS',p_apps_user_id);
  end if;

  if p_calendar_end_member  is not null then
   create_ac_param_values(new_ac_id,12,p_calendar_end_member,p_apps_user_id);
  end if;

  if p_calendar_end_periods  is not null then
   create_ac_param_values(new_ac_id,16,p_calendar_end_periods,p_apps_user_id);
  end if;

  if p_calendar_end_level  is not null then
   create_ac_param_values(new_ac_id,15,p_calendar_end_level,p_apps_user_id);
  end if;

  if p_calendar_end_pf  is not null then
    if (p_calendar_end_pf = 'PRIOR')
    OR (p_calendar_end_pf = 'FUTURE')
    OR (p_calendar_end_pf = 'CURRENT') then
      create_ac_param_values(new_ac_id,17,p_calendar_end_pf,p_apps_user_id);
    else
      raise invalid_calendar_end_pf;
    end if;
  end if;
  if p_appended is null OR (p_appended <> 'Y' AND p_appended <> 'N') then
    raise invalid_appended;
  else
    if p_appended = 'N' then
      create_ac_param_values(new_ac_id, 26,'DO_NOT_APPEND_VIEW',p_apps_user_id);
    else
      create_ac_param_values(new_ac_id, 26,'APPEND_VIEW',p_apps_user_id);
    end if;
  end if;


  create_cycle_model_dimensions(new_ac_id, p_model_dimensions,p_apps_user_id);
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
  );

 x_ac_id := new_ac_id;
exception
 WHEN invalid_calendar_start_type then
    ROLLBACK TO create_partial_cycle;
    x_msg_count := 1;
    x_msg_data := 'Invalid calendar start type';
    x_return_status := FND_API.G_RET_STS_ERROR;
 WHEN invalid_calendar_end_type then
    ROLLBACK TO create_partial_cycle;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    x_msg_data := 'Invalid calendar end type';
 WHEN invalid_calendar_end_pf then
    ROLLBACK TO create_partial_cycle;
    x_msg_count := 1;
    x_msg_data := 'Invalid calendar end pf';
    x_return_status := FND_API.G_RET_STS_ERROR;
 WHEN invalid_calendar_start_pf then
    ROLLBACK TO create_partial_cycle;
    x_msg_count := 1;
    x_msg_data := 'Invalid calendar start pf';
    x_return_status := FND_API.G_RET_STS_ERROR;
 WHEN invalid_appended then
    ROLLBACK TO create_partial_cycle;
    x_msg_count := 1;
    x_msg_data := 'Invalid appended';
    x_return_status := FND_API.G_RET_STS_ERROR;
 WHEN invalid_versions then
    ROLLBACK TO create_partial_cycle;
    x_msg_count := 1;
    x_msg_data := 'Invalid  versions';
    x_return_status := FND_API.G_RET_STS_ERROR;
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_partial_cycle;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_partial_cycle;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO create_partial_cycle;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
end create_partial_cycle;


procedure create_task_parameters( task_id in number,
                                 name in varchar2,
                                 value in varchar,
                                 p_apps_user_id in number) AS

  ac_task_param_rec zpb_task_parameters%rowtype;
  task_param_id zpb_task_parameters.param_id%type;
begin

    SELECT zpb_task_param_id_seq.NEXTVAL INTO task_param_id FROM DUAL;

    ac_task_param_rec.task_id := task_id;
    ac_task_param_rec.param_id := task_param_id;
    ac_task_param_rec.name := name;
    ac_task_param_rec.value := value;
    ac_task_param_rec.CREATED_BY         := p_apps_user_id;
    ac_task_param_rec.CREATION_DATE      := SYSDATE;
    ac_task_param_rec.LAST_UPDATED_BY    := p_apps_user_id;
    ac_task_param_rec.LAST_UPDATE_DATE   := SYSDATE;
    ac_task_param_rec.LAST_UPDATE_LOGIN  := p_apps_user_id;
    INSERT INTO zpb_task_parameters(NAME,
                    TASK_ID,
                    VALUE,
                    PARAM_ID,
                    LAST_UPDATE_LOGIN,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY)
       VALUES (ac_task_param_rec.NAME,
                    ac_task_param_rec.TASK_ID,
                    ac_task_param_rec.VALUE,
                    ac_task_param_rec.PARAM_ID,
                    ac_task_param_rec.LAST_UPDATE_LOGIN,
                    ac_task_param_rec.LAST_UPDATE_DATE,
                    ac_task_param_rec.LAST_UPDATED_BY,
                    ac_task_param_rec.CREATION_DATE,
                    ac_task_param_rec.CREATED_BY);
end create_task_parameters;
procedure create_cycle_load_task( p_ac_id in number,
                                  p_apps_user_id in number) AS

  load_task_id zpb_analysis_cycle_tasks.task_id%TYPE;
  task_param_id zpb_task_parameters.param_id%TYPE;
  ac_task_rec zpb_analysis_cycle_tasks%rowtype;
begin

    SELECT zpb_task_id_seq.NEXTVAL INTO load_task_id from dual;

    ac_task_rec.analysis_cycle_id := p_ac_id;
    ac_task_rec.task_id := load_task_id;
    ac_task_rec.sequence := 1;
    ac_task_rec.ITEM_TYPE := 'EPBCYCLE';
    ac_task_rec.WF_PROCESS_NAME := 'LOAD_DATA';
    ac_task_rec.TASK_NAME := 'LOAD_DATA';
    ac_task_rec.CREATED_BY           := p_apps_user_id;
    ac_task_rec.CREATION_DATE        := SYSDATE;
    ac_task_rec.LAST_UPDATED_BY      := p_apps_user_id;
    ac_task_rec.LAST_UPDATE_DATE     := SYSDATE;
    ac_task_rec.LAST_UPDATE_LOGIN    := p_apps_user_id;

    INSERT INTO zpb_analysis_cycle_tasks(ANALYSIS_CYCLE_ID,
                   TASK_ID,
                   SEQUENCE,
                   TASK_NAME,
                   STATUS_CODE,
                   ITEM_TYPE,
                   WF_PROCESS_NAME,
                   ITEM_KEY,
                   START_DATE,
                   HIDE_SHOW,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN,
                   OWNER_ID)
       VALUES      (ac_task_rec.ANALYSIS_CYCLE_ID,
                   ac_task_rec.TASK_ID,
                   ac_task_rec.SEQUENCE,
                   ac_task_rec.TASK_NAME,
                   ac_task_rec.STATUS_CODE,
                   ac_task_rec.ITEM_TYPE,
                   ac_task_rec.WF_PROCESS_NAME,
                   ac_task_rec.ITEM_KEY,
                   ac_task_rec.START_DATE,
                   ac_task_rec.HIDE_SHOW,
                   ac_task_rec.CREATION_DATE,
                   ac_task_rec.CREATED_BY,
                   ac_task_rec.LAST_UPDATED_BY,
                   ac_task_rec.LAST_UPDATE_DATE,
                   ac_task_rec.LAST_UPDATE_LOGIN,
                   ac_task_rec.OWNER_ID);


    create_task_parameters(load_task_id, 'DATA_SELECTION_TYPE', 'ALL_LINE_ITEMS_SELECTION_TYPE',p_apps_user_id);
    create_task_parameters(load_task_id, 'DATA_VALIDATION', 'DATA_VALIDATION',p_apps_user_id);
    create_task_parameters(load_task_id, 'LOAD_CHECK_INSIDE_INPUT_LEVELS', 'false',p_apps_user_id);
    create_task_parameters(load_task_id, 'LOAD_CHECK_OUTSIDE_INPUT_LEVELS', 'false',p_apps_user_id);
    create_task_parameters(load_task_id, 'NOTIFICATION_RECIPIENT_TYPE', 'OWNER_OF_AC',p_apps_user_id);
    create_task_parameters(load_task_id, 'OWNER_ID', to_char(p_apps_user_id),p_apps_user_id);

end create_cycle_load_task;


procedure create_cycle_curinst_task( p_ac_id in number,
                                  p_apps_user_id in number) AS

  curinst_task_id zpb_analysis_cycle_tasks.task_id%TYPE;
  task_param_id zpb_task_parameters.param_id%TYPE;
  ac_task_rec zpb_analysis_cycle_tasks%rowtype;
begin

    SELECT zpb_task_id_seq.NEXTVAL INTO curinst_task_id from dual;

    ac_task_rec.analysis_cycle_id := p_ac_id;
    ac_task_rec.task_id := curinst_task_id;
    ac_task_rec.sequence := 2;
    ac_task_rec.ITEM_TYPE := 'EPBCYCLE';
    ac_task_rec.WF_PROCESS_NAME := 'SET_CURRENT_INSTANCE';
    ac_task_rec.TASK_NAME := 'Set Current Process Run';
    ac_task_rec.CREATED_BY           := p_apps_user_id;
    ac_task_rec.CREATION_DATE        := SYSDATE;
    ac_task_rec.LAST_UPDATED_BY      := p_apps_user_id;
    ac_task_rec.LAST_UPDATE_DATE     := SYSDATE;
    ac_task_rec.LAST_UPDATE_LOGIN    := p_apps_user_id;

    INSERT INTO zpb_analysis_cycle_tasks(ANALYSIS_CYCLE_ID,
                   TASK_ID,
                   SEQUENCE,
                   TASK_NAME,
                   STATUS_CODE,
                   ITEM_TYPE,
                   WF_PROCESS_NAME,
                   ITEM_KEY,
                   START_DATE,
                   HIDE_SHOW,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN,
                   OWNER_ID)
       VALUES      (ac_task_rec.ANALYSIS_CYCLE_ID,
                   ac_task_rec.TASK_ID,
                   ac_task_rec.SEQUENCE,
                   ac_task_rec.TASK_NAME,
                   ac_task_rec.STATUS_CODE,
                   ac_task_rec.ITEM_TYPE,
                   ac_task_rec.WF_PROCESS_NAME,
                   ac_task_rec.ITEM_KEY,
                   ac_task_rec.START_DATE,
                   ac_task_rec.HIDE_SHOW,
                   ac_task_rec.CREATION_DATE,
                   ac_task_rec.CREATED_BY,
                   ac_task_rec.LAST_UPDATED_BY,
                   ac_task_rec.LAST_UPDATE_DATE,
                   ac_task_rec.LAST_UPDATE_LOGIN,
                   ac_task_rec.OWNER_ID);
    create_task_parameters(curinst_task_id, 'NOTIFICATION_RECIPIENT_TYPE', 'OWNER_OF_AC',p_apps_user_id);
    create_task_parameters(curinst_task_id, 'OWNER_ID', to_char(p_apps_user_id),p_apps_user_id);

end create_cycle_curinst_task;

procedure create_migrate_inst(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2 ,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_apps_user_id         in NUMBER,
  p_analysis_cycle_id    in NUMBER,
  p_view_name            in varchar2,
  p_calendar_start_member in varchar2,
  p_calendar_end_member  in varchar2,
  p_dataset              in varchar2,
  p_current_instance     in varchar2) AS

  l_api_name      CONSTANT VARCHAR2(30) := 'create_migrate_inst';
  l_api_version   CONSTANT NUMBER       := 1.0;
  instance_rec       zpb_analysis_cycle_instances%ROWTYPE;
  new_ac_id          zpb_analysis_cycles.analysis_cycle_id%TYPE;
  invalid_calendar_start_member  exception;
  invalid_calendar_end_member    exception;
begin

  -- Standard Start of API savepoint
   SAVEPOINT create_migrate_inst;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
   THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT zpb_analysis_cycle_id_seq.NEXTVAL INTO new_ac_id FROM DUAL;

   copy_ac_table_rec(p_analysis_cycle_id, new_ac_id);
   copy_cycle_model_dim_recs(p_analysis_cycle_id, new_ac_id);

   update zpb_cycle_model_dimensions set last_updated_by = p_apps_user_id,
                                  created_by = p_apps_user_id,
                                  last_update_login = p_apps_user_id
                     where analysis_cycle_id = new_ac_id;

   update zpb_analysis_cycles set status_code = 'PUBLISHED',
                                  validate_status = 'VALID',
                                  last_updated_by = p_apps_user_id,
                                  created_by = p_apps_user_id,
                                  last_update_login = p_apps_user_id
                     where analysis_cycle_id = new_ac_id;

   create_ac_param_values(new_ac_id,4,'FIXED_TIME',p_apps_user_id);

   if p_calendar_start_member  is not null then
    create_ac_param_values(new_ac_id,5,p_calendar_start_member,p_apps_user_id);
   else
    raise invalid_calendar_start_member;
   end if;

   create_ac_param_values(new_ac_id,11,'FIXED_TIME',p_apps_user_id);
   create_ac_param_values(new_ac_id,25,'1',p_apps_user_id);

   if p_calendar_end_member  is not null then
    create_ac_param_values(new_ac_id,12,p_calendar_end_member,p_apps_user_id);
   else
    raise invalid_calendar_end_member;
   end if;

   create_ac_param_values(new_ac_id,28,'Y',p_apps_user_id);
   -- note the dependency on the new dataset table
   create_datasets(new_ac_id,p_dataset,p_apps_user_id);

   instance_rec.analysis_cycle_id    := p_analysis_cycle_id;
   instance_rec.instance_ac_id       := new_ac_id;
   instance_rec.instance_description := p_view_name;
   instance_rec.CREATED_BY           := p_apps_user_id;
   instance_rec.CREATION_DATE        := SYSDATE;
   instance_rec.LAST_UPDATED_BY      := p_apps_user_id;
   instance_rec.LAST_UPDATE_DATE     := SYSDATE;
   instance_rec.LAST_UPDATE_LOGIN    := p_apps_user_id;

   INSERT INTO zpb_analysis_cycle_instances(ANALYSIS_CYCLE_ID,
                    INSTANCE_AC_ID,
                    INSTANCE_DESCRIPTION,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATE_LOGIN,
                    STATUS_CODE)
     VALUES (instance_rec.ANALYSIS_CYCLE_ID,
                    instance_rec.INSTANCE_AC_ID,
                    instance_rec.INSTANCE_DESCRIPTION,
                    instance_rec.CREATION_DATE,
                    instance_rec.CREATED_BY,
                    instance_rec.LAST_UPDATED_BY,
                    instance_rec.LAST_UPDATE_DATE,
                    instance_rec.LAST_UPDATE_LOGIN,
                    instance_rec.STATUS_CODE);

   create_cycle_load_task(new_ac_id,p_apps_user_id);

   if p_current_instance = 'Y' then
     create_cycle_curinst_task(new_ac_id,p_apps_user_id);
   end if;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
  );

 EXCEPTION
WHEN invalid_calendar_start_member then
    ROLLBACK TO create_migrate_inst;
    x_msg_count := 1;
    x_msg_data := 'Invalid calendar start member';
    x_return_status := FND_API.G_RET_STS_ERROR;
WHEN invalid_calendar_end_member then
    ROLLBACK TO create_migrate_inst;
    x_msg_count := 1;
    x_msg_data := 'Invalid calendar end member';
    x_return_status := FND_API.G_RET_STS_ERROR;
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_migrate_inst;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_migrate_inst;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO create_migrate_inst;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
end create_migrate_inst;

--
-- The procedure is called to create hierarchy order for an analysis cycle.
--
PROCEDURE Create_Hier_Order
(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 :=  FND_API.G_FALSE,
  p_validation_level     IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_analysis_cycle_id    IN NUMBER
)

AS
  l_api_name    CONSTANT  VARCHAR2(30) := 'Create_Hier_Order';
  l_api_version CONSTANT  NUMBER       := 1.0;

  l_solve_hier_order_id   NUMBER;
  l_dimension             VARCHAR2(50);
  l_hierarchy             VARCHAR2(50);
  l_last_order            NUMBER;
  l_order_num             NUMBER;
  l_prev_dim              VARCHAR2(50);
  l_new_dim               VARCHAR2(50);
  l_hierarchy_exists      NUMBER;
  l_user_id               NUMBER;
  l_login_id              NUMBER;
  l_first_last_flag       VARCHAR2(1);
  l_first_flag            VARCHAR2(1);
  l_last_flag             VARCHAR2(1);
  l_object_version_number NUMBER;
  l_hier_count            NUMBER;

  -- This cursor will get all the distinct Dim-Hier pairs having more that one
  -- output selection from table: zpb_solve_output_selections
  CURSOR l_get_hierarchies_csr IS
  SELECT DISTINCT b.dimension,
         b.hierarchy
  FROM zpb_solve_output_selections b,
       zpb_lab_hierarchies_v lab
  WHERE b.analysis_cycle_id = p_analysis_cycle_id
  AND b.hierarchy = lab.object_aw_name
  AND b.dimension = lab.dimension
  AND EXISTS
      (SELECT a.dimension,
              a.member,
              COUNT(a.hierarchy)
       FROM zpb_solve_output_selections a
       WHERE a.analysis_cycle_id = p_analysis_cycle_id
       AND a.dimension = b.dimension
       GROUP BY a.dimension, a.member
       HAVING COUNT(a.hierarchy) > l_hier_count )
  ORDER BY b.dimension, b.hierarchy;

  -- This cursor will return 1 if the "ac_id - dim - hier" combination already
  -- exists in the table: zpb_solve_hier_order
  CURSOR l_hierarchy_exists_csr IS
  SELECT 1 hier_exists
  FROM zpb_solve_hier_order
  WHERE analysis_cycle_id = p_analysis_cycle_id
  AND dimension = l_dimension
  AND hierarchy = l_hierarchy;

  -- This cursor will return the last used hier order for a "ac_id - Dim"
  -- combination in the table: zpb_solve_hier_order
  CURSOR l_get_last_order_csr is
  SELECT NVL(MAX(hierarchy_order),-1) max_order
  FROM zpb_solve_hier_order
  WHERE analysis_cycle_id = p_analysis_cycle_id
  AND dimension = l_dimension;

  -- This cursor is used to cleanup the table: zpb_solve_hier_order
  -- by setting the first_last_flag correctly
  CURSOR l_final_csr IS
  SELECT dimension,
         MAX(hierarchy_order) max,
         MIN(hierarchy_order) min,
         COUNT(hierarchy) count
  FROM zpb_solve_hier_order
  WHERE analysis_cycle_id = p_analysis_cycle_id
  GROUP BY dimension;

BEGIN

  SAVEPOINT Create_Hier_Order;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_user_id  := fnd_global.user_id;
  l_login_id := fnd_global.user_id;
  l_object_version_number := 1;
  l_hier_count := 1;
  l_first_last_flag := null;

  -- set the first_last_flag to null initially, this cloumn will be updated
  -- again at the end of this function.
  UPDATE zpb_solve_hier_order
  SET first_last_flag = l_first_last_flag
  WHERE analysis_cycle_id = p_analysis_cycle_id;

  -- set the previous dimension variable to -1 initially
  l_prev_dim := '-1';

  FOR l_get_hierarchies_rec IN l_get_hierarchies_csr
  LOOP
    l_dimension := l_get_hierarchies_rec.dimension;
    l_hierarchy := l_get_hierarchies_rec.hierarchy;

    -- set the new dimension variable
    l_new_dim := l_dimension;

    -- check whether "ac_id - dim - hier" combination already exists.
    -- Value of l_hierarchy_exists = 0 if it does not exist
    -- Value of l_hierarchy_exists = 1 if it does exist
    l_hierarchy_exists := 0;

    FOR l_hierarchy_exists_rec IN l_hierarchy_exists_csr
    LOOP
      l_hierarchy_exists := l_hierarchy_exists_rec.hier_exists;
    END LOOP;

    -- insert the hierarchy in table: ZPB_SOLVE_HIER_ORDER only if it does not
    -- exist already in the table
    IF l_hierarchy_exists = 0
    THEN
      SELECT zpb_solve_hier_order_s.nextval INTO l_solve_hier_order_id
      FROM dual;

      IF l_new_dim <> l_prev_dim
      THEN
        l_order_num := 0;
        l_last_order:= 0;

        FOR l_get_last_order_rec in l_get_last_order_csr
        LOOP
          l_last_order := l_get_last_order_rec.max_order;
        END LOOP;

        IF l_last_order = -1
        THEN
          l_order_num := 1;
        ELSE
          l_order_num := l_last_order + 1;
        END IF;

        l_prev_dim := l_new_dim;
      ELSE
        l_order_num := l_order_num + 1;
      END IF;  -- if l_new_dim <> l_prev_dim then

      INSERT INTO ZPB_SOLVE_HIER_ORDER
      (SOLVE_HIER_ORDER_ID
      ,ANALYSIS_CYCLE_ID
      ,DIMENSION
      ,HIERARCHY
      ,HIERARCHY_ORDER
      ,FIRST_LAST_FLAG
      ,OBJECT_VERSION_NUMBER
      ,LAST_UPDATE_LOGIN
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY)
      VALUES
      (l_solve_hier_order_id
      ,p_analysis_cycle_id
      ,l_dimension
      ,l_hierarchy
      ,l_order_num
      ,l_first_last_flag
      ,l_object_version_number
      ,l_login_id
      ,sysdate
      ,l_user_id
      ,sysdate
      ,l_user_id);

    END IF;  -- if l_hierarchy_exists = 0 then
  END LOOP;  -- for l_get_hierarchies_rec in l_get_hierarchies_csr loop

  -- Sync the o/p selections table with zpb_solve_hier_order table by deleting
  -- those hierarchies in zpb_solve_hier_order for which Hierarchy Order is
  -- not applicable
  DELETE FROM zpb_solve_hier_order
  WHERE analysis_cycle_id = p_analysis_cycle_id
  AND hierarchy NOT IN
      (SELECT b.hierarchy
       FROM zpb_solve_output_selections b,
            zpb_lab_hierarchies_v lab
       WHERE b.analysis_cycle_id = p_analysis_cycle_id
       AND b.hierarchy = lab.object_aw_name
       AND b.dimension = lab.dimension
       AND EXISTS
           (SELECT a.dimension,
                   a.member,
                    COUNT(a.hierarchy)
            FROM zpb_solve_output_selections a
            WHERE a.analysis_cycle_id = p_analysis_cycle_id
            AND a.dimension = b.dimension
            GROUP BY a.dimension, a.member
            HAVING COUNT(a.hierarchy) > l_hier_count
           )
        );

  -- get the minimum and maximum order number for every "ac_id - dim"
  -- combination.
  -- update first_last_flag of the min. order num with 'F'
  -- update first_last_flag of the max. order num with 'L'
  l_first_flag := 'F';
  l_last_flag  := 'L';

  FOR l_final_rec in l_final_csr
  LOOP
    UPDATE zpb_solve_hier_order
    SET first_last_flag = l_first_flag
    WHERE analysis_cycle_id = p_analysis_cycle_id
    AND dimension = l_final_rec.dimension
    AND hierarchy_order = l_final_rec.min;

    UPDATE zpb_solve_hier_order
    SET first_last_flag = l_last_flag
    WHERE analysis_cycle_id = p_analysis_cycle_id
    AND dimension = l_final_rec.dimension
    AND hierarchy_order = l_final_rec.max;
  END LOOP;  -- for l_final_rec in l_final_csr loop

  IF p_commit = FND_API.G_TRUE
  THEN
    COMMIT;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
    NULL;
    ROLLBACK TO Create_Hier_Order;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Create_Hier_Order;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );

  WHEN OTHERS
  THEN
    ROLLBACK TO Create_Hier_Order;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'
      || substr(sqlerrm,1,90));
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
END Create_Hier_Order;

--
-- This procedure is to retrieve instance_id based on the value of APPEND_VIEW
-- parameter value.
--
-- added for bug 5436923
PROCEDURE Get_VM_instance_id
(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_ac_id_in             IN  zpb_analysis_cycles.analysis_cycle_id%TYPE,
  x_vm_instance_id       OUT NOCOPY NUMBER
)
IS
  l_api_name    CONSTANT  VARCHAR2(30) := 'Get_VM_instance_id';
  l_api_version CONSTANT  NUMBER       := 1.0;

  l_param_value ZPB_AC_PARAM_VALUES.VALUE%TYPE;

BEGIN

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT value
  INTO   l_param_value
  FROM   ZPB_AC_PARAM_VALUES
  WHERE  analysis_cycle_id = p_ac_id_in
  AND    param_id =
         (SELECT tag
          FROM   fnd_lookup_values_vl
          WHERE  LOOKUP_TYPE = 'ZPB_PARAMS'
          AND    LOOKUP_CODE = 'APPEND_VIEW');

  IF (l_param_value= 'APPEND_VIEW')
  THEN
    SELECT CURRENT_INSTANCE_ID
    INTO   x_vm_instance_id
    FROM   ZPB_ANALYSIS_CYCLES
    WHERE  ANALYSIS_CYCLE_ID = p_ac_id_in;
  ELSE
    x_vm_instance_id := p_ac_id_in;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );

  WHEN others
  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    zpb_log.write_event(G_PKG_NAME||'.'||l_api_name,to_char(sqlcode) ||':'
      || substr(sqlerrm,1,90));
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );

END Get_VM_instance_id;


END ZPB_AC_OPS;

/
