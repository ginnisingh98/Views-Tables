--------------------------------------------------------
--  DDL for Package BIX_PMV_EMC_CPM_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_PMV_EMC_CPM_PRTLT_PKG" AUTHID CURRENT_USER AS
/*$Header: bixecpmp.pls 115.0 2002/12/21 03:15:09 anasubra noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_custom_sql         OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  );

END  BIX_PMV_EMC_CPM_PRTLT_PKG;

 

/
