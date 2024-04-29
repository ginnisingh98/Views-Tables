--------------------------------------------------------
--  DDL for Package Body OPI_DBI_WMS_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_WMS_RPT_PKG" AS
/* $Header: OPIDRWWAAB.pls 120.0 2005/05/24 19:05:17 appldev noship $ */
-- ----------------------------------------
-- Declare Private Procedures and Functions
-- ----------------------------------------
FUNCTION GET_PICK_EX_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
RETURN VARCHAR2;

FUNCTION GET_PICK_REASON_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
RETURN VARCHAR2;

FUNCTION GET_PICK_EX_TRD_SEL_CLAUSE (p_view_by_dim IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION GET_OPP_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
RETURN VARCHAR2;

FUNCTION GET_OP_EX_REASON_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
RETURN VARCHAR2;

-- -------------------------------------------------------------------
-- Name       : GET_PICK_EX_SQL
-- Description: Generate query for Picks and Exception Analysis Report
-- -------------------------------------------------------------------
PROCEDURE GET_PICK_EX_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)

IS

    l_query                     VARCHAR2(15000);
    l_view_by                   VARCHAR2(120);
    l_view_by_col               VARCHAR2 (120);
    l_xtd                       VARCHAR2(10);
    l_comparison_type           VARCHAR2(1);
    l_cur_suffix                VARCHAR2(5);
    l_custom_sql                VARCHAR2 (10000);
    l_subinv_val                VARCHAR2 (120) := NULL;
    l_col_tbl                   poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_where_clause              VARCHAR2 (2000);
    l_mv                        VARCHAR2 (30);
    l_aggregation_level_flag    VARCHAR2(10);
    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_mv_tbl                    poa_dbi_util_pkg.poa_dbi_mv_tbl;
    l_filter_where              VARCHAR2(120);
BEGIN
    -- initialization block
    l_comparison_type := 'Y';
    l_aggregation_level_flag := '0';

    -- clear out the column and Join info tables.
    l_col_tbl  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
    l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

    -- get all the query parameters
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
                                 p_mv_level_flag    => l_aggregation_level_flag,
                                 p_trend            => 'N',
                                 p_func_area        => 'OPI',
                                 p_version          => '7.1',
                                 p_role             => '',
                                 p_mv_set           => 'PEX',
                                 p_mv_flag_type     => 'WMS_PEX');

    -- Add measure columns that need to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                 p_col_name     => 'picks' ,
                                 p_alias_name   => 'picks',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                 p_col_name     => 'picks_with_exceptions' ,
                                 p_alias_name   => 'picks_with_exceptions',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                 p_col_name     => 'pick_exceptions',
                                 p_alias_name   => 'pick_exceptions',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    --Add filtering condition to suppress rows
    l_filter_where := 'OPI_MEASURE11 > 0 or OPI_MEASURE1 > 0';

    --Generate Final Query
    l_query := GET_PICK_EX_SEL_CLAUSE (l_view_by, l_join_tbl) || fnd_global.newline
            || 'from
          ' || poa_dbi_template_pkg.status_sql (
                                p_fact_name       => l_mv,
                                p_where_clause    => l_where_clause,
                                p_join_tables     => l_join_tbl,
                                p_use_windowing   => 'Y',
                                p_col_name        => l_col_tbl,
                                p_use_grpid       => 'N',
                                p_paren_count     => 3,
                                p_filter_where    => l_filter_where,
                                p_generate_viewby => 'Y',
                                p_in_join_tables  => NULL);

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);
    poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd);

    -- Passing aggregation level flag to PMV
    l_custom_rec.attribute_name     := ':OPI_PEX_AGG_LEVEL_FLAG';
    l_custom_rec.attribute_value    := l_aggregation_level_flag;
    l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;

    x_custom_output(x_custom_output.count) := l_custom_rec;

    commit;

    x_custom_sql := l_query;

END GET_PICK_EX_SQL;

-- -------------------------------------------------------------------
-- Name       : GET_PICK_EX_SEL_CLAUSE
-- Description: build select clause for Picks and Exception Analysis
-- -------------------------------------------------------------------
FUNCTION GET_PICK_EX_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2
IS
    l_sel_clause                VARCHAR2(15000);
    l_view_by_col_name          VARCHAR2(120);
    l_description               VARCHAR2(30);
    l_uom                       VARCHAR2(30);
    l_view_by_fact_col          VARCHAR2(400);

