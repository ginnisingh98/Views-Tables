--------------------------------------------------------
--  DDL for Package BIX_PMV_AI_ORR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_PMV_AI_ORR_RPT_PKG" AUTHID CURRENT_USER AS
/*$Header: bixiorrr.pls 120.1 2006/03/28 22:58:52 pubalasu noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text         OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  );

END  BIX_PMV_AI_ORR_RPT_PKG;



 

/