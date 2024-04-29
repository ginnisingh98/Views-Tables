--------------------------------------------------------
--  DDL for Package Body ISC_DEPOT_MTTR_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DEPOT_MTTR_ETL_PKG" as
/* $Header: iscdepotmttretlb.pls 120.1 2006/09/21 01:21:32 kreardon noship $ */

-- Package Variables

g_global_start_date date;
g_isc_schema  varchar2(30);
g_object_name  constant varchar2(30) := 'ISC_DR_MTTR_F';

--  Initial Load
--  Parameters:
--  retcode - 0 on successful completion, -1 on error and 1 for warning.
--  errbuf - empty on successful completion, message on error or warning
--

procedure initial_load
( errbuf    in out nocopy  varchar2
, retcode   in out nocopy  number
)
is

  l_stmt_id            number;
  l_run_date           date;
  l_proc_name          constant varchar2(30) := 'initial_load';
  l_isc_schema         varchar2(30);
  l_err_msg            varchar2(200);

  l_user_id            constant number := nvl(fnd_global.user_id,-1);
  l_login_id           constant number := nvl(fnd_global.login_id,-1);
  l_program_id         constant number := nvl(fnd_global.conc_program_id,-1);
  l_program_login_id   constant number := nvl(fnd_global.conc_login_id,-1);
  l_program_application_id constant number := nvl(fnd_global.prog_appl_id,-1);
  l_request_id         constant number := nvl(fnd_global.conc_request_id,-1);

  l_message varchar2(32000);
  l_exception exception;
  l_temp_rowcount number;
  l_rowcount number;
  l_to_date date;

