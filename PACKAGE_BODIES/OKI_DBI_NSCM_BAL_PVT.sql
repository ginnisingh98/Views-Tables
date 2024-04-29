--------------------------------------------------------
--  DDL for Package Body OKI_DBI_NSCM_BAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_NSCM_BAL_PVT" AS
/* $Header: OKIPNKPB.pls 120.4 2006/02/06 00:45:35 pubalasu noship $ */


  FUNCTION get_bal_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2
  , p_cur_suffix                IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_bal_trend_sel_clause (p_cur_suffix     IN       VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_bal_detail_sel_clause (
    p_cur_suffix                IN       VARCHAR2
  , p_period_type_code          IN       VARCHAR2
  , p_exp_type                  IN       VARCHAR2)
    RETURN VARCHAR2;

   FUNCTION get_bal_itd_sql (
       p_param   IN bis_pmv_page_parameter_tbl
      , p_trend_flag in VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION get_bal_ytd_sql (
       p_param   IN bis_pmv_page_parameter_tbl
      , p_trend_flag in VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION get_trend_query (
       p_itd   IN VARCHAR2
      ,p_ytd IN VARCHAR2
      , p_xtd in VARCHAR2
     ,p_cur_suffix in VARCHAR2)
   RETURN VARCHAR2;
FUNCTION get_xtd_sql ( p_param     IN       bis_pmv_page_parameter_tbl
                       ,p_ptd in VARCHAR2
                       , p_trend_flag  in VARCHAR2)
   RETURN VARCHAR2;
Function get_xtd_sel_clause (p_ptd in VARCHAR2
                             ,p_view_by_col in VARCHAR2
                             , p_trend_flag in VARCHAR2 )
RETURN VARCHAR2;
--------------------------------------------------------------------
  PROCEDURE get_balance_sql (
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
    l_ytd_sql                VARCHAR2(32767);
    l_itd_sql                VARCHAR2(32767);

   l_sql                VARCHAR2(32767);

  BEGIN

   l_comparison_type          := 'Y';
   l_join_tbl          := POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl ();


     OKI_DBI_UTIL_PVT.Process_Parameters (p_param               => p_param
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
                                        , p_mv_set              => 'SRM_ST_71'
                                        , p_rg_where            => 'Y');


   l_sql :=   get_xtd_sql (p_param,'XTD','N');
   l_ytd_sql :=   get_xtd_sql (p_param,'YTD','N');

  /* Additional filter needed to avoid displaying records queried due to total values at node */
   l_filter_where  := ' WHERE  ( ABS(oki_pmeasure_1) + ABS(oki_measure_1) + ABS(oki_pmeasure_2) + ABS(oki_measure_2) ) <> 0 ';

    -- Generate sql query
    l_query                    :=
       get_bal_sel_clause (l_view_by
                           , l_view_by_col
                           , l_cur_suffix)
       || ' from ('
       || l_sql
       ||'  UNION ALL  '  || get_bal_itd_sql(p_param ,'N')
       ||'  UNION ALL '  || l_ytd_sql
       ||'   ) oset05 GROUP BY  '|| l_view_by_col  ||
        ') oset10) oset13)  oset15) oset20 ) ' || l_filter_where || ')oset , '
       || poa_dbi_template_pkg.get_viewby_rank_clause ( p_join_tables    => l_join_tbl
                                                  , p_use_windowing     => 'Y' );

     x_custom_sql               := '/* OKI_DBI_SCM_BAL_SUM_RPT */ '||l_query;
   oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

  END get_balance_sql;
--------------------------------------------------------------------

FUNCTION get_xtd_sql ( p_param     IN       bis_pmv_page_parameter_tbl
                       ,p_ptd in VARCHAR2
                       , p_trend_flag  in VARCHAR2)
   RETURN VARCHAR2 IS

    l_view_by                VARCHAR2 (120);
    l_view_by_col            VARCHAR2 (120);
    l_as_of_date             DATE;
    l_prev_as_of_date        DATE;
    l_xtd                    VARCHAR2 (10);
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
    l_to_date_ytd            CONSTANT VARCHAR2 (3)                     := 'YTD';
    l_to_date_itd            CONSTANT VARCHAR2 (3)                     := 'ITD';
    l_sql                    VARCHAR2(32767);
    l_mv1		     VARCHAR2(100);
    l_mv2		     VARCHAR2(100);
    l_mv3		     VARCHAR2(100);
    l_mv4		     VARCHAR2(100);
    l_col_tbl1               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl2               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl3               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_col_tbl4               poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_xtd1                   VARCHAR2(10);
    l_xtd2                   VARCHAR2(10);
    l_mv_tbl                 poa_dbi_util_pkg.poa_dbi_mv_tbl;
    l_sql1                   VARCHAR2(32767);
    l_sql2                   VARCHAR2(32767);
    l_sql3                   VARCHAR2(32767);
    l_sql4                   VARCHAR2(32767);
    l_balance_logic          VARCHAR2(10);

  BEGIN

  l_comparison_type          := 'Y';
  l_join_tbl          := POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl ();
  l_col_tbl1          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_col_tbl2          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_col_tbl3          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_col_tbl4          := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl ();
  l_mv_tbl            := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

   /* Balance logic for OI */
  l_balance_logic     := nvl(fnd_profile.value('OKI_BAL_IDENT'),'CONTRDATE');

IF (l_balance_logic = 'CONTRDATE') THEN
--{
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
                                        , p_trend               => p_trend_flag
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_ST_71'
                                        , p_rg_where            => 'Y');

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 's_g_o_amt_' || l_cur_suffix
                               , p_alias_name      => 'xtd1'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => p_ptd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 's_r_o_amt_' || l_cur_suffix
                               , p_alias_name      => 'xtd11'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => p_ptd);


OKI_DBI_UTIL_PVT.Process_Parameters	 (p_param               => p_param
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
                                        , p_trend               => p_trend_flag
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_EN_71'
                                        , p_rg_where            => 'Y');


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl2
                               , p_col_name        => 'bal_k_amt_' || l_cur_suffix
                               , p_alias_name      => 'xtd2'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => p_ptd);

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
                                        , p_trend               => p_trend_flag
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_TM_71'
                                        , p_rg_where            => 'Y');

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl3
                               , p_col_name        => 'bal_k_amt_' || l_cur_suffix
                               , p_alias_name      => 'xtd3'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => p_ptd);

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

