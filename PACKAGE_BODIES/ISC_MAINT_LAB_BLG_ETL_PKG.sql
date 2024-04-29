--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_LAB_BLG_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_LAB_BLG_ETL_PKG" as
/*$Header: iscmaintlblgetlb.pls 120.3 2006/07/26 03:48:27 kreardon noship $ */
 g_pkg_name constant varchar2(30) := 'isc_maint_lab_blg_etl_pkg';
 g_user_id  number;
 g_login_id number;
 g_program_id number;
 g_program_login_id number;
 g_program_application_id   number;
 g_request_id               number;
 g_success constant varchar2(10) := '0';
 g_error   constant varchar2(10) := '-1';
 g_warning constant varchar2(10) := '1';
 g_bis_setup_exception exception;
 g_global_start_date date;
 g_object_name constant varchar2(30) := 'ISC_MAINT_LAB_BLG_F';
 g_max_date constant date := to_date('4712/01/01','yyyy/mm/dd');
 g_bom_hour_code  varchar2(50);
 g_bom_time_class  varchar2(50);
 g_time_base_to_hours number;
 procedure local_init
 as
 cursor c_time_base is
    select 1 / decode( conversion_rate
                     , 0 , 1 -- prevent "divide by zero" error
                     , conversion_rate )
    from mtl_uom_conversions
    where uom_class = g_bom_time_class
    and uom_code = g_bom_hour_code
    and inventory_item_id = 0;
 begin
   g_user_id  := fnd_global.user_id;
   g_login_id := fnd_global.login_id;
   g_program_id := fnd_global.conc_program_id;
   g_program_login_id := fnd_global.conc_login_id;
   g_program_application_id := fnd_global.prog_appl_id;
   g_request_id := fnd_global.conc_request_id;
   g_global_start_date := bis_common_parameters.get_global_start_date;
   g_bom_hour_code  := fnd_profile.value('BOM:HOUR_UOM_CODE');
   g_bom_time_class := fnd_profile.value('BOM:TIME_UOM_CLASS');

  bis_collection_utilities.log('BOM:HOUR_UOM_CODE -> ' || g_bom_hour_code, 3);
  bis_collection_utilities.log('BOM:TIME_UOM_CLASS -> ' || g_bom_time_class, 3);

   -- the base UOM_CODE for the UOM_CLASS may not be the same as the
   -- UOM_CODE for "hours".  We need to convert everything to "hours"
   -- so we
   open c_time_base;
   fetch c_time_base into g_time_base_to_hours;
   close c_time_base;

  bis_collection_utilities.log('TIME_BASE_TO_HOURS -> ' || g_time_base_to_hours, 3);

 end local_init;

procedure logger
( p_proc_name varchar2
, p_stmt_id number
, p_message varchar2
)
as

begin

  bis_collection_utilities.log
  ( substr( g_pkg_name || '.' || p_proc_name || ' #' || p_stmt_id || p_message
          , 1
          , 1991 -- [2000 - (3*3)]
          )
  , 3
  );

end logger;

function get_schema_name
 ( x_schema_name   out nocopy varchar2
 , x_error_message out nocopy varchar2 )
 return number as
   l_biv_schema   varchar2(30);
   l_status       varchar2(30);
   l_industry     varchar2(30);
 begin
    if(fnd_installation.get_app_info('ISC', l_status, l_industry, l_biv_schema)) then
     x_schema_name := l_biv_schema;
    else
     x_error_message := 'FIND_INSTALLATION.GET_APP_INFO returned false';
     return -1;
   end if;
   return 0;
 exception
   when others then
     x_error_message := 'Error in function get_schema_name : ' || sqlerrm;
     return -1;
 end get_schema_name;


function truncate_table
 ( p_biv_schema    in varchar2
 , p_table_name    in varchar2
 , x_error_message out nocopy varchar2 )
 return number as
 begin
   execute immediate 'truncate table ' || p_biv_schema || '.' || p_table_name;
   return 0;

 exception
   when others then
     x_error_message  := 'Error in function truncate_table : ' || sqlerrm;
     return -1;
 end truncate_table;





 ------------------------------------------- Public procedures---------------------------------------------------------------
   procedure load
   ( errbuf out nocopy varchar2
   , retcode out nocopy number
   )
   as
     l_proc_name constant varchar2(30) := 'load';
     l_stmt_id number;
     l_exception exception;
     l_error_message varchar2(4000);
     l_biv_schema varchar2(100);
     l_timer number;
     l_rowcount number;
     l_temp_rowcount number;
     l_collect_from_date date;
     l_collect_to_date date;
     type t_number_tab is table of number;
     l_organization_tbl t_number_tab;
     l_work_order_tbl t_number_tab;

   begin

