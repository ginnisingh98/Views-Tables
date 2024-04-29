--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AI_TELDTL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AI_TELDTL_RPT_PKG" AS
/*$Header: bixitelr.plb 120.0 2005/05/25 17:22:49 appldev noship $ */
FUNCTION GET_ZERONULL_CLAUSE RETURN VARCHAR2
IS
l_having_clause VARCHAR2(1500);
BEGIN
l_having_clause:=') rset where
				 (
				  abs(nvl(BIX_PMV_AI_SL_CP,0)) +abs(nvl(BIX_PMV_AI_SL_CG,0))+abs(nvl(BIX_PMV_AI_SL_PP,0))
				+ abs(nvl(BIX_PMV_AI_SPANS_CP,0)) +abs(nvl(BIX_PMV_AI_SPANS_CG,0))+abs(nvl(BIX_PMV_AI_SPANS_PP,0))
				+ abs(nvl(BIX_PMV_AI_ABANRATE_CP,0)) +abs(nvl(BIX_PMV_AI_ABANRATE_CG,0))+abs(nvl(BIX_PMV_AI_ABANRATE_PP,0))
				+ abs(nvl(BIX_PMV_AI_TRANRATE_CP,0)) +abs(nvl(BIX_PMV_AI_TRANRATE_CG,0))
				+ abs(nvl(BIX_PMV_AI_INCALLHAND_CP,0)) + abs(nvl(BIX_PMV_AI_INCALLHAND_CG,0))+ abs(nvl(BIX_PMV_AI_INCALLHAND_PP,0))
				+ abs(nvl(BIX_PMV_AI_AVGTALK_CP,0)) +abs(nvl(BIX_PMV_AI_AVGTALK_CG,0)) +abs(nvl(BIX_PMV_AI_AVGTALK_PP,0))
 			    + abs(nvl(BIX_PMV_AI_AVGWRAP_CP,0)) +abs(nvl(BIX_PMV_AI_AVGWRAP_CG,0))
				+ abs(nvl(BIX_PMV_AI_SRCR_CP,0))+abs(nvl(BIX_PMV_AI_SRCR_CG,0))
				+ abs(nvl(BIX_PMV_AI_LECR_CP,0)) + abs(nvl(BIX_PMV_AI_LECR_CG,0))
				+ abs(nvl(BIX_PMV_AI_OPCR_CP,0)) +abs(nvl(BIX_PMV_AI_OPCR_CG,0))
				+ abs(nvl(BIX_PMV_AI_WEBCALL_CG,0)) +abs(nvl(BIX_PMV_AI_WEBCALL_CP,0))
				) <> 0';
return l_having_clause;
EXCEPTION
WHEN OTHERS THEN
RAISE;
END GET_ZERONULL_CLAUSE;


FUNCTION GET_MEASURES(l_view_by_select VARCHAR2) RETURN VARCHAR2
IS
l_measure_txt VARCHAR2(32000);
l_goal NUMBER;
BEGIN
IF (FND_PROFILE.DEFINED('BIX_CALL_SLGOAL_PERCENT')) THEN
   BEGIN
   l_goal := TO_NUMBER(FND_PROFILE.VALUE('BIX_CALL_SLGOAL_PERCENT'));
   EXCEPTION
   WHEN OTHERS THEN
    l_goal := 0;
   END;
ELSE
   l_goal := 0;
END IF;

l_measure_txt:=
l_view_by_select
||','||l_goal||' BIX_PMV_AI_SLGOAL,'
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					 p_curr=>'to_number(NVL(c_g,0))'
					,p_prev=>'NVL(p_g,0)'
					,p_measurecol=>'BIX_PMV_AI_INCALLHAND_CP'
					,p_totalcol=>'BIX_PMV_TOTAL9'
					,p_changecol=>'BIX_PMV_AI_INCALLHAND_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL10'
					)
