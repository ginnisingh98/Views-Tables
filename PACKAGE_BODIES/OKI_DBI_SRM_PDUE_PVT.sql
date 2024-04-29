--------------------------------------------------------
--  DDL for Package Body OKI_DBI_SRM_PDUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_SRM_PDUE_PVT" AS
/* $Header: OKIIPDUB.pls 120.1 2005/10/09 11:24:39 kamsharm noship $ */

   FUNCTION get_table_sel_clause (
      p_view_by_dim               IN       VARCHAR2
    , p_view_by_col               IN       VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION get_ytd_sel_clause (
      p_view_by_dim               IN       VARCHAR2
    , p_view_by_col               IN       VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION get_itdytd_2way_join(
     p_blgopn_itd_sql             IN       VARCHAR2
   , p_blgopn_ytd_sql             IN       VARCHAR2
   , l_view_by_col                IN       VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION get_blgopn_itd_sql (
       p_param  IN bis_pmv_page_parameter_tbl)
   RETURN VARCHAR2;

   FUNCTION get_pdue_open_2way_sql (
       l_pastdue_where            IN       VARCHAR2
     , l_open_where               IN       VARCHAR2
     , l_viewby_col_special       IN       VARCHAR2
     , l_view_by_col              IN       VARCHAR2
     , l_cur_suffix               IN       VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION get_pduernwldetail_sel_clause (
      p_cur_suffix                IN       VARCHAR2
    , p_period_type_code          IN       VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION get_trend_sel_clause
    RETURN VARCHAR2;

  FUNCTION get_template_sel_clause
   RETURN VARCHAR2;

    FUNCTION get_blg_itd_sql (
       p_param  IN bis_pmv_page_parameter_tbl
    ) RETURN VARCHAR2;

     FUNCTION get_opn_itd_sql (
       p_param  IN bis_pmv_page_parameter_tbl
    ) RETURN VARCHAR2;


--DBI7.0
/*  FUNCTION get_pdueval_cust_sel_clause
   RETURN VARCHAR2;


  FUNCTION get_YTD_by_cust_sql(
        p_param         IN bis_pmv_page_parameter_tbl)
    RETURN VARCHAR2;
  FUNCTION get_YTD_by_cust_sel_clause
    RETURN VARCHAR2;
  FUNCTION get_ITD_by_cust_sql(
        p_param         IN bis_pmv_page_parameter_tbl)
    RETURN VARCHAR2;
  FUNCTION get_ITD_by_cust_sel_clause
    RETURN VARCHAR2;
*/

  PROCEDURE get_blg_opn_ytd_sql (
     p_param  IN bis_pmv_page_parameter_tbl,
     p_backlog_ytd OUT NOCOPY VARCHAR2,
     p_open_ytd    OUT NOCOPY VARCHAR2
        );

  /*******************************************************************************
     Procedure: get_table_sql
              Description: Procedure to retrieve the sql statement for the Backlog
                           Table portlet
   *******************************************************************************/

  PROCEDURE get_table_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl)
  IS

    l_query                  VARCHAR2 (32767);
    l_view_by                VARCHAR2 (120);
    l_view_by_col            VARCHAR2 (120);
    l_as_of_date             DATE;
    l_prev_as_of_date        DATE;

	l_xtd1                    VARCHAR2 (10);
    l_xtd2                    VARCHAR2 (10);
    l_xtd3                    VARCHAR2 (10);
    l_xtd4                    VARCHAR2 (10);

    l_comparison_type        VARCHAR2 (1);
    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2 (2);
    l_where_clause1           VARCHAR2 (2000);
    l_where_clause2          VARCHAR2 (2000);
    l_where_clause3          VARCHAR2 (2000);
    l_where_clause4          VARCHAR2 (2000);
    l_filter_where           VARCHAR2 (240);

    l_mv1                     VARCHAR2 (2000);
    l_mv2                     VARCHAR2 (2000);
    l_mv3                     VARCHAR2 (2000);
    l_mv4                     VARCHAR2 (2000);

    l_col_tbl1               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl2               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl3               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl4               poa_dbi_util_pkg.poa_dbi_col_tbl;

   l_mv_tbl                 poa_dbi_util_pkg.poa_dbi_mv_tbl;
   l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;

    l_to_date_xed    VARCHAR2 (3);
    l_to_date_xtd    VARCHAR2 (3);
    l_to_date_ytd    VARCHAR2 (3);
    l_to_date_itd    VARCHAR2 (3);

    l_blgopn_itd_sql         VARCHAR2(32767);
    l_blgopn_ytd_sql         VARCHAR2(32767);
    l_viewby_rank_where      VARCHAR2(32767);
    l_ytd_sel_clause         VARCHAR2(32767);
    l_sql                    VARCHAR2(32767);
    l_temp                   LONG;


  BEGIN
    l_to_date_xed       := 'XED';
    l_to_date_xtd       := 'XTD';
    l_comparison_type   := 'Y';
    l_to_date_ytd       := 'YTD';
    l_to_date_itd       := 'ITD';
  l_join_tbl          := POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl ();
  l_col_tbl1          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_col_tbl2          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_col_tbl3          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_col_tbl4          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();

  l_mv_tbl            := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

 OKI_DBI_UTIL_PVT.Process_Parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd1
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause1
                                        , p_mv                  => l_mv1
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'N'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_ST_71'
                                        , p_rg_where            => 'Y');
    -- Populate col table with regular columns
     -- Pdue
  	poa_dbi_util_pkg.add_column (p_col_tbl     => l_col_tbl1
	                       , p_col_name        => 'b_r_amt_' || l_cur_suffix
	                       , p_alias_name      => 'Br1'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => l_to_date_ytd);

  OKI_DBI_UTIL_PVT.Process_Parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd1
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause2
                                        , p_mv                  => l_mv2
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'N'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_SG_71'
                                        , p_rg_where            => 'Y');


     -- Pdue Signed total
	poa_dbi_util_pkg.add_column (p_col_tbl     => l_col_tbl2
	                       , p_col_name        => 'b_rgr_amt_' || l_cur_suffix
	                       , p_alias_name      => 'Br3'
                           , p_grand_total     => 'N'
	                       , p_to_date_type    => l_to_date_ytd);

     -- Open Signed total

	poa_dbi_util_pkg.add_column (p_col_tbl     => l_col_tbl2
	                       , p_col_name        => 'o_rgr_amt_' || l_cur_suffix
	                       , p_alias_name      => 'Or3'
                           , p_grand_total     => 'N'
                           , p_to_date_type    => l_to_date_ytd);


 OKI_DBI_UTIL_PVT.Process_Parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd1
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause3
                                        , p_mv                  => l_mv3
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'N'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_CN_71'
                                        , p_rg_where            => 'Y');
     -- Pdue Cancelled  total
  	poa_dbi_util_pkg.add_column (p_col_tbl     => l_col_tbl3
		               , p_col_name        => 'b_rcr_amt_' || l_cur_suffix
		               , p_alias_name      => 'Br2'
                       , p_grand_total     => 'N'
                       , p_to_date_type    => l_to_date_ytd);

     -- Open Cancelled  total

	poa_dbi_util_pkg.add_column (p_col_tbl     => l_col_tbl3
	                       , p_col_name        => 'o_rcr_amt_' || l_cur_suffix
	                       , p_alias_name      => 'Or2'
                           , p_grand_total     => 'N'
                           , p_to_date_type    => l_to_date_ytd);

 OKI_DBI_UTIL_PVT.Process_Parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd1
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause4
                                        , p_mv                  => l_mv4
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'N'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_CR_71'
                                        , p_rg_where            => 'Y');
     -- Open total

	poa_dbi_util_pkg.add_column (p_col_tbl     => l_col_tbl4
	                       , p_col_name        => 'o_r_amt_' || l_cur_suffix
	                       , p_alias_name      => 'Or1'
                           , p_grand_total     => 'N'
                           , p_to_date_type    => l_to_date_ytd);

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

  l_mv_tbl.extend;
  l_mv_tbl(3).mv_name := l_mv3;
  l_mv_tbl(3).mv_col := l_col_tbl3;
  l_mv_tbl(3).mv_where := l_where_clause3;
  l_mv_tbl(3).in_join_tbls := NULL;
  l_mv_tbl(3).use_grp_id := 'N';

  l_mv_tbl.extend;
  l_mv_tbl(4).mv_name := l_mv4;
  l_mv_tbl(4).mv_col := l_col_tbl4;
  l_mv_tbl(4).mv_where := l_where_clause4;
  l_mv_tbl(4).in_join_tbls := NULL;
  l_mv_tbl(4).use_grp_id := 'N';

   /* Additional filter needed to avoid displaying records queried due to total values at node */
   l_filter_where  := '  ( ABS(oki_measure_1) + ABS(oki_measure_2) ) <> 0';

   l_sql :=
         poa_dbi_template_pkg.union_all_status_sql
		                        	 (p_mv                      => l_mv_tbl,
                                                  p_join_tables     => l_join_tbl,
                                                  p_use_windowing     => 'Y',
                                                  p_paren_count           => 2,
                                                  p_filter_where             => NULL,
					   p_generate_viewby => 'N');

   l_ytd_sel_clause    := get_ytd_sel_clause( l_view_by ,l_view_by_col);
   l_blgopn_ytd_sql    := l_sql;
   l_viewby_rank_where :=  ') oset15) oset20 WHERE ' || l_filter_where || ')oset , '||
      poa_dbi_template_pkg.get_viewby_rank_clause ( p_join_tables       => l_join_tbl
                                                  , p_use_windowing     => 'Y'
                                                  );

    /* YTD SQL */
   l_blgopn_ytd_sql := l_ytd_sel_clause || ' FROM ( ' ||l_blgopn_ytd_sql ;
    /* ITD SQL */
   l_blgopn_itd_sql           := get_blgopn_itd_sql(p_param);

   l_sql := get_itdytd_2way_join( '/* ITD */'||l_blgopn_itd_sql || '/* END ITD */',
                                  '/* YTD */'||l_blgopn_ytd_sql || '/* END YTD */',
                                  l_view_by_col);

    -- Generate sql query

    l_query     :=
       get_table_sel_clause (l_view_by
                           , l_view_by_col)
       ||'/* ITD YTD */'
       || l_sql
       ||'/* END ITD YTD */'
       || l_viewby_rank_where;

    x_custom_sql               := '/* OKI_DBI_SRM_BLG_RPT */' || l_query;
    oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);
  END get_table_sql;



  FUNCTION get_table_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_sel_clause         VARCHAR2 (32767);
    l_pastdue_url        VARCHAR2(300);
  --  l_pduepct_url        VARCHAR2(300);
    l_prodcat_url        VARCHAR2(300);
    l_viewby_select      VARCHAR2(32767);
    l_url_select         VARCHAR2(32767);
  BEGIN


    l_viewby_select := oki_dbi_util_pvt.get_viewby_select_clause(p_view_by_dim, 'SRM', '6.0');

   l_pastdue_url := '''pFunctionName=OKI_DBI_SRM_PDUE_DTL_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY='||p_view_by_dim||'''';
