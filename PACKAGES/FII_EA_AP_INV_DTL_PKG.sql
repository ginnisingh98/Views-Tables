--------------------------------------------------------
--  DDL for Package FII_EA_AP_INV_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EA_AP_INV_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIEAINVDETS.pls 120.1 2005/10/30 05:06:10 appldev noship $ */


-- Prcodeure, get_inv_detail generates PMV SQL which retrieves data for Invoice Detail Report

   PROCEDURE get_inv_detail

   ( 	p_page_parameter_tbl         IN  BIS_PMV_PAGE_PARAMETER_TBL
       ,p_invoice_detail_sql	     OUT NOCOPY VARCHAR2
       ,p_invoice_detail_output	     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   );

END FII_EA_AP_INV_DTL_PKG;

 

/
