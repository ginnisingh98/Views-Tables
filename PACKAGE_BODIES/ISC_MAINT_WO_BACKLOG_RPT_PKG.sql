--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_WO_BACKLOG_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_WO_BACKLOG_RPT_PKG" 
/*$Header: iscmaintwoblrptb.pls 120.2 2005/11/22 01:30:51 nbhamidi noship $ */
as


	function get_fact_mv_name
	( p_report_type   in varchar2
	, p_param         in bis_pmv_page_parameter_tbl
	, p_dim_bmap      in number
	, p_custom_output in out nocopy bis_query_attributes_tbl
	)
	return varchar2
	is

	  l_org_id varchar2(200);
	  l_view_by varchar2(200);

	begin

	  l_org_id := isc_maint_rpt_util_pkg.get_parameter_id
	              ( p_param
	              , isc_maint_rpt_util_pkg.G_ORGANIZATION
	              );

	  if p_report_type = 'WORK_ORDER_BACKLOG' then

	  	l_view_by := isc_maint_rpt_util_pkg.get_parameter_value
	                 ( p_param
	                 , 'VIEW_BY'
	                 );

	   isc_maint_rpt_util_pkg.bind_group_id( p_dim_bmap
	             , p_custom_output
	        /*     , isc_maint_rpt_util_pkg.G_DEPARTMENT  Removed rollup from MV */
  	             , isc_maint_rpt_util_pkg.G_ACTIVITY
	             , isc_maint_rpt_util_pkg.G_ASSET_GROUP
	             , isc_maint_rpt_util_pkg.G_ASSET_NUMBER
	        /*     , isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE  Removed rollup from MV */
	             );

	   return ' (select
	      time_id
	    , period_type_id
	    , grp_id
	    , ' ||
	      case l_view_by
	        when isc_maint_rpt_util_pkg.G_DEPARTMENT then 'decode(department_id,-1,-1,organization_id) organization_id '
	        when isc_maint_rpt_util_pkg.G_ASSET_GROUP then 'decode(asset_group_id,-1,-1,organization_id) organization_id '
	        when isc_maint_rpt_util_pkg.G_ASSET_NUMBER then 'decode(instance_id,-1,-1,organization_id) organization_id ' /* replaced asset_number with instance_id */
	        when isc_maint_rpt_util_pkg.G_ACTIVITY then 'decode(activity_id,-1,-1,organization_id) organization_id '
	        else 'organization_id'
	      end ||'
		, organization_id organization_id_c
	    , ' ||
		  case l_view_by
	        when isc_maint_rpt_util_pkg.G_ASSET_NUMBER then 'decode(instance_id,-1,-1,asset_group_id) asset_group_id ' /* replaced asset_number with instance_id */
	        else 'asset_group_id'
	      end ||'
	    , instance_id /* replaced asset_number with instance_id */
	    , activity_id
	    , work_order_type
	    , to_char(department_id) department_id
	    , asset_group_id asset_group_id_c /* removed concatenation to org. to make asset group independent of org. */
	    , decode(instance_id,-1,-1,instance_id) instance_id_c /* replaced asset_number with instance_id */
	    , decode(activity_id,-1,''-1'',activity_id||''-''||organization_id) activity_id_c
	    , decode(department_id,-1,''-1'',department_id||''-1'') department_id_c
	    , Num_created
	    , Num_completion
            , Num_past_due_cmpl
	    , Num_past_due
	    from isc_maint_004_mv fact' || '
	    where fact.grp_id = &ISC_GRP_ID ' ||
	    case
	      when l_org_id is null then
	        '
	    and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'fact', l_org_id )
	    end || '
	      )';

	  elsif p_report_type = 'WORK_ORDER_PAST_DUE_AGING' then

	  isc_maint_rpt_util_pkg.bind_group_id( p_dim_bmap
	                 , p_custom_output
	                 , isc_maint_rpt_util_pkg.G_DEPARTMENT
	                 , isc_maint_rpt_util_pkg.G_ASSET_GROUP
	                 , isc_maint_rpt_util_pkg.G_ASSET_NUMBER
 	                 , isc_maint_rpt_util_pkg.G_ACTIVITY
	                 , isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE
			 , isc_maint_rpt_util_pkg.G_WORK_ORDER_STATUS
	                 );

	    return ' (select
		organization_id
	   ,organization_id organization_id_c
	   , bucket_num
	   , asset_group_id
	   , instance_id /* replace asset_number with instance_id */
	   , activity_id
	   , work_order_type
	   , user_defined_status_id
	   , to_char(department_id) department_id
	   , asset_group_id asset_group_id_c /* removed concatenation to org. to make asset group independent of org. */
	   , decode(instance_id,-1,-1,instance_id) instance_id_c /* replaced asset_number with instance_id */
	   , decode(activity_id,-1,''-1'',activity_id||''-''||organization_id) activity_id_c
	   , decode(department_id,-1,''-1'',department_id||''-1'') department_id_c
	   , num_pastdue c_num_pastdue
	    from isc_maint_007_mv fact' || '
	    where fact.grp_id = &ISC_GRP_ID ' ||
	    case
	      when l_org_id is null then
	        '
	    and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'fact', l_org_id )
	    end || '
	  )';

	  elsif p_report_type = 'WORK_ORDER_BACKLOG_DTL' then
	  return '(select
	           activity_id
   	         , organization_id
	         , organization_id organization_id_c
	         , asset_group_id
	         , instance_id /* replaced asset_number with instance_id */
		 , f.user_defined_status_id /*bug 4752995 */
		 , work_order_name
	         , to_char(department_id) department_id
	         , asset_group_id asset_group_id_c /* removed concatenation to org. to make asset group independent of org. */
	         , decode(instance_id,-1,-1,instance_id) instance_id_c /* replaced asset_number with instance_id */
	         , decode(activity_id,-1,''-1'',activity_id||''-''||organization_id) activity_id_c
		 , decode(department_id,-1,''-1'',department_id||''-1'') department_id_c
	         , work_order_id
	         , status.id status_type
		 , status.value status_name
	         , work_order_type
	         , SCHEDULED_COMPLETION_DATE
	         , SCHEDULED_START_DATE
	        from isc_maint_work_orders_f f,
		     biv_maint_wo_status_lvl_v status
	        where
				f.user_defined_status_id = status.id
			and status_type not in (12, 14, 15, 4, 5, 7) /* Not in: Closed, Pending Close, Failed Close, Complete, Complete - No Charges, Cancelled */
	       '     ||
	          case
	            when l_org_id is null then
	              '
	          and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'f', l_org_id )
	         end || '
	      ) ';

	  elsif p_report_type = 'WORK_ORDER_PAST_DUE_DTL' then
	  return '(select
	           f.activity_id
   	         , f.organization_id
	         , f.organization_id organization_id_c
	         , f.asset_group_id
	         , f.instance_id /* replaced asset_number with instance_id */
		 , f.user_defined_status_id /* bug 4752995 */
		 , f.work_order_name
	         , to_char(f.department_id) department_id
	         , f.asset_group_id asset_group_id_c /* removed concatenation to org. to make asset group independent of org. */
	         , decode(f.instance_id,-1,-1,f.instance_id) instance_id_c /* replaced asset_number with instance_id */
	         , decode(f.activity_id,-1,''-1'',f.activity_id||''-''||f.organization_id) activity_id_c
		 , decode(f.department_id,-1,''-1'',f.department_id||''-1'') department_id_c
	         , f.work_order_id
	         , status.id    status_type
	         , status.value status_name
	         , f.work_order_type
	         , f.SCHEDULED_COMPLETION_DATE
	         , f.SCHEDULED_START_DATE
			 , to_number(trunc(coll.last_update_date) - f.SCHEDULED_COMPLETION_DATE) Past_due_days
	         , trunc(coll.last_update_date) last_collection_date,
	         case
	            when (trunc(coll.last_update_date)- f.scheduled_completion_date) < b.range1_high then 1
	            when (trunc(coll.last_update_date)- f.scheduled_completion_date) >= b.range1_high and ((trunc(coll.last_update_date)- f.scheduled_completion_date) < b.range2_high or b.range2_high is null) then 2
	            when (trunc(coll.last_update_date)- f.scheduled_completion_date) >= b.range2_high and ((trunc(coll.last_update_date)- f.scheduled_completion_date) < b.range3_high or b.range3_high is null) then 3
	            when (trunc(coll.last_update_date)- f.scheduled_completion_date) >= b.range3_high and ((trunc(coll.last_update_date)- f.scheduled_completion_date) < b.range4_high or b.range4_high is null) then 4
	            when (trunc(coll.last_update_date)- f.scheduled_completion_date) >= b.range4_high and ((trunc(coll.last_update_date)- f.scheduled_completion_date) < b.range5_high or b.range5_high is null) then 5
	            when (trunc(coll.last_update_date)- f.scheduled_completion_date) >= b.range5_high and ((trunc(coll.last_update_date)- f.scheduled_completion_date) < b.range6_high or b.range6_high is null) then 6
	            when (trunc(coll.last_update_date)- f.scheduled_completion_date) >= b.range6_high and ((trunc(coll.last_update_date)- f.scheduled_completion_date) < b.range7_high or b.range7_high is null) then 7
	            when (trunc(coll.last_update_date)- f.scheduled_completion_date) >= b.range7_high and ((trunc(coll.last_update_date)- f.scheduled_completion_date) < b.range8_high or b.range8_high is null) then 8
	            when (trunc(coll.last_update_date)- f.scheduled_completion_date) >= b.range8_high and ((trunc(coll.last_update_date)- f.scheduled_completion_date) < b.range9_high or b.range9_high is null) then 9
	            when (trunc(coll.last_update_date)- f.scheduled_completion_date) >= b.range9_high and ((trunc(coll.last_update_date)- f.scheduled_completion_date) < b.range10_high or b.range10_high is null) then 10
	            else 0
	         end bucket_num
	        from isc_maint_work_orders_f f,
	          isc_maint_work_orders_f coll,
			  bis_bucket_customizations b,
			  bis_bucket bb,
			  biv_maint_wo_status_lvl_v status
	        where
			  f.user_defined_status_id = status.id
		  and f.status_type not in (12, 14, 15, 4, 5, 7) /* Not in: Closed, Pending Close, Failed Close, Complete, Complete - No Charges, Cancelled */
	      and coll.Organization_id = -99 and coll.Work_Order_id = -99 and coll.Entity_Type = -1
	      and bb.short_name = ''BIV_MAINT_PAST_DUE_AGING''
		  and bb.bucket_id = b.bucket_id
          and f.COMPLETION_DATE is null
	      and f.SCHEDULED_COMPLETION_DATE < trunc(coll.last_update_date) '     ||
	          case
	            when l_org_id is null then
	              '
	          and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'f', l_org_id )
	         end || '
	      ) ';


 	  end if;

	end get_fact_mv_name;



	procedure get_tbl_sql
	( p_param           in bis_pmv_page_parameter_tbl
	, x_custom_sql      out nocopy varchar2
	, x_custom_output   out nocopy bis_query_attributes_tbl
	)
	is

	  l_dimension_tbl    isc_maint_rpt_util_pkg.t_dimension_tbl;
	  l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
	  l_dim_bmap         number;

	  l_comparison_type  varchar2(200);
	  l_xtd              varchar2(200);
	  l_where_clause     varchar2(10000);
	  l_mv               varchar2(10000);
	  l_stmt             varchar2(32767);

	  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
	  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

	  l_custom_output    bis_query_attributes_tbl;

	  l_cost_element     varchar2(200);
	  l_curr_suffix      varchar2(2);

	  l_drill_across1	 varchar2(150);
	  l_drill_across2	 varchar2(150);

	  l_viewby_select 	 varchar2(200);

	  l_last_collection_date date;
	  l_as_of_date			 date;
	  l_asset_grp_column	varchar2(200);
	begin

	  -- clear out the tables.
	  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
	  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

	  	  isc_maint_rpt_util_pkg.register_dimension_levels
	  ( l_dimension_tbl
	  , l_dim_filter_map
	  , isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
	  , isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
	  , isc_maint_rpt_util_pkg.G_ACTIVITY, 'Y'
	  , isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE, 'Y'
	  );

	  isc_maint_rpt_util_pkg.process_parameters
	  ( p_param            => p_param
	  , p_dimension_tbl    => l_dimension_tbl
	  , p_dim_filter_map   => l_dim_filter_map
	  , p_trend            => 'N'
	  , p_custom_output    => l_custom_output
	  , x_cur_suffix       => l_curr_suffix
	  , x_where_clause     => l_where_clause
	  , x_viewby_select    => l_viewby_select
	  , x_join_tbl         => l_join_tbl
	  , x_dim_bmap         => l_dim_bmap
	  , x_comparison_type  => l_comparison_type
	  , x_xtd              => l_xtd
	  );

	  l_mv := get_fact_mv_name
	          ( 'WORK_ORDER_BACKLOG'
	          , p_param
	          , l_dim_bmap
	          , l_custom_output
	          );

    -- The measure columns that need to be aggregated are
    -- Num_created, Num_Completion, Num_Past_Due, Num_Past_Due_Cmpl

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'Num_created',
                                 'Num_created'
                                 );

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'Num_Completion',
                                 'Num_Completion'
				 );

    poa_dbi_util_pkg.add_column (l_col_tbl,
				'Num_Past_Due_Cmpl',
				'Num_Past_Due_Cmpl'
				 );

    poa_dbi_util_pkg.add_column (l_col_tbl,
				 'Num_Past_Due',
				 'Num_Past_Due'
				 );



	l_as_of_date:= to_date(isc_maint_rpt_util_pkg.get_parameter_value(p_param, 'AS_OF_DATE'),'DD/MM/YYYY');
	select nvl(max(trunc(last_update_date)),trunc(l_as_of_date)-1) into l_last_collection_date from isc_maint_work_orders_f coll
	where coll.Organization_id = -99 and coll.Work_Order_id = -99 and coll.Entity_Type = -1;

	case
	when l_as_of_date >= l_last_collection_date then
		 l_drill_across1:=' ''pFunctionName=ISC_MAINT_WO_BLOG_DTL_RPT_REP'' ||
	  ''&VIEW_BY_NAME=VIEW_BY_ID'' ||
	  ''&pParamIds=Y'' ';
          if l_as_of_date = l_last_collection_date then
		 l_drill_across2:=' ''pFunctionName=ISC_MAINT_PAST_DUE_DTL_RPT_REP'' ||
	  ''&VIEW_BY_NAME=VIEW_BY_ID'' ||
	  ''&pParamIds=Y'' ';
          else
                 l_drill_across2:='null';
          end if;
	else
		 l_drill_across1:='null';
		 l_drill_across2:='null';
	end case;

