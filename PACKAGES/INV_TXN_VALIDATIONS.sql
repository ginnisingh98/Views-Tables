--------------------------------------------------------
--  DDL for Package INV_TXN_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TXN_VALIDATIONS" AUTHID CURRENT_USER AS
/* $Header: INVMWAVS.pls 120.4.12010000.3 2011/09/28 11:51:20 pdong ship $ */

        TYPE t_genref IS REF CURSOR;

   TYPE t_Item_Out IS RECORD(

      Inventory_Item_Id               NUMBER,
      Description                     VARCHAR2(240),
      Revision_Qty_Control_Code       NUMBER,
      Lot_Control_Code                NUMBER,
      Serial_Number_Control_Code      NUMBER,
      Restrict_Locators_Code          NUMBER,
      Location_Control_Code            NUMBER,
      Restrict_Subinventories_Code      NUMBER);

   TYPE t_SN_Out IS RECORD(
      Current_Locator_Id             NUMBER,
      Current_Subinventory_Code      VARCHAR2(10),
      Revision           VARCHAR2(3),
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      Lot_Number            VARCHAR2(80));




   PROCEDURE VALIDATE_ITEM(x_Inventory_Item_Id            OUT NOCOPY NUMBER,
            x_Description                  OUT NOCOPY VARCHAR2,
            x_Revision_Qty_Control_Code    OUT NOCOPY NUMBER,
            x_Lot_Control_Code             OUT NOCOPY NUMBER,
            x_Serial_Number_Control_Code   OUT NOCOPY NUMBER,
            x_Restrict_Locators_Code       OUT NOCOPY NUMBER,
            x_Location_Control_Code        OUT NOCOPY NUMBER,
            x_Restrict_Subinventories_Code OUT NOCOPY NUMBER,
            x_Message                      OUT NOCOPY VARCHAR2,
            x_Status                       OUT NOCOPY VARCHAR2,
            p_Organization_Id              IN  NUMBER,
            p_Concatenated_Segments        IN  VARCHAR2);



   PROCEDURE VALIDATE_SERIAL(x_Current_Locator_Id           OUT NOCOPY NUMBER,
            x_Concatenated_Segments          OUT NOCOPY VARCHAR2, --Locator Name
            x_Current_Subinventory_Code      OUT NOCOPY VARCHAR2,
            x_Revision              OUT NOCOPY VARCHAR2,
            x_Lot_Number          OUT NOCOPY VARCHAR2,
            x_Expiration_Date                OUT NOCOPY DATE,
            x_Message                         OUT NOCOPY VARCHAR2,
            x_Status                          OUT NOCOPY VARCHAR2,
            p_Inventory_Item_Id               IN  NUMBER,
            p_Current_Organization_Id         IN  NUMBER,
            p_Serial_Number          IN  VARCHAR2);



-- This does not use cost_group id
-- Bug 5125915 Added variables demand_source_header and demand_source_line
PROCEDURE GET_AVAILABLE_QUANTITY(
             x_return_status        OUT NOCOPY VARCHAR2,
             p_tree_mode            IN  NUMBER,
             p_organization_id      IN  NUMBER,
             p_inventory_item_id    IN  NUMBER,
             p_is_revision_control  IN  VARCHAR2,
             p_is_lot_control       IN  VARCHAR2,
             p_is_serial_control    IN  VARCHAR2,
             p_demand_source_header_id IN NUMBER DEFAULT -9999,
             p_demand_source_line_id IN NUMBER DEFAULT -9999,
             p_revision             IN  VARCHAR2,
             p_lot_number           IN  VARCHAR2,
             p_lot_expiration_date  IN  DATE,
             p_subinventory_code    IN  VARCHAR2,
             p_locator_id           IN  NUMBER,
             p_source_type_id       IN  NUMBER,
             x_qoh                  OUT NOCOPY NUMBER,
             x_att                  OUT NOCOPY NUMBER
             );

