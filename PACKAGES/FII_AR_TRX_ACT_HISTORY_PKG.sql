--------------------------------------------------------
--  DDL for Package FII_AR_TRX_ACT_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_TRX_ACT_HISTORY_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBITAHS.pls 120.0.12000000.1 2007/02/23 02:29:14 applrt ship $ */


PROCEDURE get_trx_act_history (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        trx_act_history_sql             OUT NOCOPY VARCHAR2,
        trx_act_history_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_AR_TRX_ACT_HISTORY_PKG;

 

/
