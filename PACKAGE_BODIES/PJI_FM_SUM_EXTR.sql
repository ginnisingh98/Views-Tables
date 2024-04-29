--------------------------------------------------------
--  DDL for Package Body PJI_FM_SUM_EXTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_SUM_EXTR" as
  /* $Header: PJISF02B.pls 120.9.12010000.7 2010/02/24 12:12:09 rmandali ship $ */

  -- -----------------------------------------------------
  -- procedure POPULATE_TIME_DIMENSION
  -- -----------------------------------------------------
  procedure POPULATE_TIME_DIMENSION (p_worker_id in number) is

    l_process varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.POPULATE_TIME_DIMENSION(p_worker_id);')) then
      return;
    end if;

    PJI_TIME_C.LOAD(null, null, l_return_status, l_msg_count, l_msg_data);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.POPULATE_TIME_DIMENSION(p_worker_id);');

    commit;

  end POPULATE_TIME_DIMENSION;


  -- -----------------------------------------------------
  -- procedure ORG_EXTR_INFO_TABLE
  -- -----------------------------------------------------
  procedure ORG_EXTR_INFO_TABLE (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.ORG_EXTR_INFO_TABLE(p_worker_id);')) then
      return;
    end if;

    PJI_EXTRACTION_UTIL.UPDATE_ORG_EXTR_INFO;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.ORG_EXTR_INFO_TABLE(p_worker_id);');

    -- implicit commit
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_ORG_EXTR_INFO',
                                 percent => 10,
                                 degree  => PJI_UTILS.
                                            GET_DEGREE_OF_PARALLELISM);
    -- implicit commit
    FND_STATS.GATHER_INDEX_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 indname => 'PJI_ORG_EXTR_INFO_N1',
                                 percent => 10);

    commit;

  end ORG_EXTR_INFO_TABLE;


  -- -----------------------------------------------------
  -- procedure CURR_CONV_TABLE
  -- -----------------------------------------------------
  procedure CURR_CONV_TABLE (p_worker_id in number) is

    l_process varchar2(30);
    l_extract_commitments varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.CURR_CONV_TABLE(p_worker_id);')) then
      return;
    end if;

    l_extract_commitments := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                             (PJI_FM_SUM_MAIN.g_process,
                              'EXTRACT_COMMITMENTS');

    insert /*+ append */ into PJI_FM_AGGR_DLY_RATES
    (
      WORKER_ID,
      PF_CURRENCY_CODE,
      TIME_ID,
      RATE,
      MAU,
      RATE2,
      MAU2
    )
    select /*+ ordered
               full(tmp)
               full(rates) use_hash(rates) parallel(rates) */
      -1 WORKER_ID,
      tmp.PF_CURRENCY_CODE,
      tmp.TIME_ID,
      tmp.RATE,
      tmp.MAU,
      tmp.RATE2,
      tmp.MAU2
    from
    (
    select         -- for rows that have resource data only
      p_worker_id WORKER_ID,
      'PJI$NULL'  PF_CURRENCY_CODE,
      -1          TIME_ID,
      0           RATE,
      0           MAU,
      0           RATE2,
      0           MAU2
    from
      dual
    union all
    select
      p_worker_id                                         WORKER_ID,
      PF_CURRENCY_CODE                                    PF_CURRENCY_CODE,
      TIME_ID                                             TIME_ID,
      PJI_UTILS.GET_GLOBAL_RATE_PRIMARY(PF_CURRENCY_CODE,
                          to_date(to_char(TIME_ID), 'J')) RATE,
      PJI_UTILS.GET_MAU_PRIMARY                           MAU,
      PJI_UTILS.GET_GLOBAL_RATE_SECONDARY(PF_CURRENCY_CODE,
                          to_date(to_char(TIME_ID), 'J')) RATE2,
      PJI_UTILS.GET_MAU_SECONDARY                         MAU2
    from
      (
      select /*+ ordered
                 full(tmp1)     use_hash(tmp1)       parallel(tmp1)
                 full(prj_info) use_hash(prj_info)   swap_join_inputs(prj_info)
                 full(res_info) use_hash(res_info)   swap_join_inputs(res_info)
              */ -- bug 3092751: Changes in hints
        distinct
        decode(invert.INVERT_ID,
               'PRVDR_GL', to_number(to_char(tmp1.PRVDR_GL_DATE, 'J')),
               'RECVR_GL', to_number(to_char(tmp1.RECVR_GL_DATE, 'J')),
               'PRVDR_PA', to_number(to_char(tmp1.PRVDR_PA_DATE, 'J')),
               'RECVR_PA', to_number(to_char(tmp1.RECVR_PA_DATE, 'J')),
               'EXP',      to_number(to_char(tmp1.EXPENDITURE_ITEM_DATE, 'J')))
                                                          TIME_ID,
        decode(invert.INVERT_ID,
               'PRVDR_GL', res_info.PF_CURRENCY_CODE,
               'RECVR_GL', prj_info.PF_CURRENCY_CODE,
               'PRVDR_PA', res_info.PF_CURRENCY_CODE,
               'RECVR_PA', prj_info.PF_CURRENCY_CODE,
               'EXP',      res_info.PF_CURRENCY_CODE)     PF_CURRENCY_CODE
      from -- bug 3092751: Changes in table order
        PJI_ORG_EXTR_INFO     prj_info,
        (
        select /*+ full(tmp1) parallel(tmp1) */
          distinct
          PROJECT_ID,
          PROJECT_ORG_ID,
          EXPENDITURE_ORG_ID,
          PRVDR_GL_DATE,
          RECVR_GL_DATE,
          PRVDR_PA_DATE,
          RECVR_PA_DATE,
          EXPENDITURE_ITEM_DATE
        from
          PJI_FM_AGGR_FIN1 tmp1
        where
          WORKER_ID = p_worker_id
        ) tmp1,
        PJI_ORG_EXTR_INFO     res_info,
        (
          select 'PRVDR_GL' INVERT_ID from dual union all
          select 'RECVR_GL' INVERT_ID from dual union all
          select 'PRVDR_PA' INVERT_ID from dual union all
          select 'RECVR_PA' INVERT_ID from dual union all
          select 'EXP'      INVERT_ID from dual
        ) invert
      where
        tmp1.PROJECT_ORG_ID     = prj_info.ORG_ID and
        tmp1.EXPENDITURE_ORG_ID = res_info.ORG_ID
      union
      select /*+ ordered
                 full(tmp2)     use_hash(tmp2)       parallel(tmp2)
                 full(map)      use_hash(map)        parallel(map)
                 full(prj_info) use_hash(prj_info)   swap_join_inputs(prj_info)
                 full(res_info) use_hash(res_info)   swap_join_inputs(res_info)
              */ -- bug 3092751: Changes in hints
        distinct
        decode(invert.INVERT_ID,
               'PRVDR_GL', tmp2.PRVDR_GL_TIME_ID,
               'RECVR_GL', tmp2.RECVR_GL_TIME_ID,
               'PRVDR_PA', tmp2.PRVDR_PA_TIME_ID,
               'RECVR_PA', tmp2.RECVR_PA_TIME_ID,
               'EXP',      tmp2.EXPENDITURE_ITEM_TIME_ID)       TIME_ID,
        decode(invert.INVERT_ID,
               'PRVDR_GL', res_info.PF_CURRENCY_CODE,
               'RECVR_GL', prj_info.PF_CURRENCY_CODE,
               'PRVDR_PA', res_info.PF_CURRENCY_CODE,
               'RECVR_PA', prj_info.PF_CURRENCY_CODE,
               'EXP',      res_info.PF_CURRENCY_CODE)     PF_CURRENCY_CODE
      from  -- bug 3092751: changes in table order
        PJI_ORG_EXTR_INFO     prj_info,
        PJI_FM_PROJ_BATCH_MAP map,
        (
        select /*+ full(tmp2) parallel(tmp2) */
          distinct
          PROJECT_ID,
          EXPENDITURE_ORG_ID,
          PRVDR_GL_TIME_ID,
          RECVR_GL_TIME_ID,
          PRVDR_PA_TIME_ID,
          RECVR_PA_TIME_ID,
          EXPENDITURE_ITEM_TIME_ID
        from
          PJI_FM_DNGL_FIN tmp2
        where
          WORKER_ID = 0 and
          RECORD_TYPE = 'A'
        ) tmp2,
        PJI_ORG_EXTR_INFO     res_info,
        (
          select 'PRVDR_GL' INVERT_ID from dual union all
          select 'RECVR_GL' INVERT_ID from dual union all
          select 'PRVDR_PA' INVERT_ID from dual union all
          select 'RECVR_PA' INVERT_ID from dual union all
          select 'EXP'      INVERT_ID from dual
        ) invert
      where
        map.WORKER_ID           = p_worker_id     and
        map.PROJECT_ID          = tmp2.PROJECT_ID and
        map.PROJECT_ORG_ID      = prj_info.ORG_ID and
        tmp2.EXPENDITURE_ORG_ID = res_info.ORG_ID
      union
      select /*+ ordered
                 full(tmp1)     use_hash(tmp1)       parallel(tmp1)
                 full(prj_info) use_hash(prj_info)   swap_join_inputs(prj_info)
              */  -- bug 3092751: changes in hints
        distinct
        decode(invert.INVERT_ID,
               'GL', tmp1.GL_TIME_ID,
               'PA', tmp1.PA_TIME_ID)                     TIME_ID,
        prj_info.PF_CURRENCY_CODE
      from  -- bug 3092751: changes in table order
        PJI_ORG_EXTR_INFO     prj_info,
        (
        select /*+ parallel(tmp1) full(tmp1) */
          distinct
          PROJECT_ID,
          PROJECT_ORG_ID,
          GL_TIME_ID,
          PA_TIME_ID
        from
          PJI_FM_AGGR_ACT1 tmp1
        where
          WORKER_ID = p_worker_id
        ) tmp1,
        (
          select 'GL' INVERT_ID from dual union all
          select 'PA' INVERT_ID from dual
        ) invert
      where
        tmp1.PROJECT_ORG_ID = prj_info.ORG_ID
      union
      select /*+ ordered
                 full(tmp2)     use_hash(tmp2)      parallel(tmp2)
                 full(map)      use_hash(map)       parallel(map)
                 full(prj_info) use_hash(prj_info)  swap_join_inputs(prj_info)
              */  -- bug 3092751: changes in hints
        distinct
        decode(invert.INVERT_ID,
               'GL', tmp2.GL_TIME_ID,
               'PA', tmp2.PA_TIME_ID)                     TIME_ID,
        prj_info.PF_CURRENCY_CODE
      from  -- bug 3092751: changes in table order
        PJI_ORG_EXTR_INFO     prj_info,
        PJI_FM_PROJ_BATCH_MAP map,
        (
        select /*+ parallel(tmp2) full(tmp2) */
          distinct
          PROJECT_ID,
          GL_TIME_ID,
          PA_TIME_ID
        from
          PJI_FM_DNGL_ACT tmp2
        where
          WORKER_ID = 0
        ) tmp2,
        (
          select 'GL' INVERT_ID from dual union all
          select 'PA' INVERT_ID from dual
        ) invert
      where
        map.WORKER_ID      = p_worker_id     and
        map.PROJECT_ID     = tmp2.PROJECT_ID and
        map.PROJECT_ORG_ID = prj_info.ORG_ID
      union      -- commitments data
      select /*+ ordered
                 full(tmp2)     use_hash(tmp2)      parallel(tmp2)
                 full(map)      use_hash(map)       parallel(map)
                 full(prj_info) use_hash(prj_info)  swap_join_inputs(prj_info)
              */
        distinct
        decode(invert.INVERT_ID,
               'GL', tmp2.GL_TIME_ID,
               'PA', tmp2.PA_TIME_ID)                     TIME_ID,
        prj_info.PF_CURRENCY_CODE
      from
        PJI_ORG_EXTR_INFO     prj_info,
        PJI_FM_PROJ_BATCH_MAP map,
        /*  commented and changed as below for bug 6894858
        (
        select /*+ parallel(cmt) full(cmt)
          distinct
          cmt.PROJECT_ID,
          to_number(to_char(nvl(cmt.CMT_PROMISED_DATE,
                                nvl(cmt.CMT_NEED_BY_DATE,
                                    cmt.EXPENDITURE_ITEM_DATE)),
                    'J')) GL_TIME_ID,
          to_number(to_char(nvl(cmt.CMT_PROMISED_DATE,
                                nvl(cmt.CMT_NEED_BY_DATE,
                                    cmt.EXPENDITURE_ITEM_DATE)),
                    'J')) PA_TIME_ID
        from
          PA_COMMITMENT_TXNS cmt
        where
          l_extract_commitments = 'Y'
        ) tmp2,
        (
          select 'GL' INVERT_ID from dual union all
          select 'PA' INVERT_ID from dual
        ) invert
      where
        l_extract_commitments = 'Y'             and
        map.WORKER_ID         = p_worker_id     and
        map.PROJECT_ID        = tmp2.PROJECT_ID and
        map.PROJECT_ORG_ID    = prj_info.ORG_ID
      )*/
      (
        select
          to_number(to_char(trunc(sysdate),
                    'J')) GL_TIME_ID,
          to_number(to_char(trunc(sysdate),
                    'J')) PA_TIME_ID
        from
          dual
        ) tmp2,
        (
          select 'GL' INVERT_ID from dual union all
          select 'PA' INVERT_ID from dual
        ) invert
      where
        l_extract_commitments = 'Y'             and
        map.WORKER_ID         = p_worker_id     and
        --map.PROJECT_ID        = tmp2.PROJECT_ID and --6894858
        map.PROJECT_ORG_ID    = prj_info.ORG_ID
      )
    ) tmp,
      PJI_FM_AGGR_DLY_RATES rates
    where
      -1                   = rates.WORKER_ID        (+) and
      tmp.PF_CURRENCY_CODE = rates.PF_CURRENCY_CODE (+) and
      tmp.TIME_ID          = rates.TIME_ID          (+) and
      rates.WORKER_ID      is null;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.CURR_CONV_TABLE(p_worker_id);');

    commit;

  end CURR_CONV_TABLE;


  -- -----------------------------------------------------
  -- procedure DANGLING_FIN_ROWS
  -- -----------------------------------------------------
  procedure DANGLING_FIN_ROWS (p_worker_id in number) is

    l_process           varchar2(30);

    l_txn_currency_flag varchar2(1);
    l_g2_currency_flag  varchar2(1);
    l_g1_currency_code  varchar2(30);
    l_g2_currency_code  varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.DANGLING_FIN_ROWS(p_worker_id);')) then
      return;
    end if;

    select
      TXN_CURR_FLAG,
      GLOBAL_CURR2_FLAG
    into
      l_txn_currency_flag,
      l_g2_currency_flag
    from
      PJI_SYSTEM_SETTINGS;

    l_g1_currency_code := PJI_UTILS.GET_GLOBAL_PRIMARY_CURRENCY;
    l_g2_currency_code := PJI_UTILS.GET_GLOBAL_SECONDARY_CURRENCY;

    insert /*+ noappend parallel(fin2_i) */ into PJI_FM_AGGR_FIN2 fin2_i -- in DANGLING_FIN_ROWS
    ( --Bug 7139059
      WORKER_ID,
      DANGLING_RECVR_GL_RATE_FLAG,
      DANGLING_RECVR_GL_RATE2_FLAG,
      DANGLING_RECVR_PA_RATE_FLAG,
      DANGLING_RECVR_PA_RATE2_FLAG,
      DANGLING_PRVDR_EN_TIME_FLAG,
      DANGLING_RECVR_EN_TIME_FLAG,
      DANGLING_EXP_EN_TIME_FLAG,
      DANGLING_PRVDR_GL_TIME_FLAG,
      DANGLING_RECVR_GL_TIME_FLAG,
      DANGLING_EXP_GL_TIME_FLAG,
      DANGLING_PRVDR_PA_TIME_FLAG,
      DANGLING_RECVR_PA_TIME_FLAG,
      DANGLING_EXP_PA_TIME_FLAG,
      ROW_ID,
      PJI_PROJECT_RECORD_FLAG,
      PJI_RESOURCE_RECORD_FLAG,
      RECORD_TYPE,
      CMT_RECORD_TYPE,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      EXP_EVT_TYPE_ID,
      WORK_TYPE_ID,
      JOB_ID,
      TASK_ID,
      VENDOR_ID,
      EXPENDITURE_TYPE,
      EVENT_TYPE,
      EVENT_TYPE_CLASSIFICATION,
      EXPENDITURE_CATEGORY,
      REVENUE_CATEGORY,
      NON_LABOR_RESOURCE,
      BOM_LABOR_RESOURCE_ID,
      BOM_EQUIPMENT_RESOURCE_ID,
      INVENTORY_ITEM_ID,
      PO_LINE_ID,
      ASSIGNMENT_ID,
      SYSTEM_LINKAGE_FUNCTION,
      RESOURCE_CLASS_CODE,
      RECVR_GL_TIME_ID,
      GL_PERIOD_NAME,
      PRVDR_GL_TIME_ID,
      RECVR_PA_TIME_ID,
      PA_PERIOD_NAME,
      PRVDR_PA_TIME_ID,
      EXPENDITURE_ITEM_TIME_ID,
      PJ_GL_CALENDAR_ID,
      PJ_PA_CALENDAR_ID,
      RS_GL_CALENDAR_ID,
      RS_PA_CALENDAR_ID,
      PRJ_REVENUE,
      PRJ_LABOR_REVENUE,
      PRJ_REVENUE_WRITEOFF,
      PRJ_RAW_COST,
      PRJ_BRDN_COST,
      PRJ_BILL_RAW_COST,
      PRJ_BILL_BRDN_COST,
      PRJ_LABOR_RAW_COST,
      PRJ_LABOR_BRDN_COST,
      PRJ_BILL_LABOR_RAW_COST,
      PRJ_BILL_LABOR_BRDN_COST,
      POU_REVENUE,
      POU_LABOR_REVENUE,
      POU_REVENUE_WRITEOFF,
      POU_RAW_COST,
      POU_BRDN_COST,
      POU_BILL_RAW_COST,
      POU_BILL_BRDN_COST,
      POU_LABOR_RAW_COST,
      POU_LABOR_BRDN_COST,
      POU_BILL_LABOR_RAW_COST,
      POU_BILL_LABOR_BRDN_COST,
      EOU_RAW_COST,
      EOU_BRDN_COST,
      EOU_BILL_RAW_COST,
      EOU_BILL_BRDN_COST,
      TXN_CURRENCY_CODE,
      TXN_REVENUE,
      TXN_RAW_COST,
      TXN_BRDN_COST,
      TXN_BILL_RAW_COST,
      TXN_BILL_BRDN_COST,
      LABOR_HRS,
      BILL_LABOR_HRS,
      GG1_REVENUE,
      GG1_LABOR_REVENUE,
      GG1_REVENUE_WRITEOFF,
      GG1_RAW_COST,
      GG1_BRDN_COST,
      GG1_BILL_RAW_COST,
      GG1_BILL_BRDN_COST,
      GG1_LABOR_RAW_COST,
      GG1_LABOR_BRDN_COST,
      GG1_BILL_LABOR_RAW_COST,
      GG1_BILL_LABOR_BRDN_COST,
      GP1_REVENUE,
      GP1_LABOR_REVENUE,
      GP1_REVENUE_WRITEOFF,
      GP1_RAW_COST,
      GP1_BRDN_COST,
      GP1_BILL_RAW_COST,
      GP1_BILL_BRDN_COST,
      GP1_LABOR_RAW_COST,
      GP1_LABOR_BRDN_COST,
      GP1_BILL_LABOR_RAW_COST,
      GP1_BILL_LABOR_BRDN_COST,
      GG2_REVENUE,
      GG2_LABOR_REVENUE,
      GG2_REVENUE_WRITEOFF,
      GG2_RAW_COST,
      GG2_BRDN_COST,
      GG2_BILL_RAW_COST,
      GG2_BILL_BRDN_COST,
      GG2_LABOR_RAW_COST,
      GG2_LABOR_BRDN_COST,
      GG2_BILL_LABOR_RAW_COST,
      GG2_BILL_LABOR_BRDN_COST,
      GP2_REVENUE,
      GP2_LABOR_REVENUE,
      GP2_REVENUE_WRITEOFF,
      GP2_RAW_COST,
      GP2_BRDN_COST,
      GP2_BILL_RAW_COST,
      GP2_BILL_BRDN_COST,
      GP2_LABOR_RAW_COST,
      GP2_LABOR_BRDN_COST,
      GP2_BILL_LABOR_RAW_COST,
      GP2_BILL_LABOR_BRDN_COST,
      TOTAL_HRS_A,
      BILL_HRS_A
    )
    select
      p_worker_id,
      tmp2.DANGLING_RECVR_GL_RATE_FLAG,
      tmp2.DANGLING_RECVR_GL_RATE2_FLAG,
      tmp2.DANGLING_RECVR_PA_RATE_FLAG,
      tmp2.DANGLING_RECVR_PA_RATE2_FLAG,
      tmp2.DANGLING_PRVDR_EN_TIME_FLAG,
      tmp2.DANGLING_RECVR_EN_TIME_FLAG,
      tmp2.DANGLING_EXP_EN_TIME_FLAG,
      tmp2.DANGLING_PRVDR_GL_TIME_FLAG,
      tmp2.DANGLING_RECVR_GL_TIME_FLAG,
      tmp2.DANGLING_EXP_GL_TIME_FLAG,
      tmp2.DANGLING_PRVDR_PA_TIME_FLAG,
      tmp2.DANGLING_RECVR_PA_TIME_FLAG,
      tmp2.DANGLING_EXP_PA_TIME_FLAG,
      tmp2.ROW_ID,
      tmp2.PJI_PROJECT_RECORD_FLAG,
      tmp2.PJI_RESOURCE_RECORD_FLAG,
      tmp2.RECORD_TYPE,
      tmp2.CMT_RECORD_TYPE,
      tmp2.PROJECT_ID,
      tmp2.PROJECT_ORG_ID,
      tmp2.PROJECT_ORGANIZATION_ID,
      tmp2.PROJECT_TYPE_CLASS,
      tmp2.PERSON_ID,
      tmp2.EXPENDITURE_ORG_ID,
      tmp2.EXPENDITURE_ORGANIZATION_ID,
      tmp2.EXP_EVT_TYPE_ID,
      tmp2.WORK_TYPE_ID,
      tmp2.JOB_ID,
      tmp2.TASK_ID,
      tmp2.VENDOR_ID,
      tmp2.EXPENDITURE_TYPE,
      tmp2.EVENT_TYPE,
      tmp2.EVENT_TYPE_CLASSIFICATION,
      tmp2.EXPENDITURE_CATEGORY,
      tmp2.REVENUE_CATEGORY,
      tmp2.NON_LABOR_RESOURCE,
      tmp2.BOM_LABOR_RESOURCE_ID,
      tmp2.BOM_EQUIPMENT_RESOURCE_ID,
      tmp2.INVENTORY_ITEM_ID,
      tmp2.PO_LINE_ID,
      tmp2.ASSIGNMENT_ID,
      tmp2.SYSTEM_LINKAGE_FUNCTION,
      tmp2.RESOURCE_CLASS_CODE,
      tmp2.RECVR_GL_TIME_ID,
      tmp2.GL_PERIOD_NAME,
      tmp2.PRVDR_GL_TIME_ID,
      tmp2.RECVR_PA_TIME_ID,
      tmp2.PA_PERIOD_NAME,
      tmp2.PRVDR_PA_TIME_ID,
      tmp2.EXPENDITURE_ITEM_TIME_ID,
      tmp2.PJ_GL_CALENDAR_ID,
      tmp2.PJ_PA_CALENDAR_ID,
      tmp2.RS_GL_CALENDAR_ID,
      tmp2.RS_PA_CALENDAR_ID,
      tmp2.PRJ_REVENUE,
      tmp2.PRJ_LABOR_REVENUE,
      tmp2.PRJ_REVENUE_WRITEOFF,
      tmp2.PRJ_RAW_COST,
      tmp2.PRJ_BRDN_COST,
      tmp2.PRJ_BILL_RAW_COST,
      tmp2.PRJ_BILL_BRDN_COST,
      tmp2.PRJ_LABOR_RAW_COST,
      tmp2.PRJ_LABOR_BRDN_COST,
      tmp2.PRJ_BILL_LABOR_RAW_COST,
      tmp2.PRJ_BILL_LABOR_BRDN_COST,
      tmp2.POU_REVENUE,
      tmp2.POU_LABOR_REVENUE,
      tmp2.POU_REVENUE_WRITEOFF,
      tmp2.POU_RAW_COST,
      tmp2.POU_BRDN_COST,
      tmp2.POU_BILL_RAW_COST,
      tmp2.POU_BILL_BRDN_COST,
      tmp2.POU_LABOR_RAW_COST,
      tmp2.POU_LABOR_BRDN_COST,
      tmp2.POU_BILL_LABOR_RAW_COST,
      tmp2.POU_BILL_LABOR_BRDN_COST,
      tmp2.EOU_RAW_COST,
      tmp2.EOU_BRDN_COST,
      tmp2.EOU_BILL_RAW_COST,
      tmp2.EOU_BILL_BRDN_COST,
      tmp2.TXN_CURRENCY_CODE,
      tmp2.TXN_REVENUE,
      tmp2.TXN_RAW_COST,
      tmp2.TXN_BRDN_COST,
      tmp2.TXN_BILL_RAW_COST,
      tmp2.TXN_BILL_BRDN_COST,
      tmp2.LABOR_HRS,
      tmp2.BILL_LABOR_HRS,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g1_currency_code,
                         tmp2.TXN_REVENUE,
                         round(tmp2.POU_REVENUE *
                               tmp2.PRJ_GL_RATE1 /
                               PRJ_GL_MAU1) * PRJ_GL_MAU1),
                  to_number(null))                  GG1_REVENUE,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g1_currency_code,
                  --        tmp2.TXN_LABOR_REVENUE,
                         round(tmp2.POU_LABOR_REVENUE *
                               tmp2.PRJ_GL_RATE1 /
                               PRJ_GL_MAU1) * PRJ_GL_MAU1
                  -- )
                  ,
                  to_number(null))                  GG1_LABOR_REVENUE,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g1_currency_code,
                  --        tmp2.TXN_REVENUE_WRITEOFF,
                         round(tmp2.POU_REVENUE_WRITEOFF *
                               tmp2.PRJ_GL_RATE1 /
                               PRJ_GL_MAU1) * PRJ_GL_MAU1
                  -- )
                  ,
                  to_number(null))                  GG1_REVENUE_WRITEOFF,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g1_currency_code,
                         tmp2.TXN_RAW_COST,
                         round(tmp2.POU_RAW_COST *
                               tmp2.PRJ_GL_RATE1 /
                               PRJ_GL_MAU1) * PRJ_GL_MAU1),
                  to_number(null))                  GG1_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g1_currency_code,
                         tmp2.TXN_BRDN_COST,
                         round(tmp2.POU_BRDN_COST *
                               tmp2.PRJ_GL_RATE1 /
                               PRJ_GL_MAU1) * PRJ_GL_MAU1),
                  to_number(null))                  GG1_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g1_currency_code,
                         tmp2.TXN_BILL_RAW_COST,
                         round(tmp2.POU_BILL_RAW_COST *
                               tmp2.PRJ_GL_RATE1 /
                               PRJ_GL_MAU1) * PRJ_GL_MAU1),
                  to_number(null))                  GG1_BILL_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g1_currency_code,
                         tmp2.TXN_BILL_BRDN_COST,
                         round(tmp2.POU_BILL_BRDN_COST *
                               tmp2.PRJ_GL_RATE1 /
                               PRJ_GL_MAU1) * PRJ_GL_MAU1),
                  to_number(null))                  GG1_BILL_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g1_currency_code,
                  --        tmp2.TXN_LABOR_RAW_COST,
                         round(tmp2.POU_LABOR_RAW_COST *
                               tmp2.PRJ_GL_RATE1 /
                               PRJ_GL_MAU1) * PRJ_GL_MAU1
                  -- )
                  ,
                  to_number(null))                  GG1_LABOR_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g1_currency_code,
                  --        tmp2.TXN_LABOR_BRDN_COST,
                         round(tmp2.POU_LABOR_BRDN_COST *
                               tmp2.PRJ_GL_RATE1 /
                               PRJ_GL_MAU1) * PRJ_GL_MAU1
                  -- )
                  ,
                  to_number(null))                  GG1_LABOR_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g1_currency_code,
                  --        tmp2.TXN_BILL_LABOR_RAW_COST,
                         round(tmp2.POU_BILL_LABOR_RAW_COST *
                               tmp2.PRJ_GL_RATE1 /
                               PRJ_GL_MAU1) * PRJ_GL_MAU1
                  -- )
                  ,
                  to_number(null))                  GG1_BILL_LABOR_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g1_currency_code,
                  --        tmp2.TXN_BILL_LABOR_BRDN_COST,
                         round(tmp2.POU_BILL_LABOR_BRDN_COST *
                               tmp2.PRJ_GL_RATE1 /
                               PRJ_GL_MAU1) * PRJ_GL_MAU1
                  -- )
                  ,
                  to_number(null))                  GG1_BILL_LABOR_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g1_currency_code,
                         tmp2.TXN_REVENUE,
                         round(tmp2.POU_REVENUE *
                               tmp2.PRJ_PA_RATE1 /
                               PRJ_PA_MAU1) * PRJ_PA_MAU1),
                  to_number(null))                  GP1_REVENUE,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g1_currency_code,
                  --        tmp2.TXN_LABOR_REVENUE,
                         round(tmp2.POU_LABOR_REVENUE *
                               tmp2.PRJ_PA_RATE1 /
                               PRJ_PA_MAU1) * PRJ_PA_MAU1
                  -- )
                  ,
                  to_number(null))                  GP1_LABOR_REVENUE,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g1_currency_code,
                  --        tmp2.TXN_REVENUE_WRITEOFF,
                         round(tmp2.POU_REVENUE_WRITEOFF *
                               tmp2.PRJ_PA_RATE1 /
                               PRJ_PA_MAU1) * PRJ_PA_MAU1
                  -- )
                  ,
                  to_number(null))                  GP1_REVENUE_WRITEOFF,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g1_currency_code,
                         tmp2.TXN_RAW_COST,
                         round(tmp2.POU_RAW_COST *
                               tmp2.PRJ_PA_RATE1 /
                               PRJ_PA_MAU1) * PRJ_PA_MAU1),
                  to_number(null))                  GP1_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g1_currency_code,
                         tmp2.TXN_BRDN_COST,
                         round(tmp2.POU_BRDN_COST *
                               tmp2.PRJ_PA_RATE1 /
                               PRJ_PA_MAU1) * PRJ_PA_MAU1),
                  to_number(null))                  GP1_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g1_currency_code,
                         tmp2.TXN_BILL_RAW_COST,
                         round(tmp2.POU_BILL_RAW_COST *
                               tmp2.PRJ_PA_RATE1 /
                               PRJ_PA_MAU1) * PRJ_PA_MAU1),
                  to_number(null))                  GP1_BILL_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g1_currency_code,
                         tmp2.TXN_BILL_BRDN_COST,
                         round(tmp2.POU_BILL_BRDN_COST *
                               tmp2.PRJ_PA_RATE1 /
                               PRJ_PA_MAU1) * PRJ_PA_MAU1),
                  to_number(null))                  GP1_BILL_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g1_currency_code,
                  --        tmp2.TXN_LABOR_RAW_COST,
                         round(tmp2.POU_LABOR_RAW_COST *
                               tmp2.PRJ_PA_RATE1 /
                               PRJ_PA_MAU1) * PRJ_PA_MAU1
                  -- )
                  ,
                  to_number(null))                  GP1_LABOR_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g1_currency_code,
                  --        tmp2.TXN_LABOR_BRDN_COST,
                         round(tmp2.POU_LABOR_BRDN_COST *
                               tmp2.PRJ_PA_RATE1 /
                               PRJ_PA_MAU1) * PRJ_PA_MAU1
                  -- )
                  ,
                  to_number(null))                  GP1_LABOR_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g1_currency_code,
                  --        tmp2.TXN_BILL_LABOR_RAW_COST,
                         round(tmp2.POU_BILL_LABOR_RAW_COST *
                               tmp2.PRJ_PA_RATE1 /
                               PRJ_PA_MAU1) * PRJ_PA_MAU1
                  -- )
                  ,
                  to_number(null))                  GP1_BILL_LABOR_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g1_currency_code,
                  --        tmp2.TXN_BILL_LABOR_BRDN_COST,
                         round(tmp2.POU_BILL_LABOR_BRDN_COST *
                               tmp2.PRJ_PA_RATE1 /
                               PRJ_PA_MAU1) * PRJ_PA_MAU1
                  -- )
                  ,
                  to_number(null))                  GP1_BILL_LABOR_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g2_currency_code,
                         tmp2.TXN_REVENUE,
                         round(tmp2.POU_REVENUE *
                               tmp2.PRJ_GL_RATE2 /
                               PRJ_GL_MAU2) * PRJ_GL_MAU2),
                  to_number(null))                  GG2_REVENUE,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g2_currency_code,
                  --        tmp2.TXN_LABOR_REVENUE,
                         round(tmp2.POU_LABOR_REVENUE *
                               tmp2.PRJ_GL_RATE2 /
                               PRJ_GL_MAU2) * PRJ_GL_MAU2
                  -- )
                  ,
                  to_number(null))                  GG2_LABOR_REVENUE,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g2_currency_code,
                  --        tmp2.TXN_REVENUE_WRITEOFF,
                         round(tmp2.POU_REVENUE_WRITEOFF *
                               tmp2.PRJ_GL_RATE2 /
                               PRJ_GL_MAU2) * PRJ_GL_MAU2
                  -- )
                  ,
                  to_number(null))                  GG2_REVENUE_WRITEOFF,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g2_currency_code,
                         tmp2.TXN_RAW_COST,
                         round(tmp2.POU_RAW_COST *
                               tmp2.PRJ_GL_RATE2 /
                               PRJ_GL_MAU2) * PRJ_GL_MAU2),
                  to_number(null))                  GG2_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g2_currency_code,
                         tmp2.TXN_BRDN_COST,
                         round(tmp2.POU_BRDN_COST *
                               tmp2.PRJ_GL_RATE2 /
                               PRJ_GL_MAU2) * PRJ_GL_MAU2),
                  to_number(null))                  GG2_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g2_currency_code,
                         tmp2.TXN_BILL_RAW_COST,
                         round(tmp2.POU_BILL_RAW_COST *
                               tmp2.PRJ_GL_RATE2 /
                               PRJ_GL_MAU2) * PRJ_GL_MAU2),
                  to_number(null))                  GG2_BILL_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g2_currency_code,
                         tmp2.TXN_BILL_BRDN_COST,
                         round(tmp2.POU_BILL_BRDN_COST *
                               tmp2.PRJ_GL_RATE2 /
                               PRJ_GL_MAU2) * PRJ_GL_MAU2),
                  to_number(null))                  GG2_BILL_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g2_currency_code,
                  --        tmp2.TXN_LABOR_RAW_COST,
                         round(tmp2.POU_LABOR_RAW_COST *
                               tmp2.PRJ_GL_RATE2 /
                               PRJ_GL_MAU2) * PRJ_GL_MAU2
                  -- )
                  ,
                  to_number(null))                  GG2_LABOR_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g2_currency_code,
                  --        tmp2.TXN_LABOR_BRDN_COST,
                         round(tmp2.POU_LABOR_BRDN_COST *
                               tmp2.PRJ_GL_RATE2 /
                               PRJ_GL_MAU2) * PRJ_GL_MAU2
                  -- )
                  ,
                  to_number(null))                  GG2_LABOR_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g2_currency_code,
                  --        tmp2.TXN_BILL_LABOR_RAW_COST,
                         round(tmp2.POU_BILL_LABOR_RAW_COST *
                               tmp2.PRJ_GL_RATE2 /
                               PRJ_GL_MAU2) * PRJ_GL_MAU2
                  -- )
                  ,
                  to_number(null))                  GG2_BILL_LABOR_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g2_currency_code,
                  --        tmp2.TXN_BILL_LABOR_BRDN_COST,
                         round(tmp2.POU_BILL_LABOR_BRDN_COST *
                               tmp2.PRJ_GL_RATE2 /
                               PRJ_GL_MAU2) * PRJ_GL_MAU2
                  -- )
                  ,
                  to_number(null))                  GG2_BILL_LABOR_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g2_currency_code,
                         tmp2.TXN_REVENUE,
                         round(tmp2.POU_REVENUE *
                               tmp2.PRJ_PA_RATE2 /
                               PRJ_PA_MAU2) * PRJ_PA_MAU2),
                  to_number(null))                  GP2_REVENUE,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g2_currency_code,
                  --        tmp2.TXN_LABOR_REVENUE,
                         round(tmp2.POU_LABOR_REVENUE *
                               tmp2.PRJ_PA_RATE2 /
                               PRJ_PA_MAU2) * PRJ_PA_MAU2
                  -- )
                  ,
                  to_number(null))                  GP2_LABOR_REVENUE,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g2_currency_code,
                  --        tmp2.TXN_REVENUE_WRITEOFF,
                         round(tmp2.POU_REVENUE_WRITEOFF *
                               tmp2.PRJ_PA_RATE2 /
                               PRJ_PA_MAU2) * PRJ_PA_MAU2
                  -- )
                  ,
                  to_number(null))                  GP2_REVENUE_WRITEOFF,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g2_currency_code,
                         tmp2.TXN_RAW_COST,
                         round(tmp2.POU_RAW_COST *
                               tmp2.PRJ_PA_RATE2 /
                               PRJ_PA_MAU2) * PRJ_PA_MAU2),
                  to_number(null))                  GP2_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g2_currency_code,
                         tmp2.TXN_BRDN_COST,
                         round(tmp2.POU_BRDN_COST *
                               tmp2.PRJ_PA_RATE2 /
                               PRJ_PA_MAU2) * PRJ_PA_MAU2),
                  to_number(null))                  GP2_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g2_currency_code,
                         tmp2.TXN_BILL_RAW_COST,
                         round(tmp2.POU_BILL_RAW_COST *
                               tmp2.PRJ_PA_RATE2 /
                               PRJ_PA_MAU2) * PRJ_PA_MAU2),
                  to_number(null))                  GP2_BILL_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', decode(tmp2.TXN_CURRENCY_CODE,
                         l_g2_currency_code,
                         tmp2.TXN_BILL_BRDN_COST,
                         round(tmp2.POU_BILL_BRDN_COST *
                               tmp2.PRJ_PA_RATE2 /
                               PRJ_PA_MAU2) * PRJ_PA_MAU2),
                  to_number(null))                  GP2_BILL_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g2_currency_code,
                  --        tmp2.TXN_LABOR_RAW_COST,
                         round(tmp2.POU_LABOR_RAW_COST *
                               tmp2.PRJ_PA_RATE2 /
                               PRJ_PA_MAU2) * PRJ_PA_MAU2
                  -- )
                  ,
                  to_number(null))                  GP2_LABOR_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g2_currency_code,
                  --        tmp2.TXN_LABOR_BRDN_COST,
                         round(tmp2.POU_LABOR_BRDN_COST *
                               tmp2.PRJ_PA_RATE2 /
                               PRJ_PA_MAU2) * PRJ_PA_MAU2
                  -- )
                  ,
                  to_number(null))                  GP2_LABOR_BRDN_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g2_currency_code,
                  --        tmp2.TXN_BILL_LABOR_RAW_COST,
                         round(tmp2.POU_BILL_LABOR_RAW_COST *
                               tmp2.PRJ_PA_RATE2 /
                               PRJ_PA_MAU2) * PRJ_PA_MAU2
                  -- )
                  ,
                  to_number(null))                  GP2_BILL_LABOR_RAW_COST,
      decode(nvl(tmp2.PJI_PROJECT_RECORD_FLAG, 'N') ||
             tmp2.DANGLING_RECVR_GL_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_GL_RATE2_FLAG      ||
             tmp2.DANGLING_RECVR_PA_RATE_FLAG       ||
             tmp2.DANGLING_RECVR_PA_RATE2_FLAG      ||
             tmp2.DANGLING_PRVDR_EN_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_EN_TIME_FLAG       ||
             tmp2.DANGLING_EXP_EN_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_GL_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_GL_TIME_FLAG       ||
             tmp2.DANGLING_EXP_GL_TIME_FLAG         ||
             tmp2.DANGLING_PRVDR_PA_TIME_FLAG       ||
             tmp2.DANGLING_RECVR_PA_TIME_FLAG       ||
             tmp2.DANGLING_EXP_PA_TIME_FLAG,
             'Y', -- decode(tmp2.TXN_CURRENCY_CODE,
                  --        l_g2_currency_code,
                  --        tmp2.TXN_BILL_LABOR_BRDN_COST,
                         round(tmp2.POU_BILL_LABOR_BRDN_COST *
                               tmp2.PRJ_PA_RATE2 /
                               PRJ_PA_MAU2) * PRJ_PA_MAU2
                  -- )
                  ,
                  to_number(null))                  GP2_BILL_LABOR_BRDN_COST,
      tmp2.TOTAL_HRS_A,
      tmp2.BILL_HRS_A
    from
    (
    select /*+ ordered
               full(tmp2)      use_hash(tmp2)      parallel(tmp2)
               full(map)       use_hash(map)       parallel(map)
               full(prj_info)  use_hash(prj_info)
               full(res_info)  use_hash(res_info)
               full(prj_gl_rt) use_hash(prj_gl_rt)
               full(prj_pa_rt) use_hash(prj_pa_rt)
            */
      decode(tmp2.PJI_PROJECT_RECORD_FLAG,
             'Y', decode(prj_gl_rt.RATE,
                         -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                         decode(sign(prj_gl_rt.RATE),
                                -1, 'Y', null)),
             null)                             DANGLING_RECVR_GL_RATE_FLAG,
      decode(tmp2.PJI_PROJECT_RECORD_FLAG || l_g2_currency_flag,
             'YY', decode(prj_gl_rt.RATE2,
                          -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                          decode(sign(prj_gl_rt.RATE2),
                                 -1, 'Y', null)),
             null)                             DANGLING_RECVR_GL_RATE2_FLAG,
      decode(tmp2.PJI_PROJECT_RECORD_FLAG,
             'Y', decode(prj_pa_rt.RATE,
                         -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                         decode(sign(prj_pa_rt.RATE),
                                -1, 'Y', null)),
             null)                             DANGLING_RECVR_PA_RATE_FLAG,
      decode(tmp2.PJI_PROJECT_RECORD_FLAG || l_g2_currency_flag,
             'YY', decode(prj_pa_rt.RATE2,
                          -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                          decode(sign(prj_pa_rt.RATE2),
                                 -1, 'Y', null)),
             null)                             DANGLING_RECVR_PA_RATE2_FLAG,
      --case when tmp2.PJI_RESOURCE_RECORD_FLAG = 'Y' and
      --          (tmp2.PRVDR_GL_TIME_ID < res_info.EN_CALENDAR_MIN_DATE or
      --           tmp2.PRVDR_GL_TIME_ID > res_info.EN_CALENDAR_MAX_DATE)
      --     then 'Y'
      --     else null
      --     end                                 DANGLING_PRVDR_EN_TIME_FLAG,
      null                                     DANGLING_PRVDR_EN_TIME_FLAG,
      decode(tmp2.PJI_PROJECT_RECORD_FLAG,
             'Y', decode(sign(prj_info.EN_CALENDAR_MIN_DATE -
                              tmp2.RECVR_GL_TIME_ID) +
                         sign(tmp2.RECVR_GL_TIME_ID -
                              prj_info.EN_CALENDAR_MAX_DATE),
                         0, 'Y', null), null)  DANGLING_RECVR_EN_TIME_FLAG,
      decode(tmp2.PJI_RESOURCE_RECORD_FLAG,
             'Y', decode(sign(res_info.EN_CALENDAR_MIN_DATE -
                              tmp2.EXPENDITURE_ITEM_TIME_ID) +
                         sign(tmp2.EXPENDITURE_ITEM_TIME_ID -
                              res_info.EN_CALENDAR_MAX_DATE),
                         0, 'Y', null), null)  DANGLING_EXP_EN_TIME_FLAG,
      --case when tmp2.PJI_RESOURCE_RECORD_FLAG = 'Y' and
      --          (tmp2.PRVDR_GL_TIME_ID < res_info.GL_CALENDAR_MIN_DATE or
      --           tmp2.PRVDR_GL_TIME_ID > res_info.GL_CALENDAR_MAX_DATE)
      --     then 'Y'
      --     else null
      --     end                                 DANGLING_PRVDR_GL_TIME_FLAG,
      null                                     DANGLING_PRVDR_GL_TIME_FLAG,
      decode(tmp2.PJI_PROJECT_RECORD_FLAG,
             'Y', decode(sign(prj_info.GL_CALENDAR_MIN_DATE -
                              tmp2.RECVR_GL_TIME_ID) +
                         sign(tmp2.RECVR_GL_TIME_ID -
                              prj_info.GL_CALENDAR_MAX_DATE),
                         0, 'Y', null), null)  DANGLING_RECVR_GL_TIME_FLAG,
      decode(tmp2.PJI_RESOURCE_RECORD_FLAG,
             'Y', decode(sign(res_info.GL_CALENDAR_MIN_DATE -
                              tmp2.EXPENDITURE_ITEM_TIME_ID) +
                         sign(tmp2.EXPENDITURE_ITEM_TIME_ID -
                              res_info.GL_CALENDAR_MAX_DATE),
                         0, 'Y', null), null)  DANGLING_EXP_GL_TIME_FLAG,
      --case when tmp2.PJI_RESOURCE_RECORD_FLAG = 'Y' and
      --          (tmp2.PRVDR_PA_TIME_ID < res_info.PA_CALENDAR_MIN_DATE or
      --           tmp2.PRVDR_PA_TIME_ID > res_info.PA_CALENDAR_MAX_DATE)
      --     then 'Y'
      --     else null
      --     end                                 DANGLING_PRVDR_PA_TIME_FLAG,
      null                                     DANGLING_PRVDR_PA_TIME_FLAG,
      decode(tmp2.PJI_PROJECT_RECORD_FLAG,
             'Y', decode(sign(prj_info.PA_CALENDAR_MIN_DATE -
                              tmp2.RECVR_PA_TIME_ID) +
                         sign(tmp2.RECVR_PA_TIME_ID -
                              prj_info.PA_CALENDAR_MAX_DATE),
                         0, 'Y', null), null)  DANGLING_RECVR_PA_TIME_FLAG,
      decode(tmp2.PJI_RESOURCE_RECORD_FLAG,
             'Y', decode(sign(res_info.PA_CALENDAR_MIN_DATE -
                              tmp2.EXPENDITURE_ITEM_TIME_ID) +
                         sign(tmp2.EXPENDITURE_ITEM_TIME_ID -
                              res_info.PA_CALENDAR_MAX_DATE),
                         0, 'Y', null), null)  DANGLING_EXP_PA_TIME_FLAG,
      tmp2.ROWID                               ROW_ID,
      tmp2.PJI_PROJECT_RECORD_FLAG,
      tmp2.PJI_RESOURCE_RECORD_FLAG,
      tmp2.RECORD_TYPE,
      tmp2.CMT_RECORD_TYPE,
      tmp2.PROJECT_ID,
      tmp2.PROJECT_ORG_ID,
      tmp2.PROJECT_ORGANIZATION_ID,
      tmp2.PROJECT_TYPE_CLASS,
      tmp2.PERSON_ID,
      tmp2.EXPENDITURE_ORG_ID,
      tmp2.EXPENDITURE_ORGANIZATION_ID,
      tmp2.EXP_EVT_TYPE_ID,
      tmp2.WORK_TYPE_ID,
      tmp2.JOB_ID,
      tmp2.TASK_ID,
      tmp2.VENDOR_ID,
      tmp2.EXPENDITURE_TYPE,
      tmp2.EVENT_TYPE,
      tmp2.EVENT_TYPE_CLASSIFICATION,
      tmp2.EXPENDITURE_CATEGORY,
      tmp2.REVENUE_CATEGORY,
      tmp2.NON_LABOR_RESOURCE,
      tmp2.BOM_LABOR_RESOURCE_ID,
      tmp2.BOM_EQUIPMENT_RESOURCE_ID,
      tmp2.INVENTORY_ITEM_ID,
      tmp2.PO_LINE_ID,
      tmp2.ASSIGNMENT_ID,
      tmp2.SYSTEM_LINKAGE_FUNCTION,
      tmp2.RESOURCE_CLASS_CODE,
      tmp2.RECVR_GL_TIME_ID,
      tmp2.GL_PERIOD_NAME,
      tmp2.PRVDR_GL_TIME_ID,
      tmp2.RECVR_PA_TIME_ID,
      tmp2.PA_PERIOD_NAME,
      tmp2.PRVDR_PA_TIME_ID,
      tmp2.EXPENDITURE_ITEM_TIME_ID,
      prj_info.GL_CALENDAR_ID                  PJ_GL_CALENDAR_ID,
      prj_info.PA_CALENDAR_ID                  PJ_PA_CALENDAR_ID,
      res_info.GL_CALENDAR_ID                  RS_GL_CALENDAR_ID,
      res_info.PA_CALENDAR_ID                  RS_PA_CALENDAR_ID,
      prj_gl_rt.RATE                           PRJ_GL_RATE1,
      prj_gl_rt.RATE2                          PRJ_GL_RATE2,
      prj_pa_rt.RATE                           PRJ_PA_RATE1,
      prj_pa_rt.RATE2                          PRJ_PA_RATE2,
      prj_gl_rt.MAU                            PRJ_GL_MAU1,
      prj_gl_rt.MAU2                           PRJ_GL_MAU2,
      prj_pa_rt.MAU                            PRJ_PA_MAU1,
      prj_pa_rt.MAU2                           PRJ_PA_MAU2,
      tmp2.PRJ_REVENUE,
      tmp2.PRJ_LABOR_REVENUE,
      tmp2.PRJ_REVENUE_WRITEOFF,
      tmp2.PRJ_RAW_COST,
      tmp2.PRJ_BRDN_COST,
      tmp2.PRJ_BILL_RAW_COST,
      tmp2.PRJ_BILL_BRDN_COST,
      tmp2.PRJ_LABOR_RAW_COST,
      tmp2.PRJ_LABOR_BRDN_COST,
      tmp2.PRJ_BILL_LABOR_RAW_COST,
      tmp2.PRJ_BILL_LABOR_BRDN_COST,
      tmp2.POU_REVENUE,
      tmp2.POU_LABOR_REVENUE,
      tmp2.POU_REVENUE_WRITEOFF,
      tmp2.POU_RAW_COST,
      tmp2.POU_BRDN_COST,
      tmp2.POU_BILL_RAW_COST,
      tmp2.POU_BILL_BRDN_COST,
      tmp2.POU_LABOR_RAW_COST,
      tmp2.POU_LABOR_BRDN_COST,
      tmp2.POU_BILL_LABOR_RAW_COST,
      tmp2.POU_BILL_LABOR_BRDN_COST,
      tmp2.EOU_RAW_COST,
      tmp2.EOU_BRDN_COST,
      tmp2.EOU_BILL_RAW_COST,
      tmp2.EOU_BILL_BRDN_COST,
      tmp2.TXN_CURRENCY_CODE,
      tmp2.TXN_REVENUE,
      tmp2.TXN_RAW_COST,
      tmp2.TXN_BRDN_COST,
      tmp2.TXN_BILL_RAW_COST,
      tmp2.TXN_BILL_BRDN_COST,
      tmp2.LABOR_HRS,
      tmp2.BILL_LABOR_HRS,
      tmp2.TOTAL_HRS_A,
      tmp2.BILL_HRS_A
    from
      PJI_FM_DNGL_FIN       tmp2,
      PJI_FM_PROJ_BATCH_MAP map,
      PJI_ORG_EXTR_INFO     prj_info,
      PJI_ORG_EXTR_INFO     res_info,
      PJI_FM_AGGR_DLY_RATES prj_gl_rt,
      PJI_FM_AGGR_DLY_RATES prj_pa_rt
    where
      tmp2.WORKER_ID                      = 0                          and
      tmp2.RECORD_TYPE                    = 'A'                        and
      map.WORKER_ID                       = p_worker_id                and
      map.PROJECT_ID                      = tmp2.PROJECT_ID            and
      tmp2.PROJECT_ORG_ID                 = prj_info.ORG_ID            and
      tmp2.EXPENDITURE_ORG_ID             = res_info.ORG_ID            and
      prj_gl_rt.WORKER_ID                 = -1                         and
      tmp2.RECVR_GL_TIME_ID               = prj_gl_rt.TIME_ID          and
      prj_info.PF_CURRENCY_CODE           = prj_gl_rt.PF_CURRENCY_CODE and
      prj_pa_rt.WORKER_ID                 = -1                         and
      tmp2.RECVR_PA_TIME_ID               = prj_pa_rt.TIME_ID          and
      prj_info.PF_CURRENCY_CODE           = prj_pa_rt.PF_CURRENCY_CODE
    ) tmp2;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.DANGLING_FIN_ROWS(p_worker_id);');

    commit;

  end DANGLING_FIN_ROWS;


  -- -----------------------------------------------------
  -- procedure DANGLING_ACT_ROWS
  -- -----------------------------------------------------
  procedure DANGLING_ACT_ROWS (p_worker_id in number) is

    l_process           varchar2(30);

    l_txn_currency_flag varchar2(1);
    l_g2_currency_flag  varchar2(1);
    l_g1_currency_code  varchar2(30);
    l_g2_currency_code  varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.DANGLING_ACT_ROWS(p_worker_id);')) then
      return;
    end if;

    select
      TXN_CURR_FLAG,
      GLOBAL_CURR2_FLAG
    into
      l_txn_currency_flag,
      l_g2_currency_flag
    from
      PJI_SYSTEM_SETTINGS;

    l_g1_currency_code := PJI_UTILS.GET_GLOBAL_PRIMARY_CURRENCY;
    l_g2_currency_code := PJI_UTILS.GET_GLOBAL_SECONDARY_CURRENCY;

    insert /*+ append parallel(act2_i) */ into PJI_FM_AGGR_ACT2 act2_i -- in DANGLING_ACT_ROWS
    (
      WORKER_ID,
      DANGLING_GL_RATE_FLAG,
      DANGLING_GL_RATE2_FLAG,
      DANGLING_PA_RATE2_FLAG,
      DANGLING_PA_RATE_FLAG,
      DANGLING_EN_TIME_FLAG,
      DANGLING_GL_TIME_FLAG,
      DANGLING_PA_TIME_FLAG,
      ROW_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      GL_TIME_ID,
      GL_PERIOD_NAME,
      PA_TIME_ID,
      PA_PERIOD_NAME,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      TXN_CURRENCY_CODE,
      TXN_REVENUE,
      TXN_FUNDING,
      TXN_INITIAL_FUNDING_AMOUNT,
      TXN_ADDITIONAL_FUNDING_AMOUNT,
      TXN_CANCELLED_FUNDING_AMOUNT,
      TXN_FUNDING_ADJUSTMENT_AMOUNT,
      TXN_REVENUE_WRITEOFF,
      TXN_AR_INVOICE_AMOUNT,
      TXN_AR_CASH_APPLIED_AMOUNT,
      TXN_AR_INVOICE_WRITEOFF_AMOUNT,
      TXN_AR_CREDIT_MEMO_AMOUNT,
      TXN_UNBILLED_RECEIVABLES,
      TXN_UNEARNED_REVENUE,
      TXN_AR_UNAPPR_INVOICE_AMOUNT,
      TXN_AR_APPR_INVOICE_AMOUNT,
      TXN_AR_AMOUNT_DUE,
      TXN_AR_AMOUNT_OVERDUE,
      PRJ_REVENUE,
      PRJ_FUNDING,
      PRJ_INITIAL_FUNDING_AMOUNT,
      PRJ_ADDITIONAL_FUNDING_AMOUNT,
      PRJ_CANCELLED_FUNDING_AMOUNT,
      PRJ_FUNDING_ADJUSTMENT_AMOUNT,
      PRJ_REVENUE_WRITEOFF,
      PRJ_AR_INVOICE_AMOUNT,
      PRJ_AR_CASH_APPLIED_AMOUNT,
      PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
      PRJ_AR_CREDIT_MEMO_AMOUNT,
      PRJ_UNBILLED_RECEIVABLES,
      PRJ_UNEARNED_REVENUE,
      PRJ_AR_UNAPPR_INVOICE_AMOUNT,
      PRJ_AR_APPR_INVOICE_AMOUNT,
      PRJ_AR_AMOUNT_DUE,
      PRJ_AR_AMOUNT_OVERDUE,
      POU_REVENUE,
      POU_FUNDING,
      POU_INITIAL_FUNDING_AMOUNT,
      POU_ADDITIONAL_FUNDING_AMOUNT,
      POU_CANCELLED_FUNDING_AMOUNT,
      POU_FUNDING_ADJUSTMENT_AMOUNT,
      POU_REVENUE_WRITEOFF,
      POU_AR_INVOICE_AMOUNT,
      POU_AR_CASH_APPLIED_AMOUNT,
      POU_AR_INVOICE_WRITEOFF_AMOUNT,
      POU_AR_CREDIT_MEMO_AMOUNT,
      POU_UNBILLED_RECEIVABLES,
      POU_UNEARNED_REVENUE,
      POU_AR_UNAPPR_INVOICE_AMOUNT,
      POU_AR_APPR_INVOICE_AMOUNT,
      POU_AR_AMOUNT_DUE,
      POU_AR_AMOUNT_OVERDUE,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_COUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_COUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_COUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_COUNT,
      AR_COUNT_DUE,
      AR_COUNT_OVERDUE,
      GG_REVENUE,
      GG_FUNDING,
      GG_INITIAL_FUNDING_AMOUNT,
      GG_ADDITIONAL_FUNDING_AMOUNT,
      GG_CANCELLED_FUNDING_AMOUNT,
      GG_FUNDING_ADJUSTMENT_AMOUNT,
      GG_REVENUE_WRITEOFF,
      GG_AR_INVOICE_AMOUNT,
      GG_AR_CASH_APPLIED_AMOUNT,
      GG_AR_INVOICE_WRITEOFF_AMOUNT,
      GG_AR_CREDIT_MEMO_AMOUNT,
      GG_UNBILLED_RECEIVABLES,
      GG_UNEARNED_REVENUE,
      GG_AR_UNAPPR_INVOICE_AMOUNT,
      GG_AR_APPR_INVOICE_AMOUNT,
      GG_AR_AMOUNT_DUE,
      GG_AR_AMOUNT_OVERDUE,
      GP_REVENUE,
      GP_FUNDING,
      GP_INITIAL_FUNDING_AMOUNT,
      GP_ADDITIONAL_FUNDING_AMOUNT,
      GP_CANCELLED_FUNDING_AMOUNT,
      GP_FUNDING_ADJUSTMENT_AMOUNT,
      GP_REVENUE_WRITEOFF,
      GP_AR_INVOICE_AMOUNT,
      GP_AR_CASH_APPLIED_AMOUNT,
      GP_AR_INVOICE_WRITEOFF_AMOUNT,
      GP_AR_CREDIT_MEMO_AMOUNT,
      GP_UNBILLED_RECEIVABLES,
      GP_UNEARNED_REVENUE,
      GP_AR_UNAPPR_INVOICE_AMOUNT,
      GP_AR_APPR_INVOICE_AMOUNT,
      GP_AR_AMOUNT_DUE,
      GP_AR_AMOUNT_OVERDUE,
      GG2_REVENUE,
      GG2_FUNDING,
      GG2_INITIAL_FUNDING_AMOUNT,
      GG2_ADDITIONAL_FUNDING_AMOUNT,
      GG2_CANCELLED_FUNDING_AMOUNT,
      GG2_FUNDING_ADJUSTMENT_AMOUNT,
      GG2_REVENUE_WRITEOFF,
      GG2_AR_INVOICE_AMOUNT,
      GG2_AR_CASH_APPLIED_AMOUNT,
      GG2_AR_INVOICE_WRITEOFF_AMOUNT,
      GG2_AR_CREDIT_MEMO_AMOUNT,
      GG2_UNBILLED_RECEIVABLES,
      GG2_UNEARNED_REVENUE,
      GG2_AR_UNAPPR_INVOICE_AMOUNT,
      GG2_AR_APPR_INVOICE_AMOUNT,
      GG2_AR_AMOUNT_DUE,
      GG2_AR_AMOUNT_OVERDUE,
      GP2_REVENUE,
      GP2_FUNDING,
      GP2_INITIAL_FUNDING_AMOUNT,
      GP2_ADDITIONAL_FUNDING_AMOUNT,
      GP2_CANCELLED_FUNDING_AMOUNT,
      GP2_FUNDING_ADJUSTMENT_AMOUNT,
      GP2_REVENUE_WRITEOFF,
      GP2_AR_INVOICE_AMOUNT,
      GP2_AR_CASH_APPLIED_AMOUNT,
      GP2_AR_INVOICE_WRITEOFF_AMOUNT,
      GP2_AR_CREDIT_MEMO_AMOUNT,
      GP2_UNBILLED_RECEIVABLES,
      GP2_UNEARNED_REVENUE,
      GP2_AR_UNAPPR_INVOICE_AMOUNT,
      GP2_AR_APPR_INVOICE_AMOUNT,
      GP2_AR_AMOUNT_DUE,
      GP2_AR_AMOUNT_OVERDUE
    )
    select
      p_worker_id,
      tmp2.DANGLING_GL_RATE_FLAG,
      tmp2.DANGLING_GL_RATE2_FLAG,
      tmp2.DANGLING_PA_RATE_FLAG,
      tmp2.DANGLING_PA_RATE2_FLAG,
      tmp2.DANGLING_EN_TIME_FLAG,
      tmp2.DANGLING_GL_TIME_FLAG,
      tmp2.DANGLING_PA_TIME_FLAG,
      tmp2.ROW_ID,
      tmp2.PROJECT_ID,
      tmp2.PROJECT_ORG_ID,
      tmp2.PROJECT_ORGANIZATION_ID,
      tmp2.GL_TIME_ID,
      tmp2.GL_PERIOD_NAME,
      tmp2.PA_TIME_ID,
      tmp2.PA_PERIOD_NAME,
      tmp2.GL_CALENDAR_ID,
      tmp2.PA_CALENDAR_ID,
      tmp2.TXN_CURRENCY_CODE,
      tmp2.TXN_REVENUE,
      tmp2.TXN_FUNDING,
      tmp2.TXN_INITIAL_FUNDING_AMOUNT,
      tmp2.TXN_ADDITIONAL_FUNDING_AMOUNT,
      tmp2.TXN_CANCELLED_FUNDING_AMOUNT,
      tmp2.TXN_FUNDING_ADJUSTMENT_AMOUNT,
      tmp2.TXN_REVENUE_WRITEOFF,
      tmp2.TXN_AR_INVOICE_AMOUNT,
      tmp2.TXN_AR_CASH_APPLIED_AMOUNT,
      tmp2.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
      tmp2.TXN_AR_CREDIT_MEMO_AMOUNT,
      tmp2.TXN_UNBILLED_RECEIVABLES,
      tmp2.TXN_UNEARNED_REVENUE,
      tmp2.TXN_AR_UNAPPR_INVOICE_AMOUNT,
      tmp2.TXN_AR_APPR_INVOICE_AMOUNT,
      tmp2.TXN_AR_AMOUNT_DUE,
      tmp2.TXN_AR_AMOUNT_OVERDUE,
      tmp2.PRJ_REVENUE,
      tmp2.PRJ_FUNDING,
      tmp2.PRJ_INITIAL_FUNDING_AMOUNT,
      tmp2.PRJ_ADDITIONAL_FUNDING_AMOUNT,
      tmp2.PRJ_CANCELLED_FUNDING_AMOUNT,
      tmp2.PRJ_FUNDING_ADJUSTMENT_AMOUNT,
      tmp2.PRJ_REVENUE_WRITEOFF,
      tmp2.PRJ_AR_INVOICE_AMOUNT,
      tmp2.PRJ_AR_CASH_APPLIED_AMOUNT,
      tmp2.PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
      tmp2.PRJ_AR_CREDIT_MEMO_AMOUNT,
      tmp2.PRJ_UNBILLED_RECEIVABLES,
      tmp2.PRJ_UNEARNED_REVENUE,
      tmp2.PRJ_AR_UNAPPR_INVOICE_AMOUNT,
      tmp2.PRJ_AR_APPR_INVOICE_AMOUNT,
      tmp2.PRJ_AR_AMOUNT_DUE,
      tmp2.PRJ_AR_AMOUNT_OVERDUE,
      tmp2.POU_REVENUE,
      tmp2.POU_FUNDING,
      tmp2.POU_INITIAL_FUNDING_AMOUNT,
      tmp2.POU_ADDITIONAL_FUNDING_AMOUNT,
      tmp2.POU_CANCELLED_FUNDING_AMOUNT,
      tmp2.POU_FUNDING_ADJUSTMENT_AMOUNT,
      tmp2.POU_REVENUE_WRITEOFF,
      tmp2.POU_AR_INVOICE_AMOUNT,
      tmp2.POU_AR_CASH_APPLIED_AMOUNT,
      tmp2.POU_AR_INVOICE_WRITEOFF_AMOUNT,
      tmp2.POU_AR_CREDIT_MEMO_AMOUNT,
      tmp2.POU_UNBILLED_RECEIVABLES,
      tmp2.POU_UNEARNED_REVENUE,
      tmp2.POU_AR_UNAPPR_INVOICE_AMOUNT,
      tmp2.POU_AR_APPR_INVOICE_AMOUNT,
      tmp2.POU_AR_AMOUNT_DUE,
      tmp2.POU_AR_AMOUNT_OVERDUE,
      tmp2.INITIAL_FUNDING_COUNT,
      tmp2.ADDITIONAL_FUNDING_COUNT,
      tmp2.CANCELLED_FUNDING_COUNT,
      tmp2.FUNDING_ADJUSTMENT_COUNT,
      tmp2.AR_INVOICE_COUNT,
      tmp2.AR_CASH_APPLIED_COUNT,
      tmp2.AR_INVOICE_WRITEOFF_COUNT,
      tmp2.AR_CREDIT_MEMO_COUNT,
      tmp2.AR_UNAPPR_INVOICE_COUNT,
      tmp2.AR_APPR_INVOICE_COUNT,
      tmp2.AR_COUNT_DUE,
      tmp2.AR_COUNT_OVERDUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_REVENUE,
                          round(tmp2.POU_REVENUE *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_REVENUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_FUNDING,
                          round(tmp2.POU_FUNDING *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_FUNDING,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_INITIAL_FUNDING_AMOUNT,
                          round(tmp2.POU_INITIAL_FUNDING_AMOUNT *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_INITIAL_FUNDING_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_ADDITIONAL_FUNDING_AMOUNT,
                          round(tmp2.POU_ADDITIONAL_FUNDING_AMOUNT *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_ADDITIONAL_FUNDING_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_CANCELLED_FUNDING_AMOUNT,
                          round(tmp2.POU_CANCELLED_FUNDING_AMOUNT *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_CANCELLED_FUNDING_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_FUNDING_ADJUSTMENT_AMOUNT,
                          round(tmp2.POU_FUNDING_ADJUSTMENT_AMOUNT *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_FUNDING_ADJUSTMENT_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_REVENUE_WRITEOFF,
                          round(tmp2.POU_REVENUE_WRITEOFF *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_REVENUE_WRITEOFF,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_INVOICE_AMOUNT,
                          round(tmp2.POU_AR_INVOICE_AMOUNT *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_AR_INVOICE_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_CASH_APPLIED_AMOUNT,
                          round(tmp2.POU_AR_CASH_APPLIED_AMOUNT *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_AR_CASH_APPLIED_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
                          round(tmp2.POU_AR_INVOICE_WRITEOFF_AMOUNT *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_AR_INVOICE_WRITEOFF_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_CREDIT_MEMO_AMOUNT,
                          round(tmp2.POU_AR_CREDIT_MEMO_AMOUNT *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_AR_CREDIT_MEMO_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_UNBILLED_RECEIVABLES,
                          round(tmp2.POU_UNBILLED_RECEIVABLES *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_UNBILLED_RECEIVABLES,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_UNEARNED_REVENUE,
                          round(tmp2.POU_UNEARNED_REVENUE *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_UNEARNED_REVENUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_UNAPPR_INVOICE_AMOUNT,
                          round(tmp2.POU_AR_UNAPPR_INVOICE_AMOUNT *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_AR_UNAPPR_INVOICE_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_APPR_INVOICE_AMOUNT,
                          round(tmp2.POU_AR_APPR_INVOICE_AMOUNT *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_AR_APPR_INVOICE_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_AMOUNT_DUE,
                          round(tmp2.POU_AR_AMOUNT_DUE *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_AR_AMOUNT_DUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_AMOUNT_OVERDUE,
                          round(tmp2.POU_AR_AMOUNT_OVERDUE *
                                tmp2.GL_RATE1 /
                                tmp2.GL_MAU1) * tmp2.GL_MAU1),
                   to_number(null))            GG1_AR_AMOUNT_OVERDUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_REVENUE,
                          round(tmp2.POU_REVENUE *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_REVENUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_FUNDING,
                          round(tmp2.POU_FUNDING *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_FUNDING,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_INITIAL_FUNDING_AMOUNT,
                          round(tmp2.POU_INITIAL_FUNDING_AMOUNT *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_INITIAL_FUNDING_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_ADDITIONAL_FUNDING_AMOUNT,
                          round(tmp2.POU_ADDITIONAL_FUNDING_AMOUNT *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_ADDITIONAL_FUNDING_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_CANCELLED_FUNDING_AMOUNT,
                          round(tmp2.POU_CANCELLED_FUNDING_AMOUNT *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_CANCELLED_FUNDING_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_FUNDING_ADJUSTMENT_AMOUNT,
                          round(tmp2.POU_FUNDING_ADJUSTMENT_AMOUNT *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_FUNDING_ADJUSTMENT_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_REVENUE_WRITEOFF,
                          round(tmp2.POU_REVENUE_WRITEOFF *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_REVENUE_WRITEOFF,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_INVOICE_AMOUNT,
                          round(tmp2.POU_AR_INVOICE_AMOUNT *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_AR_INVOICE_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_CASH_APPLIED_AMOUNT,
                          round(tmp2.POU_AR_CASH_APPLIED_AMOUNT *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_AR_CASH_APPLIED_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
                          round(tmp2.POU_AR_INVOICE_WRITEOFF_AMOUNT *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_AR_INVOICE_WRITEOFF_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_CREDIT_MEMO_AMOUNT,
                          round(tmp2.POU_AR_CREDIT_MEMO_AMOUNT *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_AR_CREDIT_MEMO_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_UNBILLED_RECEIVABLES,
                          round(tmp2.POU_UNBILLED_RECEIVABLES *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_UNBILLED_RECEIVABLES,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_UNEARNED_REVENUE,
                          round(tmp2.POU_UNEARNED_REVENUE *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_UNEARNED_REVENUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_UNAPPR_INVOICE_AMOUNT,
                          round(tmp2.POU_AR_UNAPPR_INVOICE_AMOUNT *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_AR_UNAPPR_INVOICE_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_APPR_INVOICE_AMOUNT,
                          round(tmp2.POU_AR_APPR_INVOICE_AMOUNT *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_AR_APPR_INVOICE_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_AMOUNT_DUE,
                          round(tmp2.POU_AR_AMOUNT_DUE *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_AR_AMOUNT_DUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp2.TXN_AR_AMOUNT_OVERDUE,
                          round(tmp2.POU_AR_AMOUNT_OVERDUE *
                                tmp2.PA_RATE1 /
                                tmp2.PA_MAU1) * tmp2.PA_MAU1),
                   to_number(null))            GP1_AR_AMOUNT_OVERDUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_REVENUE,
                          round(tmp2.POU_REVENUE *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_REVENUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_FUNDING,
                          round(tmp2.POU_FUNDING *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_FUNDING,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_INITIAL_FUNDING_AMOUNT,
                          round(tmp2.POU_INITIAL_FUNDING_AMOUNT *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_INITIAL_FUNDING_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_ADDITIONAL_FUNDING_AMOUNT,
                          round(tmp2.POU_ADDITIONAL_FUNDING_AMOUNT *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_ADDITIONAL_FUNDING_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_CANCELLED_FUNDING_AMOUNT,
                          round(tmp2.POU_CANCELLED_FUNDING_AMOUNT *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_CANCELLED_FUNDING_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_FUNDING_ADJUSTMENT_AMOUNT,
                          round(tmp2.POU_FUNDING_ADJUSTMENT_AMOUNT *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_FUNDING_ADJUSTMENT_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_REVENUE_WRITEOFF,
                          round(tmp2.POU_REVENUE_WRITEOFF *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_REVENUE_WRITEOFF,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_INVOICE_AMOUNT,
                          round(tmp2.POU_AR_INVOICE_AMOUNT *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_AR_INVOICE_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_CASH_APPLIED_AMOUNT,
                          round(tmp2.POU_AR_CASH_APPLIED_AMOUNT *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_AR_CASH_APPLIED_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
                          round(tmp2.POU_AR_INVOICE_WRITEOFF_AMOUNT *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_AR_INVOICE_WRITEOFF_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_CREDIT_MEMO_AMOUNT,
                          round(tmp2.POU_AR_CREDIT_MEMO_AMOUNT *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_AR_CREDIT_MEMO_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_UNBILLED_RECEIVABLES,
                          round(tmp2.POU_UNBILLED_RECEIVABLES *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_UNBILLED_RECEIVABLES,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_UNEARNED_REVENUE,
                          round(tmp2.POU_UNEARNED_REVENUE *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_UNEARNED_REVENUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_UNAPPR_INVOICE_AMOUNT,
                          round(tmp2.POU_AR_UNAPPR_INVOICE_AMOUNT *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_AR_UNAPPR_INVOICE_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_APPR_INVOICE_AMOUNT,
                          round(tmp2.POU_AR_APPR_INVOICE_AMOUNT *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_AR_APPR_INVOICE_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_AMOUNT_DUE,
                          round(tmp2.POU_AR_AMOUNT_DUE *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_AR_AMOUNT_DUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_AMOUNT_OVERDUE,
                          round(tmp2.POU_AR_AMOUNT_OVERDUE *
                                tmp2.GL_RATE2 /
                                tmp2.GL_MAU2) * tmp2.GL_MAU2),
                   to_number(null))            GG2_AR_AMOUNT_OVERDUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_REVENUE,
                          round(tmp2.POU_REVENUE *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_REVENUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_FUNDING,
                          round(tmp2.POU_FUNDING *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_FUNDING,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_INITIAL_FUNDING_AMOUNT,
                          round(tmp2.POU_INITIAL_FUNDING_AMOUNT *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_INITIAL_FUNDING_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_ADDITIONAL_FUNDING_AMOUNT,
                          round(tmp2.POU_ADDITIONAL_FUNDING_AMOUNT *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_ADDITIONAL_FUNDING_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_CANCELLED_FUNDING_AMOUNT,
                          round(tmp2.POU_CANCELLED_FUNDING_AMOUNT *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_CANCELLED_FUNDING_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_FUNDING_ADJUSTMENT_AMOUNT,
                          round(tmp2.POU_FUNDING_ADJUSTMENT_AMOUNT *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_FUNDING_ADJUSTMENT_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_REVENUE_WRITEOFF,
                          round(tmp2.POU_REVENUE_WRITEOFF *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_REVENUE_WRITEOFF,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_INVOICE_AMOUNT,
                          round(tmp2.POU_AR_INVOICE_AMOUNT *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_AR_INVOICE_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_CASH_APPLIED_AMOUNT,
                          round(tmp2.POU_AR_CASH_APPLIED_AMOUNT *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_AR_CASH_APPLIED_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
                          round(tmp2.POU_AR_INVOICE_WRITEOFF_AMOUNT *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_AR_INVOICE_WRITEOFF_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_CREDIT_MEMO_AMOUNT,
                          round(tmp2.POU_AR_CREDIT_MEMO_AMOUNT *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_AR_CREDIT_MEMO_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_UNBILLED_RECEIVABLES,
                          round(tmp2.POU_UNBILLED_RECEIVABLES *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_UNBILLED_RECEIVABLES,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_UNEARNED_REVENUE,
                          round(tmp2.POU_UNEARNED_REVENUE *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_UNEARNED_REVENUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_UNAPPR_INVOICE_AMOUNT,
                          round(tmp2.POU_AR_UNAPPR_INVOICE_AMOUNT *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_AR_UNAPPR_INVOICE_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_APPR_INVOICE_AMOUNT,
                          round(tmp2.POU_AR_APPR_INVOICE_AMOUNT *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_AR_APPR_INVOICE_AMOUNT,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_AMOUNT_DUE,
                          round(tmp2.POU_AR_AMOUNT_DUE *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_AR_AMOUNT_DUE,
      decode(tmp2.DANGLING_GL_RATE_FLAG      ||
             tmp2.DANGLING_GL_RATE2_FLAG     ||
             tmp2.DANGLING_PA_RATE_FLAG      ||
             tmp2.DANGLING_PA_RATE2_FLAG     ||
             tmp2.DANGLING_EN_TIME_FLAG      ||
             tmp2.DANGLING_GL_TIME_FLAG      ||
             tmp2.DANGLING_PA_TIME_FLAG,
             null, decode(tmp2.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp2.TXN_AR_AMOUNT_OVERDUE,
                          round(tmp2.POU_AR_AMOUNT_OVERDUE *
                                tmp2.PA_RATE2 /
                                tmp2.PA_MAU2) * tmp2.PA_MAU2),
                   to_number(null))            GP2_AR_AMOUNT_OVERDUE
    from
    (
    select /*+ ordered
               full(tmp2)      use_hash(tmp2)     parallel(tmp2)
               full(map)       use_hash(map)      parallel(map)
               full(prj_info)  use_hash(prj_info)
               full(gl_rt)     use_hash(gl_rt)
               full(pa_rt)     use_hash(pa_rt)
            */
      decode(gl_rt.RATE,
             -3, 'E', -- EUR rate for 01-JAN-1999 is missing
             decode(sign(gl_rt.RATE),
                    -1, 'Y', null))            DANGLING_GL_RATE_FLAG,
      decode(l_g2_currency_flag,
             'Y', decode(gl_rt.RATE2,
                         -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                         decode(sign(gl_rt.RATE2),
                                -1, 'Y', null)),
             null)                             DANGLING_GL_RATE2_FLAG,
      decode(pa_rt.RATE,
             -3, 'E', -- EUR rate for 01-JAN-1999 is missing
             decode(sign(pa_rt.RATE),
                    -1, 'Y', null))            DANGLING_PA_RATE_FLAG,
      decode(l_g2_currency_flag,
             'Y', decode(pa_rt.RATE2,
                         -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                         decode(sign(pa_rt.RATE2),
                                -1, 'Y', null)),
             null)                             DANGLING_PA_RATE2_FLAG,
      decode(sign(prj_info.EN_CALENDAR_MIN_DATE -
                  tmp2.GL_TIME_ID) +
             sign(tmp2.GL_TIME_ID -
                  prj_info.EN_CALENDAR_MAX_DATE),
             0, 'Y', null)                     DANGLING_EN_TIME_FLAG,
      decode(sign(prj_info.GL_CALENDAR_MIN_DATE -
                  tmp2.GL_TIME_ID) +
             sign(tmp2.GL_TIME_ID -
                  prj_info.GL_CALENDAR_MAX_DATE),
             0, 'Y', null)                     DANGLING_GL_TIME_FLAG,
      decode(sign(prj_info.PA_CALENDAR_MIN_DATE -
                  tmp2.PA_TIME_ID) +
             sign(tmp2.PA_TIME_ID -
                  prj_info.PA_CALENDAR_MAX_DATE),
             0, 'Y', null)                     DANGLING_PA_TIME_FLAG,
      tmp2.ROWID                               ROW_ID,
      tmp2.PROJECT_ID,
      tmp2.PROJECT_ORG_ID,
      tmp2.PROJECT_ORGANIZATION_ID,
      tmp2.GL_TIME_ID,
      tmp2.GL_PERIOD_NAME,
      tmp2.PA_TIME_ID,
      tmp2.PA_PERIOD_NAME,
      prj_info.GL_CALENDAR_ID,
      prj_info.PA_CALENDAR_ID,
      gl_rt.RATE                               GL_RATE1,
      gl_rt.RATE2                              GL_RATE2,
      pa_rt.RATE                               PA_RATE1,
      pa_rt.RATE2                              PA_RATE2,
      gl_rt.MAU                                GL_MAU1,
      gl_rt.MAU2                               GL_MAU2,
      pa_rt.MAU                                PA_MAU1,
      pa_rt.MAU2                               PA_MAU2,
      tmp2.TXN_CURRENCY_CODE,
      tmp2.TXN_REVENUE,
      tmp2.TXN_FUNDING,
      tmp2.TXN_INITIAL_FUNDING_AMOUNT,
      tmp2.TXN_ADDITIONAL_FUNDING_AMOUNT,
      tmp2.TXN_CANCELLED_FUNDING_AMOUNT,
      tmp2.TXN_FUNDING_ADJUSTMENT_AMOUNT,
      tmp2.TXN_REVENUE_WRITEOFF,
      tmp2.TXN_AR_INVOICE_AMOUNT,
      tmp2.TXN_AR_CASH_APPLIED_AMOUNT,
      tmp2.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
      tmp2.TXN_AR_CREDIT_MEMO_AMOUNT,
      tmp2.TXN_UNBILLED_RECEIVABLES,
      tmp2.TXN_UNEARNED_REVENUE,
      tmp2.TXN_AR_UNAPPR_INVOICE_AMOUNT,
      tmp2.TXN_AR_APPR_INVOICE_AMOUNT,
      tmp2.TXN_AR_AMOUNT_DUE,
      tmp2.TXN_AR_AMOUNT_OVERDUE,
      tmp2.PRJ_REVENUE,
      tmp2.PRJ_FUNDING,
      tmp2.PRJ_INITIAL_FUNDING_AMOUNT,
      tmp2.PRJ_ADDITIONAL_FUNDING_AMOUNT,
      tmp2.PRJ_CANCELLED_FUNDING_AMOUNT,
      tmp2.PRJ_FUNDING_ADJUSTMENT_AMOUNT,
      tmp2.PRJ_REVENUE_WRITEOFF,
      tmp2.PRJ_AR_INVOICE_AMOUNT,
      tmp2.PRJ_AR_CASH_APPLIED_AMOUNT,
      tmp2.PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
      tmp2.PRJ_AR_CREDIT_MEMO_AMOUNT,
      tmp2.PRJ_UNBILLED_RECEIVABLES,
      tmp2.PRJ_UNEARNED_REVENUE,
      tmp2.PRJ_AR_UNAPPR_INVOICE_AMOUNT,
      tmp2.PRJ_AR_APPR_INVOICE_AMOUNT,
      tmp2.PRJ_AR_AMOUNT_DUE,
      tmp2.PRJ_AR_AMOUNT_OVERDUE,
      tmp2.POU_REVENUE,
      tmp2.POU_FUNDING,
      tmp2.POU_INITIAL_FUNDING_AMOUNT,
      tmp2.POU_ADDITIONAL_FUNDING_AMOUNT,
      tmp2.POU_CANCELLED_FUNDING_AMOUNT,
      tmp2.POU_FUNDING_ADJUSTMENT_AMOUNT,
      tmp2.POU_REVENUE_WRITEOFF,
      tmp2.POU_AR_INVOICE_AMOUNT,
      tmp2.POU_AR_CASH_APPLIED_AMOUNT,
      tmp2.POU_AR_INVOICE_WRITEOFF_AMOUNT,
      tmp2.POU_AR_CREDIT_MEMO_AMOUNT,
      tmp2.POU_UNBILLED_RECEIVABLES,
      tmp2.POU_UNEARNED_REVENUE,
      tmp2.POU_AR_UNAPPR_INVOICE_AMOUNT,
      tmp2.POU_AR_APPR_INVOICE_AMOUNT,
      tmp2.POU_AR_AMOUNT_DUE,
      tmp2.POU_AR_AMOUNT_OVERDUE,
      tmp2.INITIAL_FUNDING_COUNT,
      tmp2.ADDITIONAL_FUNDING_COUNT,
      tmp2.CANCELLED_FUNDING_COUNT,
      tmp2.FUNDING_ADJUSTMENT_COUNT,
      tmp2.AR_INVOICE_COUNT,
      tmp2.AR_CASH_APPLIED_COUNT,
      tmp2.AR_INVOICE_WRITEOFF_COUNT,
      tmp2.AR_CREDIT_MEMO_COUNT,
      tmp2.AR_UNAPPR_INVOICE_COUNT,
      tmp2.AR_APPR_INVOICE_COUNT,
      tmp2.AR_COUNT_DUE,
      tmp2.AR_COUNT_OVERDUE
    from
      PJI_FM_DNGL_ACT       tmp2,
      PJI_FM_PROJ_BATCH_MAP map,
      PJI_ORG_EXTR_INFO     prj_info,
      PJI_FM_AGGR_DLY_RATES     gl_rt,
      PJI_FM_AGGR_DLY_RATES     pa_rt
    where
      tmp2.WORKER_ID            = 0                      and
      map.WORKER_ID             = p_worker_id            and
      map.PROJECT_ID            = tmp2.PROJECT_ID        and
      tmp2.PROJECT_ORG_ID       = prj_info.ORG_ID        and
      gl_rt.WORKER_ID           = -1                     and
      tmp2.GL_TIME_ID           = gl_rt.TIME_ID          and
      prj_info.PF_CURRENCY_CODE = gl_rt.PF_CURRENCY_CODE and
      pa_rt.WORKER_ID           = -1                     and
      tmp2.PA_TIME_ID           = pa_rt.TIME_ID          and
      prj_info.PF_CURRENCY_CODE = pa_rt.PF_CURRENCY_CODE
    ) tmp2;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.DANGLING_ACT_ROWS(p_worker_id);');

    commit;

  end DANGLING_ACT_ROWS;


  -- -----------------------------------------------------
  -- procedure PURGE_DANGLING_FIN_ROWS
  -- -----------------------------------------------------
  procedure PURGE_DANGLING_FIN_ROWS (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.PURGE_DANGLING_FIN_ROWS(p_worker_id);')) then
      return;
    end if;

    /* delete /*+ parallel(fin)
    from   PJI_FM_DNGL_FIN fin
    where  WORKER_ID = 0 and
           (RECORD_TYPE = 'M' or
            ROWID in (select ROW_ID
                      from   PJI_FM_AGGR_FIN2
                      where  WORKER_ID = p_worker_id)); */
-- Commented above and added below for Bug 7357456
-- Spliting the above delete into two different deletes statements
    delete from PJI_FM_DNGL_FIN where worker_id = 0 and record_type = 'M';

    delete from PJI_FM_DNGL_FIN where worker_id = 0 and ROWID in (select row_id from PJI_FM_AGGR_FIN2 where worker_id = p_worker_id);
-- End for Bug# 7357456

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.PURGE_DANGLING_FIN_ROWS(p_worker_id);');

    commit;

  end PURGE_DANGLING_FIN_ROWS;


  -- -----------------------------------------------------
  -- procedure PURGE_DANGLING_ACT_ROWS
  -- -----------------------------------------------------
  procedure PURGE_DANGLING_ACT_ROWS (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.PURGE_DANGLING_ACT_ROWS(p_worker_id);')) then
      return;
    end if;

    delete /*+ parallel(act) */
    from   PJI_FM_DNGL_ACT act
    where  WORKER_ID = 0 and
           ROWID in (select ROW_ID
                     from   PJI_FM_AGGR_ACT2
                     where  WORKER_ID = p_worker_id);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.PURGE_DANGLING_ACT_ROWS(p_worker_id);');

    commit;

  end PURGE_DANGLING_ACT_ROWS;


  -- -----------------------------------------------------
  -- procedure FIN_SUMMARY
  -- -----------------------------------------------------
  procedure FIN_SUMMARY (p_worker_id in number) is

    l_process           varchar2(30);
    l_schema            varchar2(30);

    l_transition_flag   varchar2(1);
    l_params_cost_flag  varchar2(1);
    l_params_util_flag  varchar2(1);
    l_txn_currency_flag varchar2(1);
    l_g2_currency_flag  varchar2(1);
    l_g1_currency_code  varchar2(30);
    l_g2_currency_code  varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.FIN_SUMMARY(p_worker_id);')) then
      return;
    end if;

    l_transition_flag :=
          PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process,
                                                 'TRANSITION');

    if (l_transition_flag = 'Y') then

      l_params_cost_flag :=
      nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process,
                                                 'CONFIG_COST_FLAG'), 'N');
      l_params_util_flag :=
      nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process,
                                                 'CONFIG_UTIL_FLAG'), 'N');

    else -- l_transition is null or 'N'

      l_params_cost_flag :=
                         nvl(PJI_UTILS.GET_PARAMETER('CONFIG_COST_FLAG'), 'N');
      l_params_util_flag :=
                         nvl(PJI_UTILS.GET_PARAMETER('CONFIG_UTIL_FLAG'), 'N');

    end if;

    select
      TXN_CURR_FLAG,
      GLOBAL_CURR2_FLAG
    into
      l_txn_currency_flag,
      l_g2_currency_flag
    from
      PJI_SYSTEM_SETTINGS;

    l_g1_currency_code := PJI_UTILS.GET_GLOBAL_PRIMARY_CURRENCY;
    l_g2_currency_code := PJI_UTILS.GET_GLOBAL_SECONDARY_CURRENCY;

    insert /*+ noappend parallel(fin2_i) */ into PJI_FM_AGGR_FIN2 fin2_i  --  in FIN_SUMMARY
    (     --Bug 7139059
      WORKER_ID,
      DANGLING_RECVR_GL_RATE_FLAG,
      DANGLING_RECVR_GL_RATE2_FLAG,
      DANGLING_RECVR_PA_RATE_FLAG,
      DANGLING_RECVR_PA_RATE2_FLAG,
      DANGLING_PRVDR_EN_TIME_FLAG,
      DANGLING_RECVR_EN_TIME_FLAG,
      DANGLING_EXP_EN_TIME_FLAG,
      DANGLING_PRVDR_GL_TIME_FLAG,
      DANGLING_RECVR_GL_TIME_FLAG,
      DANGLING_EXP_GL_TIME_FLAG,
      DANGLING_PRVDR_PA_TIME_FLAG,
      DANGLING_RECVR_PA_TIME_FLAG,
      DANGLING_EXP_PA_TIME_FLAG,
      ROW_ID,
      PJI_PROJECT_RECORD_FLAG,
      PJI_RESOURCE_RECORD_FLAG,
      RECORD_TYPE,
      CMT_RECORD_TYPE,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      EXP_EVT_TYPE_ID,
      WORK_TYPE_ID,
      JOB_ID,
      TASK_ID,
      VENDOR_ID,
      EXPENDITURE_TYPE,
      EVENT_TYPE,
      EVENT_TYPE_CLASSIFICATION,
      EXPENDITURE_CATEGORY,
      REVENUE_CATEGORY,
      NON_LABOR_RESOURCE,
      BOM_LABOR_RESOURCE_ID,
      BOM_EQUIPMENT_RESOURCE_ID,
      INVENTORY_ITEM_ID,
      PO_LINE_ID,
      ASSIGNMENT_ID,
      SYSTEM_LINKAGE_FUNCTION,
      RESOURCE_CLASS_CODE,
      RECVR_GL_TIME_ID,
      GL_PERIOD_NAME,
      PRVDR_GL_TIME_ID,
      RECVR_PA_TIME_ID,
      PA_PERIOD_NAME,
      PRVDR_PA_TIME_ID,
      EXPENDITURE_ITEM_TIME_ID,
      PJ_GL_CALENDAR_ID,
      PJ_PA_CALENDAR_ID,
      RS_GL_CALENDAR_ID,
      RS_PA_CALENDAR_ID,
      PRJ_REVENUE,
      PRJ_LABOR_REVENUE,
      PRJ_REVENUE_WRITEOFF,
      PRJ_RAW_COST,
      PRJ_BRDN_COST,
      PRJ_BILL_RAW_COST,
      PRJ_BILL_BRDN_COST,
      PRJ_LABOR_RAW_COST,
      PRJ_LABOR_BRDN_COST,
      PRJ_BILL_LABOR_RAW_COST,
      PRJ_BILL_LABOR_BRDN_COST,
      POU_REVENUE,
      POU_LABOR_REVENUE,
      POU_REVENUE_WRITEOFF,
      POU_RAW_COST,
      POU_BRDN_COST,
      POU_BILL_RAW_COST,
      POU_BILL_BRDN_COST,
      POU_LABOR_RAW_COST,
      POU_LABOR_BRDN_COST,
      POU_BILL_LABOR_RAW_COST,
      POU_BILL_LABOR_BRDN_COST,
      EOU_RAW_COST,
      EOU_BRDN_COST,
      EOU_BILL_RAW_COST,
      EOU_BILL_BRDN_COST,
      TXN_CURRENCY_CODE,
      TXN_REVENUE,
      TXN_RAW_COST,
      TXN_BRDN_COST,
      TXN_BILL_RAW_COST,
      TXN_BILL_BRDN_COST,
      LABOR_HRS,
      BILL_LABOR_HRS,
      GG1_REVENUE,
      GG1_LABOR_REVENUE,
      GG1_REVENUE_WRITEOFF,
      GG1_RAW_COST,
      GG1_BRDN_COST,
      GG1_BILL_RAW_COST,
      GG1_BILL_BRDN_COST,
      GG1_LABOR_RAW_COST,
      GG1_LABOR_BRDN_COST,
      GG1_BILL_LABOR_RAW_COST,
      GG1_BILL_LABOR_BRDN_COST,
      GP1_REVENUE,
      GP1_LABOR_REVENUE,
      GP1_REVENUE_WRITEOFF,
      GP1_RAW_COST,
      GP1_BRDN_COST,
      GP1_BILL_RAW_COST,
      GP1_BILL_BRDN_COST,
      GP1_LABOR_RAW_COST,
      GP1_LABOR_BRDN_COST,
      GP1_BILL_LABOR_RAW_COST,
      GP1_BILL_LABOR_BRDN_COST,
      GG2_REVENUE,
      GG2_LABOR_REVENUE,
      GG2_REVENUE_WRITEOFF,
      GG2_RAW_COST,
      GG2_BRDN_COST,
      GG2_BILL_RAW_COST,
      GG2_BILL_BRDN_COST,
      GG2_LABOR_RAW_COST,
      GG2_LABOR_BRDN_COST,
      GG2_BILL_LABOR_RAW_COST,
      GG2_BILL_LABOR_BRDN_COST,
      GP2_REVENUE,
      GP2_LABOR_REVENUE,
      GP2_REVENUE_WRITEOFF,
      GP2_RAW_COST,
      GP2_BRDN_COST,
      GP2_BILL_RAW_COST,
      GP2_BILL_BRDN_COST,
      GP2_LABOR_RAW_COST,
      GP2_LABOR_BRDN_COST,
      GP2_BILL_LABOR_RAW_COST,
      GP2_BILL_LABOR_BRDN_COST,
      TOTAL_HRS_A,
      BILL_HRS_A
    )
    select
      tmp1.WORKER_ID,
      tmp1.DANGLING_RECVR_GL_RATE_FLAG,
      tmp1.DANGLING_RECVR_GL_RATE2_FLAG,
      tmp1.DANGLING_RECVR_PA_RATE_FLAG,
      tmp1.DANGLING_RECVR_PA_RATE2_FLAG,
      tmp1.DANGLING_PRVDR_EN_TIME_FLAG,
      tmp1.DANGLING_RECVR_EN_TIME_FLAG,
      tmp1.DANGLING_EXP_EN_TIME_FLAG,
      tmp1.DANGLING_PRVDR_GL_TIME_FLAG,
      tmp1.DANGLING_RECVR_GL_TIME_FLAG,
      tmp1.DANGLING_EXP_GL_TIME_FLAG,
      tmp1.DANGLING_PRVDR_PA_TIME_FLAG,
      tmp1.DANGLING_RECVR_PA_TIME_FLAG,
      tmp1.DANGLING_EXP_PA_TIME_FLAG,
      null ROW_ID,
      decode(l_params_cost_flag,
             'N', 'N', tmp1.PJI_PROJECT_RECORD_FLAG) PJI_PROJECT_RECORD_FLAG,
      decode(l_params_util_flag,
             'N', 'N', tmp1.PJI_RESOURCE_RECORD_FLAG) PJI_RESOURCE_RECORD_FLAG,
      'A' RECORD_TYPE,
      null CMT_RECORD_TYPE,
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.PROJECT_TYPE_CLASS,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.EXP_EVT_TYPE_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
      tmp1.TASK_ID,
      tmp1.VENDOR_ID,
      tmp1.EXPENDITURE_TYPE,
      tmp1.EVENT_TYPE,
      tmp1.EVENT_TYPE_CLASSIFICATION,
      tmp1.EXPENDITURE_CATEGORY,
      tmp1.REVENUE_CATEGORY,
      tmp1.NON_LABOR_RESOURCE,
      tmp1.BOM_LABOR_RESOURCE_ID,
      tmp1.BOM_EQUIPMENT_RESOURCE_ID,
      tmp1.INVENTORY_ITEM_ID,
      tmp1.PO_LINE_ID,
      tmp1.ASSIGNMENT_ID,
      tmp1.SYSTEM_LINKAGE_FUNCTION,
      tmp1.RESOURCE_CLASS_CODE,
      tmp1.RECVR_GL_TIME_ID,
      tmp1.GL_PERIOD_NAME,
      tmp1.PRVDR_GL_TIME_ID,
      tmp1.RECVR_PA_TIME_ID,
      tmp1.PA_PERIOD_NAME,
      tmp1.PRVDR_PA_TIME_ID,
      tmp1.EXPENDITURE_ITEM_TIME_ID,
      tmp1.PJ_GL_CALENDAR_ID,
      tmp1.PJ_PA_CALENDAR_ID,
      tmp1.RS_GL_CALENDAR_ID,
      tmp1.RS_PA_CALENDAR_ID,
      tmp1.PRJ_REVENUE,
      tmp1.PRJ_LABOR_REVENUE,
      tmp1.PRJ_REVENUE_WRITEOFF,
      tmp1.PRJ_RAW_COST,
      tmp1.PRJ_BRDN_COST,
      tmp1.PRJ_BILL_RAW_COST,
      tmp1.PRJ_BILL_BRDN_COST,
      tmp1.PRJ_LABOR_RAW_COST,
      tmp1.PRJ_LABOR_BRDN_COST,
      tmp1.PRJ_BILL_LABOR_RAW_COST,
      tmp1.PRJ_BILL_LABOR_BRDN_COST,
      tmp1.POU_REVENUE,
      tmp1.POU_LABOR_REVENUE,
      tmp1.POU_REVENUE_WRITEOFF,
      tmp1.POU_RAW_COST,
      tmp1.POU_BRDN_COST,
      tmp1.POU_BILL_RAW_COST,
      tmp1.POU_BILL_BRDN_COST,
      tmp1.POU_LABOR_RAW_COST,
      tmp1.POU_LABOR_BRDN_COST,
      tmp1.POU_BILL_LABOR_RAW_COST,
      tmp1.POU_BILL_LABOR_BRDN_COST,
      tmp1.EOU_RAW_COST,
      tmp1.EOU_BRDN_COST,
      tmp1.EOU_BILL_RAW_COST,
      tmp1.EOU_BILL_BRDN_COST,
      tmp1.TXN_CURRENCY_CODE,
      tmp1.TXN_REVENUE,
      tmp1.TXN_RAW_COST,
      tmp1.TXN_BRDN_COST,
      tmp1.TXN_BILL_RAW_COST,
      tmp1.TXN_BILL_BRDN_COST,
      tmp1.LABOR_HRS,
      tmp1.BILL_LABOR_HRS,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp1.TXN_REVENUE,
                          round(tmp1.POU_REVENUE *
                                tmp1.PRJ_GL_RATE1 /
                                PRJ_GL_MAU1) * PRJ_GL_MAU1),
                   to_number(null))            GG1_REVENUE,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g1_currency_code,
                   --        tmp1.TXN_LABOR_REVENUE,
                          round(tmp1.POU_LABOR_REVENUE *
                                tmp1.PRJ_GL_RATE1 /
                                PRJ_GL_MAU1) * PRJ_GL_MAU1
                   -- )
                   ,
                   to_number(null))            GG1_LABOR_REVENUE,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g1_currency_code,
                   --        tmp1.TXN_REVENUE_WRITEOFF,
                          round(tmp1.POU_REVENUE_WRITEOFF *
                                tmp1.PRJ_GL_RATE1 /
                                PRJ_GL_MAU1) * PRJ_GL_MAU1
                   -- )
                   ,
                   to_number(null))            GG1_REVENUE_WRITEOFF,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp1.TXN_RAW_COST,
                          round(tmp1.POU_RAW_COST *
                                tmp1.PRJ_GL_RATE1 /
                                PRJ_GL_MAU1) * PRJ_GL_MAU1),
                   to_number(null))            GG1_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp1.TXN_BRDN_COST,
                          round(tmp1.POU_BRDN_COST *
                                tmp1.PRJ_GL_RATE1 /
                                PRJ_GL_MAU1) * PRJ_GL_MAU1),
                   to_number(null))            GG1_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp1.TXN_BILL_RAW_COST,
                          round(tmp1.POU_BILL_RAW_COST *
                                tmp1.PRJ_GL_RATE1 /
                                PRJ_GL_MAU1) * PRJ_GL_MAU1),
                   to_number(null))            GG1_BILL_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp1.TXN_BILL_BRDN_COST,
                          round(tmp1.POU_BILL_BRDN_COST *
                                tmp1.PRJ_GL_RATE1 /
                                PRJ_GL_MAU1) * PRJ_GL_MAU1),
                   to_number(null))            GG1_BILL_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g1_currency_code,
                   --        tmp1.TXN_LABOR_RAW_COST,
                          round(tmp1.POU_LABOR_RAW_COST *
                                tmp1.PRJ_GL_RATE1 /
                                PRJ_GL_MAU1) * PRJ_GL_MAU1
                   -- )
                   ,
                   to_number(null))            GG1_LABOR_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g1_currency_code,
                   --        tmp1.TXN_LABOR_BRDN_COST,
                          round(tmp1.POU_LABOR_BRDN_COST *
                                tmp1.PRJ_GL_RATE1 /
                                PRJ_GL_MAU1) * PRJ_GL_MAU1
                   -- )
                   ,
                   to_number(null))            GG1_LABOR_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g1_currency_code,
                   --        tmp1.TXN_BILL_LABOR_RAW_COST,
                          round(tmp1.POU_BILL_LABOR_RAW_COST *
                                tmp1.PRJ_GL_RATE1 /
                                PRJ_GL_MAU1) * PRJ_GL_MAU1
                   -- )
                   ,
                   to_number(null))            GG1_BILL_LABOR_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g1_currency_code,
                   --        tmp1.TXN_BILL_LABOR_BRDN_COST,
                          round(tmp1.POU_BILL_LABOR_BRDN_COST *
                                tmp1.PRJ_GL_RATE1 /
                                PRJ_GL_MAU1) * PRJ_GL_MAU1
                   -- )
                   ,
                   to_number(null))            GG1_BILL_LABOR_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp1.TXN_REVENUE,
                          round(tmp1.POU_REVENUE *
                                tmp1.PRJ_PA_RATE1 /
                                PRJ_PA_MAU1) * PRJ_PA_MAU1),
                   to_number(null))            GP1_REVENUE,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g1_currency_code,
                   --        tmp1.TXN_LABOR_REVENUE,
                          round(tmp1.POU_LABOR_REVENUE *
                                tmp1.PRJ_PA_RATE1 /
                                PRJ_PA_MAU1) * PRJ_PA_MAU1
                   -- )
                   ,
                   to_number(null))            GP1_LABOR_REVENUE,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g1_currency_code,
                   --        tmp1.TXN_REVENUE_WRITEOFF,
                          round(tmp1.POU_REVENUE_WRITEOFF *
                                tmp1.PRJ_PA_RATE1 /
                                PRJ_PA_MAU1) * PRJ_PA_MAU1
                   -- )
                   ,
                   to_number(null))            GP1_REVENUE_WRITEOFF,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp1.TXN_RAW_COST,
                          round(tmp1.POU_RAW_COST *
                                tmp1.PRJ_PA_RATE1 /
                                PRJ_PA_MAU1) * PRJ_PA_MAU1),
                   to_number(null))            GP1_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp1.TXN_BRDN_COST,
                          round(tmp1.POU_BRDN_COST *
                                tmp1.PRJ_PA_RATE1 /
                                PRJ_PA_MAU1) * PRJ_PA_MAU1),
                   to_number(null))            GP1_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp1.TXN_BILL_RAW_COST,
                          round(tmp1.POU_BILL_RAW_COST *
                                tmp1.PRJ_PA_RATE1 /
                                PRJ_PA_MAU1) * PRJ_PA_MAU1),
                   to_number(null))            GP1_BILL_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g1_currency_code,
                          tmp1.TXN_BILL_BRDN_COST,
                          round(tmp1.POU_BILL_BRDN_COST *
                                tmp1.PRJ_PA_RATE1 /
                                PRJ_PA_MAU1) * PRJ_PA_MAU1),
                   to_number(null))            GP1_BILL_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g1_currency_code,
                   --        tmp1.TXN_LABOR_RAW_COST,
                          round(tmp1.POU_LABOR_RAW_COST *
                                tmp1.PRJ_PA_RATE1 /
                                PRJ_PA_MAU1) * PRJ_PA_MAU1
                   -- )
                   ,
                   to_number(null))            GP1_LABOR_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g1_currency_code,
                   --        tmp1.TXN_LABOR_BRDN_COST,
                          round(tmp1.POU_LABOR_BRDN_COST *
                                tmp1.PRJ_PA_RATE1 /
                                PRJ_PA_MAU1) * PRJ_PA_MAU1
                   -- )
                   ,
                   to_number(null))            GP1_LABOR_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g1_currency_code,
                   --        tmp1.TXN_BILL_LABOR_RAW_COST,
                          round(tmp1.POU_BILL_LABOR_RAW_COST *
                                tmp1.PRJ_PA_RATE1 /
                                PRJ_PA_MAU1) * PRJ_PA_MAU1
                   -- )
                   ,
                   to_number(null))            GP1_BILL_LABOR_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g1_currency_code,
                   --        tmp1.TXN_BILL_LABOR_BRDN_COST,
                          round(tmp1.POU_BILL_LABOR_BRDN_COST *
                                tmp1.PRJ_PA_RATE1 /
                                PRJ_PA_MAU1) * PRJ_PA_MAU1
                   -- )
                   ,
                   to_number(null))            GP1_BILL_LABOR_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp1.TXN_REVENUE,
                          round(tmp1.POU_REVENUE *
                                tmp1.PRJ_GL_RATE2 /
                                PRJ_GL_MAU2) * PRJ_GL_MAU2),
                   to_number(null))            GG2_REVENUE,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g2_currency_code,
                   --        tmp1.TXN_LABOR_REVENUE,
                          round(tmp1.POU_LABOR_REVENUE *
                                tmp1.PRJ_GL_RATE2 /
                                PRJ_GL_MAU2) * PRJ_GL_MAU2
                   -- )
                   ,
                   to_number(null))            GG2_LABOR_REVENUE,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g2_currency_code,
                   --        tmp1.TXN_REVENUE_WRITEOFF,
                          round(tmp1.POU_REVENUE_WRITEOFF *
                                tmp1.PRJ_GL_RATE2 /
                                PRJ_GL_MAU2) * PRJ_GL_MAU2
                   -- )
                   ,
                   to_number(null))            GG2_REVENUE_WRITEOFF,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp1.TXN_RAW_COST,
                          round(tmp1.POU_RAW_COST *
                                tmp1.PRJ_GL_RATE2 /
                                PRJ_GL_MAU2) * PRJ_GL_MAU2),
                   to_number(null))            GG2_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp1.TXN_BRDN_COST,
                          round(tmp1.POU_BRDN_COST *
                                tmp1.PRJ_GL_RATE2 /
                                PRJ_GL_MAU2) * PRJ_GL_MAU2),
                   to_number(null))            GG2_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp1.TXN_BILL_RAW_COST,
                          round(tmp1.POU_BILL_RAW_COST *
                                tmp1.PRJ_GL_RATE2 /
                                PRJ_GL_MAU2) * PRJ_GL_MAU2),
                   to_number(null))            GG2_BILL_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp1.TXN_BILL_BRDN_COST,
                          round(tmp1.POU_BILL_BRDN_COST *
                                tmp1.PRJ_GL_RATE2 /
                                PRJ_GL_MAU2) * PRJ_GL_MAU2),
                   to_number(null))            GG2_BILL_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g2_currency_code,
                   --        tmp1.TXN_LABOR_RAW_COST,
                          round(tmp1.POU_LABOR_RAW_COST *
                                tmp1.PRJ_GL_RATE2 /
                                PRJ_GL_MAU2) * PRJ_GL_MAU2
                   -- )
                   ,
                   to_number(null))            GG2_LABOR_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g2_currency_code,
                   --        tmp1.TXN_LABOR_BRDN_COST,
                          round(tmp1.POU_LABOR_BRDN_COST *
                                tmp1.PRJ_GL_RATE2 /
                                PRJ_GL_MAU2) * PRJ_GL_MAU2
                   -- )
                   ,
                   to_number(null))            GG2_LABOR_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g2_currency_code,
                   --        tmp1.TXN_BILL_LABOR_RAW_COST,
                          round(tmp1.POU_BILL_LABOR_RAW_COST *
                                tmp1.PRJ_GL_RATE2 /
                                PRJ_GL_MAU2) * PRJ_GL_MAU2
                   -- )
                   ,
                   to_number(null))            GG2_BILL_LABOR_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g2_currency_code,
                   --        tmp1.TXN_BILL_LABOR_BRDN_COST,
                          round(tmp1.POU_BILL_LABOR_BRDN_COST *
                                tmp1.PRJ_GL_RATE2 /
                                PRJ_GL_MAU2) * PRJ_GL_MAU2
                   -- )
                   ,
                   to_number(null))            GG2_BILL_LABOR_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp1.TXN_REVENUE,
                          round(tmp1.POU_REVENUE *
                                tmp1.PRJ_PA_RATE2 /
                                PRJ_PA_MAU2) * PRJ_PA_MAU2),
                   to_number(null))            GP2_REVENUE,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g2_currency_code,
                   --        tmp1.TXN_LABOR_REVENUE,
                          round(tmp1.POU_LABOR_REVENUE *
                                tmp1.PRJ_PA_RATE2 /
                                PRJ_PA_MAU2) * PRJ_PA_MAU2
                   -- )
                   ,
                   to_number(null))            GP2_LABOR_REVENUE,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g2_currency_code,
                   --        tmp1.TXN_REVENUE_WRITEOFF,
                          round(tmp1.POU_REVENUE_WRITEOFF *
                                tmp1.PRJ_PA_RATE2 /
                                PRJ_PA_MAU2) * PRJ_PA_MAU2
                   -- )
                   ,
                   to_number(null))            GP2_REVENUE_WRITEOFF,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp1.TXN_RAW_COST,
                          round(tmp1.POU_RAW_COST *
                                tmp1.PRJ_PA_RATE2 /
                                PRJ_PA_MAU2) * PRJ_PA_MAU2),
                   to_number(null))            GP2_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp1.TXN_BRDN_COST,
                          round(tmp1.POU_BRDN_COST *
                                tmp1.PRJ_PA_RATE2 /
                                PRJ_PA_MAU2) * PRJ_PA_MAU2),
                   to_number(null))            GP2_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp1.TXN_BILL_RAW_COST,
                          round(tmp1.POU_BILL_RAW_COST *
                                tmp1.PRJ_PA_RATE2 /
                                PRJ_PA_MAU2) * PRJ_PA_MAU2),
                   to_number(null))            GP2_BILL_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', decode(tmp1.TXN_CURRENCY_CODE,
                          l_g2_currency_code,
                          tmp1.TXN_BILL_BRDN_COST,
                          round(tmp1.POU_BILL_BRDN_COST *
                                tmp1.PRJ_PA_RATE2 /
                                PRJ_PA_MAU2) * PRJ_PA_MAU2),
                   to_number(null))            GP2_BILL_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g2_currency_code,
                   --        tmp1.TXN_LABOR_RAW_COST,
                          round(tmp1.POU_LABOR_RAW_COST *
                                tmp1.PRJ_PA_RATE2 /
                                PRJ_PA_MAU2) * PRJ_PA_MAU2
                   -- )
                   ,
                   to_number(null))            GP2_LABOR_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g2_currency_code,
                   --        tmp1.TXN_LABOR_BRDN_COST,
                          round(tmp1.POU_LABOR_BRDN_COST *
                                tmp1.PRJ_PA_RATE2 /
                                PRJ_PA_MAU2) * PRJ_PA_MAU2
                   -- )
                   ,
                   to_number(null))            GP2_LABOR_BRDN_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g2_currency_code,
                   --        tmp1.TXN_BILL_LABOR_RAW_COST,
                          round(tmp1.POU_BILL_LABOR_RAW_COST *
                                tmp1.PRJ_PA_RATE2 /
                                PRJ_PA_MAU2) * PRJ_PA_MAU2
                   -- )
                   ,
                   to_number(null))            GP2_BILL_LABOR_RAW_COST,
      decode(nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N') ||
             sign(tmp1.WORKER_ID),
             'Y1', -- decode(tmp1.TXN_CURRENCY_CODE,
                   --        l_g2_currency_code,
                   --        tmp1.TXN_BILL_LABOR_BRDN_COST,
                          round(tmp1.POU_BILL_LABOR_BRDN_COST *
                                tmp1.PRJ_PA_RATE2 /
                                PRJ_PA_MAU2) * PRJ_PA_MAU2
                   -- )
                   ,
                   to_number(null))            GP2_BILL_LABOR_BRDN_COST,
      tmp1.TOTAL_HRS_A,
      tmp1.BILL_HRS_A
    from
    (
    select /*+ ordered use_hash(tmp1,prj_info,res_info,prj_gl_rt,prj_pa_rt) full(tmp1) parallel(tmp1)
               full(prj_info)  swap_join_inputs(prj_info) full(res_info)  swap_join_inputs(res_info)
               full(prj_gl_rt) swap_join_inputs(prj_gl_rt) full(prj_pa_rt) swap_join_inputs(prj_pa_rt)
               pq_distribute(prj_gl_rt,none,broadcast) pq_distribute(prj_pa_rt,none,broadcast)
            */  -- bug 3092751: Changes in hints
      to_number(p_worker_id)                   WORKER_ID,
      decode(tmp1.PJI_PROJECT_RECORD_FLAG,
             'Y', decode(prj_gl_rt.RATE,
                         -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                         decode(sign(prj_gl_rt.RATE),
                                -1, 'Y', null)),
             null)                             DANGLING_RECVR_GL_RATE_FLAG,
      decode(tmp1.PJI_PROJECT_RECORD_FLAG || l_g2_currency_flag,
             'YY', decode(prj_gl_rt.RATE2,
                          -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                          decode(sign(prj_gl_rt.RATE2),
                                 -1, 'Y', null)),
             null)                             DANGLING_RECVR_GL_RATE2_FLAG,
      decode(tmp1.PJI_PROJECT_RECORD_FLAG,
             'Y', decode(prj_pa_rt.RATE,
                         -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                         decode(sign(prj_pa_rt.RATE),
                                -1, 'Y', null)),
             null)                             DANGLING_RECVR_PA_RATE_FLAG,
      decode(tmp1.PJI_PROJECT_RECORD_FLAG || l_g2_currency_flag,
             'YY', decode(prj_pa_rt.RATE2,
                          -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                          decode(sign(prj_pa_rt.RATE2),
                                 -1, 'Y', null)),
             null)                             DANGLING_RECVR_PA_RATE2_FLAG,
      --case when tmp1.PJI_RESOURCE_RECORD_FLAG = 'Y' and
      --          (tmp1.PRVDR_GL_TIME_ID < res_info.EN_CALENDAR_MIN_DATE or
      --           tmp1.PRVDR_GL_TIME_ID > res_info.EN_CALENDAR_MAX_DATE)
      --     then 'Y'
      --     else null
      --     end                                 DANGLING_PRVDR_EN_TIME_FLAG,
      null                                     DANGLING_PRVDR_EN_TIME_FLAG,
      decode(tmp1.PJI_PROJECT_RECORD_FLAG,
             'Y', decode(sign(prj_info.EN_CALENDAR_MIN_DATE -
                              tmp1.RECVR_GL_TIME_ID) +
                         sign(tmp1.RECVR_GL_TIME_ID -
                              prj_info.EN_CALENDAR_MAX_DATE),
                         0, 'Y', null), null)  DANGLING_RECVR_EN_TIME_FLAG,
      decode(tmp1.PJI_RESOURCE_RECORD_FLAG,
             'Y', decode(sign(res_info.EN_CALENDAR_MIN_DATE -
                              tmp1.EXPENDITURE_ITEM_TIME_ID) +
                         sign(tmp1.EXPENDITURE_ITEM_TIME_ID -
                              res_info.EN_CALENDAR_MAX_DATE),
                         0, 'Y', null), null)  DANGLING_EXP_EN_TIME_FLAG,
      --case when tmp1.PJI_RESOURCE_RECORD_FLAG = 'Y' and
      --          (tmp1.PRVDR_GL_TIME_ID < res_info.GL_CALENDAR_MIN_DATE or
      --           tmp1.PRVDR_GL_TIME_ID > res_info.GL_CALENDAR_MAX_DATE)
      --     then 'Y'
      --     else null
      --     end                                 DANGLING_PRVDR_GL_TIME_FLAG,
      null                                     DANGLING_PRVDR_GL_TIME_FLAG,
      decode(tmp1.PJI_PROJECT_RECORD_FLAG,
             'Y', decode(sign(prj_info.GL_CALENDAR_MIN_DATE -
                              tmp1.RECVR_GL_TIME_ID) +
                         sign(tmp1.RECVR_GL_TIME_ID -
                              prj_info.GL_CALENDAR_MAX_DATE),
                         0, 'Y', null), null)  DANGLING_RECVR_GL_TIME_FLAG,
      decode(tmp1.PJI_RESOURCE_RECORD_FLAG,
             'Y', decode(sign(res_info.GL_CALENDAR_MIN_DATE -
                              tmp1.EXPENDITURE_ITEM_TIME_ID) +
                         sign(tmp1.EXPENDITURE_ITEM_TIME_ID -
                              res_info.GL_CALENDAR_MAX_DATE),
                         0, 'Y', null), null)  DANGLING_EXP_GL_TIME_FLAG,
      --case when tmp1.PJI_RESOURCE_RECORD_FLAG = 'Y' and
      --          (tmp1.PRVDR_PA_TIME_ID < res_info.PA_CALENDAR_MIN_DATE or
      --           tmp1.PRVDR_PA_TIME_ID > res_info.PA_CALENDAR_MAX_DATE)
      --     then 'Y'
      --     else null
      --     end                                 DANGLING_PRVDR_PA_TIME_FLAG,
      null                                     DANGLING_PRVDR_PA_TIME_FLAG,
      decode(tmp1.PJI_PROJECT_RECORD_FLAG,
             'Y', decode(sign(prj_info.PA_CALENDAR_MIN_DATE -
                              tmp1.RECVR_PA_TIME_ID) +
                         sign(tmp1.RECVR_PA_TIME_ID -
                              prj_info.PA_CALENDAR_MAX_DATE),
                         0, 'Y', null), null)  DANGLING_RECVR_PA_TIME_FLAG,
      decode(tmp1.PJI_RESOURCE_RECORD_FLAG,
             'Y', decode(sign(res_info.PA_CALENDAR_MIN_DATE -
                              tmp1.EXPENDITURE_ITEM_TIME_ID) +
                         sign(tmp1.EXPENDITURE_ITEM_TIME_ID -
                              res_info.PA_CALENDAR_MAX_DATE),
                         0, 'Y', null), null)  DANGLING_EXP_PA_TIME_FLAG,
      tmp1.PJI_PROJECT_RECORD_FLAG,
      tmp1.PJI_RESOURCE_RECORD_FLAG,
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.PROJECT_TYPE_CLASS,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.EXP_EVT_TYPE_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
      tmp1.TASK_ID,
      tmp1.VENDOR_ID,
      tmp1.EXPENDITURE_TYPE,
      tmp1.EVENT_TYPE,
      tmp1.EVENT_TYPE_CLASSIFICATION,
      tmp1.EXPENDITURE_CATEGORY,
      tmp1.REVENUE_CATEGORY,
      tmp1.NON_LABOR_RESOURCE,
      tmp1.BOM_LABOR_RESOURCE_ID,
      tmp1.BOM_EQUIPMENT_RESOURCE_ID,
      tmp1.INVENTORY_ITEM_ID,
      tmp1.PO_LINE_ID,
      tmp1.ASSIGNMENT_ID,
      tmp1.SYSTEM_LINKAGE_FUNCTION,
      'PJI$NULL'                               RESOURCE_CLASS_CODE,
      tmp1.RECVR_GL_TIME_ID,
      tmp1.GL_PERIOD_NAME,
      tmp1.PRVDR_GL_TIME_ID,
      tmp1.RECVR_PA_TIME_ID,
      tmp1.PA_PERIOD_NAME,
      tmp1.PRVDR_PA_TIME_ID,
      tmp1.EXPENDITURE_ITEM_TIME_ID,
      prj_info.GL_CALENDAR_ID                  PJ_GL_CALENDAR_ID,
      prj_info.PA_CALENDAR_ID                  PJ_PA_CALENDAR_ID,
      res_info.GL_CALENDAR_ID                  RS_GL_CALENDAR_ID,
      res_info.PA_CALENDAR_ID                  RS_PA_CALENDAR_ID,
      prj_gl_rt.RATE                           PRJ_GL_RATE1,
      prj_gl_rt.RATE2                          PRJ_GL_RATE2,
      prj_pa_rt.RATE                           PRJ_PA_RATE1,
      prj_pa_rt.RATE2                          PRJ_PA_RATE2,
      prj_gl_rt.MAU                            PRJ_GL_MAU1,
      prj_gl_rt.MAU2                           PRJ_GL_MAU2,
      prj_pa_rt.MAU                            PRJ_PA_MAU1,
      prj_pa_rt.MAU2                           PRJ_PA_MAU2,
      tmp1.PRJ_REVENUE,
      tmp1.PRJ_LABOR_REVENUE,
      tmp1.PRJ_REVENUE_WRITEOFF,
      tmp1.PRJ_RAW_COST,
      tmp1.PRJ_BRDN_COST,
      tmp1.PRJ_BILL_RAW_COST,
      tmp1.PRJ_BILL_BRDN_COST,
      tmp1.PRJ_LABOR_RAW_COST,
      tmp1.PRJ_LABOR_BRDN_COST,
      tmp1.PRJ_BILL_LABOR_RAW_COST,
      tmp1.PRJ_BILL_LABOR_BRDN_COST,
      tmp1.POU_REVENUE,
      tmp1.POU_LABOR_REVENUE,
      tmp1.POU_REVENUE_WRITEOFF,
      tmp1.POU_RAW_COST,
      tmp1.POU_BRDN_COST,
      tmp1.POU_BILL_RAW_COST,
      tmp1.POU_BILL_BRDN_COST,
      tmp1.POU_LABOR_RAW_COST,
      tmp1.POU_LABOR_BRDN_COST,
      tmp1.POU_BILL_LABOR_RAW_COST,
      tmp1.POU_BILL_LABOR_BRDN_COST,
      tmp1.EOU_RAW_COST,
      tmp1.EOU_BRDN_COST,
      tmp1.EOU_BILL_RAW_COST,
      tmp1.EOU_BILL_BRDN_COST,
      tmp1.TXN_CURRENCY_CODE,
      tmp1.TXN_REVENUE,
      tmp1.TXN_RAW_COST,
      tmp1.TXN_BRDN_COST,
      tmp1.TXN_BILL_RAW_COST,
      tmp1.TXN_BILL_BRDN_COST,
      tmp1.LABOR_HRS,
      tmp1.BILL_LABOR_HRS,
      tmp1.TOTAL_HRS_A,
      tmp1.BILL_HRS_A
    from  -- bug 3092751: Changes in table order
      PJI_ORG_EXTR_INFO     prj_info,
    (
    select /*+ parallel(tmp1) */
      decode(l_params_cost_flag,
             'N', 'N',
             tmp1.PJI_PROJECT_RECORD_FLAG) PJI_PROJECT_RECORD_FLAG,
      tmp1.PJI_RESOURCE_RECORD_FLAG,
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.PROJECT_TYPE_CLASS,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.EXP_EVT_TYPE_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
      tmp1.TASK_ID,
      tmp1.VENDOR_ID,
      tmp1.EXPENDITURE_TYPE,
      tmp1.EVENT_TYPE,
      tmp1.EVENT_TYPE_CLASSIFICATION,
      tmp1.EXPENDITURE_CATEGORY,
      tmp1.REVENUE_CATEGORY,
      tmp1.NON_LABOR_RESOURCE,
      tmp1.BOM_LABOR_RESOURCE_ID,
      tmp1.BOM_EQUIPMENT_RESOURCE_ID,
      tmp1.INVENTORY_ITEM_ID,
      tmp1.PO_LINE_ID,
      tmp1.ASSIGNMENT_ID,
      tmp1.SYSTEM_LINKAGE_FUNCTION,
      decode(l_params_cost_flag || nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N'),
             'YY', to_number(to_char(tmp1.RECVR_GL_DATE, 'J')),
             -1)                               RECVR_GL_TIME_ID,
      tmp1.GL_PERIOD_NAME,
      to_number(to_char(tmp1.PRVDR_GL_DATE,
                        'J'))                  PRVDR_GL_TIME_ID,
      decode(l_params_cost_flag || nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N'),
             'YY', to_number(to_char(tmp1.RECVR_PA_DATE, 'J')),
             -1)                               RECVR_PA_TIME_ID,
      tmp1.PA_PERIOD_NAME,
      to_number(to_char(tmp1.PRVDR_PA_DATE,
                        'J'))                  PRVDR_PA_TIME_ID,
      to_number(to_char(tmp1.EXPENDITURE_ITEM_DATE,
                        'J'))                  EXPENDITURE_ITEM_TIME_ID,
      sum(tmp1.PRJ_REVENUE)                    PRJ_REVENUE,
      sum(decode(tmp1.SYSTEM_LINKAGE_FUNCTION,
                 'ST', tmp1.PRJ_REVENUE,
                 'OT', tmp1.PRJ_REVENUE, 0))   PRJ_LABOR_REVENUE,
      sum(decode(tmp1.EVENT_TYPE_CLASSIFICATION,
                 'WRITE OFF',
                 tmp1.PRJ_REVENUE, 0))         PRJ_REVENUE_WRITEOFF,
      sum(tmp1.PRJ_RAW_COST)                   PRJ_RAW_COST,
      sum(tmp1.PRJ_BURDENED_COST)              PRJ_BRDN_COST,
      sum(tmp1.PRJ_BILL_RAW_COST)              PRJ_BILL_RAW_COST,
      sum(tmp1.PRJ_BILL_BURDENED_COST)         PRJ_BILL_BRDN_COST,
      sum(decode(tmp1.SYSTEM_LINKAGE_FUNCTION,
                 'ST', tmp1.PRJ_RAW_COST,
                 'OT', tmp1.PRJ_RAW_COST, 0))  PRJ_LABOR_RAW_COST,
      sum(decode(tmp1.SYSTEM_LINKAGE_FUNCTION,
                 'ST', tmp1.PRJ_BURDENED_COST,
                 'OT', tmp1.PRJ_BURDENED_COST,
                 0))                           PRJ_LABOR_BRDN_COST,
      sum(decode(tmp1.SYSTEM_LINKAGE_FUNCTION,
                 'ST', tmp1.PRJ_BILL_RAW_COST,
                 'OT', tmp1.PRJ_BILL_RAW_COST,
                 0))                           PRJ_BILL_LABOR_RAW_COST,
      sum(decode(tmp1.SYSTEM_LINKAGE_FUNCTION,
                 'ST', tmp1.PRJ_BILL_BURDENED_COST,
                 'OT', tmp1.PRJ_BILL_BURDENED_COST,
                 0))                           PRJ_BILL_LABOR_BRDN_COST,
      sum(tmp1.POU_REVENUE)                    POU_REVENUE,
      sum(decode(tmp1.SYSTEM_LINKAGE_FUNCTION,
                 'ST', tmp1.POU_REVENUE,
                 'OT', tmp1.POU_REVENUE, 0))   POU_LABOR_REVENUE,
      sum(decode(tmp1.EVENT_TYPE_CLASSIFICATION,
                 'WRITE OFF',
                 tmp1.POU_REVENUE, 0))         POU_REVENUE_WRITEOFF,
      sum(tmp1.POU_RAW_COST)                   POU_RAW_COST,
      sum(tmp1.POU_BURDENED_COST)              POU_BRDN_COST,
      sum(tmp1.POU_BILL_RAW_COST)              POU_BILL_RAW_COST,
      sum(tmp1.POU_BILL_BURDENED_COST)         POU_BILL_BRDN_COST,
      sum(decode(tmp1.SYSTEM_LINKAGE_FUNCTION,
                 'ST', tmp1.POU_RAW_COST,
                 'OT', tmp1.POU_RAW_COST,
                 0))                           POU_LABOR_RAW_COST,
      sum(decode(tmp1.SYSTEM_LINKAGE_FUNCTION,
                 'ST', tmp1.POU_BURDENED_COST,
                 'OT', tmp1.POU_BURDENED_COST,
                 0))                           POU_LABOR_BRDN_COST,
      sum(decode(tmp1.SYSTEM_LINKAGE_FUNCTION,
                 'ST', tmp1.POU_BILL_RAW_COST,
                 'OT', tmp1.POU_BILL_RAW_COST,
                 0))                           POU_BILL_LABOR_RAW_COST,
      sum(decode(tmp1.SYSTEM_LINKAGE_FUNCTION,
                 'ST', tmp1.POU_BILL_BURDENED_COST,
                 'OT', tmp1.POU_BILL_BURDENED_COST,
                 0))                           POU_BILL_LABOR_BRDN_COST,
      sum(tmp1.EOU_RAW_COST)                   EOU_RAW_COST,
      sum(tmp1.EOU_BURDENED_COST)              EOU_BRDN_COST,
      sum(tmp1.EOU_BILL_RAW_COST)              EOU_BILL_RAW_COST,
      sum(tmp1.EOU_BILL_BURDENED_COST)         EOU_BILL_BRDN_COST,
      tmp1.TXN_CURRENCY_CODE,
      sum(tmp1.TXN_REVENUE)                    TXN_REVENUE,
      sum(tmp1.TXN_RAW_COST)                   TXN_RAW_COST,
      sum(tmp1.TXN_BURDENED_COST)              TXN_BRDN_COST,
      sum(tmp1.TXN_BILL_RAW_COST)              TXN_BILL_RAW_COST,
      sum(tmp1.TXN_BILL_BURDENED_COST)         TXN_BILL_BRDN_COST,
      sum(decode(tmp1.SYSTEM_LINKAGE_FUNCTION,
                 'ST', tmp1.QUANTITY,
                 'OT', tmp1.QUANTITY, 0))      LABOR_HRS,
      sum(decode(tmp1.SYSTEM_LINKAGE_FUNCTION,
                 'ST', tmp1.BILL_QUANTITY,
                 'OT', tmp1.BILL_QUANTITY, 0)) BILL_LABOR_HRS,
      sum(tmp1.QUANTITY)                       TOTAL_HRS_A,
      sum(tmp1.BILL_QUANTITY)                  BILL_HRS_A
    from
      PJI_FM_AGGR_FIN1  tmp1
    where
      tmp1.WORKER_ID = p_worker_id and
      tmp1.EXPENDITURE_ORGANIZATION_ID is not null
    group by
      decode(l_params_cost_flag,
             'N', 'N',
             tmp1.PJI_PROJECT_RECORD_FLAG),
      tmp1.PJI_RESOURCE_RECORD_FLAG,
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.PROJECT_TYPE_CLASS,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.EXP_EVT_TYPE_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
      tmp1.TASK_ID,
      tmp1.VENDOR_ID,
      tmp1.EXPENDITURE_TYPE,
      tmp1.EVENT_TYPE,
      tmp1.EVENT_TYPE_CLASSIFICATION,
      tmp1.EXPENDITURE_CATEGORY,
      tmp1.REVENUE_CATEGORY,
      tmp1.NON_LABOR_RESOURCE,
      tmp1.BOM_LABOR_RESOURCE_ID,
      tmp1.BOM_EQUIPMENT_RESOURCE_ID,
      tmp1.INVENTORY_ITEM_ID,
      tmp1.PO_LINE_ID,
      tmp1.ASSIGNMENT_ID,
      tmp1.SYSTEM_LINKAGE_FUNCTION,
      decode(l_params_cost_flag || nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N'),
             'YY', to_number(to_char(tmp1.RECVR_GL_DATE, 'J')),
             -1),
      tmp1.GL_PERIOD_NAME,
      to_number(to_char(tmp1.PRVDR_GL_DATE,
                        'J')),
      decode(l_params_cost_flag || nvl(tmp1.PJI_PROJECT_RECORD_FLAG, 'N'),
             'YY', to_number(to_char(tmp1.RECVR_PA_DATE, 'J')),
             -1),
      tmp1.PA_PERIOD_NAME,
      to_number(to_char(tmp1.PRVDR_PA_DATE,
                        'J')),
      to_number(to_char(tmp1.EXPENDITURE_ITEM_DATE,
                        'J')),
      tmp1.TXN_CURRENCY_CODE
    ) tmp1,
      PJI_ORG_EXTR_INFO     res_info,
      PJI_FM_AGGR_DLY_RATES prj_gl_rt,
      PJI_FM_AGGR_DLY_RATES prj_pa_rt
    where
      tmp1.EXPENDITURE_ORGANIZATION_ID    is not null                  and
      decode(l_params_cost_flag, 'Y', tmp1.PROJECT_ORG_ID, -1)
                                          = prj_info.ORG_ID            and
      decode(l_params_cost_flag, 'Y', tmp1.EXPENDITURE_ORG_ID, -1)
                                          = res_info.ORG_ID            and
      prj_gl_rt.WORKER_ID                 = -1                         and
      tmp1.RECVR_GL_TIME_ID               = prj_gl_rt.TIME_ID          and
      prj_info.PF_CURRENCY_CODE           = prj_gl_rt.PF_CURRENCY_CODE and
      prj_pa_rt.WORKER_ID                 = -1                         and
      tmp1.RECVR_PA_TIME_ID               = prj_pa_rt.TIME_ID          and
      prj_info.PF_CURRENCY_CODE           = prj_pa_rt.PF_CURRENCY_CODE
    ) tmp1;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.FIN_SUMMARY(p_worker_id);');

    -- truncate intermediate tables no longer required
    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_AGGR_FIN1' , 'NORMAL',null);

    commit;

  end FIN_SUMMARY;


  -- -----------------------------------------------------
  -- procedure MOVE_DANGLING_FIN_ROWS
  -- -----------------------------------------------------
  procedure MOVE_DANGLING_FIN_ROWS (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.MOVE_DANGLING_FIN_ROWS(p_worker_id);')) then
      return;
    end if;

    insert into PJI_FM_DNGL_FIN
    (
      WORKER_ID,
      DANGLING_RECVR_GL_RATE_FLAG,
      DANGLING_RECVR_GL_RATE2_FLAG,
      DANGLING_RECVR_PA_RATE_FLAG,
      DANGLING_RECVR_PA_RATE2_FLAG,
      DANGLING_PRVDR_EN_TIME_FLAG,
      DANGLING_RECVR_EN_TIME_FLAG,
      DANGLING_EXP_EN_TIME_FLAG,
      DANGLING_PRVDR_GL_TIME_FLAG,
      DANGLING_RECVR_GL_TIME_FLAG,
      DANGLING_EXP_GL_TIME_FLAG,
      DANGLING_PRVDR_PA_TIME_FLAG,
      DANGLING_RECVR_PA_TIME_FLAG,
      DANGLING_EXP_PA_TIME_FLAG,
      PJI_PROJECT_RECORD_FLAG,
      PJI_RESOURCE_RECORD_FLAG,
      RECORD_TYPE,
      CMT_RECORD_TYPE,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      EXP_EVT_TYPE_ID,
      WORK_TYPE_ID,
      JOB_ID,
      TASK_ID,
      VENDOR_ID,
      EXPENDITURE_TYPE,
      EVENT_TYPE,
      EVENT_TYPE_CLASSIFICATION,
      EXPENDITURE_CATEGORY,
      REVENUE_CATEGORY,
      NON_LABOR_RESOURCE,
      BOM_LABOR_RESOURCE_ID,
      BOM_EQUIPMENT_RESOURCE_ID,
      INVENTORY_ITEM_ID,
      PO_LINE_ID,
      ASSIGNMENT_ID,
      SYSTEM_LINKAGE_FUNCTION,
      RESOURCE_CLASS_CODE,
      RECVR_GL_TIME_ID,
      GL_PERIOD_NAME,
      PRVDR_GL_TIME_ID,
      RECVR_PA_TIME_ID,
      PA_PERIOD_NAME,
      PRVDR_PA_TIME_ID,
      EXPENDITURE_ITEM_TIME_ID,
      PJ_GL_CALENDAR_ID,
      PJ_PA_CALENDAR_ID,
      RS_GL_CALENDAR_ID,
      RS_PA_CALENDAR_ID,
      PRJ_REVENUE,
      PRJ_LABOR_REVENUE,
      PRJ_REVENUE_WRITEOFF,
      PRJ_RAW_COST,
      PRJ_BRDN_COST,
      PRJ_BILL_RAW_COST,
      PRJ_BILL_BRDN_COST,
      PRJ_LABOR_RAW_COST,
      PRJ_LABOR_BRDN_COST,
      PRJ_BILL_LABOR_RAW_COST,
      PRJ_BILL_LABOR_BRDN_COST,
      POU_REVENUE,
      POU_LABOR_REVENUE,
      POU_REVENUE_WRITEOFF,
      POU_RAW_COST,
      POU_BRDN_COST,
      POU_BILL_RAW_COST,
      POU_BILL_BRDN_COST,
      POU_LABOR_RAW_COST,
      POU_LABOR_BRDN_COST,
      POU_BILL_LABOR_RAW_COST,
      POU_BILL_LABOR_BRDN_COST,
      EOU_RAW_COST,
      EOU_BRDN_COST,
      EOU_BILL_RAW_COST,
      EOU_BILL_BRDN_COST,
      TXN_CURRENCY_CODE,
      TXN_REVENUE,
      TXN_RAW_COST,
      TXN_BRDN_COST,
      TXN_BILL_RAW_COST,
      TXN_BILL_BRDN_COST,
      LABOR_HRS,
      BILL_LABOR_HRS,
      GG1_REVENUE,
      GG1_LABOR_REVENUE,
      GG1_REVENUE_WRITEOFF,
      GG1_RAW_COST,
      GG1_BRDN_COST,
      GG1_BILL_RAW_COST,
      GG1_BILL_BRDN_COST,
      GG1_LABOR_RAW_COST,
      GG1_LABOR_BRDN_COST,
      GG1_BILL_LABOR_RAW_COST,
      GG1_BILL_LABOR_BRDN_COST,
      GP1_REVENUE,
      GP1_LABOR_REVENUE,
      GP1_REVENUE_WRITEOFF,
      GP1_RAW_COST,
      GP1_BRDN_COST,
      GP1_BILL_RAW_COST,
      GP1_BILL_BRDN_COST,
      GP1_LABOR_RAW_COST,
      GP1_LABOR_BRDN_COST,
      GP1_BILL_LABOR_RAW_COST,
      GP1_BILL_LABOR_BRDN_COST,
      GG2_REVENUE,
      GG2_LABOR_REVENUE,
      GG2_REVENUE_WRITEOFF,
      GG2_RAW_COST,
      GG2_BRDN_COST,
      GG2_BILL_RAW_COST,
      GG2_BILL_BRDN_COST,
      GG2_LABOR_RAW_COST,
      GG2_LABOR_BRDN_COST,
      GG2_BILL_LABOR_RAW_COST,
      GG2_BILL_LABOR_BRDN_COST,
      GP2_REVENUE,
      GP2_LABOR_REVENUE,
      GP2_REVENUE_WRITEOFF,
      GP2_RAW_COST,
      GP2_BRDN_COST,
      GP2_BILL_RAW_COST,
      GP2_BILL_BRDN_COST,
      GP2_LABOR_RAW_COST,
      GP2_LABOR_BRDN_COST,
      GP2_BILL_LABOR_RAW_COST,
      GP2_BILL_LABOR_BRDN_COST,
      TOTAL_HRS_A,
      BILL_HRS_A
    )
    select /*+ parallel(fin2) */
      0 WORKER_ID,
      DANGLING_RECVR_GL_RATE_FLAG,
      DANGLING_RECVR_GL_RATE2_FLAG,
      DANGLING_RECVR_PA_RATE_FLAG,
      DANGLING_RECVR_PA_RATE2_FLAG,
      DANGLING_PRVDR_EN_TIME_FLAG,
      DANGLING_RECVR_EN_TIME_FLAG,
      DANGLING_EXP_EN_TIME_FLAG,
      DANGLING_PRVDR_GL_TIME_FLAG,
      DANGLING_RECVR_GL_TIME_FLAG,
      DANGLING_EXP_GL_TIME_FLAG,
      DANGLING_PRVDR_PA_TIME_FLAG,
      DANGLING_RECVR_PA_TIME_FLAG,
      DANGLING_EXP_PA_TIME_FLAG,
      PJI_PROJECT_RECORD_FLAG,
      PJI_RESOURCE_RECORD_FLAG,
      RECORD_TYPE,
      CMT_RECORD_TYPE,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      EXP_EVT_TYPE_ID,
      WORK_TYPE_ID,
      JOB_ID,
      TASK_ID,
      VENDOR_ID,
      EXPENDITURE_TYPE,
      EVENT_TYPE,
      EVENT_TYPE_CLASSIFICATION,
      EXPENDITURE_CATEGORY,
      REVENUE_CATEGORY,
      NON_LABOR_RESOURCE,
      BOM_LABOR_RESOURCE_ID,
      BOM_EQUIPMENT_RESOURCE_ID,
      INVENTORY_ITEM_ID,
      PO_LINE_ID,
      ASSIGNMENT_ID,
      SYSTEM_LINKAGE_FUNCTION,
      RESOURCE_CLASS_CODE,
      RECVR_GL_TIME_ID,
      GL_PERIOD_NAME,
      PRVDR_GL_TIME_ID,
      RECVR_PA_TIME_ID,
      PA_PERIOD_NAME,
      PRVDR_PA_TIME_ID,
      EXPENDITURE_ITEM_TIME_ID,
      PJ_GL_CALENDAR_ID,
      PJ_PA_CALENDAR_ID,
      RS_GL_CALENDAR_ID,
      RS_PA_CALENDAR_ID,
      PRJ_REVENUE,
      PRJ_LABOR_REVENUE,
      PRJ_REVENUE_WRITEOFF,
      PRJ_RAW_COST,
      PRJ_BRDN_COST,
      PRJ_BILL_RAW_COST,
      PRJ_BILL_BRDN_COST,
      PRJ_LABOR_RAW_COST,
      PRJ_LABOR_BRDN_COST,
      PRJ_BILL_LABOR_RAW_COST,
      PRJ_BILL_LABOR_BRDN_COST,
      POU_REVENUE,
      POU_LABOR_REVENUE,
      POU_REVENUE_WRITEOFF,
      POU_RAW_COST,
      POU_BRDN_COST,
      POU_BILL_RAW_COST,
      POU_BILL_BRDN_COST,
      POU_LABOR_RAW_COST,
      POU_LABOR_BRDN_COST,
      POU_BILL_LABOR_RAW_COST,
      POU_BILL_LABOR_BRDN_COST,
      EOU_RAW_COST,
      EOU_BRDN_COST,
      EOU_BILL_RAW_COST,
      EOU_BILL_BRDN_COST,
      TXN_CURRENCY_CODE,
      TXN_REVENUE,
      TXN_RAW_COST,
      TXN_BRDN_COST,
      TXN_BILL_RAW_COST,
      TXN_BILL_BRDN_COST,
      LABOR_HRS,
      BILL_LABOR_HRS,
      GG1_REVENUE,
      GG1_LABOR_REVENUE,
      GG1_REVENUE_WRITEOFF,
      GG1_RAW_COST,
      GG1_BRDN_COST,
      GG1_BILL_RAW_COST,
      GG1_BILL_BRDN_COST,
      GG1_LABOR_RAW_COST,
      GG1_LABOR_BRDN_COST,
      GG1_BILL_LABOR_RAW_COST,
      GG1_BILL_LABOR_BRDN_COST,
      GP1_REVENUE,
      GP1_LABOR_REVENUE,
      GP1_REVENUE_WRITEOFF,
      GP1_RAW_COST,
      GP1_BRDN_COST,
      GP1_BILL_RAW_COST,
      GP1_BILL_BRDN_COST,
      GP1_LABOR_RAW_COST,
      GP1_LABOR_BRDN_COST,
      GP1_BILL_LABOR_RAW_COST,
      GP1_BILL_LABOR_BRDN_COST,
      GG2_REVENUE,
      GG2_LABOR_REVENUE,
      GG2_REVENUE_WRITEOFF,
      GG2_RAW_COST,
      GG2_BRDN_COST,
      GG2_BILL_RAW_COST,
      GG2_BILL_BRDN_COST,
      GG2_LABOR_RAW_COST,
      GG2_LABOR_BRDN_COST,
      GG2_BILL_LABOR_RAW_COST,
      GG2_BILL_LABOR_BRDN_COST,
      GP2_REVENUE,
      GP2_LABOR_REVENUE,
      GP2_REVENUE_WRITEOFF,
      GP2_RAW_COST,
      GP2_BRDN_COST,
      GP2_BILL_RAW_COST,
      GP2_BILL_BRDN_COST,
      GP2_LABOR_RAW_COST,
      GP2_LABOR_BRDN_COST,
      GP2_BILL_LABOR_RAW_COST,
      GP2_BILL_LABOR_BRDN_COST,
      TOTAL_HRS_A,
      BILL_HRS_A
    from
      PJI_FM_AGGR_FIN2 fin2
    where
      WORKER_ID = p_worker_id and
      (DANGLING_RECVR_GL_RATE_FLAG  is not null or
       DANGLING_RECVR_GL_RATE2_FLAG is not null or
       DANGLING_RECVR_PA_RATE_FLAG  is not null or
       DANGLING_RECVR_PA_RATE2_FLAG is not null or
       DANGLING_PRVDR_EN_TIME_FLAG  is not null or
       DANGLING_RECVR_EN_TIME_FLAG  is not null or
       DANGLING_EXP_EN_TIME_FLAG    is not null or
       DANGLING_PRVDR_GL_TIME_FLAG  is not null or
       DANGLING_RECVR_GL_TIME_FLAG  is not null or
       DANGLING_EXP_GL_TIME_FLAG    is not null or
       DANGLING_PRVDR_PA_TIME_FLAG  is not null or
       DANGLING_RECVR_PA_TIME_FLAG  is not null or
       DANGLING_EXP_PA_TIME_FLAG    is not null);

    delete /*+ parallel(fin2) */
    from   PJI_FM_AGGR_FIN2 fin2
    where  WORKER_ID = p_worker_id and
           (DANGLING_RECVR_GL_RATE_FLAG  is not null or
            DANGLING_RECVR_GL_RATE2_FLAG is not null or
            DANGLING_RECVR_PA_RATE_FLAG  is not null or
            DANGLING_RECVR_PA_RATE2_FLAG is not null or
            DANGLING_PRVDR_EN_TIME_FLAG  is not null or
            DANGLING_RECVR_EN_TIME_FLAG  is not null or
            DANGLING_EXP_EN_TIME_FLAG    is not null or
            DANGLING_PRVDR_GL_TIME_FLAG  is not null or
            DANGLING_RECVR_GL_TIME_FLAG  is not null or
            DANGLING_EXP_GL_TIME_FLAG    is not null or
            DANGLING_PRVDR_PA_TIME_FLAG  is not null or
            DANGLING_RECVR_PA_TIME_FLAG  is not null or
            DANGLING_EXP_PA_TIME_FLAG    is not null);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.MOVE_DANGLING_FIN_ROWS(p_worker_id);');

    commit;

  end MOVE_DANGLING_FIN_ROWS;


  -- -----------------------------------------------------
  -- procedure ACT_SUMMARY
  -- -----------------------------------------------------
  procedure ACT_SUMMARY (p_worker_id in number) is

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);
    l_schema            varchar2(30);

    l_txn_currency_flag varchar2(1);
    l_g2_currency_flag  varchar2(1);
    l_g1_currency_code  varchar2(30);
    l_g2_currency_code  varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.ACT_SUMMARY(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    select
      TXN_CURR_FLAG,
      GLOBAL_CURR2_FLAG
    into
      l_txn_currency_flag,
      l_g2_currency_flag
    from
      PJI_SYSTEM_SETTINGS;

    l_g1_currency_code := PJI_UTILS.GET_GLOBAL_PRIMARY_CURRENCY;
    l_g2_currency_code := PJI_UTILS.GET_GLOBAL_SECONDARY_CURRENCY;

    insert /*+ append parallel(act2_i) */ into PJI_FM_AGGR_ACT2 act2_i  --  in ACT_SUMMARY
    (
      WORKER_ID,
      DANGLING_GL_RATE_FLAG,
      DANGLING_GL_RATE2_FLAG,
      DANGLING_PA_RATE_FLAG,
      DANGLING_PA_RATE2_FLAG,
      DANGLING_EN_TIME_FLAG,
      DANGLING_GL_TIME_FLAG,
      DANGLING_PA_TIME_FLAG,
      ROW_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TASK_ID,
      GL_TIME_ID,
      GL_PERIOD_NAME,
      PA_TIME_ID,
      PA_PERIOD_NAME,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      TXN_CURRENCY_CODE,
      TXN_REVENUE,
      TXN_FUNDING,
      TXN_INITIAL_FUNDING_AMOUNT,
      TXN_ADDITIONAL_FUNDING_AMOUNT,
      TXN_CANCELLED_FUNDING_AMOUNT,
      TXN_FUNDING_ADJUSTMENT_AMOUNT,
      TXN_REVENUE_WRITEOFF,
      TXN_AR_INVOICE_AMOUNT,
      TXN_AR_CASH_APPLIED_AMOUNT,
      TXN_AR_INVOICE_WRITEOFF_AMOUNT,
      TXN_AR_CREDIT_MEMO_AMOUNT,
      TXN_UNBILLED_RECEIVABLES,
      TXN_UNEARNED_REVENUE,
      TXN_AR_UNAPPR_INVOICE_AMOUNT,
      TXN_AR_APPR_INVOICE_AMOUNT,
      TXN_AR_AMOUNT_DUE,
      TXN_AR_AMOUNT_OVERDUE,
      PRJ_REVENUE,
      PRJ_FUNDING,
      PRJ_INITIAL_FUNDING_AMOUNT,
      PRJ_ADDITIONAL_FUNDING_AMOUNT,
      PRJ_CANCELLED_FUNDING_AMOUNT,
      PRJ_FUNDING_ADJUSTMENT_AMOUNT,
      PRJ_REVENUE_WRITEOFF,
      PRJ_AR_INVOICE_AMOUNT,
      PRJ_AR_CASH_APPLIED_AMOUNT,
      PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
      PRJ_AR_CREDIT_MEMO_AMOUNT,
      PRJ_UNBILLED_RECEIVABLES,
      PRJ_UNEARNED_REVENUE,
      PRJ_AR_UNAPPR_INVOICE_AMOUNT,
      PRJ_AR_APPR_INVOICE_AMOUNT,
      PRJ_AR_AMOUNT_DUE,
      PRJ_AR_AMOUNT_OVERDUE,
      POU_REVENUE,
      POU_FUNDING,
      POU_INITIAL_FUNDING_AMOUNT,
      POU_ADDITIONAL_FUNDING_AMOUNT,
      POU_CANCELLED_FUNDING_AMOUNT,
      POU_FUNDING_ADJUSTMENT_AMOUNT,
      POU_REVENUE_WRITEOFF,
      POU_AR_INVOICE_AMOUNT,
      POU_AR_CASH_APPLIED_AMOUNT,
      POU_AR_INVOICE_WRITEOFF_AMOUNT,
      POU_AR_CREDIT_MEMO_AMOUNT,
      POU_UNBILLED_RECEIVABLES,
      POU_UNEARNED_REVENUE,
      POU_AR_UNAPPR_INVOICE_AMOUNT,
      POU_AR_APPR_INVOICE_AMOUNT,
      POU_AR_AMOUNT_DUE,
      POU_AR_AMOUNT_OVERDUE,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_COUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_COUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_COUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_COUNT,
      AR_COUNT_DUE,
      AR_COUNT_OVERDUE,
      GG_REVENUE,
      GG_FUNDING,
      GG_INITIAL_FUNDING_AMOUNT,
      GG_ADDITIONAL_FUNDING_AMOUNT,
      GG_CANCELLED_FUNDING_AMOUNT,
      GG_FUNDING_ADJUSTMENT_AMOUNT,
      GG_REVENUE_WRITEOFF,
      GG_AR_INVOICE_AMOUNT,
      GG_AR_CASH_APPLIED_AMOUNT,
      GG_AR_INVOICE_WRITEOFF_AMOUNT,
      GG_AR_CREDIT_MEMO_AMOUNT,
      GG_UNBILLED_RECEIVABLES,
      GG_UNEARNED_REVENUE,
      GG_AR_UNAPPR_INVOICE_AMOUNT,
      GG_AR_APPR_INVOICE_AMOUNT,
      GG_AR_AMOUNT_DUE,
      GG_AR_AMOUNT_OVERDUE,
      GP_REVENUE,
      GP_FUNDING,
      GP_INITIAL_FUNDING_AMOUNT,
      GP_ADDITIONAL_FUNDING_AMOUNT,
      GP_CANCELLED_FUNDING_AMOUNT,
      GP_FUNDING_ADJUSTMENT_AMOUNT,
      GP_REVENUE_WRITEOFF,
      GP_AR_INVOICE_AMOUNT,
      GP_AR_CASH_APPLIED_AMOUNT,
      GP_AR_INVOICE_WRITEOFF_AMOUNT,
      GP_AR_CREDIT_MEMO_AMOUNT,
      GP_UNBILLED_RECEIVABLES,
      GP_UNEARNED_REVENUE,
      GP_AR_UNAPPR_INVOICE_AMOUNT,
      GP_AR_APPR_INVOICE_AMOUNT,
      GP_AR_AMOUNT_DUE,
      GP_AR_AMOUNT_OVERDUE,
      GG2_REVENUE,
      GG2_FUNDING,
      GG2_INITIAL_FUNDING_AMOUNT,
      GG2_ADDITIONAL_FUNDING_AMOUNT,
      GG2_CANCELLED_FUNDING_AMOUNT,
      GG2_FUNDING_ADJUSTMENT_AMOUNT,
      GG2_REVENUE_WRITEOFF,
      GG2_AR_INVOICE_AMOUNT,
      GG2_AR_CASH_APPLIED_AMOUNT,
      GG2_AR_INVOICE_WRITEOFF_AMOUNT,
      GG2_AR_CREDIT_MEMO_AMOUNT,
      GG2_UNBILLED_RECEIVABLES,
      GG2_UNEARNED_REVENUE,
      GG2_AR_UNAPPR_INVOICE_AMOUNT,
      GG2_AR_APPR_INVOICE_AMOUNT,
      GG2_AR_AMOUNT_DUE,
      GG2_AR_AMOUNT_OVERDUE,
      GP2_REVENUE,
      GP2_FUNDING,
      GP2_INITIAL_FUNDING_AMOUNT,
      GP2_ADDITIONAL_FUNDING_AMOUNT,
      GP2_CANCELLED_FUNDING_AMOUNT,
      GP2_FUNDING_ADJUSTMENT_AMOUNT,
      GP2_REVENUE_WRITEOFF,
      GP2_AR_INVOICE_AMOUNT,
      GP2_AR_CASH_APPLIED_AMOUNT,
      GP2_AR_INVOICE_WRITEOFF_AMOUNT,
      GP2_AR_CREDIT_MEMO_AMOUNT,
      GP2_UNBILLED_RECEIVABLES,
      GP2_UNEARNED_REVENUE,
      GP2_AR_UNAPPR_INVOICE_AMOUNT,
      GP2_AR_APPR_INVOICE_AMOUNT,
      GP2_AR_AMOUNT_DUE,
      GP2_AR_AMOUNT_OVERDUE
    )
    select
      tmp1.WORKER_ID,
      tmp1.DANGLING_GL_RATE_FLAG,
      tmp1.DANGLING_GL_RATE2_FLAG,
      tmp1.DANGLING_PA_RATE_FLAG,
      tmp1.DANGLING_PA_RATE2_FLAG,
      tmp1.DANGLING_EN_TIME_FLAG,
      tmp1.DANGLING_GL_TIME_FLAG,
      tmp1.DANGLING_PA_TIME_FLAG,
      null ROW_ID,
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.TASK_ID,
      tmp1.GL_TIME_ID,
      tmp1.GL_PERIOD_NAME,
      tmp1.PA_TIME_ID,
      tmp1.PA_PERIOD_NAME,
      tmp1.GL_CALENDAR_ID,
      tmp1.PA_CALENDAR_ID,
      tmp1.TXN_CURRENCY_CODE,
      tmp1.TXN_REVENUE,
      tmp1.TXN_FUNDING,
      tmp1.TXN_INITIAL_FUNDING_AMOUNT,
      tmp1.TXN_ADDITIONAL_FUNDING_AMOUNT,
      tmp1.TXN_CANCELLED_FUNDING_AMOUNT,
      tmp1.TXN_FUNDING_ADJUSTMENT_AMOUNT,
      tmp1.TXN_REVENUE_WRITEOFF,
      tmp1.TXN_AR_INVOICE_AMOUNT,
      tmp1.TXN_AR_CASH_APPLIED_AMOUNT,
      tmp1.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
      tmp1.TXN_AR_CREDIT_MEMO_AMOUNT,
      tmp1.TXN_UNBILLED_RECEIVABLES,
      tmp1.TXN_UNEARNED_REVENUE,
      tmp1.TXN_AR_UNAPPR_INVOICE_AMOUNT,
      tmp1.TXN_AR_APPR_INVOICE_AMOUNT,
      tmp1.TXN_AR_AMOUNT_DUE,
      tmp1.TXN_AR_AMOUNT_OVERDUE,
      tmp1.PRJ_REVENUE,
      tmp1.PRJ_FUNDING,
      tmp1.PRJ_INITIAL_FUNDING_AMOUNT,
      tmp1.PRJ_ADDITIONAL_FUNDING_AMOUNT,
      tmp1.PRJ_CANCELLED_FUNDING_AMOUNT,
      tmp1.PRJ_FUNDING_ADJUSTMENT_AMOUNT,
      tmp1.PRJ_REVENUE_WRITEOFF,
      tmp1.PRJ_AR_INVOICE_AMOUNT,
      tmp1.PRJ_AR_CASH_APPLIED_AMOUNT,
      tmp1.PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
      tmp1.PRJ_AR_CREDIT_MEMO_AMOUNT,
      tmp1.PRJ_UNBILLED_RECEIVABLES,
      tmp1.PRJ_UNEARNED_REVENUE,
      tmp1.PRJ_AR_UNAPPR_INVOICE_AMOUNT,
      tmp1.PRJ_AR_APPR_INVOICE_AMOUNT,
      tmp1.PRJ_AR_AMOUNT_DUE,
      tmp1.PRJ_AR_AMOUNT_OVERDUE,
      tmp1.POU_REVENUE,
      tmp1.POU_FUNDING,
      tmp1.POU_INITIAL_FUNDING_AMOUNT,
      tmp1.POU_ADDITIONAL_FUNDING_AMOUNT,
      tmp1.POU_CANCELLED_FUNDING_AMOUNT,
      tmp1.POU_FUNDING_ADJUSTMENT_AMOUNT,
      tmp1.POU_REVENUE_WRITEOFF,
      tmp1.POU_AR_INVOICE_AMOUNT,
      tmp1.POU_AR_CASH_APPLIED_AMOUNT,
      tmp1.POU_AR_INVOICE_WRITEOFF_AMOUNT,
      tmp1.POU_AR_CREDIT_MEMO_AMOUNT,
      tmp1.POU_UNBILLED_RECEIVABLES,
      tmp1.POU_UNEARNED_REVENUE,
      tmp1.POU_AR_UNAPPR_INVOICE_AMOUNT,
      tmp1.POU_AR_APPR_INVOICE_AMOUNT,
      tmp1.POU_AR_AMOUNT_DUE,
      tmp1.POU_AR_AMOUNT_OVERDUE,
      tmp1.INITIAL_FUNDING_COUNT,
      tmp1.ADDITIONAL_FUNDING_COUNT,
      tmp1.CANCELLED_FUNDING_COUNT,
      tmp1.FUNDING_ADJUSTMENT_COUNT,
      tmp1.AR_INVOICE_COUNT,
      tmp1.AR_CASH_APPLIED_COUNT,
      tmp1.AR_INVOICE_WRITEOFF_COUNT,
      tmp1.AR_CREDIT_MEMO_COUNT,
      tmp1.AR_UNAPPR_INVOICE_COUNT,
      tmp1.AR_APPR_INVOICE_COUNT,
      tmp1.AR_COUNT_DUE,
      tmp1.AR_COUNT_OVERDUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_REVENUE,
                       round(tmp1.POU_REVENUE *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_REVENUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_FUNDING,
                       round(tmp1.POU_FUNDING *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_FUNDING,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_INITIAL_FUNDING_AMOUNT,
                       round(tmp1.POU_INITIAL_FUNDING_AMOUNT *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_INITIAL_FUNDING_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_ADDITIONAL_FUNDING_AMOUNT,
                       round(tmp1.POU_ADDITIONAL_FUNDING_AMOUNT *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_ADDITIONAL_FUNDING_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_CANCELLED_FUNDING_AMOUNT,
                       round(tmp1.POU_CANCELLED_FUNDING_AMOUNT *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_CANCELLED_FUNDING_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_FUNDING_ADJUSTMENT_AMOUNT,
                       round(tmp1.POU_FUNDING_ADJUSTMENT_AMOUNT *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_FUNDING_ADJUSTMENT_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_REVENUE_WRITEOFF,
                       round(tmp1.POU_REVENUE_WRITEOFF *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_REVENUE_WRITEOFF,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_INVOICE_AMOUNT,
                       round(tmp1.POU_AR_INVOICE_AMOUNT *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_AR_INVOICE_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_CASH_APPLIED_AMOUNT,
                       round(tmp1.POU_AR_CASH_APPLIED_AMOUNT *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_AR_CASH_APPLIED_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
                       round(tmp1.POU_AR_INVOICE_WRITEOFF_AMOUNT *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_AR_INVOICE_WRITEOFF_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_CREDIT_MEMO_AMOUNT,
                       round(tmp1.POU_AR_CREDIT_MEMO_AMOUNT *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_AR_CREDIT_MEMO_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_UNBILLED_RECEIVABLES,
                       round(tmp1.POU_UNBILLED_RECEIVABLES *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_UNBILLED_RECEIVABLES,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_UNEARNED_REVENUE,
                       round(tmp1.POU_UNEARNED_REVENUE *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_UNEARNED_REVENUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_UNAPPR_INVOICE_AMOUNT,
                       round(tmp1.POU_AR_UNAPPR_INVOICE_AMOUNT *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_AR_UNAPPR_INVOICE_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_APPR_INVOICE_AMOUNT,
                       round(tmp1.POU_AR_APPR_INVOICE_AMOUNT *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_AR_APPR_INVOICE_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_AMOUNT_DUE,
                       round(tmp1.POU_AR_AMOUNT_DUE *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_AR_AMOUNT_DUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_AMOUNT_OVERDUE,
                       round(tmp1.POU_AR_AMOUNT_OVERDUE *
                             tmp1.GL_RATE1 /
                             GL_MAU1) * GL_MAU1),
                to_number(null))               GG1_AR_AMOUNT_OVERDUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_REVENUE,
                       round(tmp1.POU_REVENUE *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_REVENUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_FUNDING,
                       round(tmp1.POU_FUNDING *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_FUNDING,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_INITIAL_FUNDING_AMOUNT,
                       round(tmp1.POU_INITIAL_FUNDING_AMOUNT *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_INITIAL_FUNDING_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_ADDITIONAL_FUNDING_AMOUNT,
                       round(tmp1.POU_ADDITIONAL_FUNDING_AMOUNT *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_ADDITIONAL_FUNDING_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_CANCELLED_FUNDING_AMOUNT,
                       round(tmp1.POU_CANCELLED_FUNDING_AMOUNT *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_CANCELLED_FUNDING_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_FUNDING_ADJUSTMENT_AMOUNT,
                       round(tmp1.POU_FUNDING_ADJUSTMENT_AMOUNT *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_FUNDING_ADJUSTMENT_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_REVENUE_WRITEOFF,
                       round(tmp1.POU_REVENUE_WRITEOFF *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_REVENUE_WRITEOFF,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_INVOICE_AMOUNT,
                       round(tmp1.POU_AR_INVOICE_AMOUNT *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_AR_INVOICE_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_CASH_APPLIED_AMOUNT,
                       round(tmp1.POU_AR_CASH_APPLIED_AMOUNT *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_AR_CASH_APPLIED_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
                       round(tmp1.POU_AR_INVOICE_WRITEOFF_AMOUNT *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_AR_INVOICE_WRITEOFF_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_CREDIT_MEMO_AMOUNT,
                       round(tmp1.POU_AR_CREDIT_MEMO_AMOUNT *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_AR_CREDIT_MEMO_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_UNBILLED_RECEIVABLES,
                       round(tmp1.POU_UNBILLED_RECEIVABLES *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_UNBILLED_RECEIVABLES,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_UNEARNED_REVENUE,
                       round(tmp1.POU_UNEARNED_REVENUE *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_UNEARNED_REVENUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_UNAPPR_INVOICE_AMOUNT,
                       round(tmp1.POU_AR_UNAPPR_INVOICE_AMOUNT *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_AR_UNAPPR_INVOICE_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_APPR_INVOICE_AMOUNT,
                       round(tmp1.POU_AR_APPR_INVOICE_AMOUNT *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_AR_APPR_INVOICE_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_AMOUNT_DUE,
                       round(tmp1.POU_AR_AMOUNT_DUE *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_AR_AMOUNT_DUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g1_currency_code,
                       tmp1.TXN_AR_AMOUNT_OVERDUE,
                       round(tmp1.POU_AR_AMOUNT_OVERDUE *
                             tmp1.PA_RATE1 /
                             PA_MAU1) * PA_MAU1),
                to_number(null))               GP1_AR_AMOUNT_OVERDUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_REVENUE,
                       round(tmp1.POU_REVENUE *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_REVENUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_FUNDING,
                       round(tmp1.POU_FUNDING *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_FUNDING,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_INITIAL_FUNDING_AMOUNT,
                       round(tmp1.POU_INITIAL_FUNDING_AMOUNT *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_INITIAL_FUNDING_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_ADDITIONAL_FUNDING_AMOUNT,
                       round(tmp1.POU_ADDITIONAL_FUNDING_AMOUNT *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_ADDITIONAL_FUNDING_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_CANCELLED_FUNDING_AMOUNT,
                       round(tmp1.POU_CANCELLED_FUNDING_AMOUNT *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_CANCELLED_FUNDING_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_FUNDING_ADJUSTMENT_AMOUNT,
                       round(tmp1.POU_FUNDING_ADJUSTMENT_AMOUNT *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_FUNDING_ADJUSTMENT_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_REVENUE_WRITEOFF,
                       round(tmp1.POU_REVENUE_WRITEOFF *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_REVENUE_WRITEOFF,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_INVOICE_AMOUNT,
                       round(tmp1.POU_AR_INVOICE_AMOUNT *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_AR_INVOICE_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_CASH_APPLIED_AMOUNT,
                       round(tmp1.POU_AR_CASH_APPLIED_AMOUNT *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_AR_CASH_APPLIED_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
                       round(tmp1.POU_AR_INVOICE_WRITEOFF_AMOUNT *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_AR_INVOICE_WRITEOFF_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_CREDIT_MEMO_AMOUNT,
                       round(tmp1.POU_AR_CREDIT_MEMO_AMOUNT *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_AR_CREDIT_MEMO_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_UNBILLED_RECEIVABLES,
                       round(tmp1.POU_UNBILLED_RECEIVABLES *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_UNBILLED_RECEIVABLES,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_UNEARNED_REVENUE,
                       round(tmp1.POU_UNEARNED_REVENUE *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_UNEARNED_REVENUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_UNAPPR_INVOICE_AMOUNT,
                       round(tmp1.POU_AR_UNAPPR_INVOICE_AMOUNT *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_AR_UNAPPR_INVOICE_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_APPR_INVOICE_AMOUNT,
                       round(tmp1.POU_AR_APPR_INVOICE_AMOUNT *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_AR_APPR_INVOICE_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_AMOUNT_DUE,
                       round(tmp1.POU_AR_AMOUNT_DUE *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_AR_AMOUNT_DUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_AMOUNT_OVERDUE,
                       round(tmp1.POU_AR_AMOUNT_OVERDUE *
                             tmp1.GL_RATE2 /
                             GL_MAU2) * GL_MAU2),
                to_number(null))               GG2_AR_AMOUNT_OVERDUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_REVENUE,
                       round(tmp1.POU_REVENUE *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_REVENUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_FUNDING,
                       round(tmp1.POU_FUNDING *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_FUNDING,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_INITIAL_FUNDING_AMOUNT,
                       round(tmp1.POU_INITIAL_FUNDING_AMOUNT *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_INITIAL_FUNDING_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_ADDITIONAL_FUNDING_AMOUNT,
                       round(tmp1.POU_ADDITIONAL_FUNDING_AMOUNT *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_ADDITIONAL_FUNDING_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_CANCELLED_FUNDING_AMOUNT,
                       round(tmp1.POU_CANCELLED_FUNDING_AMOUNT *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_CANCELLED_FUNDING_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_FUNDING_ADJUSTMENT_AMOUNT,
                       round(tmp1.POU_FUNDING_ADJUSTMENT_AMOUNT *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_FUNDING_ADJUSTMENT_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_REVENUE_WRITEOFF,
                       round(tmp1.POU_REVENUE_WRITEOFF *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_REVENUE_WRITEOFF,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_INVOICE_AMOUNT,
                       round(tmp1.POU_AR_INVOICE_AMOUNT *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_AR_INVOICE_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_CASH_APPLIED_AMOUNT,
                       round(tmp1.POU_AR_CASH_APPLIED_AMOUNT *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_AR_CASH_APPLIED_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
                       round(tmp1.POU_AR_INVOICE_WRITEOFF_AMOUNT *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_AR_INVOICE_WRITEOFF_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_CREDIT_MEMO_AMOUNT,
                       round(tmp1.POU_AR_CREDIT_MEMO_AMOUNT *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_AR_CREDIT_MEMO_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_UNBILLED_RECEIVABLES,
                       round(tmp1.POU_UNBILLED_RECEIVABLES *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_UNBILLED_RECEIVABLES,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_UNEARNED_REVENUE,
                       round(tmp1.POU_UNEARNED_REVENUE *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_UNEARNED_REVENUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_UNAPPR_INVOICE_AMOUNT,
                       round(tmp1.POU_AR_UNAPPR_INVOICE_AMOUNT *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_AR_UNAPPR_INVOICE_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_APPR_INVOICE_AMOUNT,
                       round(tmp1.POU_AR_APPR_INVOICE_AMOUNT *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_AR_APPR_INVOICE_AMOUNT,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_AMOUNT_DUE,
                       round(tmp1.POU_AR_AMOUNT_DUE *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_AR_AMOUNT_DUE,
      decode(sign(tmp1.WORKER_ID),
             1, decode(tmp1.TXN_CURRENCY_CODE,
                       l_g2_currency_code,
                       tmp1.TXN_AR_AMOUNT_OVERDUE,
                       round(tmp1.POU_AR_AMOUNT_OVERDUE *
                             tmp1.PA_RATE2 /
                             PA_MAU2) * PA_MAU2),
                to_number(null))               GP2_AR_AMOUNT_OVERDUE
    from
    (
    select   /*+ ordered
                 full(tmp1)     use_hash(tmp1)    parallel(tmp1)
                 full(prj_info) use_hash(prj_info)
                 full(gl_rt)    use_hash(gl_rt)
                 full(pa_rt)    use_hash(pa_rt)
              */
      p_worker_id                              WORKER_ID,
      decode(gl_rt.RATE,
             -3, 'E', -- EUR rate for 01-JAN-1999 is missing
             decode(sign(gl_rt.RATE),
                    -1, 'Y', null))            DANGLING_GL_RATE_FLAG,
      decode(l_g2_currency_flag,
             'Y', decode(gl_rt.RATE2,
                         -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                         decode(sign(gl_rt.RATE2),
                                -1, 'Y', null)),
             null)                             DANGLING_GL_RATE2_FLAG,
      decode(pa_rt.RATE,
             -3, 'E', -- EUR rate for 01-JAN-1999 is missing
             decode(sign(pa_rt.RATE),
                    -1, 'Y', null))            DANGLING_PA_RATE_FLAG,
      decode(l_g2_currency_flag,
             'Y', decode(pa_rt.RATE2,
                         -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                         decode(sign(pa_rt.RATE2),
                                -1, 'Y', null)),
             null)                             DANGLING_PA_RATE2_FLAG,
      decode(sign(prj_info.EN_CALENDAR_MIN_DATE -
                  tmp1.GL_TIME_ID) +
             sign(tmp1.GL_TIME_ID -
                  prj_info.EN_CALENDAR_MAX_DATE),
             0, 'Y', null)                     DANGLING_EN_TIME_FLAG,
      decode(sign(prj_info.GL_CALENDAR_MIN_DATE -
                  tmp1.GL_TIME_ID) +
             sign(tmp1.GL_TIME_ID -
                  prj_info.GL_CALENDAR_MAX_DATE),
             0, 'Y', null)                     DANGLING_GL_TIME_FLAG,
      decode(sign(prj_info.PA_CALENDAR_MIN_DATE -
                  tmp1.PA_TIME_ID) +
             sign(tmp1.PA_TIME_ID -
                  prj_info.PA_CALENDAR_MAX_DATE),
             0, 'Y', null)                     DANGLING_PA_TIME_FLAG,
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.TASK_ID,
      tmp1.GL_TIME_ID,
      tmp1.GL_PERIOD_NAME,
      tmp1.PA_TIME_ID,
      tmp1.PA_PERIOD_NAME,
      prj_info.GL_CALENDAR_ID                  GL_CALENDAR_ID,
      prj_info.PA_CALENDAR_ID                  PA_CALENDAR_ID,
      gl_rt.RATE                               GL_RATE1,
      gl_rt.RATE2                              GL_RATE2,
      pa_rt.RATE                               PA_RATE1,
      pa_rt.RATE2                              PA_RATE2,
      gl_rt.MAU                                GL_MAU1,
      gl_rt.MAU2                               GL_MAU2,
      pa_rt.MAU                                PA_MAU1,
      pa_rt.MAU2                               PA_MAU2,
      tmp1.TXN_CURRENCY_CODE                   TXN_CURRENCY_CODE,
      sum(tmp1.TXN_REVENUE)                    TXN_REVENUE,
      sum(tmp1.TXN_FUNDING)                    TXN_FUNDING,
      sum(tmp1.TXN_INITIAL_FUNDING_AMOUNT)     TXN_INITIAL_FUNDING_AMOUNT,
      sum(tmp1.TXN_ADDITIONAL_FUNDING_AMOUNT)  TXN_ADDITIONAL_FUNDING_AMOUNT,
      sum(tmp1.TXN_CANCELLED_FUNDING_AMOUNT)   TXN_CANCELLED_FUNDING_AMOUNT,
      sum(tmp1.TXN_FUNDING_ADJUSTMENT_AMOUNT)  TXN_FUNDING_ADJUSTMENT_AMOUNT,
      sum(tmp1.TXN_REVENUE_WRITEOFF)           TXN_REVENUE_WRITEOFF,
      sum(tmp1.TXN_AR_INVOICE_AMOUNT)          TXN_AR_INVOICE_AMOUNT,
      sum(tmp1.TXN_AR_CASH_APPLIED_AMOUNT)     TXN_AR_CASH_APPLIED_AMOUNT,
      sum(tmp1.TXN_AR_INVOICE_WRITEOFF_AMOUNT) TXN_AR_INVOICE_WRITEOFF_AMOUNT,
      sum(tmp1.TXN_AR_CREDIT_MEMO_AMOUNT)      TXN_AR_CREDIT_MEMO_AMOUNT,
      sum(tmp1.TXN_UNBILLED_RECEIVABLES)       TXN_UNBILLED_RECEIVABLES,
      sum(tmp1.TXN_UNEARNED_REVENUE)           TXN_UNEARNED_REVENUE,
      sum(tmp1.TXN_AR_UNAPPR_INVOICE_AMOUNT)   TXN_AR_UNAPPR_INVOICE_AMOUNT,
      sum(tmp1.TXN_AR_APPR_INVOICE_AMOUNT)     TXN_AR_APPR_INVOICE_AMOUNT,
      sum(tmp1.TXN_AR_AMOUNT_DUE)              TXN_AR_AMOUNT_DUE,
      sum(tmp1.TXN_AR_AMOUNT_OVERDUE)          TXN_AR_AMOUNT_OVERDUE,
      sum(tmp1.PRJ_REVENUE)                    PRJ_REVENUE,
      sum(tmp1.PRJ_FUNDING)                    PRJ_FUNDING,
      sum(tmp1.PRJ_INITIAL_FUNDING_AMOUNT)     PRJ_INITIAL_FUNDING_AMOUNT,
      sum(tmp1.PRJ_ADDITIONAL_FUNDING_AMOUNT)  PRJ_ADDITIONAL_FUNDING_AMOUNT,
      sum(tmp1.PRJ_CANCELLED_FUNDING_AMOUNT)   PRJ_CANCELLED_FUNDING_AMOUNT,
      sum(tmp1.PRJ_FUNDING_ADJUSTMENT_AMOUNT)  PRJ_FUNDING_ADJUSTMENT_AMOUNT,
      sum(tmp1.PRJ_REVENUE_WRITEOFF)           PRJ_REVENUE_WRITEOFF,
      sum(tmp1.PRJ_AR_INVOICE_AMOUNT)          PRJ_AR_INVOICE_AMOUNT,
      sum(tmp1.PRJ_AR_CASH_APPLIED_AMOUNT)     PRJ_AR_CASH_APPLIED_AMOUNT,
      sum(tmp1.PRJ_AR_INVOICE_WRITEOFF_AMOUNT) PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
      sum(tmp1.PRJ_AR_CREDIT_MEMO_AMOUNT)      PRJ_AR_CREDIT_MEMO_AMOUNT,
      sum(tmp1.PRJ_UNBILLED_RECEIVABLES)       PRJ_UNBILLED_RECEIVABLES,
      sum(tmp1.PRJ_UNEARNED_REVENUE)           PRJ_UNEARNED_REVENUE,
      sum(tmp1.PRJ_AR_UNAPPR_INVOICE_AMOUNT)   PRJ_AR_UNAPPR_INVOICE_AMOUNT,
      sum(tmp1.PRJ_AR_APPR_INVOICE_AMOUNT)     PRJ_AR_APPR_INVOICE_AMOUNT,
      sum(tmp1.PRJ_AR_AMOUNT_DUE)              PRJ_AR_AMOUNT_DUE,
      sum(tmp1.PRJ_AR_AMOUNT_OVERDUE)          PRJ_AR_AMOUNT_OVERDUE,
      sum(tmp1.POU_REVENUE)                    POU_REVENUE,
      sum(tmp1.POU_FUNDING)                    POU_FUNDING,
      sum(tmp1.POU_INITIAL_FUNDING_AMOUNT)     POU_INITIAL_FUNDING_AMOUNT,
      sum(tmp1.POU_ADDITIONAL_FUNDING_AMOUNT)  POU_ADDITIONAL_FUNDING_AMOUNT,
      sum(tmp1.POU_CANCELLED_FUNDING_AMOUNT)   POU_CANCELLED_FUNDING_AMOUNT,
      sum(tmp1.POU_FUNDING_ADJUSTMENT_AMOUNT)  POU_FUNDING_ADJUSTMENT_AMOUNT,
      sum(tmp1.POU_REVENUE_WRITEOFF)           POU_REVENUE_WRITEOFF,
      sum(tmp1.POU_AR_INVOICE_AMOUNT)          POU_AR_INVOICE_AMOUNT,
      sum(tmp1.POU_AR_CASH_APPLIED_AMOUNT)     POU_AR_CASH_APPLIED_AMOUNT,
      sum(tmp1.POU_AR_INVOICE_WRITEOFF_AMOUNT) POU_AR_INVOICE_WRITEOFF_AMOUNT,
      sum(tmp1.POU_AR_CREDIT_MEMO_AMOUNT)      POU_AR_CREDIT_MEMO_AMOUNT,
      sum(tmp1.POU_UNBILLED_RECEIVABLES)       POU_UNBILLED_RECEIVABLES,
      sum(tmp1.POU_UNEARNED_REVENUE)           POU_UNEARNED_REVENUE,
      sum(tmp1.POU_AR_UNAPPR_INVOICE_AMOUNT)   POU_AR_UNAPPR_INVOICE_AMOUNT,
      sum(tmp1.POU_AR_APPR_INVOICE_AMOUNT)     POU_AR_APPR_INVOICE_AMOUNT,
      sum(tmp1.POU_AR_AMOUNT_DUE)              POU_AR_AMOUNT_DUE,
      sum(tmp1.POU_AR_AMOUNT_OVERDUE)          POU_AR_AMOUNT_OVERDUE,
      sum(tmp1.INITIAL_FUNDING_COUNT)          INITIAL_FUNDING_COUNT,
      sum(tmp1.ADDITIONAL_FUNDING_COUNT)       ADDITIONAL_FUNDING_COUNT,
      sum(tmp1.CANCELLED_FUNDING_COUNT)        CANCELLED_FUNDING_COUNT,
      sum(tmp1.FUNDING_ADJUSTMENT_COUNT)       FUNDING_ADJUSTMENT_COUNT,
      sum(tmp1.AR_INVOICE_COUNT)               AR_INVOICE_COUNT,
      sum(tmp1.AR_CASH_APPLIED_COUNT)          AR_CASH_APPLIED_COUNT,
      sum(tmp1.AR_INVOICE_WRITEOFF_COUNT)      AR_INVOICE_WRITEOFF_COUNT,
      sum(tmp1.AR_CREDIT_MEMO_COUNT)           AR_CREDIT_MEMO_COUNT,
      sum(tmp1.AR_UNAPPR_INVOICE_COUNT)        AR_UNAPPR_INVOICE_COUNT,
      sum(tmp1.AR_APPR_INVOICE_COUNT)          AR_APPR_INVOICE_COUNT,
      sum(tmp1.AR_COUNT_DUE)                   AR_COUNT_DUE,
      sum(tmp1.AR_COUNT_OVERDUE)               AR_COUNT_OVERDUE
    from
      PJI_FM_AGGR_ACT1 tmp1,
      PJI_ORG_EXTR_INFO    prj_info,
      PJI_FM_AGGR_DLY_RATES    gl_rt,
      PJI_FM_AGGR_DLY_RATES    pa_rt
    where
      tmp1.WORKER_ID            = p_worker_id            and
      tmp1.PROJECT_ORG_ID       = prj_info.ORG_ID        and
      gl_rt.WORKER_ID           = -1                     and
      tmp1.GL_TIME_ID           = gl_rt.TIME_ID          and
      prj_info.PF_CURRENCY_CODE = gl_rt.PF_CURRENCY_CODE and
      pa_rt.WORKER_ID           = -1                     and
      tmp1.PA_TIME_ID           = pa_rt.TIME_ID          and
      prj_info.PF_CURRENCY_CODE = pa_rt.PF_CURRENCY_CODE
    group by
      decode(gl_rt.RATE,
             -3, 'E', -- EUR rate for 01-JAN-1999 is missing
             decode(sign(gl_rt.RATE),
                    -1, 'Y', null)),
      decode(l_g2_currency_flag,
             'Y', decode(gl_rt.RATE2,
                         -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                         decode(sign(gl_rt.RATE2),
                                -1, 'Y', null)),
             null),
      decode(pa_rt.RATE,
             -3, 'E', -- EUR rate for 01-JAN-1999 is missing
             decode(sign(pa_rt.RATE),
                    -1, 'Y', null)),
      decode(l_g2_currency_flag,
             'Y', decode(pa_rt.RATE2,
                         -3, 'E', -- EUR rate for 01-JAN-1999 is missing
                         decode(sign(pa_rt.RATE2),
                                -1, 'Y', null)),
             null),
      decode(sign(prj_info.EN_CALENDAR_MIN_DATE -
                  tmp1.GL_TIME_ID) +
             sign(tmp1.GL_TIME_ID -
                  prj_info.EN_CALENDAR_MAX_DATE),
             0, 'Y', null),
      decode(sign(prj_info.GL_CALENDAR_MIN_DATE -
                  tmp1.GL_TIME_ID) +
             sign(tmp1.GL_TIME_ID -
                  prj_info.GL_CALENDAR_MAX_DATE),
             0, 'Y', null),
      decode(sign(prj_info.PA_CALENDAR_MIN_DATE -
                  tmp1.PA_TIME_ID) +
             sign(tmp1.PA_TIME_ID -
                  prj_info.PA_CALENDAR_MAX_DATE),
             0, 'Y', null),
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.TASK_ID,
      tmp1.GL_TIME_ID,
      tmp1.GL_PERIOD_NAME,
      tmp1.PA_TIME_ID,
      tmp1.PA_PERIOD_NAME,
      prj_info.GL_CALENDAR_ID,
      prj_info.PA_CALENDAR_ID,
      gl_rt.RATE,
      gl_rt.RATE2,
      pa_rt.RATE,
      pa_rt.RATE2,
      gl_rt.MAU,
      gl_rt.MAU2,
      pa_rt.MAU,
      pa_rt.MAU2,
      tmp1.TXN_CURRENCY_CODE
    ) tmp1;

    delete
    from   PJI_FM_AGGR_DLY_RATES
    where  WORKER_ID = -1;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.ACT_SUMMARY(p_worker_id);');

    -- truncate intermediate tables no longer required
    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_AGGR_ACT1' , 'NORMAL',null);

    commit;

  end ACT_SUMMARY;


  -- -----------------------------------------------------
  -- procedure MOVE_DANGLING_ACT_ROWS
  -- -----------------------------------------------------
  procedure MOVE_DANGLING_ACT_ROWS (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.MOVE_DANGLING_ACT_ROWS(p_worker_id);')) then
      return;
    end if;

    insert into PJI_FM_DNGL_ACT
    (
      WORKER_ID,
      DANGLING_GL_RATE_FLAG,
      DANGLING_GL_RATE2_FLAG,
      DANGLING_PA_RATE_FLAG,
      DANGLING_PA_RATE2_FLAG,
      DANGLING_EN_TIME_FLAG,
      DANGLING_GL_TIME_FLAG,
      DANGLING_PA_TIME_FLAG,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TASK_ID,
      GL_TIME_ID,
      GL_PERIOD_NAME,
      PA_TIME_ID,
      PA_PERIOD_NAME,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      PRJ_REVENUE,
      PRJ_FUNDING,
      PRJ_INITIAL_FUNDING_AMOUNT,
      PRJ_ADDITIONAL_FUNDING_AMOUNT,
      PRJ_CANCELLED_FUNDING_AMOUNT,
      PRJ_FUNDING_ADJUSTMENT_AMOUNT,
      PRJ_REVENUE_WRITEOFF,
      PRJ_AR_INVOICE_AMOUNT,
      PRJ_AR_CASH_APPLIED_AMOUNT,
      PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
      PRJ_AR_CREDIT_MEMO_AMOUNT,
      PRJ_UNBILLED_RECEIVABLES,
      PRJ_UNEARNED_REVENUE,
      PRJ_AR_UNAPPR_INVOICE_AMOUNT,
      PRJ_AR_APPR_INVOICE_AMOUNT,
      PRJ_AR_AMOUNT_DUE,
      PRJ_AR_AMOUNT_OVERDUE,
      POU_REVENUE,
      POU_FUNDING,
      POU_INITIAL_FUNDING_AMOUNT,
      POU_ADDITIONAL_FUNDING_AMOUNT,
      POU_CANCELLED_FUNDING_AMOUNT,
      POU_FUNDING_ADJUSTMENT_AMOUNT,
      POU_REVENUE_WRITEOFF,
      POU_AR_INVOICE_AMOUNT,
      POU_AR_CASH_APPLIED_AMOUNT,
      POU_AR_INVOICE_WRITEOFF_AMOUNT,
      POU_AR_CREDIT_MEMO_AMOUNT,
      POU_UNBILLED_RECEIVABLES,
      POU_UNEARNED_REVENUE,
      POU_AR_UNAPPR_INVOICE_AMOUNT,
      POU_AR_APPR_INVOICE_AMOUNT,
      POU_AR_AMOUNT_DUE,
      POU_AR_AMOUNT_OVERDUE,
      TXN_CURRENCY_CODE,
      TXN_REVENUE,
      TXN_FUNDING,
      TXN_INITIAL_FUNDING_AMOUNT,
      TXN_ADDITIONAL_FUNDING_AMOUNT,
      TXN_CANCELLED_FUNDING_AMOUNT,
      TXN_FUNDING_ADJUSTMENT_AMOUNT,
      TXN_REVENUE_WRITEOFF,
      TXN_AR_INVOICE_AMOUNT,
      TXN_AR_CASH_APPLIED_AMOUNT,
      TXN_AR_INVOICE_WRITEOFF_AMOUNT,
      TXN_AR_CREDIT_MEMO_AMOUNT,
      TXN_UNBILLED_RECEIVABLES,
      TXN_UNEARNED_REVENUE,
      TXN_AR_UNAPPR_INVOICE_AMOUNT,
      TXN_AR_APPR_INVOICE_AMOUNT,
      TXN_AR_AMOUNT_DUE,
      TXN_AR_AMOUNT_OVERDUE,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_COUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_COUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_COUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_COUNT,
      AR_COUNT_DUE,
      AR_COUNT_OVERDUE,
      GG_REVENUE,
      GG_FUNDING,
      GG_INITIAL_FUNDING_AMOUNT,
      GG_ADDITIONAL_FUNDING_AMOUNT,
      GG_CANCELLED_FUNDING_AMOUNT,
      GG_FUNDING_ADJUSTMENT_AMOUNT,
      GG_REVENUE_WRITEOFF,
      GG_AR_INVOICE_AMOUNT,
      GG_AR_CASH_APPLIED_AMOUNT,
      GG_AR_INVOICE_WRITEOFF_AMOUNT,
      GG_AR_CREDIT_MEMO_AMOUNT,
      GG_UNBILLED_RECEIVABLES,
      GG_UNEARNED_REVENUE,
      GG_AR_UNAPPR_INVOICE_AMOUNT,
      GG_AR_APPR_INVOICE_AMOUNT,
      GG_AR_AMOUNT_DUE,
      GG_AR_AMOUNT_OVERDUE,
      GP_REVENUE,
      GP_FUNDING,
      GP_INITIAL_FUNDING_AMOUNT,
      GP_ADDITIONAL_FUNDING_AMOUNT,
      GP_CANCELLED_FUNDING_AMOUNT,
      GP_FUNDING_ADJUSTMENT_AMOUNT,
      GP_REVENUE_WRITEOFF,
      GP_AR_INVOICE_AMOUNT,
      GP_AR_CASH_APPLIED_AMOUNT,
      GP_AR_INVOICE_WRITEOFF_AMOUNT,
      GP_AR_CREDIT_MEMO_AMOUNT,
      GP_UNBILLED_RECEIVABLES,
      GP_UNEARNED_REVENUE,
      GP_AR_UNAPPR_INVOICE_AMOUNT,
      GP_AR_APPR_INVOICE_AMOUNT,
      GP_AR_AMOUNT_DUE,
      GP_AR_AMOUNT_OVERDUE,
      GG2_REVENUE,
      GG2_FUNDING,
      GG2_INITIAL_FUNDING_AMOUNT,
      GG2_ADDITIONAL_FUNDING_AMOUNT,
      GG2_CANCELLED_FUNDING_AMOUNT,
      GG2_FUNDING_ADJUSTMENT_AMOUNT,
      GG2_REVENUE_WRITEOFF,
      GG2_AR_INVOICE_AMOUNT,
      GG2_AR_CASH_APPLIED_AMOUNT,
      GG2_AR_INVOICE_WRITEOFF_AMOUNT,
      GG2_AR_CREDIT_MEMO_AMOUNT,
      GG2_UNBILLED_RECEIVABLES,
      GG2_UNEARNED_REVENUE,
      GG2_AR_UNAPPR_INVOICE_AMOUNT,
      GG2_AR_APPR_INVOICE_AMOUNT,
      GG2_AR_AMOUNT_DUE,
      GG2_AR_AMOUNT_OVERDUE,
      GP2_REVENUE,
      GP2_FUNDING,
      GP2_INITIAL_FUNDING_AMOUNT,
      GP2_ADDITIONAL_FUNDING_AMOUNT,
      GP2_CANCELLED_FUNDING_AMOUNT,
      GP2_FUNDING_ADJUSTMENT_AMOUNT,
      GP2_REVENUE_WRITEOFF,
      GP2_AR_INVOICE_AMOUNT,
      GP2_AR_CASH_APPLIED_AMOUNT,
      GP2_AR_INVOICE_WRITEOFF_AMOUNT,
      GP2_AR_CREDIT_MEMO_AMOUNT,
      GP2_UNBILLED_RECEIVABLES,
      GP2_UNEARNED_REVENUE,
      GP2_AR_UNAPPR_INVOICE_AMOUNT,
      GP2_AR_APPR_INVOICE_AMOUNT,
      GP2_AR_AMOUNT_DUE,
      GP2_AR_AMOUNT_OVERDUE
    )
    select
      0 WORKER_ID,
      DANGLING_GL_RATE_FLAG,
      DANGLING_GL_RATE2_FLAG,
      DANGLING_PA_RATE_FLAG,
      DANGLING_PA_RATE2_FLAG,
      DANGLING_EN_TIME_FLAG,
      DANGLING_GL_TIME_FLAG,
      DANGLING_PA_TIME_FLAG,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TASK_ID,
      GL_TIME_ID,
      GL_PERIOD_NAME,
      PA_TIME_ID,
      PA_PERIOD_NAME,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      PRJ_REVENUE,
      PRJ_FUNDING,
      PRJ_INITIAL_FUNDING_AMOUNT,
      PRJ_ADDITIONAL_FUNDING_AMOUNT,
      PRJ_CANCELLED_FUNDING_AMOUNT,
      PRJ_FUNDING_ADJUSTMENT_AMOUNT,
      PRJ_REVENUE_WRITEOFF,
      PRJ_AR_INVOICE_AMOUNT,
      PRJ_AR_CASH_APPLIED_AMOUNT,
      PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
      PRJ_AR_CREDIT_MEMO_AMOUNT,
      PRJ_UNBILLED_RECEIVABLES,
      PRJ_UNEARNED_REVENUE,
      PRJ_AR_UNAPPR_INVOICE_AMOUNT,
      PRJ_AR_APPR_INVOICE_AMOUNT,
      PRJ_AR_AMOUNT_DUE,
      PRJ_AR_AMOUNT_OVERDUE,
      POU_REVENUE,
      POU_FUNDING,
      POU_INITIAL_FUNDING_AMOUNT,
      POU_ADDITIONAL_FUNDING_AMOUNT,
      POU_CANCELLED_FUNDING_AMOUNT,
      POU_FUNDING_ADJUSTMENT_AMOUNT,
      POU_REVENUE_WRITEOFF,
      POU_AR_INVOICE_AMOUNT,
      POU_AR_CASH_APPLIED_AMOUNT,
      POU_AR_INVOICE_WRITEOFF_AMOUNT,
      POU_AR_CREDIT_MEMO_AMOUNT,
      POU_UNBILLED_RECEIVABLES,
      POU_UNEARNED_REVENUE,
      POU_AR_UNAPPR_INVOICE_AMOUNT,
      POU_AR_APPR_INVOICE_AMOUNT,
      POU_AR_AMOUNT_DUE,
      POU_AR_AMOUNT_OVERDUE,
      TXN_CURRENCY_CODE,
      TXN_REVENUE,
      TXN_FUNDING,
      TXN_INITIAL_FUNDING_AMOUNT,
      TXN_ADDITIONAL_FUNDING_AMOUNT,
      TXN_CANCELLED_FUNDING_AMOUNT,
      TXN_FUNDING_ADJUSTMENT_AMOUNT,
      TXN_REVENUE_WRITEOFF,
      TXN_AR_INVOICE_AMOUNT,
      TXN_AR_CASH_APPLIED_AMOUNT,
      TXN_AR_INVOICE_WRITEOFF_AMOUNT,
      TXN_AR_CREDIT_MEMO_AMOUNT,
      TXN_UNBILLED_RECEIVABLES,
      TXN_UNEARNED_REVENUE,
      TXN_AR_UNAPPR_INVOICE_AMOUNT,
      TXN_AR_APPR_INVOICE_AMOUNT,
      TXN_AR_AMOUNT_DUE,
      TXN_AR_AMOUNT_OVERDUE,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_COUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_COUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_COUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_COUNT,
      AR_COUNT_DUE,
      AR_COUNT_OVERDUE,
      GG_REVENUE,
      GG_FUNDING,
      GG_INITIAL_FUNDING_AMOUNT,
      GG_ADDITIONAL_FUNDING_AMOUNT,
      GG_CANCELLED_FUNDING_AMOUNT,
      GG_FUNDING_ADJUSTMENT_AMOUNT,
      GG_REVENUE_WRITEOFF,
      GG_AR_INVOICE_AMOUNT,
      GG_AR_CASH_APPLIED_AMOUNT,
      GG_AR_INVOICE_WRITEOFF_AMOUNT,
      GG_AR_CREDIT_MEMO_AMOUNT,
      GG_UNBILLED_RECEIVABLES,
      GG_UNEARNED_REVENUE,
      GG_AR_UNAPPR_INVOICE_AMOUNT,
      GG_AR_APPR_INVOICE_AMOUNT,
      GG_AR_AMOUNT_DUE,
      GG_AR_AMOUNT_OVERDUE,
      GP_REVENUE,
      GP_FUNDING,
      GP_INITIAL_FUNDING_AMOUNT,
      GP_ADDITIONAL_FUNDING_AMOUNT,
      GP_CANCELLED_FUNDING_AMOUNT,
      GP_FUNDING_ADJUSTMENT_AMOUNT,
      GP_REVENUE_WRITEOFF,
      GP_AR_INVOICE_AMOUNT,
      GP_AR_CASH_APPLIED_AMOUNT,
      GP_AR_INVOICE_WRITEOFF_AMOUNT,
      GP_AR_CREDIT_MEMO_AMOUNT,
      GP_UNBILLED_RECEIVABLES,
      GP_UNEARNED_REVENUE,
      GP_AR_UNAPPR_INVOICE_AMOUNT,
      GP_AR_APPR_INVOICE_AMOUNT,
      GP_AR_AMOUNT_DUE,
      GP_AR_AMOUNT_OVERDUE,
      GG2_REVENUE,
      GG2_FUNDING,
      GG2_INITIAL_FUNDING_AMOUNT,
      GG2_ADDITIONAL_FUNDING_AMOUNT,
      GG2_CANCELLED_FUNDING_AMOUNT,
      GG2_FUNDING_ADJUSTMENT_AMOUNT,
      GG2_REVENUE_WRITEOFF,
      GG2_AR_INVOICE_AMOUNT,
      GG2_AR_CASH_APPLIED_AMOUNT,
      GG2_AR_INVOICE_WRITEOFF_AMOUNT,
      GG2_AR_CREDIT_MEMO_AMOUNT,
      GG2_UNBILLED_RECEIVABLES,
      GG2_UNEARNED_REVENUE,
      GG2_AR_UNAPPR_INVOICE_AMOUNT,
      GG2_AR_APPR_INVOICE_AMOUNT,
      GG2_AR_AMOUNT_DUE,
      GG2_AR_AMOUNT_OVERDUE,
      GP2_REVENUE,
      GP2_FUNDING,
      GP2_INITIAL_FUNDING_AMOUNT,
      GP2_ADDITIONAL_FUNDING_AMOUNT,
      GP2_CANCELLED_FUNDING_AMOUNT,
      GP2_FUNDING_ADJUSTMENT_AMOUNT,
      GP2_REVENUE_WRITEOFF,
      GP2_AR_INVOICE_AMOUNT,
      GP2_AR_CASH_APPLIED_AMOUNT,
      GP2_AR_INVOICE_WRITEOFF_AMOUNT,
      GP2_AR_CREDIT_MEMO_AMOUNT,
      GP2_UNBILLED_RECEIVABLES,
      GP2_UNEARNED_REVENUE,
      GP2_AR_UNAPPR_INVOICE_AMOUNT,
      GP2_AR_APPR_INVOICE_AMOUNT,
      GP2_AR_AMOUNT_DUE,
      GP2_AR_AMOUNT_OVERDUE
    from
      PJI_FM_AGGR_ACT2
    where
      WORKER_ID = p_worker_id and
      (DANGLING_GL_RATE_FLAG  is not null or
       DANGLING_GL_RATE2_FLAG is not null or
       DANGLING_PA_RATE_FLAG  is not null or
       DANGLING_PA_RATE2_FLAG is not null or
       DANGLING_EN_TIME_FLAG  is not null or
       DANGLING_GL_TIME_FLAG  is not null or
       DANGLING_PA_TIME_FLAG  is not null);

    delete
    from   PJI_FM_AGGR_ACT2
    where  WORKER_ID = p_worker_id and
           (DANGLING_GL_RATE_FLAG  is not null or
            DANGLING_GL_RATE2_FLAG is not null or
            DANGLING_PA_RATE_FLAG  is not null or
            DANGLING_PA_RATE2_FLAG is not null or
            DANGLING_EN_TIME_FLAG  is not null or
            DANGLING_GL_TIME_FLAG  is not null or
            DANGLING_PA_TIME_FLAG  is not null);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.MOVE_DANGLING_ACT_ROWS(p_worker_id);');

    commit;

  end MOVE_DANGLING_ACT_ROWS;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_RES_SLICES
  -- -----------------------------------------------------
  procedure AGGREGATE_RES_SLICES (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.AGGREGATE_RES_SLICES(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    if (l_extraction_type = 'PARTIAL') then

      delete
      from   PJI_RM_AGGR_RES6
      where  PROJECT_ID in (select PROJECT_ID
                            from   PJI_FM_PROJ_BATCH_MAP
                            where  WORKER_ID = p_worker_id);

    end if;

    insert into PJI_RM_AGGR_RES6
    (
      WORKER_ID,
      PROJECT_ID,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      WORK_TYPE_ID,
      JOB_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      TOTAL_HRS_A,
      BILL_HRS_A
    )
    select
      WORKER_ID,
      PROJECT_ID,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      WORK_TYPE_ID,
      JOB_ID,
      EXPENDITURE_ITEM_TIME_ID TIME_ID,
      1                        PERIOD_TYPE_ID,
      'C'                      CALENDAR_TYPE,
      RS_GL_CALENDAR_ID        GL_CALENDAR_ID,
      RS_PA_CALENDAR_ID        PA_CALENDAR_ID,
      sum(LABOR_HRS)           TOTAL_HRS_A,
      sum(BILL_LABOR_HRS)      BILL_HRS_A
    from
      PJI_FM_AGGR_FIN2
    where
      WORKER_ID = p_worker_id and
      PJI_RESOURCE_RECORD_FLAG = 'Y'
    group by
      WORKER_ID,
      PROJECT_ID,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      WORK_TYPE_ID,
      JOB_ID,
      EXPENDITURE_ITEM_TIME_ID,
      RS_GL_CALENDAR_ID,
      RS_PA_CALENDAR_ID;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.AGGREGATE_RES_SLICES(p_worker_id);');

    commit;

  end AGGREGATE_RES_SLICES;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_FIN_SLICES
  -- -----------------------------------------------------
  procedure AGGREGATE_FIN_SLICES (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.AGGREGATE_FIN_SLICES(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    if (l_extraction_type = 'PARTIAL') then

      delete
      from   PJI_FM_AGGR_FIN9
      where  PROJECT_ID in (select PROJECT_ID
                            from   PJI_FM_PROJ_BATCH_MAP
                            where  WORKER_ID = p_worker_id);

    end if;

    insert into PJI_FM_AGGR_FIN9
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ORG_ID,
      PROJECT_TYPE_CLASS,
      WORK_TYPE_ID,
      EXP_EVT_TYPE_ID,
      TIME_ID,
      CALENDAR_TYPE,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      TXN_CURRENCY_CODE,
      TXN_REVENUE,
      TXN_RAW_COST,
      TXN_BRDN_COST,
      TXN_BILL_RAW_COST,
      TXN_BILL_BRDN_COST,
      PRJ_REVENUE,
      PRJ_LABOR_REVENUE,
      PRJ_RAW_COST,
      PRJ_BRDN_COST,
      PRJ_BILL_RAW_COST,
      PRJ_BILL_BRDN_COST,
      PRJ_LABOR_RAW_COST,
      PRJ_LABOR_BRDN_COST,
      PRJ_BILL_LABOR_RAW_COST,
      PRJ_BILL_LABOR_BRDN_COST,
      PRJ_REVENUE_WRITEOFF,
      POU_REVENUE,
      POU_LABOR_REVENUE,
      POU_RAW_COST,
      POU_BRDN_COST,
      POU_BILL_RAW_COST,
      POU_BILL_BRDN_COST,
      POU_LABOR_RAW_COST,
      POU_LABOR_BRDN_COST,
      POU_BILL_LABOR_RAW_COST,
      POU_BILL_LABOR_BRDN_COST,
      POU_REVENUE_WRITEOFF,
      EOU_REVENUE,
      EOU_RAW_COST,
      EOU_BRDN_COST,
      EOU_BILL_RAW_COST,
      EOU_BILL_BRDN_COST,
      G1_REVENUE,
      G1_LABOR_REVENUE,
      G1_RAW_COST,
      G1_BRDN_COST,
      G1_BILL_RAW_COST,
      G1_BILL_BRDN_COST,
      G1_LABOR_RAW_COST,
      G1_LABOR_BRDN_COST,
      G1_BILL_LABOR_RAW_COST,
      G1_BILL_LABOR_BRDN_COST,
      G1_REVENUE_WRITEOFF,
      G2_REVENUE,
      G2_LABOR_REVENUE,
      G2_RAW_COST,
      G2_BRDN_COST,
      G2_BILL_RAW_COST,
      G2_BILL_BRDN_COST,
      G2_LABOR_RAW_COST,
      G2_LABOR_BRDN_COST,
      G2_BILL_LABOR_RAW_COST,
      G2_BILL_LABOR_BRDN_COST,
      G2_REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      QUANTITY,
      BILL_QUANTITY
    )
    select /*+ ordered
               full(tmp2)    use_hash(tmp2)     parallel(tmp2)
               full(invert)  use_hash(invert)   swap_join_inputs(invert) */
      p_worker_id                                 WORKER_ID,
      tmp2.PROJECT_ID,
      tmp2.PROJECT_ORGANIZATION_ID,
      tmp2.PROJECT_ORG_ID,
      tmp2.PROJECT_TYPE_CLASS,
      tmp2.WORK_TYPE_ID,
      tmp2.EXP_EVT_TYPE_ID,
      decode(invert.INVERT_ID,
             'GL', tmp2.RECVR_GL_TIME_ID,
             'PA', tmp2.RECVR_PA_TIME_ID)         TIME_ID,
      decode(invert.INVERT_ID,
             'GL', 'C',
             'PA', 'P')                           CALENDAR_TYPE,
      tmp2.PJ_GL_CALENDAR_ID                      GL_CALENDAR_ID,
      tmp2.PJ_PA_CALENDAR_ID                      PA_CALENDAR_ID,
      null                                        TXN_CURRENCY_CODE,
      to_number(null)                             TXN_REVENUE,
      to_number(null)                             TXN_RAW_COST,
      to_number(null)                             TXN_BRDN_COST,
      to_number(null)                             TXN_BILL_RAW_COST,
      to_number(null)                             TXN_BILL_BRDN_COST,
      sum(tmp2.PRJ_REVENUE)                       PRJ_REVENUE,
      sum(tmp2.PRJ_LABOR_REVENUE)                 PRJ_LABOR_REVENUE,
      sum(tmp2.PRJ_RAW_COST)                      PRJ_RAW_COST,
      sum(tmp2.PRJ_BRDN_COST)                     PRJ_BRDN_COST,
      sum(tmp2.PRJ_BILL_RAW_COST)                 PRJ_BILL_RAW_COST,
      sum(tmp2.PRJ_BILL_BRDN_COST)                PRJ_BILL_BRDN_COST,
      sum(tmp2.PRJ_LABOR_RAW_COST)                PRJ_LABOR_RAW_COST,
      sum(tmp2.PRJ_LABOR_BRDN_COST)               PRJ_LABOR_BRDN_COST,
      sum(tmp2.PRJ_BILL_LABOR_RAW_COST)           PRJ_BILL_LABOR_RAW_COST,
      sum(tmp2.PRJ_BILL_LABOR_BRDN_COST)          PRJ_BILL_LABOR_BRDN_COST,
      sum(tmp2.PRJ_REVENUE_WRITEOFF)              PRJ_REVENUE_WRITEOFF,
      sum(tmp2.POU_REVENUE)                       POU_REVENUE,
      sum(tmp2.POU_LABOR_REVENUE)                 POU_LABOR_REVENUE,
      sum(tmp2.POU_RAW_COST)                      POU_RAW_COST,
      sum(tmp2.POU_BRDN_COST)                     POU_BRDN_COST,
      sum(tmp2.POU_BILL_RAW_COST)                 POU_BILL_RAW_COST,
      sum(tmp2.POU_BILL_BRDN_COST)                POU_BILL_BRDN_COST,
      sum(tmp2.POU_LABOR_RAW_COST)                POU_LABOR_RAW_COST,
      sum(tmp2.POU_LABOR_BRDN_COST)               POU_LABOR_BRDN_COST,
      sum(tmp2.POU_BILL_LABOR_RAW_COST)           POU_BILL_LABOR_RAW_COST,
      sum(tmp2.POU_BILL_LABOR_BRDN_COST)          POU_BILL_LABOR_BRDN_COST,
      sum(tmp2.POU_REVENUE_WRITEOFF)              POU_REVENUE_WRITEOFF,
      to_number(null)                             EOU_REVENUE,
      to_number(null)                             EOU_RAW_COST,
      to_number(null)                             EOU_BRDN_COST,
      to_number(null)                             EOU_BILL_RAW_COST,
      to_number(null)                             EOU_BILL_BRDN_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG1_REVENUE,
                 'PA', tmp2.GP1_REVENUE))         G1_REVENUE,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG1_LABOR_REVENUE,
                 'PA', tmp2.GP1_LABOR_REVENUE))   G1_LABOR_REVENUE,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG1_RAW_COST,
                 'PA', tmp2.GP1_RAW_COST))        G1_RAW_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG1_BRDN_COST,
                 'PA', tmp2.GP1_BRDN_COST))       G1_BRDN_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG1_BILL_RAW_COST,
                 'PA', tmp2.GP1_BILL_RAW_COST))   G1_BILL_RAW_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG1_BILL_BRDN_COST,
                 'PA', tmp2.GP1_BILL_BRDN_COST))
                                                  G1_BILL_BRDN_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG1_LABOR_RAW_COST,
                 'PA', tmp2.GP1_LABOR_RAW_COST))
                                                  G1_LABOR_RAW_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG1_LABOR_BRDN_COST,
                 'PA', tmp2.GP1_LABOR_BRDN_COST))
                                                  G1_LABOR_BRDN_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG1_BILL_LABOR_RAW_COST,
                 'PA', tmp2.GP1_BILL_LABOR_RAW_COST))
                                                  G1_BILL_LABOR_RAW_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG1_BILL_LABOR_BRDN_COST,
                 'PA', tmp2.GP1_BILL_LABOR_BRDN_COST))
                                                  G1_BILL_LABOR_BRDN_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG1_REVENUE_WRITEOFF,
                 'PA', tmp2.GP1_REVENUE_WRITEOFF))G1_REVENUE_WRITEOFF,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_REVENUE,
                 'PA', tmp2.GP2_REVENUE))         G2_REVENUE,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_LABOR_REVENUE,
                 'PA', tmp2.GP2_LABOR_REVENUE))   G2_LABOR_REVENUE,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_RAW_COST,
                 'PA', tmp2.GP2_RAW_COST))        G2_RAW_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_BRDN_COST,
                 'PA', tmp2.GP2_BRDN_COST))       G2_BRDN_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_BILL_RAW_COST,
                 'PA', tmp2.GP2_BILL_RAW_COST))   G2_BILL_RAW_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_BILL_BRDN_COST,
                 'PA', tmp2.GP2_BILL_BRDN_COST))
                                                  G2_BILL_BRDN_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_LABOR_RAW_COST,
                 'PA', tmp2.GP2_LABOR_RAW_COST))  G2_LABOR_RAW_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_LABOR_BRDN_COST,
                 'PA', tmp2.GP2_LABOR_BRDN_COST))
                                                  G2_LABOR_BRDN_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_BILL_LABOR_RAW_COST,
                 'PA', tmp2.GP2_BILL_LABOR_RAW_COST))
                                                  G2_BILL_LABOR_RAW_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_BILL_LABOR_BRDN_COST,
                 'PA', tmp2.GP2_BILL_LABOR_BRDN_COST))
                                                  G2_BILL_LABOR_BRDN_COST,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_REVENUE_WRITEOFF,
                 'PA', tmp2.GP2_REVENUE_WRITEOFF))G2_REVENUE_WRITEOFF,
      sum(tmp2.LABOR_HRS)                         LABOR_HRS,
      sum(tmp2.BILL_LABOR_HRS)                    BILL_LABOR_HRS,
      sum(tmp2.TOTAL_HRS_A)                       QUANTITY,
      sum(tmp2.BILL_HRS_A)                        BILL_QUANTITY
    from
      (
        select 'GL' INVERT_ID from DUAL union all
        select 'PA' INVERT_ID from DUAL
      ) invert,
      (
      select /*+ ordered
               full(fin2)    use_hash(fin2)     parallel(fin2)
               full(invert)  use_hash(invert)   swap_join_inputs(invert) */
      p_worker_id                                 WORKER_ID,
      fin2.PROJECT_ID,
      fin2.PROJECT_ORGANIZATION_ID,
      fin2.PROJECT_ORG_ID,
      fin2.PROJECT_TYPE_CLASS,
      fin2.WORK_TYPE_ID,
      fin2.EXP_EVT_TYPE_ID,
      fin2.RECVR_GL_TIME_ID,
      fin2.RECVR_PA_TIME_ID,
      fin2.PJ_GL_CALENDAR_ID,
      fin2.PJ_PA_CALENDAR_ID,
      null                                   TXN_CURRENCY_CODE,
      to_number(null)                        TXN_REVENUE,
      to_number(null)                        TXN_RAW_COST,
      to_number(null)                        TXN_BRDN_COST,
      to_number(null)                        TXN_BILL_RAW_COST,
      to_number(null)                        TXN_BILL_BRDN_COST,
      fin2.PRJ_REVENUE                       PRJ_REVENUE,
      fin2.PRJ_LABOR_REVENUE                 PRJ_LABOR_REVENUE,
      fin2.PRJ_RAW_COST                      PRJ_RAW_COST,
      fin2.PRJ_BRDN_COST                     PRJ_BRDN_COST,
      fin2.PRJ_BILL_RAW_COST                 PRJ_BILL_RAW_COST,
      fin2.PRJ_BILL_BRDN_COST                PRJ_BILL_BRDN_COST,
      fin2.PRJ_LABOR_RAW_COST                PRJ_LABOR_RAW_COST,
      fin2.PRJ_LABOR_BRDN_COST               PRJ_LABOR_BRDN_COST,
      fin2.PRJ_BILL_LABOR_RAW_COST           PRJ_BILL_LABOR_RAW_COST,
      fin2.PRJ_BILL_LABOR_BRDN_COST          PRJ_BILL_LABOR_BRDN_COST,
      fin2.PRJ_REVENUE_WRITEOFF              PRJ_REVENUE_WRITEOFF,
      fin2.POU_REVENUE                       POU_REVENUE,
      fin2.POU_LABOR_REVENUE                 POU_LABOR_REVENUE,
      fin2.POU_RAW_COST                      POU_RAW_COST,
      fin2.POU_BRDN_COST                     POU_BRDN_COST,
      fin2.POU_BILL_RAW_COST                 POU_BILL_RAW_COST,
      fin2.POU_BILL_BRDN_COST                POU_BILL_BRDN_COST,
      fin2.POU_LABOR_RAW_COST                POU_LABOR_RAW_COST,
      fin2.POU_LABOR_BRDN_COST               POU_LABOR_BRDN_COST,
      fin2.POU_BILL_LABOR_RAW_COST           POU_BILL_LABOR_RAW_COST,
      fin2.POU_BILL_LABOR_BRDN_COST          POU_BILL_LABOR_BRDN_COST,
      fin2.POU_REVENUE_WRITEOFF              POU_REVENUE_WRITEOFF,
      to_number(null)                        EOU_REVENUE,
      to_number(null)                        EOU_RAW_COST,
      to_number(null)                        EOU_BRDN_COST,
      to_number(null)                        EOU_BILL_RAW_COST,
      to_number(null)                        EOU_BILL_BRDN_COST,
      fin2.GG1_REVENUE,
      fin2.GP1_REVENUE,
      fin2.GG1_LABOR_REVENUE,
      fin2.GP1_LABOR_REVENUE,
      fin2.GG1_RAW_COST,
      fin2.GP1_RAW_COST,
      fin2.GG1_BRDN_COST,
      fin2.GP1_BRDN_COST,
      fin2.GG1_BILL_RAW_COST,
      fin2.GP1_BILL_RAW_COST,
      fin2.GG1_BILL_BRDN_COST,
      fin2.GP1_BILL_BRDN_COST,
      fin2.GG1_LABOR_RAW_COST,
      fin2.GP1_LABOR_RAW_COST,
      fin2.GG1_LABOR_BRDN_COST,
      fin2.GP1_LABOR_BRDN_COST,
      fin2.GG1_BILL_LABOR_RAW_COST,
      fin2.GP1_BILL_LABOR_RAW_COST,
      fin2.GG1_BILL_LABOR_BRDN_COST,
      fin2.GP1_BILL_LABOR_BRDN_COST,
      fin2.GG1_REVENUE_WRITEOFF,
      fin2.GP1_REVENUE_WRITEOFF,
      fin2.GG2_REVENUE,
      fin2.GP2_REVENUE,
      fin2.GG2_LABOR_REVENUE,
      fin2.GP2_LABOR_REVENUE,
      fin2.GG2_RAW_COST,
      fin2.GP2_RAW_COST,
      fin2.GG2_BRDN_COST,
      fin2.GP2_BRDN_COST,
      fin2.GG2_BILL_RAW_COST,
      fin2.GP2_BILL_RAW_COST,
      fin2.GG2_BILL_BRDN_COST,
      fin2.GP2_BILL_BRDN_COST,
      fin2.GG2_LABOR_RAW_COST,
      fin2.GP2_LABOR_RAW_COST,
      fin2.GG2_LABOR_BRDN_COST,
      fin2.GP2_LABOR_BRDN_COST,
      fin2.GG2_BILL_LABOR_RAW_COST,
      fin2.GP2_BILL_LABOR_RAW_COST,
      fin2.GG2_BILL_LABOR_BRDN_COST,
      fin2.GP2_BILL_LABOR_BRDN_COST,
      fin2.GG2_REVENUE_WRITEOFF,
      fin2.GP2_REVENUE_WRITEOFF,
      fin2.LABOR_HRS,
      fin2.BILL_LABOR_HRS,
      fin2.TOTAL_HRS_A,
      fin2.BILL_HRS_A,
      fin2.PJI_PROJECT_RECORD_FLAG
    from
        PJI_FM_AGGR_FIN2 fin2
    where
      fin2.WORKER_ID = p_worker_id and
      fin2.PJI_PROJECT_RECORD_FLAG = 'Y'
    union all /* this union added for bug 9249905 */
      select /*+ ordered
               full(cmt)    use_hash(cmt)     parallel(cmt)
               full(invert)  use_hash(invert)   swap_join_inputs(invert) */
      p_worker_id                                 WORKER_ID,
      cmt.PROJECT_ID,
      cmt.PROJECT_ORGANIZATION_ID,
      cmt.PROJECT_ORG_ID,
      cmt.PROJECT_TYPE_CLASS,
      cmt.WORK_TYPE_ID,
      cmt.EXP_EVT_TYPE_ID,
      cmt.RECVR_GL_TIME_ID,
      cmt.RECVR_PA_TIME_ID,
      cmt.PJ_GL_CALENDAR_ID,
      cmt.PJ_PA_CALENDAR_ID,
      null              TXN_CURRENCY_CODE,
      to_number(null)   TXN_REVENUE,
      to_number(null)   TXN_RAW_COST,
      to_number(null)   TXN_BRDN_COST,
      to_number(null)   TXN_BILL_RAW_COST,
      to_number(null)   TXN_BILL_BRDN_COST,
      to_number(null)   PRJ_REVENUE,
      to_number(null)   PRJ_LABOR_REVENUE,
      -cmt.PRJ_RAW_COST                      PRJ_RAW_COST,
      -cmt.PRJ_BRDN_COST                     PRJ_BRDN_COST,
      to_number(null)   PRJ_BILL_RAW_COST,
      to_number(null)   PRJ_BILL_BRDN_COST,
      to_number(null)   PRJ_LABOR_RAW_COST,
      to_number(null)   PRJ_LABOR_BRDN_COST,
      to_number(null)   PRJ_BILL_LABOR_RAW_COST,
      to_number(null)   PRJ_BILL_LABOR_BRDN_COST,
      to_number(null)   PRJ_REVENUE_WRITEOFF,
      to_number(null)   POU_REVENUE,
      to_number(null)   POU_LABOR_REVENUE,
      -cmt.POU_RAW_COST                      POU_RAW_COST,
      -cmt.POU_BRDN_COST                     POU_BRDN_COST,
      to_number(null)   POU_BILL_RAW_COST,
      to_number(null)   POU_BILL_BRDN_COST,
      to_number(null)   POU_LABOR_RAW_COST,
      to_number(null)   POU_LABOR_BRDN_COST,
      to_number(null)   POU_BILL_LABOR_RAW_COST,
      to_number(null)   POU_BILL_LABOR_BRDN_COST,
      to_number(null)   POU_REVENUE_WRITEOFF,
      to_number(null)   EOU_REVENUE,
      to_number(null)   EOU_RAW_COST,
      to_number(null)   EOU_BRDN_COST,
      to_number(null)   EOU_BILL_RAW_COST,
      to_number(null)   EOU_BILL_BRDN_COST,
      to_number(null)   GG1_REVENUE,
      to_number(null)   GP1_REVENUE,
      to_number(null)   GG1_LABOR_REVENUE,
      to_number(null)   GP1_LABOR_REVENUE,
      -cmt.GG1_RAW_COST,
      -cmt.GP1_RAW_COST,
      -cmt.GG1_BRDN_COST,
      -cmt.GP1_BRDN_COST,
      to_number(null)   GG1_BILL_RAW_COST,
      to_number(null)   GP1_BILL_RAW_COST,
      to_number(null)   GG1_BILL_BRDN_COST,
      to_number(null)   GP1_BILL_BRDN_COST,
      to_number(null)   GG1_LABOR_RAW_COST,
      to_number(null)   GP1_LABOR_RAW_COST,
      to_number(null)   GG1_LABOR_BRDN_COST,
      to_number(null)   GP1_LABOR_BRDN_COST,
      to_number(null)   GG1_BILL_LABOR_RAW_COST,
      to_number(null)   GP1_BILL_LABOR_RAW_COST,
      to_number(null)   GG1_BILL_LABOR_BRDN_COST,
      to_number(null)   GP1_BILL_LABOR_BRDN_COST,
      to_number(null)   GG1_REVENUE_WRITEOFF,
      to_number(null)   GP1_REVENUE_WRITEOFF,
      to_number(null)   GG2_REVENUE,
      to_number(null)   GP2_REVENUE,
      to_number(null)   GG2_LABOR_REVENUE,
      to_number(null)   GP2_LABOR_REVENUE,
      -cmt.GG2_RAW_COST,
      -cmt.GP2_RAW_COST,
      -cmt.GG2_BRDN_COST,
      -cmt.GP2_BRDN_COST,
      to_number(null)   GG2_BILL_RAW_COST,
      to_number(null)   GP2_BILL_RAW_COST,
      to_number(null)   GG2_BILL_BRDN_COST,
      to_number(null)   GP2_BILL_BRDN_COST,
      to_number(null)   GG2_LABOR_RAW_COST,
      to_number(null)   GP2_LABOR_RAW_COST,
      to_number(null)   GG2_LABOR_BRDN_COST,
      to_number(null)   GP2_LABOR_BRDN_COST,
      to_number(null)   GG2_BILL_LABOR_RAW_COST,
      to_number(null)   GP2_BILL_LABOR_RAW_COST,
      to_number(null)   GG2_BILL_LABOR_BRDN_COST,
      to_number(null)   GP2_BILL_LABOR_BRDN_COST,
      to_number(null)   GG2_REVENUE_WRITEOFF,
      to_number(null)   GP2_REVENUE_WRITEOFF,
      to_number(null)   LABOR_HRS,
      to_number(null)   BILL_LABOR_HRS,
      to_number(null)   TOTAL_HRS_A,
      to_number(null)   BILL_HRS_A,
      cmt.PJI_PROJECT_RECORD_FLAG
    from
        PJI_FM_PJI_CMT cmt,
        PJI_FM_AGGR_FIN2 fin2
    where
      fin2.WORKER_ID = p_worker_id and
      cmt.PJI_PROJECT_RECORD_FLAG = 'Y' and
      cmt.project_id = fin2.project_id
      ) tmp2
    where
      tmp2.WORKER_ID = p_worker_id and
      tmp2.PJI_PROJECT_RECORD_FLAG = 'Y'
    group by
      tmp2.PROJECT_ID,
      tmp2.PROJECT_ORGANIZATION_ID,
      tmp2.PROJECT_ORG_ID,
      tmp2.PROJECT_TYPE_CLASS,
      tmp2.WORK_TYPE_ID,
      tmp2.EXP_EVT_TYPE_ID,
      decode(invert.INVERT_ID,
             'GL', tmp2.RECVR_GL_TIME_ID,
             'PA', tmp2.RECVR_PA_TIME_ID),
      decode(invert.INVERT_ID,
             'GL', 'C',
             'PA', 'P'),
      tmp2.PJ_GL_CALENDAR_ID,
      tmp2.PJ_PA_CALENDAR_ID,
      tmp2.TXN_CURRENCY_CODE;

      /* Added for bug 9249905 */
      if PJI_UTILS.GET_PARAMETER('LAST_PJI_EXTR_DATE') is not null then

          delete from PJI_FM_PJI_CMT
          where project_id in (select distinct project_id
                               from PJI_FM_AGGR_FIN2);

          insert into PJI_FM_PJI_CMT
          (
            WORKER_ID ,
            PJI_PROJECT_RECORD_FLAG,
            PJI_RESOURCE_RECORD_FLAG,
            PROJECT_ID,
            PROJECT_ORG_ID,
            PROJECT_ORGANIZATION_ID,
            PERSON_ID,
            EXPENDITURE_ORG_ID,
            EXPENDITURE_ORGANIZATION_ID,
            WORK_TYPE_ID,
            JOB_ID,
            PRVDR_GL_TIME_ID,
            RECVR_GL_TIME_ID ,
            PRVDR_PA_TIME_ID ,
            RECVR_PA_TIME_ID ,
            PRJ_RAW_COST,
            PRJ_BRDN_COST ,
            POU_RAW_COST,
            POU_BRDN_COST,
            GG_RAW_COST ,
            GG_BRDN_COST ,
            GP_RAW_COST ,
            GP_BRDN_COST ,
            EXPENDITURE_ITEM_TIME_ID ,
            EXP_EVT_TYPE_ID,
            PROJECT_TYPE_CLASS  ,
            PJ_GL_CALENDAR_ID ,
            PJ_PA_CALENDAR_ID,
            RS_GL_CALENDAR_ID,
            RS_PA_CALENDAR_ID ,
            RECORD_TYPE  ,
            CMT_RECORD_TYPE ,
            TASK_ID,
            VENDOR_ID   ,
            EXPENDITURE_TYPE,
            EVENT_TYPE,
            EVENT_TYPE_CLASSIFICATION,
            EXPENDITURE_CATEGORY,
            REVENUE_CATEGORY ,
            NON_LABOR_RESOURCE  ,
            BOM_LABOR_RESOURCE_ID  ,
            BOM_EQUIPMENT_RESOURCE_ID,
            INVENTORY_ITEM_ID   ,
            SYSTEM_LINKAGE_FUNCTION  ,
            GL_PERIOD_NAME  ,
            PA_PERIOD_NAME ,
            TXN_CURRENCY_CODE,
            TXN_RAW_COST,
            TXN_BRDN_COST,
            EOU_RAW_COST ,
            EOU_BRDN_COST,
            GG1_RAW_COST,
            GG1_BRDN_COST  ,
            GP1_RAW_COST,
            GP1_BRDN_COST ,
            GG2_RAW_COST ,
            GG2_BRDN_COST ,
            GP2_RAW_COST ,
            GP2_BRDN_COST  ,
            PO_LINE_ID ,
            RESOURCE_CLASS_CODE ,
            ASSIGNMENT_ID
          )
          select /*+ ordered
                     full(tmp2)    use_hash(tmp2)     parallel(tmp2)
                     full(invert)  use_hash(invert)   swap_join_inputs(invert) */
            p_worker_id                                 WORKER_ID,
            PJI_PROJECT_RECORD_FLAG,
            PJI_RESOURCE_RECORD_FLAG,
            PROJECT_ID,
            PROJECT_ORG_ID,
            PROJECT_ORGANIZATION_ID,
            PERSON_ID,
            EXPENDITURE_ORG_ID,
            EXPENDITURE_ORGANIZATION_ID,
            WORK_TYPE_ID,
            JOB_ID,
            PRVDR_GL_TIME_ID,
            RECVR_GL_TIME_ID ,
            PRVDR_PA_TIME_ID ,
            RECVR_PA_TIME_ID ,
            PRJ_RAW_COST,
            PRJ_BRDN_COST ,
            POU_RAW_COST,
            POU_BRDN_COST,
            GG_RAW_COST ,
            GG_BRDN_COST ,
            GP_RAW_COST ,
            GP_BRDN_COST ,
            EXPENDITURE_ITEM_TIME_ID ,
            EXP_EVT_TYPE_ID,
            PROJECT_TYPE_CLASS  ,
            PJ_GL_CALENDAR_ID ,
            PJ_PA_CALENDAR_ID,
            RS_GL_CALENDAR_ID,
            RS_PA_CALENDAR_ID ,
            RECORD_TYPE  ,
            CMT_RECORD_TYPE ,
            TASK_ID,
            VENDOR_ID   ,
            EXPENDITURE_TYPE,
            EVENT_TYPE,
            EVENT_TYPE_CLASSIFICATION,
            EXPENDITURE_CATEGORY,
            REVENUE_CATEGORY ,
            NON_LABOR_RESOURCE  ,
            BOM_LABOR_RESOURCE_ID  ,
            BOM_EQUIPMENT_RESOURCE_ID,
            INVENTORY_ITEM_ID   ,
            SYSTEM_LINKAGE_FUNCTION  ,
            GL_PERIOD_NAME  ,
            PA_PERIOD_NAME ,
            TXN_CURRENCY_CODE,
            TXN_RAW_COST,
            TXN_BRDN_COST,
            EOU_RAW_COST ,
            EOU_BRDN_COST,
            GG1_RAW_COST,
            GG1_BRDN_COST  ,
            GP1_RAW_COST,
            GP1_BRDN_COST ,
            GG2_RAW_COST ,
            GG2_BRDN_COST ,
            GP2_RAW_COST ,
            GP2_BRDN_COST  ,
            PO_LINE_ID ,
            RESOURCE_CLASS_CODE ,
            ASSIGNMENT_ID
          from
            PJI_FM_AGGR_FIN2 tmp2
          where
            tmp2.WORKER_ID = p_worker_id and
            tmp2.PJI_PROJECT_RECORD_FLAG = 'Y' and
            tmp2.RECORD_TYPE = 'M';

    end if;
    /* Added for bug 9249905 */

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.AGGREGATE_FIN_SLICES(p_worker_id);');

    commit;

  end AGGREGATE_FIN_SLICES;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_ACT_SLICES
  -- -----------------------------------------------------
  procedure AGGREGATE_ACT_SLICES (p_worker_id in number) is

    l_process          varchar2(30);
    l_extraction_type  varchar2(30);
    l_pa_calendar_flag varchar2(1);
    l_schema           varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.AGGREGATE_ACT_SLICES(p_worker_id);')) then
      return;
    end if;

    l_pa_calendar_flag := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      PJI_FM_SUM_MAIN.g_process,
      'PA_CALENDAR_FLAG'
    );

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    if (l_extraction_type = 'PARTIAL') then

      delete
      from   PJI_FM_AGGR_ACT5
      where  PROJECT_ID in (select PROJECT_ID
                            from   PJI_FM_PROJ_BATCH_MAP
                            where  WORKER_ID = p_worker_id);

    elsif (l_extraction_type = 'INCREMENTAL') then

      -- clean up snapshots and activities

      update PJI_FM_AGGR_ACT5 act5
      set    act5.TXN_AR_INVOICE_AMOUNT          = to_number(null),
             act5.TXN_AR_CASH_APPLIED_AMOUNT     = to_number(null),
             act5.TXN_AR_INVOICE_WRITEOFF_AMOUNT = to_number(null),
             act5.TXN_AR_CREDIT_MEMO_AMOUNT      = to_number(null),
             act5.TXN_AR_UNAPPR_INVOICE_AMOUNT   = to_number(null),
             act5.TXN_AR_APPR_INVOICE_AMOUNT     = to_number(null),
             act5.TXN_AR_AMOUNT_DUE              = to_number(null),
             act5.TXN_AR_AMOUNT_OVERDUE          = to_number(null),
             act5.PRJ_AR_INVOICE_AMOUNT          = to_number(null),
             act5.PRJ_AR_CASH_APPLIED_AMOUNT     = to_number(null),
             act5.PRJ_AR_INVOICE_WRITEOFF_AMOUNT = to_number(null),
             act5.PRJ_AR_CREDIT_MEMO_AMOUNT      = to_number(null),
             act5.PRJ_AR_UNAPPR_INVOICE_AMOUNT   = to_number(null),
             act5.PRJ_AR_APPR_INVOICE_AMOUNT     = to_number(null),
             act5.PRJ_AR_AMOUNT_DUE              = to_number(null),
             act5.PRJ_AR_AMOUNT_OVERDUE          = to_number(null),
             act5.POU_AR_INVOICE_AMOUNT          = to_number(null),
             act5.POU_AR_CASH_APPLIED_AMOUNT     = to_number(null),
             act5.POU_AR_INVOICE_WRITEOFF_AMOUNT = to_number(null),
             act5.POU_AR_CREDIT_MEMO_AMOUNT      = to_number(null),
             act5.POU_AR_UNAPPR_INVOICE_AMOUNT   = to_number(null),
             act5.POU_AR_APPR_INVOICE_AMOUNT     = to_number(null),
             act5.POU_AR_AMOUNT_DUE              = to_number(null),
             act5.POU_AR_AMOUNT_OVERDUE          = to_number(null),
             act5.AR_INVOICE_COUNT               = to_number(null),
             act5.AR_INVOICE_WRITEOFF_COUNT      = to_number(null),
             act5.AR_CREDIT_MEMO_COUNT           = to_number(null),
             act5.AR_UNAPPR_INVOICE_COUNT        = to_number(null),
             act5.AR_APPR_INVOICE_COUNT          = to_number(null),
             act5.AR_COUNT_DUE                   = to_number(null),
             act5.AR_COUNT_OVERDUE               = to_number(null),
             act5.G1_AR_INVOICE_AMOUNT           = to_number(null),
             act5.G1_AR_CASH_APPLIED_AMOUNT      = to_number(null),
             act5.G1_AR_INVOICE_WRITEOFF_AMOUNT  = to_number(null),
             act5.G1_AR_CREDIT_MEMO_AMOUNT       = to_number(null),
             act5.G1_AR_UNAPPR_INVOICE_AMOUNT    = to_number(null),
             act5.G1_AR_APPR_INVOICE_AMOUNT      = to_number(null),
             act5.G1_AR_AMOUNT_DUE               = to_number(null),
             act5.G1_AR_AMOUNT_OVERDUE           = to_number(null),
             act5.G2_AR_INVOICE_AMOUNT           = to_number(null),
             act5.G2_AR_CASH_APPLIED_AMOUNT      = to_number(null),
             act5.G2_AR_INVOICE_WRITEOFF_AMOUNT  = to_number(null),
             act5.G2_AR_CREDIT_MEMO_AMOUNT       = to_number(null),
             act5.G2_AR_UNAPPR_INVOICE_AMOUNT    = to_number(null),
             act5.G2_AR_APPR_INVOICE_AMOUNT      = to_number(null),
             act5.G2_AR_AMOUNT_DUE               = to_number(null),
             act5.G2_AR_AMOUNT_OVERDUE           = to_number(null)
      where  act5.PROJECT_ID in (select map.PROJECT_ID
                                 from   PJI_FM_PROJ_BATCH_MAP map
                                 where  map.WORKER_ID = p_worker_id) and
             not (nvl(act5.TXN_AR_INVOICE_AMOUNT          , 0) = 0 and
                  nvl(act5.TXN_AR_CASH_APPLIED_AMOUNT     , 0) = 0 and
                  nvl(act5.TXN_AR_INVOICE_WRITEOFF_AMOUNT , 0) = 0 and
                  nvl(act5.TXN_AR_CREDIT_MEMO_AMOUNT      , 0) = 0 and
                  nvl(act5.TXN_AR_UNAPPR_INVOICE_AMOUNT   , 0) = 0 and
                  nvl(act5.TXN_AR_APPR_INVOICE_AMOUNT     , 0) = 0 and
                  nvl(act5.TXN_AR_AMOUNT_DUE              , 0) = 0 and
                  nvl(act5.TXN_AR_AMOUNT_OVERDUE          , 0) = 0 and
                  nvl(act5.PRJ_AR_INVOICE_AMOUNT          , 0) = 0 and
                  nvl(act5.PRJ_AR_CASH_APPLIED_AMOUNT     , 0) = 0 and
                  nvl(act5.PRJ_AR_INVOICE_WRITEOFF_AMOUNT , 0) = 0 and
                  nvl(act5.PRJ_AR_CREDIT_MEMO_AMOUNT      , 0) = 0 and
                  nvl(act5.PRJ_AR_UNAPPR_INVOICE_AMOUNT   , 0) = 0 and
                  nvl(act5.PRJ_AR_APPR_INVOICE_AMOUNT     , 0) = 0 and
                  nvl(act5.PRJ_AR_AMOUNT_DUE              , 0) = 0 and
                  nvl(act5.PRJ_AR_AMOUNT_OVERDUE          , 0) = 0 and
                  nvl(act5.POU_AR_INVOICE_AMOUNT          , 0) = 0 and
                  nvl(act5.POU_AR_CASH_APPLIED_AMOUNT     , 0) = 0 and
                  nvl(act5.POU_AR_INVOICE_WRITEOFF_AMOUNT , 0) = 0 and
                  nvl(act5.POU_AR_CREDIT_MEMO_AMOUNT      , 0) = 0 and
                  nvl(act5.POU_AR_UNAPPR_INVOICE_AMOUNT   , 0) = 0 and
                  nvl(act5.POU_AR_APPR_INVOICE_AMOUNT     , 0) = 0 and
                  nvl(act5.POU_AR_AMOUNT_DUE              , 0) = 0 and
                  nvl(act5.POU_AR_AMOUNT_OVERDUE          , 0) = 0 and
                  nvl(act5.AR_INVOICE_COUNT               , 0) = 0 and
                  nvl(act5.AR_INVOICE_WRITEOFF_COUNT      , 0) = 0 and
                  nvl(act5.AR_CREDIT_MEMO_COUNT           , 0) = 0 and
                  nvl(act5.AR_UNAPPR_INVOICE_COUNT        , 0) = 0 and
                  nvl(act5.AR_APPR_INVOICE_COUNT          , 0) = 0 and
                  nvl(act5.AR_COUNT_DUE                   , 0) = 0 and
                  nvl(act5.AR_COUNT_OVERDUE               , 0) = 0 and
                  nvl(act5.G1_AR_INVOICE_AMOUNT           , 0) = 0 and
                  nvl(act5.G1_AR_CASH_APPLIED_AMOUNT      , 0) = 0 and
                  nvl(act5.G1_AR_INVOICE_WRITEOFF_AMOUNT  , 0) = 0 and
                  nvl(act5.G1_AR_CREDIT_MEMO_AMOUNT       , 0) = 0 and
                  nvl(act5.G1_AR_UNAPPR_INVOICE_AMOUNT    , 0) = 0 and
                  nvl(act5.G1_AR_APPR_INVOICE_AMOUNT      , 0) = 0 and
                  nvl(act5.G1_AR_AMOUNT_DUE               , 0) = 0 and
                  nvl(act5.G1_AR_AMOUNT_OVERDUE           , 0) = 0 and
                  nvl(act5.G2_AR_INVOICE_AMOUNT           , 0) = 0 and
                  nvl(act5.G2_AR_CASH_APPLIED_AMOUNT      , 0) = 0 and
                  nvl(act5.G2_AR_INVOICE_WRITEOFF_AMOUNT  , 0) = 0 and
                  nvl(act5.G2_AR_CREDIT_MEMO_AMOUNT       , 0) = 0 and
                  nvl(act5.G2_AR_UNAPPR_INVOICE_AMOUNT    , 0) = 0 and
                  nvl(act5.G2_AR_APPR_INVOICE_AMOUNT      , 0) = 0 and
                  nvl(act5.G2_AR_AMOUNT_DUE               , 0) = 0 and
                  nvl(act5.G2_AR_AMOUNT_OVERDUE           , 0) = 0);

      delete
      from   PJI_FM_AGGR_ACT5 act5
      where  act5.PROJECT_ID in (select map.PROJECT_ID
                                 from   PJI_FM_PROJ_BATCH_MAP map
                                 where  map.WORKER_ID = p_worker_id) and
             nvl(act5.TXN_REVENUE                    , 0) = 0 and
             nvl(act5.TXN_FUNDING                    , 0) = 0 and
             nvl(act5.TXN_INITIAL_FUNDING_AMOUNT     , 0) = 0 and
             nvl(act5.TXN_ADDITIONAL_FUNDING_AMOUNT  , 0) = 0 and
             nvl(act5.TXN_CANCELLED_FUNDING_AMOUNT   , 0) = 0 and
             nvl(act5.TXN_FUNDING_ADJUSTMENT_AMOUNT  , 0) = 0 and
             nvl(act5.TXN_REVENUE_WRITEOFF           , 0) = 0 and
             nvl(act5.TXN_AR_INVOICE_AMOUNT          , 0) = 0 and
             nvl(act5.TXN_AR_CASH_APPLIED_AMOUNT     , 0) = 0 and
             nvl(act5.TXN_AR_INVOICE_WRITEOFF_AMOUNT , 0) = 0 and
             nvl(act5.TXN_AR_CREDIT_MEMO_AMOUNT      , 0) = 0 and
             nvl(act5.TXN_UNBILLED_RECEIVABLES       , 0) = 0 and
             nvl(act5.TXN_UNEARNED_REVENUE           , 0) = 0 and
             nvl(act5.TXN_AR_UNAPPR_INVOICE_AMOUNT   , 0) = 0 and
             nvl(act5.TXN_AR_APPR_INVOICE_AMOUNT     , 0) = 0 and
             nvl(act5.TXN_AR_AMOUNT_DUE              , 0) = 0 and
             nvl(act5.TXN_AR_AMOUNT_OVERDUE          , 0) = 0 and
             nvl(act5.PRJ_REVENUE                    , 0) = 0 and
             nvl(act5.PRJ_FUNDING                    , 0) = 0 and
             nvl(act5.PRJ_INITIAL_FUNDING_AMOUNT     , 0) = 0 and
             nvl(act5.PRJ_ADDITIONAL_FUNDING_AMOUNT  , 0) = 0 and
             nvl(act5.PRJ_CANCELLED_FUNDING_AMOUNT   , 0) = 0 and
             nvl(act5.PRJ_FUNDING_ADJUSTMENT_AMOUNT  , 0) = 0 and
             nvl(act5.PRJ_REVENUE_WRITEOFF           , 0) = 0 and
             nvl(act5.PRJ_AR_INVOICE_AMOUNT          , 0) = 0 and
             nvl(act5.PRJ_AR_CASH_APPLIED_AMOUNT     , 0) = 0 and
             nvl(act5.PRJ_AR_INVOICE_WRITEOFF_AMOUNT , 0) = 0 and
             nvl(act5.PRJ_AR_CREDIT_MEMO_AMOUNT      , 0) = 0 and
             nvl(act5.PRJ_UNBILLED_RECEIVABLES       , 0) = 0 and
             nvl(act5.PRJ_UNEARNED_REVENUE           , 0) = 0 and
             nvl(act5.PRJ_AR_UNAPPR_INVOICE_AMOUNT   , 0) = 0 and
             nvl(act5.PRJ_AR_APPR_INVOICE_AMOUNT     , 0) = 0 and
             nvl(act5.PRJ_AR_AMOUNT_DUE              , 0) = 0 and
             nvl(act5.PRJ_AR_AMOUNT_OVERDUE          , 0) = 0 and
             nvl(act5.POU_REVENUE                    , 0) = 0 and
             nvl(act5.POU_FUNDING                    , 0) = 0 and
             nvl(act5.POU_INITIAL_FUNDING_AMOUNT     , 0) = 0 and
             nvl(act5.POU_ADDITIONAL_FUNDING_AMOUNT  , 0) = 0 and
             nvl(act5.POU_CANCELLED_FUNDING_AMOUNT   , 0) = 0 and
             nvl(act5.POU_FUNDING_ADJUSTMENT_AMOUNT  , 0) = 0 and
             nvl(act5.POU_REVENUE_WRITEOFF           , 0) = 0 and
             nvl(act5.POU_AR_INVOICE_AMOUNT          , 0) = 0 and
             nvl(act5.POU_AR_CASH_APPLIED_AMOUNT     , 0) = 0 and
             nvl(act5.POU_AR_INVOICE_WRITEOFF_AMOUNT , 0) = 0 and
             nvl(act5.POU_AR_CREDIT_MEMO_AMOUNT      , 0) = 0 and
             nvl(act5.POU_UNBILLED_RECEIVABLES       , 0) = 0 and
             nvl(act5.POU_UNEARNED_REVENUE           , 0) = 0 and
             nvl(act5.POU_AR_UNAPPR_INVOICE_AMOUNT   , 0) = 0 and
             nvl(act5.POU_AR_APPR_INVOICE_AMOUNT     , 0) = 0 and
             nvl(act5.POU_AR_AMOUNT_DUE              , 0) = 0 and
             nvl(act5.POU_AR_AMOUNT_OVERDUE          , 0) = 0 and
             nvl(act5.INITIAL_FUNDING_COUNT          , 0) = 0 and
             nvl(act5.ADDITIONAL_FUNDING_COUNT       , 0) = 0 and
             nvl(act5.CANCELLED_FUNDING_COUNT        , 0) = 0 and
             nvl(act5.FUNDING_ADJUSTMENT_COUNT       , 0) = 0 and
             nvl(act5.AR_INVOICE_COUNT               , 0) = 0 and
             nvl(act5.AR_CASH_APPLIED_COUNT          , 0) = 0 and
             nvl(act5.AR_INVOICE_WRITEOFF_COUNT      , 0) = 0 and
             nvl(act5.AR_CREDIT_MEMO_COUNT           , 0) = 0 and
             nvl(act5.AR_UNAPPR_INVOICE_COUNT        , 0) = 0 and
             nvl(act5.AR_APPR_INVOICE_COUNT          , 0) = 0 and
             nvl(act5.AR_COUNT_DUE                   , 0) = 0 and
             nvl(act5.AR_COUNT_OVERDUE               , 0) = 0 and
             nvl(act5.G1_REVENUE                     , 0) = 0 and
             nvl(act5.G1_FUNDING                     , 0) = 0 and
             nvl(act5.G1_INITIAL_FUNDING_AMOUNT      , 0) = 0 and
             nvl(act5.G1_ADDITIONAL_FUNDING_AMOUNT   , 0) = 0 and
             nvl(act5.G1_CANCELLED_FUNDING_AMOUNT    , 0) = 0 and
             nvl(act5.G1_FUNDING_ADJUSTMENT_AMOUNT   , 0) = 0 and
             nvl(act5.G1_REVENUE_WRITEOFF            , 0) = 0 and
             nvl(act5.G1_AR_INVOICE_AMOUNT           , 0) = 0 and
             nvl(act5.G1_AR_CASH_APPLIED_AMOUNT      , 0) = 0 and
             nvl(act5.G1_AR_INVOICE_WRITEOFF_AMOUNT  , 0) = 0 and
             nvl(act5.G1_AR_CREDIT_MEMO_AMOUNT       , 0) = 0 and
             nvl(act5.G1_UNBILLED_RECEIVABLES        , 0) = 0 and
             nvl(act5.G1_UNEARNED_REVENUE            , 0) = 0 and
             nvl(act5.G1_AR_UNAPPR_INVOICE_AMOUNT    , 0) = 0 and
             nvl(act5.G1_AR_APPR_INVOICE_AMOUNT      , 0) = 0 and
             nvl(act5.G1_AR_AMOUNT_DUE               , 0) = 0 and
             nvl(act5.G1_AR_AMOUNT_OVERDUE           , 0) = 0 and
             nvl(act5.G2_REVENUE                     , 0) = 0 and
             nvl(act5.G2_FUNDING                     , 0) = 0 and
             nvl(act5.G2_INITIAL_FUNDING_AMOUNT      , 0) = 0 and
             nvl(act5.G2_ADDITIONAL_FUNDING_AMOUNT   , 0) = 0 and
             nvl(act5.G2_CANCELLED_FUNDING_AMOUNT    , 0) = 0 and
             nvl(act5.G2_FUNDING_ADJUSTMENT_AMOUNT   , 0) = 0 and
             nvl(act5.G2_REVENUE_WRITEOFF            , 0) = 0 and
             nvl(act5.G2_AR_INVOICE_AMOUNT           , 0) = 0 and
             nvl(act5.G2_AR_CASH_APPLIED_AMOUNT      , 0) = 0 and
             nvl(act5.G2_AR_INVOICE_WRITEOFF_AMOUNT  , 0) = 0 and
             nvl(act5.G2_AR_CREDIT_MEMO_AMOUNT       , 0) = 0 and
             nvl(act5.G2_UNBILLED_RECEIVABLES        , 0) = 0 and
             nvl(act5.G2_UNEARNED_REVENUE            , 0) = 0 and
             nvl(act5.G2_AR_UNAPPR_INVOICE_AMOUNT    , 0) = 0 and
             nvl(act5.G2_AR_APPR_INVOICE_AMOUNT      , 0) = 0 and
             nvl(act5.G2_AR_AMOUNT_DUE               , 0) = 0 and
             nvl(act5.G2_AR_AMOUNT_OVERDUE           , 0) = 0;

    end if;

    insert into PJI_FM_AGGR_ACT5
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TIME_ID,
      CALENDAR_TYPE,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      TXN_CURRENCY_CODE,
      TXN_REVENUE,
      TXN_FUNDING,
      TXN_INITIAL_FUNDING_AMOUNT,
      TXN_ADDITIONAL_FUNDING_AMOUNT,
      TXN_CANCELLED_FUNDING_AMOUNT,
      TXN_FUNDING_ADJUSTMENT_AMOUNT,
      TXN_REVENUE_WRITEOFF,
      TXN_AR_INVOICE_AMOUNT,
      TXN_AR_CASH_APPLIED_AMOUNT,
      TXN_AR_INVOICE_WRITEOFF_AMOUNT,
      TXN_AR_CREDIT_MEMO_AMOUNT,
      TXN_UNBILLED_RECEIVABLES,
      TXN_UNEARNED_REVENUE,
      TXN_AR_UNAPPR_INVOICE_AMOUNT,
      TXN_AR_APPR_INVOICE_AMOUNT,
      TXN_AR_AMOUNT_DUE,
      TXN_AR_AMOUNT_OVERDUE,
      PRJ_REVENUE,
      PRJ_FUNDING,
      PRJ_INITIAL_FUNDING_AMOUNT,
      PRJ_ADDITIONAL_FUNDING_AMOUNT,
      PRJ_CANCELLED_FUNDING_AMOUNT,
      PRJ_FUNDING_ADJUSTMENT_AMOUNT,
      PRJ_REVENUE_WRITEOFF,
      PRJ_AR_INVOICE_AMOUNT,
      PRJ_AR_CASH_APPLIED_AMOUNT,
      PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
      PRJ_AR_CREDIT_MEMO_AMOUNT,
      PRJ_UNBILLED_RECEIVABLES,
      PRJ_UNEARNED_REVENUE,
      PRJ_AR_UNAPPR_INVOICE_AMOUNT,
      PRJ_AR_APPR_INVOICE_AMOUNT,
      PRJ_AR_AMOUNT_DUE,
      PRJ_AR_AMOUNT_OVERDUE,
      POU_REVENUE,
      POU_FUNDING,
      POU_INITIAL_FUNDING_AMOUNT,
      POU_ADDITIONAL_FUNDING_AMOUNT,
      POU_CANCELLED_FUNDING_AMOUNT,
      POU_FUNDING_ADJUSTMENT_AMOUNT,
      POU_REVENUE_WRITEOFF,
      POU_AR_INVOICE_AMOUNT,
      POU_AR_CASH_APPLIED_AMOUNT,
      POU_AR_INVOICE_WRITEOFF_AMOUNT,
      POU_AR_CREDIT_MEMO_AMOUNT,
      POU_UNBILLED_RECEIVABLES,
      POU_UNEARNED_REVENUE,
      POU_AR_UNAPPR_INVOICE_AMOUNT,
      POU_AR_APPR_INVOICE_AMOUNT,
      POU_AR_AMOUNT_DUE,
      POU_AR_AMOUNT_OVERDUE,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_COUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_COUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_COUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_COUNT,
      AR_COUNT_DUE,
      AR_COUNT_OVERDUE,
      G1_REVENUE,
      G1_FUNDING,
      G1_INITIAL_FUNDING_AMOUNT,
      G1_ADDITIONAL_FUNDING_AMOUNT,
      G1_CANCELLED_FUNDING_AMOUNT,
      G1_FUNDING_ADJUSTMENT_AMOUNT,
      G1_REVENUE_WRITEOFF,
      G1_AR_INVOICE_AMOUNT,
      G1_AR_CASH_APPLIED_AMOUNT,
      G1_AR_INVOICE_WRITEOFF_AMOUNT,
      G1_AR_CREDIT_MEMO_AMOUNT,
      G1_UNBILLED_RECEIVABLES,
      G1_UNEARNED_REVENUE,
      G1_AR_UNAPPR_INVOICE_AMOUNT,
      G1_AR_APPR_INVOICE_AMOUNT,
      G1_AR_AMOUNT_DUE,
      G1_AR_AMOUNT_OVERDUE,
      G2_REVENUE,
      G2_FUNDING,
      G2_INITIAL_FUNDING_AMOUNT,
      G2_ADDITIONAL_FUNDING_AMOUNT,
      G2_CANCELLED_FUNDING_AMOUNT,
      G2_FUNDING_ADJUSTMENT_AMOUNT,
      G2_REVENUE_WRITEOFF,
      G2_AR_INVOICE_AMOUNT,
      G2_AR_CASH_APPLIED_AMOUNT,
      G2_AR_INVOICE_WRITEOFF_AMOUNT,
      G2_AR_CREDIT_MEMO_AMOUNT,
      G2_UNBILLED_RECEIVABLES,
      G2_UNEARNED_REVENUE,
      G2_AR_UNAPPR_INVOICE_AMOUNT,
      G2_AR_APPR_INVOICE_AMOUNT,
      G2_AR_AMOUNT_DUE,
      G2_AR_AMOUNT_OVERDUE
    )
    select  /*+ ordered
                full(tmp2)   use_hash(tmp2)   parallel(tmp2)
                full(invert) use_hash(invert) swap_join_inputs(invert) */
      p_worker_id                               WORKER_ID,
      tmp2.PROJECT_ID,
      tmp2.PROJECT_ORG_ID,
      tmp2.PROJECT_ORGANIZATION_ID,
      decode(invert.INVERT_ID,
             'GL', tmp2.GL_TIME_ID,
             'PA', tmp2.PA_TIME_ID)             TIME_ID,
      decode(invert.INVERT_ID,
             'GL', 'C',
             'PA', 'P')                         CALENDAR_TYPE,
      tmp2.GL_CALENDAR_ID,
      tmp2.PA_CALENDAR_ID,
      null                                      TXN_CURRENCY_CODE,
      to_number(null)                           TXN_REVENUE,
      to_number(null)                           TXN_FUNDING,
      to_number(null)                           TXN_INITIAL_FUNDING_AMOUNT,
      to_number(null)                           TXN_ADDITIONAL_FUNDING_AMOUNT,
      to_number(null)                           TXN_CANCELLED_FUNDING_AMOUNT,
      to_number(null)                           TXN_FUNDING_ADJUSTMENT_AMOUNT,
      to_number(null)                           TXN_REVENUE_WRITEOFF,
      to_number(null)                           TXN_AR_INVOICE_AMOUNT,
      to_number(null)                           TXN_AR_CASH_APPLIED_AMOUNT,
      to_number(null)                           TXN_AR_INVOICE_WRITEOFF_AMOUNT,
      to_number(null)                           TXN_AR_CREDIT_MEMO_AMOUNT,
      to_number(null)                           TXN_UNBILLED_RECEIVABLES,
      to_number(null)                           TXN_UNEARNED_REVENUE,
      to_number(null)                           TXN_AR_UNAPPR_INVOICE_AMOUNT,
      to_number(null)                           TXN_AR_APPR_INVOICE_AMOUNT,
      to_number(null)                           TXN_AR_AMOUNT_DUE,
      to_number(null)                           TXN_AR_AMOUNT_OVERDUE,
      sum(tmp2.PRJ_REVENUE)                     PRJ_REVENUE,
      sum(tmp2.PRJ_FUNDING)                     PRJ_FUNDING,
      sum(tmp2.PRJ_INITIAL_FUNDING_AMOUNT)      PRJ_INITIAL_FUNDING_AMOUNT,
      sum(tmp2.PRJ_ADDITIONAL_FUNDING_AMOUNT)   PRJ_ADDITIONAL_FUNDING_AMOUNT,
      sum(tmp2.PRJ_CANCELLED_FUNDING_AMOUNT)    PRJ_CANCELLED_FUNDING_AMOUNT,
      sum(tmp2.PRJ_FUNDING_ADJUSTMENT_AMOUNT)   PRJ_FUNDING_ADJUSTMENT_AMOUNT,
      sum(tmp2.PRJ_REVENUE_WRITEOFF)            PRJ_REVENUE_WRITEOFF,
      sum(tmp2.PRJ_AR_INVOICE_AMOUNT)           PRJ_AR_INVOICE_AMOUNT,
      sum(tmp2.PRJ_AR_CASH_APPLIED_AMOUNT)      PRJ_AR_CASH_APPLIED_AMOUNT,
      sum(tmp2.PRJ_AR_INVOICE_WRITEOFF_AMOUNT)  PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
      sum(tmp2.PRJ_AR_CREDIT_MEMO_AMOUNT)       PRJ_AR_CREDIT_MEMO_AMOUNT,
      sum(tmp2.PRJ_UNBILLED_RECEIVABLES)        PRJ_UNBILLED_RECEIVABLES,
      sum(tmp2.PRJ_UNEARNED_REVENUE)            PRJ_UNEARNED_REVENUE,
      sum(tmp2.PRJ_AR_UNAPPR_INVOICE_AMOUNT)    PRJ_AR_UNAPPR_INVOICE_AMOUNT,
      sum(tmp2.PRJ_AR_APPR_INVOICE_AMOUNT)      PRJ_AR_APPR_INVOICE_AMOUNT,
      sum(tmp2.PRJ_AR_AMOUNT_DUE)               PRJ_AR_AMOUNT_DUE,
      sum(tmp2.PRJ_AR_AMOUNT_OVERDUE)           PRJ_AR_AMOUNT_OVERDUE,
      sum(tmp2.POU_REVENUE)                     POU_REVENUE,
      sum(tmp2.POU_FUNDING)                     POU_FUNDING,
      sum(tmp2.POU_INITIAL_FUNDING_AMOUNT)      POU_INITIAL_FUNDING_AMOUNT,
      sum(tmp2.POU_ADDITIONAL_FUNDING_AMOUNT)   POU_ADDITIONAL_FUNDING_AMOUNT,
      sum(tmp2.POU_CANCELLED_FUNDING_AMOUNT)    POU_CANCELLED_FUNDING_AMOUNT,
      sum(tmp2.POU_FUNDING_ADJUSTMENT_AMOUNT)   POU_FUNDING_ADJUSTMENT_AMOUNT,
      sum(tmp2.POU_REVENUE_WRITEOFF)            POU_REVENUE_WRITEOFF,
      sum(tmp2.POU_AR_INVOICE_AMOUNT)           POU_AR_INVOICE_AMOUNT,
      sum(tmp2.POU_AR_CASH_APPLIED_AMOUNT)      POU_AR_CASH_APPLIED_AMOUNT,
      sum(tmp2.POU_AR_INVOICE_WRITEOFF_AMOUNT)  POU_AR_INVOICE_WRITEOFF_AMOUNT,
      sum(tmp2.POU_AR_CREDIT_MEMO_AMOUNT)       POU_AR_CREDIT_MEMO_AMOUNT,
      sum(tmp2.POU_UNBILLED_RECEIVABLES)        POU_UNBILLED_RECEIVABLES,
      sum(tmp2.POU_UNEARNED_REVENUE)            POU_UNEARNED_REVENUE,
      sum(tmp2.POU_AR_UNAPPR_INVOICE_AMOUNT)    POU_AR_UNAPPR_INVOICE_AMOUNT,
      sum(tmp2.POU_AR_APPR_INVOICE_AMOUNT)      POU_AR_APPR_INVOICE_AMOUNT,
      sum(tmp2.POU_AR_AMOUNT_DUE)               POU_AR_AMOUNT_DUE,
      sum(tmp2.POU_AR_AMOUNT_OVERDUE)           POU_AR_AMOUNT_OVERDUE,
      sum(tmp2.INITIAL_FUNDING_COUNT)           INITIAL_FUNDING_COUNT,
      sum(tmp2.ADDITIONAL_FUNDING_COUNT)        ADDITIONAL_FUNDING_COUNT,
      sum(tmp2.CANCELLED_FUNDING_COUNT)         CANCELLED_FUNDING_COUNT,
      sum(tmp2.FUNDING_ADJUSTMENT_COUNT)        FUNDING_ADJUSTMENT_COUNT,
      sum(tmp2.AR_INVOICE_COUNT)                AR_INVOICE_COUNT,
      sum(tmp2.AR_CASH_APPLIED_COUNT)           AR_CASH_APPLIED_COUNT,
      sum(tmp2.AR_INVOICE_WRITEOFF_COUNT)       AR_INVOICE_WRITEOFF_COUNT,
      sum(tmp2.AR_CREDIT_MEMO_COUNT)            AR_CREDIT_MEMO_COUNT,
      sum(tmp2.AR_UNAPPR_INVOICE_COUNT)         AR_UNAPPR_INVOICE_COUNT,
      sum(tmp2.AR_APPR_INVOICE_COUNT)           AR_APPR_INVOICE_COUNT,
      sum(tmp2.AR_COUNT_DUE)                    AR_COUNT_DUE,
      sum(tmp2.AR_COUNT_OVERDUE)                AR_COUNT_OVERDUE,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_REVENUE,
                 'PA', tmp2.GP_REVENUE))        G1_REVENUE,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_FUNDING,
                 'PA', tmp2.GP_FUNDING))        G1_FUNDING,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_INITIAL_FUNDING_AMOUNT,
                 'PA', tmp2.GP_INITIAL_FUNDING_AMOUNT))
                                                G1_INITIAL_FUNDING_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_ADDITIONAL_FUNDING_AMOUNT,
                 'PA', tmp2.GP_ADDITIONAL_FUNDING_AMOUNT))
                                                G1_ADDITIONAL_FUNDING_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_CANCELLED_FUNDING_AMOUNT,
                 'PA', tmp2.GP_CANCELLED_FUNDING_AMOUNT))
                                                G1_CANCELLED_FUNDING_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_FUNDING_ADJUSTMENT_AMOUNT,
                 'PA', tmp2.GP_FUNDING_ADJUSTMENT_AMOUNT))
                                                G1_FUNDING_ADJUSTMENT_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_REVENUE_WRITEOFF,
                 'PA', tmp2.GP_REVENUE_WRITEOFF))
                                                G1_REVENUE_WRITEOFF,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_AR_INVOICE_AMOUNT,
                 'PA', tmp2.GP_AR_INVOICE_AMOUNT))
                                                G1_AR_INVOICE_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_AR_CASH_APPLIED_AMOUNT,
                 'PA', tmp2.GP_AR_CASH_APPLIED_AMOUNT))
                                                G1_AR_CASH_APPLIED_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_AR_INVOICE_WRITEOFF_AMOUNT,
                 'PA', tmp2.GP_AR_INVOICE_WRITEOFF_AMOUNT))
                                                G1_AR_INVOICE_WRITEOFF_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_AR_CREDIT_MEMO_AMOUNT,
                 'PA', tmp2.GP_AR_CREDIT_MEMO_AMOUNT))
                                                G1_AR_CREDIT_MEMO_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_UNBILLED_RECEIVABLES,
                 'PA', tmp2.GP_UNBILLED_RECEIVABLES))
                                                G1_UNBILLED_RECEIVABLES,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_UNEARNED_REVENUE,
                 'PA', tmp2.GP_UNEARNED_REVENUE))
                                                G1_UNEARNED_REVENUE,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_AR_UNAPPR_INVOICE_AMOUNT,
                 'PA', tmp2.GP_AR_UNAPPR_INVOICE_AMOUNT))
                                                G1_AR_UNAPPR_INVOICE_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_AR_APPR_INVOICE_AMOUNT,
                 'PA', tmp2.GP_AR_APPR_INVOICE_AMOUNT))
                                                G1_AR_APPR_INVOICE_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_AR_AMOUNT_DUE,
                 'PA', tmp2.GP_AR_AMOUNT_DUE))  G1_AR_AMOUNT_DUE,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG_AR_AMOUNT_OVERDUE,
                 'PA', tmp2.GP_AR_AMOUNT_OVERDUE))
                                                G1_AR_AMOUNT_OVERDUE,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_REVENUE,
                 'PA', tmp2.GP2_REVENUE))       G2_REVENUE,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_FUNDING,
                 'PA', tmp2.GP2_FUNDING))       G2_FUNDING,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_INITIAL_FUNDING_AMOUNT,
                 'PA', tmp2.GP2_INITIAL_FUNDING_AMOUNT))
                                                G2_INITIAL_FUNDING_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_ADDITIONAL_FUNDING_AMOUNT,
                 'PA', tmp2.GP2_ADDITIONAL_FUNDING_AMOUNT))
                                                G2_ADDITIONAL_FUNDING_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_CANCELLED_FUNDING_AMOUNT,
                 'PA', tmp2.GP2_CANCELLED_FUNDING_AMOUNT))
                                                G2_CANCELLED_FUNDING_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_FUNDING_ADJUSTMENT_AMOUNT,
                 'PA', tmp2.GP2_FUNDING_ADJUSTMENT_AMOUNT))
                                                G2_FUNDING_ADJUSTMENT_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_REVENUE_WRITEOFF,
                 'PA', tmp2.GP2_REVENUE_WRITEOFF))
                                                G2_REVENUE_WRITEOFF,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_AR_INVOICE_AMOUNT,
                 'PA', tmp2.GP2_AR_INVOICE_AMOUNT))
                                                G2_AR_INVOICE_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_AR_CASH_APPLIED_AMOUNT,
                 'PA', tmp2.GP2_AR_CASH_APPLIED_AMOUNT))
                                                G2_AR_CASH_APPLIED_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_AR_INVOICE_WRITEOFF_AMOUNT,
                 'PA', tmp2.GP2_AR_INVOICE_WRITEOFF_AMOUNT))
                                                G2_AR_INVOICE_WRITEOFF_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_AR_CREDIT_MEMO_AMOUNT,
                 'PA', tmp2.GP2_AR_CREDIT_MEMO_AMOUNT))
                                                G2_AR_CREDIT_MEMO_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_UNBILLED_RECEIVABLES,
                 'PA', tmp2.GP2_UNBILLED_RECEIVABLES))
                                                G2_UNBILLED_RECEIVABLES,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_UNEARNED_REVENUE,
                 'PA', tmp2.GP2_UNEARNED_REVENUE))
                                                G2_UNEARNED_REVENUE,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_AR_UNAPPR_INVOICE_AMOUNT,
                 'PA', tmp2.GP2_AR_UNAPPR_INVOICE_AMOUNT))
                                                G2_AR_UNAPPR_INVOICE_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_AR_APPR_INVOICE_AMOUNT,
                 'PA', tmp2.GP2_AR_APPR_INVOICE_AMOUNT))
                                                G2_AR_APPR_INVOICE_AMOUNT,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_AR_AMOUNT_DUE,
                 'PA', tmp2.GP2_AR_AMOUNT_DUE))
                                                G2_AR_AMOUNT_DUE,
      sum(decode(invert.INVERT_ID,
                 'GL', tmp2.GG2_AR_AMOUNT_OVERDUE,
                 'PA', tmp2.GP2_AR_AMOUNT_OVERDUE))
                                                G2_AR_AMOUNT_OVERDUE
    from
      (
        select 'GL' INVERT_ID from DUAL union all
        select 'PA' INVERT_ID from DUAL
      ) invert,
      PJI_FM_AGGR_ACT2 tmp2
    where
      tmp2.WORKER_ID = p_worker_id
    group by
      tmp2.PROJECT_ID,
      tmp2.PROJECT_ORG_ID,
      tmp2.PROJECT_ORGANIZATION_ID,
      decode(invert.INVERT_ID,
             'GL', tmp2.GL_TIME_ID,
             'PA', tmp2.PA_TIME_ID),
      decode(invert.INVERT_ID,
             'GL', 'C',
             'PA', 'P'),
      tmp2.GL_CALENDAR_ID,
      tmp2.PA_CALENDAR_ID,
      tmp2.TXN_CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.AGGREGATE_ACT_SLICES(p_worker_id);');

    -- truncate intermediate tables no longer required
    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_AGGR_ACT2' , 'NORMAL',null);

    commit;

  end AGGREGATE_ACT_SLICES;


  -- -----------------------------------------------------
  -- procedure FORCE_SUBSEQUENT_RUN
  -- -----------------------------------------------------
  procedure FORCE_SUBSEQUENT_RUN (p_worker_id in number) is

    l_worker_id                   number;
    l_process                     varchar2(30);
    l_extraction_type             varchar2(15);

    l_newline                     varchar2(10)   := '