-- Bug# 3952081
-- New Overloaded Version of the previous procedure for OPM convergence
-- Additionally returns secondary qoh, secondary att
-- Additionally takes grade_code as an input param.
PROCEDURE GET_AVAILABLE_QUANTITY(
             x_return_status        OUT NOCOPY VARCHAR2,
             p_tree_mode            IN  NUMBER,
             p_organization_id      IN  NUMBER,
             p_inventory_item_id    IN  NUMBER,
             p_is_revision_control  IN  VARCHAR2,
             p_is_lot_control       IN  VARCHAR2,
             p_is_serial_control    IN  VARCHAR2,
             p_demand_source_header_id IN NUMBER DEFAULT -9999,
             p_demand_source_line_id IN NUMBER DEFAULT -9999,
             p_revision             IN  VARCHAR2,
             p_lot_number           IN  VARCHAR2,
             p_grade_code           IN  VARCHAR2,         -- inv converge
             p_lot_expiration_date  IN  DATE,
             p_subinventory_code    IN  VARCHAR2,
             p_locator_id           IN  NUMBER,
             p_source_type_id       IN  NUMBER,
             x_qoh                  OUT NOCOPY NUMBER,
             x_att                  OUT NOCOPY NUMBER,
             x_sqoh                 OUT NOCOPY NUMBER,   -- inv converge
             x_satt                 OUT NOCOPY NUMBER    -- inv converge
             );



-- This uses cost group id
PROCEDURE GET_AVAILABLE_QUANTITY(
             x_return_status        OUT NOCOPY VARCHAR2,
             p_tree_mode            IN  NUMBER,
             p_organization_id      IN  NUMBER,
             p_inventory_item_id    IN  NUMBER,
             p_is_revision_control  IN  VARCHAR2,
             p_is_lot_control       IN  VARCHAR2,
             p_is_serial_control    IN  VARCHAR2,
             p_revision             IN  VARCHAR2,
             p_lot_number           IN  VARCHAR2,
             p_lot_expiration_date  IN  DATE,
             p_subinventory_code    IN  VARCHAR2,
             p_locator_id           IN  NUMBER,
             p_source_type_id       IN  NUMBER,
             p_cost_group_id        IN  NUMBER,
             x_qoh                  OUT NOCOPY NUMBER,
             x_att                  OUT NOCOPY NUMBER
             );

-- Bug# 3952081
-- New Overloaded Version of the previous procedure for OPM convergence
-- Additionally returns secondary qoh, secondary att
-- Additionally takes grade_code as an input param.
PROCEDURE GET_AVAILABLE_QUANTITY(
             x_return_status        OUT NOCOPY VARCHAR2,
             p_tree_mode            IN  NUMBER,
             p_organization_id      IN  NUMBER,
             p_inventory_item_id    IN  NUMBER,
             p_is_revision_control  IN  VARCHAR2,
             p_is_lot_control       IN  VARCHAR2,
             p_is_serial_control    IN  VARCHAR2,
             p_revision             IN  VARCHAR2,
             p_lot_number           IN  VARCHAR2,
             p_grade_code           IN  VARCHAR2,         -- inv converge
             p_lot_expiration_date  IN  DATE,
             p_subinventory_code    IN  VARCHAR2,
             p_locator_id           IN  NUMBER,
             p_source_type_id       IN  NUMBER,
             p_cost_group_id        IN  NUMBER,
             x_qoh                  OUT NOCOPY NUMBER,
             x_att                  OUT NOCOPY NUMBER,
             x_sqoh                 OUT NOCOPY NUMBER,   -- inv converge
             x_satt                 OUT NOCOPY NUMBER    -- inv converge
             );

-- Bug# 2358224
-- Overloaded version of the previous procedure
-- passing in the to/transfer subinventory
-- This uses cost group id and transfer subinventory
PROCEDURE GET_AVAILABLE_QUANTITY(
             x_return_status         OUT NOCOPY VARCHAR2,
             p_tree_mode             IN  NUMBER,
             p_organization_id       IN  NUMBER,
             p_inventory_item_id     IN  NUMBER,
             p_is_revision_control   IN  VARCHAR2,
             p_is_lot_control        IN  VARCHAR2,
             p_is_serial_control     IN  VARCHAR2,
             p_revision              IN  VARCHAR2,
             p_lot_number            IN  VARCHAR2,
             p_lot_expiration_date   IN  DATE,
             p_subinventory_code     IN  VARCHAR2,
             p_locator_id            IN  NUMBER,
             p_source_type_id        IN  NUMBER,
             p_cost_group_id         IN  NUMBER,
             p_to_subinventory_code  IN  VARCHAR2,
             x_qoh                   OUT NOCOPY NUMBER,
             x_att                   OUT NOCOPY NUMBER
             );