BEGIN
    l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                            (p_view_by_dim);
    l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                            (p_join_tbl);

    -- Item Description and UOM for item view by
    opi_dbi_rpt_util_pkg.get_viewby_item_columns(
                                    p_dim_name => p_view_by_dim,
                                    p_description => l_description,
                                    p_uom => l_uom);

    -- Start generating SELECT clause for query
    l_sel_clause :=
        'SELECT
            ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
            || fnd_global.newline ||'       ' || l_description ||
            ' OPI_ATTRIBUTE10 ';

    l_sel_clause := l_sel_clause ||'
        ,OPI_MEASURE11
        ,OPI_MEASURE1
        ,OPI_MEASURE2
        ,OPI_MEASURE3
        ,OPI_MEASURE12
        ,OPI_MEASURE4
        ,OPI_MEASURE5
        ,OPI_MEASURE13
        ,OPI_MEASURE6
        ,OPI_MEASURE7
        ,OPI_MEASURE14
        ,OPI_MEASURE8
        ,OPI_MEASURE9
        ,OPI_MEASURE21
        ,OPI_MEASURE22
        ,OPI_MEASURE23
        ,OPI_MEASURE24
        ,OPI_MEASURE25
        ,OPI_MEASURE26
        ,OPI_MEASURE27
        ,OPI_MEASURE28
        ,OPI_MEASURE29
        ,OPI_MEASURE30
        ,OPI_MEASURE31
        ,OPI_MEASURE32
        ,OPI_MEASURE33 '|| fnd_global.newline;

    l_sel_clause := l_sel_clause || 'FROM ( SELECT
     rank() over (&ORDER_BY_CLAUSE nulls last '||', '||l_view_by_fact_col||') - 1 rnk
       ,'||l_view_by_fact_col;

    l_sel_clause := l_sel_clause ||'
        ,OPI_MEASURE11
        ,OPI_MEASURE1
        ,OPI_MEASURE2
        ,OPI_MEASURE3
        ,OPI_MEASURE12
        ,OPI_MEASURE4
        ,OPI_MEASURE5
        ,OPI_MEASURE13
        ,OPI_MEASURE6
        ,OPI_MEASURE7
        ,OPI_MEASURE14
        ,OPI_MEASURE8
        ,OPI_MEASURE9
        ,OPI_MEASURE21
        ,OPI_MEASURE22
        ,OPI_MEASURE23
        ,OPI_MEASURE24
        ,OPI_MEASURE25
        ,OPI_MEASURE26
        ,OPI_MEASURE27
        ,OPI_MEASURE28
        ,OPI_MEASURE29
        ,OPI_MEASURE30
        ,OPI_MEASURE31
        ,OPI_MEASURE32
        ,OPI_MEASURE33 '|| fnd_global.newline;

    l_sel_clause := l_sel_clause ||
    'FROM ( SELECT  '  || fnd_global.newline ||'
          ' || l_view_by_fact_col || ',
          ' || opi_dbi_rpt_util_pkg.nvl_str (
                       p_str         => 'p_picks',
                       p_default_val => 0) || ' OPI_MEASURE11,
          '  || opi_dbi_rpt_util_pkg.nvl_str (
                       p_str         => 'c_picks',
                       p_default_val => 0) || ' OPI_MEASURE1,
          ' || opi_dbi_rpt_util_pkg.change_str (
                       p_new_numerator   => 'c_picks',
                       p_old_numerator   => 'p_picks',
                       p_denominator     => 'p_picks',
                       p_measure_name    => 'OPI_MEASURE2') || ',
          ' || opi_dbi_rpt_util_pkg.percent_str(
                       p_numerator      => 'c_picks',
                       p_denominator    => 'c_picks_total',
                       p_measure_name   => 'OPI_MEASURE3') || ',
          ' || opi_dbi_rpt_util_pkg.nvl_str (
                       p_str         => 'p_picks_with_exceptions',
                       p_default_val => 0) || ' OPI_MEASURE12,
          ' || opi_dbi_rpt_util_pkg.nvl_str (
                       p_str         => 'c_picks_with_exceptions',
                       p_default_val => 0) || ' OPI_MEASURE4,
          ' || opi_dbi_rpt_util_pkg.change_str (
                       p_new_numerator   => 'c_picks_with_exceptions',
                       p_old_numerator   => 'p_picks_with_exceptions',
                       p_denominator     => 'p_picks_with_exceptions',
                       p_measure_name    => 'OPI_MEASURE5') || ',
          ' || opi_dbi_rpt_util_pkg.percent_str(
                       p_numerator      => 'p_picks_with_exceptions',
                       p_denominator    => 'p_picks',
                       p_measure_name   => 'OPI_MEASURE13') || ',
          ' || opi_dbi_rpt_util_pkg.percent_str(
                       p_numerator      => 'c_picks_with_exceptions',
                       p_denominator    => 'c_picks',
                       p_measure_name   => 'OPI_MEASURE6') || ',
          ' || opi_dbi_rpt_util_pkg.change_pct_str (
                       p_new_numerator   => 'c_picks_with_exceptions',
                       p_new_denominator => 'c_picks',
                       p_old_numerator   => 'p_picks_with_exceptions',
                       p_old_denominator => 'p_picks',
                       p_measure_name    => 'OPI_MEASURE7') || ',
          ' || opi_dbi_rpt_util_pkg.nvl_str (
                       p_str         => 'p_pick_exceptions',
                       p_default_val => 0) || ' OPI_MEASURE14,
          ' || opi_dbi_rpt_util_pkg.nvl_str (
                       p_str         => 'c_pick_exceptions',
                       p_default_val => 0) || ' OPI_MEASURE8,
          ' || opi_dbi_rpt_util_pkg.change_str (
                       p_new_numerator   => 'c_pick_exceptions',
                       p_old_numerator   => 'p_pick_exceptions',
                       p_denominator     => 'p_pick_exceptions',
                       p_measure_name    => 'OPI_MEASURE9') || ',
          ' || opi_dbi_rpt_util_pkg.nvl_str (
                       p_str         => 'c_picks_total',
                       p_default_val => 0) || ' OPI_MEASURE21,
          ' || opi_dbi_rpt_util_pkg.change_str (
                       p_new_numerator   => 'c_picks_total',
                       p_old_numerator   => 'p_picks_total',
                       p_denominator     => 'p_picks_total',
                       p_measure_name    => 'OPI_MEASURE22') || ',
          ' || opi_dbi_rpt_util_pkg.percent_str(
                       p_numerator      => 'c_picks_total',
                       p_denominator    => 'c_picks_total',
                       p_measure_name   => 'OPI_MEASURE23')  || ',
          ' || opi_dbi_rpt_util_pkg.nvl_str (
                       p_str         => 'c_picks_with_exceptions_total',
                       p_default_val => 0) || ' OPI_MEASURE24,
          ' || opi_dbi_rpt_util_pkg.change_str (
                       p_new_numerator   => 'c_picks_with_exceptions_total',
                       p_old_numerator   => 'p_picks_with_exceptions_total',
                       p_denominator     => 'p_picks_with_exceptions_total',
                       p_measure_name    => 'OPI_MEASURE25') || ',
          ' || opi_dbi_rpt_util_pkg.percent_str(
                       p_numerator      => 'c_picks_with_exceptions_total',
                       p_denominator    => 'c_picks_total',
                       p_measure_name   => 'OPI_MEASURE26')  || ',
          ' || opi_dbi_rpt_util_pkg.change_pct_str (
                       p_new_numerator   => 'c_picks_with_exceptions_total',
                       p_new_denominator => 'c_picks_total',
                       p_old_numerator   => 'p_picks_with_exceptions_total',
                       p_old_denominator => 'p_picks_total',
                       p_measure_name    => 'OPI_MEASURE27') || ',
          ' || opi_dbi_rpt_util_pkg.nvl_str (
                       p_str         => 'c_pick_exceptions_total',
                       p_default_val => 0) || ' OPI_MEASURE28,
          ' || opi_dbi_rpt_util_pkg.change_str (
                       p_new_numerator   => 'c_pick_exceptions_total',
                       p_old_numerator   => 'p_pick_exceptions_total',
                       p_denominator     => 'p_pick_exceptions_total',
                       p_measure_name    => 'OPI_MEASURE29') || ',
          ' || opi_dbi_rpt_util_pkg.percent_str(
                       p_numerator      => 'c_picks_with_exceptions',
                       p_denominator    => 'c_picks',
                       p_measure_name   => 'OPI_MEASURE30') || ',
          ' || opi_dbi_rpt_util_pkg.percent_str(
                       p_numerator      => 'p_picks_with_exceptions',
                       p_denominator    => 'p_picks',
                       p_measure_name   => 'OPI_MEASURE31') || ',
          ' || opi_dbi_rpt_util_pkg.percent_str(
                       p_numerator      => 'c_picks_with_exceptions_total',
                       p_denominator    => 'c_picks_total',
                       p_measure_name   => 'OPI_MEASURE32')  || ',
          ' || opi_dbi_rpt_util_pkg.percent_str(
                       p_numerator      => 'p_picks_with_exceptions_total',
                       p_denominator    => 'p_picks_total',
                       p_measure_name   => 'OPI_MEASURE33');
    RETURN l_sel_clause;
