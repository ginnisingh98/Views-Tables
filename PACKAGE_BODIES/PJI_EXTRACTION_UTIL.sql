--------------------------------------------------------
--  DDL for Package Body PJI_EXTRACTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_EXTRACTION_UTIL" as
  /* $Header: PJIUT02B.pls 120.9.12010000.6 2010/03/04 07:03:23 dbudhwar ship $ */

  g_wh_db_link                 varchar2(128);
  g_src_db_link                varchar2(128);
  g_ent_period_refresh_flag    boolean := FALSE;

  -- -------------------------------------
  -- procedure UPDATE_EXTR_SCOPE
  -- -------------------------------------
  procedure UPDATE_EXTR_SCOPE is

    l_extr_start_date   date;
    Cursor csr_purge_projs is
	select prj.project_id, sts.project_system_status_code
	from   pa_projects_all        prj
		   , pa_project_statuses  sts
    where  prj.project_status_code = sts.project_status_code
	and    sts.project_system_status_code in ('PARTIALLY_PURGED'
											 ,'PURGED'
											 ,'PENDING_PURGE')
	;

	rec_purge_projs csr_purge_projs%ROWTYPE;

    l_row_count number;

  begin

    select count(*)
    into   l_row_count
    from   PJI_PROJ_EXTR_STATUS
    where  ROWNUM = 1;

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process,
                                               'TRANSITION') = 'Y' and
        l_row_count <> 0) then
      return;
    end if;

    -- Delete all events for new and deleted projects as well as changes
    -- in organization all of which are handled without the log table.
    delete
    from   PA_PJI_PROJ_EVENTS_LOG
    where  EVENT_TYPE = 'Projects';

    l_extr_start_date := PJI_UTILS.GET_EXTRACTION_START_DATE;

    if (PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE') is not null and
        trunc(l_extr_start_date, 'J') <>
        trunc(to_date(PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE'),
                      PJI_FM_SUM_MAIN.g_date_mask), 'J')) then
      pji_utils.write2log('WARNING: Global start date has changed.');
    end if;

    -- Delete from PJI_PROJ_EXTR_STATUS those projects deleted from
    -- PA_PROJECTS_ALL.  Note that a project cannot be deleted if it has any
    -- actuals transactions, so we don't need to worry about purging data from
    -- PJI facts.

    delete
    from   PJI_PROJ_EXTR_STATUS pji
    where  not exists (select 1
                       from   PA_PROJECTS_ALL pa
                       where  pa.PROJECT_ID = pji.PROJECT_ID);

    insert into PJI_PROJ_EXTR_STATUS
    (
      PROJECT_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_NAME,
      LAST_UPDATE_DATE,
      CREATION_DATE,
      PURGE_STATUS,
      PROJECT_TYPE_CLASS
    )
    select
      prj.PROJECT_ID,
      prj.CARRYING_OUT_ORGANIZATION_ID,
      'PJI$NULL',
      sysdate,
      sysdate,
      sts.PROJECT_SYSTEM_STATUS_CODE,
      DECODE(pt.PROJECT_TYPE_CLASS_CODE,
             'CAPITAL',  'C',
             'CONTRACT', 'B',
             'INDIRECT', 'I')
    from
      PA_PROJECTS_ALL      prj,
      PA_PROJECT_STATUSES  sts,
      PA_PROJECT_TYPES_ALL pt,
      (
      select
        PROJECT_STATUS_CODE
      from
        (
        select /*+ index_ffs(prj, PA_PROJECTS_N4)
                   parallel_index(prj, PA_PROJECTS_N4) */
          distinct
          prj.PROJECT_STATUS_CODE
        from
          PA_PROJECTS_ALL prj
        )
      where
        PA_PROJECT_UTILS.CHECK_PRJ_STUS_ACTION_ALLOWED
          (PROJECT_STATUS_CODE, 'STATUS_REPORTING') = 'Y'
      ) psc
    where
      nvl(closed_date,l_extr_start_date) >= l_extr_start_date and
      prj.project_status_code = psc.project_status_code and
      not exists
      (
        select 1
        from   PJI_PROJ_EXTR_STATUS ps
        where  ps.PROJECT_ID = prj.PROJECT_ID
      ) and
      prj.project_status_code = sts.project_status_code and
      nvl(prj.ORG_ID, -1)     = nvl(pt.ORG_ID, -1)      and
      prj.PROJECT_TYPE        = pt.PROJECT_TYPE
        and prj.project_type <> 'AWARD_PROJECT';      /* Added for Bug 6450518 */