--BUG11812327 ,
-- Overloaded version of the previous procedure
-- return the total onhand qty
PROCEDURE GET_AVAILABLE_QUANTITY(
				 x_return_status         OUT NOCOPY VARCHAR2,
				 p_tree_mode             IN  NUMBER,
				 p_organization_id       IN  NUMBER,
				 p_inventory_item_id     IN  NUMBER,
				 p_is_revision_control   IN  VARCHAR2,
				 p_is_lot_control        IN  VARCHAR2,
				 p_is_serial_control     IN  VARCHAR2,
				 p_revision              IN  VARCHAR2,
				 p_lot_number            IN  VARCHAR2,
				 p_lot_expiration_date   IN  DATE,
				 p_subinventory_code     IN  VARCHAR2,
				 p_locator_id            IN  NUMBER,
				 p_source_type_id        IN  NUMBER,
				 p_cost_group_id         IN  NUMBER,
				 p_to_subinventory_code  IN  VARCHAR2,
				 x_qoh                   OUT NOCOPY NUMBER,
				 x_att                   OUT NOCOPY NUMBER,
                                 x_tqoh                  OUT NOCOPY NUMBER
				 );

-- Bug# 3952081
-- New Overloaded Version of the previous procedure for OPM convergence
-- Additionally returns secondary qoh, secondary att
-- Additionally takes grade_code as an input param.
PROCEDURE GET_AVAILABLE_QUANTITY(
             x_return_status        OUT NOCOPY VARCHAR2,
             p_tree_mode            IN NUMBER,
             p_organization_id      IN NUMBER,
             p_inventory_item_id    IN NUMBER,
             p_is_revision_control  IN VARCHAR2,
             p_is_lot_control       IN VARCHAR2,
             p_is_serial_control    IN VARCHAR2,
             p_revision             IN VARCHAR2,
             p_lot_number           IN VARCHAR2,
             p_grade_code           IN VARCHAR2,         -- inv converge
             p_lot_expiration_date  IN DATE,
             p_subinventory_code    IN VARCHAR2,
             p_locator_id           IN NUMBER,
             p_source_type_id       IN NUMBER,
             p_cost_group_id        IN NUMBER,
             p_to_subinventory_code IN VARCHAR2,
             x_qoh                  OUT NOCOPY NUMBER,
             x_att                  OUT NOCOPY NUMBER,
             x_sqoh                 OUT NOCOPY NUMBER,   -- inv converge
             x_satt                 OUT NOCOPY NUMBER    -- inv converge
             );


-- This procedure calls INV_QUANTITY_TREE_PVT to return pqoh
PROCEDURE GET_AVAILABLE_QUANTITY(
            x_return_status        OUT NOCOPY VARCHAR2,
            p_tree_mode            IN  NUMBER,
            p_organization_id      IN  NUMBER,
            p_inventory_item_id    IN  NUMBER,
            p_is_revision_control  IN  VARCHAR2,
            p_is_lot_control       IN  VARCHAR2,
            p_is_serial_control    IN  VARCHAR2,
            p_revision             IN  VARCHAR2,
            p_lot_number           IN  VARCHAR2,
            p_lot_expiration_date  IN  DATE,
            p_subinventory_code    IN  VARCHAR2,
            p_locator_id           IN  NUMBER,
            p_source_type_id       IN  NUMBER,
            x_qoh                  OUT NOCOPY NUMBER,
            x_att                  OUT NOCOPY NUMBER,
            x_pqoh                 OUT NOCOPY NUMBER,
            x_tqoh                 OUT NOCOPY NUMBER,
            x_atpp1                OUT NOCOPY NUMBER,
            x_qoh1                 OUT NOCOPY NUMBER
            );

