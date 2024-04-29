--------------------------------------------------------
--  DDL for Package ISC_DBI_OT_ARR_RT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_OT_ARR_RT_PKG" AUTHID CURRENT_USER AS
/*$Header: ISCRGBWS.pls 120.0 2005/05/25 17:25:55 appldev noship $*/
   /* Report Query for On-Time Arrival Rate Report */
   PROCEDURE get_tbl_sql(
       p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );


END ISC_DBI_OT_ARR_RT_PKG;

 

/
