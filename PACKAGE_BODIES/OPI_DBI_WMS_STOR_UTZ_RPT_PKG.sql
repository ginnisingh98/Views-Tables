--------------------------------------------------------
--  DDL for Package Body OPI_DBI_WMS_STOR_UTZ_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_WMS_STOR_UTZ_RPT_PKG" AS
/*$Header: OPIDRWSTORB.pls 120.0 2005/05/24 17:45:53 appldev noship $ */


/****************************************
 * Select clause functions
 ****************************************/
-- Warehouse Storage Utilized (Table) select function
FUNCTION get_stor_tbl_sel_clause (p_view_by_dim IN VARCHAR2,
                                  p_join_tbl IN
                                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2;

FUNCTION get_stor_trd_sel_clause (p_view_by_dim IN VARCHAR2,
                                  p_join_tbl IN
                                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2;

FUNCTION get_curr_utz_sel_clause (p_view_by_dim IN VARCHAR2,
                                  p_join_tbl IN
                                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2;

FUNCTION get_stor_tbl_filter_clause (p_view_by_dim IN VARCHAR2)
    RETURN VARCHAR2;

FUNCTION get_curr_utz_filter_clause (p_view_by_dim IN VARCHAR2)
    RETURN VARCHAR2;




/****************************************
 * Helper functions
 ****************************************/
-- Subinventory query for current utilization's viewby item/inv cat.
FUNCTION curr_utz_item_cat_sub_cap_sql (p_fact_name IN VARCHAR2,
                                        p_where_clause IN VARCHAR2,
                                        p_col_name IN
                                            poa_dbi_util_pkg.POA_DBI_COL_TBL)

    RETURN VARCHAR2;


/* get_stor_tbl_sel_clause

    Description
        Returns the select clause for the Warehouse Storage Utilized (Table)
        report query.

    Input

    Outputs
        1. l_sel_clause - Select clause of the report query

    History

    Date        Author              Action
    12/17/04    Dinkar Gupta        Wrote Function
*/
FUNCTION get_stor_tbl_sel_clause (p_view_by_dim IN VARCHAR2,
                                  p_join_tbl IN
                                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2
IS
    l_sel_clause VARCHAR2 (32767);
    l_description varchar2 (120);
    l_uom varchar2 (30);
    l_view_by_fact_col VARCHAR2(400);

BEGIN

    -- initialization block
    l_sel_clause := NULL;
    l_description := NULL;
    l_uom := NULL;
    l_view_by_fact_col := NULL;

    -- fact column view by's
    l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                (p_join_tbl);

    -- Description for item view by
    opi_dbi_rpt_util_pkg.get_viewby_item_columns (
                p_view_by_dim, l_description, l_uom);


    l_sel_clause :=
    'SELECT
    ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
      || l_description || ' OPI_ATTRIBUTE1,
    ' || l_uom || ' OPI_ATTRIBUTE2,
    ' || 'oset.OPI_MEASURE1,
    ' || 'oset.OPI_MEASURE2,
    ' || 'oset.OPI_MEASURE3,
    ' || 'oset.OPI_MEASURE4,
    ' || 'oset.OPI_MEASURE5,
    ' || 'oset.OPI_MEASURE6,
    ' || 'oset.OPI_MEASURE7,
    ' || 'oset.OPI_MEASURE8,
    ' || 'oset.OPI_MEASURE9,
    ' || 'oset.OPI_MEASURE10,
    ' || 'oset.OPI_MEASURE11,
    ' || 'oset.OPI_MEASURE12,
    ' || 'oset.OPI_MEASURE13
    ' || 'FROM
    ' || '(SELECT (rank () over
    ' || ' (&ORDER_BY_CLAUSE nulls last,
    ' || l_view_by_fact_col || ')) - 1 rnk,
    ' || l_view_by_fact_col || ',
    ' || 'OPI_MEASURE1,
    ' || 'OPI_MEASURE2,
    ' || 'OPI_MEASURE3,
    ' || 'OPI_MEASURE4,
    ' || 'OPI_MEASURE5,
    ' || 'OPI_MEASURE6,
    ' || 'OPI_MEASURE7,
    ' || 'OPI_MEASURE8,
    ' || 'OPI_MEASURE9,
    ' || 'OPI_MEASURE10,
    ' || 'OPI_MEASURE11,
    ' || 'OPI_MEASURE12,
    ' || 'OPI_MEASURE13
    ' || 'FROM
    ' || '(SELECT
            ' || l_view_by_fact_col || ',
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_stored_qty')
                                               || ' OPI_MEASURE1,
            ' || opi_dbi_rpt_util_pkg.raw_str ('p_utilized_volume')
                                               || ' OPI_MEASURE2,
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_utilized_volume')
                                               || ' OPI_MEASURE3,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_utilized_volume',
                                                  'p_utilized_volume',
                                                  'p_utilized_volume',
                                                  'OPI_MEASURE4') || ',
            ' || opi_dbi_rpt_util_pkg.raw_str ('p_weight_stored')
                                               || ' OPI_MEASURE5,
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_weight_stored')
                                               || ' OPI_MEASURE6,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_weight_stored',
                                                  'p_weight_stored',
                                                  'p_weight_stored',
                                                  'OPI_MEASURE7') || ',
            ' || opi_dbi_rpt_util_pkg.raw_str ('p_utilized_volume_total')
                                               || ' OPI_MEASURE8,
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_utilized_volume_total')
                                               || ' OPI_MEASURE9,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_utilized_volume_total',
                                                  'p_utilized_volume_total',
                                                  'p_utilized_volume_total',
                                                  'OPI_MEASURE10') || ',
            ' || opi_dbi_rpt_util_pkg.raw_str ('p_weight_stored_total')
                                               || ' OPI_MEASURE11,
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_weight_stored_total')
                                               || ' OPI_MEASURE12,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_weight_stored_total',
                                                  'p_weight_stored_total',
                                                  'p_weight_stored_total',
                                                  'OPI_MEASURE13') ;

    return l_sel_clause;

END get_stor_tbl_sel_clause;

/*  get_stor_tbl_filter_clause

    Description
        Filter clause for the warehouse storage table report.

    Input
        Viewby dimension, since qty is a criterion for filtering on
        viewby = item.

        Decode 0's as NULL, because we don't want to show anything for
        items that have 0 onhand.

    Output
        Filter clause

    History

    Date        Author              Action
    01/13/05    Dinkar Gupta        Wrote Function

*/

FUNCTION get_stor_tbl_filter_clause (p_view_by_dim IN VARCHAR2)
    RETURN VARCHAR2
IS

    l_filter_clause VARCHAR2 (20000);

    -- table column for filter clause
    l_col_rec POA_DBI_UTIL_PKG.POA_DBI_FLEX_FILTER_REC;
    l_col_tbl POA_DBI_UTIL_PKG.POA_DBI_FLEX_FILTER_TBL;

BEGIN

    -- initialization block
    l_filter_clause := NULL;
    l_col_rec := NULL;
    l_col_tbl := POA_DBI_UTIL_PKG.POA_DBI_FLEX_FILTER_TBL ();

    -- Basic columns to filter out:
    -- OPI_MEASURE2 Prior
    -- OPI_MEASURE3 Utilized Volume
    -- OPI_MEASURE4 Change
    -- OPI_MEASURE5 Prior
    -- OPI_MEASURE6 Weight Stored
    -- OPI_MEASURE7 Change
    --
    -- For viewby item, filter out additionally on:
    -- OPI_MEASURE1 Quantity
    l_col_rec.measure_name := 'OPI_MEASURE2';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    l_col_rec.measure_name := 'OPI_MEASURE3';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    l_col_rec.measure_name := 'OPI_MEASURE4';
    l_col_rec.modifier := 'DECODE_0';
    l_col_tbl.extend;
    l_col_tbl(l_col_tbl.count) := l_col_rec;

    l_col_rec.measure_name := 'OPI_MEASURE5';
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

    -- Item viewby special case
    IF (p_view_by_dim = C_VIEWBY_ITEM) THEN

        l_col_rec.measure_name := 'OPI_MEASURE1';
        l_col_rec.modifier := 'DECODE_0';
        l_col_tbl.extend;
        l_col_tbl(l_col_tbl.count) := l_col_rec;

    END IF;

    -- generate the filter clause
    l_filter_clause := poa_dbi_util_pkg.get_filter_where (l_col_tbl);

    return l_filter_clause;

END get_stor_tbl_filter_clause;


/* get_stor_tbl_sql

    Description
        Warehouse Storage Utilized (Table) report query function.

    Inputs
        1. p_params - table of parameters with which report was run.

    Outputs
        1. x_custom_sql - sql report query.
        2. x_custom_output - table of values for bind variables in
                             sql report query.

    History

    Date        Author              Action
    12/17/04    Dinkar Gupta        Wrote Function
    01/13/05    Dinkar Gupta        Added filtering.
*/
PROCEDURE get_stor_tbl_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY
                                BIS_QUERY_ATTRIBUTES_TBL)
IS

    l_query VARCHAR2 (32767);
    l_custom_sql VARCHAR2 (32767);

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

    -- Of no use, but needed for process parameters.
    l_cur_suffix VARCHAR2 (5);

    l_filter_clause VARCHAR2 (20000);

BEGIN

    -- initialization block
    x_custom_sql := NULL;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL ();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    l_query := NULL;
    l_custom_sql := NULL;
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
            p_version          => '7.1',
            p_role             => '',
            p_mv_set           => 'WMS_STOR_UTZ',
            p_mv_flag_type     => 'WMS_STOR_UTZ_LEVEL');

    -- Add the appropriate columns that need to be aggregated.
    -- Stored Quantity. No need for totals.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'stored_qty',
                                 p_alias_name => 'stored_qty',
                                 p_grand_total => 'N',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    -- Stored Weight. No need for totals.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'weight_stored',
                                 p_alias_name => 'weight_stored',
                                 p_grand_total => 'Y',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    -- Utilized Volume. No need for totals.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'utilized_volume',
                                 p_alias_name => 'utilized_volume',
                                 p_grand_total => 'Y',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    -- Get the filtering clause
    l_filter_clause := get_stor_tbl_filter_clause (l_view_by);

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
    l_query := get_stor_tbl_sel_clause (l_view_by, l_join_tbl) || '
               ' || ' from ' || '
               ' || l_query;

    -- Make the nested pattern ITD since onhand quantity (and weight/
    -- volume) are reported as a balance..
    l_query := replace (l_query, '&RLX_NESTED_PATTERN',
                        C_ROLLING_ITD_PATTERN);

    -- Get bind variables for the rolling period reports.
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);
    poa_dbi_util_pkg.get_custom_rolling_binds (x_custom_output, l_xtd);

    -- Subinventory aggregation level flag.
    l_custom_rec.attribute_name := ':OPI_WMS_STOR_UTZ_FLAG';
    l_custom_rec.attribute_value := l_aggr_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;

    return;

