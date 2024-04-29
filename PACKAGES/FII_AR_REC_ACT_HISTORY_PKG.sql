--------------------------------------------------------
--  DDL for Package FII_AR_REC_ACT_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_REC_ACT_HISTORY_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIRAHS.pls 120.0.12000000.1 2007/02/23 02:28:44 applrt ship $ */

-- Procedure for the Receipts Activity history report
PROCEDURE get_rec_act_history
  (p_page_parameter_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
   p_rec_act_detail_sql       OUT NOCOPY VARCHAR2,
   p_rec_act_detail_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END FII_AR_REC_ACT_HISTORY_PKG;


 

/
