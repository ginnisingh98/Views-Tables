--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_LAB_BLG_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_LAB_BLG_RPT_PKG" as
/*$Header: iscmaintlblgrptb.pls 120.1 2005/09/13 05:36:44 nbhamidi noship $ */
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




    if p_report_type = 'LAB_BLG_RPT' then

	l_view_by := isc_maint_rpt_util_pkg.get_parameter_value
            (p_param , 'VIEW_BY');
	   isc_maint_rpt_util_pkg.bind_group_id
	    ( p_dim_bmap
	    , p_custom_output
        , isc_maint_rpt_util_pkg.G_DEPARTMENT
        , isc_maint_rpt_util_pkg.G_RESOURCE
        , isc_maint_rpt_util_pkg.G_WORK_ORDER_STATUS
	    );

     return '(select
    	grp_id,'||
    case l_view_by
	        when isc_maint_rpt_util_pkg.G_DEPARTMENT then 'decode(department_id,-1,-1,organization_id) organization_id'
	        when isc_maint_rpt_util_pkg.G_RESOURCE then 'decode(resource_id,-1,-1,organization_id) organization_id'
	        else 'organization_id'
	      end ||'
	    ,user_defined_status_id /* system and user defined status id */
	    ,organization_id organization_id_c
	    ,to_char(department_id) department_id
            ,to_char(resource_id) resource_id
            ,to_char(resource_id)||''-''||to_char(department_id)||''-''||to_char(organization_id) resource_id_c
	    ,decode(department_id,-1,''-1'',department_id||''-1'') department_id_c
	    ,hours_required
            ,hours_charged
	    from isc_maint_002_mv fact' || '
     	      where fact.grp_id = &ISC_GRP_ID ' ||
	       case
	       when l_org_id is null then
	        '
	       and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'fact', l_org_id )
	       end || '
	      )';

    end if;
            return '(select
                 fact.organization_id            organization_id_c
                ,fact.organization_id            organization_id
                ,to_char(fact.department_id)     department_id
           	,decode(fact.department_id,-1,''-1'',fact.department_id||''-1'') department_id_c
                ,fact.resource_id       resource_id
                ,to_char(resource_id) ||''-''|| to_char(fact.department_id)||''-''||
                  to_char(fact.organization_id)    resource_id_c
                ,fact.user_defined_Status_id       user_defined_status_id /* system and user defined status id */
                ,fact.operation_seq_number  operation_seq_number
                ,fact.op_start_date        op_start_date
                ,fact.op_end_date          op_end_date
                ,fact.hours_required    hours_required
                ,fact.hours_charged     hours_charged
                ,fact.work_order_name   work_order_name
		,fact.work_order_id	work_order_id
                ,(fact.hours_required - fact.hours_charged ) hours_backlog
                from
                isc_maint_lab_blg_f     fact where 1=1 ' ||
                case
                when l_org_id is null then
                'and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'fact', l_org_id )
                end || '
                ) ';

    end get_fact_mv_name;



procedure get_tab_sql
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
  l_inner_query	     varchar2(1000);
  l_viewby_select varchar2(200);