bis_collection_utilities.log('Begin Refresh');
     local_init;
     l_stmt_id := 0;
     if not bis_collection_utilities.setup( g_object_name ) then
       l_error_message := 'Error in BIS_COLLECTION_UTILITIES.Setup';
       logger( l_proc_name, l_stmt_id, l_error_message );
       raise g_bis_setup_exception;
   end if;

   l_stmt_id := 10;

   if g_global_start_date is null then
     l_error_message := 'Unable to get DBI global start date.';
     logger( l_proc_name, l_stmt_id, l_error_message );
     raise l_exception;
   end if;

  l_collect_from_date := g_global_start_date;
  l_collect_to_date := sysdate;


   -- get the biv schema name
      l_stmt_id := 20;

      if get_schema_name
         ( l_biv_schema
         , l_error_message ) <> 0 then
      	logger( l_proc_name, l_stmt_id, l_error_message );
      	raise l_exception;
      end if;

  -- truncate the Fact table

   l_stmt_id := 30;

   if truncate_table
      ( l_biv_schema
      , 'ISC_MAINT_LAB_BLG_F'
      , l_error_message ) <> 0 then
     logger( l_proc_name, l_stmt_id, l_error_message );
     raise l_exception;
   end if;
bis_collection_utilities.log('Base Summary table Truncated',1);

   --------------------------------------------- load ----------------------------------

-- This inserts all the instances of the labor backlog into the fact table.
-- The join wiht the ISC_MAINT_WORK_ORDER_F ensures all the work orders bucketed by the
-- Global start date criteria.
   ---------------------------------------------the load query would come here----------




   l_stmt_id := 40;

  ------starts here------
Insert /*+ append parallel (ISC_MAINT_LAB_BLG_F) */
into ISC_MAINT_LAB_BLG_F
(
organization_id
,user_defined_status_id  /* added user_defined work order status */
,work_order_name
,work_order_id
,resource_id
,department_id
,operation_seq_number
,op_start_date
,op_end_date
,hours_required
,hours_charged
,creation_date
,created_by
,last_update_date
,last_updated_by
,last_update_login
,program_id
,program_login_id
,program_application_id
,request_id
)
select  /*+ parallel(BR) parallel(FACT) parallel(WO) parallel(WOR)
            parallel(M1) parallel(M2) use_hash(WOR) use_hash(WO)
            pq_distribute(WO,hash,hash) pq_distribute(WOR,hash,hash) */
 fact.organization_id  			organization_id
,fact.user_defined_Status_id            user_defined_status_id
,fact.work_order_name	   		work_order_name
,fact.work_order_id	   		work_order_id
,WOR.RESOURCE_ID	   		resource_id
,WO.DEPARTMENT_ID	   		department_id
,WO.OPERATION_SEQ_NUM  	    		operation_seq_number
,WO.first_unit_start_date		op_start_date
,WO.first_unit_completion_date		op_end_date
,WOR.usage_rate_or_amount*m1.conversion_rate*g_time_base_to_hours
					hours_required
,WOR.applied_resource_units*m1.conversion_rate*g_time_base_to_hours
					hours_charged
,sysdate                        	creation_date
,g_user_id                      	created_by
,sysdate                        	last_update_date
,g_user_id                      	last_updated_by
,g_login_id                     	last_update_login
,g_program_id				program_id
,g_program_login_id			program_login_id
,g_program_application_id		program_application_id
,g_request_id				request_id


from
 WIP_OPERATIONS				wo
,WIP_OPERATION_RESOURCES		wor
,BOM_RESOURCES				br
,ISC_MAINT_WORK_ORDERS_F    		fact -- get only the work orders that satisfy the G_start_date criteria
,mtl_uom_conversions			m1

where
fact.status_type  in (17,6,3,1) and --to get the work orders in the status draft,released,unreleased and on-hold
fact.organization_id = wo.organization_id and    -- to get the same organizational work orders.
fact.organization_id = wor.organization_id and 	 -- to get the same organizational work orders.
fact.organization_id = br.organization_id and 	 -- to get the same organizational work orders.
-- departmental level join not required as it is not specified in the join.
-- courtesy etrm (wip_operation_resources)
nvl(wo.operation_completed,'N') = 'N' and -- to get the non completed operations
fact.work_order_id = wo.wip_entity_id  	 and 	-- to get the same work orders.
fact.work_order_id = wor.wip_entity_id   and 	-- to get the same work orders.
wo.operation_seq_num = wor.operation_seq_num and   -- to get the resource
wor.resource_id      = br.resource_id and	   -- to get the resource
br.resource_type = 2 and   -- only labor
WOR.usage_rate_or_amount > WOR.applied_resource_units and -- backlog indicator.
m1.inventory_item_id = 0 and
m1.uom_code = br.unit_of_measure and
m1.uom_class = g_bom_time_class;





l_rowcount := sql%rowcount;

commit;

  ----ends here------


l_stmt_id := 90;

bis_collection_utilities.log(l_rowcount||' rows inserted into the Base Summary Table',1);
bis_collection_utilities.log('End Refresh ');

bis_collection_utilities.wrapup( p_status => true
                                  , p_period_from => l_collect_from_date
                                  , p_period_to => l_collect_to_date
                                  , p_count => l_rowcount
                                  );


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

      logger( l_proc_name, l_stmt_id, l_error_message );
      bis_collection_utilities.wrapup( p_status => false
                               	     , p_message => l_error_message
                                     , p_period_from => l_collect_from_date
                                     , p_period_to => l_collect_to_date
                                     );

     errbuf := l_error_message;
     retcode := g_error;

end load; ---  end load

end isc_maint_lab_blg_etl_pkg;


/
