--------------------------------------------------------
--  DDL for Package FII_AR_DSO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_DSO_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIDSOS.pls 120.4.12000000.1 2007/02/23 02:28:11 applrt ship $ */

g_open_rec_column_dso	VARCHAR2(200);
g_open_rec_column_dsot	VARCHAR2(200);
g_hit_rct_aging		VARCHAR2(1);

FUNCTION get_dso_period_param RETURN VARCHAR2;

PROCEDURE get_dso(
	p_page_parameter_tbl			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	p_dso_sql				OUT NOCOPY	VARCHAR2,
	p_dso_output				OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
);

PROCEDURE get_dso_trend(
	p_page_parameter_tbl			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	p_dso_sql				OUT NOCOPY	VARCHAR2,
	p_dso_output				OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
);

END fii_ar_dso_pkg;


 

/
