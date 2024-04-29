--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AI_CBMTGR_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AI_CBMTGR_PRTLT_PKG" AS
/*$Header: bixicmtp.plb 120.0 2005/05/25 17:22:50 appldev noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_custom_sql         OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS
 l_sqltext					VARCHAR2(32000) ;
 l_where_clause				VARCHAR2(1000) ;
 l_mv						VARCHAR2 (240);
 l_view_by_select			VARCHAR2(500) ;
 l_comp_type				VARCHAR2(500) ;
 l_xtd						VARCHAR2(500) ;
 l_view_by	    			VARCHAR2(120) ;
 l_col_tbl					poa_dbi_util_pkg.poa_dbi_col_tbl;
 l_join_tbl					poa_dbi_util_pkg.poa_dbi_join_tbl;
 l_func_area				CONSTANT VARCHAR2(5) := 'ICMTP';
 l_mv_set					CONSTANT VARCHAR2(3) := 'ITM';
 l_version					VARCHAR2(3):=NULL;
 l_timetype					CONSTANT VARCHAR2(3) := 'XTD';
 l_filter_where             VARCHAR2 (2000);

BEGIN

-- Get the parameters
p_custom_output  := BIS_QUERY_ATTRIBUTES_TBL();

l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();
l_col_tbl                  := poa_dbi_util_pkg.poa_dbi_col_tbl ();


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
										, p_view_by             => l_view_by
										);

-- Populate col table with regular columns

poa_dbi_util_pkg.add_column (p_col_tbl         => l_col_tbl
                               , p_col_name        => 'CALL_CALLS_HANDLED_TOTAL'
							   , p_grand_total     => 'N'
                               , p_alias_name      => 'HANDLED'
							   , p_prior_code      => poa_dbi_util_pkg.COL_PRIOR_ONLY
							   , p_to_date_type    => l_timetype
                               );

l_sqltext:= poa_dbi_template_pkg.status_sql (
										   p_fact_name         => l_mv
                                         , p_where_clause      => l_where_clause
                                         , p_filter_where      => l_filter_where
                                         , p_join_tables       => l_join_tbl
                                         , p_use_windowing     => 'N'
                                         , p_col_name          => l_col_tbl
                                         , p_use_grpid         => 'N'
                                         , p_paren_count       => 3
										 , p_generate_viewby   => 'N');

l_sqltext  :=' SELECT   decode(media_item_type, ''TELE_INB'',:l_inbound,''TELE_DIRECT'', :l_inbound,
               ''TELE_MANUAL'', :l_dialed,''TELE_WEB_CALLBACK'', :l_webcall,''UNSOLICITED'', :l_unsolicited,
               media_item_type) BIX_PMV_AI_MITYPE, nvl(sum(P_HANDLED),0) BIX_PMV_AI_PPER, nvl(sum(C_HANDLED),0) BIX_PMV_AI_CPER
			   from ((SELECT orderby orderby, name media_item_type,0 c_handled,0 p_handled FROM (
			   select 1 orderby, ''TELE_INB'' name from dual UNION ALL
			   select 2 orderby, ''TELE_DIRECT'' name from dual  UNION ALL
		       select 3 orderby, ''TELE_WEB_CALLBACK''name from dual UNION ALL
			   select 4 orderby, ''TELE_MANUAL'' name from dual  UNION ALL
			   select 5 orderby, ''UNSOLICITED'' name from dual ) types
			   )
			   UNION ALL (
			   select 0 orderby, media_item_type,c_handled, p_handled
			   from'||l_sqltext||
			   'GROUP BY decode(media_item_type, ''TELE_INB'',:l_inbound,''TELE_DIRECT'', :l_inbound,
			                  ''TELE_MANUAL'', :l_dialed,''TELE_WEB_CALLBACK'', :l_webcall,''UNSOLICITED'', :l_unsolicited,
						     media_item_type)
			   ORDER BY SUM(ORDERBY)';


p_custom_sql:=l_sqltext;
bix_pmv_dbi_utl_pkg.get_bind_vars (p_custom_output,p_func_area => l_func_area);

/*   l_sqltext := '
             SELECT mediatype BIX_PMV_AI_MITYPE,
		          nvl(sum(pper),0) BIX_PMV_AI_PPER,
				nvl(sum(cper),0) BIX_PMV_AI_CPER
             FROM (
                    SELECT 0 orderby,
				      decode(mv.media_item_type, ''TELE_INB'',:l_inbound,
                                               ''TELE_DIRECT'', :l_direct,
                                               ''TELE_MANUAL'', :l_dialed,
                                               ''TELE_WEB_CALLBACK'', :l_webcall,
                                               ''UNSOLICITED'', :l_unsolicited,
                                                mv.media_item_type) MEDIATYPE,
                           sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                               CALL_CALLS_OFFERED_TOTAL,0)) PPER,
                           sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                               CALL_CALLS_OFFERED_TOTAL,0)) CPER
                    FROM bix_ai_call_details_mv mv,
                         fii_time_rpt_struct cal
                    WHERE mv.time_id        = cal.time_id
		          AND mv.row_type = :l_row_type
                    AND   mv.period_type_id = cal.period_type_id
                    AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) =
                                        cal.record_type_id
                    AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,
                                      &BIS_PREVIOUS_ASOF_DATE) ';
l_sqltext := l_sqltext || l_call_where_clause ||
             '
		          GROUP BY mv.media_item_type
		          UNION ALL
		          SELECT orderby orderby, name MEDIATYPE,
		           0 PPER,
				 0 CPER
                    FROM (select 1 orderby, :l_inbound name from dual UNION ALL
		                select 2 orderby, :l_direct name from dual  UNION ALL
				      select 3 orderby, :l_webcall name from dual UNION ALL
				      select 4 orderby, :l_manual name from dual  UNION ALL
				      select 5 orderby, :l_unsolicited name from dual
				      ) types
			   )	GROUP BY mediatype ORDER BY sum(orderby) ' ;


*/
EXCEPTION
	WHEN OTHERS THEN
		RAISE;
END GET_SQL;
END BIX_PMV_AI_CBMTGR_PRTLT_PKG;

/
