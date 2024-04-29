--------------------------------------------------------
--  DDL for Package Body ISC_DEPOT_BACKLOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DEPOT_BACKLOG_PKG" AS
--$Header: iscdepotbklgrqb.pls 120.1 2005/08/25 05:20:41 visgupta noship $

FUNCTION GET_DRILL_ACROSS (p_view_by_dim IN VARCHAR2,p_function_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION GET_BACKLOG_TBL_SEL_CLAUSE ( p_view_by_dim IN VARCHAR2
				     ,p_view_by_col IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION GET_BACKLOG_TRD_SEL_CLAUSE (p_view_by_dim IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION GET_DAYS_UNTIL_PROM_SEL_CLAUSE(  p_view_by_dim IN VARCHAR2
					, p_bucket_rec  IN bis_bucket_pub.bis_bucket_rec_type
               				,p_view_by_col IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE GET_BACKLOG_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
        l_query                 ISC_DEPOT_RPT_UTIL_PKG.g_query_typ%type;
        l_view_by               ISC_DEPOT_RPT_UTIL_PKG.g_view_by_typ%type;
        l_view_by_col           ISC_DEPOT_RPT_UTIL_PKG.g_view_by_col_typ%type;
        l_xtd                   ISC_DEPOT_RPT_UTIL_PKG.g_xtd_typ%type;
        l_comparison_type       VARCHAR2(1) ;
        l_cur_suffix            VARCHAR2(2);
        l_col_tbl               poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl              poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_where_clause          ISC_DEPOT_RPT_UTIL_PKG.g_where_clause_typ%type;
        l_mv                    ISC_DEPOT_RPT_UTIL_PKG.g_mv_typ%type;
        l_mv_set                VARCHAR2(50);
        l_aggregation_flag      NUMBER;
        l_custom_rec            BIS_QUERY_ATTRIBUTES;
	l_mv_type		VARCHAR2(10);
	l_err_stage		VARCHAR2(32767);
	l_debug_mode            VARCHAR2(1);
        l_module_name           ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type ;
	l_last_refresh_date	DATE;

BEGIN
	l_debug_mode            :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
        l_module_name           := FND_PROFILE.value('AFLOG_MODULE');
        l_comparison_type       := 'Y';
	l_last_refresh_date	:= bis_submit_requestset.get_last_refreshdate('REPORT','APPS','ISC_DEPOT_BACKLOG_TBL') ;

	-- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

	-- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG.process_parameters ( p_param            => p_param,
                                                 x_view_by          => l_view_by,
                                                 x_view_by_col_name => l_view_by_col,
                                                 x_comparison_type  => l_comparison_type,
                                                 x_xtd              => l_xtd,
                                                 x_cur_suffix       => l_cur_suffix,
                                                 x_where_clause     => l_where_clause,
                                                 x_mv               => l_mv,
                                                 x_join_tbl         => l_join_tbl,
                                                 x_mv_type          => l_mv_type,
						 x_aggregation_flag => l_aggregation_flag,
                                                 p_trend            => 'N',
                                                 p_mv_set           => 'BKLG',
                                                 x_custom_output    => x_custom_output);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DRM_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_TBL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => '(OPEN_COUNT - CLOSE_COUNT)' ,
                                     p_alias_name   => 'backlog',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'YTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => '(PAST_DUE_OPEN_COUNT - LATE_COMPLETE_COUNT)' ,
                                     p_alias_name   => 'past_due',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'YTD');



        l_query := GET_BACKLOG_TBL_SEL_CLAUSE (  p_view_by_dim => l_view_by
						,p_view_by_col => l_view_by_col)
                || ' from
              ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
                                                    p_where_clause    => l_where_clause,
                                                    p_join_tables     => l_join_tbl,
                                                    p_use_windowing   => 'Y',
                                                    p_col_name        => l_col_tbl,
                                                    p_use_grpid       => 'N',
                                                    p_paren_count     => 3,
                                                    p_filter_where    => ' (BIV_MEASURE1 > 0 or BIV_MEASURE11 > 0 or BIV_MEASURE12 > 0 or BIV_MEASURE3 > 0)',
                                                    p_generate_viewby => 'Y',
                                                    p_in_join_tables  => NULL);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : ' || l_query;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the status SQL
        poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

        -- Passing AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':AGGREGATION_FLAG';
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_value     := l_aggregation_flag;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        -- Passing AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := '&YTD_NESTED_PATTERN';
        l_custom_rec.attribute_value     := 1143;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        -- Passing last refresh date to PMV
        l_custom_rec.attribute_name     := ':LAST_REFRESH_DATE';
        l_custom_rec.attribute_value     := to_char(l_last_refresh_date,'DD/MM/YYYY');
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        x_custom_sql := l_query;

EXCEPTION

        WHEN OTHERS THEN
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:=' The exception is : ' || SQLERRM;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END get_backlog_tbl_sql;


FUNCTION GET_BACKLOG_TBL_SEL_CLAUSE( p_view_by_dim IN VARCHAR2
				    ,p_view_by_col IN VARCHAR2)
RETURN VARCHAR2
IS

        l_sel_clause                VARCHAR2(8000);
        l_view_by_col_name          VARCHAR2(120);
        l_description               VARCHAR2(30);
        l_drill_across_rep_1        VARCHAR2(500);
        l_drill_across_rep_2        VARCHAR2(500);
        l_drill_across_rep_3        VARCHAR2(500);

BEGIN

        l_description               := 'null';
        l_drill_across_rep_1        := 'null' ;
        l_drill_across_rep_2        := 'null' ;
        l_drill_across_rep_3        := 'null' ;

        -- Item Description for item view by
        l_drill_across_rep_1 := get_drill_across (p_view_by_dim => p_view_by_dim, p_function_name =>'ISC_DEPOT_BACKLOG_TBL_REP');
	l_drill_across_rep_2 := '''pFunctionName=ISC_DEPOT_BACKLOG_DTL_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y''';
	l_drill_across_rep_3 := '''pFunctionName=ISC_DEPOT_PAST_DUE_DTL_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y''';
        IF (p_view_by_dim = 'ITEM+ENI_ITEM') THEN
        l_description := ' v. description ';
        END IF;
        l_sel_clause :=
	'SELECT    '|| ISC_DEPOT_RPT_UTIL_PKG.get_viewby_select_clause (p_view_by_dim) || fnd_global.newline ||
		    l_description || ' BIV_ATTRIBUTE1
		    ,BIV_MEASURE1
		    ,BIV_MEASURE11
		    ,BIV_MEASURE2
		    ,BIV_MEASURE12
		    ,BIV_MEASURE3
		    ,BIV_MEASURE4
		    ,BIV_MEASURE13
		    ,BIV_MEASURE5
		    ,BIV_MEASURE6
		    ,BIV_MEASURE21
		    ,BIV_MEASURE22
		    ,BIV_MEASURE23
		    ,BIV_MEASURE24
		    ,BIV_MEASURE25
		    ,BIV_MEASURE26
		    ,BIV_MEASURE27
		    ,BIV_MEASURE28
		    ,BIV_MEASURE29
		    ,BIV_MEASURE30
		    ,BIV_MEASURE31
		    ,BIV_MEASURE32
		    ,BIV_MEASURE33
		    ,BIV_MEASURE34
		    , ' || l_drill_across_rep_1 || ' BIV_DYNAMIC_URL1 ' || fnd_global.newline ||
		    ',(case when :LAST_REFRESH_DATE  <= &BIS_CURRENT_ASOF_DATE THEN ' || l_drill_across_rep_2 || ' ELSE NULL END ) BIV_DYNAMIC_URL2 ' || fnd_global.newline ||
		    ',(case when :LAST_REFRESH_DATE  = &BIS_CURRENT_ASOF_DATE THEN ' || l_drill_across_rep_3 || ' ELSE NULL END ) BIV_DYNAMIC_URL3 ' || fnd_global.newline ||
        'FROM ( SELECT
		     rank() over (&ORDER_BY_CLAUSE'||' nulls last, '||p_view_by_col||' ) - 1 rnk
                    ,'||p_view_by_col||'
		    ,BIV_MEASURE1
		    ,BIV_MEASURE11
		    ,BIV_MEASURE2
		    ,BIV_MEASURE12
		    ,BIV_MEASURE3
		    ,BIV_MEASURE4
		    ,BIV_MEASURE13
		    ,BIV_MEASURE5
		    ,BIV_MEASURE6
		    ,BIV_MEASURE21
		    ,BIV_MEASURE22
		    ,BIV_MEASURE23
		    ,BIV_MEASURE24
		    ,BIV_MEASURE25
		    ,BIV_MEASURE26
		    ,BIV_MEASURE27
		    ,BIV_MEASURE28
		    ,BIV_MEASURE29
		    ,BIV_MEASURE30
		    ,BIV_MEASURE31
		    ,BIV_MEASURE32
		    ,BIV_MEASURE33
		    ,BIV_MEASURE34 ' || fnd_global.newline ||
		   ' FROM ( SELECT  '   || fnd_global.newline ||
			     p_view_by_col || fnd_global.newline ||
			 ',' || 'NVL(c_backlog,0) BIV_MEASURE1 ' || fnd_global.newline ||
			 ',' || 'NVL(p_backlog,0) BIV_MEASURE11 ' || fnd_global.newline ||
			 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_backlog'
								   ,prior_col   => 'p_backlog'
								   ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
								   || 'BIV_MEASURE2' || fnd_global.newline ||
			 ',' || 'NVL(c_past_due,0) BIV_MEASURE3 ' || fnd_global.newline ||
			 ',' || 'NVL(p_past_due,0) BIV_MEASURE12 ' || fnd_global.newline ||
			 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_past_due'
								   ,prior_col   => 'p_past_due'
								   ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
								   || 'BIV_MEASURE4' || fnd_global.newline ||
			 ',' || poa_dbi_util_pkg.rate_clause( numerator => 'c_past_due'
								 ,denominator => 'c_backlog'
								 ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
								 || 'BIV_MEASURE5' || fnd_global.newline ||
			 ',' || poa_dbi_util_pkg.rate_clause( numerator => 'p_past_due'
								 ,denominator => 'p_backlog'
								 ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
								 || 'BIV_MEASURE13' || fnd_global.newline ||
			 ',' || OPI_DBI_RPT_UTIL_PKG.change_pct_str(p_new_numerator     => 'c_past_due',
								    p_new_denominator   => 'c_backlog',
								    p_old_numerator     => 'p_past_due',
								    p_old_denominator   => 'p_backlog',
								    p_measure_name      => 'BIV_MEASURE6')
								   || fnd_global.newline || fnd_global.newline ||
			 ',' || 'NVL(c_backlog_total,0) BIV_MEASURE21 ' || fnd_global.newline ||
			 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_backlog_total'
								   ,prior_col   => 'p_backlog_total'
								   ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
								   || 'BIV_MEASURE22' || fnd_global.newline ||
			 ',' || 'NVL(c_past_due_total,0) BIV_MEASURE23 ' || fnd_global.newline ||
			 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_past_due_total'
								   ,prior_col   => 'p_past_due_total'
								   ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
								   || 'BIV_MEASURE24' || fnd_global.newline ||
			 ',' || poa_dbi_util_pkg.rate_clause( numerator => 'c_past_due_total'
								 ,denominator => 'c_backlog_total'
								 ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
								 || 'BIV_MEASURE25' || fnd_global.newline ||
			 ',' || OPI_DBI_RPT_UTIL_PKG.change_pct_str(p_new_numerator     => 'c_past_due_total',
								    p_new_denominator   => 'c_backlog_total',
								    p_old_numerator     => 'p_past_due_total',
								    p_old_denominator   => 'p_backlog_total',
								    p_measure_name      => 'BIV_MEASURE26')
								   || fnd_global.newline || fnd_global.newline ||
			 ',' || 'NVL(c_backlog,0) BIV_MEASURE27 ' || fnd_global.newline ||
			 ',' || 'NVL(p_backlog,0) BIV_MEASURE28 ' || fnd_global.newline ||
			 ',' || 'NVL(c_backlog_total,0) BIV_MEASURE29 ' || fnd_global.newline ||
			 ',' || 'NVL(p_backlog_total,0) BIV_MEASURE30 ' || fnd_global.newline ||
			 ',' || poa_dbi_util_pkg.rate_clause( numerator => 'c_past_due'
								 ,denominator => 'c_backlog'
								 ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
								 || 'BIV_MEASURE31' || fnd_global.newline ||
			 ',' || poa_dbi_util_pkg.rate_clause( numerator => 'p_past_due'
								 ,denominator => 'p_backlog'
								 ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
								 || 'BIV_MEASURE32' || fnd_global.newline ||
			 ',' || poa_dbi_util_pkg.rate_clause( numerator => 'c_past_due_total'
								 ,denominator => 'c_backlog_total'
								 ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
								 || 'BIV_MEASURE33' || fnd_global.newline ||
			 ',' || poa_dbi_util_pkg.rate_clause( numerator => 'p_past_due_total'
								 ,denominator => 'p_backlog_total'
								 ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
								 || 'BIV_MEASURE34' || fnd_global.newline ;

RETURN l_sel_clause;

END GET_BACKLOG_TBL_SEL_CLAUSE;

PROCEDURE GET_BACKLOG_TRD_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

        l_query                 ISC_DEPOT_RPT_UTIL_PKG.g_query_typ%type;
        l_view_by               ISC_DEPOT_RPT_UTIL_PKG.g_view_by_typ%type;
        l_view_by_col           ISC_DEPOT_RPT_UTIL_PKG.g_view_by_col_typ%type;
        l_xtd                   ISC_DEPOT_RPT_UTIL_PKG.g_xtd_typ%type;
        l_comparison_type       VARCHAR2(1);
        l_cur_suffix            VARCHAR2(2);
        l_col_tbl               poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl              poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_where_clause          ISC_DEPOT_RPT_UTIL_PKG.g_where_clause_typ%type;
        l_mv                    ISC_DEPOT_RPT_UTIL_PKG.g_mv_typ%type;
        l_mv_set                VARCHAR2(50);
        l_aggregation_flag      NUMBER;
        l_custom_rec            BIS_QUERY_ATTRIBUTES;
	l_mv_type		VARCHAR2(10);
	l_err_stage		VARCHAR2(32767);
	l_debug_mode            VARCHAR2(1);
        l_module_name           ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type ;

BEGIN
	l_debug_mode            :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
        l_module_name           := FND_PROFILE.value('AFLOG_MODULE');
        l_comparison_type       := 'Y';

        -- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG.process_parameters (p_param            => p_param,
                                                 x_view_by          => l_view_by,
                                                 x_view_by_col_name => l_view_by_col,
                                                 x_comparison_type  => l_comparison_type,
                                                 x_xtd              => l_xtd,
                                                 x_cur_suffix       => l_cur_suffix,
                                                 x_where_clause     => l_where_clause,
                                                 x_mv               => l_mv,
                                                 x_join_tbl         => l_join_tbl,
                                                 x_mv_type          => l_mv_type,
						 x_aggregation_flag => l_aggregation_flag,
                                                 p_trend            => 'Y',
                                                 p_mv_set           => 'BKLG',
                                                 x_custom_output    => x_custom_output);


        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DRM_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_TRD : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => '(OPEN_COUNT - CLOSE_COUNT)' ,
                                     p_alias_name   => 'backlog',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'YTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => '(PAST_DUE_OPEN_COUNT - LATE_COMPLETE_COUNT)' ,
                                     p_alias_name   => 'past_due',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'YTD');

        l_query := GET_BACKLOG_TRD_SEL_CLAUSE (l_view_by)
                || ' from
              ' || poa_dbi_template_pkg.trend_sql(p_xtd                 => l_xtd,
                                                  p_comparison_type     => l_comparison_type,
                                                  p_fact_name           => l_mv,
                                                  p_where_clause        => l_where_clause,
                                                  p_col_name            => l_col_tbl,
                                                  p_use_grpid           => 'N',
                                                  p_in_join_tables      => NULL);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : ' || l_query;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the status SQL
    	poa_dbi_util_pkg.get_custom_trend_binds (p_xtd => l_xtd,
    					         p_comparison_type => l_comparison_type,
                                                 x_custom_output => x_custom_output);

        -- Passing AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':AGGREGATION_FLAG';
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_value     := l_aggregation_flag;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        -- Passing AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := '&YTD_NESTED_PATTERN';
        l_custom_rec.attribute_value     := 1143;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        x_custom_sql := l_query;
EXCEPTION

        WHEN OTHERS THEN
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:= 'The exception is : ' || SQLERRM;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_TRD : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END GET_BACKLOG_TRD_SQL;

FUNCTION GET_BACKLOG_TRD_SEL_CLAUSE(p_view_by_dim IN VARCHAR2)
    RETURN VARCHAR2
IS

        l_sel_clause                VARCHAR2(8000);
        l_view_by_col_name          VARCHAR2(120);
        l_description               VARCHAR2(30);
        l_drill_across_rep_1        VARCHAR2(50);

BEGIN
        l_description               := 'null';
        l_drill_across_rep_1        := 'null' ;

	l_sel_clause :=
        'SELECT  cal.name VIEWBY ' || fnd_global.newline ||
		 ',' || 'NVL(iset.c_backlog,0) BIV_MEASURE1 ' || fnd_global.newline ||
                 ',' || 'NVL(iset.p_backlog,0) BIV_MEASURE11 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_backlog'
                                                           ,prior_col   => 'p_backlog'
                                                           ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                           || 'BIV_MEASURE2' || fnd_global.newline ||
                 ',' || 'NVL(iset.c_past_due,0) BIV_MEASURE3 ' || fnd_global.newline ||
                 ',' || 'NVL(iset.p_past_due,0) BIV_MEASURE12 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_past_due'
                                                           ,prior_col   => 'p_past_due'
                                                           ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                           || 'BIV_MEASURE4' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause( numerator => 'c_past_due'
                                                         ,denominator => 'c_backlog'
                                                         ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                         || 'BIV_MEASURE5' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause( numerator => 'p_past_due'
                                                         ,denominator => 'p_backlog'
                                                         ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                         || 'BIV_MEASURE13' || fnd_global.newline ||
                 ',' || OPI_DBI_RPT_UTIL_PKG.change_pct_str(p_new_numerator     => 'c_past_due',
                                                            p_new_denominator   => 'c_backlog',
                                                            p_old_numerator     => 'p_past_due',
                                                            p_old_denominator   => 'p_backlog',
                                                            p_measure_name      => 'BIV_MEASURE6')
                                                           || fnd_global.newline;


RETURN l_sel_clause;

END GET_BACKLOG_TRD_SEL_CLAUSE;

PROCEDURE GET_BACKLOG_DTL_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
				  x_custom_sql OUT NOCOPY VARCHAR2,
				  x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

        l_query                 ISC_DEPOT_RPT_UTIL_PKG.g_query_typ%type;
        l_view_by               ISC_DEPOT_RPT_UTIL_PKG.g_view_by_typ%type;
        l_view_by_col           ISC_DEPOT_RPT_UTIL_PKG.g_view_by_col_typ%type;
        l_xtd                   ISC_DEPOT_RPT_UTIL_PKG.g_xtd_typ%type;
        l_comparison_type       VARCHAR2(1);
        l_cur_suffix            VARCHAR2(1);
        l_col_tbl               poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl              poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_where_clause          ISC_DEPOT_RPT_UTIL_PKG.g_where_clause_typ%type;
        l_mv                    ISC_DEPOT_RPT_UTIL_PKG.g_mv_typ%type;
        l_mv_set                VARCHAR2(50);
        l_aggregation_flag      NUMBER;
        l_custom_rec            BIS_QUERY_ATTRIBUTES;
	l_mv_type		VARCHAR2(10);
	l_err_stage		VARCHAR2(32767);
	l_debug_mode            VARCHAR2(1);
        l_module_name           ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type ;

BEGIN
	l_debug_mode            :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
        l_module_name           := FND_PROFILE.value('AFLOG_MODULE');

        -- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG.process_parameters (p_param            => p_param,
                                                 x_view_by          => l_view_by,
                                                 x_view_by_col_name => l_view_by_col,
                                                 x_comparison_type  => l_comparison_type,
                                                 x_xtd              => l_xtd,
                                                 x_cur_suffix       => l_cur_suffix,
                                                 x_where_clause     => l_where_clause,
                                                 x_mv               => l_mv,
                                                 x_join_tbl         => l_join_tbl,
                                                 x_mv_type          => l_mv_type,
						 x_aggregation_flag => l_aggregation_flag,
                                                 p_trend            => 'Y',
                                                 p_mv_set           => 'BKLDTL1',
                                                 x_custom_output    => x_custom_output);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DRM_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_DTL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        l_query :=
        'SELECT
		 BIV_ATTRIBUTE1
		,BIV_ATTRIBUTE2
		,BIV_ATTRIBUTE3
		,BIV_ATTRIBUTE4
		,BIV_ATTRIBUTE5
		,BIV_ATTRIBUTE6
		,BIV_MEASURE1
		,BIV_ATTRIBUTE7
		,BIV_ATTRIBUTE8
		,BIV_ATTRIBUTE9
		,BIV_DATE1
		,BIV_MEASURE2
		,BIV_MEASURE3
		,''pFunctionName=CSD_RO_DETAILS&csdInvOrgId=''||BIV_MEASURE3||''&csdRepairLineId=''||BIV_MEASURE2 BIV_DYNAMIC_URL1
		,' || ISC_DEPOT_RPT_UTIL_PKG.get_service_request_url || ' || BIV_ATTRIBUTE9 BIV_DYNAMIC_URL2
	 FROM (
		SELECT
		     rank() over (&ORDER_BY_CLAUSE nulls last,BIV_ATTRIBUTE1) - 1 rnk
			,BIV_ATTRIBUTE1
			,BIV_ATTRIBUTE2
			,BIV_ATTRIBUTE3
			,BIV_ATTRIBUTE4
			,BIV_ATTRIBUTE5
			,BIV_ATTRIBUTE6
			,BIV_MEASURE1
			,BIV_ATTRIBUTE7
			,BIV_ATTRIBUTE8
			,BIV_ATTRIBUTE9
			,BIV_DATE1
			,BIV_MEASURE2
			,BIV_MEASURE3
		FROM (
			SELECT  repair_number BIV_ATTRIBUTE1 ' || fnd_global.newline ||
				 ',' || ' incident_number BIV_ATTRIBUTE2 ' || fnd_global.newline ||
				 ',' || ' crt.name BIV_ATTRIBUTE3 ' || fnd_global.newline ||
				 ',' || ' eiov.value BIV_ATTRIBUTE4 ' || fnd_global.newline ||
				 ',' || ' eiov.description BIV_ATTRIBUTE5 ' || fnd_global.newline ||
				 ',' || ' mum.unit_of_measure BIV_ATTRIBUTE6 ' || fnd_global.newline ||
				 ',' || ' quantity BIV_MEASURE1 ' || fnd_global.newline ||
        	        	 ',' || ' fact.repair_line_id  BIV_MEASURE2 ' || fnd_global.newline ||
        	         	 ',' || ' fact.master_organization_id BIV_MEASURE3 ' || fnd_global.newline ||
				 ',' || ' serial_number BIV_ATTRIBUTE7 ' || fnd_global.newline ||
				 ',' || ' fl.meaning BIV_ATTRIBUTE8 ' || fnd_global.newline ||
				 ',' || ' incident_id BIV_ATTRIBUTE9 '|| fnd_global.newline ||
				 ',' || ' promise_date BIV_DATE1 ' || fnd_global.newline
				     || ' from ' || fnd_global.newline
				     || l_mv
				     || ' ISC_DR_CURR_01_MV fact, ' || fnd_global.newline
				     || ' ENI_ITEM_V EIOV, ' || fnd_global.newline
				     || ' CSD_FLOW_STATUSES_B CFSB, ' || fnd_global.newline
				     || ' FND_LOOKUPS FL, ' || fnd_global.newline
				     || ' MTL_UNITS_OF_MEASURE_VL MUM ' || fnd_global.newline
                     -- Mapped fact.flow_status_id to CFSB table which will be mapped to FND_LOOKUPS
				     || ' WHERE FL.LOOKUP_TYPE = ''CSD_REPAIR_FLOW_STATUS'' ' || fnd_global.newline
				     || ' AND FL.LOOKUP_CODE = CFSB.flow_status_code ' || fnd_global.newline
				     || ' AND CFSB.flow_status_id = fact.flow_status_id ' || fnd_global.newline
				     || ' AND FACT.item_org_id = eiov.id ' || fnd_global.newline
				     || ' AND mum.uom_code = fact.uom_code '|| fnd_global.newline
				     || l_where_clause
		|| ' ) ) where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
			ORDER BY rnk' || fnd_global.newline ;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : ' || l_query;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_DTL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        x_custom_sql := l_query;
EXCEPTION

        WHEN OTHERS THEN
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ' || SQLERRM;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_DTL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END get_backlog_dtl_tbl_sql;

PROCEDURE GET_PAST_DUE_AGNG_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
				    x_custom_sql OUT NOCOPY VARCHAR2,
				    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

        l_query                 ISC_DEPOT_RPT_UTIL_PKG.g_query_typ%type;
        l_view_by               ISC_DEPOT_RPT_UTIL_PKG.g_view_by_typ%type;
        l_view_by_col           ISC_DEPOT_RPT_UTIL_PKG.g_view_by_col_typ%type;
        l_xtd                   ISC_DEPOT_RPT_UTIL_PKG.g_xtd_typ%type;
        l_comparison_type       VARCHAR2(1);
        l_cur_suffix            VARCHAR2(1);
        l_col_tbl               poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl              poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_where_clause          ISC_DEPOT_RPT_UTIL_PKG.g_where_clause_typ%type;
        l_mv                    ISC_DEPOT_RPT_UTIL_PKG.g_mv_typ%type;
        l_mv_set                VARCHAR2(50);
        l_aggregation_flag      NUMBER;
        l_custom_rec            BIS_QUERY_ATTRIBUTES;
	l_mv_type		VARCHAR2(10);
	l_err_stage		VARCHAR2(32767);
	l_debug_mode            VARCHAR2(1);
        l_module_name           ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type ;

BEGIN
	l_debug_mode            :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
        l_module_name           := FND_PROFILE.value('AFLOG_MODULE');

        -- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='get past due aging report calling process parameters';
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_DTL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        -- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG.process_parameters (p_param            => p_param,
                                                 x_view_by          => l_view_by,
                                                 x_view_by_col_name => l_view_by_col,
                                                 x_comparison_type  => l_comparison_type,
                                                 x_xtd              => l_xtd,
                                                 x_cur_suffix       => l_cur_suffix,
                                                 x_where_clause     => l_where_clause,
                                                 x_mv               => l_mv,
                                                 x_join_tbl         => l_join_tbl,
                                                 x_mv_type          => l_mv_type,
						 x_aggregation_flag => l_aggregation_flag,
                                                 p_trend            => 'N',
                                                 p_mv_set           => 'BKLAGN1',
                                                 x_custom_output    => x_custom_output);


        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DRM_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_DTL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        l_query :=
                ' SELECT range_name BIV_ATTRIBUTE1 '  || fnd_global.newline ||
		'       ,nvl(past_due_count,0)  BIV_MEASURE1 ' || fnd_global.newline ||
                '       ,' || poa_dbi_util_pkg.rate_clause(numerator => 'past_due_count'
                                                          ,denominator => 'past_due_count_total'
                                                          ,rate_type  =>  'P') || ' BIV_MEASURE2' || fnd_global.newline ||
		'       ,nvl(past_due_count_total,0) BIV_MEASURE21 ' || fnd_global.newline ||
                '       ,' || poa_dbi_util_pkg.rate_clause(numerator   => 'past_due_count_total'
                                                          ,denominator => 'past_due_count_total'
                                                          ,rate_type   => 'P') || ' BIV_MEASURE22' || fnd_global.newline ||
                '       ,' || '''pFunctionName=ISC_DEPOT_PAST_DUE_DTL_TBL_REP&pParamIds=Y&BIV_ATTRIBUTE1=-1&BIV_DR_BACKLOG_BUCKET+BIV_DR_BACKLOG_BUCKET=''|| bucket_number ||''''' || ' BIV_ATTRIBUTE10' ||

		'  FROM (' || fnd_global.newline ||
		'	 SELECT  range_name ' || fnd_global.newline ||
		'		,bucket_number ' || fnd_global.newline ||
		'	        ,sum (decode (buckets.bucket_number, 1, past_due_age_b1 ' || fnd_global.newline ||
		'	                                           ,2, past_due_age_b2 ' || fnd_global.newline ||
		'	                                           ,3, past_due_age_b3 ' || fnd_global.newline ||
		'	                                           ,4, past_due_age_b4 ' || fnd_global.newline ||
		'	                                           ,5, past_due_age_b5 ' || fnd_global.newline ||
		'	                                           ,6, past_due_age_b6 ' || fnd_global.newline ||
		'	                                           ,7, past_due_age_b7 ' || fnd_global.newline ||
		'	                                           ,8, past_due_age_b8 ' || fnd_global.newline ||
  		'	                                           ,9, past_due_age_b9 ' || fnd_global.newline ||
		'	                                           ,10, past_due_age_b10 ) ) past_due_count '  || fnd_global.newline ||
       		'              ,sum(sum(decode (buckets.bucket_number, 1, past_due_age_b1 ' || fnd_global.newline ||
                '         		     		              ,2, past_due_age_b2 ' || fnd_global.newline ||
		'			     		              ,3, past_due_age_b3 ' || fnd_global.newline ||
		'			     		              ,4, past_due_age_b4 ' || fnd_global.newline ||
		'			     		              ,5, past_due_age_b5 ' || fnd_global.newline ||
		'			     		              ,6, past_due_age_b6 ' || fnd_global.newline ||
		'			     		              ,7, past_due_age_b7 ' || fnd_global.newline ||
		'			     		              ,8, past_due_age_b8 ' || fnd_global.newline ||
		'			     		              ,9, past_due_age_b9 ' || fnd_global.newline ||
		'			     		              ,10, past_due_age_b10 ) ) ) over () past_due_count_total '  || fnd_global.newline ||
                ' from ' || fnd_global.newline ||
                  l_mv || fnd_global.newline ||
                ' ISC_DR_CURR_02_MV fact, ' || fnd_global.newline ||
                ' (';

        FOR i in 1..10 LOOP
                l_query := l_query ||
                   'SELECT '|| i || ' bucket_number, ' || fnd_global.newline ||
                   '        bbct.range'|| i ||'_name range_name, ' || fnd_global.newline ||
                   '        bbc.range' || i || '_low range_low, '  || fnd_global.newline ||
                   '        bbc.range' || i || '_high  range_high ' || fnd_global.newline ||
                   'FROM    bis_bucket_customizations bbc, ' || fnd_global.newline ||
                   '        bis_bucket bb, ' || fnd_global.newline ||
                   '        bis_bucket_customizations_tl bbct ' || fnd_global.newline ||
                   'WHERE   short_name = ''ISC_DEPOT_BKLG_CMP_AGING'' ' || fnd_global.newline ||
                   '  and   bb.bucket_id = bbc.bucket_id ' || fnd_global.newline ||
                   '  and   nvl(bbc.range' || i || '_low,bbc.range' || i || '_high) is not null' || fnd_global.newline ||
                   '  and   bbct.language =USERENV(''LANG'') ' || fnd_global.newline ||
                   '  and   bbC.id = bbct.id '|| fnd_global.newline;
                IF i <> 10 THEN
                         l_query := l_query || 'UNION ALL ' || fnd_global.newline;
                ELSE
                         l_query := l_query || ') buckets ' || fnd_global.newline;
                END IF;
        END LOOP;

	IF (l_where_clause is NOT NULL ) THEN
	l_query := l_query || ' where 1=1 ' || l_where_clause;
	END IF;

	l_query := l_query || ' group by range_name,bucket_number order by bucket_number ) ';

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : ' || l_query;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_DTL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;
        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the status SQL
        poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

        -- Passing AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':AGGREGATION_FLAG';
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_value     := l_aggregation_flag;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;


        x_custom_sql := l_query;
EXCEPTION

        WHEN OTHERS THEN
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ' || SQLERRM;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_DTL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END GET_PAST_DUE_AGNG_TBL_SQL;

PROCEDURE GET_PAST_DUE_DTL_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
				  x_custom_sql OUT NOCOPY VARCHAR2,
				  x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

        l_query                 ISC_DEPOT_RPT_UTIL_PKG.g_query_typ%type;
        l_view_by               ISC_DEPOT_RPT_UTIL_PKG.g_view_by_typ%type;
        l_view_by_col           ISC_DEPOT_RPT_UTIL_PKG.g_view_by_col_typ%type;
        l_xtd                   ISC_DEPOT_RPT_UTIL_PKG.g_xtd_typ%type;
        l_comparison_type       VARCHAR2(1);
        l_cur_suffix            VARCHAR2(1);
        l_col_tbl               poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl              poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_where_clause          ISC_DEPOT_RPT_UTIL_PKG.g_where_clause_typ%type;
        l_mv                    ISC_DEPOT_RPT_UTIL_PKG.g_mv_typ%type;
        l_mv_set                VARCHAR2(50);
        l_aggregation_flag      NUMBER;
        l_custom_rec            BIS_QUERY_ATTRIBUTES;
	l_mv_type		VARCHAR2(10);
	l_err_stage		VARCHAR2(32767);
	l_debug_mode            VARCHAR2(1);
        l_module_name           ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type ;

BEGIN
	l_debug_mode            :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
        l_module_name           := FND_PROFILE.value('AFLOG_MODULE');

        -- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG.process_parameters (p_param            => p_param,
                                                 x_view_by          => l_view_by,
                                                 x_view_by_col_name => l_view_by_col,
                                                 x_comparison_type  => l_comparison_type,
                                                 x_xtd              => l_xtd,
                                                 x_cur_suffix       => l_cur_suffix,
                                                 x_where_clause     => l_where_clause,
                                                 x_mv               => l_mv,
                                                 x_join_tbl         => l_join_tbl,
                                                 x_mv_type          => l_mv_type,
						 x_aggregation_flag => l_aggregation_flag,
                                                 p_trend            => 'Y',
                                                 p_mv_set           => 'BKLDTL2',
                                                 x_custom_output    => x_custom_output);


        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DRM_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_DTL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        l_query :=
        'SELECT
		 BIV_ATTRIBUTE1
		,BIV_ATTRIBUTE2
		,BIV_ATTRIBUTE3
		,BIV_ATTRIBUTE4
		,BIV_ATTRIBUTE5
		,BIV_ATTRIBUTE6
		,BIV_MEASURE1
		,BIV_ATTRIBUTE7
		,BIV_ATTRIBUTE8
		,BIV_ATTRIBUTE9
		,BIV_DATE1
		,BIV_MEASURE2
		,BIV_MEASURE3
		,BIV_MEASURE4
		,''pFunctionName=CSD_RO_DETAILS&csdInvOrgId=''||BIV_MEASURE4||''&csdRepairLineId=''||BIV_MEASURE3 BIV_DYNAMIC_URL1
		,' || ISC_DEPOT_RPT_UTIL_PKG.get_service_request_url || ' || BIV_ATTRIBUTE9 BIV_DYNAMIC_URL2
	 FROM (
		SELECT
			 rank() over (&ORDER_BY_CLAUSE nulls last,BIV_ATTRIBUTE1, BIV_MEASURE3) - 1 rnk
			,BIV_ATTRIBUTE1
			,BIV_ATTRIBUTE2
			,BIV_ATTRIBUTE3
			,BIV_ATTRIBUTE4
			,BIV_ATTRIBUTE5
			,BIV_ATTRIBUTE6
			,BIV_MEASURE1
			,BIV_ATTRIBUTE7
			,BIV_ATTRIBUTE8
			,BIV_ATTRIBUTE9
			,BIV_DATE1
			,BIV_MEASURE2
			,BIV_MEASURE3
			,BIV_MEASURE4
		FROM (
		SELECT  repair_number BIV_ATTRIBUTE1 ' || fnd_global.newline ||
                 ',' || ' incident_number BIV_ATTRIBUTE2 ' || fnd_global.newline ||
                 ',' || ' crt.name BIV_ATTRIBUTE3 ' || fnd_global.newline ||
                 ',' || ' eiov.value BIV_ATTRIBUTE4 ' || fnd_global.newline ||
                 ',' || ' eiov.description BIV_ATTRIBUTE5 ' || fnd_global.newline ||
        	 ',' || ' fact.repair_line_id  BIV_MEASURE3 ' || fnd_global.newline ||
        	 ',' || ' fact.master_organization_id BIV_MEASURE4 ' || fnd_global.newline ||
                 ',' || ' mum.unit_of_measure BIV_ATTRIBUTE6 ' || fnd_global.newline ||
                 ',' || ' quantity BIV_MEASURE1 ' || fnd_global.newline ||
                 ',' || ' serial_number BIV_ATTRIBUTE7 ' || fnd_global.newline ||
                 ',' || ' fl.meaning BIV_ATTRIBUTE8 ' || fnd_global.newline ||
                 ',' || ' incident_id BIV_ATTRIBUTE9 ' || fnd_global.newline ||
                 ',' || ' promise_date BIV_DATE1 ' || fnd_global.newline ||
                 ',' || ' PAST_DUE_DAYS BIV_MEASURE2 ' || fnd_global.newline
                     || ' from ' || fnd_global.newline
                     || l_mv || fnd_global.newline
                     || ' ISC_DR_CURR_01_MV fact, ' || fnd_global.newline
                     || ' ENI_ITEM_V EIOV, ' || fnd_global.newline
                     || ' CSD_FLOW_STATUSES_B CFSB, ' || fnd_global.newline
                     || ' FND_LOOKUPS FL, ' || fnd_global.newline
                     || ' MTL_UNITS_OF_MEASURE_VL MUM ' || fnd_global.newline
                     -- Mapped fact.flow_status_id to CFSB table which will be mapped to FND_LOOKUPS
                     || ' WHERE FL.LOOKUP_TYPE = ''CSD_REPAIR_FLOW_STATUS'' ' || fnd_global.newline
                     || ' AND CFSB.flow_status_id = fact.flow_status_id ' || fnd_global.newline
                     || ' AND FL.LOOKUP_CODE = CFSB.flow_status_code ' || fnd_global.newline
                     || ' AND FACT.item_org_id = eiov.id ' || fnd_global.newline
                     || ' AND FACT.past_due_flag = ''Y'' ' || fnd_global.newline
                     || ' AND mum.uom_code = fact.uom_code '
		     || l_where_clause
		     || ' ) ) where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
			ORDER BY rnk' || fnd_global.newline ;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : ' || l_query;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_DTL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        x_custom_sql := l_query;
EXCEPTION

        WHEN OTHERS THEN
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ' || SQLERRM;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_DTL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END GET_PAST_DUE_DTL_TBL_SQL;

PROCEDURE GET_DAYS_UNTIL_PROM_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
        l_query                 ISC_DEPOT_RPT_UTIL_PKG.g_query_typ%type;
        l_view_by               ISC_DEPOT_RPT_UTIL_PKG.g_view_by_typ%type;
        l_view_by_col           ISC_DEPOT_RPT_UTIL_PKG.g_view_by_col_typ%type;
        l_xtd                   ISC_DEPOT_RPT_UTIL_PKG.g_xtd_typ%type;
        l_comparison_type       VARCHAR2(1);
        l_cur_suffix            VARCHAR2(1);
        l_col_tbl               poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl              poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_where_clause          ISC_DEPOT_RPT_UTIL_PKG.g_where_clause_typ%type;
        l_mv                    ISC_DEPOT_RPT_UTIL_PKG.g_mv_typ%type;
        l_mv_set                VARCHAR2(50);
        l_custom_rec            BIS_QUERY_ATTRIBUTES;
	l_mv_type		VARCHAR2(10);
	l_err_stage		VARCHAR2(32767);
	l_bucket_rec            bis_bucket_pub.bis_bucket_rec_type;
	l_agg_flag_1		NUMBER;   -- for isc_dr_curr_02_mv
	l_agg_flag_2		NUMBER;   -- for isc_dr_bklg_01_mv,isc_dr_bklg_02_mv
	l_debug_mode            VARCHAR2(1);
        l_module_name           ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type ;

BEGIN
	l_debug_mode            :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
        l_module_name           := FND_PROFILE.value('AFLOG_MODULE');
	l_agg_flag_1		:= 0;   -- for isc_dr_curr_02_mv
	l_agg_flag_2		:= 0;   -- for isc_dr_bklg_01_mv,isc_dr_bklg_02_mv

	-- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG.process_parameters ( p_param             => p_param,
                                                 x_view_by          => l_view_by,
                                                 x_view_by_col_name => l_view_by_col,
                                                 x_comparison_type  => l_comparison_type,
                                                 x_xtd              => l_xtd,
                                                 x_cur_suffix       => l_cur_suffix,
                                                 x_where_clause     => l_where_clause,
                                                 x_mv               => l_mv,
                                                 x_join_tbl         => l_join_tbl,
                                                 x_mv_type          => l_mv_type,
						 x_aggregation_flag => l_agg_flag_1,
                                                 p_trend            => 'N',
                                                 p_mv_set           => 'BKLDUP1',
                                                 x_custom_output    => x_custom_output);

	ISC_DEPOT_RPT_UTIL_PKG.process_parameters ( p_param             => p_param,
                                                 x_view_by          => l_view_by,
                                                 x_view_by_col_name => l_view_by_col,
                                                 x_comparison_type  => l_comparison_type,
                                                 x_xtd              => l_xtd,
                                                 x_cur_suffix       => l_cur_suffix,
                                                 x_where_clause     => l_where_clause,
                                                 x_mv               => l_mv,
                                                 x_join_tbl         => l_join_tbl,
                                                 x_mv_type          => l_mv_type,
						 x_aggregation_flag => l_agg_flag_2,
                                                 p_trend            => 'N',
                                                 p_mv_set           => 'BKLDUP2',
                                                 x_custom_output    => x_custom_output);

	IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DRM_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_TBL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
            l_err_stage:='l_view_by = ' || l_view_by || 'l_view_by_col = ' || l_view_by_col;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_TBL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
            l_err_stage:='l_mv_type = ' || l_mv_type || 'l_where_clause = ' || l_where_clause;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_TBL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

	l_mv := l_mv || '( SELECT ' || fnd_global.newline;
        IF ( l_mv_type = 'ROOT' AND l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' ) THEN
                l_mv := l_mv ||
                        '        EDH.PARENT_ID PRODUCT_CATEGORY_ID' || fnd_global.newline;
        ELSIF l_mv_type = 'ROOT' THEN
                l_mv := l_mv ||
                        '        FACT.PRODUCT_CATEGORY_ID' || fnd_global.newline;
        ELSE
                l_mv := l_mv ||
                        '        FACT.ITEM_ORG_ID' || fnd_global.newline ||
                        '        ,FACT.PRODUCT_CATEGORY_ID' || fnd_global.newline;
        END IF;
                l_mv := l_mv ||
                        '        ,FACT.REPAIR_ORGANIZATION_ID' || fnd_global.newline ||
                        '        ,FACT.REPAIR_TYPE_ID' || fnd_global.newline ||
                        '        ,FACT.CUSTOMER_ID' || fnd_global.newline ||
                        '        ,backlog_count c_backlog' || fnd_global.newline ||
                        '        ,0 p_backlog' || fnd_global.newline ||
			'	 ,not_promised_count not_promised ' || fnd_global.newline ||
                        '        ,past_due_count past_due' || fnd_global.newline ||
                        '        ,days_until_promised_b1 days_until_promised_b1' || fnd_global.newline ||
                        '        ,days_until_promised_b2 days_until_promised_b2' || fnd_global.newline ||
                        '        ,days_until_promised_b3 days_until_promised_b3' || fnd_global.newline ||
                        '        ,days_until_promised_b4 days_until_promised_b4' || fnd_global.newline ||
                        '        ,days_until_promised_b5 days_until_promised_b5' || fnd_global.newline ||
                        '        ,days_until_promised_b6 days_until_promised_b6' || fnd_global.newline ||
                        '        ,days_until_promised_b7 days_until_promised_b7' || fnd_global.newline ||
                        '        ,days_until_promised_b8 days_until_promised_b8' || fnd_global.newline ||
                        '        ,days_until_promised_b9 days_until_promised_b9' || fnd_global.newline ||
                        '        ,days_until_promised_b10 days_until_promised_b10' || fnd_global.newline ||
                        '        FROM ISC_DR_CURR_02_MV fact' || fnd_global.newline;
        IF ( l_mv_type = 'ROOT' AND l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' ) THEN
           l_mv := l_mv || ' ,ENI_DENORM_HIERARCHIES EDH,MTL_DEFAULT_CATEGORY_SETS MDCS  ' || fnd_global.newline ||
                           ' WHERE FACT.PRODUCT_CATEGORY_ID = EDH.CHILD_ID ' || fnd_global.newline ||
                           ' AND EDH.TOP_NODE_FLAG = ''Y'' ' || fnd_global.newline ||
			   ' AND EDH.OBJECT_TYPE = ''CATEGORY_SET'' ' || fnd_global.newline ||
			   ' AND EDH.OBJECT_ID = MDCS.CATEGORY_SET_ID '  || fnd_global.newline ||
                           ' AND fact.aggregation_flag = :aggregation_flag_1' || fnd_global.newline ||
			   ' AND EDH.DBI_FLAG = ''Y'' ' || fnd_global.newline ||
			   ' AND MDCS.FUNCTIONAL_AREA_ID = 11' || fnd_global.newline;
	ELSE
	  l_mv := l_mv || ' WHERE fact.aggregation_flag = :aggregation_flag_1';
        END IF;

        l_mv := l_mv || '  UNION ALL' || fnd_global.newline ||
                        '    SELECT '  || fnd_global.newline;

        IF l_mv_type <> 'ROOT' THEN
           l_mv := l_mv || ' FACT.ITEM_ORG_ID, ' || fnd_global.newline;
        END IF;

        l_mv := l_mv || '          FACT.PRODUCT_CATEGORY_ID' || fnd_global.newline ||
                        '          ,FACT.REPAIR_ORGANIZATION_ID' || fnd_global.newline ||
                        '          ,FACT.REPAIR_TYPE_ID' || fnd_global.newline ||
                        '          ,FACT.CUSTOMER_ID' || fnd_global.newline ||
                        '          ,0  c_backlog' || fnd_global.newline ||
                        '          ,(open_count - close_count) p_backlog' || fnd_global.newline ||
                        '          ,0  not_promised_count' || fnd_global.newline ||
                        '          ,0  past_due' || fnd_global.newline ||
                        '          ,0  days_until_promised_b1' || fnd_global.newline ||
                        '          ,0  days_until_promised_b2' || fnd_global.newline ||
                        '          ,0  days_until_promised_b3' || fnd_global.newline ||
                        '          ,0  days_until_promised_b4' || fnd_global.newline ||
                        '          ,0  days_until_promised_b5' || fnd_global.newline ||
                        '          ,0  days_until_promised_b6' || fnd_global.newline ||
                        '          ,0  days_until_promised_b7' || fnd_global.newline ||
                        '          ,0  days_until_promised_b8' || fnd_global.newline ||
                        '          ,0  days_until_promised_b9' || fnd_global.newline ||
                        '          ,0  days_until_promised_b10' || fnd_global.newline;
        IF l_mv_type = 'ROOT' THEN
                l_mv := l_mv ||
                        '     FROM ISC_DR_BKLG_02_MV fact' || fnd_global.newline;
        ELSE
                l_mv := l_mv ||
                        '     FROM ISC_DR_BKLG_01_MV fact' || fnd_global.newline;
        END IF;
                l_mv := l_mv ||
                        '         ,FII_TIME_RPT_STRUCT_V CAL' || fnd_global.newline ||
                        '    WHERE fact.time_id = cal.time_id' || fnd_global.newline ||
                        '      AND cal.report_date in &BIS_PREVIOUS_ASOF_DATE' || fnd_global.newline ||
                        '      AND fact.aggregation_flag = :aggregation_flag_2' || fnd_global.newline ||
                        '      AND bitand(cal.record_type_id, 1143) = cal.record_type_id) ';

        -- Add measure columns that need to be aggregated

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'c_backlog' ,
                                     p_alias_name   => 'c_backlog',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                     p_to_date_type => 'ITD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'not_promised' ,
                                     p_alias_name   => 'not_promised',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                     p_to_date_type => 'ITD');

	poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'p_backlog' ,
                                     p_alias_name   => 'p_backlog',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                     p_to_date_type => 'ITD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'PAST_DUE' ,
                                     p_alias_name   => 'past_due',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                     p_to_date_type => 'ITD');

	poa_dbi_util_pkg.add_bucket_columns(  p_short_name   => 'ISC_DEPOT_DAYS_UNTIL_PROM'
                                            , p_col_tbl      => l_col_tbl
                                            , p_col_name     => 'DAYS_UNTIL_PROMISED'
                                            , p_alias_name   => 'DUP_DISTRIBUTION'
                                            , p_grand_total  => 'Y'
                                            , p_prior_code   => poa_dbi_util_pkg.NO_PRIORS
                                            , p_to_date_type => 'ITD'
                                            , x_bucket_rec   => l_bucket_rec
                                            );


        -- There is an issue in POA util. Whenever all the measures are not XTD it does not append and 1 = 1
        -- and rather does not expect an AND in where clause.
        l_where_clause := ' 1 = 1 ' || l_where_clause;

        l_query := GET_DAYS_UNTIL_PROM_SEL_CLAUSE (l_view_by,l_bucket_rec,l_view_by_col)
                || ' from
              ' || poa_dbi_template_pkg.status_sql (p_fact_name => l_mv,
                                                    p_where_clause    => l_where_clause,
                                                    p_join_tables     => l_join_tbl,
                                                    p_use_windowing   => 'Y',
                                                    p_col_name        => l_col_tbl,
                                                    p_use_grpid       => 'N',
                                                    p_paren_count     => 3,
                                                    p_filter_where    => ' (BIV_MEASURE2 > 0 or BIV_MEASURE1> 0 ) ',
                                                    p_generate_viewby => 'Y',
                                                    p_in_join_tables  => NULL);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : ' || l_query;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the status SQL
        poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

        -- Passing AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':aggregation_flag_1';
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_value     := l_agg_flag_1;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

	-- Passing AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':aggregation_flag_2';
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_value     := l_agg_flag_2;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

	x_custom_sql := l_query;

EXCEPTION
        WHEN OTHERS THEN
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ' || SQLERRM;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;
            l_err_stage:='The exception is : ' || SQLERRM;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_BACKLOG_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);

END GET_DAYS_UNTIL_PROM_tbl_sql;


FUNCTION GET_DAYS_UNTIL_PROM_SEL_CLAUSE(  p_view_by_dim IN VARCHAR2
					, p_bucket_rec  IN bis_bucket_pub.bis_bucket_rec_type
               				,p_view_by_col IN VARCHAR2)
    RETURN VARCHAR2
IS

        l_sel_clause                VARCHAR2(8000);
        l_view_by_col_name          VARCHAR2(120);
        l_description               VARCHAR2(30);
        l_drill_across_rep_1        VARCHAR2(500);

BEGIN

        l_description               := 'null';
        l_drill_across_rep_1        := 'null' ;

	-- Item Description for item view by
        l_drill_across_rep_1 := get_drill_across (p_view_by_dim => p_view_by_dim, p_function_name =>'ISC_DEPOT_DUP_TBL_REP');
        IF (p_view_by_dim = 'ITEM+ENI_ITEM') THEN
        l_description := ' v. description ';
        END IF;
        l_sel_clause :=
        'SELECT    '|| ISC_DEPOT_RPT_UTIL_PKG.get_viewby_select_clause (p_view_by_dim) || fnd_global.newline ||
		    l_description || ' BIV_ATTRIBUTE1 ';

	l_sel_clause := l_sel_clause ||
			',BIV_MEASURE2
	                 ,BIV_MEASURE1
		         ,BIV_MEASURE3
		    	 ,BIV_MEASURE4
		     	 ,BIV_MEASURE6
		    	 ,BIV_MEASURE11
		    	 ,BIV_MEASURE13
		    	 ,BIV_MEASURE14
		    	 ,BIV_MEASURE16';

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
	                                   			               , p_col_name      => 'BIV_MEASURE5'
	                                                                       , p_alias_name    => 'BIV_MEASURE5'
	                                                                       , p_total_flag    => 'N'
					                                       , p_prefix        =>  NULL
					                                       , p_suffix        =>  NULL
	                                                                       ) || fnd_global.newline ;

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
	                                   			               , p_col_name      => 'BIV_MEASURE15'
	                                                                       , p_alias_name    => 'BIV_MEASURE15'
	                                                                       , p_total_flag    => 'N'
					                                       , p_prefix        =>  NULL
					                                       , p_suffix        =>  NULL
	                                                                       ) || fnd_global.newline ;

	l_sel_clause := l_sel_clause || ' ,'|| l_drill_across_rep_1  ||' BIV_DYNAMIC_URL1' || fnd_global.newline;

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
		                                   			       , p_col_name      => 'BIV_ATTRIBUTE10'
		                                                               , p_alias_name    => 'BIV_ATTRIBUTE10'
		                                                               , p_total_flag    => 'N'
						                               , p_prefix        =>  NULL
						                               , p_suffix        =>  NULL
		                                                                ) || fnd_global.newline ;
	l_sel_clause := l_sel_clause ||
	'FROM ( SELECT
		     rank() over (&ORDER_BY_CLAUSE'||' nulls last, '||p_view_by_col||') - 1 rnk
	           ,'||p_view_by_col;


	l_sel_clause := l_sel_clause ||
			',BIV_MEASURE2
	                 ,BIV_MEASURE1
		         ,BIV_MEASURE3
		    	 ,BIV_MEASURE4
		     	 ,BIV_MEASURE6
		    	 ,BIV_MEASURE11
		    	 ,BIV_MEASURE13
		    	 ,BIV_MEASURE14
		    	 ,BIV_MEASURE16';

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
	                                   			               , p_col_name      => 'BIV_MEASURE5'
	                                                                       , p_alias_name    => 'BIV_MEASURE5'
	                                                                       , p_total_flag    => 'N'
					                                       , p_prefix        =>  NULL
					                                       , p_suffix        =>  NULL
	                                                                       ) || fnd_global.newline ;

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
	                                   			               , p_col_name      => 'BIV_MEASURE15'
	                                                                       , p_alias_name    => 'BIV_MEASURE15'
	                                                                       , p_total_flag    => 'N'
					                                       , p_prefix        =>  NULL
					                                       , p_suffix        =>  NULL
	                                                                       ) || fnd_global.newline ;

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
		                                   			       , p_col_name      => 'BIV_ATTRIBUTE10'
		                                                               , p_alias_name    => 'BIV_ATTRIBUTE10'
		                                                               , p_total_flag    => 'N'
						                               , p_prefix        =>  NULL
						                               , p_suffix        =>  NULL
		                                                                ) || fnd_global.newline ;
	l_sel_clause := l_sel_clause ||
        'FROM (
         SELECT  ' || p_view_by_col || fnd_global.newline ||
		 ',' || ' NVL(c_p_backlog,0) BIV_MEASURE2 ' || fnd_global.newline ||
                 ',' || ' NVL(c_c_backlog,0) BIV_MEASURE1 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_c_backlog'
                                                           ,prior_col   => 'c_p_backlog'
                                                           ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                           || ' BIV_MEASURE3' || fnd_global.newline ||
                 ',' || 'NVL(c_past_due,0) BIV_MEASURE4 ' || fnd_global.newline ;
	 l_sel_clause := l_sel_clause ||
	                 poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    => p_bucket_rec
	                                                        , p_col_name      => 'c_DUP_DISTRIBUTION'
	                                                        , p_alias_name    => 'BIV_MEASURE5'
	                                                        , p_total_flag    => 'N'
	                                                        , p_prefix	  => NULL
								, p_suffix        => NULL
	                                                        ) || fnd_global.newline ;
	 l_sel_clause := l_sel_clause ||
                 ',' || ' NVL(c_not_promised,0) BIV_MEASURE6 ' || fnd_global.newline ||
                 ',' || ' NVL(c_c_backlog_total,0) BIV_MEASURE11 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_c_backlog_total'
                                                           ,prior_col   => 'c_p_backlog_total'
                                                           ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                           || ' BIV_MEASURE13' || fnd_global.newline ||
                 ',' || ' NVL(c_past_due_total,0) BIV_MEASURE14 ' || fnd_global.newline ;
	 l_sel_clause := l_sel_clause ||
	                 poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    => p_bucket_rec
	                                                        , p_col_name      => 'c_DUP_DISTRIBUTION'
	                                                        , p_alias_name    => 'BIV_MEASURE15'
	                                                        , p_total_flag    => 'Y'
	                                                        , p_prefix	  => NULL
								, p_suffix        => NULL
	                                                        ) || fnd_global.newline ;
	 l_sel_clause := l_sel_clause ||
                 ',' || ' NVL(c_not_promised_total,0) BIV_MEASURE16 ' || fnd_global.newline ;

        l_sel_clause := l_sel_clause ||
   	  		poa_dbi_util_pkg.get_bucket_drill_url( p_bucket_rec
   	  						     , 'BIV_ATTRIBUTE10'
							     ,'''pFunctionName=ISC_DEPOT_BACKLOG_DTL_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&BIV_ATTRIBUTE1=-1&BIV_DR_BACKLOG_BUCKET+BIV_DR_BACKLOG_BUCKET='
							     , ''''
							     , p_add_bucket_num => 'Y');

RETURN l_sel_clause;

END GET_DAYS_UNTIL_PROM_SEL_CLAUSE;

FUNCTION get_drill_across (p_view_by_dim IN VARCHAR2,p_function_name IN VARCHAR2)
RETURN VARCHAR2
IS
	l_drill_across varchar2 (500);
BEGIN
        l_drill_across := 'NULL';
	IF (p_view_by_dim = 'ITEM+ENI_ITEM_VBH_CAT') THEN
		l_drill_across := 'decode(v.leaf_node_flag, ''Y'',
		''pFunctionName='|| p_function_name ||'&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y'',
		''pFunctionName='|| p_function_name ||'&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'') ';
	END IF;
	RETURN l_drill_across;
END get_drill_across ;

END ISC_DEPOT_BACKLOG_PKG;

/
