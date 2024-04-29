--------------------------------------------------------
--  DDL for Package Body MTL_RESERVATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_RESERVATIONS_PKG" AS
/* $Header: INVRSV6B.pls 120.2 2006/09/20 11:26:07 bradha ship $ */
-- INVCONV
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
  )IS
BEGIN
 INSERT_ROW (
   x_rowid                          =>     x_rowid
  ,x_reservation_id                 =>     x_reservation_id
  ,x_requirement_date               =>     x_requirement_date
  ,x_organization_id                =>     x_organization_id
  ,x_inventory_item_id              =>     x_inventory_item_id
  ,x_demand_source_type_id          =>     x_demand_source_type_id
  ,x_demand_source_name             =>     x_demand_source_name
  ,x_demand_source_header_id        =>     x_demand_source_header_id
  ,x_demand_source_line_id          =>     x_demand_source_line_id
  ,x_demand_source_delivery         =>     x_demand_source_delivery
  ,x_primary_uom_code               =>     x_primary_uom_code
  ,x_primary_uom_id                 =>     x_primary_uom_id
  ,x_secondary_uom_code             =>     x_secondary_uom_code
  ,x_secondary_uom_id               =>     x_secondary_uom_id
  ,x_reservation_uom_code           =>     x_reservation_uom_code
  ,x_reservation_uom_id             =>     x_reservation_uom_id
  ,x_reservation_quantity           =>     x_reservation_quantity
  ,x_primary_reservation_quantity   =>     x_primary_reservation_quantity
  ,x_second_reservation_quantity    =>     x_second_reservation_quantity
  ,x_detailed_quantity              =>     x_detailed_quantity
  ,x_secondary_detailed_quantity    =>     x_secondary_detailed_quantity
  ,x_autodetail_group_id            =>     x_autodetail_group_id
  ,x_external_source_code           =>     x_external_source_code
  ,x_external_source_line_id        =>     x_external_source_line_id
  ,x_supply_source_type_id          =>     x_supply_source_type_id
  ,x_supply_source_header_id        =>     x_supply_source_header_id
  ,x_supply_source_line_id          =>     x_supply_source_line_id
  ,x_supply_source_line_detail      =>     x_supply_source_line_detail
  ,x_supply_source_name             =>     x_supply_source_name
  ,x_revision                       =>     x_revision
  ,x_subinventory_code              =>     x_subinventory_code
  ,x_subinventory_id                =>     x_subinventory_id
  ,x_locator_id                     =>     x_locator_id
  ,x_lot_number                     =>     x_lot_number
  ,x_lot_number_id                  =>     x_lot_number_id
  ,x_serial_number                  =>     x_serial_number
  ,x_serial_number_id               =>     x_serial_number_id
  ,x_partial_quantities_allowed     =>     x_partial_quantities_allowed
  ,x_auto_detailed                  =>     x_auto_detailed
  ,x_pick_slip_number               =>     x_pick_slip_number
  ,x_lpn_id                         =>     x_lpn_id
  ,x_last_update_date               =>     x_last_update_date
  ,x_last_updated_by                =>     x_last_updated_by
  ,x_creation_date                  =>     x_creation_date
  ,x_created_by                     =>     x_created_by
  ,x_last_update_login              =>     x_last_update_login
  ,x_request_id                     =>     x_request_id
  ,x_program_application_id         =>     x_program_application_id
  ,x_program_id                     =>     x_program_id
  ,x_program_update_date            =>     x_program_update_date
  ,x_attribute_category             =>     x_attribute_category
  ,x_attribute1                     =>     x_attribute1
  ,x_attribute2                     =>     x_attribute2
  ,x_attribute3                     =>     x_attribute3
  ,x_attribute4                     =>     x_attribute4
  ,x_attribute5                     =>     x_attribute5
  ,x_attribute6                     =>     x_attribute6
  ,x_attribute7                     =>     x_attribute7
  ,x_attribute8                     =>     x_attribute8
  ,x_attribute9                     =>     x_attribute9
  ,x_attribute10                    =>     x_attribute10
  ,x_attribute11                    =>     x_attribute11
  ,x_attribute12                    =>     x_attribute12
  ,x_attribute13                    =>     x_attribute13
  ,x_attribute14                    =>     x_attribute14
  ,x_attribute15                    =>     x_attribute15
   ,x_ship_ready_flag                =>     x_ship_ready_flag
   ,x_staged_flag                    =>     NULL
   /**** {{ R12 Enhanced reservations code changes }}****/
   , x_crossdock_flag               => NULL
   , x_crossdock_criteria_id        => NULL
   , x_demand_source_line_detail    => NULL
   , x_serial_reservation_quantity  => NULL
   , x_supply_receipt_date          => NULL
   , x_demand_ship_date             => NULL
   , x_project_id                   => NULL
   , x_task_id                      => NULL
   , x_orig_supply_type_id          => NULL
   , x_orig_supply_header_id        => NULL
   , x_orig_supply_line_id          => NULL
   , x_orig_supply_line_detail      => NULL
   , x_orig_demand_type_id          => NULL
   , x_orig_demand_header_id        => NULL
   , x_orig_demand_line_id          => NULL
   , x_orig_demand_line_detail      => NULL
   /*** End R12 ***/
  );