--    Some existing project might have got archived/purged since the last run. These
--    projects need to be updated, they should not be included in the current run.

	  For rec_purge_projs in csr_purge_projs LOOP

          update PJI_PROJ_EXTR_STATUS  extr
     	  set    extr.purge_status = rec_purge_projs.project_system_status_code
		  where  extr.project_id = rec_purge_projs.project_id
	      and    NVL(extr.purge_status, 'X') not in ('PARTIALLY_PURGED'
									        		 ,'PURGED'
										        	 ,'PENDING_PURGE')
		  ;

	  End LOOP;

  end UPDATE_EXTR_SCOPE;


  -- ----------------------------------------------------------
  -- procedure POPULATE_ORG_EXTR_INFO
  -- ----------------------------------------------------------
  procedure POPULATE_ORG_EXTR_INFO is

  begin

    UPDATE_ORG_EXTR_INFO; -- PJI_ORG_EXTR_INFO always maintained incrementally

  end POPULATE_ORG_EXTR_INFO;


  -- ----------------------------------------------------------
  -- procedure UPDATE_ORG_EXTR_INFO
  -- ----------------------------------------------------------
  procedure UPDATE_ORG_EXTR_INFO is

    pragma AUTONOMOUS_TRANSACTION;

    l_ent_cal_min_date number;
    l_ent_cal_max_date number;

  begin

    begin

      select
        to_number(to_char(min(START_DATE), 'J')),
        to_number(to_char(max(END_DATE), 'J'))
      into
        l_ent_cal_min_date,
        l_ent_cal_max_date
      from
        PJI_TIME_ENT_PERIOD_V;

      exception when no_data_found then null;

    end;

    insert into PJI_ORG_EXTR_INFO
    (
      ORG_ID,
      PF_CURRENCY_CODE,
      EN_CALENDAR_MIN_DATE,
      EN_CALENDAR_MAX_DATE,
      GL_CALENDAR_ID,
      GL_CALENDAR_MIN_DATE,
      GL_CALENDAR_MAX_DATE,
      PA_CALENDAR_ID,
      PA_CALENDAR_MIN_DATE,
      PA_CALENDAR_MAX_DATE
    )
    select
      -1,              -- -1 can be a valid operating unit when a row
      'PJI$NULL',      --   is only a receiver row or only a provider
      to_number(null), --   row.  When a row applies to both receiver
      to_number(null), --   and provider, ord_id will never be -1.
      to_number(null),
      to_number(null), -- Added to_number for bug 3621077
      to_number(null),
      to_number(null),
      to_number(null),
      to_number(null)
    from
      dual
    where
      not exists (select ORG_ID
                  from   PA_IMPLEMENTATIONS_ALL
                  where  ORG_ID is null) and
      -1 not in (select ORG_ID
                 from   PJI_ORG_EXTR_INFO)
    union all
    select
      nvl(imp.ORG_ID,-1)  ORG_ID,
      to_char(null),
      to_number(null),
      to_number(null),
      to_number(null),
      to_number(null),
      to_number(null),
      to_number(null),
      to_number(null),
      to_number(null)
    from
      PA_IMPLEMENTATIONS_ALL imp
    where
      imp.ORG_ID not in (select ORG_ID
                         from   PJI_ORG_EXTR_INFO);

    update PJI_ORG_EXTR_INFO info
    set (PF_CURRENCY_CODE,
         EN_CALENDAR_MIN_DATE,
         EN_CALENDAR_MAX_DATE,
         GL_CALENDAR_ID,
         GL_CALENDAR_MIN_DATE,
         GL_CALENDAR_MAX_DATE,
         PA_CALENDAR_ID,
         PA_CALENDAR_MIN_DATE,
         PA_CALENDAR_MAX_DATE) =
        (select
           gl.CURRENCY_CODE,
           l_ent_cal_min_date,
           l_ent_cal_max_date,
           gl.CALENDAR_ID,
           to_number(to_char(gl.START_DATE, 'J')),
           to_number(to_char(gl.END_DATE, 'J')),
           pa.CALENDAR_ID,
           to_number(to_char(pa.START_DATE, 'J')),
           to_number(to_char(pa.END_DATE, 'J'))
         from
           (
           select
             nvl(imp.ORG_ID,-1)  ORG_ID,
             sob.CURRENCY_CODE,
             min(glp.START_DATE) START_DATE,
             max(glp.END_DATE)   END_DATE,
             fii.CALENDAR_ID
           from
             PA_IMPLEMENTATIONS_ALL imp,
             GL_SETS_OF_BOOKS       sob,
             GL_PERIODS             glp,
             FII_TIME_CAL_NAME      fii
           where
             imp.SET_OF_BOOKS_ID       = sob.SET_OF_BOOKS_ID and
             sob.PERIOD_SET_NAME       = glp.PERIOD_SET_NAME and
             sob.ACCOUNTED_PERIOD_TYPE = glp.PERIOD_TYPE     and
             fii.PERIOD_SET_NAME       = glp.PERIOD_SET_NAME and
             fii.PERIOD_TYPE           = glp.PERIOD_TYPE
           group by
             nvl(imp.ORG_ID,-1),
             sob.CURRENCY_CODE,
             fii.CALENDAR_ID
           ) gl,
           (
           select
             nvl(imp.ORG_ID,-1)  ORG_ID,
             min(glp.START_DATE) START_DATE,
             max(glp.END_DATE)   END_DATE,
             fii.CALENDAR_ID
           from
             PA_IMPLEMENTATIONS_ALL imp,
             GL_PERIODS             glp,
             FII_TIME_CAL_NAME      fii
           where
             imp.PA_PERIOD_TYPE  = glp.PERIOD_TYPE     and
             imp.PERIOD_SET_NAME = glp.PERIOD_SET_NAME and
             fii.PERIOD_SET_NAME = glp.PERIOD_SET_NAME and
             fii.PERIOD_TYPE     = glp.PERIOD_TYPE
           group by
             nvl(imp.ORG_ID,-1),
             fii.CALENDAR_ID
           ) pa
         where
           gl.ORG_ID = pa.ORG_ID and
           gl.ORG_ID = info.ORG_ID)
    where
      (nvl(ORG_ID,                   -1),
       nvl(PF_CURRENCY_CODE, 'PJI$NULL1'),
       nvl(EN_CALENDAR_MIN_DATE,      1),
       nvl(EN_CALENDAR_MAX_DATE,      1),
       nvl(GL_CALENDAR_ID,           -1),
       nvl(GL_CALENDAR_MIN_DATE,      1),
       nvl(GL_CALENDAR_MAX_DATE,      1),
       nvl(PA_CALENDAR_ID,           -1),
       nvl(PA_CALENDAR_MIN_DATE,      1),
       nvl(PA_CALENDAR_MAX_DATE,      1)) not in
      (select
         nvl(gl.ORG_ID,                              -1),
         nvl(gl.CURRENCY_CODE,               'PJI$NULL2'),
         nvl(l_ent_cal_min_date,                      2),
         nvl(l_ent_cal_max_date,                      2),
         nvl(gl.CALENDAR_ID,                         -2),
         nvl(to_number(to_char(gl.START_DATE, 'J')),  2),
         nvl(to_number(to_char(gl.END_DATE, 'J')),    2),
         nvl(pa.CALENDAR_ID,                         -2),
         nvl(to_number(to_char(pa.START_DATE, 'J')),  2),
         nvl(to_number(to_char(pa.END_DATE, 'J')),    2)
       from
         (
         select
           nvl(imp.ORG_ID,-1)  ORG_ID,
           sob.CURRENCY_CODE,
           min(glp.START_DATE) START_DATE,
           max(glp.END_DATE)   END_DATE,
           fii.CALENDAR_ID
         from
           PA_IMPLEMENTATIONS_ALL imp,
           GL_SETS_OF_BOOKS       sob,
           GL_PERIODS             glp,
           FII_TIME_CAL_NAME      fii
         where
           imp.SET_OF_BOOKS_ID       = sob.SET_OF_BOOKS_ID and
           sob.PERIOD_SET_NAME       = glp.PERIOD_SET_NAME and
           sob.ACCOUNTED_PERIOD_TYPE = glp.PERIOD_TYPE     and
           fii.PERIOD_SET_NAME       = glp.PERIOD_SET_NAME and
           fii.PERIOD_TYPE           = glp.PERIOD_TYPE
         group by
           nvl(imp.ORG_ID,-1),
           sob.CURRENCY_CODE,
           fii.CALENDAR_ID
         ) gl,
         (
         select
           nvl(imp.ORG_ID,-1)  ORG_ID,
           min(glp.START_DATE) START_DATE,
           max(glp.END_DATE)   END_DATE,
           fii.CALENDAR_ID
         from
           PA_IMPLEMENTATIONS_ALL imp,
           GL_PERIODS             glp,
           FII_TIME_CAL_NAME      fii
         where
           imp.PA_PERIOD_TYPE  = glp.PERIOD_TYPE     and
           imp.PERIOD_SET_NAME = glp.PERIOD_SET_NAME and
           fii.PERIOD_SET_NAME = glp.PERIOD_SET_NAME and
           fii.PERIOD_TYPE     = glp.PERIOD_TYPE
         group by
           nvl(imp.ORG_ID,-1),
           fii.CALENDAR_ID
         ) pa
       where
         gl.ORG_ID = pa.ORG_ID and
         gl.ORG_ID = info.ORG_ID);

    update PJI_ORG_EXTR_INFO
    set    PF_CURRENCY_CODE = 'PJI$NULL'
    where  ORG_ID = -1 and
           nvl(PF_CURRENCY_CODE, 'x') <> 'PJI$NULL';

    update PJI_ORG_EXTR_INFO
    set    EN_CALENDAR_MIN_DATE = l_ent_cal_min_date,
           EN_CALENDAR_MAX_DATE = l_ent_cal_max_date
    where  ORG_ID <> -1 and
           (nvl(EN_CALENDAR_MIN_DATE, 1) <> l_ent_cal_min_date or
            nvl(EN_CALENDAR_MAX_DATE, 1) <> l_ent_cal_max_date);

    commit; -- we can commit since transaction is autonomous

  end UPDATE_ORG_EXTR_INFO;


