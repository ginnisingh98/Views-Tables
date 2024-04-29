--------------------------------------------------------
--  DDL for Package Body OKI_DBI_NSCM_ACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_NSCM_ACT_PVT" AS
/* $Header: OKIPNACB.pls 120.4 2006/02/06 00:43:30 pubalasu noship $ */

/******************************************************************
*  Procedure to return the query for Activations portlet
*
******************************************************************/
    PROCEDURE get_activations_sql  (
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
    l_xtd1		     VARCHAR2 (10);
    l_xtd2                   VARCHAR2 (10);
    l_comparison_type        VARCHAR2 (1);
    l_period_type            VARCHAR2(10);
    l_nested_pattern         NUMBER;
    l_cur_suffix             VARCHAR2 (2);
    l_where_clause           VARCHAR2 (2000);
    l_filter_where           VARCHAR2 (240);
    l_where_clause1          VARCHAR2 (2000);
    l_where_clause2          VARCHAR2 (2000);
    l_mv                     VARCHAR2 (2000);
     l_mv1                   VARCHAR2 (2000);
    l_mv2                    VARCHAR2 (2000);
    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl1               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl2               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_mv_tbl                 poa_dbi_util_pkg.poa_dbi_mv_tbl;

    l_to_date_xed            CONSTANT VARCHAR2 (3)                     := 'XED';
    l_to_date_xtd            CONSTANT VARCHAR2 (3)                     := 'XTD';
    l_to_date_ytd            CONSTANT VARCHAR2 (3)                     := 'YTD';
    l_to_date_itd            CONSTANT VARCHAR2 (3)                     := 'ITD';
    l_balance_logic          VARCHAR2(10);

    BEGIN

    l_comparison_type        := 'Y';
    l_join_tbl               := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl                := poa_dbi_util_pkg.poa_dbi_col_tbl ();
    l_col_tbl1               := poa_dbi_util_pkg.poa_dbi_col_tbl ();
    l_col_tbl2               := poa_dbi_util_pkg.poa_dbi_col_tbl ();
    l_mv_tbl                 := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

    l_filter_where  := '  (ABS(oki_measure_1)+ABS(oki_pmeasure_1)+ABS(oki_measure_3)) <> 0';

    /* Balance logic for OI */
    l_balance_logic := nvl(fnd_profile.value('OKI_BAL_IDENT'),'CONTRDATE');

    IF (l_balance_logic = 'EVENTDATE') THEN
--{

    OKI_DBI_UTIL_PVT.process_parameters ( p_param               => p_param
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
                                        , p_mv_set              => 'SRM_ST_71' --Change done to support customer classication (NGM)
                                        , p_rg_where            => 'Y');

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 's_g_amt_' || l_cur_suffix
                               , p_alias_name      => 'NBsgo'
                               , p_to_date_type    => l_to_date_xtd);


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 's_xg_r_amt_' || l_cur_suffix
                               , p_alias_name      => 'AEsxr'
                               , p_to_date_type    => l_to_date_xtd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 's_rg_amt_' || l_cur_suffix
                               , p_alias_name      => 'ARsro'
                               , p_to_date_type    => l_to_date_xtd);


   OKI_DBI_UTIL_PVT.process_parameters (  p_param               => p_param
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
                                        , p_trend               => 'N'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_SG_71' --Change done to support customer classication (NGM)
                                        , p_rg_where            => 'Y');

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl2
                               , p_col_name        => 'gl_s_amt_' || l_cur_suffix
                               , p_alias_name      => 'NBgo'
                               , p_to_date_type    => l_to_date_xtd);


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl2
                               , p_col_name        => 'gL_o_amt_' || l_cur_suffix
                               , p_alias_name      => 'AEglr'
                               , p_to_date_type    => l_to_date_xtd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl2
                               , p_col_name        => 'gl_r_amt_' || l_cur_suffix
                               , p_alias_name      => 'ARgls'
                               , p_to_date_type    => l_to_date_xtd);


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


  -- Generate sql query

  l_query  := get_activations_sel_clause (l_view_by, l_view_by_col)

       || ' from ('

       || poa_dbi_template_pkg.union_all_status_sql
		                  (p_mv              => l_mv_tbl,
                           p_join_tables     => l_join_tbl,
                           p_use_windowing   => 'Y',
                           p_paren_count     => 1,
                           p_filter_where    => NULL,
                           p_generate_viewby => 'N') || ')'
                           || '  oset05 ) oset10) oset15) oset20 )  where' || l_filter_where || ')oset , '

       || poa_dbi_template_pkg.get_viewby_rank_clause ( p_join_tables    => l_join_tbl
                                                        , p_use_windowing     => 'Y' );

