--------------------------------------------------------
--  DDL for Package Body OKI_DBI_SCM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_SCM_PKG" AS
/* $Header: OKIRKPIB.pls 115.36 2004/02/06 00:24:52 rpotnuru noship $ */


PROCEDURE GET_KPI_BALANCE_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)  IS
	l_pattern NUMBER;
	l_period_type_id NUMBER;
	l_SQLText varchar2(20000);
        l_view_by varchar2(200);
        l_as_of_date date;
        l_period_type varchar2(50);
        l_org varchar2(200);
        l_xtd varchar2(10);
        l_comparison_type varchar2(1) := 'Y';
        l_org_where varchar2(500);
        l_cur_suffix varchar2(2);
	l_period_code varchar2(1);
        l_nw_amt varchar2(20);
	l_rn_amt varchar2(20);
	l_x_amt varchar2(20);
	l_t_amt varchar2(20);
	l_bgn_k_amt varchar2(20);
	l_cur_sql  varchar2(5000);
        l_ytd_sql  varchar2(5000);
	l_itd  varchar2(5000);
	l_pitd  varchar2(5000);
        l_custom_rec BIS_QUERY_ATTRIBUTES;

BEGIN

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  OKI_DBI_UTIL_PVT.get_parameter_values(p_page_parameter_tbl, l_view_by, l_period_type, l_org, l_comparison_type, l_xtd,l_as_of_date, l_cur_suffix,l_pattern,l_period_type_id,l_period_code);

  l_nw_amt := 's_nw_amt_'|| l_cur_suffix;
  l_rn_amt := 's_rn_amt_'|| l_cur_suffix;
  l_x_amt := 'x_amt_'|| l_cur_suffix;
  l_t_amt := 't_amt_'|| l_cur_suffix;
  l_bgn_k_amt := 'bgn_k_amt_' || l_cur_suffix;

 l_org_where :=  OKI_DBI_UTIL_PVT.get_org_where('ORGANIZATION',l_org);

  -- Beginning Balance

  l_ytd_sql := '( SELECT fact.authoring_org_id org_id
             , NVL(SUM(DECODE(cal.report_date
                            ,&BIS_CURRENT_EFFECTIVE_START_DATE - 1
                            , '||l_nw_amt||' )), 0) +
                       NVL(SUM(DECODE(cal.report_date
                             , &BIS_CURRENT_EFFECTIVE_START_DATE - 1
                             , '||l_rn_amt||' )), 0) -
                       NVL(SUM(DECODE(cal.report_date
                             , &BIS_CURRENT_EFFECTIVE_START_DATE - 1
                             , '||l_x_amt||' )), 0) -
                       NVL(SUM(DECODE(cal.report_date
                             , &BIS_CURRENT_EFFECTIVE_START_DATE - 1
                             , '||l_t_amt||' )), 0) c_ytd_bal
               , NVL(SUM(DECODE(cal.report_date
                          ,&BIS_PREVIOUS_EFFECTIVE_START_DATE - 1
                          , '||l_nw_amt||' )), 0) +
                        NVL(SUM(DECODE(cal.report_date
                          , &BIS_PREVIOUS_EFFECTIVE_START_DATE - 1
                          , '||l_rn_amt||' )), 0) -
                        NVL(SUM(DECODE(cal.report_date
                          , &BIS_PREVIOUS_EFFECTIVE_START_DATE - 1
                          , '||l_x_amt||' )), 0) -
                        NVL(SUM(DECODE(cal.report_date
                          , &BIS_PREVIOUS_EFFECTIVE_START_DATE - 1
                          , '||l_t_amt||' )), 0) p_ytd_bal
             ,NULL c_xtd_bal,NULL p_xtd_bal
        FROM   oki_scm_o_2_mv fact
             , fii_time_rpt_struct_v cal
        WHERE  fact.time_id     = cal.time_id
      ' || l_org_where || '
        AND cal.report_date IN
                           (&BIS_CURRENT_EFFECTIVE_START_DATE - 1
                          ,&BIS_PREVIOUS_EFFECTIVE_START_DATE - 1
                           )
        AND bitand(cal.record_type_id,
                     decode(cal.report_date,
                           &BIS_CURRENT_EFFECTIVE_START_DATE - 1,119
			  ,&BIS_PREVIOUS_EFFECTIVE_START_DATE - 1,119
			   ) ) = cal.record_type_id
        GROUP BY fact.authoring_org_id
     UNION ALL
         SELECT fact.authoring_org_id org_id
            , NULL c_ytd_bal,NULL p_ytd_bal
             , NVL(SUM(DECODE(cal.report_date
                            , &BIS_CURRENT_ASOF_DATE
                            , '||l_nw_amt||' )), 0) +
                       NVL(SUM(DECODE(cal.report_date
                             , &BIS_CURRENT_ASOF_DATE
                             , '||l_rn_amt||' )), 0) -
                       NVL(SUM(DECODE(cal.report_date
                             , &BIS_CURRENT_ASOF_DATE
                             , '||l_x_amt||' )), 0) -
                       NVL(SUM(DECODE(cal.report_date
                             , &BIS_CURRENT_ASOF_DATE
                             , '||l_t_amt||' )), 0) c_xtd_bal
              , NVL(SUM(DECODE(cal.report_date
                             , &BIS_PREVIOUS_ASOF_DATE
                             , '||l_nw_amt||' )), 0) +
                        NVL(SUM(DECODE(cal.report_date
                              , &BIS_PREVIOUS_ASOF_DATE
                              , '||l_rn_amt||')), 0) -
                        NVL(SUM(DECODE(cal.report_date
                              , &BIS_PREVIOUS_ASOF_DATE
                              , '||l_x_amt||')), 0) -
                        NVL(SUM(DECODE(cal.report_date
                              , &BIS_PREVIOUS_ASOF_DATE
                              , '||l_t_amt||')), 0) p_xtd_bal
        FROM   oki_scm_o_2_mv fact
             , fii_time_rpt_struct_v cal
        WHERE  fact.time_id     = cal.time_id
      ' || l_org_where || '
        AND cal.report_date IN
                           ( &BIS_CURRENT_ASOF_DATE
                          , &BIS_PREVIOUS_ASOF_DATE )
        AND bitand(cal.record_type_id,
                     decode(cal.report_date
			  ,&BIS_CURRENT_ASOF_DATE,&BIS_NESTED_PATTERN
			  ,&BIS_PREVIOUS_ASOF_DATE ,&BIS_NESTED_PATTERN ) ) = cal.record_type_id
        GROUP BY fact.authoring_org_id ) ';

  l_cur_sql :=  ' ( Select org_id,
                        sum(c_ytd_bal) curr_cbal_ptd , sum(p_ytd_bal) curr_pbal_ptd
                        ,sum(c_xtd_bal) prev_cbal_ptd, sum(p_xtd_bal) prev_pbal_ptd
                    from ' || l_ytd_sql || '
                    GROUP by org_id ) cur ';

  l_itd := '(select fact.authoring_org_id org_id,
                    NVL('||l_bgn_k_amt||', 0 ) bal_itd
             FROM  oki_scm_o_1_mv fact
                 , fii_time_ent_year t
             WHERE fact.ent_year_id = t.ent_year_id
            ' || l_org_where || '
             AND &BIS_CURRENT_EFFECTIVE_START_DATE - 1 BETWEEN t.start_date
                                                   AND t.end_date

             ) itd ';

  l_pitd := '(select fact.authoring_org_id org_id,
                    NVL('||l_bgn_k_amt||', 0 ) pbal_itd
             FROM  oki_scm_o_1_mv fact
                 , fii_time_ent_year t
             WHERE fact.ENT_YEAR_ID = t.ent_year_id
           ' || l_org_where || '
             AND &BIS_PREVIOUS_EFFECTIVE_START_DATE - 1 BETWEEN t.start_date
                                                        AND t.end_date

             ) pitd ';

  l_sqltext := 'select   v.value VIEWBY
                       ,bbalance OKI_MEASURE_1
		       ,bbalance_prev    OKI_MEASURE_2
                       ,curr_balance     OKI_MEASURE_3
                       ,currbalance_prev OKI_MEASURE_4
		       , SUM(bbalance) OVER () OKI_MEASURE_5
		       , SUM(curr_balance) OVER () OKI_MEASURE_6
		       , SUM(bbalance_prev) OVER () OKI_MEASURE_7
		       , SUM(currbalance_prev) OVER () OKI_MEASURE_8
                from
		  ( select z.org_id,
			   bbalance,
			   curr_balance,
			   p_bbalance+ NVL(pbal_itd, 0) bbalance_prev,
	  		   p_currbalance+ NVL(pbal_itd, 0) currbalance_prev
 		    from
			( select itd.org_id  org_id,
			   	sum(nvl(cur.curr_cbal_ptd,0) +
                                           NVL(itd.bal_itd, 0)) bbalance,
				sum(nvl(cur.prev_cbal_ptd,0) +
				     nvl(cur.curr_cbal_ptd,0) +
                                      NVL(itd.bal_itd, 0)) curr_balance,
				sum(nvl(cur.curr_pbal_ptd,0) ) p_bbalance,
				sum(nvl(cur.prev_pbal_ptd,0) +
				    nvl(cur.curr_pbal_ptd,0)) p_currbalance
			  from
			      	'|| l_cur_sql ||', '|| l_itd ||'
			  where  itd.org_id  = cur.org_id(+)
			  group by itd.org_id
 		         UNION
		 	 select  cur.org_id org_id,
			   	  sum(nvl(cur.curr_cbal_ptd,0) +
                                       nvl(itd.bal_itd,0)) bbalance,
				  sum(nvl(cur.prev_cbal_ptd,0) +
				       nvl(cur.curr_cbal_ptd,0) +
                                        nvl(itd.bal_itd,0)) curr_balance,
				  sum(nvl(cur.curr_pbal_ptd,0) ) p_bbalance,
				  sum(nvl(cur.prev_pbal_ptd,0) +
				       nvl(cur.curr_pbal_ptd,0)) p_currbalance
			   from
			         '|| l_cur_sql ||', '|| l_itd ||'
			   where  cur.org_id  = itd.org_id(+)
			   group by cur.org_id
		        ) z , '|| l_pitd ||'
		    where z.org_id = pitd.org_id(+)
                  ) k , fii_operating_units_v v
                where k.org_id = v.id
                &ORDER_BY_CLAUSE ';


  x_custom_sql := '/* OKI_DBI_BAL_KPI */' || l_SQLText;

  l_custom_rec.attribute_name := '&SEC_ID';
  l_custom_rec.attribute_value := oki_dbi_util_pvt.get_sec_profile;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;


