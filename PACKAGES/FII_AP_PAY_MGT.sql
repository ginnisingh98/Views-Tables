--------------------------------------------------------
--  DDL for Package FII_AP_PAY_MGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_PAY_MGT" AUTHID CURRENT_USER AS
/* $Header: FIIAPPMS.pls 115.4 2003/10/03 19:21:22 djanaswa noship $ */
  PROCEDURE get_hold_cat_graph (
        p_page_parameter_tbl           IN  BIS_PMV_PAGE_PARAMETER_TBL,
        inv_graph_sql                  OUT NOCOPY VARCHAR2,
        inv_graph_output               OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE get_late_ontime_payment (
        p_page_parameter_tbl           IN  BIS_PMV_PAGE_PARAMETER_TBL,
        inv_graph_sql                  OUT NOCOPY VARCHAR2,
        inv_graph_output               OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE get_elec_late_payment (
        p_page_parameter_tbl            IN  BIS_PMV_PAGE_PARAMETER_TBL,
        elec_late_payment_sql        OUT NOCOPY VARCHAR2,
        elec_late_payment_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE get_inv_graph (
        p_page_parameter_tbl           IN  BIS_PMV_PAGE_PARAMETER_TBL,
        inv_graph_sql                  OUT NOCOPY VARCHAR2,
        inv_graph_output               OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE get_kpi (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        kpi_sql                 OUT NOCOPY VARCHAR2,
        kpi_output              OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_AP_PAY_MGT;

 

/