--}
  ELSE
--{

	      OKI_DBI_UTIL_PVT.process_parameters ( p_param               => p_param
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
                                        , p_mv_set              => 'SRM_ST_71' --Change done to support customer classication (NGM)
                                        , p_rg_where            => 'Y');

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 's_g_o_amt_' || l_cur_suffix
                               , p_alias_name      => 'NBsgo'
                               , p_to_date_type    => l_to_date_xtd);


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 's_x_r_amt_' || l_cur_suffix
                               , p_alias_name      => 'AEsxr'
                               , p_to_date_type    => l_to_date_xtd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 's_r_o_amt_' || l_cur_suffix
                               , p_alias_name      => 'ARsro'
                               , p_to_date_type    => l_to_date_xtd);

    -- Generate sql query
    l_query                    := get_activations_sel_clause (l_view_by, l_view_by_col) || ' from '

       || poa_dbi_template_pkg.status_sql (p_fact_name         => l_mv
                                         , p_where_clause      => l_where_clause
                                         , p_filter_where      => l_filter_where
                                         , p_join_tables       => l_join_tbl
                                         , p_use_windowing     => 'Y'
                                         , p_col_name          => l_col_tbl
                                         , p_use_grpid         => 'N'
                                         , p_paren_count       => 6);
--}
END IF;

      x_custom_sql               := l_query;

   OKI_DBI_UTIL_PVT.get_custom_status_binds (x_custom_output);

    END get_activations_sql  ;

