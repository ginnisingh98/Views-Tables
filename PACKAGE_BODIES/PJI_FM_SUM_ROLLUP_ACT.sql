--------------------------------------------------------
--  DDL for Package Body PJI_FM_SUM_ROLLUP_ACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_SUM_ROLLUP_ACT" as
  /* $Header: PJISF05B.pls 120.7 2006/04/18 20:08:27 appldev noship $ */

  -- -----------------------------------------------------
  -- procedure ACT_ROWID_TABLE
  -- -----------------------------------------------------
  procedure ACT_ROWID_TABLE (p_worker_id in number) is

    l_process   varchar2(30);
    l_schema    varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_ACT.ACT_ROWID_TABLE(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(act_i) */ into PJI_PJI_RMAP_ACT act_i
    (
      WORKER_ID,
      STG_ROWID
    )
    select
      p_worker_id                           WORKER_ID,
      act5.ROWID                            STG_ROWID
    from
      PJI_PJI_PROJ_BATCH_MAP map,
      PJI_FM_AGGR_ACT5 act5
    where
      map.WORKER_ID = p_worker_id and
      act5.PROJECT_ID = map.PROJECT_ID;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_ACT.ACT_ROWID_TABLE(p_worker_id);');

    commit;

  end ACT_ROWID_TABLE;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_ACT_SLICES
  -- -----------------------------------------------------
  procedure AGGREGATE_ACT_SLICES (p_worker_id in number) is

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);

    l_txn_currency_flag varchar2(1);
    l_g2_currency_flag  varchar2(1);

    l_g1_currency_code  varchar2(30);
    l_g2_currency_code  varchar2(30);

    l_pa_calendar_flag  varchar2(1);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_ACT.AGGREGATE_ACT_SLICES(p_worker_id);')) then
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

    l_pa_calendar_flag := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      PJI_RM_SUM_MAIN.g_process,
      'PA_CALENDAR_FLAG'
    );

    insert  /*+ append parallel(act3_i) */ into PJI_FM_AGGR_ACT3 act3_i
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      FUNDING,
      INITIAL_FUNDING_AMOUNT,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_AMOUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_AMOUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_AMOUNT,
      FUNDING_ADJUSTMENT_COUNT,
      REVENUE_WRITEOFF,
      AR_INVOICE_AMOUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_AMOUNT,
      AR_CASH_APPLIED_COUNT,
      AR_INVOICE_WRITEOFF_AMOUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_AMOUNT,
      AR_CREDIT_MEMO_COUNT,
      UNBILLED_RECEIVABLES,
      UNEARNED_REVENUE,
      AR_UNAPPR_INVOICE_AMOUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_AMOUNT,
      AR_APPR_INVOICE_COUNT,
      AR_AMOUNT_DUE,
      AR_COUNT_DUE,
      AR_AMOUNT_OVERDUE,
      AR_COUNT_OVERDUE,
      DORMANT_BACKLOG_INACTIV,
      DORMANT_BACKLOG_START,
      LOST_BACKLOG,
      ACTIVE_BACKLOG,
      REVENUE_AT_RISK
    )
    select
      src4.WORKER_ID,
      src4.PROJECT_ID,
      src4.PROJECT_ORG_ID,
      src4.PROJECT_ORGANIZATION_ID,
      src4.TIME_ID,
      src4.PERIOD_TYPE_ID,
      src4.CALENDAR_TYPE,
      src4.GL_CALENDAR_ID,
      src4.PA_CALENDAR_ID,
      src4.CURR_RECORD_TYPE_ID,
      src4.CURRENCY_CODE,
      sum(src4.REVENUE)                             REVENUE,
      sum(src4.FUNDING)                             FUNDING,
      sum(src4.INITIAL_FUNDING_AMOUNT)              INITIAL_FUNDING_AMOUNT,
      sum(src4.INITIAL_FUNDING_COUNT)               INITIAL_FUNDING_COUNT,
      sum(src4.ADDITIONAL_FUNDING_AMOUNT)           ADDITIONAL_FUNDING_AMOUNT,
      sum(src4.ADDITIONAL_FUNDING_COUNT)            ADDITIONAL_FUNDING_COUNT,
      sum(src4.CANCELLED_FUNDING_AMOUNT)            CANCELLED_FUNDING_AMOUNT,
      sum(src4.CANCELLED_FUNDING_COUNT)             CANCELLED_FUNDING_COUNT,
      sum(src4.FUNDING_ADJUSTMENT_AMOUNT)           FUNDING_ADJUSTMENT_AMOUNT,
      sum(src4.FUNDING_ADJUSTMENT_COUNT)            FUNDING_ADJUSTMENT_COUNT,
      sum(src4.REVENUE_WRITEOFF)                    REVENUE_WRITEOFF,
      sum(src4.AR_INVOICE_AMOUNT)                   AR_INVOICE_AMOUNT,
      sum(src4.AR_INVOICE_COUNT)                    AR_INVOICE_COUNT,
      sum(src4.AR_CASH_APPLIED_AMOUNT)              AR_CASH_APPLIED_AMOUNT,
      sum(src4.AR_CASH_APPLIED_COUNT)               AR_CASH_APPLIED_COUNT,
      sum(src4.AR_INVOICE_WRITEOFF_AMOUNT)          AR_INVOICE_WRITEOFF_AMOUNT,
      sum(src4.AR_INVOICE_WRITEOFF_COUNT)           AR_INVOICE_WRITEOFF_COUNT,
      sum(src4.AR_CREDIT_MEMO_AMOUNT)               AR_CREDIT_MEMO_AMOUNT,
      sum(src4.AR_CREDIT_MEMO_COUNT)                AR_CREDIT_MEMO_COUNT,
      sum(src4.UNBILLED_RECEIVABLES)                UNBILLED_RECEIVABLES,
      sum(src4.UNEARNED_REVENUE)                    UNEARNED_REVENUE,
      sum(src4.AR_UNAPPR_INVOICE_AMOUNT)            AR_UNAPPR_INVOICE_AMOUNT,
      sum(src4.AR_UNAPPR_INVOICE_COUNT)             AR_UNAPPR_INVOICE_COUNT,
      sum(src4.AR_APPR_INVOICE_AMOUNT)              AR_APPR_INVOICE_AMOUNT,
      sum(src4.AR_APPR_INVOICE_COUNT)               AR_APPR_INVOICE_COUNT,
      sum(src4.AR_AMOUNT_DUE)                       AR_AMOUNT_DUE,
      sum(src4.AR_COUNT_DUE)                        AR_COUNT_DUE,
      sum(src4.AR_AMOUNT_OVERDUE)                   AR_AMOUNT_OVERDUE,
      sum(src4.AR_COUNT_OVERDUE)                    AR_COUNT_OVERDUE,
      sum(src4.DORMANT_BACKLOG_INACTIV)             DORMANT_BACKLOG_INACTIV,
      sum(src4.DORMANT_BACKLOG_START)               DORMANT_BACKLOG_START,
      sum(src4.LOST_BACKLOG)                        LOST_BACKLOG,
      sum(src4.ACTIVE_BACKLOG)                      ACTIVE_BACKLOG,
      sum(src4.REVENUE_AT_RISK)                     REVENUE_AT_RISK
    from
      (
      select
        src3.WORKER_ID,
        src3.PROJECT_ID,
        src3.PROJECT_ORG_ID,
        src3.PROJECT_ORGANIZATION_ID,
        src3.TIME_ID,
        src3.PERIOD_TYPE_ID,
        src3.CALENDAR_TYPE,
        src3.GL_CALENDAR_ID,
        src3.PA_CALENDAR_ID,
        sum(src3.CURR_RECORD_TYPE_ID)               CURR_RECORD_TYPE_ID,
        nvl(src3.CURRENCY_CODE, 'PJI$NULL')         CURRENCY_CODE,
        max(src3.REVENUE)                           REVENUE,
        max(src3.FUNDING)                           FUNDING,
        max(src3.INITIAL_FUNDING_AMOUNT)            INITIAL_FUNDING_AMOUNT,
        max(src3.INITIAL_FUNDING_COUNT)             INITIAL_FUNDING_COUNT,
        max(src3.ADDITIONAL_FUNDING_AMOUNT)         ADDITIONAL_FUNDING_AMOUNT,
        max(src3.ADDITIONAL_FUNDING_COUNT)          ADDITIONAL_FUNDING_COUNT,
        max(src3.CANCELLED_FUNDING_AMOUNT)          CANCELLED_FUNDING_AMOUNT,
        max(src3.CANCELLED_FUNDING_COUNT)           CANCELLED_FUNDING_COUNT,
        max(src3.FUNDING_ADJUSTMENT_AMOUNT)         FUNDING_ADJUSTMENT_AMOUNT,
        max(src3.FUNDING_ADJUSTMENT_COUNT)          FUNDING_ADJUSTMENT_COUNT,
        max(src3.REVENUE_WRITEOFF)                  REVENUE_WRITEOFF,
        max(src3.AR_INVOICE_AMOUNT)                 AR_INVOICE_AMOUNT,
        max(src3.AR_INVOICE_COUNT)                  AR_INVOICE_COUNT,
        max(src3.AR_CASH_APPLIED_AMOUNT)            AR_CASH_APPLIED_AMOUNT,
        max(src3.AR_CASH_APPLIED_COUNT)             AR_CASH_APPLIED_COUNT,
        max(src3.AR_INVOICE_WRITEOFF_AMOUNT)        AR_INVOICE_WRITEOFF_AMOUNT,
        max(src3.AR_INVOICE_WRITEOFF_COUNT)         AR_INVOICE_WRITEOFF_COUNT,
        max(src3.AR_CREDIT_MEMO_AMOUNT)             AR_CREDIT_MEMO_AMOUNT,
        max(src3.AR_CREDIT_MEMO_COUNT)              AR_CREDIT_MEMO_COUNT,
        max(src3.UNBILLED_RECEIVABLES)              UNBILLED_RECEIVABLES,
        max(src3.UNEARNED_REVENUE)                  UNEARNED_REVENUE,
        max(src3.AR_UNAPPR_INVOICE_AMOUNT)          AR_UNAPPR_INVOICE_AMOUNT,
        max(src3.AR_UNAPPR_INVOICE_COUNT)           AR_UNAPPR_INVOICE_COUNT,
        max(src3.AR_APPR_INVOICE_AMOUNT)            AR_APPR_INVOICE_AMOUNT,
        max(src3.AR_APPR_INVOICE_COUNT)             AR_APPR_INVOICE_COUNT,
        max(src3.AR_AMOUNT_DUE)                     AR_AMOUNT_DUE,
        max(src3.AR_COUNT_DUE)                      AR_COUNT_DUE,
        max(src3.AR_AMOUNT_OVERDUE)                 AR_AMOUNT_OVERDUE,
        max(src3.AR_COUNT_OVERDUE)                  AR_COUNT_OVERDUE,
        to_number(null)                             DORMANT_BACKLOG_INACTIV,
        to_number(null)                             DORMANT_BACKLOG_START,
        to_number(null)                             LOST_BACKLOG,
        to_number(null)                             ACTIVE_BACKLOG,
        to_number(null)                             REVENUE_AT_RISK
      from
        (
        select /*+ ordered */
          p_worker_id                               WORKER_ID,
          src2.PROJECT_ID,
          src2.PROJECT_ORG_ID,
          src2.PROJECT_ORGANIZATION_ID,
          src2.TIME_ID,
          1                                         PERIOD_TYPE_ID,
          src2.CALENDAR_TYPE,
          src2.GL_CALENDAR_ID,
          src2.PA_CALENDAR_ID,
          invert.INVERT_ID                          CURR_RECORD_TYPE_ID,
          decode(invert.INVERT_ID,
                 1,   l_g1_currency_code,
                 2,   l_g2_currency_code,
                 4,   info.PF_CURRENCY_CODE,
                 8,   prj.PROJECT_CURRENCY_CODE,
                 16,  src2.TXN_CURRENCY_CODE,
                 32,  l_g1_currency_code,
                 64,  l_g2_currency_code,
                 128, info.PF_CURRENCY_CODE,
                 256, prj.PROJECT_CURRENCY_CODE)    DIFF_CURRENCY_CODE,
          src2.DIFF_ROWNUM                          DIFF_ROWNUM,
          decode(invert.INVERT_ID,
                 1,   l_g1_currency_code,
                 2,   l_g2_currency_code,
                 4,   info.PF_CURRENCY_CODE,
                 8,   prj.PROJECT_CURRENCY_CODE,
                 16,  src2.TXN_CURRENCY_CODE,
                 32,  src2.TXN_CURRENCY_CODE,
                 64,  src2.TXN_CURRENCY_CODE,
                 128, src2.TXN_CURRENCY_CODE,
                 256, src2.TXN_CURRENCY_CODE)       CURRENCY_CODE,
          decode(invert.INVERT_ID,
                 1,   src2.G1_REVENUE,
                 2,   src2.G2_REVENUE,
                 4,   src2.POU_REVENUE,
                 8,   src2.PRJ_REVENUE,
                 16,  src2.TXN_REVENUE,
                 32,  src2.G1_REVENUE,
                 64,  src2.G2_REVENUE,
                 128, src2.POU_REVENUE,
                 256, src2.PRJ_REVENUE)             REVENUE,
          decode(invert.INVERT_ID,
                 1,   src2.G1_FUNDING,
                 2,   src2.G2_FUNDING,
                 4,   src2.POU_FUNDING,
                 8,   src2.PRJ_FUNDING,
                 16,  src2.TXN_FUNDING,
                 32,  src2.G1_FUNDING,
                 64,  src2.G2_FUNDING,
                 128, src2.POU_FUNDING,
                 256, src2.PRJ_FUNDING)             FUNDING,
          decode(invert.INVERT_ID,
                 1,   src2.G1_INITIAL_FUNDING_AMOUNT,
                 2,   src2.G2_INITIAL_FUNDING_AMOUNT,
                 4,   src2.POU_INITIAL_FUNDING_AMOUNT,
                 8,   src2.PRJ_INITIAL_FUNDING_AMOUNT,
                 16,  src2.TXN_INITIAL_FUNDING_AMOUNT,
                 32,  src2.G1_INITIAL_FUNDING_AMOUNT,
                 64,  src2.G2_INITIAL_FUNDING_AMOUNT,
                 128, src2.POU_INITIAL_FUNDING_AMOUNT,
                 256, src2.PRJ_INITIAL_FUNDING_AMOUNT)
                                                    INITIAL_FUNDING_AMOUNT,
          src2.INITIAL_FUNDING_COUNT,
          decode(invert.INVERT_ID,
                 1,   src2.G1_ADDITIONAL_FUNDING_AMOUNT,
                 2,   src2.G2_ADDITIONAL_FUNDING_AMOUNT,
                 4,   src2.POU_ADDITIONAL_FUNDING_AMOUNT,
                 8,   src2.PRJ_ADDITIONAL_FUNDING_AMOUNT,
                 16,  src2.TXN_ADDITIONAL_FUNDING_AMOUNT,
                 32,  src2.G1_ADDITIONAL_FUNDING_AMOUNT,
                 64,  src2.G2_ADDITIONAL_FUNDING_AMOUNT,
                 128, src2.POU_ADDITIONAL_FUNDING_AMOUNT,
                 256, src2.PRJ_ADDITIONAL_FUNDING_AMOUNT)
                                                    ADDITIONAL_FUNDING_AMOUNT,
          src2.ADDITIONAL_FUNDING_COUNT,
          decode(invert.INVERT_ID,
                 1,   src2.G1_CANCELLED_FUNDING_AMOUNT,
                 2,   src2.G2_CANCELLED_FUNDING_AMOUNT,
                 4,   src2.POU_CANCELLED_FUNDING_AMOUNT,
                 8,   src2.PRJ_CANCELLED_FUNDING_AMOUNT,
                 16,  src2.TXN_CANCELLED_FUNDING_AMOUNT,
                 32,  src2.G1_CANCELLED_FUNDING_AMOUNT,
                 64,  src2.G2_CANCELLED_FUNDING_AMOUNT,
                 128, src2.POU_CANCELLED_FUNDING_AMOUNT,
                 256, src2.PRJ_CANCELLED_FUNDING_AMOUNT)
                                                    CANCELLED_FUNDING_AMOUNT,
          src2.CANCELLED_FUNDING_COUNT,
          decode(invert.INVERT_ID,
                 1,   src2.G1_FUNDING_ADJUSTMENT_AMOUNT,
                 2,   src2.G2_FUNDING_ADJUSTMENT_AMOUNT,
                 4,   src2.POU_FUNDING_ADJUSTMENT_AMOUNT,
                 8,   src2.PRJ_FUNDING_ADJUSTMENT_AMOUNT,
                 16,  src2.TXN_FUNDING_ADJUSTMENT_AMOUNT,
                 32,  src2.G1_FUNDING_ADJUSTMENT_AMOUNT,
                 64,  src2.G2_FUNDING_ADJUSTMENT_AMOUNT,
                 128, src2.POU_FUNDING_ADJUSTMENT_AMOUNT,
                 256, src2.PRJ_FUNDING_ADJUSTMENT_AMOUNT)
                                                    FUNDING_ADJUSTMENT_AMOUNT,
          src2.FUNDING_ADJUSTMENT_COUNT,
          decode(invert.INVERT_ID,
                 1,   src2.G1_REVENUE_WRITEOFF,
                 2,   src2.G2_REVENUE_WRITEOFF,
                 4,   src2.POU_REVENUE_WRITEOFF,
                 8,   src2.PRJ_REVENUE_WRITEOFF,
                 16,  src2.TXN_REVENUE_WRITEOFF,
                 32,  src2.G1_REVENUE_WRITEOFF,
                 64,  src2.G2_REVENUE_WRITEOFF,
                 128, src2.POU_REVENUE_WRITEOFF,
                 256, src2.PRJ_REVENUE_WRITEOFF)    REVENUE_WRITEOFF,
          decode(invert.INVERT_ID,
                 1,   src2.G1_AR_INVOICE_AMOUNT,
                 2,   src2.G2_AR_INVOICE_AMOUNT,
                 4,   src2.POU_AR_INVOICE_AMOUNT,
                 8,   src2.PRJ_AR_INVOICE_AMOUNT,
                 16,  src2.TXN_AR_INVOICE_AMOUNT,
                 32,  src2.G1_AR_INVOICE_AMOUNT,
                 64,  src2.G2_AR_INVOICE_AMOUNT,
                 128, src2.POU_AR_INVOICE_AMOUNT,
                 256, src2.PRJ_AR_INVOICE_AMOUNT)   AR_INVOICE_AMOUNT,
          src2.AR_INVOICE_COUNT,
          decode(invert.INVERT_ID,
                 1,   src2.G1_AR_CASH_APPLIED_AMOUNT,
                 2,   src2.G2_AR_CASH_APPLIED_AMOUNT,
                 4,   src2.POU_AR_CASH_APPLIED_AMOUNT,
                 8,   src2.PRJ_AR_CASH_APPLIED_AMOUNT,
                 16,  src2.TXN_AR_CASH_APPLIED_AMOUNT,
                 32,  src2.G1_AR_CASH_APPLIED_AMOUNT,
                 64,  src2.G2_AR_CASH_APPLIED_AMOUNT,
                 128, src2.POU_AR_CASH_APPLIED_AMOUNT,
                 256, src2.PRJ_AR_CASH_APPLIED_AMOUNT)
                                                    AR_CASH_APPLIED_AMOUNT,
          src2.AR_CASH_APPLIED_COUNT,
          decode(invert.INVERT_ID,
                 1,   src2.G1_AR_INVOICE_WRITEOFF_AMOUNT,
                 2,   src2.G2_AR_INVOICE_WRITEOFF_AMOUNT,
                 4,   src2.POU_AR_INVOICE_WRITEOFF_AMOUNT,
                 8,   src2.PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
                 16,  src2.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
                 32,  src2.G1_AR_INVOICE_WRITEOFF_AMOUNT,
                 64,  src2.G2_AR_INVOICE_WRITEOFF_AMOUNT,
                 128, src2.POU_AR_INVOICE_WRITEOFF_AMOUNT,
                 256, src2.PRJ_AR_INVOICE_WRITEOFF_AMOUNT)
                                                    AR_INVOICE_WRITEOFF_AMOUNT,
          src2.AR_INVOICE_WRITEOFF_COUNT,
          decode(invert.INVERT_ID,
                 1,   src2.G1_AR_CREDIT_MEMO_AMOUNT,
                 2,   src2.G2_AR_CREDIT_MEMO_AMOUNT,
                 4,   src2.POU_AR_CREDIT_MEMO_AMOUNT,
                 8,   src2.PRJ_AR_CREDIT_MEMO_AMOUNT,
                 16,  src2.TXN_AR_CREDIT_MEMO_AMOUNT,
                 32,  src2.G1_AR_CREDIT_MEMO_AMOUNT,
                 64,  src2.G2_AR_CREDIT_MEMO_AMOUNT,
                 128, src2.POU_AR_CREDIT_MEMO_AMOUNT,
                 256, src2.PRJ_AR_CREDIT_MEMO_AMOUNT)
                                                    AR_CREDIT_MEMO_AMOUNT,
          src2.AR_CREDIT_MEMO_COUNT,
          decode(invert.INVERT_ID,
                 1,   src2.G1_UNBILLED_RECEIVABLES,
                 2,   src2.G2_UNBILLED_RECEIVABLES,
                 4,   src2.POU_UNBILLED_RECEIVABLES,
                 8,   src2.PRJ_UNBILLED_RECEIVABLES,
                 16,  src2.TXN_UNBILLED_RECEIVABLES,
                 32,  src2.G1_UNBILLED_RECEIVABLES,
                 64,  src2.G2_UNBILLED_RECEIVABLES,
                 128, src2.POU_UNBILLED_RECEIVABLES,
                 256, src2.PRJ_UNBILLED_RECEIVABLES)UNBILLED_RECEIVABLES,
          decode(invert.INVERT_ID,
                 1,   src2.G1_UNEARNED_REVENUE,
                 2,   src2.G2_UNEARNED_REVENUE,
                 4,   src2.POU_UNEARNED_REVENUE,
                 8,   src2.PRJ_UNEARNED_REVENUE,
                 16,  src2.TXN_UNEARNED_REVENUE,
                 32,  src2.G1_UNEARNED_REVENUE,
                 64,  src2.G2_UNEARNED_REVENUE,
                 128, src2.POU_UNEARNED_REVENUE,
                 256, src2.PRJ_UNEARNED_REVENUE)    UNEARNED_REVENUE,
          decode(invert.INVERT_ID,
                 1,   src2.G1_AR_UNAPPR_INVOICE_AMOUNT,
                 2,   src2.G2_AR_UNAPPR_INVOICE_AMOUNT,
                 4,   src2.POU_AR_UNAPPR_INVOICE_AMOUNT,
                 8,   src2.PRJ_AR_UNAPPR_INVOICE_AMOUNT,
                 16,  src2.TXN_AR_UNAPPR_INVOICE_AMOUNT,
                 32,  src2.G1_AR_UNAPPR_INVOICE_AMOUNT,
                 64,  src2.G2_AR_UNAPPR_INVOICE_AMOUNT,
                 128, src2.POU_AR_UNAPPR_INVOICE_AMOUNT,
                 256, src2.PRJ_AR_UNAPPR_INVOICE_AMOUNT)
                                                    AR_UNAPPR_INVOICE_AMOUNT,
          src2.AR_UNAPPR_INVOICE_COUNT,
          decode(invert.INVERT_ID,
                 1,   src2.G1_AR_APPR_INVOICE_AMOUNT,
                 2,   src2.G2_AR_APPR_INVOICE_AMOUNT,
                 4,   src2.POU_AR_APPR_INVOICE_AMOUNT,
                 8,   src2.PRJ_AR_APPR_INVOICE_AMOUNT,
                 16,  src2.TXN_AR_APPR_INVOICE_AMOUNT,
                 32,  src2.G1_AR_APPR_INVOICE_AMOUNT,
                 64,  src2.G2_AR_APPR_INVOICE_AMOUNT,
                 128, src2.POU_AR_APPR_INVOICE_AMOUNT,
                 256, src2.PRJ_AR_APPR_INVOICE_AMOUNT)
                                                    AR_APPR_INVOICE_AMOUNT,
          src2.AR_APPR_INVOICE_COUNT,
          decode(invert.INVERT_ID,
                 1,   src2.G1_AR_AMOUNT_DUE,
                 2,   src2.G2_AR_AMOUNT_DUE,
                 4,   src2.POU_AR_AMOUNT_DUE,
                 8,   src2.PRJ_AR_AMOUNT_DUE,
                 16,  src2.TXN_AR_AMOUNT_DUE,
                 32,  src2.G1_AR_AMOUNT_DUE,
                 64,  src2.G2_AR_AMOUNT_DUE,
                 128, src2.POU_AR_AMOUNT_DUE,
                 256, src2.PRJ_AR_AMOUNT_DUE)       AR_AMOUNT_DUE,
          src2.AR_COUNT_DUE,
          decode(invert.INVERT_ID,
                 1,   src2.G1_AR_AMOUNT_OVERDUE,
                 2,   src2.G2_AR_AMOUNT_OVERDUE,
                 4,   src2.POU_AR_AMOUNT_OVERDUE,
                 8,   src2.PRJ_AR_AMOUNT_OVERDUE,
                 16,  src2.TXN_AR_AMOUNT_OVERDUE,
                 32,  src2.G1_AR_AMOUNT_OVERDUE,
                 64,  src2.G2_AR_AMOUNT_OVERDUE,
                 128, src2.POU_AR_AMOUNT_OVERDUE,
                 256, src2.PRJ_AR_AMOUNT_OVERDUE)   AR_AMOUNT_OVERDUE,
          src2.AR_COUNT_OVERDUE
        from
          (
          select
            ROWNUM                                  DIFF_ROWNUM,
            src1.PROJECT_ID,
            src1.PROJECT_ORG_ID,
            src1.PROJECT_ORGANIZATION_ID,
            src1.TIME_ID,
            src1.CALENDAR_TYPE,
            src1.GL_CALENDAR_ID,
            src1.PA_CALENDAR_ID,
            src1.TXN_CURRENCY_CODE,
            src1.TXN_REVENUE,
            src1.TXN_FUNDING,
            src1.TXN_INITIAL_FUNDING_AMOUNT,
            src1.TXN_ADDITIONAL_FUNDING_AMOUNT,
            src1.TXN_CANCELLED_FUNDING_AMOUNT,
            src1.TXN_FUNDING_ADJUSTMENT_AMOUNT,
            src1.TXN_REVENUE_WRITEOFF,
            src1.TXN_AR_INVOICE_AMOUNT,
            src1.TXN_AR_CASH_APPLIED_AMOUNT,
            src1.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
            src1.TXN_AR_CREDIT_MEMO_AMOUNT,
            src1.TXN_UNBILLED_RECEIVABLES,
            src1.TXN_UNEARNED_REVENUE,
            src1.TXN_AR_UNAPPR_INVOICE_AMOUNT,
            src1.TXN_AR_APPR_INVOICE_AMOUNT,
            src1.TXN_AR_AMOUNT_DUE,
            src1.TXN_AR_AMOUNT_OVERDUE,
            src1.PRJ_REVENUE,
            src1.PRJ_FUNDING,
            src1.PRJ_INITIAL_FUNDING_AMOUNT,
            src1.PRJ_ADDITIONAL_FUNDING_AMOUNT,
            src1.PRJ_CANCELLED_FUNDING_AMOUNT,
            src1.PRJ_FUNDING_ADJUSTMENT_AMOUNT,
            src1.PRJ_REVENUE_WRITEOFF,
            src1.PRJ_AR_INVOICE_AMOUNT,
            src1.PRJ_AR_CASH_APPLIED_AMOUNT,
            src1.PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
            src1.PRJ_AR_CREDIT_MEMO_AMOUNT,
            src1.PRJ_UNBILLED_RECEIVABLES,
            src1.PRJ_UNEARNED_REVENUE,
            src1.PRJ_AR_UNAPPR_INVOICE_AMOUNT,
            src1.PRJ_AR_APPR_INVOICE_AMOUNT,
            src1.PRJ_AR_AMOUNT_DUE,
            src1.PRJ_AR_AMOUNT_OVERDUE,
            src1.POU_REVENUE,
            src1.POU_FUNDING,
            src1.POU_INITIAL_FUNDING_AMOUNT,
            src1.POU_ADDITIONAL_FUNDING_AMOUNT,
            src1.POU_CANCELLED_FUNDING_AMOUNT,
            src1.POU_FUNDING_ADJUSTMENT_AMOUNT,
            src1.POU_REVENUE_WRITEOFF,
            src1.POU_AR_INVOICE_AMOUNT,
            src1.POU_AR_CASH_APPLIED_AMOUNT,
            src1.POU_AR_INVOICE_WRITEOFF_AMOUNT,
            src1.POU_AR_CREDIT_MEMO_AMOUNT,
            src1.POU_UNBILLED_RECEIVABLES,
            src1.POU_UNEARNED_REVENUE,
            src1.POU_AR_UNAPPR_INVOICE_AMOUNT,
            src1.POU_AR_APPR_INVOICE_AMOUNT,
            src1.POU_AR_AMOUNT_DUE,
            src1.POU_AR_AMOUNT_OVERDUE,
            src1.EOU_REVENUE,
            src1.EOU_FUNDING,
            src1.EOU_INITIAL_FUNDING_AMOUNT,
            src1.EOU_ADDITIONAL_FUNDING_AMOUNT,
            src1.EOU_CANCELLED_FUNDING_AMOUNT,
            src1.EOU_FUNDING_ADJUSTMENT_AMOUNT,
            src1.EOU_REVENUE_WRITEOFF,
            src1.EOU_AR_INVOICE_AMOUNT,
            src1.EOU_AR_CASH_APPLIED_AMOUNT,
            src1.EOU_AR_INVOICE_WRITEOFF_AMOUNT,
            src1.EOU_AR_CREDIT_MEMO_AMOUNT,
            src1.EOU_UNBILLED_RECEIVABLES,
            src1.EOU_UNEARNED_REVENUE,
            src1.EOU_AR_UNAPPR_INVOICE_AMOUNT,
            src1.EOU_AR_APPR_INVOICE_AMOUNT,
            src1.EOU_AR_AMOUNT_DUE,
            src1.EOU_AR_AMOUNT_OVERDUE,
            src1.INITIAL_FUNDING_COUNT,
            src1.ADDITIONAL_FUNDING_COUNT,
            src1.CANCELLED_FUNDING_COUNT,
            src1.FUNDING_ADJUSTMENT_COUNT,
            src1.AR_INVOICE_COUNT,
            src1.AR_CASH_APPLIED_COUNT,
            src1.AR_INVOICE_WRITEOFF_COUNT,
            src1.AR_CREDIT_MEMO_COUNT,
            src1.AR_UNAPPR_INVOICE_COUNT,
            src1.AR_APPR_INVOICE_COUNT,
            src1.AR_COUNT_DUE,
            src1.AR_COUNT_OVERDUE,
            src1.G1_REVENUE,
            src1.G1_FUNDING,
            src1.G1_INITIAL_FUNDING_AMOUNT,
            src1.G1_ADDITIONAL_FUNDING_AMOUNT,
            src1.G1_CANCELLED_FUNDING_AMOUNT,
            src1.G1_FUNDING_ADJUSTMENT_AMOUNT,
            src1.G1_REVENUE_WRITEOFF,
            src1.G1_AR_INVOICE_AMOUNT,
            src1.G1_AR_CASH_APPLIED_AMOUNT,
            src1.G1_AR_INVOICE_WRITEOFF_AMOUNT,
            src1.G1_AR_CREDIT_MEMO_AMOUNT,
            src1.G1_UNBILLED_RECEIVABLES,
            src1.G1_UNEARNED_REVENUE,
            src1.G1_AR_UNAPPR_INVOICE_AMOUNT,
            src1.G1_AR_APPR_INVOICE_AMOUNT,
            src1.G1_AR_AMOUNT_DUE,
            src1.G1_AR_AMOUNT_OVERDUE,
            src1.G2_REVENUE,
            src1.G2_FUNDING,
            src1.G2_INITIAL_FUNDING_AMOUNT,
            src1.G2_ADDITIONAL_FUNDING_AMOUNT,
            src1.G2_CANCELLED_FUNDING_AMOUNT,
            src1.G2_FUNDING_ADJUSTMENT_AMOUNT,
            src1.G2_REVENUE_WRITEOFF,
            src1.G2_AR_INVOICE_AMOUNT,
            src1.G2_AR_CASH_APPLIED_AMOUNT,
            src1.G2_AR_INVOICE_WRITEOFF_AMOUNT,
            src1.G2_AR_CREDIT_MEMO_AMOUNT,
            src1.G2_UNBILLED_RECEIVABLES,
            src1.G2_UNEARNED_REVENUE,
            src1.G2_AR_UNAPPR_INVOICE_AMOUNT,
            src1.G2_AR_APPR_INVOICE_AMOUNT,
            src1.G2_AR_AMOUNT_DUE,
            src1.G2_AR_AMOUNT_OVERDUE
          from
            (
            select
              act5.PROJECT_ID,
              act5.PROJECT_ORG_ID,
              nvl(map.NEW_PROJECT_ORGANIZATION_ID,
                  act5.PROJECT_ORGANIZATION_ID) PROJECT_ORGANIZATION_ID,
              act5.TIME_ID,
              act5.CALENDAR_TYPE,
              act5.GL_CALENDAR_ID,
              act5.PA_CALENDAR_ID,
              act5.TXN_CURRENCY_CODE,
              sum(act5.TXN_REVENUE)             TXN_REVENUE,
              sum(act5.TXN_FUNDING)             TXN_FUNDING,
              sum(act5.TXN_INITIAL_FUNDING_AMOUNT)
                                                TXN_INITIAL_FUNDING_AMOUNT,
              sum(act5.TXN_ADDITIONAL_FUNDING_AMOUNT)
                                                TXN_ADDITIONAL_FUNDING_AMOUNT,
              sum(act5.TXN_CANCELLED_FUNDING_AMOUNT)
                                                TXN_CANCELLED_FUNDING_AMOUNT,
              sum(act5.TXN_FUNDING_ADJUSTMENT_AMOUNT)
                                                TXN_FUNDING_ADJUSTMENT_AMOUNT,
              sum(act5.TXN_REVENUE_WRITEOFF)    TXN_REVENUE_WRITEOFF,
              sum(act5.TXN_AR_INVOICE_AMOUNT)   TXN_AR_INVOICE_AMOUNT,
              sum(act5.TXN_AR_CASH_APPLIED_AMOUNT)
                                                TXN_AR_CASH_APPLIED_AMOUNT,
              sum(act5.TXN_AR_INVOICE_WRITEOFF_AMOUNT)
                                                TXN_AR_INVOICE_WRITEOFF_AMOUNT,
              sum(act5.TXN_AR_CREDIT_MEMO_AMOUNT)
                                                TXN_AR_CREDIT_MEMO_AMOUNT,
              sum(act5.TXN_UNBILLED_RECEIVABLES)TXN_UNBILLED_RECEIVABLES,
              sum(act5.TXN_UNEARNED_REVENUE)    TXN_UNEARNED_REVENUE,
              sum(act5.TXN_AR_UNAPPR_INVOICE_AMOUNT)
                                                TXN_AR_UNAPPR_INVOICE_AMOUNT,
              sum(act5.TXN_AR_APPR_INVOICE_AMOUNT)
                                                TXN_AR_APPR_INVOICE_AMOUNT,
              sum(act5.TXN_AR_AMOUNT_DUE)       TXN_AR_AMOUNT_DUE,
              sum(act5.TXN_AR_AMOUNT_OVERDUE)   TXN_AR_AMOUNT_OVERDUE,
              sum(act5.PRJ_REVENUE)             PRJ_REVENUE,
              sum(act5.PRJ_FUNDING)             PRJ_FUNDING,
              sum(act5.PRJ_INITIAL_FUNDING_AMOUNT)
                                                PRJ_INITIAL_FUNDING_AMOUNT,
              sum(act5.PRJ_ADDITIONAL_FUNDING_AMOUNT)
                                                PRJ_ADDITIONAL_FUNDING_AMOUNT,
              sum(act5.PRJ_CANCELLED_FUNDING_AMOUNT)
                                                PRJ_CANCELLED_FUNDING_AMOUNT,
              sum(act5.PRJ_FUNDING_ADJUSTMENT_AMOUNT)
                                                PRJ_FUNDING_ADJUSTMENT_AMOUNT,
              sum(act5.PRJ_REVENUE_WRITEOFF)    PRJ_REVENUE_WRITEOFF,
              sum(act5.PRJ_AR_INVOICE_AMOUNT)   PRJ_AR_INVOICE_AMOUNT,
              sum(act5.PRJ_AR_CASH_APPLIED_AMOUNT)
                                                PRJ_AR_CASH_APPLIED_AMOUNT,
              sum(act5.PRJ_AR_INVOICE_WRITEOFF_AMOUNT)
                                                PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
              sum(act5.PRJ_AR_CREDIT_MEMO_AMOUNT)
                                                PRJ_AR_CREDIT_MEMO_AMOUNT,
              sum(act5.PRJ_UNBILLED_RECEIVABLES)PRJ_UNBILLED_RECEIVABLES,
              sum(act5.PRJ_UNEARNED_REVENUE)    PRJ_UNEARNED_REVENUE,
              sum(act5.PRJ_AR_UNAPPR_INVOICE_AMOUNT)
                                                PRJ_AR_UNAPPR_INVOICE_AMOUNT,
              sum(act5.PRJ_AR_APPR_INVOICE_AMOUNT)
                                                PRJ_AR_APPR_INVOICE_AMOUNT,
              sum(act5.PRJ_AR_AMOUNT_DUE)       PRJ_AR_AMOUNT_DUE,
              sum(act5.PRJ_AR_AMOUNT_OVERDUE)   PRJ_AR_AMOUNT_OVERDUE,
              sum(act5.POU_REVENUE)             POU_REVENUE,
              sum(act5.POU_FUNDING)             POU_FUNDING,
              sum(act5.POU_INITIAL_FUNDING_AMOUNT)
                                                POU_INITIAL_FUNDING_AMOUNT,
              sum(act5.POU_ADDITIONAL_FUNDING_AMOUNT)
                                                POU_ADDITIONAL_FUNDING_AMOUNT,
              sum(act5.POU_CANCELLED_FUNDING_AMOUNT)
                                                POU_CANCELLED_FUNDING_AMOUNT,
              sum(act5.POU_FUNDING_ADJUSTMENT_AMOUNT)
                                                POU_FUNDING_ADJUSTMENT_AMOUNT,
              sum(act5.POU_REVENUE_WRITEOFF)    POU_REVENUE_WRITEOFF,
              sum(act5.POU_AR_INVOICE_AMOUNT)   POU_AR_INVOICE_AMOUNT,
              sum(act5.POU_AR_CASH_APPLIED_AMOUNT)
                                                POU_AR_CASH_APPLIED_AMOUNT,
              sum(act5.POU_AR_INVOICE_WRITEOFF_AMOUNT)
                                                POU_AR_INVOICE_WRITEOFF_AMOUNT,
              sum(act5.POU_AR_CREDIT_MEMO_AMOUNT)
                                                POU_AR_CREDIT_MEMO_AMOUNT,
              sum(act5.POU_UNBILLED_RECEIVABLES)POU_UNBILLED_RECEIVABLES,
              sum(act5.POU_UNEARNED_REVENUE)    POU_UNEARNED_REVENUE,
              sum(act5.POU_AR_UNAPPR_INVOICE_AMOUNT)
                                                POU_AR_UNAPPR_INVOICE_AMOUNT,
              sum(act5.POU_AR_APPR_INVOICE_AMOUNT)
                                                POU_AR_APPR_INVOICE_AMOUNT,
              sum(act5.POU_AR_AMOUNT_DUE)       POU_AR_AMOUNT_DUE,
              sum(act5.POU_AR_AMOUNT_OVERDUE)   POU_AR_AMOUNT_OVERDUE,
              sum(act5.EOU_REVENUE)             EOU_REVENUE,
              sum(act5.EOU_FUNDING)             EOU_FUNDING,
              sum(act5.EOU_INITIAL_FUNDING_AMOUNT)
                                                EOU_INITIAL_FUNDING_AMOUNT,
              sum(act5.EOU_ADDITIONAL_FUNDING_AMOUNT)
                                                EOU_ADDITIONAL_FUNDING_AMOUNT,
              sum(act5.EOU_CANCELLED_FUNDING_AMOUNT)
                                                EOU_CANCELLED_FUNDING_AMOUNT,
              sum(act5.EOU_FUNDING_ADJUSTMENT_AMOUNT)
                                                EOU_FUNDING_ADJUSTMENT_AMOUNT,
              sum(act5.EOU_REVENUE_WRITEOFF)    EOU_REVENUE_WRITEOFF,
              sum(act5.EOU_AR_INVOICE_AMOUNT)   EOU_AR_INVOICE_AMOUNT,
              sum(act5.EOU_AR_CASH_APPLIED_AMOUNT)
                                                EOU_AR_CASH_APPLIED_AMOUNT,
              sum(act5.EOU_AR_INVOICE_WRITEOFF_AMOUNT)
                                                EOU_AR_INVOICE_WRITEOFF_AMOUNT,
              sum(act5.EOU_AR_CREDIT_MEMO_AMOUNT)
                                                EOU_AR_CREDIT_MEMO_AMOUNT,
              sum(act5.EOU_UNBILLED_RECEIVABLES)EOU_UNBILLED_RECEIVABLES,
              sum(act5.EOU_UNEARNED_REVENUE)    EOU_UNEARNED_REVENUE,
              sum(act5.EOU_AR_UNAPPR_INVOICE_AMOUNT)
                                                EOU_AR_UNAPPR_INVOICE_AMOUNT,
              sum(act5.EOU_AR_APPR_INVOICE_AMOUNT)
                                                EOU_AR_APPR_INVOICE_AMOUNT,
              sum(act5.EOU_AR_AMOUNT_DUE)       EOU_AR_AMOUNT_DUE,
              sum(act5.EOU_AR_AMOUNT_OVERDUE)   EOU_AR_AMOUNT_OVERDUE,
              sum(act5.INITIAL_FUNDING_COUNT)   INITIAL_FUNDING_COUNT,
              sum(act5.ADDITIONAL_FUNDING_COUNT)ADDITIONAL_FUNDING_COUNT,
              sum(act5.CANCELLED_FUNDING_COUNT) CANCELLED_FUNDING_COUNT,
              sum(act5.FUNDING_ADJUSTMENT_COUNT)FUNDING_ADJUSTMENT_COUNT,
              sum(act5.AR_INVOICE_COUNT)        AR_INVOICE_COUNT,
              sum(act5.AR_CASH_APPLIED_COUNT)   AR_CASH_APPLIED_COUNT,
              sum(act5.AR_INVOICE_WRITEOFF_COUNT)
                                                AR_INVOICE_WRITEOFF_COUNT,
              sum(act5.AR_CREDIT_MEMO_COUNT)    AR_CREDIT_MEMO_COUNT,
              sum(act5.AR_UNAPPR_INVOICE_COUNT) AR_UNAPPR_INVOICE_COUNT,
              sum(act5.AR_APPR_INVOICE_COUNT)   AR_APPR_INVOICE_COUNT,
              sum(act5.AR_COUNT_DUE)            AR_COUNT_DUE,
              sum(act5.AR_COUNT_OVERDUE)        AR_COUNT_OVERDUE,
              sum(act5.G1_REVENUE)              G1_REVENUE,
              sum(act5.G1_FUNDING)              G1_FUNDING,
              sum(act5.G1_INITIAL_FUNDING_AMOUNT)
                                                G1_INITIAL_FUNDING_AMOUNT,
              sum(act5.G1_ADDITIONAL_FUNDING_AMOUNT)
                                                G1_ADDITIONAL_FUNDING_AMOUNT,
              sum(act5.G1_CANCELLED_FUNDING_AMOUNT)
                                                G1_CANCELLED_FUNDING_AMOUNT,
              sum(act5.G1_FUNDING_ADJUSTMENT_AMOUNT)
                                                G1_FUNDING_ADJUSTMENT_AMOUNT,
              sum(act5.G1_REVENUE_WRITEOFF)     G1_REVENUE_WRITEOFF,
              sum(act5.G1_AR_INVOICE_AMOUNT)    G1_AR_INVOICE_AMOUNT,
              sum(act5.G1_AR_CASH_APPLIED_AMOUNT)
                                                G1_AR_CASH_APPLIED_AMOUNT,
              sum(act5.G1_AR_INVOICE_WRITEOFF_AMOUNT)
                                                G1_AR_INVOICE_WRITEOFF_AMOUNT,
              sum(act5.G1_AR_CREDIT_MEMO_AMOUNT)G1_AR_CREDIT_MEMO_AMOUNT,
              sum(act5.G1_UNBILLED_RECEIVABLES) G1_UNBILLED_RECEIVABLES,
              sum(act5.G1_UNEARNED_REVENUE)     G1_UNEARNED_REVENUE,
              sum(act5.G1_AR_UNAPPR_INVOICE_AMOUNT)
                                                G1_AR_UNAPPR_INVOICE_AMOUNT,
              sum(act5.G1_AR_APPR_INVOICE_AMOUNT)
                                                G1_AR_APPR_INVOICE_AMOUNT,
              sum(act5.G1_AR_AMOUNT_DUE)        G1_AR_AMOUNT_DUE,
              sum(act5.G1_AR_AMOUNT_OVERDUE)    G1_AR_AMOUNT_OVERDUE,
              sum(act5.G2_REVENUE)              G2_REVENUE,
              sum(act5.G2_FUNDING)              G2_FUNDING,
              sum(act5.G2_INITIAL_FUNDING_AMOUNT)
                                                G2_INITIAL_FUNDING_AMOUNT,
              sum(act5.G2_ADDITIONAL_FUNDING_AMOUNT)
                                                G2_ADDITIONAL_FUNDING_AMOUNT,
              sum(act5.G2_CANCELLED_FUNDING_AMOUNT)
                                                G2_CANCELLED_FUNDING_AMOUNT,
              sum(act5.G2_FUNDING_ADJUSTMENT_AMOUNT)
                                                G2_FUNDING_ADJUSTMENT_AMOUNT,
              sum(act5.G2_REVENUE_WRITEOFF)     G2_REVENUE_WRITEOFF,
              sum(act5.G2_AR_INVOICE_AMOUNT)    G2_AR_INVOICE_AMOUNT,
              sum(act5.G2_AR_CASH_APPLIED_AMOUNT)
                                                G2_AR_CASH_APPLIED_AMOUNT,
              sum(act5.G2_AR_INVOICE_WRITEOFF_AMOUNT)
                                                G2_AR_INVOICE_WRITEOFF_AMOUNT,
              sum(act5.G2_AR_CREDIT_MEMO_AMOUNT)G2_AR_CREDIT_MEMO_AMOUNT,
              sum(act5.G2_UNBILLED_RECEIVABLES) G2_UNBILLED_RECEIVABLES,
              sum(act5.G2_UNEARNED_REVENUE)     G2_UNEARNED_REVENUE,
              sum(act5.G2_AR_UNAPPR_INVOICE_AMOUNT)
                                                G2_AR_UNAPPR_INVOICE_AMOUNT,
              sum(act5.G2_AR_APPR_INVOICE_AMOUNT)
                                                G2_AR_APPR_INVOICE_AMOUNT,
              sum(act5.G2_AR_AMOUNT_DUE)        G2_AR_AMOUNT_DUE,
              sum(act5.G2_AR_AMOUNT_OVERDUE)    G2_AR_AMOUNT_OVERDUE
            from
              PJI_PJI_RMAP_ACT act5_r,
              PJI_FM_AGGR_ACT5 act5,
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
              act5_r.WORKER_ID = p_worker_id and
              act5.ROWID       = act5_r. STG_ROWID and
              act5.PROJECT_ID  = map.PROJECT_ID (+)
            group by
              act5.PROJECT_ID,
              act5.PROJECT_ORG_ID,
              nvl(map.NEW_PROJECT_ORGANIZATION_ID,
                  act5.PROJECT_ORGANIZATION_ID),
              act5.TIME_ID,
              act5.CALENDAR_TYPE,
              act5.GL_CALENDAR_ID,
              act5.PA_CALENDAR_ID,
              act5.TXN_CURRENCY_CODE
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
        src3.PROJECT_ORG_ID,
        src3.PROJECT_ORGANIZATION_ID,
        src3.TIME_ID,
        src3.PERIOD_TYPE_ID,
        src3.CALENDAR_TYPE,
        src3.GL_CALENDAR_ID,
        src3.PA_CALENDAR_ID,
        src3.DIFF_CURRENCY_CODE,
        src3.DIFF_ROWNUM,
        nvl(src3.CURRENCY_CODE, 'PJI$NULL')
      union all    -- snapshot reversals  -  PART 1  -  GL dates
                   -- Select old ITD amounts for snapshots with
                   -- reverse sign from base level fact
      select /*+ ordered full(map) parallel(map)
                         index(acp, PJI_AC_PROJ_F_N2)
                         use_nl(acp)
                         full(info) */
        p_worker_id                        WORKER_ID,
        acp.PROJECT_ID,
        acp.PROJECT_ORG_ID,
        acp.PROJECT_ORGANIZATION_ID,
        to_number(to_char(sysdate, 'J'))   TIME_ID,
        1                                  PERIOD_TYPE_ID,
        'C'                                CALENDAR_TYPE,
        info.GL_CALENDAR_ID,
        info.PA_CALENDAR_ID,
        acp.CURR_RECORD_TYPE_ID,
        acp.CURRENCY_CODE,
        to_number(null)                    REVENUE,
        to_number(null)                    FUNDING,
        to_number(null)                    INITIAL_FUNDING_AMOUNT,
        to_number(null)                    INITIAL_FUNDING_COUNT,
        to_number(null)                    ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                    ADDITIONAL_FUNDING_COUNT,
        to_number(null)                    CANCELLED_FUNDING_AMOUNT,
        to_number(null)                    CANCELLED_FUNDING_COUNT,
        to_number(null)                    FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                    FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                    REVENUE_WRITEOFF,
        to_number(null)                    AR_INVOICE_AMOUNT,
        to_number(null)                    AR_INVOICE_COUNT,
        -acp.AR_CASH_APPLIED_AMOUNT,
        to_number(null)                    AR_CASH_APPLIED_COUNT,
        to_number(null)                    AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                    AR_INVOICE_WRITEOFF_COUNT,
        to_number(null)                    AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                    AR_CREDIT_MEMO_COUNT,
        to_number(null)                    UNBILLED_RECEIVABLES,
        to_number(null)                    UNEARNED_REVENUE,
        -acp.AR_UNAPPR_INVOICE_AMOUNT,
        -acp.AR_UNAPPR_INVOICE_COUNT,
        -acp.AR_APPR_INVOICE_AMOUNT,
        -acp.AR_APPR_INVOICE_COUNT,
        -acp.AR_AMOUNT_DUE,
        -acp.AR_COUNT_DUE,
        -acp.AR_AMOUNT_OVERDUE,
        -acp.AR_COUNT_OVERDUE,
        to_number(null)                    DORMANT_BACKLOG_INACTIV,
        to_number(null)                    DORMANT_BACKLOG_START,
        to_number(null)                    LOST_BACKLOG,
        to_number(null)                    ACTIVE_BACKLOG,
        to_number(null)                    REVENUE_AT_RISK
      from
        PJI_PJI_PROJ_BATCH_MAP map,
        PJI_AC_PROJ_F          acp,
        FII_TIME_RPT_STRUCT    cal,
        PJI_ORG_EXTR_INFO      info
      where
        map.WORKER_ID           = p_worker_id                        and
        acp.PROJECT_ID          = map.PROJECT_ID                     and
        cal.REPORT_DATE         = trunc(sysdate, 'J')                and
        cal.CALENDAR_TYPE       = acp.CALENDAR_TYPE                  and
        cal.PERIOD_TYPE_ID      = acp.PERIOD_TYPE_ID                 and
        cal.TIME_ID             = acp.TIME_ID                        and
        cal.RECORD_TYPE_ID     <> 128                                and
        cal.RECORD_TYPE_ID     <> 256                                and
        cal.RECORD_TYPE_ID     <> 512                                and
        abs(nvl(acp.AR_CASH_APPLIED_AMOUNT,0)) +
          abs(nvl(acp.AR_UNAPPR_INVOICE_AMOUNT,0)) +
          abs(nvl(acp.AR_APPR_INVOICE_AMOUNT,0)) +
          abs(nvl(acp.AR_AMOUNT_DUE,0)) +
          abs(nvl(acp.AR_AMOUNT_OVERDUE,0)) +
          abs(nvl(acp.AR_UNAPPR_INVOICE_COUNT,0)) +
          abs(nvl(acp.AR_APPR_INVOICE_COUNT,0)) +
          abs(nvl(acp.AR_COUNT_DUE,0)) +
          abs(nvl(acp.AR_COUNT_OVERDUE,0)) > 0
        and acp.PROJECT_ORG_ID = info.ORG_ID
      union all    -- snapshot reversals  -  PART 2  -  PA dates
                   -- Select old ITD amounts for snapshots with
                   -- reverse sign from base level fact
      select /*+ ordered full(map) parallel(map)
                         index(acp, PJI_AC_PROJ_F_N2)
                         use_nl(acp)
                         full(info) */
        p_worker_id                        WORKER_ID,
        acp.PROJECT_ID,
        acp.PROJECT_ORG_ID,
        acp.PROJECT_ORGANIZATION_ID,
        to_number(to_char(sysdate, 'J'))   TIME_ID,
        1                                  PERIOD_TYPE_ID,
        'P'                                CALENDAR_TYPE,
        info.GL_CALENDAR_ID,
        info.PA_CALENDAR_ID,
        acp.CURR_RECORD_TYPE_ID,
        acp.CURRENCY_CODE,
        to_number(null)                    REVENUE,
        to_number(null)                    FUNDING,
        to_number(null)                    INITIAL_FUNDING_AMOUNT,
        to_number(null)                    INITIAL_FUNDING_COUNT,
        to_number(null)                    ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                    ADDITIONAL_FUNDING_COUNT,
        to_number(null)                    CANCELLED_FUNDING_AMOUNT,
        to_number(null)                    CANCELLED_FUNDING_COUNT,
        to_number(null)                    FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                    FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                    REVENUE_WRITEOFF,
        to_number(null)                    AR_INVOICE_AMOUNT,
        to_number(null)                    AR_INVOICE_COUNT,
        -acp.AR_CASH_APPLIED_AMOUNT,
        to_number(null)                    AR_CASH_APPLIED_COUNT,
        to_number(null)                    AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                    AR_INVOICE_WRITEOFF_COUNT,
        to_number(null)                    AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                    AR_CREDIT_MEMO_COUNT,
        to_number(null)                    UNBILLED_RECEIVABLES,
        to_number(null)                    UNEARNED_REVENUE,
        -acp.AR_UNAPPR_INVOICE_AMOUNT,
        -acp.AR_UNAPPR_INVOICE_COUNT,
        -acp.AR_APPR_INVOICE_AMOUNT,
        -acp.AR_APPR_INVOICE_COUNT,
        -acp.AR_AMOUNT_DUE,
        -acp.AR_COUNT_DUE,
        -acp.AR_AMOUNT_OVERDUE,
        -acp.AR_COUNT_OVERDUE,
        to_number(null)                    DORMANT_BACKLOG_INACTIV,
        to_number(null)                    DORMANT_BACKLOG_START,
        to_number(null)                    LOST_BACKLOG,
        to_number(null)                    ACTIVE_BACKLOG,
        to_number(null)                    REVENUE_AT_RISK

      from
        PJI_PJI_PROJ_BATCH_MAP  map,
        PJI_AC_PROJ_F           acp,
        PJI_ORG_EXTR_INFO       info,
        FII_TIME_CAL_RPT_STRUCT cal
      where
        l_pa_calendar_flag      = 'Y'                                and
        map.WORKER_ID           = p_worker_id                        and
        acp.PROJECT_ID          = map.PROJECT_ID                     and
        info.ORG_ID             = acp.PROJECT_ORG_ID                 and
        cal.CALENDAR_ID         = info.PA_CALENDAR_ID                and
        cal.REPORT_DATE         = trunc(sysdate, 'J')                and
        cal.PERIOD_TYPE_ID     <> 16                                 and
        acp.CALENDAR_TYPE       = 'P'                                and
        cal.PERIOD_TYPE_ID      = acp.PERIOD_TYPE_ID                 and
        cal.TIME_ID             = acp.TIME_ID                        and
        cal.RECORD_TYPE_ID     <> 128                                and
        cal.RECORD_TYPE_ID     <> 256                                and
        cal.RECORD_TYPE_ID     <> 512                                and
        abs(nvl(acp.AR_CASH_APPLIED_AMOUNT,0)) +
          abs(nvl(acp.AR_UNAPPR_INVOICE_AMOUNT,0)) +
          abs(nvl(acp.AR_APPR_INVOICE_AMOUNT,0)) +
          abs(nvl(acp.AR_AMOUNT_DUE,0)) +
          abs(nvl(acp.AR_AMOUNT_OVERDUE,0)) +
          abs(nvl(acp.AR_UNAPPR_INVOICE_COUNT,0)) +
          abs(nvl(acp.AR_APPR_INVOICE_COUNT,0)) +
          abs(nvl(acp.AR_COUNT_DUE,0)) +
          abs(nvl(acp.AR_COUNT_OVERDUE,0)) > 0
      union all    -- snapshot reversals  -  PART 3  -  PA day for week subst.
                   -- Select old ITD amounts for snapshots with
                   -- reverse sign from base level fact
      select /*+ ordered full(map) parallel(map)
                         index(acp, PJI_AC_PROJ_F_N2)
                         use_nl(acp)
                         full(info) */
        p_worker_id                        WORKER_ID,
        acp.PROJECT_ID,
        acp.PROJECT_ORG_ID,
        acp.PROJECT_ORGANIZATION_ID,
        to_number(to_char(sysdate, 'J'))   TIME_ID,
        1                                  PERIOD_TYPE_ID,
        'P'                                CALENDAR_TYPE,
        info.GL_CALENDAR_ID,
        info.PA_CALENDAR_ID,
        acp.CURR_RECORD_TYPE_ID,
        acp.CURRENCY_CODE,
        to_number(null)                    REVENUE,
        to_number(null)                    FUNDING,
        to_number(null)                    INITIAL_FUNDING_AMOUNT,
        to_number(null)                    INITIAL_FUNDING_COUNT,
        to_number(null)                    ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                    ADDITIONAL_FUNDING_COUNT,
        to_number(null)                    CANCELLED_FUNDING_AMOUNT,
        to_number(null)                    CANCELLED_FUNDING_COUNT,
        to_number(null)                    FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                    FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                    REVENUE_WRITEOFF,
        to_number(null)                    AR_INVOICE_AMOUNT,
        to_number(null)                    AR_INVOICE_COUNT,
        -acp.AR_CASH_APPLIED_AMOUNT,
        to_number(null)                    AR_CASH_APPLIED_COUNT,
        to_number(null)                    AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                    AR_INVOICE_WRITEOFF_COUNT,
        to_number(null)                    AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                    AR_CREDIT_MEMO_COUNT,
        to_number(null)                    UNBILLED_RECEIVABLES,
        to_number(null)                    UNEARNED_REVENUE,
        -acp.AR_UNAPPR_INVOICE_AMOUNT,
        -acp.AR_UNAPPR_INVOICE_COUNT,
        -acp.AR_APPR_INVOICE_AMOUNT,
        -acp.AR_APPR_INVOICE_COUNT,
        -acp.AR_AMOUNT_DUE,
        -acp.AR_COUNT_DUE,
        -acp.AR_AMOUNT_OVERDUE,
        -acp.AR_COUNT_OVERDUE,
        to_number(null)                    DORMANT_BACKLOG_INACTIV,
        to_number(null)                    DORMANT_BACKLOG_START,
        to_number(null)                    LOST_BACKLOG,
        to_number(null)                    ACTIVE_BACKLOG,
        to_number(null)                    REVENUE_AT_RISK

      from
        PJI_PJI_PROJ_BATCH_MAP map,
        PJI_AC_PROJ_F          acp,
        PJI_ORG_EXTR_INFO      info,
        PJI_TIME_PA_RPT_STR_MV cal
      where
        l_pa_calendar_flag      = 'Y'                                and
        map.WORKER_ID           = p_worker_id                         and
        acp.PROJECT_ID          = map.PROJECT_ID                     and
        info.ORG_ID             = acp.PROJECT_ORG_ID                 and
        cal.CALENDAR_ID         = info.PA_CALENDAR_ID                and
        cal.REPORT_DATE         = trunc(sysdate, 'J')                and
        acp.CALENDAR_TYPE       = 'P'                                and
        cal.PERIOD_TYPE_ID      = acp.PERIOD_TYPE_ID                 and
        cal.TIME_ID             = acp.TIME_ID                        and
        abs(nvl(acp.AR_CASH_APPLIED_AMOUNT,0)) +
          abs(nvl(acp.AR_UNAPPR_INVOICE_AMOUNT,0)) +
          abs(nvl(acp.AR_APPR_INVOICE_AMOUNT,0)) +
          abs(nvl(acp.AR_AMOUNT_DUE,0)) +
          abs(nvl(acp.AR_AMOUNT_OVERDUE,0)) +
          abs(nvl(acp.AR_UNAPPR_INVOICE_COUNT,0)) +
          abs(nvl(acp.AR_APPR_INVOICE_COUNT,0)) +
          abs(nvl(acp.AR_COUNT_DUE,0)) +
          abs(nvl(acp.AR_COUNT_OVERDUE,0)) > 0
      ) src4
    group by
      src4.WORKER_ID,
      src4.PROJECT_ID,
      src4.PROJECT_ORG_ID,
      src4.PROJECT_ORGANIZATION_ID,
      src4.TIME_ID,
      src4.PERIOD_TYPE_ID,
      src4.CALENDAR_TYPE,
      src4.GL_CALENDAR_ID,
      src4.PA_CALENDAR_ID,
      src4.CURR_RECORD_TYPE_ID,
      src4.CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_ACT.AGGREGATE_ACT_SLICES(p_worker_id);');

    commit;

  end AGGREGATE_ACT_SLICES;


  -- -----------------------------------------------------
  -- procedure PURGE_ACT_DATA
  -- -----------------------------------------------------
  procedure PURGE_ACT_DATA (p_worker_id in number) is

    l_process   varchar2(30);
    l_schema    varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ROLLUP_ACT.PURGE_ACT_DATA(p_worker_id);')) then
      return;
    end if;

    delete
    from   PJI_FM_AGGR_ACT5
    where  ROWID in (select STG_ROWID
                     from   PJI_PJI_RMAP_ACT
                     where  WORKER_ID = p_worker_id);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ROLLUP_ACT.PURGE_ACT_DATA(p_worker_id);');

    commit;

  end PURGE_ACT_DATA;


  -- -----------------------------------------------------
  -- procedure EXPAND_ACT_CAL_EN
  -- -----------------------------------------------------
  procedure EXPAND_ACT_CAL_EN (p_worker_id in number,
                               p_backlog_flag in varchar2 default 'N') is

    l_process   varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_EN(p_worker_id, ''' ||
                                                       p_backlog_flag || ''');'
            )) then
      return;
    end if;

    insert /*+ append parallel(act3_i) */ into PJI_FM_AGGR_ACT3 act3_i  --  in EXPAND_ACT_CAL_EN
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      FUNDING,
      INITIAL_FUNDING_AMOUNT,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_AMOUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_AMOUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_AMOUNT,
      FUNDING_ADJUSTMENT_COUNT,
      REVENUE_WRITEOFF,
      AR_INVOICE_AMOUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_AMOUNT,
      AR_CASH_APPLIED_COUNT,
      AR_INVOICE_WRITEOFF_AMOUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_AMOUNT,
      AR_CREDIT_MEMO_COUNT,
      UNBILLED_RECEIVABLES,
      UNEARNED_REVENUE,
      AR_UNAPPR_INVOICE_AMOUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_AMOUNT,
      AR_APPR_INVOICE_COUNT,
      AR_AMOUNT_DUE,
      AR_COUNT_DUE,
      AR_AMOUNT_OVERDUE,
      AR_COUNT_OVERDUE,
      DORMANT_BACKLOG_INACTIV,
      DORMANT_BACKLOG_START,
      LOST_BACKLOG,
      ACTIVE_BACKLOG,
      REVENUE_AT_RISK
    )
    select /*+ ordered
               full(time) use_hash(time) swap_join_inputs(time)
               full(act)  use_hash(act)  parallel(act) */
      p_worker_id,
      act.PROJECT_ID,
      act.PROJECT_ORG_ID,
      act.PROJECT_ORGANIZATION_ID,
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
           end  TIME_ID,
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
           end  PERIOD_TYPE_ID,
      'E' CALENDAR_TYPE,
      bitand(act.CURR_RECORD_TYPE_ID, 247)  CURR_RECORD_TYPE_ID,
      act.CURRENCY_CODE,
      sum(act.REVENUE),
      sum(act.FUNDING),
      sum(act.INITIAL_FUNDING_AMOUNT),
      sum(act.INITIAL_FUNDING_COUNT),
      sum(act.ADDITIONAL_FUNDING_AMOUNT),
      sum(act.ADDITIONAL_FUNDING_COUNT),
      sum(act.CANCELLED_FUNDING_AMOUNT),
      sum(act.CANCELLED_FUNDING_COUNT),
      sum(act.FUNDING_ADJUSTMENT_AMOUNT),
      sum(act.FUNDING_ADJUSTMENT_COUNT),
      sum(act.REVENUE_WRITEOFF),
      sum(act.AR_INVOICE_AMOUNT),
      sum(act.AR_INVOICE_COUNT),
      sum(act.AR_CASH_APPLIED_AMOUNT),
      sum(act.AR_CASH_APPLIED_COUNT),
      sum(act.AR_INVOICE_WRITEOFF_AMOUNT),
      sum(act.AR_INVOICE_WRITEOFF_COUNT),
      sum(act.AR_CREDIT_MEMO_AMOUNT),
      sum(act.AR_CREDIT_MEMO_COUNT),
      sum(act.UNBILLED_RECEIVABLES),
      sum(act.UNEARNED_REVENUE),
      sum(act.AR_UNAPPR_INVOICE_AMOUNT),
      sum(act.AR_UNAPPR_INVOICE_COUNT),
      sum(act.AR_APPR_INVOICE_AMOUNT),
      sum(act.AR_APPR_INVOICE_COUNT),
      sum(act.AR_AMOUNT_DUE),
      sum(act.AR_COUNT_DUE),
      sum(act.AR_AMOUNT_OVERDUE),
      sum(act.AR_COUNT_OVERDUE),
      sum(act.DORMANT_BACKLOG_INACTIV),
      sum(act.DORMANT_BACKLOG_START),
      sum(act.LOST_BACKLOG),
      sum(act.ACTIVE_BACKLOG),
      sum(act.REVENUE_AT_RISK)
    from
      FII_TIME_DAY     time,
      PJI_FM_AGGR_ACT3 act
    where
      act.PERIOD_TYPE_ID      = 1             and
      act.CALENDAR_TYPE       = 'C'           and
      act.CURR_RECORD_TYPE_ID not in (8, 256) and
      act.TIME_ID             = time.REPORT_DATE_JULIAN
    group by
      act.PROJECT_ID,
      act.PROJECT_ORG_ID,
      act.PROJECT_ORGANIZATION_ID,
      rollup (time.ENT_YEAR_ID,
              time.ENT_QTR_ID,
              time.ENT_PERIOD_ID),
      bitand(act.CURR_RECORD_TYPE_ID, 247),
      act.CURRENCY_CODE
    having
      not (grouping(time.ENT_YEAR_ID)   = 1 and
           grouping(time.ENT_QTR_ID)    = 1 and
           grouping(time.ENT_PERIOD_ID) = 1);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_EN(p_worker_id, ''' ||
                                               p_backlog_flag || ''');'
    );

    commit;

  end EXPAND_ACT_CAL_EN;


  -- -----------------------------------------------------
  -- procedure EXPAND_ACT_CAL_PA
  -- -----------------------------------------------------
  procedure EXPAND_ACT_CAL_PA (p_worker_id in number,
                               p_backlog_flag in varchar2 default 'N') is

    l_process   varchar2(30);

  begin

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
        (
          PJI_RM_SUM_MAIN.g_process,
          'PA_CALENDAR_FLAG'
        ) = 'N') then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_PA(p_worker_id, ''' ||
                                                       p_backlog_flag || ''');'
            )) then
      return;
    end if;

    insert /*+ append parallel(act3_i) */ into PJI_FM_AGGR_ACT3 act3_i  --  in EXPAND_ACT_CAL_PA
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      FUNDING,
      INITIAL_FUNDING_AMOUNT,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_AMOUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_AMOUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_AMOUNT,
      FUNDING_ADJUSTMENT_COUNT,
      REVENUE_WRITEOFF,
      AR_INVOICE_AMOUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_AMOUNT,
      AR_CASH_APPLIED_COUNT,
      AR_INVOICE_WRITEOFF_AMOUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_AMOUNT,
      AR_CREDIT_MEMO_COUNT,
      UNBILLED_RECEIVABLES,
      UNEARNED_REVENUE,
      AR_UNAPPR_INVOICE_AMOUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_AMOUNT,
      AR_APPR_INVOICE_COUNT,
      AR_AMOUNT_DUE,
      AR_COUNT_DUE,
      AR_AMOUNT_OVERDUE,
      AR_COUNT_OVERDUE,
      DORMANT_BACKLOG_INACTIV,
      DORMANT_BACKLOG_START,
      LOST_BACKLOG,
      ACTIVE_BACKLOG,
      REVENUE_AT_RISK
    )
    select /*+ ordered
               full(time) use_hash(time) parallel(time) swap_join_inputs(time)
               full(act)  use_hash(act)  parallel(act) */
      p_worker_id,
      act.PROJECT_ID,
      act.PROJECT_ORG_ID,
      act.PROJECT_ORGANIZATION_ID,
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
           end,
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
           end,
      'P',
      act.CURR_RECORD_TYPE_ID,
      act.CURRENCY_CODE,
      sum(act.REVENUE),
      sum(act.FUNDING),
      sum(act.INITIAL_FUNDING_AMOUNT),
      sum(act.INITIAL_FUNDING_COUNT),
      sum(act.ADDITIONAL_FUNDING_AMOUNT),
      sum(act.ADDITIONAL_FUNDING_COUNT),
      sum(act.CANCELLED_FUNDING_AMOUNT),
      sum(act.CANCELLED_FUNDING_COUNT),
      sum(act.FUNDING_ADJUSTMENT_AMOUNT),
      sum(act.FUNDING_ADJUSTMENT_COUNT),
      sum(act.REVENUE_WRITEOFF),
      sum(act.AR_INVOICE_AMOUNT),
      sum(act.AR_INVOICE_COUNT),
      sum(act.AR_CASH_APPLIED_AMOUNT),
      sum(act.AR_CASH_APPLIED_COUNT),
      sum(act.AR_INVOICE_WRITEOFF_AMOUNT),
      sum(act.AR_INVOICE_WRITEOFF_COUNT),
      sum(act.AR_CREDIT_MEMO_AMOUNT),
      sum(act.AR_CREDIT_MEMO_COUNT),
      sum(act.UNBILLED_RECEIVABLES),
      sum(act.UNEARNED_REVENUE),
      sum(act.AR_UNAPPR_INVOICE_AMOUNT),
      sum(act.AR_UNAPPR_INVOICE_COUNT),
      sum(act.AR_APPR_INVOICE_AMOUNT),
      sum(act.AR_APPR_INVOICE_COUNT),
      sum(act.AR_AMOUNT_DUE),
      sum(act.AR_COUNT_DUE),
      sum(act.AR_AMOUNT_OVERDUE),
      sum(act.AR_COUNT_OVERDUE),
      sum(act.DORMANT_BACKLOG_INACTIV),
      sum(act.DORMANT_BACKLOG_START),
      sum(act.LOST_BACKLOG),
      sum(act.ACTIVE_BACKLOG),
      sum(act.REVENUE_AT_RISK)
    from
      FII_TIME_CAL_DAY_MV time,
      PJI_FM_AGGR_ACT3    act
    where
      act.PERIOD_TYPE_ID                 = 1                  and
      act.CALENDAR_TYPE                  = 'P'                and
      to_date(to_char(act.TIME_ID), 'J') = time.REPORT_DATE   and
      act.PA_CALENDAR_ID                 = time.CALENDAR_ID
    group by
      act.PROJECT_ID,
      act.PROJECT_ORG_ID,
      act.PROJECT_ORGANIZATION_ID,
      rollup (time.CAL_YEAR_ID,
              time.CAL_QTR_ID,
              time.CAL_PERIOD_ID),
      act.CURR_RECORD_TYPE_ID,
      act.CURRENCY_CODE
    having
      not (grouping(time.CAL_YEAR_ID)   = 1 and
           grouping(time.CAL_QTR_ID)    = 1 and
           grouping(time.CAL_PERIOD_ID) = 1);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_PA(p_worker_id, ''' ||
                                               p_backlog_flag || ''');'
    );

    commit;

  end EXPAND_ACT_CAL_PA;


  -- -----------------------------------------------------
  -- procedure EXPAND_ACT_CAL_GL
  -- -----------------------------------------------------
  procedure EXPAND_ACT_CAL_GL (p_worker_id in number,
                               p_backlog_flag in varchar2 default 'N') is

    l_process   varchar2(30);

  begin

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
        (
          PJI_RM_SUM_MAIN.g_process,
          'GL_CALENDAR_FLAG'
        ) = 'N') then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_GL(p_worker_id, ''' ||
                                                       p_backlog_flag || ''');'
            )) then
      return;
    end if;

    insert /*+ append parallel(act3_i) */ into PJI_FM_AGGR_ACT3 act3_i  --  in EXPAND_ACT_CAL_GL
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      FUNDING,
      INITIAL_FUNDING_AMOUNT,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_AMOUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_AMOUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_AMOUNT,
      FUNDING_ADJUSTMENT_COUNT,
      REVENUE_WRITEOFF,
      AR_INVOICE_AMOUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_AMOUNT,
      AR_CASH_APPLIED_COUNT,
      AR_INVOICE_WRITEOFF_AMOUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_AMOUNT,
      AR_CREDIT_MEMO_COUNT,
      UNBILLED_RECEIVABLES,
      UNEARNED_REVENUE,
      AR_UNAPPR_INVOICE_AMOUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_AMOUNT,
      AR_APPR_INVOICE_COUNT,
      AR_AMOUNT_DUE,
      AR_COUNT_DUE,
      AR_AMOUNT_OVERDUE,
      AR_COUNT_OVERDUE,
      DORMANT_BACKLOG_INACTIV,
      DORMANT_BACKLOG_START,
      LOST_BACKLOG,
      ACTIVE_BACKLOG,
      REVENUE_AT_RISK
    )
    select
      p_worker_id,
      act.PROJECT_ID,
      act.PROJECT_ORG_ID,
      act.PROJECT_ORGANIZATION_ID,
      act.TIME_ID,
      act.PERIOD_TYPE_ID,
      act.CALENDAR_TYPE,
      decode(act.PERIOD_TYPE_ID,
             32, act.CURR_RECORD_TYPE_ID,
                 bitand(act.CURR_RECORD_TYPE_ID, 247)) CURR_RECORD_TYPE_ID,
      act.CURRENCY_CODE,
      act.REVENUE,
      act.FUNDING,
      act.INITIAL_FUNDING_AMOUNT,
      act.INITIAL_FUNDING_COUNT,
      act.ADDITIONAL_FUNDING_AMOUNT,
      act.ADDITIONAL_FUNDING_COUNT,
      act.CANCELLED_FUNDING_AMOUNT,
      act.CANCELLED_FUNDING_COUNT,
      act.FUNDING_ADJUSTMENT_AMOUNT,
      act.FUNDING_ADJUSTMENT_COUNT,
      act.REVENUE_WRITEOFF,
      act.AR_INVOICE_AMOUNT,
      act.AR_INVOICE_COUNT,
      act.AR_CASH_APPLIED_AMOUNT,
      act.AR_CASH_APPLIED_COUNT,
      act.AR_INVOICE_WRITEOFF_AMOUNT,
      act.AR_INVOICE_WRITEOFF_COUNT,
      act.AR_CREDIT_MEMO_AMOUNT,
      act.AR_CREDIT_MEMO_COUNT,
      act.UNBILLED_RECEIVABLES,
      act.UNEARNED_REVENUE,
      act.AR_UNAPPR_INVOICE_AMOUNT,
      act.AR_UNAPPR_INVOICE_COUNT,
      act.AR_APPR_INVOICE_AMOUNT,
      act.AR_APPR_INVOICE_COUNT,
      act.AR_AMOUNT_DUE,
      act.AR_COUNT_DUE,
      act.AR_AMOUNT_OVERDUE,
      act.AR_COUNT_OVERDUE,
      act.DORMANT_BACKLOG_INACTIV,
      act.DORMANT_BACKLOG_START,
      act.LOST_BACKLOG,
      act.ACTIVE_BACKLOG,
      act.REVENUE_AT_RISK
    from
    (
    select /*+ ordered
               full(time) use_hash(time) parallel(time) swap_join_inputs(time)
               full(act)  use_hash(act)  parallel(act) */
      act.PROJECT_ID,
      act.PROJECT_ORG_ID,
      act.PROJECT_ORGANIZATION_ID,
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
           end  TIME_ID,
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
           end  PERIOD_TYPE_ID,
      'G' CALENDAR_TYPE,
      act.CURR_RECORD_TYPE_ID,
      act.CURRENCY_CODE,
      sum(act.REVENUE)                    REVENUE,
      sum(act.FUNDING)                    FUNDING,
      sum(act.INITIAL_FUNDING_AMOUNT)     INITIAL_FUNDING_AMOUNT,
      sum(act.INITIAL_FUNDING_COUNT)      INITIAL_FUNDING_COUNT,
      sum(act.ADDITIONAL_FUNDING_AMOUNT)  ADDITIONAL_FUNDING_AMOUNT,
      sum(act.ADDITIONAL_FUNDING_COUNT)   ADDITIONAL_FUNDING_COUNT,
      sum(act.CANCELLED_FUNDING_AMOUNT)   CANCELLED_FUNDING_AMOUNT,
      sum(act.CANCELLED_FUNDING_COUNT)    CANCELLED_FUNDING_COUNT,
      sum(act.FUNDING_ADJUSTMENT_AMOUNT)  FUNDING_ADJUSTMENT_AMOUNT,
      sum(act.FUNDING_ADJUSTMENT_COUNT)   FUNDING_ADJUSTMENT_COUNT,
      sum(act.REVENUE_WRITEOFF)           REVENUE_WRITEOFF,
      sum(act.AR_INVOICE_AMOUNT)          AR_INVOICE_AMOUNT,
      sum(act.AR_INVOICE_COUNT)           AR_INVOICE_COUNT,
      sum(act.AR_CASH_APPLIED_AMOUNT)     AR_CASH_APPLIED_AMOUNT,
      sum(act.AR_CASH_APPLIED_COUNT)      AR_CASH_APPLIED_COUNT,
      sum(act.AR_INVOICE_WRITEOFF_AMOUNT) AR_INVOICE_WRITEOFF_AMOUNT,
      sum(act.AR_INVOICE_WRITEOFF_COUNT)  AR_INVOICE_WRITEOFF_COUNT,
      sum(act.AR_CREDIT_MEMO_AMOUNT)      AR_CREDIT_MEMO_AMOUNT,
      sum(act.AR_CREDIT_MEMO_COUNT)       AR_CREDIT_MEMO_COUNT,
      sum(act.UNBILLED_RECEIVABLES)       UNBILLED_RECEIVABLES,
      sum(act.UNEARNED_REVENUE)           UNEARNED_REVENUE,
      sum(act.AR_UNAPPR_INVOICE_AMOUNT)   AR_UNAPPR_INVOICE_AMOUNT,
      sum(act.AR_UNAPPR_INVOICE_COUNT)    AR_UNAPPR_INVOICE_COUNT,
      sum(act.AR_APPR_INVOICE_AMOUNT)     AR_APPR_INVOICE_AMOUNT,
      sum(act.AR_APPR_INVOICE_COUNT)      AR_APPR_INVOICE_COUNT,
      sum(act.AR_AMOUNT_DUE)              AR_AMOUNT_DUE,
      sum(act.AR_COUNT_DUE)               AR_COUNT_DUE,
      sum(act.AR_AMOUNT_OVERDUE)          AR_AMOUNT_OVERDUE,
      sum(act.AR_COUNT_OVERDUE)           AR_COUNT_OVERDUE,
      sum(act.DORMANT_BACKLOG_INACTIV)    DORMANT_BACKLOG_INACTIV,
      sum(act.DORMANT_BACKLOG_START)      DORMANT_BACKLOG_START,
      sum(act.LOST_BACKLOG)               LOST_BACKLOG,
      sum(act.ACTIVE_BACKLOG)             ACTIVE_BACKLOG,
      sum(act.REVENUE_AT_RISK)            REVENUE_AT_RISK
    from
      FII_TIME_CAL_DAY_MV time,
      PJI_FM_AGGR_ACT3    act
    where
      act.PERIOD_TYPE_ID                 = 1                  and
      act.CALENDAR_TYPE                  = 'C'                and
      to_date(to_char(act.TIME_ID), 'J') = time.REPORT_DATE   and
      act.GL_CALENDAR_ID                 = time.CALENDAR_ID
    group by
      act.PROJECT_ID,
      act.PROJECT_ORG_ID,
      act.PROJECT_ORGANIZATION_ID,
      rollup (time.CAL_YEAR_ID,
              time.CAL_QTR_ID,
              time.CAL_PERIOD_ID),
      act.CURR_RECORD_TYPE_ID,
      act.CURRENCY_CODE
    having
      not (grouping(time.CAL_YEAR_ID)   = 1 and
           grouping(time.CAL_QTR_ID)    = 1 and
           grouping(time.CAL_PERIOD_ID) = 1)
    ) act
    where
      not (act.CURR_RECORD_TYPE_ID in (8, 256) and
           act.PERIOD_TYPE_ID <> 32);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_GL(p_worker_id, ''' ||
                                               p_backlog_flag || ''');'
    );

    commit;

  end EXPAND_ACT_CAL_GL;


  -- -----------------------------------------------------
  -- procedure EXPAND_ACT_CAL_WK
  -- -----------------------------------------------------
  procedure EXPAND_ACT_CAL_WK (p_worker_id in number,
                               p_backlog_flag in varchar2 default 'N') is

    l_process   varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_WK(p_worker_id, ''' ||
                                                       p_backlog_flag || ''');'
            )) then
      return;
    end if;

    insert /*+ append parallel(act3_i) */ into PJI_FM_AGGR_ACT3 act3_i  --  in EXPAND_ACT_CAL_WK
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      FUNDING,
      INITIAL_FUNDING_AMOUNT,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_AMOUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_AMOUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_AMOUNT,
      FUNDING_ADJUSTMENT_COUNT,
      REVENUE_WRITEOFF,
      AR_INVOICE_AMOUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_AMOUNT,
      AR_CASH_APPLIED_COUNT,
      AR_INVOICE_WRITEOFF_AMOUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_AMOUNT,
      AR_CREDIT_MEMO_COUNT,
      UNBILLED_RECEIVABLES,
      UNEARNED_REVENUE,
      AR_UNAPPR_INVOICE_AMOUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_AMOUNT,
      AR_APPR_INVOICE_COUNT,
      AR_AMOUNT_DUE,
      AR_COUNT_DUE,
      AR_AMOUNT_OVERDUE,
      AR_COUNT_OVERDUE,
      DORMANT_BACKLOG_INACTIV,
      DORMANT_BACKLOG_START,
      LOST_BACKLOG,
      ACTIVE_BACKLOG,
      REVENUE_AT_RISK
    )
    select /*+ ordered
               full(time) use_hash(time) swap_join_inputs(time)
               full(act)  use_hash(act)  parallel(act) */
      p_worker_id,
      act.PROJECT_ID,
      act.PROJECT_ORG_ID,
      act.PROJECT_ORGANIZATION_ID,
      time.WEEK_ID TIME_ID,
      16,
      'E',
      bitand(act.CURR_RECORD_TYPE_ID, 247) CURR_RECORD_TYPE_ID,
      act.CURRENCY_CODE,
      sum(act.REVENUE),
      sum(act.FUNDING),
      sum(act.INITIAL_FUNDING_AMOUNT),
      sum(act.INITIAL_FUNDING_COUNT),
      sum(act.ADDITIONAL_FUNDING_AMOUNT),
      sum(act.ADDITIONAL_FUNDING_COUNT),
      sum(act.CANCELLED_FUNDING_AMOUNT),
      sum(act.CANCELLED_FUNDING_COUNT),
      sum(act.FUNDING_ADJUSTMENT_AMOUNT),
      sum(act.FUNDING_ADJUSTMENT_COUNT),
      sum(act.REVENUE_WRITEOFF),
      sum(act.AR_INVOICE_AMOUNT),
      sum(act.AR_INVOICE_COUNT),
      sum(act.AR_CASH_APPLIED_AMOUNT),
      sum(act.AR_CASH_APPLIED_COUNT),
      sum(act.AR_INVOICE_WRITEOFF_AMOUNT),
      sum(act.AR_INVOICE_WRITEOFF_COUNT),
      sum(act.AR_CREDIT_MEMO_AMOUNT),
      sum(act.AR_CREDIT_MEMO_COUNT),
      sum(act.UNBILLED_RECEIVABLES),
      sum(act.UNEARNED_REVENUE),
      sum(act.AR_UNAPPR_INVOICE_AMOUNT),
      sum(act.AR_UNAPPR_INVOICE_COUNT),
      sum(act.AR_APPR_INVOICE_AMOUNT),
      sum(act.AR_APPR_INVOICE_COUNT),
      sum(act.AR_AMOUNT_DUE),
      sum(act.AR_COUNT_DUE),
      sum(act.AR_AMOUNT_OVERDUE),
      sum(act.AR_COUNT_OVERDUE),
      sum(act.DORMANT_BACKLOG_INACTIV),
      sum(act.DORMANT_BACKLOG_START),
      sum(act.LOST_BACKLOG),
      sum(act.ACTIVE_BACKLOG),
      sum(act.REVENUE_AT_RISK)
    from
      FII_TIME_DAY     time,
      PJI_FM_AGGR_ACT3 act
    where
      act.PERIOD_TYPE_ID      = 1             and
      act.CALENDAR_TYPE       = 'C'           and
      act.CURR_RECORD_TYPE_ID not in (8, 256) and
      act.TIME_ID             = time.REPORT_DATE_JULIAN
    group by
      act.PROJECT_ID,
      act.PROJECT_ORG_ID,
      act.PROJECT_ORGANIZATION_ID,
      time.WEEK_ID,
      bitand(act.CURR_RECORD_TYPE_ID, 247),
      act.CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_WK(p_worker_id, ''' ||
                                               p_backlog_flag || ''');'
    );

    commit;

  end EXPAND_ACT_CAL_WK;


  -- -----------------------------------------------------
  -- procedure MERGE_ACT_INTO_ACP
  -- -----------------------------------------------------
  procedure MERGE_ACT_INTO_ACP (p_worker_id in number,
                                p_backlog_flag in varchar2 default 'N') is

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
              'PJI_FM_SUM_ROLLUP_ACT.MERGE_ACT_INTO_ACP(p_worker_id, ''' ||
                                                        p_backlog_flag ||
                                                        ''');'
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

    if (l_extraction_type = 'FULL' and nvl(p_backlog_flag, 'N') = 'N') then

      insert /*+ append parallel(acp) */ into PJI_AC_PROJ_F acp
      (
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        TIME_ID,
        PROJECT_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        REVENUE,
        INITIAL_FUNDING_AMOUNT,
        INITIAL_FUNDING_COUNT,
        ADDITIONAL_FUNDING_AMOUNT,
        ADDITIONAL_FUNDING_COUNT,
        CANCELLED_FUNDING_AMOUNT,
        CANCELLED_FUNDING_COUNT,
        FUNDING_ADJUSTMENT_AMOUNT,
        FUNDING_ADJUSTMENT_COUNT,
        REVENUE_WRITEOFF,
        AR_INVOICE_AMOUNT,
        AR_INVOICE_COUNT,
        AR_CASH_APPLIED_AMOUNT,
        AR_INVOICE_WRITEOFF_AMOUNT,
        AR_INVOICE_WRITEOFF_COUNT,
        AR_CREDIT_MEMO_AMOUNT,
        AR_CREDIT_MEMO_COUNT,
        UNBILLED_RECEIVABLES,
        UNEARNED_REVENUE,
        AR_UNAPPR_INVOICE_AMOUNT,
        AR_UNAPPR_INVOICE_COUNT,
        AR_APPR_INVOICE_AMOUNT,
        AR_APPR_INVOICE_COUNT,
        AR_AMOUNT_DUE,
        AR_COUNT_DUE,
        AR_AMOUNT_OVERDUE,
        AR_COUNT_OVERDUE,
        DORMANT_BACKLOG_INACTIV,
        DORMANT_BACKLOG_START,
        LOST_BACKLOG,
        ACTIVE_BACKLOG,
        REVENUE_AT_RISK,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ full(act)   parallel(act) */
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        TIME_ID,
        PROJECT_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        REVENUE,
        INITIAL_FUNDING_AMOUNT,
        INITIAL_FUNDING_COUNT,
        ADDITIONAL_FUNDING_AMOUNT,
        ADDITIONAL_FUNDING_COUNT,
        CANCELLED_FUNDING_AMOUNT,
        CANCELLED_FUNDING_COUNT,
        FUNDING_ADJUSTMENT_AMOUNT,
        FUNDING_ADJUSTMENT_COUNT,
        REVENUE_WRITEOFF,
        AR_INVOICE_AMOUNT,
        AR_INVOICE_COUNT,
        AR_CASH_APPLIED_AMOUNT,
        AR_INVOICE_WRITEOFF_AMOUNT,
        AR_INVOICE_WRITEOFF_COUNT,
        AR_CREDIT_MEMO_AMOUNT,
        AR_CREDIT_MEMO_COUNT,
        UNBILLED_RECEIVABLES,
        UNEARNED_REVENUE,
        AR_UNAPPR_INVOICE_AMOUNT,
        AR_UNAPPR_INVOICE_COUNT,
        AR_APPR_INVOICE_AMOUNT,
        AR_APPR_INVOICE_COUNT,
        AR_AMOUNT_DUE,
        AR_COUNT_DUE,
        AR_AMOUNT_OVERDUE,
        AR_COUNT_OVERDUE,
        DORMANT_BACKLOG_INACTIV,
        DORMANT_BACKLOG_START,
        LOST_BACKLOG,
        ACTIVE_BACKLOG,
        REVENUE_AT_RISK,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PJI_FM_AGGR_ACT3 act
      where
        (nvl(REVENUE                   , 0) <> 0 or
         nvl(INITIAL_FUNDING_AMOUNT    , 0) <> 0 or
         nvl(INITIAL_FUNDING_COUNT     , 0) <> 0 or
         nvl(ADDITIONAL_FUNDING_AMOUNT , 0) <> 0 or
         nvl(ADDITIONAL_FUNDING_COUNT  , 0) <> 0 or
         nvl(CANCELLED_FUNDING_AMOUNT  , 0) <> 0 or
         nvl(CANCELLED_FUNDING_COUNT   , 0) <> 0 or
         nvl(FUNDING_ADJUSTMENT_AMOUNT , 0) <> 0 or
         nvl(FUNDING_ADJUSTMENT_COUNT  , 0) <> 0 or
         nvl(REVENUE_WRITEOFF          , 0) <> 0 or
         nvl(AR_INVOICE_AMOUNT         , 0) <> 0 or
         nvl(AR_INVOICE_COUNT          , 0) <> 0 or
         nvl(AR_CASH_APPLIED_AMOUNT    , 0) <> 0 or
         nvl(AR_INVOICE_WRITEOFF_AMOUNT, 0) <> 0 or
         nvl(AR_INVOICE_WRITEOFF_COUNT , 0) <> 0 or
         nvl(AR_CREDIT_MEMO_AMOUNT     , 0) <> 0 or
         nvl(AR_CREDIT_MEMO_COUNT      , 0) <> 0 or
         nvl(UNBILLED_RECEIVABLES      , 0) <> 0 or
         nvl(UNEARNED_REVENUE          , 0) <> 0 or
         nvl(AR_UNAPPR_INVOICE_AMOUNT  , 0) <> 0 or
         nvl(AR_UNAPPR_INVOICE_COUNT   , 0) <> 0 or
         nvl(AR_APPR_INVOICE_AMOUNT    , 0) <> 0 or
         nvl(AR_APPR_INVOICE_COUNT     , 0) <> 0 or
         nvl(AR_AMOUNT_DUE             , 0) <> 0 or
         nvl(AR_COUNT_DUE              , 0) <> 0 or
         nvl(AR_AMOUNT_OVERDUE         , 0) <> 0 or
         nvl(AR_COUNT_OVERDUE          , 0) <> 0 or
         nvl(DORMANT_BACKLOG_INACTIV   , 0) <> 0 or
         nvl(DORMANT_BACKLOG_START     , 0) <> 0 or
         nvl(LOST_BACKLOG              , 0) <> 0 or
         nvl(ACTIVE_BACKLOG            , 0) <> 0 or
         nvl(REVENUE_AT_RISK           , 0) <> 0);

    else -- not initial data load

      merge /*+ parallel(acp) */ into PJI_AC_PROJ_F acp
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
          REVENUE,
          INITIAL_FUNDING_AMOUNT,
          INITIAL_FUNDING_COUNT,
          ADDITIONAL_FUNDING_AMOUNT,
          ADDITIONAL_FUNDING_COUNT,
          CANCELLED_FUNDING_AMOUNT,
          CANCELLED_FUNDING_COUNT,
          FUNDING_ADJUSTMENT_AMOUNT,
          FUNDING_ADJUSTMENT_COUNT,
          REVENUE_WRITEOFF,
          AR_INVOICE_AMOUNT,
          AR_INVOICE_COUNT,
          AR_CASH_APPLIED_AMOUNT,
          AR_INVOICE_WRITEOFF_AMOUNT,
          AR_INVOICE_WRITEOFF_COUNT,
          AR_CREDIT_MEMO_AMOUNT,
          AR_CREDIT_MEMO_COUNT,
          UNBILLED_RECEIVABLES,
          UNEARNED_REVENUE,
          AR_UNAPPR_INVOICE_AMOUNT,
          AR_UNAPPR_INVOICE_COUNT,
          AR_APPR_INVOICE_AMOUNT,
          AR_APPR_INVOICE_COUNT,
          AR_AMOUNT_DUE,
          AR_COUNT_DUE,
          AR_AMOUNT_OVERDUE,
          AR_COUNT_OVERDUE,
          DORMANT_BACKLOG_INACTIV,
          DORMANT_BACKLOG_START,
          LOST_BACKLOG,
          ACTIVE_BACKLOG,
          REVENUE_AT_RISK,
          l_last_update_date              LAST_UPDATE_DATE,
          l_last_updated_by               LAST_UPDATED_BY,
          l_creation_date                 CREATION_DATE,
          l_created_by                    CREATED_BY,
          l_last_update_login             LAST_UPDATE_LOGIN
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
            sum(REVENUE)                    REVENUE,
            sum(INITIAL_FUNDING_AMOUNT)     INITIAL_FUNDING_AMOUNT,
            sum(INITIAL_FUNDING_COUNT)      INITIAL_FUNDING_COUNT,
            sum(ADDITIONAL_FUNDING_AMOUNT)  ADDITIONAL_FUNDING_AMOUNT,
            sum(ADDITIONAL_FUNDING_COUNT)   ADDITIONAL_FUNDING_COUNT,
            sum(CANCELLED_FUNDING_AMOUNT)   CANCELLED_FUNDING_AMOUNT,
            sum(CANCELLED_FUNDING_COUNT)    CANCELLED_FUNDING_COUNT,
            sum(FUNDING_ADJUSTMENT_AMOUNT)  FUNDING_ADJUSTMENT_AMOUNT,
            sum(FUNDING_ADJUSTMENT_COUNT)   FUNDING_ADJUSTMENT_COUNT,
            sum(REVENUE_WRITEOFF)           REVENUE_WRITEOFF,
            sum(AR_INVOICE_AMOUNT)          AR_INVOICE_AMOUNT,
            sum(AR_INVOICE_COUNT)           AR_INVOICE_COUNT,
            sum(AR_CASH_APPLIED_AMOUNT)     AR_CASH_APPLIED_AMOUNT,
            sum(AR_INVOICE_WRITEOFF_AMOUNT) AR_INVOICE_WRITEOFF_AMOUNT,
            sum(AR_INVOICE_WRITEOFF_COUNT)  AR_INVOICE_WRITEOFF_COUNT,
            sum(AR_CREDIT_MEMO_AMOUNT)      AR_CREDIT_MEMO_AMOUNT,
            sum(AR_CREDIT_MEMO_COUNT)       AR_CREDIT_MEMO_COUNT,
            sum(UNBILLED_RECEIVABLES)       UNBILLED_RECEIVABLES,
            sum(UNEARNED_REVENUE)           UNEARNED_REVENUE,
            sum(AR_UNAPPR_INVOICE_AMOUNT)   AR_UNAPPR_INVOICE_AMOUNT,
            sum(AR_UNAPPR_INVOICE_COUNT)    AR_UNAPPR_INVOICE_COUNT,
            sum(AR_APPR_INVOICE_AMOUNT)     AR_APPR_INVOICE_AMOUNT,
            sum(AR_APPR_INVOICE_COUNT)      AR_APPR_INVOICE_COUNT,
            sum(AR_AMOUNT_DUE)              AR_AMOUNT_DUE,
            sum(AR_COUNT_DUE)               AR_COUNT_DUE,
            sum(AR_AMOUNT_OVERDUE)          AR_AMOUNT_OVERDUE,
            sum(AR_COUNT_OVERDUE)           AR_COUNT_OVERDUE,
            sum(DORMANT_BACKLOG_INACTIV)    DORMANT_BACKLOG_INACTIV,
            sum(DORMANT_BACKLOG_START)      DORMANT_BACKLOG_START,
            sum(LOST_BACKLOG)               LOST_BACKLOG,
            sum(ACTIVE_BACKLOG)             ACTIVE_BACKLOG,
            sum(REVENUE_AT_RISK)            REVENUE_AT_RISK
          from
            (
            select /*+ full(act)  parallel(act)  */
              PROJECT_ORG_ID,
              PROJECT_ORGANIZATION_ID,
              TIME_ID,
              PROJECT_ID,
              PERIOD_TYPE_ID,
              CALENDAR_TYPE,
              CURR_RECORD_TYPE_ID,
              CURRENCY_CODE,
              REVENUE,
              INITIAL_FUNDING_AMOUNT,
              INITIAL_FUNDING_COUNT,
              ADDITIONAL_FUNDING_AMOUNT,
              ADDITIONAL_FUNDING_COUNT,
              CANCELLED_FUNDING_AMOUNT,
              CANCELLED_FUNDING_COUNT,
              FUNDING_ADJUSTMENT_AMOUNT,
              FUNDING_ADJUSTMENT_COUNT,
              REVENUE_WRITEOFF,
              AR_INVOICE_AMOUNT,
              AR_INVOICE_COUNT,
              AR_CASH_APPLIED_AMOUNT,
              AR_INVOICE_WRITEOFF_AMOUNT,
              AR_INVOICE_WRITEOFF_COUNT,
              AR_CREDIT_MEMO_AMOUNT,
              AR_CREDIT_MEMO_COUNT,
              UNBILLED_RECEIVABLES,
              UNEARNED_REVENUE,
              AR_UNAPPR_INVOICE_AMOUNT,
              AR_UNAPPR_INVOICE_COUNT,
              AR_APPR_INVOICE_AMOUNT,
              AR_APPR_INVOICE_COUNT,
              AR_AMOUNT_DUE,
              AR_COUNT_DUE,
              AR_AMOUNT_OVERDUE,
              AR_COUNT_OVERDUE,
              DORMANT_BACKLOG_INACTIV,
              DORMANT_BACKLOG_START,
              LOST_BACKLOG,
              ACTIVE_BACKLOG,
              REVENUE_AT_RISK
            from
              PJI_FM_AGGR_ACT3 act
            union all                       -- partial refresh
            select /*+ ordered full(map)  parallel(map)
                               index(acp, PJI_AC_PROJ_F_N2)  use_nl(acp)  */
              acp.PROJECT_ORG_ID,
              acp.PROJECT_ORGANIZATION_ID,
              acp.TIME_ID,
              acp.PROJECT_ID,
              acp.PERIOD_TYPE_ID,
              acp.CALENDAR_TYPE,
              acp.CURR_RECORD_TYPE_ID,
              acp.CURRENCY_CODE,
              -acp.REVENUE,
              -acp.INITIAL_FUNDING_AMOUNT,
              -acp.INITIAL_FUNDING_COUNT,
              -acp.ADDITIONAL_FUNDING_AMOUNT,
              -acp.ADDITIONAL_FUNDING_COUNT,
              -acp.CANCELLED_FUNDING_AMOUNT,
              -acp.CANCELLED_FUNDING_COUNT,
              -acp.FUNDING_ADJUSTMENT_AMOUNT,
              -acp.FUNDING_ADJUSTMENT_COUNT,
              -acp.REVENUE_WRITEOFF,
              -acp.AR_INVOICE_AMOUNT,
              -acp.AR_INVOICE_COUNT,
              to_number(null) AR_CASH_APPLIED_AMOUNT,
              -acp.AR_INVOICE_WRITEOFF_AMOUNT,
              -acp.AR_INVOICE_WRITEOFF_COUNT,
              -acp.AR_CREDIT_MEMO_AMOUNT,
              -acp.AR_CREDIT_MEMO_COUNT,
              -acp.UNBILLED_RECEIVABLES,
              -acp.UNEARNED_REVENUE,
              to_number(null) AR_UNAPPR_INVOICE_AMOUNT,
              to_number(null) AR_UNAPPR_INVOICE_COUNT,
              to_number(null) AR_APPR_INVOICE_AMOUNT,
              to_number(null) AR_APPR_INVOICE_COUNT,
              to_number(null) AR_AMOUNT_DUE,
              to_number(null) AR_COUNT_DUE,
              to_number(null) AR_AMOUNT_OVERDUE,
              to_number(null) AR_COUNT_OVERDUE,
              to_number(null) DORMANT_BACKLOG_INACTIV,
              to_number(null) DORMANT_BACKLOG_START,
              to_number(null) LOST_BACKLOG,
              to_number(null) ACTIVE_BACKLOG,
              to_number(null) REVENUE_AT_RISK
            from
              PJI_PJI_PROJ_BATCH_MAP map,
              PJI_AC_PROJ_F acp
            where
              nvl(p_backlog_flag, 'N') = 'N'         and
              l_extraction_type        = 'PARTIAL'   and
              map.WORKER_ID            = p_worker_id and
              map.EXTRACTION_TYPE      = 'P'         and
              acp.PROJECT_ID           = map.PROJECT_ID
            )
          group by
            PROJECT_ORG_ID,
            PROJECT_ORGANIZATION_ID,
            TIME_ID,
            PROJECT_ID,
            PERIOD_TYPE_ID,
            CALENDAR_TYPE,
            CURR_RECORD_TYPE_ID,
            CURRENCY_CODE
          )
        where
          nvl(REVENUE                   , 0) <> 0 or
          nvl(INITIAL_FUNDING_AMOUNT    , 0) <> 0 or
          nvl(INITIAL_FUNDING_COUNT     , 0) <> 0 or
          nvl(ADDITIONAL_FUNDING_AMOUNT , 0) <> 0 or
          nvl(ADDITIONAL_FUNDING_COUNT  , 0) <> 0 or
          nvl(CANCELLED_FUNDING_AMOUNT  , 0) <> 0 or
          nvl(CANCELLED_FUNDING_COUNT   , 0) <> 0 or
          nvl(FUNDING_ADJUSTMENT_AMOUNT , 0) <> 0 or
          nvl(FUNDING_ADJUSTMENT_COUNT  , 0) <> 0 or
          nvl(REVENUE_WRITEOFF          , 0) <> 0 or
          nvl(AR_INVOICE_AMOUNT         , 0) <> 0 or
          nvl(AR_INVOICE_COUNT          , 0) <> 0 or
          nvl(AR_CASH_APPLIED_AMOUNT    , 0) <> 0 or
          nvl(AR_INVOICE_WRITEOFF_AMOUNT, 0) <> 0 or
          nvl(AR_INVOICE_WRITEOFF_COUNT , 0) <> 0 or
          nvl(AR_CREDIT_MEMO_AMOUNT     , 0) <> 0 or
          nvl(AR_CREDIT_MEMO_COUNT      , 0) <> 0 or
          nvl(UNBILLED_RECEIVABLES      , 0) <> 0 or
          nvl(UNEARNED_REVENUE          , 0) <> 0 or
          nvl(AR_UNAPPR_INVOICE_AMOUNT  , 0) <> 0 or
          nvl(AR_UNAPPR_INVOICE_COUNT   , 0) <> 0 or
          nvl(AR_APPR_INVOICE_AMOUNT    , 0) <> 0 or
          nvl(AR_APPR_INVOICE_COUNT     , 0) <> 0 or
          nvl(AR_AMOUNT_DUE             , 0) <> 0 or
          nvl(AR_COUNT_DUE              , 0) <> 0 or
          nvl(AR_AMOUNT_OVERDUE         , 0) <> 0 or
          nvl(AR_COUNT_OVERDUE          , 0) <> 0 or
          nvl(DORMANT_BACKLOG_INACTIV   , 0) <> 0 or
          nvl(DORMANT_BACKLOG_START     , 0) <> 0 or
          nvl(LOST_BACKLOG              , 0) <> 0 or
          nvl(ACTIVE_BACKLOG            , 0) <> 0 or
          nvl(REVENUE_AT_RISK           , 0) <> 0
      ) act
      on
      (
        act.PROJECT_ORG_ID          = acp.PROJECT_ORG_ID          and
        act.PROJECT_ORGANIZATION_ID = acp.PROJECT_ORGANIZATION_ID and
        act.TIME_ID                 = acp.TIME_ID                 and
        act.PROJECT_ID              = acp.PROJECT_ID              and
        act.PERIOD_TYPE_ID          = acp.PERIOD_TYPE_ID          and
        act.CALENDAR_TYPE           = acp.CALENDAR_TYPE           and
        act.CURR_RECORD_TYPE_ID     = acp.CURR_RECORD_TYPE_ID     and
        act.CURRENCY_CODE           = acp.CURRENCY_CODE
      )
      when matched then update set
        acp.REVENUE      = case when acp.REVENUE is null and
                                     act.REVENUE is null
                                then to_number(null)
                                else nvl(acp.REVENUE, 0) +
                                     nvl(act.REVENUE, 0)
                                end,
        acp.INITIAL_FUNDING_AMOUNT
                         = case when acp.INITIAL_FUNDING_AMOUNT is null and
                                     act.INITIAL_FUNDING_AMOUNT is null
                                then to_number(null)
                                else nvl(acp.INITIAL_FUNDING_AMOUNT, 0) +
                                     nvl(act.INITIAL_FUNDING_AMOUNT, 0)
                                end,
        acp.INITIAL_FUNDING_COUNT
                         = case when acp.INITIAL_FUNDING_COUNT is null and
                                     act.INITIAL_FUNDING_COUNT is null
                                then to_number(null)
                                else nvl(acp.INITIAL_FUNDING_COUNT, 0) +
                                     nvl(act.INITIAL_FUNDING_COUNT, 0)
                                end,
        acp.ADDITIONAL_FUNDING_AMOUNT
                         = case when acp.ADDITIONAL_FUNDING_AMOUNT is null and
                                     act.ADDITIONAL_FUNDING_AMOUNT is null
                                then to_number(null)
                                else nvl(acp.ADDITIONAL_FUNDING_AMOUNT, 0) +
                                     nvl(act.ADDITIONAL_FUNDING_AMOUNT, 0)
                                end,
        acp.ADDITIONAL_FUNDING_COUNT
                         = case when acp.ADDITIONAL_FUNDING_COUNT is null and
                                     act.ADDITIONAL_FUNDING_COUNT is null
                                then to_number(null)
                                else nvl(acp.ADDITIONAL_FUNDING_COUNT, 0) +
                                     nvl(act.ADDITIONAL_FUNDING_COUNT, 0)
                                end,
        acp.CANCELLED_FUNDING_AMOUNT
                         = case when acp.CANCELLED_FUNDING_AMOUNT is null and
                                     act.CANCELLED_FUNDING_AMOUNT is null
                                then to_number(null)
                                else nvl(acp.CANCELLED_FUNDING_AMOUNT, 0) +
                                     nvl(act.CANCELLED_FUNDING_AMOUNT, 0)
                                end,
        acp.CANCELLED_FUNDING_COUNT
                         = case when acp.CANCELLED_FUNDING_COUNT is null and
                                     act.CANCELLED_FUNDING_COUNT is null
                                then to_number(null)
                                else nvl(acp.CANCELLED_FUNDING_COUNT, 0) +
                                     nvl(act.CANCELLED_FUNDING_COUNT, 0)
                                end,
        acp.FUNDING_ADJUSTMENT_AMOUNT
                         = case when acp.FUNDING_ADJUSTMENT_AMOUNT is null and
                                     act.FUNDING_ADJUSTMENT_AMOUNT is null
                                then to_number(null)
                                else nvl(acp.FUNDING_ADJUSTMENT_AMOUNT, 0) +
                                     nvl(act.FUNDING_ADJUSTMENT_AMOUNT, 0)
                                end,
        acp.FUNDING_ADJUSTMENT_COUNT
                         = case when acp.FUNDING_ADJUSTMENT_COUNT is null and
                                     act.FUNDING_ADJUSTMENT_COUNT is null
                                then to_number(null)
                                else nvl(acp.FUNDING_ADJUSTMENT_COUNT, 0) +
                                     nvl(act.FUNDING_ADJUSTMENT_COUNT, 0)
                                end,
        acp.REVENUE_WRITEOFF
                         = case when acp.REVENUE_WRITEOFF is null and
                                     act.REVENUE_WRITEOFF is null
                                then to_number(null)
                                else nvl(acp.REVENUE_WRITEOFF, 0) +
                                     nvl(act.REVENUE_WRITEOFF, 0)
                                end,
        acp.AR_INVOICE_AMOUNT
                         = case when acp.AR_INVOICE_AMOUNT is null and
                                     act.AR_INVOICE_AMOUNT is null
                                then to_number(null)
                                else nvl(acp.AR_INVOICE_AMOUNT, 0) +
                                     nvl(act.AR_INVOICE_AMOUNT, 0)
                                end,
        acp.AR_INVOICE_COUNT
                         = case when acp.AR_INVOICE_COUNT is null and
                                     act.AR_INVOICE_COUNT is null
                                then to_number(null)
                                else nvl(acp.AR_INVOICE_COUNT, 0) +
                                     nvl(act.AR_INVOICE_COUNT, 0)
                                end,
        acp.AR_CASH_APPLIED_AMOUNT
                         = case when acp.AR_CASH_APPLIED_AMOUNT is null and
                                     act.AR_CASH_APPLIED_AMOUNT is null
                                then to_number(null)
                                else nvl(acp.AR_CASH_APPLIED_AMOUNT, 0) +
                                     nvl(act.AR_CASH_APPLIED_AMOUNT, 0)
                                end,
        acp.AR_INVOICE_WRITEOFF_AMOUNT
                         = case when acp.AR_INVOICE_WRITEOFF_AMOUNT is null and
                                     act.AR_INVOICE_WRITEOFF_AMOUNT is null
                                then to_number(null)
                                else nvl(acp.AR_INVOICE_WRITEOFF_AMOUNT, 0) +
                                     nvl(act.AR_INVOICE_WRITEOFF_AMOUNT, 0)
                                end,
        acp.AR_INVOICE_WRITEOFF_COUNT
                         = case when acp.AR_INVOICE_WRITEOFF_COUNT is null and
                                     act.AR_INVOICE_WRITEOFF_COUNT is null
                                then to_number(null)
                                else nvl(acp.AR_INVOICE_WRITEOFF_COUNT, 0) +
                                     nvl(act.AR_INVOICE_WRITEOFF_COUNT, 0)
                                end,
        acp.AR_CREDIT_MEMO_AMOUNT
                         = case when acp.AR_CREDIT_MEMO_AMOUNT is null and
                                     act.AR_CREDIT_MEMO_AMOUNT is null
                                then to_number(null)
                                else nvl(acp.AR_CREDIT_MEMO_AMOUNT, 0) +
                                     nvl(act.AR_CREDIT_MEMO_AMOUNT, 0)
                                end,
        acp.AR_CREDIT_MEMO_COUNT
                         = case when acp.AR_CREDIT_MEMO_COUNT is null and
                                     act.AR_CREDIT_MEMO_COUNT is null
                                then to_number(null)
                                else nvl(acp.AR_CREDIT_MEMO_COUNT, 0) +
                                     nvl(act.AR_CREDIT_MEMO_COUNT, 0)
                                end,
        acp.UNBILLED_RECEIVABLES
                         = case when acp.UNBILLED_RECEIVABLES is null and
                                     act.UNBILLED_RECEIVABLES is null
                                then to_number(null)
                                else nvl(acp.UNBILLED_RECEIVABLES, 0) +
                                     nvl(act.UNBILLED_RECEIVABLES, 0)
                                end,
        acp.UNEARNED_REVENUE
                         = case when acp.UNEARNED_REVENUE is null and
                                     act.UNEARNED_REVENUE is null
                                then to_number(null)
                                else nvl(acp.UNEARNED_REVENUE, 0) +
                                     nvl(act.UNEARNED_REVENUE, 0)
                                end,
        acp.AR_UNAPPR_INVOICE_AMOUNT
                         = case when acp.AR_UNAPPR_INVOICE_AMOUNT is null and
                                     act.AR_UNAPPR_INVOICE_AMOUNT is null
                                then to_number(null)
                                else nvl(acp.AR_UNAPPR_INVOICE_AMOUNT, 0) +
                                     nvl(act.AR_UNAPPR_INVOICE_AMOUNT, 0)
                                end,
        acp.AR_UNAPPR_INVOICE_COUNT
                         = case when acp.AR_UNAPPR_INVOICE_COUNT is null and
                                     act.AR_UNAPPR_INVOICE_COUNT is null
                                then to_number(null)
                                else nvl(acp.AR_UNAPPR_INVOICE_COUNT, 0) +
                                     nvl(act.AR_UNAPPR_INVOICE_COUNT, 0)
                                end,
        acp.AR_APPR_INVOICE_AMOUNT
                         = case when acp.AR_APPR_INVOICE_AMOUNT is null and
                                     act.AR_APPR_INVOICE_AMOUNT is null
                                then to_number(null)
                                else nvl(acp.AR_APPR_INVOICE_AMOUNT, 0) +
                                     nvl(act.AR_APPR_INVOICE_AMOUNT, 0)
                                end,
        acp.AR_APPR_INVOICE_COUNT
                         = case when acp.AR_APPR_INVOICE_COUNT is null and
                                     act.AR_APPR_INVOICE_COUNT is null
                                then to_number(null)
                                else nvl(acp.AR_APPR_INVOICE_COUNT, 0) +
                                     nvl(act.AR_APPR_INVOICE_COUNT, 0)
                                end,
        acp.AR_AMOUNT_DUE
                         = case when acp.AR_AMOUNT_DUE is null and
                                     act.AR_AMOUNT_DUE is null
                                then to_number(null)
                                else nvl(acp.AR_AMOUNT_DUE, 0) +
                                     nvl(act.AR_AMOUNT_DUE, 0)
                                end,
        acp.AR_COUNT_DUE = case when acp.AR_COUNT_DUE is null and
                                     act.AR_COUNT_DUE is null
                                then to_number(null)
                                else nvl(acp.AR_COUNT_DUE, 0) +
                                     nvl(act.AR_COUNT_DUE, 0)
                                end,
        acp.AR_AMOUNT_OVERDUE
                         = case when acp.AR_AMOUNT_OVERDUE is null and
                                     act.AR_AMOUNT_OVERDUE is null
                                then to_number(null)
                                else nvl(acp.AR_AMOUNT_OVERDUE, 0) +
                                     nvl(act.AR_AMOUNT_OVERDUE, 0)
                                end,
        acp.AR_COUNT_OVERDUE
                         = case when acp.AR_COUNT_OVERDUE is null and
                                     act.AR_COUNT_OVERDUE is null
                                then to_number(null)
                                else nvl(acp.AR_COUNT_OVERDUE, 0) +
                                     nvl(act.AR_COUNT_OVERDUE, 0)
                                end,
        acp.DORMANT_BACKLOG_INACTIV
                         = case when acp.DORMANT_BACKLOG_INACTIV is null and
                                     act.DORMANT_BACKLOG_INACTIV is null
                                then to_number(null)
                                else nvl(acp.DORMANT_BACKLOG_INACTIV, 0) +
                                     nvl(act.DORMANT_BACKLOG_INACTIV, 0)
                                end,
        acp.DORMANT_BACKLOG_START
                         = case when acp.DORMANT_BACKLOG_START is null and
                                     act.DORMANT_BACKLOG_START is null
                                then to_number(null)
                                else nvl(acp.DORMANT_BACKLOG_START, 0) +
                                     nvl(act.DORMANT_BACKLOG_START, 0)
                                end,
        acp.LOST_BACKLOG
                         = case when acp.LOST_BACKLOG is null and
                                     act.LOST_BACKLOG is null
                                then to_number(null)
                                else nvl(acp.LOST_BACKLOG, 0) +
                                     nvl(act.LOST_BACKLOG, 0)
                                end,
        acp.ACTIVE_BACKLOG
                         = case when acp.ACTIVE_BACKLOG is null and
                                     act.ACTIVE_BACKLOG is null
                                then to_number(null)
                                else nvl(acp.ACTIVE_BACKLOG, 0) +
                                     nvl(act.ACTIVE_BACKLOG, 0)
                                end,
        acp.REVENUE_AT_RISK
                         = case when acp.REVENUE_AT_RISK is null and
                                     act.REVENUE_AT_RISK is null
                                then to_number(null)
                                else nvl(acp.REVENUE_AT_RISK, 0) +
                                     nvl(act.REVENUE_AT_RISK, 0)
                                end,
        acp.LAST_UPDATE_DATE
             = act.LAST_UPDATE_DATE,
        acp.LAST_UPDATED_BY
             = act.LAST_UPDATED_BY,
        acp.LAST_UPDATE_LOGIN
             = act.LAST_UPDATE_LOGIN
      when not matched then insert
      (
        acp.PROJECT_ORG_ID,
        acp.PROJECT_ORGANIZATION_ID,
        acp.TIME_ID,
        acp.PROJECT_ID,
        acp.PERIOD_TYPE_ID,
        acp.CALENDAR_TYPE,
        acp.CURR_RECORD_TYPE_ID,
        acp.CURRENCY_CODE,
        acp.REVENUE,
        acp.INITIAL_FUNDING_AMOUNT,
        acp.INITIAL_FUNDING_COUNT,
        acp.ADDITIONAL_FUNDING_AMOUNT,
        acp.ADDITIONAL_FUNDING_COUNT,
        acp.CANCELLED_FUNDING_AMOUNT,
        acp.CANCELLED_FUNDING_COUNT,
        acp.FUNDING_ADJUSTMENT_AMOUNT,
        acp.FUNDING_ADJUSTMENT_COUNT,
        acp.REVENUE_WRITEOFF,
        acp.AR_INVOICE_AMOUNT,
        acp.AR_INVOICE_COUNT,
        acp.AR_CASH_APPLIED_AMOUNT,
        acp.AR_INVOICE_WRITEOFF_AMOUNT,
        acp.AR_INVOICE_WRITEOFF_COUNT,
        acp.AR_CREDIT_MEMO_AMOUNT,
        acp.AR_CREDIT_MEMO_COUNT,
        acp.UNBILLED_RECEIVABLES,
        acp.UNEARNED_REVENUE,
        acp.AR_UNAPPR_INVOICE_AMOUNT,
        acp.AR_UNAPPR_INVOICE_COUNT,
        acp.AR_APPR_INVOICE_AMOUNT,
        acp.AR_APPR_INVOICE_COUNT,
        acp.AR_AMOUNT_DUE,
        acp.AR_COUNT_DUE,
        acp.AR_AMOUNT_OVERDUE,
        acp.AR_COUNT_OVERDUE,
        acp.DORMANT_BACKLOG_INACTIV,
        acp.DORMANT_BACKLOG_START,
        acp.LOST_BACKLOG,
        acp.ACTIVE_BACKLOG,
        acp.REVENUE_AT_RISK,
        acp.LAST_UPDATE_DATE,
        acp.LAST_UPDATED_BY,
        acp.CREATION_DATE,
        acp.CREATED_BY,
        acp.LAST_UPDATE_LOGIN
      )
      values
      (
        act.PROJECT_ORG_ID,
        act.PROJECT_ORGANIZATION_ID,
        act.TIME_ID,
        act.PROJECT_ID,
        act.PERIOD_TYPE_ID,
        act.CALENDAR_TYPE,
        act.CURR_RECORD_TYPE_ID,
        act.CURRENCY_CODE,
        act.REVENUE,
        act.INITIAL_FUNDING_AMOUNT,
        act.INITIAL_FUNDING_COUNT,
        act.ADDITIONAL_FUNDING_AMOUNT,
        act.ADDITIONAL_FUNDING_COUNT,
        act.CANCELLED_FUNDING_AMOUNT,
        act.CANCELLED_FUNDING_COUNT,
        act.FUNDING_ADJUSTMENT_AMOUNT,
        act.FUNDING_ADJUSTMENT_COUNT,
        act.REVENUE_WRITEOFF,
        act.AR_INVOICE_AMOUNT,
        act.AR_INVOICE_COUNT,
        act.AR_CASH_APPLIED_AMOUNT,
        act.AR_INVOICE_WRITEOFF_AMOUNT,
        act.AR_INVOICE_WRITEOFF_COUNT,
        act.AR_CREDIT_MEMO_AMOUNT,
        act.AR_CREDIT_MEMO_COUNT,
        act.UNBILLED_RECEIVABLES,
        act.UNEARNED_REVENUE,
        act.AR_UNAPPR_INVOICE_AMOUNT,
        act.AR_UNAPPR_INVOICE_COUNT,
        act.AR_APPR_INVOICE_AMOUNT,
        act.AR_APPR_INVOICE_COUNT,
        act.AR_AMOUNT_DUE,
        act.AR_COUNT_DUE,
        act.AR_AMOUNT_OVERDUE,
        act.AR_COUNT_OVERDUE,
        act.DORMANT_BACKLOG_INACTIV,
        act.DORMANT_BACKLOG_START,
        act.LOST_BACKLOG,
        act.ACTIVE_BACKLOG,
        act.REVENUE_AT_RISK,
        act.LAST_UPDATE_DATE,
        act.LAST_UPDATED_BY,
        act.CREATION_DATE,
        act.CREATED_BY,
        act.LAST_UPDATE_LOGIN
      );

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_ACT.MERGE_ACT_INTO_ACP(p_worker_id, ''' ||
                                                p_backlog_flag || ''');'
    );

    if (p_backlog_flag = 'Y') then

      l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

      PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema ,
                                       'PJI_FM_AGGR_ACT3',
                                       'NORMAL',
                                       null);

    end if;

    commit;

  end MERGE_ACT_INTO_ACP;


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
              'PJI_FM_SUM_ROLLUP_ACT.PROJECT_ORGANIZATION(p_worker_id);'
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
             Update PJI_AC_PROJ_F
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
      'PJI_FM_SUM_ROLLUP_ACT.PROJECT_ORGANIZATION(p_worker_id);'
    );

    commit;

  end PROJECT_ORGANIZATION;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_ACO
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_ACO (p_worker_id in number) is

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
              'PJI_FM_SUM_ROLLUP_ACT.REFRESH_MVIEW_ACO(p_worker_id);'
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

    /* Stats gathered for this table in costing mviews refresh.
    FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pji_schema,
                                 TABNAME => 'PJI_ORG_DENORM',
                                 PERCENT => 10,
                                 DEGREE  => l_p_degree);
    */

    if (l_extraction_type = 'FULL') then
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_AC_ORG_F_MV',
                              'C',
                              'N');
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_AC_ORGO_F_MV',
                              'C',
                              'N');
    else
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pji_schema,
                                   TABNAME => 'MLOG$_PJI_AC_PROJ_F',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_AC_ORG_F_MV',
                              'F',
                              'N');
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_apps_schema,
                                   TABNAME => 'MLOG$_PJI_AC_ORG_F_MV',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_AC_ORGO_F_MV',
                              'F',
                              'N');
    end if;

    if (l_extraction_type <> 'INCREMENTAL') then
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_AC_ORG_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_AC_ORGO_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_ACT.REFRESH_MVIEW_ACO(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_ACO;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_ACC
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_ACC (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_pji_schema      varchar2(30);
    l_apps_schema     varchar2(30);
    l_p_degree        number;

    l_errbuf             varchar2(255);
    l_retcode            varchar2(255);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_ROLLUP_ACT.REFRESH_MVIEW_ACC(p_worker_id);'
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

    /* Stats gathered for this table in costing mviews refresh.
    FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pji_schema,
                                 TABNAME => 'PJI_PROJECT_CLASSES',
                                 PERCENT => 10,
                                 DEGREE  => l_p_degree);
    */

    if (l_extraction_type = 'FULL') then
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_AC_CLS_F_MV',
                              'C',
                              'N');
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_AC_CLSO_F_MV',
                              'C',
                              'N');
    else
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_AC_CLS_F_MV',
                              'F',
                              'N');
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_apps_schema,
                                   TABNAME => 'MLOG$_PJI_AC_CLS_F_MV',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_AC_CLSO_F_MV',
                              'F',
                              'N');
    end if;

    if (l_extraction_type <> 'INCREMENTAL') then
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_AC_CLS_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_AC_CLSO_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_ROLLUP_ACT.REFRESH_MVIEW_ACC(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_ACC;

end PJI_FM_SUM_ROLLUP_ACT;

/