END GET_PICK_EX_SEL_CLAUSE;

-- -------------------------------------------------------------------
-- Name       : GET_EX_REASON_SQL
-- Description: Generate query for Picks Exception By Reason Report
-- -------------------------------------------------------------------
PROCEDURE GET_EX_REASON_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)

IS
    l_query                     VARCHAR2(15000);
    l_view_by                   VARCHAR2(120);
    l_view_by_col               VARCHAR2 (120);
    l_xtd                       VARCHAR2(10);
    l_comparison_type           VARCHAR2(1);
    l_cur_suffix                VARCHAR2(5);
    l_custom_sql                VARCHAR2 (10000);
    l_subinv_val                VARCHAR2 (120) := NULL;
    l_col_tbl                   poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_where_clause              VARCHAR2 (2000);
    l_mv                        VARCHAR2 (30);
    l_aggregation_level_flag    VARCHAR2(10);
    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_mv_tbl                    poa_dbi_util_pkg.poa_dbi_mv_tbl;

BEGIN
    -- initialization block
    l_comparison_type := 'Y';
    l_aggregation_level_flag := '0';

    -- clear out the column and Join info tables.
    l_col_tbl  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
    l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

    -- get all the query parameters
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
                                 p_mv_level_flag    => l_aggregation_level_flag,
                                 p_trend            => 'N',
                                 p_func_area        => 'OPI',
                                 p_version          => '7.1',
                                 p_role             => '',
                                 p_mv_set           => 'PER',
                                 p_mv_flag_type     => 'WMS_PER');

    -- Add measure columns that need to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                 p_col_name     => 'exceptions',
                                 p_alias_name   => 'exceptions',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    l_query := GET_PICK_REASON_SEL_CLAUSE (l_view_by, l_join_tbl) || fnd_global.newline
                || 'from
              ' || poa_dbi_template_pkg.status_sql (
                                p_fact_name       => l_mv,
                                p_where_clause    => l_where_clause,
                                p_join_tables     => l_join_tbl,
                                p_use_windowing   => 'Y',
                                p_col_name        => l_col_tbl,
                                p_use_grpid       => 'N',
                                p_paren_count     => 3,
                                p_filter_where    => NULL,
                                p_generate_viewby => 'Y',
                                p_in_join_tables  => NULL);

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);
    poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd);

    -- Passing aggregation level flag to PMV
    l_custom_rec.attribute_name     := ':OPI_PER_AGG_LEVEL_FLAG';
    l_custom_rec.attribute_value    := l_aggregation_level_flag;
    l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;

    x_custom_output(x_custom_output.count) := l_custom_rec;

    commit;

    x_custom_sql := l_query;

