--------------------------------------------------------
--  DDL for Package Body OKI_DBI_SRM_BKRNWL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_SRM_BKRNWL_PVT" AS
/* $Header: OKIIBKGB.pls 120.1 2006/03/28 23:26:44 asparama noship $ */

FUNCTION get_book_start_2way_sql (
    l_book_where               IN       VARCHAR2
  , l_start_where              IN       VARCHAR2
  , l_viewby_col_special       IN       VARCHAR2
  , l_view_by_col              IN       VARCHAR2
  , l_cur_suffix               IN       VARCHAR2)
  RETURN VARCHAR2;

FUNCTION get_trend_sel_clause
  RETURN VARCHAR2;

FUNCTION get_table_sel_clause (
	p_view_by_dim     IN   VARCHAR2
      , p_view_by_col             IN   VARCHAR2)
   RETURN VARCHAR2;

FUNCTION get_col_name (p_dim_name VARCHAR2)
  RETURN VARCHAR2;


  /*******************************************************************************
     Procedure: get_rates_table_sql
              Description: Procedure to retrieve the sql statement for
	      the Booking to Renewal Ratios Drill Down Report
   *******************************************************************************/

PROCEDURE get_rates_table_sql(
	p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
	x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS

    l_query                  VARCHAR2 (32767);
    l_view_by                VARCHAR2 (120);
    l_view_by_col            VARCHAR2 (120);
    l_as_of_date             DATE;
    l_prev_as_of_date        DATE;
    l_xtd                    VARCHAR2 (10);
    l_comparison_type        VARCHAR2 (1) ;
    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2 (2);
    l_where_clause           VARCHAR2 (2000);
    l_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed    VARCHAR2 (3);
    l_to_date_xtd    VARCHAR2 (3);
    l_view_by_table          VARCHAR2(1000);


    l_viewby_select      VARCHAR2(10000);
    l_url_select         VARCHAR2(20000);
    l_book_where 	 VARCHAR2(10000);
    l_start_where        VARCHAR2(10000);
    l_VIEWBY_RANK_ORDER  VARCHAR2(10000);
    l_viewby_col_special VARCHAR2(60); -- Needed when the view by is resource group id
    l_filter_where       VARCHAR2(10000);
    l_prodcat_url        VARCHAR2(300);

  BEGIN
    l_to_date_xed       := 'XED';
    l_to_date_xtd       := 'XTD';
    l_comparison_type   := 'Y';
    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();


    oki_dbi_util_pvt.process_parameters ( p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause
                                        , p_mv                  => l_mv
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'N'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_DET'
                                        , p_rg_where            => 'Y');

   l_view_by_table            :=  oki_dbi_util_pvt.get_table(dim_name => l_view_by
                                                            ,p_func_area => 'SRM'
                                                            ,p_version   => '6.0' );

    IF(l_view_by = 'ITEM+ENI_ITEM_VBH_CAT')
    THEN
       l_prodcat_url :=
           'decode(leaf_node_flag,''Y'',
                 ''pFunctionName=OKI_DBI_SRM_BTS_RATE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM'',
                 ''pFunctionName=OKI_DBI_SRM_BTS_RATE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT'' ) OKI_DYNAMIC_URL_4 ';
    ELSE
       l_prodcat_url := ''''' OKI_DYNAMIC_URL_4 ';
    END IF;

    l_viewby_select := oki_dbi_util_pvt.get_viewby_select_clause(l_view_by, 'SRM', '6.0');


   /* Additional filter needed to avoid displaying records queried due to total values at node */

   l_filter_where  := ' AND ( ABS(oki_measure_1) +
                              ABS(oki_measure_2) +
	            		      ABS(oki_measure_3) +
            			      ABS(oki_measure_4) +
            			      ABS(oki_measure_5) +
            			      ABS(oki_measure_6) ) <> 0';

    l_viewby_select  :=  l_viewby_select ||
   ', OKI_DYNAMIC_URL_1 ,'|| l_prodcat_url ||',oki_measure_1 ,oki_measure_2 ,oki_calc_item1, oki_measure_3
    ,oki_measure_4, oki_calc_item2,oki_calc_item2 oki_calc_item4, oki_measure_5 ,oki_measure_6 ,oki_calc_item3
    , oki_calc_item3 oki_calc_item5, oki_measure_11 ,oki_measure_12 ,oki_measure_13 ,oki_measure_14
    ,oki_measure_15,oki_measure_16 ,oki_measure_17, oki_measure_18, oki_measure_19
     FROM (
     SELECT rank() over (&ORDER_BY_CLAUSE nulls last , '||l_view_by_col||') - 1 rnk ,'||l_view_by_col||'
    ,OKI_DYNAMIC_URL_1 ,oki_measure_1 ,oki_measure_2 ,oki_calc_item1 ,oki_measure_3 ,oki_measure_4 ,oki_calc_item2
    ,oki_measure_5 ,oki_measure_6 ,oki_calc_item3 ,oki_measure_11 ,oki_measure_12 ,oki_measure_13 ,oki_measure_14
    ,oki_measure_15 ,oki_measure_16,oki_measure_17,oki_measure_18, oki_measure_19
     FROM ( ';

   /* Dynamic URL's  */
   IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP'
   THEN
    l_url_select     :=
          'SELECT  decode(resource_id,-999,''pFunctionName=OKI_DBI_SRM_BTS_RATE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'','''') OKI_DYNAMIC_URL_1 ';
    l_viewby_col_special := ' imm_child_rg_id ';
   ELSE
    l_url_select := ' SELECT NULL OKI_DYNAMIC_URL_1 ';
    l_viewby_col_special := NULL ;
   END IF;

   /* From and Joins */
   IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP'
   THEN
      l_book_where := '
          FROM    '||l_mv ||' fact
          WHERE   fact.mx_id = 4
                  AND fact.renewal_flag IN (1,3)
                  AND fact.activity_date BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
                                             AND &BIS_CURRENT_ASOF_DATE'
          || l_where_clause || '
          GROUP BY imm_child_rg_id, resource_id ';

      l_start_where := '
          FROM    '||l_mv ||' fact
          WHERE   fact.mx_id = 5
                  AND fact.renewal_flag IN (1,3)
                  AND fact.activity_date BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
                                             AND &BIS_CURRENT_ASOF_DATE'
          || l_where_clause || '
          GROUP BY imm_child_rg_id, resource_id ';
   ELSE
      l_book_where := '
          FROM     '||l_mv ||' fact
          WHERE   fact.mx_id = 4
          AND     fact.renewal_flag IN (1,3)
          AND     fact.activity_date BETWEEN   &BIS_CURRENT_EFFECTIVE_START_DATE
                                       AND   &BIS_CURRENT_ASOF_DATE '
          || l_where_clause || '
          GROUP BY  ' ||l_view_by_col ;

      l_start_where := '
          FROM     '||l_mv ||' fact
          WHERE   fact.mx_id = 5
          AND     fact.renewal_flag IN (1,3)
          AND     fact.activity_date BETWEEN   &BIS_CURRENT_EFFECTIVE_START_DATE
                                       AND   &BIS_CURRENT_ASOF_DATE '
          || l_where_clause || '
          GROUP BY  ' ||l_view_by_col ;
   END IF;


   IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP'
   THEN
    l_VIEWBY_RANK_ORDER  :=
         ')oset05)oset10))oset ,'
      || 'jtf_rs_groups_vl g, jtf_rs_resource_extns_vl r '
      || 'where oset.rg_id=g.group_id and oset.resource_id=r.resource_id(+)  '
      || l_filter_where || '
      AND (rnk BETWEEN &START_INDEX and &END_INDEX or &END_INDEX = -1)
      &ORDER_BY_CLAUSE nulls last ';
   ELSE
    l_VIEWBY_RANK_ORDER  :=
         ')oset05)oset10))oset ,'
      || l_view_by_table || ' v
      WHERE v.id = oset.'||l_view_by_col|| l_filter_where || '
      AND (rnk BETWEEN &START_INDEX and &END_INDEX or &END_INDEX = -1)
      &ORDER_BY_CLAUSE nulls last ';
   END IF;
