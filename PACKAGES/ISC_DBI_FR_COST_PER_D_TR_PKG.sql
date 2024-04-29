--------------------------------------------------------
--  DDL for Package ISC_DBI_FR_COST_PER_D_TR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_FR_COST_PER_D_TR_PKG" AUTHID CURRENT_USER AS
/*$Header: ISCRGC2S.pls 120.0 2005/05/25 17:19:25 appldev noship $*/
   /* Report Query for Freight Cost per Unit Distance Trend */
   PROCEDURE get_trd_sql(
       p_param in BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );


END ISC_DBI_FR_COST_PER_D_TR_PKG;

 

/
