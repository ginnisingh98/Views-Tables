--------------------------------------------------------
--  DDL for Package Body ISC_DBI_FR_COST_PER_V_TR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_FR_COST_PER_V_TR_PKG" AS
/*$Header: ISCRGC0B.pls 120.1 2006/06/26 06:41:59 abhdixi noship $
    /*----------------------------------------------------
        Declare PRIVATE procedures and functions for package
    -----------------------------------------------------*/

    /* Trend Report */
    FUNCTION get_trd_sel_clause(p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2;


    /*----------------------------------------
          Trend Report Function
      ----------------------------------------*/
    PROCEDURE get_trd_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                             x_custom_sql OUT NOCOPY VARCHAR2,
                             x_custom_output OUT NOCOPY
                             BIS_QUERY_ATTRIBUTES_TBL)
    IS
        l_query                     VARCHAR2(32767);
        l_view_by                   VARCHAR2(120);
        l_view_by_col               VARCHAR2 (120);
        l_xtd                       VARCHAR2(10);
        l_comparison_type           VARCHAR2(1);
        l_cur_suffix                VARCHAR2(10);
        l_currency                  VARCHAR2(10);
        l_custom_sql                VARCHAR2 (10000);

        l_col_tbl                   poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_in_join_tbl               poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;

        l_where_clause              VARCHAR2 (2000);
        l_mv                        VARCHAR2 (30);

        l_aggregation_level_flag    VARCHAR2(10);

        l_custom_rec                BIS_QUERY_ATTRIBUTES;

    BEGIN

        -- initialization block
        l_comparison_type := 'Y';
        l_aggregation_level_flag := '0';

        -- clear out the tables.
        l_col_tbl  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
        x_custom_sql := l_query;

        -- get all the query parameters
        isc_dbi_sutil_pkg.process_parameters (
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
                                             p_func_area        => 'ISC',
                                             p_version          => '7.1',
                                             p_role             => '',
                                             p_mv_set           => 'C01',
                                             p_mv_flag_type     => 'FLAG1',
                                             p_in_join_tbl      =>  l_in_join_tbl);

        --Convert the currency suffix to conform to ISC standards
          IF (l_cur_suffix = 'g')
            THEN l_currency := 'g';
          ELSIF (l_cur_suffix = 'sg')
            THEN l_currency := 'g1';
            ELSE l_currency := 'f';
          END IF;

        -- Add measure columns that need to be aggregated
        -- No Grand totals required.
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'freight_cost_vol_'||l_currency,
                                     p_alias_name   => 'freight_cost',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'freight_volume_g',
                                     p_alias_name   => 'freight_volume',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        -- Merge Outer and Inner Query
        l_query := get_trd_sel_clause(l_view_by) ||
                   ' from ' ||
                   poa_dbi_template_pkg.trend_sql (
                        p_xtd               => l_xtd,
                        p_comparison_type   => l_comparison_type,
                        p_fact_name         => l_mv,
                        p_where_clause      => l_where_clause,
                        p_col_name          => l_col_tbl,
                        p_use_grpid         => 'N');


        -- Prepare PMV bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- get all the basic binds used by POA queries
        -- Do this before adding any of our binds, since the procedure
        -- reinitializes the output table
        poa_dbi_util_pkg.get_custom_trend_binds (
                        p_xtd   => l_xtd,
                        p_comparison_type   => l_comparison_type,
                        x_custom_output     => x_custom_output);

        -- Passing ISC_AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':ISC_AGG_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        x_custom_sql := l_query;

    END get_trd_sql;

    /*--------------------------------------------------
     Function:      get_trd_sel_clause
     Description:   builds the outer select clause
    ---------------------------------------------------*/

    FUNCTION get_trd_sel_clause (p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_sel_clause varchar2(7500);
    BEGIN

        -- Main Outer query

        l_sel_clause :=
        'SELECT
            ' || ' cal.name VIEWBY,
	           nvl(p_freight_cost,0)		ISC_MEASURE_9,
                   nvl(c_freight_cost,0) 		ISC_MEASURE_1,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_freight_cost',
                    p_old_numerator     => 'p_freight_cost',
                    p_denominator       => 'p_freight_cost',
                    p_measure_name      => 'ISC_MEASURE_2') || ', -- Rated Fr Cost Change
	           nvl(p_freight_volume,0) 		ISC_MEASURE_10,
	           nvl(c_freight_volume,0) 		ISC_MEASURE_4,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_freight_volume',
                    p_old_numerator     => 'p_freight_volume',
                    p_denominator       => 'p_freight_volume',
                    p_measure_name      => 'ISC_MEASURE_5') || ', -- Rated Fr Volume Change
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'p_freight_cost',
                    p_denominator   => 'p_freight_volume',
                    p_rate_type     => 'RATIO',
                    p_measure_name  => 'ISC_MEASURE_11') || ', -- Fr Cost per Volume Prior
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'c_freight_cost',
                    p_denominator   => 'c_freight_volume',
                    p_rate_type     => 'RATIO',
                    p_measure_name  => 'ISC_MEASURE_7') || ', -- Fr Cost per Volume
            ' || isc_dbi_sutil_pkg.change_rate_str (
                    p_new_numerator     => 'c_freight_cost',
                    p_new_denominator   => 'c_freight_volume',
                    p_old_numerator     => 'p_freight_cost',
                    p_old_denominator   => 'p_freight_volume',
                    p_rate_type         => 'RATIO',
                    p_measure_name      => 'ISC_MEASURE_8'); -- Fr Cost per Volume Change

      RETURN l_sel_clause;

    END get_trd_sel_clause;

END ISC_DBI_FR_COST_PER_V_TR_PKG;

/