END INSERT_ROW;

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
  )IS
    CURSOR C IS SELECT ROWID FROM MTL_RESERVATIONS
      WHERE reservation_id = x_reservation_id;
BEGIN
   INSERT INTO MTL_RESERVATIONS (
       reservation_id
      ,requirement_date
      ,organization_id
      ,inventory_item_id
      ,demand_source_type_id
      ,demand_source_name
      ,demand_source_header_id
      ,demand_source_line_id
      ,demand_source_delivery
      ,primary_uom_code
      ,primary_uom_id
      ,secondary_uom_code
      ,secondary_uom_id
      ,reservation_uom_code
      ,reservation_uom_id
      ,reservation_quantity
      ,primary_reservation_quantity
      ,secondary_reservation_quantity
      ,detailed_quantity
      ,secondary_detailed_quantity
      ,autodetail_group_id
      ,external_source_code
      ,external_source_line_id
      ,supply_source_type_id
      ,supply_source_header_id
      ,supply_source_line_id
      ,supply_source_line_detail
      ,supply_source_name
      ,revision
      ,subinventory_code
      ,subinventory_id
      ,locator_id
      ,lot_number
      ,lot_number_id
      ,serial_number
      ,serial_number_id
      ,partial_quantities_allowed
      ,auto_detailed
      ,pick_slip_number
      ,lpn_id
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,ship_ready_flag
     ,staged_flag
      /**** {{ R12 Enhanced reservations code changes }}****/
     , crossdock_flag
     , crossdock_criteria_id
     , demand_source_line_detail
     , serial_reservation_quantity
     , supply_receipt_date
     , demand_ship_date
     , project_id
     , task_id
     , orig_supply_source_type_id
     , orig_supply_source_header_id
     , orig_supply_source_line_id
     , orig_supply_source_line_detail
     , orig_demand_source_type_id
     , orig_demand_source_header_id
     , orig_demand_source_line_id
     , orig_demand_source_line_detail
     /*** End R12 ***/
    ) values (
       nvl(x_reservation_id, mtl_demand_s.NEXTVAL)
      ,x_requirement_date
      ,x_organization_id
      ,x_inventory_item_id
      ,x_demand_source_type_id
      ,x_demand_source_name
      ,x_demand_source_header_id
      ,x_demand_source_line_id
      ,x_demand_source_delivery
      ,x_primary_uom_code
      ,x_primary_uom_id
      ,x_secondary_uom_code
      ,x_secondary_uom_id
      ,x_reservation_uom_code
      ,x_reservation_uom_id
      ,x_reservation_quantity
      ,x_primary_reservation_quantity
      ,x_second_reservation_quantity
      ,x_detailed_quantity
      ,x_secondary_detailed_quantity
      ,x_autodetail_group_id
      ,x_external_source_code
      ,x_external_source_line_id
      ,x_supply_source_type_id
      ,x_supply_source_header_id
      ,x_supply_source_line_id
      ,x_supply_source_line_detail
      ,x_supply_source_name
      ,x_revision
      ,x_subinventory_code
      ,x_subinventory_id
      ,x_locator_id
      ,x_lot_number
      ,x_lot_number_id
      ,x_serial_number
      ,x_serial_number_id
      ,x_partial_quantities_allowed
      ,x_auto_detailed
      ,x_pick_slip_number
      ,x_lpn_id
      ,x_last_update_date
      ,x_last_updated_by
      ,x_creation_date
      ,x_created_by
      ,x_last_update_login
      ,x_request_id
      ,x_program_application_id
      ,x_program_id
      ,x_program_update_date
      ,x_attribute_category
      ,x_attribute1
      ,x_attribute2
      ,x_attribute3
      ,x_attribute4
      ,x_attribute5
      ,x_attribute6
      ,x_attribute7
      ,x_attribute8
      ,x_attribute9
      ,x_attribute10
      ,x_attribute11
      ,x_attribute12
      ,x_attribute13
      ,x_attribute14
      ,x_attribute15
      ,x_ship_ready_flag
     ,x_staged_flag
      /**** {{ R12 Enhanced reservations code changes }}****/
     , x_crossdock_flag
     , x_crossdock_criteria_id
     , x_demand_source_line_detail
     , x_serial_reservation_quantity
     , x_supply_receipt_date
     , x_demand_ship_date
     , x_project_id
     , x_task_id
     , x_orig_supply_type_id
     , x_orig_supply_header_id
     , x_orig_supply_line_id
     , x_orig_supply_line_detail
     , x_orig_demand_type_id
     , x_orig_demand_header_id
     , x_orig_demand_line_id
     , x_orig_demand_line_detail
     /*** End R12 ***/
   )RETURNING reservation_id INTO  x_reservation_id;

  OPEN C;
  FETCH C INTO x_rowid;
  IF (C%NOTFOUND) THEN
     CLOSE C;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END INSERT_ROW;

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
  )IS
