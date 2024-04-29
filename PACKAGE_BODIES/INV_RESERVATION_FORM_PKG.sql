--------------------------------------------------------
--  DDL for Package Body INV_RESERVATION_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RESERVATION_FORM_PKG" AS
/* $Header: INVRSVFB.pls 120.10.12010000.2 2013/01/31 17:35:16 avrose ship $ */
g_pkg_name CONSTANT VARCHAR2(30) := 'Inv_Reservation_Form_PKG';
--
-- INVCONV Overloaded- Incorporate secondaries
  --R12- Project - SU : Added variables p_Serial_Number_Tbl and p_CrossDock_Flag
PROCEDURE create_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_requirement_date          IN  DATE
   , p_organization_id           IN  NUMBER
   , p_inventory_item_id         IN  NUMBER
   , p_demand_type_id            IN  NUMBER
   , p_demand_name               IN  VARCHAR2
   , p_demand_header_id          IN  NUMBER
   , p_demand_line_id            IN  NUMBER
   , p_demand_delivery_id        IN  NUMBER   DEFAULT NULL
   , p_primary_uom_code          IN  VARCHAR2
   , p_primary_uom_id            IN  NUMBER
   , p_secondary_uom_code        IN  VARCHAR2 DEFAULT NULL
   , p_secondary_uom_id          IN  NUMBER   DEFAULT NULL
   , p_reservation_uom_code      IN  VARCHAR2
   , p_reservation_uom_id        IN  NUMBER
   , p_reservation_quantity      IN  NUMBER
   , p_primary_rsv_quantity      IN  NUMBER
   , p_secondary_rsv_quantity    IN  NUMBER  DEFAULT NULL
   , p_autodetail_group_id       IN  NUMBER
   , p_external_source_code      IN  VARCHAR2
   , p_external_source_line      IN  NUMBER
   , p_supply_type_id            IN  NUMBER
   , p_supply_header_id          IN  NUMBER
   , p_supply_line_id            IN  NUMBER
   , p_supply_name               IN  VARCHAR2
   , p_supply_line_detail        IN  NUMBER
   , p_revision                  IN  VARCHAR2
   , p_subinventory_code         IN  VARCHAR2
   , p_subinventory_id           IN  NUMBER
   , p_locator_id                IN  NUMBER
   , p_lot_number                IN  VARCHAR2
   , p_lot_number_id             IN  NUMBER
   , p_pick_slip_number          IN  NUMBER
   , p_lpn_id                    IN  NUMBER
   , p_project_id                IN  NUMBER Default NULL
   , p_task_id                   IN  NUMBER Default NULL
   , p_Serial_Number_Tbl         In  Inv_Reservation_Global.Serial_Number_Tbl_Type
   , p_ship_ready_flag           IN  NUMBER
   , p_CrossDock_Flag            In  Varchar2 Default null
   , p_attribute_category        IN  VARCHAR2 DEFAULT NULL
   , p_attribute1                IN  VARCHAR2 DEFAULT NULL
   , p_attribute2                IN  VARCHAR2 DEFAULT NULL
   , p_attribute3                IN  VARCHAR2 DEFAULT NULL
   , p_attribute4                IN  VARCHAR2 DEFAULT NULL
   , p_attribute5                IN  VARCHAR2 DEFAULT NULL
   , p_attribute6                IN  VARCHAR2 DEFAULT NULL
   , p_attribute7                IN  VARCHAR2 DEFAULT NULL
   , p_attribute8                IN  VARCHAR2 DEFAULT NULL
   , p_attribute9                IN  VARCHAR2 DEFAULT NULL
   , p_attribute10               IN  VARCHAR2 DEFAULT NULL
   , p_attribute11               IN  VARCHAR2 DEFAULT NULL
   , p_attribute12               IN  VARCHAR2 DEFAULT NULL
   , p_attribute13               IN  VARCHAR2 DEFAULT NULL
   , p_attribute14               IN  VARCHAR2 DEFAULT NULL
   , p_attribute15               IN  VARCHAR2 DEFAULT NULL
   , p_partial_reservation_flag  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_force_reservation_flag    IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_quantity_reserved         OUT NOCOPY NUMBER
   , x_secondary_quantity_reserved OUT NOCOPY NUMBER
   , x_reservation_id            OUT NOCOPY NUMBER
  ) IS
     l_api_version_number        CONSTANT NUMBER       := 1.0;
     l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Reservation';
     l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_rsv_rec   inv_reservation_global.mtl_reservation_rec_type;
     l_dummy_serial_number       inv_reservation_global.serial_number_tbl_type;
BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;
   -- reservation id is not decided yet
   l_rsv_rec.reservation_id               := NULL;
   l_rsv_rec.requirement_date             := p_requirement_date;
   l_rsv_rec.organization_id              := p_organization_id;
   l_rsv_rec.inventory_item_id            := p_inventory_item_id;
   l_rsv_rec.demand_source_type_id        := p_demand_type_id;
   l_rsv_rec.demand_source_name           := p_demand_name;
   l_rsv_rec.demand_source_header_id      := p_demand_header_id;
   l_rsv_rec.demand_source_line_id        := p_demand_line_id;
   l_rsv_rec.demand_source_delivery       := p_demand_delivery_id;
   l_rsv_rec.primary_uom_code             := p_primary_uom_code;
   l_rsv_rec.primary_uom_id               := p_primary_uom_id;
   l_rsv_rec.secondary_uom_code           := p_secondary_uom_code;         -- INVCONV
   l_rsv_rec.secondary_uom_id             := p_secondary_uom_id;           -- INVCONV
   l_rsv_rec.reservation_uom_code         := p_reservation_uom_code;
   l_rsv_rec.reservation_uom_id           := p_reservation_uom_id;
   l_rsv_rec.reservation_quantity         := p_reservation_quantity;
   l_rsv_rec.primary_reservation_quantity := p_primary_rsv_quantity;
   l_rsv_rec.secondary_reservation_quantity := p_secondary_rsv_quantity;   -- INVCONV
   l_rsv_rec.autodetail_group_id          := p_autodetail_group_id;
   l_rsv_rec.external_source_code         := p_external_source_code;
   l_rsv_rec.external_source_line_id      := p_external_source_line;
   l_rsv_rec.supply_source_type_id        := p_supply_type_id;
   l_rsv_rec.supply_source_header_id      := p_supply_header_id;
   l_rsv_rec.supply_source_line_id        := p_supply_line_id;
   l_rsv_rec.supply_source_name           := p_supply_name;
   l_rsv_rec.supply_source_line_detail    := p_supply_line_detail;
   l_rsv_rec.revision                     := p_revision;
   l_rsv_rec.subinventory_code            := p_subinventory_code;
   l_rsv_rec.subinventory_id              := p_subinventory_id;
   l_rsv_rec.locator_id                   := p_locator_id;
   l_rsv_rec.lot_number                   := p_lot_number;
   l_rsv_rec.lot_number_id                := p_lot_number_id;
   l_rsv_rec.pick_slip_number             := p_pick_slip_number;
   l_rsv_rec.lpn_id                       := p_lpn_id;
   l_rsv_rec.ship_ready_flag              := p_ship_ready_flag;
   -- R12 Project : SU -- Populate CrossDock_Flag
   l_rsv_rec.project_id                   := p_project_id;
   l_rsv_rec.task_id                      := p_task_id;
   l_Rsv_Rec.CrossDock_Flag               := p_CrossDock_Flag ;
   l_rsv_rec.attribute_category           := p_attribute_category;
   l_rsv_rec.attribute1                   := p_attribute1 ;
   l_rsv_rec.attribute2                   := p_attribute2 ;
   l_rsv_rec.attribute3                   := p_attribute3 ;
   l_rsv_rec.attribute4                   := p_attribute4 ;
   l_rsv_rec.attribute5                   := p_attribute5 ;
   l_rsv_rec.attribute6                   := p_attribute6 ;
   l_rsv_rec.attribute7                   := p_attribute7 ;
   l_rsv_rec.attribute8                   := p_attribute8 ;
   l_rsv_rec.attribute9                   := p_attribute9 ;
   l_rsv_rec.attribute10                  := p_attribute10;
   l_rsv_rec.attribute11                  := p_attribute11;
   l_rsv_rec.attribute12                  := p_attribute12;
   l_rsv_rec.attribute13                  := p_attribute13;
   l_rsv_rec.attribute14                  := p_attribute14;
   l_rsv_rec.attribute15                  := p_attribute15;

   inv_reservation_pvt.create_reservation
     (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => p_init_msg_lst
      , x_return_status             => l_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_rsv_rec                   => l_rsv_rec
      , p_serial_number             => p_Serial_Number_Tbl -- R12 Project SU l_dummy_serial_number
      , x_serial_number             => l_dummy_serial_number
      , p_partial_reservation_flag  => p_partial_reservation_flag
      , p_force_reservation_flag    => p_force_reservation_flag
      , p_validation_flag           => p_validation_flag
      , x_quantity_reserved         => x_quantity_reserved
      , x_secondary_quantity_reserved => x_secondary_quantity_reserved   -- INVCONV
      , x_reservation_id            => x_reservation_id
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           , p_encoded => 'F'
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
             );

END create_reservation;

