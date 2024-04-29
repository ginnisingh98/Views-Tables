--------------------------------------------------------
--  DDL for Package Body ISC_DEPOT_MTTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DEPOT_MTTR_PKG" AS
--$Header: iscdepotmttrrqb.pls 120.0 2005/05/25 17:41:39 appldev noship $

FUNCTION GET_MTTR_TBL_SEL_CLAUSE(p_view_by_dim IN VARCHAR2,p_view_by_col IN VARCHAR2,p_bucket_rec IN bis_bucket_pub.bis_bucket_rec_type)
RETURN VARCHAR2;

FUNCTION get_drill_down (p_view_by_dim IN VARCHAR2,p_function_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION GET_MTTR_TRD_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_bucket_rec IN bis_bucket_pub.bis_bucket_rec_type)
RETURN VARCHAR2;

FUNCTION GET_MTTR_DIST_TBL_SEL_CLAUSE(p_view_by_dim IN VARCHAR2,p_view_by_col IN VARCHAR2,p_bucket_rec IN bis_bucket_pub.bis_bucket_rec_type)
RETURN VARCHAR2;

FUNCTION GET_MTTR_DIST_TRD_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_bucket_rec IN bis_bucket_pub.bis_bucket_rec_type)
RETURN VARCHAR2;

FUNCTION GET_MTTR_DTL_SEL_CLAUSE(l_mv ISC_DEPOT_RPT_UTIL_PKG.g_mv_typ%type ,l_where_clause ISC_DEPOT_RPT_UTIL_PKG.g_where_clause_typ%type)
RETURN VARCHAR2;

FUNCTION GET_SRVC_TBL_SEL_CLAUSE(p_view_by_dim IN VARCHAR2,p_view_by_col IN VARCHAR2)
RETURN VARCHAR2;

--Package level variables


-- MEAN TIME TO REPAIR STATUS REPORT

PROCEDURE GET_MTTR_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
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
	l_bucket_rec            bis_bucket_pub.bis_bucket_rec_type;
	l_debug_mode            VARCHAR2(1);
	l_module_name           ISC_DEPOT_RPT_UTIL_PKG .g_module_name_typ%type;

BEGIN
	l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
	l_module_name := FND_PROFILE.value('AFLOG_MODULE');

        -- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG .process_parameters (p_param            => p_param,
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
                                                p_mv_set           => 'MTTR',
                                                x_custom_output    => x_custom_output);

        IF (l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%') THEN
            l_err_stage:='After calling  DR_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_TBL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'ro_count',
                                     p_alias_name   => 'ro_count',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'time_to_repair',
                                     p_alias_name   => 'time_to_repair',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

           poa_dbi_util_pkg.add_bucket_columns(p_short_name   => 'ISC_DEPOT_MTTR'
	                                     , p_col_tbl      => l_col_tbl
                                             , p_col_name     => 'time_to_repair'
                                             , p_alias_name   => 'ttr_distribution'
                                             , p_grand_total  => 'Y'
                                             , p_prior_code   => poa_dbi_util_pkg.NO_PRIORS
                                             , p_to_date_type => 'XTD'
                                             , x_bucket_rec   => l_bucket_rec);

        l_query := GET_MTTR_TBL_SEL_CLAUSE (l_view_by,l_view_by_col,l_bucket_rec)
                || ' from
              ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
                                                        p_where_clause    => l_where_clause,
                                                        p_join_tables     => l_join_tbl,
                                                    	p_use_windowing   => 'Y',
                                                    	p_col_name        => l_col_tbl,
                                                    	p_use_grpid       => 'N',
                                                    	p_paren_count     => 3,
                                                    	p_filter_where    => NULL,
                                                    	p_generate_viewby => 'Y',
                                                    	p_in_join_tables  => NULL);

	IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : || l_query';
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the status SQL
        poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

        -- Passing AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':AGGREGATION_FLAG';
        l_custom_rec.attribute_type     :=  BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_value     := l_aggregation_flag;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        x_custom_sql := l_query;

EXCEPTION

        WHEN OTHERS THEN
	l_err_stage := SQLERRM;
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ' || l_err_stage;
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

END GET_MTTR_TBL_SQL;


FUNCTION GET_MTTR_TBL_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_view_by_col IN VARCHAR2, p_bucket_rec IN bis_bucket_pub.bis_bucket_rec_type)
RETURN VARCHAR2
IS

        l_sel_clause                VARCHAR2(8000);
        l_view_by_col_name          VARCHAR2(120);
        l_description               VARCHAR2(30);
        l_drill_down_rep_1          VARCHAR2(500);