END GET_EX_REASON_SQL;

-- -------------------------------------------------------------------
-- Name       : GET_PICK_REASON_SEL_CLAUSE
-- Description: build select clause for Picks Exception By Reason
-- -------------------------------------------------------------------
FUNCTION GET_PICK_REASON_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2
IS
    l_sel_clause                VARCHAR2(15000);
    l_view_by_col_name          VARCHAR2(120);
    l_view_by_fact_col          VARCHAR2(400);
BEGIN
    l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                (p_view_by_dim);
    l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                (p_join_tbl);

    -- Start generating SELECT clause for query
    l_sel_clause :=
        'SELECT
           ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
          || fnd_global.newline;

    l_sel_clause := l_sel_clause ||
            'OPI_MEASURE1
            ,OPI_MEASURE2
            ,OPI_MEASURE3
            ,OPI_MEASURE4
            ,OPI_MEASURE5
            ,OPI_MEASURE6' || fnd_global.newline ||
        'FROM
            (SELECT (rank () over
               (&ORDER_BY_CLAUSE nulls last,
               ' || l_view_by_fact_col || ')) - 1 rnk,
               ' || l_view_by_fact_col || ',
              OPI_MEASURE1,
              OPI_MEASURE2,
              OPI_MEASURE3,
              OPI_MEASURE4,
              OPI_MEASURE5,
              OPI_MEASURE6'|| fnd_global.newline;

        l_sel_clause := l_sel_clause ||
            'FROM ( SELECT  '  || fnd_global.newline ||'
            ' ||  l_view_by_fact_col || ',
            ' ||  opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'c_exceptions',
                           p_default_val => 0) || ' OPI_MEASURE1,
            ' ||  opi_dbi_rpt_util_pkg.change_str (
                           p_new_numerator   => 'c_exceptions',
                           p_old_numerator   => 'p_exceptions',
                           p_denominator     => 'p_exceptions',
                           p_measure_name    => 'OPI_MEASURE2') || ',
           ' ||  opi_dbi_rpt_util_pkg.percent_str(
                           p_numerator      => 'c_exceptions',
                           p_denominator    => 'c_exceptions_total',
                           p_measure_name   => 'OPI_MEASURE3') || ',
            ' ||  opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'c_exceptions_total',
                           p_default_val => 0) || ' OPI_MEASURE4,
            ' ||  opi_dbi_rpt_util_pkg.change_str (
                           p_new_numerator   => 'c_exceptions_total',
                           p_old_numerator   => 'p_exceptions_total',
                           p_denominator     => 'p_exceptions_total',
                           p_measure_name    => 'OPI_MEASURE5') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str(
                           p_numerator      => 'c_exceptions_total',
                           p_denominator    => 'c_exceptions_total',
                           p_measure_name   => 'OPI_MEASURE6');
    RETURN l_sel_clause;
END GET_PICK_REASON_SEL_CLAUSE;

-- -------------------------------------------------------------
-- Name       : GET_PICK_TRD_SQL
-- Description: Generate query for Picks and Exception Trend
-- -------------------------------------------------------------
PROCEDURE get_pick_trd_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                             x_custom_sql OUT NOCOPY VARCHAR2,
                             x_custom_output OUT NOCOPY
                             BIS_QUERY_ATTRIBUTES_TBL)
IS
    l_query                     VARCHAR2(32767);
    l_view_by                   VARCHAR2(120);
    l_view_by_col               VARCHAR2 (120);
    l_xtd                       VARCHAR2(10);
    l_comparison_type           VARCHAR2(1);
    l_cur_suffix                VARCHAR2(5);
    l_custom_sql                VARCHAR2 (10000);
    l_col_tbl                   poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_in_join_tbl               poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_where_clause              VARCHAR2 (2000);
    l_mv                        VARCHAR2 (30);
    l_aggregation_level_flag    VARCHAR2(10);
    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_mv_tbl                    poa_dbi_util_pkg.poa_dbi_mv_tbl;
