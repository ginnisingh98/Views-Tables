--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_WO_CST_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_WO_CST_ETL_PKG" 
/* $Header: iscmaintwocstetb.pls 120.0 2005/05/25 17:31:32 appldev noship $ */
as

  g_pkg_name constant varchar2(30) := 'isc_maint_wo_cst_etl_pkg';
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
  g_object_name constant varchar2(30) := 'ISC_MAINT_WO_CST_FACT';
  g_max_date constant date := to_date('4712/01/01','yyyy/mm/dd');

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
  bis_collection_utilities.log( g_pkg_name || '.' || p_proc_name ||
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

function compute_cost_conv_rates
( p_isc_schema in varchar2
, x_error_message out nocopy varchar2 )
return number as

  l_proc_name constant varchar2(30):= 'compute_cost_conv_rates';
  l_stmt_id number;

  l_global_currency_code1 varchar2(15);
  l_global_rate_type1 varchar2(15);
  l_global_currency_code2 varchar2(15);
  l_global_rate_type2 varchar2(15);

  /* EURO currency became official on 01-JAN-1999 */
  l_euro_start_date constant date := to_date ('01/01/1999', 'mm/dd/yyyy');

  /* GL API returns -3 if EURO rate missing on 01-JAN-1999 */
  l_euro_missing_at_start constant number := -3;

  l_all_rates_found boolean;

  -- Set up a cursor to get all the invalid rates.
  -- By the logic of the fii_currency.get_global_rate_primary
  -- API, the returned value is -ve if no rate exists:
  -- -1 for dates with no rate.
  -- -2 for unrecognized conversion rates.
  -- Also, cross check with the org-date pairs in the staging table,
  -- in case some orgs never had a functional currency code defined.
  cursor c_invalid_rates is
    select distinct
      mp.organization_code
    , decode( least( r.conversion_rate1, r.conversion_rate2 )
            , l_euro_missing_at_start, l_euro_start_date
            , r.transaction_date) transaction_date
    , r.base_currency_code
    , nvl(r.conversion_rate1, -999) primary_rate
    , nvl(r.conversion_rate2, -999) secondary_rate
    from
      isc_maint_wo_cst_conv_rates r
    , mtl_parameters mp
    , ( select /*+ index_ffs(isc_maint_wo_cst_sum_stg) */ distinct
          organization_id
        , completion_date
        from isc_maint_wo_cst_sum_stg
      ) s
    where ( nvl(r.conversion_rate1, -999) < 0 or
            nvl(r.conversion_rate2, -999) < 0 )
    and mp.organization_id = s.organization_id
    and r.transaction_date (+) = s.completion_date
    and r.organization_id (+) = s.organization_id;

  l_exception exception;
  l_error_message varchar2(4000);
  l_rowcount number;

begin

  bis_collection_utilities.log( 'Begin Currency Conversion', 1 );

  -- get the primary global currency code
  l_stmt_id := 10;
  l_global_currency_code1 := bis_common_parameters.get_currency_code;
  if l_global_currency_code1 is null then
    l_error_message := 'Unable to get primary global currency code.'; -- translatable message?
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Primary global currency code: ' || l_global_currency_code1, 2 );

  -- get the primary global rate type
  l_stmt_id := 20;
  l_global_rate_type1 := bis_common_parameters.get_rate_type;
  if l_global_rate_type1 is null then
    l_error_message := 'Unable to get primary global rate type.'; -- translatable message?
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Primary global rate type: ' || l_global_rate_type1, 2 );

  -- get the secondary global currency code
  l_stmt_id := 30;
  l_global_currency_code2 := bis_common_parameters.get_secondary_currency_code;

  if l_global_currency_code2 is not null then
    bis_collection_utilities.log( 'Secondary global currency code: ' || l_global_currency_code2, 2 );
  else
    bis_collection_utilities.log( 'Secondary global currency code is not defined', 2 );
  end if;

  -- get the secondary global rate type
  l_stmt_id := 40;
  l_global_rate_type2 := bis_common_parameters.get_secondary_rate_type;
  if l_global_rate_type2 is null and l_global_currency_code2 is not null then
    l_error_message := 'Unable to get secondary global rate type.'; -- translatable message?
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  if l_global_currency_code2 is not null then
    bis_collection_utilities.log( 'Secondary global rate type: ' || l_global_rate_type2, 2 );
  end if;

  -- truncate the conversion rates work table
  l_stmt_id := 50;
  if truncate_table
     ( p_isc_schema
     , 'ISC_MAINT_WO_CST_CONV_RATES'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Currency conversion table truncated', 2 );

  -- Get all the distinct organization and date pairs and the
  -- base currency codes for the orgs into the conversion rates
  -- work table.

  -- Use the fii_currency.get_global_rate_primary function to get the
  -- conversion rate given a currency code and a date.
  -- only attempt to get conversion rate for rows that are complete
  -- (have complete_flag = 'Y')
  --
  -- The function returns:
  -- 1 for currency code when is the global currency
  -- -1 for dates for which there is no currency conversion rate
  -- -2 for unrecognized currency conversion rates

  -- By selecting distinct org and currency code from the gl_set_of_books
  -- and hr_organization_information, take care of duplicate codes.

  l_stmt_id := 60;
  insert /*+ append */
  into isc_maint_wo_cst_conv_rates
  ( organization_id
  , transaction_date
  , base_currency_code
  , conversion_rate1
  , conversion_rate2
  , creation_date
  , last_update_date
  , created_by
  , last_updated_by
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  )
  select
    s.organization_id
  , s.completion_date
  , c.currency_code
  , decode( s.completed_flag -- only attempt conversion for real completion dates
          , 'Y', fii_currency.get_global_rate_primary
                              ( c.currency_code
                              , s.completion_date )
          , 0
          ) conversion_rate1
  , decode( l_global_currency_code2
          , null, 0 -- only attempt conversion if secondary currency defined
          , decode( s.completed_flag -- only attempt conversion for real completion dates
                  , 'Y', fii_currency.get_global_rate_secondary
                              ( c.currency_code
                              , s.completion_date )
                  , 0
                  )
          ) conversion_rate2
  , sysdate
  , sysdate
  , g_user_id
  , g_user_id
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  from
    ( select /*+ index_ffs(isc_maint_wo_cst_sum_stg)
                 parallel_index(isc_maint_wo_cst_sum_stg) */ distinct
        organization_id
      , completion_date
      , completed_flag
      from
        isc_maint_wo_cst_sum_stg
    ) s
  , ( select distinct
        hoi.organization_id
      , gsob.currency_code
      from
        hr_organization_information hoi
      , gl_sets_of_books gsob
      where hoi.org_information_context  = 'Accounting Information'
      and hoi.org_information1  = to_char(gsob.set_of_books_id)
    ) c
  where c.organization_id  = s.organization_id;

  l_rowcount := sql%rowcount;

  commit;

  bis_collection_utilities.log( l_rowcount || ' rows inserted into currency conversion table', 2 );

  l_all_rates_found := true;

  -- gather statistics on conversion rates table before returning
  l_stmt_id := 70;
  if gather_statistics
     ( p_isc_schema
     , 'ISC_MAINT_WO_CST_CONV_RATES'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Currency conversion table analyzed', 2 );

  -- Check that all rates have been found and are non-negative.
  -- If there is a problem, notify user.
  l_stmt_id := 80;
  for invalid_rate_rec in c_invalid_rates loop

    -- print the header out
    if c_invalid_rates%rowcount = 1 then
      bis_collection_utilities.writeMissingRateHeader;
    end if;

    l_all_rates_found := false;

    if invalid_rate_rec.primary_rate < 0 then
      bis_collection_utilities.writeMissingRate
      ( l_global_rate_type1
      , invalid_rate_rec.base_currency_code
      , l_global_currency_code1
      , invalid_rate_rec.transaction_date );
    end if;

    if invalid_rate_rec.secondary_rate < 0 then
      bis_collection_utilities.writeMissingRate
      ( l_global_rate_type2
      , invalid_rate_rec.base_currency_code
      , l_global_currency_code2
      , invalid_rate_rec.transaction_date );
    end if;

  end loop;

  -- If all rates not found raise an exception
  if not l_all_rates_found then
    l_error_message := 'Missing currency rates exist.'; -- translatable message?
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'End Currency Conversion', 1 );

  return 0;

exception

  when l_exception then
    x_error_message := l_error_message;
    return -1;

  when others then
    rollback;
    l_error_message := substr( sqlerrm, 1, 4000 );
    logger( l_proc_name, l_stmt_id, l_error_message );
    x_error_message := 'Load conversion rate computation failed'; -- translatable message?
    return -1;

end compute_cost_conv_rates;

function get_last_refresh_date
( x_refresh_date out nocopy date
, x_error_message out nocopy varchar2 )
return number as

  l_refresh_date date;

begin

  l_refresh_date := fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period(g_object_name));
  if l_refresh_date = g_global_start_date then
    x_error_message := 'Incremental Load can only be run after a completed initial or incremental load';
    return -1;
  end if;

  x_refresh_date := l_refresh_date;
  return 0;

exception
  when others then
    x_error_message := 'Error in function get_last_refresh_date : ' || sqlerrm;
    return -1;

end get_last_refresh_date;


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

  l_timer number;
  l_rowcount number;
  l_temp_rowcount number;

  l_collect_from_date date;
  l_collect_to_date date;

  type t_number_tab is table of number;
  l_organization_tbl t_number_tab;
  l_work_order_tbl t_number_tab;

begin

  local_init;

  bis_collection_utilities.log( 'Begin Initial Load' );

  l_stmt_id := 0;
  if not bis_collection_utilities.setup( g_object_name ) then
    l_error_message := 'Error in BIS_COLLECTION_UTILITIES.Setup';
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise g_bis_setup_exception;
  end if;

  -- determine the date we last collected to
  l_stmt_id := 10;
  if g_global_start_date is null then
    l_error_message := 'Unable to get DBI global start date.'; -- translatable message?
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  l_collect_from_date := g_global_start_date;
  l_collect_to_date := sysdate;

  bis_collection_utilities.log( 'From ' || fnd_date.date_to_displaydt(l_collect_from_date), 1 );
  bis_collection_utilities.log( 'To ' || fnd_date.date_to_displaydt(l_collect_to_date), 1 );

  -- get the isc schema name
  l_stmt_id := 20;
  if get_schema_name
     ( l_isc_schema
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- truncate the staging table
  l_stmt_id := 30;
  if truncate_table
     ( l_isc_schema
     , 'ISC_MAINT_WO_CST_SUM_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Staging table truncated', 1 );

  -- ------------------------------------------------------------
  -- this inserts into the staging table the "current"
  -- total actual and estimated costs for completed or closed
  -- work orders when nvl(completion_date,closed_date) on or
  -- after global start date.
  -- only cancelled work orders my be closed with no completion
  -- date -- to be confirmed.
  -- ------------------------------------------------------------
  l_stmt_id := 40;
  insert /*+ append parallel(s) */
  into isc_maint_wo_cst_sum_stg s
  ( organization_id
  , work_order_id
  , department_id
  , maint_cost_category
  , estimated_flag
  , completion_date
  , completed_flag
  , actual_mat_cost_b
  , actual_lab_cost_b
  , actual_eqp_cost_b
  , estimated_mat_cost_b
  , estimated_lab_cost_b
  , estimated_eqp_cost_b
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
  select /*+ parallel(wo) parallel(pb) */
    wo.organization_id
  , wo.work_order_id
  , nvl(pb.operations_dept_id,-1) -- nvl'd so merge stmt join is successful
  , nvl(pb.maint_cost_category,-1)-- nvl'd so merge stmt join is successful
  , decode( sum( sum( abs(pb.system_estimated_mat_cost)
                    + abs(pb.system_estimated_lab_cost)
                    + abs(pb.system_estimated_eqp_cost)
                    )
               ) over( partition by wo.organization_id, wo.work_order_id )
          , 0, 'N'
          , 'Y') estimated_flag
  , nvl(wo.completion_date,wo.closed_date)
  , 'Y'
  , sum(pb.actual_mat_cost)
  , sum(pb.actual_lab_cost)
  , sum(pb.actual_eqp_cost)
  , sum(pb.system_estimated_mat_cost)
  , sum(pb.system_estimated_lab_cost)
  , sum(pb.system_estimated_eqp_cost)
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
    isc_maint_work_orders_f wo
  , wip_eam_period_balances pb
  where
      wo.work_order_id = pb.wip_entity_id
  and wo.organization_id = pb.organization_id
  and nvl(wo.completion_date, wo.closed_date) >= g_global_start_date
  and wo.status_type in (4, 5, 12)
  group by
    wo.organization_id
  , wo.work_order_id
  , nvl(pb.operations_dept_id,-1)
  , nvl(pb.maint_cost_category,-1)
  , nvl(wo.completion_date,wo.closed_date);

  l_rowcount := sql%rowcount;

  bis_collection_utilities.log( l_rowcount || ' rows inserted into staging table', 1 );

  -- gather statistics on staging table before computing
  -- conversion rates
  l_stmt_id := 50;
  if gather_statistics
     ( l_isc_schema
     , 'ISC_MAINT_WO_CST_SUM_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Staging table analyzed', 1 );

  -- check currency conversion rates
  l_stmt_id := 60;
  if compute_cost_conv_rates
     ( l_isc_schema
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- truncate the fact table
  l_stmt_id := 70;
  if truncate_table
     ( l_isc_schema
     , 'ISC_MAINT_WO_CST_SUM_F'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Base summary table truncated', 1 );

  -- insert into base fact from staging table
  l_stmt_id := 80;
  insert /*+ append parallel(f) */
  into isc_maint_wo_cst_sum_f f
  ( organization_id
  , work_order_id
  , department_id
  , maint_cost_category
  , estimated_flag
  , completion_date
  , conversion_rate1
  , conversion_rate2
  , actual_mat_cost_b
  , actual_lab_cost_b
  , actual_eqp_cost_b
  , estimated_mat_cost_b
  , estimated_lab_cost_b
  , estimated_eqp_cost_b
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
  select /*+ parallel(s) parallel(c) */
    s.organization_id
  , s.work_order_id
  , s.department_id
  , s.maint_cost_category
  , s.estimated_flag
  , s.completion_date
  , c.conversion_rate1
  , decode( c.conversion_rate2
          , 0, null
          , c.conversion_rate2 )
  , s.actual_mat_cost_b
  , s.actual_lab_cost_b
  , s.actual_eqp_cost_b
  , s.estimated_mat_cost_b
  , s.estimated_lab_cost_b
  , s.estimated_eqp_cost_b
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
    isc_maint_wo_cst_sum_stg s
  , isc_maint_wo_cst_conv_rates c
  where
      c.organization_id = s.organization_id
  and c.transaction_date = s.completion_date;

  l_rowcount := sql%rowcount;

  commit;

  bis_collection_utilities.log( l_rowcount || ' rows inserted into base summary', 1 );

  -- house keeping -- cleanup staging/currency conversion tables
  l_stmt_id := 90;
  if truncate_table
     ( l_isc_schema
     , 'ISC_MAINT_WO_CST_SUM_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Staging table truncated', 1 );

  l_stmt_id := 100;
  if truncate_table
     ( l_isc_schema
     , 'ISC_MAINT_WO_CST_CONV_RATES'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Currency conversion table truncated', 1 );

  l_stmt_id := 110;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 );

  bis_collection_utilities.log('End Initial Load');

  errbuf := null;
  retcode := g_success;

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := l_error_message;
    retcode := g_error;

  when others then
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

  l_timer number;
  l_rowcount number;
  l_temp_rowcount number;

  l_collect_from_date date;
  l_collect_to_date date;

begin

  local_init;

  bis_collection_utilities.log( 'Begin Incremental Load' );

  l_stmt_id := 0;
  if not bis_collection_utilities.setup( g_object_name ) then
    l_error_message := 'Error in BIS_COLLECTION_UTILITIES.Setup';
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise g_bis_setup_exception;
  end if;

  -- determine the date we last collected to
  l_stmt_id := 10;
  if get_last_refresh_date(l_collect_to_date, l_error_message) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;
  l_collect_from_date := l_collect_to_date + 1/86400;
  l_collect_to_date := sysdate;

  bis_collection_utilities.log( 'From: ' || fnd_date.date_to_displaydt(l_collect_from_date), 1 );
  bis_collection_utilities.log( 'To: ' || fnd_date.date_to_displaydt(l_collect_to_date), 1 );

  -- get the isc schema name
  l_stmt_id := 20;
  if get_schema_name
     ( l_isc_schema
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- truncate the staging table
  l_stmt_id := 30;
  if truncate_table
     ( l_isc_schema
     , 'ISC_MAINT_WO_CST_SUM_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Staging table truncated', 1 );

  -- ------------------------------------------------------------
  -- this inserts into the staging table the "current"
  -- total actual and estimated costs for completed or closed
  -- work orders where the actual or estimated costs have been
  -- updated since the last collection OR
  -- the nvl(completion_date,closed_date) <> completion_date
  -- on base summary and the work order fact has been updated
  -- since the last collection
  -- ------------------------------------------------------------
  l_stmt_id := 40;
  insert /*+ append */
  into isc_maint_wo_cst_sum_stg
  ( organization_id
  , work_order_id
  , department_id
  , maint_cost_category
  , estimated_flag
  , completion_date
  , completed_flag
  , actual_mat_cost_b
  , actual_lab_cost_b
  , actual_eqp_cost_b
  , estimated_mat_cost_b
  , estimated_lab_cost_b
  , estimated_eqp_cost_b
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
    organization_id
  , work_order_id
  , nvl(operations_dept_id,-1) -- nvl'd so merge stmt join is successful
  , nvl(maint_cost_category,-1)-- nvl'd so merge stmt join is successful
  , decode( sum( sum( abs(system_estimated_mat_cost)
                    + abs(system_estimated_lab_cost)
                    + abs(system_estimated_eqp_cost)
                    )
               ) over( partition by organization_id, work_order_id )
          , 0, 'N'
          , 'Y') estimated_flag
  , decode( status_type
          , 4, completion_date -- complete
          , 5, completion_date -- complete - no charges
          , 12, nvl(completion_date,closed_date) -- closed
          , g_max_date )
  , decode( status_type
          , 4, 'Y'
          , 5, 'Y'
          , 12, 'Y'
          , 'N' )
  , sum(actual_mat_cost)
  , sum(actual_lab_cost)
  , sum(actual_eqp_cost)
  , sum(system_estimated_mat_cost)
  , sum(system_estimated_lab_cost)
  , sum(system_estimated_eqp_cost)
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
    ( select
        wo.organization_id
      , wo.work_order_id
      , wo.status_type
      , wo.completion_date
      , wo.closed_date
      , pb.operations_dept_id
      , pb.maint_cost_category
      , pb.actual_mat_cost
      , pb.actual_lab_cost
      , pb.actual_eqp_cost
      , pb.system_estimated_mat_cost
      , pb.system_estimated_lab_cost
      , pb.system_estimated_eqp_cost
      from
        wip_eam_period_balances pb
      , (
          -- identifies all completed/closed work orders that
          -- have at least on cost balance row updated since
          -- last collection
          select
            wo.organization_id
          , wo.work_order_id
          , wo.status_type
          , wo.completion_date
          , wo.closed_date
          from
            isc_maint_work_orders_f wo
          , wip_eam_period_balances pb
          where
              pb.last_update_date >= l_collect_from_date
          and wo.work_order_id = pb.wip_entity_id
          and wo.organization_id = pb.organization_id
          and wo.status_type in (4, 5, 12)
          --
          union
          --
          -- identifies all work orders that have been updated since last
          -- collection whos completion_date differs from the previously
          -- recorded completion_date (this allows us to verify the
          -- currency conversion for all changed completion_dates also
          -- allows us to clear completion_date for "un-completed" work
          -- orders)
          -- and identifies all completed or closed work orders that have
          -- been re-estimated since last collection (this allows us to
          -- catch work orders that have had a resource estimated deleted
          -- that resulted in a row being deleted from period balances)
          select
            wo.organization_id
          , wo.work_order_id
          , wo.status_type
          , wo.completion_date
          , wo.closed_date
          from
            isc_maint_work_orders_f wo
          , wip_eam_period_balances pb
          , isc_maint_wo_cst_sum_f f
          where
              wo.last_update_date >= l_collect_from_date
          and ( nvl(nvl(wo.completion_date,closed_date),g_max_date) <> nvl(f.completion_date,g_max_date) or
                -- this is necessary to pick up cost for any work order where the estimated
                -- resource was deleted this resulted in a
                ( wo.last_estimation_date >= l_collect_from_date and
                  nvl(wo.completion_date,closed_date) is not null )
              )
          and wo.work_order_id = pb.wip_entity_id
          and wo.organization_id = pb.organization_id
          -- need to outer join here to ensure we pick up completed work order that
          -- may not already exist in the wo cst base summary
          and wo.work_order_id = f.work_order_id(+)
          and wo.organization_id = f.organization_id(+)
        ) wo
      where
          wo.work_order_id = pb.wip_entity_id
      and wo.organization_id = pb.organization_id
      --
      union all
      --
      -- returns an all "zero" cost row from isc_maint_wo_cst_sum_f
      -- for all completed/closed work orders have been updated since
      -- last collection and have been re-estimated since last collection
      -- (this allows us to catch work orders that have had a resource
      -- estimated deleted that resulted in a row being deleted from
      -- period balances and zero out the isc_maint_wo_cst_sum_f row)
      select
        wo.organization_id
      , wo.work_order_id
      , wo.status_type
      , wo.completion_date
      , wo.closed_date
      , f.department_id
      , f.maint_cost_category
      , 0 actual_mat_cost
      , 0 actual_lab_cost
      , 0 actual_eqp_cost
      , 0 system_estimated_mat_cost
      , 0 system_estimated_lab_cost
      , 0 system_estimated_eqp_cost
      from
        isc_maint_work_orders_f wo
      , isc_maint_wo_cst_sum_f f
      where
          wo.status_type in (4, 5, 12)
      and wo.last_update_date >= l_collect_from_date
      and wo.last_estimation_date >= l_collect_from_date
      and wo.work_order_id = f.work_order_id
      and wo.organization_id = f.organization_id
    )
  group by
    organization_id
  , work_order_id
  , nvl(operations_dept_id,-1) -- nvl'd so merge stmt join is successful
  , nvl(maint_cost_category,-1)-- nvl'd so merge stmt join is successful
  , decode( status_type
          , 4, completion_date
          , 5, completion_date
          , 12, nvl(completion_date,closed_date)
          , g_max_date )
  , decode( status_type
          , 4, 'Y'
          , 5, 'Y'
          , 12, 'Y'
          , 'N' );

  l_rowcount := sql%rowcount;

  bis_collection_utilities.log( l_rowcount || ' rows inserted into staging table', 1 );

  -- gather statistics on staging table before computing
  -- conversion rates
  l_stmt_id := 50;
  if gather_statistics
     ( l_isc_schema
     , 'ISC_MAINT_WO_CST_SUM_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Staging table analyzed', 1 );

  -- check currency conversion rates
  l_stmt_id := 60;
  if compute_cost_conv_rates
     ( l_isc_schema
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- merge staging table into base fact
  l_stmt_id := 70;
  merge into isc_maint_wo_cst_sum_f f
  using
    ( select
        s.organization_id
      , s.work_order_id
      , s.department_id
      , s.maint_cost_category
      , s.estimated_flag
      , decode( s.completed_flag
              , 'Y', s.completion_date
              , null ) completion_date
      , decode( s.completed_flag
              , 'Y', c.conversion_rate1
              , null ) conversion_rate1
      , decode( s.completed_flag
              , 'Y', decode( c.conversion_rate2
                           , 0, null
                           , c.conversion_rate2
                           )
              , null ) conversion_rate2
      , decode( s.completed_flag
              , 'Y', s.actual_mat_cost_b
              , null ) actual_mat_cost_b
      , decode( s.completed_flag
              , 'Y', s.actual_lab_cost_b
              , null ) actual_lab_cost_b
      , decode( s.completed_flag
              , 'Y', s.actual_eqp_cost_b
              , null ) actual_eqp_cost_b
      , decode( s.completed_flag
              , 'Y', s.estimated_mat_cost_b
              , null ) estimated_mat_cost_b
      , decode( s.completed_flag
              , 'Y', s.estimated_lab_cost_b
              , null ) estimated_lab_cost_b
      , decode( s.completed_flag
              , 'Y', s.estimated_eqp_cost_b
              , null ) estimated_eqp_cost_b
      , sysdate creation_date
      , g_user_id created_by
      , sysdate last_update_date
      , g_user_id last_updated_by
      , g_login_id last_update_login
      , g_program_id program_id
      , g_program_login_id program_login_id
      , g_program_application_id program_application_id
      , g_request_id request_id
      from
        isc_maint_wo_cst_sum_stg s
      , isc_maint_wo_cst_conv_rates c
      where
          c.organization_id = s.organization_id
      and c.transaction_date = s.completion_date
    ) s
  on
    (     f.organization_id = s.organization_id
      and f.work_order_id = s.work_order_id
      and f.department_id = s.department_id
      and f.maint_cost_category = s.maint_cost_category
    )
  when matched then update
    set
      f.estimated_flag = s.estimated_flag
    , f.completion_date = s.completion_date
    , f.conversion_rate1 = s.conversion_rate1
    , f.conversion_rate2 = s.conversion_rate2
    , f.actual_mat_cost_b = s.actual_mat_cost_b
    , f.actual_lab_cost_b = s.actual_lab_cost_b
    , f.actual_eqp_cost_b = s.actual_eqp_cost_b
    , f.estimated_mat_cost_b = s.estimated_mat_cost_b
    , f.estimated_lab_cost_b = s.estimated_lab_cost_b
    , f.estimated_eqp_cost_b = s.estimated_eqp_cost_b
    , f.last_update_date = s.last_update_date
    , f.last_updated_by = s.last_updated_by
    , f.last_update_login = s.last_update_login
    , f.program_id = s.program_id
    , f.program_login_id = s.program_login_id
    , f.program_application_id = s.program_application_id
    , f.request_id = s.request_id
  when not matched then insert
    ( organization_id
    , work_order_id
    , department_id
    , maint_cost_category
    , estimated_flag
    , completion_date
    , conversion_rate1
    , conversion_rate2
    , actual_mat_cost_b
    , actual_lab_cost_b
    , actual_eqp_cost_b
    , estimated_mat_cost_b
    , estimated_lab_cost_b
    , estimated_eqp_cost_b
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
    values
    ( s.organization_id
    , s.work_order_id
    , s.department_id
    , s.maint_cost_category
    , s.estimated_flag
    , s.completion_date
    , s.conversion_rate1
    , s.conversion_rate2
    , s.actual_mat_cost_b
    , s.actual_lab_cost_b
    , s.actual_eqp_cost_b
    , s.estimated_mat_cost_b
    , s.estimated_lab_cost_b
    , s.estimated_eqp_cost_b
    , s.creation_date
    , s.created_by
    , s.last_update_date
    , s.last_updated_by
    , s.last_update_login
    , s.program_id
    , s.program_login_id
    , s.program_application_id
    , s.request_id
    );

  l_rowcount := sql%rowcount;

  commit;

  bis_collection_utilities.log( l_rowcount || ' rows merged into base summary', 1 );

  -- house keeping -- cleanup staging/currency conversion tables
  l_stmt_id := 80;
  if truncate_table
     ( l_isc_schema
     , 'ISC_MAINT_WO_CST_SUM_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Staging table truncated', 1 );

  l_stmt_id := 90;
  if truncate_table
     ( l_isc_schema
     , 'ISC_MAINT_WO_CST_CONV_RATES'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Currency conversion table truncated', 1 );

  l_stmt_id := 100;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 );

  bis_collection_utilities.log('End Incremental Load');

  errbuf := null;
  retcode := g_success;


exception
  when g_bis_setup_exception then
    rollback;
    errbuf := l_error_message;
    retcode := g_error;

  when others then
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

end incremental_load;

end isc_maint_wo_cst_etl_pkg;

/