END GET_KPI_BALANCE_SQL ;


PROCEDURE GET_KPI_OTHERS_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)  IS
	l_pattern NUMBER;
	l_period_type_id NUMBER;
	l_sqltext varchar2(20000);
        l_view_by varchar2(200);
        l_as_of_date date;
        l_period_type varchar2(50);
        l_org varchar2(200);
        l_xtd varchar2(10);
        l_comparison_type varchar2(1) := 'Y';
        l_org_where varchar2(500);
        l_cur_suffix varchar2(2);
	l_period_code varchar2(1);
        l_nw_amt varchar2(20);
	l_rn_amt varchar2(20);
	l_x_amt varchar2(20);
	l_t_amt varchar2(20);
        l_xrgr_amt varchar2(20);
	l_xrgrn_amt varchar2(20);
	l_sorsrn_amt varchar2(20);
	l_srslrn_amt varchar2(20);
	l_srsorn_amt varchar2(20);
	l_cur_sql  varchar2(20000);
        l_custom_rec BIS_QUERY_ATTRIBUTES;

BEGIN

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  OKI_DBI_UTIL_PVT.get_parameter_values(p_page_parameter_tbl, l_view_by, l_period_type, l_org, l_comparison_type, l_xtd,l_as_of_date, l_cur_suffix,l_pattern,l_period_type_id,l_period_code);

  l_nw_amt := 's_nw_amt_'|| l_cur_suffix;
  l_rn_amt := 's_rn_amt_'|| l_cur_suffix;
  l_x_amt := 'x_amt_'|| l_cur_suffix;
  l_t_amt := 't_amt_'|| l_cur_suffix;
  l_sorsrn_amt := 's_ors_rn_amt_'|| l_cur_suffix;
  l_srslrn_amt := 's_rsl_rn_amt_'|| l_cur_suffix;
  l_srsorn_amt := 's_rso_rn_amt_' || l_cur_suffix;
  l_xrgr_amt := 'x_rgr_amt_'|| l_cur_suffix;  -- Current ren rate
  l_xrgrn_amt := 'x_rgr_amt_n_'|| l_period_code || '_' || l_cur_suffix;


  l_org_where :=  OKI_DBI_UTIL_PVT.get_org_where('ORGANIZATION',l_org);

  l_cur_sql :=
      '(SELECT fact.authoring_org_id org_id
               -- Current values
             , NVL2(SUM(DECODE(cal.report_date
                                        , &BIS_CURRENT_ASOF_DATE
                                        , '||l_x_amt||'))
                   , (NVL(SUM(DECODE(cal.report_date
                                  , &BIS_CURRENT_ASOF_DATE
                                  , '||l_xrgr_amt||')), 0) -
                         NVL(SUM(DECODE(cal.report_date
                                      , &BIS_CURRENT_ASOF_DATE
                                      , '||l_xrgrn_amt||')), 0) )
                   , NULL) curr_renewed
                   ,SUM(DECODE(cal.report_date
                                  , &BIS_CURRENT_ASOF_DATE
                                  , '||l_x_amt||')) curr_expired
                   , SUM(DECODE(cal.report_date
                                  , &BIS_CURRENT_ASOF_DATE
                                  , '||l_t_amt||')) curr_term
             , NVL2(COALESCE(SUM(DECODE(cal.report_date
                                        , &BIS_CURRENT_ASOF_DATE
                                        , '||l_nw_amt||'))
                           , SUM(DECODE(cal.report_date
                                        , &BIS_CURRENT_ASOF_DATE
                                        , '||l_srslrn_amt ||'))
			   , SUM(DECODE(cal.report_date
                                        , &BIS_CURRENT_ASOF_DATE
                                        , '||l_srsorn_amt ||'))
		     )
                    , NVL(SUM(DECODE(cal.report_date
                                  , &BIS_CURRENT_ASOF_DATE
                                  , '||l_nw_amt||')), 0) +
                         NVL(SUM(DECODE(cal.report_date
                                      , &BIS_CURRENT_ASOF_DATE
                                      , '||l_srslrn_amt||')), 0) +
                         NVL(SUM(DECODE(cal.report_date
                                      , &BIS_CURRENT_ASOF_DATE
                                      , '||l_srsorn_amt||')), 0)
                    ,  NULL
		   ) curr_active
             , NVL2(COALESCE(SUM(DECODE(cal.report_date
                                        , &BIS_CURRENT_ASOF_DATE
                                        , '||l_rn_amt||'))
                           , SUM(DECODE(cal.report_date
                                        , &BIS_CURRENT_ASOF_DATE
                                        , '||l_sorsrn_amt||')))
                   , NVL(SUM(DECODE(cal.report_date
                                  , &BIS_CURRENT_ASOF_DATE
                                  , '||l_rn_amt||')), 0) -
                         NVL(SUM(DECODE(cal.report_date
                                      , &BIS_CURRENT_ASOF_DATE
                                      , '||l_sorsrn_amt||')), 0)
                   , NULL) curr_uplft
                      -- Prior values
             , NVL2(SUM(DECODE(cal.report_date
                           , &BIS_PREVIOUS_ASOF_DATE
                                        , '||l_x_amt||'))
                   ,(NVL(SUM(DECODE(cal.report_date, &BIS_PREVIOUS_ASOF_DATE
                                  , '||l_xrgr_amt||')), 0) -
                         NVL(SUM(DECODE(cal.report_date, &BIS_PREVIOUS_ASOF_DATE
                                      , '||l_xrgrn_amt||')), 0) )
                   , NULL) prev_renewed
                   , SUM(DECODE(cal.report_date
                                  , &BIS_PREVIOUS_ASOF_DATE
                                  , '||l_x_amt||')) prev_expired
                   , SUM(DECODE(cal.report_date
                                  , &BIS_PREVIOUS_ASOF_DATE
                                  , '||l_t_amt||')) prev_term
             , NVL2(COALESCE(SUM(DECODE(cal.report_date
                           , &BIS_PREVIOUS_ASOF_DATE
                                        , '||l_nw_amt||'))
                           , SUM(DECODE(cal.report_date
                                        , &BIS_PREVIOUS_ASOF_DATE
                                        , '||l_srslrn_amt ||'))
			   , SUM(DECODE(cal.report_date
                                        , &BIS_CURRENT_ASOF_DATE
                                        , '||l_srsorn_amt ||'))
		     )
                   , NVL(SUM(DECODE(cal.report_date
                                  , &BIS_PREVIOUS_ASOF_DATE
                                  , '||l_nw_amt||')), 0) +
                         NVL(SUM(DECODE(cal.report_date
                                      , &BIS_PREVIOUS_ASOF_DATE
                                      , '||l_srslrn_amt||')), 0) +
                         NVL(SUM(DECODE(cal.report_date
                                      , &BIS_PREVIOUS_ASOF_DATE
                                      , '||l_srsorn_amt||')), 0)
                   , NULL
 		  ) prev_active
             , NVL2(COALESCE(SUM(DECODE(cal.report_date
                           , &BIS_PREVIOUS_ASOF_DATE
                                        , '||l_rn_amt||'))
                           , SUM(DECODE(cal.report_date
                                        , &BIS_PREVIOUS_ASOF_DATE
                                        , '||l_sorsrn_amt||')))
                   , NVL(SUM(DECODE(cal.report_date
                                  , &BIS_PREVIOUS_ASOF_DATE
                                  , '||l_rn_amt||')), 0) -
                         NVL(SUM(DECODE(cal.report_date
                                      , &BIS_PREVIOUS_ASOF_DATE
                                      , '||l_sorsrn_amt||')), 0)
                   , NULL) prev_uplft
        	FROM   OKI_SCM_O_2_MV fact
             , fii_time_rpt_struct_v cal
	WHERE  fact.time_id = cal.time_id
      ' || l_org_where || '
	AND cal.report_date IN
                    (&BIS_CURRENT_ASOF_DATE
                   , &BIS_PREVIOUS_ASOF_DATE )
                        AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN ) =
                   cal.record_type_id
        GROUP BY fact.authoring_org_id
       ) cur,';

   l_sqltext :=
      'select v.value VIEWBY
            , cur.curr_expired OKI_MEASURE_1 -- Expired
            , cur.prev_expired OKI_MEASURE_2
            , cur.curr_term    OKI_MEASURE_3 -- Terminated
            , cur.prev_term    OKI_MEASURE_4
            , cur.curr_active  OKI_MEASURE_5 -- Activated
            , cur.prev_active  OKI_MEASURE_6
            , cur.curr_uplft   OKI_MEASURE_7 -- Uplift
            , cur.prev_uplft   OKI_MEASURE_8
            , NULL OKI_CALC_ITEM1
            , NULL OKI_CALC_ITEM2
            , NULL OKI_MEASURE_9 , NULL OKI_MEASURE_10
            , NULL OKI_CALC_ITEM5
            , NULL OKI_CALC_ITEM6
	    , SUM(cur.curr_expired) OVER () OKI_CALC_ITEM4
	    , SUM(cur.curr_term) OVER () OKI_MEASURE_11
	    , SUM(cur.curr_active ) OVER () OKI_CALC_ITEM3
	    , SUM(cur.prev_expired) OVER () OKI_MEASURE_12
	    , SUM(cur.prev_term) OVER () OKI_MEASURE_13
	    , SUM(cur.prev_active) OVER () OKI_MEASURE_14
	    , SUM( cur.curr_uplft ) OVER () OKI_MEASURE_15
	    , SUM(cur.prev_uplft) OVER () OKI_PARAMETER_NUM_1
 	         FROM '|| l_cur_sql || '
             fii_operating_units_v v
       WHERE cur.org_id = v.id
       &ORDER_BY_CLAUSE ';

  x_custom_sql := '/* OKI_DBI_OTHERS_KPI */' || l_sqltext;

  l_custom_rec.attribute_name := '&SEC_ID';
  l_custom_rec.attribute_value := oki_dbi_util_pvt.get_sec_profile;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;


