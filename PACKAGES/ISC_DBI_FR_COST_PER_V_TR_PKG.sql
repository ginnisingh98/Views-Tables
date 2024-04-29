--------------------------------------------------------
--  DDL for Package ISC_DBI_FR_COST_PER_V_TR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_FR_COST_PER_V_TR_PKG" AUTHID CURRENT_USER AS
/*$Header: ISCRGC0S.pls 120.0 2005/05/25 17:33:34 appldev noship $*/
   /* Report Query for Freight Cost per Unit Volume Trend */
   PROCEDURE get_trd_sql(
       p_param in BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );


END ISC_DBI_FR_COST_PER_V_TR_PKG;

 

/
