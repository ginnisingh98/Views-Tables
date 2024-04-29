--------------------------------------------------------
--  DDL for Package Body OPI_DBI_INV_CURR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_INV_CURR_RPT_PKG" AS
/*$Header: OPIDRIVDETB.pls 120.9 2006/01/06 01:31:34 srayadur noship $ */


/****************************************
 * Select clause functions
 ****************************************/

/* Current Inventory Status */
-- Outer select clause
FUNCTION get_curr_inv_stat_sel_clause (p_view_by_dim IN VARCHAR2,
                                       p_join_tbl IN
                                         poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2;

/* Current Inventory Expiration Status */
-- Outer select clause
FUNCTION get_curr_inv_exp_sel_clause (p_view_by_dim IN VARCHAR2,
                                      p_join_tbl IN
                                        poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2;


/* Inventory Days Onhand */
-- Outer select clause
FUNCTION get_inv_doh_sel_clause (p_view_by_dim IN VARCHAR2,
                                 p_join_tbl IN
                                    poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2;

/****************************************
 * Helper functions
 ****************************************/

/* Current Inventory Status */
-- Set up the in_join table for viewby grade.
PROCEDURE get_curr_inv_stat_mln
            (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
             p_query IN OUT NOCOPY VARCHAR2);

-- Set up the in_join table for viewby item cat.
PROCEDURE get_curr_inv_stat_eni
            (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
             p_query IN OUT NOCOPY VARCHAR2);

-- Get fixed view by columns for Current Inventory Status
-- inner SQL.
PROCEDURE get_curr_inv_viewby_cols
            (p_view_by IN VARCHAR2,
             p_view_by_col IN VARCHAR2,
             p_query IN OUT NOCOPY VARCHAR2);

-- Parameter condition where clauses
PROCEDURE get_curr_inv_stat_param_cond
            (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
             p_query IN OUT NOCOPY VARCHAR2);

-- Security Where clause
PROCEDURE get_curr_inv_sec_where_clause
            (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
             p_query IN OUT NOCOPY VARCHAR2);

-- Concatenated, formatted viewby column
FUNCTION get_curr_inv_viewby_format (p_viewby IN VARCHAR2)
    RETURN VARCHAR2;

/* Current inventory Expiration Status */
-- Filter function for when measures are all 0/NULL
FUNCTION get_curr_inv_exp_filter_clause (p_view_by_dim IN VARCHAR2)
    RETURN VARCHAR2;

/* Inventory Days Onhand */
-- Filter function for when measures are all 0/NULL
FUNCTION get_inv_doh_filter_clause (p_view_by_dim IN VARCHAR2)
    RETURN VARCHAR2;


/****************************************
 * Current Inventory Expiration Status
 ****************************************/

/* get_curr_inv_exp_stat_sql

    Description
        Current Inventory Expiration Status (Table) report query function.

    Inputs
        1. p_params - table of parameters with which report was run.

    Outputs
        1. x_custom_sql - sql report query.
        2. x_custom_output - table of values for bind variables in
                             sql report query.

    History

    Date        Author              Action
    07/11/05    Dinkar Gupta        Wrote Function
*/
PROCEDURE get_curr_inv_exp_stat_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                                     x_custom_sql OUT NOCOPY VARCHAR2,
                                     x_custom_output OUT NOCOPY
                                        BIS_QUERY_ATTRIBUTES_TBL)
IS
-- {
    l_query VARCHAR2 (32767);

    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_xtd VARCHAR2(10);
    l_comparison_type VARCHAR2(1);

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

    l_where_clause VARCHAR2 (2000);
    l_mv VARCHAR2 (30);

    l_aggr_level_flag VARCHAR2(1);

    l_custom_rec BIS_QUERY_ATTRIBUTES;

    l_cur_suffix VARCHAR2 (5);

    l_filter_clause VARCHAR2 (20000);
-- }
BEGIN
-- {
    -- initialization block
    x_custom_sql := NULL;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL ();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    l_query := NULL;
    l_view_by := NULL;
    l_view_by_col := NULL;
    l_xtd := NULL;
    l_comparison_type := NULL;
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
    l_where_clause := NULL;
    l_mv := NULL;
    l_aggr_level_flag := NULL;
    l_cur_suffix := NULL;
    l_filter_clause := NULL;

    -- Process the parameters using the template package.
    opi_dbi_rpt_util_pkg.process_parameters (
            p_param            => p_param,
            p_view_by          => l_view_by,
            p_view_by_col_name => l_view_by_col,
            p_comparison_type  => l_comparison_type,
            p_xtd              => l_xtd,
            p_cur_suffix       => l_cur_suffix,
            p_where_clause     => l_where_clause,
            p_mv               => l_mv,
            p_join_tbl         => l_join_tbl,
            p_mv_level_flag    => l_aggr_level_flag,
            p_trend            => 'N',
            p_func_area        => 'OPI',
            p_version          => '12.0',
            p_role             => '',
            p_mv_set           => 'CURR_INV_EXP',
            p_mv_flag_type     => 'CURR_INV_EXP_LEVEL');

    -- Add the appropriate columns that need to be aggregated.
    -- On-Hand Value. Need totals but no priors.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'onhand_val_' || l_cur_suffix,
                                 p_alias_name => 'onhand_val',
                                 p_grand_total => 'Y',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.NO_PRIORS,
                                 p_to_date_type => 'NA');

    -- Expired Value. Need totals but no priors.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'expired_val_' || l_cur_suffix,
                                 p_alias_name => 'expired_val',
                                 p_grand_total => 'Y',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.NO_PRIORS,
                                 p_to_date_type => 'NA');

    -- Get the quantities also.
    -- On-Hand Quantities. No need for totals and priors.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'onhand_qty',
                                 p_alias_name => 'onhand_qty',
                                 p_grand_total => 'N',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.NO_PRIORS,
                                 p_to_date_type => 'NA');

    -- Expired Quantities. No need for totals and priors.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'expired_qty',
                                 p_alias_name => 'expired_qty',
                                 p_grand_total => 'N',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.NO_PRIORS,
                                 p_to_date_type => 'NA');

    -- Get the filtering clause for 0/NULL rows
    l_filter_clause := get_curr_inv_exp_filter_clause
                            (p_view_by_dim => l_view_by);

    -- Since there is no join to the time dimension, need a dummy condition
    -- at the start of the where clause, since it starts with an AND.
    l_where_clause := '1 = 1 ' || l_where_clause;

    -- The status query provided by POA
    l_query := poa_dbi_template_pkg.status_sql (
                p_fact_name         => l_mv,
                p_where_clause      => l_where_clause,
                p_join_tables       => l_join_tbl,
                p_use_windowing     => 'Y',
                p_col_name          => l_col_tbl,
                p_use_grpid         => 'N',
                p_paren_count       => 3,
                p_filter_where      => l_filter_clause,
                p_generate_viewby   => 'Y',
                p_in_join_tables    => NULL);

    -- Final report query with select clause etc.
    l_query := get_curr_inv_exp_sel_clause
                    (p_view_by_dim => l_view_by,
                     p_join_tbl => l_join_tbl) || '
               ' || ' from ' || '
               ' || l_query;

    -- Subinventory aggregation level flag.
    l_custom_rec.attribute_name := ':OPI_CURR_INV_EXP_AGG_FLAG';
    l_custom_rec.attribute_value := l_aggr_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;

    return;
-- }
END get_curr_inv_exp_stat_sql;

