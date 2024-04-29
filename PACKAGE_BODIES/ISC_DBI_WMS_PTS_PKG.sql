--------------------------------------------------------
--  DDL for Package Body ISC_DBI_WMS_PTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_WMS_PTS_PKG" AS
/*$Header: ISCRGBRB.pls 120.1 2006/06/29 06:14:03 abhdixi noship $
    /*----------------------------------------------------
        Declare PRIVATE procedures and functions for package
    -----------------------------------------------------*/

    /* No subinventory dimension --> need all measures
       from isc_wms_000_mv and isc_wms_001_mv */
    FUNCTION get_sel_clause1 (p_view_by_dim IN VARCHAR2,
                                    p_join_tbl IN
                                    poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2;

    /* Subinventory dimension --> don't need to retrieve pick release measures,
       only measures from isc_wms_001_mv */
    FUNCTION get_sel_clause2 (p_view_by_dim IN VARCHAR2,
                                    p_join_tbl IN
                                    poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2;

    /*------------------------------------------------
      Report Query for Pick Release To Ship Cycle Time
    -------------------------------------------------*/
    PROCEDURE get_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
    IS
        l_query                     VARCHAR2(32767);
        l_view_by                   VARCHAR2(120);
        l_view_by_col               VARCHAR2 (120);
        l_xtd                       VARCHAR2(10);
        l_comparison_type           VARCHAR2(1);
        l_cur_suffix                VARCHAR2(10);
        l_custom_sql                VARCHAR2 (10000);

	l_mv_tbl                    poa_dbi_util_pkg.POA_DBI_MV_TBL;
        l_col_tbl1                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_col_tbl2                  poa_dbi_util_pkg.POA_DBI_COL_TBL;
        l_join_tbl                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
        l_in_join_tbl               poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;

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
                                         p_trend            => 'N',
                                         p_func_area        => 'ISC',
                                         p_version          => '7.1',
                                         p_role             => '',
                                         p_mv_set           => 'RS2',
                                         p_mv_flag_type     => 'FLAG4',
                                         p_in_join_tbl      =>  l_in_join_tbl);

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2,
                                     p_col_name     => 'ship_confirm_cnt',
                                     p_alias_name   => 'ship_confirm_cnt',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');

        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2,
                                     p_col_name     => 'release_to_ship',
                                     p_alias_name   => 'release_to_ship',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');


        IF l_view_by = 'ITEM+ENI_ITEM_ORG' THEN
           poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2,
                                        p_col_name     => 'ship_confirm_qty',
                                        p_alias_name   => 'ship_confirm_qty',
                                        p_grand_total  => 'N',
                                        p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                        p_to_date_type => 'RLX');
        END IF;

IF (l_view_by <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY'
    AND l_where_clause2 NOT LIKE '%fact.subinventory%') THEN
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
                                         p_trend            => 'N',
                                         p_func_area        => 'ISC',
                                         p_version          => '7.1',
                                         p_role             => '',
                                         p_mv_set           => 'RS1',
                                         p_mv_flag_type     => 'FLAG5',
                                         p_in_join_tbl      =>  l_in_join_tbl);

        -- Add measure columns that need to be aggregated
        poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                     p_col_name     => 'pick_release_cnt',
                                     p_alias_name   => 'pick_release_cnt',
                                     p_grand_total  => 'Y',
                                     p_prior_code   => poa_dbi_util_pkg.BOTH_PRIORS,
                                     p_to_date_type => 'RLX');

        IF l_view_by = 'ITEM+ENI_ITEM_ORG' THEN
           poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1,
                                        p_col_name     => 'pick_release_qty',
                                        p_alias_name   => 'pick_release_qty',
                                        p_grand_total  => 'N',
                                        p_prior_code   => poa_dbi_util_pkg.NO_PRIORS,
                                        p_to_date_type => 'RLX');
        END IF;
END IF;

        -- construct the query
IF (l_view_by <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY'
    AND l_where_clause2 NOT LIKE '%fact.subinventory%') THEN

	l_mv_tbl.extend;
	l_mv_tbl(1).mv_name := l_mv1;
	l_mv_tbl(1).mv_col := l_col_tbl1;
	l_mv_tbl(1).mv_where := l_where_clause1;
	l_mv_tbl(1).in_join_tbls := NULL;
	l_mv_tbl(1).use_grp_id := 'N';

	l_mv_tbl.extend;
	l_mv_tbl(2).mv_name := l_mv2;
	l_mv_tbl(2).mv_col := l_col_tbl2;
	l_mv_tbl(2).mv_where := l_where_clause2;
	l_mv_tbl(2).in_join_tbls := NULL;
	l_mv_tbl(2).use_grp_id := 'N';

        l_query := get_sel_clause1 (l_view_by, l_join_tbl)
              || ' from (
            ' || poa_dbi_template_pkg.union_all_status_sql
						 (p_mv              => l_mv_tbl,
                                                  p_join_tables     => l_join_tbl,
                                                  p_use_windowing   => 'Y',
                                                  p_paren_count     => 3,
                                                  p_filter_where    => NULL);

