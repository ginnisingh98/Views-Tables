--------------------------------------------------------
--  DDL for Package Body OPI_DBI_PRD_CST_MARGIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_PRD_CST_MARGIN_PKG" AS
/*$Header: OPIDRPPGMB.pls 120.0 2005/05/24 18:21:01 appldev noship $ */

/*++++++++++++++++++++++++++++++++++++++++*/
/* Function and procedure declarations in this file but not in spec*/
/*++++++++++++++++++++++++++++++++++++++++*/


FUNCTION get_status_sel_clause(p_view_by_dim IN VARCHAR2,
                               p_join_tbl IN
                               poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    return VARCHAR2;

FUNCTION get_trend_sel_clause(p_view_by_dim IN VARCHAR2, p_url IN VARCHAR2)
    return VARCHAR2;

PROCEDURE get_qty_columns (p_dim_name VARCHAR2,
                           x_description OUT NOCOPY VARCHAR2,
                           x_uom OUT NOCOPY VARCHAR2,
                           x_qty1 OUT NOCOPY VARCHAR2);

FUNCTION get_drill_across (p_view_by_dim IN VARCHAR2)
    return VARCHAR2;
/*
    Report query Function for viewby = Item, Org, Cat, Customer
*/
PROCEDURE margin_status_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                             x_custom_sql OUT NOCOPY VARCHAR2,
                             x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
    l_query VARCHAR2(32767);
    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_xtd VARCHAR2(10);
    l_comparison_type VARCHAR2(1);
    l_cur_suffix VARCHAR2(2);
    l_custom_sql VARCHAR2 (10000);

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

    l_where_clause VARCHAR2 (2000);
    l_mv VARCHAR2 (2000);

    l_mv_flag_type  VARCHAR2(50);
    l_mv_set  VARCHAR2(50);

    l_prd_cust_flag VARCHAR2(100);
    l_custom_rec BIS_QUERY_ATTRIBUTES;

BEGIN

    -- initialization block
    l_comparison_type := 'Y';
    l_prd_cust_flag := '';

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

    -- get all the query parameters
    OPI_DBI_RPT_UTIL_PKG.process_parameters (p_param => p_param,
                                             p_view_by => l_view_by,
                                             p_view_by_col_name => l_view_by_col,
                                             p_comparison_type => l_comparison_type,
                                             p_xtd => l_xtd,
                                             p_cur_suffix => l_cur_suffix,
                                             p_where_clause => l_where_clause,
                                             p_mv => l_mv,
                                             p_join_tbl => l_join_tbl,
                                             p_mv_level_flag => l_prd_cust_flag,
                                             p_trend => 'N',
                                             p_func_area => 'OPI',
                                             p_version => '7.0',
                                             p_role => '',
                                             p_mv_set => 'PGM',
                                             p_mv_flag_type => 'PRD_CUST');

    -- The measure columns that need to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'fulfilled_val_' || l_cur_suffix,
                                 p_alias_name => 'fulfilled_val');

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'cogs_val_' || l_cur_suffix,
                                 p_alias_name => 'cogs_val');

    IF (l_view_by = 'ITEM+ENI_ITEM_ORG') THEN
        poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                     p_col_name => 'decode(organization_id,top_model_org_id,NVL(fulfilled_qty,0),NULL)',
                                     p_alias_name => 'fulfilled_qty',
                                     p_grand_total => 'N');
    END IF;

    -- construct the query
    l_query := get_status_sel_clause (l_view_by, l_join_tbl)
          || ' from
        ' || poa_dbi_template_pkg.status_sql (p_fact_name => l_mv,
                                              p_where_clause => l_where_clause,
                                              p_join_tables => l_join_tbl,
                                              p_use_windowing => 'Y',
                                              p_col_name => l_col_tbl,
                                              p_use_grpid => 'N');

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);


    /*
     No Bind Variables if the MV being used is at the Root Product Category level.
    */

    IF (l_mv <> 'OPI_PGM_CAT_MV') THEN
    l_custom_rec.attribute_name := ':OPI_PRDCAT_CUST_FLAG';
    l_custom_rec.attribute_value := l_prd_cust_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;
    END IF;
    x_custom_sql := l_query;

END margin_status_sql;

/*
    Outer main query for viewby = item, org, cat, customer
*/


