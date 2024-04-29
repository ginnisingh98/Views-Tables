--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_BCKT_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_BCKT_GRAPH" AUTHID CURRENT_USER AS
/* $Header: hriophrg.pkh 120.0 2005/05/29 07:33:05 appldev noship $ */

PROCEDURE get_sql_bckt_perf
      (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql          OUT NOCOPY VARCHAR2,
       x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_sql_bckt_low
      (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql          OUT NOCOPY VARCHAR2,
       x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END hri_oltp_pmv_wmv_bckt_graph;

 

/