PROCEDURE create_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_requirement_date          IN  DATE
   , p_organization_id           IN  NUMBER
   , p_inventory_item_id         IN  NUMBER
   , p_demand_type_id            IN  NUMBER
   , p_demand_name               IN  VARCHAR2
   , p_demand_header_id          IN  NUMBER
   , p_demand_line_id            IN  NUMBER
   , p_demand_delivery_id        IN  NUMBER   DEFAULT NULL
   , p_primary_uom_code          IN  VARCHAR2
   , p_primary_uom_id            IN  NUMBER
   , p_reservation_uom_code      IN  VARCHAR2
   , p_reservation_uom_id        IN  NUMBER
   , p_reservation_quantity      IN  NUMBER
   , p_primary_rsv_quantity      IN  NUMBER
   , p_autodetail_group_id       IN  NUMBER
   , p_external_source_code      IN  VARCHAR2
   , p_external_source_line      IN  NUMBER
   , p_supply_type_id            IN  NUMBER
   , p_supply_header_id          IN  NUMBER
   , p_supply_line_id            IN  NUMBER
   , p_supply_name               IN  VARCHAR2
   , p_supply_line_detail        IN  NUMBER
   , p_revision                  IN  VARCHAR2
   , p_subinventory_code         IN  VARCHAR2
   , p_subinventory_id           IN  NUMBER
   , p_locator_id                IN  NUMBER
   , p_lot_number                IN  VARCHAR2
   , p_lot_number_id             IN  NUMBER
   , p_pick_slip_number          IN  NUMBER
   , p_lpn_id                    IN  NUMBER
   , p_ship_ready_flag           IN  NUMBER
   , p_attribute_category        IN  VARCHAR2 DEFAULT NULL
   , p_attribute1                IN  VARCHAR2 DEFAULT NULL
   , p_attribute2                IN  VARCHAR2 DEFAULT NULL
   , p_attribute3                IN  VARCHAR2 DEFAULT NULL
   , p_attribute4                IN  VARCHAR2 DEFAULT NULL
   , p_attribute5                IN  VARCHAR2 DEFAULT NULL
   , p_attribute6                IN  VARCHAR2 DEFAULT NULL
   , p_attribute7                IN  VARCHAR2 DEFAULT NULL
   , p_attribute8                IN  VARCHAR2 DEFAULT NULL
   , p_attribute9                IN  VARCHAR2 DEFAULT NULL
   , p_attribute10               IN  VARCHAR2 DEFAULT NULL
   , p_attribute11               IN  VARCHAR2 DEFAULT NULL
   , p_attribute12               IN  VARCHAR2 DEFAULT NULL
   , p_attribute13               IN  VARCHAR2 DEFAULT NULL
   , p_attribute14               IN  VARCHAR2 DEFAULT NULL
   , p_attribute15               IN  VARCHAR2 DEFAULT NULL
   , p_partial_reservation_flag  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_force_reservation_flag    IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_quantity_reserved         OUT NOCOPY NUMBER
   , x_reservation_id            OUT NOCOPY NUMBER
  ) IS
     l_api_version_number        CONSTANT NUMBER := 1.0;
     l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Reservation';
     l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_secondary_quantity_reserved NUMBER;
     l_Dummy_Serial_Number_Tbl   Inv_Reservation_Global.Serial_Number_Tbl_Type ;

BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Call the over loaded function
   Create_reservation (
          p_api_version_number 		=> p_api_version_number
        , p_init_msg_lst       		=> p_init_msg_lst
   	, x_return_status      		=> l_return_status
   	, x_msg_count          		=> x_msg_count
   	, x_msg_data           		=> x_msg_data
   	, p_requirement_date   		=> p_requirement_date
   	, p_organization_id    		=> p_organization_id
   	, p_inventory_item_id  		=> p_inventory_item_id
   	, p_demand_type_id     		=> p_demand_type_id
    	, p_demand_name        		=> p_demand_name
    	, p_demand_header_id     	=> p_demand_header_id
    	, p_demand_line_id      	=> p_demand_line_id
    	, p_demand_delivery_id  	=> p_demand_delivery_id
    	, p_primary_uom_code   		=> p_primary_uom_code
    	, p_primary_uom_id     		=> p_primary_uom_id
    	, p_reservation_uom_code  	=> p_reservation_uom_code
    	, p_reservation_uom_id   	=> p_reservation_uom_id
    	, p_reservation_quantity   	=> p_reservation_quantity
    	, p_primary_rsv_quantity     	=> p_primary_rsv_quantity
    	, p_autodetail_group_id      	=> p_autodetail_group_id
    	, p_external_source_code     	=> p_external_source_code
   	, p_external_source_line    	=> p_external_source_line
   	, p_supply_type_id         	=> p_supply_type_id
   	, p_supply_header_id      	=> p_supply_header_id
   	, p_supply_line_id       	=> p_supply_line_id
   	, p_supply_name         	=> p_supply_name
   	, p_supply_line_detail  	=> p_supply_line_detail
   	, p_revision           		=> p_revision
   	, p_subinventory_code   	=> p_subinventory_code
   	, p_subinventory_id    		=> p_subinventory_id
   	, p_locator_id        		=> p_locator_id
   	, p_lot_number       		=> p_lot_number
   	, p_lot_number_id   		=> p_lot_number_id
   	, p_pick_slip_number  		=> p_pick_slip_number
   	, p_lpn_id           		=> p_lpn_id
        , p_project_id                  => Null
        , p_task_id                     => Null
        , p_Serial_Number_Tbl           => l_Dummy_Serial_NUmber_Tbl  -- R12 Project : SU
   	, p_ship_ready_flag  		=> p_ship_ready_flag
        , p_CrossDock_Flag              => Null  -- R12 Project : SU
   	, p_attribute_category  	=> p_attribute_category
   	, p_attribute1         		=> p_attribute1
   	, p_attribute2        		=> p_attribute2
   	, p_attribute3       		=> p_attribute2
   	, p_attribute4     		=> p_attribute4
   	, p_attribute5    		=> p_attribute5
   	, p_attribute6        		=> p_attribute6
   	, p_attribute7          	=> p_attribute7
   	, p_attribute8         		=> p_attribute8
   	, p_attribute9        		=> p_attribute9
   	, p_attribute10          	=> p_attribute10
   	, p_attribute11             	=> p_attribute11
   	, p_attribute12            	=> p_attribute12
   	, p_attribute13           	=> p_attribute13
   	, p_attribute14          	=> p_attribute14
   	, p_attribute15         	=> p_attribute15
   	, p_partial_reservation_flag    => p_partial_reservation_flag
   	, p_force_reservation_flag      => p_force_reservation_flag
   	, p_validation_flag             => p_validation_flag
   	, x_quantity_reserved           => x_quantity_reserved
   	, x_secondary_quantity_reserved => l_secondary_quantity_reserved
        , x_reservation_id		=> x_reservation_id
     );


   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
                  , p_encoded => 'F'
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

 --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
             );

END create_reservation;


-- Description
--   called by the form to update a reservation record
-- Note
--   1. Required all values of the original record
--      and the update_to record (including null values).
--   2. Can not update organization_id, inventory_item_id, primary_uom_code
--      or primary_uom_id.
-- INVCONV - Incorporate secondaries
PROCEDURE update_reservation
  (
     p_api_version_number          IN  NUMBER
   , p_init_msg_lst                IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_return_status               OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , p_from_reservation_id         IN  NUMBER
   , p_from_requirement_date       IN  DATE
   , p_from_organization_id        IN  NUMBER
   , p_from_inventory_item_id      IN  NUMBER
   , p_from_demand_type_id         IN  NUMBER
   , p_from_demand_name            IN  VARCHAR2
   , p_from_demand_header_id       IN  NUMBER
   , p_from_demand_line_id         IN  NUMBER
   , p_from_demand_delivery_id     IN  NUMBER   DEFAULT NULL
   , p_from_primary_uom_code       IN  VARCHAR2
   , p_from_primary_uom_id         IN  NUMBER
   , p_from_secondary_uom_code     IN  VARCHAR2
   , p_from_secondary_uom_id       IN  NUMBER
   , p_from_reservation_uom_code   IN  VARCHAR2
   , p_from_reservation_uom_id     IN  NUMBER
   , p_from_reservation_quantity   IN  NUMBER
   , p_from_primary_rsv_quantity   IN  NUMBER
   , p_from_secondary_rsv_quantity IN  NUMBER
   , p_from_autodetail_group_id    IN  NUMBER
   , p_from_external_source_code   IN  VARCHAR2
   , p_from_external_source_line   IN  NUMBER
   , p_from_supply_type_id         IN  NUMBER
   , p_from_supply_header_id       IN  NUMBER
   , p_from_supply_line_id         IN  NUMBER
   , p_from_supply_name            IN  VARCHAR2
   , p_from_supply_line_detail     IN  NUMBER
   , p_from_revision               IN  VARCHAR2
   , p_from_subinventory_code      IN  VARCHAR2
   , p_from_subinventory_id        IN  NUMBER
   , p_from_locator_id             IN  NUMBER
   , p_from_lot_number             IN  VARCHAR2
   , p_from_lot_number_id          IN  NUMBER
   , p_from_pick_slip_number       IN  NUMBER
   , p_from_lpn_id                 IN  NUMBER
   , p_from_project_id             IN  NUMBER Default Null
   , p_from_task_id                IN  NUMBER Default Null
   , p_From_Serial_Number_Tbl      In Inv_Reservation_Global.Serial_Number_Tbl_Type
   , p_from_ship_ready_flag        IN  NUMBER
   , p_From_CrossDock_Flag         In  Varchar2 Default Null
   , p_from_attribute_category     IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute1             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute2             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute3             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute4             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute5             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute6             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute7             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute8             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute9             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute10            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute11            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute12            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute13            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute14            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute15            IN  VARCHAR2 DEFAULT NULL
   , p_to_requirement_date         IN  DATE
   , p_to_demand_type_id           IN  NUMBER
   , p_to_demand_name              IN  VARCHAR2
   , p_to_demand_header_id         IN  NUMBER
   , p_to_demand_line_id           IN  NUMBER
   , p_to_demand_delivery_id       IN  NUMBER   DEFAULT NULL
   , p_to_reservation_uom_code     IN  VARCHAR2
   , p_to_reservation_uom_id       IN  NUMBER
   , p_to_reservation_quantity     IN  NUMBER
   , p_to_primary_rsv_quantity     IN  NUMBER
   , p_to_secondary_rsv_quantity   IN  NUMBER
   , p_to_autodetail_group_id      IN  NUMBER
   , p_to_external_source_code     IN  VARCHAR2
   , p_to_external_source_line     IN  NUMBER
   , p_to_supply_type_id           IN  NUMBER
   , p_to_supply_header_id         IN  NUMBER
   , p_to_supply_line_id           IN  NUMBER
   , p_to_supply_name              IN  VARCHAR2
   , p_to_supply_line_detail       IN  NUMBER
   , p_to_revision                 IN  VARCHAR2
   , p_to_subinventory_code        IN  VARCHAR2
   , p_to_subinventory_id          IN  NUMBER
   , p_to_locator_id               IN  NUMBER
   , p_to_lot_number               IN  VARCHAR2
   , p_to_lot_number_id            IN  NUMBER
   , p_to_pick_slip_number         IN  NUMBER
   , p_to_lpn_id                   IN  NUMBER
   , p_to_project_id               IN  NUMBER Default Null
   , p_to_task_id                  IN  NUMBER Default Null
   , p_To_Serial_Number_Tbl        In  Inv_Reservation_Global.Serial_Number_Tbl_Type
   , p_to_ship_ready_flag          IN  NUMBER
   , p_To_CrossDock_Flag           In  Varchar2 Default Null
   , p_to_attribute_category       IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute1               IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute2               IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute3               IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute4               IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute5               IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute6               IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute7               IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute8               IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute9               IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute10              IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute11              IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute12              IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute13              IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute14              IN  VARCHAR2 DEFAULT NULL
   , p_to_attribute15              IN  VARCHAR2 DEFAULT NULL
   , p_validation_flag             IN  VARCHAR2 DEFAULT fnd_api.g_true
  ) IS
     l_api_version_number        CONSTANT NUMBER       := 1.0;
     l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Reservation';
     l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_orig_rsv_rec   inv_reservation_global.mtl_reservation_rec_type;
     l_to_rsv_rec     inv_reservation_global.mtl_reservation_rec_type;
     l_dummy_serial_number inv_reservation_global.serial_number_tbl_type;