/*
   l_VIEWBY_RANK_ORDER  :=
         ')oset05)oset10))oset ,'
      || l_view_by_table || ' v
      WHERE v.id = oset.'||l_view_by_col|| l_filter_where || '
      AND (rnk BETWEEN &START_INDEX and &END_INDEX or &END_INDEX = -1)
      &ORDER_BY_CLAUSE nulls last ';
*/
    l_query := l_viewby_select || l_url_select ||' ,'||
    -- Generate sql query
       l_view_by_col || ',' ||
      'oset10.booked_val OKI_MEASURE_1,
       oset10.start_val OKI_MEASURE_2,
       oset10.val_rate OKI_CALC_ITEM1,
       oset10.booked_lcount OKI_MEASURE_3,
       oset10.start_lcount OKI_MEASURE_4,
       oset10.lcount_rate OKI_CALC_ITEM2,
       oset10.booked_hcount OKI_MEASURE_5,
       oset10.start_hcount OKI_MEASURE_6,
       oset10.hcount_rate OKI_CALC_ITEM3,
       oset10.booked_val_tot OKI_MEASURE_11,
       oset10.start_val_tot OKI_MEASURE_12,
       oset10.val_rate_tot OKI_MEASURE_13,
       oset10.booked_lcount_tot OKI_MEASURE_14,
       oset10.start_lcount_tot OKI_MEASURE_15,
       oset10.lcount_rate_tot OKI_MEASURE_16,
       oset10.booked_hcount_tot OKI_MEASURE_17,
       oset10.start_hcount_tot OKI_MEASURE_18,
       oset10.hcount_rate_tot OKI_MEASURE_19
   FROM
   (
     SELECT '|| l_view_by_col || ',
         nvl(oset05.booked_val,0) booked_val,
         nvl(oset05.starting_val,0) start_val,
         oset05.booked_val/decode(oset05.starting_val,0,NULL,oset05.starting_val) val_rate,
         nvl(oset05.booked_lcount,0) booked_lcount,
         nvl(oset05.starting_lcount,0) start_lcount,
         oset05.booked_lcount /decode( oset05.starting_lcount,0,NULL,oset05.starting_lcount) lcount_rate,
         nvl(oset05.booked_hcount,0) booked_hcount,
         nvl(oset05.starting_hcount,0) start_hcount,
         oset05.booked_hcount /decode( oset05.starting_hcount,0,NULL,oset05.starting_hcount) hcount_rate,
         nvl(oset05.booked_val_tot,0) booked_val_tot,
         nvl(oset05.starting_val_tot,0) start_val_tot,
         oset05.booked_val_tot/decode(oset05.starting_val_tot,0,NULL,oset05.starting_val_tot) val_rate_tot,
         nvl(oset05.booked_lcount_tot,0) booked_lcount_tot,
         nvl(oset05.starting_lcount_tot,0) start_lcount_tot,
         oset05.booked_lcount_tot /decode( oset05.starting_lcount_tot,0,NULL,oset05.starting_lcount_tot) lcount_rate_tot,
         nvl(oset05.booked_hcount_tot,0) booked_hcount_tot,
         nvl(oset05.starting_hcount_tot,0) start_hcount_tot,
         oset05.booked_hcount_tot /decode( oset05.starting_hcount_tot,0,NULL,oset05.starting_hcount_tot) hcount_rate_tot
     FROM
      ('||
      		get_book_start_2way_sql( l_book_where,
		                        l_start_where,
				        l_viewby_col_special,
				        l_view_by_col,
				        l_cur_suffix )
        || l_VIEWBY_RANK_ORDER;

    x_custom_sql               := '/* OKI_DBI_SRM_BTS_RATE_DRPT */'||l_query;
    oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

END get_rates_table_sql;
-----------------------------------------------------------

  FUNCTION get_book_start_2way_sql (
    l_book_where               IN       VARCHAR2
  , l_start_where              IN       VARCHAR2
  , l_viewby_col_special       IN       VARCHAR2
  , l_view_by_col              IN       VARCHAR2
  , l_cur_suffix               IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_select  varchar2(32767);
    l_query1  varchar2(32767);
    l_query2  varchar2(32767);
    l_join_column1 varchar2(50);
    l_join_column2 varchar2(50);
    l_query    varchar2(32767);
  BEGIN
  --  l_select := l_view_by_col||',
    l_select := 'sum(booked_val)          booked_val,
                 sum(booked_hcount)       booked_hcount,
                 sum(booked_lcount)       booked_lcount,
                 sum(booked_val_tot)      booked_val_tot,
                 sum(booked_hcount_tot)   booked_hcount_tot,
                 sum(booked_lcount_tot)   booked_lcount_tot,
                 sum(starting_val)        starting_val,
                 sum(starting_hcount)     starting_hcount,
                 sum(starting_lcount)     starting_lcount,
                 sum(starting_val_tot)    starting_val_tot,
                 sum(starting_hcount_tot) starting_hcount_tot,
                 sum(starting_lcount_tot) starting_lcount_tot ';

   l_query1  :=
     ' SELECT '|| l_viewby_col_special ||l_view_by_col ||',
          NVL(SUM(fact.price_nego_' || l_cur_suffix || '),0) booked_val,
          NVL(COUNT(distinct(fact.chr_id)),0) booked_hcount,
          NVL(COUNT(distinct(fact.cle_id)),0) booked_lcount,
          NVL(SUM(SUM(fact.price_nego_' || l_cur_suffix || ')) over (),0) booked_val_tot,
          NVL(SUM(COUNT(distinct(fact.chr_id))) over (),0) booked_hcount_tot,
	  NVL(SUM(COUNT(distinct(fact.cle_id))) over (),0) booked_lcount_tot,
	  to_number(null) starting_val,
	  to_number(null) starting_hcount,
	  to_number(null) starting_lcount,
	  to_number(null) starting_val_tot,
	  to_number(null) starting_hcount_tot,
	  to_number(null) starting_lcount_tot '||
          l_book_where;

   l_query2  :=
     ' SELECT '|| l_viewby_col_special ||l_view_by_col ||',
          to_number(null) booked_val,
          to_number(null) booked_hcount,
          to_number(null) booked_lcount,
          to_number(null) booked_val_tot,
          to_number(null) booked_hcount_tot,
          to_number(null) booked_lcount_tot,
          NVL(SUM(fact.price_nego_' || l_cur_suffix || '),0) starting_val,
          NVL(COUNT(distinct(fact.chr_id)),0) starting_hcount,
          NVL(COUNT(distinct(fact.cle_id)),0) starting_lcount,
          NVL(SUM(SUM(fact.price_nego_' || l_cur_suffix || ')) over (),0) starting_val_tot,
          NVL(SUM(COUNT(distinct(fact.chr_id))) over (),0) starting_hcount_tot,
          NVL(SUM(COUNT(distinct(fact.cle_id))) over (),0) starting_lcount_tot '||
          l_start_where;

   l_join_column1  := l_view_by_col;
   l_join_column2  := l_view_by_col;

   l_query := oki_dbi_util_pvt.two_way_join (l_select, l_query1, l_query2,l_join_column1, l_join_column1);
   RETURN l_query;

END get_book_start_2way_sql;

  /*******************************************************************************
     Procedure: get_table_sql
              Description: Procedure to retrieve the sql statement for
	      the Booking to Renewals Activity Portlet/Report
   *******************************************************************************/

PROCEDURE get_table_sql(
	p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
	x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_query 		VARCHAR2 (10000);
	l_view_by		VARCHAR2 (120);
	l_view_by_col		VARCHAR2 (120);
	l_as_of_date		DATE;
	l_prev_as_of_date	DATE;
	l_xtd1			VARCHAR2 (10);
	l_xtd2			VARCHAR2 (10);
	l_comparison_type	VARCHAR2 (1);
	l_period_type           VARCHAR2(10);
	l_nested_pattern	NUMBER;
	l_cur_suffix		VARCHAR2 (2);
	l_custom_sql		VARCHAR2 (10000);
	l_where_clause          VARCHAR2 (2000);
	l_filter_where           VARCHAR2 (240);
	l_mv1                    VARCHAR2 (2000);
	l_mv2                    VARCHAR2 (2000);
	l_col_tbl1		poa_dbi_util_pkg.poa_dbi_col_tbl;
	l_col_tbl2		poa_dbi_util_pkg.poa_dbi_col_tbl;
	l_mv_tbl                 poa_dbi_util_pkg.poa_dbi_mv_tbl;
	l_join_tbl		poa_dbi_util_pkg.poa_dbi_join_tbl;
        l_to_date_xed    VARCHAR2 (3);
        l_to_date_xtd    VARCHAR2 (3);
	l_viewby_rank_where      VARCHAR2(32767);
        l_sql                    VARCHAR2(32767);
        l_temp                   LONG;
BEGIN
/*	x_custom_output := bis_query_attributes_tbl();
	l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;

 DEBUG - brrao added
 --    OKI_DBIDEBUG_PVT.check_portal_param('OKI_DBI_SRM_KAPILT',p_param);

*/
    l_to_date_xed       := 'XED';
    l_to_date_xtd       := 'XTD';
    l_comparison_type   := 'Y';
    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl1                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();
    l_col_tbl2                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();
    l_mv_tbl            := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

   oki_dbi_util_pvt.process_parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd1
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause
                                        , p_mv                  => l_mv1
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'N'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_SG_71'
                                        , p_rg_where            => 'Y');

poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                                   , p_col_name        => 'g_r_amt_' || l_cur_suffix
                                   , p_alias_name      => 'booked'
                                   , p_to_date_type    => l_to_date_xtd);
 l_mv_tbl.extend;
  l_mv_tbl(1).mv_name := l_mv1;
  l_mv_tbl(1).mv_col := l_col_tbl1;
  l_mv_tbl(1).mv_where := l_where_clause;
  l_mv_tbl(1).in_join_tbls := NULL;
  l_mv_tbl(1).use_grp_id := 'N';

    oki_dbi_util_pvt.process_parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd2
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause
                                        , p_mv                  => l_mv2
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'N'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_ST_71'
                                        , p_rg_where            => 'Y');


	/*
	poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                                   , p_col_name        => 'g_r_amt_n_' || l_cur_suffix
                                   , p_alias_name      => 'booked_n'
                                   , p_to_date_type    => l_to_date_xtd);

	poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                                   , p_col_name        => 'g_r_amt_t_' || l_cur_suffix
                                   , p_alias_name      => 'booked_t'
                                   , p_to_date_type    => l_to_date_xtd);

	poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                                   , p_col_name        => 's_r_amt_n_' || l_cur_suffix
                                   , p_alias_name      => 'started_n'
                                   , p_to_date_type    => l_to_date_xtd);

	poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                                   , p_col_name        => 's_r_amt_t_' || l_cur_suffix
                                   , p_alias_name      => 'started_t'
                                   , p_to_date_type    => l_to_date_xtd);

*/
		poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl2
                                   , p_col_name        => 's_r_amt_' || l_cur_suffix
                                   , p_alias_name      => 'started'
                                   , p_to_date_type    => l_to_date_xtd);

   /* Additional filter needed to avoid displaying records queried due to total values at node */



  l_mv_tbl.extend;
  l_mv_tbl(2).mv_name := l_mv2;
  l_mv_tbl(2).mv_col := l_col_tbl2;
  l_mv_tbl(2).mv_where := l_where_clause;
  l_mv_tbl(2).in_join_tbls := NULL;
  l_mv_tbl(2).use_grp_id := 'N';

   l_filter_where  := ' ( ABS(oki_measure_1) + ABS(oki_measure_2) ) <> 0';

	l_query :=
	poa_dbi_template_pkg.union_all_status_sql
		                        	 (p_mv              => l_mv_tbl,
                                                  p_join_tables     => l_join_tbl,
                                                  p_use_windowing   => 'Y',
                                                  p_paren_count     => 5,
                                                  p_filter_where    => NULL,
						  p_generate_viewby => 'N');