BEGIN
	l_description := 'null';
	l_drill_down_rep_1 := 'null';

        -- Item Description for item view by
        IF (p_view_by_dim = 'ITEM+ENI_ITEM') THEN
        l_description := ' v. description ';
        END IF;

        l_drill_down_rep_1 := get_drill_down (p_view_by_dim => p_view_by_dim, p_function_name => 'ISC_DEPOT_MTTR_TBL_REP');

        l_sel_clause :=
        'SELECT    '|| ISC_DEPOT_RPT_UTIL_PKG.get_viewby_select_clause (p_view_by_dim) || fnd_global.newline ||
		    l_description || ' BIV_ATTRIBUTE10 ';

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
		                                   			       , p_col_name      => 'BIV_ATTRIBUTE1'
		                                                               , p_alias_name    => 'BIV_ATTRIBUTE1'
		                                                               , p_total_flag    => 'N'
						                               , p_prefix        =>  NULL
						                               , p_suffix        =>  NULL
		                                                                ) || fnd_global.newline ;

	l_sel_clause := l_sel_clause ||
			',BIV_MEASURE11
	                 ,BIV_MEASURE1
		         ,BIV_MEASURE2
		    	 ,BIV_MEASURE12
		     	 ,BIV_MEASURE3
 			 ,BIV_MEASURE4
		    	 ,BIV_MEASURE21
		    	 ,BIV_MEASURE22
		    	 ,BIV_MEASURE23
		    	 ,BIV_MEASURE24
		    	 ,BIV_MEASURE27
		    	 ,BIV_MEASURE28
		    	 ,BIV_MEASURE29
		    	 ,BIV_MEASURE30 '|| fnd_global.newline;

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
	                                   			               , p_col_name      => 'BIV_MEASURE5'
	                                                                       , p_alias_name    => 'BIV_MEASURE5'
	                                                                       , p_total_flag    => 'N'
					                                       , p_prefix        =>  NULL
					                                       , p_suffix        =>  NULL
	                                                                       ) || fnd_global.newline ;

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
	                                   			               , p_col_name      => 'BIV_MEASURE25'
	                                                                       , p_alias_name    => 'BIV_MEASURE25'
	                                                                       , p_total_flag    => 'N'
					                                       , p_prefix        =>  NULL
					                                       , p_suffix        =>  NULL
	                                                                       ) || fnd_global.newline ;


	l_sel_clause := l_sel_clause || ' ,'||l_drill_down_rep_1||' BIV_DYNAMIC_URL1' || fnd_global.newline;

	l_sel_clause := l_sel_clause ||
	'FROM ( SELECT
		     rank() over (&ORDER_BY_CLAUSE'||' nulls last, '||p_view_by_col||') - 1 rnk
	           ,'||p_view_by_col;

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
		                                   			       , p_col_name      => 'BIV_ATTRIBUTE1'
		                                                               , p_alias_name    => 'BIV_ATTRIBUTE1'
		                                                               , p_total_flag    => 'N'
						                               , p_prefix        =>  NULL
						                               , p_suffix        =>  NULL
		                                                                ) || fnd_global.newline ;

	l_sel_clause := l_sel_clause ||
			',BIV_MEASURE11
	                 ,BIV_MEASURE1
		         ,BIV_MEASURE2
		    	 ,BIV_MEASURE12
		     	 ,BIV_MEASURE3
 			 ,BIV_MEASURE4
		    	 ,BIV_MEASURE21
		    	 ,BIV_MEASURE22
		    	 ,BIV_MEASURE23
		    	 ,BIV_MEASURE24
		    	 ,BIV_MEASURE27
		    	 ,BIV_MEASURE28
		    	 ,BIV_MEASURE29
		    	 ,BIV_MEASURE30 '|| fnd_global.newline;

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
	                                   			               , p_col_name      => 'BIV_MEASURE5'
	                                                                       , p_alias_name    => 'BIV_MEASURE5'
	                                                                       , p_total_flag    => 'N'
					                                       , p_prefix        =>  NULL
					                                       , p_suffix        =>  NULL
	                                                                       ) || fnd_global.newline ;

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
	                                   			               , p_col_name      => 'BIV_MEASURE25'
	                                                                       , p_alias_name    => 'BIV_MEASURE25'
	                                                                       , p_total_flag    => 'N'
					                                       , p_prefix        =>  NULL
					                                       , p_suffix        =>  NULL
	                                                                       ) || fnd_global.newline ;

	l_sel_clause := l_sel_clause ||
        'FROM ( SELECT  '  || fnd_global.newline ||
                         p_view_by_col || fnd_global.newline ||
	         ',' || 'NVL(p_ro_count,0) BIV_MEASURE11 ' || fnd_global.newline ||
	         ',' || 'NVL(c_ro_count,0) BIV_MEASURE1 ' || fnd_global.newline ||
	         ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_ro_count'
	                                               ,prior_col   => 'p_ro_count'
	                                               ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
	                                               || 'BIV_MEASURE2' || fnd_global.newline ||
	         ',' || '(p_time_to_repair/(decode(p_ro_count,0,to_number(NULL),p_ro_count))) BIV_MEASURE12 ' || fnd_global.newline ||
	         ',' || '(c_time_to_repair/(decode(c_ro_count,0,to_number(NULL),c_ro_count))) BIV_MEASURE3 ' || fnd_global.newline ||
	         ',' || poa_dbi_util_pkg.change_clause( cur_col     => '(c_time_to_repair/(decode(c_ro_count,0,to_number(NULL),c_ro_count)))'
	                                               ,prior_col   => '(p_time_to_repair/(decode(p_ro_count,0,to_number(NULL),p_ro_count)))'
	                                               ,change_type =>  'P') -- 'P' for Percent ; 'NP' for non percent
	                                               || 'BIV_MEASURE4' || fnd_global.newline ||
	         ',' || 'NVL(c_ro_count_total,0) BIV_MEASURE21 ' || fnd_global.newline ||
	         ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_ro_count_total'
	                                               ,prior_col   => 'p_ro_count_total'
	                                               ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
	                                                || 'BIV_MEASURE22' || fnd_global.newline ||
	         ',' || '(c_time_to_repair_total/(decode(c_ro_count_total,0,to_number(NULL),c_ro_count_total))) BIV_MEASURE23 ' || fnd_global.newline ||
	         ',' || poa_dbi_util_pkg.change_clause( cur_col     => '(c_time_to_repair_total/(decode(c_ro_count_total,0,to_number(NULL),c_ro_count_total)))'
	                                               ,prior_col   => '(p_time_to_repair_total/(decode(p_ro_count_total,0,to_number(NULL),p_ro_count_total)))'
	                                               ,change_type =>  'P') -- 'P' for Percent ; 'NP' for non percent
	                                                || 'BIV_MEASURE24' || fnd_global.newline ||
	         ',' || '(c_time_to_repair/(decode(c_ro_count,0,to_number(NULL),c_ro_count))) BIV_MEASURE27 ' || fnd_global.newline ||
	         ',' || '(p_time_to_repair/(decode(p_ro_count,0,to_number(NULL),p_ro_count))) BIV_MEASURE28 ' || fnd_global.newline ||
	         ',' || '(c_time_to_repair_total/(decode(c_ro_count_total,0,to_number(NULL),c_ro_count_total))) BIV_MEASURE29 ' || fnd_global.newline ||
	         ',' || '(p_time_to_repair_total/(decode(p_ro_count_total,0,to_number(NULL),p_ro_count_total))) BIV_MEASURE30 ' || fnd_global.newline;

	 l_sel_clause := l_sel_clause ||
	                 poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    => p_bucket_rec
	                                                        , p_col_name      => 'c_ttr_distribution'
	                                                        , p_alias_name    => 'BIV_MEASURE5'
	                                                        , p_total_flag    => 'N'
					                        , p_prefix        => 'NVL('
					                        , p_suffix        => ',0)'
	                                                        ) || fnd_global.newline ;

        l_sel_clause := l_sel_clause ||
   	  		poa_dbi_util_pkg.get_bucket_drill_url( p_bucket_rec
   	  						     , 'BIV_ATTRIBUTE1'
							     ,'''pFunctionName=ISC_DEPOT_MTTR_DTL_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&BIV_ATTRIBUTE1=-1&BIV_DR_BACKLOG_BUCKET+BIV_DR_BACKLOG_BUCKET='
							     , ''''
							     , p_add_bucket_num => 'Y');

	 l_sel_clause := l_sel_clause ||
	                 poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    => p_bucket_rec
	                                                         , p_col_name     => 'c_ttr_distribution'
	                                                         , p_alias_name   => 'BIV_MEASURE25'
 	                                                         , p_total_flag   => 'Y'
 	                                                         , p_prefix       => 'NVL('
					                         , p_suffix       => ',0)'
	                                                        ) || fnd_global.newline ;



