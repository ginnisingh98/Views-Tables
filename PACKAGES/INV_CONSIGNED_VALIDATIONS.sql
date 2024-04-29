--------------------------------------------------------
--  DDL for Package INV_CONSIGNED_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CONSIGNED_VALIDATIONS" AUTHID CURRENT_USER AS
/* $Header: INVVMILS.pls 120.1.12010000.2 2008/07/29 12:55:34 ptkumar ship $ */

/** This package is created as part of VMI quantities in patchset H
 ** and continue to support Consigned inventory from patchset I */

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

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_VMI_VALIDATIONS';

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
-- It will first check whether there is data populated in global
--  temp table mtl_consigned_qty_temp (invvmitb.sql). If not, it first
--  populate the temp table with data in MOQD where
--  organization_id <> planning_organization_id or
--  organization_id <> owning_organization_id
-- Then it queries the onhand and available-to-transact quantity
--  depends on the query mode.
-- The return values for the three query modes are
/*
Query Mode Value Meaning	    Consider       Quantity Returned              Value
                              Reservation?	  x_att      x_qoh
---------- ----- -----------  ------------   --------------------      -------------------
G_TXN_MODE	1	VMI/Consign 	   Y          VCATT	     QOH             VCATT= Min(QATT, VCOH)
                Misc Txn                               (from Qty tree)

G_XRF_MODE	2	VMI/Consign	       N           VCOH	     VCOH	        VMI/Consign onhand qty
                Transafer to reg                                         from the global temp table

G_REG_MODE	3	Regular  Transfer  N	        ROH	      ROH	         Quantity from MOQD where
                 to Consigned txn                                        organization_id = owning_organization_id
                                                                         = p_organization_id
*/

PROCEDURE GET_CONSIGNED_QUANTITY(
  x_return_status       OUT NOCOPY VARCHAR2,
  x_return_msg          OUT NOCOPY VARCHAR2,
  p_tree_mode           IN NUMBER,
  p_organization_id     IN NUMBER,
  p_owning_org_id       IN NUMBER,
  p_planning_org_id     IN NUMBER,
  p_inventory_item_id   IN NUMBER,
  p_is_revision_control IN VARCHAR2,
  p_is_lot_control      IN VARCHAR2,
  p_is_serial_control   IN VARCHAR2,
  p_revision            IN VARCHAR2,
  p_lot_number          IN VARCHAR2,
  p_lot_expiration_date IN  DATE,
  p_subinventory_code   IN  VARCHAR2,
  p_locator_id          IN NUMBER,
  p_source_type_id      IN NUMBER  DEFAULT -999,
  p_demand_source_line_id IN NUMBER  DEFAULT NULL,
  p_demand_source_header_id IN NUMBER  DEFAULT -999,
  p_demand_source_name  IN  VARCHAR2 DEFAULT NULL,
  p_onhand_source       IN NUMBER DEFAULT g_all_subs,
  p_cost_group_id       IN NUMBER,
  p_query_mode          IN NUMBER,
  x_qoh                 OUT NOCOPY NUMBER,
  x_att	                OUT NOCOPY NUMBER);

-- invConv changes begin : overloading version :
PROCEDURE GET_CONSIGNED_QUANTITY(
  x_return_status       OUT NOCOPY VARCHAR2,
  x_return_msg          OUT NOCOPY VARCHAR2,
  p_tree_mode           IN NUMBER,
  p_organization_id     IN NUMBER,
  p_owning_org_id       IN NUMBER,
  p_planning_org_id     IN NUMBER,
  p_inventory_item_id   IN NUMBER,
  p_is_revision_control IN VARCHAR2,
  p_is_lot_control      IN VARCHAR2,
  p_is_serial_control   IN VARCHAR2,
  p_revision            IN VARCHAR2,
  p_lot_number          IN VARCHAR2,
  p_lot_expiration_date IN  DATE,
  p_subinventory_code   IN  VARCHAR2,
  p_locator_id          IN NUMBER,
  p_grade_code          IN VARCHAR2,               -- invConv change
  p_source_type_id      IN NUMBER  DEFAULT -999,
  p_demand_source_line_id IN NUMBER  DEFAULT NULL,
  p_demand_source_header_id IN NUMBER  DEFAULT -999,
  p_demand_source_name  IN  VARCHAR2 DEFAULT NULL,
  p_onhand_source       IN NUMBER DEFAULT g_all_subs,
  p_cost_group_id       IN NUMBER,
  p_query_mode          IN NUMBER,
  x_qoh                 OUT NOCOPY NUMBER,
  x_att	                OUT NOCOPY NUMBER,
  x_sqoh                OUT NOCOPY NUMBER,           -- invConv change
  x_satt                OUT NOCOPY NUMBER);          -- invConv change
-- invConv changes end.


-- This API will allow update of the existing temp table.
---This API needs to be called after a transaction is commited or
-- when moving onto the next line for the same transaction without a
--commit.

PROCEDURE update_consigned_quantities
   ( x_return_status      OUT NOCOPY varchar2
   , x_msg_count          OUT NOCOPY varchar2
   , x_msg_data           OUT NOCOPY varchar2
   , p_organization_id    IN NUMBER
   , p_inventory_item_id  IN NUMBER
   , p_revision           IN VARCHAR2
   , p_lot_number         IN VARCHAR
   , p_subinventory_code  IN VARCHAR2
   , p_locator_id         IN NUMBER
   , p_grade_code         IN VARCHAR2 DEFAULT NULL    -- invConv change
   , p_primary_quantity   IN NUMBER
   , p_secondary_quantity IN NUMBER   DEFAULT NULL    -- invConv change
   , p_cost_group_id      IN NUMBER
   , p_containerized      IN NUMBER DEFAULT 2
   , p_planning_organization_id IN NUMBER
   , p_owning_organization_id IN number
   );


