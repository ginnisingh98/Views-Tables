--------------------------------------------------------
--  DDL for Package FII_PSI_BUD_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PSI_BUD_SUM_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIPSIB1S.pls 120.1 2005/10/30 05:05:54 appldev noship $ */


PROCEDURE get_bud_sum (
  p_page_parameter_tbl	IN BIS_PMV_PAGE_PARAMETER_TBL,
  bud_sum_sql 		OUT NOCOPY VARCHAR2,
  bud_sum_output 	OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_bud_sum_port (
  p_page_parameter_tbl	IN BIS_PMV_PAGE_PARAMETER_TBL,
  bud_sum_sql 		OUT NOCOPY VARCHAR2,
  bud_sum_output 	OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_PSI_BUD_SUM_PKG;

-- End of package


 

/
