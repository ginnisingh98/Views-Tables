--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_SAL_CTR_SUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_SAL_CTR_SUP" AUTHID CURRENT_USER AS
/* $Header: hriopwsc.pkh 120.0 2005/05/29 07:38:54 appldev noship $ */

/* Default Number of Top Countries to display in the portlet*/
g_no_countries_to_show   PLS_INTEGER := 10;

    PROCEDURE GET_SQL2(
       p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql  OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   ) ;

END HRI_OLTP_PMV_WMV_SAL_CTR_SUP;

 

/