-- Bug# 3952081
-- New Overloaded Version of the previous procedure for OPM convergence
-- Additionally returns secondary qoh, secondary att
-- Additionally takes grade_code as an input param.
PROCEDURE GET_AVAILABLE_QUANTITY(
            x_return_status        OUT NOCOPY VARCHAR2,
            p_tree_mode            IN  NUMBER,
            p_organization_id      IN  NUMBER,
            p_inventory_item_id    IN  NUMBER,
            p_is_revision_control  IN  VARCHAR2,
            p_is_lot_control       IN  VARCHAR2,
            p_is_serial_control    IN  VARCHAR2,
            p_revision             IN  VARCHAR2,
            p_lot_number           IN  VARCHAR2,
            p_grade_code           IN  VARCHAR2,
            p_lot_expiration_date  IN  DATE,
            p_subinventory_code    IN  VARCHAR2,
            p_locator_id           IN  NUMBER,
            p_source_type_id       IN  NUMBER,
            x_qoh                  OUT NOCOPY NUMBER,
            x_att                  OUT NOCOPY NUMBER,
            x_pqoh                 OUT NOCOPY NUMBER,
            x_tqoh                 OUT NOCOPY NUMBER,
            x_atpp1                OUT NOCOPY NUMBER,
            x_qoh1                 OUT NOCOPY NUMBER,
            x_sqoh                  OUT NOCOPY NUMBER,
            x_satt                  OUT NOCOPY NUMBER,
            x_spqoh                 OUT NOCOPY NUMBER,
            x_stqoh                 OUT NOCOPY NUMBER,
            x_satpp1                OUT NOCOPY NUMBER,
            x_sqoh1                 OUT NOCOPY NUMBER
            );

/* This Overloaded Procedure Calls INV_QUANTITY_TREE_PVT to return pqoh.
--This procedure takes in the cost group
*/

PROCEDURE GET_AVAILABLE_QUANTITY(
            x_return_status         OUT NOCOPY VARCHAR2,
            p_tree_mode             IN  NUMBER,
            p_organization_id       IN  NUMBER,
            p_inventory_item_id     IN  NUMBER,
            p_is_revision_control   IN  VARCHAR2,
            p_is_lot_control        IN  VARCHAR2,
            p_is_serial_control     IN  VARCHAR2,
            p_revision              IN  VARCHAR2,
            p_lot_number            IN  VARCHAR2,
            p_lot_expiration_date   IN  DATE,
            p_subinventory_code     IN  VARCHAR2,
            p_locator_id            IN  NUMBER,
            p_source_type_id        IN  NUMBER,
            x_qoh                   OUT NOCOPY NUMBER,
            x_att                   OUT NOCOPY NUMBER,
            x_pqoh                  OUT NOCOPY NUMBER,
            x_tqoh                  OUT NOCOPY NUMBER,
            x_atpp1                 OUT NOCOPY NUMBER,
            x_qoh1                  OUT NOCOPY NUMBER,
            p_cost_group_id         IN  NUMBER,
            p_transfer_subinventory IN  VARCHAR2
            );

-- Bug# 3952081
-- New Overloaded Version of the previous procedure for OPM convergence
-- Additionally returns secondary qoh, secondary att
-- Additionally takes grade_code as an input param.
PROCEDURE GET_AVAILABLE_QUANTITY(
            x_return_status         OUT NOCOPY VARCHAR2,
            p_tree_mode             IN  NUMBER,
            p_organization_id       IN  NUMBER,
            p_inventory_item_id     IN  NUMBER,
            p_is_revision_control   IN  VARCHAR2,
            p_is_lot_control        IN  VARCHAR2,
            p_is_serial_control     IN  VARCHAR2,
            p_revision              IN  VARCHAR2,
            p_lot_number            IN  VARCHAR2,
            p_grade_code            IN  VARCHAR2,
            p_lot_expiration_date   IN  DATE,
            p_subinventory_code     IN  VARCHAR2,
            p_locator_id            IN  NUMBER,
            p_source_type_id        IN  NUMBER,
            x_qoh                   OUT NOCOPY NUMBER,
            x_att                   OUT NOCOPY NUMBER,
            x_pqoh                  OUT NOCOPY NUMBER,
            x_tqoh                  OUT NOCOPY NUMBER,
            x_atpp1                 OUT NOCOPY NUMBER,
            x_qoh1                  OUT NOCOPY NUMBER,
            x_sqoh                   OUT NOCOPY NUMBER,
            x_satt                   OUT NOCOPY NUMBER,
            x_spqoh                  OUT NOCOPY NUMBER,
            x_stqoh                  OUT NOCOPY NUMBER,
            x_satpp1                 OUT NOCOPY NUMBER,
            x_sqoh1                  OUT NOCOPY NUMBER,
            p_cost_group_id         IN  NUMBER,
            p_transfer_subinventory IN  VARCHAR2
            );