END GET_KPI_OTHERS_SQL ;

-- brrao added for Past due renewal rate new definition for dbi 5.1

PROCEDURE GET_KPI_RATES_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)  IS
	l_pattern NUMBER;
	l_period_type_id NUMBER;
	l_sqltext varchar2(32767);
        l_itd varchar2(2000);
        l_view_by varchar2(200);
        l_as_of_date date;
        l_period_type varchar2(50);
        l_org varchar2(200);
        l_xtd varchar2(10);
        l_comparison_type varchar2(1) := 'Y';
        l_org_where varchar2(500);
        l_cur_suffix varchar2(2);
	l_period_code varchar2(1);
	l_x_amt varchar2(20);
        l_B_amt varchar2(20);
	l_Brd_amt varchar2(20);
        l_xrgr_amt varchar2(20);
	l_xrgrn_amt varchar2(20);
        l_brgr_amt varchar2(20);
	l_cur_sql  varchar2(20000);
	l_ytd_sql  varchar2(20000);
        l_custom_rec BIS_QUERY_ATTRIBUTES;

BEGIN


  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  OKI_DBI_UTIL_PVT.get_parameter_values(p_page_parameter_tbl, l_view_by, l_period_type, l_org, l_comparison_type, l_xtd,l_as_of_date, l_cur_suffix,l_pattern,l_period_type_id,l_period_code);

  l_x_amt := 'x_amt_'|| l_cur_suffix;
  l_xrgr_amt := 'x_rgr_amt_'|| l_cur_suffix;  -- Current ren rate
  l_xrgrn_amt := 'x_rgr_amt_n_'|| l_period_code || '_' || l_cur_suffix;
  l_brgr_amt := 'b_rgr_amt_'|| l_cur_suffix;  -- Backlog ren rate changed to b_rgr_amt_f
  l_Brd_amt := 'B_rd_amt_'|| l_cur_suffix;
  l_B_amt := 'B_amt_'|| l_cur_suffix;

  /* DEBUG
     --OKI_DBIDEBUG_PVT.g_portal_name := 'OKI_DBI_BAL';
     OKI_DBIDEBUG_PVT.check_portal_param('OKI_DBI_BAL',p_page_parameter_tbl);
*/

  l_org_where :=  OKI_DBI_UTIL_PVT.get_org_where('ORGANIZATION',l_org);

  l_itd := '(select mv.authoring_org_id org_id
            ,SUM(DECODE (t.report_date,&BIS_CURRENT_ASOF_DATE-1,'||l_B_amt||',0)) cblog
	    ,SUM(DECODE (t.report_date,&BIS_PREVIOUS_ASOF_DATE-1,'||l_B_amt||',0)) pblog
            from Oki_scm_blg_mv mv, fii_time_day t
            WHERE mv.ent_year_id(+) = t.ent_year_id ' || l_org_where || '
            AND t.report_date in (&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1 )
            group by mv.authoring_org_id )itd ';

  l_ytd_sql := '(SELECT fact.authoring_org_id org_id
               , NVL2(SUM(DECODE(cal.report_date, &BIS_CURRENT_ASOF_DATE, '||l_x_amt||'))
                    , (NVL(SUM(DECODE(cal.report_date, &BIS_CURRENT_ASOF_DATE, '||l_xrgr_amt||')), 0) -
                      NVL(SUM(DECODE(cal.report_date, &BIS_CURRENT_ASOF_DATE, '||l_xrgrn_amt||')), 0) ),
                  NULL) curr_renewed
             , NVL2(SUM(DECODE(cal.report_date, &BIS_CURRENT_ASOF_DATE, '||l_x_amt||'))
               , NVL(SUM(DECODE(cal.report_date, &BIS_CURRENT_ASOF_DATE, '||l_x_amt||')), 0),
                 NULL) curr_expired
            , NVL(SUM(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE-1, '||l_B_amt||' )), 0) bklg_amt
            , NULL blg_rd_amt
            , SUM(DECODE(cal.report_date, &BIS_CURRENT_ASOF_DATE, '||l_brgr_amt||')) curr_blogn
           , NVL2(SUM(DECODE(cal.report_date, &BIS_PREVIOUS_ASOF_DATE, '||l_x_amt||'))
                ,(NVL(SUM(DECODE(cal.report_date, &BIS_PREVIOUS_ASOF_DATE, '||l_xrgr_amt||')), 0) -
               NVL(SUM(DECODE(cal.report_date, &BIS_PREVIOUS_ASOF_DATE, '||l_xrgrn_amt||')), 0))
             ,NULL) prev_renewed
        , NVL2(SUM(DECODE(cal.report_date, &BIS_PREVIOUS_ASOF_DATE, '||l_x_amt||'))
              , NVL(SUM(DECODE(cal.report_date, &BIS_PREVIOUS_ASOF_DATE, '||l_x_amt||')), 0)
             ,NULL) prev_expired
        , NVL(SUM(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE-1, '||l_B_amt||' )), 0) bklg_amt_p
        , NULL blg_rd_amt_p
        , SUM(DECODE(cal.report_date, &BIS_PREVIOUS_ASOF_DATE, '||l_brgr_amt||')) prev_blogn
	FROM   OKI_SCM_O_2_MV fact, fii_time_rpt_struct_v cal WHERE  fact.time_id = cal.time_id ' || l_org_where || '
          AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE ,&BIS_CURRENT_ASOF_DATE-1
                                  ,&BIS_PREVIOUS_ASOF_DATE
                                  ,&BIS_PREVIOUS_ASOF_DATE-1)
        AND bitand(cal.record_type_id, decode(cal.report_date
		                             ,&BIS_CURRENT_ASOF_DATE,&BIS_NESTED_PATTERN
		                             ,&BIS_PREVIOUS_ASOF_DATE ,&BIS_NESTED_PATTERN
					     ,&BIS_CURRENT_ASOF_DATE-1,119
			 		     ,&BIS_PREVIOUS_ASOF_DATE-1,119 )
		   ) = cal.record_type_id
        GROUP BY fact.authoring_org_id
    UNION ALL
        SELECT fact.authoring_org_id org_id,
               NULL curr_renewed,NULL curr_expired,NULL bklg_amt
              ,NVL(SUM(DECODE(cal.report_date,&BIS_CURRENT_EFFECTIVE_START_DATE - 1,  '||l_Brd_amt||')), 0) blg_rd_amt
              , NULL curr_blogn, NULL prev_renewed, NULL prev_expired, NULL bklg_amt_p
             , NVL(SUM(DECODE(cal.report_date,&BIS_PREVIOUS_EFFECTIVE_START_DATE - 1,  '||l_Brd_amt||'))
          , 0) blg_rd_amt_p, NULL  prev_blogn
	FROM   OKI_SCM_O_2_MV fact, fii_time_rpt_struct_v cal WHERE  fact.time_id = cal.time_id ' || l_org_where || '
          AND cal.report_date IN (&BIS_CURRENT_EFFECTIVE_START_DATE - 1
                                  ,&BIS_PREVIOUS_EFFECTIVE_START_DATE - 1)
        AND bitand(cal.record_type_id, decode(cal.report_date,
                                              &BIS_CURRENT_EFFECTIVE_START_DATE - 1,119
					     ,&BIS_PREVIOUS_EFFECTIVE_START_DATE - 1,119)
		   ) = cal.record_type_id
        GROUP BY fact.authoring_org_id  ) ';

  l_cur_sql := ' ( Select org_id, sum(curr_renewed) curr_renewed, sum(curr_expired) curr_expired
                  ,sum(bklg_amt) bklg_amt, sum(blg_rd_amt) blg_rd_amt, sum(curr_blogn) curr_blogn
                 ,sum(prev_renewed) prev_renewed, sum(prev_expired) prev_expired
                 ,sum(bklg_amt_p) bklg_amt_p, sum(blg_rd_amt_p) blg_rd_amt_p,sum(prev_blogn) prev_blogn
                 from '|| l_ytd_sql ||'
                 GROUP BY org_id ) cur, fii_time_day c,fii_time_day p
       where c.report_date = &BIS_CURRENT_ASOF_DATE-1 and  p.report_date = &BIS_PREVIOUS_ASOF_DATE-1 ';


  l_sqltext :=
      'select v.value VIEWBY
            , NVL2(COALESCE(cur.curr_renewed, cur.curr_expired )
	           , (NVL(cur.curr_renewed, 0) / DECODE(cur.curr_expired, 0,NULL ,cur.curr_expired)) * 100
                   , NULL) OKI_CALC_ITEM1
	    , NVL2(COALESCE(cur.prev_renewed, cur.prev_expired )
                  ,(NVL(cur.prev_renewed, 0) / DECODE(cur.prev_expired,0,NULL, cur.prev_expired)) * 100
                 , NULL) OKI_CALC_ITEM2
            , (nvl(cur.bkd_xtd,0) / Decode(cur.exp_bal,0,NULL,cur.exp_bal)) * 100  OKI_MEASURE_9
            , (nvl(cur.bkd_xtd_p,0) / Decode(cur.exp_bal_p,0,NULL,cur.exp_bal_p)) * 100  OKI_MEASURE_10
            , NVL2(COALESCE(SUM(cur.curr_renewed) OVER(), SUM(cur.curr_expired) OVER ())
		   , (SUM(NVL(cur.curr_renewed, 0)) OVER ()/
                      DECODE(SUM(cur.curr_expired) OVER (), 0, NULL, SUM(cur.curr_expired) OVER ())) * 100
                   , NULL) OKI_CALC_ITEM3
            , (SUM(NVL(cur.bkd_xtd,0)) OVER ()/
                   Decode(SUM(cur.exp_bal) OVER (),0,NULL,SUM(cur.exp_bal) OVER ())) * 100 OKI_CALC_ITEM4
           , NVL2(COALESCE(SUM(cur.prev_renewed) OVER(), SUM(cur.prev_expired) OVER ())
		   , (SUM(NVL(cur.prev_renewed, 0)) OVER ()/
                      DECODE(SUM(cur.prev_expired) OVER (), 0, NULL, SUM(cur.prev_expired) OVER ())) * 100
                   , NULL) OKI_CALC_ITEM5
            , (SUM(NVL(cur.bkd_xtd_p,0)) OVER ()/
                   Decode(SUM(cur.exp_bal_p) OVER (),0,NULL,SUM(cur.exp_bal_p) OVER ())) * 100 OKI_CALC_ITEM6
           ,cur.bkd_xtd OKI_MEASURE_1
           ,cur.bkd_xtd_p OKI_MEASURE_2
           ,cur.exp_bal OKI_MEASURE_3
	   ,cur.exp_bal_p OKI_MEASURE_4
       FROM ( SELECT itd.org_id  org_id, nvl(itd.cblog,0)+nvl(cur.bklg_amt,0)-
                            (case when  &BIS_CURRENT_EFFECTIVE_START_DATE -1 > c.ent_year_start_date
                                  then nvl(cur.blg_rd_amt,0) else 0 end ) exp_bal,
		     nvl(itd.pblog,0)+nvl(cur.bklg_amt_p,0)-
                            (case when  &BIS_PREVIOUS_EFFECTIVE_START_DATE -1 > p.ent_year_start_date
                                  then nvl(cur.blg_rd_amt_p,0) else 0 end ) exp_bal_p,
                     cur.curr_blogn bkd_xtd, cur.prev_blogn bkd_xtd_p,cur.curr_expired, cur.prev_expired
                    ,cur.curr_renewed,cur.prev_renewed
              FROM '|| l_itd || ', '|| l_cur_sql || ' and  itd.org_id  = cur.org_id(+)
             UNION
            SELECT cur.org_id  org_id, nvl(itd.cblog,0)+nvl(cur.bklg_amt,0)-
                            (case when  &BIS_CURRENT_EFFECTIVE_START_DATE -1 > c.ent_year_start_date
                                  then nvl(cur.blg_rd_amt,0) else 0 end ) exp_bal,
		     nvl(itd.pblog,0)+nvl(cur.bklg_amt_p,0)-
                            (case when  &BIS_PREVIOUS_EFFECTIVE_START_DATE -1 > p.ent_year_start_date
                                  then nvl(cur.blg_rd_amt_p,0) else 0 end ) exp_bal_p,
                   cur.curr_blogn bkd_xtd
                  ,cur.prev_blogn bkd_xtd_p,cur.curr_expired,cur.prev_expired
                   , cur.curr_renewed, cur.prev_renewed
              FROM '|| l_itd || ', '|| l_cur_sql || ' and  itd.org_id (+) = cur.org_id
          ) cur,fii_operating_units_v v  WHERE cur.org_id = v.id &ORDER_BY_CLAUSE ';

   x_custom_sql := '/* OKI_DBI_RATES_KPI */' || l_sqltext;

  l_custom_rec.attribute_name := '&SEC_ID';
  l_custom_rec.attribute_value := oki_dbi_util_pvt.get_sec_profile;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;

 /* DEBUG
     OKI_DBIDEBUG_PVT.check_portal_value('OKI_DBI_BAL','SQL',l_SQLText);
         COMMIT;
*/


