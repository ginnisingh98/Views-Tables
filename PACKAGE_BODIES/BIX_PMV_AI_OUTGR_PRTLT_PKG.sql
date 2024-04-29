--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AI_OUTGR_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AI_OUTGR_PRTLT_PKG" AS
/*$Header: bixioutp.plb 120.0 2005/05/25 17:15:59 appldev noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_custom_sql         OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS
 l_sqltext		VARCHAR2(32000) ;
 l_where_clause		VARCHAR2(1000) ;
 l_mv			VARCHAR2 (240);
 l_view_by_select	VARCHAR2(500) ;
 l_comp_type				VARCHAR2(500) ;
 l_xtd						VARCHAR2(500) ;
 l_join_tbl		poa_dbi_util_pkg.poa_dbi_join_tbl;
 l_func_area		VARCHAR2(5);
 l_mv_set		VARCHAR2(3);
 l_version		VARCHAR2(3);
 l_timetype		VARCHAR2(3);
 l_filter_where         VARCHAR2 (2000);
 l_view_by		VARCHAR2(120);

BEGIN
 l_func_area	:= 'IOUTP';
 l_mv_set	:= 'ITM';
 l_version	:= NULL;
 l_timetype	:= 'XTD';

p_custom_output  := BIS_QUERY_ATTRIBUTES_TBL();

-- Get the parameters

l_join_tbl                 := poa_dbi_util_pkg.poa_dbi_join_tbl ();

bix_pmv_dbi_utl_pkg.process_parameters
( p_param               => p_page_parameter_tbl
, p_trend		=> 'N'
, p_func_area		=> l_func_area
, p_version             => l_version
, p_mv_set              => l_mv_set
, p_where_clause        => l_where_clause
, p_mv                  => l_mv
, p_join_tbl            => l_join_tbl
, p_comp_type           => l_comp_type
, p_xtd					=> l_xtd
, p_view_by_select      => l_view_by_select
, p_view_by		=> l_view_by
);

l_sqltext := '
         SELECT meaning BIX_PMV_AI_OUTCOME,
	           sum(pper) BIX_PMV_AI_PPER,
			 sum(cper) BIX_PMV_AI_CPER
         FROM (
             SELECT lookup.meaning meaning,
                    nvl(sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                           decode(lookup.lookup_code,
                                      ''SR'',   AGENT_SR_CREATED,
                                      ''LEAD'', AGENT_LEADS_CREATED,
                                      ''OPP'',  AGENT_OPPORTUNITIES_CREATED,
                                   0),
                     0)),0) PPER,
                    nvl(sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                           decode(lookup.lookup_code,
                                      ''SR'',   AGENT_SR_CREATED,
                                      ''LEAD'', AGENT_LEADS_CREATED,
                                      ''OPP'',  AGENT_OPPORTUNITIES_CREATED,
                                   0),
                     0)),0) CPER
              FROM bix_ai_call_details_mv fact,
                   fii_time_rpt_struct cal,
                   (
                    select lookup_code,meaning
                    from fnd_lookup_values_vl
                    where lookup_type = :l_lookup_type
                    ) lookup
              WHERE fact.time_id        = cal.time_id
              AND   fact.period_type_id = cal.period_type_id
              AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) =
                                        cal.record_type_id
              AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,
                                      &BIS_PREVIOUS_ASOF_DATE) ';

l_sqltext := l_sqltext || l_where_clause ||
             '
		    GROUP BY lookup.meaning
		    UNION ALL
		    SELECT meaning, 0, 0
		    from fnd_lookup_values_vl
		    where lookup_type = :l_lookup_type
		    )
           GROUP BY meaning '
                ;
p_custom_sql:=l_sqltext;
bix_pmv_dbi_utl_pkg.get_bind_vars (p_custom_output,p_func_area => l_func_area);


EXCEPTION
	WHEN OTHERS THEN
	RAISE;
END GET_SQL;
END BIX_PMV_AI_OUTGR_PRTLT_PKG;

/
