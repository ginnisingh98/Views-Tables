--------------------------------------------------------
--  DDL for Package Body PJI_PJP_EXTRACTION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PJP_EXTRACTION_UTILS" as
  /* $Header: PJIUT06B.pls 120.9.12010000.8 2010/02/17 07:30:34 rmandali ship $ */

  g_worker_id number;

  -- -------------------------------------
  -- function SET_WORKER_ID
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -------------------------------------
  procedure SET_WORKER_ID (p_worker_id in number) is

    l_invalid_worker_id varchar2(255) := 'Partitioning worker ID is invalid.';

  begin

    if (p_worker_id < 1 or
        p_worker_id > PJI_PJP_SUM_MAIN.g_parallel_processes or
        p_worker_id <> trunc(p_worker_id)) then
      dbms_standard.raise_application_error(-20010, l_invalid_worker_id);
    end if;

    g_worker_id := p_worker_id;

  end SET_WORKER_ID;


  -- -------------------------------------
  -- function GET_WORKER_ID
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- External PJP Summarization API.
  --
  -- -------------------------------------
  function GET_WORKER_ID return number is

    l_no_worker_context varchar2(255) := 'Worker context does not exist.';

  begin

    if (g_worker_id is null) then
      dbms_standard.raise_application_error(-20020, l_no_worker_context);
    end if;

    return g_worker_id;

  end GET_WORKER_ID;


  -- -------------------------------------
  -- procedure UPDATE_EXTR_SCOPE
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -------------------------------------
  procedure UPDATE_EXTR_SCOPE is

    l_count             number;

    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;

  begin

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    select count(*)
    into   l_count
    from   PJI_PJP_PROJ_EXTR_STATUS
    where  ROWNUM = 1;

    if (l_count > 0) then

      insert into PA_PJI_PROJ_EVENTS_LOG
      (
        EVENT_TYPE,
        EVENT_ID,
        EVENT_OBJECT,
        OPERATION_TYPE,
        STATUS,
        ATTRIBUTE1,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select
        'PRG_CHANGE',
        PA_PJI_PROJ_EVENTS_LOG_S.NEXTVAL,
        -1,
        'I',
        'X',
        prj.PROJECT_ID,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PA_PROJECTS_ALL prj,
        PJI_PJP_PROJ_EXTR_STATUS pjp_status/*, Commented for bug 	8916168
        PJI_PROJ_EXTR_STATUS fm_status  Added for bug 8661279 */
      where
        prj.TEMPLATE_FLAG     = 'N' and
        prj.PROJECT_ID        = pjp_status.PROJECT_ID (+) and
        PA_PROJECT_UTILS.CHECK_PRJ_STUS_ACTION_ALLOWED
          (prj.PROJECT_STATUS_CODE, 'STATUS_REPORTING') = 'Y' and /* Added for bug 8916168 */
        /*prj.PROJECT_ID        = fm_status.PROJECT_ID      and   Added for bug 8661279 Commented for bug 	8916168 */
        pjp_status.PROJECT_ID is null
        and prj.project_type <> 'AWARD_PROJECT';      /* Added for Bug 6450518 */

      delete
      from   PJI_PJP_PROJ_EXTR_STATUS pjp
      where  not exists (select 1
                         from   PA_PROJECTS_ALL prj
                         where  prj.PROJECT_ID = pjp.PROJECT_ID);

      /* This delete statement is added so that data in PJI_PJP_PROJ_EXTR_STATUS
         is always in sync with data in PJI_PROJ_EXTR_STATUS.
         Code added for bug 6748705 starts **** Commented for bug 9034593 ****
      delete
      from   PJI_PJP_PROJ_EXTR_STATUS pjp
      where  not exists (select 1
                         from   PJI_PROJ_EXTR_STATUS prj
                         where  prj.PROJECT_ID = pjp.PROJECT_ID);
      /* Code added for bug 6748705 ends */

      update PJI_PJP_PROJ_EXTR_STATUS sts
      set    sts.PROJECT_ORGANIZATION_ID =
             (
             select prj.CARRYING_OUT_ORGANIZATION_ID
             from   PA_PROJECTS_ALL prj
             where  prj.PROJECT_ID = sts.PROJECT_ID
             )
      where  exists
             (
             select 1
             from   PA_PROJECTS_ALL prj
             where  prj.PROJECT_ID = sts.PROJECT_ID and
                    prj.CARRYING_OUT_ORGANIZATION_ID <>
                    sts.PROJECT_ORGANIZATION_ID
             );

      insert into PJI_PJP_PROJ_EXTR_STATUS
      (
        PROJECT_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_NAME,
        PROJECT_TYPE_CLASS,
        EXTRACTION_STATUS,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select
        prj.PROJECT_ID,
        prj.CARRYING_OUT_ORGANIZATION_ID PROJECT_ORGANIZATION_ID,
        'PJI$NULL'                       PROJECT_NAME,
        decode(pt.PROJECT_TYPE_CLASS_CODE,
               'CAPITAL',  'C',
               'CONTRACT', 'B',
               'INDIRECT', 'I')          PROJECT_TYPE_CLASS,
        'F'                              EXTRACTION_STATUS,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PA_PROJECTS_ALL          prj,
        PA_PROJECT_TYPES_ALL     pt,
        PJI_PJP_PROJ_EXTR_STATUs pjp_status/*, Commented for bug 	8916168
        PJI_PROJ_EXTR_STATUS     fm_status     Added for bug 6748705 */
      where
        prj.TEMPLATE_FLAG     = 'N'                       and
        prj.ORG_ID   = pt.ORG_ID                          and   /*5377131*/
        prj.PROJECT_TYPE      = pt.PROJECT_TYPE           and
        prj.PROJECT_ID        = pjp_status.PROJECT_ID (+) and
        PA_PROJECT_UTILS.CHECK_PRJ_STUS_ACTION_ALLOWED
          (prj.PROJECT_STATUS_CODE, 'STATUS_REPORTING') = 'Y' and /* Added for bug 8916168 */
        /*prj.PROJECT_ID        = fm_status.project_id      and    Added for bug 6748705 Commented for bug 	8916168 */
        pjp_status.PROJECT_ID is null
        and prj.project_type <> 'AWARD_PROJECT';      /* Added for Bug 6450518 */

    else

      delete
      from   PA_PJI_PROJ_EVENTS_LOG
      where  EVENT_TYPE in ('WBS_CHANGE',
                            'WBS_PUBLISH',
                            'PRG_CHANGE'
                         -- 'RBS_ASSOC',  The source system depends on
                         -- 'RBS_PRG',    updates from Project Performance
                         -- 'RBS_PUSH',   processing of these events, so
                         -- 'RBS_DELETE'  they must persist after truncate.
                            );

      insert into PA_PJI_PROJ_EVENTS_LOG
      (
        EVENT_TYPE,
        EVENT_ID,
        EVENT_OBJECT,
        OPERATION_TYPE,
        STATUS,
        ATTRIBUTE1,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select
        'PRG_CHANGE',
        PA_PJI_PROJ_EVENTS_LOG_S.NEXTVAL,
        -1,
        'I',
        'X',
        prj.PROJECT_ID,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PA_PROJECTS_ALL prj,
        PJI_PROJ_EXTR_STATUS     fm_status    /* Added for bug 8661279 */
      where
        prj.TEMPLATE_FLAG = 'N' and
        not exists (select 1
                    from   PA_XBS_DENORM den
                    where  den.STRUCT_TYPE = 'PRG' and
                           den.SUP_PROJECT_ID = prj.PROJECT_ID) /*and
        not exists (select 1
                    from   PA_PJI_PROJ_EVENTS_LOG log
                    where  log.EVENT_TYPE = 'PRG_CHANGE' and
                           log.EVENT_OBJECT = -1 and
                           log.ATTRIBUTE1 = prj.PROJECT_ID) Commented for bug 9340121 */
        and prj.PROJECT_ID = fm_status.project_id   /* Added for bug 8661279 */
        and prj.project_type <> 'AWARD_PROJECT';      /* Added for Bug 6450518 */

      insert into PJI_PJP_PROJ_EXTR_STATUS pjp_i
      (
        PROJECT_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_NAME,
        PROJECT_TYPE_CLASS,
        EXTRACTION_STATUS,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select
        prj.PROJECT_ID,
        prj.CARRYING_OUT_ORGANIZATION_ID PROJECT_ORGANIZATION_ID,
        'PJI$NULL'                       PROJECT_NAME,
        decode(pt.PROJECT_TYPE_CLASS_CODE,
               'CAPITAL',  'C',
               'CONTRACT', 'B',
               'INDIRECT', 'I')          PROJECT_TYPE_CLASS,
        'F'                              EXTRACTION_STATUS,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PA_PROJECTS_ALL prj,
        PA_PROJECT_TYPES_ALL pt,
        PJI_PROJ_EXTR_STATUS     fm_status    /* Added for bug 6748705 */
      where
        prj.TEMPLATE_FLAG   = 'N'                and
        prj.ORG_ID   = pt.ORG_ID                 and   /*5377131*/
        prj.PROJECT_ID      = fm_status.project_id and   /* Added for bug 6748705 */
        prj.PROJECT_TYPE    = pt.PROJECT_TYPE
        and prj.project_type <> 'AWARD_PROJECT';      /* Added for Bug 6450518 */

    end if;

  end UPDATE_EXTR_SCOPE;


  -- ----------------------------------------------------------
  -- procedure POPULATE_ORG_EXTR_INFO
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- ----------------------------------------------------------
  procedure POPULATE_ORG_EXTR_INFO is

  begin

    PJI_EXTRACTION_UTIL.POPULATE_ORG_EXTR_INFO;

  end POPULATE_ORG_EXTR_INFO;


  -- ----------------------------------------------------------
  -- procedure UPDATE_ORG_EXTR_INFO
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- ----------------------------------------------------------
  procedure UPDATE_ORG_EXTR_INFO is

  begin

    PJI_EXTRACTION_UTIL.UPDATE_ORG_EXTR_INFO;

  end UPDATE_ORG_EXTR_INFO;


  -- ------------------------------------------------------
  -- Procedure : SEED_PJI_PJP_STATS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------

  procedure SEED_PJI_PJP_STATS(p_worker_id in number) is

        l_high_rows     number;
        l_med_rows      number;
        l_low_rows      number;
        l_db_block_size number;
        l_high_blocks   number;
        l_med_blocks    number;
        l_low_blocks    number;

        l_pa_schema     varchar2(30);
        l_pji_schema    varchar2(30);
        l_degree        number;

  begin

    /*  This procedure sets statistics for all PJI_PJP intermediate tables
     *
     *  Presently this procedure sets statistics for only
     *  the first partition for partitioned tables since
     *  there will be only one worker for Phase I.  Later when
     *  this restriction is removed then the statistics need to
     *  be set for other partitions too.
     *
     *  The tables are divided into 3 broad categories: high medium and low
     *  The statistics seeded are based on 3 sets of parameters:
     *               Number of rows     Average row length
     *    High       batch_size         225
     *    Medium     batch_size/50      150
     *    Low        batch_size/150      75
     *
     *    Blocks = 1.5* (number of rows * average row length)/block size
     *
     *    A factor of 1.5 is assumed for row chaining into multiple blocks
     *
     */

    l_high_rows  := 100000000;
    l_med_rows   := l_high_rows/50;
    l_low_rows   := l_high_rows/150;

    select to_number(value)
    into   l_db_block_size
    from   v$parameter
    where  name = 'db_block_size';

    l_high_blocks := 1.25*(l_high_rows*225)/l_db_block_size;
    l_med_blocks  := 1.25*(l_med_rows*150)/l_db_block_size;
    l_low_blocks  := 1.25*(l_low_rows*75)/l_db_block_size;

    l_pa_schema   := PJI_UTILS.GET_PA_SCHEMA_NAME;
    l_pji_schema  := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    l_degree      := PJI_UTILS.GET_DEGREE_OF_PARALLELISM();

    -- partitioned tables
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_FP_AGGR_PJP0',         l_high_rows, l_high_blocks, 225, 'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_AC_AGGR_PJP0',         l_high_rows, l_high_blocks, 225, 'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_FP_CUST_PJP0',         l_high_rows, l_high_blocks, 225, 'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_AC_CUST_PJP0',         l_high_rows, l_high_blocks, 225, 'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_FP_AGGR_PJP1',         l_high_rows, l_high_blocks, 225, 'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_AC_AGGR_PJP1',         l_high_rows, l_high_blocks, 225, 'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_FP_AGGR_XBS',          l_med_rows,  l_med_blocks,  150, 'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_FP_AGGR_RBS',          l_med_rows,  l_med_blocks,  150, 'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_PJP_PROJ_BATCH_MAP',   l_med_rows,  l_med_blocks,  150, 'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_XBS_DENORM_DELTA',     l_low_rows,  l_low_blocks,  75,  'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_RBS_DENORM_DELTA',     l_low_rows,  l_low_blocks,  75,  'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_PA_PROJ_EVENTS_LOG',   l_low_rows,  l_low_blocks,  75,  'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_FP_RMAP_FPR',          l_low_rows,  l_low_blocks,  75,  'P' || p_worker_id);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_AC_RMAP_ACR',          l_low_rows,  l_low_blocks,  75,  'P' || p_worker_id);

    -- non-partitioned tables
    FND_STATS.SET_TABLE_STATS(l_pa_schema,  'PA_RBS_TXN_ACCUM_MAP',     l_med_rows,  l_med_blocks,  150);
    FND_STATS.SET_TABLE_STATS(l_pji_schema, 'PJI_PJP_PROJ_EXTR_STATUS', l_med_rows,  l_med_blocks,  150);

    -- gather statistics for PJI metadata tables
    FND_STATS.GATHER_TABLE_STATS(ownname => l_pji_schema,
                                 tabname => 'PJI_PJP_PROJ_EXTR_STATUS',
                                 percent => 10,
                                 degree  => l_degree);

    commit;

  end SEED_PJI_PJP_STATS;


  -- ------------------------------------------------------
  -- procedure ANALYZE_PJP_FACTS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- ------------------------------------------------------
  procedure ANALYZE_PJP_FACTS is

    l_pa_schema  varchar2(30);
    l_pji_schema varchar2(30);
    l_degree     number;

  begin

    l_pa_schema  := PJI_UTILS.GET_PA_SCHEMA_NAME;
    l_pji_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    l_degree     := PJI_UTILS.GET_DEGREE_OF_PARALLELISM;

    FND_STATS.GATHER_TABLE_STATS(ownname => l_pji_schema,
                                 tabname => 'PJI_FP_XBS_ACCUM_F',
                                 percent => 10,
                                 degree  => l_degree);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_pji_schema,
                                 tabname => 'PJI_AC_XBS_ACCUM_F',
                                 percent => 10,
                                 degree  => l_degree);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_pa_schema,
                                 tabname => 'PA_XBS_DENORM',
                                 percent => 10,
                                 degree  => l_degree);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_pji_schema,
                                 tabname => 'PJI_XBS_DENORM',
                                 percent => 10,
                                 degree  => l_degree);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_pa_schema,
                                 tabname => 'PA_RBS_DENORM',
                                 percent => 10,
                                 degree  => l_degree);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_pji_schema,
                                 tabname => 'PJI_RBS_DENORM',
                                 percent => 10,
                                 degree  => l_degree);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_pji_schema,
                                 tabname => 'PJI_PJP_WBS_HEADER',
                                 percent => 10,
                                 degree  => l_degree);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_pji_schema,
                                 tabname => 'PJI_PJP_RBS_HEADER',
                                 percent => 10,
                                 degree  => l_degree);

    commit;

  end ANALYZE_PJP_FACTS;


  -- -----------------------------------------------------
  -- procedure TRUNCATE_PJP_TABLES
  --
  --  This procedure resets the summarization process by
  --  truncating all PJI stage 3 summarization tables.
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure TRUNCATE_PJP_TABLES
  (
    errbuf        out nocopy varchar2,
    retcode       out nocopy varchar2,
    p_check       in         varchar2 default 'N',
    p_fpm_upgrade in         varchar2 default 'Y',
    p_recover     in         varchar2 default 'N'
  ) is

    l_profile_check varchar2(30);
    l_pji_schema    varchar2(30);
    l_pa_schema     varchar2(30);
    l_fpm_upgrade   varchar2(100);
    l_return_status varchar2(1);
    l_msg_count     number;
    l_msg_data      varchar2(2000);
    l_sqlerrm       varchar2(240);

  begin

    FND_MESSAGE.SET_NAME('PJI', 'PJI_SUM_CLEANALL_FAILED');

    if (upper(nvl(p_check, 'N')) <> 'Y') then
      pji_utils.write2out(FND_MESSAGE.GET);
      commit;
      retcode := 1;
      return;
    end if;
    /* starts here bug#5414276 , this code is moved out of the profile value check
       as it should work for only FPM upgrade recovery also                  */
    insert into PJI_SYSTEM_CONFIG_HIST
    (
      REQUEST_ID,
      USER_NAME,
      PROCESS_NAME,
      RUN_TYPE,
      PARAMETERS,
      CONFIG_PROJ_PERF_FLAG,
      CONFIG_COST_FLAG,
      CONFIG_PROFIT_FLAG,
      CONFIG_UTIL_FLAG,
      START_DATE,
      END_DATE,
      COMPLETION_TEXT
    )
    select
      FND_GLOBAL.CONC_REQUEST_ID                         REQUEST_ID,
      substr(FND_GLOBAL.USER_NAME, 1, 10)                USER_NAME,
      'STAGE3'                                           PROCESS_NAME,
      'CLEANALL'                                         RUN_TYPE,
      substr(p_check || ', ' ||
             p_fpm_upgrade || ', ' ||
             p_recover, 1, 240)                          PARAMETERS,
      null                                               CONFIG_PROJ_PERF_FLAG,
      null                                               CONFIG_COST_FLAG,
      null                                               CONFIG_PROFIT_FLAG,
      null                                               CONFIG_UTIL_FLAG,
      sysdate                                            START_DATE,
      null                                               END_DATE,
      null                                               COMPLETION_TEXT
    from
      dual;


    l_profile_check := FND_PROFILE.VALUE('PJI_SUM_CLEANALL');

    if (upper(nvl(l_profile_check, 'N')) = 'Y') then

    update FND_PROFILE_OPTION_VALUES
    set    PROFILE_OPTION_VALUE = 'N'
    where  APPLICATION_ID = 1292 and
           -- LEVEL_ID = 10001 and
           PROFILE_OPTION_ID in
           (select PROFILE_OPTION_ID
            from   FND_PROFILE_OPTIONS
            where  APPLICATION_ID = 1292 and
                   PROFILE_OPTION_NAME = 'PJI_SUM_CLEANALL');

    commit;

    l_pji_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
    l_pa_schema := PJI_UTILS.GET_PA_SCHEMA_NAME;



    -- PJP summarization tables with persistent data
    delete from PJI_MT_PRC_STEPS       where PROCESS_NAME like (PJI_PJP_SUM_MAIN.g_process || '%');
    delete from PJI_SYSTEM_PARAMETERS  where NAME         like (PJI_PJP_SUM_MAIN.g_process || '%$%') or
                                             NAME         like 'PJI_FPM_UPGRADE' or
                                             NAME         like 'PJI_PTC_UPGRADE' or    /*4882640 */
                                             NAME         like 'PJP_FPM_UPGRADE_DATE' or
                                             NAME         like 'LAST_PJP_EXTR_DATE%';
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJP_PROJ_EXTR_STATUS',  'NORMAL', null);

    -- PJP facts
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_XBS_ACCUM_F',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_AC_XBS_ACCUM_F',        'NORMAL', null);

    -- PJP intermediate summarization tables
    delete from PJI_SYSTEM_PRC_STATUS where PROCESS_NAME like (PJI_PJP_SUM_MAIN.g_process || '%');
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJP_PROJ_BATCH_MAP',    'NORMAL', null);
    delete from PA_PJI_PROJ_EVENTS_LOG where event_type = 'PLANTYPE_UPG';  /*4882640 */
    -------------------

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_AGGR_XBS',           'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pa_schema,  'PA_XBS_DENORM',             'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_XBS_DENORM',            'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_XBS_DENORM_DELTA',      'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_AGGR_RBS',           'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pa_schema,  'PA_RBS_DENORM',             'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RBS_DENORM',            'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RBS_DENORM_DELTA',      'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pa_schema,  'PA_RBS_TXN_ACCUM_MAP',      'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_RES_TYPES',     'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJP_PROJ_EXTR_STATUS',  'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJP_PROJ_BATCH_MAP',    'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PA_PROJ_EVENTS_LOG',    'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_AGGR_PJP0',          'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_AC_AGGR_PJP0',          'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_CUST_PJP0',          'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_AC_CUST_PJP0',          'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_AGGR_PJP1',          'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_AC_AGGR_PJP1',          'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJP_RBS_HEADER',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJP_WBS_HEADER',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJP_RMAP_FPR',          'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_RMAP_FPR',           'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJP_RMAP_ACR',          'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_AC_RMAP_ACR',           'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_TIME_WEEK',             'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_TIME_RPT_STRUCT',       'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_TIME_ENT_PERIOD',       'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_TIME_ENT_QTR',          'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_TIME_ENT_YEAR',         'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_TIME_CAL_EXTR_INFO',    'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_TIME_CAL_PERIOD',       'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_TIME_CAL_QTR',          'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_TIME_CAL_RPT_STRUCT',   'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_TIME_CAL_YEAR',         'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_REP_XBS_DENORM',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_ROLLUP_LEVEL_STATUS',   'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_FIN8',          'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_EXTR_PLNVER4',       'NORMAL', null);

    commit;

    end if;

    l_fpm_upgrade := nvl(PJI_UTILS.GET_PARAMETER('PJI_FPM_UPGRADE'), 'X');

    if (p_fpm_upgrade = 'Y' and l_fpm_upgrade <> 'C') then

      PJI_FM_PLAN_MAINT.CREATE_PRIMARY_UPGRD_PVT(p_context => 'TRUNCATE');

    end if;

    update PJI_SYSTEM_CONFIG_HIST
    set    END_DATE = sysdate,
           COMPLETION_TEXT = 'Normal completion'
    where  PROCESS_NAME = 'STAGE3' and
           END_DATE is null;

    commit;

    retcode := 0;

    exception when others then

      rollback;

      l_sqlerrm := substr(sqlerrm, 1, 240);
      /* starts here bug#5414276 , if the program failed this is showing completed
      successfully in the SRS, retcode=2 will make sure it shows Error */

      retcode := 2;
      errbuf := l_sqlerrm;
     /* ends here bug#5414276 */
      update PJI_SYSTEM_CONFIG_HIST
      set    END_DATE = sysdate,
             COMPLETION_TEXT = l_sqlerrm
      where  PROCESS_NAME = 'STAGE3' and
             END_DATE is null;

      commit;

      raise;

  end TRUNCATE_PJP_TABLES;


  -- -----------------------------------------------------
  -- function LAST_PJP_EXTR_DATE
  --
  --   History
  --   26-MAY-2004  SVERMETT  Created
  --
  -- External PJP Summarization API.
  --
  -- -----------------------------------------------------

  function LAST_PJP_EXTR_DATE( p_project_id IN number DEFAULT null) return date is

    l_last_proj_extr_date date;

  begin

    select trunc(last_update_date)
    into   l_last_proj_extr_date
    from   PJI_PJP_PROJ_EXTR_STATUS
    where  project_id = p_project_id ;

    return l_last_proj_extr_date;

    exception when no_data_found then

    return null;

  end LAST_PJP_EXTR_DATE;

end PJI_PJP_EXTRACTION_UTILS;

/
