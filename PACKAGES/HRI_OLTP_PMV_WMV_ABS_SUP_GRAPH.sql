--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_ABS_SUP_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_ABS_SUP_GRAPH" 
/* $Header: hriopwabst.pkh 120.0 2005/09/22 07:31 cbridge noship $ */
AUTHID CURRENT_USER AS

PROCEDURE GET_SQL
  (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
   x_custom_sql         OUT NOCOPY VARCHAR2,
   x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END HRI_OLTP_PMV_WMV_ABS_SUP_GRAPH ;

 

/
