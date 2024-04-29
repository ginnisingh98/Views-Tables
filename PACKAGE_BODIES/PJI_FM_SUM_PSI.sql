--------------------------------------------------------
--  DDL for Package Body PJI_FM_SUM_PSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_SUM_PSI" as
  /* $Header: PJISF09B.pls 120.15.12010000.3 2009/05/22 06:36:34 rballamu ship $ */

  -- -----------------------------------------------------
  -- procedure RESOURCE_LOOKUP_TABLE
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure RESOURCE_LOOKUP_TABLE (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(15);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.RESOURCE_LOOKUP_TABLE(p_worker_id);')) then
      return;
    end if;

    insert into PJI_FM_AGGR_RES_TYPES
    (
      EXP_TYPE_CLASS,
      RESOURCE_CLASS_ID
    )
    select 'OT' EXP_TYPE_CLASS,                          -- actuals lookups
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'PEOPLE'
    union all
    select 'ER' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'FINANCIAL_ELEMENTS'
    union all
    select 'ST' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'PEOPLE'
    union all
    select 'INV' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'MATERIAL_ITEMS'
    union all
    select 'VI$FINANCIAL' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'FINANCIAL_ELEMENTS'
    union all
    select 'VI$MATERIAL' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'MATERIAL_ITEMS'
    union all
    select 'VI$PEOPLE' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'PEOPLE'
    union all
    select 'PJ' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'FINANCIAL_ELEMENTS'
    union all
    select 'BTC' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'FINANCIAL_ELEMENTS'
    union all
    select 'WIP$EQUIPMENT' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'EQUIPMENT'
    union all
    select 'WIP$PEOPLE' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'PEOPLE'
    union all
    select 'WIP$OTHER' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'FINANCIAL_ELEMENTS'
    union all
    select 'USG$Y' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'EQUIPMENT'
    union all
    select 'USG$N' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'FINANCIAL_ELEMENTS'
    union all
    select 'PJI$NULL' EXP_TYPE_CLASS,
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE = 'FINANCIAL_ELEMENTS'
    union all
    select cls.RESOURCE_CLASS_CODE EXP_TYPE_CLASS,       -- commitments lookups
           cls.RESOURCE_CLASS_ID
    from   PA_RESOURCE_CLASSES_B  cls
    where  cls.RESOURCE_CLASS_CODE in ('FINANCIAL_ELEMENTS',
                                       'MATERIAL_ITEMS',
                                       'EQUIPMENT',
                                       'PEOPLE');

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.RESOURCE_LOOKUP_TABLE(p_worker_id);');

    commit;

  end RESOURCE_LOOKUP_TABLE;


  -- -----------------------------------------------------
  -- procedure PURGE_FP_BALANCES
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure PURGE_FP_BALANCES (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(15);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.PURGE_FP_BALANCES(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    if (l_extraction_type = 'PARTIAL') then

      delete
      from   PJI_FM_AGGR_FIN7 fin7
      where  fin7.RECORD_TYPE = 'A' and
             fin7.PROJECT_ID in (select map.PROJECT_ID
                                 from   PJI_FM_PROJ_BATCH_MAP map
                                 where  map.WORKER_ID = p_worker_id);

      delete
      from   PJI_FP_TXN_ACCUM bal
      where  bal.PROJECT_ID in (select map.PROJECT_ID
                                from   PJI_FM_PROJ_BATCH_MAP map
                                where  map.WORKER_ID = p_worker_id);

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.PURGE_FP_BALANCES(p_worker_id);');

    commit;

  end PURGE_FP_BALANCES;


  -- -----------------------------------------------------
  -- procedure PURGE_CMT_BALANCES
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure PURGE_CMT_BALANCES (p_worker_id in number) is

    l_process             varchar2(30);
    l_extraction_type     varchar2(15);
    l_extract_commitments varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.PURGE_CMT_BALANCES(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    l_extract_commitments := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                             (PJI_FM_SUM_MAIN.g_process,
                              'EXTRACT_COMMITMENTS');

    if (l_extraction_type <> 'FULL' and l_extract_commitments = 'Y') then

      delete
      from   PJI_FM_AGGR_FIN7 fin7
      where  fin7.RECORD_TYPE = 'M' and
             fin7.PROJECT_ID in (select map.PROJECT_ID
                                 from   PJI_FM_PROJ_BATCH_MAP map
                                 where  map.WORKER_ID = p_worker_id);

      delete
      from   PJI_FP_TXN_ACCUM1 bal
      where  bal.PROJECT_ID in (select map.PROJECT_ID
                                from   PJI_FM_PROJ_BATCH_MAP map
                                where  map.WORKER_ID = p_worker_id);

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.PURGE_CMT_BALANCES(p_worker_id);');

    commit;

  end PURGE_CMT_BALANCES;


  -- -----------------------------------------------------
  -- procedure PURGE_AC_BALANCES
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure PURGE_AC_BALANCES (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(15);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.PURGE_AC_BALANCES(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    if (l_extraction_type = 'PARTIAL') then

      delete
      from   PJI_FM_AGGR_ACT4 act4
      where  act4.PROJECT_ID in (select map.PROJECT_ID
                                 from   PJI_FM_PROJ_BATCH_MAP map
                                 where  map.WORKER_ID = p_worker_id);

    elsif (l_extraction_type = 'INCREMENTAL') then

      -- clean up snapshots and activities

      update PJI_FM_AGGR_ACT4 act4
      set    act4.TXN_AR_INVOICE_AMOUNT          = to_number(null),
             act4.TXN_AR_CASH_APPLIED_AMOUNT     = to_number(null),
             act4.TXN_AR_INVOICE_WRITEOFF_AMOUNT = to_number(null),
             act4.TXN_AR_CREDIT_MEMO_AMOUNT      = to_number(null),
             act4.TXN_AR_UNAPPR_INVOICE_AMOUNT   = to_number(null),
             act4.TXN_AR_APPR_INVOICE_AMOUNT     = to_number(null),
             act4.TXN_AR_AMOUNT_DUE              = to_number(null),
             act4.TXN_AR_AMOUNT_OVERDUE          = to_number(null),
             act4.PRJ_AR_INVOICE_AMOUNT          = to_number(null),
             act4.PRJ_AR_CASH_APPLIED_AMOUNT     = to_number(null),
             act4.PRJ_AR_INVOICE_WRITEOFF_AMOUNT = to_number(null),
             act4.PRJ_AR_CREDIT_MEMO_AMOUNT      = to_number(null),
             act4.PRJ_AR_UNAPPR_INVOICE_AMOUNT   = to_number(null),
             act4.PRJ_AR_APPR_INVOICE_AMOUNT     = to_number(null),
             act4.PRJ_AR_AMOUNT_DUE              = to_number(null),
             act4.PRJ_AR_AMOUNT_OVERDUE          = to_number(null),
             act4.POU_AR_INVOICE_AMOUNT          = to_number(null),
             act4.POU_AR_CASH_APPLIED_AMOUNT     = to_number(null),
             act4.POU_AR_INVOICE_WRITEOFF_AMOUNT = to_number(null),
             act4.POU_AR_CREDIT_MEMO_AMOUNT      = to_number(null),
             act4.POU_AR_UNAPPR_INVOICE_AMOUNT   = to_number(null),
             act4.POU_AR_APPR_INVOICE_AMOUNT     = to_number(null),
             act4.POU_AR_AMOUNT_DUE              = to_number(null),
             act4.POU_AR_AMOUNT_OVERDUE          = to_number(null),
             act4.AR_INVOICE_COUNT               = to_number(null),
             act4.AR_INVOICE_WRITEOFF_COUNT      = to_number(null),
             act4.AR_CREDIT_MEMO_COUNT           = to_number(null),
             act4.AR_UNAPPR_INVOICE_COUNT        = to_number(null),
             act4.AR_APPR_INVOICE_COUNT          = to_number(null),
             act4.AR_COUNT_DUE                   = to_number(null),
             act4.AR_COUNT_OVERDUE               = to_number(null),
             act4.G1_AR_INVOICE_AMOUNT           = to_number(null),
             act4.G1_AR_CASH_APPLIED_AMOUNT      = to_number(null),
             act4.G1_AR_INVOICE_WRITEOFF_AMOUNT  = to_number(null),
             act4.G1_AR_CREDIT_MEMO_AMOUNT       = to_number(null),
             act4.G1_AR_UNAPPR_INVOICE_AMOUNT    = to_number(null),
             act4.G1_AR_APPR_INVOICE_AMOUNT      = to_number(null),
             act4.G1_AR_AMOUNT_DUE               = to_number(null),
             act4.G1_AR_AMOUNT_OVERDUE           = to_number(null),
             act4.G2_AR_INVOICE_AMOUNT           = to_number(null),
             act4.G2_AR_CASH_APPLIED_AMOUNT      = to_number(null),
             act4.G2_AR_INVOICE_WRITEOFF_AMOUNT  = to_number(null),
             act4.G2_AR_CREDIT_MEMO_AMOUNT       = to_number(null),
             act4.G2_AR_UNAPPR_INVOICE_AMOUNT    = to_number(null),
             act4.G2_AR_APPR_INVOICE_AMOUNT      = to_number(null),
             act4.G2_AR_AMOUNT_DUE               = to_number(null),
             act4.G2_AR_AMOUNT_OVERDUE           = to_number(null)
      where  act4.PROJECT_ID in (select map.PROJECT_ID
                                 from   PJI_FM_PROJ_BATCH_MAP map
                                 where  map.WORKER_ID = p_worker_id) and
             not (nvl(act4.TXN_AR_INVOICE_AMOUNT          , 0) = 0 and
                  nvl(act4.TXN_AR_CASH_APPLIED_AMOUNT     , 0) = 0 and
                  nvl(act4.TXN_AR_INVOICE_WRITEOFF_AMOUNT , 0) = 0 and
                  nvl(act4.TXN_AR_CREDIT_MEMO_AMOUNT      , 0) = 0 and
                  nvl(act4.TXN_AR_UNAPPR_INVOICE_AMOUNT   , 0) = 0 and
                  nvl(act4.TXN_AR_APPR_INVOICE_AMOUNT     , 0) = 0 and
                  nvl(act4.TXN_AR_AMOUNT_DUE              , 0) = 0 and
                  nvl(act4.TXN_AR_AMOUNT_OVERDUE          , 0) = 0 and
                  nvl(act4.PRJ_AR_INVOICE_AMOUNT          , 0) = 0 and
                  nvl(act4.PRJ_AR_CASH_APPLIED_AMOUNT     , 0) = 0 and
                  nvl(act4.PRJ_AR_INVOICE_WRITEOFF_AMOUNT , 0) = 0 and
                  nvl(act4.PRJ_AR_CREDIT_MEMO_AMOUNT      , 0) = 0 and
                  nvl(act4.PRJ_AR_UNAPPR_INVOICE_AMOUNT   , 0) = 0 and
                  nvl(act4.PRJ_AR_APPR_INVOICE_AMOUNT     , 0) = 0 and
                  nvl(act4.PRJ_AR_AMOUNT_DUE              , 0) = 0 and
                  nvl(act4.PRJ_AR_AMOUNT_OVERDUE          , 0) = 0 and
                  nvl(act4.POU_AR_INVOICE_AMOUNT          , 0) = 0 and
                  nvl(act4.POU_AR_CASH_APPLIED_AMOUNT     , 0) = 0 and
                  nvl(act4.POU_AR_INVOICE_WRITEOFF_AMOUNT , 0) = 0 and
                  nvl(act4.POU_AR_CREDIT_MEMO_AMOUNT      , 0) = 0 and
                  nvl(act4.POU_AR_UNAPPR_INVOICE_AMOUNT   , 0) = 0 and
                  nvl(act4.POU_AR_APPR_INVOICE_AMOUNT     , 0) = 0 and
                  nvl(act4.POU_AR_AMOUNT_DUE              , 0) = 0 and
                  nvl(act4.POU_AR_AMOUNT_OVERDUE          , 0) = 0 and
                  nvl(act4.AR_INVOICE_COUNT               , 0) = 0 and
                  nvl(act4.AR_INVOICE_WRITEOFF_COUNT      , 0) = 0 and
                  nvl(act4.AR_CREDIT_MEMO_COUNT           , 0) = 0 and
                  nvl(act4.AR_UNAPPR_INVOICE_COUNT        , 0) = 0 and
                  nvl(act4.AR_APPR_INVOICE_COUNT          , 0) = 0 and
                  nvl(act4.AR_COUNT_DUE                   , 0) = 0 and
                  nvl(act4.AR_COUNT_OVERDUE               , 0) = 0 and
                  nvl(act4.G1_AR_INVOICE_AMOUNT           , 0) = 0 and
                  nvl(act4.G1_AR_CASH_APPLIED_AMOUNT      , 0) = 0 and
                  nvl(act4.G1_AR_INVOICE_WRITEOFF_AMOUNT  , 0) = 0 and
                  nvl(act4.G1_AR_CREDIT_MEMO_AMOUNT       , 0) = 0 and
                  nvl(act4.G1_AR_UNAPPR_INVOICE_AMOUNT    , 0) = 0 and
                  nvl(act4.G1_AR_APPR_INVOICE_AMOUNT      , 0) = 0 and
                  nvl(act4.G1_AR_AMOUNT_DUE               , 0) = 0 and
                  nvl(act4.G1_AR_AMOUNT_OVERDUE           , 0) = 0 and
                  nvl(act4.G2_AR_INVOICE_AMOUNT           , 0) = 0 and
                  nvl(act4.G2_AR_CASH_APPLIED_AMOUNT      , 0) = 0 and
                  nvl(act4.G2_AR_INVOICE_WRITEOFF_AMOUNT  , 0) = 0 and
                  nvl(act4.G2_AR_CREDIT_MEMO_AMOUNT       , 0) = 0 and
                  nvl(act4.G2_AR_UNAPPR_INVOICE_AMOUNT    , 0) = 0 and
                  nvl(act4.G2_AR_APPR_INVOICE_AMOUNT      , 0) = 0 and
                  nvl(act4.G2_AR_AMOUNT_DUE               , 0) = 0 and
                  nvl(act4.G2_AR_AMOUNT_OVERDUE           , 0) = 0);

      delete
      from   PJI_FM_AGGR_ACT4 act4
      where  act4.PROJECT_ID in (select map.PROJECT_ID
                                 from   PJI_FM_PROJ_BATCH_MAP map
                                 where  map.WORKER_ID = p_worker_id) and
             nvl(act4.TXN_REVENUE                    , 0) = 0 and
             nvl(act4.TXN_FUNDING                    , 0) = 0 and
             nvl(act4.TXN_INITIAL_FUNDING_AMOUNT     , 0) = 0 and
             nvl(act4.TXN_ADDITIONAL_FUNDING_AMOUNT  , 0) = 0 and
             nvl(act4.TXN_CANCELLED_FUNDING_AMOUNT   , 0) = 0 and
             nvl(act4.TXN_FUNDING_ADJUSTMENT_AMOUNT  , 0) = 0 and
             nvl(act4.TXN_REVENUE_WRITEOFF           , 0) = 0 and
             nvl(act4.TXN_AR_INVOICE_AMOUNT          , 0) = 0 and
             nvl(act4.TXN_AR_CASH_APPLIED_AMOUNT     , 0) = 0 and
             nvl(act4.TXN_AR_INVOICE_WRITEOFF_AMOUNT , 0) = 0 and
             nvl(act4.TXN_AR_CREDIT_MEMO_AMOUNT      , 0) = 0 and
             nvl(act4.TXN_UNBILLED_RECEIVABLES       , 0) = 0 and
             nvl(act4.TXN_UNEARNED_REVENUE           , 0) = 0 and
             nvl(act4.TXN_AR_UNAPPR_INVOICE_AMOUNT   , 0) = 0 and
             nvl(act4.TXN_AR_APPR_INVOICE_AMOUNT     , 0) = 0 and
             nvl(act4.TXN_AR_AMOUNT_DUE              , 0) = 0 and
             nvl(act4.TXN_AR_AMOUNT_OVERDUE          , 0) = 0 and
             nvl(act4.PRJ_REVENUE                    , 0) = 0 and
             nvl(act4.PRJ_FUNDING                    , 0) = 0 and
             nvl(act4.PRJ_INITIAL_FUNDING_AMOUNT     , 0) = 0 and
             nvl(act4.PRJ_ADDITIONAL_FUNDING_AMOUNT  , 0) = 0 and
             nvl(act4.PRJ_CANCELLED_FUNDING_AMOUNT   , 0) = 0 and
             nvl(act4.PRJ_FUNDING_ADJUSTMENT_AMOUNT  , 0) = 0 and
             nvl(act4.PRJ_REVENUE_WRITEOFF           , 0) = 0 and
             nvl(act4.PRJ_AR_INVOICE_AMOUNT          , 0) = 0 and
             nvl(act4.PRJ_AR_CASH_APPLIED_AMOUNT     , 0) = 0 and
             nvl(act4.PRJ_AR_INVOICE_WRITEOFF_AMOUNT , 0) = 0 and
             nvl(act4.PRJ_AR_CREDIT_MEMO_AMOUNT      , 0) = 0 and
             nvl(act4.PRJ_UNBILLED_RECEIVABLES       , 0) = 0 and
             nvl(act4.PRJ_UNEARNED_REVENUE           , 0) = 0 and
             nvl(act4.PRJ_AR_UNAPPR_INVOICE_AMOUNT   , 0) = 0 and
             nvl(act4.PRJ_AR_APPR_INVOICE_AMOUNT     , 0) = 0 and
             nvl(act4.PRJ_AR_AMOUNT_DUE              , 0) = 0 and
             nvl(act4.PRJ_AR_AMOUNT_OVERDUE          , 0) = 0 and
             nvl(act4.POU_REVENUE                    , 0) = 0 and
             nvl(act4.POU_FUNDING                    , 0) = 0 and
             nvl(act4.POU_INITIAL_FUNDING_AMOUNT     , 0) = 0 and
             nvl(act4.POU_ADDITIONAL_FUNDING_AMOUNT  , 0) = 0 and
             nvl(act4.POU_CANCELLED_FUNDING_AMOUNT   , 0) = 0 and
             nvl(act4.POU_FUNDING_ADJUSTMENT_AMOUNT  , 0) = 0 and
             nvl(act4.POU_REVENUE_WRITEOFF           , 0) = 0 and
             nvl(act4.POU_AR_INVOICE_AMOUNT          , 0) = 0 and
             nvl(act4.POU_AR_CASH_APPLIED_AMOUNT     , 0) = 0 and
             nvl(act4.POU_AR_INVOICE_WRITEOFF_AMOUNT , 0) = 0 and
             nvl(act4.POU_AR_CREDIT_MEMO_AMOUNT      , 0) = 0 and
             nvl(act4.POU_UNBILLED_RECEIVABLES       , 0) = 0 and
             nvl(act4.POU_UNEARNED_REVENUE           , 0) = 0 and
             nvl(act4.POU_AR_UNAPPR_INVOICE_AMOUNT   , 0) = 0 and
             nvl(act4.POU_AR_APPR_INVOICE_AMOUNT     , 0) = 0 and
             nvl(act4.POU_AR_AMOUNT_DUE              , 0) = 0 and
             nvl(act4.POU_AR_AMOUNT_OVERDUE          , 0) = 0 and
             nvl(act4.INITIAL_FUNDING_COUNT          , 0) = 0 and
             nvl(act4.ADDITIONAL_FUNDING_COUNT       , 0) = 0 and
             nvl(act4.CANCELLED_FUNDING_COUNT        , 0) = 0 and
             nvl(act4.FUNDING_ADJUSTMENT_COUNT       , 0) = 0 and
             nvl(act4.AR_INVOICE_COUNT               , 0) = 0 and
             nvl(act4.AR_CASH_APPLIED_COUNT          , 0) = 0 and
             nvl(act4.AR_INVOICE_WRITEOFF_COUNT      , 0) = 0 and
             nvl(act4.AR_CREDIT_MEMO_COUNT           , 0) = 0 and
             nvl(act4.AR_UNAPPR_INVOICE_COUNT        , 0) = 0 and
             nvl(act4.AR_APPR_INVOICE_COUNT          , 0) = 0 and
             nvl(act4.AR_COUNT_DUE                   , 0) = 0 and
             nvl(act4.AR_COUNT_OVERDUE               , 0) = 0 and
             nvl(act4.G1_REVENUE                     , 0) = 0 and
             nvl(act4.G1_FUNDING                     , 0) = 0 and
             nvl(act4.G1_INITIAL_FUNDING_AMOUNT      , 0) = 0 and
             nvl(act4.G1_ADDITIONAL_FUNDING_AMOUNT   , 0) = 0 and
             nvl(act4.G1_CANCELLED_FUNDING_AMOUNT    , 0) = 0 and
             nvl(act4.G1_FUNDING_ADJUSTMENT_AMOUNT   , 0) = 0 and
             nvl(act4.G1_REVENUE_WRITEOFF            , 0) = 0 and
             nvl(act4.G1_AR_INVOICE_AMOUNT           , 0) = 0 and
             nvl(act4.G1_AR_CASH_APPLIED_AMOUNT      , 0) = 0 and
             nvl(act4.G1_AR_INVOICE_WRITEOFF_AMOUNT  , 0) = 0 and
             nvl(act4.G1_AR_CREDIT_MEMO_AMOUNT       , 0) = 0 and
             nvl(act4.G1_UNBILLED_RECEIVABLES        , 0) = 0 and
             nvl(act4.G1_UNEARNED_REVENUE            , 0) = 0 and
             nvl(act4.G1_AR_UNAPPR_INVOICE_AMOUNT    , 0) = 0 and
             nvl(act4.G1_AR_APPR_INVOICE_AMOUNT      , 0) = 0 and
             nvl(act4.G1_AR_AMOUNT_DUE               , 0) = 0 and
             nvl(act4.G1_AR_AMOUNT_OVERDUE           , 0) = 0 and
             nvl(act4.G2_REVENUE                     , 0) = 0 and
             nvl(act4.G2_FUNDING                     , 0) = 0 and
             nvl(act4.G2_INITIAL_FUNDING_AMOUNT      , 0) = 0 and
             nvl(act4.G2_ADDITIONAL_FUNDING_AMOUNT   , 0) = 0 and
             nvl(act4.G2_CANCELLED_FUNDING_AMOUNT    , 0) = 0 and
             nvl(act4.G2_FUNDING_ADJUSTMENT_AMOUNT   , 0) = 0 and
             nvl(act4.G2_REVENUE_WRITEOFF            , 0) = 0 and
             nvl(act4.G2_AR_INVOICE_AMOUNT           , 0) = 0 and
             nvl(act4.G2_AR_CASH_APPLIED_AMOUNT      , 0) = 0 and
             nvl(act4.G2_AR_INVOICE_WRITEOFF_AMOUNT  , 0) = 0 and
             nvl(act4.G2_AR_CREDIT_MEMO_AMOUNT       , 0) = 0 and
             nvl(act4.G2_UNBILLED_RECEIVABLES        , 0) = 0 and
             nvl(act4.G2_UNEARNED_REVENUE            , 0) = 0 and
             nvl(act4.G2_AR_UNAPPR_INVOICE_AMOUNT    , 0) = 0 and
             nvl(act4.G2_AR_APPR_INVOICE_AMOUNT      , 0) = 0 and
             nvl(act4.G2_AR_AMOUNT_DUE               , 0) = 0 and
             nvl(act4.G2_AR_AMOUNT_OVERDUE           , 0) = 0;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.PURGE_AC_BALANCES(p_worker_id);');

    commit;

  end PURGE_AC_BALANCES;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_FPR_PERIODS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure AGGREGATE_FPR_PERIODS (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.AGGREGATE_FPR_PERIODS(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(tmp6_i) */ into PJI_FM_AGGR_FIN6 tmp6_i
    (
      WORKER_ID,
      RECORD_TYPE,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      RESOURCE_CLASS_ID,
      JOB_ID,
      VENDOR_ID,
      WORK_TYPE_ID,
      EXPENDITURE_CATEGORY_ID,
      EXPENDITURE_TYPE_ID,
      EVENT_TYPE_ID,
      EXP_EVT_TYPE_ID,
      EXPENDITURE_TYPE,
      EVENT_TYPE,
      EVENT_TYPE_CLASSIFICATION,
      EXPENDITURE_CATEGORY,
      REVENUE_CATEGORY,
      NON_LABOR_RESOURCE_ID,
      BOM_LABOR_RESOURCE_ID,
      BOM_EQUIPMENT_RESOURCE_ID,
      ITEM_CATEGORY_ID,
      INVENTORY_ITEM_ID,
      PROJECT_ROLE_ID,
      NAMED_ROLE,
      PERSON_TYPE,
      SYSTEM_LINKAGE_FUNCTION,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_TYPE_CLASS,
      TASK_ID,
      ASSIGNMENT_ID,
      RECVR_PERIOD_TYPE,
      RECVR_PERIOD_ID,
      TXN_CURRENCY_CODE,
      TXN_REVENUE,
      TXN_RAW_COST,
      TXN_BRDN_COST,
      TXN_BILL_RAW_COST,
      TXN_BILL_BRDN_COST,
      TXN_SUP_INV_COMMITTED_COST,
      TXN_PO_COMMITTED_COST,
      TXN_PR_COMMITTED_COST,
      TXN_OTH_COMMITTED_COST,
      PRJ_REVENUE,
      PRJ_RAW_COST,
      PRJ_BRDN_COST,
      PRJ_BILL_RAW_COST,
      PRJ_BILL_BRDN_COST,
      PRJ_REVENUE_WRITEOFF,
      PRJ_SUP_INV_COMMITTED_COST,
      PRJ_PO_COMMITTED_COST,
      PRJ_PR_COMMITTED_COST,
      PRJ_OTH_COMMITTED_COST,
      POU_REVENUE,
      POU_RAW_COST,
      POU_BRDN_COST,
      POU_BILL_RAW_COST,
      POU_BILL_BRDN_COST,
      POU_REVENUE_WRITEOFF,
      POU_SUP_INV_COMMITTED_COST,
      POU_PO_COMMITTED_COST,
      POU_PR_COMMITTED_COST,
      POU_OTH_COMMITTED_COST,
      EOU_REVENUE,
      EOU_RAW_COST,
      EOU_BRDN_COST,
      EOU_BILL_RAW_COST,
      EOU_BILL_BRDN_COST,
      EOU_SUP_INV_COMMITTED_COST,
      EOU_PO_COMMITTED_COST,
      EOU_PR_COMMITTED_COST,
      EOU_OTH_COMMITTED_COST,
      QUANTITY,
      BILL_QUANTITY,
      G1_REVENUE,
      G1_RAW_COST,
      G1_BRDN_COST,
      G1_BILL_RAW_COST,
      G1_BILL_BRDN_COST,
      G1_REVENUE_WRITEOFF,
      G1_SUP_INV_COMMITTED_COST,
      G1_PO_COMMITTED_COST,
      G1_PR_COMMITTED_COST,
      G1_OTH_COMMITTED_COST,
      G2_REVENUE,
      G2_RAW_COST,
      G2_BRDN_COST,
      G2_BILL_RAW_COST,
      G2_BILL_BRDN_COST,
      G2_REVENUE_WRITEOFF,
      G2_SUP_INV_COMMITTED_COST,
      G2_PO_COMMITTED_COST,
      G2_PR_COMMITTED_COST,
      G2_OTH_COMMITTED_COST
    )
    select /*+ full(tmp2)     parallel(tmp2)     use_hash(tmp2)
               full(gl_cal)   parallel(gl_cal)   use_hash(gl_cal)
               full(pa_cal)   parallel(pa_cal)   use_hash(pa_cal)
               full(res)      use_hash(res)
               full(res_typs) use_hash(res_typs)
               full(mcsts)    use_hash(mcsts)
               full(cls)      use_hash(cls)
               parallel(cat) */
      p_worker_id                                  WORKER_ID,
      tmp2.RECORD_TYPE,
      tmp2.PERSON_ID                               PERSON_ID,
      -- temporary fix for bug 3660160
      -1                                           EXPENDITURE_ORG_ID,
      -- tmp2.EXPENDITURE_ORG_ID                   EXPENDITURE_ORG_ID,
      tmp2.EXPENDITURE_ORGANIZATION_ID             EXPENDITURE_ORGANIZATION_ID,
      nvl(res_typs.RESOURCE_CLASS_ID, -1)          RESOURCE_CLASS_ID,
      tmp2.JOB_ID,
      tmp2.VENDOR_ID,
      -- temporary fix for bug 3660160
      -1                                           WORK_TYPE_ID,
      -- tmp2.WORK_TYPE_ID,
      nvl(exp_cat.EXPENDITURE_CATEGORY_ID, -1)     EXPENDITURE_CATEGORY_ID,
      decode(tmp2.EVENT_TYPE, 'PJI$NULL',
             tmp2.EXP_EVT_TYPE_ID, -1)             EXPENDITURE_TYPE_ID,
      decode(tmp2.EXPENDITURE_TYPE, 'PJI$NULL',
             tmp2.EXP_EVT_TYPE_ID, -1)             EVENT_TYPE_ID,
      -- temporary fix for bug 3813982
      -1                                           EXP_EVT_TYPE_ID,
      -- tmp2.EXP_EVT_TYPE_ID,
      -- temporary fix for bug 3813982
      -- 'PJI$NULL'                                EXPENDITURE_TYPE,
      tmp2.EXPENDITURE_TYPE,
      tmp2.EVENT_TYPE,
      tmp2.EVENT_TYPE_CLASSIFICATION,
      -- temporary fix for bug 3813982
      -- 'PJI$NULL'                                EXPENDITURE_CATEGORY,
      tmp2.EXPENDITURE_CATEGORY,
      tmp2.REVENUE_CATEGORY,
      tmp2.NON_LABOR_RESOURCE_ID,
      tmp2.BOM_LABOR_RESOURCE_ID,
      tmp2.BOM_EQUIPMENT_RESOURCE_ID,
      nvl(inv.ITEM_CATEGORY_ID, -1)                ITEM_CATEGORY_ID,
      tmp2.INVENTORY_ITEM_ID,
      tmp2.PROJECT_ROLE_ID,
      tmp2.NAMED_ROLE,
      tmp2.PERSON_TYPE,
      -- temporary fix for bug 3813982
      'PJI$NULL'                                   SYSTEM_LINKAGE_FUNCTION,
      -- tmp2.SYSTEM_LINKAGE_FUNCTION,
      tmp2.PROJECT_ID,
      tmp2.PROJECT_ORG_ID,
      tmp2.PROJECT_ORGANIZATION_ID,
      tmp2.PROJECT_TYPE_CLASS,
      tmp2.TASK_ID,
      tmp2.ASSIGNMENT_ID,
      decode(invert.INVERT_ID,
             'ENT', 'ENT',
             'GL',  'GL',
             'PA',  'PA')                          RECVR_PERIOD_TYPE,
      decode(invert.INVERT_ID,
             'ENT', tmp2.RECVR_ENT_PERIOD_ID,
             'GL',  gl_cal.CAL_PERIOD_ID,
             'PA',  pa_cal.CAL_PERIOD_ID)          RECVR_PERIOD_ID,
      tmp2.TXN_CURRENCY_CODE,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.TXN_REVENUE,
                      to_number(null)))            TXN_REVENUE,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.TXN_RAW_COST,
                      to_number(null)))            TXN_RAW_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.TXN_BRDN_COST,
                      to_number(null)))            TXN_BRDN_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.TXN_BILL_RAW_COST,
                      to_number(null)))            TXN_BILL_RAW_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.TXN_BILL_BRDN_COST,
                      to_number(null)))            TXN_BILL_BRDN_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_I', tmp2.TXN_BRDN_COST,
                        to_number(null)))          TXN_SUP_INV_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_P', tmp2.TXN_BRDN_COST,
                        to_number(null)))          TXN_PO_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_R', tmp2.TXN_BRDN_COST,
                        to_number(null)))          TXN_PR_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_O', tmp2.TXN_BRDN_COST,
                        to_number(null)))          TXN_OTH_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.PRJ_REVENUE,
                      to_number(null)))            PRJ_REVENUE,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.PRJ_RAW_COST,
                      to_number(null)))            PRJ_RAW_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.PRJ_BRDN_COST,
                      to_number(null)))            PRJ_BRDN_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.PRJ_BILL_RAW_COST,
                      to_number(null)))            PRJ_BILL_RAW_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.PRJ_BILL_BRDN_COST,
                      to_number(null)))            PRJ_BILL_BRDN_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.PRJ_REVENUE_WRITEOFF,
                      to_number(null)))            PRJ_REVENUE_WRITEOFF,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_I', tmp2.PRJ_BRDN_COST,
                        to_number(null)))          PRJ_SUP_INV_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_P', tmp2.PRJ_BRDN_COST,
                        to_number(null)))          PRJ_PO_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_R', tmp2.PRJ_BRDN_COST,
                        to_number(null)))          PRJ_PR_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_O', tmp2.PRJ_BRDN_COST,
                        to_number(null)))          PRJ_OTH_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.POU_REVENUE,
                      to_number(null)))            POU_REVENUE,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.POU_RAW_COST,
                      to_number(null)))            POU_RAW_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.POU_BRDN_COST,
                      to_number(null)))            POU_BRDN_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.POU_BILL_RAW_COST,
                      to_number(null)))            POU_BILL_RAW_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.POU_BILL_BRDN_COST,
                      to_number(null)))            POU_BILL_BRDN_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.POU_REVENUE_WRITEOFF,
                      to_number(null)))            POU_REVENUE_WRITEOFF,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_I', tmp2.POU_BRDN_COST,
                        to_number(null)))          POU_SUP_INV_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_P', tmp2.POU_BRDN_COST,
                        to_number(null)))          POU_PO_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_R', tmp2.POU_BRDN_COST,
                        to_number(null)))          POU_PR_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_O', tmp2.POU_BRDN_COST,
                        to_number(null)))          POU_OTH_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.EOU_REVENUE,
                      to_number(null)))            EOU_REVENUE,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.EOU_RAW_COST,
                      to_number(null)))            EOU_RAW_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.EOU_BRDN_COST,
                      to_number(null)))            EOU_BRDN_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.EOU_BILL_RAW_COST,
                      to_number(null)))            EOU_BILL_RAW_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.EOU_BILL_BRDN_COST,
                      to_number(null)))            EOU_BILL_BRDN_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_I', tmp2.EOU_BRDN_COST,
                        to_number(null)))          EOU_SUP_INV_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_P', tmp2.EOU_BRDN_COST,
                        to_number(null)))          EOU_PO_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_R', tmp2.EOU_BRDN_COST,
                        to_number(null)))          EOU_PR_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_O', tmp2.EOU_BRDN_COST,
                        to_number(null)))          EOU_OTH_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.QUANTITY,
                      to_number(null)))            QUANTITY,
      sum(decode(tmp2.RECORD_TYPE,
                 'A', tmp2.BILL_QUANTITY,
                      to_number(null)))            BILL_QUANTITY,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID,
                 'A_ENT', tmp2.GG1_REVENUE,
                 'A_GL',  tmp2.GG1_REVENUE,
                 'A_PA',  tmp2.GP1_REVENUE,
                          to_number(null)))        G1_REVENUE,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID,
                 'A_ENT', tmp2.GG1_RAW_COST,
                 'A_GL',  tmp2.GG1_RAW_COST,
                 'A_PA',  tmp2.GP1_RAW_COST,
                          to_number(null)))        G1_RAW_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID,
                 'A_ENT', tmp2.GG1_BRDN_COST,
                 'A_GL',  tmp2.GG1_BRDN_COST,
                 'A_PA',  tmp2.GP1_BRDN_COST,
                          to_number(null)))        G1_BRDN_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID,
                 'A_ENT', tmp2.GG1_BILL_RAW_COST,
                 'A_GL',  tmp2.GG1_BILL_RAW_COST,
                 'A_PA',  tmp2.GP1_BILL_RAW_COST,
                          to_number(null)))        G1_BILL_RAW_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID,
                 'A_ENT', tmp2.GG1_BILL_BRDN_COST,
                 'A_GL',  tmp2.GG1_BILL_BRDN_COST,
                 'A_PA',  tmp2.GP1_BILL_BRDN_COST,
                          to_number(null)))        G1_BILL_BRDN_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID,
                 'A_ENT', tmp2.GG1_REVENUE_WRITEOFF,
                 'A_GL',  tmp2.GG1_REVENUE_WRITEOFF,
                 'A_PA',  tmp2.GP1_REVENUE_WRITEOFF,
                          to_number(null)))        G1_REVENUE_WRITEOFF,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_ENT_I', tmp2.GG1_BRDN_COST,
                 'M_GL_I', tmp2.GG1_BRDN_COST,
                 'M_PA_I', tmp2.GP1_BRDN_COST,
                           to_number(null)))       G1_SUP_INV_COMMITTED_COST, -- Bug 6410765. Modified from M_GL_I to M_ENT_I
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_ENT_P', tmp2.GG1_BRDN_COST,
                 'M_GL_P', tmp2.GG1_BRDN_COST,
                 'M_PA_P', tmp2.GP1_BRDN_COST,
                           to_number(null)))       G1_PO_COMMITTED_COST, -- Bug 6410765. Modified from M_GL_P to M_ENT_P
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_ENT_R', tmp2.GG1_BRDN_COST,
                 'M_GL_R', tmp2.GG1_BRDN_COST,
                 'M_PA_R', tmp2.GP1_BRDN_COST,
                           to_number(null)))       G1_PR_COMMITTED_COST, -- Bug 6410765. Modified from M_GL_R to M_ENT_R
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_ENT_O', tmp2.GG1_BRDN_COST,
                 'M_GL_O', tmp2.GG1_BRDN_COST,
                 'M_PA_O', tmp2.GP1_BRDN_COST,
                           to_number(null)))       G1_OTH_COMMITTED_COST, -- Bug 6410765. Modified from M_GL_O to M_ENT_O
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID,
                 'A_ENT', tmp2.GG2_REVENUE,
                 'A_GL',  tmp2.GG2_REVENUE,
                 'A_PA',  tmp2.GP2_REVENUE,
                          to_number(null)))        G2_REVENUE,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID,
                 'A_ENT', tmp2.GG2_RAW_COST,
                 'A_GL',  tmp2.GG2_RAW_COST,
                 'A_PA',  tmp2.GP2_RAW_COST,
                          to_number(null)))        G2_RAW_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID,
                 'A_ENT', tmp2.GG2_BRDN_COST,
                 'A_GL',  tmp2.GG2_BRDN_COST,
                 'A_PA',  tmp2.GP2_BRDN_COST,
                          to_number(null)))        G2_BRDN_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID,
                 'A_ENT', tmp2.GG2_BILL_RAW_COST,
                 'A_GL',  tmp2.GG2_BILL_RAW_COST,
                 'A_PA',  tmp2.GP2_BILL_RAW_COST,
                          to_number(null)))        G2_BILL_RAW_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID,
                 'A_ENT', tmp2.GG2_BILL_BRDN_COST,
                 'A_GL',  tmp2.GG2_BILL_BRDN_COST,
                 'A_PA',  tmp2.GP2_BILL_BRDN_COST,
                          to_number(null)))        G2_BILL_BRDN_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID,
                 'A_ENT', tmp2.GG2_REVENUE_WRITEOFF,
                 'A_GL',  tmp2.GG2_REVENUE_WRITEOFF,
                 'A_PA',  tmp2.GP2_REVENUE_WRITEOFF,
                          to_number(null)))        G2_REVENUE_WRITEOFF,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_ENT_I', tmp2.GG2_BRDN_COST,
                 'M_GL_I',  tmp2.GG2_BRDN_COST,
                 'M_PA_I',  tmp2.GP2_BRDN_COST,
                            to_number(null)))      G2_SUP_INV_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_ENT_P', tmp2.GG2_BRDN_COST,
                 'M_GL_P',  tmp2.GG2_BRDN_COST,
                 'M_PA_P',  tmp2.GP2_BRDN_COST,
                            to_number(null)))      G2_PO_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_ENT_R', tmp2.GG2_BRDN_COST,
                 'M_GL_R',  tmp2.GG2_BRDN_COST,
                 'M_PA_R',  tmp2.GP2_BRDN_COST,
                            to_number(null)))      G2_PR_COMMITTED_COST,
      sum(decode(tmp2.RECORD_TYPE || '_' ||
                 invert.INVERT_ID || '_' ||
                 tmp2.CMT_RECORD_TYPE,
                 'M_ENT_O', tmp2.GG2_BRDN_COST,
                 'M_GL_O',  tmp2.GG2_BRDN_COST,
                 'M_PA_O',  tmp2.GP2_BRDN_COST,
                            to_number(null)))      G2_OTH_COMMITTED_COST
    from
      (
      select /*+ ordered
                 full(tmp2) parallel(tmp2) use_hash(tmp2)
                 full(ent)  parallel(ent)  use_hash(ent) */
        tmp2.RECORD_TYPE,
        tmp2.CMT_RECORD_TYPE,
        nvl(tmp2.PERSON_ID, -1)                    PERSON_ID,
        nvl(tmp2.EXPENDITURE_ORG_ID, -1)           EXPENDITURE_ORG_ID,
        nvl(tmp2.EXPENDITURE_ORGANIZATION_ID, -1)  EXPENDITURE_ORGANIZATION_ID,
        nvl(tmp2.JOB_ID, -1)                       JOB_ID,
        nvl(tmp2.VENDOR_ID, -1)                    VENDOR_ID,
        nvl(tmp2.WORK_TYPE_ID, -1)                 WORK_TYPE_ID,
        nvl(tmp2.EXP_EVT_TYPE_ID, -1)              EXP_EVT_TYPE_ID,
        nvl(tmp2.EXPENDITURE_TYPE, 'PJI$NULL')     EXPENDITURE_TYPE,
        nvl(tmp2.EVENT_TYPE, 'PJI$NULL')           EVENT_TYPE,
        nvl(tmp2.EVENT_TYPE_CLASSIFICATION, 'PJI$NULL')
                                                   EVENT_TYPE_CLASSIFICATION,
        nvl(tmp2.EXPENDITURE_CATEGORY, 'PJI$NULL') EXPENDITURE_CATEGORY,
        nvl(tmp2.REVENUE_CATEGORY, 'PJI$NULL')     REVENUE_CATEGORY,
        nvl(nlr.NON_LABOR_RESOURCE_ID, -1)         NON_LABOR_RESOURCE_ID,
        decode(tmp2.SYSTEM_LINKAGE_FUNCTION || decode(bom.RESOURCE_TYPE, 2,
                                                      '$PEOPLE', null),
               'WIP$PEOPLE', nvl(tmp2.BOM_LABOR_RESOURCE_ID, -1),
               -1)                                 BOM_LABOR_RESOURCE_ID,
        decode(tmp2.SYSTEM_LINKAGE_FUNCTION || decode(bom.RESOURCE_TYPE, 1,
                                                      '$EQUIPMENT', null),
               'WIP$EQUIPMENT', nvl(tmp2.BOM_EQUIPMENT_RESOURCE_ID, -1),
               -1)                                 BOM_EQUIPMENT_RESOURCE_ID,
        nvl(tmp2.INVENTORY_ITEM_ID, -1)            INVENTORY_ITEM_ID,
        nvl(asg.PROJECT_ROLE_ID, -1)               PROJECT_ROLE_ID,
        nvl(asg.ASSIGNMENT_NAME, 'PJI$NULL')       NAMED_ROLE,
        nvl(typ.SYSTEM_PERSON_TYPE, 'PJI$NULL')    PERSON_TYPE,
        nvl(tmp2.SYSTEM_LINKAGE_FUNCTION, 'PJI$NULL')
                                                   SYSTEM_LINKAGE_FUNCTION,
        decode
          (tmp2.RECORD_TYPE,
           'A',
           decode
             (tmp2.SYSTEM_LINKAGE_FUNCTION,
              'WIP', 'WIP$' || decode
                                 (bom.RESOURCE_TYPE,
                                  1, 'EQUIPMENT',
                                  2, 'PEOPLE',
                                     'OTHER'),
              'USG', 'USG$' || nvl(nlr.EQUIPMENT_RESOURCE_FLAG, 'N'),
              'VI',  'VI$'  || decode
                                 (nvl(tmp2.INVENTORY_ITEM_ID, -1),
                                  -1,
                                  decode
                                    (lt.ORDER_TYPE_LOOKUP_CODE,
                                     'RATE',
                                     decode
                                       (imp.XFACE_CWK_TIMECARDS_FLAG,
                                        'Y', 'PEOPLE', 'FINANCIAL'),
                                     'FINANCIAL'),
                                  'MATERIAL'),
              nvl(tmp2.SYSTEM_LINKAGE_FUNCTION, 'PJI$NULL')),
           'M',
           tmp2.RESOURCE_CLASS_CODE)               SYSTEM_LINKAGE_FUNCTION_R,
        tmp2.PROJECT_ID,
        tmp2.PROJECT_ORG_ID,
        tmp2.PROJECT_ORGANIZATION_ID,
        tmp2.PROJECT_TYPE_CLASS,
        tmp2.TASK_ID,
        tmp2.ASSIGNMENT_ID,
        ent.ENT_PERIOD_ID                          RECVR_ENT_PERIOD_ID,
        tmp2.GL_PERIOD_NAME                        RECVR_GL_PERIOD_NAME,
        tmp2.PA_PERIOD_NAME                        RECVR_PA_PERIOD_NAME,
        tmp2.PJ_GL_CALENDAR_ID                     RECVR_GL_CALENDAR_ID,
        tmp2.PJ_PA_CALENDAR_ID                     RECVR_PA_CALENDAR_ID,
        tmp2.TXN_CURRENCY_CODE,
        sum(tmp2.TXN_REVENUE)                      TXN_REVENUE,
        sum(tmp2.TXN_RAW_COST)                     TXN_RAW_COST,
        sum(tmp2.TXN_BRDN_COST)                    TXN_BRDN_COST,
        sum(tmp2.TXN_BILL_RAW_COST)                TXN_BILL_RAW_COST,
        sum(tmp2.TXN_BILL_BRDN_COST)               TXN_BILL_BRDN_COST,
        sum(tmp2.PRJ_REVENUE)                      PRJ_REVENUE,
        sum(tmp2.PRJ_RAW_COST)                     PRJ_RAW_COST,
        sum(tmp2.PRJ_BRDN_COST)                    PRJ_BRDN_COST,
        sum(tmp2.PRJ_BILL_RAW_COST)                PRJ_BILL_RAW_COST,
        sum(tmp2.PRJ_BILL_BRDN_COST)               PRJ_BILL_BRDN_COST,
        sum(tmp2.PRJ_REVENUE_WRITEOFF)             PRJ_REVENUE_WRITEOFF,
        sum(tmp2.POU_REVENUE)                      POU_REVENUE,
        sum(tmp2.POU_RAW_COST)                     POU_RAW_COST,
        sum(tmp2.POU_BRDN_COST)                    POU_BRDN_COST,
        sum(tmp2.POU_BILL_RAW_COST)                POU_BILL_RAW_COST,
        sum(tmp2.POU_BILL_BRDN_COST)               POU_BILL_BRDN_COST,
        sum(tmp2.POU_REVENUE_WRITEOFF)             POU_REVENUE_WRITEOFF,
        sum(tmp2.EOU_REVENUE)                      EOU_REVENUE,
        sum(tmp2.EOU_RAW_COST)                     EOU_RAW_COST,
        sum(tmp2.EOU_BRDN_COST)                    EOU_BRDN_COST,
        sum(tmp2.EOU_BILL_RAW_COST)                EOU_BILL_RAW_COST,
        sum(tmp2.EOU_BILL_BRDN_COST)               EOU_BILL_BRDN_COST,
        sum(tmp2.TOTAL_HRS_A)                      QUANTITY,
        sum(tmp2.BILL_HRS_A)                       BILL_QUANTITY,
        sum(tmp2.GG1_REVENUE)                      GG1_REVENUE,
        sum(tmp2.GG1_RAW_COST)                     GG1_RAW_COST,
        sum(tmp2.GG1_BRDN_COST)                    GG1_BRDN_COST,
        sum(tmp2.GG1_BILL_RAW_COST)                GG1_BILL_RAW_COST,
        sum(tmp2.GG1_BILL_BRDN_COST)               GG1_BILL_BRDN_COST,
        sum(tmp2.GG1_REVENUE_WRITEOFF)             GG1_REVENUE_WRITEOFF,
        sum(tmp2.GP1_REVENUE)                      GP1_REVENUE,
        sum(tmp2.GP1_RAW_COST)                     GP1_RAW_COST,
        sum(tmp2.GP1_BRDN_COST)                    GP1_BRDN_COST,
        sum(tmp2.GP1_BILL_RAW_COST)                GP1_BILL_RAW_COST,
        sum(tmp2.GP1_BILL_BRDN_COST)               GP1_BILL_BRDN_COST,
        sum(tmp2.GP1_REVENUE_WRITEOFF)             GP1_REVENUE_WRITEOFF,
        sum(tmp2.GG2_REVENUE)                      GG2_REVENUE,
        sum(tmp2.GG2_RAW_COST)                     GG2_RAW_COST,
        sum(tmp2.GG2_BRDN_COST)                    GG2_BRDN_COST,
        sum(tmp2.GG2_BILL_RAW_COST)                GG2_BILL_RAW_COST,
        sum(tmp2.GG2_BILL_BRDN_COST)               GG2_BILL_BRDN_COST,
        sum(tmp2.GG2_REVENUE_WRITEOFF)             GG2_REVENUE_WRITEOFF,
        sum(tmp2.GP2_REVENUE)                      GP2_REVENUE,
        sum(tmp2.GP2_RAW_COST)                     GP2_RAW_COST,
        sum(tmp2.GP2_BRDN_COST)                    GP2_BRDN_COST,
        sum(tmp2.GP2_BILL_RAW_COST)                GP2_BILL_RAW_COST,
        sum(tmp2.GP2_BILL_BRDN_COST)               GP2_BILL_BRDN_COST,
        sum(tmp2.GP2_REVENUE_WRITEOFF)             GP2_REVENUE_WRITEOFF
      from
        (
        select
          tmp2.WORKER_ID,
          tmp2.RECORD_TYPE,
          tmp2.CMT_RECORD_TYPE,
          tmp2.PERSON_ID,
          tmp2.EXPENDITURE_ORG_ID,
          tmp2.EXPENDITURE_ORGANIZATION_ID,
          tmp2.JOB_ID,
          tmp2.VENDOR_ID,
          tmp2.WORK_TYPE_ID,
          tmp2.EXP_EVT_TYPE_ID,
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
          tmp2.SYSTEM_LINKAGE_FUNCTION,
          tmp2.RESOURCE_CLASS_CODE,
          tmp2.PROJECT_ID,
          tmp2.PROJECT_ORG_ID,
          tmp2.PROJECT_ORGANIZATION_ID,
          tmp2.PROJECT_TYPE_CLASS,
          tmp2.TASK_ID,
          tmp2.ASSIGNMENT_ID,
          tmp2.RECVR_GL_TIME_ID,
          tmp2.GL_PERIOD_NAME,
          tmp2.PA_PERIOD_NAME,
          tmp2.PJ_GL_CALENDAR_ID,
          tmp2.PJ_PA_CALENDAR_ID,
          tmp2.TXN_CURRENCY_CODE,
          tmp2.TXN_REVENUE,
          tmp2.TXN_RAW_COST,
          tmp2.TXN_BRDN_COST,
          tmp2.TXN_BILL_RAW_COST,
          tmp2.TXN_BILL_BRDN_COST,
          tmp2.PRJ_REVENUE,
          tmp2.PRJ_RAW_COST,
          tmp2.PRJ_BRDN_COST,
          tmp2.PRJ_BILL_RAW_COST,
          tmp2.PRJ_BILL_BRDN_COST,
          tmp2.PRJ_REVENUE_WRITEOFF,
          tmp2.POU_REVENUE,
          tmp2.POU_RAW_COST,
          tmp2.POU_BRDN_COST,
          tmp2.POU_BILL_RAW_COST,
          tmp2.POU_BILL_BRDN_COST,
          tmp2.POU_REVENUE_WRITEOFF,
          tmp2.EOU_REVENUE,
          tmp2.EOU_RAW_COST,
          tmp2.EOU_BRDN_COST,
          tmp2.EOU_BILL_RAW_COST,
          tmp2.EOU_BILL_BRDN_COST,
          tmp2.TOTAL_HRS_A,
          tmp2.BILL_HRS_A,
          tmp2.GG1_REVENUE,
          tmp2.GG1_RAW_COST,
          tmp2.GG1_BRDN_COST,
          tmp2.GG1_BILL_RAW_COST,
          tmp2.GG1_BILL_BRDN_COST,
          tmp2.GG1_REVENUE_WRITEOFF,
          tmp2.GP1_REVENUE,
          tmp2.GP1_RAW_COST,
          tmp2.GP1_BRDN_COST,
          tmp2.GP1_BILL_RAW_COST,
          tmp2.GP1_BILL_BRDN_COST,
          tmp2.GP1_REVENUE_WRITEOFF,
          tmp2.GG2_REVENUE,
          tmp2.GG2_RAW_COST,
          tmp2.GG2_BRDN_COST,
          tmp2.GG2_BILL_RAW_COST,
          tmp2.GG2_BILL_BRDN_COST,
          tmp2.GG2_REVENUE_WRITEOFF,
          tmp2.GP2_REVENUE,
          tmp2.GP2_RAW_COST,
          tmp2.GP2_BRDN_COST,
          tmp2.GP2_BILL_RAW_COST,
          tmp2.GP2_BILL_BRDN_COST,
          tmp2.GP2_REVENUE_WRITEOFF
        from
          PJI_FM_AGGR_FIN2 tmp2
        where
          tmp2.WORKER_ID = p_worker_id and
          tmp2.GL_PERIOD_NAME is not null and
          tmp2.PA_PERIOD_NAME is not null and
          tmp2.PJI_PROJECT_RECORD_FLAG = 'Y'
        union all
        select /*+ ordered
                   full(tmp2) parallel(tmp2) */
          tmp2.WORKER_ID,
          tmp2.RECORD_TYPE,
          tmp2.CMT_RECORD_TYPE,
          tmp2.PERSON_ID,
          tmp2.EXPENDITURE_ORG_ID,
          tmp2.EXPENDITURE_ORGANIZATION_ID,
          tmp2.JOB_ID,
          tmp2.VENDOR_ID,
          tmp2.WORK_TYPE_ID,
          tmp2.EXP_EVT_TYPE_ID,
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
          tmp2.SYSTEM_LINKAGE_FUNCTION,
          tmp2.RESOURCE_CLASS_CODE,
          tmp2.PROJECT_ID,
          tmp2.PROJECT_ORG_ID,
          tmp2.PROJECT_ORGANIZATION_ID,
          tmp2.PROJECT_TYPE_CLASS,
          tmp2.TASK_ID,
          tmp2.ASSIGNMENT_ID,
          tmp2.RECVR_GL_TIME_ID,
          gl_per.PERIOD_NAME                               GL_PERIOD_NAME,
          pa_per.PERIOD_NAME                               PA_PERIOD_NAME,
          tmp2.PJ_GL_CALENDAR_ID,
          tmp2.PJ_PA_CALENDAR_ID,
          tmp2.TXN_CURRENCY_CODE,
          tmp2.TXN_REVENUE,
          tmp2.TXN_RAW_COST,
          tmp2.TXN_BRDN_COST,
          tmp2.TXN_BILL_RAW_COST,
          tmp2.TXN_BILL_BRDN_COST,
          tmp2.PRJ_REVENUE,
          tmp2.PRJ_RAW_COST,
          tmp2.PRJ_BRDN_COST,
          tmp2.PRJ_BILL_RAW_COST,
          tmp2.PRJ_BILL_BRDN_COST,
          tmp2.PRJ_REVENUE_WRITEOFF,
          tmp2.POU_REVENUE,
          tmp2.POU_RAW_COST,
          tmp2.POU_BRDN_COST,
          tmp2.POU_BILL_RAW_COST,
          tmp2.POU_BILL_BRDN_COST,
          tmp2.POU_REVENUE_WRITEOFF,
          tmp2.EOU_REVENUE,
          tmp2.EOU_RAW_COST,
          tmp2.EOU_BRDN_COST,
          tmp2.EOU_BILL_RAW_COST,
          tmp2.EOU_BILL_BRDN_COST,
          tmp2.TOTAL_HRS_A,
          tmp2.BILL_HRS_A,
          tmp2.GG1_REVENUE,
          tmp2.GG1_RAW_COST,
          tmp2.GG1_BRDN_COST,
          tmp2.GG1_BILL_RAW_COST,
          tmp2.GG1_BILL_BRDN_COST,
          tmp2.GG1_REVENUE_WRITEOFF,
          tmp2.GP1_REVENUE,
          tmp2.GP1_RAW_COST,
          tmp2.GP1_BRDN_COST,
          tmp2.GP1_BILL_RAW_COST,
          tmp2.GP1_BILL_BRDN_COST,
          tmp2.GP1_REVENUE_WRITEOFF,
          tmp2.GG2_REVENUE,
          tmp2.GG2_RAW_COST,
          tmp2.GG2_BRDN_COST,
          tmp2.GG2_BILL_RAW_COST,
          tmp2.GG2_BILL_BRDN_COST,
          tmp2.GG2_REVENUE_WRITEOFF,
          tmp2.GP2_REVENUE,
          tmp2.GP2_RAW_COST,
          tmp2.GP2_BRDN_COST,
          tmp2.GP2_BILL_RAW_COST,
          tmp2.GP2_BILL_BRDN_COST,
          tmp2.GP2_REVENUE_WRITEOFF
        from
          PJI_FM_AGGR_FIN2  tmp2,
          FII_TIME_CAL_NAME gl_cal,
          GL_PERIODS        gl_per,
          PA_PERIODS_ALL    pa_per
        where
          tmp2.WORKER_ID          = p_worker_id            and
          (tmp2.GL_PERIOD_NAME is null or
           tmp2.PA_PERIOD_NAME is null)                    and
          tmp2.PJI_PROJECT_RECORD_FLAG = 'Y'               and
          gl_cal.CALENDAR_ID      = tmp2.PJ_GL_CALENDAR_ID and
          gl_per.PERIOD_SET_NAME  = gl_cal.PERIOD_SET_NAME and
          gl_per.PERIOD_TYPE      = gl_cal.PERIOD_TYPE     and
          to_date(to_char(tmp2.RECVR_GL_TIME_ID), 'J')
            between gl_per.START_DATE and gl_per.END_DATE  and
          pa_per.ORG_ID           = tmp2.PROJECT_ORG_ID    and
          to_date(to_char(tmp2.RECVR_PA_TIME_ID), 'J')
            between pa_per.START_DATE and pa_per.END_DATE
        )                      tmp2,
        PJI_TIME_ENT_PERIOD_V  ent,
        (
        select
          distinct
          usg.PERSON_ID,
          usg.EFFECTIVE_START_DATE,
          usg.EFFECTIVE_END_DATE,
          typ.SYSTEM_PERSON_TYPE
        from
          PER_PERSON_TYPES typ,
          PER_PERSON_TYPE_USAGES_F usg
        where
          typ.SYSTEM_PERSON_TYPE in ('EMP', 'CWK') and
          typ.PERSON_TYPE_ID = usg.PERSON_TYPE_ID
        ) typ,                                         -- (+)
        BOM_RESOURCES          bom,                    -- (+)
        PA_NON_LABOR_RESOURCES nlr,                    -- (+)
        PO_LINES_ALL           pol,                    -- (+)
        PO_LINE_TYPES_B        lt,                     -- (+)
        PA_PROJECT_ASSIGNMENTS asg,                    -- (+)
        PA_IMPLEMENTATIONS_ALL imp
      where
        tmp2.WORKER_ID               = p_worker_id                 and
        to_date(to_char(tmp2.RECVR_GL_TIME_ID), 'J')
          between ent.START_DATE and ent.END_DATE                  and
        tmp2.PERSON_ID               = typ.PERSON_ID          (+)  and
        to_date(to_char(tmp2.RECVR_GL_TIME_ID), 'J')
          between typ.EFFECTIVE_START_DATE (+) and
                  typ.EFFECTIVE_END_DATE (+)                       and
        tmp2.NON_LABOR_RESOURCE      = nlr.NON_LABOR_RESOURCE (+)  and
        tmp2.BOM_LABOR_RESOURCE_ID   = bom.RESOURCE_ID        (+)  and
        tmp2.PO_LINE_ID              = pol.PO_LINE_ID         (+)  and
        pol.LINE_TYPE_ID             = lt.LINE_TYPE_ID        (+)  and
        tmp2.ASSIGNMENT_ID           = asg.ASSIGNMENT_ID      (+)  and
        nvl(tmp2.PROJECT_ORG_ID, -1) = nvl(imp.ORG_ID, -1)
      group by
        tmp2.RECORD_TYPE,
        tmp2.CMT_RECORD_TYPE,
        nvl(tmp2.PERSON_ID, -1),
        nvl(tmp2.EXPENDITURE_ORG_ID, -1),
        nvl(tmp2.EXPENDITURE_ORGANIZATION_ID, -1),
        nvl(tmp2.JOB_ID, -1),
        nvl(tmp2.VENDOR_ID, -1),
        nvl(tmp2.WORK_TYPE_ID, -1),
        nvl(tmp2.EXP_EVT_TYPE_ID, -1),
        nvl(tmp2.EXPENDITURE_TYPE, 'PJI$NULL'),
        nvl(tmp2.EVENT_TYPE, 'PJI$NULL'),
        nvl(tmp2.EVENT_TYPE_CLASSIFICATION, 'PJI$NULL'),
        nvl(tmp2.EXPENDITURE_CATEGORY, 'PJI$NULL'),
        nvl(tmp2.REVENUE_CATEGORY, 'PJI$NULL'),
        nvl(nlr.NON_LABOR_RESOURCE_ID, -1),
        decode(tmp2.SYSTEM_LINKAGE_FUNCTION || decode(bom.RESOURCE_TYPE, 2,
                                                      '$PEOPLE', null),
               'WIP$PEOPLE', nvl(tmp2.BOM_LABOR_RESOURCE_ID, -1),
               -1),
        decode(tmp2.SYSTEM_LINKAGE_FUNCTION || decode(bom.RESOURCE_TYPE, 1,
                                                      '$EQUIPMENT', null),
               'WIP$EQUIPMENT', nvl(tmp2.BOM_EQUIPMENT_RESOURCE_ID, -1),
               -1),
        nvl(tmp2.INVENTORY_ITEM_ID, -1),
        nvl(asg.PROJECT_ROLE_ID, -1),
        nvl(asg.ASSIGNMENT_NAME, 'PJI$NULL'),
        nvl(typ.SYSTEM_PERSON_TYPE, 'PJI$NULL'),
        nvl(tmp2.SYSTEM_LINKAGE_FUNCTION, 'PJI$NULL'),
        decode
          (tmp2.RECORD_TYPE,
           'A',
           decode
             (tmp2.SYSTEM_LINKAGE_FUNCTION,
              'WIP', 'WIP$' || decode
                                 (bom.RESOURCE_TYPE,
                                  1, 'EQUIPMENT',
                                  2, 'PEOPLE',
                                     'OTHER'),
              'USG', 'USG$' || nvl(nlr.EQUIPMENT_RESOURCE_FLAG, 'N'),
              'VI',  'VI$'  || decode
                                 (nvl(tmp2.INVENTORY_ITEM_ID, -1),
                                  -1,
                                  decode
                                    (lt.ORDER_TYPE_LOOKUP_CODE,
                                     'RATE',
                                     decode
                                       (imp.XFACE_CWK_TIMECARDS_FLAG,
                                        'Y', 'PEOPLE', 'FINANCIAL'),
                                     'FINANCIAL'),
                                  'MATERIAL'),
              nvl(tmp2.SYSTEM_LINKAGE_FUNCTION, 'PJI$NULL')),
           'M',
           tmp2.RESOURCE_CLASS_CODE),
        tmp2.PROJECT_ID,
        tmp2.PROJECT_ORG_ID,
        tmp2.PROJECT_ORGANIZATION_ID,
        tmp2.PROJECT_TYPE_CLASS,
        tmp2.TASK_ID,
        tmp2.ASSIGNMENT_ID,
        ent.ENT_PERIOD_ID,
        tmp2.GL_PERIOD_NAME,
        tmp2.PA_PERIOD_NAME,
        tmp2.PJ_GL_CALENDAR_ID,
        tmp2.PJ_PA_CALENDAR_ID,
        tmp2.TXN_CURRENCY_CODE
      )                         tmp2,
      PJI_TIME_CAL_PERIOD_V     gl_cal,
      PJI_TIME_CAL_PERIOD_V     pa_cal,
      PJI_FM_AGGR_RES_TYPES     res_typs,
      (
        select
          cat.CATEGORY_ID ITEM_CATEGORY_ID,
          cat.INVENTORY_ITEM_ID,
          cat.ORGANIZATION_ID
        from
          PA_RESOURCE_CLASSES_B classes,
          PA_PLAN_RES_DEFAULTS  cls,
          MTL_ITEM_CATEGORIES   cat                  -- (+)  big
        where
          classes.RESOURCE_CLASS_CODE = 'MATERIAL_ITEMS'          and
          cls.RESOURCE_CLASS_ID       = classes.RESOURCE_CLASS_ID and
          cls.ITEM_CATEGORY_SET_ID    = cat.CATEGORY_SET_ID
      ) inv,
      PA_EXPENDITURE_CATEGORIES exp_cat,             -- (+)
      (
        select 'ENT' INVERT_ID from dual union all
        select 'GL'  INVERT_ID from dual union all
        select 'PA'  INVERT_ID from dual
      ) invert
    where
      tmp2.RECVR_GL_CALENDAR_ID        = gl_cal.CALENDAR_ID               and
      tmp2.RECVR_GL_PERIOD_NAME        = gl_cal.NAME                      and
      tmp2.RECVR_PA_CALENDAR_ID        = pa_cal.CALENDAR_ID               and
      tmp2.RECVR_PA_PERIOD_NAME        = pa_cal.NAME                      and
      tmp2.SYSTEM_LINKAGE_FUNCTION_R   = res_typs.EXP_TYPE_CLASS          and
      tmp2.EXPENDITURE_ORGANIZATION_ID = inv.ORGANIZATION_ID          (+) and
      tmp2.INVENTORY_ITEM_ID           = inv.INVENTORY_ITEM_ID        (+) and
      tmp2.EXPENDITURE_CATEGORY        = exp_cat.EXPENDITURE_CATEGORY (+)
    group by
      tmp2.RECORD_TYPE,
      tmp2.PERSON_ID,
      -- temporary fix for bug 3660160
      -- tmp2.EXPENDITURE_ORG_ID,
      tmp2.EXPENDITURE_ORGANIZATION_ID,
      nvl(res_typs.RESOURCE_CLASS_ID, -1),
      tmp2.JOB_ID,
      tmp2.VENDOR_ID,
      -- temporary fix for bug 3660160
      -- tmp2.WORK_TYPE_ID,
      nvl(exp_cat.EXPENDITURE_CATEGORY_ID, -1),
      decode(tmp2.EVENT_TYPE, 'PJI$NULL',
             tmp2.EXP_EVT_TYPE_ID, -1),
      decode(tmp2.EXPENDITURE_TYPE, 'PJI$NULL',
             tmp2.EXP_EVT_TYPE_ID, -1),
      -- temporary fix for bug 3813982
      -- tmp2.EXP_EVT_TYPE_ID,
      -- temporary fix for bug 3813982
      -- 'PJI$NULL',
      tmp2.EXPENDITURE_TYPE,
      tmp2.EVENT_TYPE,
      tmp2.EVENT_TYPE_CLASSIFICATION,
      -- temporary fix for bug 3813982
      -- 'PJI$NULL',
      tmp2.EXPENDITURE_CATEGORY,
      tmp2.REVENUE_CATEGORY,
      tmp2.NON_LABOR_RESOURCE_ID,
      tmp2.BOM_LABOR_RESOURCE_ID,
      tmp2.BOM_EQUIPMENT_RESOURCE_ID,
      nvl(inv.ITEM_CATEGORY_ID, -1),
      tmp2.INVENTORY_ITEM_ID,
      tmp2.PROJECT_ROLE_ID,
      tmp2.NAMED_ROLE,
      tmp2.PERSON_TYPE,
      -- temporary fix for bug 3813982
      -- tmp2.SYSTEM_LINKAGE_FUNCTION,
      tmp2.PROJECT_ID,
      tmp2.PROJECT_ORG_ID,
      tmp2.PROJECT_ORGANIZATION_ID,
      tmp2.PROJECT_TYPE_CLASS,
      tmp2.TASK_ID,
      tmp2.ASSIGNMENT_ID,
      decode(invert.INVERT_ID,
             'ENT', 'ENT',
             'GL',  'GL',
             'PA',  'PA'),
      decode(invert.INVERT_ID,
             'ENT', tmp2.RECVR_ENT_PERIOD_ID,
             'GL',  gl_cal.CAL_PERIOD_ID,
             'PA',  pa_cal.CAL_PERIOD_ID),
      tmp2.TXN_CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.AGGREGATE_FPR_PERIODS(p_worker_id);');

    commit;

  end AGGREGATE_FPR_PERIODS;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_ACR_PERIODS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure AGGREGATE_ACR_PERIODS (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.AGGREGATE_ACR_PERIODS(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(tmp4_i) */ into PJI_FM_AGGR_ACT4 tmp4_i
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      TASK_ID,
      PERIOD_TYPE,
      PERIOD_ID,
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
    select
      p_worker_id,
      tmp2.PROJECT_ID,
      tmp2.PROJECT_ORG_ID,
      tmp2.PROJECT_ORGANIZATION_ID,
      tmp2.TASK_ID,
      decode(invert.INVERT_ID,
             'ENT', 'ENT',
             'GL',  'GL',
             'PA',  'PA')                       PERIOD_TYPE,
      decode(invert.INVERT_ID,
             'ENT', tmp2.ENT_PERIOD_ID,
             'GL',  gl_cal.CAL_PERIOD_ID,
             'PA',  pa_cal.CAL_PERIOD_ID)       PERIOD_ID,
      tmp2.TXN_CURRENCY_CODE,
      sum(tmp2.TXN_REVENUE)                     TXN_REVENUE,
      sum(tmp2.TXN_FUNDING)                     TXN_FUNDING,
      sum(tmp2.TXN_INITIAL_FUNDING_AMOUNT)      TXN_INITIAL_FUNDING_AMOUNT,
      sum(tmp2.TXN_ADDITIONAL_FUNDING_AMOUNT)   TXN_ADDITIONAL_FUNDING_AMOUNT,
      sum(tmp2.TXN_CANCELLED_FUNDING_AMOUNT)    TXN_CANCELLED_FUNDING_AMOUNT,
      sum(tmp2.TXN_FUNDING_ADJUSTMENT_AMOUNT)   TXN_FUNDING_ADJUSTMENT_AMOUNT,
      sum(tmp2.TXN_REVENUE_WRITEOFF)            TXN_REVENUE_WRITEOFF,
      sum(tmp2.TXN_AR_INVOICE_AMOUNT)           TXN_AR_INVOICE_AMOUNT,
      sum(tmp2.TXN_AR_CASH_APPLIED_AMOUNT)      TXN_AR_CASH_APPLIED_AMOUNT,
      sum(tmp2.TXN_AR_INVOICE_WRITEOFF_AMOUNT)  TXN_AR_INVOICE_WRITEOFF_AMOUNT,
      sum(tmp2.TXN_AR_CREDIT_MEMO_AMOUNT)       TXN_AR_CREDIT_MEMO_AMOUNT,
      sum(tmp2.TXN_UNBILLED_RECEIVABLES)        TXN_UNBILLED_RECEIVABLES,
      sum(tmp2.TXN_UNEARNED_REVENUE)            TXN_UNEARNED_REVENUE,
      sum(tmp2.TXN_AR_UNAPPR_INVOICE_AMOUNT)    TXN_AR_UNAPPR_INVOICE_AMOUNT,
      sum(tmp2.TXN_AR_APPR_INVOICE_AMOUNT)      TXN_AR_APPR_INVOICE_AMOUNT,
      sum(tmp2.TXN_AR_AMOUNT_DUE)               TXN_AR_AMOUNT_DUE,
      sum(tmp2.TXN_AR_AMOUNT_OVERDUE)           TXN_AR_AMOUNT_OVERDUE,
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
             'ENT', tmp2.GG1_REVENUE,
             'GL',  tmp2.GG1_REVENUE,
             'PA',  tmp2.GP1_REVENUE))          G1_REVENUE,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_FUNDING,
             'GL',  tmp2.GG1_FUNDING,
             'PA',  tmp2.GP1_FUNDING))          G1_FUNDING,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_INITIAL_FUNDING_AMOUNT,
             'GL',  tmp2.GG1_INITIAL_FUNDING_AMOUNT,
             'PA',  tmp2.GP1_INITIAL_FUNDING_AMOUNT))
                                                G1_INITIAL_FUNDING_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_ADDITIONAL_FUNDING_AMOUNT,
             'GL',  tmp2.GG1_ADDITIONAL_FUNDING_AMOUNT,
             'PA',  tmp2.GP1_ADDITIONAL_FUNDING_AMOUNT))
                                                G1_ADDITIONAL_FUNDING_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_CANCELLED_FUNDING_AMOUNT,
             'GL',  tmp2.GG1_CANCELLED_FUNDING_AMOUNT,
             'PA',  tmp2.GP1_CANCELLED_FUNDING_AMOUNT))
                                                G1_CANCELLED_FUNDING_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_FUNDING_ADJUSTMENT_AMOUNT,
             'GL',  tmp2.GG1_FUNDING_ADJUSTMENT_AMOUNT,
             'PA',  tmp2.GP1_FUNDING_ADJUSTMENT_AMOUNT))
                                                G1_FUNDING_ADJUSTMENT_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_REVENUE_WRITEOFF,
             'GL',  tmp2.GG1_REVENUE_WRITEOFF,
             'PA',  tmp2.GP1_REVENUE_WRITEOFF))
                                                G1_REVENUE_WRITEOFF,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_AR_INVOICE_AMOUNT,
             'GL',  tmp2.GG1_AR_INVOICE_AMOUNT,
             'PA',  tmp2.GP1_AR_INVOICE_AMOUNT))
                                                G1_AR_INVOICE_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_AR_CASH_APPLIED_AMOUNT,
             'GL',  tmp2.GG1_AR_CASH_APPLIED_AMOUNT,
             'PA',  tmp2.GP1_AR_CASH_APPLIED_AMOUNT))
                                                G1_AR_CASH_APPLIED_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_AR_INVOICE_WRITEOFF_AMOUNT,
             'GL',  tmp2.GG1_AR_INVOICE_WRITEOFF_AMOUNT,
             'PA',  tmp2.GP1_AR_INVOICE_WRITEOFF_AMOUNT))
                                                G1_AR_INVOICE_WRITEOFF_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_AR_CREDIT_MEMO_AMOUNT,
             'GL',  tmp2.GG1_AR_CREDIT_MEMO_AMOUNT,
             'PA',  tmp2.GP1_AR_CREDIT_MEMO_AMOUNT))
                                                G1_AR_CREDIT_MEMO_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_UNBILLED_RECEIVABLES,
             'GL',  tmp2.GG1_UNBILLED_RECEIVABLES,
             'PA',  tmp2.GP1_UNBILLED_RECEIVABLES))
                                                G1_UNBILLED_RECEIVABLES,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_UNEARNED_REVENUE,
             'GL',  tmp2.GG1_UNEARNED_REVENUE,
             'PA',  tmp2.GP1_UNEARNED_REVENUE))
                                                G1_UNEARNED_REVENUE,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_AR_UNAPPR_INVOICE_AMOUNT,
             'GL',  tmp2.GG1_AR_UNAPPR_INVOICE_AMOUNT,
             'PA',  tmp2.GP1_AR_UNAPPR_INVOICE_AMOUNT))
                                                G1_AR_UNAPPR_INVOICE_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_AR_APPR_INVOICE_AMOUNT,
             'GL',  tmp2.GG1_AR_APPR_INVOICE_AMOUNT,
             'PA',  tmp2.GP1_AR_APPR_INVOICE_AMOUNT))
                                                G1_AR_APPR_INVOICE_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_AR_AMOUNT_DUE,
             'GL',  tmp2.GG1_AR_AMOUNT_DUE,
             'PA',  tmp2.GP1_AR_AMOUNT_DUE))    G1_AR_AMOUNT_DUE,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG1_AR_AMOUNT_OVERDUE,
             'GL',  tmp2.GG1_AR_AMOUNT_OVERDUE,
             'PA',  tmp2.GP1_AR_AMOUNT_OVERDUE))
                                                G1_AR_AMOUNT_OVERDUE,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_REVENUE,
             'GL',  tmp2.GG2_REVENUE,
             'PA',  tmp2.GP2_REVENUE))          G2_REVENUE,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_FUNDING,
             'GL',  tmp2.GG2_FUNDING,
             'PA',  tmp2.GP2_FUNDING))          G2_FUNDING,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_INITIAL_FUNDING_AMOUNT,
             'GL',  tmp2.GG2_INITIAL_FUNDING_AMOUNT,
             'PA',  tmp2.GP2_INITIAL_FUNDING_AMOUNT))
                                                G2_INITIAL_FUNDING_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_ADDITIONAL_FUNDING_AMOUNT,
             'GL',  tmp2.GG2_ADDITIONAL_FUNDING_AMOUNT,
             'PA',  tmp2.GP2_ADDITIONAL_FUNDING_AMOUNT))
                                                G2_ADDITIONAL_FUNDING_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_CANCELLED_FUNDING_AMOUNT,
             'GL',  tmp2.GG2_CANCELLED_FUNDING_AMOUNT,
             'PA',  tmp2.GP2_CANCELLED_FUNDING_AMOUNT))
                                                G2_CANCELLED_FUNDING_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_FUNDING_ADJUSTMENT_AMOUNT,
             'GL',  tmp2.GG2_FUNDING_ADJUSTMENT_AMOUNT,
             'PA',  tmp2.GP2_FUNDING_ADJUSTMENT_AMOUNT))
                                                G2_FUNDING_ADJUSTMENT_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_REVENUE_WRITEOFF,
             'GL',  tmp2.GG2_REVENUE_WRITEOFF,
             'PA',  tmp2.GP2_REVENUE_WRITEOFF))
                                                G2_REVENUE_WRITEOFF,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_AR_INVOICE_AMOUNT,
             'GL',  tmp2.GG2_AR_INVOICE_AMOUNT,
             'PA',  tmp2.GP2_AR_INVOICE_AMOUNT))
                                                G2_AR_INVOICE_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_AR_CASH_APPLIED_AMOUNT,
             'GL',  tmp2.GG2_AR_CASH_APPLIED_AMOUNT,
             'PA',  tmp2.GP2_AR_CASH_APPLIED_AMOUNT))
                                                G2_AR_CASH_APPLIED_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_AR_INVOICE_WRITEOFF_AMOUNT,
             'GL',  tmp2.GG2_AR_INVOICE_WRITEOFF_AMOUNT,
             'PA',  tmp2.GP2_AR_INVOICE_WRITEOFF_AMOUNT))
                                                G2_AR_INVOICE_WRITEOFF_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_AR_CREDIT_MEMO_AMOUNT,
             'GL',  tmp2.GG2_AR_CREDIT_MEMO_AMOUNT,
             'PA',  tmp2.GP2_AR_CREDIT_MEMO_AMOUNT))
                                                G2_AR_CREDIT_MEMO_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_UNBILLED_RECEIVABLES,
             'GL',  tmp2.GG2_UNBILLED_RECEIVABLES,
             'PA',  tmp2.GP2_UNBILLED_RECEIVABLES))
                                                G2_UNBILLED_RECEIVABLES,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_UNEARNED_REVENUE,
             'GL',  tmp2.GG2_UNEARNED_REVENUE,
             'PA',  tmp2.GP2_UNEARNED_REVENUE))
                                                G2_UNEARNED_REVENUE,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_AR_UNAPPR_INVOICE_AMOUNT,
             'GL',  tmp2.GG2_AR_UNAPPR_INVOICE_AMOUNT,
             'PA',  tmp2.GP2_AR_UNAPPR_INVOICE_AMOUNT))
                                                G2_AR_UNAPPR_INVOICE_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_AR_APPR_INVOICE_AMOUNT,
             'GL',  tmp2.GG2_AR_APPR_INVOICE_AMOUNT,
             'PA',  tmp2.GP2_AR_APPR_INVOICE_AMOUNT))
                                                G2_AR_APPR_INVOICE_AMOUNT,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_AR_AMOUNT_DUE,
             'GL',  tmp2.GG2_AR_AMOUNT_DUE,
             'PA',  tmp2.GP2_AR_AMOUNT_DUE))    G2_AR_AMOUNT_DUE,
      sum(decode(invert.INVERT_ID,
             'ENT', tmp2.GG2_AR_AMOUNT_OVERDUE,
             'GL',  tmp2.GG2_AR_AMOUNT_OVERDUE,
             'PA',  tmp2.GP2_AR_AMOUNT_OVERDUE))
                                                G2_AR_AMOUNT_OVERDUE
    from
      (
      select /*+ ordered full(tmp2) parallel(tmp2) */
        tmp2.WORKER_ID,
        tmp2.PROJECT_ID,
        tmp2.PROJECT_ORG_ID,
        tmp2.PROJECT_ORGANIZATION_ID,
        tmp2.TASK_ID,
        ent.ENT_PERIOD_ID,
        tmp2.GL_PERIOD_NAME,
        tmp2.PA_PERIOD_NAME,
        tmp2.GL_CALENDAR_ID,
        tmp2.PA_CALENDAR_ID,
        tmp2.TXN_CURRENCY_CODE,
        sum(tmp2.TXN_REVENUE)                   TXN_REVENUE,
        sum(tmp2.TXN_FUNDING)                   TXN_FUNDING,
        sum(tmp2.TXN_INITIAL_FUNDING_AMOUNT)    TXN_INITIAL_FUNDING_AMOUNT,
        sum(tmp2.TXN_ADDITIONAL_FUNDING_AMOUNT) TXN_ADDITIONAL_FUNDING_AMOUNT,
        sum(tmp2.TXN_CANCELLED_FUNDING_AMOUNT)  TXN_CANCELLED_FUNDING_AMOUNT,
        sum(tmp2.TXN_FUNDING_ADJUSTMENT_AMOUNT) TXN_FUNDING_ADJUSTMENT_AMOUNT,
        sum(tmp2.TXN_REVENUE_WRITEOFF)          TXN_REVENUE_WRITEOFF,
        sum(tmp2.TXN_AR_INVOICE_AMOUNT)         TXN_AR_INVOICE_AMOUNT,
        sum(tmp2.TXN_AR_CASH_APPLIED_AMOUNT)    TXN_AR_CASH_APPLIED_AMOUNT,
        sum(tmp2.TXN_AR_INVOICE_WRITEOFF_AMOUNT)TXN_AR_INVOICE_WRITEOFF_AMOUNT,
        sum(tmp2.TXN_AR_CREDIT_MEMO_AMOUNT)     TXN_AR_CREDIT_MEMO_AMOUNT,
        sum(tmp2.TXN_UNBILLED_RECEIVABLES)      TXN_UNBILLED_RECEIVABLES,
        sum(tmp2.TXN_UNEARNED_REVENUE)          TXN_UNEARNED_REVENUE,
        sum(tmp2.TXN_AR_UNAPPR_INVOICE_AMOUNT)  TXN_AR_UNAPPR_INVOICE_AMOUNT,
        sum(tmp2.TXN_AR_APPR_INVOICE_AMOUNT)    TXN_AR_APPR_INVOICE_AMOUNT,
        sum(tmp2.TXN_AR_AMOUNT_DUE)             TXN_AR_AMOUNT_DUE,
        sum(tmp2.TXN_AR_AMOUNT_OVERDUE)         TXN_AR_AMOUNT_OVERDUE,
        sum(tmp2.PRJ_REVENUE)                   PRJ_REVENUE,
        sum(tmp2.PRJ_FUNDING)                   PRJ_FUNDING,
        sum(tmp2.PRJ_INITIAL_FUNDING_AMOUNT)    PRJ_INITIAL_FUNDING_AMOUNT,
        sum(tmp2.PRJ_ADDITIONAL_FUNDING_AMOUNT) PRJ_ADDITIONAL_FUNDING_AMOUNT,
        sum(tmp2.PRJ_CANCELLED_FUNDING_AMOUNT)  PRJ_CANCELLED_FUNDING_AMOUNT,
        sum(tmp2.PRJ_FUNDING_ADJUSTMENT_AMOUNT) PRJ_FUNDING_ADJUSTMENT_AMOUNT,
        sum(tmp2.PRJ_REVENUE_WRITEOFF)          PRJ_REVENUE_WRITEOFF,
        sum(tmp2.PRJ_AR_INVOICE_AMOUNT)         PRJ_AR_INVOICE_AMOUNT,
        sum(tmp2.PRJ_AR_CASH_APPLIED_AMOUNT)    PRJ_AR_CASH_APPLIED_AMOUNT,
        sum(tmp2.PRJ_AR_INVOICE_WRITEOFF_AMOUNT)PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
        sum(tmp2.PRJ_AR_CREDIT_MEMO_AMOUNT)     PRJ_AR_CREDIT_MEMO_AMOUNT,
        sum(tmp2.PRJ_UNBILLED_RECEIVABLES)      PRJ_UNBILLED_RECEIVABLES,
        sum(tmp2.PRJ_UNEARNED_REVENUE)          PRJ_UNEARNED_REVENUE,
        sum(tmp2.PRJ_AR_UNAPPR_INVOICE_AMOUNT)  PRJ_AR_UNAPPR_INVOICE_AMOUNT,
        sum(tmp2.PRJ_AR_APPR_INVOICE_AMOUNT)    PRJ_AR_APPR_INVOICE_AMOUNT,
        sum(tmp2.PRJ_AR_AMOUNT_DUE)             PRJ_AR_AMOUNT_DUE,
        sum(tmp2.PRJ_AR_AMOUNT_OVERDUE)         PRJ_AR_AMOUNT_OVERDUE,
        sum(tmp2.POU_REVENUE)                   POU_REVENUE,
        sum(tmp2.POU_FUNDING)                   POU_FUNDING,
        sum(tmp2.POU_INITIAL_FUNDING_AMOUNT)    POU_INITIAL_FUNDING_AMOUNT,
        sum(tmp2.POU_ADDITIONAL_FUNDING_AMOUNT) POU_ADDITIONAL_FUNDING_AMOUNT,
        sum(tmp2.POU_CANCELLED_FUNDING_AMOUNT)  POU_CANCELLED_FUNDING_AMOUNT,
        sum(tmp2.POU_FUNDING_ADJUSTMENT_AMOUNT) POU_FUNDING_ADJUSTMENT_AMOUNT,
        sum(tmp2.POU_REVENUE_WRITEOFF)          POU_REVENUE_WRITEOFF,
        sum(tmp2.POU_AR_INVOICE_AMOUNT)         POU_AR_INVOICE_AMOUNT,
        sum(tmp2.POU_AR_CASH_APPLIED_AMOUNT)    POU_AR_CASH_APPLIED_AMOUNT,
        sum(tmp2.POU_AR_INVOICE_WRITEOFF_AMOUNT)POU_AR_INVOICE_WRITEOFF_AMOUNT,
        sum(tmp2.POU_AR_CREDIT_MEMO_AMOUNT)     POU_AR_CREDIT_MEMO_AMOUNT,
        sum(tmp2.POU_UNBILLED_RECEIVABLES)      POU_UNBILLED_RECEIVABLES,
        sum(tmp2.POU_UNEARNED_REVENUE)          POU_UNEARNED_REVENUE,
        sum(tmp2.POU_AR_UNAPPR_INVOICE_AMOUNT)  POU_AR_UNAPPR_INVOICE_AMOUNT,
        sum(tmp2.POU_AR_APPR_INVOICE_AMOUNT)    POU_AR_APPR_INVOICE_AMOUNT,
        sum(tmp2.POU_AR_AMOUNT_DUE)             POU_AR_AMOUNT_DUE,
        sum(tmp2.POU_AR_AMOUNT_OVERDUE)         POU_AR_AMOUNT_OVERDUE,
        sum(tmp2.INITIAL_FUNDING_COUNT)         INITIAL_FUNDING_COUNT,
        sum(tmp2.ADDITIONAL_FUNDING_COUNT)      ADDITIONAL_FUNDING_COUNT,
        sum(tmp2.CANCELLED_FUNDING_COUNT)       CANCELLED_FUNDING_COUNT,
        sum(tmp2.FUNDING_ADJUSTMENT_COUNT)      FUNDING_ADJUSTMENT_COUNT,
        sum(tmp2.AR_INVOICE_COUNT)              AR_INVOICE_COUNT,
        sum(tmp2.AR_CASH_APPLIED_COUNT)         AR_CASH_APPLIED_COUNT,
        sum(tmp2.AR_INVOICE_WRITEOFF_COUNT)     AR_INVOICE_WRITEOFF_COUNT,
        sum(tmp2.AR_CREDIT_MEMO_COUNT)          AR_CREDIT_MEMO_COUNT,
        sum(tmp2.AR_UNAPPR_INVOICE_COUNT)       AR_UNAPPR_INVOICE_COUNT,
        sum(tmp2.AR_APPR_INVOICE_COUNT)         AR_APPR_INVOICE_COUNT,
        sum(tmp2.AR_COUNT_DUE)                  AR_COUNT_DUE,
        sum(tmp2.AR_COUNT_OVERDUE)              AR_COUNT_OVERDUE,
        sum(tmp2.GG_REVENUE)                    GG1_REVENUE,
        sum(tmp2.GG_FUNDING)                    GG1_FUNDING,
        sum(tmp2.GG_INITIAL_FUNDING_AMOUNT)     GG1_INITIAL_FUNDING_AMOUNT,
        sum(tmp2.GG_ADDITIONAL_FUNDING_AMOUNT)  GG1_ADDITIONAL_FUNDING_AMOUNT,
        sum(tmp2.GG_CANCELLED_FUNDING_AMOUNT)   GG1_CANCELLED_FUNDING_AMOUNT,
        sum(tmp2.GG_FUNDING_ADJUSTMENT_AMOUNT)  GG1_FUNDING_ADJUSTMENT_AMOUNT,
        sum(tmp2.GG_REVENUE_WRITEOFF)           GG1_REVENUE_WRITEOFF,
        sum(tmp2.GG_AR_INVOICE_AMOUNT)          GG1_AR_INVOICE_AMOUNT,
        sum(tmp2.GG_AR_CASH_APPLIED_AMOUNT)     GG1_AR_CASH_APPLIED_AMOUNT,
        sum(tmp2.GG_AR_INVOICE_WRITEOFF_AMOUNT) GG1_AR_INVOICE_WRITEOFF_AMOUNT,
        sum(tmp2.GG_AR_CREDIT_MEMO_AMOUNT)      GG1_AR_CREDIT_MEMO_AMOUNT,
        sum(tmp2.GG_UNBILLED_RECEIVABLES)       GG1_UNBILLED_RECEIVABLES,
        sum(tmp2.GG_UNEARNED_REVENUE)           GG1_UNEARNED_REVENUE,
        sum(tmp2.GG_AR_UNAPPR_INVOICE_AMOUNT)   GG1_AR_UNAPPR_INVOICE_AMOUNT,
        sum(tmp2.GG_AR_APPR_INVOICE_AMOUNT)     GG1_AR_APPR_INVOICE_AMOUNT,
        sum(tmp2.GG_AR_AMOUNT_DUE)              GG1_AR_AMOUNT_DUE,
        sum(tmp2.GG_AR_AMOUNT_OVERDUE)          GG1_AR_AMOUNT_OVERDUE,
        sum(tmp2.GP_REVENUE)                    GP1_REVENUE,
        sum(tmp2.GP_FUNDING)                    GP1_FUNDING,
        sum(tmp2.GP_INITIAL_FUNDING_AMOUNT)     GP1_INITIAL_FUNDING_AMOUNT,
        sum(tmp2.GP_ADDITIONAL_FUNDING_AMOUNT)  GP1_ADDITIONAL_FUNDING_AMOUNT,
        sum(tmp2.GP_CANCELLED_FUNDING_AMOUNT)   GP1_CANCELLED_FUNDING_AMOUNT,
        sum(tmp2.GP_FUNDING_ADJUSTMENT_AMOUNT)  GP1_FUNDING_ADJUSTMENT_AMOUNT,
        sum(tmp2.GP_REVENUE_WRITEOFF)           GP1_REVENUE_WRITEOFF,
        sum(tmp2.GP_AR_INVOICE_AMOUNT)          GP1_AR_INVOICE_AMOUNT,
        sum(tmp2.GP_AR_CASH_APPLIED_AMOUNT)     GP1_AR_CASH_APPLIED_AMOUNT,
        sum(tmp2.GP_AR_INVOICE_WRITEOFF_AMOUNT) GP1_AR_INVOICE_WRITEOFF_AMOUNT,
        sum(tmp2.GP_AR_CREDIT_MEMO_AMOUNT)      GP1_AR_CREDIT_MEMO_AMOUNT,
        sum(tmp2.GP_UNBILLED_RECEIVABLES)       GP1_UNBILLED_RECEIVABLES,
        sum(tmp2.GP_UNEARNED_REVENUE)           GP1_UNEARNED_REVENUE,
        sum(tmp2.GP_AR_UNAPPR_INVOICE_AMOUNT)   GP1_AR_UNAPPR_INVOICE_AMOUNT,
        sum(tmp2.GP_AR_APPR_INVOICE_AMOUNT)     GP1_AR_APPR_INVOICE_AMOUNT,
        sum(tmp2.GP_AR_AMOUNT_DUE)              GP1_AR_AMOUNT_DUE,
        sum(tmp2.GP_AR_AMOUNT_OVERDUE)          GP1_AR_AMOUNT_OVERDUE,
        sum(tmp2.GG2_REVENUE)                   GG2_REVENUE,
        sum(tmp2.GG2_FUNDING)                   GG2_FUNDING,
        sum(tmp2.GG2_INITIAL_FUNDING_AMOUNT)    GG2_INITIAL_FUNDING_AMOUNT,
        sum(tmp2.GG2_ADDITIONAL_FUNDING_AMOUNT) GG2_ADDITIONAL_FUNDING_AMOUNT,
        sum(tmp2.GG2_CANCELLED_FUNDING_AMOUNT)  GG2_CANCELLED_FUNDING_AMOUNT,
        sum(tmp2.GG2_FUNDING_ADJUSTMENT_AMOUNT) GG2_FUNDING_ADJUSTMENT_AMOUNT,
        sum(tmp2.GG2_REVENUE_WRITEOFF)          GG2_REVENUE_WRITEOFF,
        sum(tmp2.GG2_AR_INVOICE_AMOUNT)         GG2_AR_INVOICE_AMOUNT,
        sum(tmp2.GG2_AR_CASH_APPLIED_AMOUNT)    GG2_AR_CASH_APPLIED_AMOUNT,
        sum(tmp2.GG2_AR_INVOICE_WRITEOFF_AMOUNT)GG2_AR_INVOICE_WRITEOFF_AMOUNT,
        sum(tmp2.GG2_AR_CREDIT_MEMO_AMOUNT)     GG2_AR_CREDIT_MEMO_AMOUNT,
        sum(tmp2.GG2_UNBILLED_RECEIVABLES)      GG2_UNBILLED_RECEIVABLES,
        sum(tmp2.GG2_UNEARNED_REVENUE)          GG2_UNEARNED_REVENUE,
        sum(tmp2.GG2_AR_UNAPPR_INVOICE_AMOUNT)  GG2_AR_UNAPPR_INVOICE_AMOUNT,
        sum(tmp2.GG2_AR_APPR_INVOICE_AMOUNT)    GG2_AR_APPR_INVOICE_AMOUNT,
        sum(tmp2.GG2_AR_AMOUNT_DUE)             GG2_AR_AMOUNT_DUE,
        sum(tmp2.GG2_AR_AMOUNT_OVERDUE)         GG2_AR_AMOUNT_OVERDUE,
        sum(tmp2.GP2_REVENUE)                   GP2_REVENUE,
        sum(tmp2.GP2_FUNDING)                   GP2_FUNDING,
        sum(tmp2.GP2_INITIAL_FUNDING_AMOUNT)    GP2_INITIAL_FUNDING_AMOUNT,
        sum(tmp2.GP2_ADDITIONAL_FUNDING_AMOUNT) GP2_ADDITIONAL_FUNDING_AMOUNT,
        sum(tmp2.GP2_CANCELLED_FUNDING_AMOUNT)  GP2_CANCELLED_FUNDING_AMOUNT,
        sum(tmp2.GP2_FUNDING_ADJUSTMENT_AMOUNT) GP2_FUNDING_ADJUSTMENT_AMOUNT,
        sum(tmp2.GP2_REVENUE_WRITEOFF)          GP2_REVENUE_WRITEOFF,
        sum(tmp2.GP2_AR_INVOICE_AMOUNT)         GP2_AR_INVOICE_AMOUNT,
        sum(tmp2.GP2_AR_CASH_APPLIED_AMOUNT)    GP2_AR_CASH_APPLIED_AMOUNT,
        sum(tmp2.GP2_AR_INVOICE_WRITEOFF_AMOUNT)GP2_AR_INVOICE_WRITEOFF_AMOUNT,
        sum(tmp2.GP2_AR_CREDIT_MEMO_AMOUNT)     GP2_AR_CREDIT_MEMO_AMOUNT,
        sum(tmp2.GP2_UNBILLED_RECEIVABLES)      GP2_UNBILLED_RECEIVABLES,
        sum(tmp2.GP2_UNEARNED_REVENUE)          GP2_UNEARNED_REVENUE,
        sum(tmp2.GP2_AR_UNAPPR_INVOICE_AMOUNT)  GP2_AR_UNAPPR_INVOICE_AMOUNT,
        sum(tmp2.GP2_AR_APPR_INVOICE_AMOUNT)    GP2_AR_APPR_INVOICE_AMOUNT,
        sum(tmp2.GP2_AR_AMOUNT_DUE)             GP2_AR_AMOUNT_DUE,
        sum(tmp2.GP2_AR_AMOUNT_OVERDUE)         GP2_AR_AMOUNT_OVERDUE
      from
        (
        select
          tmp2.WORKER_ID,
          tmp2.PROJECT_ID,
          tmp2.PROJECT_ORG_ID,
          tmp2.PROJECT_ORGANIZATION_ID,
          tmp2.TASK_ID,
          tmp2.GL_TIME_ID,
          tmp2.GL_PERIOD_NAME,
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
          tmp2.GG_REVENUE,
          tmp2.GG_FUNDING,
          tmp2.GG_INITIAL_FUNDING_AMOUNT,
          tmp2.GG_ADDITIONAL_FUNDING_AMOUNT,
          tmp2.GG_CANCELLED_FUNDING_AMOUNT,
          tmp2.GG_FUNDING_ADJUSTMENT_AMOUNT,
          tmp2.GG_REVENUE_WRITEOFF,
          tmp2.GG_AR_INVOICE_AMOUNT,
          tmp2.GG_AR_CASH_APPLIED_AMOUNT,
          tmp2.GG_AR_INVOICE_WRITEOFF_AMOUNT,
          tmp2.GG_AR_CREDIT_MEMO_AMOUNT,
          tmp2.GG_UNBILLED_RECEIVABLES,
          tmp2.GG_UNEARNED_REVENUE,
          tmp2.GG_AR_UNAPPR_INVOICE_AMOUNT,
          tmp2.GG_AR_APPR_INVOICE_AMOUNT,
          tmp2.GG_AR_AMOUNT_DUE,
          tmp2.GG_AR_AMOUNT_OVERDUE,
          tmp2.GP_REVENUE,
          tmp2.GP_FUNDING,
          tmp2.GP_INITIAL_FUNDING_AMOUNT,
          tmp2.GP_ADDITIONAL_FUNDING_AMOUNT,
          tmp2.GP_CANCELLED_FUNDING_AMOUNT,
          tmp2.GP_FUNDING_ADJUSTMENT_AMOUNT,
          tmp2.GP_REVENUE_WRITEOFF,
          tmp2.GP_AR_INVOICE_AMOUNT,
          tmp2.GP_AR_CASH_APPLIED_AMOUNT,
          tmp2.GP_AR_INVOICE_WRITEOFF_AMOUNT,
          tmp2.GP_AR_CREDIT_MEMO_AMOUNT,
          tmp2.GP_UNBILLED_RECEIVABLES,
          tmp2.GP_UNEARNED_REVENUE,
          tmp2.GP_AR_UNAPPR_INVOICE_AMOUNT,
          tmp2.GP_AR_APPR_INVOICE_AMOUNT,
          tmp2.GP_AR_AMOUNT_DUE,
          tmp2.GP_AR_AMOUNT_OVERDUE,
          tmp2.GG2_REVENUE,
          tmp2.GG2_FUNDING,
          tmp2.GG2_INITIAL_FUNDING_AMOUNT,
          tmp2.GG2_ADDITIONAL_FUNDING_AMOUNT,
          tmp2.GG2_CANCELLED_FUNDING_AMOUNT,
          tmp2.GG2_FUNDING_ADJUSTMENT_AMOUNT,
          tmp2.GG2_REVENUE_WRITEOFF,
          tmp2.GG2_AR_INVOICE_AMOUNT,
          tmp2.GG2_AR_CASH_APPLIED_AMOUNT,
          tmp2.GG2_AR_INVOICE_WRITEOFF_AMOUNT,
          tmp2.GG2_AR_CREDIT_MEMO_AMOUNT,
          tmp2.GG2_UNBILLED_RECEIVABLES,
          tmp2.GG2_UNEARNED_REVENUE,
          tmp2.GG2_AR_UNAPPR_INVOICE_AMOUNT,
          tmp2.GG2_AR_APPR_INVOICE_AMOUNT,
          tmp2.GG2_AR_AMOUNT_DUE,
          tmp2.GG2_AR_AMOUNT_OVERDUE,
          tmp2.GP2_REVENUE,
          tmp2.GP2_FUNDING,
          tmp2.GP2_INITIAL_FUNDING_AMOUNT,
          tmp2.GP2_ADDITIONAL_FUNDING_AMOUNT,
          tmp2.GP2_CANCELLED_FUNDING_AMOUNT,
          tmp2.GP2_FUNDING_ADJUSTMENT_AMOUNT,
          tmp2.GP2_REVENUE_WRITEOFF,
          tmp2.GP2_AR_INVOICE_AMOUNT,
          tmp2.GP2_AR_CASH_APPLIED_AMOUNT,
          tmp2.GP2_AR_INVOICE_WRITEOFF_AMOUNT,
          tmp2.GP2_AR_CREDIT_MEMO_AMOUNT,
          tmp2.GP2_UNBILLED_RECEIVABLES,
          tmp2.GP2_UNEARNED_REVENUE,
          tmp2.GP2_AR_UNAPPR_INVOICE_AMOUNT,
          tmp2.GP2_AR_APPR_INVOICE_AMOUNT,
          tmp2.GP2_AR_AMOUNT_DUE,
          tmp2.GP2_AR_AMOUNT_OVERDUE
        from
          PJI_FM_AGGR_ACT2 tmp2
        where
          tmp2.WORKER_ID = p_worker_id and
          tmp2.GL_PERIOD_NAME is not null and
          tmp2.PA_PERIOD_NAME is not null
        union all
        select
          tmp2.WORKER_ID,
          tmp2.PROJECT_ID,
          tmp2.PROJECT_ORG_ID,
          tmp2.PROJECT_ORGANIZATION_ID,
          tmp2.TASK_ID,
          tmp2.GL_TIME_ID,
          gl_per.PERIOD_NAME             GL_PERIOD_NAME,
          pa_per.PERIOD_NAME             PA_PERIOD_NAME,
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
          tmp2.GG_REVENUE,
          tmp2.GG_FUNDING,
          tmp2.GG_INITIAL_FUNDING_AMOUNT,
          tmp2.GG_ADDITIONAL_FUNDING_AMOUNT,
          tmp2.GG_CANCELLED_FUNDING_AMOUNT,
          tmp2.GG_FUNDING_ADJUSTMENT_AMOUNT,
          tmp2.GG_REVENUE_WRITEOFF,
          tmp2.GG_AR_INVOICE_AMOUNT,
          tmp2.GG_AR_CASH_APPLIED_AMOUNT,
          tmp2.GG_AR_INVOICE_WRITEOFF_AMOUNT,
          tmp2.GG_AR_CREDIT_MEMO_AMOUNT,
          tmp2.GG_UNBILLED_RECEIVABLES,
          tmp2.GG_UNEARNED_REVENUE,
          tmp2.GG_AR_UNAPPR_INVOICE_AMOUNT,
          tmp2.GG_AR_APPR_INVOICE_AMOUNT,
          tmp2.GG_AR_AMOUNT_DUE,
          tmp2.GG_AR_AMOUNT_OVERDUE,
          tmp2.GP_REVENUE,
          tmp2.GP_FUNDING,
          tmp2.GP_INITIAL_FUNDING_AMOUNT,
          tmp2.GP_ADDITIONAL_FUNDING_AMOUNT,
          tmp2.GP_CANCELLED_FUNDING_AMOUNT,
          tmp2.GP_FUNDING_ADJUSTMENT_AMOUNT,
          tmp2.GP_REVENUE_WRITEOFF,
          tmp2.GP_AR_INVOICE_AMOUNT,
          tmp2.GP_AR_CASH_APPLIED_AMOUNT,
          tmp2.GP_AR_INVOICE_WRITEOFF_AMOUNT,
          tmp2.GP_AR_CREDIT_MEMO_AMOUNT,
          tmp2.GP_UNBILLED_RECEIVABLES,
          tmp2.GP_UNEARNED_REVENUE,
          tmp2.GP_AR_UNAPPR_INVOICE_AMOUNT,
          tmp2.GP_AR_APPR_INVOICE_AMOUNT,
          tmp2.GP_AR_AMOUNT_DUE,
          tmp2.GP_AR_AMOUNT_OVERDUE,
          tmp2.GG2_REVENUE,
          tmp2.GG2_FUNDING,
          tmp2.GG2_INITIAL_FUNDING_AMOUNT,
          tmp2.GG2_ADDITIONAL_FUNDING_AMOUNT,
          tmp2.GG2_CANCELLED_FUNDING_AMOUNT,
          tmp2.GG2_FUNDING_ADJUSTMENT_AMOUNT,
          tmp2.GG2_REVENUE_WRITEOFF,
          tmp2.GG2_AR_INVOICE_AMOUNT,
          tmp2.GG2_AR_CASH_APPLIED_AMOUNT,
          tmp2.GG2_AR_INVOICE_WRITEOFF_AMOUNT,
          tmp2.GG2_AR_CREDIT_MEMO_AMOUNT,
          tmp2.GG2_UNBILLED_RECEIVABLES,
          tmp2.GG2_UNEARNED_REVENUE,
          tmp2.GG2_AR_UNAPPR_INVOICE_AMOUNT,
          tmp2.GG2_AR_APPR_INVOICE_AMOUNT,
          tmp2.GG2_AR_AMOUNT_DUE,
          tmp2.GG2_AR_AMOUNT_OVERDUE,
          tmp2.GP2_REVENUE,
          tmp2.GP2_FUNDING,
          tmp2.GP2_INITIAL_FUNDING_AMOUNT,
          tmp2.GP2_ADDITIONAL_FUNDING_AMOUNT,
          tmp2.GP2_CANCELLED_FUNDING_AMOUNT,
          tmp2.GP2_FUNDING_ADJUSTMENT_AMOUNT,
          tmp2.GP2_REVENUE_WRITEOFF,
          tmp2.GP2_AR_INVOICE_AMOUNT,
          tmp2.GP2_AR_CASH_APPLIED_AMOUNT,
          tmp2.GP2_AR_INVOICE_WRITEOFF_AMOUNT,
          tmp2.GP2_AR_CREDIT_MEMO_AMOUNT,
          tmp2.GP2_UNBILLED_RECEIVABLES,
          tmp2.GP2_UNEARNED_REVENUE,
          tmp2.GP2_AR_UNAPPR_INVOICE_AMOUNT,
          tmp2.GP2_AR_APPR_INVOICE_AMOUNT,
          tmp2.GP2_AR_AMOUNT_DUE,
          tmp2.GP2_AR_AMOUNT_OVERDUE
        from
          PJI_FM_AGGR_ACT2  tmp2,
          FII_TIME_CAL_NAME gl_cal,
          GL_PERIODS        gl_per,
          PA_PERIODS_ALL    pa_per
        where
          tmp2.WORKER_ID          = p_worker_id                            and
          (tmp2.GL_PERIOD_NAME is null or
           tmp2.PA_PERIOD_NAME is null)                                    and
          gl_cal.CALENDAR_ID      = tmp2.GL_CALENDAR_ID                    and
          gl_per.PERIOD_SET_NAME  = gl_cal.PERIOD_SET_NAME                 and
          gl_per.PERIOD_TYPE      = gl_cal.PERIOD_TYPE                     and
          to_date(to_char(tmp2.GL_TIME_ID), 'J') between gl_per.START_DATE
                                                     and gl_per.END_DATE   and
          pa_per.ORG_ID           = tmp2.PROJECT_ORG_ID                    and
          to_date(to_char(tmp2.PA_TIME_ID), 'J') between pa_per.START_DATE
                                                     and pa_per.END_DATE
        ) tmp2,
        PJI_TIME_ENT_PERIOD_V ent
      where
        tmp2.WORKER_ID = p_worker_id and
        to_date(to_char(tmp2.GL_TIME_ID), 'J') between ent.START_DATE and
                                                       ent.END_DATE
      group by
        tmp2.WORKER_ID,
        tmp2.PROJECT_ID,
        tmp2.PROJECT_ORG_ID,
        tmp2.PROJECT_ORGANIZATION_ID,
        tmp2.TASK_ID,
        ent.ENT_PERIOD_ID,
        tmp2.GL_PERIOD_NAME,
        tmp2.PA_PERIOD_NAME,
        tmp2.GL_CALENDAR_ID,
        tmp2.PA_CALENDAR_ID,
        tmp2.TXN_CURRENCY_CODE
      ) tmp2,
      PJI_TIME_CAL_PERIOD_V gl_cal,
      PJI_TIME_CAL_PERIOD_V pa_cal,
      (
        select 'ENT' INVERT_ID from dual union all
        select 'GL'  INVERT_ID from dual union all
        select 'PA'  INVERT_ID from dual
      ) invert
    where
      tmp2.GL_CALENDAR_ID = gl_cal.CALENDAR_ID and
      tmp2.GL_PERIOD_NAME = gl_cal.NAME        and
      tmp2.PA_CALENDAR_ID = pa_cal.CALENDAR_ID and
      tmp2.PA_PERIOD_NAME = pa_cal.NAME
    group by
      tmp2.PROJECT_ID,
      tmp2.PROJECT_ORG_ID,
      tmp2.PROJECT_ORGANIZATION_ID,
      tmp2.TASK_ID,
      decode(invert.INVERT_ID,
             'ENT', 'ENT',
             'GL',  'GL',
             'PA',  'PA'),
      decode(invert.INVERT_ID,
             'ENT', tmp2.ENT_PERIOD_ID,
             'GL',  gl_cal.CAL_PERIOD_ID,
             'PA',  pa_cal.CAL_PERIOD_ID),
      tmp2.TXN_CURRENCY_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.AGGREGATE_ACR_PERIODS(p_worker_id);');

    commit;

  end AGGREGATE_ACR_PERIODS;


  -- -----------------------------------------------------
  -- procedure INSERT_NEW_HEADERS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure INSERT_NEW_HEADERS (p_worker_id in number) is

    l_process           varchar2(30);
    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;
    l_extraction_type   varchar2(15);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.INSERT_NEW_HEADERS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    insert /*+ append parallel(hdr_i) */ into PJI_FP_TXN_ACCUM_HEADER hdr_i
    (
      TXN_ACCUM_HEADER_ID,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      RESOURCE_CLASS_ID,
      JOB_ID,
      VENDOR_ID,
      WORK_TYPE_ID,
      EXPENDITURE_CATEGORY_ID,
      EXPENDITURE_TYPE_ID,
      EVENT_TYPE_ID,
      EXP_EVT_TYPE_ID,
      EXPENDITURE_TYPE,
      EVENT_TYPE,
      EVENT_TYPE_CLASSIFICATION,
      EXPENDITURE_CATEGORY,
      REVENUE_CATEGORY,
      NON_LABOR_RESOURCE_ID,
      BOM_LABOR_RESOURCE_ID,
      BOM_EQUIPMENT_RESOURCE_ID,
      ITEM_CATEGORY_ID,
      INVENTORY_ITEM_ID,
      PROJECT_ROLE_ID,
      PERSON_TYPE,
      SYSTEM_LINKAGE_FUNCTION,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN
    )
    select
      PJI_FP_TXN_ACCUM_HEADER_S.NEXTVAL TXN_ACCUM_HEADER_ID,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      RESOURCE_CLASS_ID,
      JOB_ID,
      VENDOR_ID,
      WORK_TYPE_ID,
      EXPENDITURE_CATEGORY_ID,
      EXPENDITURE_TYPE_ID,
      EVENT_TYPE_ID,
      EXP_EVT_TYPE_ID,
      EXPENDITURE_TYPE,
      EVENT_TYPE,
      EVENT_TYPE_CLASSIFICATION,
      EXPENDITURE_CATEGORY,
      REVENUE_CATEGORY,
      NON_LABOR_RESOURCE_ID,
      BOM_LABOR_RESOURCE_ID,
      BOM_EQUIPMENT_RESOURCE_ID,
      ITEM_CATEGORY_ID,
      INVENTORY_ITEM_ID,
      PROJECT_ROLE_ID,
      PERSON_TYPE,
      SYSTEM_LINKAGE_FUNCTION,
      l_last_update_date,
      l_last_updated_by,
      l_creation_date,
      l_created_by,
      l_last_update_login
    from
      (
      select /*+ full(tmp6) parallel(tmp6) */
        distinct
        PERSON_ID,
        EXPENDITURE_ORG_ID,
        EXPENDITURE_ORGANIZATION_ID,
        RESOURCE_CLASS_ID,
        JOB_ID,
        VENDOR_ID,
        WORK_TYPE_ID,
        EXPENDITURE_CATEGORY_ID,
        EXPENDITURE_TYPE_ID,
        EVENT_TYPE_ID,
        EXP_EVT_TYPE_ID,
        EXPENDITURE_TYPE,
        EVENT_TYPE,
        EVENT_TYPE_CLASSIFICATION,
        EXPENDITURE_CATEGORY,
        REVENUE_CATEGORY,
        NON_LABOR_RESOURCE_ID,
        BOM_LABOR_RESOURCE_ID,
        BOM_EQUIPMENT_RESOURCE_ID,
        ITEM_CATEGORY_ID,
        INVENTORY_ITEM_ID,
        PROJECT_ROLE_ID,
        PERSON_TYPE,
        SYSTEM_LINKAGE_FUNCTION
      from
        PJI_FM_AGGR_FIN6 tmp6
      where
        WORKER_ID = p_worker_id
      ) tmp6
    where
      not exists
      (select
         1
       from
         PJI_FP_TXN_ACCUM_HEADER hdr
       where
         tmp6.PERSON_ID                   = hdr.PERSON_ID                   and
         tmp6.EXPENDITURE_ORG_ID          = hdr.EXPENDITURE_ORG_ID          and
         tmp6.EXPENDITURE_ORGANIZATION_ID = hdr.EXPENDITURE_ORGANIZATION_ID and
         tmp6.RESOURCE_CLASS_ID           = hdr.RESOURCE_CLASS_ID           and
         tmp6.JOB_ID                      = hdr.JOB_ID                      and
         tmp6.VENDOR_ID                   = hdr.VENDOR_ID                   and
         tmp6.WORK_TYPE_ID                = hdr.WORK_TYPE_ID                and
         tmp6.EXPENDITURE_CATEGORY_ID     = hdr.EXPENDITURE_CATEGORY_ID     and
         tmp6.EXPENDITURE_TYPE_ID         = hdr.EXPENDITURE_TYPE_ID         and
         tmp6.EVENT_TYPE_ID               = hdr.EVENT_TYPE_ID               and
         tmp6.EXP_EVT_TYPE_ID             = hdr.EXP_EVT_TYPE_ID             and
         tmp6.EXPENDITURE_TYPE            = hdr.EXPENDITURE_TYPE            and
         tmp6.EVENT_TYPE                  = hdr.EVENT_TYPE                  and
         tmp6.EVENT_TYPE_CLASSIFICATION   = hdr.EVENT_TYPE_CLASSIFICATION   and
         tmp6.EXPENDITURE_CATEGORY        = hdr.EXPENDITURE_CATEGORY        and
         tmp6.REVENUE_CATEGORY            = hdr.REVENUE_CATEGORY            and
         tmp6.NON_LABOR_RESOURCE_ID       = hdr.NON_LABOR_RESOURCE_ID       and
         tmp6.BOM_LABOR_RESOURCE_ID       = hdr.BOM_LABOR_RESOURCE_ID       and
         tmp6.BOM_EQUIPMENT_RESOURCE_ID   = hdr.BOM_EQUIPMENT_RESOURCE_ID   and
         tmp6.ITEM_CATEGORY_ID            = hdr.ITEM_CATEGORY_ID            and
         tmp6.INVENTORY_ITEM_ID           = hdr.INVENTORY_ITEM_ID           and
         tmp6.PROJECT_ROLE_ID             = hdr.PROJECT_ROLE_ID             and
         tmp6.PERSON_TYPE                 = hdr.PERSON_TYPE                 and
         tmp6.SYSTEM_LINKAGE_FUNCTION     = hdr.SYSTEM_LINKAGE_FUNCTION);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.INSERT_NEW_HEADERS(p_worker_id);');

    commit;

  end INSERT_NEW_HEADERS;


  -- -----------------------------------------------------
  -- procedure BALANCES_INSERT
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure BALANCES_INSERT (p_worker_id in number) is

    l_process           varchar2(30);
    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;
    l_extraction_type   varchar2(15);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.BALANCES_INSERT(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (l_extraction_type = 'FULL' or
        l_extraction_type = 'PARTIAL') then

      insert /*+ append parallel(bal) */ into PJI_FP_TXN_ACCUM bal
      (
        TXN_ACCUM_HEADER_ID,
        RESOURCE_CLASS_ID,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_TYPE_CLASS,
        TASK_ID,
        ASSIGNMENT_ID,
        NAMED_ROLE,
        RECVR_PERIOD_TYPE,
        RECVR_PERIOD_ID,
        TXN_CURRENCY_CODE,
        TXN_RAW_COST,
        TXN_BILL_RAW_COST,
        TXN_BRDN_COST,
        TXN_BILL_BRDN_COST,
        TXN_REVENUE,
        PRJ_RAW_COST,
        PRJ_BILL_RAW_COST,
        PRJ_BRDN_COST,
        PRJ_BILL_BRDN_COST,
        PRJ_REVENUE,
        POU_RAW_COST,
        POU_BILL_RAW_COST,
        POU_BRDN_COST,
        POU_BILL_BRDN_COST,
        POU_REVENUE,
        EOU_RAW_COST,
        EOU_BILL_RAW_COST,
        EOU_BRDN_COST,
        EOU_BILL_BRDN_COST,
        G1_RAW_COST,
        G1_BILL_RAW_COST,
        G1_BRDN_COST,
        G1_BILL_BRDN_COST,
        G1_REVENUE,
        G2_RAW_COST,
        G2_BILL_RAW_COST,
        G2_BRDN_COST,
        G2_BILL_BRDN_COST,
        G2_REVENUE,
        QUANTITY,
        BILL_QUANTITY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ ordered
                 full(tmp6) parallel(tmp6) use_hash(tmp6)
                 full(hdr)  parallel(hdr)
                 pq_distribute(tmp2, hash, hash) */
        hdr.TXN_ACCUM_HEADER_ID,
        hdr.RESOURCE_CLASS_ID,
        tmp6.PROJECT_ID,
        tmp6.PROJECT_ORG_ID,
        tmp6.PROJECT_ORGANIZATION_ID,
        tmp6.PROJECT_TYPE_CLASS,
        tmp6.TASK_ID,
        tmp6.ASSIGNMENT_ID,
        tmp6.NAMED_ROLE,
        tmp6.RECVR_PERIOD_TYPE,
        tmp6.RECVR_PERIOD_ID,
        tmp6.TXN_CURRENCY_CODE,
        sum(tmp6.TXN_RAW_COST)           TXN_RAW_COST,
        sum(tmp6.TXN_BILL_RAW_COST)      TXN_BILL_RAW_COST,
        sum(tmp6.TXN_BRDN_COST)          TXN_BRDN_COST,
        sum(tmp6.TXN_BILL_BRDN_COST)     TXN_BILL_BRDN_COST,
        sum(tmp6.TXN_REVENUE)            TXN_REVENUE,
        sum(tmp6.PRJ_RAW_COST)           PRJ_RAW_COST,
        sum(tmp6.PRJ_BILL_RAW_COST)      PRJ_BILL_RAW_COST,
        sum(tmp6.PRJ_BRDN_COST)          PRJ_BRDN_COST,
        sum(tmp6.PRJ_BILL_BRDN_COST)     PRJ_BILL_BRDN_COST,
        sum(tmp6.PRJ_REVENUE)            PRJ_REVENUE,
        sum(tmp6.POU_RAW_COST)           POU_RAW_COST,
        sum(tmp6.POU_BILL_RAW_COST)      POU_BILL_RAW_COST,
        sum(tmp6.POU_BRDN_COST)          POU_BRDN_COST,
        sum(tmp6.POU_BILL_BRDN_COST)     POU_BILL_BRDN_COST,
        sum(tmp6.POU_REVENUE)            POU_REVENUE,
        sum(tmp6.EOU_RAW_COST)           EOU_RAW_COST,
        sum(tmp6.EOU_BILL_RAW_COST)      EOU_BILL_RAW_COST,
        sum(tmp6.EOU_BRDN_COST)          EOU_BRDN_COST,
        sum(tmp6.EOU_BILL_BRDN_COST)     EOU_BILL_BRDN_COST,
        sum(tmp6.G1_RAW_COST)            G1_RAW_COST,
        sum(tmp6.G1_BILL_RAW_COST)       G1_BILL_RAW_COST,
        sum(tmp6.G1_BRDN_COST)           G1_BRDN_COST,
        sum(tmp6.G1_BILL_BRDN_COST)      G1_BILL_BRDN_COST,
        sum(tmp6.G1_REVENUE)             G1_REVENUE,
        sum(tmp6.G2_RAW_COST)            G2_RAW_COST,
        sum(tmp6.G2_BILL_RAW_COST)       G2_BILL_RAW_COST,
        sum(tmp6.G2_BRDN_COST)           G2_BRDN_COST,
        sum(tmp6.G2_BILL_BRDN_COST)      G2_BILL_BRDN_COST,
        sum(tmp6.G2_REVENUE)             G2_REVENUE,
        sum(tmp6.QUANTITY)               QUANTITY,
        sum(tmp6.BILL_QUANTITY)          BILL_QUANTITY,
        l_last_update_date               LAST_UPDATE_DATE,
        l_last_updated_by                LAST_UPDATED_BY,
        l_creation_date                  CREATION_DATE,
        l_created_by                     CREATED_BY,
        l_last_update_login              LAST_UPDATE_LOGIN
      from
        PJI_FM_AGGR_FIN6        tmp6,
        PJI_FP_TXN_ACCUM_HEADER hdr
      where
        tmp6.WORKER_ID                   = p_worker_id                     and
        tmp6.RECORD_TYPE                 = 'A'                             and
        tmp6.PERSON_ID                   = hdr.PERSON_ID                   and
        tmp6.EXPENDITURE_ORG_ID          = hdr.EXPENDITURE_ORG_ID          and
        tmp6.EXPENDITURE_ORGANIZATION_ID = hdr.EXPENDITURE_ORGANIZATION_ID and
        tmp6.RESOURCE_CLASS_ID           = hdr.RESOURCE_CLASS_ID           and
        tmp6.JOB_ID                      = hdr.JOB_ID                      and
        tmp6.VENDOR_ID                   = hdr.VENDOR_ID                   and
        tmp6.WORK_TYPE_ID                = hdr.WORK_TYPE_ID                and
        tmp6.EXPENDITURE_CATEGORY_ID     = hdr.EXPENDITURE_CATEGORY_ID     and
        tmp6.EXPENDITURE_TYPE_ID         = hdr.EXPENDITURE_TYPE_ID         and
        tmp6.EVENT_TYPE_ID               = hdr.EVENT_TYPE_ID               and
        tmp6.EXP_EVT_TYPE_ID             = hdr.EXP_EVT_TYPE_ID             and
        tmp6.EXPENDITURE_TYPE            = hdr.EXPENDITURE_TYPE            and
        tmp6.EVENT_TYPE                  = hdr.EVENT_TYPE                  and
        tmp6.EVENT_TYPE_CLASSIFICATION   = hdr.EVENT_TYPE_CLASSIFICATION   and
        tmp6.EXPENDITURE_CATEGORY        = hdr.EXPENDITURE_CATEGORY        and
        tmp6.REVENUE_CATEGORY            = hdr.REVENUE_CATEGORY            and
        tmp6.NON_LABOR_RESOURCE_ID       = hdr.NON_LABOR_RESOURCE_ID       and
        tmp6.BOM_LABOR_RESOURCE_ID       = hdr.BOM_LABOR_RESOURCE_ID       and
        tmp6.BOM_EQUIPMENT_RESOURCE_ID   = hdr.BOM_EQUIPMENT_RESOURCE_ID   and
        tmp6.ITEM_CATEGORY_ID            = hdr.ITEM_CATEGORY_ID            and
        tmp6.INVENTORY_ITEM_ID           = hdr.INVENTORY_ITEM_ID           and
        tmp6.PROJECT_ROLE_ID             = hdr.PROJECT_ROLE_ID             and
        tmp6.PERSON_TYPE                 = hdr.PERSON_TYPE                 and
        tmp6.SYSTEM_LINKAGE_FUNCTION     = hdr.SYSTEM_LINKAGE_FUNCTION
      group by
        hdr.TXN_ACCUM_HEADER_ID,
        hdr.RESOURCE_CLASS_ID,
        tmp6.PROJECT_ID,
        tmp6.PROJECT_ORG_ID,
        tmp6.PROJECT_ORGANIZATION_ID,
        tmp6.PROJECT_TYPE_CLASS,
        tmp6.TASK_ID,
        tmp6.ASSIGNMENT_ID,
        tmp6.NAMED_ROLE,
        tmp6.RECVR_PERIOD_TYPE,
        tmp6.RECVR_PERIOD_ID,
        tmp6.TXN_CURRENCY_CODE;

    elsif (l_extraction_type = 'INCREMENTAL') then

      -- insert both commitments and actuals into delta table

      insert /*+ append parallel(tmp7) */ into PJI_FM_AGGR_FIN7 tmp7
      (
        WORKER_ID,
        TXN_ACCUM_HEADER_ID,
        RECORD_TYPE,
        RESOURCE_CLASS_ID,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_TYPE_CLASS,
        TASK_ID,
        ASSIGNMENT_ID,
        NAMED_ROLE,
        RECVR_PERIOD_TYPE,
        RECVR_PERIOD_ID,
        TXN_CURRENCY_CODE,
        TXN_REVENUE,
        TXN_RAW_COST,
        TXN_BRDN_COST,
        TXN_BILL_RAW_COST,
        TXN_BILL_BRDN_COST,
        TXN_SUP_INV_COMMITTED_COST,
        TXN_PO_COMMITTED_COST,
        TXN_PR_COMMITTED_COST,
        TXN_OTH_COMMITTED_COST,
        PRJ_REVENUE,
        PRJ_RAW_COST,
        PRJ_BRDN_COST,
        PRJ_BILL_RAW_COST,
        PRJ_BILL_BRDN_COST,
        PRJ_REVENUE_WRITEOFF,
        PRJ_SUP_INV_COMMITTED_COST,
        PRJ_PO_COMMITTED_COST,
        PRJ_PR_COMMITTED_COST,
        PRJ_OTH_COMMITTED_COST,
        POU_REVENUE,
        POU_RAW_COST,
        POU_BRDN_COST,
        POU_BILL_RAW_COST,
        POU_BILL_BRDN_COST,
        POU_REVENUE_WRITEOFF,
        POU_SUP_INV_COMMITTED_COST,
        POU_PO_COMMITTED_COST,
        POU_PR_COMMITTED_COST,
        POU_OTH_COMMITTED_COST,
        EOU_REVENUE,
        EOU_RAW_COST,
        EOU_BRDN_COST,
        EOU_BILL_RAW_COST,
        EOU_BILL_BRDN_COST,
        EOU_SUP_INV_COMMITTED_COST,
        EOU_PO_COMMITTED_COST,
        EOU_PR_COMMITTED_COST,
        EOU_OTH_COMMITTED_COST,
        QUANTITY,
        BILL_QUANTITY,
        G1_REVENUE,
        G1_RAW_COST,
        G1_BRDN_COST,
        G1_BILL_RAW_COST,
        G1_BILL_BRDN_COST,
        G1_REVENUE_WRITEOFF,
        G1_SUP_INV_COMMITTED_COST,
        G1_PO_COMMITTED_COST,
        G1_PR_COMMITTED_COST,
        G1_OTH_COMMITTED_COST,
        G2_REVENUE,
        G2_RAW_COST,
        G2_BRDN_COST,
        G2_BILL_RAW_COST,
        G2_BILL_BRDN_COST,
        G2_REVENUE_WRITEOFF,
        G2_SUP_INV_COMMITTED_COST,
        G2_PO_COMMITTED_COST,
        G2_PR_COMMITTED_COST,
        G2_OTH_COMMITTED_COST
      )
      select /*+ ordered
                 full(tmp6) parallel(tmp6) use_hash(tmp6)
                 full(hdr)  parallel(hdr)
                 pq_distribute(tmp2, hash, hash) */
        tmp6.WORKER_ID,
        hdr.TXN_ACCUM_HEADER_ID,
        tmp6.RECORD_TYPE,
        hdr.RESOURCE_CLASS_ID,
        tmp6.PROJECT_ID,
        tmp6.PROJECT_ORG_ID,
        tmp6.PROJECT_ORGANIZATION_ID,
        tmp6.PROJECT_TYPE_CLASS,
        tmp6.TASK_ID,
        tmp6.ASSIGNMENT_ID,
        tmp6.NAMED_ROLE,
        tmp6.RECVR_PERIOD_TYPE,
        tmp6.RECVR_PERIOD_ID,
        tmp6.TXN_CURRENCY_CODE,
        tmp6.TXN_REVENUE,
        tmp6.TXN_RAW_COST,
        tmp6.TXN_BRDN_COST,
        tmp6.TXN_BILL_RAW_COST,
        tmp6.TXN_BILL_BRDN_COST,
        tmp6.TXN_SUP_INV_COMMITTED_COST,
        tmp6.TXN_PO_COMMITTED_COST,
        tmp6.TXN_PR_COMMITTED_COST,
        tmp6.TXN_OTH_COMMITTED_COST,
        tmp6.PRJ_REVENUE,
        tmp6.PRJ_RAW_COST,
        tmp6.PRJ_BRDN_COST,
        tmp6.PRJ_BILL_RAW_COST,
        tmp6.PRJ_BILL_BRDN_COST,
        tmp6.PRJ_REVENUE_WRITEOFF,
        tmp6.PRJ_SUP_INV_COMMITTED_COST,
        tmp6.PRJ_PO_COMMITTED_COST,
        tmp6.PRJ_PR_COMMITTED_COST,
        tmp6.PRJ_OTH_COMMITTED_COST,
        tmp6.POU_REVENUE,
        tmp6.POU_RAW_COST,
        tmp6.POU_BRDN_COST,
        tmp6.POU_BILL_RAW_COST,
        tmp6.POU_BILL_BRDN_COST,
        tmp6.POU_REVENUE_WRITEOFF,
        tmp6.POU_SUP_INV_COMMITTED_COST,
        tmp6.POU_PO_COMMITTED_COST,
        tmp6.POU_PR_COMMITTED_COST,
        tmp6.POU_OTH_COMMITTED_COST,
        tmp6.EOU_REVENUE,
        tmp6.EOU_RAW_COST,
        tmp6.EOU_BRDN_COST,
        tmp6.EOU_BILL_RAW_COST,
        tmp6.EOU_BILL_BRDN_COST,
        tmp6.EOU_SUP_INV_COMMITTED_COST,
        tmp6.EOU_PO_COMMITTED_COST,
        tmp6.EOU_PR_COMMITTED_COST,
        tmp6.EOU_OTH_COMMITTED_COST,
        tmp6.QUANTITY,
        tmp6.BILL_QUANTITY,
        tmp6.G1_REVENUE,
        tmp6.G1_RAW_COST,
        tmp6.G1_BRDN_COST,
        tmp6.G1_BILL_RAW_COST,
        tmp6.G1_BILL_BRDN_COST,
        tmp6.G1_REVENUE_WRITEOFF,
        tmp6.G1_SUP_INV_COMMITTED_COST,
        tmp6.G1_PO_COMMITTED_COST,
        tmp6.G1_PR_COMMITTED_COST,
        tmp6.G1_OTH_COMMITTED_COST,
        tmp6.G2_REVENUE,
        tmp6.G2_RAW_COST,
        tmp6.G2_BRDN_COST,
        tmp6.G2_BILL_RAW_COST,
        tmp6.G2_BILL_BRDN_COST,
        tmp6.G2_REVENUE_WRITEOFF,
        tmp6.G2_SUP_INV_COMMITTED_COST,
        tmp6.G2_PO_COMMITTED_COST,
        tmp6.G2_PR_COMMITTED_COST,
        tmp6.G2_OTH_COMMITTED_COST
      from
        PJI_FM_AGGR_FIN6        tmp6,
        PJI_FP_TXN_ACCUM_HEADER hdr
      where
        tmp6.WORKER_ID                   = p_worker_id                     and
        tmp6.PERSON_ID                   = hdr.PERSON_ID                   and
        tmp6.EXPENDITURE_ORG_ID          = hdr.EXPENDITURE_ORG_ID          and
        tmp6.EXPENDITURE_ORGANIZATION_ID = hdr.EXPENDITURE_ORGANIZATION_ID and
        tmp6.RESOURCE_CLASS_ID           = hdr.RESOURCE_CLASS_ID           and
        tmp6.JOB_ID                      = hdr.JOB_ID                      and
        tmp6.VENDOR_ID                   = hdr.VENDOR_ID                   and
        tmp6.WORK_TYPE_ID                = hdr.WORK_TYPE_ID                and
        tmp6.EXPENDITURE_CATEGORY_ID     = hdr.EXPENDITURE_CATEGORY_ID     and
        tmp6.EXPENDITURE_TYPE_ID         = hdr.EXPENDITURE_TYPE_ID         and
        tmp6.EVENT_TYPE_ID               = hdr.EVENT_TYPE_ID               and
        tmp6.EXP_EVT_TYPE_ID             = hdr.EXP_EVT_TYPE_ID             and
        tmp6.EXPENDITURE_TYPE            = hdr.EXPENDITURE_TYPE            and
        tmp6.EVENT_TYPE                  = hdr.EVENT_TYPE                  and
        tmp6.EVENT_TYPE_CLASSIFICATION   = hdr.EVENT_TYPE_CLASSIFICATION   and
        tmp6.EXPENDITURE_CATEGORY        = hdr.EXPENDITURE_CATEGORY        and
        tmp6.REVENUE_CATEGORY            = hdr.REVENUE_CATEGORY            and
        tmp6.NON_LABOR_RESOURCE_ID       = hdr.NON_LABOR_RESOURCE_ID       and
        tmp6.BOM_LABOR_RESOURCE_ID       = hdr.BOM_LABOR_RESOURCE_ID       and
        tmp6.BOM_EQUIPMENT_RESOURCE_ID   = hdr.BOM_EQUIPMENT_RESOURCE_ID   and
        tmp6.ITEM_CATEGORY_ID            = hdr.ITEM_CATEGORY_ID            and
        tmp6.INVENTORY_ITEM_ID           = hdr.INVENTORY_ITEM_ID           and
        tmp6.PROJECT_ROLE_ID             = hdr.PROJECT_ROLE_ID             and
        tmp6.PERSON_TYPE                 = hdr.PERSON_TYPE                 and
        tmp6.SYSTEM_LINKAGE_FUNCTION     = hdr.SYSTEM_LINKAGE_FUNCTION     and
        tmp6.PROJECT_ID in (select pjp.PROJECT_ID
                            from   PJI_PJP_PROJ_EXTR_STATUS pjp);

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.BALANCES_INSERT(p_worker_id);');

    commit;

  end BALANCES_INSERT;


  -- -----------------------------------------------------
  -- procedure BALANCES_INCR_NEW_PRJ
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure BALANCES_INCR_NEW_PRJ (p_worker_id in number) is

    l_process           varchar2(30);
    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;
    l_extraction_type   varchar2(15);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.BALANCES_INCR_NEW_PRJ(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (l_extraction_type = 'INCREMENTAL') then

      insert /*+ append parallel(bal) */ into PJI_FP_TXN_ACCUM bal
      (
        TXN_ACCUM_HEADER_ID,
        RESOURCE_CLASS_ID,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_TYPE_CLASS,
        TASK_ID,
        ASSIGNMENT_ID,
        NAMED_ROLE,
        RECVR_PERIOD_TYPE,
        RECVR_PERIOD_ID,
        TXN_CURRENCY_CODE,
        TXN_RAW_COST,
        TXN_BILL_RAW_COST,
        TXN_BRDN_COST,
        TXN_BILL_BRDN_COST,
        TXN_REVENUE,
        PRJ_RAW_COST,
        PRJ_BILL_RAW_COST,
        PRJ_BRDN_COST,
        PRJ_BILL_BRDN_COST,
        PRJ_REVENUE,
        POU_RAW_COST,
        POU_BILL_RAW_COST,
        POU_BRDN_COST,
        POU_BILL_BRDN_COST,
        POU_REVENUE,
        EOU_RAW_COST,
        EOU_BILL_RAW_COST,
        EOU_BRDN_COST,
        EOU_BILL_BRDN_COST,
        G1_RAW_COST,
        G1_BILL_RAW_COST,
        G1_BRDN_COST,
        G1_BILL_BRDN_COST,
        G1_REVENUE,
        G2_RAW_COST,
        G2_BILL_RAW_COST,
        G2_BRDN_COST,
        G2_BILL_BRDN_COST,
        G2_REVENUE,
        QUANTITY,
        BILL_QUANTITY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ ordered
                 full(tmp6) parallel(tmp6) use_hash(tmp6)
                 full(hdr)  parallel(hdr)
                 pq_distribute(tmp2, hash, hash) */
        hdr.TXN_ACCUM_HEADER_ID,
        hdr.RESOURCE_CLASS_ID,
        tmp6.PROJECT_ID,
        tmp6.PROJECT_ORG_ID,
        tmp6.PROJECT_ORGANIZATION_ID,
        tmp6.PROJECT_TYPE_CLASS,
        tmp6.TASK_ID,
        tmp6.ASSIGNMENT_ID,
        tmp6.NAMED_ROLE,
        tmp6.RECVR_PERIOD_TYPE,
        tmp6.RECVR_PERIOD_ID,
        tmp6.TXN_CURRENCY_CODE,
        sum(tmp6.TXN_RAW_COST)           TXN_RAW_COST,
        sum(tmp6.TXN_BILL_RAW_COST)      TXN_BILL_RAW_COST,
        sum(tmp6.TXN_BRDN_COST)          TXN_BRDN_COST,
        sum(tmp6.TXN_BILL_BRDN_COST)     TXN_BILL_BRDN_COST,
        sum(tmp6.TXN_REVENUE)            TXN_REVENUE,
        sum(tmp6.PRJ_RAW_COST)           PRJ_RAW_COST,
        sum(tmp6.PRJ_BILL_RAW_COST)      PRJ_BILL_RAW_COST,
        sum(tmp6.PRJ_BRDN_COST)          PRJ_BRDN_COST,
        sum(tmp6.PRJ_BILL_BRDN_COST)     PRJ_BILL_BRDN_COST,
        sum(tmp6.PRJ_REVENUE)            PRJ_REVENUE,
        sum(tmp6.POU_RAW_COST)           POU_RAW_COST,
        sum(tmp6.POU_BILL_RAW_COST)      POU_BILL_RAW_COST,
        sum(tmp6.POU_BRDN_COST)          POU_BRDN_COST,
        sum(tmp6.POU_BILL_BRDN_COST)     POU_BILL_BRDN_COST,
        sum(tmp6.POU_REVENUE)            POU_REVENUE,
        sum(tmp6.EOU_RAW_COST)           EOU_RAW_COST,
        sum(tmp6.EOU_BILL_RAW_COST)      EOU_BILL_RAW_COST,
        sum(tmp6.EOU_BRDN_COST)          EOU_BRDN_COST,
        sum(tmp6.EOU_BILL_BRDN_COST)     EOU_BILL_BRDN_COST,
        sum(tmp6.G1_RAW_COST)            G1_RAW_COST,
        sum(tmp6.G1_BILL_RAW_COST)       G1_BILL_RAW_COST,
        sum(tmp6.G1_BRDN_COST)           G1_BRDN_COST,
        sum(tmp6.G1_BILL_BRDN_COST)      G1_BILL_BRDN_COST,
        sum(tmp6.G1_REVENUE)             G1_REVENUE,
        sum(tmp6.G2_RAW_COST)            G2_RAW_COST,
        sum(tmp6.G2_BILL_RAW_COST)       G2_BILL_RAW_COST,
        sum(tmp6.G2_BRDN_COST)           G2_BRDN_COST,
        sum(tmp6.G2_BILL_BRDN_COST)      G2_BILL_BRDN_COST,
        sum(tmp6.G2_REVENUE)             G2_REVENUE,
        sum(tmp6.QUANTITY)               QUANTITY,
        sum(tmp6.BILL_QUANTITY)          BILL_QUANTITY,
        l_last_update_date               LAST_UPDATE_DATE,
        l_last_updated_by                LAST_UPDATED_BY,
        l_creation_date                  CREATION_DATE,
        l_created_by                     CREATED_BY,
        l_last_update_login              LAST_UPDATE_LOGIN
      from
        PJI_FM_AGGR_FIN6        tmp6,
        PJI_FP_TXN_ACCUM_HEADER hdr
      where
        tmp6.WORKER_ID                   = p_worker_id                     and
        tmp6.RECORD_TYPE                 = 'A'                             and
        tmp6.PERSON_ID                   = hdr.PERSON_ID                   and
        tmp6.EXPENDITURE_ORG_ID          = hdr.EXPENDITURE_ORG_ID          and
        tmp6.EXPENDITURE_ORGANIZATION_ID = hdr.EXPENDITURE_ORGANIZATION_ID and
        tmp6.RESOURCE_CLASS_ID           = hdr.RESOURCE_CLASS_ID           and
        tmp6.JOB_ID                      = hdr.JOB_ID                      and
        tmp6.VENDOR_ID                   = hdr.VENDOR_ID                   and
        tmp6.WORK_TYPE_ID                = hdr.WORK_TYPE_ID                and
        tmp6.EXPENDITURE_CATEGORY_ID     = hdr.EXPENDITURE_CATEGORY_ID     and
        tmp6.EXPENDITURE_TYPE_ID         = hdr.EXPENDITURE_TYPE_ID         and
        tmp6.EVENT_TYPE_ID               = hdr.EVENT_TYPE_ID               and
        tmp6.EXP_EVT_TYPE_ID             = hdr.EXP_EVT_TYPE_ID             and
        tmp6.EXPENDITURE_TYPE            = hdr.EXPENDITURE_TYPE            and
        tmp6.EVENT_TYPE                  = hdr.EVENT_TYPE                  and
        tmp6.EVENT_TYPE_CLASSIFICATION   = hdr.EVENT_TYPE_CLASSIFICATION   and
        tmp6.EXPENDITURE_CATEGORY        = hdr.EXPENDITURE_CATEGORY        and
        tmp6.REVENUE_CATEGORY            = hdr.REVENUE_CATEGORY            and
        tmp6.NON_LABOR_RESOURCE_ID       = hdr.NON_LABOR_RESOURCE_ID       and
        tmp6.BOM_LABOR_RESOURCE_ID       = hdr.BOM_LABOR_RESOURCE_ID       and
        tmp6.BOM_EQUIPMENT_RESOURCE_ID   = hdr.BOM_EQUIPMENT_RESOURCE_ID   and
        tmp6.ITEM_CATEGORY_ID            = hdr.ITEM_CATEGORY_ID            and
        tmp6.INVENTORY_ITEM_ID           = hdr.INVENTORY_ITEM_ID           and
        tmp6.PROJECT_ROLE_ID             = hdr.PROJECT_ROLE_ID             and
        tmp6.PERSON_TYPE                 = hdr.PERSON_TYPE                 and
        tmp6.SYSTEM_LINKAGE_FUNCTION     = hdr.SYSTEM_LINKAGE_FUNCTION     and
        tmp6.PROJECT_ID not in (select pjp.PROJECT_ID
                                from   PJI_PJP_PROJ_EXTR_STATUS pjp)
      group by
        hdr.TXN_ACCUM_HEADER_ID,
        hdr.RESOURCE_CLASS_ID,
        tmp6.PROJECT_ID,
        tmp6.PROJECT_ORG_ID,
        tmp6.PROJECT_ORGANIZATION_ID,
        tmp6.PROJECT_TYPE_CLASS,
        tmp6.TASK_ID,
        tmp6.ASSIGNMENT_ID,
        tmp6.NAMED_ROLE,
        tmp6.RECVR_PERIOD_TYPE,
        tmp6.RECVR_PERIOD_ID,
        tmp6.TXN_CURRENCY_CODE;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.BALANCES_INCR_NEW_PRJ(p_worker_id);');

    commit;

  end BALANCES_INCR_NEW_PRJ;


  -- -----------------------------------------------------
  -- procedure BALANCES_INSERT_CMT
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure BALANCES_INSERT_CMT (p_worker_id in number) is

    l_process             varchar2(30);
    l_last_update_date    date;
    l_last_updated_by     number;
    l_creation_date       date;
    l_created_by          number;
    l_last_update_login   number;
    l_extraction_type     varchar2(15);
    l_extract_commitments varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.BALANCES_INSERT_CMT(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    l_extract_commitments := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                             (PJI_FM_SUM_MAIN.g_process,
                              'EXTRACT_COMMITMENTS');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if ((l_extraction_type = 'FULL' or
         l_extraction_type = 'PARTIAL') and
        l_extract_commitments = 'Y') then

      -- Only insert commitments during FULL run since INCREMENTAL commitments
      -- data is handled at the same time as INCREMETNAL actuals data above.

      insert /*+ append parallel(bal) */ into PJI_FP_TXN_ACCUM1 bal
      (
        TXN_ACCUM_HEADER_ID,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        TASK_ID,
        RECVR_PERIOD_TYPE,
        RECVR_PERIOD_ID,
        TXN_CURRENCY_CODE,
        TXN_SUP_INV_COMMITTED_COST,
        TXN_PO_COMMITTED_COST,
        TXN_PR_COMMITTED_COST,
        TXN_OTH_COMMITTED_COST,
        PRJ_SUP_INV_COMMITTED_COST,
        PRJ_PO_COMMITTED_COST,
        PRJ_PR_COMMITTED_COST,
        PRJ_OTH_COMMITTED_COST,
        POU_SUP_INV_COMMITTED_COST,
        POU_PO_COMMITTED_COST,
        POU_PR_COMMITTED_COST,
        POU_OTH_COMMITTED_COST,
        EOU_SUP_INV_COMMITTED_COST,
        EOU_PO_COMMITTED_COST,
        EOU_PR_COMMITTED_COST,
        EOU_OTH_COMMITTED_COST,
        G1_SUP_INV_COMMITTED_COST,
        G1_PO_COMMITTED_COST,
        G1_PR_COMMITTED_COST,
        G1_OTH_COMMITTED_COST,
        G2_SUP_INV_COMMITTED_COST,
        G2_PO_COMMITTED_COST,
        G2_PR_COMMITTED_COST,
        G2_OTH_COMMITTED_COST,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ ordered
                 full(tmp6) parallel(tmp6) use_hash(tmp6)
                 full(hdr)  parallel(hdr)
                 pq_distribute(tmp2, hash, hash) */
        hdr.TXN_ACCUM_HEADER_ID,
        tmp6.PROJECT_ID,
        tmp6.PROJECT_ORG_ID,
        tmp6.PROJECT_ORGANIZATION_ID,
        tmp6.TASK_ID,
        tmp6.RECVR_PERIOD_TYPE,
        tmp6.RECVR_PERIOD_ID,
        tmp6.TXN_CURRENCY_CODE,
        sum(tmp6.TXN_SUP_INV_COMMITTED_COST) TXN_SUP_INV_COMMITTED_COST,
        sum(tmp6.TXN_PO_COMMITTED_COST)      TXN_PO_COMMITTED_COST,
        sum(tmp6.TXN_PR_COMMITTED_COST)      TXN_PR_COMMITTED_COST,
        sum(tmp6.TXN_OTH_COMMITTED_COST)     TXN_OTH_COMMITTED_COST,
        sum(tmp6.PRJ_SUP_INV_COMMITTED_COST) PRJ_SUP_INV_COMMITTED_COST,
        sum(tmp6.PRJ_PO_COMMITTED_COST)      PRJ_PO_COMMITTED_COST,
        sum(tmp6.PRJ_PR_COMMITTED_COST)      PRJ_PR_COMMITTED_COST,
        sum(tmp6.PRJ_OTH_COMMITTED_COST)     PRJ_OTH_COMMITTED_COST,
        sum(tmp6.POU_SUP_INV_COMMITTED_COST) POU_SUP_INV_COMMITTED_COST,
        sum(tmp6.POU_PO_COMMITTED_COST)      POU_PO_COMMITTED_COST,
        sum(tmp6.POU_PR_COMMITTED_COST)      POU_PR_COMMITTED_COST,
        sum(tmp6.POU_OTH_COMMITTED_COST)     POU_OTH_COMMITTED_COST,
        sum(tmp6.EOU_SUP_INV_COMMITTED_COST) EOU_SUP_INV_COMMITTED_COST,
        sum(tmp6.EOU_PO_COMMITTED_COST)      EOU_PO_COMMITTED_COST,
        sum(tmp6.EOU_PR_COMMITTED_COST)      EOU_PR_COMMITTED_COST,
        sum(tmp6.EOU_OTH_COMMITTED_COST)     EOU_OTH_COMMITTED_COST,
        sum(tmp6.G1_SUP_INV_COMMITTED_COST)  G1_SUP_INV_COMMITTED_COST,
        sum(tmp6.G1_PO_COMMITTED_COST)       G1_PO_COMMITTED_COST,
        sum(tmp6.G1_PR_COMMITTED_COST)       G1_PR_COMMITTED_COST,
        sum(tmp6.G1_OTH_COMMITTED_COST)      G1_OTH_COMMITTED_COST,
        sum(tmp6.G2_SUP_INV_COMMITTED_COST)  G2_SUP_INV_COMMITTED_COST,
        sum(tmp6.G2_PO_COMMITTED_COST)       G2_PO_COMMITTED_COST,
        sum(tmp6.G2_PR_COMMITTED_COST)       G2_PR_COMMITTED_COST,
        sum(tmp6.G2_OTH_COMMITTED_COST)      G2_OTH_COMMITTED_COST,
        l_last_update_date                   LAST_UPDATE_DATE,
        l_last_updated_by                    LAST_UPDATED_BY,
        l_creation_date                      CREATION_DATE,
        l_created_by                         CREATED_BY,
        l_last_update_login                  LAST_UPDATE_LOGIN
      from
        PJI_FM_AGGR_FIN6        tmp6,
        PJI_FP_TXN_ACCUM_HEADER hdr
      where
        tmp6.WORKER_ID                   = p_worker_id                     and
        tmp6.RECORD_TYPE                 = 'M'                             and
        tmp6.PERSON_ID                   = hdr.PERSON_ID                   and
        tmp6.EXPENDITURE_ORG_ID          = hdr.EXPENDITURE_ORG_ID          and
        tmp6.EXPENDITURE_ORGANIZATION_ID = hdr.EXPENDITURE_ORGANIZATION_ID and
        tmp6.RESOURCE_CLASS_ID           = hdr.RESOURCE_CLASS_ID           and
        tmp6.JOB_ID                      = hdr.JOB_ID                      and
        tmp6.VENDOR_ID                   = hdr.VENDOR_ID                   and
        tmp6.WORK_TYPE_ID                = hdr.WORK_TYPE_ID                and
        tmp6.EXPENDITURE_CATEGORY_ID     = hdr.EXPENDITURE_CATEGORY_ID     and
        tmp6.EXPENDITURE_TYPE_ID         = hdr.EXPENDITURE_TYPE_ID         and
        tmp6.EVENT_TYPE_ID               = hdr.EVENT_TYPE_ID               and
        tmp6.EXP_EVT_TYPE_ID             = hdr.EXP_EVT_TYPE_ID             and
        tmp6.EXPENDITURE_TYPE            = hdr.EXPENDITURE_TYPE            and
        tmp6.EVENT_TYPE                  = hdr.EVENT_TYPE                  and
        tmp6.EVENT_TYPE_CLASSIFICATION   = hdr.EVENT_TYPE_CLASSIFICATION   and
        tmp6.EXPENDITURE_CATEGORY        = hdr.EXPENDITURE_CATEGORY        and
        tmp6.REVENUE_CATEGORY            = hdr.REVENUE_CATEGORY            and
        tmp6.NON_LABOR_RESOURCE_ID       = hdr.NON_LABOR_RESOURCE_ID       and
        tmp6.BOM_LABOR_RESOURCE_ID       = hdr.BOM_LABOR_RESOURCE_ID       and
        tmp6.BOM_EQUIPMENT_RESOURCE_ID   = hdr.BOM_EQUIPMENT_RESOURCE_ID   and
        tmp6.ITEM_CATEGORY_ID            = hdr.ITEM_CATEGORY_ID            and
        tmp6.INVENTORY_ITEM_ID           = hdr.INVENTORY_ITEM_ID           and
        tmp6.PROJECT_ROLE_ID             = hdr.PROJECT_ROLE_ID             and
        tmp6.NAMED_ROLE                  = hdr.NAMED_ROLE                  and
        tmp6.PERSON_TYPE                 = hdr.PERSON_TYPE                 and
        tmp6.SYSTEM_LINKAGE_FUNCTION     = hdr.SYSTEM_LINKAGE_FUNCTION
      group by
        hdr.TXN_ACCUM_HEADER_ID,
        tmp6.PROJECT_ID,
        tmp6.PROJECT_ORG_ID,
        tmp6.PROJECT_ORGANIZATION_ID,
        tmp6.TASK_ID,
        tmp6.RECVR_PERIOD_TYPE,
        tmp6.RECVR_PERIOD_ID,
        tmp6.TXN_CURRENCY_CODE;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.BALANCES_INSERT_CMT(p_worker_id);');

    commit;

  end BALANCES_INSERT_CMT;


  -- -----------------------------------------------------
  -- procedure BALANCES_INCR_NEW_PRJ_CMT
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure BALANCES_INCR_NEW_PRJ_CMT (p_worker_id in number) is

    l_process             varchar2(30);
    l_last_update_date    date;
    l_last_updated_by     number;
    l_creation_date       date;
    l_created_by          number;
    l_last_update_login   number;
    l_extraction_type     varchar2(15);
    l_extract_commitments varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.BALANCES_INCR_NEW_PRJ_CMT(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    l_extract_commitments := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                             (PJI_FM_SUM_MAIN.g_process,
                              'EXTRACT_COMMITMENTS');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (l_extraction_type = 'INCREMENTAL' and l_extract_commitments = 'Y') then

      insert /*+ append parallel(bal) */ into PJI_FP_TXN_ACCUM1 bal
      (
        TXN_ACCUM_HEADER_ID,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        TASK_ID,
        RECVR_PERIOD_TYPE,
        RECVR_PERIOD_ID,
        TXN_CURRENCY_CODE,
        TXN_SUP_INV_COMMITTED_COST,
        TXN_PO_COMMITTED_COST,
        TXN_PR_COMMITTED_COST,
        TXN_OTH_COMMITTED_COST,
        PRJ_SUP_INV_COMMITTED_COST,
        PRJ_PO_COMMITTED_COST,
        PRJ_PR_COMMITTED_COST,
        PRJ_OTH_COMMITTED_COST,
        POU_SUP_INV_COMMITTED_COST,
        POU_PO_COMMITTED_COST,
        POU_PR_COMMITTED_COST,
        POU_OTH_COMMITTED_COST,
        EOU_SUP_INV_COMMITTED_COST,
        EOU_PO_COMMITTED_COST,
        EOU_PR_COMMITTED_COST,
        EOU_OTH_COMMITTED_COST,
        G1_SUP_INV_COMMITTED_COST,
        G1_PO_COMMITTED_COST,
        G1_PR_COMMITTED_COST,
        G1_OTH_COMMITTED_COST,
        G2_SUP_INV_COMMITTED_COST,
        G2_PO_COMMITTED_COST,
        G2_PR_COMMITTED_COST,
        G2_OTH_COMMITTED_COST,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ ordered
                 full(tmp6) parallel(tmp6) use_hash(tmp6)
                 full(hdr)  parallel(hdr)
                 pq_distribute(tmp2, hash, hash) */
        hdr.TXN_ACCUM_HEADER_ID,
        tmp6.PROJECT_ID,
        tmp6.PROJECT_ORG_ID,
        tmp6.PROJECT_ORGANIZATION_ID,
        tmp6.TASK_ID,
        tmp6.RECVR_PERIOD_TYPE,
        tmp6.RECVR_PERIOD_ID,
        tmp6.TXN_CURRENCY_CODE,
        sum(tmp6.TXN_SUP_INV_COMMITTED_COST) TXN_SUP_INV_COMMITTED_COST,
        sum(tmp6.TXN_PO_COMMITTED_COST)      TXN_PO_COMMITTED_COST,
        sum(tmp6.TXN_PR_COMMITTED_COST)      TXN_PR_COMMITTED_COST,
        sum(tmp6.TXN_OTH_COMMITTED_COST)     TXN_OTH_COMMITTED_COST,
        sum(tmp6.PRJ_SUP_INV_COMMITTED_COST) PRJ_SUP_INV_COMMITTED_COST,
        sum(tmp6.PRJ_PO_COMMITTED_COST)      PRJ_PO_COMMITTED_COST,
        sum(tmp6.PRJ_PR_COMMITTED_COST)      PRJ_PR_COMMITTED_COST,
        sum(tmp6.PRJ_OTH_COMMITTED_COST)     PRJ_OTH_COMMITTED_COST,
        sum(tmp6.POU_SUP_INV_COMMITTED_COST) POU_SUP_INV_COMMITTED_COST,
        sum(tmp6.POU_PO_COMMITTED_COST)      POU_PO_COMMITTED_COST,
        sum(tmp6.POU_PR_COMMITTED_COST)      POU_PR_COMMITTED_COST,
        sum(tmp6.POU_OTH_COMMITTED_COST)     POU_OTH_COMMITTED_COST,
        sum(tmp6.EOU_SUP_INV_COMMITTED_COST) EOU_SUP_INV_COMMITTED_COST,
        sum(tmp6.EOU_PO_COMMITTED_COST)      EOU_PO_COMMITTED_COST,
        sum(tmp6.EOU_PR_COMMITTED_COST)      EOU_PR_COMMITTED_COST,
        sum(tmp6.EOU_OTH_COMMITTED_COST)     EOU_OTH_COMMITTED_COST,
        sum(tmp6.G1_SUP_INV_COMMITTED_COST)  G1_SUP_INV_COMMITTED_COST,
        sum(tmp6.G1_PO_COMMITTED_COST)       G1_PO_COMMITTED_COST,
        sum(tmp6.G1_PR_COMMITTED_COST)       G1_PR_COMMITTED_COST,
        sum(tmp6.G1_OTH_COMMITTED_COST)      G1_OTH_COMMITTED_COST,
        sum(tmp6.G2_SUP_INV_COMMITTED_COST)  G2_SUP_INV_COMMITTED_COST,
        sum(tmp6.G2_PO_COMMITTED_COST)       G2_PO_COMMITTED_COST,
        sum(tmp6.G2_PR_COMMITTED_COST)       G2_PR_COMMITTED_COST,
        sum(tmp6.G2_OTH_COMMITTED_COST)      G2_OTH_COMMITTED_COST,
        l_last_update_date                   LAST_UPDATE_DATE,
        l_last_updated_by                    LAST_UPDATED_BY,
        l_creation_date                      CREATION_DATE,
        l_created_by                         CREATED_BY,
        l_last_update_login                  LAST_UPDATE_LOGIN
      from
        PJI_FM_AGGR_FIN6        tmp6,
        PJI_FP_TXN_ACCUM_HEADER hdr
      where
        tmp6.WORKER_ID                   = p_worker_id                     and
        tmp6.RECORD_TYPE                 = 'M'                             and
        tmp6.PERSON_ID                   = hdr.PERSON_ID                   and
        tmp6.EXPENDITURE_ORG_ID          = hdr.EXPENDITURE_ORG_ID          and
        tmp6.EXPENDITURE_ORGANIZATION_ID = hdr.EXPENDITURE_ORGANIZATION_ID and
        tmp6.RESOURCE_CLASS_ID           = hdr.RESOURCE_CLASS_ID           and
        tmp6.JOB_ID                      = hdr.JOB_ID                      and
        tmp6.VENDOR_ID                   = hdr.VENDOR_ID                   and
        tmp6.WORK_TYPE_ID                = hdr.WORK_TYPE_ID                and
        tmp6.EXPENDITURE_CATEGORY_ID     = hdr.EXPENDITURE_CATEGORY_ID     and
        tmp6.EXPENDITURE_TYPE_ID         = hdr.EXPENDITURE_TYPE_ID         and
        tmp6.EVENT_TYPE_ID               = hdr.EVENT_TYPE_ID               and
        tmp6.EXP_EVT_TYPE_ID             = hdr.EXP_EVT_TYPE_ID             and
        tmp6.EXPENDITURE_TYPE            = hdr.EXPENDITURE_TYPE            and
        tmp6.EVENT_TYPE                  = hdr.EVENT_TYPE                  and
        tmp6.EVENT_TYPE_CLASSIFICATION   = hdr.EVENT_TYPE_CLASSIFICATION   and
        tmp6.EXPENDITURE_CATEGORY        = hdr.EXPENDITURE_CATEGORY        and
        tmp6.REVENUE_CATEGORY            = hdr.REVENUE_CATEGORY            and
        tmp6.NON_LABOR_RESOURCE_ID       = hdr.NON_LABOR_RESOURCE_ID       and
        tmp6.BOM_LABOR_RESOURCE_ID       = hdr.BOM_LABOR_RESOURCE_ID       and
        tmp6.BOM_EQUIPMENT_RESOURCE_ID   = hdr.BOM_EQUIPMENT_RESOURCE_ID   and
        tmp6.ITEM_CATEGORY_ID            = hdr.ITEM_CATEGORY_ID            and
        tmp6.INVENTORY_ITEM_ID           = hdr.INVENTORY_ITEM_ID           and
        tmp6.PROJECT_ROLE_ID             = hdr.PROJECT_ROLE_ID             and
        tmp6.NAMED_ROLE                  = hdr.NAMED_ROLE                  and
        tmp6.PERSON_TYPE                 = hdr.PERSON_TYPE                 and
        tmp6.SYSTEM_LINKAGE_FUNCTION     = hdr.SYSTEM_LINKAGE_FUNCTION     and
        tmp6.PROJECT_ID not in (select pjp.PROJECT_ID
                                from   PJI_PJP_PROJ_EXTR_STATUS pjp)
      group by
        hdr.TXN_ACCUM_HEADER_ID,
        tmp6.PROJECT_ID,
        tmp6.PROJECT_ORG_ID,
        tmp6.PROJECT_ORGANIZATION_ID,
        tmp6.TASK_ID,
        tmp6.RECVR_PERIOD_TYPE,
        tmp6.RECVR_PERIOD_ID,
        tmp6.TXN_CURRENCY_CODE;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.BALANCES_INCR_NEW_PRJ_CMT(p_worker_id);');

    commit;

  end BALANCES_INCR_NEW_PRJ_CMT;


  -- -----------------------------------------------------
  -- procedure FORCE_SUBSEQUENT_RUN
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure FORCE_SUBSEQUENT_RUN (p_worker_id in number) is

    l_worker_id       number;
    l_process         varchar2(30);
    l_extraction_type varchar2(15);

    l_newline         varchar2(10)   := '
';
    l_no_selection    varchar2(50);

    l_from_project_tg varchar2(40);
    l_to_project_tg   varchar2(40);
    l_plan_type_tg    varchar2(40);

    l_from_project_id number;
    l_to_project_id   number;
    l_plan_type_id    number;

    l_from_project    varchar2(50);
    l_to_project      varchar2(50);
    l_plan_type       varchar2(200);

    l_from_project_num    varchar2(50);
    l_to_project_num      varchar2(50);

    l_operating_unit  number := null;
    l_project_operating_unit_tg varchar2(40);
    l_project_operating_unit_name varchar2(240);
    l_print_rpt_flag varchar2(1) :='Y';
  begin
--Commenting out this procedure for Bug 8365073. Please check bug for details
 /*
    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.FORCE_SUBSEQUENT_RUN(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    if (l_extraction_type = 'PARTIAL') then
      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_NO_SELECTION');

      l_no_selection := FND_MESSAGE.GET;

     l_operating_unit := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                           (PJI_FM_SUM_MAIN.g_process, 'PROJECT_OPERATING_UNIT');

      if (nvl(l_operating_unit, -1) = -1) then
            l_project_operating_unit_name := l_no_selection;
          else
            select NAME
            into   l_project_operating_unit_name
            from   HR_OPERATING_UNITS
            where  ORGANIZATION_ID = l_operating_unit;
      end if;
*/

/* 4604355 l_from_project_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                           (PJI_FM_SUM_MAIN.g_process, 'FROM_PROJECT_ID');

      if (nvl(l_from_project_id, -1) = -1) then

        l_from_project := l_no_selection;

      else

        select SEGMENT1
        into   l_from_project
        from   PA_PROJECTS_ALL
        where  PROJECT_ID = l_from_project_id;

      end if;
4604355     *//*
      l_from_project_num := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                           (PJI_FM_SUM_MAIN.g_process, 'FROM_PROJECT');

      if (nvl(l_from_project_num,'PJI$NULL') = 'PJI$NULL') then

        l_from_project := l_no_selection;
      else

        l_from_project := l_from_project_num;
      end if;*/

/*4604355      l_to_project_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_FM_SUM_MAIN.g_process, 'TO_PROJECT_ID');

      if (nvl(l_to_project_id, -1) = -1) then

        l_to_project := l_no_selection;

      else

        select SEGMENT1
        into   l_to_project
        from   PA_PROJECTS_ALL
        where  PROJECT_ID = l_to_project_id;

      end if;
4604355 */
/*
     l_to_project_num := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_FM_SUM_MAIN.g_process, 'TO_PROJECT');

      if (nvl(l_to_project_num, 'PJI$NULL') = 'PJI$NULL') then

        l_to_project := l_no_selection;
      else
        l_to_project := l_to_project_num;

      end if;

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

      commit;

    BEGIN
      PJI_PJP_SUM_MAIN.INIT_PROCESS(l_worker_id,
                                    'P',
                                    l_operating_unit,
                                    null,
				    null,
                                    l_from_project_num,
                                    l_to_project_num,
                                    l_plan_type_id,
                                    null,
                                    null,
				    null,
				    null);

    EXCEPTION
	when others then
    IF SQLCODE = -20041 then
      l_print_rpt_flag:='N';
    else
       raise;
    end if;
   END;
    end if;

    if (l_extraction_type = 'PARTIAL' and l_print_rpt_flag ='Y') then

      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_FORCE_PRTL');

      PJI_UTILS.WRITE2OUT(l_newline       ||
                          l_newline       ||
                          FND_MESSAGE.GET ||
                          l_newline       ||
                          l_newline);

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PRJ_OP_UNIT');

          l_project_operating_unit_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_project_operating_unit_tg                      ||
                              PJI_FM_SUM_MAIN.my_pad(30 - length(l_project_operating_unit_tg),
                                     ' ')                                    ||
                              ': '                                           ||
                              l_project_operating_unit_name                  ||
                              l_newline);


            FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_FROM_PRJ');

      l_from_project_tg := substr(FND_MESSAGE.GET, 1, 30);

      PJI_UTILS.WRITE2OUT(l_from_project_tg           ||
                          PJI_FM_SUM_MAIN.my_pad(30-length(l_from_project_tg),
                                                 ' ') ||
                          ': '                        ||
                          l_from_project              ||
                          l_newline);


      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_TO_PRJ');

      l_to_project_tg := substr(FND_MESSAGE.GET, 1, 30);

      PJI_UTILS.WRITE2OUT(l_to_project_tg             ||
                          PJI_FM_SUM_MAIN.my_pad(30 - length(l_to_project_tg),
                                                 ' ') ||
                          ': '                        ||
                          l_to_project                ||
                          l_newline);


      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PLAN_TYPE');

      l_plan_type_tg := substr(FND_MESSAGE.GET, 1, 30);

      PJI_UTILS.WRITE2OUT(l_plan_type_tg              ||
                          PJI_FM_SUM_MAIN.my_pad(30 - length(l_plan_type_tg),
                                                 ' ') ||
                          ': '                        ||
                          l_plan_type                 ||
                          l_newline);

   end if;
*/

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.FORCE_SUBSEQUENT_RUN(p_worker_id);');

    commit;

  end FORCE_SUBSEQUENT_RUN;


  -- -----------------------------------------------------
  -- procedure BALANCES_ROWID_TABLE
  --
  --
  -- NOTE: This API is called from stage 3 summarization.
  --
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure BALANCES_ROWID_TABLE (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(15);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.BALANCES_ROWID_TABLE(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'INCREMENTAL') then

      -- Actuals
      insert into PJI_PJP_RMAP_FPR psi_i
      (
        WORKER_ID,
        STG_ROWID,
        TXN_ROWID,
        RECORD_TYPE
      )
      select /* ordered */
        distinct
        p_worker_id      WORKER_ID,
        tmp7.ROWID       STG_ROWID,
        psi.ROWID        TXN_ROWID,
        tmp7.RECORD_TYPE
      from
        PJI_PJP_PROJ_BATCH_MAP map,
        PJI_FM_AGGR_FIN7       tmp7,
        PJI_FP_TXN_ACCUM       psi
      where
        map.WORKER_ID                = p_worker_id                     and
        tmp7.PROJECT_ID              = map.PROJECT_ID                  and
        tmp7.RECORD_TYPE             = 'A'                             and
        tmp7.TXN_ACCUM_HEADER_ID     = psi.TXN_ACCUM_HEADER_ID     (+) and
        tmp7.RESOURCE_CLASS_ID       = psi.RESOURCE_CLASS_ID       (+) and
        tmp7.PROJECT_ID              = psi.PROJECT_ID              (+) and
        tmp7.PROJECT_ORG_ID          = psi.PROJECT_ORG_ID          (+) and
        tmp7.PROJECT_ORGANIZATION_ID = psi.PROJECT_ORGANIZATION_ID (+) and
        tmp7.TASK_ID                 = psi.TASK_ID                 (+) and
        tmp7.ASSIGNMENT_ID           = psi.ASSIGNMENT_ID           (+) and
        tmp7.NAMED_ROLE              = psi.NAMED_ROLE              (+) and
        tmp7.RECVR_PERIOD_TYPE       = psi.RECVR_PERIOD_TYPE       (+) and
        tmp7.RECVR_PERIOD_ID         = psi.RECVR_PERIOD_ID         (+) and
        tmp7.TXN_CURRENCY_CODE       = psi.TXN_CURRENCY_CODE       (+);

      -- coMmitments
      insert into PJI_PJP_RMAP_FPR psi_i
      (
        WORKER_ID,
        STG_ROWID,
        TXN_ROWID,
        RECORD_TYPE
      )
      select /* ordered */
        distinct
        p_worker_id      WORKER_ID,
        tmp7.ROWID       STG_ROWID,
        null             TXN_ROWID,
        tmp7.RECORD_TYPE
      from
        PJI_PJP_PROJ_BATCH_MAP map,
        PJI_FM_AGGR_FIN7 tmp7
      where
        map.WORKER_ID    = p_worker_id    and
        tmp7.PROJECT_ID  = map.PROJECT_ID and
        tmp7.RECORD_TYPE = 'M';

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.BALANCES_ROWID_TABLE(p_worker_id);');

    commit;

  end BALANCES_ROWID_TABLE;


  -- -----------------------------------------------------
  -- procedure BALANCES_UPDATE_DELTA
  --
  --
  -- NOTE: This API is called from stage 3 summarization.
  --
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure BALANCES_UPDATE_DELTA (p_worker_id in number) is

    l_process           varchar2(30);
    l_last_update_date  date;
    l_last_updated_by   number;
    l_last_update_login number;
    l_extraction_type   varchar2(15);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.BALANCES_UPDATE_DELTA(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (l_extraction_type = 'INCREMENTAL') then

      update PJI_FP_TXN_ACCUM psi
      set (TXN_RAW_COST,
           TXN_BILL_RAW_COST,
           TXN_BRDN_COST,
           TXN_BILL_BRDN_COST,
           TXN_REVENUE,
           PRJ_RAW_COST,
           PRJ_BILL_RAW_COST,
           PRJ_BRDN_COST,
           PRJ_BILL_BRDN_COST,
           PRJ_REVENUE,
           POU_RAW_COST,
           POU_BILL_RAW_COST,
           POU_BRDN_COST,
           POU_BILL_BRDN_COST,
           POU_REVENUE,
           EOU_RAW_COST,
           EOU_BILL_RAW_COST,
           EOU_BRDN_COST,
           EOU_BILL_BRDN_COST,
           G1_RAW_COST,
           G1_BILL_RAW_COST,
           G1_BRDN_COST,
           G1_BILL_BRDN_COST,
           G1_REVENUE,
           G2_RAW_COST,
           G2_BILL_RAW_COST,
           G2_BRDN_COST,
           G2_BILL_BRDN_COST,
           G2_REVENUE,
           QUANTITY,
           BILL_QUANTITY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN) =
          (select /*+ ordered index(tmp7_r, PJI_PJP_RMAP_FPR_N1) rowid(tmp7) */
             decode(nvl(psi.TXN_RAW_COST, 0) + nvl(sum(tmp7.TXN_RAW_COST), 0),
                    0, null,
                       nvl(psi.TXN_RAW_COST, 0) + nvl(sum(tmp7.TXN_RAW_COST), 0)),
             decode(nvl(psi.TXN_BILL_RAW_COST, 0) + nvl(sum(tmp7.TXN_BILL_RAW_COST), 0),
                    0, null,
                       nvl(psi.TXN_BILL_RAW_COST, 0) + nvl(sum(tmp7.TXN_BILL_RAW_COST), 0)),
             decode(nvl(psi.TXN_BRDN_COST, 0) + nvl(sum(tmp7.TXN_BRDN_COST), 0),
                    0, null,
                       nvl(psi.TXN_BRDN_COST, 0) + nvl(sum(tmp7.TXN_BRDN_COST), 0)),
             decode(nvl(psi.TXN_BILL_BRDN_COST, 0) + nvl(sum(tmp7.TXN_BILL_BRDN_COST), 0),
                    0, null,
                       nvl(psi.TXN_BILL_BRDN_COST, 0) + nvl(sum(tmp7.TXN_BILL_BRDN_COST), 0)),
             decode(nvl(psi.TXN_REVENUE, 0) + nvl(sum(tmp7.TXN_REVENUE), 0),
                    0, null,
                       nvl(psi.TXN_REVENUE, 0) + nvl(sum(tmp7.TXN_REVENUE), 0)),
             decode(nvl(psi.PRJ_RAW_COST, 0) + nvl(sum(tmp7.PRJ_RAW_COST), 0),
                    0, null,
                       nvl(psi.PRJ_RAW_COST, 0) + nvl(sum(tmp7.PRJ_RAW_COST), 0)),
             decode(nvl(psi.PRJ_BILL_RAW_COST, 0) + nvl(sum(tmp7.PRJ_BILL_RAW_COST), 0),
                    0, null,
                       nvl(psi.PRJ_BILL_RAW_COST, 0) + nvl(sum(tmp7.PRJ_BILL_RAW_COST), 0)),
             decode(nvl(psi.PRJ_BRDN_COST, 0) + nvl(sum(tmp7.PRJ_BRDN_COST), 0),
                    0, null,
                       nvl(psi.PRJ_BRDN_COST, 0) + nvl(sum(tmp7.PRJ_BRDN_COST), 0)),
             decode(nvl(psi.PRJ_BILL_BRDN_COST, 0) + nvl(sum(tmp7.PRJ_BILL_BRDN_COST), 0),
                    0, null,
                       nvl(psi.PRJ_BILL_BRDN_COST, 0) + nvl(sum(tmp7.PRJ_BILL_BRDN_COST), 0)),
             decode(nvl(psi.PRJ_REVENUE, 0) + nvl(sum(tmp7.PRJ_REVENUE), 0),
                    0, null,
                       nvl(psi.PRJ_REVENUE, 0) + nvl(sum(tmp7.PRJ_REVENUE), 0)),
             decode(nvl(psi.POU_RAW_COST, 0) + nvl(sum(tmp7.POU_RAW_COST), 0),
                    0, null,
                       nvl(psi.POU_RAW_COST, 0) + nvl(sum(tmp7.POU_RAW_COST), 0)),
             decode(nvl(psi.POU_BILL_RAW_COST, 0) + nvl(sum(tmp7.POU_BILL_RAW_COST), 0),
                    0, null,
                       nvl(psi.POU_BILL_RAW_COST, 0) + nvl(sum(tmp7.POU_BILL_RAW_COST), 0)),
             decode(nvl(psi.POU_BRDN_COST, 0) + nvl(sum(tmp7.POU_BRDN_COST), 0),
                    0, null,
                       nvl(psi.POU_BRDN_COST, 0) + nvl(sum(tmp7.POU_BRDN_COST), 0)),
             decode(nvl(psi.POU_BILL_BRDN_COST, 0) + nvl(sum(tmp7.POU_BILL_BRDN_COST), 0),
                    0, null,
                       nvl(psi.POU_BILL_BRDN_COST, 0) + nvl(sum(tmp7.POU_BILL_BRDN_COST), 0)),
             decode(nvl(psi.POU_REVENUE, 0) + nvl(sum(tmp7.POU_REVENUE), 0),
                    0, null,
                       nvl(psi.POU_REVENUE, 0) + nvl(sum(tmp7.POU_REVENUE), 0)),
             decode(nvl(psi.EOU_RAW_COST, 0) + nvl(sum(tmp7.EOU_RAW_COST), 0),
                    0, null,
                       nvl(psi.EOU_RAW_COST, 0) + nvl(sum(tmp7.EOU_RAW_COST), 0)),
             decode(nvl(psi.EOU_BILL_RAW_COST, 0) + nvl(sum(tmp7.EOU_BILL_RAW_COST), 0),
                    0, null,
                       nvl(psi.EOU_BILL_RAW_COST, 0) + nvl(sum(tmp7.EOU_BILL_RAW_COST), 0)),
             decode(nvl(psi.EOU_BRDN_COST, 0) + nvl(sum(tmp7.EOU_BRDN_COST), 0),
                    0, null,
                       nvl(psi.EOU_BRDN_COST, 0) + nvl(sum(tmp7.EOU_BRDN_COST), 0)),
             decode(nvl(psi.EOU_BILL_BRDN_COST, 0) + nvl(sum(tmp7.EOU_BILL_BRDN_COST), 0),
                    0, null,
                       nvl(psi.EOU_BILL_BRDN_COST, 0) + nvl(sum(tmp7.EOU_BILL_BRDN_COST), 0)),
             decode(nvl(psi.G1_RAW_COST, 0) + nvl(sum(tmp7.G1_RAW_COST), 0),
                    0, null,
                       nvl(psi.G1_RAW_COST, 0) + nvl(sum(tmp7.G1_RAW_COST), 0)),
             decode(nvl(psi.G1_BILL_RAW_COST, 0) + nvl(sum(tmp7.G1_BILL_RAW_COST), 0),
                    0, null,
                       nvl(psi.G1_BILL_RAW_COST, 0) + nvl(sum(tmp7.G1_BILL_RAW_COST), 0)),
             decode(nvl(psi.G1_BRDN_COST, 0) + nvl(sum(tmp7.G1_BRDN_COST), 0),
                    0, null,
                       nvl(psi.G1_BRDN_COST, 0) + nvl(sum(tmp7.G1_BRDN_COST), 0)),
             decode(nvl(psi.G1_BILL_BRDN_COST, 0) + nvl(sum(tmp7.G1_BILL_BRDN_COST), 0),
                    0, null,
                       nvl(psi.G1_BILL_BRDN_COST, 0) + nvl(sum(tmp7.G1_BILL_BRDN_COST), 0)),
             decode(nvl(psi.G1_REVENUE, 0) + nvl(sum(tmp7.G1_REVENUE), 0),
                    0, null,
                       nvl(psi.G1_REVENUE, 0) + nvl(sum(tmp7.G1_REVENUE), 0)),
             decode(nvl(psi.G2_RAW_COST, 0) + nvl(sum(tmp7.G2_RAW_COST), 0),
                    0, null,
                       nvl(psi.G2_RAW_COST, 0) + nvl(sum(tmp7.G2_RAW_COST), 0)),
             decode(nvl(psi.G2_BILL_RAW_COST, 0) + nvl(sum(tmp7.G2_BILL_RAW_COST), 0),
                    0, null,
                       nvl(psi.G2_BILL_RAW_COST, 0) + nvl(sum(tmp7.G2_BILL_RAW_COST), 0)),
             decode(nvl(psi.G2_BRDN_COST, 0) + nvl(sum(tmp7.G2_BRDN_COST), 0),
                    0, null,
                       nvl(psi.G2_BRDN_COST, 0) + nvl(sum(tmp7.G2_BRDN_COST), 0)),
             decode(nvl(psi.G2_BILL_BRDN_COST, 0) + nvl(sum(tmp7.G2_BILL_BRDN_COST), 0),
                    0, null,
                       nvl(psi.G2_BILL_BRDN_COST, 0) + nvl(sum(tmp7.G2_BILL_BRDN_COST), 0)),
             decode(nvl(psi.G2_REVENUE, 0) + nvl(sum(tmp7.G2_REVENUE), 0),
                    0, null,
                       nvl(psi.G2_REVENUE, 0) + nvl(sum(tmp7.G2_REVENUE), 0)),
             decode(nvl(psi.QUANTITY, 0) + nvl(sum(tmp7.QUANTITY), 0),
                    0, null,
                       nvl(psi.QUANTITY, 0) + nvl(sum(tmp7.QUANTITY), 0)),
             decode(nvl(psi.BILL_QUANTITY, 0) + nvl(sum(tmp7.BILL_QUANTITY), 0),
                    0, null,
                       nvl(psi.BILL_QUANTITY, 0) + nvl(sum(tmp7.BILL_QUANTITY), 0)),
             l_last_update_date,
             l_last_updated_by,
             l_last_update_login
           from
             PJI_PJP_RMAP_FPR tmp7_r,
             PJI_FM_AGGR_FIN7 tmp7
           where
             tmp7_r.WORKER_ID   = p_worker_id       and
             tmp7_r.RECORD_TYPE = 'A'               and
             tmp7_r.TXN_ROWID   is not null         and
             tmp7.ROWID         = tmp7_r.STG_ROWID and
             psi.ROWID          = tmp7_r.TXN_ROWID)
      where psi.ROWID in
            (select /*+ index(tmp7_r, PJI_PJP_RMAP_FPR_N1) */
               tmp7_r.TXN_ROWID
             from
               PJI_PJP_RMAP_FPR tmp7_r
             where
               tmp7_r.WORKER_ID   = p_worker_id and
               tmp7_r.RECORD_TYPE = 'A' and
               tmp7_r.TXN_ROWID   is not null);

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.BALANCES_UPDATE_DELTA(p_worker_id);');

    commit;

  end BALANCES_UPDATE_DELTA;


  -- -----------------------------------------------------
  -- procedure BALANCES_INSERT_DELTA
  --
  --
  -- NOTE: This API is called from stage 3 summarization.
  --
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure BALANCES_INSERT_DELTA (p_worker_id in number) is

    l_process           varchar2(30);
    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;
    l_extraction_type   varchar2(15);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.BALANCES_INSERT_DELTA(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (l_extraction_type = 'INCREMENTAL') then

      insert /*+ append parallel(bal_i) */ into PJI_FP_TXN_ACCUM bal_i
      (
        TXN_ACCUM_HEADER_ID,
        RESOURCE_CLASS_ID,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_TYPE_CLASS,
        TASK_ID,
        ASSIGNMENT_ID,
        NAMED_ROLE,
        RECVR_PERIOD_TYPE,
        RECVR_PERIOD_ID,
        TXN_CURRENCY_CODE,
        TXN_RAW_COST,
        TXN_BILL_RAW_COST,
        TXN_BRDN_COST,
        TXN_BILL_BRDN_COST,
        TXN_REVENUE,
        PRJ_RAW_COST,
        PRJ_BILL_RAW_COST,
        PRJ_BRDN_COST,
        PRJ_BILL_BRDN_COST,
        PRJ_REVENUE,
        POU_RAW_COST,
        POU_BILL_RAW_COST,
        POU_BRDN_COST,
        POU_BILL_BRDN_COST,
        POU_REVENUE,
        EOU_RAW_COST,
        EOU_BILL_RAW_COST,
        EOU_BRDN_COST,
        EOU_BILL_BRDN_COST,
        G1_RAW_COST,
        G1_BILL_RAW_COST,
        G1_BRDN_COST,
        G1_BILL_BRDN_COST,
        G1_REVENUE,
        G2_RAW_COST,
        G2_BILL_RAW_COST,
        G2_BRDN_COST,
        G2_BILL_BRDN_COST,
        G2_REVENUE,
        QUANTITY,
        BILL_QUANTITY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ ordered
                 full(tmp7_r) parallel(tmp7_r)
                 rowid(tmp7) */
        tmp7.TXN_ACCUM_HEADER_ID,
        tmp7.RESOURCE_CLASS_ID,
        tmp7.PROJECT_ID,
        tmp7.PROJECT_ORG_ID,
        tmp7.PROJECT_ORGANIZATION_ID,
        tmp7.PROJECT_TYPE_CLASS,
        tmp7.TASK_ID,
        tmp7.ASSIGNMENT_ID,
        tmp7.NAMED_ROLE,
        tmp7.RECVR_PERIOD_TYPE,
        tmp7.RECVR_PERIOD_ID,
        tmp7.TXN_CURRENCY_CODE,
        sum(tmp7.TXN_RAW_COST)           TXN_RAW_COST,
        sum(tmp7.TXN_BILL_RAW_COST)      TXN_BILL_RAW_COST,
        sum(tmp7.TXN_BRDN_COST)          TXN_BRDN_COST,
        sum(tmp7.TXN_BILL_BRDN_COST)     TXN_BILL_BRDN_COST,
        sum(tmp7.TXN_REVENUE)            TXN_REVENUE,
        sum(tmp7.PRJ_RAW_COST)           PRJ_RAW_COST,
        sum(tmp7.PRJ_BILL_RAW_COST)      PRJ_BILL_RAW_COST,
        sum(tmp7.PRJ_BRDN_COST)          PRJ_BRDN_COST,
        sum(tmp7.PRJ_BILL_BRDN_COST)     PRJ_BILL_BRDN_COST,
        sum(tmp7.PRJ_REVENUE)            PRJ_REVENUE,
        sum(tmp7.POU_RAW_COST)           POU_RAW_COST,
        sum(tmp7.POU_BILL_RAW_COST)      POU_BILL_RAW_COST,
        sum(tmp7.POU_BRDN_COST)          POU_BRDN_COST,
        sum(tmp7.POU_BILL_BRDN_COST)     POU_BILL_BRDN_COST,
        sum(tmp7.POU_REVENUE)            POU_REVENUE,
        sum(tmp7.EOU_RAW_COST)           EOU_RAW_COST,
        sum(tmp7.EOU_BILL_RAW_COST)      EOU_BILL_RAW_COST,
        sum(tmp7.EOU_BRDN_COST)          EOU_BRDN_COST,
        sum(tmp7.EOU_BILL_BRDN_COST)     EOU_BILL_BRDN_COST,
        sum(tmp7.G1_RAW_COST)            G1_RAW_COST,
        sum(tmp7.G1_BILL_RAW_COST)       G1_BILL_RAW_COST,
        sum(tmp7.G1_BRDN_COST)           G1_BRDN_COST,
        sum(tmp7.G1_BILL_BRDN_COST)      G1_BILL_BRDN_COST,
        sum(tmp7.G1_REVENUE)             G1_REVENUE,
        sum(tmp7.G2_RAW_COST)            G2_RAW_COST,
        sum(tmp7.G2_BILL_RAW_COST)       G2_BILL_RAW_COST,
        sum(tmp7.G2_BRDN_COST)           G2_BRDN_COST,
        sum(tmp7.G2_BILL_BRDN_COST)      G2_BILL_BRDN_COST,
        sum(tmp7.G2_REVENUE)             G2_REVENUE,
        sum(tmp7.QUANTITY)               QUANTITY,
        sum(tmp7.BILL_QUANTITY)          BILL_QUANTITY,
        l_last_update_date               LAST_UPDATE_DATE,
        l_last_updated_by                LAST_UPDATED_BY,
        l_creation_date                  CREATION_DATE,
        l_created_by                     CREATED_BY,
        l_last_update_login              LAST_UPDATE_LOGIN
      from
        PJI_PJP_RMAP_FPR tmp7_r,
        PJI_FM_AGGR_FIN7 tmp7
      where
        tmp7_r.WORKER_ID   = p_worker_id and
        tmp7_r.TXN_ROWID   is null       and
        tmp7_r.RECORD_TYPE = 'A'         and
        tmp7.ROWID         = tmp7_r.STG_ROWID
      group by
        tmp7.TXN_ACCUM_HEADER_ID,
        tmp7.RESOURCE_CLASS_ID,
        tmp7.PROJECT_ID,
        tmp7.PROJECT_ORG_ID,
        tmp7.PROJECT_ORGANIZATION_ID,
        tmp7.PROJECT_TYPE_CLASS,
        tmp7.TASK_ID,
        tmp7.ASSIGNMENT_ID,
        tmp7.NAMED_ROLE,
        tmp7.RECVR_PERIOD_TYPE,
        tmp7.RECVR_PERIOD_ID,
        tmp7.TXN_CURRENCY_CODE;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.BALANCES_INSERT_DELTA(p_worker_id);');

    commit;

  end BALANCES_INSERT_DELTA;


  -- -----------------------------------------------------
  -- procedure PURGE_INCREMENTAL_BALANCES
  --
  --
  -- NOTE: This API is called from stage 3 summarization.
  --
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure PURGE_INCREMENTAL_BALANCES (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(15);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.PURGE_INCREMENTAL_BALANCES(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'INCREMENTAL') then

      delete from PJI_FM_AGGR_FIN7
      where ROWID in (select STG_ROWID
                      from   PJI_PJP_RMAP_FPR
                      where  WORKER_ID = p_worker_id);

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.PURGE_INCREMENTAL_BALANCES(p_worker_id);');

    commit;

  end PURGE_INCREMENTAL_BALANCES;


  -- -----------------------------------------------------
  -- procedure PURGE_BALANCES_CMT
  --
  --
  -- NOTE: This API is called from stage 3 summarization.
  --
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure PURGE_BALANCES_CMT (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.PURGE_BALANCES_CMT(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'INCREMENTAL') then

      delete
      from   PJI_FP_TXN_ACCUM1 bal
      where  bal.PROJECT_ID in (select distinct
                                       fin7.PROJECT_ID
                                from   PJI_PJP_RMAP_FPR tmp7_r,
                                       PJI_FM_AGGR_FIN7 fin7
                                where  tmp7_r.WORKER_ID   = p_worker_id and
                                       tmp7_r.RECORD_TYPE = 'M' and
                                       fin7.ROWID         = tmp7_r.STG_ROWID);


    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.PURGE_BALANCES_CMT(p_worker_id);');

    commit;

  end PURGE_BALANCES_CMT;


  -- -----------------------------------------------------
  -- procedure BALANCES_INSERT_DELTA_CMT
  --
  --
  -- NOTE: This API is called from stage 3 summarization.
  --
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure BALANCES_INSERT_DELTA_CMT (p_worker_id in number) is

    l_process           varchar2(30);
    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;
    l_extraction_type   varchar2(15);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.BALANCES_INSERT_DELTA_CMT(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (l_extraction_type = 'INCREMENTAL') then

      insert /*+ append parallel(bal_i) */ into PJI_FP_TXN_ACCUM1 bal_i
      (
        TXN_ACCUM_HEADER_ID,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        TASK_ID,
        RECVR_PERIOD_TYPE,
        RECVR_PERIOD_ID,
        TXN_CURRENCY_CODE,
        TXN_SUP_INV_COMMITTED_COST,
        TXN_PO_COMMITTED_COST,
        TXN_PR_COMMITTED_COST,
        TXN_OTH_COMMITTED_COST,
        PRJ_SUP_INV_COMMITTED_COST,
        PRJ_PO_COMMITTED_COST,
        PRJ_PR_COMMITTED_COST,
        PRJ_OTH_COMMITTED_COST,
        POU_SUP_INV_COMMITTED_COST,
        POU_PO_COMMITTED_COST,
        POU_PR_COMMITTED_COST,
        POU_OTH_COMMITTED_COST,
        EOU_SUP_INV_COMMITTED_COST,
        EOU_PO_COMMITTED_COST,
        EOU_PR_COMMITTED_COST,
        EOU_OTH_COMMITTED_COST,
        G1_SUP_INV_COMMITTED_COST,
        G1_PO_COMMITTED_COST,
        G1_PR_COMMITTED_COST,
        G1_OTH_COMMITTED_COST,
        G2_SUP_INV_COMMITTED_COST,
        G2_PO_COMMITTED_COST,
        G2_PR_COMMITTED_COST,
        G2_OTH_COMMITTED_COST,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select
        tmp7.TXN_ACCUM_HEADER_ID,
        tmp7.PROJECT_ID,
        tmp7.PROJECT_ORG_ID,
        tmp7.PROJECT_ORGANIZATION_ID,
        tmp7.TASK_ID,
        tmp7.RECVR_PERIOD_TYPE,
        tmp7.RECVR_PERIOD_ID,
        tmp7.TXN_CURRENCY_CODE,
        sum(tmp7.TXN_SUP_INV_COMMITTED_COST) TXN_SUP_INV_COMMITTED_COST,
        sum(tmp7.TXN_PO_COMMITTED_COST)      TXN_PO_COMMITTED_COST,
        sum(tmp7.TXN_PR_COMMITTED_COST)      TXN_PR_COMMITTED_COST,
        sum(tmp7.TXN_OTH_COMMITTED_COST)     TXN_OTH_COMMITTED_COST,
        sum(tmp7.PRJ_SUP_INV_COMMITTED_COST) PRJ_SUP_INV_COMMITTED_COST,
        sum(tmp7.PRJ_PO_COMMITTED_COST)      PRJ_PO_COMMITTED_COST,
        sum(tmp7.PRJ_PR_COMMITTED_COST)      PRJ_PR_COMMITTED_COST,
        sum(tmp7.PRJ_OTH_COMMITTED_COST)     PRJ_OTH_COMMITTED_COST,
        sum(tmp7.POU_SUP_INV_COMMITTED_COST) POU_SUP_INV_COMMITTED_COST,
        sum(tmp7.POU_PO_COMMITTED_COST)      POU_PO_COMMITTED_COST,
        sum(tmp7.POU_PR_COMMITTED_COST)      POU_PR_COMMITTED_COST,
        sum(tmp7.POU_OTH_COMMITTED_COST)     POU_OTH_COMMITTED_COST,
        sum(tmp7.EOU_SUP_INV_COMMITTED_COST) EOU_SUP_INV_COMMITTED_COST,
        sum(tmp7.EOU_PO_COMMITTED_COST)      EOU_PO_COMMITTED_COST,
        sum(tmp7.EOU_PR_COMMITTED_COST)      EOU_PR_COMMITTED_COST,
        sum(tmp7.EOU_OTH_COMMITTED_COST)     EOU_OTH_COMMITTED_COST,
        sum(tmp7.G1_SUP_INV_COMMITTED_COST)  G1_SUP_INV_COMMITTED_COST,
        sum(tmp7.G1_PO_COMMITTED_COST)       G1_PO_COMMITTED_COST,
        sum(tmp7.G1_PR_COMMITTED_COST)       G1_PR_COMMITTED_COST,
        sum(tmp7.G1_OTH_COMMITTED_COST)      G1_OTH_COMMITTED_COST,
        sum(tmp7.G2_SUP_INV_COMMITTED_COST)  G2_SUP_INV_COMMITTED_COST,
        sum(tmp7.G2_PO_COMMITTED_COST)       G2_PO_COMMITTED_COST,
        sum(tmp7.G2_PR_COMMITTED_COST)       G2_PR_COMMITTED_COST,
        sum(tmp7.G2_OTH_COMMITTED_COST)      G2_OTH_COMMITTED_COST,
        l_last_update_date                   LAST_UPDATE_DATE,
        l_last_updated_by                    LAST_UPDATED_BY,
        l_creation_date                      CREATION_DATE,
        l_created_by                         CREATED_BY,
        l_last_update_login                  LAST_UPDATE_LOGIN
      from
        PJI_PJP_RMAP_FPR tmp7_r,
        PJI_FM_AGGR_FIN7 tmp7
      where
        tmp7_r.WORKER_ID   = p_worker_id and
        tmp7_r.TXN_ROWID   is null       and
        tmp7_r.RECORD_TYPE = 'M'         and
        tmp7.ROWID         = tmp7_r.STG_ROWID
      group by
        tmp7.TXN_ACCUM_HEADER_ID,
        tmp7.PROJECT_ID,
        tmp7.PROJECT_ORG_ID,
        tmp7.PROJECT_ORGANIZATION_ID,
        tmp7.TASK_ID,
        tmp7.RECVR_PERIOD_TYPE,
        tmp7.RECVR_PERIOD_ID,
        tmp7.TXN_CURRENCY_CODE;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.BALANCES_INSERT_DELTA_CMT(p_worker_id);');

    commit;

  end BALANCES_INSERT_DELTA_CMT;


  -- -----------------------------------------------------
  -- procedure ACT_ROWID_TABLE
  --
  --
  -- NOTE: This API is called from stage 3 summarization.
  --
  --
  --   History
  --   30-SEP-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure ACT_ROWID_TABLE (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(15);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.ACT_ROWID_TABLE(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    insert into PJI_PJP_RMAP_ACR psi_i
    (
      WORKER_ID,
      STG_ROWID
    )
    select /* ordered */
      p_worker_id WORKER_ID,
      act4.ROWID STG_ROWID
    from
      PJI_PJP_PROJ_BATCH_MAP map,
      PJI_FM_AGGR_ACT4 act4
    where
      map.WORKER_ID = p_worker_id and
      act4.PROJECT_ID = map.PROJECT_ID;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.ACT_ROWID_TABLE(p_worker_id);');

    commit;

  end ACT_ROWID_TABLE;


  -- -----------------------------------------------------
  -- procedure PURGE_BALANCES_ACT
  --
  --
  -- NOTE: This API is called from stage 3 summarization.
  --
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure PURGE_BALANCES_ACT (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_PSI.PURGE_BALANCES_ACT(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'FULL' or
        l_extraction_type = 'INCREMENTAL' or
        l_extraction_type = 'PARTIAL') then

      delete
      from   PJI_FM_AGGR_ACT4
      where  ROWID in (select STG_ROWID
                       from   PJI_PJP_RMAP_ACR
                       where  WORKER_ID = p_worker_id);

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_PSI.PURGE_BALANCES_ACT(p_worker_id);');

    commit;

  end PURGE_BALANCES_ACT;


  -- -----------------------------------------------------
  -- procedure CLEANUP
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure CLEANUP (p_worker_id in number) is

    l_schema varchar2(30);

  begin

    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_AGGR_RES_TYPES',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_AGGR_FIN1',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_AGGR_FIN2',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_AGGR_FIN6',
                                     'NORMAL',
                                     null);

  end CLEANUP;

end PJI_FM_SUM_PSI;

/