--     l_pastdue_url := '''pFunctionName=OKI_DBI_SRM_PDUE_RNWL_CRPT''';

    IF(p_view_by_dim = 'ITEM+ENI_ITEM_VBH_CAT')
    THEN
       l_prodcat_url :=
           ' decode(leaf_node_flag,''Y'',
           ''pFunctionName=OKI_DBI_SRM_BLG_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM'',
           ''pFunctionName=OKI_DBI_SRM_BLG_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT'' ) OKI_DYNAMIC_URL_4 ';
    ELSE
       l_prodcat_url := ''''' OKI_DYNAMIC_URL_4 ';
    END IF;


    l_viewby_select  :=  l_viewby_select ||
   ', OKI_DYNAMIC_URL_1 ,OKI_DYNAMIC_URL_2 ,'|| l_prodcat_url || ' ,oki_measure_1 ,oki_measure_2
    ,oki_measure_3 ,oki_measure_4 ,oki_measure_5 ,oki_measure_6 ,oki_measure_11 ,oki_measure_12
    ,oki_measure_13 ,oki_measure_14 ,oki_measure_15, oki_measure_23
    ,oki_calc_item1 ,oki_calc_item2 , oki_calc_item11 ,oki_calc_item12
     FROM (SELECT  rank() over (&ORDER_BY_CLAUSE nulls last , '||p_view_by_col||') - 1 rnk ,'||p_view_by_col||'
   ,OKI_DYNAMIC_URL_1 ,OKI_DYNAMIC_URL_2 ,oki_measure_1 ,oki_measure_2 ,oki_measure_3
   ,oki_measure_4 ,oki_measure_5 ,oki_measure_6 ,oki_measure_11, oki_measure_12
   ,oki_measure_13 ,oki_measure_14, sum(oki_measure_5) over() oki_measure_15, oki_measure_23, oki_calc_item1
   ,oki_calc_item2, oki_calc_item11 ,oki_calc_item12
       FROM ( ';

 --   ' , decode(resource_id,-999, '''',''pFunctionName=OKI_DBI_SRM_PDUE_DTL_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=VIEW_BY'')  OKI_DYNAMIC_URL_2 '||