END get_stor_tbl_sql;


/* get_stor_trd_sel_clause

    Description
        Returns the select clause for the Warehouse Storage Utilized Trend
        report query.

    Input

    Outputs
        1. l_sel_clause - Select clause of the report query

    History

    Date        Author              Action
    11/30/04    Dinkar Gupta        Wrote Function
*/
FUNCTION get_stor_trd_sel_clause (p_view_by_dim IN VARCHAR2,
                                  p_join_tbl IN
                                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2
IS
    l_sel_clause VARCHAR2 (32767);

BEGIN

    -- initialization block
    l_sel_clause := NULL;

    l_sel_clause :=
    'SELECT
        ' || ' cal.name VIEWBY,
        ' || opi_dbi_rpt_util_pkg.raw_str ('iset.p_utilized_volume')
                                           || ' OPI_MEASURE1,
        ' || opi_dbi_rpt_util_pkg.raw_str ('iset.c_utilized_volume')
                                           || ' OPI_MEASURE2,
        ' || opi_dbi_rpt_util_pkg.change_str ('c_utilized_volume',
                                              'p_utilized_volume',
                                              'p_utilized_volume',
                                              'OPI_MEASURE3') || ',
        ' || opi_dbi_rpt_util_pkg.raw_str ('iset.p_weight_stored')
                                           || ' OPI_MEASURE4,
        ' || opi_dbi_rpt_util_pkg.raw_str ('iset.c_weight_stored')
                                           || ' OPI_MEASURE5,
        ' || opi_dbi_rpt_util_pkg.change_str ('c_weight_stored',
                                              'p_weight_stored',
                                              'p_weight_stored',
                                              'OPI_MEASURE6') ;


    return l_sel_clause;


