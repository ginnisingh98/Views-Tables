--------------------------------------------------------
--  DDL for Package FII_GL_CUMUL_REV_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_CUMUL_REV_TREND_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIGLCGS.pls 115.0 2004/01/08 13:09:54 hpoddar noship $ */
PROCEDURE get_cumul_rev(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
cumul_rev_sql out NOCOPY VARCHAR2, cumul_rev_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END fii_gl_cumul_rev_trend_pkg;

 

/
