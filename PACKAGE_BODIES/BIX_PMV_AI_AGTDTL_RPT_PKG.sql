--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AI_AGTDTL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AI_AGTDTL_RPT_PKG" AS
/*$Header: bixiagtr.plb 120.1 2006/04/18 17:26:11 anasubra noship $ */

FUNCTION GET_ZERONULL_CLAUSE RETURN VARCHAR2
IS
l_having_clause VARCHAR2(1000);

BEGIN

l_having_clause:=' where
				 ( abs(nvl(BIX_PMV_AI_LOGIN_CP,0)) + abs(nvl(BIX_PMV_AI_AVAILRATE_CP,0))
				  + abs(nvl(BIX_PMV_AI_UTILRATE_CP,0))+abs(nvl(BIX_PMV_AI_INCALLHAND_CP,0))
				  + abs(nvl(BIX_PMV_AI_INCALLHAND_PAH,0)) + abs(nvl(BIX_PMV_AI_DIALED_CP,0))
				  + abs(nvl(BIX_PMV_AI_DIALED_PAH,0)) +abs(nvl(BIX_PMV_AI_AVGTALK_CP,0))
				  +abs(nvl(BIX_PMV_AI_AVGWRAP_CP,0)) +abs(nvl(BIX_PMV_AI_WEBCALL_CP,0))
				  +abs(nvl(BIX_PMV_AI_WEBCALL_PAH,0)) +abs(nvl(BIX_PMV_AI_SRCR_CP,0))
				  +abs(nvl(BIX_PMV_AI_LECR_CP,0)) +abs(nvl(BIX_PMV_AI_OPCR_CP,0))
				  +abs(nvl(BIX_CALC_ITEM3,0)) +abs(nvl(BIX_CALC_ITEM7,0))
				  +abs(nvl(BIX_CALC_ITEM11,0)) +abs(nvl(BIX_CALC_ITEM15,0))
				  +abs(nvl(BIX_CALC_ITEM19,0))
				  ) <> 0';

return l_having_clause;

END GET_ZERONULL_CLAUSE;

FUNCTION GET_MEASURES RETURN VARCHAR2
IS
l_measure_txt VARCHAR2(32000);
l_goal NUMBER;
BEGIN

--insert into bix_debug
--values ('Entered get_measures ');

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
' SELECT v.resource_name BIX_PMV_AI_AGENT, '
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'to_number(NVL(c_lg,0))'
					,p_measurecol=>'BIX_PMV_AI_LOGIN_CP'
					,p_totalcol=>'BIX_PMV_TOTAL1'
					,p_convertunit=>'/3600'
					)
||','
||bix_pmv_dbi_utl_pkg.get_pertotal_measure(
					p_num =>'to_number(NVL(c_lg,0))'
					,p_measurecol=>'BIX_PMV_AI_LOGIN_PT'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(c_lg, 0)-NVL(c_id,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_measurecol=>'BIX_PMV_AI_AVAILRATE_CP'
					,p_totalcol=>'BIX_PMV_TOTAL2'
					)
||','
||bix_pmv_dbi_utl_pkg.get_devavg_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(c_lg, 0)-NVL(c_id,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_col=>'BIX_PMV_AI_AVAILRATE_DEV'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(c_lg, 0)-NVL(c_id,0)-NVL(c_av,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_measurecol=>'BIX_PMV_AI_UTILRATE_CP'
					,p_totalcol=>'BIX_PMV_TOTAL3'
					)
||','
||bix_pmv_dbi_utl_pkg.get_devavg_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(c_lg, 0)-NVL(c_id,0)-NVL(c_av,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_col=>'BIX_PMV_AI_UTILRATE_DEV'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_ic,0)'
					,p_measurecol=>'BIX_PMV_AI_INCALLHAND_CP'
					,p_totalcol=>'BIX_PMV_TOTAL4'
					)
||','
||bix_pmv_dbi_utl_pkg.get_pertotal_measure(
					p_num =>'to_number(NVL(c_ic,0))'
					,p_measurecol=>'BIX_PMV_AI_INCALLHAND_PT'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_ic,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_measurecol=>'BIX_PMV_AI_INCALLHAND_PAH'
					,p_totalcol=>'BIX_PMV_TOTAL5'
					,p_convunitfordenom=>'/3600'
					)
||','
||bix_pmv_dbi_utl_pkg.get_devavg_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_ic,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_col=>'BIX_PMV_AI_INCALLHAND_PAH_DEV'
				    ,p_convunitfordenom=>'/3600'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_mc,0)'
					,p_measurecol=>'BIX_PMV_AI_DIALED_CP'
					,p_totalcol=>'BIX_PMV_TOTAL8'
					)
