--------------------------------------------------------
--  DDL for Package Body INVADPT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVADPT1" as
/* $Header: INVADPTB.pls 120.1 2005/07/01 11:47:34 appldev ship $ */

procedure update_adjustments (
	v_orgid mtl_parameters.organization_id%TYPE,
	v_physinvid mtl_physical_inventories.physical_inventory_id%TYPE,
	v_adjid mtl_physical_adjustments.adjustment_id%TYPE,
	v_last_updated_by mtl_physical_adjustments.last_updated_by%TYPE,
	v_adj_count_quantity mtl_physical_adjustments.count_quantity%TYPE)
is
begin

	update mtl_physical_adjustments
	set last_update_date = sysdate,
	last_updated_by = nvl(last_updated_by, -1),
	count_quantity = v_adj_count_quantity,
	adjustment_quantity = nvl(v_adj_count_quantity,nvl(system_quantity,0))
				- nvl(system_quantity,0),
	approval_status = null,
	approved_by_employee_id = null
	where adjustment_id = v_adjid
	and physical_inventory_id = v_physinvid
	and organization_id = v_orgid;

	commit;

end update_adjustments;

end INVADPT1;

/
