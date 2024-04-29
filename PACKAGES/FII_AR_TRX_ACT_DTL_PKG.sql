--------------------------------------------------------
--  DDL for Package FII_AR_TRX_ACT_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_TRX_ACT_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBITADS.pls 120.0.12000000.1 2007/02/23 02:29:10 applrt ship $ */

PROCEDURE get_trx_act_dtl(
	p_page_parameter_tbl			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	p_trx_act_dtl_sql			OUT NOCOPY	VARCHAR2,
	p_trx_act_dtl_output			OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
);

END fii_ar_trx_act_dtl_pkg;


 

/
