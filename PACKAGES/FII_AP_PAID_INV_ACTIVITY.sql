--------------------------------------------------------
--  DDL for Package FII_AP_PAID_INV_ACTIVITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_PAID_INV_ACTIVITY" AUTHID CURRENT_USER AS
/* $Header: FIIAPS2S.pls 115.1 2003/06/24 19:52:27 djanaswa ship $ */

   PROCEDURE GET_PAID_INV
       (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       paid_invoice_sql out NOCOPY VARCHAR2,
       paid_invoice_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

   PROCEDURE GET_PAID_INV_DISCOUNT
     ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       paid_invoice_sql out NOCOPY VARCHAR2,
       paid_invoice_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
END;

 

/