-- This api wil be called to decide whether to consume the consigned or VMI
--item according to the set up in the consumption form
-- X_CONSUME_CONSIGNED:  1 => Consume ,   0 => Do not consume
-- X_CONSUME_VMI:        1 => Consume ,   0 => Do not consume
PROCEDURE CHECK_CONSUME
  (
   P_TRANSACTION_TYPE_ID        IN     NUMBER,
   P_ORGANIZATION_ID            IN     NUMBER    DEFAULT NULL,
   P_SUBINVENTORY_CODE          IN     VARCHAR2  DEFAULT NULL,
   P_XFER_SUBINVENTORY_CODE     IN     VARCHAR2  DEFAULT NULL,
   p_from_locator_id            IN     NUMBER    DEFAULT NULL,
   p_TO_locator_id              IN     NUMBER    DEFAULT NULL,
   P_INVENTORY_ITEM_ID          IN     NUMBER    DEFAULT NULL,
   P_OWNING_ORGANIZATION_ID     IN     NUMBER    DEFAULT NULL,
   P_PLANNING_ORGANIZATION_ID   IN     NUMBER    DEFAULT NULL,
   X_RETURN_STATUS              OUT    NOCOPY VARCHAR2,
   X_MSG_COUNT                  OUT    NOCOPY NUMBER,
   X_MSG_DATA                   OUT    NOCOPY VARCHAR2,
   X_CONSUME_CONSIGNED          OUT    NOCOPY NUMBER,
   X_CONSUME_VMI                OUT    NOCOPY NUMBER
   );

-- This API checks whether there is existing pending transactions
--  for consign transfer txns.
FUNCTION check_pending_transactions(
 P_ORGANIZATION_ID         IN     NUMBER,
 P_SUBINVENTORY_CODE       IN     VARCHAR2,
 p_locator_id              IN     VARCHAR2 DEFAULT NULL,
 p_item_id		   IN     NUMBER,
 p_lpn_id		   IN     NUMBER DEFAULT NULL
) RETURN VARCHAR2;


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
FUNCTION GET_PLANNING_QUANTITY(
  P_INCLUDE_NONNET  NUMBER
, P_LEVEL           NUMBER
, P_ORG_ID          NUMBER
, P_SUBINV          VARCHAR2
, P_ITEM_ID         NUMBER
) RETURN NUMBER;

-- invConv changes begin : new procedure because GET_PLANNING_QUANTITY based on original function GET_PLANNING_QUANTITY.
PROCEDURE GET_PLANNING_QUANTITY(
     P_INCLUDE_NONNET  IN NUMBER
   , P_LEVEL           IN NUMBER
   , P_ORG_ID          IN NUMBER
   , P_SUBINV          IN VARCHAR2
   , P_ITEM_ID         IN NUMBER
   , P_GRADE_CODE      IN VARCHAR2                       -- invConv change
   , X_QOH             OUT NOCOPY NUMBER                         -- invConv change
   , X_SQOH            OUT NOCOPY NUMBER);                       -- invConv change
-- invConv changes end.


-- Bug 4247148: Added a new function to get the onhand qty
-- This API returns the onhand quantity for planning purpose
-- , which does not include VMI quantity based on atp/nettable/all subs
-- The quantity is calculated with onhand quantity from
-- MTL_ONHAND_QUANTITIES_DETAIL and pending transactions from
-- MTL_MATERIAL_TRANSACTIONS_TEMP
-- The quantities does not include suggestions
-- Input Parameters
--  P_INCLUDE_NONNET: Whether include non-nettable subinventories
--      Values: g_atpable_only => Include only atpable subinventories
--              g_netable_only => Only include nettabel subinventores
--              g_allsubs      => Include all subinventores
--  P_ORG_ID: Organization ID
--  P_ITEM_ID: Item ID

-- Note that this may includes pending transactions that
-- will keep the VMI attributes of inventory stock
FUNCTION get_planning_sd_quantity
  (
     P_ONHAND_SOURCE   NUMBER
     , P_ORG_ID          NUMBER
     , P_ITEM_ID         NUMBER
     ) RETURN NUMBER;

     --Bug#6157532. Overloaded the procedure for the case
--where LPN is involved .
PROCEDURE GET_CONSIGNED_LPN_QUANTITY(
	x_return_status       OUT NOCOPY VARCHAR2,
	x_return_msg          OUT NOCOPY VARCHAR2,
	p_tree_mode           IN NUMBER,
	p_organization_id     IN NUMBER,
	p_owning_org_id       IN NUMBER,
	p_planning_org_id     IN NUMBER,
	p_inventory_item_id   IN NUMBER,
	p_is_revision_control IN VARCHAR2,
	p_is_lot_control      IN VARCHAR2,
	p_is_serial_control   IN VARCHAR2,
	p_revision            IN VARCHAR2,
	p_lot_number          IN VARCHAR2,
	p_lot_expiration_date IN  DATE,
	p_subinventory_code   IN  VARCHAR2,
	p_locator_id          IN NUMBER,
	p_source_type_id      IN NUMBER,
	p_demand_source_line_id IN NUMBER,
	p_demand_source_header_id IN NUMBER,
	p_demand_source_name  IN  VARCHAR2,
	p_onhand_source       IN NUMBER,
	p_cost_group_id       IN NUMBER,
	p_query_mode          IN NUMBER,
	p_lpn_id              IN NUMBER,
	x_qoh                 OUT NOCOPY NUMBER,
	x_att                 OUT NOCOPY NUMBER) ;

PROCEDURE clear_vmi_cache ; --Bug#6157532.Added this procedure in SPEC.


END INV_CONSIGNED_VALIDATIONS;

/
