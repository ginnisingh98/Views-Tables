--------------------------------------------------------
--  DDL for Package Body ISC_DEPOT_COMPLETION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DEPOT_COMPLETION_PKG" AS
--$Header: iscdepotcomprqb.pls 120.0 2005/05/25 17:25:22 appldev noship $

FUNCTION GET_COMPLETION_TBL_SEL_CLAUSE (p_view_by_dim IN VARCHAR2
                                       ,p_view_by_col IN VARCHAR2)
RETURN VARCHAR2;


FUNCTION GET_COMPLETION_TRD_SEL_CLAUSE (p_view_by_dim IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION GET_DRILL_ACROSS (p_view_by_dim IN VARCHAR2,p_function_name IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE GET_COMPLETION_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
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
        l_mv_type               VARCHAR2(10);
        l_err_stage             VARCHAR2(32767);
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
                                                 p_trend            => 'N',
                                                 p_mv_set           => 'BKLG',
                                                 x_custom_output    => x_custom_output);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DRM_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_COMPLETION_TBL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'close_count' ,
                                     p_alias_name   => 'completed_count',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'COMPLETE_WITH_PROMISE_DATE_CNT' ,
                                     p_alias_name   => 'cmplt_with_prom_dt',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'late_complete_count' ,
                                     p_alias_name   => 'late_complete_count',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'days_late' ,
                                     p_alias_name   => 'days_late',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');



	l_query := GET_COMPLETION_TBL_SEL_CLAUSE ( p_view_by_dim => l_view_by
                                                  ,p_view_by_col => l_view_by_col )
                || ' from
              ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
                                                    p_where_clause    => l_where_clause,
                                                    p_join_tables     => l_join_tbl,
                                                    p_use_windowing   => 'Y',
                                                    p_col_name        => l_col_tbl,
                                                    p_use_grpid       => 'N',
                                                    p_paren_count     => 3,
                                                    p_filter_where    => ' (BIV_MEASURE1 > 0 or BIV_MEASURE11 > 0 ) ',
                                                    p_generate_viewby => 'Y',
                                                    p_in_join_tables  => NULL);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : ' || l_query;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_COMPLETION_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
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
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_COMPLETION_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END GET_COMPLETION_TBL_SQL;


FUNCTION GET_COMPLETION_TBL_SEL_CLAUSE( p_view_by_dim IN VARCHAR2
                                       ,p_view_by_col IN VARCHAR2)
    RETURN VARCHAR2
IS

        l_sel_clause                VARCHAR2(8000);
        l_view_by_col_name          VARCHAR2(120);
        l_description               VARCHAR2(30);
        l_drill_across_rep_1        VARCHAR2(500);
        l_drill_across_rep_2        VARCHAR2(500);

