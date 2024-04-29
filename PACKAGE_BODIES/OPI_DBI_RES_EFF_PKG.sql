--------------------------------------------------------
--  DDL for Package Body OPI_DBI_RES_EFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_RES_EFF_PKG" AS
/*$Header: OPIDRRSEFB.pls 120.0 2005/05/27 18:38:32 appldev noship $ */


/*++++++++++++++++++++++++++++++++++++++++*/
/* Function and procedure declarations in this file but not in spec*/
/*++++++++++++++++++++++++++++++++++++++++*/

FUNCTION get_status_sel_clause (p_view_by_dim IN VARCHAR2, p_period_type in VARCHAR2, p_org in VARCHAR2)
    RETURN VARCHAR2;

PROCEDURE get_qty_columns (p_dim_name VARCHAR2,
                           p_description OUT NOCOPY VARCHAR2,
                           p_uom OUT NOCOPY VARCHAR2,
                           p_qty1 OUT NOCOPY VARCHAR2,
                           p_qty2 OUT NOCOPY VARCHAR2,
                           p_qty3 OUT NOCOPY VARCHAR2);


FUNCTION get_trend_sel_clause(p_view_by_dim IN VARCHAR2, p_url IN VARCHAR2)
    return VARCHAR2;


/*----------------------------------------*/

/*
    Report query Function for viewby = Resource Group, Department, Resource, Org
*/
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

    l_period_type VARCHAR2(255)  := NULL;
    l_org VARCHAR2(255) := NULL;

BEGIN

    -- clear out the tables.
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();


    -- Extracting the period type selected
    FOR i IN 1..p_param.COUNT
    LOOP
      	IF(p_param(i).parameter_name = 'PERIOD_TYPE')
       	    THEN l_period_type := p_param(i).parameter_value;
        END IF;

        IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
            THEN l_org := p_param(i).parameter_value;
        END IF;

    END LOOP;

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
                                          'RSEF',
                                          'RESOURCE_LEVEL');

    -- The measure columns that need to be aggregated are


    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'std_usage_qty',
                                 'std_usage_qty');

    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'actual_qty',
                                 'actual_qty');

    -- construct the query
    l_query := get_status_sel_clause (l_view_by, l_period_type, l_org)
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


/*
    Outer main query for viewby = Org,Resource Group, Resource Department, Resource
*/

FUNCTION get_status_sel_clause(p_view_by_dim IN VARCHAR2, p_period_type in VARCHAR2, p_org VARCHAR2)
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
    'SELECT '|| opi_dbi_rpt_util_pkg.get_viewby_select_clause(p_view_by_dim) ||
                l_view_by_col_name                              || ' OPI_ATTRIBUTE1,';

    IF ((p_view_by_dim = 'RESOURCE+ENI_RESOURCE') AND
       (upper(p_org) <> 'ALL') AND
       (p_period_type = 'FII_TIME_WEEK' OR p_period_type = 'FII_TIME_ENT_PERIOD')) THEN
            l_sel_clause := l_sel_clause || ' ''pFunctionName=OPI_DBI_RES_EFF_JOB_DTL_REP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=RESOURCE+ENI_RESOURCE&pParamIds=Y'' OPI_ATTRIBUTE2 ,';
        ELSE
            l_sel_clause := l_sel_clause || 'NULL OPI_ATTRIBUTE2 ,';
    END IF;

    l_sel_clause := l_sel_clause ||
           l_qty2                                          || ' OPI_MEASURE1,
      ' || l_qty1                                          || ' OPI_MEASURE2,
      ' || opi_dbi_rpt_util_pkg.percent_str ('oset.p_std_usage_qty',
                                             'oset.p_actual_qty',
                                             ' OPI_MEASURE3') || ',
      ' || opi_dbi_rpt_util_pkg.percent_str ('oset.c_std_usage_qty',
                                             'oset.c_actual_qty',
                                             ' OPI_MEASURE4') || ',
      ' || opi_dbi_rpt_util_pkg.percent_str ('oset.c_std_usage_qty',
                                             'oset.c_actual_qty',
                                             '') || ' -
      ' || opi_dbi_rpt_util_pkg.percent_str ('oset.p_std_usage_qty',
                                             'oset.p_actual_qty',
                                             '') || ' OPI_MEASURE5 ,
      ' || opi_dbi_rpt_util_pkg.nvl_str ('oset.c_std_usage_qty_total')
                                                 || ' OPI_MEASURE7 ,
      ' || opi_dbi_rpt_util_pkg.nvl_str ('oset.c_actual_qty_total')
                                                 || ' OPI_MEASURE8 ,
      ' || opi_dbi_rpt_util_pkg.percent_str ('oset.c_std_usage_qty_total',
                                             'oset.c_actual_qty_total',
                                             ' OPI_MEASURE9') || ',
      ' || opi_dbi_rpt_util_pkg.percent_str ('oset.c_std_usage_qty_total',
                                             'oset.c_actual_qty_total',
                                             '') || ' -
      ' || opi_dbi_rpt_util_pkg.percent_str ('oset.p_std_usage_qty_total',
                                             'oset.p_actual_qty_total',
                                             '') || ' OPI_MEASURE10 ';

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
                                    ('oset.c_std_usage_qty');
                  p_qty3 := opi_dbi_rpt_util_pkg.percent_str
                                        ('oset.c_std_usage_qty',
                                         'oset.c_actual_qty',
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
                                          'RSEF',
                                          'RESOURCE_LEVEL');

    -- The measure columns that need to be aggregated are
    -- No Grand totals required.
    poa_dbi_util_pkg.add_column (l_col_tbl,
                                'actual_qty',
                                'actual_qty',
                                'N');
    poa_dbi_util_pkg.add_column (l_col_tbl,
                                 'std_usage_qty',
                                 'std_usage_qty',
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
        ' || opi_dbi_rpt_util_pkg.nvl_str ('iset.c_std_usage_qty')
                                           || ' OPI_MEASURE1,
        ' || opi_dbi_rpt_util_pkg.nvl_str ('iset.c_actual_qty')
                                           || ' OPI_MEASURE2,
        ' || opi_dbi_rpt_util_pkg.percent_str ('iset.p_std_usage_qty',
                                               'iset.p_actual_qty',
                                               'OPI_MEASURE3') || ',
        ' || opi_dbi_rpt_util_pkg.percent_str ('iset.c_std_usage_qty',
        				       'iset.c_actual_qty ',
                                               'OPI_MEASURE4') || ',
        ' || opi_dbi_rpt_util_pkg.percent_str ('iset.c_std_usage_qty',
                                                     'iset.c_actual_qty',
                                                     '') || ' -
        ' || opi_dbi_rpt_util_pkg.percent_str ('iset.p_std_usage_qty',
                                                'iset.p_actual_qty',
                                               '') || ' OPI_MEASURE5 ';

  RETURN l_sel_clause;

END get_trend_sel_clause;

END opi_dbi_res_eff_pkg;

/