BEGIN
    -- initialization block
    l_comparison_type := 'Y';
    l_aggregation_level_flag := '0';

    -- clear out the tables.
    l_col_tbl  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
    l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

    -- Get Report Parameters for query
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
                                 p_mv_level_flag    =>l_aggregation_level_flag,
                                 p_trend            => 'Y',
                                 p_func_area        => 'OPI',
                                 p_version          => '7.1',
                                 p_role             => '',
                                 p_mv_set           => 'PEX',
                                 p_mv_flag_type     => 'WMS_PEX');

    -- Add measure columns to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                 p_col_name     => 'picks' ,
                                 p_alias_name   => 'picks',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                 p_col_name     => 'picks_with_exceptions',
                                 p_alias_name   => 'picks_with_exceptions',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                 p_col_name     => 'pick_exceptions',
                                 p_alias_name   => 'pick_exceptions',
                                 p_grand_total  => 'N',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    --Generate Final Query
    l_query := GET_PICK_EX_TRD_SEL_CLAUSE(l_view_by) ||
                   ' from ' ||
                    poa_dbi_template_pkg.trend_sql(
                                p_xtd              => l_xtd,
                                p_comparison_type  => l_comparison_type,
                                p_fact_name        =>  l_mv,
                                p_where_clause     => l_where_clause,
                                p_col_name         => l_col_tbl,
                                p_use_grpid        => 'N',
                                p_in_join_tables   => NULL,
                                p_fact_hint        => poa_dbi_sutil_pkg.get_fact_hint(l_mv)
                        );

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the trend SQL
    poa_dbi_util_pkg.get_custom_trend_binds (p_xtd => l_xtd,
                             p_comparison_type => l_comparison_type,
                                             x_custom_output => x_custom_output);
    poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd);

    -- Passing AGGREGATION_LEVEL_FLAG to PMV
    l_custom_rec.attribute_name     := ':OPI_PEX_AGG_LEVEL_FLAG';
    l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    l_custom_rec.attribute_value     := l_aggregation_level_flag;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    commit;
    x_custom_sql := l_query;

END get_pick_trd_sql;

-- -------------------------------------------------------------------
-- Name       : GET_PICK_EX_TRD_SEL_CLAUSE
-- Description: build select clause for Picks and Exception Trend
-- -------------------------------------------------------------------
FUNCTION GET_PICK_EX_TRD_SEL_CLAUSE (p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2
IS
    l_sel_clause varchar2(7500);
BEGIN
    -- Main Outer query
    l_sel_clause := 'SELECT
      ' || ' cal.name VIEWBY,
      ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'p_picks',
                    p_default_val   => 0) || ' OPI_MEASURE11,
      ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_picks',
                    p_default_val   => 0) || ' OPI_MEASURE1,
      ' || opi_dbi_rpt_util_pkg.change_str (
                    p_new_numerator     => 'c_picks',
                    p_old_numerator   => 'p_picks',
                    p_denominator     => 'p_picks',
                    p_measure_name      => 'OPI_MEASURE2') || ',
      ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'p_picks_with_exceptions',
                    p_default_val   => 0) || ' OPI_MEASURE12,
      ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_picks_with_exceptions',
                    p_default_val   => 0) || ' OPI_MEASURE3,
      ' || opi_dbi_rpt_util_pkg.change_str (
                    p_new_numerator  => 'c_picks_with_exceptions',
                    p_old_numerator  => 'p_picks_with_exceptions',
                    p_denominator    => 'p_picks_with_exceptions',
                    p_measure_name   => 'OPI_MEASURE4') || ',
      ' || opi_dbi_rpt_util_pkg.percent_str(
                   p_numerator       => 'p_picks_with_exceptions',
                   p_denominator    => 'p_picks',
                   p_measure_name   => 'OPI_MEASURE13') || ',
      ' || opi_dbi_rpt_util_pkg.percent_str(
                   p_numerator      => 'c_picks_with_exceptions',
                   p_denominator    => 'c_picks',
                   p_measure_name   => 'OPI_MEASURE5') || ',
      ' || opi_dbi_rpt_util_pkg.change_pct_str (
                   p_new_numerator   => 'c_picks_with_exceptions',
                   p_new_denominator => 'c_picks',
                   p_old_numerator   => 'p_picks_with_exceptions',
                   p_old_denominator => 'p_picks',
                   p_measure_name    => 'OPI_MEASURE6') || ',
      ' || opi_dbi_rpt_util_pkg.nvl_str (
                   p_str         => 'p_pick_exceptions',
                   p_default_val => 0) || ' OPI_MEASURE14,
      ' || opi_dbi_rpt_util_pkg.nvl_str (
                   p_str         => 'c_pick_exceptions',
                   p_default_val => 0) || ' OPI_MEASURE7,
      ' || opi_dbi_rpt_util_pkg.change_str (
                   p_new_numerator     => 'c_pick_exceptions',
                   p_old_numerator   => 'p_pick_exceptions',
                   p_denominator     => 'p_pick_exceptions',
                   p_measure_name      => 'OPI_MEASURE8');
RETURN l_sel_clause;

END GET_PICK_EX_TRD_SEL_CLAUSE;

-- -------------------------------------------------------------------
-- Name       : GET_OPP_SQL
-- Description: Generate query for Picks and Exception Analysis Report
-- -------------------------------------------------------------------
PROCEDURE GET_OPP_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)

