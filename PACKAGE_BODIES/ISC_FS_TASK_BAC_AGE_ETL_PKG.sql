--------------------------------------------------------
--  DDL for Package Body ISC_FS_TASK_BAC_AGE_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_TASK_BAC_AGE_ETL_PKG" 
/* $Header: iscfsbacageetlb.pls 120.2 2005/10/26 20:47:12 kreardon noship $ */
as

  g_pkg_name constant varchar2(30) := 'isc_fs_task_bac_age_etl_pkg';
  g_user_id  number;
  g_login_id number;
  g_program_id number;
  g_program_login_id number;
  g_program_application_id number;
  g_request_id number;
  g_success constant varchar2(10) := '0';
  g_error   constant varchar2(10) := '-1';
  g_warning constant varchar2(10) := '1';
  g_bis_setup_exception exception;
  g_global_start_date date;
  g_object_name constant varchar2(30) := 'ISC_FS_TASK_BAC_DATES_F';
  g_max_date constant date := to_date('4712/01/01','yyyy/mm/dd');

procedure bis_collection_utilities_log
( m varchar2, indent number default null )
as
begin
  --if indent is not null then
  --  for i in 1..indent loop
  --    dbms_output.put('__');
  --  end loop;
  --end if;
  --dbms_output.put_line(substr(m,1,254));

  bis_collection_utilities.log( substr(m,1,2000-(nvl(indent,0)*3)), nvl(indent,0) );

end bis_collection_utilities_log;

procedure local_init
as
begin
  g_user_id  := fnd_global.user_id;
  g_login_id := fnd_global.login_id;
  g_global_start_date := bis_common_parameters.get_global_start_date;
  g_program_id := fnd_global.conc_program_id;
  g_program_login_id := fnd_global.conc_login_id;
  g_program_application_id := fnd_global.prog_appl_id;
  g_request_id := fnd_global.conc_request_id;
end local_init;

procedure logger
( p_proc_name varchar2
, p_stmt_id number
, p_message varchar2
)
as
begin
  bis_collection_utilities_log( g_pkg_name || '.' || p_proc_name ||
                                ' #' || p_stmt_id || ' ' ||
                                p_message
                              , 3 );
end logger;

function get_schema_name
( x_schema_name   out nocopy varchar2
, x_error_message out nocopy varchar2 )
return number as

  l_isc_schema   varchar2(30);
  l_status       varchar2(30);
  l_industry     varchar2(30);

begin

  if fnd_installation.get_app_info('ISC', l_status, l_industry, l_isc_schema) then
    x_schema_name := l_isc_schema;
  else
    x_error_message := 'FND_INSTALLATION.GET_APP_INFO returned false';
    return -1;
  end if;

  return 0;

exception
  when others then
    x_error_message := 'Error in function get_schema_name : ' || sqlerrm;
    return -1;

end get_schema_name;

function truncate_table
( p_isc_schema    in varchar2
, p_table_name    in varchar2
, x_error_message out nocopy varchar2 )
return number as

begin

  execute immediate 'truncate table ' || p_isc_schema || '.' || p_table_name;

  return 0;

exception
  when others then
    x_error_message  := 'Error in function truncate_table : ' || sqlerrm;
    return -1;

end truncate_table;

function gather_statistics
( p_isc_schema    in varchar2
, p_table_name    in varchar2
, x_error_message out nocopy varchar2 )
return number as

begin

  fnd_stats.gather_table_stats( ownname => p_isc_schema
                              , tabname => p_table_name
                              );

  return 0;

exception
  when others then
    x_error_message  := 'Error in function gather_statistics : ' || sqlerrm;
    return -1;

end gather_statistics;

function get_last_refresh_date
( p_object_name in varchar2
, x_refresh_date out nocopy date
, x_error_message out nocopy varchar2 )
return number as

  l_refresh_date date;

begin

  l_refresh_date := fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period(p_object_name));
  x_refresh_date := l_refresh_date;
  return 0;

exception
  when others then
    x_error_message := 'Error in function get_last_refresh_date : ' || sqlerrm;
    return -1;

