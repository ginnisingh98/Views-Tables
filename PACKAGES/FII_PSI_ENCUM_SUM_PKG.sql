--------------------------------------------------------
--  DDL for Package FII_PSI_ENCUM_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PSI_ENCUM_SUM_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIPSIENS.pls 120.1 2005/10/30 05:05:58 appldev noship $ */

PROCEDURE get_encum_sum(
	p_page_parameter_tbl			IN			BIS_PMV_PAGE_PARAMETER_TBL,
	p_enc_sum_sql					OUT NOCOPY	VARCHAR2,
	p_enc_sum_output				OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
);

PROCEDURE get_encum_sum_port(
	p_page_parameter_tbl			IN			BIS_PMV_PAGE_PARAMETER_TBL,
	p_enc_sum_sql					OUT NOCOPY	VARCHAR2,
	p_enc_sum_output				OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
);

END fii_psi_encum_sum_pkg;

 

/
