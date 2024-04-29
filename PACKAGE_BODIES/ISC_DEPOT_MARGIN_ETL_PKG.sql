--------------------------------------------------------
--  DDL for Package Body ISC_DEPOT_MARGIN_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DEPOT_MARGIN_ETL_PKG" as
/* $Header: iscdepotmrgetlb.pls 120.1 2006/09/21 01:21:04 kreardon noship $ */

-- File scope variables
g_isc_schema             varchar2(30);
g_global_start_date      date;
g_global_curr_code       varchar2(30);
g_global_sec_curr_code   varchar2(30);
g_global_rate_type       varchar2(30);
g_global_sec_rate_type   varchar2(30);

g_user_id                number;
g_login_id               number;
g_program_id             number;
g_program_login_id       number;
g_program_application_id number;
g_request_id             number;

g_charges_object_name  constant varchar2(30) := 'ISC_DR_CHARGES_F';
g_costs_object_name    constant varchar2(30) := 'ISC_DR_COSTS_F';

--  Common Procedures Definitions

--  err_mesg
function err_mesg
( p_mesg      in varchar2
, p_proc_name in varchar2 default null
, p_stmt_id   in number default -1
)
return varchar2
is

  l_formatted_message varchar2(3000);

begin

  l_formatted_message := substr( p_proc_name || ' #' || to_char (p_stmt_id) ||
                                 ': ' || p_mesg
                               , 1
                               , c_errbuf_size
                               );
  return l_formatted_message;

exception

  when others then
    -- the exception happened in the exception reporting function !!
    -- return with ERROR.
    l_formatted_message := 'Error in error reporting. ' || p_mesg;
    return l_formatted_message;

end err_mesg;

--  check_initial_load_setup
function check_initial_load_setup
( x_message           out nocopy varchar2
)
return number
is

  l_func_name     constant varchar2(40) := 'check_initial_load_setup';
  l_stmnt_id      number;
  l_setup_good    boolean;
  l_status        varchar2(30);
  l_industry      varchar2(30);
  l_exception     exception;
  l_message       varchar2(1000);

begin

  -- Check for the global start date setup.
  -- These parameter must be set up prior to any DBI load.

  l_stmnt_id := 0;
  g_global_start_date := trunc(bis_common_parameters.get_global_start_date);

  l_stmnt_id := 10;
  g_global_curr_code := bis_common_parameters.get_currency_code;

  l_stmnt_id := 20;
  g_global_sec_curr_code := bis_common_parameters.get_secondary_currency_code;

  l_stmnt_id := 30;
  g_global_rate_type := bis_common_parameters.get_rate_type;

  l_stmnt_id := 40;
  g_global_sec_rate_type := bis_common_parameters.get_secondary_rate_type;

  l_stmnt_id := 50;
  if g_global_start_date is null or
     g_global_curr_code is null or
     g_global_rate_type is null then

    l_message := 'Please check the Global Start Date, Global Currency Code, ' ||
                 'Global Rate Type. One of these variables is NULL. ' ||
                 'Please define the same and re-run the load';
    raise l_exception;

  end if;

  l_stmnt_id := 60;
  if g_global_sec_curr_code is not null and
     g_global_sec_rate_type is null then

     l_message := 'The Secondary Global Rate Type is NULL. ' ||
                  'Please define the same and re-run the load';
    raise l_exception;

  end if;

  l_stmnt_id := 70;
  l_setup_good := fnd_installation.get_app_info
                  ( 'ISC'
                  , l_status
                  , l_industry
                  , g_isc_schema
                  );

  l_stmnt_id := 80;
  if l_setup_good = false or g_isc_schema is null then

    l_message := 'ISC schema not found';
    raise l_exception;

  end if;

  -- Initialize the Standard WHO variables.
  l_stmnt_id := 90;
  g_user_id                := nvl(fnd_global.user_id,-1);
  g_login_id               := nvl(fnd_global.login_id,-1);
  g_program_id             := nvl(fnd_global.conc_program_id,-1);
  g_program_login_id       := nvl(fnd_global.conc_login_id,-1);
  g_program_application_id := nvl(fnd_global.prog_appl_id,-1);
  g_request_id             := nvl(fnd_global.conc_request_id,-1);

  return c_ok;

exception

  when l_exception then
    x_message := err_mesg( l_message, l_func_name, l_stmnt_id );
    bis_collection_utilities.put_line( x_message );
    return c_error;

  when others then
    x_message := err_mesg( sqlerrm, l_func_name, l_stmnt_id );
    bis_collection_utilities.put_line( x_message );
    return c_error;

end check_initial_load_setup;


--  load_costs_staging
function load_costs_staging
( p_run_date  in date
, p_load_type in varchar2
, x_message   out nocopy varchar2
)
return number
is

  l_func_name     constant varchar2(40) := 'load_costs_staging';
  l_stmnt_id      number;
  l_rowcount      number;