||','
||bix_pmv_dbi_utl_pkg.get_pertotal_measure(
					p_num =>'to_number(NVL(c_mc,0))'
					,p_measurecol=>'BIX_PMV_AI_DIALED_PT'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_mc,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_measurecol=>'BIX_PMV_AI_DIALED_PAH'
					,p_totalcol=>'BIX_PMV_TOTAL9'
					,p_convunitfordenom=>'/3600'
					)
||','
||bix_pmv_dbi_utl_pkg.get_devavg_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_mc,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_col=>'BIX_PMV_AI_DIALED_PAH_DEV'
					,p_convunitfordenom=>'/3600'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_t, 0)'
					,p_denom=>'NVL(c_tc,0)+NVL(c_cch,0)+
					           NVL(c_ctc,0)+NVL(c_cct,0)'
					,p_measurecol=>'BIX_PMV_AI_AVGTALK_CP'
					,p_totalcol=>'BIX_PMV_TOTAL10'
					)
||','
||bix_pmv_dbi_utl_pkg.get_devavg_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_t, 0)'
					,p_denom=>'NVL(c_tc,0)+NVL(c_cch,0)+
					           NVL(c_ctc,0)+NVL(c_cct,0)'
					,p_col=>'BIX_PMV_AI_AVGTALK_DEV'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_w, 0)'
					,p_denom=>'NVL(c_tc,0)+NVL(c_cch,0)+
					           NVL(c_ctc,0)+NVL(c_cct,0)'
					,p_measurecol=>'BIX_PMV_AI_AVGWRAP_CP'
					,p_totalcol=>'BIX_PMV_TOTAL11'
					)
||','
||bix_pmv_dbi_utl_pkg.get_devavg_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_w, 0)'
					,p_denom=>'NVL(c_tc,0)+NVL(c_cch,0)+
					           NVL(c_ctc,0)+NVL(c_cct,0)'
					,p_col=>'BIX_PMV_AI_AVGWRAP_DEV'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_wc,0)'
					,p_measurecol=>'BIX_PMV_AI_WEBCALL_CP'
					,p_totalcol=>'BIX_PMV_TOTAL6'
					)
||','
||bix_pmv_dbi_utl_pkg.get_pertotal_measure(
					p_num =>'to_number(NVL(c_wc,0))'
					,p_measurecol=>'BIX_PMV_AI_WEBCALL_PT'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_wc,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_measurecol=>'BIX_PMV_AI_WEBCALL_PAH'
					,p_totalcol=>'BIX_PMV_TOTAL7'
					,p_convunitfordenom=>'/3600'
					)
||','
||bix_pmv_dbi_utl_pkg.get_devavg_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_wc,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_col=>'BIX_PMV_AI_WEBCALL_PAH_DEV'
	   			    ,p_convunitfordenom=>'/3600'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_s,0)'
					,p_measurecol=>'BIX_PMV_AI_SRCR_CP'
					,p_totalcol=>'BIX_PMV_TOTAL13'
					)
||','
||bix_pmv_dbi_utl_pkg.get_pertotal_measure(
					p_num =>'to_number(NVL(c_s,0))'
					,p_measurecol=>'BIX_PMV_AI_SRCR_PT'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_l,0)'
					,p_measurecol=>'BIX_PMV_AI_LECR_CP'
					,p_totalcol=>'BIX_PMV_TOTAL14'
					)
||','
||bix_pmv_dbi_utl_pkg.get_pertotal_measure(
					p_num =>'to_number(NVL(c_l,0))'
					,p_measurecol=>'BIX_PMV_AI_LECR_PT'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_o,0)'
					,p_measurecol=>'BIX_PMV_AI_OPCR_CP'
					,p_totalcol=>'BIX_PMV_TOTAL15'
					)
||','
||bix_pmv_dbi_utl_pkg.get_pertotal_measure(
					p_num =>'to_number(NVL(c_o,0))'
					,p_measurecol=>'BIX_PMV_AI_OPCR_PT'
					)
||','

||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_mc,0)'
					,p_measurecol=>'BIX_CALC_ITEM1'
					,p_totalcol=>'BIX_CALC_ITEM2'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(p_mc,0)'
					,p_measurecol=>'BIX_CALC_ITEM3'
					,p_totalcol=>'BIX_CALC_ITEM4'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(c_wc,0)'
					,p_measurecol=>'BIX_CALC_ITEM5'
					,p_totalcol=>'BIX_CALC_ITEM6'
					)
