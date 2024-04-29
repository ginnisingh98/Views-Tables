--------------------------------------------------------
--  DDL for Package Body PJI_PJI_EXTRACTION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PJI_EXTRACTION_UTILS" as
  /* $Header: PJIUT07B.pls 120.3 2007/01/25 00:45:54 degupta ship $ */

  -- -------------------------------------
  -- procedure UPDATE_PJI_EXTR_SCOPE
  -- -------------------------------------
  procedure UPDATE_PJI_EXTR_SCOPE is

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
    from   PJI_PJI_PROJ_EXTR_STATUS
    where  ROWNUM = 1;

    if (l_count > 0) then

      insert into PJI_PJI_PROJ_EXTR_STATUS
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
        PJI_PJI_PROJ_EXTR_STATUS pji_status
      where
        prj.TEMPLATE_FLAG     = 'N'                       and
        prj.ORG_ID            = pt.ORG_ID                 and  /*5377131*/
        prj.PROJECT_TYPE      = pt.PROJECT_TYPE           and
        prj.PROJECT_ID        = pji_status.PROJECT_ID (+) and
        pji_status.PROJECT_ID is null;

    else

      insert into PJI_PJI_PROJ_EXTR_STATUS pjp_i
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
        PA_PROJECT_TYPES_ALL pt
      where
        prj.TEMPLATE_FLAG   = 'N'                and
        prj.ORG_ID = pt.ORG_ID                   and  /*5377131*/
        prj.PROJECT_TYPE    = pt.PROJECT_TYPE;

    end if;

  end UPDATE_PJI_EXTR_SCOPE;


  -- ----------------------------------------------------------
  -- procedure POPULATE_ORG_EXTR_INFO
  -- ----------------------------------------------------------
  procedure POPULATE_ORG_EXTR_INFO is

  begin

    PJI_EXTRACTION_UTIL.POPULATE_ORG_EXTR_INFO;

  end POPULATE_ORG_EXTR_INFO;


  -- ----------------------------------------------------------
  -- procedure UPDATE_ORG_EXTR_INFO
  -- ----------------------------------------------------------
  procedure UPDATE_ORG_EXTR_INFO is

  begin

    PJI_EXTRACTION_UTIL.UPDATE_ORG_EXTR_INFO;

  end UPDATE_ORG_EXTR_INFO;


  -- ------------------------------------------------------
  -- procedure MVIEW_REFRESH( p_name )
  -- ------------------------------------------------------
  procedure MVIEW_REFRESH
  (
      errbuf                  out nocopy varchar2
    , retcode                 out nocopy varchar2
    , p_name                  in         varchar2 default 'All'
    , p_method                in         varchar2 default 'C'
    , p_refresh_mview_lookups in         varchar2 default 'Y'
  ) is

  l_chk number := 0;

  cursor cur_mv is
         SELECT
                level_1.owner                                  owner
                , level_1.name                                 mv_name
                , level_1.mview_id                             mv_id
                , max(decode(level_1.ord_bod1
                         , 1, decode(bod2.DEPEND_OBJECT_TYPE
                                     , 'MV', 2
                                     , 1)
                         , 0))                                 ord_bod2
         FROM
         (
         select
               rmv.OWNER
             , rmv.NAME
             , rmv.MVIEW_ID
             , bod1.DEPEND_OBJECT_NAME         prnt1
             , decode(bod1.DEPEND_OBJECT_TYPE
                  , 'MV'    , 1
                  , 0)                     ord_bod1
         from DBA_REGISTERED_MVIEWS rmv
              , BIS_OBJ_DEPENDENCY  bod1
         where 1=1
         and rmv.NAME like 'PJI%'
         and bod1.OBJECT_TYPE (+) = 'MV'
         and rmv.NAME = bod1.OBJECT_NAME (+)
         ) level_1
         , BIS_OBJ_DEPENDENCY  bod2
         WHERE 1=1
         AND   decode(level_1.ord_bod1
                , 1, level_1.prnt1
                , level_1.name       )  = bod2.OBJECT_NAME (+)
         --and level_1.name = 'PJI_FP_ORGO_F_MV'
         group by level_1.owner
              , level_1.name
                  , level_1.mview_id
         order by 4,3
         ;


    cur_mv_rec  cur_mv%ROWTYPE;

  begin

    /*
     * Update tables on which only PJI mviews rely.  This way if massive
     * changes take place in these tables we can run a full refresh on the
     * materialized views rather than an incremental refresh.
     *
     */

    if (p_refresh_mview_lookups = 'Y') then
      PJI_PJ_PROJ_CLASS_EXTR.EXTR_CLASS_CODES;
      PJI_PJI_EXTRACTION_UTILS.UPDATE_PJI_ORG_HRCHY;
    end if;

    commit; -- we need to end any transactions before altering parallel DML

    IF (upper(p_name) <> 'ALL')  THEN

      BIS_MV_REFRESH.REFRESH_WRAPPER(p_name, p_method);

    ELSE

      IF cur_mv%ISOPEN then
        CLOSE cur_mv;
      END IF;

      For cur_mv_rec in cur_mv LOOP
        BIS_MV_REFRESH.REFRESH_WRAPPER(cur_mv_rec.owner ||'.'||
                                       cur_mv_rec.mv_name,
                                       p_method);
      End LOOP;

    END IF;

    -- bis utility disables parallel query, but pji summarization always
    -- uses parallel query
    execute immediate 'alter session enable parallel query';

  retcode := 0;
  exception when others then
    retcode := 2;
    errbuf  := sqlerrm;
    PJI_UTILS.write2log('PJI_PJI_EXTRACTION_UTILS.mview_refresh '||sqlerrm);
    PJI_UTILS.write2out('PJI_PJI_EXTRACTION_UTILS.mview_refresh '||sqlerrm);
    raise;
  end MVIEW_REFRESH;


  -- ------------------------------------------------------
  -- procedure ANALYZE_PJI_FACTS
  -- ------------------------------------------------------
  procedure ANALYZE_PJI_FACTS
    is

            l_schema   varchar2(30);
            l_degree   number;



  begin

            l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;
            l_degree :=  PJI_UTILS.GET_DEGREE_OF_PARALLELISM();

            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_FP_PROJ_ET_WT_F'
                      , percent  =>  10
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_FP_PROJ_ET_F'
                      , percent  =>  10
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_FP_PROJ_F'
                      , percent  =>  10
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_AC_PROJ_F'
                      , percent  =>  10
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_RM_RES_F'
                      , percent  =>  10
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_RM_RES_WT_F'
                      , percent  =>  10
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_FP_TXN_ACCUM_HEADER'
                      , percent  =>  10
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_FP_TXN_ACCUM'
                      , percent  =>  10
                      , degree   =>  l_degree
                      );

  end ANALYZE_PJI_FACTS;


