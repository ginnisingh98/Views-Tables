--------------------------------------------------------
--  DDL for Package Body OPI_DBI_WMS_RTP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_WMS_RTP_PKG" AS
/*$Header: OPIDRWMSRTPB.pls 120.0 2005/05/24 18:17:27 appldev noship $ */
    /*----------------------------------------------------
        Declare PRIVATE procedures and functions for package
    -----------------------------------------------------*/

    FUNCTION get_tbl_sel_clause1 (p_view_by_dim IN VARCHAR2,
                                    p_join_tbl IN
                                    poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2;


    FUNCTION get_tbl_sel_clause2 (p_view_by_dim IN VARCHAR2,
                                    p_join_tbl IN
                                    poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2;


    FUNCTION get_trd_sel_clause(p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION get_trd_sel_clause2(p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION get_tbl_filter_where1(p_view_by in VARCHAR2) return varchar2;


    /*----------------------------------------
    Receipt to Putaway Cycle Time
    ----------------------------------------*/
    PROCEDURE get_tbl_sql1 (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
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
        l_custom_sql                VARCHAR2 (10000);
	l_subinv_val        VARCHAR2 (120) := NULL;


        l_col_tbl1                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_col_tbl2                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;

        l_where_clause              VARCHAR2 (2000);
	l_where_clause2		    VARCHAR2 (2000);
        l_mv1                       VARCHAR2 (30);
        l_mv2                       VARCHAR2 (30);

        l_aggregation_level_flag1    VARCHAR2(10);
        l_aggregation_level_flag2    VARCHAR2(10);

        l_custom_rec                BIS_QUERY_ATTRIBUTES;
	l_mv_tbl 		    poa_dbi_util_pkg.poa_dbi_mv_tbl;


    BEGIN

	-- initialization block
        l_comparison_type := 'Y';
        l_aggregation_level_flag1 := '0';

        -- clear out the column and Join info tables.
        l_col_tbl1  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_col_tbl2  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
  	l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

	l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();


        -- get all the query parameters for the RTP MV
        opi_dbi_rpt_util_pkg.process_parameters (
                                         p_param            => p_param,
                                         p_view_by          => l_view_by,
                                         p_view_by_col_name => l_view_by_col,
                                         p_comparison_type  => l_comparison_type,
                                         p_xtd              => l_xtd2,
                                         p_cur_suffix       => l_cur_suffix,
                                         p_where_clause     => l_where_clause2,
                                         p_mv               => l_mv2,
                                         p_join_tbl         => l_join_tbl,
                                         p_mv_level_flag    => l_aggregation_level_flag2,
                                         p_trend            => 'N',
                                         p_func_area        => 'OPI',
                                         p_version          => '7.1',
                                         p_role             => '',
                                         p_mv_set           => 'RTP',
                                         p_mv_flag_type     => 'WMS_RTP');


        -- Add measure columns that need to be aggregated

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2,
                                     p_col_name     => 'c_putaway_quantity' ,
                                     p_alias_name   => 'putaways',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2,
                                     p_col_name     => 'putaway_quantity' ,
                                     p_alias_name   => 'qty_putaway',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2,
                                     p_col_name     => 'rtp_cycle_time',
                                     p_alias_name   => 'rtp_cyc_time',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');





        -- get all the query parameters for RTX MV and viewbys other than SUB
IF l_view_by <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' AND l_where_clause2 not like '%fact.subinventory%' THEN
        opi_dbi_rpt_util_pkg.process_parameters (
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
                                         p_func_area        => 'OPI',
                                         p_version          => '7.1',
                                         p_role             => '',
                                         p_mv_set           => 'RTX',
                                         p_mv_flag_type     => 'WMS_RTX');

        -- Add measure columns that need to be aggregated


        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'transactions_cnt' ,
                                     p_alias_name   => 'rcv_txns',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');
END IF;

IF l_view_by = 'ITEM+ENI_ITEM_ORG' THEN
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'quantity' ,
                                     p_alias_name   => 'quantity_rcv',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');
END IF;



        -- construct the query
IF l_view_by <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' AND l_where_clause2 not like '%fact.subinventory%' THEN
	l_mv_tbl.extend;
	l_mv_tbl(1).mv_name := l_mv1;
	l_mv_tbl(1).mv_col := l_col_tbl1;
	l_mv_tbl(1).mv_where := l_where_clause;
	l_mv_tbl(1).in_join_tbls := NULL;
	l_mv_tbl(1).use_grp_id := 'N';

	l_mv_tbl.extend;
	l_mv_tbl(2).mv_name := l_mv2;
	l_mv_tbl(2).mv_col := l_col_tbl2;
	l_mv_tbl(2).mv_where := l_where_clause2;
	l_mv_tbl(2).in_join_tbls := NULL;
	l_mv_tbl(2).use_grp_id := 'N';


        l_query := get_tbl_sel_clause1 (l_view_by, l_join_tbl)
              || ' from (
            ' || poa_dbi_template_pkg.union_all_status_sql
						 (p_mv       => l_mv_tbl,
                                                  p_join_tables     => l_join_tbl,
                                                  p_use_windowing   => 'Y',
                                                  p_paren_count     => 3,
                                                  p_filter_where    => get_tbl_filter_where1(l_view_by),
						  p_generate_viewby => 'Y');

ELSE
        l_query := get_tbl_sel_clause2(l_view_by, l_join_tbl)
              || ' from
            ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv2,
                                                  p_where_clause    => l_where_clause2,
                                                  p_join_tables     => l_join_tbl,
                                                  p_use_windowing   => 'Y',
                                                  p_col_name        => l_col_tbl2,
                                                  p_use_grpid       => 'N',
                                                  p_paren_count     => 3,
                                                  p_filter_where    => get_tbl_filter_where1(l_view_by),
                                                  p_generate_viewby => 'Y',
                                                  p_in_join_tables  => NULL);

END IF;
        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the status SQL
        poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);
    	poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd2);
IF l_view_by <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' AND l_where_clause2 not like '%fact.subinventory%' THEN
    	poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd1);
END IF;
        -- Passing OPI_AGGREGATION_LEVEL_FLAGS to PMV
IF l_view_by <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' AND l_where_clause2 not like '%fact.subinventory%' THEN
        l_custom_rec.attribute_name     := ':OPI_RTX_AGG_LEVEL_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag1;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;
 END IF;

        l_custom_rec.attribute_name     := ':OPI_RTP_AGG_LEVEL_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag2;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;

        x_custom_output(x_custom_output.count) := l_custom_rec;

        x_custom_sql := l_query;

    END get_tbl_sql1;


    /*--------------------------------------------------
     Function:      get_tbl_sel_clause1
     Description:   Builds the outer select clause for
                    Receipt to Putaway Cycle Time Report.
		    For viewbys other than subinventory
    ---------------------------------------------------*/

    FUNCTION get_tbl_sel_clause1(p_view_by_dim IN VARCHAR2,
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
	l_inner_qty_rcv_sel_clause	    VARCHAR2(300);
	l_inner_qty_put_sel_clause	    VARCHAR2(300);
    BEGIN

        -- initialization block

        -- Column to get view by column name
        l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                    (p_view_by_dim);


        -- fact column view by's
        l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                    (p_join_tbl);

        -- Outer select clause
        l_sel_clause :=
        'SELECT
        ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim);
	IF p_view_by_dim = 'ITEM+ENI_ITEM_ORG' THEN
           l_sel_clause := l_sel_clause || '
	   v.description OPI_ATTRIBUTE2,		--Description
          v2.description OPI_ATTRIBUTE3,      		--UOM
	  oset.OPI_MEASURE1 OPI_MEASURE1,		-- Quantity Received
	  oset.OPI_MEASURE4 OPI_MEASURE4,		-- Quantity Putaway
';
	l_inner_qty_rcv_sel_clause:= opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_quantity_rcv',
                    p_default_val   => 0);
	l_inner_qty_put_sel_clause:= opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_qty_putaway',
                    p_default_val   => 0);

	ELSE
   	   l_sel_clause := l_sel_clause || '
	   null OPI_ATTRIBUTE2,		-- Description
	   null OPI_ATTRIBUTE3,		-- UOM
	   null OPI_MEASURE1,		-- Quantity Received
	   null OPI_MEASURE4,		-- Quantity Putaway
