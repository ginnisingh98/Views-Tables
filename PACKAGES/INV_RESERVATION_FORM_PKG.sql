--------------------------------------------------------
--  DDL for Package INV_RESERVATION_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RESERVATION_FORM_PKG" AUTHID CURRENT_USER AS
  /* $Header: INVRSVFS.pls 120.6 2006/03/16 21:15:10 rambrose noship $ */
  -- INVCONV Overloaded- Incorporate secondaries into parameter list
  --R12- Project - SU : Added variables p_Serial_Number_Tbl and p_CrossDock_Flag
  PROCEDURE create_reservation(
    p_api_version_number       IN     NUMBER
  , p_init_msg_lst             IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_return_status            OUT    NOCOPY VARCHAR2
  , x_msg_count                OUT    NOCOPY NUMBER
  , x_msg_data                 OUT    NOCOPY VARCHAR2
  , p_requirement_date         IN     DATE
  , p_organization_id          IN     NUMBER
  , p_inventory_item_id        IN     NUMBER
  , p_demand_type_id           IN     NUMBER
  , p_demand_name              IN     VARCHAR2
  , p_demand_header_id         IN     NUMBER
  , p_demand_line_id           IN     NUMBER
  , p_demand_delivery_id       IN     NUMBER DEFAULT NULL
  , p_primary_uom_code         IN     VARCHAR2
  , p_primary_uom_id           IN     NUMBER
  , p_secondary_uom_code       IN     VARCHAR2 DEFAULT NULL
  , p_secondary_uom_id         IN     NUMBER DEFAULT NULL
  , p_reservation_uom_code     IN     VARCHAR2
  , p_reservation_uom_id       IN     NUMBER
  , p_reservation_quantity     IN     NUMBER
  , p_primary_rsv_quantity     IN     NUMBER
  , p_secondary_rsv_quantity   IN     NUMBER DEFAULT NULL
  , p_autodetail_group_id      IN     NUMBER
  , p_external_source_code     IN     VARCHAR2
  , p_external_source_line     IN     NUMBER
  , p_supply_type_id           IN     NUMBER
  , p_supply_header_id         IN     NUMBER
  , p_supply_line_id           IN     NUMBER
  , p_supply_name              IN     VARCHAR2
  , p_supply_line_detail       IN     NUMBER
  , p_revision                 IN     VARCHAR2
  , p_subinventory_code        IN     VARCHAR2
  , p_subinventory_id          IN     NUMBER
  , p_locator_id               IN     NUMBER
  , p_lot_number               IN     VARCHAR2
  , p_lot_number_id            IN     NUMBER
  , p_pick_slip_number         IN     NUMBER
  , p_lpn_id                   IN     NUMBER
  , p_project_id               IN     NUMBER Default Null
  , p_task_id                  IN     NUMBER Default Null
  , p_Serial_Number_Tbl        In     Inv_Reservation_Global.Serial_Number_Tbl_Type
  , p_ship_ready_flag          IN     NUMBER
  , p_CrossDock_Flag           In     Varchar2 Default Null
  , p_attribute_category       IN     VARCHAR2 DEFAULT NULL
  , p_attribute1               IN     VARCHAR2 DEFAULT NULL
  , p_attribute2               IN     VARCHAR2 DEFAULT NULL
  , p_attribute3               IN     VARCHAR2 DEFAULT NULL
  , p_attribute4               IN     VARCHAR2 DEFAULT NULL
  , p_attribute5               IN     VARCHAR2 DEFAULT NULL
  , p_attribute6               IN     VARCHAR2 DEFAULT NULL
  , p_attribute7               IN     VARCHAR2 DEFAULT NULL
  , p_attribute8               IN     VARCHAR2 DEFAULT NULL
  , p_attribute9               IN     VARCHAR2 DEFAULT NULL
  , p_attribute10              IN     VARCHAR2 DEFAULT NULL
  , p_attribute11              IN     VARCHAR2 DEFAULT NULL
  , p_attribute12              IN     VARCHAR2 DEFAULT NULL
  , p_attribute13              IN     VARCHAR2 DEFAULT NULL
  , p_attribute14              IN     VARCHAR2 DEFAULT NULL
  , p_attribute15              IN     VARCHAR2 DEFAULT NULL
  , p_partial_reservation_flag IN     VARCHAR2 DEFAULT fnd_api.g_false
  , p_force_reservation_flag   IN     VARCHAR2 DEFAULT fnd_api.g_false
  , p_validation_flag          IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_quantity_reserved        OUT    NOCOPY NUMBER
  , x_secondary_quantity_reserved OUT    NOCOPY NUMBER
  , x_reservation_id           OUT    NOCOPY NUMBER
  );

  PROCEDURE create_reservation(
    p_api_version_number       IN     NUMBER
  , p_init_msg_lst             IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_return_status            OUT    NOCOPY VARCHAR2
  , x_msg_count                OUT    NOCOPY NUMBER
  , x_msg_data                 OUT    NOCOPY VARCHAR2
  , p_requirement_date         IN     DATE
  , p_organization_id          IN     NUMBER
  , p_inventory_item_id        IN     NUMBER
  , p_demand_type_id           IN     NUMBER
  , p_demand_name              IN     VARCHAR2
  , p_demand_header_id         IN     NUMBER
  , p_demand_line_id           IN     NUMBER
  , p_demand_delivery_id       IN     NUMBER DEFAULT NULL
  , p_primary_uom_code         IN     VARCHAR2
  , p_primary_uom_id           IN     NUMBER
  , p_reservation_uom_code     IN     VARCHAR2
  , p_reservation_uom_id       IN     NUMBER
  , p_reservation_quantity     IN     NUMBER
  , p_primary_rsv_quantity     IN     NUMBER
  , p_autodetail_group_id      IN     NUMBER
  , p_external_source_code     IN     VARCHAR2
  , p_external_source_line     IN     NUMBER
  , p_supply_type_id           IN     NUMBER
  , p_supply_header_id         IN     NUMBER
  , p_supply_line_id           IN     NUMBER
  , p_supply_name              IN     VARCHAR2
  , p_supply_line_detail       IN     NUMBER
  , p_revision                 IN     VARCHAR2
  , p_subinventory_code        IN     VARCHAR2
  , p_subinventory_id          IN     NUMBER
  , p_locator_id               IN     NUMBER
  , p_lot_number               IN     VARCHAR2
  , p_lot_number_id            IN     NUMBER
  , p_pick_slip_number         IN     NUMBER
  , p_lpn_id                   IN     NUMBER
  , p_ship_ready_flag          IN     NUMBER
  , p_attribute_category       IN     VARCHAR2 DEFAULT NULL
  , p_attribute1               IN     VARCHAR2 DEFAULT NULL
  , p_attribute2               IN     VARCHAR2 DEFAULT NULL
  , p_attribute3               IN     VARCHAR2 DEFAULT NULL
  , p_attribute4               IN     VARCHAR2 DEFAULT NULL
  , p_attribute5               IN     VARCHAR2 DEFAULT NULL
  , p_attribute6               IN     VARCHAR2 DEFAULT NULL
  , p_attribute7               IN     VARCHAR2 DEFAULT NULL
  , p_attribute8               IN     VARCHAR2 DEFAULT NULL
  , p_attribute9               IN     VARCHAR2 DEFAULT NULL
  , p_attribute10              IN     VARCHAR2 DEFAULT NULL
  , p_attribute11              IN     VARCHAR2 DEFAULT NULL
  , p_attribute12              IN     VARCHAR2 DEFAULT NULL
  , p_attribute13              IN     VARCHAR2 DEFAULT NULL
  , p_attribute14              IN     VARCHAR2 DEFAULT NULL
  , p_attribute15              IN     VARCHAR2 DEFAULT NULL
  , p_partial_reservation_flag IN     VARCHAR2 DEFAULT fnd_api.g_false
  , p_force_reservation_flag   IN     VARCHAR2 DEFAULT fnd_api.g_false
  , p_validation_flag          IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_quantity_reserved        OUT    NOCOPY NUMBER
  , x_reservation_id           OUT    NOCOPY NUMBER
  );

  --
  -- INVCONV - Incorporate secondaries into parameter list
  PROCEDURE update_reservation(
    p_api_version_number        IN     NUMBER
  , p_init_msg_lst              IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_return_status             OUT    NOCOPY VARCHAR2
  , x_msg_count                 OUT    NOCOPY NUMBER
  , x_msg_data                  OUT    NOCOPY VARCHAR2
  , p_from_reservation_id       IN     NUMBER
  , p_from_requirement_date     IN     DATE
  , p_from_organization_id      IN     NUMBER
  , p_from_inventory_item_id    IN     NUMBER
  , p_from_demand_type_id       IN     NUMBER
  , p_from_demand_name          IN     VARCHAR2
  , p_from_demand_header_id     IN     NUMBER
  , p_from_demand_line_id       IN     NUMBER
  , p_from_demand_delivery_id   IN     NUMBER DEFAULT NULL
  , p_from_primary_uom_code     IN     VARCHAR2
  , p_from_primary_uom_id       IN     NUMBER
  , p_from_secondary_uom_code   IN     VARCHAR2 DEFAULT NULL
  , p_from_secondary_uom_id     IN     NUMBER   DEFAULT NULL
  , p_from_reservation_uom_code IN     VARCHAR2
  , p_from_reservation_uom_id   IN     NUMBER
  , p_from_reservation_quantity IN     NUMBER
  , p_from_primary_rsv_quantity IN     NUMBER
  , p_from_secondary_rsv_quantity IN     NUMBER DEFAULT NULL
  , p_from_autodetail_group_id  IN     NUMBER
  , p_from_external_source_code IN     VARCHAR2
  , p_from_external_source_line IN     NUMBER
  , p_from_supply_type_id       IN     NUMBER
  , p_from_supply_header_id     IN     NUMBER
  , p_from_supply_line_id       IN     NUMBER
  , p_from_supply_name          IN     VARCHAR2
  , p_from_supply_line_detail   IN     NUMBER
  , p_from_revision             IN     VARCHAR2
  , p_from_subinventory_code    IN     VARCHAR2
  , p_from_subinventory_id      IN     NUMBER
  , p_from_locator_id           IN     NUMBER
  , p_from_lot_number           IN     VARCHAR2
  , p_from_lot_number_id        IN     NUMBER
  , p_from_pick_slip_number     IN     NUMBER
  , p_from_lpn_id               IN     NUMBER
  , p_from_project_id           IN     NUMBER Default Null
  , p_from_task_id              IN     NUMBER Default Null
  , p_From_Serial_Number_Tbl    In     Inv_Reservation_Global.Serial_Number_Tbl_Type
  , p_from_ship_ready_flag      IN     NUMBER
  , p_From_CrossDock_Flag       In     Varchar2 Default Null
  , p_from_attribute_category   IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute1           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute2           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute3           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute4           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute5           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute6           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute7           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute8           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute9           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute10          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute11          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute12          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute13          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute14          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute15          IN     VARCHAR2 DEFAULT NULL
  , p_to_requirement_date       IN     DATE
  , p_to_demand_type_id         IN     NUMBER
  , p_to_demand_name            IN     VARCHAR2
  , p_to_demand_header_id       IN     NUMBER
  , p_to_demand_line_id         IN     NUMBER
  , p_to_demand_delivery_id     IN     NUMBER DEFAULT NULL
  , p_to_reservation_uom_code   IN     VARCHAR2 DEFAULT NULL
  , p_to_reservation_uom_id     IN     NUMBER  DEFAULT NULL
  , p_to_reservation_quantity   IN     NUMBER
  , p_to_primary_rsv_quantity   IN     NUMBER
  , p_to_secondary_rsv_quantity IN     NUMBER DEFAULT NULL
  , p_to_autodetail_group_id    IN     NUMBER
  , p_to_external_source_code   IN     VARCHAR2
  , p_to_external_source_line   IN     NUMBER
  , p_to_supply_type_id         IN     NUMBER
  , p_to_supply_header_id       IN     NUMBER
  , p_to_supply_line_id         IN     NUMBER
  , p_to_supply_name            IN     VARCHAR2
  , p_to_supply_line_detail     IN     NUMBER
  , p_to_revision               IN     VARCHAR2
  , p_to_subinventory_code      IN     VARCHAR2
  , p_to_subinventory_id        IN     NUMBER
  , p_to_locator_id             IN     NUMBER
  , p_to_lot_number             IN     VARCHAR2
  , p_to_lot_number_id          IN     NUMBER
  , p_to_pick_slip_number       IN     NUMBER
  , p_to_lpn_id                 IN     NUMBER
  , p_to_project_id             IN     NUMBER Default Null
  , p_to_task_id                IN     NUMBER Default Null
  , p_To_Serial_Number_Tbl      In     Inv_Reservation_Global.Serial_Number_Tbl_Type
  , p_to_ship_ready_flag        IN     NUMBER
  , p_To_CrossDock_Flag         In     Varchar2 Default Null
  , p_to_attribute_category     IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute1             IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute2             IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute3             IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute4             IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute5             IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute6             IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute7             IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute8             IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute9             IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute10            IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute11            IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute12            IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute13            IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute14            IN     VARCHAR2 DEFAULT NULL
  , p_to_attribute15            IN     VARCHAR2 DEFAULT NULL
  , p_validation_flag           IN     VARCHAR2 DEFAULT fnd_api.g_true
  );

  --
  -- INVCONV - Incorporate secondaries into parameter list
  PROCEDURE delete_reservation(
    p_api_version_number   IN     NUMBER
  , p_init_msg_lst         IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_return_status        OUT    NOCOPY VARCHAR2
  , x_msg_count            OUT    NOCOPY NUMBER
  , x_msg_data             OUT    NOCOPY VARCHAR2
  , p_reservation_id       IN     NUMBER
  , p_requirement_date     IN     DATE
  , p_organization_id      IN     NUMBER
  , p_inventory_item_id    IN     NUMBER
  , p_demand_type_id       IN     NUMBER
  , p_demand_name          IN     VARCHAR2
  , p_demand_header_id     IN     NUMBER
  , p_demand_line_id       IN     NUMBER
  , p_demand_delivery_id   IN     NUMBER DEFAULT NULL
  , p_primary_uom_code     IN     VARCHAR2
  , p_primary_uom_id       IN     NUMBER
  , p_secondary_uom_code   IN     VARCHAR2 DEFAULT NULL
  , p_secondary_uom_id     IN     NUMBER  DEFAULT NULL
  , p_reservation_uom_code IN     VARCHAR2
  , p_reservation_uom_id   IN     NUMBER
  , p_reservation_quantity IN     NUMBER
  , p_primary_rsv_quantity IN     NUMBER
  , p_secondary_rsv_quantity IN     NUMBER DEFAULT NULL
  , p_autodetail_group_id  IN     NUMBER
  , p_external_source_code IN     VARCHAR2
  , p_external_source_line IN     NUMBER
  , p_supply_type_id       IN     NUMBER
  , p_supply_header_id     IN     NUMBER
  , p_supply_line_id       IN     NUMBER
  , p_supply_name          IN     VARCHAR2
  , p_supply_line_detail   IN     NUMBER
  , p_revision             IN     VARCHAR2
  , p_subinventory_code    IN     VARCHAR2
  , p_subinventory_id      IN     NUMBER
  , p_locator_id           IN     NUMBER
  , p_lot_number           IN     VARCHAR2
  , p_lot_number_id        IN     NUMBER
  , p_pick_slip_number     IN     NUMBER
  , p_lpn_id               IN     NUMBER
  , p_Serial_Number_Tbl    In     Inv_Reservation_Global.Serial_Number_Tbl_Type
  , p_ship_ready_flag      IN     NUMBER
  , p_CrossDock_Flag       In     Varchar2 Default Null
  , p_attribute_category   IN     VARCHAR2 DEFAULT NULL
  , p_attribute1           IN     VARCHAR2 DEFAULT NULL
  , p_attribute2           IN     VARCHAR2 DEFAULT NULL
  , p_attribute3           IN     VARCHAR2 DEFAULT NULL
  , p_attribute4           IN     VARCHAR2 DEFAULT NULL
  , p_attribute5           IN     VARCHAR2 DEFAULT NULL
  , p_attribute6           IN     VARCHAR2 DEFAULT NULL
  , p_attribute7           IN     VARCHAR2 DEFAULT NULL
  , p_attribute8           IN     VARCHAR2 DEFAULT NULL
  , p_attribute9           IN     VARCHAR2 DEFAULT NULL
  , p_attribute10          IN     VARCHAR2 DEFAULT NULL
  , p_attribute11          IN     VARCHAR2 DEFAULT NULL
  , p_attribute12          IN     VARCHAR2 DEFAULT NULL
  , p_attribute13          IN     VARCHAR2 DEFAULT NULL
  , p_attribute14          IN     VARCHAR2 DEFAULT NULL
  , p_attribute15          IN     VARCHAR2 DEFAULT NULL
  , p_validation_flag      IN     VARCHAR2 DEFAULT 'T'  --Bug 2354735
  );

  --
  PROCEDURE transfer_supply(
    p_api_version_number        IN     NUMBER
  , p_init_msg_lst              IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_return_status             OUT    NOCOPY VARCHAR2
  , x_msg_count                 OUT    NOCOPY NUMBER
  , x_msg_data                  OUT    NOCOPY VARCHAR2
  , p_from_reservation_id       IN     NUMBER
  , p_from_requirement_date     IN     DATE
  , p_from_organization_id      IN     NUMBER
  , p_from_inventory_item_id    IN     NUMBER
  , p_from_demand_type_id       IN     NUMBER
  , p_from_demand_name          IN     VARCHAR2
  , p_from_demand_header_id     IN     NUMBER
  , p_from_demand_line_id       IN     NUMBER
  , p_from_demand_delivery_id   IN     NUMBER DEFAULT NULL
  , p_from_primary_uom_code     IN     VARCHAR2
  , p_from_primary_uom_id       IN     NUMBER
  , p_from_secondary_uom_code   IN     VARCHAR2
  , p_from_secondary_uom_id     IN     NUMBER
  , p_from_reservation_uom_code IN     VARCHAR2
  , p_from_reservation_uom_id   IN     NUMBER
  , p_from_reservation_quantity IN     NUMBER
  , p_from_primary_rsv_quantity IN     NUMBER
  , p_from_secondary_rsv_quantity IN     NUMBER
  , p_from_autodetail_group_id  IN     NUMBER
  , p_from_external_source_code IN     VARCHAR2
  , p_from_external_source_line IN     NUMBER
  , p_from_supply_type_id       IN     NUMBER
  , p_from_supply_header_id     IN     NUMBER
  , p_from_supply_line_id       IN     NUMBER
  , p_from_supply_name          IN     VARCHAR2
  , p_from_supply_line_detail   IN     NUMBER
  , p_from_revision             IN     VARCHAR2
  , p_from_subinventory_code    IN     VARCHAR2
  , p_from_subinventory_id      IN     NUMBER
  , p_from_locator_id           IN     NUMBER
  , p_from_lot_number           IN     VARCHAR2
  , p_from_lot_number_id        IN     NUMBER
  , p_from_pick_slip_number     IN     NUMBER
  , p_from_lpn_id               IN     NUMBER
  , p_from_ship_ready_flag      IN     NUMBER
  , p_from_attribute_category   IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute1           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute2           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute3           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute4           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute5           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute6           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute7           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute8           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute9           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute10          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute11          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute12          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute13          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute14          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute15          IN     VARCHAR2 DEFAULT NULL
  , p_to_reservation_uom_code   IN     VARCHAR2
  , p_to_secondary_uom_code     IN     VARCHAR2
  , p_to_reservation_quantity   IN     NUMBER
  , p_to_secondary_rsv_quantity IN     NUMBER
  , p_to_supply_type_id         IN     NUMBER
  , p_to_supply_header_id       IN     NUMBER
  , p_to_supply_line_id         IN     NUMBER
  , p_to_supply_name            IN     VARCHAR2
  , p_to_supply_line_detail     IN     NUMBER
  , p_to_revision               IN     VARCHAR2
  , p_to_subinventory_code      IN     VARCHAR2
  , p_to_subinventory_id        IN     NUMBER
  , p_to_locator_id             IN     NUMBER
  , p_to_lot_number             IN     VARCHAR2
  , p_to_lot_number_id          IN     NUMBER
  , p_to_pick_slip_number       IN     NUMBER
  , p_to_lpn_id                 IN     NUMBER
  , p_validation_flag           IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_to_reservation_id         OUT    NOCOPY NUMBER
  );

  --
  PROCEDURE transfer_demand(
    p_api_version_number        IN     NUMBER
  , p_init_msg_lst              IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_return_status             OUT    NOCOPY VARCHAR2
  , x_msg_count                 OUT    NOCOPY NUMBER
  , x_msg_data                  OUT    NOCOPY VARCHAR2
  , p_from_reservation_id       IN     NUMBER
  , p_from_requirement_date     IN     DATE
  , p_from_organization_id      IN     NUMBER
  , p_from_inventory_item_id    IN     NUMBER
  , p_from_demand_type_id       IN     NUMBER
  , p_from_demand_name          IN     VARCHAR2
  , p_from_demand_header_id     IN     NUMBER
  , p_from_demand_line_id       IN     NUMBER
  , p_from_demand_delivery_id   IN     NUMBER DEFAULT NULL
  , p_from_primary_uom_code     IN     VARCHAR2
  , p_from_primary_uom_id       IN     NUMBER
  , p_from_secondary_uom_code   IN     VARCHAR2
  , p_from_secondary_uom_id     IN     NUMBER
  , p_from_reservation_uom_code IN     VARCHAR2
  , p_from_reservation_uom_id   IN     NUMBER
  , p_from_reservation_quantity IN     NUMBER
  , p_from_primary_rsv_quantity IN     NUMBER
  , p_from_secondary_rsv_quantity IN     NUMBER
  , p_from_autodetail_group_id  IN     NUMBER
  , p_from_external_source_code IN     VARCHAR2
  , p_from_external_source_line IN     NUMBER
  , p_from_supply_type_id       IN     NUMBER
  , p_from_supply_header_id     IN     NUMBER
  , p_from_supply_line_id       IN     NUMBER
  , p_from_supply_name          IN     VARCHAR2
  , p_from_supply_line_detail   IN     NUMBER
  , p_from_revision             IN     VARCHAR2
  , p_from_subinventory_code    IN     VARCHAR2
  , p_from_subinventory_id      IN     NUMBER
  , p_from_locator_id           IN     NUMBER
  , p_from_lot_number           IN     VARCHAR2
  , p_from_lot_number_id        IN     NUMBER
  , p_from_pick_slip_number     IN     NUMBER
  , p_from_lpn_id               IN     NUMBER
  , p_from_project_id           IN     NUMBER Default Null
  , p_from_task_id              IN     NUMBER Default Null
  , p_from_ship_ready_flag      IN     NUMBER
  , p_from_attribute_category   IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute1           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute2           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute3           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute4           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute5           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute6           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute7           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute8           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute9           IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute10          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute11          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute12          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute13          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute14          IN     VARCHAR2 DEFAULT NULL
  , p_from_attribute15          IN     VARCHAR2 DEFAULT NULL
  , p_to_demand_type_id         IN     NUMBER
  , p_to_demand_name            IN     VARCHAR2
  , p_to_demand_header_id       IN     NUMBER
  , p_to_demand_line_id         IN     NUMBER
  , p_to_demand_delivery_id     IN     NUMBER DEFAULT NULL
  , p_to_reservation_uom_code   IN     VARCHAR2
  , p_to_reservation_quantity   IN     NUMBER
  , p_to_secondary_uom_code     IN     VARCHAR2                 -- INVCONV
  , p_to_secondary_rsv_quantity IN     NUMBER  			-- INVCONV
  , p_to_project_id             IN     NUMBER Default Null
  , p_to_task_id                IN     NUMBER Default Null
  , p_validation_flag           IN     VARCHAR2 DEFAULT fnd_api.g_true
  , x_to_reservation_id         OUT    NOCOPY NUMBER
  );

  --
  PROCEDURE query_reservation(
    p_api_version_number        IN     NUMBER
  , p_init_msg_lst              IN     VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status             OUT    NOCOPY VARCHAR2
  , x_msg_count                 OUT    NOCOPY NUMBER
  , x_msg_data                  OUT    NOCOPY VARCHAR2
  , p_reservation_id            IN     NUMBER
  , p_lock_records              IN     VARCHAR2 DEFAULT fnd_api.g_false
  , p_sort_by_req_date          IN     NUMBER
  , p_cancel_order_mode         IN     NUMBER
  , x_mtl_reservation_tbl       OUT    NOCOPY inv_reservation_global.mtl_reservation_tbl_type
  , x_mtl_reservation_tbl_count OUT    NOCOPY NUMBER
  , x_error_code                OUT    NOCOPY NUMBER
  );

  --
  PROCEDURE get_reservable_quantity(
    p_api_version_number   IN     NUMBER
  , p_init_msg_lst         IN     VARCHAR2 DEFAULT fnd_api.g_false
  , x_return_status        OUT    NOCOPY VARCHAR2
  , x_msg_count            OUT    NOCOPY NUMBER
  , x_msg_data             OUT    NOCOPY VARCHAR2
  , p_reservation_id       IN     NUMBER
  , p_reservation_uom_code IN     VARCHAR2
  , p_demand_type_id       IN     NUMBER
  , p_demand_name          IN     VARCHAR2
  , p_demand_header_id     IN     NUMBER
  , p_demand_line_id       IN     NUMBER
  , p_demand_delivery_id   IN     NUMBER DEFAULT NULL
  , p_Project_Id           In     Number
  , p_Task_Id              In     Number
  , x_reservable_quantity  OUT    NOCOPY NUMBER
  , x_reservation_margin_above OUT NOCOPY NUMBER                  -- INVCONV
  );