begin

  bis_collection_utilities.log( 'Begin Initial Load' );

  l_stmt_id := 0;
  if not bis_collection_utilities.setup( g_object_name ) then
    l_message := isc_depot_backlog_etl_pkg.err_mesg
                 ( 'Error in BIS_COLLECTION_UTILITIES.Setup'
                 , l_proc_name
                 , l_stmt_id
                 );
    bis_collection_utilities.put_line( l_message );
    raise l_exception;
  end if;

  l_stmt_id := 10;
  if isc_depot_backlog_etl_pkg.check_initial_load_setup
     ( x_global_start_date => g_global_start_date
     , x_isc_schema        => g_isc_schema
     , x_message           => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Global Start Date: ' || fnd_date.date_to_displaydt(g_global_start_date), 1 );

  l_stmt_id := 20;
  delete
  from isc_dr_inc
  where fact_name = 'ISC_DR_MTTR_F';

  bis_collection_utilities.log( 'Deleted from table ISC_DR_INC', 1 );

  l_stmt_id := 30;
  execute immediate 'TRUNCATE TABLE ' || g_isc_schema || '.ISC_DR_MTTR_F';

  bis_collection_utilities.log( 'Truncated table ISC_DR_MTTR_F', 1 );

  l_stmt_id := 40;
  if isc_depot_backlog_etl_pkg.get_last_run_date
     ( p_fact_name => 'ISC_DR_REPAIR_ORDERS_F'
     , x_run_date  => l_run_date
     , x_message   => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  if l_run_date is null then
    l_message := 'Please launch the Intial Load Request Set for the Depot Repair Management page.';
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Repair Order To Date: ' || fnd_date.date_to_displaydt(l_run_date), 1 );

  l_to_date := sysdate;

  l_stmt_id := 50;
  -- Insertion of Non-refurbishment repair orders for Serialized and
  -- Non-serialized items

  insert /*+ append parallel(isc_dr_mttr_f) */
  into isc_dr_mttr_f
  ( repair_line_id
  , repair_start_date
  , repair_end_date
  , time_to_repair
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
  select  /*+ ordered use_hash(crt, bdr, cpt, ced, pdr, cpt1, ced1, ibs)
              parallel(crt) parallel(cpt) parallel(ced) parallel(pdr)
              parallel(cpt1) parallel(ced1) parallel(ibs) parallel(bdr) */
    bdr.repair_line_id repair_line_id
  , min(pdr.transaction_date) repair_start_date
  , max(ibs.actual_shipment_date) repair_end_date
  , max(ibs.actual_shipment_date) - min(pdr.transaction_date) time_to_repair
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
    csd_repair_types_b crt
  , isc_dr_repair_orders_f bdr
  , csd_product_transactions cpt
  , cs_estimate_details ced
  , poa_dbi_rtx_f pdr
  , csd_product_transactions cpt1
  , cs_estimate_details ced1
  , isc_book_sum2_f ibs
  where
      bdr.repair_line_id = cpt.repair_line_id
  and bdr.repair_type_id = crt.repair_type_id
  and crt.repair_type_ref <> 'RF'
  and cpt.action_type in ('RMA','WALK_IN_RECEIPT')
  and cpt.action_code = 'CUST_PROD'
  and cpt.estimate_detail_id = ced.estimate_detail_id
  and ced.order_line_id = pdr.oe_order_line_id
  and pdr.transaction_type = 'DELIVER'
  and bdr.repair_line_id = cpt1.repair_line_id
  and cpt1.action_type in ('SHIP','WALK_IN_ISSUE')
  and cpt1.action_code = 'CUST_PROD'
  and cpt1.estimate_detail_id = ced1.estimate_detail_id
  and ced1.order_line_id = ibs.line_id
  and ibs.actual_shipment_date is not null
  and bdr.status = 'C'
  and bdr.date_closed is not null
  and bdr.ro_creation_date >= g_global_start_date
  group by
    bdr.repair_line_id;

  l_rowcount := sql%rowcount;
  bis_collection_utilities.log( 'Inserted ' || l_rowcount || ' rows into ISC_DR_MTTR_F' , 1 );

  l_stmt_id := 60;
  commit;

  l_stmt_id := 70;
  -- Insertion of repair orders with Refurbishment(IO) repair type for
  -- Non-serialized items

  insert /*+ append parallel(isc_dr_mttr_f) */
  into isc_dr_mttr_f
  ( repair_line_id
  , repair_start_date
  , repair_end_date
  , time_to_repair
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
  select  /*+ use_hash(crt, bdr) parallel(bdr) */
    bdr.repair_line_id repair_line_id
  , min(pdr.transaction_date) repair_start_date
  , max(ibs.actual_shipment_date) repair_end_date
  , max(ibs.actual_shipment_date) - min(pdr.transaction_date) time_to_repair
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
    isc_dr_repair_orders_f bdr
  , csd_repair_types_b crt
  , csd_product_transactions cpt
  , csd_product_transactions cpt1
  , poa_dbi_rtx_f pdr
  , isc_book_sum2_f ibs
  where
      bdr.repair_line_id = cpt.repair_line_id
  and bdr.serial_number is null
  and bdr.repair_type_id = crt.repair_type_id
  and crt.repair_type_ref = 'RF'
  and cpt.action_type = 'MOVE_IN'
  -- and cpt.action_code = 'DEFECTIVES'
  and cpt.req_line_id = pdr.requisition_line_id
  and pdr.transaction_type = 'DELIVER'
  and bdr.repair_line_id = cpt1.repair_line_id
  and cpt1.action_type = 'MOVE_OUT'
  -- and cpt1.action_code = 'USABLES'
  and cpt1.order_line_id = ibs.line_id
  and ibs.actual_shipment_date is not null
  and bdr.status = 'C'
  and bdr.date_closed is not null
  and bdr.ro_creation_date >= g_global_start_date
  group by
    bdr.repair_line_id;

  l_temp_rowcount := sql%rowcount;
  bis_collection_utilities.log( 'Inserted ' || l_temp_rowcount || ' rows into ISC_DR_MTTR_F' , 1 );
  l_rowcount := l_rowcount + l_temp_rowcount;

  l_stmt_id := 80;
  commit;

  l_stmt_id := 90;
  -- Insertion of repair orders with Refurbishment(IO) repair type for
  -- Serialized items

  insert /*+ append parallel(isc_dr_mttr_f) */
  into isc_dr_mttr_f
  ( repair_line_id
  , repair_start_date
  , repair_end_date
  , time_to_repair
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
  select /* use_hash(crt, bdr) parallel(bdr) */
    bdr.repair_line_id repair_line_id
  , pdr.transaction_date repair_start_date
  , ibs.actual_shipment_date repair_end_date
  , (ibs.actual_shipment_date - pdr.transaction_date) time_to_repair
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
    isc_dr_repair_orders_f bdr
  , csd_repair_types_b crt
  , csd_product_transactions cpt
  , csd_product_transactions cpt1
  , poa_dbi_rtx_f pdr
  , mtl_unit_transactions mut
  , isc_book_sum2_f ibs
  where
      bdr.repair_line_id = cpt.repair_line_id
  and bdr.serial_number is not null
  and bdr.repair_type_id = crt.repair_type_id
  and crt.repair_type_ref = 'RF'
  and cpt.action_type = 'MOVE_IN'
  -- and cpt.action_code = 'DEFECTIVES'
  and cpt.req_line_id = pdr.requisition_line_id
  and pdr.transaction_type = 'DELIVER'
  and pdr.inv_transaction_id = mut.transaction_id
  and cpt.source_serial_number = mut.serial_number
  and bdr.repair_line_id = cpt1.repair_line_id
  and cpt1.action_type = 'MOVE_OUT'
  -- and cpt1.action_code = 'USABLES'
  and cpt1.order_line_id = ibs.line_id
  and ibs.actual_shipment_date is not null
  and cpt1.prod_txn_status = 'SHIPPED'
  and bdr.status = 'C'
  and bdr.date_closed is not null
  and bdr.ro_creation_date >= g_global_start_date;

  l_temp_rowcount := sql%rowcount;
  bis_collection_utilities.log( 'Inserted ' || l_temp_rowcount || ' rows into ISC_DR_MTTR_F' , 1 );
  l_rowcount := l_rowcount + l_temp_rowcount;

  l_stmt_id := 100;
  commit;

  l_stmt_id := 110;
  -- Insertion into the incremental log table

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
  ( 'ISC_DR_MTTR_F'
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

  l_stmt_id := 120;
  commit;

  l_stmt_id := 130;
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
    l_message := isc_depot_backlog_etl_pkg.err_mesg
                 ( sqlerrm
                 , l_proc_name
                 , l_stmt_id
                 );
    bis_collection_utilities.put_line( l_message );
    bis_collection_utilities.wrapup( p_status => false
                                   , p_period_from => g_global_start_date
                                   , p_period_to => l_to_date
                                   , p_message => l_message
                                   );
    retcode := c_error;
    errbuf := l_message;

end initial_load;

-- Incremental Load
-- Parameters:
-- retcode - 0 on successful completion, -1 on error and 1 for warning.
-- errbuf - empty on successful completion, message on error or warning
--

procedure incr_load
( errbuf  in out nocopy varchar2
, retcode in out nocopy number
)
is

  l_stmt_id            number;
  l_run_date           date;
  l_proc_name          constant varchar2(30) := 'incr_load';
  l_last_run_date      date;
  l_err_msg            varchar2(200);

  l_user_id            constant number := nvl(fnd_global.user_id,-1);
  l_login_id           constant number := nvl(fnd_global.login_id,-1);
  l_program_id         constant number := nvl(fnd_global.conc_program_id,-1);
  l_program_login_id   constant number := nvl(fnd_global.conc_login_id,-1);
  l_program_application_id constant number := nvl(fnd_global.prog_appl_id,-1);
  l_request_id         constant number := nvl(fnd_global.conc_request_id,-1);

  l_message varchar2(32000);
  l_exception exception;
  l_temp_rowcount number;
  l_rowcount number;
  l_to_date date;

begin

  bis_collection_utilities.log( 'Begin Incremental Load' );

  l_stmt_id := 0;
  if not bis_collection_utilities.setup( g_object_name ) then
    l_message := isc_depot_backlog_etl_pkg.err_mesg
                 ( 'Error in BIS_COLLECTION_UTILITIES.Setup'
                 , l_proc_name
                 , l_stmt_id
                 );
    bis_collection_utilities.put_line( l_message );
    raise l_exception;
  end if;

  l_stmt_id := 10;
  if isc_depot_backlog_etl_pkg.check_initial_load_setup
     ( x_global_start_date => g_global_start_date
     , x_isc_schema        => g_isc_schema
     , x_message           => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Global Start Date: ' || fnd_date.date_to_displaydt(g_global_start_date), 1 );

  l_stmt_id := 20;
  if isc_depot_backlog_etl_pkg.get_last_run_date
     ( p_fact_name => 'ISC_DR_MTTR_F'
     , x_run_date  => l_run_date
     , x_message   => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  if l_run_date is null then
    l_message := 'Please run the Intial Load Request Set for the Depot Repair Management page.';
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'MTTR From Date: ' || fnd_date.date_to_displaydt(l_run_date), 1 );

  l_stmt_id := 30;
  if isc_depot_backlog_etl_pkg.get_last_run_date
     ( p_fact_name => 'ISC_DR_REPAIR_ORDERS_F'
     , x_run_date  => l_last_run_date
     , x_message   => l_message
     ) <> c_ok then
    raise l_exception;
  end if;

  if l_run_date is null then
    l_message := 'Please run the Intial Load Request Set for the Depot Repair Management page.';
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Repair Order From Date: ' || fnd_date.date_to_displaydt(l_last_run_date), 1 );

  l_to_date := sysdate;

  l_stmt_id := 40;
  -- Insertion / Updation of repair orders with Non-refurbishment repair type
  -- for Serialized and Non-serialized items

  merge into
  isc_dr_mttr_f fact
  using
    ( select
        bdr.repair_line_id repair_line_id
      , min(pdr.transaction_date) repair_start_date
      , max(ibs.actual_shipment_date) repair_end_date
      , max(ibs.actual_shipment_date) - min(pdr.transaction_date) time_to_repair
      from
        isc_dr_repair_orders_f bdr
      , csd_repair_types_b crt
      , csd_product_transactions cpt
      , csd_product_transactions cpt1
      , cs_estimate_details ced
      , cs_estimate_details ced1
      , poa_dbi_rtx_f pdr
      , isc_book_sum2_f ibs
      where
          bdr.repair_line_id = cpt.repair_line_id
      and bdr.repair_type_id = crt.repair_type_id
      and crt.repair_type_ref <> 'RF'
      and cpt.action_type in ('RMA','WALK_IN_RECEIPT')
      and cpt.action_code = 'CUST_PROD'
      and cpt.estimate_detail_id = ced.estimate_detail_id
      and ced.order_line_id = pdr.oe_order_line_id
      and pdr.transaction_type = 'DELIVER'
      and bdr.repair_line_id = cpt1.repair_line_id
      and cpt1.action_type in ('SHIP','WALK_IN_ISSUE')
      and cpt1.action_code = 'CUST_PROD'
      and cpt1.estimate_detail_id = ced1.estimate_detail_id
      and ced1.order_line_id = ibs.line_id
      and ibs.actual_shipment_date is not null
      and bdr.status = 'C'
      and bdr.ro_creation_date >= g_global_start_date
      and bdr.date_closed > l_run_date
      group by
        bdr.repair_line_id
    ) oltp
  on
    ( fact.repair_line_id = oltp.repair_line_id )
  when matched then
    update
    set fact.repair_start_date         =  oltp.repair_start_date
      , fact.repair_end_date           =  oltp.repair_end_date
      , fact.time_to_repair            =  oltp.time_to_repair
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
    , repair_start_date
    , repair_end_date
    , time_to_repair
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
    , oltp.repair_start_date
    , oltp.repair_end_date
    , oltp.time_to_repair
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
  bis_collection_utilities.log( 'Merged ' || l_rowcount || ' rows into ISC_DR_MTTR_F' , 1 );

  l_stmt_id := 50;
  -- Insertion/Updation of repair orders with Refurbishment repair type
  -- for Non-serialized items

  merge into
  isc_dr_mttr_f fact
  using
    ( select
        bdr.repair_line_id repair_line_id
      , min(pdr.transaction_date) repair_start_date
      , max(ibs.actual_shipment_date) repair_end_date
      , max(ibs.actual_shipment_date) - min(pdr.transaction_date) time_to_repair
      from
        isc_dr_repair_orders_f bdr
      , csd_repair_types_b crt
      , csd_product_transactions cpt
      , csd_product_transactions cpt1
      , poa_dbi_rtx_f pdr
      , isc_book_sum2_f ibs
      where
          bdr.repair_line_id = cpt.repair_line_id
      and bdr.serial_number is null
      and bdr.repair_type_id = crt.repair_type_id
      and crt.repair_type_ref = 'RF'
      and cpt.action_type = 'MOVE_IN'
      -- and cpt.action_code = 'DEFECTIVES'
      and cpt.req_line_id = pdr.requisition_line_id
      and pdr.transaction_type = 'DELIVER'
      and bdr.repair_line_id = cpt1.repair_line_id
      and cpt1.action_type = 'MOVE_OUT'
      -- and cpt1.action_code = 'USABLES'
      and cpt1.order_line_id = ibs.line_id
      and ibs.actual_shipment_date is not null
      and bdr.status = 'C'
      and bdr.ro_creation_date >= g_global_start_date
      and bdr.date_closed > l_run_date
      group by
        bdr.repair_line_id
    ) oltp
  on
    ( fact.repair_line_id = oltp.repair_line_id )
  when matched then
    update
    set fact.repair_start_date         =       oltp.repair_start_date
      , fact.repair_end_date           =       oltp.repair_end_date
      , fact.time_to_repair            =       oltp.time_to_repair
      , fact.last_update_date          =       sysdate
      , fact.last_updated_by           =       l_user_id
      , fact.last_update_login         =       l_login_id
      , fact.program_id                =       l_program_id
      , fact.program_login_id          =       l_program_login_id
      , fact.program_application_id    =       l_program_application_id
      , fact.request_id                =       l_request_id
  when not matched then
    insert
    ( repair_line_id
    , repair_start_date
    , repair_end_date
    , time_to_repair
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
    , oltp.repair_start_date
    , oltp.repair_end_date
    , oltp.time_to_repair
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

  l_temp_rowcount := sql%rowcount;
  bis_collection_utilities.log( 'Merged ' || l_temp_rowcount || ' rows into ISC_DR_MTTR_F' , 1 );
  l_rowcount := l_rowcount + l_temp_rowcount;

  l_stmt_id := 60;
  -- Insertion/Updation of repair orders with Refurbishment repair type for
  -- Serialized items

  merge into
  isc_dr_mttr_f fact
  using
    ( select
        bdr.repair_line_id repair_line_id
      , pdr.transaction_date repair_start_date
      , ibs.actual_shipment_date repair_end_date
      , ibs.actual_shipment_date - pdr.transaction_date time_to_repair
      from
        isc_dr_repair_orders_f bdr
      , csd_repair_types_b crt
      , csd_product_transactions cpt
      , csd_product_transactions cpt1
      , poa_dbi_rtx_f pdr
      , mtl_unit_transactions mut
      , isc_book_sum2_f ibs
      where
          bdr.repair_line_id = cpt.repair_line_id
      and bdr.serial_number is not null
      and bdr.repair_type_id = crt.repair_type_id
      and crt.repair_type_ref = 'RF'
      and cpt.action_type = 'MOVE_IN'
      -- and cpt.action_code = 'DEFECTIVES'
      and cpt.req_line_id = pdr.requisition_line_id
      and pdr.transaction_type = 'DELIVER'
      and pdr.inv_transaction_id = mut.transaction_id
      and cpt.source_serial_number = mut.serial_number
      and bdr.repair_line_id = cpt1.repair_line_id
      and cpt1.action_type = 'MOVE_OUT'
      -- and cpt1.action_code = 'USABLES'
      and cpt1.order_line_id = ibs.line_id
      and ibs.actual_shipment_date is not null
      and cpt1.prod_txn_status = 'SHIPPED'
      and bdr.status = 'C'
      and bdr.ro_creation_date >= g_global_start_date
      and bdr.date_closed > l_run_date
    ) oltp
  on
    ( fact.repair_line_id = oltp.repair_line_id )
  when matched then
    update
    set fact.repair_start_date         =  oltp.repair_start_date
      , fact.repair_end_date           =  oltp.repair_end_date
      , fact.time_to_repair            =  oltp.time_to_repair
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
    , repair_start_date
    , repair_end_date
    , time_to_repair
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
    , oltp.repair_start_date
    , oltp.repair_end_date
    , oltp.time_to_repair
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

  l_temp_rowcount := sql%rowcount;
  bis_collection_utilities.log( 'Merged ' || l_temp_rowcount || ' rows into ISC_DR_MTTR_F' , 1 );
  l_rowcount := l_rowcount + l_temp_rowcount;

  l_stmt_id := 70;
  update isc_dr_inc
  set last_run_date             =  l_last_run_date
    , last_update_date          =  sysdate
    , last_updated_by           =  l_user_id
    , last_update_login         =  l_login_id
    , program_id                =  l_program_id
    , program_login_id          =  l_program_login_id
    , program_application_id    =  l_program_application_id
    , request_id                =  l_request_id
    WHERE fact_name = 'ISC_DR_MTTR_F' ;

  bis_collection_utilities.log( 'Updated into table ISC_DR_INC', 1 );

  l_stmt_id := 80;
  commit;

  l_stmt_id := 90;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_run_date
                                 , p_period_to => l_to_date
                                 , p_count => l_rowcount
                                 );

  retcode := c_ok;

  bis_collection_utilities.log( 'End Incremental Load' );

exception

  when l_exception then
    rollback;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_period_from => l_run_date
                                   , p_period_to => l_to_date
                                   , p_message => l_message
                                   );
    retcode := c_error;
    errbuf := l_message;

  when others then
    rollback;
    l_message := isc_depot_backlog_etl_pkg.err_mesg
                 ( sqlerrm
                 , l_proc_name
                 , l_stmt_id
                 );
    bis_collection_utilities.put_line( l_message );
    bis_collection_utilities.wrapup( p_status => false
                                   , p_period_from => l_run_date
                                   , p_period_to => l_to_date
                                   , p_message => l_message
                                   );
    retcode := c_error;
    errbuf := l_message;

end incr_load;

-- Comments on the Initial and Incremental Load

-- During the insertion of repair orders with Refurbishment repair type for
-- serialized items , a check on the product transaction status is necessary
-- because any split made in the order line id, while shipping the serialized
-- items, will be reflected in the csd_product_transaction table only after
-- all the serialized items are shipped, however the status corresponding to
-- the repair order will be updated.

-- Currently, the condition check on the action codes are commented as action
-- types 'MOVE_IN' and 'MOVE_OUT' consists of only one action code
-- 'DEFECTIVES' and 'USABLES' respectively. However in the future, Depot
-- Repair may include more action codes -- for the 'MOVE_IN' and 'MOVE_OUT'
-- action types, this being the case these lines have to be uncommented.

-- For Non-refurbishment repair type, if shipment of items is done by spliting
-- the line id manually in Order Management form then the max of shipment date
-- corresponding to the line id stamped on the cs_estimate_details is alone
-- taken. The shipment date on the split line ids are not taken into
-- consideration. This requires a 'Connect By' to be included in the query
-- which may cause performance issues.

-- For refurbishment repair order with serialized item, a check on the serial
-- number for the item received is required , as when multiple repair orders
-- are created simultaneously for different serial numbers of an item, the
-- requisition line ids for the ROs are the same. Hence to get the accurate
-- repair start date corresponding to each of the repair order, a check is
-- required on the serial number of the item received.

end isc_depot_mttr_etl_pkg;

/