/*  get_curr_inv_exp_filter_clause

    Description
        Filter clause for the current inventory expiration report
        in case all relevant measures are 0/NULL.

    Input
        Viewby dimension, since qty is a criterion for filtering on
        viewby = item.

        Decode 0's as NULL, because we don't want to show anything for
        items that have 0 onhand.

    Output
        Filter clause

    History

    Date        Author              Action
    07/13/05    Dinkar Gupta        Wrote Function

*/

FUNCTION get_curr_inv_exp_filter_clause (p_view_by_dim IN VARCHAR2)
    RETURN VARCHAR2
IS
-- {
    l_filter_clause VARCHAR2 (20000);

    -- table column for filter clause
    l_col_rec POA_DBI_UTIL_PKG.POA_DBI_FLEX_FILTER_REC;
    l_col_tbl POA_DBI_UTIL_PKG.POA_DBI_FLEX_FILTER_TBL;
-- }
BEGIN
-- {
    -- initialization block
    l_filter_clause := NULL;
    l_col_rec := NULL;
    l_col_tbl := POA_DBI_UTIL_PKG.POA_DBI_FLEX_FILTER_TBL ();

    -- Basic columns to filter out:
    -- OPI_MEASURE3 Expired Value
    -- OPI_MEASURE6 On-Hand Value
    l_col_rec.measure_name := 'OPI_MEASURE3';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    l_col_rec.measure_name := 'OPI_MEASURE6';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    -- Item viewby special case
    -- For viewby item, filter out additionally on:
    -- OPI_MEASURE2 Expired Quantity
    -- OPI_MEASURE5 On-Hand Quantity
    IF (p_view_by_dim = C_VIEWBY_ITEM) THEN

        l_col_rec.measure_name := 'OPI_MEASURE2';
        l_col_rec.modifier := 'DECODE_0';
        l_col_tbl.extend;
        l_col_tbl(l_col_tbl.count) := l_col_rec;

        l_col_rec.measure_name := 'OPI_MEASURE5';
        l_col_rec.modifier := 'DECODE_0';
        l_col_tbl.extend;
        l_col_tbl(l_col_tbl.count) := l_col_rec;

    END IF;

    -- generate the filter clause
    l_filter_clause := poa_dbi_util_pkg.get_filter_where (p_cols => l_col_tbl);

    return l_filter_clause;
-- }
END get_curr_inv_exp_filter_clause;


