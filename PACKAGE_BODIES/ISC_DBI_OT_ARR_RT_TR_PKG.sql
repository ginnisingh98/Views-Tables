--------------------------------------------------------
--  DDL for Package Body ISC_DBI_OT_ARR_RT_TR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_OT_ARR_RT_TR_PKG" AS
/*$Header: ISCRGBXB.pls 120.1 2006/06/26 06:45:27 abhdixi noship $
    /*----------------------------------------------------
        Declare PRIVATE procedures and functions for package
    -----------------------------------------------------*/
    /* On-Time Arrival Rate Trend */
    FUNCTION get_trd_sel_clause(p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2;


    /*------------------------------------------------
          On-Time Arrival Rate Trend Function
    -------------------------------------------------*/
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
                                             p_mv_set           => 'BX1',
                                             p_mv_flag_type     => 'FLAG2',
                                             p_in_join_tbl      =>  l_in_join_tbl);

        -- Add measure columns that need to be aggregated
        -- No Grand totals required.
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'trip_arrivals',
                                     p_alias_name   => 'trip_arrivals',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'stop_arrivals',
                                     p_alias_name   => 'stop_arrivals',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'on_time_stop_arrivals',
                                     p_alias_name   => 'ot_arrivals',
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
                   nvl(c_trip_arrivals,0) 		ISC_MEASURE_1,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_trip_arrivals',
                    p_old_numerator     => 'p_trip_arrivals',
                    p_denominator       => 'p_trip_arrivals',
                    p_measure_name      => 'ISC_MEASURE_2') || ', -- Trip Arrivals Change
                   nvl(p_stop_arrivals,0) 		ISC_MEASURE_3,
                   nvl(c_stop_arrivals,0) 		ISC_MEASURE_4,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_stop_arrivals',
                    p_old_numerator     => 'p_stop_arrivals',
                    p_denominator       => 'p_stop_arrivals',
                    p_measure_name      => 'ISC_MEASURE_5') || ', -- Trip Stop Arrivals Change
                   nvl(p_ot_arrivals,0) 		ISC_MEASURE_8,
                   nvl(c_ot_arrivals,0)	 	ISC_MEASURE_6,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_trip_arrivals',
                    p_old_numerator     => 'p_trip_arrivals',
                    p_denominator       => 'p_trip_arrivals',
                    p_measure_name      => 'ISC_MEASURE_7') || ', -- On-Time Trip Stop Arrivals Change
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'p_ot_arrivals',
                    p_denominator   => 'p_stop_arrivals',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_9') || ', -- OT Arrival Rate Prior
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'c_ot_arrivals',
                    p_denominator   => 'c_stop_arrivals',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_10') || ', -- OT Arrival Rate
            ' || isc_dbi_sutil_pkg.change_rate_str (
                    p_new_numerator     => 'c_ot_arrivals',
                    p_new_denominator   => 'c_stop_arrivals',
                    p_old_numerator     => 'p_ot_arrivals',
                    p_old_denominator   => 'p_stop_arrivals',
                    p_rate_type         => 'PERCENT',
                    p_measure_name      => 'ISC_MEASURE_11'); -- OT Arrival Rate Change

      RETURN l_sel_clause;

    END get_trd_sel_clause;

END ISC_DBI_OT_ARR_RT_TR_PKG;

/
