--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_CLASS_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_CLASS_RPT_PKG" AS
/*$Header: bixeclar.plb 115.5 2003/12/15 19:05:07 djambula noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS
l_sqltext	      VARCHAR2(32000) ;
l_where_clause        VARCHAR2(1000) ;
l_as_of_date   DATE;
l_period_type	varchar2(2000);
l_comp_type    varchar2(2000);
l_sql_errm      varchar2(32000);
l_agent_cost      NUMBER := 0;
l_cust_resp_time_goal NUMBER;
l_service_level_goal  NUMBER;
l_custom_rec       BIS_QUERY_ATTRIBUTES;
l_period_type_id   NUMBER := 1;
l_record_type_id   NUMBER;
l_account      VARCHAR2(32000);
l_start_date   DATE;
l_end_date     DATE;
l_period_from  DATE;
l_period_to    DATE;
l_max_collect_date   VARCHAR2(100);
l_period_start_date  DATE;
BEGIN
NULL;
EXCEPTION
WHEN OTHERS THEN
NULL;
END GET_SQL;
END  BIX_PMV_EMC_CLASS_RPT_PKG;

/
