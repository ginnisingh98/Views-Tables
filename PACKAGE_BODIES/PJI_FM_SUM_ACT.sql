--------------------------------------------------------
--  DDL for Package Body PJI_FM_SUM_ACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_SUM_ACT" as
  /* $Header: PJISF08B.pls 120.1 2005/10/17 12:02:12 appldev noship $ */

  -- -----------------------------------------------------
  -- procedure BASE_SUMMARY
  -- -----------------------------------------------------
  procedure BASE_SUMMARY (p_worker_id in number) is

    l_process              varchar2(30);
    l_batch_id             number;
    l_min_date             number;
    l_schema               varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_ACT.BASE_SUMMARY(p_worker_id);')) then
      return;
    end if;

    l_batch_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      l_process,
      'CURRENT_BATCH'
    );

    l_min_date := to_number(to_char(to_date(
                  PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE'),
                  PJI_FM_SUM_MAIN.g_date_mask), 'J'));

    insert /*+ append parallel(act1_i) */ into PJI_FM_AGGR_ACT1 act1_i
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TASK_ID,
      CUSTOMER_ID,
      GL_TIME_ID,
      GL_PERIOD_NAME,
      PA_TIME_ID,
      PA_PERIOD_NAME,
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
      AR_COUNT_OVERDUE
    )
    select
      p_worker_id,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TASK_ID,
      CUSTOMER_ID,
      GL_TIME_ID,
      GL_PERIOD_NAME,
      PA_TIME_ID,
      PA_PERIOD_NAME,
      TXN_CURRENCY_CODE,
      sum(TXN_REVENUE),
      sum(TXN_FUNDING),
      sum(TXN_INITIAL_FUNDING_AMOUNT),
      sum(TXN_ADDITIONAL_FUNDING_AMOUNT),
      sum(TXN_CANCELLED_FUNDING_AMOUNT),
      sum(TXN_FUNDING_ADJUSTMENT_AMOUNT),
      sum(TXN_REVENUE_WRITEOFF),
      sum(TXN_AR_INVOICE_AMOUNT),
      sum(TXN_AR_CASH_APPLIED_AMOUNT),
      sum(TXN_AR_INVOICE_WRITEOFF_AMOUNT),
      sum(TXN_AR_CREDIT_MEMO_AMOUNT),
      sum(TXN_UNBILLED_RECEIVABLES),
      sum(TXN_UNEARNED_REVENUE),
      sum(TXN_AR_UNAPPR_INVOICE_AMOUNT),
      sum(TXN_AR_APPR_INVOICE_AMOUNT),
      sum(TXN_AR_AMOUNT_DUE),
      sum(TXN_AR_AMOUNT_OVERDUE),
      sum(PRJ_REVENUE),
      sum(PRJ_FUNDING),
      sum(PRJ_INITIAL_FUNDING_AMOUNT),
      sum(PRJ_ADDITIONAL_FUNDING_AMOUNT),
      sum(PRJ_CANCELLED_FUNDING_AMOUNT),
      sum(PRJ_FUNDING_ADJUSTMENT_AMOUNT),
      sum(PRJ_REVENUE_WRITEOFF),
      sum(PRJ_AR_INVOICE_AMOUNT),
      sum(PRJ_AR_CASH_APPLIED_AMOUNT),
      sum(PRJ_AR_INVOICE_WRITEOFF_AMOUNT),
      sum(PRJ_AR_CREDIT_MEMO_AMOUNT),
      sum(PRJ_UNBILLED_RECEIVABLES),
      sum(PRJ_UNEARNED_REVENUE),
      sum(PRJ_AR_UNAPPR_INVOICE_AMOUNT),
      sum(PRJ_AR_APPR_INVOICE_AMOUNT),
      sum(PRJ_AR_AMOUNT_DUE),
      sum(PRJ_AR_AMOUNT_OVERDUE),
      sum(POU_REVENUE),
      sum(POU_FUNDING),
      sum(POU_INITIAL_FUNDING_AMOUNT),
      sum(POU_ADDITIONAL_FUNDING_AMOUNT),
      sum(POU_CANCELLED_FUNDING_AMOUNT),
      sum(POU_FUNDING_ADJUSTMENT_AMOUNT),
      sum(POU_REVENUE_WRITEOFF),
      sum(POU_AR_INVOICE_AMOUNT),
      sum(POU_AR_CASH_APPLIED_AMOUNT),
      sum(POU_AR_INVOICE_WRITEOFF_AMOUNT),
      sum(POU_AR_CREDIT_MEMO_AMOUNT),
      sum(POU_UNBILLED_RECEIVABLES),
      sum(POU_UNEARNED_REVENUE),
      sum(POU_AR_UNAPPR_INVOICE_AMOUNT),
      sum(POU_AR_APPR_INVOICE_AMOUNT),
      sum(POU_AR_AMOUNT_DUE),
      sum(POU_AR_AMOUNT_OVERDUE),
      sum(INITIAL_FUNDING_COUNT),
      sum(ADDITIONAL_FUNDING_COUNT),
      sum(CANCELLED_FUNDING_COUNT),
      sum(FUNDING_ADJUSTMENT_COUNT),
      sum(AR_INVOICE_COUNT),
      sum(AR_CASH_APPLIED_COUNT),
      sum(AR_INVOICE_WRITEOFF_COUNT),
      sum(AR_CREDIT_MEMO_COUNT),
      sum(AR_UNAPPR_INVOICE_COUNT),
      sum(AR_APPR_INVOICE_COUNT),
      sum(AR_COUNT_DUE),
      sum(AR_COUNT_OVERDUE)
    from
      (
      select /*+ parallel(dinv) */   -- UBR, UER from draft invoices; functional currency only
        dinv.PROJECT_ID,
        dinv.PROJECT_ORG_ID,
        dinv.PROJECT_ORGANIZATION_ID,
        -1                                      TASK_ID,
        dinv.CUSTOMER_ID,
        greatest(to_number(to_char(dinv.GL_DATE,'J')),
                 l_min_date)                    GL_TIME_ID,
        null                                    GL_PERIOD_NAME,
        greatest(to_number(to_char(dinv.PA_DATE,'J')),
                 l_min_date)                    PA_TIME_ID,
        null                                    PA_PERIOD_NAME,
        null                                    TXN_CURRENCY_CODE,
        to_number(null)                         TXN_REVENUE,
        to_number(null)                         TXN_FUNDING,
        to_number(null)                         TXN_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         TXN_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         TXN_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         TXN_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         TXN_REVENUE_WRITEOFF,
        to_number(null)                         TXN_AR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         TXN_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         TXN_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         TXN_UNBILLED_RECEIVABLES,
        to_number(null)                         TXN_UNEARNED_REVENUE,
        to_number(null)                         TXN_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_AMOUNT_DUE,
        to_number(null)                         TXN_AR_AMOUNT_OVERDUE,
        to_number(null)                         PRJ_REVENUE,
        to_number(null)                         PRJ_FUNDING,
        to_number(null)                         PRJ_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         PRJ_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         PRJ_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         PRJ_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         PRJ_REVENUE_WRITEOFF,
        to_number(null)                         PRJ_AR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         PRJ_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         PRJ_UNBILLED_RECEIVABLES,
        to_number(null)                         PRJ_UNEARNED_REVENUE,
        to_number(null)                         PRJ_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_AMOUNT_DUE,
        to_number(null)                         PRJ_AR_AMOUNT_OVERDUE,
        to_number(null)                         POU_REVENUE,
        to_number(null)                         POU_FUNDING,
        to_number(null)                         POU_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         POU_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         POU_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         POU_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         POU_REVENUE_WRITEOFF,
        to_number(null)                         POU_AR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         POU_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         POU_AR_CREDIT_MEMO_AMOUNT,
        dinv.UNBILLED_RECEIVABLE_DR             POU_UNBILLED_RECEIVABLES,
        dinv.UNEARNED_REVENUE_CR                POU_UNEARNED_REVENUE,
        to_number(null)                         POU_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_AMOUNT_DUE,
        to_number(null)                         POU_AR_AMOUNT_OVERDUE,
        to_number(null)                         INITIAL_FUNDING_COUNT,
        to_number(null)                         ADDITIONAL_FUNDING_COUNT,
        to_number(null)                         CANCELLED_FUNDING_COUNT,
        to_number(null)                         FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                         AR_INVOICE_COUNT,
        to_number(null)                         AR_CASH_APPLIED_COUNT,
        to_number(null)                         AR_INVOICE_WRITEOFF_COUNT,
        to_number(null)                         AR_CREDIT_MEMO_COUNT,
        to_number(null)                         AR_UNAPPR_INVOICE_COUNT,
        to_number(null)                         AR_APPR_INVOICE_COUNT,
        to_number(null)                         AR_COUNT_DUE,
        to_number(null)                         AR_COUNT_OVERDUE
      from
        PJI_FM_EXTR_DINVC dinv
      where
        dinv.WORKER_ID = p_worker_id
      union all
      select /*+ parallel(drev) */   -- UBR, UER from draft revenues; functional currency only
        drev.PROJECT_ID,
        drev.PROJECT_ORG_ID,
        drev.PROJECT_ORGANIZATION_ID,
        -1                                      TASK_ID,
        drev.CUSTOMER_ID,
        greatest(to_number(to_char(drev.GL_DATE,'J')),
                 l_min_date)                    GL_TIME_ID,
        drev.GL_PERIOD_NAME,
        greatest(to_number(to_char(drev.PA_DATE,'J')),
                 l_min_date)                    PA_TIME_ID,
        drev.PA_PERIOD_NAME,
        null                                    TXN_CURRENCY_CODE,
        to_number(null)                         TXN_REVENUE,
        to_number(null)                         TXN_FUNDING,
        to_number(null)                         TXN_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         TXN_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         TXN_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         TXN_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         TXN_REVENUE_WRITEOFF,
        to_number(null)                         TXN_AR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         TXN_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         TXN_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         TXN_UNBILLED_RECEIVABLES,
        to_number(null)                         TXN_UNEARNED_REVENUE,
        to_number(null)                         TXN_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_AMOUNT_DUE,
        to_number(null)                         TXN_AR_AMOUNT_OVERDUE,
        to_number(null)                         PRJ_REVENUE,
        to_number(null)                         PRJ_FUNDING,
        to_number(null)                         PRJ_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         PRJ_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         PRJ_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         PRJ_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         PRJ_REVENUE_WRITEOFF,
        to_number(null)                         PRJ_AR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         PRJ_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         PRJ_UNBILLED_RECEIVABLES,
        to_number(null)                         PRJ_UNEARNED_REVENUE,
        to_number(null)                         PRJ_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_AMOUNT_DUE,
        to_number(null)                         PRJ_AR_AMOUNT_OVERDUE,
        to_number(null)                         POU_REVENUE,
        to_number(null)                         POU_FUNDING,
        to_number(null)                         POU_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         POU_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         POU_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         POU_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         POU_REVENUE_WRITEOFF,
        to_number(null)                         POU_AR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         POU_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         POU_AR_CREDIT_MEMO_AMOUNT,
        drev.POU_UBR                            POU_UNBILLED_RECEIVABLES,
        drev.POU_UER                            POU_UNEARNED_REVENUE,
        to_number(null)                         POU_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_AMOUNT_DUE,
        to_number(null)                         POU_AR_AMOUNT_OVERDUE,
        to_number(null)                         INITIAL_FUNDING_COUNT,
        to_number(null)                         ADDITIONAL_FUNDING_COUNT,
        to_number(null)                         CANCELLED_FUNDING_COUNT,
        to_number(null)                         FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                         AR_INVOICE_COUNT,
        to_number(null)                         AR_CASH_APPLIED_COUNT,
        to_number(null)                         AR_INVOICE_WRITEOFF_COUNT,
        to_number(null)                         AR_CREDIT_MEMO_COUNT,
        to_number(null)                         AR_UNAPPR_INVOICE_COUNT,
        to_number(null)                         AR_APPR_INVOICE_COUNT,
        to_number(null)                         AR_COUNT_DUE,
        to_number(null)                         AR_COUNT_OVERDUE
      from
        PJI_FM_EXTR_DREVN drev
      where
        drev.WORKER_ID = p_worker_id
      union all
      select /*+ parallel(fnd) */   -- funding in functional and project currencies
        fnd.PROJECT_ID,
        fnd.PROJECT_ORG_ID,
        fnd.PROJECT_ORGANIZATION_ID,
        -1                                      TASK_ID,
        fnd.CUSTOMER_ID,
        greatest(to_number(to_char(fnd.date_allocated,'J')),
                 l_min_date)                    GL_TIME_ID,
        null                                    GL_PERIOD_NAME,
        greatest(to_number(to_char(fnd.date_allocated,'J')),
                 l_min_date)                    PA_TIME_ID,
        null                                    PA_PERIOD_NAME,
        null                                    TXN_CURRENCY_CODE,
        to_number(null)                         TXN_REVENUE,
        to_number(null)                         TXN_FUNDING,
        to_number(null)                         TXN_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         TXN_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         TXN_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         TXN_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         TXN_REVENUE_WRITEOFF,
        to_number(null)                         TXN_AR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         TXN_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         TXN_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         TXN_UNBILLED_RECEIVABLES,
        to_number(null)                         TXN_UNEARNED_REVENUE,
        to_number(null)                         TXN_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_AMOUNT_DUE,
        to_number(null)                         TXN_AR_AMOUNT_OVERDUE,
        to_number(null)                         PRJ_REVENUE,
        fnd.prj_allocated_amount                PRJ_FUNDING,
        decode(fnd.funding_category
               , 'ORIGINAL'     , fnd.prj_allocated_amount
               , 'ADDITIONAL'   , 0
               , 'CANCELLATION' , 0
               , 'CORRECTION'   , 0
               , 'TRANSFER'     , 0
               , 'REVALUATION'  , 0
               , fnd.prj_allocated_amount)      PRJ_INITIAL_FUNDING_AMOUNT,
        decode(fnd.funding_category
               , 'ORIGINAL'     , 0
               , 'ADDITIONAL'   , fnd.prj_allocated_amount
               , 'CANCELLATION' , 0
               , 'CORRECTION'   , 0
               , 'TRANSFER'     , 0
               , 'REVALUATION'  , 0
               , 0)                             PRJ_ADDITIONAL_FUNDING_AMOUNT,
        decode(fnd.funding_category
               , 'ORIGINAL'     , 0
               , 'ADDITIONAL'   , 0
               , 'CANCELLATION' , fnd.prj_allocated_amount
               , 'CORRECTION'   , 0
               , 'TRANSFER'     , 0
               , 'REVALUATION'  , 0
               , 0)                             PRJ_CANCELLED_FUNDING_AMOUNT,
        decode(fnd.funding_category
               , 'ORIGINAL'     , 0
               , 'ADDITIONAL'   , 0
               , 'CANCELLATION' , 0
               , 'CORRECTION'   , fnd.prj_allocated_amount
               , 'TRANSFER'     , fnd.prj_allocated_amount
               , 'REVALUATION'  , fnd.prj_allocated_amount
               , 0)                             PRJ_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         PRJ_REVENUE_WRITEOFF,
        to_number(null)                         PRJ_AR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         PRJ_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         PRJ_UNBILLED_RECEIVABLES,
        to_number(null)                         PRJ_UNEARNED_REVENUE,
        to_number(null)                         PRJ_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_AMOUNT_DUE,
        to_number(null)                         PRJ_AR_AMOUNT_OVERDUE,
        to_number(null)                         POU_REVENUE,
        fnd.pou_allocated_amount                POU_FUNDING,
        decode(fnd.funding_category
               , 'ORIGINAL'     , fnd.pou_allocated_amount
               , 'ADDITIONAL'   , 0
               , 'CANCELLATION' , 0
               , 'CORRECTION'   , 0
               , 'TRANSFER'     , 0
               , 'REVALUATION'  , 0
               , fnd.pou_allocated_amount)      POU_INITIAL_FUNDING_AMOUNT,
        decode(fnd.funding_category
               , 'ORIGINAL'     , 0
               , 'ADDITIONAL'   , fnd.pou_allocated_amount
               , 'CANCELLATION' , 0
               , 'CORRECTION'   , 0
               , 'TRANSFER'     , 0
               , 'REVALUATION'  , 0
               , 0)                             POU_ADDITIONAL_FUNDING_AMOUNT,
        decode(fnd.funding_category
               , 'ORIGINAL'     , 0
               , 'ADDITIONAL'   , 0
               , 'CANCELLATION' , fnd.pou_allocated_amount
               , 'CORRECTION'   , 0
               , 'TRANSFER'     , 0
               , 'REVALUATION'  , 0
               , 0)                             POU_CANCELLED_FUNDING_AMOUNT,
        decode(fnd.funding_category
               , 'ORIGINAL'     , 0
               , 'ADDITIONAL'   , 0
               , 'CANCELLATION' , 0
               , 'CORRECTION'   , fnd.pou_allocated_amount
               , 'TRANSFER'     , fnd.pou_allocated_amount
               , 'REVALUATION'  , fnd.pou_allocated_amount
               , 0)                             POU_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         POU_REVENUE_WRITEOFF,
        to_number(null)                         POU_AR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         POU_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         POU_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         POU_UNBILLED_RECEIVABLES,
        to_number(null)                         POU_UNEARNED_REVENUE,
        to_number(null)                         POU_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_AMOUNT_DUE,
        to_number(null)                         POU_AR_AMOUNT_OVERDUE,
        decode(fnd.funding_category
               , 'ORIGINAL'     , 1
               , 'ADDITIONAL'   , 0
               , 'CANCELLATION' , 0
               , 'CORRECTION'   , 0
               , 'TRANSFER'     , 0
               , 'REVALUATION'  , 0
               , 1)                             INITIAL_FUNDING_COUNT,
        decode(fnd.funding_category
               , 'ORIGINAL'     , 0
               , 'ADDITIONAL'   , 1
               , 'CANCELLATION' , 0
               , 'CORRECTION'   , 0
               , 'TRANSFER'     , 0
               , 'REVALUATION'  , 0
               , 0)                             ADDITIONAL_FUNDING_COUNT,
        decode(fnd.funding_category
               , 'ORIGINAL'     , 0
               , 'ADDITIONAL'   , 0
               , 'CANCELLATION' , 1
               , 'CORRECTION'   , 0
               , 'TRANSFER'     , 0
               , 'REVALUATION'  , 0
               , 0)                             CANCELLED_FUNDING_COUNT,
        decode(fnd.funding_category
               , 'ORIGINAL'     , 0
               , 'ADDITIONAL'   , 0
               , 'CANCELLATION' , 0
               , 'CORRECTION'   , 1
               , 'TRANSFER'     , 1
               , 'REVALUATION'  , 1
               , 0)                             FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                         AR_INVOICE_COUNT,
        to_number(null)                         AR_CASH_APPLIED_COUNT,
        to_number(null)                         AR_INVOICE_WRITEOFF_COUNT,
        to_number(null)                         AR_CREDIT_MEMO_COUNT,
        to_number(null)                         AR_UNAPPR_INVOICE_COUNT,
        to_number(null)                         AR_APPR_INVOICE_COUNT,
        to_number(null)                         AR_COUNT_DUE,
        to_number(null)                         AR_COUNT_OVERDUE
      from
        PJI_FM_EXTR_FUNDG fnd
      where
        fnd.WORKER_ID = p_worker_id
      union all
      select /*+ parallel(fin1) */   -- FIN_TMP1 in functional and project currency
        fin1.Project_ID,
        fin1.Project_Org_ID,
        fin1.Project_Organization_ID,
        fin1.TASK_ID,
        fin1.Customer_ID,
        greatest(to_number(to_char(fin1.Recvr_GL_Date,'J')),
                 l_min_date)                    GL_TIME_ID,
        fin1.GL_PERIOD_NAME,
        greatest(to_number(to_char(fin1.Recvr_PA_Date,'J')),
                 l_min_date)                    PA_TIME_ID,
        fin1.PA_PERIOD_NAME,
        fin1.TXN_CURRENCY_CODE,
        fin1.TXN_REVENUE,
        to_number(null)                         TXN_FUNDING,
        to_number(null)                         TXN_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         TXN_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         TXN_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         TXN_FUNDING_ADJUSTMENT_AMOUNT,
        decode(fin1.event_type_classification,
               'WRITE OFF', fin1.txn_revenue,
               0)                               TXN_REVENUE_WRITEOFF,
        to_number(null)                         TXN_AR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         TXN_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         TXN_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         TXN_UNBILLED_RECEIVABLES,
        to_number(null)                         TXN_UNEARNED_REVENUE,
        to_number(null)                         TXN_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_AMOUNT_DUE,
        to_number(null)                         TXN_AR_AMOUNT_OVERDUE,
        fin1.Prj_Revenue                        PRJ_REVENUE,
        to_number(null)                         PRJ_FUNDING,
        to_number(null)                         PRJ_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         PRJ_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         PRJ_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         PRJ_FUNDING_ADJUSTMENT_AMOUNT,
        decode(fin1.event_type_classification,
               'WRITE OFF', fin1.prj_revenue,
               0)                               PRJ_REVENUE_WRITEOFF,
        to_number(null)                         PRJ_AR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         PRJ_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         PRJ_UNBILLED_RECEIVABLES,
        to_number(null)                         PRJ_UNEARNED_REVENUE,
        to_number(null)                         PRJ_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_AMOUNT_DUE,
        to_number(null)                         PRJ_AR_AMOUNT_OVERDUE,
        fin1.Pou_Revenue                        POU_REVENUE,
        to_number(null)                         POU_FUNDING,
        to_number(null)                         POU_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         POU_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         POU_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         POU_FUNDING_ADJUSTMENT_AMOUNT,
        decode(fin1.event_type_classification,
               'WRITE OFF', fin1.pou_revenue,
               0)                               POU_REVENUE_WRITEOFF,
        to_number(null)                         POU_AR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         POU_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         POU_AR_CREDIT_MEMO_AMOUNT,
        fin1.POU_UBR                            POU_UNBILLED_RECEIVABLES,
        fin1.POU_UER                            POU_UNEARNED_REVENUE,
        to_number(null)                         POU_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_AMOUNT_DUE,
        to_number(null)                         POU_AR_AMOUNT_OVERDUE,
        to_number(null)                         INITIAL_FUNDING_COUNT,
        to_number(null)                         ADDITIONAL_FUNDING_COUNT,
        to_number(null)                         CANCELLED_FUNDING_COUNT,
        to_number(null)                         FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                         AR_INVOICE_COUNT,
        to_number(null)                         AR_CASH_APPLIED_COUNT,
        to_number(null)                         AR_INVOICE_WRITEOFF_COUNT,
        to_number(null)                         AR_CREDIT_MEMO_COUNT,
        to_number(null)                         AR_UNAPPR_INVOICE_COUNT,
        to_number(null)                         AR_APPR_INVOICE_COUNT,
        to_number(null)                         AR_COUNT_DUE,
        to_number(null)                         AR_COUNT_OVERDUE
      from
        PJI_FM_AGGR_FIN1 fin1
      where
        fin1.WORKER_ID = p_worker_id and
        (fin1.PRJ_REVENUE <> 0 or fin1.POU_REVENUE <> 0)
      union all
      select  /*+ parallel(dii) */
              -- Draft invoice data in functional and project currency
              -- For activities we use actual dates
              -- For snapshots we use SYSDATE
        dii.PROJECT_ID,
        dii.PROJECT_ORG_ID,
        dii.PROJECT_ORGANIZATION_ID,
        -1                                      TASK_ID,
        dii.CUSTOMER_ID,
        decode(dii.pji_record_type,
               'A', greatest(to_number(to_char(dii.GL_DATE,'J')),
                             l_min_date),
               to_number(to_char(SYSDATE,'J'))) GL_TIME_ID,
        null                                    GL_PERIOD_NAME,
        decode(dii.pji_record_type,
               'A',greatest(to_number(to_char(dii.PA_DATE,'J')),
                            l_min_date),
               to_number(to_char(SYSDATE,'J'))) PA_TIME_ID,
        null                                    GL_PERIOD_NAME,
        null                                    TXN_CURRENCY_CODE,
        to_number(null)                         TXN_REVENUE,
        to_number(null)                         TXN_FUNDING,
        to_number(null)                         TXN_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         TXN_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         TXN_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         TXN_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         TXN_REVENUE_WRITEOFF,
        to_number(null)                         TXN_AR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         TXN_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         TXN_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         TXN_UNBILLED_RECEIVABLES,
        to_number(null)                         TXN_UNEARNED_REVENUE,
        to_number(null)                         TXN_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_AMOUNT_DUE,
        to_number(null)                         TXN_AR_AMOUNT_OVERDUE,
        to_number(null)                         PRJ_REVENUE,
        to_number(null)                         PRJ_FUNDING,
        to_number(null)                         PRJ_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         PRJ_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         PRJ_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         PRJ_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         PRJ_REVENUE_WRITEOFF,
        decode(dii.pji_date_range_flag || '_' ||
             dii.pji_record_type,
             'Y_A', dii.prj_invoice_amount,
              0)                                PRJ_AR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_CASH_APPLIED_AMOUNT,
        decode(dii.pji_date_range_flag || '_' ||
             dii.pji_record_type || '_' ||
             dii.write_off_flag,
             'Y_A_Y', dii.prj_invoice_amount,
             0)                                 PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
        decode(dii.pji_date_range_flag || '_' ||
             dii.pji_record_type || '_' ||
             dii.cancel_credit_memo_flag,
             'Y_A_Y', dii.prj_invoice_amount,
             0)                                 PRJ_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         PRJ_UNBILLED_RECEIVABLES,
        to_number(null)                         PRJ_UNEARNED_REVENUE,
        decode(dii.pji_record_type || '_' ||
             dii.approved_flag,
             'S_N',dii.prj_invoice_amount,
             0)                                 PRJ_AR_UNAPPR_INVOICE_AMOUNT,
        decode(dii.pji_record_type || '_' ||
             dii.approved_flag,
             'S_Y',dii.prj_invoice_amount,
             0)                                 PRJ_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_AMOUNT_DUE,
        to_number(null)                         PRJ_AR_AMOUNT_OVERDUE,
        to_number(null)                         POU_REVENUE,
        to_number(null)                         POU_FUNDING,
        to_number(null)                         POU_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         POU_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         POU_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         POU_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         POU_REVENUE_WRITEOFF,
        decode(dii.pji_date_range_flag || '_' ||
             dii.pji_record_type,
             'Y_A', dii.pou_invoice_amount,
              0)                                POU_AR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_CASH_APPLIED_AMOUNT,
        decode(dii.pji_date_range_flag || '_' ||
             dii.pji_record_type || '_' ||
             dii.write_off_flag,
             'Y_A_Y', dii.pou_invoice_amount,
             0)                                 POU_AR_INVOICE_WRITEOFF_AMOUNT,
        decode(dii.pji_date_range_flag || '_' ||
             dii.pji_record_type || '_' ||
             dii.cancel_credit_memo_flag,
             'Y_A_Y', dii.pou_invoice_amount,
             0)                                 POU_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         POU_UNBILLED_RECEIVABLES,
        to_number(null)                         POU_UNEARNED_REVENUE,
        decode(dii.pji_record_type || '_' ||
             dii.approved_flag,
             'S_N',dii.pou_invoice_amount,
             0)                                 POU_AR_UNAPPR_INVOICE_AMOUNT,
        decode(dii.pji_record_type || '_' ||
             dii.approved_flag,
             'S_Y',dii.pou_invoice_amount,
             0)                                 POU_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_AMOUNT_DUE,
        to_number(null)                         POU_AR_AMOUNT_OVERDUE,
        to_number(null)                         INITIAL_FUNDING_COUNT,
        to_number(null)                         ADDITIONAL_FUNDING_COUNT,
        to_number(null)                         CANCELLED_FUNDING_COUNT,
        to_number(null)                         FUNDING_ADJUSTMENT_COUNT,
        dii.AR_INVOICE_COUNT                    AR_INVOICE_COUNT,
        to_number(null)                         AR_CASH_APPLIED_COUNT,
        dii.AR_INVOICE_WRITEOFF_COUNT           AR_INVOICE_WRITEOFF_COUNT,
        dii.AR_CREDIT_MEMO_COUNT                AR_CREDIT_MEMO_COUNT,
        dii.AR_UNAPPR_INVOICE_COUNT             AR_UNAPPR_INVOICE_COUNT,
        dii.AR_APPR_INVOICE_COUNT               AR_APPR_INVOICE_COUNT,
        to_number(null)                         AR_COUNT_DUE,
        to_number(null)                         AR_COUNT_OVERDUE
      from
        PJI_FM_EXTR_DINVCITM dii
      where
        dii.WORKER_ID = p_worker_id
      union all
      select /*+ parallel(ar) */      -- AR data in functional currency only
        ar.PROJECT_ID,
        ar.PROJECT_ORG_ID                       PROJECT_ORG_ID,
        ar.PROJECT_ORGANIZATION_ID              PROJECT_ORGANIZATION_ID,
        -1                                      TASK_ID,
        ar.CUSTOMER_ID,
        to_number(to_char(SYSDATE,'J'))         GL_TIME_ID,
        null                                    GL_PERIOD_NAME,
        to_number(to_char(SYSDATE,'J'))         PA_TIME_ID,
        null                                    PA_PERIOD_NAME,
        null                                    TXN_CURRENCY_CODE,
        to_number(null)                         TXN_REVENUE,
        to_number(null)                         TXN_FUNDING,
        to_number(null)                         TXN_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         TXN_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         TXN_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         TXN_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         TXN_REVENUE_WRITEOFF,
        to_number(null)                         TXN_AR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         TXN_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         TXN_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         TXN_UNBILLED_RECEIVABLES,
        to_number(null)                         TXN_UNEARNED_REVENUE,
        to_number(null)                         TXN_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         TXN_AR_AMOUNT_DUE,
        to_number(null)                         TXN_AR_AMOUNT_OVERDUE,
        to_number(null)                         PRJ_REVENUE,
        to_number(null)                         PRJ_FUNDING,
        to_number(null)                         PRJ_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         PRJ_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         PRJ_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         PRJ_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         PRJ_REVENUE_WRITEOFF,
        to_number(null)                         PRJ_AR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         PRJ_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         PRJ_UNBILLED_RECEIVABLES,
        to_number(null)                         PRJ_UNEARNED_REVENUE,
        to_number(null)                         PRJ_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_APPR_INVOICE_AMOUNT,
        to_number(null)                         PRJ_AR_AMOUNT_DUE,
        to_number(null)                         PRJ_AR_AMOUNT_OVERDUE,
        to_number(null)                         POU_REVENUE,
        to_number(null)                         POU_FUNDING,
        to_number(null)                         POU_INITIAL_FUNDING_AMOUNT,
        to_number(null)                         POU_ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                         POU_CANCELLED_FUNDING_AMOUNT,
        to_number(null)                         POU_FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                         POU_REVENUE_WRITEOFF,
        to_number(null)                         POU_AR_INVOICE_AMOUNT,
        ar.cash_applied_amount                  POU_AR_CASH_APPLIED_AMOUNT,
        to_number(null)                         POU_AR_INVOICE_WRITEOFF_AMOUNT,
        to_number(null)                         POU_AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                         POU_UNBILLED_RECEIVABLES,
        to_number(null)                         POU_UNEARNED_REVENUE,
        to_number(null)                         POU_AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                         POU_AR_APPR_INVOICE_AMOUNT,
        ar.amount_due_remaining                 POU_AR_AMOUNT_DUE,
        ar.amount_overdue_remaining             POU_AR_AMOUNT_OVERDUE,
        to_number(null)                         INITIAL_FUNDING_COUNT,
        to_number(null)                         ADDITIONAL_FUNDING_COUNT,
        to_number(null)                         CANCELLED_FUNDING_COUNT,
        to_number(null)                         FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                         AR_INVOICE_COUNT,
        to_number(null)                         AR_CASH_APPLIED_COUNT,
    -- OPEN ISSUE: need to add support for AR_CASH_APPLIED_COUNT
        to_number(null)                         AR_INVOICE_WRITEOFF_COUNT,
        to_number(null)                         AR_CREDIT_MEMO_COUNT,
        to_number(null)                         AR_UNAPPR_INVOICE_COUNT,
        to_number(null)                         AR_APPR_INVOICE_COUNT,
        decode(sign(amount_overdue_remaining),
               1, 0, decode(sign(ar.amount_due_remaining),
                            1, 1, 0), 0)        AR_COUNT_DUE,
        decode(sign(amount_overdue_remaining),
               1, 1, 0)                         AR_COUNT_OVERDUE
      from
        PJI_FM_EXTR_ARINV ar
      where
        ar.WORKER_ID = p_worker_id
      )
    group by
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TASK_ID,
      CUSTOMER_ID,
      GL_TIME_ID,
      GL_PERIOD_NAME,
      PA_TIME_ID,
      PA_PERIOD_NAME,
      TXN_CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_ACT.BASE_SUMMARY(p_worker_id);');

    -- truncate intermediate tables no longer required
    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_EXTR_FUNDG' , 'NORMAL',null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_EXTR_DREVN' , 'NORMAL',null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_EXTR_DINVC' , 'NORMAL',null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_EXTR_DINVCITM' , 'NORMAL',null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_EXTR_ARINV' , 'NORMAL',null);

    commit;

  end BASE_SUMMARY;


  -- -----------------------------------------------------
  -- procedure CLEANUP
  -- -----------------------------------------------------
  procedure CLEANUP (p_worker_id in number) is

    l_schema varchar2(30);

  begin

    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_AGGR_ACT1', 'NORMAL',null);

  end CLEANUP;

end PJI_FM_SUM_ACT;

/