END GET_KPI_RATES_SQL ;


PROCEDURE GET_CBALANCE_TREND_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)  IS
	l_pattern NUMBER;
	l_period_type_id NUMBER;
	l_SQLText varchar2(20000);
        l_view_by varchar2(200);
        l_as_of_date date;
        l_period varchar2(50);
        l_org varchar2(200);
        l_xtd varchar2(10);
        l_comparison_type varchar2(1) := 'Y';
        l_org_where varchar2(500);
        l_cur_suffix varchar2(2);
	l_period_code varchar2(1);
	l_bgn_k_amt varchar2(20);
        l_nw_amt varchar2(20);
	l_rn_amt varchar2(20);
	l_x_amt varchar2(20);
	l_t_amt varchar2(20);
       	l_xtd_sql  varchar2(5000);
	l_bbal_cur  varchar2(5000);
        l_org_where_value varchar2(5000);
	l_rep_sql  varchar2(5000);
        l_case     varchar2(3000);
        p_case     varchar2(3000);
        l_lag_id   varchar2(3000);
        l_custom_rec BIS_QUERY_ATTRIBUTES;

BEGIN

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  OKI_DBI_UTIL_PVT.get_parameter_values(p_page_parameter_tbl, l_view_by, l_period, l_org, l_comparison_type, l_xtd,l_as_of_date, l_cur_suffix,l_pattern,l_period_type_id,l_period_code);

  /* DEBUG
     OKI_DBI_DEBUG_PVT.g_portal_name := 'OKI_DBI_BAL_TRND';
     OKI_DBI_DEBUG_PVT.check_portal_param(p_page_parameter_tbl);
*/

  l_nw_amt := 's_nw_amt_'|| l_cur_suffix;
  l_rn_amt := 's_rn_amt_'|| l_cur_suffix;
  l_x_amt := 'x_amt_'|| l_cur_suffix;
  l_t_amt := 't_amt_'|| l_cur_suffix;
  l_bgn_k_amt := 'bgn_k_amt_' || l_cur_suffix;


 l_org_where :=  OKI_DBI_UTIL_PVT.get_org_where('ORGANIZATION',l_org);