begin

  bis_collection_utilities.log( 'Begin load staging table', 1 );

  l_stmnt_id := 10;
  if p_load_type = 'init_load' then         -- initial load

    insert  /*+ append parallel(isc_dr_costs_stg) */
    into isc_dr_costs_stg
    ( repair_line_id
    , work_order_id
    , func_currency_code
    , date_closed
    , material_cost_b
    , labor_cost_b
    , expense_cost_b
    )
    select  /*+ ordered use_hash( crjx, rof,wpb, hoi, gsob)
                parallel (crjx) parallel(rof) parallel(wpb) parallel(hoi) */
      rof.repair_line_id repair_line_id
    , crjx.wip_entity_id work_order_id
    , gsob.currency_code func_currency_code
    , rof.dbi_date_closed date_closed
    , sum( nvl(wpb.pl_material_in,0) ) material_cost_b
    , sum( nvl(wpb.tl_resource_in,0) + nvl(wpb.pl_resource_in,0) ) labor_cost_b
    , sum( nvl(pl_material_overhead_in,0)
         + nvl(tl_overhead_in,0)
         + nvl(pl_overhead_in,0)
         + nvl(tl_outside_processing_in,0)
         + nvl(pl_outside_processing_in,0) ) expense_cost_b
    from
      isc_dr_repair_orders_f      rof
    , csd_repair_job_xref         crjx
    , wip_period_balances         wpb
    , ( select wip_entity_id
        from csd_repair_job_xref xref
        group by xref.wip_entity_id
        having count(1) = 1
      ) crjx1
    , hr_organization_information hoi
    , gl_sets_of_books            gsob
    where
        rof.repair_line_id = crjx.repair_line_id
    and crjx.wip_entity_id = wpb.wip_entity_id
    and hoi.org_information_context  = 'Accounting Information'
    and hoi.org_information1 = to_char(gsob.set_of_books_id)
    and hoi.organization_id = wpb.organization_id
    and rof.status = 'C'
    and crjx1.wip_entity_id = wpb.wip_entity_id
    and rof.ro_creation_date >= p_run_date
    group by
      crjx.wip_entity_id
    , rof.repair_line_id
    , gsob.currency_code
    , rof.dbi_date_closed;

    l_rowcount := sql%rowcount;
    bis_collection_utilities.log( 'Inserted ' || l_rowcount || ' insert staging table', 2 );


  else                        -- incremental load

    l_stmnt_id := 20;

    insert /*+ append parallel(isc_dr_costs_stg) */
    into isc_dr_costs_stg
    ( repair_line_id
    , work_order_id
    , func_currency_code
    , date_closed
    , material_cost_b
    , labor_cost_b
    , expense_cost_b
    )
    select
      rof.repair_line_id repair_line_id
    , crjx.wip_entity_id work_order_id
    , gsob.currency_code func_currency_code
    , rof.dbi_date_closed date_closed
    , sum( nvl(wpb.pl_material_in,0) ) material_cost_b
    , sum( nvl(wpb.tl_resource_in,0) + nvl(wpb.pl_resource_in,0) ) labor_cost_b
    , sum( nvl(pl_material_overhead_in,0)
         + nvl(tl_overhead_in,0)
         + nvl(pl_overhead_in,0)
         + nvl(tl_outside_processing_in,0)
         + nvl(pl_outside_processing_in,0)
         ) expense_cost_b
    from
      isc_dr_repair_orders_f      rof
    , csd_repair_job_xref         crjx
    , wip_period_balances         wpb
    , ( select wip_entity_id
        from csd_repair_job_xref xref
        group by xref.wip_entity_id
        having count (1) = 1
      ) crjx1
    , hr_organization_information hoi
    , gl_sets_of_books            gsob
    where
        rof.repair_line_id = crjx.repair_line_id
    and crjx.wip_entity_id = wpb.wip_entity_id
    and hoi.org_information_context  = 'Accounting Information'
    and hoi.org_information1 = to_char(gsob.set_of_books_id)
    and hoi.organization_id = wpb.organization_id
    and rof.status = 'C'
    and crjx1.wip_entity_id = wpb.wip_entity_id
    and rof.date_closed >= p_run_date
    and rof.ro_creation_date >= g_global_start_date
    group by
      crjx.wip_entity_id
    , rof.repair_line_id
    , gsob.currency_code
    , rof.dbi_date_closed;

    l_rowcount := sql%rowcount;
    bis_collection_utilities.log( 'Inserted ' || l_rowcount || ' insert staging table', 2 );

  end if;

  l_stmnt_id := 30;
  commit;

  l_stmnt_id := 40;
  fnd_stats.gather_table_stats
  ( ownname => g_isc_schema
  , tabname => 'ISC_DR_COSTS_STG'
  , percent=> 10
  );

  bis_collection_utilities.log( 'Gather statistics onstaging table', 2 );

  bis_collection_utilities.log( 'End load staging table', 1 );

  return c_ok;

exception

  when others then
    x_message := err_mesg( sqlerrm, l_func_name, l_stmnt_id );
    bis_collection_utilities.put_line( x_message );
    return c_error;

end load_costs_staging;

--  load_costs_conv_rates

function load_costs_conv_rates
( x_message   out nocopy varchar2
)
return number
is

  l_func_name     constant varchar2(40) := 'load_costs_conv_rates';
  l_stmnt_id      number;
  l_missing_rate_count number;
  l_rowcount      number;

  cursor get_missing_rates_c is
    select
      func_currency_code
    , date_closed
    , g_conv_rate
    , sg_conv_rate
    from
      isc_dr_costs_conv_tmp
    where
       g_conv_rate < 0
    or ( sg_conv_rate < 0 and g_global_sec_curr_code is not null );

  get_missing_rates_rec get_missing_rates_c%rowtype;