l_viewby_rank_where :=  ' WHERE ' || l_filter_where || ')oset , '||
      poa_dbi_template_pkg.get_viewby_rank_clause ( p_join_tables       => l_join_tbl
                                                  , p_use_windowing     => 'Y'
                                                  );

 l_query     :=
	get_table_sel_clause (l_view_by, l_view_by_col) ||
	l_query||l_viewby_rank_where;
		/* poa_dbi_template_pkg.status_sql (
	--		p_nested_pattern	=> l_nested_pattern
		       p_fact_name		=> l_mv
		      , p_where_clause		=> l_where_clause
		      , p_filter_where  	=> l_filter_where
		      , p_join_tables		=> l_join_tbl
		      , p_use_windowing		=> 'Y'
		      , p_col_name		=> l_col_tbl
		      , p_use_grpid		=> 'N'
		      , p_paren_count		=> 6);
*/
	x_custom_sql := '/* OKI_DBI_SRM_BTS_RATIO_RPT */' || l_query;
	oki_dbi_util_pvt.get_custom_status_binds(x_custom_output);
 /* DEBUG - brrao added */
 --    OKI_DBIDEBUG_PVT.check_portal_value('OKI_DBI_SRM_KAPILT','SQL',x_custom_sql);
  --   COMMIT;

