--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_TRN_BCKT_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_TRN_BCKT_GRAPH" AUTHID CURRENT_USER AS
/* $Header: hrioptbg.pkh 120.0 2005/05/29 07:36:20 appldev noship $ */

PROCEDURE get_sql_bckt_perf
      (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql          OUT NOCOPY VARCHAR2,
       x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_sql_rnk_jfn_graph
     (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
      x_custom_sql          OUT NOCOPY VARCHAR2,
      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_sql_rnk_rsn_graph
       (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
        x_custom_sql          OUT NOCOPY VARCHAR2,
        x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END hri_oltp_pmv_trn_bckt_graph;

 

/
