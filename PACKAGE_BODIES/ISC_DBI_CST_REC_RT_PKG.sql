--------------------------------------------------------
--  DDL for Package Body ISC_DBI_CST_REC_RT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_CST_REC_RT_PKG" AS
/*$Header: ISCRGBTB.pls 120.0 2005/05/25 17:15:52 appldev noship $
    /*----------------------------------------------------
        Declare PRIVATE procedures and functions for package
    -----------------------------------------------------*/
    /* Freight Cost Recovery Rate Report */
    FUNCTION get_rpt_sel_clause (p_view_by_dim IN VARCHAR2,
                                    p_join_tbl IN
                                    poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2;

    /* Function to filter rows that don't provide informative data */
    FUNCTION get_status_filter_where(p_view_by IN VARCHAR2)
        RETURN VARCHAR2;

    /*------------------------------------------------
    Freight Cost Recovery Rate Report Function
    -------------------------------------------------*/
    PROCEDURE get_tbl_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
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

        -- clear out the column and Join info tables.
        l_col_tbl  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

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
                                         p_mv_level_flag    => l_aggregation_level_flag,
                                         p_trend            => 'N',
                                         p_func_area        => 'ISC',
                                         p_version          => '7.1',
                                         p_role             => '',
                                         p_mv_set           => 'BT1',
                                         p_mv_flag_type     => 'FLAG3',
                                         p_in_join_tbl      =>  l_in_join_tbl);

        --Convert the currency suffix to conform to ISC standards
          IF (l_cur_suffix = 'g')
            THEN l_currency := 'g';
          ELSIF (l_cur_suffix = 'sg')
            THEN l_currency := 'g1';
            ELSE l_currency := 'f';
          END IF;

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'freight_cost_amt_'||l_currency,
                                     p_alias_name   => 'freight_cost',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                     p_col_name     => 'freight_charge_amt_'||l_currency,
                                     p_alias_name   => 'freight_charge',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'XTD');

        IF l_view_by = 'ITEM+ENI_ITEM_ORG' THEN
           poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl,
                                        p_col_name     => 'shipped_qty',
                                        p_alias_name   => 'quantity',
                                        p_grand_total  => 'Y',
                                        p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                        p_to_date_type => 'XTD');
        END IF;


        -- construct the query
        l_query := get_rpt_sel_clause (l_view_by, l_join_tbl)
              || ' from
            ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv,
                                                  p_where_clause    => l_where_clause,
                                                  p_join_tables     => l_join_tbl,
                                                  p_use_windowing   => 'Y',
                                                  p_col_name        => l_col_tbl,
                                                  p_use_grpid       => 'N',
                                                  p_paren_count     => 3,
                                                  p_filter_where    => get_status_filter_where(l_view_by),
                                                  p_generate_viewby => 'Y',
                                                  p_in_join_tables  => l_in_join_tbl);

        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the status SQL
        poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);

        -- Passing ISC_AGG_FLAG to PMV
        l_custom_rec.attribute_name     := ':ISC_AGG_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

        x_custom_sql := l_query;

    END get_tbl_sql;


    /*------------------------------------------------------------------------------------
     Function:      get_status_filter_where
     Description:   creates additional where clause to filter rows without meaningful data
    -------------------------------------------------------------------------------------*/
  FUNCTION get_status_filter_where(p_view_by in VARCHAR2) return VARCHAR2
  IS
    l_col_tbl poa_dbi_util_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'ISC_MEASURE_2';
    l_col_tbl.extend;
    l_col_tbl(2) := 'ISC_MEASURE_4';
    l_col_tbl.extend;
    l_col_tbl(3) := 'ISC_MEASURE_5';
    return poa_dbi_util_pkg.get_filter_where(l_col_tbl);

  END;


    /*--------------------------------------------------
     Function:      get_rtp_sel_clause
     Description:   builds the outer select clause
    ---------------------------------------------------*/
    FUNCTION get_rpt_sel_clause(p_view_by_dim IN VARCHAR2,
                                   p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2
    IS
        l_sel_clause                VARCHAR2(32000);
        l_view_by_col_name          VARCHAR2(60);
        l_drill_across_rep_1        VARCHAR2(50);
        l_drill_across_rep_2        VARCHAR2(50);
        l_view_by_fact_col          VARCHAR2(400);
        l_drill_across              VARCHAR2(1000);
	l_inner_qty_sel_clause	    VARCHAR2(300);

    BEGIN

        -- initialization block

        -- Column to get view by column name
        l_view_by_col_name := isc_dbi_sutil_pkg.get_view_by_col_name (p_view_by_dim);

        -- fact column view by's
        l_view_by_fact_col := isc_dbi_sutil_pkg.get_fact_select_columns (p_join_tbl);


        -- Outer select clause
        l_sel_clause :=
        'SELECT
        ' || isc_dbi_sutil_pkg.get_view_by_select_clause (p_view_by_dim);
        IF p_view_by_dim = 'ITEM+ENI_ITEM_ORG' THEN
           l_sel_clause := l_sel_clause || '
	   v.description 		ISC_ATTRIBUTE_2, -- Description
           v2.uom_code 			ISC_ATTRIBUTE_3, -- UOM
           NULL 			ISC_ATTRIBUTE_4, -- Drill Across URL
	   oset.ISC_MEASURE_1 		ISC_MEASURE_1,	 -- Shipped Quantity
';
           l_inner_qty_sel_clause:= nvl('c_quantity',0);
        ELSIF p_view_by_dim = 'ITEM+ENI_ITEM_VBH_CAT' THEN
   	   l_sel_clause := l_sel_clause || '
	     NULL	 		ISC_ATTRIBUTE_2, -- Description
             NULL 			ISC_ATTRIBUTE_3, -- UOM
	     decode(v.leaf_node_flag, ''Y'',
		''pFunctionName=ISC_DBI_CST_REC_RT_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_ORG&pParamIds=Y'',
		''pFunctionName=ISC_DBI_CST_REC_RT_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'')
             	 			ISC_ATTRIBUTE_4, -- Drill Across URL
	     NULL 			ISC_MEASURE_1,	 -- Shipped Quantity
';
	   l_inner_qty_sel_clause:= ' NULL ';
        ELSE
   	   l_sel_clause := l_sel_clause || '
	     NULL	 		ISC_ATTRIBUTE_2, -- Description
             NULL 			ISC_ATTRIBUTE_3, -- UOM
             NULL 			ISC_ATTRIBUTE_4, -- Drill Across URL
	     NULL 			ISC_MEASURE_1,	 -- Shipped Quantity
';
	   l_inner_qty_sel_clause:= ' NULL ';

        END IF;

   	l_sel_clause := l_sel_clause ||
            '  oset.ISC_MEASURE_2 	ISC_MEASURE_2,
        ' || 'oset.ISC_MEASURE_3 	ISC_MEASURE_3,
        ' || 'oset.ISC_MEASURE_4	ISC_MEASURE_4,
        ' || 'oset.ISC_MEASURE_5	ISC_MEASURE_5,
        ' || 'oset.ISC_MEASURE_6	ISC_MEASURE_6,
        ' || 'oset.ISC_MEASURE_7	ISC_MEASURE_7,
        ' || 'oset.ISC_MEASURE_8	ISC_MEASURE_8,
        ' || 'oset.ISC_MEASURE_9	ISC_MEASURE_9,
        ' || 'oset.ISC_MEASURE_10	ISC_MEASURE_10,
        ' || 'oset.ISC_MEASURE_11	ISC_MEASURE_11,
        ' || 'oset.ISC_MEASURE_12 	ISC_MEASURE_12,
        ' || 'oset.ISC_MEASURE_13 	ISC_MEASURE_13,
        ' || 'oset.ISC_MEASURE_14	ISC_MEASURE_14,
        ' || 'oset.ISC_MEASURE_15	ISC_MEASURE_15,
        ' || 'oset.ISC_MEASURE_16	ISC_MEASURE_16,
        ' || 'oset.ISC_MEASURE_17	ISC_MEASURE_17
        ' || 'FROM
        ' || '(SELECT (rank () over
        ' || ' (&ORDER_BY_CLAUSE nulls last,
        ' || l_view_by_fact_col || ')) - 1 rnk,
        ' || l_view_by_fact_col || ',
        ' || 'ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,ISC_MEASURE_4,ISC_MEASURE_5,
           ISC_MEASURE_6,ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,
           ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13,ISC_MEASURE_14,ISC_MEASURE_15,
           ISC_MEASURE_16,ISC_MEASURE_17
        ' || 'FROM
        ' || '(SELECT
            ' || l_view_by_fact_col || ',
            ' || l_inner_qty_sel_clause || ' ISC_MEASURE_1,
	nvl(c_freight_cost,0)	 		ISC_MEASURE_2,
	nvl(p_freight_charge,0) 		ISC_MEASURE_4,
	nvl(c_freight_charge,0) 		ISC_MEASURE_5,
	nvl(c_freight_cost_total,0) 		ISC_MEASURE_11,
	nvl(c_freight_charge_total,0) 		ISC_MEASURE_13,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_freight_cost',
                    p_old_numerator     => 'p_freight_cost',
                    p_denominator       => 'p_freight_cost',
                    p_measure_name      => 'ISC_MEASURE_3') || ', -- Estimated Fr Cost Change
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_freight_charge',
                    p_old_numerator     => 'p_freight_charge',
                    p_denominator       => 'p_freight_charge',
                    p_measure_name      => 'ISC_MEASURE_6') || ', -- Order Fr Charge Change
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'c_freight_charge',
                    p_denominator   => 'c_freight_charge_total',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_7') || ', -- Percent of Total Fr Cost
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'p_freight_charge',
                    p_denominator   => 'p_freight_cost',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_8') || ', -- Prior Recovery Rate
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'c_freight_charge',
                    p_denominator   => 'c_freight_cost',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_9') || ', -- Recovery Rate
            ' || isc_dbi_sutil_pkg.change_rate_str (
                    p_new_numerator     => 'c_freight_charge',
                    p_new_denominator   => 'c_freight_cost',
                    p_old_numerator     => 'p_freight_charge',
                    p_old_denominator   => 'p_freight_cost',
                    p_rate_type         => 'PERCENT',
                    p_measure_name      => 'ISC_MEASURE_10') || ', -- Recovery Rate Change
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_freight_cost_total',
                    p_old_numerator     => 'p_freight_cost_total',
                    p_denominator       => 'p_freight_cost_total',
                    p_measure_name      => 'ISC_MEASURE_12') || ', --Grand Total Estimated Fr Cost Change
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_freight_charge_total',
                    p_old_numerator     => 'p_freight_charge_total',
                    p_denominator       => 'p_freight_charge_total',
                    p_measure_name      => 'ISC_MEASURE_14') || ', --Grand Total Fr Charge Change
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'c_freight_charge_total',
                    p_denominator   => 'c_freight_charge_total',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_15') || ', -- Grand Total Percent of Total Fr Cost
            ' || isc_dbi_sutil_pkg.rate_str (
                    p_numerator     => 'c_freight_charge_total',
                    p_denominator   => 'c_freight_cost_total',
                    p_rate_type     => 'PERCENT',
                    p_measure_name  => 'ISC_MEASURE_16') || ', -- Grand Total Recovery Rate
            ' || isc_dbi_sutil_pkg.change_rate_str (
                    p_new_numerator     => 'c_freight_charge_total',
                    p_new_denominator   => 'c_freight_cost_total',
                    p_old_numerator     => 'p_freight_charge_total',
                    p_old_denominator   => 'p_freight_cost_total',
                    p_rate_type         => 'PERCENT',
                    p_measure_name      => 'ISC_MEASURE_17'); -- Grand Total Recovery Rate Change

      RETURN l_sel_clause;

    END get_rpt_sel_clause;

END ISC_DBI_CST_REC_RT_PKG;

/
