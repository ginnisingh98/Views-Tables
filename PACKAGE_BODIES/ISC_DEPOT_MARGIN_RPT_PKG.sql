--------------------------------------------------------
--  DDL for Package Body ISC_DEPOT_MARGIN_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DEPOT_MARGIN_RPT_PKG" AS
--$Header: iscdepotmrgrqb.pls 120.0 2005/05/25 17:34:31 appldev noship $

/*++++++++++++++++++++++++++++++++++++++++*/
/* Function and procedure declarations in this file but not in spec*/
/*++++++++++++++++++++++++++++++++++++++++*/

FUNCTION get_ro_mrg_tbl_sel_clause(p_view_by_dim IN VARCHAR2, p_view_by_col IN VARCHAR2)
    return VARCHAR2;

FUNCTION get_ro_mrg_trd_sel_clause(p_view_by_dim IN VARCHAR2)
    return VARCHAR2;

FUNCTION get_chg_summ_tbl_sel_clause(p_view_by_dim IN VARCHAR2, p_view_by_col IN VARCHAR2)
    return VARCHAR2;

FUNCTION get_chg_summ_trd_sel_clause(p_view_by_dim IN VARCHAR2)
    return VARCHAR2;

FUNCTION get_cst_summ_tbl_sel_clause(p_view_by_dim IN VARCHAR2, p_view_by_col IN VARCHAR2)
    return VARCHAR2;

FUNCTION get_cst_summ_trd_sel_clause(p_view_by_dim IN VARCHAR2)
    return VARCHAR2;

FUNCTION get_mrg_summ_tbl_sel_clause(p_view_by_dim IN VARCHAR2, p_view_by_col IN VARCHAR2)
    return VARCHAR2;

FUNCTION get_mrg_summ_trd_sel_clause(p_view_by_dim IN VARCHAR2)
    return VARCHAR2;

FUNCTION get_mrg_dtl_sel_clause(p_curr_suffix IN VARCHAR2)
    return VARCHAR2;


/*----------------------------------
Repair Order Margin Table
----------------------------------*/

PROCEDURE get_ro_mrg_tbl_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS

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
    l_mv_type		    VARCHAR2(10);
    l_err_stage		    VARCHAR2(500);
    l_debug_mode 	    VARCHAR2(1);
    l_module_name 	    ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type;

BEGIN
    l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_module_name := FND_PROFILE.value('AFLOG_MODULE');
    l_comparison_type  := 'Y';
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
                                             p_mv_set           => 'MARGIN',
                                             x_custom_output    => x_custom_output);

    -- The measure columns that need to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'nvl(material_charges_' || l_cur_suffix ||
                                 		',0) + nvl(labor_charges_' || l_cur_suffix ||
                                 		',0) + nvl(expense_charges_' || l_cur_suffix || ',0)',
                                 p_alias_name => 'charges',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'nvl(material_cost_' || l_cur_suffix ||
                                 		',0) + nvl(labor_cost_' || l_cur_suffix ||
                                 		',0) + nvl(expense_cost_' || l_cur_suffix || ',0)',
                                 p_alias_name => 'costs',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    l_join_tbl(l_join_tbl.count).additional_where_clause := l_join_tbl(l_join_tbl.count).additional_where_clause;


    -- construct the query
    l_query := get_ro_mrg_tbl_sel_clause (l_view_by, l_view_by_col)
          || ' from
        ' || poa_dbi_template_pkg.status_sql (p_fact_name 	=> l_mv,
                                              p_where_clause 	=> l_where_clause,
                                              p_join_tables 	=> l_join_tbl,
                                              p_use_windowing 	=> 'Y',
                                              p_col_name 	=> l_col_tbl,
                                              p_use_grpid 	=> 'N',
                                              p_paren_count     => 3,
                                              p_filter_where    => '(BIV_MEASURE1 > 0 OR BIV_MEASURE2 > 0 OR BIV_MEASURE4 > 0 OR BIV_MEASURE5 > 0)',
                                              p_generate_viewby => 'Y',
                                              p_in_join_tables  => NULL);

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

    l_custom_rec.attribute_name := ':AGGREGATION_FLAG';
    l_custom_rec.attribute_value     := l_aggregation_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;
EXCEPTION
        WHEN OTHERS THEN
	l_err_stage := SQLERRM;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ';
            ISC_DEPOT_RPT_UTIL_PKG.write('get_ro_mrg_tbl_sql : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END get_ro_mrg_tbl_sql;

FUNCTION get_ro_mrg_tbl_sel_clause (p_view_by_dim IN VARCHAR2, p_view_by_col IN VARCHAR2)
    return VARCHAR2
IS

l_sel_clause varchar2(8000);
l_p_margin varchar2 (500);
l_c_margin varchar2 (500);
l_p_margin_total varchar2 (500);
l_c_margin_total varchar2 (500);
l_p_margin_percent varchar2 (500);
l_c_margin_percent varchar2 (500);
l_p_margin_percent_total varchar2 (500);
l_c_margin_percent_total varchar2 (500);
l_description varchar2(30);

l_cat_drill_down varchar2(500);

BEGIN
  l_description   := 'null';
  l_cat_drill_down := 'null';

  l_p_margin := '(NVL (p_charges, 0) - NVL (p_costs, 0))';
  l_c_margin := '(NVL (c_charges, 0) - NVL (c_costs, 0))';
  l_p_margin_total := '(NVL (p_charges_total, 0) - NVL (p_costs_total, 0))';
  l_c_margin_total := '(NVL (c_charges_total, 0) - NVL (c_costs_total, 0))';
  l_p_margin_percent := poa_dbi_util_pkg.rate_clause (l_p_margin, 'NVL (p_charges, 0)', 'P');
  l_c_margin_percent := poa_dbi_util_pkg.rate_clause (l_c_margin, 'NVL (c_charges, 0)', 'P');
  l_p_margin_percent_total := poa_dbi_util_pkg.rate_clause (l_p_margin_total, 'NVL (p_charges_total, 0)', 'P');
  l_c_margin_percent_total := poa_dbi_util_pkg.rate_clause (l_c_margin_total, 'NVL (c_charges_total, 0)', 'P');


  IF p_view_by_dim = 'ITEM+ENI_ITEM' THEN
        l_description := 'v.description';
  END IF;

  IF (p_view_by_dim = 'ITEM+ENI_ITEM_VBH_CAT') THEN
	l_cat_drill_down := 'decode(v.leaf_node_flag, ''Y'', ' ||
		'''pFunctionName=ISC_DEPOT_RO_MARGIN_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y'', ' ||
		'''pFunctionName=ISC_DEPOT_RO_MARGIN_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'') ';
  END IF;

  l_sel_clause :=
    	' SELECT ' ||
    	ISC_DEPOT_RPT_UTIL_PKG.get_viewby_select_clause (p_view_by_dim) || fnd_global.newline ||
    	l_description || ' BIV_ATTRIBUTE1 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE1 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE5 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE9 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE10 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE11 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE12 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE13 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE14 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE15 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE16 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE17 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE18 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE19 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE20 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE21 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE22 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE23 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE24 ' || fnd_global.newline || ', ' ||
	 l_cat_drill_down || ' BIV_DYNAMIC_URL1 ' || fnd_global.newline ||
	'FROM ( SELECT   ' ||
	' rank() over (&ORDER_BY_CLAUSE'||' nulls last, '|| p_view_by_col ||' ) - 1 rnk' || fnd_global.newline || ', ' ||
	p_view_by_col || fnd_global.newline || ', ' ||
    	'BIV_MEASURE1 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE5 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE9 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE10 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE11 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE12 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE13 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE14 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE15 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE16 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE17 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE18 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE19 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE20 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE21 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE22 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE23 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE24 ' || fnd_global.newline ||
	' FROM (SELECT ' || p_view_by_col || fnd_global.newline || ', ' ||
    	 'NVL (p_charges, 0) BIV_MEASURE1 ' || fnd_global.newline || ', ' ||
    	 'NVL (c_charges, 0) BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
    	 poa_dbi_util_pkg.change_clause ('c_charges', 'p_charges') || ' BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
    	 'NVL (p_costs, 0) BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_costs, 0) BIV_MEASURE5 ' || fnd_global.newline || ', ' ||
    	 poa_dbi_util_pkg.change_clause ('c_costs', 'p_costs') || ' BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
    	 l_p_margin || ' BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
    	 l_c_margin || ' BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause (l_c_margin, l_p_margin) || ' BIV_MEASURE9 ' || fnd_global.newline || ', ' ||
    	 l_p_margin_percent || ' BIV_MEASURE10 ' || fnd_global.newline || ', ' ||
    	 l_c_margin_percent || ' BIV_MEASURE11 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause  (l_c_margin_percent, l_p_margin_percent, 'P')  || ' BIV_MEASURE12 ' || fnd_global.newline || ', ' ||
	 'NVL (c_charges_total, 0) BIV_MEASURE13 ' || fnd_global.newline || ', ' ||
	 poa_dbi_util_pkg.change_clause ('c_charges_total', 'p_charges_total') || ' BIV_MEASURE14 ' || fnd_global.newline || ', ' ||
	 'NVL (c_costs_total, 0) BIV_MEASURE15 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_costs_total', 'p_costs_total') || ' BIV_MEASURE16 ' || fnd_global.newline || ', ' ||
  	 l_c_margin_total || ' BIV_MEASURE17 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause (l_c_margin_total, l_p_margin_total) || ' BIV_MEASURE18 ' || fnd_global.newline || ', ' ||
	 l_c_margin_percent_total || ' BIV_MEASURE19 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause (l_c_margin_percent_total, l_p_margin_percent_total, 'P')  || ' BIV_MEASURE20 ' || fnd_global.newline || ', ' ||
         l_c_margin || ' BIV_MEASURE21 ' || fnd_global.newline || ', ' ||
	 l_p_margin || ' BIV_MEASURE22 ' || fnd_global.newline || ', ' ||
	 l_c_margin_total || ' BIV_MEASURE23 ' || fnd_global.newline || ', ' ||
	 l_p_margin_total || ' BIV_MEASURE24 ' || fnd_global.newline;
  RETURN l_sel_clause;
