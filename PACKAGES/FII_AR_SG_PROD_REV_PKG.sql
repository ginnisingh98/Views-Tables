--------------------------------------------------------
--  DDL for Package FII_AR_SG_PROD_REV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_SG_PROD_REV_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARSGPRS.pls 115.1 2004/03/26 01:09:47 djanaswa noship $ */

PROCEDURE get_sg_prod_rev
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       get_sg_prod_rev_sql out NOCOPY VARCHAR2,
       get_sg_prod_rev_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END fii_ar_sg_prod_rev_pkg;

 

/