begin

  bis_collection_utilities.log( 'Begin currency conversion', 1 );

  l_stmnt_id := 10;
  insert
  into isc_dr_costs_conv_tmp
  ( func_currency_code
  , date_closed
  , g_conv_rate
  , sg_conv_rate
  )
  select
    costs.func_currency_code
  , costs.date_closed
  , decode( costs.func_currency_code
          , g_global_curr_code, 1
          , fii_currency.get_rate( costs.func_currency_code
                                 , g_global_curr_code
                                 , costs.date_closed
                                 , g_global_rate_type
                                 )
          ) g_conv_rate
  , decode( g_global_sec_curr_code
          , null, null
          , costs.func_currency_code, 1
          , fii_currency.get_rate( costs.func_currency_code
                                 , g_global_sec_curr_code
                                 , costs.date_closed
                                 , g_global_sec_rate_type
                                 )
          ) sg_conv_rate
  from
    ( select distinct
        func_currency_code
      , date_closed
      from isc_dr_costs_stg
      order by func_currency_code, date_closed
    ) costs;

  l_rowcount := sql%rowcount;
  bis_collection_utilities.log( 'Inserted ' || l_rowcount || ' rows into currency conversion table', 2 );

  l_stmnt_id := 20;
  l_missing_rate_count := 0;

  l_stmnt_id := 30;
  -- Handle Missing Currency Conversion Rates
  open get_missing_rates_c;
  l_stmnt_id := 40;
  fetch get_missing_rates_c into get_missing_rates_rec;

  while get_missing_rates_c%found loop
    exit when get_missing_rates_c%notfound;

    l_missing_rate_count := l_missing_rate_count + 1;

    if l_missing_rate_count = 1 then
      bis_collection_utilities.writemissingrateheader;
    end if;

    l_stmnt_id := 60;
    if  get_missing_rates_rec.g_conv_rate < 0 then
      bis_collection_utilities.writemissingrate
      ( g_global_rate_type
      , get_missing_rates_rec.func_currency_code
      , g_global_curr_code
      , get_missing_rates_rec.date_closed
      );
    elsif get_missing_rates_rec.sg_conv_rate < 0 and
          g_global_sec_curr_code is not null then
      bis_collection_utilities.writemissingrate
      ( g_global_sec_rate_type
      , get_missing_rates_rec.func_currency_code
      , g_global_sec_curr_code
      , get_missing_rates_rec.date_closed
      );
    end if;

    l_stmnt_id := 70;
    fetch get_missing_rates_c into get_missing_rates_rec;

  end loop;

  l_stmnt_id := 80;
  close get_missing_rates_c;

  if l_missing_rate_count <> c_ok then
   x_message := 'Missing Currency Conversion Rates';
  end if;

  bis_collection_utilities.log( 'There are ' || l_missing_rate_count || ' missing currency conversion rates', 2 );

  bis_collection_utilities.log( 'End currency conversion', 1 );

  return l_missing_rate_count;

exception

  when others then
    x_message := err_mesg( sqlerrm, l_func_name, l_stmnt_id );
    bis_collection_utilities.put_line( x_message );
    return c_error;

end load_costs_conv_rates;

--  charges_initial_load
--  Parameters:
--  retcode - 0 on successful completion, -1 on error and 1 for warning.
--  errbuf - empty on successful completion, message on error or warning
--

procedure charges_initial_load
( errbuf    in out nocopy  varchar2
, retcode   in out nocopy  number
)
is

  l_proc_name        constant varchar2(30) := 'charges_initial_load';
  l_stmnt_id         number;
  l_ro_last_run_date date;
  l_message          varchar2(32000);
  l_exception        exception;
  l_rowcount number;
  l_to_date date;