END get_ro_mrg_tbl_sel_clause;

/*----------------------------------
Repair Order Margin Trend
----------------------------------*/
PROCEDURE get_ro_mrg_trd_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
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
    l_mv_type		    VARCHAR2(10);
    l_err_stage		    VARCHAR2(500);
    l_debug_mode 	    VARCHAR2(1);
    l_module_name 	    ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type;

BEGIN
    l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_module_name := FND_PROFILE.value('AFLOG_MODULE');
    l_comparison_type := 'Y';
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
                                             p_mv_set           => 'MARGIN',
                                             x_custom_output    => x_custom_output);

    -- The measure columns that need to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'nvl(material_charges_' || l_cur_suffix ||
                                 		',0) + nvl(labor_charges_' || l_cur_suffix ||
                                 		',0) + nvl(expense_charges_' || l_cur_suffix || ',0)',
                                 p_alias_name => 'charges',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'nvl(material_cost_' || l_cur_suffix ||
                                 		',0) + nvl(labor_cost_' || l_cur_suffix ||
                                 		',0) + nvl(expense_cost_' || l_cur_suffix || ',0)',
                                 p_alias_name => 'costs',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    -- Joining Outer and Inner Query
    l_query := get_ro_mrg_trd_sel_clause (l_view_by) ||
               ' from ' ||
               poa_dbi_template_pkg.trend_sql (p_xtd => l_xtd,
                    			       p_comparison_type => l_comparison_type,
                    			       p_fact_name 	=> l_mv,
                    			       p_where_clause 	=> l_where_clause,
                    			       p_col_name 	=> l_col_tbl,
                    			       p_use_grpid 	=> 'N',
                    			       p_in_join_tables => NULL);

    -- Prepare PMV bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- get all the basic binds used by POA queries
    -- Do this before adding any of our binds, since the procedure
    -- reinitializes the output table
    poa_dbi_util_pkg.get_custom_trend_binds (p_xtd => l_xtd,
    					     p_comparison_type => l_comparison_type,
                                             x_custom_output => x_custom_output);

    l_custom_rec.attribute_name := ':AGGREGATION_FLAG';
    l_custom_rec.attribute_value := l_aggregation_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;
EXCEPTION
        WHEN OTHERS THEN
	l_err_stage := SQLERRM;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ';
            ISC_DEPOT_RPT_UTIL_PKG.write('get_ro_mrg_trd_sql : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;
END get_ro_mrg_trd_sql;


/*
    The outer main query for the trend SQL.
*/
FUNCTION get_ro_mrg_trd_sel_clause(p_view_by_dim IN VARCHAR2)
    return VARCHAR2
IS

l_sel_clause varchar2(4500);
l_p_margin varchar2 (500);
l_c_margin varchar2 (500);
l_p_margin_percent varchar2 (500);
l_c_margin_percent varchar2 (500);

BEGIN
  l_p_margin := '(NVL (iset.p_charges, 0) - NVL (iset.p_costs, 0))';
  l_c_margin := '(NVL (iset.c_charges, 0) - NVL (iset.c_costs, 0))';
  l_p_margin_percent := poa_dbi_util_pkg.rate_clause (l_p_margin, 'NVL (iset.p_charges, 0)', 'P');
  l_c_margin_percent := poa_dbi_util_pkg.rate_clause (l_c_margin, 'NVL (iset.c_charges, 0)', 'P');

  l_sel_clause :=
  	' SELECT ' ||
  	 ' cal.name VIEWBY ' || fnd_global.newline || ', ' ||
  	 'NVL (iset.p_charges, 0) BIV_MEASURE1 ' || fnd_global.newline || ', ' ||
  	 'NVL (iset.c_charges, 0) BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('iset.c_charges', 'iset.p_charges') || ' BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
  	 'NVL (iset.p_costs, 0) BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
	 'NVL (iset.c_costs, 0) BIV_MEASURE5 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('iset.c_costs', 'iset.p_costs') || ' BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
  	 l_p_margin || ' BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
  	 l_c_margin || ' BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
	 poa_dbi_util_pkg.change_clause (l_c_margin, l_p_margin) || ' BIV_MEASURE9 ' || fnd_global.newline || ', ' ||
  	 l_p_margin_percent || ' BIV_MEASURE10 ' || fnd_global.newline || ', ' ||
  	 l_c_margin_percent || ' BIV_MEASURE11 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause  (l_c_margin_percent, l_p_margin_percent, 'P')  || ' BIV_MEASURE12 ' || fnd_global.newline;
  RETURN l_sel_clause;

END get_ro_mrg_trd_sel_clause;

/*----------------------------------
Charges Summary Table
----------------------------------*/

PROCEDURE get_chg_summ_tbl_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS

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
    l_mv_type		    VARCHAR2(10);
    l_err_stage		    VARCHAR2(500);
    l_debug_mode 	    VARCHAR2(1);
    l_module_name 	    ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type;

BEGIN
    l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_module_name := FND_PROFILE.value('AFLOG_MODULE');
    l_comparison_type := 'Y';
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
                                             p_mv_set           => 'CHARGES',
                                             x_custom_output    => x_custom_output);

    -- The measure columns that need to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'material_charges_' || l_cur_suffix,
                                 p_alias_name => 'm_charges',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'labor_charges_' || l_cur_suffix,
                                 p_alias_name => 'l_charges',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'expense_charges_' || l_cur_suffix,
                                 p_alias_name => 'e_charges',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    l_join_tbl(l_join_tbl.count).additional_where_clause := l_join_tbl(l_join_tbl.count).additional_where_clause;


    -- construct the query
    l_query := get_chg_summ_tbl_sel_clause (l_view_by, l_view_by_col)
          || ' from
        ' || poa_dbi_template_pkg.status_sql (p_fact_name 	=> l_mv,
                                              p_where_clause 	=> l_where_clause,
                                              p_join_tables 	=> l_join_tbl,
                                              p_use_windowing 	=> 'Y',
                                              p_col_name 	=> l_col_tbl,
                                              p_use_grpid 	=> 'N',
                                              p_paren_count     => 3,
                                              p_filter_where    => '(BIV_MEASURE7 > 0 OR BIV_MEASURE8 > 0)',
                                              p_generate_viewby => 'Y',
                                              p_in_join_tables  => NULL);

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

    l_custom_rec.attribute_name := ':AGGREGATION_FLAG';
    l_custom_rec.attribute_value     := l_aggregation_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;
