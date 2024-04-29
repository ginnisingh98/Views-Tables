--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AI_CSTDTL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AI_CSTDTL_RPT_PKG" AS
/*$Header: bixicstr.plb 120.0 2005/05/25 17:21:40 appldev noship $ */

FUNCTION GET_ZERONULL_CLAUSE RETURN VARCHAR2
IS
l_having_clause VARCHAR2(1000);
BEGIN
l_having_clause:=') where
				 ( abs(nvl(BIX_PMV_AI_INCALLHAND_CP,0)) + abs(nvl(BIX_PMV_AI_INCALLHAND_CG,0))
				  + abs(nvl(BIX_PMV_AI_SRCR_CP,0))+abs(nvl(BIX_PMV_AI_SRCR_CG,0))
				  + abs(nvl(BIX_PMV_AI_LECR_CP,0)) + abs(nvl(BIX_PMV_AI_LECR_CG,0))
				  + abs(nvl(BIX_PMV_AI_OPCR_CP,0)) +abs(nvl(BIX_PMV_AI_OPCR_CG,0))
				  +abs(nvl(BIX_PMV_AI_SL_CP,0)) +abs(nvl(BIX_PMV_AI_SL_CG,0))
				  +abs(nvl(BIX_PMV_AI_SPANS_CP,0)) +abs(nvl(BIX_PMV_AI_SPANS_CG,0))
				  +abs(nvl(BIX_PMV_AI_TRANRATE_CP,0)) +abs(nvl(BIX_PMV_AI_TRANRATE_CG,0))
				  +abs(nvl(BIX_PMV_AI_AVGTALK_CP,0)) +abs(nvl(BIX_PMV_AI_AVGTALK_CG,0))
				  +abs(nvl(BIX_PMV_AI_AVGWRAP_CP,0)) +abs(nvl(BIX_PMV_AI_AVGWRAP_CG,0))
				  ) <> 0';
return l_having_clause;
END GET_ZERONULL_CLAUSE;


FUNCTION GET_MEASURES RETURN VARCHAR2
IS
l_measure_txt VARCHAR2(8000);
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

l_measure_txt :=
' SELECT nvl(party_name,:l_unknown)  BIX_PMV_AI_CUSTOMER,'||l_goal||' BIX_PMV_AI_SLGOAL,'
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'to_number(NVL(c_e,0))'
					,p_prev=>'NVL(p_e,0)'
					,p_measurecol=>'BIX_PMV_AI_INCALLHAND_CP'
					,p_totalcol=>'BIX_PMV_TOTAL7'
					,p_changecol=>'BIX_PMV_AI_INCALLHAND_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL8'
					)
||','
/* For KPI- Inbound calls Handled Current */
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_e,0)'
					,p_measurecol=>'BIX_CALC_ITEM17'
					,p_totalcol=>'BIX_CALC_ITEM18'
					)
||',' /* For KPI- Inbound calls Handled Previous */
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(p_e,0)'
					,p_measurecol=>'BIX_CALC_ITEM19'
					,p_totalcol=>'BIX_CALC_ITEM20'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_i,0)'
					,p_prev=>'NVL(p_i,0)'
					,p_measurecol=>'BIX_PMV_AI_SRCR_CP'
					,p_totalcol=>'BIX_PMV_TOTAL13'
					,p_changecol=>'BIX_PMV_AI_SRCR_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL14'
					)
||','
||/* For KPI- SR created -Current period */
bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_i,0)'
					,p_measurecol=>'BIX_CALC_ITEM29'
					,p_totalcol=>'BIX_CALC_ITEM30'
					)
||','
||/* For KPI- SR created -Prior period */
bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(p_i,0)'
					,p_measurecol=>'BIX_CALC_ITEM31'
					,p_totalcol=>'BIX_CALC_ITEM32'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_j,0)'
					,p_prev=>'NVL(p_j,0)'
					,p_measurecol=>'BIX_PMV_AI_LECR_CP'
					,p_totalcol=>'BIX_PMV_TOTAL15'
					,p_changecol=>'BIX_PMV_AI_LECR_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL16'
					)