';
	  l_inner_qty_rcv_sel_clause:= ' NULL ';
	  l_inner_qty_put_sel_clause:= ' NULL ';

	END IF;

   l_sel_clause := l_sel_clause ||
'      	   oset.OPI_MEASURE2,
	   oset.OPI_MEASURE3,
	oset.OPI_MEASURE5, 			-- Putaways
        oset.OPI_MEASURE6, 			-- Change
        oset.OPI_MEASURE7, 			-- Receipt to Putaway Cycle Time (Hours)
        oset.OPI_MEASURE8,			-- Change
        oset.OPI_MEASURE9, 			-- Total Receiving Transactions
        oset.OPI_MEASURE10, 			-- Total Change
        oset.OPI_MEASURE11, 			-- Total Putaways
        oset.OPI_MEASURE12,			-- Total Change
        oset.OPI_MEASURE13,			-- Total Receipt to Putaway
        oset.OPI_MEASURE14,			-- Total Change
	oset.OPI_MEASURE15,			-- Total Prior RTP (Hours)
        oset.OPI_ATTRIBUTE5,
        oset.OPI_ATTRIBUTE7,
        oset.OPI_ATTRIBUTE9
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
        OPI_MEASURE6,
        OPI_MEASURE7,
        OPI_MEASURE8,
        OPI_MEASURE9,
        OPI_MEASURE10,
        OPI_MEASURE11,
        OPI_MEASURE12,
        OPI_MEASURE13,
        OPI_MEASURE14,
	OPI_MEASURE15,
        OPI_ATTRIBUTE5,
        OPI_ATTRIBUTE7,
        OPI_ATTRIBUTE9
        FROM
        (SELECT
            ' || l_view_by_fact_col || ',
            ' || l_inner_qty_rcv_sel_clause
                    || ' OPI_MEASURE1,
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_rcv_txns',
                    p_default_val   => 0)
                    || ' OPI_MEASURE2,
            ' || opi_dbi_rpt_util_pkg.change_str (
                    p_new_numerator     => 'c_rcv_txns',
                    p_old_numerator   => 'p_rcv_txns',
                    p_denominator     => 'p_rcv_txns',
                    p_measure_name      => 'OPI_MEASURE3') || ',
             ' || l_inner_qty_put_sel_clause
                    || ' OPI_MEASURE4,
             ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_putaways',
                    p_default_val   => 0)
                    || ' OPI_MEASURE5,
            ' || opi_dbi_rpt_util_pkg.change_str (
                    p_new_numerator     => 'c_putaways',
                    p_old_numerator   => 'p_putaways',
                    p_denominator     => 'p_putaways',
                    p_measure_name      => 'OPI_MEASURE6') || ',
            ' || opi_dbi_rpt_util_pkg.rate_str (
                    p_numerator     => '24*c_rtp_cyc_time',
                    p_denominator     => 'c_putaways',
		    p_rate_type	   => 'NP')
                   || 'OPI_MEASURE7,
	    ' || (opi_dbi_rpt_util_pkg.rate_str (
		    p_numerator	    => '24*c_rtp_cyc_time',
	   	    p_denominator   => 'c_putaways',
		    p_rate_type	    => 'NP')) || '-'
	      || (opi_dbi_rpt_util_pkg.rate_str (
		    p_numerator    => '24*p_rtp_cyc_time',
		    p_denominator  => 'p_putaways',
		    p_rate_type    => 'NP'))
	           || ' OPI_MEASURE8,
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_rcv_txns_total',
                    p_default_val   => 0)
                    || ' OPI_MEASURE9,
            ' || opi_dbi_rpt_util_pkg.change_str (
                    p_new_numerator     => 'c_rcv_txns_total',
                    p_old_numerator   => 'p_rcv_txns_total',
                    p_denominator     => 'p_rcv_txns_total',
                    p_measure_name      => 'OPI_MEASURE10') || ',
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_putaways_total',
                    p_default_val   => 0)
                    || ' OPI_MEASURE11,
            ' || opi_dbi_rpt_util_pkg.change_str (
                    p_new_numerator     => 'c_putaways_total',
                    p_old_numerator   => 'p_putaways_total',
                    p_denominator     => 'p_putaways_total',
                    p_measure_name      => 'OPI_MEASURE12') || ',
            ' || opi_dbi_rpt_util_pkg.rate_str (
                    p_numerator     => '24*c_rtp_cyc_time_total',
                    p_denominator     => 'c_putaways_total',
		    p_rate_type	   => 'NP')
                   || 'OPI_MEASURE13,
	    ' || (opi_dbi_rpt_util_pkg.rate_str (
		    p_numerator	    => '24*c_rtp_cyc_time_total',
	   	    p_denominator   => 'c_putaways_total',
		    p_rate_type	    => 'NP')) || '-'
	      || (opi_dbi_rpt_util_pkg.rate_str (
		    p_numerator    => '24*p_rtp_cyc_time_total',
		    p_denominator  => 'p_putaways_total',
		    p_rate_type    => 'NP'))
	           || ' OPI_MEASURE14,
            ' || opi_dbi_rpt_util_pkg.rate_str (
                    p_numerator     => '24*p_rtp_cyc_time_total',
                    p_denominator     => 'p_putaways_total',
		    p_rate_type	   => 'NP')
                   || 'OPI_MEASURE15,
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'p_rcv_txns',
                    p_default_val   => 0)
                    || ' OPI_ATTRIBUTE5,
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'p_putaways',
                    p_default_val   => 0)
                    || ' OPI_ATTRIBUTE7,
            ' || opi_dbi_rpt_util_pkg.rate_str (
                    p_numerator     => '24*p_rtp_cyc_time',
                    p_denominator     => 'p_putaways',
		    p_rate_type	   => 'NP')
                   || 'OPI_ATTRIBUTE9

