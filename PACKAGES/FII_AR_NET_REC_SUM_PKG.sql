--------------------------------------------------------
--  DDL for Package FII_AR_NET_REC_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_NET_REC_SUM_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBINRS.pls 120.2.12000000.1 2007/02/23 02:28:19 applrt ship $ */

PROCEDURE get_net_rec_sum(
	p_page_parameter_tbl			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	p_net_rec_sum_sql			OUT NOCOPY	VARCHAR2,
	p_net_rec_sum_output			OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
);

END fii_ar_net_rec_sum_pkg;


 

/
