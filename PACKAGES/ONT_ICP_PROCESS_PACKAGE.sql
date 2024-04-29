--------------------------------------------------------
--  DDL for Package ONT_ICP_PROCESS_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_ICP_PROCESS_PACKAGE" AUTHID CURRENT_USER as
/*  $Header: ONTPROCS.pls 120.4 2005/09/28 00:37:52 shewgupt ship $ */

/*Inventory Convergence OIP changes */
--Below procedures/functions obsoleted after inventory convergence project
/*
 function is_process_item(p_inventory_item_id in number,
                          p_ship_from_org_id in number) return number;
procedure is_process_installed (p_return out nocopy number) ;

 function get_itemid(p_organization_id IN  NUMBER ,
			p_inventory_item_id IN  NUMBER) return number;

 function get_lotid(p_inv_itemid IN  NUMBER,
		p_orgid IN NUMBER,
		p_lot_number IN  varchar2,
		p_sublot_number in varchar2) return number ; */

procedure dual_uom_and_grade_control
(
p_inventory_item_id IN NUMBER ,
p_ship_from_org_id IN NUMBER := FND_API.G_MISS_NUM ,
p_org_id IN NUMBER ,
x_dual_control_flag OUT NOCOPY VARCHAR2 ,
x_grade_control_flag OUT NOCOPY VARCHAR2,
x_wms_enabled_flag OUT NOCOPY VARCHAR2
) ;
/* end */

end ont_icp_process_package;

 

/
