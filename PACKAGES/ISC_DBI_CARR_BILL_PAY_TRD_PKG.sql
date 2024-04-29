--------------------------------------------------------
--  DDL for Package ISC_DBI_CARR_BILL_PAY_TRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_CARR_BILL_PAY_TRD_PKG" AUTHID CURRENT_USER AS
/*$Header: ISCRGC4S.pls 120.0 2005/05/25 17:23:26 appldev noship $*/

   /* Trend Query for Carrier Billing and Payment Trend */
   PROCEDURE get_trd_sql(
       p_param in BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );


END ISC_DBI_CARR_BILL_PAY_TRD_PKG;

 

/