--}

ELSE

--{

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
                                        , p_trend               => p_trend_flag
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_ST_71'
                                        , p_rg_where            => 'Y');

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 's_g_amt_' || l_cur_suffix
                               , p_alias_name      => 'xtd1'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => p_ptd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl1
                               , p_col_name        => 's_rg_amt_' || l_cur_suffix
                               , p_alias_name      => 'xtd11'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => p_ptd);


OKI_DBI_UTIL_PVT.Process_Parameters	 (p_param               => p_param
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
                                        , p_trend               => p_trend_flag
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_EN_71'
                                        , p_rg_where            => 'Y');


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl2
                               , p_col_name        => 'bal_k_amt_' || l_cur_suffix
                               , p_alias_name      => 'xtd2'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => p_ptd);

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
                                        , p_trend               => p_trend_flag
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_TM_71'
                                        , p_rg_where            => 'Y');

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl3
                               , p_col_name        => 'bal_k_amt_' || l_cur_suffix
                               , p_alias_name      => 'xtd3'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => p_ptd);

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

 OKI_DBI_UTIL_PVT.Process_Parameters	 (p_param               => p_param
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
                                        , p_trend               => p_trend_flag
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_SG_71'
                                        , p_rg_where            => 'Y');

    poa_dbi_util_pkg.add_column (p_col_tbl        => l_col_tbl4
                               , p_col_name       => 'gl_s_amt_' || l_cur_suffix
                               , p_alias_name     => 'xtd4'
                               , p_grand_total    => 'N'
                               , p_to_date_type   => p_ptd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl4
                               , p_col_name        => 'gl_r_amt_' || l_cur_suffix
                               , p_alias_name      => 'xtd44'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => p_ptd);


  l_mv_tbl.extend;
  l_mv_tbl(4).mv_name := l_mv4;
  l_mv_tbl(4).mv_col := l_col_tbl4;
  l_mv_tbl(4).mv_where := l_where_clause4;
  l_mv_tbl(4).in_join_tbls := NULL;
  l_mv_tbl(4).use_grp_id := 'N';
  l_mv_tbl(4).mv_xtd := l_xtd1;

--}
END IF;

 IF (p_trend_flag = 'N') THEN
   l_sql :=  get_xtd_sel_clause (p_ptd, l_view_by_col, 'N') || '('
             ||poa_dbi_template_pkg.union_all_status_sql
			 (p_mv       => l_mv_tbl,
                           p_join_tables     => l_join_tbl,
                           p_use_windowing   => 'Y',
                           p_paren_count     => 1,
                           p_filter_where    => NULL,
                           p_generate_viewby   => 'N') || ')';

 ELSE    -- trend sql

  l_mv_tbl(1).mv_xtd := l_xtd1;
  l_mv_tbl(2).mv_xtd := l_xtd1;
  l_mv_tbl(3).mv_xtd := l_xtd1;


  IF (p_ptd = 'YTD' ) THEN
   l_sql1 := 'Select 1'
                        || oki_dbi_util_pvt.get_nested_cols(l_col_tbl1,'YTD',p_trend_flag)
                        || oki_dbi_util_pvt.get_xtd_where(l_mv1,'N','YTD','119')
                        || l_where_clause1;


   l_sql2 := 'Select 1'
                        || oki_dbi_util_pvt.get_nested_cols(l_col_tbl2,'YTD',p_trend_flag)
                        || oki_dbi_util_pvt.get_xtd_where(l_mv2,'N','YTD','119')
                        || l_where_clause2;

   l_sql3 := 'Select 1'
                        || oki_dbi_util_pvt.get_nested_cols(l_col_tbl3,'YTD',p_trend_flag)
                        || oki_dbi_util_pvt.get_xtd_where(l_mv3,'N','YTD','119')
                        || l_where_clause3;

   l_sql :=  get_xtd_sel_clause (p_ptd, l_view_by_col, 'Y') || '('
              || l_sql1
              || ') a, ( '
               || l_sql2
               || ' ) b, ( '
              || l_sql3 || ') c';

