--------------------------------------------------------
--  DDL for Package Body OPI_DBI_RES_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_RES_UTL_PKG" AS
/*$Header: OPIDRRSUTB.pls 120.0 2005/05/24 18:08:48 appldev noship $ */


/*++++++++++++++++++++++++++++++++++++++++*/
/* Function and procedure declarations in this file but not in spec*/
/*++++++++++++++++++++++++++++++++++++++++*/

FUNCTION get_status_sel_clause (p_view_by_dim IN VARCHAR2)
    RETURN VARCHAR2;

PROCEDURE get_qty_columns (p_dim_name VARCHAR2,
                           p_description OUT NOCOPY VARCHAR2,
                           p_uom OUT NOCOPY VARCHAR2,
                           p_qty1 OUT NOCOPY VARCHAR2,
                           p_qty2 OUT NOCOPY VARCHAR2,
                           p_qty3 OUT NOCOPY VARCHAR2);


FUNCTION get_trend_sel_clause(p_view_by_dim IN VARCHAR2, p_url IN VARCHAR2)
    return VARCHAR2;


PROCEDURE get_rpt_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
    l_query VARCHAR2(15000);
    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_xtd VARCHAR2(10);
    l_comparison_type VARCHAR2(1) := 'Y';
    l_cur_suffix VARCHAR2(2);
    l_custom_sql VARCHAR2 (10000);

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

    l_where_clause VARCHAR2 (2000);
    l_mv VARCHAR2 (30);

    l_resource_level_flag varchar2(1) := '0';

    l_custom_rec BIS_QUERY_ATTRIBUTES;

BEGIN

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();


    -- get all the query parameters
    opi_dbi_rpt_util_pkg.process_parameters (p_param,
                                          l_view_by,
                                          l_view_by_col,
                                          l_comparison_type,
                                          l_xtd,
                                          l_cur_suffix,
                                          l_where_clause,
                                          l_mv,
                                          l_join_tbl,
                                          l_resource_level_flag,
                                          'N',
                                          'OPI',
                                          '6.0',
                                          '',
                                          'RSUT',
                                          'RESOURCE_LEVEL');

    -- The measure columns that need to be aggregated are
    -- avail_val_ <b/g>, actual_val_ <b/g>
    -- If viewing by Resource, then sum up
    -- avail_qty, actual_qty

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'avail_val_' || l_cur_suffix,
                                 'avail_val');

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'actual_val_' || l_cur_suffix,
                                 'actual_val');

    -- Quantity columns are only needed for Resource viewby.
   -- IF (l_view_by = 'RESOURCE+ENI_RESOURCE') THEN
    	poa_dbi_util_pkg.add_column (l_col_tbl,
                                     'avail_qty',
                                     'avail_qty');

    	poa_dbi_util_pkg.add_column (l_col_tbl,
                                     'actual_qty',
                                     'actual_qty');
    -- END IF;

    -- construct the query

    l_query := get_status_sel_clause (l_view_by)
          || ' from ((
        ' || poa_dbi_template_pkg.status_sql (l_mv,
                                              l_where_clause,
                                              l_join_tbl,
                                              'N',
                                              l_col_tbl,
                                              'N');

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

    -- Passing OPI_RESOURCE_LEVEL_FLAG to PMV
    l_custom_rec.attribute_name := ':OPI_RESOURCE_LEVEL_FLAG';
    l_custom_rec.attribute_value := l_resource_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;

END get_rpt_sql;


FUNCTION get_status_sel_clause(p_view_by_dim IN VARCHAR2)
    return VARCHAR2
IS

    l_sel_clause varchar2(4500);
    l_view_by_col_name varchar2(60);
    l_description varchar2(30);
    l_uom varchar2(30) := '';
    l_qty1 varchar2(35);
    l_qty2 varchar2(35);
    l_qty3 varchar2(200);

