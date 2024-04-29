--------------------------------------------------------
--  DDL for Package FII_AR_REC_AGING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_REC_AGING_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARDBIRAS.pls 120.1.12000000.1 2007/02/23 02:28:46 applrt ship $ */

-- Procedure for the Past Due Receviables Aging Summary report
PROCEDURE get_pastdue_rec_aging
  (p_page_parameter_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
   p_pastdue_rec_aging_sql    OUT NOCOPY VARCHAR2,
   p_pastdue_rec_aging_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- Procedure for the Receviables Aging Summary report
PROCEDURE get_rec_aging
  (p_page_parameter_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL,
   p_pastdue_rec_aging_sql    OUT NOCOPY VARCHAR2,
   p_pastdue_rec_aging_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END FII_AR_REC_AGING_PKG;


 

/
