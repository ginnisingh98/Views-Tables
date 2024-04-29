--------------------------------------------------------
--  DDL for Package INV_LPN_RESERVATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LPN_RESERVATIONS_PVT" AUTHID CURRENT_USER as
/* $Header: INVRSVLS.pls 120.0.12010000.4 2010/09/13 09:01:46 avuppala ship $*/


--Create_LPN_Reservations
--
-- This API is designed to be called from the Reservations Form.
-- This procedure will create a separate reservation for each lot and
-- revision in that LPN.  The procedure assumes that the LPN passed as
-- a parameter is an innermost LPN.  Only material residing directly
-- within the given LPN, without a level of nesting, will be reserved.

PROCEDURE Create_LPN_Reservations
(
  x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
 ,p_organization_id IN NUMBER
 ,p_inventory_item_id IN NUMBER
 ,p_demand_source_type_id IN NUMBER
 ,p_demand_source_header_id IN NUMBER
 ,p_demand_source_line_id IN NUMBER
 ,p_demand_source_name IN VARCHAR2
 ,p_need_by_date IN DATE
 ,p_lpn_id IN NUMBER
);


--Transfer_LPN_Reservations
--
-- This API is designed to be called from the mobile subinventory transfer
-- and putaway forms.  This procedure will transfer all the reservations
-- for a given LPN from the current subinventory and locator to a new
-- subinventory and locator.  This is useful for moving reserved LPNs around
-- the warehouse.
PROCEDURE Transfer_LPN_Reservations
(
  x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
 ,p_organization_id IN NUMBER
 ,p_inventory_item_id IN NUMBER default NULL
 ,p_lpn_id IN NUMBER
 ,p_to_subinventory_code IN VARCHAR2
 ,p_to_locator_id IN NUMBER
 ,p_system_task_type  IN NUMBER default NULL --9794776
);


-- ER 7307189 changes start

PROCEDURE transfer_reserved_lpn_contents
(
  x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
 ,p_organization_id IN NUMBER
 ,p_inventory_item_id IN NUMBER default NULL
 ,p_lpn_id IN NUMBER
 ,p_transfer_lpn_id IN NUMBER
 ,p_to_subinventory_code IN VARCHAR2
 ,p_to_locator_id IN NUMBER
 , p_system_task_type     IN            NUMBER DEFAULT NULL -- 9794776
);

-- ER 7307189 changes end


END inv_lpn_reservations_pvt;

/
