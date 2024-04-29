--------------------------------------------------------
--  DDL for Package BIX_PMV_AO_TELDTL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_PMV_AO_TELDTL_RPT_PKG" AUTHID CURRENT_USER AS
/*$Header: bixotelr.pls 115.0 2004/01/29 12:23:35 pubalasu noship $ */

  PROCEDURE GET_SQL(p_page_parameter_tbl IN         BIS_PMV_PAGE_PARAMETER_TBL,
                    p_sql_text           OUT NOCOPY VARCHAR2,
                    p_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                   );

END  BIX_PMV_AO_TELDTL_RPT_PKG;


 

/
