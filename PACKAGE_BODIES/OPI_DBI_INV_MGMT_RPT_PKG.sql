--------------------------------------------------------
--  DDL for Package Body OPI_DBI_INV_MGMT_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_INV_MGMT_RPT_PKG" AS
/*$Header: OPIDRINVMB.pls 120.2 2005/09/21 03:51:16 srayadur noship $ */


/*++++++++++++++++++++++++++++++++++++++++*/
/* Function and procedure declarations in this file but not in spec*/
/*++++++++++++++++++++++++++++++++++++++++*/

/* Inventory Value Report */

FUNCTION get_inv_val_status_sel_clause (p_view_by_dim IN VARCHAR2,
                                        p_join_tbl IN
                                        poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2;

FUNCTION get_onhand_sel_clause (p_view_by_dim IN VARCHAR2,
                                p_join_tbl IN
                                poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2;

FUNCTION get_intransit_sel_clause (p_view_by_dim IN VARCHAR2,
                                   p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2;

PROCEDURE get_inv_val_item_columns (p_dim_name VARCHAR2,
                                p_description OUT NOCOPY VARCHAR2,
                                p_uom OUT NOCOPY VARCHAR2);


/* Inventory Value Trend Report */

FUNCTION get_inv_val_trend_sel_clause(p_view_by_dim IN VARCHAR2)
    return VARCHAR2;




/*----------------------------------------
Inventory Value Report Functions
  ----------------------------------------*/



/*
    Report query Function for viewby = Item, Org, Cat.
*/
PROCEDURE inv_val_status_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY
                              BIS_QUERY_ATTRIBUTES_TBL)
IS
    l_query VARCHAR2(15000);
    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_xtd VARCHAR2(10);
    l_comparison_type VARCHAR2(1);
    l_cur_suffix VARCHAR2(5);
    l_custom_sql VARCHAR2 (10000);

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

    l_where_clause VARCHAR2 (2000);
    l_mv VARCHAR2 (30);

    l_aggregation_level_flag varchar2(1);

    l_custom_rec BIS_QUERY_ATTRIBUTES;
    l_filter_where  VARCHAR2(120);

BEGIN

    -- initialization block
    l_comparison_type := 'Y';
    l_aggregation_level_flag := '0';

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();


    -- get all the query parameters
    opi_dbi_rpt_util_pkg.process_parameters (p_param => p_param,
                                          p_view_by => l_view_by,
                                          p_view_by_col_name => l_view_by_col,
                                          p_comparison_type => l_comparison_type,
                                          p_xtd => l_xtd,
                                          p_cur_suffix => l_cur_suffix,
                                          p_where_clause => l_where_clause,
                                          p_mv => l_mv,
                                          p_join_tbl => l_join_tbl,
                                          p_mv_level_flag => l_aggregation_level_flag,
                                          p_trend => 'N',
                                          p_func_area => 'OPI',
                                          p_version => '7.0',
                                          p_role => '',
                                          p_mv_set => 'INV_VAL',
                                          p_mv_flag_type => 'INV_VAL_LEVEL');

    -- The measure columns that need to be aggregated are
    -- onhand_value_<b/g>, intransit_value_<b/g>,
    -- wip_value_<b/g>, inv_total_value_<b/g>
    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'onhand_value_' || l_cur_suffix,
                                 'onhand_value');

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'intransit_value_' || l_cur_suffix,
                                 'intransit_value');

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'wip_value_' || l_cur_suffix,
                                 'wip_value');

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'inv_total_value_' || l_cur_suffix,
                                 'inv_total_value');

    --Add filtering condition to suppress rows
    l_filter_where := 'abs(OPI_MEASURE7) > 0 or abs(OPI_MEASURE8) > 0';

    -- construct the query
    l_query := get_inv_val_status_sel_clause (l_view_by, l_join_tbl)
          || ' from
        ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
                                              p_where_clause    => l_where_clause,
                                              p_join_tables     => l_join_tbl,
                                              p_use_windowing   => 'Y',
                                              p_col_name        => l_col_tbl,
                                              p_use_grpid       => 'N',
                                              p_filter_where    => l_filter_where);

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

    -- Passing OPI_AGGREGATION_LEVEL_FLAG to PMV
    l_custom_rec.attribute_name := ':OPI_AGGREGATION_LEVEL_FLAG';
    l_custom_rec.attribute_value := l_aggregation_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    -- make the nested pattern ITD since inv. value is reported as a balance,
    -- not an XTD value.
    l_query := replace (l_query, '&BIS_NESTED_PATTERN', '1143');

    x_custom_sql := l_query;