EXCEPTION
        WHEN OTHERS THEN
	l_err_stage := SQLERRM;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ';
            ISC_DEPOT_RPT_UTIL_PKG.write('get_chg_summ_tbl_sql : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END get_chg_summ_tbl_sql;

FUNCTION get_chg_summ_tbl_sel_clause (p_view_by_dim IN VARCHAR2, p_view_by_col IN VARCHAR2)
    return VARCHAR2
IS

l_sel_clause varchar2(8000);
l_p_total_charges varchar2 (500);
l_c_total_charges varchar2 (500);
l_p_total_charges_total varchar2 (500);
l_c_total_charges_total varchar2 (500);
l_description varchar2(30);
l_cat_drill_down varchar2 (500);

BEGIN
  l_description := 'null';
  l_cat_drill_down := 'null';

  l_p_total_charges := '(NVL (p_m_charges, 0) + NVL (p_l_charges, 0) + NVL (p_e_charges, 0))';
  l_c_total_charges := '(NVL (c_m_charges, 0) + NVL (c_l_charges, 0) + NVL (c_e_charges, 0))';
  l_p_total_charges_total := '(NVL (p_m_charges_total, 0) + NVL (p_l_charges_total, 0) + ' ||
  	 		     'NVL (p_e_charges_total, 0))';
  l_c_total_charges_total := '(NVL (c_m_charges_total, 0) + NVL (c_l_charges_total, 0) +'  ||
  			     'NVL (c_e_charges_total, 0))';

  IF p_view_by_dim = 'ITEM+ENI_ITEM_VBH_CAT' THEN
	l_cat_drill_down := 'decode(v.leaf_node_flag, ''Y'', ' ||
		'''pFunctionName=ISC_DEPOT_CHARGES_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y'', ' ||
		'''pFunctionName=ISC_DEPOT_CHARGES_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'') ';
  ELSIF p_view_by_dim = 'ITEM+ENI_ITEM' THEN
        l_description := 'v.description';
  END IF;

  l_sel_clause :=
     	' SELECT ' ||
      	ISC_DEPOT_RPT_UTIL_PKG.get_viewby_select_clause (p_view_by_dim) || fnd_global.newline ||
      	l_description || ' BIV_ATTRIBUTE1 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE1 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE2 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE3 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE4 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE5 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE6 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE7 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE8 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE9 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE10 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE11 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE12 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE13 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE14 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE15 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE16 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE17 ' || fnd_global.newline || ',' ||
  	 l_cat_drill_down || ' BIV_DYNAMIC_URL1 ' || fnd_global.newline ||
  	'FROM ( SELECT   ' || fnd_global.newline ||
  	' rank() over (&ORDER_BY_CLAUSE'||' nulls last, '|| p_view_by_col ||' ) - 1 rnk ' || fnd_global.newline || ', ' ||
  	p_view_by_col || fnd_global.newline || ', ' ||
      	'BIV_MEASURE1 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE2 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE3 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE4 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE5 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE6 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE7 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE8 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE9 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE10 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE11 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE12 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE13 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE14 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE15 ' || fnd_global.newline || ',' ||
    	'BIV_MEASURE16 ' || fnd_global.newline || ',' ||
    	'BIV_MEASURE17 ' || fnd_global.newline ||
  	'FROM (' ||
  	' SELECT ' || p_view_by_col || fnd_global.newline || ', ' ||
  	 'NVL (c_m_charges, 0) BIV_MEASURE1 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_m_charges', 'p_m_charges') || ' BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_l_charges, 0) BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_l_charges', 'p_l_charges') || ' BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_e_charges, 0) BIV_MEASURE5 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_e_charges', 'p_e_charges') || ' BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
  	 l_p_total_charges || ' BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
  	 l_c_total_charges || ' BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause (l_c_total_charges, l_p_total_charges) || ' BIV_MEASURE9 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_m_charges_total, 0) BIV_MEASURE10 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_m_charges_total', 'p_m_charges_total') || ' BIV_MEASURE11 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_l_charges_total, 0) BIV_MEASURE12 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_l_charges_total', 'p_l_charges_total') || ' BIV_MEASURE13 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_e_charges_total, 0) BIV_MEASURE14 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_e_charges_total', 'p_e_charges_total') || ' BIV_MEASURE15 ' || fnd_global.newline || ', ' ||
  	 l_c_total_charges_total || ' BIV_MEASURE16 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause (l_c_total_charges_total, l_p_total_charges_total) || ' BIV_MEASURE17 ' || fnd_global.newline;


  RETURN l_sel_clause;
END get_chg_summ_tbl_sel_clause;

/*----------------------------------
Charges Summary Trend
----------------------------------*/
PROCEDURE get_chg_summ_trd_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
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
    l_mv_type		    VARCHAR2(10);
    l_err_stage		    VARCHAR2(500);
    l_debug_mode 	    VARCHAR2(1);
    l_module_name 	    ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type;