END get_table_sql;

  /*******************************************************************************
     Procedure: get_trend_sql
              Description: Procedure to retrieve the sql statement for
	      the Booking to Renewals Ratio Trend Portlet/Report
   *******************************************************************************/

  PROCEDURE get_trend_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl)
  IS
    l_query             VARCHAR2 (10000);
    l_view_by           VARCHAR2 (120);
    l_view_by_col       VARCHAR2 (120);
    l_as_of_date        DATE;
    l_prev_as_of_date   DATE;
    l_xtd1               VARCHAR2 (10);
    l_xtd2               VARCHAR2 (10);
    l_comparison_type   VARCHAR2 (1);
    l_period_type       VARCHAR2(10);
    l_nested_pattern    NUMBER;
    l_cur_suffix        VARCHAR2 (2);
    l_custom_sql        VARCHAR2 (10000);
    l_where_clause      VARCHAR2 (2000);
    l_mv1                VARCHAR2 (2000);
    l_mv2                VARCHAR2 (2000);
    l_col_tbl1		poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl2		poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl		poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_mv_tbl                 poa_dbi_util_pkg.poa_dbi_mv_tbl;
    l_to_date_xed    VARCHAR2 (3);
    l_to_date_xtd    VARCHAR2 (3);
  BEGIN
 /*
    x_custom_output    := bis_query_attributes_tbl ();
    l_custom_rec       := bis_pmv_parameters_pub.initialize_query_type;
*/
    l_to_date_xed       := 'XED';
    l_to_date_xtd       := 'XTD';
    l_comparison_type   := 'Y';
    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl1                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();
    l_col_tbl2                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();

    l_mv_tbl            := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

    oki_dbi_util_pvt.process_parameters ( p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd1
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause
                                        , p_mv                  => l_mv1
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_SG_71'
                                        , p_rg_where            => 'Y');




	poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                                   , p_col_name        => 'g_r_amt_' || l_cur_suffix
                                   , p_alias_name      => 'booked'
				   , p_grand_total     => 'N'
                                   , p_to_date_type    => l_to_date_xtd);

 l_mv_tbl.extend;
  l_mv_tbl(1).mv_name := l_mv1;
  l_mv_tbl(1).mv_col := l_col_tbl1;
  l_mv_tbl(1).mv_where := l_where_clause;
  l_mv_tbl(1).in_join_tbls := NULL;
  l_mv_tbl(1).use_grp_id := 'N';
  l_mv_tbl(1).mv_xtd :=  l_xtd1;

	oki_dbi_util_pvt.process_parameters ( p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd2
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause
                                        , p_mv                  => l_mv2
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_ST_71'
                                        , p_rg_where            => 'Y');

	poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl2
                                   , p_col_name        => 's_r_amt_' || l_cur_suffix
                                   , p_alias_name      => 'started'
				   , p_grand_total     => 'N'
                                   , p_to_date_type    => l_to_date_xtd);


  l_mv_tbl.extend;
  l_mv_tbl(2).mv_name := l_mv2;
  l_mv_tbl(2).mv_col := l_col_tbl2;
  l_mv_tbl(2).mv_where := l_where_clause;
  l_mv_tbl(2).in_join_tbls := NULL;
  l_mv_tbl(2).use_grp_id := 'N';
  l_mv_tbl(2).mv_xtd := l_xtd2;

    l_query := get_trend_sel_clause || ' from '
       ||poa_dbi_template_pkg.union_all_trend_sql
		                                 (p_mv              => l_mv_tbl,
                                                  p_comparison_type   => 'R',
                                                  p_filter_where    => NULL);

       /*poa_dbi_template_pkg.trend_sql (   l_xtd
                                            , l_comparison_type
					    , l_mv
                                            , l_where_clause
                                            , l_col_tbl
                                            , 'R');
                                        	/*  , l_as_of_date
                                            , l_prev_as_of_date
                                            , l_nested_pattern);*/
   x_custom_sql  := '/* OKI_DBI_SRM_BTS_RATIO_G  */'||l_query;