end get_last_refresh_date;

function load
( p_mode in varchar2
, p_collect_to_date in date
, p_isc_schema in varchar2
, x_rowcount out nocopy number
, x_error_message out nocopy varchar2
)
return number
as

  l_proc_name constant varchar2(30) := 'load';
  l_stmt_id number;

  l_collect_to_date date;
  l_collect_to_date_trunc date;
  l_max_aging_date date;

begin

  l_collect_to_date := p_collect_to_date;
  l_collect_to_date_trunc := trunc(p_collect_to_date);

  bis_collection_utilities_log( 'Begin current backlog age dates load', 1 );

  -- check last as at date if doing incremental_load
  l_stmt_id := 10;
  if p_mode = 'incremental_load' then
    select max(aging_date)
    into l_max_aging_date
    from isc_fs_task_bac_dates_c;
  else
    l_max_aging_date := l_collect_to_date_trunc-1;
  end if;

  l_stmt_id := 20;
  if trunc(l_max_aging_date) = l_collect_to_date_trunc then
    update isc_fs_task_bac_dates_c
    set aging_date = l_collect_to_date
    , last_update_date = sysdate
    , last_updated_by = g_user_id
    , last_update_login = g_login_id
    , program_id = g_program_id
    , program_login_id = g_program_login_id
    , program_application_id = g_program_application_id
    , request_id = g_request_id
    where aging_date = l_max_aging_date;

    bis_collection_utilities_log( 'Previous current as at date row updated in task current backlog age dates table', 2 );

    bis_collection_utilities_log( 'End current backlog age dates load', 1 );

    return 0;

  end if;

  -- truncate the isc_fs_task_bac_dates_c fact table
  l_stmt_id := 30;
  if truncate_table
     ( p_isc_schema
     , 'ISC_FS_TASK_BAC_DATES_C'
     , x_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, x_error_message );
    return -1;
  end if;

  bis_collection_utilities_log( 'Task current backlog age dates table truncated', 2 );

  -- insert into task current backlog age dates tables
  l_stmt_id := 40;

  insert
  into isc_fs_task_bac_dates_c
  ( aging_date
  , record_type_id
  , xtd_end_date_flag
  , week_start_date
  , ent_period_start_date
  , ent_qtr_start_date
  , ent_year_start_date
  , day_start_date
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  )
  select
    aging_date
  , sum( power(2,id) ) record_type_id
  , max(xtd_end_date_flag)
  , max(week_start_date)
  , max(ent_period_start_date)
  , max(ent_qtr_start_date)
  , max(ent_yr_start_date)
  , max(day_start_date)
  , sysdate
  , g_user_id
  , sysdate
  , g_user_id
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  from
    ( select -- WTD
        id
      , aging_date
      , decode(trunc(aging_date),end_date,'Y','N') xtd_end_date_flag
      , start_date week_start_date
      , to_date(null) ent_period_start_date
      , to_date(null) ent_qtr_start_date
      , to_date(null) ent_yr_start_date
      , to_date(null) day_start_date
      from
       ( select m.id
         , least(fii.end_date+86399/86400, m.the_date) aging_date
         , fii.start_date
         , fii.end_date
         , rank() over (partition by m.id  order by fii.start_date desc ) rnk
         from fii_time_week fii
         , (select
              id
            , case
                when id = 9 then FII_TIME_API.sd_lyswk(l_collect_to_date_trunc)+86399/86400
                when id = 5 then FII_TIME_API.sd_pwk(l_collect_to_date_trunc)+86399/86400
                else l_collect_to_date
              end the_date
            from oki_dbi_multiplexer_b
            where id in (1,5,9)
           ) m
         where fii.start_date < m.the_date
      )
      where rnk <= 13
      --
      union all
      --
      select -- MTD
        id
      , aging_date
      , decode(trunc(aging_date),end_date,'Y','N')
      , null
      , start_date
      , null
      , null
      , null
      from
       ( select m.id
         , least(fii.end_date+86399/86400, m.the_date) aging_date
         , fii.start_date
         , fii.end_date
         , rank() over (partition by m.id  order by fii.start_date desc ) rnk
         from fii_time_ent_period fii
         , (select
              id
            , case
                when id = 10 then FII_TIME_API.ent_sd_lysper_end(l_collect_to_date_trunc)+86399/86400
                when id = 6 then FII_TIME_API.ent_sd_pper_end(l_collect_to_date_trunc)+86399/86400
                else l_collect_to_date
              end the_date
            from oki_dbi_multiplexer_b
            where id in (2,6,10)
           ) m
         where fii.start_date < m.the_date
      )
      where rnk <= 12
      --
      union all
      --
      select -- QTD
        id
      , aging_date
      , decode(trunc(aging_date),end_date,'Y','N')
      , null
      , null
      , start_date
      , null
      , null
      from
       ( select m.id
         , least(fii.end_date+86399/86400, m.the_date) aging_date
         , fii.start_date
         , fii.end_date
         , rank() over (partition by m.id  order by fii.start_date desc ) rnk
         from fii_time_ent_qtr fii
         , (select
              id
            , case
                when id = 11 then FII_TIME_API.ent_sd_lysqtr_end(l_collect_to_date_trunc)+86399/86400
                when id = 7 then FII_TIME_API.ent_sd_pqtr_end (l_collect_to_date_trunc)+86399/86400
                else l_collect_to_date
              end the_date
            from oki_dbi_multiplexer_b
            where id in (3,7,11)
           ) m
         where fii.start_date < m.the_date
      )
      where (id in (3,7) and rnk <=8) or (id = 11 and rnk <= 4)
      --
      union all
      --
      select -- YTD
        id
      , aging_date
      , decode(trunc(aging_date),end_date,'Y','N')
      , null
      , null
      , null
      , start_date
      , null
      from
       ( select m.id
         , least(fii.end_date+86399/86400, m.the_date) aging_date
         , fii.start_date
         , fii.end_date
         , rank() over (partition by m.id  order by fii.start_date desc ) rnk
         from fii_time_ent_year fii
         , (select
              id
            , case
                when id = 12 then FII_TIME_API.ent_sd_lyr_end(l_collect_to_date_trunc)+86399/86400
                when id = 8 then FII_TIME_API.ent_sd_lyr_end(l_collect_to_date_trunc)+86399/86400
                else l_collect_to_date
              end the_date
            from oki_dbi_multiplexer_b
            where id in (4,8,12)
           ) m
         where fii.start_date < m.the_date
        )
      where rnk <= 4
      union all
      select -- DAY
        id
      , aging_date
      , 'N'
      , null
      , null
      , null
      , null
      , start_date
      from
       ( select m.id
         , least(fii.report_date+86399/86400, m.the_date) aging_date
         , fii.report_date start_date
         , rank() over (partition by m.id  order by fii.report_date desc ) rnk
         from fii_time_day fii
         , (select
              id
            , case
                when id = 15 then  FII_TIME_API.ent_sd_lyr_end(l_collect_to_date_trunc)+86399/86400
                when id = 14 then (l_collect_to_date_trunc - 1)+86399/86400
                else l_collect_to_date
              end the_date
            from oki_dbi_multiplexer_b
            where id in (13,14,15)
           ) m
         where fii.report_date < m.the_date
      )
      where rnk <= 7
    )
  group by aging_date;

  x_rowcount := sql%rowcount;

  bis_collection_utilities_log( x_rowcount || ' rows inserted into task current backlog age dates table', 2 );

  commit;

  -- gather stats for staging table
  l_stmt_id := 50;
  if gather_statistics
     ( p_isc_schema
     , 'ISC_FS_TASK_BAC_DATES_C'
     , x_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, x_error_message );
    return -1;
  end if;

  bis_collection_utilities_log( 'Gathered stats for current backlog age dates table', 2 );

  bis_collection_utilities_log( 'End current backlog age dates load', 1 );

  return 0;