END inv_val_status_sql;


/*
    Outer main query for viewby = item, org, cat
*/

FUNCTION get_inv_val_status_sel_clause(p_view_by_dim IN VARCHAR2,
                                       p_join_tbl IN
                                       poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    return VARCHAR2
IS

    l_sel_clause varchar2(4500);
    l_view_by_col_name varchar2(60);
    l_description varchar2(30);
    l_uom varchar2(30);
    l_view_by_fact_col VARCHAR2(400);

BEGIN

    -- Main Outer query

    -- Column to get view by column name
    l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                (p_view_by_dim);

    -- fact column view by's
    l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                (p_join_tbl);

    -- Description for item view by
    get_inv_val_item_columns (p_view_by_dim, l_description, l_uom);

    -- Outer select clause
    l_sel_clause :=
    'SELECT
    ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
      || l_view_by_col_name || ' OPI_ATTRIBUTE1,
    ' || l_description || ' OPI_ATTRIBUTE2,
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
    ' || 'oset.OPI_MEASURE13,
    ' || 'oset.OPI_MEASURE14,
    ' || 'oset.OPI_MEASURE15,
    ' || 'oset.OPI_MEASURE16,
    ' || 'oset.OPI_MEASURE17,
    ' || 'oset.OPI_MEASURE18,
    ' || 'oset.OPI_MEASURE19,
    ' || 'oset.OPI_MEASURE20,
    ' || 'oset.OPI_MEASURE21,
    ' || 'oset.OPI_MEASURE22,
    ' || 'oset.OPI_MEASURE23,
    ' || 'oset.OPI_DYNAMIC_URL_1,
    ' || 'oset.OPI_DYNAMIC_URL_2
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
    ' || 'OPI_MEASURE13,
    ' || 'OPI_MEASURE14,
    ' || 'OPI_MEASURE15,
    ' || 'OPI_MEASURE16,
    ' || 'OPI_MEASURE17,
    ' || 'OPI_MEASURE18,
    ' || 'OPI_MEASURE19,
    ' || 'OPI_MEASURE20,
    ' || 'OPI_MEASURE21,
    ' || 'OPI_MEASURE22,
    ' || 'OPI_MEASURE23,
    ' || 'OPI_DYNAMIC_URL_1,
    ' || 'OPI_DYNAMIC_URL_2
    ' || 'FROM
    ' || '(SELECT
            ' || l_view_by_fact_col || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_onhand_value')
                                               || ' OPI_MEASURE1,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_onhand_value',
                                                  'p_onhand_value',
                                                  'p_onhand_value',
                                                  'OPI_MEASURE2') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_intransit_value')
                                               || ' OPI_MEASURE3,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_intransit_value',
                                                  'p_intransit_value',
                                                  'p_intransit_value',
                                                  'OPI_MEASURE4') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_wip_value')
                                               || ' OPI_MEASURE5,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_wip_value',
                                                  'p_wip_value',
                                                  'p_wip_value',
                                                  'OPI_MEASURE6') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('p_inv_total_value')
                                               || ' OPI_MEASURE7,
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_inv_total_value')
                                               || ' OPI_MEASURE8,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_inv_total_value',
                                                  'p_inv_total_value',
                                                  'p_inv_total_value',
                                                  'OPI_MEASURE9') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str ('c_inv_total_value',
                                                   'c_inv_total_value_total',
                                                   'OPI_MEASURE10') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_onhand_value_total')
                                                   || ' OPI_MEASURE11,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_onhand_value_total',
                                                      'p_onhand_value_total',
                                                  'p_onhand_value_total',
                                                  'OPI_MEASURE12') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_intransit_value_total')
                                               || ' OPI_MEASURE13,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_intransit_value_total',
                                                  'p_intransit_value_total',
                                                  'p_intransit_value_total',
                                                  'OPI_MEASURE14') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_wip_value_total')
                                               || ' OPI_MEASURE15,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_wip_value_total',
                                                  'p_wip_value_total',
                                                  'p_wip_value_total',
                                                  'OPI_MEASURE16') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_inv_total_value_total')
                                               || ' OPI_MEASURE17,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_inv_total_value_total',
                                                  'p_inv_total_value_total',
                                                  'p_inv_total_value_total',
                                                  'OPI_MEASURE18') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str ('c_inv_total_value_total',
                                                   'c_inv_total_value_total',
                                                   'OPI_MEASURE19') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_inv_total_value')
                                               || ' OPI_MEASURE20,
            ' || opi_dbi_rpt_util_pkg.nvl_str ('p_inv_total_value')
                                               || ' OPI_MEASURE21,
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_inv_total_value_total')
                                               || ' OPI_MEASURE22,
            ' || opi_dbi_rpt_util_pkg.nvl_str ('p_inv_total_value_total')
                                               || ' OPI_MEASURE23,
            ' || '''pFunctionName=OPI_DBI_INV_ONH_ORG_TBL_REP&VIEW_BY_NAME=VIEW_BY_VALUE&VIEW_BY=' || p_view_by_dim || ''' OPI_DYNAMIC_URL_1,
            ' || '''pFunctionName=OPI_DBI_INV_INT_ORG_TBL_REP&VIEW_BY_NAME=VIEW_BY_VALUE&VIEW_BY=' || p_view_by_dim || ''' OPI_DYNAMIC_URL_2 ';


  RETURN l_sel_clause;