||','
||bix_pmv_dbi_utl_pkg.get_simple_measure(
					p_curr=>'NVL(p_wc,0)'
					,p_measurecol=>'BIX_CALC_ITEM7'
					,p_totalcol=>'BIX_CALC_ITEM8'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(c_lg, 0)-NVL(c_id,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_measurecol=>'BIX_CALC_ITEM9'
					,p_totalcol=>'BIX_CALC_ITEM10'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(p_lg, 0)-NVL(p_id,0)'
					,p_denom=>'NVL(p_lg,0)'
					,p_measurecol=>'BIX_CALC_ITEM11'
					,p_totalcol=>'BIX_CALC_ITEM12'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(c_lg, 0)-NVL(c_id,0)-NVL(c_av,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_measurecol=>'BIX_CALC_ITEM13'
					,p_totalcol=>'BIX_CALC_ITEM14'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'Y'
					,p_num=>'NVL(p_lg, 0)-NVL(p_id,0)-NVL(p_av,0)'
					,p_denom=>'NVL(p_lg,0)'
					,p_measurecol=>'BIX_CALC_ITEM15'
					,p_totalcol=>'BIX_CALC_ITEM16'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(c_ic,0)'
					,p_denom=>'NVL(c_lg,0)'
					,p_measurecol=>'BIX_CALC_ITEM17'
					,p_totalcol=>'BIX_CALC_ITEM18'
					,p_convunitfordenom=>'/3600'
					)
||','
||bix_pmv_dbi_utl_pkg.get_divided_measure(
					p_percentage=>'N'
					,p_num=>'NVL(p_ic,0)'
					,p_denom=>'NVL(p_lg,0)'
					,p_measurecol=>'BIX_CALC_ITEM19'
					,p_totalcol=>'BIX_CALC_ITEM20'
					)
;
/**
',0 BIX_CALC_ITEM1,
0 BIX_CALC_ITEM2,
0 BIX_CALC_ITEM3,
0 BIX_CALC_ITEM4,
0 BIX_CALC_ITEM5,
0 BIX_CALC_ITEM6,
0 BIX_CALC_ITEM7,
0 BIX_CALC_ITEM8,
0 BIX_CALC_ITEM9,
0 BIX_CALC_ITEM10,
0 BIX_CALC_ITEM11,
0 BIX_CALC_ITEM12,
0 BIX_CALC_ITEM13,
0 BIX_CALC_ITEM14,
0 BIX_CALC_ITEM15,
0 BIX_CALC_ITEM16,
0 BIX_CALC_ITEM17,
0 BIX_CALC_ITEM18,
0 BIX_CALC_ITEM19,
0 BIX_CALC_ITEM20 ';
**/

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
  l_sqltext_cont       VARCHAR2(32000) ;
  l_sqltext_sess       VARCHAR2(32000) ;

  l_mv                 VARCHAR2 (240);
  l_mv_sess            VARCHAR2(240);
  l_comp_type          VARCHAR2(500);
  l_xtd			       VARCHAR2(500);

  l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_col_tbl_cont                poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_col_tbl_sess                poa_dbi_util_pkg.poa_dbi_col_tbl;

  l_where_clause       VARCHAR2(1000) ;
  l_where_clause_sess  VARCHAR2(1000);

  l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_join_tbl_sess          poa_dbi_util_pkg.poa_dbi_join_tbl;

  l_filter_where           VARCHAR2 (2000);
  l_filter_where_sess           VARCHAR2 (2000);

  l_mv_set CONSTANT varchar2(3)       := 'ITM';
  l_mv_set_sess CONSTANT varchar2(3)       := 'SES';

  l_view_by_select                VARCHAR2 (500);
  l_view_by_select_sess                VARCHAR2 (500);

  l_func_area CONSTANT varchar2(5)    := 'IAGTR';
  l_version varchar2(3)      := NULL;
  l_timetype CONSTANT varchar2(3)     := 'XTD';

  l_view_by			   VARCHAR2 (120);
  x integer;
BEGIN
  /* Initialize the variables */
  p_custom_output  := BIS_QUERY_ATTRIBUTES_TBL();

--insert into bix_Debug values (1);
/* Trial for Util Package..*/

l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
l_join_tbl_sess            := poa_dbi_util_pkg.poa_dbi_join_tbl ();

l_col_tbl                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();
l_col_tbl_cont             := poa_dbi_util_pkg.poa_dbi_col_tbl ();
l_col_tbl_sess        := poa_dbi_util_pkg.poa_dbi_col_tbl ();

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
, p_xtd				=> l_xtd
, p_view_by_select      => l_view_by_select
, p_view_by             => l_view_by
);

-- Populate col table with  columns for continued measures
poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 't'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'w'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'ic'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'wc'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'mc'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'tc'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'agent_cont_calls_hand_na'
, p_grand_total     => 'N'
, p_alias_name      => 'cch'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'ctc'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'agent_cont_calls_tc_na'
, p_grand_total     => 'N'
, p_alias_name      => 'cct'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'l'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'o'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 's'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'lg'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'id'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl_cont
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'av'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);