/* get_curr_inv_exp_sel_clause

    Description
        Returns the select clause for the Current Inventory Expiration
        Status (Table) report query.

    Input

    Outputs
        1. l_sel_clause - Select clause of the report query

    History

    Date        Author              Action
    07/13/05    Dinkar Gupta        Wrote Function
*/
FUNCTION get_curr_inv_exp_sel_clause (p_view_by_dim IN VARCHAR2,
                                      p_join_tbl IN
                                      poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2
IS
-- {
    l_sel_clause VARCHAR2 (32767);
    l_description varchar2 (120);
    l_uom varchar2 (30);
    l_view_by_fact_col VARCHAR2(400);
-- }
BEGIN
-- {
    -- initialization block
    l_sel_clause := NULL;
    l_description := NULL;
    l_uom := NULL;
    l_view_by_fact_col := NULL;

    -- fact column view by's
    l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                (p_join_tbl => p_join_tbl);

    -- Description for item view by
    opi_dbi_rpt_util_pkg.get_viewby_item_columns (
                p_dim_name => p_view_by_dim,
                p_description => l_description,
                p_uom => l_uom);


    l_sel_clause :=
    'SELECT
    ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
      || l_description || ' OPI_ATTRIBUTE1,
    ' || l_uom || ' OPI_ATTRIBUTE2,
    ' || 'oset.OPI_MEASURE2,
    ' || 'oset.OPI_MEASURE3,
    ' || 'oset.OPI_MEASURE5,
    ' || 'oset.OPI_MEASURE6,
    ' || 'oset.OPI_MEASURE7,
    ' || 'oset.OPI_MEASURE8,
    ' || 'oset.OPI_MEASURE9,
    ' || 'oset.OPI_MEASURE10
    ' || 'FROM
    ' || '(SELECT (rank () over
    ' || ' (&ORDER_BY_CLAUSE nulls last,
    ' || l_view_by_fact_col || ')) - 1 rnk,
    ' || l_view_by_fact_col || ',
    ' || 'OPI_MEASURE2,
    ' || 'OPI_MEASURE3,
    ' || 'OPI_MEASURE5,
    ' || 'OPI_MEASURE6,
    ' || 'OPI_MEASURE7,
    ' || 'OPI_MEASURE8,
    ' || 'OPI_MEASURE9,
    ' || 'OPI_MEASURE10
    ' || 'FROM
    ' || '(SELECT
            ' || l_view_by_fact_col || ',
            ' || opi_dbi_rpt_util_pkg.raw_str
                            (p_str => 'c_expired_qty')
                                               || ' OPI_MEASURE2,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'c_expired_val')
                                               || ' OPI_MEASURE3,
            ' || opi_dbi_rpt_util_pkg.raw_str
                            (p_str => 'c_onhand_qty')
                                               || ' OPI_MEASURE5,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'c_onhand_val')
                                               || ' OPI_MEASURE6,
            ' || opi_dbi_rpt_util_pkg.percent_str
                            (p_numerator => 'c_expired_val',
                             p_denominator => 'c_onhand_val',
                             p_measure_name => 'OPI_MEASURE7')   || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'c_expired_val_total')
                                               || ' OPI_MEASURE8,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'c_onhand_val_total')
                                               || ' OPI_MEASURE9,
            ' || opi_dbi_rpt_util_pkg.percent_str
                            (p_numerator => 'c_expired_val_total',
                             p_denominator => 'c_onhand_val_total',
                             p_measure_name => 'OPI_MEASURE10');

    return l_sel_clause;
-- }
END get_curr_inv_exp_sel_clause;



/****************************************
 * Inventory Days On-Hand
 ****************************************/

/* get_inv_days_onh_sql

    Description
        Inventory Days On-Hand (Table) report query function.
        3 part union-all query.

    Inputs
        1. p_params - table of parameters with which report was run.

    Outputs
        1. x_custom_sql - sql report query.
        2. x_custom_output - table of values for bind variables in
                             sql report query.

    History

    Date        Author              Action
    07/11/05    Dinkar Gupta        Wrote Function
*/
PROCEDURE get_inv_days_onh_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                                x_custom_sql OUT NOCOPY VARCHAR2,
                                x_custom_output OUT NOCOPY
                                    BIS_QUERY_ATTRIBUTES_TBL)
IS
-- {
    l_query VARCHAR2 (32767);

    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);


    l_xtd VARCHAR2(10);

    l_comparison_type VARCHAR2(1);
    l_cur_suffix VARCHAR2 (5);

    l_onh_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_prod_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_ship_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;

    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

    l_onh_where_clause VARCHAR2 (2000);
    l_prod_where_clause VARCHAR2 (2000);
    l_ship_where_clause VARCHAR2 (2000);

    l_onh_mv VARCHAR2 (30);
    l_prod_mv VARCHAR2 (30);
    l_ship_mv VARCHAR2 (30);

    l_onh_aggr_level_flag VARCHAR2(1);
    l_prod_aggr_level_flag VARCHAR2(1);
    l_ship_aggr_level_flag VARCHAR2(1);

    l_custom_rec BIS_QUERY_ATTRIBUTES;

    l_filter_clause VARCHAR2 (20000);

    l_unionall_tbl poa_dbi_util_pkg.POA_DBI_MV_TBL;

    l_per_length NUMBER;
-- }
BEGIN
-- {
    -- initialization block
    x_custom_sql := NULL;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL ();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    l_query := NULL;
    l_view_by := NULL;
    l_view_by_col := NULL;
    l_xtd := NULL;
    l_comparison_type := NULL;
    l_onh_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_prod_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_ship_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
    l_onh_where_clause := NULL;
    l_prod_where_clause := NULL;
    l_ship_where_clause := NULL;
    l_onh_mv := NULL;
    l_prod_mv := NULL;
    l_ship_mv := NULL;
    l_onh_aggr_level_flag := NULL;
    l_prod_aggr_level_flag := NULL;
    l_ship_aggr_level_flag := NULL;
    l_cur_suffix := NULL;
    l_filter_clause := NULL;
    l_unionall_tbl := poa_dbi_util_pkg.POA_DBI_MV_TBL ();
    l_per_length := 0;

    -- Process the parameters using the template package for the onhand
    -- branch.
    opi_dbi_rpt_util_pkg.process_parameters (
            p_param            => p_param,
            p_view_by          => l_view_by,
            p_view_by_col_name => l_view_by_col,
            p_comparison_type  => l_comparison_type,
            p_xtd              => l_xtd,
            p_cur_suffix       => l_cur_suffix,
            p_where_clause     => l_onh_where_clause,
            p_mv               => l_onh_mv,
            p_join_tbl         => l_join_tbl,
            p_mv_level_flag    => l_onh_aggr_level_flag,
            p_trend            => 'N',
            p_func_area        => 'OPI',
            p_version          => '12.0',
            p_role             => '',
            p_mv_set           => 'INV_VAL_UOM',
            p_mv_flag_type     => 'INV_VAL_UOM_LEVEL');

    -- Process the parameters using the template package for the
    -- production consumption branch.
    opi_dbi_rpt_util_pkg.process_parameters (
            p_param            => p_param,
            p_view_by          => l_view_by,
            p_view_by_col_name => l_view_by_col,
            p_comparison_type  => l_comparison_type,
            p_xtd              => l_xtd,
            p_cur_suffix       => l_cur_suffix,
            p_where_clause     => l_prod_where_clause,
            p_mv               => l_prod_mv,
            p_join_tbl         => l_join_tbl,
            p_mv_level_flag    => l_prod_aggr_level_flag,
            p_trend            => 'N',
            p_func_area        => 'OPI',
            p_version          => '12.0',
            p_role             => '',
            p_mv_set           => 'PROD_CONS',
            p_mv_flag_type     => 'PROD_CONS_LEVEL');

    -- Process the parameters using the template package for the
    -- shipment consumption branch.
    opi_dbi_rpt_util_pkg.process_parameters (
            p_param            => p_param,
            p_view_by          => l_view_by,
            p_view_by_col_name => l_view_by_col,
            p_comparison_type  => l_comparison_type,
            p_xtd              => l_xtd,
            p_cur_suffix       => l_cur_suffix,
            p_where_clause     => l_ship_where_clause,
            p_mv               => l_ship_mv,
            p_join_tbl         => l_join_tbl,
            p_mv_level_flag    => l_ship_aggr_level_flag,
            p_trend            => 'N',
            p_func_area        => 'OPI',
            p_version          => '12.0',
            p_role             => '',
            p_mv_set           => 'COGS',
            p_mv_flag_type     => 'COGS_LEVEL');


    -- Add the appropriate columns for the onhand branch.
    -- Onhand Quantity is needed for viewby item.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_onh_col_tbl,
                                 p_col_name => 'onhand_qty',
                                 p_alias_name => 'onhand_qty',
                                 p_grand_total => 'N',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.NO_PRIORS,
                                 p_to_date_type => 'RLX');

    -- On-Hand Value. No need for totals.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_onh_col_tbl,
                                 p_col_name => 'onhand_value_' || l_cur_suffix,
                                 p_alias_name => 'onhand_val',
                                 p_grand_total => 'Y',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    -- Production Consumption. No need for totals.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_prod_col_tbl,
                                 p_col_name =>
                                    'prod_usage_val_' || l_cur_suffix,
                                 p_alias_name => 'prod_usage_val',
                                 p_grand_total => 'Y',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    -- Shipment Consumption. No need for totals.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_ship_col_tbl,
                                 p_col_name =>
                                    'cogs_val_' || l_cur_suffix,
                                 p_alias_name => 'cogs_val',
                                 p_grand_total => 'Y',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    -- Get the filtering clause
    l_filter_clause := get_inv_doh_filter_clause (p_view_by_dim => l_view_by);

    -- Merge all data into the giant UNION ALL query data structure
    l_unionall_tbl.extend;
    l_unionall_tbl(l_unionall_tbl.count).mv_name := l_onh_mv;
    l_unionall_tbl(l_unionall_tbl.count).mv_col := l_onh_col_tbl;
    l_unionall_tbl(l_unionall_tbl.count).mv_where := l_onh_where_clause;
    l_unionall_tbl(l_unionall_tbl.count).in_join_tbls := NULL;
    l_unionall_tbl(l_unionall_tbl.count).use_grp_id := 'N';

    l_unionall_tbl.extend;
    l_unionall_tbl(l_unionall_tbl.count).mv_name := l_prod_mv;
    l_unionall_tbl(l_unionall_tbl.count).mv_col := l_prod_col_tbl;
    l_unionall_tbl(l_unionall_tbl.count).mv_where := l_prod_where_clause;
    l_unionall_tbl(l_unionall_tbl.count).in_join_tbls := NULL;
    l_unionall_tbl(l_unionall_tbl.count).use_grp_id := 'N';

    l_unionall_tbl.extend;
    l_unionall_tbl(l_unionall_tbl.count).mv_name := l_ship_mv;
    l_unionall_tbl(l_unionall_tbl.count).mv_col := l_ship_col_tbl;
    l_unionall_tbl(l_unionall_tbl.count).mv_where := l_ship_where_clause;
    l_unionall_tbl(l_unionall_tbl.count).in_join_tbls := NULL;
    l_unionall_tbl(l_unionall_tbl.count).use_grp_id := 'N';

    -- Figure out the period length
    CASE
    -- {
        WHEN l_xtd = 'RLW' THEN
            l_per_length := 7;
        WHEN l_xtd = 'RLM' THEN
            l_per_length := 30;
        WHEN l_xtd = 'RLQ' THEN
            l_per_length := 90;
        WHEN l_xtd = 'RLY' THEN
            l_per_length := 365;
    -- }
    END CASE;

    -- The union all query provided by POA
    l_query := poa_dbi_template_pkg.union_all_status_sql (
                p_mv => l_unionall_tbl,
                p_join_tables => l_join_tbl,
                p_use_windowing => 'Y',
                p_paren_count => 5,
                p_filter_where => l_filter_clause,
                p_generate_viewby => 'Y');

    -- Final report query with select clause etc.
    l_query := get_inv_doh_sel_clause
                (p_view_by_dim => l_view_by,
                 p_join_tbl => l_join_tbl) || '
               ' || ' from (' || '
               ' || l_query;

    -- Make the nested pattern ITD since onhand quantity (and weight/
    -- volume) are reported as a balance..
    l_query := opi_dbi_rpt_util_pkg.replace_n
                    (p_orig_str => l_query,
                     p_match_str => '&RLX_NESTED_PATTERN',
                     p_replace_str => C_ROLLING_ITD_PATTERN,
                     p_start_pos => 1,
                     p_num_times => 2);

    -- Get bind variables for the rolling period reports.
    poa_dbi_util_pkg.get_custom_status_binds
            (x_custom_output => x_custom_output);
    poa_dbi_util_pkg.get_custom_rolling_binds
            (p_custom_output => x_custom_output,
             p_xtd => l_xtd);

    -- Aggregation level flags
    l_custom_rec.attribute_name := ':OPI_AGGREGATION_LEVEL_FLAG';
    l_custom_rec.attribute_value := l_onh_aggr_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    l_custom_rec.attribute_name := ':OPI_PROD_CONS_AGG_FLAG';
    l_custom_rec.attribute_value := l_prod_aggr_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    l_custom_rec.attribute_name := ':OPI_COGS_SHIP_AGG_FLAG';
    l_custom_rec.attribute_value := l_ship_aggr_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    l_custom_rec.attribute_name := ':OPI_INV_DOH_PER_LEN';
    l_custom_rec.attribute_value := l_per_length;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;

    return;
-- }
END get_inv_days_onh_sql;