BEGIN

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- construct the record type for the original reservation
   l_orig_rsv_rec.reservation_id               := p_from_reservation_id;
   l_orig_rsv_rec.requirement_date             := p_from_requirement_date;
   l_orig_rsv_rec.organization_id              := p_from_organization_id;
   l_orig_rsv_rec.inventory_item_id            := p_from_inventory_item_id;
   l_orig_rsv_rec.demand_source_type_id        := p_from_demand_type_id;
   l_orig_rsv_rec.demand_source_name           := p_from_demand_name;
   l_orig_rsv_rec.demand_source_header_id      := p_from_demand_header_id;
   l_orig_rsv_rec.demand_source_line_id        := p_from_demand_line_id;
   l_orig_rsv_rec.demand_source_delivery       := p_from_demand_delivery_id;
   l_orig_rsv_rec.primary_uom_code             := p_from_primary_uom_code;
   l_orig_rsv_rec.primary_uom_id               := p_from_primary_uom_id;
   l_orig_rsv_rec.secondary_uom_code           := p_from_secondary_uom_code;       -- INVCONV
   l_orig_rsv_rec.secondary_uom_id             := p_from_secondary_uom_id;         -- INVCONV
   l_orig_rsv_rec.reservation_uom_code         := p_from_reservation_uom_code;
   l_orig_rsv_rec.reservation_uom_id           := p_from_reservation_uom_id;
   l_orig_rsv_rec.reservation_quantity         := p_from_reservation_quantity;
   l_orig_rsv_rec.primary_reservation_quantity := Nvl(p_from_primary_rsv_quantity,fnd_api.g_miss_num);
   l_orig_rsv_rec.secondary_reservation_quantity := Nvl(p_from_secondary_rsv_quantity,fnd_api.g_miss_num);
   l_orig_rsv_rec.autodetail_group_id          := p_from_autodetail_group_id;
  -- Bug 4756403:Setting external source code to g_miss_char
   l_orig_rsv_rec.external_source_code         :=
     Nvl(p_from_external_source_code, fnd_api.g_miss_char);
   l_orig_rsv_rec.external_source_line_id      := p_from_external_source_line;
   l_orig_rsv_rec.supply_source_type_id        := p_from_supply_type_id;
   l_orig_rsv_rec.supply_source_header_id      := p_from_supply_header_id;
   l_orig_rsv_rec.supply_source_line_id        := p_from_supply_line_id;
   l_orig_rsv_rec.supply_source_name           := p_from_supply_name;
   l_orig_rsv_rec.supply_source_line_detail    := p_from_supply_line_detail;
   l_orig_rsv_rec.revision                     := p_from_revision;
   l_orig_rsv_rec.subinventory_code            := p_from_subinventory_code;
   l_orig_rsv_rec.subinventory_id              := p_from_subinventory_id;
   l_orig_rsv_rec.locator_id                   := p_from_locator_id;
   l_orig_rsv_rec.lot_number                   := p_from_lot_number;
   l_orig_rsv_rec.lot_number_id                := p_from_lot_number_id;
   l_orig_rsv_rec.pick_slip_number             := p_from_pick_slip_number;
   l_orig_rsv_rec.lpn_id                       := p_from_lpn_id;
   l_orig_rsv_rec.project_id                   := p_from_project_id;
   l_orig_rsv_rec.task_id                      := p_from_task_id;
   l_orig_rsv_rec.ship_ready_flag              := p_from_ship_ready_flag;
   l_orig_rsv_rec.attribute_category           := p_from_attribute_category;
   l_orig_rsv_rec.attribute1                   := p_from_attribute1 ;
   l_orig_rsv_rec.attribute2                   := p_from_attribute2 ;
   l_orig_rsv_rec.attribute3                   := p_from_attribute3 ;
   l_orig_rsv_rec.attribute4                   := p_from_attribute4 ;
   l_orig_rsv_rec.attribute5                   := p_from_attribute5 ;
   l_orig_rsv_rec.attribute6                   := p_from_attribute6 ;
   l_orig_rsv_rec.attribute7                   := p_from_attribute7 ;
   l_orig_rsv_rec.attribute8                   := p_from_attribute8 ;
   l_orig_rsv_rec.attribute9                   := p_from_attribute9 ;
   l_orig_rsv_rec.attribute10                  := p_from_attribute10;
   l_orig_rsv_rec.attribute11                  := p_from_attribute11;
   l_orig_rsv_rec.attribute12                  := p_from_attribute12;
   l_orig_rsv_rec.attribute13                  := p_from_attribute13;
   l_orig_rsv_rec.attribute14                  := p_from_attribute14;
   l_orig_rsv_rec.attribute15                  := p_from_attribute15;
   -- R12 Project : SU
   l_Orig_Rsv_Rec.CrossDock_Flag               := p_From_CrossDock_Flag ;

   -- construct the record type for the update to record
   l_to_rsv_rec.requirement_date             := p_to_requirement_date;
   l_to_rsv_rec.organization_id              := Nvl(p_from_organization_id,fnd_api.g_miss_num);
   l_to_rsv_rec.inventory_item_id            := Nvl(p_from_inventory_item_id,fnd_api.g_miss_num);
   l_to_rsv_rec.demand_source_type_id        := p_to_demand_type_id;
   l_to_rsv_rec.demand_source_name           := p_to_demand_name;
   l_to_rsv_rec.demand_source_header_id      := p_to_demand_header_id;
   l_to_rsv_rec.demand_source_line_id        := p_to_demand_line_id;
   l_to_rsv_rec.demand_source_delivery       := p_to_demand_delivery_id;
   l_to_rsv_rec.primary_uom_code             := p_from_primary_uom_code;
   l_to_rsv_rec.primary_uom_id               := p_from_primary_uom_id;
   l_to_rsv_rec.secondary_uom_code           := p_from_secondary_uom_code;	-- INVCONV
   l_to_rsv_rec.secondary_uom_id             := p_from_secondary_uom_id;     	-- INVCONV
   l_to_rsv_rec.reservation_uom_code         := p_to_reservation_uom_code;
   l_to_rsv_rec.reservation_uom_id           := p_to_reservation_uom_id;
   l_to_rsv_rec.reservation_quantity         := p_to_reservation_quantity;
   l_to_rsv_rec.primary_reservation_quantity := Nvl(p_to_primary_rsv_quantity,fnd_api.g_miss_num);
   l_to_rsv_rec.secondary_reservation_quantity := Nvl(p_to_secondary_rsv_quantity,fnd_api.g_miss_num); --INVCONV
   l_to_rsv_rec.autodetail_group_id          := p_to_autodetail_group_id;

   -- Bug 4756403:Setting external source code to g_miss_char
   l_to_rsv_rec.external_source_code         := Nvl(p_from_external_source_code, fnd_api.g_miss_char);
   l_to_rsv_rec.external_source_line_id      := p_to_external_source_line;
   l_to_rsv_rec.supply_source_type_id        := p_to_supply_type_id;
   l_to_rsv_rec.supply_source_header_id      := p_to_supply_header_id;
   l_to_rsv_rec.supply_source_line_id        := p_to_supply_line_id;
   l_to_rsv_rec.supply_source_name           := p_to_supply_name;
   l_to_rsv_rec.supply_source_line_detail    := p_to_supply_line_detail;
   l_to_rsv_rec.revision                     := p_to_revision;
   l_to_rsv_rec.subinventory_code            := p_to_subinventory_code;
   l_to_rsv_rec.subinventory_id              := p_to_subinventory_id;
   l_to_rsv_rec.locator_id                   := p_to_locator_id;
   l_to_rsv_rec.lot_number                   := p_to_lot_number;
   l_to_rsv_rec.lot_number_id                := p_to_lot_number_id;
   l_to_rsv_rec.pick_slip_number             := p_to_pick_slip_number;
   l_to_rsv_rec.lpn_id                       := p_to_lpn_id;
   l_to_rsv_rec.project_id                   := p_to_project_id;
   l_to_rsv_rec.task_id                      := p_to_task_id;
   -- kkoothan
   l_to_rsv_rec.ship_ready_flag              := p_to_ship_ready_flag;
   l_to_rsv_rec.attribute_category           := p_to_attribute_category;
   l_to_rsv_rec.attribute1                   := p_to_attribute1 ;
   l_to_rsv_rec.attribute2                   := p_to_attribute2 ;
   l_to_rsv_rec.attribute3                   := p_to_attribute3 ;
   l_to_rsv_rec.attribute4                   := p_to_attribute4 ;
   l_to_rsv_rec.attribute5                   := p_to_attribute5 ;
   l_to_rsv_rec.attribute6                   := p_to_attribute6 ;
   l_to_rsv_rec.attribute7                   := p_to_attribute7 ;
   l_to_rsv_rec.attribute8                   := p_to_attribute8 ;
   l_to_rsv_rec.attribute9                   := p_to_attribute9 ;
   l_to_rsv_rec.attribute10                  := p_to_attribute10;
   l_to_rsv_rec.attribute11                  := p_to_attribute11;
   l_to_rsv_rec.attribute12                  := p_to_attribute12;
   l_to_rsv_rec.attribute13                  := p_to_attribute13;
   l_to_rsv_rec.attribute14                  := p_to_attribute14;
   l_to_rsv_rec.attribute15                  := p_to_attribute15;
   -- R12 Project : SU
   l_To_Rsv_Rec.CrossDock_Flag               := p_To_CrossDock_Flag ;

   inv_reservation_pvt.update_reservation
     (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => p_init_msg_lst
      , x_return_status             => l_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_original_rsv_rec          => l_orig_rsv_rec
      , p_to_rsv_rec                => l_to_rsv_rec
      , p_original_serial_number    => p_from_serial_number_Tbl   -- R12 Changes: SU
      , p_to_serial_number          => p_To_serial_number_tbl     -- R12 Changes : SU
      , p_validation_flag           => p_validation_flag
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           , p_encoded => 'F'
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
             );

