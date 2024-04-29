--------------------------------------------------------
--  DDL for Package Body ISC_DBI_WMS_PTS_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_WMS_PTS_TREND_PKG" AS
/*$Header: ISCRGBSB.pls 120.0 2005/05/25 17:16:54 appldev noship $
    /*----------------------------------------------------
        Declare PRIVATE procedures and functions for package
    -----------------------------------------------------*/

    /* No subinventory dimension  --> need all measures
       from isc_wms_000_mv and isc_wms_001_mv */
    FUNCTION get_sel_clause1(p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2;

    /* Subinventory dimension --> don't need to retrieve pick release measures,
       only measures from isc_wms_001_mv */
    FUNCTION get_sel_clause2(p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2;

    /*------------------------------------------------------
       Trend Query for Pick Release To Ship Cycle Time Trend
      -----------------------------------------------------*/
    PROCEDURE get_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                             x_custom_sql OUT NOCOPY VARCHAR2,
                             x_custom_output OUT NOCOPY
                             BIS_QUERY_ATTRIBUTES_TBL)
    IS
        l_query                     VARCHAR2(32767);
        l_view_by                   VARCHAR2(120);
        l_view_by_col               VARCHAR2(120);
        l_xtd                       VARCHAR2(10);
        l_comparison_type           VARCHAR2(1);
        l_cur_suffix                VARCHAR2(10);
        l_custom_sql                VARCHAR2(10000);

	l_mv_tbl                    poa_dbi_util_pkg.POA_DBI_MV_TBL;
        l_col_tbl1                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_col_tbl2                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_in_join_tbl 		    poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
        l_where_clause1             VARCHAR2 (2000);
        l_where_clause2             VARCHAR2 (2000);
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
        l_mv_tbl := poa_dbi_util_pkg.POA_DBI_MV_TBL ();
        l_col_tbl1  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_col_tbl2  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters

        isc_dbi_sutil_pkg.process_parameters (
                                             p_param            => p_param,
                                             p_view_by          => l_view_by,
                                             p_view_by_col_name => l_view_by_col,
                                             p_comparison_type  => l_comparison_type,
                                             p_xtd              => l_xtd,
                                             p_cur_suffix       => l_cur_suffix,
                                             p_where_clause     => l_where_clause2,
                                             p_mv               => l_mv2,
                                             p_join_tbl         => l_join_tbl,
                                             p_mv_level_flag    => l_aggregation_level_flag2,
                                             p_trend            => 'Y',
                                             p_func_area        => 'ISC',
                                             p_version          => '7.1',
                                             p_role             => '',
                                             p_mv_set           => 'RS2',
                                             p_mv_flag_type     => 'FLAG4',
                                             p_in_join_tbl      =>  l_in_join_tbl);

        -- Add measure columns that need to be aggregated
        -- No Grand totals required.
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2,
                                     p_col_name     => 'ship_confirm_cnt',
                                     p_alias_name   => 'ship_confirm_cnt',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2,
                                     p_col_name     => 'release_to_ship',
                                     p_alias_name   => 'release_to_ship',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');

IF (l_where_clause2 NOT LIKE '%fact.subinventory%') THEN
        isc_dbi_sutil_pkg.process_parameters (
                                             p_param            => p_param,
                                             p_view_by          => l_view_by,
                                             p_view_by_col_name => l_view_by_col,
                                             p_comparison_type  => l_comparison_type,
                                             p_xtd              => l_xtd,
                                             p_cur_suffix       => l_cur_suffix,
                                             p_where_clause     => l_where_clause1,
                                             p_mv               => l_mv1,
                                             p_join_tbl         => l_join_tbl,
                                             p_mv_level_flag    => l_aggregation_level_flag1,
                                             p_trend            => 'Y',
                                             p_func_area        => 'ISC',
                                             p_version          => '7.1',
                                             p_role             => '',
                                             p_mv_set           => 'RS1',
                                             p_mv_flag_type     => 'FLAG5',
                                             p_in_join_tbl      =>  l_in_join_tbl);

        -- Add measure columns that need to be aggregated
        -- No Grand totals required.
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'pick_release_cnt',
                                     p_alias_name   => 'pick_release_cnt',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');
END IF;

        -- Merge Outer and Inner Query
IF (l_where_clause2 NOT LIKE '%fact.subinventory%') THEN

	l_mv_tbl.extend;
	l_mv_tbl(1).mv_name := l_mv1;
	l_mv_tbl(1).mv_col := l_col_tbl1;
	l_mv_tbl(1).mv_where := l_where_clause1;
	l_mv_tbl(1).in_join_tbls := NULL;
	l_mv_tbl(1).use_grp_id := 'N';
	l_mv_tbl(1).mv_xtd := l_xtd;

	l_mv_tbl.extend;
	l_mv_tbl(2).mv_name := l_mv2;
	l_mv_tbl(2).mv_col := l_col_tbl2;
	l_mv_tbl(2).mv_where := l_where_clause2;
	l_mv_tbl(2).in_join_tbls := NULL;
	l_mv_tbl(2).use_grp_id := 'N';
	l_mv_tbl(2).mv_xtd := l_xtd;

        l_query := get_sel_clause1(l_view_by) ||
                   ' from ' ||
                   poa_dbi_template_pkg.union_all_trend_sql (
                        p_mv                 => l_mv_tbl,
                        p_comparison_type    => l_comparison_type,
			p_filter_where       => NULL);

ELSE
        l_query := get_sel_clause2(l_view_by) ||
                   ' from ' ||
                   poa_dbi_template_pkg.trend_sql (
                        p_xtd               => l_xtd,
                        p_comparison_type   => l_comparison_type,
                        p_fact_name         => l_mv2,
                        p_where_clause      => l_where_clause2,
                        p_col_name          => l_col_tbl2,
                        p_use_grpid         => 'N');

END IF;


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

    	poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd);

        -- Passing ISC_AGG_FLAGS to PMV

