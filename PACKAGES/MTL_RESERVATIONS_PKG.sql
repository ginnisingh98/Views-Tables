--------------------------------------------------------
--  DDL for Package MTL_RESERVATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_RESERVATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: INVRSV6S.pls 120.2 2006/09/20 11:27:23 bradha ship $ */

-- INV CONV
-- Add columns to signatures as follows:
--   secondary_uom_code
--   secondary_uom_id
--   secondary_reservation_quantity
--   secondary_detailed_quantity
PROCEDURE INSERT_ROW (
   x_rowid                          IN OUT NOCOPY VARCHAR2
  ,x_reservation_id                 IN OUT NOCOPY NUMBER
  ,x_requirement_date               IN     DATE
  ,x_organization_id                IN     NUMBER
  ,x_inventory_item_id              IN     NUMBER
  ,x_demand_source_type_id          IN     NUMBER
  ,x_demand_source_name             IN     VARCHAR2
  ,x_demand_source_header_id        IN     NUMBER
  ,x_demand_source_line_id          IN     NUMBER
  ,x_demand_source_delivery         IN     NUMBER
  ,x_primary_uom_code               IN     VARCHAR2
  ,x_primary_uom_id                 IN     NUMBER
  ,x_secondary_uom_code             IN     VARCHAR2
  ,x_secondary_uom_id               IN     NUMBER
  ,x_reservation_uom_code           IN     VARCHAR2
  ,x_reservation_uom_id             IN     NUMBER
  ,x_reservation_quantity           IN     NUMBER
  ,x_primary_reservation_quantity   IN     NUMBER
  ,x_second_reservation_quantity    IN     NUMBER
  ,x_detailed_quantity              IN     NUMBER
  ,x_secondary_detailed_quantity    IN     NUMBER
  ,x_autodetail_group_id            IN     NUMBER
  ,x_external_source_code           IN     VARCHAR2
  ,x_external_source_line_id        IN     NUMBER
  ,x_supply_source_type_id          IN     NUMBER
  ,x_supply_source_header_id        IN     NUMBER
  ,x_supply_source_line_id          IN     NUMBER
  ,x_supply_source_line_detail      IN     NUMBER
  ,x_supply_source_name             IN     VARCHAR2
  ,x_revision                       IN     VARCHAR2
  ,x_subinventory_code              IN     VARCHAR2
  ,x_subinventory_id                IN     NUMBER
  ,x_locator_id                     IN     NUMBER
  ,x_lot_number                     IN     VARCHAR2
  ,x_lot_number_id                  IN     NUMBER
  ,x_serial_number                  IN     VARCHAR2
  ,x_serial_number_id               IN     NUMBER
  ,x_partial_quantities_allowed     IN     NUMBER
  ,x_auto_detailed                  IN     NUMBER
  ,x_pick_slip_number               IN     NUMBER
  ,x_lpn_id                         IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_last_updated_by                IN     NUMBER
  ,x_creation_date                  IN     DATE
  ,x_created_by                     IN     NUMBER
  ,x_last_update_login              IN     NUMBER
  ,x_request_id                     IN     NUMBER
  ,x_program_application_id         IN     NUMBER
  ,x_program_id                     IN     NUMBER
  ,x_program_update_date            IN     DATE
  ,x_attribute_category             IN     VARCHAR2
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  ,x_ship_ready_flag                IN     NUMBER
  );