END update_reservation;

-- INVCONV - Incorporate secondaries
PROCEDURE delete_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_reservation_id            IN  NUMBER
   , p_requirement_date          IN  DATE
   , p_organization_id           IN  NUMBER
   , p_inventory_item_id         IN  NUMBER
   , p_demand_type_id            IN  NUMBER
   , p_demand_name               IN  VARCHAR2
   , p_demand_header_id          IN  NUMBER
   , p_demand_line_id            IN  NUMBER
   , p_demand_delivery_id        IN  NUMBER   DEFAULT NULL
   , p_primary_uom_code          IN  VARCHAR2
   , p_primary_uom_id            IN  NUMBER
   , p_secondary_uom_code        IN  VARCHAR2
   , p_secondary_uom_id          IN  NUMBER
   , p_reservation_uom_code      IN  VARCHAR2
   , p_reservation_uom_id        IN  NUMBER
   , p_reservation_quantity      IN  NUMBER
   , p_primary_rsv_quantity      IN  NUMBER
   , p_secondary_rsv_quantity    IN  NUMBER
   , p_autodetail_group_id       IN  NUMBER
   , p_external_source_code      IN  VARCHAR2
   , p_external_source_line      IN  NUMBER
   , p_supply_type_id            IN  NUMBER
   , p_supply_header_id          IN  NUMBER
   , p_supply_line_id            IN  NUMBER
   , p_supply_name               IN  VARCHAR2
   , p_supply_line_detail        IN  NUMBER
   , p_revision                  IN  VARCHAR2
   , p_subinventory_code         IN  VARCHAR2
   , p_subinventory_id           IN  NUMBER
   , p_locator_id                IN  NUMBER
   , p_lot_number                IN  VARCHAR2
   , p_lot_number_id             IN  NUMBER
   , p_pick_slip_number          IN  NUMBER
   , p_lpn_id                    IN  NUMBER
   , p_Serial_Number_Tbl         In  Inv_Reservation_Global.Serial_Number_Tbl_Type
   , p_ship_ready_flag           IN  NUMBER
   , p_CrossDock_Flag            In  Varchar2 Default Null
   , p_attribute_category        IN  VARCHAR2 DEFAULT NULL
   , p_attribute1                IN  VARCHAR2 DEFAULT NULL
   , p_attribute2                IN  VARCHAR2 DEFAULT NULL
   , p_attribute3                IN  VARCHAR2 DEFAULT NULL
   , p_attribute4                IN  VARCHAR2 DEFAULT NULL
   , p_attribute5                IN  VARCHAR2 DEFAULT NULL
   , p_attribute6                IN  VARCHAR2 DEFAULT NULL
   , p_attribute7                IN  VARCHAR2 DEFAULT NULL
   , p_attribute8                IN  VARCHAR2 DEFAULT NULL
   , p_attribute9                IN  VARCHAR2 DEFAULT NULL
   , p_attribute10               IN  VARCHAR2 DEFAULT NULL
   , p_attribute11               IN  VARCHAR2 DEFAULT NULL
   , p_attribute12               IN  VARCHAR2 DEFAULT NULL
   , p_attribute13               IN  VARCHAR2 DEFAULT NULL
   , p_attribute14               IN  VARCHAR2 DEFAULT NULL
   , p_attribute15               IN  VARCHAR2 DEFAULT NULL
   , p_validation_flag           IN  VARCHAR2 DEFAULT 'T'  --Bug 2354735
  ) IS
     l_api_version_number        CONSTANT NUMBER       := 1.0;
     l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Reservation';
     l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_rsv_rec   inv_reservation_global.mtl_reservation_rec_type;
     l_dummy_serial_number       inv_reservation_global.serial_number_tbl_type;
BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   l_rsv_rec.reservation_id               := p_reservation_id;
   l_rsv_rec.requirement_date             := p_requirement_date;
   l_rsv_rec.organization_id              := p_organization_id;
   l_rsv_rec.inventory_item_id            := p_inventory_item_id;
   l_rsv_rec.demand_source_type_id        := p_demand_type_id;
   l_rsv_rec.demand_source_name           := p_demand_name;
   l_rsv_rec.demand_source_header_id      := p_demand_header_id;
   l_rsv_rec.demand_source_line_id        := p_demand_line_id;
   l_rsv_rec.demand_source_delivery       := p_demand_delivery_id;
   l_rsv_rec.primary_uom_code             := p_primary_uom_code;
   l_rsv_rec.primary_uom_id               := p_primary_uom_id;
   l_rsv_rec.secondary_uom_code           := p_secondary_uom_code;  	-- INVCONV
   l_rsv_rec.secondary_uom_id             := p_secondary_uom_id;    	-- INVCONV
   l_rsv_rec.reservation_uom_code         := p_reservation_uom_code;
   l_rsv_rec.reservation_uom_id           := p_reservation_uom_id;
   l_rsv_rec.reservation_quantity         := p_reservation_quantity;
   l_rsv_rec.primary_reservation_quantity := p_primary_rsv_quantity;
   l_rsv_rec.secondary_reservation_quantity := p_secondary_rsv_quantity;-- INVCONV
   l_rsv_rec.autodetail_group_id          := p_autodetail_group_id;
   l_rsv_rec.external_source_code         := p_external_source_code;
   l_rsv_rec.external_source_line_id      := p_external_source_line;
   l_rsv_rec.supply_source_type_id        := p_supply_type_id;
   l_rsv_rec.supply_source_header_id      := p_supply_header_id;
   l_rsv_rec.supply_source_line_id        := p_supply_line_id;
   l_rsv_rec.supply_source_name           := p_supply_name;
   l_rsv_rec.supply_source_line_detail    := p_supply_line_detail;
   l_rsv_rec.revision                     := p_revision;
   l_rsv_rec.subinventory_code            := p_subinventory_code;
   l_rsv_rec.subinventory_id              := p_subinventory_id;
   l_rsv_rec.locator_id                   := p_locator_id;
   l_rsv_rec.lot_number                   := p_lot_number;
   l_rsv_rec.lot_number_id                := p_lot_number_id;
   l_rsv_rec.pick_slip_number             := p_pick_slip_number;
   l_rsv_rec.lpn_id                       := p_lpn_id;
   l_rsv_rec.ship_ready_flag              := p_ship_ready_flag;
   l_Rsv_Rec.CrossDock_Flag               := p_CrossDock_Flag; -- R12 Changes : SU
   l_rsv_rec.attribute_category           := p_attribute_category;
   l_rsv_rec.attribute1                   := p_attribute1 ;
   l_rsv_rec.attribute2                   := p_attribute2 ;
   l_rsv_rec.attribute3                   := p_attribute3 ;
   l_rsv_rec.attribute4                   := p_attribute4 ;
   l_rsv_rec.attribute5                   := p_attribute5 ;
   l_rsv_rec.attribute6                   := p_attribute6 ;
   l_rsv_rec.attribute7                   := p_attribute7 ;
   l_rsv_rec.attribute8                   := p_attribute8 ;
   l_rsv_rec.attribute9                   := p_attribute9 ;
   l_rsv_rec.attribute10                  := p_attribute10;
   l_rsv_rec.attribute11                  := p_attribute11;
   l_rsv_rec.attribute12                  := p_attribute12;
   l_rsv_rec.attribute13                  := p_attribute13;
   l_rsv_rec.attribute14                  := p_attribute14;
   l_rsv_rec.attribute15                  := p_attribute15;

   inv_reservation_pvt.delete_reservation
     (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => p_init_msg_lst
      , x_return_status             => l_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_rsv_rec                   => l_rsv_rec
      , p_original_serial_number    => p_serial_number_Tbl -- R12 Changes : SU
      , p_validation_flag           => p_validation_flag   -- Bug 2354735
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           , p_encoded => 'F'
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
             );

