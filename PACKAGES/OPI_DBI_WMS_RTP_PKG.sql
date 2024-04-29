--------------------------------------------------------
--  DDL for Package OPI_DBI_WMS_RTP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WMS_RTP_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDRWMSRTPS.pls 120.0 2005/05/24 18:08:26 appldev noship $ */
   /* Report Receipt to Putaway Cycle Time */


   PROCEDURE get_tbl_sql1(
       p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );

   /* Report Receipt to Putaway Cycle Time Trend */
   PROCEDURE get_trd_sql(
       p_param in BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );


END opi_dbi_wms_rtp_pkg;

 

/
