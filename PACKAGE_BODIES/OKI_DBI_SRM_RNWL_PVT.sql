--------------------------------------------------------
--  DDL for Package Body OKI_DBI_SRM_RNWL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_SRM_RNWL_PVT" AS
/* $Header: OKIIRNWB.pls 120.7 2006/05/18 01:23:54 asparama noship $ */

  FUNCTION get_table_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_top_bookings_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_bookings_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_renwlforecast_sel_clause (
      p_cur_suffix                IN       VARCHAR2
    , p_period_type_code          IN       VARCHAR2)
      RETURN VARCHAR2;

  FUNCTION get_late_rnwl_table_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_cncl_table_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2;


  FUNCTION get_cancellations_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2)
    RETURN VARCHAR2;

 --DBI7.0
/*   FUNCTION get_bkngs_by_cust_sel_clause
    RETURN VARCHAR2;

   FUNCTION get_exp_bkngs_cust_sel_clause
    RETURN VARCHAR2;

   FUNCTION get_cancln_by_cust_sel_clause
    RETURN VARCHAR2;
*/

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
--    l_xtd                    VARCHAR2 (10);
    l_comparison_type        VARCHAR2 (1);
    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2 (2);
    l_where_clause1          VARCHAR2 (2000);
    l_where_clause2          VARCHAR2 (2000);
    l_filter_where           VARCHAR2 (340);
    l_mv                     VARCHAR2 (2000);
