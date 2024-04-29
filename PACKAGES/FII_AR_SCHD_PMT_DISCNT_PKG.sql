--------------------------------------------------------
--  DDL for Package FII_AR_SCHD_PMT_DISCNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_SCHD_PMT_DISCNT_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBISPDS.pls 120.0.12000000.1 2007/02/23 02:29:00 applrt ship $ */

PROCEDURE get_schd_pmt_discnt (p_page_parameter_tbl      IN   BIS_PMV_PAGE_PARAMETER_TBL
                	      ,p_schd_pmt_discnt_sql     OUT  NOCOPY VARCHAR2
			      ,p_schd_pmt_discnt_output  OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END fii_ar_schd_pmt_discnt_pkg;

 

/
