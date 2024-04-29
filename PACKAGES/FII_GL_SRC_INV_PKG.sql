--------------------------------------------------------
--  DDL for Package FII_GL_SRC_INV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_SRC_INV_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIGLSRS.pls 115.8 2003/12/26 22:01:58 juding noship $ */

  PROCEDURE get_exp_source (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  exp_source_sql out NOCOPY VARCHAR2, exp_source_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL, fin_type IN VARCHAR2);
  PROCEDURE get_inv_exp_det (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  inv_exp_det_sql out NOCOPY VARCHAR2, inv_exp_det_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE get_inv_rev_det (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  inv_rev_det_sql out NOCOPY VARCHAR2, inv_rev_det_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE fii_drill_across (pSource IN varchar2,
                              pCategory IN varchar2, pCostCenter IN varchar2, pMonth IN varchar2,
                              pCurrency IN varchar2, pManager IN varchar2, pAsOfDateValue IN varchar2, pLOB IN varchar2);

  PROCEDURE get_rev_src (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, rev_src_sql out NOCOPY VARCHAR2, rev_src_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE get_exp_src (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, exp_src_sql out NOCOPY VARCHAR2, exp_src_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  PROCEDURE get_cogs_src (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, cogs_src_sql out NOCOPY VARCHAR2, cogs_src_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END fii_gl_src_inv_pkg;

 

/