IF (l_balance_logic = 'EVENTDATE') THEN
--{
  l_sql4 := 'Select 1'
                        || oki_dbi_util_pvt.get_nested_cols(l_col_tbl4,'YTD',p_trend_flag)
                        || oki_dbi_util_pvt.get_xtd_where(l_mv4,'N','YTD','119')
                        || l_where_clause4;

   l_sql :=  get_xtd_sel_clause (p_ptd, l_view_by_col, 'Y') || '('
              || l_sql1
              || ') a, ( '
               || l_sql2
               || ' ) b, ( '
              || l_sql3
              || ') c, ('
              || l_sql4
              || ') d';
--}
END IF;

  ELSE
   l_sql :=  get_xtd_sel_clause (p_ptd, l_view_by_col, 'Y')
             || poa_dbi_template_pkg.union_all_trend_sql
			     		        (p_mv       => l_mv_tbl,
						 p_comparison_type => l_comparison_type,
                                                 p_filter_where    => NULL);

 END IF;

 END IF;  -- trend end

 return l_sql;

END get_xtd_sql;

-------------------------------------------------------
Function get_xtd_sel_clause (p_ptd in VARCHAR2
                            ,p_view_by_col in VARCHAR2
                            , p_trend_flag in VARCHAR2 )
RETURN VARCHAR2 IS
  l_sql                    VARCHAR2(5000);
  l_alias                  VARCHAR2(300);
  l_viewby                 VARCHAR2(300);
  l_balance_logic          VARCHAR2(10);

BEGIN

 /* Balance logic for OI */
    l_balance_logic := nvl(fnd_profile.value('OKI_BAL_IDENT'),'CONTRDATE');

 IF (p_trend_flag = 'N')  THEN   -- Status SQL
    l_viewby := p_view_by_col;
 ELSE   -- trend sql
    If (p_ptd = 'YTD') then
      l_viewby := ' 1 ';
    Else
      l_viewby := ' cal_name VIEWBY, cal_start_date';
    END IF;
 END IF;


