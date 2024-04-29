--------------------------------------------------------
--  DDL for Package Body OKI_DBI_SRM_PRNWL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_SRM_PRNWL_PVT" AS
/* $Header: OKIIPRNB.pls 120.3 2006/05/18 04:26:55 asparama noship $ */

 FUNCTION get_table_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2;

 FUNCTION get_bookings_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2)
    RETURN VARCHAR2;


--dbi7.0
/* FUNCTION get_bkngs_by_cust_sel_clause
   RETURN VARCHAR2;
*/

/*******************************************************************************
  Function: get_table_sql
  Description: Function to get Period Renewals Summary Report DBI 6.0
*******************************************************************************/


PROCEDURE get_table_sql (

    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl)
  IS

    l_query                  VARCHAR2(32767);
    l_view_by                VARCHAR2(120);
    l_view_by_col            VARCHAR2(120);
    l_xtd1                   VARCHAR2(10);
    l_xtd2                   VARCHAR2(10);
    l_as_of_date             DATE;
    l_prev_as_of_date        DATE;
    l_comparison_type        VARCHAR2(1);

    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2(2);
    l_col_tbl1               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl2               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
   l_mv_tbl                 poa_dbi_util_pkg.poa_dbi_mv_tbl;

    l_where_clause1           VARCHAR2(2000);
    l_where_clause2           VARCHAR2(2000);
    l_filter_where           VARCHAR2(240);
    l_mv1                    VARCHAR2(2000);
    l_mv2                    VARCHAR2(2000);


    l_to_date_xed            VARCHAR2(3);
    l_to_date_xtd            VARCHAR2(3);
    l_to_date_ytd            VARCHAR2(3);
    l_to_date_itd            VARCHAR2(3);

    l_period_ytd_sql    VARCHAR2(32767);
    l_viewby_rank_where      VARCHAR2(32767);
    l_ytd_sel_clause         VARCHAR2(32767);

    l_mv_1		VARCHAR2(100);
    l_mv_2		VARCHAR2(100);

    l_ytd_sel1  VARCHAR2(5000);

    l_ytd_sel2  VARCHAR2(5000);

    l_pcflag  VARCHAR2(500);
    l_ouflag  VARCHAR2(500);
    l_ccflag  VARCHAR2(500);
    l_umark  VARCHAR2(500);

    l_sg		VARCHAR2(32000);
    l_org 		VARCHAR2(32000);
    l_prod		VARCHAR2(32000);
    l_prod_cat		VARCHAR2(32000);

BEGIN

  l_to_date_xed       := 'XED';
  l_to_date_xtd       := 'XTD';
  l_comparison_type   := 'Y';
  l_to_date_ytd       := 'YTD';
  l_to_date_itd       := 'ITD';
  l_join_tbl          := POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl ();
  l_col_tbl1          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_col_tbl2          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_mv_tbl            := poa_dbi_util_pkg.poa_dbi_mv_tbl ();
  l_ytd_sel_clause    := '';

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

    -- Period Renewal node

  poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 's_r_amt_' || l_cur_suffix
                               , p_alias_name      => 'Scr'
                               , p_to_date_type    => l_to_date_xed);



  poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 'c_scr_amt_' || l_cur_suffix
                               , p_alias_name      => 'CScr'
                               , p_to_date_type    => l_to_date_xed);


  poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 's_gpr_amt_'||l_period_type||'_' || l_cur_suffix
                               , p_alias_name      => 'ScGpr'
                               , p_to_date_type    => l_to_date_xed);



  poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 's_gpo_amt_'||l_period_type||'_' || l_cur_suffix
                               , p_alias_name      => 'ScGpo'
                               , p_to_date_type    => l_to_date_xed);



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

  poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl2
                               , p_col_name        => 'g_scr_amt_'||l_period_type||'_' || l_cur_suffix
                               , p_alias_name      => 'ScGr'
                               , p_to_date_type    => l_to_date_xtd);


  poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl2
                               , p_col_name        => 'g_sco_amt_'||l_period_type||'_' || l_cur_suffix
                               , p_alias_name      => 'ScGo'
                               , p_to_date_type    => l_to_date_xtd);


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
  l_mv_tbl(1).use_grp_id := 'N';



  /* Additional filter needed to avoid displaying records queried due to total values at node */

  l_filter_where  := '  ( ABS(oki_measure_1) + ABS(oki_measure_2) + ABS(oki_measure_5) ) <> 0 ';
--  l_filter_where  := ' 1=1 ';


  /* Building the query */

--  l_query := get_table_sel_clause (l_view_by, l_view_by_col)
--                || ' FROM '
--                || l_period_ytd_sql;

  l_query := get_table_sel_clause (l_view_by, l_view_by_col) -- in poa : l_join_tbl

              || ' from (
            ' || poa_dbi_template_pkg.union_all_status_sql
						 (p_mv       => l_mv_tbl,
                                                  p_join_tables     => l_join_tbl,
                                                  p_use_windowing   => 'Y',
                                                  p_paren_count     => 7,
                                                  p_filter_where    => l_filter_where );




  x_custom_sql := '/* New OKI_DBI_SRM_PRNWL_SUM_RPT */' || l_query;
  oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

