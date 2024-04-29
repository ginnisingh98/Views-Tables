--------------------------------------------------------
--  DDL for Package Body OKI_DBI_NSCM_EXP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_NSCM_EXP_PVT" AS
/* $Header: OKIPNEXB.pls 120.4 2006/02/06 00:41:43 pubalasu noship $ */


  FUNCTION get_expirations_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_period_expiring_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_exp_detail_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2
  , p_exp_type                  IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_prd_exp_cont_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2
  , p_exp_type                  IN       VARCHAR2)
    RETURN VARCHAR2;

  PROCEDURE get_expirations_sql (
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
    l_filter_where           VARCHAR2 (240);
    l_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed   CONSTANT VARCHAR2 (3)                     := 'XED';
    l_to_date_xtd   CONSTANT VARCHAR2 (3)                     := 'XTD';
    l_to_date_ytd   CONSTANT VARCHAR2 (3)                     := 'YTD';
    l_to_date_itd   CONSTANT VARCHAR2 (3)                     := 'ITD';


  BEGIN

    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();
    l_comparison_type  := 'Y';


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
                                        , p_mv_set              => 'SRM_EN_71'
                                        , p_rg_where            => 'Y');


    -- Populate col table with regular columns
    -- Period Renewal node
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'x_rg_amt_' || l_cur_suffix
                               , p_alias_name      => 'Xg'
                               , p_to_date_type    => l_to_date_xtd);


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'x_ro_o_amt_' || l_cur_suffix
                               , p_alias_name      => 'Xo'
                               , p_to_date_type    => l_to_date_xtd);


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'x_rc_amt_' || l_cur_suffix
                               , p_alias_name      => 'Xc'
                               , p_to_date_type    => l_to_date_xtd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'x_rd_o_amt_' || l_cur_suffix
                               , p_alias_name      => 'Xd'
                               , p_to_date_type    => l_to_date_xtd);



   /* Additional filter needed to avoid displaying records queried due to total values at node */
   l_filter_where  := ' ( ABS(oki_pmeasure_1) + ABS(oki_measure_1) ) <> 0 ';




	-- Generate sql query
    l_query                    :=
       get_expirations_sel_clause (l_view_by
                           , l_view_by_col)
       || ' from '
       || poa_dbi_template_pkg.status_sql (p_fact_name         => l_mv
                                         , p_where_clause      => l_where_clause
                                         , p_filter_where      => l_filter_where
                                         , p_join_tables       => l_join_tbl
                                         , p_use_windowing     => 'Y'
                                         , p_col_name          => l_col_tbl
                                         , p_use_grpid         => 'N'
                                         , p_paren_count       => 7);

    x_custom_sql               := l_query;
	oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

  END get_expirations_sql;


  PROCEDURE get_period_expiring_sql (
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
    l_filter_where           VARCHAR2 (240);
    l_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed   CONSTANT VARCHAR2 (3)                     := 'XED';
    l_to_date_xtd   CONSTANT VARCHAR2 (3)                     := 'XTD';
    l_to_date_ytd   CONSTANT VARCHAR2 (3)                     := 'YTD';
    l_to_date_itd   CONSTANT VARCHAR2 (3)                     := 'ITD';

  BEGIN

    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();
    l_comparison_type  := 'Y';



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
                                        , p_mv_set              => 'SRM_EN_71'
                                        , p_rg_where            => 'Y');


    -- Populate col table with regular columns
    -- Period Renewal node
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'x_rg_amt_' || l_cur_suffix
                               , p_alias_name      => 'Xg'
                               , p_to_date_type    => l_to_date_xed);


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'x_ro_o_amt_' || l_cur_suffix
                               , p_alias_name      => 'Xo'
                               , p_to_date_type    => l_to_date_xed);


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'x_rc_amt_' || l_cur_suffix
                               , p_alias_name      => 'Xc'
                               , p_to_date_type    => l_to_date_xed);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'x_rd_o_amt_' || l_cur_suffix
                               , p_alias_name      => 'Xd'
                               , p_to_date_type    => l_to_date_xed);



   /* Additional filter needed to avoid displaying records queried due to total values at node */
   l_filter_where  := ' ( ABS(oki_pmeasure_1) + ABS(oki_measure_1) ) <> 0 ';

    -- Generate sql query
    l_query                    :=
       get_period_expiring_sel_clause (l_view_by
                           , l_view_by_col)
       || ' from '
       || poa_dbi_template_pkg.status_sql (p_fact_name         => l_mv
                                         , p_where_clause      => l_where_clause
                                         , p_filter_where      => l_filter_where
                                         , p_join_tables       => l_join_tbl
                                         , p_use_windowing     => 'Y'
                                         , p_col_name          => l_col_tbl
                                         , p_use_grpid         => 'N'
                                         , p_paren_count       => 7);

    x_custom_sql               := l_query;
    oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

  END get_period_expiring_sql;

  /*
     Expirations Summary  Select clause
  */
  FUNCTION get_expirations_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_sel_clause         VARCHAR2 (32767);

    l_Xg_url             VARCHAR2(300);
    l_Xo_url             VARCHAR2(300);
    l_Xc_url             VARCHAR2(300);
    l_Xd_url             VARCHAR2(300);

    l_viewby_select      VARCHAR2(32767);
    l_url_select         VARCHAR2(32767);


  BEGIN


  /*  Column Definition Mapping:
      OKI_MEASURE_1  - Total Expired - Value (exp reports)
      OKI_TMEASURE_1 - Total Expired - Grand Total (exp reports)
      OKI_CHANGE_1   - Change colum (exp reports)
      OKI_TCHANGE_1  - Change _ Grand total (exp reports)
      OKI_MEASURE_2  - Renewed - Value (exp reports)
      OKI_TMEASURE_2 - Renewed - Grand Total (exp reports)
      OKI_MEASURE_3  - Open Renewal - Value (exp reports)
      OKI_TMEASURE_3 - Open Renewal- Grand Total (exp reports)
      OKI_MEASURE_4  - Cancelled Renewal - Value (exp reports)
      OKI_TMEASURE_4 - Cancelled Renewal  - Grand Total (exp reports)
      OKI_MEASURE_5  - No Renewal  - Value (exp reports)
      OKI_TMEASURE_5 - No Renewal   - Grand Total (exp reports)

      OKI_MEASURE_6  - Total Expired (exp portlet & Graph legend)
      OKI_MEASURE_7  - Total Expired - Grand total (exp portlet & Graph legend)
      OKI_CHANGE_2   - Change colum (exp portlet)
      OKI_TCHANGE_2  - Change _ Grand total (exp portlet)
      OKI_MEASURE_8  - Renewed (exp portlet & Graph legend)
      OKI_MEASURE_9  - Renewed - Grand total (exp portlet & Graph legend)
      OKI_MEASURE_10 - Open Renewal  (exp portlet & Graph legend)
      OKI_MEASURE_11 - Open Renewal - Grand total (exp portlet & Graph legend)
      OKI_MEASURE_12 - Cancelled Renewal(exp portlet & Graph legend)
      OKI_MEASURE_13 - Cancelled Renewal - Grand total (exp portlet & Graph legend)
      OKI_MEASURE_14 - No Renewal (exp portlet & Graph legend)
      OKI_TMEASURE_15- No Renewal - Grand Total (exp portlet & Graph legend)

  */


    l_viewby_select := oki_dbi_util_pvt.get_viewby_select_clause(p_view_by_dim, 'SRM_EN_71', '6.0');

    -- Drill Across URL when view by is Salesrep and Product
         l_Xg_url  := '''pFunctionName=OKI_DBI_SCM_EXP_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&OKI_STATUS+EXP_TYPE=1''';
         l_Xo_url  := '''pFunctionName=OKI_DBI_SCM_EXP_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&OKI_STATUS+EXP_TYPE=2''';
         l_Xc_url  := '''pFunctionName=OKI_DBI_SCM_EXP_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&OKI_STATUS+EXP_TYPE=3''';
         l_Xd_url  := '''pFunctionName=OKI_DBI_SCM_EXP_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&OKI_STATUS+EXP_TYPE=4''';

  l_viewby_select  :=  l_viewby_select ||
   ',OKI_SALES_GROUP_URL, OKI_DYNAMIC_URL_2 ,OKI_DYNAMIC_URL_3,OKI_DYNAMIC_URL_4 ,OKI_DYNAMIC_URL_5
    ,OKI_PMEASURE_1,OKI_MEASURE_1,OKI_TMEASURE_1,OKI_CHANGE_1,OKI_TCHANGE_1
    ,OKI_KPI_MEASURE_1,OKI_PKPI_MEASURE_1,OKI_TKPI_MEASURE_1,OKI_PTKPI_MEASURE_1
    ,OKI_PERCENT_1,sum(oki_percent_1) over() OKI_TPERCENT_1, OKI_MEASURE_2,OKI_TMEASURE_2,OKI_PERCENT_2,OKI_TPERCENT_2
    ,OKI_MEASURE_3,OKI_TMEASURE_3,OKI_PERCENT_3,OKI_TPERCENT_3,OKI_MEASURE_4,OKI_TMEASURE_4
    ,OKI_PERCENT_4,OKI_TPERCENT_4,OKI_MEASURE_5,OKI_TMEASURE_5,OKI_PERCENT_5,OKI_TPERCENT_5
    , OKI_MEASURE_1 OKI_MEASURE_6, OKI_CHANGE_1 OKI_CHANGE_2, OKI_TCHANGE_1 OKI_TCHANGE_2
    , OKI_TMEASURE_1 OKI_MEASURE_7, OKI_MEASURE_2 OKI_MEASURE_8, OKI_TMEASURE_2 OKI_MEASURE_9
    , OKI_MEASURE_3 OKI_MEASURE_10,OKI_TMEASURE_3 OKI_MEASURE_11, OKI_MEASURE_4 OKI_MEASURE_12
    , OKI_TMEASURE_4 OKI_MEASURE_13, OKI_MEASURE_5 OKI_MEASURE_14,OKI_TMEASURE_5  OKI_MEASURE_15
    , OKI_ATTRIBUTE_2, OKI_ATTRIBUTE_4 , OKI_ATTRIBUTE_5    , OKI_ATTRIBUTE_6
     FROM (SELECT  rank() over (&ORDER_BY_CLAUSE nulls last , '||p_view_by_col||') - 1 rnk ,'||p_view_by_col||'
    ,OKI_ATTRIBUTE_2,OKI_ATTRIBUTE_4,OKI_ATTRIBUTE_5,OKI_ATTRIBUTE_6,OKI_SALES_GROUP_URL, OKI_DYNAMIC_URL_2 ,OKI_DYNAMIC_URL_3,OKI_DYNAMIC_URL_4 ,OKI_DYNAMIC_URL_5
    ,OKI_PMEASURE_1,OKI_MEASURE_1,OKI_TMEASURE_1,OKI_CHANGE_1,OKI_TCHANGE_1
    ,OKI_KPI_MEASURE_1,OKI_PKPI_MEASURE_1,OKI_TKPI_MEASURE_1,OKI_PTKPI_MEASURE_1
    ,OKI_PERCENT_1,OKI_MEASURE_2,OKI_TMEASURE_2,OKI_PERCENT_2,OKI_TPERCENT_2
    ,OKI_MEASURE_3,OKI_TMEASURE_3,OKI_PERCENT_3,OKI_TPERCENT_3,OKI_MEASURE_4,OKI_TMEASURE_4
    ,OKI_PERCENT_4,OKI_TPERCENT_4,OKI_MEASURE_5,OKI_TMEASURE_5,OKI_PERCENT_5,OKI_TPERCENT_5
       FROM ( ';

    IF(p_view_by_dim = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
    THEN
       l_url_select :=
          'SELECT  decode(resource_id,-999,''pFunctionName=OKI_DBI_SCM_EXP_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'','''') OKI_SALES_GROUP_URL '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Xg_url||')) OKI_DYNAMIC_URL_2 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Xo_url||')) OKI_DYNAMIC_URL_3 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Xo_url||')) OKI_ATTRIBUTE_2 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Xc_url||')) OKI_ATTRIBUTE_4 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Xd_url||')) OKI_ATTRIBUTE_5 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Xg_url||')) OKI_ATTRIBUTE_6 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Xc_url||')) OKI_DYNAMIC_URL_4 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Xd_url||')) OKI_DYNAMIC_URL_5 ';
    ELSIF(p_view_by_dim = 'ITEM+ENI_ITEM')
    THEN
       l_url_select :=
          'SELECT  ''''  OKI_SALES_GROUP_URL '||
          ' , '||l_Xg_url||' OKI_DYNAMIC_URL_2 '||
          ' , '||l_Xo_url||' OKI_DYNAMIC_URL_3 '||
          ' , '||l_Xo_url||' OKI_ATTRIBUTE_2 '||
          ' , '||l_Xc_url||' OKI_ATTRIBUTE_4 '||
          ' , '||l_Xd_url||' OKI_ATTRIBUTE_5 '||
          ' , '||l_Xg_url||' OKI_ATTRIBUTE_6 '||
          ' , '||l_Xc_url||' OKI_DYNAMIC_URL_4 '||
          ' , '||l_Xd_url||' OKI_DYNAMIC_URL_5 ';
    ELSE
       l_url_select :=
          'SELECT  '''' OKI_SALES_GROUP_URL '||
          ' , '''' OKI_DYNAMIC_URL_2 '||
          ' , '''' OKI_DYNAMIC_URL_3 '||
          ' , '''' OKI_ATTRIBUTE_2 '||
          ' , '''' OKI_ATTRIBUTE_4 '||
          ' , '''' OKI_ATTRIBUTE_5 '||
          ' , '''' OKI_ATTRIBUTE_6 '||
          ' , '''' OKI_DYNAMIC_URL_4 '||
          ' , '''' OKI_DYNAMIC_URL_5 ';
    END IF;

      l_sel_clause               := l_viewby_select || l_url_select ||
          -- AK Attribute naming
          '   ,'|| p_view_by_col ||
          ' , oset20.p_X           OKI_PMEASURE_1 '||
          ' , oset20.c_X           OKI_MEASURE_1 '||
          ' , oset20.c_X_tot       OKI_TMEASURE_1 '||
          ' , oset20.X_chg         OKI_CHANGE_1 '||
          ' , oset20.X_chg_tot     OKI_TCHANGE_1 '||
          ' , oset20.c_X           OKI_KPI_MEASURE_1 '||
          ' , oset20.p_X           OKI_PKPI_MEASURE_1 '||
          ' , oset20.c_X_tot       OKI_TKPI_MEASURE_1 '||
          ' , oset20.p_X_tot       OKI_PTKPI_MEASURE_1 '||
          ' , oset20.c_X_per       OKI_PERCENT_1 '||
          ' , oset20.c_Xg          OKI_MEASURE_2 '||
          ' , oset20.c_Xg_tot      OKI_TMEASURE_2 '||
          ' , oset20.c_Xg_per      OKI_PERCENT_2 '||
          ' , oset20.c_Xg_per_tot  OKI_TPERCENT_2 '||
          ' , oset20.c_Xo          OKI_MEASURE_3 '||
          ' , oset20.c_Xo_tot      OKI_TMEASURE_3 '||
          ' , oset20.c_Xo_per      OKI_PERCENT_3 '||
          ' , oset20.c_Xo_per_tot  OKI_TPERCENT_3 '||
          ' , oset20.c_Xc          OKI_MEASURE_4 '||
          ' , oset20.c_Xc_tot      OKI_TMEASURE_4 '||
          ' , oset20.c_Xc_per      OKI_PERCENT_4 '||
          ' , oset20.c_Xc_per_tot  OKI_TPERCENT_4 '||
          ' , oset20.c_Xd          OKI_MEASURE_5 '||
          ' , oset20.c_Xd_tot      OKI_TMEASURE_5 '||
          ' , oset20.c_Xd_per      OKI_PERCENT_5 '||
          ' , oset20.c_Xd_per_tot  OKI_TPERCENT_5 '||
          '   from '||
          '   ( select '||
          -- Change Calculation
          '    '|| p_view_by_col ||
          '   , oset15.c_X c_X '||
          '   , oset15.p_X p_X '||
          '   , oset15.c_X_tot c_X_tot '||
          '   , oset15.p_X_tot p_X_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_X','oset15.p_X','NP') || ' X_chg '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_X_tot','oset15.p_X_tot','NP') || ' X_chg_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_X','oset15.c_X_tot') || ' c_X_per '||
          '   , oset15.c_Xg c_Xg '||
          '   , oset15.c_Xg_tot c_Xg_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xg','oset15.c_X') || ' c_Xg_per '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xg_tot','oset15.c_X_tot') || ' c_Xg_per_tot '||
          '   , oset15.c_Xo c_Xo '||
          '   , oset15.c_Xo_tot c_Xo_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xo','oset15.c_X') || ' c_Xo_per '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xo_tot','oset15.c_X_tot') || ' c_Xo_per_tot '||
          '   , oset15.c_Xc c_Xc '||
          '   , oset15.c_Xc_tot c_Xc_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xc','oset15.c_X') || ' c_Xc_per '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xc_tot','oset15.c_X_tot') || ' c_Xc_per_tot '||
          '   , oset15.c_Xd c_Xd '||
          '   , oset15.c_Xd_tot c_Xd_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xd','oset15.c_X') || ' c_Xd_per '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xd_tot','oset15.c_X_tot') || ' c_Xd_per_tot '||
          '   from  '||
          '    (select '||
               -- Calculated Measures
                p_view_by_col ||
               ' , (oset13.c_Xg + oset13.c_Xo + oset13.c_Xc + oset13.c_Xd) c_X '||
               ' , (oset13.p_Xg + oset13.p_Xo + oset13.p_Xc + oset13.p_Xd) p_X '||
               ' , (oset13.c_Xg_tot + oset13.c_Xo_tot + oset13.c_Xc_tot + oset13.c_Xd_tot) c_X_tot '||
               ' , (oset13.p_Xg_tot + oset13.p_Xo_tot + oset13.p_Xc_tot + oset13.p_Xd_tot) p_X_tot '||
               ' , oset13.c_Xg '||
               ' , oset13.c_Xg_tot '||
               ' , oset13.c_Xo '||
               ' , oset13.c_Xo_tot '||
               ' , oset13.c_Xc '||
               ' , oset13.c_Xc_tot '||
               ' , oset13.c_Xd '||
               ' , oset13.c_Xd_tot '||
          '   from  '||
          '     (select '||
                --  Measures Based on a formula
                p_view_by_col ||
               ' , oset10.c_Xg c_Xg '||
               ' , oset10.p_Xg p_Xg '||
               ' , oset10.c_Xg_tot c_Xg_tot '||
               ' , oset10.p_Xg_tot p_Xg_tot '||
               ' , oset10.c_Xo c_Xo '||
               ' , oset10.p_Xo p_Xo '||
               ' , oset10.c_Xo_tot c_Xo_tot '||
               ' , oset10.p_Xo_tot p_Xo_tot '||
               ' , oset10.c_Xc c_Xc '||
               ' , oset10.p_Xc p_Xc '||
               ' , oset10.c_Xc_tot c_Xc_tot '||
               ' , oset10.p_Xc_tot p_Xc_tot '||
               ' , oset10.c_Xd c_Xd '||
               ' , oset10.p_Xd p_Xd '||
               ' , oset10.c_Xd_tot c_Xd_tot '||
               ' , oset10.p_Xd_tot p_Xd_tot '||
               ' from '||
               '   ( select '||
               '        oset05.'||p_view_by_col ||
               '      , NVL(oset05.c_Xg,0) c_Xg '||
               '      , NVL(oset05.p_Xg,0) p_Xg '||
               '      , NVL(oset05.c_Xg_total,0) c_Xg_tot '||
               '      , NVL(oset05.p_Xg_total,0) p_Xg_tot '||
               '      , NVL(oset05.c_Xo,0) c_Xo '||
               '      , NVL(oset05.p_Xo,0) p_Xo '||
               '      , NVL(oset05.c_Xo_total,0) c_Xo_tot '||
               '      , NVL(oset05.p_Xo_total,0) p_Xo_tot '||
               '      , NVL(oset05.c_Xc,0) c_Xc '||
               '      , NVL(oset05.p_Xc,0) p_Xc '||
               '      , NVL(oset05.c_Xc_total,0) c_Xc_tot '||
               '      , NVL(oset05.p_Xc_total,0) p_Xc_tot '||
               '      , NVL(oset05.c_Xd,0) c_Xd '||
               '      , NVL(oset05.p_Xd,0) p_Xd '||
               '      , NVL(oset05.c_Xd_total,0) c_Xd_tot '||
               '      , NVL(oset05.p_Xd_total,0) p_Xd_tot ';

    RETURN l_sel_clause;
  END get_expirations_sel_clause;

  /*
     Period Expiring Summary  Select clause
  */
  FUNCTION get_period_expiring_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_sel_clause         VARCHAR2 (32767);

    l_Xg_url             VARCHAR2(300);
    l_Xo_url             VARCHAR2(300);
    l_Xc_url             VARCHAR2(300);
    l_Xd_url             VARCHAR2(300);

    l_viewby_select      VARCHAR2(32767);
    l_url_select         VARCHAR2(32767);
  BEGIN


    l_viewby_select := oki_dbi_util_pvt.get_viewby_select_clause(p_view_by_dim, 'SRM_EN_71', '6.0');

    -- Drill Across URL when view by is Salesrep and Product
         l_Xg_url  := '''pFunctionName=OKI_DBI_SCM_PEX_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&OKI_STATUS+EXP_TYPE=1''';
         l_Xo_url  := '''pFunctionName=OKI_DBI_SCM_PEX_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&OKI_STATUS+EXP_TYPE=2''';
         l_Xc_url  := '''pFunctionName=OKI_DBI_SCM_PEX_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&OKI_STATUS+EXP_TYPE=3''';
         l_Xd_url  := '''pFunctionName=OKI_DBI_SCM_PEX_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&OKI_STATUS+EXP_TYPE=4''';

    l_viewby_select  :=  l_viewby_select ||
   ', OKI_SALES_GROUP_URL, OKI_DYNAMIC_URL_2 ,OKI_DYNAMIC_URL_3,OKI_DYNAMIC_URL_4 ,OKI_DYNAMIC_URL_5
    ,OKI_PMEASURE_1,OKI_MEASURE_1,OKI_TMEASURE_1,OKI_CHANGE_1,OKI_TCHANGE_1
    ,OKI_PERCENT_1,sum(oki_percent_1) over() OKI_TPERCENT_1, OKI_MEASURE_2,OKI_TMEASURE_2,OKI_PERCENT_2,OKI_TPERCENT_2
    ,OKI_MEASURE_3,OKI_TMEASURE_3,OKI_PERCENT_3,OKI_TPERCENT_3,OKI_MEASURE_4,OKI_TMEASURE_4
    ,OKI_PERCENT_4,OKI_TPERCENT_4,OKI_MEASURE_5,OKI_TMEASURE_5,OKI_PERCENT_5,OKI_TPERCENT_5
     FROM (SELECT  rank() over (&ORDER_BY_CLAUSE nulls last , '||p_view_by_col||') - 1 rnk ,'||p_view_by_col||'
    ,OKI_SALES_GROUP_URL, OKI_DYNAMIC_URL_2 ,OKI_DYNAMIC_URL_3,OKI_DYNAMIC_URL_4 ,OKI_DYNAMIC_URL_5
    ,OKI_PMEASURE_1,OKI_MEASURE_1,OKI_TMEASURE_1,OKI_CHANGE_1,OKI_TCHANGE_1
    ,OKI_PERCENT_1,OKI_MEASURE_2,OKI_TMEASURE_2,OKI_PERCENT_2,OKI_TPERCENT_2
    ,OKI_MEASURE_3,OKI_TMEASURE_3,OKI_PERCENT_3,OKI_TPERCENT_3,OKI_MEASURE_4,OKI_TMEASURE_4
    ,OKI_PERCENT_4,OKI_TPERCENT_4,OKI_MEASURE_5,OKI_TMEASURE_5,OKI_PERCENT_5,OKI_TPERCENT_5
       FROM ( ';

    IF(p_view_by_dim = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
    THEN
       l_url_select :=
          'SELECT  decode(resource_id,-999,''pFunctionName=OKI_DBI_SCM_PEX_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'','''') OKI_SALES_GROUP_URL '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Xg_url||')) OKI_DYNAMIC_URL_2 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Xo_url||')) OKI_DYNAMIC_URL_3 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Xc_url||')) OKI_DYNAMIC_URL_4 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Xd_url||')) OKI_DYNAMIC_URL_5 ';
    ELSIF(p_view_by_dim = 'ITEM+ENI_ITEM')
    THEN
       l_url_select :=
          'SELECT  ''''  OKI_SALES_GROUP_URL '||
          ' , '||l_Xg_url||' OKI_DYNAMIC_URL_2 '||
          ' , '||l_Xo_url||' OKI_DYNAMIC_URL_3 '||
          ' , '||l_Xc_url||' OKI_DYNAMIC_URL_4 '||
          ' , '||l_Xd_url||' OKI_DYNAMIC_URL_5 ';
    ELSE
       l_url_select :=
          'SELECT  '''' OKI_SALES_GROUP_URL '||
          ' , '''' OKI_DYNAMIC_URL_2 '||
          ' , '''' OKI_DYNAMIC_URL_3 '||
          ' , '''' OKI_DYNAMIC_URL_4 '||
          ' , '''' OKI_DYNAMIC_URL_5 ';
    END IF;

      l_sel_clause               := l_viewby_select || l_url_select ||
          -- AK Attribute naming
          '   ,'|| p_view_by_col ||
          ' , oset20.p_X           OKI_PMEASURE_1 '||
          ' , oset20.c_X           OKI_MEASURE_1 '||
          ' , oset20.c_X_tot       OKI_TMEASURE_1 '||
          ' , oset20.X_chg         OKI_CHANGE_1 '||
          ' , oset20.X_chg_tot     OKI_TCHANGE_1 '||
          ' , oset20.c_X_per       OKI_PERCENT_1 '||
          ' , oset20.c_Xg          OKI_MEASURE_2 '||
          ' , oset20.c_Xg_tot      OKI_TMEASURE_2 '||
          ' , oset20.c_Xg_per      OKI_PERCENT_2 '||
          ' , oset20.c_Xg_per_tot  OKI_TPERCENT_2 '||
          ' , oset20.c_Xo          OKI_MEASURE_3 '||
          ' , oset20.c_Xo_tot      OKI_TMEASURE_3 '||
          ' , oset20.c_Xo_per      OKI_PERCENT_3 '||
          ' , oset20.c_Xo_per_tot  OKI_TPERCENT_3 '||
          ' , oset20.c_Xc          OKI_MEASURE_4 '||
          ' , oset20.c_Xc_tot      OKI_TMEASURE_4 '||
          ' , oset20.c_Xc_per      OKI_PERCENT_4 '||
          ' , oset20.c_Xc_per_tot  OKI_TPERCENT_4 '||
          ' , oset20.c_Xd          OKI_MEASURE_5 '||
          ' , oset20.c_Xd_tot      OKI_TMEASURE_5 '||
          ' , oset20.c_Xd_per      OKI_PERCENT_5 '||
          ' , oset20.c_Xd_per_tot  OKI_TPERCENT_5 '||
          '   from '||
          '   ( select '||
          -- Change Calculation
          '    '|| p_view_by_col ||
          '   , oset15.c_X c_X '||
          '   , oset15.p_X p_X '||
          '   , oset15.c_X_tot c_X_tot '||
          '   , oset15.p_X_tot p_X_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_X','oset15.p_X','NP') || ' X_chg '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_X_tot','oset15.p_X_tot','NP') || ' X_chg_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_X','oset15.c_X_tot') || ' c_X_per '||
          '   , oset15.c_Xg c_Xg '||
          '   , oset15.c_Xg_tot c_Xg_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xg','oset15.c_X') || ' c_Xg_per '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xg_tot','oset15.c_X_tot') || ' c_Xg_per_tot '||
          '   , oset15.c_Xo c_Xo '||
          '   , oset15.c_Xo_tot c_Xo_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xo','oset15.c_X') || ' c_Xo_per '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xo_tot','oset15.c_X_tot') || ' c_Xo_per_tot '||
          '   , oset15.c_Xc c_Xc '||
          '   , oset15.c_Xc_tot c_Xc_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xc','oset15.c_X') || ' c_Xc_per '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xc_tot','oset15.c_X_tot') || ' c_Xc_per_tot '||
          '   , oset15.c_Xd c_Xd '||
          '   , oset15.c_Xd_tot c_Xd_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xd','oset15.c_X') || ' c_Xd_per '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xd_tot','oset15.c_X_tot') || ' c_Xd_per_tot '||
          '   from  '||
          '    (select '||
               -- Calculated Measures
                p_view_by_col ||
               ' , (oset13.c_Xg + oset13.c_Xo + oset13.c_Xc + oset13.c_Xd) c_X '||
               ' , (oset13.p_Xg + oset13.p_Xo + oset13.p_Xc + oset13.p_Xd) p_X '||
               ' , (oset13.c_Xg_tot + oset13.c_Xo_tot + oset13.c_Xc_tot + oset13.c_Xd_tot) c_X_tot '||
               ' , (oset13.p_Xg_tot + oset13.p_Xo_tot + oset13.p_Xc_tot + oset13.p_Xd_tot) p_X_tot '||
               ' , oset13.c_Xg '||
               ' , oset13.c_Xg_tot '||
               ' , oset13.c_Xo '||
               ' , oset13.c_Xo_tot '||
               ' , oset13.c_Xc '||
               ' , oset13.c_Xc_tot '||
               ' , oset13.c_Xd '||
               ' , oset13.c_Xd_tot '||
          '   from  '||
          '     (select '||
                --  Measures Based on a formula
                p_view_by_col ||
               ' , oset10.c_Xg c_Xg '||
               ' , oset10.p_Xg p_Xg '||
               ' , oset10.c_Xg_tot c_Xg_tot '||
               ' , oset10.p_Xg_tot p_Xg_tot '||
               ' , oset10.c_Xo c_Xo '||
               ' , oset10.p_Xo p_Xo '||
               ' , oset10.c_Xo_tot c_Xo_tot '||
               ' , oset10.p_Xo_tot p_Xo_tot '||
               ' , oset10.c_Xc c_Xc '||
               ' , oset10.p_Xc p_Xc '||
               ' , oset10.c_Xc_tot c_Xc_tot '||
               ' , oset10.p_Xc_tot p_Xc_tot '||
               ' , oset10.c_Xd c_Xd '||
               ' , oset10.p_Xd p_Xd '||
               ' , oset10.c_Xd_tot c_Xd_tot '||
               ' , oset10.p_Xd_tot p_Xd_tot '||
               ' from '||
               '   ( select '||
               '        oset05.'||p_view_by_col ||
               '      , NVL(oset05.c_Xg,0) c_Xg '||
               '      , NVL(oset05.p_Xg,0) p_Xg '||
               '      , NVL(oset05.c_Xg_total,0) c_Xg_tot '||
               '      , NVL(oset05.p_Xg_total,0) p_Xg_tot '||
               '      , NVL(oset05.c_Xo,0) c_Xo '||
               '      , NVL(oset05.p_Xo,0) p_Xo '||
               '      , NVL(oset05.c_Xo_total,0) c_Xo_tot '||
               '      , NVL(oset05.p_Xo_total,0) p_Xo_tot '||
               '      , NVL(oset05.c_Xc,0) c_Xc '||
               '      , NVL(oset05.p_Xc,0) p_Xc '||
               '      , NVL(oset05.c_Xc_total,0) c_Xc_tot '||
               '      , NVL(oset05.p_Xc_total,0) p_Xc_tot '||
               '      , NVL(oset05.c_Xd,0) c_Xd '||
               '      , NVL(oset05.p_Xd,0) p_Xd '||
               '      , NVL(oset05.c_Xd_total,0) c_Xd_tot '||
               '      , NVL(oset05.p_Xd_total,0) p_Xd_tot ';

    RETURN l_sel_clause;
  END get_period_expiring_sel_clause;

  FUNCTION exptype_detail(
    p_type                      IN VARCHAR2
  , p_renewed                   IN NUMBER
  , p_open                      IN NUMBER
  , p_cancelled                 IN NUMBER
  , p_norenewal                 IN NUMBER ) RETURN NUMBER IS
    l_retval NUMBER;
  BEGIN

    SELECT
       CASE WHEN (p_type = 'All' or p_type = 'ALL' or p_type is NULL) THEN
          NVL(p_renewed,0)+NVL(p_open,0)+NVL(p_cancelled,0)+NVL(p_norenewal,0)
       WHEN (p_type = '1') THEN
          p_renewed
       WHEN (p_type = '2') THEN
          p_open
       WHEN (p_type = '3') THEN
          p_cancelled
       WHEN (p_type = '4') THEN
          p_norenewal
       END
    INTO
       l_retval
    FROM dual;

    RETURN l_retval;

  END exptype_detail;

  PROCEDURE get_expirations_detail_sql (
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
    l_additional_mv          VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed   CONSTANT VARCHAR2 (3)                     := 'XED';
    l_to_date_xtd   CONSTANT VARCHAR2 (3)                     := 'XTD';

    l_rpt_specific_where     VARCHAR2 (1000);
    l_join_where             VARCHAR2 (1000);
    l_group_by               VARCHAR2 (1000);
    l_exp_type               VARCHAR2 (100);
    l_exp_type_filter               VARCHAR2 (100);

    l_filter_where           VARCHAR2 (240);
    l_columns   VARCHAR (5000);
    l_additional_where       VARCHAR2 (2000);

  BEGIN

    l_comparison_type  := 'Y';

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
                                        , p_version             => '7.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_CDTL_RPT'
                                        , p_rg_where            => 'Y');

	l_rpt_specific_where    := ' AND   fact.effective_expire_date between &BIS_CURRENT_EFFECTIVE_START_DATE
	and &BIS_CURRENT_ASOF_DATE  AND   fact.date_signed is not null'; -- modified for OKI 8.0

	poa_dbi_util_pkg.add_column (p_col_tbl       => l_col_tbl
                               , p_col_name      => 'price_negotiated_' || l_cur_suffix
                               , p_alias_name    => 'affected_value'
                               , p_prior_code    => poa_dbi_util_pkg.no_priors);

    l_group_by     := '   GROUP BY fact.chr_id, fact.customer_party_id, fact.resource_id,fact.date_signed';

	l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();

    OKI_DBI_UTIL_PVT.join_rpt_where (p_join_tbl     => l_join_tbl
                                    , p_func_area    => 'SRM'
                                    , p_version      => '6.0'
                                    , p_role         => NULL
                                    , p_mv_set       => 'SRM_CDTL_RPT');

    l_filter_where  := '  ( ABS(oki_measure_2) ) <> 0  ';
    l_additional_mv := ' ) fact
                       , OKI_SCM_OCR_MV k
                       WHERE fact.chr_id = k.chr_id) ';
    l_exp_type  :=  NVL(OKI_DBI_UTIL_PVT.get_param_id(p_param,'OKI_STATUS+EXP_TYPE'),'''All''');

    if l_exp_type = '''All''' then
    l_exp_type_filter:=' AND exp_renewal_flag <> 0';
    else
    select ' AND exp_renewal_flag='||decode(l_exp_type,'''1''','2','''2''','1','''3''','4','''4''','8')
    into l_exp_type_filter
    from dual;
   end if;

    l_rpt_specific_where:=l_rpt_specific_where||l_exp_type_filter;


    l_query                 := get_exp_detail_sel_clause(l_cur_suffix, l_period_type, l_exp_type)
                             || poa_dbi_template_pkg.dtl_status_sql2 (
                                               p_fact_name         => l_mv
                                             , p_where_clause      => l_where_clause || l_rpt_specific_where
                                             , p_join_tables       => l_join_tbl
                                             , p_use_windowing     => 'Y'
                                             , p_col_name          => l_col_tbl
                                             , p_use_grpid         => 'N'
                                             , p_filter_where      => l_filter_where||l_additional_mv
                                             , p_paren_count       => 5
                                             , p_group_by          => l_group_by
                                             , p_from_clause       => 'from '||l_mv ||' fact ');
    x_custom_sql            := l_query;

    OKI_DBI_UTIL_PVT.get_custom_status_binds (x_custom_output);

   /* l_columns :=   ', sum(price_negotiated_' || l_cur_suffix || ' + ubt_amt_' || l_cur_suffix ||
    ' + supp_credit_' || l_cur_suffix || ' + credit_amt_' || l_cur_suffix || ' ) affected_value,
     sum(sum(price_negotiated_' || l_cur_suffix || ' + ubt_amt_' || l_cur_suffix ||
    ' + supp_credit_' || l_cur_suffix || ' + credit_amt_' || l_cur_suffix || ' )) Over () affected_value_total ';




    */
   /* Additional filter needed to avoid displaying records queried due to total values at node */