RETURN l_sel_clause;

END GET_MTTR_TBL_SEL_CLAUSE;

FUNCTION get_drill_down (p_view_by_dim IN VARCHAR2,p_function_name IN VARCHAR2)
RETURN VARCHAR2
IS
	l_drill_down varchar2 (500);
BEGIN
	l_drill_down := 'null';
	IF (p_view_by_dim = 'ITEM+ENI_ITEM_VBH_CAT') THEN
		l_drill_down := 'decode(v.leaf_node_flag, ''Y'',
		''pFunctionName='|| p_function_name ||'&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y'',
		''pFunctionName='|| p_function_name ||'&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'') ';
	END IF;
	RETURN l_drill_down;
END get_drill_down ;

-- MEAN TIME TO REPAIR TREND REPORT

PROCEDURE GET_MTTR_TRD_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

        l_query                 ISC_DEPOT_RPT_UTIL_PKG .g_query_typ%type;
        l_view_by               ISC_DEPOT_RPT_UTIL_PKG .g_view_by_typ%type;
        l_view_by_col           ISC_DEPOT_RPT_UTIL_PKG .g_view_by_col_typ%type;
        l_xtd                   ISC_DEPOT_RPT_UTIL_PKG .g_xtd_typ%type;
        l_comparison_type       VARCHAR2(1);
        l_cur_suffix            VARCHAR2(2);
        l_col_tbl               poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl              poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_where_clause          ISC_DEPOT_RPT_UTIL_PKG .g_where_clause_typ%type;
        l_mv                    ISC_DEPOT_RPT_UTIL_PKG .g_mv_typ%type;
        l_mv_set                VARCHAR2(50);
        l_aggregation_flag      NUMBER;
        l_custom_rec            BIS_QUERY_ATTRIBUTES;
	l_mv_type		VARCHAR2(10);
	l_err_stage		VARCHAR2(32767);
	l_bucket_rec            bis_bucket_pub.bis_bucket_rec_type;
	l_debug_mode            VARCHAR2(1);
	l_module_name           ISC_DEPOT_RPT_UTIL_PKG .g_module_name_typ%type;

BEGIN
	l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
	l_module_name := FND_PROFILE.value('AFLOG_MODULE');

        -- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG .process_parameters (p_param            => p_param,
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
                                            p_mv_set           => 'MTTR',
                                            x_custom_output    => x_custom_output);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DR_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_TRD : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'ro_count' ,
                                     p_alias_name   => 'ro_count',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'time_to_repair' ,
                                     p_alias_name   => 'time_to_repair',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_bucket_columns(p_short_name   => 'ISC_DEPOT_MTTR'
                                          , p_col_tbl      => l_col_tbl
                                          , p_col_name     => 'time_to_repair'
                                          , p_alias_name   => 'ttr_distribution'
                                          , p_grand_total  => 'N'
                                          , p_prior_code   => poa_dbi_util_pkg.NO_PRIORS
                                          , p_to_date_type => 'XTD'
                                          , x_bucket_rec   => l_bucket_rec
                                           );


        l_query := GET_MTTR_TRD_SEL_CLAUSE (l_view_by,l_bucket_rec)
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
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_TRD : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the trend SQL
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
	l_err_stage := SQLERRM;
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ' || l_err_stage;
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_TRD : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

END GET_MTTR_TRD_SQL;

FUNCTION GET_MTTR_TRD_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_bucket_rec  IN bis_bucket_pub.bis_bucket_rec_type)
RETURN VARCHAR2
IS

        l_sel_clause                VARCHAR2(8000);
        l_view_by_col_name          VARCHAR2(120);
        l_description               VARCHAR2(30);