l_sqltext_cont                   :=
BIX_PMV_DBI_utl_pkg.status_sql_daylevel (
p_fact_name         => l_mv
, p_row_type_where_clause      => l_where_clause --this shud come from util package
, p_col_name          => l_col_tbl_cont
, p_join_tables       => l_join_tbl
, p_time_type         => 'ESD'
, p_union             => 'ALL');
--insert into bix_Debug values ('Ended status_sql_daylevel for continued');
--
--Session SQL
--
bix_pmv_dbi_utl_pkg.process_parameters
( p_param               => p_page_parameter_tbl
, p_trend              => 'N'
, p_func_area            => l_func_area
, p_version             => l_version
, p_mv_set              => l_mv_set_sess
, p_where_clause        => l_where_clause_sess
, p_mv                  => l_mv_sess
, p_join_tbl            => l_join_tbl_sess
, p_comp_type           => l_comp_type
, p_xtd				=> l_xtd
, p_view_by_select      => l_view_by_select_sess
, p_view_by             => l_view_by
);

--insert into bix_Debug values ('Ended process parameters for session');

-- Populate col_table_session with session measures

--insert into bix_Debug values ('Starting add columns for session');

poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_sess
, p_col_name        => 'login_time'
, p_grand_total     => 'N'
, p_alias_name      => 'lg'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_sess
, p_col_name        => 'idle_time'
, p_grand_total     => 'N'
, p_alias_name      => 'id'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl_sess
, p_col_name        => 'available_time'
, p_grand_total     => 'N'
, p_alias_name      => 'av'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);

--insert into bix_Debug values ('Setting nulls in l_sqltext_sess ');

l_sqltext_sess :='(Select
sess.agent_id resource_id,
null c_t,null p_t,
null c_w,null p_w,
null c_ic,null p_ic,
null c_wc,null p_wc,
null c_mc,null p_mc,
null c_tc,null p_tc,
null c_cch,null p_cch,
null c_ctc,null p_ctc,
null c_cct,null p_cct,
null c_l,null p_l,
null c_o,null p_o,
null c_s,null p_s,
c_lg,p_lg,c_id,p_id,c_av,p_av
from ';

--insert into bix_Debug values ('Calling status_sql for sess ');
--insert into bix_Debug values ('l_mv_sess:'|| l_mv_sess || 'l_where_clause_sess:'|| l_where_clause_sess||
                              --'l_filter_where_sess:'|| l_filter_where_sess);


l_sqltext_sess := l_sqltext_sess ||
poa_dbi_template_pkg.status_sql (
  p_fact_name         => l_mv_sess
, p_where_clause      => l_where_clause_sess
, p_filter_where      => l_filter_where_sess
, p_join_tables       => l_join_tbl_sess
, p_use_windowing     => 'N'
, p_col_name          => l_col_tbl_sess
, p_use_grpid         => 'N'
, p_paren_count       => 1
, p_generate_viewby   => 'N');

--insert into bix_Debug values ('Calling add_column for regular columns');

-- Populate col table with regular columns

poa_dbi_util_pkg.add_column(p_col_tbl         => l_col_tbl
, p_col_name        => 'agent_talk_time_nac'
, p_grand_total     => 'N'
, p_alias_name      => 't'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => 'agent_wrap_time_nac'
, p_grand_total     => 'N'
, p_alias_name      => 'w'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => '(CASE WHEN media_item_type in (''TELE_INB'',''TELE_DIRECT'') THEN agent_calls_handled_total END)'
, p_grand_total     => 'N'
, p_alias_name      => 'ic'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => '(CASE WHEN media_item_type in (''TELE_WEB_CALLBACK'') THEN  agent_calls_handled_total END)'
, p_grand_total     => 'N'
, p_alias_name      => 'wc'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => '(CASE WHEN media_item_type in (''TELE_MANUAL'') THEN  agent_calls_handled_total END)'
, p_grand_total     => 'N'
, p_alias_name      => 'mc'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => 'agent_calls_handled_total'
, p_grand_total     => 'N'
, p_alias_name      => 'tc'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'cch'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => 'agent_calls_tran_conf_to_nac'
, p_grand_total     => 'N'
, p_alias_name      => 'ctc'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'cct'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => 'agent_leads_created'
, p_grand_total     => 'N'
, p_alias_name      => 'l'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => 'agent_opportunities_created'
, p_grand_total     => 'N'
, p_alias_name      => 'o'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => 'agent_sr_created'
, p_grand_total     => 'N'
, p_alias_name      => 's'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'lg'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'id'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);
poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
, p_col_name        => 'NULL'
, p_grand_total     => 'N'
, p_alias_name      => 'av'
, p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
, p_to_date_type    => l_timetype
);


