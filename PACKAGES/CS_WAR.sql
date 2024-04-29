--------------------------------------------------------
--  DDL for Package CS_WAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_WAR" AUTHID CURRENT_USER as
/* $Header: csxcuwas.pls 120.0 2005/08/01 12:34:13 smisra noship $ */
--
--
	--Get the comma-separated item_ids of the attached warranties on an item,
	--as on p_war_date. The Item-Validation-Organization of the attached
	--warranty is the same as the item's.
	--Note: Used by CSOEBAT and CSXSUDCP form as of 1/29/97.
	function get_war_item_ids
	(
		p_organization_id   number,
		p_inventory_item_id number,
		p_war_date          date    default sysdate
	) return varchar2;
	--pragma RESTRICT_REFERENCES (get_war_item_ids,WNDS,WNPS);
	--
	--
	-- This function returns Y or N for warranty attached to a customer
     -- product_id
	function warranty_exists
	(
	    cp_id  NUMBER
     )  return VARCHAR2 ;
	pragma RESTRICT_REFERENCES (warranty_exists,WNDS,WNPS);
	--
	--
	--Get the duration, period and coverage of a warranty on a product, as on
	--p_war_date.
	--The Item-Validation-Organization of the attached
	--warranty is the same as the product's.
	--It is upto the caller to ensure that the warranty is a valid warranty
	--on the product, else an exception NO_DATA_FOUND is raised.
	procedure get_war_dur_per
	(
		p_organization_id   number,
		p_prod_inv_item_id  number,
		p_war_inv_item_id   number,
		p_war_date          date    default sysdate,
		p_duration   in out nocopy number,
		p_uom_code   in out nocopy varchar2,
		p_cov_sch_id in out nocopy number
	);
	--
	--
--
--
end cs_war;

 

/