ELSE
        l_query := get_sel_clause2 (l_view_by, l_join_tbl)
              || ' from
            ' || poa_dbi_template_pkg.status_sql (p_fact_name       => l_mv2,
                                                  p_where_clause    => l_where_clause2,
                                                  p_join_tables     => l_join_tbl,
                                                  p_use_windowing   => 'Y',
                                                  p_col_name        => l_col_tbl2,
                                                  p_use_grpid       => 'N',
                                                  p_paren_count     => 3,
                                                  p_filter_where    => NULL,
                                                  p_generate_viewby => 'Y',
                                                  p_in_join_tables  => NULL);
END IF;

        -- prepare output for bind variables
        x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

        -- set the basic bind variables for the status SQL
        poa_dbi_util_pkg.get_custom_status_binds (x_custom_output);
    	poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd);

        -- Passing ISC_AGG_FLAGS to PMV
IF (l_view_by <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY'
    AND l_where_clause2 NOT LIKE '%fact.subinventory%') THEN
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
    FUNCTION get_sel_clause1(p_view_by_dim IN VARCHAR2,
                                   p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2
    IS
        l_sel_clause                VARCHAR2(32000);
        l_view_by_col_name          VARCHAR2(60);
        l_view_by_fact_col          VARCHAR2(400);
	l_inner_qty_sel_clause1	    VARCHAR2(300);
	l_inner_qty_sel_clause2	    VARCHAR2(300);
	l_measure_5_desc	    VARCHAR2(300);

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
	   v.description 		ISC_ATTRIBUTE_4, -- Description
           v2.uom_code 			ISC_ATTRIBUTE_5, -- UOM
	   oset.ISC_MEASURE_1 		ISC_MEASURE_1, -- Quantity Pick Released
';
           l_measure_5_desc := '
	   oset.ISC_MEASURE_5 		ISC_MEASURE_5, -- Quantity Ship Confirmed ';

           l_inner_qty_sel_clause1:= 'c_pick_release_qty 		ISC_MEASURE_1,';
           l_inner_qty_sel_clause2:= 'c_ship_confirm_qty		ISC_MEASURE_5,';
        ELSE
   	   l_sel_clause := l_sel_clause || '
	   NULL	 			ISC_ATTRIBUTE_4, -- Description
           NULL 			ISC_ATTRIBUTE_5, -- UOM
	   NULL	 			ISC_MEASURE_1, -- Quantity Pick Released
';
           l_measure_5_desc := '
	   NULL	ISC_MEASURE_5, -- Quantity Ship Confirmed ';

	   l_inner_qty_sel_clause1:= 'NULL		 	ISC_MEASURE_1,';
	   l_inner_qty_sel_clause2:= 'NULL			ISC_MEASURE_5,';

        END IF;

   	l_sel_clause := l_sel_clause ||
'	   oset.ISC_MEASURE_2 		ISC_MEASURE_2,
	   oset.ISC_MEASURE_3 		ISC_MEASURE_3,
	   oset.ISC_MEASURE_4		ISC_MEASURE_4,';

	l_sel_clause := l_sel_clause || '
	' || l_measure_5_desc || '
	   oset.ISC_MEASURE_6		ISC_MEASURE_6,
	   oset.ISC_MEASURE_7		ISC_MEASURE_7,
	   oset.ISC_MEASURE_8		ISC_MEASURE_8,
	   oset.ISC_MEASURE_9		ISC_MEASURE_9,
	   oset.ISC_MEASURE_10		ISC_MEASURE_10,
	   oset.ISC_MEASURE_11		ISC_MEASURE_11,
	   oset.ISC_MEASURE_12 		ISC_MEASURE_12,
	   oset.ISC_MEASURE_13 		ISC_MEASURE_13,
	   oset.ISC_MEASURE_14		ISC_MEASURE_14,
	   oset.ISC_MEASURE_15		ISC_MEASURE_15,
	   oset.ISC_MEASURE_16		ISC_MEASURE_16,
	   oset.ISC_MEASURE_17		ISC_MEASURE_17,
	   oset.ISC_MEASURE_19		ISC_MEASURE_19
	   FROM
	   (SELECT (rank () over
	    (&ORDER_BY_CLAUSE nulls last, ' || l_view_by_fact_col || ')) - 1 rnk,
           ' || l_view_by_fact_col || ',
	   ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,ISC_MEASURE_4,ISC_MEASURE_5,
           ISC_MEASURE_6,ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,
           ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13,ISC_MEASURE_14,ISC_MEASURE_15,
           ISC_MEASURE_16,ISC_MEASURE_17,ISC_MEASURE_19
              FROM
	      (SELECT
            ' || l_view_by_fact_col || ',
            ' || l_inner_qty_sel_clause1 || '
	    p_pick_release_cnt		ISC_MEASURE_2,
	    c_pick_release_cnt 		ISC_MEASURE_3,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_pick_release_cnt',
                    p_old_numerator     => 'p_pick_release_cnt',
                    p_denominator       => 'p_pick_release_cnt',
                    p_measure_name      => 'ISC_MEASURE_4') || ',
            ' || l_inner_qty_sel_clause2 || '
	    p_ship_confirm_cnt 		ISC_MEASURE_6,
   	    c_ship_confirm_cnt 		ISC_MEASURE_7,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_ship_confirm_cnt',
                    p_old_numerator     => 'p_ship_confirm_cnt',
                    p_denominator       => 'p_ship_confirm_cnt',
                    p_measure_name      => 'ISC_MEASURE_8') || ',
            CASE WHEN p_ship_confirm_cnt = 0 THEN to_number (NULL)
                 ELSE (p_release_to_ship*24/p_ship_confirm_cnt)
                 END			ISC_MEASURE_9,
            CASE WHEN c_ship_confirm_cnt = 0 THEN to_number (NULL)
                 ELSE (c_release_to_ship*24/c_ship_confirm_cnt)
                 END			ISC_MEASURE_10,
            CASE WHEN c_ship_confirm_cnt = 0 THEN to_number(NULL)
                 WHEN p_ship_confirm_cnt = 0 THEN to_number(NULL)
	         ELSE ((c_release_to_ship*24/c_ship_confirm_cnt
                         - p_release_to_ship*24/p_ship_confirm_cnt))
                 END			ISC_MEASURE_11,
	    c_pick_release_cnt_total	ISC_MEASURE_12,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_pick_release_cnt_total',
                    p_old_numerator     => 'p_pick_release_cnt_total',
                    p_denominator       => 'p_pick_release_cnt_total',
                    p_measure_name      => 'ISC_MEASURE_13') || ',
	    c_ship_confirm_cnt_total	ISC_MEASURE_14,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_ship_confirm_cnt_total',
                    p_old_numerator     => 'p_ship_confirm_cnt_total',
                    p_denominator       => 'p_ship_confirm_cnt_total',
                    p_measure_name      => 'ISC_MEASURE_15') || ',
            CASE WHEN c_ship_confirm_cnt_total = 0 THEN to_number (NULL)
                 ELSE (c_release_to_ship_total*24/c_ship_confirm_cnt_total)
                 END			ISC_MEASURE_16,
            CASE WHEN c_ship_confirm_cnt_total = 0 THEN to_number(NULL)
                 WHEN p_ship_confirm_cnt_total = 0 THEN to_number(NULL)
	         ELSE ((c_release_to_ship_total*24/c_ship_confirm_cnt_total
                         - p_release_to_ship_total*24/p_ship_confirm_cnt_total))
                 END			ISC_MEASURE_17,
            CASE WHEN p_ship_confirm_cnt_total = 0 THEN to_number (NULL)
                 ELSE (p_release_to_ship_total*24/p_ship_confirm_cnt_total)
                 END			ISC_MEASURE_19
