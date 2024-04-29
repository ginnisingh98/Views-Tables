--------------------------------------------------------
--  DDL for Package BIX_PMV_EMC_BACK_ACT_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_PMV_EMC_BACK_ACT_RPT_PKG" AUTHID CURRENT_USER AS
/*$Header: bixebacr.pls 115.0 2002/12/30 21:18:19 djambula noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                 );

END  BIX_PMV_EMC_BACK_ACT_RPT_PKG;

 

/
