--------------------------------------------------------
--  DDL for Package Body ISC_DEPOT_BACKLOG_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DEPOT_BACKLOG_ETL_PKG" as
/* $Header: iscdepotetlbb.pls 120.2 2006/09/21 01:20:05 kreardon noship $ */

-- Global Varaiables

c_error         constant  number := -1;   -- concurrent manager error code
c_warning       constant  number := 1;    -- concurrent manager warning code
c_ok            constant  number := 0;    -- concurrent manager success code
c_errbuf_size   constant  number := 300;  -- length of formatted error message

g_global_start_date      date;
g_isc_schema             varchar2(30);
g_object_name  constant varchar2(30) := 'ISC_DR_REPAIR_ORDERS_F';

-- Common Procedures (for initial and incremental load)

--  err_mesg
function err_mesg
( p_mesg      in varchar2
, p_proc_name in varchar2 default null
, p_stmt_id   in number default -1
)
return varchar2

is

  l_formatted_message varchar2(300);

begin

  l_formatted_message := substr( p_proc_name || ' #' || to_char(p_stmt_id)
                                             || ': ' || p_mesg
                               , 1
                               , c_errbuf_size
                               );
  return l_formatted_message;

exception

  when others then
     -- the exception happened in the exception reporting function
     -- return with error.
     l_formatted_message := 'Error in error reporting. ' || p_mesg;
     return l_formatted_message;

end err_mesg;

--  Common Procedures Definitions
--  check_initial_load_setup
--  Gets the GSD.

function check_initial_load_setup
( x_global_start_date out nocopy date
, x_isc_schema        out nocopy varchar2
, x_message           out nocopy varchar2
)
return number
is

  l_proc_name     constant varchar2(40) := 'check_initial_load_setup';
  l_stmt_id       number;
  l_setup_good    boolean;
  l_status        varchar2(30);
  l_industry      varchar2(30);
  l_message       varchar2(100);

  l_exception     exception;
  l_error_mesg    constant varchar2(100) := 'Error in Global setup';

begin

  -- Initialization
  l_stmt_id := 0;

  -- Check for the global start date setup.
  -- These parameter must be set up prior to any DBI load.

  x_global_start_date := trunc(bis_common_parameters.get_global_start_date);

  if x_global_start_date is null then
    l_message := 'Global Start Date is NULL';
    raise l_exception;
  end if;

  l_setup_good := fnd_installation.get_app_info
                  ( 'ISC'
                  , l_status
                  , l_industry
                  , x_isc_schema
                  );

  if l_setup_good = false or x_isc_schema is null then
    l_message := 'ISC schema not found';
    raise l_exception;
  end if;

  return c_ok;

exception

  when l_exception then
    x_message := err_mesg( l_error_mesg || ': ' || l_message
                         , l_proc_name
                         , l_stmt_id
                         );
    bis_collection_utilities.put_line( x_message );
    return c_error;

  when others then
    x_message := err_mesg( sqlerrm, l_proc_name, l_stmt_id );
    bis_collection_utilities.put_line( x_message );
    return c_error;

end check_initial_load_setup;

--  check_incr_load_setup
--  Gets the last run date.

function get_last_run_date
( p_fact_name in  varchar2
, x_run_date  out nocopy date
, x_message   out nocopy varchar2
)
return number
is

  l_func_name     constant varchar2(40) := 'get_last_run_date';
  l_stmt_id       number;

begin

  -- Initialization
  l_stmt_id := 0;

  select last_run_date
  into x_run_date
  from isc_dr_inc
  where fact_name = p_fact_name;

  return c_ok;

exception

  when no_data_found then
    x_message :=  err_mesg( p_fact_name ||
                            ': Please run the Intial Load Request Set for ' ||
                            'the Depot Repair Management page.'
                          , l_func_name
                          , l_stmt_id
                          );
    bis_collection_utilities.put_line( x_message );
    return c_error;

  when others then
    x_message := err_mesg( sqlerrm, l_func_name, l_stmt_id );
    bis_collection_utilities.put_line( x_message );
    return c_error;