BEGIN
    l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_module_name := FND_PROFILE.value('AFLOG_MODULE');
    l_comparison_type := 'Y';
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
                                             p_mv_set           => 'CHARGES',
                                             x_custom_output    => x_custom_output);

    -- The measure columns that need to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'material_charges_' || l_cur_suffix,
                                 p_alias_name => 'm_charges',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'labor_charges_' || l_cur_suffix,
                                 p_alias_name => 'l_charges',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'expense_charges_' || l_cur_suffix,
                                 p_alias_name => 'e_charges',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    -- Joining Outer and Inner Query
    l_query := get_chg_summ_trd_sel_clause (l_view_by) ||
               ' from ' ||
               poa_dbi_template_pkg.trend_sql (p_xtd => l_xtd,
                    			       p_comparison_type => l_comparison_type,
                    			       p_fact_name 	=> l_mv,
                    			       p_where_clause 	=> l_where_clause,
                    			       p_col_name 	=> l_col_tbl,
                    			       p_use_grpid 	=> 'N',
                    			       p_in_join_tables => NULL);

    -- Prepare PMV bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- get all the basic binds used by POA queries
    -- Do this before adding any of our binds, since the procedure
    -- reinitializes the output table
    poa_dbi_util_pkg.get_custom_trend_binds (p_xtd => l_xtd,
    					     p_comparison_type => l_comparison_type,
                                             x_custom_output => x_custom_output);


    l_custom_rec.attribute_name := ':AGGREGATION_FLAG';
    l_custom_rec.attribute_value := l_aggregation_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;
EXCEPTION
        WHEN OTHERS THEN
	l_err_stage := SQLERRM;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ';
            ISC_DEPOT_RPT_UTIL_PKG.write('get_chg_summ_trd_sql : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END get_chg_summ_trd_sql;


/*
    The outer main query for the trend SQL.
*/
FUNCTION get_chg_summ_trd_sel_clause(p_view_by_dim IN VARCHAR2)
    return VARCHAR2
IS

l_sel_clause varchar2(4500);
l_p_total_charges varchar2 (500);
l_c_total_charges varchar2 (500);


BEGIN
  l_p_total_charges := '(NVL (iset.p_m_charges, 0) + NVL (iset.p_l_charges, 0) + NVL (iset.p_e_charges, 0))';
  l_c_total_charges := '(NVL (iset.c_m_charges, 0) + NVL (iset.c_l_charges, 0) + NVL (iset.c_e_charges, 0))';

  l_sel_clause :=
  	' SELECT ' ||
  	 ' cal.name VIEWBY ' || fnd_global.newline || ', ' ||
  	 'NVL (iset.c_m_charges, 0) BIV_MEASURE1 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('iset.c_m_charges', 'iset.p_m_charges') || ' BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
  	 'NVL (iset.c_l_charges, 0) BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('iset.c_l_charges', 'iset.p_l_charges') || ' BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
  	 'NVL (iset.c_e_charges, 0) BIV_MEASURE5 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('iset.c_e_charges', 'iset.p_e_charges') || ' BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
  	 l_p_total_charges || ' BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
  	 l_c_total_charges || ' BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause (l_c_total_charges, l_p_total_charges) || ' BIV_MEASURE9 ' || fnd_global.newline;
  RETURN l_sel_clause;
END get_chg_summ_trd_sel_clause;

/*----------------------------------
Cost Summary Table
----------------------------------*/

PROCEDURE get_cst_summ_tbl_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS

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
    l_mv_type		    VARCHAR2(10);
    l_err_stage		    VARCHAR2(500);
    l_debug_mode 	    VARCHAR2(1);
    l_module_name 	    ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type;

BEGIN
    l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_module_name := FND_PROFILE.value('AFLOG_MODULE');
    l_comparison_type := 'Y';

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
                                             p_mv_set           => 'COSTS',
                                             x_custom_output    => x_custom_output);

    -- The measure columns that need to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'material_cost_' || l_cur_suffix,
                                 p_alias_name => 'm_cost',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'labor_cost_' || l_cur_suffix,
                                 p_alias_name => 'l_cost',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'expense_cost_' || l_cur_suffix,
                                 p_alias_name => 'e_cost',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    l_join_tbl(l_join_tbl.count).additional_where_clause := l_join_tbl(l_join_tbl.count).additional_where_clause;

    -- construct the query
    l_query := get_cst_summ_tbl_sel_clause (l_view_by, l_view_by_col)
         || ' from '
         || poa_dbi_template_pkg.status_sql (p_fact_name 	=> l_mv,
                                              p_where_clause 	=> l_where_clause,
                                              p_join_tables 	=> l_join_tbl,
                                              p_use_windowing 	=> 'Y',
                                              p_col_name 	=> l_col_tbl,
                                              p_use_grpid 	=> 'N',
                                              p_paren_count     => 3,
                                              p_filter_where    => '(BIV_MEASURE7 > 0 OR BIV_MEASURE8 > 0)',
                                              p_generate_viewby => 'Y',
                                              p_in_join_tables  => NULL);

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

    l_custom_rec.attribute_name := ':AGGREGATION_FLAG';
    l_custom_rec.attribute_value     := l_aggregation_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;
EXCEPTION
        WHEN OTHERS THEN
	l_err_stage := SQLERRM;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ';
            ISC_DEPOT_RPT_UTIL_PKG.write('get_cst_summ_tbl_sql : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END get_cst_summ_tbl_sql;

FUNCTION get_cst_summ_tbl_sel_clause (p_view_by_dim IN VARCHAR2, p_view_by_col IN VARCHAR2)
    return VARCHAR2
IS

l_sel_clause varchar2(8000);
l_p_total_cost varchar2 (500);
l_c_total_cost varchar2 (500);
l_p_total_cost_total varchar2 (500);
l_c_total_cost_total varchar2 (500);
l_description varchar2(30);
l_cat_drill_down varchar2(500);

BEGIN
  l_description := 'null';
  l_cat_drill_down := 'null';

  l_p_total_cost := '(NVL (p_m_cost, 0) + NVL (p_l_cost, 0) + NVL (p_e_cost, 0))';
  l_c_total_cost := '(NVL (c_m_cost, 0) + NVL (c_l_cost, 0) + NVL (c_e_cost, 0))';
  l_p_total_cost_total := '(NVL (p_m_cost_total, 0) + NVL (p_l_cost_total, 0) + ' ||
  			'NVL (p_e_cost_total, 0))';
  l_c_total_cost_total := '(NVL (c_m_cost_total, 0) + NVL (c_l_cost_total, 0) + ' ||
  			'NVL (c_e_cost_total, 0))';

  IF p_view_by_dim = 'ITEM+ENI_ITEM_VBH_CAT' THEN
	l_cat_drill_down := 'decode(v.leaf_node_flag, ''Y'', ' ||
		'''pFunctionName=ISC_DEPOT_COSTS_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y'', ' ||
		'''pFunctionName=ISC_DEPOT_COSTS_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'') ';
  ELSIF p_view_by_dim = 'ITEM+ENI_ITEM' THEN
        l_description := 'v.description';
  END IF;

  l_sel_clause :=
     	' SELECT ' ||
      	ISC_DEPOT_RPT_UTIL_PKG.get_viewby_select_clause (p_view_by_dim) || fnd_global.newline ||
      	l_description || ' BIV_ATTRIBUTE1 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE1 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE2 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE3 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE4 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE5 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE6 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE7 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE8 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE9 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE10 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE11 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE12 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE13 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE14 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE15 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE16 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE17 ' || fnd_global.newline || ',' ||
  	 l_cat_drill_down || ' BIV_DYNAMIC_URL1 ' || fnd_global.newline ||
  	'FROM ( SELECT   ' || fnd_global.newline ||
  	' rank() over (&ORDER_BY_CLAUSE'||' nulls last, '|| p_view_by_col ||' ) - 1 rnk' || fnd_global.newline || ', ' ||
  	 p_view_by_col  || fnd_global.newline || ', ' ||
      	'BIV_MEASURE1 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE5 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE9 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE10 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE11 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE12 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE13 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE14 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE15 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE16 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE17 ' || fnd_global.newline ||
  	'FROM (' || fnd_global.newline ||
  	' SELECT ' || p_view_by_col || fnd_global.newline || ', ' ||
  	 'NVL (c_m_cost, 0) BIV_MEASURE1 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_m_cost', 'p_m_cost') || ' BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_l_cost, 0) BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_l_cost', 'p_l_cost') || ' BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_e_cost,0) BIV_MEASURE5 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_e_cost', 'p_e_cost') || ' BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
  	 l_p_total_cost || ' BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
  	 l_c_total_cost || ' BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause (l_c_total_cost, l_p_total_cost) || ' BIV_MEASURE9 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_m_cost_total, 0) BIV_MEASURE10 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_m_cost_total', 'p_m_cost_total') || ' BIV_MEASURE11 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_l_cost_total, 0) BIV_MEASURE12 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_l_cost_total', 'p_l_cost_total') || ' BIV_MEASURE13 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_e_cost_total, 0) BIV_MEASURE14 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_e_cost_total', 'p_e_cost_total') || ' BIV_MEASURE15 ' || fnd_global.newline || ', ' ||
  	 l_c_total_cost_total || ' BIV_MEASURE16 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause (l_c_total_cost_total, l_p_total_cost_total) || ' BIV_MEASURE17 ' || fnd_global.newline;

  RETURN l_sel_clause;