--    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed    VARCHAR2 (3) ;
    l_to_date_xtd    VARCHAR2 (3);
    l_to_date_ytd    VARCHAR2 (3);
    l_to_date_itd    VARCHAR2 (3);
    l_mv1		VARCHAR2(100);
    l_mv2		VARCHAR2(100);
    l_col_tbl1               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl2               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_xtd1                   VARCHAR2(10);
    l_xtd2                   VARCHAR2(10);
    l_mv_tbl                 poa_dbi_util_pkg.poa_dbi_mv_tbl;

  BEGIN
    l_to_date_xed       := 'XED';
    l_to_date_xtd       := 'XTD';
    l_to_date_ytd       := 'YTD';
    l_to_date_itd       := 'ITD';
    l_comparison_type   := 'Y';

  l_join_tbl          := POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl ();
  l_col_tbl1          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_col_tbl2          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
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
                                        , p_mv_set              => 'SRM_SG_71'
                                        , p_rg_where            => 'Y');


    -- Populate col table with regular columns
    -- Period Renewal node
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 'g_r_amt_' || l_cur_suffix
                               , p_alias_name      => 'Gr'
                               , p_to_date_type    => l_to_date_xtd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 'g_o_amt_' || l_cur_suffix
                               , p_alias_name      => 'Go'
                               , p_to_date_type    => l_to_date_xtd);


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
                                        , p_mv_set              => 'SRM_EC_71'
                                        , p_rg_where            => 'Y');
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl2
                               , p_col_name        => 'f_f_amt_' || l_cur_suffix
                               , p_alias_name      => 'Fcf'
                               , p_to_date_type    => l_to_date_xed
                               , p_prior_code      => poa_dbi_util_pkg.no_priors);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl2
                               , p_col_name        => 'f_r_amt_' || l_cur_suffix
                               , p_alias_name      => 'Fcr'
                               , p_to_date_type    => l_to_date_xed
                               , p_prior_code      => poa_dbi_util_pkg.no_priors);

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
   /* Additional filter needed to avoid displaying records queried due to total values at node */

   l_filter_where  := ' ( ABS(oki_measure_1) +
                          ABS(oki_measure_3) +
                          ABS(oki_measure_4) +
                          ABS(oki_measure_7) +
                          ABS(oki_measure_8) ) <> 0 ' ;

 --                         oki_measure_21 + --commented for bug 3503029
  --                       oki_measure_25)  <> 0 ';

    -- Generate sql query


  l_query := get_table_sel_clause (l_view_by, l_view_by_col)
              || ' from (
            ' || poa_dbi_template_pkg.union_all_status_sql
						 (p_mv       => l_mv_tbl,
                                                  p_join_tables     => l_join_tbl,
                                                  p_use_windowing   => 'Y',
                                                  p_paren_count     => 7,
                                                  p_filter_where    => l_filter_where );

 -- insert into brrao_temp values ( l_query);
 -- commit;

    x_custom_sql               := '/* OKI_DBI_SRM_RNWL_SUM_RPT */' ||l_query;
   --oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);
   oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

  END get_table_sql;


  /*
     Renewal Bookings Summary  Select clause
  */
  FUNCTION get_table_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_sel_clause         VARCHAR2 (32767);
    l_bookings_url       VARCHAR2(300);
    l_forecast_url       VARCHAR2(300);
    l_prodcat_url        VARCHAR2(300);
    l_viewby_select      VARCHAR2(32767);
    l_url_select         VARCHAR2(32767);
  BEGIN


    l_viewby_select := oki_dbi_util_pvt.get_viewby_select_clause(p_view_by_dim, 'SRM', '6.0');

    -- Bookings URL when view by is Salesrep
         l_bookings_url  := '''pFunctionName=OKI_DBI_SRM_RSBK_DTL_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';
         --l_bookings_url  := '''pFunctionName=OKI_DBI_SRM_RSBK_DTL_DRPT''';

         l_forecast_url  := '''pFunctionName=OKI_DBI_SRM_FCST_DTL_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';
         --l_forecast_url  := '''pFunctionName=OKI_DBI_SRM_FCST_DTL_DRPT''';

    IF(p_view_by_dim = 'ITEM+ENI_ITEM_VBH_CAT')
    THEN
       l_prodcat_url :=
           ' decode(leaf_node_flag,''Y''
           , ''pFunctionName=OKI_DBI_SRM_RNWL_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM''
           ,''pFunctionName=OKI_DBI_SRM_RNWL_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT'' ) OKI_DYNAMIC_URL_4 ';
    ELSE
       l_prodcat_url := ''''' OKI_DYNAMIC_URL_4 ';
    END IF;


    l_viewby_select  :=  l_viewby_select ||
   ', OKI_DYNAMIC_URL_1 ,OKI_DYNAMIC_URL_2 ,OKI_DYNAMIC_URL_3, '|| l_prodcat_url || ', oki_measure_1 ,oki_measure_2
    ,oki_measure_3 ,oki_measure_4 ,oki_measure_5 ,oki_measure_6,oki_measure_7,oki_measure_8 ,oki_measure_11
    ,oki_measure_12 ,oki_measure_13 ,oki_measure_14 ,oki_measure_15 ,oki_measure_16, oki_measure_17,oki_measure_18
    , oki_measure_21, oki_measure_25 ,oki_calc_item1 ,oki_calc_item2
    ,oki_calc_item3 ,oki_calc_item4,oki_calc_item5, oki_calc_item6, oki_calc_item11 ,oki_calc_item12 ,oki_calc_item13
    ,oki_calc_item14, oki_calc_item15, oki_calc_item16
     FROM (SELECT  rank() over (&ORDER_BY_CLAUSE nulls last , '||p_view_by_col||') - 1 rnk ,'||p_view_by_col||'
    ,OKI_DYNAMIC_URL_1 ,OKI_DYNAMIC_URL_2 ,OKI_DYNAMIC_URL_3 ,oki_measure_1 ,oki_measure_2 ,oki_measure_3
    ,oki_measure_4 ,oki_measure_5 ,oki_measure_6, oki_measure_7, oki_measure_8 ,oki_measure_11 ,oki_measure_12
    ,oki_measure_13 ,oki_measure_14 ,oki_measure_15 ,oki_measure_16, oki_measure_17, oki_measure_18 ,oki_measure_21
    , oki_measure_25 ,oki_calc_item1 ,oki_calc_item2 ,oki_calc_item3
    ,oki_calc_item4, oki_calc_item5, oki_calc_item6, oki_calc_item11 ,oki_calc_item12 ,oki_calc_item13
    ,oki_calc_item14, oki_calc_item15, oki_calc_item16
       FROM ( ';

--' , decode(resource_id,-999,'''','||l_bookings_url||') OKI_DYNAMIC_URL_2 '||
--          ' , decode(resource_id,-999,'''','||l_forecast_url||') OKI_DYNAMIC_URL_3 ';

    IF(p_view_by_dim = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
    THEN
       l_url_select :=
          'SELECT  decode(resource_id,-999,''pFunctionName=OKI_DBI_SRM_RNWL_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'','''') OKI_DYNAMIC_URL_1 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_bookings_url||')) OKI_DYNAMIC_URL_2 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_forecast_url||')) OKI_DYNAMIC_URL_3 ';
    ELSIF(p_view_by_dim = 'ITEM+ENI_ITEM')
    THEN
       l_url_select :=
          'SELECT  '''' OKI_DYNAMIC_URL_1 '||
          ' , '||l_bookings_url||' OKI_DYNAMIC_URL_2 '||
          ' , '||l_forecast_url||' OKI_DYNAMIC_URL_3 ';
    ELSE
       l_url_select :=
          'SELECT  '''' OKI_DYNAMIC_URL_1 '||
          ' , '''' OKI_DYNAMIC_URL_2 '||
          ' , '''' OKI_DYNAMIC_URL_3 ';

    END IF;

      l_sel_clause               := l_viewby_select || l_url_select ||
          -- AK Attribute naming
          '   ,'|| p_view_by_col ||
          ' , oset20.C_bkg oki_measure_1 '||
          ' , oset20.bkg_chg oki_measure_2 '||
          ' , oset20.fcst oki_measure_3 '||
          ' , oset20.exp_bkg oki_measure_4 '||
          ' , oset20.C_upl oki_measure_5 '||
          ' , oset20.upl_chg oki_measure_6 '||
          ' , oset20.fcst_full oki_measure_7 '||
          ' , oset20.exp_bkg_full oki_measure_8 '||
          ' , oset20.C_bkg_tot oki_measure_11 '||
          ' , oset20.bkg_chg_tot oki_measure_12 '||
          ' , oset20.fcst_tot oki_measure_13 '||
          ' , oset20.exp_bkg_tot oki_measure_14 '||
          ' , oset20.C_upl_tot oki_measure_15 '||
          ' , oset20.upl_chg_tot oki_measure_16 '||
          ' , oset20.fcst_full_tot oki_measure_17 '||
          ' , oset20.exp_bkg_full_tot oki_measure_18 '||
          ' , oset20.p_bkg oki_measure_21 '||
          ' , oset20.P_upl oki_measure_25 '||
          ' , oset20.C_bkg oki_calc_item1 '||
          ' , oset20.C_bkg_tot oki_calc_item11 '||
          ' , oset20.P_bkg oki_calc_item2 '||
          ' , oset20.P_bkg_tot oki_calc_item12 '||
          ' , oset20.exp_bkg oki_calc_item3 '||
          ' , oset20.exp_bkg_tot oki_calc_item13 '||
          ' , NULL oki_calc_item4 '||
          ' , NULL oki_calc_item14 '||
          ' , oset20.C_upl oki_calc_item5 '||
          ' , oset20.C_upl_tot oki_calc_item15 '||
          ' , oset20.P_upl oki_calc_item6 '||
          ' , oset20.P_upl_tot oki_calc_item16 '||
          '   from '||
          '   ( select '||
          -- Change Calculation
          '    '|| p_view_by_col ||
          '   , oset15.C_Gr C_bkg '||
          '   , oset15.P_Gr P_bkg '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.C_Gr','oset15.P_Gr','NP') || ' bkg_chg '||
          '   , oset15.C_Fcf fcst '||
          '   , oset15.C_Fcr fcst_full '||
          '   , oset15.C_GrFcf exp_bkg '||
          '   , oset15.C_GrFcr exp_bkg_full '||
          '   , oset15.C_upl c_upl '||
          '   , oset15.P_upl p_upl '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.C_upl','oset15.P_upl','NP') || ' upl_chg '||
          '   , oset15.C_Gr_tot C_bkg_tot '||
          '   , oset15.P_Gr_tot P_bkg_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.C_Gr_tot','oset15.P_Gr_tot','NP') || ' bkg_chg_tot '||
          '   , oset15.C_Fcf_tot fcst_tot '||
          '   , oset15.C_Fcr_tot fcst_full_tot '||
          '   , oset15.C_GrFcf_tot exp_bkg_tot '||
          '   , oset15.C_GrFcr_tot exp_bkg_full_tot '||
          '   , oset15.C_upl_tot C_upl_tot '||
          '   , oset15.P_upl_tot P_upl_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.C_upl_tot','oset15.P_upl_tot','NP') || ' upl_chg_tot '||
          '   from  '||
          '    (select '||
               -- Calculated Measures
                p_view_by_col ||
               ' , oset13.c_Gr '||
               ' , oset13.p_Gr '||
               ' , oset13.c_Fcf '||
               ' , oset13.c_Fcr '||
               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset13.c_Gr','oset13.c_Fcf') ||' c_GrFcf '||
               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset13.c_Gr','oset13.c_Fcr') ||' c_GrFcr '||
               ' ,'|| OKI_DBI_UTIL_PVT.subtract_measures('oset13.c_Gr','oset13.c_Go') ||' c_Upl '||
               ' ,'|| OKI_DBI_UTIL_PVT.subtract_measures('oset13.p_Gr','oset13.p_Go') ||' p_Upl '||
               ' , oset13.c_Gr_tot '||
               ' , oset13.p_Gr_tot '||
               ' , oset13.c_Fcf_tot '||
               ' , oset13.c_Fcr_tot '||
               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset13.c_Gr_tot','oset13.c_Fcf_tot') ||' c_GrFcf_tot '||
               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset13.c_Gr_tot','oset13.c_Fcr_tot') ||' c_GrFcr_tot '||
               ' ,'|| OKI_DBI_UTIL_PVT.subtract_measures('oset13.c_Gr_tot','oset13.c_Go_tot') ||' c_Upl_tot '||
               ' ,'|| OKI_DBI_UTIL_PVT.subtract_measures('oset13.p_Gr_tot','oset13.p_Go_tot') ||' p_Upl_tot '||
          '   from  '||
          '     (select '||
                --  Measures Based on a formula
                p_view_by_col ||
               ' , oset10.c_Gr c_Gr '||
               ' , oset10.c_Go c_Go '||
               ' , oset10.p_Gr p_Gr '||
               ' , oset10.p_Go p_Go '||
               ' , oset10.c_Fcf c_Fcf '||
               ' , oset10.c_Fcr c_Fcr '||
               ' , oset10.c_Gr_tot c_Gr_tot '||
               ' , oset10.c_Go_tot c_Go_tot '||
               ' , oset10.p_Gr_tot p_Gr_tot '||
               ' , oset10.p_Go_tot p_Go_tot '||
               ' , oset10.c_Fcf_tot c_Fcf_tot '||
               ' , oset10.c_Fcr_tot c_Fcr_tot '||
               ' from '||
               '   ( select '||
               '        oset05.'||p_view_by_col ||
               '      , nvl(oset05.c_Gr,0) c_Gr '||
               '      , nvl(oset05.c_Go,0) c_Go '||
               '      , nvl(oset05.c_Fcf,0) c_Fcf '||
               '      , nvl(oset05.c_Fcr,0) c_Fcr '||
               '      , nvl(oset05.p_Gr,0) p_Gr '||
               '      , nvl(oset05.p_Go,0) p_Go '||
               '      , nvl(oset05.c_Gr_total,0) c_Gr_tot '||
               '      , nvl(oset05.c_Go_total,0) c_Go_tot '||
               '      , nvl(oset05.c_Fcf_total,0) c_Fcf_tot '||
               '      , nvl(oset05.c_Fcr_total,0) c_Fcr_tot '||
               '      , nvl(oset05.p_Gr_total,0) p_Gr_tot '||
               '      , nvl(oset05.p_Go_total,0) p_Go_tot ';

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
    l_cur_suffix             VARCHAR2 (2);
    l_where_clause           VARCHAR2 (2000);
    l_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed    VARCHAR2 (3);
    l_to_date_xtd    VARCHAR2 (3);

    l_rpt_specific_where     VARCHAR2 (1000);
    l_join_where             VARCHAR2 (1000);
    l_group_by               VARCHAR2 (1000);
    l_filter_where           VARCHAR2 (240);
    l_additional_where       VARCHAR2 (2000);
    l_columns   VARCHAR (5000);

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
                                        , p_mv_set              => 'SRM_DTL_RPT'
                                        , p_rg_where            => 'Y');

 l_rpt_specific_where    :=
      ' AND   fact.renewal_flag in (1,3)
        AND   fact.date_signed between &BIS_CURRENT_EFFECTIVE_START_DATE
                                and &BIS_CURRENT_ASOF_DATE';

 l_group_by     := '   GROUP BY fact.chr_id, fact.customer_party_id, fact.resource_id , fact.date_signed';

        poa_dbi_util_pkg.add_column ( p_col_tbl       => l_col_tbl
                                    , p_col_name      => 'price_negotiated_' || l_cur_suffix
                                    , p_alias_name    => 'affected_value'
                                    , p_prior_code    => poa_dbi_util_pkg.no_priors);

        l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();

        oki_dbi_util_pvt.join_rpt_where ( p_join_tbl     => l_join_tbl
                                        , p_func_area    => 'SRM'
                                        , p_version      => '6.0'
                                        , p_role         => NULL
                                        , p_mv_set       => 'SRM_DTL_RPT');

   /* Additional filter needed to avoid displaying records queried due to total values at node */
       l_filter_where  := ' ( ABS(oki_measure_1) ) <> 0 ';

    l_query                 :=  get_bookings_sel_clause (l_cur_suffix, l_period_type ) ||
                                poa_dbi_template_pkg.dtl_status_sql2 (
                                            p_fact_name         => l_mv
                                          , p_where_clause      => l_where_clause || l_rpt_specific_where
                                          , p_join_tables       => l_join_tbl
                                          , p_use_windowing     => 'Y'
                                          , p_col_name          => l_col_tbl
                                          , p_use_grpid         => 'N'
                                          , p_filter_where      => l_filter_where
                                          , p_paren_count       => 5
                                          , p_group_by          => l_group_by
                                          , p_from_clause       => ' from '||l_mv ||' fact ');

    x_custom_sql            := '/* OKI_DBI_SRM_RSBK_DTL_DRP */' || l_query;


   oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);