BEGIN

        l_sel_clause :=
        'SELECT  cal.name VIEWBY ' || fnd_global.newline ||
		 ',' || 'NVL(iset.p_ro_count,0) BIV_MEASURE11 ' || fnd_global.newline ||
                 ',' || 'NVL(iset.c_ro_count,0) BIV_MEASURE1 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'iset.c_ro_count'
                                                       ,prior_col   => 'iset.p_ro_count'
                                                       ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                       || 'BIV_MEASURE2' || fnd_global.newline ||
                 ',' || '(iset.p_time_to_repair/(decode(iset.p_ro_count,0,to_number(NULL),iset.p_ro_count))) BIV_MEASURE12 ' || fnd_global.newline ||
                 ',' || '(iset.c_time_to_repair/(decode(iset.c_ro_count,0,to_number(NULL),iset.c_ro_count))) BIV_MEASURE3 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => '(iset.c_time_to_repair/(decode(iset.c_ro_count,0,to_number(NULL),iset.c_ro_count)))'
                                                       ,prior_col   => '(iset.p_time_to_repair/(decode(iset.p_ro_count,0,to_number(NULL),iset.p_ro_count)))'
                                                       ,change_type =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                       || 'BIV_MEASURE4' || fnd_global.newline;

	l_sel_clause := l_sel_clause ||
	                poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec        => p_bucket_rec
	                                                        , p_col_name         => 'iset.c_ttr_distribution'
	                                                        , p_alias_name       => 'BIV_MEASURE5'
	                                                        , p_total_flag       => 'N'
					                        , p_prefix           => 'NVL('
					                        , p_suffix           => ',0)'
                                                                ) || fnd_global.newline ;

RETURN l_sel_clause;

END GET_MTTR_TRD_SEL_CLAUSE;

-- MEAN TIME TO REPAIR DETAIL REPORT

PROCEDURE GET_MTTR_DTL_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
		               x_custom_sql OUT NOCOPY VARCHAR2,
			       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

        l_query                 ISC_DEPOT_RPT_UTIL_PKG .g_query_typ%type;
        l_view_by               ISC_DEPOT_RPT_UTIL_PKG .g_view_by_typ%type;
        l_view_by_col           ISC_DEPOT_RPT_UTIL_PKG .g_view_by_col_typ%type;
        l_xtd                   ISC_DEPOT_RPT_UTIL_PKG .g_xtd_typ%type;
        l_comparison_type       VARCHAR2(1);
        l_cur_suffix            VARCHAR2(2);
        l_col_tbl               poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl              poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_where_clause          ISC_DEPOT_RPT_UTIL_PKG .g_where_clause_typ%type;
        l_mv                    ISC_DEPOT_RPT_UTIL_PKG .g_mv_typ%type;
        l_mv_set                VARCHAR2(50);
        l_aggregation_flag      NUMBER;
        l_custom_rec            BIS_QUERY_ATTRIBUTES;
	l_mv_type		VARCHAR2(10);
	l_err_stage		VARCHAR2(32767);
	l_debug_mode            VARCHAR2(1);
	l_module_name           ISC_DEPOT_RPT_UTIL_PKG .g_module_name_typ%type;

BEGIN
	l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
	l_module_name := FND_PROFILE.value('AFLOG_MODULE');

        -- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG .process_parameters (p_param       => p_param,
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
                                            p_mv_set           => 'MDTL',
                                            x_custom_output    => x_custom_output);

       IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DR_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_DTL_TBL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

        l_query := GET_MTTR_DTL_SEL_CLAUSE(l_mv,l_where_clause);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : ' || l_query;
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_DTL_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

        x_custom_sql := l_query;

EXCEPTION

        WHEN OTHERS THEN
	l_err_stage := SQLERRM;
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ' || l_err_stage;
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_DTL_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

END GET_MTTR_DTL_TBL_SQL;

FUNCTION GET_MTTR_DTL_SEL_CLAUSE(l_mv ISC_DEPOT_RPT_UTIL_PKG.g_mv_typ%type ,l_where_clause ISC_DEPOT_RPT_UTIL_PKG.g_where_clause_typ%type)
RETURN VARCHAR2
IS

        l_sel_clause                VARCHAR2(8000);