BEGIN

 LOCK_ROW (
   x_reservation_id                 =>     x_reservation_id
  ,x_requirement_date               =>     x_requirement_date
  ,x_organization_id                =>     x_organization_id
  ,x_inventory_item_id              =>     x_inventory_item_id
  ,x_demand_source_type_id          =>     x_demand_source_type_id
  ,x_demand_source_name             =>     x_demand_source_name
  ,x_demand_source_header_id        =>     x_demand_source_header_id
  ,x_demand_source_line_id          =>     x_demand_source_line_id
  ,x_demand_source_delivery         =>     x_demand_source_delivery
  ,x_primary_uom_code               =>     x_primary_uom_code
  ,x_primary_uom_id                 =>     x_primary_uom_id
  ,x_secondary_uom_code             =>     x_secondary_uom_code
  ,x_secondary_uom_id               =>     x_secondary_uom_id
  ,x_reservation_uom_code           =>     x_reservation_uom_code
  ,x_reservation_uom_id             =>     x_reservation_uom_id
  ,x_reservation_quantity           =>     x_reservation_quantity
  ,x_primary_reservation_quantity   =>     x_primary_reservation_quantity
  ,x_second_reservation_quantity    =>     x_second_reservation_quantity
  ,x_detailed_quantity              =>     x_detailed_quantity
  ,x_secondary_detailed_quantity    =>     x_secondary_detailed_quantity
  ,x_autodetail_group_id            =>     x_autodetail_group_id
  ,x_external_source_code           =>     x_external_source_code
  ,x_external_source_line_id        =>     x_external_source_line_id
  ,x_supply_source_type_id          =>     x_supply_source_type_id
  ,x_supply_source_header_id        =>     x_supply_source_header_id
  ,x_supply_source_line_id          =>     x_supply_source_line_id
  ,x_supply_source_line_detail      =>     x_supply_source_line_detail
  ,x_supply_source_name             =>     x_supply_source_name
  ,x_revision                       =>     x_revision
  ,x_subinventory_code              =>     x_subinventory_code
  ,x_subinventory_id                =>     x_subinventory_id
  ,x_locator_id                     =>     x_locator_id
  ,x_lot_number                     =>     x_lot_number
  ,x_lot_number_id                  =>     x_lot_number_id
  ,x_serial_number                  =>     x_serial_number
  ,x_serial_number_id               =>     x_serial_number_id
  ,x_partial_quantities_allowed     =>     x_partial_quantities_allowed
  ,x_auto_detailed                  =>     x_auto_detailed
  ,x_pick_slip_number               =>     x_pick_slip_number
  ,x_lpn_id                         =>     x_lpn_id
  ,x_request_id                     =>     x_request_id
  ,x_program_application_id         =>     x_program_application_id
  ,x_program_id                     =>     x_program_id
  ,x_program_update_date            =>     x_program_update_date
  ,x_attribute_category             =>     x_attribute_category
  ,x_attribute1                     =>     x_attribute1
  ,x_attribute2                     =>     x_attribute2
  ,x_attribute3                     =>     x_attribute3
  ,x_attribute4                     =>     x_attribute4
  ,x_attribute5                     =>     x_attribute5
  ,x_attribute6                     =>     x_attribute6
  ,x_attribute7                     =>     x_attribute7
  ,x_attribute8                     =>     x_attribute8
  ,x_attribute9                     =>     x_attribute9
  ,x_attribute10                    =>     x_attribute10
  ,x_attribute11                    =>     x_attribute11
  ,x_attribute12                    =>     x_attribute12
  ,x_attribute13                    =>     x_attribute13
  ,x_attribute14                    =>     x_attribute14
  ,x_attribute15                    =>     x_attribute15
  ,x_ship_ready_flag                =>     x_ship_ready_flag
   ,x_staged_flag                    =>     NULL
    /**** {{ R12 Enhanced reservations code changes }}****/
   , x_crossdock_flag               => NULL
   , x_crossdock_criteria_id        => NULL
   , x_demand_source_line_detail    => NULL
   , x_serial_reservation_quantity  => NULL
   , x_supply_receipt_date          => NULL
   , x_demand_ship_date             => NULL
   , x_project_id                   => NULL
   , x_task_id                      => NULL
   , x_orig_supply_type_id          => NULL
   , x_orig_supply_header_id        => NULL
   , x_orig_supply_line_id          => NULL
   , x_orig_supply_line_detail      => NULL
   , x_orig_demand_type_id          => NULL
   , x_orig_demand_header_id        => NULL
   , x_orig_demand_line_id          => NULL
   , x_orig_demand_line_detail      => NULL
   /*** End R12 ***/
  );