--	l_additional_where := l_mv;








  --  l_query     := get_exp_detail_sel_clause (l_cur_suffix, l_period_type, l_exp_type ) || l_columns
--   ||l_where_clause || l_rpt_specific_where ||l_group_by ||l_filter_where||l_additional_where;

--     x_custom_sql            := l_query;
 --  OKI_DBI_UTIL_PVT.get_custom_status_binds (x_custom_output);

END get_expirations_detail_sql;

  FUNCTION get_exp_detail_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2
  , p_exp_type                  IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_query   VARCHAR2 (10000);


  BEGIN

    -- Generate sql query
    l_query                    :=
        '
        SELECT
           complete_k_number OKI_ATTRIBUTE_1,
           cust.value     OKI_ATTRIBUTE_2,
           DECODE(fact.resource_id,-1,&UNASSIGNED,rsex.resource_name) oki_attribute_3,
           to_char(date_signed) OKI_DATE_2,
	   to_char(end_date) OKI_DATE_1,
	   price_nego_' ||p_cur_suffix ||' OKI_MEASURE_1,
           OKI_TMEASURE_1,
           OKI_MEASURE_2,
           OKI_TMEASURE_2,
	   fact.chr_id OKI_ATTRIBUTE_5
     FROM(
       SELECT *
       FROM
       ((
      SELECT
      FACT.*
      ,K.COMPLETE_K_NUMBER
      ,K.END_DATE END_DATE
      , K.PRICE_NEGO_' ||p_cur_suffix ||'
      , SUM(price_nego_' ||p_cur_suffix ||') over ()  OKI_TMEASURE_1
       FROM (
          SELECT
             rank() over (&ORDER_BY_CLAUSE nulls last) - 1 rnk ,
             chr_id,
             customer_party_id,
             resource_id,
             oki_measure_2,
             oki_tmeasure_2,
			 date_signed
          FROM (
              SELECT oset5.chr_id    ,
                     oset5.customer_party_id  ,
                     oset5.resource_id   ,
		     affected_value OKI_MEASURE_2,
                     affected_value_total  OKI_TMEASURE_2,
					 date_signed
              FROM
                (SELECT
                    fact.chr_id,
                    fact.customer_party_id,
                    fact.resource_id,
					fact.date_signed
		   ';
     RETURN l_query;
  END get_exp_detail_sel_clause;

 PROCEDURE get_prd_exp_cont_dtl_sql (
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
    l_additional_mv           VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed   CONSTANT VARCHAR2 (3)                     := 'XED';
    l_to_date_xtd   CONSTANT VARCHAR2 (3)                     := 'XTD';

    l_rpt_specific_where     VARCHAR2 (1000);
    l_join_where             VARCHAR2 (1000);
    l_group_by               VARCHAR2 (1000);
    l_exp_type               VARCHAR2 (100);

    l_filter_where           VARCHAR2 (240);
    l_exp_renewal_flag       NUMBER;

  BEGIN

    l_comparison_type    := 'Y';
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
                                        , p_version             => '7.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_CDTL_RPT'
                                        , p_rg_where            => 'Y');

    l_exp_type  :=  OKI_DBI_UTIL_PVT.get_param_id(p_param,'OKI_STATUS+EXP_TYPE');

    SELECT DECODE (l_exp_type, '''1''', 2, '''2''', 1,'''3''', 4,'''4''', 8) INTO l_exp_renewal_flag FROM DUAL;


  	l_rpt_specific_where    := ' AND  fact.effective_expire_date between &BIS_CURRENT_EFFECTIVE_START_DATE
 	                                                     and  &BIS_CURRENT_EFFECTIVE_END_DATE
 	                               AND  fact.date_signed is not null';
    IF l_exp_renewal_flag IS NULL THEN
    l_rpt_specific_where    := l_rpt_specific_where || ' AND fact.exp_renewal_flag <> 0';
    ELSE
    l_rpt_specific_where    := l_rpt_specific_where || ' AND fact.exp_renewal_flag = ' || l_exp_renewal_flag;
    END IF;

  l_group_by              := ' GROUP BY fact.chr_id, fact.customer_party_id, fact.resource_id, fact.date_signed';

    poa_dbi_util_pkg.add_column (p_col_tbl       => l_col_tbl
                                , p_col_name		 => 'price_negotiated_' || l_cur_suffix
                               , p_alias_name    => 'expired_value'
                               , p_prior_code    => poa_dbi_util_pkg.no_priors);

   /* Additional filter needed to avoid displaying records queried due to total values at node*/
    l_filter_where  := ' ( ABS(oki_measure_2) ) <> 0 ';
     l_additional_mv := ' ) fact
                       , OKI_SCM_OCR_MV k
                       WHERE fact.chr_id = k.chr_id) ';

    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();


    oki_dbi_util_pvt.join_rpt_where (p_join_tbl     => l_join_tbl
                                    , p_func_area    => 'SRM'
                                    , p_version      => '6.0'
                                    , p_role         => NULL
                                    , p_mv_set       => 'SRM_CDTL_RPT');


    l_query                 := get_prd_exp_cont_sel_clause (l_cur_suffix, l_period_type, l_exp_type )
       ||poa_dbi_template_pkg.dtl_status_sql2 (p_fact_name         => l_mv
                                             , p_where_clause      => l_where_clause || l_rpt_specific_where
                                             , p_join_tables       => l_join_tbl
                                             , p_use_windowing     => 'Y'
                                             , p_col_name          => l_col_tbl
                                             , p_use_grpid         => 'N'
                                             , p_filter_where      => l_filter_where||l_additional_mv
                                             , p_paren_count       => 5
                                             , p_group_by          => l_group_by
                                             , p_from_clause       => ' from '||l_mv ||' fact ');
    x_custom_sql            := l_query;


   oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

END get_prd_exp_cont_dtl_sql;

/*Added by Arun for Perido Expiring Contracts Detail*/

  FUNCTION get_prd_exp_cont_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2
  , p_exp_type                  IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_query   VARCHAR2 (10000);
  BEGIN
    -- Generate sql query
    l_query                    :=
        '
        SELECT
           complete_k_number oki_attribute_1,
           cust.value     OKI_ATTRIBUTE_2,
           DECODE(fact.resource_id,-1,&UNASSIGNED,rsex.resource_name) oki_attribute_3,
           to_char(end_date) OKI_DATE_1,
	   to_char(date_signed) OKI_DATE_2,
           OKI_MEASURE_2,
           OKI_TMEASURE_2,
           OKI_MEASURE_1,
           OKI_TMEASURE_1,
	   fact.chr_id OKI_ATTRIBUTE_5
     FROM(
       SELECT * FROM
       ((
       SELECT fact.*,
       k.complete_k_number
       , k.end_date
       , k.price_nego_'|| p_cur_suffix || '
       , NVL(price_nego_'|| p_cur_suffix || ',0) OKI_MEASURE_1
       , NVL(SUM(price_nego_' ||p_cur_suffix ||') over (),0) OKI_TMEASURE_1
       FROM (
          SELECT
             rank() over (&ORDER_BY_CLAUSE nulls last) - 1 rnk ,
             chr_id,
             customer_party_id,
             resource_id,
	     date_signed,
             oki_measure_2,
             oki_tmeasure_2
          FROM (
              SELECT oset5.chr_id    ,
                     oset5.customer_party_id  ,
                     oset5.resource_id   ,
		     oset5.date_signed,
                     oset5.expired_value OKI_MEASURE_2,
                     oset5.expired_value_total OKI_TMEASURE_2
              FROM
                (SELECT
                    fact.chr_id,
                    fact.customer_party_id,
                    fact.resource_id,
		    fact.date_signed';

     RETURN l_query;
  END get_prd_exp_cont_sel_clause;



  PROCEDURE get_exp_dist_sql  (
    p_param                     IN  bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl) IS

       l_query                  VARCHAR2 (32767);
    l_as_of_date             DATE;
    l_prev_as_of_date        DATE;
    l_xtd                    VARCHAR2 (10);
    l_comparison_type        VARCHAR2 (1);
    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2 (2);
    l_where_clause           VARCHAR2 (2000);
    l_view_by          VARCHAR2 (240);
    l_view_by_col          VARCHAR2 (240);
    l_to_date_xtd   CONSTANT VARCHAR2 (3)                     := 'XTD';
    l_mv                     VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;


   BEGIN

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
                                        , p_mv_set              => 'SRM_EN_71'
                                        , p_rg_where            => 'Y');

    -- Populate col table with regular columns
    -- Period Renewal node
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'x_rg_amt_' || l_cur_suffix
                               , p_alias_name      => 'Xg'
                               , p_to_date_type    => l_to_date_xtd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'x_ro_o_amt_' || l_cur_suffix
                               , p_alias_name      => 'Xo'
                               , p_to_date_type    => l_to_date_xtd);


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'x_rc_amt_' || l_cur_suffix
                               , p_alias_name      => 'Xc'
                               , p_to_date_type    => l_to_date_xtd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'x_rd_o_amt_' || l_cur_suffix
                               , p_alias_name      => 'Xd'
                               , p_to_date_type    => l_to_date_xtd);


    l_query                    :=
       get_expdist_sel_clause
       || ' from ( select 1 '
       || oki_dbi_util_pvt.get_nested_cols(l_col_tbl,'XTD','N')
       || oki_dbi_util_pvt.get_xtd_where(l_mv, 'N', 'XTD')
       || l_where_clause
       || ') oset05) oset10) oset15) oset20) oset '
       || ' , fnd_lookups l
          WHERE l.lookup_type = ''OKI_EXP_TYPE''
          ORDER BY lookup_code ';


     x_custom_sql               := l_query;
     oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

   END get_exp_dist_sql;

/*********************************************************************
*   Function for getting top SQL for Expired Value Distribution report
*********************************************************************/

  FUNCTION get_expdist_sel_clause RETURN VARCHAR2 IS

    l_sel_clause         VARCHAR2 (32767);
    l_top_select      VARCHAR2(32767);

  BEGIN

     l_top_select := 'SELECT   l.meaning oki_attribute_1  '||
                            ', decode(l.lookup_code
                                       , ''1'', c_Xg_tot
                                       , ''2'', c_Xo_tot
                                       , ''3'', c_Xc_tot
                                       , ''4'', c_Xd_tot ) oki_measure_1
                             , c_X_tot oki_tmeasure_1

                             , decode(l.lookup_code
                                       , ''1'', Xg_chg_tot
                                       , ''2'', Xo_chg_tot
                                       , ''3'', Xc_chg_tot
                                       , ''4'', Xd_chg_tot) oki_change_1
                             ,  X_chg_tot oki_tchange_1
                             , decode(l.lookup_code
                                       , ''1'', c_Xg_per_tot
                                       , ''2'', c_Xo_per_tot
                                       , ''3'', c_Xc_per_tot
                                       , ''4'', c_Xd_per_tot) oki_percent_1
                             , X_per_tot oki_tpercent_1
                             , decode(l.lookup_code
                                       , ''1'', Xg_perchg_tot
                                       , ''2'', Xo_perchg_tot
                                       , ''3'', Xc_perchg_tot
                                       , ''4'', Xd_perchg_tot) oki_percent_change_1
                             , 0 oki_tpercent_change_1
                          FROM ( ';

      l_sel_clause := l_top_select || 'Select '||
          '    oset20.c_X_tot c_X_tot '||
          '   , oset20.c_Xg_tot c_Xg_tot '||
          '   , oset20.c_Xo_tot c_Xo_tot '||
          '   , oset20.c_Xc_tot c_Xc_tot '||
          '   , oset20.c_Xd_tot c_Xd_tot '||
          '   , oset20.X_chg_tot X_chg_tot '||
          '   , oset20.Xg_chg_tot Xg_chg_tot '||
          '   , oset20.Xo_chg_tot Xo_chg_tot '||
          '   , oset20.Xc_chg_tot Xc_chg_tot '||
          '   , oset20.Xd_chg_tot Xd_chg_tot '||
          '   , oset20.c_Xg_per_tot c_Xg_per_tot '||
          '   , oset20.c_Xo_per_tot c_Xo_per_tot '||
          '   , oset20.c_Xc_per_tot c_Xc_per_tot '||
          '   , oset20.c_Xd_per_tot c_Xd_per_tot '||
          '   , oset20.X_per_tot X_per_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset20.c_Xg_per_tot','oset20.p_Xg_per_tot','P') || ' Xg_perchg_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset20.c_Xo_per_tot','oset20.p_Xo_per_tot','P') || ' Xo_perchg_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset20.c_Xc_per_tot','oset20.p_Xc_per_tot','P') || ' Xc_perchg_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset20.c_Xd_per_tot','oset20.p_Xd_per_tot','P') || ' Xd_perchg_tot '||
          '   from  '||
          '    (select '||
           '  oset15.c_Xg_tot '||
           ' , oset15.c_Xo_tot '||
           ' , oset15.c_Xc_tot '||
           ' , oset15.c_Xd_tot '||
           ' , oset15.c_X_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_X_tot','oset15.p_X_tot','NP') || ' X_chg_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_Xg_tot','oset15.p_Xg_tot','NP') || ' Xg_chg_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_Xo_tot','oset15.p_Xo_tot','NP') || ' Xo_chg_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_Xc_tot','oset15.p_Xc_tot','NP') || ' Xc_chg_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_Xd_tot','oset15.p_Xd_tot','NP') || ' Xd_chg_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xg_tot','oset15.c_X_tot') || ' c_Xg_per_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xo_tot','oset15.c_X_tot') || ' c_Xo_per_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xc_tot','oset15.c_X_tot') || ' c_Xc_per_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_Xd_tot','oset15.c_X_tot') || ' c_Xd_per_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.p_Xg_tot','oset15.p_X_tot') || ' p_Xg_per_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.p_Xo_tot','oset15.p_X_tot') || ' p_Xo_per_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.p_Xc_tot','oset15.p_X_tot') || ' p_Xc_per_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.p_Xd_tot','oset15.p_X_tot') || ' p_Xd_per_tot '||
          '   ,'||POA_DBI_UTIL_PKG.rate_clause('oset15.c_X_tot','oset15.c_X_tot') || ' X_per_tot '||
          '   from  '||
          '    (select '||
               '  (oset10.c_Xg_tot + oset10.c_Xo_tot + oset10.c_Xc_tot + oset10.c_Xd_tot) c_X_tot '||
               ' , (oset10.p_Xg_tot + oset10.p_Xo_tot + oset10.p_Xc_tot + oset10.p_Xd_tot) p_X_tot '||
               ' , oset10.c_Xg_tot '||
               ' , oset10.p_Xg_tot '||
               ' , oset10.c_Xo_tot '||
               ' , oset10.p_Xo_tot '||
               ' , oset10.c_Xc_tot '||
               ' , oset10.p_Xc_tot '||
               ' , oset10.c_Xd_tot '||
               ' , oset10.p_Xd_tot '||
          '   from  '||
                 '   ( select '||
               '       NVL(oset05.c_Xg_total,0) c_Xg_tot '||
               '      , NVL(oset05.p_Xg_total,0) p_Xg_tot '||
               '      , NVL(oset05.c_Xo_total,0) c_Xo_tot '||
               '      , NVL(oset05.p_Xo_total,0) p_Xo_tot '||
               '      , NVL(oset05.c_Xc_total,0) c_Xc_tot '||
               '      , NVL(oset05.p_Xc_total,0) p_Xc_tot '||
               '      , NVL(oset05.c_Xd_total,0) c_Xd_tot '||
               '      , NVL(oset05.p_Xd_total,0) p_Xd_tot ';

    RETURN l_sel_clause;
  END get_expdist_sel_clause;


END OKI_DBI_NSCM_EXP_PVT;

/