IS
    l_query                     VARCHAR2(15000);
    l_view_by                   VARCHAR2(120);
    l_view_by_col               VARCHAR2 (120);
    l_xtd                       VARCHAR2(10);
    l_comparison_type           VARCHAR2(1);
    l_cur_suffix                VARCHAR2(5);
    l_custom_sql                VARCHAR2 (10000);
    l_subinv_val                VARCHAR2 (120) := NULL;
    l_col_tbl                   poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_where_clause              VARCHAR2 (2000);
    l_mv                        VARCHAR2 (30);
    l_aggregation_level_flag    VARCHAR2(10);
    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_mv_tbl                    poa_dbi_util_pkg.poa_dbi_mv_tbl;
    l_filter_where              VARCHAR2(120);
BEGIN
    -- initialization block
    l_comparison_type := 'Y';
    l_aggregation_level_flag := '0';

    -- clear out the column and Join info tables.
    l_col_tbl  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
    l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

    -- get all the query parameters
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
                                 p_mv_level_flag    => l_aggregation_level_flag,
                                 p_trend            => 'N',
                                 p_func_area        => 'OPI',
                                 p_version          => '7.1',
                                 p_role             => '',
                                 p_mv_set           => 'OPP',
                                 p_mv_flag_type     => 'WMS_OPP');

    -- Add measure columns that need to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                 p_col_name     => 'elapsed_time' ,
                                 p_alias_name   => 'elapsed_time',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                 p_col_name     => 'executions' ,
                                 p_alias_name   => 'executions',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                 p_col_name     => 'exec_with_exceptions',
                                 p_alias_name   => 'exec_with_exceptions',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                 p_col_name     => 'exceptions',
                                 p_alias_name   => 'exceptions',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');

    --Add filtering condition to suppress rows
    l_filter_where := 'OPI_MEASURE4 > 0' ||
                      ' OR OPI_MEASURE13 > 0' ||
                      ' OR OPI_MEASURE15 > 0' ;

        l_query := GET_OPP_SEL_CLAUSE (l_view_by, l_join_tbl)
                || ' from
              ' || poa_dbi_template_pkg.status_sql (
                                p_fact_name       => l_mv,
                                p_where_clause    => l_where_clause,
                                p_join_tables     => l_join_tbl,
                                p_use_windowing   => 'Y',
                                p_col_name        => l_col_tbl,
                                p_use_grpid       => 'N',
                                p_paren_count     => 3,
                                p_filter_where    => l_filter_where,
                                p_generate_viewby => 'Y',
                                p_in_join_tables  => NULL);

    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);
    poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd);

    -- Passing aggregation level flag to PMV
    l_custom_rec.attribute_name     := ':OPI_OPP_AGG_LEVEL_FLAG';
    l_custom_rec.attribute_value    := l_aggregation_level_flag;
    l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    commit;

    x_custom_sql := l_query;

END GET_OPP_SQL;

-- -------------------------------------------------------------------
-- Name       : GET_OPP_SEL_CLAUSE
-- Description: build select clause for Operation Plan Performance
-- -------------------------------------------------------------------
FUNCTION GET_OPP_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2
    IS
        l_sel_clause                VARCHAR2(15000);
        l_view_by_col_name          VARCHAR2(120);
        l_view_by_fact_col          VARCHAR2(400);