END LOCK_ROW;

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
  )IS
    CURSOR C IS SELECT
       reservation_id
      ,requirement_date
      ,organization_id
      ,inventory_item_id
      ,demand_source_type_id
      ,demand_source_name
      ,demand_source_header_id
      ,demand_source_line_id
      ,demand_source_delivery
      ,primary_uom_code
      ,primary_uom_id
      ,secondary_uom_code
      ,secondary_uom_id
      ,reservation_uom_code
      ,reservation_uom_id
      ,reservation_quantity
      ,primary_reservation_quantity
      ,secondary_reservation_quantity
      ,detailed_quantity
      ,secondary_detailed_quantity
      ,autodetail_group_id
      ,external_source_code
      ,external_source_line_id
      ,supply_source_type_id
      ,supply_source_header_id
      ,supply_source_line_id
      ,supply_source_line_detail
      ,supply_source_name
      ,revision
      ,subinventory_code
      ,subinventory_id
      ,locator_id
      ,lot_number
      ,lot_number_id
      ,serial_number
      ,serial_number_id
      ,partial_quantities_allowed
      ,auto_detailed
      ,pick_slip_number
      ,lpn_id
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,ship_ready_flag
      ,staged_flag
      /**** {{ R12 Enhanced reservations code changes }}****/
      , crossdock_flag
      , crossdock_criteria_id
      , demand_source_line_detail
      , serial_reservation_quantity
      , supply_receipt_date
      , demand_ship_date
      , project_id
      , task_id
      /*** End R12 ***/
     FROM MTL_RESERVATIONS
     WHERE reservation_id = x_reservation_id
     FOR UPDATE OF reservation_id NOWAIT;

  recinfo c%ROWTYPE;