||','
||/* For KPI- Leads created -Current period */
bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_j,0)'
					,p_measurecol=>'BIX_CALC_ITEM33'
					,p_totalcol=>'BIX_CALC_ITEM34'
					)
||','
||/* For KPI- Leads created -Priorperiod */
bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(p_j,0)'
					,p_measurecol=>'BIX_CALC_ITEM35'
					,p_totalcol=>'BIX_CALC_ITEM36'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_n,0)'
					,p_prev=>'NVL(p_n,0)'
					,p_measurecol=>'BIX_PMV_AI_OPCR_CP'
					,p_totalcol=>'BIX_PMV_TOTAL19'
					,p_changecol=>'BIX_PMV_AI_OPCR_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL20'
					)
||','
||/* For KPI- Opportunities created -Current period */
bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_n,0)'
					,p_measurecol=>'BIX_CALC_ITEM37'
					,p_totalcol=>'BIX_CALC_ITEM38'
					)
||','
||/* For KPI- Opportunities created -Prior period */
bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(p_n,0)'
					,p_measurecol=>'BIX_CALC_ITEM39'
					,p_totalcol=>'BIX_CALC_ITEM40'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(c_a, 0)'
					,p_denom=>'NVL(c_c,0)'
					,p_pnum=>'NVL(p_a, 0)'
					,p_pdenom=>'NVL(p_c,0)'
					,p_measurecol=>'BIX_PMV_AI_SL_CP'
					,p_totalcol=>'BIX_PMV_TOTAL1'
					,p_changecol=>'BIX_PMV_AI_SL_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL2'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_b, 0)'
					,p_denom=>'NVL(c_e,0)'
					,p_pnum=>'NVL(p_b, 0)'
					,p_pdenom=>'NVL(p_e,0)'
					,p_measurecol=>'BIX_PMV_AI_SPANS_CP'
					,p_totalcol=>'BIX_PMV_TOTAL3'
					,p_changecol=>'BIX_PMV_AI_SPANS_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL4'
					)
||',' /*  KPI - Average Speed to Answer */
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_b, 0)'
					,p_denom=>'NVL(c_e,0)'
					,p_measurecol=>'BIX_CALC_ITEM21'
					,p_totalcol=>'BIX_CALC_ITEM22'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(p_b, 0)'
					,p_denom=>'NVL(p_e,0)'
					,p_measurecol=>'BIX_CALC_ITEM23'
					,p_totalcol=>'BIX_CALC_ITEM24'
					)
||','

||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(c_d, 0)'
					,p_denom=>'NVL(c_e,0)'
					,p_pnum=>'NVL(p_d, 0)'
					,p_pdenom=>'NVL(p_e,0)'
					,p_measurecol=>'BIX_PMV_AI_TRANRATE_CP'
					,p_totalcol=>'BIX_PMV_TOTAL5'
					,p_changecol=>'BIX_PMV_AI_TRANRATE_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL6'
					)
||',' /* KPI - Transfer Rate */
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(c_d, 0)'
					,p_denom=>'NVL(c_e,0)'
					,p_measurecol=>'BIX_CALC_ITEM25'
					,p_totalcol=>'BIX_CALC_ITEM26'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(p_d, 0)'
					,p_denom=>'NVL(p_e,0)'
					,p_measurecol=>'BIX_CALC_ITEM27'
					,p_totalcol=>'BIX_CALC_ITEM28'
					)
