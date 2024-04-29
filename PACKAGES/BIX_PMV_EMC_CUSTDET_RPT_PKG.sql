--------------------------------------------------------
--  DDL for Package BIX_PMV_EMC_CUSTDET_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_PMV_EMC_CUSTDET_RPT_PKG" AUTHID CURRENT_USER AS
/*$Header: bixecd1r.pls 115.0 2003/01/14 00:14:40 anasubra noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                 );

END  BIX_PMV_EMC_CUSTDET_RPT_PKG;

 

/