END get_table_sql;

  /*


     Period Renewal Summary  Select clause

  */

  FUNCTION get_table_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2

  IS

    l_sel_clause         VARCHAR2 (32767);
    l_bookings_url       VARCHAR2(300);

    l_prodcat_url        VARCHAR2(300);
 --   l_rrate_url        VARCHAR2(300);
    l_viewby_select      VARCHAR2(32767);
    l_url_select         VARCHAR2(32767);

  BEGIN


    l_viewby_select := oki_dbi_util_pvt.get_viewby_select_clause(p_view_by_dim, 'SRM', '6.0');

    -- Bookings URL when view by is Salesrep

     l_bookings_url  := '''pFunctionName=OKI_DBI_SRM_PRNWL_BKING_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY='||p_view_by_dim||'''';


    --l_bookings_url  := '''pFunctionName=OKI_DBI_SRM_PRNWL_BKING_RPT''';

  --  l_rrate_url  := '''pFunctionName=OKI_DBI_SRM_PRNWL_RATE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY='||p_view_by_dim||'''';

    --l_rrate_url :='''OKI_DBI_SRM_PRNWL_RATE_DRPT''';

	IF(p_view_by_dim = 'ITEM+ENI_ITEM_PROD_LEAF_CAT')
           THEN
	       l_prodcat_url :=
	           ' decode(leaf_node_flag,''Y''
             , ''pFunctionName=OKI_DBI_SRM_PRNWL_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM''
             ,''pFunctionName=OKI_DBI_SRM_PRNWL_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT'' ) OKI_DYNAMIC_URL_4 ';

	    ELSE
	       l_prodcat_url := ''''' OKI_DYNAMIC_URL_4 ';
        END IF;



    l_viewby_select  :=  l_viewby_select ||

   ',OKI_DYNAMIC_URL_1
    ,OKI_DYNAMIC_URL_2
    ,' ||l_prodcat_url || '
    ,oki_measure_1
    ,oki_measure_2

    ,oki_measure_3
    ,oki_measure_4
    ,oki_measure_5
    ,oki_measure_6
    ,oki_measure_7
    ,oki_measure_8
    ,oki_measure_11
    ,oki_measure_12
    ,oki_measure_13
    ,oki_measure_14
    ,oki_measure_15
    ,oki_measure_16
    ,oki_measure_17

    ,oki_measure_18
    ,oki_measure_23
    ,oki_measure_26
    ,oki_calc_item1
    ,oki_calc_item2
    ,oki_calc_item3
    ,oki_calc_item4
    ,oki_calc_item5
    ,oki_calc_item6
    ,oki_calc_item7
    ,oki_calc_item8
    ,oki_calc_item11
    ,oki_calc_item12

    ,oki_calc_item13
    ,oki_calc_item14
    ,oki_calc_item15
    ,oki_calc_item16
    ,oki_calc_item17
    ,oki_calc_item18

      FROM (
             SELECT
                   rank() over (&ORDER_BY_CLAUSE nulls last , '||p_view_by_col||') - 1 rnk
                   ,'||p_view_by_col||'
                   ,OKI_DYNAMIC_URL_1
                   ,OKI_DYNAMIC_URL_2

                   ,oki_measure_1
                   ,oki_measure_2
                   ,oki_measure_3
                   ,oki_measure_4
                   ,oki_measure_5
                   ,oki_measure_6
                   ,oki_measure_7
		   ,oki_measure_8
                   ,oki_measure_11
                   ,oki_measure_12
                   ,oki_measure_13
                   ,oki_measure_14
                   ,oki_measure_15

                   ,oki_measure_16
                   ,oki_measure_17
                   ,sum(oki_measure_8) over() oki_measure_18
                   ,oki_measure_23
                   ,oki_measure_26
                   ,oki_calc_item1
                   ,oki_calc_item2
                   ,oki_calc_item3
                   ,oki_calc_item4
                   ,oki_calc_item5
                   ,oki_calc_item6
                   ,oki_calc_item7
                   ,oki_calc_item8

                   ,oki_calc_item11
                   ,oki_calc_item12
                   ,oki_calc_item13
                   ,oki_calc_item14
                   ,oki_calc_item15
                   ,oki_calc_item16
                   ,oki_calc_item17
                   ,oki_calc_item18

       			FROM ( ';

      --                ' , decode(resource_id,-999,'''','||l_bookings_url||') OKI_DYNAMIC_URL_2 '||
      --      	      ' , decode(resource_id,-999,'||l_rrate_url||','||l_rrate_url||') OKI_DYNAMIC_URL_3 ';



   IF(p_view_by_dim = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
      THEN
         l_url_select :=
            'SELECT  decode(resource_id,-999,''pFunctionName=OKI_DBI_SRM_PRNWL_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'','''') OKI_DYNAMIC_URL_1 '||
    ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_bookings_url||')) OKI_DYNAMIC_URL_2 ';
    ELSIF(p_view_by_dim = 'ITEM+ENI_ITEM')
      THEN
         l_url_select :=
            'SELECT  '''' OKI_DYNAMIC_URL_1 '||
                    ' , '||l_bookings_url||' OKI_DYNAMIC_URL_2 ';

      ELSE
         l_url_select :=
            'SELECT  '''' OKI_DYNAMIC_URL_1 '||
                    ' , '''' OKI_DYNAMIC_URL_2 ';
    END IF;


      l_sel_clause               := l_viewby_select || l_url_select ||

          '   ,'|| p_view_by_col ||

          ' , oset20.c_Rnw oki_measure_1 '||


          ' , oset20.c_Bkg oki_measure_2 '||

          ' , oset20.c_rnwl_rate oki_measure_3 '||

          ' , oset20.rnwl_rate_chg oki_measure_4 '||

          ' , oset20.Can oki_measure_5 '||

          ' , oset20.C_Upl oki_measure_6 '||

          ' , oset20.Upl_chg oki_measure_7 '||

          ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset20.c_Rnw','oset20.C_Rnw_tot') || ' oki_measure_8 '||


          ' , oset20.C_Rnw_tot oki_measure_11 '||

          ' , oset20.C_Bkg_tot oki_measure_12 '||

          ' , oset20.C_rnwl_rate_tot oki_measure_13 '||

          ' , oset20.rnwl_rate_chg_tot oki_measure_14 '||

          ' , oset20.Can_tot oki_measure_15 '||

          ' , oset20.C_Upl_tot oki_measure_16 '||


          ' , oset20.Upl_chg_tot oki_measure_17 '||

          ' , oset20.p_rnwl_rate oki_measure_23 '||

          ' , oset20.P_Upl oki_measure_26 '||

          ' , oset20.c_Rnw oki_calc_item1 '||

          ' , oset20.c_Rnw_tot oki_calc_item11 '||

          ' , oset20.P_Rnw oki_calc_item2 '||

          ' , oset20.P_Rnw_tot oki_calc_item12 '||


          ' , oset20.C_Bkg oki_calc_item3 '||

          ' , oset20.C_Bkg_tot oki_calc_item13 '||

          ' , oset20.P_Bkg oki_calc_item4 '||

          ' , oset20.P_Bkg_tot oki_calc_item14 '||

          ' , oset20.C_rnwl_rate oki_calc_item5 '||

          ' , oset20.C_rnwl_rate_tot oki_calc_item15 '||


          ' , oset20.P_rnwl_rate oki_calc_item6 '||

          ' , oset20.P_rnwl_rate_tot oki_calc_item16 '||

          ' , oset20.C_Upl oki_calc_item7 '||

          ' , oset20.C_Upl_tot oki_calc_item17 '||

          ' , oset20.P_Upl oki_calc_item8 '||

          ' , oset20.P_Upl_tot oki_calc_item18 '||

          '   from '||


          '   ( select '||

          '    '|| p_view_by_col ||

          '   , oset15.c_Scr c_Rnw '||

          '   , oset15.p_Scr p_Rnw '||

          '   , oset15.c_ScGpGr c_Bkg '||

          '   , oset15.p_ScGpGr p_Bkg '||


          '   , oset15.c_rnwl_Rate c_rnwl_rate '||

          '   , oset15.p_rnwl_Rate p_rnwl_rate '||

          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_rnwl_Rate','oset15.p_rnwl_Rate','P') || ' rnwl_rate_chg '||

          '   , oset15.CScr Can '||

          '   , oset15.c_Upl c_Upl '||

          '   , oset15.p_Upl P_Upl '||

          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_Upl','oset15.p_Upl','NP') || ' Upl_chg '||


          '   , oset15.c_Scr_tot C_Rnw_tot '||

          '   , oset15.p_Scr_tot P_Rnw_tot '||

          '   , oset15.c_ScGpGr_tot C_Bkg_tot '||

          '   , oset15.p_ScGpGr_tot P_Bkg_tot '||

          '   , oset15.c_rnwl_Rate_tot C_rnwl_rate_tot '||

          '   , oset15.p_rnwl_Rate_tot P_rnwl_rate_tot '||


          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_rnwl_Rate_tot','oset15.p_rnwl_Rate_tot','P') || ' rnwl_rate_chg_tot '||

          '   , oset15.CScr_tot Can_tot '||

          '   , oset15.c_Upl_tot C_Upl_tot '||

          '   , oset15.p_Upl_tot P_Upl_tot '||

          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_Upl_tot','oset15.p_Upl_tot','NP') || ' Upl_chg_tot '||

          '   from  '||

          '    (select '||


                p_view_by_col ||

               ' , oset13.c_Scr '||

               ' , oset13.p_Scr '||

               ' , oset13.c_ScGpGr '||

               ' , oset13.c_ScGpGo '||

               ' , oset13.p_ScGpGr '||


               ' , oset13.p_ScGpGo '||

               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.c_ScGpGr','oset13.c_Scr') || 'c_rnwl_Rate '||

               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.p_ScGpGr','oset13.p_Scr') || 'p_rnwl_Rate '||

               ' , oset13.CScr '||

               ' , oset13.c_Scr_tot '||

               ' , oset13.p_Scr_tot '||

               ' , oset13.c_ScGpGr_tot '||


               ' , oset13.c_ScGpGo_tot '||

               ' , oset13.p_ScGpGr_tot '||

               ' , oset13.p_ScGpGo_tot '||

               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.c_ScGpGr_tot','oset13.c_Scr_tot') || ' c_rnwl_Rate_tot '||

               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.p_ScGpGr_tot','oset13.p_Scr_tot') || ' p_rnwl_Rate_tot '||

               ' , oset13.CScr_tot '||


               ' ,'|| OKI_DBI_UTIL_PVT.subtract_measures('oset13.c_ScGpGr','oset13.c_ScGpGo') ||' c_Upl '||

               ' ,'|| OKI_DBI_UTIL_PVT.subtract_measures('oset13.p_ScGpGr','oset13.p_ScGpGo') ||' p_Upl '||

               ' ,'|| OKI_DBI_UTIL_PVT.subtract_measures('oset13.c_ScGpGr_tot','oset13.c_ScGpGo_tot') ||' c_Upl_tot '||

               ' ,'|| OKI_DBI_UTIL_PVT.subtract_measures('oset13.p_ScGpGr_tot','oset13.p_ScGpGo_tot') ||' p_Upl_tot '||

          '   from  '||

          '     (select '||

                -- For use in where condition to join to the dimension table


                p_view_by_col ||

               ' , oset10.c_Scr c_Scr '||

               ' , oset10.p_Scr p_Scr '||

               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset10.c_ScGpr','oset10.c_ScGr') ||' c_ScGpGr '||

               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset10.c_ScGpo','oset10.c_ScGo') ||' c_ScGpGo '||

               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset10.p_ScGpr','oset10.p_ScGr') ||' p_ScGpGr '||


               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset10.p_ScGpo','oset10.p_ScGo') ||' p_ScGpGo '||

               ' , oset10.c_CScr CScr '||

               ' , oset10.c_Scr_tot c_Scr_tot '||

               ' , oset10.p_Scr_tot p_Scr_tot '||

               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset10.c_ScGpr_tot','oset10.c_ScGr_tot') ||' c_ScGpGr_tot '||

               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset10.c_ScGpo_tot','oset10.c_ScGo_tot') ||' c_ScGpGo_tot '||

               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset10.p_ScGpr_tot','oset10.p_ScGr_tot') ||' p_ScGpGr_tot '||


               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset10.p_ScGpo_tot','oset10.p_ScGo_tot') ||' p_ScGpGo_tot '||

               ' , oset10.c_CScr_tot CScr_tot '||

               ' from '||

               '   ( select '||

               '        oset05.'||p_view_by_col ||

               '      , nvl(oset05.c_Scr,0) c_Scr '||


               '      , nvl(oset05.c_CScr,0) c_CScr '||

               '      , nvl(oset05.c_ScGpr,0) c_ScGpr '||

               '      , nvl(oset05.c_ScGpo,0) c_ScGpo '||

               '      , nvl(oset05.c_ScGr,0) c_ScGr '||

               '      , nvl(oset05.c_ScGo,0) c_ScGo '||

               '      , nvl(oset05.p_Scr,0) p_Scr '||

               '      , nvl(oset05.p_CScr,0) p_CScr '||


               '      , nvl(oset05.p_ScGpr,0) p_ScGpr '||

               '      , nvl(oset05.p_ScGpo,0) p_ScGpo '||

               '      , nvl(oset05.p_ScGr,0) p_ScGr '||

               '      , nvl(oset05.p_ScGo,0) p_ScGo '||

               '      , nvl(oset05.c_Scr_total,0) c_Scr_tot '||

               '      , nvl(oset05.c_CScr_total,0) c_CScr_tot '||


               '      , nvl(oset05.c_ScGpr_total,0) c_ScGpr_tot '||

               '      , nvl(oset05.c_ScGpo_total,0) c_ScGpo_tot '||

               '      , nvl(oset05.c_ScGr_total,0) c_ScGr_tot '||

               '      , nvl(oset05.c_ScGo_total,0) c_ScGo_tot '||

               '      , nvl(oset05.p_Scr_total,0) p_Scr_tot '||

               '      , nvl(oset05.p_CScr_total,0) p_CScr_tot '||

               '      , nvl(oset05.p_ScGpr_total,0) p_ScGpr_tot '||


               '      , nvl(oset05.p_ScGpo_total,0) p_ScGpo_tot '||

               '      , nvl(oset05.p_ScGr_total,0) p_ScGr_tot '||

               '      , nvl(oset05.p_ScGo_total,0) p_ScGo_tot ';




    RETURN l_sel_clause;

  END get_table_sel_clause;



   PROCEDURE get_bookings_sql (

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
    l_curr_suffix             VARCHAR2 (2);
    l_where_clause           VARCHAR2 (2000);
    l_mv                     VARCHAR2 (2000);
    l_additional_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed    VARCHAR2 (3) ;
    l_to_date_xtd    VARCHAR2 (3);

    l_rpt_specific_where     VARCHAR2 (1000);
    l_join_where             VARCHAR2 (1000);
    l_group_by               VARCHAR2 (1000);

    l_filter_where           VARCHAR2 (240);

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
                                        , p_cur_suffix          => l_curr_suffix
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
      ' AND  fact.renewal_flag in (1,3)
        AND  fact.start_date between &BIS_CURRENT_EFFECTIVE_START_DATE
                                and &BIS_CURRENT_EFFECTIVE_END_DATE
        AND  fact.date_signed <= &BIS_CURRENT_ASOF_DATE';

    l_group_by              := ' GROUP BY fact.chr_id, fact.customer_party_id, fact.resource_id,fact.date_signed';

    poa_dbi_util_pkg.add_column (p_col_tbl       => l_col_tbl
                               , p_col_name      => 'price_negotiated_' || l_curr_suffix
                               , p_alias_name    => 'affected_value'
                               , p_prior_code    => poa_dbi_util_pkg.no_priors);

    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();

        oki_dbi_util_pvt.join_rpt_where (p_join_tbl     => l_join_tbl
                                        , p_func_area    => 'SRM'
                                        , p_version      => '6.0'
                                        , p_role         => NULL
                                        , p_mv_set       => 'SRM_CDTL_RPT');

   /* Additional filter needed to avoid displaying records queried due to total values at node */
   l_filter_where  := ' ( ABS(oki_measure_1) ) <> 0 ';
   l_additional_mv := ' ) fact
                       , OKI_SCM_OCR_MV k
                       WHERE fact.chr_id = k.chr_id) ';
    l_query                 := get_bookings_sel_clause (l_curr_suffix, l_period_type )
                       || poa_dbi_template_pkg.dtl_status_sql2 (
                                               p_fact_name         => l_mv
                                             , p_where_clause      => l_where_clause || l_rpt_specific_where
                                             , p_join_tables       => l_join_tbl
                                             , p_use_windowing     => 'Y'
                                             , p_col_name          => l_col_tbl
                                             , p_use_grpid         => 'N'
                                             , p_filter_where      => l_filter_where || l_additional_mv
                                             , p_paren_count       => 5
                                             , p_group_by          => l_group_by
                                             , p_from_clause       => ' from '||l_mv ||' fact ');

    x_custom_sql            := '/* OKI_DBI_SRM_PRNWL_BKING_RPT */' || l_query;



    oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

END get_bookings_sql;


  FUNCTION get_bookings_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_query   VARCHAR2 (10000);

  BEGIN

    -- Generate sql query
    l_query                    :=
        'SELECT
 complete_k_number oki_attribute_1
, cust.value oki_attribute_2
, DECODE(fact.resource_id,-1,&UNASSIGNED,rsex.resource_name) oki_attribute_3
, to_char(date_signed) OKI_DATE_1
, to_char(start_date) OKI_DATE_2
, to_char(end_date) OKI_DATE_3
, oki_measure_1
, OKI_MEASURE_2
, oki_measure_11
, OKI_MEASURE_12
, fact.chr_id OKI_ATTRIBUTE_5
FROM
(
SELECT * FROM
((
SELECT
fact.*
, k.complete_k_number
, k.start_date start_date
, k.end_date end_date
, NVL(k.price_nego_' ||p_cur_suffix ||',0) OKI_MEASURE_2
, NVL(SUM(k.price_nego_' ||p_cur_suffix ||') over (),0) OKI_MEASURE_12
FROM
(
SELECT rank() over (ORDER BY OKI_MEASURE_1 DESC nulls last) - 1 rnk
, chr_id
, customer_party_id
, resource_id
, oki_measure_1
, oki_measure_11
, date_signed
FROM
(
SELECT oset5.chr_id
, oset5.customer_party_id
, oset5.resource_id
, nvl(oset5.affected_value,0) OKI_MEASURE_1
, nvl(oset5.affected_value_total,0) OKI_MEASURE_11
, oset5.date_signed
FROM
(
SELECT fact.chr_id, fact.customer_party_id , fact.resource_id,fact.date_signed';
     RETURN l_query;
  END get_bookings_sel_clause;


/* This procedure generates the entire SQL query that is required for the report
 * Period Renewal Bookings By Customer.
 *
 * p_param      -->a table populated by PMV which contains all the parameters that
 *                 the user selects in the report
 * x_custom_sql -->the final SQL query that is generated
 * x_custom_output -->contains the bind variables
 */


/*******************************************************************************
* FUNCTION get_bkngs_by_cust_sql () returns the select clause containing
  the measures for the report
********************************************************************************/
/*
 FUNCTION get_bkngs_by_cust_sel_clause
  RETURN VARCHAR2
  IS
    l_query  VARCHAR2(10000);
     BEGIN

    l_query                    :='';
 RETURN    l_query;

 END  get_bkngs_by_cust_sel_clause;
*/


/* This procedure generates the entire SQL query that is required for the report
 * Period Renewal Bookings By Customer.
 *
 * p_param      -->a table populated by PMV which contains all the parameters that
 *                 the user selects in the report
 * x_custom_sql -->the final SQL query that is generated
 * x_custom_output -->contains the bind variables
 */


 PROCEDURE get_bkngs_by_cust_sql (

    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl)

  IS
    l_query                  VARCHAR2 (32767);

     BEGIN

    l_query                 := 'Hello';


    x_custom_sql               := '/* OKI_DBI_SRM_PRNWL_SUM_CRPT */' || l_query;

    oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

 END get_bkngs_by_cust_sql;
/*******************************************************************************
* FUNCTION get_bkngs_by_cust_sql () returns the select clause containing
  the measures for the report
********************************************************************************/
/*
 FUNCTION get_bkngs_by_cust_sel_clause
  RETURN VARCHAR2
  IS

    l_query  VARCHAR2(10000);
     BEGIN

    l_query                    :='';
 RETURN    l_query;

 END  get_bkngs_by_cust_sel_clause;
*/

  PROCEDURE get_rrate_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl)

  IS

    l_query                  VARCHAR2 (32767);
    l_view_by                VARCHAR2 (12000);
    l_view_by_col            VARCHAR2 (12000);
    l_as_of_date             DATE;
    l_prev_as_of_date        DATE;
    l_xtd                    VARCHAR2 (10);
    l_comparison_type        VARCHAR2 (1) ;
    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2 (22);
    l_where_clause           VARCHAR2 (20000);

    l_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed    VARCHAR2 (3);
    l_to_date_xtd    VARCHAR2 (3);
    l_view_by_table          VARCHAR2(10000);

    l_viewby_select      VARCHAR2(10000);
    l_url_select         VARCHAR2(20000);
    l_FROM_WHERE         VARCHAR2(20000);
    l_viewby_col_special VARCHAR2(1160); -- Needed when the view by is resource group id
    l_filter_where       VARCHAR2(20000);
    l_VIEWBY_RANK_ORDER  VARCHAR2(20000);

    l_prodcat_url        VARCHAR2(1300);


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

	           ' decode(leaf_node_flag,''Y''
           , ''pFunctionName=OKI_DBI_SRM_PRNWL_RATE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM''
           ,''pFunctionName=OKI_DBI_SRM_PRNWL_RATE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT'' ) OKI_DYNAMIC_URL_2 ';
	    ELSE
	       l_prodcat_url := ''''' OKI_DYNAMIC_URL_2 ';
       END IF;

    l_viewby_select := oki_dbi_util_pvt.get_viewby_select_clause(l_view_by, 'SRM', '6.0');


   /* Additional filter needed to avoid displaying records queried due to total values at node */

   l_filter_where  := ' AND  ( ABS(oki_measure_1) + ABS(oki_measure_2) + ABS(oki_measure_4) + ABS(oki_measure_5) + ABS(oki_measure_7) + ABS(oki_measure_8) ) <> 0 ';


     l_viewby_select  :=  l_viewby_select ||
   ', OKI_DYNAMIC_URL_1 ,'|| l_prodcat_url || ' ,oki_measure_1 ,oki_measure_2 ,oki_measure_3 ,oki_measure_4
    ,oki_measure_5 ,oki_measure_6 , oki_measure_6 oki_calc_item4,oki_measure_7,oki_measure_8, oki_measure_9 ,
    oki_measure_9 oki_calc_item5, oki_measure_11 ,oki_measure_12 ,oki_measure_13 ,oki_measure_14 ,
    oki_measure_15,oki_measure_16 ,oki_measure_17, oki_measure_18, oki_measure_19
     FROM (SELECT  rank() over (&ORDER_BY_CLAUSE nulls last , '||l_view_by_col||') - 1 rnk ,'||l_view_by_col||'
    ,OKI_DYNAMIC_URL_1 ,oki_measure_1 ,oki_measure_2 ,oki_measure_3 ,oki_measure_4 ,oki_measure_5 ,oki_measure_6
    ,oki_measure_7,oki_measure_8,oki_measure_9 ,oki_measure_11 ,oki_measure_12 ,oki_measure_13 ,oki_measure_14
    ,oki_measure_15 ,oki_measure_16,oki_measure_17,oki_measure_18, oki_measure_19 FROM ( ';


   /* Dynamic URL's  */


   IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP'
   THEN
   l_url_select :=
      'SELECT  DECODE(resource_id,-999, ''pFunctionName=OKI_DBI_SRM_PRNWL_RATE_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'', '''') OKI_DYNAMIC_URL_1 ';
    l_viewby_col_special := ' imm_child_rg_id ';
   ELSE
    l_url_select :=
      'SELECT NULL  OKI_DYNAMIC_URL_1 ';
     l_viewby_col_special := NULL ;
   END IF;



   /* From and Joins */
   IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP'
   THEN
      l_FROM_WHERE := '
           FROM    '||l_mv ||' fact
           WHERE   fact.mx_id = 5
          AND     fact.renewal_flag IN (1,3)
          AND     fact.activity_date BETWEEN   &BIS_CURRENT_EFFECTIVE_START_DATE
                                       AND   &BIS_CURRENT_EFFECTIVE_END_DATE '
          || l_where_clause || '
          GROUP BY imm_child_rg_id, resource_id ';

     l_VIEWBY_RANK_ORDER :='

             )oset05)oset10))oset ,'
         || ' jtf_rs_groups_vl g, jtf_rs_resource_extns_vl r
             where oset.rg_id=g.group_id and oset.resource_id=r.resource_id(+) '
         || l_filter_where || '
         AND (rnk BETWEEN &START_INDEX and &END_INDEX or &END_INDEX = -1)
         &ORDER_BY_CLAUSE nulls last ';

   ELSE
      l_FROM_WHERE := '
           FROM    '||l_mv ||' fact
          WHERE   fact.mx_id = 5
          AND     fact.renewal_flag IN (1,3)
          AND     fact.activity_date BETWEEN   &BIS_CURRENT_EFFECTIVE_START_DATE

                                       AND   &BIS_CURRENT_EFFECTIVE_END_DATE '
          || l_where_clause || '
          GROUP BY  ' ||l_view_by_col ;

    l_VIEWBY_RANK_ORDER  :='
          )oset05)oset10))oset ,'
      || l_view_by_table || ' v
      WHERE v.id = oset.'||l_view_by_col|| l_filter_where || '
      AND (rnk BETWEEN &START_INDEX and &END_INDEX or &END_INDEX = -1)
      &ORDER_BY_CLAUSE nulls last ';
   END IF;

    l_query                    := l_viewby_select || l_url_select || ' ,'||

       l_view_by_col || ',' ||'
       oset10.booked_val OKI_MEASURE_1,
       oset10.start_val OKI_MEASURE_2,
       oset10.val_rate OKI_MEASURE_3,
       oset10.booked_lcount OKI_MEASURE_4,
       oset10.start_lcount OKI_MEASURE_5,
       oset10.lcount_rate OKI_MEASURE_6,
       oset10.booked_hcount OKI_MEASURE_7,
       oset10.start_hcount OKI_MEASURE_8,
       oset10.hcount_rate OKI_MEASURE_9,
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
         oset05.booked_val booked_val,
         oset05.starting_val start_val,
         oset05.booked_val/decode(oset05.starting_val,0,NULL,oset05.starting_val)*100 val_rate,
         oset05.booked_lcount booked_lcount,

         oset05.starting_lcount start_lcount,
         oset05.booked_lcount /decode( oset05.starting_lcount,0,NULL,oset05.starting_lcount)*100 lcount_rate,
         oset05.booked_hcount booked_hcount,
         oset05.starting_hcount start_hcount,
         oset05.booked_hcount /decode( oset05.starting_hcount,0,NULL,oset05.starting_hcount)*100 hcount_rate,
         oset05.booked_val_tot booked_val_tot,
         oset05.starting_val_tot start_val_tot,
         oset05.booked_val_tot/decode(oset05.starting_val_tot,0,NULL,oset05.starting_val_tot)*100 val_rate_tot,
         oset05.booked_lcount_tot booked_lcount_tot,
         oset05.starting_lcount_tot start_lcount_tot,
         oset05.booked_lcount_tot /decode( oset05.starting_lcount_tot,0,NULL,oset05.starting_lcount_tot)*100 lcount_rate_tot,
         oset05.booked_hcount_tot booked_hcount_tot,
         oset05.starting_hcount_tot start_hcount_tot,

         oset05.booked_hcount_tot /decode( oset05.starting_hcount_tot,0,NULL,oset05.starting_hcount_tot)*100 hcount_rate_tot
     FROM
      (SELECT '|| l_viewby_col_special ||l_view_by_col ||',
          NVL(SUM(fact.price_nego_'||l_cur_suffix||'),0) starting_val,
          NVL(COUNT(distinct(fact.chr_id)),0) starting_hcount,
          NVL(COUNT(distinct(fact.cle_id)),0) starting_lcount,
          NVL(SUM(case when date_signed <= &BIS_CURRENT_ASOF_DATE then fact.price_nego_'||l_cur_suffix||' else null end),0) booked_val,
          NVL(COUNT(distinct(case when date_signed <= &BIS_CURRENT_ASOF_DATE then fact.chr_id else null end)),0) booked_hcount,
          NVL(COUNT(distinct(case when date_signed <= &BIS_CURRENT_ASOF_DATE then fact.cle_id else null end)),0) booked_lcount ,
          NVL(SUM(SUM(fact.price_nego_'||l_cur_suffix||')) over (),0) starting_val_tot,
          NVL(SUM(COUNT(distinct(fact.chr_id))) over (),0) starting_hcount_tot,
          NVL(SUM(COUNT(distinct(fact.cle_id))) over (),0) starting_lcount_tot,
          NVL(SUM(SUM(case when date_signed <= &BIS_CURRENT_ASOF_DATE then fact.price_nego_'||l_cur_suffix||' else null end)) over (),0) booked_val_tot,

          NVL(SUM(COUNT(distinct(case when date_signed <= &BIS_CURRENT_ASOF_DATE then fact.chr_id else null end))) over(),0) booked_hcount_tot,
          NVL(SUM(COUNT(distinct(case when date_signed <= &BIS_CURRENT_ASOF_DATE then fact.cle_id else null end))) over(),0) booked_lcount_tot '||
          l_FROM_WHERE || l_VIEWBY_RANK_ORDER ;
    x_custom_sql               := '/* OKI_DBI_SRM_PRNWL_RATE_DRPT */ ' ||  l_query;
    oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

  END get_rrate_sql;


/*******************************************************************************
  Function: get_pr_trend_sql
  Description: Function to retrieve the sql statement for the period renewals
               TREND portlet

*******************************************************************************/

PROCEDURE get_pr_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  -- Variables associated with the parameter portlet
    l_query             VARCHAR2 (32767);
    l_view_by           VARCHAR2 (120);
    l_view_by_col            VARCHAR2 (120);
    l_as_of_date        DATE;
    l_prev_as_of_date   DATE;
    l_xtd               VARCHAR2 (10);

    l_comparison_type   VARCHAR2 (1);
    l_nested_pattern    NUMBER;
    l_dim_bmap          NUMBER;
    l_cur_suffix        VARCHAR2 (2);
    l_custom_sql        VARCHAR2 (10000);

    l_col_tbl1		poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl2		poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl		poa_dbi_util_pkg.poa_dbi_join_tbl;

    l_mv_tbl                 poa_dbi_util_pkg.poa_dbi_mv_tbl;

    l_period_code varchar2(1);
    l_where_clause1           VARCHAR2 (2000);
    l_where_clause2           VARCHAR2 (2000);
    l_mv                     VARCHAR2 (2000);
    l_to_date_xtd    VARCHAR2 (3);

    l_to_date_xed    VARCHAR2 (3);
    l_mv1                VARCHAR2 (2000);
    l_mv2                VARCHAR2 (2000);

	l_xtd1               VARCHAR2 (10);
    l_xtd2               VARCHAR2 (10);
  BEGIN

    l_to_date_xed       := 'XED';
    l_to_date_xtd       := 'XTD';
    l_comparison_type   := 'Y';
/* DEBUG
     OKI_DBIDEBUG_PVT.check_portal_param('OKI_DBI_SRG',p_param);
*/
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
                                        , p_where_clause        => l_where_clause1
                                        , p_mv                  => l_mv1
                                        , p_join_tbl            => l_join_tbl
                                        ,p_period_type          => l_period_code
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_ST_71'
                                        , p_rg_where            => 'Y');
    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl1
                               , p_col_name       => 's_r_amt_' || l_cur_suffix
                               , p_alias_name     => 's_r_amt_xed'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XED');
    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl1
                               , p_col_name       => 's_gpr_amt_' || l_period_code || '_' || l_cur_suffix
                               , p_alias_name     => 's_gpr_amt_xed'

                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XED');
    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl1
                               , p_col_name       => 's_gpo_amt_'|| l_period_code || '_'  || l_cur_suffix
                               , p_alias_name     => 's_gpo_amt_xed'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XED');

   oki_dbi_util_pvt.process_parameters (p_param            => p_param
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
                                        ,p_period_type          => l_period_code
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_SG_71'
                                        , p_rg_where            => 'Y');


    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl2
                               , p_col_name       => 'g_scr_amt_' || l_period_code || '_' || l_cur_suffix
                               , p_alias_name     => 'g_scr_amt_xtd'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XTD');
    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl2
                               , p_col_name       => 'g_sco_amt_' || l_period_code || '_' || l_cur_suffix
                               , p_alias_name     => 'g_sco_amt_xtd'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XTD');


  l_mv_tbl.extend;
  l_mv_tbl(1).mv_name := l_mv1;
  l_mv_tbl(1).mv_col := l_col_tbl1;
  l_mv_tbl(1).mv_where := l_where_clause1;
  l_mv_tbl(1).in_join_tbls := NULL;
  l_mv_tbl(1).use_grp_id := 'N';
  l_mv_tbl(1).mv_xtd :=  l_xtd1;


  l_mv_tbl.extend;

  l_mv_tbl(2).mv_name := l_mv2;
  l_mv_tbl(2).mv_col := l_col_tbl2;
  l_mv_tbl(2).mv_where := l_where_clause2;
  l_mv_tbl(2).in_join_tbls := NULL;
  l_mv_tbl(2).use_grp_id := 'N';
  l_mv_tbl(2).mv_xtd := l_xtd2;


 l_query                    :=
          get_trend_sel_clause
	     || ' from '
         ||poa_dbi_template_pkg.union_all_trend_sql
		                                 (p_mv              => l_mv_tbl,
                                                  p_comparison_type   => 'R',
                                                  p_filter_where    => NULL);


	x_custom_sql               := '/* OKI_DBI_SRM_PR_G */ ' || l_query;
    oki_dbi_util_pvt.get_custom_trend_binds (l_xtd1
                                           , l_comparison_type
                                           , x_custom_output);

 /* DEBUG
     OKI_DBIDEBUG_PVT.check_portal_value('OKI_DBI_SRG','SQL',x_custom_sql);
     COMMIT;
 */

  END get_pr_trend_sql ;