/* Abandoned Calls */
||',' || bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_e,0)'
					,p_prev=>'NVL(p_e,0)'
					,p_measurecol=>'BIX_ATTRIBUTE_7'
					,p_totalcol=>'BIX_PMV_TOTAL21'
					,p_changecol=>'BIX_ATTRIBUTE_9'
					,p_changetotalcol=>'BIX_PMV_TOTAL22'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_l,0)'
					,p_prev=>'NVL(p_l,0)'
					,p_measurecol=>'BIX_PMV_AI_SRCR_CP'
					,p_totalcol=>'BIX_PMV_TOTAL17'
					,p_changecol=>'BIX_PMV_AI_SRCR_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL18'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_m,0)'
					,p_prev=>'NVL(p_m,0)'
					,p_measurecol=>'BIX_PMV_AI_LECR_CP'
					,p_totalcol=>'BIX_PMV_TOTAL19'
					,p_changecol=>'BIX_PMV_AI_LECR_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL20'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_n,0)'
					,p_prev=>'NVL(p_n,0)'
					,p_measurecol=>'BIX_PMV_AI_OPCR_CP'
					,p_totalcol=>'BIX_PMV_TOTAL23'
					,p_changecol=>'BIX_PMV_AI_OPCR_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL24'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_h,0)'
					,p_prev=>'NVL(p_h,0)'
					,p_measurecol=>'BIX_PMV_AI_WEBCALL_CP'
					,p_totalcol=>'BIX_PMV_TOTAL11'
					,p_changecol=>'BIX_PMV_AI_WEBCALL_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL12'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(c_a, 0)'
					,p_denom=>'NVL(c_d,0)'
					,p_pnum=>'NVL(p_a, 0)'
					,p_pdenom=>'NVL(p_d,0)'
					,p_measurecol=>'BIX_PMV_AI_SL_CP'
					,p_totalcol=>'BIX_PMV_TOTAL1'
					,p_changecol=>'BIX_PMV_AI_SL_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL2'
					)
||','
/* For KPI -Inbound Service Level -Current Value - got from BIX_PMV_AI_SL_CP*/
/* For KPI -Inbound Service Level -Prior Value*/
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(p_a, 0)'
					,p_denom=>'NVL(p_d,0)'
					,p_measurecol=>'BIX_CALC_ITEM3'
					,p_totalcol=>'BIX_CALC_ITEM4'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_c, 0)'
					,p_denom=>'NVL(c_g,0)'
					,p_pnum=>'NVL(p_c, 0)'
					,p_pdenom=>'NVL(p_g,0)'
					,p_measurecol=>'BIX_PMV_AI_SPANS_CP'
					,p_totalcol=>'BIX_PMV_TOTAL3'
					,p_changecol=>'BIX_PMV_AI_SPANS_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL4'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(c_e, 0)'
					,p_denom=>'NVL(c_d,0)'
					,p_pnum=>'NVL(p_e, 0)'
					,p_pdenom=>'NVL(p_d,0)'
					,p_measurecol=>'BIX_PMV_AI_ABANRATE_CP'
					,p_totalcol=>'BIX_PMV_TOTAL5'
					,p_changecol=>'BIX_PMV_AI_ABANRATE_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL6'
					)
||','
/* For KPI-Abandon rate Current period - got from BIX_PMV_AI_ABANRATE_CP*/
/* For KPI-Abandon rate Prior period */
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(p_e, 0)'
					,p_denom=>'NVL(p_d,0)'
					,p_measurecol=>'BIX_CALC_ITEM11'
					,p_totalcol=>'BIX_CALC_ITEM12'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(c_f, 0)'
					,p_denom=>'NVL(c_g,0)'
					,p_pnum=>'NVL(p_f, 0)'
					,p_pdenom=>'NVL(p_g,0)'
					,p_measurecol=>'BIX_PMV_AI_TRANRATE_CP'
					,p_totalcol=>'BIX_PMV_TOTAL7'
					,p_changecol=>'BIX_PMV_AI_TRANRATE_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL8'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_k, 0)'
					,p_denom=>'NVL(c_i,0)'
					,p_pnum=>'NVL(p_k, 0)'
					,p_pdenom=>'NVL(p_i,0)'
					,p_measurecol=>'BIX_PMV_AI_AVGTALK_CP'
					,p_totalcol=>'BIX_PMV_TOTAL13'
					,p_changecol=>'BIX_PMV_AI_AVGTALK_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL14'
					)
||','

/* For KPI- Average Talk Current got from BIX_PMV_AI_AVGTALK_CP*/
/* For KPI- Average Talk Prior*/
/*||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(p_k, 0)'
					,p_denom=>'NVL(p_i,0)'
					,p_measurecol=>'BIX_CALC_ITEM23'
					,p_totalcol=>'BIX_CALC_ITEM24'
					)
||','
*/
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_j, 0)'
					,p_denom=>'NVL(c_i,0)'
					,p_pnum=>'NVL(p_j, 0)'
					,p_pdenom=>'NVL(p_i,0)'
					,p_measurecol=>'BIX_PMV_AI_AVGWRAP_CP'
					,p_totalcol=>'BIX_PMV_TOTAL15'
					,p_changecol=>'BIX_PMV_AI_AVGWRAP_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL16'
					)
