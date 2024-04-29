--------------------------------------------------------
--  DDL for Package Body ISC_DBI_CARR_BILL_PAY_TRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_CARR_BILL_PAY_TRD_PKG" AS
/*$Header: ISCRGC4B.pls 120.1 2006/06/26 06:53:20 abhdixi noship $
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
        l_xtd1                       VARCHAR2(10);
        l_xtd2                       VARCHAR2(10);
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
                                             p_mv_set           => 'C41',
                                             p_mv_flag_type     => 'FLAG2',
                                             p_in_join_tbl      =>  l_in_join_tbl);

        -- Add measure columns that need to be aggregated
        -- No Grand totals required.

        --Convert the currency suffix to conform to ISC standards
          IF (l_cur_suffix = 'g')
            THEN l_currency := 'g';
          ELSIF (l_cur_suffix = 'sg')
            THEN l_currency := 'g1';
            ELSE l_currency := 'g';
          END IF;


        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'fully_paid_amt_'|| l_currency,
                                     p_alias_name   => 'fully_paid_amt',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'bill_amt_' || l_currency,
                                     p_alias_name   => 'bill_amt',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'approved_amt_'||l_currency,
                                     p_alias_name   => 'approved_amt',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
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
                                             p_mv_set           => 'C42',
                                             p_mv_flag_type     => 'FLAG2',
                                             p_in_join_tbl      =>  l_in_join_tbl);



        -- Add measure columns that need to be aggregated
        -- No Grand totals required.


 	--Convert the currency suffix to conform to ISC standards
          IF (l_cur_suffix = 'g')
            THEN l_currency := 'g';
          ELSIF (l_cur_suffix = 'sg')
            THEN l_currency := 'g1';
            ELSE l_currency := 'g';
          END IF;


        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2,
                                     p_col_name     => 'payment_amt_'||l_currency,
                                     p_alias_name   => 'payment_amt',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
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
        l_query := get_trd_sel_clause(l_view_by)
                   || ' from ' || poa_dbi_template_pkg.union_all_trend_sql
                         (p_mv       => l_mv_tbl,
                             p_comparison_type    => l_comparison_type,
                                                  p_filter_where    => NULL);





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
                   p_payment_amt 		  ISC_MEASURE_9,
                   c_payment_amt 		  ISC_MEASURE_10,
             ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_payment_amt',
                    p_old_numerator     => 'p_payment_amt',
                    p_denominator       => 'p_payment_amt',
                    p_measure_name      => 'ISC_MEASURE_11') || ', -- Payment Change
                   c_bill_amt - c_fully_paid_amt  ISC_MEASURE_15, --- Bill to Paid Variance Amount
             ' || isc_dbi_sutil_pkg.change_str (
 		    p_new_numerator     => '(c_bill_amt - c_fully_paid_amt)',
                    p_old_numerator     => '(p_bill_amt - p_fully_paid_amt)',
                    p_denominator       => '(p_bill_amt - p_fully_paid_amt)',
                    p_measure_name      => 'ISC_MEASURE_16') || ', -- Billed to Paid Variance Amount Change
	     ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'p_bill_amt',
                    p_old_numerator     => 'p_fully_paid_amt',
                    p_denominator       => 'p_fully_paid_amt',
                    p_measure_name      => 'ISC_MEASURE_17') || ', --(Bill-to-Paid Variance Percent) Prior
	     ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_bill_amt',
                    p_old_numerator     => 'c_fully_paid_amt',
                    p_denominator       => 'c_fully_paid_amt',
                    p_measure_name      => 'ISC_MEASURE_18') || ', --(Bill-to-Paid Variance Percent) Current
             ' || isc_dbi_sutil_pkg.change_rate_str (
                    p_new_numerator     => '(c_bill_amt - c_fully_paid_amt)',
                    p_new_denominator   => 'c_fully_paid_amt',
                    p_old_numerator     => '(p_bill_amt - p_fully_paid_amt)',
                    p_old_denominator   => 'p_fully_paid_amt',
                    p_rate_type         => 'RATIO',
                    p_measure_name      => 'ISC_MEASURE_19') || ', -- Bill-to_Paid Variance Percent Change
		   c_bill_amt - c_approved_amt    ISC_MEASURE_22, --- Bill to Approved Variance Amount
	     ' || isc_dbi_sutil_pkg.change_str (
 		    p_new_numerator     => '(c_bill_amt - c_approved_amt)',
                    p_old_numerator     => '(p_bill_amt - p_approved_amt)',
                    p_denominator       => '(p_bill_amt - p_approved_amt)',
                    p_measure_name      => 'ISC_MEASURE_21') || ',--Billed to Approved Variance Amount Change
	     ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'p_bill_amt',
                    p_old_numerator     => 'p_approved_amt',
                    p_denominator       => 'p_approved_amt',
                    p_measure_name      => 'ISC_MEASURE_12') ||',--(Bill-to-Approved Variance Percent) Prior
	     ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_bill_amt',
                    p_old_numerator     => 'c_approved_amt',
                    p_denominator       => 'c_approved_amt',
                    p_measure_name      => 'ISC_MEASURE_23') ||',--(Bill-to-Approved Var Percent) Current
             ' || isc_dbi_sutil_pkg.change_rate_str (
                    p_new_numerator     => '(c_bill_amt - c_approved_amt)',
                    p_new_denominator   => 'c_approved_amt',
                    p_old_numerator     => '(p_bill_amt - p_approved_amt)',
                    p_old_denominator   => 'p_approved_amt',
                    p_rate_type         => 'RATIO',
                    p_measure_name      => 'ISC_MEASURE_24'); -- Bill-to_Approved Variance Percent Change


      RETURN l_sel_clause;

    END get_trd_sel_clause;

END ISC_DBI_CARR_BILL_PAY_TRD_PKG;

/
