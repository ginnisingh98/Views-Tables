--------------------------------------------------------
--  DDL for Package Body PJI_RM_SUM_ROLLUP_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_RM_SUM_ROLLUP_RES" as
  /* $Header: PJISR03B.pls 120.4 2006/03/31 12:04:06 appldev noship $ */


  -- -----------------------------------------------------
  -- procedure JOB_NONUTIL2UTIL
  -- -----------------------------------------------------
  procedure JOB_NONUTIL2UTIL (p_worker_id in number) is

    l_process   varchar2(30);
    l_row_count number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
     'PJI_RM_SUM_ROLLUP_RES.JOB_NONUTIL2UTIL(p_worker_id);'
            )) then
      return;
    end if;

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_RM_SUM_MAIN.g_process,
                                              'EXTRACTION_TYPE') = 'FULL') then
      return;
    end if;

    -- implicit commit
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_RES_DELTA',
                                 percent => 10,
                                 degree  => BIS_COMMON_PARAMETERS.
                                            GET_DEGREE_OF_PARALLELISM);
    -- implicit commit
    FND_STATS.GATHER_COLUMN_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                  tabname => 'PJI_RES_DELTA',
                                  colname => 'CHANGE_TYPE',
                                  percent => 10,
                                  degree  => BIS_COMMON_PARAMETERS.
                                             GET_DEGREE_OF_PARALLELISM);
    -- implicit commit
    FND_STATS.GATHER_COLUMN_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                  tabname => 'PJI_RES_DELTA',
                                  colname => 'RESOURCE_ID',
                                  percent => 10,
                                  degree  => BIS_COMMON_PARAMETERS.
                                             GET_DEGREE_OF_PARALLELISM);
    -- implicit commit
    FND_STATS.GATHER_COLUMN_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                  tabname => 'PJI_RES_DELTA',
                                  colname => 'PERSON_ID',
                                  percent => 10,
                                  degree  => BIS_COMMON_PARAMETERS.
                                             GET_DEGREE_OF_PARALLELISM);

    select count(*)
    into   l_row_count
    from   PJI_RES_DELTA
    where  CHANGE_TYPE = 'Y';

    if (l_row_count > 0) then

      insert /*+ append parallel(fcst_i) */ into PJI_RM_REXT_FCSTITEM fcst_i
      (
        WORKER_ID,
        FID_ROWID,
        START_DATE,
        END_DATE,
        PJI_SUMMARIZED_FLAG,
        BATCH_ID
      )
      select /*+ ordered
                 full(delta)
                 full(fcst)   use_hash(fcst)
                 full(status) use_hash(status)
             */
        p_worker_id      WORKER_ID,
        fid.ROWID        FID_ROWID,
        delta.START_DATE,
        delta.END_DATE,
        fid.PJI_SUMMARIZED_FLAG,
        ceil(ROWNUM / PJI_RM_SUM_MAIN.g_commit_threshold)
      from
        PJI_RES_DELTA            delta,
        PA_FORECAST_ITEMS        fi,
        PA_FORECAST_ITEM_DETAILS fid,
        PJI_RM_REXT_FCSTITEM     fcst,
        PJI_ORG_EXTR_STATUS      status
      where
        delta.CHANGE_TYPE     = 'Y'                                       and
        fi.RESOURCE_ID        = delta.RESOURCE_ID                         and
        fi.FORECAST_ITEM_TYPE in ('U', 'A')                               and
        fi.ITEM_DATE          between delta.START_DATE and delta.END_DATE and
        fi.FORECAST_ITEM_ID   = fid.FORECAST_ITEM_ID                      and
        nvl(fid.pji_summarized_flag,'Y') <> 'N'                           and
        fi.EXPENDITURE_ORGANIZATION_ID   = status.ORGANIZATION_ID         and
        fcst.FID_ROWID (+)    = fid.ROWID                                 and
        fcst.WORKER_ID (+)    = p_worker_id                               and
        fcst.FID_ROWID        is null;

      insert /*+ append parallel(cdl_i) */ into PJI_FM_REXT_CDL cdl_i
      (
        WORKER_ID,
        CDL_ROWID,
        START_DATE,
        END_DATE,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PJI_SUMMARIZED_FLAG,
        BATCH_ID
      )
      select /*+ ordered
                 full(delta)
                 full(rcdl)      use_hash(rcdl)
                 full(status)    use_hash(status)
             */
        p_worker_id      WORKER_ID,
        cdl.ROWID        CDL_ROWID,
        delta.START_DATE,
        delta.END_DATE,
        -1               PROJECT_ORG_ID,
        -1               PROJECT_ORGANIZATION_ID,
        cdl.PJI_SUMMARIZED_FLAG,
        ceil(ROWNUM / PJI_RM_SUM_MAIN.g_commit_threshold)
      from
        PJI_RES_DELTA                  delta,
        PA_EXPENDITURES_ALL            exp,
        PA_EXPENDITURE_ITEMS_ALL       ei,
        PA_COST_DISTRIBUTION_LINES_ALL cdl,
        PJI_FM_REXT_CDL                rcdl,
        PJI_PROJ_EXTR_STATUS           status
      where
        delta.CHANGE_TYPE          = 'Y'                           and
        nvl(cdl.ORG_ID, -999)      = nvl(ei.ORG_ID, -999)          and
        nvl(exp.ORG_ID, -999)      = nvl(ei.ORG_ID, -999)          and
        ei.EXPENDITURE_ITEM_DATE   between delta.START_DATE and
                                           delta.END_DATE          and
        delta.PERSON_ID            = exp.INCURRED_BY_PERSON_ID     and
        exp.EXPENDITURE_ID         = ei.EXPENDITURE_ID             and
        ei.EXPENDITURE_ITEM_ID     = cdl.EXPENDITURE_ITEM_ID       and
        cdl.LINE_TYPE              = 'R'                           and
        nvl(cdl.PJI_SUMMARIZED_FLAG, 'Y') <> 'N'                   and
        cdl.PROJECT_ID             = status.PROJECT_ID             and
        rcdl.CDL_ROWID (+)         = cdl.ROWID                     and
        rcdl.WORKER_ID (+)         = p_worker_id                   and
        rcdl.CDL_ROWID             is null;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
     'PJI_RM_SUM_ROLLUP_RES.JOB_NONUTIL2UTIL(p_worker_id);'
    );

    commit;

  end JOB_NONUTIL2UTIL;


  -- -----------------------------------------------------
  -- procedure CALC_RMS_AVL_AND_WT
  -- -----------------------------------------------------
  procedure CALC_RMS_AVL_AND_WT (p_worker_id in number) is

    l_process          varchar2(30);
    l_extraction_type  varchar2(30);
    l_work_type_change varchar2(30);
    l_count            number;
    l_avl_bkt_1        number;
    l_avl_bkt_2        number;
    l_avl_bkt_3        number;
    l_avl_bkt_4        number;
    l_avl_bkt_5        number;

    l_missing_avl_setup exception;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
  'PJI_RM_SUM_ROLLUP_RES.CALC_RMS_AVL_AND_WT(p_worker_id);'
            )) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (PJI_RM_SUM_MAIN.g_process, 'EXTRACTION_TYPE');

    select count(*)
    into   l_count
    from   PJI_RM_WORK_TYPE_INFO
    where  RECORD_TYPE = 'CHANGE_OLD' or
           RECORD_TYPE = 'CHANGE_NEW';

    if (l_count > 0) then
      l_work_type_change := 'CHANGE_EXISTS';
    else
      l_work_type_change := 'NO_CHANGE';
    end if;

    --Initialize the availability bucket thresholds into variables
    --Each threshold corresponds to an availability definition
    begin

      select
        sum(case when bkt.SEQ = 1
                 then bkt.TO_VALUE
                 else null
                 end) ,
        sum(case when bkt.SEQ = 2
                 then bkt.TO_VALUE
                 else null
                 end) ,
        sum(case when bkt.SEQ = 3
                 then bkt.TO_VALUE
                 else null
                 end) ,
        sum(case when bkt.SEQ = 4
                 then bkt.TO_VALUE
                 else null
                 end) ,
        sum(case when bkt.SEQ = 5
                 then bkt.TO_VALUE
                 else null
                 end)
      into
        l_avl_bkt_1,
        l_avl_bkt_2,
        l_avl_bkt_3,
        l_avl_bkt_4,
        l_avl_bkt_5
      from
        PJI_MT_BUCKETS  bkt
      where
        bkt.BUCKET_SET_CODE  = 'PJI_RESOURCE_AVAILABILITY';

    exception
      when no_data_found then
        raise l_missing_avl_setup;
    end;

    insert /*+ append parallel(res2_i) */ into PJI_RM_AGGR_RES2 res2_i
    (
      WORKER_ID,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      JOB_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      GL_CALENDAR_ID,
      PA_CALENDAR_ID,
      CAPACITY_HRS,
      TOTAL_HRS_A,
      MISSING_HRS_A,
      TOTAL_WTD_ORG_HRS_A,
      TOTAL_WTD_RES_HRS_A,
      BILL_HRS_A,
      BILL_WTD_ORG_HRS_A,
      BILL_WTD_RES_HRS_A,
      TRAINING_HRS_A,
      REDUCIBLE_CAPACITY_HRS_A,
      REDUCE_CAPACITY_HRS_A,
      CONF_HRS_S,
      CONF_WTD_ORG_HRS_S,
      CONF_WTD_RES_HRS_S,
      CONF_BILL_HRS_S,
      CONF_BILL_WTD_ORG_HRS_S,
      CONF_BILL_WTD_RES_HRS_S,
      PROV_HRS_S,
      PROV_WTD_ORG_HRS_S,
      PROV_WTD_RES_HRS_S,
      PROV_BILL_HRS_S,
      PROV_BILL_WTD_ORG_HRS_S,
      PROV_BILL_WTD_RES_HRS_S,
      TRAINING_HRS_S,
      UNASSIGNED_HRS_S,
      REDUCIBLE_CAPACITY_HRS_S,
      REDUCE_CAPACITY_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S,
      AVAILABLE_HRS_BKT1_S,
      AVAILABLE_HRS_BKT2_S,
      AVAILABLE_HRS_BKT3_S,
      AVAILABLE_HRS_BKT4_S,
      AVAILABLE_HRS_BKT5_S,
      AVAILABLE_RES_COUNT_BKT1_S,
      AVAILABLE_RES_COUNT_BKT2_S,
      AVAILABLE_RES_COUNT_BKT3_S,
      AVAILABLE_RES_COUNT_BKT4_S,
      AVAILABLE_RES_COUNT_BKT5_S,
      TOTAL_RES_COUNT
    )
    select
      p_worker_id                                   WORKER_ID,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.JOB_ID,
      tmp1.TIME_ID,
      tmp1.PERIOD_TYPE_ID,
      tmp1.CALENDAR_TYPE,
      tmp1.GL_CALENDAR_ID,
      tmp1.PA_CALENDAR_ID,
      sum(tmp1.CAPACITY_HRS),
      sum(tmp1.TOTAL_HRS_A),
      sum(greatest(nvl(tmp1.CAPACITY_HRS,0) + nvl(rms.CAPACITY_HRS, 0) -
                   (nvl(tmp1.TOTAL_HRS_A,0) + nvl(rms.TOTAL_HRS_A, 0)), 0) -
          nvl(rms.MISSING_HRS_A, 0))                MISSING_HRS_A,
      sum(tmp1.TOTAL_WTD_ORG_HRS_A),
      sum(tmp1.TOTAL_WTD_RES_HRS_A),
      sum(tmp1.BILL_HRS_A),
      sum(tmp1.BILL_WTD_ORG_HRS_A),
      sum(tmp1.BILL_WTD_RES_HRS_A),
      sum(tmp1.TRAINING_HRS_A),
      sum(tmp1.REDUCE_CAPACITY_HRS_A)               REDUCIBLE_CAPACITY_HRS_A,
      sum(least(nvl(tmp1.CAPACITY_HRS, 0) + nvl(rms.CAPACITY_HRS, 0),
                nvl(tmp1.REDUCE_CAPACITY_HRS_A, 0) +
                nvl(rms.REDUCIBLE_CAPACITY_HRS_A, 0)) -
          nvl(rms.REDUCE_CAPACITY_HRS_A, 0))        REDUCE_CAPACITY_HRS_A,
      sum(tmp1.CONF_HRS_S),
      sum(tmp1.CONF_WTD_ORG_HRS_S),
      sum(tmp1.CONF_WTD_RES_HRS_S),
      sum(tmp1.CONF_BILL_HRS_S),
      sum(tmp1.CONF_BILL_WTD_ORG_HRS_S),
      sum(tmp1.CONF_BILL_WTD_RES_HRS_S),
      sum(tmp1.PROV_HRS_S),
      sum(tmp1.PROV_WTD_ORG_HRS_S),
      sum(tmp1.PROV_WTD_RES_HRS_S),
      sum(tmp1.PROV_BILL_HRS_S),
      sum(tmp1.PROV_BILL_WTD_ORG_HRS_S),
      sum(tmp1.PROV_BILL_WTD_RES_HRS_S),
      sum(tmp1.TRAINING_HRS_S),
      sum(tmp1.UNASSIGNED_HRS_S),
      sum(tmp1.REDUCE_CAPACITY_HRS_S)               REDUCIBLE_CAPACITY_HRS_S,
      sum(least(nvl(tmp1.CAPACITY_HRS, 0) + nvl(rms.CAPACITY_HRS, 0),
                nvl(tmp1.REDUCE_CAPACITY_HRS_S, 0) +
                nvl(rms.REDUCIBLE_CAPACITY_HRS_S, 0)) -
          nvl(rms.REDUCE_CAPACITY_HRS_S, 0))        REDUCE_CAPACITY_HRS_S,
      sum(tmp1.CONF_OVERCOM_HRS_S),
      sum(tmp1.PROV_OVERCOM_HRS_S),
      sum(case when l_avl_bkt_1 is not null and
                    nvl(rms.CONF_HRS_S, 0) + nvl(tmp1.CONF_HRS_S, 0) <=
                    ((nvl(rms.CAPACITY_HRS, 0) + nvl(tmp1.CAPACITY_HRS, 0)) *
                    ((100-l_avl_bkt_1)/100))
               then - nvl(tmp1.CONF_HRS_S, 0) + nvl(tmp1.CAPACITY_HRS, 0)
               else - nvl(rms.AVAILABLE_HRS_BKT1_S, 0)
               end)                                 AVAILABLE_HRS_BKT1_S,
      sum(case when l_avl_bkt_2 is not null and
                    nvl(rms.CONF_HRS_S, 0) + nvl(tmp1.CONF_HRS_S, 0) <=
                    ((nvl(rms.CAPACITY_HRS, 0) + nvl(tmp1.CAPACITY_HRS, 0)) *
                    ((100-l_avl_bkt_2)/100))
               then - nvl(tmp1.CONF_HRS_S, 0) + nvl(tmp1.CAPACITY_HRS, 0)
               else - nvl(rms.AVAILABLE_HRS_BKT2_S, 0)
               end)                                 AVAILABLE_HRS_BKT2_S,
      sum(case when l_avl_bkt_3 is not null and
                    nvl(rms.CONF_HRS_S, 0) + nvl(tmp1.CONF_HRS_S, 0) <=
                    ((nvl(rms.CAPACITY_HRS, 0) + nvl(tmp1.CAPACITY_HRS, 0)) *
                    ((100-l_avl_bkt_3)/100))
               then - nvl(tmp1.CONF_HRS_S, 0) + nvl(tmp1.CAPACITY_HRS, 0)
               else - nvl(rms.AVAILABLE_HRS_BKT3_S, 0)
               end)                                 AVAILABLE_HRS_BKT3_S,
      sum(case when l_avl_bkt_4 is not null and
                    nvl(rms.CONF_HRS_S, 0) + nvl(tmp1.CONF_HRS_S, 0) <=
                    ((nvl(rms.CAPACITY_HRS, 0) + nvl(tmp1.CAPACITY_HRS, 0)) *
                    ((100-l_avl_bkt_4)/100))
               then - nvl(tmp1.CONF_HRS_S, 0) + nvl(tmp1.CAPACITY_HRS, 0)
               else - nvl(rms.AVAILABLE_HRS_BKT4_S, 0)
               end)                                 AVAILABLE_HRS_BKT4_S,
      sum(case when l_avl_bkt_5 is not null and
                    nvl(rms.CONF_HRS_S, 0) + nvl(tmp1.CONF_HRS_S, 0) <=
                    ((nvl(rms.CAPACITY_HRS, 0) + nvl(tmp1.CAPACITY_HRS, 0)) *
                    ((100-l_avl_bkt_5)/100))
               then - nvl(tmp1.CONF_HRS_S, 0) + nvl(tmp1.CAPACITY_HRS, 0)
               else - nvl(rms.AVAILABLE_HRS_BKT5_S, 0)
               end)                                 AVAILABLE_HRS_BKT5_S,
      sum(case when l_avl_bkt_1 is not null and
                    nvl(rms.CONF_HRS_S, 0) + nvl(tmp1.CONF_HRS_S, 0) <=
                    ((nvl(rms.CAPACITY_HRS, 0) + nvl(tmp1.CAPACITY_HRS, 0)) *
                    ((100-l_avl_bkt_1)/100))
               then 1 - nvl(rms.AVAILABLE_RES_COUNT_BKT1_S, 0)
               else - nvl(rms.AVAILABLE_RES_COUNT_BKT1_S, 0)
               end)                                 AVAILABLE_RES_COUNT_BKT1_S,
      sum(case when l_avl_bkt_2 is not null and
                    nvl(rms.CONF_HRS_S, 0) + nvl(tmp1.CONF_HRS_S, 0) <=
                    ((nvl(rms.CAPACITY_HRS, 0) + nvl(tmp1.CAPACITY_HRS, 0)) *
                    ((100-l_avl_bkt_2)/100))
               then 1 - nvl(rms.AVAILABLE_RES_COUNT_BKT2_S, 0)
               else - nvl(rms.AVAILABLE_RES_COUNT_BKT2_S, 0)
               end)                                 AVAILABLE_RES_COUNT_BKT2_S,
      sum(case when l_avl_bkt_3 is not null and
                    nvl(rms.CONF_HRS_S, 0) + nvl(tmp1.CONF_HRS_S, 0) <=
                    ((nvl(rms.CAPACITY_HRS, 0) + nvl(tmp1.CAPACITY_HRS, 0)) *
                    ((100-l_avl_bkt_3)/100))
               then 1 - nvl(rms.AVAILABLE_RES_COUNT_BKT3_S, 0)
               else - nvl(rms.AVAILABLE_RES_COUNT_BKT3_S, 0)
               end)                                 AVAILABLE_RES_COUNT_BKT3_S,
      sum(case when l_avl_bkt_4 is not null and
                    nvl(rms.CONF_HRS_S, 0) + nvl(tmp1.CONF_HRS_S, 0) <=
                    ((nvl(rms.CAPACITY_HRS, 0) + nvl(tmp1.CAPACITY_HRS, 0)) *
                    ((100-l_avl_bkt_4)/100))
               then 1 - nvl(rms.AVAILABLE_RES_COUNT_BKT4_S, 0)
               else - nvl(rms.AVAILABLE_RES_COUNT_BKT4_S, 0)
               end)                                 AVAILABLE_RES_COUNT_BKT4_S,
      sum(case when l_avl_bkt_5 is not null and
                    nvl(rms.CONF_HRS_S, 0) + nvl(tmp1.CONF_HRS_S, 0) <=
                    ((nvl(rms.CAPACITY_HRS, 0) + nvl(tmp1.CAPACITY_HRS, 0)) *
                    ((100-l_avl_bkt_5)/100))
               then 1 - nvl(rms.AVAILABLE_RES_COUNT_BKT5_S, 0)
               else - nvl(rms.AVAILABLE_RES_COUNT_BKT5_S, 0)
               end)                                 AVAILABLE_RES_COUNT_BKT5_S,
      sum(case when tmp1.CAPACITY_HRS < 0 and
                    (tmp1.CAPACITY_HRS + nvl(rms.CAPACITY_HRS, 0)) = 0
               then -1
               when tmp1.CAPACITY_HRS > 0 and
                    nvl(rms.CAPACITY_HRS, 0) = 0
               then 1
               else 0
               end) TOTAL_RES_COUNT
    from
      (
      select
        PERSON_ID,
        EXPENDITURE_ORG_ID,
        EXPENDITURE_ORGANIZATION_ID,
        JOB_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        GL_CALENDAR_ID,
        PA_CALENDAR_ID,
        sum(CAPACITY_HRS)            CAPACITY_HRS,
        sum(TOTAL_HRS_A)             TOTAL_HRS_A,
        sum(TOTAL_WTD_ORG_HRS_A)     TOTAL_WTD_ORG_HRS_A,
        sum(TOTAL_WTD_RES_HRS_A)     TOTAL_WTD_RES_HRS_A,
        sum(BILL_HRS_A)              BILL_HRS_A,
        sum(BILL_WTD_ORG_HRS_A)      BILL_WTD_ORG_HRS_A,
        sum(BILL_WTD_RES_HRS_A)      BILL_WTD_RES_HRS_A,
        sum(TRAINING_HRS_A)          TRAINING_HRS_A,
        sum(REDUCE_CAPACITY_HRS_A)   REDUCE_CAPACITY_HRS_A,
        sum(CONF_HRS_S)              CONF_HRS_S,
        sum(CONF_WTD_ORG_HRS_S)      CONF_WTD_ORG_HRS_S,
        sum(CONF_WTD_RES_HRS_S)      CONF_WTD_RES_HRS_S,
        sum(CONF_BILL_HRS_S)         CONF_BILL_HRS_S,
        sum(CONF_BILL_WTD_ORG_HRS_S) CONF_BILL_WTD_ORG_HRS_S,
        sum(CONF_BILL_WTD_RES_HRS_S) CONF_BILL_WTD_RES_HRS_S,
        sum(PROV_HRS_S)              PROV_HRS_S,
        sum(PROV_WTD_ORG_HRS_S)      PROV_WTD_ORG_HRS_S,
        sum(PROV_WTD_RES_HRS_S)      PROV_WTD_RES_HRS_S,
        sum(PROV_BILL_HRS_S)         PROV_BILL_HRS_S,
        sum(PROV_BILL_WTD_ORG_HRS_S) PROV_BILL_WTD_ORG_HRS_S,
        sum(PROV_BILL_WTD_RES_HRS_S) PROV_BILL_WTD_RES_HRS_S,
        sum(TRAINING_HRS_S)          TRAINING_HRS_S,
        sum(UNASSIGNED_HRS_S)        UNASSIGNED_HRS_S,
        sum(REDUCE_CAPACITY_HRS_S)   REDUCE_CAPACITY_HRS_S,
        sum(CONF_OVERCOM_HRS_S)      CONF_OVERCOM_HRS_S,
        sum(PROV_OVERCOM_HRS_S)      PROV_OVERCOM_HRS_S
      from
      (
        select /*+ ordered
                   full(wt)   use_hash(wt)   swap_join_inputs(wt)
                   full(tmp1) use_hash(tmp1) parallel(tmp1) */
          tmp1.PERSON_ID,
          tmp1.EXPENDITURE_ORG_ID,
          tmp1.EXPENDITURE_ORGANIZATION_ID,
          tmp1.JOB_ID,
          tmp1.TIME_ID,
          tmp1.PERIOD_TYPE_ID,
          tmp1.CALENDAR_TYPE,
          tmp1.GL_CALENDAR_ID,
          tmp1.PA_CALENDAR_ID,
          tmp1.CAPACITY_HRS                            CAPACITY_HRS,
          tmp1.TOTAL_HRS_A                             TOTAL_HRS_A,
          tmp1.TOTAL_HRS_A
            * wt.ORG_UTILIZATION_PERCENTAGE / 100      TOTAL_WTD_ORG_HRS_A,
          tmp1.TOTAL_HRS_A
            * wt.RES_UTILIZATION_PERCENTAGE / 100      TOTAL_WTD_RES_HRS_A,
          tmp1.BILL_HRS_A                              BILL_HRS_A,
          tmp1.BILL_HRS_A
            * wt.ORG_UTILIZATION_PERCENTAGE / 100      BILL_WTD_ORG_HRS_A,
          tmp1.BILL_HRS_A
            * wt.RES_UTILIZATION_PERCENTAGE / 100      BILL_WTD_RES_HRS_A,
          decode(wt.TRAINING_FLAG,
                 'Y', tmp1.TOTAL_HRS_A, 0)             TRAINING_HRS_A,
          decode(wt.REDUCE_CAPACITY_FLAG,
                 'Y', tmp1.TOTAL_HRS_A, 0)             REDUCE_CAPACITY_HRS_A,
          tmp1.CONF_HRS_S                              CONF_HRS_S,
          tmp1.CONF_HRS_S
            * wt.ORG_UTILIZATION_PERCENTAGE / 100      CONF_WTD_ORG_HRS_S,
          tmp1.CONF_HRS_S
            * wt.RES_UTILIZATION_PERCENTAGE / 100      CONF_WTD_RES_HRS_S,
          decode(wt.BILLABLE_CAPITALIZABLE_FLAG,
                 'Y', tmp1.CONF_HRS_S, 0)              CONF_BILL_HRS_S,
          decode(wt.BILLABLE_CAPITALIZABLE_FLAG,
                 'Y', tmp1.CONF_HRS_S
                      * wt.ORG_UTILIZATION_PERCENTAGE
                      / 100, 0)                        CONF_BILL_WTD_ORG_HRS_S,
          decode(wt.BILLABLE_CAPITALIZABLE_FLAG,
                 'Y', tmp1.CONF_HRS_S
                      * wt.RES_UTILIZATION_PERCENTAGE
                      / 100, 0)                        CONF_BILL_WTD_RES_HRS_S,
          tmp1.PROV_HRS_S                              PROV_HRS_S,
          tmp1.PROV_HRS_S
            * wt.ORG_UTILIZATION_PERCENTAGE / 100      PROV_WTD_ORG_HRS_S,
          tmp1.PROV_HRS_S
            * wt.RES_UTILIZATION_PERCENTAGE / 100      PROV_WTD_RES_HRS_S,
          decode(wt.BILLABLE_CAPITALIZABLE_FLAG,
                 'Y', tmp1.PROV_HRS_S, 0)              PROV_BILL_HRS_S,
          decode(wt.BILLABLE_CAPITALIZABLE_FLAG,
                 'Y', tmp1.PROV_HRS_S
                      * wt.ORG_UTILIZATION_PERCENTAGE
                      / 100, 0)                        PROV_BILL_WTD_ORG_HRS_S,
          decode(wt.BILLABLE_CAPITALIZABLE_FLAG,
                 'Y', tmp1.PROV_HRS_S
                      * wt.RES_UTILIZATION_PERCENTAGE
                      / 100, 0)                        PROV_BILL_WTD_RES_HRS_S,
          decode(wt.TRAINING_FLAG,
                 'Y', tmp1.CONF_HRS_S, 0)              TRAINING_HRS_S,
          tmp1.UNASSIGNED_HRS_S                        UNASSIGNED_HRS_S,
          decode(wt.REDUCE_CAPACITY_FLAG,
                 'Y', tmp1.CONF_HRS_S, 0)              REDUCE_CAPACITY_HRS_S,
          tmp1.CONF_OVERCOM_HRS_S                      CONF_OVERCOM_HRS_S,
          tmp1.PROV_OVERCOM_HRS_S                      PROV_OVERCOM_HRS_S
        from
          PJI_RM_WORK_TYPE_INFO wt,
          PJI_RM_AGGR_RES1      tmp1
        where
          tmp1.WORKER_ID    = p_worker_id         and
          tmp1.RECORD_TYPE <> 'N'                 and
          'NORMAL'          = wt.RECORD_TYPE  (+) and
          tmp1.WORK_TYPE_ID = wt.WORK_TYPE_ID (+)
        union all
        select /*+ ordered
                   full(wt_old)   use_hash(wt_old)
                   full(wt_new)   use_hash(wt_new)
                   parallel(rmr)
                   full(info)     use_hash(info) */    -- work type corrections
          rmr.PERSON_ID,
          rmr.EXPENDITURE_ORG_ID,
          rmr.EXPENDITURE_ORGANIZATION_ID,
          rmr.JOB_ID,
          rmr.TIME_ID,
          rmr.PERIOD_TYPE_ID,
          rmr.CALENDAR_TYPE,
          info.GL_CALENDAR_ID,
          info.PA_CALENDAR_ID,
          0                                            CAPACITY_HRS,
          0                                            TOTAL_HRS_A,
          rmr.TOTAL_HRS_A
            * (wt_new.ORG_UTILIZATION_PERCENTAGE -
               wt_old.ORG_UTILIZATION_PERCENTAGE)
            / 100                                      TOTAL_WTD_ORG_HRS_A,
          rmr.TOTAL_HRS_A
            * (wt_new.RES_UTILIZATION_PERCENTAGE -
               wt_old.RES_UTILIZATION_PERCENTAGE)
            / 100                                      TOTAL_WTD_RES_HRS_A,
          0                                            BILL_HRS_A,
          rmr.BILL_HRS_A
            * (wt_new.ORG_UTILIZATION_PERCENTAGE -
               wt_old.ORG_UTILIZATION_PERCENTAGE)
            / 100                                      BILL_WTD_ORG_HRS_A,
          rmr.BILL_HRS_A
            * (wt_new.RES_UTILIZATION_PERCENTAGE -
               wt_old.RES_UTILIZATION_PERCENTAGE)
            / 100                                      BILL_WTD_RES_HRS_A,
          case when nvl(wt_old.TRAINING_FLAG, 'N') = 'N' and
                    nvl(wt_new.TRAINING_FLAG, 'N') = 'Y'
               then rmr.TOTAL_HRS_A
               when nvl(wt_old.TRAINING_FLAG, 'N') = 'Y' and
                    nvl(wt_new.TRAINING_FLAG, 'N') = 'N'
               then -rmr.TOTAL_HRS_A
               else 0
               end                                     TRAINING_HRS_A,
          case when nvl(wt_old.REDUCE_CAPACITY_FLAG, 'N') = 'N' and
                    nvl(wt_new.REDUCE_CAPACITY_FLAG, 'N') = 'Y'
               then rmr.TOTAL_HRS_A
               when nvl(wt_old.REDUCE_CAPACITY_FLAG, 'N') = 'Y' and
                    nvl(wt_new.REDUCE_CAPACITY_FLAG, 'N') = 'N'
               then -rmr.TOTAL_HRS_A
               else 0
               end                                     REDUCE_CAPACITY_HRS_A,
          0                                            CONF_HRS_S,
          rmr.CONF_HRS_S
            * (wt_new.ORG_UTILIZATION_PERCENTAGE -
               wt_old.ORG_UTILIZATION_PERCENTAGE)
            / 100                                      CONF_WTD_ORG_HRS_S,
          rmr.CONF_HRS_S
            * (wt_new.RES_UTILIZATION_PERCENTAGE -
               wt_old.RES_UTILIZATION_PERCENTAGE)
            / 100                                      CONF_WTD_RES_HRS_S,
          case when nvl(wt_old.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'N' and
                    nvl(wt_new.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'Y'
               then rmr.CONF_HRS_S
               when nvl(wt_old.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'Y' and
                    nvl(wt_new.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'N'
               then -rmr.CONF_HRS_S
               else 0
               end                                     CONF_BILL_HRS_S,
          case when nvl(wt_old.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'N' and
                    nvl(wt_new.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'Y'
               then rmr.CONF_HRS_S * wt_new.ORG_UTILIZATION_PERCENTAGE / 100
               when nvl(wt_old.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'Y' and
                    nvl(wt_new.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'N'
               then -rmr.CONF_HRS_S * wt_old.ORG_UTILIZATION_PERCENTAGE / 100
               else 0
               end                                     CONF_BILL_WTD_ORG_HRS_S,
          case when nvl(wt_old.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'N' and
                    nvl(wt_new.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'Y'
               then rmr.CONF_HRS_S * wt_new.RES_UTILIZATION_PERCENTAGE / 100
               when nvl(wt_old.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'Y' and
                    nvl(wt_new.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'N'
               then -rmr.CONF_HRS_S * wt_old.RES_UTILIZATION_PERCENTAGE / 100
               else 0
               end                                     CONF_BILL_WTD_RES_HRS_S,
          0                                            PROV_HRS_S,
          rmr.PROV_HRS_S
            * (wt_new.ORG_UTILIZATION_PERCENTAGE -
               wt_old.ORG_UTILIZATION_PERCENTAGE)
            / 100                                      PROV_WTD_ORG_HRS_S,
          rmr.PROV_HRS_S
            * (wt_new.RES_UTILIZATION_PERCENTAGE -
               wt_old.RES_UTILIZATION_PERCENTAGE)
            / 100                                      PROV_WTD_RES_HRS_S,
          case when nvl(wt_old.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'N' and
                    nvl(wt_new.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'Y'
               then rmr.PROV_HRS_S
               when nvl(wt_old.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'Y' and
                    nvl(wt_new.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'N'
               then -rmr.PROV_HRS_S
               else 0
               end                                     PROV_BILL_HRS_S,
          case when nvl(wt_old.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'N' and
                    nvl(wt_new.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'Y'
               then rmr.PROV_HRS_S * wt_new.ORG_UTILIZATION_PERCENTAGE / 100
               when nvl(wt_old.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'Y' and
                    nvl(wt_new.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'N'
               then -rmr.PROV_HRS_S * wt_old.ORG_UTILIZATION_PERCENTAGE / 100
               else 0
               end                                     PROV_BILL_WTD_ORG_HRS_S,
          case when nvl(wt_old.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'N' and
                    nvl(wt_new.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'Y'
               then rmr.PROV_HRS_S * wt_new.RES_UTILIZATION_PERCENTAGE / 100
               when nvl(wt_old.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'Y' and
                    nvl(wt_new.BILLABLE_CAPITALIZABLE_FLAG, 'N') = 'N'
               then -rmr.PROV_HRS_S * wt_old.RES_UTILIZATION_PERCENTAGE / 100
               else 0
               end                                     PROV_BILL_WTD_RES_HRS_S,
          case when nvl(wt_old.TRAINING_FLAG, 'N') = 'N' and
                    nvl(wt_new.TRAINING_FLAG, 'N') = 'Y'
               then rmr.CONF_HRS_S
               when nvl(wt_old.TRAINING_FLAG, 'N') = 'Y' and
                    nvl(wt_new.TRAINING_FLAG, 'N') = 'N'
               then -rmr.CONF_HRS_S
               else 0
               end                                     TRAINING_HRS_S,
          0                                            UNASSIGNED_HRS_S,
          case when nvl(wt_old.REDUCE_CAPACITY_FLAG, 'N') = 'N' and
                    nvl(wt_new.REDUCE_CAPACITY_FLAG, 'N') = 'Y'
               then rmr.CONF_HRS_S
               when nvl(wt_old.REDUCE_CAPACITY_FLAG, 'N') = 'Y' and
                    nvl(wt_new.REDUCE_CAPACITY_FLAG, 'N') = 'N'
               then -rmr.CONF_HRS_S
               else 0
               end                                     REDUCE_CAPACITY_HRS_S,
          0                                            CONF_OVERCOM_HRS_S,
          0                                            PROV_OVERCOM_HRS_S
        from
          PJI_RM_WORK_TYPE_INFO wt_old,
          PJI_RM_WORK_TYPE_INFO wt_new,
          PJI_RM_RES_WT_F       rmr,
          PJI_ORG_EXTR_INFO     info
        where
          l_extraction_type          = 'INCREMENTAL'                        and
          l_work_type_change         = 'CHANGE_EXISTS'                      and
          wt_old.RECORD_TYPE         = 'CHANGE_OLD'                         and
          wt_new.RECORD_TYPE         = 'CHANGE_NEW'                         and
          wt_old.WORK_TYPE_ID        = wt_new.WORK_TYPE_ID                  and
          rmr.CALENDAR_TYPE          = 'C'                                  and
          rmr.PERIOD_TYPE_ID         = 1                                    and
          wt_new.WORK_TYPE_ID        = rmr.WORK_TYPE_ID                     and
          (rmr.PROJECT_ID in
           (select /*+ full(map1) */
                   PROJECT_ID
            from   PJI_PJI_PROJ_BATCH_MAP map1
            where  WORKER_ID = p_worker_id) or
           rmr.EXPENDITURE_ORGANIZATION_ID in
           (select /*+ full(map2) */
                   ORGANIZATION_ID
            from   PJI_RM_ORG_BATCH_MAP map2
            where  WORKER_ID = p_worker_id))                                and
          rmr.EXPENDITURE_ORG_ID = info.ORG_ID
        )
      group by
        PERSON_ID,
        EXPENDITURE_ORG_ID,
        EXPENDITURE_ORGANIZATION_ID,
        JOB_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        GL_CALENDAR_ID,
        PA_CALENDAR_ID
      ) tmp1,
      PJI_RM_RES_F rms
    where
      tmp1.PERSON_ID                   = rms.PERSON_ID                  (+) and
      tmp1.EXPENDITURE_ORG_ID          = rms.EXPENDITURE_ORG_ID         (+) and
      tmp1.EXPENDITURE_ORGANIZATION_ID = rms.EXPENDITURE_ORGANIZATION_ID(+) and
      tmp1.TIME_ID                     = rms.TIME_ID                    (+) and
      tmp1.PERIOD_TYPE_ID              = rms.PERIOD_TYPE_ID             (+) and
      tmp1.CALENDAR_TYPE               = rms.CALENDAR_TYPE              (+)
    group by
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.JOB_ID,
      tmp1.TIME_ID,
      tmp1.PERIOD_TYPE_ID,
      tmp1.CALENDAR_TYPE,
      tmp1.GL_CALENDAR_ID,
      tmp1.PA_CALENDAR_ID;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
  'PJI_RM_SUM_ROLLUP_RES.CALC_RMS_AVL_AND_WT(p_worker_id);'
    );

    commit;

  end CALC_RMS_AVL_AND_WT;


  -- -----------------------------------------------------
  -- procedure EXPAND_RMR_CAL_EN
  -- -----------------------------------------------------
  procedure EXPAND_RMR_CAL_EN (p_worker_id in number) is

    l_process   varchar2(30);
    l_row_count number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMR_CAL_EN(p_worker_id);'
            )) then
      return;
    end if;

    insert /*+ append parallel(res1_i) */ into PJI_RM_AGGR_RES1 res1_i
    (
      WORKER_ID,
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
      CAPACITY_HRS,
      TOTAL_HRS_A,
      BILL_HRS_A,
      CONF_HRS_S,
      PROV_HRS_S,
      UNASSIGNED_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S
    )
    select /*+ ordered
               full(time) use_hash(time) swap_join_inputs(time)
               full(tmp1) use_hash(tmp1) parallel(tmp1) */
      p_worker_id,
      tmp1.RECORD_TYPE,
      -1,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
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
           end                                TIME_ID,
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
           end                                PERIOD_TYPE_ID,
      'E'                                     CALENDAR_TYPE,
      sum(tmp1.CAPACITY_HRS)                  CAPACITY_HRS,
      sum(tmp1.TOTAL_HRS_A)                   TOTAL_HRS_A,
      sum(tmp1.BILL_HRS_A)                    BILL_HRS_A,
      sum(tmp1.CONF_HRS_S)                    CONF_HRS_S,
      sum(tmp1.PROV_HRS_S)                    PROV_HRS_S,
      sum(tmp1.UNASSIGNED_HRS_S)              UNASSIGNED_HRS_S,
      sum(tmp1.CONF_OVERCOM_HRS_S)            CONF_OVERCOM_HRS_S,
      sum(tmp1.PROV_OVERCOM_HRS_S)            PROV_OVERCOM_HRS_S
    from
      FII_TIME_DAY     time,
      PJI_RM_AGGR_RES1 tmp1
    where
      tmp1.WORKER_ID      = p_worker_id and
      tmp1.RECORD_TYPE   <> 'N'         and
      tmp1.PERIOD_TYPE_ID = 1           and
      tmp1.CALENDAR_TYPE  = 'C'         and
      tmp1.TIME_ID        = time.REPORT_DATE_JULIAN
    group by
      tmp1.RECORD_TYPE,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
      rollup (time.ENT_YEAR_ID,
              time.ENT_QTR_ID,
              time.ENT_PERIOD_ID)
    having
      not (grouping(time.ENT_YEAR_ID)   = 1 and
           grouping(time.ENT_QTR_ID)    = 1 and
           grouping(time.ENT_PERIOD_ID) = 1);

    l_row_count := sql%rowcount;

    l_row_count := l_row_count + PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT'
    );

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT',
      l_row_count
    );

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMR_CAL_EN(p_worker_id);'
    );

    commit;

  end EXPAND_RMR_CAL_EN;


  -- -----------------------------------------------------
  -- procedure EXPAND_RMR_CAL_PA
  -- -----------------------------------------------------
  procedure EXPAND_RMR_CAL_PA (p_worker_id in number) is

    l_process   varchar2(30);
    l_row_count number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
        (
          l_process,
          'PA_CALENDAR_FLAG'
        ) = 'N') then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMR_CAL_PA(p_worker_id);'
            )) then
      return;
    end if;

    insert /*+ append parallel(res1_i) */ into PJI_RM_AGGR_RES1 res1_i
    (
      WORKER_ID,
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
      CAPACITY_HRS,
      TOTAL_HRS_A,
      BILL_HRS_A,
      CONF_HRS_S,
      PROV_HRS_S,
      UNASSIGNED_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S
    )
    select /*+ ordered
               full(time) use_hash(time) parallel(time) swap_join_inputs(time)
               full(tmp1) use_hash(tmp1) parallel(tmp1) */
      p_worker_id,
      tmp1.RECORD_TYPE,
      -1,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
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
           end                                TIME_ID,
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
           end                                PERIOD_TYPE_ID,
      'P'                                     CALENDAR_TYPE,
      sum(tmp1.CAPACITY_HRS)                  CAPACITY_HRS,
      sum(tmp1.TOTAL_HRS_A)                   TOTAL_HRS_A,
      sum(tmp1.BILL_HRS_A)                    BILL_HRS_A,
      sum(tmp1.CONF_HRS_S)                    CONF_HRS_S,
      sum(tmp1.PROV_HRS_S)                    PROV_HRS_S,
      sum(tmp1.UNASSIGNED_HRS_S)              UNASSIGNED_HRS_S,
      sum(tmp1.CONF_OVERCOM_HRS_S)            CONF_OVERCOM_HRS_S,
      sum(tmp1.PROV_OVERCOM_HRS_S)            PROV_OVERCOM_HRS_S
    from
      FII_TIME_CAL_DAY_MV time,
      PJI_RM_AGGR_RES1    tmp1
    where
      tmp1.WORKER_ID                      = p_worker_id      and
      tmp1.RECORD_TYPE                   <> 'N'              and
      tmp1.PERIOD_TYPE_ID                 = 1                and
      tmp1.CALENDAR_TYPE                  = 'C'              and
      to_date(to_char(tmp1.TIME_ID), 'J') = time.REPORT_DATE and
      tmp1.PA_CALENDAR_ID                 = time.CALENDAR_ID
    group by
      tmp1.RECORD_TYPE,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
      rollup (time.CAL_YEAR_ID,
              time.CAL_QTR_ID,
              time.CAL_PERIOD_ID)
    having
      not (grouping(time.CAL_YEAR_ID)   = 1 and
           grouping(time.CAL_QTR_ID)    = 1 and
           grouping(time.CAL_PERIOD_ID) = 1);

    l_row_count := sql%rowcount;

    l_row_count := l_row_count + PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT'
    );

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT',
      l_row_count
    );

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMR_CAL_PA(p_worker_id);'
    );

    commit;

  end EXPAND_RMR_CAL_PA;


  -- -----------------------------------------------------
  -- procedure EXPAND_RMR_CAL_GL
  -- -----------------------------------------------------
  procedure EXPAND_RMR_CAL_GL (p_worker_id in number) is

    l_process   varchar2(30);
    l_row_count number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
        (
          l_process,
          'GL_CALENDAR_FLAG'
        ) = 'N') then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMR_CAL_GL(p_worker_id);'
            )) then
      return;
    end if;

    insert /*+ append parallel(res1_i) */ into PJI_RM_AGGR_RES1 res1_i
    (
      WORKER_ID,
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
      CAPACITY_HRS,
      TOTAL_HRS_A,
      BILL_HRS_A,
      CONF_HRS_S,
      PROV_HRS_S,
      UNASSIGNED_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S
    )
    select /*+ ordered
               full(time) use_hash(time) parallel(time) swap_join_inputs(time)
               full(tmp1) use_hash(tmp1) parallel(tmp1) */
      p_worker_id,
      tmp1.RECORD_TYPE,
      -1,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
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
           end                                TIME_ID,
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
           end                                PERIOD_TYPE_ID,
      'G'                                     CALENDAR_TYPE,
      sum(tmp1.CAPACITY_HRS)                  CAPACITY_HRS,
      sum(tmp1.TOTAL_HRS_A)                   TOTAL_HRS_A,
      sum(tmp1.BILL_HRS_A)                    BILL_HRS_A,
      sum(tmp1.CONF_HRS_S)                    CONF_HRS_S,
      sum(tmp1.PROV_HRS_S)                    PROV_HRS_S,
      sum(tmp1.UNASSIGNED_HRS_S)              UNASSIGNED_HRS_S,
      sum(tmp1.CONF_OVERCOM_HRS_S)            CONF_OVERCOM_HRS_S,
      sum(tmp1.PROV_OVERCOM_HRS_S)            PROV_OVERCOM_HRS_S
    from
      FII_TIME_CAL_DAY_MV time,
      PJI_RM_AGGR_RES1    tmp1
    where
      tmp1.WORKER_ID                      = p_worker_id      and
      tmp1.RECORD_TYPE                   <> 'N'              and
      tmp1.PERIOD_TYPE_ID                 = 1                and
      tmp1.CALENDAR_TYPE                  = 'C'              and
      to_date(to_char(tmp1.TIME_ID), 'J') = time.REPORT_DATE and
      tmp1.GL_CALENDAR_ID                 = time.CALENDAR_ID
    group by
      tmp1.RECORD_TYPE,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
      rollup (time.CAL_YEAR_ID,
              time.CAL_QTR_ID,
              time.CAL_PERIOD_ID)
    having
      not (grouping(time.CAL_YEAR_ID)   = 1 and
           grouping(time.CAL_QTR_ID)    = 1 and
           grouping(time.CAL_PERIOD_ID) = 1);

    l_row_count := sql%rowcount;

    l_row_count := l_row_count + PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT'
    );

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT',
      l_row_count
    );

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMR_CAL_GL(p_worker_id);'
    );

    commit;

  end EXPAND_RMR_CAL_GL;


  -- -----------------------------------------------------
  -- procedure EXPAND_RMR_CAL_WK
  -- -----------------------------------------------------
  procedure EXPAND_RMR_CAL_WK (p_worker_id in number) is

    l_process   varchar2(30);
    l_row_count number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMR_CAL_WK(p_worker_id);'
            )) then
      return;
    end if;

    insert /*+ append parallel(res1_i) */ into PJI_RM_AGGR_RES1 res1_i
    (
      WORKER_ID,
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
      CAPACITY_HRS,
      TOTAL_HRS_A,
      BILL_HRS_A,
      CONF_HRS_S,
      PROV_HRS_S,
      UNASSIGNED_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S
    )
    select /*+ ordered
               full(time) use_hash(time) swap_join_inputs(time)
               full(tmp1) use_hash(tmp1) parallel(tmp1) */
      p_worker_id,
      tmp1.RECORD_TYPE,
      -1,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
      time.WEEK_ID                            TIME_ID,
      16                                      PERIOD_TYPE_ID,
      'E'                                     CALENDAR_TYPE,
      sum(tmp1.CAPACITY_HRS)                  CAPACITY_HRS,
      sum(tmp1.TOTAL_HRS_A)                   TOTAL_HRS_A,
      sum(tmp1.BILL_HRS_A)                    BILL_HRS_A,
      sum(tmp1.CONF_HRS_S)                    CONF_HRS_S,
      sum(tmp1.PROV_HRS_S)                    PROV_HRS_S,
      sum(tmp1.UNASSIGNED_HRS_S)              UNASSIGNED_HRS_S,
      sum(tmp1.CONF_OVERCOM_HRS_S)            CONF_OVERCOM_HRS_S,
      sum(tmp1.PROV_OVERCOM_HRS_S)            PROV_OVERCOM_HRS_S
    from
      FII_TIME_DAY     time,
      PJI_RM_AGGR_RES1 tmp1
    where
      tmp1.WORKER_ID      = p_worker_id and
      tmp1.RECORD_TYPE   <> 'N'         and
      tmp1.PERIOD_TYPE_ID = 1           and
      tmp1.CALENDAR_TYPE  = 'C'         and
      tmp1.TIME_ID        = time.REPORT_DATE_JULIAN
    group by
      tmp1.RECORD_TYPE,
      tmp1.PERSON_ID,
      tmp1.EXPENDITURE_ORGANIZATION_ID,
      tmp1.EXPENDITURE_ORG_ID,
      tmp1.WORK_TYPE_ID,
      tmp1.JOB_ID,
      time.WEEK_ID;

    l_row_count := sql%rowcount;

    l_row_count := l_row_count + PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT'
    );

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT',
      l_row_count
    );

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMR_CAL_WK(p_worker_id);'
    );

    commit;

  end EXPAND_RMR_CAL_WK;


  -- -----------------------------------------------------
  -- procedure EXPAND_RMS_CAL_EN
  -- -----------------------------------------------------
  procedure EXPAND_RMS_CAL_EN (p_worker_id in number) is

    l_process   varchar2(30);
    l_row_count number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMS_CAL_EN(p_worker_id);'
            )) then
      return;
    end if;

    insert /*+ append parallel(res2_i) */ into PJI_RM_AGGR_RES2 res2_i
    (
      WORKER_ID,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      JOB_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CAPACITY_HRS,
      TOTAL_HRS_A,
      MISSING_HRS_A,
      TOTAL_WTD_ORG_HRS_A,
      TOTAL_WTD_RES_HRS_A,
      BILL_HRS_A,
      BILL_WTD_ORG_HRS_A,
      BILL_WTD_RES_HRS_A,
      TRAINING_HRS_A,
      UNASSIGNED_HRS_A,
      REDUCIBLE_CAPACITY_HRS_A,
      REDUCE_CAPACITY_HRS_A,
      CONF_HRS_S,
      CONF_WTD_ORG_HRS_S,
      CONF_WTD_RES_HRS_S,
      CONF_BILL_HRS_S,
      CONF_BILL_WTD_ORG_HRS_S,
      CONF_BILL_WTD_RES_HRS_S,
      PROV_HRS_S,
      PROV_WTD_ORG_HRS_S,
      PROV_WTD_RES_HRS_S,
      PROV_BILL_HRS_S,
      PROV_BILL_WTD_ORG_HRS_S,
      PROV_BILL_WTD_RES_HRS_S,
      TRAINING_HRS_S,
      UNASSIGNED_HRS_S,
      REDUCIBLE_CAPACITY_HRS_S,
      REDUCE_CAPACITY_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S,
      AVAILABLE_HRS_BKT1_S,
      AVAILABLE_HRS_BKT2_S,
      AVAILABLE_HRS_BKT3_S,
      AVAILABLE_HRS_BKT4_S,
      AVAILABLE_HRS_BKT5_S,
      AVAILABLE_RES_COUNT_BKT1_S,
      AVAILABLE_RES_COUNT_BKT2_S,
      AVAILABLE_RES_COUNT_BKT3_S,
      AVAILABLE_RES_COUNT_BKT4_S,
      AVAILABLE_RES_COUNT_BKT5_S,
      TOTAL_RES_COUNT
    )
    select /*+ ordered
               full(time) use_hash(time) swap_join_inputs(time)
               full(tmp2) use_hash(tmp2) parallel(tmp2) */
      p_worker_id,
      tmp2.PERSON_ID,
      tmp2.EXPENDITURE_ORG_ID,
      tmp2.EXPENDITURE_ORGANIZATION_ID,
      tmp2.JOB_ID,
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
           end                                TIME_ID,
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
           end                                PERIOD_TYPE_ID,
      'E'                                     CALENDAR_TYPE,
      sum(tmp2.CAPACITY_HRS)                  CAPACITY_HRS,
      sum(tmp2.TOTAL_HRS_A)                   TOTAL_HRS_A,
      sum(tmp2.MISSING_HRS_A)                 MISSING_HRS_A,
      sum(tmp2.TOTAL_WTD_ORG_HRS_A)           TOTAL_WTD_ORG_HRS_A,
      sum(tmp2.TOTAL_WTD_RES_HRS_A)           TOTAL_WTD_RES_HRS_A,
      sum(tmp2.BILL_HRS_A)                    BILL_HRS_A,
      sum(tmp2.BILL_WTD_ORG_HRS_A)            BILL_WTD_ORG_HRS_A,
      sum(tmp2.BILL_WTD_RES_HRS_A)            BILL_WTD_RES_HRS_A,
      sum(tmp2.TRAINING_HRS_A)                TRAINING_HRS_A,
      sum(tmp2.UNASSIGNED_HRS_A)              UNASSIGNED_HRS_A,
      sum(tmp2.REDUCIBLE_CAPACITY_HRS_A)      REDUCIBLE_CAPACITY_HRS_A,
      sum(tmp2.REDUCE_CAPACITY_HRS_A)         REDUCE_CAPACITY_HRS_A,
      sum(tmp2.CONF_HRS_S)                    CONF_HRS_S,
      sum(tmp2.CONF_WTD_ORG_HRS_S)            CONF_WTD_ORG_HRS_S,
      sum(tmp2.CONF_WTD_RES_HRS_S)            CONF_WTD_RES_HRS_S,
      sum(tmp2.CONF_BILL_HRS_S)               CONF_BILL_HRS_S,
      sum(tmp2.CONF_BILL_WTD_ORG_HRS_S)       CONF_BILL_WTD_ORG_HRS_S,
      sum(tmp2.CONF_BILL_WTD_RES_HRS_S)       CONF_BILL_WTD_RES_HRS_S,
      sum(tmp2.PROV_HRS_S)                    PROV_HRS_S,
      sum(tmp2.PROV_WTD_ORG_HRS_S)            PROV_WTD_ORG_HRS_S,
      sum(tmp2.PROV_WTD_RES_HRS_S)            PROV_WTD_RES_HRS_S,
      sum(tmp2.PROV_BILL_HRS_S)               PROV_BILL_HRS_S,
      sum(tmp2.PROV_BILL_WTD_ORG_HRS_S)       PROV_BILL_WTD_ORG_HRS_S,
      sum(tmp2.PROV_BILL_WTD_RES_HRS_S)       PROV_BILL_WTD_RES_HRS_S,
      sum(tmp2.TRAINING_HRS_S)                TRAINING_HRS_S,
      sum(tmp2.UNASSIGNED_HRS_S)              UNASSIGNED_HRS_S,
      sum(tmp2.REDUCIBLE_CAPACITY_HRS_S)      REDUCIBLE_CAPACITY_HRS_S,
      sum(tmp2.REDUCE_CAPACITY_HRS_S)         REDUCE_CAPACITY_HRS_S,
      sum(tmp2.CONF_OVERCOM_HRS_S)            CONF_OVERCOM_HRS_S,
      sum(tmp2.PROV_OVERCOM_HRS_S)            PROV_OVERCOM_HRS_S,
      sum(tmp2.AVAILABLE_HRS_BKT1_S)          AVAILABLE_HRS_BKT1_S,
      sum(tmp2.AVAILABLE_HRS_BKT2_S)          AVAILABLE_HRS_BKT2_S,
      sum(tmp2.AVAILABLE_HRS_BKT3_S)          AVAILABLE_HRS_BKT3_S,
      sum(tmp2.AVAILABLE_HRS_BKT4_S)          AVAILABLE_HRS_BKT4_S,
      sum(tmp2.AVAILABLE_HRS_BKT5_S)          AVAILABLE_HRS_BKT5_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT1_S)    AVAILABLE_RES_COUNT_BKT1_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT2_S)    AVAILABLE_RES_COUNT_BKT2_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT3_S)    AVAILABLE_RES_COUNT_BKT3_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT4_S)    AVAILABLE_RES_COUNT_BKT4_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT5_S)    AVAILABLE_RES_COUNT_BKT5_S,
      sum(tmp2.TOTAL_RES_COUNT)               TOTAL_RES_COUNT
    from
      FII_TIME_DAY     time,
      PJI_RM_AGGR_RES2 tmp2
    where
      tmp2.WORKER_ID      = p_worker_id and
      tmp2.PERIOD_TYPE_ID = 1           and
      tmp2.CALENDAR_TYPE  = 'C'         and
      tmp2.TIME_ID        = time.REPORT_DATE_JULIAN
    group by
      tmp2.PERSON_ID,
      tmp2.EXPENDITURE_ORG_ID,
      tmp2.EXPENDITURE_ORGANIZATION_ID,
      tmp2.JOB_ID,
      rollup (time.ENT_YEAR_ID,
              time.ENT_QTR_ID,
              time.ENT_PERIOD_ID)
    having
      not (grouping(time.ENT_YEAR_ID)   = 1 and
           grouping(time.ENT_QTR_ID)    = 1 and
           grouping(time.ENT_PERIOD_ID) = 1);

    l_row_count := sql%rowcount;

    l_row_count := l_row_count + PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT'
    );

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT',
      l_row_count
    );

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMS_CAL_EN(p_worker_id);'
    );

    commit;

  end EXPAND_RMS_CAL_EN;


  -- -----------------------------------------------------
  -- procedure EXPAND_RMS_CAL_PA
  -- -----------------------------------------------------
  procedure EXPAND_RMS_CAL_PA (p_worker_id in number) is

    l_process   varchar2(30);
    l_row_count number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
        (
          l_process,
          'PA_CALENDAR_FLAG'
        ) = 'N') then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMS_CAL_PA(p_worker_id);'
            )) then
      return;
    end if;

    insert /*+ append parallel(res2_i) */ into PJI_RM_AGGR_RES2 res2_i
    (
      WORKER_ID,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      JOB_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CAPACITY_HRS,
      TOTAL_HRS_A,
      MISSING_HRS_A,
      TOTAL_WTD_ORG_HRS_A,
      TOTAL_WTD_RES_HRS_A,
      BILL_HRS_A,
      BILL_WTD_ORG_HRS_A,
      BILL_WTD_RES_HRS_A,
      TRAINING_HRS_A,
      UNASSIGNED_HRS_A,
      REDUCIBLE_CAPACITY_HRS_A,
      REDUCE_CAPACITY_HRS_A,
      CONF_HRS_S,
      CONF_WTD_ORG_HRS_S,
      CONF_WTD_RES_HRS_S,
      CONF_BILL_HRS_S,
      CONF_BILL_WTD_ORG_HRS_S,
      CONF_BILL_WTD_RES_HRS_S,
      PROV_HRS_S,
      PROV_WTD_ORG_HRS_S,
      PROV_WTD_RES_HRS_S,
      PROV_BILL_HRS_S,
      PROV_BILL_WTD_ORG_HRS_S,
      PROV_BILL_WTD_RES_HRS_S,
      TRAINING_HRS_S,
      UNASSIGNED_HRS_S,
      REDUCIBLE_CAPACITY_HRS_S,
      REDUCE_CAPACITY_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S,
      AVAILABLE_HRS_BKT1_S,
      AVAILABLE_HRS_BKT2_S,
      AVAILABLE_HRS_BKT3_S,
      AVAILABLE_HRS_BKT4_S,
      AVAILABLE_HRS_BKT5_S,
      AVAILABLE_RES_COUNT_BKT1_S,
      AVAILABLE_RES_COUNT_BKT2_S,
      AVAILABLE_RES_COUNT_BKT3_S,
      AVAILABLE_RES_COUNT_BKT4_S,
      AVAILABLE_RES_COUNT_BKT5_S,
      TOTAL_RES_COUNT
    )
    select /*+ ordered
               full(time) use_hash(time) parallel(time) swap_join_inputs(time)
               full(tmp2) use_hash(tmp2) parallel(tmp2) */
      p_worker_id,
      tmp2.PERSON_ID,
      tmp2.EXPENDITURE_ORG_ID,
      tmp2.EXPENDITURE_ORGANIZATION_ID,
      tmp2.JOB_ID,
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
           end                                      TIME_ID,
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
           end                                      PERIOD_TYPE_ID,
      'P'                                           CALENDAR_TYPE,
      sum(tmp2.CAPACITY_HRS)                        CAPACITY_HRS,
      sum(tmp2.TOTAL_HRS_A)                         TOTAL_HRS_A,
      sum(tmp2.MISSING_HRS_A)                       MISSING_HRS_A,
      sum(tmp2.TOTAL_WTD_ORG_HRS_A)                 TOTAL_WTD_ORG_HRS_A,
      sum(tmp2.TOTAL_WTD_RES_HRS_A)                 TOTAL_WTD_RES_HRS_A,
      sum(tmp2.BILL_HRS_A)                          BILL_HRS_A,
      sum(tmp2.BILL_WTD_ORG_HRS_A)                  BILL_WTD_ORG_HRS_A,
      sum(tmp2.BILL_WTD_RES_HRS_A)                  BILL_WTD_RES_HRS_A,
      sum(tmp2.TRAINING_HRS_A)                      TRAINING_HRS_A,
      sum(tmp2.UNASSIGNED_HRS_A)                    UNASSIGNED_HRS_A,
      sum(tmp2.REDUCIBLE_CAPACITY_HRS_A)            REDUCIBLE_CAPACITY_HRS_A,
      sum(tmp2.REDUCE_CAPACITY_HRS_A)               REDUCE_CAPACITY_HRS_A,
      sum(tmp2.CONF_HRS_S)                          CONF_HRS_S,
      sum(tmp2.CONF_WTD_ORG_HRS_S)                  CONF_WTD_ORG_HRS_S,
      sum(tmp2.CONF_WTD_RES_HRS_S)                  CONF_WTD_RES_HRS_S,
      sum(tmp2.CONF_BILL_HRS_S)                     CONF_BILL_HRS_S,
      sum(tmp2.CONF_BILL_WTD_ORG_HRS_S)             CONF_BILL_WTD_ORG_HRS_S,
      sum(tmp2.CONF_BILL_WTD_RES_HRS_S)             CONF_BILL_WTD_RES_HRS_S,
      sum(tmp2.PROV_HRS_S)                          PROV_HRS_S,
      sum(tmp2.PROV_WTD_ORG_HRS_S)                  PROV_WTD_ORG_HRS_S,
      sum(tmp2.PROV_WTD_RES_HRS_S)                  PROV_WTD_RES_HRS_S,
      sum(tmp2.PROV_BILL_HRS_S)                     PROV_BILL_HRS_S,
      sum(tmp2.PROV_BILL_WTD_ORG_HRS_S)             PROV_BILL_WTD_ORG_HRS_S,
      sum(tmp2.PROV_BILL_WTD_RES_HRS_S)             PROV_BILL_WTD_RES_HRS_S,
      sum(tmp2.TRAINING_HRS_S)                      TRAINING_HRS_S,
      sum(tmp2.UNASSIGNED_HRS_S)                    UNASSIGNED_HRS_S,
      sum(tmp2.REDUCIBLE_CAPACITY_HRS_S)            REDUCIBLE_CAPACITY_HRS_S,
      sum(tmp2.REDUCE_CAPACITY_HRS_S)               REDUCE_CAPACITY_HRS_S,
      sum(tmp2.CONF_OVERCOM_HRS_S)                  CONF_OVERCOM_HRS_S,
      sum(tmp2.PROV_OVERCOM_HRS_S)                  PROV_OVERCOM_HRS_S,
      sum(tmp2.AVAILABLE_HRS_BKT1_S)                AVAILABLE_HRS_BKT1_S,
      sum(tmp2.AVAILABLE_HRS_BKT2_S)                AVAILABLE_HRS_BKT2_S,
      sum(tmp2.AVAILABLE_HRS_BKT3_S)                AVAILABLE_HRS_BKT3_S,
      sum(tmp2.AVAILABLE_HRS_BKT4_S)                AVAILABLE_HRS_BKT4_S,
      sum(tmp2.AVAILABLE_HRS_BKT5_S)                AVAILABLE_HRS_BKT5_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT1_S)          AVAILABLE_RES_COUNT_BKT1_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT2_S)          AVAILABLE_RES_COUNT_BKT2_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT3_S)          AVAILABLE_RES_COUNT_BKT3_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT4_S)          AVAILABLE_RES_COUNT_BKT4_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT5_S)          AVAILABLE_RES_COUNT_BKT5_S,
      sum(tmp2.TOTAL_RES_COUNT)                     TOTAL_RES_COUNT
    from
      FII_TIME_CAL_DAY_MV time,
      PJI_RM_AGGR_RES2    tmp2
    where
      tmp2.WORKER_ID                      = p_worker_id      and
      tmp2.PERIOD_TYPE_ID                 = 1                and
      tmp2.CALENDAR_TYPE                  = 'C'              and
      to_date(to_char(tmp2.TIME_ID), 'J') = time.REPORT_DATE and
      tmp2.PA_CALENDAR_ID                 = time.CALENDAR_ID
    group by
      tmp2.PERSON_ID,
      tmp2.EXPENDITURE_ORGANIZATION_ID,
      tmp2.EXPENDITURE_ORG_ID,
      tmp2.JOB_ID,
      rollup (time.CAL_YEAR_ID,
              time.CAL_QTR_ID,
              time.CAL_PERIOD_ID)
    having
      not (grouping(time.CAL_YEAR_ID)   = 1 and
           grouping(time.CAL_QTR_ID)    = 1 and
           grouping(time.CAL_PERIOD_ID) = 1);

    l_row_count := sql%rowcount;

    l_row_count := l_row_count + PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT'
    );

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT',
      l_row_count
    );

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMS_CAL_PA(p_worker_id);'
    );

    commit;

  end EXPAND_RMS_CAL_PA;


  -- -----------------------------------------------------
  -- procedure EXPAND_RMS_CAL_GL
  -- -----------------------------------------------------
  procedure EXPAND_RMS_CAL_GL (p_worker_id in number) is

    l_process   varchar2(30);
    l_row_count number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
        (
          l_process,
          'GL_CALENDAR_FLAG'
        ) = 'N') then
      return;
    end if;

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMS_CAL_GL(p_worker_id);'
            )) then
      return;
    end if;

    insert /*+ append parallel(res2_i) */ into PJI_RM_AGGR_RES2 res2_i
    (
      WORKER_ID,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      JOB_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CAPACITY_HRS,
      TOTAL_HRS_A,
      MISSING_HRS_A,
      TOTAL_WTD_ORG_HRS_A,
      TOTAL_WTD_RES_HRS_A,
      BILL_HRS_A,
      BILL_WTD_ORG_HRS_A,
      BILL_WTD_RES_HRS_A,
      TRAINING_HRS_A,
      UNASSIGNED_HRS_A,
      REDUCIBLE_CAPACITY_HRS_A,
      REDUCE_CAPACITY_HRS_A,
      CONF_HRS_S,
      CONF_WTD_ORG_HRS_S,
      CONF_WTD_RES_HRS_S,
      CONF_BILL_HRS_S,
      CONF_BILL_WTD_ORG_HRS_S,
      CONF_BILL_WTD_RES_HRS_S,
      PROV_HRS_S,
      PROV_WTD_ORG_HRS_S,
      PROV_WTD_RES_HRS_S,
      PROV_BILL_HRS_S,
      PROV_BILL_WTD_ORG_HRS_S,
      PROV_BILL_WTD_RES_HRS_S,
      TRAINING_HRS_S,
      UNASSIGNED_HRS_S,
      REDUCIBLE_CAPACITY_HRS_S,
      REDUCE_CAPACITY_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S,
      AVAILABLE_HRS_BKT1_S,
      AVAILABLE_HRS_BKT2_S,
      AVAILABLE_HRS_BKT3_S,
      AVAILABLE_HRS_BKT4_S,
      AVAILABLE_HRS_BKT5_S,
      AVAILABLE_RES_COUNT_BKT1_S,
      AVAILABLE_RES_COUNT_BKT2_S,
      AVAILABLE_RES_COUNT_BKT3_S,
      AVAILABLE_RES_COUNT_BKT4_S,
      AVAILABLE_RES_COUNT_BKT5_S,
      TOTAL_RES_COUNT
    )
    select /*+ ordered
               full(time) use_hash(time) parallel(time) swap_join_inputs(time)
               full(tmp2) use_hash(tmp2) parallel(tmp2) */
      p_worker_id,
      tmp2.PERSON_ID,
      tmp2.EXPENDITURE_ORG_ID,
      tmp2.EXPENDITURE_ORGANIZATION_ID,
      tmp2.JOB_ID,
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
           end                                TIME_ID,
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
           end                                PERIOD_TYPE_ID,
      'G'                                     CALENDAR_TYPE,
      sum(tmp2.CAPACITY_HRS)                  CAPACITY_HRS,
      sum(tmp2.TOTAL_HRS_A)                   TOTAL_HRS_A,
      sum(tmp2.MISSING_HRS_A)                 MISSING_HRS_A,
      sum(tmp2.TOTAL_WTD_ORG_HRS_A)           TOTAL_WTD_ORG_HRS_A,
      sum(tmp2.TOTAL_WTD_RES_HRS_A)           TOTAL_WTD_RES_HRS_A,
      sum(tmp2.BILL_HRS_A)                    BILL_HRS_A,
      sum(tmp2.BILL_WTD_ORG_HRS_A)            BILL_WTD_ORG_HRS_A,
      sum(tmp2.BILL_WTD_RES_HRS_A)            BILL_WTD_RES_HRS_A,
      sum(tmp2.TRAINING_HRS_A)                TRAINING_HRS_A,
      sum(tmp2.UNASSIGNED_HRS_A)              UNASSIGNED_HRS_A,
      sum(tmp2.REDUCIBLE_CAPACITY_HRS_A)      REDUCIBLE_CAPACITY_HRS_A,
      sum(tmp2.REDUCE_CAPACITY_HRS_A)         REDUCE_CAPACITY_HRS_A,
      sum(tmp2.CONF_HRS_S)                    CONF_HRS_S,
      sum(tmp2.CONF_WTD_ORG_HRS_S)            CONF_WTD_ORG_HRS_S,
      sum(tmp2.CONF_WTD_RES_HRS_S)            CONF_WTD_RES_HRS_S,
      sum(tmp2.CONF_BILL_HRS_S)               CONF_BILL_HRS_S,
      sum(tmp2.CONF_BILL_WTD_ORG_HRS_S)       CONF_BILL_WTD_ORG_HRS_S,
      sum(tmp2.CONF_BILL_WTD_RES_HRS_S)       CONF_BILL_WTD_RES_HRS_S,
      sum(tmp2.PROV_HRS_S)                    PROV_HRS_S,
      sum(tmp2.PROV_WTD_ORG_HRS_S)            PROV_WTD_ORG_HRS_S,
      sum(tmp2.PROV_WTD_RES_HRS_S)            PROV_WTD_RES_HRS_S,
      sum(tmp2.PROV_BILL_HRS_S)               PROV_BILL_HRS_S,
      sum(tmp2.PROV_BILL_WTD_ORG_HRS_S)       PROV_BILL_WTD_ORG_HRS_S,
      sum(tmp2.PROV_BILL_WTD_RES_HRS_S)       PROV_BILL_WTD_RES_HRS_S,
      sum(tmp2.TRAINING_HRS_S)                TRAINING_HRS_S,
      sum(tmp2.UNASSIGNED_HRS_S)              UNASSIGNED_HRS_S,
      sum(tmp2.REDUCIBLE_CAPACITY_HRS_S)      REDUCIBLE_CAPACITY_HRS_S,
      sum(tmp2.REDUCE_CAPACITY_HRS_S)         REDUCE_CAPACITY_HRS_S,
      sum(tmp2.CONF_OVERCOM_HRS_S)            CONF_OVERCOM_HRS_S,
      sum(tmp2.PROV_OVERCOM_HRS_S)            PROV_OVERCOM_HRS_S,
      sum(tmp2.AVAILABLE_HRS_BKT1_S)          AVAILABLE_HRS_BKT1_S,
      sum(tmp2.AVAILABLE_HRS_BKT2_S)          AVAILABLE_HRS_BKT2_S,
      sum(tmp2.AVAILABLE_HRS_BKT3_S)          AVAILABLE_HRS_BKT3_S,
      sum(tmp2.AVAILABLE_HRS_BKT4_S)          AVAILABLE_HRS_BKT4_S,
      sum(tmp2.AVAILABLE_HRS_BKT5_S)          AVAILABLE_HRS_BKT5_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT1_S)    AVAILABLE_RES_COUNT_BKT1_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT2_S)    AVAILABLE_RES_COUNT_BKT2_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT3_S)    AVAILABLE_RES_COUNT_BKT3_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT4_S)    AVAILABLE_RES_COUNT_BKT4_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT5_S)    AVAILABLE_RES_COUNT_BKT5_S,
      sum(tmp2.TOTAL_RES_COUNT)               TOTAL_RES_COUNT
    from
      FII_TIME_CAL_DAY_MV time,
      PJI_RM_AGGR_RES2    tmp2
    where
      tmp2.WORKER_ID                      = p_worker_id      and
      tmp2.PERIOD_TYPE_ID                 = 1                and
      tmp2.CALENDAR_TYPE                  = 'C'              and
      to_date(to_char(tmp2.TIME_ID), 'J') = time.REPORT_DATE and
      tmp2.GL_CALENDAR_ID                 = time.CALENDAR_ID
    group by
      tmp2.PERSON_ID,
      tmp2.EXPENDITURE_ORGANIZATION_ID,
      tmp2.EXPENDITURE_ORG_ID,
      tmp2.JOB_ID,
      rollup (time.CAL_YEAR_ID,
              time.CAL_QTR_ID,
              time.CAL_PERIOD_ID)
    having
      not (grouping(time.CAL_YEAR_ID)   = 1 and
           grouping(time.CAL_QTR_ID)    = 1 and
           grouping(time.CAL_PERIOD_ID) = 1);

    l_row_count := sql%rowcount;

    l_row_count := l_row_count + PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT'
    );

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT',
      l_row_count
    );

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMS_CAL_GL(p_worker_id);'
    );

    commit;

  end EXPAND_RMS_CAL_GL;


  -- -----------------------------------------------------
  -- procedure EXPAND_RMS_CAL_WK
  -- -----------------------------------------------------
  procedure EXPAND_RMS_CAL_WK (p_worker_id in number) is

    l_process   varchar2(30);
    l_row_count number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMS_CAL_WK(p_worker_id);'
            )) then
      return;
    end if;

    insert /*+ append parallel(res2_i) */ into PJI_RM_AGGR_RES2 res2_i
    (
      WORKER_ID,
      PERSON_ID,
      EXPENDITURE_ORG_ID,
      EXPENDITURE_ORGANIZATION_ID,
      JOB_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      CAPACITY_HRS,
      TOTAL_HRS_A,
      MISSING_HRS_A,
      TOTAL_WTD_ORG_HRS_A,
      TOTAL_WTD_RES_HRS_A,
      BILL_HRS_A,
      BILL_WTD_ORG_HRS_A,
      BILL_WTD_RES_HRS_A,
      TRAINING_HRS_A,
      UNASSIGNED_HRS_A,
      REDUCIBLE_CAPACITY_HRS_A,
      REDUCE_CAPACITY_HRS_A,
      CONF_HRS_S,
      CONF_WTD_ORG_HRS_S,
      CONF_WTD_RES_HRS_S,
      CONF_BILL_HRS_S,
      CONF_BILL_WTD_ORG_HRS_S,
      CONF_BILL_WTD_RES_HRS_S,
      PROV_HRS_S,
      PROV_WTD_ORG_HRS_S,
      PROV_WTD_RES_HRS_S,
      PROV_BILL_HRS_S,
      PROV_BILL_WTD_ORG_HRS_S,
      PROV_BILL_WTD_RES_HRS_S,
      TRAINING_HRS_S,
      UNASSIGNED_HRS_S,
      REDUCIBLE_CAPACITY_HRS_S,
      REDUCE_CAPACITY_HRS_S,
      CONF_OVERCOM_HRS_S,
      PROV_OVERCOM_HRS_S,
      AVAILABLE_HRS_BKT1_S,
      AVAILABLE_HRS_BKT2_S,
      AVAILABLE_HRS_BKT3_S,
      AVAILABLE_HRS_BKT4_S,
      AVAILABLE_HRS_BKT5_S,
      AVAILABLE_RES_COUNT_BKT1_S,
      AVAILABLE_RES_COUNT_BKT2_S,
      AVAILABLE_RES_COUNT_BKT3_S,
      AVAILABLE_RES_COUNT_BKT4_S,
      AVAILABLE_RES_COUNT_BKT5_S,
      TOTAL_RES_COUNT
    )
    select /*+ ordered
               full(time) use_hash(time) swap_join_inputs(time)
               full(tmp2) use_hash(tmp2) parallel(tmp2) */
      p_worker_id,
      tmp2.PERSON_ID,
      tmp2.EXPENDITURE_ORG_ID,
      tmp2.EXPENDITURE_ORGANIZATION_ID,
      tmp2.JOB_ID,
      time.WEEK_ID                            TIME_ID,
      16                                      PERIOD_TYPE_ID,
      'E'                                     CALENDAR_TYPE,
      sum(tmp2.CAPACITY_HRS)                  CAPACITY_HRS,
      sum(tmp2.TOTAL_HRS_A)                   TOTAL_HRS_A,
      sum(tmp2.MISSING_HRS_A)                 MISSING_HRS_A,
      sum(tmp2.TOTAL_WTD_ORG_HRS_A)           TOTAL_WTD_ORG_HRS_A,
      sum(tmp2.TOTAL_WTD_RES_HRS_A)           TOTAL_WTD_RES_HRS_A,
      sum(tmp2.BILL_HRS_A)                    BILL_HRS_A,
      sum(tmp2.BILL_WTD_ORG_HRS_A)            BILL_WTD_ORG_HRS_A,
      sum(tmp2.BILL_WTD_RES_HRS_A)            BILL_WTD_RES_HRS_A,
      sum(tmp2.TRAINING_HRS_A)                TRAINING_HRS_A,
      sum(tmp2.UNASSIGNED_HRS_A)              UNASSIGNED_HRS_A,
      sum(tmp2.REDUCIBLE_CAPACITY_HRS_A)      REDUCIBLE_CAPACITY_HRS_A,
      sum(tmp2.REDUCE_CAPACITY_HRS_A)         REDUCE_CAPACITY_HRS_A,
      sum(tmp2.CONF_HRS_S)                    CONF_HRS_S,
      sum(tmp2.CONF_WTD_ORG_HRS_S)            CONF_WTD_ORG_HRS_S,
      sum(tmp2.CONF_WTD_RES_HRS_S)            CONF_WTD_RES_HRS_S,
      sum(tmp2.CONF_BILL_HRS_S)               CONF_BILL_HRS_S,
      sum(tmp2.CONF_BILL_WTD_ORG_HRS_S)       CONF_BILL_WTD_ORG_HRS_S,
      sum(tmp2.CONF_BILL_WTD_RES_HRS_S)       CONF_BILL_WTD_RES_HRS_S,
      sum(tmp2.PROV_HRS_S)                    PROV_HRS_S,
      sum(tmp2.PROV_WTD_ORG_HRS_S)            PROV_WTD_ORG_HRS_S,
      sum(tmp2.PROV_WTD_RES_HRS_S)            PROV_WTD_RES_HRS_S,
      sum(tmp2.PROV_BILL_HRS_S)               PROV_BILL_HRS_S,
      sum(tmp2.PROV_BILL_WTD_ORG_HRS_S)       PROV_BILL_WTD_ORG_HRS_S,
      sum(tmp2.PROV_BILL_WTD_RES_HRS_S)       PROV_BILL_WTD_RES_HRS_S,
      sum(tmp2.TRAINING_HRS_S)                TRAINING_HRS_S,
      sum(tmp2.UNASSIGNED_HRS_S)              UNASSIGNED_HRS_S,
      sum(tmp2.REDUCIBLE_CAPACITY_HRS_S)      REDUCIBLE_CAPACITY_HRS_S,
      sum(tmp2.REDUCE_CAPACITY_HRS_S)         REDUCE_CAPACITY_HRS_S,
      sum(tmp2.CONF_OVERCOM_HRS_S)            CONF_OVERCOM_HRS_S,
      sum(tmp2.PROV_OVERCOM_HRS_S)            PROV_OVERCOM_HRS_S,
      sum(tmp2.AVAILABLE_HRS_BKT1_S)          AVAILABLE_HRS_BKT1_S,
      sum(tmp2.AVAILABLE_HRS_BKT2_S)          AVAILABLE_HRS_BKT2_S,
      sum(tmp2.AVAILABLE_HRS_BKT3_S)          AVAILABLE_HRS_BKT3_S,
      sum(tmp2.AVAILABLE_HRS_BKT4_S)          AVAILABLE_HRS_BKT4_S,
      sum(tmp2.AVAILABLE_HRS_BKT5_S)          AVAILABLE_HRS_BKT5_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT1_S)    AVAILABLE_RES_COUNT_BKT1_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT2_S)    AVAILABLE_RES_COUNT_BKT2_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT3_S)    AVAILABLE_RES_COUNT_BKT3_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT4_S)    AVAILABLE_RES_COUNT_BKT4_S,
      sum(tmp2.AVAILABLE_RES_COUNT_BKT5_S)    AVAILABLE_RES_COUNT_BKT5_S,
      sum(tmp2.TOTAL_RES_COUNT)               TOTAL_RES_COUNT
    from
      FII_TIME_DAY     time,
      PJI_RM_AGGR_RES2 tmp2
    where
      tmp2.WORKER_ID      = p_worker_id and
      tmp2.PERIOD_TYPE_ID = 1           and
      tmp2.CALENDAR_TYPE  = 'C'         and
      tmp2.TIME_ID        = time.REPORT_DATE_JULIAN
    group by
      tmp2.PERSON_ID,
      tmp2.EXPENDITURE_ORGANIZATION_ID,
      tmp2.EXPENDITURE_ORG_ID,
      tmp2.JOB_ID,
      time.WEEK_ID;

    l_row_count := sql%rowcount;

    l_row_count := l_row_count + PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT'
    );

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
    (
      l_process,
      'TOTAL_RES_ROW_COUNT',
      l_row_count
    );

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.EXPAND_RMS_CAL_WK(p_worker_id);'
    );

    commit;

  end EXPAND_RMS_CAL_WK;


  -- -----------------------------------------------------
  -- procedure MERGE_TMP1_INTO_RMR
  -- -----------------------------------------------------
  procedure MERGE_TMP1_INTO_RMR (p_worker_id in number) is

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);
    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
  'PJI_RM_SUM_ROLLUP_RES.MERGE_TMP1_INTO_RMR(p_worker_id);'
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

      insert /*+ append parallel(rmr_i) */ into PJI_RM_RES_WT_F rmr_i
      (
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
        CAPACITY_HRS,
        TOTAL_HRS_A,
        BILL_HRS_A,
        CONF_HRS_S,
        PROV_HRS_S,
        UNASSIGNED_HRS_S,
        CONF_OVERCOM_HRS_S,
        PROV_OVERCOM_HRS_S,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ parallel(res1) */
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
        sum(CAPACITY_HRS)       CAPACITY_HRS,
        sum(TOTAL_HRS_A)        TOTAL_HRS_A,
        sum(BILL_HRS_A)         BILL_HRS_A,
        sum(CONF_HRS_S)         CONF_HRS_S,
        sum(PROV_HRS_S)         PROV_HRS_S,
        sum(UNASSIGNED_HRS_S)   UNASSIGNED_HRS_S,
        sum(CONF_OVERCOM_HRS_S) CONF_OVERCOM_HRS_S,
        sum(PROV_OVERCOM_HRS_S) PROV_OVERCOM_HRS_S,
        l_last_update_date      LAST_UPDATE_DATE,
        l_last_updated_by       LAST_UPDATED_BY,
        l_creation_date         CREATION_DATE,
        l_created_by            CREATED_BY,
        l_last_update_login     LAST_UPDATE_LOGIN
      from
        PJI_RM_AGGR_RES1 res1
      where
        WORKER_ID = p_worker_id and
        EXPENDITURE_ORGANIZATION_ID is not null and
        RECORD_TYPE <> 'N'
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
        CALENDAR_TYPE;

    else

      merge /*+ parallel(rmr) */ into PJI_RM_RES_WT_F rmr
      using
      (
        select /*+ parallel(res1) */
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
          sum(CAPACITY_HRS)       CAPACITY_HRS,
          sum(TOTAL_HRS_A)        TOTAL_HRS_A,
          sum(BILL_HRS_A)         BILL_HRS_A,
          sum(CONF_HRS_S)         CONF_HRS_S,
          sum(PROV_HRS_S)         PROV_HRS_S,
          sum(UNASSIGNED_HRS_S)   UNASSIGNED_HRS_S,
          sum(CONF_OVERCOM_HRS_S) CONF_OVERCOM_HRS_S,
          sum(PROV_OVERCOM_HRS_S) PROV_OVERCOM_HRS_S,
          l_last_update_date      LAST_UPDATE_DATE,
          l_last_updated_by       LAST_UPDATED_BY,
          l_creation_date         CREATION_DATE,
          l_created_by            CREATED_BY,
          l_last_update_login     LAST_UPDATE_LOGIN
        from
          PJI_RM_AGGR_RES1 res1
        where
          WORKER_ID = p_worker_id and
          EXPENDITURE_ORGANIZATION_ID is not null and
          RECORD_TYPE <> 'N'
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
          CALENDAR_TYPE
      ) res1
      on
      (
        res1.RECORD_TYPE                 = rmr.RECORD_TYPE                 and
        res1.PROJECT_ID                  = rmr.PROJECT_ID                  and
        res1.PERSON_ID                   = rmr.PERSON_ID                   and
        res1.EXPENDITURE_ORG_ID          = rmr.EXPENDITURE_ORG_ID          and
        res1.EXPENDITURE_ORGANIZATION_ID = rmr.EXPENDITURE_ORGANIZATION_ID and
        res1.JOB_ID                      = rmr.JOB_ID                      and
        res1.WORK_TYPE_ID                = rmr.WORK_TYPE_ID                and
        res1.TIME_ID                     = rmr.TIME_ID                     and
        res1.PERIOD_TYPE_ID              = rmr.PERIOD_TYPE_ID              and
        res1.CALENDAR_TYPE               = rmr.CALENDAR_TYPE
      )
      when matched then update set
        rmr.CAPACITY_HRS       = case when rmr.CAPACITY_HRS is null and
                                           res1.CAPACITY_HRS is null
                                      then to_number(null)
                                      else nvl(rmr.CAPACITY_HRS, 0) +
                                           nvl(res1.CAPACITY_HRS, 0)
                                      end,
        rmr.TOTAL_HRS_A        = case when rmr.TOTAL_HRS_A is null and
                                           res1.TOTAL_HRS_A is null
                                      then to_number(null)
                                      else nvl(rmr.TOTAL_HRS_A, 0) +
                                           nvl(res1.TOTAL_HRS_A, 0)
                                      end,
        rmr.BILL_HRS_A         = case when rmr.BILL_HRS_A is null and
                                           res1.BILL_HRS_A is null
                                      then to_number(null)
                                      else nvl(rmr.BILL_HRS_A, 0) +
                                           nvl(res1.BILL_HRS_A, 0)
                                      end,
        rmr.CONF_HRS_S         = case when rmr.CONF_HRS_S is null and
                                           res1.CONF_HRS_S is null
                                      then to_number(null)
                                      else nvl(rmr.CONF_HRS_S, 0) +
                                           nvl(res1.CONF_HRS_S, 0)
                                      end,
        rmr.PROV_HRS_S         = case when rmr.PROV_HRS_S is null and
                                           res1.PROV_HRS_S is null
                                      then to_number(null)
                                      else nvl(rmr.PROV_HRS_S, 0) +
                                           nvl(res1.PROV_HRS_S, 0)
                                      end,
        rmr.UNASSIGNED_HRS_S   = case when rmr.UNASSIGNED_HRS_S is null and
                                           res1.UNASSIGNED_HRS_S is null
                                      then to_number(null)
                                      else nvl(rmr.UNASSIGNED_HRS_S, 0) +
                                           nvl(res1.UNASSIGNED_HRS_S, 0)
                                      end,
        rmr.CONF_OVERCOM_HRS_S = case when rmr.CONF_OVERCOM_HRS_S is null and
                                           res1.CONF_OVERCOM_HRS_S is null
                                      then to_number(null)
                                      else nvl(rmr.CONF_OVERCOM_HRS_S, 0) +
                                           nvl(res1.CONF_OVERCOM_HRS_S, 0)
                                      end,
        rmr.PROV_OVERCOM_HRS_S = case when rmr.PROV_OVERCOM_HRS_S is null and
                                           res1.PROV_OVERCOM_HRS_S is null
                                      then to_number(null)
                                      else nvl(rmr.PROV_OVERCOM_HRS_S, 0) +
                                           nvl(res1.PROV_OVERCOM_HRS_S, 0)
                                      end,
        rmr.LAST_UPDATE_DATE   = res1.LAST_UPDATE_DATE,
        rmr.LAST_UPDATED_BY    = res1.LAST_UPDATED_BY,
        rmr.LAST_UPDATE_LOGIN  = res1.LAST_UPDATE_LOGIN
      when not matched then insert
      (
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
        rmr.CAPACITY_HRS,
        rmr.TOTAL_HRS_A,
        rmr.BILL_HRS_A,
        rmr.CONF_HRS_S,
        rmr.PROV_HRS_S,
        rmr.UNASSIGNED_HRS_S,
        rmr.CONF_OVERCOM_HRS_S,
        rmr.PROV_OVERCOM_HRS_S,
        rmr.LAST_UPDATE_DATE,
        rmr.LAST_UPDATED_BY,
        rmr.CREATION_DATE,
        rmr.CREATED_BY,
        rmr.LAST_UPDATE_LOGIN
      )
      values
      (
        res1.RECORD_TYPE,
        res1.PROJECT_ID,
        res1.PERSON_ID,
        res1.EXPENDITURE_ORG_ID,
        res1.EXPENDITURE_ORGANIZATION_ID,
        res1.WORK_TYPE_ID,
        res1.JOB_ID,
        res1.TIME_ID,
        res1.PERIOD_TYPE_ID,
        res1.CALENDAR_TYPE,
        res1.CAPACITY_HRS,
        res1.TOTAL_HRS_A,
        res1.BILL_HRS_A,
        res1.CONF_HRS_S,
        res1.PROV_HRS_S,
        res1.UNASSIGNED_HRS_S,
        res1.CONF_OVERCOM_HRS_S,
        res1.PROV_OVERCOM_HRS_S,
        res1.LAST_UPDATE_DATE,
        res1.LAST_UPDATED_BY,
        res1.CREATION_DATE,
        res1.CREATED_BY,
        res1.LAST_UPDATE_LOGIN
      );

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
  'PJI_RM_SUM_ROLLUP_RES.MERGE_TMP1_INTO_RMR(p_worker_id);'
    );

    commit;

  end MERGE_TMP1_INTO_RMR;


  -- -----------------------------------------------------
  -- procedure CLEANUP_RMR
  -- -----------------------------------------------------
  procedure CLEANUP_RMR (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
          'PJI_RM_SUM_ROLLUP_RES.CLEANUP_RMR(p_worker_id);'
            )) then
      return;
    end if;

    delete
    from   PJI_RM_RES_WT_F
    where  (RECORD_TYPE,
            PROJECT_ID,
            PERSON_ID,
            EXPENDITURE_ORG_ID,
            EXPENDITURE_ORGANIZATION_ID,
            WORK_TYPE_ID,
            JOB_ID,
            TIME_ID,
            PERIOD_TYPE_ID,
            CALENDAR_TYPE) in
           (select /*+ parallel(res1) */
                   RECORD_TYPE,
                   PROJECT_ID,
                   PERSON_ID,
                   EXPENDITURE_ORG_ID,
                   EXPENDITURE_ORGANIZATION_ID,
                   WORK_TYPE_ID,
                   JOB_ID,
                   TIME_ID,
                   PERIOD_TYPE_ID,
                   CALENDAR_TYPE
            from   PJI_RM_AGGR_RES1 res1
            where  WORKER_ID = p_worker_id and
                   RECORD_TYPE <> 'N') and
           nvl(CAPACITY_HRS, 0)       = 0 and
           nvl(TOTAL_HRS_A, 0)        = 0 and
           nvl(BILL_HRS_A, 0)         = 0 and
           nvl(CONF_HRS_S, 0)         = 0 and
           nvl(PROV_HRS_S, 0)         = 0 and
           nvl(UNASSIGNED_HRS_S, 0)   = 0 and
           nvl(CONF_OVERCOM_HRS_S, 0) = 0 and
           nvl(PROV_OVERCOM_HRS_S, 0) = 0;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_RM_SUM_ROLLUP_RES.CLEANUP_RMR(p_worker_id);'
    );

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                     'PJI_RM_AGGR_RES1','NORMAL',null);

    commit;

  end CLEANUP_RMR;


  -- -----------------------------------------------------
  -- procedure MERGE_TMP2_INTO_RMS
  -- -----------------------------------------------------
  procedure MERGE_TMP2_INTO_RMS (p_worker_id in number) is

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);
    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
  'PJI_RM_SUM_ROLLUP_RES.MERGE_TMP2_INTO_RMS(p_worker_id);'
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

      insert /*+ append parallel(rms_i) */ into PJI_RM_RES_F rms_i
      (
        PERSON_ID,
        EXPENDITURE_ORG_ID,
        EXPENDITURE_ORGANIZATION_ID,
        JOB_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        CAPACITY_HRS,
        TOTAL_HRS_A,
        MISSING_HRS_A,
        TOTAL_WTD_ORG_HRS_A,
        TOTAL_WTD_RES_HRS_A,
        BILL_HRS_A,
        BILL_WTD_ORG_HRS_A,
        BILL_WTD_RES_HRS_A,
        TRAINING_HRS_A,
        UNASSIGNED_HRS_A,
        REDUCIBLE_CAPACITY_HRS_A,
        REDUCE_CAPACITY_HRS_A,
        CONF_HRS_S,
        CONF_WTD_ORG_HRS_S,
        CONF_WTD_RES_HRS_S,
        CONF_BILL_HRS_S,
        CONF_BILL_WTD_ORG_HRS_S,
        CONF_BILL_WTD_RES_HRS_S,
        PROV_HRS_S,
        PROV_WTD_ORG_HRS_S,
        PROV_WTD_RES_HRS_S,
        PROV_BILL_HRS_S,
        PROV_BILL_WTD_ORG_HRS_S,
        PROV_BILL_WTD_RES_HRS_S,
        TRAINING_HRS_S,
        UNASSIGNED_HRS_S,
        REDUCIBLE_CAPACITY_HRS_S,
        REDUCE_CAPACITY_HRS_S,
        CONF_OVERCOM_HRS_S,
        PROV_OVERCOM_HRS_S,
        AVAILABLE_HRS_BKT1_S,
        AVAILABLE_HRS_BKT2_S,
        AVAILABLE_HRS_BKT3_S,
        AVAILABLE_HRS_BKT4_S,
        AVAILABLE_HRS_BKT5_S,
        AVAILABLE_RES_COUNT_BKT1_S,
        AVAILABLE_RES_COUNT_BKT2_S,
        AVAILABLE_RES_COUNT_BKT3_S,
        AVAILABLE_RES_COUNT_BKT4_S,
        AVAILABLE_RES_COUNT_BKT5_S,
        TOTAL_RES_COUNT,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ parallel(res2) */
        PERSON_ID,
        EXPENDITURE_ORG_ID,
        EXPENDITURE_ORGANIZATION_ID,
        JOB_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        sum(CAPACITY_HRS)               CAPACITY_HRS,
        sum(TOTAL_HRS_A)                TOTAL_HRS_A,
        sum(MISSING_HRS_A)              MISSING_HRS_A,
        sum(TOTAL_WTD_ORG_HRS_A)        TOTAL_WTD_ORG_HRS_A,
        sum(TOTAL_WTD_RES_HRS_A)        TOTAL_WTD_RES_HRS_A,
        sum(BILL_HRS_A)                 BILL_HRS_A,
        sum(BILL_WTD_ORG_HRS_A)         BILL_WTD_ORG_HRS_A,
        sum(BILL_WTD_RES_HRS_A)         BILL_WTD_RES_HRS_A,
        sum(TRAINING_HRS_A)             TRAINING_HRS_A,
        sum(UNASSIGNED_HRS_A)           UNASSIGNED_HRS_A,
        sum(REDUCIBLE_CAPACITY_HRS_A)   REDUCIBLE_CAPACITY_HRS_A,
        sum(REDUCE_CAPACITY_HRS_A)      REDUCE_CAPACITY_HRS_A,
        sum(CONF_HRS_S)                 CONF_HRS_S,
        sum(CONF_WTD_ORG_HRS_S)         CONF_WTD_ORG_HRS_S,
        sum(CONF_WTD_RES_HRS_S)         CONF_WTD_RES_HRS_S,
        sum(CONF_BILL_HRS_S)            CONF_BILL_HRS_S,
        sum(CONF_BILL_WTD_ORG_HRS_S)    CONF_BILL_WTD_ORG_HRS_S,
        sum(CONF_BILL_WTD_RES_HRS_S)    CONF_BILL_WTD_RES_HRS_S,
        sum(PROV_HRS_S)                 PROV_HRS_S,
        sum(PROV_WTD_ORG_HRS_S)         PROV_WTD_ORG_HRS_S,
        sum(PROV_WTD_RES_HRS_S)         PROV_WTD_RES_HRS_S,
        sum(PROV_BILL_HRS_S)            PROV_BILL_HRS_S,
        sum(PROV_BILL_WTD_ORG_HRS_S)    PROV_BILL_WTD_ORG_HRS_S,
        sum(PROV_BILL_WTD_RES_HRS_S)    PROV_BILL_WTD_RES_HRS_S,
        sum(TRAINING_HRS_S)             TRAINING_HRS_S,
        sum(UNASSIGNED_HRS_S)           UNASSIGNED_HRS_S,
        sum(REDUCIBLE_CAPACITY_HRS_S)   REDUCIBLE_CAPACITY_HRS_S,
        sum(REDUCE_CAPACITY_HRS_S)      REDUCE_CAPACITY_HRS_S,
        sum(CONF_OVERCOM_HRS_S)         CONF_OVERCOM_HRS_S,
        sum(PROV_OVERCOM_HRS_S)         PROV_OVERCOM_HRS_S,
        sum(AVAILABLE_HRS_BKT1_S)       AVAILABLE_HRS_BKT1_S,
        sum(AVAILABLE_HRS_BKT2_S)       AVAILABLE_HRS_BKT2_S,
        sum(AVAILABLE_HRS_BKT3_S)       AVAILABLE_HRS_BKT3_S,
        sum(AVAILABLE_HRS_BKT4_S)       AVAILABLE_HRS_BKT4_S,
        sum(AVAILABLE_HRS_BKT5_S)       AVAILABLE_HRS_BKT5_S,
        sum(AVAILABLE_RES_COUNT_BKT1_S) AVAILABLE_RES_COUNT_BKT1_S,
        sum(AVAILABLE_RES_COUNT_BKT2_S) AVAILABLE_RES_COUNT_BKT2_S,
        sum(AVAILABLE_RES_COUNT_BKT3_S) AVAILABLE_RES_COUNT_BKT3_S,
        sum(AVAILABLE_RES_COUNT_BKT4_S) AVAILABLE_RES_COUNT_BKT4_S,
        sum(AVAILABLE_RES_COUNT_BKT5_S) AVAILABLE_RES_COUNT_BKT5_S,
        sum(TOTAL_RES_COUNT)            TOTAL_RES_COUNT,
        l_last_update_date              LAST_UPDATE_DATE,
        l_last_updated_by               LAST_UPDATED_BY,
        l_creation_date                 CREATION_DATE,
        l_created_by                    CREATED_BY,
        l_last_update_login             LAST_UPDATE_LOGIN
      from
        PJI_RM_AGGR_RES2 res2
      where
        WORKER_ID = p_worker_id and
        EXPENDITURE_ORGANIZATION_ID is not null
      group by
        PERSON_ID,
        EXPENDITURE_ORG_ID,
        EXPENDITURE_ORGANIZATION_ID,
        JOB_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE;

    else

      merge /*+ parallel(rms) */ into PJI_RM_RES_F rms
      using
      (
        select /*+ parallel(res2) */
          PERSON_ID,
          EXPENDITURE_ORG_ID,
          EXPENDITURE_ORGANIZATION_ID,
          JOB_ID,
          TIME_ID,
          PERIOD_TYPE_ID,
          CALENDAR_TYPE,
          sum(CAPACITY_HRS)               CAPACITY_HRS,
          sum(TOTAL_HRS_A)                TOTAL_HRS_A,
          sum(MISSING_HRS_A)              MISSING_HRS_A,
          sum(TOTAL_WTD_ORG_HRS_A)        TOTAL_WTD_ORG_HRS_A,
          sum(TOTAL_WTD_RES_HRS_A)        TOTAL_WTD_RES_HRS_A,
          sum(BILL_HRS_A)                 BILL_HRS_A,
          sum(BILL_WTD_ORG_HRS_A)         BILL_WTD_ORG_HRS_A,
          sum(BILL_WTD_RES_HRS_A)         BILL_WTD_RES_HRS_A,
          sum(TRAINING_HRS_A)             TRAINING_HRS_A,
          sum(UNASSIGNED_HRS_A)           UNASSIGNED_HRS_A,
          sum(REDUCIBLE_CAPACITY_HRS_A)   REDUCIBLE_CAPACITY_HRS_A,
          sum(REDUCE_CAPACITY_HRS_A)      REDUCE_CAPACITY_HRS_A,
          sum(CONF_HRS_S)                 CONF_HRS_S,
          sum(CONF_WTD_ORG_HRS_S)         CONF_WTD_ORG_HRS_S,
          sum(CONF_WTD_RES_HRS_S)         CONF_WTD_RES_HRS_S,
          sum(CONF_BILL_HRS_S)            CONF_BILL_HRS_S,
          sum(CONF_BILL_WTD_ORG_HRS_S)    CONF_BILL_WTD_ORG_HRS_S,
          sum(CONF_BILL_WTD_RES_HRS_S)    CONF_BILL_WTD_RES_HRS_S,
          sum(PROV_HRS_S)                 PROV_HRS_S,
          sum(PROV_WTD_ORG_HRS_S)         PROV_WTD_ORG_HRS_S,
          sum(PROV_WTD_RES_HRS_S)         PROV_WTD_RES_HRS_S,
          sum(PROV_BILL_HRS_S)            PROV_BILL_HRS_S,
          sum(PROV_BILL_WTD_ORG_HRS_S)    PROV_BILL_WTD_ORG_HRS_S,
          sum(PROV_BILL_WTD_RES_HRS_S)    PROV_BILL_WTD_RES_HRS_S,
          sum(TRAINING_HRS_S)             TRAINING_HRS_S,
          sum(UNASSIGNED_HRS_S)           UNASSIGNED_HRS_S,
          sum(REDUCIBLE_CAPACITY_HRS_S)   REDUCIBLE_CAPACITY_HRS_S,
          sum(REDUCE_CAPACITY_HRS_S)      REDUCE_CAPACITY_HRS_S,
          sum(CONF_OVERCOM_HRS_S)         CONF_OVERCOM_HRS_S,
          sum(PROV_OVERCOM_HRS_S)         PROV_OVERCOM_HRS_S,
          sum(AVAILABLE_HRS_BKT1_S)       AVAILABLE_HRS_BKT1_S,
          sum(AVAILABLE_HRS_BKT2_S)       AVAILABLE_HRS_BKT2_S,
          sum(AVAILABLE_HRS_BKT3_S)       AVAILABLE_HRS_BKT3_S,
          sum(AVAILABLE_HRS_BKT4_S)       AVAILABLE_HRS_BKT4_S,
          sum(AVAILABLE_HRS_BKT5_S)       AVAILABLE_HRS_BKT5_S,
          sum(AVAILABLE_RES_COUNT_BKT1_S) AVAILABLE_RES_COUNT_BKT1_S,
          sum(AVAILABLE_RES_COUNT_BKT2_S) AVAILABLE_RES_COUNT_BKT2_S,
          sum(AVAILABLE_RES_COUNT_BKT3_S) AVAILABLE_RES_COUNT_BKT3_S,
          sum(AVAILABLE_RES_COUNT_BKT4_S) AVAILABLE_RES_COUNT_BKT4_S,
          sum(AVAILABLE_RES_COUNT_BKT5_S) AVAILABLE_RES_COUNT_BKT5_S,
          sum(TOTAL_RES_COUNT)            TOTAL_RES_COUNT,
          l_last_update_date              LAST_UPDATE_DATE,
          l_last_updated_by               LAST_UPDATED_BY,
          l_creation_date                 CREATION_DATE,
          l_created_by                    CREATED_BY,
          l_last_update_login             LAST_UPDATE_LOGIN
        from
          PJI_RM_AGGR_RES2 res2
        where
          WORKER_ID = p_worker_id and
          EXPENDITURE_ORGANIZATION_ID is not null
        group by
          PERSON_ID,
          EXPENDITURE_ORG_ID,
          EXPENDITURE_ORGANIZATION_ID,
          JOB_ID,
          TIME_ID,
          PERIOD_TYPE_ID,
          CALENDAR_TYPE
      ) res2
      on
      (
        res2.PERSON_ID                   = rms.PERSON_ID                   and
        res2.EXPENDITURE_ORG_ID          = rms.EXPENDITURE_ORG_ID          and
        res2.EXPENDITURE_ORGANIZATION_ID = rms.EXPENDITURE_ORGANIZATION_ID and
        res2.JOB_ID                      = rms.JOB_ID                      and
        res2.TIME_ID                     = rms.TIME_ID                     and
        res2.PERIOD_TYPE_ID              = rms.PERIOD_TYPE_ID              and
        res2.CALENDAR_TYPE               = rms.CALENDAR_TYPE
      )
      when matched then update set
        rms.CAPACITY_HRS = case when rms.CAPACITY_HRS is null and
                                     res2.CAPACITY_HRS is null
                                then to_number(null)
                                else nvl(rms.CAPACITY_HRS, 0) +
                                     nvl(res2.CAPACITY_HRS, 0)
                                end,
        rms.TOTAL_HRS_A  = case when rms.TOTAL_HRS_A is null and
                                     res2.TOTAL_HRS_A is null
                                then to_number(null)
                                else nvl(rms.TOTAL_HRS_A, 0) +
                                     nvl(res2.TOTAL_HRS_A, 0)
                                end,
        rms.MISSING_HRS_A= case when rms.MISSING_HRS_A  is null and
                                     res2.MISSING_HRS_A is null
                                then to_number(null)
                                else nvl(rms.MISSING_HRS_A, 0) +
                                     nvl(res2.MISSING_HRS_A, 0)
                                end,
        rms.TOTAL_WTD_ORG_HRS_A
                         = case when rms.TOTAL_WTD_ORG_HRS_A is null and
                                     res2.TOTAL_WTD_ORG_HRS_A is null
                                then to_number(null)
                                else nvl(rms.TOTAL_WTD_ORG_HRS_A, 0) +
                                     nvl(res2.TOTAL_WTD_ORG_HRS_A, 0)
                                end,
        rms.TOTAL_WTD_RES_HRS_A
                         = case when rms.TOTAL_WTD_RES_HRS_A is null and
                                     res2.TOTAL_WTD_RES_HRS_A is null
                                then to_number(null)
                                else nvl(rms.TOTAL_WTD_RES_HRS_A, 0) +
                                     nvl(res2.TOTAL_WTD_RES_HRS_A, 0)
                                end,
        rms.BILL_HRS_A   = case when rms.BILL_HRS_A is null and
                                     res2.BILL_HRS_A is null
                                then to_number(null)
                                else nvl(rms.BILL_HRS_A, 0) +
                                     nvl(res2.BILL_HRS_A, 0)
                                end,
        rms.BILL_WTD_ORG_HRS_A
                         = case when rms.BILL_WTD_ORG_HRS_A is null and
                                     res2.BILL_WTD_ORG_HRS_A is null
                                then to_number(null)
                                else nvl(rms.BILL_WTD_ORG_HRS_A, 0) +
                                     nvl(res2.BILL_WTD_ORG_HRS_A, 0)
                                end,
        rms.BILL_WTD_RES_HRS_A
                         = case when rms.BILL_WTD_RES_HRS_A is null and
                                     res2.BILL_WTD_RES_HRS_A is null
                                then to_number(null)
                                else nvl(rms.BILL_WTD_RES_HRS_A, 0) +
                                     nvl(res2.BILL_WTD_RES_HRS_A, 0)
                                end,
        rms.TRAINING_HRS_A
                         = case when rms.TRAINING_HRS_A is null and
                                     res2.TRAINING_HRS_A is null
                                then to_number(null)
                                else nvl(rms.TRAINING_HRS_A, 0) +
                                     nvl(res2.TRAINING_HRS_A, 0)
                                end,
        rms.UNASSIGNED_HRS_A
                         = case when rms.UNASSIGNED_HRS_A is null and
                                     res2.UNASSIGNED_HRS_A is null
                                then to_number(null)
                                else nvl(rms.UNASSIGNED_HRS_A, 0) +
                                     nvl(res2.UNASSIGNED_HRS_A, 0)
                                end,
        rms.REDUCIBLE_CAPACITY_HRS_A
                         = case when rms.REDUCIBLE_CAPACITY_HRS_A is null and
                                     res2.REDUCIBLE_CAPACITY_HRS_A is null
                                then to_number(null)
                                else nvl(rms.REDUCIBLE_CAPACITY_HRS_A, 0) +
                                     nvl(res2.REDUCIBLE_CAPACITY_HRS_A, 0)
                                end,
        rms.REDUCE_CAPACITY_HRS_A
                         = case when rms.REDUCE_CAPACITY_HRS_A is null and
                                     res2.REDUCE_CAPACITY_HRS_A is null
                                then to_number(null)
                                else nvl(rms.REDUCE_CAPACITY_HRS_A, 0) +
                                     nvl(res2.REDUCE_CAPACITY_HRS_A, 0)
                                end,
        rms.CONF_HRS_S   = case when rms.CONF_HRS_S is null and
                                     res2.CONF_HRS_S is null
                                then to_number(null)
                                else nvl(rms.CONF_HRS_S, 0) +
                                     nvl(res2.CONF_HRS_S, 0)
                                end,
        rms.CONF_WTD_ORG_HRS_S
                         = case when rms.CONF_WTD_ORG_HRS_S is null and
                                     res2.CONF_WTD_ORG_HRS_S is null
                                then to_number(null)
                                else nvl(rms.CONF_WTD_ORG_HRS_S, 0) +
                                     nvl(res2.CONF_WTD_ORG_HRS_S, 0)
                                end,
        rms.CONF_WTD_RES_HRS_S
                         = case when rms.CONF_WTD_RES_HRS_S is null and
                                     res2.CONF_WTD_RES_HRS_S is null
                                then to_number(null)
                                else nvl(rms.CONF_WTD_RES_HRS_S, 0) +
                                     nvl(res2.CONF_WTD_RES_HRS_S, 0)
                                end,
        rms.CONF_BILL_HRS_S
                         = case when rms.CONF_BILL_HRS_S is null and
                                     res2.CONF_BILL_HRS_S is null
                                then to_number(null)
                                else nvl(rms.CONF_BILL_HRS_S, 0) +
                                     nvl(res2.CONF_BILL_HRS_S, 0)
                                end,
        rms.CONF_BILL_WTD_ORG_HRS_S
                         = case when rms.CONF_BILL_WTD_ORG_HRS_S is null and
                                     res2.CONF_BILL_WTD_ORG_HRS_S is null
                                then to_number(null)
                                else nvl(rms.CONF_BILL_WTD_ORG_HRS_S, 0) +
                                     nvl(res2.CONF_BILL_WTD_ORG_HRS_S, 0)
                                end,
        rms.CONF_BILL_WTD_RES_HRS_S
                         = case when rms.CONF_BILL_WTD_RES_HRS_S is null and
                                     res2.CONF_BILL_WTD_RES_HRS_S is null
                                then to_number(null)
                                else nvl(rms.CONF_BILL_WTD_RES_HRS_S, 0) +
                                     nvl(res2.CONF_BILL_WTD_RES_HRS_S, 0)
                                end,
        rms.PROV_HRS_S   = case when rms.PROV_HRS_S is null and
                                     res2.PROV_HRS_S is null
                                then to_number(null)
                                else nvl(rms.PROV_HRS_S, 0) +
                                     nvl(res2.PROV_HRS_S, 0)
                                end,
        rms.PROV_WTD_ORG_HRS_S
                         = case when rms.PROV_WTD_ORG_HRS_S is null and
                                     res2.PROV_WTD_ORG_HRS_S is null
                                then to_number(null)
                                else nvl(rms.PROV_WTD_ORG_HRS_S, 0) +
                                     nvl(res2.PROV_WTD_ORG_HRS_S, 0)
                                end,
        rms.PROV_WTD_RES_HRS_S
                         = case when rms.PROV_WTD_RES_HRS_S is null and
                                     res2.PROV_WTD_RES_HRS_S is null
                                then to_number(null)
                                else nvl(rms.PROV_WTD_RES_HRS_S, 0) +
                                     nvl(res2.PROV_WTD_RES_HRS_S, 0)
                                end,
        rms.PROV_BILL_HRS_S
                         = case when rms.PROV_BILL_HRS_S is null and
                                     res2.PROV_BILL_HRS_S is null
                                then to_number(null)
                                else nvl(rms.PROV_BILL_HRS_S, 0) +
                                     nvl(res2.PROV_BILL_HRS_S, 0)
                                end,
        rms.PROV_BILL_WTD_ORG_HRS_S
                         = case when rms.PROV_BILL_WTD_ORG_HRS_S is null and
                                     res2.PROV_BILL_WTD_ORG_HRS_S is null
                                then to_number(null)
                                else nvl(rms.PROV_BILL_WTD_ORG_HRS_S, 0) +
                                     nvl(res2.PROV_BILL_WTD_ORG_HRS_S, 0)
                                end,
        rms.PROV_BILL_WTD_RES_HRS_S
                         = case when rms.PROV_BILL_WTD_RES_HRS_S is null and
                                     res2.PROV_BILL_WTD_RES_HRS_S is null
                                then to_number(null)
                                else nvl(rms.PROV_BILL_WTD_RES_HRS_S, 0) +
                                     nvl(res2.PROV_BILL_WTD_RES_HRS_S, 0)
                                end,
        rms.TRAINING_HRS_S
                         = case when rms.TRAINING_HRS_S is null and
                                     res2.TRAINING_HRS_S is null
                                then to_number(null)
                                else nvl(rms.TRAINING_HRS_S, 0) +
                                     nvl(res2.TRAINING_HRS_S, 0)
                                end,
        rms.UNASSIGNED_HRS_S
                         = case when rms.UNASSIGNED_HRS_S is null and
                                     res2.UNASSIGNED_HRS_S is null
                                then to_number(null)
                                else nvl(rms.UNASSIGNED_HRS_S, 0) +
                                     nvl(res2.UNASSIGNED_HRS_S, 0)
                                end,
        rms.REDUCIBLE_CAPACITY_HRS_S
                         = case when rms.REDUCIBLE_CAPACITY_HRS_S is null and
                                     res2.REDUCIBLE_CAPACITY_HRS_S is null
                                then to_number(null)
                                else nvl(rms.REDUCIBLE_CAPACITY_HRS_S, 0) +
                                     nvl(res2.REDUCIBLE_CAPACITY_HRS_S, 0)
                                end,
        rms.REDUCE_CAPACITY_HRS_S
                         = case when rms.REDUCE_CAPACITY_HRS_S is null and
                                     res2.REDUCE_CAPACITY_HRS_S is null
                                then to_number(null)
                                else nvl(rms.REDUCE_CAPACITY_HRS_S, 0) +
                                     nvl(res2.REDUCE_CAPACITY_HRS_S, 0)
                                end,
        rms.CONF_OVERCOM_HRS_S
                         = case when rms.CONF_OVERCOM_HRS_S is null and
                                     res2.CONF_OVERCOM_HRS_S is null
                                then to_number(null)
                                else nvl(rms.CONF_OVERCOM_HRS_S, 0) +
                                     nvl(res2.CONF_OVERCOM_HRS_S, 0)
                                end,
        rms.PROV_OVERCOM_HRS_S
                         = case when rms.PROV_OVERCOM_HRS_S is null and
                                     res2.PROV_OVERCOM_HRS_S is null
                                then to_number(null)
                                else nvl(rms.PROV_OVERCOM_HRS_S, 0) +
                                     nvl(res2.PROV_OVERCOM_HRS_S, 0)
                                end,
        rms.AVAILABLE_HRS_BKT1_S
                         = case when rms.AVAILABLE_HRS_BKT1_S is null and
                                     res2.AVAILABLE_HRS_BKT1_S is null
                                then to_number(null)
                                else nvl(rms.AVAILABLE_HRS_BKT1_S, 0) +
                                     nvl(res2.AVAILABLE_HRS_BKT1_S, 0)
                                end,
        rms.AVAILABLE_HRS_BKT2_S
                         = case when rms.AVAILABLE_HRS_BKT2_S is null and
                                     res2.AVAILABLE_HRS_BKT2_S is null
                                then to_number(null)
                                else nvl(rms.AVAILABLE_HRS_BKT2_S, 0) +
                                     nvl(res2.AVAILABLE_HRS_BKT2_S, 0)
                                end,
        rms.AVAILABLE_HRS_BKT3_S
                         = case when rms.AVAILABLE_HRS_BKT3_S is null and
                                     res2.AVAILABLE_HRS_BKT3_S is null
                                then to_number(null)
                                else nvl(rms.AVAILABLE_HRS_BKT3_S, 0) +
                                     nvl(res2.AVAILABLE_HRS_BKT3_S, 0)
                                end,
        rms.AVAILABLE_HRS_BKT4_S
                         = case when rms.AVAILABLE_HRS_BKT4_S is null and
                                     res2.AVAILABLE_HRS_BKT4_S is null
                                then to_number(null)
                                else nvl(rms.AVAILABLE_HRS_BKT4_S, 0) +
                                     nvl(res2.AVAILABLE_HRS_BKT4_S, 0)
                                end,
        rms.AVAILABLE_HRS_BKT5_S
                         = case when rms.AVAILABLE_HRS_BKT5_S is null and
                                     res2.AVAILABLE_HRS_BKT5_S is null
                                then to_number(null)
                                else nvl(rms.AVAILABLE_HRS_BKT5_S, 0) +
                                     nvl(res2.AVAILABLE_HRS_BKT5_S, 0)
                                end,
        rms.AVAILABLE_RES_COUNT_BKT1_S
                         = case when rms.AVAILABLE_RES_COUNT_BKT1_S is null and
                                     res2.AVAILABLE_RES_COUNT_BKT1_S is null
                                then to_number(null)
                                else nvl(rms.AVAILABLE_RES_COUNT_BKT1_S, 0) +
                                     nvl(res2.AVAILABLE_RES_COUNT_BKT1_S, 0)
                                end,
        rms.AVAILABLE_RES_COUNT_BKT2_S
                         = case when rms.AVAILABLE_RES_COUNT_BKT2_S is null and
                                     res2.AVAILABLE_RES_COUNT_BKT2_S is null
                                then to_number(null)
                                else nvl(rms.AVAILABLE_RES_COUNT_BKT2_S, 0) +
                                     nvl(res2.AVAILABLE_RES_COUNT_BKT2_S, 0)
                                end,
        rms.AVAILABLE_RES_COUNT_BKT3_S
                         = case when rms.AVAILABLE_RES_COUNT_BKT3_S is null and
                                     res2.AVAILABLE_RES_COUNT_BKT3_S is null
                                then to_number(null)
                                else nvl(rms.AVAILABLE_RES_COUNT_BKT3_S, 0) +
                                     nvl(res2.AVAILABLE_RES_COUNT_BKT3_S, 0)
                                end,
        rms.AVAILABLE_RES_COUNT_BKT4_S
                         = case when rms.AVAILABLE_RES_COUNT_BKT4_S is null and
                                     res2.AVAILABLE_RES_COUNT_BKT4_S is null
                                then to_number(null)
                                else nvl(rms.AVAILABLE_RES_COUNT_BKT4_S, 0) +
                                     nvl(res2.AVAILABLE_RES_COUNT_BKT4_S, 0)
                                end,
        rms.AVAILABLE_RES_COUNT_BKT5_S
                         = case when rms.AVAILABLE_RES_COUNT_BKT5_S is null and
                                     res2.AVAILABLE_RES_COUNT_BKT5_S is null
                                then to_number(null)
                                else nvl(rms.AVAILABLE_RES_COUNT_BKT5_S, 0) +
                                     nvl(res2.AVAILABLE_RES_COUNT_BKT5_S, 0)
                                end,
        rms.TOTAL_RES_COUNT
                         = case when rms.TOTAL_RES_COUNT is null and
                                     res2.TOTAL_RES_COUNT is null
                                then to_number(null)
                                else nvl(rms.TOTAL_RES_COUNT, 0) +
                                     nvl(res2.TOTAL_RES_COUNT, 0)
                                end,
        rms.LAST_UPDATE_DATE
            = res2.LAST_UPDATE_DATE,
        rms.LAST_UPDATED_BY
            = res2.LAST_UPDATED_BY,
        rms.LAST_UPDATE_LOGIN
            = res2.LAST_UPDATE_LOGIN
      when not matched then insert
      (
        rms.PERSON_ID,
        rms.EXPENDITURE_ORG_ID,
        rms.EXPENDITURE_ORGANIZATION_ID,
        rms.JOB_ID,
        rms.TIME_ID,
        rms.PERIOD_TYPE_ID,
        rms.CALENDAR_TYPE,
        rms.CAPACITY_HRS,
        rms.TOTAL_HRS_A,
        rms.MISSING_HRS_A,
        rms.TOTAL_WTD_ORG_HRS_A,
        rms.TOTAL_WTD_RES_HRS_A,
        rms.BILL_HRS_A,
        rms.BILL_WTD_ORG_HRS_A,
        rms.BILL_WTD_RES_HRS_A,
        rms.TRAINING_HRS_A,
        rms.UNASSIGNED_HRS_A,
        rms.REDUCIBLE_CAPACITY_HRS_A,
        rms.REDUCE_CAPACITY_HRS_A,
        rms.CONF_HRS_S,
        rms.CONF_WTD_ORG_HRS_S,
        rms.CONF_WTD_RES_HRS_S,
        rms.CONF_BILL_HRS_S,
        rms.CONF_BILL_WTD_ORG_HRS_S,
        rms.CONF_BILL_WTD_RES_HRS_S,
        rms.PROV_HRS_S,
        rms.PROV_WTD_ORG_HRS_S,
        rms.PROV_WTD_RES_HRS_S,
        rms.PROV_BILL_HRS_S,
        rms.PROV_BILL_WTD_ORG_HRS_S,
        rms.PROV_BILL_WTD_RES_HRS_S,
        rms.TRAINING_HRS_S,
        rms.UNASSIGNED_HRS_S,
        rms.REDUCIBLE_CAPACITY_HRS_S,
        rms.REDUCE_CAPACITY_HRS_S,
        rms.CONF_OVERCOM_HRS_S,
        rms.PROV_OVERCOM_HRS_S,
        rms.AVAILABLE_HRS_BKT1_S,
        rms.AVAILABLE_HRS_BKT2_S,
        rms.AVAILABLE_HRS_BKT3_S,
        rms.AVAILABLE_HRS_BKT4_S,
        rms.AVAILABLE_HRS_BKT5_S,
        rms.AVAILABLE_RES_COUNT_BKT1_S,
        rms.AVAILABLE_RES_COUNT_BKT2_S,
        rms.AVAILABLE_RES_COUNT_BKT3_S,
        rms.AVAILABLE_RES_COUNT_BKT4_S,
        rms.AVAILABLE_RES_COUNT_BKT5_S,
        rms.TOTAL_RES_COUNT,
        rms.LAST_UPDATE_DATE,
        rms.LAST_UPDATED_BY,
        rms.CREATION_DATE,
        rms.CREATED_BY,
        rms.LAST_UPDATE_LOGIN
      )
      values
      (
        res2.PERSON_ID,
        res2.EXPENDITURE_ORG_ID,
        res2.EXPENDITURE_ORGANIZATION_ID,
        res2.JOB_ID,
        res2.TIME_ID,
        res2.PERIOD_TYPE_ID,
        res2.CALENDAR_TYPE,
        res2.CAPACITY_HRS,
        res2.TOTAL_HRS_A,
        res2.MISSING_HRS_A,
        res2.TOTAL_WTD_ORG_HRS_A,
        res2.TOTAL_WTD_RES_HRS_A,
        res2.BILL_HRS_A,
        res2.BILL_WTD_ORG_HRS_A,
        res2.BILL_WTD_RES_HRS_A,
        res2.TRAINING_HRS_A,
        res2.UNASSIGNED_HRS_A,
        res2.REDUCIBLE_CAPACITY_HRS_A,
        res2.REDUCE_CAPACITY_HRS_A,
        res2.CONF_HRS_S,
        res2.CONF_WTD_ORG_HRS_S,
        res2.CONF_WTD_RES_HRS_S,
        res2.CONF_BILL_HRS_S,
        res2.CONF_BILL_WTD_ORG_HRS_S,
        res2.CONF_BILL_WTD_RES_HRS_S,
        res2.PROV_HRS_S,
        res2.PROV_WTD_ORG_HRS_S,
        res2.PROV_WTD_RES_HRS_S,
        res2.PROV_BILL_HRS_S,
        res2.PROV_BILL_WTD_ORG_HRS_S,
        res2.PROV_BILL_WTD_RES_HRS_S,
        res2.TRAINING_HRS_S,
        res2.UNASSIGNED_HRS_S,
        res2.REDUCIBLE_CAPACITY_HRS_S,
        res2.REDUCE_CAPACITY_HRS_S,
        res2.CONF_OVERCOM_HRS_S,
        res2.PROV_OVERCOM_HRS_S,
        res2.AVAILABLE_HRS_BKT1_S,
        res2.AVAILABLE_HRS_BKT2_S,
        res2.AVAILABLE_HRS_BKT3_S,
        res2.AVAILABLE_HRS_BKT4_S,
        res2.AVAILABLE_HRS_BKT5_S,
        res2.AVAILABLE_RES_COUNT_BKT1_S,
        res2.AVAILABLE_RES_COUNT_BKT2_S,
        res2.AVAILABLE_RES_COUNT_BKT3_S,
        res2.AVAILABLE_RES_COUNT_BKT4_S,
        res2.AVAILABLE_RES_COUNT_BKT5_S,
        res2.TOTAL_RES_COUNT,
        res2.LAST_UPDATE_DATE,
        res2.LAST_UPDATED_BY,
        res2.CREATION_DATE,
        res2.CREATED_BY,
        res2.LAST_UPDATE_LOGIN
      );

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
  'PJI_RM_SUM_ROLLUP_RES.MERGE_TMP2_INTO_RMS(p_worker_id);'
    );

    commit;

  end MERGE_TMP2_INTO_RMS;


  -- -----------------------------------------------------
  -- procedure CLEANUP_RMS
  -- -----------------------------------------------------
  procedure CLEANUP_RMS (p_worker_id in number) is

    l_process varchar2(30);

  begin

    l_process := PJI_RM_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
            (
              l_process,
          'PJI_RM_SUM_ROLLUP_RES.CLEANUP_RMS(p_worker_id);'
            )) then
      return;
    end if;

    delete
    from   PJI_RM_RES_F
    where  (PERSON_ID,
            EXPENDITURE_ORG_ID,
            EXPENDITURE_ORGANIZATION_ID,
            JOB_ID,
            TIME_ID,
            PERIOD_TYPE_ID,
            CALENDAR_TYPE) in
           (select /*+ parallel(res2) */
                   PERSON_ID,
                   EXPENDITURE_ORG_ID,
                   EXPENDITURE_ORGANIZATION_ID,
                   JOB_ID,
                   TIME_ID,
                   PERIOD_TYPE_ID,
                   CALENDAR_TYPE
            from   PJI_RM_AGGR_RES2 res2
            where  WORKER_ID = p_worker_id) and
           nvl(CAPACITY_HRS, 0)       = 0 and
           nvl(TOTAL_HRS_A, 0)        = 0 and
           nvl(BILL_HRS_A, 0)         = 0 and
           nvl(CONF_HRS_S, 0)         = 0 and
           nvl(PROV_HRS_S, 0)         = 0 and
           nvl(UNASSIGNED_HRS_S, 0)   = 0 and
           nvl(CONF_OVERCOM_HRS_S, 0) = 0 and
           nvl(PROV_OVERCOM_HRS_S, 0) = 0;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
      'PJI_RM_SUM_ROLLUP_RES.CLEANUP_RMS(p_worker_id);'
    );

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                     'PJI_RM_AGGR_RES2','NORMAL',null);

    commit;

  end CLEANUP_RMS;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_UTW
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_UTW (p_worker_id in number) is

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
    'PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_UTW(p_worker_id);'
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

    /* Stats gathered for this table in availability mview refresh.
    FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pji_schema,
                                 TABNAME => 'PJI_ORG_DENORM',
                                 PERCENT => 10,
                                 DEGREE  => l_p_degree);
    */

    if (l_extraction_type = 'FULL') then
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_RM_WT_F_MV',
                              'C',
                              'N');
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_RM_WTO_F_MV',
                              'C',
                              'N');
    else
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pji_schema,
                                   TABNAME => 'MLOG$_PJI_RM_RES_WT_F',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_RM_WT_F_MV',
                              'F',
                              'N');
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_apps_schema,
                                   TABNAME => 'MLOG$_PJI_RM_WT_F_MV',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_RM_WTO_F_MV',
                              'F',
                              'N');
    end if;

    if (l_extraction_type <> 'INCREMENTAL') then
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_RM_WT_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_RM_WTO_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_UTW(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_UTW;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_UTX
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_UTX (p_worker_id in number) is

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
    'PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_UTX(p_worker_id);'
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
                              'PJI_RM_ORG_F_MV',
                              'C',
                              'N');
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_RM_ORGO_F_MV',
                              'C',
                              'N');
    else
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_pji_schema,
                                   TABNAME => 'MLOG$_PJI_RM_RES_F',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_RM_ORG_F_MV',
                              'F',
                              'N');
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_apps_schema,
                                   TABNAME => 'MLOG$_PJI_RM_ORG_F_MV',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_RM_ORGO_F_MV',
                              'F',
                              'N');
    end if;

    if (l_extraction_type <> 'INCREMENTAL') then
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_RM_ORG_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_RM_ORGO_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_UTX(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_UTX;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_UTJ
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_UTJ (p_worker_id in number) is

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
    'PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_UTJ(p_worker_id);'
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
                              'PJI_RM_JOB_F_MV',
                              'C',
                              'N');
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_RM_JOBO_F_MV',
                              'C',
                              'N');
    else
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_RM_JOB_F_MV',
                              'F',
                              'N');
      FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_apps_schema,
                                   TABNAME => 'MLOG$_PJI_RM_JOB_F_MV',
                                   PERCENT => 10,
                                   DEGREE  => l_p_degree);
      PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                              l_retcode,
                              'PJI_RM_JOBO_F_MV',
                              'F',
                              'N');
    end if;

    if (l_extraction_type <> 'INCREMENTAL') then
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_RM_JOB_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_RM_JOBO_F_MV',
                                 percent => 10,
                                 degree  => l_p_degree);
    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_UTJ(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_UTJ;

  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_TIME
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_TIME (p_worker_id in number) is

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
    'PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_TIME(p_worker_id);'
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

    PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                            l_retcode,
                            'PJI_TIME_MV',
                            'C',
                            'N');

    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_TIME_MV',
                                 percent => 10,
                                 degree  => l_p_degree);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_TIME(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_TIME;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_TIME_DAY
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_TIME_DAY (p_worker_id in number) is

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
    'PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_TIME_DAY(p_worker_id);'
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

    PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                            l_retcode,
                            'PJI_TIME_DAY_MV',
                            'C',
                            'N');

    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_TIME_DAY_MV',
                                 percent => 10,
                                 degree  => l_p_degree);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_TIME_DAY(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_TIME_DAY;


  -- -----------------------------------------------------
  -- procedure REFRESH_MVIEW_TIME_TREND
  -- -----------------------------------------------------
  procedure REFRESH_MVIEW_TIME_TREND (p_worker_id in number) is

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
    'PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_TIME_TREND(p_worker_id);'
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

    PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(l_errbuf,
                            l_retcode,
                            'PJI_TIME_TREND_MV',
                            'C',
                            'N');

    FND_STATS.GATHER_TABLE_STATS(ownname => l_apps_schema,
                                 tabname => 'PJI_TIME_TREND_MV',
                                 percent => 10,
                                 degree  => l_p_degree);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (
      l_process,
    'PJI_RM_SUM_ROLLUP_RES.REFRESH_MVIEW_TIME_TREND(p_worker_id);'
    );

    commit;

  end REFRESH_MVIEW_TIME_TREND;


  -- -----------------------------------------------------
  -- procedure CLEANUP
  -- -----------------------------------------------------
  procedure CLEANUP (p_worker_id in number) is

    l_schema varchar2(30);

  begin

    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_RM_AGGR_RES1','NORMAL',null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_RM_AGGR_RES2','NORMAL',null);

  end CLEANUP;

end PJI_RM_SUM_ROLLUP_RES;

/
