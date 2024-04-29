--------------------------------------------------------
--  DDL for Package BIL_TX_OPTY_DETL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_TX_OPTY_DETL_RPT_PKG" AUTHID CURRENT_USER AS
/* $Header: biltxods.pls 120.0 2005/09/14 10:44 syeddana noship $ */

PROCEDURE OPP_DETL_TAB( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                       ,x_custom_sql    OUT NOCOPY VARCHAR2
                       ,x_custom_attr   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE OPP_FLEX_TAB(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                      ,x_custom_sql    OUT NOCOPY VARCHAR2
                      ,x_custom_attr   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE PRODUCTS_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                         ,x_custom_sql         OUT  NOCOPY VARCHAR2
                         ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE SALES_TEAM_TAB (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                         ,x_custom_sql         OUT  NOCOPY VARCHAR2
                         ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE PARTNER_TAB (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                       ,x_custom_sql    OUT NOCOPY VARCHAR2
                       ,x_custom_attr   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE CONTACTS_TAB (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                       ,x_custom_sql    OUT NOCOPY VARCHAR2
                       ,x_custom_attr   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE PROPOSAL_TAB (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                       ,x_custom_sql    OUT NOCOPY VARCHAR2
                       ,x_custom_attr   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


PROCEDURE QUOTE_TAB (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql    OUT NOCOPY VARCHAR2
                    ,x_custom_attr   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


PROCEDURE PROJECTS_TAB (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql    OUT NOCOPY VARCHAR2
                    ,x_custom_attr   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE TASKS_TAB (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql    OUT NOCOPY VARCHAR2
                    ,x_custom_attr   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE ATTACHMENTS_TAB (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql    OUT NOCOPY VARCHAR2
                    ,x_custom_attr   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE NOTES_TAB (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql    OUT NOCOPY VARCHAR2
                    ,x_custom_attr   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END BIL_TX_OPTY_DETL_RPT_PKG;

 

/