END get_stor_trd_sel_clause;


/* get_stor_trd_sql

    Description
        Warehouse Storage Utilized Trend report query function.

    Inputs
        1. p_params - table of parameters with which report was run.

    Outputs
        1. x_custom_sql - sql report query.
        2. x_custom_output - table of values for bind variables in
                             sql report query.

    History

    Date        Author              Action
    11/30/04    Dinkar Gupta        Wrote Function

*/
PROCEDURE get_stor_trd_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY
                                BIS_QUERY_ATTRIBUTES_TBL)
IS

    l_query VARCHAR2 (32767);
    l_custom_sql VARCHAR2 (32767);

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

    -- Of no use, but needed for process parameters.
    l_cur_suffix VARCHAR2 (5);

BEGIN

    -- initialization block
    x_custom_sql := NULL;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL ();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    l_query := NULL;
    l_custom_sql := NULL;
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
            p_trend            => 'Y',
            p_func_area        => 'OPI',
            p_version          => '7.1',
            p_role             => '',
            p_mv_set           => 'WMS_STOR_UTZ',
            p_mv_flag_type     => 'WMS_STOR_UTZ_LEVEL');


    -- Measures the need to be aggregated.
    -- No need for totals.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'weight_stored',
                                 p_alias_name => 'weight_stored',
                                 p_grand_total => 'N',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    -- Utilized Volume. No need for totals.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'utilized_volume',
                                 p_alias_name => 'utilized_volume',
                                 p_grand_total => 'N',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');


    -- The POA template central query
    l_query := poa_dbi_template_pkg.trend_sql(
                p_xtd               => l_xtd,
                p_comparison_type   => l_comparison_type,
                p_fact_name         => l_mv,
                p_where_clause      => l_where_clause,
                p_col_name          => l_col_tbl,
                p_use_grpid         => 'N',
                p_in_join_tables    => NULL);

    -- Final query with select clause
    l_query := get_stor_trd_sel_clause (l_view_by, l_join_tbl) || '
               ' || ' from ' || '
               ' || l_query;

    -- Make the nested pattern ITD since onhand quantity (and weight/
    -- volume) are reported as a balance..
    l_query := replace (l_query, '&RLX_NESTED_PATTERN',
                        C_ROLLING_ITD_PATTERN);


    -- Get bind variables for the rolling period reports.
    poa_dbi_util_pkg.get_custom_trend_binds (
            p_xtd               => l_xtd,
            p_comparison_type   => l_comparison_type,
            x_custom_output     => x_custom_output);
    poa_dbi_util_pkg.get_custom_rolling_binds (x_custom_output, l_xtd);

    -- Subinventory aggregation level flag.
    l_custom_rec.attribute_name := ':OPI_WMS_STOR_UTZ_FLAG';
    l_custom_rec.attribute_value := l_aggr_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;


    x_custom_sql := l_query;

    return;