BEGIN
    l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                (p_view_by_dim);
    l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                (p_join_tbl);

    -- Start generating SELECT clause for query
    l_sel_clause :=
        'SELECT
        ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim) || fnd_global.newline;

        l_sel_clause := l_sel_clause ||'
             OPI_MEASURE13
            ,OPI_MEASURE2
            ,OPI_MEASURE3
            ,OPI_MEASURE4
            ,OPI_MEASURE5
            ,OPI_MEASURE15
            ,OPI_MEASURE6
            ,OPI_MEASURE7
            ,OPI_MEASURE16
            ,OPI_MEASURE8
            ,OPI_MEASURE9
            ,OPI_MEASURE21
            ,OPI_MEASURE22
            ,OPI_MEASURE23
            ,OPI_MEASURE24
            ,OPI_MEASURE25
            ,OPI_MEASURE26
            ,OPI_MEASURE27
            ,OPI_MEASURE28'|| fnd_global.newline;

        l_sel_clause := l_sel_clause ||
            'FROM ( SELECT
             rank() over (&ORDER_BY_CLAUSE nulls last '||', '||l_view_by_fact_col||') - 1 rnk
               ,'||l_view_by_fact_col;

        l_sel_clause := l_sel_clause ||'
            ,OPI_MEASURE13
            ,OPI_MEASURE2
            ,OPI_MEASURE3
            ,OPI_MEASURE4
            ,OPI_MEASURE5
            ,OPI_MEASURE15
            ,OPI_MEASURE6
            ,OPI_MEASURE7
            ,OPI_MEASURE16
            ,OPI_MEASURE8
            ,OPI_MEASURE9
            ,OPI_MEASURE21
            ,OPI_MEASURE22
            ,OPI_MEASURE23
            ,OPI_MEASURE24
            ,OPI_MEASURE25
            ,OPI_MEASURE26
            ,OPI_MEASURE27
            ,OPI_MEASURE28'|| fnd_global.newline;

        l_sel_clause := l_sel_clause ||
        'FROM ( SELECT  '  || fnd_global.newline ||
                         l_view_by_fact_col || fnd_global.newline ||
               ',' || opi_dbi_rpt_util_pkg.rate_str (
                           p_numerator       => 'p_elapsed_time',
                           p_denominator     => 'p_executions',
                           p_rate_type       => 'NP') || 'OPI_MEASURE13,
              ' || opi_dbi_rpt_util_pkg.rate_str (
                           p_numerator       => 'c_elapsed_time',
                           p_denominator     => 'c_executions',
                           p_rate_type       => 'NP') || 'OPI_MEASURE2,
              ' || opi_dbi_rpt_util_pkg.change_pct_str_basic(
                               p_new_numerator     => 'c_elapsed_time',
                               p_new_denominator   => 'c_executions',
                               p_old_numerator     => 'p_elapsed_time',
                               p_old_denominator   => 'c_executions',
                               p_measure_name      => 'OPI_MEASURE3') || ',
              ' || opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'c_executions',
                           p_default_val => 0) || ' OPI_MEASURE4,
              '  || opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'c_exec_with_exceptions',
                           p_default_val => 0) || ' OPI_MEASURE5,
              ' || opi_dbi_rpt_util_pkg.rate_str (
                           p_numerator       => 'p_exec_with_exceptions',
                           p_denominator     => 'p_executions',
                           p_rate_type       => 'P') || 'OPI_MEASURE15,
              ' || opi_dbi_rpt_util_pkg.rate_str (
                           p_numerator       => 'c_exec_with_exceptions',
                           p_denominator     => 'c_executions',
                           p_rate_type       => 'P') || 'OPI_MEASURE6,
              ' || opi_dbi_rpt_util_pkg.change_pct_str (
                           p_new_numerator   => 'c_exec_with_exceptions',
                           p_new_denominator => 'c_executions',
                           p_old_numerator   => 'p_exec_with_exceptions',
                           p_old_denominator => 'p_executions',
                           p_measure_name    => 'OPI_MEASURE7') || ',
              ' || opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'p_exceptions',
                           p_default_val => 0) || ' OPI_MEASURE16,
              ' || opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'c_exceptions',
                           p_default_val => 0) || ' OPI_MEASURE8,
              ' || opi_dbi_rpt_util_pkg.change_str (
                           p_new_numerator   => 'c_exceptions',
                           p_old_numerator   => 'p_exceptions',
                           p_denominator     => 'p_exceptions',
                           p_measure_name    => 'OPI_MEASURE9') || ',
              ' || opi_dbi_rpt_util_pkg.rate_str (
                           p_numerator       => 'c_elapsed_time_total',
                           p_denominator     => 'c_executions_total',
                           p_rate_type       => 'NP') || 'OPI_MEASURE21,
              ' || opi_dbi_rpt_util_pkg.change_pct_str_basic(
                               p_new_numerator     => 'c_elapsed_time_total',
                               p_new_denominator   => 'c_executions_total',
                               p_old_numerator     => 'p_elapsed_time_total',
                               p_old_denominator   => 'c_executions_total',
                               p_measure_name      => 'OPI_MEASURE22') || ',
              ' || opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'c_executions_total',
                           p_default_val => 0) || ' OPI_MEASURE23,
              ' || opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'c_exec_with_exceptions_total',
                           p_default_val => 0) || ' OPI_MEASURE24,
              ' || opi_dbi_rpt_util_pkg.rate_str (
                           p_numerator       => 'c_exec_with_exceptions_total',
                           p_denominator     => 'c_executions_total',
                           p_rate_type       => 'P') || 'OPI_MEASURE25,
              ' || opi_dbi_rpt_util_pkg.change_pct_str (
                           p_new_numerator   => 'c_exec_with_exceptions_total',
                           p_new_denominator => 'c_executions_total',
                           p_old_numerator   => 'p_exec_with_exceptions_total',
                           p_old_denominator => 'p_executions_total',
                           p_measure_name    => 'OPI_MEASURE26') || ',
              ' || opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'c_exceptions_total',
                           p_default_val => 0) || ' OPI_MEASURE27,
              ' || opi_dbi_rpt_util_pkg.change_str (
                           p_new_numerator   => 'c_exceptions_total',
                           p_old_numerator   => 'p_exceptions_total',
                           p_denominator     => 'p_exceptions_total',
                           p_measure_name    => 'OPI_MEASURE28');

    RETURN l_sel_clause;
END GET_OPP_SEL_CLAUSE;

-- -------------------------------------------------------------------
-- Name       : GET_OP_EX_REASON_SQL
-- Description: Generate query for Op Plan Exception by Reason Report
-- -------------------------------------------------------------------
PROCEDURE GET_OP_EX_REASON_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)

IS
    l_query                     VARCHAR2(15000);
    l_view_by                   VARCHAR2(120);
    l_view_by_col               VARCHAR2 (120);
    l_xtd                       VARCHAR2(10);
    l_comparison_type           VARCHAR2(1);
    l_cur_suffix                VARCHAR2(5);
    l_custom_sql                VARCHAR2 (10000);
    l_subinv_val                VARCHAR2 (120) := NULL;
    l_col_tbl                   poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_where_clause              VARCHAR2 (2000);
    l_mv                        VARCHAR2 (30);
    l_aggregation_level_flag    VARCHAR2(10);
    l_custom_rec                BIS_QUERY_ATTRIBUTES;
    l_mv_tbl                    poa_dbi_util_pkg.poa_dbi_mv_tbl;
    l_filter_where              VARCHAR2(120);