/*  get_inv_doh_filter_clause

    Description
        Filter clause for the inventory days onhand report
        in case all relevant measures are 0/NULL.

    Input
        Viewby dimension, since qty is a criterion for filtering on
        viewby = item.

        Decode 0's as NULL, because we don't want to show anything for
        items that have 0 onhand.

    Output
        Filter clause

    History

    Date        Author              Action
    07/13/05    Dinkar Gupta        Wrote Function

*/

FUNCTION get_inv_doh_filter_clause (p_view_by_dim IN VARCHAR2)
    RETURN VARCHAR2
IS
-- {
    l_filter_clause VARCHAR2 (20000);

    -- table column for filter clause
    l_col_rec POA_DBI_UTIL_PKG.POA_DBI_FLEX_FILTER_REC;
    l_col_tbl POA_DBI_UTIL_PKG.POA_DBI_FLEX_FILTER_TBL;
-- }
BEGIN
-- {
    -- initialization block
    l_filter_clause := NULL;
    l_col_rec := NULL;
    l_col_tbl := POA_DBI_UTIL_PKG.POA_DBI_FLEX_FILTER_TBL ();

    -- Basic columns to filter out:
    -- Cannot use OPI_MEASURE10/OPI_MEASURE11 because they are
    -- computed in outer clause
    -- OPI_MEASURE3 - Prior (On-Hand Value)
    -- OPI_MEASURE4 - On-Hand Value
    -- OPI_MEASURE6 - Production Consumption Value
    -- OPI_MEASURE7 - Shipments Consumption Value
    -- OPI_MEASURE8 - Total Value
    -- OPI_MEASURE9 - Daily Average
    -- OPI_MEASURE10- Prior Days Onhand
    -- OPI_MEASURE11- Days Onhand
    -- OPI_MEASURE17- Change
    l_col_rec.measure_name := 'OPI_MEASURE3';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    l_col_rec.measure_name := 'OPI_MEASURE4';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    l_col_rec.measure_name := 'OPI_MEASURE6';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    l_col_rec.measure_name := 'OPI_MEASURE7';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    l_col_rec.measure_name := 'OPI_MEASURE8';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    l_col_rec.measure_name := 'OPI_MEASURE9';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    l_col_rec.measure_name := 'OPI_MEASURE10';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    l_col_rec.measure_name := 'OPI_MEASURE11';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    l_col_rec.measure_name := 'OPI_MEASURE17';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    -- Item viewby special case
    -- For viewby item, filter out additionally on:
    -- OPI_MEASURE2 Expired Quantity
    IF (p_view_by_dim = C_VIEWBY_ITEM) THEN

        l_col_rec.measure_name := 'OPI_MEASURE2';
        l_col_rec.modifier := 'DECODE_0';
        l_col_tbl.extend;
        l_col_tbl(l_col_tbl.count) := l_col_rec;

    END IF;

    -- generate the filter clause
    l_filter_clause := poa_dbi_util_pkg.get_filter_where (p_cols => l_col_tbl);

    return l_filter_clause;
-- }
END get_inv_doh_filter_clause;