/* ------------------------------------------------------
   Procedure : SEED_PJI_RM_STATS
   -----------------------------------------------------*/

PROCEDURE SEED_PJI_RM_STATS IS

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
    /*  This procedure sets statistics for all PJI_RM intermediate tables
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

     l_high_rows  := 10000000;
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

--  partitioned tables
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_EXTR_PLN'        , l_med_rows,  l_med_blocks,  150, 'P0' );
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_EXTR_PLN'        , l_med_rows,  l_med_blocks,  150, 'P1' );
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_EXTR_PLN'        , l_med_rows,  l_med_blocks,  150, 'P2' );
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_EXTR_PLN'        , l_med_rows,  l_med_blocks,  150, 'P3' );
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_EXTR_PLN'        , l_med_rows,  l_med_blocks,  150, 'P4' );

    --  non-partitioned tables
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_RMAP_ACT'   , l_low_rows,  l_low_blocks,   75);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_AGGR_ACT3'        , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_AGGR_FIN3'        , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_AGGR_FIN4'   , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_AGGR_FIN5'   , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_AGGR_PLN'   , l_med_rows,  l_med_blocks,  150);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_EXTR_PLN'        , l_med_rows,  l_med_blocks,  150);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_RMAP_FIN'   , l_low_rows,  l_low_blocks,   75);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_PJ_EXTR_PRJCLS'    , l_low_rows,  l_low_blocks,   75);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_CLASS_CATEGORIES'   , l_low_rows,  l_low_blocks,   75);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_CLASS_CODES'        , l_low_rows,  l_low_blocks,   75);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_FM_EXTR_PLN_LOG'    , l_low_rows,  l_low_blocks,   75);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_RM_REXT_FCSTITEM'  , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_RM_AGGR_RES1'   , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_RM_AGGR_RES2'   , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_RM_AGGR_RES3'   , l_high_rows, l_high_blocks, 225);
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_RM_ORG_BATCH_MAP'   , l_low_rows,  l_low_blocks,   75);

--  global temporary tables
    FND_STATS.SET_TABLE_STATS(l_schema,'PJI_ROWID_ORG_DENORM'   , l_low_rows,  l_low_blocks,   75);

--  gather statistics for PJI metadata tables
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_ORG_DENORM'
                      , percent  =>  50
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_ORG_EXTR_INFO'
                      , percent  =>  50
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_ORG_EXTR_STATUS'
                      , percent  =>  50
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_RM_WORK_TYPE_INFO'
                      , percent  =>  50
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_COLUMN_STATS(ownname => l_schema,
                                          tabname => 'PJI_RM_WORK_TYPE_INFO',
                                          colname => 'WORK_TYPE_ID',
                                          percent => 10,
                                          degree  => l_degree);
            FND_STATS.GATHER_COLUMN_STATS(ownname => l_schema,
                                          tabname => 'PJI_RM_WORK_TYPE_INFO',
                                          colname => 'RECORD_TYPE',
                                          percent => 10,
                                          degree  => l_degree);
            FND_STATS.GATHER_TABLE_STATS(
                      ownname    =>  l_schema
                      , tabname  =>  'PJI_RESOURCES_DENORM'
                      , percent  =>  10
                      , degree   =>  l_degree
                      );
            FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                         tabname => 'PJI_ORG_EXTR_STATUS',
                                         percent => 10,
                                         degree  => l_degree);
            FND_STATS.GATHER_COLUMN_STATS(ownname => l_schema,
                                          tabname => 'PJI_ORG_EXTR_STATUS',
                                          colname => 'ORGANIZATION_ID',
                                          percent => 10,
                                          degree  => l_degree);
            FND_STATS.GATHER_COLUMN_STATS(ownname => l_schema,
                                          tabname => 'PJI_ORG_EXTR_STATUS',
                                          colname => 'STATUS',
                                          percent => 10,
                                          degree  => l_degree);
            FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                         tabname => 'PJI_RM_ORG_BATCH_MAP',
                                         percent => 10,
                                         degree  => l_degree);
            FND_STATS.GATHER_COLUMN_STATS(ownname => l_schema,
                                          tabname => 'PJI_RM_ORG_BATCH_MAP',
                                          colname => 'ORGANIZATION_ID',
                                          percent => 10,
                                          degree  => l_degree);
            FND_STATS.GATHER_COLUMN_STATS(ownname => l_schema,
                                          tabname => 'PJI_RM_ORG_BATCH_MAP',
                                          colname => 'EXTRACTION_TYPE',
                                          percent => 10,
                                          degree  => l_degree);
            FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                         tabname => 'PJI_PROJECT_CLASSES',
                                         percent => 10,
                                         degree  => l_degree); --Bug#4997700
END SEED_PJI_RM_STATS;


  -- ------------------------------------------------------------------
  -- procedure UPDATE_PJI_RM_WORK_TYPE_INFO
  --
  -- This procedure maintains the table PJI_RM_WORK_TYPE_INFO
  -- This table contains 3 slices of data which can be distinguished
  -- by the value in  RECORD_TYPE column
  -- RECORD_TYPE column can take 3 values
  --   NORMAL     - This slice is a copy of PA_WORK_TYPE _B table;
  --                the slice is maintained incrementally,
  --                i.e. we never delete records from this slice
  --   CHANGE_OLD - This slice is used for processing changes in
  --                work type attributes. It stores the old version of
  --                changed work type record
  --   CHANGE_NEW - This slice is used for processing changes in
  --                work type attributes. It stores the new version of
  --                changed work type record. Records in this slice will
  --                be copies of NORMAL slice records for which CHANGE_OLD
  --                record exists
  -- ------------------------------------------------------------------
  procedure UPDATE_PJI_RM_WORK_TYPE_INFO (p_process in varchar2) is

  l_row_count       number;
  l_extraction_type varchar2(30);
  l_event_id     number;

  begin

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(p_process, 'PJI_PJI_EXTRACTION_UTILS.UPDATE_PJI_RM_WORK_TYPE_INFO(p_process);')) then
      return;
    end if;

    select count(*)
    into   l_row_count
    from   PJI_RM_WORK_TYPE_INFO
    where  ROWNUM = 1;

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process,
                                               'TRANSITION') = 'Y' and
        l_row_count <> 0) then
      return;
    end if;

   --delete CHANGE_NEW / CHANGE_OLD records
   delete
   from PJI_RM_WORK_TYPE_INFO
   where RECORD_TYPE in ( 'CHANGE_NEW', 'CHANGE_OLD');

   --Conditional processing based on extraction type
   --Work type change processing is not done for
   --Partial refresh
   l_extraction_type := PJI_UTILS.get_parameter (
                                   p_name => 'EXTRACTION_TYPE');

   IF l_extraction_type = 'PARTIAL' THEN
     return;
   END IF;

   --Synchronize NORMAL slice of PJI_RM_WORK_TYPE_INFO
   --with PA_WORK_TYPES_B when extraction type is FULL
   --or INCREMENTAL
   insert into PJI_RM_WORK_TYPE_ROWID
    (
      PA_ROWID,
      PJI_ROWID,
      CHANGE_FLAG
    )
    select
      pa.ROWID,
      pji.ROWID,
      case when nvl(pa.BILLABLE_CAPITALIZABLE_FLAG,'Y') <> nvl(pji.BILLABLE_CAPITALIZABLE_FLAG,'Y') or
                nvl(pa.REDUCE_CAPACITY_FLAG,'Y')        <> nvl(pji.REDUCE_CAPACITY_FLAG,'Y')        or
                nvl(pa.RES_UTILIZATION_PERCENTAGE,0)    <> nvl(pji.RES_UTILIZATION_PERCENTAGE,0)    or
                nvl(pa.ORG_UTILIZATION_PERCENTAGE,0)    <> nvl(pji.ORG_UTILIZATION_PERCENTAGE,0)    or
                nvl(pa.TRAINING_FLAG,'Y') <> nvl(pji.TRAINING_FLAG,'Y')
           then 'Y'
           else 'N'
           end
    from
      PA_WORK_TYPES_B pa,
      PJI_RM_WORK_TYPE_INFO pji
    where
      pa.WORK_TYPE_ID         = pji.WORK_TYPE_ID (+) and
      pji.RECORD_TYPE      (+)= 'NORMAL';

    delete
    from PJI_RM_WORK_TYPE_INFO wt
    where
      wt.ROWID not in
      (
        select
          wt_r.PJI_ROWID
        from
          PJI_RM_WORK_TYPE_ROWID wt_r
        where
          wt_r.PJI_ROWID is not null
      )
      and wt.RECORD_TYPE = 'NORMAL';

    pji_utils.write2log(sql%rowcount || ' rows deleted.');

    update PJI_RM_WORK_TYPE_INFO wt
    set
    (
      WORK_TYPE_ID,
      BILLABLE_CAPITALIZABLE_FLAG,
      REDUCE_CAPACITY_FLAG,
      RES_UTILIZATION_PERCENTAGE,
      ORG_UTILIZATION_PERCENTAGE,
      TRAINING_FLAG,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY
    ) =
    (
      select
        pa.WORK_TYPE_ID,
        pa.BILLABLE_CAPITALIZABLE_FLAG,
        pa.REDUCE_CAPACITY_FLAG,
        pa.RES_UTILIZATION_PERCENTAGE,
        pa.ORG_UTILIZATION_PERCENTAGE,
        pa.TRAINING_FLAG,
        pa.LAST_UPDATE_DATE,
        pa.LAST_UPDATED_BY
      from
        PJI_RM_WORK_TYPE_ROWID wt_r,
        PA_WORK_TYPES_B pa
      where
        wt_r.PJI_ROWID = wt.ROWID and
        pa.ROWID       = wt_r.PA_ROWID
    )
    where
      wt.ROWID in
      (
        select
          wt_r.PJI_ROWID
        from
          PJI_RM_WORK_TYPE_ROWID wt_r
        where
          wt_r.PJI_ROWID is not null and
          wt_r.CHANGE_FLAG = 'Y'
      );

    pji_utils.write2log(sql%rowcount || ' rows updated.');

    insert into PJI_RM_WORK_TYPE_INFO
    (
      WORK_TYPE_ID,
      BILLABLE_CAPITALIZABLE_FLAG,
      REDUCE_CAPACITY_FLAG,
      RES_UTILIZATION_PERCENTAGE,
      ORG_UTILIZATION_PERCENTAGE,
      TRAINING_FLAG,
      RECORD_TYPE,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY
    )
    select /*+ rowid(pa) */
      pa.WORK_TYPE_ID,
      pa.BILLABLE_CAPITALIZABLE_FLAG,
      pa.REDUCE_CAPACITY_FLAG,
      pa.RES_UTILIZATION_PERCENTAGE,
      pa.ORG_UTILIZATION_PERCENTAGE,
      pa.TRAINING_FLAG,
      'NORMAL',
      pa.CREATION_DATE,
      pa.CREATED_BY,
      pa.LAST_UPDATE_DATE,
      pa.LAST_UPDATED_BY
    from
      PA_WORK_TYPES_B pa
    where
      pa.ROWID in
      (
        select
          wt_r.PA_ROWID
        from
          PJI_RM_WORK_TYPE_ROWID wt_r
        where
          wt_r.PJI_ROWID is null
      );

    pji_utils.write2log(sql%rowcount || ' rows inserted.');

    --Only those work type changes which occured upto launch of summarization
    --process will be handled in a given run. This is done by tracking
    --the MAX(EVENT_ID) on the log table PA_PJI_PROJ_EVENTS_LOG
    begin

      select max(event_id)
      into   l_event_id
      from
        pa_pji_proj_events_log log
      where
        log.EVENT_TYPE     = 'Work Types' and
        log.OPERATION_TYPE = 'U';

    exception
      when others then
        l_event_id := 0;
    end;

    --WORK TYPE change handling is done as net change handling
    --not processing every change for a given worktype
    --Log table stores the old value of worktype attribute
    --Only the first change is retained for a given worktype
    --All subsequent changes are deleted below.
    delete
    from
      pa_pji_proj_events_log log
    where
      log.EVENT_TYPE     = 'Work Types' and
      log.OPERATION_TYPE = 'U'          and
      log.EVENT_ID      <= l_event_id   and
      log.EVENT_ID       > ( select min(log1.event_id)
                               from pa_pji_proj_events_log log1
                              where log1.event_object = log.EVENT_OBJECT
                                and log1.operation_type = 'U'
                           group by log1.event_object );

    pji_utils.write2log(sql%rowcount || ' rows deleted :2.');

    --populate CHANGE_OLD slice from PA_PJI_PROJ_EVENTS_LOG table
    insert into PJI_RM_WORK_TYPE_INFO
    (
      WORK_TYPE_ID,
      BILLABLE_CAPITALIZABLE_FLAG,
      REDUCE_CAPACITY_FLAG,
      RES_UTILIZATION_PERCENTAGE,
      ORG_UTILIZATION_PERCENTAGE,
      TRAINING_FLAG,
      RECORD_TYPE,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY
    )
    select
      to_number(EVENT_OBJECT),
      ATTRIBUTE3,
      ATTRIBUTE4,
      to_number(ATTRIBUTE1),
      to_number(ATTRIBUTE2),
      ATTRIBUTE5,
      'CHANGE_OLD',
      sysdate,
      -1,
      sysdate,
      -1
    from pa_pji_proj_events_log
    where
      EVENT_ID      <= l_event_id   and
      EVENT_TYPE     = 'Work Types' and
      OPERATION_TYPE = 'U';

    pji_utils.write2log(sql%rowcount || ' rows inserted :2.');

    --Cleanup log table for processed Worktype changes
    delete
    from
      pa_pji_proj_events_log log
    where
      log.EVENT_ID      <= l_event_id   and
      log.EVENT_TYPE     = 'Work Types' and
      log.OPERATION_TYPE = 'U';
     pji_utils.write2log(sql%rowcount || ' rows deleted 3.');

    --Populate PJI_RM_WORK_TYPE_INFO with CHANGE_NEW records
    insert into PJI_RM_WORK_TYPE_INFO
    (
      WORK_TYPE_ID,
      BILLABLE_CAPITALIZABLE_FLAG,
      REDUCE_CAPACITY_FLAG,
      RES_UTILIZATION_PERCENTAGE,
      ORG_UTILIZATION_PERCENTAGE,
      TRAINING_FLAG,
      RECORD_TYPE,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY
    )
    select
      WORK_TYPE_ID,
      BILLABLE_CAPITALIZABLE_FLAG,
      REDUCE_CAPACITY_FLAG,
      RES_UTILIZATION_PERCENTAGE,
      ORG_UTILIZATION_PERCENTAGE,
      TRAINING_FLAG,
      'CHANGE_NEW',
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY
    from PJI_RM_WORK_TYPE_INFO info
    where info.RECORD_TYPE = 'NORMAL'
    and   info.WORK_TYPE_ID in ( select WORK_TYPE_ID
                                 from   PJI_RM_WORK_TYPE_INFO wt
                                 where  wt.RECORD_TYPE = 'CHANGE_OLD');

    pji_utils.write2log(sql%rowcount || ' rows inserted :3.');

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(p_process, 'PJI_PJI_EXTRACTION_UTILS.UPDATE_PJI_RM_WORK_TYPE_INFO(p_process);');

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(PJI_UTILS.GET_PJI_SCHEMA_NAME, 'PJI_RM_WORK_TYPE_ROWID', 'NORMAL', null);

    commit;

  end UPDATE_PJI_RM_WORK_TYPE_INFO;


  -- -----------------------------------------------------
  -- procedure UPDATE_PJI_ORG_HRCHY
  --
  --  This procedure incrementally synchronizes HRI_ORG_HRCHY_SUMMARY with
  --  PJI_ORG_DENORM.  This is required because incremental updates on
  --  HRI_ORG_HRCHY_SUMMARY are performed by deleting the entire table and
  --  repopulating it.  This would cause slow mview refreshes.
  --
  -- -----------------------------------------------------
  procedure UPDATE_PJI_ORG_HRCHY is

    l_org_structure_version_id number;

  begin

    select ORG_STRUCTURE_VERSION_ID
    into   l_org_structure_version_id
    from   PJI_SYSTEM_SETTINGS;

    insert into PJI_ROWID_ORG_DENORM
    (
      HRI_ROWID,
      PJI_ROWID,
      CHANGE_FLAG
    )
    select /*+ ordered full(pji) use_hash(pji)
                       index(hri, HRI_ORG_HRCHY_SUMMARY_U1) */
      hri.ROWID,
      pji.ROWID,
      case when hri.ORGANIZATION_LEVEL <> pji.ORGANIZATION_LEVEL or
                hri.SUB_ORGANIZATION_LEVEL <> pji.SUB_ORGANIZATION_LEVEL
           then 'Y'
           else 'N'
           end
    from
      HRI_ORG_HRCHY_SUMMARY hri,
      PJI_ORG_DENORM pji
    where
      hri.ORG_STRUCTURE_VERSION_ID = l_org_structure_version_id and
      hri.ORGANIZATION_ID          = pji.ORGANIZATION_ID (+) and
      hri.SUB_ORGANIZATION_ID      = pji.SUB_ORGANIZATION_ID (+);

    delete /*+ use_nl(denorm) rowid(denorm) */
    from PJI_ORG_DENORM denorm
    where
      denorm.ROWID not in
      (
        select /*+ index(org_r, PJI_ROWID_ORG_DENORM_N1) */
          org_r.PJI_ROWID
        from
          PJI_ROWID_ORG_DENORM org_r
        where
          org_r.PJI_ROWID is not null
      );

    pji_utils.write2log(sql%rowcount || ' rows deleted.');

    update /*+ use_nl(denorm) rowid(denorm) */ PJI_ORG_DENORM denorm
    set
    (
      ORGANIZATION_LEVEL,
      SUB_ORGANIZATION_LEVEL
    ) =
    (
      select /*+ ordered index(org_r, PJI_ROWID_ORG_DENORM_N1) rowid(hri) */
        hri.ORGANIZATION_LEVEL,
        hri.SUB_ORGANIZATION_LEVEL
      from
        PJI_ROWID_ORG_DENORM org_r,
        HRI_ORG_HRCHY_SUMMARY hri
      where
        org_r.PJI_ROWID = denorm.ROWID and
        hri.ROWID = org_r.HRI_ROWID
    )
    where
      denorm.ROWID in
      (
        select /*+ index(org_r, PJI_ROWID_ORG_DENORM_N1) */
          org_r.PJI_ROWID
        from
          PJI_ROWID_ORG_DENORM org_r
        where
          org_r.PJI_ROWID is not null and
          org_r.CHANGE_FLAG = 'Y'
      );

    pji_utils.write2log(sql%rowcount || ' rows updated.');

    insert into PJI_ORG_DENORM
    (
      ORGANIZATION_ID,
      ORGANIZATION_LEVEL,
      SUB_ORGANIZATION_ID,
      SUB_ORGANIZATION_LEVEL
    )
    select /*+ rowid(hri) */
      hri.ORGANIZATION_ID,
      hri.ORGANIZATION_LEVEL,
      hri.SUB_ORGANIZATION_ID,
      hri.SUB_ORGANIZATION_LEVEL
    from
      HRI_ORG_HRCHY_SUMMARY hri
    where
      hri.ROWID in
      (
        select /*+ index(org_r, PJI_ROWID_ORG_DENORM_N1) */
          org_r.HRI_ROWID
        from
          PJI_ROWID_ORG_DENORM org_r
        where
          org_r.PJI_ROWID is null
      );

    pji_utils.write2log(sql%rowcount || ' rows inserted.');

    execute immediate 'truncate table '|| pji_utils.get_pji_schema_name
                                       || '.PJI_ROWID_ORG_DENORM drop storage';

    commit;

  end UPDATE_PJI_ORG_HRCHY;


  -- -----------------------------------------------------
  -- procedure UPDATE_RESOURCE_DATA
  --
  --  This procedure incrementally synchronizes PA_RESOURCES_DENORM with
  --  PJI_RESOURCES_DENORM.
  --
  -- -----------------------------------------------------
  procedure UPDATE_RESOURCE_DATA (p_process in varchar2) is

    l_row_count number;
    l_max_date date;
    l_extraction_type varchar2(30);

  begin

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(p_process, 'PJI_PJI_EXTRACTION_UTILS.UPDATE_RESOURCE_DATA(p_process);')) then
      return;
    end if;

    select count(*)
    into   l_row_count
    from   PJI_RESOURCES_DENORM
    where  ROWNUM = 1;

    if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(PJI_FM_SUM_MAIN.g_process,
                                               'TRANSITION') = 'Y' and
        l_row_count <> 0) then
      return;
    end if;

    l_max_date := PJI_RM_SUM_MAIN.g_max_date;
    l_extraction_type := PJI_UTILS.GET_PARAMETER('EXTRACTION_TYPE');

    insert into PJI_ROWID_RESOURCES_DENORM
    (
      PA_ROWID,
      PJI_ROWID,
      CHANGE_FLAG
    )
    select /*+ full(pa)  parallel(pa)  use_hash(pa)
               full(pji) parallel(pji) use_hash(pji) */
      pa.ROWID,
      pji.ROWID,
      case when nvl(pa.JOB_ID, -999) <>
                  nvl(pji.JOB_ID, -999) or
                nvl(pa.UTILIZATION_FLAG, 'PJI$NULL') <>
                  nvl(pji.UTILIZATION_FLAG, 'PJI$NULL')
           then 'Y'
           else 'N'
           end
    from
      PA_RESOURCES_DENORM pa,
      PJI_RESOURCES_DENORM pji
    where
      pa.PERSON_ID                                = pji.PERSON_ID       (+) and
      pa.RESOURCE_ID                              = pji.RESOURCE_ID     (+) and
      pa.RESOURCE_NAME                            = pji.RESOURCE_NAME   (+) and
      pa.RESOURCE_ORGANIZATION_ID                 = pji.ORGANIZATION_ID (+) and
      pa.RESOURCE_EFFECTIVE_START_DATE            = pji.START_DATE      (+) and
      nvl(pa.RESOURCE_EFFECTIVE_END_DATE, l_max_date) = pji.END_DATE    (+);

    -- --------------------------------------------------------------------
    -- Determine delta between PA_RESOURCES_DENORM and PJI_RESOURCES_DENORM
    -- --------------------------------------------------------------------

    if (l_extraction_type <> 'FULL') then

      insert into PJI_RES_DELTA
      (
        PERSON_ID,
        RESOURCE_ID,
        START_DATE,
        END_DATE,
        CHANGE_TYPE
      )
      select /*+ use_nl(denorm) rowid(denorm) */  -- old resources
        denorm.PERSON_ID,
        denorm.RESOURCE_ID,
        denorm.START_DATE,
        denorm.END_DATE,
        'N'
      from
        PJI_RESOURCES_DENORM denorm
      where
        denorm.UTILIZATION_FLAG = 'Y' and
        denorm.ROWID not in
        (
          select /*+ index(res_r, PJI_ROWID_RESOURCES_DENORM_N1) */
            res_r.PJI_ROWID
          from
            PJI_ROWID_RESOURCES_DENORM res_r
          where
            res_r.PJI_ROWID is not null
        )
      union all                                   -- updated resources
      select /*+ ordered
                 index(res_r, PJI_ROWID_RESOURCES_DENORM_N1)
                 rowid(pa)
                 rowid(pji) */
        pa.PERSON_ID,
        pa.RESOURCE_ID,
        pa.RESOURCE_EFFECTIVE_START_DATE,
        nvl(pa.RESOURCE_EFFECTIVE_END_DATE, l_max_date),
        case when (nvl(pa.UTILIZATION_FLAG, 'N') = 'N' and
                   nvl(pji.UTILIZATION_FLAG, 'N') = 'Y')
             then 'N'
             when (nvl(pa.UTILIZATION_FLAG, 'N') = 'Y' and
                   nvl(pji.UTILIZATION_FLAG, 'N') = 'N')
             then 'Y'
             end
      from
        PJI_ROWID_RESOURCES_DENORM res_r,
        PA_RESOURCES_DENORM        pa,
        PJI_RESOURCES_DENORM       pji
      where
        res_r.PJI_ROWID                is not null  and
        res_r.CHANGE_FLAG              =  'Y'       and
        res_r.PA_ROWID                 =  pa.ROWID  and
        res_r.PJI_ROWID                =  pji.ROWID and
        nvl(pji.UTILIZATION_FLAG, 'N') <> nvl(pa.UTILIZATION_FLAG, 'N')
      union all                                   -- new resources
      select /*+ rowid(pa) */
        pa.PERSON_ID,
        pa.RESOURCE_ID,
        pa.RESOURCE_EFFECTIVE_START_DATE,
        nvl(pa.RESOURCE_EFFECTIVE_END_DATE, l_max_date),
        'Y'
      from
        PA_RESOURCES_DENORM pa
      where
        pa.UTILIZATION_FLAG = 'Y' and
        pa.ROWID in
        (
          select /*+ index(res_r, PJI_ROWID_RESOURCES_DENORM_N1) */
            res_r.PA_ROWID
          from
            PJI_ROWID_RESOURCES_DENORM res_r
          where
            res_r.PJI_ROWID is null
        );

    end if;

    -- --------------------------------------------------------
    -- Synchronize PA_RESOURCES_DENORM and PJI_RESOURCES_DENORM
    -- --------------------------------------------------------

    delete /*+ use_nl(denorm) rowid(denorm) */
    from PJI_RESOURCES_DENORM denorm
    where
      denorm.ROWID not in
      (
        select /*+ index(res_r, PJI_ROWID_RESOURCES_DENORM_N1) */
          res_r.PJI_ROWID
        from
          PJI_ROWID_RESOURCES_DENORM res_r
        where
          res_r.PJI_ROWID is not null
      );

    pji_utils.write2log(sql%rowcount || ' rows deleted.');

    update /*+ use_nl(denorm) rowid(denorm) */ PJI_RESOURCES_DENORM denorm
    set
    (
      JOB_ID,
      UTILIZATION_FLAG
    ) =
    (
      select /*+ordered index(res_r, PJI_ROWID_RESOURCES_DENORM_N1) rowid(pa)*/
        pa.JOB_ID,
        pa.UTILIZATION_FLAG
      from
        PJI_ROWID_RESOURCES_DENORM res_r,
        PA_RESOURCES_DENORM pa
      where
        res_r.PJI_ROWID = denorm.ROWID and
        pa.ROWID = res_r.PA_ROWID
    )
    where
      denorm.ROWID in
      (
        select /*+ index(res_r, PJI_ROWID_RESOURCES_DENORM_N1) */
          res_r.PJI_ROWID
        from
          PJI_ROWID_RESOURCES_DENORM res_r
        where
          res_r.PJI_ROWID is not null and
          res_r.CHANGE_FLAG = 'Y'
      );

    pji_utils.write2log(sql%rowcount || ' rows updated.');

    insert into PJI_RESOURCES_DENORM
    (
      PERSON_ID,
      RESOURCE_ID,
      RESOURCE_NAME,
      START_DATE,
      END_DATE,
      JOB_ID,
      ORGANIZATION_ID,
      UTILIZATION_FLAG
    )
    select /*+ rowid(pa) */
      pa.PERSON_ID,
      pa.RESOURCE_ID,
      pa.RESOURCE_NAME,
      pa.RESOURCE_EFFECTIVE_START_DATE,
      nvl(pa.RESOURCE_EFFECTIVE_END_DATE, l_max_date),
      pa.JOB_ID,
      pa.RESOURCE_ORGANIZATION_ID,
      pa.UTILIZATION_FLAG
    from
      PA_RESOURCES_DENORM pa
    where
      pa.ROWID in
      (
        select /*+ index(res_r, PJI_ROWID_RESOURCES_DENORM_N1) */
          res_r.PA_ROWID
        from
          PJI_ROWID_RESOURCES_DENORM res_r
        where
          res_r.PJI_ROWID is null
      );

    pji_utils.write2log(sql%rowcount || ' rows inserted.');

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(p_process, 'PJI_PJI_EXTRACTION_UTILS.UPDATE_RESOURCE_DATA(p_process);');

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(PJI_UTILS.GET_PJI_SCHEMA_NAME, 'PJI_ROWID_RESOURCES_DENORM', 'NORMAL', null);

    commit;

  end UPDATE_RESOURCE_DATA;


  -- -----------------------------------------------------
  -- procedure TRUNCATE_PJI_TABLES
  --
  --  This procedure resets the summarization process by
  --  truncating all PJI stage 2 summarization tables.
  --
  -- -----------------------------------------------------
  procedure TRUNCATE_PJI_TABLES
  (
    errbuf                out nocopy varchar2,
    retcode               out nocopy varchar2,
    p_check               in         varchar2 default 'N'
  ) is

    l_profile_check varchar2(30);
    l_pji_schema    varchar2(30);
    l_sqlerrm       varchar2(240);

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
      'STAGE2'                                           PROCESS_NAME,
      'CLEANALL'                                         RUN_TYPE,
      substr(p_check, 1, 240)                            PARAMETERS,
      null                                               CONFIG_PROJ_PERF_FLAG,
      null                                               CONFIG_COST_FLAG,
      null                                               CONFIG_PROFIT_FLAG,
      null                                               CONFIG_UTIL_FLAG,
      sysdate                                            START_DATE,
      null                                               END_DATE,
      null                                               COMPLETION_TEXT
    from
      dual;

    -- PJP summarization tables with persistent data
    delete from PJI_MT_PRC_STEPS       where PROCESS_NAME like (PJI_RM_SUM_MAIN.g_process || '%');
    delete from PJI_SYSTEM_PARAMETERS  where NAME         like (PJI_RM_SUM_MAIN.g_process || '%$%') or
                                             NAME         like 'DANGLING_PJI_ROWS_EXIST' or
                                             NAME         like 'LAST_PJI_EXTR_DATE';

    -- PJI facts
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_RES_F',            'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_RES_WT_F',         'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_AV_ORG_F',            'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_CA_ORG_F',            'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_PROJ_ET_WT_F',     'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_PROJ_ET_F',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FP_PROJ_F',           'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_AC_PROJ_F',           'NORMAL', null);

    -- PJP intermediate summarization tables
    delete from PJI_SYSTEM_PRC_STATUS where PROCESS_NAME like (PJI_RM_SUM_MAIN.g_process || '%');

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PROJECT_CLASSES',     'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RESOURCES_DENORM',    'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_WORK_TYPE_INFO',   'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_CLASS_CATEGORIES',    'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_CLASS_CODES',         'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_ORG_DENORM',          'NORMAL', null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_HELPER_BATCH_MAP',    'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJI_PROJ_EXTR_STATUS','NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJI_PROJ_BATCH_MAP',  'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_EXTR_PLN',         'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_EXTR_PLN_LOG',     'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_EXTR_PLNVER1',     'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_EXTR_PLNVER2',     'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_EXTR_PLAN',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJ_EXTR_PRJCLS',      'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_DLY_RATES',   'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_PLN',         'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_FIN3',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_FIN4',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_FIN5',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJI_RMAP_FIN',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_AGGR_ACT3',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJI_RMAP_ACT',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_RMAP_FIN',         'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_FM_RMAP_ACT',         'NORMAL', null);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RES_DELTA',           'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_ORG_EXTR_STATUS',     'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_ORG_BATCH_MAP',    'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_REXT_FCSTITEM',    'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_DNGL_RES',         'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_AGGR_RES1',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_AGGR_RES2',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_AGGR_RES3',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_PJI_RMAP_RES',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_AGGR_AVL1',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_AGGR_AVL2',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_AGGR_AVL3',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_AGGR_AVL4',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_AGGR_AVL5',        'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_ROLL_WEEK_OFFSET',    'NORMAL', null);
    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_pji_schema, 'PJI_RM_RES_BATCH_MAP',    'NORMAL', null);

    retcode := 0;

    PJI_PJI_EXTRACTION_UTILS.MVIEW_REFRESH(errbuf, retcode, 'All', 'C', 'N');

    update PJI_SYSTEM_CONFIG_HIST
    set    END_DATE = sysdate,
           COMPLETION_TEXT = 'Normal completion'
    where  PROCESS_NAME = 'STAGE2' and
           END_DATE is null;

    commit;

    exception when others then

      rollback;

      l_sqlerrm := substr(sqlerrm, 1, 240);

      update PJI_SYSTEM_CONFIG_HIST
      set    END_DATE = sysdate,
             COMPLETION_TEXT = l_sqlerrm
      where  PROCESS_NAME = 'STAGE2' and
             END_DATE is null;

      commit;

      raise;

  end TRUNCATE_PJI_TABLES;


end PJI_PJI_EXTRACTION_UTILS;

/