BEGIN
   OPEN c;
   FETCH c INTO recinfo;
   IF (c%notfound) THEN
      CLOSE c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
   END IF;
   CLOSE c;
   IF (    (recinfo.reservation_id = x_reservation_id)
       AND (recinfo.requirement_date = x_requirement_date)
       AND (recinfo.organization_id = x_organization_id)
       AND (recinfo.inventory_item_id = x_inventory_item_id)
       AND (recinfo.demand_source_type_id = x_demand_source_type_id)
       AND ((recinfo.demand_source_name = x_demand_source_name)
             OR ((recinfo.demand_source_name IS NULL)
            AND (x_demand_source_name IS NULL)))
       AND ((recinfo.demand_source_header_id = x_demand_source_header_id)
             OR ((recinfo.demand_source_header_id IS NULL)
            AND (x_demand_source_header_id IS NULL)))
       AND ((recinfo.demand_source_line_id = x_demand_source_line_id)
             OR ((recinfo.demand_source_line_id IS NULL)
            AND (x_demand_source_line_id IS NULL)))
       AND ((recinfo.demand_source_delivery = x_demand_source_delivery)
             OR ((recinfo.demand_source_delivery IS NULL)
            AND (x_demand_source_delivery IS NULL)))
       AND ((recinfo.primary_uom_code = x_primary_uom_code)
             OR ((recinfo.primary_uom_code IS NULL)
            AND (x_primary_uom_code IS NULL)))
       AND ((recinfo.primary_uom_id = x_primary_uom_id)
             OR ((recinfo.primary_uom_id IS NULL)
            AND (x_primary_uom_id IS NULL)))
       -- INVCONV BEGIN
       AND ((recinfo.secondary_uom_code = x_secondary_uom_code)
             OR ((recinfo.secondary_uom_code IS NULL)
            AND (x_secondary_uom_code IS NULL)))
       AND ((recinfo.secondary_uom_id = x_secondary_uom_id)
             OR ((recinfo.secondary_uom_id IS NULL)
            AND (x_secondary_uom_id IS NULL)))
       -- INVCONV END
       AND ((recinfo.reservation_uom_code = x_reservation_uom_code)
             OR ((recinfo.reservation_uom_code IS NULL)
            AND (x_reservation_uom_code IS NULL)))
       AND ((recinfo.reservation_uom_id = x_reservation_uom_id)
             OR ((recinfo.reservation_uom_id IS NULL)
            AND (x_reservation_uom_id IS NULL)))
       AND (recinfo.reservation_quantity = x_reservation_quantity)
       AND (recinfo.primary_reservation_quantity = x_primary_reservation_quantity)
       -- INVCONV BEGIN
       AND (recinfo.secondary_reservation_quantity = x_second_reservation_quantity)
       -- INVCONV END
       AND (recinfo.detailed_quantity = x_detailed_quantity)
       -- INVCONV BEGIN
       AND (recinfo.secondary_detailed_quantity = x_secondary_detailed_quantity)
       -- INVCONV END
       AND ((recinfo.autodetail_group_id = x_autodetail_group_id)
             OR ((recinfo.autodetail_group_id IS NULL)
            AND (x_autodetail_group_id IS NULL)))
       AND ((recinfo.external_source_code = x_external_source_code)
             OR ((recinfo.external_source_code IS NULL)
            AND (x_external_source_code IS NULL)))
       AND ((recinfo.external_source_line_id = x_external_source_line_id)
             OR ((recinfo.external_source_line_id IS NULL)
            AND (x_external_source_line_id IS NULL)))
       AND (recinfo.supply_source_type_id = x_supply_source_type_id)
       AND ((recinfo.supply_source_header_id = x_supply_source_header_id)
             OR ((recinfo.supply_source_header_id IS NULL)
            AND (x_supply_source_header_id IS NULL)))
       AND ((recinfo.supply_source_line_id = x_supply_source_line_id)
             OR ((recinfo.supply_source_line_id IS NULL)
            AND (x_supply_source_line_id IS NULL)))
       AND ((recinfo.supply_source_line_detail = x_supply_source_line_detail)
             OR ((recinfo.supply_source_line_detail IS NULL)
            AND (x_supply_source_line_detail IS NULL)))
       AND ((recinfo.supply_source_name = x_supply_source_name)
             OR ((recinfo.supply_source_name IS NULL)
            AND (x_supply_source_name IS NULL)))
       AND ((recinfo.revision = x_revision)
             OR ((recinfo.revision IS NULL)
            AND (x_revision IS NULL)))
       AND ((recinfo.subinventory_code = x_subinventory_code)
             OR ((recinfo.subinventory_code IS NULL)
            AND (x_subinventory_code IS NULL)))
       AND ((recinfo.subinventory_id = x_subinventory_id)
             OR ((recinfo.subinventory_id IS NULL)
            AND (x_subinventory_id IS NULL)))
       AND ((recinfo.locator_id = x_locator_id)
             OR ((recinfo.locator_id IS NULL)
            AND (x_locator_id IS NULL)))
       AND ((recinfo.lot_number = x_lot_number)
             OR ((recinfo.lot_number IS NULL)
            AND (x_lot_number IS NULL)))
       AND ((recinfo.lot_number_id = x_lot_number_id)
             OR ((recinfo.lot_number_id IS NULL)
            AND (x_lot_number_id IS NULL)))
       AND ((recinfo.serial_number = x_serial_number)
             OR ((recinfo.serial_number IS NULL)
            AND (x_serial_number IS NULL)))
       AND ((recinfo.serial_number_id = x_serial_number_id)
             OR ((recinfo.serial_number_id IS NULL)
            AND (x_serial_number_id IS NULL)))
       AND ((recinfo.partial_quantities_allowed = x_partial_quantities_allowed)
             OR ((recinfo.partial_quantities_allowed IS NULL)
            AND (x_partial_quantities_allowed IS NULL)))
       AND ((recinfo.auto_detailed = x_auto_detailed)
             OR ((recinfo.auto_detailed IS NULL)
            AND (x_auto_detailed IS NULL)))
       AND ((recinfo.pick_slip_number = x_pick_slip_number)
             OR ((recinfo.pick_slip_number IS NULL)
            AND (x_pick_slip_number IS NULL)))
       AND ((recinfo.lpn_id = x_lpn_id)
             OR ((recinfo.lpn_id IS NULL)
            AND (x_lpn_id IS NULL)))
       AND ((recinfo.request_id = x_request_id)
             OR ((recinfo.request_id IS NULL)
            AND (x_request_id IS NULL)))
       AND ((recinfo.program_application_id = x_program_application_id)
             OR ((recinfo.program_application_id IS NULL)
            AND (x_program_application_id IS NULL)))
       AND ((recinfo.program_id = x_program_id)
             OR ((recinfo.program_id IS NULL)
            AND (x_program_id IS NULL)))
       AND ((recinfo.program_update_date = x_program_update_date)
             OR ((recinfo.program_update_date IS NULL)
            AND (x_program_update_date IS NULL)))
       AND ((recinfo.attribute_category = x_attribute_category)
             OR ((recinfo.attribute_category IS NULL)
            AND (x_attribute_category IS NULL)))
       AND ((recinfo.attribute1 = x_attribute1)
             OR ((recinfo.attribute1 IS NULL)
            AND (x_attribute1 IS NULL)))
       AND ((recinfo.attribute2 = x_attribute2)
             OR ((recinfo.attribute2 IS NULL)
            AND (x_attribute2 IS NULL)))
       AND ((recinfo.attribute3 = x_attribute3)
             OR ((recinfo.attribute3 IS NULL)
            AND (x_attribute3 IS NULL)))
       AND ((recinfo.attribute4 = x_attribute4)
             OR ((recinfo.attribute4 IS NULL)
            AND (x_attribute4 IS NULL)))
       AND ((recinfo.attribute5 = x_attribute5)
             OR ((recinfo.attribute5 IS NULL)
            AND (x_attribute5 IS NULL)))
       AND ((recinfo.attribute6 = x_attribute6)
             OR ((recinfo.attribute6 IS NULL)
            AND (x_attribute6 IS NULL)))
       AND ((recinfo.attribute7 = x_attribute7)
             OR ((recinfo.attribute7 IS NULL)
            AND (x_attribute7 IS NULL)))
       AND ((recinfo.attribute8 = x_attribute8)
             OR ((recinfo.attribute8 IS NULL)
            AND (x_attribute8 IS NULL)))
       AND ((recinfo.attribute9 = x_attribute9)
             OR ((recinfo.attribute9 IS NULL)
            AND (x_attribute9 IS NULL)))
       AND ((recinfo.attribute10 = x_attribute10)
             OR ((recinfo.attribute10 IS NULL)
            AND (x_attribute10 IS NULL)))
       AND ((recinfo.attribute11 = x_attribute11)
             OR ((recinfo.attribute11 IS NULL)
            AND (x_attribute11 IS NULL)))
       AND ((recinfo.attribute12 = x_attribute12)
             OR ((recinfo.attribute12 IS NULL)
            AND (x_attribute12 IS NULL)))
       AND ((recinfo.attribute13 = x_attribute13)
             OR ((recinfo.attribute13 IS NULL)
            AND (x_attribute13 IS NULL)))
       AND ((recinfo.attribute14 = x_attribute14)
             OR ((recinfo.attribute14 IS NULL)
            AND (x_attribute14 IS NULL)))
       AND ((recinfo.attribute15 = x_attribute15)
             OR ((recinfo.attribute15 IS NULL)
            AND (x_attribute15 IS NULL)))
       AND ((recinfo.ship_ready_flag = x_ship_ready_flag)
             OR ((recinfo.ship_ready_flag IS NULL)
            AND (x_ship_ready_flag IS NULL)))
       AND ((recinfo.staged_flag = x_staged_flag)
             OR ((recinfo.staged_flag IS NULL)
		 AND (x_staged_flag IS NULL)))
/**** {{ R12 Enhanced reservations code changes }}****/
	AND ((recinfo.crossdock_flag = x_crossdock_flag)
             OR ((recinfo.crossdock_flag IS NULL)
		 AND (x_crossdock_flag IS NULL)))
        AND ((recinfo.crossdock_criteria_id = x_crossdock_criteria_id)
             OR ((recinfo.crossdock_criteria_id IS NULL)
		 AND (x_crossdock_criteria_id IS NULL)))
        AND ((recinfo.demand_source_line_detail = x_demand_source_line_detail)
             OR ((recinfo.demand_source_line_detail IS NULL)
            AND (x_demand_source_line_detail IS NULL)))
        AND ((recinfo.serial_reservation_quantity = x_serial_reservation_quantity)
             OR ((recinfo.serial_reservation_quantity IS NULL)
            AND (x_serial_reservation_quantity IS NULL)))
        AND ((recinfo.supply_receipt_date = x_supply_receipt_date)
             OR ((recinfo.supply_receipt_date IS NULL)
            AND (x_supply_receipt_date IS NULL)))
        AND ((recinfo.demand_ship_date = x_demand_ship_date)
             OR ((recinfo.demand_ship_date IS NULL)
            AND (x_demand_ship_date IS NULL)))
        AND ((recinfo.project_id = x_project_id)
             OR ((recinfo.project_id IS NULL)
            AND (x_project_id IS NULL)))
        AND ((recinfo.task_id = x_task_id)
             OR ((recinfo.task_id IS NULL)
            AND (x_task_id IS NULL)))
/*** End R12 ***/
   ) THEN
     NULL;
   ELSE
     fnd_message.set_name('FND','FORM_RECORD_CHANGED');
     app_exception.raise_exception;
   END IF;