--insert into bix_Debug values ('Calling status_sql for regular columns');

l_sqltext :=poa_dbi_template_pkg.status_sql (
p_fact_name         => l_mv
, p_where_clause      => l_where_clause
, p_filter_where      => l_filter_where
, p_join_tables       => l_join_tbl
, p_use_windowing     => 'N'
, p_col_name          => l_col_tbl
, p_use_grpid         => 'N'
, p_paren_count       => 3
, p_generate_viewby   => 'Y');

--insert into bix_Debug values(l_sqltext);
--insert into bix_Debug values ('Forming l_sqltext');

l_sqltext :='select * from ('||get_measures|| ' from (('||l_sqltext_cont||l_sqltext_sess||') sess) UNION ALL '||l_sqltext||')'||GET_ZERONULL_CLAUSE;

--insert into bix_debug values('Returned from status_sql:' );

l_sqltext:=replace(replace(replace(replace(replace(l_sqltext,
'      ',' '),'     ',' '),'    ',' '),'   ',' '),'  ',' ');

--insert into bix_debug values ('Completed forming l_sqltext');

x:=length(l_sqltext);
--insert into bix_debug values (l_sqltext);
--insert into bix_debug values (x);


p_sql_text:=l_sqltext;
bix_pmv_dbi_utl_pkg.get_bind_vars (p_custom_output,p_func_area => l_func_area);

/* End of Trial for Util Package */