END delete_reservation;

-- INVCONV - Incorporate secondaries
PROCEDURE transfer_supply
  (
     p_api_version_number          IN  NUMBER
   , p_init_msg_lst                IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_return_status               OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , p_from_reservation_id         IN  NUMBER
   , p_from_requirement_date       IN  DATE
   , p_from_organization_id        IN  NUMBER
   , p_from_inventory_item_id      IN  NUMBER
   , p_from_demand_type_id         IN  NUMBER
   , p_from_demand_name            IN  VARCHAR2
   , p_from_demand_header_id       IN  NUMBER
   , p_from_demand_line_id         IN  NUMBER
   , p_from_demand_delivery_id     IN  NUMBER   DEFAULT NULL
   , p_from_primary_uom_code       IN  VARCHAR2
   , p_from_primary_uom_id         IN  NUMBER
   , p_from_secondary_uom_code     IN  VARCHAR2
   , p_from_secondary_uom_id       IN  NUMBER
   , p_from_reservation_uom_code   IN  VARCHAR2
   , p_from_reservation_uom_id     IN  NUMBER
   , p_from_reservation_quantity   IN  NUMBER
   , p_from_primary_rsv_quantity   IN  NUMBER
   , p_from_secondary_rsv_quantity IN  NUMBER
   , p_from_autodetail_group_id    IN  NUMBER
   , p_from_external_source_code   IN  VARCHAR2
   , p_from_external_source_line   IN  NUMBER
   , p_from_supply_type_id         IN  NUMBER
   , p_from_supply_header_id       IN  NUMBER
   , p_from_supply_line_id         IN  NUMBER
   , p_from_supply_name            IN  VARCHAR2
   , p_from_supply_line_detail     IN  NUMBER
   , p_from_revision               IN  VARCHAR2
   , p_from_subinventory_code      IN  VARCHAR2
   , p_from_subinventory_id        IN  NUMBER
   , p_from_locator_id             IN  NUMBER
   , p_from_lot_number             IN  VARCHAR2
   , p_from_lot_number_id          IN  NUMBER
   , p_from_pick_slip_number       IN  NUMBER
   , p_from_lpn_id                 IN  NUMBER
   , p_from_ship_ready_flag        IN  NUMBER
   , p_from_attribute_category     IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute1             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute2             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute3             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute4             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute5             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute6             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute7             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute8             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute9             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute10            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute11            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute12            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute13            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute14            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute15            IN  VARCHAR2 DEFAULT NULL
   , p_to_reservation_uom_code     IN  VARCHAR2
   , p_to_secondary_uom_code       IN  VARCHAR2
   , p_to_reservation_quantity     IN  NUMBER
   , p_to_secondary_rsv_quantity   IN  NUMBER
   , p_to_supply_type_id           IN  NUMBER
   , p_to_supply_header_id         IN  NUMBER
   , p_to_supply_line_id           IN  NUMBER
   , p_to_supply_name              IN  VARCHAR2
   , p_to_supply_line_detail       IN  NUMBER
   , p_to_revision                 IN  VARCHAR2
   , p_to_subinventory_code        IN  VARCHAR2
   , p_to_subinventory_id          IN  NUMBER
   , p_to_locator_id               IN  NUMBER
   , p_to_lot_number               IN  VARCHAR2
   , p_to_lot_number_id            IN  NUMBER
   , p_to_pick_slip_number         IN  NUMBER
   , p_to_lpn_id                   IN  NUMBER
   , p_validation_flag             IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_to_reservation_id           OUT NOCOPY NUMBER
  ) IS
     l_api_version_number        CONSTANT NUMBER       := 1.0;
     l_api_name                  CONSTANT VARCHAR2(30) := 'Transfer_Supply';
     l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_orig_rsv_rec   inv_reservation_global.mtl_reservation_rec_type;
     l_to_rsv_rec     inv_reservation_global.mtl_reservation_rec_type;
     l_dummy_serial_number inv_reservation_global.serial_number_tbl_type;
BEGIN

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- construct the record type for the original reservation
   IF p_from_reservation_id IS NOT NULL
     AND p_from_reservation_id <> fnd_api.g_miss_num
     THEN
      l_orig_rsv_rec.reservation_id               := p_from_reservation_id;
    ELSE
      l_orig_rsv_rec.requirement_date             := p_from_requirement_date;
      l_orig_rsv_rec.organization_id              := p_from_organization_id;
      l_orig_rsv_rec.inventory_item_id            := p_from_inventory_item_id;
      l_orig_rsv_rec.demand_source_type_id        := p_from_demand_type_id;
      l_orig_rsv_rec.demand_source_name           := p_from_demand_name;
      l_orig_rsv_rec.demand_source_header_id      := p_from_demand_header_id;
      l_orig_rsv_rec.demand_source_line_id        := p_from_demand_line_id;
      l_orig_rsv_rec.demand_source_delivery       := p_from_demand_delivery_id;
      l_orig_rsv_rec.primary_uom_code             := p_from_primary_uom_code;
      l_orig_rsv_rec.primary_uom_id               := p_from_primary_uom_id;
      l_orig_rsv_rec.secondary_uom_code           := p_from_secondary_uom_code; 	-- INVCONV
      l_orig_rsv_rec.secondary_uom_id             := p_from_secondary_uom_id;   	-- INVCONV
      l_orig_rsv_rec.reservation_uom_code         := p_from_reservation_uom_code;
      l_orig_rsv_rec.reservation_uom_id           := p_from_reservation_uom_id;
      l_orig_rsv_rec.reservation_quantity         := p_from_reservation_quantity;
      l_orig_rsv_rec.primary_reservation_quantity := p_from_primary_rsv_quantity;
      l_orig_rsv_rec.secondary_reservation_quantity := p_from_secondary_rsv_quantity;	-- INVCONV
      l_orig_rsv_rec.autodetail_group_id          := p_from_autodetail_group_id;
      l_orig_rsv_rec.external_source_code         := p_from_external_source_code;
      l_orig_rsv_rec.external_source_line_id      := p_from_external_source_line;
      l_orig_rsv_rec.supply_source_type_id        := p_from_supply_type_id;
      l_orig_rsv_rec.supply_source_header_id      := p_from_supply_header_id;
      l_orig_rsv_rec.supply_source_line_id        := p_from_supply_line_id;
      l_orig_rsv_rec.supply_source_name           := p_from_supply_name;
      l_orig_rsv_rec.supply_source_line_detail    := p_from_supply_line_detail;
      l_orig_rsv_rec.revision                     := p_from_revision;
      l_orig_rsv_rec.subinventory_code            := p_from_subinventory_code;
      l_orig_rsv_rec.subinventory_id              := p_from_subinventory_id;
      l_orig_rsv_rec.locator_id                   := p_from_locator_id;
      l_orig_rsv_rec.lot_number                   := p_from_lot_number;
      l_orig_rsv_rec.lot_number_id                := p_from_lot_number_id;
      l_orig_rsv_rec.pick_slip_number             := p_from_pick_slip_number;
      l_orig_rsv_rec.lpn_id                       := p_from_lpn_id;
      l_orig_rsv_rec.ship_ready_flag              := p_from_ship_ready_flag;
      l_orig_rsv_rec.attribute_category           := p_from_attribute_category;
      l_orig_rsv_rec.attribute1                   := p_from_attribute1 ;
      l_orig_rsv_rec.attribute2                   := p_from_attribute2 ;
      l_orig_rsv_rec.attribute3                   := p_from_attribute3 ;
      l_orig_rsv_rec.attribute4                   := p_from_attribute4 ;
      l_orig_rsv_rec.attribute5                   := p_from_attribute5 ;
      l_orig_rsv_rec.attribute6                   := p_from_attribute6 ;
      l_orig_rsv_rec.attribute7                   := p_from_attribute7 ;
      l_orig_rsv_rec.attribute8                   := p_from_attribute8 ;
      l_orig_rsv_rec.attribute9                   := p_from_attribute9 ;
      l_orig_rsv_rec.attribute10                  := p_from_attribute10;
      l_orig_rsv_rec.attribute11                  := p_from_attribute11;
      l_orig_rsv_rec.attribute12                  := p_from_attribute12;
      l_orig_rsv_rec.attribute13                  := p_from_attribute13;
      l_orig_rsv_rec.attribute14                  := p_from_attribute14;
      l_orig_rsv_rec.attribute15                  := p_from_attribute15;
   END IF;

   -- construct the record type for the transfer to record
   l_to_rsv_rec.reservation_uom_code         := p_to_reservation_uom_code;
   l_to_rsv_rec.reservation_quantity         := p_to_reservation_quantity;
   l_to_rsv_rec.secondary_uom_code           := p_to_secondary_uom_code;            	-- INVCONV
   l_to_rsv_rec.reservation_quantity         := p_to_reservation_quantity;
   l_to_rsv_rec.secondary_reservation_quantity := p_to_secondary_rsv_quantity;          -- INVCONV
   l_to_rsv_rec.supply_source_type_id        := p_to_supply_type_id;
   l_to_rsv_rec.supply_source_header_id      := p_to_supply_header_id;
   l_to_rsv_rec.supply_source_line_id        := p_to_supply_line_id;
   l_to_rsv_rec.supply_source_name           := p_to_supply_name;
   l_to_rsv_rec.supply_source_line_detail    := p_to_supply_line_detail;
   l_to_rsv_rec.revision                     := p_to_revision;
   l_to_rsv_rec.subinventory_code            := p_to_subinventory_code;
   l_to_rsv_rec.subinventory_id              := p_to_subinventory_id;
   l_to_rsv_rec.locator_id                   := p_to_locator_id;
   l_to_rsv_rec.lot_number                   := p_to_lot_number;
   l_to_rsv_rec.lot_number_id                := p_to_lot_number_id;
   l_to_rsv_rec.pick_slip_number             := p_to_pick_slip_number;
   l_to_rsv_rec.lpn_id                       := p_to_lpn_id;

   inv_reservation_pvt.transfer_reservation
     (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => p_init_msg_lst
      , x_return_status             => l_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_original_rsv_rec          => l_orig_rsv_rec
      , p_to_rsv_rec                => l_to_rsv_rec
      , p_original_serial_number    => l_dummy_serial_number
      , p_validation_flag           => p_validation_flag
      , x_reservation_id            => x_to_reservation_id
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           , p_encoded => 'F'
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
             );