END LOCK_ROW;

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
  )IS
BEGIN
 UPDATE_ROW (
   x_reservation_id                 =>     x_reservation_id
  ,x_requirement_date               =>     x_requirement_date
  ,x_organization_id                =>     x_organization_id
  ,x_inventory_item_id              =>     x_inventory_item_id
  ,x_demand_source_type_id          =>     x_demand_source_type_id
  ,x_demand_source_name             =>     x_demand_source_name
  ,x_demand_source_header_id        =>     x_demand_source_header_id
  ,x_demand_source_line_id          =>     x_demand_source_line_id
  ,x_demand_source_delivery         =>     x_demand_source_delivery
  ,x_primary_uom_code               =>     x_primary_uom_code
  ,x_primary_uom_id                 =>     x_primary_uom_id
  ,x_secondary_uom_code             =>     x_secondary_uom_code
  ,x_secondary_uom_id               =>     x_secondary_uom_id
  ,x_reservation_uom_code           =>     x_reservation_uom_code
  ,x_reservation_uom_id             =>     x_reservation_uom_id
  ,x_reservation_quantity           =>     x_reservation_quantity
  ,x_primary_reservation_quantity   =>     x_primary_reservation_quantity
  ,x_second_reservation_quantity    =>     x_second_reservation_quantity
  ,x_detailed_quantity              =>     x_detailed_quantity
  ,x_secondary_detailed_quantity    =>     x_secondary_detailed_quantity
  ,x_autodetail_group_id            =>     x_autodetail_group_id
  ,x_external_source_code           =>     x_external_source_code
  ,x_external_source_line_id        =>     x_external_source_line_id
  ,x_supply_source_type_id          =>     x_supply_source_type_id
  ,x_supply_source_header_id        =>     x_supply_source_header_id
  ,x_supply_source_line_id          =>     x_supply_source_line_id
  ,x_supply_source_line_detail      =>     x_supply_source_line_detail
  ,x_supply_source_name             =>     x_supply_source_name
  ,x_revision                       =>     x_revision
  ,x_subinventory_code              =>     x_subinventory_code
  ,x_subinventory_id                =>     x_subinventory_id
  ,x_locator_id                     =>     x_locator_id
  ,x_lot_number                     =>     x_lot_number
  ,x_lot_number_id                  =>     x_lot_number_id
  ,x_serial_number                  =>     x_serial_number
  ,x_serial_number_id               =>     x_serial_number_id
  ,x_partial_quantities_allowed     =>     x_partial_quantities_allowed
  ,x_auto_detailed                  =>     x_auto_detailed
  ,x_pick_slip_number               =>     x_pick_slip_number
  ,x_lpn_id                         =>     x_lpn_id
  ,x_last_update_date               =>     x_last_update_date
  ,x_last_updated_by                =>     x_last_updated_by
  ,x_last_update_login              =>     x_last_update_login
  ,x_request_id                     =>     x_request_id
  ,x_program_application_id         =>     x_program_application_id
  ,x_program_id                     =>     x_program_id
  ,x_program_update_date            =>     x_program_update_date
  ,x_attribute_category             =>     x_attribute_category
  ,x_attribute1                     =>     x_attribute1
  ,x_attribute2                     =>     x_attribute2
  ,x_attribute3                     =>     x_attribute3
  ,x_attribute4                     =>     x_attribute4
  ,x_attribute5                     =>     x_attribute5
  ,x_attribute6                     =>     x_attribute6
  ,x_attribute7                     =>     x_attribute7
  ,x_attribute8                     =>     x_attribute8
  ,x_attribute9                     =>     x_attribute9
  ,x_attribute10                    =>     x_attribute10
  ,x_attribute11                    =>     x_attribute11
  ,x_attribute12                    =>     x_attribute12
  ,x_attribute13                    =>     x_attribute13
  ,x_attribute14                    =>     x_attribute14
  ,x_attribute15                    =>     x_attribute15
  ,x_ship_ready_flag                =>     x_ship_ready_flag
   ,x_staged_flag                    =>     NULL
    /**** {{ R12 Enhanced reservations code changes }}****/
   , x_crossdock_flag               => NULL
   , x_crossdock_criteria_id        => NULL
   , x_demand_source_line_detail    => NULL
   , x_serial_reservation_quantity  => NULL
   , x_supply_receipt_date          => NULL
   , x_demand_ship_date             => NULL
   , x_project_id                   => NULL
   , x_task_id                      => NULL
  /*** End R12 ***/
  );