';

      RETURN l_sel_clause;

    END get_sel_clause1;


    /*--------------------------------------------------
     Function:      get_sel_clause2
     Description:   builds the outer select clause
    ---------------------------------------------------*/
    FUNCTION get_sel_clause2(p_view_by_dim IN VARCHAR2,
                                   p_join_tbl IN
                                   poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
        RETURN VARCHAR2
    IS
        l_sel_clause                VARCHAR2(32000);
        l_view_by_col_name          VARCHAR2(60);
        l_view_by_fact_col          VARCHAR2(400);
	l_inner_qty_sel_clause	    VARCHAR2(300);
	l_measure_5_desc	    VARCHAR2(300);

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
	   v.description 		ISC_ATTRIBUTE_4, -- Description
           v2.uom_code 			ISC_ATTRIBUTE_5, -- UOM
	   NULL	 			ISC_MEASURE_1, -- Quantity Pick Released
';

       	   l_measure_5_desc := '
	   oset.ISC_MEASURE_5 		ISC_MEASURE_5, -- Quantity Ship Confirmed';
           l_inner_qty_sel_clause:= 'c_ship_confirm_qty		ISC_MEASURE_5,';
        ELSE
   	   l_sel_clause := l_sel_clause || '
	   NULL	 			ISC_ATTRIBUTE_4, -- Description
           NULL 			ISC_ATTRIBUTE_5, -- UOM
	   NULL	 			ISC_MEASURE_1, -- Quantity Pick Released
';
       	   l_measure_5_desc := '
	   NULL	 			ISC_MEASURE_5, -- Quantity Ship Confirmed';
	   l_inner_qty_sel_clause:= 'NULL			ISC_MEASURE_5,';

        END IF;

   	l_sel_clause := l_sel_clause ||
'	   NULL 			ISC_MEASURE_2,
	   NULL 			ISC_MEASURE_3,
	   NULL				ISC_MEASURE_4,
';
	l_sel_clause := l_sel_clause || '
	' || l_measure_5_desc || '
	   oset.ISC_MEASURE_6		ISC_MEASURE_6,
	   oset.ISC_MEASURE_7		ISC_MEASURE_7,
	   oset.ISC_MEASURE_8		ISC_MEASURE_8,
	   oset.ISC_MEASURE_9		ISC_MEASURE_9,
	   oset.ISC_MEASURE_10		ISC_MEASURE_10,
	   oset.ISC_MEASURE_11		ISC_MEASURE_11,
	   NULL				ISC_MEASURE_12,
	   NULL		 		ISC_MEASURE_13,
	   oset.ISC_MEASURE_14		ISC_MEASURE_14,
	   oset.ISC_MEASURE_15		ISC_MEASURE_15,
	   oset.ISC_MEASURE_16		ISC_MEASURE_16,
	   oset.ISC_MEASURE_17		ISC_MEASURE_17,
	   oset.ISC_MEASURE_19		ISC_MEASURE_19
	   FROM
	   (SELECT (rank () over
	    (&ORDER_BY_CLAUSE nulls last, ' || l_view_by_fact_col || ')) - 1 rnk,
           ' || l_view_by_fact_col || ',
           ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,ISC_MEASURE_4,ISC_MEASURE_5,
           ISC_MEASURE_6,ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,
           ISC_MEASURE_11,ISC_MEASURE_14,ISC_MEASURE_15,
           ISC_MEASURE_16,ISC_MEASURE_17,ISC_MEASURE_19
              FROM
	      (SELECT
            ' || l_view_by_fact_col || ',
            NULL 			ISC_MEASURE_1,
            ' || l_inner_qty_sel_clause || '
	    NULL 			ISC_MEASURE_2,
	    NULL 			ISC_MEASURE_3,
	    NULL			ISC_MEASURE_4,
	    p_ship_confirm_cnt 		ISC_MEASURE_6,
   	    c_ship_confirm_cnt 		ISC_MEASURE_7,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_ship_confirm_cnt',
                    p_old_numerator     => 'p_ship_confirm_cnt',
                    p_denominator       => 'p_ship_confirm_cnt',
                    p_measure_name      => 'ISC_MEASURE_8') || ',
            CASE WHEN p_ship_confirm_cnt = 0 THEN to_number (NULL)
                 ELSE (p_release_to_ship*24/p_ship_confirm_cnt)
                 END			ISC_MEASURE_9,
            CASE WHEN c_ship_confirm_cnt = 0 THEN to_number (NULL)
                 ELSE (c_release_to_ship*24/c_ship_confirm_cnt)
                 END			ISC_MEASURE_10,
            CASE WHEN c_ship_confirm_cnt = 0 THEN to_number(NULL)
                 WHEN p_ship_confirm_cnt = 0 THEN to_number(NULL)
	         ELSE ((c_release_to_ship*24/c_ship_confirm_cnt
                         - p_release_to_ship*24/p_ship_confirm_cnt))
                 END			ISC_MEASURE_11,
	    c_ship_confirm_cnt_total	ISC_MEASURE_14,
            ' || isc_dbi_sutil_pkg.change_str (
                    p_new_numerator     => 'c_ship_confirm_cnt_total',
                    p_old_numerator     => 'p_ship_confirm_cnt_total',
                    p_denominator       => 'p_ship_confirm_cnt_total',
                    p_measure_name      => 'ISC_MEASURE_15') || ',
            CASE WHEN c_ship_confirm_cnt_total = 0 THEN to_number (NULL)
                 ELSE (c_release_to_ship_total*24/c_ship_confirm_cnt_total)
                 END			ISC_MEASURE_16,
            CASE WHEN c_ship_confirm_cnt_total = 0 THEN to_number(NULL)
                 WHEN p_ship_confirm_cnt_total = 0 THEN to_number(NULL)
	         ELSE ((c_release_to_ship_total*24/c_ship_confirm_cnt_total
                         - p_release_to_ship_total*24/p_ship_confirm_cnt_total))
                 END			ISC_MEASURE_17,
            CASE WHEN p_ship_confirm_cnt_total = 0 THEN to_number (NULL)
                 ELSE (p_release_to_ship_total*24/p_ship_confirm_cnt_total)
                 END			ISC_MEASURE_19
';

      RETURN l_sel_clause;

    END get_sel_clause2;

END ISC_DBI_WMS_PTS_PKG;

/