IF (l_balance_logic = 'EVENTDATE') THEN
--{
   IF (p_ptd = 'YTD') THEN
   --{
    l_sql :=  'Select ' || l_viewby || ' , 0 c_xtd, 0 p_xtd
              , nvl(c_xtd1,0)+ nvl(c_xtd11,0) + nvl(c_xtd4,0)+ nvl(c_xtd44,0) - nvl(c_xtd2,0)- nvl(c_xtd3,0) c_ytd
              , nvl(p_xtd1,0)+ nvl(p_xtd11,0) + nvl(p_xtd4,0)+ nvl(p_xtd44,0)- nvl(p_xtd2,0)- nvl(p_xtd3,0) p_ytd
              , 0 c_itd, 0 p_itd from ';
   --}
   ELSE
   --{
    l_sql :=  'Select ' || l_viewby || '
              , nvl(c_xtd1,0)+ nvl(c_xtd11,0) + nvl(c_xtd4,0)+ nvl(c_xtd44,0) - nvl(c_xtd2,0)- nvl(c_xtd3,0) c_xtd
              , nvl(p_xtd1,0)+ nvl(p_xtd11,0) + nvl(p_xtd4,0)+ nvl(p_xtd44,0) - nvl(p_xtd2,0)- nvl(p_xtd3,0) p_xtd
              , 0 c_ytd, 0 p_ytd, 0 c_itd, 0 p_itd from ';
    --}
   END IF;
ELSE
--{
  IF (p_ptd = 'YTD') THEN
   --{
     l_sql :=  'Select ' || l_viewby || ' , 0 c_xtd, 0 p_xtd
              , nvl(c_xtd1,0)+ nvl(c_xtd11,0)- nvl(c_xtd2,0)- nvl(c_xtd3,0) c_ytd
              , nvl(p_xtd1,0)+ nvl(p_xtd11,0)- nvl(p_xtd2,0)- nvl(p_xtd3,0) p_ytd
              , 0 c_itd, 0 p_itd from ';
   --}
   ELSE
   --{
    l_sql :=  'Select ' || l_viewby || '
              , nvl(c_xtd1,0)+ nvl(c_xtd11,0)- nvl(c_xtd2,0)- nvl(c_xtd3,0) c_xtd
              , nvl(p_xtd1,0)+ nvl(p_xtd11,0)- nvl(p_xtd2,0)- nvl(p_xtd3,0) p_xtd
              , 0 c_ytd, 0 p_ytd, 0 c_itd, 0 p_itd from ';
    --}
   END IF;
--}
END IF;

  return l_sql;

END get_xtd_sel_clause;

-------------------------------------------------------
  /*
     Balance Summary  Select clause
  */
  FUNCTION get_bal_sel_clause (
    p_view_by_dim               IN       VARCHAR2
  , p_view_by_col               IN       VARCHAR2
  , p_cur_suffix                IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_sel_clause         VARCHAR2 (32767);

    l_Cbal_url             VARCHAR2(300);

    l_viewby_select      VARCHAR2(32767);
    l_url_select         VARCHAR2(32767);
  BEGIN

    l_viewby_select := oki_dbi_util_pvt.get_viewby_select_clause(p_view_by_dim, 'SRM', '6.0');
    -- Drill Across URL when view by is Salesrep and Product
         l_Cbal_url  := '''pFunctionName=OKI_DBI_SCM_BAL_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';

    l_viewby_select  :=  l_viewby_select ||
   ', OKI_SALES_GROUP_URL, OKI_DYNAMIC_URL_2
    ,OKI_PMEASURE_1,OKI_MEASURE_1,OKI_TMEASURE_1,OKI_CHANGE_1,OKI_TCHANGE_1
    ,OKI_KPI_MEASURE_1,OKI_PKPI_MEASURE_1,OKI_TKPI_MEASURE_1,OKI_PTKPI_MEASURE_1
    ,OKI_PERCENT_1,OKI_TPERCENT_1,OKI_PERCENT_CHANGE_1
    ,OKI_PMEASURE_2,OKI_MEASURE_2,OKI_TMEASURE_2,OKI_CHANGE_2,OKI_TCHANGE_2
    ,OKI_KPI_MEASURE_2,OKI_PKPI_MEASURE_2,OKI_TKPI_MEASURE_2,OKI_PTKPI_MEASURE_2
    ,OKI_PERCENT_2,OKI_TPERCENT_2,OKI_PERCENT_CHANGE_2
    ,OKI_CHANGE_3, OKI_TCHANGE_3
     FROM (SELECT  rank() over (&ORDER_BY_CLAUSE nulls last , '||p_view_by_col||') - 1 rnk ,'||p_view_by_col||'
    , OKI_SALES_GROUP_URL, OKI_DYNAMIC_URL_2
    ,OKI_PMEASURE_1,OKI_MEASURE_1,OKI_TMEASURE_1,OKI_CHANGE_1,OKI_TCHANGE_1
    ,OKI_KPI_MEASURE_1,OKI_PKPI_MEASURE_1,OKI_TKPI_MEASURE_1,OKI_PTKPI_MEASURE_1
    ,OKI_PERCENT_1,SUM(OKI_PERCENT_1) over() OKI_TPERCENT_1,OKI_PERCENT_CHANGE_1
    ,OKI_PMEASURE_2,OKI_MEASURE_2,OKI_TMEASURE_2,OKI_CHANGE_2,OKI_TCHANGE_2
    ,OKI_KPI_MEASURE_2,OKI_PKPI_MEASURE_2,OKI_TKPI_MEASURE_2,OKI_PTKPI_MEASURE_2
    ,OKI_PERCENT_2,SUM(OKI_PERCENT_2) over() OKI_TPERCENT_2,OKI_PERCENT_CHANGE_2
    ,OKI_CHANGE_3, OKI_TCHANGE_3
       FROM ( ';

    IF(p_view_by_dim = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
    THEN
       l_url_select :=
          'SELECT  decode(resource_id,-999,''pFunctionName=OKI_DBI_SCM_BAL_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'','''') OKI_SALES_GROUP_URL '||
          ' , decode(resource_id,-999,'''',decode(rg_id,-1,'''','||l_Cbal_url||')) OKI_DYNAMIC_URL_2 ';
    ELSIF(p_view_by_dim = 'ITEM+ENI_ITEM')
    THEN
       l_url_select :=
          'SELECT  ''''  OKI_SALES_GROUP_URL '||
          ' , '||l_cBal_url||' OKI_DYNAMIC_URL_2 ';
    ELSE
       l_url_select :=
          'SELECT  '''' OKI_SALES_GROUP_URL '||
          ' , '''' OKI_DYNAMIC_URL_2 ';
    END IF;


--cur   current balance
-- p_cur
-- p_cur_tot
-- c_cur
-- c_cur_tot
--beg   Beginning balance
-- p_beg
-- p_beg_tot
-- c_beg
-- c_beg_tot

      l_sel_clause               := l_viewby_select || l_url_select ||
          '   ,'|| p_view_by_col ||
          ' , oset20.p_beg   OKI_PMEASURE_1, oset20.c_beg  OKI_MEASURE_1 '||
          ' , oset20.c_beg_tot OKI_TMEASURE_1, oset20.beg_chg OKI_CHANGE_1 '||
          ' , oset20.beg_chg_tot  OKI_TCHANGE_1, oset20.c_beg   OKI_KPI_MEASURE_1 '||
          ' , oset20.p_beg   OKI_PKPI_MEASURE_1, oset20.c_beg_tot  OKI_TKPI_MEASURE_1 '||
          ' , oset20.p_beg_tot  OKI_PTKPI_MEASURE_1, oset20.c_beg_per  OKI_PERCENT_1 '||
          ' , oset20.beg_per_chg  OKI_PERCENT_CHANGE_1, oset20.p_cur   OKI_PMEASURE_2 '||
          ' , oset20.c_cur  OKI_MEASURE_2, oset20.c_cur_tot  OKI_TMEASURE_2 '||
          ' , oset20.cur_chg    OKI_CHANGE_2, oset20.cur_chg_tot OKI_TCHANGE_2 '||
          ' , oset20.c_cur  OKI_KPI_MEASURE_2, oset20.p_cur   OKI_PKPI_MEASURE_2 '||
          ' , oset20.c_cur_tot  OKI_TKPI_MEASURE_2, oset20.p_cur_tot  OKI_PTKPI_MEASURE_2 '||
          ' , oset20.c_cur_per   OKI_PERCENT_2, oset20.cur_per_chg   OKI_PERCENT_CHANGE_2 '||
          ' , oset20.ptd_chg     OKI_CHANGE_3, oset20.ptd_chg_tot  OKI_TCHANGE_3 '||
          '   from  ( select  '|| p_view_by_col ||', oset15.c_cur c_cur '||
          '   , oset15.p_cur p_cur, oset15.c_cur_tot c_cur_tot '||
          '   , oset15.p_cur_tot p_cur_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_cur','oset15.p_cur','NP') || ' cur_chg '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_cur_tot','oset15.p_cur_tot','NP') || ' cur_chg_tot '||
          '   , oset15.c_cur_per, oset15.p_cur_per '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_cur_per','oset15.p_cur_per','P') || ' cur_per_chg '||
          '   , oset15.c_beg c_beg, oset15.p_beg p_beg, oset15.c_beg_tot c_beg_tot '||
          '   , oset15.p_beg_tot p_beg_tot '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_beg','oset15.p_beg','NP') || ' beg_chg '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_beg_tot','oset15.p_beg_tot','NP') || ' beg_chg_tot '||
          '   , oset15.c_beg_per, oset15.p_beg_per '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_beg_per','oset15.p_beg_per','P') || ' beg_per_chg '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_cur','oset15.c_beg','NP') || ' ptd_chg '||
          '   ,'||OKI_DBI_UTIL_PVT.change_clause('oset15.c_cur_tot','oset15.c_beg_tot','NP') || ' ptd_chg_tot '||
          '   from  (select '||  p_view_by_col ||', oset13.c_cur , oset13.c_cur_tot '||
               ' , oset13.p_cur , oset13.p_cur_tot '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.c_cur','oset13.c_cur_tot') || ' c_cur_per '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.p_cur','oset13.p_cur_tot') || ' p_cur_per '||
               ' , oset13.c_beg , oset13.c_beg_tot, oset13.p_beg , oset13.p_beg_tot '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.c_beg','oset13.c_beg_tot') || ' c_beg_per '||
               ' ,'||POA_DBI_UTIL_PKG.rate_clause('oset13.p_beg','oset13.p_beg_tot') || ' p_beg_per '||
          '   from  (select '|| p_view_by_col ||
               ' , (oset10.c_itd + oset10.c_ytd)  c_cur '||
               ' , (oset10.c_itd_tot + oset10.c_ytd_tot)  c_cur_tot '||
               ' , (oset10.p_itd + oset10.p_ytd)  p_cur '||
               ' , (oset10.p_itd_tot + oset10.p_ytd_tot)  p_cur_tot '||
               ' , (oset10.c_itd + oset10.c_ytd - oset10.c_xtd) c_beg '||
               ' , (oset10.c_itd_tot + oset10.c_ytd_tot - oset10.c_xtd_tot) c_beg_tot '||
               ' , (oset10.p_itd + oset10.p_ytd - oset10.p_xtd) p_beg '||
               ' , (oset10.p_itd_tot + oset10.p_ytd_tot - oset10.p_xtd_tot) p_beg_tot '||
               ' from ( select  oset05.'||p_view_by_col ||
               ' , SUM(NVL(oset05.c_ytd,0)) c_ytd '||
               ' , SUM(NVL(oset05.p_ytd,0)) p_ytd '||
               ' , SUM(SUM(NVL(oset05.c_ytd,0))) over ()  c_ytd_tot '||
               ' , SUM(SUM(NVL(oset05.p_ytd,0))) over ()  p_ytd_tot '||
               ' , SUM(NVL(oset05.c_xtd,0)) c_xtd '||
               ' , SUM(NVL(oset05.p_xtd,0)) p_xtd '||
               ' , SUM(SUM(NVL(oset05.c_xtd,0))) over ()  c_xtd_tot '||
               ' , SUM(SUM(NVL(oset05.p_xtd,0))) over ()  p_xtd_tot '||
               ' , SUM(NVL(oset05.c_itd,0)) c_itd '||
               ' , SUM(SUM(NVL(oset05.c_itd,0))) over ()  c_itd_tot '||
               ' , SUM(NVL(oset05.p_itd,0)) p_itd '||
               ' , SUM(SUM(NVL(oset05.p_itd,0))) over ()  p_itd_tot ';

    RETURN l_sel_clause;
  END get_bal_sel_clause;

   FUNCTION get_bal_itd_sql (
       p_param   IN bis_pmv_page_parameter_tbl
    , p_trend_flag  in VARCHAR2)
   RETURN VARCHAR2 IS
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


    l_sql                    VARCHAR2(32767);

  BEGIN

    l_comparison_type          := 'Y';
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
                                        , p_trend               => p_trend_flag
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM_BAL'
                                        , p_rg_where            => 'Y');

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'NULL'
                               , p_alias_name      => 'xtd'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => l_to_date_xtd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'bal_amt_' || l_cur_suffix
                               , p_alias_name      => 'itd'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => l_to_date_itd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'NULL'
                               , p_alias_name      => 'ytd'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => l_to_date_ytd);

    if (p_trend_flag = 'Y') then
        l_sql := 'Select 1'
                        || oki_dbi_util_pvt.get_nested_cols(l_col_tbl,'ITD',p_trend_flag)
                        || oki_dbi_util_pvt.get_itd_where(l_mv,p_trend_flag)
                        || l_where_clause;
     else
     l_sql := 'Select ' || l_view_by_col
                        || oki_dbi_util_pvt.get_nested_cols(l_col_tbl,'ITD',p_trend_flag)
                        || oki_dbi_util_pvt.get_itd_where(l_mv,p_trend_flag)
                        || l_where_clause
                        || ' GROUP BY ' || l_view_by_col;
     END IF;

     RETURN l_sql;

  END get_bal_itd_sql;


   FUNCTION Get_bal_ytd_sql (
       p_param   IN bis_pmv_page_parameter_tbl
    , p_trend_flag  in VARCHAR2)
   RETURN VARCHAR2 IS
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


    l_sql                    VARCHAR2(32767);

  BEGIN

    l_comparison_type          := 'Y';
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
                                        , p_trend               => p_trend_flag
                                        , p_func_area           => 'OKI'
                                        , p_version             => '6.0'
                                        , p_role                => NULL
                                        , p_mv_set              => 'SRM'
                                        , p_rg_where            => 'Y');


    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'NULL'
                               , p_alias_name      => 'xtd'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => l_to_date_xtd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'NULL'
                               , p_alias_name      => 'itd'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => l_to_date_itd);

    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'bal_k_amt_' || l_cur_suffix
                               , p_alias_name      => 'ytd'
                               , p_grand_total     => 'N'
                               , p_to_date_type    => l_to_date_ytd);

    if (p_trend_flag = 'Y') then
     -- NOte: Currently chnaged implementation to use same dates for trend and status.
     --       hence get_xtd_where trend flag = N for both cases.
        l_sql := 'Select 1'
                        || oki_dbi_util_pvt.get_nested_cols(l_col_tbl,'YTD',p_trend_flag)
                        || oki_dbi_util_pvt.get_xtd_where(l_mv,'N','YTD','119')
                        || l_where_clause;
     else
     l_sql := 'Select ' || l_view_by_col
                        || oki_dbi_util_pvt.get_nested_cols(l_col_tbl,'YTD',p_trend_flag)
                        || oki_dbi_util_pvt.get_xtd_where(l_mv,'N','YTD','119')
                        || l_where_clause
                        || ' GROUP BY ' || l_view_by_col;
     END IF;


     RETURN l_sql;

  END get_bal_ytd_sql;


/******************************************************************************
* Procedure to return the query for Ending Balance TRend graph
*  get_balance_trend_sql
-- brrao added
*******************************************************************************/

   PROCEDURE get_balance_trend_sql  (
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
    l_comparison_type   VARCHAR2 (1);
    l_period_type            VARCHAR2(10);
    l_nested_pattern    NUMBER;
    l_dim_bmap          NUMBER;
    l_cur_suffix        VARCHAR2 (2);
    l_custom_sql        VARCHAR2 (10000);

    l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_to_date_xed   CONSTANT VARCHAR2 (3)                     := 'XED';
    l_to_date_xtd   CONSTANT VARCHAR2 (3)                     := 'XTD';
    l_to_date_ytd   CONSTANT VARCHAR2 (3)                     := 'YTD';
    l_to_date_itd   CONSTANT VARCHAR2 (3)                     := 'ITD';

    l_period_code varchar2(1);
    l_where_clause           VARCHAR2 (2000);
    l_mv                     VARCHAR2 (2000);

    l_ytd_sql                VARCHAR2(32767);
    l_itd_sql                VARCHAR2(10000);
    l_xtd_sql                VARCHAR2(32767);

    BEGIN

    l_comparison_type          := 'Y';
    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();

     OKI_DBI_UTIL_PVT.Process_Parameters (p_param               => p_param
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
                                        , p_mv_set              => 'SRM_ST_71'
                                        , p_rg_where            => 'Y');

   l_itd_sql :=  get_bal_itd_sql(p_param,'Y');
   l_xtd_sql :=    get_bal_trend_sel_clause(l_cur_suffix)  || ' from ( ' ||get_xtd_sql (p_param,'XTD','Y');
   l_ytd_sql :=   get_xtd_sql (p_param,'YTD','Y');

    l_query := get_trend_query(l_itd_sql,l_ytd_sql,l_xtd_sql,l_cur_suffix);


  /*
       l_itd_sql :=  get_bal_itd_sql(p_param,'Y');

       l_ytd_sql := get_bal_ytd_sql(p_param ,'Y');

      l_xtd_sql :=  get_bal_trend_sel_clause(l_cur_suffix)
       || ' from '
       || poa_dbi_template_pkg.trend_sql (p_xtd                => l_xtd
                                        , p_comparison_type    => l_comparison_type
                                        , p_fact_name          => l_mv
                                        , p_where_clause       => l_where_clause
                                        , p_col_name           => l_col_tbl
                                        , p_use_grpid          => 'R');

    l_query := get_trend_query(l_itd_sql,l_ytd_sql,l_xtd_sql,l_cur_suffix);
*/
     x_custom_sql               := '/* OKI_DBI_SCM_BAL_GPH_RPT */ '||l_query;
    oki_dbi_util_pvt.get_custom_trend_binds (l_xtd
                                           , l_comparison_type
                                           , x_custom_output);

  END get_balance_trend_sql  ;

/*************************************************************/



/*************************************************************
*  Current Balance top SQL sel clause for TREND
************************************************************/

FUNCTION get_bal_trend_sel_clause (p_cur_suffix     IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_sel_clause   VARCHAR2 (10000);
  BEGIN

    l_sel_clause               := '  Select  viewby, cal_start_date, c_ytd,p_ytd,
	    lead(c_xtd,1) over(order by cal_start_date) c_xtd,
	    lead(p_xtd,1) over(order by cal_start_date) p_xtd
	  	  from ( Select   VIEWBY '||
        ' ,cal_start_date , c_ytd  '||
        ' ,p_ytd '||
        ' ,SUM(c_xtd) OVER( ORDER BY cal_start_date DESC ROWS UNBOUNDED PRECEDING)  c_xtd '||
        ' ,SUM(p_xtd) OVER( ORDER BY cal_start_date DESC ROWS UNBOUNDED PRECEDING)  p_xtd ';

    RETURN l_sel_clause;
  END get_bal_trend_sel_clause;


/*****************************************************
* Function to get the ITD Trend SQL
******************************************************/

 FUNCTION get_trend_query (
       p_itd IN VARCHAR2
      ,p_ytd IN VARCHAR2
      ,p_xtd IN VARCHAR2
      ,p_cur_suffix IN VARCHAR2)

 RETURN VARCHAR2 IS
     l_sql         VARCHAR2(32767);

  BEGIN

       l_sql := 'Select VIEWBY, '||
	         ' curr_bal OKI_MEASURE_1, '||
                 ' p_curr_bal OKI_PMEASURE_1' ||
                 '  ,'||OKI_DBI_UTIL_PVT.change_clause('curr_bal','p_curr_bal','NP') || ' OKI_CHANGE_1 '||
                ' FROM ( ' ||
                'Select  cal_start_date, VIEWBY, '||
                ' nvl(bal.c_bal,0) - nvl(xtd.c_xtd,0)  curr_bal '||
                ' ,nvl(bal.p_bal,0) - nvl(xtd.p_xtd,0)  p_curr_bal '||
                ' FROM ( '||
                ' Select ' || OKI_DBI_UTIL_PVT.add_measures('itd.c_itd','ytd.c_ytd') ||' c_bal '||
                  ' ,'|| OKI_DBI_UTIL_PVT.add_measures('itd.p_itd','ytd.p_ytd') ||' p_bal '||
                      ' FROM ( '|| p_itd ||') itd, ( '|| p_ytd || ') ytd ) bal , ('|| p_xtd || '))) xtd' ||
                 ' )  ' ;
  -- ORDER BY cal_start_date

  return l_sql;

 END get_trend_query;


  /*
     Balance Detail Select clause
  */

  PROCEDURE get_balance_detail_sql (
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
    l_to_date_xed   CONSTANT VARCHAR2 (3)                     := 'XED';
    l_to_date_xtd   CONSTANT VARCHAR2 (3)                     := 'XTD';

    l_rpt_specific_where     VARCHAR2 (1000);
    l_join_where             VARCHAR2 (1000);
    l_group_by               VARCHAR2 (1000);
    l_exp_type               VARCHAR2 (100);

    l_filter_where           VARCHAR2 (240);
    l_additional_where       VARCHAR2 (2000);
    l_additional_mv          VARCHAR2 (1000);
    l_columns   VARCHAR (5000);

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


  -- modified for OKI 8.0
    l_rpt_specific_where    :=
      ' AND  fact.effective_start_date <=  &BIS_CURRENT_ASOF_DATE
        AND  fact.date_signed is not null
        AND  fact.effective_end_date >  &BIS_CURRENT_ASOF_DATE';

  l_group_by     := '   GROUP BY fact.chr_id, fact.customer_party_id, fact.resource_id,fact.date_signed';

   poa_dbi_util_pkg.add_column (p_col_tbl       => l_col_tbl
                              , p_col_name      => 'price_negotiated_' || l_cur_suffix
                               , p_alias_name    => 'Bal'
                               , p_prior_code    => poa_dbi_util_pkg.no_priors);

    l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();

    OKI_DBI_UTIL_PVT.join_rpt_where (p_join_tbl     => l_join_tbl
                                    , p_func_area    => 'SRM'
                                    , p_version      => '6.0'
                                    , p_role         => NULL
                                    , p_mv_set       => 'SRM_CDTL_RPT');


   /* Additional filter needed to avoid displaying records queried due to total values at node */
   l_filter_where  := ' ( ABS(oki_measure_2) ) <> 0 ';
   l_additional_mv := ' ) fact
                       , OKI_SCM_OCR_MV k
                       WHERE fact.chr_id = k.chr_id) ';

  l_query                 := get_bal_detail_sel_clause(l_cur_suffix, l_period_type, '1')
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
                                             , p_from_clause       => 'from '||l_mv ||' fact ');


    x_custom_sql               := '/* OKI_DBI_SCM_BAL_DTL_RPT */'||l_query;
   oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

END get_balance_detail_sql;

  FUNCTION get_bal_detail_sel_clause (
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
           OKI_ATTRIBUTE_1,
           cust.value     OKI_ATTRIBUTE_2,
           DECODE(fact.resource_id,-1,&UNASSIGNED,rsex.resource_name) oki_attribute_3,
           OKI_DATE_3,
           OKI_DATE_1,
	   OKI_DATE_2,
           OKI_MEASURE_1,
           OKI_TMEASURE_1,
           OKI_MEASURE_2,
           OKI_TMEASURE_2,
	   fact.chr_id OKI_ATTRIBUTE_5
     FROM(
       SELECT *
       FROM (
          SELECT
             rank() over (&ORDER_BY_CLAUSE nulls last) - 1 rnk ,
             customer_party_id,
             resource_id,
             oki_measure_2,
             oki_tmeasure_2,
	     oki_date_3,
	     oki_date_1,
             oki_date_2,
             oki_attribute_1,
             oki_measure_1,
             oki_tmeasure_1,
	     chr_id
         FROM (SELECT fact.*
		     , to_char(k.start_date) OKI_DATE_1
                     , to_char(k.end_date) OKI_DATE_2
                     , k.COMPLETE_k_number oki_attribute_1
                     , k.price_nego_' ||p_cur_suffix ||' OKI_MEASURE_1
                     , SUM(k.price_nego_' ||p_cur_suffix ||') over ()  OKI_TMEASURE_1
                  FROM (SELECT *
          FROM (
              SELECT oset5.chr_id    ,
                     oset5.customer_party_id  ,
                     oset5.resource_id   ,
                     nvl(oset5.Bal,0) OKI_MEASURE_2,
                     SUM(nvl(oset5.Bal,0)) over ()  OKI_TMEASURE_2,
				  	 to_char(oset5.date_signed) OKI_DATE_3
              FROM
                (SELECT
                    fact.chr_id,
                    fact.customer_party_id,
                    fact.resource_id,
					fact.date_signed
		    ';
     RETURN l_query;
  END get_bal_detail_sel_clause;

END OKI_DBI_NSCM_BAL_PVT;

/
