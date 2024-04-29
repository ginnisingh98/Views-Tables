--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AI_ORR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AI_ORR_RPT_PKG" AS
/*$Header: bixiorrr.plb 120.1 2006/03/28 22:58:32 pubalasu noship $ */

FUNCTION GET_ZERONULL_CLAUSE RETURN VARCHAR2
IS
    l_zeronull_clause VARCHAR2(1500);
BEGIN
    l_zeronull_clause:=') WHERE (nvl(BIX_PMV_AI_COUNT,0)+nvl(BIX_PMV_AI_COUNTCHANGE,0))<>0';
    return l_zeronull_clause;
EXCEPTION
WHEN OTHERS THEN
NULL;
END GET_ZERONULL_CLAUSE;


FUNCTION GET_MEASURES RETURN VARCHAR2
IS
    l_measure_txt VARCHAR2(32000);
    l_unknown VARCHAR2(50);

BEGIN

/*
pubalasu:
Get Measures for this report does not use the get_simple_measure, get_Divided
measure of Util Package because the format for measures in this report is
a,sum(a) and not sum(a),sum(sum(a)) over()
*/


l_measure_txt:=
        'SELECT outcome_code BIX_PMV_AI_OUTCOME,
         NVL(result_code,:l_unknown) BIX_PMV_AI_RESULT
         ,NVL(reason_code,:l_unknown) BIX_PMV_AI_REASON
         ,NVL(c_count,0) BIX_PMV_AI_COUNT
         ,sum(nvl(c_count,0)) over() BIX_PMV_TOTAL1
         ,(NVL(c_count,0)*100/decode(c_counttot,0,null,c_counttot)) BIX_PMV_AI_PERTOTAL1
         ,(c_count*100/decode(c_counttot,0,null,c_counttot)) -
        (p_count*100/decode(p_counttot,0,null,p_counttot)) BIX_PMV_AI_COUNTCHANGE
          FROM
        (';

RETURN l_measure_txt;

END GET_MEASURES;

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS
  l_sqltext            VARCHAR2(32000) ;
  l_func_area CONSTANT varchar2(5)  := 'IORRR';
  l_version varchar2(3)             := NULL;
  l_mv_set CONSTANT varchar2(3)     := 'ITM';
  l_where_clause       VARCHAR2(1000) ;
  l_filter_where       VARCHAR2(1000) ;
  l_mv                 VARCHAR2 (240);
  l_comp_type	       VARCHAR2(500) ;
  l_xtd			       VARCHAR2(500) ;
  l_view_by			   VARCHAR2 (120);
  l_view_by_select     VARCHAR2(500) ;



  l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_col_tbl                poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_timetype CONSTANT varchar2(3)   := 'XTD';


BEGIN


l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
l_col_tbl                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();
p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();


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


/* pubalasu:Process parameters returns the correct where clause, mv for the query */
/* pubalasu:Add columns to the select list of the innermost query */
 poa_dbi_util_pkg.add_column(
                                p_col_tbl           => l_col_tbl
                                , p_col_name        => 'AGENTCALL_ORR_COUNT'
                                , p_grand_total     => 'N'
                                , p_alias_name      => 'count'
                                , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
                                , p_to_date_type    => l_timetype
                               );
l_sqltext:= poa_dbi_template_pkg.status_sql (
                                p_fact_name           => l_mv
                                , p_where_clause      => l_where_clause
                                , p_filter_where      => l_filter_where
                                , p_join_tables       => l_join_tbl
                                , p_use_windowing     => 'N'
                                , p_col_name          => l_col_tbl
                                , p_use_grpid         => 'N'
                                , p_paren_count       => 3
                                , p_generate_viewby   => 'N'
                                );



l_Sqltext:=
            'SELECT * FROM
            (
            '
            ||
            GET_MEASURES
            ||
            '
            (
            select outcome_id,result_id,reason_id,c_count,p_count,
            sum(c_count) over(partition by outcome_id) c_counttot,
            sum(p_count) over(partition by outcome_id) p_counttot
            from
            '
            ||l_sqltext
            || ',' || bix_pmv_dbi_utl_pkg.get_orr_views
            ||get_zeronull_clause

            ;

p_sql_text:=l_sqltext;
bix_pmv_dbi_utl_pkg.get_bind_vars (p_custom_output,p_func_area => l_func_area);



EXCEPTION
WHEN OTHERS THEN
NULL;
END GET_SQL;
END  BIX_PMV_AI_ORR_RPT_PKG;



/