||','
/* Average Talk KPI */
||bix_pmv_dbi_utl_pkg.get_divided_measure(
				     p_percentage=>'N'
					,p_num=>'NVL(c_h, 0)'
					,p_denom=>'NVL(c_f,0)'
					,p_measurecol=>'BIX_CALC_ITEM1'
					,p_totalcol=>'BIX_CALC_ITEM2'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
				     p_percentage=>'N'
					,p_num=>'NVL(p_h, 0)'
					,p_denom=>'NVL(p_f,0)'
					,p_measurecol=>'BIX_CALC_ITEM3'
					,p_totalcol=>'BIX_CALC_ITEM4'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
				     p_percentage=>'N'
					,p_num=>'NVL(c_h, 0)'
					,p_denom=>'NVL(c_f,0)'
					,p_pnum=>'NVL(p_h, 0)'
					,p_pdenom=>'NVL(p_f,0)'
					,p_measurecol=>'BIX_PMV_AI_AVGTALK_CP'
					,p_totalcol=>'BIX_PMV_TOTAL9'
					,p_changecol=>'BIX_PMV_AI_AVGTALK_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL10'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_g, 0)'
					,p_denom=>'NVL(c_f,0)'
					,p_pnum=>'NVL(p_g, 0)'
					,p_pdenom=>'NVL(p_f,0)'
					,p_measurecol=>'BIX_PMV_AI_AVGWRAP_CP'
					,p_totalcol=>'BIX_PMV_TOTAL11'
					,p_changecol=>'BIX_PMV_AI_AVGWRAP_CG'
					,p_changetotalcol=>'BIX_PMV_TOTAL12'
					)

||' FROM ( (';
	RETURN l_measure_txt;
EXCEPTION
 WHEN OTHERS THEN
  -- insert into bix_debug values('error in get measures',9876);
  RAISE;
END GET_MEASURES;



PROCEDURE GET_SQL(p_page_parameter_tbl IN         BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                  )
AS
  l_sqltext            VARCHAR2(32000) ;
  l_sqltext_cont       VARCHAR2(32000) ;
  l_where_clause       VARCHAR2(1000) ;
  l_mv                 VARCHAR2 (240);
  l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_col_tbl_cont                poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_filter_where           VARCHAR2 (2000);
  l_func_area varchar2(5)    := 'ICSTR';
  l_mv_set varchar2(3)       := 'ITM';
  l_version varchar2(3)      := NULL;
  l_timetype varchar2(3)     := 'XTD';
  l_view_by_select                VARCHAR2 (500);
  l_comp_type                VARCHAR2 (500);
  l_xtd                VARCHAR2 (500);
  l_view_by			   VARCHAR2 (120);


BEGIN
  /* Initialize the variables */
  p_custom_output  := BIS_QUERY_ATTRIBUTES_TBL();

/* Trial for Util Package..*/

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
										, p_xtd					=> l_xtd
										, p_view_by_select      => l_view_by_select
										, p_view_by				=> l_view_by
										);
 -- Populate col table with  columns for continued measures
  poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'a'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'b'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
   poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_cont_calls_offered_na END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'c'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'd'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_cont_calls_handled_tot_na END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'e'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'call_cont_calls_handled_tot_na'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'f'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
	poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'g'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'h'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'i'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
                               , p_col_name        => 'NULL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'j'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
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
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_tot_queue_to_answer END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'b'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_calls_offered_total END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'c'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_calls_transferred END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'd'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN call_calls_handled_total END)'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'e'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'call_calls_handled_total'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'f'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
	poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'agent_wrap_time_nac'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'g'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'call_talk_time'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'h'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'agent_sr_created'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'i'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );
    poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'agent_leads_created'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'j'
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

 l_sqltext                    :='select * from ('||
								get_measures || l_sqltext_cont ||
							  poa_dbi_template_pkg.status_sql (
										   p_fact_name         => l_mv
                                         , p_where_clause      => l_where_clause
                                         , p_filter_where      => l_filter_where
                                         , p_join_tables       => l_join_tbl
                                         , p_use_windowing     => 'N'
                                         , p_col_name          => l_col_tbl
                                         , p_use_grpid         => 'N'
                                         , p_paren_count       => 3
										 , p_generate_viewby   => 'Y')
										 || get_zeronull_clause;


