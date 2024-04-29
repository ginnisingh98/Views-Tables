--------------------------------------------------------
--  DDL for Package INV_CONSIGNED_VALIDATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CONSIGNED_VALIDATIONS_GRP" AUTHID CURRENT_USER AS
/* $Header: INVVMIGS.pls 120.1 2005/06/16 15:30:01 appldev  $ */

/** This package is created as part of Consign Inventory in patchset I
 ** This contains the public APIs that can be called from other product*/

/*------------------*
 * Global variables *
 *------------------*/
-- Onhand Source
--  Defined in mtl_onhand_source lookup
--  Used to determine which subs are included in calculation of
--  onhand qty
g_atpable_only    CONSTANT NUMBER := 1;
g_nettable_only   CONSTANT NUMBER := 2;
g_all_subs        CONSTANT NUMBER := 3;

-- Containerized
--  Used to indicate packed quantities for use in quantity calculations
--  If 0, then record is not packed in container.
--  If 1, then record is packed in containter.
g_containerized_true      CONSTANT NUMBER := 1;
g_containerized_false     CONSTANT NUMBER := 0;

-- pjm support
g_unit_eff_enabled VARCHAR(1) := NULL;

--Modes
g_reservation_mode CONSTANT INTEGER := 1;
g_transaction_mode CONSTANT INTEGER := 2;
g_loose_only_mode  CONSTANT INTEGER := 3;

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_CONSIGNED_VALIDATIONS_GRP';

-- Query Mode
-- This is used when query VMI/CONSIGNED quantity
-- G_TXN_MODE(Transaction Mode) is for VMI/Consign Receipt/Issue, and
--    Min-Max report of VMI stock. API will query the quantity tree and
--    returns the minimum of available-to-transact(from tree) and VMI/Consign
--    onhand quantity
-- G_XFR_MODE(Transfer mode) is for VMI/Consign transfer to regular transaction
--    Because there is no quantity change, only the property of onhand will change
--    , it does not query quantity tree, only returns the VMI/Consigned quantity
-- G_REG_MODE(Regular mode) is for 'Regular transfer to consign' transaction
--    It will return non-consigned onhand quantity.
G_TXN_MODE   CONSTANT INTEGER :=1;
G_XFR_MODE   CONSTANT INTEGER :=2;
G_REG_MODE   CONSTANT INTEGER :=3;

/*----------------*
 * API Spec       *
 *----------------*/

--The API GET_CONSIGNED_QUANTITY returns the onhand quantity and
--  available to transact quantities for three kinds of VMI/CONSIGN
--  related transactions.
--  It intern calls INV_CONSIGNED_VALIDATIONS.GET_CONSIGNED_QUANTITY()

PROCEDURE GET_CONSIGNED_QUANTITY(
   p_api_version_number       IN  NUMBER DEFAULT 1.0
,  p_init_msg_lst             IN  VARCHAR2 DEFAULT fnd_api.g_false
,  x_return_status            OUT NOCOPY VARCHAR2
,  x_msg_count                OUT NOCOPY NUMBER
,  x_msg_data                 OUT NOCOPY VARCHAR2
,  p_tree_mode                IN NUMBER
,  p_organization_id          IN NUMBER
,  p_owning_org_id            IN NUMBER
,  p_planning_org_id          IN NUMBER
,  p_inventory_item_id        IN NUMBER
,  p_is_revision_control      IN VARCHAR2
,  p_is_lot_control           IN VARCHAR2
,  p_is_serial_control        IN VARCHAR2
,  p_revision                 IN VARCHAR2
,  p_lot_number               IN VARCHAR2
,  p_lot_expiration_date      IN DATE
,  p_subinventory_code        IN VARCHAR2
,  p_locator_id               IN NUMBER
,  p_source_type_id           IN NUMBER  DEFAULT -999
,  p_demand_source_line_id    IN NUMBER  DEFAULT NULL
,  p_demand_source_header_id  IN NUMBER  DEFAULT -999
,  p_demand_source_name       IN VARCHAR2 DEFAULT NULL
,  p_onhand_source            IN NUMBER DEFAULT g_all_subs
,  p_cost_group_id            IN NUMBER
,  p_query_mode               IN NUMBER
,  x_qoh                      OUT NOCOPY NUMBER
,  x_att  				      OUT NOCOPY NUMBER
);

