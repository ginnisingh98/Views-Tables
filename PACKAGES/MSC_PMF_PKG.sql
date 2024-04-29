--------------------------------------------------------
--  DDL for Package MSC_PMF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_PMF_PKG" AUTHID CURRENT_USER as
/* $Header: MSCXPMFS.pls 115.1 2002/03/18 13:31:01 pkm ship        $ */

/* deprecated - no need to call this anymore */
procedure process_pmf_thresholds;

/* this api is used for both seeded as well as user-defined exceptions */
function get_threshold(p_exception_type in number,
                       p_company_id in number,
		       p_company_site_id in number,
		       p_inventory_item_id in number,
		       p_supplier_id in number,
		       p_supplier_site_id in number,
		       p_customer_id in number,
		       p_customer_site_id in number,
		       p_excp_time in date)
		       return number;


end MSC_PMF_PKG;

 

/
