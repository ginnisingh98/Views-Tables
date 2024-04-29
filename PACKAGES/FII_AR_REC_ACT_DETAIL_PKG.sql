--------------------------------------------------------
--  DDL for Package FII_AR_REC_ACT_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_REC_ACT_DETAIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIRADS.pls 120.0.12000000.1 2007/02/23 02:28:40 applrt ship $ */

-- Procedure for the Receipts Activity Detail report
PROCEDURE get_rec_act_detail
  (p_page_parameter_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
   p_rec_act_detail_sql       OUT NOCOPY VARCHAR2,
   p_rec_act_detail_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END FII_AR_REC_ACT_DETAIL_PKG;


 

/
