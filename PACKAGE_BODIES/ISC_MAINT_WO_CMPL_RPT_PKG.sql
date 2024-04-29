--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_WO_CMPL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_WO_CMPL_RPT_PKG" 
/*$Header: iscmaintwocrptb.pls 120.1 2005/09/13 05:38:08 nbhamidi noship $ */
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

	  if p_report_type = 'WORK_ORDER_CMPL' then

	  	l_view_by := isc_maint_rpt_util_pkg.get_parameter_value
	                 ( p_param
	                 , 'VIEW_BY'
	                 );

	    isc_maint_rpt_util_pkg.bind_group_id
	    ( p_dim_bmap
	    , p_custom_output
	  /*  , isc_maint_rpt_util_pkg.G_DEPARTMENT  Removed rollup from MV */
	    , isc_maint_rpt_util_pkg.G_ACTIVITY
	    , isc_maint_rpt_util_pkg.G_ASSET_GROUP
	    , isc_maint_rpt_util_pkg.G_ASSET_NUMBER
	  /*  , isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE Removed rollup from MV */
	    );

	    return ' (select
	      time_id
	    , period_type_id
	    , grp_id
	    , ' ||
	      case l_view_by
	        when isc_maint_rpt_util_pkg.G_DEPARTMENT then 'decode(department_id,-1,-1,organization_id) organization_id'
	        when isc_maint_rpt_util_pkg.G_ASSET_GROUP then 'decode(asset_group_id,-1,-1,organization_id) organization_id'
	        when isc_maint_rpt_util_pkg.G_ASSET_NUMBER then 'decode(instance_id,-1,-1,organization_id) organization_id' /* replaced asset_number with instance_id */
	        when isc_maint_rpt_util_pkg.G_ACTIVITY then 'decode(activity_id,-1,-1,organization_id) organization_id'
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
	    , num_completion
	    , num_late_completion
	    , days_late
	    from isc_maint_004_mv fact' || '
	    where fact.grp_id = &ISC_GRP_ID ' ||
	    case
	      when l_org_id is null then
	        '
	    and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'fact', l_org_id )
	    end || '
	  )';

	  elsif p_report_type = 'WORK_ORDER_LATE_CMPL_AGING' then

	  	l_view_by := isc_maint_rpt_util_pkg.get_parameter_value
	                 ( p_param
	                 , 'VIEW_BY'
	                 );

	    isc_maint_rpt_util_pkg.bind_group_id
	    ( p_dim_bmap
	    , p_custom_output
	    , isc_maint_rpt_util_pkg.G_DEPARTMENT
	    , isc_maint_rpt_util_pkg.G_ACTIVITY
	    , isc_maint_rpt_util_pkg.G_ASSET_GROUP
	    , isc_maint_rpt_util_pkg.G_ASSET_NUMBER
	    , isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE
	    );

	    return ' (select
	      time_id
	    , period_type_id
	    , grp_id
	    , organization_id
	    , organization_id organization_id_c
	    , bucket_num
	    , asset_group_id
	    , instance_id /* replaced asset_number with instance_id */
	    , activity_id
	    , work_order_type
	    , to_char(department_id) department_id
	    , asset_group_id  asset_group_id_c /* removed concatenation to org. to make asset group independent of org. */
	    , decode(instance_id,-1,-1,instance_id) instance_id_c /* replaced asset_number with instance_id */
	    , decode(activity_id,-1,''-1'',activity_id||''-''||organization_id) activity_id_c
		, decode(department_id,-1,''-1'',department_id||''-1'') department_id_c
	    , num_count
	    from isc_maint_006_mv fact' || '
	    where fact.grp_id = &ISC_GRP_ID ' ||
	    case
	      when l_org_id is null then
	        '
	    and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'fact', l_org_id )
	    end || '
	  )';


	  elsif p_report_type = 'WORK_ORDER_CMPL_DTL' then
	  return '(select
	           activity_id
	         , organization_id
 	         , organization_id organization_id_c
	         , asset_group_id
	         , instance_id /* replaced asset_number with instance_id */
		 , work_order_name
	         , to_char(department_id) department_id
	         , asset_group_id	  asset_group_id_c
	         , decode(instance_id,-1,-1,instance_id) instance_id_c /* replaced asset_number with instance_id */
	         , decode(activity_id,-1,''-1'',activity_id||''-''||organization_id) activity_id_c
		 , decode(department_id,-1,''-1'',department_id||''-1'') department_id_c
	         , work_order_id
	         , status.value wo_status
	         , work_order_type
	         , SCHEDULED_COMPLETION_DATE
	         , SCHEDULED_START_DATE
	         , COMPLETION_DATE
	        from isc_maint_work_orders_f f,
		     biv_maint_wo_status_lvl_v status
	        where
				 f.user_defined_status_id = status.id
			 and f.Include_WO = 1 /* Do not include Pending Close, Failed Close, Cancelled */
	         and f.COMPLETION_DATE is not null
	         and f.COMPLETION_DATE <= &BIS_CURRENT_ASOF_DATE
	         and f.COMPLETION_DATE >= &BIS_CURRENT_EFFECTIVE_START_DATE ' ||
	          case
	            when l_org_id is null then
	              '
	          and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'f', l_org_id )
	         end || '
	      ) ';

	  elsif p_report_type = 'WORK_ORDER_LATE_DTL' then
	  return '(select
	          activity_id
	         , organization_id
 	         , organization_id organization_id_c
	         , asset_group_id
	         , instance_id /* replaced asset_number with instance_id */
		 , work_order_name
	         , to_char(department_id) department_id
	         , asset_group_id  asset_group_id_c /* removed concatenation to org. to make asset group independent of org. */
	         , decode(instance_id,-1,-1,instance_id) instance_id_c /* replaced asset_number with instance_id */
	         , decode(activity_id,-1,''-1'',activity_id||''-''||organization_id) activity_id_c
	 	 , decode(department_id,-1,''-1'',department_id||''-1'') department_id_c
	         , work_order_id
	         , status.value wo_status
	         , work_order_type
	         , SCHEDULED_COMPLETION_DATE
	         , SCHEDULED_START_DATE
	         , COMPLETION_DATE
	         , DAYS_LATE
	         , case
			    when f.days_late >= b.range1_low and (f.days_late < b.range1_high or b.range1_high is null) then 1
	            when f.days_late >= b.range2_low and (f.days_late < b.range2_high or b.range2_high is null) then 2
	            when f.days_late >= b.range3_low and (f.days_late < b.range3_high or b.range3_high is null) then 3
	            when f.days_late >= b.range4_low and (f.days_late < b.range4_high or b.range4_high is null) then 4
	            when f.days_late >= b.range5_low and (f.days_late < b.range5_high or b.range5_high is null) then 5
	            when f.days_late >= b.range6_low and (f.days_late < b.range6_high or b.range6_high is null) then 6
	            when f.days_late >= b.range7_low and (f.days_late < b.range7_high or b.range7_high is null) then 7
	            when f.days_late >= b.range8_low and (f.days_late < b.range8_high or b.range8_high is null) then 8
	            when f.days_late >= b.range9_low and (f.days_late < b.range9_high or b.range9_high is null) then 9
	         else 10
	         end bucket_num
	      from isc_maint_work_orders_f f,
		  	   bis_bucket_customizations b,
			   bis_bucket bb,
			   biv_maint_wo_status_lvl_v status
	        where
				f.user_defined_status_id = status.id
			and f.Include_WO = 1 /* Do not include Pending Close, Failed Close, Cancelled */
			and f.COMPLETION_DATE is not null
			and bb.short_name = ''BIV_MAINT_LATECMPL_AGING''
			and bb.bucket_id = b.bucket_id
			and f.SCHEDULED_COMPLETION_DATE < f.COMPLETION_DATE
			and f.COMPLETION_DATE <= &BIS_CURRENT_ASOF_DATE
			and f.COMPLETION_DATE >= &BIS_CURRENT_EFFECTIVE_START_DATE ' ||
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

	  l_viewby_select varchar2(200);
	  l_asset_grp_column varchar2(200);
	  l_inner_query      varchar2(5000);

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
	          ( 'WORK_ORDER_CMPL'
	          , p_param
	          , l_dim_bmap
	          , l_custom_output
	          );

		-- The measure columns that need to be aggregated are
		-- completed_wo, on_time_cmp_wo, late_cmp_wo

		poa_dbi_util_pkg.add_column (l_col_tbl,
		                           'num_completion',
		                           'num_completion');

		poa_dbi_util_pkg.add_column (l_col_tbl,
		                           'num_late_completion',
		                           'num_late_completion');
		poa_dbi_util_pkg.add_column (l_col_tbl,
		                           'days_late',
		                           'days_late');

       /* if view by is asset number add asset_group column */

	if(isc_maint_rpt_util_pkg.get_parameter_id(p_param,'VIEW_BY')) =
        isc_maint_rpt_util_pkg.G_ASSET_NUMBER then
        l_asset_grp_column := isc_maint_rpt_util_pkg.add_asset_group_column(isc_maint_rpt_util_pkg.G_ASSET_NUMBER,l_dimension_tbl);
        else
        l_asset_grp_column :='NULL';
        end if ;