BEGIN

        l_sel_clause :=
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
		,BIV_DATE3
		,BIV_MEASURE2
		,BIV_MEASURE3
		,BIV_MEASURE4
		,''pFunctionName=CSD_RO_DETAILS&csdInvOrgId=''||BIV_MEASURE4||''&csdRepairLineId=''||BIV_MEASURE3 BIV_DYNAMIC_URL1
		,' || ISC_DEPOT_RPT_UTIL_PKG.get_service_request_url || '|| BIV_ATTRIBUTE8 BIV_DYNAMIC_URL2
	 FROM (
		SELECT
	 		 rank() over (&ORDER_BY_CLAUSE nulls last,repair_line_id ) - 1 rnk
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
			,BIV_DATE3
			,BIV_MEASURE2
			,BIV_MEASURE3
			,BIV_MEASURE4
	  FROM ( SELECT fact1.repair_line_id repair_line_id' || fnd_global.newline ||
			 ',' ||	' fact.repair_number BIV_ATTRIBUTE1 ' || fnd_global.newline ||
        	         ',' || ' fact.incident_number BIV_ATTRIBUTE2 ' || fnd_global.newline ||
        	         ',' || ' crt.name BIV_ATTRIBUTE3 ' || fnd_global.newline ||
        	         ',' || ' eiov.value BIV_ATTRIBUTE4 ' || fnd_global.newline ||
        	         ',' || ' eiov.description BIV_ATTRIBUTE5 ' || fnd_global.newline ||
        	         ',' || ' mum.unit_of_measure BIV_ATTRIBUTE6 ' || fnd_global.newline ||
        	         ',' || ' fact.incident_id    BIV_ATTRIBUTE8 ' || fnd_global.newline ||
        	         ',' || ' fact.repair_line_id  BIV_MEASURE3 ' || fnd_global.newline ||
        	         ',' || ' fact.master_organization_id    BIV_MEASURE4 ' || fnd_global.newline ||
        	         ',' || ' fact.quantity BIV_MEASURE1 ' || fnd_global.newline ||
        	         ',' || ' fact.serial_number BIV_ATTRIBUTE7 ' || fnd_global.newline ||
        	         ',' || ' fact.promise_date BIV_DATE1 ' || fnd_global.newline ||
        	         ',' || ' trunc(fact1.repair_start_date) BIV_DATE2 ' || fnd_global.newline ||
        	         ',' || ' trunc(fact1.repair_end_date) BIV_DATE3 ' || fnd_global.newline ||
        	         ',' || ' fact1.time_to_repair BIV_MEASURE2 ' || fnd_global.newline ||
        	         '        FROM '|| fnd_global.newline || l_mv ||
        	         '        ISC_DR_REPAIR_ORDERS_F fact' || fnd_global.newline ||
        	         ',' || ' ISC_DR_MTTR_F fact1' || fnd_global.newline ||
        	         ',' || ' MTL_UNITS_OF_MEASURE_VL mum' || fnd_global.newline ||
        	         ',' || ' ENI_ITEM_V eiov' || fnd_global.newline ||
        	         '        WHERE fact.dbi_date_closed BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ' || fnd_global.newline ||
        	         '        AND fact.item_org_id = eiov.id' || fnd_global.newline ||
        	         '        AND fact.repair_line_id = fact1.repair_line_id' || fnd_global.newline ||
			 '	  AND fact1.time_to_repair >= 0' || fnd_global.newline ||
        	         '        AND mum.uom_code = fact.uom_code' || fnd_global.newline || l_where_clause
        	  	     || ' ) ) where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
				  ORDER BY rnk' ;

RETURN l_sel_clause;

END GET_MTTR_DTL_SEL_CLAUSE;

-- MEAN TIME TO REPAIR DISTRIBUTION STATUS REPORT

PROCEDURE GET_MTTR_DIST_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                                x_custom_sql OUT NOCOPY VARCHAR2,
                                x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
        l_query                 ISC_DEPOT_RPT_UTIL_PKG .g_query_typ%type;
        l_view_by               ISC_DEPOT_RPT_UTIL_PKG .g_view_by_typ%type;
        l_view_by_col           ISC_DEPOT_RPT_UTIL_PKG .g_view_by_col_typ%type;
        l_xtd                   ISC_DEPOT_RPT_UTIL_PKG .g_xtd_typ%type;
        l_comparison_type       VARCHAR2(1);
        l_cur_suffix            VARCHAR2(2);
        l_col_tbl               poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl              poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_where_clause          ISC_DEPOT_RPT_UTIL_PKG .g_where_clause_typ%type;
        l_mv                    ISC_DEPOT_RPT_UTIL_PKG .g_mv_typ%type;
        l_mv_set                VARCHAR2(50);
        l_aggregation_flag      NUMBER;
        l_custom_rec            BIS_QUERY_ATTRIBUTES;
	l_mv_type		VARCHAR2(10);
	l_err_stage		VARCHAR2(32767);
	l_bucket_rec            bis_bucket_pub.bis_bucket_rec_type;
	l_debug_mode            VARCHAR2(1);
	l_module_name           ISC_DEPOT_RPT_UTIL_PKG .g_module_name_typ%type;

BEGIN
	l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
	l_module_name := FND_PROFILE.value('AFLOG_MODULE');

        -- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG .process_parameters ( p_param            => p_param,
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
                                             	p_mv_set           => 'MTTR',
                                             	x_custom_output    => x_custom_output);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DR_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_DIST_TBL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'ro_count' ,
                                     p_alias_name   => 'ro_count',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'time_to_repair' ,
                                     p_alias_name   => 'time_to_repair',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_bucket_columns(p_short_name   => 'ISC_DEPOT_MTTR'
                                          , p_col_tbl      =>  l_col_tbl
                                          , p_col_name     => 'time_to_repair'
                                          , p_alias_name   => 'ttr_distribution'
                                          , p_grand_total  => 'Y'
                                          , p_prior_code   =>  poa_dbi_util_pkg.NO_PRIORS
                                          , p_to_date_type => 'XTD'
                                          , x_bucket_rec   =>  l_bucket_rec
                                           );

        l_query := GET_MTTR_DIST_TBL_SEL_CLAUSE (l_view_by,l_view_by_col,l_bucket_rec)
                || ' from
              ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
                                                    p_where_clause    => l_where_clause,
                                                    p_join_tables     => l_join_tbl,
                                                    p_use_windowing   => 'Y',
                                                    p_col_name        => l_col_tbl,
                                                    p_use_grpid       => 'N',
                                                    p_paren_count     => 3,
                                                    p_filter_where    => NULL,
                                                    p_generate_viewby => 'Y',
                                                    p_in_join_tables  => NULL);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
           l_err_stage:='The query is : ' || l_query;
           ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_DIST_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the status SQL
        poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

        -- Passing AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':AGGREGATION_FLAG';
        l_custom_rec.attribute_type     :=  BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_value     := l_aggregation_flag;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        x_custom_sql := l_query;

EXCEPTION

        WHEN OTHERS THEN
	l_err_stage := SQLERRM;
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ';
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_DIST_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

END GET_MTTR_DIST_TBL_SQL;

FUNCTION GET_MTTR_DIST_TBL_SEL_CLAUSE(p_view_by_dim IN VARCHAR2,p_view_by_col IN VARCHAR2,p_bucket_rec  IN bis_bucket_pub.bis_bucket_rec_type)
RETURN VARCHAR2
IS
        l_sel_clause                VARCHAR2(8000);
        l_view_by_col_name          VARCHAR2(120);
        l_description               VARCHAR2(30);
        l_drill_down_rep_1          VARCHAR2(500);

BEGIN

	l_description := 'null';
	l_drill_down_rep_1 := 'null';

        -- Item Description for item view by
        IF (p_view_by_dim = 'ITEM+ENI_ITEM') THEN
        l_description := ' v. description ';
        END IF;

        l_drill_down_rep_1 := get_drill_down (p_view_by_dim => p_view_by_dim, p_function_name =>'ISC_DEPOT_MTTR_DIST_TBL_REP');

        l_sel_clause :=
        'SELECT    '|| ISC_DEPOT_RPT_UTIL_PKG.get_viewby_select_clause (p_view_by_dim) || fnd_global.newline ||
		    l_description || ' BIV_ATTRIBUTE10
		    ,BIV_MEASURE11
		    ,BIV_MEASURE1
		    ,BIV_MEASURE2
		    ,BIV_MEASURE12
		    ,BIV_MEASURE3
		    ,BIV_MEASURE4
		    ,BIV_MEASURE21
		    ,BIV_MEASURE22
		    ,BIV_MEASURE23
		    ,BIV_MEASURE24';

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
	                                   			               , p_col_name      => 'BIV_MEASURE5'
	                                                                       , p_alias_name    => 'BIV_MEASURE5'
	                                                                       , p_total_flag    => 'N'
					                                       , p_prefix        =>  NULL
					                                       , p_suffix        =>  NULL
	                                                                       ) || fnd_global.newline ;

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
	                                   			               , p_col_name      => 'BIV_MEASURE25'
	                                                                       , p_alias_name    => 'BIV_MEASURE25'
	                                                                       , p_total_flag    => 'N'
					                                       , p_prefix        =>  NULL
					                                       , p_suffix        =>  NULL
	                                                                       ) || fnd_global.newline ;
	l_sel_clause := l_sel_clause || ' ,'||l_drill_down_rep_1||' BIV_DYNAMIC_URL1' || fnd_global.newline;

	l_sel_clause := l_sel_clause ||
	'FROM ( SELECT rank() over (&ORDER_BY_CLAUSE'||' nulls last, '||p_view_by_col||' ) - 1 rnk
	           ,'||p_view_by_col||'
		    ,BIV_MEASURE11
		    ,BIV_MEASURE1
		    ,BIV_MEASURE2
		    ,BIV_MEASURE12
		    ,BIV_MEASURE3
		    ,BIV_MEASURE4
		    ,BIV_MEASURE21
		    ,BIV_MEASURE22
		    ,BIV_MEASURE23
		    ,BIV_MEASURE24';

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
	                                   			               , p_col_name      => 'BIV_MEASURE5'
	                                                                       , p_alias_name    => 'BIV_MEASURE5'
	                                                                       , p_total_flag    => 'N'
					                                       , p_prefix        =>  NULL
					                                       , p_suffix        =>  NULL
	                                                                       ) || fnd_global.newline ;

	l_sel_clause := l_sel_clause || poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec    =>  p_bucket_rec
	                                   			               , p_col_name      => 'BIV_MEASURE25'
	                                                                       , p_alias_name    => 'BIV_MEASURE25'
	                                                                       , p_total_flag    => 'N'
					                                       , p_prefix        =>  NULL
					                                       , p_suffix        =>  NULL
	                                                                       ) || fnd_global.newline ;

        l_sel_clause := l_sel_clause || 'FROM ( SELECT  '  || fnd_global.newline ||
                     p_view_by_col || fnd_global.newline ||
                 ',' || 'NVL(p_ro_count,0) BIV_MEASURE11 ' || fnd_global.newline ||
                 ',' || 'NVL(c_ro_count,0) BIV_MEASURE1 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_ro_count'
                                                       ,prior_col   => 'p_ro_count'
                                                       ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                       || 'BIV_MEASURE2' || fnd_global.newline ||
                 ',' || '(p_time_to_repair/(decode(p_ro_count,0,to_number(NULL),p_ro_count))) BIV_MEASURE12 ' || fnd_global.newline ||
                 ',' || '(c_time_to_repair/(decode(c_ro_count,0,to_number(NULL),c_ro_count))) BIV_MEASURE3 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => '(c_time_to_repair/(decode(c_ro_count,0,to_number(NULL),c_ro_count)))'
                                                       ,prior_col   => '(p_time_to_repair/(decode(p_ro_count,0,to_number(NULL),p_ro_count)))'
                                                       ,change_type =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                       || 'BIV_MEASURE4' || fnd_global.newline ||
                 ',' || 'NVL(c_ro_count_total,0) BIV_MEASURE21 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'c_ro_count_total'
                                                       ,prior_col   => 'p_ro_count_total'
                                                       ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                       || 'BIV_MEASURE22' || fnd_global.newline ||
                 ',' || '(c_time_to_repair_total/(decode(c_ro_count_total,0,to_number(NULL),c_ro_count_total))) BIV_MEASURE23 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => '(c_time_to_repair_total/(decode(c_ro_count_total,0,to_number(NULL),c_ro_count_total)))'
                                                       ,prior_col   => '(p_time_to_repair_total/(decode(p_ro_count_total,0,to_number(NULL),p_ro_count_total)))'
                                                       ,change_type =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                       || 'BIV_MEASURE24' || fnd_global.newline;

	 l_sel_clause := l_sel_clause ||
	                 poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec       => p_bucket_rec
	                                                  	, p_col_name         => '(100/(decode(c_ro_count,0,to_number(NULL),c_ro_count))) * c_ttr_distribution'
	                                                  	, p_alias_name       => 'BIV_MEASURE5'
	                                                  	, p_total_flag       => 'N'
					                        , p_prefix           => NULL
					                        , p_suffix           => NULL
 	                                                  	) || fnd_global.newline ;

	 l_sel_clause := l_sel_clause ||
	                 poa_dbi_util_pkg.get_bucket_outer_query(  p_bucket_rec       => p_bucket_rec
	                                                         , p_col_name         => '(100/(decode(c_ro_count_total,0,to_number(NULL),c_ro_count_total))) * c_ttr_distribution'
	                                                         , p_alias_name       => 'BIV_MEASURE25'
	                                                         , p_total_flag       => 'Y'
					                         , p_prefix           => NULL
					                         , p_suffix           => NULL
 	                                                         ) || fnd_global.newline ;