END get_bookings_sql;

  PROCEDURE get_top_bookings_sql (
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
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed    VARCHAR2 (3);
    l_to_date_xtd    VARCHAR2 (3);

    l_filter_where            varchar2(1000);
    l_rpt_specific_where     VARCHAR2 (1000);
    l_join_where             VARCHAR2 (1000);
    l_group_by               VARCHAR2 (1000);

	g_resource_id            NUMBER;
	g_rs_group_id            NUMBER;
	l_pseudo_rs_group        VARCHAR2(1000);
	l_sep                    NUMBER;
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
                                        , p_mv_set              => 'SRM_TBK_RPT'
                                        , p_rg_where            => 'Y');

  l_rpt_specific_where    :=
      ' AND   fact.renewal_flag in (1,3)
        AND   fact.date_signed between &BIS_CURRENT_EFFECTIVE_START_DATE
                                and &BIS_CURRENT_ASOF_DATE ';
    l_group_by              := ' GROUP BY chr_id,customer_party_id,resource_id,complete_k_number,hstart_date,hend_date ';

   /* Additional filter needed to avoid displaying records queried due to total values at node */
   l_filter_where  := ' ( ABS(oki_measure_1) ) <> 0 ';


    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();

    oki_dbi_util_pvt.join_rpt_where (p_join_tbl     => l_join_tbl
                                    , p_func_area    => 'SRM'
                                    , p_version      => '6.0'
                                    , p_role         => NULL
                                    , p_mv_set       => 'SRM_TBK_RPT');

    l_query                 := get_top_bookings_sel_clause (l_curr_suffix, l_period_type )
       || poa_dbi_template_pkg.dtl_status_sql2 (p_fact_name         => l_mv
                                             , p_where_clause      => l_where_clause || l_rpt_specific_where
                                             , p_join_tables       => l_join_tbl
                                             , p_use_windowing     => 'Y'
                                             , p_col_name          => l_col_tbl
                                             , p_use_grpid         => 'N'
                                             , p_filter_where      => l_filter_where
                                             , p_paren_count       => 5
                                             , p_group_by          => l_group_by
                                             , p_from_clause       => ' from '||l_mv ||' fact ');
    x_custom_sql            := '/* OKI_DBI_SRM_RSBK_DTL_DRPT */ ' || l_query;

   oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