BEGIN

	  -- clear out the tables.
	  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
	  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

	  isc_maint_rpt_util_pkg.register_dimension_levels
	  ( l_dimension_tbl
	  , l_dim_filter_map
	  , isc_maint_rpt_util_pkg.G_RESOURCE, 'Y'
	  , isc_maint_rpt_util_pkg.G_WORK_ORDER_STATUS, 'Y'
	   );

	  isc_maint_rpt_util_pkg.process_parameters
	  ( p_param            => p_param
	  , p_dimension_tbl    => l_dimension_tbl
	  , p_dim_filter_map   => l_dim_filter_map
	  , p_trend            => 'K'
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
	 ( 'LAB_BLG_RPT'
	   ,p_param
	   ,l_dim_bmap
	   ,l_custom_output
     );



      poa_dbi_util_pkg.add_column(l_col_tbl,
		                  'hours_required',
		                  'hours_required',
		                   p_grand_total => 'Y',
		                   p_prior_code => poa_dbi_util_pkg.NO_PRIORS,
				   p_to_date_type => 'NA');

      poa_dbi_util_pkg.add_column (l_col_tbl,
		                   'hours_charged',
		                   'hours_charged',
		                    p_grand_total => 'Y',
		                    p_prior_code => poa_dbi_util_pkg.NO_PRIORS,
		                    p_to_date_type => 'NA');

/* to enable windowing we are using an addition inline view */
     l_stmt := ' select ' || l_viewby_select ||',
      biv_measure1,
      biv_measure2,
      biv_measure3,
      biv_measure4,
      biv_measure5,
      biv_measure6,
      biv_attribute1 ';


if(isc_maint_rpt_util_pkg.get_parameter_id(p_param,'VIEW_BY') = isc_maint_rpt_util_pkg.G_RESOURCE)
    then
    l_drill_across := ', ''pFunctionName=ISC_MAINT_LAB_BLG_RPT_REP'' ||
        ''&VIEW_BY_NAME=VIEW_BY_ID'' ||''&pParamIds=Y'' BIV_ATTRIBUTE1 ' ;
else
   l_drill_across := ', null BIV_ATTRIBUTE1 ';
end if;

/* calculate the rank on the sorting column in the inline view */
l_inner_query := 'from ( select iset.*,  row_number() over(&ORDER_BY_CLAUSE nulls last )-1 rnk'||
                 ' from ( select c_hours_required BIV_MEASURE1, '||
                 ' c_hours_charged BIV_MEASURE2, ' ||
                 isc_maint_rpt_util_pkg.change_column('c_hours_required','c_hours_charged','BIV_MEASURE3','X') ||
                ', c_hours_required_total BIV_MEASURE4 , c_hours_charged_total BIV_MEASURE5 ,' ||
                 isc_maint_rpt_util_pkg.change_column('c_hours_required_total','c_hours_charged_total','BIV_MEASURE6','X')
                 ||l_drill_across ||','
                 ||isc_maint_rpt_util_pkg.get_inner_select_col(l_join_tbl)||' from ';

l_stmt := l_stmt || l_inner_query;
l_stmt := l_stmt || poa_dbi_template_pkg.status_sql
	        ( p_fact_name            => l_mv
	        , p_where_clause         => l_where_clause
	        , p_join_tables          => l_join_tbl
	        , p_use_windowing        => 'Y'
	        , p_col_name             => l_col_tbl
	       	, p_paren_count          => 2
	        , p_use_grpid            => 'N'
	        , p_filter_where         => '1=1)iset'
	        , p_generate_viewby      => 'Y'
	        );

x_custom_output := l_custom_output;
x_custom_sql      := l_stmt;

end get_tab_sql;



procedure  get_lab_blg_dtl
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

    l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
    l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

	  isc_maint_rpt_util_pkg.register_dimension_levels
	  ( l_dimension_tbl
	  , l_dim_filter_map
	  , isc_maint_rpt_util_pkg.G_WORK_ORDER_STATUS, 'Y'
	  , isc_maint_rpt_util_pkg.G_RESOURCE, 'Y'
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
		        ( 'LABOR_BACKLOG_DTL_REPORT'
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
                    case when l_order_by like '%MEASURE5%'
                    then
                    'OP_START_DATE'
                    when l_order_by like '%MEASURE6%'
                    then
                    'OP_END_DATE'
                    when l_order_by like '%MEASURE7%'
                    then
                    'hours_required'
                    when l_order_by like '%MEASURE8%'
                    then
                    'hours_charged'
                    else
                    'hours_backlog'
                    end || l_asc_desc||',work_order_id,operation_seq_number,department_id,resource_id,rowid';


    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_RESOURCE
		, p_column_key         => 'resource_id'
		);

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_dimension_level    => isc_maint_rpt_util_pkg.G_DEPARTMENT
		, p_column_key         => 'department_id'
		);

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'OP_START_DATE'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'OP_START_DATE'
		);

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'OP_END_DATE'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'OP_END_DATE'
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
		, p_fact_col_name      => 'WORK_ORDER_ID'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'WORK_ORDER_ID'
		);

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'OPERATION_SEQ_NUMBER'
		, p_fact_col_total     => 'N'
		, p_column_key         => 'OPERATION_SEQ_NUMBER'
		);



    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'hours_required'
		, p_fact_col_total     => 'Y'
		, p_column_key         => 'hours_required'
		);

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'hours_charged'
		, p_fact_col_total     => 'Y'
		, p_column_key         => 'hours_charged'
		);

    isc_maint_rpt_util_pkg.add_detail_column
		( p_detail_col_tbl     => l_detail_col_tbl
		, p_dimension_tbl      => l_dimension_tbl
		, p_fact_col_name      => 'hours_backlog'
		, p_fact_col_total     => 'Y'
		, p_column_key         => 'hours_backlog'
		);



    l_stmt := 'select
		' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'resource_id','BIV_MEASURE1') || '
		, ' || isc_maint_rpt_util_pkg.get_detail_column
		    (l_detail_col_tbl,'department_id','BIV_MEASURE2') || '
		, oset.WORK_ORDER_NAME            BIV_MEASURE3
		, oset.OPERATION_SEQ_NUMBER	  BIV_MEASURE4
		, oset.OP_START_DATE		  BIV_MEASURE5
		, oset.OP_END_DATE		  BIV_MEASURE6
		, oset.hours_required		  BIV_MEASURE7
		, oset.hours_charged		  BIV_MEASURE8
		, oset.hours_backlog		  BIV_MEASURE9
		, oset.hours_required_total	  BIV_MEASURE10
		, oset.hours_charged_total        BIV_MEASURE11 , '||
		 isc_maint_rpt_util_pkg.change_column('oset.hours_required_total','oset.hours_charged_total'
		                                    ,'BIV_MEASURE12','X') ||' , ' ||
		 isc_maint_rpt_util_pkg.get_drill_detail('BIV_ATTRIBUTE1') ||
        ' from
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

end get_lab_blg_dtl;

end  isc_maint_lab_blg_rpt_pkg;


/