--   x_custom_sql := 'select 1 VIEWBY, 1 OKI_MEASURE_1, 2 OKI_MEASURE_2, 2 OKI_MEASURE_3 from dual';
    oki_dbi_util_pvt.get_custom_trend_binds (l_xtd1
                                           , l_comparison_type
                                           , x_custom_output);

  END get_trend_sql;

  FUNCTION get_col_name (p_dim_name  VARCHAR2)
    RETURN VARCHAR2
  IS
    l_col_name   VARCHAR2 (100);
  BEGIN
    l_col_name := (CASE p_dim_name
                   WHEN 'ORGANIZATION+JTF_ORG_SALES_GROUP'
                   THEN 'prg_id'
                   ELSE ''
                   END);
    RETURN l_col_name;
  END get_col_name;

  FUNCTION get_trend_sel_clause
    RETURN VARCHAR2
  IS
    l_sel_clause   VARCHAR2 (10000);
  BEGIN

/* Removed NVL clauses from the query because of bug 3123830--ARUN */

    l_sel_clause   :=
      'SELECT cal_NAME AS VIEWBY
          , (uset.p_booked) / DECODE (uset.p_started, 0, NULL, uset.p_started)
					            oki_measure_1
          , (uset.c_booked) / DECODE (uset.c_started, 0, NULL, uset.c_started)
                oki_measure_2
          , (uset.c_booked / DECODE (uset.c_started, 0, NULL, uset.c_started))
            -(uset.p_booked / DECODE (uset.p_started, 0, NULL, uset.p_started))
              oki_measure_3';
    RETURN l_sel_clause;
  END get_trend_sel_clause;