begin

  bis_collection_utilities.log( 'Begin Initial Load' );

  l_stmnt_id := 0;
  if not bis_collection_utilities.setup( g_charges_object_name ) then
    l_message := isc_depot_backlog_etl_pkg.err_mesg
                 ( 'Error in BIS_COLLECTION_UTILITIES.Setup'
                 , l_proc_name
                 , l_stmnt_id
                 );
    bis_collection_utilities.put_line( l_message );
    raise l_exception;
  end if;

  l_stmnt_id := 10;
  if check_initial_load_setup
     ( x_message => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Global Start Date: ' || fnd_date.date_to_displaydt(g_global_start_date), 1 );
  bis_collection_utilities.log( 'Primary Global Currency: ' || g_global_curr_code, 1 );
  bis_collection_utilities.log( 'Primary Global Currency Rate Type: ' || g_global_rate_type, 1 );
  bis_collection_utilities.log( 'Secondary Global Currency: ' || g_global_sec_curr_code, 1 );
  bis_collection_utilities.log( 'Secondary Global Currency Rate Type: ' || g_global_sec_rate_type, 1 );

  l_stmnt_id := 20;
  delete
  from isc_dr_inc
  where fact_name = 'ISC_DR_CHARGES_F';

  bis_collection_utilities.log( 'Deleted from table ISC_DR_INC', 1 );

  l_stmnt_id := 30;
  execute immediate 'TRUNCATE TABLE ' || g_isc_schema || '.ISC_DR_CHARGES_F';

  bis_collection_utilities.log( 'Truncated table ISC_DR_CHARGES_F', 1 );

  l_stmnt_id := 40;
  if isc_depot_backlog_etl_pkg.get_last_run_date
     ( p_fact_name => 'ISC_DR_REPAIR_ORDERS_F'
     , x_run_date  => l_ro_last_run_date
     , x_message   => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  if l_ro_last_run_date is null then
    l_message := 'Please launch the Intial Load Request Set for the Depot Repair Management page.';
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Repair Order To Date: ' || fnd_date.date_to_displaydt(l_ro_last_run_date), 1 );
  l_to_date := sysdate;

  l_stmnt_id := 50;
  insert /*+ append parallel(isc_dr_charges_f) */
  into isc_dr_charges_f
  ( repair_line_id
  , material_charges_g
  , labor_charges_g
  , expense_charges_g
  , material_charges_sg
  , labor_charges_sg
  , expense_charges_sg
  , created_by
  , creation_date
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  )
  select  /*+ use_hash(cra, rof, cral, ced, ibsf, ctbt)
              parallel(cra) parallel(rof) parallel(cral) parallel(ced) parallel(ibsf) parallel(ctbt) */
    rof.repair_line_id repair_line_id
  , sum( case
           when cbtc.billing_category = 'M' then
             ibsf.fulfilled_amt_g
           else 0
         end
       ) material_charges_g
  , sum( case
           when cbtc.billing_category = 'L' then
             ibsf.fulfilled_amt_g
           else 0
         end
       ) labor_charges_g
  , sum( case
           when cbtc.billing_category = 'E' then
             ibsf.fulfilled_amt_g
           else 0
         end
       ) expense_charges_g
  , sum( case
           when cbtc.billing_category = 'M' then
             ibsf.fulfilled_amt_g1
           else 0
         end
       ) material_charges_sg
  , sum( case
           when cbtc.billing_category = 'L' then
             ibsf.fulfilled_amt_g1
           else 0
         end
       ) labor_charges_sg
  , sum( case
           when cbtc.billing_category = 'E' then
             ibsf.fulfilled_amt_g1
           else 0
         end
       ) expense_charges_sg
  , g_user_id                 created_by
  , sysdate                   creation_date
  , sysdate                   last_update_date
  , g_user_id                 last_updated_by
  , g_login_id                last_update_login
  , g_program_id              program_id
  , g_program_login_id        program_login_id
  , g_program_application_id  program_application_id
  , g_request_id              request_id
  from
    csd_repair_actuals          cra
  , isc_dr_repair_orders_f      rof
  , csd_repair_actual_lines     cral
  , cs_estimate_details         ced
  , isc_book_sum2_f             ibsf
  , cs_txn_billing_types        ctbt
  , cs_billing_type_categories  cbtc
  where
      rof.repair_line_id = cra.repair_line_id
  and cra.repair_actual_id = cral.repair_actual_id
  and ced.estimate_detail_id = cral.estimate_detail_id
  and ced.order_line_id = ibsf.line_id
  and ced.txn_billing_type_id = ctbt.txn_billing_type_id
  and ctbt.billing_type = cbtc.billing_type
  and rof.repair_mode = 'WIP'
  and rof.status = 'C'
  and rof.ro_creation_date >= g_global_start_date
  group by rof.repair_line_id;

  l_rowcount := sql%rowcount;
  bis_collection_utilities.log( 'Inserted ' || l_rowcount || ' rows into ISC_DR_CHARGES_F' , 1 );

  l_stmnt_id := 60;
  commit;

  l_stmnt_id := 70;
  insert into isc_dr_inc
  ( fact_name
  , last_run_date
  , created_by
  , creation_date
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  )
  values
  ( 'ISC_DR_CHARGES_F'
  , l_ro_last_run_date
  , g_user_id
  , sysdate
  , sysdate
  , g_user_id
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  );

  bis_collection_utilities.log( 'Inserted into table ISC_DR_INC', 1 );

  l_stmnt_id := 80;
  commit;

  l_stmnt_id := 90;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => g_global_start_date
                                 , p_period_to => l_to_date
                                 , p_count => l_rowcount
                                 );

  retcode := c_ok;

  bis_collection_utilities.log( 'End Initial Load' );

exception

  when l_exception then
    rollback;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_period_from => g_global_start_date
                                   , p_period_to => l_to_date
                                   , p_message => l_message
                                   );
    retcode := c_error;
    errbuf := l_message;

  when others then
    rollback;
    l_message := err_mesg( sqlerrm, l_proc_name, l_stmnt_id );
    bis_collection_utilities.put_line( l_message );
    bis_collection_utilities.wrapup( p_status => false
                                   , p_period_from => g_global_start_date
                                   , p_period_to => l_to_date
                                   , p_message => l_message
                                   );
    retcode := c_error;
    errbuf := l_message;

end charges_initial_load;


--  costs_initial_load
--  Parameters:
--  retcode - 0 on successful completion, -1 on error and 1 for warning.
--  errbuf - empty on successful completion, message on error or warning
--

procedure costs_initial_load
( errbuf    in out nocopy  varchar2
, retcode   in out nocopy  number
)
is

  l_proc_name        constant varchar2(30) := 'costs_initial_load';
  l_stmnt_id         number;
  l_ro_last_run_date date;
  l_message          varchar2(32000);
  l_exception        exception;
  l_rowcount number;
  l_to_date date;

