--------------------------------------------------------
--  DDL for Package Body OPI_DBI_CC_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_CC_RPT_PKG" AS
/*$Header: OPIDRICCAB.pls 120.0 2005/05/24 18:18:25 appldev noship $ */
    /*----------------------------------------------------
        Declare PRIVATE procedures and functions for package
    -----------------------------------------------------*/
    /* Get Item Description when view by is item */
    PROCEDURE get_cc_item_columns ( p_dim_name IN VARCHAR2,
                                    p_description OUT NOCOPY VARCHAR2,
                                    p_col_type IN VARCHAR2 := 'ITEM');

    /* Cycle Count Accuracy Report */
    FUNCTION get_cc_rpt_sel_clause (p_view_by_dim IN VARCHAR2,
                                    p_join_tbl IN
                                    poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2;


    /* Cycle Count Accuracy Trend Report */
    FUNCTION get_cc_trd_sel_clause(p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2;

    /* Hit/Miss Summary */
    FUNCTION get_hitmiss_sel_clause (p_view_by_dim IN VARCHAR2,
                                     p_join_tbl IN
                                     poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2;

    /* Cycle Count Adjustment Summary Report */
    FUNCTION get_adj_rpt_sel_clause (p_view_by_dim IN VARCHAR2,
                                     p_join_tbl IN
                                     poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2;

    /* Cycle Count Adjustment Detail Report */
    FUNCTION get_adj_dtl_sel_clause (p_view_by_dim IN VARCHAR2,
                                     p_join_tbl IN
                                     poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2;

    /*----------------------------------------
    Cycle Count Accuracy Report Function
    ----------------------------------------*/
    PROCEDURE get_tbl_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
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

        l_where_clause              VARCHAR2 (2000);
        l_mv                        VARCHAR2 (30);

        l_aggregation_level_flag    VARCHAR2(10);

        l_custom_rec                BIS_QUERY_ATTRIBUTES;

    BEGIN

        -- initialization block
        l_comparison_type := 'Y';
        l_aggregation_level_flag := '0';

        -- clear out the column and Join info tables.
        l_col_tbl  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

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
                                         p_version          => '7.0',
                                         p_role             => '',
                                         p_mv_set           => 'CCAC',
                                         p_mv_flag_type     => 'CCA_LEVEL');

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_hits' ,
                                     p_alias_name   => 'hits',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_exact_matches' ,
                                     p_alias_name   => 'exact_matches',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_total_entries',
                                     p_alias_name   => 'tot_entries',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'system_inventory_val_' || l_cur_suffix,
                                     p_alias_name   => 'system_val',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'gross_adjustment_val_' || l_cur_suffix,
                                     p_alias_name   => 'gross_adj_val',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        -- construct the query
        l_query := get_cc_rpt_sel_clause (l_view_by, l_join_tbl)
              || ' from
            ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
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

        -- Passing OPI_AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':OPI_CCA_LEVEL_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;


        x_custom_sql := l_query;

    END get_tbl_sql;


    /*--------------------------------------------------
     Function:      get_cc_rtp_sel_clause
     Description:   builds the outer select clause for
                    Cycle Count Accuracy Report
    ---------------------------------------------------*/
    FUNCTION get_cc_rpt_sel_clause(p_view_by_dim IN VARCHAR2,
                                   p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2
    IS

        l_sel_clause                VARCHAR2(15000);
        l_view_by_col_name          VARCHAR2(60);
        l_description               VARCHAR2(30);
        l_drill_across_rep_1        VARCHAR2(50);
        l_drill_across_rep_2        VARCHAR2(50);
        l_view_by_fact_col VARCHAR2(400);
        l_drill_across VARCHAR2(1000);

    BEGIN

        -- initialization block
        l_drill_across_rep_1 := 'OPI_DBI_CC_HM_TBL_REP' ;
        l_drill_across_rep_2 := 'OPI_DBI_CC_ADJ_TBL_REP' ;

        -- Column to get view by column name
        l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                    (p_view_by_dim);

        -- Item Description for item view by
        get_cc_item_columns (p_view_by_dim, l_description);

        -- fact column view by's
        l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                    (p_join_tbl);

        l_drill_across :=  '
            ''pFunctionName='||l_drill_across_rep_1||'&VIEW_BY_NAME=VIEW_BY_VALUE&VIEW_BY=' || p_view_by_dim || ''' OPI_DYNAMIC_URL_1,
            ''pFunctionName='||l_drill_across_rep_2||'&VIEW_BY_NAME=VIEW_BY_VALUE&VIEW_BY=' || p_view_by_dim || ''' OPI_DYNAMIC_URL_2,
            ''pFunctionName='||l_drill_across_rep_1||'&VIEW_BY_NAME=VIEW_BY_VALUE&VIEW_BY=' || p_view_by_dim || ''' OPI_DYNAMIC_URL_3';

        -- Outer select clause
        l_sel_clause :=
        'SELECT
        ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
          || l_view_by_col_name || ' OPI_ATTRIBUTE1,
        ' || l_description || ' OPI_ATTRIBUTE2,
        ' || 'oset.OPI_MEASURE1,
        ' || 'oset.OPI_MEASURE3,
        ' || 'oset.OPI_MEASURE4,
        ' || 'oset.OPI_MEASURE5,
        ' || 'oset.OPI_MEASURE7,
        ' || 'oset.OPI_MEASURE8,
        ' || 'oset.OPI_MEASURE9,
        ' || 'oset.OPI_MEASURE10,
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
        ' || 'oset.OPI_MEASURE24,
        ' || 'oset.OPI_MEASURE25,
        ' || 'oset.OPI_MEASURE26,
        ' || 'oset.OPI_MEASURE27,
        ' || 'oset.OPI_MEASURE28,
        ' || 'oset.OPI_MEASURE29,
        ' || 'oset.OPI_MEASURE30,
        ' || 'oset.OPI_MEASURE31,
        ' || 'oset.OPI_MEASURE32,
        ' || 'oset.OPI_MEASURE33,
        ' || 'oset.OPI_MEASURE34,
        ' || l_drill_across || '
        ' || 'FROM
        ' || '(SELECT (rank () over
        ' || ' (&ORDER_BY_CLAUSE nulls last,
        ' || l_view_by_fact_col || ')) - 1 rnk,
        ' || l_view_by_fact_col || ',
        ' || 'OPI_MEASURE1,
        ' || 'OPI_MEASURE3,
        ' || 'OPI_MEASURE4,
        ' || 'OPI_MEASURE5,
        ' || 'OPI_MEASURE7,
        ' || 'OPI_MEASURE8,
        ' || 'OPI_MEASURE9,
        ' || 'OPI_MEASURE10,
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
        ' || 'OPI_MEASURE24,
        ' || 'OPI_MEASURE25,
        ' || 'OPI_MEASURE26,
        ' || 'OPI_MEASURE27,
        ' || 'OPI_MEASURE28,
        ' || 'OPI_MEASURE29,
        ' || 'OPI_MEASURE30,
        ' || 'OPI_MEASURE31,
        ' || 'OPI_MEASURE32,
        ' || 'OPI_MEASURE33,
        ' || 'OPI_MEASURE34
        ' || 'FROM
        ' || '(SELECT
            ' || l_view_by_fact_col || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_tot_entries',
                    p_default_val   => 0)
                    || ' OPI_MEASURE1,
            ' || opi_dbi_rpt_util_pkg.percent_str(
                    p_numerator     => 'p_hits',
                    p_denominator   => 'p_tot_entries',
                    p_measure_name  => 'OPI_MEASURE3') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     => 'c_hits',
                    p_denominator   => 'c_tot_entries',
                    p_measure_name  => 'OPI_MEASURE4') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'c_hits',
                    p_new_denominator   => 'c_tot_entries',
                    p_old_numerator     => 'p_hits',
                    p_old_denominator   => 'p_tot_entries',
                    p_measure_name      => 'OPI_MEASURE5') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_gross_adj_val',
                    p_default_val   => 0)
                    || ' OPI_MEASURE7,
            ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                    p_numerator     => 'p_gross_adj_val',
                    p_denominator   => 'p_system_val',
                    p_measure_name  => 'OPI_MEASURE8') || ',
            ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                    p_numerator     => 'c_gross_adj_val',
                    p_denominator   => 'c_system_val',
                    p_measure_name  => 'OPI_MEASURE9') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'c_gross_adj_val',
                    p_new_denominator   => 'c_system_val',
                    p_old_numerator     => 'p_gross_adj_val',
                    p_old_denominator   => 'p_system_val',
                    p_measure_name      => 'OPI_MEASURE10') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     => 'p_exact_matches',
                    p_denominator   => 'p_tot_entries',
                    p_measure_name  => 'OPI_MEASURE12') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     => 'c_exact_matches',
                    p_denominator   => 'c_tot_entries',
                    p_measure_name  => 'OPI_MEASURE13') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'c_exact_matches',
                    p_new_denominator   => 'c_tot_entries',
                    p_old_numerator     => 'p_exact_matches',
                    p_old_denominator   => 'p_tot_entries',
                    p_measure_name      => 'OPI_MEASURE14') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str  => 'c_tot_entries_total',
                    p_default_val   => 0)
                    || ' OPI_MEASURE15,
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'c_hits_total',
                    p_denominator   =>'c_tot_entries_total',
                    p_measure_name  => 'OPI_MEASURE16') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'c_hits_total',
                    p_new_denominator   => 'c_tot_entries_total',
                    p_old_numerator     => 'p_hits_total',
                    p_old_denominator   => 'p_tot_entries_total',
                    p_measure_name      => 'OPI_MEASURE17') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str => 'c_gross_adj_val_total',
                    p_default_val   => 0)
                    || ' OPI_MEASURE18,
            ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                    p_numerator     =>'c_gross_adj_val_total',
                    p_denominator   =>'c_system_val_total',
                    p_measure_name  => 'OPI_MEASURE19') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'c_gross_adj_val_total',
                    p_new_denominator   => 'c_system_val_total',
                    p_old_numerator     => 'p_gross_adj_val_total',
                    p_old_denominator   => 'p_system_val_total',
                    p_measure_name      => 'OPI_MEASURE20') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator =>'c_exact_matches_total',
                    p_denominator   => 'c_tot_entries_total',
                    p_measure_name  => 'OPI_MEASURE21') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str(
                    p_new_numerator     => 'c_exact_matches_total',
                    p_new_denominator   => 'c_tot_entries_total',
                    p_old_numerator     => 'p_exact_matches_total',
                    p_old_denominator   => 'p_tot_entries_total',
                    p_measure_name      => 'OPI_MEASURE22') ||',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'c_hits',
                    p_denominator   => 'c_tot_entries',
                    p_measure_name  => 'OPI_MEASURE23') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'p_hits',
                    p_denominator   => 'p_tot_entries',
                    p_measure_name  => 'OPI_MEASURE24') || ',
            ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                    p_numerator     =>'c_gross_adj_val',
                    p_denominator   => 'c_system_val',
                    p_measure_name  => 'OPI_MEASURE25') || ',
            ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                    p_numerator     =>'p_gross_adj_val',
                    p_denominator   => 'p_system_val',
                    p_measure_name  => 'OPI_MEASURE26') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'c_exact_matches',
                    p_denominator   => 'c_tot_entries',
                    p_measure_name  => 'OPI_MEASURE27') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'p_exact_matches',
                    p_denominator   => 'p_tot_entries',
                    p_measure_name  => 'OPI_MEASURE28') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'c_hits_total',
                    p_denominator   => 'c_tot_entries_total',
                    p_measure_name  => 'OPI_MEASURE29') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'p_hits_total',
                    p_denominator   => 'p_tot_entries_total',
                    p_measure_name  => 'OPI_MEASURE30') || ',
            ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                    p_numerator     =>'c_gross_adj_val_total',
                    p_denominator   => 'c_system_val_total',
                    p_measure_name  => 'OPI_MEASURE31') || ',
            ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                    p_numerator     =>'p_gross_adj_val_total',
                    p_denominator   => 'p_system_val_total',
                    p_measure_name  => 'OPI_MEASURE32') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'c_exact_matches_total',
                    p_denominator   => 'c_tot_entries_total',
                    p_measure_name  => 'OPI_MEASURE33') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'p_exact_matches_total',
                    p_denominator   => 'p_tot_entries_total',
                    p_measure_name  => 'OPI_MEASURE34') ;


      RETURN l_sel_clause;

    END get_cc_rpt_sel_clause;


    /*-----------------------------------------------------------------------------------
      Function:     get_cc_item_columns
      Description:  When view by is item this function adds
                    column for item description to outer select
     ------------------------------------------------------------------------------------*/
    PROCEDURE get_cc_item_columns ( p_dim_name VARCHAR2,
                                    p_description OUT NOCOPY VARCHAR2,
                                    p_col_type IN VARCHAR2 := 'ITEM')
    IS
       l_view    VARCHAR2(3);

    BEGIN
          CASE
          WHEN p_col_type = 'ITEM' THEN
                  BEGIN
                      l_view := 'v';
                  END;
          WHEN p_col_type = 'UOM' THEN
                  BEGIN
                      l_view := 'v2';
                  END;
          END CASE;

          CASE
          WHEN p_dim_name = 'ITEM+ENI_ITEM_ORG' THEN
                  BEGIN
                      p_description := l_view || '.' ||'description';
                  END;
              ELSE
                  BEGIN
                      p_description := 'NULL';
                  END;
          END CASE;
    END get_cc_item_columns;



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
        l_cur_suffix                VARCHAR2(5);
        l_custom_sql                VARCHAR2 (10000);

        l_col_tbl                   poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

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
                                             p_mv_level_flag    =>l_aggregation_level_flag,
                                             p_trend            => 'Y',
                                             p_func_area        => 'OPI',
                                             p_version          => '7.0',
                                             p_role             => '',
                                             p_mv_set           => 'CCAC',
                                             p_mv_flag_type     => 'CCA_LEVEL');
        -- Add measure columns that need to be aggregated
        -- No Grand totals required.
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_hits' ,
                                     p_alias_name   => 'hits',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_exact_matches' ,
                                     p_alias_name   => 'exact_matches',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_total_entries',
                                     p_alias_name   => 'tot_entries',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'system_inventory_val_' || l_cur_suffix,
                                     p_alias_name   => 'system_val',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'gross_adjustment_val_' || l_cur_suffix,
                                     p_alias_name   => 'gross_adj_val',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        -- Merge Outer and Inner Query
        l_query := get_cc_trd_sel_clause(l_view_by) ||
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

        -- Passing OPI_AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':OPI_CCA_LEVEL_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        x_custom_sql := l_query;

    END get_trd_sql;

    /*--------------------------------------------------
     Function:      get_cc_trd_sel_clause
     Description:   builds the outer select clause for
                    Cycle Count Accuracy Trend Report
    ---------------------------------------------------*/
    FUNCTION get_cc_trd_sel_clause (p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2
    IS

        l_sel_clause varchar2(7500);

    BEGIN

        -- Main Outer query

        l_sel_clause :=
        'SELECT
            ' || ' cal.name VIEWBY,
            ' || opi_dbi_rpt_util_pkg.nvl_str (p_str => 'iset.c_tot_entries')
                                        || ' OPI_MEASURE1,
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'iset.p_hits',
                    p_denominator   => 'iset.p_tot_entries',
                    p_measure_name  => 'OPI_MEASURE3') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'iset.c_hits',
                    p_denominator   => 'iset.c_tot_entries',
                    p_measure_name  => 'OPI_MEASURE4') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'iset.c_hits',
                    p_new_denominator   => 'iset.c_tot_entries',
                    p_old_numerator     => 'iset.p_hits',
                    p_old_denominator   => 'iset.p_tot_entries',
                    p_measure_name      => 'OPI_MEASURE5') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str (p_str => 'iset.c_gross_adj_val')
                                        || ' OPI_MEASURE7,
            ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                    p_numerator     =>'iset.p_gross_adj_val',
                    p_denominator   => 'iset.p_system_val',
                    p_measure_name  => 'OPI_MEASURE8') || ',
            ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                    p_numerator     =>'iset.c_gross_adj_val',
                    p_denominator   => 'iset.c_system_val',
                    p_measure_name  => 'OPI_MEASURE9') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'iset.c_gross_adj_val',
                    p_new_denominator   => 'iset.c_system_val',
                    p_old_numerator     => 'iset.p_gross_adj_val',
                    p_old_denominator   => 'iset.p_system_val',
                    p_measure_name      => 'OPI_MEASURE10') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'iset.p_exact_matches',
                    p_denominator   => 'iset.p_tot_entries',
                    p_measure_name  => 'OPI_MEASURE12') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'iset.c_exact_matches',
                    p_denominator   => 'iset.c_tot_entries',
                    p_measure_name  => 'OPI_MEASURE13') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'iset.c_exact_matches',
                    p_new_denominator   => 'iset.c_tot_entries',
                    p_old_numerator     => 'iset.p_exact_matches',
                    p_old_denominator   => 'iset.p_tot_entries',
                    p_measure_name      => 'OPI_MEASURE14') ;
      RETURN l_sel_clause;

    END get_cc_trd_sel_clause;


    PROCEDURE get_hm_tbl_sql(
                    p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                    x_custom_sql OUT NOCOPY VARCHAR2,
                    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                    )
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

        l_where_clause              VARCHAR2 (2000);
        l_mv                        VARCHAR2 (30);

        l_aggregation_level_flag    VARCHAR2(10);

        l_custom_rec                BIS_QUERY_ATTRIBUTES;
    BEGIN

        -- initialization block
        l_aggregation_level_flag := '0';
        l_comparison_type := 'Y';

        -- clear out the tables.
        l_col_tbl  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();


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
                                         p_version          => '7.0',
                                         p_role             => '',
                                         p_mv_set           => 'CCAC',
                                         p_mv_flag_type     => 'CCA_LEVEL');

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_hits' ,
                                     p_alias_name   => 'hits',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_exact_matches',
                                     p_alias_name   => 'exact_matches',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_misses',
                                     p_alias_name   => 'misses',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_total_entries',
                                     p_alias_name   => 'tot_entries',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');


        -- construct the query
        l_query := get_hitmiss_sel_clause (l_view_by, l_join_tbl)
              || ' from
            ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
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

        -- Passing aggregation level flag to PMV
        l_custom_rec.attribute_name     := ':OPI_CCA_LEVEL_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;


        x_custom_sql := l_query;

    END get_hm_tbl_sql;


    /*--------------------------------------------------
     Function:      get_hitmiss_sel_clause
     Description:   builds the outer select clause for
                    Hit/Miss Summary Report
    ---------------------------------------------------*/

    FUNCTION get_hitmiss_sel_clause(p_view_by_dim IN VARCHAR2,
                                    p_join_tbl IN
                                    poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        return VARCHAR2
    IS

        l_sel_clause varchar2(7000);
        l_view_by_col_name varchar2(60);
        l_description varchar2(30);
        l_err    varchar2(200);
        l_view_by_fact_col VARCHAR2 (400);

    BEGIN

        -- Column to get view by column name
        l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                    (p_view_by_dim);


        -- Description for item view by
        get_cc_item_columns (p_view_by_dim, l_description);

        -- fact column view by's
        l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                    (p_join_tbl);

        -- Outer select clause
        l_sel_clause :=
        'SELECT
        ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
          || l_view_by_col_name || ' OPI_ATTRIBUTE1,
        ' || l_description || ' OPI_ATTRIBUTE2,
        ' || 'oset.OPI_MEASURE1,
        ' || 'oset.OPI_MEASURE3,
        ' || 'oset.OPI_MEASURE4,
        ' || 'oset.OPI_MEASURE5,
        ' || 'oset.OPI_MEASURE6,
        ' || 'oset.OPI_MEASURE8,
        ' || 'oset.OPI_MEASURE9,
        ' || 'oset.OPI_MEASURE10,
        ' || 'oset.OPI_MEASURE11,
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
        ' || 'oset.OPI_MEASURE24,
        ' || 'oset.OPI_MEASURE25,
        ' || 'oset.OPI_MEASURE26
        ' || 'FROM
        ' || '(SELECT (rank () over
        ' || ' (&ORDER_BY_CLAUSE nulls last,
        ' || l_view_by_fact_col || ')) - 1 rnk,
        ' || l_view_by_fact_col || ',
        ' || 'OPI_MEASURE1,
        ' || 'OPI_MEASURE3,
        ' || 'OPI_MEASURE4,
        ' || 'OPI_MEASURE5,
        ' || 'OPI_MEASURE6,
        ' || 'OPI_MEASURE8,
        ' || 'OPI_MEASURE9,
        ' || 'OPI_MEASURE10,
        ' || 'OPI_MEASURE11,
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
        ' || 'OPI_MEASURE24,
        ' || 'OPI_MEASURE25,
        ' || 'OPI_MEASURE26
        ' || 'FROM
        ' || '(SELECT
            ' || l_view_by_fact_col || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str (p_str => 'c_tot_entries')
                                        || ' OPI_MEASURE1,
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str => 'c_hits')
                                        || ' OPI_MEASURE3,
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator         =>'p_hits',
                    p_denominator       => 'p_tot_entries',
                    p_measure_name      => 'OPI_MEASURE4') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator         =>'c_hits',
                    p_denominator       => 'c_tot_entries',
                    p_measure_name      => 'OPI_MEASURE5') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'c_hits',
                    p_new_denominator   => 'c_tot_entries',
                    p_old_numerator     => 'p_hits',
                    p_old_denominator   => 'p_tot_entries',
                    p_measure_name      => 'OPI_MEASURE6') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str => 'c_misses')
                                        || ' OPI_MEASURE8,
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator         =>'p_misses',
                    p_denominator       => 'p_tot_entries',
                    p_measure_name      => 'OPI_MEASURE9') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator         =>'c_misses',
                    p_denominator       => 'c_tot_entries',
                    p_measure_name      => 'OPI_MEASURE10') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'c_misses',
                    p_new_denominator   => 'c_tot_entries',
                    p_old_numerator     => 'p_misses',
                    p_old_denominator   => 'p_tot_entries',
                    p_measure_name      => 'OPI_MEASURE11') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str  => 'c_exact_matches')
                                       || ' OPI_MEASURE13,
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator         =>'p_exact_matches',
                    p_denominator       => 'p_tot_entries',
                    p_measure_name      => 'OPI_MEASURE14') || ',
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator         =>'c_exact_matches',
                    p_denominator       => 'c_tot_entries',
                    p_measure_name      => 'OPI_MEASURE15') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'c_exact_matches',
                    p_new_denominator   => 'c_tot_entries',
                    p_old_numerator     => 'p_exact_matches',
                    p_old_denominator   => 'p_tot_entries',
                    p_measure_name      => 'OPI_MEASURE16') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str => 'c_tot_entries_total')
                                        || ' OPI_MEASURE17,
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str => 'c_hits_total')
                                        || ' OPI_MEASURE18,
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator         =>'c_hits_total',
                    p_denominator       => 'c_tot_entries_total',
                    p_measure_name      => 'OPI_MEASURE19') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'c_hits_total',
                    p_new_denominator   => 'c_tot_entries_total',
                    p_old_numerator     => 'p_hits_total',
                    p_old_denominator   => 'p_tot_entries_total',
                    p_measure_name      => 'OPI_MEASURE20') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str (p_str => 'c_misses_total')
                                        || ' OPI_MEASURE21,
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator         =>'c_misses_total',
                    p_denominator       => 'c_tot_entries_total',
                    p_measure_name      => 'OPI_MEASURE22') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'c_misses_total',
                    p_new_denominator   => 'c_tot_entries_total',
                    p_old_numerator     => 'p_misses_total',
                    p_old_denominator   => 'p_tot_entries_total',
                    p_measure_name      => 'OPI_MEASURE23') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str => 'c_exact_matches_total')
                                        || ' OPI_MEASURE24,
            ' || opi_dbi_rpt_util_pkg.percent_str (
                    p_numerator     =>'c_exact_matches_total',
                    p_denominator   => 'c_tot_entries_total',
                    p_measure_name  => 'OPI_MEASURE25') || ',
            ' || opi_dbi_rpt_util_pkg.change_pct_str (
                    p_new_numerator     => 'c_exact_matches_total',
                    p_new_denominator   => 'c_tot_entries_total',
                    p_old_numerator     => 'p_exact_matches_total',
                    p_old_denominator   => 'p_tot_entries_total',
                    p_measure_name      => 'OPI_MEASURE26') ;

      RETURN l_sel_clause;

    END get_hitmiss_sel_clause;

    /*----------------------------------------
    Cycle Count Adjustment Summary Report Function
    ----------------------------------------*/
    PROCEDURE get_adj_tbl_sql(
           p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
           x_custom_sql OUT NOCOPY VARCHAR2,
           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
       )
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

        l_where_clause              VARCHAR2 (2000);
        l_mv                        VARCHAR2 (30);

        l_aggregation_level_flag    VARCHAR2(10);

        l_custom_rec                BIS_QUERY_ATTRIBUTES;

    BEGIN

        -- initialization block
        l_comparison_type := 'Y';
        l_aggregation_level_flag := '0';

        -- clear out the column and Join info tables.
        l_col_tbl  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

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
                                         p_version          => '7.0',
                                         p_role             => '',
                                         p_mv_set           => 'CCAD',
                                         p_mv_flag_type     => 'CCA_LEVEL');

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'system_inventory_qty' ,
                                     p_alias_name   => 'system_qty',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'net_adjustment_qty' ,
                                     p_alias_name   => 'net_adj_qty',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'gross_adjustment_qty' ,
                                     p_alias_name   => 'gross_adj_qty',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_adjustments' ,
                                     p_alias_name   => 'adjustments',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_total_entries',
                                     p_alias_name   => 'tot_entries',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'system_inventory_val_' || l_cur_suffix,
                                     p_alias_name   => 'system_val',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'gross_adjustment_val_' || l_cur_suffix,
                                     p_alias_name   => 'gross_adj_val',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'net_adjustment_val_' || l_cur_suffix,
                                     p_alias_name   => 'net_adj_val',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        -- construct the query
        l_query := get_adj_rpt_sel_clause (l_view_by, l_join_tbl)
              || ' from
            ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
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

        -- Passing OPI_AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':OPI_CCA_LEVEL_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;


        x_custom_sql := l_query;

    END get_adj_tbl_sql;

    /*--------------------------------------------------
     Function:      get_adj_rpt_sel_clause
     Description:   builds the outer select clause for
                    Cycle Count Adjustment Summary Report
    ---------------------------------------------------*/
    FUNCTION get_adj_rpt_sel_clause(p_view_by_dim IN VARCHAR2,
                                    p_join_tbl IN
                                    poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2
    IS

        l_sel_clause                VARCHAR2(7500);
        l_view_by_col_name          VARCHAR2(60);
        l_item                      VARCHAR2(30);
        l_uom                       VARCHAR2(30);
        l_view_by_fact_col          VARCHAR2(400);
    BEGIN

        -- Column to get view by column name
        l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                    (p_view_by_dim);

        -- Item Description for item view by
        get_cc_item_columns (p_view_by_dim, l_item, 'ITEM');
        get_cc_item_columns (p_view_by_dim, l_uom, 'UOM');

        -- fact column view by's
        l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                    (p_join_tbl);

        -- Outer select clause
        l_sel_clause :=
        'SELECT
        ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
          || l_view_by_col_name || ' OPI_ATTRIBUTE1,
        ' || l_item || ' OPI_ATTRIBUTE2,
        ' || l_uom || ' OPI_ATTRIBUTE3,
        ' || 'oset.OPI_MEASURE2,
        ' || 'oset.OPI_MEASURE3,
        ' || 'oset.OPI_MEASURE5,
        ' || 'oset.OPI_MEASURE6,
        ' || 'oset.OPI_MEASURE8,
        ' || 'oset.OPI_MEASURE9,
        ' || 'oset.OPI_MEASURE10,
        ' || 'oset.OPI_MEASURE11,
        ' || 'oset.OPI_MEASURE12,
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
        ' || 'oset.OPI_MEASURE24,
        ' || 'oset.OPI_MEASURE25,
        ' || 'oset.OPI_MEASURE26,
        ' || 'oset.OPI_MEASURE27
        ' || 'FROM
        ' || '(SELECT (rank () over
        ' || ' (&ORDER_BY_CLAUSE nulls last,
        ' || l_view_by_fact_col || ')) - 1 rnk,
        ' || l_view_by_fact_col || ',
        ' || 'OPI_MEASURE2,
        ' || 'OPI_MEASURE3,
        ' || 'OPI_MEASURE5,
        ' || 'OPI_MEASURE6,
        ' || 'OPI_MEASURE8,
        ' || 'OPI_MEASURE9,
        ' || 'OPI_MEASURE10,
        ' || 'OPI_MEASURE11,
        ' || 'OPI_MEASURE12,
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
        ' || 'OPI_MEASURE24,
        ' || 'OPI_MEASURE25,
        ' || 'OPI_MEASURE26,
        ' || 'OPI_MEASURE27
        ' || 'FROM
            ' || '(SELECT
                ' || l_view_by_fact_col || ',
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_tot_entries',
                        p_default_val   => 0)
                        || ' OPI_MEASURE2,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_adjustments',
                        p_default_val   => 0)
                        || ' OPI_MEASURE3,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_system_qty',
                        p_default_val   => 0)
                        || ' OPI_MEASURE5,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_system_val',
                        p_default_val   => 0)
                        || ' OPI_MEASURE6,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_gross_adj_qty',
                        p_default_val   => 0)
                        || ' OPI_MEASURE8,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_gross_adj_val',
                        p_default_val   => 0)
                        || ' OPI_MEASURE9,
                ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                        p_numerator     => 'p_gross_adj_val',
                        p_denominator   => 'p_system_val',
                        p_measure_name  => 'OPI_MEASURE10') || ',
                ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                        p_numerator     => 'c_gross_adj_val',
                        p_denominator   => 'c_system_val',
                        p_measure_name  => 'OPI_MEASURE11') || ',
                ' || opi_dbi_rpt_util_pkg.change_pct_str (
                        p_new_numerator     => 'c_gross_adj_val',
                        p_new_denominator   => 'c_system_val',
                        p_old_numerator     => 'p_gross_adj_val',
                        p_old_denominator   => 'p_system_val',
                        p_measure_name      => 'OPI_MEASURE12') || ',
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_net_adj_qty',
                        p_default_val   => 0)
                        || ' OPI_MEASURE14,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_net_adj_val',
                        p_default_val   => 0)
                        || ' OPI_MEASURE15,
                ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                        p_numerator     => 'p_net_adj_val',
                        p_denominator   => 'p_system_val',
                        p_measure_name  => 'OPI_MEASURE16') || ',
                ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                        p_numerator     => 'c_net_adj_val',
                        p_denominator   => 'c_system_val',
                        p_measure_name  => 'OPI_MEASURE17') || ',
                ' || opi_dbi_rpt_util_pkg.change_pct_str (
                        p_new_numerator     => 'c_net_adj_val',
                        p_new_denominator   => 'c_system_val',
                        p_old_numerator     => 'p_net_adj_val',
                        p_old_denominator   => 'p_system_val',
                        p_measure_name      => 'OPI_MEASURE18') || ',
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str  => 'c_tot_entries_total',
                        p_default_val   => 0)
                        || ' OPI_MEASURE19,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str  => 'c_adjustments_total',
                        p_default_val   => 0)
                        || ' OPI_MEASURE20,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_system_val_total',
                        p_default_val   => 0)
                        || ' OPI_MEASURE21,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str => 'c_gross_adj_val_total',
                        p_default_val   => 0)
                        || ' OPI_MEASURE22,
                ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                        p_numerator     =>'c_gross_adj_val_total',
                        p_denominator   =>'c_system_val_total',
                        p_measure_name  => 'OPI_MEASURE23') || ',
                ' || opi_dbi_rpt_util_pkg.change_pct_str (
                        p_new_numerator     => 'c_gross_adj_val_total',
                        p_new_denominator   => 'c_system_val_total',
                        p_old_numerator     => 'p_gross_adj_val_total',
                        p_old_denominator   => 'p_system_val_total',
                        p_measure_name      => 'OPI_MEASURE24') || ',
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str => 'c_net_adj_val_total',
                        p_default_val   => 0)
                        || ' OPI_MEASURE25,
                ' || opi_dbi_rpt_util_pkg.pos_denom_percent_str (
                        p_numerator     =>'c_net_adj_val_total',
                        p_denominator   =>'c_system_val_total',
                        p_measure_name  => 'OPI_MEASURE26') || ',
                ' || opi_dbi_rpt_util_pkg.change_pct_str (
                        p_new_numerator     => 'c_net_adj_val_total',
                        p_new_denominator   => 'c_system_val_total',
                        p_old_numerator     => 'p_net_adj_val_total',
                        p_old_denominator   => 'p_system_val_total',
                        p_measure_name      => 'OPI_MEASURE27');

        RETURN l_sel_clause;

    END get_adj_rpt_sel_clause;

    /*----------------------------------------
     Cycle Count Adjustment Detail Report Function
    ----------------------------------------*/
    PROCEDURE get_adj_dtl_sql   (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                                x_custom_sql OUT NOCOPY VARCHAR2,
                                x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
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

        l_where_clause              VARCHAR2 (2000);
        l_mv                        VARCHAR2 (30);

        l_aggregation_level_flag    VARCHAR2(10);

        l_custom_rec                BIS_QUERY_ATTRIBUTES;

    BEGIN

        -- initialization block
        l_comparison_type := 'Y';
        l_aggregation_level_flag := '0';


        -- clear out the column and Join info tables.
        l_col_tbl  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

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
                                         p_version          => '7.0',
                                         p_role             => '',
                                         p_mv_set           => 'CCAD',
                                         p_mv_flag_type     => 'CCA_LEVEL');


        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'system_inventory_qty' ,
                                     p_alias_name   => 'system_qty',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'positive_adjustment_qty' ,
                                     p_alias_name   => 'positive_adj_qty',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'negative_adjustment_qty' ,
                                     p_alias_name   => 'negative_adj_qty',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'number_of_total_entries',
                                     p_alias_name   => 'tot_entries',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'system_inventory_val_' || l_cur_suffix,
                                     p_alias_name   => 'system_val',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'positive_adjustment_val_' || l_cur_suffix,
                                     p_alias_name   => 'positive_adj_val',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'negative_adjustment_val_' || l_cur_suffix,
                                     p_alias_name   => 'negative_adj_val',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'gross_adjustment_val_' || l_cur_suffix,
                                     p_alias_name   => 'gross_adj_val',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'net_adjustment_val_' || l_cur_suffix,
                                     p_alias_name   => 'net_adj_val',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        -- construct the query
        l_query := get_adj_dtl_sel_clause (l_view_by, l_join_tbl)
              || ' from
            ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
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

        -- Passing OPI_AGGREGATION_LEVEL_FLAG to PMV
        l_custom_rec.attribute_name     := ':OPI_CCA_LEVEL_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;


        x_custom_sql := l_query;
    END get_adj_dtl_sql;

    /*--------------------------------------------------
     Function:      get_adj_dtl_sel_clause
     Description:   builds the outer select clause for
                    Cycle Count Adjustment Summary Report
    ---------------------------------------------------*/
    FUNCTION get_adj_dtl_sel_clause(p_view_by_dim IN VARCHAR2,
                                    p_join_tbl IN
                                    poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2
    IS

        l_sel_clause                VARCHAR2(7500);
        l_view_by_col_name          VARCHAR2(60);
        l_item                      VARCHAR2(30);
        l_uom                       VARCHAR2(30);
        l_view_by_fact_col          VARCHAR2(400);

    BEGIN

        -- Column to get view by column name
        l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                    (p_view_by_dim);

        -- Item Description for item view by
        get_cc_item_columns (p_view_by_dim, l_item, 'ITEM');
        get_cc_item_columns (p_view_by_dim, l_uom, 'UOM');

        -- fact column view by's
        l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                    (p_join_tbl);

        -- Outer select clause
        l_sel_clause :=
        'SELECT
        ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim)
          || l_view_by_col_name || ' OPI_ATTRIBUTE1,
        ' || l_item || ' OPI_ATTRIBUTE2,
        ' || l_uom || ' OPI_ATTRIBUTE3,
        ' || 'oset.OPI_MEASURE1,
        ' || 'oset.OPI_MEASURE3,
        ' || 'oset.OPI_MEASURE4,
        ' || 'oset.OPI_MEASURE6,
        ' || 'oset.OPI_MEASURE7,
        ' || 'oset.OPI_MEASURE9,
        ' || 'oset.OPI_MEASURE10,
        ' || 'oset.OPI_MEASURE12,
        ' || 'oset.OPI_MEASURE13,
        ' || 'oset.OPI_MEASURE14,
        ' || 'oset.OPI_MEASURE15,
        ' || 'oset.OPI_MEASURE16,
        ' || 'oset.OPI_MEASURE17,
        ' || 'oset.OPI_MEASURE18,
        ' || 'oset.OPI_MEASURE19
        ' || 'FROM
        ' || '(SELECT (rank () over
        ' || ' (&ORDER_BY_CLAUSE nulls last,
        ' || l_view_by_fact_col || ')) - 1 rnk,
        ' || l_view_by_fact_col || ',
        ' || 'OPI_MEASURE1,
        ' || 'OPI_MEASURE3,
        ' || 'OPI_MEASURE4,
        ' || 'OPI_MEASURE6,
        ' || 'OPI_MEASURE7,
        ' || 'OPI_MEASURE9,
        ' || 'OPI_MEASURE10,
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
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_tot_entries',
                        p_default_val   => 0)
                        || ' OPI_MEASURE1,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_system_qty',
                        p_default_val   => 0)
                        || ' OPI_MEASURE3,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_system_val',
                        p_default_val   => 0)
                        || ' OPI_MEASURE4,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_positive_adj_qty',
                        p_default_val   => 0)
                        || ' OPI_MEASURE6,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_positive_adj_val',
                        p_default_val   => 0)
                        || ' OPI_MEASURE7,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_negative_adj_qty',
                        p_default_val   => 0)
                        || ' OPI_MEASURE9,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_negative_adj_val',
                        p_default_val   => 0)
                        || ' OPI_MEASURE10,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_gross_adj_val',
                        p_default_val   => 0)
                        || ' OPI_MEASURE12,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_net_adj_val',
                        p_default_val   => 0)
                        || ' OPI_MEASURE13,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str  => 'c_tot_entries_total',
                        p_default_val   => 0)
                        || ' OPI_MEASURE14,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str           => 'c_system_val_total',
                        p_default_val   => 0)
                        || ' OPI_MEASURE15,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str => 'c_positive_adj_val_total',
                        p_default_val   => 0)
                        || ' OPI_MEASURE16,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str => 'c_negative_adj_val_total',
                        p_default_val   => 0)
                        || ' OPI_MEASURE17,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str => 'c_gross_adj_val_total',
                        p_default_val   => 0)
                        || ' OPI_MEASURE18,
                ' || opi_dbi_rpt_util_pkg.nvl_str (
                        p_str => 'c_net_adj_val_total',
                        p_default_val   => 0)
                        || ' OPI_MEASURE19';

        RETURN l_sel_clause;

    END get_adj_dtl_sel_clause;


END opi_dbi_cc_rpt_pkg;

/