BEGIN
    -- initialization block
    l_comparison_type := 'Y';
    l_aggregation_level_flag := '0';

    -- clear out the column and Join info tables.
    l_col_tbl  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
    l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

    -- get all the query parameters
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
                                 p_mv_level_flag    => l_aggregation_level_flag,
                                 p_trend            => 'N',
                                 p_func_area        => 'OPI',
                                 p_version          => '7.1',
                                 p_role             => '',
                                 p_mv_set           => 'OPER',
                                 p_mv_flag_type     => 'WMS_OPER');

    -- Add measure columns that need to be aggregated
    poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                 p_col_name     => 'exceptions',
                                 p_alias_name   => 'exceptions',
                                 p_grand_total  => 'Y',
                                 p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                 p_to_date_type => 'RLX');
    --Add filtering condition to suppress rows
    l_filter_where := NULL;

    --Generate Final Query
    l_query := GET_OP_EX_REASON_SEL_CLAUSE (l_view_by, l_join_tbl)
                || ' from
              ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
                                                        p_where_clause    => l_where_clause,
                                                        p_join_tables     => l_join_tbl,
                                                        p_use_windowing   => 'Y',
                                                        p_col_name        => l_col_tbl,
                                                        p_use_grpid       => 'N',
                                                        p_paren_count     => 3,
                                                        p_filter_where    => l_filter_where,
                                                        p_generate_viewby => 'Y',
                                                        p_in_join_tables  => NULL);
    -- prepare output for bind variables
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    -- set the basic bind variables for the status SQL
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);
    poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd);

    -- Passing OPI_AGGREGATION_LEVEL_FLAGS to PMV
    l_custom_rec.attribute_name     := ':OPI_OPER_AGG_LEVEL_FLAG';
    l_custom_rec.attribute_value    := l_aggregation_level_flag;
    l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(x_custom_output.count) := l_custom_rec;

    commit;

    x_custom_sql := l_query;
END GET_OP_EX_REASON_SQL;

-- -------------------------------------------------------------------
-- Name       : GET_OP_EX_REASON_SEL_CLAUSE
-- Description: build select clause for Op Exception by Reason
-- -------------------------------------------------------------------
FUNCTION GET_OP_EX_REASON_SEL_CLAUSE(p_view_by_dim IN VARCHAR2, p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2
IS
    l_sel_clause                VARCHAR2(15000);
    l_view_by_col_name          VARCHAR2(120);
    l_view_by_fact_col          VARCHAR2(400);
BEGIN
    l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                (p_view_by_dim);
    l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                (p_join_tbl);

    -- Start generating SELECT clause for query
    l_sel_clause :=
        'SELECT
            ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
              || fnd_global.newline;

        l_sel_clause := l_sel_clause ||
            ' OPI_MEASURE1
            ,OPI_MEASURE2
            ,OPI_MEASURE3
            ,OPI_MEASURE4
            ,OPI_MEASURE5
            ,OPI_MEASURE6
         FROM
            (SELECT (rank () over
                   (&ORDER_BY_CLAUSE nulls last,
                   ' || l_view_by_fact_col || ')) - 1 rnk,
                   ' || l_view_by_fact_col || ',
              OPI_MEASURE1,
              OPI_MEASURE2,
              OPI_MEASURE3,
              OPI_MEASURE4,
              OPI_MEASURE5,
              OPI_MEASURE6'|| fnd_global.newline;

        l_sel_clause := l_sel_clause ||
        'FROM ( SELECT  '  || fnd_global.newline ||
                         l_view_by_fact_col || fnd_global.newline ||
         ',' ||  opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'c_exceptions',
                           p_default_val => 0) || ' OPI_MEASURE1,
           ' ||  opi_dbi_rpt_util_pkg.change_str (
                           p_new_numerator   => 'c_exceptions',
                           p_old_numerator   => 'p_exceptions',
                           p_denominator     => 'p_exceptions',
                           p_measure_name    => 'OPI_MEASURE2') || ',
           ' ||  opi_dbi_rpt_util_pkg.percent_str(
                           p_numerator      => 'c_exceptions',
                           p_denominator    => 'c_exceptions_total',
                           p_measure_name   => 'OPI_MEASURE3') || ',
            ' ||  opi_dbi_rpt_util_pkg.nvl_str (
                           p_str         => 'c_exceptions_total',
                           p_default_val => 0) || ' OPI_MEASURE4,
            ' ||  opi_dbi_rpt_util_pkg.change_str (
                           p_new_numerator   => 'c_exceptions_total',
                           p_old_numerator   => 'p_exceptions_total',
                           p_denominator     => 'p_exceptions_total',
                           p_measure_name    => 'OPI_MEASURE5') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str(
                           p_numerator      => 'c_exceptions_total',
                           p_denominator    => 'c_exceptions_total',
                           p_measure_name   => 'OPI_MEASURE6');
    RETURN l_sel_clause;
END GET_OP_EX_REASON_SEL_CLAUSE;

END opi_dbi_wms_rpt_pkg;

/
