--------------------------------------------------------
--  DDL for Package OPI_DBI_CC_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_CC_RPT_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDRICCAS.pls 115.1 2004/02/03 17:12:14 bthammin noship $ */
   /* Report Query for Cycle Count Accuracy */
   PROCEDURE get_tbl_sql(
       p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );

   /* Report Query for Cycle Count Accuracy Trend */
   PROCEDURE get_trd_sql(
       p_param in BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );

   /* Report Query for Hit/Miss Summary */
   PROCEDURE get_hm_tbl_sql(
       p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );

   /* Report Query for Cycle Count Adjustment Summary */
   PROCEDURE get_adj_tbl_sql(
       p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );

   /* Report Query for Cycle Count Adjustment Detail */
   PROCEDURE get_adj_dtl_sql(
       p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );

END opi_dbi_cc_rpt_pkg;

 

/