END get_top_bookings_sql;



  FUNCTION get_top_bookings_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_query   VARCHAR2 (10000);


  BEGIN

    -- Generate sql query
    l_query                    :=
        '
        SELECT
           oki_attribute_1,
           cust.value     oki_attribute_2,
           DECODE(fact.resource_id,-1,&UNASSIGNED,rsex.resource_name) oki_attribute_3,
    	     OKI_DATE_1,
	     OKI_DATE_2,
    	     OKI_DATE_3,
           oki_measure_1,
           oki_measure_11,
	   fact.chr_id OKI_ATTRIBUTE_5
     FROM(
       SELECT *
       FROM (
          SELECT
             rank() over (&ORDER_BY_CLAUSE nulls last) - 1 rnk ,
             oki_attribute_1,
             oki_date_1,
             oki_date_2,
             oki_date_3,
             customer_party_id,
             resource_id,
             oki_measure_1,
             oki_measure_11,
	     chr_id
          FROM (
              SELECT oset5.complete_k_number oki_attribute_1,
                     oset5.customer_party_id ,
                     oset5.resource_id   ,
		             oset5.chr_id,
                     to_char(oset5.date_signed) OKI_DATE_1,
                     oset5.start_date OKI_DATE_2,
                     oset5.end_date OKI_DATE_3,
                     nvl(oset5.affected_value,0)       OKI_MEASURE_1,
                     nvl(oset5.affected_value_total,0) OKI_MEASURE_11
              FROM
               ( SELECT
                    fact.customer_party_id,
                    fact.resource_id,
 		            fact.chr_id,
                    fact.complete_k_number,
                    min(fact.date_signed) date_signed,
                    to_char(fact.hstart_date) start_date,
                    to_char(fact.hend_date) end_date,
                    sum(fact.price_negotiated_'|| p_cur_suffix || ') affected_value,
                    sum(sum(fact.price_negotiated_'|| p_cur_suffix || ')) over() affected_value_total ';
     RETURN l_query;
  END get_top_bookings_sel_clause;

  FUNCTION get_bookings_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_query   VARCHAR2 (10000);


  BEGIN

    -- Generate sql query
    l_query                    :=
        '
        SELECT
           k.complete_k_number oki_attribute_1,
           cust.value     oki_attribute_2,
           DECODE(fact.resource_id,-1,&UNASSIGNED,rsex.resource_name) oki_attribute_3,
    	    OKI_DATE_1,
	        to_char(k.start_date) OKI_DATE_2,
    	    to_char(k.end_date) OKI_DATE_3,
            oki_measure_1,
            oki_measure_11,
	        fact.chr_id OKI_ATTRIBUTE_5
     FROM(
       SELECT *
       FROM (
          SELECT
             rank() over (&ORDER_BY_CLAUSE nulls last) - 1 rnk ,
             chr_id,
             customer_party_id,
             resource_id,
             oki_measure_1,
             oki_measure_11,
			 date_signed OKI_DATE_1
          FROM (
              SELECT oset5.chr_id    ,
                     oset5.customer_party_id  ,
                     oset5.resource_id   ,
                     nvl(oset5.affected_value,0)       OKI_MEASURE_1,
                     nvl(oset5.affected_value_total,0) OKI_MEASURE_11,
					 date_signed
              FROM
                (SELECT
				    fact.chr_id,
                    fact.customer_party_id,
                    fact.resource_id,
					to_char(fact.date_signed) date_signed';
     RETURN l_query;
  END get_bookings_sel_clause;


/* This procedure generates the entire SQL query that is required for the report
 * Renewal Bookings By Customer.
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
     x_custom_sql               := '/* OKI_DBI_SRM_RSBK_DTL_CRPT */ ' || l_query;
     oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);
 END get_bkngs_by_cust_sql;

/*******************************************************************************/
/* get_bkngs_by_cust_sel_clause returns the top most select statement of the query
/********************************************************************************/
/*
  FUNCTION get_bkngs_by_cust_sel_clause
    RETURN VARCHAR2
     IS
        l_query                  VARCHAR2 (32767);


 BEGIN

 RETURN  l_query;

 END  get_bkngs_by_cust_sel_clause;
*/


  PROCEDURE get_renewal_forecast_sql (
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
                                            , p_mv_set              => 'SRM_DTL_RPT'
                                            , p_rg_where            => 'Y');


        l_rpt_specific_where    :=
          ' AND   fact.renewal_flag in (1,3)
            AND   fact.past_due_date = TO_DATE(''01-01-4712'',''DD-MM-YYYY'')
            AND   fact.expected_close_date between &BIS_CURRENT_EFFECTIVE_START_DATE
                                  and &BIS_CURRENT_EFFECTIVE_END_DATE ' ;

        l_group_by              := ' GROUP BY fact.chr_id, fact.customer_party_id, fact.resource_id';


          poa_dbi_util_pkg.add_column
                              ( p_col_tbl       => l_col_tbl
                              , p_col_name      => 'price_negotiated_' || l_cur_suffix
                              , p_alias_name    => 'affected_full_value'
                              , p_prior_code    => poa_dbi_util_pkg.no_priors);

          poa_dbi_util_pkg.add_column
                              ( p_col_tbl       => l_col_tbl
                              , p_col_name      => 'win_percent *.01 *price_negotiated_' || l_cur_suffix
                              , p_alias_name    => 'affected_forecast_value'
                              , p_prior_code    => poa_dbi_util_pkg.no_priors);

       /* Additional filter needed to avoid displaying records queried due to total values at node */
      l_filter_where  := ' ( ABS(oki_measure_1) + ABS(oki_measure_3) ) <> 0 ';

        l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
        oki_dbi_util_pvt.join_rpt_where (p_join_tbl     => l_join_tbl
                                        , p_func_area    => 'SRM'
                                        , p_version      => '6.0'
                                        , p_role         => NULL
                                        , p_mv_set       => 'SRM_DTL_RPT');

        l_query                 := get_renwlforecast_sel_clause  (l_cur_suffix, l_period_type )

           || poa_dbi_template_pkg.dtl_status_sql2 (
                                                   p_fact_name         => l_mv
                                                  , p_where_clause      => l_where_clause || l_rpt_specific_where
                                                  , p_join_tables       => l_join_tbl
                                                  , p_use_windowing     => 'Y'
                                                  , p_col_name          => l_col_tbl
                                                  , p_use_grpid         => 'N'
                                                  , p_filter_where      => l_filter_where
                                                  , p_paren_count       => 5
                                                  , p_group_by          => l_group_by
                                                  , p_from_clause       => ' from '||l_mv ||' fact ');

        x_custom_sql               := '/* OKI_DBI_SRM_FCST_DTL_DRPT */' || l_query;
     oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

    END get_renewal_forecast_sql;

    FUNCTION get_renwlforecast_sel_clause (
        p_cur_suffix                IN       VARCHAR2
      , p_period_type_code          IN       VARCHAR2)
        RETURN VARCHAR2
      IS
        l_query   VARCHAR2 (10000);

      BEGIN

        -- Generate sql query
        l_query                    :=
            'SELECT
               k.complete_k_number oki_attribute_1,
               cust.value oki_attribute_2,
               DECODE(fact.resource_id,-1,&UNASSIGNED,rsex.resource_name) oki_attribute_3,
               to_char(k.start_date) OKI_DATE_1,
	           to_char(k.expected_close_date) OKI_DATE_2,
               oki_measure_1,
	           k.win_percent OKI_MEASURE_2,
               oki_measure_3,
               oki_measure_11,
               oki_measure_13,
 	           fact.chr_id OKI_ATTRIBUTE_5
         FROM (SELECT *
           FROM (
              SELECT
                 rank() over (&ORDER_BY_CLAUSE nulls last) - 1 rnk ,
                 chr_id,
                 customer_party_id,
                 resource_id,
    	         oki_measure_1,
    	         oki_measure_3,
    	         oki_measure_11,
                 oki_measure_13
              FROM (
                    SELECT
                    	 oset5.chr_id ,
    	                 oset5.customer_party_id ,
    	                 oset5.resource_id ,
    	                 nvl(oset5.affected_full_value,0)	    	OKI_MEASURE_1,
    	  	       	 nvl(oset5.affected_forecast_value,0)      	OKI_MEASURE_3,
    	  	       	 nvl(oset5.affected_full_value_total,0)    	OKI_MEASURE_11,
    	                 nvl(oset5.affected_forecast_value_total,0)     OKI_MEASURE_13
               	    FROM
                    (SELECT
                        fact.chr_id,
                        fact.customer_party_id,
                        fact.resource_id';
         RETURN l_query;

    END get_renwlforecast_sel_clause;


/* This procedure generates the entire SQL query that is required for the report
 * Renewal Expected Bookings By Customer.
 *
 * p_param      -->a table populated by PMV which contains all the parameters that
 *                 the user selects in the report
 * x_custom_sql -->the final SQL query that is generated
 * x_custom_output -->contains the bind variables
 */

 PROCEDURE get_exp_bkngs_by_cust_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl)
  IS
    l_query                  VARCHAR2 (32767);
  BEGIN
    l_query                 := 'Hello';
     x_custom_sql               := '/* OKI_DBI_SRM_RSBK_DTL_CRPT */ ' || l_query;
     oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);
 END get_exp_bkngs_by_cust_sql;

/*******************************************************************************
  Function: get_exp_bkngs_cust_sel_clause
  Description: Function to get the top most select statement of the query

*******************************************************************************/
/*
 FUNCTION get_exp_bkngs_cust_sel_clause
    RETURN VARCHAR2
  IS
         l_query  VARCHAR2(10000);
BEGIN

RETURN    l_query;
END  get_exp_bkngs_cust_sel_clause;
*/


/*******************************************************************************
  Function: get_late_rnwl_table_sql
  Description: Function to get the Late Renewals Booking Report DBI 6.0

*******************************************************************************/

PROCEDURE get_late_rnwl_table_sql (
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
    l_comparison_type        VARCHAR2 (1) ;
    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2 (2);
    l_where_clause           VARCHAR2 (2000);

    l_filter_where           VARCHAR2 (1000);

    l_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed    VARCHAR2 (3)    ;
    l_to_date_xtd    VARCHAR2 (3)  ;
    l_to_date_ytd    VARCHAR2 (3) ;
    l_to_date_itd    VARCHAR2 (3) ;

  l_group_by		VARCHAR2(32000);


  l_custom_rec 		BIS_QUERY_ATTRIBUTES ;

  BEGIN
    l_to_date_xed       := 'XED';
    l_to_date_xtd       := 'XTD';
    l_comparison_type   := 'Y';
    l_to_date_ytd       := 'YTD';
    l_to_date_itd       := 'ITD';
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
                                        , p_mv_set              => 'SRM_SG_71'
                                        , p_rg_where            => 'Y');



    -- Populate col table with regular columns

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'g_r_amt_' || l_cur_suffix
                               , p_alias_name      => 'Gr'
                               , p_to_date_type    => l_to_date_xtd);


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'gl_r_amt_' || l_cur_suffix
                               , p_alias_name      => 'Glr'
                               , p_to_date_type    => l_to_date_xtd);


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'gr_r_amt_' || l_cur_suffix
                               , p_alias_name      => 'Grr'
                               , p_to_date_type    => l_to_date_xtd);


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'gl_days'
                               , p_alias_name      => 'Gld'
                               , p_to_date_type    => l_to_date_xtd
                               , p_prior_code      => poa_dbi_util_pkg.no_priors);


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'gl_days_count'
                               , p_alias_name      => 'Gld_count'
                               , p_to_date_type    => l_to_date_xtd
                               , p_prior_code      => poa_dbi_util_pkg.no_priors);


   /* Additional filter needed to avoid displaying records queried due to total values at node */
    l_filter_where  := '  ( ABS(oki_measure_1) +  ABS(oki_measure_2) + ABS(oki_measure_5) ) <> 0 ';
/*   l_filter_where  := '  ( oki_measure_1 +
  			   oki_measure_2 +
   			   oki_measure_3 +
   			   oki_measure_5 +
   			   oki_measure_6 +
   			   oki_measure_8
   			    ) <> 0 '; */

    -- Generate sql query

    l_query                    :=
       get_late_rnwl_table_sel_clause (l_view_by
                           	     , l_view_by_col)
       		     || ' from '
       	              || poa_dbi_template_pkg.status_sql (
                             		              p_fact_name         => l_mv
                             		            , p_where_clause      => l_where_clause
                             		            , p_filter_where      => l_filter_where
                             		            , p_join_tables       => l_join_tbl
                             		            , p_use_windowing     => 'Y'
                             		            , p_col_name          => l_col_tbl
                             		            , p_use_grpid         => 'N'
                             		            , p_paren_count       => 7);

    x_custom_sql               := '/* OKI_DBI_SRM_LATE_BKNG_LRPT */ ' || l_query;

   oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

  END get_late_rnwl_table_sql;

  /*
     Late Renewal Bookings table Select clause
  */
  FUNCTION get_late_rnwl_table_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_sel_clause                VARCHAR2 (32767);
    l_viewby_select             VARCHAR2(32767);
    l_url_select         	VARCHAR2(32767);
    l_bookings_url              VARCHAR2(300);
    l_late_rnwl_booking_url 	VARCHAR2(300);
  BEGIN


    l_viewby_select:= oki_dbi_util_pvt.get_viewby_select_clause(p_view_by_dim, 'SRM', '6.0');

    -- Bookings URL when view by is Salesrep
    l_bookings_url  := '''pFunctionName=OKI_DBI_SRM_RSBK_DTL_DRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';

     --l_bookings_url  := '''pFunctionName=OKI_DBI_SRM_RSBK_DTL_DRPT''';
    l_late_rnwl_booking_url := '''pFunctionName=OKI_DBI_SRM_LATE_AGNG_LRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';
     --l_late_rnwl_booking_url := '''pFunctionName=OKI_DBI_SRM_LATE_AGNG_LRPT''';

    l_viewby_select:= l_viewby_select ||
                   ', OKI_DYNAMIC_URL_1
                    , OKI_DYNAMIC_URL_2
                    , OKI_DYNAMIC_URL_3
                    , oki_measure_1
                    , oki_measure_2
                    , oki_measure_3
                    , oki_measure_4
                    , oki_measure_5
                    , oki_measure_6
                    , oki_measure_7
                    , oki_measure_8
                    , oki_measure_11
                    , oki_measure_12
                    , oki_measure_13
                    , oki_measure_14
                    , oki_measure_15
                    , oki_measure_16
                    , oki_measure_17
                    , oki_measure_18
                    , oki_measure_23
                    , oki_measure_26
     		  FROM (
     		         SELECT
     		         	rank() over (&ORDER_BY_CLAUSE nulls last , '||p_view_by_col||') - 1 rnk ,'||p_view_by_col||'
     		         	 , OKI_DYNAMIC_URL_1
     		         	 , OKI_DYNAMIC_URL_2
     		         	 , OKI_DYNAMIC_URL_3
     		         	 , oki_measure_1
     		         	 , oki_measure_2
     		         	 , oki_measure_3
     		         	 , oki_measure_4
     		         	 , oki_measure_5
     		         	 , oki_measure_6
     		         	 , oki_measure_7
     		         	 , oki_measure_8
     		         	 , oki_measure_11
     		         	 , oki_measure_12
     		         	 , oki_measure_13
     		         	 , oki_measure_14
     		         	 , oki_measure_15
     		         	 , oki_measure_16
     		         	 , oki_measure_17
     		         	 , oki_measure_18
     		         	 , oki_measure_23
     		         	 , oki_measure_26
       			FROM ( ';

-- disabling links for unassigned group
 -- ' , decode(resource_id,-999,'''','||l_late_rnwl_booking_url||') OKI_DYNAMIC_URL_2 '||
 -- ' , decode(resource_id,-999,'''','||l_bookings_url||') OKI_DYNAMIC_URL_3 ';


        IF(p_view_by_dim = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
        THEN
           l_url_select :=
              'SELECT  decode(resource_id,-999,''pFunctionName=OKI_DBI_SRM_LATE_BKNG_LRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'','''') OKI_DYNAMIC_URL_1 '||
           ' , decode(resource_id,-999,'||l_late_rnwl_booking_url||',decode(rg_id,-1,'''','||l_late_rnwl_booking_url||')) OKI_DYNAMIC_URL_2 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_bookings_url||')) OKI_DYNAMIC_URL_3 ';


        ELSE
           l_url_select :=
              'SELECT  '''' OKI_DYNAMIC_URL_1 '||
              ' , '''' OKI_DYNAMIC_URL_2 '||
              ' , '''' OKI_DYNAMIC_URL_3 ';

    END IF;



       l_sel_clause               := l_viewby_select || l_url_select ||
          -- AK Attribute naming
          '   ,'|| p_view_by_col ||
          ' , oset20.C_Gr oki_measure_1 '||
          ' , oset20.c_Glr oki_measure_2 '||
          ' , oset20.c_late_rate oki_measure_3 '||
          ' , oset20.late_chg oki_measure_4 '||
          ' , oset20.c_Grr oki_measure_5 '||
          ' , oset20.c_grace_rate oki_measure_6 '||
          ' , oset20.grace_chg oki_measure_7 '||
          ' , oset20.c_avg_late oki_measure_8 '||
          ' , oset20.C_Gr_tot oki_measure_11 '||
          ' , oset20.c_Glr_tot oki_measure_12 '||
          ' , oset20.c_late_rate_tot oki_measure_13 '||
          ' , oset20.late_chg_tot oki_measure_14 '||
          ' , oset20.c_Grr_tot oki_measure_15 '||
          ' , oset20.c_grace_rate_tot oki_measure_16 '||
          ' , oset20.grace_chg_tot oki_measure_17 '||
          ' , oset20.c_avg_late_tot oki_measure_18 '||
          ' , oset20.p_late_rate oki_measure_23 '||
          ' , oset20.p_grace_rate oki_measure_26 '||
          '   from '||
          '   ( select '||
          -- Change Calculation
          '    '|| p_view_by_col ||
          '   , oset15.C_Gr '||
          '   , oset15.C_Gr_tot '||
          '   , oset15.c_Glr '||
          '   , oset15.c_Glr_tot '||
          '   , oset15.c_late_rate '||
          '   , oset15.p_late_rate '||
          '   , oset15.c_late_rate_tot '||
          '   ,'||oki_dbi_util_pvt.change_clause('oset15.c_late_rate','oset15.p_late_rate','P') || ' late_chg '||
          '   ,'||oki_dbi_util_pvt.change_clause('oset15.c_late_rate_tot','oset15.p_late_rate_tot','P') || ' late_chg_tot '||
          '   , oset15.c_Grr '||
          '   , oset15.c_Grr_tot '||
          '   , oset15.c_grace_rate '||
          '   , oset15.p_grace_rate '||
          '   , oset15.c_grace_rate_tot '||
          '   ,'||oki_dbi_util_pvt.change_clause('oset15.c_grace_rate','oset15.p_grace_rate','P') || ' grace_chg '||
          '   ,'||oki_dbi_util_pvt.change_clause('oset15.c_grace_rate_tot','oset15.p_grace_rate_tot','P') || ' grace_chg_tot '||
          '   , oset15.c_avg_late '||
          '   , oset15.c_avg_late_tot '||
          '   from  '||
          '    (select '||
               -- Calculated Measures
                p_view_by_col ||
               ' , oset13.c_Gr '||
               ' , oset13.c_Gr_tot '||
               ' , oset13.c_Glr '||
               ' , oset13.c_Glr_tot '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.c_Glr','oset13.c_Gr') || 'c_late_Rate '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.p_Glr','oset13.p_Gr') || 'p_late_Rate '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.c_Glr_tot','oset13.c_Gr_tot') || 'c_late_Rate_tot '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.p_Glr_tot','oset13.p_Gr_tot') || 'p_late_Rate_tot '||
               ' , oset13.c_Grr '||
               ' , oset13.c_Grr_tot '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.c_Grr','oset13.c_Gr') || 'c_grace_Rate '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.p_Grr','oset13.p_Gr') || 'p_grace_Rate '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.c_Grr_tot','oset13.c_Gr_tot') || 'c_grace_Rate_tot '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.p_Grr_tot','oset13.p_Gr_tot') || 'p_grace_Rate_tot '||
               ' , NVL(oset13.c_avg_late,0) c_avg_late '||
               ' , NVL(oset13.c_avg_late_tot,0) c_avg_late_tot '||
          '   from  '||
          '     (select '||
                --  Measures Based on a formula
                p_view_by_col ||
               ' , oset10.c_Gr '||
               ' , oset10.p_Gr '||
               ' , oset10.c_Gr_tot '||
               ' , oset10.p_Gr_tot '||
               ' , oset10.c_Glr '||
               ' , oset10.p_Glr '||
               ' , oset10.c_Glr_tot '||
               ' , oset10.p_Glr_tot '||
               ' , oset10.c_Grr '||
               ' , oset10.p_Grr '||
               ' , oset10.c_Grr_tot '||
               ' , oset10.p_Grr_tot '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('NVL(oset10.c_Gld,0)','oset10.c_Gld_count','NP') || 'c_avg_late '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('NVL(oset10.c_Gld_tot,0)','oset10.c_Gld_count_tot','NP') || 'c_avg_late_tot '||
               ' from '||
	                      '   ( select '||
	                      '        oset05.'||p_view_by_col ||
	                      '      , nvl(oset05.c_Gr,0) c_Gr '||
	                      '      , nvl(oset05.p_Gr,0) p_Gr '||
	                      '      , nvl(oset05.c_Gr_total,0) c_Gr_tot '||
	                      '      , nvl(oset05.p_Gr_total,0) p_Gr_tot '||
	                      '      , nvl(oset05.c_Glr,0) c_Glr '||
	                      '      , nvl(oset05.p_Glr,0) p_Glr '||
	                      '      , nvl(oset05.c_Glr_total,0) c_Glr_tot '||
	                      '      , nvl(oset05.p_Glr_total,0) p_Glr_tot '||
	                      '      , nvl(oset05.c_Grr,0) c_Grr '||
	                      '      , nvl(oset05.p_Grr,0) p_Grr '||
	                      '      , nvl(oset05.c_Grr_total,0) c_Grr_tot '||
	                      '      , nvl(oset05.p_Grr_total,0) p_Grr_tot '||
	                      '      , nvl(oset05.c_Gld,0) c_Gld '||
	                      '      , nvl(oset05.c_Gld_total,0) c_Gld_tot '||
	                      '      , nvl(oset05.c_Gld_count,0) c_Gld_count '||
	                      '      , nvl(oset05.c_Gld_count_total,0) c_Gld_count_tot ';


    RETURN l_sel_clause;

  END get_late_rnwl_table_sel_clause;

/*******************************************************************************
  Function: get_cncl_table_sql
  Description: Function to get Renewals Cancellations Summary Report DBI 6.0
*******************************************************************************/

PROCEDURE get_cncl_table_sql (
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

    l_filter_where           VARCHAR2 (1000);

    l_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed    VARCHAR2 (3) ;
    l_to_date_xtd    VARCHAR2 (3);
    l_to_date_ytd    VARCHAR2 (3);
    l_to_date_itd    VARCHAR2 (3);
    g_rs_group_id    number;
    g_resource_id    number;

  l_mv_1		VARCHAR2(100);
  l_mv_2		VARCHAR2(100);

  l_url_1		VARCHAR2(32000);
  l_url_2		VARCHAR2(32000);

  l_dim_where		VARCHAR2(32000);
--  l_inner_view_by_id	VARCHAR2(32000);
--  l_inner_group_by	VARCHAR2(32000);
  l_group_by		VARCHAR2(32000);

  l_pc_flag		VARCHAR2(100);
  l_pc_flag_where	VARCHAR2(32000);
  l_ou_flag		VARCHAR2(100);
  l_ou_flag_where	VARCHAR2(32000);
  l_sg			VARCHAR2(32000);
  l_sg_where		VARCHAR2(32000);
  l_sg_select_cust	VARCHAR2(32000);
  l_sg_groupby_cust	VARCHAR2(32000);

  l_pseudo_rs_group	VARCHAR2 (200);
  l_sep			NUMBER;

  l_org 		VARCHAR2(32000);
  l_org_where		VARCHAR2(32000);
  l_org_where2		VARCHAR2(32000);

  l_prod		VARCHAR2(32000);
  l_prod_where		VARCHAR2(32000);

  l_cancel		VARCHAR2(32000);
  l_cancel_where		VARCHAR2(32000);
  l_prod_cat		VARCHAR2(32000);
  l_prod_cat_where	VARCHAR2(32000);

  l_cust		VARCHAR2(32000);
  l_cust_where		VARCHAR2(32000);

  l_curr		VARCHAR2(50);

  l_lang		VARCHAR2(10);
  l_custom_rec 		BIS_QUERY_ATTRIBUTES ;

  BEGIN
    l_to_date_xed       := 'XED';
    l_to_date_xtd       := 'XTD';
    l_comparison_type   := 'Y';
    l_to_date_ytd       := 'YTD';
    l_to_date_itd       := 'ITD';
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
                                        , p_mv_set              => 'SRM_CN_71'
                                        , p_rg_where            => 'Y');
                                        --, p_rpt_type            => 'SUMMARY'

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'c_r_amt_' || l_cur_suffix
                               , p_alias_name      => 'Cr'
                               , p_to_date_type    => l_to_date_xtd);

   /* Additional filter needed to avoid displaying records queried due to total values at node */
   l_filter_where  := '  ( ABS(oki_measure_1) + ABS(oki_measure_21) ) <> 0 ';
    -- Generate sql query
    l_query                    :=
       get_cncl_table_sel_clause (  l_view_by
                           	  , l_view_by_col)
      			       	 || ' from '
      				   || poa_dbi_template_pkg.status_sql (
      				                                     p_fact_name         => l_mv
      				                                   , p_where_clause      => l_where_clause
      				                                   , p_filter_where      => l_filter_where
      				                                   , p_join_tables       => l_join_tbl
      				                                   , p_use_windowing     => 'Y'
      				                                   , p_col_name          => l_col_tbl
      				                                   , p_use_grpid         => 'N'
      				                                   , p_paren_count       => 7);
    x_custom_sql               := '/* OKI_DBI_SRM_CNCL_SUM_RPT */' || l_query;
   oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

  END get_cncl_table_sql;


  FUNCTION get_cncl_table_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_sel_clause         	VARCHAR2 (32767);
    l_viewby_select             VARCHAR2(32767);
    l_url_select         	VARCHAR2(32767);
    l_cancelled_value_url       VARCHAR2(300);
    l_cancelled_value_reason_url VARCHAR2(300);
    l_prodcat_url		VARCHAR2(300);

   BEGIN


    l_viewby_select := oki_dbi_util_pvt.get_viewby_select_clause(p_view_by_dim, 'SRM', '6.0');

     l_cancelled_value_url  := '''pFunctionName=OKI_DBI_SRM_CNCL_DTL_LRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';
     l_cancelled_value_reason_url:= '''pFunctionName=OKI_DBI_SRM_CNCL_DTL_LRPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';

    IF(p_view_by_dim = 'ITEM+ENI_ITEM_VBH_CAT')
    THEN
       l_prodcat_url :=
           ' decode(leaf_node_flag,''Y''
        , ''pFunctionName=OKI_DBI_SRM_CNCL_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM''
        ,''pFunctionName=OKI_DBI_SRM_CNCL_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT'' ) OKI_DYNAMIC_URL_3 ';
    ELSE
       l_prodcat_url := ''''' OKI_DYNAMIC_URL_3 ';
    END IF;

    l_viewby_select  :=  l_viewby_select ||
   			 ', OKI_DYNAMIC_URL_1
   			  , OKI_DYNAMIC_URL_2
   			  ,' ||l_prodcat_url || '
   			  , oki_measure_1
   			  , oki_measure_2
   			  , oki_measure_3
   			  , oki_measure_11
   			  , oki_measure_12
   			  , oki_measure_13
   			  , oki_measure_21
     FROM (SELECT
     		  rank() over (&ORDER_BY_CLAUSE nulls last , '||p_view_by_col||') - 1 rnk ,'||p_view_by_col||'
     		  ,OKI_DYNAMIC_URL_1
     		  ,OKI_DYNAMIC_URL_2
     		  ,oki_measure_1
     		  ,oki_measure_2
		  ,oki_measure_3
     		  ,oki_measure_11
     		  ,oki_measure_12
     		  ,sum(oki_measure_3) over() oki_measure_13
     		  ,oki_measure_21
     FROM ( ';


    IF(p_view_by_dim = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
      THEN
         l_url_select :=
            'SELECT  decode(resource_id,-999,''pFunctionName=OKI_DBI_SRM_CNCL_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'','''') OKI_DYNAMIC_URL_1 '||
        ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_cancelled_value_url||')) OKI_DYNAMIC_URL_2 ';

     ELSIF (p_view_by_dim IN ('OKI_STATUS+CNCL_REASON','ITEM+ENI_ITEM'))
         THEN
            l_url_select :=
	          'SELECT  '''' OKI_DYNAMIC_URL_1 '||
	          ' , '||l_cancelled_value_reason_url ||' OKI_DYNAMIC_URL_2 ';
     ELSE
          l_url_select :=
            'SELECT  '''' OKI_DYNAMIC_URL_1 '||
	             ' , '''' OKI_DYNAMIC_URL_2 ';
    END IF;

          l_sel_clause               := l_viewby_select || l_url_select ||
          -- AK Attribute naming
          '   ,'|| p_view_by_col ||
          ' , oset20.C_cncl oki_measure_1 '||
          ' , oset20.cncl_chg oki_measure_2 '||
          ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset20.C_cncl','oset20.C_cncl_tot') || ' oki_measure_3 '||
          ' , oset20.C_cncl_tot oki_measure_11 '||
          ' , oset20.cncl_chg_tot oki_measure_12 '||
          ' , oset20.p_cncl oki_measure_21 '||
          '   from '||
          '   ( select '||
          -- Change Calculation
          '    '|| p_view_by_col ||
          '   , oset15.C_Cr C_cncl '||
          '   , oset15.P_Cr P_cncl '||
          '   ,'||oki_dbi_util_pvt.change_clause('oset15.C_Cr','oset15.P_Cr','NP') || ' cncl_chg '||
          '   , oset15.C_Cr_tot C_cncl_tot '||
          '   , oset15.P_Cr_tot P_cncl_tot '||
          '   ,'||oki_dbi_util_pvt.change_clause('oset15.C_Cr_tot','oset15.P_Cr_tot','NP') || ' cncl_chg_tot '||
          '   from  '||
          '    (select '||
               -- Calculated Measures
                p_view_by_col ||
               ' , oset13.c_Cr '||
               ' , oset13.p_Cr '||
               ' , oset13.c_Cr_tot '||
               ' , oset13.p_Cr_tot '||
          '   from  '||
          '     (select '||
                --  Measures Based on a formula
                p_view_by_col ||
               ' , oset10.c_Cr c_Cr '||
               ' , oset10.p_Cr p_Cr '||
               ' , oset10.c_Cr_tot c_Cr_tot '||
               ' , oset10.p_Cr_tot p_Cr_tot '||
	 	      ' from '||
         		      '   ( select '||
         		      '        oset05.'||p_view_by_col ||
         		      '      , nvl(oset05.c_Cr,0) c_Cr '||
         		      '      , nvl(oset05.p_Cr,0) p_Cr '||
         		      '      , nvl(oset05.c_Cr_total,0) c_Cr_tot '||
         		      '      , nvl(oset05.p_Cr_total,0) p_Cr_tot ';


    RETURN l_sel_clause;
  END get_cncl_table_sel_clause;

/*******************************************************************************
  Function: get_cancellations_sql
  Description: Function to get Renewals Cancellations Summary Detail Report DBI 6.0
*******************************************************************************/

  PROCEDURE get_cancellations_sql (
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
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed    VARCHAR2 (3);
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
                                        , p_mv_set              => 'SRM_DTL_RPT'
                                        , p_rg_where            => 'Y');

     l_rpt_specific_where    :=
      ' AND fact.renewal_flag in (1,3)
        AND fact.date_cancelled between &BIS_CURRENT_EFFECTIVE_START_DATE
                                and &BIS_CURRENT_ASOF_DATE';

    l_group_by              := ' GROUP BY fact.chr_id, fact.customer_party_id, fact.resource_id, fact.sts_code ';

        poa_dbi_util_pkg.add_column ( p_col_tbl       => l_col_tbl
                                    , p_col_name      => 'price_negotiated_' || l_curr_suffix
                                    , p_alias_name    => 'cancelled_value'
                                    , p_prior_code    => poa_dbi_util_pkg.no_priors);

        l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();

        oki_dbi_util_pvt.join_rpt_where ( p_join_tbl     => l_join_tbl
                                        , p_func_area    => 'SRM'
                                        , p_version      => '6.0'
                                        , p_role         => NULL
                                        , p_mv_set       => 'SRM_DTL_RPT');

   /* Additional filter needed to avoid displaying records queried due to total values at node */
       l_filter_where  := ' ( ABS(oki_measure_1) ) <> 0 ';

       oki_dbi_util_pvt.add_join_table (p_join_tbl            => l_join_tbl
                                     , p_column_name          => 'id'
                                     , p_table_name           => 'OKI_CANCEL_STATUSES_V'
              			     , p_table_alias          => 'v'
                                     , p_fact_column          => 'sts_code'
                                     , p_additional_where_clause => NULL);


    l_query                 := get_cancellations_sel_clause (l_curr_suffix, l_period_type )

       || poa_dbi_template_pkg.dtl_status_sql2 (
                                               p_fact_name         => l_mv
                                             , p_where_clause      => l_where_clause || l_rpt_specific_where
                                             , p_join_tables       => l_join_tbl
                                             , p_use_windowing     => 'Y'
                                             , p_col_name          => l_col_tbl
                                             , p_use_grpid         => 'N'
                                             , p_filter_where      => l_filter_where
                                             , p_paren_count       => 5
                                             , p_group_by          => l_group_by
                                             , p_from_clause       => ' from '||l_mv ||' fact ');
    x_custom_sql            := '/* OKI_DBI_SRM_CNCL_DTL_LRPT */' || l_query;


   oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

  END get_cancellations_sql;

  FUNCTION get_cancellations_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_query   VARCHAR2 (10000);


  BEGIN

    -- Generate sql query
    l_query                    :=
        '
        SELECT
           k.complete_k_number oki_attribute_1,
           cust.value oki_attribute_2,
           DECODE(fact.resource_id,-1,&UNASSIGNED,rsex.resource_name) oki_attribute_3,
	   v.value oki_attribute_4,
    	   to_char(k.start_date) OKI_DATE_1,
	   to_char(fact.date_cancelled) OKI_DATE_2,
  	   k. price_nego_g oki_measure_2,
           oki_measure_1,
           oki_measure_11,
	   fact.chr_id OKI_ATTRIBUTE_5
      FROM (select *
       FROM (
          SELECT
             rank() over (&ORDER_BY_CLAUSE nulls last) - 1 rnk ,
             chr_id,
             customer_party_id,
             resource_id,
	     date_cancelled,
             oki_measure_1,
             oki_measure_11,
             oki_attribute_4 sts_code
          FROM (
              SELECT oset5.chr_id ,
                     oset5.customer_party_id ,
                     oset5.resource_id ,
		     oset5.date_cancelled,
                     nvl(oset5.cancelled_value,0)       OKI_MEASURE_1,
                     nvl(oset5.cancelled_value_total,0) OKI_MEASURE_11,
                     oset5.sts_code  oki_attribute_4
              FROM
                (SELECT
                    fact.chr_id,
                    fact.customer_party_id,
                    fact.resource_id,
		    min(fact.date_cancelled) date_cancelled,
                    fact.sts_code';
     RETURN l_query;
  END get_cancellations_sel_clause;

/* This procedure generates the entire SQL query that is required for the report
 * Renewal Cancellations By Customer.
 *
 * p_param      -->a table populated by PMV which contains all the parameters that
 *                 the user selects in the report
 * x_custom_sql -->the final SQL query that is generated
 * x_custom_output -->contains the bind variables
 */

 PROCEDURE get_cancln_by_cust_sql (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl)
  IS
    l_query                  VARCHAR2 (32767);
  BEGIN
    l_query                 := 'Hello';
     x_custom_sql               := '/* OKI_DBI_SRM_RSBK_DTL_CRPT */ ' || l_query;
     oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);
 END get_cancln_by_cust_sql;



/*******************************************************************************
  Function: get_cancln_by_cust_sel_clause
  Description: Function to get top most select portion of the SQL statment
*******************************************************************************/

/*
 FUNCTION get_cancln_by_cust_sel_clause
    RETURN VARCHAR2
  IS
      l_query  VARCHAR2(10000);

 BEGIN

 RETURN    l_query;
 END  get_cancln_by_cust_sel_clause;
  */



/*******************************************************************************
  Function: get_bucket_sql
  Description: Function to get Late Renewal Bookings Aging Report DBI 6.0
*******************************************************************************/

  PROCEDURE get_bucket_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                        x_custom_sql  OUT NOCOPY VARCHAR2,
                        x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

      l_query                  VARCHAR2 (32767);
      l_view_by                VARCHAR2 (120);
      l_view_by_col            VARCHAR2 (120);
      l_as_of_date             DATE;
      l_prev_as_of_date        DATE;
      l_xtd                    VARCHAR2 (10);
      l_comparison_type        VARCHAR2 (1)  ;
      l_period_type            VARCHAR2(10);
      l_nested_pattern         NUMBER;
      l_dim_bmap               NUMBER;
      l_cur_suffix             VARCHAR2 (2);
      l_custom_sql             VARCHAR2 (32767);
      l_custom_rec             bis_query_attributes;
      l_where_clause           VARCHAR2 (2000);
      l_mv                     VARCHAR2 (2000);
      l_col_rec                poa_dbi_util_pkg.poa_dbi_col_rec;
      l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
      l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
      l_url                    VARCHAR2 (500);
      l_to_date_xed    VARCHAR2 (3)      ;
      l_to_date_xtd    VARCHAR2 (3);

      l_curr_sql VARCHAR2(32767) ;
      l_rep_sql VARCHAR2(32767) ;
      l_bucket_rec                  bis_bucket_pub.BIS_BUCKET_REC_TYPE;
      l_error_tbl                   bis_utilities_pub.ERROR_TBL_TYPE;
      l_status                      VARCHAR2(10000);

      --Amount columns
      l_b1_amt          VARCHAR2(20) ;
      l_b2_amt          VARCHAR2(20) ;
      l_b3_amt          VARCHAR2(20) ;
      l_b4_amt          VARCHAR2(20) ;
      l_b5_amt          VARCHAR2(20) ;
      l_b6_amt          VARCHAR2(20) ;
      l_b7_amt          VARCHAR2(20) ;
      l_b8_amt          VARCHAR2(20) ;
      l_b9_amt          VARCHAR2(20) ;
      l_b10_amt         VARCHAR2(20) ;

    -- Contains the query

    BEGIN

    l_to_date_xed       := 'XED';
    l_to_date_xtd       := 'XTD';
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
                                          , p_mv_set              => 'SRM_LATE_BKING'
                                          , p_rg_where            => 'Y');

          l_b1_amt          := 'bucket1_amt_' || l_cur_suffix ;
          l_b2_amt          := 'bucket2_amt_' || l_cur_suffix ;
          l_b3_amt          := 'bucket3_amt_' || l_cur_suffix ;
          l_b4_amt          := 'bucket4_amt_' || l_cur_suffix ;
          l_b5_amt          := 'bucket5_amt_' || l_cur_suffix ;
          l_b6_amt          := 'bucket6_amt_' || l_cur_suffix ;
          l_b7_amt          := 'bucket7_amt_' || l_cur_suffix ;
          l_b8_amt          := 'bucket8_amt_' || l_cur_suffix ;
          l_b9_amt          := 'bucket9_amt_' || l_cur_suffix ;
          l_b10_amt         := 'bucket10_amt_' || l_cur_suffix ;

   -- Retrieve record to get bucket labels
    bis_bucket_pub.RETRIEVE_BIS_BUCKET('OKI_DBI_SRM_LATE_AGING', l_bucket_rec, l_status, l_error_tbl);

  /* sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
  					   (case when ' || l_b1_amt || '> 0
                                                 then fact.bucket1_cnt_g
                                                  else 0 end), 0))  B1_cnt,
  */

  l_curr_sql := 'SELECT
                 sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                                            fact.bucket1_cnt_g, 0))  B1_cnt,
                 sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                                       fact.bucket2_cnt_g, 0)) b2_cnt,
                 sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                                    fact.bucket3_cnt_g, 0)) b3_cnt,
                 sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                                     fact.bucket4_cnt_g, 0)) b4_cnt,
                 sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                                    fact.bucket5_cnt_g, 0)) b5_cnt,
                 sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                                    fact.bucket6_cnt_g, 0)) b6_cnt,
                 sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                                    fact.bucket7_cnt_g, 0)) b7_cnt,
                 sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                                    fact.bucket8_cnt_g, 0)) b8_cnt,
                 sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                                    fact.bucket9_cnt_g, 0)) b9_cnt,
                 sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                                    fact.bucket10_cnt_g, 0))  b10_cnt,

  	        sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,' || l_b1_amt || ', 0)) B1,
                  sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,' || l_b2_amt || ', 0)) b2,
                  sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,' || l_b3_amt || ', 0)) b3,
                  sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,' || l_b4_amt || ', 0)) b4,
                  sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,' || l_b5_amt || ', 0)) b5,
                  sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,' || l_b6_amt || ', 0)) b6,
                  sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,' || l_b7_amt || ', 0)) b7,
                  sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,' || l_b8_amt || ', 0)) b8,
                  sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,' || l_b9_amt || ', 0)) b9,
                 sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,' || l_b10_amt || ', 0)) b10,

                  sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,' || l_b1_amt || ', 0)) B1_p,
                  sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,' || l_b2_amt || ', 0)) b2_p,
                  sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,' || l_b3_amt || ', 0)) b3_p,
                  sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,' || l_b4_amt || ', 0)) b4_p,
                  sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,' || l_b5_amt || ', 0)) b5_p,
                  sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,' || l_b6_amt || ', 0)) b6_P,
                  sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,' || l_b7_amt || ', 0)) b7_p,
                  sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,' || l_b8_amt || ', 0)) b8_P,
                  sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,' || l_b9_amt || ', 0)) b9_p,
                 sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,' || l_b10_amt || ', 0)) b10_p

                 FROM '|| l_mv || '  fact,
                  FII_TIME_RPT_STRUCT_V           cal
             WHERE fact.time_id(+) = cal.time_id
              and fact.ren_type=''REN''
              ' || l_where_clause || '
             AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
             AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
             AND fact.grp_id = DECODE(cal.period_type_id
                                       ,1  ,14
                                       ,16 ,13
                                       ,32 ,11
                                       ,64 ,7 ) ' ;

   l_rep_sql := 'SELECT decode(rownum,
                          1, &RANGE1_NAME ,
                          2, &RANGE2_NAME ,
                          3, &RANGE3_NAME ,
                          4, &RANGE4_NAME ,
                          5, &RANGE5_NAME ,
                          6, &RANGE6_NAME ,
                          7, &RANGE7_NAME ,
                          8, &RANGE8_NAME ,
                          9, &RANGE9_NAME ,
                          10,&RANGE10_NAME, null)   BUCKET,
                          rownum                          BUCKET_TYPE,
                          decode(rownum,
                          1,b1_cnt,
                          2, b2_cnt,
                          3, b3_cnt,
                          4, b4_cnt,
                          5, b5_cnt,
                          6, b6_cnt,
                          7, b7_cnt,
                          8, b8_cnt,
                          9, b9_cnt,
                          10, b10_cnt, null)   line_CNT
                  ,decode(rownum,
                          1, b1,
                          2, b2,
                          3, b3,
                          4, b4,
                          5, b5,
                          6, b6,
                          7, b7,
                          8, b8,
                          9, b9,
                          10,b10, null) curr_late
                  ,decode(rownum,
                          1, b1_p,
                          2, b2_p,
                          3, b3_p,
                          4, b4_p,
                          5, b5_p,
                          6, b6_p,
                          7, b7_p,
                          8, b8_p,
                          9, b9_p,
                          10,b10_p, null) prior_late
          FROM (' ||l_curr_sql ||'),
          (SELECT id from oki_dbi_multiplexer_b where id < 11)';

     l_query := 'SELECT
        		bucket   OKI_ATTRIBUTE_3
                       ,bucket_type  OKI_MEASURE_23
  	               ,NVL(line_cnt,0)    OKI_MEASURE_1
                       ,nvl(curr_late,0)   OKI_MEASURE_2
                       ,nvl(prior_late,0)  OKI_MEASURE_3
		       ,'||oki_dbi_util_pvt.change_clause('curr_late','prior_late','NP') ||' OKI_MEASURE_4
                       ,nvl((sum(curr_late) over ()),0) OKI_MEASURE_12
                       ,nvl((curr_late /decode(sum(curr_late) over (),0,NULL,sum(curr_late) over ())*100),0) OKI_MEASURE_5
                       ,nvl((curr_late /decode(sum(curr_late) over (),0,NULL,sum(curr_late) over ())*100),0) OKI_MEASURE_6
                       ,(nvl((sum(curr_late) over ()),0) - (sum(prior_late) over ()))/ decode(sum(prior_late) over (),0,NULL,sum(prior_late) over ()) *100 OKI_MEASURE_14
                       ,nvl((sum(line_cnt) over ()),0) OKI_MEASURE_11
                       ,nvl((sum(curr_late) over () /decode(sum(curr_late) over (),0,NULL,sum(curr_late) over ()) *100),0) OKI_MEASURE_15

                  FROM  ( ' || l_rep_sql || '
                             )c
  		WHERE BUCKET IS NOT NULL
  	        ORDER BY BUCKET_TYPE ';

      x_custom_sql :=  '/* OKI_DBI_SRM_LATE_AGING_LRPT */' ||  l_query;

      oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);
      oki_dbi_util_pvt.get_bis_bucket_binds    (x_custom_output, l_bucket_rec);

    END get_bucket_sql ;

