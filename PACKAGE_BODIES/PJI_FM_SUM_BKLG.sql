--------------------------------------------------------
--  DDL for Package Body PJI_FM_SUM_BKLG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_SUM_BKLG" AS
/* $Header: PJISF12B.pls 120.3 2005/11/16 19:43:36 appldev noship $ */

   g_last_activity_date  number;
   g_pji_schema varchar2(30);


  -- -----------------------------------------------------
  -- procedure ROWID_ACTIVITY_DATES_FIN
  -- -----------------------------------------------------
  procedure ROWID_ACTIVITY_DATES_FIN (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_BKLG.ROWID_ACTIVITY_DATES_FIN(p_worker_id);')) then
      return;
    end if;

    -- Get the minimum activity dates for each project in the current batch
    insert /*+ append */ into PJI_FM_RMAP_FIN
    (
      WORKER_ID
      , MAP_ROWID
      , PROJECT_ID
      , ACTIVITY_MIN_GL_DATE
      , ACTIVITY_MIN_PA_DATE
      , REVENUE
    )
    select /*+ ordered
               full(fin9)      use_hash(fin9)    parallel(fin9)
               full(map)       use_hash(map)     swap_join_inputs(map)
            */
      p_worker_id
      , map.rowid
      , map.project_id
      -- temptemp should consider GL and PA seperately
      , to_date(min(fin9.TIME_ID), 'J')
      , to_date(min(fin9.TIME_ID), 'J')
      -- , to_date(min(fin9.RECVR_GL_TIME_ID),'J')
      -- , to_date(min(fin9.RECVR_PA_TIME_ID),'J')
      , sum(abs(fin9.POU_REVENUE))
    from pji_pji_proj_batch_map map
      ,  PJI_FM_AGGR_FIN9      fin9
    where 1 = 1
    and   map.worker_id   = p_worker_id
    and   fin9.project_id = map.project_id
    -- temptemp should consider GL and PA seperately
    and   nvl(fin9.TIME_ID, 0) > 0
    -- and   nvl(fin9.RECVR_GL_TIME_ID,0) > 0
    -- and   nvl(fin9.RECVR_PA_TIME_ID,0) > 0
    group by
          map.rowid
          , map.project_id
    ;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_BKLG.ROWID_ACTIVITY_DATES_FIN(p_worker_id);');

    commit;

  end ROWID_ACTIVITY_DATES_FIN;


  -- -----------------------------------------------------
  -- procedure UPDATE_ACTIVITY_DATES_FIN
  -- -----------------------------------------------------
  procedure UPDATE_ACTIVITY_DATES_FIN (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_BKLG.UPDATE_ACTIVITY_DATES_FIN(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    -- Update the table pji_pji_proj_batch_map with the
    -- minimum activity dates for each project in the current batch
    UPDATE /*+ index(map, PJI_PJI_PROJ_BATCH_MAP_N1) */
           pji_pji_proj_batch_map map
    SET    ( map.ACTIVITY_MIN_GL_DATE
           , map.ACTIVITY_MIN_PA_DATE) =
           (select scope.ACTIVITY_MIN_GL_DATE
                   , scope.ACTIVITY_MIN_PA_DATE
            from   PJI_FM_RMAP_FIN     scope
            where  scope.worker_id = p_worker_id
            and    scope.MAP_ROWID = map.rowid
           )
    WHERE  1 = 1
      AND  map.WORKER_ID = p_worker_id
      AND  map.PROJECT_ID in (select scope2.PROJECT_ID
                              from   PJI_FM_RMAP_FIN     scope2
                              where  scope2.worker_id = p_worker_id
                              and    ((l_extraction_type <> 'INCREMENTAL')
                                       or
                                       scope2.REVENUE <>0
                                     )
                              )
      ;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_BKLG.UPDATE_ACTIVITY_DATES_FIN(p_worker_id);');

    commit;

  end UPDATE_ACTIVITY_DATES_FIN;


  -- -----------------------------------------------------
  -- procedure ROWID_ACTIVITY_DATES_ACT
  -- -----------------------------------------------------
  procedure ROWID_ACTIVITY_DATES_ACT (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_BKLG.ROWID_ACTIVITY_DATES_ACT(p_worker_id);')) then
      return;
    end if;

    -- Get minimum funding dates for each project in the current batch
    insert /*+ append */ into PJI_FM_RMAP_ACT
    (
      WORKER_ID
      , MAP_ROWID
      , PROJECT_ID
      , FUNDING_MIN_DATE
      , FUNDING
    )
    select /*  ordered
               full(act5)      use_hash(act5)    parallel(act5)
               full(map)       use_hash(map)     parallel(map)
            */
      p_worker_id
      , map.rowid
      , map.project_id
      -- temptemp should consider GL and PA seperately
      , to_date(min(act5.TIME_ID), 'J')
      -- , to_date(min(LEAST(act5.GL_TIME_ID,act5.PA_TIME_ID)),'J')
      , sum(abs(act5.POU_FUNDING))
    from  PJI_FM_AGGR_ACT5       act5
          , pji_pji_proj_batch_map    map
    where 1 = 1
    and   act5.worker_id  = p_worker_id
    and   act5.project_id = map.project_id
    and   map.worker_id   = p_worker_id
    group by
          map.rowid
        , map.project_id
    ;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_BKLG.ROWID_ACTIVITY_DATES_ACT(p_worker_id);');

    commit;

  end ROWID_ACTIVITY_DATES_ACT;


  -- -----------------------------------------------------
  -- procedure UPDATE_ACTIVITY_DATES_ACT
  -- -----------------------------------------------------
  procedure UPDATE_ACTIVITY_DATES_ACT (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_FM_SUM_BKLG.UPDATE_ACTIVITY_DATES_ACT(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    -- Update the table pji_pji_proj_batch_map with the
    -- minimum funding dates for each project in the current batch
    UPDATE /*+ index(map, PJI_PJI_PROJ_BATCH_MAP_N1) */
           pji_pji_proj_batch_map map
    SET    ( map.FUNDING_MIN_DATE ) =
           (select scope.FUNDING_MIN_DATE
            from   PJI_FM_RMAP_ACT     scope
            where  scope.worker_id = p_worker_id
            and    scope.MAP_ROWID = map.rowid
           )
    WHERE  1 = 1
      AND  map.WORKER_ID = p_worker_id
      AND  map.PROJECT_ID in (select scope2.PROJECT_ID
                              from   PJI_FM_RMAP_ACT     scope2
                              where  scope2.worker_id = p_worker_id
                              and    ((l_extraction_type <> 'INCREMENTAL')
                                       or
                                       scope2.FUNDING <>0
                                     )
                              )
      ;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_FM_SUM_BKLG.UPDATE_ACTIVITY_DATES_ACT(p_worker_id);');

    commit;

  end UPDATE_ACTIVITY_DATES_ACT;


  -- -----------------------------------------------------
  -- procedure SCOPE_PROJECTS_BKLG
  -- -----------------------------------------------------
  procedure SCOPE_PROJECTS_BKLG (p_worker_id in number) is

    l_process         varchar2(30);
    l_schema          varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            ( l_process, 'PJI_FM_SUM_BKLG.SCOPE_PROJECTS_BKLG(p_worker_id);'
            )) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

          UPDATE  PJI_PJI_PROJ_BATCH_MAP  upd
          set     upd.BACKLOG_EXTRACTION_STATUS=null
          where   upd.project_id in
          (
          select /*+  ORDERED
                      full(fin2)
                  */
                distinct
                map.project_id                 project_id
          From
                PJI_PJI_PROJ_BATCH_MAP      map
                , PJI_FM_AGGR_ACT3         act3
          Where 1=1
                and map.worker_id = p_worker_id
                and map.project_id = act3.project_id
                and (
          			(abs(nvl(act3.initial_funding_amount, 0))
          			   +abs(nvl(act3.additional_funding_amount, 0))
          			   +abs(nvl(act3.cancelled_funding_amount, 0))
          			   +abs(nvl(act3.funding_adjustment_amount, 0))
                    )              > 0
          			OR
          			abs(act3.revenue) > 0
          			OR
          			nvl(map.OLD_CLOSED_DATE,sysdate) <> nvl(map.NEW_CLOSED_DATE,sysdate)
          			OR
          			l_extraction_type <> 'INCREMENTAL'
                    )
          )
          ;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (l_process, 'PJI_FM_SUM_BKLG.SCOPE_PROJECTS_BKLG(p_worker_id);');

    commit;

  end SCOPE_PROJECTS_BKLG;


  -- -----------------------------------------------------
  -- procedure CLEANUP_INT_TABLE
  -- -----------------------------------------------------
  procedure CLEANUP_INT_TABLE (p_worker_id in number) is

    l_process varchar2(30);
    l_schema  varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    PJI_FM_DEBUG.CLEANUP_HOOK(l_process);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_FM_SUM_BKLG.CLEANUP_INT_TABLE(p_worker_id);'
            )) then
      return;
    end if;

    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema ,
                                     'PJI_FM_AGGR_ACT3',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_FM_SUM_BKLG.CLEANUP_INT_TABLE(p_worker_id);'
    );

    commit;

  end;


  -- -----------------------------------------------------
  -- Procedure Insert_Backlog_Updates_pvt
  -- -----------------------------------------------------
  Procedure Insert_Backlog_Updates_pvt
          (  p_worker_id                  IN number
          ,  p_project_id                 IN number
          ,  p_time_id                    IN number
          ,  p_curr_record_type_id        IN number
          ,  p_currency_code              IN varchar2
          ,  p_gl_calendar_id             IN number
          ,  p_pa_calendar_id             IN number
          ,  p_drmt_bklg                  IN number
          ,  p_strt_bklg                  IN number
          ,  p_lost_bklg                  IN number
          ,  p_actv_bklg                  IN number
          ,  p_risky_rev                  IN number
          ,  p_project_org_id             IN number
          ,  p_project_organization_id    IN number
          ,  p_calendar_type              IN varchar2
          ,  p_ex_drmt_bklg               IN number
          ,  p_ex_strt_bklg               IN number
          ,  p_ex_lost_bklg               IN number
          ,  p_ex_actv_bklg               IN number
          ,  p_ex_risky_rev               IN number
          ) is
  Begin

            INSERT INTO PJI_FM_AGGR_ACT3(
                  WORKER_ID
               ,  PROJECT_ID
               ,  PROJECT_ORG_ID
               ,  PROJECT_ORGANIZATION_ID
               ,  TIME_ID
               ,  PERIOD_TYPE_ID
               ,  CALENDAR_TYPE
               ,  GL_CALENDAR_ID
               ,  PA_CALENDAR_ID
               ,  CURR_RECORD_TYPE_ID
               ,  CURRENCY_CODE
               ,  REVENUE
               ,  FUNDING
               ,  INITIAL_FUNDING_AMOUNT
               ,  INITIAL_FUNDING_COUNT
               ,  ADDITIONAL_FUNDING_AMOUNT
               ,  ADDITIONAL_FUNDING_COUNT
               ,  CANCELLED_FUNDING_AMOUNT
               ,  CANCELLED_FUNDING_COUNT
               ,  FUNDING_ADJUSTMENT_AMOUNT
               ,  FUNDING_ADJUSTMENT_COUNT
               ,  REVENUE_WRITEOFF
               ,  AR_INVOICE_AMOUNT
               ,  AR_INVOICE_COUNT
               ,  AR_CASH_APPLIED_AMOUNT
               ,  AR_CASH_APPLIED_COUNT
               ,  AR_INVOICE_WRITEOFF_AMOUNT
               ,  AR_INVOICE_WRITEOFF_COUNT
               ,  AR_CREDIT_MEMO_AMOUNT
               ,  AR_CREDIT_MEMO_COUNT
               ,  UNBILLED_RECEIVABLES
               ,  UNEARNED_REVENUE
               ,  AR_UNAPPR_INVOICE_AMOUNT
               ,  AR_UNAPPR_INVOICE_COUNT
               ,  AR_APPR_INVOICE_AMOUNT
               ,  AR_APPR_INVOICE_COUNT
               ,  AR_AMOUNT_DUE
               ,  AR_COUNT_DUE
               ,  AR_AMOUNT_OVERDUE
               ,  AR_COUNT_OVERDUE
               ,  DORMANT_BACKLOG_INACTIV
               ,  DORMANT_BACKLOG_START
               ,  LOST_BACKLOG
               ,  ACTIVE_BACKLOG
               ,  REVENUE_AT_RISK
                   )
             SELECT
                 1                                  WORKER_ID
               ,  p_project_id                      PROJECT_ID
               ,  p_project_org_id                  PROJECT_ORG_ID
               ,  p_project_organization_id         PROJECT_ORGANIZATION_ID
               ,  p_time_id                         TIME_ID
               ,  1                                 PERIOD_TYPE_ID
               ,  p_calendar_type                   CALENDAR_TYPE
               ,  p_gl_calendar_id                  GL_CALENDAR_ID
               ,  p_pa_calendar_id                  PA_CALENDAR_ID
               ,  p_curr_record_type_id             CURR_RECORD_TYPE_ID
               ,  p_currency_code                   CURRENCY_CODE
               ,  to_number(null)                   REVENUE
               ,  to_number(null)                   FUNDING
               ,  to_number(null)                   INITIAL_FUNDING_AMOUNT
               ,  to_number(null)                   INITIAL_FUNDING_COUNT
               ,  to_number(null)                   ADDITIONAL_FUNDING_AMOUNT
               ,  to_number(null)                   ADDITIONAL_FUNDING_COUNT
               ,  to_number(null)                   CANCELLED_FUNDING_AMOUNT
               ,  to_number(null)                   CANCELLED_FUNDING_COUNT
               ,  to_number(null)                   FUNDING_ADJUSTMENT_AMOUNT
               ,  to_number(null)                   FUNDING_ADJUSTMENT_COUNT
               ,  to_number(null)                   REVENUE_WRITEOFF
               ,  to_number(null)                   AR_INVOICE_AMOUNT
               ,  to_number(null)                   AR_INVOICE_COUNT
               ,  to_number(null)                   AR_CASH_APPLIED_AMOUNT
               ,  to_number(null)                   AR_CASH_APPLIED_COUNT
               ,  to_number(null)                   AR_INVOICE_WRITEOFF_AMOUNT
               ,  to_number(null)                   AR_INVOICE_WRITEOFF_COUNT
               ,  to_number(null)                   AR_CREDIT_MEMO_AMOUNT
               ,  to_number(null)                   AR_CREDIT_MEMO_COUNT
               ,  to_number(null)                   UNBILLED_RECEIVABLES
               ,  to_number(null)                   UNEARNED_REVENUE
               ,  to_number(null)                   AR_UNAPPR_INVOICE_AMOUNT
               ,  to_number(null)                   AR_UNAPPR_INVOICE_COUNT
               ,  to_number(null)                   AR_APPR_INVOICE_AMOUNT
               ,  to_number(null)                   AR_APPR_INVOICE_COUNT
               ,  to_number(null)                   AR_AMOUNT_DUE
               ,  to_number(null)                   AR_COUNT_DUE
               ,  to_number(null)                   AR_AMOUNT_OVERDUE
               ,  to_number(null)                   AR_COUNT_OVERDUE
               ,  nvl(-p_ex_drmt_bklg,0) + p_drmt_bklg DORMANT_BACKLOG_INACTIV
               ,  nvl(-p_ex_strt_bklg,0) + p_strt_bklg DORMANT_BACKLOG_START
               ,  nvl(-p_ex_lost_bklg,0) + p_lost_bklg LOST_BACKLOG
               ,  nvl(-p_ex_actv_bklg,0) + p_actv_bklg ACTIVE_BACKLOG
               ,  nvl(-p_ex_risky_rev,0) + p_risky_rev REVENUE_AT_RISK
               FROM  dual
               ;
  End Insert_Backlog_Updates_pvt;


  -- -----------------------------------------------------
  -- Procedure Backlog_Bucketing_pvt
  -- -----------------------------------------------------
  Procedure Backlog_Bucketing_pvt
          ( p_worker_id         IN number
          , p_project_id        IN number
          , p_curr_record_type_id IN number
          , p_currency_code     IN varchar2
          , p_gl_calendar_id    IN number
          , p_pa_calendar_id    IN number
          , p_itd_rev           IN OUT nocopy number
          , p_itd_fnd           IN OUT nocopy number
          , p_curr_rev          IN number
          , p_curr_fnd          IN number
          , p_curr_date         IN number
          , p_scope_min_date    IN number
          , p_min_julian_date   IN number
          , p_close_date        IN number
          , p_dbklg_days        IN number
          , p_record_type       IN varchar2
          , p_drmt_bklg         IN OUT nocopy number
          , p_strt_bklg         IN OUT nocopy number
          , p_lost_bklg         IN OUT nocopy number
          , p_actv_bklg         IN OUT nocopy number
          , p_risky_rev         IN OUT nocopy number
          , p_curr_status       IN OUT nocopy varchar2
          , p_project_org_id    IN number
          , p_project_organization_id    IN number
          , p_calendar_type     IN varchar2
          , p_ex_drmt_bklg      IN OUT nocopy number
          , p_ex_strt_bklg      IN OUT nocopy number
          , p_ex_lost_bklg      IN OUT nocopy number
          , p_ex_actv_bklg      IN OUT nocopy number
          , p_ex_risky_rev      IN OUT nocopy number
          ) is

     l_before_status    VARCHAR2(30);

  Begin

          l_before_status := p_curr_status;


     If ( p_curr_date = -1 )  Then
          if      ( sign(abs(p_ex_risky_rev)) = 1)  then
                  p_drmt_bklg   := 0;
                  p_strt_bklg   := 0;
                  p_lost_bklg   := 0;
                  p_actv_bklg   := 0;
                  p_risky_rev   := p_ex_risky_rev;
                  p_curr_status := 'REV_AT_RISK';
          elsif   ( sign(abs(p_ex_lost_bklg)) = 1)  then
                  p_drmt_bklg   := 0;
                  p_strt_bklg   := 0;
                  p_lost_bklg   := p_ex_lost_bklg;
                  p_actv_bklg   := 0;
                  p_risky_rev   := 0;
                  p_curr_status := 'LOST_BACKLOG';
          elsif   ( sign(abs(p_ex_strt_bklg)) = 1)  then
                  p_drmt_bklg   := 0;
                  p_strt_bklg   := p_ex_strt_bklg;
                  p_lost_bklg   := 0;
                  p_actv_bklg   := 0;
                  p_risky_rev   := 0;
                  p_curr_status := 'BACKLOG_NOT_STARTED';
          elsif   ( sign(abs(p_ex_drmt_bklg)) = 1)  then
                  p_drmt_bklg   := p_ex_drmt_bklg;
                  p_strt_bklg   := 0;
                  p_lost_bklg   := 0;
                  p_actv_bklg   := 0;
                  p_risky_rev   := 0;
                  p_curr_status := 'DORMANT_BACKLOG';
          elsif   ( sign(abs(p_ex_actv_bklg)) = 1)  then
                  p_drmt_bklg   := 0;
                  p_strt_bklg   := 0;
                  p_lost_bklg   := 0;
                  p_actv_bklg   := p_ex_actv_bklg;
                  p_risky_rev   := 0;
                  p_curr_status := 'ACTIVE_BACKLOG';
          else
                  p_drmt_bklg   := 0;
                  p_strt_bklg   := 0;
                  p_lost_bklg   := 0;
                  p_actv_bklg   := 0;
                  p_risky_rev   := 0;
                  p_curr_status := 'BACKLOG_NOT_STARTED';
          end if;
     Else     -- ( when p_curr_date <> -1 )

          IF     (p_itd_fnd+p_curr_fnd-p_itd_rev-p_curr_rev) < 0  THEN

               iF p_record_type <> 'V'  then
                  p_curr_status := 'REV_AT_RISK';
                  p_drmt_bklg   := -p_drmt_bklg;
                  p_strt_bklg   := -p_strt_bklg;
                  p_lost_bklg   := -p_lost_bklg;
                  p_actv_bklg   := -p_actv_bklg;
                  If     l_before_status = p_curr_status  Then
                         p_risky_rev := (p_curr_rev-p_curr_fnd);
                  Else
                         p_risky_rev   := (p_itd_rev+p_curr_rev-p_itd_fnd-p_curr_fnd);
                  end If;
               enD iF;

          ELSIF   ( p_close_date <= p_curr_date )  THEN

               iF p_record_type <> 'V'  then
                  p_curr_status := 'LOST_BACKLOG';
                  p_drmt_bklg   := -p_drmt_bklg;
                  p_strt_bklg   := -p_strt_bklg;
                  If     l_before_status = p_curr_status  Then
                         p_lost_bklg := (p_curr_fnd-p_curr_rev);
                  Else
                         p_lost_bklg   := (p_itd_fnd+p_curr_fnd-p_itd_rev-p_curr_rev);
                  end If;
                  p_actv_bklg   := -p_actv_bklg;
                  p_risky_rev   := -p_risky_rev;
               enD iF;

          ELSIF  (abs(p_itd_rev)+abs(p_curr_rev)) = 0  THEN

               iF p_record_type <> 'V'  then
                  p_curr_status := 'BACKLOG_NOT_STARTED';
                  p_drmt_bklg   := -p_drmt_bklg;
                  If     l_before_status = p_curr_status  Then
                         p_strt_bklg := p_curr_fnd;
                  Else
                         p_strt_bklg   := (p_itd_fnd+p_curr_fnd);
                  end If;
                  p_lost_bklg   := -p_lost_bklg;
                  p_actv_bklg   := -p_actv_bklg;
                  p_risky_rev   := -p_risky_rev;
               enD iF;

          ELSIF  (   (p_record_type = 'V')
                  or
                     (p_record_type = 'N'
                      and l_before_status = 'DORMANT_BACKLOG'
                      and p_curr_rev = 0)
                  or
                     (g_last_activity_date+p_dbklg_days+1<p_curr_date
                      and p_curr_rev = 0 ) -- corner case of funding after before 3 buckets
                  )  THEN

                  p_curr_status := 'DORMANT_BACKLOG';
                  If     l_before_status = p_curr_status  Then
                         p_drmt_bklg := (p_curr_fnd-p_curr_rev);
                  Else
                         p_drmt_bklg   := (p_itd_fnd+p_curr_fnd-p_itd_rev-p_curr_rev);
                  end If;
                  p_strt_bklg   := -p_strt_bklg;
                  p_lost_bklg   := -p_lost_bklg;
                  p_actv_bklg   := -p_actv_bklg;
                  p_risky_rev   := -p_risky_rev;

          ELSE

                  p_curr_status := 'ACTIVE_BACKLOG';
                  p_drmt_bklg   := -p_drmt_bklg;
                  p_strt_bklg   := -p_strt_bklg;
                  p_lost_bklg   := -p_lost_bklg;
                  If     l_before_status = p_curr_status  Then
                         p_actv_bklg := (p_curr_fnd-p_curr_rev);
                  Else
                         p_actv_bklg   := (p_itd_fnd+p_curr_fnd-p_itd_rev-p_curr_rev);
                  end If;
                  p_risky_rev   := -p_risky_rev;
          END IF;

     End If;  -- ( p_curr_date = -1 )

          p_itd_rev := p_itd_rev + p_curr_rev;
          p_itd_fnd := p_itd_fnd + p_curr_fnd;


      -- Need to insert a record into the tmp table only for those days where :
      --  the project is closed
      --  or
      --  there is an existing record in the fact table
      --  and the date is after the l_min_julian_date
      --  or
      --  there is a change in status (virtual day)
      --  and the date is within scope
      --  or
      --   (to take care of the closing date of the previous run, if present)
      --  there is an existing record in the fact table
      --  and the date is before update scope
      --  there are no relevant txns on the date

          IF       (   (p_record_type = 'C')
                     OR
                       (p_record_type = 'N'
                        and p_curr_date >= p_min_julian_date)
                     OR
                       (p_record_type = 'V'
                        and p_curr_date >= p_min_julian_date
                        and l_before_status = 'ACTIVE_BACKLOG'
                        and p_curr_status   = 'DORMANT_BACKLOG')
                     OR
                       (p_record_type = 'N'
                        and p_curr_date > p_scope_min_date
                        and p_curr_date < p_min_julian_date
                        and p_curr_rev = 0
                        and p_curr_fnd = 0)
                   )  THEN
                   Insert_Backlog_Updates_pvt
                          (  p_worker_id               => p_worker_id
                          ,  p_project_id              => p_project_id
                          ,  p_time_id                 => p_curr_date
                          ,  p_curr_record_type_id     => p_curr_record_type_id
                          ,  p_currency_code           => p_currency_code
                          ,  p_gl_calendar_id          => p_gl_calendar_id
                          ,  p_pa_calendar_id          => p_pa_calendar_id
                          ,  p_drmt_bklg               => p_drmt_bklg
                          ,  p_strt_bklg               => p_strt_bklg
                          ,  p_lost_bklg               => p_lost_bklg
                          ,  p_actv_bklg               => p_actv_bklg
                          ,  p_risky_rev               => p_risky_rev
                          ,  p_project_org_id          => p_project_org_id
                          ,  p_project_organization_id => p_project_organization_id
                          ,  p_calendar_type           => p_calendar_type
                          ,  p_ex_drmt_bklg            => p_ex_drmt_bklg
                          ,  p_ex_strt_bklg            => p_ex_strt_bklg
                          ,  p_ex_lost_bklg            => p_ex_lost_bklg
                          ,  p_ex_actv_bklg            => p_ex_actv_bklg
                          ,  p_ex_risky_rev            => p_ex_risky_rev
                          );
          END IF;


          --  Resetting the values so that only one of the 5 has a +ve itd value
          IF      (p_curr_status = 'REV_AT_RISK')  THEN
                         p_risky_rev   := (p_itd_rev-p_itd_fnd);
                   p_lost_bklg := 0;
                   p_strt_bklg := 0;
                   p_drmt_bklg := 0;
                   p_actv_bklg := 0;
          ELSIF   (p_curr_status = 'LOST_BACKLOG')  THEN
                   p_risky_rev := 0;
                         p_lost_bklg   := (p_itd_fnd-p_itd_rev);
                   p_strt_bklg := 0;
                   p_drmt_bklg := 0;
                   p_actv_bklg := 0;
          ELSIF   (p_curr_status = 'BACKLOG_NOT_STARTED')  THEN
                   p_risky_rev := 0;
                   p_lost_bklg := 0;
                         p_strt_bklg   := (p_itd_fnd);
                   p_drmt_bklg := 0;
                   p_actv_bklg := 0;
          ELSIF   (p_curr_status = 'DORMANT_BACKLOG')  THEN
                   p_risky_rev := 0;
                   p_lost_bklg := 0;
                   p_strt_bklg := 0;
                         p_drmt_bklg   := (p_itd_fnd-p_itd_rev);
                   p_actv_bklg := 0;
          ELSIF   (p_curr_status = 'ACTIVE_BACKLOG')  THEN
                   p_risky_rev := 0;
                   p_lost_bklg := 0;
                   p_strt_bklg := 0;
                   p_drmt_bklg := 0;
                         p_actv_bklg   := (p_itd_fnd-p_itd_rev);
          ELSE     null;
          END IF;


  End Backlog_Bucketing_pvt;


  -- -----------------------------------------------------
  -- Procedure Calculate_Drmt_Bklg
  -- -----------------------------------------------------
  Procedure Calculate_Drmt_Bklg(
                     p_worker_id         IN NUMBER
                    , p_project_id        IN NUMBER
                    , p_project_org_id    IN NUMBER
                    , p_project_organization_id    IN NUMBER
                    , p_calendar_id       IN NUMBER DEFAULT NULL
                    , p_gl_calendar_id    IN NUMBER
                    , p_pa_calendar_id    IN NUMBER
                    , p_dbklg_days        IN NUMBER
                    , p_min_julian_date   IN NUMBER
                    , p_close_julian_date IN NUMBER
                              )
  IS
  -- Local Variable Declaration
     l_worker_id                NUMBER       := p_worker_id;
     l_project_id               NUMBER       := p_project_id;
     l_project_org_id           NUMBER       := p_project_org_id;
     l_project_organization_id  NUMBER       := p_project_organization_id;
     l_calendar_id              NUMBER       := p_calendar_id;
     l_gl_calendar_id           NUMBER       := p_gl_calendar_id;
     l_pa_calendar_id           NUMBER       := p_pa_calendar_id;
     l_dbklg_days               NUMBER       := p_dbklg_days;
     l_min_julian_date          NUMBER       := p_min_julian_date;
     l_close_julian_date        NUMBER       := p_close_julian_date;
     l_daily_calendar_type      VARCHAR2(1)  := NULL;
     l_aggr_calendar_type       VARCHAR2(1)  := NULL;
     l_period_type              VARCHAR2(3)  := NULL;
     l_curr_record_type_id      NUMBER       := NULL;
     l_txn_currency_flag        VARCHAR2(1);
     l_g2_currency_flag         VARCHAR2(1);
     l_g1_currency_code         VARCHAR2(30);
     l_g2_currency_code         VARCHAR2(30);

     l_scope_min_date           NUMBER;
     l_prev_activity_date       NUMBER;
     l_itd_rev                  NUMBER;
     l_itd_fnd                  NUMBER;
     l_curr_rev                 NUMBER;
     l_curr_fnd                 NUMBER;
     l_drmt_bklg                NUMBER;
     l_strt_bklg                NUMBER;
     l_lost_bklg                NUMBER;
     l_actv_bklg                NUMBER;
     l_risky_rev                NUMBER;
     l_curr_status              VARCHAR2(30);
     l_prev_status              VARCHAR2(30);
     l_rowcount                 NUMBER;
     l_temp_date                NUMBER;
     l_last_activity_date       NUMBER;
     l_last_date                NUMBER;
     l_prev_date                NUMBER;
     l_first_currency           NUMBER;
     l_bkt_dual                 NUMBER       :=0;
     l_called_before            VARCHAR2(1)  :='N';
     l_curr_date                NUMBER;
     l_max_date                 DATE         := PJI_RM_SUM_MAIN.g_max_date;
     l_record_type              VARCHAR2(1);
     l_ex_drmt_bklg             NUMBER;
     l_ex_strt_bklg             NUMBER;
     l_ex_lost_bklg             NUMBER;
     l_ex_actv_bklg             NUMBER;
     l_ex_risky_rev             NUMBER;

      Cursor csr_bklg is
      SELECT
            WORKER_ID
            , PROJECT_ID
            , PROJECT_ORG_ID
            , PROJECT_ORGANIZATION_ID
            , TIME_ID
            , PERIOD_TYPE_ID
            , CALENDAR_TYPE
            , CURR_RECORD_TYPE_ID
            , CURRENCY_CODE
            , nvl(REVENUE, 0)                 REVENUE
            , nvl(FUNDING, 0)                 FUNDING
            , nvl(DORMANT_BACKLOG_INACTIV, 0) DORMANT_BACKLOG_INACTIV
            , nvl(DORMANT_BACKLOG_START, 0)   DORMANT_BACKLOG_START
            , nvl(LOST_BACKLOG, 0)            LOST_BACKLOG
            , nvl(ACTIVE_BACKLOG, 0)          ACTIVE_BACKLOG
            , nvl(REVENUE_AT_RISK, 0)         REVENUE_AT_RISK
      FROM  (
         Select
              -l_worker_id                         worker_id
            , fct.project_id                       project_id
            , fct.PROJECT_ORG_ID                   PROJECT_ORG_ID
            , fct.PROJECT_ORGANIZATION_ID          PROJECT_ORGANIZATION_ID
            , fct.time_id                          time_id
            , 1                                    period_type_id
            , fct.CALENDAR_TYPE                    CALENDAR_TYPE
            , bitand(fct.curr_record_type_id, 247) curr_record_type_id
            , fct.currency_code                    currency_code
            , sum(fct.revenue)                     REVENUE
            , sum(nvl(fct.initial_funding_amount, 0)    +
                  nvl(fct.additional_funding_amount, 0) +
                  nvl(fct.cancelled_funding_amount, 0)  +
                  nvl(fct.funding_adjustment_amount, 0))   FUNDING
            , sum(DORMANT_BACKLOG_INACTIV)         DORMANT_BACKLOG_INACTIV
            , sum(DORMANT_BACKLOG_START)           DORMANT_BACKLOG_START
            , sum(LOST_BACKLOG)                    LOST_BACKLOG
            , sum(ACTIVE_BACKLOG)                  ACTIVE_BACKLOG
            , sum(REVENUE_AT_RISK)                 REVENUE_AT_RISK
         FROM  pji_ac_proj_f               fct
         WHERE 1 = 1
         And   fct.project_id = l_project_id
         And   fct.calendar_type = l_daily_calendar_type
         And   fct.time_id >= l_min_julian_date - l_dbklg_days
         And   fct.curr_record_type_id not in (8, 256)
         And   fct.period_type_id = 1
         Group By
                  fct.project_id
                , fct.PROJECT_ORG_ID
                , fct.PROJECT_ORGANIZATION_ID
                , fct.time_id
                , fct.CALENDAR_TYPE
                , bitand(fct.curr_record_type_id, 247)
                , fct.currency_code
   union all
         Select
              -l_worker_id                         worker_id
            , fct.project_id                       project_id
            , to_number(l_project_org_id)          project_org_id
            , to_number(l_project_organization_id) project_organization_id
            , -1                                   time_id
            , 1                                    period_type_id
            , to_char(l_daily_calendar_type)       calendar_type
            , bitand(fct.curr_record_type_id, 247) curr_record_type_id
            , fct.currency_code                    currency_code
            , sum(fct.revenue)                     REVENUE
            , sum(nvl(fct.initial_funding_amount, 0) +
                  nvl(fct.additional_funding_amount, 0) +
                  nvl(fct.cancelled_funding_amount, 0) +
                  nvl(fct.funding_adjustment_amount, 0))   FUNDING
            , sum(fct.DORMANT_BACKLOG_INACTIV)     DORMANT_BACKLOG_INACTIV
            , sum(fct.DORMANT_BACKLOG_START)       DORMANT_BACKLOG_START
            , sum(fct.LOST_BACKLOG)                LOST_BACKLOG
            , sum(fct.ACTIVE_BACKLOG)              ACTIVE_BACKLOG
            , sum(fct.REVENUE_AT_RISK)             REVENUE_AT_RISK
         From   PJI_PMV_ITD_DIM_TMP      time
                , pji_ac_proj_f       fct
         Where fct.time_id = time.id
         And   fct.project_id = l_project_id
         And   (fct.calendar_type = l_aggr_calendar_type or fct.calendar_type = l_daily_calendar_type)
         And fct.curr_record_type_id not in (8, 256)
         Group By fct.project_id
                  , bitand(fct.curr_record_type_id, 247)
                  , fct.currency_code
   union all
         Select
              -l_worker_id                    as worker_id
            , to_number(l_project_id)         as project_id
            , to_number(l_project_org_id)     as project_org_id
            , to_number(l_project_organization_id)  as project_organization_id
            , to_number(to_char(l_max_date-1,'J')) as time_id
            , 1                               as period_type_id
            , to_char(l_daily_calendar_type)  as calendar_type
            , 1                               as curr_record_type_id
            , l_g1_currency_code              as currency_code
            , to_number(null)                 as REVENUE
            , to_number(null)                 as FUNDING
            , to_number(null)                 as DORMANT_BACKLOG_INACTIV
            , to_number(null)                 as DORMANT_BACKLOG_START
            , to_number(null)                 as LOST_BACKLOG
            , to_number(null)                 as ACTIVE_BACKLOG
            , to_number(null)                 as REVENUE_AT_RISK
         From   Dual
   union all
         Select
              -l_worker_id                    as worker_id
            , to_number(l_project_id)         as project_id
            , to_number(l_project_org_id)     as project_org_id
            , to_number(l_project_organization_id)  as project_organization_id
            , to_number(to_char(l_max_date-1,'J')) as time_id
            , 1                               as period_type_id
            , to_char(l_daily_calendar_type)  as calendar_type
            , 2                               as curr_record_type_id
            , l_g2_currency_code              as currency_code
            , to_number(null)                 as REVENUE
            , to_number(null)                 as FUNDING
            , to_number(null)                 as DORMANT_BACKLOG_INACTIV
            , to_number(null)                 as DORMANT_BACKLOG_START
            , to_number(null)                 as LOST_BACKLOG
            , to_number(null)                 as ACTIVE_BACKLOG
            , to_number(null)                 as REVENUE_AT_RISK
         From   Dual
         Where  l_g2_currency_flag = 'Y'
   union all
         Select
              -l_worker_id                    as worker_id
            , to_number(l_project_id)         as project_id
            , to_number(l_project_org_id)     as project_org_id
            , to_number(l_project_organization_id)  as project_organization_id
            , to_number(to_char(l_max_date-1,'J')) as time_id
            , 1                               as period_type_id
            , to_char(l_daily_calendar_type)  as calendar_type
            , 4                               as curr_record_type_id
            , pf_currency_code                as currency_code
            , to_number(null)                 as REVENUE
            , to_number(null)                 as FUNDING
            , to_number(null)                 as DORMANT_BACKLOG_INACTIV
            , to_number(null)                 as DORMANT_BACKLOG_START
            , to_number(null)                 as LOST_BACKLOG
            , to_number(null)                 as ACTIVE_BACKLOG
            , to_number(null)                 as REVENUE_AT_RISK
         From   PJI_ORG_EXTR_INFO
         Where  nvl(ORG_ID, -1) = nvl(l_project_org_id, -1)
      )
     ORDER BY
         PROJECT_ID
         , CURR_RECORD_TYPE_ID
         , CURRENCY_CODE
         , TIME_ID
     ;

     rec_bklg csr_bklg%ROWTYPE;



  BEGIN

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

      IF l_calendar_id IS NULL THEN
            l_daily_calendar_type := 'C';
            l_aggr_calendar_type := 'E';

            l_period_type := 'ITD';
        ELSE
            l_daily_calendar_type := 'P';
            l_aggr_calendar_type := 'P';

            l_period_type := 'PA';
      END IF;

    DELETE FROM PJI_PMV_ITD_DIM_TMP;

begin
  -- Using Enterprise Calendar, Build PJI_PMV_ITD_DIM_TMP for Subsequent ITD Insert SQL
  PJI_PMV_ENGINE.Convert_ITD_NViewBY_AS_OF_DATE(
          p_As_Of_Date => l_min_julian_date - l_dbklg_days - 1
          , p_Period_Type => l_period_type
          , p_Calendar_ID => l_calendar_id
         );
exception when others then null;
end;


     l_scope_min_date := l_min_julian_date - l_dbklg_days - 1;


--    Next we open the cursor for processing backlog

      IF      csr_bklg%ISOPEN  THEN
              CLOSE csr_bklg;
      END IF;

      l_first_currency     := 0;

      For rec_bklg in csr_bklg LOOP

            l_bkt_dual      := 0;

      IF    rec_bklg.time_id = -1  THEN

            l_itd_rev   := rec_bklg.revenue;
            l_itd_fnd   := rec_bklg.funding;
            l_curr_rev  := 0;
            l_curr_fnd  := 0;

            l_drmt_bklg := 0;
            l_strt_bklg := 0;
            l_lost_bklg := 0;
            l_actv_bklg := 0;
            l_risky_rev := 0;

            l_curr_status := 'UNKNOWN';

            l_first_currency := rec_bklg.curr_record_type_id;
            g_last_activity_date := l_scope_min_date;
            l_bkt_dual      := 1;
            l_called_before := 'N';

      ELSIF   (rec_bklg.time_id = to_number(to_char(l_max_date-1,'j'))) THEN
               -- check dormancy for the last record

            l_curr_rev  := 0;
            l_curr_fnd  := 0;

            l_bkt_dual      := 0;

      ELSE
            l_bkt_dual      := 0;

            If     (bitand(l_first_currency,
                           rec_bklg.curr_record_type_id) = 0)  Then
            -- corner case of no ITD record
                   l_itd_rev   := 0;
                   l_itd_fnd   := 0;

                   l_drmt_bklg := 0;
                   l_strt_bklg := 0;
                   l_lost_bklg := 0;
                   l_actv_bklg := 0;
                   l_risky_rev := 0;

                   l_curr_status := 'UNKNOWN';
                   l_first_currency := rec_bklg.curr_record_type_id;
                   g_last_activity_date := rec_bklg.time_id;
            l_bkt_dual      := 1;
            l_called_before := 'N';

            End If;

      END IF;        --  rec_bklg.time_id = -1



      --  Next we call the backlog bucketing procedure in a loop thrice
      --   for each record in the cursor
      --  The first time for the project closed date if required
      --  The second time for a virtual date if required
      --  The third time for the normal date


      WHILE  l_bkt_dual < 3  Loop

              l_ex_drmt_bklg := rec_bklg.DORMANT_BACKLOG_INACTIV;
              l_ex_strt_bklg := rec_bklg.DORMANT_BACKLOG_START;
              l_ex_lost_bklg := rec_bklg.LOST_BACKLOG;
              l_ex_actv_bklg := rec_bklg.ACTIVE_BACKLOG;
              l_ex_risky_rev := rec_bklg.REVENUE_AT_RISK;


      IF      ( l_bkt_dual < 1
                and g_last_activity_date < l_close_julian_date
                and l_close_julian_date <= rec_bklg.time_id
                and (rec_bklg.time_id <> to_number(to_char(l_max_date-1,'j'))
                     or
                     l_close_julian_date < (g_last_activity_date + l_dbklg_days + 1)
                    )
                                          )  THEN  -- the closed date case

              l_record_type  := 'C';
              l_curr_date    := l_close_julian_date ;
            l_curr_rev  := rec_bklg.revenue;
            l_curr_fnd  := rec_bklg.funding;

              l_bkt_dual := 1;

      ELSIF   ( l_bkt_dual < 2
                and (g_last_activity_date + l_dbklg_days + 1) <= rec_bklg.time_id
                and (g_last_activity_date + l_dbklg_days + 1) < l_close_julian_date
                and l_called_before = 'N' )  THEN  -- the virtual case

              l_record_type  := 'V';
              l_curr_date    := g_last_activity_date + l_dbklg_days + 1;
            l_curr_rev  := 0;
            l_curr_fnd  := 0;
              l_ex_drmt_bklg := 0;
              l_ex_strt_bklg := 0;
              l_ex_lost_bklg := 0;
              l_ex_actv_bklg := 0;
              l_ex_risky_rev := 0;

            IF (rec_bklg.time_id <> to_number(to_char(l_max_date-1,'j')))  THEN
              l_bkt_dual :=2;
            ELSE   -- the last record is virtual
                   -- thus the normal case should not be called
              l_bkt_dual :=99;
            END IF;

              l_called_before := 'Y';

      ELSE    -- the normal case

              l_record_type  := 'N';
              l_curr_date    := rec_bklg.time_id;
             IF  (rec_bklg.time_id = -1)  THEN
                 l_curr_rev := 0;
                 l_curr_fnd := 0;
             ELSE
                 l_curr_rev  := rec_bklg.revenue;
                 l_curr_fnd  := rec_bklg.funding;
             END IF;

              l_bkt_dual := 3;
      END IF;

            IF (l_curr_date < to_number(to_char(l_max_date-1,'j')))  THEN
            Backlog_Bucketing_pvt
                    ( p_worker_id               => p_worker_id
                    , p_project_id              => p_project_id
                    , p_curr_record_type_id     => rec_bklg.curr_record_type_id
                    , p_currency_code           => rec_bklg.currency_code
                    , p_gl_calendar_id          => l_gl_calendar_id
                    , p_pa_calendar_id          => l_pa_calendar_id
                    , p_itd_rev                 => l_itd_rev
                    , p_itd_fnd                 => l_itd_fnd
                    , p_curr_rev                => l_curr_rev
                    , p_curr_fnd                => l_curr_fnd
                    , p_curr_date               => l_curr_date
                    , p_scope_min_date          => l_scope_min_date
                    , p_min_julian_date         => l_min_julian_date
                    , p_close_date              => l_close_julian_date
                    , p_dbklg_days              => l_dbklg_days
                    , p_record_type             => l_record_type
                    , p_drmt_bklg               => l_drmt_bklg
                    , p_strt_bklg               => l_strt_bklg
                    , p_lost_bklg               => l_lost_bklg
                    , p_actv_bklg               => l_actv_bklg
                    , p_risky_rev               => l_risky_rev
                    , p_curr_status             => l_curr_status
                    , p_project_org_id          => p_project_org_id
                    , p_project_organization_id => p_project_organization_id
                    , p_calendar_type           => rec_bklg.calendar_type
                    , p_ex_drmt_bklg            => l_ex_drmt_bklg
                    , p_ex_strt_bklg            => l_ex_strt_bklg
                    , p_ex_lost_bklg            => l_ex_lost_bklg
                    , p_ex_actv_bklg            => l_ex_actv_bklg
                    , p_ex_risky_rev            => l_ex_risky_rev
                    );
            END IF; -- (l_curr_date < to_number(to_char(l_max_date-1,'j')))

          End Loop; -- for l_bkt_dual

          if       l_curr_rev <> 0   then
                   g_last_activity_date := l_curr_date;
                   l_called_before := 'N';
          end if;
      END LOOP;   --  For rec_bklg in csr_bklg


  END Calculate_Drmt_Bklg;



  -- -----------------------------------------------------
  -- Procedure Process_Drmt_Bklg
  -- -----------------------------------------------------
  Procedure Process_Drmt_Bklg(p_worker_id  IN  NUMBER)
  IS

  -- Local Variable Declaration
  -- IN Variables
      l_worker_id          NUMBER        := NULL;
      l_process            VARCHAR2(30)  := NULL;
      l_project_id         NUMBER        := NULL;
      l_min_date           DATE          := NULL;
      l_close_date         DATE          := NULL;
      l_min_julian_date    NUMBER        := NULL;
      l_close_julian_date  NUMBER        := NULL;
      l_project_org_id     NUMBER        := NULL;
      l_project_organization_id         NUMBER     := NULL;
      l_calendar_id        NUMBER        := NULL;
      l_gl_calendar_id     NUMBER        := NULL;
      l_pa_calendar_id     NUMBER        := NULL;
      l_pa_calendar_flag   VARCHAR2(1)   := 'N';
      l_dbklg_days         NUMBER        := 0;
      l_max_date           DATE          := PJI_RM_SUM_MAIN.g_max_date;
--temptemp needs to be PJI_PJI_LAST_EXTR_DATE
      last_extr_date       DATE          := to_date(PJI_UTILS.GET_PARAMETER('LAST_FM_EXTR_DATE'),'YYYY/MM/DD');
      l_commit_counter     NUMBER        := 0;
      l_dual_limit         NUMBER        := 0;
      l_dual               NUMBER        := 0;
      l_min_nocal_date     DATE;
      l_min_cal_date       DATE;
      l_prev_project       NUMBER;
      l_rowcount            number := 0;
      l_curr_project_id     number := 0;
      l_parallel_processes  number := null;

      l_try_upd_again   varchar2(1);
      l_count_for_upd   number;


  BEGIN

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            ( l_process, 'PJI_FM_SUM_BKLG.PROCESS_DRMT_BKLG(p_worker_id);')) then
       return;
    end if;

    -- Assigning Values to the variables

    l_worker_id := p_worker_id;

    l_dbklg_days := to_number(PJI_UTILS.GET_SETUP_PARAMETER('DORMANT_BACKLOG_DAYS'));

    l_pa_calendar_flag := PJI_UTILS.GET_SETUP_PARAMETER('PA_PERIOD_FLAG');

    -- Code below has been added so that each programming unit
    -- handles the exception of the previous run

  delete
  from    PJI_FM_AGGR_ACT3
  where   worker_id = 1
  and     project_id in
          (select project_id
           from   pji_pji_proj_batch_map
           where  worker_id = 1
           and    BACKLOG_EXTRACTION_STATUS = 'P'
           and    PARALLEL_BACKLOG_WORKER_ID = p_worker_id
          )
  ;

  Update pji_pji_proj_batch_map
  Set    BACKLOG_EXTRACTION_STATUS = null
         , PARALLEL_BACKLOG_WORKER_ID = null
  Where  WORKER_ID = 1
  And    PARALLEL_BACKLOG_WORKER_ID = p_worker_id
  And    BACKLOG_EXTRACTION_STATUS  = 'P'
  ;

    -- Code above has been added so that each programming unit
    -- handles the exception of the previous run

    -- Next we determine how many times the main procedure needs to be called
    -- for a given project

    IF l_pa_calendar_flag = 'Y' THEN
       l_dual_limit := 2;
    ELSE
       l_dual_limit := 1;
    END IF;


    l_prev_project := -99;

    LOOP

      -- Exit if the main process is not running
      IF  (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
           (PJI_RM_SUM_MAIN.g_process, 'PROCESS_RUNNING') <> 'Y' )  THEN
           exit;
      END IF;

            l_try_upd_again := 'N';

            Update pji_pji_proj_batch_map
            Set    BACKLOG_EXTRACTION_STATUS='P'
                   , PARALLEL_BACKLOG_WORKER_ID = p_worker_id
            Where  WORKER_ID = 1
            And    BACKLOG_EXTRACTION_STATUS is null
            And    rownum = 1
            And    not exists
                   ( select   1
                     from     pji_pji_proj_batch_map
                     where    worker_id = 1
                     and      parallel_backlog_worker_id = p_worker_id
                     and      backlog_extraction_status = 'P'
                   )
            And       (   ACTIVITY_MIN_GL_DATE is not null
                       or ACTIVITY_MIN_PA_DATE is not null
                       or FUNDING_MIN_DATE     is not null
                       or nvl(OLD_CLOSED_DATE, l_max_date)
                       <> nvl(NEW_CLOSED_DATE, l_max_date)
                       )
            ;

            l_rowcount := SQL%ROWCOUNT;


     --  The following IF is to optimize the distribution of load on
     --  the helpers in case one of them hit upon a data contention and
     --  was not able to commit the record that it updated above
     IF      ( l_rowcount <> 0 )  THEN
             commit;
     ELSE    -- either there are no more records to be processed
             -- or there has been data contention
             select count(*)
             into   l_count_for_upd
             from   pji_pji_proj_batch_map
             where  WORKER_ID = p_worker_id
             and    BACKLOG_EXTRACTION_STATUS is null
             and      (   ACTIVITY_MIN_GL_DATE is not null
                       or ACTIVITY_MIN_PA_DATE is not null
                       or FUNDING_MIN_DATE     is not null
                       or nvl(OLD_CLOSED_DATE, l_max_date)
                       <> nvl(NEW_CLOSED_DATE, l_max_date)
                       )
             ;

             if      ( l_count_for_upd = 0 )  then
                     exit;
             else
                     l_try_upd_again := 'Y';
             end if;
     END IF; --  ( l_rowcount <> 0 )


     IF      ( l_try_upd_again = 'Y' )  Then
             -- wait for some time and try again
             PJI_PROCESS_UTIL.sleep(PJI_RM_SUM_MAIN.g_process_delay);
     ELSE    -- go ahead with the processing for the record updated

            Select project_id
            Into   l_curr_project_id
            From   pji_pji_proj_batch_map
            Where  BACKLOG_EXTRACTION_STATUS='P'
            And    PARALLEL_BACKLOG_WORKER_ID = p_worker_id
            ;

      IF      (l_prev_project <> l_curr_project_id)  THEN
              l_dual := 0;
      END IF;

      WHILE  l_dual < l_dual_limit  Loop


    SELECT  /*+ ORDERED */
                map.project_id
                , least(
                  (nvl(map.ACTIVITY_MIN_GL_DATE, l_max_date))
                , (nvl(map.FUNDING_MIN_DATE, l_max_date))
                , (nvl(map.OLD_CLOSED_DATE, l_max_date))
                , (nvl(map.NEW_CLOSED_DATE, l_max_date))
                , (nvl(last_extr_date , l_max_date))
                   )   as min_nocal_date
                , least(
                  (nvl(map.ACTIVITY_MIN_PA_DATE, l_max_date))
                , (nvl(map.FUNDING_MIN_DATE, l_max_date))
                , (nvl(map.OLD_CLOSED_DATE, l_max_date))
                , (nvl(map.NEW_CLOSED_DATE, l_max_date))
                , (nvl(last_extr_date , l_max_date))
                   )   as min_cal_date
                , nvl(map.NEW_CLOSED_DATE, l_max_date)  as new_closed_date
                , map.PROJECT_ORG_ID
                , map.PROJECT_ORGANIZATION_ID
                , org_info.PA_CALENDAR_ID
                , org_info.GL_CALENDAR_ID
                , org_info.PA_CALENDAR_ID
            INTO  l_project_id
                  , l_min_nocal_date
                  , l_min_cal_date
                  , l_close_date
                  , l_project_org_id
                  , l_project_organization_id
                  , l_calendar_id
                  , l_gl_calendar_id
                  , l_pa_calendar_id
    FROM      pji_pji_proj_batch_map          map
              , PJI_ORG_EXTR_INFO             org_info
    WHERE     map.WORKER_ID = 1
    AND       map.PROJECT_ORG_ID = org_info.org_id
    AND       map.project_id = l_curr_project_id
    ;


        l_close_julian_date := to_number(to_char(l_close_date,'j'));



        -- First we call the main procedure for the period type of ITD
        -- that is when the pa_calendar_id is null
        -- The second time we call for the period type of PA
        -- that is when the pa_calendar_id is NOT null

        IF     (l_dual = 0)  Then
               l_min_julian_date := to_number(to_char(l_min_nocal_date,'j'));
               l_calendar_id     := null;
        ELSIF  (l_dual = 1)  Then
               l_min_julian_date := to_number(to_char(l_min_cal_date,'j'));
        END IF;

        Calculate_Drmt_Bklg(
                     p_worker_id         => l_worker_id
                    , p_project_id        => l_project_id
                    , p_project_org_id    => l_project_org_id
                    , p_project_organization_id    => l_project_organization_id
                    , p_calendar_id       => l_calendar_id
                    , p_gl_calendar_id    => l_gl_calendar_id
                    , p_pa_calendar_id    => l_pa_calendar_id
                    , p_dbklg_days        => l_dbklg_days
                    , p_min_julian_date   => l_min_julian_date
                    , p_close_julian_date => l_close_julian_date
                   );

        l_dual := l_dual + 1;

      end loop;   --  WHILE  l_dual < 3

      l_prev_project := l_curr_project_id;

            Update pji_pji_proj_batch_map
            Set    BACKLOG_EXTRACTION_STATUS='X'
            Where  project_id = l_curr_project_id
            ;


      commit;


     END IF; --  ( l_try_upd_again = 'Y' )


    END LOOP;


      select count(*)
      into   l_count_for_upd
      from   pji_pji_proj_batch_map
      where  WORKER_ID = p_worker_id
      and    NVL(BACKLOG_EXTRACTION_STATUS,'P') = 'P'
      ;

      IF     ( l_count_for_upd = 0 )  THEN

        l_parallel_processes := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process, 'PARALLEL_PROCESSES');

        for x in 2 .. l_parallel_processes loop

          update PJI_SYSTEM_PRC_STATUS
          set    STEP_STATUS = 'C'
          where  PROCESS_NAME = PJI_RM_SUM_MAIN.g_process || to_char(x) and
                 STEP_NAME = 'PJI_FM_SUM_BKLG.PROCESS_DRMT_BKLG(p_worker_id);';

          commit;

        end loop;

      END IF;

      IF  (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
           (PJI_RM_SUM_MAIN.g_process, 'PROCESS_RUNNING') <> 'Y' )  THEN
          --  no need to raise any error here
          null;

      ELSE
          PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
          ( l_process, 'PJI_FM_SUM_BKLG.PROCESS_DRMT_BKLG(p_worker_id);');

          commit;

      END IF;


END Process_Drmt_Bklg;



begin
  g_pji_schema := pji_utils.get_pji_schema_name;

end PJI_FM_SUM_BKLG;

/