PROCEDURE LOCK_ROW (
   x_reservation_id                 IN     NUMBER
  ,x_requirement_date               IN     DATE
  ,x_organization_id                IN     NUMBER
  ,x_inventory_item_id              IN     NUMBER
  ,x_demand_source_type_id          IN     NUMBER
  ,x_demand_source_name             IN     VARCHAR2
  ,x_demand_source_header_id        IN     NUMBER
  ,x_demand_source_line_id          IN     NUMBER
  ,x_demand_source_delivery         IN     NUMBER
  ,x_primary_uom_code               IN     VARCHAR2
  ,x_primary_uom_id                 IN     NUMBER
  ,x_secondary_uom_code             IN     VARCHAR2
  ,x_secondary_uom_id               IN     NUMBER
  ,x_reservation_uom_code           IN     VARCHAR2
  ,x_reservation_uom_id             IN     NUMBER
  ,x_reservation_quantity           IN     NUMBER
  ,x_primary_reservation_quantity   IN     NUMBER
  ,x_second_reservation_quantity    IN     NUMBER
  ,x_detailed_quantity              IN     NUMBER
  ,x_secondary_detailed_quantity    IN     NUMBER
  ,x_autodetail_group_id            IN     NUMBER
  ,x_external_source_code           IN     VARCHAR2
  ,x_external_source_line_id        IN     NUMBER
  ,x_supply_source_type_id          IN     NUMBER
  ,x_supply_source_header_id        IN     NUMBER
  ,x_supply_source_line_id          IN     NUMBER
  ,x_supply_source_line_detail      IN     NUMBER
  ,x_supply_source_name             IN     VARCHAR2
  ,x_revision                       IN     VARCHAR2
  ,x_subinventory_code              IN     VARCHAR2
  ,x_subinventory_id                IN     NUMBER
  ,x_locator_id                     IN     NUMBER
  ,x_lot_number                     IN     VARCHAR2
  ,x_lot_number_id                  IN     NUMBER
  ,x_serial_number                  IN     VARCHAR2
  ,x_serial_number_id               IN     NUMBER
  ,x_partial_quantities_allowed     IN     NUMBER
  ,x_auto_detailed                  IN     NUMBER
  ,x_pick_slip_number               IN     NUMBER
  ,x_lpn_id                         IN     NUMBER
  ,x_request_id                     IN     NUMBER
  ,x_program_application_id         IN     NUMBER
  ,x_program_id                     IN     NUMBER
  ,x_program_update_date            IN     DATE
  ,x_attribute_category             IN     VARCHAR2
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  ,x_ship_ready_flag                IN     NUMBER
  );

PROCEDURE UPDATE_ROW (
   x_reservation_id                 IN     NUMBER
  ,x_requirement_date               IN     DATE
  ,x_organization_id                IN     NUMBER
  ,x_inventory_item_id              IN     NUMBER
  ,x_demand_source_type_id          IN     NUMBER
  ,x_demand_source_name             IN     VARCHAR2
  ,x_demand_source_header_id        IN     NUMBER
  ,x_demand_source_line_id          IN     NUMBER
  ,x_demand_source_delivery         IN     NUMBER
  ,x_primary_uom_code               IN     VARCHAR2
  ,x_primary_uom_id                 IN     NUMBER
  ,x_secondary_uom_code             IN     VARCHAR2
  ,x_secondary_uom_id               IN     NUMBER
  ,x_reservation_uom_code           IN     VARCHAR2
  ,x_reservation_uom_id             IN     NUMBER
  ,x_reservation_quantity           IN     NUMBER
  ,x_primary_reservation_quantity   IN     NUMBER
  ,x_second_reservation_quantity    IN     NUMBER
  ,x_detailed_quantity              IN     NUMBER
  ,x_secondary_detailed_quantity    IN     NUMBER
  ,x_autodetail_group_id            IN     NUMBER
  ,x_external_source_code           IN     VARCHAR2
  ,x_external_source_line_id        IN     NUMBER
  ,x_supply_source_type_id          IN     NUMBER
  ,x_supply_source_header_id        IN     NUMBER
  ,x_supply_source_line_id          IN     NUMBER
  ,x_supply_source_line_detail      IN     NUMBER
  ,x_supply_source_name             IN     VARCHAR2
  ,x_revision                       IN     VARCHAR2
  ,x_subinventory_code              IN     VARCHAR2
  ,x_subinventory_id                IN     NUMBER
  ,x_locator_id                     IN     NUMBER
  ,x_lot_number                     IN     VARCHAR2
  ,x_lot_number_id                  IN     NUMBER
  ,x_serial_number                  IN     VARCHAR2
  ,x_serial_number_id               IN     NUMBER
  ,x_partial_quantities_allowed     IN     NUMBER
  ,x_auto_detailed                  IN     NUMBER
  ,x_pick_slip_number               IN     NUMBER
  ,x_lpn_id                         IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_login              IN     NUMBER
  ,x_request_id                     IN     NUMBER
  ,x_program_application_id         IN     NUMBER
  ,x_program_id                     IN     NUMBER
  ,x_program_update_date            IN     DATE
  ,x_attribute_category             IN     VARCHAR2
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  ,x_ship_ready_flag                IN     NUMBER
  );