';
    l_no_selection                varchar2(50);

    l_organization_tg             varchar2(40);
    l_include_sub_org_tg          varchar2(40);
    l_project_operating_unit_tg   varchar2(40);
    l_from_project_tg             varchar2(40);
    l_to_project_tg               varchar2(40);
    l_plan_type_tg                varchar2(40);

    l_organization_id             number;
    l_include_sub_org_flag        varchar2(50);
    l_operating_unit              number;
    l_from_project_num            varchar2(50);
    l_to_project_num              varchar2(50);
    l_plan_type_id                number;

    l_prtl_schedule               varchar2(1);
    l_organization                varchar2(50);
    l_include_sub_org             varchar2(50);
    l_prtl_financial              varchar2(1);
    l_project_operating_unit_name varchar2(240);
    l_from_project                varchar2(50);
    l_to_project                  varchar2(50);
    l_plan_type                   varchar2(200);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_EXTR.FORCE_SUBSEQUENT_RUN(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    if (l_extraction_type = 'PARTIAL') then
    null;
/* Temporary removal of stage 1 dependency on stage 2.  temptemp
      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_NO_SELECTION');

      l_no_selection := FND_MESSAGE.GET;

      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJI_SUM_FORCE_PRTL');

      PJI_UTILS.WRITE2OUT(l_newline       ||
                          l_newline       ||
                          FND_MESSAGE.GET ||
                          l_newline       ||
                          l_newline);

      -- -----------------------
      -- Stage 2 - RM Parameters
      -- -----------------------

      l_organization_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                           (PJI_FM_SUM_MAIN.g_process, 'ORGANIZATION_ID');

      if (nvl(l_organization_id, -1) = -1) then

        l_organization := l_no_selection;

      else

        select NAME
        into   l_organization
        from   HR_ALL_ORGANIZATION_UNITS
        where  ORGANIZATION_ID = l_organization_id;

      end if;

      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJI_SUM_ORGANIZATION');

      l_organization_tg := substr(FND_MESSAGE.GET, 1, 30);

     -- PJI_UTILS.WRITE2OUT(l_plan_type_tg              ||
     --                     PJI_FM_SUM_MAIN.my_pad(30 -
     --                                            length(l_organization_tg),
     --                                            ' ') ||
      --                    ': '                        ||
      --                    l_organization              ||
      --                    l_newline);

      l_include_sub_org_flag := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                                (PJI_FM_SUM_MAIN.g_process, 'INCLUDE_SUB_ORG');

      if (nvl(l_include_sub_org_flag, 'PJI$NULL') = 'PJI$NULL') then

        l_include_sub_org := l_no_selection;

      else

        l_include_sub_org := l_include_sub_org_flag;

      end if;

      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJI_SUM_INCLUDE_SUB_ORG');

      l_include_sub_org_tg := substr(FND_MESSAGE.GET, 1, 30);

   --   PJI_UTILS.WRITE2OUT(l_plan_type_tg              ||
    --                      PJI_FM_SUM_MAIN.my_pad(30 -
    --                                             length(l_include_sub_org_tg),
    --                                             ' ') ||
     --                     ': '                        ||
      --                    l_include_sub_org              ||
      --                    l_newline);

      -- -----------------------
      -- Stage 2 - FM Parameters
      -- -----------------------

     l_operating_unit := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                          (PJI_FM_SUM_MAIN.g_process,'PROJECT_OPERATING_UNIT');

      if (nvl(l_operating_unit, -1) = -1) then

        l_project_operating_unit_name := l_no_selection;

      else

        select NAME
        into   l_project_operating_unit_name
        from   HR_OPERATING_UNITS
        where  ORGANIZATION_ID = l_operating_unit;

      end if;

      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PRJ_OP_UNIT');

      l_project_operating_unit_tg := substr(FND_MESSAGE.GET, 1, 30);

      PJI_UTILS.WRITE2OUT(l_project_operating_unit_tg                 ||
                          PJI_FM_SUM_MAIN.my_pad(30 -
                            length(l_project_operating_unit_tg), ' ') ||
                          ': '                                        ||
                          l_project_operating_unit_name               ||
                          l_newline);

      l_from_project_num := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                           (PJI_FM_SUM_MAIN.g_process, 'FROM_PROJECT');

      if (nvl(l_from_project_num,'PJI$NULL') = 'PJI$NULL') then

        l_from_project := l_no_selection;

      else

        l_from_project := l_from_project_num;

      end if;

      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_FROM_PRJ');

      l_from_project_tg := substr(FND_MESSAGE.GET, 1, 30);

      PJI_UTILS.WRITE2OUT(l_from_project_tg           ||
                          PJI_FM_SUM_MAIN.my_pad(30-length(l_from_project_tg),
                                                 ' ') ||
                          ': '                        ||
                          l_from_project              ||
                          l_newline);

      l_to_project_num := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                          (PJI_FM_SUM_MAIN.g_process, 'TO_PROJECT');

      if (nvl(l_to_project_num, 'PJI$NULL') = 'PJI$NULL') then

        l_to_project := l_no_selection;

      else

        l_to_project := l_to_project_num;

      end if;

      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_TO_PRJ');

      l_to_project_tg := substr(FND_MESSAGE.GET, 1, 30);

      PJI_UTILS.WRITE2OUT(l_to_project_tg             ||
                          PJI_FM_SUM_MAIN.my_pad(30 - length(l_to_project_tg),
                                                 ' ') ||
                          ': '                        ||
                          l_to_project                ||
                          l_newline);

      l_plan_type_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                        (PJI_FM_SUM_MAIN.g_process, 'PLAN_TYPE_ID');

      if (nvl(l_plan_type_id, -1) = -1) then

        l_plan_type := l_no_selection;

      else

        select NAME
        into   l_plan_type
        from   PA_FIN_PLAN_TYPES_VL
        where  FIN_PLAN_TYPE_ID = l_plan_type_id;

      end if;

      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PLAN_TYPE');

      l_plan_type_tg := substr(FND_MESSAGE.GET, 1, 30);

      PJI_UTILS.WRITE2OUT(l_plan_type_tg              ||
                          PJI_FM_SUM_MAIN.my_pad(30 - length(l_plan_type_tg),
                                                 ' ') ||
                          ': '                        ||
                          l_plan_type                 ||
                          l_newline);

      commit;


      PJI_RM_SUM_MAIN.INIT_PROCESS('P',
                                   l_prtl_schedule,
                                   l_organization_id,
                                   l_include_sub_org,
                                   l_prtl_financial,
                                   l_operating_unit,
                                   l_from_project_num,
                                   l_to_project_num,
                                   l_plan_type_id);
*/

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_EXTR.FORCE_SUBSEQUENT_RUN(p_worker_id);');

    commit;

  end FORCE_SUBSEQUENT_RUN;


  -- -----------------------------------------------------
  -- procedure CLEANUP_WORKER
  -- -----------------------------------------------------
  procedure CLEANUP_WORKER (p_worker_id in number) is

    l_process varchar2(30);
    l_schema  varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    PJI_FM_DEBUG.CLEANUP_HOOK(l_process);

    PJI_FM_EXTR.CLEANUP(p_worker_id);
    PJI_FM_SUM_PSI.CLEANUP(p_worker_id);
    PJI_FM_SUM_ACT.CLEANUP(p_worker_id);

    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_AGGR_FIN1',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_AGGR_FIN2',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_AGGR_ACT1',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_AGGR_ACT2',
                                     'NORMAL',
                                     null);

    commit;

  end CLEANUP_WORKER;


  -- -----------------------------------------------------
  -- procedure WRAPUP_FAILURE
  -- -----------------------------------------------------
  procedure WRAPUP_FAILURE is

  begin

    rollback;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process, 'PROCESS_RUNNING', 'F');

    commit;

    pji_utils.write2log(sqlerrm, true, 0);

    commit;

  end WRAPUP_FAILURE;


  -- -----------------------------------------------------
  -- procedure WORKER
  -- -----------------------------------------------------
  procedure WORKER (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    PJI_FM_DEBUG.CONC_REQUEST_HOOK(l_process);

    PJI_EXTRACTION_UTIL.SEED_PJI_FM_STATS;

    PJI_PROCESS_UTIL.CLEAN_HELPER_BATCH_TABLE;

    PJI_FM_SUM_EXTR.POPULATE_TIME_DIMENSION(p_worker_id);
    PJI_EXTRACTION_UTIL.POPULATE_ORG_EXTR_INFO;

    PJI_FM_EXTR.EXTRACT_BATCH_DREV(p_worker_id);

    PJI_FM_EXTR.MARK_EXTRACTED_DREV_PRE(p_worker_id);
    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_FM_SUM_MAIN.g_process,
             'PJI_FM_EXTR.MARK_EXTRACTED_DREV(p_worker_id);',
             PJI_FM_SUM_MAIN.g_process_delay)) then
      return;
    end if;
    PJI_FM_EXTR.MARK_EXTRACTED_DREV_POST(p_worker_id);

    PJI_FM_EXTR.EXTRACT_BATCH_CDL_ROWIDS(p_worker_id);

    PJI_FM_EXTR.MARK_EXTRACTED_CDL_ROWS_PRE(p_worker_id);
    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_FM_SUM_MAIN.g_process,
             'PJI_FM_EXTR.MARK_EXTRACTED_CDL_ROWS(p_worker_id);',
             PJI_FM_SUM_MAIN.g_process_delay)) then
      return;
    end if;
    PJI_FM_EXTR.MARK_EXTRACTED_CDL_ROWS_POST(p_worker_id);

    PJI_FM_EXTR.EXTRACT_BATCH_CDL_CRDL_FULL(p_worker_id);
    PJI_FM_EXTR.EXTRACT_BATCH_ERDL_FULL(p_worker_id);
    PJI_FM_EXTR.EXTRACT_BATCH_CRDL_ROWIDS(p_worker_id);
    PJI_FM_EXTR.EXTRACT_BATCH_ERDL_ROWIDS(p_worker_id);
    PJI_FM_EXTR.EXTRACT_BATCH_CDL_AND_CRDL(p_worker_id);
    PJI_FM_EXTR.EXTRACT_BATCH_ERDL(p_worker_id);
    PJI_FM_EXTR.EXTRACT_BATCH_FND(p_worker_id);

    PJI_FM_EXTR.MARK_EXTRACTED_FND_ROWS_PRE(p_worker_id);
    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_FM_SUM_MAIN.g_process,
             'PJI_FM_EXTR.MARK_EXTRACTED_FND_ROWS(p_worker_id);',
             PJI_FM_SUM_MAIN.g_process_delay)) then
      return;
    end if;
    PJI_FM_EXTR.MARK_EXTRACTED_FND_ROWS_POST(p_worker_id);

    PJI_FM_EXTR.EXTRACT_BATCH_DINV(p_worker_id);
    PJI_FM_EXTR.MARK_EXTRACTED_DINV_ROWS(p_worker_id);
    PJI_FM_EXTR.EXTRACT_BATCH_DINVITEM(p_worker_id);
    PJI_FM_EXTR.EXTRACT_BATCH_ARINV(p_worker_id);

    PJI_FM_EXTR.MARK_FULLY_PAID_INVOICES_PRE(p_worker_id);
    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_FM_SUM_MAIN.g_process,
             'PJI_FM_EXTR.MARK_FULLY_PAID_INVOICES(p_worker_id);',
             PJI_FM_SUM_MAIN.g_process_delay)) then
      return;
    end if;
    PJI_FM_EXTR.MARK_FULLY_PAID_INVOICES_POST(p_worker_id);

    PJI_FM_SUM_ACT.BASE_SUMMARY(p_worker_id);

    PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT_PRE(p_worker_id);
    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_FM_SUM_MAIN.g_process,
             'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT(p_worker_id);',
             PJI_FM_SUM_MAIN.g_process_delay)) then
      return;
    end if;
    PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT_POST(p_worker_id);

    PJI_FM_SUM_EXTR.ORG_EXTR_INFO_TABLE(p_worker_id);
    PJI_FM_SUM_EXTR.CURR_CONV_TABLE(p_worker_id);

    PJI_FM_SUM_EXTR.DANGLING_FIN_ROWS(p_worker_id);
    PJI_FM_SUM_EXTR.DANGLING_ACT_ROWS(p_worker_id);
    PJI_FM_SUM_EXTR.PURGE_DANGLING_FIN_ROWS(p_worker_id);
    PJI_FM_SUM_EXTR.PURGE_DANGLING_ACT_ROWS(p_worker_id);

    PJI_FM_CMT_EXTR.FIN_CMT_SUMMARY(p_worker_id);

    PJI_FM_SUM_EXTR.FIN_SUMMARY(p_worker_id);
    PJI_FM_SUM_EXTR.MOVE_DANGLING_FIN_ROWS(p_worker_id);

    PJI_FM_SUM_EXTR.ACT_SUMMARY(p_worker_id);
    PJI_FM_SUM_EXTR.MOVE_DANGLING_ACT_ROWS(p_worker_id);

    PJI_FM_SUM_PSI.RESOURCE_LOOKUP_TABLE(p_worker_id);

    PJI_FM_SUM_PSI.PURGE_FP_BALANCES(p_worker_id);
    PJI_FM_SUM_PSI.PURGE_CMT_BALANCES(p_worker_id);
    PJI_FM_SUM_PSI.PURGE_AC_BALANCES(p_worker_id);

    PJI_FM_SUM_PSI.AGGREGATE_FPR_PERIODS(p_worker_id);
    PJI_FM_SUM_PSI.AGGREGATE_ACR_PERIODS(p_worker_id);

    PJI_FM_SUM_PSI.INSERT_NEW_HEADERS(p_worker_id);
    PJI_FM_SUM_PSI.BALANCES_INSERT(p_worker_id);
    PJI_FM_SUM_PSI.BALANCES_INCR_NEW_PRJ(p_worker_id);
    PJI_FM_SUM_PSI.BALANCES_INSERT_CMT(p_worker_id);
    PJI_FM_SUM_PSI.BALANCES_INCR_NEW_PRJ_CMT(p_worker_id);

    PJI_FM_SUM_PSI.FORCE_SUBSEQUENT_RUN(p_worker_id);

    PJI_FM_SUM_EXTR.AGGREGATE_RES_SLICES(p_worker_id);
    PJI_FM_SUM_EXTR.AGGREGATE_FIN_SLICES(p_worker_id);
    PJI_FM_SUM_EXTR.AGGREGATE_ACT_SLICES(p_worker_id);

    PJI_FM_SUM_EXTR.FORCE_SUBSEQUENT_RUN(p_worker_id);

    CLEANUP_WORKER(p_worker_id);

  end WORKER;


  -- -----------------------------------------------------
  -- procedure HELPER
  -- -----------------------------------------------------
  procedure HELPER
  (
    errbuf      out nocopy varchar2,
    retcode     out nocopy varchar2,
    p_worker_id  in        number
  ) is

    l_process varchar2(30);

  begin

    -- If this helper's concurrent request ID does not exist in the
    -- parameters table, the dispatcher must have kicked off a new
    -- helper.  Therefore do nothing.
    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process,
                                               PJI_FM_SUM_MAIN.g_process ||
                                               p_worker_id)
        <> FND_GLOBAL.CONC_REQUEST_ID) then
      pji_utils.write2log('Warning: Helper is already running.');
      commit;
      retcode := 0;
      return;
    end if;

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    PJI_FM_DEBUG.CONC_REQUEST_HOOK(l_process);

    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_FM_SUM_MAIN.g_process,
             'PJI_FM_EXTR.MARK_EXTRACTED_DREV_PRE(p_worker_id);',
             PJI_FM_SUM_MAIN.g_process_delay,
             'EVEN_IF_NOT_EXISTS')) then
      if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
          (PJI_FM_SUM_MAIN.g_process, 'PROCESS_RUNNING') = 'N') then
        null;
      else
        return;
      end if;
    end if;

    PJI_FM_EXTR.MARK_EXTRACTED_DREV(p_worker_id);

    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_FM_SUM_MAIN.g_process,
             'PJI_FM_EXTR.MARK_EXTRACTED_CDL_ROWS_PRE(p_worker_id);',
             PJI_FM_SUM_MAIN.g_process_delay)) then
      if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
          (PJI_FM_SUM_MAIN.g_process, 'PROCESS_RUNNING') = 'N') then
        null;
      else
        return;
      end if;
    end if;

    PJI_FM_EXTR.MARK_EXTRACTED_CDL_ROWS(p_worker_id);

    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_FM_SUM_MAIN.g_process,
             'PJI_FM_EXTR.MARK_EXTRACTED_FND_ROWS_PRE(p_worker_id);',
             PJI_FM_SUM_MAIN.g_process_delay)) then
      if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
          (PJI_FM_SUM_MAIN.g_process, 'PROCESS_RUNNING') = 'N') then
        null;
      else
        return;
      end if;
    end if;

    PJI_FM_EXTR.MARK_EXTRACTED_FND_ROWS(p_worker_id);

    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_FM_SUM_MAIN.g_process,
             'PJI_FM_EXTR.MARK_FULLY_PAID_INVOICES_PRE(p_worker_id);',
             PJI_FM_SUM_MAIN.g_process_delay)) then
      if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
          (PJI_FM_SUM_MAIN.g_process, 'PROCESS_RUNNING') = 'N') then
        null;
      else
        return;
      end if;
    end if;

    PJI_FM_EXTR.MARK_FULLY_PAID_INVOICES(p_worker_id);

    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_FM_SUM_MAIN.g_process,
             'PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT_PRE(p_worker_id);',
             PJI_FM_SUM_MAIN.g_process_delay)) then
      if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
          (PJI_FM_SUM_MAIN.g_process, 'PROCESS_RUNNING') = 'N') then
        null;
      else
        return;
      end if;
    end if;

    PJI_FM_CMT_EXTR.REFRESH_PROJPERF_CMT(p_worker_id);

    while (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
           (PJI_FM_SUM_MAIN.g_process, 'PROCESS_RUNNING') = 'Y') loop
      PJI_PROCESS_UTIL.SLEEP(PJI_FM_SUM_MAIN.g_process_delay);
    end loop;

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
        (PJI_FM_SUM_MAIN.g_process, 'PROCESS_RUNNING') = 'F') then
      return;
    end if;

    PJI_PROCESS_UTIL.WRAPUP_PROCESS(l_process);

    commit;

    retcode := 0;

    exception when others then

      WRAPUP_FAILURE;
      retcode := 2;
      errbuf := sqlerrm;

  end HELPER;


  -- -----------------------------------------------------
  -- procedure START_HELPER
  -- -----------------------------------------------------
  procedure START_HELPER (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(30);

  begin

    -- If a helper with this concurrent request ID is already running
    -- then we do not need to do anything.
    if (WORKER_STATUS(p_worker_id, 'RUNNING')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    -- Initialize status tables with worker details

    -- Note that adding a new step will do nothing if the step already
    -- exists.  Therefore, no state will be overwritten in the case of
    -- error recovery.

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    PJI_PROCESS_UTIL.ADD_STEPS(l_process, 'PJI_EXTR_HELPER', l_extraction_type);

    -- Kick off helper

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
    (
      PJI_FM_SUM_MAIN.g_process,
      l_process,
      FND_REQUEST.SUBMIT_REQUEST
      (
        PJI_UTILS.GET_PJI_SCHEMA_NAME,     -- Application name
        PJI_FM_SUM_MAIN.g_helper_name,     -- concurrent program name
        null,                              -- description (optional)
        null,                              -- Start Time  (optional)
        false,                             -- called from another conc. request
        p_worker_id                        -- first parameter
      )
    );

    if (nvl(to_number(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                      (PJI_FM_SUM_MAIN.g_process, l_process)), 0) = 0) then
        fnd_message.set_name('PJI', 'PJI_SUM_NO_SUB_REQ');
        dbms_standard.raise_application_error(-20030, fnd_message.get);
    end if;

    commit;

  end START_HELPER;


  -- -----------------------------------------------------
  -- function WORKER_STATUS
  -- -----------------------------------------------------
  function WORKER_STATUS (p_worker_id in number,
                          p_mode in varchar2) return boolean is

    l_process         varchar2(30);
    l_request_id      number;
    l_worker_name     varchar2(255);
    l_extraction_type varchar2(30);

  begin

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    if (p_worker_id = 1) then

      if (l_extraction_type = 'FULL') then
        l_worker_name := PJI_FM_SUM_MAIN.g_full_disp_name;
      elsif (l_extraction_type = 'INCREMENTAL') then
        l_worker_name := PJI_FM_SUM_MAIN.g_incr_disp_name;
      elsif (l_extraction_type = 'PARTIAL') then
        l_worker_name := PJI_FM_SUM_MAIN.g_prtl_disp_name;
      end if;

      l_request_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                      (PJI_FM_SUM_MAIN.g_process,
                       PJI_FM_SUM_MAIN.g_process);

    else

      l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

      l_worker_name := PJI_FM_SUM_MAIN.g_helper_name;

      l_request_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                      (PJI_FM_SUM_MAIN.g_process, l_process);

    end if;

    return PJI_PROCESS_UTIL.REQUEST_STATUS(p_mode,
                                           l_request_id,
                                           l_worker_name);

  end WORKER_STATUS;


  -- -----------------------------------------------------
  -- procedure WAIT_FOR_WORKER
  -- -----------------------------------------------------
  procedure WAIT_FOR_WORKER (p_worker_id in number) is

    l_process    varchar2(30);
    l_request_id number;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    l_request_id :=
    PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      PJI_FM_SUM_MAIN.g_process,
      l_process
    );

    PJI_PROCESS_UTIL.WAIT_FOR_REQUEST(l_request_id,
                                      PJI_FM_SUM_MAIN.g_process_delay);

  end WAIT_FOR_WORKER;

end PJI_FM_SUM_EXTR;

/