/* get_inv_doh_sel_clause

    Description
        Returns the select clause for the Inventory Days Onhand
        Status (Table) report query.

    Input

    Outputs
        1. l_sel_clause - Select clause of the report query

    History

    Date        Author              Action
    07/13/05    Dinkar Gupta        Wrote Function
*/
FUNCTION get_inv_doh_sel_clause (p_view_by_dim IN VARCHAR2,
                                 p_join_tbl IN
                                    poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2
IS
-- {
    l_sel_clause VARCHAR2 (32767);
    l_description varchar2 (120);
    l_uom varchar2 (30);
    l_view_by_fact_col VARCHAR2(400);
-- }
BEGIN
-- {
    -- initialization block
    l_sel_clause := NULL;
    l_description := NULL;
    l_uom := NULL;
    l_view_by_fact_col := NULL;

    -- fact column view by's
    l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                (p_join_tbl => p_join_tbl);

    -- Description for item view by
    opi_dbi_rpt_util_pkg.get_viewby_item_columns (
                p_dim_name => p_view_by_dim,
                p_description => l_description,
                p_uom => l_uom);

    l_sel_clause :=
    'SELECT /* outer query */
    ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
      || l_description || ' OPI_ATTRIBUTE1,
    ' || l_uom || ' OPI_ATTRIBUTE2,
    ' || 'OPI_MEASURE2,
    ' || 'OPI_MEASURE3,
    ' || 'OPI_MEASURE4,
    ' || 'OPI_MEASURE12,
    ' || 'OPI_MEASURE6,
    ' || 'OPI_MEASURE13,
    ' || 'OPI_MEASURE7,
    ' || 'OPI_MEASURE14,
    ' || 'OPI_MEASURE8,
    ' || 'OPI_MEASURE15,
    ' || 'OPI_MEASURE9,
    ' || 'OPI_MEASURE16,
    ' || 'OPI_MEASURE10,
    ' || 'OPI_MEASURE11,
    ' || 'OPI_MEASURE17,
    ' || 'OPI_MEASURE18,
    ' || 'OPI_MEASURE19
    ' || 'FROM
    ' || '(SELECT (rank () over /* rank clause */
    ' || ' (&ORDER_BY_CLAUSE nulls last,
    ' || l_view_by_fact_col || ')) - 1 rnk,
    ' || l_view_by_fact_col || ',
    ' || 'OPI_MEASURE2,
    ' || 'OPI_MEASURE3,
    ' || 'OPI_MEASURE4,
    ' || 'OPI_MEASURE12,
    ' || 'OPI_MEASURE6,
    ' || 'OPI_MEASURE13,
    ' || 'OPI_MEASURE7,
    ' || 'OPI_MEASURE14,
    ' || 'OPI_MEASURE8,
    ' || 'OPI_MEASURE15,
    ' || 'OPI_MEASURE9,
    ' || 'OPI_MEASURE16,
    ' || 'OPI_MEASURE10,
    ' || 'OPI_MEASURE11,
    ' || 'OPI_MEASURE17,
    ' || 'OPI_MEASURE18,
    ' || 'OPI_MEASURE19
    ' || 'FROM
    ' || '(SELECT /* extra for paren_cnt = 5 */
    ' || l_view_by_fact_col || ',
    ' || 'OPI_MEASURE2,
    ' || 'OPI_MEASURE3,
    ' || 'OPI_MEASURE4,
    ' || 'OPI_MEASURE12,
    ' || 'OPI_MEASURE6,
    ' || 'OPI_MEASURE13,
    ' || 'OPI_MEASURE7,
    ' || 'OPI_MEASURE14,
    ' || 'OPI_MEASURE8,
    ' || 'OPI_MEASURE15,
    ' || 'OPI_MEASURE9,
    ' || 'OPI_MEASURE16,
    ' || 'OPI_MEASURE10,
    ' || 'OPI_MEASURE11,
    ' || 'OPI_MEASURE17,
    ' || 'OPI_MEASURE18,
    ' || 'OPI_MEASURE19
    ' || 'FROM
    ' || '(SELECT /* days onhand computation */
    ' || l_view_by_fact_col || ',
    ' || 'OPI_MEASURE2,
    ' || 'OPI_MEASURE3,
    ' || 'OPI_MEASURE4,
    ' || 'OPI_MEASURE12,
    ' || 'OPI_MEASURE6,
    ' || 'OPI_MEASURE13,
    ' || 'OPI_MEASURE7,
    ' || 'OPI_MEASURE14,
    ' || 'OPI_MEASURE8,
    ' || 'OPI_MEASURE15,
    ' || 'OPI_MEASURE9,
    ' || 'OPI_MEASURE16,
    -- not truly a percentage, so multiply denom by 100
    ' || opi_dbi_rpt_util_pkg.percent_str
                    (p_numerator => 'OPI_MEASURE3',
                     p_denominator => '(p_cons_daily_avg * 100)',
                     p_measure_name => 'OPI_MEASURE10') || ',
    -- not truly a percentage, so multiply denom by 100
    ' || opi_dbi_rpt_util_pkg.percent_str
                    (p_numerator => 'OPI_MEASURE4',
                     p_denominator => '(OPI_MEASURE9 * 100)',
                     p_measure_name => 'OPI_MEASURE11') || ',
    -- not truly a percentage, so multiply denom by 100
    ' || opi_dbi_rpt_util_pkg.percent_str
                    (p_numerator => 'OPI_MEASURE12',
                     p_denominator => '(OPI_MEASURE16 * 100)',
                     p_measure_name => 'OPI_MEASURE17') || ',
    ' || opi_dbi_rpt_util_pkg.change_pct_str
                    (p_new_numerator => 'OPI_MEASURE4',
                     p_new_denominator => '(OPI_MEASURE9 * 100)',
                     p_old_numerator => 'OPI_MEASURE3',
                     p_old_denominator => '(p_cons_daily_avg * 100)',
                     p_measure_name => 'OPI_MEASURE18') || ',
    ' || opi_dbi_rpt_util_pkg.change_pct_str
                    (p_new_numerator => 'OPI_MEASURE12',
                     p_new_denominator => '(OPI_MEASURE16 * 100)',
                     p_old_numerator => 'p_onhand_val_total',
                     p_old_denominator => '(p_cons_daily_avg_total * 100)',
                     p_measure_name => 'OPI_MEASURE19') || '
    ' || 'FROM
    ' || '(SELECT /* basic measure computation */
            ' || l_view_by_fact_col || ',
            ' || opi_dbi_rpt_util_pkg.raw_str
                            (p_str => 'c_onhand_qty')
                                               || ' OPI_MEASURE2,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'p_onhand_val')
                                               || ' OPI_MEASURE3,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'c_onhand_val')
                                               || ' OPI_MEASURE4,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'c_onhand_val_total')
                                               || ' OPI_MEASURE12,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'c_prod_usage_val')
                                               || ' OPI_MEASURE6,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'c_prod_usage_val_total')
                                               || ' OPI_MEASURE13,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'c_cogs_val')
                                               || ' OPI_MEASURE7,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'c_cogs_val_total')
                                               || ' OPI_MEASURE14,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str =>
                                opi_dbi_rpt_util_pkg.nvl_str
                                    ('c_prod_usage_val') || ' + ' ||
                                opi_dbi_rpt_util_pkg.nvl_str
                                    ('c_cogs_val'))
                                               || ' OPI_MEASURE8,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str =>
                                opi_dbi_rpt_util_pkg.nvl_str
                                    ('c_prod_usage_val_total') || ' + ' ||
                                opi_dbi_rpt_util_pkg.nvl_str
                                    ('c_cogs_val_total'))
                                               || ' OPI_MEASURE15,
            -- not truly a percentage, so multiply denom by 100
            ' || opi_dbi_rpt_util_pkg.percent_str_basic
                            (p_numerator =>
                                opi_dbi_rpt_util_pkg.neg_str (
                                    opi_dbi_rpt_util_pkg.nvl_str
				       ('c_prod_usage_val') || ' + ' ||
                                    opi_dbi_rpt_util_pkg.nvl_str
				        ('c_cogs_val')),
                             p_denominator => ('(:OPI_INV_DOH_PER_LEN * 100)'),
                             p_measure_name => 'OPI_MEASURE9') || ',
            -- not truly a percentage, so multiply denom by 100
            ' ||  opi_dbi_rpt_util_pkg.percent_str_basic
                            (p_numerator =>
                                opi_dbi_rpt_util_pkg.neg_str (
                                    opi_dbi_rpt_util_pkg.nvl_str
				           ('c_prod_usage_val_total') || ' + ' ||
                                    opi_dbi_rpt_util_pkg.nvl_str
                                           ('c_cogs_val_total')),
                             p_denominator => ('(:OPI_INV_DOH_PER_LEN * 100)'),
                             p_measure_name => 'OPI_MEASURE16') || ',
            ' || ' null OPI_MEASURE10,
            ' || ' null OPI_MEASURE11,
            ' || ' null OPI_MEASURE17,
            ' || ' null OPI_MEASURE18,
            ' || ' null OPI_MEASURE19,
            ' || ' p_onhand_val_total,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str =>
                                opi_dbi_rpt_util_pkg.nvl_str
                                    ('p_prod_usage_val') || ' + ' ||
                                opi_dbi_rpt_util_pkg.nvl_str
                                    ('p_cogs_val'))
                                               || ' p_total_cons_val,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str =>
                                opi_dbi_rpt_util_pkg.nvl_str
                                    ('p_prod_usage_val_total') || ' + ' ||
                                opi_dbi_rpt_util_pkg.nvl_str
                                    ('p_cogs_val_total'))
                                               || ' p_total_cons_val_total,
            -- not truly a percentage, so multiply denom by 100
            ' || opi_dbi_rpt_util_pkg.percent_str_basic
                            (p_numerator =>
                                opi_dbi_rpt_util_pkg.neg_str (
                                    opi_dbi_rpt_util_pkg.nvl_str
				        ('p_prod_usage_val') || ' + ' ||
                                    opi_dbi_rpt_util_pkg.nvl_str
				        ('p_cogs_val')),
                             p_denominator => ('(:OPI_INV_DOH_PER_LEN * 100)'),
                             p_measure_name => 'p_cons_daily_avg') || ',
            -- not truly a percentage, so multiply denom by 100
            ' ||  opi_dbi_rpt_util_pkg.percent_str_basic
                            (p_numerator =>
                                opi_dbi_rpt_util_pkg.neg_str (
				  opi_dbi_rpt_util_pkg.nvl_str
                                    ('p_prod_usage_val_total') || ' + ' ||
                                  opi_dbi_rpt_util_pkg.nvl_str
                                    ('p_cogs_val_total')),
                             p_denominator => ('(:OPI_INV_DOH_PER_LEN * 100)'),
                             p_measure_name => 'p_cons_daily_avg_total');

    return l_sel_clause;
-- }
END get_inv_doh_sel_clause;


/****************************************
 * Current Inventory Status
 ****************************************/

/* get_curr_inv_stat_sql

    Description
        Current Inventory Status (Table) report query function.

    Inputs
        1. p_params - table of parameters with which report was run.

    Outputs
        1. x_custom_sql - sql report query.
        2. x_custom_output - table of values for bind variables in
                             sql report query.

    History

    Date        Author              Action
    07/18/05    Dinkar Gupta        Wrote Function
*/
PROCEDURE get_curr_inv_stat_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                                 x_custom_sql OUT NOCOPY VARCHAR2,
                                 x_custom_output OUT NOCOPY
                                    BIS_QUERY_ATTRIBUTES_TBL)