END get_inv_val_status_sel_clause;


/*
    For viewby = item_org, the inventory value report has to display
    a description and unit of measure
*/
PROCEDURE get_inv_val_item_columns (p_dim_name VARCHAR2,
                                p_description OUT NOCOPY VARCHAR2,
                                p_uom OUT NOCOPY VARCHAR2)

IS
   l_description varchar2(30);
   l_uom varchar2(30);

BEGIN
      CASE
      WHEN p_dim_name = 'ITEM+ENI_ITEM_ORG' THEN
              BEGIN
                  p_description := 'v.description';
                  p_uom := 'v2.unit_of_measure';
              END;
          ELSE
              BEGIN
                  p_description := 'null';
                  p_uom := 'null';
              END;
      END CASE;

END get_inv_val_item_columns;



/*----------------------------------------
Inventory Value Report Functions
  ----------------------------------------*/


/*
    Report query for viewby = time
*/

/*
    Report query for viewby = Time
*/
PROCEDURE inv_val_trend_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                             x_custom_sql OUT NOCOPY VARCHAR2,
                             x_custom_output OUT NOCOPY
                             BIS_QUERY_ATTRIBUTES_TBL)
IS
    l_query VARCHAR2(15000);
    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_xtd varchar2(10);
    l_comparison_type VARCHAR2(1);
    l_cur_suffix VARCHAR2(5);
    l_custom_sql VARCHAR2(4000);
    l_mv VARCHAR2 (30);
    l_where_clause VARCHAR2 (4000);

    l_aggregation_level_flag VARCHAR2(1);

    l_custom_rec BIS_QUERY_ATTRIBUTES;

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

