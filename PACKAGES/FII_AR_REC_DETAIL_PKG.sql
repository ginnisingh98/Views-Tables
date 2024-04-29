--------------------------------------------------------
--  DDL for Package FII_AR_REC_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_REC_DETAIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIRDS.pls 120.0.12000000.1 2007/02/23 02:28:50 applrt ship $ */

-- Procedure for the Receipts Detail report
PROCEDURE get_rec_detail
  (p_page_parameter_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
   p_pastdue_rec_aging_sql    OUT NOCOPY VARCHAR2,
   p_pastdue_rec_aging_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- Procedure for the Receipt Balances Detail report
PROCEDURE get_rec_bal_detail
  (p_page_parameter_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
   p_pastdue_rec_aging_sql    OUT NOCOPY VARCHAR2,
   p_pastdue_rec_aging_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END FII_AR_REC_DETAIL_PKG;


 

/