PROCEDURE INSERT_ROW (
   x_rowid                          IN OUT NOCOPY VARCHAR2
  ,x_reservation_id                 IN OUT NOCOPY NUMBER
  ,x_requirement_date               IN     DATE
  ,x_organization_id                IN     NUMBER
  ,x_inventory_item_id              IN     NUMBER
  ,x_demand_source_type_id          IN     NUMBER
  ,x_demand_source_name             IN     VARCHAR2
  ,x_demand_source_header_id        IN     NUMBER
  ,x_demand_source_line_id          IN     NUMBER
  ,x_demand_source_delivery         IN     NUMBER
  ,x_primary_uom_code               IN     VARCHAR2
  ,x_primary_uom_id                 IN     NUMBER
  ,x_secondary_uom_code             IN     VARCHAR2
  ,x_secondary_uom_id               IN     NUMBER
  ,x_reservation_uom_code           IN     VARCHAR2
  ,x_reservation_uom_id             IN     NUMBER
  ,x_reservation_quantity           IN     NUMBER
  ,x_primary_reservation_quantity   IN     NUMBER
  ,x_second_reservation_quantity    IN     NUMBER
  ,x_detailed_quantity              IN     NUMBER
  ,x_secondary_detailed_quantity    IN     NUMBER
  ,x_autodetail_group_id            IN     NUMBER
  ,x_external_source_code           IN     VARCHAR2
  ,x_external_source_line_id        IN     NUMBER
  ,x_supply_source_type_id          IN     NUMBER
  ,x_supply_source_header_id        IN     NUMBER
  ,x_supply_source_line_id          IN     NUMBER
  ,x_supply_source_line_detail      IN     NUMBER
  ,x_supply_source_name             IN     VARCHAR2
  ,x_revision                       IN     VARCHAR2
  ,x_subinventory_code              IN     VARCHAR2
  ,x_subinventory_id                IN     NUMBER
  ,x_locator_id                     IN     NUMBER
  ,x_lot_number                     IN     VARCHAR2
  ,x_lot_number_id                  IN     NUMBER
  ,x_serial_number                  IN     VARCHAR2
  ,x_serial_number_id               IN     NUMBER
  ,x_partial_quantities_allowed     IN     NUMBER
  ,x_auto_detailed                  IN     NUMBER
  ,x_pick_slip_number               IN     NUMBER
  ,x_lpn_id                         IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_last_updated_by                IN     NUMBER
  ,x_creation_date                  IN     DATE
  ,x_created_by                     IN     NUMBER
  ,x_last_update_login              IN     NUMBER
  ,x_request_id                     IN     NUMBER
  ,x_program_application_id         IN     NUMBER
  ,x_program_id                     IN     NUMBER
  ,x_program_update_date            IN     DATE
  ,x_attribute_category             IN     VARCHAR2
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  ,x_ship_ready_flag                IN     NUMBER
  ,x_staged_flag                    IN     VARCHAR2
  /**** {{ R12 Enhanced reservations code changes }}****/
  , x_crossdock_flag                IN     VARCHAR2
  , x_crossdock_criteria_id         IN     NUMBER
  , x_demand_source_line_detail     IN     NUMBER
  , x_serial_reservation_quantity   IN     NUMBER
  , x_supply_receipt_date           IN     DATE
  , x_demand_ship_date              IN     DATE
  , x_project_id                    IN     NUMBER
  , x_task_id                       IN     NUMBER
  , x_orig_supply_type_id    IN     NUMBER
  , x_orig_supply_header_id  IN     NUMBER
  , x_orig_supply_line_id    IN     NUMBER
  , x_orig_supply_line_detail IN    NUMBER
  , x_orig_demand_type_id    IN     NUMBER
  , x_orig_demand_header_id  IN     NUMBER
  , x_orig_demand_line_id    IN     NUMBER
  , x_orig_demand_line_detail IN    NUMBER
  /*** End R12 ***/
  );