-- GME CONVERGENCE BEGIN
PROCEDURE create_move_order_header
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_organization_id               IN  NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , x_header_id                     OUT NOCOPY NUMBER
   );

PROCEDURE create_move_order_line
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_organization_id               IN  NUMBER
   , p_move_order_header_id          IN  NUMBER
   , p_inventory_item_id             IN  NUMBER
   , p_quantity                      IN  NUMBER
   , p_uom_code                      IN  VARCHAR2
   , p_secondary_quantity            IN  NUMBER  DEFAULT NULL
   , p_secondary_uom                 IN  VARCHAR2 DEFAULT NULL
   , p_revision                      IN  VARCHAR2
   , p_date_required                 IN  DATE
   , p_source_type_id                IN  NUMBER
   , p_source_id                     IN  NUMBER
   , p_source_line_id                IN  NUMBER
   , p_grade_code                    IN  VARCHAR2
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , x_line_id                       OUT NOCOPY NUMBER
   );

PROCEDURE delete_move_order
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_move_order_header_id          IN  NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );
-- GME CONVERGENCE END

--bug 4097848

  FUNCTION demand_source_line_number(
    p_line_number       IN      NUMBER
  , p_shipment_number   IN      NUMBER
  , p_option_number     IN      NUMBER
  , p_component_number  IN      NUMBER
  , p_service_number    IN      NUMBER
  )
 RETURN VARCHAR2;

END inv_reservation_form_pkg;

 

/