||','
/* For KPI- Average Wrap Current - got from BIX_PMV_AI_AVGWRAP_CP */
/* For KPI- Average Wrap Prior */
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(p_j, 0)'
					,p_denom=>'NVL(p_i,0)'
					,p_measurecol=>'BIX_CALC_ITEM27'
					,p_totalcol=>'BIX_CALC_ITEM28'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(p_a, 0)'
					,p_denom=>'NVL(p_d,0)'
					,p_measurecol=>'BIX_PMV_AI_SL_PP'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(p_c, 0)'
					,p_denom=>'NVL(p_g,0)'
					,p_measurecol=>'BIX_PMV_AI_SPANS_PP'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(p_e, 0)'
					,p_denom=>'NVL(p_d,0)'
					,p_measurecol=>'BIX_PMV_AI_ABANRATE_PP'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(p_k, 0)'
					,p_denom=>'NVL(p_i,0)'
					,p_measurecol=>'BIX_PMV_AI_AVGTALK_PP'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					 p_curr=>'NVL(p_g, 0)'
					,p_measurecol=>'BIX_PMV_AI_INCALLHAND_PP'
					)
||' FROM((';
	RETURN l_measure_txt;
EXCEPTION
 WHEN OTHERS THEN
  RAISE;
END GET_MEASURES;


PROCEDURE GET_SQL(p_page_parameter_tbl IN         BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                  )
AS
  l_sqltext            VARCHAR2(32000) ;


  l_call_center        VARCHAR2(3000);
  l_classification     VARCHAR2(3000);
  l_dnis               VARCHAR2(3000);
  l_view_by			   VARCHAR2 (120);
  l_column_name        VARCHAR2(1000);

  l_custom_rec         BIS_QUERY_ATTRIBUTES;

  l_as_of_date   DATE;
  l_period_type	varchar2(2000);
  l_record_type_id NUMBER;


  l_sqltext_cont       VARCHAR2(32000) ;
  l_where_clause       VARCHAR2(1000) ;
  l_group_by_clause       VARCHAR2(1000) ;
  l_view_by_select     VARCHAR2(500) ;
  l_comp_type	       VARCHAR2(500) ;
  l_xtd			       VARCHAR2(500) ;
  l_mv                 VARCHAR2 (240);
  l_view_by_col              VARCHAR2 (120);
  l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_col_tbl_cont           poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_filter_where           VARCHAR2 (2000);
  l_func_area CONSTANT varchar2(5)  := 'ITATR';
  l_mv_set CONSTANT varchar2(3)     := 'ITM';
  l_version varchar2(3)             := NULL;
  l_timetype CONSTANT varchar2(3)   := 'XTD';
  l_generate_viewby		   VARCHAR2(1);



BEGIN

l_generate_viewby		   :='N';

 /* Initialize the variables */
  p_custom_output  := BIS_QUERY_ATTRIBUTES_TBL();

 /* Trial for Util Package.. */

l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
l_col_tbl                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();
l_col_tbl_cont             := poa_dbi_util_pkg.poa_dbi_col_tbl ();


bix_pmv_dbi_utl_pkg.process_parameters
									    ( p_param               => p_page_parameter_tbl
                                        , p_trend		        => 'N'
                                        , p_func_area			=> l_func_area
									    , p_version             => l_version
										, p_mv_set              => l_mv_set
									    , p_where_clause        => l_where_clause
										, p_mv                  => l_mv
										, p_join_tbl            => l_join_tbl
										, p_comp_type           => l_comp_type
										, p_xtd 				=> l_xtd
										, p_view_by_select      => l_view_by_select
										, p_view_by				=> l_view_by
										);

IF l_view_by = bix_pmv_dbi_utl_pkg.g_ai_ccntr_dim THEN
	l_generate_viewby :='Y';
ELSIF l_view_by = bix_pmv_dbi_utl_pkg.g_ai_class_dim THEN
	l_group_by_clause :='group by classification_value &ORDER_BY_CLAUSE nulls last';
ELSIF l_view_by = bix_pmv_dbi_utl_pkg.g_ai_dnis_dim THEN
	l_group_by_clause :='group by dnis_name &ORDER_BY_CLAUSE nulls last';