p_sql_text:=l_sqltext;
bix_pmv_dbi_utl_pkg.get_bind_vars (p_custom_output,p_func_area => l_func_area);


/* End of Trial for Util Package */


/*The original query
  l_sqltext :=
    'SELECT         nvl(party.party_name,:l_unknown)  BIX_PMV_AI_CUSTOMER
       ,ROUND(SUM(NVL(a, 0)) / DECODE(SUM(NVL(e,0)+NVL(y,0)), 0, NULL, SUM(NVL(e,0)+NVL(y,0))) * 100, 1)
                          BIX_PMV_AI_SL_CP
       ,ROUND(SUM(SUM(NVL(a, 0))) OVER() /  DECODE(SUM(SUM(NVL(e,0)+NVL(y,0))) OVER(), 0, NULL,
	                    SUM(SUM(NVL(e,0)+NVL(y,0))) OVER()) * 100, 1)
                          BIX_PMV_TOTAL1
       ,ROUND((SUM(NVL(a, 0)) / DECODE(SUM(NVL(e,0)+NVL(y,0)), 0, NULL, SUM(NVL(e,0)+NVL(y,0))) * 100) -
          (SUM(NVL(b, 0)) / DECODE(SUM(NVL(f,0)+NVL(z,0)), 0, NULL, SUM(NVL(f,0)+NVL(z,0))) * 100), 1)
                          BIX_PMV_AI_SL_CG
       ,ROUND(SUM(SUM(NVL(a, 0))) OVER() /  DECODE(SUM(SUM(NVL(e,0)+NVL(y,0))) OVER(), 0, NULL,
	                           SUM(SUM(NVL(e,0)+NVL(y,0))) OVER()) * 100, 1) -
          ROUND(SUM(SUM(NVL(b, 0))) OVER() / DECODE(SUM(SUM(NVL(f,0)+NVL(z,0))) OVER(), 0, NULL,
		                         SUM(SUM(NVL(f,0)+NVL(z,0))) OVER()) * 100, 1)
                          BIX_PMV_TOTAL2
       ,ROUND(SUM(NVL(c, 0)) / DECODE(SUM(NVL(i,0)+NVL(w,0)), 0, NULL, SUM(NVL(i,0)+NVL(w,0))), 1)
                          BIX_PMV_AI_SPANS_CP
       ,ROUND(SUM(SUM(NVL(c, 0))) OVER() /  DECODE(SUM(SUM(NVL(i,0)+NVL(w,0))) OVER(), 0, NULL,
	             SUM(SUM(NVL(i,0)+NVL(w,0))) OVER()), 1)
                          BIX_PMV_TOTAL3
       ,((
	   (SUM(NVL(c, 0)) / DECODE(SUM(NVL(i,0)+NVL(w,0)), 0, NULL, SUM(NVL(i,0)+NVL(w,0)))) -
            (SUM(NVL(d, 0)) / DECODE(SUM(NVL(j,0)+NVL(x,0)), 0, NULL, SUM(NVL(j,0)+NVL(x,0))))) /
          DECODE(SUM(NVL(d, 0)) / DECODE(SUM(NVL(j,0)+NVL(x,0)), 0, NULL, SUM(NVL(j,0)+NVL(x,0))), 0, NULL,
            SUM(NVL(d, 0)) / DECODE(SUM(NVL(j,0)+NVL(x,0)), 0, NULL, SUM(NVL(j,0)+NVL(x,0))))) * 100
                          BIX_PMV_AI_SPANS_CG
       ,ROUND((((SUM(SUM(NVL(c, 0))) OVER() /
	              DECODE(SUM(SUM(NVL(i,0)+NVL(w,0))) OVER(), 0, NULL, SUM(SUM(NVL(i,0)+NVL(w,0))) OVER())) -
            (SUM(SUM(NVL(d, 0))) OVER() /
		         DECODE(SUM(SUM(NVL(j,0)+NVL(x,0))) OVER(), 0, NULL, SUM(SUM(NVL(j,0)+NVL(x,0))) OVER()))) /
          DECODE(SUM(SUM(NVL(d, 0))) OVER() /
		         DECODE(SUM(SUM(NVL(j,0)+NVL(x,0))) OVER(), 0, NULL, SUM(SUM(NVL(j,0)+NVL(x,0))) OVER()), 0, NULL,
            SUM(SUM(NVL(d, 0))) OVER() /
		         DECODE(SUM(SUM(NVL(j,0)+NVL(x,0))) OVER(), 0, NULL, SUM(SUM(NVL(j,0)+NVL(x,0))) OVER()))) * 100, 1)
                          BIX_PMV_TOTAL4
       ,ROUND(SUM(NVL(g, 0)) / DECODE(SUM(i), 0, NULL, SUM(i)) * 100, 1)
                          BIX_PMV_AI_TRANRATE_CP
       ,ROUND(SUM(SUM(NVL(g, 0))) OVER() / DECODE(SUM(SUM(i)) OVER(), 0, NULL, SUM(SUM(i)) OVER()) * 100, 1)
                          BIX_PMV_TOTAL5
       ,ROUND((SUM(NVL(g, 0)) / DECODE(SUM(i), 0, NULL, SUM(i)) * 100) -
          (SUM(NVL(h, 0)) / DECODE(SUM(j), 0, NULL, SUM(j)) * 100), 1)
                          BIX_PMV_AI_TRANRATE_CG
       ,ROUND(SUM(SUM(NVL(g, 0))) OVER() / DECODE(SUM(SUM(i)) OVER(), 0, NULL, SUM(SUM(i)) OVER()) * 100 -
          SUM(SUM(NVL(h, 0))) OVER() / DECODE(SUM(SUM(j)) OVER(), 0, NULL, SUM(SUM(j)) OVER()) * 100, 1)
                          BIX_PMV_TOTAL6
       ,SUM(NVL(i,0))
                          BIX_PMV_AI_INCALLHAND_CP
       ,SUM(SUM(NVL(i,0))) OVER()
                          BIX_PMV_TOTAL7
       ,ROUND(((SUM(NVL(i,0)) - SUM(NVL(j,0))) / DECODE(SUM(NVL(j,0)), 0, NULL, SUM(NVL(j,0)))) * 100, 1)
                          BIX_PMV_AI_INCALLHAND_CG
       ,ROUND(((SUM(SUM(NVL(i,0))) OVER() - SUM(SUM(NVL(j,0))) OVER()) /
          DECODE(SUM(SUM(NVL(j,0))) OVER(), 0, NULL, SUM(SUM(NVL(j,0))) OVER())) * 100, 1)
                          BIX_PMV_TOTAL8
       ,ROUND(SUM(NVL(o, 0)) / DECODE(SUM(NVL(k,0)+NVL(u,0)), 0, NULL, SUM(NVL(k,0)+NVL(u,0))), 1)
                          BIX_PMV_AI_AVGTALK_CP
       ,ROUND(SUM(SUM(NVL(o, 0))) OVER() / DECODE(SUM(SUM(NVL(k,0)+NVL(u,0))) OVER(), 0, NULL,
	      SUM(SUM(NVL(k,0)+NVL(u,0))) OVER()), 1)
                          BIX_PMV_TOTAL9
       ,ROUND((((SUM(NVL(o, 0)) / DECODE(SUM(NVL(k,0)+NVL(u,0)), 0, NULL, SUM(NVL(k,0)+NVL(u,0)))) -
            (SUM(NVL(p, 0)) / DECODE(SUM(NVL(l,0)+NVL(v,0)), 0, NULL, SUM(NVL(l,0)+NVL(v,0))))) /
          DECODE(SUM(NVL(p, 0)) / DECODE(SUM(NVL(l,0)+NVL(v,0)), 0, NULL, SUM(NVL(l,0)+NVL(v,0))), 0, NULL,
            SUM(NVL(p, 0)) / DECODE(SUM(NVL(l,0)+NVL(v,0)), 0, NULL, SUM(NVL(l,0)+NVL(v,0))))) * 100, 1)
                          BIX_PMV_AI_AVGTALK_CG
       ,ROUND((((SUM(SUM(NVL(o, 0))) OVER() /
	              DECODE(SUM(SUM(NVL(k,0)+NVL(u,0))) OVER(), 0, NULL, SUM(SUM(NVL(k,0)+NVL(u,0))) OVER())) -
            (SUM(SUM(NVL(p, 0))) OVER() /
		         DECODE(SUM(SUM(NVL(l,0)+NVL(v,0))) OVER(), 0, NULL, SUM(SUM(NVL(l,0)+NVL(v,0))) OVER()))) /
          DECODE(SUM(SUM(NVL(p, 0))) OVER() /
		         DECODE(SUM(SUM(NVL(l,0)+NVL(v,0))) OVER(), 0, NULL, SUM(SUM(NVL(l,0)+NVL(v,0))) OVER()), 0, NULL,
            SUM(SUM(NVL(p, 0))) OVER() /
		         DECODE(SUM(SUM(NVL(l,0)+NVL(v,0))) OVER(), 0, NULL, SUM(SUM(NVL(l,0)+NVL(v,0))) OVER()))) * 100, 1)
                          BIX_PMV_TOTAL10
       ,ROUND(SUM(NVL(m, 0)) / DECODE(SUM(NVL(k,0)+NVL(u,0)), 0, NULL, SUM(NVL(k,0)+NVL(u,0))), 1)
                          BIX_PMV_AI_AVGWRAP_CP
       ,ROUND(SUM(SUM(NVL(m, 0))) OVER() /
	              DECODE(SUM(SUM(NVL(k,0)+NVL(u,0))) OVER(), 0, NULL, SUM(SUM(NVL(k,0)+NVL(u,0))) OVER()) ,1)
                          BIX_PMV_TOTAL11
       ,ROUND((((SUM(NVL(m, 0)) / DECODE(SUM(NVL(k,0)+NVL(u,0)), 0, NULL, SUM(NVL(k,0)+NVL(u,0)))) -
            (SUM(NVL(n, 0)) / DECODE(SUM(NVL(l,0)+NVL(v,0)), 0, NULL, SUM(NVL(l,0)+NVL(v,0))))) /
          DECODE(SUM(NVL(n, 0)) / DECODE(SUM(NVL(l,0)+NVL(v,0)), 0, NULL, SUM(NVL(l,0)+NVL(v,0))), 0, NULL,
            SUM(NVL(n, 0)) / DECODE(SUM(NVL(l,0)+NVL(v,0)), 0, NULL, SUM(NVL(l,0)+NVL(v,0))))) * 100, 1)
                         BIX_PMV_AI_AVGWRAP_CG
       ,ROUND((((SUM(SUM(NVL(m, 0))) OVER() /
	              DECODE(SUM(SUM(NVL(k,0)+NVL(u,0))) OVER(), 0, NULL, SUM(SUM(NVL(k,0)+NVL(u,0))) OVER())) -
            (SUM(SUM(NVL(n, 0))) OVER() /
		         DECODE(SUM(SUM(NVL(l,0)+NVL(v,0))) OVER(), 0, NULL, SUM(SUM(NVL(l,0)+NVL(v,0))) OVER()))) /
          DECODE(SUM(SUM(NVL(n, 0))) OVER() /
		         DECODE(SUM(SUM(NVL(l,0)+NVL(v,0))) OVER(), 0, NULL, SUM(SUM(NVL(l,0)+NVL(v,0))) OVER()), 0, NULL,
            SUM(SUM(NVL(n, 0))) OVER() /
		         DECODE(SUM(SUM(NVL(l,0)+NVL(v,0))) OVER(), 0, NULL, SUM(SUM(NVL(l,0)+NVL(v,0))) OVER()))) * 100, 1)
                        BIX_PMV_TOTAL12
       ,SUM(NVL(q,0))
                        BIX_PMV_AI_SRCR_CP
       ,SUM(SUM(NVL(q,0))) OVER()
                        BIX_PMV_TOTAL13
       ,ROUND(((SUM(NVL(q,0)) - SUM(NVL(r,0))) / DECODE(SUM(NVL(r,0)), 0, NULL, SUM(NVL(r,0)))) * 100, 1)
                        BIX_PMV_AI_SRCR_CG
       ,ROUND((((SUM(SUM(NVL(q,0))) OVER()) - (SUM(SUM(NVL(r,0))) OVER())) /
          DECODE(SUM(SUM(NVL(r,0))) OVER(), 0, NULL, SUM(SUM(NVL(r,0))) OVER())) * 100, 1)
                        BIX_PMV_TOTAL14
       ,SUM(NVL(s,0))
                        BIX_PMV_AI_LECR_CP
       ,SUM(SUM(NVL(s,0))) OVER()
                        BIX_PMV_TOTAL15
       ,ROUND(((SUM(NVL(s,0)) - SUM(NVL(t,0))) / DECODE(SUM(NVL(t,0)), 0, NULL, SUM(NVL(t,0)))) * 100, 1)
                        BIX_PMV_AI_LECR_CG
       ,ROUND((((SUM(SUM(NVL(s,0))) OVER()) - (SUM(SUM(NVL(t,0))) OVER())) /
          DECODE(SUM(SUM(NVL(t,0))) OVER(), 0, NULL, SUM(SUM(NVL(t,0))) OVER())) * 100, 1)
                        BIX_PMV_TOTAL16
       ,SUM(NVL(s1,0))
                        BIX_PMV_AI_OPCR_CP
       ,SUM(SUM(NVL(s1,0))) OVER()
                        BIX_PMV_TOTAL19
       ,ROUND(((SUM(NVL(s1,0)) - SUM(NVL(t1,0))) / DECODE(SUM(NVL(t1,0)), 0, NULL, SUM(NVL(t1,0)))) * 100, 1)
                        BIX_PMV_AI_OPCR_CG
       ,ROUND((((SUM(SUM(NVL(s1,0))) OVER()) - (SUM(SUM(NVL(t1,0))) OVER())) /
          DECODE(SUM(SUM(NVL(t1,0))) OVER(), 0, NULL, SUM(SUM(NVL(t1,0))) OVER())) * 100, 1)
                        BIX_PMV_TOTAL20
       ,SUM(NVL(k,0))
                        BIX_PMV_AI_CNCT_CP
       ,SUM(SUM(NVL(k,0))) OVER()
                        BIX_PMV_TOTAL17
       ,ROUND(((SUM(NVL(k,0)) - SUM(NVL(l,0))) / DECODE(SUM(NVL(l,0)), 0, NULL, SUM(NVL(l,0)))) * 100, 1)
                        BIX_PMV_AI_CNCT_CG
       ,ROUND((((SUM(SUM(NVL(k,0))) OVER()) - (SUM(SUM(NVL(l,0))) OVER())) /
          DECODE(SUM(SUM(NVL(l,0))) OVER(), 0, NULL, SUM(SUM(NVL(l,0))) OVER())) * 100, 1)
                        BIX_PMV_TOTAL18
  FROM
  (
    SELECT
       party_id  party_id
      ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',agent_calls_answered_by_goal,
          ''TELE_DIRECT'',agent_calls_answered_by_goal, 0)))
                       a
      ,SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',agent_calls_answered_by_goal,
          ''TELE_DIRECT'',agent_calls_answered_by_goal, 0)))
                       b
      ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_tot_queue_to_answer,
         ''TELE_DIRECT'',call_tot_queue_to_answer, 0)))
                       c
      ,SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_tot_queue_to_answer,
         ''TELE_DIRECT'',call_tot_queue_to_answer, 0)))
                       d
      ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_calls_offered_total,
         ''TELE_DIRECT'',call_calls_offered_total, 0)))
                       e
      ,SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_calls_offered_total,
         ''TELE_DIRECT'',call_calls_offered_total, 0)))
                       f
      ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_calls_transferred,
         ''TELE_DIRECT'',call_calls_transferred, 0)))
                       g
      ,SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'',call_calls_transferred,
         ''TELE_DIRECT'',call_calls_transferred, 0)))
                       h
      ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'', call_calls_handled_total,
         ''TELE_DIRECT'', call_calls_handled_total, 0)))
                       i
      ,SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,DECODE(media_item_type, ''TELE_INB'', call_calls_handled_total,
         ''TELE_DIRECT'', call_calls_handled_total, 0)))
                       j
      ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,call_calls_handled_total))
                       k
      ,SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,call_calls_handled_total))
                       l
      ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_wrap_time_nac))
                       m
      ,SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_wrap_time_nac))
                       n
      ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,call_talk_time))
                       o
      ,SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,call_talk_time))
                       p
      ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_sr_created))
                       q
      ,SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_sr_created))
                       r
      ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_leads_created))
                       s
      ,SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_leads_created))
                       t
      ,NULL            u
      ,NULL            v
	 ,NULL            w
	 ,NULL            x
	 ,NULL            y
	 ,NULL            z
      ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_opportunities_created))
                       s1
      ,SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_opportunities_created))
                       t1
    FROM
      bix_ai_call_details_mv a,
      fii_time_rpt_struct calendar
    WHERE a.row_type = ''CDPR''
    AND   a.time_id = calendar.time_id
    AND   a.period_type_id = calendar.period_type_id
    AND   calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
    AND   bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id ';

  l_sqltext := l_sqltext || l_where_clause || '
    GROUP BY a.party_id
    UNION ALL
    SELECT
      party_id
	        party_id
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
      ,SUM(DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),call_cont_calls_handled_tot_na))
             u
      ,SUM(DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')),call_cont_calls_handled_tot_na))
             v
      ,SUM(DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),DECODE(media_item_type, ''TELE_INB'',
	                call_cont_calls_handled_tot_na, ''TELE_DIRECT'', call_cont_calls_handled_tot_na, 0)))
             w
      ,SUM(DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')),DECODE(media_item_type, ''TELE_INB'',
	                call_cont_calls_handled_tot_na, ''TELE_DIRECT'', call_cont_calls_handled_tot_na, 0)))
             x
      ,SUM(DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),DECODE(media_item_type, ''TELE_INB'',
	                call_cont_calls_offered_na, ''TELE_DIRECT'', call_cont_calls_offered_na, 0)))
             y
      ,SUM(DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')),DECODE(media_item_type, ''TELE_INB'',
	                call_cont_calls_offered_na, ''TELE_DIRECT'', call_cont_calls_offered_na, 0)))
             z
      ,NULL  s1
      ,NULL  t1
    FROM
      bix_ai_call_details_mv
    WHERE row_type = ''CDPR''
    AND   time_id IN (TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),
              TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')))
    AND   period_type_id = 1 ';

  l_sqltext := l_sqltext || l_where_clause || '
    GROUP BY party_id

  ) b, hz_parties party
  WHERE b.party_id = party.party_id (+)
  GROUP BY nvl(party.party_name,:l_unknown) &ORDER_BY_CLAUSE ';

*/

EXCEPTION
  WHEN OTHERS THEN
    l_sqltext:=sqlerrm;
END GET_SQL;
END  BIX_PMV_AI_CSTDTL_RPT_PKG;

/