end get_last_run_date;


function get_master_organization_id
( x_organization_id out nocopy number
, x_message         out nocopy varchar2
)
return number
is

  l_func_name     constant varchar2(40) := 'get_master_organization_id';
  l_profile_name  varchar2(240);
  l_stmt_id       number;
  l_master_org    number;
  l_org           number;

  l_exception exception;
  l_err_msg varchar2(2000);

  cursor master_org_cur is
    select distinct master_organization_id
    from mtl_parameters;

begin

  l_stmt_id := 0;

  for master_org_cur_rec in master_org_cur loop

    l_master_org := master_org_cur_rec.master_organization_id;
    if master_org_cur%rowcount > 1 then
      l_master_org := null;
      exit;
    end if;

  end loop;

  /* Get the site level value for Service: Inventory Validation Organization */
  if l_master_org is null then

    l_stmt_id := 10;
    l_org :=  fnd_profile.value_specific
              ( name              => 'CS_INV_VALIDATION_ORG'
              , user_id           => -1
              , responsibility_id => -1
              , application_id    => -1
              );


    if l_org is null then

      l_stmt_id := 20;
      select user_profile_option_name
      into l_profile_name
      from fnd_profile_options_vl
      where profile_option_name = 'CS_INV_VALIDATION_ORG';

      fnd_message.set_name( 'ISC', 'ISC_DEPOT_MISSING_INV_VAL_ORG' );
      fnd_message.set_token( 'ISC_DEPOT_PROFILE_NAME', l_profile_name );
      l_err_msg := fnd_message.get;
      raise l_exception;

    end if;

    l_stmt_id := 30;
    select master_organization_id
    into l_master_org
    from mtl_parameters
    where organization_id = l_org;

  end if;

  x_organization_id := l_master_org;
  return c_ok;

exception

  when l_exception then
    x_message := l_err_msg;
    bis_collection_utilities.put_line( x_message );
    return c_error;

  when others then
    x_message := err_mesg ( sqlerrm, l_func_name, l_stmt_id );
    bis_collection_utilities.put_line( x_message );
    return c_error;

end get_master_organization_id;

--  initial_load
--  Parameters:
--  retcode - 0 on successful completion, -1 on error and 1 for warning.
--  errbuf - empty on successful completion, message on error or warning

procedure initial_load
( errbuf    in out nocopy  varchar2
, retcode   in out nocopy  number
)
is

  l_stmnt_id      number;
  l_run_date      date;
  l_proc_name     constant varchar2(30) := 'intitial_load';
  l_master_org    number;

  l_user_id                constant number := nvl(fnd_global.user_id,-1);
  l_login_id               constant number := nvl(fnd_global.login_id,-1);
  l_program_id             constant number := nvl(fnd_global.conc_program_id,-1);
  l_program_login_id       constant number := nvl(fnd_global.conc_login_id,-1);
  l_program_application_id constant number := nvl(fnd_global.prog_appl_id,-1);
  l_request_id             constant number := nvl(fnd_global.conc_request_id,-1);

  l_message varchar2(32000);
  l_exception exception;
  l_rowcount number;
  l_to_date date;