IS
-- {
    l_query VARCHAR2 (32767);

    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_xtd VARCHAR2(10);
    l_comparison_type VARCHAR2(1);

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_in_join_rec poa_dbi_util_pkg.POA_DBI_IN_JOIN_REC;

    l_where_clause VARCHAR2 (2000);
    l_mv VARCHAR2 (30);

    l_aggr_level_flag VARCHAR2(1);

    l_custom_rec BIS_QUERY_ATTRIBUTES;

    l_cur_suffix VARCHAR2 (5);

    l_filter_clause VARCHAR2 (20000);

    l_view_by_str VARCHAR2 (1000);
    l_view_by_str_new VARCHAR2 (1000);
    l_view_by_str_nvl VARCHAR2 (1000);

    l_item_id VARCHAR2(100);

    l_viewby_rank_clause VARCHAR2 (4000);

-- }
BEGIN
-- {
    -- initialization block
    x_custom_sql := NULL;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL ();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    l_query := NULL;
    l_view_by := NULL;
    l_view_by_col := NULL;
    l_xtd := NULL;
    l_comparison_type := NULL;
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
    l_in_join_tbl := poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL ();
    l_in_join_rec := NULL;
    l_where_clause := NULL;
    l_mv := NULL;
    l_aggr_level_flag := NULL;
    l_cur_suffix := NULL;
    l_filter_clause := NULL;
    l_view_by_str := NULL;
    l_view_by_str_new := NULL;
    l_view_by_str_nvl := NULL;
    l_item_id := NULL;
    l_viewby_rank_clause := NULL;

    -- Process the parameters using the template package for the
    -- shipment consumption branch.
    opi_dbi_rpt_util_pkg.process_parameters (
            p_param            => p_param,
            p_view_by          => l_view_by,
            p_view_by_col_name => l_view_by_col,
            p_comparison_type  => l_comparison_type,
            p_xtd              => l_xtd,
            p_cur_suffix       => l_cur_suffix,
            p_where_clause     => l_where_clause,
            p_mv               => l_mv,
            p_join_tbl         => l_join_tbl,
            p_mv_level_flag    => l_aggr_level_flag,
            p_trend            => 'N',
            p_func_area        => 'OPI',
            p_version          => '12.0',
            p_role             => '',
            p_mv_set           => 'CURR_INV_STAT',
            p_mv_flag_type     => 'CURR_INV_STAT_LEVEL');


    -- Build the query from the SELECT clause
    l_query := get_curr_inv_stat_sel_clause
                (p_view_by_dim => l_view_by,
                 p_join_tbl => l_join_tbl);

    -- The inner join table for viewby grade
    get_curr_inv_stat_mln (p_param => p_param, p_query => l_query);

    -- The inner join table for viewby inv cat
    get_curr_inv_stat_eni (p_param => p_param, p_query => l_query);

    -- Since this query runs directly on the OLTP tables,
    -- get the correctly formatted viewby column keys from the
    -- OLTP tables, including default values for NULL.
    get_curr_inv_viewby_cols (p_view_by => l_view_by,
                              p_view_by_col => l_view_by_col,
                              p_query => l_query);

    -- Get the parameter conditions in the where clause
    get_curr_inv_stat_param_cond (p_param => p_param, p_query => l_query);

    -- Get the security where clause
    get_curr_inv_sec_where_clause (p_param => p_param, p_query => l_query);

    -- The outermost ranking/order by clause with
    -- the join to the dimension tables.
    l_viewby_rank_clause :=
        poa_dbi_template_pkg.get_viewby_rank_clause (
            p_join_tables       => l_join_tbl,
            p_use_windowing     => 'Y');

    -- Put the query together
    -- There should be no need for a filter clause.
    l_query := l_query || ' ) ) ) oset,
    ' || ' (SELECT (substr (&ITEM+ENI_ITEM_ORG, 1, instr (&ITEM+ENI_ITEM_ORG, ''-'') - 1)) inventory_item_id FROM eni_oltp_item_star where id = &ITEM+ENI_ITEM_ORG) item_uom,
    ' || l_viewby_rank_clause;

    x_custom_sql := l_query;

    return;
-- }
END get_curr_inv_stat_sql;

/* get_curr_inv_stat_mln

    Description
        Current Inventory Status (Table) MTL_LOT_NUMBERS procedure.

        For viewby or parameter of item grade, join MOQ to MLN and
        select the grade_code from MTL_LOT_NUMBERS.

        Also append the relevant join conditions to the where clause.

    Inputs
        1. p_params - table of parameters with which report was run.
        2. p_query - query with placeholders

    Outputs
        1. p_query - query with MLN alias and join conditions.

    History

    Date        Author              Action
    07/18/05    Dinkar Gupta        Wrote Function
*/
PROCEDURE get_curr_inv_stat_mln
            (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
             p_query IN OUT NOCOPY VARCHAR2)
IS
-- {

    l_join_mln BOOLEAN;
    l_outer_join_mln VARCHAR2 (4);
-- }
BEGIN
-- {
    -- Initialization block
    l_join_mln := FALSE;
    l_outer_join_mln := '(+)';  -- by default, outer join

    FOR i in 1..p_param.count
    LOOP
    -- {
        -- If only the Viewby is Item grade, must outer join mln
        IF (p_param(i).parameter_name = 'VIEW_BY' AND
            p_param(i).parameter_value =
                    'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL') THEN
        -- {
            l_join_mln := TRUE;
        -- }
        END IF;

        -- If an  item grade parameter has been specified,
        -- join to the mtl_lot_numbers table need not be an outer join.
        IF (p_param(i).parameter_name =
                    'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL'
            AND
            NOT (p_param(i).parameter_id is null OR
                 p_param(i).parameter_id = 'All') ) THEN
        -- {
            l_join_mln := TRUE;
            -- no need to outer join since specific grade parameter value
            -- given.
            l_outer_join_mln := '';
        -- }
        END IF;
    -- }
    END LOOP;

    IF (l_join_mln) THEN
    -- {
        p_query := replace (p_query, ':OPI_MLN_TABLE',
                            'mtl_lot_numbers mln, ');

        -- Also append the relevant conditions to the where clause
        -- with the correct outer join conditions.
        p_query := replace (p_query, ':OPI_MLN_CONDITIONS',
            ' AND fact.organization_id = mln.organization_id' ||
                    l_outer_join_mln ||
            ' AND fact.inventory_item_id = mln.inventory_item_id' ||
                    l_outer_join_mln ||
            ' AND fact.lot_number = mln.lot_number' ||
                    l_outer_join_mln || ' ');
    -- }
    ELSE
    -- {
        -- MLN is not required
        p_query := replace (p_query, ':OPI_MLN_TABLE', '');
        p_query := replace (p_query, ':OPI_MLN_CONDITIONS', '');
    -- }

    END IF;

    return;

-- }
END get_curr_inv_stat_mln;

/* get_curr_inv_stat_eni

    Description
        Current Inventory Status (Table) ENI_OLTP_ITEM_STAR procedure.

        For viewby parameter of item cat, join MOQ to ENI_OLTP_ITEM_STAR
        and select inv_category_id from ENI_OLTP_ITEM_STAR

        Also append the relevant join conditions to the where clause.

    Inputs
        1. p_viewby - viewby dimension key.
        2. p_query - query with placeholders

    Outputs
        1. p_query - query with ENI alias and join conditions.

    History

    Date        Author              Action
    07/18/05    Dinkar Gupta        Wrote Function
*/
PROCEDURE get_curr_inv_stat_eni
            (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
             p_query IN OUT NOCOPY VARCHAR2)