END get_cst_summ_tbl_sel_clause;

/*----------------------------------
Cost Summary Trend
----------------------------------*/
PROCEDURE get_cst_summ_trd_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
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
    l_mv_type		    VARCHAR2(10);
    l_err_stage		    VARCHAR2(500);
    l_debug_mode 	    VARCHAR2(1);
    l_module_name 	    ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type;

BEGIN
    l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_module_name := FND_PROFILE.value('AFLOG_MODULE');
    l_comparison_type := 'Y';
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
                                             p_mv_set           => 'COSTS',
                                             x_custom_output    => x_custom_output);

    -- The measure columns that need to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'material_cost_' || l_cur_suffix,
                                 p_alias_name => 'm_cost',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'labor_cost_' || l_cur_suffix,
                                 p_alias_name => 'l_cost',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'expense_cost_' || l_cur_suffix,
                                 p_alias_name => 'e_cost',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    -- Joining Outer and Inner Query
    l_query := get_cst_summ_trd_sel_clause (l_view_by) ||
               ' from ' ||
               poa_dbi_template_pkg.trend_sql (p_xtd => l_xtd,
                    			       p_comparison_type => l_comparison_type,
                    			       p_fact_name 	=> l_mv,
                    			       p_where_clause 	=> l_where_clause,
                    			       p_col_name 	=> l_col_tbl,
                    			       p_use_grpid 	=> 'N',
                    			       p_in_join_tables => NULL);

    -- Prepare PMV bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- get all the basic binds used by POA queries
    -- Do this before adding any of our binds, since the procedure
    -- reinitializes the output table
    poa_dbi_util_pkg.get_custom_trend_binds (p_xtd => l_xtd,
    					     p_comparison_type => l_comparison_type,
                                             x_custom_output => x_custom_output);

    l_custom_rec.attribute_name := ':AGGREGATION_FLAG';
    l_custom_rec.attribute_value := l_aggregation_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;
EXCEPTION
        WHEN OTHERS THEN
	l_err_stage := SQLERRM;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ';
            ISC_DEPOT_RPT_UTIL_PKG.write('get_cst_summ_trd_sql : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END get_cst_summ_trd_sql;


/*
    The outer main query for the trend SQL.
*/
FUNCTION get_cst_summ_trd_sel_clause(p_view_by_dim IN VARCHAR2)
    return VARCHAR2
IS

l_sel_clause varchar2(4500);
l_p_total_cost varchar2 (500);
l_c_total_cost varchar2 (500);


BEGIN
  l_p_total_cost := '(NVL (iset.p_m_cost, 0) + NVL (iset.p_l_cost, 0) + NVL (iset.p_e_cost, 0))';
  l_c_total_cost := '(NVL (iset.c_m_cost, 0) + NVL (iset.c_l_cost, 0) + NVL (iset.c_e_cost, 0))';

  l_sel_clause :=
  	' SELECT ' ||
  	 ' cal.name VIEWBY ' || fnd_global.newline || ', ' ||
  	 'NVL (iset.c_m_cost, 0) BIV_MEASURE1 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('iset.c_m_cost', 'iset.p_m_cost') || ' BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
  	 'NVL (iset.c_l_cost, 0) BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('iset.c_l_cost', 'iset.p_l_cost') || ' BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
  	 'NVL (iset.c_e_cost, 0) BIV_MEASURE5 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('iset.c_e_cost', 'iset.p_e_cost') || ' BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
  	 l_p_total_cost || ' BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
  	 l_c_total_cost || ' BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause (l_c_total_cost, l_p_total_cost) || ' BIV_MEASURE9 ' || fnd_global.newline;
  RETURN l_sel_clause;
END get_cst_summ_trd_sel_clause;

/*----------------------------------
Margin Summary Table
----------------------------------*/

PROCEDURE get_mrg_summ_tbl_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS

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
    l_mv_type		    VARCHAR2(10);
    l_err_stage		    VARCHAR2(500);
    l_debug_mode 	    VARCHAR2(1);
    l_module_name 	    ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type;
    l_supress			VARCHAR2 (200);

BEGIN
    l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_module_name := FND_PROFILE.value('AFLOG_MODULE');
    l_comparison_type := 'Y';

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
                                             p_mv_set           => 'MARGIN',
                                             x_custom_output    => x_custom_output);

    -- The measure columns that need to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'nvl(material_charges_' || l_cur_suffix || ', 0) - '
                                 		|| 'nvl(material_cost_' || l_cur_suffix || ', 0)',
                                 p_alias_name => 'm_margin',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'nvl(labor_charges_' || l_cur_suffix || ', 0) - '
                                 		|| 'nvl(labor_cost_' || l_cur_suffix || ', 0)',
                                 p_alias_name => 'l_margin',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'nvl(expense_charges_' || l_cur_suffix || ', 0) - '
                                 		|| 'nvl(expense_cost_' || l_cur_suffix || ', 0)',
                                 p_alias_name => 'e_margin',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    l_join_tbl(l_join_tbl.count).additional_where_clause := l_join_tbl(l_join_tbl.count).additional_where_clause;


    -- construct the query
    l_supress := ' and (nvl(material_charges_' || l_cur_suffix || ', 0) > 0 OR nvl(labor_charges_' || l_cur_suffix || ', 0) > 0 '
		|| 'OR nvl(expense_charges_' || l_cur_suffix || ', 0) > 0 OR nvl(material_cost_' || l_cur_suffix || ', 0) > 0 '
		|| 'OR nvl(labor_cost_' || l_cur_suffix || ', 0) > 0 OR nvl(expense_cost_' || l_cur_suffix || ', 0) > 0) ';

    l_query := get_mrg_summ_tbl_sel_clause (l_view_by, l_view_by_col)
          || ' from
        ' || poa_dbi_template_pkg.status_sql (p_fact_name 	=> l_mv,
                                              p_where_clause 	=> l_where_clause || l_supress,
                                              p_join_tables 	=> l_join_tbl,
                                              p_use_windowing 	=> 'Y',
                                              p_col_name 	=> l_col_tbl,
                                              p_use_grpid 	=> 'N',
                                              p_paren_count     => 3,
                                              p_filter_where    => NULL,
                                              p_generate_viewby => 'Y',
                                              p_in_join_tables  => NULL);

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

    l_custom_rec.attribute_name := ':AGGREGATION_FLAG';
    l_custom_rec.attribute_value     := l_aggregation_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;