END transfer_supply;

-- INVCONV - Incorporate secondaries
PROCEDURE transfer_demand
  (
     p_api_version_number          IN  NUMBER
   , p_init_msg_lst                IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_return_status               OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , p_from_reservation_id         IN  NUMBER
   , p_from_requirement_date       IN  DATE
   , p_from_organization_id        IN  NUMBER
   , p_from_inventory_item_id      IN  NUMBER
   , p_from_demand_type_id         IN  NUMBER
   , p_from_demand_name            IN  VARCHAR2
   , p_from_demand_header_id       IN  NUMBER
   , p_from_demand_line_id         IN  NUMBER
   , p_from_demand_delivery_id     IN  NUMBER   DEFAULT NULL
   , p_from_primary_uom_code       IN  VARCHAR2
   , p_from_primary_uom_id         IN  NUMBER
   , p_from_secondary_uom_code     IN  VARCHAR2			-- INVCONV
   , p_from_secondary_uom_id       IN  NUMBER   		-- INVCONV
   , p_from_reservation_uom_code   IN  VARCHAR2
   , p_from_reservation_uom_id     IN  NUMBER
   , p_from_reservation_quantity   IN  NUMBER
   , p_from_primary_rsv_quantity   IN  NUMBER
   , p_from_secondary_rsv_quantity IN  NUMBER  			-- INVCONV
   , p_from_autodetail_group_id    IN  NUMBER
   , p_from_external_source_code   IN  VARCHAR2
   , p_from_external_source_line   IN  NUMBER
   , p_from_supply_type_id         IN  NUMBER
   , p_from_supply_header_id       IN  NUMBER
   , p_from_supply_line_id         IN  NUMBER
   , p_from_supply_name            IN  VARCHAR2
   , p_from_supply_line_detail     IN  NUMBER
   , p_from_revision               IN  VARCHAR2
   , p_from_subinventory_code      IN  VARCHAR2
   , p_from_subinventory_id        IN  NUMBER
   , p_from_locator_id             IN  NUMBER
   , p_from_lot_number             IN  VARCHAR2
   , p_from_lot_number_id          IN  NUMBER
   , p_from_pick_slip_number       IN  NUMBER
   , p_from_lpn_id                 IN  NUMBER
   , p_from_project_id             IN  NUMBER Default Null
   , p_from_task_id                IN  NUMBER Default Null
   , p_from_ship_ready_flag        IN  NUMBER
   , p_from_attribute_category     IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute1             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute2             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute3             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute4             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute5             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute6             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute7             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute8             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute9             IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute10            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute11            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute12            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute13            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute14            IN  VARCHAR2 DEFAULT NULL
   , p_from_attribute15            IN  VARCHAR2 DEFAULT NULL
   , p_to_demand_type_id           IN  NUMBER
   , p_to_demand_name              IN  VARCHAR2
   , p_to_demand_header_id         IN  NUMBER
   , p_to_demand_line_id           IN  NUMBER
   , p_to_demand_delivery_id       IN  NUMBER   DEFAULT NULL
   , p_to_reservation_uom_code     IN  VARCHAR2
   , p_to_reservation_quantity     IN  NUMBER
   , p_to_secondary_uom_code       IN  VARCHAR2                 -- INVCONV
   , p_to_secondary_rsv_quantity   IN  NUMBER  			-- INVCONV
   , p_to_project_id               IN  NUMBER Default Null
   , p_to_task_id                  IN  NUMBER Default Null
   , p_validation_flag             IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_to_reservation_id           OUT NOCOPY NUMBER
  ) IS
     l_api_version_number        CONSTANT NUMBER       := 1.0;
     l_api_name                  CONSTANT VARCHAR2(30) := 'Transfer_Demand';
     l_return_status             VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_orig_rsv_rec   inv_reservation_global.mtl_reservation_rec_type;
     l_to_rsv_rec     inv_reservation_global.mtl_reservation_rec_type;
     l_dummy_serial_number inv_reservation_global.serial_number_tbl_type;
BEGIN

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- construct the record type for the original reservation
   IF p_from_reservation_id IS NOT NULL
     AND p_from_reservation_id <> fnd_api.g_miss_num THEN
      l_orig_rsv_rec.reservation_id               := p_from_reservation_id;
    ELSE
      l_orig_rsv_rec.requirement_date             := p_from_requirement_date;
      l_orig_rsv_rec.organization_id              := p_from_organization_id;
      l_orig_rsv_rec.inventory_item_id            := p_from_inventory_item_id;
      l_orig_rsv_rec.demand_source_type_id        := p_from_demand_type_id;
      l_orig_rsv_rec.demand_source_name           := p_from_demand_name;
      l_orig_rsv_rec.demand_source_header_id      := p_from_demand_header_id;
      l_orig_rsv_rec.demand_source_line_id        := p_from_demand_line_id;
      l_orig_rsv_rec.demand_source_delivery       := p_from_demand_delivery_id;
      l_orig_rsv_rec.primary_uom_code             := p_from_primary_uom_code;
      l_orig_rsv_rec.primary_uom_id               := p_from_primary_uom_id;
      l_orig_rsv_rec.secondary_uom_code           := p_from_secondary_uom_code;     	-- INVCONV
      l_orig_rsv_rec.secondary_uom_id             := p_from_secondary_uom_id;           -- INVCONV
      l_orig_rsv_rec.reservation_uom_code         := p_from_reservation_uom_code;
      l_orig_rsv_rec.reservation_uom_id           := p_from_reservation_uom_id;
      l_orig_rsv_rec.reservation_quantity         := p_from_reservation_quantity;
      l_orig_rsv_rec.primary_reservation_quantity := p_from_primary_rsv_quantity;
      l_orig_rsv_rec.secondary_reservation_quantity := p_from_secondary_rsv_quantity;   -- INVCONV
      l_orig_rsv_rec.autodetail_group_id          := p_from_autodetail_group_id;
      l_orig_rsv_rec.external_source_code         := p_from_external_source_code;
      l_orig_rsv_rec.external_source_line_id      := p_from_external_source_line;
      l_orig_rsv_rec.supply_source_type_id        := p_from_supply_type_id;
      l_orig_rsv_rec.supply_source_header_id      := p_from_supply_header_id;
      l_orig_rsv_rec.supply_source_line_id        := p_from_supply_line_id;
      l_orig_rsv_rec.supply_source_name           := p_from_supply_name;
      l_orig_rsv_rec.supply_source_line_detail    := p_from_supply_line_detail;
      l_orig_rsv_rec.revision                     := p_from_revision;
      l_orig_rsv_rec.subinventory_code            := p_from_subinventory_code;
      l_orig_rsv_rec.subinventory_id              := p_from_subinventory_id;
      l_orig_rsv_rec.locator_id                   := p_from_locator_id;
      l_orig_rsv_rec.lot_number                   := p_from_lot_number;
      l_orig_rsv_rec.lot_number_id                := p_from_lot_number_id;
      l_orig_rsv_rec.pick_slip_number             := p_from_pick_slip_number;
      l_orig_rsv_rec.lpn_id                       := p_from_lpn_id;
      l_orig_rsv_rec.project_id                   := p_from_project_id;
      l_orig_rsv_rec.task_id                      := p_from_task_id;
      l_orig_rsv_rec.ship_ready_flag              := p_from_ship_ready_flag;
      l_orig_rsv_rec.attribute_category           := p_from_attribute_category;
      l_orig_rsv_rec.attribute1                   := p_from_attribute1 ;
      l_orig_rsv_rec.attribute2                   := p_from_attribute2 ;
      l_orig_rsv_rec.attribute3                   := p_from_attribute3 ;
      l_orig_rsv_rec.attribute4                   := p_from_attribute4 ;
      l_orig_rsv_rec.attribute5                   := p_from_attribute5 ;
      l_orig_rsv_rec.attribute6                   := p_from_attribute6 ;
      l_orig_rsv_rec.attribute7                   := p_from_attribute7 ;
      l_orig_rsv_rec.attribute8                   := p_from_attribute8 ;
      l_orig_rsv_rec.attribute9                   := p_from_attribute9 ;
      l_orig_rsv_rec.attribute10                  := p_from_attribute10;
      l_orig_rsv_rec.attribute11                  := p_from_attribute11;
      l_orig_rsv_rec.attribute12                  := p_from_attribute12;
      l_orig_rsv_rec.attribute13                  := p_from_attribute13;
      l_orig_rsv_rec.attribute14                  := p_from_attribute14;
      l_orig_rsv_rec.attribute15                  := p_from_attribute15;
   END IF;

   -- construct the record type for the transfer to record
   l_to_rsv_rec.demand_source_type_id        := p_to_demand_type_id;
   l_to_rsv_rec.demand_source_name           := p_to_demand_name;
   l_to_rsv_rec.demand_source_header_id      := p_to_demand_header_id;
   l_to_rsv_rec.demand_source_line_id        := p_to_demand_line_id;
   l_to_rsv_rec.demand_source_delivery       := p_to_demand_delivery_id;
   l_to_rsv_rec.reservation_uom_code         := p_to_reservation_uom_code;
   l_to_rsv_rec.reservation_quantity         := p_to_reservation_quantity;
   l_to_rsv_rec.secondary_uom_code           := p_to_secondary_uom_code;         	-- INVCONV
   l_to_rsv_rec.secondary_reservation_quantity := p_to_secondary_rsv_quantity;	        -- INVCONV
   l_to_rsv_rec.project_id                   := p_to_project_id;
   l_to_rsv_rec.task_id                      := p_to_task_id;

   inv_reservation_pvt.transfer_reservation
     (
        p_api_version_number        => 1.0
      , p_init_msg_lst              => p_init_msg_lst
      , x_return_status             => l_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_original_rsv_rec          => l_orig_rsv_rec
      , p_to_rsv_rec                => l_to_rsv_rec
      , p_original_serial_number    => l_dummy_serial_number
      , p_validation_flag           => p_validation_flag
      , x_reservation_id            => x_to_reservation_id
      );

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           , p_encoded => 'F'
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
             );

