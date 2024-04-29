--------------------------------------------------------
--  DDL for Package Body PJI_FM_SUM_ROLLUP_FIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_SUM_ROLLUP_FIN" as
  /* $Header: PJISF04B.pls 120.5 2006/04/18 20:07:45 appldev noship $ */

  -- -----------------------------------------------------
  -- procedure FIN_ROWID_TABLE
  -- -----------------------------------------------------
  procedure FIN_ROWID_TABLE (p_worker_id in number) is

    l_process   varchar2(30);
    l_schema    varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.FIN_ROWID_TABLE(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(fin_i) */ into PJI_PJI_RMAP_FIN fin_i
    (
      WORKER_ID,
      STG_ROWID
    )
    select
      p_worker_id                           WORKER_ID,
      fin9.ROWID                            STG_ROWID
    from
      PJI_PJI_PROJ_BATCH_MAP map,
      PJI_FM_AGGR_FIN9 fin9
    where
      map.WORKER_ID = p_worker_id and
      fin9.PROJECT_ID = map.PROJECT_ID;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.FIN_ROWID_TABLE(p_worker_id);');

    commit;

  end FIN_ROWID_TABLE;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_FIN_ET_WT_SLICES
  -- -----------------------------------------------------
  procedure AGGREGATE_FIN_ET_WT_SLICES (p_worker_id in number) is

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);

    l_txn_currency_flag varchar2(1);
    l_g2_currency_flag  varchar2(1);

    l_g1_currency_code  varchar2(30);
    l_g2_currency_code  varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.AGGREGATE_FIN_ET_WT_SLICES(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

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

    insert  /*+ append parallel(fin4_i) */ into PJI_FM_AGGR_FIN4 fin4_i
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
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      PERIOD_TYPE_ID,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      QUANTITY,
      BILL_QUANTITY
    )
    select
      src3.WORKER_ID,
      src3.PROJECT_ID,
      src3.PROJECT_ORGANIZATION_ID,
      src3.PROJECT_ORG_ID,
      src3.PROJECT_TYPE_CLASS,
      src3.WORK_TYPE_ID,
      src3.EXP_EVT_TYPE_ID,
      src3.TIME_ID,
      src3.CALENDAR_TYPE,
      src3.GL_CALENDAR_ID,
      src3.PA_CALENDAR_ID,
      sum(src3.CURR_RECORD_TYPE_ID)                   CURR_RECORD_TYPE_ID,
      nvl(src3.CURRENCY_CODE, 'PJI$NULL')             CURRENCY_CODE,
      src3.PERIOD_TYPE_ID,
      max(src3.REVENUE)                               REVENUE,
      max(src3.LABOR_REVENUE)                         LABOR_REVENUE,
      max(src3.RAW_COST)                              RAW_COST,
      max(src3.BURDENED_COST)                         BURDENED_COST,
      max(src3.BILL_RAW_COST)                         BILL_RAW_COST,
      max(src3.BILL_BURDENED_COST)                    BILL_BURDENED_COST,
      max(src3.LABOR_RAW_COST)                        LABOR_RAW_COST,
      max(src3.LABOR_BURDENED_COST)                   LABOR_BURDENED_COST,
      max(src3.BILL_LABOR_RAW_COST)                   BILL_LABOR_RAW_COST,
      max(src3.BILL_LABOR_BURDENED_COST)              BILL_LABOR_BURDENED_COST,
      max(src3.REVENUE_WRITEOFF)                      REVENUE_WRITEOFF,
      max(src3.LABOR_HRS)                             LABOR_HRS,
      max(src3.BILL_LABOR_HRS)                        BILL_LABOR_HRS,
      max(src3.QUANTITY)                              QUANTITY,
      max(src3.BILL_QUANTITY)                         BILL_QUANTITY
    from
      (
      select /*+ ordered */
        p_worker_id                                   WORKER_ID,
        src2.PROJECT_ID,
        src2.PROJECT_ORGANIZATION_ID,
        src2.PROJECT_ORG_ID,
        src2.PROJECT_TYPE_CLASS,
        src2.WORK_TYPE_ID,
        src2.EXP_EVT_TYPE_ID,
        src2.TIME_ID,
        src2.CALENDAR_TYPE,
        src2.GL_CALENDAR_ID,
        src2.PA_CALENDAR_ID,
        invert.INVERT_ID                              CURR_RECORD_TYPE_ID,
        decode(invert.INVERT_ID,
               1,   l_g1_currency_code,
               2,   l_g2_currency_code,
               4,   info.PF_CURRENCY_CODE,
               8,   prj.PROJECT_CURRENCY_CODE,
               16,  src2.TXN_CURRENCY_CODE,
               32,  l_g1_currency_code,
               64,  l_g2_currency_code,
               128, info.PF_CURRENCY_CODE,
               256, prj.PROJECT_CURRENCY_CODE)        DIFF_CURRENCY_CODE,
        src2.DIFF_ROWNUM                              DIFF_ROWNUM,
        decode(invert.INVERT_ID,
               1,   l_g1_currency_code,
               2,   l_g2_currency_code,
               4,   info.PF_CURRENCY_CODE,
               8,   prj.PROJECT_CURRENCY_CODE,
               16,  src2.TXN_CURRENCY_CODE,
               32,  src2.TXN_CURRENCY_CODE,
               64,  src2.TXN_CURRENCY_CODE,
               128, src2.TXN_CURRENCY_CODE,
               256, src2.TXN_CURRENCY_CODE)           CURRENCY_CODE,
        1                                             PERIOD_TYPE_ID,
        decode(invert.INVERT_ID,
               1,   src2.G1_REVENUE,
               2,   src2.G2_REVENUE,
               4,   src2.POU_REVENUE,
               8,   src2.PRJ_REVENUE,
               16,  src2.TXN_REVENUE,
               32,  src2.G1_REVENUE,
               64,  src2.G2_REVENUE,
               128, src2.POU_REVENUE,
               256, src2.PRJ_REVENUE)                 REVENUE,
        decode(invert.INVERT_ID,
               1,   src2.G1_LABOR_REVENUE,
               2,   src2.G2_LABOR_REVENUE,
               4,   src2.POU_LABOR_REVENUE,
               8,   src2.PRJ_LABOR_REVENUE,
               16,  src2.TXN_LABOR_REVENUE,
               32,  src2.G1_LABOR_REVENUE,
               64,  src2.G2_LABOR_REVENUE,
               128, src2.POU_LABOR_REVENUE,
               256, src2.PRJ_LABOR_REVENUE)           LABOR_REVENUE,
        decode(invert.INVERT_ID,
               1,   src2.G1_RAW_COST,
               2,   src2.G2_RAW_COST,
               4,   src2.POU_RAW_COST,
               8,   src2.PRJ_RAW_COST,
               16,  src2.TXN_RAW_COST,
               32,  src2.G1_RAW_COST,
               64,  src2.G2_RAW_COST,
               128, src2.POU_RAW_COST,
               256, src2.PRJ_RAW_COST)                RAW_COST,
        decode(invert.INVERT_ID,
               1,   src2.G1_BRDN_COST,
               2,   src2.G2_BRDN_COST,
               4,   src2.POU_BRDN_COST,
               8,   src2.PRJ_BRDN_COST,
               16,  src2.TXN_BRDN_COST,
               32,  src2.G1_BRDN_COST,
               64,  src2.G2_BRDN_COST,
               128, src2.POU_BRDN_COST,
               256, src2.PRJ_BRDN_COST)               BURDENED_COST,
        decode(invert.INVERT_ID,
               1,   src2.G1_BILL_RAW_COST,
               2,   src2.G2_BILL_RAW_COST,
               4,   src2.POU_BILL_RAW_COST,
               8,   src2.PRJ_BILL_RAW_COST,
               16,  src2.TXN_BILL_RAW_COST,
               32,  src2.G1_BILL_RAW_COST,
               64,  src2.G2_BILL_RAW_COST,
               128, src2.POU_BILL_RAW_COST,
               256, src2.PRJ_BILL_RAW_COST)           BILL_RAW_COST,
        decode(invert.INVERT_ID,
               1,   src2.G1_BILL_BRDN_COST,
               2,   src2.G2_BILL_BRDN_COST,
               4,   src2.POU_BILL_BRDN_COST,
               8,   src2.PRJ_BILL_BRDN_COST,
               16,  src2.TXN_BILL_BRDN_COST,
               32,  src2.G1_BILL_BRDN_COST,
               64,  src2.G2_BILL_BRDN_COST,
               128, src2.POU_BILL_BRDN_COST,
               256, src2.PRJ_BILL_BRDN_COST)          BILL_BURDENED_COST,
        decode(invert.INVERT_ID,
               1,   src2.G1_LABOR_RAW_COST,
               2,   src2.G2_LABOR_RAW_COST,
               4,   src2.POU_LABOR_RAW_COST,
               8,   src2.PRJ_LABOR_RAW_COST,
               16,  src2.TXN_LABOR_RAW_COST,
               32,  src2.G1_LABOR_RAW_COST,
               64,  src2.G2_LABOR_RAW_COST,
               128, src2.POU_LABOR_RAW_COST,
               256, src2.PRJ_LABOR_RAW_COST)          LABOR_RAW_COST,
        decode(invert.INVERT_ID,
               1,   src2.G1_LABOR_BRDN_COST,
               2,   src2.G2_LABOR_BRDN_COST,
               4,   src2.POU_LABOR_BRDN_COST,
               8,   src2.PRJ_LABOR_BRDN_COST,
               16,  src2.TXN_LABOR_BRDN_COST,
               32,  src2.G1_LABOR_BRDN_COST,
               64,  src2.G2_LABOR_BRDN_COST,
               128, src2.POU_LABOR_BRDN_COST,
               256, src2.PRJ_LABOR_BRDN_COST)         LABOR_BURDENED_COST,
        decode(invert.INVERT_ID,
               1,   src2.G1_BILL_LABOR_RAW_COST,
               2,   src2.G2_BILL_LABOR_RAW_COST,
               4,   src2.POU_BILL_LABOR_RAW_COST,
               8,   src2.PRJ_BILL_LABOR_RAW_COST,
               16,  src2.TXN_BILL_LABOR_RAW_COST,
               32,  src2.G1_BILL_LABOR_RAW_COST,
               64,  src2.G2_BILL_LABOR_RAW_COST,
               128, src2.POU_BILL_LABOR_RAW_COST,
               256, src2.PRJ_BILL_LABOR_RAW_COST)     BILL_LABOR_RAW_COST,
        decode(invert.INVERT_ID,
               1,   src2.G1_BILL_LABOR_BRDN_COST,
               2,   src2.G2_BILL_LABOR_BRDN_COST,
               4,   src2.POU_BILL_LABOR_BRDN_COST,
               8,   src2.PRJ_BILL_LABOR_BRDN_COST,
               16,  src2.TXN_BILL_LABOR_BRDN_COST,
               32,  src2.G1_BILL_LABOR_BRDN_COST,
               64,  src2.G2_BILL_LABOR_BRDN_COST,
               128, src2.POU_BILL_LABOR_BRDN_COST,
               256, src2.PRJ_BILL_LABOR_BRDN_COST)    BILL_LABOR_BURDENED_COST,
        decode(invert.INVERT_ID,
               1,   src2.G1_REVENUE_WRITEOFF,
               2,   src2.G2_REVENUE_WRITEOFF,
               4,   src2.POU_REVENUE_WRITEOFF,
               8,   src2.PRJ_REVENUE_WRITEOFF,
               16,  src2.TXN_REVENUE_WRITEOFF,
               32,  src2.G1_REVENUE_WRITEOFF,
               64,  src2.G2_REVENUE_WRITEOFF,
               128, src2.POU_REVENUE_WRITEOFF,
               256, src2.PRJ_REVENUE_WRITEOFF)        REVENUE_WRITEOFF,
        src2.LABOR_HRS,
        src2.BILL_LABOR_HRS,
        src2.QUANTITY,
        src2.BILL_QUANTITY
      from
        (
        select
          ROWNUM                                    DIFF_ROWNUM,
          src1.PROJECT_ID,
          src1.PROJECT_ORGANIZATION_ID,
          src1.PROJECT_ORG_ID,
          src1.PROJECT_TYPE_CLASS,
          src1.WORK_TYPE_ID,
          src1.EXP_EVT_TYPE_ID,
          src1.TIME_ID,
          src1.CALENDAR_TYPE,
          src1.GL_CALENDAR_ID,
          src1.PA_CALENDAR_ID,
          src1.TXN_CURRENCY_CODE,
          src1.TXN_REVENUE,
          src1.TXN_LABOR_REVENUE,
          src1.TXN_RAW_COST,
          src1.TXN_BRDN_COST,
          src1.TXN_BILL_RAW_COST,
          src1.TXN_BILL_BRDN_COST,
          src1.TXN_LABOR_RAW_COST,
          src1.TXN_LABOR_BRDN_COST,
          src1.TXN_BILL_LABOR_RAW_COST,
          src1.TXN_BILL_LABOR_BRDN_COST,
          src1.TXN_REVENUE_WRITEOFF,
          src1.PRJ_REVENUE,
          src1.PRJ_LABOR_REVENUE,
          src1.PRJ_RAW_COST,
          src1.PRJ_BRDN_COST,
          src1.PRJ_BILL_RAW_COST,
          src1.PRJ_BILL_BRDN_COST,
          src1.PRJ_LABOR_RAW_COST,
          src1.PRJ_LABOR_BRDN_COST,
          src1.PRJ_BILL_LABOR_RAW_COST,
          src1.PRJ_BILL_LABOR_BRDN_COST,
          src1.PRJ_REVENUE_WRITEOFF,
          src1.POU_REVENUE,
          src1.POU_LABOR_REVENUE,
          src1.POU_RAW_COST,
          src1.POU_BRDN_COST,
          src1.POU_BILL_RAW_COST,
          src1.POU_BILL_BRDN_COST,
          src1.POU_LABOR_RAW_COST,
          src1.POU_LABOR_BRDN_COST,
          src1.POU_BILL_LABOR_RAW_COST,
          src1.POU_BILL_LABOR_BRDN_COST,
          src1.POU_REVENUE_WRITEOFF,
          src1.EOU_REVENUE,
          src1.EOU_LABOR_REVENUE,
          src1.EOU_RAW_COST,
          src1.EOU_BRDN_COST,
          src1.EOU_BILL_RAW_COST,
          src1.EOU_BILL_BRDN_COST,
          src1.EOU_LABOR_RAW_COST,
          src1.EOU_LABOR_BRDN_COST,
          src1.EOU_BILL_LABOR_RAW_COST,
          src1.EOU_BILL_LABOR_BRDN_COST,
          src1.EOU_REVENUE_WRITEOFF,
          src1.G1_REVENUE,
          src1.G1_LABOR_REVENUE,
          src1.G1_RAW_COST,
          src1.G1_BRDN_COST,
          src1.G1_BILL_RAW_COST,
          src1.G1_BILL_BRDN_COST,
          src1.G1_LABOR_RAW_COST,
          src1.G1_LABOR_BRDN_COST,
          src1.G1_BILL_LABOR_RAW_COST,
          src1.G1_BILL_LABOR_BRDN_COST,
          src1.G1_REVENUE_WRITEOFF,
          src1.G2_REVENUE,
          src1.G2_LABOR_REVENUE,
          src1.G2_RAW_COST,
          src1.G2_BRDN_COST,
          src1.G2_BILL_RAW_COST,
          src1.G2_BILL_BRDN_COST,
          src1.G2_LABOR_RAW_COST,
          src1.G2_LABOR_BRDN_COST,
          src1.G2_BILL_LABOR_RAW_COST,
          src1.G2_BILL_LABOR_BRDN_COST,
          src1.G2_REVENUE_WRITEOFF,
          src1.LABOR_HRS,
          src1.BILL_LABOR_HRS,
          src1.QUANTITY,
          src1.BILL_QUANTITY
        from
          (
          select
            fin9.PROJECT_ID,
            nvl(map.NEW_PROJECT_ORGANIZATION_ID,
                fin9.PROJECT_ORGANIZATION_ID)       PROJECT_ORGANIZATION_ID,
            fin9.PROJECT_ORG_ID,
            fin9.PROJECT_TYPE_CLASS,
            fin9.WORK_TYPE_ID,
            fin9.EXP_EVT_TYPE_ID,
            fin9.TIME_ID,
            fin9.CALENDAR_TYPE,
            fin9.GL_CALENDAR_ID,
            fin9.PA_CALENDAR_ID,
            fin9.TXN_CURRENCY_CODE,
            sum(fin9.TXN_REVENUE)                   TXN_REVENUE,
            sum(fin9.TXN_LABOR_REVENUE)             TXN_LABOR_REVENUE,
            sum(fin9.TXN_RAW_COST)                  TXN_RAW_COST,
            sum(fin9.TXN_BRDN_COST)                 TXN_BRDN_COST,
            sum(fin9.TXN_BILL_RAW_COST)             TXN_BILL_RAW_COST,
            sum(fin9.TXN_BILL_BRDN_COST)            TXN_BILL_BRDN_COST,
            sum(fin9.TXN_LABOR_RAW_COST)            TXN_LABOR_RAW_COST,
            sum(fin9.TXN_LABOR_BRDN_COST)           TXN_LABOR_BRDN_COST,
            sum(fin9.TXN_BILL_LABOR_RAW_COST)       TXN_BILL_LABOR_RAW_COST,
            sum(fin9.TXN_BILL_LABOR_BRDN_COST)      TXN_BILL_LABOR_BRDN_COST,
            sum(fin9.TXN_REVENUE_WRITEOFF)          TXN_REVENUE_WRITEOFF,
            sum(fin9.PRJ_REVENUE)                   PRJ_REVENUE,
            sum(fin9.PRJ_LABOR_REVENUE)             PRJ_LABOR_REVENUE,
            sum(fin9.PRJ_RAW_COST)                  PRJ_RAW_COST,
            sum(fin9.PRJ_BRDN_COST)                 PRJ_BRDN_COST,
            sum(fin9.PRJ_BILL_RAW_COST)             PRJ_BILL_RAW_COST,
            sum(fin9.PRJ_BILL_BRDN_COST)            PRJ_BILL_BRDN_COST,
            sum(fin9.PRJ_LABOR_RAW_COST)            PRJ_LABOR_RAW_COST,
            sum(fin9.PRJ_LABOR_BRDN_COST)           PRJ_LABOR_BRDN_COST,
            sum(fin9.PRJ_BILL_LABOR_RAW_COST)       PRJ_BILL_LABOR_RAW_COST,
            sum(fin9.PRJ_BILL_LABOR_BRDN_COST)      PRJ_BILL_LABOR_BRDN_COST,
            sum(fin9.PRJ_REVENUE_WRITEOFF)          PRJ_REVENUE_WRITEOFF,
            sum(fin9.POU_REVENUE)                   POU_REVENUE,
            sum(fin9.POU_LABOR_REVENUE)             POU_LABOR_REVENUE,
            sum(fin9.POU_RAW_COST)                  POU_RAW_COST,
            sum(fin9.POU_BRDN_COST)                 POU_BRDN_COST,
            sum(fin9.POU_BILL_RAW_COST)             POU_BILL_RAW_COST,
            sum(fin9.POU_BILL_BRDN_COST)            POU_BILL_BRDN_COST,
            sum(fin9.POU_LABOR_RAW_COST)            POU_LABOR_RAW_COST,
            sum(fin9.POU_LABOR_BRDN_COST)           POU_LABOR_BRDN_COST,
            sum(fin9.POU_BILL_LABOR_RAW_COST)       POU_BILL_LABOR_RAW_COST,
            sum(fin9.POU_BILL_LABOR_BRDN_COST)      POU_BILL_LABOR_BRDN_COST,
            sum(fin9.POU_REVENUE_WRITEOFF)          POU_REVENUE_WRITEOFF,
            sum(fin9.EOU_REVENUE)                   EOU_REVENUE,
            sum(fin9.EOU_LABOR_REVENUE)             EOU_LABOR_REVENUE,
            sum(fin9.EOU_RAW_COST)                  EOU_RAW_COST,
            sum(fin9.EOU_BRDN_COST)                 EOU_BRDN_COST,
            sum(fin9.EOU_BILL_RAW_COST)             EOU_BILL_RAW_COST,
            sum(fin9.EOU_BILL_BRDN_COST)            EOU_BILL_BRDN_COST,
            sum(fin9.EOU_LABOR_RAW_COST)            EOU_LABOR_RAW_COST,
            sum(fin9.EOU_LABOR_BRDN_COST)           EOU_LABOR_BRDN_COST,
            sum(fin9.EOU_BILL_LABOR_RAW_COST)       EOU_BILL_LABOR_RAW_COST,
            sum(fin9.EOU_BILL_LABOR_BRDN_COST)      EOU_BILL_LABOR_BRDN_COST,
            sum(fin9.EOU_REVENUE_WRITEOFF)          EOU_REVENUE_WRITEOFF,
            sum(fin9.G1_REVENUE)                    G1_REVENUE,
            sum(fin9.G1_LABOR_REVENUE)              G1_LABOR_REVENUE,
            sum(fin9.G1_RAW_COST)                   G1_RAW_COST,
            sum(fin9.G1_BRDN_COST)                  G1_BRDN_COST,
            sum(fin9.G1_BILL_RAW_COST)              G1_BILL_RAW_COST,
            sum(fin9.G1_BILL_BRDN_COST)             G1_BILL_BRDN_COST,
            sum(fin9.G1_LABOR_RAW_COST)             G1_LABOR_RAW_COST,
            sum(fin9.G1_LABOR_BRDN_COST)            G1_LABOR_BRDN_COST,
            sum(fin9.G1_BILL_LABOR_RAW_COST)        G1_BILL_LABOR_RAW_COST,
            sum(fin9.G1_BILL_LABOR_BRDN_COST)       G1_BILL_LABOR_BRDN_COST,
            sum(fin9.G1_REVENUE_WRITEOFF)           G1_REVENUE_WRITEOFF,
            sum(fin9.G2_REVENUE)                    G2_REVENUE,
            sum(fin9.G2_LABOR_REVENUE)              G2_LABOR_REVENUE,
            sum(fin9.G2_RAW_COST)                   G2_RAW_COST,
            sum(fin9.G2_BRDN_COST)                  G2_BRDN_COST,
            sum(fin9.G2_BILL_RAW_COST)              G2_BILL_RAW_COST,
            sum(fin9.G2_BILL_BRDN_COST)             G2_BILL_BRDN_COST,
            sum(fin9.G2_LABOR_RAW_COST)             G2_LABOR_RAW_COST,
            sum(fin9.G2_LABOR_BRDN_COST)            G2_LABOR_BRDN_COST,
            sum(fin9.G2_BILL_LABOR_RAW_COST)        G2_BILL_LABOR_RAW_COST,
            sum(fin9.G2_BILL_LABOR_BRDN_COST)       G2_BILL_LABOR_BRDN_COST,
            sum(fin9.G2_REVENUE_WRITEOFF)           G2_REVENUE_WRITEOFF,
            sum(fin9.LABOR_HRS)                     LABOR_HRS,
            sum(fin9.BILL_LABOR_HRS)                BILL_LABOR_HRS,
            sum(fin9.QUANTITY)                      QUANTITY,
            sum(fin9.BILL_QUANTITY)                 BILL_QUANTITY
          from
            PJI_PJI_RMAP_FIN fin9_r,
            PJI_FM_AGGR_FIN9 fin9,
            (
            select
              map.PROJECT_ID,
              map.NEW_PROJECT_ORGANIZATION_ID
            from
              PJI_PJI_PROJ_BATCH_MAP map
            where
              map.NEW_PROJECT_ORGANIZATION_ID <> map.PROJECT_ORGANIZATION_ID
            ) map
          where
            fin9_r.WORKER_ID = p_worker_id and
            fin9.ROWID       = fin9_r. STG_ROWID and
            fin9.PROJECT_ID  = map.PROJECT_Id (+)
          group by
            fin9.PROJECT_ID,
            nvl(map.NEW_PROJECT_ORGANIZATION_ID,
                fin9.PROJECT_ORGANIZATION_ID),
            fin9.PROJECT_ORG_ID,
            fin9.PROJECT_TYPE_CLASS,
            fin9.WORK_TYPE_ID,
            fin9.EXP_EVT_TYPE_ID,
            fin9.TIME_ID,
            fin9.CALENDAR_TYPE,
            fin9.GL_CALENDAR_ID,
            fin9.PA_CALENDAR_ID,
            fin9.TXN_CURRENCY_CODE
          ) src1
        ) src2,
        PA_PROJECTS_ALL prj,
        PJI_ORG_EXTR_INFO info,
        (
          select 1   INVERT_ID from dual
                               where l_g1_currency_code is not null union all
          select 2   INVERT_ID from dual
                               where l_g2_currency_flag = 'Y' and
                                     l_g2_currency_code is not null union all
          select 4   INVERT_ID from dual union all
          select 8   INVERT_ID from dual
       -- select 16  INVERT_ID from dual  OMIT TXN CURRENCY FROM PJI
       --                      where l_txn_currency_flag = 'Y' union all
       -- select 32  INVERT_ID from dual  OMIT DETAIL SLICES FOR NOW
       --                      where l_g1_currency_code is not null union all
       -- select 64  INVERT_ID from dual
       --                      where l_g2_currency_flag = 'Y' and
       --                            l_g2_currency_code is not null union all
       -- select 128 INVERT_ID from dual union all
       -- select 256 INVERT_ID from dual
        ) invert
      where
        src2.PROJECT_ID              = prj.PROJECT_ID       and
        nvl(src2.PROJECT_ORG_ID, -1) = nvl(info.ORG_ID, -1)
      ) src3
    group by
      src3.WORKER_ID,
      src3.PROJECT_ID,
      src3.PROJECT_ORGANIZATION_ID,
      src3.PROJECT_ORG_ID,
      src3.PROJECT_TYPE_CLASS,
      src3.WORK_TYPE_ID,
      src3.EXP_EVT_TYPE_ID,
      src3.TIME_ID,
      src3.CALENDAR_TYPE,
      src3.GL_CALENDAR_ID,
      src3.PA_CALENDAR_ID,
      src3.DIFF_CURRENCY_CODE,
      src3.DIFF_ROWNUM,
      nvl(src3.CURRENCY_CODE, 'PJI$NULL'),
      src3.PERIOD_TYPE_ID;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.AGGREGATE_FIN_ET_WT_SLICES(p_worker_id);');

    commit;

  end AGGREGATE_FIN_ET_WT_SLICES;


  -- -----------------------------------------------------
  -- procedure PURGE_FIN_DATA
  -- -----------------------------------------------------
  procedure PURGE_FIN_DATA (p_worker_id in number) is

    l_process   varchar2(30);
    l_schema    varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.PURGE_FIN_DATA(p_worker_id);')) then
      return;
    end if;

    delete
    from   PJI_FM_AGGR_FIN9
    where  ROWID in (select STG_ROWID
                     from   PJI_PJI_RMAP_FIN
                     where  WORKER_ID = p_worker_id);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.PURGE_FIN_DATA(p_worker_id);');

    commit;

  end PURGE_FIN_DATA;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_FIN_ET_SLICES
  -- -----------------------------------------------------
  procedure AGGREGATE_FIN_ET_SLICES (p_worker_id in number) is

    l_process   varchar2(30);
    l_schema    varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.AGGREGATE_FIN_ET_SLICES(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(fin5_i) */ into PJI_FM_AGGR_FIN5 fin5_i
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      EXP_EVT_TYPE_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      QUANTITY,
      BILL_QUANTITY
    )
    select /*+ parallel(tmp4) */
      p_worker_id,
      tmp4.PROJECT_ID,
      tmp4.PROJECT_ORG_ID,
      tmp4.PROJECT_ORGANIZATION_ID,
      tmp4.PROJECT_TYPE_CLASS,
      tmp4.EXP_EVT_TYPE_ID,
      tmp4.TIME_ID,
      tmp4.PERIOD_TYPE_ID,
      tmp4.CALENDAR_TYPE,
      tmp4.GL_CALENDAR_ID,
      tmp4.PA_CALENDAR_ID,
      tmp4.CURR_RECORD_TYPE_ID,
      tmp4.CURRENCY_CODE,
      sum(tmp4.REVENUE),
      sum(tmp4.LABOR_REVENUE),
      sum(tmp4.RAW_COST),
      sum(tmp4.BURDENED_COST),
      sum(tmp4.BILL_RAW_COST),
      sum(tmp4.BILL_BURDENED_COST),
      sum(tmp4.LABOR_RAW_COST),
      sum(tmp4.LABOR_BURDENED_COST),
      sum(tmp4.BILL_LABOR_RAW_COST),
      sum(tmp4.BILL_LABOR_BURDENED_COST),
      sum(tmp4.REVENUE_WRITEOFF),
      sum(tmp4.LABOR_HRS),
      sum(tmp4.BILL_LABOR_HRS),
      sum(QUANTITY),
      sum(BILL_QUANTITY)
    from
      PJI_FM_AGGR_FIN4 tmp4
    where
      tmp4.WORKER_ID = p_worker_id
    group by
      tmp4.PROJECT_ID,
      tmp4.PROJECT_ORG_ID,
      tmp4.PROJECT_ORGANIZATION_ID,
      tmp4.PROJECT_TYPE_CLASS,
      tmp4.EXP_EVT_TYPE_ID,
      tmp4.TIME_ID,
      tmp4.PERIOD_TYPE_ID,
      tmp4.CALENDAR_TYPE,
      tmp4.GL_CALENDAR_ID,
      tmp4.PA_CALENDAR_ID,
      tmp4.CURR_RECORD_TYPE_ID,
      tmp4.CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.AGGREGATE_FIN_ET_SLICES(p_worker_id);');

    commit;

  end AGGREGATE_FIN_ET_SLICES;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_FIN_SLICES
  -- -----------------------------------------------------
  procedure AGGREGATE_FIN_SLICES (p_worker_id in number) is

    l_process   varchar2(30);
    l_schema    varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.AGGREGATE_FIN_SLICES(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(fin3_i) */ into PJI_FM_AGGR_FIN3 fin3_i
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      CURR_BGT_REVENUE,
      CURR_BGT_RAW_COST,
      CURR_BGT_BURDENED_COST,
      CURR_BGT_LABOR_HRS,
      ORIG_BGT_REVENUE,
      ORIG_BGT_RAW_COST,
      ORIG_BGT_BURDENED_COST,
      ORIG_BGT_LABOR_HRS,
      FORECAST_REVENUE,
      FORECAST_RAW_COST,
      FORECAST_BURDENED_COST,
      FORECAST_LABOR_HRS
    )
    select /*+ parallel(tmp5) */
      p_worker_id,
      tmp5.PROJECT_ID,
      tmp5.PROJECT_ORG_ID,
      tmp5.PROJECT_ORGANIZATION_ID,
      tmp5.PROJECT_TYPE_CLASS,
      tmp5.TIME_ID,
      tmp5.PERIOD_TYPE_ID,
      tmp5.CALENDAR_TYPE,
      tmp5.GL_CALENDAR_ID,
      tmp5.PA_CALENDAR_ID,
      tmp5.CURR_RECORD_TYPE_ID,
      tmp5.CURRENCY_CODE,
      sum(tmp5.REVENUE)                  REVENUE,
      sum(tmp5.LABOR_REVENUE)            LABOR_REVENUE,
      sum(tmp5.RAW_COST)                 RAW_COST,
      sum(tmp5.BURDENED_COST)            BURDENED_COST,
      sum(tmp5.BILL_RAW_COST)            BILL_RAW_COST,
      sum(tmp5.BILL_BURDENED_COST)       BILL_BURDENED_COST,
      sum(tmp5.LABOR_RAW_COST)           LABOR_RAW_COST,
      sum(tmp5.LABOR_BURDENED_COST)      LABOR_BURDENED_COST,
      sum(tmp5.BILL_LABOR_RAW_COST)      BILL_LABOR_RAW_COST,
      sum(tmp5.BILL_LABOR_BURDENED_COST) BILL_LABOR_BURDENED_COST,
      sum(tmp5.REVENUE_WRITEOFF)         REVENUE_WRITEOFF,
      sum(tmp5.LABOR_HRS)                LABOR_HRS,
      sum(tmp5.BILL_LABOR_HRS)           BILL_LABOR_HRS,
      to_number(null)                    CURR_BGT_REVENUE,
      to_number(null)                    CURR_BGT_RAW_COST,
      to_number(null)                    CURR_BGT_BURDENED_COST,
      to_number(null)                    CURR_BGT_LABOR_HRS,
      to_number(null)                    ORIG_BGT_REVENUE,
      to_number(null)                    ORIG_BGT_RAW_COST,
      to_number(null)                    ORIG_BGT_BURDENED_COST,
      to_number(null)                    ORIG_BGT_LABOR_HRS,
      to_number(null)                    FORECAST_REVENUE,
      to_number(null)                    FORECAST_RAW_COST,
      to_number(null)                    FORECAST_BURDENED_COST,
      to_number(null)                    FORECAST_LABOR_HRS
    from
      PJI_FM_AGGR_FIN5 tmp5
    where
      tmp5.WORKER_ID = p_worker_id
    group by
      tmp5.PROJECT_ID,
      tmp5.PROJECT_ORG_ID,
      tmp5.PROJECT_ORGANIZATION_ID,
      tmp5.PROJECT_TYPE_CLASS,
      tmp5.TIME_ID,
      tmp5.PERIOD_TYPE_ID,
      tmp5.CALENDAR_TYPE,
      tmp5.GL_CALENDAR_ID,
      tmp5.PA_CALENDAR_ID,
      tmp5.CURR_RECORD_TYPE_ID,
      tmp5.CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.AGGREGATE_FIN_SLICES(p_worker_id);');

    commit;

  end AGGREGATE_FIN_SLICES;


  -- -----------------------------------------------------
  -- procedure EXPAND_FPW_CAL_EN
  -- -----------------------------------------------------
  procedure EXPAND_FPW_CAL_EN (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPW_CAL_EN(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    insert /*+ append parallel(fin4_i) */ into PJI_FM_AGGR_FIN4 fin4_i -- in EXPAND_FPW_CAL_EN
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      EXP_EVT_TYPE_ID,
      WORK_TYPE_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      QUANTITY,
      BILL_QUANTITY
    )
    select /*+ ordered
               full(time) use_hash(time) swap_join_inputs(time)
               full(fin)  use_hash(fin)  parallel(fin) */
      p_worker_id                           WORKER_ID,
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      fin.WORK_TYPE_ID,
      case when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 0 and
                grouping(time.ENT_PERIOD_ID) = 0
           then time.ENT_PERIOD_ID
           when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 0 and
                grouping(time.ENT_PERIOD_ID) = 1
           then time.ENT_QTR_ID
           when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 1 and
                grouping(time.ENT_PERIOD_ID) = 1
           then time.ENT_YEAR_ID
           end                              TIME_ID,
      case when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 0 and
                grouping(time.ENT_PERIOD_ID) = 0
           then 32
           when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 0 and
                grouping(time.ENT_PERIOD_ID) = 1
           then 64
           when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 1 and
                grouping(time.ENT_PERIOD_ID) = 1
           then 128
           end                              PERIOD_TYPE_ID,
      'E'                                   CALENDAR_TYPE,
      bitand(fin.CURR_RECORD_TYPE_ID, 247)  CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE)                      REVENUE,
      sum(fin.LABOR_REVENUE)                LABOR_REVENUE,
      sum(fin.RAW_COST)                     RAW_COST,
      sum(fin.BURDENED_COST)                BURDENED_COST,
      sum(fin.BILL_RAW_COST)                BILL_RAW_COST,
      sum(fin.BILL_BURDENED_COST)           BILL_BURDENED_COST,
      sum(fin.LABOR_RAW_COST)               LABOR_RAW_COST,
      sum(fin.LABOR_BURDENED_COST)          LABOR_BURDENED_COST,
      sum(fin.BILL_LABOR_RAW_COST)          BILL_LABOR_RAW_COST,
      sum(fin.BILL_LABOR_BURDENED_COST)     BILL_LABOR_BURDENED_COST,
      sum(fin.REVENUE_WRITEOFF)             REVENUE_WRITEOFF,
      sum(fin.LABOR_HRS)                    LABOR_HRS,
      sum(fin.BILL_LABOR_HRS)               BILL_LABOR_HRS,
      sum(fin.QUANTITY)                     QUANTITY,
      sum(fin.BILL_QUANTITY)                BILL_QUANTITY
    from
      FII_TIME_DAY     time,
      PJI_FM_AGGR_FIN4 fin
    where
      fin.WORKER_ID           = p_worker_id   and
      fin.PERIOD_TYPE_ID      = 1             and
      fin.CALENDAR_TYPE       = 'C'           and
      fin.CURR_RECORD_TYPE_ID not in (8, 256) and
      fin.TIME_ID             = time.REPORT_DATE_JULIAN
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      fin.WORK_TYPE_ID,
      rollup (time.ENT_YEAR_ID,
              time.ENT_QTR_ID,
              time.ENT_PERIOD_ID),
      bitand(fin.CURR_RECORD_TYPE_ID, 247),
      fin.CURRENCY_CODE
    having
      not (grouping(time.ENT_YEAR_ID)   = 1 and
           grouping(time.ENT_QTR_ID)    = 1 and
           grouping(time.ENT_PERIOD_ID) = 1);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPW_CAL_EN(p_worker_id);');

    commit;

  end EXPAND_FPW_CAL_EN;


  -- -----------------------------------------------------
  -- procedure EXPAND_FPW_CAL_PA
  -- -----------------------------------------------------
  procedure EXPAND_FPW_CAL_PA (p_worker_id in number) is

    l_process   varchar2(30);

  begin

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process, 'PA_CALENDAR_FLAG') = 'N') then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPW_CAL_PA(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(fin4_i) */ into PJI_FM_AGGR_FIN4 fin4_i -- in EXPAND_FPW_CAL_PA
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      EXP_EVT_TYPE_ID,
      WORK_TYPE_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      QUANTITY,
      BILL_QUANTITY
    )
    select /*+ ordered
               full(time) use_hash(time) parallel(time) swap_join_inputs(time)
               full(fin)  use_hash(fin)  parallel(fin) */
      p_worker_id                           WORKER_ID,
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      fin.WORK_TYPE_ID,
      case when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 0
           then time.CAL_PERIOD_ID
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 1
           then time.CAL_QTR_ID
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 1 and
                grouping(time.CAL_PERIOD_ID) = 1
           then time.CAL_YEAR_ID
           end                              TIME_ID,
      case when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 0
           then 32
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 1
           then 64
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 1 and
                grouping(time.CAL_PERIOD_ID) = 1
           then 128
           end                              PERIOD_TYPE_ID,
      'P'                                   CALENDAR_TYPE,
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE)                      REVENUE,
      sum(fin.LABOR_REVENUE)                LABOR_REVENUE,
      sum(fin.RAW_COST)                     RAW_COST,
      sum(fin.BURDENED_COST)                BURDENED_COST,
      sum(fin.BILL_RAW_COST)                BILL_RAW_COST,
      sum(fin.BILL_BURDENED_COST)           BILL_BURDENED_COST,
      sum(fin.LABOR_RAW_COST)               LABOR_RAW_COST,
      sum(fin.LABOR_BURDENED_COST)          LABOR_BURDENED_COST,
      sum(fin.BILL_LABOR_RAW_COST)          BILL_LABOR_RAW_COST,
      sum(fin.BILL_LABOR_BURDENED_COST)     BILL_LABOR_BURDENED_COST,
      sum(fin.REVENUE_WRITEOFF)             REVENUE_WRITEOFF,
      sum(fin.LABOR_HRS)                    LABOR_HRS,
      sum(fin.BILL_LABOR_HRS)               BILL_LABOR_HRS,
      sum(fin.QUANTITY)                     QUANTITY,
      sum(fin.BILL_QUANTITY)                BILL_QUANTITY
    from
      FII_TIME_CAL_DAY_MV time,
      PJI_FM_AGGR_FIN4    fin
    where
      fin.WORKER_ID                      = p_worker_id        and
      fin.PERIOD_TYPE_ID                 = 1                  and
      fin.CALENDAR_TYPE                  = 'P'                and
      to_date(to_char(fin.TIME_ID), 'J') = time.REPORT_DATE   and
      fin.PA_CALENDAR_ID                 = time.CALENDAR_ID
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      fin.WORK_TYPE_ID,
      rollup (time.CAL_YEAR_ID,
              time.CAL_QTR_ID,
              time.CAL_PERIOD_ID),
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE
    having
      not (grouping(time.CAL_YEAR_ID)   = 1 and
           grouping(time.CAL_QTR_ID)    = 1 and
           grouping(time.CAL_PERIOD_ID) = 1);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPW_CAL_PA(p_worker_id);');

    commit;

  end EXPAND_FPW_CAL_PA;


  -- -----------------------------------------------------
  -- procedure EXPAND_FPW_CAL_GL
  -- -----------------------------------------------------
  procedure EXPAND_FPW_CAL_GL (p_worker_id in number) is

    l_process   varchar2(30);

  begin

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process, 'GL_CALENDAR_FLAG') = 'N') then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPW_CAL_GL(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(fin4_i) */ into PJI_FM_AGGR_FIN4 fin4_i -- in EXPAND_FPW_CAL_GL
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      EXP_EVT_TYPE_ID,
      WORK_TYPE_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      QUANTITY,
      BILL_QUANTITY
    )
    select /*+ ordered
               full(time) use_hash(time) parallel(time) swap_join_inputs(time)
               full(fin)  use_hash(fin)  parallel(fin) */
      p_worker_id                           WORKER_ID,
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      fin.WORK_TYPE_ID,
      case when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 0
           then time.CAL_PERIOD_ID
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 1
           then time.CAL_QTR_ID
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 1 and
                grouping(time.CAL_PERIOD_ID) = 1
           then time.CAL_YEAR_ID
           end                              TIME_ID,
      case when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 0
           then 32
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 1
           then 64
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 1 and
                grouping(time.CAL_PERIOD_ID) = 1
           then 128
           end                              PERIOD_TYPE_ID,
      'G'                                   CALENDAR_TYPE,
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE)                      REVENUE,
      sum(fin.LABOR_REVENUE)                LABOR_REVENUE,
      sum(fin.RAW_COST)                     RAW_COST,
      sum(fin.BURDENED_COST)                BURDENED_COST,
      sum(fin.BILL_RAW_COST)                BILL_RAW_COST,
      sum(fin.BILL_BURDENED_COST)           BILL_BURDENED_COST,
      sum(fin.LABOR_RAW_COST)               LABOR_RAW_COST,
      sum(fin.LABOR_BURDENED_COST)          LABOR_BURDENED_COST,
      sum(fin.BILL_LABOR_RAW_COST)          BILL_LABOR_RAW_COST,
      sum(fin.BILL_LABOR_BURDENED_COST)     BILL_LABOR_BURDENED_COST,
      sum(fin.REVENUE_WRITEOFF)             REVENUE_WRITEOFF,
      sum(fin.LABOR_HRS)                    LABOR_HRS,
      sum(fin.BILL_LABOR_HRS)               BILL_LABOR_HRS,
      sum(fin.QUANTITY)                     QUANTITY,
      sum(fin.BILL_QUANTITY)                BILL_QUANTITY
    from
      FII_TIME_CAL_DAY_MV time,
      PJI_FM_AGGR_FIN4    fin
    where
      fin.WORKER_ID                      = p_worker_id        and
      fin.PERIOD_TYPE_ID                 = 1                  and
      fin.CALENDAR_TYPE                  = 'C'                and
      to_date(to_char(fin.TIME_ID), 'J') = time.REPORT_DATE   and
      fin.GL_CALENDAR_ID                 = time.CALENDAR_ID
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      fin.WORK_TYPE_ID,
      rollup (time.CAL_YEAR_ID,
              time.CAL_QTR_ID,
              time.CAL_PERIOD_ID),
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE
    having
      not (grouping(time.CAL_YEAR_ID)   = 1 and
           grouping(time.CAL_QTR_ID)    = 1 and
           grouping(time.CAL_PERIOD_ID) = 1);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPW_CAL_GL(p_worker_id);');

    commit;

  end EXPAND_FPW_CAL_GL;


  -- -----------------------------------------------------
  -- procedure EXPAND_FPW_CAL_WK
  -- -----------------------------------------------------
  procedure EXPAND_FPW_CAL_WK (p_worker_id in number) is

    l_process   varchar2(30);
    l_schema    varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPW_CAL_WK(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(fin4_i) */ into PJI_FM_AGGR_FIN4 fin4_i -- in EXPAND_FPW_CAL_WK
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      EXP_EVT_TYPE_ID,
      WORK_TYPE_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      QUANTITY,
      BILL_QUANTITY
    )
    select /*+ ordered
               full(time) use_hash(time) swap_join_inputs(time)
               full(fin)  use_hash(fin)  parallel(fin) */
      p_worker_id                           WORKER_ID,
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      fin.WORK_TYPE_ID,
      time.WEEK_ID                          TIME_ID,
      16                                    PERIOD_TYPE_ID,
      'E'                                   CALENDAR_TYPE,
      bitand(fin.CURR_RECORD_TYPE_ID, 247)  CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE)                      REVENUE,
      sum(fin.LABOR_REVENUE)                LABOR_REVENUE,
      sum(fin.RAW_COST)                     RAW_COST,
      sum(fin.BURDENED_COST)                BURDENED_COST,
      sum(fin.BILL_RAW_COST)                BILL_RAW_COST,
      sum(fin.BILL_BURDENED_COST)           BILL_BURDENED_COST,
      sum(fin.LABOR_RAW_COST)               LABOR_RAW_COST,
      sum(fin.LABOR_BURDENED_COST)          LABOR_BURDENED_COST,
      sum(fin.BILL_LABOR_RAW_COST)          BILL_LABOR_RAW_COST,
      sum(fin.BILL_LABOR_BURDENED_COST)     BILL_LABOR_BURDENED_COST,
      sum(fin.REVENUE_WRITEOFF)             REVENUE_WRITEOFF,
      sum(fin.LABOR_HRS)                    LABOR_HRS,
      sum(fin.BILL_LABOR_HRS)               BILL_LABOR_HRS,
      sum(fin.QUANTITY)                     QUANTITY,
      sum(fin.BILL_QUANTITY)                BILL_QUANTITY
    from
      FII_TIME_DAY     time,
      PJI_FM_AGGR_FIN4 fin
    where
      fin.WORKER_ID           = p_worker_id   and
      fin.PERIOD_TYPE_ID      = 1             and
      fin.CALENDAR_TYPE       = 'C'           and
      fin.CURR_RECORD_TYPE_ID not in (8, 256) and
      fin.TIME_ID             = time.REPORT_DATE_JULIAN
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      fin.WORK_TYPE_ID,
      time.WEEK_ID,
      bitand(fin.CURR_RECORD_TYPE_ID, 247),
      fin.CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPW_CAL_WK(p_worker_id);');

    commit;

  end EXPAND_FPW_CAL_WK;


  -- -----------------------------------------------------
  -- procedure EXPAND_FPE_CAL_EN
  -- -----------------------------------------------------
  procedure EXPAND_FPE_CAL_EN (p_worker_id in number) is

    l_process   varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPE_CAL_EN(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(fin5_i) */ into PJI_FM_AGGR_FIN5 fin5_i -- in EXPAND_FPE_CAL_EN
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      EXP_EVT_TYPE_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      QUANTITY,
      BILL_QUANTITY
    )
    select /*+ ordered
               full(time) use_hash(time) swap_join_inputs(time)
               full(fin)  use_hash(fin)  parallel(fin)   */
      p_worker_id                           WORKER_ID,
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      case when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 0 and
                grouping(time.ENT_PERIOD_ID) = 0
           then time.ENT_PERIOD_ID
           when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 0 and
                grouping(time.ENT_PERIOD_ID) = 1
           then time.ENT_QTR_ID
           when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 1 and
                grouping(time.ENT_PERIOD_ID) = 1
           then time.ENT_YEAR_ID
           end                              TIME_ID,
      case when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 0 and
                grouping(time.ENT_PERIOD_ID) = 0
           then 32
           when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 0 and
                grouping(time.ENT_PERIOD_ID) = 1
           then 64
           when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 1 and
                grouping(time.ENT_PERIOD_ID) = 1
           then 128
           end                              PERIOD_TYPE_ID,
      'E'                                   CALENDAR_TYPE,
      bitand(fin.CURR_RECORD_TYPE_ID, 247)  CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE)                      REVENUE,
      sum(fin.LABOR_REVENUE)                LABOR_REVENUE,
      sum(fin.RAW_COST)                     RAW_COST,
      sum(fin.BURDENED_COST)                BURDENED_COST,
      sum(fin.BILL_RAW_COST)                BILL_RAW_COST,
      sum(fin.BILL_BURDENED_COST)           BILL_BURDENED_COST,
      sum(fin.LABOR_RAW_COST)               LABOR_RAW_COST,
      sum(fin.LABOR_BURDENED_COST)          LABOR_BURDENED_COST,
      sum(fin.BILL_LABOR_RAW_COST)          BILL_LABOR_RAW_COST,
      sum(fin.BILL_LABOR_BURDENED_COST)     BILL_LABOR_BURDENED_COST,
      sum(fin.REVENUE_WRITEOFF)             REVENUE_WRITEOFF,
      sum(fin.LABOR_HRS)                    LABOR_HRS,
      sum(fin.BILL_LABOR_HRS)               BILL_LABOR_HRS,
      sum(fin.QUANTITY)                     QUANTITY,
      sum(fin.BILL_QUANTITY)                BILL_QUANTITY
    from
      FII_TIME_DAY     time,
      PJI_FM_AGGR_FIN5 fin
    where
      fin.WORKER_ID           = p_worker_id   and
      fin.PERIOD_TYPE_ID      = 1             and
      fin.CALENDAR_TYPE       = 'C'           and
      fin.CURR_RECORD_TYPE_ID not in (8, 256) and
      fin.TIME_ID             = time.REPORT_DATE_JULIAN
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      rollup (time.ENT_YEAR_ID,
              time.ENT_QTR_ID,
              time.ENT_PERIOD_ID),
      bitand(fin.CURR_RECORD_TYPE_ID, 247),
      fin.CURRENCY_CODE
    having
      not (grouping(time.ENT_YEAR_ID)   = 1 and
           grouping(time.ENT_QTR_ID)    = 1 and
           grouping(time.ENT_PERIOD_ID) = 1);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPE_CAL_EN(p_worker_id);');

    commit;

  end EXPAND_FPE_CAL_EN;


  -- -----------------------------------------------------
  -- procedure EXPAND_FPE_CAL_PA
  -- -----------------------------------------------------
  procedure EXPAND_FPE_CAL_PA (p_worker_id in number) is

    l_process   varchar2(30);

  begin

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process, 'PA_CALENDAR_FLAG') = 'N') then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPE_CAL_PA(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(fin5_i) */ into PJI_FM_AGGR_FIN5 fin5_i -- in EXPAND_FPE_CAL_PA
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      EXP_EVT_TYPE_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      QUANTITY,
      BILL_QUANTITY
    )
    select /*+ ordered
               full(time) use_hash(time) parallel(time) swap_join_inputs(time)
               full(fin)  use_hash(fin)  parallel(fin) */
      p_worker_id                           WORKER_ID,
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      case when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 0
           then time.CAL_PERIOD_ID
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 1
           then time.CAL_QTR_ID
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 1 and
                grouping(time.CAL_PERIOD_ID) = 1
           then time.CAL_YEAR_ID
           end                              TIME_ID,
      case when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 0
           then 32
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 1
           then 64
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 1 and
                grouping(time.CAL_PERIOD_ID) = 1
           then 128
           end                              PERIOD_TYPE_ID,
      'P'                                   CALENDAR_TYPE,
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE)                      REVENUE,
      sum(fin.LABOR_REVENUE)                LABOR_REVENUE,
      sum(fin.RAW_COST)                     RAW_COST,
      sum(fin.BURDENED_COST)                BURDENED_COST,
      sum(fin.BILL_RAW_COST)                BILL_RAW_COST,
      sum(fin.BILL_BURDENED_COST)           BILL_BURDENED_COST,
      sum(fin.LABOR_RAW_COST)               LABOR_RAW_COST,
      sum(fin.LABOR_BURDENED_COST)          LABOR_BURDENED_COST,
      sum(fin.BILL_LABOR_RAW_COST)          BILL_LABOR_RAW_COST,
      sum(fin.BILL_LABOR_BURDENED_COST)     BILL_LABOR_BURDENED_COST,
      sum(fin.REVENUE_WRITEOFF)             REVENUE_WRITEOFF,
      sum(fin.LABOR_HRS)                    LABOR_HRS,
      sum(fin.BILL_LABOR_HRS)               BILL_LABOR_HRS,
      sum(fin.QUANTITY)                     QUANTITY,
      sum(fin.BILL_QUANTITY)                BILL_QUANTITY
    from
      FII_TIME_CAL_DAY_MV time,
      PJI_FM_AGGR_FIN5    fin
    where
      fin.WORKER_ID                      = p_worker_id        and
      fin.PERIOD_TYPE_ID                 = 1                  and
      fin.CALENDAR_TYPE                  = 'P'                and
      to_date(to_char(fin.TIME_ID), 'J') = time.REPORT_DATE   and
      fin.PA_CALENDAR_ID                 = time.CALENDAR_ID
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      rollup (time.CAL_YEAR_ID,
              time.CAL_QTR_ID,
              time.CAL_PERIOD_ID),
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE
    having
      not (grouping(time.CAL_YEAR_ID)   = 1 and
           grouping(time.CAL_QTR_ID)    = 1 and
           grouping(time.CAL_PERIOD_ID) = 1);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPE_CAL_PA(p_worker_id);');

    commit;

  end EXPAND_FPE_CAL_PA;


  -- -----------------------------------------------------
  -- procedure EXPAND_FPE_CAL_GL
  -- -----------------------------------------------------
  procedure EXPAND_FPE_CAL_GL (p_worker_id in number) is

    l_process   varchar2(30);

  begin

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process, 'GL_CALENDAR_FLAG') = 'N') then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPE_CAL_GL(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(fin5_i) */ into PJI_FM_AGGR_FIN5 fin5_i -- in EXPAND_FPE_CAL_GL
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      EXP_EVT_TYPE_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      QUANTITY,
      BILL_QUANTITY
    )
    select /*+ ordered
               full(time) use_hash(time) parallel(time) swap_join_inputs(time)
               full(fin)  use_hash(fin)  parallel(fin) */
      p_worker_id                           WORKER_ID,
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      case when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 0
           then time.CAL_PERIOD_ID
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 1
           then time.CAL_QTR_ID
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 1 and
                grouping(time.CAL_PERIOD_ID) = 1
           then time.CAL_YEAR_ID
           end                              TIME_ID,
      case when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 0
           then 32
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 1
           then 64
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 1 and
                grouping(time.CAL_PERIOD_ID) = 1
           then 128
           end                              PERIOD_TYPE_ID,
      'G'                                   CALENDAR_TYPE,
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE)                      REVENUE,
      sum(fin.LABOR_REVENUE)                LABOR_REVENUE,
      sum(fin.RAW_COST)                     RAW_COST,
      sum(fin.BURDENED_COST)                BURDENED_COST,
      sum(fin.BILL_RAW_COST)                BILL_RAW_COST,
      sum(fin.BILL_BURDENED_COST)           BILL_BURDENED_COST,
      sum(fin.LABOR_RAW_COST)               LABOR_RAW_COST,
      sum(fin.LABOR_BURDENED_COST)          LABOR_BURDENED_COST,
      sum(fin.BILL_LABOR_RAW_COST)          BILL_LABOR_RAW_COST,
      sum(fin.BILL_LABOR_BURDENED_COST)     BILL_LABOR_BURDENED_COST,
      sum(fin.REVENUE_WRITEOFF)             REVENUE_WRITEOFF,
      sum(fin.LABOR_HRS)                    LABOR_HRS,
      sum(fin.BILL_LABOR_HRS)               BILL_LABOR_HRS,
      sum(fin.QUANTITY)                     QUANTITY,
      sum(fin.BILL_QUANTITY)                BILL_QUANTITY
    from
      FII_TIME_CAL_DAY_MV time,
      PJI_FM_AGGR_FIN5    fin
    where
      fin.WORKER_ID                      = p_worker_id        and
      fin.PERIOD_TYPE_ID                 = 1                  and
      fin.CALENDAR_TYPE                  = 'C'                and
      to_date(to_char(fin.TIME_ID), 'J') = time.REPORT_DATE   and
      fin.GL_CALENDAR_ID                 = time.CALENDAR_ID
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      rollup (time.CAL_YEAR_ID,
              time.CAL_QTR_ID,
              time.CAL_PERIOD_ID),
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE
    having
      not (grouping(time.CAL_YEAR_ID)   = 1 and
           grouping(time.CAL_QTR_ID)    = 1 and
           grouping(time.CAL_PERIOD_ID) = 1);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPE_CAL_GL(p_worker_id);');

    commit;

  end EXPAND_FPE_CAL_GL;


  -- -----------------------------------------------------
  -- procedure EXPAND_FPE_CAL_WK
  -- -----------------------------------------------------
  procedure EXPAND_FPE_CAL_WK (p_worker_id in number) is

    l_process   varchar2(30);
    l_schema    varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPE_CAL_WK(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(fin5_i) */ into PJI_FM_AGGR_FIN5 fin5_i -- in EXPAND_FPE_CAL_WK
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      EXP_EVT_TYPE_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      QUANTITY,
      BILL_QUANTITY
    )
    select /*+ ordered
               full(time) use_hash(time) swap_join_inputs(time)
               full(fin)  use_hash(fin)  parallel(fin) */
      p_worker_id                           WORKER_ID,
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      time.WEEK_ID                          TIME_ID,
      16                                    PERIOD_TYPE_ID,
      'E'                                   CALENDAR_TYPE,
      bitand(fin.CURR_RECORD_TYPE_ID, 247)  CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE)                      REVENUE,
      sum(fin.LABOR_REVENUE)                LABOR_REVENUE,
      sum(fin.RAW_COST)                     RAW_COST,
      sum(fin.BURDENED_COST)                BURDENED_COST,
      sum(fin.BILL_RAW_COST)                BILL_RAW_COST,
      sum(fin.BILL_BURDENED_COST)           BILL_BURDENED_COST,
      sum(fin.LABOR_RAW_COST)               LABOR_RAW_COST,
      sum(fin.LABOR_BURDENED_COST)          LABOR_BURDENED_COST,
      sum(fin.BILL_LABOR_RAW_COST)          BILL_LABOR_RAW_COST,
      sum(fin.BILL_LABOR_BURDENED_COST)     BILL_LABOR_BURDENED_COST,
      sum(fin.REVENUE_WRITEOFF)             REVENUE_WRITEOFF,
      sum(fin.LABOR_HRS)                    LABOR_HRS,
      sum(fin.BILL_LABOR_HRS)               BILL_LABOR_HRS,
      sum(fin.QUANTITY)                     QUANTITY,
      sum(fin.BILL_QUANTITY)                BILL_QUANTITY
    from
      FII_TIME_DAY     time,
      PJI_FM_AGGR_FIN5 fin
    where
      fin.WORKER_ID           = p_worker_id   and
      fin.PERIOD_TYPE_ID      = 1             and
      fin.CALENDAR_TYPE       = 'C'           and
      fin.CURR_RECORD_TYPE_ID not in (8, 256) and
      fin.TIME_ID             = time.REPORT_DATE_JULIAN
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.EXP_EVT_TYPE_ID,
      time.WEEK_ID,
      bitand(fin.CURR_RECORD_TYPE_ID, 247),
      fin.CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPE_CAL_WK(p_worker_id);');

    commit;

  end EXPAND_FPE_CAL_WK;


  -- -----------------------------------------------------
  -- procedure EXPAND_FPP_CAL_EN
  -- -----------------------------------------------------
  procedure EXPAND_FPP_CAL_EN (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPP_CAL_EN(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    insert /*+ append parallel(fin3_i) */ into PJI_FM_AGGR_FIN3 fin3_i -- in EXPAND_FPP_CAL_EN
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      CURR_BGT_REVENUE,
      CURR_BGT_RAW_COST,
      CURR_BGT_BURDENED_COST,
      CURR_BGT_LABOR_HRS,
      ORIG_BGT_REVENUE,
      ORIG_BGT_RAW_COST,
      ORIG_BGT_BURDENED_COST,
      ORIG_BGT_LABOR_HRS,
      FORECAST_REVENUE,
      FORECAST_RAW_COST,
      FORECAST_BURDENED_COST,
      FORECAST_LABOR_HRS
    )
    select
      p_worker_id,
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.TIME_ID,
      fin.PERIOD_TYPE_ID,
      fin.CALENDAR_TYPE,
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE),
      sum(fin.LABOR_REVENUE),
      sum(fin.RAW_COST),
      sum(fin.BURDENED_COST),
      sum(fin.BILL_RAW_COST),
      sum(fin.BILL_BURDENED_COST),
      sum(fin.LABOR_RAW_COST),
      sum(fin.LABOR_BURDENED_COST),
      sum(fin.BILL_LABOR_RAW_COST),
      sum(fin.BILL_LABOR_BURDENED_COST),
      sum(fin.REVENUE_WRITEOFF),
      sum(fin.LABOR_HRS),
      sum(fin.BILL_LABOR_HRS),
      sum(fin.CURR_BGT_REVENUE),
      sum(fin.CURR_BGT_RAW_COST),
      sum(fin.CURR_BGT_BURDENED_COST),
      sum(fin.CURR_BGT_LABOR_HRS),
      sum(fin.ORIG_BGT_REVENUE),
      sum(fin.ORIG_BGT_RAW_COST),
      sum(fin.ORIG_BGT_BURDENED_COST),
      sum(fin.ORIG_BGT_LABOR_HRS),
      sum(fin.FORECAST_REVENUE),
      sum(fin.FORECAST_RAW_COST),
      sum(fin.FORECAST_BURDENED_COST),
      sum(fin.FORECAST_LABOR_HRS)
    from
    (
    select /*+ ordered
               full(time) use_hash(time) swap_join_inputs(time)
               full(fin)  use_hash(fin)  parallel(fin) */
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      case when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 0 and
                grouping(time.ENT_PERIOD_ID) = 0
           then time.ENT_PERIOD_ID
           when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 0 and
                grouping(time.ENT_PERIOD_ID) = 1
           then time.ENT_QTR_ID
           when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 1 and
                grouping(time.ENT_PERIOD_ID) = 1
           then time.ENT_YEAR_ID
           end                              TIME_ID,
      case when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 0 and
                grouping(time.ENT_PERIOD_ID) = 0
           then 32
           when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 0 and
                grouping(time.ENT_PERIOD_ID) = 1
           then 64
           when grouping(time.ENT_YEAR_ID)   = 0 and
                grouping(time.ENT_QTR_ID)    = 1 and
                grouping(time.ENT_PERIOD_ID) = 1
           then 128
           end                              PERIOD_TYPE_ID,
      'E'                                   CALENDAR_TYPE,
      bitand(fin.CURR_RECORD_TYPE_ID, 247)  CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE)                      REVENUE,
      sum(fin.LABOR_REVENUE)                LABOR_REVENUE,
      sum(fin.RAW_COST)                     RAW_COST,
      sum(fin.BURDENED_COST)                BURDENED_COST,
      sum(fin.BILL_RAW_COST)                BILL_RAW_COST,
      sum(fin.BILL_BURDENED_COST)           BILL_BURDENED_COST,
      sum(fin.LABOR_RAW_COST)               LABOR_RAW_COST,
      sum(fin.LABOR_BURDENED_COST)          LABOR_BURDENED_COST,
      sum(fin.BILL_LABOR_RAW_COST)          BILL_LABOR_RAW_COST,
      sum(fin.BILL_LABOR_BURDENED_COST)     BILL_LABOR_BURDENED_COST,
      sum(fin.REVENUE_WRITEOFF)             REVENUE_WRITEOFF,
      sum(fin.LABOR_HRS)                    LABOR_HRS,
      sum(fin.BILL_LABOR_HRS)               BILL_LABOR_HRS,
      to_number(null)                       CURR_BGT_REVENUE,
      to_number(null)                       CURR_BGT_RAW_COST,
      to_number(null)                       CURR_BGT_BURDENED_COST,
      to_number(null)                       CURR_BGT_LABOR_HRS,
      to_number(null)                       ORIG_BGT_REVENUE,
      to_number(null)                       ORIG_BGT_RAW_COST,
      to_number(null)                       ORIG_BGT_BURDENED_COST,
      to_number(null)                       ORIG_BGT_LABOR_HRS,
      to_number(null)                       FORECAST_REVENUE,
      to_number(null)                       FORECAST_RAW_COST,
      to_number(null)                       FORECAST_BURDENED_COST,
      to_number(null)                       FORECAST_LABOR_HRS
    from
      FII_TIME_DAY     time,
      PJI_FM_AGGR_FIN3 fin
    where
      fin.WORKER_ID           = p_worker_id   and
      fin.PERIOD_TYPE_ID      = 1             and
      fin.CALENDAR_TYPE       = 'C'           and
      fin.CURR_RECORD_TYPE_ID not in (8, 256) and
      fin.TIME_ID             = time.REPORT_DATE_JULIAN
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      rollup (time.ENT_YEAR_ID,
              time.ENT_QTR_ID,
              time.ENT_PERIOD_ID),
      bitand(fin.CURR_RECORD_TYPE_ID, 247),
      fin.CURRENCY_CODE
    having
      not (grouping(time.ENT_YEAR_ID)   = 1 and
           grouping(time.ENT_QTR_ID)    = 1 and
           grouping(time.ENT_PERIOD_ID) = 1)
    union all
    select /*+ ordered
               full(period) use_hash(period) swap_join_inputs(period)
               full(qtr)    use_hash(qtr)    swap_join_inputs(qtr)
               full(tmp1)   use_hash(tmp1)   parallel(tmp1) */  -- budget data
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.PROJECT_TYPE_CLASS,
      case when grouping(qtr.ENT_YEAR_ID)      = 0 and
                grouping(period.ENT_QTR_ID)    = 0 and
                grouping(period.ENT_PERIOD_ID) = 0
           then period.ENT_PERIOD_ID
           when grouping(qtr.ENT_YEAR_ID)      = 0 and
                grouping(period.ENT_QTR_ID)    = 0 and
                grouping(period.ENT_PERIOD_ID) = 1
           then period.ENT_QTR_ID
           when grouping(qtr.ENT_YEAR_ID)      = 0 and
                grouping(period.ENT_QTR_ID)    = 1 and
                grouping(period.ENT_PERIOD_ID) = 1
           then qtr.ENT_YEAR_ID
           end                              TIME_ID,
      case when grouping(qtr.ENT_YEAR_ID)      = 0 and
                grouping(period.ENT_QTR_ID)    = 0 and
                grouping(period.ENT_PERIOD_ID) = 0
           then 32
           when grouping(qtr.ENT_YEAR_ID)      = 0 and
                grouping(period.ENT_QTR_ID)    = 0 and
                grouping(period.ENT_PERIOD_ID) = 1
           then 64
           when grouping(qtr.ENT_YEAR_ID)      = 0 and
                grouping(period.ENT_QTR_ID)    = 1 and
                grouping(period.ENT_PERIOD_ID) = 1
           then 128
           end                              PERIOD_TYPE_ID,
      'E'                                   CALENDAR_TYPE,
      bitand(tmp1.CURR_RECORD_TYPE_ID, 247) CURR_RECORD_TYPE_ID,
      tmp1.CURRENCY_CODE,
      to_number(null)                       REVENUE,
      to_number(null)                       LABOR_REVENUE,
      to_number(null)                       RAW_COST,
      to_number(null)                       BURDENED_COST,
      to_number(null)                       BILL_RAW_COST,
      to_number(null)                       BILL_BURDENED_COST,
      to_number(null)                       LABOR_RAW_COST,
      to_number(null)                       LABOR_BURDENED_COST,
      to_number(null)                       BILL_LABOR_RAW_COST,
      to_number(null)                       BILL_LABOR_BURDENED_COST,
      to_number(null)                       REVENUE_WRITEOFF,
      to_number(null)                       LABOR_HRS,
      to_number(null)                       BILL_LABOR_HRS,
      sum(tmp1.CURR_BGT_REVENUE)            CURR_BGT_REVENUE,
      sum(tmp1.CURR_BGT_RAW_COST)           CURR_BGT_RAW_COST,
      sum(tmp1.CURR_BGT_BRDN_COST)          CURR_BGT_BURDENED_COST,
      sum(tmp1.CURR_BGT_LABOR_HRS)          CURR_BGT_LABOR_HRS,
      sum(tmp1.CURR_ORIG_BGT_REVENUE)       ORIG_BGT_REVENUE,
      sum(tmp1.CURR_ORIG_BGT_RAW_COST)      ORIG_BGT_RAW_COST,
      sum(tmp1.CURR_ORIG_BGT_BRDN_COST)     ORIG_BGT_BURDENED_COST,
      sum(tmp1.CURR_ORIG_BGT_LABOR_HRS)     ORIG_BGT_LABOR_HRS,
      sum(tmp1.CURR_FORECAST_REVENUE)       FORECAST_REVENUE,
      sum(tmp1.CURR_FORECAST_RAW_COST)      FORECAST_RAW_COST,
      sum(tmp1.CURR_FORECAST_BRDN_COST)     FORECAST_BURDENED_COST,
      sum(tmp1.CURR_FORECAST_LABOR_HRS)     FORECAST_LABOR_HRS
    from
      FII_TIME_ENT_PERIOD period,
      FII_TIME_ENT_QTR    qtr,
      PJI_FM_AGGR_PLN     tmp1
    where
      tmp1.CALENDAR_TYPE_CODE  = 'ENT'                and
      tmp1.CURR_RECORD_TYPE_ID not in (8, 256)        and
      tmp1.TIME_ID             = period.ENT_PERIOD_ID and
      period.ENT_QTR_ID        = qtr.ENT_QTR_ID
    group by
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.PROJECT_TYPE_CLASS,
      rollup (qtr.ENT_YEAR_ID,
              period.ENT_QTR_ID,
              period.ENT_PERIOD_ID),
      bitand(tmp1.CURR_RECORD_TYPE_ID, 247),
      tmp1.CURRENCY_CODE
    having
      not (grouping(qtr.ENT_YEAR_ID)      = 1 and
           grouping(period.ENT_QTR_ID)    = 1 and
           grouping(period.ENT_PERIOD_ID) = 1)
    union all
    select /*+ ordered full(map) parallel(map)
                       index(fpp, PJI_FP_PROJ_F_N2) use_nl(fpp) */  -- budget reversals
      fpp.PROJECT_ID,
      fpp.PROJECT_ORG_ID,
      fpp.PROJECT_ORGANIZATION_ID,
      fpp.PROJECT_TYPE_CLASS,
      fpp.TIME_ID,
      fpp.PERIOD_TYPE_ID,
      fpp.CALENDAR_TYPE,
      fpp.CURR_RECORD_TYPE_ID,
      fpp.CURRENCY_CODE,
      to_number(null)                       REVENUE,
      to_number(null)                       LABOR_REVENUE,
      to_number(null)                       RAW_COST,
      to_number(null)                       BURDENED_COST,
      to_number(null)                       BILL_RAW_COST,
      to_number(null)                       BILL_BURDENED_COST,
      to_number(null)                       LABOR_RAW_COST,
      to_number(null)                       LABOR_BURDENED_COST,
      to_number(null)                       BILL_LABOR_RAW_COST,
      to_number(null)                       BILL_LABOR_BURDENED_COST,
      to_number(null)                       REVENUE_WRITEOFF,
      to_number(null)                       LABOR_HRS,
      to_number(null)                       BILL_LABOR_HRS,
      case when map.REVENUE_BUDGET_C_VERSION <>
                map.REVENUE_BUDGET_N_VERSION
           then -fpp.CURR_BGT_REVENUE
           else to_number(null)
           end                              CURR_BGT_REVENUE,
      case when map.COST_BUDGET_C_VERSION <>
                map.COST_BUDGET_N_VERSION
           then -fpp.CURR_BGT_RAW_COST
           else to_number(null)
           end                              CURR_BGT_RAW_COST,
      case when map.COST_BUDGET_C_VERSION <>
                map.COST_BUDGET_N_VERSION
           then -fpp.CURR_BGT_BURDENED_COST
           else to_number(null)
           end                              CURR_BGT_BURDENED_COST,
      case when map.COST_BUDGET_C_VERSION <>
                map.COST_BUDGET_N_VERSION
           then -fpp.CURR_BGT_LABOR_HRS
           else to_number(null)
           end                              CURR_BGT_LABOR_HRS,
      case when map.REVENUE_BUDGET_CO_VERSION <>
                map.REVENUE_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_REVENUE
           else to_number(null)
           end                              ORIG_BGT_REVENUE,
      case when map.COST_BUDGET_CO_VERSION <>
                map.COST_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_RAW_COST
           else to_number(null)
           end                              ORIG_BGT_RAW_COST,
      case when map.COST_BUDGET_CO_VERSION <>
                map.COST_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_BURDENED_COST
           else to_number(null)
           end                              ORIG_BGT_BURDENED_COST,
      case when map.COST_BUDGET_CO_VERSION <>
                map.COST_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_LABOR_HRS
           else to_number(null)
           end                              ORIG_BGT_LABOR_HRS,
      case when map.REVENUE_FORECAST_C_VERSION <>
                map.REVENUE_FORECAST_N_VERSION
           then -fpp.FORECAST_REVENUE
           else to_number(null)
           end                              FORECAST_REVENUE,
      case when map.COST_FORECAST_C_VERSION <>
                map.COST_FORECAST_N_VERSION
           then -fpp.FORECAST_RAW_COST
           else to_number(null)
           end                              FORECAST_RAW_COST,
      case when map.COST_FORECAST_C_VERSION <>
                map.COST_FORECAST_N_VERSION
           then -fpp.FORECAST_BURDENED_COST
           else to_number(null)
           end                              FORECAST_BURDENED_COST,
      case when map.COST_FORECAST_C_VERSION <>
                map.COST_FORECAST_N_VERSION
           then -fpp.FORECAST_LABOR_HRS
           else to_number(null)
           end                              FORECAST_LABOR_HRS
    from
      PJI_PJI_PROJ_BATCH_MAP map,
      PJI_FP_PROJ_F fpp
    where
      l_extraction_type <> 'FULL' and
      map.WORKER_ID = p_worker_id and
      (map.REVENUE_BUDGET_C_VERSION   <> map.REVENUE_BUDGET_N_VERSION   or
       map.COST_BUDGET_C_VERSION      <> map.COST_BUDGET_N_VERSION      or
       map.REVENUE_BUDGET_CO_VERSION  <> map.REVENUE_BUDGET_NO_VERSION  or
       map.COST_BUDGET_CO_VERSION     <> map.COST_BUDGET_NO_VERSION     or
       map.REVENUE_FORECAST_C_VERSION <> map.REVENUE_FORECAST_N_VERSION or
       map.COST_FORECAST_C_VERSION    <> map.COST_FORECAST_N_VERSION) and
      map.PROJECT_ID = fpp.PROJECT_ID and
      fpp.CALENDAR_TYPE = 'E' and
      fpp.PERIOD_TYPE_ID <> 1
    ) fin
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.TIME_ID,
      fin.PERIOD_TYPE_ID,
      fin.CALENDAR_TYPE,
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPP_CAL_EN(p_worker_id);');

    commit;

  end EXPAND_FPP_CAL_EN;


  -- -----------------------------------------------------
  -- procedure EXPAND_FPP_CAL_PA
  -- -----------------------------------------------------
  procedure EXPAND_FPP_CAL_PA (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

  begin

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process, 'PA_CALENDAR_FLAG') = 'N') then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPP_CAL_PA(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    insert /*+ append parallel(fin3_i) */ into PJI_FM_AGGR_FIN3 fin3_i -- in EXPAND_FPP_CAL_PA
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      CURR_BGT_REVENUE,
      CURR_BGT_RAW_COST,
      CURR_BGT_BURDENED_COST,
      CURR_BGT_LABOR_HRS,
      ORIG_BGT_REVENUE,
      ORIG_BGT_RAW_COST,
      ORIG_BGT_BURDENED_COST,
      ORIG_BGT_LABOR_HRS,
      FORECAST_REVENUE,
      FORECAST_RAW_COST,
      FORECAST_BURDENED_COST,
      FORECAST_LABOR_HRS
    )
    select
      p_worker_id,
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.TIME_ID,
      fin.PERIOD_TYPE_ID,
      fin.CALENDAR_TYPE,
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE),
      sum(fin.LABOR_REVENUE),
      sum(fin.RAW_COST),
      sum(fin.BURDENED_COST),
      sum(fin.BILL_RAW_COST),
      sum(fin.BILL_BURDENED_COST),
      sum(fin.LABOR_RAW_COST),
      sum(fin.LABOR_BURDENED_COST),
      sum(fin.BILL_LABOR_RAW_COST),
      sum(fin.BILL_LABOR_BURDENED_COST),
      sum(fin.REVENUE_WRITEOFF),
      sum(fin.LABOR_HRS),
      sum(fin.BILL_LABOR_HRS),
      sum(fin.CURR_BGT_REVENUE),
      sum(fin.CURR_BGT_RAW_COST),
      sum(fin.CURR_BGT_BURDENED_COST),
      sum(fin.CURR_BGT_LABOR_HRS),
      sum(fin.ORIG_BGT_REVENUE),
      sum(fin.ORIG_BGT_RAW_COST),
      sum(fin.ORIG_BGT_BURDENED_COST),
      sum(fin.ORIG_BGT_LABOR_HRS),
      sum(fin.FORECAST_REVENUE),
      sum(fin.FORECAST_RAW_COST),
      sum(fin.FORECAST_BURDENED_COST),
      sum(fin.FORECAST_LABOR_HRS)
    from
    (
    select /*+ ordered
               full(time) use_hash(time) parallel(time) swap_join_inputs(time)
               full(fin)  use_hash(fin)  parallel(fin) */
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      case when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 0
           then time.CAL_PERIOD_ID
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 1
           then time.CAL_QTR_ID
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 1 and
                grouping(time.CAL_PERIOD_ID) = 1
           then time.CAL_YEAR_ID
           end                              TIME_ID,
      case when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 0
           then 32
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 1
           then 64
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 1 and
                grouping(time.CAL_PERIOD_ID) = 1
           then 128
           end                              PERIOD_TYPE_ID,
      'P'                                   CALENDAR_TYPE,
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE)                      REVENUE,
      sum(fin.LABOR_REVENUE)                LABOR_REVENUE,
      sum(fin.RAW_COST)                     RAW_COST,
      sum(fin.BURDENED_COST)                BURDENED_COST,
      sum(fin.BILL_RAW_COST)                BILL_RAW_COST,
      sum(fin.BILL_BURDENED_COST)           BILL_BURDENED_COST,
      sum(fin.LABOR_RAW_COST)               LABOR_RAW_COST,
      sum(fin.LABOR_BURDENED_COST)          LABOR_BURDENED_COST,
      sum(fin.BILL_LABOR_RAW_COST)          BILL_LABOR_RAW_COST,
      sum(fin.BILL_LABOR_BURDENED_COST)     BILL_LABOR_BURDENED_COST,
      sum(fin.REVENUE_WRITEOFF)             REVENUE_WRITEOFF,
      sum(fin.LABOR_HRS)                    LABOR_HRS,
      sum(fin.BILL_LABOR_HRS)               BILL_LABOR_HRS,
      to_number(null)                       CURR_BGT_REVENUE,
      to_number(null)                       CURR_BGT_RAW_COST,
      to_number(null)                       CURR_BGT_BURDENED_COST,
      to_number(null)                       CURR_BGT_LABOR_HRS,
      to_number(null)                       ORIG_BGT_REVENUE,
      to_number(null)                       ORIG_BGT_RAW_COST,
      to_number(null)                       ORIG_BGT_BURDENED_COST,
      to_number(null)                       ORIG_BGT_LABOR_HRS,
      to_number(null)                       FORECAST_REVENUE,
      to_number(null)                       FORECAST_RAW_COST,
      to_number(null)                       FORECAST_BURDENED_COST,
      to_number(null)                       FORECAST_LABOR_HRS
    from
      FII_TIME_CAL_DAY_MV time,
      PJI_FM_AGGR_FIN3    fin
    where
      fin.WORKER_ID                      = p_worker_id        and
      fin.PERIOD_TYPE_ID                 = 1                  and
      fin.CALENDAR_TYPE                  = 'P'                and
      to_date(to_char(fin.TIME_ID), 'J') = time.REPORT_DATE   and
      fin.PA_CALENDAR_ID                 = time.CALENDAR_ID
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      rollup (time.CAL_YEAR_ID,
              time.CAL_QTR_ID,
              time.CAL_PERIOD_ID),
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE
    having
      not (grouping(time.CAL_YEAR_ID)   = 1 and
           grouping(time.CAL_QTR_ID)    = 1 and
           grouping(time.CAL_PERIOD_ID) = 1)
    union all
    select /*+ ordered
               full(period) use_hash(period) swap_join_inputs(period)
               full(qtr)    use_hash(qtr)    swap_join_inputs(qtr)
               full(tmp1)   use_hash(tmp1)   parallel(tmp1) */ -- budget data
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.PROJECT_TYPE_CLASS,
      case when grouping(qtr.CAL_YEAR_ID)      = 0 and
                grouping(period.CAL_QTR_ID)    = 0 and
                grouping(period.CAL_PERIOD_ID) = 0
           then period.CAL_PERIOD_ID
           when grouping(qtr.CAL_YEAR_ID)      = 0 and
                grouping(period.CAL_QTR_ID)    = 0 and
                grouping(period.CAL_PERIOD_ID) = 1
           then period.CAL_QTR_ID
           when grouping(qtr.CAL_YEAR_ID)      = 0 and
                grouping(period.CAL_QTR_ID)    = 1 and
                grouping(period.CAL_PERIOD_ID) = 1
           then qtr.CAL_YEAR_ID
           end                              TIME_ID,
      case when grouping(qtr.CAL_YEAR_ID)      = 0 and
                grouping(period.CAL_QTR_ID)    = 0 and
                grouping(period.CAL_PERIOD_ID) = 0
           then 32
           when grouping(qtr.CAL_YEAR_ID)      = 0 and
                grouping(period.CAL_QTR_ID)    = 0 and
                grouping(period.CAL_PERIOD_ID) = 1
           then 64
           when grouping(qtr.CAL_YEAR_ID)      = 0 and
                grouping(period.CAL_QTR_ID)    = 1 and
                grouping(period.CAL_PERIOD_ID) = 1
           then 128
           end                              PERIOD_TYPE_ID,
      'P'                                   CALENDAR_TYPE,
      tmp1.CURR_RECORD_TYPE_ID,
      tmp1.CURRENCY_CODE,
      to_number(null)                       REVENUE,
      to_number(null)                       LABOR_REVENUE,
      to_number(null)                       RAW_COST,
      to_number(null)                       BURDENED_COST,
      to_number(null)                       BILL_RAW_COST,
      to_number(null)                       BILL_BURDENED_COST,
      to_number(null)                       LABOR_RAW_COST,
      to_number(null)                       LABOR_BURDENED_COST,
      to_number(null)                       BILL_LABOR_RAW_COST,
      to_number(null)                       BILL_LABOR_BURDENED_COST,
      to_number(null)                       REVENUE_WRITEOFF,
      to_number(null)                       LABOR_HRS,
      to_number(null)                       BILL_LABOR_HRS,
      sum(tmp1.CURR_BGT_REVENUE)            CURR_BGT_REVENUE,
      sum(tmp1.CURR_BGT_RAW_COST)           CURR_BGT_RAW_COST,
      sum(tmp1.CURR_BGT_BRDN_COST)          CURR_BGT_BURDENED_COST,
      sum(tmp1.CURR_BGT_LABOR_HRS)          CURR_BGT_LABOR_HRS,
      sum(tmp1.CURR_ORIG_BGT_REVENUE)       ORIG_BGT_REVENUE,
      sum(tmp1.CURR_ORIG_BGT_RAW_COST)      ORIG_BGT_RAW_COST,
      sum(tmp1.CURR_ORIG_BGT_BRDN_COST)     ORIG_BGT_BURDENED_COST,
      sum(tmp1.CURR_ORIG_BGT_LABOR_HRS)     ORIG_BGT_LABOR_HRS,
      sum(tmp1.CURR_FORECAST_REVENUE)       FORECAST_REVENUE,
      sum(tmp1.CURR_FORECAST_RAW_COST)      FORECAST_RAW_COST,
      sum(tmp1.CURR_FORECAST_BRDN_COST)     FORECAST_BURDENED_COST,
      sum(tmp1.CURR_FORECAST_LABOR_HRS)     FORECAST_LABOR_HRS
    from
      FII_TIME_CAL_PERIOD period,
      FII_TIME_CAL_QTR    qtr,
      PJI_FM_AGGR_PLN     tmp1
    where
      tmp1.CALENDAR_TYPE_CODE = 'PA'               and
      tmp1.TIME_ID            = period.CAL_PERIOD_ID and
      period.CAL_QTR_ID       = qtr.CAL_QTR_ID
    group by
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.PROJECT_TYPE_CLASS,
      rollup (qtr.CAL_YEAR_ID,
              period.CAL_QTR_ID,
              period.CAL_PERIOD_ID),
      tmp1.CURR_RECORD_TYPE_ID,
      tmp1.CURRENCY_CODE
    having
      not (grouping(qtr.CAL_YEAR_ID)      = 1 and
           grouping(period.CAL_QTR_ID)    = 1 and
           grouping(period.CAL_PERIOD_ID) = 1)
    union all
    select /*+ ordered full(map) parallel(map)
                       index(fpp, PJI_FP_PROJ_F_N2) use_nl(fpp) */  -- budget reversals
      fpp.PROJECT_ID,
      fpp.PROJECT_ORG_ID,
      fpp.PROJECT_ORGANIZATION_ID,
      fpp.PROJECT_TYPE_CLASS,
      fpp.TIME_ID,
      fpp.PERIOD_TYPE_ID,
      fpp.CALENDAR_TYPE,
      fpp.CURR_RECORD_TYPE_ID,
      fpp.CURRENCY_CODE,
      to_number(null)                       REVENUE,
      to_number(null)                       LABOR_REVENUE,
      to_number(null)                       RAW_COST,
      to_number(null)                       BURDENED_COST,
      to_number(null)                       BILL_RAW_COST,
      to_number(null)                       BILL_BURDENED_COST,
      to_number(null)                       LABOR_RAW_COST,
      to_number(null)                       LABOR_BURDENED_COST,
      to_number(null)                       BILL_LABOR_RAW_COST,
      to_number(null)                       BILL_LABOR_BURDENED_COST,
      to_number(null)                       REVENUE_WRITEOFF,
      to_number(null)                       LABOR_HRS,
      to_number(null)                       BILL_LABOR_HRS,
      case when map.REVENUE_BUDGET_C_VERSION <>
                map.REVENUE_BUDGET_N_VERSION
           then -fpp.CURR_BGT_REVENUE
           else to_number(null)
           end                              CURR_BGT_REVENUE,
      case when map.COST_BUDGET_C_VERSION <>
                map.COST_BUDGET_N_VERSION
           then -fpp.CURR_BGT_RAW_COST
           else to_number(null)
           end                              CURR_BGT_RAW_COST,
      case when map.COST_BUDGET_C_VERSION <>
                map.COST_BUDGET_N_VERSION
           then -fpp.CURR_BGT_BURDENED_COST
           else to_number(null)
           end                              CURR_BGT_BURDENED_COST,
      case when map.COST_BUDGET_C_VERSION <>
                map.COST_BUDGET_N_VERSION
           then -fpp.CURR_BGT_LABOR_HRS
           else to_number(null)
           end                              CURR_BGT_LABOR_HRS,
      case when map.REVENUE_BUDGET_CO_VERSION <>
                map.REVENUE_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_REVENUE
           else to_number(null)
           end                              ORIG_BGT_REVENUE,
      case when map.COST_BUDGET_CO_VERSION <>
                map.COST_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_RAW_COST
           else to_number(null)
           end                              ORIG_BGT_RAW_COST,
      case when map.COST_BUDGET_CO_VERSION <>
                map.COST_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_BURDENED_COST
           else to_number(null)
           end                              ORIG_BGT_BURDENED_COST,
      case when map.COST_BUDGET_CO_VERSION <>
                map.COST_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_LABOR_HRS
           else to_number(null)
           end                              ORIG_BGT_LABOR_HRS,
      case when map.REVENUE_FORECAST_C_VERSION <>
                map.REVENUE_FORECAST_N_VERSION
           then -fpp.FORECAST_REVENUE
           else to_number(null)
           end                              FORECAST_REVENUE,
      case when map.COST_FORECAST_C_VERSION <>
                map.COST_FORECAST_N_VERSION
           then -fpp.FORECAST_RAW_COST
           else to_number(null)
           end                              FORECAST_RAW_COST,
      case when map.COST_FORECAST_C_VERSION <>
                map.COST_FORECAST_N_VERSION
           then -fpp.FORECAST_BURDENED_COST
           else to_number(null)
           end                              FORECAST_BURDENED_COST,
      case when map.COST_FORECAST_C_VERSION <>
                map.COST_FORECAST_N_VERSION
           then -fpp.FORECAST_LABOR_HRS
           else to_number(null)
           end                              FORECAST_LABOR_HRS
    from
      PJI_PJI_PROJ_BATCH_MAP map,
      PJI_FP_PROJ_F fpp
    where
      l_extraction_type <> 'FULL' and
      map.WORKER_ID = p_worker_id and
      (map.REVENUE_BUDGET_C_VERSION   <> map.REVENUE_BUDGET_N_VERSION   or
       map.COST_BUDGET_C_VERSION      <> map.COST_BUDGET_N_VERSION      or
       map.REVENUE_BUDGET_CO_VERSION  <> map.REVENUE_BUDGET_NO_VERSION  or
       map.COST_BUDGET_CO_VERSION     <> map.COST_BUDGET_NO_VERSION     or
       map.REVENUE_FORECAST_C_VERSION <> map.REVENUE_FORECAST_N_VERSION or
       map.COST_FORECAST_C_VERSION    <> map.COST_FORECAST_N_VERSION) and
      map.PROJECT_ID = fpp.PROJECT_ID and
      fpp.CALENDAR_TYPE = 'P' and
      fpp.PERIOD_TYPE_ID <> 1
    ) fin
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.TIME_ID,
      fin.PERIOD_TYPE_ID,
      fin.CALENDAR_TYPE,
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPP_CAL_PA(p_worker_id);');

    commit;

  end EXPAND_FPP_CAL_PA;


  -- -----------------------------------------------------
  -- procedure EXPAND_FPP_CAL_GL
  -- -----------------------------------------------------
  procedure EXPAND_FPP_CAL_GL (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

  begin

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process, 'GL_CALENDAR_FLAG') = 'N') then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPP_CAL_GL(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    insert /*+ append parallel(fin3_i) */ into PJI_FM_AGGR_FIN3 fin3_i -- in EXPAND_FPP_CAL_GL
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      CURR_BGT_REVENUE,
      CURR_BGT_RAW_COST,
      CURR_BGT_BURDENED_COST,
      CURR_BGT_LABOR_HRS,
      ORIG_BGT_REVENUE,
      ORIG_BGT_RAW_COST,
      ORIG_BGT_BURDENED_COST,
      ORIG_BGT_LABOR_HRS,
      FORECAST_REVENUE,
      FORECAST_RAW_COST,
      FORECAST_BURDENED_COST,
      FORECAST_LABOR_HRS
    )
    select
      p_worker_id,
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.TIME_ID,
      fin.PERIOD_TYPE_ID,
      fin.CALENDAR_TYPE,
      decode(fin.PERIOD_TYPE_ID,
             32, fin.CURR_RECORD_TYPE_ID,
                 bitand(fin.CURR_RECORD_TYPE_ID,
                        247))               CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE),
      sum(fin.LABOR_REVENUE),
      sum(fin.RAW_COST),
      sum(fin.BURDENED_COST),
      sum(fin.BILL_RAW_COST),
      sum(fin.BILL_BURDENED_COST),
      sum(fin.LABOR_RAW_COST),
      sum(fin.LABOR_BURDENED_COST),
      sum(fin.BILL_LABOR_RAW_COST),
      sum(fin.BILL_LABOR_BURDENED_COST),
      sum(fin.REVENUE_WRITEOFF),
      sum(fin.LABOR_HRS),
      sum(fin.BILL_LABOR_HRS),
      sum(fin.CURR_BGT_REVENUE),
      sum(fin.CURR_BGT_RAW_COST),
      sum(fin.CURR_BGT_BURDENED_COST),
      sum(fin.CURR_BGT_LABOR_HRS),
      sum(fin.ORIG_BGT_REVENUE),
      sum(fin.ORIG_BGT_RAW_COST),
      sum(fin.ORIG_BGT_BURDENED_COST),
      sum(fin.ORIG_BGT_LABOR_HRS),
      sum(fin.FORECAST_REVENUE),
      sum(fin.FORECAST_RAW_COST),
      sum(fin.FORECAST_BURDENED_COST),
      sum(fin.FORECAST_LABOR_HRS)
    from
    (
    select /*+ ordered
               full(time) use_hash(time) parallel(time) swap_join_inputs(time)
               full(fin)  use_hash(fin)  parallel(fin) */
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      case when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 0
           then time.CAL_PERIOD_ID
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 1
           then time.CAL_QTR_ID
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 1 and
                grouping(time.CAL_PERIOD_ID) = 1
           then time.CAL_YEAR_ID
           end                              TIME_ID,
      case when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 0
           then 32
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 0 and
                grouping(time.CAL_PERIOD_ID) = 1
           then 64
           when grouping(time.CAL_YEAR_ID)   = 0 and
                grouping(time.CAL_QTR_ID)    = 1 and
                grouping(time.CAL_PERIOD_ID) = 1
           then 128
           end                              PERIOD_TYPE_ID,
      'G'                                   CALENDAR_TYPE,
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE)                      REVENUE,
      sum(fin.LABOR_REVENUE)                LABOR_REVENUE,
      sum(fin.RAW_COST)                     RAW_COST,
      sum(fin.BURDENED_COST)                BURDENED_COST,
      sum(fin.BILL_RAW_COST)                BILL_RAW_COST,
      sum(fin.BILL_BURDENED_COST)           BILL_BURDENED_COST,
      sum(fin.LABOR_RAW_COST)               LABOR_RAW_COST,
      sum(fin.LABOR_BURDENED_COST)          LABOR_BURDENED_COST,
      sum(fin.BILL_LABOR_RAW_COST)          BILL_LABOR_RAW_COST,
      sum(fin.BILL_LABOR_BURDENED_COST)     BILL_LABOR_BURDENED_COST,
      sum(fin.REVENUE_WRITEOFF)             REVENUE_WRITEOFF,
      sum(fin.LABOR_HRS)                    LABOR_HRS,
      sum(fin.BILL_LABOR_HRS)               BILL_LABOR_HRS,
      to_number(null)                       CURR_BGT_REVENUE,
      to_number(null)                       CURR_BGT_RAW_COST,
      to_number(null)                       CURR_BGT_BURDENED_COST,
      to_number(null)                       CURR_BGT_LABOR_HRS,
      to_number(null)                       ORIG_BGT_REVENUE,
      to_number(null)                       ORIG_BGT_RAW_COST,
      to_number(null)                       ORIG_BGT_BURDENED_COST,
      to_number(null)                       ORIG_BGT_LABOR_HRS,
      to_number(null)                       FORECAST_REVENUE,
      to_number(null)                       FORECAST_RAW_COST,
      to_number(null)                       FORECAST_BURDENED_COST,
      to_number(null)                       FORECAST_LABOR_HRS
    from
      FII_TIME_CAL_DAY_MV time,
      PJI_FM_AGGR_FIN3    fin
    where
      fin.WORKER_ID                      = p_worker_id        and
      fin.PERIOD_TYPE_ID                 = 1                  and
      fin.CALENDAR_TYPE                  = 'C'                and
      to_date(to_char(fin.TIME_ID), 'J') = time.REPORT_DATE   and
      fin.GL_CALENDAR_ID                 = time.CALENDAR_ID
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      rollup (time.CAL_YEAR_ID,
              time.CAL_QTR_ID,
              time.CAL_PERIOD_ID),
      fin.CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE
    having
      not (grouping(time.CAL_YEAR_ID)   = 1 and
           grouping(time.CAL_QTR_ID)    = 1 and
           grouping(time.CAL_PERIOD_ID) = 1)
    union all
    select /*+ ordered
               full(period) use_hash(period) swap_join_inputs(period)
               full(qtr)    use_hash(qtr)    swap_join_inputs(qtr)
               full(tmp1)   use_hash(tmp1)   parallel(tmp1) */ -- budget data
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.PROJECT_TYPE_CLASS,
      case when grouping(qtr.CAL_YEAR_ID)      = 0 and
                grouping(period.CAL_QTR_ID)    = 0 and
                grouping(period.CAL_PERIOD_ID) = 0
           then period.CAL_PERIOD_ID
           when grouping(qtr.CAL_YEAR_ID)      = 0 and
                grouping(period.CAL_QTR_ID)    = 0 and
                grouping(period.CAL_PERIOD_ID) = 1
           then period.CAL_QTR_ID
           when grouping(qtr.CAL_YEAR_ID)      = 0 and
                grouping(period.CAL_QTR_ID)    = 1 and
                grouping(period.CAL_PERIOD_ID) = 1
           then qtr.CAL_YEAR_ID
           end                              TIME_ID,
      case when grouping(qtr.CAL_YEAR_ID)      = 0 and
                grouping(period.CAL_QTR_ID)    = 0 and
                grouping(period.CAL_PERIOD_ID) = 0
           then 32
           when grouping(qtr.CAL_YEAR_ID)      = 0 and
                grouping(period.CAL_QTR_ID)    = 0 and
                grouping(period.CAL_PERIOD_ID) = 1
           then 64
           when grouping(qtr.CAL_YEAR_ID)      = 0 and
                grouping(period.CAL_QTR_ID)    = 1 and
                grouping(period.CAL_PERIOD_ID) = 1
           then 128
           end                              PERIOD_TYPE_ID,
      'G'                                   CALENDAR_TYPE,
      tmp1.CURR_RECORD_TYPE_ID,
      tmp1.CURRENCY_CODE,
      to_number(null)                       REVENUE,
      to_number(null)                       LABOR_REVENUE,
      to_number(null)                       RAW_COST,
      to_number(null)                       BURDENED_COST,
      to_number(null)                       BILL_RAW_COST,
      to_number(null)                       BILL_BURDENED_COST,
      to_number(null)                       LABOR_RAW_COST,
      to_number(null)                       LABOR_BURDENED_COST,
      to_number(null)                       BILL_LABOR_RAW_COST,
      to_number(null)                       BILL_LABOR_BURDENED_COST,
      to_number(null)                       REVENUE_WRITEOFF,
      to_number(null)                       LABOR_HRS,
      to_number(null)                       BILL_LABOR_HRS,
      sum(tmp1.CURR_BGT_REVENUE)            CURR_BGT_REVENUE,
      sum(tmp1.CURR_BGT_RAW_COST)           CURR_BGT_RAW_COST,
      sum(tmp1.CURR_BGT_BRDN_COST)          CURR_BGT_BURDENED_COST,
      sum(tmp1.CURR_BGT_LABOR_HRS)          CURR_BGT_LABOR_HRS,
      sum(tmp1.CURR_ORIG_BGT_REVENUE)       ORIG_BGT_REVENUE,
      sum(tmp1.CURR_ORIG_BGT_RAW_COST)      ORIG_BGT_RAW_COST,
      sum(tmp1.CURR_ORIG_BGT_BRDN_COST)     ORIG_BGT_BURDENED_COST,
      sum(tmp1.CURR_ORIG_BGT_LABOR_HRS)     ORIG_BGT_LABOR_HRS,
      sum(tmp1.CURR_FORECAST_REVENUE)       FORECAST_REVENUE,
      sum(tmp1.CURR_FORECAST_RAW_COST)      FORECAST_RAW_COST,
      sum(tmp1.CURR_FORECAST_BRDN_COST)     FORECAST_BURDENED_COST,
      sum(tmp1.CURR_FORECAST_LABOR_HRS)     FORECAST_LABOR_HRS
    from
      FII_TIME_CAL_PERIOD period,
      FII_TIME_CAL_QTR    qtr,
      PJI_FM_AGGR_PLN     tmp1
    where
      tmp1.CALENDAR_TYPE_CODE = 'GL'                 and
      tmp1.TIME_ID            = period.CAL_PERIOD_ID and
      period.CAL_QTR_ID       = qtr.CAL_QTR_ID
    group by
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.PROJECT_TYPE_CLASS,
      rollup (qtr.CAL_YEAR_ID,
              period.CAL_QTR_ID,
              period.CAL_PERIOD_ID),
      tmp1.CURR_RECORD_TYPE_ID,
      tmp1.CURRENCY_CODE
    having
      not (grouping(qtr.CAL_YEAR_ID)      = 1 and
           grouping(period.CAL_QTR_ID)    = 1 and
           grouping(period.CAL_PERIOD_ID) = 1)
    union all
    select /*+ ordered full(map) parallel(map)
                       index(fpp, PJI_FP_PROJ_F_N2) use_nl(fpp) */  -- budget reversals
      fpp.PROJECT_ID,
      fpp.PROJECT_ORG_ID,
      fpp.PROJECT_ORGANIZATION_ID,
      fpp.PROJECT_TYPE_CLASS,
      fpp.TIME_ID,
      fpp.PERIOD_TYPE_ID,
      fpp.CALENDAR_TYPE,
      fpp.CURR_RECORD_TYPE_ID,
      fpp.CURRENCY_CODE,
      to_number(null)                       REVENUE,
      to_number(null)                       LABOR_REVENUE,
      to_number(null)                       RAW_COST,
      to_number(null)                       BURDENED_COST,
      to_number(null)                       BILL_RAW_COST,
      to_number(null)                       BILL_BURDENED_COST,
      to_number(null)                       LABOR_RAW_COST,
      to_number(null)                       LABOR_BURDENED_COST,
      to_number(null)                       BILL_LABOR_RAW_COST,
      to_number(null)                       BILL_LABOR_BURDENED_COST,
      to_number(null)                       REVENUE_WRITEOFF,
      to_number(null)                       LABOR_HRS,
      to_number(null)                       BILL_LABOR_HRS,
      case when map.REVENUE_BUDGET_C_VERSION <>
                map.REVENUE_BUDGET_N_VERSION
           then -fpp.CURR_BGT_REVENUE
           else to_number(null)
           end                              CURR_BGT_REVENUE,
      case when map.COST_BUDGET_C_VERSION <>
                map.COST_BUDGET_N_VERSION
           then -fpp.CURR_BGT_RAW_COST
           else to_number(null)
           end                              CURR_BGT_RAW_COST,
      case when map.COST_BUDGET_C_VERSION <>
                map.COST_BUDGET_N_VERSION
           then -fpp.CURR_BGT_BURDENED_COST
           else to_number(null)
           end                              CURR_BGT_BURDENED_COST,
      case when map.COST_BUDGET_C_VERSION <>
                map.COST_BUDGET_N_VERSION
           then -fpp.CURR_BGT_LABOR_HRS
           else to_number(null)
           end                              CURR_BGT_LABOR_HRS,
      case when map.REVENUE_BUDGET_CO_VERSION <>
                map.REVENUE_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_REVENUE
           else to_number(null)
           end                              ORIG_BGT_REVENUE,
      case when map.COST_BUDGET_CO_VERSION <>
                map.COST_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_RAW_COST
           else to_number(null)
           end                              ORIG_BGT_RAW_COST,
      case when map.COST_BUDGET_CO_VERSION <>
                map.COST_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_BURDENED_COST
           else to_number(null)
           end                              ORIG_BGT_BURDENED_COST,
      case when map.COST_BUDGET_CO_VERSION <>
                map.COST_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_LABOR_HRS
           else to_number(null)
           end                              ORIG_BGT_LABOR_HRS,
      case when map.REVENUE_FORECAST_C_VERSION <>
                map.REVENUE_FORECAST_N_VERSION
           then -fpp.FORECAST_REVENUE
           else to_number(null)
           end                              FORECAST_REVENUE,
      case when map.COST_FORECAST_C_VERSION <>
                map.COST_FORECAST_N_VERSION
           then -fpp.FORECAST_RAW_COST
           else to_number(null)
           end                              FORECAST_RAW_COST,
      case when map.COST_FORECAST_C_VERSION <>
                map.COST_FORECAST_N_VERSION
           then -fpp.FORECAST_BURDENED_COST
           else to_number(null)
           end                              FORECAST_BURDENED_COST,
      case when map.COST_FORECAST_C_VERSION <>
                map.COST_FORECAST_N_VERSION
           then -fpp.FORECAST_LABOR_HRS
           else to_number(null)
           end                              FORECAST_LABOR_HRS
    from
      PJI_PJI_PROJ_BATCH_MAP map,
      PJI_FP_PROJ_F fpp
    where
      l_extraction_type <> 'FULL' and
      map.WORKER_ID = p_worker_id and
      (map.REVENUE_BUDGET_C_VERSION   <> map.REVENUE_BUDGET_N_VERSION   or
       map.COST_BUDGET_C_VERSION      <> map.COST_BUDGET_N_VERSION      or
       map.REVENUE_BUDGET_CO_VERSION  <> map.REVENUE_BUDGET_NO_VERSION  or
       map.COST_BUDGET_CO_VERSION     <> map.COST_BUDGET_NO_VERSION     or
       map.REVENUE_FORECAST_C_VERSION <> map.REVENUE_FORECAST_N_VERSION or
       map.COST_FORECAST_C_VERSION    <> map.COST_FORECAST_N_VERSION) and
      map.PROJECT_ID = fpp.PROJECT_ID and
      fpp.CALENDAR_TYPE = 'G' and
      fpp.PERIOD_TYPE_ID <> 1
    ) fin
    where
      not (fin.CURR_RECORD_TYPE_ID in (8, 256) and
           fin.PERIOD_TYPE_ID <> 32)
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      fin.TIME_ID,
      fin.PERIOD_TYPE_ID,
      fin.CALENDAR_TYPE,
      decode(fin.PERIOD_TYPE_ID,
             32, fin.CURR_RECORD_TYPE_ID,
                 bitand(fin.CURR_RECORD_TYPE_ID,
                        247)),
      fin.CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPP_CAL_GL(p_worker_id);');

    commit;

  end EXPAND_FPP_CAL_GL;


  -- -----------------------------------------------------
  -- procedure EXPAND_FPP_CAL_WK
  -- -----------------------------------------------------
  procedure EXPAND_FPP_CAL_WK (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_schema          varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPP_CAL_WK(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    insert /*+ append parallel(fin3_i) */ into PJI_FM_AGGR_FIN3 fin3_i -- in EXPAND_FPP_CAL_WK
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      LABOR_REVENUE,
      RAW_COST,
      BURDENED_COST,
      BILL_RAW_COST,
      BILL_BURDENED_COST,
      LABOR_RAW_COST,
      LABOR_BURDENED_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BURDENED_COST,
      REVENUE_WRITEOFF,
      LABOR_HRS,
      BILL_LABOR_HRS,
      CURR_BGT_REVENUE,
      CURR_BGT_RAW_COST,
      CURR_BGT_BURDENED_COST,
      CURR_BGT_LABOR_HRS,
      ORIG_BGT_REVENUE,
      ORIG_BGT_RAW_COST,
      ORIG_BGT_BURDENED_COST,
      ORIG_BGT_LABOR_HRS,
      FORECAST_REVENUE,
      FORECAST_RAW_COST,
      FORECAST_BURDENED_COST,
      FORECAST_LABOR_HRS
    )
    select
      p_worker_id,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      sum(REVENUE),
      sum(LABOR_REVENUE),
      sum(RAW_COST),
      sum(BURDENED_COST),
      sum(BILL_RAW_COST),
      sum(BILL_BURDENED_COST),
      sum(LABOR_RAW_COST),
      sum(LABOR_BURDENED_COST),
      sum(BILL_LABOR_RAW_COST),
      sum(BILL_LABOR_BURDENED_COST),
      sum(REVENUE_WRITEOFF),
      sum(LABOR_HRS),
      sum(BILL_LABOR_HRS),
      sum(CURR_BGT_REVENUE),
      sum(CURR_BGT_RAW_COST),
      sum(CURR_BGT_BURDENED_COST),
      sum(CURR_BGT_LABOR_HRS),
      sum(ORIG_BGT_REVENUE),
      sum(ORIG_BGT_RAW_COST),
      sum(ORIG_BGT_BURDENED_COST),
      sum(ORIG_BGT_LABOR_HRS),
      sum(FORECAST_REVENUE),
      sum(FORECAST_RAW_COST),
      sum(FORECAST_BURDENED_COST),
      sum(FORECAST_LABOR_HRS)
    from
    (
    select /*+ ordered
               full(time) use_hash(time) swap_join_inputs(time)
               full(fin)  use_hash(fin)  parallel(fin) */
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      time.WEEK_ID                          TIME_ID,
      16                                    PERIOD_TYPE_ID,
      'E'                                   CALENDAR_TYPE,
      bitand(fin.CURR_RECORD_TYPE_ID, 247)  CURR_RECORD_TYPE_ID,
      fin.CURRENCY_CODE,
      sum(fin.REVENUE)                      REVENUE,
      sum(fin.LABOR_REVENUE)                LABOR_REVENUE,
      sum(fin.RAW_COST)                     RAW_COST,
      sum(fin.BURDENED_COST)                BURDENED_COST,
      sum(fin.BILL_RAW_COST)                BILL_RAW_COST,
      sum(fin.BILL_BURDENED_COST)           BILL_BURDENED_COST,
      sum(fin.LABOR_RAW_COST)               LABOR_RAW_COST,
      sum(fin.LABOR_BURDENED_COST)          LABOR_BURDENED_COST,
      sum(fin.BILL_LABOR_RAW_COST)          BILL_LABOR_RAW_COST,
      sum(fin.BILL_LABOR_BURDENED_COST)     BILL_LABOR_BURDENED_COST,
      sum(fin.REVENUE_WRITEOFF)             REVENUE_WRITEOFF,
      sum(fin.LABOR_HRS)                    LABOR_HRS,
      sum(fin.BILL_LABOR_HRS)               BILL_LABOR_HRS,
      to_number(null)                       CURR_BGT_REVENUE,
      to_number(null)                       CURR_BGT_RAW_COST,
      to_number(null)                       CURR_BGT_BURDENED_COST,
      to_number(null)                       CURR_BGT_LABOR_HRS,
      to_number(null)                       ORIG_BGT_REVENUE,
      to_number(null)                       ORIG_BGT_RAW_COST,
      to_number(null)                       ORIG_BGT_BURDENED_COST,
      to_number(null)                       ORIG_BGT_LABOR_HRS,
      to_number(null)                       FORECAST_REVENUE,
      to_number(null)                       FORECAST_RAW_COST,
      to_number(null)                       FORECAST_BURDENED_COST,
      to_number(null)                       FORECAST_LABOR_HRS
    from
      FII_TIME_DAY     time,
      PJI_FM_AGGR_FIN3 fin
    where
      fin.WORKER_ID           = p_worker_id   and
      fin.PERIOD_TYPE_ID      = 1             and
      fin.CALENDAR_TYPE       = 'C'           and
      fin.CURR_RECORD_TYPE_ID not in (8, 256) and
      fin.TIME_ID             = time.REPORT_DATE_JULIAN
    group by
      fin.PROJECT_ID,
      fin.PROJECT_ORG_ID,
      fin.PROJECT_ORGANIZATION_ID,
      fin.PROJECT_TYPE_CLASS,
      time.WEEK_ID,
      bitand(fin.CURR_RECORD_TYPE_ID, 247),
      fin.CURRENCY_CODE
    union all
    select /*+ parallel(tmp1) */          -- budget data
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.PROJECT_TYPE_CLASS,
      tmp1.TIME_ID,
      16                                    PERIOD_TYPE_ID,
      'E'                                   CALENDAR_TYPE,
      bitand(tmp1.CURR_RECORD_TYPE_ID, 247) CURR_RECORD_TYPE_ID,
      tmp1.CURRENCY_CODE,
      to_number(null)                       REVENUE,
      to_number(null)                       LABOR_REVENUE,
      to_number(null)                       RAW_COST,
      to_number(null)                       BURDENED_COST,
      to_number(null)                       BILL_RAW_COST,
      to_number(null)                       BILL_BURDENED_COST,
      to_number(null)                       LABOR_RAW_COST,
      to_number(null)                       LABOR_BURDENED_COST,
      to_number(null)                       BILL_LABOR_RAW_COST,
      to_number(null)                       BILL_LABOR_BURDENED_COST,
      to_number(null)                       REVENUE_WRITEOFF,
      to_number(null)                       LABOR_HRS,
      to_number(null)                       BILL_LABOR_HRS,
      sum(tmp1.CURR_BGT_REVENUE)            CURR_BGT_REVENUE,
      sum(tmp1.CURR_BGT_RAW_COST)           CURR_BGT_RAW_COST,
      sum(tmp1.CURR_BGT_BRDN_COST)          CURR_BGT_BURDENED_COST,
      sum(tmp1.CURR_BGT_LABOR_HRS)          CURR_BGT_LABOR_HRS,
      sum(tmp1.CURR_ORIG_BGT_REVENUE)       ORIG_BGT_REVENUE,
      sum(tmp1.CURR_ORIG_BGT_RAW_COST)      ORIG_BGT_RAW_COST,
      sum(tmp1.CURR_ORIG_BGT_BRDN_COST)     ORIG_BGT_BURDENED_COST,
      sum(tmp1.CURR_ORIG_BGT_LABOR_HRS)     ORIG_BGT_LABOR_HRS,
      sum(tmp1.CURR_FORECAST_REVENUE)       FORECAST_REVENUE,
      sum(tmp1.CURR_FORECAST_RAW_COST)      FORECAST_RAW_COST,
      sum(tmp1.CURR_FORECAST_BRDN_COST)     FORECAST_BURDENED_COST,
      sum(tmp1.CURR_FORECAST_LABOR_HRS)     FORECAST_LABOR_HRS
    from
      PJI_FM_AGGR_PLN tmp1
    where
      tmp1.CALENDAR_TYPE_CODE = 'ENTW' and
      tmp1.CURR_RECORD_TYPE_ID not in (8, 256)
    group by
      tmp1.PROJECT_ID,
      tmp1.PROJECT_ORG_ID,
      tmp1.PROJECT_ORGANIZATION_ID,
      tmp1.PROJECT_TYPE_CLASS,
      tmp1.TIME_ID,
      bitand(tmp1.CURR_RECORD_TYPE_ID, 247),
      tmp1.CURRENCY_CODE
    union all
    select /*+ ordered full(map) parallel(map)
                       index(fpp, PJI_FP_PROJ_F_N2) use_nl(fpp) */  -- budget reversals
      fpp.PROJECT_ID,
      fpp.PROJECT_ORG_ID,
      fpp.PROJECT_ORGANIZATION_ID,
      fpp.PROJECT_TYPE_CLASS,
      fpp.TIME_ID,
      fpp.PERIOD_TYPE_ID,
      fpp.CALENDAR_TYPE,
      fpp.CURR_RECORD_TYPE_ID,
      fpp.CURRENCY_CODE,
      to_number(null)                       REVENUE,
      to_number(null)                       LABOR_REVENUE,
      to_number(null)                       RAW_COST,
      to_number(null)                       BURDENED_COST,
      to_number(null)                       BILL_RAW_COST,
      to_number(null)                       BILL_BURDENED_COST,
      to_number(null)                       LABOR_RAW_COST,
      to_number(null)                       LABOR_BURDENED_COST,
      to_number(null)                       BILL_LABOR_RAW_COST,
      to_number(null)                       BILL_LABOR_BURDENED_COST,
      to_number(null)                       REVENUE_WRITEOFF,
      to_number(null)                       LABOR_HRS,
      to_number(null)                       BILL_LABOR_HRS,
      case when map.REVENUE_BUDGET_C_VERSION <>
                map.REVENUE_BUDGET_N_VERSION
           then -fpp.CURR_BGT_REVENUE
           else to_number(null)
           end                              CURR_BGT_REVENUE,
      case when map.COST_BUDGET_C_VERSION <>
                map.COST_BUDGET_N_VERSION
           then -fpp.CURR_BGT_RAW_COST
           else to_number(null)
           end                              CURR_BGT_RAW_COST,
      case when map.COST_BUDGET_C_VERSION <>
                map.COST_BUDGET_N_VERSION
           then -fpp.CURR_BGT_BURDENED_COST
           else to_number(null)
           end                              CURR_BGT_BURDENED_COST,
      case when map.COST_BUDGET_C_VERSION <>
                map.COST_BUDGET_N_VERSION
           then -fpp.CURR_BGT_LABOR_HRS
           else to_number(null)
           end                              CURR_BGT_LABOR_HRS,
      case when map.REVENUE_BUDGET_CO_VERSION <>
                map.REVENUE_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_REVENUE
           else to_number(null)
           end                              ORIG_BGT_REVENUE,
      case when map.COST_BUDGET_CO_VERSION <>
                map.COST_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_RAW_COST
           else to_number(null)
           end                              ORIG_BGT_RAW_COST,
      case when map.COST_BUDGET_CO_VERSION <>
                map.COST_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_BURDENED_COST
           else to_number(null)
           end                              ORIG_BGT_BURDENED_COST,
      case when map.COST_BUDGET_CO_VERSION <>
                map.COST_BUDGET_NO_VERSION
           then -fpp.ORIG_BGT_LABOR_HRS
           else to_number(null)
           end                              ORIG_BGT_LABOR_HRS,
      case when map.REVENUE_FORECAST_C_VERSION <>
                map.REVENUE_FORECAST_N_VERSION
           then -fpp.FORECAST_REVENUE
           else to_number(null)
           end                              FORECAST_REVENUE,
      case when map.COST_FORECAST_C_VERSION <>
                map.COST_FORECAST_N_VERSION
           then -fpp.FORECAST_RAW_COST
           else to_number(null)
           end                              FORECAST_RAW_COST,
      case when map.COST_FORECAST_C_VERSION <>
                map.COST_FORECAST_N_VERSION
           then -fpp.FORECAST_BURDENED_COST
           else to_number(null)
           end                              FORECAST_BURDENED_COST,
      case when map.COST_FORECAST_C_VERSION <>
                map.COST_FORECAST_N_VERSION
           then -fpp.FORECAST_LABOR_HRS
           else to_number(null)
           end                              FORECAST_LABOR_HRS
    from
      PJI_PJI_PROJ_BATCH_MAP map,
      PJI_FP_PROJ_F fpp
    where
      l_extraction_type <> 'FULL' and
      map.WORKER_ID = p_worker_id and
      (map.REVENUE_BUDGET_C_VERSION   <> map.REVENUE_BUDGET_N_VERSION   or
       map.COST_BUDGET_C_VERSION      <> map.COST_BUDGET_N_VERSION      or
       map.REVENUE_BUDGET_CO_VERSION  <> map.REVENUE_BUDGET_NO_VERSION  or
       map.COST_BUDGET_CO_VERSION     <> map.COST_BUDGET_NO_VERSION     or
       map.REVENUE_FORECAST_C_VERSION <> map.REVENUE_FORECAST_N_VERSION or
       map.COST_FORECAST_C_VERSION    <> map.COST_FORECAST_N_VERSION) and
      map.PROJECT_ID = fpp.PROJECT_ID and
      fpp.CALENDAR_TYPE = 'E' and
      fpp.PERIOD_TYPE_ID = 16
    ) fin
    group by
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPP_CAL_WK(p_worker_id);');

    -- truncate intermediate tables no longer required
    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_AGGR_PLN' , 'NORMAL',null);

    commit;

  end EXPAND_FPP_CAL_WK;


  -- -----------------------------------------------------
  -- procedure MERGE_FIN_INTO_FPW
  -- -----------------------------------------------------
  procedure MERGE_FIN_INTO_FPW (p_worker_id in number) is

    l_process              varchar2(30);
    l_extraction_type      varchar2(30);
    l_last_update_date     date;
    l_last_updated_by      number;
    l_creation_date        date;
    l_created_by           number;
    l_last_update_login    number;
    l_schema               varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_FIN.MERGE_FIN_INTO_FPW(p_worker_id);'
            )) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (l_extraction_type = 'FULL') then

      insert /*+ append parallel(fpw) */ into PJI_FP_PROJ_ET_WT_F fpw
      (
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        TIME_ID,
        PROJECT_ID,
        EXP_EVT_TYPE_ID,
        WORK_TYPE_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        PROJECT_TYPE_CLASS,
        RAW_COST,
        BURDENED_COST,
        BILL_RAW_COST,
        BILL_BURDENED_COST,
        CAPITALIZABLE_RAW_COST,
        CAPITALIZABLE_BRDN_COST,
        LABOR_RAW_COST,
        LABOR_BURDENED_COST,
        BILL_LABOR_RAW_COST,
        BILL_LABOR_BURDENED_COST,
        LABOR_HRS,
        BILL_LABOR_HRS,
        QUANTITY,
        BILL_QUANTITY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ full(fin4)  parallel(fin4)  */
        fin4.PROJECT_ORG_ID,
        fin4.PROJECT_ORGANIZATION_ID,
        fin4.TIME_ID,
        fin4.PROJECT_ID,
        fin4.EXP_EVT_TYPE_ID,
        fin4.WORK_TYPE_ID,
        fin4.PERIOD_TYPE_ID,
        fin4.CALENDAR_TYPE,
        fin4.CURR_RECORD_TYPE_ID,
        fin4.CURRENCY_CODE,
        fin4.PROJECT_TYPE_CLASS,
        fin4.RAW_COST,
        fin4.BURDENED_COST,
        decode(fin4.PROJECT_TYPE_CLASS,
               'B', fin4.BILL_RAW_COST,
                    to_number(null))         BILL_RAW_COST,
        decode(fin4.Project_Type_Class,
               'B', fin4.BILL_BURDENED_COST,
                    to_number(null))         BILL_BURDENED_COST,
        decode(fin4.PROJECT_TYPE_CLASS,
               'C', fin4.BILL_RAW_COST,
                    to_number(null))         CAPITALIZABLE_RAW_COST,
        decode(fin4.PROJECT_TYPE_CLASS,
               'C', fin4.BILL_BURDENED_COST,
                    to_number(null))         CAPITALIZABLE_BRDN_COST,
        fin4.LABOR_RAW_COST,
        fin4.LABOR_BURDENED_COST,
        fin4.BILL_LABOR_RAW_COST,
        fin4.BILL_LABOR_BURDENED_COST,
        fin4.LABOR_HRS,
        fin4.BILL_LABOR_HRS,
        fin4.QUANTITY,
        fin4.BILL_QUANTITY,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PJI_FM_AGGR_FIN4 fin4
      where
        fin4.WORKER_ID = p_worker_id and
        (nvl(fin4.RAW_COST                 , 0) <> 0 or
         nvl(fin4.BURDENED_COST            , 0) <> 0 or
         nvl(fin4.BILL_RAW_COST            , 0) <> 0 or
         nvl(fin4.BILL_BURDENED_COST       , 0) <> 0 or
         nvl(fin4.LABOR_RAW_COST           , 0) <> 0 or
         nvl(fin4.LABOR_BURDENED_COST      , 0) <> 0 or
         nvl(fin4.BILL_LABOR_RAW_COST      , 0) <> 0 or
         nvl(fin4.BILL_LABOR_BURDENED_COST , 0) <> 0 or
         nvl(fin4.LABOR_HRS                , 0) <> 0 or
         nvl(fin4.BILL_LABOR_HRS           , 0) <> 0 or
         nvl(fin4.QUANTITY                 , 0) <> 0 or
         nvl(fin4.BILL_QUANTITY            , 0) <> 0);

    else -- not initial data load

      merge /*+ parallel(fpw) */ into PJI_FP_PROJ_ET_WT_F fpw
      using
      (
        select
          PROJECT_ORG_ID,
          PROJECT_ORGANIZATION_ID,
          TIME_ID,
          PROJECT_ID,
          EXP_EVT_TYPE_ID,
          WORK_TYPE_ID,
          PERIOD_TYPE_ID,
          CALENDAR_TYPE,
          CURR_RECORD_TYPE_ID,
          CURRENCY_CODE,
          PROJECT_TYPE_CLASS,
          RAW_COST,
          BURDENED_COST,
          BILL_RAW_COST,
          BILL_BURDENED_COST,
          CAPITALIZABLE_RAW_COST,
          CAPITALIZABLE_BRDN_COST,
          LABOR_RAW_COST,
          LABOR_BURDENED_COST,
          BILL_LABOR_RAW_COST,
          BILL_LABOR_BURDENED_COST,
          LABOR_HRS,
          BILL_LABOR_HRS,
          QUANTITY,
          BILL_QUANTITY,
          l_last_update_date            LAST_UPDATE_DATE,
          l_last_updated_by             LAST_UPDATED_BY,
          l_creation_date               CREATION_DATE,
          l_created_by                  CREATED_BY,
          l_last_update_login           LAST_UPDATE_LOGIN
        from
          (
          select
            PROJECT_ORG_ID,
            PROJECT_ORGANIZATION_ID,
            TIME_ID,
            PROJECT_ID,
            EXP_EVT_TYPE_ID,
            WORK_TYPE_ID,
            PERIOD_TYPE_ID,
            CALENDAR_TYPE,
            CURR_RECORD_TYPE_ID,
            CURRENCY_CODE,
            PROJECT_TYPE_CLASS,
            sum(RAW_COST)                 RAW_COST,
            sum(BURDENED_COST)            BURDENED_COST,
            sum(BILL_RAW_COST)            BILL_RAW_COST,
            sum(BILL_BURDENED_COST)       BILL_BURDENED_COST,
            sum(CAPITALIZABLE_RAW_COST)   CAPITALIZABLE_RAW_COST,
            sum(CAPITALIZABLE_BRDN_COST)  CAPITALIZABLE_BRDN_COST,
            sum(LABOR_RAW_COST)           LABOR_RAW_COST,
            sum(LABOR_BURDENED_COST)      LABOR_BURDENED_COST,
            sum(BILL_LABOR_RAW_COST)      BILL_LABOR_RAW_COST,
            sum(BILL_LABOR_BURDENED_COST) BILL_LABOR_BURDENED_COST,
            sum(LABOR_HRS)                LABOR_HRS,
            sum(BILL_LABOR_HRS)           BILL_LABOR_HRS,
            sum(QUANTITY)                 QUANTITY,
            sum(BILL_QUANTITY)            BILL_QUANTITY
          from
            (
            select /*+ full(fin4)   parallel(fin4)  */
              fin4.PROJECT_ORG_ID,
              fin4.PROJECT_ORGANIZATION_ID,
              fin4.TIME_ID,
              fin4.PROJECT_ID,
              fin4.EXP_EVT_TYPE_ID,
              fin4.WORK_TYPE_ID,
              fin4.PERIOD_TYPE_ID,
              fin4.CALENDAR_TYPE,
              fin4.CURR_RECORD_TYPE_ID,
              fin4.CURRENCY_CODE,
              fin4.PROJECT_TYPE_CLASS,
              fin4.RAW_COST,
              fin4.BURDENED_COST,
              decode(fin4.PROJECT_TYPE_CLASS,
                     'B', fin4.BILL_RAW_COST,
                          to_number(null))         BILL_RAW_COST,
              decode(fin4.Project_Type_Class,
                     'B', fin4.BILL_BURDENED_COST,
                          to_number(null))         BILL_BURDENED_COST,
              decode(fin4.PROJECT_TYPE_CLASS,
                     'C', fin4.BILL_RAW_COST,
                          to_number(null))         CAPITALIZABLE_RAW_COST,
              decode(fin4.PROJECT_TYPE_CLASS,
                     'C', fin4.BILL_BURDENED_COST,
                          to_number(null))         CAPITALIZABLE_BRDN_COST,
              fin4.LABOR_RAW_COST,
              fin4.LABOR_BURDENED_COST,
              fin4.BILL_LABOR_RAW_COST,
              fin4.BILL_LABOR_BURDENED_COST,
              fin4.LABOR_HRS,
              fin4.BILL_LABOR_HRS,
              fin4.QUANTITY,
              fin4.BILL_QUANTITY
            from
              PJI_FM_AGGR_FIN4 fin4
            where
              fin4.WORKER_ID = p_worker_id
            union all                       -- partial refresh
            select /*+ ordered full(map) parallel(map)
                               index(fpw, PJI_FP_PROJ_ET_WT_F_N2) use_nl(fpw)*/
              fpw.PROJECT_ORG_ID,
              fpw.PROJECT_ORGANIZATION_ID,
              fpw.TIME_ID,
              fpw.PROJECT_ID,
              fpw.EXP_EVT_TYPE_ID,
              fpw.WORK_TYPE_ID,
              fpw.PERIOD_TYPE_ID,
              fpw.CALENDAR_TYPE,
              fpw.CURR_RECORD_TYPE_ID,
              fpw.CURRENCY_CODE,
              fpw.PROJECT_TYPE_CLASS,
              -fpw.RAW_COST,
              -fpw.BURDENED_COST,
              -fpw.BILL_RAW_COST,
              -fpw.BILL_BURDENED_COST,
              -fpw.CAPITALIZABLE_RAW_COST,
              -fpw.CAPITALIZABLE_BRDN_COST,
              -fpw.LABOR_RAW_COST,
              -fpw.LABOR_BURDENED_COST,
              -fpw.BILL_LABOR_RAW_COST,
              -fpw.BILL_LABOR_BURDENED_COST,
              -fpw.LABOR_HRS,
              -fpw.BILL_LABOR_HRS,
              -fpw.QUANTITY,
              -fpw.BILL_QUANTITY
            from
              PJI_PJI_PROJ_BATCH_MAP map,
              PJI_FP_PROJ_ET_WT_F fpw
            where
              l_extraction_type   = 'PARTIAL'   and
              map.WORKER_ID       = p_worker_id and
              map.EXTRACTION_TYPE = 'P'         and
              fpw.PROJECT_ID      = map.PROJECT_ID
            )
          group by
            PROJECT_ORG_ID,
            PROJECT_ORGANIZATION_ID,
            TIME_ID,
            PROJECT_ID,
            EXP_EVT_TYPE_ID,
            WORK_TYPE_ID,
            PERIOD_TYPE_ID,
            CALENDAR_TYPE,
            CURR_RECORD_TYPE_ID,
            CURRENCY_CODE,
            PROJECT_TYPE_CLASS
          )
        where
          nvl(RAW_COST                , 0) <> 0 or
          nvl(BURDENED_COST           , 0) <> 0 or
          nvl(BILL_RAW_COST           , 0) <> 0 or
          nvl(BILL_BURDENED_COST      , 0) <> 0 or
          nvl(CAPITALIZABLE_RAW_COST  , 0) <> 0 or
          nvl(CAPITALIZABLE_BRDN_COST , 0) <> 0 or
          nvl(LABOR_RAW_COST          , 0) <> 0 or
          nvl(LABOR_BURDENED_COST     , 0) <> 0 or
          nvl(BILL_LABOR_RAW_COST     , 0) <> 0 or
          nvl(BILL_LABOR_BURDENED_COST, 0) <> 0 or
          nvl(LABOR_HRS               , 0) <> 0 or
          nvl(BILL_LABOR_HRS          , 0) <> 0 or
          nvl(QUANTITY                , 0) <> 0 or
          nvl(BILL_QUANTITY           , 0) <> 0
      ) fin
      on
      (
        fin.PROJECT_ORG_ID          = fpw.PROJECT_ORG_ID          and
        fin.PROJECT_ORGANIZATION_ID = fpw.PROJECT_ORGANIZATION_ID and
        fin.TIME_ID                 = fpw.TIME_ID                 and
        fin.PROJECT_ID              = fpw.PROJECT_ID              and
        fin.EXP_EVT_TYPE_ID         = fpw.EXP_EVT_TYPE_ID         and
        fin.WORK_TYPE_ID            = fpw.WORK_TYPE_ID            and
        fin.PERIOD_TYPE_ID          = fpw.PERIOD_TYPE_ID          and
        fin.CALENDAR_TYPE           = fpw.CALENDAR_TYPE           and
        fin.CURR_RECORD_TYPE_ID     = fpw.CURR_RECORD_TYPE_ID     and
        fin.CURRENCY_CODE           = fpw.CURRENCY_CODE           and
        fin.PROJECT_TYPE_CLASS      = fpw.PROJECT_TYPE_CLASS
      )
      when matched then update set
        fpw.RAW_COST       = case when fpw.RAW_COST is null and
                                       fin.RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpw.RAW_COST, 0) +
                                       nvl(fin.RAW_COST, 0)
                                  end,
        fpw.BURDENED_COST  = case when fpw.BURDENED_COST is null and
                                       fin.BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpw.BURDENED_COST, 0) +
                                       nvl(fin.BURDENED_COST, 0)
                                  end,
        fpw.BILL_RAW_COST  = case when fpw.BILL_RAW_COST is null and
                                       fin.BILL_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpw.BILL_RAW_COST, 0) +
                                       nvl(fin.BILL_RAW_COST, 0)
                                  end,
        fpw.BILL_BURDENED_COST
                           = case when fpw.BILL_BURDENED_COST is null and
                                       fin.BILL_BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpw.BILL_BURDENED_COST, 0) +
                                       nvl(fin.BILL_BURDENED_COST, 0)
                                  end,
        fpw.CAPITALIZABLE_RAW_COST
                           = case when fpw.CAPITALIZABLE_RAW_COST is null and
                                       fin.CAPITALIZABLE_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpw.CAPITALIZABLE_RAW_COST, 0) +
                                       nvl(fin.CAPITALIZABLE_RAW_COST, 0)
                                  end,
        fpw.CAPITALIZABLE_BRDN_COST
                           = case when fpw.CAPITALIZABLE_BRDN_COST is null and
                                       fin.CAPITALIZABLE_BRDN_COST is null
                                  then to_number(null)
                                  else nvl(fpw.CAPITALIZABLE_BRDN_COST, 0) +
                                       nvl(fin.CAPITALIZABLE_BRDN_COST, 0)
                                  end,
        fpw.LABOR_RAW_COST = case when fpw.LABOR_RAW_COST is null and
                                       fin.LABOR_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpw.LABOR_RAW_COST, 0) +
                                       nvl(fin.LABOR_RAW_COST, 0)
                                  end,
        fpw.LABOR_BURDENED_COST
                           = case when fpw.LABOR_BURDENED_COST is null and
                                       fin.LABOR_BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpw.LABOR_BURDENED_COST, 0) +
                                       nvl(fin.LABOR_BURDENED_COST, 0)
                                  end,
        fpw.BILL_LABOR_RAW_COST
                           = case when fpw.BILL_LABOR_RAW_COST is null and
                                       fin.BILL_LABOR_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpw.BILL_LABOR_RAW_COST, 0) +
                                       nvl(fin.BILL_LABOR_RAW_COST, 0)
                                  end,
        fpw.BILL_LABOR_BURDENED_COST
                           = case when fpw.BILL_LABOR_BURDENED_COST is null and
                                       fin.BILL_LABOR_BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpw.BILL_LABOR_BURDENED_COST, 0) +
                                       nvl(fin.BILL_LABOR_BURDENED_COST, 0)
                                  end,
        fpw.LABOR_HRS      = case when fpw.LABOR_HRS is null and
                                       fin.LABOR_HRS is null
                                  then to_number(null)
                                  else nvl(fpw.LABOR_HRS, 0) +
                                       nvl(fin.LABOR_HRS, 0)
                                  end,
        fpw.BILL_LABOR_HRS = case when fpw.BILL_LABOR_HRS is null and
                                       fin.BILL_LABOR_HRS is null
                                  then to_number(null)
                                  else nvl(fpw.BILL_LABOR_HRS, 0) +
                                       nvl(fin.BILL_LABOR_HRS, 0)
                                  end,
        fpw.QUANTITY       = case when fpw.QUANTITY is null and
                                       fin.QUANTITY is null
                                  then to_number(null)
                                  else nvl(fpw.QUANTITY, 0) +
                                       nvl(fin.QUANTITY, 0)
                                  end,
        fpw.BILL_QUANTITY  = case when fpw.BILL_QUANTITY is null and
                                       fin.BILL_QUANTITY is null
                                  then to_number(null)
                                  else nvl(fpw.BILL_QUANTITY, 0) +
                                       nvl(fin.BILL_QUANTITY, 0)
                                  end,
        fpw.LAST_UPDATE_DATE
                 = fin.LAST_UPDATE_DATE,
        fpw.LAST_UPDATED_BY
                 = fin.LAST_UPDATED_BY,
        fpw.LAST_UPDATE_LOGIN
                 = fin.LAST_UPDATE_LOGIN
      when not matched then insert
      (
        fpw.PROJECT_ORG_ID,
        fpw.PROJECT_ORGANIZATION_ID,
        fpw.TIME_ID,
        fpw.PROJECT_ID,
        fpw.EXP_EVT_TYPE_ID,
        fpw.WORK_TYPE_ID,
        fpw.PERIOD_TYPE_ID,
        fpw.CALENDAR_TYPE,
        fpw.CURR_RECORD_TYPE_ID,
        fpw.CURRENCY_CODE,
        fpw.PROJECT_TYPE_CLASS,
        fpw.RAW_COST,
        fpw.BURDENED_COST,
        fpw.BILL_RAW_COST,
        fpw.BILL_BURDENED_COST,
        fpw.CAPITALIZABLE_RAW_COST,
        fpw.CAPITALIZABLE_BRDN_COST,
        fpw.LABOR_RAW_COST,
        fpw.LABOR_BURDENED_COST,
        fpw.BILL_LABOR_RAW_COST,
        fpw.BILL_LABOR_BURDENED_COST,
        fpw.LABOR_HRS,
        fpw.BILL_LABOR_HRS,
        fpw.QUANTITY,
        fpw.BILL_QUANTITY,
        fpw.LAST_UPDATE_DATE,
        fpw.LAST_UPDATED_BY,
        fpw.CREATION_DATE,
        fpw.CREATED_BY,
        fpw.LAST_UPDATE_LOGIN
      )
      values
      (
        fin.PROJECT_ORG_ID,
        fin.PROJECT_ORGANIZATION_ID,
        fin.TIME_ID,
        fin.PROJECT_ID,
        fin.EXP_EVT_TYPE_ID,
        fin.WORK_TYPE_ID,
        fin.PERIOD_TYPE_ID,
        fin.CALENDAR_TYPE,
        fin.CURR_RECORD_TYPE_ID,
        fin.CURRENCY_CODE,
        fin.PROJECT_TYPE_CLASS,
        fin.RAW_COST,
        fin.BURDENED_COST,
        fin.BILL_RAW_COST,
        fin.BILL_BURDENED_COST,
        fin.CAPITALIZABLE_RAW_COST,
        fin.CAPITALIZABLE_BRDN_COST,
        fin.LABOR_RAW_COST,
        fin.LABOR_BURDENED_COST,
        fin.BILL_LABOR_RAW_COST,
        fin.BILL_LABOR_BURDENED_COST,
        fin.LABOR_HRS,
        fin.BILL_LABOR_HRS,
        fin.QUANTITY,
        fin.BILL_QUANTITY,
        fin.LAST_UPDATE_DATE,
        fin.LAST_UPDATED_BY,
        fin.CREATION_DATE,
        fin.CREATED_BY,
        fin.LAST_UPDATE_LOGIN
      );

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_FIN.MERGE_FIN_INTO_FPW(p_worker_id);'
    );

    -- truncate intermediate tables no longer required
    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema , 'PJI_FM_AGGR_FIN4' , 'NORMAL',null);

    commit;

  end MERGE_FIN_INTO_FPW;


  -- -----------------------------------------------------
  -- procedure MERGE_FIN_INTO_FPE
  -- -----------------------------------------------------
  procedure MERGE_FIN_INTO_FPE (p_worker_id in number) is

    l_process              varchar2(30);
    l_extraction_type      varchar2(30);
    l_last_update_date     date;
    l_last_updated_by      number;
    l_creation_date        date;
    l_created_by           number;
    l_last_update_login    number;
    l_schema               varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_FIN.MERGE_FIN_INTO_FPE(p_worker_id);'
            )) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (l_extraction_type = 'FULL') then

      insert /*+ append parallel(fpe) */ into PJI_FP_PROJ_ET_F fpe
      (
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        TIME_ID,
        PROJECT_ID,
        EXP_EVT_TYPE_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        PROJECT_TYPE_CLASS,
        REVENUE,
        LABOR_REVENUE,
        RAW_COST,
        BURDENED_COST,
        BILL_RAW_COST,
        BILL_BURDENED_COST,
        CAPITALIZABLE_RAW_COST,
        CAPITALIZABLE_BRDN_COST,
        LABOR_RAW_COST,
        LABOR_BURDENED_COST,
        BILL_LABOR_RAW_COST,
        BILL_LABOR_BURDENED_COST,
        LABOR_HRS,
        BILL_LABOR_HRS,
        QUANTITY,
        BILL_QUANTITY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ full(fin5)  parallel(fin5)  */
        fin5.PROJECT_ORG_ID,
        fin5.PROJECT_ORGANIZATION_ID,
        fin5.TIME_ID,
        fin5.PROJECT_ID,
        fin5.EXP_EVT_TYPE_ID,
        fin5.PERIOD_TYPE_ID,
        fin5.CALENDAR_TYPE,
        fin5.CURR_RECORD_TYPE_ID,
        fin5.CURRENCY_CODE,
        fin5.PROJECT_TYPE_CLASS,
        fin5.REVENUE,
        fin5.LABOR_REVENUE,
        fin5.RAW_COST,
        fin5.BURDENED_COST,
        decode(fin5.PROJECT_TYPE_CLASS,
               'B', fin5.BILL_RAW_COST,
                    to_number(null))         BILL_RAW_COST,
        decode(fin5.Project_Type_Class,
               'B', fin5.BILL_BURDENED_COST,
                    to_number(null))         BILL_BURDENED_COST,
        decode(fin5.PROJECT_TYPE_CLASS,
               'C', fin5.BILL_RAW_COST,
                    to_number(null))         CAPITALIZABLE_RAW_COST,
        decode(fin5.PROJECT_TYPE_CLASS,
               'C', fin5.BILL_BURDENED_COST,
                    to_number(null))         CAPITALIZABLE_BRDN_COST,
        fin5.LABOR_RAW_COST,
        fin5.LABOR_BURDENED_COST,
        fin5.BILL_LABOR_RAW_COST,
        fin5.BILL_LABOR_BURDENED_COST,
        fin5.LABOR_HRS,
        fin5.BILL_LABOR_HRS,
        fin5.QUANTITY,
        fin5.BILL_QUANTITY,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PJI_FM_AGGR_FIN5 fin5
      where
        fin5.WORKER_ID = p_worker_id and
        (nvl(fin5.REVENUE                 , 0) <> 0 or
         nvl(fin5.LABOR_REVENUE           , 0) <> 0 or
         nvl(fin5.RAW_COST                , 0) <> 0 or
         nvl(fin5.BURDENED_COST           , 0) <> 0 or
         nvl(fin5.BILL_RAW_COST           , 0) <> 0 or
         nvl(fin5.BILL_BURDENED_COST      , 0) <> 0 or
         nvl(fin5.LABOR_RAW_COST          , 0) <> 0 or
         nvl(fin5.LABOR_BURDENED_COST     , 0) <> 0 or
         nvl(fin5.BILL_LABOR_RAW_COST     , 0) <> 0 or
         nvl(fin5.BILL_LABOR_BURDENED_COST, 0) <> 0 or
         nvl(fin5.LABOR_HRS               , 0) <> 0 or
         nvl(fin5.BILL_LABOR_HRS          , 0) <> 0 or
         nvl(fin5.QUANTITY                , 0) <> 0 or
         nvl(fin5.BILL_QUANTITY           , 0) <> 0);

    else -- not initial data load

      merge /*+ parallel(fpe) */ into PJI_FP_PROJ_ET_F fpe
      using
      (
        select
          PROJECT_ORG_ID,
          PROJECT_ORGANIZATION_ID,
          TIME_ID,
          PROJECT_ID,
          EXP_EVT_TYPE_ID,
          PERIOD_TYPE_ID,
          CALENDAR_TYPE,
          CURR_RECORD_TYPE_ID,
          CURRENCY_CODE,
          PROJECT_TYPE_CLASS,
          REVENUE,
          LABOR_REVENUE,
          RAW_COST,
          BURDENED_COST,
          BILL_RAW_COST,
          BILL_BURDENED_COST,
          CAPITALIZABLE_RAW_COST,
          CAPITALIZABLE_BRDN_COST,
          LABOR_RAW_COST,
          LABOR_BURDENED_COST,
          BILL_LABOR_RAW_COST,
          BILL_LABOR_BURDENED_COST,
          LABOR_HRS,
          BILL_LABOR_HRS,
          QUANTITY,
          BILL_QUANTITY,
          l_last_update_date            LAST_UPDATE_DATE,
          l_last_updated_by             LAST_UPDATED_BY,
          l_creation_date               CREATION_DATE,
          l_created_by                  CREATED_BY,
          l_last_update_login           LAST_UPDATE_LOGIN
        from
          (
          select
            PROJECT_ORG_ID,
            PROJECT_ORGANIZATION_ID,
            TIME_ID,
            PROJECT_ID,
            EXP_EVT_TYPE_ID,
            PERIOD_TYPE_ID,
            CALENDAR_TYPE,
            CURR_RECORD_TYPE_ID,
            CURRENCY_CODE,
            PROJECT_TYPE_CLASS,
            sum(REVENUE)                  REVENUE,
            sum(LABOR_REVENUE)            LABOR_REVENUE,
            sum(RAW_COST)                 RAW_COST,
            sum(BURDENED_COST)            BURDENED_COST,
            sum(BILL_RAW_COST)            BILL_RAW_COST,
            sum(BILL_BURDENED_COST)       BILL_BURDENED_COST,
            sum(CAPITALIZABLE_RAW_COST)   CAPITALIZABLE_RAW_COST,
            sum(CAPITALIZABLE_BRDN_COST)  CAPITALIZABLE_BRDN_COST,
            sum(LABOR_RAW_COST)           LABOR_RAW_COST,
            sum(LABOR_BURDENED_COST)      LABOR_BURDENED_COST,
            sum(BILL_LABOR_RAW_COST)      BILL_LABOR_RAW_COST,
            sum(BILL_LABOR_BURDENED_COST) BILL_LABOR_BURDENED_COST,
            sum(LABOR_HRS)                LABOR_HRS,
            sum(BILL_LABOR_HRS)           BILL_LABOR_HRS,
            sum(QUANTITY)                 QUANTITY,
            sum(BILL_QUANTITY)            BILL_QUANTITY
          from
            (
            select /*+ full(fin5)   parallel(fin5)  */
              fin5.PROJECT_ORG_ID,
              fin5.PROJECT_ORGANIZATION_ID,
              fin5.TIME_ID,
              fin5.PROJECT_ID,
              fin5.EXP_EVT_TYPE_ID,
              fin5.PERIOD_TYPE_ID,
              fin5.CALENDAR_TYPE,
              fin5.CURR_RECORD_TYPE_ID,
              fin5.CURRENCY_CODE,
              fin5.PROJECT_TYPE_CLASS,
              fin5.REVENUE,
              fin5.LABOR_REVENUE,
              fin5.RAW_COST,
              fin5.BURDENED_COST,
              decode(fin5.PROJECT_TYPE_CLASS,
                     'B', fin5.BILL_RAW_COST,
                          to_number(null))         BILL_RAW_COST,
              decode(fin5.Project_Type_Class,
                     'B', fin5.BILL_BURDENED_COST,
                          to_number(null))         BILL_BURDENED_COST,
              decode(fin5.PROJECT_TYPE_CLASS,
                     'C', fin5.BILL_RAW_COST,
                          to_number(null))         CAPITALIZABLE_RAW_COST,
              decode(fin5.PROJECT_TYPE_CLASS,
                     'C', fin5.BILL_BURDENED_COST,
                          to_number(null))         CAPITALIZABLE_BRDN_COST,
              fin5.LABOR_RAW_COST,
              fin5.LABOR_BURDENED_COST,
              fin5.BILL_LABOR_RAW_COST,
              fin5.BILL_LABOR_BURDENED_COST,
              fin5.LABOR_HRS,
              fin5.BILL_LABOR_HRS,
              fin5.QUANTITY,
              fin5.BILL_QUANTITY
            from
              PJI_FM_AGGR_FIN5 fin5
            where
              fin5.WORKER_ID = p_worker_id
            union all                       -- partial refresh
            select /*+ ordered full(map) parallel(map)
                               index(fpe, PJI_FP_PROJ_ET_F_N2) use_nl(fpe) */
              fpe.PROJECT_ORG_ID,
              fpe.PROJECT_ORGANIZATION_ID,
              fpe.TIME_ID,
              fpe.PROJECT_ID,
              fpe.EXP_EVT_TYPE_ID,
              fpe.PERIOD_TYPE_ID,
              fpe.CALENDAR_TYPE,
              fpe.CURR_RECORD_TYPE_ID,
              fpe.CURRENCY_CODE,
              fpe.PROJECT_TYPE_CLASS,
              -fpe.REVENUE,
              -fpe.LABOR_REVENUE,
              -fpe.RAW_COST,
              -fpe.BURDENED_COST,
              -fpe.BILL_RAW_COST,
              -fpe.BILL_BURDENED_COST,
              -fpe.CAPITALIZABLE_RAW_COST,
              -fpe.CAPITALIZABLE_BRDN_COST,
              -fpe.LABOR_RAW_COST,
              -fpe.LABOR_BURDENED_COST,
              -fpe.BILL_LABOR_RAW_COST,
              -fpe.BILL_LABOR_BURDENED_COST,
              -fpe.LABOR_HRS,
              -fpe.BILL_LABOR_HRS,
              -fpe.QUANTITY,
              -fpe.BILL_QUANTITY
            from
              PJI_PJI_PROJ_BATCH_MAP map,
              PJI_FP_PROJ_ET_F fpe
            where
              l_extraction_type   = 'PARTIAL'   and
              map.WORKER_ID       = p_worker_id and
              map.EXTRACTION_TYPE = 'P'         and
              fpe.PROJECT_ID      = map.PROJECT_ID
            )
          group by
            PROJECT_ORG_ID,
            PROJECT_ORGANIZATION_ID,
            TIME_ID,
            PROJECT_ID,
            EXP_EVT_TYPE_ID,
            PERIOD_TYPE_ID,
            CALENDAR_TYPE,
            CURR_RECORD_TYPE_ID,
            CURRENCY_CODE,
            PROJECT_TYPE_CLASS
          )
        where
          nvl(REVENUE                 , 0) <> 0 or
          nvl(LABOR_REVENUE           , 0) <> 0 or
          nvl(RAW_COST                , 0) <> 0 or
          nvl(BURDENED_COST           , 0) <> 0 or
          nvl(BILL_RAW_COST           , 0) <> 0 or
          nvl(BILL_BURDENED_COST      , 0) <> 0 or
          nvl(CAPITALIZABLE_RAW_COST  , 0) <> 0 or
          nvl(CAPITALIZABLE_BRDN_COST , 0) <> 0 or
          nvl(LABOR_RAW_COST          , 0) <> 0 or
          nvl(LABOR_BURDENED_COST     , 0) <> 0 or
          nvl(BILL_LABOR_RAW_COST     , 0) <> 0 or
          nvl(BILL_LABOR_BURDENED_COST, 0) <> 0 or
          nvl(LABOR_HRS               , 0) <> 0 or
          nvl(BILL_LABOR_HRS          , 0) <> 0 or
          nvl(QUANTITY                , 0) <> 0 or
          nvl(BILL_QUANTITY           , 0) <> 0
      ) fin
      on
      (
        fin.PROJECT_ORG_ID          = fpe.PROJECT_ORG_ID          and
        fin.PROJECT_ORGANIZATION_ID = fpe.PROJECT_ORGANIZATION_ID and
        fin.TIME_ID                 = fpe.TIME_ID                 and
        fin.PROJECT_ID              = fpe.PROJECT_ID              and
        fin.EXP_EVT_TYPE_ID         = fpe.EXP_EVT_TYPE_ID         and
        fin.PERIOD_TYPE_ID          = fpe.PERIOD_TYPE_ID          and
        fin.CALENDAR_TYPE           = fpe.CALENDAR_TYPE           and
        fin.CURR_RECORD_TYPE_ID     = fpe.CURR_RECORD_TYPE_ID     and
        fin.CURRENCY_CODE           = fpe.CURRENCY_CODE           and
        fin.PROJECT_TYPE_CLASS      = fpe.PROJECT_TYPE_CLASS
      )
      when matched then update set
        fpe.REVENUE        = case when fpe.REVENUE is null and
                                       fin.REVENUE is null
                                  then to_number(null)
                                  else nvl(fpe.REVENUE, 0) +
                                       nvl(fin.REVENUE, 0)
                                  end,
        fpe.LABOR_REVENUE  = case when fpe.LABOR_REVENUE is null and
                                       fin.LABOR_REVENUE is null
                                  then to_number(null)
                                  else nvl(fpe.LABOR_REVENUE, 0) +
                                       nvl(fin.LABOR_REVENUE, 0)
                                  end,
        fpe.RAW_COST       = case when fpe.RAW_COST is null and
                                       fin.RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpe.RAW_COST, 0) +
                                       nvl(fin.RAW_COST, 0)
                                  end,
        fpe.BURDENED_COST  = case when fpe.BURDENED_COST is null and
                                       fin.BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpe.BURDENED_COST, 0) +
                                       nvl(fin.BURDENED_COST, 0)
                                  end,
        fpe.BILL_RAW_COST  = case when fpe.BILL_RAW_COST is null and
                                       fin.BILL_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpe.BILL_RAW_COST, 0) +
                                       nvl(fin.BILL_RAW_COST, 0)
                                  end,
        fpe.BILL_BURDENED_COST
                           = case when fpe.BILL_BURDENED_COST is null and
                                       fin.BILL_BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpe.BILL_BURDENED_COST, 0) +
                                       nvl(fin.BILL_BURDENED_COST, 0)
                                  end,
        fpe.CAPITALIZABLE_RAW_COST
                           = case when fpe.CAPITALIZABLE_RAW_COST is null and
                                       fin.CAPITALIZABLE_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpe.CAPITALIZABLE_RAW_COST, 0) +
                                       nvl(fin.CAPITALIZABLE_RAW_COST, 0)
                                  end,
        fpe.CAPITALIZABLE_BRDN_COST
                           = case when fpe.CAPITALIZABLE_BRDN_COST is null and
                                       fin.CAPITALIZABLE_BRDN_COST is null
                                  then to_number(null)
                                  else nvl(fpe.CAPITALIZABLE_BRDN_COST, 0) +
                                       nvl(fin.CAPITALIZABLE_BRDN_COST, 0)
                                  end,
        fpe.LABOR_RAW_COST = case when fpe.LABOR_RAW_COST is null and
                                       fin.LABOR_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpe.LABOR_RAW_COST, 0) +
                                       nvl(fin.LABOR_RAW_COST, 0)
                                  end,
        fpe.LABOR_BURDENED_COST
                           = case when fpe.LABOR_BURDENED_COST is null and
                                       fin.LABOR_BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpe.LABOR_BURDENED_COST, 0) +
                                       nvl(fin.LABOR_BURDENED_COST, 0)
                                  end,
        fpe.BILL_LABOR_RAW_COST
                           = case when fpe.BILL_LABOR_RAW_COST is null and
                                       fin.BILL_LABOR_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpe.BILL_LABOR_RAW_COST, 0) +
                                       nvl(fin.BILL_LABOR_RAW_COST, 0)
                                  end,
        fpe.BILL_LABOR_BURDENED_COST
                           = case when fpe.BILL_LABOR_BURDENED_COST is null and
                                       fin.BILL_LABOR_BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpe.BILL_LABOR_BURDENED_COST, 0) +
                                       nvl(fin.BILL_LABOR_BURDENED_COST, 0)
                                  end,
        fpe.LABOR_HRS      = case when fpe.LABOR_HRS is null and
                                       fin.LABOR_HRS is null
                                  then to_number(null)
                                  else nvl(fpe.LABOR_HRS, 0) +
                                       nvl(fin.LABOR_HRS, 0)
                                  end,
        fpe.BILL_LABOR_HRS = case when fpe.BILL_LABOR_HRS is null and
                                       fin.BILL_LABOR_HRS is null
                                  then to_number(null)
                                  else nvl(fpe.BILL_LABOR_HRS, 0) +
                                       nvl(fin.BILL_LABOR_HRS, 0)
                                  end,
        fpe.QUANTITY       = case when fpe.QUANTITY is null and
                                       fin.QUANTITY is null
                                  then to_number(null)
                                  else nvl(fpe.QUANTITY, 0) +
                                       nvl(fin.QUANTITY, 0)
                                  end,
        fpe.BILL_QUANTITY  = case when fpe.BILL_QUANTITY is null and
                                       fin.BILL_QUANTITY is null
                                  then to_number(null)
                                  else nvl(fpe.BILL_QUANTITY, 0) +
                                       nvl(fin.BILL_QUANTITY, 0)
                                  end,
        fpe.LAST_UPDATE_DATE
                 = fin.LAST_UPDATE_DATE,
        fpe.LAST_UPDATED_BY
                 = fin.LAST_UPDATED_BY,
        fpe.LAST_UPDATE_LOGIN
                 = fin.LAST_UPDATE_LOGIN
      when not matched then insert
      (
        fpe.PROJECT_ORG_ID,
        fpe.PROJECT_ORGANIZATION_ID,
        fpe.TIME_ID,
        fpe.PROJECT_ID,
        fpe.EXP_EVT_TYPE_ID,
        fpe.PERIOD_TYPE_ID,
        fpe.CALENDAR_TYPE,
        fpe.CURR_RECORD_TYPE_ID,
        fpe.CURRENCY_CODE,
        fpe.PROJECT_TYPE_CLASS,
        fpe.REVENUE,
        fpe.LABOR_REVENUE,
        fpe.RAW_COST,
        fpe.BURDENED_COST,
        fpe.BILL_RAW_COST,
        fpe.BILL_BURDENED_COST,
        fpe.CAPITALIZABLE_RAW_COST,
        fpe.CAPITALIZABLE_BRDN_COST,
        fpe.LABOR_RAW_COST,
        fpe.LABOR_BURDENED_COST,
        fpe.BILL_LABOR_RAW_COST,
        fpe.BILL_LABOR_BURDENED_COST,
        fpe.LABOR_HRS,
        fpe.BILL_LABOR_HRS,
        fpe.QUANTITY,
        fpe.BILL_QUANTITY,
        fpe.LAST_UPDATE_DATE,
        fpe.LAST_UPDATED_BY,
        fpe.CREATION_DATE,
        fpe.CREATED_BY,
        fpe.LAST_UPDATE_LOGIN
      )
      values
      (
        fin.PROJECT_ORG_ID,
        fin.PROJECT_ORGANIZATION_ID,
        fin.TIME_ID,
        fin.PROJECT_ID,
        fin.EXP_EVT_TYPE_ID,
        fin.PERIOD_TYPE_ID,
        fin.CALENDAR_TYPE,
        fin.CURR_RECORD_TYPE_ID,
        fin.CURRENCY_CODE,
        fin.PROJECT_TYPE_CLASS,
        fin.REVENUE,
        fin.LABOR_REVENUE,
        fin.RAW_COST,
        fin.BURDENED_COST,
        fin.BILL_RAW_COST,
        fin.BILL_BURDENED_COST,
        fin.CAPITALIZABLE_RAW_COST,
        fin.CAPITALIZABLE_BRDN_COST,
        fin.LABOR_RAW_COST,
        fin.LABOR_BURDENED_COST,
        fin.BILL_LABOR_RAW_COST,
        fin.BILL_LABOR_BURDENED_COST,
        fin.LABOR_HRS,
        fin.BILL_LABOR_HRS,
        fin.QUANTITY,
        fin.BILL_QUANTITY,
        fin.LAST_UPDATE_DATE,
        fin.LAST_UPDATED_BY,
        fin.CREATION_DATE,
        fin.CREATED_BY,
        fin.LAST_UPDATE_LOGIN
      );

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_FIN.MERGE_FIN_INTO_FPE(p_worker_id);'
    );

    -- truncate intermediate tables no longer required
    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema , 'PJI_FM_AGGR_FIN5' , 'NORMAL',null);

    commit;

  end MERGE_FIN_INTO_FPE;


  -- -----------------------------------------------------
  -- procedure MERGE_FIN_INTO_FPP
  -- -----------------------------------------------------
  procedure MERGE_FIN_INTO_FPP (p_worker_id in number) is

    l_process              varchar2(30);
    l_extraction_type      varchar2(30);
    l_last_update_date     date;
    l_last_updated_by      number;
    l_creation_date        date;
    l_created_by           number;
    l_last_update_login    number;
    l_schema               varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_FIN.MERGE_FIN_INTO_FPP(p_worker_id);'
            )) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (l_extraction_type = 'FULL') then

      insert /*+ append parallel(fpp) */ into PJI_FP_PROJ_F fpp
      (
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        TIME_ID,
        PROJECT_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        PROJECT_TYPE_CLASS,
        REVENUE,
        LABOR_REVENUE,
        RAW_COST,
        BURDENED_COST,
        BILL_RAW_COST,
        BILL_BURDENED_COST,
        CAPITALIZABLE_RAW_COST,
        CAPITALIZABLE_BRDN_COST,
        LABOR_RAW_COST,
        LABOR_BURDENED_COST,
        BILL_LABOR_RAW_COST,
        BILL_LABOR_BURDENED_COST,
        REVENUE_WRITEOFF,
        LABOR_HRS,
        BILL_LABOR_HRS,
        CURR_BGT_REVENUE,
        CURR_BGT_RAW_COST,
        CURR_BGT_BURDENED_COST,
        CURR_BGT_LABOR_HRS,
        ORIG_BGT_REVENUE,
        ORIG_BGT_RAW_COST,
        ORIG_BGT_BURDENED_COST,
        ORIG_BGT_LABOR_HRS,
        FORECAST_REVENUE,
        FORECAST_RAW_COST,
        FORECAST_BURDENED_COST,
        FORECAST_LABOR_HRS,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ full(fin3)  parallel(fin3)  */
        fin3.PROJECT_ORG_ID,
        fin3.PROJECT_ORGANIZATION_ID,
        fin3.TIME_ID,
        fin3.PROJECT_ID,
        fin3.PERIOD_TYPE_ID,
        fin3.CALENDAR_TYPE,
        fin3.CURR_RECORD_TYPE_ID,
        fin3.CURRENCY_CODE,
        fin3.PROJECT_TYPE_CLASS,
        fin3.REVENUE,
        fin3.LABOR_REVENUE,
        fin3.RAW_COST,
        fin3.BURDENED_COST,
        decode(fin3.PROJECT_TYPE_CLASS,
               'B', fin3.BILL_RAW_COST,
                    to_number(null))         BILL_RAW_COST,
        decode(fin3.Project_Type_Class,
               'B', fin3.BILL_BURDENED_COST,
                    to_number(null))         BILL_BURDENED_COST,
        decode(fin3.PROJECT_TYPE_CLASS,
               'C', fin3.BILL_RAW_COST,
                    to_number(null))         CAPITALIZABLE_RAW_COST,
        decode(fin3.PROJECT_TYPE_CLASS,
               'C', fin3.BILL_BURDENED_COST,
                    to_number(null))         CAPITALIZABLE_BRDN_COST,
        fin3.LABOR_RAW_COST,
        fin3.LABOR_BURDENED_COST,
        fin3.BILL_LABOR_RAW_COST,
        fin3.BILL_LABOR_BURDENED_COST,
        fin3.REVENUE_WRITEOFF,
        fin3.LABOR_HRS,
        fin3.BILL_LABOR_HRS,
        fin3.CURR_BGT_REVENUE,
        fin3.CURR_BGT_RAW_COST,
        fin3.CURR_BGT_BURDENED_COST,
        fin3.CURR_BGT_LABOR_HRS,
        fin3.ORIG_BGT_REVENUE,
        fin3.ORIG_BGT_RAW_COST,
        fin3.ORIG_BGT_BURDENED_COST,
        fin3.ORIG_BGT_LABOR_HRS,
        fin3.FORECAST_REVENUE,
        fin3.FORECAST_RAW_COST,
        fin3.FORECAST_BURDENED_COST,
        fin3.FORECAST_LABOR_HRS,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PJI_FM_AGGR_FIN3 fin3
      where
        fin3.WORKER_ID = p_worker_id and
        (nvl(fin3.REVENUE                 , 0) <> 0 or
         nvl(fin3.LABOR_REVENUE           , 0) <> 0 or
         nvl(fin3.RAW_COST                , 0) <> 0 or
         nvl(fin3.BURDENED_COST           , 0) <> 0 or
         nvl(fin3.BILL_RAW_COST           , 0) <> 0 or
         nvl(fin3.BILL_BURDENED_COST      , 0) <> 0 or
         nvl(fin3.LABOR_RAW_COST          , 0) <> 0 or
         nvl(fin3.LABOR_BURDENED_COST     , 0) <> 0 or
         nvl(fin3.BILL_LABOR_RAW_COST     , 0) <> 0 or
         nvl(fin3.BILL_LABOR_BURDENED_COST, 0) <> 0 or
         nvl(fin3.REVENUE_WRITEOFF        , 0) <> 0 or
         nvl(fin3.LABOR_HRS               , 0) <> 0 or
         nvl(fin3.BILL_LABOR_HRS          , 0) <> 0 or
         nvl(fin3.CURR_BGT_REVENUE        , 0) <> 0 or
         nvl(fin3.CURR_BGT_RAW_COST       , 0) <> 0 or
         nvl(fin3.CURR_BGT_BURDENED_COST  , 0) <> 0 or
         nvl(fin3.CURR_BGT_LABOR_HRS      , 0) <> 0 or
         nvl(fin3.ORIG_BGT_REVENUE        , 0) <> 0 or
         nvl(fin3.ORIG_BGT_RAW_COST       , 0) <> 0 or
         nvl(fin3.ORIG_BGT_BURDENED_COST  , 0) <> 0 or
         nvl(fin3.ORIG_BGT_LABOR_HRS      , 0) <> 0 or
         nvl(fin3.FORECAST_REVENUE        , 0) <> 0 or
         nvl(fin3.FORECAST_RAW_COST       , 0) <> 0 or
         nvl(fin3.FORECAST_BURDENED_COST  , 0) <> 0 or
         nvl(fin3.FORECAST_LABOR_HRS      , 0) <> 0);

    else -- not initial data load

      merge /*+ parallel(fpp) */ into PJI_FP_PROJ_F fpp
      using
      (
        select
          PROJECT_ORG_ID,
          PROJECT_ORGANIZATION_ID,
          TIME_ID,
          PROJECT_ID,
          PERIOD_TYPE_ID,
          CALENDAR_TYPE,
          CURR_RECORD_TYPE_ID,
          CURRENCY_CODE,
          PROJECT_TYPE_CLASS,
          REVENUE,
          LABOR_REVENUE,
          RAW_COST,
          BURDENED_COST,
          BILL_RAW_COST,
          BILL_BURDENED_COST,
          CAPITALIZABLE_RAW_COST,
          CAPITALIZABLE_BRDN_COST,
          LABOR_RAW_COST,
          LABOR_BURDENED_COST,
          BILL_LABOR_RAW_COST,
          BILL_LABOR_BURDENED_COST,
          REVENUE_WRITEOFF,
          LABOR_HRS,
          BILL_LABOR_HRS,
          CURR_BGT_REVENUE,
          CURR_BGT_RAW_COST,
          CURR_BGT_BURDENED_COST,
          CURR_BGT_LABOR_HRS,
          ORIG_BGT_REVENUE,
          ORIG_BGT_RAW_COST,
          ORIG_BGT_BURDENED_COST,
          ORIG_BGT_LABOR_HRS,
          FORECAST_REVENUE,
          FORECAST_RAW_COST,
          FORECAST_BURDENED_COST,
          FORECAST_LABOR_HRS,
          l_last_update_date            LAST_UPDATE_DATE,
          l_last_updated_by             LAST_UPDATED_BY,
          l_creation_date               CREATION_DATE,
          l_created_by                  CREATED_BY,
          l_last_update_login           LAST_UPDATE_LOGIN
        from
          (
          select
            PROJECT_ORG_ID,
            PROJECT_ORGANIZATION_ID,
            TIME_ID,
            PROJECT_ID,
            PERIOD_TYPE_ID,
            CALENDAR_TYPE,
            CURR_RECORD_TYPE_ID,
            CURRENCY_CODE,
            PROJECT_TYPE_CLASS,
            sum(REVENUE)                  REVENUE,
            sum(LABOR_REVENUE)            LABOR_REVENUE,
            sum(RAW_COST)                 RAW_COST,
            sum(BURDENED_COST)            BURDENED_COST,
            sum(BILL_RAW_COST)            BILL_RAW_COST,
            sum(BILL_BURDENED_COST)       BILL_BURDENED_COST,
            sum(CAPITALIZABLE_RAW_COST)   CAPITALIZABLE_RAW_COST,
            sum(CAPITALIZABLE_BRDN_COST)  CAPITALIZABLE_BRDN_COST,
            sum(LABOR_RAW_COST)           LABOR_RAW_COST,
            sum(LABOR_BURDENED_COST)      LABOR_BURDENED_COST,
            sum(BILL_LABOR_RAW_COST)      BILL_LABOR_RAW_COST,
            sum(BILL_LABOR_BURDENED_COST) BILL_LABOR_BURDENED_COST,
            sum(REVENUE_WRITEOFF)         REVENUE_WRITEOFF,
            sum(LABOR_HRS)                LABOR_HRS,
            sum(BILL_LABOR_HRS)           BILL_LABOR_HRS,
            sum(CURR_BGT_REVENUE)         CURR_BGT_REVENUE,
            sum(CURR_BGT_RAW_COST)        CURR_BGT_RAW_COST,
            sum(CURR_BGT_BURDENED_COST)   CURR_BGT_BURDENED_COST,
            sum(CURR_BGT_LABOR_HRS)       CURR_BGT_LABOR_HRS,
            sum(ORIG_BGT_REVENUE)         ORIG_BGT_REVENUE,
            sum(ORIG_BGT_RAW_COST)        ORIG_BGT_RAW_COST,
            sum(ORIG_BGT_BURDENED_COST)   ORIG_BGT_BURDENED_COST,
            sum(ORIG_BGT_LABOR_HRS)       ORIG_BGT_LABOR_HRS,
            sum(FORECAST_REVENUE)         FORECAST_REVENUE,
            sum(FORECAST_RAW_COST)        FORECAST_RAW_COST,
            sum(FORECAST_BURDENED_COST)   FORECAST_BURDENED_COST,
            sum(FORECAST_LABOR_HRS)       FORECAST_LABOR_HRS
          from
            (
            select /*+ full(fin3)   parallel(fin3)  */
              fin3.PROJECT_ORG_ID,
              fin3.PROJECT_ORGANIZATION_ID,
              fin3.TIME_ID,
              fin3.PROJECT_ID,
              fin3.PERIOD_TYPE_ID,
              fin3.CALENDAR_TYPE,
              fin3.CURR_RECORD_TYPE_ID,
              fin3.CURRENCY_CODE,
              fin3.PROJECT_TYPE_CLASS,
              fin3.REVENUE,
              fin3.LABOR_REVENUE,
              fin3.RAW_COST,
              fin3.BURDENED_COST,
              decode(fin3.PROJECT_TYPE_CLASS,
                     'B', fin3.BILL_RAW_COST,
                          to_number(null))         BILL_RAW_COST,
              decode(fin3.Project_Type_Class,
                     'B', fin3.BILL_BURDENED_COST,
                          to_number(null))         BILL_BURDENED_COST,
              decode(fin3.PROJECT_TYPE_CLASS,
                     'C', fin3.BILL_RAW_COST,
                          to_number(null))         CAPITALIZABLE_RAW_COST,
              decode(fin3.PROJECT_TYPE_CLASS,
                     'C', fin3.BILL_BURDENED_COST,
                          to_number(null))         CAPITALIZABLE_BRDN_COST,
              fin3.LABOR_RAW_COST,
              fin3.LABOR_BURDENED_COST,
              fin3.BILL_LABOR_RAW_COST,
              fin3.BILL_LABOR_BURDENED_COST,
              fin3.REVENUE_WRITEOFF,
              fin3.LABOR_HRS,
              fin3.BILL_LABOR_HRS,
              fin3.CURR_BGT_REVENUE,
              fin3.CURR_BGT_RAW_COST,
              fin3.CURR_BGT_BURDENED_COST,
              fin3.CURR_BGT_LABOR_HRS,
              fin3.ORIG_BGT_REVENUE,
              fin3.ORIG_BGT_RAW_COST,
              fin3.ORIG_BGT_BURDENED_COST,
              fin3.ORIG_BGT_LABOR_HRS,
              fin3.FORECAST_REVENUE,
              fin3.FORECAST_RAW_COST,
              fin3.FORECAST_BURDENED_COST,
              fin3.FORECAST_LABOR_HRS
            from
              PJI_FM_AGGR_FIN3 fin3
            where
              fin3.WORKER_ID = p_worker_id
            union all                       -- partial refresh
            select /*+ ordered full(map) parallel(map)
                               index(fpp, PJI_FP_PROJ_F_N2) use_nl(fpp) */
              fpp.PROJECT_ORG_ID,
              fpp.PROJECT_ORGANIZATION_ID,
              fpp.TIME_ID,
              fpp.PROJECT_ID,
              fpp.PERIOD_TYPE_ID,
              fpp.CALENDAR_TYPE,
              fpp.CURR_RECORD_TYPE_ID,
              fpp.CURRENCY_CODE,
              fpp.PROJECT_TYPE_CLASS,
              -fpp.REVENUE,
              -fpp.LABOR_REVENUE,
              -fpp.RAW_COST,
              -fpp.BURDENED_COST,
              -fpp.BILL_RAW_COST,
              -fpp.BILL_BURDENED_COST,
              -fpp.CAPITALIZABLE_RAW_COST,
              -fpp.CAPITALIZABLE_BRDN_COST,
              -fpp.LABOR_RAW_COST,
              -fpp.LABOR_BURDENED_COST,
              -fpp.BILL_LABOR_RAW_COST,
              -fpp.BILL_LABOR_BURDENED_COST,
              -fpp.REVENUE_WRITEOFF,
              -fpp.LABOR_HRS,
              -fpp.BILL_LABOR_HRS,
              to_number(null) CURR_BGT_REVENUE,
              to_number(null) CURR_BGT_RAW_COST,
              to_number(null) CURR_BGT_BURDENED_COST,
              to_number(null) CURR_BGT_LABOR_HRS,
              to_number(null) ORIG_BGT_REVENUE,
              to_number(null) ORIG_BGT_RAW_COST,
              to_number(null) ORIG_BGT_BURDENED_COST,
              to_number(null) ORIG_BGT_LABOR_HRS,
              to_number(null) FORECAST_REVENUE,
              to_number(null) FORECAST_RAW_COST,
              to_number(null) FORECAST_BURDENED_COST,
              to_number(null) FORECAST_LABOR_HRS
            from
              PJI_PJI_PROJ_BATCH_MAP map,
              PJI_FP_PROJ_F fpp
            where
              l_extraction_type   = 'PARTIAL'   and
              map.WORKER_ID       = p_worker_id and
              map.EXTRACTION_TYPE = 'P'         and
              fpp.PROJECT_ID      = map.PROJECT_ID
            )
          group by
            PROJECT_ORG_ID,
            PROJECT_ORGANIZATION_ID,
            TIME_ID,
            PROJECT_ID,
            PERIOD_TYPE_ID,
            CALENDAR_TYPE,
            CURR_RECORD_TYPE_ID,
            CURRENCY_CODE,
            PROJECT_TYPE_CLASS
          )
        where
          nvl(REVENUE                 , 0) <> 0 or
          nvl(LABOR_REVENUE           , 0) <> 0 or
          nvl(RAW_COST                , 0) <> 0 or
          nvl(BURDENED_COST           , 0) <> 0 or
          nvl(BILL_RAW_COST           , 0) <> 0 or
          nvl(BILL_BURDENED_COST      , 0) <> 0 or
          nvl(CAPITALIZABLE_RAW_COST  , 0) <> 0 or
          nvl(CAPITALIZABLE_BRDN_COST , 0) <> 0 or
          nvl(LABOR_RAW_COST          , 0) <> 0 or
          nvl(LABOR_BURDENED_COST     , 0) <> 0 or
          nvl(BILL_LABOR_RAW_COST     , 0) <> 0 or
          nvl(BILL_LABOR_BURDENED_COST, 0) <> 0 or
          nvl(REVENUE_WRITEOFF        , 0) <> 0 or
          nvl(LABOR_HRS               , 0) <> 0 or
          nvl(BILL_LABOR_HRS          , 0) <> 0 or
          nvl(CURR_BGT_REVENUE        , 0) <> 0 or
          nvl(CURR_BGT_RAW_COST       , 0) <> 0 or
          nvl(CURR_BGT_BURDENED_COST  , 0) <> 0 or
          nvl(CURR_BGT_LABOR_HRS      , 0) <> 0 or
          nvl(ORIG_BGT_REVENUE        , 0) <> 0 or
          nvl(ORIG_BGT_RAW_COST       , 0) <> 0 or
          nvl(ORIG_BGT_BURDENED_COST  , 0) <> 0 or
          nvl(ORIG_BGT_LABOR_HRS      , 0) <> 0 or
          nvl(FORECAST_REVENUE        , 0) <> 0 or
          nvl(FORECAST_RAW_COST       , 0) <> 0 or
          nvl(FORECAST_BURDENED_COST  , 0) <> 0 or
          nvl(FORECAST_LABOR_HRS      , 0) <> 0
      ) fin
      on
      (
        fin.PROJECT_ORG_ID          = fpp.PROJECT_ORG_ID          and
        fin.PROJECT_ORGANIZATION_ID = fpp.PROJECT_ORGANIZATION_ID and
        fin.TIME_ID                 = fpp.TIME_ID                 and
        fin.PROJECT_ID              = fpp.PROJECT_ID              and
        fin.PERIOD_TYPE_ID          = fpp.PERIOD_TYPE_ID          and
        fin.CALENDAR_TYPE           = fpp.CALENDAR_TYPE           and
        fin.CURR_RECORD_TYPE_ID     = fpp.CURR_RECORD_TYPE_ID     and
        fin.CURRENCY_CODE           = fpp.CURRENCY_CODE           and
        fin.PROJECT_TYPE_CLASS      = fpp.PROJECT_TYPE_CLASS
      )
      when matched then update set
        fpp.REVENUE        = case when fpp.REVENUE is null and
                                       fin.REVENUE is null
                                  then to_number(null)
                                  else nvl(fpp.REVENUE, 0) +
                                       nvl(fin.REVENUE, 0)
                                  end,
        fpp.LABOR_REVENUE  = case when fpp.LABOR_REVENUE is null and
                                       fin.LABOR_REVENUE is null
                                  then to_number(null)
                                  else nvl(fpp.LABOR_REVENUE, 0) +
                                       nvl(fin.LABOR_REVENUE, 0)
                                  end,
        fpp.RAW_COST       = case when fpp.RAW_COST is null and
                                       fin.RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpp.RAW_COST, 0) +
                                       nvl(fin.RAW_COST, 0)
                                  end,
        fpp.BURDENED_COST  = case when fpp.BURDENED_COST is null and
                                       fin.BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpp.BURDENED_COST, 0) +
                                       nvl(fin.BURDENED_COST, 0)
                                  end,
        fpp.BILL_RAW_COST  = case when fpp.BILL_RAW_COST is null and
                                       fin.BILL_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpp.BILL_RAW_COST, 0) +
                                       nvl(fin.BILL_RAW_COST, 0)
                                  end,
        fpp.BILL_BURDENED_COST
                           = case when fpp.BILL_BURDENED_COST is null and
                                       fin.BILL_BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpp.BILL_BURDENED_COST, 0) +
                                       nvl(fin.BILL_BURDENED_COST, 0)
                                  end,
        fpp.CAPITALIZABLE_RAW_COST
                           = case when fpp.CAPITALIZABLE_RAW_COST is null and
                                       fin.CAPITALIZABLE_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpp.CAPITALIZABLE_RAW_COST, 0) +
                                       nvl(fin.CAPITALIZABLE_RAW_COST, 0)
                                  end,
        fpp.CAPITALIZABLE_BRDN_COST
                           = case when fpp.CAPITALIZABLE_BRDN_COST is null and
                                       fin.CAPITALIZABLE_BRDN_COST is null
                                  then to_number(null)
                                  else nvl(fpp.CAPITALIZABLE_BRDN_COST, 0) +
                                       nvl(fin.CAPITALIZABLE_BRDN_COST, 0)
                                  end,
        fpp.LABOR_RAW_COST = case when fpp.LABOR_RAW_COST is null and
                                       fin.LABOR_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpp.LABOR_RAW_COST, 0) +
                                       nvl(fin.LABOR_RAW_COST, 0)
                                  end,
        fpp.LABOR_BURDENED_COST
                           = case when fpp.LABOR_BURDENED_COST is null and
                                       fin.LABOR_BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpp.LABOR_BURDENED_COST, 0) +
                                       nvl(fin.LABOR_BURDENED_COST, 0)
                                  end,
        fpp.BILL_LABOR_RAW_COST
                           = case when fpp.BILL_LABOR_RAW_COST is null and
                                       fin.BILL_LABOR_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpp.BILL_LABOR_RAW_COST, 0) +
                                       nvl(fin.BILL_LABOR_RAW_COST, 0)
                                  end,
        fpp.BILL_LABOR_BURDENED_COST
                           = case when fpp.BILL_LABOR_BURDENED_COST is null and
                                       fin.BILL_LABOR_BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpp.BILL_LABOR_BURDENED_COST, 0) +
                                       nvl(fin.BILL_LABOR_BURDENED_COST, 0)
                                  end,
        fpp.REVENUE_WRITEOFF
                           = case when fpp.REVENUE_WRITEOFF is null and
                                       fin.REVENUE_WRITEOFF is null
                                  then to_number(null)
                                  else nvl(fpp.REVENUE_WRITEOFF, 0) +
                                       nvl(fin.REVENUE_WRITEOFF, 0)
                                  end,
        fpp.LABOR_HRS      = case when fpp.LABOR_HRS is null and
                                       fin.LABOR_HRS is null
                                  then to_number(null)
                                  else nvl(fpp.LABOR_HRS, 0) +
                                       nvl(fin.LABOR_HRS, 0)
                                  end,
        fpp.BILL_LABOR_HRS = case when fpp.BILL_LABOR_HRS is null and
                                       fin.BILL_LABOR_HRS is null
                                  then to_number(null)
                                  else nvl(fpp.BILL_LABOR_HRS, 0) +
                                       nvl(fin.BILL_LABOR_HRS, 0)
                                  end,
        fpp.CURR_BGT_REVENUE
                           = case when fpp.CURR_BGT_REVENUE is null and
                                       fin.CURR_BGT_REVENUE is null
                                  then to_number(null)
                                  else nvl(fpp.CURR_BGT_REVENUE, 0) +
                                       nvl(fin.CURR_BGT_REVENUE, 0)
                                  end,
        fpp.CURR_BGT_RAW_COST
                           = case when fpp.CURR_BGT_RAW_COST is null and
                                       fin.CURR_BGT_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpp.CURR_BGT_RAW_COST, 0) +
                                       nvl(fin.CURR_BGT_RAW_COST, 0)
                                  end,
        fpp.CURR_BGT_BURDENED_COST
                           = case when fpp.CURR_BGT_BURDENED_COST is null and
                                       fin.CURR_BGT_BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpp.CURR_BGT_BURDENED_COST, 0) +
                                       nvl(fin.CURR_BGT_BURDENED_COST, 0)
                                  end,
        fpp.CURR_BGT_LABOR_HRS
                           = case when fpp.CURR_BGT_LABOR_HRS is null and
                                       fin.CURR_BGT_LABOR_HRS is null
                                  then to_number(null)
                                  else nvl(fpp.CURR_BGT_LABOR_HRS, 0) +
                                       nvl(fin.CURR_BGT_LABOR_HRS, 0)
                                  end,
        fpp.ORIG_BGT_REVENUE
                           = case when fpp.ORIG_BGT_REVENUE is null and
                                       fin.ORIG_BGT_REVENUE is null
                                  then to_number(null)
                                  else nvl(fpp.ORIG_BGT_REVENUE, 0) +
                                       nvl(fin.ORIG_BGT_REVENUE, 0)
                                  end,
        fpp.ORIG_BGT_RAW_COST
                           = case when fpp.ORIG_BGT_RAW_COST is null and
                                       fin.ORIG_BGT_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpp.ORIG_BGT_RAW_COST, 0) +
                                       nvl(fin.ORIG_BGT_RAW_COST, 0)
                                  end,
        fpp.ORIG_BGT_BURDENED_COST
                           = case when fpp.ORIG_BGT_BURDENED_COST is null and
                                       fin.ORIG_BGT_BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpp.ORIG_BGT_BURDENED_COST, 0) +
                                       nvl(fin.ORIG_BGT_BURDENED_COST, 0)
                                  end,
        fpp.ORIG_BGT_LABOR_HRS
                           = case when fpp.ORIG_BGT_LABOR_HRS is null and
                                       fin.ORIG_BGT_LABOR_HRS is null
                                  then to_number(null)
                                  else nvl(fpp.ORIG_BGT_LABOR_HRS, 0) +
                                       nvl(fin.ORIG_BGT_LABOR_HRS, 0)
                                  end,
        fpp.FORECAST_REVENUE
                           = case when fpp.FORECAST_REVENUE is null and
                                       fin.FORECAST_REVENUE is null
                                  then to_number(null)
                                  else nvl(fpp.FORECAST_REVENUE, 0) +
                                       nvl(fin.FORECAST_REVENUE, 0)
                                  end,
        fpp.FORECAST_RAW_COST
                           = case when fpp.FORECAST_RAW_COST is null and
                                       fin.FORECAST_RAW_COST is null
                                  then to_number(null)
                                  else nvl(fpp.FORECAST_RAW_COST, 0) +
                                       nvl(fin.FORECAST_RAW_COST, 0)
                                  end,
        fpp.FORECAST_BURDENED_COST
                           = case when fpp.FORECAST_BURDENED_COST is null and
                                       fin.FORECAST_BURDENED_COST is null
                                  then to_number(null)
                                  else nvl(fpp.FORECAST_BURDENED_COST, 0) +
                                       nvl(fin.FORECAST_BURDENED_COST, 0)
                                  end,
        fpp.FORECAST_LABOR_HRS
                           = case when fpp.FORECAST_LABOR_HRS is null and
                                       fin.FORECAST_LABOR_HRS is null
                                  then to_number(null)
                                  else nvl(fpp.FORECAST_LABOR_HRS, 0) +
                                       nvl(fin.FORECAST_LABOR_HRS, 0)
                                  end,
        fpp.LAST_UPDATE_DATE
                 = fin.LAST_UPDATE_DATE,
        fpp.LAST_UPDATED_BY
                 = fin.LAST_UPDATED_BY,
        fpp.LAST_UPDATE_LOGIN
                 = fin.LAST_UPDATE_LOGIN
      when not matched then insert
      (
        fpp.PROJECT_ORG_ID,
        fpp.PROJECT_ORGANIZATION_ID,
        fpp.TIME_ID,
        fpp.PROJECT_ID,
        fpp.PERIOD_TYPE_ID,
        fpp.CALENDAR_TYPE,
        fpp.CURR_RECORD_TYPE_ID,
        fpp.CURRENCY_CODE,
        fpp.PROJECT_TYPE_CLASS,
        fpp.REVENUE,
        fpp.LABOR_REVENUE,
        fpp.RAW_COST,
        fpp.BURDENED_COST,
        fpp.BILL_RAW_COST,
        fpp.BILL_BURDENED_COST,
        fpp.CAPITALIZABLE_RAW_COST,
        fpp.CAPITALIZABLE_BRDN_COST,
        fpp.LABOR_RAW_COST,
        fpp.LABOR_BURDENED_COST,
        fpp.BILL_LABOR_RAW_COST,
        fpp.BILL_LABOR_BURDENED_COST,
        fpp.REVENUE_WRITEOFF,
        fpp.LABOR_HRS,
        fpp.BILL_LABOR_HRS,
        fpp.CURR_BGT_REVENUE,
        fpp.CURR_BGT_RAW_COST,
        fpp.CURR_BGT_BURDENED_COST,
        fpp.CURR_BGT_LABOR_HRS,
        fpp.ORIG_BGT_REVENUE,
        fpp.ORIG_BGT_RAW_COST,
        fpp.ORIG_BGT_BURDENED_COST,
        fpp.ORIG_BGT_LABOR_HRS,
        fpp.FORECAST_REVENUE,
        fpp.FORECAST_RAW_COST,
        fpp.FORECAST_BURDENED_COST,
        fpp.FORECAST_LABOR_HRS,
        fpp.LAST_UPDATE_DATE,
        fpp.LAST_UPDATED_BY,
        fpp.CREATION_DATE,
        fpp.CREATED_BY,
        fpp.LAST_UPDATE_LOGIN
      )
      values
      (
        fin.PROJECT_ORG_ID,
        fin.PROJECT_ORGANIZATION_ID,
        fin.TIME_ID,
        fin.PROJECT_ID,
        fin.PERIOD_TYPE_ID,
        fin.CALENDAR_TYPE,
        fin.CURR_RECORD_TYPE_ID,
        fin.CURRENCY_CODE,
        fin.PROJECT_TYPE_CLASS,
        fin.REVENUE,
        fin.LABOR_REVENUE,
        fin.RAW_COST,
        fin.BURDENED_COST,
        fin.BILL_RAW_COST,
        fin.BILL_BURDENED_COST,
        fin.CAPITALIZABLE_RAW_COST,
        fin.CAPITALIZABLE_BRDN_COST,
        fin.LABOR_RAW_COST,
        fin.LABOR_BURDENED_COST,
        fin.BILL_LABOR_RAW_COST,
        fin.BILL_LABOR_BURDENED_COST,
        fin.REVENUE_WRITEOFF,
        fin.LABOR_HRS,
        fin.BILL_LABOR_HRS,
        fin.CURR_BGT_REVENUE,
        fin.CURR_BGT_RAW_COST,
        fin.CURR_BGT_BURDENED_COST,
        fin.CURR_BGT_LABOR_HRS,
        fin.ORIG_BGT_REVENUE,
        fin.ORIG_BGT_RAW_COST,
        fin.ORIG_BGT_BURDENED_COST,
        fin.ORIG_BGT_LABOR_HRS,
        fin.FORECAST_REVENUE,
        fin.FORECAST_RAW_COST,
        fin.FORECAST_BURDENED_COST,
        fin.FORECAST_LABOR_HRS,
        fin.LAST_UPDATE_DATE,
        fin.LAST_UPDATED_BY,
        fin.CREATION_DATE,
        fin.CREATED_BY,
        fin.LAST_UPDATE_LOGIN
      );

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_FIN.MERGE_FIN_INTO_FPP(p_worker_id);'
    );

    -- truncate intermediate tables no longer required
    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema , 'PJI_FM_AGGR_FIN3' , 'NORMAL',null);

    commit;

  end MERGE_FIN_INTO_FPP;


  -- -----------------------------------------------------
  -- procedure PROJECT_ORGANIZATION
  -- -----------------------------------------------------
  procedure PROJECT_ORGANIZATION (p_worker_id in number) is

    l_process  varchar2(30);

       CURSOR update_scope(c_worker_id number)
       IS
         SELECT
                 map.PROJECT_ID
                 , map.NEW_PROJECT_ORGANIZATION_ID
         FROM    PJI_PJI_PROJ_BATCH_MAP   map
         WHERE   1=1
           AND   map.WORKER_ID = c_worker_id
           AND   map.PROJECT_ORGANIZATION_ID <> map.NEW_PROJECT_ORGANIZATION_ID
         ;

   /*
    * Define PL/SQL Table for storing values.
    */
    L_NEW_ORGZ_TAB       PA_PLSQL_DATATYPES.IdTabTyp;
    L_PROJECT_TAB        PA_PLSQL_DATATYPES.IdTabTyp;

   /*
    * Define other variable to be used in this procedure
    */
    l_this_fetch            NUMBER:=0;
    l_totally_fetched       NUMBER:=0;
    l_last_fetch            VARCHAR2(1):='N';
    I                       PLS_INTEGER;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_FIN.PROJECT_ORGANIZATION(p_worker_id);'
            )) then
      return;
    end if;

      IF    update_scope%ISOPEN then
            CLOSE update_scope;
      END IF;
      OPEN update_scope(p_worker_id);

      LOOP
             /*
              * Clear all PL/SQL table.
              */
             L_NEW_ORGZ_TAB.delete;
             L_PROJECT_TAB.delete;

            /*
             * Fetch 1000 records at a time.
             */
             FETCH update_scope BULK COLLECT
             INTO
             L_PROJECT_TAB
             , L_NEW_ORGZ_TAB    LIMIT 1000;

            /*
             *  To check the rows fetched in this fetch
             */
                l_this_fetch := update_scope%ROWCOUNT - l_totally_fetched;
                l_totally_fetched := update_scope%ROWCOUNT;

            /*
             *  Check if this fetch has 0 rows returned (ie last fetch was
             *                                           even 1000)
             *  This could happen in 2 cases
             *      1) this fetch is the very first fetch with 0 rows returned
             *   OR 2) the last fetch returned an even 1000 rows
             *  If either then EXIT without any processing
             */
                IF  l_this_fetch = 0 then
                        EXIT;
                END IF;

            /*
             *  Check if this fetch is the last fetch
             *  If so then set the flag l_last_fetch so as to exit after
             *  processing
             */
                IF  l_this_fetch < 1000  then
                      l_last_fetch := 'Y';
                ELSE
                      l_last_fetch := 'N';
                END IF;

             FORALL I in L_PROJECT_TAB.FIRST..L_PROJECT_TAB.LAST
             Update PJI_FP_PROJ_ET_WT_F
                Set PROJECT_ORGANIZATION_ID = L_NEW_ORGZ_TAB(I)
              Where PROJECT_ID              = L_PROJECT_TAB(I)
             ;

             FORALL I in L_PROJECT_TAB.FIRST..L_PROJECT_TAB.LAST
             Update PJI_FP_PROJ_ET_F
                Set PROJECT_ORGANIZATION_ID = L_NEW_ORGZ_TAB(I)
              Where PROJECT_ID              = L_PROJECT_TAB(I)
             ;

             FORALL I in L_PROJECT_TAB.FIRST..L_PROJECT_TAB.LAST
             Update PJI_FP_PROJ_F
                Set PROJECT_ORGANIZATION_ID = L_NEW_ORGZ_TAB(I)
              Where PROJECT_ID              = L_PROJECT_TAB(I)
             ;

            /*
             *  Check if this loop is the last set of 100
             *  If so then EXIT;
             */
                IF l_last_fetch='Y' THEN
                       EXIT;
                END IF;

      END LOOP;

      CLOSE update_scope;


    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_FIN.PROJECT_ORGANIZATION(p_worker_id);'
    );

    commit;

  end PROJECT_ORGANIZATION;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_FWO
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_FWO (p_worker_id in number) is

    l_process          varchar2(30);
    l_extraction_type  varchar2(30);
    l_pji_schema       varchar2(30);
    l_apps_schema      varchar2(30);
    l_p_degree         number := 0;
    l_params_util_flag varchar2(1);

    l_errbuf             varchar2(255);
    l_retcode            varchar2(255);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FWO(p_worker_id);'
            )) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    if (upper(nvl(FND_PROFILE.VALUE('PJI_USE_DBI_RSG'), 'N')) = 'Y' and
        l_extraction_type <> 'PARTIAL') then
      return;
    end if;

    l_pji_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    l_apps_schema := PJI_UTILS.GET_APPS_SCHEMA_NAME;
    l_p_degree := BIS_COMMON_PARAMETERS.GET_DEGREE_OF_PARALLELISM();
    if (l_p_degree = 1) then
      l_p_degree := 0;
    end if;

    /*
    l_params_util_flag :=
      nvl(PJI_UTILS.GET_PARAMETER('CONFIG_UTIL_FLAG'),
      nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_top_process,
          'CONFIG_UTIL_FLAG'), 'N'));

    if (l_params_util_flag = 'N') then
    FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pji_schema,
                                 TABNAME => 'PJI_ORG_DENORM',
                                 PERCENT => 10,
                                 DEGREE  => l_p_degree);
    end if;
    */

    if (l_extraction_type = 'FULL') then
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_ORG_ET_WT_F_MV',
                              'C',
                              'N');
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_ORGO_ET_WT_F_MV',
                              'C',
                              'N');
    else
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pji_schema,
                                   TABNAME => 'MLOG$_PJI_FP_PROJ_ET_WT_F',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_ORG_ET_WT_F_MV',
                              'F',
                              'N');
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_apps_schema,
                                   TABNAME => 'MLOG$_PJI_FP_ORG_ET_WT_F_M',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_ORGO_ET_WT_F_MV',
                              'F',
                              'N');
    end if;

    if (l_extraction_type <> 'INCREMENTAL') then
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_FP_ORG_ET_WT_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_FP_ORGO_ET_WT_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FWO(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_FWO;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_FWC
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_FWC (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_pji_schema      varchar2(30);
    l_apps_schema     varchar2(30);
    l_p_degree        number := 0;

    l_errbuf             varchar2(255);
    l_retcode            varchar2(255);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FWC(p_worker_id);'
            )) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    if (upper(nvl(FND_PROFILE.VALUE('PJI_USE_DBI_RSG'), 'N')) = 'Y' and
        l_extraction_type <> 'PARTIAL') then
      return;
    end if;

    l_pji_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    l_apps_schema := PJI_UTILS.GET_APPS_SCHEMA_NAME;
    l_p_degree := BIS_COMMON_PARAMETERS.GET_DEGREE_OF_PARALLELISM();
    if (l_p_degree = 1) then
      l_p_degree := 0;
    end if;

    FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pji_schema,
                                 TABNAME => 'PJI_PROJECT_CLASSES',
                                 PERCENT => 10,
                                 DEGREE  => l_p_degree);

    if (l_extraction_type = 'FULL') then
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_CLS_ET_WT_F_MV',
                              'C',
                              'N');
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_CLSO_ET_WT_F_MV',
                              'C',
                              'N');
    else
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_CLS_ET_WT_F_MV',
                              'F',
                              'N');
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_apps_schema,
                                   TABNAME => 'MLOG$_PJI_FP_CLS_ET_WT_F_M',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_CLSO_ET_WT_F_MV',
                              'F',
                              'N');
    end if;

    if (l_extraction_type <> 'INCREMENTAL') then
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_FP_CLS_ET_WT_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_FP_CLSO_ET_WT_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FWC(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_FWC;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_FEO
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_FEO (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_pji_schema      varchar2(30);
    l_apps_schema     varchar2(30);
    l_p_degree        number := 0;

    l_errbuf             varchar2(255);
    l_retcode            varchar2(255);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FEO(p_worker_id);'
            )) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    if (upper(nvl(FND_PROFILE.VALUE('PJI_USE_DBI_RSG'), 'N')) = 'Y' and
        l_extraction_type <> 'PARTIAL') then
      return;
    end if;

    l_pji_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    l_apps_schema := PJI_UTILS.GET_APPS_SCHEMA_NAME;
    l_p_degree := BIS_COMMON_PARAMETERS.GET_DEGREE_OF_PARALLELISM();
    if (l_p_degree = 1) then
      l_p_degree := 0;
    end if;

    if (l_extraction_type = 'FULL') then
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_ORG_ET_F_MV',
                              'C',
                              'N');
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_ORGO_ET_F_MV',
                              'C',
                              'N');
    else
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pji_schema,
                                   TABNAME => 'MLOG$_PJI_FP_PROJ_ET_F',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_ORG_ET_F_MV',
                              'F',
                              'N');
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_apps_schema,
                                   TABNAME => 'MLOG$_PJI_FP_ORG_ET_F_MV',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_ORGO_ET_F_MV',
                              'F',
                              'N');
    end if;

    if (l_extraction_type <> 'INCREMENTAL') then
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_FP_ORG_ET_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_FP_ORGO_ET_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FEO(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_FEO;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_FEC
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_FEC (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_apps_schema     varchar2(30);
    l_p_degree        number := 0;

    l_errbuf             varchar2(255);
    l_retcode            varchar2(255);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FEC(p_worker_id);'
            )) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    if (upper(nvl(FND_PROFILE.VALUE('PJI_USE_DBI_RSG'), 'N')) = 'Y' and
        l_extraction_type <> 'PARTIAL') then
      return;
    end if;

    l_apps_schema := PJI_UTILS.GET_APPS_SCHEMA_NAME;
    l_p_degree := BIS_COMMON_PARAMETERS.GET_DEGREE_OF_PARALLELISM();
    if (l_p_degree = 1) then
      l_p_degree := 0;
    end if;

    if (l_extraction_type = 'FULL') then
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_CLS_ET_F_MV',
                              'C',
                              'N');
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_CLSO_ET_F_MV',
                              'C',
                              'N');
    else
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_CLS_ET_F_MV',
                              'F',
                              'N');
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_apps_schema,
                                   TABNAME => 'MLOG$_PJI_FP_CLS_ET_F_MV',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_CLSO_ET_F_MV',
                              'F',
                              'N');
    end if;

    if (l_extraction_type <> 'INCREMENTAL') then
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_FP_CLS_ET_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_FP_CLSO_ET_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FEC(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_FEC;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_FPO
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_FPO (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_pji_schema      varchar2(30);
    l_apps_schema     varchar2(30);
    l_p_degree        number := 0;

    l_errbuf             varchar2(255);
    l_retcode            varchar2(255);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FPO(p_worker_id);'
            )) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    if (upper(nvl(FND_PROFILE.VALUE('PJI_USE_DBI_RSG'), 'N')) = 'Y' and
        l_extraction_type <> 'PARTIAL') then
      return;
    end if;

    l_pji_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    l_apps_schema := PJI_UTILS.GET_APPS_SCHEMA_NAME;
    l_p_degree := BIS_COMMON_PARAMETERS.GET_DEGREE_OF_PARALLELISM();
    if (l_p_degree = 1) then
      l_p_degree := 0;
    end if;

    if (l_extraction_type = 'FULL') then
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_ORG_F_MV',
                              'C',
                              'N');
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_ORGO_F_MV',
                              'C',
                              'N');
    else
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pji_schema,
                                   TABNAME => 'MLOG$_PJI_FP_PROJ_F',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_ORG_F_MV',
                              'F',
                              'N');
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_apps_schema,
                                   TABNAME => 'MLOG$_PJI_FP_ORG_F_MV',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_ORGO_F_MV',
                              'F',
                              'N');
    end if;

    if (l_extraction_type <> 'INCREMENTAL') then
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_FP_ORG_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_FP_ORGO_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FPO(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_FPO;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_FPC
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_FPC (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_apps_schema     varchar2(30);
    l_p_degree        number := 0;

    l_errbuf             varchar2(255);
    l_retcode            varchar2(255);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FPC(p_worker_id);'
            )) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    if (upper(nvl(FND_PROFILE.VALUE('PJI_USE_DBI_RSG'), 'N')) = 'Y' and
        l_extraction_type <> 'PARTIAL') then
      return;
    end if;

    l_apps_schema := PJI_UTILS.GET_APPS_SCHEMA_NAME;
    l_p_degree := BIS_COMMON_PARAMETERS.GET_DEGREE_OF_PARALLELISM();
    if (l_p_degree = 1) then
      l_p_degree := 0;
    end if;

    if (l_extraction_type = 'FULL') then
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_CLS_F_MV',
                              'C',
                              'N');
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_CLSO_F_MV',
                              'C',
                              'N');
    else
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_CLS_F_MV',
                              'F',
                              'N');
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_apps_schema,
                                   TABNAME => 'MLOG$_PJI_FP_CLS_F_MV',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_FP_CLSO_F_MV',
                              'F',
                              'N');
    end if;

    if (l_extraction_type <> 'INCREMENTAL') then
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_FP_CLS_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_FP_CLSO_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FPC(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_FPC;

end PJI_FM_SUM_ROLLUP_FIN;

/
