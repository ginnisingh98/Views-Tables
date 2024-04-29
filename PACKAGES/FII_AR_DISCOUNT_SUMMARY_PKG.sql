--------------------------------------------------------
--  DDL for Package FII_AR_DISCOUNT_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_DISCOUNT_SUMMARY_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIDSUMS.pls 120.0.12000000.1 2007/02/23 02:28:15 applrt ship $ */

PROCEDURE get_discount_summary(p_page_parameter_tbl      IN   BIS_PMV_PAGE_PARAMETER_TBL
                	      ,p_discount_summary_sql    OUT  NOCOPY VARCHAR2
			      ,p_discount_summary_output OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END fii_ar_discount_summary_pkg;

 

/