END transfer_demand;
--
PROCEDURE query_reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_reservation_id                IN  NUMBER
   , p_lock_records                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_sort_by_req_date              IN  NUMBER
   , p_cancel_order_mode             IN  NUMBER
   , x_mtl_reservation_tbl
           OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
   , x_mtl_reservation_tbl_count     OUT NOCOPY NUMBER
   , x_error_code                    OUT NOCOPY NUMBER
   ) IS
      l_api_version_number   CONSTANT NUMBER       := 1.0;
      l_api_name             CONSTANT VARCHAR2(30) := 'Query_Reservation';
      l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_rsv_rec              inv_reservation_global.mtl_reservation_rec_type;
BEGIN
   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;
   --
   l_rsv_rec.reservation_id := p_reservation_id;
   inv_reservation_pub.query_reservation
     ( p_api_version_number      => 1.0
       , p_init_msg_lst          => fnd_api.g_false
       , x_return_status         => l_return_status
       , x_msg_count             => x_msg_count
       , x_msg_data              => x_msg_data
       , p_query_input           => l_rsv_rec
       , p_lock_records          => p_lock_records
       , p_sort_by_req_date      => p_sort_by_req_date
       , p_cancel_order_mode     => p_cancel_order_mode
       , x_mtl_reservation_tbl   => x_mtl_reservation_tbl
       , x_mtl_reservation_tbl_count => x_mtl_reservation_tbl_count
       , x_error_code            => x_error_code
       );
   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_return_status := l_return_status;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           , p_encoded => 'F'
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
             );
END query_reservation;

PROCEDURE get_reservable_quantity
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_reservation_id                IN  NUMBER
   , p_reservation_uom_code          IN  VARCHAR2
   , p_demand_type_id                IN  NUMBER
   , p_demand_name                   IN  VARCHAR2
   , p_demand_header_id              IN  NUMBER
   , p_demand_line_id                IN  NUMBER
   , p_demand_delivery_id            IN  NUMBER   DEFAULT NULL
   , p_Project_Id                    In  Number
   , p_Task_ID                       In  Number
   , x_reservable_quantity           OUT NOCOPY NUMBER
   , x_reservation_margin_above      OUT NOCOPY NUMBER                   -- INVCONV
   ) is
      l_api_version_number  CONSTANT NUMBER       := 1.0;
      l_api_name            CONSTANT VARCHAR2(30) := 'get_reservable_quantity';

      --l_line_rec 			OE_Order_PUB.Line_Rec_Type;
      l_ordered_quantity_rsv_uom       	NUMBER := 0;
      l_primary_uom_code  	     	VARCHAR2(3);
      l_primary_reserved_quantity    	NUMBER := 0;
      l_reserved_quantity            	NUMBER := 0;
      l_ship_tolerance_above            NUMBER;          -- INVCONV

      l_org_id	                        NUMBER;
      l_line_rec_inventory_item_id      oe_order_lines_all.inventory_item_id%TYPE;
      l_line_rec_ordered_quantity       oe_order_lines_all.ordered_quantity%TYPE;
      l_line_rec_order_quantity_uom     oe_order_lines_all.order_quantity_uom%TYPE;
      l_line_rec_org_id                 oe_order_lines_all.org_id%TYPE;
      -- R12 Project : SU
      lx_Qty_Available                  Number;

      lx_Qty_Available2                  Number;
      l_Reservable_Quantity2            number;
BEGIN
   -- Initialize return status
   x_return_status := fnd_api.g_ret_sts_success;

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   if p_demand_type_id in (inv_reservation_global.g_source_type_oe,
                           inv_reservation_global.g_source_type_internal_ord,
                           inv_reservation_global.g_source_type_rma) then

        -- Fetch row from oe_order_lines
        --l_line_rec := OE_Line_Util.Query_Row(p_line_id => p_demand_line_id);
	-- Because oe_lines_util.query_row was changed to private, so we need to
	-- query order lines manually

	-- Fix bug 2024374, remove the constraint on org_id,
	--  when the sales order is in another operating unit
	--  it will not get the correct org.
	/*l_org_id := OE_GLOBALS.G_ORG_ID;
            if l_org_id IS NULL THEN
                    OE_GLOBALS.Set_Context;
                    l_org_id := OE_GLOBALS.G_ORG_ID;
            end if;*/
        --INVCONV - Retrieve ship tolerance above for lot indivisible scenarios
	SELECT inventory_item_id, ordered_quantity, order_quantity_uom, ship_from_org_id,
               ship_tolerance_above
	INTO	l_line_rec_inventory_item_id,
		l_line_rec_ordered_quantity,
		l_line_rec_order_quantity_uom,
		l_line_rec_org_id,
                l_ship_tolerance_above
	FROM    oe_order_lines_all
	WHERE	line_id = p_demand_line_id ;
	--AND	 NVL(ORG_ID,NVL(l_org_id,0))= NVL(l_org_id,0) ;

        -- Convert order quantity into reservation uom code
        l_ordered_quantity_rsv_uom :=
        	inv_convert.inv_um_convert
                   (
                    l_line_rec_inventory_item_id,
                    NULL,
                    l_line_rec_ordered_quantity,
                    l_line_rec_order_quantity_uom,
                    p_reservation_uom_code,
                    NULL,
                    NULL);


        -- Fetch quantity reserved so far
     	select nvl(sum(primary_reservation_quantity),0)
        into l_primary_reserved_quantity
        from mtl_reservations
        where demand_source_type_id   = p_demand_type_id
        and   demand_source_header_id = p_demand_header_id
        and   demand_source_line_id   = p_demand_line_id
        and   reservation_id         <> p_reservation_id;

        if l_primary_reserved_quantity > 0 then

        	-- Get primary UOM
        	select primary_uom_code
        	into l_primary_uom_code
        	from mtl_system_items
        	where organization_id   = l_line_rec_org_id
        	and   inventory_item_id = l_line_rec_inventory_item_id;

        	-- Convert primary reservation quantity into
		-- reservation uom code
        	l_reserved_quantity :=
        	  inv_convert.inv_um_convert
                   (
                    l_line_rec_inventory_item_id,
                    NULL,
                    l_primary_reserved_quantity,
                    l_primary_uom_code,
                    p_reservation_uom_code,
                    NULL,
                    NULL);
	else
        	l_reserved_quantity := 0;
	end if;

        -- Quantity that can be still reserved
        x_reservable_quantity := l_ordered_quantity_rsv_uom -
                                 l_reserved_quantity;
        -- INVCONV
        -- Calculate the upper limit on the reservation using ship_tolerance above
        x_reservation_margin_above :=
          l_ordered_quantity_rsv_uom * NVL(l_ship_tolerance_above,0) / 100;
   -- R12 Project Changes : SU
   Else   -- For any other demand call following API
      -- For any other Demand call following API
      Inv_Reservation_Avail_Pvt.Available_Demand_To_Reserve (
         x_Return_Status             => x_Return_Status
        ,x_Msg_Count                 => x_Msg_Count
        ,X_Msg_Data                  => x_Msg_Data
        ,x_qty_Available_to_Reserve  => x_Reservable_Quantity
        ,x_Qty_Available             => lx_Qty_Available
        ,x_qty_available_to_reserve2  => l_Reservable_Quantity2
        ,x_qty_available2             => lx_Qty_Available2
        ,p_Demand_Source_Type_Id     => p_Demand_Type_ID
        ,p_Demand_Source_Header_ID   => p_Demand_HEader_ID
        ,p_Demand_Source_Line_ID     => p_Demand_Line_Id
        ,p_Demand_Source_Line_Detail => p_Demand_Delivery_Id
        ,P_Project_Id                => p_Project_Id
        ,p_Task_Id                   => P_Task_Id
        ,p_API_Version_Number        => 1.0
        ,p_Init_Msg_Lst              => p_Init_Msg_lst );

      IF x_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF ;

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   end if;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        x_reservable_quantity := 0;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           , p_encoded => 'F'
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        x_reservable_quantity := 0;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        x_reservable_quantity := 0;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
             );