EXCEPTION
        WHEN OTHERS THEN
	l_err_stage := SQLERRM;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ';
            ISC_DEPOT_RPT_UTIL_PKG.write('get_mrg_summ_tbl_sql : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END get_mrg_summ_tbl_sql;

FUNCTION get_mrg_summ_tbl_sel_clause (p_view_by_dim IN VARCHAR2, p_view_by_col IN VARCHAR2)
    return VARCHAR2
IS

l_sel_clause varchar2(8000);
l_p_total_margin varchar2 (500);
l_c_total_margin varchar2 (500);
l_p_total_margin_total varchar2 (500);
l_c_total_margin_total varchar2 (500);
l_description varchar2(30);
l_cat_drill_down  varchar2 (500);

BEGIN
  l_description := 'null';
  l_cat_drill_down := 'null';

  l_p_total_margin := '(NVL (p_m_margin, 0) + NVL (p_l_margin, 0) + NVL (p_e_margin, 0))';
  l_c_total_margin := '(NVL (c_m_margin, 0) + NVL (c_l_margin, 0) + NVL (c_e_margin, 0))';
  l_p_total_margin_total := '(NVL (p_m_margin_total, 0) + NVL (p_l_margin_total, 0) + ' ||
  			'NVL (p_e_margin_total, 0))';
  l_c_total_margin_total := '(NVL (c_m_margin_total, 0) + NVL (c_l_margin_total, 0) + ' ||
  			'NVL (c_e_margin_total, 0))';

  IF p_view_by_dim = 'ITEM+ENI_ITEM_VBH_CAT' THEN
	l_cat_drill_down := 'decode(v.leaf_node_flag, ''Y'', ' ||
		'''pFunctionName=ISC_DEPOT_MARGIN_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y'', ' ||
		'''pFunctionName=ISC_DEPOT_MARGIN_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'') ';
  ELSIF p_view_by_dim = 'ITEM+ENI_ITEM' THEN
        l_description := 'v.description';
  END IF;

  l_sel_clause :=
     	' SELECT ' ||
      	ISC_DEPOT_RPT_UTIL_PKG.get_viewby_select_clause (p_view_by_dim) || fnd_global.newline ||
      	l_description || ' BIV_ATTRIBUTE1 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE1 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE2 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE3 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE4 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE5 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE6 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE7 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE8 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE9 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE10 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE11 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE12 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE13 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE14 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE15 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE16 ' || fnd_global.newline || ',' ||
      	'BIV_MEASURE17 ' || fnd_global.newline || ',' ||
  	 l_cat_drill_down || ' BIV_DYNAMIC_URL1 ' || fnd_global.newline ||
  	'FROM ( SELECT   ' || fnd_global.newline ||
  	' rank() over (&ORDER_BY_CLAUSE'||' nulls last, '|| p_view_by_col ||' ) - 1 rnk' || fnd_global.newline || ', ' ||
  	 p_view_by_col  || fnd_global.newline || ', ' ||
      	'BIV_MEASURE1 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE5 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE9 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE10 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE11 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE12 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE13 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE14 ' || fnd_global.newline || ', ' ||
      	'BIV_MEASURE15 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE16 ' || fnd_global.newline || ', ' ||
    	'BIV_MEASURE17 ' || fnd_global.newline ||
  	'FROM (' || fnd_global.newline ||
  	' SELECT ' || p_view_by_col || fnd_global.newline || ', ' ||
  	 'NVL (c_m_margin, 0) BIV_MEASURE1 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_m_margin', 'p_m_margin') || ' BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_l_margin, 0) BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_l_margin', 'p_l_margin') || ' BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_e_margin,0) BIV_MEASURE5 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_e_margin', 'p_e_margin') || ' BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
  	 l_p_total_margin || ' BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
  	 l_c_total_margin || ' BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause (l_c_total_margin, l_p_total_margin) || ' BIV_MEASURE9 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_m_margin_total, 0) BIV_MEASURE10 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_m_margin_total', 'p_m_margin_total') || ' BIV_MEASURE11 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_l_margin_total, 0) BIV_MEASURE12 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_l_margin_total', 'p_l_margin_total') || ' BIV_MEASURE13 ' || fnd_global.newline || ', ' ||
  	 'NVL (c_e_margin_total, 0) BIV_MEASURE14 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('c_e_margin_total', 'p_e_margin_total') || ' BIV_MEASURE15 ' || fnd_global.newline || ', ' ||
  	 l_c_total_margin_total || ' BIV_MEASURE16 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause (l_c_total_margin_total, l_p_total_margin_total) || ' BIV_MEASURE17 ' || fnd_global.newline;


  RETURN l_sel_clause;
END get_mrg_summ_tbl_sel_clause;

/*----------------------------------
Margin Summary Trend
----------------------------------*/
PROCEDURE get_mrg_summ_trd_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
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
    l_mv_type		    VARCHAR2(10);
    l_err_stage		    VARCHAR2(500);
    l_debug_mode 	    VARCHAR2(1);
    l_module_name 	    ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type;

BEGIN
    l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_module_name := FND_PROFILE.value('AFLOG_MODULE');
    l_comparison_type := 'Y';
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
                                             p_mv_set           => 'MARGIN',
                                             x_custom_output    => x_custom_output);

    -- The measure columns that need to be aggregated

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'nvl(material_charges_' || l_cur_suffix || ', 0) - '
                                 		|| 'nvl(material_cost_' || l_cur_suffix || ', 0)',
                                 p_alias_name => 'm_margin',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'nvl(labor_charges_' || l_cur_suffix || ', 0) - '
                                 		|| 'nvl(labor_cost_' || l_cur_suffix || ', 0)',
                                 p_alias_name => 'l_margin',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'nvl(expense_charges_' || l_cur_suffix || ', 0) - '
                                 		|| 'nvl(expense_cost_' || l_cur_suffix || ', 0)',
                                 p_alias_name => 'e_margin',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS);

    -- Joining Outer and Inner Query
    l_query := get_mrg_summ_trd_sel_clause (l_view_by) ||
               ' from ' ||
               poa_dbi_template_pkg.trend_sql (p_xtd => l_xtd,
                    			       p_comparison_type => l_comparison_type,
                    			       p_fact_name 	=> l_mv,
                    			       p_where_clause 	=> l_where_clause,
                    			       p_col_name 	=> l_col_tbl,
                    			       p_use_grpid 	=> 'N',
                    			       p_in_join_tables => NULL);

    -- Prepare PMV bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- get all the basic binds used by POA queries
    -- Do this before adding any of our binds, since the procedure
    -- reinitializes the output table
    poa_dbi_util_pkg.get_custom_trend_binds (p_xtd => l_xtd,
    					     p_comparison_type => l_comparison_type,
                                             x_custom_output => x_custom_output);

    l_custom_rec.attribute_name := ':AGGREGATION_FLAG';
    l_custom_rec.attribute_value := l_aggregation_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;