/* if view by is asset number then add the asset_group column */
       if(isc_maint_rpt_util_pkg.get_parameter_id(p_param,'VIEW_BY')) =
        isc_maint_rpt_util_pkg.G_ASSET_NUMBER then
        l_asset_grp_column := isc_maint_rpt_util_pkg.add_asset_group_column(isc_maint_rpt_util_pkg.G_ASSET_NUMBER,l_dimension_tbl);
        else
        l_asset_grp_column :='NULL';
        end if ;


/* to enable windowing we are using an addition inline view */
	  l_stmt := 'select
	  ' || l_viewby_select || '
	, ' || l_drill_across1 || '  BIV_ATTRIBUTE1
	, ' || l_drill_across2 || '  BIV_ATTRIBUTE2
	, BIV_MEASURE1
	, BIV_MEASURE2
	, BIV_MEASURE3
	, BIV_MEASURE4
	, BIV_MEASURE5
	, BIV_MEASURE6
	, BIV_MEASURE7
	, BIV_MEASURE8
	, BIV_MEASURE9
	, BIV_MEASURE21
	, BIV_MEASURE13
	, BIV_MEASURE14
	, BIV_MEASURE15
	, BIV_MEASURE16
	, BIV_MEASURE22
	, BIV_MEASURE17
	, BIV_MEASURE18 , '
	 || l_asset_grp_column ||' BIV_MEASURE30
	from ( /* calculate the rank on the sorting column in the inline view */
		select row_number() over(&ORDER_BY_CLAUSE, '|| isc_maint_rpt_util_pkg.get_inner_select_col(l_join_tbl) || ')-1 rnk
		 		, iset.*
		from ( select * from (
			select ' || isc_maint_rpt_util_pkg.get_inner_select_col(l_join_tbl) || '
			, nvl(p_num_created - nvl(p_num_completion,0),0)  BIV_MEASURE1
			, nvl(c_num_created - nvl(c_num_completion,0),0)  BIV_MEASURE2' || '
			, ' ||
			isc_maint_rpt_util_pkg.change_column
			  ( 'c_num_created - nvl(c_num_completion,0)'
			  , '(p_num_created - nvl(p_num_completion,0))'
			  , 'BIV_MEASURE3' ) || ' /* Change Backlog */
			, decode(sign(p_num_past_due - nvl(p_num_past_due_cmpl,0)), -1, 0, nvl(p_num_past_due - nvl(p_num_past_due_cmpl,0),0))  BIV_MEASURE4
			, decode(sign(c_num_past_due - nvl(c_num_past_due_cmpl,0)), -1, 0, nvl(c_num_past_due - nvl(c_num_past_due_cmpl,0),0))  BIV_MEASURE5' || '
			, ' ||
			isc_maint_rpt_util_pkg.change_column
			  ( 'decode(sign(c_num_past_due - nvl(c_num_past_due_cmpl,0)), -1, 0, nvl(c_num_past_due - nvl(c_num_past_due_cmpl,0),0))'
			  , 'decode(sign(p_num_past_due - nvl(p_num_past_due_cmpl,0)), -1, 0, nvl(p_num_past_due - nvl(p_num_past_due_cmpl,0),0))'
			  , 'BIV_MEASURE6' ) || ' /* Change Past Due */
			, ' ||
			isc_maint_rpt_util_pkg.rate_column
			  ( 'decode(sign(p_num_past_due - nvl(p_num_past_due_cmpl,0)), -1, 0, nvl(p_num_past_due - nvl(p_num_past_due_cmpl,0),0))'
			  , 'p_num_created - nvl(p_num_completion,0)'
			  , 'BIV_MEASURE7'
			  , 'Y' ) || '
			/* Prior Past Due percent */, ' ||
			isc_maint_rpt_util_pkg.rate_column
			  ( 'decode(sign(c_num_past_due - nvl(c_num_past_due_cmpl,0)), -1, 0, nvl(c_num_past_due - nvl(c_num_past_due_cmpl,0),0))'
			  , '(c_num_created - nvl(c_num_completion,0))'
			  , 'BIV_MEASURE8'
			  , 'Y' ) || '
			/* Past Due percent */, ' ||
			isc_maint_rpt_util_pkg.change_column
			  ( isc_maint_rpt_util_pkg.rate_column
			      ( 'decode(sign(c_num_past_due - nvl(c_num_past_due_cmpl,0)), -1, 0, nvl(c_num_past_due - nvl(c_num_past_due_cmpl,0),0))'
			      , '(c_num_created - nvl(c_num_completion,0))'
			      , ''
			      , 'Y' )
			  , isc_maint_rpt_util_pkg.rate_column
			      ( 'decode(sign(p_num_past_due - nvl(p_num_past_due_cmpl,0)), -1, 0, nvl(p_num_past_due - nvl(p_num_past_due_cmpl,0),0))'
			      , '(p_num_created - nvl(p_num_completion,0))'
			      , ''
			      , 'Y' )
			  , 'BIV_MEASURE9'
			  , 'N' ) || ' /* Past Due Percent Change */
			, nvl(p_num_created_total - nvl(p_num_completion_total,0),0)  BIV_MEASURE21
			, nvl(c_num_created_total - nvl(c_num_completion_total,0),0)  BIV_MEASURE13' || '
			, ' ||
			isc_maint_rpt_util_pkg.change_column
			  ( 'c_num_created_total - nvl(c_num_completion_total,0)'
			  , '(p_num_created_total - nvl(p_num_completion_total,0))'
			  , 'BIV_MEASURE14' ) || ' /* Grand Total - Backlog Change */
			, nvl(decode(sign(c_num_past_due_total - nvl(c_num_past_due_cmpl_total,0)), -1, 0, nvl(c_num_past_due_total - nvl(c_num_past_due_cmpl_total,0),0)),0)  BIV_MEASURE15' || '
			, ' ||
			isc_maint_rpt_util_pkg.change_column
			  ( 'decode(sign(c_num_past_due_total - nvl(c_num_past_due_cmpl_total,0)), -1, 0, nvl(c_num_past_due_total - nvl(c_num_past_due_cmpl_total,0),0)) '
			  , 'decode(sign(p_num_past_due_total - nvl(p_num_past_due_cmpl_total,0)), -1, 0, nvl(p_num_past_due_total - nvl(p_num_past_due_cmpl_total,0),0)) '
			  , 'BIV_MEASURE16' ) || ' /* Grand Total - Past Due Change */
			, ' ||
			isc_maint_rpt_util_pkg.rate_column
			  ( 'decode(sign(p_num_past_due_total - nvl(p_num_past_due_cmpl_total,0)), -1, 0, nvl(p_num_past_due_total - nvl(p_num_past_due_cmpl_total,0),0))'
			  , '(p_num_created_total - nvl(p_num_completion_total,0))'
			  , 'BIV_MEASURE22'
			  , 'Y' ) || 	'/* Grand Total - Prior Past Due percent */, ' ||
			isc_maint_rpt_util_pkg.rate_column
			  ( 'decode(sign(c_num_past_due_total - nvl(c_num_past_due_cmpl_total,0)), -1, 0, nvl(c_num_past_due_total - nvl(c_num_past_due_cmpl_total,0),0))'
			  , '(c_num_created_total - nvl(c_num_completion_total,0))'
			  , 'BIV_MEASURE17'
			  , 'Y' ) || '
			/* Grand Total - Past Due percent */, ' ||
			isc_maint_rpt_util_pkg.change_column
			  ( isc_maint_rpt_util_pkg.rate_column
			      ( 'decode(sign(c_num_past_due_total - nvl(c_num_past_due_cmpl_total,0)), -1, 0, nvl(c_num_past_due_total - nvl(c_num_past_due_cmpl_total,0),0))'
			      , '(c_num_created_total - nvl(c_num_completion_total,0))'
			      , ''
			      , 'Y' )
			  , isc_maint_rpt_util_pkg.rate_column
			      ( 'decode(sign(p_num_past_due_total - nvl(p_num_past_due_cmpl_total,0)), -1, 0, nvl(p_num_past_due_total - nvl(p_num_past_due_cmpl_total,0),0))'
			      , '(p_num_created_total - nvl(p_num_completion_total,0))'
			      , ''
			      , 'Y' )
			  , 'BIV_MEASURE18'
			  , 'N' ) || ' /* Grand Total - Past Due Percent Change */
	 from ' || poa_dbi_template_pkg.status_sql
	        ( p_fact_name            => l_mv
	        , p_where_clause         => l_where_clause
	        , p_join_tables          => l_join_tbl
	        , p_use_windowing        => 'Y'
	        , p_col_name             => l_col_tbl
	        , p_use_grpid            => 'N'
	        , p_paren_count          => 3
	        , p_filter_where         => '(BIV_MEASURE1 <> 0 or BIV_MEASURE2 <> 0 or BIV_MEASURE4 <> 0 or BIV_MEASURE5 <> 0
			  						 or BIV_MEASURE7 <> 0 or BIV_MEASURE8 <> 0) ) iset '
	        , p_generate_viewby      => 'Y'
	        );

	  l_stmt := replace(l_stmt,'&BIS_NESTED_PATTERN', '1143');

	  /* the next line can be used to dump the contents of the PMV parameters as comments into stmt */
	  -- l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);

	  x_custom_output := l_custom_output;

	  x_custom_sql      := l_stmt;

	end get_tbl_sql;



	procedure get_trd_sql
	( p_param           in bis_pmv_page_parameter_tbl
	, x_custom_sql      out nocopy varchar2
	, x_custom_output   out nocopy bis_query_attributes_tbl
	)
	is

	  l_dimension_tbl    isc_maint_rpt_util_pkg.t_dimension_tbl;
	  l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
	  l_dim_bmap         number;
	  l_comparison_type  varchar2(200);
	  l_xtd              varchar2(200);
	  l_where_clause     varchar2(10000);
	  l_mv               varchar2(10000);
	  l_stmt             varchar2(32767);

	  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
	  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

	  l_custom_output    bis_query_attributes_tbl;

	  l_cost_element     varchar2(200);
	  l_curr_suffix      varchar2(2);

	  l_viewby_select varchar2(200);

	begin

		 -- clear out the tables.
		 l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
		 l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

		 isc_maint_rpt_util_pkg.register_dimension_levels
		 ( l_dimension_tbl
		 , l_dim_filter_map
		 , isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
		 , isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
		 , isc_maint_rpt_util_pkg.G_ACTIVITY, 'Y'
		 , isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE, 'Y'
		 );

		 isc_maint_rpt_util_pkg.process_parameters
		 ( p_param            => p_param
		 , p_dimension_tbl    => l_dimension_tbl
		 , p_dim_filter_map   => l_dim_filter_map
		 , p_trend            => 'Y'
		 , p_custom_output    => l_custom_output
		 , x_cur_suffix       => l_curr_suffix
		 , x_where_clause     => l_where_clause
		 , x_viewby_select    => l_viewby_select
		 , x_join_tbl         => l_join_tbl
		 , x_dim_bmap         => l_dim_bmap
		 , x_comparison_type  => l_comparison_type
		 , x_xtd              => l_xtd
		 );

		 l_mv := get_fact_mv_name
		        ( 'WORK_ORDER_BACKLOG'
		        , p_param
		        , l_dim_bmap
		        , l_custom_output
		        );

		-- The measure columns that need to be aggregated are
		-- Num_created, Num_Completion, Num_past_due, Num_Past_Due_Cmpl
		-- No Grand totals required.

		poa_dbi_util_pkg.add_column (l_col_tbl,
		                             'Num_created',
		                             'Num_created',
					     'N'
		                             );

		poa_dbi_util_pkg.add_column (l_col_tbl,
		                             'Num_Completion',
		                             'Num_Completion',
					     'N'
					     );

	        poa_dbi_util_pkg.add_column (l_col_tbl,
					     'Num_Past_Due_Cmpl',
					     'Num_Past_Due_Cmpl',
					     'N'
					     );

		poa_dbi_util_pkg.add_column (l_col_tbl,
					     'Num_past_due',
					     'Num_past_due',
					     'N'
					     );


		l_stmt := 'select
		 cal.name VIEWBY
		, null BIV_ATTRIBUTE1
		, nvl(iset.p_num_created - nvl(iset.p_num_completion,0),0)  BIV_MEASURE1
		, nvl(iset.c_num_created - nvl(iset.c_num_completion,0),0)  BIV_MEASURE2' || '
		, ' ||
		 isc_maint_rpt_util_pkg.change_column
		   ( 'iset.c_num_created - nvl(iset.c_num_completion,0)'
		   , '(iset.p_num_created - nvl(iset.p_num_completion,0))'
		   , 'BIV_MEASURE3' ) || ' /* Change Backlog */
		, decode(sign(iset.p_num_past_due - nvl(iset.p_num_past_due_cmpl,0)), -1, 0, nvl(iset.p_num_past_due - nvl(iset.p_num_past_due_cmpl,0),0))  BIV_MEASURE5
		, decode(sign(iset.c_num_past_due - nvl(iset.c_num_past_due_cmpl,0)), -1, 0, nvl(iset.c_num_past_due - nvl(iset.c_num_past_due_cmpl,0),0))  BIV_MEASURE6' || '
		, ' ||
		isc_maint_rpt_util_pkg.change_column
		  ( 'decode(sign(iset.c_num_past_due - nvl(iset.c_num_past_due_cmpl,0)), -1, 0, nvl(iset.c_num_past_due - nvl(iset.c_num_past_due_cmpl,0),0))'
		  , 'decode(sign(iset.p_num_past_due - nvl(iset.p_num_past_due_cmpl,0)), -1, 0, nvl(iset.p_num_past_due - nvl(iset.p_num_past_due_cmpl,0),0))'
		  , 'BIV_MEASURE7' ) || ' /* Change Past Due */
		, ' ||
		isc_maint_rpt_util_pkg.rate_column
		  ( 'decode(sign(iset.p_num_past_due - nvl(iset.p_num_past_due_cmpl,0)), -1, 0, nvl(iset.p_num_past_due - nvl(iset.p_num_past_due_cmpl,0),0))'
		  , 'iset.p_num_created - nvl(iset.p_num_completion,0)'
		  , 'BIV_MEASURE9'
		  , 'Y' ) || '
		/* Prior Past Due percent */, ' ||
		isc_maint_rpt_util_pkg.rate_column
		  ( 'decode(sign(iset.c_num_past_due - nvl(iset.c_num_past_due_cmpl,0)), -1, 0, nvl(iset.c_num_past_due - nvl(iset.c_num_past_due_cmpl,0),0))'
		  , '(iset.c_num_created - nvl(iset.c_num_completion,0))'
		  , 'BIV_MEASURE10'
		  , 'Y' ) || '
		/* Past Due percent */, ' ||
		isc_maint_rpt_util_pkg.change_column
		  ( isc_maint_rpt_util_pkg.rate_column
		      ( 'decode(sign(iset.c_num_past_due - nvl(iset.c_num_past_due_cmpl,0)), -1, 0, nvl(iset.c_num_past_due - nvl(iset.c_num_past_due_cmpl,0),0))'
		      , '(iset.c_num_created - nvl(iset.c_num_completion,0))'
		      , ''
		      , 'Y' )
		  , isc_maint_rpt_util_pkg.rate_column
		      ( 'decode(sign(iset.p_num_past_due - nvl(iset.p_num_past_due_cmpl,0)), -1, 0, nvl(iset.p_num_past_due - nvl(iset.p_num_past_due_cmpl,0),0))'
		      , '(iset.p_num_created - nvl(iset.p_num_completion,0))'
		      , ''
		      , 'Y' )
		  , 'BIV_MEASURE11'
		  , 'N' ) || ' /* Past Due Percent Change */
		from
		' || poa_dbi_template_pkg.trend_sql
		      ( p_xtd                  => l_xtd
		      , p_comparison_type      => l_comparison_type
		      , p_fact_name            => l_mv
		      , p_where_clause         => l_where_clause
		      , p_col_name             => l_col_tbl
		      , p_use_grpid            => 'N'
		      );

		l_stmt := replace(l_stmt,'&BIS_NESTED_PATTERN', '1143');
		/* the next line can be used to dump the contents of the PMV parameters as comments into stmt */
		-- l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);

		x_custom_sql      := l_stmt;

		x_custom_output := l_custom_output;

		poa_dbi_util_pkg.get_custom_trend_binds
		( x_custom_output     => l_custom_output
		, p_xtd               => l_xtd
		, p_comparison_type   => l_comparison_type
		);

		if l_custom_output is not null then
		  for i in 1..l_custom_output.count loop
		    x_custom_output.extend;
		    x_custom_output(x_custom_output.count) := l_custom_output(i);
		  end loop;
		end if;

	end get_trd_sql;



	procedure get_cur_past_due_dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
	                    x_custom_sql  OUT NOCOPY VARCHAR2,
	                    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
	IS

		l_dimension_tbl    isc_maint_rpt_util_pkg.t_dimension_tbl;
		l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
		l_dim_bmap         number;
		l_comparison_type  varchar2(200);
		l_xtd              varchar2(200);
		l_where_clause     varchar2(10000);
		l_mv               varchar2(10000);
		l_stmt             varchar2(32767);

		l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
		l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

		l_custom_output    bis_query_attributes_tbl;

		l_curr_suffix      varchar2(2);

		l_rank_order       varchar2(100);
		l_order_by         varchar2(200);
		l_asc_desc         varchar2(100);

		l_viewby_select varchar2(200);

		l_detail_col_tbl isc_maint_rpt_util_pkg.t_detail_column_tbl;


	begin

		  -- clear out the tables.
		  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
		  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  	  	isc_maint_rpt_util_pkg.register_dimension_levels
		( l_dimension_tbl
		, l_dim_filter_map
		, isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
		, isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
		, isc_maint_rpt_util_pkg.G_ACTIVITY, 'Y'
		, isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE, 'Y'
		, isc_maint_rpt_util_pkg.G_PAST_DUE_AGING, 'Y'
                , isc_maint_rpt_util_pkg.G_WORK_ORDER_STATUS, 'Y'
		);

		isc_maint_rpt_util_pkg.process_parameters
		( p_param            => p_param
		, p_dimension_tbl    => l_dimension_tbl
		, p_dim_filter_map   => l_dim_filter_map
		, p_trend            => 'D'
		, p_custom_output    => l_custom_output
		, x_cur_suffix       => l_curr_suffix
		, x_where_clause     => l_where_clause
		, x_viewby_select    => l_viewby_select
		, x_join_tbl         => l_join_tbl
		, x_dim_bmap         => l_dim_bmap
		, x_comparison_type  => l_comparison_type
		, x_xtd              => l_xtd
		);

		l_mv := get_fact_mv_name
		        ( 'WORK_ORDER_PAST_DUE_DTL'
		        , p_param
		        , l_dim_bmap
		        , l_custom_output
		        );

		l_order_by := isc_maint_rpt_util_pkg.get_parameter_value
              ( p_param
              , 'ORDERBY'
              );

		if l_order_by like '% DESC%' then
		    l_asc_desc := ' desc ';
		else
		    l_asc_desc := ' asc ';
		end if;

		l_rank_order := 'order by ' ||
		                case
		                  when l_order_by like '%BIV_ATTRIBUTE7%' then
		                    'status_type'
		                  when l_order_by like '%BIV_ATTRIBUTE10%' then
		                    'SCHEDULED_START_DATE'
		                  when l_order_by like '%BIV_ATTRIBUTE11%' then
		                    'SCHEDULED_COMPLETION_DATE'
						  when l_order_by like '%BIV_ATTRIBUTE12%' then
		                    'Past_due_days'
		                  else
						    'Past_due_days'
		                end ||
		                l_asc_desc ||
		                'nulls last, organization_id, work_order_id';


		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'work_order_id'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'work_order_id'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'work_order_name'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'work_order_name'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE
		, p_column_key         => 'work_order_type'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_ASSET_NUMBER
		, p_column_key         => 'asset_number'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_ASSET_GROUP
		, p_column_key         => 'asset_group'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_ACTIVITY
		, p_column_key         => 'activity'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'status_name'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'status_type'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_DEPARTMENT
		, p_column_key         => 'department'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'SCHEDULED_START_DATE'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'SCHEDULED_START_DATE'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'SCHEDULED_COMPLETION_DATE'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'SCHEDULED_COMPLETION_DATE'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'LAST_COLLECTION_DATE'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'LAST_COLLECTION_DATE'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'Past_due_days'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'Past_due_days'
		);

		 l_stmt := 'select
		  oset.work_order_name BIV_ATTRIBUTE1
                , null BIV_ATTRIBUTE2 ' || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		      (l_detail_col_tbl,'work_order_type','BIV_ATTRIBUTE3') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		      (l_detail_col_tbl,'asset_number','BIV_ATTRIBUTE4') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		      (l_detail_col_tbl,'asset_group','BIV_ATTRIBUTE5') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		      (l_detail_col_tbl,'activity','BIV_ATTRIBUTE6') || '
		, oset.status_type BIV_ATTRIBUTE7' || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		      (l_detail_col_tbl,'department','BIV_ATTRIBUTE9') || '
		, oset.SCHEDULED_START_DATE BIV_ATTRIBUTE10
		, oset.SCHEDULED_COMPLETION_DATE BIV_ATTRIBUTE11
		, oset.Past_due_days BIV_ATTRIBUTE12 ' || '
		, null							 BIV_ATTRIBUTE13
		, ' || isc_maint_rpt_util_pkg.get_drill_detail('BIV_ATTRIBUTE8') || '
		from
		' || isc_maint_rpt_util_pkg.detail_sql
		     ( p_detail_col_tbl => l_detail_col_tbl
		     , p_dimension_tbl  => l_dimension_tbl
		     , p_mv_name        => l_mv
		     , p_where_clause   => l_where_clause
		     , p_rank_order     => l_rank_order
			 , p_override_date_clause => '1 = 1 '
		     );

		/* the next line can be used to dump the contents of the PMV parameters as comments into stmt */
		-- l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);

		x_custom_sql      := l_stmt;

		x_custom_output := l_custom_output;

	end get_cur_past_due_dtl_sql;



	procedure get_wo_bl_dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
	                 x_custom_sql  OUT NOCOPY VARCHAR2,
	                 x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
	is

		l_dimension_tbl    isc_maint_rpt_util_pkg.t_dimension_tbl;
		l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
		l_dim_bmap         number;

	  	l_comparison_type  varchar2(200);
		l_xtd              varchar2(200);
		l_where_clause     varchar2(10000);
		l_mv               varchar2(10000);
		l_stmt             varchar2(32767);

		l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
		l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

		l_custom_output    bis_query_attributes_tbl;

		l_curr_suffix      varchar2(2);

		l_rank_order       varchar2(100);
		l_order_by         varchar2(200);
		l_asc_desc         varchar2(100);

		l_viewby_select varchar2(200);

		l_detail_col_tbl isc_maint_rpt_util_pkg.t_detail_column_tbl;

	begin

		-- clear out the tables.
		l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
		l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

		isc_maint_rpt_util_pkg.register_dimension_levels
		( l_dimension_tbl
		, l_dim_filter_map
		, isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
		, isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
		, isc_maint_rpt_util_pkg.G_ACTIVITY, 'Y'
		, isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE, 'Y'
                , isc_maint_rpt_util_pkg.G_WORK_ORDER_STATUS, 'Y'
		);

		isc_maint_rpt_util_pkg.process_parameters
		( p_param            => p_param
		, p_dimension_tbl    => l_dimension_tbl
		, p_dim_filter_map   => l_dim_filter_map
		, p_trend            => 'D'
		, p_custom_output    => l_custom_output
		, x_cur_suffix       => l_curr_suffix
		, x_where_clause     => l_where_clause
		, x_viewby_select    => l_viewby_select
		, x_join_tbl         => l_join_tbl
		, x_dim_bmap         => l_dim_bmap
		, x_comparison_type  => l_comparison_type
		, x_xtd              => l_xtd
		);

		l_mv := get_fact_mv_name
		        ( 'WORK_ORDER_BACKLOG_DTL'
		        , p_param
		        , l_dim_bmap
		        , l_custom_output
		        );


		l_order_by := isc_maint_rpt_util_pkg.get_parameter_value
              ( p_param
              , 'ORDERBY'
              );

		if l_order_by like '% DESC%' then
		    l_asc_desc := ' desc ';
		else
		    l_asc_desc := ' asc ';
		end if;

		l_rank_order := 'order by ' ||
		                case
		                  when l_order_by like '%BIV_ATTRIBUTE7%' then
		                    'status_type'
		                  when l_order_by like '%BIV_ATTRIBUTE10%' then
		                    'SCHEDULED_START_DATE'
		                  when l_order_by like '%BIV_ATTRIBUTE11%' then
		                    'SCHEDULED_COMPLETION_DATE'
		                  else
						    'scheduled_completion_date'
		                end ||
		                l_asc_desc ||
		                'nulls last, organization_id, work_order_id';


		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'work_order_id'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'work_order_id'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'work_order_name'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'work_order_name'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE
		, p_column_key         => 'work_order_type'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_ASSET_NUMBER
		, p_column_key         => 'asset_number'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_ASSET_GROUP
		, p_column_key         => 'asset_group'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_ACTIVITY
		, p_column_key         => 'activity'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'status_name'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'status_type'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_DEPARTMENT
		, p_column_key         => 'department'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'SCHEDULED_START_DATE'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'SCHEDULED_START_DATE'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'SCHEDULED_COMPLETION_DATE'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'SCHEDULED_COMPLETION_DATE'
		);

		 l_stmt := 'select
		  oset.work_order_name BIV_ATTRIBUTE1
                , null BIV_ATTRIBUTE2 ' || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		      (l_detail_col_tbl,'work_order_type','BIV_ATTRIBUTE3') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		      (l_detail_col_tbl,'asset_number','BIV_ATTRIBUTE4') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		      (l_detail_col_tbl,'asset_group','BIV_ATTRIBUTE5') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		      (l_detail_col_tbl,'activity','BIV_ATTRIBUTE6') || '
		, status_type BIV_ATTRIBUTE7' || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		      (l_detail_col_tbl,'department','BIV_ATTRIBUTE9') || '
		, oset.SCHEDULED_START_DATE BIV_ATTRIBUTE10
		, oset.SCHEDULED_COMPLETION_DATE BIV_ATTRIBUTE11' || '
		, ' || isc_maint_rpt_util_pkg.get_drill_detail('BIV_ATTRIBUTE8') || '
		from
		' || isc_maint_rpt_util_pkg.detail_sql
		     ( p_detail_col_tbl => l_detail_col_tbl
		     , p_dimension_tbl  => l_dimension_tbl
		     , p_mv_name        => l_mv
		     , p_where_clause   => l_where_clause
		     , p_rank_order     => l_rank_order
			 , p_override_date_clause => '1 = 1 '
		     );


		/* the next line can be used to dump the contents of the PMV parameters as comments into stmt */
		-- l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);

		x_custom_sql      := l_stmt;

		x_custom_output := l_custom_output;

	end get_wo_bl_dtl_sql;



	procedure get_pastdue_aging_sql
	( p_param           in bis_pmv_page_parameter_tbl
	, x_custom_sql      out nocopy varchar2
	, x_custom_output   out nocopy bis_query_attributes_tbl
	)
	as
		l_dimension_tbl    isc_maint_rpt_util_pkg.t_dimension_tbl;
		l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
		l_dim_bmap         number;
		l_comparison_type  varchar2(200);
		l_xtd              varchar2(200);
		l_where_clause     varchar2(10000);
		l_mv               varchar2(10000);
		l_stmt             varchar2(32767);

		l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
		l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

		l_custom_output    bis_query_attributes_tbl;

		l_curr_suffix      varchar2(2);

		l_rank_order       varchar2(100);

		l_viewby_select varchar2(200);

		l_orderby		 varchar2(40);

		l_detail_col_tbl isc_maint_rpt_util_pkg.t_detail_column_tbl;

	begin

		-- clear out the tables.
		l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
		l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

	  	isc_maint_rpt_util_pkg.register_dimension_levels
		( l_dimension_tbl
		, l_dim_filter_map
		, isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
		, isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
		, isc_maint_rpt_util_pkg.G_ACTIVITY, 'Y'
		, isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE, 'Y'
		, isc_maint_rpt_util_pkg.G_WORK_ORDER_STATUS, 'Y'
		, isc_maint_rpt_util_pkg.G_PAST_DUE_AGING, 'N'
		);

		isc_maint_rpt_util_pkg.process_parameters
		( p_param            => p_param
		, p_dimension_tbl    => l_dimension_tbl
		, p_dim_filter_map   => l_dim_filter_map
		, p_trend            => 'D'
		, p_custom_output    => l_custom_output
		, x_cur_suffix       => l_curr_suffix
		, x_where_clause     => l_where_clause
		, x_viewby_select    => l_viewby_select
		, x_join_tbl         => l_join_tbl
		, x_dim_bmap         => l_dim_bmap
		, x_comparison_type  => l_comparison_type
		, x_xtd              => l_xtd
		);

		l_mv := get_fact_mv_name
		        ( 'WORK_ORDER_PAST_DUE_AGING'
		        , p_param
		        , l_dim_bmap
		        , l_custom_output
		        );

		 isc_maint_rpt_util_pkg.add_detail_column
		 ( p_detail_col_tbl     => l_detail_col_tbl
		 , p_dimension_tbl      => l_dimension_tbl
		 , p_dimension_level    => isc_maint_rpt_util_pkg.G_PAST_DUE_AGING
		 , p_column_key         => 'bucket_name'
		 );

		 isc_maint_rpt_util_pkg.add_detail_column
		 ( p_detail_col_tbl     => l_detail_col_tbl
		 , p_dimension_tbl      => l_dimension_tbl
		 , p_fact_col_name      => 'sum(c_num_pastdue)'
		 , p_fact_col_total     => 'Y'
		 , p_column_key         => 'c_num_pastdue'
		 );

		 l_stmt := 'select
		  ''pFunctionName=ISC_MAINT_PAST_DUE_DTL_RPT_REP'' ||
		  ''&VIEW_BY_NAME=VIEW_BY_ID'' ||
		  ''&pParamIds=Y'' BIV_ATTRIBUTE1,
		 ' || isc_maint_rpt_util_pkg.get_detail_column
		      (l_detail_col_tbl,'bucket_name','VIEWBY') || '
	  	, id VIEWBYID
		, nvl(oset.c_num_pastdue,0)  BIV_MEASURE1' || '
		, ' ||
		  isc_maint_rpt_util_pkg.rate_column
		    ( 'oset.c_num_pastdue'
		    , 'avg(oset.c_num_pastdue_total) over()'
		    , 'BIV_MEASURE2'
		    , 'Y' ) || '
		 /* Percent of Total */ ' || '
		, nvl(avg(oset.c_num_pastdue_total) over(),0)  BIV_MEASURE3' || '
		, ' ||
		  isc_maint_rpt_util_pkg.rate_column
		    ( 'avg(oset.c_num_pastdue_total) over()'
		    , 'avg(oset.c_num_pastdue_total) over()'
		    , 'BIV_MEASURE4'
		    , 'Y' ) || '
		/* Grand Total Percent of Total */  ' || '
		, null BIV_ATTRIBUTE11
		from
		' || isc_maint_rpt_util_pkg.detail_sql
		    ( p_detail_col_tbl => l_detail_col_tbl
		    , p_dimension_tbl  => l_dimension_tbl
		    , p_mv_name        => l_mv
		    , p_where_clause   => l_where_clause
		    , p_rank_order     => l_rank_order
			, p_filter_where   => 'group by bucket_num'
			, p_override_date_clause => '1 = 1 '
		    );

		/* the next line can be used to dump the contents of the PMV parameters as comments into stmt */
		-- l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);

		l_orderby := 'ORDER BY VIEWBYID ASC';

		l_stmt := replace(l_stmt,'&ORDER_BY_CLAUSE',l_orderby);

		x_custom_sql      := l_stmt;

		x_custom_output := l_custom_output;

	end get_pastdue_aging_sql;

end ISC_MAINT_WO_BACKLOG_RPT_PKG;

/