/*******************************************************************************
  Function: get_bkng_trend_sql (get_forecast_trend_sql)
  Description: Function for the Bookings Trend Forecast graph in DBI 6.0
*******************************************************************************/

 PROCEDURE get_bkng_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  -- Variables associated with the parameter portlet
    l_query             VARCHAR2 (32767);
    l_view_by           VARCHAR2 (120);
    l_view_by_col            VARCHAR2 (120);
    l_as_of_date        DATE;
    l_prev_as_of_date   DATE;
    l_xtd               VARCHAR2 (10);
    l_comparison_type   VARCHAR2 (1)   ;
    l_nested_pattern    NUMBER;
    l_dim_bmap          NUMBER;
    l_cur_suffix        VARCHAR2 (2);
    l_custom_sql        VARCHAR2 (10000);
    l_period_type            VARCHAR2(10);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;

    l_period_code varchar2(1);
    l_where_clause1          VARCHAR2 (2000);
    l_where_clause2          VARCHAR2 (2000);
    l_mv                     VARCHAR2 (2000);
    l_to_date_xtd    VARCHAR2 (3)  ;
    l_to_date_xed    VARCHAR2 (3) ;
    l_mv1		VARCHAR2(100);
    l_mv2		VARCHAR2(100);
    l_col_tbl1               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl2               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_xtd1                   VARCHAR2(10);
    l_xtd2                   VARCHAR2(10);
    l_mv_tbl                 poa_dbi_util_pkg.poa_dbi_mv_tbl;

  BEGIN

    l_to_date_xed       := 'XED';
    l_to_date_xtd       := 'XTD';
    l_comparison_type   := 'Y';

  l_join_tbl          := POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl ();
  l_col_tbl1          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_col_tbl2          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
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
                                        , p_mv_set              => 'SRM_SG_71'
                                        , p_rg_where            => 'Y');

    -- Populate col table with regular columns
    -- Period Renewal node
    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl1
                               , p_col_name       => 'g_r_amt_' || l_cur_suffix
                               , p_alias_name     => 'g_r_amt_xtd'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XTD');
    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl1
                               , p_col_name       => 'g_r_amt_' || l_cur_suffix
                               , p_alias_name     => 'g_r_amt_tot'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XED');

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
                                        , p_mv_set              => 'SRM_EC_71'
                                        , p_rg_where            => 'Y');
    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl2
                               , p_col_name       => 'f_f_amt_' || l_cur_suffix
                               , p_alias_name     => 'f_f_amt_xed'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XED');

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
   /* Additional filter needed to avoid displaying records queried due to total values at node */
     l_query                    :=  get_bkng_trend_sel_clause
       || ' from '
       || 	poa_dbi_template_pkg.union_all_trend_sql(
			             p_mv		    => l_mv_tbl,
                         p_comparison_type   => l_comparison_type,
              			 p_filter_where	    => NULL);
 -- insert into brrao_temp values ( l_query);
 -- commit;