/* ------------------------------------------------------
   Procedure : SEED_PJI_FM_STATS
   -----------------------------------------------------*/

PROCEDURE SEED_PJI_FM_STATS IS

        l_high_rows           number;
        l_med_rows            number;
        l_low_rows            number;
        l_db_block_size       number;
        l_high_blocks         number;
        l_med_blocks          number;
        l_low_blocks          number;

        l_schema              varchar2(30);
        l_degree              number;

BEGIN
    /*  This procedure sets statistics for all PJI_FM intermediate tables
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


     l_high_rows  := GET_BATCH_SIZE;
     l_med_rows   := l_high_rows/50;
     l_low_rows   := l_high_rows/150;

	 select to_number(value)
	 into   l_db_block_size
	 from   v$parameter
	 where  name = 'db_block_size'
	 ;

     l_high_blocks  := 1.25*(l_high_rows*225)/l_db_block_size;
     l_med_blocks   := 1.25*(l_med_rows*150)/l_db_block_size;
     l_low_blocks   := 1.25*(l_low_rows*75)/l_db_block_size;


     l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
     l_degree := PJI_UTILS.GET_DEGREE_OF_PARALLELISM();

--  non-partitioned tables
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_AGGR_ACT1'   , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_AGGR_ACT2'   , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_AGGR_ACT4'   , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_AGGR_FIN1'   , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_AGGR_FIN2'   , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_AGGR_DLY_RATES', l_low_rows,  l_low_blocks,   75);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_EXTR_ARINV'         , l_med_rows,  l_med_blocks,  150);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_EXTR_DINVC'       , l_med_rows,  l_med_blocks,  150);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_EXTR_DINVCITM'   , l_med_rows,  l_med_blocks,  150);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_EXTR_DREVN'       , l_med_rows,  l_med_blocks,  150);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_EXTR_FUNDG'        , l_med_rows,  l_med_blocks,  150);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_REXT_CDL'       , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_REXT_CRDL'      , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_REXT_ERDL'      , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_PROJ_BATCH_MAP'  , l_low_rows,  l_low_blocks,   75);

--  gather statistics for PJI metadata tables
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_PROJ_EXTR_STATUS'
                      , percent  =>  10
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_INDEX_STATS(ownname => l_schema,
                                         indname => 'PJI_PROJ_EXTR_STATUS_U1',
                                         percent => 10);
-- Commenting this because the table is used in Stage2 Summarization . Bug#4997700
/*            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_PROJECT_CLASSES'
                      , percent  =>  10
                      , degree   =>  l_degree
                      ); */
            FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                         tabname => 'PJI_FM_PROJ_BATCH_MAP',
                                         percent => 10,
                                         degree  => l_degree);
            FND_STATS.GATHER_COLUMN_STATS(ownname => l_schema,
                                          tabname => 'PJI_FM_PROJ_BATCH_MAP',
                                          colname => 'EXTRACTION_TYPE',
                                          percent => 10,
                                          degree  => l_degree);
            FND_STATS.GATHER_INDEX_STATS(ownname => l_schema,
                                         indname => 'PJI_FM_PROJ_BATCH_MAP_U1',
                                         percent => 10);