IS
-- {
    l_join_eni BOOLEAN;
-- }
BEGIN
-- {

    -- initialization block
    l_join_eni := FALSE;

    FOR i in 1..p_param.count
    LOOP
    -- {
        -- If only the Viewby is Item grade, must outer join mln
        IF ( (p_param(i).parameter_name = 'VIEW_BY' AND
              p_param(i).parameter_value =
                    'ITEM+ENI_ITEM_INV_CAT') OR
             (p_param(i).parameter_name =
                    'ITEM+ENI_ITEM_INV_CAT'
              AND
              NOT (p_param(i).parameter_id is null OR
                   p_param(i).parameter_id = 'All')) ) THEN
        -- {
            l_join_eni := TRUE;
        -- }
        END IF;
    -- }
    END LOOP;

    IF (l_join_eni) THEN
    -- {
        p_query := replace (p_query, ':OPI_ENI_OLTP_STAR_TABLE',
                            'eni_oltp_item_star eios, ');

        -- Also append the relevant conditions to the where clause
        -- with the correct outer join conditions.
        p_query := replace (p_query, ':OPI_ENI_OLTP_STAR_COND',
            ' AND fact.organization_id = eios.organization_id ' ||
            ' AND fact.inventory_item_id = eios.inventory_item_id ');
    -- }
    ELSE
    -- {
        -- ENI is not required
        p_query := replace (p_query, ':OPI_ENI_OLTP_STAR_TABLE', '');
        p_query := replace (p_query, ':OPI_ENI_OLTP_STAR_COND', '');
    -- }

    END IF;


    return;

-- }
END get_curr_inv_stat_eni;

/* get_curr_inv_viewby_format

    Description
        Current Inventory Status (Table) viewby column formatted
        with decodes joining various columns to build various keys.

    Inputs
        1. p_viewby - Dimension level key of viewby

    Output
        3. l_viewby_format - Formatted viewby

    History

    Date        Author              Action
    07/20/05    Dinkar Gupta        Wrote Function


*/
FUNCTION get_curr_inv_viewby_format (p_viewby IN VARCHAR2)
    RETURN VARCHAR2
IS
-- {
    l_viewby_format VARCHAR2 (1000);
-- }
BEGIN
-- {

    -- initialization block
    l_viewby_format := NULL;

    IF (p_viewby = 'ORGANIZATION+OPI_SUB_LOCATOR_LVL') THEN
    -- {
        l_viewby_format := ' decode (fact.locator_id,
                                    NULL, ''-1'',
                                    fact.locator_id || ''-'' || fact.subinventory_code || ''-'' || fact.organization_id) ';
    -- }
    ELSIF (p_viewby = 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL') THEN
    -- {
        l_viewby_format := ' decode (mln.grade_code,
                                     NULL, ''-1'',
                                     mln.grade_code || ''-'' || fact.inventory_item_id || ''-'' || fact.organization_id) ';
    -- }
    ELSIF (p_viewby = 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL') THEN
    -- {
        l_viewby_format := ' decode (fact.lot_number,
                                     NULL, ''-2'',
                                     fact.lot_number || ''-'' || fact.inventory_item_id || ''-'' || fact.organization_id) ';
    -- }
    ELSIF (p_viewby = 'ITEM+ENI_ITEM_ORG') THEN
    -- {
        l_viewby_format :=
            ' (fact.inventory_item_id || ''-'' || fact.organization_id) ';
    --}
    ELSIF (p_viewby = 'ITEM+ENI_ITEM_INV_CAT') THEN
    -- {
        l_viewby_format :=
            ' nvl (eios.inv_category_id, -1) ';
    --}
    ELSIF (p_viewby = 'ORGANIZATION+ORGANIZATION') THEN
    -- {
        l_viewby_format := ' to_char (fact.organization_id) ';
    --}
    ELSIF (p_viewby = 'ORGANIZATION+ORGANIZATION_SUBINVENTORY') THEN
    -- {
        l_viewby_format := ' decode (fact.subinventory_code,
                                    NULL, ''-1'',
                                    fact.subinventory_code || ''-'' || fact.organization_id) ';
    --}
    END IF;

    return l_viewby_format;

-- }
END get_curr_inv_viewby_format;


/* get_curr_inv_viewby_cols

    Description
        Current Inventory Status (Table) viewby column replacements.

        This function identifies the viewby column in the inner
        query and what it should be replaced by to handle the NULL
        values of the viewby. Since the Current Inventory Status
        query is written on OLTP tables, the NULL values for certain
        dimensions (e.g. lot) have not been replaced with their
        'Unassigned' id's (e.g. -2) in the report query.

    Inputs
        1. p_view_by - Dimension level key of viewby
        2. p_view_by_col - Standard column alias for dimension level
        3. p_query - Input query with place holders

    Outputs
        1. p_query - query with viewby column name replaced

    History

    Date        Author              Action
    07/18/05    Dinkar Gupta        Wrote Function
*/
PROCEDURE get_curr_inv_viewby_cols
            (p_view_by IN VARCHAR2,
             p_view_by_col IN VARCHAR2,
             p_query IN OUT NOCOPY VARCHAR2)
IS
-- {
    l_view_by_str VARCHAR2 (1000);
-- }
BEGIN
-- {
    -- initialization block
    l_view_by_str := get_curr_inv_viewby_format (p_view_by);

    -- replace the placeholders
    p_query := replace (p_query, ':OPI_CURR_INV_STAT_VIEWBY_ALIAS',
                        p_view_by_col);
    p_query := replace (p_query, ':OPI_CURR_INV_STAT_VIEWBY', l_view_by_str);
    return;

-- }
END get_curr_inv_viewby_cols;

/* get_curr_inv_stat_param_cond

    Description
        Current Inventory Status (Table) inner parameter conditions
        statement.

    Inputs
        1. p_params - table of parameters with which report was run.
        2. p_query - query with placeholders

    Outputs
        1. p_query - query with MLN alias and join conditions.

    History

    Date        Author              Action
    07/18/05    Dinkar Gupta        Wrote Function
*/
PROCEDURE get_curr_inv_stat_param_cond
            (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
             p_query IN OUT NOCOPY VARCHAR2)
