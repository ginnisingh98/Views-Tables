--------------------------------------------------------
--  DDL for Package FII_GL_REV_PROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_REV_PROD" AUTHID CURRENT_USER AS
/* $Header: FIIGLRPS.pls 115.4 2003/12/26 22:01:57 juding noship $ */


-- modified by kim
  PROCEDURE get_rev_by_prod(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
  rev_by_prod_sql out NOCOPY VARCHAR2, rev_by_prod_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END fii_gl_rev_prod;

 

/