';

      RETURN l_sel_clause;

    END get_tbl_sel_clause1;

   /*--------------------------------------------------
     Function:      get_tbl_filter_where1
     Description:   Generates a where clause to restrict
                    rows with NA/0 values
    ---------------------------------------------------*/

 function get_tbl_filter_where1(p_view_by in VARCHAR2) return varchar2
  is
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  begin
    l_col_tbl := poa_dbi_sutil_pkg.poa_dbi_filter_tbl();
    l_col_tbl.extend;
    l_col_tbl(1) := 'OPI_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(2) := 'OPI_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(3) := 'OPI_MEASURE5';
    l_col_tbl.extend;
    l_col_tbl(4) := 'OPI_MEASURE6';
    l_col_tbl.extend;
    l_col_tbl(5) := 'OPI_MEASURE7';
    l_col_tbl.extend;
    l_col_tbl(6) := 'OPI_MEASURE8';
    if(p_view_by = 'ITEM+POA_ITEMS') then
     l_col_tbl.extend;
     l_col_tbl(10) := 'OPI_MEASURE1';
     l_col_tbl.extend;
     l_col_tbl(10) := 'OPI_MEASURE4';
    end if;
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);
  end;




    /*--------------------------------------------------
     Function:      get_tbl_sel_clause2
     Description:   Builds the outer select clause for
                    Receipt to Putaway Cycle Time Report.
		    For viewby subinventory or when a
		    specific subinventory is chosen
    ---------------------------------------------------*/

    FUNCTION get_tbl_sel_clause2(p_view_by_dim IN VARCHAR2,
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
	l_inner_qty_rcv_sel_clause	    VARCHAR2(300);
	l_inner_qty_put_sel_clause	    VARCHAR2(300);

    BEGIN

        -- initialization block

        -- Column to get view by column name
        l_view_by_col_name := opi_dbi_rpt_util_pkg.get_view_by_col_name
                                                    (p_view_by_dim);


        -- fact column view by's
        l_view_by_fact_col := opi_dbi_rpt_util_pkg.get_fact_select_columns
                                                    (p_join_tbl);

        -- Outer select clause
        l_sel_clause :=
        'SELECT
        ' || opi_dbi_rpt_util_pkg.get_viewby_select_clause (p_view_by_dim);

	IF p_view_by_dim = 'ITEM+ENI_ITEM_ORG' THEN
           l_sel_clause := l_sel_clause || '
	   v.description OPI_ATTRIBUTE2,		--Description
          v2.description OPI_ATTRIBUTE3,      		--UOM
	  null OPI_MEASURE1,				-- Quantity Received
	  oset.OPI_MEASURE4 OPI_MEASURE4,		-- Quantity Putaway
';
	l_inner_qty_rcv_sel_clause:= ' NULL ';
	l_inner_qty_put_sel_clause:= opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_qty_putaway',
                    p_default_val   => 0);

	ELSE
   	   l_sel_clause := l_sel_clause || '
	   null OPI_ATTRIBUTE2,		-- Description
	   null OPI_ATTRIBUTE3,		-- UOM
	   null OPI_MEASURE1,		-- Quantity Received
	   null OPI_MEASURE4,		-- Quantity Putaway