FUNCTION get_status_sel_clause(p_view_by_dim IN VARCHAR2,
                               p_join_tbl IN
                               poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    return VARCHAR2
IS
    l_sel_clause varchar2(10000);
    l_view_by_col_name varchar2(60);
    l_description varchar2(30);
    l_uom varchar2(30);
    l_qty1 varchar2(35);
    l_view_by_fact_col VARCHAR2(400);


    l_c_fulfilled_val varchar2(35);
    l_p_fulfilled_val varchar2(35);
    l_c_margin varchar2(100);
    l_p_margin varchar2(100);

    l_c_fulfilled_val_total varchar2(35);
    l_p_fulfilled_val_total varchar2(35);
    l_c_margin_total varchar2(100);
    l_p_margin_total varchar2(100);
    l_drill_across_url varchar2(500);



BEGIN
    -- Main Outer query
    -- Column to get view by column name
    l_view_by_col_name := OPI_DBI_RPT_UTIL_PKG.get_view_by_col_name (p_view_by_dim);
    get_qty_columns (p_view_by_dim, l_description, l_uom, l_qty1);
    -- Fulfilled Value/COGS/Margin
    l_p_margin := OPI_DBI_RPT_UTIL_PKG.nvl_str ('p_fulfilled_val') || '-' ||
                  OPI_DBI_RPT_UTIL_PKG.nvl_str ('p_cogs_val');
    l_c_margin := OPI_DBI_RPT_UTIL_PKG.nvl_str ('c_fulfilled_val') || '-' ||
                  OPI_DBI_RPT_UTIL_PKG.nvl_str ('c_cogs_val');
    l_p_margin_total := OPI_DBI_RPT_UTIL_PKG.nvl_str ('p_fulfilled_val_total')
                        || '-' ||
                        OPI_DBI_RPT_UTIL_PKG.nvl_str ('p_cogs_val_total');
    l_c_margin_total := OPI_DBI_RPT_UTIL_PKG.nvl_str ('c_fulfilled_val_total')
                        || '-' ||
                        OPI_DBI_RPT_UTIL_PKG.nvl_str ('c_cogs_val_total');

    l_p_fulfilled_val := OPI_DBI_RPT_UTIL_PKG.nvl_str ('p_fulfilled_val');
    l_c_fulfilled_val := OPI_DBI_RPT_UTIL_PKG.nvl_str ('c_fulfilled_val');
    l_p_fulfilled_val_total := OPI_DBI_RPT_UTIL_PKG.nvl_str ('p_fulfilled_val_total');
    l_c_fulfilled_val_total := OPI_DBI_RPT_UTIL_PKG.nvl_str ('c_fulfilled_val_total');
    l_drill_across_url := get_drill_across (p_view_by_dim => p_view_by_dim);
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
    ' || l_drill_across_url || ' OPI_DYNAMIC_URL_1
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
    ' || 'OPI_MEASURE19
    ' || 'FROM
    ' || '(SELECT
          ' || l_view_by_fact_col || ',
          ' || OPI_DBI_RPT_UTIL_PKG.nvl_str ('c_fulfilled_val')
                                            || ' OPI_MEASURE1,
          ' || OPI_DBI_RPT_UTIL_PKG.nvl_str ('c_cogs_val')
                                            || ' OPI_MEASURE2,
          ' || l_p_margin || ' OPI_MEASURE3,
          ' || l_c_margin || ' OPI_MEASURE4,
          ' || OPI_DBI_RPT_UTIL_PKG.change_str (l_c_margin,
                                                l_p_margin,
                                                l_p_margin, '')
                                            || ' OPI_MEASURE5,
          ' || OPI_DBI_RPT_UTIL_PKG.percent_str (l_p_margin,
                                                 l_p_fulfilled_val, '')
                                            || ' OPI_MEASURE6,
          ' || OPI_DBI_RPT_UTIL_PKG.percent_str (l_c_margin,
                                                 l_c_fulfilled_val, '')
                                            || ' OPI_MEASURE7,
          ' || OPI_DBI_RPT_UTIL_PKG.change_pct_str (l_c_margin,
                                                    l_c_fulfilled_val,
                                                    l_p_margin,
                                                    l_p_fulfilled_val, '')
                                            || ' OPI_MEASURE8,
          ' || OPI_DBI_RPT_UTIL_PKG.nvl_str ('c_fulfilled_val_total')
                                            || ' OPI_MEASURE9,
          ' || OPI_DBI_RPT_UTIL_PKG.nvl_str ('c_cogs_val_total')
                                            || ' OPI_MEASURE10,
          ' || l_c_margin_total || ' OPI_MEASURE11,
          ' || OPI_DBI_RPT_UTIL_PKG.change_str (l_c_margin_total,
                                                l_p_margin_total,
                                                l_p_margin_total, '')
                                            || ' OPI_MEASURE12,
          ' || OPI_DBI_RPT_UTIL_PKG.percent_str (l_c_margin_total,
                                                 l_c_fulfilled_val_total, '')
                                            || ' OPI_MEASURE13,
          ' || OPI_DBI_RPT_UTIL_PKG.change_pct_str (l_c_margin_total,
                                                    l_c_fulfilled_val_total,
                                                    l_p_margin_total,
                                                    l_p_fulfilled_val_total,
                                                    '')
                                            || ' OPI_MEASURE14,
          ' || OPI_DBI_RPT_UTIL_PKG.percent_str (l_c_margin,
                                                 l_c_fulfilled_val, '')
                                            || ' OPI_MEASURE15,
          ' || OPI_DBI_RPT_UTIL_PKG.percent_str (l_p_margin,
                                                 l_p_fulfilled_val, '')
                                            || ' OPI_MEASURE16,
          ' || OPI_DBI_RPT_UTIL_PKG.nvl_str (l_qty1)
                                            || ' OPI_MEASURE17,
          ' || OPI_DBI_RPT_UTIL_PKG.percent_str (l_c_margin_total,
                                                 l_c_fulfilled_val_total, '')
                                            || ' OPI_MEASURE18,
          ' || OPI_DBI_RPT_UTIL_PKG.percent_str (l_p_margin_total,
                                                 l_p_fulfilled_val_total, '')
                                            || ' OPI_MEASURE19 ';

  RETURN l_sel_clause;

