--------------------------------------------------------
--  DDL for Package FII_EA_AP_TRAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EA_AP_TRAN_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIEAAPTS.pls 120.1 2005/10/30 05:12:53 appldev noship $ */

PROCEDURE GET_AP_TRAN
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       ap_tran_sql out NOCOPY VARCHAR2,
       ap_tran_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END;

 

/
