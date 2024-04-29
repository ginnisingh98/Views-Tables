--------------------------------------------------------
--  DDL for Package Body ISC_DBI_TS_ARR_PERF_TR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_TS_ARR_PERF_TR_PKG" AS
/*$Header: ISCRGBPB.pls 120.1 2006/06/26 06:47:49 abhdixi noship $
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
        l_xtd1                      VARCHAR2(10);
        l_xtd2                      VARCHAR2(10);
        l_comparison_type           VARCHAR2(1);
        l_cur_suffix                VARCHAR2(10);
        l_currency                  VARCHAR2(10);
        l_custom_sql                VARCHAR2 (10000);

        l_col_tbl1                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_col_tbl2                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_in_join_tbl               poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;

	l_mv_tbl  		    poa_dbi_util_pkg.poa_dbi_mv_tbl;

        l_where_clause              VARCHAR2 (2000);
        l_mv1                       VARCHAR2 (30);
        l_mv2                       VARCHAR2 (30);

        l_aggregation_level_flag1    VARCHAR2(10);
        l_aggregation_level_flag2    VARCHAR2(10);

        l_custom_rec                BIS_QUERY_ATTRIBUTES;

    BEGIN

        -- initialization block
        l_comparison_type := 'Y';
        l_aggregation_level_flag1 := '0';
        l_aggregation_level_flag2 := '0';

        -- clear out the tables.
        l_col_tbl1  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_col_tbl2  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();
        x_custom_sql := l_query;

        -- get all the query parameters
        isc_dbi_sutil_pkg.process_parameters (
                                             p_param            => p_param,
                                             p_view_by          => l_view_by,
                                             p_view_by_col_name => l_view_by_col,
                                             p_comparison_type  => l_comparison_type,
                                             p_xtd              => l_xtd1,
                                             p_cur_suffix       => l_cur_suffix,
                                             p_where_clause     => l_where_clause,
                                             p_mv               => l_mv1,
                                             p_join_tbl         => l_join_tbl,
                                             p_mv_level_flag    => l_aggregation_level_flag1,
                                             p_trend            => 'Y',
                                             p_func_area        => 'ISC',
                                             p_version          => '7.1',
                                             p_role             => '',
                                             p_mv_set           => 'BP1',
                                             p_mv_flag_type     => 'FLAG2',
                                             p_in_join_tbl      =>  l_in_join_tbl);

        -- Add measure columns that need to be aggregated
        -- No Grand totals required.

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'stop_arrivals',
                                     p_alias_name   => 'stop_arrivals',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'early_stop_arrivals',
                                     p_alias_name   => 'early_arrivals',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'late_stop_arrivals',
                                     p_alias_name   => 'late_arrivals',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'on_time_stop_arrivals',
                                     p_alias_name   => 'ot_arrivals',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                     p_to_date_type => 'XTD');

        isc_dbi_sutil_pkg.process_parameters (
                                             p_param            => p_param,
                                             p_view_by          => l_view_by,
                                             p_view_by_col_name => l_view_by_col,
                                             p_comparison_type  => l_comparison_type,
                                             p_xtd              => l_xtd2,
                                             p_cur_suffix       => l_cur_suffix,
                                             p_where_clause     => l_where_clause,
                                             p_mv               => l_mv2,
                                             p_join_tbl         => l_join_tbl,
                                             p_mv_level_flag    => l_aggregation_level_flag2,
                                             p_trend            => 'Y',
                                             p_func_area        => 'ISC',
                                             p_version          => '7.1',
                                             p_role             => '',
                                             p_mv_set           => 'BP2',
                                             p_mv_flag_type     => 'FLAG2',
                                             p_in_join_tbl      =>  l_in_join_tbl);

        -- Add measure columns that need to be aggregated
        -- No Grand totals required.
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2,
                                     p_col_name     => 'planned_stop_arrivals',
                                     p_alias_name   => 'plan_arrivals',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                     p_to_date_type => 'XTD');


  	l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

   	l_mv_tbl.extend;
    	l_mv_tbl(1).mv_name := l_mv1;
    	l_mv_tbl(1).mv_col := l_col_tbl1;
    	l_mv_tbl(1).mv_where := l_where_clause;
    	l_mv_tbl(1).in_join_tbls := NULL;
    	l_mv_tbl(1).use_grp_id := 'N';
	l_mv_tbl(1).mv_xtd := l_xtd1;

    	l_mv_tbl.extend;
    	l_mv_tbl(2).mv_name := l_mv2;
    	l_mv_tbl(2).mv_col := l_col_tbl2;
    	l_mv_tbl(2).mv_where := l_where_clause;
    	l_mv_tbl(2).in_join_tbls := NULL;
    	l_mv_tbl(2).use_grp_id := 'N';
	l_mv_tbl(2).mv_xtd := l_xtd2;

        -- Merge Outer and Inner Query
        l_query := get_trd_sel_clause(l_view_by) ||
                   ' from ' ||
                   poa_dbi_template_pkg.union_all_trend_sql (
			p_mv		    => l_mv_tbl,
			p_comparison_type   => l_comparison_type,

			p_filter_where	    => NULL
);


        -- Prepare PMV bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- get all the basic binds used by POA queries
        -- Do this before adding any of our binds, since the procedure
        -- reinitializes the output table
        poa_dbi_util_pkg.get_custom_trend_binds (
                        p_xtd   => l_xtd2,
                        p_comparison_type   => l_comparison_type,
                        x_custom_output     => x_custom_output);

        -- Passing ISC_AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':ISC_AGG_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag1;
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
            ' || ' cal_name VIEWBY,
                   nvl(c_ot_arrivals,0) 		ISC_MEASURE_1,
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'c_ot_arrivals',
                    p_denominator   => 'c_stop_arrivals',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_2') || ', -- OT Arrival Rate
                   nvl(c_late_arrivals,0) 		ISC_MEASURE_3,
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'c_late_arrivals',
                    p_denominator   => 'c_stop_arrivals',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_4') || ', -- Late Arrival Rate
                   nvl(c_early_arrivals,0) 		ISC_MEASURE_5,
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'c_early_arrivals',
                    p_denominator   => 'c_stop_arrivals',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_6') || ', -- Early Arrival Rate
                   nvl(c_stop_arrivals,0) 		ISC_MEASURE_7,
                   nvl(c_plan_arrivals,0) 		ISC_MEASURE_8,
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'c_stop_arrivals',
                    p_denominator   => 'c_plan_arrivals',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_9'); -- Trip Stop Arrivals to Plan

      RETURN l_sel_clause;

    END get_trd_sel_clause;

END ISC_DBI_TS_ARR_PERF_TR_PKG;

/
