--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_ASSET_DT_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_ASSET_DT_RPT_PKG" as
/*$Header: iscmaintadtrptb.pls 120.1 2005/09/13 05:36:55 nbhamidi noship $ */


function get_fact_mv_name
( p_report_type   in varchar2
, p_param         in bis_pmv_page_parameter_tbl
, p_dim_bmap      in number
, p_custom_output in out nocopy bis_query_attributes_tbl
)
return varchar2
is

    l_org_id  varchar2(200);
    l_view_by varchar2(200);
    tmp1      varchar2(2000);

    begin
        l_org_id := isc_maint_rpt_util_pkg.get_parameter_id
        ( p_param, isc_maint_rpt_util_pkg.G_ORGANIZATION);

    if p_report_type = 'ASSET_DOWNTIME_REPORT' then
        l_view_by := isc_maint_rpt_util_pkg.get_parameter_value
        ( p_param , 'VIEW_BY');

    isc_maint_rpt_util_pkg.bind_group_id
        ( p_dim_bmap
	    , p_custom_output
        , isc_maint_rpt_util_pkg.G_ASSET_GROUP
	    , isc_maint_rpt_util_pkg.G_ASSET_NUMBER
    --	, isc_maint_rpt_util_pkg.G_ASSET_CRITICALITY
        , isc_maint_rpt_util_pkg.G_DEPARTMENT
	    , isc_maint_rpt_util_pkg.G_ASSET_CATEGORY
	    );


    return  '(select
            time_id
            , period_type_id
            , grp_id
    	    , ' ||
            case l_view_by /* replaced asset_number with instance_id */
	        when isc_maint_rpt_util_pkg.G_DEPARTMENT then 'decode(department_id,-1,-1,organization_id) organization_id'
	        when isc_maint_rpt_util_pkg.G_ASSET_GROUP then 'decode(asset_group_id,-1,-1,organization_id) organization_id'
	        when isc_maint_rpt_util_pkg.G_ASSET_NUMBER then 'decode(instance_id,-1,-1,organization_id) organization_id'
	        when isc_maint_rpt_util_pkg.G_ASSET_CATEGORY then 'decode(category_id,-1,-1,organization_id) organization_id'
	        else 'organization_id'
            end ||'
            ,asset_group_id
            ,instance_id /* replaced asset_number with instance_id */
            ,organization_id organization_id_c
            ,category_id
            ,to_char(department_id) department_id
            ,asset_group_id  asset_group_id_c /* removed concatenation to org. to make asset group independent of org. */
            ,decode(instance_id,-1,-1,instance_id) instance_id_c /* replaced asset_number with instance_id */
            ,decode(department_id,-1,''-1'',department_id||''-1'') department_id_c
            ,asset_criticality_code
            ,dt_non_overlap_hrs
            from isc_maint_001_mv fact' || '
            where fact.grp_id = &ISC_GRP_ID ' ||
            case
            when l_org_id is null then
        	'
        	and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'fact', l_org_id )
        	end || '
            )';

	else
            return '( select
                    fact.organization_id            organization_id
                    ,fact.asset_group_id            asset_group_id
                    ,fact.instance_id               instance_id /* replace asset_number with instance_id */
                    ,fact.category_id               category_id
                    ,fact.asset_criticality_code    asset_criticality_code
                    ,fact.organization_id           organization_id_c
                    ,to_char(fact.department_id)    department_id
                    ,fact.asset_group_id	    asset_group_id_c /* removed concatenation to org. to make it independent of org. */
                    ,decode(fact.instance_id,-1,-1,fact.instance_id)
                                                    instance_id_c /* replaced asset_number with instance_id */
                    ,fact.department_id||''-1''     department_id_c
                    ,fact.start_date                start_date
                    ,fact.end_date                  end_date
                    ,24*(fact.end_date - fact.start_date)
                                                    dt_overlap_hrs
                    ,w.wip_entity_name              work_order_name
		    ,fact.work_order_id		    work_order_id
                    ,fact.description               description
                    ,fact.operation_seq_number      operation_seq_number
                    from
                    isc_maint_asset_down_f fact
                    ,wip_entities w
                    where
                    w.wip_entity_id(+) = fact.WORK_ORDER_ID and
                    fact.start_date < &BIS_CURRENT_ASOF_DATE+1 and
                    fact.end_date >= &BIS_CURRENT_EFFECTIVE_START_DATE ' ||
                    case
                    when l_org_id is null then
                    'and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'fact', l_org_id )
                    end || '
                    ) ';

    end if ;

end get_fact_mv_name;


procedure get_tbl_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
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
    l_drill_down       varchar2(1000);
    l_drill_across     varchar2 (1000);
    l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_custom_output    bis_query_attributes_tbl;
    l_cost_element     varchar2(200);
    l_curr_suffix      varchar2(2);
    l_viewby_select varchar2(200);
    l_asset_grp_column varchar2(200);
    l_criticality_column varchar2(1000);
    l_inner_query      varchar2(5000);

BEGIN

	  -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
    l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