END get_stor_trd_sql;


/* get_curr_utz_sel_clause

    Description
        Returns the select clause for the Current Capacity Utilization
        report query.

    Input

    Outputs
        1. l_sel_clause - Select clause of the report query

    History

    Date        Author              Action
    12/16/04    Dinkar Gupta        Wrote Function
*/
FUNCTION get_curr_utz_sel_clause (p_view_by_dim IN VARCHAR2,
                                  p_join_tbl IN
                                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2
IS
    l_sel_clause VARCHAR2 (32767);
    l_description varchar2 (120);
    l_uom varchar2 (30);
    l_view_by_fact_col VARCHAR2(400);

    l_vol_utz_denom VARCHAR2 (40);
    l_wt_utz_denom VARCHAR2 (40);

BEGIN

    -- initialization block
    l_sel_clause := NULL;

    -- fact column view by's
    l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                (p_join_tbl);

    -- Description for item view by
    opi_dbi_rpt_util_pkg.get_viewby_item_columns (
                p_view_by_dim, l_description, l_uom);


    -- Denominators for the volume/weight utilization.
    -- Should be the capacity per row for viewbys of Org/Sub
    IF (p_view_by_dim = C_VIEWBY_ORG OR
        p_view_by_dim = C_VIEWBY_SUB) THEN

        l_vol_utz_denom := 'c_volume_capacity';
        l_wt_utz_denom := 'c_weight_capacity';

    ELSIF (p_view_by_dim = C_VIEWBY_INV_CAT OR
           p_view_by_dim = C_VIEWBY_ITEM) THEN

        l_vol_utz_denom := 'c_volume_capacity_total';
        l_wt_utz_denom := 'c_weight_capacity_total';

    END IF;

    l_sel_clause :=
    'SELECT
    ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
      || l_description || ' OPI_ATTRIBUTE1,
    ' || l_uom || ' OPI_ATTRIBUTE2,
    ' || 'oset.OPI_MEASURE1,
    ' || 'oset.OPI_MEASURE2,
    ' || 'oset.OPI_MEASURE3,
    ' || 'oset.OPI_MEASURE4,
    ' || 'oset.OPI_MEASURE5,
    ' || 'oset.OPI_MEASURE6,
    ' || 'oset.OPI_MEASURE7,
    ' || 'oset.OPI_MEASURE8,
    ' || 'oset.OPI_MEASURE9,
    ' || 'oset.OPI_MEASURE10,
    ' || 'oset.OPI_MEASURE11,
    ' || 'oset.OPI_MEASURE12,
    ' || 'oset.OPI_MEASURE13
    ' || 'FROM
    ' || '(SELECT (rank () over
    ' || ' (&ORDER_BY_CLAUSE nulls last,
    ' || l_view_by_fact_col || ')) - 1 rnk,
    ' || l_view_by_fact_col || ',
    ' || 'OPI_MEASURE1,
    ' || 'OPI_MEASURE2,
    ' || 'OPI_MEASURE3,
    ' || 'OPI_MEASURE4,
    ' || 'OPI_MEASURE5,
    ' || 'OPI_MEASURE6,
    ' || 'OPI_MEASURE7,
    ' || 'OPI_MEASURE8,
    ' || 'OPI_MEASURE9,
    ' || 'OPI_MEASURE10,
    ' || 'OPI_MEASURE11,
    ' || 'OPI_MEASURE12,
    ' || 'OPI_MEASURE13
    ' || 'FROM
    ' || '(SELECT
            ' || l_view_by_fact_col || ',
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_stored_qty')
                                               || ' OPI_MEASURE1,
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_utilized_volume')
                                               || ' OPI_MEASURE2,
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_volume_capacity')
                                               || ' OPI_MEASURE3,
            ' || opi_dbi_rpt_util_pkg.percent_str_basic ('c_utilized_volume',
                                                         l_vol_utz_denom,
                                                         'OPI_MEASURE4') || ',
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_stored_weight')
                                               || ' OPI_MEASURE5,
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_weight_capacity')
                                               || ' OPI_MEASURE6,
            ' || opi_dbi_rpt_util_pkg.percent_str_basic ('c_stored_weight',
                                                         l_wt_utz_denom,
                                                         'OPI_MEASURE7') || ',
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_utilized_volume_total')
                                               || ' OPI_MEASURE8,
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_volume_capacity_total')
                                               || ' OPI_MEASURE9,
            ' || opi_dbi_rpt_util_pkg.percent_str_basic
                    ('c_utilized_volume_total',
                     'c_volume_capacity_total',
                     'OPI_MEASURE10') || ',
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_stored_weight_total')
                                               || ' OPI_MEASURE11,
            ' || opi_dbi_rpt_util_pkg.raw_str ('c_weight_capacity_total')
                                               || ' OPI_MEASURE12,
            ' || opi_dbi_rpt_util_pkg.percent_str_basic
                    ('c_stored_weight_total',
                     'c_weight_capacity_total',
                     'OPI_MEASURE13') ;


    return l_sel_clause;


END get_curr_utz_sel_clause;


/*  curr_utz_item_cat_sub_cap_sql

    Returns the inline view needed for the capacity calculation of the
    current capacity report, for viewby of item and category.

    Needs to return a sql of form:

    select
        sum (weight_capacity) over (),
        sum (volume_capacity) over ()
      from opi_dbi_wms_curr_utz_sub_f
      where  .... (conditions calculated by utility packages).

    History

    Date        Author              Action
    12/16/04    Dinkar Gupta        Wrote Function


*/
FUNCTION curr_utz_item_cat_sub_cap_sql (p_fact_name IN VARCHAR2,
                                        p_where_clause IN VARCHAR2,
                                        p_col_name IN
                                            poa_dbi_util_pkg.POA_DBI_COL_TBL)

    RETURN VARCHAR2

IS

    l_query VARCHAR2 (32767);

    -- call the fact 'fact' to stay consistent with the POA utility
    L_FACT_ALIAS CONSTANT VARCHAR2 (10) := 'fact';

BEGIN

    -- Initialization block
    l_query := 'select distinct ';

    -- Generate the columns
    FOR i IN 1 .. p_col_name.count
    LOOP

        -- Add a comma
        IF (i <> 1) THEN
            l_query := l_query || ',';
        END IF;

        l_query :=
            l_query || '
            ' || 'NULL ' || 'c_' || p_col_name(i).column_alias || ',
            ' || 'sum ( ' || p_col_name(i).column_name || ' ) over () ' ||
                 'c_' || p_col_name(i).column_alias || '_total';

    END LOOP;

    -- Append the fact
    l_query :=
        l_query || '
        ' || 'from ' || p_fact_name || ' ' || L_FACT_ALIAS;

    -- Append the where clause
    l_query :=
        l_query || '
        ' || 'where ' || p_where_clause;

    return l_query;

END curr_utz_item_cat_sub_cap_sql;

/*  get_curr_utz_filter_clause

    Description
        Filter clause for the Current Capacity table report.

    Input
        Viewby dimension, since qty is a criterion for filtering on
        viewby = item.

    Output
        Filter clause

    History

    Date        Author              Action
    01/13/05    Dinkar Gupta        Wrote Function

*/
FUNCTION get_curr_utz_filter_clause (p_view_by_dim IN VARCHAR2)
    RETURN VARCHAR2
IS

    l_filter_clause VARCHAR2 (20000);

    -- table column for filter clause
    l_col_rec POA_DBI_UTIL_PKG.POA_DBI_FLEX_FILTER_REC;
    l_col_tbl POA_DBI_UTIL_PKG.POA_DBI_FLEX_FILTER_TBL;

BEGIN

    -- initialization block
    l_filter_clause := NULL;
    l_col_rec := NULL;
    l_col_tbl := POA_DBI_UTIL_PKG.POA_DBI_FLEX_FILTER_TBL ();

    -- Nothing needed for Viewby ORG/SUB.

    IF (p_view_by_dim = C_VIEWBY_ITEM OR
        p_view_by_dim = C_VIEWBY_INV_CAT) THEN

        -- Basic columns to filter out for viewby ITEM/CAT:
        -- OPI_MEASURE2 Utilized Volume
        -- OPI_MEASURE5 Weight Stored
        -- since utilization will be NULL if the above measures are NULL
        --
        -- For viewby item, filter out additionally on:
        -- OPI_MEASURE1 Quantity
        l_col_rec.measure_name := 'OPI_MEASURE2';
        l_col_rec.modifier := NULL;
        l_col_tbl.extend;
        l_col_tbl(l_col_tbl.count) := l_col_rec;

        l_col_rec.measure_name := 'OPI_MEASURE5';
        l_col_rec.modifier := NULL;
        l_col_tbl.extend;
        l_col_tbl(l_col_tbl.count) := l_col_rec;


        -- Item viewby special case
        IF (p_view_by_dim = C_VIEWBY_ITEM) THEN


            l_col_rec.measure_name := 'OPI_MEASURE1';
            l_col_rec.modifier := NULL;
            l_col_tbl.extend;
            l_col_tbl(l_col_tbl.count) := l_col_rec;

        END IF;

        -- generate the filter clause
        l_filter_clause := poa_dbi_util_pkg.get_filter_where (l_col_tbl);

    END IF;

    return l_filter_clause;

END get_curr_utz_filter_clause;


/* get_curr_utz_sql

    Description
        Current Capacity Utilization report query function.

    Inputs
        1. p_params - table of parameters with which report was run.

    Outputs
        1. x_custom_sql - sql report query.
        2. x_custom_output - table of values for bind variables in
                             sql report query.

    History

    Date        Author              Action
    12/16/04    Dinkar Gupta        Wrote Function

*/
PROCEDURE get_curr_utz_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY
                                BIS_QUERY_ATTRIBUTES_TBL)
