--------------------------------------------------------
--  DDL for Package INV_RESERVATION_AVAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RESERVATION_AVAIL_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVRVAS.pls 120.2.12010000.2 2013/02/01 05:59:04 brana ship $*/

-- Procedure
--   available_supply_to_reserve
-- Description
--   This procedure returns the available quantity to reserve for a particular
--   supply line, for which a reservation is either intended to be created or
--   modified.  The API will call the get_available_supply_demand API to get
--   the current availability at the document level, query all the existing
--   reservations for this supply line and return the difference which would
--   be the available supply to reserve.  At the same time, the available
--   quantity at the document level will also be returned through this API.
-- Input Parameters
--   p_api_version_number
--     API version number
--   p_init_msg_list
--     Whether initialize the error message list or not
--     Should be fnd_api.g_false or fnd_api.g_true
--   p_organization_id
--     organization id for the document to be validated.
--   p_item_id
--     inventory item id of the document to be validated.
--   p_revision
--     revision of the item
--   p_lot_number
--     lot number of the item
--   p_subinventory_code
--     subinventory code
--   p_locator_id
--     locator id of the subinventory if the subinventory is locator controlled
--   p_supply_source_type_id
--     the supply type for which the availability is to be checked
--   p_supply_source_header_id
--     the header information of the supply document for which the availability
--     is to be checked
--   p_supply_source_line_id
--     the line information of the supply document for which the availability
--     is to be checked
--   p_supply_source_line_detail
--     the line detial information of the supply document for which the
--     availability is to be checked
--   p_lpn_id
--     the lpn for the supply document for which the availability is going
--     to be computed
--   p_project_id
--     the project id for the demand document
--   p_task_id
--     the task id for the demand document
-- Output Parameters
--   x_return_status
--     return status indicating success, error, unexpected error
--   x_msg_count
--     number of messages in message list
--   x_msg_data
--     if the number of messages in message list is 1, contains
--     message text
--   x_qty_available_to_reserve
--     returns the total available quantity based on the input criteria
--   x_qty_available
--     returns the final available quantity on the document line for which
--     the reservation is being made

Procedure available_supply_to_reserve
  (
     p_api_version_number        IN  NUMBER DEFAULT 1.0
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_organization_id           IN  NUMBER DEFAULT NULL
   , p_item_id                   IN  NUMBER DEFAULT NULL
   , p_revision                  IN  VARCHAR2 DEFAULT NULL
   , p_lot_number                IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code         IN  VARCHAR2 DEFAULT NULL
   , p_locator_id                IN  NUMBER DEFAULT NULL
   , p_lpn_id                    IN  NUMBER DEFAULT fnd_api.g_miss_num
   , p_fm_supply_source_type_id  IN  NUMBER DEFAULT 0
   , p_supply_source_type_id     IN  NUMBER
   , p_supply_source_header_id   IN  NUMBER
   , p_supply_source_line_id     IN  NUMBER
   , p_supply_source_line_detail IN  NUMBER DEFAULT fnd_api.g_miss_num
   , p_project_id                IN  NUMBER DEFAULT NULL
   , p_task_id                   IN  NUMBER DEFAULT NULL
   , x_qty_available_to_reserve  OUT NOCOPY NUMBER
   , x_qty_available             OUT NOCOPY NUMBER
   );

-- Procedure
--   available_demand_to_reserve
-- Description
--   This procedure returns the available quantity to reserve for a particular
--   demand line, for which a reservation is either intended to be created or
--   modified.  The API will call the get_available_supply_demand API to get
--   the current availability at the document level, query all the existing
--   reservations for this supply line and return the difference which would
--   be the available supply to reserve.  At the same time, the available
--   quantity at the document level will also be returned through this API.
-- Input Parameters
--   p_api_version_number
--     API version number
--   p_init_msg_list
--     Whether initialize the error message list or not
--     Should be fnd_api.g_false or fnd_api.g_true
--   p_demand_source_type_id
--     the demand type for which the availability is to be checked
--   p_demand_source_header_id
--     the header information of the demand document for which the
--     availability is to be checked
--   p_demand_source_line_id
--     the line information of the demand document for which the
--     availability is to be checked
--   p_demand_source_line_detail
--     the line detail information of the demand document for which
--     the availability is to be checked
--   p_project_id
--     the project id for the demand document
--   p_task_id
--     the task id for the demand document
-- Output Parameters
--   x_return_status
--     return status indicating success, error, unexpected error
--   x_msg_count
--     number of messages in message list
--   x_msg_data
--     if the number of messages in message list is 1, contains
--     message text
--   x_qty_available_to_reserve
--     returns the total available quantity based on the input criteria
--   x_qty_available
--     returns the final available quantity on the document line for which
--     the reservation is being made

Procedure available_demand_to_reserve
  (
     p_api_version_number        IN  NUMBER DEFAULT 1.0
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_organization_id           IN  NUMBER DEFAULT NULL
   , p_item_id                   IN  NUMBER DEFAULT NULL
   , p_primary_uom_code          IN  VARCHAR2 DEFAULT NULL
   , p_demand_source_type_id     IN  NUMBER
   , p_demand_source_header_id   IN  NUMBER
   , p_demand_source_line_id     IN  NUMBER
   , p_demand_source_line_detail IN  NUMBER DEFAULT fnd_api.g_miss_num
   , p_project_id                IN  NUMBER DEFAULT NULL
   , p_task_id                   IN  NUMBER DEFAULT NULL
   , x_qty_available_to_reserve  OUT NOCOPY NUMBER
   , x_qty_available             OUT NOCOPY NUMBER
  );

--MUOM Fulfillment Project overloaded the Procedure
Procedure available_demand_to_reserve
  (
     p_api_version_number        IN  NUMBER DEFAULT 1.0
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_organization_id           IN  NUMBER DEFAULT NULL
   , p_item_id                   IN  NUMBER DEFAULT NULL
   , p_primary_uom_code          IN  VARCHAR2 DEFAULT NULL
   , p_demand_source_type_id     IN  NUMBER
   , p_demand_source_header_id   IN  NUMBER
   , p_demand_source_line_id     IN  NUMBER
   , p_demand_source_line_detail IN  NUMBER DEFAULT fnd_api.g_miss_num
   , p_project_id                IN  NUMBER DEFAULT NULL
   , p_task_id                   IN  NUMBER DEFAULT NULL
   , x_qty_available_to_reserve  OUT NOCOPY NUMBER
   , x_qty_available             OUT NOCOPY NUMBER
   , x_qty_available_to_reserve2  OUT NOCOPY NUMBER
   , x_qty_available2             OUT NOCOPY NUMBER
  );
END inv_reservation_avail_pvt;

/