--- ******************************************
FUNCTION get_trend_sel_clause
    RETURN VARCHAR2
  IS
    l_sel_clause   VARCHAR2 (10000);
  BEGIN

   --  OKI_MEASURE_1  : expiring value
   --  OKI_MEASURE_2  : prior exp. value
   --  OKI_MEASURE_3  : Booked value
   --  OKI_MEASURE_4  : prior booked value
   --  OKI_MEASURE_5  : Ren rate value
   --  OKI_MEASURE_6  : Change

   --  OKI_MEASURE_9  : prior Ren rate value
   --  OKI_MEASURE_7  : Uplift value
   --  OKI_MEASURE_8  : Change Uplift
   --  OKI_MEASURE_10 : prior Uplift value

/*-------------
              ,('||oki_dbi_util_pvt.add_measures('iset.c_s_gpr_amt_xed','iset.c_g_scr_amt_xtd') || '
                 /decode(iset.c_s_r_amt_xed,0,NULL,iset.c_s_r_amt_xed)*100) -
                 ('||oki_dbi_util_pvt.add_measures('iset.p_s_gpr_amt_xed','iset.p_g_scr_amt_xtd') || '
                  /decode(iset.p_s_r_amt_xed,0,NULL,iset.p_s_r_amt_xed)*100) OKI_MEASURE_6
*/

    l_sel_clause               :=
        'SELECT  cal_NAME AS VIEWBY
        , nvl(uset.c_s_r_amt_xed,0) OKI_MEASURE_1
        , nvl(uset.p_s_r_amt_xed,0) OKI_MEASURE_2
        , nvl(uset.c_s_gpr_amt_xed,0) + nvl(uset.c_g_scr_amt_xtd,0) OKI_MEASURE_3
        , nvl(uset.p_s_gpr_amt_xed,0) + nvl(uset.p_g_scr_amt_xtd,0) OKI_MEASURE_4
        ,( (nvl(uset.c_s_gpr_amt_xed,0) + nvl(uset.c_g_scr_amt_xtd,0))
                  /decode(uset.c_s_r_amt_xed,0,NULL,uset.c_s_r_amt_xed))*100 OKI_MEASURE_5
        ,(((nvl(uset.c_s_gpr_amt_xed,0) + nvl(uset.c_g_scr_amt_xtd,0))
                         /decode(uset.c_s_r_amt_xed,0,NULL,uset.c_s_r_amt_xed)*100) -
                 ((nvl(uset.p_s_gpr_amt_xed,0) + nvl(uset.p_g_scr_amt_xtd,0))
                         /decode(uset.p_s_r_amt_xed,0,NULL,uset.p_s_r_amt_xed)*100)) OKI_MEASURE_6
        ,((nvl(uset.p_s_gpr_amt_xed,0) + nvl(uset.p_g_scr_amt_xtd,0))
                        /decode(uset.p_s_r_amt_xed,0,NULL,uset.p_s_r_amt_xed))*100 OKI_MEASURE_9

        ,nvl(uset.c_s_gpr_amt_xed,0) + nvl(uset.c_g_scr_amt_xtd,0) -
                (nvl(uset.c_s_gpo_amt_xed,0)+nvl(uset.c_g_sco_amt_xtd,0)) OKI_MEASURE_7
        ,nvl(uset.p_s_gpr_amt_xed,0) + nvl(uset.p_g_scr_amt_xtd,0) -
                (nvl(uset.p_s_gpo_amt_xed,0)+nvl(uset.p_g_sco_amt_xtd,0)) OKI_MEASURE_10
        , ((nvl(uset.c_s_gpr_amt_xed,0) + nvl(uset.c_g_scr_amt_xtd,0) -
                (nvl(uset.c_s_gpo_amt_xed,0) + nvl(uset.c_g_sco_amt_xtd,0)) )
            - (nvl(uset.p_s_gpr_amt_xed,0) + nvl(uset.p_g_scr_amt_xtd,0) -
                (nvl(uset.p_s_gpo_amt_xed,0) + nvl(uset.p_g_sco_amt_xtd,0))
              )
          ) / abs(decode(
                            (nvl(uset.p_s_gpr_amt_xed,0) + nvl(uset.p_g_scr_amt_xtd,0) -
                                (nvl(uset.p_s_gpo_amt_xed,0) + nvl(uset.p_g_sco_amt_xtd,0))
                            ),0,NULL

                           ,(nvl(uset.p_s_gpr_amt_xed,0) + nvl(uset.p_g_scr_amt_xtd,0) -
                                (nvl(uset.p_s_gpo_amt_xed,0) + nvl(uset.p_g_sco_amt_xtd,0))
                            )
                         )
                 ) *100 OKI_MEASURE_8 ';

     RETURN l_sel_clause;
  END get_trend_sel_clause;


END oki_dbi_srm_prnwl_pvt;

/