EXCEPTION
        WHEN OTHERS THEN
	l_err_stage := SQLERRM;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ';
            ISC_DEPOT_RPT_UTIL_PKG.write('get_mrg_summ_trd_sql : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;

END get_mrg_summ_trd_sql;


/*
    The outer main query for the trend SQL.
*/
FUNCTION get_mrg_summ_trd_sel_clause(p_view_by_dim IN VARCHAR2)
    return VARCHAR2
IS

l_sel_clause varchar2(8000);
l_p_total_margin varchar2 (500);
l_c_total_margin varchar2 (500);


BEGIN
  l_p_total_margin := '(NVL (iset.p_m_margin, 0) + NVL (iset.p_l_margin, 0) + NVL (iset.p_e_margin, 0))';
  l_c_total_margin := '(NVL (iset.c_m_margin, 0) + NVL (iset.c_l_margin, 0) + NVL (iset.c_e_margin, 0))';

  l_sel_clause :=
  	' SELECT ' ||
  	 ' cal.name VIEWBY ' || fnd_global.newline || ', ' ||
  	 'NVL (iset.c_m_margin, 0) BIV_MEASURE1 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('iset.c_m_margin', 'iset.p_m_margin') || ' BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
  	 'NVL (iset.c_l_margin, 0) BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('iset.c_l_margin', 'iset.p_l_margin') || ' BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
  	 'NVL (iset.c_e_margin, 0) BIV_MEASURE5 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause ('iset.c_e_margin', 'iset.p_e_margin') || ' BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
  	 l_p_total_margin || ' BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
  	 l_c_total_margin || ' BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
  	 poa_dbi_util_pkg.change_clause (l_c_total_margin, l_p_total_margin) || ' BIV_MEASURE9 ' || fnd_global.newline;
  RETURN l_sel_clause;
END get_mrg_summ_trd_sel_clause;

/*----------------------------------
Repair Order Margin Detail
----------------------------------*/

PROCEDURE get_mrg_dtl_tbl_sql(
    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql OUT NOCOPY VARCHAR2,
    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS

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
    l_mv_type		    VARCHAR2(10);
    l_err_stage		    VARCHAR2(500);
    l_debug_mode 	    VARCHAR2(1);
    l_module_name 	    ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type;

BEGIN
        l_debug_mode :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
        l_module_name := FND_PROFILE.value('AFLOG_MODULE');
	l_comparison_type := 'Y';
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
                                                 p_mv_set           => 'MRGN_DTL',
                                                 x_custom_output    => x_custom_output);

        l_query := get_mrg_dtl_sel_clause (l_cur_suffix) ||
                ' FROM ' || fnd_global.newline
                || l_mv ||
	  	'	ISC_DR_REPAIR_ORDERS_F fact' || fnd_global.newline ||
	  	'	,ISC_DR_CHARGES_F charges' || fnd_global.newline ||
	  	'	,ISC_DR_COSTS_F costs' || fnd_global.newline ||
	  	'	,ENI_ITEM_V eiov ' || fnd_global.newline ||
		' WHERE  fact.item_org_id = eiov.id ' || fnd_global.newline ||
		'	 AND fact.repair_line_id = charges.repair_line_id (+) ' || fnd_global.newline ||
		'	 AND fact.repair_line_id = costs.repair_line_id (+) ' || fnd_global.newline ||
		'	 AND (charges.repair_line_id IS NOT NULL OR costs.repair_line_id IS NOT NULL) ' || fnd_global.newline ||
		'	 AND (costs.labor_cost_'||l_cur_suffix ||'<> 0
				  or costs.expense_cost_'||l_cur_suffix ||' <> 0
				  or costs.material_cost_'||l_cur_suffix ||' <> 0
				  or charges.labor_charges_'||l_cur_suffix ||' <> 0
				  or charges.expense_charges_'||l_cur_suffix ||' <> 0
				  or charges.material_charges_'||l_cur_suffix ||' <> 0 )'|| fnd_global.newline ||
		'	 AND fact.dbi_date_closed BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ' || fnd_global.newline
                || l_where_clause || fnd_global.newline
                || ' ) ) where (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1) '||
                	'ORDER BY rnk' ;

        x_custom_sql := l_query;

EXCEPTION
        WHEN OTHERS THEN
	l_err_stage := SQLERRM;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='The exception is : ';
            ISC_DEPOT_RPT_UTIL_PKG.write('get_mrg_dtl_sql : ',l_err_stage,ISC_DEPOT_RPT_UTIL_PKG.C_DEBUG_LEVEL);
        END IF;
END get_mrg_dtl_tbl_sql;

FUNCTION get_mrg_dtl_sel_clause (p_curr_suffix IN VARCHAR2)
    return VARCHAR2
IS

l_sel_clause varchar2(8000);
l_total_charges varchar2 (500);
l_total_cost varchar2 (500);
l_total_margin varchar2 (500);
l_total_charges_total varchar2 (500);
l_total_cost_total varchar2 (500);
l_total_margin_total varchar2 (500);

