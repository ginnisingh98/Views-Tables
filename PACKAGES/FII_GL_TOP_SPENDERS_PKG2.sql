--------------------------------------------------------
--  DDL for Package FII_GL_TOP_SPENDERS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_TOP_SPENDERS_PKG2" AUTHID CURRENT_USER AS
/* $Header: FIIGLC4S.pls 115.1 2003/12/26 22:01:51 juding noship $ */

PROCEDURE get_top_spenders (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
top_spenders_sql out NOCOPY VARCHAR2, top_spenders_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_top_spenders_drilldown (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,top_spenders_drilldown_sql out NOCOPY VARCHAR2, top_spenders_drilldown_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END fii_gl_top_spenders_pkg2;

 

/
