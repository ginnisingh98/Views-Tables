--------------------------------------------------------
--  DDL for Package BIX_PMV_EMC_ORR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_PMV_EMC_ORR_RPT_PKG" AUTHID CURRENT_USER AS
/*$Header: bixeorrs.pls 115.1 2003/11/22 01:46:38 djambula noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text         OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  );

END  BIX_PMV_EMC_ORR_RPT_PKG;

 

/
