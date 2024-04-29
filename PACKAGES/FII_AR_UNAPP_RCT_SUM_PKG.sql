--------------------------------------------------------
--  DDL for Package FII_AR_UNAPP_RCT_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_UNAPP_RCT_SUM_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIURS.pls 120.0.12000000.1 2007/02/23 02:29:26 applrt ship $ */

PROCEDURE GET_UNAPP_RCT_SUM
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       unapp_rct_sql out NOCOPY VARCHAR2,
       unapp_rct_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END;

 

/