exception
  when others then
    x_error_message := 'Error in function load : ' || sqlerrm;
    return -1;

end load;

-- -------------------------------------------------------------------
-- PUBLIC PROCEDURES
-- -------------------------------------------------------------------
procedure initial_load
( errbuf out nocopy varchar2
, retcode out nocopy number
)
as

  l_proc_name constant varchar2(30) := 'initial_load';
  l_stmt_id number;
  l_exception exception;
  l_error_message varchar2(4000);
  l_isc_schema varchar2(100);

  l_rowcount number;
  l_temp_rowcount number;

  l_collect_from_date date;
  l_collect_to_date date;

begin

  local_init;

  bis_collection_utilities_log( 'Begin Initial Load' );

  l_stmt_id := 0;
  if not bis_collection_utilities.setup( g_object_name ) then
    l_error_message := 'Error in BIS_COLLECTION_UTILITIES.Setup';
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise g_bis_setup_exception;
  end if;

  -- determine the date we last collected backlog to
  l_stmt_id := 10;
  if get_last_refresh_date( isc_fs_task_etl_pkg.g_object_name
                          , l_collect_to_date
                          , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  if l_collect_to_date = g_global_start_date then
    l_error_message := 'Load can only be run after a completed initial or incremental load of Task Activity and Backlog';
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  l_collect_from_date := l_collect_to_date;

  bis_collection_utilities_log( 'As At ' || fnd_date.date_to_displaydt(l_collect_to_date), 1 );

  -- get the isc schema name
  l_stmt_id := 20;
  if get_schema_name
     ( l_isc_schema
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- load current backlog age dates
  l_stmt_id := 30;
  if load
     ( l_proc_name
     , l_collect_to_date
     , l_isc_schema
     , l_rowcount
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- truncate the isc_fs_task_bac_dates_f fact table
  l_stmt_id := 40;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_TASK_BAC_DATES_F'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Task backlog age dates base summary table truncated', 1 );

  -- insert into isc_fs_task_bac_dates_f fact table
  l_stmt_id := 50;
  insert /*+ append f */
  into isc_fs_task_bac_dates_f f
  ( report_date
  , aging_date
  , xtd_end_date_flag
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  )
  select
    trunc(aging_date)
  , aging_date
  , xtd_end_date_flag
  , sysdate
  , g_user_id
  , sysdate
  , g_user_id
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  from
    isc_fs_task_bac_dates_c;

  l_temp_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_temp_rowcount || ' rows inserted into task backlog age dates base summary table', 1 );

  l_rowcount := nvl(l_rowcount,0) + l_temp_rowcount;

  commit;

  l_stmt_id := 60;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 );

  bis_collection_utilities_log('End Initial Load');

  errbuf := null;
  retcode := g_success;

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := l_error_message;
    retcode := g_error;
    bis_collection_utilities_log('End Initial Load with Error');

  when l_exception then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := g_error;
    bis_collection_utilities_log('End Initial Load with Error');

  when others then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    logger( l_proc_name, l_stmt_id, l_error_message );
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := g_error;
    bis_collection_utilities_log('End Initial Load with Error');

