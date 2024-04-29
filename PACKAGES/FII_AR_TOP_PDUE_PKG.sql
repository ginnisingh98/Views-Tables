--------------------------------------------------------
--  DDL for Package FII_AR_TOP_PDUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_TOP_PDUE_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBITPDS.pls 120.0.12000000.1 2007/02/23 02:29:22 applrt ship $ */

PROCEDURE get_top_pdue_cst(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
top_pdue_cst_sql out NOCOPY VARCHAR2, top_pdue_cst_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END fii_ar_top_pdue_pkg;

 

/