BEGIN
  l_total_charges := 'NVL(charges.material_charges_' || p_curr_suffix || ', 0) + ' ||
  		     'NVL(charges.labor_charges_' || p_curr_suffix || ', 0) + ' ||
  		     'NVL(charges.expense_charges_' || p_curr_suffix || ', 0)';

  l_total_cost := 'NVL(costs.material_cost_' || p_curr_suffix || ', 0) + ' ||
  		     'NVL(costs.labor_cost_' || p_curr_suffix || ', 0) + ' ||
  		     'NVL(costs.expense_cost_' || p_curr_suffix || ', 0)';

  l_total_margin := '(NVL(charges.material_charges_' || p_curr_suffix || ', 0) - ' ||
  		     'NVL(costs.material_cost_' || p_curr_suffix || ', 0)) ' ||
		    '+ (NVL(charges.labor_charges_' || p_curr_suffix || ', 0) - ' ||
  		     'NVL(costs.labor_cost_' || p_curr_suffix || ', 0)) ' ||
		    '+ (NVL(charges.expense_charges_' || p_curr_suffix || ', 0) - ' ||
  		     'NVL(costs.expense_cost_' || p_curr_suffix || ', 0)) ';

  l_total_charges_total := 'NVL(sum(charges.material_charges_' || p_curr_suffix || ') over(), 0) + ' ||
  		     'NVL(sum(charges.labor_charges_' || p_curr_suffix || ') over(), 0) + ' ||
  		     'NVL(sum(charges.expense_charges_' || p_curr_suffix || ') over(), 0)';

  l_total_cost_total := 'NVL(sum(costs.material_cost_' || p_curr_suffix || ') over(), 0) + ' ||
  		     'NVL(sum(costs.labor_cost_' || p_curr_suffix || ') over(), 0) + ' ||
  		     'NVL(sum(costs.expense_cost_' || p_curr_suffix || ') over(), 0)';

  l_total_margin_total := '(NVL(sum(charges.material_charges_' || p_curr_suffix || ') over(), 0) - ' ||
  		     'NVL(sum(costs.material_cost_' || p_curr_suffix || ') over(), 0)) ' ||
		    '+ (NVL(sum(charges.labor_charges_' || p_curr_suffix || ') over(), 0) - ' ||
  		     'NVL(sum(costs.labor_cost_' || p_curr_suffix || ') over(), 0)) ' ||
		    '+ (NVL(sum(charges.expense_charges_' || p_curr_suffix || ') over(), 0) - ' ||
  		     'NVL(sum(costs.expense_cost_' || p_curr_suffix || ') over(), 0)) ';
  l_sel_clause :=
        'SELECT '||
		'BIV_ATTRIBUTE1 ' || fnd_global.newline || ', ' ||
		'BIV_ATTRIBUTE2 ' || fnd_global.newline || ', ' ||
		'BIV_ATTRIBUTE3 ' || fnd_global.newline || ', ' ||
		'BIV_ATTRIBUTE4 ' || fnd_global.newline || ', ' ||
		'BIV_ATTRIBUTE5 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE10 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE11 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE12 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE14 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE15 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE16 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE17 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE18 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE19 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE20 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE21 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE22 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE23 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE24 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE25 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE26 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE27 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE28 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE29 ' || fnd_global.newline || ', ' ||
		'BIV_MEASURE30 ' || fnd_global.newline || ', ' ||
		'''pFunctionName=CSD_RO_DETAILS&csdInvOrgId=''||BIV_MEASURE30||''&csdRepairLineId=''||BIV_MEASURE29 BIV_DYNAMIC_URL1'|| ', '||
		ISC_DEPOT_RPT_UTIL_PKG.get_service_request_url || '|| BIV_ATTRIBUTE5 BIV_DYNAMIC_URL2 '||
	 ' FROM ( ' || fnd_global.newline ||
		'SELECT ' || fnd_global.newline ||
	 		'rank() over (&ORDER_BY_CLAUSE  nulls last ,BIV_ATTRIBUTE1) - 1 rnk ' || fnd_global.newline || ', ' ||
			'BIV_ATTRIBUTE1 ' || fnd_global.newline || ', ' ||
			'BIV_ATTRIBUTE2 ' || fnd_global.newline || ', ' ||
			'BIV_ATTRIBUTE3 ' || fnd_global.newline || ', ' ||
			'BIV_ATTRIBUTE4 ' || fnd_global.newline || ', ' ||
			'BIV_ATTRIBUTE5 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE2 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE3 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE4 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE6 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE7 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE8 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE10 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE11 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE12 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE14 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE15 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE16 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE17 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE18 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE19 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE20 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE21 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE22 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE23 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE24 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE25 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE26 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE27 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE28 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE29 ' || fnd_global.newline || ', ' ||
			'BIV_MEASURE30 ' || fnd_global.newline ||
  		'FROM ( ' || fnd_global.newline ||
		'SELECT ' || fnd_global.newline ||
		 'repair_number BIV_ATTRIBUTE1 ' || fnd_global.newline || ', ' ||
		 'incident_number BIV_ATTRIBUTE2 ' || fnd_global.newline || ', ' ||
		 'fact.repair_line_id BIV_MEASURE29 ' || fnd_global.newline || ', ' ||
		 'fact.master_organization_id BIV_MEASURE30 ' || fnd_global.newline || ', ' ||
		 'crt.name  BIV_ATTRIBUTE3 ' || fnd_global.newline || ', ' ||
		 'eiov.value BIV_ATTRIBUTE4 ' || fnd_global.newline || ', ' ||
		 'incident_id BIV_ATTRIBUTE5 ' || fnd_global.newline || ', ' ||
		 'NVL(charges.material_charges_' || p_curr_suffix || ', 0) BIV_MEASURE2' || fnd_global.newline || ', ' ||
		 'NVL(costs.material_cost_' || p_curr_suffix || ', 0) BIV_MEASURE3' || fnd_global.newline || ', ' ||
		 'NVL(charges.material_charges_' || p_curr_suffix || ', 0) - ' ||
			'NVL(costs.material_cost_' || p_curr_suffix || ', 0) BIV_MEASURE4' || fnd_global.newline || ', ' ||
		 'NVL(charges.labor_charges_' || p_curr_suffix || ', 0) BIV_MEASURE6' || fnd_global.newline || ', ' ||
		 'NVL(costs.labor_cost_' || p_curr_suffix || ', 0) BIV_MEASURE7' || fnd_global.newline || ', ' ||
		 'NVL(charges.labor_charges_' || p_curr_suffix || ', 0) - ' ||
			'NVL(costs.labor_cost_' || p_curr_suffix || ', 0) BIV_MEASURE8' || fnd_global.newline || ', ' ||
		 'NVL(charges.expense_charges_' || p_curr_suffix || ', 0) BIV_MEASURE10' || fnd_global.newline || ', ' ||
		 'NVL(costs.expense_cost_' || p_curr_suffix || ', 0) BIV_MEASURE11' || fnd_global.newline || ', ' ||
		 'NVL(charges.expense_charges_' || p_curr_suffix || ', 0) - ' ||
			'NVL(costs.expense_cost_' || p_curr_suffix || ', 0) BIV_MEASURE12' || fnd_global.newline || ', ' ||
		  l_total_charges || ' BIV_MEASURE14' || fnd_global.newline || ', ' ||
		  l_total_cost || ' BIV_MEASURE15' || fnd_global.newline || ', ' ||
		  l_total_margin || ' BIV_MEASURE16' || fnd_global.newline || ', ' ||
		 'NVL(sum(charges.material_charges_' || p_curr_suffix || ') over(), 0)  BIV_MEASURE17' || fnd_global.newline || ', ' ||
		 'NVL(sum(costs.material_cost_' || p_curr_suffix || ') over(), 0) BIV_MEASURE18' || fnd_global.newline || ', ' ||
		 'NVL(sum(charges.material_charges_' || p_curr_suffix || ') over(), 0) - ' ||
			'NVL(sum(costs.material_cost_' || p_curr_suffix || ') over(), 0) BIV_MEASURE19' || fnd_global.newline || ', ' ||
		 'NVL(sum(charges.labor_charges_' || p_curr_suffix || ') over(), 0) BIV_MEASURE20' || fnd_global.newline || ', ' ||
		 'NVL(sum(costs.labor_cost_' || p_curr_suffix || ') over(), 0) BIV_MEASURE21' || fnd_global.newline || ', ' ||
		 'NVL(sum(charges.labor_charges_' || p_curr_suffix || ') over(), 0) - ' ||
			'NVL(sum(costs.labor_cost_' || p_curr_suffix || ') over(), 0) BIV_MEASURE22' || fnd_global.newline || ', ' ||
		 'NVL(sum(charges.expense_charges_' || p_curr_suffix || ') over(), 0) BIV_MEASURE23' || fnd_global.newline || ', ' ||
		 'NVL(sum(costs.expense_cost_' || p_curr_suffix || ') over(), 0) BIV_MEASURE24' || fnd_global.newline || ', ' ||
		 'NVL(sum(charges.expense_charges_' || p_curr_suffix || ') over(), 0) - ' ||
			'NVL(sum(costs.expense_cost_' || p_curr_suffix || ') over(), 0) BIV_MEASURE25' || fnd_global.newline || ', ' ||
		  l_total_charges_total || ' BIV_MEASURE26' || fnd_global.newline || ', ' ||
		  l_total_cost_total || ' BIV_MEASURE27' || fnd_global.newline || ', ' ||
		  l_total_margin_total || ' BIV_MEASURE28 ' || fnd_global.newline;
  RETURN l_sel_clause;
END get_mrg_dtl_sel_clause;

END ISC_DEPOT_MARGIN_RPT_PKG;

/