end initial_load;

procedure incremental_load
( errbuf out nocopy varchar2
, retcode out nocopy number
)
as

  l_proc_name constant varchar2(30) := 'incremental_load';
  l_stmt_id number;
  l_exception exception;
  l_error_message varchar2(4000);
  l_isc_schema varchar2(100);

  l_rowcount number;
  l_temp_rowcount number;

  l_collect_from_date date;
  l_collect_to_date date;

begin

  local_init;

  bis_collection_utilities_log( 'Begin Incremental Load' );

  l_stmt_id := 0;
  if not bis_collection_utilities.setup( g_object_name ) then
    l_error_message := 'Error in BIS_COLLECTION_UTILITIES.Setup';
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise g_bis_setup_exception;
  end if;

  -- determine the date we last collected to
  l_stmt_id := 10;
  if get_last_refresh_date( isc_fs_task_etl_pkg.g_object_name
                          , l_collect_to_date
                          , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  if l_collect_to_date = g_global_start_date then
    l_error_message := 'Load can only be run after a completed initial or incremental load of Task Activity and Backlog';
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  l_collect_from_date := l_collect_to_date;

  bis_collection_utilities_log( 'As At ' || fnd_date.date_to_displaydt(l_collect_to_date), 1 );

  -- get the isc schema name
  l_stmt_id := 20;
  if get_schema_name
     ( l_isc_schema
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- load current backlog age dates
  l_stmt_id := 30;
  if load
     ( l_proc_name
     , l_collect_to_date
     , l_isc_schema
     , l_rowcount
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- delete the "current" row for last aging as was probably a partitial day (<midnight)
  l_stmt_id := 40;
  delete from isc_fs_task_bac_dates_f
  where report_date = (select max(report_date) from isc_fs_task_bac_dates_f)
  and aging_date <> l_collect_to_date;

  if sql%rowcount > 0 then
    bis_collection_utilities_log( 'Previous current as at date row deleted from task backlog age dates base summary table', 1 );
  end if;

  -- cleanup isc_fs_task_bac_dates_f, remove old rows that are not for period ends
  l_stmt_id := 50;
  delete from isc_fs_task_bac_dates_f
  where report_date not in (select trunc(aging_date) from isc_fs_task_bac_dates_c);

  l_temp_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_temp_rowcount || ' rows deleted from task backlog age dates base summary table', 1 );
  l_rowcount := l_rowcount + l_temp_rowcount;

  -- insert into isc_fs_task_bac_dates_f fact table
  l_stmt_id := 60;
  insert
  into isc_fs_task_bac_dates_f
  ( report_date
  , aging_date
  , xtd_end_date_flag
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  )
  select
    trunc(aging_date) report_date
  , aging_date
  , xtd_end_date_flag
  , g_user_id
  , sysdate
  , g_user_id
  , sysdate
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  from
    isc_fs_task_bac_dates_c c
  where
      trunc(aging_date) not in (select report_date from isc_fs_task_bac_dates_f);

  l_temp_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_temp_rowcount || ' rows inserted into task backlog age dates base summary table', 1 );
  l_rowcount := l_rowcount + l_temp_rowcount;

  commit;

  l_stmt_id := 50;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 );

  bis_collection_utilities_log('End Incremental Load');

  errbuf := null;
  retcode := g_success;

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := l_error_message;
    retcode := g_error;
    bis_collection_utilities_log('End Incremental Load with Error');

  when l_exception then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := g_error;
    bis_collection_utilities_log('End Incremental Load with Error');

  when others then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    logger( l_proc_name, l_stmt_id, l_error_message );
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := g_error;
    bis_collection_utilities_log('End Incremental Load with Error');