begin

  bis_collection_utilities.log( 'Begin Initial Load' );

  l_stmnt_id := 0;
  if not bis_collection_utilities.setup( g_costs_object_name ) then
    l_message := isc_depot_backlog_etl_pkg.err_mesg
                 ( 'Error in BIS_COLLECTION_UTILITIES.Setup'
                 , l_proc_name
                 , l_stmnt_id
                 );
    bis_collection_utilities.put_line( l_message );
    raise l_exception;
  end if;

  l_stmnt_id := 10;
  if check_initial_load_setup
     ( x_message => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Global Start Date: ' || fnd_date.date_to_displaydt(g_global_start_date), 1 );
  bis_collection_utilities.log( 'Primary Global Currency: ' || g_global_curr_code, 1 );
  bis_collection_utilities.log( 'Primary Global Currency Rate Type: ' || g_global_rate_type, 1 );
  bis_collection_utilities.log( 'Secondary Global Currency: ' || g_global_sec_curr_code, 1 );
  bis_collection_utilities.log( 'Secondary Global Currency Rate Type: ' || g_global_sec_rate_type, 1 );

  l_stmnt_id := 20;
  delete
  from isc_dr_inc
  where fact_name = 'ISC_DR_COSTS_F';

  bis_collection_utilities.log( 'Deleted from table ISC_DR_INC', 1 );

  l_stmnt_id := 30;
  execute immediate 'TRUNCATE TABLE ' || g_isc_schema || '.ISC_DR_COSTS_STG';

  bis_collection_utilities.log( 'Truncated table ISC_DR_COSTS_STG', 1 );

  l_stmnt_id := 40;
  execute immediate 'TRUNCATE TABLE ' || g_isc_schema || '.ISC_DR_COSTS_CONV_TMP';

  bis_collection_utilities.log( 'Truncated table ISC_DR_COSTS_CONV_TMP', 1 );

  l_stmnt_id := 50;
  execute immediate 'TRUNCATE TABLE ' || g_isc_schema || '.ISC_DR_COSTS_F';

  bis_collection_utilities.log( 'Truncated table ISC_DR_COSTS_F', 1 );

  l_stmnt_id := 60;
  if isc_depot_backlog_etl_pkg.get_last_run_date
     ( p_fact_name => 'ISC_DR_REPAIR_ORDERS_F'
     , x_run_date  => l_ro_last_run_date
     , x_message   => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  if l_ro_last_run_date is null then
    l_message := 'Please launch the Intial Load Request Set for the Depot Repair Management page.';
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Repair Order To Date: ' || fnd_date.date_to_displaydt(l_ro_last_run_date), 1 );
  l_to_date := sysdate;

  l_stmnt_id := 70;
  if load_costs_staging
     ( p_run_date  => g_global_start_date
     , p_load_type => 'INIT_LOAD'
     , x_message   => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  l_stmnt_id := 80;
  if load_costs_conv_rates
     ( x_message => l_message
     ) <> 0 then
    raise l_exception;
  end if;

  l_stmnt_id := 90;
  commit;

  l_stmnt_id := 100;
  insert /*+ append parallel(isc_dr_costs_f) */
  into isc_dr_costs_f
  ( repair_line_id
  , material_cost_g
  , labor_cost_g
  , expense_cost_g
  , material_cost_sg
  , labor_cost_sg
  , expense_cost_sg
  , created_by
  , creation_date
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  )
  select
    stg.repair_line_id repair_line_id
  , nvl(sum( stg.material_cost_b * rates.g_conv_rate ), 0) material_cost_g
  , nvl(sum( stg.labor_cost_b    * rates.g_conv_rate ), 0) labor_cost_g
  , nvl(sum( stg.expense_cost_b  * rates.g_conv_rate ), 0) expense_cost_g
  , nvl(sum( stg.material_cost_b * rates.sg_conv_rate ), 0) material_cost_sg
  , nvl(sum( stg.labor_cost_b    * rates.sg_conv_rate ), 0) labor_cost_sg
  , nvl(sum( stg.expense_cost_b  * rates.sg_conv_rate ), 0) expense_cost_sg
  , g_user_id                 created_by
  , sysdate                   creation_date
  , sysdate                   last_update_date
  , g_user_id                 last_updated_by
  , g_login_id                last_update_login
  , g_program_id              program_id
  , g_program_login_id        program_login_id
  , g_program_application_id  program_application_id
  , g_request_id              request_id
  from
    isc_dr_costs_stg        stg
  , isc_dr_costs_conv_tmp   rates
  where
      stg.func_currency_code = rates.func_currency_code
  and stg.date_closed = rates.date_closed
  group by stg.repair_line_id;

  l_rowcount := sql%rowcount;
  bis_collection_utilities.log( 'Inserted ' || l_rowcount || ' rows into ISC_DR_COSTS_F' , 1 );

  l_stmnt_id := 110;
  commit;

  l_stmnt_id := 120;
  insert into
  isc_dr_inc
  ( fact_name
  , last_run_date
  , created_by
  , creation_date
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  )
  values
  ( 'ISC_DR_COSTS_F'
  , l_ro_last_run_date
  , g_user_id
  , sysdate
  , sysdate
  , g_user_id
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  );

  bis_collection_utilities.log( 'Inserted into table ISC_DR_INC', 1 );

  l_stmnt_id := 130;
  commit;

  l_stmnt_id := 140;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => g_global_start_date
                                 , p_period_to => l_to_date
                                 , p_count => l_rowcount
                                 );

  retcode := c_ok;

  bis_collection_utilities.log( 'End Inital Load' );

exception

  when l_exception then
    rollback;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_period_from => g_global_start_date
                                   , p_period_to => l_to_date
                                   , p_message => l_message
                                   );
    retcode := c_error;
    errbuf := l_message;

  when others then
    rollback;
    l_message := err_mesg( sqlerrm, l_proc_name, l_stmnt_id );
    bis_collection_utilities.put_line( l_message );
    bis_collection_utilities.wrapup( p_status => false
                                   , p_period_from => g_global_start_date
                                   , p_period_to => l_to_date
                                   , p_message => l_message
                                   );
    retcode := c_error;
    errbuf := l_message;

end costs_initial_load;

-- charges_incr_load
-- Parameters:
-- retcode - 0 on successful completion, -1 on error and 1 for warning.
-- errbuf - empty on successful completion, message on error or warning

procedure charges_incr_load
( errbuf  in out nocopy varchar2
, retcode in out nocopy number)
is

  l_proc_name             constant varchar2(30) := 'charges_incr_load';
  l_stmnt_id              number;
  l_ro_last_run_date      date;
  l_charges_last_run_date date;
  l_message               varchar2(32000);
  l_exception             exception;
  l_rowcount number;
  l_to_date date;

begin

  bis_collection_utilities.log( 'Begin Incremental Load' );

  l_stmnt_id := 0;
  if not bis_collection_utilities.setup( g_charges_object_name ) then
    l_message := isc_depot_backlog_etl_pkg.err_mesg
                 ( 'Error in BIS_COLLECTION_UTILITIES.Setup'
                 , l_proc_name
                 , l_stmnt_id
                 );
    bis_collection_utilities.put_line( l_message );
    raise l_exception;
  end if;

  l_stmnt_id := 10;
  if check_initial_load_setup
     ( x_message => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Global Start Date: ' || fnd_date.date_to_displaydt(g_global_start_date), 1 );
  bis_collection_utilities.log( 'Primary Global Currency: ' || g_global_curr_code, 1 );
  bis_collection_utilities.log( 'Primary Global Currency Rate Type: ' || g_global_rate_type, 1 );
  bis_collection_utilities.log( 'Secondary Global Currency: ' || g_global_sec_curr_code, 1 );
  bis_collection_utilities.log( 'Secondary Global Currency Rate Type: ' || g_global_sec_rate_type, 1 );

  l_stmnt_id := 20;
  if isc_depot_backlog_etl_pkg.get_last_run_date
     ( p_fact_name => 'ISC_DR_REPAIR_ORDERS_F'
     , x_run_date  => l_ro_last_run_date
     , x_message   => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  if l_ro_last_run_date is null then
    l_message := 'Please run the Intial Load Request Set for the Depot Repair Management page.';
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Repair Order From Date: ' || fnd_date.date_to_displaydt(l_ro_last_run_date), 1 );

  l_stmnt_id := 30;
  if isc_depot_backlog_etl_pkg.get_last_run_date
     ( p_fact_name => 'ISC_DR_CHARGES_F'
     , x_run_date  => l_charges_last_run_date
     , x_message   => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  if l_charges_last_run_date is null then
    l_message := 'Please run the Intial Load Request Set for the Depot Repair Management page.';
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Charges From Date: ' || fnd_date.date_to_displaydt(l_charges_last_run_date), 1 );

  l_to_date := sysdate;

  l_stmnt_id := 40;
  merge into isc_dr_charges_f fact
  using
    ( select rof.repair_line_id repair_line_id
      , sum( case
               when cbtc.billing_category = 'M' then
                 ibsf.fulfilled_amt_g
               else 0
             end
           ) material_charges_g
      , sum( case
               when cbtc.billing_category = 'L' then
                 ibsf.fulfilled_amt_g
               else 0
             end
           ) labor_charges_g
      , sum( case
               when cbtc.billing_category = 'E' then
                 ibsf.fulfilled_amt_g
               else 0
             end
           ) expense_charges_g
      , sum( case
               when cbtc.billing_category = 'M' then
                 ibsf.fulfilled_amt_g1
               else 0
               end
           ) material_charges_sg
      , sum( case
               when cbtc.billing_category = 'L' then
                 ibsf.fulfilled_amt_g1
               else 0
             end
           ) labor_charges_sg
      , sum( case
               when cbtc.billing_category = 'E' then
                 ibsf.fulfilled_amt_g1
               else 0
             end
           ) expense_charges_sg
      , sysdate                   last_update_date
      , g_user_id                 last_updated_by
      , g_login_id                last_update_login
      , g_program_id              program_id
      , g_program_login_id        program_login_id
      , g_program_application_id  program_application_id
      , g_request_id              request_id
      from
        isc_dr_repair_orders_f          rof
      , cs_estimate_details             ced
      , csd_repair_actuals              cra
      , csd_repair_actual_lines         cral
      , cs_txn_billing_types            ctbt
      , cs_billing_type_categories      cbtc
      , isc_book_sum2_f                 ibsf
      where
          rof.repair_line_id = cra.repair_line_id
      and cra.repair_actual_id = cral.repair_actual_id
      and ced.estimate_detail_id = cral.estimate_detail_id
      and ced.order_line_id = ibsf.line_id
      and ced.txn_billing_type_id = ctbt.txn_billing_type_id
      and ctbt.billing_type = cbtc.billing_type
      and rof.repair_mode = 'WIP'
      and rof.status = 'C'
      and rof.date_closed >= l_charges_last_run_date
      and rof.ro_creation_date >= g_global_start_date
      group by
        rof.repair_line_id
    ) charges
  on
    ( fact.repair_line_id = charges.repair_line_id )
  when matched then
    update
    set fact.material_charges_g     = charges.material_charges_g
      , fact.labor_charges_g        = charges.labor_charges_g
      , fact.expense_charges_g      = charges.expense_charges_g
      , fact.material_charges_sg    = charges.material_charges_sg
      , fact.labor_charges_sg       = charges.labor_charges_sg
      , fact.expense_charges_sg     = charges.expense_charges_sg
      , fact.last_update_date       = charges.last_update_date
      , fact.last_updated_by        = charges.last_updated_by
      , fact.last_update_login      = charges.last_update_login
      , fact.program_id             = charges.program_id
      , fact.program_login_id       = charges.program_login_id
      , fact.program_application_id = charges.program_application_id
      , fact.request_id             = charges.request_id
  when not matched then
    insert
    ( fact.repair_line_id
    , fact.material_charges_g
    , fact.labor_charges_g
    , fact.expense_charges_g
    , fact.material_charges_sg
    , fact.labor_charges_sg
    , fact.expense_charges_sg
    , fact.created_by
    , fact.creation_date
    , fact.last_update_date
    , fact.last_updated_by
    , fact.last_update_login
    , fact.program_id
    , fact.program_login_id
    , fact.program_application_id
    , fact.request_id
    )
    values
    ( charges.repair_line_id
    , charges.material_charges_g
    , charges.labor_charges_g
    , charges.expense_charges_g
    , charges.material_charges_sg
    , charges.labor_charges_sg
    , charges.expense_charges_sg
    , g_user_id
    , sysdate
    , charges.last_update_date
    , charges.last_updated_by
    , charges.last_update_login
    , charges.program_id
    , charges.program_login_id
    , charges.program_application_id
    , charges.request_id
    );

  l_rowcount := sql%rowcount;
  bis_collection_utilities.log( 'Merged ' || l_rowcount || ' rows into ISC_DR_CHARGES_F' , 1 );

  l_stmnt_id := 50;
  update isc_dr_inc
  set
    last_run_date          = l_ro_last_run_date
  , last_update_date       = sysdate
  , last_updated_by        = g_user_id
  , last_update_login      = g_login_id
  , program_id             = g_program_id
  , program_login_id       = g_program_login_id
  , program_application_id = g_program_application_id
  , request_id             = g_request_id
  where fact_name = 'ISC_DR_CHARGES_F';

  bis_collection_utilities.log( 'Updated into table ISC_DR_INC', 1 );

  l_stmnt_id := 60;
  commit;

  l_stmnt_id := 70;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_charges_last_run_date
                                 , p_period_to => l_to_date
                                 , p_count => l_rowcount
                                 );

  retcode := c_ok;

  bis_collection_utilities.log( 'End Incremental Load' );

exception

  when l_exception then
    rollback;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_period_from => l_charges_last_run_date
                                   , p_period_to => l_to_date
                                   , p_message => l_message
                                   );
    retcode := c_error;
    errbuf := l_message;

  when others then
    rollback;
    l_message := err_mesg( sqlerrm, l_proc_name, l_stmnt_id );
    bis_collection_utilities.put_line( l_message );
    bis_collection_utilities.wrapup( p_status => false
                                   , p_period_from => l_charges_last_run_date
                                   , p_period_to => l_to_date
                                   , p_message => l_message
                                   );
    retcode := c_error;
    errbuf := l_message;

end charges_incr_load;

-- costs_incr_load
-- Parameters:
-- retcode - 0 on successful completion, -1 on error and 1 for warning.
-- errbuf - empty on successful completion, message on error or warning

procedure costs_incr_load
( errbuf  in out nocopy varchar2
, retcode in out nocopy number
)
is

  l_proc_name             constant varchar2(30) := 'costs_incr_load';
  l_stmnt_id              number;

  l_ro_last_run_date      date;
  l_costs_last_run_date   date;
  l_message               varchar2(32000);
  l_exception             exception;
  l_rowcount number;
  l_to_date date;

begin

  bis_collection_utilities.log( 'Begin Incremental Load' );

  l_stmnt_id := 0;
  if not bis_collection_utilities.setup( g_costs_object_name ) then
    l_message := isc_depot_backlog_etl_pkg.err_mesg
                 ( 'Error in BIS_COLLECTION_UTILITIES.Setup'
                 , l_proc_name
                 , l_stmnt_id
                 );
    bis_collection_utilities.put_line( l_message );
    raise l_exception;
  end if;

  l_stmnt_id := 10;
  if check_initial_load_setup
     ( x_message => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Global Start Date: ' || fnd_date.date_to_displaydt(g_global_start_date), 1 );
  bis_collection_utilities.log( 'Primary Global Currency: ' || g_global_curr_code, 1 );
  bis_collection_utilities.log( 'Primary Global Currency Rate Type: ' || g_global_rate_type, 1 );
  bis_collection_utilities.log( 'Secondary Global Currency: ' || g_global_sec_curr_code, 1 );
  bis_collection_utilities.log( 'Secondary Global Currency Rate Type: ' || g_global_sec_rate_type, 1 );

  l_stmnt_id := 20;
  execute immediate 'TRUNCATE TABLE ' || g_isc_schema || '.ISC_DR_COSTS_STG';

  bis_collection_utilities.log( 'Truncated table ISC_DR_COSTS_STG', 1 );

  l_stmnt_id := 30;
  execute immediate 'TRUNCATE TABLE ' || g_isc_schema || '.ISC_DR_COSTS_CONV_TMP';

  bis_collection_utilities.log( 'Truncated table ISC_DR_COSTS_CONV_TMP', 1 );

  l_stmnt_id := 40;
  if isc_depot_backlog_etl_pkg.get_last_run_date
     ( p_fact_name => 'ISC_DR_REPAIR_ORDERS_F'
     , x_run_date  => l_ro_last_run_date
     , x_message   => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  if l_ro_last_run_date is null then
    l_message := 'Please run the Intial Load Request Set for the Depot Repair Management page.';
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Repair Order From Date: ' || fnd_date.date_to_displaydt(l_ro_last_run_date), 1 );

  l_stmnt_id := 50;
  if isc_depot_backlog_etl_pkg.get_last_run_date
     ( p_fact_name => 'ISC_DR_COSTS_F'
     , x_run_date  => l_costs_last_run_date
     , x_message   => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  if l_costs_last_run_date is null then
    l_message := 'Please run the Intial Load Request Set for the Depot Repair Management page.';
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Cost From Date: ' || fnd_date.date_to_displaydt(l_costs_last_run_date), 1 );
  l_to_date := sysdate;

  l_stmnt_id := 60;
  if load_costs_staging
     ( p_run_date => l_costs_last_run_date
     , p_load_type => 'INCR_LOAD'
     , x_message   => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  l_stmnt_id := 70;
  if load_costs_conv_rates
     ( x_message => l_message
     ) <> 0 then
    raise l_exception;
  end if;

  l_stmnt_id := 80;
  merge into
  isc_dr_costs_f fact
  using
    ( select
        stg.repair_line_id repair_line_id
      , nvl(sum( stg.material_cost_b * rates.g_conv_rate ), 0) material_cost_g
      , nvl(sum( stg.labor_cost_b    * rates.g_conv_rate ), 0) labor_cost_g
      , nvl(sum( stg.expense_cost_b  * rates.g_conv_rate ), 0) expense_cost_g
      , nvl(sum( stg.material_cost_b * rates.sg_conv_rate ), 0) material_cost_sg
      , nvl(sum( stg.labor_cost_b    * rates.sg_conv_rate ), 0) labor_cost_sg
      , nvl(sum( stg.expense_cost_b  * rates.sg_conv_rate ), 0) expense_cost_sg
      , sysdate                  last_update_date
      , g_user_id                last_updated_by
      , g_login_id               last_update_login
      , g_program_id             program_id
      , g_program_login_id       program_login_id
      , g_program_application_id program_application_id
      , g_request_id             request_id
      from
        isc_dr_costs_stg           stg
      , isc_dr_costs_conv_tmp      rates
      where
          stg.func_currency_code = rates.func_currency_code
      and stg.date_closed = rates.date_closed
      group by stg.repair_line_id
    ) costs
  on
    ( fact.repair_line_id = costs.repair_line_id )
  when matched then
    update
    set fact.material_cost_g        = costs.material_cost_g
      , fact.labor_cost_g           = costs.labor_cost_g
      , fact.expense_cost_g         = costs.expense_cost_g
      , fact.material_cost_sg       = costs.material_cost_sg
      , fact.labor_cost_sg          = costs.labor_cost_sg
      , fact.expense_cost_sg        = costs.expense_cost_sg
      , fact.last_update_date       = costs.last_update_date
      , fact.last_updated_by        = costs.last_updated_by
      , fact.last_update_login      = costs.last_update_login
      , fact.program_id             = costs.program_id
      , fact.program_login_id       = costs.program_login_id
      , fact.program_application_id = costs.program_application_id
      , fact.request_id             = costs.request_id
  when not matched then
    insert
    ( fact.repair_line_id
    , fact.material_cost_g
    , fact.labor_cost_g
    , fact.expense_cost_g
    , fact.material_cost_sg
    , fact.labor_cost_sg
    , fact.expense_cost_sg
    , fact.created_by
    , fact.creation_date
    , fact.last_update_date
    , fact.last_updated_by
    , fact.last_update_login
    , fact.program_id
    , fact.program_login_id
    , fact.program_application_id
    , fact.request_id
    )
    values
    ( costs.repair_line_id
    , costs.material_cost_g
    , costs.labor_cost_g
    , costs.expense_cost_g
    , costs.material_cost_sg
    , costs.labor_cost_sg
    , costs.expense_cost_sg
    , g_user_id
    , sysdate
    , costs.last_update_date
    , costs.last_updated_by
    , costs.last_update_login
    , costs.program_id
    , costs.program_login_id
    , costs.program_application_id
    , costs.request_id
    );

  l_rowcount := sql%rowcount;
  bis_collection_utilities.log( 'Merged ' || l_rowcount || ' rows into ISC_DR_COSTS_F' , 1 );

  l_stmnt_id := 90;
  update isc_dr_inc
  set last_run_date          = l_ro_last_run_date
    , last_update_date       = sysdate
    , last_updated_by        = g_user_id
    , last_update_login      = g_login_id
    , program_id             = g_program_id
    , program_login_id       = g_program_login_id
    , program_application_id = g_program_application_id
    , request_id             = g_request_id
  where fact_name = 'ISC_DR_COSTS_F';

  bis_collection_utilities.log( 'Updated into table ISC_DR_INC', 1 );

  l_stmnt_id := 100;
  commit;

  l_stmnt_id := 110;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_costs_last_run_date
                                 , p_period_to => l_to_date
                                 , p_count => l_rowcount
                                 );

  retcode := c_ok;

  bis_collection_utilities.log( 'End Incremental Load' );

exception

  when l_exception then
    rollback;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_period_from => l_costs_last_run_date
                                   , p_period_to => l_to_date
                                   , p_message => l_message
                                   );
    retcode := c_error;
    errbuf := l_message;

  when others then
    rollback;
    l_message := err_mesg( sqlerrm, l_proc_name, l_stmnt_id );
    bis_collection_utilities.put_line( l_message );
    bis_collection_utilities.wrapup( p_status => false
                                   , p_period_from => l_costs_last_run_date
                                   , p_period_to => l_to_date
                                   , p_message => l_message
                                   );
    retcode := c_error;
    errbuf := l_message;

end costs_incr_load;

end isc_depot_margin_etl_pkg;

/
