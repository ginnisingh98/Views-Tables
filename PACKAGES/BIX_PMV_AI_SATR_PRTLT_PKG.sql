--------------------------------------------------------
--  DDL for Package BIX_PMV_AI_SATR_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_PMV_AI_SATR_PRTLT_PKG" AUTHID CURRENT_USER AS
/*$Header: bixisoap.pls 115.1 2003/10/15 01:52:01 anasubra noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_custom_sql         OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  );
END BIX_PMV_AI_SATR_PRTLT_PKG;

 

/
