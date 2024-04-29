--------------------------------------------------------
--  DDL for Package Body OKI_DBI_NSCM_TRM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_NSCM_TRM_PVT" 	OKI_DBI_NSCM_TRM_PVT AS
/* $Header: OKIPNTRB.pls 120.4 2005/10/10 04:40:35 kamsharm noship $ */

/******************************************************************
*  Procedure to return the query for Terminations portlet
******************************************************************/

  PROCEDURE Get_Terminations_Sql(
	p_param			IN  BIS_PMV_PAGE_PARAMETER_TBL,
	x_custom_sql		OUT NOCOPY VARCHAR2,
	x_custom_output		OUT NOCOPY bis_query_attributes_tbl) IS

  l_query			VARCHAR2(32767);
  l_view_by			VARCHAR2(120);
  l_view_by_col			VARCHAR2(120);
  l_as_of_date			DATE;
  l_prev_as_of_date		DATE;
  l_xtd				VARCHAR2(10);
  l_comparison_type		VARCHAR2(1);
  l_period_type			VARCHAR2(10);
  l_nested_pattern		NUMBER;
  l_cur_suffix			VARCHAR2(2);
  l_where_clause		VARCHAR2(2000);
  l_filter_where		VARCHAR2(240);
  l_mv				VARCHAR2(2000);
  l_col_tbl			POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl;
  l_join_tbl			POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl;
  l_to_date_xed			CONSTANT VARCHAR2(3):='XED';
  l_to_date_xtd			CONSTANT VARCHAR2(3):='XTD';
  l_to_date_ytd			CONSTANT VARCHAR2(3):='YTD';
  l_to_date_itd			CONSTANT VARCHAR2(3):='ITD';

    BEGIN

    l_comparison_type := 'Y';

    l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl ();
    l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

    oki_dbi_util_pvt.process_parameters (
		p_param			=> p_param,
		p_view_by		=> l_view_by,
		p_view_by_col_name	=> l_view_by_col,
		p_comparison_type	=> l_comparison_type,
		p_xtd			=> l_xtd,
		p_as_of_date		=> l_as_of_date,
		p_prev_as_of_date	=> l_prev_as_of_date,
		p_cur_suffix		=> l_cur_suffix,
		p_nested_pattern	=> l_nested_pattern,
		p_where_clause		=> l_where_clause,
		p_mv			=> l_mv,
		p_join_tbl		=> l_join_tbl,
		p_period_type		=> l_period_type,
		p_trend			=> 'N',
		p_func_area		=> 'OKI',
		p_version		=> '7.0',
		p_role			=> NULL ,
		p_mv_set		=> 'SRM_TM_71',
		p_rg_where		=> 'Y');


  l_query := 'select  1 VIEWBYID, ''Hello'' VIEWBY ,''SG Url'' OKI_SALES_GROUP_URL ,
''RUL 2 Url'' OKI_DYNAMIC_URL_1,1 OKI_MEASURE_1  ,2 OKI_PMEASURE_1  ,3 OKI_TMEASURE_1  ,
4 OKI_CHANGE_1  ,5 OKI_TCHANGE_1, 6 OKI_KPI_MEASURE_1  ,7 OKI_PKPI_MEASURE_1  ,
8 OKI_TKPI_MEASURE_1  ,9 OKI_PTKPI_MEASURE_1, 10 OKI_PERCENT_1  ,11 OKI_TPERCENT_1  ,
12 OKI_PERCENT_CHANGE_1  ,13 OKI_MEASURE_2  ,14 OKI_TMEASURE_2  ,15 OKI_KPI_MEASURE_2  ,
16 OKI_PKPI_MEASURE_2  ,17 OKI_TKPI_MEASURE_2  ,18 OKI_PTKPI_MEASURE_2  ,19 OKI_PERCENT_2  ,
20 OKI_TPERCENT_2   FROM DUAL' ;

     POA_DBI_UTIL_PKG.Add_Column(
		p_col_tbl		=> l_col_tbl,
		p_col_name		=> 't_rv_amt_'||l_cur_suffix,
		p_alias_name		=> 't_rv',
		p_to_date_type		=> l_to_date_xtd);


     POA_DBI_UTIL_PKG.Add_Column(
		p_col_tbl		=> l_col_tbl,
		p_col_name		=> 't_bv_amt_' || l_cur_suffix,
		p_alias_name		=> 't_bv',
		p_to_date_type		=> l_to_date_xtd);

    l_filter_where := '  ( ABS(oki_measure_1) <> 0 or ABS(oki_pmeasure_1) <> 0 or ABS(oki_measure_2) <> 0)';

    -- Generate sql query
    l_query := Get_Terminations_Sel_Clause(l_view_by, l_view_by_col)
	|| ' from '
	|| POA_DBI_TEMPLATE_PKG.Status_Sql (
		p_fact_name 		=> l_mv,
		p_where_clause		=> l_where_clause,
		p_filter_where		=> l_filter_where,
		p_join_tables		=> l_join_tbl,
		p_use_windowing		=> 'Y',
		p_col_name		=> l_col_tbl,
		p_use_grpid		=> 'N',
		p_paren_count		=> 6);



    x_custom_sql := '/* OKI_DBI_SCM_TRM_SUM_RPT */ '||l_query;

    oki_dbi_util_pvt.get_custom_status_binds (x_custom_output);

  END get_terminations_sql;