-- invConv changes begin : Overloaded API
PROCEDURE GET_CONSIGNED_QUANTITY(
   p_api_version_number       IN  NUMBER
,  p_init_msg_lst             IN  VARCHAR2
,  x_return_status            OUT NOCOPY VARCHAR2
,  x_msg_count                OUT NOCOPY NUMBER
,  x_msg_data                 OUT NOCOPY VARCHAR2
,  p_tree_mode                IN NUMBER
,  p_organization_id          IN NUMBER
,  p_owning_org_id            IN NUMBER
,  p_planning_org_id          IN NUMBER
,  p_inventory_item_id        IN NUMBER
,  p_is_revision_control      IN VARCHAR2
,  p_is_lot_control           IN VARCHAR2
,  p_is_serial_control        IN VARCHAR2
,  p_revision                 IN VARCHAR2
,  p_lot_number               IN VARCHAR2
,  p_lot_expiration_date      IN DATE
,  p_subinventory_code        IN VARCHAR2
,  p_locator_id               IN NUMBER
,  p_grade_code               IN VARCHAR2                   -- invConv changes
,  p_source_type_id           IN NUMBER
,  p_demand_source_line_id    IN NUMBER
,  p_demand_source_header_id  IN NUMBER
,  p_demand_source_name       IN VARCHAR2
,  p_onhand_source            IN NUMBER
,  p_cost_group_id            IN NUMBER
,  p_query_mode               IN NUMBER
,  x_qoh                      OUT NOCOPY NUMBER
,  x_att                      OUT NOCOPY NUMBER
,  x_sqoh                     OUT NOCOPY NUMBER             -- invConv changes
,  x_satt                     OUT NOCOPY NUMBER);           -- invConv changes
-- invConv changes end.

-- This API returns the onhand quantity for planning purpose
-- , which does not include VMI quantity
-- The quantity is calculated with onhand quantity from
-- MTL_ONHAND_QUANTITIES_DETAIL and pending transactions from
-- MTL_MATERIAL_TRANSACTIONS_TEMP
-- The quantities does not include suggestions
-- Input Parameters
--  P_INCLUDE_NONNET: Whether include non-nettable subinventories
--      Values: 1 => Include non-nettable subinventories
--              2 => Only include nettabel subinventores
--  P_LEVEL: Query onhand at Organization level (1)
--                        or Subinventory level (2)
--  P_ORG_ID: Organization ID
--  P_SUBINV: Subinventory
--  P_ITEM_ID: Item ID

-- Note that this may includes pending transactions that
-- will keep the VMI attributes of inventory stock

-- It intern calls INV_CONSIGNED_VALIDATIONS.GET_PLANNING_QUANTITY()
PROCEDURE GET_PLANNING_QUANTITY(
   p_api_version_number IN  NUMBER DEFAULT 1.0
,  p_init_msg_lst       IN  VARCHAR2 DEFAULT fnd_api.g_false
,  x_return_status      OUT NOCOPY VARCHAR2
,  x_msg_count          OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
,  p_include_nonnet     IN  NUMBER
,  p_level              IN  NUMBER
,  p_org_id             IN  NUMBER
,  p_subinv             IN  VARCHAR2
,  p_item_id            IN  NUMBER
,  x_planning_qty       OUT NOCOPY NUMBER
);

-- invConv changes begin : new overloaded API
PROCEDURE GET_PLANNING_QUANTITY(
   p_api_version_number IN  NUMBER
,  p_init_msg_lst       IN  VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  x_msg_count          OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
,  p_include_nonnet     IN  NUMBER
,  p_level              IN  NUMBER
,  p_org_id             IN  NUMBER
,  p_subinv             IN  VARCHAR2
,  p_item_id            IN  NUMBER
,  p_grade_code         IN  VARCHAR2                       -- invConv change
,  x_planning_qty       OUT NOCOPY NUMBER
,  x_planning_sqty      OUT NOCOPY NUMBER);                -- invConv change
-- invConv changes end.

--Bug 4239469: Added this new function to get the available qty
-- This API returns the onhand quantity for planning purpose
-- , which does not include VMI quantity but checks ATP condition also
-- The quantity is calculated with onhand quantity from
-- MTL_ONHAND_QUANTITIES_DETAIL and pending transactions from
-- MTL_MATERIAL_TRANSACTIONS_TEMP
-- The quantities does not include suggestions
-- Input Parameters
--  P_ONHAND_SOURCE: Whether include non-nettable subinventories
--      Values: g_atpable_only => Only Include atpable subinventories
--              g_nettable_only => Only include nettabl subinventores
--              g_all_subs      => include all subinventores
--  P_ORG_ID: Organization ID
--  P_ITEM_ID: Item ID

-- Note that this may includes pending transactions that
-- will keep the VMI attributes of inventory stock

-- It intern calls INV_CONSIGNED_VALIDATIONS.GET_PLANNING_SD_QUANTITY()
PROCEDURE get_planning_sd_quantity
  (
     p_api_version_number IN  NUMBER DEFAULT 1.0
     ,  p_init_msg_lst       IN  VARCHAR2 DEFAULT fnd_api.g_false
     ,  x_return_status      OUT NOCOPY VARCHAR2
     ,  x_msg_count          OUT NOCOPY NUMBER
     ,  x_msg_data           OUT NOCOPY VARCHAR2
     ,  p_onhand_source      IN  NUMBER
     ,  p_org_id             IN  NUMBER
     ,  p_item_id            IN  NUMBER
     ,  x_planning_qty       OUT NOCOPY NUMBER
     );


END INV_CONSIGNED_VALIDATIONS_GRP;

 

/
