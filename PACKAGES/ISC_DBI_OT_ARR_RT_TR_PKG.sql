--------------------------------------------------------
--  DDL for Package ISC_DBI_OT_ARR_RT_TR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_OT_ARR_RT_TR_PKG" AUTHID CURRENT_USER AS
/*$Header: ISCRGBXS.pls 120.0 2005/05/25 17:39:17 appldev noship $*/

   /* Report Query for On-Time Arrival Rate Trend */
   PROCEDURE get_trd_sql(
       p_param in BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );


END ISC_DBI_OT_ARR_RT_TR_PKG;

 

/