PROCEDURE CHECK_LOOSE_QUANTITY(
                                p_api_version_number    IN   NUMBER
                              , p_init_msg_lst          IN   VARCHAR2 DEFAULT fnd_api.g_false
                              , x_return_status         OUT  NOCOPY VARCHAR2
                              , x_msg_count             OUT  NOCOPY NUMBER
                              , x_msg_data              OUT  NOCOPY VARCHAR2
                              , p_organization_id       IN   NUMBER
                              , p_inventory_item_id     IN   NUMBER
                              , p_is_revision_control   IN   VARCHAR2
                              , p_is_lot_control        IN   VARCHAR2
                              , p_is_serial_control     IN   VARCHAR2
                              , p_revision              IN   VARCHAR2
                              , p_lot_number            IN   VARCHAR2
                              , p_transaction_quantity  IN   NUMBER
                              , p_transaction_uom       IN   VARCHAR2
                              , p_subinventory_code     IN   VARCHAR2
                              , p_locator_id            IN   NUMBER
                              , p_transaction_temp_id   IN   NUMBER
                              , p_ok_to_process         OUT  NOCOPY VARCHAR2
                              , p_transfer_subinventory IN   VARCHAR2);


PROCEDURE CHECK_WMS_INSTALL (x_return_status  OUT NOCOPY VARCHAR2,
                               p_msg_count    OUT NOCOPY NUMBER,
                               p_msg_data     OUT NOCOPY VARCHAR2,
                               p_org          IN NUMBER
                              );

FUNCTION validate_lpn_status_quantity(
                                      p_lpn_id IN NUMBER,
                                      p_orgid IN NUMBER,
                                      p_to_org_id IN NUMBER,
                                      p_wms_installed IN VARCHAR2,
                                      p_transaction_type_id IN NUMBER,
                       p_source_type_id IN NUMBER,
                       x_return_msg OUT NOCOPY VARCHAR2
                                     )
  RETURN VARCHAR2;

-- Bug# 2358224
-- Overloaded version of the previous function passing in
-- the to/transfer subinventory
FUNCTION validate_lpn_status_quantity(
                                      p_lpn_id                IN  NUMBER,
                                      p_orgid                 IN  NUMBER,
                                      p_to_org_id             IN  NUMBER,
                                      p_wms_installed         IN  VARCHAR2,
                                      p_transaction_type_id   IN  NUMBER,
                       p_source_type_id        IN  NUMBER,
                  p_to_subinventory_code  IN  VARCHAR2,
                       x_return_msg            OUT NOCOPY VARCHAR2
                                     )
  RETURN VARCHAR2;


FUNCTION validate_lpn_status_quantity2(
                                      p_lpn_id IN NUMBER,
                                      p_orgid IN NUMBER,
                                      p_to_org_id IN NUMBER,
                                      p_wms_installed IN VARCHAR2,
                                      p_transaction_type_id IN NUMBER,
                       p_source_type_id IN NUMBER,
                       x_return_msg OUT NOCOPY VARCHAR2
                                     )
  RETURN VARCHAR2;


FUNCTION orgxfer_lpn_check(
                                      p_lpn_id IN NUMBER,
                                      p_orgid IN NUMBER,
                                      p_to_org_id IN NUMBER,
                                      p_wms_installed IN VARCHAR2,
                                      p_transaction_type_id IN NUMBER,
                                      p_source_type_id IN NUMBER,
                                      x_return_msg OUT NOCOPY VARCHAR2
                                     )
  RETURN VARCHAR2;


