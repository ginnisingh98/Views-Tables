--------------------------------------------------------
--  DDL for Package Body CS_WAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_WAR" as
/* $Header: csxcuwab.pls 120.0 2005/08/01 12:36:16 smisra noship $ */
--
--
/*******************************************************************************
********************************************************************************
	--
	--  Public Functions/procedures
	--
********************************************************************************
*******************************************************************************/
--
--
	--Get the comma-separated item_ids of the attached warranties on an item,
	--as on p_war_date. The Item-Validation-Organization of the attached
	--warranty is the same as the item's.
	function get_war_item_ids
	(
		p_organization_id   number,
		p_inventory_item_id number,
		p_war_date          date    default sysdate
	) return varchar2 is
	begin
		return(cs_std.get_war_item_ids(p_organization_id, p_inventory_item_id,
								p_war_date));
	end get_war_item_ids;
	--
	--
	-- This function returns Y or N for warranty attached to a customer
     -- product_id
	function warranty_exists
	(
	    cp_id  NUMBER
     )  return VARCHAR2 is
	begin
		return(cs_std.warranty_exists(cp_id));
	end warranty_exists;
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
	) is
		l_war_date		date;
		l_com_bill_seq_id	number;
	begin
		if p_organization_id is null or
		   p_prod_inv_item_id is null or
		   p_war_inv_item_id is null then
			raise NO_DATA_FOUND;
		end if;
		--
		l_war_date := nvl(p_war_date, sysdate);
		--
		select common_bill_sequence_id
		into l_com_bill_seq_id
		from bom_bill_of_materials
		where organization_id = p_organization_id
		and   assembly_item_id = p_prod_inv_item_id
		and   alternate_bom_designator is null;
		--
		-- BOM allows you to define the same component in the same bill
		-- at the same level twice as long as they differ either in the
		-- operation sequence (which doesnt make sense for warranties) or
		-- effectivity date range. Normally this shouldn't occur, but just
		-- in case it does, we pick any one.
		-- If for some reason the duration and period is not defined in the
		-- BOM, we look up the item master once ascertained that the warnty
		-- is indeed present on the product. This shouldnt really be
		-- necessary bcoz the BOM forms enforces the relevant data to be
		-- entered, but just in case.
		select bic.component_quantity, mtl.primary_uom_code,
			mtl.coverage_schedule_id
		into p_duration, p_uom_code, p_cov_sch_id
		from mtl_system_items mtl, bom_inventory_components bic
		where bic.component_item_id = mtl.inventory_item_id
		and   mtl.organization_id = p_organization_id
		and   bic.bill_sequence_id = l_com_bill_seq_id
		and   bic.component_item_id = p_war_inv_item_id
		and   l_war_date >= bic.effectivity_date
		and   l_war_date < nvl(bic.disable_date,l_war_date+1)
		and   mtl.vendor_warranty_flag = 'Y'
		and   rownum < 2;
		--
		if p_duration is null or
		   p_uom_code is null then
			select service_duration, service_duration_period_code,
				coverage_schedule_id
			into p_duration, p_uom_code, p_cov_sch_id
			from mtl_system_items
			where inventory_item_id = p_war_inv_item_id
			and   organization_id = p_organization_id;
		end if;
		--
		--
	end get_war_dur_per;
--
--
end cs_war;

/