begin

  bis_collection_utilities.log( 'Begin Initial Load' );

  l_stmnt_id := 0;
  if not bis_collection_utilities.setup( g_object_name ) then
    l_message := err_mesg( 'Error in BIS_COLLECTION_UTILITIES.Setup'
                         , l_proc_name
                         , l_stmnt_id
                         );
    bis_collection_utilities.put_line( l_message );
    raise l_exception;
  end if;

  l_stmnt_id := 10;
  if check_initial_load_setup
     ( x_global_start_date => g_global_start_date
     , x_isc_schema        => g_isc_schema
     , x_message           => l_message
     ) <> c_ok then
    raise l_exception;
  end if;
  bis_collection_utilities.log( 'Global Start Date: ' || fnd_date.date_to_displaydt(g_global_start_date), 1 );

  l_stmnt_id := 20;
  delete
  from isc_dr_inc
  where fact_name = 'ISC_DR_REPAIR_ORDERS_F';

  bis_collection_utilities.log( 'Deleted from table ISC_DR_INC', 1 );

  l_stmnt_id := 30;
  execute immediate 'TRUNCATE TABLE ' || g_isc_schema || '.ISC_DR_REPAIR_ORDERS_F';

  bis_collection_utilities.log( 'Truncated table ISC_DR_REPAIR_ORDERS_F', 1 );

  l_stmnt_id := 40;
  l_run_date := sysdate - 5/(24*60);
  l_to_date := sysdate;

  l_stmnt_id := 50;
  if get_master_organization_id
     ( x_organization_id => l_master_org
     , x_message         => l_message
     ) <> c_ok then
    raise l_exception;
  end if;
  bis_collection_utilities.log( 'Master organization id: ' || l_master_org, 1 );

  l_stmnt_id := 60;
  insert /*+ append parallel(isc_dr_repair_orders_f) */
  into isc_dr_repair_orders_f
  ( repair_line_id
  , repair_number
  , repair_organization_id
  , master_organization_id
  , inventory_item_id
  , item_org_id
  , repair_type_id
  , incident_id
  , incident_number
  , customer_id
  , ro_creation_date
  , dbi_ro_creation_date
  , repair_mode
  , date_closed
  , dbi_date_closed
  , promise_date
  , dbi_promise_date
  , flow_status_id
  , status
  , serial_number
  , quantity
  , uom_code
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
  select  /*+ use_hash(inc, cr) parallel(inc) parallel(cr)*/
    cr.repair_line_id
  , cr.repair_number
  , nvl(cr.owning_organization_id,-1)
  , l_master_org master_organization_id
  , cr.inventory_item_id
  , cr.inventory_item_id || '-' || l_master_org
  , cr.repair_type_id
  , inc.incident_id
  , inc.incident_number
  , inc.customer_id
  , trunc(cr.creation_date)
  , case
      when cr.creation_date < g_global_start_date then
        g_global_start_date
      else trunc(cr.creation_date)
    end
  , cr.repair_mode
  , cr.date_closed
  , trunc(cr.date_closed)
  , trunc(cr.promise_date)
  , case
      when cr.promise_date < g_global_start_date then
        g_global_start_date - 1
      else trunc(cr.promise_date)
    end
  , cr.flow_status_id
  , cr.status
  , cr.serial_number
  , cr.quantity
  , cr.unit_of_measure
  , l_user_id
  , sysdate
  , sysdate
  , l_user_id
  , l_login_id
  , l_program_id
  , l_program_login_id
  , l_program_application_id
  , l_request_id
  from
    csd_repairs cr
  , cs_incidents_all_b inc
  where
      cr.incident_id = inc.incident_id
  and ( cr.status in ('O','H','D') or
        cr.Date_closed >= g_global_start_date
      );

  l_rowcount := sql%rowcount;
  bis_collection_utilities.log( 'Inserted ' || l_rowcount || ' rows into ISC_DR_REPAIR_ORDERS_F' , 1 );

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
  ( 'ISC_DR_REPAIR_ORDERS_F'
  , l_run_date
  , l_user_id
  , sysdate
  , sysdate
  , l_user_id
  , l_login_id
  , l_program_id
  , l_program_login_id
  , l_program_application_id
  , l_request_id
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

end initial_load;

-- incr_load
-- Parameters:
-- retcode - 0 on successful completion, -1 on error and 1 for warning.
-- errbuf - empty on successful completion, message on error or warning
--

procedure incr_load
( errbuf  in out nocopy varchar2
, retcode in out nocopy number
)
is

  l_stmnt_id      number;
  l_run_date      date;
  l_last_run_date date;
  l_proc_name     constant varchar2(30) := 'incr_load';
  l_master_org    number;

  l_user_id                constant number := nvl(fnd_global.user_id,-1);
  l_login_id               constant number := nvl(fnd_global.login_id,-1);
  l_program_id             constant number := nvl(fnd_global.conc_program_id,-1);
  l_program_login_id       constant number := nvl(fnd_global.conc_login_id,-1);
  l_program_application_id constant number := nvl(fnd_global.prog_appl_id,-1);
  l_request_id             constant number := nvl(fnd_global.conc_request_id,-1);

  l_message varchar2(32000);
  l_exception exception;
  l_rowcount number;
  l_to_date date;

begin

  bis_collection_utilities.log( 'Begin Incremental Load' );

  l_stmnt_id := 0;
  if not bis_collection_utilities.setup( g_object_name ) then
    l_message := err_mesg( 'Error in BIS_COLLECTION_UTILITIES.Setup'
                         , l_proc_name
                         , l_stmnt_id
                         );
    bis_collection_utilities.put_line( l_message );
    raise l_exception;
  end if;

  l_stmnt_id := 10;
  if get_last_run_date
     ( p_fact_name => 'ISC_DR_REPAIR_ORDERS_F'
     , x_run_date  => l_last_run_date
     , x_message   => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  if l_last_run_date is null then
    l_message := 'Please run the Intial Load Request Set for the Depot Repair Management page.';
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'From Date: ' || fnd_date.date_to_displaydt(l_last_run_date), 1 );

  l_stmnt_id := 20;
  l_run_date := sysdate - 5/(24*60);
  l_to_date := sysdate;

  l_stmnt_id := 30;
  if get_master_organization_id
     ( x_organization_id => l_master_org
     , x_message         => l_message
     ) <> c_ok then
    raise l_exception;
  end if;
  bis_collection_utilities.log( 'Master organization id: ' || l_master_org, 1 );

  l_stmnt_id := 40;
  merge into isc_dr_repair_orders_f fact
  using
    ( select
      cr.repair_line_id                  repair_line_id
    , cr.repair_number                   repair_number
    , nvl(cr.owning_organization_id, -1) organization_id
    , cr.inventory_item_id               inventory_item_id
    , cr.repair_type_id                  repair_type_id
    , inc.incident_id                    incident_id
    , inc.incident_number                incident_number
    , inc.customer_id                    customer_id
    , trunc(cr.creation_date)            ro_creation_date
    , case
        when cr.creation_date < g_global_start_date then
          g_global_start_date
        else trunc(cr.creation_date)
      end                                dbi_ro_creation_date
    , cr.repair_mode                     repair_mode
    , cr.date_closed                     date_closed
    , trunc(cr.date_closed)              dbi_date_closed
    , trunc(cr.promise_date)             promise_date
    , case
        when cr.promise_date < g_global_start_date then
          g_global_start_date - 1
        else
          trunc(cr.promise_date)
        end                              dbi_promise_date
    , cr.flow_status_id                  flow_status_id
    , cr.status                          status
    , cr.serial_number                   serial_number
    , cr.quantity                        quantity
    , cr.unit_of_measure                 uom_code
    from
      csd_repairs cr
    , cs_incidents_all_b inc
    where
        cr.incident_id = inc.incident_id
    and cr.last_update_date > l_last_run_date
    ) oltp
  on
    ( fact.repair_line_id = oltp.repair_line_id )
  when matched then
    update set
      fact.repair_number             =  oltp.repair_number
    , fact.repair_organization_id    =  oltp.organization_id
    , fact.master_organization_id    =  l_master_org
    , fact.inventory_item_id         =  oltp.inventory_item_id
    , fact.item_org_id               =  oltp.inventory_item_id || '-' || l_master_org
    , fact.repair_type_id            =  oltp.repair_type_id
    , fact.incident_id               =  oltp.incident_id
    , fact.incident_number           =  oltp.incident_number
    , fact.customer_id               =  oltp.customer_id
    , fact.ro_creation_date          =  oltp.ro_creation_date
    , fact.dbi_ro_creation_date      =  oltp.dbi_ro_creation_date
    , fact.date_closed               =  oltp.date_closed
    , fact.dbi_date_closed           =  oltp.dbi_date_closed
    , fact.repair_mode               =  oltp.repair_mode
    , fact.promise_date              =  oltp.promise_date
    , fact.dbi_promise_date          =  oltp.dbi_promise_date
    , fact.flow_status_id            =  oltp.flow_status_id
    , fact.status                    =  oltp.status
    , fact.serial_number             =  oltp.serial_number
    , fact.quantity                  =  oltp.quantity
    , fact.uom_code                  =  oltp.uom_code
    , fact.last_update_date          =  sysdate
    , fact.last_updated_by           =  l_user_id
    , fact.last_update_login         =  l_login_id
    , fact.program_id                =  l_program_id
    , fact.program_login_id          =  l_program_login_id
    , fact.program_application_id    =  l_program_application_id
    , fact.request_id                =  l_request_id
  when not matched then
    insert
    ( repair_line_id
    , repair_number
    , repair_organization_id
    , master_organization_id
    , inventory_item_id
    , item_org_id
    , repair_type_id
    , incident_id
    , incident_number
    , customer_id
    , ro_creation_date
    , dbi_ro_creation_date
    , repair_mode
    , date_closed
    , dbi_date_closed
    , promise_date
    , dbi_promise_date
    , flow_status_id
    , status
    , serial_number
    , quantity
    , uom_code
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
    ( oltp.repair_line_id
    , oltp.repair_number
    , oltp.organization_id
    , l_master_org
    , oltp.inventory_item_id
    , oltp.inventory_item_id || '-' || l_master_org
    , oltp.repair_type_id
    , oltp.incident_id
    , oltp.incident_number
    , oltp.customer_id
    , oltp.ro_creation_date
    , oltp.dbi_ro_creation_date
    , oltp.repair_mode
    , oltp.date_closed
    , oltp.dbi_date_closed
    , oltp.promise_date
    , oltp.dbi_promise_date
    , oltp.flow_status_id
    , oltp.status
    , oltp.serial_number
    , oltp.quantity
    , oltp.uom_code
    , l_user_id
    , sysdate
    , sysdate
    , l_user_id
    , l_login_id
    , l_program_id
    , l_program_login_id
    , l_program_application_id
    , l_request_id
    );

  l_rowcount := sql%rowcount;
  bis_collection_utilities.log( 'Merged ' || l_rowcount || ' rows into ISC_DR_REPAIR_ORDERS_F' , 1 );

  l_stmnt_id := 50;
  update isc_dr_inc
  set
    last_run_date           =  l_run_date
  , last_update_date        =  sysdate
  , last_updated_by         =  l_user_id
  , last_update_login       =  l_login_id
  , program_id              =  l_program_id
  , program_login_id        =  l_program_login_id
  , program_application_id  =  l_program_application_id
  , request_id              =  l_request_id
  where fact_name = 'ISC_DR_REPAIR_ORDERS_F';

  bis_collection_utilities.log( 'Updated into table ISC_DR_INC', 1 );

  l_stmnt_id := 60;
  commit;

  l_stmnt_id := 70;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_last_run_date
                                 , p_period_to => l_to_date
                                 , p_count => l_rowcount
                                 );

  retcode := c_ok;

  bis_collection_utilities.log( 'End Incremental Load' );

exception

  when l_exception then
    rollback;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_period_from => l_last_run_date
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
                                   , p_period_from => l_last_run_date
                                   , p_period_to => l_to_date
                                   , p_message => l_message
                                   );
    retcode := c_error;
    errbuf := l_message;

end incr_load;

end isc_depot_backlog_etl_pkg;

/