FUNCTION check_lpn_quantity(
             p_lpn_id               IN NUMBER,
             p_organization_id      IN  NUMBER,
             p_source_type_id       IN  NUMBER,
             p_transaction_type_id  IN NUMBER,
             x_return_msg           OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 ;


-- Bug# 2358224
-- Overloaded version of the previous function passing in
-- the to/transfer subinventory
-- Bug # 2433095 -- Changes to LPN reservations ported to the ovreloaded function
FUNCTION check_lpn_quantity(
             p_lpn_id                IN  NUMBER,
             p_organization_id       IN  NUMBER,
             p_source_type_id        IN  NUMBER,
             p_transaction_type_id   IN NUMBER,
             p_to_subinventory_code  IN  VARCHAR2,
             x_return_msg            OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 ;


FUNCTION get_immediate_lpn_item_qty ( p_lpn_id     IN  NUMBER,
             p_organization_id      IN  NUMBER,
             p_source_type_id       IN  NUMBER,
             p_inventory_item_id    IN  NUMBER,
             p_revision             IN  VARCHAR2,
             p_locator_id           IN  NUMBER,
             p_subinventory_code    IN  VARCHAR2,
             p_lot_number           IN  VARCHAR2,
             p_is_revision_control  IN  VARCHAR2,
             p_is_serial_control    IN  VARCHAR2,
             p_is_lot_control       IN  VARCHAR2,
             x_transactable_qty     OUT NOCOPY NUMBER,
             x_qoh                  OUT NOCOPY NUMBER,
             x_lpn_onhand           OUT NOCOPY NUMBER,
             x_return_msg           OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 ;

-- Gets the immediate quantity of an item in an LPN.
-- Overloaded function with the following new output parameters (INVCONV):
--    x_transactable_sec_qty OUT NOCOPY NUMBER,
--    x_sqoh OUT NOCOPY NUMBER,
---   x_lpn_sec_onhand OUT NOCOPY NUMBER,

FUNCTION get_immediate_lpn_item_qty(p_lpn_id IN NUMBER,
                                    p_organization_id IN NUMBER,
                                    p_source_type_id IN NUMBER,
                                    p_inventory_item_id IN NUMBER,
                                    p_revision IN VARCHAR2,
                                    p_locator_id IN NUMBER,
                                    p_subinventory_code IN VARCHAR2,
                                    p_lot_number IN VARCHAR2,
                                    p_is_revision_control IN VARCHAR2,
                                    p_is_serial_control IN VARCHAR2,
                                    p_is_lot_control IN VARCHAR2,
                                    x_transactable_qty OUT NOCOPY NUMBER,
                                    x_qoh OUT NOCOPY NUMBER,
                                    x_lpn_onhand OUT NOCOPY NUMBER,
                                    x_transactable_sec_qty OUT NOCOPY NUMBER,
                                    x_sqoh OUT NOCOPY NUMBER,
                                    x_lpn_sec_onhand OUT NOCOPY NUMBER,
                                    x_return_msg OUT NOCOPY VARCHAR2)

  RETURN VARCHAR2;

FUNCTION get_unpacksplit_lpn_item_qty(p_lpn_id IN NUMBER,
                                    p_organization_id IN NUMBER,
                                    p_source_type_id IN NUMBER,
                                    p_inventory_item_id IN NUMBER,
                        p_revision IN VARCHAR2,
                     p_locator_id IN NUMBER,
                     p_subinventory_code IN VARCHAR2,
                     p_lot_number IN VARCHAR2,
                     p_is_revision_control IN VARCHAR2,
                     p_is_serial_control IN VARCHAR2,
                     p_is_lot_control IN VARCHAR2,
                     p_transfer_subinventory_code IN VARCHAR2,
                     p_transfer_locator_id        IN NUMBER,
                     x_transactable_qty OUT NOCOPY NUMBER,
                     x_qoh OUT NOCOPY NUMBER,
                     x_lpn_onhand OUT NOCOPY NUMBER,
                     x_return_msg OUT NOCOPY VARCHAR2)
 RETURN VARCHAR2 ;



 FUNCTION  CHECK_SERIAL_UNPACKSPLIT( p_lpn_id     IN  NUMBER
                                    ,p_org_id     IN  NUMBER
                                    ,p_item_id    IN  NUMBER
                                    ,p_rev        IN  VARCHAR2
                                    ,p_lot        IN  VARCHAR2
                                    ,p_serial     IN  VARCHAR2)
RETURN VARCHAR2;

--"Returns"
PROCEDURE GET_RETURN_LOT_QUANTITIES(
         x_lot_qty  OUT NOCOPY t_genref
   ,     p_org_id   IN  NUMBER
   ,     p_lpn_id   IN  NUMBER
   ,     p_item_id  IN  NUMBER
   ,     p_revision IN  VARCHAR2
   ,     p_uom      IN  VARCHAR2);

PROCEDURE GET_RETURN_TOTAL_QTY(
         x_tot_qty  OUT NOCOPY t_genref
   ,     p_org_id   IN  NUMBER
   ,     p_lpn_id   IN  NUMBER
   ,     p_item_id  IN  NUMBER
   ,     p_revision IN  VARCHAR2
   ,     p_uom      IN  VARCHAR2);
--"Returns"



-- This procedure validates the serial number, to sub and to loc for a
-- serial triggered sub transfer. It also updates the quantity tree. It
-- sets the GROUP mark ID of the serial number to a non null value. It also
-- inserts into MMTT, MTLT and MSNT tables for the sub transfer transaction
PROCEDURE process_serial_subxfr(p_organization_id       IN  NUMBER,
            p_serial_number         IN  VARCHAR2,
            p_inventory_item_id     IN  NUMBER,
            p_inventory_item        IN  VARCHAR2,
            --I Development Bug 2634570
            p_project_id      IN  NUMBER,
            p_task_id      IN  NUMBER,

            p_revision              IN  VARCHAR2,
            p_primary_uom_code      IN  VARCHAR2,
            p_subinventory_code     IN  VARCHAR2,
            p_locator_id            IN  NUMBER,
            p_locator               IN  VARCHAR2,
            p_to_subinventory_code  IN  VARCHAR2,
            p_to_locator            IN  VARCHAR2,
            p_to_locator_id         IN  NUMBER,
            p_reason_id             IN  NUMBER,
            p_lot_number            IN  VARCHAR2,
            p_wms_installed         IN  VARCHAR2,
            p_transaction_action_id IN  NUMBER,
            p_transaction_type_id   IN  VARCHAR2,
            p_source_type_id        IN  NUMBER,
            p_user_id               IN  NUMBER,
            p_transaction_header_id IN  NUMBER,
            p_restrict_sub_code     IN  NUMBER,
            p_restrict_loc_code     IN  NUMBER,
            p_from_sub_asset_inv    IN  NUMBER,
            p_serial_control_code   IN  NUMBER,
            p_process_serial        IN  VARCHAR2,
            x_serial_processed      OUT NOCOPY VARCHAR2,
            x_transaction_header_id OUT NOCOPY NUMBER,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_return_msg            OUT NOCOPY VARCHAR2);

PROCEDURE check_loose_and_packed_qty
  (p_api_version_number      IN   NUMBER
   , p_init_msg_lst          IN   VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status         OUT  NOCOPY VARCHAR2
   , x_msg_count             OUT  NOCOPY NUMBER
   , x_msg_data              OUT  NOCOPY VARCHAR2
   , p_organization_id       IN   NUMBER
   , p_inventory_item_id     IN   NUMBER
   , p_is_revision_control   IN   VARCHAR2
   , p_is_lot_control        IN   VARCHAR2
   , p_is_serial_control     IN   VARCHAR2
   , p_revision              IN   VARCHAR2
   , p_lot_number            IN   VARCHAR2
   , p_transaction_quantity  IN   NUMBER
   , p_transaction_uom       IN   VARCHAR2
   , p_subinventory_code     IN   VARCHAR2
   , p_locator_id            IN   NUMBER
   , p_transaction_temp_id   IN   NUMBER
   , p_ok_to_process         OUT  NOCOPY VARCHAR2
   , p_transfer_subinventory IN   VARCHAR2
   );

FUNCTION check_lpn_allocation(p_lpn_id IN NUMBER,
               p_org_id IN NUMBER,
               x_return_msg OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

FUNCTION check_lpn_serial_allocation(p_lpn_id IN NUMBER,
                 p_org_id IN NUMBER,
                 x_return_msg OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

/* Bug 4194323 Added Procedure to get available quantity
    when Demand Information is provided for WIP Enhancement 4163405 */
PROCEDURE GET_AVBL_TO_TRANSACT_QTY(
             x_return_status OUT NOCOPY VARCHAR2,
             p_organization_id IN NUMBER,
             p_inventory_item_id IN NUMBER,
                                 p_is_revision_control IN VARCHAR2,
                                 p_is_lot_control IN VARCHAR2,
                                 p_is_serial_control  IN VARCHAR2,
             p_demand_source_type_id IN NUMBER,
             p_demand_source_header_id IN NUMBER,
             p_demand_source_line_id IN NUMBER,
             p_revision IN VARCHAR2,
             p_lot_number IN VARCHAR2,
             p_lot_expiration_date IN  DATE,
             p_subinventory_code IN  VARCHAR2,
             p_locator_id IN NUMBER,
             x_att  OUT NOCOPY NUMBER
             ) ;
--Bug#4446248.Added the following function to check any pending transaction
--for the LPN/inner LPNs .
FUNCTION check_lpn_pending_txns( p_lpn_id IN NUMBER,
               p_org_id IN NUMBER,
               x_return_msg OUT NOCOPY VARCHAR2)
 RETURN VARCHAR2;


END INV_TXN_VALIDATIONS;

/