BEGIN
        l_description               := 'null';
        l_drill_across_rep_1        := 'null' ;
        l_drill_across_rep_2        := 'null' ;

        -- Item Description for item view by
        l_drill_across_rep_1 := get_drill_across (p_view_by_dim => p_view_by_dim, p_function_name =>'ISC_DEPOT_COMPLETION_TBL_REP');
        IF (p_view_by_dim IN ('ITEM+ENI_ITEM')) THEN
                l_description := ' v. description ';
        END IF;

        IF (p_view_by_dim IN  ('ITEM+ENI_ITEM', 'CUSTOMER+PROSPECT')) THEN
                l_drill_across_rep_2 := '''pFunctionName=ISC_DEPOT_COMP_DTL_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y''';
        END IF;

        l_sel_clause :=
        'SELECT    '|| ISC_DEPOT_RPT_UTIL_PKG.get_viewby_select_clause (p_view_by_dim) || fnd_global.newline ||
                    l_description || ' BIV_ATTRIBUTE1
                    ,BIV_MEASURE1
                    ,BIV_MEASURE11
                    ,BIV_MEASURE2
                    ,BIV_MEASURE3
                    ,BIV_MEASURE4
                    ,BIV_MEASURE5
                    ,BIV_MEASURE12
                    ,BIV_MEASURE6
                    ,BIV_MEASURE7
                    ,BIV_MEASURE13
                    ,BIV_MEASURE8
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
                    ,BIV_MEASURE35
                    ,BIV_MEASURE36
                    ,' || l_drill_across_rep_1 || ' BIV_DYNAMIC_URL1
                    ,BIV_DYNAMIC_URL_2 ' || fnd_global.newline ||
        'FROM ( SELECT
		     rank() over (&ORDER_BY_CLAUSE'||' nulls last, '||p_view_by_col||' ) - 1 rnk
                    ,'||p_view_by_col||'
                    ,BIV_MEASURE1
                    ,BIV_MEASURE11
                    ,BIV_MEASURE2
                    ,BIV_MEASURE3
                    ,BIV_MEASURE4
                    ,BIV_MEASURE5
                    ,BIV_MEASURE12
                    ,BIV_MEASURE6
                    ,BIV_MEASURE7
                    ,BIV_MEASURE13
                    ,BIV_MEASURE8
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
                    ,BIV_MEASURE35
                    ,BIV_MEASURE36
                    ,BIV_DYNAMIC_URL_2 ' || fnd_global.newline ||
                 ' FROM ( SELECT  '   || fnd_global.newline ||
                     p_view_by_col || fnd_global.newline ||
                 ',' || 'NVL(c_completed_count,0) BIV_MEASURE1 ' || fnd_global.newline ||
                 ',' || 'NVL(p_completed_count,0) BIV_MEASURE11 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_completed_count'
                                                        ,prior_col   => 'p_completed_count'
                                                        ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                         || ' BIV_MEASURE2' || fnd_global.newline ||
                 ',' || 'NVL(c_cmplt_with_prom_dt,0) BIV_MEASURE3 ' || fnd_global.newline ||
                 ',' || 'NVL(c_late_complete_count,0) BIV_MEASURE4 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'c_late_complete_count'
                                                      ,denominator => 'c_completed_count'
                                                      ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                      || 'BIV_MEASURE5' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'p_late_complete_count'
                                                      ,denominator => 'p_completed_count'
                                                      ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                      || ' BIV_MEASURE12' || fnd_global.newline ||
                 ',' || OPI_DBI_RPT_UTIL_PKG.change_pct_str(p_new_numerator     => 'c_late_complete_count',
                                                            p_new_denominator   => 'c_completed_count',
                                                            p_old_numerator     => 'p_late_complete_count',
                                                            p_old_denominator   => 'p_completed_count',
                                                            p_measure_name      => 'BIV_MEASURE6')
                                                           || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'c_days_late'
                                                      ,denominator => 'c_late_complete_count'
                                                      ,rate_type  =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                      || ' BIV_MEASURE7' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'p_days_late'
                                                      ,denominator => 'p_late_complete_count'
                                                      ,rate_type  =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                      || ' BIV_MEASURE13' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'c_days_late'
                                                      ,denominator => 'c_late_complete_count'
                                                      ,rate_type  =>  'NP') -- 'P' for Percent ; 'NP' for non percent
		     || ' - '
                     || poa_dbi_util_pkg.rate_clause(  numerator => 'p_days_late'
                                                      ,denominator => 'p_late_complete_count'
                                                      ,rate_type  =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                      || ' BIV_MEASURE8' || fnd_global.newline ||
                 ',' || 'NVL(c_completed_count_total,0) BIV_MEASURE21 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause(  cur_col     => 'c_completed_count_total'
                                                        ,prior_col   => 'p_completed_count_total'
                                                        ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                           || 'BIV_MEASURE22' || fnd_global.newline ||
                 ',' || 'NVL(c_cmplt_with_prom_dt_total,0) BIV_MEASURE23 ' || fnd_global.newline ||
                 ',' || 'NVL(c_late_complete_count_total,0) BIV_MEASURE24 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'c_late_complete_count_total'
                                                      ,denominator => 'c_completed_count_total'
                                                      ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                      || 'BIV_MEASURE25' || fnd_global.newline ||
                 ',' || OPI_DBI_RPT_UTIL_PKG.change_pct_str(p_new_numerator     => 'c_late_complete_count_total',
                                                            p_new_denominator   => 'c_completed_count_total',
                                                            p_old_numerator     => 'p_late_complete_count_total',
                                                            p_old_denominator   => 'p_completed_count_total',
                                                            p_measure_name      => 'BIV_MEASURE26')
                                                           || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'c_days_late_total'
                                                      ,denominator => 'c_late_complete_count_total'
                                                      ,rate_type  =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                      || ' BIV_MEASURE27' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'c_days_late_total'
                                                      ,denominator => 'c_late_complete_count_total'
                                                      ,rate_type  =>  'NP') -- 'P' for Percent ; 'NP' for non percent
		     || ' - '
                     || poa_dbi_util_pkg.rate_clause(  numerator => 'p_days_late_total'
                                                      ,denominator => 'p_late_complete_count_total'
                                                      ,rate_type  =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                      || ' BIV_MEASURE28' || fnd_global.newline ||
                 ',' || 'NVL(c_completed_count,0) BIV_MEASURE29 ' || fnd_global.newline ||
                 ',' || 'NVL(p_completed_count,0) BIV_MEASURE30 ' || fnd_global.newline ||
                 ',' || 'NVL(c_completed_count_total,0) BIV_MEASURE31 ' || fnd_global.newline ||
                 ',' || 'NVL(p_completed_count_total,0) BIV_MEASURE32 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'c_late_complete_count'
                                                      ,denominator => 'c_completed_count'
                                                      ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                      || 'BIV_MEASURE33' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'p_late_complete_count'
                                                      ,denominator => 'p_completed_count'
                                                      ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                      || 'BIV_MEASURE34' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'c_late_complete_count_total'
                                                      ,denominator => 'c_completed_count_total'
                                                      ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                      || 'BIV_MEASURE35' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'p_late_complete_count_total'
                                                      ,denominator => 'p_completed_count_total'
                                                      ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                      || 'BIV_MEASURE36' || fnd_global.newline  ||
                 ',' || l_drill_across_rep_2 || ' BIV_DYNAMIC_URL_2 ' || fnd_global.newline;
RETURN l_sel_clause;

END GET_COMPLETION_TBL_SEL_CLAUSE;

PROCEDURE GET_COMPLETION_TRD_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
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
        l_mv_type               VARCHAR2(10);
        l_err_stage             VARCHAR2(32767);
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
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_COMPLETION_TRD : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'close_count' ,
                                     p_alias_name   => 'completed_count',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'late_complete_count' ,
                                     p_alias_name   => 'late_complete_count',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'days_late' ,
                                     p_alias_name   => 'days_late',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        l_query := GET_COMPLETION_TRD_SEL_CLAUSE (l_view_by)
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
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_COMPLETION_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
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

        x_custom_sql := l_query;
EXCEPTION

        WHEN OTHERS THEN
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ' || SQLERRM;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_COMPLETION_TRD : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END GET_COMPLETION_TRD_SQL;

FUNCTION GET_COMPLETION_TRD_SEL_CLAUSE(p_view_by_dim IN VARCHAR2)
    RETURN VARCHAR2
IS

        l_sel_clause                VARCHAR2(8000);
        l_view_by_col_name          VARCHAR2(120);
        l_description               VARCHAR2(30);

BEGIN
        l_description               := 'null';

	l_sel_clause :=
        'SELECT  cal.name VIEWBY ' || fnd_global.newline ||
                 ',' || 'NVL(iset.c_completed_count,0) BIV_MEASURE1 ' || fnd_global.newline ||
                 ',' || 'NVL(iset.p_completed_count,0) BIV_MEASURE11 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_completed_count'
                                                        ,prior_col   => 'p_completed_count'
                                                        ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                         || ' BIV_MEASURE2' || fnd_global.newline ||
                 ',' || 'NVL(iset.c_late_complete_count,0) BIV_MEASURE3 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'c_late_complete_count'
                                                      ,denominator => 'c_completed_count'
                                                      ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                      || 'BIV_MEASURE4' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'p_late_complete_count'
                                                      ,denominator => 'p_completed_count'
                                                      ,rate_type  =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                      || ' BIV_MEASURE12' || fnd_global.newline ||
                 ',' || OPI_DBI_RPT_UTIL_PKG.change_pct_str(p_new_numerator     => 'c_late_complete_count',
                                                            p_new_denominator   => 'c_completed_count',
                                                            p_old_numerator     => 'p_late_complete_count',
                                                            p_old_denominator   => 'p_completed_count',
                                                            p_measure_name      => 'BIV_MEASURE5')
                                                           || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'c_days_late'
                                                      ,denominator => 'c_late_complete_count'
                                                      ,rate_type  =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                      || ' BIV_MEASURE6' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'p_days_late'
                                                      ,denominator => 'p_late_complete_count'
                                                      ,rate_type  =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                      || ' BIV_MEASURE13' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.rate_clause(  numerator => 'c_days_late'
                                                      ,denominator => 'c_late_complete_count'
                                                      ,rate_type  =>  'NP') -- 'P' for Percent ; 'NP' for non percent
		     || ' - '
                     || poa_dbi_util_pkg.rate_clause(  numerator => 'p_days_late'
                                                      ,denominator => 'p_late_complete_count'
                                                      ,rate_type  =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                      || ' BIV_MEASURE7' || fnd_global.newline;
RETURN l_sel_clause;

END GET_COMPLETION_TRD_SEL_CLAUSE;


PROCEDURE GET_COMPLETION_DTL_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
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
        l_mv_type               VARCHAR2(10);
        l_err_stage             VARCHAR2(32767);
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
                                                 p_trend            => 'N',
                                                 p_mv_set           => 'CMPDTL1',
                                                 x_custom_output    => x_custom_output);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DRM_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_COMPLETION_DTL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
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
                ,BIV_DATE1
                ,BIV_DATE2
                ,BIV_MEASURE2
                ,BIV_MEASURE3
		,''pFunctionName=CSD_RO_DETAILS&csdInvOrgId=''||BIV_MEASURE3||''&csdRepairLineId=''||BIV_MEASURE2 BIV_DYNAMIC_URL1
		,' || ISC_DEPOT_RPT_UTIL_PKG.get_service_request_url || ' || BIV_ATTRIBUTE8 BIV_DYNAMIC_URL2
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
                        ,BIV_DATE1
                        ,BIV_DATE2
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
                         ',' || ' serial_number BIV_ATTRIBUTE7 ' || fnd_global.newline ||
                         ',' || ' incident_id BIV_ATTRIBUTE8 ' || fnd_global.newline ||
                         ',' || ' promise_date BIV_DATE1 ' || fnd_global.newline ||
                         ',' || ' date_closed BIV_DATE2 ' || fnd_global.newline ||
        	         ',' || ' fact.repair_line_id  BIV_MEASURE2 ' || fnd_global.newline ||
        	         ',' || ' fact.master_organization_id BIV_MEASURE3 ' || fnd_global.newline
                             || ' from ' || fnd_global.newline
                             ||   l_mv || fnd_global.newline
                             || ' ISC_DR_REPAIR_ORDERS_F fact, ' || fnd_global.newline
                             || ' ENI_ITEM_V EIOV, ' || fnd_global.newline
                             || ' FND_LOOKUPS FL, ' || fnd_global.newline
                             || ' MTL_UNITS_OF_MEASURE_VL MUM ' || fnd_global.newline
                             || ' WHERE dbi_date_closed between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ' || fnd_global.newline
                             || '   AND FL.LOOKUP_TYPE = ''CSD_REPAIR_STATUS'' ' || fnd_global.newline
                             || '   AND FL.LOOKUP_CODE = fact.status ' || fnd_global.newline
                             || '   AND FACT.item_org_id = eiov.id ' || fnd_global.newline
                             || '   AND mum.uom_code = fact.uom_code ' || fnd_global.newline
                             || l_where_clause || fnd_global.newline
                || ' ) ) where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
                        ORDER BY rnk' || fnd_global.newline ;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : ' || l_query;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_COMPLETION_DTL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;
        x_custom_sql := l_query;

EXCEPTION

        WHEN OTHERS THEN
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ' || SQLERRM;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_COMPLETION_DTL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END GET_COMPLETION_DTL_TBL_SQL;

PROCEDURE GET_LAT_COMP_DTL_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
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
        l_mv_type               VARCHAR2(10);
        l_err_stage             VARCHAR2(32767);
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
                                                 p_trend            => 'N',
                                                 p_mv_set           => 'CMPDTL2',
                                                 x_custom_output    => x_custom_output);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DRM_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_LAT_COMP_DTL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
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
                ,BIV_DATE1
                ,BIV_DATE2
                ,BIV_MEASURE2
                ,BIV_MEASURE3
                ,BIV_MEASURE4
		,''pFunctionName=CSD_RO_DETAILS&csdInvOrgId=''||BIV_MEASURE4||''&csdRepairLineId=''||BIV_MEASURE3 BIV_DYNAMIC_URL1
		,' || ISC_DEPOT_RPT_UTIL_PKG.get_service_request_url || ' || BIV_ATTRIBUTE8 BIV_DYNAMIC_URL2
         FROM (
                SELECT
                         rank() over (&ORDER_BY_CLAUSE nulls last,BIV_ATTRIBUTE1 ) - 1 rnk
                        ,BIV_ATTRIBUTE1
                        ,BIV_ATTRIBUTE2
                        ,BIV_ATTRIBUTE3
                        ,BIV_ATTRIBUTE4
                        ,BIV_ATTRIBUTE5
                        ,BIV_ATTRIBUTE6
                        ,BIV_MEASURE1
                        ,BIV_ATTRIBUTE7
                        ,BIV_ATTRIBUTE8
                        ,BIV_DATE1
                        ,BIV_DATE2
                        ,BIV_MEASURE2
                        ,BIV_MEASURE3
                        ,BIV_MEASURE4
                FROM (
                        SELECT  repair_number BIV_ATTRIBUTE1 ' || fnd_global.newline ||
                            ',' || ' incident_number BIV_ATTRIBUTE2 ' || fnd_global.newline ||
                            ',' || ' crt.name BIV_ATTRIBUTE3 ' || fnd_global.newline ||
                            ',' || ' eiov.value BIV_ATTRIBUTE4 ' || fnd_global.newline ||
                            ',' || ' eiov.description BIV_ATTRIBUTE5 ' || fnd_global.newline ||
                            ',' || ' mum.unit_of_measure BIV_ATTRIBUTE6 ' || fnd_global.newline ||
                            ',' || ' quantity BIV_MEASURE1 ' || fnd_global.newline ||
                            ',' || ' serial_number BIV_ATTRIBUTE7 ' || fnd_global.newline ||
                            ',' || ' incident_id BIV_ATTRIBUTE8 ' || fnd_global.newline ||
                            ',' || ' promise_date BIV_DATE1 ' || fnd_global.newline ||
                            ',' || ' date_closed BIV_DATE2 ' || fnd_global.newline ||
                            ',' || ' trunc(date_closed) - trunc(promise_date) BIV_MEASURE2 ' || fnd_global.newline ||
        	            ',' || ' fact.repair_line_id  BIV_MEASURE3 ' || fnd_global.newline ||
        	            ',' || ' fact.master_organization_id BIV_MEASURE4 ' || fnd_global.newline
                                || ' from ' || fnd_global.newline
                                ||   l_mv || fnd_global.newline
                                || ' ISC_DR_REPAIR_ORDERS_F fact, ' || fnd_global.newline
                                || ' ENI_ITEM_V EIOV, ' || fnd_global.newline
                                || ' FND_LOOKUPS FL, ' || fnd_global.newline
                                || ' MTL_UNITS_OF_MEASURE_VL MUM ' || fnd_global.newline
                                || ' WHERE dbi_date_closed between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ' || fnd_global.newline
                                || '   AND dbi_date_closed  > fact.promise_date ' || fnd_global.newline
                                || '   AND FL.LOOKUP_TYPE = ''CSD_REPAIR_STATUS'' ' || fnd_global.newline
                                || '   AND FL.LOOKUP_CODE = fact.status ' || fnd_global.newline
                                || '   AND FACT.item_org_id = eiov.id ' || fnd_global.newline
                                || '   AND mum.uom_code = fact.uom_code '  || fnd_global.newline
                                || l_where_clause || fnd_global.newline
                || ' ) ) where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
                        ORDER BY rnk' || fnd_global.newline ;
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : ' || l_query;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_LAT_COMP_DTL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;
        x_custom_sql := l_query;

EXCEPTION
        WHEN OTHERS THEN
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ' || SQLERRM;
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_LAT_COMP_DTL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END GET_LAT_COMP_DTL_TBL_SQL;

PROCEDURE GET_LAT_COMP_AGNG_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
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
        l_mv_type               VARCHAR2(10);
        l_err_stage             VARCHAR2(32767);
        l_function_name         VARCHAR2(30);
	l_debug_mode            VARCHAR2(1);
        l_module_name           ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type ;

BEGIN
	l_debug_mode            :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
        l_module_name           := FND_PROFILE.value('AFLOG_MODULE');

        -- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG.process_parameters (p_param             => p_param,
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
                                                 p_mv_set           => 'CMPAGN1',
                                                 x_custom_output    => x_custom_output);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DRM_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG.write('BIS_ISC_DEPOT_COMPLETION_TBL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

        l_query := '    SELECT range_name BIV_ATTRIBUTE1 '  || fnd_global.newline ||
                           '      ,nvl(c_LATE_COMPLETE_COUNT,0) BIV_MEASURE1 ' || fnd_global.newline ||
                           '      ,nvl(p_LATE_COMPLETE_COUNT,0) BIV_MEASURE11 ' || fnd_global.newline ||
                           '      ,' || poa_dbi_util_pkg.change_clause(cur_col     => 'c_LATE_COMPLETE_COUNT'
                                                                      ,prior_col   => 'p_LATE_COMPLETE_COUNT'
                                                                      ,change_type =>  'NP') || 'BIV_MEASURE2' || fnd_global.newline ||
                           '      ,'|| poa_dbi_util_pkg.rate_clause(numerator   => 'c_LATE_COMPLETE_COUNT'
                                                                   ,denominator => 'c_LATE_COMPLETE_COUNT_TOTAL'
                                                                   ,rate_type   =>  'P') || 'BIV_MEASURE3' || fnd_global.newline ||
                           '      ,nvl(c_LATE_COMPLETE_COUNT_total,0)  BIV_MEASURE21 ' || fnd_global.newline ||
                           '      ,'|| poa_dbi_util_pkg.change_clause(cur_col     => 'c_LATE_COMPLETE_COUNT_total'
                                                                     ,prior_col   => 'p_LATE_COMPLETE_COUNT_total'
                                                                     ,change_type =>  'NP') || 'BIV_MEASURE22' || fnd_global.newline ||
                           '      ,'|| poa_dbi_util_pkg.rate_clause(numerator   => 'c_LATE_COMPLETE_COUNT_TOTAL'
                                                                   ,denominator => 'c_LATE_COMPLETE_COUNT_TOTAL'
                                                                   ,rate_type   =>  'P') || 'BIV_MEASURE23' || fnd_global.newline ||
--                           ','  || 'ISC_DEPOT_COMPLETION_PKG.GET_BUCKET_DRILL_ACROSS_URL(''ISC_DEPOT_LAT_COMP_DTL_TBL_REP'', bucket_number)' || ' BIV_DYNAMIC_URL1 ' ||
                          ',' || '''pFunctionName=ISC_DEPOT_LAT_COMP_DTL_TBL_REP&pParamIds=Y&BIV_ATTRIBUTE1=-1&BIV_DR_BACKLOG_BUCKET+BIV_DR_BACKLOG_BUCKET=''|| bucket_number ||''''' || ' BIV_DYNAMIC_URL1 ' ||
                           ' FROM (select sum (decode(cal.report_date, &BIS_CURRENT_ASOF_DATE, ' || fnd_global.newline ||
                           '             decode (buckets.bucket_number, 1, days_late_age_b1 ' || fnd_global.newline ||
                           '                                           ,2, days_late_age_b2 ' || fnd_global.newline ||
                           '                                           ,3, days_late_age_b3 ' || fnd_global.newline ||
                           '                                           ,4, days_late_age_b4 ' || fnd_global.newline ||
                           '                                           ,5, days_late_age_b5 ' || fnd_global.newline ||
                           '                                           ,6, days_late_age_b6 ' || fnd_global.newline ||
                           '                                           ,7, days_late_age_b7 ' || fnd_global.newline ||
                           '                                           ,8, days_late_age_b8 ' || fnd_global.newline ||
                           '                                           ,9, days_late_age_b9 ' || fnd_global.newline ||
                           '                                           ,10, days_late_age_b10 ))) c_LATE_COMPLETE_COUNT '  || fnd_global.newline ||
                           '        ,sum (decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE, ' || fnd_global.newline ||
                           '             decode (buckets.bucket_number, 1, days_late_age_b1 ' || fnd_global.newline ||
                           '                                           ,2, days_late_age_b2 ' || fnd_global.newline ||
                           '                                           ,3, days_late_age_b3 ' || fnd_global.newline ||
                           '                                           ,4, days_late_age_b4 ' || fnd_global.newline ||
                           '                                           ,5, days_late_age_b5 ' || fnd_global.newline ||
                           '                                           ,6, days_late_age_b6 ' || fnd_global.newline ||
                           '                                           ,7, days_late_age_b7 ' || fnd_global.newline ||
                           '                                           ,8, days_late_age_b8 ' || fnd_global.newline ||
                           '                                           ,9, days_late_age_b9 ' || fnd_global.newline ||
                           '                                           ,10, days_late_age_b10 ))) p_LATE_COMPLETE_COUNT '  || fnd_global.newline ||
--                           ' ,0 c_LATE_COMPLETE_COUNT_total , 0 p_LATE_COMPLETE_COUNT_total ' ||
                           '        ,sum (sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE, ' || fnd_global.newline ||
                           '             decode (buckets.bucket_number, 1, days_late_age_b1 ' || fnd_global.newline ||
                           '                                           ,2, days_late_age_b2 ' || fnd_global.newline ||
                           '                                           ,3, days_late_age_b3 ' || fnd_global.newline ||
                           '                                           ,4, days_late_age_b4 ' || fnd_global.newline ||
                           '                                           ,5, days_late_age_b5 ' || fnd_global.newline ||
                           '                                           ,6, days_late_age_b6 ' || fnd_global.newline ||
                           '                                           ,7, days_late_age_b7 ' || fnd_global.newline ||
                           '                                           ,8, days_late_age_b8 ' || fnd_global.newline ||
                           '                                           ,9, days_late_age_b9 ' || fnd_global.newline ||
                           '                                           ,10, days_late_age_b10 )))) over () c_LATE_COMPLETE_COUNT_total '  || fnd_global.newline ||
                           '        ,sum (sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE, ' || fnd_global.newline ||
                           '             decode (buckets.bucket_number, 1, days_late_age_b1 ' || fnd_global.newline ||
                           '                                           ,2, days_late_age_b2 ' || fnd_global.newline ||
                           '                                           ,3, days_late_age_b3 ' || fnd_global.newline ||
                           '                                           ,4, days_late_age_b4 ' || fnd_global.newline ||
                           '                                           ,5, days_late_age_b5 ' || fnd_global.newline ||
                           '                                           ,6, days_late_age_b6 ' || fnd_global.newline ||
                           '                                           ,7, days_late_age_b7 ' || fnd_global.newline ||
                           '                                           ,8, days_late_age_b8 ' || fnd_global.newline ||
                           '                                           ,9, days_late_age_b9 ' || fnd_global.newline ||
                           '                                           ,10, days_late_age_b10 )))) over () p_LATE_COMPLETE_COUNT_total '  || fnd_global.newline ||
                           '     ,range_name ' || fnd_global.newline ||
                           '     ,buckets.bucket_number ' || fnd_global.newline ||
                   ' from (';
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
                                l_query := l_query || ') buckets, ' || fnd_global.newline;
                        END IF;
                END LOOP;

        IF l_mv_type = 'ROOT' THEN
                l_mv := l_mv ||
                        '     ISC_DR_BKLG_02_MV fact' || fnd_global.newline;
        ELSE
                l_mv := l_mv ||
                        '     ISC_DR_BKLG_01_MV fact' || fnd_global.newline;
        END IF;
                l_query := l_query || l_mv ||
                          ',fii_time_rpt_struct_v cal' || fnd_global.newline ||
                          ' where fact.time_id = cal.time_id' || fnd_global.newline ||
                          '   and cal.report_date in (&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE)' || fnd_global.newline ||
                          '   and bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id ' || fnd_global.newline ||
                          l_where_clause || fnd_global.newline ||
                         ' group by range_name, buckets.bucket_number order by buckets.bucket_number)';

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

END GET_LAT_COMP_AGNG_TBL_SQL;

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


FUNCTION GET_BUCKET_DRILL_ACROSS_URL (p_function_name VARCHAR2,
                                      p_bucket_number NUMBER)
RETURN VARCHAR2
IS
    l_drill_across_rep_1        VARCHAR2(500);
BEGIN
    l_drill_across_rep_1 := 'null' ;
    l_drill_across_rep_1 := 'pFunctionName=' || p_function_name || '&SERVICE_DISTRIBUTION=';
    l_drill_across_rep_1 := l_drill_across_rep_1  || p_bucket_number || '&pParamIds=Y';

    RETURN l_drill_across_rep_1;
END GET_BUCKET_DRILL_ACROSS_URL ;

END ISC_DEPOT_COMPLETION_PKG;

/