IS

    l_query VARCHAR2 (32767);
    l_custom_sql VARCHAR2 (32767);

    -- Item Specific
    l_item_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_item_where_clause VARCHAR2 (20000);
    l_item_mv VARCHAR2 (30);
    l_item_aggr_level_flag VARCHAR2(5);
    l_item_inner_status_sql VARCHAR2 (32767); -- for viewby item/cat only
    l_viewby_rank_clause VARCHAR2 (32767); -- for viewby item/cat only

    -- Sub Specific
    l_sub_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_sub_where_clause VARCHAR2 (20000);
    l_sub_mv VARCHAR2 (30);
    l_sub_aggr_level_flag VARCHAR2(5);
    l_sub_status_sql VARCHAR2(32767);
    l_sub_item_outer_join VARCHAR2(10);

    -- Common to item and sub side of the queries
    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_xtd VARCHAR2(10);
    l_custom_rec BIS_QUERY_ATTRIBUTES;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_mv_tbl poa_dbi_util_pkg.POA_DBI_MV_TBL;
    l_sel_clause VARCHAR2 (32767);
    l_filter_clause VARCHAR2 (20000);

    -- Of no use, but needed for process parameters.
    l_cur_suffix VARCHAR2 (5);
    l_comparison_type VARCHAR2(5);


