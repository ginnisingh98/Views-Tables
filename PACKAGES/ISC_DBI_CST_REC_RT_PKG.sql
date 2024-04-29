--------------------------------------------------------
--  DDL for Package ISC_DBI_CST_REC_RT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_CST_REC_RT_PKG" AUTHID CURRENT_USER AS
/*$Header: ISCRGBTS.pls 120.0 2005/05/25 17:15:36 appldev noship $*/
   /* Report Query for Freight Cost Recovery Rate */
   PROCEDURE get_tbl_sql(
       p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );


END ISC_DBI_CST_REC_RT_PKG;

 

/
