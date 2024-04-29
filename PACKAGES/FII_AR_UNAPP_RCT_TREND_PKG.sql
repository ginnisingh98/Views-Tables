--------------------------------------------------------
--  DDL for Package FII_AR_UNAPP_RCT_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_UNAPP_RCT_TREND_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIURTS.pls 120.1.12000000.1 2007/02/23 02:29:30 applrt ship $ */

PROCEDURE get_unapp_rct_trend (p_page_parameter_tbl      IN   BIS_PMV_PAGE_PARAMETER_TBL
                	      ,p_unapp_rct_trend_sql     OUT  NOCOPY VARCHAR2
			      ,p_unapp_rct_trend_output  OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END fii_ar_unapp_rct_trend_pkg;

 

/