PROCEDURE LOCK_ROW (
   x_reservation_id                 IN     NUMBER
  ,x_requirement_date               IN     DATE
  ,x_organization_id                IN     NUMBER
  ,x_inventory_item_id              IN     NUMBER
  ,x_demand_source_type_id          IN     NUMBER
  ,x_demand_source_name             IN     VARCHAR2
  ,x_demand_source_header_id        IN     NUMBER
  ,x_demand_source_line_id          IN     NUMBER
  ,x_demand_source_delivery         IN     NUMBER
  ,x_primary_uom_code               IN     VARCHAR2
  ,x_primary_uom_id                 IN     NUMBER
  ,x_secondary_uom_code             IN     VARCHAR2
  ,x_secondary_uom_id               IN     NUMBER
  ,x_reservation_uom_code           IN     VARCHAR2
  ,x_reservation_uom_id             IN     NUMBER
  ,x_reservation_quantity           IN     NUMBER
  ,x_primary_reservation_quantity   IN     NUMBER
  ,x_second_reservation_quantity    IN     NUMBER
  ,x_detailed_quantity              IN     NUMBER
  ,x_secondary_detailed_quantity    IN     NUMBER
  ,x_autodetail_group_id            IN     NUMBER
  ,x_external_source_code           IN     VARCHAR2
  ,x_external_source_line_id        IN     NUMBER
  ,x_supply_source_type_id          IN     NUMBER
  ,x_supply_source_header_id        IN     NUMBER
  ,x_supply_source_line_id          IN     NUMBER
  ,x_supply_source_line_detail      IN     NUMBER
  ,x_supply_source_name             IN     VARCHAR2
  ,x_revision                       IN     VARCHAR2
  ,x_subinventory_code              IN     VARCHAR2
  ,x_subinventory_id                IN     NUMBER
  ,x_locator_id                     IN     NUMBER
  ,x_lot_number                     IN     VARCHAR2
  ,x_lot_number_id                  IN     NUMBER
  ,x_serial_number                  IN     VARCHAR2
  ,x_serial_number_id               IN     NUMBER
  ,x_partial_quantities_allowed     IN     NUMBER
  ,x_auto_detailed                  IN     NUMBER
  ,x_pick_slip_number               IN     NUMBER
  ,x_lpn_id                         IN     NUMBER
  ,x_request_id                     IN     NUMBER
  ,x_program_application_id         IN     NUMBER
  ,x_program_id                     IN     NUMBER
  ,x_program_update_date            IN     DATE
  ,x_attribute_category             IN     VARCHAR2
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  ,x_ship_ready_flag                IN     NUMBER
  ,x_staged_flag                    IN     VARCHAR2
  /**** {{ R12 Enhanced reservations code changes }}****/
  , x_crossdock_flag                IN     VARCHAR2
  , x_crossdock_criteria_id         IN     NUMBER
  , x_demand_source_line_detail     IN     NUMBER
  , x_serial_reservation_quantity   IN     NUMBER
  , x_supply_receipt_date           IN     DATE
  , x_demand_ship_date              IN     DATE
  , x_project_id                    IN     NUMBER
  , x_task_id                       IN     NUMBER
  , x_orig_supply_type_id    IN     NUMBER
  , x_orig_supply_header_id  IN     NUMBER
  , x_orig_supply_line_id    IN     NUMBER
  , x_orig_supply_line_detail IN    NUMBER
  , x_orig_demand_type_id    IN     NUMBER
  , x_orig_demand_header_id  IN     NUMBER
  , x_orig_demand_line_id    IN     NUMBER
  , x_orig_demand_line_detail IN    NUMBER
   /*** End R12 ***/
  );

