--------------------------------------------------------
--  DDL for Package BIX_PMV_AI_TELDTL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_PMV_AI_TELDTL_RPT_PKG" AUTHID CURRENT_USER AS
/*$Header: bixitelr.pls 115.0 2003/10/29 18:51:04 djambula noship $ */

  PROCEDURE GET_SQL(p_page_parameter_tbl IN         BIS_PMV_PAGE_PARAMETER_TBL,
                    p_sql_text           OUT NOCOPY VARCHAR2,
                    p_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                   );

END  BIX_PMV_AI_TELDTL_RPT_PKG;

 

/