/**********************************************************
* GET TERMINATIONS SELECT CLAUSE SQL - TERMINATIONS PORTLET
**********************************************************/

  FUNCTION Get_Terminations_Sel_Clause(
    p_view_by_dim		IN	VARCHAR2,
    p_view_by_col		IN	VARCHAR2) RETURN VARCHAR2 IS


    l_sel_clause		VARCHAR2(32767);
    l_terminated_url		VARCHAR2(300);
    l_viewby_select		VARCHAR2(32767);
    l_url_select		VARCHAR2(32767);

  BEGIN


    l_viewby_select := OKI_DBI_UTIL_PVT.Get_Viewby_Select_Clause(p_view_by_dim, 'SRM', '7.0');

    -- when view by is Salesrep OKI_DBI_SCM_ACT_DTL_RPT

    l_terminated_url := '''pFunctionName=OKI_DBI_SCM_TRM_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';

    l_viewby_select := l_viewby_select||', OKI_SALES_GROUP_URL, OKI_DYNAMIC_URL_1, OKI_MEASURE_1,
 OKI_PMEASURE_1, OKI_TMEASURE_1, OKI_CHANGE_1, OKI_TCHANGE_1, OKI_KPI_MEASURE_1, OKI_PKPI_MEASURE_1,
 OKI_TKPI_MEASURE_1, OKI_PTKPI_MEASURE_1, OKI_PERCENT_1, OKI_TPERCENT_1, OKI_PERCENT_CHANGE_1,
 OKI_MEASURE_2, OKI_TMEASURE_2, OKI_KPI_MEASURE_2, OKI_PKPI_MEASURE_2, OKI_TKPI_MEASURE_2,
 OKI_PTKPI_MEASURE_2, OKI_PERCENT_2, OKI_TPERCENT_2
     FROM (SELECT rank() over (&ORDER_BY_CLAUSE NULLS LAST , '||p_view_by_col||') - 1 rnk ,
'||p_view_by_col||', OKI_SALES_GROUP_URL, OKI_DYNAMIC_URL_1, OKI_MEASURE_1, OKI_PMEASURE_1,
 OKI_TMEASURE_1, OKI_CHANGE_1, OKI_TCHANGE_1, OKI_KPI_MEASURE_1, OKI_PKPI_MEASURE_1,
OKI_TKPI_MEASURE_1, OKI_PTKPI_MEASURE_1, OKI_PERCENT_1, OKI_TPERCENT_1, OKI_PERCENT_CHANGE_1,
 OKI_MEASURE_2, OKI_TMEASURE_2, OKI_KPI_MEASURE_2, OKI_PKPI_MEASURE_2, OKI_TKPI_MEASURE_2,
 OKI_PTKPI_MEASURE_2, OKI_PERCENT_2, OKI_TPERCENT_2
       FROM ( ';

    IF (p_view_by_dim = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
      THEN l_url_select := 'SELECT decode(resource_id, -999,
''pFunctionName=OKI_DBI_SCM_TRM_SUM_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'', '''') OKI_SALES_GROUP_URL,
 decode(resource_id, -999, '''',
 decode( rg_id, -1, '''', '||l_terminated_url||')) OKI_DYNAMIC_URL_1 ';
    ELSIF (p_view_by_dim IN('ITEM+ENI_ITEM','OKI_STATUS+TERM_REASON'))
      THEN l_url_select := 'SELECT  ''''  OKI_SALES_GROUP_URL, '||l_terminated_url||' OKI_DYNAMIC_URL_1';
      ELSE l_url_select := 'SELECT '''' OKI_SALES_GROUP_URL, '''' OKI_DYNAMIC_URL_1';
    END IF;


      l_sel_clause := l_viewby_select||l_url_select||
	  -- AK Attribute naming
	  ', '||p_view_by_col||
	  ', oset20.c_t_rv	OKI_MEASURE_1'||
	  ', oset20.p_t_rv	OKI_PMEASURE_1'||
	  ', oset20.c_t_rv_tot	OKI_TMEASURE_1'||
	  ', oset20.c_t_rv_chg	OKI_CHANGE_1'||
	  ', oset20.c_t_rv_chg_tot	OKI_TCHANGE_1'||
	  ', oset20.c_t_rv	OKI_KPI_MEASURE_1'||
	  ', oset20.p_t_rv	OKI_PKPI_MEASURE_1'||
	  ', oset20.c_t_rv_tot	OKI_TKPI_MEASURE_1'||
	  ', oset20.p_t_rv_tot	OKI_PTKPI_MEASURE_1'||
	  ', oset20.c_t_rv_pot	OKI_PERCENT_1'||
	  ', oset20.c_t_rv_pot_tot	OKI_TPERCENT_1'||
	  ', '||OKI_DBI_UTIL_PVT.Change_Clause('oset20.c_t_rv_pot','oset20.p_t_rv_pot','P')||'	OKI_PERCENT_CHANGE_1'||
	  ', oset20.c_t_bv	OKI_MEASURE_2'||
	  ', oset20.c_t_bv_tot	OKI_TMEASURE_2'||
	  ', oset20.c_t_bv	OKI_KPI_MEASURE_2'||
	  ', oset20.p_t_bv	OKI_PKPI_MEASURE_2'||
	  ', oset20.c_t_bv_tot	OKI_TKPI_MEASURE_2'||
	  ', oset20.p_t_bv_tot	OKI_PTKPI_MEASURE_2'||
	  ', oset20.c_t_bv_pot	OKI_PERCENT_2'||
	  ', oset20.c_t_bv_pot_tot	OKI_TPERCENT_2'||
	  '   from ( select'||
	  -- Change Calculation
	  ' '||p_view_by_col||
	  ', oset15.c_t_rv	C_T_RV'||
	  ', oset15.p_t_rv	P_T_RV'||
	  ', '||OKI_DBI_UTIL_PVT.Change_Clause('oset15.c_t_rv','oset15.p_t_rv','NP') || '	C_T_RV_CHG'||
	  ', '||POA_DBI_UTIL_PKG.Rate_Clause('oset15.c_t_rv','oset15.c_t_rv_tot') || '	C_T_RV_POT'||
	  ', '||POA_DBI_UTIL_PKG.Rate_Clause('oset15.p_t_rv','oset15.p_t_rv_tot') || '	P_T_RV_POT'||
	  ', oset15.c_t_rv_tot	C_T_RV_TOT'||
	  ', oset15.p_t_rv_tot	P_T_RV_TOT'||
	  ', '||OKI_DBI_UTIL_PVT.Change_Clause('oset15.c_t_rv_tot','oset15.p_t_rv_tot','NP') || '	C_T_RV_CHG_TOT'||
	  ', '||poa_dbi_util_pkg.Rate_Clause('oset15.c_t_rv_tot','oset15.c_t_rv_tot')||'	C_T_RV_POT_TOT'||
	  ', oset15.c_t_bv	C_T_BV'||
	  ', oset15.p_t_bv	P_T_BV'||
	  ', '||POA_DBI_UTIL_PKG.Rate_Clause('oset15.c_t_rv', (OKI_DBI_UTIL_PVT.add_measures('oset15.c_t_rv','oset15.c_t_bv')))||'	C_T_BV_POT'||
	  ', oset15.c_t_bv_tot	C_T_BV_TOT'||
	  ', oset15.p_t_bv_tot	P_T_BV_TOT'||
	  ', '||POA_DBI_UTIL_PKG.Rate_Clause('oset15.c_t_rv_tot', (OKI_DBI_UTIL_PVT.add_measures('oset15.c_t_rv_tot','oset15.c_t_bv_tot')))||'	C_T_BV_POT_TOT'||
	  '   from (select '||
--marker
		-- Calculated Measures
		p_view_by_col ||
		', nvl(oset10.c_t_rv,0)	C_T_RV'||
		', nvl(oset10.p_t_rv,0)	P_T_RV'||
		', nvl(oset10.c_t_bv,0)	C_T_BV'||
		', nvl(oset10.p_t_bv,0)	P_T_BV'||
		', nvl(oset10.c_t_rv_tot,0)	C_T_RV_TOT'||
		', nvl(oset10.p_t_rv_tot,0)	P_T_RV_TOT'||
		', nvl(oset10.c_t_bv_tot,0)	C_T_BV_TOT'||
		', nvl(oset10.p_t_bv_tot,0)	P_T_BV_TOT'||
		' from '||
/*??*/
		'   ( select oset05.'||p_view_by_col||
		', nvl(oset05.c_t_rv,0)	C_T_RV'||
		', nvl(oset05.p_t_rv,0)	P_T_RV'||
		', nvl(oset05.c_t_bv,0)	C_T_BV'||
		', nvl(oset05.p_t_bv,0)	P_T_BV'||
		', nvl(oset05.c_t_rv_total,0)	C_T_RV_TOT'||
		', nvl(oset05.p_t_rv_total,0)	P_T_RV_TOT'||
		', nvl(oset05.c_t_bv_total,0)	C_T_BV_TOT'||
		', nvl(oset05.p_t_bv_total,0)	P_T_BV_TOT';

    RETURN l_sel_clause;
  END get_terminations_sel_clause;



/******************************************************************
*  Procedure to return the query for Terminations Detail report
******************************************************************/

  FUNCTION Get_Trm_Dtl_Sel_Clause(
		p_cur_suffix		IN	VARCHAR2,
		p_period_type_code	IN	VARCHAR2) RETURN VARCHAR2 IS

  l_query	VARCHAR2(10000);

  BEGIN

-- Generate sql query
    l_query := '
SELECT	k.complete_k_number			OKI_ATTRIBUTE_1,
	cust.value				OKI_ATTRIBUTE_2,
        DECODE(fact.resource_id,-1,&UNASSIGNED,rsex.resource_name) oki_attribute_3,
	v.value				OKI_ATTRIBUTE_4,
	to_char(k.start_date)			OKI_DATE_1,
	to_char(fact.oki_date_2)		OKI_DATE_2,
	to_char(fact.oki_date_3)		OKI_DATE_3,
	k.price_nego_'||p_cur_suffix||'         OKI_MEASURE_1,
	fact.oki_measure_2			OKI_MEASURE_2,
	fact.t_t_bv				OKI_TMEASURE_2,
	fact.oki_measure_3			OKI_MEASURE_3,
	fact.t_t_rv				OKI_TMEASURE_3,
	fact.chr_id                             OKI_ATTRIBUTE_6
  FROM (SELECT *
	  FROM (SELECT	rank() over (&ORDER_BY_CLAUSE NULLS LAST, chr_id, trn_code) - 1	RNK,
			chr_id,
			trn_code,
			customer_party_id,
			resource_id,
			oki_date_2,
			oki_date_3,
			oki_measure_2,
			t_t_bv,
			oki_measure_3,
			t_t_rv
		  FROM (SELECT	oset5.chr_id			CHR_ID,
				oset5.trn_code			TRN_CODE,
				oset5.customer_party_id		CUSTOMER_PARTY_ID,
				oset5.resource_id		RESOURCE_ID,
				oset5.date_terminated		OKI_DATE_2,
				oset5.termination_entry_date    OKI_DATE_3,
				oset5.t_bv			OKI_MEASURE_2,
				oset5.t_bv_total			T_T_BV,
				oset5.t_rv			OKI_MEASURE_3,
				oset5.t_rv_total			T_T_RV
			   FROM	(SELECT fact.chr_id,
					fact.trn_code,
					fact.customer_party_id,
					fact.resource_id,
					min(fact.date_terminated) date_terminated,
					min(fact.termination_entry_date) termination_entry_date';

     RETURN l_query;
  END Get_Trm_Dtl_Sel_Clause;

  PROCEDURE Get_Terminations_Detail_Sql(
		p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
		x_custom_sql	OUT NOCOPY 	VARCHAR2,
		x_custom_output	OUT NOCOPY 	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_query		VARCHAR2(32767);
  l_where_clause	VARCHAR2(2000);
  l_rpt_specific_where	VARCHAR2(2000);
  l_join_where		VARCHAR2(2000);
  l_group_by		VARCHAR2(2000);
  l_filter_where	VARCHAR2(240);
  l_view_by		VARCHAR2(240);
  l_view_by_col		VARCHAR2(240);
  l_mv			VARCHAR2(2000);
  l_period_type		VARCHAR2(10);
  l_xtd			VARCHAR2(10);
  l_curr_suffix		VARCHAR2(2);
  l_comparison_type	VARCHAR2(1);

  l_as_of_date		DATE;
  l_prev_as_of_date	DATE;

  l_nested_pattern	NUMBER;

  l_col_tbl		POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl;
  l_join_tbl		POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl;
  l_additional_where       VARCHAR2(32767);
  BEGIN

    l_comparison_type	:= 'Y';
    l_join_tbl := POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl();
    l_col_tbl := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl();

    OKI_DBI_UTIL_PVT.Process_Parameters(
		p_param			=> p_param,
		p_view_by		=> l_view_by,
		p_view_by_col_name	=> l_view_by_col,
		p_comparison_type	=> l_comparison_type,
		p_xtd			=> l_xtd,
		p_as_of_date		=> l_as_of_date,
		p_prev_as_of_date	=> l_prev_as_of_date,
		p_cur_suffix		=> l_curr_suffix,
		p_nested_pattern	=> l_nested_pattern,
		p_where_clause		=> l_where_clause,
		p_mv			=> l_mv,
		p_join_tbl		=> l_join_tbl,
		p_period_type		=> l_period_type,
		p_trend			=> 'N',
		p_func_area		=> 'OKI',
		p_version		=> '6.0',
		p_role			=> NULL,
                p_mv_set                => 'SRM_DTL_RPT',
		p_rg_where		=> 'Y');

    l_rpt_specific_where    :=
      ' AND fact.effective_term_date between &BIS_CURRENT_EFFECTIVE_START_DATE
                                and &BIS_CURRENT_ASOF_DATE';

    l_group_by := ' GROUP BY fact.chr_id, fact.trn_code, fact.customer_party_id, fact.resource_id';


     poa_dbi_util_pkg.Add_Column(
		 p_col_tbl	=> l_col_tbl
		,p_col_name	=> 'trn_billed_value_' || l_curr_suffix
		,p_alias_name	=> 't_bv'
		,p_prior_code    => poa_dbi_util_pkg.no_priors);

     poa_dbi_util_pkg.Add_Column(
		 p_col_tbl	=> l_col_tbl
		,p_col_name	=> 'price_negotiated_' || l_curr_suffix  ||' - trn_billed_value_' || l_curr_suffix
		,p_alias_name	=> 't_rv'
		,p_prior_code    => poa_dbi_util_pkg.no_priors);

    l_join_tbl := POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl();

    oki_dbi_util_pvt.join_rpt_where ( p_join_tbl     => l_join_tbl
                                    , p_func_area    => 'SRM'
                                    , p_version      => '6.0'
                                    , p_role         => NULL
                                    , p_mv_set       => 'SRM_DTL_RPT');

    oki_dbi_util_pvt.add_join_table (p_join_tbl            => l_join_tbl
                                  , p_column_name          => 'id'
                                  , p_table_name           => 'OKI_TERM_REASONS_V'
        			  , p_table_alias          => 'v'
                                  , p_fact_column          => 'trn_code'
                                  , p_additional_where_clause => NULL);


    l_filter_where  := ' ( abs(OKI_MEASURE_3) + abs(OKI_MEASURE_2) ) <> 0 ';


    l_query := Get_Trm_Dtl_Sel_Clause(l_curr_suffix, l_period_type)
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

    x_custom_sql := '/* OKI_DBI_SCM_TRM_DTL_RPT */ '||l_query;

    OKI_DBI_UTIL_PVT.Get_Custom_Status_Binds(x_custom_output);

  END Get_Terminations_Detail_Sql;



/******************************************************************
*  Procedure to return the query for Terminations TREND portlet
******************************************************************/
  PROCEDURE get_terminations_trend_sql(
	p_param			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	x_custom_sql		OUT NOCOPY	VARCHAR2,
	x_custom_output		OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  -- Variables associated with the parameter portlet
  l_query		VARCHAR2(32767);
  l_view_by		VARCHAR2(120);
  l_view_by_col		VARCHAR2(120);
  l_as_of_date		DATE;
  l_prev_as_of_date	DATE;
  l_xtd			VARCHAR2(10);
  l_comparison_type	VARCHAR2(1);
  l_nested_pattern	NUMBER;
  l_dim_bmap		NUMBER;
  l_cur_suffix		VARCHAR2(2);
  l_custom_sql		VARCHAR2(10000);

  l_col_tbl		POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl;
  l_join_tbl		POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl;

  l_period_code		VARCHAR2(1);
  l_where_clause	VARCHAR2(2000);
  l_mv			VARCHAR2(2000);

  BEGIN

    l_comparison_type := 'Y';
    l_join_tbl := POA_DBI_UTIL_PKG.Poa_Dbi_Join_Tbl();
    l_col_tbl := POA_DBI_UTIL_PKG.Poa_Dbi_Col_Tbl();

    OKI_DBI_UTIL_PVT.Process_Parameters(
	p_param			=> p_param,
	p_view_by		=> l_view_by,
	p_view_by_col_name	=> l_view_by_col,
	p_comparison_type	=> l_comparison_type,
	p_xtd			=> l_xtd,
	p_as_of_date		=> l_as_of_date,
	p_prev_as_of_date	=> l_prev_as_of_date,
	p_cur_suffix		=> l_cur_suffix,
	p_nested_pattern	=> l_nested_pattern,
	p_where_clause		=> l_where_clause,
	p_mv			=> l_mv,
	p_join_tbl		=> l_join_tbl,
	p_period_type		=> l_period_code,
	p_trend			=> 'Y',
	p_func_area		=> 'OKI',
	p_version		=> '7.0',
	p_role			=> NULL,
	p_mv_set		=> 'SRM_TM_71',
	p_rg_where		=> 'Y');

    POA_DBI_UTIL_PKG.Add_Column(
	p_col_tbl		=> l_col_tbl,
	p_col_name		=> 't_rv_amt_'||l_cur_suffix,
	p_alias_name		=> 't_rv',
	p_grand_total		=> 'N',
	p_to_date_type		=> 'XTD');

    l_query := Get_Trm_Trend_Sel_Clause||' FROM '
      ||POA_DBI_TEMPLATE_PKG.Trend_Sql(
		p_xtd			=> l_xtd,
		p_comparison_type	=> l_comparison_type,
		p_fact_name		=> l_mv,
		p_where_clause		=> l_where_clause,
		p_col_name		=> l_col_tbl,
		p_use_grpid		=> 'N');

    x_custom_sql := '/* OKI_DBI_SCM_TRM_GPH_RPT */ '||l_query;
    OKI_DBI_UTIL_PVT.Get_Custom_Trend_Binds(
	l_xtd,
	l_comparison_type,
	x_custom_output);

  END Get_Terminations_Trend_Sql;

/********************************************
* Terminations top SQL sel clause for TREND
*********************************************/

  FUNCTION Get_Trm_Trend_Sel_Clause RETURN VARCHAR2 IS
    l_sel_clause	VARCHAR2(10000);

  BEGIN

   --OKI_MEASURE_1: Total Terminated Value
    l_sel_clause := '
SELECT  cal.name		VIEWBY,
	nvl(iset.c_t_rv,0)	OKI_MEASURE_1,
	nvl(iset.p_t_rv,0)	OKI_PMEASURE_1,
	'||OKI_DBI_UTIL_PVT.Change_Clause('nvl(iset.c_t_rv,0)','nvl(iset.p_t_rv,0)','NP')||'	OKI_CHANGE_1';

    RETURN l_sel_clause;
  END Get_Trm_Trend_Sel_Clause;


  END ;


/
