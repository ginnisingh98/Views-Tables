--------------------------------------------------------
--  DDL for Package FII_AR_COLL_EFF_IND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_COLL_EFF_IND_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBICEIS.pls 120.1.12000000.1 2007/02/23 02:27:59 applrt ship $ */

PROCEDURE get_coll_eff_index(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
coll_eff_sql out NOCOPY VARCHAR2, coll_eff_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


PROCEDURE get_coll_eff(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
coll_eff_sql out NOCOPY VARCHAR2, coll_eff_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_coll_eff_trend(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
coll_eff_trend_sql out NOCOPY VARCHAR2, coll_eff_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END fii_ar_coll_eff_ind_pkg;

 

/