BEGIN

    -- Main Outer query

    -- Column to get view by column name
    l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                (p_view_by_dim);

    -- Quantity columns for
    get_qty_columns (p_view_by_dim, l_description, l_uom, l_qty1,
                     l_qty2, l_qty3);

    -- Outer select clause
    l_sel_clause :=
    'SELECT
        ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
          || l_view_by_col_name || ' OPI_ATTRIBUTE1,
          NULL	 OPI_ATTRIBUTE2,
        ' || l_qty1 || ' OPI_MEASURE1,
        ' || opi_dbi_rpt_util_pkg.nvl_str ('oset.c_actual_val')
                                           || ' OPI_MEASURE2,
        ' || l_qty2 || ' OPI_MEASURE3,
        ' || opi_dbi_rpt_util_pkg.nvl_str ('oset.c_avail_val')
                                           || ' OPI_MEASURE4,
        ' || opi_dbi_rpt_util_pkg.percent_str ('oset.p_actual_val',
                                            'oset.p_avail_val',
                                            'OPI_MEASURE5') || ',
        ' || opi_dbi_rpt_util_pkg.percent_str ('oset.c_actual_val',
                                            'oset.c_avail_val',
                                            'OPI_MEASURE6') || ',
        ' || opi_dbi_rpt_util_pkg.change_pct_str ('oset.c_actual_val',
                                               'oset.c_avail_val',
                                               'oset.p_actual_val',
                                               'oset.p_avail_val',
                                               'OPI_MEASURE7') || ',
        ' || opi_dbi_rpt_util_pkg.nvl_str ('oset.c_actual_val_total')
                                           || ' OPI_MEASURE8,
        ' || opi_dbi_rpt_util_pkg.nvl_str ('oset.c_avail_val_total')
                                           || ' OPI_MEASURE9,
        ' || opi_dbi_rpt_util_pkg.percent_str ('oset.c_actual_val_total',
                                            'oset.c_avail_val_total',
                                            'OPI_MEASURE10') || ',
        ' || opi_dbi_rpt_util_pkg.change_pct_str ('oset.c_actual_val_total',
                                               'oset.c_avail_val_total',
                                               'oset.p_actual_val_total',
                                               'oset.p_avail_val_total',
                                               'OPI_MEASURE11') || ',
        ' || opi_dbi_rpt_util_pkg.nvl_str('oset.c_avail_qty_total')
                                            || ' OPI_MEASURE16 ,
        ' || opi_dbi_rpt_util_pkg.nvl_str('oset.c_actual_qty_total')
                                            || ' OPI_MEASURE17 ,
	' || opi_dbi_rpt_util_pkg.percent_str ('oset.c_actual_val',
                                            'oset.c_avail_val',
                                            'OPI_MEASURE12') || ',
        ' || opi_dbi_rpt_util_pkg.percent_str ('oset.p_actual_val',
                                            'oset.p_avail_val',
                                               'OPI_MEASURE13') || ',
	' || opi_dbi_rpt_util_pkg.percent_str ('oset.c_actual_val_total',
                                            'oset.c_avail_val_total',
                                            'OPI_MEASURE14') || ',
	' || opi_dbi_rpt_util_pkg.percent_str ('oset.p_actual_val_total',
                                            'oset.p_avail_val_total',
                                            'OPI_MEASURE15'
                                               );

  RETURN l_sel_clause;

END get_status_sel_clause;


PROCEDURE get_qty_columns (p_dim_name VARCHAR2,
                           p_description OUT NOCOPY VARCHAR2,
                           p_uom OUT NOCOPY VARCHAR2,
                           p_qty1 OUT NOCOPY VARCHAR2,
                           p_qty2 OUT NOCOPY VARCHAR2,
                           p_qty3 OUT NOCOPY VARCHAR2)
IS
   l_description varchar2(30);
   l_uom varchar2(30);

BEGIN
      CASE
      WHEN p_dim_name = 'RESOURCE+ENI_RESOURCE' THEN
              BEGIN
/*
                  p_description := 'v.description';
                  p_uom := 'v2.unit_of_measure';
*/
                  p_qty1 := opi_dbi_rpt_util_pkg.nvl_str ('oset.c_actual_qty');
                  p_qty2 := opi_dbi_rpt_util_pkg.nvl_str
                                    ('oset.c_avail_qty');
                  p_qty3 := opi_dbi_rpt_util_pkg.percent_str
                                        ('oset.c_actual_qty',
                                         'oset.c_avail_qty',
                                         '');
              END;
          ELSE
              BEGIN
