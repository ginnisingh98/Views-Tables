--------------------------------------------------------
--  DDL for Package INVADPT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVADPT1" AUTHID CURRENT_USER as
/* $Header: INVADPTS.pls 120.0 2005/05/25 05:05:49 appldev noship $ */

procedure update_adjustments (
	v_orgid mtl_parameters.organization_id%TYPE,
	v_physinvid mtl_physical_inventories.physical_inventory_id%TYPE,
	v_adjid mtl_physical_adjustments.adjustment_id%TYPE,
	v_last_updated_by mtl_physical_adjustments.last_updated_by%TYPE,
	v_adj_count_quantity mtl_physical_adjustments.count_quantity%TYPE);

end INVADPT1;

 

/