BEGIN

    -- initialization block
    l_comparison_type := 'Y';
    l_where_clause := '';
    l_aggregation_level_flag := '0';

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

    -- get all the query parameters
    opi_dbi_rpt_util_pkg.process_parameters (p_param => p_param,
                                          p_view_by => l_view_by,
                                          p_view_by_col_name => l_view_by_col,
                                          p_comparison_type => l_comparison_type,
                                          p_xtd => l_xtd,
                                          p_cur_suffix => l_cur_suffix,
                                          p_where_clause => l_where_clause,
                                          p_mv => l_mv,
                                          p_join_tbl => l_join_tbl,
                                          p_mv_level_flag => l_aggregation_level_flag,
                                          p_trend => 'Y',
                                          p_func_area => 'OPI',
                                          p_version => '7.0',
                                          p_role => '',
                                          p_mv_set => 'INV_VAL',
                                          p_mv_flag_type => 'INV_VAL_LEVEL');

    -- The measure columns that need to be aggregated are
    -- onhand_value_<b/g>, intransit_value_<b/g>,
    -- wip_value_<b/g>, inv_total_value_<b/g>
    -- No Grand totals required.

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'onhand_value_' || l_cur_suffix,
                                 'onhand_value',
                                 'N');

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'intransit_value_' || l_cur_suffix,
                                 'intransit_value',
                                 'N');

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'wip_value_' || l_cur_suffix,
                                 'wip_value',
                                 'N');

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'inv_total_value_' || l_cur_suffix,
                                 'inv_total_value',
                                 'N');


    -- Joining Outer and Inner Query
    l_query := get_inv_val_trend_sel_clause(l_view_by) ||
               ' from ' ||
               poa_dbi_template_pkg.trend_sql (
                    l_xtd,
                    l_comparison_type,
                    l_mv,
                    l_where_clause,
                    l_col_tbl,
                    'N');



    -- Prepare PMV bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- get all the basic binds used by POA queries
    -- Do this before adding any of our binds, since the procedure
    -- reinitializes the output table
    poa_dbi_util_pkg.get_custom_trend_binds (l_xtd, l_comparison_type,
                                             x_custom_output);

    -- Passing OPI_AGGREGATION_LEVEL_FLAG to PMV
    l_custom_rec.attribute_name := ':OPI_AGGREGATION_LEVEL_FLAG';
    l_custom_rec.attribute_value := l_aggregation_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    -- make the nested pattern ITD since inv. value is reported as a balance,
    -- not an XTD value.
    l_query := replace (l_query, '&BIS_NESTED_PATTERN', '1143');

    x_custom_sql := l_query;

    x_custom_sql := l_query;


END inv_val_trend_sql;

/*
    The outer main query for the trend SQL.
*/
FUNCTION get_inv_val_trend_sel_clause (p_view_by_dim IN VARCHAR2)
    RETURN VARCHAR2
IS

    l_sel_clause varchar2(4500);

BEGIN

    -- Main Outer query

    l_sel_clause :=
    'SELECT
        ' || ' cal.name VIEWBY,
        ' || opi_dbi_rpt_util_pkg.nvl_str ('iset.c_onhand_value')
                                           || ' OPI_MEASURE1,
        ' || opi_dbi_rpt_util_pkg.change_str ('iset.c_onhand_value',
                                              'iset.p_onhand_value',
                                              'iset.p_onhand_value',
                                              'OPI_MEASURE2') || ',
        ' || opi_dbi_rpt_util_pkg.nvl_str ('iset.c_intransit_value')
                                           || ' OPI_MEASURE3,
        ' || opi_dbi_rpt_util_pkg.change_str ('iset.c_intransit_value',
                                              'iset.p_intransit_value',
                                              'iset.p_intransit_value',
                                              'OPI_MEASURE4') || ',
        ' || opi_dbi_rpt_util_pkg.nvl_str ('iset.c_wip_value')
                                           || ' OPI_MEASURE5,
        ' || opi_dbi_rpt_util_pkg.change_str ('iset.c_wip_value',
                                              'iset.p_wip_value',
                                              'iset.p_wip_value',
                                              'OPI_MEASURE6') || ',
        ' || opi_dbi_rpt_util_pkg.nvl_str ('iset.p_inv_total_value')
                                           || ' OPI_MEASURE8,
        ' || opi_dbi_rpt_util_pkg.nvl_str ('iset.c_inv_total_value')
                                           || ' OPI_MEASURE7,
        ' || opi_dbi_rpt_util_pkg.change_str ('iset.c_inv_total_value',
                                              'iset.p_inv_total_value',
                                              'iset.p_inv_total_value',
                                              'OPI_MEASURE9') ;  --OPI Measure 9 is added for bug 3570094

  RETURN l_sel_clause;

END get_inv_val_trend_sel_clause;

