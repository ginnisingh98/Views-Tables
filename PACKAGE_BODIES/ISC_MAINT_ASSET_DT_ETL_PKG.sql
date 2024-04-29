--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_ASSET_DT_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_ASSET_DT_ETL_PKG" as
/*$Header: iscmaintadtetlb.pls 120.4 2006/07/26 03:47:50 kreardon noship $ */
 g_pkg_name constant varchar2(30) := 'isc_maint_asset_dt_etl_pkg';
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
 g_object_name constant varchar2(30) := 'ISC_MAINT_ASSET_DOWN_F';
 g_max_date constant date := to_date('4712/01/01','yyyy/mm/dd');
 l_max_date constant date := to_date('4712/12/31','yyyy/mm/dd');


procedure local_init -- sets up the user_id,login_id and the global start date.
as
begin
    g_user_id  := fnd_global.user_id;
    g_login_id := fnd_global.login_id;
    g_program_id := fnd_global.conc_program_id;
    g_program_login_id := fnd_global.conc_login_id;
    g_program_application_id := fnd_global.prog_appl_id;
    g_request_id := fnd_global.conc_request_id;
    g_global_start_date := bis_common_parameters.get_global_start_date;
    --g_global_start_date := to_date('0100/01/01','yyyy/mm/dd') ;
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

function get_schema_name  -- returns the schema name of the object
(x_schema_name   out nocopy varchar2
,x_error_message out nocopy varchar2 )
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


function truncate_table -- truncates the fact table.Should be called before initial load only
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

function get_last_refresh_date -- gets the last refresh date of the fact table
 ( x_refresh_date out nocopy date
 , x_error_message out nocopy varchar2 )
return number as
    l_refresh_date date;
begin
    l_refresh_date := fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period(g_object_name));
    if l_refresh_date = g_global_start_date then
    x_error_message := 'Incremental Load can only be run after a completed initial or incremental load';
    x_error_message := x_error_message || ' Refresh Date is '|| l_refresh_date;
    x_error_message := x_error_message || ' global start date is '|| g_global_start_date ;

     return -1;
    end if;
    x_refresh_date := l_refresh_date;
     return 0;
    exception
    when others then
    x_error_message := 'Error in function get_last_refresh_date : ' || sqlerrm ;
    return -1;
end get_last_refresh_date;

 ------------------------------------------- Public procedures---------------------------------------------------------------