END IF;


 -- Populate col table with  columns for continued measures
   poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'a'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
       poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'b'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

      poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'c'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

      poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_cont_calls_offered_na END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'd'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

       poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'e'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

       poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'f'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

      poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_cont_calls_handled_tot_na END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'g'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

	   poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'h'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

	   poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'call_cont_calls_handled_tot_na'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'i'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

	   poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'j'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

      poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'k'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

      poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'l'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

      poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'm'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

     poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'n'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );


	l_sqltext_cont                   :=
							  bix_pmv_dbi_utl_pkg.status_sql_daylevel (
										   p_fact_name         => l_mv
                                         , p_row_type_where_clause      => l_where_clause --this shud come from util package
									     , p_col_name          => l_col_tbl_cont
                                         , p_join_tables       => l_join_tbl
                                         , p_time_type         => 'ESD'
                                         , p_union             => 'ALL');

   -- Populate col table with regular columns

    poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN agent_calls_answered_by_goal END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'a'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN agent_calls_handled_total END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'b'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_tot_queue_to_answer END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'c'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_calls_offered_total END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'd'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_calls_abandoned END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'e'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_calls_transferred END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'f'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
								);
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_calls_handled_total END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'g'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
								);
	poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => '(CASE WHEN media_item_type=''TELE_WEB_CALLBACK'' THEN call_calls_handled_total END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'h'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
								);
	poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'call_calls_handled_total'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'i'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
	poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'agent_wrap_time_nac'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'j'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'call_talk_time'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'k'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'agent_sr_created'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'l'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'agent_leads_created'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'm'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
   poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'agent_opportunities_created'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'n'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

 l_sqltext                    :='select rset.*,BIX_PMV_AI_SL_CP BIX_CALC_ITEM1,BIX_PMV_TOTAL1 BIX_CALC_ITEM2,'
								||'BIX_PMV_AI_ABANRATE_CP BIX_CALC_ITEM9,BIX_PMV_TOTAL5 BIX_CALC_ITEM10,'
								||'BIX_PMV_AI_AVGWRAP_CP BIX_CALC_ITEM25,'
								||'BIX_PMV_TOTAL15 BIX_CALC_ITEM26  from ('
								||	get_measures(l_view_by_select) || l_sqltext_cont ||
							  poa_dbi_template_pkg.status_sql (
										   p_fact_name         => l_mv
                                         , p_where_clause      => l_where_clause
                                         , p_filter_where      => l_filter_where
                                         , p_join_tables       => l_join_tbl
                                         , p_use_windowing     => 'N'
                                         , p_col_name          => l_col_tbl
                                         , p_use_grpid         => 'N'
                                         , p_paren_count       => 3
										 , p_generate_viewby   => l_generate_viewby)
										 ||l_group_by_clause|| get_zeronull_clause;

l_sqltext:=replace(replace(replace(replace(replace(l_sqltext,
'      ',' '),'     ',' '),'    ',' '),'   ',' '),'  ',' ');



p_sql_text := l_sqltext;
bix_pmv_dbi_utl_pkg.get_bind_vars (p_custom_output,p_func_area => l_func_area);


