--------------------------------------------------------
--  DDL for Package Body PJI_RM_SUM_EXTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_RM_SUM_EXTR" as
  /* $Header: PJISR02B.pls 120.8 2005/12/07 21:57:59 appldev noship $ */

  -- -----------------------------------------------------
  -- procedure PROCESS_DANGLING_ROWS
  -- -----------------------------------------------------
  procedure PROCESS_DANGLING_ROWS
  (
    p_worker_id in number
  ) is

  l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
                                              'PJI_RM_SUM_EXTR.PROCESS_DANGLING_ROWS(p_worker_id);')) then
      return;
    end if;

    --The calendar_type is hard coded as 'C'. The dangling 'P' and 'G'
    --records are inserted into TMP1 as 'C'

    insert /*+ append parallel(res1_i) */ into PJI_RM_AGGR_RES1 res1_i
    (
      WORKER_ID,
      DANGLING_FLAG,
      ROW_ID,
      RECORD_TYPE,
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
      CAPACITY_HRS,
      TOTAL_HRS_A,
      BILL_HRS_A,
      CONF_HRS_S,
      PROV_HRS_S,
      UNASSIGNED_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S
    )
    select /*+ parallel(tmp1) full(res_map) */
      p_worker_id,
      null,
      tmp1.ROWID,
      tmp1.RECORD_TYPE,
      tmp1.PROJECT_ID,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
      tmp1.TIME_ID,
      tmp1.PERIOD_TYPE_ID,
      'C',
      res_map.GL_CALENDAR_ID,
      res_map.PA_CALENDAR_ID,
      tmp1.CAPACITY_HRS,
      tmp1.TOTAL_HRS_A,
      tmp1.BILL_HRS_A,
      tmp1.CONF_HRS_S,
      tmp1.PROV_HRS_S,
      tmp1.UNASSIGNED_HRS_S,
      tmp1.CONF_OVERCOM_HRS_S,
      tmp1.PROV_OVERCOM_HRS_S
    from
      PJI_RM_DNGL_RES      tmp1,
      PJI_RM_ORG_BATCH_MAP orgs,
      PJI_ORG_EXTR_INFO    res_map
    where
      tmp1.WORKER_ID           = 0                                and
      orgs.WORKER_ID           = p_worker_id                      and
      orgs.ORGANIZATION_ID     = tmp1.EXPENDITURE_ORGANIZATION_ID and
      tmp1.EXPENDITURE_ORG_ID  = res_map.ORG_ID                   and
      tmp1.TIME_ID            >= res_map.PA_CALENDAR_MIN_DATE     and
      tmp1.TIME_ID            <= res_map.PA_CALENDAR_MAX_DATE     and
      tmp1.TIME_ID            >= res_map.GL_CALENDAR_MIN_DATE     and
      tmp1.TIME_ID            <= res_map.GL_CALENDAR_MAX_DATE     and
      tmp1.TIME_ID            >= res_map.EN_CALENDAR_MIN_DATE     and
      tmp1.TIME_ID            <= res_map.EN_CALENDAR_MAX_DATE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION (l_process,
                                               'PJI_RM_SUM_EXTR.PROCESS_DANGLING_ROWS(p_worker_id);');

    commit;

  end PROCESS_DANGLING_ROWS;


  -- -----------------------------------------------------
  -- procedure PURGE_DANGLING_ROWS
  -- -----------------------------------------------------
  procedure PURGE_DANGLING_ROWS (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_RM_SUM_EXTR.PURGE_DANGLING_ROWS(p_worker_id);')) then
      return;
    end if;

    delete /*+ parallel(res) */
    from   PJI_RM_DNGL_RES res
    where  WORKER_ID = 0 and
           ROWID in (select ROW_ID
                     from   PJI_RM_AGGR_RES1
                     where  WORKER_ID = p_worker_id);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION (l_process, 'PJI_RM_SUM_EXTR.PURGE_DANGLING_ROWS(p_worker_id);');

    commit;

  end PURGE_DANGLING_ROWS;


  -- -----------------------------------------------------
  -- procedure RES_ROWID_TABLE
  -- -----------------------------------------------------
  procedure RES_ROWID_TABLE (p_worker_id in number) is

    l_process   varchar2(30);
    l_schema    varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_RM_SUM_EXTR.RES_ROWID_TABLE(p_worker_id);')) then
      return;
    end if;

    insert /*+ append parallel(res_i) */ into PJI_PJI_RMAP_RES res_i
    (
      WORKER_ID,
      STG_ROWID
    )
    select /*+ ordered */
      p_worker_id                           WORKER_ID,
      res6.ROWID                            STG_ROWID
    from
      PJI_PJI_PROJ_BATCH_MAP map,
      PJI_RM_AGGR_RES6       res6,
      PJI_RESOURCES_DENORM   denorm
    where
      map.WORKER_ID                       = p_worker_id             and
      res6.PROJECT_ID                     = map.PROJECT_ID          and
      res6.PERSON_ID                      = denorm.PERSON_ID        and
      denorm.UTILIZATION_FLAG             = 'Y'                     and
      to_date(to_char(res6.TIME_ID), 'J') between denorm.START_DATE and
                                                  denorm.END_DATE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_RM_SUM_EXTR.RES_ROWID_TABLE(p_worker_id);');

    commit;

  end RES_ROWID_TABLE;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_FID_FULL
  --
  -- This procedure is used for initial data extraction
  -- -----------------------------------------------------
  procedure EXTRACT_BATCH_FID_FULL (p_worker_id IN NUMBER) is

    l_process             varchar2(30);
    l_counter             number := 0;
    l_from_org_id         number := 0;
    l_to_org_id           number := 0;
    l_min_date            number;

    cursor c_update_fid is
    select fid.ROWID as row_id
    from   pa_forecast_item_details fid
    where  fid.expenditure_organization_id in  (select organization_id
                                                from   pji_rm_org_batch_map
                                                where  worker_id = p_worker_id)
    and    fid.pji_summarized_flag = 'N';

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
                                              'PJI_RM_SUM_EXTR.EXTRACT_BATCH_FID_FULL(p_worker_id);')) then
      return;
    end if;

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process,
                          'EXTRACTION_TYPE') <> 'FULL' ) then
      return;
    end if;

    l_min_date := to_number(to_char(to_date(
                  PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE'),
                  PJI_RM_SUM_MAIN.g_date_mask), 'J'));

    insert /*+ append parallel(res1_i) */ into PJI_RM_AGGR_RES1 res1_i
    (
      WORKER_ID,
      DANGLING_FLAG,
      RECORD_TYPE,
      TOTAL_HRS_A,
      BILL_HRS_A,
      CAPACITY_HRS,
      CONF_HRS_S,
      PROV_HRS_S,
      UNASSIGNED_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      EXPENDITURE_ORGANIZATION_ID,
      EXPENDITURE_ORG_ID,
      TIME_ID,
      PERSON_ID,
      JOB_ID,
      WORK_TYPE_ID,
      PROJECT_ID
    )
    select
        WORKER_ID,
        DANGLING_FLAG,
        RECORD_TYPE,
        TOTAL_HRS_A,
        BILL_HRS_A,
        CAPACITY_HRS,
        CONF_HRS_S,
        PROV_HRS_S,
        UNASSIGNED_HRS_S,
        CONF_OVERCOM_HRS_S,
        PROV_OVERCOM_HRS_S,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        GL_CALENDAR_ID,
        PA_CALENDAR_ID,
        EXPENDITURE_ORGANIZATION_ID,
        EXPENDITURE_ORG_ID,
        TIME_ID,
        PERSON_ID,
        JOB_ID,
        WORK_TYPE_ID,
        PROJECT_ID
      from
        (
        select  -- Selecting data from source : FI
          WORKER_ID,
          DANGLING_FLAG,
          RECORD_TYPE,
          sum(TOTAL_HRS_A)        TOTAL_HRS_A,
          sum(BILL_HRS_A)         BILL_HRS_A,
          sum(CAPACITY_HRS)       CAPACITY_HRS,
          sum(CONF_HRS_S)         CONF_HRS_S,
          sum(PROV_HRS_S)         PROV_HRS_S,
          sum(UNASSIGNED_HRS_S)   UNASSIGNED_HRS_S,
          sum(CONF_OVERCOM_HRS_S) CONF_OVERCOM_HRS_S,
          sum(PROV_OVERCOM_HRS_S) PROV_OVERCOM_HRS_S,
          PERIOD_TYPE_ID,
          CALENDAR_TYPE,
          GL_CALENDAR_ID,
          PA_CALENDAR_ID,
          EXPENDITURE_ORGANIZATION_ID,
          EXPENDITURE_ORG_ID,
          TIME_ID,
          PERSON_ID,
          JOB_ID,
          WORK_TYPE_ID,
          PROJECT_ID
        from
          (
          select /*+        ORDERED
                            full(fid)      use_hash(fid)      parallel(fid)
                            full(fi)       use_hash(fi)       parallel(fi)
                            full(res)      use_hash(res)      parallel(res)
                            full(wt)       use_hash(wt)
                            full(res_info) use_hash(res_info)
                 */
            p_worker_id WORKER_ID,
            case when  res_info.ORG_ID is null
                 then 'O'
                 when greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) < res_info.EN_CALENDAR_MIN_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) > res_info.EN_CALENDAR_MAX_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) < res_info.GL_CALENDAR_MIN_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) > res_info.GL_CALENDAR_MAX_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) < res_info.PA_CALENDAR_MIN_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) > res_info.PA_CALENDAR_MAX_DATE
                 then 'T'
                 else null
            end DANGLING_FLAG,
            case when fi.FORECAST_ITEM_TYPE = 'U'
                 then 'U'
                 else 'N'
                 end RECORD_TYPE,
            case when fi.FORECAST_ITEM_TYPE = 'U'
                 then fid.CAPACITY_QUANTITY
                 else to_number(null)
            end CAPACITY_HRS,
            case when fi.FORECAST_ITEM_TYPE = 'A'
                 then fid.ITEM_QUANTITY *
                        decode(fi.PROVISIONAL_FLAG, 'N', 1, 0)
                 else to_number(null)
            end CONF_HRS_S,
            case when fi.FORECAST_ITEM_TYPE = 'A'
                 then fid.ITEM_QUANTITY *
                        decode(fi.PROVISIONAL_FLAG, 'Y', 1, 0)
                 else to_number(null)
            end PROV_HRS_S,
            case when fi.FORECAST_ITEM_TYPE = 'U'
                 then fid.ITEM_QUANTITY
                 else to_number(null)
            end UNASSIGNED_HRS_S,
            case when fi.FORECAST_ITEM_TYPE = 'U'
                 then fid.OVERCOMMITMENT_QTY *
                        decode(fi.OVERCOMMITMENT_FLAG, 'Y', 1, 0)
                 else to_number(null)
            end CONF_OVERCOM_HRS_S,
            case when fi.FORECAST_ITEM_TYPE = 'U'
                 then fid.OVERPROVISIONAL_QTY *
                        decode(fi.OVERCOMMITMENT_FLAG, 'Y', 1, 0)
                 else to_number(null)
            end PROV_OVERCOM_HRS_S,
            to_number(null) TOTAL_HRS_A,
            to_number(null) BILL_HRS_A,
            1 PERIOD_TYPE_ID,
            case when  res_info.ORG_ID is null
                 then 'C'
                 when greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) < res_info.PA_CALENDAR_MIN_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) > res_info.PA_CALENDAR_MAX_DATE
                 then 'P'
                 when greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) < res_info.GL_CALENDAR_MIN_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) > res_info.GL_CALENDAR_MAX_DATE
                 then 'G'
                 else 'C'
            end CALENDAR_TYPE ,
            res_info.GL_CALENDAR_ID,
            res_info.PA_CALENDAR_ID,
            fid.EXPENDITURE_ORGANIZATION_ID,
            fid.EXPENDITURE_ORG_ID,
            greatest(to_number(to_char(fi.ITEM_DATE,'J')), l_min_date) TIME_ID,
            fi.PERSON_ID,
            nvl(nvl(fid.JOB_ID, res.JOB_ID), -1) JOB_ID,
            fid.WORK_TYPE_ID,
            fid.PROJECT_ID
          from
            PJI_RM_WORK_TYPE_INFO    wt,
            PA_FORECAST_ITEM_DETAILS fid,
            PA_FORECAST_ITEMS        fi,
            PJI_RESOURCES_DENORM     res,
            PJI_ORG_EXTR_INFO        res_info
          where
            nvl(fid.pji_summarized_flag,'Y') <> 'N'                  and
            fi.FORECAST_ITEM_ID              = fid.FORECAST_ITEM_ID  and
            fi.FORECAST_ITEM_TYPE            in ('U', 'A')           and
            fid.WORK_TYPE_ID                 = wt.WORK_TYPE_ID       and
            wt.RECORD_TYPE                   = 'NORMAL'              and
            res.PERSON_ID                    = fi.PERSON_ID          and
            res.UTILIZATION_FLAG             = 'Y'                   and
            fi.item_date between res.START_DATE and res.END_DATE     and
            fid.EXPENDITURE_ORG_ID           = res_info.ORG_ID
          union all
          select /*+ ordered */
            p_worker_id                           WORKER_ID,
            null                                  DANGLING_FLAG,
            'N'                                   RECORD_TYPE,
            to_number(null)                       CAPACITY_HRS,
            to_number(null)                       CONF_HRS_S,
            to_number(null)                       PROV_HRS_S,
            to_number(null)                       UNASSIGNED_HRS_S,
            to_number(null)                       CONF_OVERCOM_HRS_S,
            to_number(null)                       PROV_OVERCOM_HRS_S,
            res6.TOTAL_HRS_A,
            res6.BILL_HRS_A,
            1                                     PERIOD_TYPE_ID,
            res6.CALENDAR_TYPE,
            res6.GL_CALENDAR_ID,
            res6.PA_CALENDAR_ID,
            res6.EXPENDITURE_ORGANIZATION_ID,
            res6.EXPENDITURE_ORG_ID,
            res6.TIME_ID,
            res6.PERSON_ID,
            res6.JOB_ID,
            res6.WORK_TYPE_ID,
            res6.PROJECT_ID
          from
            PJI_RM_AGGR_RES6 res6,
            PJI_PJI_RMAP_RES res6_r
          where
            res6_r.WORKER_ID = p_worker_id and
            res6.ROWID = res6_r.STG_ROWID
        ) tmp1
      group by
        WORKER_ID,
        DANGLING_FLAG,
        RECORD_TYPE,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        GL_CALENDAR_ID,
        PA_CALENDAR_ID,
        EXPENDITURE_ORGANIZATION_ID,
        EXPENDITURE_ORG_ID,
        TIME_ID,
        PERSON_ID,
        JOB_ID,
        WORK_TYPE_ID,
        PROJECT_ID
      )
    where
      nvl(TOTAL_HRS_A, 0)        <> 0 or
      nvl(BILL_HRS_A, 0)         <> 0 or
      nvl(CAPACITY_HRS, 0)       <> 0 or
      nvl(CONF_HRS_S, 0)         <> 0 or
      nvl(PROV_HRS_S, 0)         <> 0 or
      nvl(UNASSIGNED_HRS_S, 0)   <> 0 or
      nvl(CONF_OVERCOM_HRS_S, 0) <> 0 or
      nvl(PROV_OVERCOM_HRS_S, 0) <> 0;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_RM_SUM_EXTR.EXTRACT_BATCH_FID_FULL(p_worker_id);');

    COMMIT;

  end EXTRACT_BATCH_FID_FULL;


  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_FID_ROWIDS
  --  This procedure is used in partial and incremental
  --  data extraction
  -- -----------------------------------------------------
  PROCEDURE EXTRACT_BATCH_FID_ROWIDS (p_worker_id IN NUMBER) IS

    l_process         varchar2(30);
    l_from_org_id     number := 0;
    l_to_org_id       number := 0;
    l_extraction_type varchar2(30);

    l_row_count           number;
    l_last_update_date    date;
    l_last_updated_by     number;
    l_request_id          number;
    l_program_appl_id     number;
    l_program_id          number;
    l_program_update_date date;

  BEGIN

    l_process := PJI_RM_SUM_MAIN.g_process || TO_CHAR(p_worker_id);

    IF (NOT PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_RM_SUM_EXTR.EXTRACT_BATCH_FID_ROWIDS(p_worker_id);')) THEN
      RETURN;
    END IF;

    -- JOB_ID Util --> Non-Util: make sure source reversals are not summarized

    select count(*)
    into   l_row_count
    from   PJI_RES_DELTA
    where  CHANGE_TYPE = 'N';

    if (l_row_count > 0) then

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_request_id        := FND_GLOBAL.CONC_REQUEST_ID;
    l_program_appl_id   := FND_GLOBAL.PROG_APPL_ID;
    l_program_id        := FND_GLOBAL.CONC_PROGRAM_ID;
    l_program_update_date := sysdate;

    update PA_FORECAST_ITEM_DETAILS fid
    set    fid.PJI_SUMMARIZED_FLAG    = null,
           fid.LAST_UPDATE_DATE       = l_last_update_date,
           fid.LAST_UPDATED_BY        = l_last_updated_by,
           fid.REQUEST_ID             = l_request_id,
           fid.PROGRAM_APPLICATION_ID = l_program_appl_id,
           fid.PROGRAM_ID             = l_program_id,
           fid.PROGRAM_UPDATE_DATE    = l_program_update_date
    where  fid.PJI_SUMMARIZED_FLAG = 'N' and
           fid.FORECAST_ITEM_ID in
           (select /*+ cardinality(delta, 1) */
                   fi.FORECAST_ITEM_ID
            from   PJI_RES_DELTA delta,
                   PA_FORECAST_ITEMS fi
            where  delta.CHANGE_TYPE     = 'N'                    and
                   delta.RESOURCE_ID     = fi.RESOURCE_ID         and
                   fi.FORECAST_ITEM_TYPE in ('U', 'A')            and
                   fi.DELETE_FLAG        in ('Y', 'N')            and
                   fi.ITEM_DATE          between delta.START_DATE and
                                                 delta.END_DATE);

    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'FULL') then

      insert /*+ append */ into PJI_RM_REXT_FCSTITEM
      (
        WORKER_ID
      , FID_ROWID
      , START_DATE
      , END_DATE
      , PJI_SUMMARIZED_FLAG
      , BATCH_ID
      )
      SELECT /*+ index_ffs(fid, PA_FORECAST_ITEM_DETAILS_N2) */
        p_worker_id
      , fid.ROWID
      , null
      , null
      , fid.PJI_SUMMARIZED_FLAG
      , ceil(ROWNUM / PJI_RM_SUM_MAIN.g_commit_threshold)
      FROM
        PA_FORECAST_ITEM_DETAILS fid
      WHERE
        fid.PJI_SUMMARIZED_FLAG = 'N';

    else

      INSERT /*+ APPEND */ INTO PJI_RM_REXT_FCSTITEM
      (
        WORKER_ID
      , FID_ROWID
      , START_DATE
      , END_DATE
      , PJI_SUMMARIZED_FLAG
      , BATCH_ID
      )
      SELECT /*+ ORDERED
                 USE_NL(fid)
                 INDEX(fid, PA_FORECAST_ITEM_DETAILS_N2)
                 NOPARALLEL(bat)
              */
        p_worker_id    WORKER_ID
      , fid.ROWID      FID_ROWID
      , bat.start_date START_DATE
      , bat.end_date   END_DATE
      , fid.PJI_SUMMARIZED_FLAG
      , ceil(ROWNUM / PJI_RM_SUM_MAIN.g_commit_threshold)
      FROM
        pji_rm_org_batch_map     bat
      , pa_forecast_item_details fid
      , pji_rm_rext_fcstitem     fcst
      WHERE
        bat.WORKER_ID = p_worker_id                            and
        fid.EXPENDITURE_ORGANIZATION_ID  = bat.ORGANIZATION_ID and
        ((nvl(fid.PJI_SUMMARIZED_FLAG, 'N') <> 'X' and
          bat.EXTRACTION_TYPE in ('F', 'P')) or
         (fid.PJI_SUMMARIZED_FLAG = 'N' and
          bat.EXTRACTION_TYPE = 'I'))                          and
        p_worker_id = fcst.WORKER_ID (+)                       and
        fid.ROWID = fcst.FID_ROWID (+)                         and
        fcst.WORKER_ID is null;

    end if;

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_RM_SUM_EXTR.EXTRACT_BATCH_FID_ROWIDS(p_worker_id);');

    COMMIT;

  END EXTRACT_BATCH_FID_ROWIDS;

  -- -----------------------------------------------------
  -- procedure EXTRACT_BATCH_FID
  --
  -- The following steps are done in this procedure
  --   - Extract data from FID
  --   - Identify dangling records
  --   - Identify data for partial refresh
  --   - Aggregate and insert data into PJI_RM_AGGR_RES1
  -- -----------------------------------------------------
  PROCEDURE EXTRACT_BATCH_FID (p_worker_id IN NUMBER) IS

    l_process         VARCHAR2(30);
    l_min_date        NUMBER;
    l_extraction_type VARCHAR2(30);

    l_last_update_date    date;
    l_last_updated_by     number;
    l_request_id          number;
    l_program_appl_id     number;
    l_program_id          number;
    l_program_update_date date;

  BEGIN

    l_process := PJI_RM_SUM_MAIN.g_process || TO_CHAR(p_worker_id);

    IF (NOT PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_RM_SUM_EXTR.EXTRACT_BATCH_FID(p_worker_id);')) THEN
      RETURN;
    END IF;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'FULL' ) then
      return;
    end if;

    l_min_date := to_number(to_char(to_date(
                  PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE'),
                  PJI_RM_SUM_MAIN.g_date_mask), 'J'));

    -- implicit commit
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_RM_REXT_FCSTITEM',
                                 percent => 10,
                                 degree  => BIS_COMMON_PARAMETERS.
                                            GET_DEGREE_OF_PARALLELISM);

    -- Initial/Incremental collection from forecast log table
      insert /*+ append parallel(res1_i) */ into PJI_RM_AGGR_RES1 res1_i
      (
        WORKER_ID,
        DANGLING_FLAG,
        RECORD_TYPE,
        TOTAL_HRS_A,
        BILL_HRS_A,
        CAPACITY_HRS,
        CONF_HRS_S,
        PROV_HRS_S,
        UNASSIGNED_HRS_S,
        CONF_OVERCOM_HRS_S,
        PROV_OVERCOM_HRS_S,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        GL_CALENDAR_ID,
        PA_CALENDAR_ID,
        EXPENDITURE_ORGANIZATION_ID,
        EXPENDITURE_ORG_ID,
        TIME_ID,
        PERSON_ID,
        JOB_ID,
        WORK_TYPE_ID,
        PROJECT_ID
      )
      select
        WORKER_ID,
        DANGLING_FLAG,
        RECORD_TYPE,
        TOTAL_HRS_A,
        BILL_HRS_A,
        CAPACITY_HRS,
        CONF_HRS_S,
        PROV_HRS_S,
        UNASSIGNED_HRS_S,
        CONF_OVERCOM_HRS_S,
        PROV_OVERCOM_HRS_S,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        GL_CALENDAR_ID,
        PA_CALENDAR_ID,
        EXPENDITURE_ORGANIZATION_ID,
        EXPENDITURE_ORG_ID,
        TIME_ID,
        PERSON_ID,
        JOB_ID,
        WORK_TYPE_ID,
        PROJECT_ID
      from
        (
        select  -- Selecting data from source : FI
          WORKER_ID,
          DANGLING_FLAG,
          RECORD_TYPE,
          sum(TOTAL_HRS_A)        TOTAL_HRS_A,
          sum(BILL_HRS_A)         BILL_HRS_A,
          sum(CAPACITY_HRS)       CAPACITY_HRS,
          sum(CONF_HRS_S)         CONF_HRS_S,
          sum(PROV_HRS_S)         PROV_HRS_S,
          sum(UNASSIGNED_HRS_S)   UNASSIGNED_HRS_S,
          sum(CONF_OVERCOM_HRS_S) CONF_OVERCOM_HRS_S,
          sum(PROV_OVERCOM_HRS_S) PROV_OVERCOM_HRS_S,
          PERIOD_TYPE_ID,
          CALENDAR_TYPE,
          GL_CALENDAR_ID,
          PA_CALENDAR_ID,
          EXPENDITURE_ORGANIZATION_ID,
          EXPENDITURE_ORG_ID,
          TIME_ID,
          PERSON_ID,
          JOB_ID,
          WORK_TYPE_ID,
          PROJECT_ID
        from
          (
          select /*+ ordered use_nl(fid, fi, res)
                     parallel(scope) parallel(fi)
                     parallel(fid) parallel(res) */
            p_worker_id WORKER_ID,
            case when  res_info.ORG_ID is null
                 then 'O'
                 when greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) < res_info.EN_CALENDAR_MIN_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) > res_info.EN_CALENDAR_MAX_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) < res_info.GL_CALENDAR_MIN_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) > res_info.GL_CALENDAR_MAX_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) < res_info.PA_CALENDAR_MIN_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) > res_info.PA_CALENDAR_MAX_DATE
                 then 'T'
                 else null
            end DANGLING_FLAG,
            case when fi.FORECAST_ITEM_TYPE = 'U'
                 then 'U'
                 else 'N'
                 end RECORD_TYPE,
            case when fi.FORECAST_ITEM_TYPE = 'U'
                 then fid.CAPACITY_QUANTITY
                 else to_number(null)
            end CAPACITY_HRS,
            case when fi.FORECAST_ITEM_TYPE = 'A'
                 then fid.ITEM_QUANTITY *
                        decode(fi.PROVISIONAL_FLAG, 'N', 1, 0)
                 else to_number(null)
            end CONF_HRS_S,
            case when fi.FORECAST_ITEM_TYPE = 'A'
                 then fid.ITEM_QUANTITY *
                        decode(fi.PROVISIONAL_FLAG, 'Y', 1, 0)
                 else to_number(null)
            end PROV_HRS_S,
            case when fi.FORECAST_ITEM_TYPE = 'U'
                 then fid.ITEM_QUANTITY
                 else to_number(null)
            end UNASSIGNED_HRS_S,
            case when fi.FORECAST_ITEM_TYPE = 'U'
                 then fid.OVERCOMMITMENT_QTY *
                        decode(fi.OVERCOMMITMENT_FLAG,'Y',1,0)
                 else to_number(null)
            end CONF_OVERCOM_HRS_S,
            case when fi.FORECAST_ITEM_TYPE = 'U'
                 then fid.OVERPROVISIONAL_QTY *
                        decode(fi.OVERCOMMITMENT_FLAG,'Y',1,0)
                 else to_number(null)
            end PROV_OVERCOM_HRS_S,
            to_number(null) TOTAL_HRS_A,
            to_number(null) BILL_HRS_A,
            1 PERIOD_TYPE_ID,
            case when  res_info.ORG_ID is null
                 then 'C'
                 when greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) < res_info.PA_CALENDAR_MIN_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) > res_info.PA_CALENDAR_MAX_DATE
                 then 'P'
                 when greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) < res_info.GL_CALENDAR_MIN_DATE or
                      greatest(to_number(to_char( fi.ITEM_DATE, 'J')), l_min_date) > res_info.GL_CALENDAR_MAX_DATE
                 then 'G'
                 else 'C'
            end CALENDAR_TYPE ,
            res_info.GL_CALENDAR_ID,
            res_info.PA_CALENDAR_ID,
            fid.EXPENDITURE_ORGANIZATION_ID,
            fid.EXPENDITURE_ORG_ID,
            greatest(to_number(to_char(fi.ITEM_DATE,'J')), l_min_date) TIME_ID,
            fi.PERSON_ID,
            nvl(nvl(fid.JOB_ID, res.JOB_ID), -1) JOB_ID,
            fid.WORK_TYPE_ID,
            fid.PROJECT_ID
          from
            PJI_RM_REXT_FCSTITEM     scope,
            PA_FORECAST_ITEM_DETAILS fid,
            PA_FORECAST_ITEMS        fi,
            PJI_RM_WORK_TYPE_INFO    wt,
            PJI_RESOURCES_DENORM     res,
            PJI_ORG_EXTR_INFO        res_info
          where
            scope.WORKER_ID                  = p_worker_id           and
            scope.fid_rowid                  = fid.rowid             and
            fi.FORECAST_ITEM_ID              = fid.FORECAST_ITEM_ID  and
            fi.ITEM_DATE                     between scope.START_DATE
                                                 and scope.END_DATE  and
            fi.FORECAST_ITEM_TYPE            in ('U', 'A')           and
            fid.WORK_TYPE_ID                 = wt.WORK_TYPE_ID       and
            wt.RECORD_TYPE                   = 'NORMAL'              and
            res.PERSON_ID                    = fi.PERSON_ID          and
            res.UTILIZATION_FLAG             = 'Y'                   and
            fi.item_date between res.START_DATE and res.END_DATE     and
            fid.EXPENDITURE_ORG_ID           = res_info.ORG_ID
          union all
          select /*+ ordered */
            p_worker_id                           WORKER_ID,
            null                                  DANGLING_FLAG,
            'N'                                   RECORD_TYPE,
            to_number(null)                       CAPACITY_HRS,
            to_number(null)                       CONF_HRS_S,
            to_number(null)                       PROV_HRS_S,
            to_number(null)                       UNASSIGNED_HRS_S,
            to_number(null)                       CONF_OVERCOM_HRS_S,
            to_number(null)                       PROV_OVERCOM_HRS_S,
            res6.TOTAL_HRS_A,
            res6.BILL_HRS_A,
            1                                     PERIOD_TYPE_ID,
            res6.CALENDAR_TYPE,
            res6.GL_CALENDAR_ID,
            res6.PA_CALENDAR_ID,
            res6.EXPENDITURE_ORGANIZATION_ID,
            res6.EXPENDITURE_ORG_ID,
            res6.TIME_ID,
            res6.PERSON_ID,
            res6.JOB_ID,
            res6.WORK_TYPE_ID,
            res6.PROJECT_ID
          from
            PJI_PJI_RMAP_RES res6_r,
            PJI_RM_AGGR_RES6 res6
          where
            res6_r.WORKER_ID = p_worker_id and
            res6.ROWID = res6_r.STG_ROWID
        ) tmp1
      group by
        WORKER_ID,
        DANGLING_FLAG,
        RECORD_TYPE,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        GL_CALENDAR_ID,
        PA_CALENDAR_ID,
        EXPENDITURE_ORGANIZATION_ID,
        EXPENDITURE_ORG_ID,
        TIME_ID,
        PERSON_ID,
        JOB_ID,
        WORK_TYPE_ID,
        PROJECT_ID
      )
    where
      nvl(TOTAL_HRS_A, 0)        <> 0 or
      nvl(BILL_HRS_A, 0)         <> 0 or
      nvl(CAPACITY_HRS, 0)       <> 0 or
      nvl(CONF_HRS_S, 0)         <> 0 or
      nvl(PROV_HRS_S, 0)         <> 0 or
      nvl(UNASSIGNED_HRS_S, 0)   <> 0 or
      nvl(CONF_OVERCOM_HRS_S, 0) <> 0 or
      nvl(PROV_OVERCOM_HRS_S, 0) <> 0;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_RM_SUM_EXTR.EXTRACT_BATCH_FID(p_worker_id);');

    COMMIT;

  END EXTRACT_BATCH_FID;


  -- -----------------------------------------------------
  -- procedure MOVE_DANGLING_ROWS
  -- -----------------------------------------------------
  procedure MOVE_DANGLING_ROWS (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_RM_SUM_EXTR.MOVE_DANGLING_ROWS(p_worker_id);')) then
      return;
    end if;

    insert into PJI_RM_DNGL_RES
    (
      WORKER_ID,
      DANGLING_FLAG,
      RECORD_TYPE,
      TOTAL_HRS_A,
      BILL_HRS_A,
      CAPACITY_HRS,
      CONF_HRS_S,
      PROV_HRS_S,
      UNASSIGNED_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      EXPENDITURE_ORGANIZATION_ID,
      EXPENDITURE_ORG_ID,
      TIME_ID,
      PERSON_ID,
      JOB_ID,
      WORK_TYPE_ID,
      PROJECT_ID
    )
    select /*+ full(tmp) parallel(tmp) */
      0 WORKER_ID,
      DANGLING_FLAG,
      RECORD_TYPE,
      TOTAL_HRS_A,
      BILL_HRS_A,
      CAPACITY_HRS,
      CONF_HRS_S,
      PROV_HRS_S,
      UNASSIGNED_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      EXPENDITURE_ORGANIZATION_ID,
      EXPENDITURE_ORG_ID,
      TIME_ID,
      PERSON_ID,
      JOB_ID,
      WORK_TYPE_ID,
      PROJECT_ID
    from
      PJI_RM_AGGR_RES1 tmp
    where
      WORKER_ID = p_worker_id and
      DANGLING_FLAG is not null;

    delete
    from   PJI_RM_AGGR_RES1
    where  WORKER_ID = p_worker_id and
           DANGLING_FLAG is not null;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION (l_process, 'PJI_RM_SUM_EXTR.MOVE_DANGLING_ROWS(p_worker_id);');

    commit;

  end MOVE_DANGLING_ROWS;


  -- -----------------------------------------------------
  -- procedure PURGE_RES_DATA
  -- -----------------------------------------------------
  procedure PURGE_RES_DATA (p_worker_id in number) is

    l_process   varchar2(30);
    l_schema    varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_RM_SUM_EXTR.PURGE_RES_DATA(p_worker_id);')) then
      return;
    end if;

    delete
    from   PJI_RM_AGGR_RES6
    where  ROWID in (select STG_ROWID
                     from   PJI_PJI_RMAP_RES
                     where  WORKER_ID = p_worker_id);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_RM_SUM_EXTR.PURGE_RES_DATA(p_worker_id);');

    commit;

  end PURGE_RES_DATA;


  -- -----------------------------------------------------
  -- procedure GET_JOB_ID_LOOKUPS
  -- -----------------------------------------------------
  procedure GET_JOB_ID_LOOKUPS
  (
    p_worker_id in number
  ) is

    l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_RM_SUM_EXTR.GET_JOB_ID_LOOKUPS(p_worker_id);'
            )) then
      return;
    end if;

    insert /*+ append parallel(res3_i) */ into PJI_RM_AGGR_RES3 res3_i
    (
      WORKER_ID,
      PROJECT_ID,
      PERSON_ID,
      TIME_ID,
      CALENDAR_TYPE,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      JOB_ID
    )
    select /*+ parallel(tmp1) */
      p_worker_id,
      PROJECT_ID,
      PERSON_ID,
      TIME_ID,
      CALENDAR_TYPE,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      JOB_ID
    from
      PJI_RM_AGGR_RES1 tmp1
    where
      WORKER_ID         = p_worker_id and
      RECORD_TYPE       = 'U'         and
      CAPACITY_HRS     >= 0           and
      UNASSIGNED_HRS_S >= 0;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_RM_SUM_EXTR.GET_JOB_ID_LOOKUPS(p_worker_id);'
    );

    commit;

  end GET_JOB_ID_LOOKUPS;


  -- -----------------------------------------------------
  -- procedure PROCESS_JOB_ID
  -- -----------------------------------------------------
  procedure PROCESS_JOB_ID
  (
    p_worker_id in number
  ) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
              'PJI_RM_SUM_EXTR.PROCESS_JOB_ID(p_worker_id);'
            )) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    insert /*+ append parallel(res1_i) */ into PJI_RM_AGGR_RES1 res1_i
    (
      WORKER_ID,
      DANGLING_FLAG,
      RECORD_TYPE,
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
      CAPACITY_HRS,
      TOTAL_HRS_A,
      BILL_HRS_A,
      CONF_HRS_S,
      PROV_HRS_S,
      UNASSIGNED_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S
    )
    select
      p_worker_id             WORKER_ID,
      null                    DANGLING_FLAG,
      RECORD_TYPE,
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
      sum(CAPACITY_HRS)       CAPACITY_HRS,
      sum(TOTAL_HRS_A)        TOTAL_HRS_A,
      sum(BILL_HRS_A)         BILL_HRS_A,
      sum(CONF_HRS_S)         CONF_HRS_S,
      sum(PROV_HRS_S)         PROV_HRS_S,
      sum(UNASSIGNED_HRS_S)   UNASSIGNED_HRS_S,
      sum(CONF_OVERCOM_HRS_S) CONF_OVERCOM_HRS_S,
      sum(PROV_OVERCOM_HRS_S) PROV_OVERCOM_HRS_S
    from
      (
      select /*+ ordered
                 full(map)
             */ -- partial refresh (RM) and job Util --> Non-Util
        rmr.RECORD_TYPE,
        rmr.PROJECT_ID,
        rmr.PERSON_ID,
        rmr.EXPENDITURE_ORG_ID,
        rmr.EXPENDITURE_ORGANIZATION_ID,
        rmr.WORK_TYPE_ID,
        rmr.JOB_ID,
        rmr.TIME_ID,
        rmr.PERIOD_TYPE_ID,
        rmr.CALENDAR_TYPE,
        info.GL_CALENDAR_ID,
        info.PA_CALENDAR_ID,
        -rmr.CAPACITY_HRS       CAPACITY_HRS,
        to_number(null)         TOTAL_HRS_A,
        to_number(null)         BILL_HRS_A,
        -rmr.CONF_HRS_S         CONF_HRS_S,
        -rmr.PROV_HRS_S         PROV_HRS_S,
        -rmr.UNASSIGNED_HRS_S   UNASSIGNED_HRS_S,
        -rmr.CONF_OVERCOM_HRS_S CONF_OVERCOM_HRS_S,
        -rmr.PROV_OVERCOM_HRS_S PROV_OVERCOM_HRS_S
      from
        PJI_RM_ORG_BATCH_MAP map,
        PJI_RM_RES_WT_F      rmr,
        PJI_ORG_EXTR_INFO    info
      where
        l_extraction_type      = 'PARTIAL'                          and
        map.WORKER_ID          = p_worker_id                        and
        map.EXTRACTION_TYPE    = 'P'                                and
        rmr.PERIOD_TYPE_ID     = 1                                  and
        map.ORGANIZATION_ID    = rmr.EXPENDITURE_ORGANIZATION_ID    and
        rmr.TIME_ID between to_number(to_char(map.START_DATE, 'J'))
                    and     to_number(to_char(map.END_DATE, 'J'))   and
        rmr.EXPENDITURE_ORG_ID = info.ORG_ID
      union all -- partial refresh (FM) and job Util --> Non-Util
      select /*+ ordered
                 full(map)
             */
        rmr.RECORD_TYPE,
        rmr.PROJECT_ID,
        rmr.PERSON_ID,
        rmr.EXPENDITURE_ORG_ID,
        rmr.EXPENDITURE_ORGANIZATION_ID,
        rmr.WORK_TYPE_ID,
        rmr.JOB_ID,
        rmr.TIME_ID,
        rmr.PERIOD_TYPE_ID,
        rmr.CALENDAR_TYPE,
        info.GL_CALENDAR_ID,
        info.PA_CALENDAR_ID,
        to_number(null)         CAPACITY_HRS,
        -rmr.TOTAL_HRS_A        TOTAL_HRS_A,
        -rmr.BILL_HRS_A         BILL_HRS_A,
        to_number(null)         CONF_HRS_S,
        to_number(null)         PROV_HRS_S,
        to_number(null)         UNASSIGNED_HRS_S,
        to_number(null)         CONF_OVERCOM_HRS_S,
        to_number(null)         PROV_OVERCOM_HRS_S
      from
        PJI_PJI_PROJ_BATCH_MAP map,
        PJI_RM_RES_WT_F        rmr,
        PJI_ORG_EXTR_INFO      info
      where
        l_extraction_type      = 'PARTIAL'      and
        map.WORKER_ID          = p_worker_id    and
        map.EXTRACTION_TYPE    = 'P'            and
        rmr.PERIOD_TYPE_ID     = 1              and
        map.PROJECT_ID         = rmr.PROJECT_ID and
        rmr.EXPENDITURE_ORG_ID = info.ORG_ID
      union all  --  JOB_ID Util --> Non-Util corrections
      select /*+ ordered
                 full(delta)
                 full(map)
             */
        rmr.RECORD_TYPE,
        rmr.PROJECT_ID,
        rmr.PERSON_ID,
        rmr.EXPENDITURE_ORG_ID,
        rmr.EXPENDITURE_ORGANIZATION_ID,
        rmr.WORK_TYPE_ID,
        rmr.JOB_ID,
        rmr.TIME_ID,
        rmr.PERIOD_TYPE_ID,
        rmr.CALENDAR_TYPE,
        info.GL_CALENDAR_ID,
        info.PA_CALENDAR_ID,
        -rmr.CAPACITY_HRS       CAPACITY_HRS,
        -rmr.TOTAL_HRS_A        TOTAL_HRS_A,
        -rmr.BILL_HRS_A         BILL_HRS_A,
        -rmr.CONF_HRS_S         CONF_HRS_S,
        -rmr.PROV_HRS_S         PROV_HRS_S,
        -rmr.UNASSIGNED_HRS_S   UNASSIGNED_HRS_S,
        -rmr.CONF_OVERCOM_HRS_S CONF_OVERCOM_HRS_S,
        -rmr.PROV_OVERCOM_HRS_S PROV_OVERCOM_HRS_S
      from
        PJI_RES_DELTA          delta,
        PJI_RM_RES_WT_F        rmr,
        PJI_RM_ORG_BATCH_MAP   map,
        PJI_PJI_PROJ_BATCH_MAP fm_map,
        PJI_ORG_EXTR_INFO      info
      where
        l_extraction_type               = 'PARTIAL'                   and
        delta.CHANGE_TYPE               = 'N'                         and
        delta.PERSON_ID                 = rmr.PERSON_ID               and
        rmr.PERIOD_TYPE_ID              = 1                           and
        rmr.TIME_ID between to_number(to_char(delta.START_DATE, 'J')) and
                            to_number(to_char(delta.END_DATE, 'J'))   and
        p_worker_id                     = map.WORKER_ID       (+)     and
        'P'                             = map.EXTRACTION_TYPE (+)     and
        rmr.EXPENDITURE_ORGANIZATION_ID = map.ORGANIZATION_ID (+)     and
        rmr.TIME_ID between to_number(to_char(map.START_DATE (+), 'J')) and
                            to_number(to_char(map.END_DATE (+), 'J')) and
        map.WORKER_ID                   is null                       and
        p_worker_id                     = fm_map.WORKER_ID       (+)  and
        'P'                             = fm_map.EXTRACTION_TYPE (+)  and
        rmr.PROJECT_ID                  = fm_map.PROJECT_ID      (+)  and
        fm_map.WORKER_ID                is null                       and
        rmr.EXPENDITURE_ORG_ID          = info.ORG_ID
      union all  --  JOB_ID Util --> Non-Util corrections
      select /*+ ordered
                 full(delta)
                 full(info)
             */
        rmr.RECORD_TYPE,
        rmr.PROJECT_ID,
        rmr.PERSON_ID,
        rmr.EXPENDITURE_ORG_ID,
        rmr.EXPENDITURE_ORGANIZATION_ID,
        rmr.WORK_TYPE_ID,
        rmr.JOB_ID,
        rmr.TIME_ID,
        rmr.PERIOD_TYPE_ID,
        rmr.CALENDAR_TYPE,
        info.GL_CALENDAR_ID,
        info.PA_CALENDAR_ID,
        -rmr.CAPACITY_HRS,
        -rmr.TOTAL_HRS_A,
        -rmr.BILL_HRS_A,
        -rmr.CONF_HRS_S,
        -rmr.PROV_HRS_S,
        -rmr.UNASSIGNED_HRS_S,
        -rmr.CONF_OVERCOM_HRS_S,
        -rmr.PROV_OVERCOM_HRS_S
      from
        PJI_RES_DELTA delta,
        PJI_RM_RES_WT_F rmr,
        PJI_ORG_EXTR_INFO info
      where
        l_extraction_type   = 'INCREMENTAL'       and
        delta.CHANGE_TYPE   = 'N'                 and
        delta.PERSON_ID     = rmr.PERSON_ID       and
        rmr.PERIOD_TYPE_ID  = 1                   and
        rmr.TIME_ID between to_number(to_char(delta.START_DATE, 'J')) and
                            to_number(to_char(delta.END_DATE, 'J')) and
        rmr.EXPENDITURE_ORG_ID = info.ORG_ID
      union all     -- JOB_ID corrections for 'A' slice of rmr
      select /*+ ordered
                 full(tmp3)
                 parallel(rmr) */
        'A'                                 RECORD_TYPE,
        rmr.PROJECT_ID,
        rmr.PERSON_ID,
        rmr.EXPENDITURE_ORG_ID,
        rmr.EXPENDITURE_ORGANIZATION_ID,
        rmr.WORK_TYPE_ID,
        case when invert.INVERT_ID = 'TMP3'
             then tmp3.JOB_ID
             when invert.INVERT_ID = 'RMR'
             then rmr.JOB_ID
             end                            JOB_ID,
        rmr.TIME_ID,
        rmr.PERIOD_TYPE_ID,
        rmr.CALENDAR_TYPE,
        tmp3.GL_CALENDAR_ID,
        tmp3.PA_CALENDAR_ID,
        case when invert.INVERT_ID = 'TMP3'
             then rmr.CAPACITY_HRS
             when invert.INVERT_ID = 'RMR'
             then -rmr.CAPACITY_HRS
             end                            CAPACITY_HRS,
        case when invert.INVERT_ID = 'TMP3'
             then rmr.TOTAL_HRS_A
             when invert.INVERT_ID = 'RMR'
             then -rmr.TOTAL_HRS_A
             end                            TOTAL_HRS_A,
        case when invert.INVERT_ID = 'TMP3'
             then rmr.BILL_HRS_A
             when invert.INVERT_ID = 'RMR'
             then -rmr.BILL_HRS_A
             end                            BILL_HRS_A,
        case when invert.INVERT_ID = 'TMP3'
             then rmr.CONF_HRS_S
             when invert.INVERT_ID = 'RMR'
             then -rmr.CONF_HRS_S
             end                            CONF_HRS_S,
        case when invert.INVERT_ID = 'TMP3'
             then rmr.PROV_HRS_S
             when invert.INVERT_ID = 'RMR'
             then -rmr.PROV_HRS_S
             end                            PROV_HRS_S,
        case when invert.INVERT_ID = 'TMP3'
             then rmr.UNASSIGNED_HRS_S
             when invert.INVERT_ID = 'RMR'
             then -rmr.UNASSIGNED_HRS_S
             end                            UNASSIGNED_HRS_S,
        case when invert.INVERT_ID = 'TMP3'
             then rmr.CONF_OVERCOM_HRS_S
             when invert.INVERT_ID = 'RMR'
             then -rmr.CONF_OVERCOM_HRS_S
             end                            CONF_OVERCOM_HRS_S,
        case when invert.INVERT_ID = 'TMP3'
             then rmr.PROV_OVERCOM_HRS_S
             when invert.INVERT_ID = 'RMR'
             then -rmr.PROV_OVERCOM_HRS_S
             end                            PROV_OVERCOM_HRS_S
      from
        PJI_RM_AGGR_RES3 tmp3,
        PJI_RM_RES_WT_F  rmr,
        PJI_RES_DELTA    delta,
        (
        select 'TMP3' INVERT_ID from dual union all
        select 'RMR'  INVERT_ID from dual
        ) invert
      where
        l_extraction_type  <> 'PARTIAL'                                     and
        tmp3.WORKER_ID      = p_worker_id                                   and
        'A'                 = rmr.RECORD_TYPE                               and
        tmp3.PERSON_ID      = rmr.PERSON_ID                                 and
        tmp3.JOB_ID        <> rmr.JOB_ID                                    and
        tmp3.TIME_ID        = rmr.TIME_ID                                   and
        1                   = rmr.PERIOD_TYPE_ID                            and
        tmp3.CALENDAR_TYPE  = rmr.CALENDAR_TYPE                             and
        'N'                 = delta.CHANGE_TYPE (+)                         and
        rmr.PERSON_ID       = delta.PERSON_ID (+)                           and
        rmr.TIME_ID        >= to_number(to_char(delta.START_DATE (+), 'J')) and
        rmr.TIME_ID        <= to_number(to_char(delta.END_DATE (+), 'J'))   and
        delta.PERSON_ID     is null
      union all     -- JOB_ID lookups for assignments in tmp1
      select /*+ ordered index(tmp3, PJI_RM_AGGR_RES3_N1)
                         index(rmr, PJI_RM_RES_WT_F_N2)
                         parallel(rmr) */
        'A' RECORD_TYPE,
        tmp1.PROJECT_ID,
        tmp1.PERSON_ID,
        tmp1.EXPENDITURE_ORG_ID,
        tmp1.EXPENDITURE_ORGANIZATION_ID,
        tmp1.WORK_TYPE_ID,
        nvl(tmp3.JOB_ID, nvl(rmr.JOB_ID, -1)) JOB_ID,
        tmp1.TIME_ID,
        tmp1.PERIOD_TYPE_ID,
        tmp1.CALENDAR_TYPE,
        tmp1.GL_CALENDAR_ID,
        tmp1.PA_CALENDAR_ID,
        tmp1.CAPACITY_HRS,
        tmp1.TOTAL_HRS_A,
        tmp1.BILL_HRS_A,
        tmp1.CONF_HRS_S,
        tmp1.PROV_HRS_S,
        tmp1.UNASSIGNED_HRS_S,
        tmp1.CONF_OVERCOM_HRS_S,
        tmp1.PROV_OVERCOM_HRS_S
      from
        PJI_RM_AGGR_RES1 tmp1,
        PJI_RM_AGGR_RES3 tmp3,
        PJI_RM_RES_WT_F  rmr
      where
        tmp1.WORKER_ID             = p_worker_id                          and
        tmp1.RECORD_TYPE           = 'N'                                  and
        p_worker_id                = tmp3.WORKER_ID                   (+) and
        tmp1.PERSON_ID             = tmp3.PERSON_ID                   (+) and
        tmp1.TIME_ID               = tmp3.TIME_ID                     (+) and
        tmp1.PERIOD_TYPE_ID        = 1                                    and
        tmp1.CALENDAR_TYPE         = tmp3.CALENDAR_TYPE               (+) and
        'U'                        = rmr.RECORD_TYPE                  (+) and
        tmp1.PERSON_ID             = rmr.PERSON_ID                    (+) and
        tmp1.EXPENDITURE_ORG_ID    = rmr.EXPENDITURE_ORG_ID           (+) and
        tmp1.EXPENDITURE_ORGANIZATION_ID
                                   = rmr.EXPENDITURE_ORGANIZATION_ID  (+) and
        tmp1.TIME_ID               = rmr.TIME_ID                      (+) and
        tmp1.PERIOD_TYPE_ID        = rmr.PERIOD_TYPE_ID               (+) and
        tmp1.CALENDAR_TYPE         = rmr.CALENDAR_TYPE                (+)
      union all -- reversals for deleted projects
      select /*+ ordered
                 index(rmr, PJI_RM_RES_WT_F_N3)
                 full(delta)
                 full(info)
             */
        rmr.RECORD_TYPE,
        rmr.PROJECT_ID,
        rmr.PERSON_ID,
        rmr.EXPENDITURE_ORG_ID,
        rmr.EXPENDITURE_ORGANIZATION_ID,
        rmr.WORK_TYPE_ID,
        rmr.JOB_ID,
        rmr.TIME_ID,
        rmr.PERIOD_TYPE_ID,
        rmr.CALENDAR_TYPE,
        info.GL_CALENDAR_ID,
        info.PA_CALENDAR_ID,
        -rmr.CAPACITY_HRS,
        -rmr.TOTAL_HRS_A,
        -rmr.BILL_HRS_A,
        -rmr.CONF_HRS_S,
        -rmr.PROV_HRS_S,
        -rmr.UNASSIGNED_HRS_S,
        -rmr.CONF_OVERCOM_HRS_S,
        -rmr.PROV_OVERCOM_HRS_S
      from
        (
        select
          PROJECT_ID
        from
          (
          select /*+ index_ffs(rmr, PJI_RM_RES_WT_F_N3)
                      parallel_index(rmr, PJI_RM_RES_WT_F_N3) */
            distinct
            PROJECT_ID
          from
            PJI_RM_RES_WT_F rmr
          where
            PROJECT_ID is not null and
            PROJECT_ID <> -1
          ) pji
        where
          not exists (select 1
                      from  PA_PROJECTS_ALL pa
                      where  pa.PROJECT_ID = pji.PROJECT_ID)
        ) prj,
        PJI_RM_RES_WT_F rmr,
        PJI_RES_DELTA delta,
        PJI_ORG_EXTR_INFO info
      where
        l_extraction_type      = 'INCREMENTAL'                          and
        rmr.PROJECT_ID         = prj.PROJECT_ID                         and
        rmr.PERIOD_TYPE_ID     = 1                                      and
        rmr.TIME_ID between to_number(to_char(delta.START_DATE (+), 'J')) and
                            to_number(to_char(delta.END_DATE (+), 'J')) and
        rmr.PERSON_ID          = delta.PERSON_ID (+)                    and
        delta.PERSON_ID        is null                                  and
        rmr.EXPENDITURE_ORG_ID = info.ORG_ID
      )
    group by
      RECORD_TYPE,
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
      PA_CALENDAR_ID;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_RM_SUM_EXTR.PROCESS_JOB_ID(p_worker_id);'
    );

    commit;

  end PROCESS_JOB_ID;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_ROWS_PRE
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_ROWS_PRE
  (
    p_worker_id in number
  ) is

    l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
              'PJI_RM_SUM_EXTR.MARK_EXTRACTED_ROWS_PRE(p_worker_id);')) then
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
      PJI_RM_REXT_FCSTITEM
    where
      PJI_SUMMARIZED_FLAG is not null;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION (l_process,
      'PJI_RM_SUM_EXTR.MARK_EXTRACTED_ROWS_PRE(p_worker_id);');

    commit;

  end MARK_EXTRACTED_ROWS_PRE;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_ROWS
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_ROWS
  (
    p_worker_id in number
  ) is

  l_process             varchar2(30);
  l_last_update_date    date;
  l_last_updated_by     number;
  l_request_id          number;
  l_program_appl_id     number;
  l_program_id          number;
  l_program_update_date date;
  l_helper_batch_id     number;
  l_parallel_processes  number;
  l_row_count           number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
                                              'PJI_RM_SUM_EXTR.MARK_EXTRACTED_ROWS(p_worker_id);')) then
      return;
    end if;

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_request_id        := FND_GLOBAL.CONC_REQUEST_ID;
    l_program_appl_id   := FND_GLOBAL.PROG_APPL_ID;
    l_program_id        := FND_GLOBAL.CONC_PROGRAM_ID;
    l_program_update_date := sysdate;
    l_helper_batch_id   := 0;

    while (l_helper_batch_id <> -1) loop

      update    PJI_HELPER_BATCH_MAP
      set       WORKER_ID = p_worker_id,
                STATUS = 'P'
      where     WORKER_ID is null and
                ROWNUM = 1
      returning BATCH_ID
      into      l_helper_batch_id;

      if (sql%rowcount <> 0) then

        commit;

        update PA_FORECAST_ITEM_DETAILS
        set
          PJI_SUMMARIZED_FLAG    = null,
          LAST_UPDATE_DATE       = l_last_update_date,
          LAST_UPDATED_BY        = l_last_updated_by,
          REQUEST_ID             = l_request_id,
          PROGRAM_APPLICATION_ID = l_program_appl_id,
          PROGRAM_ID             = l_program_id,
          PROGRAM_UPDATE_DATE    = l_program_update_date
        where
          ROWID in
          (
            select /*+ cardinality(fcst, 1) */
              fcst.FID_ROWID
            from
              PJI_RM_REXT_FCSTITEM fcst
            where
              fcst.PJI_SUMMARIZED_FLAG = 'N' and
              fcst.BATCH_ID = l_helper_batch_id
          );

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

          l_parallel_processes := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process, 'PARALLEL_PROCESSES');

          for x in 2 .. l_parallel_processes loop

            update PJI_SYSTEM_PRC_STATUS
            set    STEP_STATUS = 'C'
            where  PROCESS_NAME like PJI_RM_SUM_MAIN.g_process|| to_char(x) and
                   STEP_NAME = 'PJI_RM_SUM_EXTR.MARK_EXTRACTED_ROWS(p_worker_id);' and
                   START_DATE is null;

            commit;

          end loop;

          l_helper_batch_id := -1;

        end if;

      end if;

    end loop;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION (l_process,
                                               'PJI_RM_SUM_EXTR.MARK_EXTRACTED_ROWS(p_worker_id);');

    commit;

  end MARK_EXTRACTED_ROWS;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_ROWS_POST
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_ROWS_POST
  (
    p_worker_id in number
  ) is

    l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process,
              'PJI_RM_SUM_EXTR.MARK_EXTRACTED_ROWS_POST(p_worker_id);')) then
      return;
    end if;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE('PJI',
                                     'PJI_HELPER_BATCH_MAP',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION (l_process,
      'PJI_RM_SUM_EXTR.MARK_EXTRACTED_ROWS_POST(p_worker_id);');

    commit;

  end MARK_EXTRACTED_ROWS_POST;


  -- -----------------------------------------------------
  -- procedure CLEANUP_WORKER
  -- -----------------------------------------------------
  procedure CLEANUP_WORKER
  (
    p_worker_id in number
  ) is

    l_process varchar2(30);
    l_schema varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    PJI_PJ_PROJ_CLASS_EXTR.CLEANUP(p_worker_id);
    PJI_FM_PLAN_EXTR.CLEANUP(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.CLEANUP(p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_RM_REXT_FCSTITEM',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_PJI_RMAP_RES',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_PJI_RMAP_FIN',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_PJI_RMAP_ACT',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_RM_AGGR_RES3',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_RES_DELTA',
                                     'NORMAL',
                                     null);

    delete
    from   PJI_FM_AGGR_DLY_RATES
    where  WORKER_ID = -1;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_RMAP_FIN',
                                     'NORMAL',
                                     null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_RMAP_ACT',
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

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process, 'PROCESS_RUNNING', 'F');

    commit;

    pji_utils.write2log(sqlerrm, true, 0);

    commit;

  end WRAPUP_FAILURE;


  -- -----------------------------------------------------
  -- procedure WORKER
  -- -----------------------------------------------------
  procedure WORKER (p_worker_id in number) is

  begin

    PJI_PJI_EXTRACTION_UTILS.SEED_PJI_RM_STATS;

    PJI_PJI_EXTRACTION_UTILS.POPULATE_ORG_EXTR_INFO;

    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_ORG_EXTR_INFO',
                                 percent => 10,
                                 degree  => PJI_UTILS.
                                            GET_DEGREE_OF_PARALLELISM);
    FND_STATS.GATHER_INDEX_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 indname => 'PJI_ORG_EXTR_INFO_N1',
                                 percent => 10);

    -- Reset status for Availability helper workers
    PJI_RM_SUM_AVL.UPDATE_RES_STATUS;

    -- Populate Rolling Week Offset Table if it is not populated
    PJI_RM_SUM_AVL.POP_ROLL_WEEK_OFFSET;

    PJI_PROCESS_UTIL.CLEAN_HELPER_BATCH_TABLE;

    -- Procedure updates project classification dimension tables
    -- PJI_CLASS_CODES and PJI_CLASS_CATEGORIES. Data extraction is
    -- always incremental.
    PJI_PJ_PROJ_CLASS_EXTR.EXTR_CLASS_CODES;

    -- Populates PJI_ORG_DENORM to be used with the Materialized views
    PJI_PJI_EXTRACTION_UTILS.UPDATE_PJI_ORG_HRCHY;

    PJI_FM_PLAN_EXTR.UPDATE_PLAN_ORG_INFO(p_worker_id);
    PJI_FM_PLAN_EXTR.EXTRACT_PLAN_VERSIONS(p_worker_id);
    PJI_FM_PLAN_EXTR.EXTRACT_BATCH_PLAN(p_worker_id );
    PJI_FM_PLAN_EXTR.SPREAD_ENT_PLANS(p_worker_id);
    PJI_FM_PLAN_EXTR.PLAN_CURR_CONV_TABLE(p_worker_id);
    PJI_FM_PLAN_EXTR.CONVERT_TO_GLOBAL_CURRENCY(p_worker_id);
    PJI_FM_PLAN_EXTR.CONVERT_TO_GLOBAL2_CURRENCY(p_worker_id);
    PJI_FM_PLAN_EXTR.CONVERT_TO_PA_PERIODS(p_worker_id);
    PJI_FM_PLAN_EXTR.CONVERT_TO_GL_PERIODS(p_worker_id);
    PJI_FM_PLAN_EXTR.CONVERT_TO_ENT_PERIODS(p_worker_id);
    PJI_FM_PLAN_EXTR.CONVERT_TO_ENTW_PERIODS(p_worker_id);
    PJI_FM_PLAN_EXTR.DANGLING_PLAN_VERSIONS(p_worker_id);
    PJI_FM_PLAN_EXTR.SUMMARIZE_EXTRACT(p_worker_id);
    PJI_FM_PLAN_EXTR.EXTRACT_UPDATED_VERSIONS(p_worker_id);

    PJI_FM_PLAN_EXTR.UPDATE_BATCH_VERSIONS_PRE(p_worker_id);
    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_RM_SUM_MAIN.g_process,
             'PJI_FM_PLAN_EXTR.UPDATE_BATCH_VERSIONS(p_worker_id);',
             PJI_RM_SUM_MAIN.g_process_delay)) then
      return;
    end if;
    PJI_FM_PLAN_EXTR.UPDATE_BATCH_VERSIONS_POST(p_worker_id);
    PJI_FM_PLAN_EXTR.UPDATE_BATCH_STATUSES(p_worker_id);

    PJI_PJ_PROJ_CLASS_EXTR.EXTR_PROJECT_CLASSES(p_worker_id);

    PJI_RM_SUM_EXTR.PROCESS_DANGLING_ROWS(p_worker_id);
    PJI_RM_SUM_EXTR.PURGE_DANGLING_ROWS(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.JOB_NONUTIL2UTIL(p_worker_id);
    PJI_RM_SUM_EXTR.EXTRACT_BATCH_FID_ROWIDS(p_worker_id);

    PJI_RM_SUM_EXTR.MARK_EXTRACTED_ROWS_PRE(p_worker_id);
    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_RM_SUM_MAIN.g_process,
            'PJI_RM_SUM_EXTR.MARK_EXTRACTED_ROWS(p_worker_id);',
             PJI_RM_SUM_MAIN.g_process_delay)) then
      return;
    end if;
    PJI_RM_SUM_EXTR.MARK_EXTRACTED_ROWS_POST(p_worker_id);

    PJI_RM_SUM_EXTR.RES_ROWID_TABLE(p_worker_id);
    PJI_RM_SUM_EXTR.EXTRACT_BATCH_FID_FULL(p_worker_id);
    PJI_RM_SUM_EXTR.EXTRACT_BATCH_FID(p_worker_id);
    PJI_RM_SUM_EXTR.MOVE_DANGLING_ROWS(p_worker_id);
    PJI_RM_SUM_EXTR.PURGE_RES_DATA(p_worker_id);
    PJI_RM_SUM_EXTR.GET_JOB_ID_LOOKUPS(p_worker_id);
    PJI_RM_SUM_EXTR.PROCESS_JOB_ID(p_worker_id);

    PJI_RM_SUM_ROLLUP_RES.CALC_RMS_AVL_AND_WT(p_worker_id);

    PJI_RM_SUM_AVL.INS_INTO_RES_STATUS(p_worker_id);
    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_RM_SUM_MAIN.g_process,
             'PJI_RM_SUM_AVL.START_RES_AVL_CALC_R1(p_worker_id);',
             PJI_RM_SUM_MAIN.g_process_delay)) then
      return;
    end if;

    PJI_FM_SUM_BKLG.ROWID_ACTIVITY_DATES_FIN(p_worker_id);
    PJI_FM_SUM_BKLG.UPDATE_ACTIVITY_DATES_FIN(p_worker_id);
    PJI_FM_SUM_BKLG.ROWID_ACTIVITY_DATES_ACT(p_worker_id);
    PJI_FM_SUM_BKLG.UPDATE_ACTIVITY_DATES_ACT(p_worker_id);

    PJI_FM_SUM_ROLLUP_FIN.FIN_ROWID_TABLE(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.AGGREGATE_FIN_ET_WT_SLICES(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.PURGE_FIN_DATA(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.AGGREGATE_FIN_ET_SLICES(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.AGGREGATE_FIN_SLICES(p_worker_id);

    PJI_FM_SUM_ROLLUP_ACT.ACT_ROWID_TABLE(p_worker_id);
    PJI_FM_SUM_ROLLUP_ACT.AGGREGATE_ACT_SLICES(p_worker_id);
    PJI_FM_SUM_ROLLUP_ACT.PURGE_ACT_DATA(p_worker_id);

    PJI_RM_SUM_ROLLUP_RES.EXPAND_RMR_CAL_EN(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.EXPAND_RMR_CAL_PA(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.EXPAND_RMR_CAL_GL(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.EXPAND_RMR_CAL_WK(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.EXPAND_RMS_CAL_EN(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.EXPAND_RMS_CAL_PA(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.EXPAND_RMS_CAL_GL(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.EXPAND_RMS_CAL_WK(p_worker_id);

    PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPW_CAL_EN(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPW_CAL_PA(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPW_CAL_GL(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPW_CAL_WK(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPE_CAL_EN(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPE_CAL_PA(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPE_CAL_GL(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPE_CAL_WK(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPP_CAL_EN(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPP_CAL_PA(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPP_CAL_GL(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.EXPAND_FPP_CAL_WK(p_worker_id);

    PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_EN(p_worker_id, 'N');
    PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_PA(p_worker_id, 'N');
    PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_GL(p_worker_id, 'N');
    PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_WK(p_worker_id, 'N');

    PJI_RM_SUM_ROLLUP_RES.MERGE_TMP1_INTO_RMR(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.CLEANUP_RMR(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.MERGE_TMP2_INTO_RMS(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.CLEANUP_RMS(p_worker_id);

    PJI_RM_SUM_AVL.UPDATE_RES_STA_FOR_RUN2(p_worker_id);
    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_RM_SUM_MAIN.g_process,
            'PJI_RM_SUM_AVL.START_RES_AVL_CALC_R2(p_worker_id);',
             PJI_RM_SUM_MAIN.g_process_delay)) then
      return;
    end if;
    PJI_RM_SUM_AVL.MERGE_ORG_AVL_DUR(p_worker_id);
    PJI_RM_SUM_AVL.MERGE_CURR_ORG_AVL(p_worker_id);
    PJI_RM_SUM_AVL.RES_CALC_CLEANUP(p_worker_id);

    PJI_FM_SUM_ROLLUP_FIN.MERGE_FIN_INTO_FPW(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.MERGE_FIN_INTO_FPE(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.MERGE_FIN_INTO_FPP(p_worker_id);
    PJI_FM_SUM_ROLLUP_ACT.MERGE_ACT_INTO_ACP(p_worker_id, 'N');

    PJI_FM_SUM_BKLG.SCOPE_PROJECTS_BKLG(p_worker_id);
    PJI_FM_SUM_BKLG.CLEANUP_INT_TABLE(p_worker_id);
    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_RM_SUM_MAIN.g_process,
             'PJI_FM_SUM_BKLG.PROCESS_DRMT_BKLG(p_worker_id);',
             PJI_RM_SUM_MAIN.g_process_delay)) then
      return;
    end if;

    PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_EN(p_worker_id, 'Y');
    PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_PA(p_worker_id, 'Y');
    PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_GL(p_worker_id, 'Y');
    PJI_FM_SUM_ROLLUP_ACT.EXPAND_ACT_CAL_WK(p_worker_id, 'Y');

    PJI_FM_SUM_ROLLUP_ACT.MERGE_ACT_INTO_ACP(p_worker_id, 'Y');

    PJI_FM_SUM_ROLLUP_FIN.PROJECT_ORGANIZATION(p_worker_id);
    PJI_FM_SUM_ROLLUP_ACT.PROJECT_ORGANIZATION(p_worker_id);

    PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_UTW(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_UTX(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_UTJ(p_worker_id);

    PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_TIME(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_TIME_DAY(p_worker_id);
    PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_TIME_TREND(p_worker_id);

    PJI_RM_SUM_AVL.REFRESH_AV_ORGO_F_MV(p_worker_id);
    PJI_RM_SUM_AVL.REFRESH_CA_ORGO_F_MV(p_worker_id);

    PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FWO(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FWC(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FEO(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FEC(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FPO(p_worker_id);
    PJI_FM_SUM_ROLLUP_FIN.REFRESH_MVIEW_FPC(p_worker_id);
    PJI_FM_SUM_ROLLUP_ACT.REFRESH_MVIEW_ACO(p_worker_id);
    PJI_FM_SUM_ROLLUP_ACT.REFRESH_MVIEW_ACC(p_worker_id);

    CLEANUP_WORKER(p_worker_id);

  end WORKER;


  -- -----------------------------------------------------
  -- procedure HELPER
  -- -----------------------------------------------------
  procedure HELPER
  (
    errbuf      out nocopy varchar2,
    retcode     out nocopy varchar2,
    p_worker_id in         number
  ) is

    l_process varchar2(30);

  begin

    -- If this helper's concurrent request ID does not exist in the
    -- parameters table, the dispatcher must have kicked off a new
    -- helper.  Therefore do nothing.
    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process,
                                               PJI_RM_SUM_MAIN.g_process ||
                                               to_char(p_worker_id))
        <> FND_GLOBAL.CONC_REQUEST_ID) then
      pji_utils.write2log('Warning: Helper is already running.');
      commit;
      retcode := 0;
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_RM_SUM_MAIN.g_process,
             'PJI_FM_PLAN_EXTR.UPDATE_BATCH_VERSIONS_PRE(p_worker_id);',
             PJI_RM_SUM_MAIN.g_process_delay,
             'EVEN_IF_NOT_EXISTS')) then
      return;
    end if;

    PJI_FM_PLAN_EXTR.UPDATE_BATCH_VERSIONS(p_worker_id);

    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_RM_SUM_MAIN.g_process,
             'PJI_RM_SUM_EXTR.MARK_EXTRACTED_ROWS_PRE(p_worker_id);',
             PJI_RM_SUM_MAIN.g_process_delay)) then
      return;
    end if;

    PJI_RM_SUM_EXTR.MARK_EXTRACTED_ROWS(p_worker_id);

    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_RM_SUM_MAIN.g_process,
             'PJI_RM_SUM_AVL.INS_INTO_RES_STATUS(p_worker_id);',
             PJI_RM_SUM_MAIN.g_process_delay)) then
      return;
    end if;

    PJI_RM_SUM_AVL.START_RES_AVL_CALC_R1(p_worker_id);

    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_RM_SUM_MAIN.g_process,
            'PJI_RM_SUM_AVL.UPDATE_RES_STA_FOR_RUN2(p_worker_id);',
             PJI_RM_SUM_MAIN.g_process_delay)) then
      return;
    end if;

    PJI_RM_SUM_AVL.START_RES_AVL_CALC_R2(p_worker_id);

    if (not PJI_PROCESS_UTIL.WAIT_FOR_STEP
            (PJI_RM_SUM_MAIN.g_process,
             'PJI_FM_SUM_BKLG.CLEANUP_INT_TABLE(p_worker_id);',
             PJI_RM_SUM_MAIN.g_process_delay)) then
      return;
    end if;

    PJI_FM_SUM_BKLG.PROCESS_DRMT_BKLG(p_worker_id);

    while (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
           (PJI_RM_SUM_MAIN.g_process, 'PROCESS_RUNNING') = 'Y') loop
      PJI_PROCESS_UTIL.SLEEP(PJI_RM_SUM_MAIN.g_process_delay);
    end loop;

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
        (PJI_RM_SUM_MAIN.g_process, 'PROCESS_RUNNING') = 'F') then
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
  procedure START_HELPER
  (
    p_worker_id in number
  ) is

    l_process varchar2(30);
    l_extraction_type varchar2(30);

  begin

    -- If a helper with this concurrent request ID is already running
    -- then we do not need to do anything.
    if (WORKER_STATUS(p_worker_id, 'RUNNING')) then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    -- Initialize status tables with worker details

    -- Note that adding a new step will do nothing if the step already
    -- exists.  Therefore, no state will be overwritten in the case of
    -- error recovery.

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    PJI_PROCESS_UTIL.ADD_STEPS(l_process, 'PJI_PJI_HELPER', l_extraction_type);

    -- Kick off worker

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
    (
      PJI_RM_SUM_MAIN.g_process,
      l_process,
      FND_REQUEST.SUBMIT_REQUEST
      (
        PJI_UTILS.GET_PJI_SCHEMA_NAME,     -- Application name
        PJI_RM_SUM_MAIN.g_helper_name,     -- concurrent program name
        null,                              -- description (optional)
        null,                              -- Start Time  (optional)
        false,                             -- called from another conc. request
        p_worker_id                        -- first parameter
      )
    );

    if (nvl(to_number(PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                      (PJI_RM_SUM_MAIN.g_process, l_process)), 0) = 0) then
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

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    if (p_worker_id = 1) then

      if (l_extraction_type = 'FULL') then
        l_worker_name := PJI_RM_SUM_MAIN.g_full_disp_name;
      elsif (l_extraction_type = 'INCREMENTAL') then
        l_worker_name := PJI_RM_SUM_MAIN.g_incr_disp_name;
      elsif (l_extraction_type = 'PARTIAL') then
        l_worker_name := PJI_RM_SUM_MAIN.g_prtl_disp_name;
      end if;

      l_request_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                      (PJI_RM_SUM_MAIN.g_process,
                       PJI_RM_SUM_MAIN.g_process);

    else

      l_process := PJI_RM_SUM_MAIN.g_process || p_worker_id;

      l_worker_name := PJI_RM_SUM_MAIN.g_helper_name;

      l_request_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                      (PJI_RM_SUM_MAIN.g_process, l_process);

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

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    l_request_id :=
    PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      PJI_RM_SUM_MAIN.g_process,
      l_process
    );

    PJI_PROCESS_UTIL.WAIT_FOR_REQUEST(l_request_id,
                                      PJI_RM_SUM_MAIN.g_process_delay);

  end WAIT_FOR_WORKER;

end PJI_RM_SUM_EXTR;

/