/*****************************************************************
  Booking to Renewal Activity SQL Select clause

*******************************************************************/

  FUNCTION get_table_sel_clause (
  	p_view_by_dim 	IN 	VARCHAR2
      , p_view_by_col		IN 	VARCHAR2)
      RETURN VARCHAR2
  IS
    l_sel_clause	 VARCHAR2 (10000);
    l_bookings_url       VARCHAR2(300);
    l_prodcat_url        VARCHAR2(300);
    l_viewby_select      VARCHAR2(10000);
    l_url_select         VARCHAR2(10000);
  BEGIN

    l_viewby_select := oki_dbi_util_pvt.get_viewby_select_clause(p_view_by_dim, 'SRM', '6.0');
    l_bookings_url  := '''pFunctionName=OKI_DBI_SRM_RSBK_DTL_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP''';

 --   l_rate_url := '''pFunctionName=OKI_DBI_SRM_BTS_RATE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP''';

    IF(p_view_by_dim = 'ITEM+ENI_ITEM_VBH_CAT')
    THEN
    	l_prodcat_url :=
           ' decode(leaf_node_flag,''Y''
           , ''pFunctionName=OKI_DBI_SRM_BTS_RATIO_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM''
           ,''pFunctionName=OKI_DBI_SRM_BTS_RATIO_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT'' ) OKI_DYNAMIC_URL_4 ';
    ELSE
       l_prodcat_url := 'NULL OKI_DYNAMIC_URL_4 ';
    END IF;

   l_viewby_select  :=  l_viewby_select ||
      ', OKI_DYNAMIC_URL_1 ,OKI_DYNAMIC_URL_3, '|| l_prodcat_url || '
      ,OKI_MEASURE_1 ,OKI_MEASURE_2 ,OKI_CALC_ITEM1 ,OKI_CALC_ITEM2
      ,OKI_CALC_ITEM3 ,OKI_CALC_ITEM4 ,OKI_CALC_ITEM5 ,OKI_CALC_ITEM6,oki_measure_3
      ,OKI_MEASURE_4, oki_measure_5, OKI_CALC_ITEM7, OKI_CALC_ITEM8,OKI_CALC_ITEM17
      ,OKI_CALC_ITEM18, oki_measure_15, OKI_MEASURE_18, OKI_MEASURE_19
       FROM
       (SELECT
           rank() over (&ORDER_BY_CLAUSE nulls last,
	   '||p_view_by_col||') - 1 rnk
	   ,'||p_view_by_col||',OKI_DYNAMIC_URL_1
	   ,OKI_DYNAMIC_URL_3 ,OKI_MEASURE_1 ,OKI_MEASURE_2
	   ,OKI_CALC_ITEM1 ,OKI_CALC_ITEM2 ,OKI_CALC_ITEM3
	   ,OKI_CALC_ITEM4 ,OKI_CALC_ITEM5 ,OKI_CALC_ITEM6,oki_measure_3,OKI_MEASURE_4
	   ,'||POA_DBI_UTIL_PKG.rate_clause('oki_measure_2','oki_calc_item4') || ' oki_measure_5
	   ,OKI_CALC_ITEM7, OKI_CALC_ITEM8,OKI_CALC_ITEM17, OKI_CALC_ITEM18,
           SUM( '||POA_DBI_UTIL_PKG.rate_clause('oki_measure_2','oki_calc_item4') || ') over() oki_measure_15
	   ,OKI_CALC_ITEM8 OKI_MEASURE_18, OKI_CALC_ITEM18 OKI_MEASURE_19
       FROM ( ';

 -- ,''pFunctionName=OKI_DBI_SRM_BTS_RATE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'' OKI_DYNAMIC_URL_2
 --    ,  decode(resource_id,-999,'''','|| l_bookings_url || ') OKI_DYNAMIC_URL_3 ';

    IF(p_view_by_dim = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
    THEN
       l_url_select :=
          'SELECT  decode(resource_id,-999,''pFunctionName=OKI_DBI_SRM_BTS_RATIO_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'','''') OKI_DYNAMIC_URL_1' ||
       ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_bookings_url||')) OKI_DYNAMIC_URL_3 ';
    ELSIF(p_view_by_dim = 'ITEM+ENI_ITEM')
    THEN
       l_url_select :=
           ' SELECT NULL OKI_DYNAMIC_URL_1
          , '||l_bookings_url||' OKI_DYNAMIC_URL_3 ';
    ELSE

/* brrao added for documentation */
    -- OKI_DYNAMIC_URL_1 (sales group URL)
    -- OKI_DYNAMIC_URL_2 (Booking to Renewal Ratio DD URL link)
    -- OKI_DYNAMIC_URL_3 (Bookings Column URL)
    -- OKI_DYNAMIC_URL_4 (product Category URL if present)
    -- OKI_MEASURE_1     (Renewals Value)
    -- OKI_MEASURE_2     (Booked Value Column)
    -- OKI_CALC_ITEM1    (Book to Renewal Ratio)
    -- OKI_CALC_ITEM2    (Book to Renewal Ratio Change)
    -- OKI_CALC_ITEM3    (Renewals Value TOTAL)
    -- OKI_CALC_ITEM4    (Booked Value TOTAL)
    -- OKI_CALC_ITEM5    (Book to Renewal Ratio TOTAL)
    -- OKI_CALC_ITEM6    (Book to Renewal Ratio Change TOTAL)
    -- OKI_MEASURE_3     (Book to Renewal Ratio - Current Graph) not used superflous column --
    -- OKI_MEASURE_4     (Book to Renewal Ratio - Prior Graph)
    -- OKI_CALC_ITEM7    (Book to Renewal Ratio - Current KPI)
    -- OKI_CALC_ITEM17   (Book to Renewal Ratio - Current TOTAL KPI)
    -- OKI_CALC_ITEM8    (Book to Renewal Ratio - Prior KPI)
    -- OKI_CALC_ITEM18   (Book to Renewal Ratio - Prior TOTAL KPI)
    -- OKI_MEASURE_18    (Book to Renewal Ratio - Prior KPI )
    -- OKI_MEASURE_19    (Book to Renewal Ratio - Prior TOTAL for measure 18)

       l_url_select :=
           ' SELECT NULL OKI_DYNAMIC_URL_1
          , '''' OKI_DYNAMIC_URL_3 ';
       END IF;
            l_sel_clause := l_viewby_select || l_url_select ||
                  '  ,'|| p_view_by_col ||
	          '  , oset20.rnwl_started oki_measure_1
		     , oset20.rnwl_booked oki_measure_2
		     , oset20.c_rnwl_rate oki_calc_item1
		     , oset20.rnwl_rate_chg oki_calc_item2
	             , oset20.rnwl_started_tot oki_calc_item3
		     , oset20.rnwl_booked_tot oki_calc_item4
		     , oset20.rnwl_rate_tot oki_calc_item5
		     , oset20.rnwl_rate_chg_tot oki_calc_item6
		     , oset20.c_rnwl_rate oki_measure_3
		     , oset20.p_rnwl_rate oki_measure_4
                     ,'||POA_DBI_UTIL_PKG.rate_clause('oset20.rnwl_booked','oset20.rnwl_booked_tot') || ' oki_measure_5
		     , oset20.c_rnwl_rate oki_calc_item7
		     , oset20.rnwl_rate_tot oki_calc_item17
		     , oset20.p_rnwl_rate oki_calc_item8
		     , oset20.p_rnwl_rate_tot oki_calc_item18
	       FROM
	            (SELECT '
		    	  || p_view_by_col ||'
                           , oset15.rnwl_booked
			   , oset15.rnwl_started
                           , oset15.c_rnwl_rate
			   , oset15.p_rnwl_rate
			   , oset15.rnwl_rate_chg
                           , oset15.rnwl_booked_tot
			   , oset15.rnwl_started_tot
                           , oset15.rnwl_rate_tot
                           , oset15.p_rnwl_rate_tot
			   , oset15.rnwl_rate_chg_tot
		     FROM
		     	(SELECT '|| p_view_by_col || '
                                 , oset10.c_rnwl_booked rnwl_booked
				 , oset10.c_rnwl_started rnwl_started
                                 , oset10.c_rnwl_rate c_rnwl_rate
                                 , oset10.p_rnwl_rate p_rnwl_rate
                                 ,'||OKI_DBI_UTIL_PVT.change_clause('oset10.c_rnwl_Rate',
                                                       'oset10.p_rnwl_Rate','P') || 'rnwl_rate_chg
			         , oset10.c_rnwl_booked_tot rnwl_booked_tot
				 , oset10.c_rnwl_started_tot rnwl_started_tot
                                 , oset10.c_rnwl_Rate_total rnwl_rate_tot
                                 , oset10.p_rnwl_Rate_total p_rnwl_rate_tot
                                 ,'||OKI_DBI_UTIL_PVT.change_clause('oset10.c_rnwl_Rate_total',
                                                       'oset10.p_rnwl_Rate_total','P') || 'rnwl_rate_chg_tot
             FROM
	         (SELECT oset05.' || p_view_by_col || '
		       , nvl(oset05.c_started,0) c_rnwl_started
		       , nvl(oset05.c_booked,0) c_rnwl_booked
		       , nvl(oset05.p_started,0) p_rnwl_started
		       , nvl(oset05.p_booked,0) p_rnwl_booked
                       , '||POA_DBI_UTIL_PKG.rate_clause('NVL(oset05.c_booked,0)','oset05.c_started','NP') || 'c_rnwl_Rate
                       , '||POA_DBI_UTIL_PKG.rate_clause('NVL(oset05.p_booked,0)','oset05.p_started','NP') || 'p_rnwl_Rate
	               , nvl(oset05.c_booked_total,0) c_rnwl_booked_tot
		       , nvl(oset05.p_booked_total,0) p_rnwl_booked_tot
                       , nvl(oset05.c_started_total,0) c_rnwl_started_tot
		       , nvl(oset05.p_started_total,0) p_rnwl_started_tot
                       , '||POA_DBI_UTIL_PKG.rate_clause('NVL(oset05.c_booked_total,0)', 'oset05.c_started_total','NP') || 'c_rnwl_Rate_total
                       , '||POA_DBI_UTIL_PKG.rate_clause('NVL(oset05.p_booked_total,0)', 'oset05.p_started_total','NP') || 'p_rnwl_Rate_total  from (';


    RETURN l_sel_clause;
  END get_table_sel_clause;
END OKI_DBI_SRM_BKRNWL_PVT;

/