--  l_sqltext:=NULL;
--  l_where_clause:=NULL;

  /* Initialize p_custom_output and l_custom_rec */
  /*p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

  l_where_clause   := NULL;
  l_call_center    := NULL;
  l_classification := NULL;
  l_dnis           := NULL;
  l_view_by        := NULL;
  l_column_name    := NULL;

 -- Get the parameters

BIX_PMV_DBI_UTL_PKG.get_ai_page_params( p_page_parameter_tbl,
                                         l_as_of_date,
                                         l_period_type,
                                         l_record_type_id,
                                         l_comp_type,
                                         l_call_center,
                                         l_classification,
                                         l_dnis,
								 l_view_by
                                      );

IF l_call_center IS NOT NULL THEN
   l_where_clause := ' AND a.server_group_id IN (:l_call_center) ';
END IF;

IF l_classification IS NOT NULL THEN
   l_where_clause := l_where_clause || ' AND a.classification_value IN (:l_classification) ';
END IF;

--insert into bixtest values ('l_dnis is ' || l_dnis);
--commit;

IF l_dnis IS NOT NULL THEN
   IF l_dnis = '''INBOUND'''
   THEN
      l_where_clause := l_where_clause ||
	                        ' AND a.dnis_name <> ''OUTBOUND'' ';
   ELSIF l_dnis = '''OUTBOUND'''
   THEN
      l_where_clause := l_where_clause ||
	                        ' AND a.dnis_name = ''OUTBOUND'' ';
   ELSE
      l_where_clause := l_where_clause ||
	                        ' AND a.dnis_name IN (:l_dnis) ';
   END IF;
END IF;


  IF l_view_by = 'BIX_TELEPHONY+BIX_CALL_CENTER' THEN
    l_column_name := 'server_group_id ';
    --l_column_name := 'dnis_name ';
  ELSIF l_view_by = 'BIX_TELEPHONY+BIX_CALL_CLASSIFICATION' THEN
    l_column_name := 'classification_value ';
  ELSIF l_view_by = 'BIX_TELEPHONY+BIX_DNIS' THEN
    l_column_name := 'dnis_name ';
  ELSE
    l_column_name := 'classification_value ';
  END IF;

  --

IF l_column_name = 'server_group_id '
THEN
   l_sqltext := 'SELECT group_name VIEWBY ';
ELSE
   l_sqltext := 'SELECT ' || l_column_name || ' VIEWBY ';
END IF;

  l_sqltext := l_sqltext ||
    '
       ,ROUND(a / g1 * 100, 1)
                          BIX_PMV_AI_SL_CP
       ,ROUND(SUM(a) OVER() / SUM(g1) OVER() * 100, 1)
                          BIX_PMV_TOTAL1
       ,ROUND((a / g1 * 100) - (b / h1 * 100), 1)
                          BIX_PMV_AI_SL_CG
       ,ROUND((SUM(a) OVER() / SUM(g1) OVER() * 100) - (SUM(b) OVER() / SUM(h1) OVER() * 100), 1)
                          BIX_PMV_TOTAL2
       ,ROUND(b / h1 * 100, 1)
                          BIX_PMV_AI_SL_PP
       ,ROUND(e / m1, 1)   BIX_PMV_AI_SPANS_CP
       ,ROUND(SUM(e) OVER() / SUM(m1) OVER(), 1)
                          BIX_PMV_TOTAL3
       ,ROUND(((e / m1) - (f / n1)) / DECODE(f / n1, 0, NULL, f / n1) * 100 , 1)
                          BIX_PMV_AI_SPANS_CG
       ,ROUND((SUM(e) OVER() / SUM(m1) OVER() - SUM(f) OVER() / SUM(n1) OVER()) / DECODE(SUM(f) OVER() / SUM(n1) OVER(), 0, NULL,
	        SUM(f) OVER() / SUM(n1) OVER()) * 100 , 1)
                          BIX_PMV_TOTAL4
       ,ROUND(f / n1, 1)   BIX_PMV_AI_SPANS_PP
       ,ROUND(i / g1 * 100, 1)
                          BIX_PMV_AI_ABANRATE_CP
       ,ROUND(SUM(i) OVER() / SUM(g1) OVER() * 100, 1)
                          BIX_PMV_TOTAL5
       ,ROUND((i / g1 * 100) - (j / h1 * 100), 1)
                          BIX_PMV_AI_ABANRATE_CG
       ,ROUND(SUM(i) OVER() / SUM(g1) OVER() * 100 - SUM(j) OVER() / SUM(h1) OVER() * 100, 1)
                          BIX_PMV_TOTAL6
       ,ROUND(j / h1 * 100, 1)
                          BIX_PMV_AI_ABANRATE_PP
       ,ROUND(k / m * 100, 1)
                          BIX_PMV_AI_TRANRATE_CP
       ,ROUND(SUM(k) OVER() / SUM(m) OVER() * 100, 1)
                          BIX_PMV_TOTAL7
       ,ROUND((k / m * 100) - (l / n * 100), 1)
                          BIX_PMV_AI_TRANRATE_CG
       ,ROUND(SUM(k) OVER() / SUM(m) OVER() * 100 - SUM(l) OVER() / SUM(n) OVER() * 100, 1)
                          BIX_PMV_TOTAL8
       ,nvl(m,0)          BIX_PMV_AI_INCALLHAND_CP
       ,nvl(SUM(m) OVER() ,0)
	                     BIX_PMV_TOTAL9
       ,ROUND((m - n) / DECODE(n, 0, NULL, n) * 100, 1)
                          BIX_PMV_AI_INCALLHAND_CG
       ,ROUND((SUM(m) OVER() - SUM(n) OVER()) / DECODE(SUM(n) OVER(), 0, NULL, SUM(n) OVER()) * 100, 1)
                          BIX_PMV_TOTAL10
       ,nvl(n,0)          BIX_PMV_AI_INCALLHAND_PP
       ,o                 BIX_PMV_AI_WEBCALL_CP
       ,SUM(o) OVER()     BIX_PMV_TOTAL11
       ,ROUND((o - p) / DECODE(p, 0, NULL, p) * 100, 1)
                          BIX_PMV_AI_WEBCALL_CG
       ,ROUND((SUM(o) OVER() - SUM(p) OVER()) / DECODE(SUM(p) OVER(), 0, NULL, SUM(p) OVER()) * 100, 1)
                          BIX_PMV_TOTAL12
       ,ROUND(u / q, 1)   BIX_PMV_AI_AVGTALK_CP
       ,ROUND(SUM(u) OVER() / SUM(q) OVER(), 1)
                          BIX_PMV_TOTAL13
       ,ROUND(((u / q) - (v / r)) / DECODE(v / r, 0, NULL, v / r) * 100 , 1)
                          BIX_PMV_AI_AVGTALK_CG
       ,ROUND((SUM(u) OVER() / SUM(q) OVER() - SUM(v) OVER() / SUM(r) OVER()) /
	       DECODE(SUM(v) OVER() / SUM(r) OVER(), 0, NULL, SUM(v) OVER() / SUM(r) OVER()) * 100 , 1)
                          BIX_PMV_TOTAL14
       ,ROUND(v / r, 1)   BIX_PMV_AI_AVGTALK_PP
       ,ROUND(s / q, 1)   BIX_PMV_AI_AVGWRAP_CP
       ,ROUND(SUM(s) OVER() / SUM(q) OVER(), 1)
                          BIX_PMV_TOTAL15
       ,ROUND(((s / q) - (t / r)) / DECODE(t / r, 0, NULL, t / r) * 100, 1)
                          BIX_PMV_AI_AVGWRAP_CG
       ,ROUND((SUM(s) OVER() / SUM(q) OVER() - SUM(t) OVER() / SUM(r) OVER()) /
	       DECODE(SUM(t) OVER() / SUM(r) OVER(), 0, NULL, SUM(t) OVER() / SUM(r) OVER()) * 100, 1)
                          BIX_PMV_TOTAL16
       ,w                 BIX_PMV_AI_SRCR_CP
       ,SUM(w) OVER()     BIX_PMV_TOTAL17
       ,ROUND((w - x) / DECODE(x, 0, NULL, x) * 100, 1)
                          BIX_PMV_AI_SRCR_CG
       ,ROUND((SUM(w) OVER() - SUM(x) OVER()) / DECODE(SUM(x) OVER(), 0, NULL, SUM(x) OVER()) * 100, 1)
                          BIX_PMV_TOTAL18
       ,y                 BIX_PMV_AI_LECR_CP
       ,SUM(y) OVER()     BIX_PMV_TOTAL19
       ,ROUND((y - z) / DECODE(z, 0, NULL, z) * 100, 1)
                          BIX_PMV_AI_LECR_CG
       ,ROUND((SUM(y) OVER() - SUM(z) OVER()) / DECODE(SUM(z) OVER(), 0, NULL, SUM(z) OVER()) * 100, 1)
                          BIX_PMV_TOTAL20
       ,y1                BIX_PMV_AI_OPCR_CP
       ,SUM(y1) OVER()    BIX_PMV_TOTAL23
       ,ROUND((y1 - z1) / DECODE(z1, 0, NULL, z1) * 100, 1)
                          BIX_PMV_AI_OPCR_CG
       ,ROUND((SUM(y1) OVER() - SUM(z1) OVER()) / DECODE(SUM(z1) OVER(), 0, NULL, SUM(z1) OVER()) * 100, 1)
                          BIX_PMV_TOTAL24
       ,a1                BIX_PMV_AI_CUST_CP
       ,a9                BIX_PMV_TOTAL21
       ,ROUND((a1 - a2) / DECODE(a2, 0, 1, a2) * 100, 1)
                          BIX_PMV_AI_CUST_CG
       ,ROUND((a9 - a10) / DECODE(a10, 0, NULL, a10) * 100, 1)
                          BIX_PMV_TOTAL22
  FROM ( ';

  l_sqltext := l_sqltext || '
    SELECT
       ' || l_column_name || '
      ,SUM(NVL(a,0)) a
      ,SUM(NVL(b,0)) b
      ,DECODE(SUM(c), 0, NULL, SUM(c)) c
      ,DECODE(SUM(d), 0, NULL, SUM(d)) d
      ,SUM(NVL(e,0)) e
      ,SUM(NVL(f,0)) f
      ,DECODE(SUM(g), 0, NULL, SUM(g)) g
      ,DECODE(SUM(h), 0, NULL, SUM(h)) h
      ,SUM(NVL(i,0)) i
      ,SUM(NVL(j,0)) j
      ,SUM(NVL(k,0)) k
      ,SUM(NVL(l,0)) l
	 ,DECODE(SUM(m), 0, NULL, SUM(m)) m
	 ,DECODE(SUM(n), 0, NULL, SUM(n)) n
      ,SUM(NVL(o,0)) o
      ,SUM(NVL(p,0)) p
      ,SUM(NVL(s,0)) s
      ,SUM(NVL(t,0)) t
      ,SUM(NVL(u,0)) u
      ,SUM(NVL(v,0)) v
      ,SUM(NVL(w,0)) w
      ,SUM(NVL(x,0)) x
      ,SUM(NVL(y,0)) y
      ,SUM(NVL(z,0)) z
      ,SUM(NVL(y1,0)) y1
      ,SUM(NVL(z1,0)) z1
      ,COUNT(DISTINCT(CASE WHEN report_date = &BIS_CURRENT_ASOF_DATE
                           AND party_id <> -1
                      THEN PARTY_ID END ))
                       a1
      ,COUNT(DISTINCT(CASE WHEN report_date = &BIS_PREVIOUS_ASOF_DATE
                           AND party_id <> -1
                      THEN PARTY_ID END ))
                       a2
      ,MIN(a9) a9
      ,MIN(a10) a10
      ,DECODE(SUM(NVL(q,0) + NVL(a3,0)), 0, NULL, SUM(NVL(q,0) + NVL(a3,0))) q
      ,DECODE(SUM(NVL(r,0) + NVL(a4,0)), 0, NULL, SUM(NVL(r,0) + NVL(a4,0))) r
      ,DECODE(SUM(NVL(m,0) + NVL(a5,0)), 0, NULL, SUM(NVL(m,0) + NVL(a5,0))) m1
      ,DECODE(SUM(NVL(n,0) + NVL(a6,0)), 0, NULL, SUM(NVL(n,0) + NVL(a6,0))) n1
      ,DECODE(SUM(NVL(g,0) + NVL(a7,0)), 0, NULL, SUM(NVL(g,0) + NVL(a7,0))) g1
      ,DECODE(SUM(NVL(h,0) + NVL(a8,0)), 0, NULL, SUM(NVL(h,0) + NVL(a8,0))) h1
    FROM ( ';

  l_sqltext := l_sqltext || '
		SELECT
		  ' || l_column_name || '
		  ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',agent_calls_answered_by_goal,
			 ''TELE_DIRECT'',agent_calls_answered_by_goal, 0))
						   a
		  ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',agent_calls_answered_by_goal,
			 ''TELE_DIRECT'',agent_calls_answered_by_goal, 0))
						   b
		  ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',agent_calls_handled_total,
			 ''TELE_DIRECT'',agent_calls_handled_total, 0))
						   c
		  ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',agent_calls_handled_total,
			 ''TELE_DIRECT'',agent_calls_handled_total, 0))
						   d
		  ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_tot_queue_to_answer,
			 ''TELE_DIRECT'',call_tot_queue_to_answer, 0))
						   e
		  ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_tot_queue_to_answer,
			 ''TELE_DIRECT'',call_tot_queue_to_answer, 0))
						   f
		  ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_calls_offered_total,
			 ''TELE_DIRECT'',call_calls_offered_total, 0))
						   g
		  ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_calls_offered_total,
			 ''TELE_DIRECT'',call_calls_offered_total, 0))
						   h
		  ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_calls_abandoned,
			 ''TELE_DIRECT'',call_calls_abandoned, 0))
						   i
      ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_calls_abandoned,
         ''TELE_DIRECT'',call_calls_abandoned, 0))
                       j
      ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_calls_transferred,
         ''TELE_DIRECT'',call_calls_transferred, 0))
                       k
      ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_calls_transferred,
         ''TELE_DIRECT'',call_calls_transferred, 0))
                       l
      ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'', call_calls_handled_total,
              ''TELE_DIRECT'', call_calls_handled_total, 0))
                       m
      ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'', call_calls_handled_total,
              ''TELE_DIRECT'', call_calls_handled_total, 0))
                       n
      ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_WEB_CALLBACK'',
               call_calls_handled_total, 0))
                       o
      ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_WEB_CALLBACK'',
               call_calls_handled_total, 0))
                       p
      ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,call_calls_handled_total)
                       q
      ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,call_calls_handled_total)
                       r
      ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_wrap_time_nac)
                       s
      ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_wrap_time_nac)
                       t
      ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,call_talk_time)
                       u
      ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,call_talk_time)
                       v
      ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_sr_created)
                       w
      ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_sr_created)
                       x
      ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_leads_created)
                       y
      ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_leads_created)
                       z
      ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_opportunities_created)
                       y1
      ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_opportunities_created)
                       z1
	 ,party_id party_id
	 ,calendar.report_date report_date
      ,NULL            a3
      ,NULL            a4
	 ,NULL            a5
	 ,NULL            a6
	 ,NULL            a7
	 ,NULL            a8
      ,COUNT(DISTINCT(CASE WHEN calendar.report_date = &BIS_CURRENT_ASOF_DATE
                           AND party_id <> -1
                      THEN PARTY_ID END )) OVER()
             a9
      ,COUNT(DISTINCT(CASE WHEN calendar.report_date = &BIS_PREVIOUS_ASOF_DATE
                           AND party_id <> -1
                      THEN PARTY_ID END )) OVER()
             a10
    FROM
      bix_ai_call_details_mv a,
      fii_time_rpt_struct calendar
    WHERE a.row_type = ''CDPR''
    AND   a.time_id = calendar.time_id
    AND   a.period_type_id = calendar.period_type_id
    AND   calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
    AND   bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id ';

  l_sqltext := l_sqltext || l_where_clause || '
    UNION ALL
    SELECT
       ' || l_column_name || '
      ,NULL  a
      ,NULL  b
      ,NULL  c
      ,NULL  d
      ,NULL  e
      ,NULL  f
      ,NULL  g
      ,NULL  h
      ,NULL  i
      ,NULL  j
      ,NULL  k
      ,NULL  l
      ,NULL  m
      ,NULL  n
      ,NULL  o
      ,NULL  p
      ,NULL  q
      ,NULL  r
      ,NULL  s
      ,NULL  t
      ,NULL  u
      ,NULL  v
      ,NULL  w
      ,NULL  x
      ,NULL  y
      ,NULL  z
      ,NULL  y1
      ,NULL  z1
	 ,NULL party_id
	 ,NULL report_date
      ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),call_cont_calls_handled_tot_na)
             a3
      ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')),call_cont_calls_handled_tot_na)
             a4
      ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),DECODE(media_item_type, ''TELE_INB'',
	                call_cont_calls_handled_tot_na, ''TELE_DIRECT'', call_cont_calls_handled_tot_na, 0))
             a5
      ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')),DECODE(media_item_type, ''TELE_INB'',
	                call_cont_calls_handled_tot_na, ''TELE_DIRECT'', call_cont_calls_handled_tot_na, 0))
             a6
      ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),DECODE(media_item_type, ''TELE_INB'',
	                call_cont_calls_offered_na, ''TELE_DIRECT'', call_cont_calls_offered_na, 0))
             a7
      ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')),DECODE(media_item_type, ''TELE_INB'',
	                call_cont_calls_offered_na, ''TELE_DIRECT'', call_cont_calls_offered_na, 0))
             a8
      ,NULL  a9
      ,NULL  a10
    FROM
      bix_ai_call_details_mv a
    WHERE row_type = ''CDPR''
    AND   time_id IN (TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),
                          TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')))
    AND   period_type_id = 1 ';

  l_sqltext := l_sqltext || l_where_clause || '
  )
    GROUP BY ' || l_column_name || '
  )  a ';


  IF l_view_by = 'BIX_TELEPHONY+BIX_CALL_CENTER' THEN
    l_sqltext := l_sqltext ||
      ' , ieo_svr_groups grp
        WHERE a.server_group_id = grp.server_group_id
        &ORDER_BY_CLAUSE ';
  ELSIF l_view_by = 'BIX_TELEPHONY+BIX_CALL_CLASSIFICATION' THEN
    l_sqltext := l_sqltext ||
      ' &ORDER_BY_CLAUSE ';
  ELSIF l_view_by = 'BIX_TELEPHONY+BIX_DNIS' THEN
    l_sqltext := l_sqltext ||
      ' &ORDER_BY_CLAUSE ';
  ELSE
    l_sqltext := l_sqltext ||
      ' &ORDER_BY_CLAUSE ';
  END IF;


  p_sql_text := l_sqltext;

  --
  p_custom_output.EXTEND();
  IF l_call_center IS NOT NULL THEN
    l_custom_rec.attribute_name := ':l_call_center' ;
    l_custom_rec.attribute_value:= l_call_center;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

    p_custom_output.Extend();
    p_custom_output(p_custom_output.count) := l_custom_rec;
  END IF;

  IF l_classification IS NOT NULL THEN
    l_custom_rec.attribute_name := ':l_classification' ;
    l_custom_rec.attribute_value:= l_classification;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

    p_custom_output.Extend();
    p_custom_output(p_custom_output.count) := l_custom_rec;
  END IF;

IF l_dnis IS NOT NULL AND l_dnis NOT IN ('INBOUND','OUTBOUND')
THEN
   l_custom_rec.attribute_name := ':l_dnis';
   l_custom_rec.attribute_value:= l_dnis;
   l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

   p_custom_output.Extend();
   p_custom_output(p_custom_output.count) := l_custom_rec;
END IF;


l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
l_custom_rec.attribute_value := l_view_by;

p_custom_output.EXTEND();
p_custom_output(p_custom_output.COUNT) := l_custom_rec;
*/
EXCEPTION
  WHEN OTHERS THEN
	RAISE;
END GET_SQL;
END  BIX_PMV_AI_TELDTL_RPT_PKG;

/