END get_status_sel_clause;

/*
    For viewby = item, get the quantity columns that have to be displayed.
    For all other viewby values, there is no quantity to display.
*/
PROCEDURE get_qty_columns (p_dim_name VARCHAR2,
                           x_description OUT NOCOPY VARCHAR2,
                           x_uom OUT NOCOPY VARCHAR2,
                           x_qty1 OUT NOCOPY VARCHAR2)
IS
BEGIN
      CASE
      WHEN p_dim_name = 'ITEM+ENI_ITEM_ORG' THEN
              BEGIN
                  x_description := 'v.description';
                  x_uom := 'v2.unit_of_measure';
                  --x_qty1 := opi_dbi_rpt_util_pkg.nvl_str ('c_fulfilled_qty');
                  x_qty1 := 'c_fulfilled_qty';
              END;
          ELSE
              BEGIN
                  x_description := 'null';
                  x_uom := 'null';
                  x_qty1 := 'null';
              END;
      END CASE;
END get_qty_columns;

/*
     This Drill Across is for ViewBy Product Category.
     If it is a LeafNode the Drill Across is ViewBy is Item else ViewBy Product Category.
*/
FUNCTION get_drill_across (p_view_by_dim IN VARCHAR2)
   return VARCHAR2
IS
    l_drill_across VARCHAR2(500);
BEGIN

    -- initialization block
    l_drill_across := 'NULL';

    IF (p_view_by_dim = 'ITEM+ENI_ITEM_VBH_CAT') THEN
        l_drill_across := 'decode(v.leaf_node_flag, ''Y'',
        ''pFunctionName=OPI_DBI_PRD_CST_MARGIN_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_ORG&pParamIds=Y'',
        ''pFunctionName=OPI_DBI_PRD_CST_MARGIN_TBL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'') ';
    END IF;
    RETURN l_drill_across;
END get_drill_across ;

/*
    Report query for viewby = time (Trend Report)
*/

PROCEDURE margin_trend_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
    l_query VARCHAR2(32767);
    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_xtd varchar2(10);
    l_comparison_type VARCHAR2(1);
    l_cur_suffix VARCHAR2(2);
    l_custom_sql VARCHAR2(4000);
    l_mv VARCHAR2 (2000);
    l_where_clause VARCHAR2 (4000);
    l_custom_rec BIS_QUERY_ATTRIBUTES;

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

    l_mv_flag_type  VARCHAR2(50);
    l_mv_set  VARCHAR2(50);

    l_prd_cust_flag VARCHAR2(100);