/******************************************************************
*       get activations Select clause SQL - Activations portlet
******************************************************************/

  FUNCTION get_activations_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_sel_clause         VARCHAR2 (32767);
    l_newbus_url         VARCHAR2(300);
    l_activated_url      VARCHAR2(300);
    l_prodcat_url        VARCHAR2(300);
    l_viewby_select      VARCHAR2(32767);
    l_url_select         VARCHAR2(32767);
    l_balance_logic      VARCHAR2(10);
  BEGIN

     /* Balance logic for OI */
    l_balance_logic := nvl(fnd_profile.value('OKI_BAL_IDENT'),'CONTRDATE');

    l_viewby_select := OKI_DBI_UTIL_PVT.get_viewby_select_clause(p_view_by_dim, 'SRM', '6.0');

    -- when view by is Salesrep OKI_DBI_SCM_ACT_DTL_RPT
         l_newbus_url  := '''pFunctionName=OKI_DBI_SCM_ACT_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&OKI_STATUS+ACT_TYPE=1''';

         l_activated_url  := '''pFunctionName=OKI_DBI_SCM_ACT_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&OKI_STATUS+ACT_TYPE=2''';

    IF(p_view_by_dim = 'ITEM+ENI_ITEM_PROD_LEAF_CAT')
    THEN
       l_prodcat_url := '''pFunctionName=OKI_DBI_SCM_ACT_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM'' OKI_VBH_CAT_URL ';
    ELSE
       l_prodcat_url := ''''' OKI_VBH_CAT_URL ';
    END IF;


    l_viewby_select  :=  l_viewby_select ||
   ',OKI_SALES_GROUP_URL, OKI_DYNAMIC_URL_2 ,OKI_DYNAMIC_URL_5 , '|| l_prodcat_url ||
     ',OKI_MEASURE_1, OKI_PMEASURE_1, OKI_TMEASURE_1, OKI_CHANGE_1,OKI_TCHANGE_1' ||
    ', OKI_PERCENT_1,OKI_TPERCENT_1,OKI_PERCENT_CHANGE_1,OKI_MEASURE_2,OKI_TMEASURE_2' ||
    ',OKI_KPI_MEASURE_2,OKI_PKPI_MEASURE_2,OKI_TKPI_MEASURE_2,OKI_PTKPI_MEASURE_2' ||
   ',OKI_PERCENT_2,OKI_TPERCENT_2,OKI_MEASURE_3,OKI_TMEASURE_3,OKI_MEASURE_4,OKI_TMEASURE_4,OKI_ATTRIBUTE_5,OKI_PERCENT_CHANGE_2' ||
  ',OKI_MEASURE_5,OKI_TMEASURE_5,OKI_KPI_MEASURE_5,OKI_PKPI_MEASURE_5,OKI_TKPI_MEASURE_5' ||
   ',OKI_PTKPI_MEASURE_5,OKI_PERCENT_5, OKI_TPERCENT_5,OKI_ATTRIBUTE_1,OKI_ATTRIBUTE_4 ' ||
   '  FROM (SELECT  rank() over (&ORDER_BY_CLAUSE nulls last , '||p_view_by_col||') - 1 rnk ,'
   ||p_view_by_col||',OKI_SALES_GROUP_URL, OKI_DYNAMIC_URL_2 ,OKI_DYNAMIC_URL_5 ,OKI_MEASURE_1 '||
  ', OKI_PMEASURE_1, OKI_TMEASURE_1, OKI_CHANGE_1,OKI_TCHANGE_1,OKI_PERCENT_1,OKI_TPERCENT_1' ||
 ',OKI_PERCENT_CHANGE_1,OKI_MEASURE_2,OKI_TMEASURE_2,OKI_KPI_MEASURE_2,OKI_PKPI_MEASURE_2 '||
  ',OKI_TKPI_MEASURE_2,OKI_PTKPI_MEASURE_2,OKI_PERCENT_2,OKI_TPERCENT_2,OKI_MEASURE_3,OKI_ATTRIBUTE_5,OKI_PERCENT_CHANGE_2 ' ||
   ',OKI_TMEASURE_3,OKI_MEASURE_4,OKI_TMEASURE_4,OKI_MEASURE_5,OKI_TMEASURE_5,OKI_KPI_MEASURE_5 '||
  ',OKI_PKPI_MEASURE_5,OKI_TKPI_MEASURE_5,OKI_PTKPI_MEASURE_5,OKI_PERCENT_5,OKI_TPERCENT_5,OKI_ATTRIBUTE_1,OKI_ATTRIBUTE_4
       FROM ( ';

    IF(p_view_by_dim = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
    THEN
       l_url_select :=
          'SELECT  decode(resource_id,-999,''pFunctionName=OKI_DBI_SCM_ACT_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'','''') OKI_SALES_GROUP_URL '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_newbus_url||')) OKI_DYNAMIC_URL_2 '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_activated_url||')) OKI_DYNAMIC_URL_5 ';

    ELSIF(p_view_by_dim = 'ITEM+ENI_ITEM')
    THEN
       l_url_select :=
         'SELECT  ''''  OKI_SALES_GROUP_URL '||
          ' , '||l_newbus_url||' OKI_DYNAMIC_URL_2 '||
          ' , '||l_activated_url||' OKI_DYNAMIC_URL_5 ';
    ELSE
       l_url_select :=
          'SELECT  '''' OKI_SALES_GROUP_URL '||
          ' , '''' OKI_DYNAMIC_URL_2 '||
          ' , '''' OKI_DYNAMIC_URL_5 ';

    END IF;

      l_sel_clause               := l_viewby_select || l_url_select ||
          -- AK Attribute naming
          '   ,'|| p_view_by_col ||
          ' , oset20.C_TAC OKI_MEASURE_1  '||
          ' , oset20.p_TAC OKI_PMEASURE_1  '||
          ' , oset20.C_TAC_tot OKI_TMEASURE_1  '||
          ' , oset20.TAC_chg OKI_CHANGE_1  '||
          ' , oset20.TAC_chg_tot OKI_TCHANGE_1  '||
          ' , oset20.TAC_PoT OKI_PERCENT_1  '||
          ' , oset20.TAC_PoT_tot OKI_TPERCENT_1  '||
          ' ,'||OKI_DBI_UTIL_PVT.change_clause('oset20.tac_PoT','oset20.p_tac_PoT','P') || ' OKI_PERCENT_CHANGE_1 '||
          ' ,'||OKI_DBI_UTIL_PVT.change_clause('oset20.c_NB','oset20.p_NB','NP') || ' OKI_PERCENT_CHANGE_2 '||
          ' ,'||OKI_DBI_UTIL_PVT.change_clause('oset20.c_NB_tot','oset20.p_NB_tot','NP') || ' OKI_ATTRIBUTE_1'||
          ' , oset20.C_NB OKI_MEASURE_2  '||
          ' , oset20.C_NB_tot OKI_TMEASURE_2  '||
          ' , oset20.C_NB OKI_KPI_MEASURE_2  '||
          ' , oset20.p_NB OKI_PKPI_MEASURE_2  '||
          ' , oset20.c_NB_tot OKI_TKPI_MEASURE_2  '||
          ' , oset20.p_NB_tot OKI_PTKPI_MEASURE_2  '||
          ' , oset20.NB_PoT OKI_PERCENT_2  '||
          ' , oset20.NB_PoT_tot OKI_TPERCENT_2  '||
          ' , oset20.c_AE OKI_MEASURE_3 '||
          ' ,'||OKI_DBI_UTIL_PVT.change_clause('oset20.c_AR','oset20.p_AR','NP') || ' OKI_ATTRIBUTE_5 '||
          ' ,'||OKI_DBI_UTIL_PVT.change_clause('oset20.c_AR_tot','oset20.p_AR_tot','NP') || ' OKI_ATTRIBUTE_4 '||
          ' , oset20.c_AE_tot OKI_TMEASURE_3 '||
          ' , oset20.c_Upl OKI_MEASURE_4 '||
          ' , oset20.c_Upl_tot OKI_TMEASURE_4 '||
          ' , oset20.c_AR OKI_MEASURE_5 '||
          ' , oset20.c_AR_tot OKI_TMEASURE_5 '||
          ' , oset20.c_AR OKI_KPI_MEASURE_5 '||
          ' , oset20.c_AR_tot OKI_TKPI_MEASURE_5 '||
          ' , oset20.p_AR OKI_PKPI_MEASURE_5 '||
          ' , oset20.p_AR_tot OKI_PTKPI_MEASURE_5 '||
          ' , oset20.AR_PoT OKI_PERCENT_5 '||
          ' , oset20.AR_PoT_tot OKI_TPERCENT_5 '||
          '   from '||
          '   ( select '||
          -- Change Calculation
          '    '|| p_view_by_col ||
          '   , oset15.C_TAC C_TAC '||
          '   , oset15.P_TAC P_TAC '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.C_TAC','oset15.P_TAC','NP') || ' TAC_chg '||
          '   ,'||poa_dbi_util_pkg.rate_clause('oset15.c_TAC','oset15.c_TAC_tot') || 'tac_PoT '||
          '   ,'||poa_dbi_util_pkg.rate_clause('oset15.p_TAC','oset15.p_TAC_tot') || 'p_tac_PoT '||
          '   , oset15.C_TAC_tot C_TAC_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.C_TAc_tot','oset15.P_TAC_tot','NP') || ' TAC_chg_tot '||
          '   ,'||poa_dbi_util_pkg.rate_clause('oset15.c_TAC_tot','oset15.c_TAC_tot') || 'tac_PoT_tot '||
          '   , oset15.c_NB '||
          '   , oset15.p_NB '||
          '   ,'||poa_dbi_util_pkg.rate_clause('oset15.c_NB','oset15.c_TAC') || ' NB_PoT '||
          '   ,'||poa_dbi_util_pkg.rate_clause('oset15.p_NB','oset15.p_TAC') || ' p_NB_PoT '||
          '   , oset15.c_NB_tot '||
          '   ,'||poa_dbi_util_pkg.rate_clause('oset15.c_NB_tot','oset15.c_TAC_tot') || ' NB_PoT_tot '||
          ' , oset15.c_AE '||
          ' , oset15.c_Upl '||
          ' , oset15.c_AR '||
          ' , oset15.p_AE '||
          ' , oset15.p_AR '||
          '   ,'||poa_dbi_util_pkg.rate_clause('oset15.c_AR','oset15.c_TAC') || 'AR_PoT '||
          '   ,'||poa_dbi_util_pkg.rate_clause('oset15.p_AR','oset15.p_TAC') || 'p_AR_PoT '||
          ' , oset15.p_NB_tot '||
          ' , oset15.c_AE_tot '||
          ' , oset15.c_Upl_tot '||
          ' , oset15.c_AR_tot '||
          ' , oset15.p_AR_tot '||
          '   ,'||poa_dbi_util_pkg.rate_clause('oset15.c_AR_tot','oset15.c_TAC_tot') || 'AR_PoT_tot '||
          '   from  '||
          '    (select '||
               -- Calculated Measures
                p_view_by_col ||
               ' , oset10.c_NB '||
              ' , oset10.p_NB '||
               ' , oset10.c_AE '||
               ' , oset10.c_AR '||
               ' , oset10.p_AR '||
               ' , oset10.p_AE '||
               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset10.c_NB','oset10.c_AR') ||' c_TAC '||
               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset10.p_NB','oset10.p_AR') ||' p_TAC '||
               ' ,'|| OKI_DBI_UTIL_PVT.subtract_measures('oset10.c_AR','oset10.c_AE') ||' c_Upl '||
               ' , oset10.c_NB_tot '||
               ' , oset10.p_NB_tot '||
               ' , oset10.c_AE_tot '||
               ' , oset10.c_AR_tot '||
               ' , oset10.p_AR_tot '||
               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset10.c_NB_tot','oset10.c_AR_tot') ||' c_TAC_tot '||
               ' ,'|| OKI_DBI_UTIL_PVT.subtract_measures('oset10.c_AR_tot','oset10.c_AE_tot') ||' c_Upl_tot '||
               ' ,'|| OKI_DBI_UTIL_PVT.add_measures('oset10.p_NB_tot','oset10.p_AR_tot') ||' p_TAC_tot ';

IF (l_balance_logic = 'EVENTDATE') THEN
--{
	       l_sel_clause := l_sel_clause ||
	       ' from '||
               '   ( select '||
               '        oset05.'||p_view_by_col ||
               '      , nvl(oset05.c_NBsgo + oset05.c_NBgo,0) c_NB '||
               '      , nvl(oset05.c_AEsxr + oset05.c_AEglr,0) c_AE '||
               '      , nvl(oset05.c_ARsro + oset05.c_ARgls,0) c_AR '||
               '      , nvl(oset05.p_NBsgo + oset05.p_NBgo,0) p_NB'||
               '      , nvl(oset05.p_AEsxr + oset05.p_AEglr,0) p_AE '||
               '      , nvl(oset05.p_ARsro + oset05.p_ARgls,0) p_AR '||
               '      , nvl(oset05.c_NBsgo_total + oset05.c_NBgo_total,0) c_NB_tot '||
               '      , nvl(oset05.c_AEsxr_total + oset05.c_AEglr_total,0) c_AE_tot '||
               '      , nvl(oset05.c_ARsro_total + oset05.c_ARgls_total,0) c_AR_tot '||
               '      , nvl(oset05.p_NBsgo_total + oset05.p_NBgo_total,0) p_NB_tot '||
               '      , nvl(oset05.p_ARsro_total + oset05.p_ARgls_total,0) p_AR_tot ';
--}
ELSE
--{
               l_sel_clause := l_sel_clause ||
	       ' from '||
               '   ( select '||
               '        oset05.'||p_view_by_col ||
               '      , nvl(oset05.c_NBsgo,0) c_NB '||
               '      , nvl(oset05.c_AEsxr,0) c_AE '||
               '      , nvl(oset05.c_ARsro,0) c_AR '||
               '      , nvl(oset05.p_NBsgo,0) p_NB'||
               '      , nvl(oset05.p_AEsxr,0) p_AE '||
               '      , nvl(oset05.p_ARsro,0) p_AR '||
               '      , nvl(oset05.c_NBsgo_total,0) c_NB_tot '||
               '      , nvl(oset05.c_AEsxr_total,0) c_AE_tot '||
               '      , nvl(oset05.c_ARsro_total,0) c_AR_tot '||
               '      , nvl(oset05.p_NBsgo_total,0) p_NB_tot '||
               '      , nvl(oset05.p_ARsro_total,0) p_AR_tot ';
--}
END IF;

    RETURN l_sel_clause;
  END get_activations_sel_clause;

/******************************************************************
*  Procedure to return the query for Activations TREND portlet
*
******************************************************************/
       PROCEDURE get_activations_trend_sql  (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl) IS

  -- Variables associated with the parameter portlet
    l_query             VARCHAR2 (32767);
    l_view_by           VARCHAR2 (120);
    l_view_by_col            VARCHAR2 (120);
    l_as_of_date        DATE;
    l_prev_as_of_date   DATE;
    l_xtd               VARCHAR2 (10);
    l_xtd1              VARCHAR2 (10);
    l_xtd2              VARCHAR2 (10);
    l_comparison_type   VARCHAR2 (1);
    l_nested_pattern    NUMBER;
    l_dim_bmap          NUMBER;
    l_cur_suffix        VARCHAR2 (2);
    l_custom_sql        VARCHAR2 (10000);

    l_col_tbl           poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl1          poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl2          poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl          poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_mv_tbl            poa_dbi_util_pkg.poa_dbi_mv_tbl;

    l_period_code       varchar2(1);
    l_where_clause      VARCHAR2 (2000);
    l_where_clause1     VARCHAR2 (2000);
    l_where_clause2     VARCHAR2 (2000);
    l_mv                VARCHAR2 (2000);
    l_mv1               VARCHAR2 (2000);
    l_mv2               VARCHAR2 (2000);
    l_balance_logic     VARCHAR2(10);

    BEGIN

    l_comparison_type          := 'Y';
    l_join_tbl                  := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl                   := poa_dbi_util_pkg.poa_dbi_col_tbl ();
    l_col_tbl1                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();
    l_col_tbl2                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();
    l_mv_tbl                    := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

     /* Balance logic for OI */
    l_balance_logic := nvl(fnd_profile.value('OKI_BAL_IDENT'),'CONTRDATE');

 IF (l_balance_logic = 'EVENTDATE') THEN
--{
    OKI_DBI_UTIL_PVT.process_parameters (p_param               => p_param
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
                                        , p_version             => '7.0'
                                        , p_role                => NULL
                                        --, p_mv_set              => 'SRM' --NGM
                                        , p_mv_set              => 'SRM_ST_71' --Change done to support customer classication (NGM)
                                        , p_rg_where            => 'Y');
    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl1
                               , p_col_name       => 's_rg_amt_' || l_cur_suffix
                               , p_alias_name     => 'sro_amt'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XTD');

    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl1
                               , p_col_name       => 's_g_amt_' || l_cur_suffix
                               , p_alias_name     => 'sgo_amt'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XTD');

   OKI_DBI_UTIL_PVT.process_parameters (p_param               => p_param
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
                                        , p_period_type          => l_period_code
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '7.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_SG_71'
                                        , p_rg_where            => 'Y');
    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl2
                               , p_col_name       => 'gl_s_amt_' || l_cur_suffix
                               , p_alias_name     => 'gls_amt'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XTD');

    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl2
                               , p_col_name       => 'gl_r_amt_' || l_cur_suffix
                               , p_alias_name     => 'glr_amt'
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



       l_query := get_act_trend_sel_clause
        || ' from '
	||poa_dbi_template_pkg.union_all_trend_sql
		                                 (p_mv              => l_mv_tbl,
                                                  p_comparison_type => 'R',
                                                  p_filter_where    => NULL);
--}
ELSE
--{
     OKI_DBI_UTIL_PVT.process_parameters (p_param               => p_param
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
                                        ,p_period_type          => l_period_code
                                        , p_trend               => 'Y'
                                        , p_func_area           => 'OKI'
                                        , p_version             => '7.0'
                                        , p_role                => NULL
                                        --, p_mv_set              => 'SRM' --NGM
                                        , p_mv_set              => 'SRM_ST_71' --Change done to support customer classication (NGM)
                                        , p_rg_where            => 'Y');
    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl
                               , p_col_name       => 's_r_o_amt_' || l_cur_suffix
                               , p_alias_name     => 'sro_amt'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XTD');

    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl
                               , p_col_name       => 's_g_o_amt_' || l_cur_suffix
                               , p_alias_name     => 'sgo_amt'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => 'XTD');

       l_query                    :=
          get_act_trend_sel_clause
       || ' from '
       || poa_dbi_template_pkg.trend_sql (p_xtd                => l_xtd
                                        , p_comparison_type    => l_comparison_type
                                        , p_fact_name          => l_mv
                                        , p_where_clause       => l_where_clause
                                        , p_col_name           => l_col_tbl
                                        , p_use_grpid          => 'N');

--}
END IF;

    x_custom_sql               := l_query;

    OKI_DBI_UTIL_PVT.get_custom_trend_binds (l_xtd
                                           , l_comparison_type
                                           , x_custom_output);

  END get_activations_trend_sql  ;

/*************************************************************
*  Activations top SQL sel clause for TREND
************************************************************/

FUNCTION get_act_trend_sel_clause
    RETURN VARCHAR2
  IS
    l_sel_clause     VARCHAR2 (10000);
    l_balance_logic  VARCHAR2(10);

  BEGIN

   /* Balance logic for OI */
    l_balance_logic := nvl(fnd_profile.value('OKI_BAL_IDENT'),'CONTRDATE');

    --  OKI_MEASURE_1  : Total Activated Value

 IF (l_balance_logic = 'EVENTDATE') THEN
--{
        l_sel_clause               :=
        'Select  cal_NAME AS VIEWBY '||
       ' , nvl(uset.c_sro_amt,0)+nvl(uset.c_sgo_amt,0)+nvl(uset.c_glr_amt,0)+nvl(uset.c_gls_amt,0)  OKI_MEASURE_1 '||
       ' , nvl(uset.p_sro_amt,0)+nvl(uset.p_sgo_amt,0)+nvl(uset.p_glr_amt,0)+nvl(uset.p_gls_amt,0)  OKI_PMEASURE_1 '||
       ' ,'||OKI_DBI_UTIL_PVT.change_clause('(nvl(uset.c_sro_amt,0)+nvl(uset.c_sgo_amt,0)+nvl(uset.c_glr_amt,0)+
					nvl(uset.c_gls_amt,0))','(nvl(uset.p_sro_amt,0)+nvl(uset.p_sgo_amt,0)+
					nvl(uset.p_glr_amt,0)+
					nvl(uset.p_gls_amt,0))', 'NP' ) || ' OKI_CHANGE_1 ';
ELSE
--{
	l_sel_clause               :=
        'Select  cal.NAME AS VIEWBY '||
       ' , nvl(iset.c_sro_amt,0)+nvl(iset.c_sgo_amt,0)  OKI_MEASURE_1 '||
       ' , nvl(iset.p_sro_amt,0)+nvl(iset.p_sgo_amt,0)  OKI_PMEASURE_1 '||
       '   ,'||OKI_DBI_UTIL_PVT.change_clause('(nvl(iset.c_sro_amt,0)+nvl(iset.c_sgo_amt,0))','(nvl(iset.p_sro_amt,0)+nvl(iset.p_sgo_amt,0))', 'NP' ) || ' OKI_CHANGE_1 ';
--}
END IF;

/*     ' ,'|| OKI_DBI_UTIL_PVT.add_measures('iset.c_sro_amt','iset.c_sgo_amt') ||' OKI_MEASURE_1 '||
       ' ,'|| OKI_DBI_UTIL_PVT.add_measures('iset.p_sro_amt','iset.p_sgo_amt') ||' OKI_PMEASURE_1 '||
       '   ,'||OKI_DBI_UTIL_PVT.change_clause((OKI_DBI_UTIL_PVT.add_measures('iset.c_sro_amt','iset.c_sgo_amt')), (OKI_DBI_UTIL_PVT.add_measures('iset.p_sro_amt','iset.p_sgo_amt')),'NP') || ' OKI_CHANGE_1 ';                   */

    RETURN l_sel_clause;
  END get_act_trend_sel_clause;
/******************************************************************
*  Procedure to return the query for Activations DETAIL report
*
******************************************************************/
    PROCEDURE get_activations_detail_sql  (
    p_param                     IN       bis_pmv_page_parameter_tbl
  , x_custom_sql                OUT NOCOPY VARCHAR2
  , x_custom_output             OUT NOCOPY bis_query_attributes_tbl) IS
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
    --l_to_date_xed   CONSTANT VARCHAR2 (3)                     := 'XED';
    --l_to_date_xtd   CONSTANT VARCHAR2 (3)                     := 'XTD';

    l_rpt_specific_where     VARCHAR2 (1000);
    l_join_where             VARCHAR2 (1000);
    l_group_by               VARCHAR2 (1000);
    l_status_id              VARCHAR2 (100);
    l_filter_where           VARCHAR2 (100);

    l_additional_mv          VARCHAR2 (2000);

   BEGIN

    l_comparison_type          := 'Y';
    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();
    OKI_DBI_UTIL_PVT.process_parameters ( p_param               => p_param
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

-- MODIFIED IN 8.0
    l_rpt_specific_where    :=' AND fact.effective_active_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
                                AND fact.date_signed IS NOT NULL
                               ';

    l_group_by              := ' GROUP BY fact.chr_id, fact.customer_party_id, fact.resource_id,fact.date_signed';

    poa_dbi_util_pkg.add_column (p_col_tbl       => l_col_tbl
                               , p_col_name      => 'price_negotiated_' || l_cur_suffix
                               , p_alias_name    => 'act_value'
                               , p_prior_code    => poa_dbi_util_pkg.no_priors);

    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();

    OKI_DBI_UTIL_PVT.join_rpt_where (p_join_tbl     => l_join_tbl
                                    , p_func_area    => 'SRM'
                                    , p_version      => '6.0'
                                    , p_role         => NULL
                                    , p_mv_set       => 'SRM_CDTL_RPT');


    l_filter_where := ' ( ABS(OKI_MEASURE_2) <> 0 )  ';

    l_additional_mv := ' ) fact
                       , OKI_SCM_OCR_MV k
                       WHERE fact.chr_id = k.chr_id) ';

    l_status_id :=  NVL(OKI_DBI_UTIL_PVT.get_param_id(p_param,'OKI_STATUS+ACT_TYPE'),'''All''');

    if (l_status_id = '''All''' or l_status_id = '''ALL''' or l_status_id is NULL) THEN
        l_where_clause := l_where_clause ||'  ';
    elsif (l_status_id  = '''1''') THEN
        l_where_clause := l_where_clause ||' AND renewal_flag in (0,2) ';
    else
        l_where_clause := l_where_clause ||' AND renewal_flag in (1,3) ';
    end if;

    l_query                 := get_act_dtl_sel_clause (l_cur_suffix, l_period_type,l_status_id)
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
                                             , p_from_clause       => ' from '||l_mv ||' fact ');
    x_custom_sql            := l_query;

   OKI_DBI_UTIL_PVT.get_custom_status_binds (x_custom_output);

  END get_activations_detail_sql  ;

/*********************************************************************
*  Function to get top SQL for Activations detail report
*********************************************************************/

 FUNCTION get_act_dtl_sel_clause (
    p_cur_suffix                IN       VARCHAR2
   , p_period_type_code          IN       VARCHAR2
   , p_status_id in VARCHAR2)
    RETURN VARCHAR2
  IS
    l_query   VARCHAR2 (10000);
  BEGIN

        -- Generate sql query
    l_query                    :=
        '
        SELECT
           oki_attribute_1,
           cust.value oki_attribute_2,
           DECODE(fact.resource_id,-1,&UNASSIGNED,rsex.resource_name) oki_attribute_3,
	   to_char(OKI_DATE_3) OKI_DATE_3,
	   to_char(OKI_DATE_1) OKI_DATE_1,
	   to_char(OKI_DATE_2) OKI_DATE_2,
           OKI_MEASURE_1,
           OKI_TMEASURE_1,
           OKI_MEASURE_2,
           OKI_TMEASURE_2,
	   fact.chr_id OKI_ATTRIBUTE_5
      FROM (select *
       FROM (
          SELECT
             rank() over (&ORDER_BY_CLAUSE nulls last) - 1 rnk ,
             chr_id,
             customer_party_id,
             resource_id,
             oki_measure_2,
             oki_tmeasure_2,
	     oki_date_3,
             oki_date_1,
             oki_date_2,
             oki_attribute_1,
             oki_measure_1,
             oki_tmeasure_1
        FROM (SELECT fact.*
				     , k.start_date OKI_DATE_1
                     , k.end_date OKI_DATE_2
                     , k.COMPLETE_k_number oki_attribute_1
                     , k.price_nego_' ||p_cur_suffix ||' OKI_MEASURE_1
                     , SUM(k.price_nego_' ||p_cur_suffix ||') over ()  OKI_TMEASURE_1
                  FROM (SELECT *
          FROM (
              SELECT oset5.chr_id ,
                     oset5.customer_party_id ,
                     oset5.resource_id ,
                     oset5.act_value OKI_MEASURE_2,
                     oset5.act_value_total OKI_TMEASURE_2,
		 			 oset5.date_signed OKI_DATE_3
              FROM
                (SELECT
                    fact.chr_id,
                    fact.customer_party_id,
                    fact.resource_id,
					fact.date_signed
		    ';

     RETURN l_query;
  END get_act_dtl_sel_clause;

/*****************************************************************
* Function get activationed detail value based on type selected
******************************************************************/

 Function new_ren_detail( p_type                   IN VARCHAR2
                         , p_new                   IN NUMBER
                         , p_ren                   IN NUMBER ) RETURN NUMBER IS
  BEGIN
    if (p_type = 'All' or p_type = 'ALL' or p_type is NULL) THEN
        return NVL(p_new,0)+NVL(p_ren,0);
    elsif (p_type = '1') THEN
        return p_new;
    else
        return p_ren;
    end if;
 END new_ren_detail;

END OKI_DBI_NSCM_ACT_PVT;

/