END SEED_PJI_FM_STATS;


  -- -----------------------------------------------------
  -- procedure TRUNCATE_PJI_TABLES
  --
  --  This procedure resets the summarization process by
  --  truncating all PJI stage 1 summarization tables.
  --
  -- -----------------------------------------------------
  procedure TRUNCATE_PJI_TABLES
  (
    errbuf                out nocopy varchar2,
    retcode               out nocopy varchar2,
    p_check               in         varchar2 default 'N',
    p_truncate_pji_tables in         varchar2 default 'Y',
    p_truncate_pjp_tables in         varchar2 default 'Y',
    p_run_fpm_upgrade     in         varchar2 default 'N'
  ) is

    l_profile_check varchar2(30);
    l_pji_schema    varchar2(30);
    l_sqlerrm       varchar2(240);
    l_last_update_date  date;
    l_last_updated_by   number;
    l_last_update_login number;

  begin

    l_profile_check := FND_PROFILE.VALUE('PJI_SUM_CLEANALL');

    FND_MESSAGE.SET_NAME('PJI', 'PJI_SUM_CLEANALL_FAILED');

    if (upper(nvl(l_profile_check, 'N')) <> 'Y') then
      pji_utils.write2out(FND_MESSAGE.GET);
      commit;
      retcode := 1;
      return;
    end if;

    if (upper(nvl(p_check, 'N')) <> 'Y') then
      pji_utils.write2out(FND_MESSAGE.GET);
      commit;
      retcode := 1;
      return;
    end if;

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

    -- PJI summarization tables with persistent data
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_MT_PRC_STEPS',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_SYSTEM_CONFIG_HIST',  'NORMAL', null);
    delete from PJI_SYSTEM_PARAMETERS where NAME not in ('PJI_PJP_ENT_CURR_REP_PERIOD');
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PROJ_EXTR_STATUS',    'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_SYSTEM_DEBUG_MSG',    'NORMAL', null);

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
      'STAGE1'                                           PROCESS_NAME,
      'CLEANALL'                                         RUN_TYPE,
      substr(p_check || ', ' ||
             p_truncate_pji_tables || ', ' ||
             p_truncate_pjp_tables || ', ' ||
             p_run_fpm_upgrade, 1, 240)                  PARAMETERS,
      null                                               CONFIG_PROJ_PERF_FLAG,
      null                                               CONFIG_COST_FLAG,
      null                                               CONFIG_PROFIT_FLAG,
      null                                               CONFIG_UTIL_FLAG,
      sysdate                                            START_DATE,
      null                                               END_DATE,
      null                                               COMPLETION_TEXT
    from
      dual;

    -- PJI intermediate summarization tables
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_SYSTEM_PRC_STATUS',   'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_HELPER_BATCH_MAP',    'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_PROJ_BATCH_MAP',   'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_EXTR_DREVN',       'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_EXTR_DINVC',       'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_EXTR_DINVCITM',    'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_EXTR_ARINV',       'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_EXTR_FUNDG',       'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_DLY_RATES',   'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_REXT_CDL',         'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_REXT_CRDL',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_REXT_ERDL',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_DNGL_FIN',         'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_FIN1',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_FIN2',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_FIN6',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_DNGL_ACT',         'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_ACT1',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_ACT2',        'NORMAL', null);

    -- Staging Tables

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_AGGR_RES6',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_FIN9',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_ACT5',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_TXN_ACCUM_HEADER', 'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_FIN7',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_TXN_ACCUM',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_TXN_ACCUM1',       'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_PJI_CMT',          'NORMAL', null); /* Added for bug 9317177 */
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_ACT4',        'NORMAL', null);

    -- Added for bug 6857368
    -- Debug Tables

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_EXTR_PLAN_LINES_DEBUG','NORMAL', null); /* Added for bug 6857368 */
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_XBS_ACCUM_TMP1_DEBUG','NORMAL', null); /* Added for bug 6857368 */

    -- Added for bug 6603016
    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    update PA_PROJECTS_ALL
    set    PJI_SOURCE_FLAG   = null,
           LAST_UPDATE_DATE  = l_last_update_date,
           LAST_UPDATED_BY   = l_last_updated_by,
           LAST_UPDATE_LOGIN = l_last_update_login
    where  PJI_SOURCE_FLAG = 'Y';
    commit;
    -- Added for bug 6603016 ends

    if (p_truncate_pji_tables = 'Y') then

      update FND_PROFILE_OPTION_VALUES
      set    PROFILE_OPTION_VALUE = 'Y'
      where  APPLICATION_ID = 1292 and
             -- LEVEL_ID = 10001 and
             PROFILE_OPTION_ID in
             (select PROFILE_OPTION_ID
              from   FND_PROFILE_OPTIONS
              where  APPLICATION_ID = 1292 and
                     PROFILE_OPTION_NAME = 'PJI_SUM_CLEANALL');

      commit;

