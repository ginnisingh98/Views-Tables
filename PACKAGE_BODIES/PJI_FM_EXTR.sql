--------------------------------------------------------
--  DDL for Package Body PJI_FM_EXTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_EXTR" as
/* $Header: PJISF06B.pls 120.9.12010000.3 2009/07/09 07:05:00 dbudhwar ship $ */

  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_FND
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_FND (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_from_project_id number := 0;
    l_to_project_id   number := 0;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_FND(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    INSERT /*+ APPEND */ INTO PJI_FM_EXTR_FUNDG
    (
     worker_id
    ,project_org_id
    ,project_organization_id
    ,project_id
    ,customer_id
    ,date_allocated
    ,funding_category
    ,pou_allocated_amount
    ,prj_allocated_amount
    ,pji_summarized_flag
    ,row_id
    ,batch_id
    )
    SELECT /*+ ordered
               full(bat)  use_hash(bat)  parallel(bat)
               full(pf)   use_hash(pf)   parallel(pf)
               full(arg)  use_hash(agr)  parallel(agr)
               full(cust) use_hash(cust) parallel(cust) */
     p_worker_id                        WORKER_ID
    ,nvl(bat.project_org_id, -1)        PROJECT_OU_ID
    ,bat.project_organization_id        PROJECT_ORG_ID
    ,pf.project_id                      PROJECT_ID
    ,agr.customer_id                                CUSTOMER_ID
    ,trunc(pf.date_allocated)                       DATE_ALLOCATED
    ,nvl(pf.funding_category,
         PJI_FM_SUM_MAIN.g_null)        FUNDING_CATEGORY
    ,pf.projfunc_allocated_amount       POU_ALLOCATED_AMOUNT
    ,pf.project_allocated_amount        PRJ_ALLOCATED_AMOUNT
    ,pf.pji_summarized_flag             PJI_SUMMARIZED_FLAG
    ,pf.rowid                           ROW_ID
    ,ceil(ROWNUM / PJI_FM_SUM_MAIN.g_commit_threshold) BATCH_ID
    FROM  pji_fm_proj_batch_map                 bat
         ,pa_project_fundings                   pf
         ,pa_agreements_all                     agr
         ,pa_project_customers                  cust
    WHERE l_extraction_type = 'FULL'
    AND   pf.agreement_id            = agr.agreement_id
    AND   pf.project_id                      = bat.project_id
    AND   bat.worker_id                      = p_worker_id
    AND   bat.extraction_type = 'F'
    AND   pf.project_id   = cust.project_id
    AND   pf.BUDGET_TYPE_CODE = 'BASELINE'
    AND   agr.customer_id  = cust.customer_id
--    AND   NVL(cust.bill_another_project_flag,'N') <> 'Y' -- ER 6519955
    AND   pf.date_allocated is not null
    union all
    SELECT /*+ ordered
               full(bat)
               index(pf,PA_PROJECT_FUNDINGS_N2)  use_nl(pf)
           */
     p_worker_id                        WORKER_ID
    ,nvl(bat.project_org_id, -1)        PROJECT_OU_ID
    ,bat.project_organization_id        PROJECT_ORG_ID
    ,pf.project_id                      PROJECT_ID
    ,agr.customer_id                                CUSTOMER_ID
    ,trunc(pf.date_allocated)                       DATE_ALLOCATED
    ,nvl(pf.funding_category,
         PJI_FM_SUM_MAIN.g_null)        FUNDING_CATEGORY
    ,pf.projfunc_allocated_amount       POU_ALLOCATED_AMOUNT
    ,pf.project_allocated_amount        PRJ_ALLOCATED_AMOUNT
    ,pf.pji_summarized_flag             PJI_SUMMARIZED_FLAG
    ,pf.rowid                           ROW_ID
    ,ceil(ROWNUM / PJI_FM_SUM_MAIN.g_commit_threshold) BATCH_ID
    FROM  pji_fm_proj_batch_map                 bat
         ,pa_project_fundings                   pf
         ,pa_agreements_all                     agr
         ,pa_project_customers                  cust
    WHERE l_extraction_type = 'INCREMENTAL'
    AND   pf.agreement_id            = agr.agreement_id
    AND   pf.project_id                      = bat.project_id
    AND   bat.worker_id                      = p_worker_id
    AND   bat.extraction_type = 'F'
    AND   pf.project_id   = cust.project_id
    AND   pf.BUDGET_TYPE_CODE = 'BASELINE'
    AND   agr.customer_id  = cust.customer_id
--    AND   NVL(cust.bill_another_project_flag,'N') <> 'Y' -- ER 6519955
    AND   pf.date_allocated is not null
    union all
    SELECT /*+ ordered
               index(pf, PA_PROJECT_FUNDINGS_N4)
           */
     p_worker_id                        WORKER_ID
    ,nvl(bat.project_org_id, -1)        PROJECT_OU_ID
    ,bat.project_organization_id        PROJECT_ORG_ID
    ,pf.project_id                      PROJECT_ID
    ,agr.customer_id                                CUSTOMER_ID
    ,trunc(pf.date_allocated)                       DATE_ALLOCATED
    ,nvl(pf.funding_category,
         PJI_FM_SUM_MAIN.g_null)        FUNDING_CATEGORY
    ,pf.projfunc_allocated_amount       POU_ALLOCATED_AMOUNT
    ,pf.project_allocated_amount        PRJ_ALLOCATED_AMOUNT
    ,pf.pji_summarized_flag             PJI_SUMMARIZED_FLAG
    ,pf.rowid                           ROW_ID
    ,ceil(ROWNUM / PJI_FM_SUM_MAIN.g_commit_threshold) BATCH_ID
    FROM  pji_fm_proj_batch_map                 bat
         ,pa_project_fundings                   pf
         ,pa_agreements_all                     agr
         ,pa_project_customers                  cust
    WHERE l_extraction_type = 'INCREMENTAL'
    AND   pf.agreement_id            = agr.agreement_id
    AND   pf.project_id                      = bat.project_id
    AND   bat.worker_id                       = p_worker_id
    AND   bat.extraction_type = 'I'
    AND   pf.pji_summarized_flag = 'N'
    AND   pf.project_id   = cust.project_id
    AND   pf.BUDGET_TYPE_CODE = 'BASELINE'
    AND   agr.customer_id  = cust.customer_id
--    AND   NVL(cust.bill_another_project_flag,'N') <> 'Y' -- ER 6519955
    AND   pf.date_allocated is not null
    union all
    SELECT /*+ ordered
               full(bat)  use_hash(bat)  parallel(bat)
               full(pf)   use_hash(pf)   parallel(pf)
               full(arg)  use_hash(agr)  parallel(ag)
               full(cust) use_hash(cust) parallel(cust)  */
     p_worker_id                        WORKER_ID
    ,nvl(bat.project_org_id, -1)        PROJECT_OU_ID
    ,bat.project_organization_id        PROJECT_ORG_ID
    ,pf.project_id                      PROJECT_ID
    ,agr.customer_id                                CUSTOMER_ID
    ,trunc(pf.date_allocated)                       DATE_ALLOCATED
    ,nvl(pf.funding_category,
         PJI_FM_SUM_MAIN.g_null)        FUNDING_CATEGORY
    ,pf.projfunc_allocated_amount       POU_ALLOCATED_AMOUNT
    ,pf.project_allocated_amount        PRJ_ALLOCATED_AMOUNT
    ,pf.pji_summarized_flag             PJI_SUMMARIZED_FLAG
    ,pf.rowid                           ROW_ID
    ,ceil(ROWNUM / PJI_FM_SUM_MAIN.g_commit_threshold) BATCH_ID
    FROM  pji_fm_proj_batch_map                 bat
         ,pa_project_fundings                   pf
         ,pa_agreements_all                     agr
         ,pa_project_customers                  cust
    WHERE l_extraction_type = 'PARTIAL'
    AND   pf.agreement_id            = agr.agreement_id
    AND   pf.project_id                      = bat.project_id
    AND   bat.worker_id                       = p_worker_id
    AND   bat.extraction_type = 'P'
    AND   pf.project_id   = cust.project_id
    AND   pf.BUDGET_TYPE_CODE = 'BASELINE'
    AND   agr.customer_id  = cust.customer_id
--    AND   NVL(cust.bill_another_project_flag,'N') <> 'Y' -- ER 6519955
    AND   pf.date_allocated is not null;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_FND(p_worker_id);');

    commit;

  end EXTRACT_BATCH_FND;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_FND_ROWS_PRE
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_FND_ROWS_PRE (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
              'PJI_FM_EXTR.MARK_EXTRACTED_FND_ROWS_PRE(p_worker_id);')) then
      return;
    end if;

    insert /*+ append */ into PJI_HELPER_BATCH_MAP
    (
      BATCH_ID,
      WORKER_ID,
      STATUS
    )
    select
      distinct
      BATCH_ID,
      null,
      null
    from
      PJI_FM_EXTR_FUNDG
    where
      PJI_SUMMARIZED_FLAG is not null;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_EXTR.MARK_EXTRACTED_FND_ROWS_PRE(p_worker_id);');

    commit;

  end MARK_EXTRACTED_FND_ROWS_PRE;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_FND_ROWS
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_FND_ROWS (p_worker_id in number) is

    l_process            varchar2(30);
    l_leftover_batches   number;
    l_helper_batch_id    number;
    l_row_count          number;
    l_parallel_processes number;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.MARK_EXTRACTED_FND_ROWS(p_worker_id);')) then
      return;
    end if;

    l_parallel_processes := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                            (PJI_FM_SUM_MAIN.g_process, 'PARALLEL_PROCESSES');

    select count(*)
    into   l_leftover_batches
    from   PJI_HELPER_BATCH_MAP
    where  WORKER_ID = p_worker_id and
           STATUS = 'P';

    l_helper_batch_id   := 0;

    while l_helper_batch_id >= 0 loop

      if (l_leftover_batches > 0) then

        l_leftover_batches := l_leftover_batches - 1;

        select  BATCH_ID
        into    l_helper_batch_id
        from    PJI_HELPER_BATCH_MAP
        where   WORKER_ID = p_worker_id and
                STATUS = 'P' and
                ROWNUM = 1;

      else

        update    PJI_HELPER_BATCH_MAP
        set       WORKER_ID = p_worker_id,
                  STATUS = 'P'
        where     WORKER_ID is null and
                  ROWNUM = 1
        returning BATCH_ID
        into      l_helper_batch_id;

      end if;

      if (sql%rowcount <> 0) then

        commit;

        update pa_project_fundings
        set    pji_summarized_flag = NULL
        where  rowid in (select /*+ cardinality(fnd, 1) */
                                fnd.row_id
                         from   PJI_FM_EXTR_FUNDG fnd
                         where  fnd.pji_summarized_flag is not null and
                                fnd.batch_id = l_helper_batch_id);

        update PJI_HELPER_BATCH_MAP
        set    STATUS = 'C'
        where  WORKER_ID = p_worker_id and
               BATCH_ID = l_helper_batch_id;

        commit;

      else

        select count(*)
        into   l_row_count
        from   PJI_HELPER_BATCH_MAP
        where  nvl(STATUS, 'X') <> 'C';

        if (l_row_count = 0) then

          for x in 2 .. l_parallel_processes loop

            update PJI_SYSTEM_PRC_STATUS
            set    STEP_STATUS = 'C'
            where  PROCESS_NAME like PJI_FM_SUM_MAIN.g_process || x and
                   STEP_NAME =
                     'PJI_FM_EXTR.MARK_EXTRACTED_FND_ROWS(p_worker_id);' and
                   START_DATE is null;

            commit;

          end loop;

          l_helper_batch_id := -1;

        else

          PJI_PROCESS_UTIL.SLEEP(1); -- so the CPU is not bombarded

        end if;

      end if;

      if (l_helper_batch_id >= 0) then

        for x in 2 .. l_parallel_processes loop
          if (not PJI_FM_SUM_EXTR.WORKER_STATUS(x, 'OKAY')) then
            l_helper_batch_id := -2;
          end if;
        end loop;

      end if;

    end loop;

    if (l_helper_batch_id <> -2) then

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
        'PJI_FM_EXTR.MARK_EXTRACTED_FND_ROWS(p_worker_id);');

    end if;

    commit;

  end MARK_EXTRACTED_FND_ROWS;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_FND_ROWS_POST
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_FND_ROWS_POST (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
              'PJI_FM_EXTR.MARK_EXTRACTED_FND_ROWS_POST(p_worker_id);')) then
      return;
    end if;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE('PJI',
                                     'PJI_HELPER_BATCH_MAP',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_EXTR.MARK_EXTRACTED_FND_ROWS_POST(p_worker_id);');

    commit;

  end MARK_EXTRACTED_FND_ROWS_POST;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_DREV
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_DREV (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_from_project_id number := 0;
    l_to_project_id   number := 0;
    l_transition_flag varchar2(1);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_DREV(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    l_transition_flag :=
          PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process,
                                                 'TRANSITION');

    INSERT /*+ APPEND */ INTO PJI_FM_EXTR_DREVN
    (
      ROW_ID
    , WORKER_ID
    , LINE_SOURCE_TYPE
    , POU_UBR
    , POU_UER
    , PROJECT_ORG_ID
    , PROJECT_ORGANIZATION_ID
    , PROJECT_ID
    , PROJECT_TYPE_CLASS
    , DRAFT_REVENUE_NUM
    , AGREEMENT_ID
    , PA_DATE
    , PA_PERIOD_NAME
    , GL_DATE
    , GL_PERIOD_NAME
    , LOG_EVENT_ID
    , PJI_SUMMARIZED_FLAG
    , CUSTOMER_ID
    , BATCH_ID
    )
      SELECT /*+ ordered
                 full(bat) use_hash(bat) parallel(bat)
                 full(drv) use_hash(drv) parallel(drv)
                 full(agr) use_hash(agr) parallel(agr) */
        drv.rowid                         row_id
      , p_worker_id                       worker_id
      , 'R'                               line_source_type
      , drv.unbilled_receivable_dr        POU_ubr
      , drv.unearned_revenue_cr           POU_uer
      , nvl(bat.project_org_id, -1)       project_org_id
      , bat.project_organization_id       project_organization_id /*also PSI */
      , drv.project_id                    project_id
      , bat.project_type_class            project_type_class
      , drv.draft_revenue_num             draft_revenue_num
      , drv.agreement_id                  agreement_id
      , drv.pa_date                       pa_date
      , drv.pa_period_name                pa_period_name
      , drv.gl_date                       gl_date
      , drv.gl_period_name                gl_period_name
      , -1                                log_event_id
      , drv.pji_summarized_flag           PJI_SUMMARIZED_FLAG
      , agr.customer_id                   customer_id
      , ceil(ROWNUM / PJI_FM_SUM_MAIN.g_commit_threshold) batch_id
      FROM
              pji_fm_proj_batch_map            bat
            , pa_draft_revenues_all            drv
            , pa_agreements_all                agr
      WHERE
            l_extraction_type = 'FULL'
        and bat.worker_id = p_worker_id
        and bat.project_id = drv.project_id
        and drv.released_date IS NOT NULL
        and drv.transfer_status_code = 'A'
        and bat.extraction_type = 'F'
        and drv.gl_date is not null
        and drv.pa_date is not null
        and agr.agreement_id = drv.agreement_id
        and ((nvl(l_transition_flag, 'N') = 'N') or
             (nvl(l_transition_flag, 'N') = 'Y' and
              nvl(drv.pji_summarized_flag, 'Y') <> 'N'))
      union all
      SELECT /*+ ordered
                 full(bat)
                 index(drv, PA_DRAFT_REVENUES_U1)   use_nl(drv)
             */
        drv.rowid                         row_id
      , p_worker_id                       worker_id
      , 'R'                               line_source_type
      , drv.unbilled_receivable_dr        POU_ubr
      , drv.unearned_revenue_cr           POU_uer
      , nvl(bat.project_org_id, -1)       project_org_id
      , bat.project_organization_id       project_organization_id /*also PSI */
      , drv.project_id                    project_id
      , bat.project_type_class            project_type_class
      , drv.draft_revenue_num             draft_revenue_num
      , drv.agreement_id                  agreement_id
      , drv.pa_date                       pa_date
      , drv.pa_period_name                pa_period_name
      , drv.gl_date                       gl_date
      , drv.gl_period_name                gl_period_name
      , -1                                log_event_id
      , drv.pji_summarized_flag           PJI_SUMMARIZED_FLAG
      , agr.customer_id                   customer_id
      , ceil(ROWNUM / PJI_FM_SUM_MAIN.g_commit_threshold) batch_id
      FROM
              pji_fm_proj_batch_map            bat
            , pa_draft_revenues_all            drv
            , pa_agreements_all                agr
      WHERE
            l_extraction_type = 'INCREMENTAL'
        and bat.worker_id = p_worker_id
        and bat.project_id = drv.project_id
        and drv.released_date IS NOT NULL
        and drv.transfer_status_code = 'A'
        and bat.extraction_type = 'F'
        and drv.gl_date is not null
        and drv.pa_date is not null
        and agr.agreement_id = drv.agreement_id
      union all
      SELECT /*+ ordered
                 full(bat) use_hash(bat)
                 index(drv,PA_DRAFT_REVENUES_N12)
             */
        drv.rowid                         row_id
      , p_worker_id                       worker_id
      , 'R'                               line_source_type
      , drv.unbilled_receivable_dr        POU_ubr
      , drv.unearned_revenue_cr           POU_uer
      , nvl(bat.project_org_id, -1)       project_org_id
      , bat.project_organization_id       project_organization_id /*also PSI */
      , drv.project_id                    project_id
      , bat.project_type_class            project_type_class
      , drv.draft_revenue_num             draft_revenue_num
      , drv.agreement_id                  agreement_id
      , drv.pa_date                       pa_date
      , drv.pa_period_name                pa_period_name
      , drv.gl_date                       gl_date
      , drv.gl_period_name                gl_period_name
      , -1                                log_event_id
      , drv.pji_summarized_flag           PJI_SUMMARIZED_FLAG
      , agr.customer_id                   customer_id
      , ceil(ROWNUM / PJI_FM_SUM_MAIN.g_commit_threshold) batch_id
      FROM
              pji_fm_proj_batch_map            bat
            , pa_draft_revenues_all            drv
            , pa_agreements_all                agr
      WHERE
            l_extraction_type = 'INCREMENTAL'
        and bat.worker_id = p_worker_id
        and bat.project_id = drv.project_id
        and drv.released_date IS NOT NULL
        and drv.transfer_status_code = 'A'
        and bat.extraction_type = 'I'
        and drv.pji_summarized_flag = 'N'
        and drv.gl_date is not null
        and drv.pa_date is not null
        and agr.agreement_id = drv.agreement_id
      union all
      SELECT /*+ ordered
                 full(bat) use_hash(bat)   parallel(bat)
                 full(drv) use_hash(drv)   parallel(drv)
                 full(agr) use_hash(agr)   parallel(agr)  */
        drv.rowid                         row_id
      , p_worker_id                       worker_id
      , 'R'                               line_source_type
      , drv.unbilled_receivable_dr        POU_ubr
      , drv.unearned_revenue_cr           POU_uer
      , nvl(bat.project_org_id, -1)       project_org_id
      , bat.project_organization_id       project_organization_id /*also PSI */
      , drv.project_id                    project_id
      , bat.project_type_class            project_type_class
      , drv.draft_revenue_num             draft_revenue_num
      , drv.agreement_id                  agreement_id
      , drv.pa_date                       pa_date
      , drv.pa_period_name                pa_period_name
      , drv.gl_date                       gl_date
      , drv.gl_period_name                gl_period_name
      , -1                                log_event_id
      , drv.pji_summarized_flag           PJI_SUMMARIZED_FLAG
      , agr.customer_id                   customer_id
      , ceil(ROWNUM / PJI_FM_SUM_MAIN.g_commit_threshold) batch_id
      FROM
              pji_fm_proj_batch_map            bat
            , pa_draft_revenues_all            drv
            , pa_agreements_all                agr
      WHERE
            l_extraction_type = 'PARTIAL'
        and bat.worker_id = p_worker_id
        and bat.project_id = drv.project_id
        and drv.released_date IS NOT NULL
        and drv.transfer_status_code = 'A'
        and bat.extraction_type = 'P'
        and drv.gl_date is not null
        and drv.pa_date is not null
        and agr.agreement_id = drv.agreement_id
      union all
      SELECT  /*+ ordered
                  index(log, PA_PJI_PROJ_EVENTS_LOG_N1)
                  full(imp)    use_hash(imp)
                  full(paprd)  use_hash(paprd)
                  full(glprd)  use_hash(glprd)
                  full(sob)    use_hash(sob)
              */
        log.rowid                    row_id
      , p_worker_id                  worker_id
      , 'L'                          line_source_type
      , -to_number(log.attribute2)   POU_ubr
      , -to_number(log.attribute3)   POU_uer
      , nvl(bat.project_org_id, -1)  project_org_id
      , bat.project_organization_id  project_organization_id /* also PSI */
      , to_number(log.event_object)  project_id
      , bat.project_type_class       project_type_class
      , to_number(log.attribute1)    draft_revenue_num
      , to_number(log.attribute4)    agreement_id
      , to_date(log.attribute5, PJI_FM_SUM_MAIN.g_date_mask) pa_date
      , paprd.period_name                                    pa_period_name
      , to_date(log.attribute6, PJI_FM_SUM_MAIN.g_date_mask) gl_date
      , glprd.period_name                                    gl_period_name
      , log.event_id                 log_event_id
      , null                         pji_summarized_flag
      , agr.customer_id              customer_id
      , ceil(ROWNUM / PJI_FM_SUM_MAIN.g_commit_threshold) batch_id
      FROM
              pa_pji_proj_events_log           log
            , pji_fm_proj_batch_map            bat
            , pa_agreements_all                agr
     /* Note:
      * The tables below are not needed if Billing Team
      * populates the PA and GL period_names while
      * inserting records into the log table
      */
            , pa_implementations_all           imp
            , gl_periods                       paprd
            , gl_periods                       glprd
            , gl_sets_of_books                 sob
      WHERE
            l_extraction_type = 'INCREMENTAL'
        and bat.worker_id   = p_worker_id
        and bat.project_id = log.event_object
        and log.event_type = 'DRAFT_REVENUES'
        and log.attribute5 is not null
        and log.attribute6 is not null
        and agr.agreement_id = to_number(log.attribute4)
        and bat.extraction_type = 'I'
        and nvl(bat.PROJECT_ORG_ID,-1) = nvl(imp.org_id ,-1)
        and imp.period_set_name = paprd.period_set_name
        and imp.pa_period_type = paprd.period_type
        and to_date(log.attribute5, PJI_FM_SUM_MAIN.g_date_mask)
            between paprd.START_DATE and paprd.END_DATE
        and imp.period_set_name = glprd.period_set_name
        and imp.set_of_books_id = sob.set_of_books_id
        and sob.accounted_period_type = glprd.period_type
        and to_date(log.attribute6, PJI_FM_SUM_MAIN.g_date_mask)
            between glprd.START_DATE and glprd.END_DATE
        ;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_DREV(p_worker_id);');

    commit;

  end EXTRACT_BATCH_DREV;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_DREV_PRE
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_DREV_PRE (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
              'PJI_FM_EXTR.MARK_EXTRACTED_DREV_PRE(p_worker_id);')) then
      return;
    end if;

    insert /*+ append */ into PJI_HELPER_BATCH_MAP
    (
      BATCH_ID,
      WORKER_ID,
      STATUS
    )
    select
      distinct
      BATCH_ID,
      null,
      null
    from
      PJI_FM_EXTR_DREVN
    where
      (LINE_SOURCE_TYPE = 'R' and
       PJI_SUMMARIZED_FLAG is not null) or
      (LINE_SOURCE_TYPE = 'L');

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_EXTR.MARK_EXTRACTED_DREV_PRE(p_worker_id);');

    commit;

  end MARK_EXTRACTED_DREV_PRE;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_DREV
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_DREV (p_worker_id in number) is

    l_process            varchar2(30);
    l_leftover_batches   number;
    l_helper_batch_id    number;
    l_row_count          number;
    l_parallel_processes number;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.MARK_EXTRACTED_DREV(p_worker_id);')) then
      return;
    end if;

    l_parallel_processes := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                            (PJI_FM_SUM_MAIN.g_process, 'PARALLEL_PROCESSES');

    select count(*)
    into   l_leftover_batches
    from   PJI_HELPER_BATCH_MAP
    where  WORKER_ID = p_worker_id and
           STATUS = 'P';

    l_helper_batch_id   := 0;

    while l_helper_batch_id >= 0 loop

      if (l_leftover_batches > 0) then

        l_leftover_batches := l_leftover_batches - 1;

        select  BATCH_ID
        into    l_helper_batch_id
        from    PJI_HELPER_BATCH_MAP
        where   WORKER_ID = p_worker_id and
                STATUS = 'P' and
                ROWNUM = 1;

      else

        update    PJI_HELPER_BATCH_MAP
        set       WORKER_ID = p_worker_id,
                  STATUS = 'P'
        where     WORKER_ID is null and
                  ROWNUM = 1
        returning BATCH_ID
        into      l_helper_batch_id;

      end if;

      if (sql%rowcount <> 0) then

        commit;

        UPDATE pa_draft_revenues_all    drv
        SET    drv.pji_summarized_flag = null
        WHERE  drv.rowid in (select /*+ cardinality(drvn, 1) */
                                    drvn.row_id
                             from   PJI_FM_EXTR_DREVN drvn
                             where  drvn.pji_summarized_flag is not null
                               and  drvn.LINE_SOURCE_TYPE = 'R'
                               and  drvn.batch_id = l_helper_batch_id);

        -- Clean up log table

        DELETE pa_pji_proj_events_log
        WHERE  rowid in (select row_id
                         from   PJI_FM_EXTR_DREVN
                         where  line_source_type = 'L'
                           and  batch_id = l_helper_batch_id);

        update PJI_HELPER_BATCH_MAP
        set    STATUS = 'C'
        where  WORKER_ID = p_worker_id and
               BATCH_ID = l_helper_batch_id;

        commit;

      else

        select count(*)
        into   l_row_count
        from   PJI_HELPER_BATCH_MAP
        where  nvl(STATUS, 'X') <> 'C';

        if (l_row_count = 0) then

          for x in 2 .. l_parallel_processes loop

            update PJI_SYSTEM_PRC_STATUS
            set    STEP_STATUS = 'C'
            where  PROCESS_NAME like PJI_FM_SUM_MAIN.g_process || x and
                   STEP_NAME =
                     'PJI_FM_EXTR.MARK_EXTRACTED_DREV(p_worker_id);' and
                   START_DATE is null;

            commit;

          end loop;

          l_helper_batch_id := -1;

        else

          PJI_PROCESS_UTIL.SLEEP(1); -- so the CPU is not bombarded

        end if;

      end if;

      if (l_helper_batch_id >= 0) then

        for x in 2 .. l_parallel_processes loop
          if (not PJI_FM_SUM_EXTR.WORKER_STATUS(x, 'OKAY')) then
            l_helper_batch_id := -2;
          end if;
        end loop;

      end if;

    end loop;

    if (l_helper_batch_id <> -2) then

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
        'PJI_FM_EXTR.MARK_EXTRACTED_DREV(p_worker_id);');

    end if;

    commit;

  end MARK_EXTRACTED_DREV;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_DREV_POST
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_DREV_POST (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
              'PJI_FM_EXTR.MARK_EXTRACTED_DREV_POST(p_worker_id);')) then
      return;
    end if;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE('PJI',
                                     'PJI_HELPER_BATCH_MAP',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_EXTR.MARK_EXTRACTED_DREV_POST(p_worker_id);');

    commit;

  end MARK_EXTRACTED_DREV_POST;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_CDL_CRDL_FULL
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_CDL_CRDL_FULL(p_worker_id in number) is

    l_process          varchar2(30);
    l_from_project_id  number := 0;
    l_to_project_id    number := 0;
    l_min_date         date;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_CDL_CRDL_FULL(p_worker_id);')) then
      return;
    end if;

    l_min_date := to_date(PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE'),
                          PJI_FM_SUM_MAIN.g_date_mask);

    if ( PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE') = 'FULL') then

      -- This cleanup is intentionally before the implicit commit so as not
      -- to interfere with the CDL extraction.
      if (nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
              (PJI_FM_SUM_MAIN.g_process, 'CONFIG_PROJ_PERF_FLAG'),
              'N') = 'N' and
          nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
              (PJI_FM_SUM_MAIN.g_process, 'CONFIG_COST_FLAG'),
              'N') = 'N' and
          nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
              (PJI_FM_SUM_MAIN.g_process, 'CONFIG_PROFIT_FLAG'),
              'N') = 'N') then
        delete /*+ index (log, PA_PJI_PROJ_EVENTS_LOG_N1) */
        from   PA_PJI_PROJ_EVENTS_LOG log
        where  EVENT_TYPE = 'DRAFT_REVENUES';
      end if;

      if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                 'CURRENT_BATCH') = 1) then
      -- implicit commit
      FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                   tabname => 'PJI_FM_EXTR_DREVN',
                                   percent => 10,
                                   degree  => PJI_UTILS.
                                              GET_DEGREE_OF_PARALLELISM);
      -- implicit commit
      FND_STATS.GATHER_COLUMN_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                    tabname => 'PJI_FM_EXTR_DREVN',
                                    colname => 'PROJECT_ID',
                                    percent => 10,
                                    degree  => PJI_UTILS.
                                               GET_DEGREE_OF_PARALLELISM);
      end if;

      INSERT /*+ APPEND PARALLEL(fin1_i) */ INTO PJI_FM_AGGR_FIN1 fin1_i
       ( WORKER_ID
       , SLICE_ID
       , PROJECT_ID
       , TASK_ID
       , PERSON_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_TYPE_CLASS
       , CUSTOMER_ID
       , EXPENDITURE_ORG_ID
       , EXPENDITURE_ORGANIZATION_ID
       , JOB_ID
       , VENDOR_ID
       , WORK_TYPE_ID
       , EXP_EVT_TYPE_ID
       , EXPENDITURE_TYPE
       , EVENT_TYPE
       , EVENT_TYPE_CLASSIFICATION
       , EXPENDITURE_CATEGORY
       , REVENUE_CATEGORY
       , NON_LABOR_RESOURCE
       , BOM_LABOR_RESOURCE_ID
       , BOM_EQUIPMENT_RESOURCE_ID
       , INVENTORY_ITEM_ID
       , PO_LINE_ID
       , ASSIGNMENT_ID
       , SYSTEM_LINKAGE_FUNCTION
       , PJI_PROJECT_RECORD_FLAG
       , PJI_RESOURCE_RECORD_FLAG
       , CODE_COMBINATION_ID
       , PRVDR_GL_DATE
       , RECVR_GL_DATE
       , GL_PERIOD_NAME
       , PRVDR_PA_DATE
       , RECVR_PA_DATE
       , PA_PERIOD_NAME
       , EXPENDITURE_ITEM_DATE
       , TXN_CURRENCY_CODE
       , TXN_REVENUE
       , TXN_RAW_COST
       , TXN_BILL_RAW_COST
       , TXN_BURDENED_COST
       , TXN_BILL_BURDENED_COST
       , TXN_UBR
       , TXN_UER
       , PRJ_REVENUE
       , PRJ_RAW_COST
       , PRJ_BILL_RAW_COST
       , PRJ_BURDENED_COST
       , PRJ_BILL_BURDENED_COST
       , PRJ_UBR
       , PRJ_UER
       , POU_REVENUE
       , POU_RAW_COST
       , POU_BILL_RAW_COST
       , POU_BURDENED_COST
       , POU_BILL_BURDENED_COST
       , POU_UBR
       , POU_UER
       , EOU_RAW_COST
       , EOU_BILL_RAW_COST
       , EOU_BURDENED_COST
       , EOU_BILL_BURDENED_COST
       , EOU_UBR
       , EOU_UER
       , QUANTITY
       , BILL_QUANTITY
       )
       SELECT
          grp.WORKER_ID
        , grp.SLICE_ID
        , grp.PROJECT_ID
        , grp.TASK_ID
        , grp.PERSON_ID
        , grp.PROJECT_ORG_ID
        , grp.PROJECT_ORGANIZATION_ID
        , grp.PROJECT_TYPE_CLASS
        , grp.CUSTOMER_ID
        , grp.EXPENDITURE_ORG_ID
        , grp.EXPENDITURE_ORGANIZATION_ID
        , grp.JOB_ID
        , grp.VENDOR_ID
        , grp.WORK_TYPE_ID
        , grp.EXP_EVT_TYPE_ID
        , grp.EXPENDITURE_TYPE
        , grp.EVENT_TYPE
        , grp.EVENT_TYPE_CLASSIFICATION
        , grp.EXPENDITURE_CATEGORY
        , grp.REVENUE_CATEGORY
        , grp.NON_LABOR_RESOURCE
        , grp.BOM_LABOR_RESOURCE_ID
        , grp.BOM_EQUIPMENT_RESOURCE_ID
        , grp.INVENTORY_ITEM_ID
        , grp.PO_LINE_ID
        , grp.ASSIGNMENT_ID
        , grp.SYSTEM_LINKAGE_FUNCTION
        , grp.PJI_PROJECT_RECORD_FLAG
        , grp.PJI_RESOURCE_RECORD_FLAG
        , grp.CODE_COMBINATION_ID
        , grp.PRVDR_GL_DATE
        , grp.RECVR_GL_DATE
        , grp.GL_PERIOD_NAME
        , grp.PRVDR_PA_DATE
        , grp.RECVR_PA_DATE
        , grp.PA_PERIOD_NAME
        , grp.EXPENDITURE_ITEM_DATE
        , grp.TXN_CURRENCY_CODE
        , sum(grp.TXN_REVENUE)
        , sum(grp.TXN_RAW_COST)
        , sum(grp.TXN_BILL_RAW_COST)
        , sum(grp.TXN_BURDENED_COST)
        , sum(grp.TXN_BILL_BURDENED_COST)
        , sum(grp.TXN_UBR)
        , sum(grp.TXN_UER)
        , sum(grp.PRJ_REVENUE)
        , sum(grp.PRJ_RAW_COST)
        , sum(grp.PRJ_BILL_RAW_COST)
        , sum(grp.PRJ_BURDENED_COST)
        , sum(grp.PRJ_BILL_BURDENED_COST)
        , sum(grp.PRJ_UBR)
        , sum(grp.PRJ_UER)
        , sum(grp.POU_REVENUE)
        , sum(grp.POU_RAW_COST)
        , sum(grp.POU_BILL_RAW_COST)
        , sum(grp.POU_BURDENED_COST)
        , sum(grp.POU_BILL_BURDENED_COST)
        , sum(grp.POU_UBR)
        , sum(grp.POU_UER)
        , sum(grp.EOU_RAW_COST)
        , sum(grp.EOU_BILL_RAW_COST)
        , sum(grp.EOU_BURDENED_COST)
        , sum(grp.EOU_BILL_BURDENED_COST)
        , sum(grp.EOU_UBR)
        , sum(grp.EOU_UER)
        , sum(grp.QUANTITY)
        , sum(grp.BILL_QUANTITY)
       FROM (
       SELECT /*+ ORDERED
                  use_hash(CnR,et,exp,ei)
                  swap_join_inputs(exp)
                  swap_join_inputs(ei)
                  swap_join_inputs(et)
                  PARALLEL(exp) PARALLEL(ei) PARALLEL(et) */
          p_worker_id                           AS WORKER_ID
          , 1                                   AS SLICE_ID
          , CnR.Project_ID                      AS PROJECT_ID
          , ei.Task_ID                          AS TASK_ID
          , decode(exp.Incurred_BY_Person_ID,
                   null, -1, 0, -1,
                   exp.Incurred_BY_Person_ID)   AS PERSON_ID
          , map.Project_Org_ID                  AS PROJECT_ORG_ID
          , map.Project_Organization_ID         AS PROJECT_ORGANIZATION_ID
          , map.Project_Type_Class              AS PROJECT_TYPE_CLASS
          , CnR.Customer_ID                     AS CUSTOMER_ID
          , decode(CnR.C_or_R
                   , 'COST', CnR.Expenditure_Org_ID
                   , ei.org_id)                 AS EXPENDITURE_ORG_ID
          , nvl(ei.Override_TO_Organization_ID,
               exp.Incurred_BY_Organization_ID) AS EXPENDITURE_ORGANIZATION_ID
      --    , CnR.Expenditure_Item_ID             AS EXPENDITURE_ITEM_ID
          , nvl(ei.Job_ID, -1)                  AS JOB_ID
          , nvl(exp.Vendor_ID,-1)               AS VENDOR_ID
          , decode(CnR.C_or_R,
                   'COST', nvl(CnR.Work_Type_Id,-1),
                   nvl(ei.Work_Type_Id, -1))    AS WORK_TYPE_ID
          , et.Expenditure_Type_ID              AS EXP_EVT_TYPE_ID
          , et.Expenditure_Type                 AS EXPENDITURE_TYPE
          , PJI_FM_SUM_MAIN.g_null              AS EVENT_TYPE
          , PJI_FM_SUM_MAIN.g_null              AS EVENT_TYPE_CLASSIFICATION
          , et.Expenditure_Category             AS EXPENDITURE_CATEGORY
          , et.Revenue_Category_Code            AS REVENUE_CATEGORY
          , ei.Non_Labor_Resource               AS NON_LABOR_RESOURCE
          , ei.Wip_Resource_ID                  AS BOM_LABOR_RESOURCE_ID
          , ei.Wip_Resource_ID                  AS BOM_EQUIPMENT_RESOURCE_ID
          , ei.Inventory_Item_ID                AS INVENTORY_ITEM_ID
          , ei.PO_Line_ID                       AS PO_LINE_ID
          , decode(ei.Assignment_ID,
                   null, -1, 0, -1,
                   ei.Assignment_ID)            AS ASSIGNMENT_ID
          , NVL(ei.src_system_linkage_function,
                ei.system_linkage_function)     AS SYSTEM_LINKAGE_FUNCTION
          , decode(CnR.C_or_R,
                   'COST', 'Y',
                   'REVENUE', 'Y', 'N')         AS PJI_PROJECT_RECORD_FLAG
          , decode(exp.Incurred_BY_Person_ID,
                   null, 'N',
                   0, 'N',
                   decode(CnR.C_or_R,
                          'COST', 'Y',
                          'REVENUE', 'Y',
                          'N'))                 AS PJI_RESOURCE_RECORD_FLAG
          , -1                                  AS CODE_COMBINATION_ID
          , greatest(CnR.Prvdr_GL_Date,l_min_date) AS PRVDR_GL_DATE
          , greatest(CnR.Recvr_GL_Date,l_min_date) AS RECVR_GL_DATE
          , CnR.GL_Period_Name                     AS GL_PERIOD_NAME
          , greatest(CnR.Prvdr_PA_Date,l_min_date) AS PRVDR_PA_DATE
          , greatest(CnR.Recvr_PA_Date,l_min_date) AS RECVR_PA_DATE
          , CnR.PA_Period_Name                     AS PA_PERIOD_NAME
          , greatest(ei.Expenditure_Item_Date,
                     l_min_date)                AS EXPENDITURE_ITEM_DATE
          , CnR.Txn_Currency_Code               AS TXN_CURRENCY_CODE
          , CnR.Txn_Revenue                     AS TXN_REVENUE
          , CnR.Txn_Raw_Cost                    AS TXN_RAW_COST
          , CnR.Txn_Bill_Raw_Cost               AS TXN_BILL_RAW_COST
          , CnR.Txn_Burdened_Cost               AS TXN_BURDENED_COST
          , CnR.Txn_Bill_Burdened_Cost          AS TXN_BILL_BURDENED_COST
          , CnR.Txn_Ubr                         AS TXN_UBR
          , CnR.Txn_Uer                         AS TXN_UER
          , CnR.Prj_Revenue                     AS PRJ_REVENUE
          , CnR.Prj_Raw_Cost                    AS PRJ_RAW_COST
          , CnR.Prj_Bill_Raw_Cost               AS PRJ_BILL_RAW_COST
          , CnR.Prj_Burdened_Cost               AS PRJ_BURDENED_COST
          , CnR.Prj_Bill_Burdened_Cost          AS PRJ_BILL_BURDENED_COST
          , CnR.Prj_Ubr                         AS PRJ_UBR
          , CnR.Prj_Uer                         AS PRJ_UER
          , CnR.Pou_Revenue                     AS POU_REVENUE
          , CnR.Pou_Raw_Cost                    AS POU_RAW_COST
          , CnR.Pou_Bill_Raw_Cost               AS POU_BILL_RAW_COST
          , CnR.Pou_Burdened_Cost               AS POU_BURDENED_COST
          , CnR.Pou_Bill_Burdened_Cost          AS POU_BILL_BURDENED_COST
          , CnR.Pou_Ubr                         AS POU_UBR
          , CnR.Pou_Uer                         AS POU_UER
          , CnR.Eou_Raw_Cost                    AS EOU_RAW_COST
          , CnR.Eou_Bill_Raw_Cost               AS EOU_BILL_RAW_COST
          , CnR.Eou_Burdened_Cost               AS EOU_BURDENED_COST
          , CnR.Eou_Bill_Burdened_Cost          AS EOU_BILL_BURDENED_COST
          , CnR.Eou_Ubr                         AS EOU_UBR
          , CnR.Eou_Uer                         AS EOU_UER
          , CnR.Quantity                        AS QUANTITY
          , CnR.Bill_Quantity                   AS BILL_QUANTITY
       FROM
         pji_fm_proj_batch_map map,
        (
        Select /*+ FULL(cdl) PARALLEL(cdl) */
          'COST'                                AS C_or_R
          , cdl.Project_ID                      AS PROJECT_ID
          , cdl.Task_ID                         AS TASK_ID
          , -1                                  AS CUSTOMER_ID
          , cdl.Org_ID                          AS EXPENDITURE_ORG_ID
          , cdl.Expenditure_Item_ID             AS EXPENDITURE_ITEM_ID
  ---     , nvl(to_number(cdl.System_Reference1),-1) AS VENDOR_ID
          , cdl.work_type_id                    AS WORK_TYPE_ID
          , cdl.GL_Date                         AS PRVDR_GL_DATE
          , nvl(cdl.Recvr_GL_Date,cdl.GL_Date)  AS RECVR_GL_DATE
          , cdl.Recvr_GL_Period_Name            AS GL_PERIOD_NAME
          , cdl.PA_DATE                         AS PRVDR_PA_DATE
          , nvl(cdl.Recvr_PA_Date,cdl.PA_Date)  AS RECVR_PA_DATE
          , cdl.Recvr_PA_Period_Name            AS PA_PERIOD_NAME
          , cdl.Denom_Currency_Code             AS TXN_CURRENCY_CODE
          , to_number(null)                     AS TXN_REVENUE
          , nvl(cdl.Denom_Raw_Cost, 0)          AS TXN_RAW_COST
          , decode(cdl.billable_flag
                   , 'Y', nvl(cdl.Denom_Raw_Cost, 0)
                   , 0)                         AS TXN_BILL_RAW_COST
          , nvl(cdl.Denom_Burdened_Cost, 0)     AS TXN_BURDENED_COST
          , decode(cdl.Billable_Flag
                   , 'Y', nvl(cdl.Denom_Burdened_Cost, 0)
                   , 0)                         AS TXN_BILL_BURDENED_COST
          , to_number(null)                     AS TXN_UBR
          , to_number(null)                     AS TXN_UER
          , to_number(null)                     AS PRJ_REVENUE
          , nvl(cdl.Project_Raw_Cost, 0)        AS PRJ_RAW_COST
          , decode(cdl.billable_flag
                   , 'Y', nvl(cdl.Project_Raw_Cost, 0)
                   , 0)                         AS PRJ_BILL_RAW_COST
          , nvl(cdl.Project_Burdened_Cost, 0)   AS PRJ_BURDENED_COST
          , decode(cdl.Billable_Flag
                   , 'Y', nvl(cdl.Project_Burdened_Cost, 0)
                   , 0)                         AS PRJ_BILL_BURDENED_COST
          , to_number(null)                     AS PRJ_UBR
          , to_number(null)                     AS PRJ_UER
          , to_number(null)                     AS POU_REVENUE
          , cdl.AMOUNT                          AS POU_RAW_COST
          , decode(cdl.bILLABLE_fLAG
                   , 'Y', nvl(cdl.Amount, 0)
                   , 0)                         AS POU_BILL_RAW_COST
          , nvl(cdl.Burdened_Cost, 0)           AS POU_BURDENED_COST
          , decode(cdl.Billable_Flag
                   , 'Y', nvl(cdl.Burdened_Cost, 0)
                   , 0)                         AS POU_BILL_BURDENED_COST
          , to_number(null)                     AS POU_UBR
          , to_number(null)                     AS POU_UER
          , nvl(cdl.Acct_Raw_Cost, 0)           AS EOU_RAW_COST
          , decode(cdl.Billable_Flag
                   , 'Y', nvl(cdl.Acct_Raw_Cost,0)
                   , 0)                         AS EOU_BILL_RAW_COST
          , nvl(cdl.Acct_Burdened_Cost, 0)      AS EOU_BURDENED_COST
          , decode(cdl.Billable_Flag
                   , 'Y', nvl(cdl.Acct_Burdened_Cost, 0)
                   , 0)                         AS EOU_BILL_BURDENED_COST
          , to_number(null)                     AS EOU_UBR
          , to_number(null)                     AS EOU_UER
          , cdl.Quantity                        AS QUANTITY
          , decode(cdl.Billable_Flag
                   , 'Y', cdl.Quantity
                   , 0)                         AS BILL_QUANTITY
        From  pa_cost_distribution_lines_all   cdl
        Where 1 = 1
        And   cdl.line_type in ('R','I')
        And   nvl(cdl.pji_summarized_flag,'Y') <> 'N'
        And   cdl.gl_date is not null
        And   cdl.pa_date is not null
        UNION ALL
        Select /*+ ORDERED
                   FULL(ag)   PARALLEL(ag)   use_hash(ag)
                   FULL(cust) PARALLEL(cust) use_hash(cust)
                   FULL(drev) PARALLEL(drev) use_hash(drev)
                   FULL(crdl) PARALLEL(crdl) use_hash(crdl) */
          'REVENUE'                             AS C_or_R
          , crdl.Project_ID                     AS PROJECT_ID
          , -1                                  AS TASK_ID
          , cust.Customer_ID                    AS CUSTOMER_ID
          , -1                                  AS EXPENDITURE_ORG_ID
          , crdl.Expenditure_Item_ID            AS EXPENDITURE_ITEM_ID
    ---   , -1                                  AS VENDOR_ID
          , -1                                  AS WORK_TYPE_ID
          , drev.GL_Date                        AS PRVDR_GL_DATE
          , drev.GL_Date                        AS RECVR_GL_DATE
          , drev.GL_Period_Name                 AS GL_PERIOD_NAME
          , drev.PA_Date                        AS PRVDR_PA_DATE
          , drev.PA_Date                        AS RECVR_PA_DATE
          , drev.PA_Period_Name                 AS PA_PERIOD_NAME
          , crdl.Funding_Currency_Code          AS TXN_CURRENCY_CODE
          , crdl.Funding_Revenue_Amount         AS TXN_REVENUE
          , to_number(null)                     AS TXN_RAW_COST
          , to_number(null)                     AS TXN_BILL_RAW_COST
          , to_number(null)                     AS TXN_BURDENED_COST
          , to_number(null)                     AS TXN_BILL_BURDENED_COST
          , to_number(null)                     AS TXN_UBR
          , to_number(null)                     AS TXN_UER
          , crdl.Project_Revenue_Amount         AS PRJ_REVENUE
          , to_number(null)                     AS PRJ_RAW_COST
          , to_number(null)                     AS PRJ_BILL_RAW_COST
          , to_number(null)                     AS PRJ_BURDENED_COST
          , to_number(null)                     AS PRJ_BILL_BURDENED_COST
          , to_number(null)                     AS PRJ_UBR
          , to_number(null)                     AS PRJ_UER
          , crdl.Projfunc_Revenue_Amount        AS POU_REVENUE
          , to_number(null)                     AS POU_RAW_COST
          , to_number(null)                     AS POU_BILL_RAW_COST
          , to_number(null)                     AS POU_BURDENED_COST
          , to_number(null)                     AS POU_BILL_BURDENED_COST
          , to_number(null)                     AS POU_UBR
          , to_number(null)                     AS POU_UER
          , to_number(null)                     AS EOU_RAW_COST
          , to_number(null)                     AS EOU_BILL_RAW_COST
          , to_number(null)                     AS EOU_BURDENED_COST
          , to_number(null)                     AS EOU_BILL_BURDENED_COST
          , to_number(null)                     AS EOU_UBR
          , to_number(null)                     AS EOU_UER
          , to_number(null)                     AS QUANTITY
          , to_number(null)                     AS BILL_QUANTITY
        From  PJI_FM_EXTR_DREVN            drev
              , pa_agreements_all          ag
              , pa_project_customers       cust
              , pa_cust_rev_dist_lines_all crdl
        Where 1 = 1
        And   drev.worker_id = p_worker_id
        And   drev.project_id = crdl.project_id
        And   drev.draft_revenue_num = crdl.draft_revenue_num
        And   drev.agreement_id = ag.agreement_id
        And   drev.project_id = cust.project_id
        And   ag.customer_id = cust.customer_id
--        And   NVL(cust.bill_another_project_flag,'N') <> 'Y' -- ER 6519955
        And   crdl.function_code NOT IN ('LRL','LRB','URL','URB')
        And   drev.gl_date is not null
        And   drev.pa_date is not null
      )                                       CnR
            , pa_expenditure_items_all        ei
            , pa_expenditures_all             exp
            , pa_expenditure_types            et
       WHERE  1 = 1
       And    CnR.expenditure_item_id = ei.expenditure_item_id
       And    exp.expenditure_id = ei.expenditure_id
       And    ei.expenditure_type = et.expenditure_type
       And    CnR.project_id = map.project_id
--       And    (NVL(ei.transaction_source,'dummy') <> 'INTERPROJECT_AP_INVOICES'  -- ER 6519955
--               OR CnR.C_or_R = 'REVENUE')
       )  grp
       GROUP BY
          grp.WORKER_ID
        , grp.SLICE_ID
        , grp.PROJECT_ID
        , grp.TASK_ID
        , grp.PERSON_ID
        , grp.PROJECT_ORG_ID
        , grp.PROJECT_ORGANIZATION_ID
        , grp.PROJECT_TYPE_CLASS
        , grp.CUSTOMER_ID
        , grp.EXPENDITURE_ORG_ID
        , grp.EXPENDITURE_ORGANIZATION_ID
        , grp.JOB_ID
        , grp.VENDOR_ID
        , grp.WORK_TYPE_ID
        , grp.EXP_EVT_TYPE_ID
        , grp.EXPENDITURE_TYPE
        , grp.EVENT_TYPE
        , grp.EVENT_TYPE_CLASSIFICATION
        , grp.EXPENDITURE_CATEGORY
        , grp.REVENUE_CATEGORY
        , grp.NON_LABOR_RESOURCE
        , grp.BOM_LABOR_RESOURCE_ID
        , grp.BOM_EQUIPMENT_RESOURCE_ID
        , grp.INVENTORY_ITEM_ID
        , grp.PO_LINE_ID
        , grp.ASSIGNMENT_ID
        , grp.SYSTEM_LINKAGE_FUNCTION
        , grp.PJI_PROJECT_RECORD_FLAG
        , grp.PJI_RESOURCE_RECORD_FLAG
        , grp.CODE_COMBINATION_ID
        , grp.PRVDR_GL_DATE
        , grp.RECVR_GL_DATE
        , grp.GL_PERIOD_NAME
        , grp.PRVDR_PA_DATE
        , grp.RECVR_PA_DATE
        , grp.PA_PERIOD_NAME
        , grp.EXPENDITURE_ITEM_DATE
        , grp.TXN_CURRENCY_CODE
      ;

    end if;  -- EXTRACTION_TYPE = 'FULL'

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_CDL_CRDL_FULL(p_worker_id);');

    commit;

  end EXTRACT_BATCH_CDL_CRDL_FULL;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_ERDL_FULL
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_ERDL_FULL(p_worker_id in number) is

    l_process         varchar2(30);
    l_from_project_id number := 0;
    l_to_project_id   number := 0;
    l_min_date        date;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_ERDL_FULL(p_worker_id);')) then
      return;
    end if;

    l_min_date := to_date(PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE'),
                          PJI_FM_SUM_MAIN.g_date_mask);

    if ( PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE') = 'FULL') then

      -- insert for erdl
      INSERT /*+ APPEND */ INTO PJI_FM_AGGR_FIN1
       ( WORKER_ID
       , SLICE_ID
       , PROJECT_ID
       , TASK_ID
       , PERSON_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_TYPE_CLASS
       , CUSTOMER_ID
       , EXPENDITURE_ORG_ID
       , EXPENDITURE_ORGANIZATION_ID
       , JOB_ID
       , VENDOR_ID
       , WORK_TYPE_ID
       , EXP_EVT_TYPE_ID
       , EXPENDITURE_TYPE
       , EVENT_TYPE
       , EVENT_TYPE_CLASSIFICATION
       , EXPENDITURE_CATEGORY
       , REVENUE_CATEGORY
       , NON_LABOR_RESOURCE
       , BOM_LABOR_RESOURCE_ID
       , BOM_EQUIPMENT_RESOURCE_ID
       , INVENTORY_ITEM_ID
       , SYSTEM_LINKAGE_FUNCTION
       , PJI_PROJECT_RECORD_FLAG
       , PJI_RESOURCE_RECORD_FLAG
       , CODE_COMBINATION_ID
       , PRVDR_GL_DATE
       , RECVR_GL_DATE
       , GL_PERIOD_NAME
       , PRVDR_PA_DATE
       , RECVR_PA_DATE
       , PA_PERIOD_NAME
       , TXN_CURRENCY_CODE
       , TXN_REVENUE
       , TXN_RAW_COST
       , TXN_BILL_RAW_COST
       , TXN_BURDENED_COST
       , TXN_BILL_BURDENED_COST
       , TXN_UBR
       , TXN_UER
       , PRJ_REVENUE
       , PRJ_RAW_COST
       , PRJ_BILL_RAW_COST
       , PRJ_BURDENED_COST
       , PRJ_BILL_BURDENED_COST
       , PRJ_UBR
       , PRJ_UER
       , POU_REVENUE
       , POU_RAW_COST
       , POU_BILL_RAW_COST
       , POU_BURDENED_COST
       , POU_BILL_BURDENED_COST
       , POU_UBR
       , POU_UER
       , EOU_RAW_COST
       , EOU_BILL_RAW_COST
       , EOU_BURDENED_COST
       , EOU_BILL_BURDENED_COST
       , EOU_UBR
       , EOU_UER
       , QUANTITY
       , BILL_QUANTITY
       )
        Select /*+ PARALLEL(drev) FULL(drev)
                   PARALLEL(erdl) FULL(erdl) */
          p_worker_id                           AS WORKER_ID
          , 1                                   AS SLICE_ID
          , erdl.Project_ID                     AS PROJECT_ID
          , nvl(ev.task_id, -1)                 AS TASK_ID                  -- Bug 6065483
          , -1                                  AS PERSON_ID
          , drev.Project_Org_ID                 AS PROJECT_ORG_ID
          , drev.Project_Organization_ID        AS PROJECT_ORGANIZATION_ID
          , drev.Project_Type_Class             AS PROJECT_TYPE_CLASS
          , cust.Customer_ID                    AS CUSTOMER_ID
          , -1                                  AS EXPENDITURE_ORG_ID
          , ev.Organization_ID                  AS EXPENDITURE_ORGANIZATION_ID
          , -1                                  AS JOB_ID
          , -1                                  AS VENDOR_ID
          , -1                                  AS WORK_TYPE_ID
          , evt.event_type_id                   AS EXP_EVT_TYPE_ID
          , PJI_FM_SUM_MAIN.g_null              AS EXPENDITURE_TYPE
          , evt.event_type                      AS EVENT_TYPE
          , evt.event_type_classification       AS EVENT_TYPE_CLASSIFICATION
          , PJI_FM_SUM_MAIN.g_null              AS EXPENDITURE_CATEGORY
          , evt.revenue_category_code           AS REVENUE_CATEGORY
          , 'PJI$NULL'                          AS NON_LABOR_RESOURCE
          , -1                                  AS BOM_LABOR_RESOURCE_ID
          , -1                                  AS BOM_EQUIPMENT_RESOURCE_ID
          , -1                                  AS INVENTORY_ITEM_ID
          , PJI_FM_SUM_MAIN.g_null              AS SYSTEM_LINKAGE_FUNCTION
          , 'Y'                                 AS PJI_PROJECT_RECORD_FLAG
          , 'N'                                 AS PJI_RESOURCE_RECORD_FLAG
          , -1                                  AS CODE_COMBINATION_ID
          , Greatest(drev.GL_Date,l_min_date)   AS PRVDR_GL_DATE
          , Greatest(drev.GL_Date,l_min_date)   AS RECVR_GL_DATE
          , drev.GL_Period_Name                 AS GL_PERIOD_NAME
          , Greatest(drev.PA_Date,l_min_date)   AS PRVDR_PA_DATE
          , Greatest(drev.PA_Date,l_min_date)   AS RECVR_PA_DATE
          , drev.PA_Period_Name                 AS PA_PERIOD_NAME
          , erdl.Funding_Currency_Code          AS TXN_CURRENCY_CODE
          , sum(erdl.Funding_Revenue_Amount)    AS TXN_REVENUE
          , to_number(null)                     AS TXN_RAW_COST
          , to_number(null)                     AS TXN_BILL_RAW_COST
          , to_number(null)                     AS TXN_BURDENED_COST
          , to_number(null)                     AS TXN_BILL_BURDENED_COST
          , to_number(null)                     AS TXN_UBR
          , to_number(null)                     AS TXN_UER
          , sum(erdl.Project_Revenue_Amount)    AS PRJ_REVENUE
          , to_number(null)                     AS PRJ_RAW_COST
          , to_number(null)                     AS PRJ_BILL_RAW_COST
          , to_number(null)                     AS PRJ_BURDENED_COST
          , to_number(null)                     AS PRJ_BILL_BURDENED_COST
          , to_number(null)                     AS PRJ_UBR
          , to_number(null)                     AS PRJ_UER
          , sum(erdl.Projfunc_Revenue_Amount)   AS POU_REVENUE
          , to_number(null)                     AS POU_RAW_COST
          , to_number(null)                     AS POU_BILL_RAW_COST
          , to_number(null)                     AS POU_BURDENED_COST
          , to_number(null)                     AS POU_BILL_BURDENED_COST
          , to_number(null)                     AS POU_UBR
          , to_number(null)                     AS POU_UER
          , to_number(null)                     AS EOU_RAW_COST
          , to_number(null)                     AS EOU_BILL_RAW_COST
          , to_number(null)                     AS EOU_BURDENED_COST
          , to_number(null)                     AS EOU_BILL_BURDENED_COST
          , to_number(null)                     AS EOU_UBR
          , to_number(null)                     AS EOU_UER
          , to_number(null)                     AS QUANTITY
          , to_number(null)                     AS BILL_QUANTITY
        From    pa_agreements_all               ag
              , pa_project_customers            cust
              , pa_events                       ev
              , pa_event_types                  evt
              , PJI_FM_EXTR_DREVN               drev
              , pa_cust_event_rdl_all           erdl
        Where 1 = 1
        And   drev.worker_id = p_worker_id
        And   drev.project_id = erdl.project_id
        And   ev.project_id = erdl.project_id
        And   drev.draft_revenue_num = erdl.draft_revenue_num
        And   NVL(erdl.task_id,-1) = NVL(ev.task_id,-1)
        And   ev.event_num = erdl.event_num
        And   ev.event_type = evt.event_type
        And   drev.agreement_id = ag.agreement_id
        And   drev.project_id = cust.project_id
        And   ag.customer_id = cust.customer_id
--        And   NVL(cust.bill_another_project_flag,'N') <> 'Y' ---- ER 6519955
        And   drev.gl_date is not null
        And   drev.pa_date is not null
        Group By
              erdl.Project_ID
			, nvl(ev.task_id, -1)           -- Bug 6065483
            , drev.Project_Org_ID
            , drev.Project_Organization_ID
            , drev.Project_Type_Class
            , cust.Customer_ID
            , ev.Organization_ID
            , evt.event_type_id
            , evt.event_type
            , evt.event_type_classification
            , evt.revenue_category_code
            , drev.GL_Date
            , drev.PA_Date
            , drev.GL_Period_Name
            , drev.PA_Period_Name
            , erdl.Funding_Currency_Code
      ;

    end if;  -- EXTRACTION_TYPE = 'FULL'

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_ERDL_FULL(p_worker_id);');

    commit;

  end EXTRACT_BATCH_ERDL_FULL;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_CDL_ROWIDS
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_CDL_ROWIDS(p_worker_id in number) is

    l_process         varchar2(30);
    l_schema          varchar2(30);
    l_from_project_id number;
    l_to_project_id   number;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_CDL_ROWIDS(p_worker_id);')) then
      return;
    end if;

    if (PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE') = 'FULL') then

      insert /*+ append */ into PJI_FM_REXT_CDL
      (
        WORKER_ID
      , CDL_ROWID
      , START_DATE
      , END_DATE
      , PROJECT_ORG_ID
      , PROJECT_ORGANIZATION_ID
      , PROJECT_TYPE_CLASS
      , PJI_SUMMARIZED_FLAG
      , BATCH_ID
      )
      SELECT /*+ index_ffs(cdl, PA_COST_DISTRIBUTION_LINES_N15)
                 parallel_index(cdl, PA_COST_DISTRIBUTION_LINES_N15) */
        p_worker_id
      , cdl.ROWID
      , null
      , null
      , null
      , null
      , null
      , cdl.PJI_SUMMARIZED_FLAG
      , ceil(ROWNUM / PJI_FM_SUM_MAIN.g_commit_threshold)
      FROM
        PA_COST_DISTRIBUTION_LINES_ALL cdl
      WHERE
        cdl.LINE_TYPE in ('R', 'I') and
        cdl.PJI_SUMMARIZED_FLAG = 'N';

    else

    INSERT /*+ APPEND */ INTO PJI_FM_REXT_CDL
    (
      WORKER_ID
    , CDL_ROWID
    , START_DATE
    , END_DATE
    , PROJECT_ORG_ID
    , PROJECT_ORGANIZATION_ID
    , PROJECT_TYPE_CLASS
    , PJI_SUMMARIZED_FLAG
    , BATCH_ID
    )
    SELECT
      p_worker_id
    , row_id
    , start_date
    , end_date
    , project_org_id
    , project_organization_id
    , project_type_class
    , pji_summarized_flag
    , ceil(ROWNUM / PJI_FM_SUM_MAIN.g_commit_threshold)
    FROM
      (
      SELECT /*+ ORDERED
                 USE_NL(cdl)
                 INDEX(cdl, PA_COST_DISTRIBUTION_LINES_N15)
              */
        cdl.rowid row_id
      , bat.start_date
      , bat.end_date
      , bat.project_org_id
      , bat.project_organization_id
      , bat.project_type_class
      , cdl.pji_summarized_flag
      FROM
        pji_fm_proj_batch_map            bat
      , pa_cost_distribution_lines_all   cdl
      WHERE
            bat.worker_id = p_worker_id
        and cdl.project_id = bat.project_id
        and cdl.line_type in ('R','I')
        and bat.extraction_type = 'I'
        and cdl.pji_summarized_flag = 'N'
      union all
      SELECT /*+ ORDERED
                 USE_NL(cdl)
                 INDEX(cdl, PA_COST_DISTRIBUTION_LINES_N15)
              */
        cdl.rowid row_id
      , bat.start_date
      , bat.end_date
      , bat.project_org_id
      , bat.project_organization_id
      , bat.project_type_class
      , cdl.pji_summarized_flag
      FROM
        pji_fm_proj_batch_map            bat
      , pa_cost_distribution_lines_all   cdl
      WHERE
            bat.worker_id = p_worker_id
        and cdl.project_id = bat.project_id
        and cdl.line_type in ('R','I')
        and bat.extraction_type <> 'I'
      );

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_CDL_ROWIDS(p_worker_id);');

    commit;

  end EXTRACT_BATCH_CDL_ROWIDS;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_CRDL_ROWIDS
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_CRDL_ROWIDS(p_worker_id in number) is

    l_process  varchar2(30);
    l_schema   varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_CRDL_ROWIDS(p_worker_id);')) then
      return;
    end if;

    if ( PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE') <> 'FULL') then

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                               'CURRENT_BATCH') = 1) then
    -- implicit commit
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_FM_EXTR_DREVN',
                                 percent => 10,
                                 degree  => PJI_UTILS.
                                            GET_DEGREE_OF_PARALLELISM);
    end if;

    INSERT /*+ APPEND */ INTO PJI_FM_REXT_CRDL
    (
      WORKER_ID
    , CRDL_ROWID
    , PA_DATE
    , PA_PERIOD_NAME
    , GL_DATE
    , GL_PERIOD_NAME
    , PROJECT_ORG_ID
    , PROJECT_ORGANIZATION_ID
    , PROJECT_TYPE_CLASS
    , LINE_SOURCE_TYPE
    , BILL_ANOTHER_PROJECT_FLAG
    , CUSTOMER_ID
    )
    SELECT /*+ ORDERED
               USE_NL(ag)
               USE_NL(cust)
               USE_NL(crdl)
               INDEX(crdl, PA_CUST_REV_DIST_LINES_N1)
             */
      p_worker_id
    , crdl.rowid
    , drev.pa_date
    , drev.pa_period_name
    , drev.gl_date
    , drev.gl_period_name
    , drev.project_org_id
    , drev.project_organization_id
    , drev.project_type_class
    , drev.line_source_type
    , cust.bill_another_project_flag
    , cust.customer_id
    FROM
      PJI_FM_EXTR_DREVN                 drev
    , pa_agreements_all                ag
    , pa_project_customers             cust
    , pa_cust_rev_dist_lines_all       crdl
    WHERE
          drev.worker_id = p_worker_id
      and drev.project_id = crdl.project_id
      and drev.draft_revenue_num = crdl.draft_revenue_num
      and drev.gl_date is not null
      and drev.pa_date is not null
      and drev.agreement_id = ag.agreement_id
      and drev.project_id = cust.project_id
      and ag.customer_id = cust.customer_id;
