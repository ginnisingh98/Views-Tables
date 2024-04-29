--------------------------------------------------------
--  DDL for Package FII_AR_CURR_REC_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_CURR_REC_SUM_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBICRS.pls 120.0.12000000.1 2007/02/23 02:28:05 applrt ship $ */

PROCEDURE GET_CURR_REC_SUM
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       curr_rec_sql out NOCOPY VARCHAR2,
       curr_rec_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END;

 

/
