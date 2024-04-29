--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_SUP_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_SUP_GRAPH" AUTHID CURRENT_USER AS
/* $Header: hriopbdg.pkh 120.1 2005/11/21 03:40:09 cbridge noship $ */

PROCEDURE GET_SQL2(
       p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql  OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   ) ;

END HRI_OLTP_PMV_WMV_SUP_GRAPH;

 

/