--      and NVL(cust.bill_another_project_flag,'N') <> 'Y'; -- ER 6519955

    end if;  --  EXTRACTION_TYPE <> 'FULL'

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_CRDL_ROWIDS(p_worker_id);');

    commit;

  end EXTRACT_BATCH_CRDL_ROWIDS;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_ERDL_ROWIDS
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_ERDL_ROWIDS(p_worker_id in number) is

    l_process varchar2(30);
    l_schema varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_ERDL_ROWIDS(p_worker_id);')) then
      return;
    end if;

    if ( PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE') <> 'FULL') then

    INSERT /*+ APPEND */ INTO PJI_FM_REXT_ERDL
    (
      WORKER_ID
    , ERDL_ROWID
    , PROJECT_ORG_ID
    , PROJECT_ORGANIZATION_ID
    , PROJECT_ID
    , PROJECT_TYPE_CLASS
    , EXPENDITURE_ORGANIZATION_ID
    , TASK_ID
    , EXP_EVT_TYPE_ID
    , EVENT_TYPE
    , EVENT_NUM
    , REVENUE_CATEGORY
    , EVENT_TYPE_CLASSIFICATION
    , LINE_SOURCE_TYPE
    , BILL_ANOTHER_PROJECT_FLAG
    , CUSTOMER_ID
    , TXN_DATE
    , PA_DATE
    , PA_PERIOD_NAME
    , GL_DATE
    , GL_PERIOD_NAME
    )
    SELECT /*+ ORDERED
               USE_NL(ag)
               USE_NL(cust)
               USE_NL(erdl)
               INDEX(erdl, PA_CUST_EVENT_REV_DIST_LINE_N1)
             */
      p_worker_id                     worker_id
    , erdl.rowid                      row_id
    , nvl(drev.project_org_id, -1)    project_org_id
    , drev.project_organization_id    project_organization_id
    , drev.project_id                 project_id
    , drev.project_type_class         project_type_class
    , ev.organization_id              expenditure_organization_id
    , NVL(ev.task_id,-1)              task_id
    , evt.event_type_id               exp_evt_type_id
    , evt.event_type                  event_type
    , ev.event_num                    event_num
    , evt.revenue_category_code       revenue_category
    , evt.event_type_classification   event_type_classification
    , drev.line_source_type           line_source_type
    , cust.bill_another_project_flag  bill_another_project_flag
    , ag.customer_id                  customer_id
    , ev.completion_date              txn_date
    , drev.pa_date                    pa_date
    , drev.pa_period_name             pa_period_name
    , drev.gl_date                    gl_date
    , drev.gl_period_name             gl_period_name
    FROM
            PJI_FM_EXTR_DREVN               drev
          , pa_agreements_all              ag
          , pa_project_customers           cust
          , pa_cust_event_rdl_all          erdl  /* Changed the order for bug 8668173 */
          , pa_events                      ev
          , pa_event_types                 evt
    WHERE
          drev.worker_id = p_worker_id
  /*  and drev.project_id = ev.project_id  Commented for bug 8668173 */
      and ev.project_id = erdl.project_id
      and drev.project_id = erdl.project_id
      and drev.draft_revenue_num = erdl.draft_revenue_num
      and NVL(erdl.task_id,-1) = NVL(ev.task_id,-1) -- uncommented for bug 7354140
      and ev.event_num = erdl.event_num -- uncommented for bug 7354140
      and ev.event_type = evt.event_type
      and drev.agreement_id = ag.agreement_id
      and drev.project_id = cust.project_id
      and ag.customer_id = cust.customer_id
--      and NVL(cust.bill_another_project_flag,'N') <> 'Y' -- ER 6519955
      and drev.gl_date is not null
      and drev.pa_date is not null
      ;

    end if;  --  EXTRACTION_TYPE <> 'FULL'

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_ERDL_ROWIDS(p_worker_id);');

    commit;

  end EXTRACT_BATCH_ERDL_ROWIDS;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_CDL_AND_CRDL
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_CDL_AND_CRDL (p_worker_id in number) is

    l_process   varchar2(30);
    l_min_date  date;
    l_schema    varchar2(30);
    l_row_count number;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_CDL_AND_CRDL(p_worker_id);')) then
      return;
    end if;

    l_min_date := to_date(PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE'),
                          PJI_FM_SUM_MAIN.g_date_mask);

    if ( PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE') <> 'FULL') then

      -- This cleanup is intentionally before the implicit commit so as not
      -- to interfere with the CDL extraction.
      if (nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
              (PJI_FM_SUM_MAIN.g_process, 'CONFIG_PROJ_PERF_FLAG'),
              'N') = 'N' and
          nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
              (PJI_FM_SUM_MAIN.g_process, 'CONFIG_COST_FLAG'),
              'N') = 'N' and
          nvl(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
              (PJI_FM_SUM_MAIN.g_process, 'CONFIG_PROFIT_FLAG'),
              'N') = 'N') then
        delete /*+ index (log, PA_PJI_PROJ_EVENTS_LOG_N1) */
        from   PA_PJI_PROJ_EVENTS_LOG log
        where  EVENT_TYPE = 'DRAFT_REVENUES';
      end if;

      -- delete Non-Util --> Util resources that are getting extracted anyway
      delete
      from   PJI_FM_REXT_CDL
      where  WORKER_ID = p_worker_id and
             PROJECT_ORG_ID = -1 and
             PROJECT_ORGANIZATION_ID = -1 and
             CDL_ROWID in (select CDL_ROWID
                           from   PJI_FM_REXT_CDL
                           where  WORKER_ID = p_worker_id and
                                  PROJECT_ORGANIZATION_ID <> -1);

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                               'CURRENT_BATCH') = 1) then
    -- implicit commit
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_FM_REXT_CDL',
                                 percent => 10,
                                 degree  => PJI_UTILS.
                                            GET_DEGREE_OF_PARALLELISM);
    -- implicit commit
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_FM_REXT_CRDL',
                                 percent => 10,
                                 degree  => PJI_UTILS.
                                            GET_DEGREE_OF_PARALLELISM);
    end if;

    INSERT /*+ APPEND PARALLEL(fin1_i) */ INTO PJI_FM_AGGR_FIN1 fin1_i
     ( WORKER_ID
     , SLICE_ID
     , PROJECT_ID
     , TASK_ID
     , PERSON_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_TYPE_CLASS
     , CUSTOMER_ID
     , EXPENDITURE_ORG_ID
     , EXPENDITURE_ORGANIZATION_ID
     , JOB_ID
     , VENDOR_ID
     , WORK_TYPE_ID
     , EXP_EVT_TYPE_ID
     , EXPENDITURE_TYPE
     , EVENT_TYPE
     , EVENT_TYPE_CLASSIFICATION
     , EXPENDITURE_CATEGORY
     , REVENUE_CATEGORY
     , NON_LABOR_RESOURCE
     , BOM_LABOR_RESOURCE_ID
     , BOM_EQUIPMENT_RESOURCE_ID
     , INVENTORY_ITEM_ID
     , PO_LINE_ID
     , ASSIGNMENT_ID
     , SYSTEM_LINKAGE_FUNCTION
     , PJI_PROJECT_RECORD_FLAG
     , PJI_RESOURCE_RECORD_FLAG
     , CODE_COMBINATION_ID
     , PRVDR_GL_DATE
     , RECVR_GL_DATE
     , GL_PERIOD_NAME
     , PRVDR_PA_DATE
     , RECVR_PA_DATE
     , PA_PERIOD_NAME
     , EXPENDITURE_ITEM_DATE
     , TXN_CURRENCY_CODE
     , TXN_REVENUE
     , TXN_RAW_COST
     , TXN_BILL_RAW_COST
     , TXN_BURDENED_COST
     , TXN_BILL_BURDENED_COST
     , TXN_UBR
     , TXN_UER
     , PRJ_REVENUE
     , PRJ_RAW_COST
     , PRJ_BILL_RAW_COST
     , PRJ_BURDENED_COST
     , PRJ_BILL_BURDENED_COST
     , PRJ_UBR
     , PRJ_UER
     , POU_REVENUE
     , POU_RAW_COST
     , POU_BILL_RAW_COST
     , POU_BURDENED_COST
     , POU_BILL_BURDENED_COST
     , POU_UBR
     , POU_UER
     , EOU_RAW_COST
     , EOU_BILL_RAW_COST
     , EOU_BURDENED_COST
     , EOU_BILL_BURDENED_COST
     , EOU_UBR
     , EOU_UER
     , QUANTITY
     , BILL_QUANTITY
    )
    SELECT
       grp.WORKER_ID
     , grp.SLICE_ID
     , grp.PROJECT_ID
     , grp.TASK_ID
     , grp.PERSON_ID
     , grp.PROJECT_ORG_ID
     , grp.PROJECT_ORGANIZATION_ID
     , grp.PROJECT_TYPE_CLASS
     , grp.CUSTOMER_ID
     , grp.EXPENDITURE_ORG_ID
     , grp.EXPENDITURE_ORGANIZATION_ID
     , grp.JOB_ID
     , grp.VENDOR_ID
     , grp.WORK_TYPE_ID
     , grp.EXP_EVT_TYPE_ID
     , grp.EXPENDITURE_TYPE
     , grp.EVENT_TYPE
     , grp.EVENT_TYPE_CLASSIFICATION
     , grp.EXPENDITURE_CATEGORY
     , grp.REVENUE_CATEGORY
     , grp.NON_LABOR_RESOURCE
     , grp.BOM_LABOR_RESOURCE_ID
     , grp.BOM_EQUIPMENT_RESOURCE_ID
     , grp.INVENTORY_ITEM_ID
     , grp.PO_LINE_ID
     , grp.ASSIGNMENT_ID
     , grp.SYSTEM_LINKAGE_FUNCTION
     , grp.PJI_PROJECT_RECORD_FLAG
     , grp.PJI_RESOURCE_RECORD_FLAG
     , grp.CODE_COMBINATION_ID
     , grp.PRVDR_GL_DATE
     , grp.RECVR_GL_DATE
     , grp.GL_PERIOD_NAME
     , grp.PRVDR_PA_DATE
     , grp.RECVR_PA_DATE
     , grp.PA_PERIOD_NAME
     , grp.EXPENDITURE_ITEM_DATE
     , grp.TXN_CURRENCY_CODE
     , sum(grp.TXN_REVENUE)
     , sum(grp.TXN_RAW_COST)
     , sum(grp.TXN_BILL_RAW_COST)
     , sum(grp.TXN_BURDENED_COST)
     , sum(grp.TXN_BILL_BURDENED_COST)
     , sum(grp.TXN_UBR)
     , sum(grp.TXN_UER)
     , sum(grp.PRJ_REVENUE)
     , sum(grp.PRJ_RAW_COST)
     , sum(grp.PRJ_BILL_RAW_COST)
     , sum(grp.PRJ_BURDENED_COST)
     , sum(grp.PRJ_BILL_BURDENED_COST)
     , sum(grp.PRJ_UBR)
     , sum(grp.PRJ_UER)
     , sum(grp.POU_REVENUE)
     , sum(grp.POU_RAW_COST)
     , sum(grp.POU_BILL_RAW_COST)
     , sum(grp.POU_BURDENED_COST)
     , sum(grp.POU_BILL_BURDENED_COST)
     , sum(grp.POU_UBR)
     , sum(grp.POU_UER)
     , sum(grp.EOU_RAW_COST)
     , sum(grp.EOU_BILL_RAW_COST)
     , sum(grp.EOU_BURDENED_COST)
     , sum(grp.EOU_BILL_BURDENED_COST)
     , sum(grp.EOU_UBR)
     , sum(grp.EOU_UER)
     , sum(grp.QUANTITY)
     , sum(grp.BILL_QUANTITY)
    FROM (
    SELECT /*+ ordered */
      p_worker_id                         AS WORKER_ID
    , decode(scope.PROJECT_ORG_ID, -1,                -- Ensure that JOB_ID
             decode(scope.PROJECT_ORGANIZATION_ID,    -- Util --> Non-Util
                    -1, -1, 1),                       -- reversals do not get
             1)                              SLICE_ID -- into PSI tables.
    , cdl.project_id                      AS PROJECT_ID
    , cdl.task_id                         AS TASK_ID
    , decode(exp.incurred_by_person_id,
             null, -1, 0, -1,
             exp.incurred_by_person_id)   AS PERSON_ID
    , nvl(scope.project_org_id, -1)       AS PROJECT_ORG_ID
    , scope.project_organization_id       AS PROJECT_ORGANIZATION_ID
    , scope.project_type_class            AS PROJECT_TYPE_CLASS
    , -1                                  AS CUSTOMER_ID
    , cdl.org_id                          AS EXPENDITURE_ORG_ID
    , NVL(ei.override_to_organization_id, exp.incurred_by_organization_id)
                                          AS EXPENDITURE_ORGANIZATION_ID
    , nvl(ei.job_id, -1)                  AS JOB_ID
    , nvl(exp.vendor_id, -1)              AS VENDOR_ID
    , nvl(cdl.work_type_id, -1)           AS WORK_TYPE_ID
    , et.expenditure_type_id              AS EXP_EVT_TYPE_ID
    , et.expenditure_type                 AS EXPENDITURE_TYPE
    , PJI_FM_SUM_MAIN.g_null              AS EVENT_TYPE
    , PJI_FM_SUM_MAIN.g_null              AS EVENT_TYPE_CLASSIFICATION
    , et.expenditure_category             AS EXPENDITURE_CATEGORY
    , et.revenue_category_code            AS REVENUE_CATEGORY
    , ei.Non_Labor_Resource               AS NON_LABOR_RESOURCE
    , ei.Wip_Resource_ID                  AS BOM_LABOR_RESOURCE_ID
    , ei.Wip_Resource_ID                  AS BOM_EQUIPMENT_RESOURCE_ID
    , ei.Inventory_Item_ID                AS INVENTORY_ITEM_ID
    , ei.PO_Line_ID                       AS PO_LINE_ID
    , decode(ei.Assignment_ID,
             null, -1, 0, -1,
             ei.Assignment_ID)            AS ASSIGNMENT_ID
    , NVL(ei.src_system_linkage_function,
                ei.system_linkage_function)
                                          AS SYSTEM_LINKAGE_FUNCTION
    , decode(scope.PROJECT_ORG_ID,
             -1, decode(scope.PROJECT_ORGANIZATION_ID,
                        -1, 'N',
                            'Y'),
                 'Y')                     AS PJI_PROJECT_RECORD_FLAG
    , decode(scope.PROJECT_ORG_ID,
             -1, decode(scope.PROJECT_ORGANIZATION_ID,
                        -1, 'Y',
                            decode(exp.Incurred_BY_Person_ID,
                                   null, 'N',
                                   0,    'N',
                                         'Y')),
                 decode(exp.Incurred_BY_Person_ID,
                        null, 'N',
                        0,    'N',
                              'Y'))       AS PJI_RESOURCE_RECORD_FLAG
    , -1                                  AS CODE_COMBINATION_ID
    , Greatest(cdl.gl_date,l_min_date)    AS PRVDR_GL_DATE
    , Greatest(nvl(cdl.recvr_gl_date, cdl.gl_date),l_min_date) AS RECVR_GL_DATE
    , cdl.Recvr_GL_Period_Name            AS GL_PERIOD_NAME
    , Greatest(cdl.pa_date,l_min_date)    AS PRVDR_PA_DATE
    , Greatest(nvl(cdl.recvr_pa_date, cdl.pa_date),l_min_date) AS RECVR_PA_DATE
    , cdl.Recvr_PA_Period_Name            AS PA_PERIOD_NAME
    , Greatest(ei.Expenditure_Item_Date,
               l_min_date)                AS EXPENDITURE_ITEM_DATE
    , cdl.Denom_Currency_Code             AS TXN_CURRENCY_CODE
    , to_number(null)                     AS TXN_REVENUE
    , NVL(cdl.Denom_Raw_Cost,0)           AS TXN_RAW_COST
    , decode(cdl.billable_flag
             , 'Y', nvl(cdl.Denom_Raw_Cost, 0)
             , 0)                         AS TXN_BILL_RAW_COST
    , nvl(cdl.Denom_Burdened_Cost, 0)     AS TXN_BURDENED_COST
    , decode(cdl.Billable_Flag
             , 'Y', nvl(cdl.Denom_Burdened_Cost, 0)
             , 0)                         AS TXN_BILL_BURDENED_COST
    , to_number(null)                     AS TXN_UBR
    , to_number(null)                     AS TXN_UER
    , to_number(null)                     AS PRJ_REVENUE
    , NVL(cdl.project_raw_cost,0)         AS PRJ_RAW_COST
    , decode(cdl.billable_flag
             , 'Y', nvl(cdl.Project_Raw_Cost, 0)
             , 0)                         AS PRJ_BILL_RAW_COST
    , nvl(cdl.Project_Burdened_Cost, 0)   AS PRJ_BURDENED_COST
    , decode(cdl.Billable_Flag
             , 'Y', nvl(cdl.Project_Burdened_Cost, 0)
             , 0)                         AS PRJ_BILL_BURDENED_COST
    , to_number(null)                     AS PRJ_UBR
    , to_number(null)                     AS PRJ_UER
    , to_number(null)                     AS POU_REVENUE
    , cdl.AMOUNT                          AS POU_RAW_COST
    , decode(cdl.bILLABLE_fLAG
             , 'Y', nvl(cdl.Amount, 0)
             , 0)                         AS POU_BILL_RAW_COST
    , nvl(cdl.Burdened_Cost, 0)           AS POU_BURDENED_COST
    , decode(cdl.Billable_Flag
             , 'Y', nvl(cdl.Burdened_Cost, 0)
             , 0)                         AS POU_BILL_BURDENED_COST
    , to_number(null)                     AS POU_UBR
    , to_number(null)                     AS POU_UER
    , nvl(cdl.Acct_Raw_Cost, 0)           AS EOU_RAW_COST
    , decode(cdl.Billable_Flag
             , 'Y', nvl(cdl.Acct_Raw_Cost,0)
             , 0)                         AS EOU_BILL_RAW_COST
    , nvl(cdl.Acct_Burdened_Cost, 0)      AS EOU_BURDENED_COST
    , decode(cdl.Billable_Flag
             , 'Y', nvl(cdl.Acct_Burdened_Cost, 0)
             , 0)                         AS EOU_BILL_BURDENED_COST
    , to_number(null)                     AS EOU_UBR
    , to_number(null)                     AS EOU_UER
    , cdl.Quantity                        AS QUANTITY
    , decode(cdl.Billable_Flag
             , 'Y', cdl.Quantity
             , 0)                         AS BILL_QUANTITY
    FROM
        PJI_FM_REXT_CDL                 scope
      , pa_cost_distribution_lines_all   cdl
      , pa_expenditure_items_all         ei
      , pa_expenditures_all              exp
      , pa_expenditure_types             et
    WHERE
          scope.worker_id = p_worker_id
      and scope.cdl_rowid = cdl.rowid
      and cdl.expenditure_item_id = ei.expenditure_item_id
      and ei.expenditure_type = et.expenditure_type
      and exp.expenditure_id = ei.expenditure_id
      and cdl.gl_date is not null
      and cdl.pa_date is not null
--      and NVL(ei.transaction_source,'dummy') <> 'INTERPROJECT_AP_INVOICES' -- ER 6519955
    UNION ALL
    SELECT /*+ ordered */
      p_worker_id                         AS WORKER_ID
    , 1                                   AS SLICE_ID
    , crdl.Project_ID                     AS PROJECT_ID
    , ei.Task_ID                          AS TASK_ID
    , decode(exp.Incurred_By_Person_ID,
             null, -1, 0, -1,
             exp.Incurred_By_Person_ID)   AS PERSON_ID
    , nvl(scope.Project_Org_ID, -1)       AS PROJECT_ORG_ID
    , scope.Project_Organization_ID       AS PROJECT_ORGANIZATION_ID
    , scope.Project_Type_Class            AS PROJECT_TYPE_CLASS
    , scope.Customer_ID                   AS CUSTOMER_ID
    , ei.Org_ID                           AS EXPENDITURE_ORG_ID
    , nvl(ei.Override_To_Organization_ID, exp.Incurred_By_Organization_ID)
                                          AS EXPENDITURE_ORGANIZATION_ID
    , nvl(ei.Job_ID, -1)                  AS JOB_ID
    , nvl(exp.vendor_id,-1)               AS VENDOR_ID
    , nvl(ei.Work_type_ID, -1)            AS WORK_TYPE_ID
    , et.Expenditure_Type_ID              AS EXP_EVT_TYPE_ID
    , et.Expenditure_Type                 AS EXPENDITURE_TYPE
    , PJI_FM_SUM_MAIN.g_null              AS EVENT_TYPE
    , PJI_FM_SUM_MAIN.g_null              AS EVENT_TYPE_CLASSIFICATION
    , et.Expenditure_Category             AS EXPENDITURE_CATEGORY
    , et.Revenue_Category_Code            AS REVENUE_CATEGORY
    , ei.Non_Labor_Resource               AS NON_LABOR_RESOURCE
    , ei.Wip_Resource_ID                  AS BOM_LABOR_RESOURCE_ID
    , ei.Wip_Resource_ID                  AS BOM_EQUIPMENT_RESOURCE_ID
    , ei.Inventory_Item_ID                AS INVENTORY_ITEM_ID
    , ei.PO_Line_ID                       AS PO_LINE_ID
    , decode(ei.Assignment_ID,
             null, -1, 0, -1,
             ei.Assignment_ID)            AS ASSIGNMENT_ID
    , NVL(ei.src_system_linkage_function,
                ei.system_linkage_function)
                                          AS SYSTEM_LINKAGE_FUNCTION
    , 'Y'                                 AS PJI_PROJECT_RECORD_FLAG
    , decode(exp.Incurred_By_Person_ID, null, 'N', 0, 'N', 'Y')
                                          AS PJI_RESOURCE_RECORD_FLAG
    , -1                                  AS CODE_COMBINATION_ID
    , Greatest(scope.GL_Date,l_min_date)  AS PRVDR_GL_DATE
    , Greatest(scope.GL_Date,l_min_date)  AS RECVR_GL_DATE
    , scope.GL_Period_Name                AS GL_PERIOD_NAME
    , Greatest(scope.PA_Date,l_min_date)  AS PRVDR_PA_DATE
    , Greatest(scope.PA_Date,l_min_date)  AS RECVR_PA_DATE
    , scope.PA_Period_Name                AS PA_PERIOD_NAME
    , Greatest(ei.Expenditure_Item_Date,
               l_min_date)                AS EXPENDITURE_ITEM_DATE
    , crdl.Funding_Currency_Code          AS TXN_CURRENCY_CODE
    , decode(scope.line_source_type,
        'R', (crdl.Funding_Revenue_Amount),
        'L', (-crdl.Funding_Revenue_Amount)
      )                                   AS TXN_REVENUE
    , to_number(null)                     AS TXN_RAW_COST
    , to_number(null)                     AS TXN_BILL_RAW_COST
    , to_number(null)                     AS TXN_BURDENED_COST
    , to_number(null)                     AS TXN_BILL_BURDENED_COST
    , to_number(null)                     AS TXN_UBR
    , to_number(null)                     AS TXN_UER
    , decode(scope.line_source_type,
        'R', (crdl.Project_Revenue_Amount),
        'L', (-crdl.Project_Revenue_Amount)
      )                                   AS PRJ_REVENUE
    , to_number(null)                     AS PRJ_RAW_COST
    , to_number(null)                     AS PRJ_BILL_RAW_COST
    , to_number(null)                     AS PRJ_BURDENED_COST
    , to_number(null)                     AS PRJ_BILL_BURDENED_COST
    , to_number(null)                     AS PRJ_UBR
    , to_number(null)                     AS PRJ_UER
    , decode(scope.line_source_type,
        'R', (crdl.Projfunc_Revenue_Amount),
        'L', (-crdl.Projfunc_Revenue_Amount)
      )                                   AS POU_REVENUE
    , to_number(null)                     AS POU_RAW_COST
    , to_number(null)                     AS POU_BILL_RAW_COST
    , to_number(null)                     AS POU_BURDENED_COST
    , to_number(null)                     AS POU_BILL_BURDENED_COST
    , to_number(null)                     AS POU_UBR
    , to_number(null)                     AS POU_UER
    , to_number(null)                     AS EOU_RAW_COST
    , to_number(null)                     AS EOU_BILL_RAW_COST
    , to_number(null)                     AS EOU_BURDENED_COST
    , to_number(null)                     AS EOU_BILL_BURDENED_COST
    , to_number(null)                     AS EOU_UBR
    , to_number(null)                     AS EOU_UER
    , to_number(null)                     AS QUANTITY
    , to_number(null)                     AS BILL_QUANTITY
    FROM
        PJI_FM_REXT_CRDL               scope
      , pa_cust_rev_dist_lines_all      crdl
      , pa_expenditure_items_all        ei
      , pa_expenditures_all             exp
      , pa_expenditure_types            et
    WHERE
          scope.worker_id = p_worker_id
      and scope.crdl_rowid = crdl.rowid
      and crdl.function_code NOT IN ('LRL','LRB','URL','URB')
      and crdl.expenditure_item_id = ei.expenditure_item_id
      and ei.expenditure_type = et.expenditure_type
      and exp.expenditure_id = ei.expenditure_id
    )  grp
    GROUP BY
       grp.WORKER_ID
     , grp.SLICE_ID
     , grp.PROJECT_ID
     , grp.TASK_ID
     , grp.PERSON_ID
     , grp.PROJECT_ORG_ID
     , grp.PROJECT_ORGANIZATION_ID
     , grp.PROJECT_TYPE_CLASS
     , grp.CUSTOMER_ID
     , grp.EXPENDITURE_ORG_ID
     , grp.EXPENDITURE_ORGANIZATION_ID
     , grp.JOB_ID
     , grp.VENDOR_ID
     , grp.WORK_TYPE_ID
     , grp.EXP_EVT_TYPE_ID
     , grp.EXPENDITURE_TYPE
     , grp.EVENT_TYPE
     , grp.EVENT_TYPE_CLASSIFICATION
     , grp.EXPENDITURE_CATEGORY
     , grp.REVENUE_CATEGORY
     , grp.NON_LABOR_RESOURCE
     , grp.BOM_LABOR_RESOURCE_ID
     , grp.BOM_EQUIPMENT_RESOURCE_ID
     , grp.INVENTORY_ITEM_ID
     , grp.PO_LINE_ID
     , grp.ASSIGNMENT_ID
     , grp.SYSTEM_LINKAGE_FUNCTION
     , grp.PJI_PROJECT_RECORD_FLAG
     , grp.PJI_RESOURCE_RECORD_FLAG
     , grp.CODE_COMBINATION_ID
     , grp.PRVDR_GL_DATE
     , grp.RECVR_GL_DATE
     , grp.GL_PERIOD_NAME
     , grp.PRVDR_PA_DATE
     , grp.RECVR_PA_DATE
     , grp.PA_PERIOD_NAME
     , grp.EXPENDITURE_ITEM_DATE
     , grp.TXN_CURRENCY_CODE
     ;

    end if;   --  EXTRACTION_TYPE <> 'FULL'

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_CDL_AND_CRDL(p_worker_id);');

    -- truncate intermediate tables no longer required
    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_REXT_CRDL' , 'NORMAL',null);

    commit;

  end EXTRACT_BATCH_CDL_AND_CRDL;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_CDL_ROWS_PRE
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_CDL_ROWS_PRE (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
          'PJI_FM_EXTR.MARK_EXTRACTED_CDL_ROWS_PRE(p_worker_id);')) then
      return;
    end if;

    insert /*+ append */ into PJI_HELPER_BATCH_MAP
    (
      BATCH_ID,
      WORKER_ID,
      STATUS
    )
    select
      distinct
      BATCH_ID,
      null,
      null
    from
      PJI_FM_REXT_CDL
    where
      PJI_SUMMARIZED_FLAG is not null;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_EXTR.MARK_EXTRACTED_CDL_ROWS_PRE(p_worker_id);');

    commit;

  end MARK_EXTRACTED_CDL_ROWS_PRE;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_CDL_ROWS
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_CDL_ROWS (p_worker_id in number) is

    l_process            varchar2(30);
    l_leftover_batches   number;
    l_helper_batch_id    number;
    l_row_count          number;
    l_parallel_processes number;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.MARK_EXTRACTED_CDL_ROWS(p_worker_id);')) then
      return;
    end if;

    l_parallel_processes := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                            (PJI_FM_SUM_MAIN.g_process, 'PARALLEL_PROCESSES');

    select count(*)
    into   l_leftover_batches
    from   PJI_HELPER_BATCH_MAP
    where  WORKER_ID = p_worker_id and
           STATUS = 'P';

    l_helper_batch_id   := 0;

    while l_helper_batch_id >= 0 loop

      if (l_leftover_batches > 0) then

        l_leftover_batches := l_leftover_batches - 1;

        select  BATCH_ID
        into    l_helper_batch_id
        from    PJI_HELPER_BATCH_MAP
        where   WORKER_ID = p_worker_id and
                STATUS = 'P' and
                ROWNUM = 1;

      else

        update    PJI_HELPER_BATCH_MAP
        set       WORKER_ID = p_worker_id,
                  STATUS = 'P'
        where     WORKER_ID is null and
                  ROWNUM = 1
        returning BATCH_ID
        into      l_helper_batch_id;

      end if;

      if (sql%rowcount <> 0) then

        commit;

        update PA_COST_DISTRIBUTION_LINES_ALL cdl
        set    cdl.PJI_SUMMARIZED_FLAG = null
        where  cdl.ROWID in (select /*+ cardinality(cdl, 1) */
                                    cdl.CDL_ROWID
                             from   PJI_FM_REXT_CDL cdl
                             where  cdl.PJI_SUMMARIZED_FLAG = 'N' and
                                    cdl.BATCH_ID = l_helper_batch_id);

        update PJI_HELPER_BATCH_MAP
        set    STATUS = 'C'
        where  WORKER_ID = p_worker_id and
               BATCH_ID = l_helper_batch_id;

        commit;

      else

        select count(*)
        into   l_row_count
        from   PJI_HELPER_BATCH_MAP
        where  nvl(STATUS, 'X') <> 'C';

        if (l_row_count = 0) then

          for x in 2 .. l_parallel_processes loop

            update PJI_SYSTEM_PRC_STATUS
            set    STEP_STATUS = 'C'
            where  PROCESS_NAME like PJI_FM_SUM_MAIN.g_process || x and
                   STEP_NAME =
                     'PJI_FM_EXTR.MARK_EXTRACTED_CDL_ROWS(p_worker_id);' and
                   START_DATE is null;

            commit;

          end loop;

          l_helper_batch_id := -1;

        else

          PJI_PROCESS_UTIL.SLEEP(1); -- so the CPU is not bombarded

        end if;

      end if;

      if (l_helper_batch_id >= 0) then

        for x in 2 .. l_parallel_processes loop
          if (not PJI_FM_SUM_EXTR.WORKER_STATUS(x, 'OKAY')) then
            l_helper_batch_id := -2;
          end if;
        end loop;

      end if;

    end loop;

    if (l_helper_batch_id <> -2) then

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
        'PJI_FM_EXTR.MARK_EXTRACTED_CDL_ROWS(p_worker_id);');

    end if;

    commit;

  end MARK_EXTRACTED_CDL_ROWS;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_CDL_ROWS_POST
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_CDL_ROWS_POST (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
          'PJI_FM_EXTR.MARK_EXTRACTED_CDL_ROWS_POST(p_worker_id);')) then
      return;
    end if;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE('PJI',
                                     'PJI_HELPER_BATCH_MAP',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_EXTR.MARK_EXTRACTED_CDL_ROWS_POST(p_worker_id);');

    if (PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE') = 'FULL') then
      PJI_PROCESS_UTIL.TRUNC_INT_TABLE(PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                       'PJI_FM_REXT_CDL', 'NORMAL',null);
    end if;

    commit;

  end MARK_EXTRACTED_CDL_ROWS_POST;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_ERDL
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_ERDL (p_worker_id in number) is

    l_process  varchar2(30);
    l_min_date date;
    l_schema   varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_ERDL(p_worker_id);')) then
      return;
    end if;

    l_min_date := to_date(PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE'),
                          PJI_FM_SUM_MAIN.g_date_mask);

    if ( PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE') <> 'FULL') then

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                               'CURRENT_BATCH') = 1) then
    -- implicit commit
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_FM_REXT_ERDL',
                                 percent => 10,
                                 degree  => PJI_UTILS.
                                            GET_DEGREE_OF_PARALLELISM);
    end if;

    INSERT /*+ APPEND */ INTO PJI_FM_AGGR_FIN1
     ( WORKER_ID
     , SLICE_ID
     , PROJECT_ID
     , TASK_ID
     , PERSON_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_TYPE_CLASS
     , CUSTOMER_ID
     , EXPENDITURE_ORG_ID
     , EXPENDITURE_ORGANIZATION_ID
     , JOB_ID
     , VENDOR_ID
     , WORK_TYPE_ID
     , EXP_EVT_TYPE_ID
     , EXPENDITURE_TYPE
     , EVENT_TYPE
     , EVENT_TYPE_CLASSIFICATION
     , EXPENDITURE_CATEGORY
     , REVENUE_CATEGORY
     , NON_LABOR_RESOURCE
     , BOM_LABOR_RESOURCE_ID
     , BOM_EQUIPMENT_RESOURCE_ID
     , INVENTORY_ITEM_ID
     , SYSTEM_LINKAGE_FUNCTION
     , PJI_PROJECT_RECORD_FLAG
     , PJI_RESOURCE_RECORD_FLAG
     , CODE_COMBINATION_ID
     , PRVDR_GL_DATE
     , RECVR_GL_DATE
     , GL_PERIOD_NAME
     , PRVDR_PA_DATE
     , RECVR_PA_DATE
     , PA_PERIOD_NAME
     , TXN_CURRENCY_CODE
     , TXN_REVENUE
     , TXN_RAW_COST
     , TXN_BILL_RAW_COST
     , TXN_BURDENED_COST
     , TXN_BILL_BURDENED_COST
     , TXN_UBR
     , TXN_UER
     , PRJ_REVENUE
     , PRJ_RAW_COST
     , PRJ_BILL_RAW_COST
     , PRJ_BURDENED_COST
     , PRJ_BILL_BURDENED_COST
     , PRJ_UBR
     , PRJ_UER
     , POU_REVENUE
     , POU_RAW_COST
     , POU_BILL_RAW_COST
     , POU_BURDENED_COST
     , POU_BILL_BURDENED_COST
     , POU_UBR
     , POU_UER
     , EOU_RAW_COST
     , EOU_BILL_RAW_COST
     , EOU_BURDENED_COST
     , EOU_BILL_BURDENED_COST
     , EOU_UBR
     , EOU_UER
     , QUANTITY
     , BILL_QUANTITY
    )
    SELECT
       grp.WORKER_ID
     , grp.SLICE_ID
     , grp.PROJECT_ID
     , grp.TASK_ID
     , grp.PERSON_ID
     , grp.PROJECT_ORG_ID
     , grp.PROJECT_ORGANIZATION_ID
     , grp.PROJECT_TYPE_CLASS
     , grp.CUSTOMER_ID
     , grp.EXPENDITURE_ORG_ID
     , grp.EXPENDITURE_ORGANIZATION_ID
     , grp.JOB_ID
     , grp.VENDOR_ID
     , grp.WORK_TYPE_ID
     , grp.EXP_EVT_TYPE_ID
     , grp.EXPENDITURE_TYPE
     , grp.EVENT_TYPE
     , grp.EVENT_TYPE_CLASSIFICATION
     , grp.EXPENDITURE_CATEGORY
     , grp.REVENUE_CATEGORY
     , grp.NON_LABOR_RESOURCE
     , grp.BOM_LABOR_RESOURCE_ID
     , grp.BOM_EQUIPMENT_RESOURCE_ID
     , grp.INVENTORY_ITEM_ID
     , grp.SYSTEM_LINKAGE_FUNCTION
     , grp.PJI_PROJECT_RECORD_FLAG
     , grp.PJI_RESOURCE_RECORD_FLAG
     , grp.CODE_COMBINATION_ID
     , grp.PRVDR_GL_DATE
     , grp.RECVR_GL_DATE
     , grp.GL_PERIOD_NAME
     , grp.PRVDR_PA_DATE
     , grp.RECVR_PA_DATE
     , grp.PA_PERIOD_NAME
     , grp.TXN_CURRENCY_CODE
     , sum(grp.TXN_REVENUE)
     , sum(grp.TXN_RAW_COST)
     , sum(grp.TXN_BILL_RAW_COST)
     , sum(grp.TXN_BURDENED_COST)
     , sum(grp.TXN_BILL_BURDENED_COST)
     , sum(grp.TXN_UBR)
     , sum(grp.TXN_UER)
     , sum(grp.PRJ_REVENUE)
     , sum(grp.PRJ_RAW_COST)
     , sum(grp.PRJ_BILL_RAW_COST)
     , sum(grp.PRJ_BURDENED_COST)
     , sum(grp.PRJ_BILL_BURDENED_COST)
     , sum(grp.PRJ_UBR)
     , sum(grp.PRJ_UER)
     , sum(grp.POU_REVENUE)
     , sum(grp.POU_RAW_COST)
     , sum(grp.POU_BILL_RAW_COST)
     , sum(grp.POU_BURDENED_COST)
     , sum(grp.POU_BILL_BURDENED_COST)
     , sum(grp.POU_UBR)
     , sum(grp.POU_UER)
     , sum(grp.EOU_RAW_COST)
     , sum(grp.EOU_BILL_RAW_COST)
     , sum(grp.EOU_BURDENED_COST)
     , sum(grp.EOU_BILL_BURDENED_COST)
     , sum(grp.EOU_UBR)
     , sum(grp.EOU_UER)
     , sum(grp.QUANTITY)
     , sum(grp.BILL_QUANTITY)
    FROM (
    SELECT /*+ ORDERED */
      p_worker_id                         AS WORKER_ID
    , 1                                   AS SLICE_ID
    , erdl.Project_ID                     AS PROJECT_ID
    , scope.Task_ID                       AS TASK_ID
    , -1                                  AS PERSON_ID
    , scope.Project_Org_ID                AS PROJECT_ORG_ID
    , scope.Project_Organization_ID       AS PROJECT_ORGANIZATION_ID
    , scope.Project_Type_Class            AS PROJECT_TYPE_CLASS
    , scope.Customer_ID                   AS CUSTOMER_ID
    , -1                                  AS EXPENDITURE_ORG_ID
    , scope.Expenditure_Organization_ID   AS EXPENDITURE_ORGANIZATION_ID
    , -1                                  AS JOB_ID
    , -1                                  AS VENDOR_ID
    , -1                                  AS WORK_TYPE_ID
    , scope.Exp_Evt_Type_ID               AS EXP_EVT_TYPE_ID
    , PJI_FM_SUM_MAIN.g_null              AS EXPENDITURE_TYPE
    , scope.Event_Type                    AS EVENT_TYPE
    , scope.Event_Type_Classification     AS EVENT_TYPE_CLASSIFICATION
    , PJI_FM_SUM_MAIN.g_null              AS EXPENDITURE_CATEGORY
    , scope.Revenue_Category              AS REVENUE_CATEGORY
    , 'PJI$NULL'                          AS NON_LABOR_RESOURCE
    , -1                                  AS BOM_LABOR_RESOURCE_ID
    , -1                                  AS BOM_EQUIPMENT_RESOURCE_ID
    , -1                                  AS INVENTORY_ITEM_ID
    , PJI_FM_SUM_MAIN.g_null              AS SYSTEM_LINKAGE_FUNCTION
    , 'Y'                                 AS PJI_PROJECT_RECORD_FLAG
    , 'N'                                 AS PJI_RESOURCE_RECORD_FLAG
    , -1                                  AS CODE_COMBINATION_ID
    , Greatest(scope.GL_Date,l_min_date)  AS PRVDR_GL_DATE
    , Greatest(scope.GL_Date,l_min_date)  AS RECVR_GL_DATE
    , scope.GL_Period_Name                AS GL_PERIOD_NAME
    , Greatest(scope.PA_Date,l_min_date)  AS PRVDR_PA_DATE
    , Greatest(scope.PA_Date,l_min_date)  AS RECVR_PA_DATE
    , scope.PA_Period_Name                AS PA_PERIOD_NAME
    , erdl.Funding_Currency_Code          AS TXN_CURRENCY_CODE
    , decode(scope.line_source_type,
        'R', (erdl.Funding_Revenue_Amount),
        'L', (-erdl.Funding_Revenue_Amount)
      )                                   AS TXN_REVENUE
    , to_number(null)                     AS TXN_RAW_COST
    , to_number(null)                     AS TXN_BILL_RAW_COST
    , to_number(null)                     AS TXN_BURDENED_COST
    , to_number(null)                     AS TXN_BILL_BURDENED_COST
    , to_number(null)                     AS TXN_UBR
    , to_number(null)                     AS TXN_UER
    , decode(scope.line_source_type,
        'R', (erdl.Project_Revenue_Amount),
        'L', (-erdl.Project_Revenue_Amount)
      )                                   AS PRJ_REVENUE
    , to_number(null)                     AS PRJ_RAW_COST
    , to_number(null)                     AS PRJ_BILL_RAW_COST
    , to_number(null)                     AS PRJ_BURDENED_COST
    , to_number(null)                     AS PRJ_BILL_BURDENED_COST
    , to_number(null)                     AS PRJ_UBR
    , to_number(null)                     AS PRJ_UER
    , decode(scope.line_source_type,
        'R', (erdl.Projfunc_Revenue_Amount),
        'L', (-erdl.Projfunc_Revenue_Amount)
      )                                   AS POU_REVENUE
    , to_number(null)                     AS POU_RAW_COST
    , to_number(null)                     AS POU_BILL_RAW_COST
    , to_number(null)                     AS POU_BURDENED_COST
    , to_number(null)                     AS POU_BILL_BURDENED_COST
    , to_number(null)                     AS POU_UBR
    , to_number(null)                     AS POU_UER
    , to_number(null)                     AS EOU_RAW_COST
    , to_number(null)                     AS EOU_BILL_RAW_COST
    , to_number(null)                     AS EOU_BURDENED_COST
    , to_number(null)                     AS EOU_BILL_BURDENED_COST
    , to_number(null)                     AS EOU_UBR
    , to_number(null)                     AS EOU_UER
    , to_number(null)                     AS QUANTITY
    , to_number(null)                     AS BILL_QUANTITY
    FROM
        PJI_FM_REXT_ERDL               scope
      , pa_cust_event_rdl_all           erdl
    WHERE
          scope.worker_id = p_worker_id
      and scope.erdl_rowid = erdl.rowid
      and scope.event_num = erdl.event_num
      and NVL(scope.task_id,-1) = NVL(erdl.task_id,-1)
    )  grp
    GROUP BY
       grp.WORKER_ID
     , grp.SLICE_ID
     , grp.PROJECT_ID
     , grp.TASK_ID
     , grp.PERSON_ID
     , grp.PROJECT_ORG_ID
     , grp.PROJECT_ORGANIZATION_ID
     , grp.PROJECT_TYPE_CLASS
     , grp.CUSTOMER_ID
     , grp.EXPENDITURE_ORG_ID
     , grp.EXPENDITURE_ORGANIZATION_ID
     , grp.JOB_ID
     , grp.VENDOR_ID
     , grp.WORK_TYPE_ID
     , grp.EXP_EVT_TYPE_ID
     , grp.EXPENDITURE_TYPE
     , grp.EVENT_TYPE
     , grp.EVENT_TYPE_CLASSIFICATION
     , grp.EXPENDITURE_CATEGORY
     , grp.REVENUE_CATEGORY
     , grp.NON_LABOR_RESOURCE
     , grp.BOM_LABOR_RESOURCE_ID
     , grp.BOM_EQUIPMENT_RESOURCE_ID
     , grp.INVENTORY_ITEM_ID
     , grp.SYSTEM_LINKAGE_FUNCTION
     , grp.PJI_PROJECT_RECORD_FLAG
     , grp.PJI_RESOURCE_RECORD_FLAG
     , grp.CODE_COMBINATION_ID
     , grp.PRVDR_GL_DATE
     , grp.RECVR_GL_DATE
     , grp.GL_PERIOD_NAME
     , grp.PRVDR_PA_DATE
     , grp.RECVR_PA_DATE
     , grp.PA_PERIOD_NAME
     , grp.TXN_CURRENCY_CODE
     ;

    end if;   --  EXTRACTION_TYPE <> 'FULL'

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_ERDL(p_worker_id);');

    -- truncate intermediate tables no longer required
    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_REXT_ERDL' , 'NORMAL',null);

    commit;

  end EXTRACT_BATCH_ERDL;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_DINV
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_DINV (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_from_project_id number := 0;
    l_to_project_id   number := 0;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_DINV(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    INSERT /*+ APPEND */ INTO PJI_FM_EXTR_DINVC
    ( WORKER_ID
    , ROW_ID
    , PROJECT_ORG_ID
    , PROJECT_ORGANIZATION_ID
    , PROJECT_ID
    , PJI_PROJECT_STATUS
    , DRAFT_INVOICE_NUM
    , UNBILLED_RECEIVABLE_DR
    , UNEARNED_REVENUE_CR
    , TRANSFER_STATUS_CODE
    , GL_DATE
    , PA_DATE
    , SYSTEM_REFERENCE
    , APPROVED_DATE
    , APPROVED_BY_PERSON_ID
    , CANCEL_CREDIT_MEMO_FLAG
    , WRITE_OFF_FLAG
    , INTER_COMPANY_BILLING_FLAG
    , PJI_SUMMARIZED_FLAG
    , CUSTOMER_ID
    , APPROVED_FLAG
    , PJI_DATE_RANGE_FLAG
    )
    SELECT /*+ ordered
               full(bat)  use_hash(bat)   parallel(bat)
               full(ppa)  use_hash(ppa)   parallel(ppa)
               full(ptyp) use_hash(ptyp)
               full(dinv) use_hash(dinv)  parallel(dinv)
               full(agr)  use_hash(agr)   parallel(agr)   */
      p_worker_id                      worker_id
    , dinv.rowid                       row_id
    , nvl(ppa.org_id, -1)              project_org_id
    , ppa.carrying_out_organization_id project_organization_id
    , dinv.project_id                  project_id
    , bat.pji_project_status           pji_project_status
    , dinv.draft_invoice_num           draft_invoice_num
    , dinv.unbilled_receivable_dr      unbilled_receivable_dr
    , dinv.unearned_revenue_cr         unearned_revenue_cr
    , dinv.transfer_status_code        transfer_status_code
    , dinv.gl_date                     gl_date
    , dinv.pa_date                     pa_date
    , dinv.system_reference            system_reference
    , dinv.approved_date               approved_date
    , dinv.approved_by_person_id       approved_by_person_id
    , nvl2(dinv.draft_invoice_num_credited,'Y','N')     cancel_credit_memo_flag
    , dinv.write_off_flag              write_off_flag
    , ptyp.cc_prvdr_flag               inter_company_billing_flag
    , dinv.pji_summarized_flag         pji_summarized_flag
    , agr.customer_id                  customer_id
    , decode(nvl(dinv.approved_by_person_id,
                 -1), -1, 'N','Y')     approved_flag
    , 'Y'                              pji_date_range_flag
    -- the flag cc_prvdr_flag on the project_type indicates whether
    -- the project is used for inter project billings
    -- since we are considering only external revenue to be consistent we
    -- need to consider only the external invoices
    -- NOTE for cost we will consider everything (external + internal)
    -- this skews the margin but ...
    FROM
            pji_fm_proj_batch_map            bat
          , pa_projects_all                  ppa
          , pa_project_types_all             ptyp
          , pa_draft_invoices_all            dinv
          , pa_agreements_all                agr
    WHERE
          l_extraction_type = 'FULL'
      and bat.worker_id = p_worker_id
      and ppa.project_id = bat.project_id
      and ppa.project_type = ptyp.project_type
      and nvl(ppa.org_id,-1) = nvl(ptyp.org_id,-1)
    -- and ptyp.cc_prvdr_flag <> 'Oracle Inter-Project'
      and dinv.gl_date is not null
      and dinv.pa_date is not null
      and ppa.project_id = dinv.project_id
      and bat.extraction_type = 'F'
    -- the pji_summarized_flag will have other values besides N and null
    -- to indicate if the invoice is still open
    -- Thus for incremental we need to pick all the invoices which have the
    -- flag as not null.  Then only if the flag is N do we do the incremental
    -- processing.  But if the value is something else then we use it only to
    -- check activities that might have happened on the AR side
           -- and dinv.gl_date between bat.start_date and bat.end_date
      and dinv.system_reference is not null
      and dinv.system_reference <> 0
      and dinv.agreement_id = agr.agreement_id
    union all
    SELECT /*+ ordered
               full(bat)
               index(drv, PA_DRAFT_INVOICES_U1)
               use_nl(dinv, ppa, ptyp, agr)
               parallel(bat) parallel(dinv) parallel(ppa)
               parallel(ptyp) parallel(agr) */
      p_worker_id                      worker_id
    , dinv.rowid                       row_id
    , nvl(ppa.org_id, -1)              project_org_id
    , ppa.carrying_out_organization_id project_organization_id
    , dinv.project_id                  project_id
    , bat.pji_project_status           pji_project_status
    , dinv.draft_invoice_num           draft_invoice_num
    , dinv.unbilled_receivable_dr      unbilled_receivable_dr
    , dinv.unearned_revenue_cr         unearned_revenue_cr
    , dinv.transfer_status_code        transfer_status_code
    , dinv.gl_date                     gl_date
    , dinv.pa_date                     pa_date
    , dinv.system_reference            system_reference
    , dinv.approved_date               approved_date
    , dinv.approved_by_person_id       approved_by_person_id
    , nvl2(dinv.draft_invoice_num_credited,'Y','N')     cancel_credit_memo_flag
    , dinv.write_off_flag              write_off_flag
    , ptyp.cc_prvdr_flag               inter_company_billing_flag
    , dinv.pji_summarized_flag         pji_summarized_flag
    , agr.customer_id                  customer_id
    , decode(nvl(dinv.approved_by_person_id,
                 -1), -1, 'N','Y')     approved_flag
    , 'Y'                              pji_date_range_flag
    -- the flag cc_prvdr_flag on the project_type indicates whether
    -- the project is used for inter project billings
    -- since we are considering only external revenue to be consistent we
    -- need to consider only the external invoices
    -- NOTE for cost we will consider everything (external + internal)
    -- this skews the margin but ...
    FROM
            pji_fm_proj_batch_map            bat
          , pa_draft_invoices_all            dinv
          , pa_projects_all                  ppa
          , pa_project_types_all             ptyp
          , pa_agreements_all                agr
    WHERE
          l_extraction_type = 'INCREMENTAL'
      and bat.worker_id = p_worker_id
      and bat.project_id = dinv.project_id
      and ppa.project_id = bat.project_id
      and ppa.project_type = ptyp.project_type
      and nvl(ppa.org_id,-1) = nvl(ptyp.org_id,-1)
--      and ptyp.cc_prvdr_flag <> 'Oracle Inter-Project'
      and dinv.gl_date is not null
      and dinv.pa_date is not null
      and ppa.project_id = dinv.project_id
      and bat.extraction_type = 'F'
    -- the pji_summarized_flag will have other values besides N and null
    -- to indicate if the invoice is still open
    -- Thus for incremental we need to pick all the invoices which have the
    -- flag as not null.  Then only if the flag is N do we do the incremental
    -- processing.  But if the value is something else then we use it only to
    -- check activities that might have happened on the AR side
           -- and dinv.gl_date between bat.start_date and bat.end_date
      and dinv.system_reference is not null
      and dinv.system_reference <> 0
      and dinv.agreement_id = agr.agreement_id
    union all
    SELECT /*+ ordered
               index(dinv PA_DRAFT_INVOICES_N11)
               full(bat) use_nl(dinv, ppa, ptyp, agr)
               parallel(bat) parallel(dinv) parallel(ppa)
               parallel(ptyp) parallel(agr) */
      p_worker_id                      worker_id
    , dinv.rowid                       row_id
    , nvl(ppa.org_id, -1)              project_org_id
    , ppa.carrying_out_organization_id project_organization_id
    , dinv.project_id                  project_id
    , bat.pji_project_status           pji_project_status
    , dinv.draft_invoice_num           draft_invoice_num
    , dinv.unbilled_receivable_dr      unbilled_receivable_dr
    , dinv.unearned_revenue_cr         unearned_revenue_cr
    , dinv.transfer_status_code        transfer_status_code
    , dinv.gl_date                     gl_date
    , dinv.pa_date                     pa_date
    , dinv.system_reference            system_reference
    , dinv.approved_date               approved_date
    , dinv.approved_by_person_id       approved_by_person_id
    , nvl2(dinv.draft_invoice_num_credited,'Y','N')     cancel_credit_memo_flag
    , dinv.write_off_flag              write_off_flag
    , ptyp.cc_prvdr_flag               inter_company_billing_flag
    , dinv.pji_summarized_flag         pji_summarized_flag
    , agr.customer_id                  customer_id
    , decode(nvl(dinv.approved_by_person_id,
                 -1), -1, 'N','Y')     approved_flag
    , 'Y'                              pji_date_range_flag
    -- the flag cc_prvdr_flag on the project_type indicates whether
    -- the project is used for inter project billings
    -- since we are considering only external revenue to be consistent we
    -- need to consider only the external invoices
    -- NOTE for cost we will consider everything (external + internal)
    -- this skews the margin but ...
    FROM
            pji_fm_proj_batch_map            bat
          , pa_draft_invoices_all            dinv
          , pa_projects_all                  ppa
          , pa_project_types_all             ptyp
          , pa_agreements_all                agr
    WHERE
          l_extraction_type = 'INCREMENTAL'
      and bat.worker_id = p_worker_id
      and ppa.project_id = bat.project_id
      and dinv.project_id = bat.project_id
      and ppa.project_type = ptyp.project_type
      and nvl(ppa.org_id,-1) = nvl(ptyp.org_id,-1)
--      and ptyp.cc_prvdr_flag <> 'Oracle Inter-Project'
      and dinv.gl_date is not null
      and dinv.pa_date is not null
      and ppa.project_id = dinv.project_id
      and bat.extraction_type = 'I'
      and dinv.pji_summarized_flag = 'N'
    -- the pji_summarized_flag will have other values besides N and null
    -- to indicate if the invoice is still open
    -- Thus for incremental we need to pick all the invoices which have the
    -- flag as not null.  Then only if the flag is N do we do the incremental
    -- processing.  But if the value is something else then we use it only to
    -- check activities that might have happened on the AR side
           -- and dinv.gl_date between bat.start_date and bat.end_date
      and dinv.system_reference is not null
      and dinv.system_reference <> 0
      and dinv.agreement_id = agr.agreement_id
    union all
    SELECT /*+ ordered
               full(bat)  use_hash(bat)   parallel(bat)
               full(ppa)  use_hash(ppa)   parallel(ppa)
               full(ptyp) use_hash(ptyp)
               full(dinv) use_hash(dinv)  parallel(dinv)
               full(agr)  use_hash(agr)   parallel(agr)   */
      p_worker_id                      worker_id
    , dinv.rowid                       row_id
    , nvl(ppa.org_id, -1)              project_org_id
    , ppa.carrying_out_organization_id project_organization_id
    , dinv.project_id                  project_id
    , bat.pji_project_status           pji_project_status
    , dinv.draft_invoice_num           draft_invoice_num
    , dinv.unbilled_receivable_dr      unbilled_receivable_dr
    , dinv.unearned_revenue_cr         unearned_revenue_cr
    , dinv.transfer_status_code        transfer_status_code
    , dinv.gl_date                     gl_date
    , dinv.pa_date                     pa_date
    , dinv.system_reference            system_reference
    , dinv.approved_date               approved_date
    , dinv.approved_by_person_id       approved_by_person_id
    , nvl2(dinv.draft_invoice_num_credited,'Y','N')     cancel_credit_memo_flag
    , dinv.write_off_flag              write_off_flag
    , ptyp.cc_prvdr_flag               inter_company_billing_flag
    , dinv.pji_summarized_flag         pji_summarized_flag
    , agr.customer_id                  customer_id
    , decode(nvl(dinv.approved_by_person_id,
                 -1), -1, 'N','Y')     approved_flag
    , 'Y'                              pji_date_range_flag
    -- the flag cc_prvdr_flag on the project_type indicates whether
    -- the project is used for inter project billings
    -- since we are considering only external revenue to be consistent we
    -- need to consider only the external invoices
    -- NOTE for cost we will consider everything (external + internal)
    -- this skews the margin but ...
    FROM
            pji_fm_proj_batch_map            bat
          , pa_projects_all                  ppa
          , pa_project_types_all             ptyp
          , pa_draft_invoices_all            dinv
          , pa_agreements_all                agr
    WHERE
          l_extraction_type = 'PARTIAL'
      and bat.worker_id = p_worker_id
      and ppa.project_id = bat.project_id
      and ppa.project_type = ptyp.project_type
      and nvl(ppa.org_id,-1) = nvl(ptyp.org_id,-1)
--      and ptyp.cc_prvdr_flag <> 'Oracle Inter-Project'
      and dinv.gl_date is not null
      and dinv.pa_date is not null
      and ppa.project_id = dinv.project_id
      and bat.extraction_type = 'P'
    -- the pji_summarized_flag will have other values besides N and null
    -- to indicate if the invoice is still open
    -- Thus for incremental we need to pick all the invoices which have the
    -- flag as not null.  Then only if the flag is N do we do the incremental
    -- processing.  But if the value is something else then we use it only to
    -- check activities that might have happened on the AR side
           -- and dinv.gl_date between bat.start_date and bat.end_date
      and dinv.system_reference is not null
      and dinv.system_reference <> 0
      and dinv.agreement_id = agr.agreement_id;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_DINV(p_worker_id);');

    commit;

  end EXTRACT_BATCH_DINV;

  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_DINV_ROWS
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_DINV_ROWS (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(15);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;
    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.MARK_EXTRACTED_DINV_ROWS(p_worker_id);')) then
      return;
    end if;

    UPDATE pa_draft_invoices_all    dinv
    SET    dinv.pji_summarized_flag = 'O'
    -- later the flag is updated to null for those invoices that are closed
    WHERE  dinv.rowid in (select row_id
                          from   PJI_FM_EXTR_DINVC
                          where  worker_id = p_worker_id
                            and  transfer_status_code = 'A'
                         )
       AND ( (l_extraction_type = 'INCREMENTAL'
              and  nvl(dinv.pji_summarized_flag,'O') <> 'O')
                   or
                   l_extraction_type <> 'INCREMENTAL'
           )
    ;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.MARK_EXTRACTED_DINV_ROWS(p_worker_id);');

    commit;

  end MARK_EXTRACTED_DINV_ROWS;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_DINVITEM
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_DINVITEM (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_from_project_id number := 0;
    l_to_project_id   number := 0;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_DINVITEM(p_worker_id);')) then
      return;
    end if;

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                               'CURRENT_BATCH') = 1) then
    -- implicit commit
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_FM_EXTR_DINVC',
                                 percent => 10,
                                 degree  => PJI_UTILS.
                                            GET_DEGREE_OF_PARALLELISM);
    -- implicit commit
    FND_STATS.GATHER_COLUMN_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                  tabname => 'PJI_FM_EXTR_DINVC',
                                  colname => 'PROJECT_ID',
                                  percent => 10,
                                  degree  => PJI_UTILS.
                                             GET_DEGREE_OF_PARALLELISM);
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    INSERT /*+ APPEND */ INTO PJI_FM_EXTR_DINVCITM
    ( WORKER_ID
    , PROJECT_ORG_ID
    , PROJECT_ORGANIZATION_ID
    , PROJECT_ID
    , DRAFT_INVOICE_NUM
    , GL_DATE
    , PA_DATE
    , CANCEL_CREDIT_MEMO_FLAG
    , WRITE_OFF_FLAG
    , INTER_COMPANY_BILLING_FLAG
    , PJI_SUMMARIZED_FLAG
    , POU_INVOICE_AMOUNT
    , PRJ_INVOICE_AMOUNT
    , CUSTOMER_ID
    , APPROVED_FLAG
    , PJI_DATE_RANGE_FLAG
    , TRANSFER_STATUS_CODE
    , PJI_RECORD_TYPE
    , AR_INVOICE_COUNT
    , AR_INVOICE_WRITEOFF_COUNT
    , AR_CREDIT_MEMO_COUNT
    , AR_UNAPPR_INVOICE_COUNT
    , AR_APPR_INVOICE_COUNT
    )
    SELECT /*+ ordered
               full(part) use_hash(part)
               full(item) use_hash(item) parallel(item) */
      p_worker_id                              worker_id
    , nvl(part.project_org_id, -1)             project_org_id
    , part.project_organization_id             project_organization_id
    , part.project_id                          project_id
    , part.draft_invoice_num                   draft_invoice_num
    , part.gl_date                             gl_date
    , part.pa_date                             pa_date
    , part.cancel_credit_memo_flag             cancel_credit_memo_flag
    , part.write_off_flag                      write_off_flag
    , part.inter_company_billing_flag          inter_company_billing_flag
    , part.pji_summarized_flag                 pji_summarized_flag
    , nvl(sum(item.projfunc_bill_amount),0)    pou_invoice_amount
    , nvl(sum(item.project_bill_amount),0)     prj_invoice_amount
    , part.customer_id                         customer_id
    , part.approved_flag                       approved_flag
    , part.pji_date_range_flag                 pji_date_range_flag
    , part.transfer_status_code                transfer_status_code
    , decode(part.transfer_status_code,        -- Activity 'A' vs Snapshot 'S'
             'A','A','S')                      pji_record_type
    , to_number(null)                          ar_invoice_count
    , to_number(null)                          ar_invoice_writeoff_count
    , to_number(null)                          ar_credit_memo_count
    , to_number(null)                          ar_unappr_invoice_count
    , to_number(null)                          ar_appr_invoice_count
    FROM
      PJI_FM_EXTR_DINVC                part
    , pa_draft_invoice_items          item
    WHERE
          l_extraction_type = 'FULL'
      and part.worker_id      = p_worker_id
      and part.project_id        = item.project_id
      and part.draft_invoice_num = item.draft_invoice_num
      and item.invoice_line_type <> 'NET ZERO ADJUSTMENT'
      and part.gl_date is not null
      and part.pa_date is not null
    GROUP BY part.project_id,
             nvl(part.project_org_id, -1),
             part.project_organization_id,
             part.draft_invoice_num,
             part.gl_date,
             part.pa_date,
             part.write_off_flag,
             part.customer_id,
             part.approved_flag,
             part.pji_date_range_flag,
             part.transfer_status_code,
             part.cancel_credit_memo_flag,
             part.inter_company_billing_flag,
             part.pji_summarized_flag
    union all
    SELECT /*+ ordered
               full(part)
            */
      p_worker_id                              worker_id
    , nvl(part.project_org_id, -1)             project_org_id
    , part.project_organization_id             project_organization_id
    , part.project_id                          project_id
    , part.draft_invoice_num                   draft_invoice_num
    , part.gl_date                             gl_date
    , part.pa_date                             pa_date
    , part.cancel_credit_memo_flag             cancel_credit_memo_flag
    , part.write_off_flag                      write_off_flag
    , part.inter_company_billing_flag          inter_company_billing_flag
    , part.pji_summarized_flag                 pji_summarized_flag
    , nvl(sum(item.projfunc_bill_amount),0)    pou_invoice_amount
    , nvl(sum(item.project_bill_amount),0)     prj_invoice_amount
    , part.customer_id                         customer_id
    , part.approved_flag                       approved_flag
    , part.pji_date_range_flag                 pji_date_range_flag
    , part.transfer_status_code                transfer_status_code
    , decode(part.transfer_status_code,        -- Activity 'A' vs Snapshot 'S'
             'A','A','S')                      pji_record_type
    , to_number(null)                          ar_invoice_count
    , to_number(null)                          ar_invoice_writeoff_count
    , to_number(null)                          ar_credit_memo_count
    , to_number(null)                          ar_unappr_invoice_count
    , to_number(null)                          ar_appr_invoice_count
    FROM
      PJI_FM_EXTR_DINVC                part
    , pa_draft_invoice_items          item
    WHERE
          l_extraction_type = 'INCREMENTAL'
      and part.worker_id      = p_worker_id
      and part.project_id        = item.project_id
      and part.draft_invoice_num = item.draft_invoice_num
      and item.invoice_line_type <> 'NET ZERO ADJUSTMENT'
      and part.gl_date is not null
      and part.pa_date is not null
    GROUP BY part.project_id,
             nvl(part.project_org_id, -1),
             part.project_organization_id,
             part.draft_invoice_num,
             part.gl_date,
             part.pa_date,
             part.write_off_flag,
             part.customer_id,
             part.approved_flag,
             part.pji_date_range_flag,
             part.transfer_status_code,
             part.cancel_credit_memo_flag,
             part.inter_company_billing_flag,
             part.pji_summarized_flag
    union all
    SELECT /*+ ordered
               full(part) use_hash(part)
               full(item) use_hash(item)  parallel(item)  */
      p_worker_id                              worker_id
    , nvl(part.project_org_id, -1)             project_org_id
    , part.project_organization_id             project_organization_id
    , part.project_id                          project_id
    , part.draft_invoice_num                   draft_invoice_num
    , part.gl_date                             gl_date
    , part.pa_date                             pa_date
    , part.cancel_credit_memo_flag             cancel_credit_memo_flag
    , part.write_off_flag                      write_off_flag
    , part.inter_company_billing_flag          inter_company_billing_flag
    , part.pji_summarized_flag                 pji_summarized_flag
    , nvl(sum(item.projfunc_bill_amount),0)    pou_invoice_amount
    , nvl(sum(item.project_bill_amount),0)     prj_invoice_amount
    , part.customer_id                         customer_id
    , part.approved_flag                       approved_flag
    , part.pji_date_range_flag                 pji_date_range_flag
    , part.transfer_status_code                transfer_status_code
    , decode(part.transfer_status_code,        -- Activity 'A' vs Snapshot 'S'
             'A','A','S')                      pji_record_type
    , to_number(null)                          ar_invoice_count
    , to_number(null)                          ar_invoice_writeoff_count
    , to_number(null)                          ar_credit_memo_count
    , to_number(null)                          ar_unappr_invoice_count
    , to_number(null)                          ar_appr_invoice_count
    FROM
      PJI_FM_EXTR_DINVC                part
    , pa_draft_invoice_items          item
    WHERE
          l_extraction_type = 'PARTIAL'
      and part.worker_id      = p_worker_id
      and part.project_id        = item.project_id
      and part.draft_invoice_num = item.draft_invoice_num
      and item.invoice_line_type <> 'NET ZERO ADJUSTMENT'
      and part.gl_date is not null
      and part.pa_date is not null
    GROUP BY part.project_id,
             nvl(part.project_org_id, -1),
             part.project_organization_id,
             part.draft_invoice_num,
             part.gl_date,
             part.pa_date,
             part.write_off_flag,
             part.customer_id,
             part.approved_flag,
             part.pji_date_range_flag,
             part.transfer_status_code,
             part.cancel_credit_memo_flag,
             part.inter_company_billing_flag,
             part.pji_summarized_flag
    union all
    SELECT
      p_worker_id                              worker_id
    , nvl(part.project_org_id, -1)             project_org_id
    , part.project_organization_id             project_organization_id
    , part.project_id                          project_id
    , part.draft_invoice_num                   draft_invoice_num
    , part.gl_date                             gl_date
    , part.pa_date                             pa_date
    , part.cancel_credit_memo_flag             cancel_credit_memo_flag
    , part.write_off_flag                      write_off_flag
    , part.inter_company_billing_flag          inter_company_billing_flag
    , part.pji_summarized_flag                 pji_summarized_flag
    , to_number(null)                          pou_invoice_amount
    , to_number(null)                          prj_invoice_amount
    , part.customer_id                         customer_id
    , part.approved_flag                       approved_flag
    , part.pji_date_range_flag                 pji_date_range_flag
    , part.transfer_status_code                transfer_status_code
    , decode(part.transfer_status_code,        -- Activity 'A' vs Snapshot 'S'
             'A','A','S')                      pji_record_type
    , decode(part.pji_date_range_flag || '_' ||
             decode(part.transfer_status_code,
                    'A','A','S'),
             'Y_A', 1, 0)                      ar_invoice_count
    , decode(part.pji_date_range_flag || '_' ||
             decode(part.transfer_status_code,
                    'A','A','S') || '_' ||
             part.write_off_flag,
             'Y_A_Y', 1,0)                     ar_invoice_writeoff_count
    , decode(part.pji_date_range_flag || '_' ||
             decode(part.transfer_status_code,
                    'A','A','S') || '_' ||
             part.cancel_credit_memo_flag,
             'Y_A_Y', 1,0)                     ar_credit_memo_count
    , decode(decode(part.transfer_status_code,
                    'A','A','S') || '_' ||
             part.approved_flag,
             'S_N',1,0)                        ar_unappr_invoice_count
    , decode(decode(part.transfer_status_code,
                    'A','A','S') || '_' ||
             part.approved_flag,
             'S_Y',1,0)                        ar_appr_invoice_count
    FROM
      PJI_FM_EXTR_DINVC part
    WHERE
          part.worker_id = p_worker_id
      and part.gl_date is not null
      and part.pa_date is not null;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_DINVITEM(p_worker_id);');

    commit;

  end EXTRACT_BATCH_DINVITEM;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_ARINV
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_ARINV (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_ARINV(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    INSERT /*+ APPEND */ INTO PJI_FM_EXTR_ARINV
    ( WORKER_ID
    , ROW_ID
    , PROJECT_ID
    , PROJECT_ORG_ID
    , PROJECT_ORGANIZATION_ID
    , DRAFT_INVOICE_NUM
    , CASH_APPLIED_AMOUNT
    , AMOUNT_DUE_REMAINING
    , AMOUNT_OVERDUE_REMAINING
    , MAX_ACTUAL_DATE_CLOSED
    , CUSTOMER_ID
    , PJI_SUMMARIZED_FLAG
    , BATCH_ID
    )
    SELECT
      p_worker_id worker_id
    , row_id
    , project_id
    , project_org_id
    , project_organization_id
    , draft_invoice_num
    , cash_applied_amount
    , amount_due_remaining
    , amount_overdue_remaining
    , actual_date_closed
    , customer_id
    , pji_summarized_flag
    , ceil(ROWNUM / PJI_FM_SUM_MAIN.g_commit_threshold)
    from
    (SELECT /*+ ordered
               parallel(part)
               full(bat)  use_hash(bat) */
      part.rowid                          row_id
    , part.project_id                     project_id
    , bat.project_org_id
    , bat.project_organization_id
    , part.draft_invoice_num              draft_invoice_num
    , nvl(sum(ar.amount_applied),0)       cash_applied_amount
    , decode(sign(ar.due_date - trunc(sysdate)),
             -1, 0, nvl(sum(ar.amount_due_remaining),
                        0))                amount_due_remaining
    , decode(sign(ar.due_date - trunc(sysdate)),
             -1, nvl(sum(ar.amount_due_remaining),0),
             0)                           amount_overdue_remaining
    , max(ar.actual_date_closed)          actual_date_closed
    , trx.bill_to_customer_id             customer_id
    , part.pji_summarized_flag
    FROM
            pa_draft_invoices_all         part
          , pji_fm_proj_batch_map         bat
          , ra_customer_trx_all           trx
          , ar_payment_schedules_all      ar
    WHERE
          bat.worker_id            = p_worker_id
      and part.project_id          = bat.project_id
      and part.gl_date             is not null
      and part.pa_date             is not null
      and part.pji_summarized_flag = 'O'
      and trx.customer_trx_id      = part.system_reference
      and ar.customer_trx_id       = trx.customer_trx_id
    GROUP BY
          part.rowid,
          part.project_id,
          bat.project_org_id,
          bat.project_organization_id,
          part.draft_invoice_num,
          ar.due_date,
          trx.bill_to_customer_id,
          part.pji_summarized_flag);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_EXTR.EXTRACT_BATCH_ARINV(p_worker_id);');

    commit;

  end EXTRACT_BATCH_ARINV;


  -- -----------------------------------------------------
  -- procedure MARK_FULLY_PAID_INVOICES_PRE
  -- -----------------------------------------------------
  procedure MARK_FULLY_PAID_INVOICES_PRE (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
              'PJI_FM_EXTR.MARK_FULLY_PAID_INVOICES_PRE(p_worker_id);')) then
      return;
    end if;

    insert /*+ append */ into PJI_HELPER_BATCH_MAP
    (
      BATCH_ID,
      WORKER_ID,
      STATUS
    )
    select
      distinct
      BATCH_ID,
      null,
      null
    from
      PJI_FM_EXTR_ARINV
    where
      PJI_SUMMARIZED_FLAG = 'O';

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_EXTR.MARK_FULLY_PAID_INVOICES_PRE(p_worker_id);');

    commit;

  end MARK_FULLY_PAID_INVOICES_PRE;


  -- -----------------------------------------------------
  -- procedure MARK_FULLY_PAID_INVOICES
  -- -----------------------------------------------------
  procedure MARK_FULLY_PAID_INVOICES (p_worker_id in number) is

    l_process            varchar2(30);
    l_leftover_batches   number;
    l_helper_batch_id    number;
    l_row_count          number;
    l_parallel_processes number;

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_EXTR.MARK_FULLY_PAID_INVOICES(p_worker_id);')) then
      return;
    end if;

    l_parallel_processes := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                            (PJI_FM_SUM_MAIN.g_process, 'PARALLEL_PROCESSES');

    select count(*)
    into   l_leftover_batches
    from   PJI_HELPER_BATCH_MAP
    where  WORKER_ID = p_worker_id and
           STATUS = 'P';

    l_helper_batch_id   := 0;

    while l_helper_batch_id >= 0 loop

      if (l_leftover_batches > 0) then

        l_leftover_batches := l_leftover_batches - 1;

        select  BATCH_ID
        into    l_helper_batch_id
        from    PJI_HELPER_BATCH_MAP
        where   WORKER_ID = p_worker_id and
                STATUS = 'P' and
                ROWNUM = 1;

      else

        update    PJI_HELPER_BATCH_MAP
        set       WORKER_ID = p_worker_id,
                  STATUS = 'P'
        where     WORKER_ID is null and
                  ROWNUM = 1
        returning BATCH_ID
        into      l_helper_batch_id;

      end if;

      if (sql%rowcount <> 0) then

        commit;

        UPDATE pa_draft_invoices_all dinv
        SET dinv.pji_summarized_flag = NULL
        WHERE dinv.rowid in (SELECT /*+ cardinality(ar, 1) */
                                    ar.row_id
                             FROM   PJI_FM_EXTR_ARINV ar
                             WHERE  1 = 2 -- We will always extract
                                          -- the AR snapshots for now.
                               AND  ar.pji_summarized_flag = 'O'
                               AND  ar.batch_id = l_helper_batch_id);

        update PJI_HELPER_BATCH_MAP
        set    STATUS = 'C'
        where  WORKER_ID = p_worker_id and
               BATCH_ID = l_helper_batch_id;

        commit;

      else

        select count(*)
        into   l_row_count
        from   PJI_HELPER_BATCH_MAP
        where  nvl(STATUS, 'X') <> 'C';

        if (l_row_count = 0) then

          for x in 2 .. l_parallel_processes loop

            update PJI_SYSTEM_PRC_STATUS
            set    STEP_STATUS = 'C'
            where  PROCESS_NAME like PJI_FM_SUM_MAIN.g_process || x and
                   STEP_NAME =
                     'PJI_FM_EXTR.MARK_FULLY_PAID_INVOICES(p_worker_id);' and
                   START_DATE is null;

            commit;

          end loop;

          l_helper_batch_id := -1;

        else

          PJI_PROCESS_UTIL.SLEEP(1); -- so the CPU is not bombarded

        end if;

      end if;

      if (l_helper_batch_id >= 0) then

        for x in 2 .. l_parallel_processes loop
          if (not PJI_FM_SUM_EXTR.WORKER_STATUS(x, 'OKAY')) then
            l_helper_batch_id := -2;
          end if;
        end loop;

      end if;

    end loop;

    if (l_helper_batch_id <> -2) then

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
        'PJI_FM_EXTR.MARK_FULLY_PAID_INVOICES(p_worker_id);');

    end if;

    commit;

  end MARK_FULLY_PAID_INVOICES;


  -- -----------------------------------------------------
  -- procedure MARK_FULLY_PAID_INVOICES_POST
  -- -----------------------------------------------------
  procedure MARK_FULLY_PAID_INVOICES_POST (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_FM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
              'PJI_FM_EXTR.MARK_FULLY_PAID_INVOICES_POST(p_worker_id);')) then
      return;
    end if;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE('PJI',
                                     'PJI_HELPER_BATCH_MAP',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
      'PJI_FM_EXTR.MARK_FULLY_PAID_INVOICES_POST(p_worker_id);');

    commit;

  end MARK_FULLY_PAID_INVOICES_POST;


  -- -----------------------------------------------------
  -- procedure CLEANUP
  -- -----------------------------------------------------
  procedure CLEANUP (p_worker_id in number) is

    l_schema varchar2(30);

  begin

    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_EXTR_FUNDG', 'NORMAL',null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_EXTR_DREVN', 'NORMAL',null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_REXT_CDL', 'NORMAL',null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_REXT_CRDL', 'NORMAL',null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_REXT_ERDL', 'NORMAL',null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_EXTR_DINVC', 'NORMAL',null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_EXTR_DINVCITM', 'NORMAL',null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE( l_schema , 'PJI_FM_EXTR_ARINV', 'NORMAL',null);

  end CLEANUP;

end PJI_FM_EXTR;

/
