--------------------------------------------------------
--  DDL for Package FII_AR_PAID_REC_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_PAID_REC_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIPRDS.pls 120.0.12000000.1 2007/02/23 02:28:30 applrt ship $ */

PROCEDURE get_paid_rec_dtl(
	p_page_parameter_tbl			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	p_paid_rec_dtl_sql			OUT NOCOPY	VARCHAR2,
	p_paid_rec_dtl_output			OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
);

END fii_ar_paid_rec_dtl_pkg;


 

/
