--------------------------------------------------------
--  DDL for Package ISC_DBI_CARR_BILL_PAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_CARR_BILL_PAY_PKG" AUTHID CURRENT_USER AS
/*$Header: ISCRGC3S.pls 120.0 2005/05/25 17:23:44 appldev noship $*/

   /*----------------------------------------
    Carrier Billing and Payment Variance Report Function
    ----------------------------------------*/
    PROCEDURE get_tbl_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql OUT NOCOPY VARCHAR2,
                           x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END ISC_DBI_CARR_BILL_PAY_PKG;

 

/