/*****************************
  l_sqltext :=
    'SELECT
        res.resource_name
                 BIX_PMV_AI_AGENT
       ,ROUND(SUM(NVL(fact.login,0))/3600, 1)
                      BIX_PMV_AI_LOGIN_CP
       ,ROUND((SUM(SUM(NVL(fact.login,0))) OVER())/3600, 1)
                      BIX_PMV_TOTAL1
       ,ROUND(SUM(nvl(fact.login,0))*100/
        decode(SUM(SUM(nvl(fact.login,0))) OVER(), 0, NULL,
	          SUM(SUM(nvl(fact.login,0))) OVER()),1) BIX_PMV_AI_LOGIN_PT
       ,ROUND((SUM(NVL(fact.login,0) - NVL(fact.idle, 0)) /
            DECODE(SUM(NVL(fact.login,0)), 0, NULL, SUM(NVL(fact.login,0)))) * 100, 1)
                      BIX_PMV_AI_AVAILRATE_CP
	   ,ROUND(
		  (
			SUM(SUM(NVL(fact.login,0) - NVL(fact.idle, 0))) OVER() /
               DECODE(SUM(SUM(NVL(fact.login,0))) OVER(), 0, NULL,
			    SUM(SUM(NVL(fact.login,0))) OVER()
			      )
            ) * 100
              ,1)
                      BIX_PMV_TOTAL2
       ,ROUND(((SUM(NVL(fact.login,0) - NVL(fact.idle, 0)) /
            DECODE(SUM(NVL(fact.login,0)), 0, NULL, SUM(NVL(fact.login,0)))) * 100)
                      -
       ((SUM(SUM(NVL(fact.login,0) - NVL(fact.idle, 0))) OVER() /
            DECODE(SUM(SUM(NVL(fact.login,0))) OVER(), 0, NULL, SUM(SUM(NVL(fact.login,0))) OVER())) * 100) ,1)  BIX_PMV_AI_AVAILRATE_DEV
       ,ROUND(
		    (
			SUM( NVL(fact.login,0) - NVL(fact.idle, 0) - NVL(fact.available,0) ) /
               DECODE(SUM(fact.login), 0, NULL, SUM(fact.login))
			) * 100
	      , 1)
                      BIX_PMV_AI_UTILRATE_CP
       ,ROUND(
		    (
		SUM(SUM( NVL(fact.login,0) - NVL(fact.idle, 0) - NVL(fact.available,0) )) over() /
          DECODE(SUM(SUM(fact.login)) over(), 0, NULL, SUM(SUM(fact.login)) over())
			) * 100
	      , 1) BIX_PMV_TOTAL3
       ,ROUND(
		    (
			SUM( NVL(fact.login,0) - NVL(fact.idle, 0) - NVL(fact.available,0) ) /
               DECODE(SUM(fact.login), 0, NULL, SUM(fact.login))
			) * 100
       -
		    (
		SUM(SUM( NVL(fact.login,0) - NVL(fact.idle, 0) - NVL(fact.available,0) )) over() /
          DECODE(SUM(SUM(fact.login)) over(), 0, NULL, SUM(SUM(fact.login)) over())
			) * 100
             ,1) BIX_PMV_AI_UTILRATE_DEV
       ,SUM(NVL(fact.inb_calls,0))
                      BIX_PMV_AI_INCALLHAND_CP
       ,SUM(SUM(NVL(fact.inb_calls,0))) OVER()
                      BIX_PMV_TOTAL4
,ROUND(SUM(NVL(fact.inb_calls,0))*100/
decode(SUM(SUM(NVL(fact.inb_calls,0))) OVER(),0,NULL,
       SUM(SUM(NVL(fact.inb_calls,0))) OVER()),1) BIX_PMV_AI_INCALLHAND_PT
       ,ROUND(SUM(NVL(fact.inb_calls,0)) /
            DECODE(SUM(NVL(fact.login,0))/3600, 0, NULL, SUM(NVL(fact.login,0))/3600), 1)
                      BIX_PMV_AI_INCALLHAND_PAH
       ,ROUND(SUM(SUM(NVL(fact.inb_calls,0))) OVER() /
            DECODE(SUM(SUM(NVL(fact.login,0))) OVER()/3600, 0, NULL, SUM(SUM(NVL(fact.login,0))) OVER()/3600), 1)
                      BIX_PMV_TOTAL5
       ,ROUND(SUM(NVL(fact.inb_calls,0)) /
            DECODE(SUM(NVL(fact.login,0))/3600, 0, NULL, SUM(NVL(fact.login,0))/3600), 1) -
          ROUND(SUM(SUM(NVL(fact.inb_calls,0))) OVER() /
            DECODE(SUM(SUM(NVL(fact.login,0))) OVER()/3600, 0, NULL, SUM(SUM(NVL(fact.login,0))) OVER()/3600), 1)
                      BIX_PMV_AI_INCALLHAND_PAH_DEV
       ,SUM(NVL(fact.web_calls,0))
                      BIX_PMV_AI_WEBCALL_CP
       ,SUM(SUM(NVL(fact.web_calls,0))) OVER()
                      BIX_PMV_TOTAL6
,ROUND(SUM(NVL(fact.web_calls,0))*100/
DECODE(SUM(SUM(NVL(fact.web_calls,0))) OVER(),0,NULL,
       SUM(SUM(NVL(fact.web_calls,0))) OVER()),1) BIX_PMV_AI_WEBCALL_PT
       ,ROUND(SUM(NVL(fact.web_calls,0)) /
            DECODE(SUM(NVL(fact.login,0))/3600, 0, NULL, SUM(NVL(fact.login,0))/3600), 1)
                      BIX_PMV_AI_WEBCALL_PAH
       ,ROUND(SUM(SUM(NVL(fact.web_calls,0))) OVER() /
            DECODE(SUM(SUM(NVL(fact.login,0))) OVER()/3600, 0, NULL, SUM(SUM(NVL(fact.login,0))) OVER()/3600), 1)
                      BIX_PMV_TOTAL7
       ,ROUND(SUM(NVL(fact.web_calls,0)) /
            DECODE(SUM(NVL(fact.login,0))/3600, 0, NULL, SUM(NVL(fact.login,0))/3600), 1) -
          ROUND(SUM(SUM(NVL(fact.web_calls,0))) OVER() /
            DECODE(SUM(SUM(NVL(fact.login,0))) OVER()/3600, 0, NULL, SUM(SUM(NVL(fact.login,0))) OVER()/3600), 1)
                      BIX_PMV_AI_WEBCALL_PAH_DEV
       ,SUM(NVL(fact.man_calls,0))
                      BIX_PMV_AI_DIALED_CP
       ,SUM(SUM(NVL(fact.man_calls,0))) OVER()
                      BIX_PMV_TOTAL8
,ROUND(SUM(NVL(fact.man_calls,0))*100/
DECODE(SUM(SUM(NVL(fact.man_calls,0))) OVER(),0,NULL,
       SUM(SUM(NVL(fact.man_calls,0))) OVER()),1) BIX_PMV_AI_DIALED_PT
       ,ROUND(SUM(NVL(fact.man_calls,0)) /
            DECODE(SUM(NVL(fact.login,0))/3600, 0, NULL, SUM(NVL(fact.login,0))/3600), 1)
                      BIX_PMV_AI_DIALED_PAH
       ,ROUND(SUM(SUM(NVL(fact.man_calls,0))) OVER() /
            DECODE(SUM(SUM(NVL(fact.login,0))) OVER()/3600, 0, NULL, SUM(SUM(NVL(fact.login,0))) OVER()/3600), 1)
                      BIX_PMV_TOTAL9
       ,ROUND(SUM(NVL(fact.man_calls,0)) /
            DECODE(SUM(NVL(fact.login,0))/3600, 0, NULL, SUM(NVL(fact.login,0))/3600), 1) -
          ROUND(SUM(SUM(NVL(fact.man_calls,0))) OVER() /
            DECODE(SUM(SUM(NVL(fact.login,0))) OVER()/3600, 0, NULL, SUM(SUM(NVL(fact.login,0))) OVER()/3600), 1)
                      BIX_PMV_AI_DIALED_PAH_DEV
       ,ROUND(SUM(NVL(fact.talk,0)) /
            DECODE(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) + NVL(fact.calls_tran_conf,0)
              + NVL(cont_calls_tc,0)), 0, NULL, SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) +
              NVL(fact.calls_tran_conf,0) + NVL(cont_calls_tc,0))), 1)
                      BIX_PMV_AI_AVGTALK_CP
       ,ROUND(SUM(SUM(NVL(fact.talk,0))) OVER() /
            DECODE(SUM(SUM(NVL(tot_calls,0) +
					  NVL(fact.cont_calls_hand,0)
                   )) OVER(), 0, NULL,
			    SUM(SUM(NVL(tot_calls,0) +
					  NVL(fact.cont_calls_hand,0)
			    )) OVER()), 1)
                      BIX_PMV_TOTAL10
       ,ROUND(SUM(NVL(fact.talk,0)) /
            DECODE(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) + NVL(fact.calls_tran_conf,0)
              + NVL(cont_calls_tc,0)), 0, NULL, SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) +
              NVL(fact.calls_tran_conf,0) + NVL(cont_calls_tc,0))), 1) -
          ROUND(SUM(SUM(NVL(fact.talk,0))) OVER() /
            DECODE(SUM(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0)
            )) OVER(), 0, NULL, SUM(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) )) OVER()), 1)
                      BIX_PMV_AI_AVGTALK_DEV
       ,ROUND(SUM(NVL(fact.wrap,0)) /
            DECODE(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) + NVL(fact.calls_tran_conf,0)
            + NVL(cont_calls_tc,0)), 0, NULL, SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) +
            NVL(fact.calls_tran_conf,0) + NVL(cont_calls_tc,0))), 1)
                      BIX_PMV_AI_AVGWRAP_CP
       ,ROUND(SUM(SUM(NVL(fact.wrap,0))) OVER() /
            DECODE(SUM(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0)
            )) OVER(), 0, NULL, SUM(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) )) OVER()), 1)
                      BIX_PMV_TOTAL11
       ,ROUND(SUM(NVL(fact.wrap,0)) /
            DECODE(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) + NVL(fact.calls_tran_conf,0)
            + NVL(cont_calls_tc,0)), 0, NULL, SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) +
            NVL(fact.calls_tran_conf,0) + NVL(cont_calls_tc,0))), 1) -
          ROUND(SUM(SUM(NVL(fact.wrap,0))) OVER() /
            DECODE(SUM(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0)
            )) OVER(), 0, NULL, SUM(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) )) OVER()), 1)
                      BIX_PMV_AI_AVGWRAP_DEV
       ,SUM(NVL(fact.sr,0))
                      BIX_PMV_AI_SRCR_CP
       ,SUM(SUM(NVL(fact.sr,0))) OVER()
                      BIX_PMV_TOTAL13
,ROUND(SUM(NVL(fact.sr,0))*100/
DECODE(SUM(SUM(NVL(fact.sr,0))) OVER(),0,NULL,
       SUM(SUM(NVL(fact.sr,0))) OVER()),1) BIX_PMV_AI_SRCR_PT
       ,SUM(NVL(fact.leads,0))
                      BIX_PMV_AI_LECR_CP
       ,SUM(SUM(NVL(fact.leads,0))) OVER()
                      BIX_PMV_TOTAL14
,ROUND(SUM(NVL(fact.leads,0))*100/
DECODE(SUM(SUM(NVL(fact.leads,0))) OVER(),0,NULL,
       SUM(SUM(NVL(fact.leads,0))) OVER()),1) BIX_PMV_AI_LECR_PT
       ,SUM(NVL(fact.oppr,0))
                      BIX_PMV_AI_OPCR_CP
       ,SUM(SUM(NVL(fact.oppr,0))) OVER()
                      BIX_PMV_TOTAL15
,ROUND(SUM(NVL(fact.oppr,0))*100/
DECODE(SUM(SUM(NVL(fact.oppr,0))) OVER(),0,NULL,
       SUM(SUM(NVL(fact.oppr,0))) OVER()),1) BIX_PMV_AI_OPCR_PT
     FROM (
      SELECT
         fact.resource_id
                 agent_id
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_talk_time_nac))
                 talk
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_wrap_time_nac))
                 wrap
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(fact.media_item_type, ''TELE_INB'', agent_calls_handled_total,
               ''TELE_DIRECT'', agent_calls_handled_total, 0)))
                 inb_calls
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(fact.media_item_type, ''TELE_WEB_CALLBACK'',
          agent_calls_handled_total, 0)))
                 web_calls
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,DECODE(fact.media_item_type, ''TELE_MANUAL'', agent_calls_handled_total, 0)))
                 man_calls
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_calls_handled_total))
                 tot_calls
        ,NULL    cont_calls_hand
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_calls_tran_conf_to_nac))
                 calls_tran_conf
        ,NULL    cont_calls_tc
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_leads_created))
                 leads
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_opportunities_created))
                 oppr
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_sr_created))
                 sr
        ,NULL    login
	   ,NULL    idle
        ,NULL    available
      FROM
        bix_ai_call_details_mv fact,
        fii_time_rpt_struct calendar
      WHERE fact.row_type = ''CDR''
	 AND   fact.time_id = calendar.time_id
      AND   fact.period_type_id = calendar.period_type_id
      AND   calendar.report_date = &BIS_CURRENT_ASOF_DATE
      AND   bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id ';

  l_sqltext := l_sqltext || l_call_where_clause ;

  IF l_agent_group IS NOT NULL THEN
    l_sqltext := l_sqltext ||
                   ' AND EXISTS (
                       SELECT 1
                       FROM   jtf_rs_group_members mem
                       WHERE  fact.resource_id = mem.resource_id
                       AND    mem.group_id IN (:l_agent_group)
                       AND    nvl(mem.delete_flag, ''N'') <> ''Y'' )';
  END IF;

  l_sqltext := l_sqltext || '
    GROUP BY fact.resource_id
    UNION ALL
    SELECT
        fact.agent_id
              agent_id
      , NULL  talk
      , NULL  wrap
      , NULL  inb_calls
      , NULL  web_calls
      , NULL  man_calls
      , NULL  tot_calls
      , NULL  cont_calls_hand
      , NULL  calls_tran_conf
      , NULL  cont_calls_tc
      , NULL  leads
      , NULL  oppr
      , NULL  sr
      , SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.login_time))
              login
      , SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.idle_time))
              idle
      , SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.available_time))
              available
    FROM
      bix_agent_session_f fact,
      fii_time_rpt_struct calendar
    WHERE fact.time_id = calendar.time_id
    AND   fact.application_id = 696
    AND   fact.period_type_id = calendar.period_type_id
    AND   calendar.report_date = &BIS_CURRENT_ASOF_DATE
    AND   bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id ';

  l_sqltext := l_sqltext || l_session_where_clause ;

  IF l_agent_group IS NOT NULL THEN
    l_sqltext := l_sqltext ||
                   ' AND EXISTS (
                       SELECT 1
                       FROM   jtf_rs_group_members mem
                       WHERE  fact.agent_id = mem.resource_id
                       AND    mem.group_id IN (:l_agent_group)
                       AND    nvl(mem.delete_flag, ''N'') <> ''Y'' )';
  END IF;

  l_sqltext := l_sqltext || '
    GROUP BY fact.agent_id
    UNION ALL
    SELECT
        fact.resource_id
              agent_id
      , NULL  talk
      , NULL  wrap
      , NULL  inb_calls
      , NULL  web_calls
      , NULL  man_calls
      , NULL  tot_calls
      , SUM(fact.agent_cont_calls_hand_na)
              cont_calls_hand
      , NULL  calls_tran_conf
      , SUM(fact.agent_cont_calls_tc_na)
              cont_calls_tc
      , NULL  leads
      , NULL  oppr
      , NULL  sr
      , NULL  login
	 , NULL  idle
      , NULL  available
    FROM
      bix_ai_call_details_mv fact
    WHERE fact.row_type = ''CDR''
    AND   fact.time_id = TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J''))
    AND   fact.period_type_id = 1 ';

  l_sqltext := l_sqltext || l_call_where_clause ;

  IF l_agent_group IS NOT NULL THEN
    l_sqltext := l_sqltext ||
                   ' AND EXISTS (
                       SELECT 1
                       FROM   jtf_rs_group_members mem
                       WHERE  fact.resource_id = mem.resource_id
                       AND    mem.group_id IN (:l_agent_group)
                       AND    nvl(mem.delete_flag, ''N'') <> ''Y'' )';
  END IF;

  l_sqltext := l_sqltext || '
    GROUP BY fact.resource_id
  ) fact, jtf_rs_resource_extns_vl res
  WHERE fact.agent_id = res.resource_id
  GROUP BY res.resource_name &ORDER_BY_CLAUSE ';

********************************************/

EXCEPTION
  WHEN OTHERS THEN
  l_sqltext:=sqlerrm;
 --insert into bix_Debug values (l_sqltext);
 commit;
END GET_SQL;
END  BIX_PMV_AI_AGTDTL_RPT_PKG;

/
