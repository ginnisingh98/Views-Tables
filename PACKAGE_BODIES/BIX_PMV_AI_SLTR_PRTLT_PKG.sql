--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AI_SLTR_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AI_SLTR_PRTLT_PKG" AS
/*$Header: bixisltp.plb 120.0 2005/05/25 17:21:30 appldev noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_custom_sql         OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS

p_cols poa_dbi_util_pkg.poa_dbi_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
bix_col_tab      poa_dbi_util_pkg.poa_dbi_col_tbl     := poa_dbi_util_pkg.poa_dbi_col_tbl()    ;
poa_in_join_tab  poa_dbi_util_pkg.poa_dbi_in_join_tbl := poa_dbi_util_pkg.poa_dbi_IN_join_tbl();

l_join_tbl               poa_dbi_util_pkg.poa_dbi_join_tbl;

l_where_clause               VARCHAR2(32000);
l_mv                         VARCHAR2(32000);
l_dummy                      VARCHAR2(32000);
l_view_by_select             VARCHAR2(32000);

l_sqltext	             VARCHAR2(32000);
l_sqltext1	             VARCHAR2(32000);
l_as_of_date                 DATE;
l_period_type	             VARCHAR2(2000);
l_record_type_id             NUMBER;
l_comp_type                  VARCHAR2(50);
l_sql_errm                   VARCHAR2(32000);
l_dim_map                    poa_dbi_util_pkg.poa_dbi_dim_map;
l_previous_report_start_date DATE;
l_current_report_start_date  DATE;
l_previous_as_of_date        DATE;
l_period_type_id             NUMBER;
l_nested_pattern             NUMBER;
l_dim_bmap                   NUMBER;
l_curr_suffix                VARCHAR2(20);
l_time_id_column             VARCHAR2(1000);
l_goal                       NUMBER;
l_call_center                VARCHAR2(3000);
l_classification             VARCHAR2(3000);
l_dnis                       VARCHAR2(3000);
l_view_by                    VARCHAR2(3000);
l_xtd                        VARCHAR2(3);

l_call_where_clause          VARCHAR2(3000);
l_errmsg                     VARCHAR2(1000);
l_session_where_clause       VARCHAR2(3000);
l_union_all_text             VARCHAR2(32000);



l_custom_rec BIS_QUERY_ATTRIBUTES := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

BEGIN
--
--Initialize p_custom_output
--
p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

     bix_pmv_dbi_utl_pkg.process_parameters(
                      p_param           => p_page_parameter_tbl
                     ,p_trend	        => 'Y'
                     ,p_func_area	=> 'ITMAT'
                     ,p_version         => '6.0'
                     ,p_mv_set          => 'ITM'
                     ,p_where_clause    => l_where_clause
                     ,p_mv              => l_mv
                     ,p_join_tbl        => l_join_tbl
                     ,p_comp_type       => l_comp_type
                     ,p_xtd            => l_xtd
                     ,p_view_by_select  => l_view_by_select
                     ,p_view_by         => l_dummy);



  poa_dbi_util_pkg.add_column(bix_col_tab,'call_calls_offered_total','offrd' ,'N',2,'XTD');
  poa_dbi_util_pkg.add_column(bix_col_tab,'agent_calls_answered_by_goal','ansgoal' ,'N',2,'XTD');


  --Columns, for which sum is not to be taken, pass them as 0.

  poa_dbi_util_pkg.add_column(p_cols,'call_cont_calls_offered_na'    ,'offrd','N',2,'XTD');
  poa_dbi_util_pkg.add_column(p_cols,'0'     ,'ansgoal','N',2,'XTD');


   l_union_all_text := 'UNION ALL '||bix_pmv_dbi_utl_pkg.get_continued_measures
                          (p_bix_col_tab => p_cols,
                           p_where_clause => l_where_clause,
                           p_xtd  => l_xtd,
                           p_comparison_type => l_comp_type,
                           p_mv_set => 'ITM');

   IF (FND_PROFILE.DEFINED('BIX_CALL_SLGOAL_PERCENT')) THEN
      l_goal := TO_NUMBER(FND_PROFILE.VALUE('BIX_CALL_SLGOAL_PERCENT'));
   ELSE
      l_goal := 0;
   END IF;

   l_where_clause := l_where_clause || ' AND    fact.media_item_type IN (''TELE_INB'', ''TELE_DIRECT'') ';

BEGIN

   l_sqltext := 'SELECT name VIEWBY,
                        SUM(p_ansgoal)*100/DECODE(SUM(p_offrd),0,null,SUM(p_offrd))           BIX_PMV_AI_PREVSL,
                        SUM(curr_ansgoal)*100/DECODE(SUM(curr_offrd),0,null,SUM(curr_offrd))  BIX_PMV_AI_SL,
                        ' || l_goal ||'                           BIX_PMV_AI_SLGOAL
                 FROM '||'(SELECT iset.*,cal.start_date st_date,cal.name
                           FROM '||
                           bix_pmv_dbi_utl_pkg.trend_sql
                                   (p_xtd             => l_xtd,
                                    p_comparison_type => l_comp_type,
                                    p_fact_name       => l_mv,
                                    p_where_clause    => l_where_clause,
                                    p_col_name        => bix_col_tab,
                                    p_use_grpid       => 'N',
                                    p_in_join_tables  => NULL,
                                    p_fact_hint       => NULL,
                                    p_union_clause    =>l_union_all_text )||'
                           ) GROUP BY  name ,st_date order by st_date ';

EXCEPTION
WHEN OTHERS THEN
    l_errmsg := SQLERRM;
END;


 p_custom_sql := l_sqltext;


 poa_dbi_util_pkg.get_custom_trend_binds (p_xtd             => l_xtd
                                         ,p_comparison_type => l_comp_type
                                         ,x_custom_output   => p_custom_output);

 bix_pmv_dbi_utl_pkg.get_bind_vars (x_custom_output  => p_custom_output
                                   ,p_func_area      => NULL);

    EXCEPTION
      WHEN OTHERS THEN
      l_sql_errm := SQLERRM;

END GET_SQL;
END BIX_PMV_AI_SLTR_PRTLT_PKG;

/