/*
     l_query                    :=
          get_bkng_trend_sel_clause
       || ' from '
       || poa_dbi_template_pkg.trend_sql (p_xtd                => l_xtd
                                        , p_comparison_type    => l_comparison_type
                                        , p_fact_name          => l_mv
                                        , p_where_clause       => l_where_clause
                                        , p_col_name           => l_col_tbl
                                        , p_use_grpid          => 'R');
*/
    x_custom_sql               := '/* OKI_DBI_SRM_BKNG_FCST_G */ ' || l_query;
    oki_dbi_util_pvt.get_custom_trend_binds (l_xtd1
                                           , l_comparison_type
                                           , x_custom_output);

  END get_bkng_trend_sql ;

/*******************************************************************************
  Function: get_bkng_trend_sql_clause
  Description: Top SQL layer function for Bookings Forecast Trend in DBI 6.0
*******************************************************************************/

FUNCTION get_bkng_trend_sel_clause
    RETURN VARCHAR2
  IS
    l_sel_clause   VARCHAR2 (10000);
  BEGIN

   --  OKI_MEASURE_1  : Prior        - shows for current period only
   --  OKI_MEASURE_2  : Prior Total  -always show for all periods
   --  OKI_MEASURE_3  : Bookings     - shows for current period only
   --  OKI_MEASURE_4  : Expected Bookings - shows for current period only
   --  OKI_MEASURE_5  : Current Total  - shows for all prev periods only (except current)
   --  OKI_MEASURE_6  : Change (Bookings)