/*
                  p_description := 'null';
                  p_uom := 'null';
*/
                  p_qty1 := 'null';
                  p_qty2 := 'null';
                  p_qty3 := 'null';
              END;
      END CASE;
END get_qty_columns;


/*
    Report query for viewby = time
*/

PROCEDURE get_trd_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
    l_query VARCHAR2(15000);
    l_view_by VARCHAR2(120);
    l_view_by_col VARCHAR2 (120);
    l_xtd varchar2(10);
    l_comparison_type VARCHAR2(1) := 'Y';
    l_cur_suffix VARCHAR2(2);
    l_custom_sql VARCHAR2(4000);
    l_mv VARCHAR2 (30);
    l_where_clause VARCHAR2 (4000) := '';

    l_resource_level_flag VARCHAR2(1) := '0';

    l_custom_rec BIS_QUERY_ATTRIBUTES;

    l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

BEGIN

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

    -- get all the query parameters
    opi_dbi_rpt_util_pkg.process_parameters (p_param,
                                          l_view_by,
                                          l_view_by_col,
                                          l_comparison_type,
                                          l_xtd,
                                          l_cur_suffix,
                                          l_where_clause,
                                          l_mv,
                                          l_join_tbl,
                                          l_resource_level_flag,
                                          'Y',
                                          'OPI',
                                          '6.0',
                                          '',
                                          'RSUT',
                                          'RESOURCE_LEVEL');

    -- The measure columns that need to be aggregated are
    -- avail_val_ <b/g>, actual_val_ <b/g>
    -- No Grand totals required.
    poa_dbi_util_pkg.add_column (l_col_tbl,
                                'actual_val_' || l_cur_suffix,
                                'actual_val',
                                'N');
    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'avail_val_' || l_cur_suffix,
                                 'avail_val',
                                 'N');

    -- Joining Outer and Inner Query
    l_query := get_trend_sel_clause(l_view_by, null) ||
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

    -- put the custom OPI binds in
    l_custom_rec.attribute_name := ':OPI_RESOURCE_LEVEL_FLAG';
    l_custom_rec.attribute_value := l_resource_level_flag;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    x_custom_sql := l_query;


END get_trd_sql;

/*
    The outer main query for the trend SQL.
*/

FUNCTION get_trend_sel_clause(p_view_by_dim IN VARCHAR2, p_url IN VARCHAR2)
    return VARCHAR2
IS

    l_sel_clause varchar2(4500);

BEGIN

    -- Main Outer query

    l_sel_clause :=
    'SELECT
        ' || ' cal.name VIEWBY,
        ' || ' cal.name OPI_ATTRIBUTE1,
        ' || opi_dbi_rpt_util_pkg.nvl_str ('iset.c_actual_val')
                                           || ' OPI_MEASURE1,
        ' || opi_dbi_rpt_util_pkg.nvl_str ('iset.c_actual_val')
                                           || ' OPI_MEASURE2,
        ' || opi_dbi_rpt_util_pkg.nvl_str ('iset.c_avail_val')
                                           || ' OPI_MEASURE3,
        ' || opi_dbi_rpt_util_pkg.nvl_str ('iset.c_avail_val')
                                           || ' OPI_MEASURE4,
        ' || opi_dbi_rpt_util_pkg.percent_str ('iset.p_actual_val',
                                            'iset.p_avail_val',
                                            'OPI_MEASURE5') || ',
        ' || opi_dbi_rpt_util_pkg.percent_str ('iset.c_actual_val',
                                            'iset.c_avail_val',
                                            'OPI_MEASURE6') || ',
        ' || opi_dbi_rpt_util_pkg.change_pct_str ('iset.c_actual_val',
                                               'iset.c_avail_val',
                                               'iset.p_actual_val',
                                               'iset.p_avail_val',
                                               'OPI_MEASURE7');
  RETURN l_sel_clause;

END get_trend_sel_clause;

END opi_dbi_res_utl_pkg;

/