/*  brrao modified -- as this is failing for the join clause with fii_time */

  l_org_where_value := l_org_where ;
  IF l_org_where_value IS NOT NULL then
    l_org_where_value :=
      replace(l_org_where_value,
              'AND ',
              'AND ( fact.authoring_org_id is null or ') || ') ' ;
  END IF ;



 if(l_comparison_type = 'Y' and l_xtd <> 'YTD') then
    l_rep_sql := ' and cal.report_date = (case when (fii.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE)
                        then least(fii.end_date, &BIS_PREVIOUS_ASOF_DATE)
                        else least(fii.end_date, &BIS_CURRENT_ASOF_DATE)
                       end )';
  else
    l_rep_sql := ' and cal.report_date in (least(fii.end_date, &BIS_CURRENT_ASOF_DATE) , &BIS_PREVIOUS_ASOF_DATE)
               and cal.report_date between fii.start_date and fii.end_date ';
  end if;

 l_case := 'CASE when (fii.start_date between &BIS_CURRENT_REPORT_START_DATE
                                          and &BIS_CURRENT_ASOF_DATE
                     and cal.report_date = least(fii.end_date,&BIS_CURRENT_ASOF_DATE))';

 p_case := ' CASE WHEN (fii.start_date between &BIS_PREVIOUS_REPORT_START_DATE
                                                and &BIS_PREVIOUS_ASOF_DATE
                      and cal.report_date = least(fii.end_date,&BIS_PREVIOUS_ASOF_DATE ))';

 l_lag_id := 'decode (&BIS_TIME_COMPARISON_TYPE, ''SEQUENTIAL'',1 ,''YEARLY'',
                        (CASE &BIS_PERIOD_TYPE WHEN ''FII_TIME_ENT_PERIOD'' THEN 12
                                               WHEN ''FII_TIME_ENT_QTR'' THEN 4
                                               WHEN ''FII_TIME_ENT_YEAR'' THEN 1
                          END))';


  /* Handles the overlapping YTD/ITD problem */