PROCEDURE onhand_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY
                              BIS_QUERY_ATTRIBUTES_TBL)
IS
    l_query VARCHAR2(15000);
    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_xtd VARCHAR2(10);
    l_comparison_type VARCHAR2(1);
    l_cur_suffix VARCHAR2(5);
    l_custom_sql VARCHAR2 (10000);

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

    l_where_clause VARCHAR2 (2000);
    l_mv VARCHAR2 (30);

    l_aggregation_level_flag varchar2(1);
    l_custom_rec BIS_QUERY_ATTRIBUTES;
    l_filter_where  VARCHAR2(120);

BEGIN

    -- initialization block
    l_comparison_type := 'Y';
    l_aggregation_level_flag := '0';

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();


    -- get all the query parameters
    opi_dbi_rpt_util_pkg.process_parameters (p_param => p_param,
                                          p_view_by => l_view_by,
                                          p_view_by_col_name => l_view_by_col,
                                          p_comparison_type => l_comparison_type,
                                          p_xtd => l_xtd,
                                          p_cur_suffix => l_cur_suffix,
                                          p_where_clause => l_where_clause,
                                          p_mv => l_mv,
                                          p_join_tbl => l_join_tbl,
                                          p_mv_level_flag => l_aggregation_level_flag,
                                          p_trend => 'N',
                                          p_func_area => 'OPI',
                                          p_version => '7.0',
                                          p_role => '',
                                          p_mv_set => 'ONH',
                                          p_mv_flag_type => 'INV_VAL_LEVEL');

    -- The measure columns that need to be aggregated are
    -- onhand_value_<b/g>, onhand_qty,
    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'onhand_value_' || l_cur_suffix,
                                 'onhand_value');

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                     'onhand_qty',
                                     'onhand_qty');

    --Add filtering condition to suppress rows
    l_filter_where :=     'abs(OPI_MEASURE1) > 0 ' ||
                       'OR abs(OPI_MEASURE4) > 0 ' ||
                       'OR abs(OPI_MEASURE5) > 0';

    -- construct the query
    l_query := get_onhand_sel_clause (l_view_by, l_join_tbl)
          || ' from
        ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
                                              p_where_clause    => l_where_clause,
                                              p_join_tables     => l_join_tbl,
                                              p_use_windowing   => 'Y',
                                              p_col_name        => l_col_tbl,
                                              p_use_grpid       => 'N',
                                              p_filter_where    => l_filter_where);

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

    -- Passing OPI_AGGREGATION_LEVEL_FLAG to PMV
    l_custom_rec.attribute_name := ':OPI_AGGREGATION_LEVEL_FLAG';
    l_custom_rec.attribute_value := l_aggregation_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

        -- make the nested pattern ITD since inv. value is reported as a balance,
        -- not an XTD value.
        l_query := replace (l_query, '&BIS_NESTED_PATTERN', '1143');

    x_custom_sql := l_query;

END onhand_sql;

