--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_TOPCUST_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_TOPCUST_PRTLT_PKG" AS
/*$Header: bixetcvp.plb 115.20 2003/12/15 19:05:09 djambula noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_custom_sql         OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS
l_sqltext	      VARCHAR2(32000) ;
l_as_of_date   DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_agent_cost     NUMBER;
l_dummy_cust     NUMBER;
l_comp_type    varchar2(2000);
l_account      varchar2(32000);
l_sql_errm      varchar2(32000);
l_where  varchar2(32000);
l_others_string VARCHAR2(100);
l_unident_string VARCHAR2(100);
l_subtotal_string VARCHAR2(100);
l_application_id NUMBER := 680;

l_custom_rec BIS_QUERY_ATTRIBUTES := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

BEGIN
NULL;

EXCEPTION
WHEN OTHERS THEN
NULL;
END GET_SQL;
END  BIX_PMV_EMC_TOPCUST_PRTLT_PKG;

/