--          ' , ''pFunctionName=OKI_DBI_SRM_PDUE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=VIEW_BY'' OKI_DYNAMIC_URL_3 ';


    IF(p_view_by_dim = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
    THEN
       l_url_select :=
          'SELECT  decode(resource_id,-999, ''pFunctionName=OKI_DBI_SRM_BLG_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'', '''')  OKI_DYNAMIC_URL_1 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_pastdue_url||')) OKI_DYNAMIC_URL_2 ';
    ELSIF(p_view_by_dim = 'ITEM+ENI_ITEM')
    THEN
       l_url_select :=
          ' SELECT NULL OKI_DYNAMIC_URL_1 '||
          ' , '||l_pastdue_url||' OKI_DYNAMIC_URL_2 ';
    ELSE
       l_url_select :=
          ' SELECT NULL OKI_DYNAMIC_URL_1 '||
          ' , NULL OKI_DYNAMIC_URL_2 ';
    END IF;

      l_sel_clause               := l_viewby_select || l_url_select ||
          -- AK Attribute naming
          '   ,'|| p_view_by_col ||
          ' , nvl(c_Or,0) oki_measure_1'||
          ' , nvl(c_Br,0) oki_measure_2'||
          ' ,'||POA_DBI_UTIL_PKG.rate_clause('c_Br','c_Or') || 'oki_measure_3 '||
          ' ,'||OKI_DBI_UTIL_PVT.change_clause(POA_DBI_UTIL_PKG.rate_clause('c_Br','c_Or'),
                                               POA_DBI_UTIL_PKG.rate_clause('p_Br','p_Or'),'P')||'oki_measure_4 '||
          ' ,'||POA_DBI_UTIL_PKG.rate_clause('c_Br','c_Br_tot') || ' oki_measure_5 '||
          ' ,'||OKI_DBI_UTIL_PVT.change_clause(POA_DBI_UTIL_PKG.rate_clause('c_Br','c_Br_tot'),
                                      POA_DBI_UTIL_PKG.rate_clause('p_Br','p_Br_tot'),'P')||' oki_measure_6 '||
          ' , nvl(c_Or_tot,0) oki_measure_11'||
          ' , nvl(c_Br_tot,0) oki_measure_12'||
          ' ,'||POA_DBI_UTIL_PKG.rate_clause('c_Br_tot','c_Or_tot') || 'oki_measure_13 '||
          ' ,'||OKI_DBI_UTIL_PVT.change_clause(POA_DBI_UTIL_PKG.rate_clause('c_Br_tot','c_Or_tot'),
                                               POA_DBI_UTIL_PKG.rate_clause('p_Br_tot','p_Or_tot'),'P')||'oki_measure_14 '||
          ' ,'||POA_DBI_UTIL_PKG.rate_clause('p_Br','p_Or') || 'oki_measure_23 '||
          ' ,'||POA_DBI_UTIL_PKG.rate_clause('c_Br','c_Or') || 'oki_calc_item1 '||
          ' ,'||POA_DBI_UTIL_PKG.rate_clause('p_Br','p_Or') || 'oki_calc_item2 '||
          ' ,'||POA_DBI_UTIL_PKG.rate_clause('c_Br_tot','c_Or_tot') || 'oki_calc_item11 '||
          ' ,'||POA_DBI_UTIL_PKG.rate_clause('p_Br_tot','p_Or_tot') || 'oki_calc_item12 '||
          '   from  '||
          '     ( ';

    RETURN l_sel_clause;
  END get_table_sel_clause;

  FUNCTION get_ytd_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2 )
    RETURN VARCHAR2
  IS
    l_sel_clause         VARCHAR2 (32767);
  BEGIN

     l_sel_clause :=
              ' select '||
                --  Measures Based on a formula
                p_view_by_col ||
' ,to_number(NULL) c_Br_itd '||
' ,to_number(NULL) c_or_itd '||
' ,to_number(NULL) p_Br_itd '||
' ,to_number(NULL) p_or_itd '||
' ,NVL2(COALESCE(c_Br1,c_Br2,c_Br3),(NVL(c_Br1,0)-NVL(c_Br2,0)-NVL(c_Br3,0)),NULL) c_Br_ytd '||
' ,NVL2(COALESCE(c_Or1,c_Or2,c_Or3),(NVL(c_Or1,0)-NVL(c_Or2,0)-NVL(c_Or3,0)),NULL) c_Or_ytd '||
' ,NVL2(COALESCE(p_Br1,p_Br2,p_Br3),(NVL(p_Br1,0)-NVL(p_Br2,0)-NVL(p_Br3,0)),NULL) p_Br_ytd '||
' ,NVL2(COALESCE(p_Or1,p_Or2,p_Or3),(NVL(p_Or1,0)-NVL(p_Or2,0)-NVL(p_Or3,0)),NULL) p_Or_ytd '||
        ' FROM ( '||
                   '    select '||
                   '        '||p_view_by_col ||
                   '      , c_Br1 '||
                   '      , c_Br2 '||
                   '      , c_Br3 '||
                   '      , c_Or1 '||
                   '      , c_Or2 '||
                   '      , c_Or3 '||
                   '      , p_Br1 '||
                   '      , p_Br2 '||
                   '      , p_Br3 '||
                   '      , p_Or1 '||
                   '      , p_Or2 '||
                   '      , p_Or3 ';

    RETURN l_sel_clause;
  END get_ytd_sel_clause;


  FUNCTION get_blgopn_itd_sql (
     p_param  IN bis_pmv_page_parameter_tbl
  ) RETURN VARCHAR2
  IS
    l_view_by                VARCHAR2 (120);
    l_view_by_col            VARCHAR2 (120);
    l_as_of_date             DATE;
    l_prev_as_of_date        DATE;
    l_xtd                    VARCHAR2 (10);
    l_comparison_type        VARCHAR2 (1);
    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2 (2);
    l_where_clause           VARCHAR2 (2000);
    l_filter_where           VARCHAR2 (240);
    l_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;


    l_blg_mv                 VARCHAR2(100);
    l_opn_mv                 VARCHAR2(100);
    l_blg_open_where         VARCHAR2(100);

    l_blg_sql                VARCHAR2(10000);
    l_opn_sql                VARCHAR2(10000);

    l_select0                varchar2(1000);
    l_select                 varchar2(32767);
    l_join_column1           varchar2(100);
    l_join_column2           varchar2(100);
    l_query                  varchar2(32767);


  BEGIN
    l_comparison_type   := 'Y';
    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();


    oki_dbi_util_pvt.process_parameters (p_param               => p_param
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
                                        , p_mv_set              => 'SRM_BLG'
                                        , p_rg_where            => 'Y');

    l_blg_mv := l_mv;

    /* Open Where  */
    oki_dbi_util_pvt.process_parameters (p_param               => p_param
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
                                        , p_mv_set              => 'SRM_OPN'
                                        , p_rg_where            => 'Y');
   l_opn_mv := l_mv;

   l_join_column1           := l_view_by_col;
   l_join_column2           := l_view_by_col;

    l_select := 'SUM(c_br_itd) c_br_itd, SUM(c_or_itd) c_or_itd, SUM(p_br_itd) p_br_itd, SUM(p_or_itd)p_or_itd, SUM(to_number(NULL)) c_br_ytd, SUM(to_number(NULL)) c_or_ytd , SUM(to_number(NULL)) p_br_ytd, SUM(to_number(NULL)) p_or_ytd';

   l_select0 :=
        ' fact, fii_time_day time ' ||
        ' WHERE 1 = 1 '||
        ' AND fact.ent_year_id = time.ent_year_id '||
        ' AND   time.report_date IN ( &BIS_CURRENT_ASOF_DATE , &BIS_PREVIOUS_ASOF_DATE ) '||
          l_where_clause;

/*
   IF(l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
   THEN
       l_blg_sql :=
        ' SELECT '||
        ' fact.rg_id ,'||
        ' SUM( DECODE(time.report_date, &BIS_CURRENT_ASOF_DATE , DECODE(fact.rg_id, &ORGANIZATION+JTF_ORG_SALES_GROUP, b_r_amt_n_'||l_cur_suffix||', b_r_amt_t_'||l_cur_suffix||'))) c_br_itd,'||
        ' to_number(NULL) c_or_itd,'||
        ' SUM( DECODE(time.report_date, &BIS_PREVIOUS_ASOF_DATE , DECODE(fact.rg_id, &ORGANIZATION+JTF_ORG_SALES_GROUP, b_r_amt_n_'||l_cur_suffix||', b_r_amt_t_'||l_cur_suffix||'))) p_br_itd, '||
        ' to_number(NULL) p_or_itd '||
        ' FROM '|| l_blg_mv || l_select0 ||
        ' GROUP BY fact.rg_id ';

       l_opn_sql :=
        ' SELECT '||
        ' fact.rg_id ,'||
        ' to_number(NULL) c_br_itd,'||
        ' SUM( DECODE(time.report_date, &BIS_CURRENT_ASOF_DATE , DECODE(fact.rg_id, &ORGANIZATION+JTF_ORG_SALES_GROUP, o_r_amt_n_'||l_cur_suffix||', o_r_amt_t_'||l_cur_suffix||'))) c_or_itd,'||
        ' to_number(NULL) p_br_itd, '||
        ' SUM( DECODE(time.report_date, &BIS_PREVIOUS_ASOF_DATE , DECODE(fact.rg_id, &ORGANIZATION+JTF_ORG_SALES_GROUP, o_r_amt_n_'||l_cur_suffix||', o_r_amt_t_'||l_cur_suffix||'))) p_or_itd '||
        ' FROM '|| l_opn_mv || l_select0 ||
        ' GROUP BY fact.rg_id ';
   ELSE
*/
      l_blg_sql  :=
         'SELECT '||
         'fact.'||l_view_by_col||','||
         'SUM( DECODE(time.report_date, &BIS_CURRENT_ASOF_DATE , b_r_amt_'||l_cur_suffix||')) c_br_itd,'||
        ' to_number(NULL) c_or_itd,'||
         'SUM( DECODE(time.report_date, &BIS_PREVIOUS_ASOF_DATE , b_r_amt_'||l_cur_suffix||')) p_br_itd, '||
        ' to_number(NULL) p_or_itd '||
        ' FROM '|| l_blg_mv || l_select0 ||
        ' GROUP BY   fact.'||l_view_by_col;
      l_opn_sql  :=
         'SELECT fact.'||l_view_by_col||','||
        ' to_number(NULL) c_br_itd, '||
         'SUM( DECODE(time.report_date, &BIS_CURRENT_ASOF_DATE , o_r_amt_'||l_cur_suffix||')) c_or_itd,'||
        ' to_number(NULL) p_br_itd, '||
         'SUM( DECODE(time.report_date, &BIS_PREVIOUS_ASOF_DATE , o_r_amt_'||l_cur_suffix||')) p_or_itd '||
        ' FROM '|| l_opn_mv || l_select0 ||
        ' GROUP BY   fact.'||l_view_by_col;
/*
  END IF;
*/

  l_query := oki_dbi_util_pvt.two_way_join (l_select,
                                        '/* BLG ITD */'||l_blg_sql || '/* END BLG ITD */',
                                        '/* OPN ITD */'||l_opn_sql || '/* END OPN ITD */',
                                        l_join_column1,
                                        l_join_column2);

  RETURN l_query;

 END get_blgopn_itd_sql;

 FUNCTION get_itdytd_2way_join(
   p_blgopn_itd_sql             IN       VARCHAR2
 , p_blgopn_ytd_sql             IN       VARCHAR2
 , l_view_by_col                IN       VARCHAR2)
 RETURN VARCHAR2  IS
     l_select     VARCHAR2(32767);
     l_query      VARCHAR2(32767);
 BEGIN
     l_select := 'SUM(c_br_itd) c_br_itd, SUM(c_or_itd) c_or_itd, SUM(p_br_itd) p_br_itd, SUM(p_or_itd) p_or_itd ,SUM(c_br_ytd) c_br_ytd, SUM(c_or_ytd) c_or_ytd, SUM(p_br_ytd) p_br_ytd, SUM(p_or_ytd) p_or_ytd ';

     l_query := oki_dbi_util_pvt.two_way_join (l_select,
                                           p_blgopn_itd_sql,
                                           p_blgopn_ytd_sql,
                                           l_view_by_col,
                                           l_view_by_col);

     return  'SELECT '||l_view_by_col||','||'
                  NVL2(COALESCE(c_br_itd,c_br_ytd),NVL(c_br_itd,0)+NVL(c_br_ytd,0),NULL) c_br ,
                  NVL2(COALESCE(c_or_itd,c_or_ytd),NVL(c_or_itd,0)+NVL(c_or_ytd,0),NULL) c_or ,
                  NVL2(COALESCE(p_br_itd,p_br_ytd),NVL(p_br_itd,0)+NVL(p_br_ytd,0),NULL) p_br ,
                  NVL2(COALESCE(p_or_itd,p_or_ytd),NVL(p_or_itd,0)+NVL(p_or_ytd,0),NULL) p_or ,
                  SUM(NVL2(COALESCE(c_br_itd,c_br_ytd),NVL(c_br_itd,0)+NVL(c_br_ytd,0),NULL) ) over() c_br_tot ,
                  SUM(NVL2(COALESCE(c_or_itd,c_or_ytd),NVL(c_or_itd,0)+NVL(c_or_ytd,0),NULL) ) over()c_or_tot ,
                  SUM(NVL2(COALESCE(p_br_itd,p_br_ytd),NVL(p_br_itd,0)+NVL(p_br_ytd,0),NULL) ) over()p_br_tot ,
                  SUM(NVL2(COALESCE(p_or_itd,p_or_ytd),NVL(p_or_itd,0)+NVL(p_or_ytd,0),NULL) ) over()p_or_tot
                  FROM ( '|| l_query ||')';

 END get_itdytd_2way_join;



   /*******************************************************************************
         Procedure: get_pduernwldetail_sql
         Description: Function to retrieve the sql statement for the past due renewal
                      Detail portlet
    *******************************************************************************/
    PROCEDURE get_pduernwldetail_sql (
      p_param                     IN       bis_pmv_page_parameter_tbl
    , x_custom_sql                OUT NOCOPY VARCHAR2
    , x_custom_output             OUT NOCOPY bis_query_attributes_tbl)
    IS

      l_query                  VARCHAR2 (32767);
      l_view_by                VARCHAR2 (120);
      l_view_by_col            VARCHAR2 (120);
      l_as_of_date             DATE;
      l_prev_as_of_date        DATE;
      l_xtd                    VARCHAR2 (10);
      l_comparison_type        VARCHAR2 (1);
      l_period_type            VARCHAR2(10);
      l_nested_pattern         NUMBER;
      l_cur_suffix             VARCHAR2 (2);
      l_where_clause           VARCHAR2 (2000);
      l_mv                     VARCHAR2 (2000);
      l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
      l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
      l_to_date_xed    VARCHAR2 (3);
      l_to_date_xtd    VARCHAR2 (3);

      l_rpt_specific_where     VARCHAR2 (1000);
      l_additional_where_clause VARCHAR2 (1000);
      l_join_where             VARCHAR2 (1000);
      l_group_by               VARCHAR2 (1000);
      l_filter_where           VARCHAR2 (240);
      l_additional_mv          VARCHAR2 (1000);

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
                                          , p_mv_set              => 'SRM_CDTL_RPT'
                                          , p_rg_where            => 'Y');

      l_rpt_specific_where    :=
        ' AND fact.renewal_flag in (1,3)
		      AND fact.start_date <= &BIS_CURRENT_ASOF_DATE
          AND fact.past_due_date > &BIS_CURRENT_ASOF_DATE';

      l_group_by     := ' GROUP BY fact.chr_id, fact.customer_party_id, fact.resource_id';

      poa_dbi_util_pkg.add_column (p_col_tbl       => l_col_tbl
                                 , p_col_name      => 'price_negotiated_' || l_cur_suffix
                                 , p_alias_name    => 'full_value'
                                 , p_prior_code    => poa_dbi_util_pkg.no_priors);

      poa_dbi_util_pkg.add_column (p_col_tbl       => l_col_tbl
                                 , p_col_name      => 'win_percent /100 * fact.price_negotiated_' || l_cur_suffix
                                 , p_alias_name    => 'forecast_value'
                                 , p_prior_code    => poa_dbi_util_pkg.no_priors);

      l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();

      oki_dbi_util_pvt.join_rpt_where (p_join_tbl     => l_join_tbl
                                        , p_func_area    => 'SRM'
                                        , p_version      => '6.0'
                                        , p_role         => NULL
                                        , p_mv_set       => 'SRM_CDTL_RPT');

     /* Additional filter needed to avoid displaying records queried due to total values at node */
   l_filter_where  := ' ( ABS(oki_measure_1) + ABS(oki_measure_3) ) <> 0 ';

   l_additional_mv := ' ) fact
                       , OKI_SCM_OCR_MV k
                       WHERE fact.chr_id = k.chr_id) ';

      l_query                 := get_pduernwldetail_sel_clause (l_cur_suffix, l_period_type )

         || poa_dbi_template_pkg.dtl_status_sql2 (p_fact_name         => l_mv
                                               , p_where_clause      => l_where_clause || l_rpt_specific_where
                                               , p_join_tables       => l_join_tbl
                                               , p_use_windowing     => 'Y'
                                               , p_col_name          => l_col_tbl
                                               , p_use_grpid         => 'N'
                                               , p_filter_where      => l_filter_where || l_additional_mv
                                               , p_paren_count       => 5
                                               , p_group_by          => l_group_by
                                               , p_from_clause       => ' from '||l_mv ||' fact ');

      x_custom_sql               := '/* OKI_DBI_SRM_PDUE_DTL_DRPT */' || l_query;
      oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

  END get_pduernwldetail_sql;


  FUNCTION get_pduernwldetail_sel_clause (
      p_cur_suffix                IN       VARCHAR2
    , p_period_type_code          IN       VARCHAR2)
      RETURN VARCHAR2
    IS
      l_query   VARCHAR2 (10000);

    BEGIN

      -- Generate sql query
      l_query                    :=
          'SELECT
             oki_attribute_1,
             cust.value oki_attribute_2,
             DECODE(fact.resource_id,-1,&UNASSIGNED,rsex.resource_name) oki_attribute_3,
             OKI_DATE_1,
	     OKI_DATE_2,
             oki_measure_1,
             oki_measure_3,
             OKI_MEASURE_4,
             oki_measure_11,
             oki_measure_13,
             OKI_MEASURE_14,
	     fact.chr_id OKI_ATTRIBUTE_5
         FROM (SELECT *
         FROM (
            SELECT
               rank() over (&ORDER_BY_CLAUSE nulls last) - 1 rnk ,
               customer_party_id,
               resource_id,
  	       oki_measure_1,
       	       oki_measure_3,
	       oki_measure_11,
               oki_measure_13,
               oki_date_1,
               oki_date_2,
               oki_attribute_1,
               oki_measure_4,
               oki_measure_14,
	       chr_id
           FROM (SELECT fact.*
                     , to_char(k.start_date) OKI_DATE_1
                     , to_char(k.expected_close_date) OKI_DATE_2
                     , k.COMPLETE_k_number oki_attribute_1
                     , NVL(k.price_nego_'|| p_cur_suffix || ',0) OKI_MEASURE_4
                     , NVL(SUM(k.price_nego_' ||p_cur_suffix ||') over (),0)  OKI_MEASURE_14
                  FROM (SELECT *
            FROM (
                  SELECT
                  	 oset5.chr_id,
  	                 oset5.customer_party_id ,
  	                 oset5.resource_id  ,
                     nvl(oset5.full_value,0)	          OKI_MEASURE_1,
  	  	           	 nvl(oset5.forecast_value,0)   	    OKI_MEASURE_3,
  	  	           	 nvl(oset5.full_value_total,0) 	    OKI_MEASURE_11,
  	                 nvl(oset5.forecast_value_total,0)  OKI_MEASURE_13
  	    FROM
                  (SELECT
                      fact.chr_id,
                      fact.customer_party_id,
                      fact.resource_id ';

       RETURN l_query;

       END get_pduernwldetail_sel_clause;


   /*******************************************************************************
     Procedure: get_pastdue_percent_sql
            Description: Function to retrieve the sql statement for the past due percent
                         portlet
    *******************************************************************************/

PROCEDURE get_pastdue_percent_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl)
  IS

    l_query                  VARCHAR2 (32767);
    l_view_by                VARCHAR2 (120);
    l_view_by_col            VARCHAR2 (120);
    l_as_of_date             DATE;
    l_prev_as_of_date        DATE;
    l_xtd                    VARCHAR2 (10);
    l_comparison_type        VARCHAR2 (1);
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
    l_pastdue_where      VARCHAR2(20000);
    l_open_where         VARCHAR2(20000);
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
           ' decode(leaf_node_flag,''Y'',
         ''pFunctionName=OKI_DBI_SRM_PDUE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM'',
         ''pFunctionName=OKI_DBI_SRM_PDUE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT'' ) OKI_DYNAMIC_URL_4 ';
    ELSE
       l_prodcat_url := ''''' OKI_DYNAMIC_URL_4 ';
    END IF;


    l_viewby_select := oki_dbi_util_pvt.get_viewby_select_clause(l_view_by, 'SRM', '6.0');

   /* Additional filter needed to avoid displaying records queried due to total values at node */
   l_filter_where  := ' ( ABS(oki_measure_1) +
   			              ABS(oki_measure_2) +
   			              ABS(oki_measure_4) +
   			              ABS(oki_measure_5) +
   			              ABS(oki_measure_7) +
   			              ABS(oki_measure_8) ) <> 0';

    /*
     *  OKI_ATTRIBUTE_3 and OKI_ATTRIBUTE_4 are required for displaying the Legends in the Past Due Percent by count
     *  graph,since the long label for the measure 6 and measure 9 are PastDuePercent
     */

    l_viewby_select  :=  l_viewby_select ||
   ', OKI_DYNAMIC_URL_1 ,'|| l_prodcat_url || ' ,oki_measure_1 ,oki_measure_2 ,oki_measure_3 ,oki_measure_4
    ,oki_measure_5 ,oki_measure_6 ,oki_measure_7 ,oki_measure_8 ,oki_measure_9 ,oki_measure_11 ,oki_measure_12
    ,oki_measure_13 ,oki_measure_14 ,oki_measure_15 ,oki_measure_16 ,oki_measure_17 ,oki_measure_18 ,oki_measure_19
    ,oki_measure_6 OKI_ATTRIBUTE_3 ,oki_measure_9 OKI_ATTRIBUTE_4
     FROM (
     SELECT  rank() over (&ORDER_BY_CLAUSE nulls last , '||l_view_by_col||') - 1 rnk ,'||l_view_by_col||'
    ,OKI_DYNAMIC_URL_1 ,oki_measure_1 ,oki_measure_2 ,oki_measure_3 ,oki_measure_4 ,oki_measure_5 ,oki_measure_6
    ,oki_measure_7 ,oki_measure_8 ,oki_measure_9 ,oki_measure_11 ,oki_measure_12 ,oki_measure_13 ,oki_measure_14
    ,oki_measure_15 ,oki_measure_16 ,oki_measure_17 ,oki_measure_18 ,oki_measure_19
     FROM ( ';

   /* Dynamic URL's  */
    IF(l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
    THEN
       l_url_select :=
          'SELECT  decode(resource_id,-999,''pFunctionName=OKI_DBI_SRM_PDUE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'','''') OKI_DYNAMIC_URL_1 ';
       l_viewby_col_special := ' imm_child_rg_id ';
    ELSE
       l_url_select :=
          'SELECT  NULL OKI_DYNAMIC_URL_1 ';
       l_viewby_col_special := NULL ;
    END IF;

   /* From and Joins */
   IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP'
   THEN
      l_pastdue_where := '
          FROM    '||l_mv ||' fact
          WHERE fact.mx_id = 5
          AND   fact.renewal_flag IN (1,3)
          AND   fact.start_date <= &BIS_CURRENT_ASOF_DATE
          AND   COALESCE(fact.date_signed, fact.date_cancelled, &BIS_CURRENT_ASOF_DATE + 1)
                                                              >  &BIS_CURRENT_ASOF_DATE'
          || l_where_clause || '
          GROUP BY imm_child_rg_id, resource_id ';

      l_open_where := '
          FROM    '||l_mv ||' fact
          WHERE   fact.mx_id = 1
          AND   fact.renewal_flag IN (1,3)
          AND   fact.cle_creation_date <= &BIS_CURRENT_ASOF_DATE
          AND   COALESCE(fact.date_signed, fact.date_cancelled, &BIS_CURRENT_ASOF_DATE + 1)
                                                              > &BIS_CURRENT_ASOF_DATE '
          || l_where_clause || '
          GROUP BY imm_child_rg_id, resource_id ';
   ELSE
      l_pastdue_where := '
          FROM     '||l_mv ||' fact
          WHERE   fact.mx_id = 5
          AND   fact.renewal_flag IN (1,3)
          AND   fact.start_date <= &BIS_CURRENT_ASOF_DATE
          AND   COALESCE(fact.date_signed, fact.date_cancelled, &BIS_CURRENT_ASOF_DATE + 1)
                                                              >  &BIS_CURRENT_ASOF_DATE '
          || l_where_clause || '
          GROUP BY  ' ||l_view_by_col  ;

      l_open_where := '
          FROM     '||l_mv ||' fact
          WHERE   fact.mx_id = 1
          AND   fact.renewal_flag IN (1,3)
          AND   fact.cle_creation_date <= &BIS_CURRENT_ASOF_DATE
          AND   COALESCE(fact.date_signed, fact.date_cancelled, &BIS_CURRENT_ASOF_DATE + 1)
                                                              >  &BIS_CURRENT_ASOF_DATE '
          || l_where_clause || '
          GROUP BY  ' ||l_view_by_col  ;

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



    l_query                    := l_viewby_select || l_url_select || ' ,'||
       l_view_by_col || ',' ||
      'oset10.pastdue_val OKI_MEASURE_1,
       oset10.open_val OKI_MEASURE_2,
       oset10.val_rate OKI_MEASURE_3,
       oset10.pastdue_lcount OKI_MEASURE_4,
       oset10.open_lcount OKI_MEASURE_5,
       oset10.lcount_rate OKI_MEASURE_6,
       oset10.pastdue_hcount OKI_MEASURE_7,
       oset10.open_hcount OKI_MEASURE_8,
       oset10.hcount_rate OKI_MEASURE_9,
       oset10.pastdue_val_tot OKI_MEASURE_11,
       oset10.open_val_tot OKI_MEASURE_12,
       oset10.val_rate_tot OKI_MEASURE_13,
       oset10.pastdue_lcount_tot OKI_MEASURE_14,
       oset10.open_lcount_tot OKI_MEASURE_15,
       oset10.lcount_rate_tot OKI_MEASURE_16,
       oset10.pastdue_hcount_tot OKI_MEASURE_17,
       oset10.open_hcount_tot OKI_MEASURE_18,
       oset10.hcount_rate_tot OKI_MEASURE_19
   FROM
   (
     SELECT '|| l_view_by_col || ',
         nvl(oset05.pastdue_val,0) pastdue_val,
         nvl(oset05.open_val,0) open_val,
         oset05.pastdue_val /decode( open_val,0,NULL,open_val)*100 val_rate ,
         nvl(oset05.pastdue_lcount,0) pastdue_lcount,
         nvl(oset05.open_lcount,0) open_lcount,
         oset05.pastdue_lcount/decode( open_lcount,0,NULL,open_lcount)*100 lcount_rate ,
         nvl(oset05.pastdue_hcount,0) pastdue_hcount,
         nvl(oset05.open_hcount,0) open_hcount ,
         oset05.pastdue_hcount/decode( open_hcount,0,NULL,open_hcount)*100 hcount_rate ,
         nvl(oset05.pastdue_val_tot,0) pastdue_val_tot,
         nvl(oset05.open_val_tot,0) open_val_tot,
         oset05.pastdue_val_tot/decode(oset05.open_val_tot,0,NULL,oset05.open_val_tot)*100 val_rate_tot,
         nvl(oset05.pastdue_lcount_tot,0) pastdue_lcount_tot,
         nvl(oset05.open_lcount_tot,0) open_lcount_tot,
         oset05.pastdue_lcount_tot /decode( oset05.open_lcount_tot,0,NULL,oset05.open_lcount_tot)*100 lcount_rate_tot,
         nvl(oset05.pastdue_hcount_tot,0) pastdue_hcount_tot,
         nvl(oset05.open_hcount_tot,0) open_hcount_tot,
	 oset05.pastdue_hcount_tot /decode( oset05.open_hcount_tot,0,NULL,oset05.open_hcount_tot)*100 hcount_rate_tot

     FROM
      ( '||
         get_pdue_open_2way_sql(l_pastdue_where,
                                l_open_where,
                                l_viewby_col_special,
                                l_view_by_col,
                                l_cur_suffix   )
        || l_VIEWBY_RANK_ORDER;


    x_custom_sql               := '/* OKI_DBI_SRM_PDUE_DRPT */ ' || l_query;

    oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

  END get_pastdue_percent_sql;

FUNCTION get_pdue_open_2way_sql (
    l_pastdue_where            IN       VARCHAR2
  , l_open_where               IN       VARCHAR2
  , l_viewby_col_special       IN       VARCHAR2
  , l_view_by_col              IN       VARCHAR2
  , l_cur_suffix               IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_select  varchar2(32767);
    l_query1  varchar2(32767);
    l_query2  varchar2(32767);
    l_join_column1 varchar2(100);
    l_join_column2 varchar2(100);
    l_query    varchar2(32767);
  BEGIN

    l_select :=' SUM(pastdue_val) pastdue_val,
                 SUM(pastdue_hcount) pastdue_hcount,
                 SUM(pastdue_lcount) pastdue_lcount,
                 SUM(pastdue_val_tot) pastdue_val_tot,
                 SUM(pastdue_hcount_tot) pastdue_hcount_tot,
                 SUM(pastdue_lcount_tot) pastdue_lcount_tot,
                 SUM(open_val) open_val,
                 SUM(open_hcount) open_hcount,
                 SUM(open_lcount) open_lcount,
                 SUM(open_val_tot) open_val_tot,
                 SUM(open_hcount_tot) open_hcount_tot,
                 SUM(open_lcount_tot) open_lcount_tot
                ';

   l_query1  :=
     ' SELECT '|| l_viewby_col_special ||l_view_by_col ||',
           NVL(SUM(fact.price_nego_'||l_cur_suffix||'),0) pastdue_val,
           NVL(COUNT(distinct(fact.chr_id)),0) pastdue_hcount,
           NVL(COUNT(distinct(fact.cle_id)),0) pastdue_lcount,
           NVL(SUM(SUM(fact.price_nego_'||l_cur_suffix||')) over (),0)pastdue_val_tot,
           NVL(SUM(COUNT(distinct(fact.chr_id))) over (),0)pastdue_hcount_tot,
           NVL(SUM(COUNT(distinct(fact.cle_id))) over (),0)pastdue_lcount_tot,
           to_number(NULL) open_val,
	   to_number(NULL) open_hcount,
	   to_number(NULL) open_lcount,
	   to_number(NULL) open_val_tot,
	   to_number(NULL) open_hcount_tot,
	   to_number(NULL) open_lcount_tot '||l_pastdue_where;

   l_query2  :=
     ' SELECT '|| l_viewby_col_special ||l_view_by_col ||',
	  to_number(NULL) pastdue_val,
          to_number(NULL) pastdue_hcount,
          to_number(NULL) pastdue_lcount,
          to_number(NULL) pastdue_val_tot,
          to_number(NULL) pastdue_hcount_tot,
          to_number(NULL) pastdue_lcount_tot,
          NVL(SUM(fact.price_nego_'||l_cur_suffix||'),0) Open_val,
          NVL(COUNT(distinct(fact.chr_id)),0) Open_hcount,
          NVL(COUNT(distinct(fact.cle_id)),0) Open_lcount,
          NVL(SUM(SUM(fact.price_nego_'||l_cur_suffix||')) over (),0) Open_val_tot,
          NVL(SUM(COUNT(distinct(fact.chr_id))) over (),0) Open_hcount_tot,
          NVL(SUM(COUNT(distinct(fact.cle_id))) over (),0) Open_lcount_tot '||
          l_open_where;

   l_join_column1  := l_view_by_col;
   l_join_column2  := l_view_by_col;

   l_query := oki_dbi_util_pvt.two_way_join (l_select, l_query1, l_query2,l_join_column1, l_join_column2);

   return l_query;

  END get_pdue_open_2way_sql;

       /*******************************************************************************
        Procedure: get_trend_sql
         Description: Function to retrieve the sql statement for the past due percent
                      TREND portlet
       *******************************************************************************/

  PROCEDURE get_trend_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl)
  IS

    l_query                  VARCHAR2 (32767);
    l_sql_text                  VARCHAR2 (32767);
    l_view_by                VARCHAR2 (120);
    l_view_by_col            VARCHAR2 (120);
    l_as_of_date             DATE;
    l_prev_as_of_date        DATE;
    l_xtd1                    VARCHAR2 (10);
    l_xtd2                    VARCHAR2 (10);
    l_xtd3                    VARCHAR2 (10);
    l_xtd4                    VARCHAR2 (10);

    l_comparison_type        VARCHAR2 (1);
    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2 (2);
    l_where_clause1          VARCHAR2 (2000);
    l_where_clause2          VARCHAR2 (2000);
    l_where_clause3          VARCHAR2 (2000);
    l_where_clause4          VARCHAR2 (2000);
    l_filter_where           VARCHAR2 (240);
    l_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed    VARCHAR2 (3);
    l_to_date_xtd    VARCHAR2 (3);
    l_to_date_ytd    VARCHAR2 (3);
    l_to_date_itd    VARCHAR2 (3);

    l_mv1                     VARCHAR2 (2000);
    l_mv2                     VARCHAR2 (2000);
    l_mv3                     VARCHAR2 (2000);
    l_mv4                     VARCHAR2 (2000);

    l_col_tbl1               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl2               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl3               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl4               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_sql                    VARCHAR2(32767);
    l_template_sql VARCHAR2(32767);
    l_backlog_ytd  VARCHAR2(32767);
    l_open_ytd     VARCHAR2(32767);
    l_mv_tbl                 poa_dbi_util_pkg.poa_dbi_mv_tbl;
    l_count NUMBER;
  BEGIN
    l_to_date_xed       := 'XED';
    l_to_date_xtd       := 'XTD';
    l_comparison_type   := 'Y';
    l_to_date_ytd       := 'YTD';
    l_to_date_itd       := 'ITD';
  l_join_tbl          := POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl ();
  l_col_tbl1          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_col_tbl2          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_col_tbl3          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_col_tbl4          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();

  l_mv_tbl            := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

 OKI_DBI_UTIL_PVT.Process_Parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd1
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause1
                                        , p_mv                  => l_mv1
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_ST_71'
                                        , p_rg_where            => 'Y');
    -- Populate col table with regular columns
     -- Pdue
  	poa_dbi_util_pkg.add_column (p_col_tbl     => l_col_tbl1
	                       , p_col_name        => 'b_r_amt_' || l_cur_suffix
	                       , p_alias_name      => 'Br1'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => l_to_date_ytd);

  OKI_DBI_UTIL_PVT.Process_Parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd2
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause2
                                        , p_mv                  => l_mv2
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_SG_71'
                                        , p_rg_where            => 'Y');


     -- Pdue Signed total
	poa_dbi_util_pkg.add_column (p_col_tbl     => l_col_tbl2
	                       , p_col_name        => 'b_rgr_amt_' || l_cur_suffix
	                       , p_alias_name      => 'Br3'
                           , p_grand_total     => 'N'
	                       , p_to_date_type    => l_to_date_ytd);

     -- Open Signed total

	poa_dbi_util_pkg.add_column (p_col_tbl     => l_col_tbl2
	                       , p_col_name        => 'o_rgr_amt_' || l_cur_suffix
	                       , p_alias_name      => 'Or3'
                           , p_grand_total     => 'N'
                           , p_to_date_type    => l_to_date_ytd);


 OKI_DBI_UTIL_PVT.Process_Parameters (   p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd3
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause3
                                        , p_mv                  => l_mv3
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_CN_71'
                                        , p_rg_where            => 'Y');
     -- Pdue Cancelled  total
  	poa_dbi_util_pkg.add_column (p_col_tbl     => l_col_tbl3
		               , p_col_name        => 'b_rcr_amt_' || l_cur_suffix
		               , p_alias_name      => 'Br2'
                       , p_grand_total     => 'N'
                       , p_to_date_type    => l_to_date_ytd);

     -- Open Cancelled  total

	poa_dbi_util_pkg.add_column (p_col_tbl     => l_col_tbl3
	                       , p_col_name        => 'o_rcr_amt_' || l_cur_suffix
	                       , p_alias_name      => 'Or2'
                           , p_grand_total     => 'N'
                           , p_to_date_type    => l_to_date_ytd);

 OKI_DBI_UTIL_PVT.Process_Parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd4
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause4
                                        , p_mv                  => l_mv4
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_CR_71'
                                        , p_rg_where            => 'Y');
     -- Open total

	poa_dbi_util_pkg.add_column (p_col_tbl     => l_col_tbl4
	                       , p_col_name        => 'o_r_amt_' || l_cur_suffix
	                       , p_alias_name      => 'Or1'
                           , p_grand_total     => 'N'
                           , p_to_date_type    => l_to_date_ytd);

  l_mv_tbl.extend;
  l_mv_tbl(1).mv_name := l_mv1;
  l_mv_tbl(1).mv_col := l_col_tbl1;
  l_mv_tbl(1).mv_where := l_where_clause1;
  l_mv_tbl(1).in_join_tbls := NULL;
  l_mv_tbl(1).use_grp_id := 'N';
  l_mv_tbl(1).mv_xtd := l_xtd1;

  l_mv_tbl.extend;
  l_mv_tbl(2).mv_name := l_mv2;
  l_mv_tbl(2).mv_col := l_col_tbl2;
  l_mv_tbl(2).mv_where := l_where_clause2;
  l_mv_tbl(2).in_join_tbls := NULL;
  l_mv_tbl(2).use_grp_id := 'N';
  l_mv_tbl(2).mv_xtd := l_xtd2;

  l_mv_tbl.extend;
  l_mv_tbl(3).mv_name := l_mv3;
  l_mv_tbl(3).mv_col := l_col_tbl3;
  l_mv_tbl(3).mv_where := l_where_clause3;
  l_mv_tbl(3).in_join_tbls := NULL;
  l_mv_tbl(3).use_grp_id := 'N';
  l_mv_tbl(3).mv_xtd := l_xtd3;

  l_mv_tbl.extend;
  l_mv_tbl(4).mv_name := l_mv4;
  l_mv_tbl(4).mv_col := l_col_tbl4;
  l_mv_tbl(4).mv_where := l_where_clause4;
  l_mv_tbl(4).in_join_tbls := NULL;
  l_mv_tbl(4).use_grp_id := 'N';
  l_mv_tbl(4).mv_xtd := l_xtd4;


   /* Additional filter needed to avoid displaying records queried due to total values at node */


   l_template_sql :=
          poa_dbi_template_pkg.union_all_trend_sql
		                        				 (p_mv              => l_mv_tbl,
                                      p_comparison_type   => l_comparison_type,
                                      p_filter_where    => NULL);


l_template_sql := '(select
cn vb
,csd
,sum(c_Br1)c_Br1
,sum(p_Br1)p_Br1
,sum(c_Br3)c_Br3
,sum(p_Br3)p_Br3
,sum(c_Or3)c_Or3
,sum(p_Or3)p_Or3
,sum(c_Br2)c_Br2
,sum(p_Br2)p_Br2
,sum(c_Or2)c_Or2
,sum(p_Or2)p_Or2
,sum(c_Or1)c_Or1
,sum(p_Or1)p_Or1
from(
WITH n AS(select /*+ NO_MERGE */n.time_id ntid,n.record_type_id,n.period_type_id,n.report_date nrd,cal.start_date nsd,cal.end_date
from '|| poa_dbi_util_pkg.get_calendar_table (l_xtd1)||' cal,fii_time_rpt_struct_v n
where cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE and n.report_date in(least(cal.end_date,&BIS_CURRENT_ASOF_DATE),&BIS_PREVIOUS_ASOF_DATE)
and n.report_date between cal.start_date and cal.end_date and bitand(n.record_type_id,&BIS_NESTED_PATTERN)=n.record_type_id)
(SELECT
cal.name cn,cal.start_date csd,c_Br1,p_Br1,0 c_Br3,0 p_Br3,0 c_Or3,0 p_Or3,0 c_Br2,0 p_Br2,0 c_Or2,0 p_Or2,0 c_Or1,0 p_Or1
from(select n.start_date isd
,sum(case when(n.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE and nrd=LEAST(n.end_date,&BIS_CURRENT_ASOF_DATE))then Br1 end)c_Br1
,lag(sum(case when(n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE and nrd=LEAST(n.end_date,&BIS_PREVIOUS_ASOF_DATE))then Br1 end),&LAG)over(order by n.start_date)p_Br1
from(select nsd,nrd,sum(b_r_amt_g)Br1 FROM '|| l_mv1 ||' fact,n
where fact.time_id=ntid '
|| l_where_clause1 ||
' GROUP by  nsd, nrd)i,'|| poa_dbi_util_pkg.get_calendar_table (l_xtd1)|| ' n where nsd(+)=n.start_date and n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
group by n.start_date)iset,'|| poa_dbi_util_pkg.get_calendar_table (l_xtd1)|| ' cal where cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and cal.start_date=iset.isd(+)
)UNION ALL
(select
cal.name cn,cal.start_date csd,0 c_Br1,0 p_Br1,c_Br3,p_Br3,c_Or3,p_Or3,0 c_Br2,0 p_Br2,0 c_Or2,0 p_Or2,0 c_Or1,0 p_Or1
from
(select n.start_date isd
,sum(case when(n.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE and nrd=LEAST(n.end_date,&BIS_CURRENT_ASOF_DATE))then Br3 end)c_Br3
,lag(sum(case when(n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE and nrd=LEAST(n.end_date,&BIS_PREVIOUS_ASOF_DATE))then Br3 end),&LAG)over(order by n.start_date)p_Br3
,sum(case when(n.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE and nrd=LEAST(n.end_date,&BIS_CURRENT_ASOF_DATE))then Or3 end) c_Or3
,lag(sum(case when(n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE and nrd=LEAST (n.end_date,&BIS_PREVIOUS_ASOF_DATE))then Or3 end),&LAG)over(order by n.start_date)p_Or3
from(select nsd,nrd,sum(b_rgr_amt_g)Br3,sum(o_rgr_amt_g)Or3 from '||l_mv2||  ' fact,n
where fact.time_id=ntid '
|| l_where_clause2 ||
' GROUP by nsd,nrd)i,'|| poa_dbi_util_pkg.get_calendar_table (l_xtd2)|| ' n where nsd(+)=n.start_date and n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
group by n.start_date)iset,'|| poa_dbi_util_pkg.get_calendar_table (l_xtd2)|| ' cal
where cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and cal.start_date=iset.isd(+)
)UNION ALL
(select
cal.name cn,cal.start_date csd,0 c_Br1,0 p_Br1,0 c_Br3,0 p_Br3,0 c_Or3,0 p_Or3,c_Br2,p_Br2,c_Or2,p_Or2,0 c_Or1,0 p_Or1 from
(select n.start_date isd
,sum(case when(n.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE and nrd=LEAST(n.end_date,&BIS_CURRENT_ASOF_DATE))then Br2 end)c_Br2
,lag(sum(case when(n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE and nrd=LEAST(n.end_date,&BIS_PREVIOUS_ASOF_DATE))then Br2 end),&LAG)over(order by n.start_date)p_Br2
,sum(case when(n.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE and nrd=LEAST(n.end_date,&BIS_CURRENT_ASOF_DATE))then Or2 end)c_Or2
,lag(sum(case when(n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE and nrd=LEAST(n.end_date,&BIS_PREVIOUS_ASOF_DATE))then Or2 end),&LAG)over(order by n.start_date)p_Or2
from(select nsd,nrd,sum(b_rcr_amt_g)Br2,sum(o_rcr_amt_g)Or2 from ' || l_mv3 ||' fact,n
where fact.time_id=ntid '
||l_where_clause3||
' GROUP by nsd,nrd)i,'|| poa_dbi_util_pkg.get_calendar_table (l_xtd3)|| ' n where nsd(+)=n.start_date and n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
group by n.start_date)iset,' || poa_dbi_util_pkg.get_calendar_table (l_xtd3)|| ' cal
where cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and cal.start_date=iset.isd(+)
)UNION ALL
(select
cal.name cn,cal.start_date csd,0 c_Br1,0 p_Br1,0 c_Br3,0 p_Br3,0 c_Or3,0 p_Or3,0 c_Br2,0 p_Br2,0 c_Or2,0 p_Or2,c_Or1,p_Or1
from
(select n.start_date isd
,sum(case when(n.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE and nrd=LEAST(n.end_date,&BIS_CURRENT_ASOF_DATE))then Or1 end)c_Or1
,lag(sum(case when(n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE and nrd=LEAST(n.end_date,&BIS_PREVIOUS_ASOF_DATE))then Or1 end),&LAG)over(order by n.start_date)p_Or1
from(select nsd,nrd,sum(o_r_amt_g)Or1 from ' ||l_mv4||' fact,n
where fact.time_id=ntid '
|| l_where_clause4 ||
' GROUP by nsd,nrd)i,' ||poa_dbi_util_pkg.get_calendar_table (l_xtd4)|| ' n where nsd(+)=n.start_date and n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
group by n.start_date)iset,'|| poa_dbi_util_pkg.get_calendar_table (l_xtd4)|| ' cal
where cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and cal.start_date=iset.isd(+)
))group by cn,csd
)u
order by csd';

   get_blg_opn_ytd_sql ( p_param , l_backlog_ytd , l_open_ytd );

 l_query:=  get_trend_sel_clause || '  FROM ('
	 		  ||get_template_sel_clause||' FROM  '
						   ||l_template_sql || ' ))x , '||
                         '('|| l_backlog_ytd || ' )b, ' ||
                         '('|| l_open_ytd || ') o ))ORDER BY S';

l_sql_text:=replace(Replace(REplace(REPLACE(replace(replace(replace(replace(replace(l_query,'      ',' '),'     ',' '),'    ',' '),'   ',' '),'  ',' '),' (','('),'( ','('),' )',')'),') ',')');

    x_custom_sql               := '/* OKI_DBI_SRM_PDUE_G */' || l_sql_text;

    oki_dbi_util_pvt.get_custom_trend_binds (l_xtd1
                                           , l_comparison_type
                                           , x_custom_output);

  END get_trend_sql;


  FUNCTION get_trend_sel_clause
   RETURN VARCHAR2
  IS
    l_sel_clause   VARCHAR2 (10000);

  BEGIN
  	 l_sel_clause:=
   'SELECT
VIEWBY,
p_rate OKI_MEASURE_1,
c_rate OKI_MEASURE_2,
'||OKI_DBI_UTIL_PVT.change_clause('c_rate','p_rate','P') || ' OKI_MEASURE_3,
c_Or OKI_MEASURE_4,
c_Br OKI_MEASURE_5
FROM(
SELECT
csd s,
vb VIEWBY,
c_Br,
c_Or,
c_Br_iy,
c_Br_i,
c_Br_y,
c_Br_x_cum,
c_Br_x,
c_BrS,
c_BrC,
c_BrG,
c_Or_iy,
c_Or_i,
c_Or_y,
c_Or_x,
c_Or_x_cum,
c_Or_x,
c_OrS,
c_OrC,
c_OrG, '||
        POA_DBI_UTIL_PKG.rate_clause('c_Br','c_Or') || ' c_rate,'||
        POA_DBI_UTIL_PKG.rate_clause('p_Br','p_Or') || ' p_rate '||
   ' FROM(
SELECT
csd,
vb,
nvl(b.c_br,0)c_Br_iy,
nvl(b.c_br_i,0)c_br_i,
nvl(b.c_br_y,0)c_br_y,
nvl(x.c_br,0)c_Br_x_cum,
nvl(x.c_Br_x,0)c_Br_x,
nvl(x.c_BrS,0)c_BrS,
nvl(x.c_BrC,0)c_BrC,
nvl(x.c_BrG,0)c_BrG,
nvl(o.c_or,0)c_Or_iy,
nvl(o.c_or_i,0)c_or_i,
nvl(o.c_or_y,0)c_or_y,
nvl(x.c_or,0)c_Or_x_cum,
nvl(x.c_or_x,0)c_or_x,
nvl(x.c_OrS,0)c_OrS,
nvl(x.c_OrC,0)c_OrC,
nvl(x.c_OrG,0)c_OrG,
nvl(b.c_br,0)+nvl(x.c_br,0)c_br,
NVL(b.p_br,0)+NVL(x.p_br,0)p_br,
NVL(o.c_or,0)+NVL(x.c_or,0)c_or,
NVL(o.p_or,0)+NVL(x.p_or,0)p_or ';

   RETURN l_sel_clause ;

  END get_trend_sel_clause ;



  FUNCTION get_template_sel_clause
   RETURN VARCHAR2
    IS
  	l_sel_clause   VARCHAR2 (10000);
  BEGIN

 l_sel_clause:=
 ' SELECT
csd,
vb,
c_br c_br_x,
c_or c_or_x,
c_BrS,
c_BrC,
c_BrG,
c_OrS,
c_OrC,
c_OrG,
SUM(c_br)OVER(ORDER BY csd ROWS UNBOUNDED PRECEDING)c_br,
SUM(p_br)OVER(ORDER BY csd ROWS UNBOUNDED PRECEDING)p_br,
SUM(c_or)OVER(ORDER BY csd ROWS UNBOUNDED PRECEDING)c_or,
SUM(p_or)OVER(ORDER BY csd ROWS UNBOUNDED PRECEDING)p_or
FROM (
SELECT
vb,
csd,
u.c_Br1 c_BrS,
u.c_Br2 c_BrC,
u.c_Br3 c_BrG,
u.c_Or1 c_OrS,
u.c_Or2 c_OrC,
u.c_Or3 c_OrG,
NVL(u.c_Br1,0)-NVL(u.c_Br2,0)-NVL(u.c_Br3,0)c_br,
NVL(u.p_Br1,0)-NVL(u.p_Br2,0)-NVL(u.p_Br3,0)p_br,
NVL(u.c_Or1,0)-NVL(u.c_Or2,0)-NVL(u.c_Or3,0)c_Or,
NVL(u.p_Or1,0)-NVL(u.p_Or2,0)-NVL(u.p_Or3,0)p_Or ';

   RETURN l_sel_clause ;

  END get_template_sel_clause ;


  PROCEDURE get_blg_opn_ytd_sql (
     p_param  IN bis_pmv_page_parameter_tbl,
     p_backlog_ytd OUT NOCOPY VARCHAR2,
     p_open_ytd    OUT NOCOPY VARCHAR2
	)
  IS
    l_view_by                VARCHAR2 (120);
    l_view_by_col            VARCHAR2 (120);
    l_as_of_date             DATE;
    l_prev_as_of_date        DATE;
    l_xtd1                   VARCHAR2 (10);
    l_xtd2                   VARCHAR2 (10);
    l_xtd3                   VARCHAR2 (10);
    l_xtd4                   VARCHAR2 (10);

    l_comparison_type        VARCHAR2 (1);
    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2 (2);
    l_where_clause1          VARCHAR2 (2000);
    l_where_clause2          VARCHAR2 (2000);
    l_where_clause3          VARCHAR2 (2000);
    l_where_clause4          VARCHAR2 (2000);

    l_filter_where           VARCHAR2 (240);
    l_mv1                     VARCHAR2 (2000);
    l_mv2                     VARCHAR2 (2000);
    l_mv3                     VARCHAR2 (2000);
    l_mv4                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;

    l_blg_itd VARCHAR2(32767);
    l_opn_itd VARCHAR2(32767);
    l_blg_ytd VARCHAR2(32767);
    l_opn_ytd VARCHAR2(32767);


  BEGIN
   l_join_tbl          := POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl ();

     oki_dbi_util_pvt.process_parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd1
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause1
                                        , p_mv                  => l_mv1
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_ST_71'
                                        , p_rg_where            => 'Y');

     oki_dbi_util_pvt.process_parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd2
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause2
                                        , p_mv                  => l_mv2
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_SG_71'
                                        , p_rg_where            => 'Y');

     oki_dbi_util_pvt.process_parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd3
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause3
                                        , p_mv                  => l_mv3
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_CN_71'
                                        , p_rg_where            => 'Y');

     oki_dbi_util_pvt.process_parameters (p_param               => p_param
                                        , p_view_by             => l_view_by
                                        , p_view_by_col_name    => l_view_by_col
                                        , p_comparison_type     => l_comparison_type
                                        , p_xtd                 => l_xtd4
                                        , p_as_of_date          => l_as_of_date
                                        , p_prev_as_of_date     => l_prev_as_of_date
                                        , p_cur_suffix          => l_cur_suffix
                                        , p_nested_pattern      => l_nested_pattern
                                        , p_where_clause        => l_where_clause4
                                        , p_mv                  => l_mv4
                                        , p_join_tbl            => l_join_tbl
                                        , p_period_type         => l_period_type
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_CR_71'
                                        , p_rg_where            => 'Y');

  l_blg_itd := get_blg_itd_sql ( p_param  ) ;
  l_opn_itd := get_opn_itd_sql ( p_param  ) ;

  l_blg_ytd :=
  ' SELECT NVL2(COALESCE(p_b,p_b_s,p_b_c),'||
            '(NVL(p_b,0)-NVL(p_b_s,0)-NVL(p_b_c,0)),NULL)p_b_y,'||
          'NVL2( coalesce(c_b,c_b_s,c_b_c),'||
            '(NVL(c_b,0)-NVL(c_b_s,0)-NVL(c_b_c,0)),NULL)c_b_y'||
  ' FROM(select
sum(p_b)p_b,
sum(c_b)c_b,
sum(p_b_s)p_b_s,
sum(c_b_s)c_b_s,
sum(p_b_c)p_b_c,
sum(c_b_c)c_b_c
 from (with cal as(SELECT /*+ NO_MERGE */
cal.time_id ctid,
cal.record_type_id,
cal.period_type_id,
cal.report_date crd
FROM fii_time_rpt_struct_v cal
WHERE cal.report_date IN(&BIS_PREVIOUS_REPORT_START_DATE-1,&BIS_CURRENT_REPORT_START_DATE-1)
AND bitAND(cal.record_type_id,119)=cal.record_type_id)(SELECT '||
'SUM(decode(crd,&BIS_PREVIOUS_REPORT_START_DATE-1,b_r_amt_'||l_cur_suffix||'))p_b,'||
    'SUM(decode(crd,&BIS_CURRENT_REPORT_START_DATE-1,b_r_amt_'||l_cur_suffix||'))c_b, 0 p_b_s,0 c_b_s,0 p_b_c,0 c_b_c '||
  'FROM '||l_mv1||' fact,cal WHERE fact.time_id=ctid '||
     l_where_clause1 ||')
UNION ALL
(SELECT 0 p_b,0 c_b,'||
    'SUM(decode(crd,&BIS_PREVIOUS_REPORT_START_DATE-1,b_rgr_amt_'||l_cur_suffix||'))p_b_s,'||
    'SUM(decode(crd,&BIS_CURRENT_REPORT_START_DATE-1,b_rgr_amt_'||l_cur_suffix||'))c_b_s,0 p_b_c,0 c_b_c '||
  'FROM '||l_mv2||' fact,cal WHERE fact.time_id=ctid '||
     l_where_clause2 ||')
UNION ALL
(SELECT 0 p_b,0 c_b,0 p_b_s,0 c_b_s,'||
    'SUM(decode(crd,&BIS_PREVIOUS_REPORT_START_DATE-1,b_rcr_amt_'||l_cur_suffix||'))p_b_c,'||
    'SUM(decode(crd,&BIS_CURRENT_REPORT_START_DATE-1,b_rcr_amt_'||l_cur_suffix||'))c_b_c '||
  ' FROM '||l_mv3||' fact,cal WHERE fact.time_id=ctid '||
     l_where_clause3 ||')))';


  l_opn_ytd :=
  ' SELECT NVL2(COALESCE(p_o,p_o_s,p_o_c),'||
            '(NVL(p_o,0)-NVL(p_o_s,0)-NVL(p_o_c,0)),NULL)p_o_y,'||
          'NVL2( coalesce(c_o,c_o_s,c_o_c),'||
            '(NVL(c_o,0)-NVL(c_o_s,0)-NVL(c_o_c,0)),NULL)c_o_y'||
  ' FROM(select
sum(p_o)p_o,
sum(c_o)c_o,
sum(p_o_s)p_o_s,
sum(c_o_s)c_o_s,
sum(p_o_c)p_o_c,
sum(c_o_c)c_o_c
 from(with cal as(SELECT /*+ NO_MERGE */
cal.time_id ctid,
cal.record_type_id,
cal.period_type_id,
cal.report_date crd
FROM fii_time_rpt_struct_v cal
WHERE cal.report_date IN(&BIS_PREVIOUS_REPORT_START_DATE-1,&BIS_CURRENT_REPORT_START_DATE-1)
AND bitAND(cal.record_type_id,119)=cal.record_type_id)(SELECT '||
'SUM(decode(crd,&BIS_PREVIOUS_REPORT_START_DATE-1,o_r_amt_'||l_cur_suffix||'))p_o,'||
    'SUM(decode(crd,&BIS_CURRENT_REPORT_START_DATE-1,o_r_amt_'||l_cur_suffix||'))c_o,0 p_o_s,0 c_o_s,0 p_o_c,0 c_o_c '||
  'FROM '||l_mv4||' fact,cal WHERE fact.time_id=ctid '||
     l_where_clause4 ||')
UNION ALL
(SELECT 0 p_o,0 c_o,'||
    'SUM(decode(crd,&BIS_PREVIOUS_REPORT_START_DATE-1,o_rgr_amt_'||l_cur_suffix||'))p_o_s,'||
    'SUM(decode(crd,&BIS_CURRENT_REPORT_START_DATE-1,o_rgr_amt_'||l_cur_suffix||'))c_o_s,0 p_o_c,0 c_o_c '||
  'FROM '||l_mv2||' fact,cal WHERE fact.time_id=ctid '||
     l_where_clause2 ||')
UNION ALL
(SELECT 0 p_o,0 c_o,0 p_o_s,0 c_o_s,'||
    'SUM(decode(crd,&BIS_PREVIOUS_REPORT_START_DATE-1,o_rcr_amt_'||l_cur_suffix||'))p_o_c,'||
    'SUM(decode(crd,&BIS_CURRENT_REPORT_START_DATE-1,o_rcr_amt_'||l_cur_suffix||'))c_o_c '||
  ' FROM '||l_mv3||' fact,cal WHERE fact.time_id=ctid '||
     l_where_clause3 ||')))';

  p_backlog_ytd :=
  ' SELECT c_b_i c_br_i,
c_b_y c_br_y,
NVL2(COALESCE(p_b_i,p_b_y),nvl(p_b_i,0)+nvl(p_b_y,0),NULL)p_br,'||
         'NVL2(COALESCE(c_b_i,c_b_y),nvl(c_b_i,0)+nvl(c_b_y,0),NULL) c_br'||
  ' FROM('|| l_blg_itd ||')i,'||
       '('|| l_blg_ytd ||')y ';

  p_open_ytd :=
  ' SELECT c_o_i c_or_i,
c_o_y c_or_y,
 NVL2(COALESCE(p_o_i,p_o_y),nvl(p_o_i,0)+nvl(p_o_y,0),NULL)p_or,'||
         ' NVL2(COALESCE(c_o_i,c_o_y),nvl(c_o_i,0)+nvl(c_o_y,0),NULL)c_or '||
  ' FROM('|| l_opn_itd ||')i , '||
       '('|| l_opn_ytd ||')y ';


 END get_blg_opn_ytd_sql;


    FUNCTION get_blg_itd_sql (
     p_param  IN bis_pmv_page_parameter_tbl
	) RETURN VARCHAR2
  IS
    l_view_by                VARCHAR2 (120);
    l_view_by_col            VARCHAR2 (120);
    l_as_of_date             DATE;
    l_prev_as_of_date        DATE;
    l_xtd                    VARCHAR2 (10);
    l_comparison_type        VARCHAR2 (1);
    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2 (2);
    l_where_clause           VARCHAR2 (2000);
    l_filter_where           VARCHAR2 (240);
    l_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;


    l_blg_mv                 VARCHAR2(100);
    l_blg_sql                VARCHAR2(10000);

    l_select0                varchar2(1000);
    l_select                 varchar2(32767);
    l_query                  varchar2(32767);


  BEGIN
    l_comparison_type   := 'Y';
    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();


    oki_dbi_util_pvt.process_parameters (p_param               => p_param
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
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_BLG'
                                        , p_rg_where            => 'Y');

   l_query :=

  'SELECT SUM(decode(cal.report_date,&BIS_PREVIOUS_REPORT_START_DATE-1,b_r_amt_'||l_cur_suffix||'))p_b_i,'||
         'SUM(decode(cal.report_date,&BIS_CURRENT_REPORT_START_DATE-1,b_r_amt_'||l_cur_suffix||'))c_b_i '||
    'FROM '||l_mv||' fact,fii_time_day cal WHERE fact.ent_year_id=cal.ent_year_id'||
    ' AND cal.report_date IN(&BIS_PREVIOUS_REPORT_START_DATE-1,&BIS_CURRENT_REPORT_START_DATE-1)'||
    l_where_clause;

  RETURN l_query;

 END get_blg_itd_sql;


    FUNCTION get_opn_itd_sql (
     p_param  IN bis_pmv_page_parameter_tbl
	) RETURN VARCHAR2
  IS
    l_view_by                VARCHAR2 (120);
    l_view_by_col            VARCHAR2 (120);
    l_as_of_date             DATE;
    l_prev_as_of_date        DATE;
    l_xtd                    VARCHAR2 (10);
    l_comparison_type        VARCHAR2 (1);
    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2 (2);
    l_where_clause           VARCHAR2 (2000);
    l_filter_where           VARCHAR2 (240);
    l_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;


    l_blg_mv                 VARCHAR2(100);
    l_blg_sql                VARCHAR2(10000);

    l_select0                varchar2(1000);
    l_select                 varchar2(32767);
    l_query                  varchar2(32767);


  BEGIN
    l_comparison_type   := 'Y';
    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();


    oki_dbi_util_pvt.process_parameters (p_param               => p_param
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
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_OPN'
                                        , p_rg_where            => 'Y');

   l_query :=

  'SELECT SUM(decode(cal.report_date,&BIS_PREVIOUS_REPORT_START_DATE-1,o_r_amt_'||l_cur_suffix||'))p_o_i,'||
         'SUM(decode(cal.report_date,&BIS_CURRENT_REPORT_START_DATE-1,o_r_amt_'||l_cur_suffix||'))c_o_i '||
    'FROM '||l_mv||' fact,fii_time_day cal WHERE fact.ent_year_id=cal.ent_year_id'||
    ' AND cal.report_date IN (&BIS_PREVIOUS_REPORT_START_DATE-1,&BIS_CURRENT_REPORT_START_DATE-1)'||
    l_where_clause;

  RETURN l_query;

 END get_opn_itd_sql;


/*******************************************************************************
  PROCEDURE get_pastduevalue_by_customer_sql() returns the SQL query by adding
  the ITD measures and YTD Measures to calculate the past due value.
/*******************************************************************************/

PROCEDURE get_pdueval_cust_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl)
  IS
    l_query                  VARCHAR2 (32767);

  BEGIN

     l_query:='Hello';

     x_custom_sql               := '/* OKI_DBI_SRM_PDUE_CRPT */' || l_query;

     oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

  END get_pdueval_cust_sql;

/*******************************************************************************
 FUNCTION get_PDueVal_cust_sel_clause() returns the top most select
 statment of SQL query by adding p the ITD measures and YTD Measures.
/*******************************************************************************/
/*
FUNCTION get_pdueVal_cust_sel_clause
RETURN VARCHAR2
AS
    l_query                  VARCHAR2 (32767);
    l_pdue_url               VARCHAR2 (1000);

BEGIN


l_pdue_url:= '''pFunctionName=OKI_DBI_SRM_PDUE_DTL_DRPT&FII_CUSTOMERS=OKI_ATTRIBUTE_1'' OKI_DYNAMIC_URL_1 ';

RETURN     l_query ;
END get_PDueVal_cust_sel_clause;
*/

/*******************************************************************************
  FUNCTION get_YTD_by_cust_sql() returns the portion of the SQL query containing
  YTD measures.
/*******************************************************************************/
/*
FUNCTION get_YTD_by_cust_sql(p_param  IN bis_pmv_page_parameter_tbl)
RETURN VARCHAR2
AS
    l_query                  VARCHAR2 (32767);

  BEGIN

END get_YTD_by_cust_sql;
*/

/*******************************************************************************
  FUNCTION get_YTD_by_cust_sel_clause() returns the SQL select portion of the query for
  YTD measures.
/*******************************************************************************/
/*
FUNCTION get_YTD_by_cust_sel_clause
RETURN VARCHAR2
AS
l_query VARCHAR2(2000);
BEGIN
RETURN l_query;

END get_YTD_by_cust_sel_clause;
*/

/******************************************************************************
 FUNCTION get_ITD_by_cust_sql() returns the SQL portion of the Query containing
 ITD measures.
/******************************************************************************/
/*
FUNCTION get_ITD_by_cust_sql(p_param  IN bis_pmv_page_parameter_tbl)
RETURN VARCHAR2
AS
    l_query                  VARCHAR2 (32767);
   BEGIN
     return l_ITD_sql;

END get_ITD_by_cust_sql;
*/

/******************************************************************************
 FUNCTION get_ITD_by_cust_sel_clause() returns the select clause containing all
 the ITD measures
/******************************************************************************/
/*
FUNCTION get_ITD_by_cust_sel_clause
RETURN VARCHAR2
AS
l_query VARCHAR2(2000);
BEGIN
RETURN l_query;
END get_ITD_by_cust_sel_clause;
*/


END OKI_DBI_SRM_PDUE_PVT;

/