RETURN l_sel_clause;

END GET_MTTR_DIST_TBL_SEL_CLAUSE;

-- MEAN TIME TO REPAIR DISTRIBUTION TREND REPORT

PROCEDURE GET_MTTR_DIST_TRD_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

        l_query                 ISC_DEPOT_RPT_UTIL_PKG .g_query_typ%type;
        l_view_by               ISC_DEPOT_RPT_UTIL_PKG .g_view_by_typ%type;
        l_view_by_col           ISC_DEPOT_RPT_UTIL_PKG .g_view_by_col_typ%type;
        l_xtd                   ISC_DEPOT_RPT_UTIL_PKG .g_xtd_typ%type;
        l_comparison_type       VARCHAR2(1);
        l_cur_suffix            VARCHAR2(2);
        l_col_tbl               poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl              poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_where_clause          ISC_DEPOT_RPT_UTIL_PKG .g_where_clause_typ%type;
        l_mv                    ISC_DEPOT_RPT_UTIL_PKG .g_mv_typ%type;
        l_mv_set                VARCHAR2(50);
        l_aggregation_flag      NUMBER;
        l_custom_rec            BIS_QUERY_ATTRIBUTES;
	l_mv_type		VARCHAR2(10);
	l_err_stage		VARCHAR2(32767);
	l_bucket_rec            bis_bucket_pub.bis_bucket_rec_type;
	l_debug_mode            VARCHAR2(1);
	l_module_name           ISC_DEPOT_RPT_UTIL_PKG .g_module_name_typ%type;