IF (l_where_clause2 NOT LIKE '%fact.subinventory%') THEN
        l_custom_rec.attribute_name     := ':ISC_AGG_FLAG2';
        l_custom_rec.attribute_value    := l_aggregation_level_flag1;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;
END IF;

        l_custom_rec.attribute_name     := ':ISC_AGG_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag2;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        x_custom_sql := l_query;

    END get_sql;

    /*--------------------------------------------------
     Function:      get_sel_clause1
     Description:   builds the outer select clause
    ---------------------------------------------------*/

    FUNCTION get_sel_clause1 (p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_sel_clause varchar2(7500);
    BEGIN

        -- Main Outer query

        l_sel_clause :=
   'SELECT
            cal_name			VIEWBY,
            p_pick_release_cnt 		ISC_MEASURE_1,
            c_pick_release_cnt		ISC_MEASURE_2,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_pick_release_cnt',
                    p_old_numerator     => 'p_pick_release_cnt',
                    p_denominator       => 'p_pick_release_cnt',
                    p_measure_name      => 'ISC_MEASURE_3') || ',
            p_ship_confirm_cnt 		ISC_MEASURE_4,
            c_ship_confirm_cnt 		ISC_MEASURE_5,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_ship_confirm_cnt',
                    p_old_numerator     => 'p_ship_confirm_cnt',
                    p_denominator       => 'p_ship_confirm_cnt',
                    p_measure_name      => 'ISC_MEASURE_6') || ',
            CASE WHEN p_ship_confirm_cnt = 0 THEN to_number (NULL)
                 ELSE (p_release_to_ship*24/p_ship_confirm_cnt)
                 END			ISC_MEASURE_7,
            CASE WHEN c_ship_confirm_cnt = 0 THEN to_number (NULL)
                 ELSE (c_release_to_ship*24/c_ship_confirm_cnt)
                 END			ISC_MEASURE_8,
            CASE WHEN c_ship_confirm_cnt = 0 THEN to_number(NULL)
                 WHEN p_ship_confirm_cnt = 0 THEN to_number(NULL)
	         ELSE ((c_release_to_ship*24/c_ship_confirm_cnt
                         - p_release_to_ship*24/p_ship_confirm_cnt))
                 END			ISC_MEASURE_9
';

      RETURN l_sel_clause;

    END get_sel_clause1;


    /*--------------------------------------------------
     Function:      get_sel_clause2
     Description:   builds the outer select clause
    ---------------------------------------------------*/

    FUNCTION get_sel_clause2 (p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_sel_clause varchar2(7500);
    BEGIN

        -- Main Outer query

        l_sel_clause :=
   'SELECT
            cal.name			VIEWBY,
            NULL	 		ISC_MEASURE_1,
            NULL			ISC_MEASURE_2,
            NULL			ISC_MEASURE_3,
            p_ship_confirm_cnt 		ISC_MEASURE_4,
            c_ship_confirm_cnt 		ISC_MEASURE_5,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_ship_confirm_cnt',
                    p_old_numerator     => 'p_ship_confirm_cnt',
                    p_denominator       => 'p_ship_confirm_cnt',
                    p_measure_name      => 'ISC_MEASURE_6') || ',
            CASE WHEN p_ship_confirm_cnt = 0 THEN to_number (NULL)
                 ELSE (p_release_to_ship*24/p_ship_confirm_cnt)
                 END			ISC_MEASURE_7,
            CASE WHEN c_ship_confirm_cnt = 0 THEN to_number (NULL)
                 ELSE (c_release_to_ship*24/c_ship_confirm_cnt)
                 END			ISC_MEASURE_8,
            CASE WHEN c_ship_confirm_cnt = 0 THEN to_number(NULL)
                 WHEN p_ship_confirm_cnt = 0 THEN to_number(NULL)
	         ELSE ((c_release_to_ship*24/c_ship_confirm_cnt
                         - p_release_to_ship*24/p_ship_confirm_cnt))
                 END			ISC_MEASURE_9
';

      RETURN l_sel_clause;

    END get_sel_clause2;

END ISC_DBI_WMS_PTS_TREND_PKG;

/