/* to enable windowing we are using an addition inline view */
l_stmt := ' select ' || l_viewby_select ||
        ', BIV_ATTRIBUTE1
         , BIV_ATTRIBUTE2
         , BIV_MEASURE1
         , BIV_MEASURE2
         , BIV_MEASURE3
         , BIV_MEASURE22
         , BIV_MEASURE4
         , BIV_MEASURE23
         , BIV_MEASURE5
         , BIV_MEASURE6
         , BIV_MEASURE7
         , BIV_MEASURE8
         , BIV_MEASURE9
         , BIV_MEASURE10
         , BIV_MEASURE11
         , BIV_MEASURE12
         , BIV_MEASURE26
         , BIV_MEASURE13
         , BIV_MEASURE14
         , BIV_MEASURE15
         , BIV_MEASURE24
         , BIV_MEASURE16
         , BIV_MEASURE17
         , BIV_MEASURE18
         , BIV_MEASURE28
         , BIV_MEASURE19
         , BIV_MEASURE20
         , BIV_MEASURE21 ,
          ' ||
              l_asset_grp_column ||' BIV_MEASURE30  ';

/* calculate the rank on the sorting column in the inline view */

l_inner_query := 'from ( select row_number() over(&ORDER_BY_CLAUSE)-1 rnk,iset.*
		  from (select '||
	  case
	  when isc_maint_rpt_util_pkg.get_parameter_id
         ( p_param
         , 'VIEW_BY'
         ) in ( isc_maint_rpt_util_pkg.G_ASSET_GROUP
              , isc_maint_rpt_util_pkg.G_ASSET_NUMBER
              , isc_maint_rpt_util_pkg.G_ACTIVITY ) then
      '
	 ''pFunctionName=ISC_MAINT_WO_CMPL_DTL_RPT_REP'' ||
	  ''&VIEW_BY_NAME=VIEW_BY_ID'' ||
	  ''&pParamIds=Y'' BIV_ATTRIBUTE1 '
	    else '
	 null  BIV_ATTRIBUTE1 ' end || '
	, ''pFunctionName=ISC_MAINT_LATECMPL_DTL_RPT_REP'' ||
	  ''&VIEW_BY_NAME=VIEW_BY_ID'' ||
	  ''&pParamIds=Y''  BIV_ATTRIBUTE2
	, nvl(oset05.p_num_completion,0)  BIV_MEASURE1
	, nvl(oset05.c_num_completion,0)  BIV_MEASURE2' || '
	, ' ||
	  isc_maint_rpt_util_pkg.change_column
	    ( 'oset05.c_num_completion'
	    , 'oset05.p_num_completion'
	    , 'BIV_MEASURE3' ) || ' /* Completion Change */
	, nvl(oset05.p_num_completion - oset05.p_num_late_completion,0) BIV_MEASURE22
	, nvl(oset05.c_num_completion - oset05.c_num_late_completion,0) BIV_MEASURE4 ' || '
	, ' ||
	  isc_maint_rpt_util_pkg.change_column
	    ( 'oset05.c_num_completion - oset05.c_num_late_completion'
	    , 'oset05.p_num_completion - oset05.p_num_late_completion'
	    , 'BIV_MEASURE23' ) || ' /* On Time Completion Change */
	, ' ||
	  isc_maint_rpt_util_pkg.rate_column
	    ( 'oset05.p_num_completion - oset05.p_num_late_completion'
	    , 'oset05.p_num_completion'
	    , 'BIV_MEASURE5'
	    , 'Y' ) || '
	 /* Prior On time completion percent */, ' ||
	  isc_maint_rpt_util_pkg.rate_column
	    ( 'oset05.c_num_completion - oset05.c_num_late_completion'
	    , 'oset05.c_num_completion'
	    , 'BIV_MEASURE6'
	    , 'Y' ) || '
	 /* On time completion percent */, ' ||
	  isc_maint_rpt_util_pkg.change_column
	    ( isc_maint_rpt_util_pkg.rate_column
	        ( 'oset05.c_num_completion - oset05.c_num_late_completion'
	        , 'oset05.c_num_completion'
	        , ''
	        , 'Y' )
	    , isc_maint_rpt_util_pkg.rate_column
	        ( 'oset05.p_num_completion - oset05.p_num_late_completion'
	        , 'oset05.p_num_completion'
	        , ''
	        , 'Y' )
	    , 'BIV_MEASURE7'
	    , 'N' ) || ' /* On Time Completion Change */
	, nvl(oset05.c_num_late_completion,0) BIV_MEASURE8 ' || '
	, ' ||
	  isc_maint_rpt_util_pkg.rate_column
	    ( 'oset05.p_num_late_completion'
	    , 'oset05.p_num_completion'
	    , 'BIV_MEASURE9'
	    , 'Y' ) || '
	 /* Late Completion Percent */, ' ||
	  isc_maint_rpt_util_pkg.rate_column
	    ( 'oset05.c_num_late_completion'
	    , 'oset05.c_num_completion'
	    , 'BIV_MEASURE10'
	    , 'Y' ) || '
	 /* Prior Late Completion Percent */, ' ||
	  isc_maint_rpt_util_pkg.change_column
	    ( isc_maint_rpt_util_pkg.rate_column
	        ( 'oset05.c_num_late_completion'
	        , 'oset05.c_num_completion'
	        , ''
	        , 'Y' )
	    , isc_maint_rpt_util_pkg.rate_column
	        ( 'oset05.p_num_late_completion'
	        , 'oset05.p_num_completion'
	        , ''
	        , 'Y' )
	    , 'BIV_MEASURE11'
	    , 'N' ) || '
	 /* Late Completion Change */, ' ||
	  isc_maint_rpt_util_pkg.rate_column
	    ( 'oset05.c_days_late'
	    , 'oset05.c_num_late_completion'
	    , 'BIV_MEASURE12'
	    , 'N' ) || ' /* Average Days Late */
	, nvl(oset05.p_num_completion_total,0) BIV_MEASURE26 ' || '
	, nvl(oset05.c_num_completion_total,0) BIV_MEASURE13 ' || '
	, ' ||
	  isc_maint_rpt_util_pkg.rate_column
	    ( 'oset05.c_num_completion_total - oset05.p_num_completion_total'
	    , 'oset05.p_num_completion_total'
	    , 'BIV_MEASURE14'
	    , 'Y' ) || ' /* Grand Total Completion Change */
	, nvl(oset05.c_num_completion_total - oset05.c_num_late_completion_total,0) BIV_MEASURE15 ' || '
	, ' ||
		  isc_maint_rpt_util_pkg.rate_column
	    ( 'oset05.c_num_completion_total - oset05.c_num_late_completion_total'
	    , 'oset05.p_num_completion_total - oset05.p_num_late_completion_total'
	    , 'BIV_MEASURE24'
	    , 'Y' ) || ' /* Grand Total On time completion Change */, ' ||
	  isc_maint_rpt_util_pkg.rate_column
	    ( 'oset05.c_num_completion_total - oset05.c_num_late_completion_total'
	    , 'oset05.c_num_completion_total'
	    , 'BIV_MEASURE16'
	    , 'Y' ) || ' /* On time completion percent Grand Total */, ' ||
	  isc_maint_rpt_util_pkg.change_column
	    ( isc_maint_rpt_util_pkg.rate_column
	        ( 'oset05.c_num_completion_total - oset05.c_num_late_completion_total'
	        , 'oset05.c_num_completion_total'
	        , ''
	        , 'Y' )
	    , isc_maint_rpt_util_pkg.rate_column
	        ( 'oset05.p_num_completion_total - oset05.p_num_late_completion_total'
	        , 'oset05.p_num_completion_total'
	        , ''
	        , 'Y' )
	    , 'BIV_MEASURE17'
	    , 'N' ) || ' /* Grand Total On Time Completion Percent Change */
	, nvl(oset05.c_num_late_completion_total,0) BIV_MEASURE18, ' ||
	  isc_maint_rpt_util_pkg.rate_column
	    ( 'oset05.p_num_late_completion_total'
	    , 'oset05.p_num_completion_total'
	    , 'BIV_MEASURE28'
	    , 'Y' ) || ' /* Prior Late Completion Percent Grand Total */, ' ||
	  isc_maint_rpt_util_pkg.rate_column
	    ( 'oset05.c_num_late_completion_total'
	    , 'oset05.c_num_completion_total'
	    , 'BIV_MEASURE19'
	    , 'Y' ) || ' /* Late Completion Percent Grand Total */, ' ||
	  isc_maint_rpt_util_pkg.change_column
	    ( isc_maint_rpt_util_pkg.rate_column
	        ( 'oset05.c_num_late_completion_total'
	        , 'oset05.c_num_completion_total'
	        , ''
	        , 'Y' )
	    , isc_maint_rpt_util_pkg.rate_column
	        ( 'oset05.p_num_late_completion_total'
	        , 'oset05.p_num_completion_total'
	        , ''
	        , 'Y' )
	    , 'BIV_MEASURE20'
	    , 'N' ) || ' /* Grand Total Late Completion Change */, ' ||
	  isc_maint_rpt_util_pkg.rate_column
	    ( 'oset05.c_days_late_total'
	    , 'c_num_late_completion_total'
	    , 'BIV_MEASURE21'
	    , 'N' ) || ' , ' ||
	    isc_maint_rpt_util_pkg.get_inner_select_col(l_join_tbl)||' from ';


	l_stmt := l_stmt || l_inner_query ||  poa_dbi_template_pkg.status_sql
	        ( p_fact_name            => l_mv
	        , p_where_clause         => l_where_clause
	        , p_join_tables          => l_join_tbl
	        , p_use_windowing        => 'Y'
	        , p_col_name             => l_col_tbl
	        , p_use_grpid            => 'N'
	        , p_paren_count          => 2
	        , p_filter_where         => '(c_num_completion <> 0 or p_num_completion <> 0
		or c_num_late_completion <> 0 or p_num_late_completion <> 0 or c_days_late <> 0 or p_days_late <> 0))iset'
	        , p_generate_viewby      => 'Y'
	        );

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
          ( 'WORK_ORDER_CMPL'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

	    -- The measure columns that need to be aggregated are
	    -- completed_wo, on_time_cmp_wo, late_cmp_wo
	    -- No Grand totals required.

	    poa_dbi_util_pkg.add_column (l_col_tbl,
	                                 'num_completion',
	                                 'num_completion',
	                                 'N');

	    poa_dbi_util_pkg.add_column (l_col_tbl,
	                                 'num_late_completion',
	                                 'num_late_completion',
					 'N');
	    poa_dbi_util_pkg.add_column (l_col_tbl,
	                                 'days_late',
	                                 'days_late',
					 'N');

	  l_stmt := 'select
		  cal.name VIEWBY
		, nvl(iset.p_num_completion,0)  BIV_MEASURE1
		, nvl(iset.c_num_completion,0)  BIV_MEASURE2
		, ' ||
		  isc_maint_rpt_util_pkg.change_column
		    ( 'iset.c_num_completion'
		    , 'iset.p_num_completion'
		    , 'BIV_MEASURE3' ) || ' /* Completion Change */
		, nvl(iset.p_num_completion - iset.p_num_late_completion,0) BIV_MEASURE13
		, nvl(iset.c_num_completion - iset.c_num_late_completion,0) BIV_MEASURE4
		, ' ||
		  isc_maint_rpt_util_pkg.change_column
		    ( 'iset.c_num_completion - iset.c_num_late_completion'
		    , 'iset.p_num_completion - iset.p_num_late_completion'
		    , 'BIV_MEASURE14' ) || ' /* On time Completion Change */
		, ' ||
		  isc_maint_rpt_util_pkg.rate_column
		    ( 'iset.p_num_completion - iset.p_num_late_completion'
		    , 'iset.p_num_completion'
		    , 'BIV_MEASURE5'
		    , 'Y' ) || '
		 /* Prior On time completion percent */
		 , ' ||
		  isc_maint_rpt_util_pkg.rate_column
		    ( 'iset.c_num_completion - iset.c_num_late_completion'
		    , 'iset.c_num_completion'
		    , 'BIV_MEASURE6'
		    , 'Y' ) || '
		 /* On time completion percent */
		 , ' ||
		  isc_maint_rpt_util_pkg.change_column
		    ( isc_maint_rpt_util_pkg.rate_column
		        ( 'iset.c_num_completion - iset.c_num_late_completion'
		        , 'iset.c_num_completion'
		        , ''
		        , 'Y' )
		    , isc_maint_rpt_util_pkg.rate_column
		        ( 'iset.p_num_completion - iset.p_num_late_completion'
		        , 'iset.p_num_completion'
		        , ''
		        , 'Y' )
		    , 'BIV_MEASURE7'
		    , 'N' ) || ' /* On Time Completion Change */
		, nvl(iset.c_num_late_completion,0) BIV_MEASURE8 ' || '
		, ' ||
		  isc_maint_rpt_util_pkg.rate_column
		    ( 'iset.p_num_late_completion'
		    , 'iset.p_num_completion'
		    , 'BIV_MEASURE9'
		    , 'Y' ) || '
		 /* Prior Late Completion Percent */, ' ||
		  isc_maint_rpt_util_pkg.rate_column
		    ( 'iset.c_num_late_completion'
		    , 'iset.c_num_completion'
		    , 'BIV_MEASURE10'
		    , 'Y' ) || '
		 /* Late Completion Percent */
		 , ' ||
		  isc_maint_rpt_util_pkg.change_column
		    ( isc_maint_rpt_util_pkg.rate_column
		        ( 'iset.c_num_late_completion'
		        , 'iset.c_num_completion'
		        , ''
		        , 'Y' )
		    , isc_maint_rpt_util_pkg.rate_column
		        ( 'iset.p_num_late_completion'
		        , 'iset.p_num_completion'
		        , ''
		        , 'Y' )
		    , 'BIV_MEASURE11'
		    , 'N' ) || '
		 /* Late Completion Change */
		 , ' ||
		  isc_maint_rpt_util_pkg.rate_column
		    ( 'iset.c_days_late'
		    , 'iset.c_num_late_completion'
		    , 'BIV_MEASURE12'
		    , 'N' ) || ' /* Average Days Late */
	from
	  ' || poa_dbi_template_pkg.trend_sql
	        ( p_xtd                  => l_xtd
	        , p_comparison_type      => l_comparison_type
	        , p_fact_name            => l_mv
	        , p_where_clause         => l_where_clause
	        , p_col_name             => l_col_tbl
	        , p_use_grpid            => 'N'
	        );

	  /* the next line can be used to dump the contents of the PMV parameters as comments into stmt */
	  --l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);

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



	procedure get_late_cmpl_age
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

	  l_orderby 		 varchar2(40);

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
 	  , isc_maint_rpt_util_pkg.G_LATE_CMPL_AGING, 'N'
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
	          ( 'WORK_ORDER_LATE_CMPL_AGING'
	          , p_param
	          , l_dim_bmap
	          , l_custom_output
	          );

	   -- The measure columns that need to be aggregated are
	   -- late_comp_wo

	   poa_dbi_util_pkg.add_column (l_col_tbl,
		                             'num_count',
		                             'num_count');

	  l_stmt := 'select
	' || l_viewby_select || '
	,''pFunctionName=ISC_MAINT_LATECMPL_DTL_RPT_REP'' ||
	''&VIEW_BY_NAME=VIEW_BY_ID'' ||
	''&pParamIds=Y'' BIV_ATTRIBUTE1
	, nvl(oset.p_num_count,0)  BIV_MEASURE1
	, nvl(oset.c_num_count,0)  BIV_MEASURE2' || '
	, ' ||
	  isc_maint_rpt_util_pkg.change_column
	    ( 'oset.c_num_count'
	    , 'oset.p_num_count'
	    , 'BIV_MEASURE3'
		, 'Y' ) || ' /* Late Completion Work Orders Change */
	, ' ||
	  isc_maint_rpt_util_pkg.rate_column
	    ( 'oset.c_num_count'
	    , 'avg(oset.c_num_count_total) over()'
	    , 'BIV_MEASURE4'
	    , 'Y' ) || '
	 /* Percent of Total */ ' || '
	 , nvl(avg(c_num_count_total) over(),0) BIV_MEASURE5
	 , ' ||
	  isc_maint_rpt_util_pkg.change_column
	    ( 'avg(oset.c_num_count_total) over()'
	    , 'avg(oset.p_num_count_total) over()'
	    , 'BIV_MEASURE6'
	    , 'Y' ) || ' /* Grand Total Late Completion Work Orders Change */
	, ' ||
	  isc_maint_rpt_util_pkg.rate_column
	    ( 'avg(c_num_count_total) over()'
	    , 'avg(c_num_count_total) over ()'
	    , 'BIV_MEASURE7'
	    , 'Y' ) || '
	 /* Grand Total Percent of Total */
	 , null BIV_ATTRIBUTE10
	 from
	( select * from ( ' || poa_dbi_template_pkg.status_sql
	        ( p_fact_name            => l_mv
	        , p_where_clause         => l_where_clause
	        , p_join_tables          => l_join_tbl
	        , p_use_windowing        => 'N'
	        , p_col_name             => l_col_tbl
	        , p_use_grpid            => 'N'
	        , p_paren_count          => 3
	        , p_filter_where         => ''
	        , p_generate_viewby      => 'Y'
	        );

	  /* the next line can be used to dump the contents of the PMV parameters as comments into stmt */
	  -- l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);

	  l_orderby := 'ORDER BY VIEWBYID ASC';

	  l_stmt := replace(l_stmt,'&ORDER_BY_CLAUSE',l_orderby);

	  x_custom_output := l_custom_output;

	  x_custom_sql    := l_stmt;

	end get_late_cmpl_age;



	PROCEDURE get_wo_dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
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

		l_viewby_select    varchar2(200);

		l_detail_col_tbl isc_maint_rpt_util_pkg.t_detail_column_tbl;

	BEGIN

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
		        ( 'WORK_ORDER_CMPL_DTL'
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
		                  when l_order_by like '%BIV_ATTRIBUTE6%' then
		                    'wo_status'
		                  when l_order_by like '%BIV_ATTRIBUTE9%' then
		                    'SCHEDULED_START_DATE'
		                  when l_order_by like '%BIV_ATTRIBUTE10%' then
		                    'SCHEDULED_COMPLETION_DATE'
		                  when l_order_by like '%BIV_ATTRIBUTE11%' then
		                    'COMPLETION_DATE'
		                  else
						    'COMPLETION_DATE'
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
		, p_fact_col_name      => 'wo_status'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'wo_status'
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
		, p_fact_col_name      => 'COMPLETION_DATE'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'COMPLETION_DATE'
		);


		l_stmt := 'select
		oset.work_order_name BIV_ATTRIBUTE1' || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'work_order_type','BIV_ATTRIBUTE2') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'asset_number','BIV_ATTRIBUTE3') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'asset_group','BIV_ATTRIBUTE4') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'activity','BIV_ATTRIBUTE5') || '
		, oset.wo_status BIV_ATTRIBUTE6' || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'department','BIV_ATTRIBUTE7') || '
		, oset.SCHEDULED_START_DATE BIV_ATTRIBUTE9
		, oset.SCHEDULED_COMPLETION_DATE BIV_ATTRIBUTE10
		, oset.COMPLETION_DATE BIV_ATTRIBUTE11 ' || '
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

	end get_wo_dtl_sql;


	PROCEDURE get_wo_late_dtl_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
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

		l_viewby_select    varchar2(200);

		l_detail_col_tbl isc_maint_rpt_util_pkg.t_detail_column_tbl;

	BEGIN

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
		, isc_maint_rpt_util_pkg.G_LATE_CMPL_AGING, 'Y'
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
		        ( 'WORK_ORDER_LATE_DTL'
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
		                  when l_order_by like '%BIV_ATTRIBUTE6%' then
		                    'wo_status'
		                  when l_order_by like '%BIV_ATTRIBUTE9%' then
		                    'SCHEDULED_START_DATE'
		                  when l_order_by like '%BIV_ATTRIBUTE10%' then
		                    'SCHEDULED_COMPLETION_DATE'
		                  when l_order_by like '%BIV_ATTRIBUTE11%' then
		                    'COMPLETION_DATE'
						  when l_order_by like '%BIV_ATTRIBUTE12%' then
		                    'days_late'
		                  else
						    'days_late'
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
		, p_fact_col_name      => 'wo_status'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'wo_status'
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
		, p_fact_col_name      => 'COMPLETION_DATE'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'COMPLETION_DATE'
		);

		isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'DAYS_LATE'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'DAYS_LATE'
		);


		l_stmt := 'select
		oset.work_order_name BIV_ATTRIBUTE1' || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'work_order_type','BIV_ATTRIBUTE2') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'asset_number','BIV_ATTRIBUTE3') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'asset_group','BIV_ATTRIBUTE4') || '
        , ' || isc_maint_rpt_util_pkg.get_detail_column
            (l_detail_col_tbl,'activity','BIV_ATTRIBUTE5') || '
		, oset.wo_status BIV_ATTRIBUTE6' || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'department','BIV_ATTRIBUTE7') || '
		, oset.SCHEDULED_START_DATE BIV_ATTRIBUTE9
		, oset.SCHEDULED_COMPLETION_DATE BIV_ATTRIBUTE10
		, oset.COMPLETION_DATE BIV_ATTRIBUTE11
		, oset.DAYS_LATE BIV_ATTRIBUTE12 ' || '
		, null	BIV_ATTRIBUTE13
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

	end get_wo_late_dtl_sql;

end isc_maint_wo_cmpl_rpt_pkg;

/