FUNCTION get_onhand_sel_clause(p_view_by_dim IN VARCHAR2,
                               p_join_tbl IN
                               poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    return VARCHAR2
IS

    l_sel_clause varchar2(4500);
    l_view_by_col_name varchar2(60);
    l_description varchar2(30);
    l_uom varchar2(30);
    l_view_by_fact_col VARCHAR2(400);
    l_drill_url_1 VARCHAR2 (500);

BEGIN

    -- Main Outer query

    -- Column to get view by column name
    l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                (p_view_by_dim);
    -- Description for item view by
    get_inv_val_item_columns (p_view_by_dim, l_description, l_uom);

    -- fact column view by's
    l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                (p_join_tbl);

    -- Drill across URL, for viewby Item, is AsOfDate = trunc (sysdate)
    l_drill_url_1 := 'NULL';
    IF (p_view_by_dim = 'ITEM+ENI_ITEM_ORG') THEN
    -- {
        l_drill_url_1 := ' decode (&BIS_CURRENT_ASOF_DATE,
                                    trunc (sysdate), ''pFunctionName=OPI_DBI_INV_CURR_STS_TBL_REP&VIEW_BY_NAME=VIEW_BY_VALUE&VIEW_BY=' || 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL' || ''', NULL) ';
    -- }
    END IF;

    -- Outer select clause
    l_sel_clause :=
    'SELECT
    ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
      || l_view_by_col_name || ' OPI_ATTRIBUTE1,
    ' || l_description || ' OPI_ATTRIBUTE2,
    ' || l_uom || ' OPI_ATTRIBUTE3,
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
    ' || 'OPI_DYNAMIC_URL_1
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
    ' || 'OPI_DYNAMIC_URL_1
    ' || 'FROM
    ' || '(SELECT
            ' || l_view_by_fact_col || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_onhand_qty')
                                               || ' OPI_MEASURE1,
            ' || opi_dbi_rpt_util_pkg.nvl_str ('p_onhand_qty')
                                               || ' OPI_MEASURE2,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_onhand_qty',
                                                  'p_onhand_qty',
                                                  'p_onhand_qty',
                                                  'OPI_MEASURE3') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('p_onhand_value')
                                               || ' OPI_MEASURE4,
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_onhand_value')
                                               || ' OPI_MEASURE5,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_onhand_value',
                                                  'p_onhand_value',
                                                  'p_onhand_value',
                                                  'OPI_MEASURE6') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str ('c_onhand_value',
                                                   'c_onhand_value_total',
                                                   'OPI_MEASURE7') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_onhand_value_total')
                                               || ' OPI_MEASURE8,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_onhand_value_total',
                                                  'p_onhand_value_total',
                                                  'p_onhand_value_total',
                                                  'OPI_MEASURE9') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str ('c_onhand_value_total',
                                                   'c_onhand_value_total',
                                                   'OPI_MEASURE10') || ',
            ' || l_drill_url_1 || ' OPI_DYNAMIC_URL_1 ';

  RETURN l_sel_clause;

END get_onhand_sel_clause;

PROCEDURE intransit_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY
                              BIS_QUERY_ATTRIBUTES_TBL)
IS
    l_query VARCHAR2(15000);
    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_xtd VARCHAR2(10);
    l_comparison_type VARCHAR2(1);
    l_cur_suffix VARCHAR2(5);
    l_custom_sql VARCHAR2 (10000);

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

    l_where_clause VARCHAR2 (2000);
    l_mv VARCHAR2 (30);

    l_aggregation_level_flag varchar2(1);
    l_custom_rec BIS_QUERY_ATTRIBUTES;
    l_filter_where  VARCHAR2(120);

BEGIN

    -- initialization block
    l_comparison_type := 'Y';
    l_aggregation_level_flag := '0';

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();


    -- get all the query parameters
    opi_dbi_rpt_util_pkg.process_parameters (p_param => p_param,
                                          p_view_by => l_view_by,
                                          p_view_by_col_name => l_view_by_col,
                                          p_comparison_type => l_comparison_type,
                                          p_xtd => l_xtd,
                                          p_cur_suffix => l_cur_suffix,
                                          p_where_clause => l_where_clause,
                                          p_mv => l_mv,
                                          p_join_tbl => l_join_tbl,
                                          p_mv_level_flag => l_aggregation_level_flag,
                                          p_trend => 'N',
                                          p_func_area => 'OPI',
                                          p_version => '7.0',
                                          p_role => '',
                                          p_mv_set => 'INT',
                                          p_mv_flag_type => 'INV_VAL_LEVEL');

    -- The measure columns that need to be aggregated are
    -- onhand_value_<b/g>, onhand_qty,
    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'intransit_value_' || l_cur_suffix,
                                 'intransit_value');

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                     'intransit_qty',
                                     'intransit_qty');

    --Add filtering condition to suppress rows
    l_filter_where :=     'abs(OPI_MEASURE1) > 0 ' ||
                       'OR abs(OPI_MEASURE4) > 0 ' ||
                       'OR abs(OPI_MEASURE5) > 0';

    -- construct the query
    l_query := get_intransit_sel_clause (l_view_by, l_join_tbl)
          || ' from
        ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
                                              p_where_clause    => l_where_clause,
                                              p_join_tables     => l_join_tbl,
                                              p_use_windowing   => 'Y',
                                              p_col_name        => l_col_tbl,
                                              p_use_grpid       => 'N',
                                              p_filter_where    => l_filter_where);

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

    -- Passing OPI_AGGREGATION_LEVEL_FLAG to PMV
    l_custom_rec.attribute_name := ':OPI_AGGREGATION_LEVEL_FLAG';
    l_custom_rec.attribute_value := l_aggregation_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

        -- make the nested pattern ITD since inv. value is reported as a balance,
        -- not an XTD value.
        l_query := replace (l_query, '&BIS_NESTED_PATTERN', '1143');

    x_custom_sql := l_query;

END intransit_sql;

FUNCTION get_intransit_sel_clause(p_view_by_dim IN VARCHAR2,
                                  p_join_tbl IN
                                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    return VARCHAR2
IS

    l_sel_clause varchar2(4500);
    l_view_by_col_name varchar2(60);
    l_description varchar2(30);
    l_uom varchar2(30);
    l_view_by_fact_col VARCHAR2(400);

BEGIN

    -- Main Outer query

    -- Column to get view by column name
    l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                (p_view_by_dim);

    -- Description for item view by
    get_inv_val_item_columns (p_view_by_dim, l_description, l_uom);

    -- fact column view by's
    l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                (p_join_tbl);

    -- Outer select clause
    l_sel_clause :=
    'SELECT
    ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
      || l_view_by_col_name || ' OPI_ATTRIBUTE1,
    ' || l_description || ' OPI_ATTRIBUTE2,
    ' || l_uom || ' OPI_ATTRIBUTE3,
    ' || 'oset.OPI_MEASURE1,
    ' || 'oset.OPI_MEASURE2,
    ' || 'oset.OPI_MEASURE3,
    ' || 'oset.OPI_MEASURE4,
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
    ' || 'OPI_MEASURE1,
    ' || 'OPI_MEASURE2,
    ' || 'OPI_MEASURE3,
    ' || 'OPI_MEASURE4,
    ' || 'OPI_MEASURE5,
    ' || 'OPI_MEASURE6,
    ' || 'OPI_MEASURE7,
    ' || 'OPI_MEASURE8,
    ' || 'OPI_MEASURE9,
    ' || 'OPI_MEASURE10
    ' || 'FROM
    ' || '(SELECT
            ' || l_view_by_fact_col || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_intransit_qty')
                                           || ' OPI_MEASURE1,
            ' || opi_dbi_rpt_util_pkg.nvl_str ('p_intransit_qty')
                                               || ' OPI_MEASURE2,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_intransit_qty',
                                                  'p_intransit_qty',
                                                  'p_intransit_qty',
                                                  'OPI_MEASURE3') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('p_intransit_value')
                                               || ' OPI_MEASURE4,
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_intransit_value')
                                               || ' OPI_MEASURE5,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_intransit_value',
                                                  'p_intransit_value',
                                                  'p_intransit_value',
                                                  'OPI_MEASURE6') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str ('c_intransit_value',
                                                   'c_intransit_value_total',
                                                   'OPI_MEASURE7') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str ('c_intransit_value_total')
                                               || ' OPI_MEASURE8,
            ' || opi_dbi_rpt_util_pkg.change_str ('c_intransit_value_total',
                                                  'p_intransit_value_total',
                                                  'p_intransit_value_total',
                                                  'OPI_MEASURE9') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str ('c_intransit_value_total',
                                                   'c_intransit_value_total',
                                                   'OPI_MEASURE10');

  RETURN l_sel_clause;

END get_intransit_sel_clause;

/*
    Report query Function for viewby = Item, Org, Cat.
*/
PROCEDURE inv_val_type_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql OUT NOCOPY VARCHAR2,
                              x_custom_output OUT NOCOPY
                              BIS_QUERY_ATTRIBUTES_TBL)
IS
-- {
    l_query VARCHAR2(15000);
    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_xtd VARCHAR2(10);
    l_comparison_type VARCHAR2(1);
    l_cur_suffix VARCHAR2(5);
    l_custom_sql VARCHAR2 (32767);
    l_viewby_rank_clause VARCHAR2 (32767);

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;


    l_where_clause VARCHAR2 (2000);
    l_mv VARCHAR2 (30);

    l_aggregation_level_flag varchar2(1);

    l_custom_rec BIS_QUERY_ATTRIBUTES;
    l_filter_where  VARCHAR2(120);
-- }
BEGIN
-- {
    -- initialization block
    l_comparison_type := 'Y';
    l_aggregation_level_flag := '0';

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();


    -- get all the query parameters
    opi_dbi_rpt_util_pkg.process_parameters (p_param => p_param,
                                          p_view_by => l_view_by,
                                          p_view_by_col_name => l_view_by_col,
                                          p_comparison_type => l_comparison_type,
                                          p_xtd => l_xtd,
                                          p_cur_suffix => l_cur_suffix,
                                          p_where_clause => l_where_clause,
                                          p_mv => l_mv,
                                          p_join_tbl => l_join_tbl,
                                          p_mv_level_flag => l_aggregation_level_flag,
                                          p_trend => 'N',
                                          p_func_area => 'OPI',
                                          p_version => '7.0',
                                          p_role => '',
                                          p_mv_set => 'INV_VAL',
                                          p_mv_flag_type => 'INV_VAL_LEVEL');

    -- Since this query is pretty straightforward, define most of it
    -- here. The only thing that will be returned from the OPI report
    -- query template is the where clause. The POA template is not
    -- directly needed.
    l_query :=  '
                select
                    inventory_type OPI_ATTRIBUTE1,
                ' || opi_dbi_rpt_util_pkg.nvl_str ('c_value') ||
                                                ' OPI_MEASURE1,
                ' || opi_dbi_rpt_util_pkg.change_str ('c_value',
                                                      'p_value',
                                                      'p_value',
                                                      'OPI_MEASURE2') || '
                  from
                        (select
                        fnd.meaning inventory_type,
                        sum (decode (fnd.lookup_code,
                                     ''ONH'', oset.c_onhand_value,
                                     ''INT'', oset.c_intransit_value,
                                     ''WIP'', oset.c_wip_value)) c_value,
                        sum (decode (fnd.lookup_code,
                                     ''ONH'', oset.p_onhand_value,
                                     ''INT'', oset.p_intransit_value,
                                     ''WIP'', oset.p_wip_value)) p_value
                ' ||
        ' from
            (select
                sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                           onhand_value_'
                           || l_cur_suffix || ', null))  c_onhand_value,
                sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
                           onhand_value_'
                           || l_cur_suffix || ', null))  p_onhand_value,
                sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                           intransit_value_'
                           || l_cur_suffix || ', null)) c_intransit_value,
                sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
                           intransit_value_'
                           || l_cur_suffix || ', null)) p_intransit_value,
                sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                           wip_value_'
                           || l_cur_suffix || ', null))  c_wip_value,
                sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
                           wip_value_'
                           || l_cur_suffix || ', null))  p_wip_value
              from ' || l_mv || ' fact, fii_time_rpt_struct_v cal
              where fact.time_id = cal.time_id
            ' || l_where_clause || '
                and cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
                and bitand(cal.record_type_id, 1143) = cal.record_type_id
              ) oset,
                fnd_lookup_values_vl fnd
                where fnd.lookup_type = ''OPI_DBI_INV_TYPE''
--                and fnd.language = USERENV(''LANG'')
                group by fnd.meaning) oset2
                &ORDER_BY_CLAUSE nulls last';


    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

    -- Passing OPI_AGGREGATION_LEVEL_FLAG to PMV
    l_custom_rec.attribute_name := ':OPI_AGGREGATION_LEVEL_FLAG';
    l_custom_rec.attribute_value := l_aggregation_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    -- make the nested pattern ITD since inv. value is reported as a balance,
    -- not an XTD value.
--    l_query := replace (l_query, '&BIS_NESTED_PATTERN', '1143');

    x_custom_sql := l_query;
-- }
END inv_val_type_sql;

END OPI_DBI_INV_MGMT_RPT_PKG;

/