/* Temporary removal of stage 1 dependency on stage 2.  temptemp
      PJI_EXTRACTION_UTIL.TRUNCATE_PJI_PJI_TABLES
      (
        errbuf,
        retcode,
        'Y'
      );

      commit;
*/

    end if;

    if (p_truncate_pjp_tables = 'Y') then

      update FND_PROFILE_OPTION_VALUES
      set    PROFILE_OPTION_VALUE = 'Y'
      where  APPLICATION_ID = 1292 and
             -- LEVEL_ID = 10001 and
             PROFILE_OPTION_ID in
             (select PROFILE_OPTION_ID
              from   FND_PROFILE_OPTIONS
              where  APPLICATION_ID = 1292 and
                     PROFILE_OPTION_NAME = 'PJI_SUM_CLEANALL');

      commit;

      PJI_PJP_EXTRACTION_UTILS.TRUNCATE_PJP_TABLES
      (
        errbuf,
        retcode,
        'Y',
        p_run_fpm_upgrade
      );

      commit;

    end if;

    update PJI_SYSTEM_CONFIG_HIST
    set    END_DATE = sysdate,
           COMPLETION_TEXT = 'Normal completion'
    where  PROCESS_NAME = 'STAGE1' and
           END_DATE is null;

    commit;

    retcode := 0;

    exception when others then

      rollback;

      l_sqlerrm := substr(sqlerrm, 1, 240);

      update PJI_SYSTEM_CONFIG_HIST
      set    END_DATE = sysdate,
             COMPLETION_TEXT = l_sqlerrm
      where  PROCESS_NAME = 'STAGE1' and
             END_DATE is null;

      commit;

      raise;

  end TRUNCATE_PJI_TABLES;


  -- -----------------------------------------------------
  -- function GET_PARALLEL_PROCESSES
  -- -----------------------------------------------------
  function GET_PARALLEL_PROCESSES return number is

    l_parallel_processes number;

  begin

    l_parallel_processes :=
      trunc(to_number(FND_PROFILE.VALUE('PJI_EXTRACTION_PARALLELISM')), 0);

    l_parallel_processes:= nvl(l_parallel_processes, 4);

    l_parallel_processes:= greatest(l_parallel_processes, 2);

    -- no upper limit on number of helpers
    -- l_parallel_processes:= least(l_parallel_processes, 8);

    return l_parallel_processes;

    exception when others then

      l_parallel_processes := 4;
      return l_parallel_processes;

  end GET_PARALLEL_PROCESSES;


  -- -----------------------------------------------------
  -- function GET_BATCH_SIZE
  -- -----------------------------------------------------
  function GET_BATCH_SIZE return number is

  l_batch_size number;

  begin
        l_batch_size := TRUNC(to_number(FND_PROFILE.VALUE('PJI_EXTRACTION_BATCH_SIZE')),0);
        l_batch_size:= GREATEST(l_batch_size,1000000);
        l_batch_size:= NVL(l_batch_size,5000000);

        return l_batch_size;

  exception
        when others then
        l_batch_size:=5000000;
        return l_batch_size;

  end GET_BATCH_SIZE;


end PJI_EXTRACTION_UTIL;

/
