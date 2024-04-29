--------------------------------------------------------
--  DDL for Package Body ISC_DBI_CARR_BILL_PAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_CARR_BILL_PAY_PKG" AS
/*$Header: ISCRGC3B.pls 120.0 2005/05/25 17:17:50 appldev noship $
    /*----------------------------------------------------
        Declare PRIVATE procedures and functions for package
    -----------------------------------------------------*/


    /* Non-Trend Report */
    FUNCTION get_rpt_sel_clause (p_view_by_dim IN VARCHAR2,
                                    p_join_tbl IN
                                    poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2;


    /*----------------------------------------
    Carrier Billing and Payment Variance Report Function
    ----------------------------------------*/
    PROCEDURE get_tbl_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
    IS
        l_query                     VARCHAR2(32767);
        l_view_by                   VARCHAR2(120);
        l_view_by_col               VARCHAR2 (120);
        l_xtd1                      VARCHAR2(10);
	l_xtd2			    VARCHAR2(10);
        l_comparison_type           VARCHAR2(1);
        l_cur_suffix                VARCHAR2(5);
        l_currency                  VARCHAR2(10);

        l_custom_sql                VARCHAR2 (10000);

        l_col_tbl1                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_col_tbl2                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
	l_in_join_tbl1 		    poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
	l_in_join_tbl2 		    poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
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

        -- clear out the column and Join info tables.
        l_col_tbl1  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_col_tbl2  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters for the RTX MV
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
                                         p_trend            => 'N',
                                         p_func_area        => 'ISC',
                                         p_version          => '7.1',
                                         p_role             => '',
                                         p_mv_set           => 'C31',
                                         p_mv_flag_type     => 'FLAG2',
                                         p_in_join_tbl      =>  l_in_join_tbl1);



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
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'bill_amt_' || l_currency,
                                     p_alias_name   => 'bill_amt',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'approved_amt_'||l_currency,
                                     p_alias_name   => 'approved_amt',
                                     p_grand_total  => 'Y',
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
                                             p_trend            => 'N',
                                             p_func_area        => 'ISC',
                                             p_version          => '7.1',
                                             p_role             => '',
                                             p_mv_set           => 'C32',
                                             p_mv_flag_type     => 'FLAG2',
                                             p_in_join_tbl      =>  l_in_join_tbl2);



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
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');




   	l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

   	l_mv_tbl.extend;
    	l_mv_tbl(1).mv_name := l_mv1;
    	l_mv_tbl(1).mv_col := l_col_tbl1;
    	l_mv_tbl(1).mv_where := l_where_clause;
    	l_mv_tbl(1).in_join_tbls := NULL;
    	l_mv_tbl(1).use_grp_id := 'N';

    	l_mv_tbl.extend;
    	l_mv_tbl(2).mv_name := l_mv2;
    	l_mv_tbl(2).mv_col := l_col_tbl2;
    	l_mv_tbl(2).mv_where := l_where_clause;
    	l_mv_tbl(2).in_join_tbls := NULL;
    	l_mv_tbl(2).use_grp_id := 'N';




        -- construct the query
        l_query := get_rpt_sel_clause (l_view_by, l_join_tbl)
              || ' from (
            ' || poa_dbi_template_pkg.union_all_status_sql
                         (p_mv       => l_mv_tbl,
                                                  p_join_tables     => l_join_tbl,
                                                  p_use_windowing   => 'Y',
                                                  p_paren_count     => 3,
                                                  p_filter_where    => NULL);

        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the status SQL
        poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);
    	poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd1);
    	poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd2);
        -- Passing OPI_AGGREGATION_LEVEL_FLAGS to PMV
        l_custom_rec.attribute_name     := ':ISC_AGG_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag1;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;


        l_custom_rec.attribute_name     := ':ISC_AGG_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag2;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        x_custom_sql := l_query;

    END get_tbl_sql;




    FUNCTION get_rpt_sel_clause(p_view_by_dim IN VARCHAR2,
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
        -- Column to get view by column name
        l_view_by_col_name := isc_dbi_sutil_pkg.get_view_by_col_name (p_view_by_dim);

        -- fact column view by's
        l_view_by_fact_col := isc_dbi_sutil_pkg.get_fact_select_columns (p_join_tbl);


        -- Outer select clause
	l_sel_clause :=
       'SELECT ' || isc_dbi_sutil_pkg.get_view_by_select_clause (p_view_by_dim)
	  || 'oset.ISC_MEASURE_9	ISC_MEASURE_9,
        ' || 'oset.ISC_MEASURE_10	ISC_MEASURE_10,
        ' || 'oset.ISC_MEASURE_11 	ISC_MEASURE_11,
        ' || 'oset.ISC_MEASURE_12	ISC_MEASURE_12,
        ' || 'oset.ISC_MEASURE_13 	ISC_MEASURE_13,
        ' || 'oset.ISC_MEASURE_15 	ISC_MEASURE_15,
        ' || 'oset.ISC_MEASURE_16	ISC_MEASURE_16,
        ' || 'oset.ISC_MEASURE_17	ISC_MEASURE_17,
        ' || 'oset.ISC_MEASURE_18	ISC_MEASURE_18,
        ' || 'oset.ISC_MEASURE_19	ISC_MEASURE_19,
        ' || 'oset.ISC_MEASURE_21	ISC_MEASURE_21,
        ' || 'oset.ISC_MEASURE_22	ISC_MEASURE_22,
        ' || 'oset.ISC_MEASURE_23	ISC_MEASURE_23,
        ' || 'oset.ISC_MEASURE_24	ISC_MEASURE_24,
        ' || 'oset.ISC_MEASURE_1	ISC_MEASURE_1,
        ' || 'oset.ISC_MEASURE_2	ISC_MEASURE_2,
        ' || 'oset.ISC_MEASURE_3	ISC_MEASURE_3,
        ' || 'oset.ISC_MEASURE_4	ISC_MEASURE_4,
        ' || 'oset.ISC_MEASURE_5	ISC_MEASURE_5,
        ' || 'oset.ISC_MEASURE_6	ISC_MEASURE_6,
        ' || 'oset.ISC_MEASURE_7	ISC_MEASURE_7,
        ' || 'oset.ISC_MEASURE_8	ISC_MEASURE_8,
        ' || 'oset.ISC_MEASURE_25	ISC_MEASURE_25,
        ' || 'oset.ISC_MEASURE_26	ISC_MEASURE_26,
        ' || 'oset.ISC_MEASURE_27	ISC_MEASURE_27,
        ' || 'oset.ISC_MEASURE_28	ISC_MEASURE_28,
        ' || 'oset.ISC_MEASURE_30	ISC_MEASURE_30,
        ' || 'oset.ISC_MEASURE_32	ISC_MEASURE_32,
        ' || 'oset.ISC_MEASURE_33	ISC_MEASURE_33,
        ' || 'oset.ISC_MEASURE_34	ISC_MEASURE_34,
        ' || 'oset.ISC_MEASURE_35	ISC_MEASURE_35
        ' || 'FROM
        ' || '(SELECT (rank () over
        ' || ' (&ORDER_BY_CLAUSE nulls last,
        ' || l_view_by_fact_col || ')) - 1 rnk,
        ' || l_view_by_fact_col || ',
        ' || 'ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,ISC_MEASURE_4,ISC_MEASURE_5,
           ISC_MEASURE_6,ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,
           ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13,ISC_MEASURE_15,
           ISC_MEASURE_16,ISC_MEASURE_17,ISC_MEASURE_18,ISC_MEASURE_19,
 	   ISC_MEASURE_21,ISC_MEASURE_22,ISC_MEASURE_23,ISC_MEASURE_24,
	   ISC_MEASURE_25,ISC_MEASURE_26,ISC_MEASURE_27,ISC_MEASURE_28,
	   ISC_MEASURE_30,ISC_MEASURE_32,ISC_MEASURE_33,ISC_MEASURE_34,ISC_MEASURE_35
        ' || 'FROM
        ' || '(SELECT
            ' || l_view_by_fact_col || ',
	p_payment_amt 			ISC_MEASURE_9,
	c_payment_amt 			ISC_MEASURE_10,
	p_payment_amt_total 		ISC_MEASURE_32,
	c_payment_amt_total	        ISC_MEASURE_1,
	c_fully_paid_amt		ISC_MEASURE_13,
	c_fully_paid_amt_total		ISC_MEASURE_4,
	c_bill_amt			ISC_MEASURE_15,
	c_bill_amt_total		ISC_MEASURE_5,
	c_bill_amt - c_fully_paid_amt	ISC_MEASURE_16,
	c_bill_amt_total - c_fully_paid_amt_total	ISC_MEASURE_6,
	c_approved_amt			ISC_MEASURE_21,
	c_bill_amt - c_approved_amt     ISC_MEASURE_22,
	c_approved_amt_total 		ISC_MEASURE_25,
	c_bill_amt_total - c_approved_amt_total     ISC_MEASURE_26,
	    ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_payment_amt',
                    p_old_numerator     => 'p_payment_amt',
                    p_denominator       => 'p_payment_amt',
                    p_measure_name      => 'ISC_MEASURE_11') || ', -- Payment Change

	    ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_payment_amt_total',
                    p_old_numerator     => 'p_payment_amt_total',
                    p_denominator       => 'p_payment_amt_total',
                    p_measure_name      => 'ISC_MEASURE_2') || ', -- GT - Total Payment Change

   	    ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'c_payment_amt',
                    p_denominator   => 'c_payment_amt_total',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_12') || ', -- Percent of Total

   	    ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'c_payment_amt_total',
                    p_denominator   => 'c_payment_amt_total',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_3') || ', -- GT- Percent of Total

  	    ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'p_bill_amt',
                    p_old_numerator     => 'p_fully_paid_amt',
                    p_denominator       => 'p_fully_paid_amt',
                    p_measure_name      => 'ISC_MEASURE_17') || ', -- (Bill-to-Paid Variance Percent) Prior

  	    ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'p_bill_amt',
                    p_old_numerator     => 'p_fully_paid_amt',
                    p_denominator       => 'p_fully_paid_amt',
                    p_measure_name      => 'ISC_MEASURE_35') || ', -- KPI (Bill-to-Paid Variance Percent) Prior

  	    ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'p_bill_amt_total',
                    p_old_numerator     => 'p_fully_paid_amt_total',
                    p_denominator       => 'p_fully_paid_amt_total',
                    p_measure_name      => 'ISC_MEASURE_30') || ', -- GT (Bill-to-Paid Variance Percent) Prior

 	    ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_bill_amt',
                    p_old_numerator     => 'c_fully_paid_amt',
                    p_denominator       => 'c_fully_paid_amt',
                    p_measure_name      => 'ISC_MEASURE_18') || ', --(Bill-to-Paid Variance Percent) Current

 	    ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_bill_amt',
                    p_old_numerator     => 'c_fully_paid_amt',
                    p_denominator       => 'c_fully_paid_amt',
                    p_measure_name      => 'ISC_MEASURE_33') || ', --(Bill-to-Paid Variance Percent) Current (for KPI)

 	    ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_bill_amt_total',
                    p_old_numerator     => 'c_fully_paid_amt_total',
                    p_denominator       => 'c_fully_paid_amt_total',
                    p_measure_name      => 'ISC_MEASURE_7') || ', -- GT-(Bill-to-Paid Variance Percent) Current

 	    ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_bill_amt_total',
                    p_old_numerator     => 'c_fully_paid_amt_total',
                    p_denominator       => 'c_fully_paid_amt_total',
                    p_measure_name      => 'ISC_MEASURE_34') || ', -- KPIGT-(Bill-to-Paid Variance Percent) Current

	    ' || isc_dbi_sutil_pkg.change_rate_str (
                    p_new_numerator     => '(c_bill_amt - c_fully_paid_amt)',
                    p_new_denominator   => 'c_fully_paid_amt',
                    p_old_numerator     => '(p_bill_amt - p_fully_paid_amt)',
                    p_old_denominator   => 'p_fully_paid_amt',
                    p_rate_type         => 'RATIO',
                    p_measure_name      => 'ISC_MEASURE_19') || ', -- Bill-to_Paid Variance Percent Change

	    ' || isc_dbi_sutil_pkg.change_rate_str (
                    p_new_numerator     => '(c_bill_amt_total - c_fully_paid_amt_total)',
                    p_new_denominator   => 'c_fully_paid_amt_total',
                    p_old_numerator     => '(p_bill_amt_total - p_fully_paid_amt_total)',
                    p_old_denominator   => 'p_fully_paid_amt_total',
                    p_rate_type         => 'RATIO',
                    p_measure_name      => 'ISC_MEASURE_8') || ', --GT - Bill-to_Paid Variance Percent Change

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
                    p_measure_name      => 'ISC_MEASURE_24') || ', -- Bill-to-Approved Variance Percent Change

	     ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_bill_amt_total',
                    p_old_numerator     => 'c_approved_amt_total',
                    p_denominator       => 'c_approved_amt_total',
                    p_measure_name      => 'ISC_MEASURE_27') ||',--GT (Bill-to-Approved Var Percent) Current

             ' || isc_dbi_sutil_pkg.change_rate_str (
                    p_new_numerator     => '(c_bill_amt_total - c_approved_amt_total)',
                    p_new_denominator   => 'c_approved_amt_total',
                    p_old_numerator     => '(p_bill_amt_total - p_approved_amt_total)',
                    p_old_denominator   => 'p_approved_amt_total',
                    p_rate_type         => 'RATIO',
                    p_measure_name      => 'ISC_MEASURE_28'); -- GT Bill-to-Approved Variance Percent Change


      RETURN l_sel_clause;

    END get_rpt_sel_clause;


END ISC_DBI_CARR_BILL_PAY_PKG;

/