IS
-- {

    l_param_cond VARCHAR2 (4000);

-- }
BEGIN
-- {
    -- Initialization block
    l_param_cond := NULL;

    FOR i in 1..p_param.count
    LOOP
    -- {

        -- No need to put in conditions for the inventory category parameter
        -- since the only navigatio
        CASE
        -- {
            WHEN p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION' AND
                 NOT (p_param(i).parameter_value IS NULL OR
                      p_param(i).parameter_value = 'All') THEN
                l_param_cond := l_param_cond ||
                    ' AND ( ' ||
                     get_curr_inv_viewby_format (p_param(i).parameter_name) ||
                    ' ) in (&ORGANIZATION+ORGANIZATION)';
            WHEN p_param(i).parameter_name =
                    'ORGANIZATION+ORGANIZATION_SUBINVENTORY' AND
                 NOT (p_param(i).parameter_value IS NULL OR
                      p_param(i).parameter_value = 'All') THEN
                l_param_cond := l_param_cond ||
                    ' AND ( ' ||
                     get_curr_inv_viewby_format (p_param(i).parameter_name) ||
                    ' ) in (&ORGANIZATION+ORGANIZATION_SUBINVENTORY)';
            WHEN p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG' AND
                 NOT (p_param(i).parameter_value IS NULL OR
                      p_param(i).parameter_value = 'All') THEN
                l_param_cond := l_param_cond ||
                    ' AND ( ' ||
                     get_curr_inv_viewby_format (p_param(i).parameter_name) ||
                    ' ) in (&ITEM+ENI_ITEM_ORG)';
            WHEN p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT' AND
                 NOT (p_param(i).parameter_value IS NULL OR
                      p_param(i).parameter_value = 'All') THEN
                l_param_cond := l_param_cond ||
                    ' AND ( ' ||
                     get_curr_inv_viewby_format (p_param(i).parameter_name) ||
                    ' ) in (&ITEM+ENI_ITEM_INV_CAT)';
            WHEN p_param(i).parameter_name =
                    'ORGANIZATION+OPI_SUB_LOCATOR_LVL' AND
                 NOT (p_param(i).parameter_value IS NULL OR
                      p_param(i).parameter_value = 'All') THEN
                l_param_cond := l_param_cond ||
                    ' AND ( ' ||
                     get_curr_inv_viewby_format (p_param(i).parameter_name) ||
                    ' ) in (&ORGANIZATION+OPI_SUB_LOCATOR_LVL)';
            WHEN p_param(i).parameter_name =
                    'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL' AND
                 NOT (p_param(i).parameter_value IS NULL OR
                      p_param(i).parameter_value = 'All') THEN
                l_param_cond := l_param_cond ||
                    ' AND ( ' ||
                     get_curr_inv_viewby_format (p_param(i).parameter_name) ||
                    ' ) in (&OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL)';
            WHEN p_param(i).parameter_name =
                    'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL' AND
                 NOT (p_param(i).parameter_value IS NULL OR
                      p_param(i).parameter_value = 'All') THEN
                l_param_cond := l_param_cond ||
                    ' AND ( ' ||
                     get_curr_inv_viewby_format (p_param(i).parameter_name) ||
                    ' ) in (&OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL)';
            ELSE
                l_param_cond := l_param_cond || '';
        --}
        END CASE;
    -- }
    END LOOP;

    -- add parameter conditions
    p_query := replace (p_query, ':OPI_PARAM_CONDITIONS', l_param_cond);

    return;

-- }
END get_curr_inv_stat_param_cond;


/* get_curr_inv_sec_where_clause

    Description
        Current Inventory Status (Table) viewby column security
        where clause.

        Basically the standard OPI where clause from the
        common utility.

    Inputs
        1. p_param - BIS parameter table
        2. p_query - Input query with place holders

    Outputs
        1. p_query - query with viewby column name replaced

    History

    Date        Author              Action
    07/18/05    Dinkar Gupta        Wrote Function
*/
PROCEDURE get_curr_inv_sec_where_clause
            (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
             p_query IN OUT NOCOPY VARCHAR2)
IS
-- {
    l_security_where_clause VARCHAR2 (2000);
-- }
BEGIN
-- {

    -- initialization block
    l_security_where_clause := '';

    FOR i in 1..p_param.count
    LOOP
    -- {
        -- If only the Viewby is Item grade, must outer join mln
        IF (p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION') THEN
        -- {
            l_security_where_clause :=
                opi_dbi_rpt_util_pkg.get_security_where_clauses
                    (p_org_value => p_param(i).parameter_value,
                     p_trend => 'N');
        -- }
        END IF;
    -- }
    END LOOP;

    -- replace the placeholders
    p_query := replace (p_query, ':OPI_SECURITY_CLAUSE',
                        l_security_where_clause);
    return;

-- }
END get_curr_inv_sec_where_clause;



/* get_curr_inv_stat_sel_clause

    Description
        Returns the select clause for the Current Inventory
        Status (Table) report query.

    Input

    Outputs
        1. l_sel_clause - Select clause of the report query

    History

    Date        Author              Action
    07/13/05    Dinkar Gupta        Wrote Function
*/
FUNCTION get_curr_inv_stat_sel_clause (p_view_by_dim IN VARCHAR2,
                                       p_join_tbl IN
                                         poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2
IS
-- {
    l_sel_clause VARCHAR2 (32767);
    l_description varchar2 (120);
    l_uom varchar2 (30);
    l_view_by_fact_col VARCHAR2(400);
-- }
BEGIN
-- {
    -- initialization block
    l_sel_clause := NULL;
    l_description := NULL;
    l_uom := NULL;
    l_view_by_fact_col := NULL;

    -- fact column view by's
    l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                (p_join_tbl => p_join_tbl);

    -- It is fine to sum primary_qty in the secondary qty measures
    -- in the rank clause. Since the report is item specific, the
    -- conversion between primary and secondary quantity is fixed,
    -- and hence the sort order on the primary and secondary quantity
    -- is the same.
    l_sel_clause :=
    'SELECT /* outer select */
    ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
      || 'v2.unit_of_measure OPI_ATTRIBUTE1,
    ' || 'oset.OPI_MEASURE2,
    ' || 'oset.OPI_MEASURE5,
    ' || 'v3.unit_of_measure OPI_ATTRIBUTE2,
    ' || 'oset.OPI_MEASURE4,
    ' || 'oset.OPI_MEASURE6
    ' || 'FROM
    ' || '(SELECT (rank () over
    ' || ' (&ORDER_BY_CLAUSE nulls last,
    ' || l_view_by_fact_col || ')) - 1 rnk,
    ' || l_view_by_fact_col || ',
    ' || 'OPI_MEASURE2,
    ' || 'OPI_MEASURE5,
    ' || 'OPI_MEASURE4,
    ' || 'OPI_MEASURE6
    ' || 'FROM
    ' || '(SELECT /* measure computation */
            ' || l_view_by_fact_col || ',
            ' || opi_dbi_rpt_util_pkg.raw_str
                            (p_str => 'c_primary_qty')
                                               || ' OPI_MEASURE2,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'c_primary_qty_total')
                                               || ' OPI_MEASURE5,
            ' || opi_dbi_rpt_util_pkg.raw_str
                            (p_str => 'c_secondary_qty')
                                               || ' OPI_MEASURE4,
            ' || opi_dbi_rpt_util_pkg.nvl_str
                            (p_str => 'c_secondary_qty_total')
                                               || ' OPI_MEASURE6
    ' || ' FROM ( /* OLTP select */
    ' || ' SELECT
    ' || '      msi.primary_uom_code,
    ' || '      msi.secondary_uom_code,
    ' || '      :OPI_CURR_INV_STAT_VIEWBY :OPI_CURR_INV_STAT_VIEWBY_ALIAS,
    ' || '      sum (fact.transaction_quantity) c_primary_qty,
    ' || '      sum (sum (fact.transaction_quantity)) over () c_primary_qty_total,
    ' || '      sum (fact.secondary_transaction_quantity) c_secondary_qty,
    ' || '      sum (sum (fact.secondary_transaction_quantity)) over () c_secondary_qty_total
    ' || '   FROM mtl_onhand_quantities fact,
    ' || '        :OPI_MLN_TABLE
    ' || '        :OPI_ENI_OLTP_STAR_TABLE
    ' || '        mtl_system_items_b msi
    ' || '   WHERE fact.inventory_item_id = msi.inventory_item_id
    ' || '     AND fact.organization_id = msi.organization_id
    ' || '     :OPI_MLN_CONDITIONS
    ' || '     :OPI_ENI_OLTP_STAR_COND
    ' || '     :OPI_PARAM_CONDITIONS
    ' || '     :OPI_SECURITY_CLAUSE
    ' || '   GROUP BY msi.primary_uom_code,
    ' || '            msi.secondary_uom_code,
    ' || '            :OPI_CURR_INV_STAT_VIEWBY
    ';

    return l_sel_clause;
-- }
END get_curr_inv_stat_sel_clause;


END OPI_DBI_INV_CURR_RPT_PKG;

/