';
	  l_inner_qty_rcv_sel_clause:= ' NULL ';
	  l_inner_qty_put_sel_clause:= ' NULL ';

	END IF;

           l_sel_clause := l_sel_clause || '
        oset.OPI_MEASURE2, 			-- Receiving Transactions
        oset.OPI_MEASURE3, 			-- Change
        oset.OPI_MEASURE5, 			-- Putaways
        oset.OPI_MEASURE6, 			-- Change
        oset.OPI_MEASURE7, 			-- Receipt to Putaway Cycle Time (Hours)
        oset.OPI_MEASURE8,			-- Change
        oset.OPI_MEASURE9, 			-- Total Receiving Transactions
        oset.OPI_MEASURE10, 			-- Total Change
        oset.OPI_MEASURE11, 			-- Total Putaways
        oset.OPI_MEASURE12,			-- Total Change
        oset.OPI_MEASURE13,			-- Total Receipt to Putaway
        oset.OPI_MEASURE14,			-- Total Change
	oset.OPI_MEASURE15,			-- Total Prior RTP(Hours)
        oset.OPI_ATTRIBUTE5,
        oset.OPI_ATTRIBUTE7,
        oset.OPI_ATTRIBUTE9
        FROM
        (SELECT (rank () over
        (&ORDER_BY_CLAUSE nulls last,
        ' || l_view_by_fact_col || ')) - 1 rnk,
        ' || l_view_by_fact_col || ',
	OPI_MEASURE1,
	OPI_MEASURE4,
        OPI_MEASURE2,
        OPI_MEASURE3,
        OPI_MEASURE5,
        OPI_MEASURE6,
        OPI_MEASURE7,
        OPI_MEASURE8,
        OPI_MEASURE9,
        OPI_MEASURE10,
        OPI_MEASURE11,
        OPI_MEASURE12,
        OPI_MEASURE13,
        OPI_MEASURE14,
	OPI_MEASURE15,
        OPI_ATTRIBUTE5,
        OPI_ATTRIBUTE7,
        OPI_ATTRIBUTE9
        FROM
        (SELECT
        ' || l_view_by_fact_col || ',
            ' || l_inner_qty_rcv_sel_clause
                    || ' OPI_MEASURE1,
            null OPI_MEASURE2,
            null OPI_MEASURE3,
             ' || l_inner_qty_put_sel_clause
                    || ' OPI_MEASURE4,
             ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_putaways',
                    p_default_val   => 0)
                    || ' OPI_MEASURE5,
            ' || opi_dbi_rpt_util_pkg.change_str (
                    p_new_numerator     => 'c_putaways',
                    p_old_numerator   => 'p_putaways',
                    p_denominator     => 'p_putaways',
                    p_measure_name      => 'OPI_MEASURE6') || ',
            ' || opi_dbi_rpt_util_pkg.rate_str (
                    p_numerator     => '24*c_rtp_cyc_time',
                    p_denominator     => 'c_putaways',
		    p_rate_type	   => 'NP')
                   || 'OPI_MEASURE7,
	    ' || (opi_dbi_rpt_util_pkg.rate_str (
		    p_numerator	    => '24*c_rtp_cyc_time',
	   	    p_denominator   => 'c_putaways',
		    p_rate_type	    => 'NP')) || '-'
	      || (opi_dbi_rpt_util_pkg.rate_str (
		    p_numerator    => '24*p_rtp_cyc_time',
		    p_denominator  => 'p_putaways',
		    p_rate_type    => 'NP'))
	           || ' OPI_MEASURE8,
            null OPI_MEASURE9,
            null OPI_MEASURE10,
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_putaways_total',
                    p_default_val   => 0)
                    || ' OPI_MEASURE11,
            ' || opi_dbi_rpt_util_pkg.change_str (
                    p_new_numerator     => 'c_putaways_total',
                    p_old_numerator   => 'p_putaways_total',
                    p_denominator     => 'p_putaways_total',
                    p_measure_name      => 'OPI_MEASURE12') || ',
            ' || opi_dbi_rpt_util_pkg.rate_str (
                    p_numerator     => '24*c_rtp_cyc_time_total',
                    p_denominator     => 'c_putaways_total',
		    p_rate_type	   => 'NP')
                   || 'OPI_MEASURE13,
	    ' || (opi_dbi_rpt_util_pkg.rate_str (
		    p_numerator	    => '24*c_rtp_cyc_time_total',
	   	    p_denominator   => 'c_putaways_total',
		    p_rate_type	    => 'NP')) || '-'
	      || (opi_dbi_rpt_util_pkg.rate_str (
		    p_numerator    => '24*p_rtp_cyc_time_total',
		    p_denominator  => 'p_putaways_total',
		    p_rate_type    => 'NP'))
	           || ' OPI_MEASURE14,
           ' || opi_dbi_rpt_util_pkg.rate_str (
                    p_numerator     => '24*p_rtp_cyc_time_total',
                    p_denominator     => 'p_putaways_total',
		    p_rate_type	   => 'NP')
                   || 'OPI_MEASURE15,
            null OPI_ATTRIBUTE5,
            ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'p_putaways',
                    p_default_val   => 0)
                    || ' OPI_ATTRIBUTE7,

            ' || opi_dbi_rpt_util_pkg.rate_str (
                    p_numerator     => '24*p_rtp_cyc_time',
                    p_denominator     => 'p_putaways',
		    p_rate_type	   => 'NP')
                   || 'OPI_ATTRIBUTE9