/*
    l_sel_clause               :=
        'Select  cal.NAME AS VIEWBY
           ,(case when iset.start_date != &BIS_CURRENT_EFFECTIVE_START_DATE
             then iset.c_g_r_amt_tot else NULL END) OKI_MEASURE_5
           , nvl(iset.p_g_r_amt_tot,0) OKI_MEASURE_2
           , nvl(iset.c_g_r_amt_xtd,0) OKI_MEASURE_3
           , nvl(iset.p_g_r_amt_xtd,0) OKI_MEASURE_1
	   , '||OKI_DBI_UTIL_PVT.change_clause('nvl(iset.c_g_r_amt_xtd,0)','iset.p_g_r_amt_xtd','NP')
	   ||' OKI_MEASURE_6
	  ,(case when iset.start_date = &BIS_CURRENT_EFFECTIVE_START_DATE
	   then nvl(iset.c_f_f_amt_xed,0) + nvl(iset.c_g_r_amt_xtd,0) else NULL
	   END) OKI_MEASURE_4
	';
*/

    l_sel_clause               :=
        'Select  cal_name AS VIEWBY
           ,(case when cal_start_date != &BIS_CURRENT_EFFECTIVE_START_DATE
             then c_g_r_amt_tot else NULL END) OKI_MEASURE_5
           , nvl(p_g_r_amt_tot,0) OKI_MEASURE_2
           , nvl(c_g_r_amt_xtd,0) OKI_MEASURE_3
           , nvl(p_g_r_amt_xtd,0) OKI_MEASURE_1
	   , '||OKI_DBI_UTIL_PVT.change_clause('nvl(c_g_r_amt_xtd,0)','p_g_r_amt_xtd','NP')
	   ||' OKI_MEASURE_6
	  ,(case when cal_start_date = &BIS_CURRENT_EFFECTIVE_START_DATE
	   then nvl(c_f_f_amt_xed,0) + nvl(c_g_r_amt_xtd,0) else NULL
	   END) OKI_MEASURE_4
	';

     RETURN l_sel_clause;
  END get_bkng_trend_sel_clause;


END oki_dbi_srm_rnwl_pvt;

/