END UPDATE_ROW;


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
  )IS
BEGIN
   UPDATE MTL_RESERVATIONS SET
       reservation_id = x_reservation_id
      ,requirement_date = x_requirement_date
      ,organization_id = x_organization_id
      ,inventory_item_id = x_inventory_item_id
      ,demand_source_type_id = x_demand_source_type_id
      ,demand_source_name = x_demand_source_name
      ,demand_source_header_id = x_demand_source_header_id
      ,demand_source_line_id = x_demand_source_line_id
      ,demand_source_delivery = x_demand_source_delivery
      ,primary_uom_code = x_primary_uom_code
      ,primary_uom_id = x_primary_uom_id
      ,secondary_uom_code = x_secondary_uom_code
      ,secondary_uom_id = x_secondary_uom_id
      ,reservation_uom_code = x_reservation_uom_code
      ,reservation_uom_id = x_reservation_uom_id
      ,reservation_quantity = x_reservation_quantity
      ,primary_reservation_quantity = x_primary_reservation_quantity
      ,secondary_reservation_quantity = x_second_reservation_quantity
      ,detailed_quantity = x_detailed_quantity
      ,secondary_detailed_quantity = x_secondary_detailed_quantity
      ,autodetail_group_id = x_autodetail_group_id
      ,external_source_code = x_external_source_code
      ,external_source_line_id = x_external_source_line_id
      ,supply_source_type_id = x_supply_source_type_id
      ,supply_source_header_id = x_supply_source_header_id
      ,supply_source_line_id = x_supply_source_line_id
      ,supply_source_line_detail = x_supply_source_line_detail
      ,supply_source_name = x_supply_source_name
      ,revision = x_revision
      ,subinventory_code = x_subinventory_code
      ,subinventory_id = x_subinventory_id
      ,locator_id = x_locator_id
      ,lot_number = x_lot_number
      ,lot_number_id = x_lot_number_id
      ,serial_number = x_serial_number
      ,serial_number_id = x_serial_number_id
      ,partial_quantities_allowed = x_partial_quantities_allowed
      ,auto_detailed = x_auto_detailed
      ,pick_slip_number = x_pick_slip_number
      ,lpn_id = x_lpn_id
      ,last_update_date = x_last_update_date
      ,last_updated_by = x_last_updated_by
      ,last_update_login = x_last_update_login
      ,request_id = x_request_id
      ,program_application_id = x_program_application_id
      ,program_id = x_program_id
      ,program_update_date = x_program_update_date
      ,attribute_category = x_attribute_category
      ,attribute1 = x_attribute1
      ,attribute2 = x_attribute2
      ,attribute3 = x_attribute3
      ,attribute4 = x_attribute4
      ,attribute5 = x_attribute5
      ,attribute6 = x_attribute6
      ,attribute7 = x_attribute7
      ,attribute8 = x_attribute8
      ,attribute9 = x_attribute9
      ,attribute10 = x_attribute10
      ,attribute11 = x_attribute11
      ,attribute12 = x_attribute12
      ,attribute13 = x_attribute13
      ,attribute14 = x_attribute14
      ,attribute15 = x_attribute15
      ,ship_ready_flag = x_ship_ready_flag
     ,staged_flag = x_staged_flag
      /**** {{ R12 Enhanced reservations code changes }}****/
     , crossdock_flag = x_crossdock_flag
     , crossdock_criteria_id  = x_crossdock_criteria_id
     , demand_source_line_detail = x_demand_source_line_detail
     , serial_reservation_quantity = x_serial_reservation_quantity
     , supply_receipt_date = x_supply_receipt_date
     , demand_ship_date = x_demand_ship_date
     , project_id = x_project_id
     , task_id = x_task_id
     /*** End R12 ***/
   WHERE reservation_id = x_reservation_id;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;
PROCEDURE DELETE_ROW (
		      x_reservation_id    IN     NUMBER
		     ,x_to_reservation_id IN     NUMBER
  )IS
BEGIN

   DELETE FROM MTL_RESERVATIONS
   WHERE reservation_id = x_reservation_id;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;

  IF (x_to_reservation_id IS NULL) THEN
     -- bug 1809218
     -- when deleting a reservation, make sure we delete the pointer
     -- to the reservation on the MMTT record.
     UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
       SET reservation_id = NULL
       WHERE reservation_id = x_reservation_id;
   ELSE
     UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
       SET reservation_id = x_to_reservation_id
       WHERE reservation_id = x_reservation_id;
  END IF;

END DELETE_ROW;
END MTL_RESERVATIONS_PKG;

/