BEGIN
	l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
	l_module_name := FND_PROFILE.value('AFLOG_MODULE');

        -- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG .process_parameters (p_param            => p_param,
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
                                            p_mv_set           => 'MTTR',
                                            x_custom_output    => x_custom_output);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DR_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_DIST_TRD : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'ro_count' ,
                                     p_alias_name   => 'ro_count',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'time_to_repair' ,
                                     p_alias_name   => 'time_to_repair',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_bucket_columns(p_short_name   => 'ISC_DEPOT_MTTR'
                                          , p_col_tbl      => l_col_tbl
                                          , p_col_name     => 'time_to_repair'
                                          , p_alias_name   => 'ttr_distribution'
                                          , p_grand_total  => 'N'
                                          , p_prior_code   => poa_dbi_util_pkg.NO_PRIORS
                                          , p_to_date_type => 'XTD'
                                          , x_bucket_rec   => l_bucket_rec
                                           );

        l_query := GET_MTTR_DIST_TRD_SEL_CLAUSE (l_view_by,l_bucket_rec)
                || ' from
              ' || poa_dbi_template_pkg.trend_sql(p_xtd             => l_xtd,
                                                  p_comparison_type     => l_comparison_type,
                                                  p_fact_name           => l_mv,
                                                  p_where_clause        => l_where_clause,
                                                  p_col_name            => l_col_tbl,
                                                  p_use_grpid           => 'N',
                                                  p_in_join_tables      => NULL);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : ' || l_query;
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_DIST_TRD : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the trend SQL
    	poa_dbi_util_pkg.get_custom_trend_binds (p_xtd => l_xtd,
    					         p_comparison_type => l_comparison_type,
                                                 x_custom_output => x_custom_output);
        -- Passing AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name      :=':AGGREGATION_FLAG';
        l_custom_rec.attribute_type      := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_value     := l_aggregation_flag;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        x_custom_sql := l_query;
EXCEPTION

         WHEN OTHERS THEN
 	l_err_stage := SQLERRM;
         IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
             l_err_stage:='The exception is : ' || l_err_stage;
             ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_MTTR_DIST_TRD : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
         END IF;


END GET_MTTR_DIST_TRD_SQL;

FUNCTION GET_MTTR_DIST_TRD_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_bucket_rec  IN bis_bucket_pub.bis_bucket_rec_type)
RETURN VARCHAR2
IS

        l_sel_clause                VARCHAR2(8000);
        l_view_by_col_name          VARCHAR2(120);
        l_description               VARCHAR2(30);

BEGIN
        l_sel_clause :=
        'SELECT  cal.name VIEWBY ' || fnd_global.newline ||
		 ',' || 'NVL(iset.p_ro_count,0) BIV_MEASURE11 ' || fnd_global.newline ||
                 ',' || 'NVL(iset.c_ro_count,0) BIV_MEASURE1 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => 'iset.c_ro_count'
                                                       ,prior_col   => 'iset.p_ro_count'
                                                       ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
                                                       || 'BIV_MEASURE2' || fnd_global.newline ||
                 ',' || '(iset.p_time_to_repair/(decode(iset.p_ro_count,0,to_number(NULL),iset.p_ro_count))) BIV_MEASURE12 ' || fnd_global.newline ||
                 ',' || '(iset.c_time_to_repair/(decode(iset.c_ro_count,0,to_number(NULL),iset.c_ro_count))) BIV_MEASURE3 ' || fnd_global.newline ||
                 ',' || poa_dbi_util_pkg.change_clause( cur_col     => '(iset.c_time_to_repair/(decode(iset.c_ro_count,0,to_number(NULL),iset.c_ro_count)))'
                                                       ,prior_col   => '(iset.p_time_to_repair/(decode(iset.p_ro_count,0,to_number(NULL),iset.p_ro_count)))'
                                                       ,change_type =>  'P') -- 'P' for Percent ; 'NP' for non percent
                                                       || 'BIV_MEASURE4' || fnd_global.newline;

	l_sel_clause := l_sel_clause ||
	                poa_dbi_util_pkg.get_bucket_outer_query( p_bucket_rec        => p_bucket_rec
	                                                        , p_col_name         =>'(100/(decode(iset.c_ro_count,0,to_number(NULL),iset.c_ro_count))) * iset.c_ttr_distribution'
	                                                        , p_alias_name       =>'BIV_MEASURE5'
	                                                        , p_total_flag       =>'N'
					                        , p_prefix           => NULL
					                        , p_suffix           => NULL
                                                                ) || fnd_global.newline ;

RETURN l_sel_clause;

END GET_MTTR_DIST_TRD_SEL_CLAUSE;

-- REPAIR ORDER SERVICE CODE SUMMARY REPORT