/* brrao modified ITD  org where clause to inline view for fact table */
  l_bbal_cur :=
       '(select itd.cbal + (case when (&BIS_CURRENT_REPORT_START_DATE - 1 < itd.start_date)
			    then 0
                            else nvl(ytd.cbal,0) end) curbal
		,itd.pbal + (case when (&BIS_PREVIOUS_REPORT_START_DATE -1 < itd.p_start_date)
			      then 0
                              else nvl(ytd.pbal,0) end) prevbal
	 from ( select cbal,pbal,start_date,p_start_date from
	         (select NVL(SUM( '||l_bgn_k_amt ||'), 0) cbal
		        ,NVL(lag(SUM( '||l_bgn_k_amt ||'),1) OVER (order by t.start_date),0) pbal
		        ,t.start_date
			,lag (t.start_date, 1) OVER (ORDER BY t.start_date ) p_start_date
                  from
		      (select  '||l_bgn_k_amt ||', ent_year_id, authoring_org_id
		        from oki_scm_o_1_mv
		        where 1=1  ' || l_org_where || '
		       ) fact
                       , fii_time_ent_year t
                  where fact.ent_year_id (+) = t.ent_year_id
                  and ( &BIS_CURRENT_REPORT_START_DATE BETWEEN t.start_date AND t.end_date
		       OR &BIS_PREVIOUS_REPORT_START_DATE BETWEEN t.start_date AND t.end_date)
                  group by t.start_date
	          order by t.start_date desc
	          ) where rownum = 1
               ) itd,
	    (select cbal,pbal from
              (select SUM( NVL( '||l_nw_amt||', 0) + NVL('||l_rn_amt||', 0) -
                           NVL( '||l_x_amt||' , 0) - NVL( '||l_t_amt||' , 0)) cbal
	    	     ,lag(SUM( NVL( '||l_nw_amt||', 0) + NVL('||l_rn_amt||', 0) -
                           NVL( '||l_x_amt||' , 0) - NVL( '||l_t_amt||' , 0)),1)
			 OVER (order by cal.report_date) pbal
               from
		   ( select * from oki_scm_o_2_mv
		     where 1=1  ' || l_org_where || '
		    ) fact
                    , fii_time_rpt_struct_v cal
               where  fact.time_id(+) = cal.time_id
               and cal.report_date in ( &BIS_CURRENT_REPORT_START_DATE - 1,
					&BIS_PREVIOUS_REPORT_START_DATE -1)
               and bitand(cal.record_type_id,119 ) = cal.record_type_id
		group by cal.report_date
		 ORDER BY cal.report_date DESC
	       ) where rownum=1
              ) ytd
        ) begbal,';


  l_xtd_sql :=
       '(select cur_xtd.name,cur_xtd.c_sum,cur_xtd.p_sum, f.start_date
         from (select name
                    , sum(cur_sum) over
                            (order by start_date ROWS UNBOUNDED PRECEDING) c_sum
		    , sum(pre_sum) over (order by start_date ROWS UNBOUNDED PRECEDING) p_sum
		    , start_date
               from (Select fii.name
                          , fii.start_date
                          , SUM(' || l_case ||' then (NVL(  '||l_nw_amt||', 0) +
                                                       NVL(  '||l_rn_amt||' , 0) -
                                                       NVL( '||l_x_amt||' , 0) -
                                                       NVL(  '||l_t_amt||' , 0))
						 else 0 end ) cur_sum
                          , lag (SUM(' || p_case ||' then (NVL(  '||l_nw_amt||', 0) +
                                     			   NVL(  '||l_rn_amt||' , 0) -
                                     			   NVL( '||l_x_amt||' , 0) -
                                     			   NVL(  '||l_t_amt||' , 0))
						     else 0 end ), ' || l_lag_id || ')
 		            OVER (order by fii.start_date) pre_sum
                     from ( select * from oki_scm_o_2_mv
		     where 1=1  ' || l_org_where || '
		    ) fact, '|| l_period ||' fii
                         , fii_time_rpt_struct_v cal
                     where  fii.start_date
                              between &BIS_PREVIOUS_REPORT_START_DATE
                                  and &BIS_CURRENT_ASOF_DATE
		     ' || l_rep_sql  || '
                      and bitand(cal.record_type_id,&BIS_NESTED_PATTERN ) = cal.record_type_id
                     and fact.time_id (+) = cal.time_id
                    group by fii.name,fii.start_date
	            ) cur
              ) cur_xtd ,' || l_period || ' f
                WHERE cur_xtd.start_date(+) = f.start_date
                AND   f.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
                                       AND &BIS_CURRENT_ASOF_DATE
                ORDER BY f.start_date ) XTD ' ;
--	NVL(pbalance, 0)   OKI_MEASURE_2,

   l_SQLText := 'select curr_bal.name VIEWBY,
			NVL(pbalance, 0)   OKI_MEASURE_1,' ||
                        oki_dbi_util_pvt.change_clause('cbalance','pbalance') || '  OKI_MEASURE_2,
			NVL(cbalance, 0)   OKI_MEASURE_3
 		 from
		      ( select xtd.name
                             , NVL(begbal.curbal, 0) + NVL(xtd.c_sum, 0) cbalance
			     , NVL(begbal.prevbal, 0) + NVL(xtd.p_sum, 0) pbalance
                        from  '|| l_bbal_cur || l_xtd_sql ||'
		      ) curr_bal ';

  x_custom_sql := '/* OKI_DBI_K_BALANCE_G */' || l_SQLText;

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
  l_custom_rec.attribute_value := 'TIME+'||l_period;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;


  l_custom_rec.attribute_name := '&SEC_ID';
  l_custom_rec.attribute_value := oki_dbi_util_pvt.get_sec_profile;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;

--return l_SQLText ;

END GET_CBALANCE_TREND_SQL ;


END OKI_DBI_SCM_PKG ;


/