BEGIN

    -- initialization block
    l_query := NULL;
    l_custom_sql := NULL;

    -- Item specific
    l_item_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_item_where_clause := NULL;
    l_item_mv := NULL;
    l_item_aggr_level_flag := NULL;

    -- Sub specific
    l_sub_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_sub_where_clause := NULL;
    l_sub_mv := NULL;
    l_sub_aggr_level_flag := NULL;
    l_sub_status_sql := NULL;
    l_sub_item_outer_join := NULL;

    -- Common
    x_custom_sql := NULL;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL ();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    l_view_by := NULL;
    l_view_by_col := NULL;
    l_xtd := NULL;
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
    l_mv_tbl := poa_dbi_util_pkg.POA_DBI_MV_TBL ();
    l_sel_clause := NULL;
    l_item_inner_status_sql := NULL;
    l_viewby_rank_clause := NULL;
    l_filter_clause := NULL;

    -- Of no use
    l_cur_suffix := NULL;
    l_comparison_type := NULL;

    -- Get all the report query parameters for the item
    -- side of the query.
    opi_dbi_rpt_util_pkg.process_parameters (
            p_param            => p_param,
            p_view_by          => l_view_by,
            p_view_by_col_name => l_view_by_col,
            p_comparison_type  => l_comparison_type,
            p_xtd              => l_xtd,
            p_cur_suffix       => l_cur_suffix,
            p_where_clause     => l_item_where_clause,
            p_mv               => l_item_mv,
            p_join_tbl         => l_join_tbl,
            p_mv_level_flag    => l_item_aggr_level_flag,
            p_trend            => 'N',
            p_func_area        => 'OPI',
            p_version          => '7.1',
            p_role             => '',
            p_mv_set           => 'WMS_CURR_UTZ_ITEM',
            p_mv_flag_type     => 'WMS_CURR_UTZ_ITEM_LEVEL');

    -- The list of all item level table columns that need to be aggregated.
    -- These are: stored_qty, stored_weight, utilized_volume.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_item_col_tbl,
                                 p_col_name => 'stored_qty',
                                 p_alias_name => 'stored_qty',
                                 p_grand_total => 'N',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.NO_PRIORS,
                                 p_to_date_type => 'NA');

    poa_dbi_util_pkg.add_column (p_col_tbl => l_item_col_tbl,
                                 p_col_name => 'stored_weight',
                                 p_alias_name => 'stored_weight',
                                 p_grand_total => 'Y',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.NO_PRIORS,
                                 p_to_date_type => 'NA');

    poa_dbi_util_pkg.add_column (p_col_tbl => l_item_col_tbl,
                                 p_col_name => 'utilized_volume',
                                 p_alias_name => 'utilized_volume',
                                 p_grand_total => 'Y',
                                 p_prior_code =>
                                        poa_dbi_util_pkg.NO_PRIORS,
                                 p_to_date_type => 'NA');


    -- Get all the report query parameters for the subinventory
    -- side of the query.
    opi_dbi_rpt_util_pkg.process_parameters (
            p_param            => p_param,
            p_view_by          => l_view_by,
            p_view_by_col_name => l_view_by_col,
            p_comparison_type  => l_comparison_type,
            p_xtd              => l_xtd,
            p_cur_suffix       => l_cur_suffix,
            p_where_clause     => l_sub_where_clause,
            p_mv               => l_sub_mv,
            p_join_tbl         => l_join_tbl,
            p_mv_level_flag    => l_sub_aggr_level_flag,
            p_trend            => 'N',
            p_func_area        => 'OPI',
            p_version          => '7.1',
            p_role             => '',
            p_mv_set           => 'WMS_CURR_UTZ_SUB',
            p_mv_flag_type     => 'WMS_CURR_UTZ_SUB_LEVEL');

        -- The subinventory level measures we're interested in are:
        -- weight_capacity, and volume_capacity.
        poa_dbi_util_pkg.add_column (p_col_tbl => l_sub_col_tbl,
                                     p_col_name => 'weight_capacity',
                                     p_alias_name => 'weight_capacity',
                                     p_grand_total => 'Y',
                                     p_prior_code =>
                                        poa_dbi_util_pkg.NO_PRIORS,
                                     p_to_date_type => 'NA');


        poa_dbi_util_pkg.add_column (p_col_tbl => l_sub_col_tbl,
                                     p_col_name => 'volume_capacity',
                                     p_alias_name => 'volume_capacity',
                                     p_grand_total => 'Y',
                                     p_prior_code =>
                                        poa_dbi_util_pkg.NO_PRIORS,
                                     p_to_date_type => 'NA');

    -- Since there is no join to the time dimension, need a dummy condition
    -- at the start of the where clause, since it starts with an AND.
    l_item_where_clause := '1 = 1 ' || l_item_where_clause;
    l_sub_where_clause := '1 = 1 ' || l_sub_where_clause;


    -- Get the select clause that depends purely on the
    -- the viewby columns.
    l_sel_clause := get_curr_utz_sel_clause (l_view_by, l_join_tbl);

    -- The Current Capacity Utilization report looks really different
    -- for the viewby Org and Sub, as opposed to the view by Item and Cat.
    -- The viewby Org/Sub report is a basic union all report with no
    -- calendar. The viewby Cat/Item contains only grand totals for the
    -- capacity. There are no other possible viewby's.
    IF (l_view_by = opi_dbi_rpt_util_pkg.C_VIEWBY_ORG OR
        l_view_by = opi_dbi_rpt_util_pkg.C_VIEWBY_SUB) THEN
        -- Need a query of form:
        /*
        select sum (....)
        ...
        rank (...)
        ....
        from
            (
            select
                item.viewby,
                item.qty,
                item.wt,
                item.vol,
                item.qty_tot,
                item.wt_tot,
                item.vol_tot,
                sub.wt_cap,
                sub.vol_cap,
                sub.wt_cap_tot,
                sub.vol_cap_tot
              from
                (select
                    viewby,
                    sum (stored_qty) qty,
                    sum (stored_weight) wt,
                    sum (utilized_volume) vol,
                    sum (stored_qty) over () qty_tot,
                    sum (stored_weight) over () wt_tot,
                    sum (utilized_volume) over () vol_tot
                  from opi_dbi_wms_curr_utz_item_f
                  where ..... (all where clauses)
                ) item,
                (select
                    viewby,
                    sum (weight_capacity) wt_cap,
                    sum (volume_capacity) vol_cap,
                    sum (weight_capacity) over () wt_cap_tot,
                    sum (volume_capacity) over () vol_cap_tot
                  from opi_dbi_wms_curr_utz_sub_f
                  where ... (no item/cat where clause)
                ) sub
              where sub.viewby = item.viewby
            )
            .....
        */

        -- Get the item section of the status sql without the ranking
        -- clause. This inline view contains the utilization in
        -- each sub/org.
        l_item_inner_status_sql :=
            poa_dbi_template_pkg.status_sql (
                p_fact_name         => l_item_mv,
                p_where_clause      => l_item_where_clause,
                p_join_tables       => l_join_tbl,
                p_use_windowing     => 'Y',
                p_col_name          => l_item_col_tbl,
                p_use_grpid         => 'N',
                p_paren_count       => 1,
                p_filter_where      => NULL,
                p_generate_viewby   => 'N',
                p_in_join_tables    => NULL);


        -- Get the subinventory section of the status sql without
        -- the ranking clause. This inline view contains the
        -- capacity of each sub/org.
        l_sub_status_sql :=
            poa_dbi_template_pkg.status_sql (
                p_fact_name         => l_sub_mv,
                p_where_clause      => l_sub_where_clause,
                p_join_tables       => l_join_tbl,
                p_use_windowing     => 'Y',
                p_col_name          => l_sub_col_tbl,
                p_use_grpid         => 'N',
                p_paren_count       => 1,
                p_filter_where      => NULL,
                p_generate_viewby   => 'N',
                p_in_join_tables    => NULL);

        -- The outermost ranking/order by clause with
        -- the join to the dimension tables.
        l_viewby_rank_clause :=
            poa_dbi_template_pkg.get_viewby_rank_clause (
                p_join_tables       => l_join_tbl,
                p_use_windowing     => 'Y');

        -- Always outer join the item utilization inline view with the
        -- sub capacity inline view. Capacity is governed by the sub/org
        -- parameters and not the item/cat parameters.
        l_sub_item_outer_join := '(+)';

        -- We need to generate grand totals after the join between
        -- the sub/org view from the item side, and the capacity view.
        -- Decode NULLS so that rows for orgs/subs that get created
        -- in the outer join case and have no items stored are reported
        -- with 0 usage.
        -- Also, report N/A for utilized volume/stored weight for
        -- rows where the corresponding capacity is NULL.
        --
        -- Since both capacities of any row can never be NULL (such a
        -- a subinventory would have been ignored by the ETL), no
        -- need to filter out any rows.
        l_query :=
            l_sel_clause ||
            'from ( ' || '
            select ' || '
                oset02.' || l_view_by_col || ' ' || l_view_by_col || ',
                CASE WHEN oset01.' || l_view_by_col || ' IS NULL THEN 0
                     ELSE c_stored_qty
                END c_stored_qty,
                CASE WHEN c_weight_capacity IS NULL THEN NULL
                     WHEN oset01.' || l_view_by_col || ' IS NULL THEN 0
                     ELSE c_stored_weight
                END c_stored_weight,
                sum (CASE WHEN c_weight_capacity IS NULL THEN NULL
                          WHEN oset01.' || l_view_by_col || ' IS NULL THEN 0
                          ELSE c_stored_weight
                     END) over () c_stored_weight_total,
                CASE WHEN c_volume_capacity IS NULL THEN NULL
                     WHEN oset01.' || l_view_by_col || ' IS NULL THEN 0
                     ELSE c_utilized_volume
                END c_utilized_volume,
                sum (CASE WHEN c_volume_capacity IS NULL THEN NULL
                          WHEN oset01.' || l_view_by_col || ' IS NULL THEN 0
                          ELSE c_utilized_volume
                     END) over () c_utilized_volume_total,
                c_weight_capacity,
                sum (c_weight_capacity) over () c_weight_capacity_total,
                c_volume_capacity,
                sum (c_volume_capacity) over () c_volume_capacity_total
                from
            ' || l_item_inner_status_sql || ') oset01,
            ' || l_sub_status_sql || ') oset02
            ' || ' where oset01.' || l_view_by_col ||
            ' ' || l_sub_item_outer_join ||
            ' = oset02.' || l_view_by_col || '
            ' || ' ) ) ) oset,
            ' || l_viewby_rank_clause;


    ELSIF (l_view_by = opi_dbi_rpt_util_pkg.C_VIEWBY_ITEM OR
           l_view_by = opi_dbi_rpt_util_pkg.C_VIEWBY_INV_CAT) THEN
        -- Need a query of form:
        /*
        select sum (....)
        ...
        rank (...)
        ....
        (select
            items.qty,
            items.wt,
            items.vol,
            items.qty_tot,
            items.wt_tot,
            items.vol_tot,
            NULL wt_cap,
            NULL vol_cap,
            subs.wt_cap_tot,
            subs.vol_cap_tot
          from
            (
            select
                viewby,
                sum (stored_qty) qty,
                sum (stored_weight) wt,
                sum (utilized_volume) vol,
                sum (stored_qty) over () qty_tot,
                sum (stored_weight) over () wt_tot,
                sum (utilized_volume) over () vol_tot
            from opi_dbi_wms_curr_utz_item_f
            where ..... (all where clauses)
            ) items,
            (
            select distinct
                sum (wt_cap) over () wt_cap_tot,
                sum (vol_cap) over () vol_cap_tot
            from opi_dbi_wms_curr_utz_sub_f
            where ... (no item/cat where clause)
            ) subs
            .....
        */

        -- Need to filter rows if all relevant measures are
        -- N/A.
        l_filter_clause := get_curr_utz_filter_clause (l_view_by);

        -- The inner part of the query based only on the
        -- item fact
        l_item_inner_status_sql :=
            poa_dbi_template_pkg.status_sql (
                p_fact_name         => l_item_mv,
                p_where_clause      => l_item_where_clause,
                p_join_tables       => l_join_tbl,
                p_use_windowing     => 'Y',
                p_col_name          => l_item_col_tbl,
                p_use_grpid         => 'N',
                p_paren_count       => 1,
                p_filter_where      => NULL,
                p_generate_viewby   => 'N',
                p_in_join_tables    => NULL);

        -- The outer part of the join to the dimension tables
        l_viewby_rank_clause :=
            poa_dbi_template_pkg.get_viewby_rank_clause (
                p_join_tables       => l_join_tbl,
                p_use_windowing     => 'Y');


        -- Get the subinventory side of the query
        l_sub_status_sql :=
            curr_utz_item_cat_sub_cap_sql (
                p_fact_name => l_sub_mv,
                p_where_clause => l_sub_where_clause,
                p_col_name => l_sub_col_tbl);


        -- Add together every part
        l_query := l_sel_clause || '
                   ' || ' from
                   ' || l_item_inner_status_sql || ') oset01,
                   ' || '( ' || l_sub_status_sql || ') oset02 ) where '
                     || l_filter_clause || ' ) oset,
                   ' || l_viewby_rank_clause;

    END IF;

    -- Return back the two aggregation level flags.

    -- Item aggregation level flag.
    l_custom_rec.attribute_name := ':OPI_WMS_CURR_UTZ_ITEM_FLAG';
    l_custom_rec.attribute_value := l_item_aggr_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    -- Subinventory aggregation level flag.
    l_custom_rec.attribute_name := ':OPI_WMS_CURR_UTZ_SUB_FLAG';
    l_custom_rec.attribute_value := l_sub_aggr_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    -- Return the entire SQL query.
    x_custom_sql := l_query;

    return;

END get_curr_utz_sql;

END opi_dbi_wms_stor_utz_rpt_pkg;

/