PROCEDURE UPDATE_ROW (
   x_reservation_id                 IN     NUMBER
  ,x_requirement_date               IN     DATE
  ,x_organization_id                IN     NUMBER
  ,x_inventory_item_id              IN     NUMBER
  ,x_demand_source_type_id          IN     NUMBER
  ,x_demand_source_name             IN     VARCHAR2
  ,x_demand_source_header_id        IN     NUMBER
  ,x_demand_source_line_id          IN     NUMBER
  ,x_demand_source_delivery         IN     NUMBER
  ,x_primary_uom_code               IN     VARCHAR2
  ,x_primary_uom_id                 IN     NUMBER
  ,x_secondary_uom_code             IN     VARCHAR2
  ,x_secondary_uom_id               IN     NUMBER
  ,x_reservation_uom_code           IN     VARCHAR2
  ,x_reservation_uom_id             IN     NUMBER
  ,x_reservation_quantity           IN     NUMBER
  ,x_primary_reservation_quantity   IN     NUMBER
  ,x_second_reservation_quantity    IN     NUMBER
  ,x_detailed_quantity              IN     NUMBER
  ,x_secondary_detailed_quantity    IN     NUMBER
  ,x_autodetail_group_id            IN     NUMBER
  ,x_external_source_code           IN     VARCHAR2
  ,x_external_source_line_id        IN     NUMBER
  ,x_supply_source_type_id          IN     NUMBER
  ,x_supply_source_header_id        IN     NUMBER
  ,x_supply_source_line_id          IN     NUMBER
  ,x_supply_source_line_detail      IN     NUMBER
  ,x_supply_source_name             IN     VARCHAR2
  ,x_revision                       IN     VARCHAR2
  ,x_subinventory_code              IN     VARCHAR2
  ,x_subinventory_id                IN     NUMBER
  ,x_locator_id                     IN     NUMBER
  ,x_lot_number                     IN     VARCHAR2
  ,x_lot_number_id                  IN     NUMBER
  ,x_serial_number                  IN     VARCHAR2
  ,x_serial_number_id               IN     NUMBER
  ,x_partial_quantities_allowed     IN     NUMBER
  ,x_auto_detailed                  IN     NUMBER
  ,x_pick_slip_number               IN     NUMBER
  ,x_lpn_id                         IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_login              IN     NUMBER
  ,x_request_id                     IN     NUMBER
  ,x_program_application_id         IN     NUMBER
  ,x_program_id                     IN     NUMBER
  ,x_program_update_date            IN     DATE
  ,x_attribute_category             IN     VARCHAR2
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  ,x_ship_ready_flag                IN     NUMBER
  ,x_staged_flag                    IN     VARCHAR2
   /**** {{ R12 Enhanced reservations code changes }}****/
  , x_crossdock_flag                IN     VARCHAR2
  , x_crossdock_criteria_id         IN     NUMBER
  , x_demand_source_line_detail     IN     NUMBER
  , x_serial_reservation_quantity   IN     NUMBER
  , x_supply_receipt_date           IN     DATE
  , x_demand_ship_date              IN     DATE
  , x_project_id                    IN     NUMBER
  , x_task_id                       IN     NUMBER
  /*** End R12 ***/
  );

PROCEDURE DELETE_ROW (
		      x_reservation_id   IN   NUMBER
		     ,x_to_reservation_id IN NUMBER DEFAULT NULL

  );
END MTL_RESERVATIONS_PKG;

 

/