END get_reservable_quantity;

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
   ) is
     l_api_version_number   CONSTANT NUMBER       := 1.0;
     l_api_name             CONSTANT VARCHAR2(30) := 'create_move_order_header';

     l_user_id              NUMBER := fnd_global.user_id;
     l_return_status        VARCHAR2(1);
     l_in_trohdr_rec        INV_MOVE_ORDER_PUB.Trohdr_Rec_Type;
     l_in_trohdr_val_rec    INV_MOVE_ORDER_PUB.Trohdr_Val_Rec_Type;
     l_out_trohdr_rec       INV_MOVE_ORDER_PUB.Trohdr_Rec_Type;
     l_out_trohdr_val_rec   INV_MOVE_ORDER_PUB.Trohdr_Val_Rec_Type;

BEGIN
   -- Initialize return status
   x_return_status := fnd_api.g_ret_sts_success;

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   l_in_trohdr_rec.organization_id  := p_organization_id;
   l_in_trohdr_rec.move_order_type  := 8;
   l_in_trohdr_rec.operation        := inv_globals.g_opr_create;
   l_in_trohdr_rec.request_number   := FND_API.G_MISS_CHAR;
   l_in_trohdr_rec.header_id        := FND_API.G_MISS_NUM;
   l_in_trohdr_rec.creation_date    := SYSDATE;
   l_in_trohdr_rec.created_by       := l_user_id;
   l_in_trohdr_rec.last_update_date := SYSDATE;
   l_in_trohdr_rec.last_updated_by  := l_user_id;
   inv_move_order_pub.create_move_order_header
             (p_api_version_number => 1.0,
              p_init_msg_list      => FND_API.G_FALSE,
              p_return_values      => FND_API.G_FALSE,
              p_commit             => FND_API.G_FALSE,
              x_return_status      => l_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data,
              p_trohdr_rec         => l_in_trohdr_rec,
              p_trohdr_val_rec     => l_in_trohdr_val_rec,
              x_trohdr_rec         => l_out_trohdr_rec,
              x_trohdr_val_rec     => l_out_trohdr_val_rec,
              p_validation_flag    => inv_move_order_pub.g_validation_yes);

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_header_id := l_out_trohdr_rec.header_id;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           , p_encoded => 'F'
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
             );
END create_move_order_header;

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
   ) is
     l_api_version_number   CONSTANT NUMBER       := 1.0;
     l_api_name             CONSTANT VARCHAR2(30) := 'create_move_order_line';

     l_user_id              NUMBER := fnd_global.user_id;
     l_return_status        VARCHAR2(1);
     l_in_trolin_tbl        INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
     l_in_trolin_val_tbl    INV_MOVE_ORDER_PUB.Trolin_Val_Tbl_Type;
     l_out_trolin_tbl       INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
     l_out_trolin_val_tbl   INV_MOVE_ORDER_PUB.Trolin_Val_Tbl_Type;

BEGIN
   -- Initialize return status
   x_return_status := fnd_api.g_ret_sts_success;

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   l_in_trolin_tbl(1).operation          := inv_globals.g_opr_create;
   l_in_trolin_tbl(1).header_id          := p_move_order_header_id;
   l_in_trolin_tbl(1).inventory_item_id  := p_inventory_item_id;
   l_in_trolin_tbl(1).organization_id    := p_organization_id;
   l_in_trolin_tbl(1).quantity           := p_quantity;
   l_in_trolin_tbl(1).uom_code           := p_uom_code;
   l_in_trolin_tbl(1).secondary_quantity := p_secondary_quantity;
   l_in_trolin_tbl(1).secondary_uom      := p_secondary_uom;
   l_in_trolin_tbl(1).revision           := p_revision;
   l_in_trolin_tbl(1).date_required      := p_date_required;
   l_in_trolin_tbl(1).creation_date      := SYSDATE;
   l_in_trolin_tbl(1).created_by         := l_user_id;
   l_in_trolin_tbl(1).last_update_date   := SYSDATE;
   l_in_trolin_tbl(1).last_updated_by    := l_user_id;
   l_in_trolin_tbl(1).transaction_type_id  := INV_GLOBALS.G_TYPE_XFER_ORDER_REPL_SUBXFR;
   l_in_trolin_tbl(1).transaction_source_type_id := p_source_type_id;
   l_in_trolin_tbl(1).txn_source_id      := p_source_id;
   l_in_trolin_tbl(1).txn_source_line_id := p_source_line_id;
   l_in_trolin_tbl(1).grade_code         := p_grade_code;
   -- For dual track items, secondary quantity may need to be zeroed.
   IF l_in_trolin_tbl(1).secondary_uom is NOT NULL AND
     l_in_trolin_tbl(1).secondary_quantity IS NULL THEN
     l_in_trolin_tbl(1).secondary_quantity := 0;
   END IF;
   -- bug 5671641 begin
   IF l_in_trolin_tbl(1).transaction_source_type_id = 2 then -- for sales order
     -- populate reference field as 'ORDER_LINE_ID_RSV'
     l_in_trolin_tbl(1).reference := 'ORDER_LINE_ID_RSV';
     l_in_trolin_tbl(1).reference_id := p_source_line_id;
     l_in_trolin_tbl(1).transaction_type_id  := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_STGXFR;
   END IF;
   -- bug 5671641 end

   inv_move_order_pub.create_move_order_lines
          (p_api_version_number => 1.0,
           p_init_msg_list      => FND_API.G_FALSE,
           p_return_values      => FND_API.G_FALSE,
           p_commit             => FND_API.G_FALSE,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_trolin_tbl         => l_in_trolin_tbl,
           p_trolin_val_tbl     => l_in_trolin_val_tbl,
           x_trolin_tbl         => l_out_trolin_tbl,
           x_trolin_val_tbl     => l_out_trolin_val_tbl,
           p_validation_flag    => inv_move_order_pub.g_validation_yes);

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_line_id := l_out_trolin_tbl(1).line_id;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           , p_encoded => 'F'
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
             );
END create_move_order_line;

PROCEDURE delete_move_order
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_move_order_header_id          IN  NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) is
     l_api_version_number   CONSTANT NUMBER       := 1.0;
     l_api_name             CONSTANT VARCHAR2(30) := 'delete_move_order';

     l_user_id              NUMBER := fnd_global.user_id;
     l_return_status        VARCHAR2(1);
     l_trohdr_rec           INV_MOVE_ORDER_PUB.Trohdr_Rec_Type;
     l_in_trohdr_rec        INV_MOVE_ORDER_PUB.Trohdr_Rec_Type;
     l_trohdr_val_rec       INV_MOVE_ORDER_PUB.Trohdr_Val_Rec_Type;
     l_trolin_tbl           INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
     l_trolin_val_tbl       INV_MOVE_ORDER_PUB.Trolin_Val_Tbl_Type;

BEGIN
   -- Initialize return status
   x_return_status := fnd_api.g_ret_sts_success;

   --  Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version_number
                                      , p_api_version_number
                                      , l_api_name
                                      , G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   --
   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_lst) THEN
      fnd_msg_pub.initialize;
   END IF;

   l_in_trohdr_rec.operation := inv_globals.g_opr_delete;
   l_in_trohdr_rec.header_id := p_move_order_header_id;
   inv_move_order_pub.process_move_order
         (p_api_version_number => 1.0,
          p_init_msg_list  => FND_API.G_TRUE,
          p_return_values  => FND_API.G_FALSE,
          p_commit         => FND_API.G_FALSE,
          x_return_status  => l_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_trohdr_rec     => l_in_trohdr_rec,
          x_trohdr_rec     => l_trohdr_rec,
          x_trohdr_val_rec => l_trohdr_val_rec,
          x_trolin_tbl     => l_trolin_tbl,
          x_trolin_val_tbl => l_trolin_val_tbl);

   IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;


EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           , p_encoded => 'F'
           );

   WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
            );

    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
           , p_encoded => 'F'
             );
END delete_move_order;
-- GME CONVERGENCE END

--bug 4097848

FUNCTION demand_source_line_number(
    p_line_number       IN      NUMBER
  , p_shipment_number   IN      NUMBER
  , p_option_number     IN      NUMBER
  , p_component_number  IN      NUMBER
  , p_service_number    IN      NUMBER
)
RETURN VARCHAR2
IS

x_concat_line_number VARCHAR2(256);


BEGIN
  IF p_service_number is not null then
         IF p_option_number is not null then
           IF p_component_number is not null then
             x_concat_line_number := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number||'.'||p_component_number||'.'||
                                           p_service_number;
           ELSE
             x_concat_line_number := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number||'..'||p_service_number;
           END IF;

      --- if  option is not attached
        ELSE
           IF p_component_number is not null then

              x_concat_line_number := p_line_number||'.'||p_shipment_number||'..'||
                                           p_component_number||'.'||p_service_number;
           ELSE
             x_concat_line_number := p_line_number||'.'||p_shipment_number||
                                           '...'||p_service_number;
           END IF;

        END IF; /* if option number is not null */
    -- if the service number is null
    ELSE
         IF p_option_number is not null then
           IF p_component_number is not null then
             x_concat_line_number := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number||'.'||p_component_number;
           ELSE
             x_concat_line_number := p_line_number||'.'||p_shipment_number||'.'||
                                           p_option_number;
          END IF;

      --- if  option is not attached
      ELSE
           IF p_component_number is not null then
             x_concat_line_number := p_line_number||'.'||p_shipment_number||'..'||
                                           p_component_number;
    ELSE

            IF (p_line_number is NULL and p_shipment_number is NULL ) THEN
                x_concat_line_number := NULL;
             ELSE
                x_concat_line_number := p_line_number||'.'||p_shipment_number;
             END IF;
        END IF;

         END IF; /* if option number is not null */

    END IF; /* if service number is not null */

return x_concat_line_number;

EXCEPTION WHEN OTHERS THEN
    return NULL;

END demand_source_line_number;

END inv_reservation_form_pkg ;

/