PROCEDURE GET_SRVC_TBL_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
        l_query                 ISC_DEPOT_RPT_UTIL_PKG .g_query_typ%type;
        l_view_by               ISC_DEPOT_RPT_UTIL_PKG .g_view_by_typ%type;
        l_view_by_col           ISC_DEPOT_RPT_UTIL_PKG .g_view_by_col_typ%type;
        l_xtd                   ISC_DEPOT_RPT_UTIL_PKG .g_xtd_typ%type;
        l_comparison_type       VARCHAR2(1);
        l_cur_suffix            VARCHAR2(2);
        l_col_tbl               poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl              poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_where_clause          ISC_DEPOT_RPT_UTIL_PKG .g_where_clause_typ%type;
        l_mv                    ISC_DEPOT_RPT_UTIL_PKG .g_mv_typ%type;
        l_mv_set                VARCHAR2(50);
        l_aggregation_flag      NUMBER;
        l_custom_rec            BIS_QUERY_ATTRIBUTES;
	l_mv_type		VARCHAR2(10);
	l_err_stage		VARCHAR2(32767);
	l_debug_mode            VARCHAR2(1);
	l_module_name           ISC_DEPOT_RPT_UTIL_PKG .g_module_name_typ%type;

BEGIN
	l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
	l_module_name := FND_PROFILE.value('AFLOG_MODULE');

        -- clear out the tables.
        l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters
        ISC_DEPOT_RPT_UTIL_PKG .process_parameters (p_param            => p_param,
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
                                            	 p_mv_set           => 'SRVC',
                                            	 x_custom_output    => x_custom_output);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After calling  DR_DBI_RPT_UTIL_PKG.process_parameters';
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_SRVC_TBL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

	-- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'ro_count',
                                     p_alias_name   => 'ro_count',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After initializing';
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_SRVC_TBL : ' ,l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;


	        l_query := GET_SRVC_TBL_SEL_CLAUSE(l_view_by,l_view_by_col)
                || ' from
              ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
                                                        p_where_clause    => l_where_clause,
                                                        p_join_tables     => l_join_tbl,
                                                        p_use_windowing   => 'Y',
                                                        p_col_name        => l_col_tbl,
                                                        p_use_grpid       => 'N',
                                                        p_paren_count     => 3,
                                                        p_filter_where    => NULL,
                                                        p_generate_viewby => 'Y',
                                                        p_in_join_tables  => NULL);

	IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The query is : ' || l_query;
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_SRVC_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the status SQL
        poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

        -- Passing AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':AGGREGATION_FLAG';
        l_custom_rec.attribute_type     :=  BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        l_custom_rec.attribute_value     := l_aggregation_flag;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;
        x_custom_sql := l_query;

EXCEPTION

        WHEN OTHERS THEN
	l_err_stage := SQLERRM;
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ' ||l_err_stage;
            ISC_DEPOT_RPT_UTIL_PKG .write('BIS_ISC_DEPOT_SRVC_TBL : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG .C_DEBUG_LEVEL);
        END IF;

END GET_SRVC_TBL_SQL;

FUNCTION GET_SRVC_TBL_SEL_CLAUSE(p_view_by_dim VARCHAR2,p_view_by_col IN VARCHAR2)
RETURN VARCHAR2
IS

        l_sel_clause                VARCHAR2(8000);
        l_percent                   VARCHAR2(500);
        l_percent_total             VARCHAR2(500);

BEGIN
	l_percent    := '(c_ro_count/(decode(c_ro_count_total,0,to_number(NULL),c_ro_count_total))) * 100';
	l_percent_total := '(c_ro_count_total/(decode(c_ro_count_total,0,to_number(NULL),c_ro_count_total))) * 100';


        l_sel_clause :=
        'SELECT    '|| ISC_DEPOT_RPT_UTIL_PKG.get_viewby_select_clause (p_view_by_dim) || fnd_global.newline ||
	           ' v.description BIV_ATTRIBUTE6 ' || fnd_global.newline ||
		   ',BIV_MEASURE11
		    ,BIV_MEASURE1
		    ,BIV_MEASURE2
		    ,BIV_MEASURE12
		    ,BIV_MEASURE5
		    ,BIV_MEASURE6
		    ,BIV_MEASURE7' || fnd_global.newline ||
	'FROM ( SELECT
		     rank() over (&ORDER_BY_CLAUSE'||' nulls last ,'||p_view_by_col||' ) - 1 rnk
 	           ,'||p_view_by_col||'
         	   ,BIV_MEASURE11
		   ,BIV_MEASURE1
		   ,BIV_MEASURE2
		   ,BIV_MEASURE12
		   ,BIV_MEASURE5
		   ,BIV_MEASURE6
		   ,BIV_MEASURE7' || fnd_global.newline ||
        'FROM ( SELECT  '  || fnd_global.newline ||
                     p_view_by_col || fnd_global.newline ||
                 ',' || ' NVL(p_ro_count,0) BIV_MEASURE11' || fnd_global.newline ||
 	         ',' || ' NVL(c_ro_count,0) BIV_MEASURE1 ' || fnd_global.newline ||
                 ',' ||   poa_dbi_util_pkg.change_clause( cur_col     => 'c_ro_count'
                                                         ,prior_col   => 'p_ro_count'
                                                         ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
	                                                || ' BIV_MEASURE2' || fnd_global.newline ||
	         ',' ||  l_percent || ' BIV_MEASURE12' || fnd_global.newline ||
	         ',' || ' NVL(c_ro_count_total,0) BIV_MEASURE5 ' || fnd_global.newline ||
                 ',' ||   poa_dbi_util_pkg.change_clause( cur_col     => 'c_ro_count_total'
                                                         ,prior_col   => 'p_ro_count_total'
                                                         ,change_type =>  'NP') -- 'P' for Percent ; 'NP' for non percent
	                                                || ' BIV_MEASURE6' || fnd_global.newline ||
	         ',' || l_percent_total || ' BIV_MEASURE7' || fnd_global.newline ;

RETURN l_sel_clause;

END GET_SRVC_TBL_SEL_CLAUSE;

END ISC_DEPOT_MTTR_PKG;

/