BEGIN

    -- initialization block
    l_comparison_type := 'Y';
    l_where_clause := '';
    l_prd_cust_flag := '';

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

    -- get all the query parameters
    OPI_DBI_RPT_UTIL_PKG.process_parameters (p_param => p_param,
                                             p_view_by => l_view_by,
                                             p_view_by_col_name => l_view_by_col,
                                             p_comparison_type => l_comparison_type,
                                             p_xtd => l_xtd,
                                             p_cur_suffix => l_cur_suffix,
                                             p_where_clause => l_where_clause,
                                             p_mv => l_mv,
                                             p_join_tbl => l_join_tbl,
                                             p_mv_level_flag => l_prd_cust_flag,
                                             p_trend => 'Y',
                                             p_func_area => 'OPI',
                                             p_version => '7.0',
                                             p_role => '',
                                             p_mv_set => 'PGM',
                                             p_mv_flag_type => 'PRD_CUST');


    -- The measure columns that need to be aggregated are
    -- production_val_<b/g>, scrap_val_<b/g>
    -- If viewing by item as, then sum up
    -- production_qty, scrap_qty.
    -- No Grand totals required.
    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'fulfilled_val_' || l_cur_suffix,
                                 p_alias_name => 'fulfilled_val',
                                 p_grand_total => 'N');

    poa_dbi_util_pkg.add_column (p_col_tbl => l_col_tbl,
                                 p_col_name => 'cogs_val_' || l_cur_suffix,
                                 p_alias_name => 'cogs_val',
                                 p_grand_total => 'N');

    -- Joining Outer and Inner Query
    l_query := get_trend_sel_clause(l_view_by, null) ||
               ' from ' ||
               poa_dbi_template_pkg.trend_sql (p_xtd => l_xtd,
                                       p_comparison_type => l_comparison_type,
                                       p_fact_name => l_mv,
                                       p_where_clause => l_where_clause,
                                       p_col_name => l_col_tbl,
                                       p_use_grpid => 'N');

    -- Prepare PMV bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- get all the basic binds used by POA queries
    -- Do this before adding any of our binds, since the procedure
    -- reinitializes the output table
    poa_dbi_util_pkg.get_custom_trend_binds (p_xtd => l_xtd,
                             p_comparison_type => l_comparison_type,
                                             x_custom_output => x_custom_output);

    /*
     No Bind Variables if the MV being used is at the Root Product Category level.
    */
    l_custom_rec.attribute_name := ':OPI_PRDCAT_CUST_FLAG';
    l_custom_rec.attribute_value := l_prd_cust_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;
END margin_trend_sql;


/*
    The outer main query for the trend SQL.
*/
FUNCTION get_trend_sel_clause(p_view_by_dim IN VARCHAR2, p_url IN VARCHAR2)
    return VARCHAR2
IS

    l_sel_clause varchar2(4500);
    l_c_fulfilled_val varchar2(35);
    l_p_fulfilled_val varchar2(35);
    l_c_margin varchar2(100);
    l_p_margin varchar2(100);

BEGIN

    -- Fulfilled Value/COGS/Margin

    l_p_margin := OPI_DBI_RPT_UTIL_PKG.nvl_str ('iset.p_fulfilled_val') || '-' || OPI_DBI_RPT_UTIL_PKG.nvl_str ('iset.p_cogs_val');
    l_c_margin := OPI_DBI_RPT_UTIL_PKG.nvl_str ('iset.c_fulfilled_val') || '-' || OPI_DBI_RPT_UTIL_PKG.nvl_str ('iset.c_cogs_val');

    l_p_fulfilled_val := OPI_DBI_RPT_UTIL_PKG.nvl_str ('iset.p_fulfilled_val');
    l_c_fulfilled_val := OPI_DBI_RPT_UTIL_PKG.nvl_str ('iset.c_fulfilled_val');

    -- Main Outer query
    l_sel_clause :=
        'SELECT
    ' || ' cal.name VIEWBY,
    ' || OPI_DBI_RPT_UTIL_PKG.nvl_str ('iset.c_fulfilled_val') || ' OPI_MEASURE1,
    ' || OPI_DBI_RPT_UTIL_PKG.nvl_str ('iset.c_cogs_val') || ' OPI_MEASURE2,
    ' || l_p_margin       || ' OPI_MEASURE3,
    ' || l_c_margin       || ' OPI_MEASURE4,
    ' || OPI_DBI_RPT_UTIL_PKG.change_str (l_c_margin, l_p_margin, l_p_margin, '') || ' OPI_MEASURE5,
    ' || OPI_DBI_RPT_UTIL_PKG.percent_str (l_p_margin, l_p_fulfilled_val, '') || ' OPI_MEASURE6,
    ' || OPI_DBI_RPT_UTIL_PKG.percent_str (l_c_margin, l_c_fulfilled_val, '') || ' OPI_MEASURE7,
    ' || OPI_DBI_RPT_UTIL_PKG.change_pct_str (l_c_margin, l_c_fulfilled_val,
                            l_p_margin, l_p_fulfilled_val, '') || ' OPI_MEASURE8 ';
  RETURN l_sel_clause;

END get_trend_sel_clause;

END opi_dbi_prd_cst_margin_pkg;

/