procedure initial_load -- Initial load program for Downtime.
(errbuf out nocopy varchar2
,retcode out nocopy number
)
as
    l_proc_name constant varchar2(30) := 'initial_load';
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
    local_init;

    bis_collection_utilities.log( 'Begin Initial Load' );

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
        (l_biv_schema
         ,l_error_message ) <> 0 then
      	logger( l_proc_name, l_stmt_id, l_error_message );
      	raise l_exception;
    end if;

  -- truncate the Fact table

    l_stmt_id := 30;

    if truncate_table
        (l_biv_schema
        ,'ISC_MAINT_ASSET_DOWN_F'
        ,l_error_message ) <> 0 then
        logger( l_proc_name, l_stmt_id, l_error_message );
        raise l_exception;
    end if;


   ---------------------------------------------initial load ----------------------------------

   -- This inserts into the fact table all the asset downtime instances where the
   -- completion date is on or after the global start date.
   -- The start date for the calculation of the downtime hours is calculated on the DBI_start_date.

   ---------------------------------------------the initial load query would come here----------




    l_stmt_id := 40;

  ------starts here------


   Insert  /*+ append parallel(f) */  into
   ISC_MAINT_ASSET_DOWN_F f
   (
    asset_status_id
   ,instance_id
   ,asset_group_id
   ,category_id
   ,asset_criticality_code
   ,organization_id
   ,department_id
   ,work_order_id
   ,operation_seq_number
   ,description
   ,enable_flag
   ,start_date
   ,end_date
   ,dbi_start_date
   ,effective_start_date
   ,effective_end_date
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

   select   /*+ parallel(msn) parallel(fact) */
    fact.asset_status_id                            	 asset_status_id
   ,fact.maintenance_object_id                         	 instance_id
   ,fact.asset_group_id                             	 asset_group_id
   ,nvl(cii.category_id,-1)                              category_id
   ,nvl(cii.asset_criticality_code,'-1')                 asset_criticality_code
   ,fact.organization_id                            	 oraganization_id
   ,nvl(eomd.owning_department_id,-1)                    department_id
   ,fact.wip_entity_id            		         work_order_id
   ,fact.operation_seq_num 	                         operation_seq_number
   ,fact.description			         	 shutdown_description
   ,fact.enable_flag					 enable_flag
   ,fact.start_date				 	 start_date
   ,fact.end_date					 end_date
   ,greatest(fact.start_date,g_global_start_date)
                                                         dbi_start_date
   ,greatest(fact.effective_start_date,g_global_start_date)
                                                         effective_start_date
   ,effective_end_date				 	 effective_end_date
   ,sysdate					 	 creation_date
   ,g_user_id					 	 created_by
   ,sysdate					 	 last_update_date
   ,g_user_id					 	 last_updated_by
   ,g_login_id					 	 last_update_login
   ,g_program_id					 program_id
   ,g_program_login_id					 program_login_id
   ,g_program_application_id				 program_application_id
   ,g_request_id					 request_id
   from
   (
   select
   	 maintenance_object_id
   	,start_date
   	,end_date
   	,asset_status_id
   	,asset_group_id
   	,organization_id
   	,wip_entity_id
   	,operation_seq_num
   	,description
	,enable_flag
   	,last_update_date
   	,case
   		when effective_start_date >= effective_end_date then
   		null
   		else
   		effective_start_date
   	 end
   	 					 	effective_start_date
   	,case
   		when effective_start_date >= effective_end_date then
   		null
   		else
   		effective_end_date
   	 end
   	 					 	effective_end_date
   from
     ( select
    	 maintenance_object_id
    	,start_date
    	,end_date
    	,asset_status_id
    	,asset_group_id
    	,organization_id
    	,wip_entity_id
    	,operation_seq_num
   	,description
	,enable_flag
   	,last_update_date
   	,case
   		when start_date > lag(max_so_far,1,start_date-1)
   		over(partition by maintenance_object_id order by rn) then
             	start_date
           	else
           	lag(max_so_far,1) over(partition by maintenance_object_id order by rn)
         end
         						 effective_start_date
       	,max_so_far 				 	 effective_end_date

       from
         ( select /*+ parallel(EASH) */
   		 maintenance_object_id
   		,start_date
   		,end_date
   		,asset_status_id
   		,asset_group_id
    		,organization_id
    		,wip_entity_id
    		,operation_seq_num
   		,description
		,nvl(enable_flag,'Y')	enable_flag
   		,last_update_date
           	,min(start_date) over(partition by maintenance_object_id order by start_date, end_date)
           					 min_so_far
           	, max(end_date) over(partition by maintenance_object_id order by start_date, end_date)
           					 max_so_far
           	, row_number() over(partition by maintenance_object_id order by start_date, end_date)
           					 rn
           from EAM_ASSET_STATUS_HISTORY EASH where (enable_flag = 'Y'  or enable_flag is NULL ) and
												start_date <> end_date
		and maintenance_object_type = 3
         )
     )

   )fact
   ,csi_item_instances		cii  /* table that contains the instance_id, category and criticality */
   ,EAM_ORG_MAINT_DEFAULTS	eomd /* table containing the owning department */

   where
   	fact.maintenance_object_id = cii.instance_id
   and	fact.maintenance_object_id = eomd.object_id(+) /* an asset need not be owned to any dept */
   and 	fact.organization_id = eomd.organization_id(+)
   and  eomd.object_type(+) = 50
   and	fact.end_date >=g_global_start_date;

  l_rowcount := sql%rowcount;

  commit;

  ----ends here------


  l_stmt_id := 90;

  bis_collection_utilities.log( l_rowcount || ' rows inserted into base summary', 1 );

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
  logger( l_proc_name, l_stmt_id, l_error_message );
  bis_collection_utilities.wrapup(p_status => false
                       		 ,p_message => l_error_message
                                 ,p_period_from => l_collect_from_date
                                 ,p_period_to => l_collect_to_date
                                 );

 errbuf := l_error_message;
 retcode := g_error;

end initial_load; --- here we end the initial load

procedure incremental_load -- the incremental load procedure
(errbuf out nocopy varchar2
,retcode out nocopy number
)
as

    l_proc_name constant varchar2(30) := 'incremental_load';
    l_stmt_id number;
    l_exception exception;
    l_error_message varchar2(4000);
    l_biv_schema varchar2(100);
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

  -- get the biv schema name

   l_stmt_id := 20;

    if get_schema_name
      (l_biv_schema
      ,l_error_message ) <> 0 then
        logger( l_proc_name, l_stmt_id, l_error_message );
        raise l_exception;
    end if;

   -- merge staging table into base fact
   l_stmt_id := 30;

----------------incremental load starts from here---------------

/* removed the alternate query given by the performance team */

merge into isc_maint_asset_down_f nbmaf
using
(
  -- this inline view compares the new data set with the old data set and
  -- only returns rows that have logically changed.
  -- this is done to ensure that the merge inserts new downtime rows and
  -- only existing rows that have actually changed.
  select
    o.rowid old_rowid
  , n.asset_status_id
  , n.instance_id
  , n.asset_group_id
  , n.category_id
  , n.asset_criticality_code
  , n.organization_id
  , n.department_id
  , n.work_order_id
  , n.operation_seq_number
  , n.description
  , n.start_date
  , n.end_date
  , n.dbi_start_date
  , n.effective_start_date
  , n.effective_end_date
  , n.enable_flag
  from
  (
    -- this inline view contains the current state of all enable_flag rows and
    -- any rows that have become disabled since the last collection
    -- by joining isc_maint_asset_down_f data to mtl_serial_numbers data
    -- we also rename the maintenance_object_id to instance_id to remain consistent
    -- with all the other regions
    select
      a.asset_status_id
    , a.maintenance_object_id instance_id
    , a.asset_group_id
    , nvl(cii.category_id,-1) category_id
    , nvl(cii.asset_criticality_code,'-1') asset_criticality_code
    , a.organization_id
    , nvl(eomd.owning_department_id,-1) department_id
    , a.wip_entity_id work_order_id
    , a.operation_seq_num operation_seq_number
    , a.description
    , a.start_date
    , a.end_date
    , a.dbi_start_date
    , a.effective_start_date
    , a.effective_end_date
    , a.enable_flag enable_flag
    from
    (
      -- this inline view contains the current state of all enable_flag rows and
      -- any rows that have become disabled since the last collection
      -- based only on isc_maint_asset_down_f
      select
        asset_status_id
      , maintenance_object_id
      , asset_group_id
      , organization_id
      , wip_entity_id
      , operation_seq_num
      , description
      , start_date
      , end_date
      , dbi_start_date
      , effective_start_date
      , effective_end_date
      , enable_flag
      from
      (
        -- this inline view nulls out effective start and effective end dates
        -- where they are not meaningful, that is the downtime row is fully
        -- overlapped by a prior downtime
        select
          asset_status_id
        , maintenance_object_id
        , asset_group_id
        , organization_id
        , wip_entity_id
        , operation_seq_num
        , description
        , start_date
        , end_date
        , dbi_start_date
        , case
            when effective_start_date >= effective_end_date then
              null
           else
              effective_start_date
          end effective_start_date
        , case
            when effective_start_date >= effective_end_date then
              null
            else
              effective_end_date
          end effective_end_date
        , enable_flag
        from
        (
          -- this inline view calculates the effective start and effective end date.
          -- - for each downtime by comparing the dbi start date of the current row
          --   with the max so far date of the previous row.  if it is less then they
          --   overlap, it it is great then there is a new effective start date.
          -- - or each downtime the end date is the max so far date
          select
            asset_status_id
          , maintenance_object_id
          , asset_group_id
          , organization_id
          , wip_entity_id
          , operation_seq_num
          , description
          , start_date
          , end_date
          , dbi_start_date
          , case
              when enable_flag = 'Y' then
                case
                  when dbi_start_date > lag(max_so_far,1,dbi_start_date-1)
                                        over(partition by maintenance_object_id order by rn) then
                    dbi_start_date
                  else
                    lag(max_so_far,1) over(partition by maintenance_object_id order by rn)
                end
              else
                null
            end effective_start_date
          , case
              when enable_flag = 'Y' then
                max_so_far
              else
                null
            end effective_end_date
          , enable_flag
          from
          (
            -- this inline view identifies all enable_flag rows and all rows that have
            -- been updated since last collection (newly disabled rows)
            -- it only considers rows with an end date >= gsd
            -- it assumes that data can no longer be updated, the existing row will
            -- be disabled and an new row will be inserted.
            --
            -- - it calculates dbi_start_date
            -- - it determines the min start date-to date (min_so_far) for each maintenance_object_id (asset)
            -- - it determines the max end date-to date (max_so_far) for each maintenance_object_id (asset)
            -- - it determines the logical order of the downtime rows for each maintenance_object_id (asset)
            --
            -- disabled rows are ranked last
            --
            select
              asset_status_id
            , maintenance_object_id
            , asset_group_id
            , organization_id
            , wip_entity_id
            , operation_seq_num
            , description
            , start_date
            , end_date
            , greatest(start_date,g_global_start_date) dbi_start_date
            , nvl(enable_flag,'Y') enable_flag
            , min(decode(nvl(enable_flag,'Y'),'Y',greatest(start_date,g_global_start_date),null))
                over(partition by maintenance_object_id
                order by decode(nvl(enable_flag,'Y'),'Y',start_date,null), decode(nvl(enable_flag,'Y'),'Y',end_date,null)) min_so_far
            , max(decode(nvl(enable_flag,'Y'),'Y',end_date,null))
                over(partition by maintenance_object_id
                order by decode(nvl(enable_flag,'Y'),'Y',start_date,null), decode(nvl(enable_flag,'Y'),'Y',end_date,null)) max_so_far
            , row_number()
                over(partition by maintenance_object_id
                order by decode(nvl(enable_flag,'Y'),'Y',start_date,null), decode(nvl(enable_flag,'Y'),'Y',end_date,null)) rn
            from
		---
		(
		  select * from eam_asset_status_history
		where
			(
			( creation_date > l_collect_from_date and nvl(enable_flag,'Y') = 'Y' )
			or
			( (last_update_date > l_collect_from_date  and creation_date < l_collect_from_date ) or nvl(enable_flag,'Y') = 'Y' )
			)and end_date >= g_global_start_date and start_date <> end_date
			and maintenance_object_type = 3

		)
	  )
        )
      )
    ) a
    , csi_item_instances cii	/* extract the instance_id,category and criticality of the asset */
    , eam_org_maint_defaults eomd /* extract the department of the asset */
    where
        a.maintenance_object_id = cii.instance_id
    and a.maintenance_object_id = eomd.object_id(+)	/* department is not mandatory */
    and eomd.object_type(+)= 50  /* bug 4750689 */
    and a.organization_id = eomd.organization_id(+)
  ) n
, isc_maint_asset_down_f o
where
    n.asset_status_id = o.asset_status_id(+)
and ( o.asset_status_id is null or
      n.category_id                           <> o.category_id                          or
      n.asset_criticality_code                <> o.asset_criticality_code               or
      n.organization_id                       <> o.organization_id                      or
      n.department_id                         <> o.department_id                        or
      nvl(n.work_order_id,-1)                 <> nvl(o.work_order_id,-1)                or
      nvl(n.operation_seq_number,-1)          <> nvl(o.operation_seq_number,-1)         or
      nvl(n.description,'%%')                 <> nvl(o.description,'%%')                or
      n.start_date                            <> o.start_date                           or
      n.end_date                              <> o.end_date                             or
      n.dbi_start_date                        <> o.dbi_start_date                       or
      nvl(n.effective_start_date,l_max_date)  <> nvl(o.effective_start_date,l_max_date) or
      nvl(n.effective_end_date,l_max_date)    <> nvl(o.effective_end_date,l_max_date)   or
      nvl(n.enable_flag,'Y')                  <> nvl(o.enable_flag,'Y')
    )
) data
on
  (
    data.old_rowid = nbmaf.rowid
  )
when matched then
  update set
  -- 3 rows from updation of the mtl_serial_numbers table.
    nbmaf.category_id                    = data.category_id
  , nbmaf.asset_criticality_code         = data.asset_criticality_code
  , nbmaf.department_id                  = data.department_id
  -- 5 rows from updation of the eam_asset_status_history  table.
  , nbmaf.work_order_id                  = data.work_order_id
  , nbmaf.operation_seq_number           = data.operation_seq_number
  , nbmaf.description                    = data.description
  , nbmaf.start_date                     = data.start_date
  , nbmaf.end_date                       = data.end_date
  , nbmaf.dbi_start_date                 = data.dbi_start_date
  -- 2 rows for the updation of the asset effective start and end dates due
  -- to addition of the n row which might impact the asset effective
  --- downtime.
  , nbmaf.effective_start_date           = data.effective_start_date
  , nbmaf.effective_end_date             = data.effective_end_date
  , nbmaf.enable_flag                    = data.enable_flag
  --- the standard who cols that are to be updated.
  , nbmaf.last_update_date               = sysdate
  , nbmaf.last_updated_by                = g_user_id
  , nbmaf.last_update_login              = g_login_id
  , nbmaf.program_id                     = g_program_id
  , nbmaf.program_login_id               = g_program_login_id
  , nbmaf.program_application_id         = g_program_application_id
  , nbmaf.request_id                     = g_request_id


when not matched then
  insert
  (
    asset_status_id
  , instance_id
  , asset_group_id
  , category_id
  , asset_criticality_code
  , organization_id
  , department_id
  , work_order_id
  , operation_seq_number
  , description
  , enable_flag
  , start_date
  , end_date
  , dbi_start_date
  , effective_start_date
  , effective_end_date
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
  (
    data.asset_status_id
  , data.instance_id
  , data.asset_group_id
  , data.category_id
  , data.asset_criticality_code
  , data.organization_id
  , data.department_id
  , data.work_order_id
  , data.operation_seq_number
  , data.description
  , data.enable_flag
  , data.start_date
  , data.end_date
  , data.dbi_start_date
  , data.effective_start_date
  , data.effective_end_date
  , sysdate
  , g_user_id
  , sysdate
  , g_user_id
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  );



 l_rowcount := sql%rowcount;
  commit;


    bis_collection_utilities.log( 'From: ' || fnd_date.date_to_displaydt(l_collect_from_date), 1 );
    bis_collection_utilities.log( 'To: ' || fnd_date.date_to_displaydt(l_collect_to_date), 1 );
    bis_collection_utilities.log( l_rowcount || ' rows merged into base summary', 1 );

    l_stmt_id := 40;

    bis_collection_utilities.wrapup( p_status => true
                                  , p_period_from => l_collect_from_date
                                  , p_period_to => l_collect_to_date
                                  , p_count => l_rowcount
                                  );
    bis_collection_utilities.log('Incremental Load complete');

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
                                    ,p_message => l_error_message
                                    ,p_period_from => l_collect_from_date
                                    ,p_period_to => l_collect_to_date
                                    );
    errbuf := l_error_message;
    retcode := g_error;
---------------- incremental load ends -----------------------------------------
end incremental_load;

end isc_maint_asset_dt_etl_pkg;

/