end incremental_load;

function get_period_bit_tbl
return t_period_bit_tbl
is

  l_period_bit_tbl t_period_bit_tbl;

begin

  l_period_bit_tbl('WTD').curr := G_WTD;
  l_period_bit_tbl('WTD').prior_period := G_WTD_PP;
  l_period_bit_tbl('WTD').prior_year := G_WTD_PY;

  l_period_bit_tbl('MTD').curr := G_MTD;
  l_period_bit_tbl('MTD').prior_period := G_MTD_PP;
  l_period_bit_tbl('MTD').prior_year := G_MTD_PY;

  l_period_bit_tbl('QTD').curr := G_QTD;
  l_period_bit_tbl('QTD').prior_period := G_QTD_PP;
  l_period_bit_tbl('QTD').prior_year := G_QTD_PY;

  l_period_bit_tbl('YTD').curr := G_YTD;
  l_period_bit_tbl('YTD').prior_period := G_YTD_PP;
  l_period_bit_tbl('YTD').prior_year := G_YTD_PY;

  l_period_bit_tbl('DAY').curr := G_DAY;
  l_period_bit_tbl('DAY').prior_period := G_DAY_PP;
  l_period_bit_tbl('DAY').prior_year := G_DAY_PY;

  return l_period_bit_tbl;

end get_period_bit_tbl;

end isc_fs_task_bac_age_etl_pkg;

/