----  view by dimensions that can be possible except org and dept ie register them -----

    isc_maint_rpt_util_pkg.register_dimension_levels
	( l_dimension_tbl
	, l_dim_filter_map
	, isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
	, isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
	, isc_maint_rpt_util_pkg.G_ASSET_CATEGORY, 'Y'
	, isc_maint_rpt_util_pkg.G_ASSET_CRITICALITY, 'Y'
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
	          ( 'ASSET_DOWNTIME_REPORT'
	          , p_param
	          , l_dim_bmap
	          , l_custom_output
	          );


    poa_dbi_util_pkg.add_column
                 (l_col_tbl,'dt_non_overlap_hrs','dt_non_overlap_hrs');


	/* check for view if asset_number add criticality and asset_group and drill across link
	 if asset_group then add drill down link only
	 else nullify all */

	if(isc_maint_rpt_util_pkg.get_parameter_id(p_param,'VIEW_BY')) = isc_maint_rpt_util_pkg.G_ASSET_NUMBER
	then
		l_asset_grp_column := isc_maint_rpt_util_pkg.add_asset_group_column(isc_maint_rpt_util_pkg.G_ASSET_NUMBER,l_dimension_tbl);
		l_criticality_column := isc_maint_rpt_util_pkg.add_view_by(isc_maint_rpt_util_pkg.G_ASSET_CRITICALITY, l_dimension_tbl,l_join_tbl);
		l_drill_across := ' ''pFunctionName=ISC_MAINT_ASSET_DT_RPT_REP'' ||
	        ''&VIEW_BY_NAME=VIEW_BY_ID'' ||''&pParamIds=Y'' ' ;
		l_drill_down := 'NULL';
	else
		if(isc_maint_rpt_util_pkg.get_parameter_id(p_param,'VIEW_BY')=isc_maint_rpt_util_pkg.G_ASSET_GROUP)
		then
			l_asset_grp_column :='NULL';
			l_criticality_column := 'NULL';
		        l_drill_across := 'NULL';
			l_drill_down  :=  '''pFunctionName=ISC_MAINT_ASSET_DT_TBL_REP'' ||
		        ''&VIEW_BY_NAME=VIEW_BY_ID'' ||
		        ''&VIEW_BY=BIV_MAINT_ASSET+BIV_MAINT_ASSET_NUMBER_LVL'' ||
		        ''&pParamIds=Y'' ';
		else
			l_asset_grp_column :='NULL';
			l_criticality_column := 'NULL';
		        l_drill_across := 'NULL';
			l_drill_down  := 'NULL';
		end if;

	end if ;


/* to enable windowing we are using an addition inline view */
l_stmt := ' select ' || l_viewby_select ||
	   ', biv_measure1
            , biv_measure2
	    , biv_measure3
	    , biv_measure13
	    , biv_measure14
	    , biv_measure15 , ' ||
             l_asset_grp_column || ' BIV_MEASURE16 ,' ||
	     l_criticality_column || ' BIV_MEASURE20 , ' ||
	     l_drill_across || ' BIV_Attribute1 , '||
	     l_drill_down  ||  ' BIV_Attribute2 ' ;



/* calculate the rank on the sorting column in the inline view */
l_inner_query := 'from ( select row_number() over(&ORDER_BY_CLAUSE nulls last )-1 rnk,iset.*'||
                 ' from ( select nvl(oset05.p_dt_non_overlap_hrs,0)           BIV_MEASURE1
        ,nvl(oset05.c_dt_non_overlap_hrs,0)           BIV_MEASURE2, ' ||
        isc_maint_rpt_util_pkg.change_column('nvl(oset05.c_dt_non_overlap_hrs,0)',
	'nvl(oset05.p_dt_non_overlap_hrs,0)','BIV_MEASURE3','X') || '
        ,nvl(oset05.c_dt_non_overlap_hrs_total,0)     BIV_MEASURE13, ' ||
	isc_maint_rpt_util_pkg.change_column('nvl(oset05.c_dt_non_overlap_hrs_total,0)',
	'nvl(oset05.p_dt_non_overlap_hrs_total,0)','BIV_MEASURE14','X') || '
	,nvl(oset05.p_dt_non_overlap_hrs_total,0) BIV_MEASURE15,'||
	 isc_maint_rpt_util_pkg.get_inner_select_col(l_join_tbl) || ' from ';



l_stmt := l_stmt || l_inner_query;
l_stmt := l_stmt || poa_dbi_template_pkg.status_sql
	        ( p_fact_name            => l_mv
	        , p_where_clause         => l_where_clause
	        , p_join_tables          => l_join_tbl
	        , p_use_windowing        => 'Y'
	        , p_col_name             => l_col_tbl
	        , p_use_grpid            => 'N'
	        , p_paren_count          => 2
	        , p_filter_where         => '1=1)iset'
	        , p_generate_viewby      => 'Y'
	        );

x_custom_output := l_custom_output;
x_custom_sql    := l_stmt;


end get_tbl_sql;
-----start of  detailed report ------------------------------------------

procedure get_asset_dt_dtl_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
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
    l_order_by         varchar2(200);
    l_asc_desc         varchar2(100);
    l_custom_output    bis_query_attributes_tbl;
    l_rank_order       varchar2(100);
    l_cost_element     varchar2(200);
    l_curr_suffix      varchar2(2);
    l_detail_col_tbl isc_maint_rpt_util_pkg.t_detail_column_tbl;
    l_viewby_select varchar2(200);
BEGIN

		-- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
    l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

    isc_maint_rpt_util_pkg.register_dimension_levels
	  ( l_dimension_tbl
	  , l_dim_filter_map
	  , isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
	  , isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
	  , isc_maint_rpt_util_pkg.G_ASSET_CATEGORY, 'Y'
	  , isc_maint_rpt_util_pkg.G_ASSET_CRITICALITY, 'Y'
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
		        ( 'ASSET_DOWNTIME_DTL_REPORT'
		        , p_param
		        , l_dim_bmap
		        , l_custom_output
		        );
    l_order_by := isc_maint_rpt_util_pkg.get_parameter_value
                ( p_param
                , 'ORDERBY'
                );
    if l_order_by like '%DESC%' then
      l_asc_desc := ' desc ';
    else
      l_asc_desc := ' asc ';
    end if;

    l_rank_order := 'order by ' ||
                    case when l_order_by like '%BIV_MEASURE3%'
                    then
                    'START_DATE '
                    when l_order_by like '%BIV_MEASURE13%'
                    then
                    'END_DATE'
                    else
                    'dt_overlap_hrs'
                    end || l_asc_desc ;

/* added organization_id since making asset_group independent of org. the org_id is
 not getting propogated which is required as a parameter in the hyperlink to the
 work order */

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_ORGANIZATION
		, p_column_key         => 'organization_id'
		);


    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_ASSET_NUMBER
		, p_column_key         => 'instance_id'
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
		, p_fact_col_name      => 'START_DATE'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'START_DATE'
		);

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'END_DATE'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'END_DATE'
		);

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'WORK_ORDER_ID'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'WORK_ORDER_ID'
		);

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'WORK_ORDER_NAME'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'WORK_ORDER_NAME'
		);

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'OPERATION_SEQ_NUMBER'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'OPERATION'
		);

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'DESCRIPTION'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'DESCRIPTION'
		);

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'dt_overlap_hrs'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'dt_overlap_hrs'
		);


    l_stmt := 'select
		' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'instance_id','BIV_MEASURE1') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'asset_group','BIV_MEASURE2') || '
		, oset.START_DATE				BIV_MEASURE3
		, oset.END_DATE					BIV_MEASURE13
		, oset.dt_overlap_hrs				BIV_MEASURE14
		, oset.WORK_ORDER_NAME            		BIV_MEASURE15
		, oset.OPERATION				BIV_MEASURE16
		, oset.DESCRIPTION				BIV_MEASURE17 ,
		case when oset.work_order_id is null then null else '||
		 isc_maint_rpt_util_pkg.get_drill_detail(' ') ||
		' end BIV_ATTRIBUTE1 from
		' || isc_maint_rpt_util_pkg.detail_sql
		    ( p_detail_col_tbl => l_detail_col_tbl
		    , p_dimension_tbl  => l_dimension_tbl
		    , p_mv_name        => l_mv
		    , p_where_clause   => l_where_clause
		    , p_rank_order     => l_rank_order
		   , p_override_date_clause => '1 = 1 '
		    );

    x_custom_sql      := l_stmt;
    x_custom_output := l_custom_output;

end get_asset_dt_dtl_sql;

----trend query--------------------------------------------
procedure get_trd_sql
(
 p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
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
    l_viewby_select    varchar2(200);
BEGIN
  -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
    l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

    isc_maint_rpt_util_pkg.register_dimension_levels
	  ( l_dimension_tbl
	  , l_dim_filter_map
	  , isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
	  , isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
	  , isc_maint_rpt_util_pkg.G_ASSET_CATEGORY, 'Y'
	  , isc_maint_rpt_util_pkg.G_ASSET_CRITICALITY, 'Y'
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
          ( 'ASSET_DOWNTIME_REPORT'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );


    poa_dbi_util_pkg.add_column (l_col_tbl,
		                 'dt_non_overlap_hrs',
		                 'dt_non_overlap_hrs',
                                'N');

    l_stmt := 'select
           cal.name VIEWBY
         , nvl(iset.p_dt_non_overlap_hrs,0) BIV_MEASURE2
		 , nvl(iset.c_dt_non_overlap_hrs,0) BIV_MEASURE3 , ' ||
		  isc_maint_rpt_util_pkg.change_column('nvl(iset.c_dt_non_overlap_hrs,0)',
		 'nvl(iset.p_dt_non_overlap_hrs,0)','BIV_MEASURE4','X')||'
         from ' ||
		 poa_dbi_template_pkg.trend_sql
	        ( p_xtd                  => l_xtd
	        , p_comparison_type      => l_comparison_type
	        , p_fact_name            => l_mv
	        , p_where_clause         => l_where_clause
	        , p_col_name             => l_col_tbl
	        , p_use_grpid            => 'N'
	        );

    x_custom_sql     := l_stmt;
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



end isc_maint_asset_dt_rpt_pkg;

/