';
      RETURN l_sel_clause;

    END get_tbl_sel_clause2;




    /*----------------------------------------
          Receipt to Putaway Cycle Time Trend
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
        l_cur_suffix                VARCHAR2(5);
        l_custom_sql                VARCHAR2 (10000);

        l_col_tbl1                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_col_tbl2                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
        l_where_clause              VARCHAR2 (2000);
        l_where_clause2             VARCHAR2 (2000);
        l_mv1                       VARCHAR2 (30);
        l_mv2                       VARCHAR2 (30);

        l_aggregation_level_flag1    VARCHAR2(10);
        l_aggregation_level_flag2    VARCHAR2(10);

        l_custom_rec                BIS_QUERY_ATTRIBUTES;
	l_mv_tbl 		    poa_dbi_util_pkg.poa_dbi_mv_tbl;

    BEGIN

	l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

        -- initialization block
        l_comparison_type := 'Y';
        l_aggregation_level_flag1 := '0';

        -- clear out the tables.
        l_col_tbl1  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_col_tbl2  := poa_dbi_util_pkg.POA_DBI_COL_TBL ();
        l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- get all the query parameters for putaway side


        opi_dbi_rpt_util_pkg.process_parameters (
                                             p_param            => p_param,
                                             p_view_by          => l_view_by,
                                             p_view_by_col_name => l_view_by_col,
                                             p_comparison_type  => l_comparison_type,
                                             p_xtd              => l_xtd2,
                                             p_cur_suffix       => l_cur_suffix,
                                             p_where_clause     => l_where_clause2,
                                             p_mv               => l_mv2,
                                             p_join_tbl         => l_join_tbl,
                                             p_mv_level_flag    =>l_aggregation_level_flag2,
                                             p_trend            => 'Y',
                                             p_func_area        => 'OPI',
                                             p_version          => '7.1',
                                             p_role             => '',
                                             p_mv_set           => 'RTP',
                                             p_mv_flag_type     => 'WMS_RTP');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2,
                                     p_col_name     => 'c_putaway_quantity' ,
                                     p_alias_name   => 'putaways',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');


        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2,
                                     p_col_name     => 'rtp_cycle_time',
                                     p_alias_name   => 'rtp_cyc_time',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');


        -- get all the query parameters for receiving side

IF l_where_clause2 not like '%fact.subinventory%' THEN
        opi_dbi_rpt_util_pkg.process_parameters (
                                             p_param            => p_param,
                                             p_view_by          => l_view_by,
                                             p_view_by_col_name => l_view_by_col,
                                             p_comparison_type  => l_comparison_type,
                                             p_xtd              => l_xtd1,
                                             p_cur_suffix       => l_cur_suffix,
                                             p_where_clause     => l_where_clause,
                                             p_mv               => l_mv1,
                                             p_join_tbl         => l_join_tbl,
                                             p_mv_level_flag    =>l_aggregation_level_flag1,
                                             p_trend            => 'Y',
                                             p_func_area        => 'OPI',
                                             p_version          => '7.1',
                                             p_role             => '',
                                             p_mv_set           => 'RTX',
                                             p_mv_flag_type     => 'WMS_RTX');
        -- Add measure columns that need to be aggregated
        -- No Grand totals required.
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'transactions_cnt' ,
                                     p_alias_name   => 'rcv_txns',
                                     p_grand_total  => 'N',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');
END IF;


        -- Merge Outer and Inner Query
IF l_where_clause2 not like '%fact.subinventory%' THEN

	l_mv_tbl.extend;
	l_mv_tbl(1).mv_name := l_mv1;
	l_mv_tbl(1).mv_col := l_col_tbl1;
	l_mv_tbl(1).mv_where := l_where_clause;
	l_mv_tbl(1).in_join_tbls := NULL;
	l_mv_tbl(1).use_grp_id := 'N';
	l_mv_tbl(1).mv_hint := poa_dbi_sutil_pkg.get_fact_hint(l_mv1);
	l_mv_tbl(1).mv_xtd := l_xtd1;

	l_mv_tbl.extend;
	l_mv_tbl(2).mv_name := l_mv2;
	l_mv_tbl(2).mv_col := l_col_tbl2;
	l_mv_tbl(2).mv_where := l_where_clause2;
	l_mv_tbl(2).in_join_tbls := NULL;
	l_mv_tbl(2).use_grp_id := 'N';
	l_mv_tbl(2).mv_hint := poa_dbi_sutil_pkg.get_fact_hint(l_mv2);
	l_mv_tbl(2).mv_xtd := l_xtd2;

        l_query := get_trd_sel_clause(l_view_by) ||
                   ' from ' ||
	poa_dbi_template_pkg.union_all_trend_sql(
			p_mv		    => l_mv_tbl,
                        p_comparison_type   => l_comparison_type,

			p_filter_where	    => NULL
);

ELSE
        l_query := get_trd_sel_clause2(l_view_by) ||
                   ' from ' ||
	poa_dbi_template_pkg.trend_sql(
                        p_xtd               => l_xtd2,
                        p_comparison_type   => l_comparison_type,
                        p_fact_name        => l_mv2,
                        p_where_clause      => l_where_clause2,
                        p_col_name          => l_col_tbl2,
                        p_use_grpid         => 'N',
			p_in_join_tables    => NULL,
			p_fact_hint	     => poa_dbi_sutil_pkg.get_fact_hint(l_mv2)

);
END IF;

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
    	poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd2);
        -- Passing OPI_AGGREGATION_LEVEL_FLAG to PMV
IF l_where_clause2 not like '%fact.subinventory%' THEN
        l_custom_rec.attribute_name     := ':OPI_RTX_AGG_LEVEL_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag1;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(x_custom_output.count) := l_custom_rec;

END IF;

        l_custom_rec.attribute_name     := ':OPI_RTP_AGG_LEVEL_FLAG';
        l_custom_rec.attribute_value    := l_aggregation_level_flag2;
        l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;

        x_custom_output(x_custom_output.count) := l_custom_rec;

        x_custom_sql := l_query;

    END get_trd_sql;

    /*--------------------------------------------------
     Function:      get_trd_sel_clause
     Description:   Builds the outer select clause for
                    Receipt to Putaway Cycle Time Trend
		    Report when viewing all subinventories
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
             ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'p_rcv_txns',
                    p_default_val   => 0)
                    || ' OPI_ATTRIBUTE5,
             ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_rcv_txns',
                    p_default_val   => 0)
                    || ' OPI_MEASURE1,
            ' || opi_dbi_rpt_util_pkg.change_str (
                    p_new_numerator     => 'c_rcv_txns',
                    p_old_numerator   => 'p_rcv_txns',
                    p_denominator     => 'p_rcv_txns',
                    p_measure_name      => 'OPI_MEASURE2') || ',
             ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'p_putaways',
                    p_default_val   => 0)
                    || ' OPI_ATTRIBUTE6,
             ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_putaways',
                    p_default_val   => 0)
                    || ' OPI_MEASURE3,
            ' || opi_dbi_rpt_util_pkg.change_str (
                    p_new_numerator     => 'c_putaways',
                    p_old_numerator   => 'p_putaways',
                    p_denominator     => 'p_putaways',
                    p_measure_name      => 'OPI_MEASURE4') || ',
            ' || opi_dbi_rpt_util_pkg.rate_str (
                    p_numerator     => '24*p_rtp_cyc_time',
                    p_denominator     => 'p_putaways',
		    p_rate_type	   => 'NP')
                   || 'OPI_ATTRIBUTE7,
            ' || opi_dbi_rpt_util_pkg.rate_str (
                    p_numerator     => '24*c_rtp_cyc_time',
                    p_denominator     => 'c_putaways',
		    p_rate_type	   => 'NP')
                   || 'OPI_MEASURE5,
	    ' || (opi_dbi_rpt_util_pkg.rate_str (
		    p_numerator	    => '24*c_rtp_cyc_time',
	   	    p_denominator   => 'c_putaways',
		    p_rate_type	    => 'NP')) || '-'
	      || (opi_dbi_rpt_util_pkg.rate_str (
		    p_numerator    => '24*p_rtp_cyc_time',
		    p_denominator  => 'p_putaways',
		    p_rate_type    => 'NP'))
	           || ' OPI_MEASURE6'
;
      RETURN l_sel_clause;

    END get_trd_sel_clause;

    /*--------------------------------------------------
     Function:      get_trd_sel_clause2
     Description:   Builds the outer select clause for
                    Receipt to Putaway Cycle Time Trend
		    Report when a specific subinventory
		    is selected
    ---------------------------------------------------*/

    FUNCTION get_trd_sel_clause2 (p_view_by_dim IN VARCHAR2)
        RETURN VARCHAR2
    IS

        l_sel_clause varchar2(7500);

    BEGIN

        -- Main Outer query

        l_sel_clause :=
        'SELECT
            ' || ' cal.name VIEWBY,
             null OPI_ATTRIBUTE5,
             null OPI_MEASURE1,
             null OPI_MEASURE2,
             ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'p_putaways',
                    p_default_val   => 0)
                    || ' OPI_ATTRIBUTE6,
             ' || opi_dbi_rpt_util_pkg.nvl_str (
                    p_str           => 'c_putaways',
                    p_default_val   => 0)
                    || ' OPI_MEASURE3,
            ' || opi_dbi_rpt_util_pkg.change_str (
                    p_new_numerator     => 'c_putaways',
                    p_old_numerator   => 'p_putaways',
                    p_denominator     => 'p_putaways',
                    p_measure_name      => 'OPI_MEASURE4') || ',
            ' || opi_dbi_rpt_util_pkg.rate_str (
                    p_numerator     => '24*p_rtp_cyc_time',
                    p_denominator     => 'p_putaways',
		    p_rate_type	   => 'NP')
                   || 'OPI_ATTRIBUTE7,
            ' || opi_dbi_rpt_util_pkg.rate_str (
                    p_numerator     => '24*c_rtp_cyc_time',
                    p_denominator     => 'c_putaways',
		    p_rate_type	   => 'NP')
                   || 'OPI_MEASURE5,
	    ' || (opi_dbi_rpt_util_pkg.rate_str (
		    p_numerator	    => '24*c_rtp_cyc_time',
	   	    p_denominator   => 'c_putaways',
		    p_rate_type	    => 'NP')) || '-'
	      || (opi_dbi_rpt_util_pkg.rate_str (
		    p_numerator    => '24*p_rtp_cyc_time',
		    p_denominator  => 'p_putaways',
		    p_rate_type    => 'NP'))
	           || ' OPI_MEASURE6';
        RETURN l_sel_clause;

    END get_trd_sel_clause2;
END opi_dbi_wms_rtp_pkg;

/
