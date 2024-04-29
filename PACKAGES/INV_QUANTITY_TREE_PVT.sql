--------------------------------------------------------
--  DDL for Package INV_QUANTITY_TREE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_QUANTITY_TREE_PVT" AUTHID CURRENT_USER as
/* $Header: INVVQTTS.pls 120.1.12010000.4 2010/02/16 11:00:52 hjogleka ship $*/

-- synonyms used in this program
--     qoh          quantity on hand
--     rqoh         reservable quantity on hand
--     qr           quantity reserved
--     qs           quantity suggested
--     att          available to transact
--     atr          available to reserve
--    sqoh          secondary quantity on hand
--    srqoh         secondary reservable quantity on hand
--    sqr           secondary quantity reserved
--    sqs           secondare quantity suggested
--    satt          secondary available to transact
--    satr          secondary available to reserve

/******************************************************************
 *
 * Using the Quantity Tree
 *
 * Here's some general instructions and guidelines on using the
 * quantity tree. This section also mentions the C code equivalents
 * of the pl/sql procedures.
 * 1. Create_Tree
 *    call create_tree to build the tree for a given organization and
 *    item.  The tree can be built in two modes: reservation mode
 *    and transaction mode.  Reservation mode is used to determine
 *    the available to reserve (atr) quantity (for reservations).
 *    Transaction mode is used to determine the availabe to transact
 *    (att) quantity, used in transactions.  The onhand_source passed
 *    to the create tree function help define which subs and locators
 *    will be used to determine onhand quantity.  If Onhand_source is 1,
 *    then only the quantity in ATPable subs will be used to
 *    determine quantity.  If onhand_source is 2, then only
 *    the quantity in nettable subs is considered.  If onhand_source is 3,
 *    the subs are not limited based on the nettable and ATPable flags.
 *    Pick_release should be 0 except if called from the inventory or
 *    wms detailing engines.
 *    The create_tree procedure returns tree_id, which must be used
 *    to query or update the tree.
 *    The equivalent function in the C code is CreateTree.
 *
 * 2. Query_Tree
 *    This procedure is used to find the values for quantity onhand,
 *    reservable quantity on hand, quantity reserved, quantity suggested,
 *    availabe to transact, and available to reserve. This procedure
 *    takes the place of 2 C functions: QtyQuery and SubXQuery.  If
 *    tree is being queried in transaction mode, and
 *    the transaction is a subinventory
 *    transfer, then pass the subinventory code of the destination
 *    sub in the p_transfer_subinventory_code parameter.  In all other
 *    cases, set the p_transfer_subinventory_code parameter to NULL.
 *    ATT and ATR are calculated differently depending on whether
 *    the transaction is a subinventory transfer or some other
 *    transaction.
 *
 * 3. Update_Quantities
 *    The update procedure changes the quantity in the quantity tree
 *    for a given item/org/revision/lot/sub/locator.  The quantity
 *    updated depends on the quantity type parameter. If the quantity
 *    type is g_qoh, then the p_primary_quantity value is added
 *    to the quantity onhand.  If the quantity type is g_qs_txn,
 *    then the quantity suggested value is updated. Reservations
 *    work the same way. Update_quantities does not update the
 *    database - it only updates the local version of the qty tree.
 *    The database must be updated separately.
 *          There are a couple of important things to keep in mind.
 *    First, the quantity passed in to update_quantities is important.
 *    The quantity is always added to the appropriate node qty.  So,
 *    for a receipt txn, the quantity passed in should be
 *    positive.  For an issue txn,  the quantity passed in
 *    should have a negative sign (to decrement
 *    on hand quantity).  For reserving items or suggesting
 *    an issue, the value passed in should be positive (incrementing
 *    quantity reserved or quantity suggested). Do not update the
 *    tree with suggested receipts; including suggested receipts
 *    could lead to missing inventory if the suggestion is not
 *    transacted.
 *          Second, this function is the same as the C function
 *    QtyAvail.  There is no pl/sql equivalent of the C function
 *    SubXFer.  For a subinventory transfer transaction which
 *    updates both the destination location and the source location,
 *    update_quantities must be called twice.  First, add the quantity to
 *    the destination sub/locator.  Then decrement the quantity from the
 *    source sub/locator.  Order is important - this ordering assures
 *    that higher level att/atr are not made negative. The updates
 *    to both the destination and source should only happen for actual
 *    transactions, not suggested transfers.
 *
 * 4. Do_check
 *    This procedure should be called before committing quantity
 *    updates to the database. There can be multiple quantity trees
 *    for each item and organization.  Updates in a quantity tree
 *    are not reflected in other quantity trees of the same org/item.
 *    Thus, it would be possible for two different sessions to try
 *    to reserve or transact the same quantity, which would led
 *    to negative quantity, a big no-no. To solve this problem, call
 *    do_check before commiting.  This procedure will rebuild the
 *    quantity tree with the current info in the database.  If your
 *    updates would drive the quantity negative (and if negative
 *    quantities are not allowed), then x_no_violation will be false.
 *    You should then rollback your updates.
 *
 ***********************************************************************/
-- Constant Definition
--
-- Source Type ID Constants
--
-- The following constants are valid demand source type ids and
-- supply source type ids.
-- They are the same as TRANSACTION_SOURCE_TYPE_ID
-- in table MTL_TXN_SOURCE_TYPES.
g_source_type_po            CONSTANT NUMBER := 1 ;
g_source_type_oe            CONSTANT NUMBER := 2 ;
g_source_type_account       CONSTANT NUMBER := 3 ;
g_source_type_trans_order   CONSTANT NUMBER := 4 ;
g_source_type_wip           CONSTANT NUMBER := 5 ;
g_source_type_account_alias CONSTANT NUMBER := 6 ;
g_source_type_internal_req  CONSTANT NUMBER := 7 ;
g_source_type_internal_ord  CONSTANT NUMBER := 8 ;
g_source_type_cycle_count   CONSTANT NUMBER := 9 ;
g_source_type_physical_inv  CONSTANT NUMBER := 10;
g_source_type_standard_cost CONSTANT NUMBER := 11;
g_source_type_rma           CONSTANT NUMBER := 12;
g_source_type_inv           CONSTANT NUMBER := 13;
--
-- Tree mode constants
--   Users can call create_tree() in three modes, reservation mode,
--   transaction mode, and loose items only mode.  In loose items only
--   mode, only quantity not in containers is considered
g_reservation_mode          CONSTANT INTEGER := 1;
g_transaction_mode          CONSTANT INTEGER := 2;
g_loose_only_mode           CONSTANT INTEGER := 3;
g_no_lpn_rsvs_mode          CONSTANT INTEGER := 4;
--
-- Quantity type constants
--   User can call update_quantities to change quantities at a given level.
--   Quantity type constans should be used to specify which quantity the user
--   intents to change: quantity onhand, or quantity reserved
g_qoh                       CONSTANT INTEGER := 1; -- quantity on hand
g_qr_same_demand            CONSTANT INTEGER := 2; -- quantity reserved for the same demand source
g_qr_other_demand           CONSTANT INTEGER := 3; -- quantity reserved for other demand source
g_qs_rsv                    CONSTANT INTEGER := 4; -- quantity for suggested reservation
g_qs_txn                    CONSTANT INTEGER := 5; -- quantity for suggested transaction

-- Onhand Source
--  Defined in mtl_onhand_source lookup
--  Used to determine which subs are included in calculation of
--  onhand qty
g_atpable_only              CONSTANT NUMBER := 1;
g_nettable_only             CONSTANT NUMBER := 2;
g_all_subs                  CONSTANT NUMBER := 3;
g_atpable_nettable_only     CONSTANT NUMBER := 4;

-- Containerized
--  Used to indicate packed quantities for use in quantity calculations
--  If 0, then record is not packed in container.
--  If 1, then record is packed in containter.
g_containerized_true        CONSTANT NUMBER := 1;
g_containerized_false       CONSTANT NUMBER := 0;

-- Exclusive
--  Used to indicate if tree should be build in exclusive mode
--  If 0, then tree is not locked when it is built.
--  If 1, then tree is locked when built.
g_exclusive                 CONSTANT NUMBER := 1;
g_non_exclusive             CONSTANT NUMBER := 0;

-- Pick Release
--  Used to indicate if the tree is being called from the pick release
--  process.  When the tree is built during pick release, we should
--  consider all reservations that have a staged flag, even if the
--  reservation is for the same transaction.  This way, quantity in
--  staging lanes never appears to be available, and the pick
--  release process will not allocate from staging locations.  All
--  other times, the tree should not consider reservations which are
--  for this current transactions.
--  If 0, then tree is built normally (ignoring reservations for current
--     transaction)
--  If 1, then tree is built in pick release (considering staged
--     reservations for the current transaction)
g_pick_release_yes          CONSTANT NUMBER := 1;
g_pick_release_no           CONSTANT NUMBER := 0;

-- invConv: need to set this variable... in order to stop populating the TOP nodes when the first QT is complete after a CT :
g_is_populating_top_node BOOLEAN := TRUE;
/* set the value of global var g_is_mat_status_used from the profile INV_MATERIAL_STATUS
   in create_tree procedure body. no value should be defaulted here.
   This variable detemines whether reservations allowed flag derived from
   material status definition is used for lots and locators while computing atr
   INV_MATERIAL_STATUS == 1 == YES
   INV_MATERIAL_STATUS == 2 == NO   */
g_is_mat_status_used  NUMBER;

-- Function
--   demand_source_equals
-- Description
--   Compare whether two demand sources are the same.
-- Return Value
--   'Y' if the two demand sources are the same; 'N' otherwise
Function demand_source_equals
  (  p_demand_source_type_id1   NUMBER
    ,p_demand_source_header_id1 NUMBER
    ,p_demand_source_line_id1   NUMBER
    ,p_demand_source_delivery1  NUMBER
    ,p_demand_source_name1      VARCHAR2
    ,p_demand_source_type_id2   NUMBER
    ,p_demand_source_header_id2 NUMBER
    ,p_demand_source_line_id2   NUMBER
    ,p_demand_source_delivery2  NUMBER
    ,p_demand_source_name2      VARCHAR2
     ) RETURN VARCHAR2;
PRAGMA restrict_references(demand_source_equals, wnds, wnps, rnds);
--
-- Procedure
--   clear_quantity_cache
-- Description
--   Delete all quantity trees in the memory. Should be called when you call
--   rollback. Otherwise the trees in memory may not be in sync with the data
--   in the corresponding database tables
PROCEDURE clear_quantity_cache;

--
-- Procedure
--   create_tree
-- Description
--   Create a quantity tree
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--   p_organization_id         organzation id
--   p_inventory_item_id       inventory_item_id
--   p_tree_mode               tree mode, either g_reservation_mode
--                             or g_transaction_mode
--   p_is_revision_control
--   p_is_lot_control
--   p_is_serial_control
--   p_asset_sub_only
--   p_include_suggestion      should be true only for pick/put engine
--   p_demand_source_type_id   demand_source_type_id
--   p_demand_source_header_id demand_source_header_id
--   p_demand_source_line_id   demand_source_line_id
--   p_demand_source_name      demand_source_name
--   p_demand_source_delivery  demand_source_delivery
--   p_onhand_source           describes subinventories in which to search
--                                for onhand - nettable, ATPable, all
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--   x_tree_id                 used later to refer to the same tree
--
PROCEDURE create_tree
  (   p_api_version_number       IN  NUMBER
   ,  p_init_msg_lst             IN  VARCHAR2 DEFAULT fnd_api.g_false
   ,  x_return_status            OUT NOCOPY VARCHAR2
   ,  x_msg_count                OUT NOCOPY NUMBER
   ,  x_msg_data                 OUT NOCOPY VARCHAR2
   ,  p_organization_id          IN  NUMBER
   ,  p_inventory_item_id        IN  NUMBER
   ,  p_tree_mode                IN  INTEGER
   ,  p_is_revision_control      IN  BOOLEAN
   ,  p_is_lot_control           IN  BOOLEAN
   ,  p_is_serial_control        IN  BOOLEAN
   ,  p_asset_sub_only           IN  BOOLEAN  DEFAULT FALSE
   ,  p_include_suggestion       IN  BOOLEAN  DEFAULT FALSE
   ,  p_demand_source_type_id    IN  NUMBER   DEFAULT -9999
   ,  p_demand_source_header_id  IN  NUMBER   DEFAULT -9999
   ,  p_demand_source_line_id    IN  NUMBER   DEFAULT -9999
   ,  p_demand_source_name       IN  VARCHAR2 DEFAULT NULL
   ,  p_demand_source_delivery   IN  NUMBER   DEFAULT NULL
   ,  p_lot_expiration_date      IN  DATE     DEFAULT NULL
   ,  x_tree_id                  OUT NOCOPY INTEGER
   ,  p_onhand_source            IN  NUMBER   DEFAULT 3  --g_all_subs
   ,  p_exclusive                IN  NUMBER   DEFAULT 0  --g_non_exclusive
   ,  p_pick_release             IN  NUMBER   DEFAULT 0  --g_pick_release_no
   );

PROCEDURE create_tree
  (   p_api_version_number       IN  NUMBER
   ,  p_init_msg_lst             IN  VARCHAR2 DEFAULT fnd_api.g_false
   ,  x_return_status            OUT NOCOPY VARCHAR2
   ,  x_msg_count                OUT NOCOPY NUMBER
   ,  x_msg_data                 OUT NOCOPY VARCHAR2
   ,  p_organization_id          IN  NUMBER
   ,  p_inventory_item_id        IN  NUMBER
   ,  p_tree_mode                IN  INTEGER
   ,  p_is_revision_control      IN  BOOLEAN
   ,  p_is_lot_control           IN  BOOLEAN
   ,  p_is_serial_control        IN  BOOLEAN
   ,  p_grade_code               IN  VARCHAR2
   ,  p_asset_sub_only           IN  BOOLEAN  DEFAULT FALSE
   ,  p_include_suggestion       IN  BOOLEAN  DEFAULT FALSE
   ,  p_demand_source_type_id    IN  NUMBER   DEFAULT -9999
   ,  p_demand_source_header_id  IN  NUMBER   DEFAULT -9999
   ,  p_demand_source_line_id    IN  NUMBER   DEFAULT -9999
   ,  p_demand_source_name       IN  VARCHAR2 DEFAULT NULL
   ,  p_demand_source_delivery   IN  NUMBER   DEFAULT NULL
   ,  p_lot_expiration_date      IN  DATE     DEFAULT NULL
   ,  x_tree_id                  OUT NOCOPY INTEGER
   ,  p_onhand_source            IN  NUMBER   DEFAULT 3  --g_all_subs
   ,  p_exclusive                IN  NUMBER   DEFAULT 0  --g_non_exclusive
   ,  p_pick_release             IN  NUMBER   DEFAULT 0  --g_pick_release_no
   );


-- Procedure
--   query tree
--
--  Version
--   Current version       1.0
--   Initial version       1.0
--
-- Input parameters:
--   p_api_version_number   standard input parameter
--   p_init_msg_lst         standard input parameter
--   p_tree_id              tree_id
--   p_revision             revision
--   p_lot_number           lot_number
--   p_subinventory_code    subinventory code
--   p_locator_id           locator_id
--   p_to_subinventory_code destination subinventory for subinventory transfer
--			    transactions.  Should be NULL otherwise.
--
-- Output parameters:
--   x_return_status       standard output parameter
--   x_msg_count           standard output parameter
--   x_msg_data            standard output parameter
--   x_qoh                 qoh
--   x_rqoh                rqoh
--   x_qr                  qr
--   x_qs                  qs
--   x_att                 att
--   x_atr                 atr
--
PROCEDURE query_tree
  (   p_api_version_number   IN  NUMBER
   ,  p_init_msg_lst         IN  VARCHAR2 DEFAULT fnd_api.g_false
   ,  x_return_status        OUT NOCOPY VARCHAR2
   ,  x_msg_count            OUT NOCOPY NUMBER
   ,  x_msg_data             OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_locator_id           IN  NUMBER
   ,  x_qoh                  OUT NOCOPY NUMBER
   ,  x_rqoh                 OUT NOCOPY NUMBER
   ,  x_qr                   OUT NOCOPY NUMBER
   ,  x_qs                   OUT NOCOPY NUMBER
   ,  x_att                  OUT NOCOPY NUMBER
   ,  x_atr                  OUT NOCOPY NUMBER
   ,  p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   ,  p_cost_group_id        IN  NUMBER DEFAULT NULL
   ,  p_lpn_id               IN  NUMBER DEFAULT NULL
   ,  p_transfer_locator_id  IN  NUMBER DEFAULT NULL
   );

PROCEDURE query_tree
  (   p_api_version_number   IN  NUMBER
   ,  p_init_msg_lst         IN  VARCHAR2 DEFAULT fnd_api.g_false
   ,  x_return_status        OUT NOCOPY VARCHAR2
   ,  x_msg_count            OUT NOCOPY NUMBER
   ,  x_msg_data             OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_locator_id           IN  NUMBER
   ,  x_qoh                  OUT NOCOPY NUMBER
   ,  x_rqoh                 OUT NOCOPY NUMBER
   ,  x_qr                   OUT NOCOPY NUMBER
   ,  x_qs                   OUT NOCOPY NUMBER
   ,  x_att                  OUT NOCOPY NUMBER
   ,  x_atr                  OUT NOCOPY NUMBER
   ,  x_sqoh                 OUT NOCOPY NUMBER
   ,  x_srqoh                OUT NOCOPY NUMBER
   ,  x_sqr                  OUT NOCOPY NUMBER
   ,  x_sqs                  OUT NOCOPY NUMBER
   ,  x_satt                 OUT NOCOPY NUMBER
   ,  x_satr                 OUT NOCOPY NUMBER
   ,  p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   ,  p_cost_group_id        IN  NUMBER DEFAULT NULL
   ,  p_lpn_id               IN  NUMBER DEFAULT NULL
   ,  p_transfer_locator_id  IN  NUMBER DEFAULT NULL
   );

--Query_Tree
--  Use this query_tree to return the packed quantity on hand.
--  The Packed Quantity On Hand is the total on hand sitting in
--  LPNs.
--  PQOH is populated only if the tree is created in loose_only_mode.
--  If tree is not created in loose_only_mode, this API will return
--  PQOH of 0.

PROCEDURE query_tree
  (   p_api_version_number   IN  NUMBER
   ,  p_init_msg_lst         IN  VARCHAR2 DEFAULT fnd_api.g_false
   ,  x_return_status        OUT NOCOPY VARCHAR2
   ,  x_msg_count            OUT NOCOPY NUMBER
   ,  x_msg_data             OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_locator_id           IN  NUMBER
   ,  x_qoh                  OUT NOCOPY NUMBER
   ,  x_rqoh                 OUT NOCOPY NUMBER
   ,  x_pqoh                 OUT NOCOPY NUMBER
   ,  x_qr                   OUT NOCOPY NUMBER
   ,  x_qs                   OUT NOCOPY NUMBER
   ,  x_att                  OUT NOCOPY NUMBER
   ,  x_atr                  OUT NOCOPY NUMBER
   ,  p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   ,  p_cost_group_id        IN  NUMBER DEFAULT NULL
   ,  p_lpn_id               IN  NUMBER DEFAULT NULL
   ,  p_transfer_locator_id  IN  NUMBER DEFAULT NULL
   );

PROCEDURE query_tree
  (   p_api_version_number   IN  NUMBER
   ,  p_init_msg_lst         IN  VARCHAR2 DEFAULT fnd_api.g_false
   ,  x_return_status        OUT NOCOPY VARCHAR2
   ,  x_msg_count            OUT NOCOPY NUMBER
   ,  x_msg_data             OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_locator_id           IN  NUMBER
   ,  x_qoh                  OUT NOCOPY NUMBER
   ,  x_rqoh                 OUT NOCOPY NUMBER
   ,  x_pqoh                 OUT NOCOPY NUMBER
   ,  x_qr                   OUT NOCOPY NUMBER
   ,  x_qs                   OUT NOCOPY NUMBER
   ,  x_att                  OUT NOCOPY NUMBER
   ,  x_atr                  OUT NOCOPY NUMBER
   ,  x_sqoh                 OUT NOCOPY NUMBER
   ,  x_srqoh                OUT NOCOPY NUMBER
   ,  x_spqoh                OUT NOCOPY NUMBER
   ,  x_sqr                  OUT NOCOPY NUMBER
   ,  x_sqs                  OUT NOCOPY NUMBER
   ,  x_satt                 OUT NOCOPY NUMBER
   ,  x_satr                 OUT NOCOPY NUMBER
   ,  p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   ,  p_cost_group_id        IN  NUMBER DEFAULT NULL
   ,  p_lpn_id               IN  NUMBER DEFAULT NULL
   ,  p_transfer_locator_id  IN  NUMBER DEFAULT NULL
   );

--
-- Procedure
--   update_quantities
-- Description
--   update a quantity tree
--
--  Version
--   Current version        1.0
--   Initial version        1.0
--
-- Input parameters:
--   p_api_version_number   standard input parameter
--   p_init_msg_lst         standard input parameter
--   p_tree_id              tree_id
--   p_revision             revision
--   p_lot_number           lot_number
--   p_subinventory_code    subinventory_code
--   p_locator_id           locator_id
--   p_primary_quantity     primary_quantity
--   p_quantity_type
--   p_containerized	    set to g_containerized_true if
--			     quantity is in container
-- Output parameters:
--   x_return_status       standard output parameter
--   x_msg_count           standard output parameter
--   x_msg_data            standard output parameter
--   x_tree_id             used later to refer to the same tree
--   x_qoh                 qoh   after the update
--   x_rqoh                rqoh  after the update
--   x_qr                  qr    after the update
--   x_qs                  qs    after the update
--   x_att                 att   after the update
--   x_atr                 atr   after the update
PROCEDURE update_quantities
  (  p_api_version_number    IN  NUMBER
   , p_init_msg_lst          IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
   , p_tree_id               IN  INTEGER
   , p_revision              IN  VARCHAR2 DEFAULT NULL
   , p_lot_number            IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code     IN  VARCHAR2 DEFAULT NULL
   , p_locator_id            IN  NUMBER   DEFAULT NULL
   , p_primary_quantity      IN  NUMBER
   , p_quantity_type         IN  INTEGER
   , x_qoh                   OUT NOCOPY NUMBER
   , x_rqoh                  OUT NOCOPY NUMBER
   , x_qr                    OUT NOCOPY NUMBER
   , x_qs                    OUT NOCOPY NUMBER
   , x_att                   OUT NOCOPY NUMBER
   , x_atr                   OUT NOCOPY NUMBER
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_cost_group_id         IN  NUMBER DEFAULT NULL
   , p_containerized         IN  NUMBER DEFAULT g_containerized_false
   , p_lpn_id                IN  NUMBER DEFAULT NULL
   , p_transfer_locator_id   IN  NUMBER DEFAULT NULL
   ) ;

PROCEDURE update_quantities
  (  p_api_version_number    IN  NUMBER
   , p_init_msg_lst          IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
   , p_tree_id               IN  INTEGER
   , p_revision              IN  VARCHAR2 DEFAULT NULL
   , p_lot_number            IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code     IN  VARCHAR2 DEFAULT NULL
   , p_locator_id            IN  NUMBER   DEFAULT NULL
   , p_primary_quantity      IN  NUMBER
   , p_secondary_quantity    IN  NUMBER
   , p_quantity_type         IN  INTEGER
   , x_qoh                   OUT NOCOPY NUMBER
   , x_rqoh                  OUT NOCOPY NUMBER
   , x_qr                    OUT NOCOPY NUMBER
   , x_qs                    OUT NOCOPY NUMBER
   , x_att                   OUT NOCOPY NUMBER
   , x_atr                   OUT NOCOPY NUMBER
   , x_sqoh                  OUT NOCOPY NUMBER
   , x_srqoh                 OUT NOCOPY NUMBER
   , x_sqr                   OUT NOCOPY NUMBER
   , x_sqs                   OUT NOCOPY NUMBER
   , x_satt                  OUT NOCOPY NUMBER
   , x_satr                  OUT NOCOPY NUMBER
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_cost_group_id         IN  NUMBER DEFAULT NULL
   , p_containerized         IN  NUMBER DEFAULT g_containerized_false
   , p_lpn_id                IN  NUMBER DEFAULT NULL
   , p_transfer_locator_id   IN  NUMBER DEFAULT NULL
   ) ;

--
-- Procedure
--   do_check
-- Description
--   Check quantity violation
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--   p_tree_id                 tree id
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--   x_no_violation            true if no violation, false otherwise
--
PROCEDURE do_check
  (  p_api_version_number  IN  NUMBER
   , p_init_msg_lst        IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   , p_tree_id             IN  INTEGER
   , x_no_violation        OUT NOCOPY BOOLEAN
   );

--
-- Procedure
--   do_check
-- Description
--   Check quantity violation
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--   x_no_violation            true if no violation, false otherwise
--
PROCEDURE do_check
  (  p_api_version_number  IN  NUMBER
   , p_init_msg_lst        IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   , x_no_violation        OUT NOCOPY BOOLEAN
   );

--
-- Procedure
--   free_tree
-- Description
--   free the tree when it is no longer needed
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--   p_tree_id                 tree id
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--
PROCEDURE free_tree
  (  p_api_version_number  IN  NUMBER
   , p_init_msg_lst        IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   , p_tree_id             IN  INTEGER
   );

--
-- Procedure
--   free_all
-- Description
--   free all the trees
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--
PROCEDURE free_all
  (  p_api_version_number  IN  NUMBER
   , p_init_msg_lst        IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   );

--
-- Procedure
--   mark_all_for_refresh
-- Description
--   marks all existing trees as needing to be rebuilt. Unlike
--   free_tree and clear_quantity_cache, no quantity trees are deleted.
--
--   This API is needed so that the do_check_for_commit procedure in
--   INVRSV3B.pls will still work.  That procedure stores tree_ids in a
--   temp table. When clear_quantity_cache is called, these tree_ids are
--   no longer valid. When this is called instead of clear_quantity_cache,
--   the tree_ids are still valid to be passed to do_check.
--
--
--  Version
--   Current version           1.0
--   Initial version           1.0
--
-- Input parameters:
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--
PROCEDURE mark_all_for_refresh
  (  p_api_version_number  IN  NUMBER
   , p_init_msg_lst        IN  VARCHAR2
   , x_return_status       OUT NOCOPY VARCHAR2
   , x_msg_count           OUT NOCOPY NUMBER
   , x_msg_data            OUT NOCOPY VARCHAR2
   );


--
-- Procedure
--    find_rootinfo
-- Description
--    find a rootinfo record based on input parameters
-- Version
--  Current Version 	1.0
--  Initial Version 	1.0
--
-- Input Parameters
--   p_api_version_number      standard input parameter
--   p_init_msg_lst            standard input parameter
--
-- Output parameters:
--   x_return_status           standard output parameter
--   x_msg_count               standard output parameter
--   x_msg_data                standard output parameter
--
--  Return
--    0                          if rootinfo not found
--    >0                         index for the rootinfo in the rootinfo array
--
FUNCTION find_rootinfo
  (   x_return_status            OUT NOCOPY VARCHAR2
   ,  p_organization_id          IN  NUMBER
   ,  p_inventory_item_id        IN  NUMBER
   ,  p_tree_mode                IN  INTEGER
   ,  p_is_revision_control      IN  BOOLEAN
   ,  p_is_lot_control           IN  BOOLEAN
   ,  p_is_serial_control        IN  BOOLEAN
   ,  p_asset_sub_only           IN  BOOLEAN
   ,  p_include_suggestion       IN  BOOLEAN
   ,  p_demand_source_type_id    IN  NUMBER
   ,  p_demand_source_header_id  IN  NUMBER
   ,  p_demand_source_line_id    IN  NUMBER
   ,  p_demand_source_name       IN  VARCHAR2
   ,  p_demand_source_delivery   IN  NUMBER
   ,  p_lot_expiration_date      IN  DATE
   ,  p_onhand_source            IN  NUMBER
   ,  p_pick_release             IN  NUMBER DEFAULT 0 --g_pick_release_no
   ) RETURN INTEGER;

-- Procedure
--   backup_tree
-- Description
--   backup the current state of a tree
-- Note
--   This is only a one level backup. Calling it twice will
--   overwrite the previous backup
PROCEDURE backup_tree
  (
     x_return_status OUT NOCOPY VARCHAR2
   , p_tree_id       IN  INTEGER
   );

-- Procedure
--   restore_tree
-- Description
--   restore the current state of a tree to the state
--   at the last time when savepoint_tree is called
-- Note
--   This is only a one level restore. Calling it more than once
--   has the same effect as calling it once.
PROCEDURE restore_tree
  (
     x_return_status OUT NOCOPY VARCHAR2
   , p_tree_id       IN  INTEGER
   );

-- **NEW BACKUP/RESTORE PROCEDURES**
-- Bug 2788807
--    We now need to support multi-level backup and restore capability
-- for the quantity tree.  We'll overload the existing procedures.

-- Procedure
--   backup_tree
-- Description
--   backup the current state of a tree.  This procedure returns a backup_id
--   which needs to be passed to restore_tree in order to restore the correct
--   version of the quantity tree.  Unlike the older version of backup_tree,
--   this can be called multiple times without overwriting previous backups.
--   The backups dissappear when clear_quantity_cache is called.
--
PROCEDURE backup_tree
  (
     x_return_status OUT NOCOPY VARCHAR2
   , p_tree_id       IN  INTEGER
   , x_backup_id     OUT NOCOPY NUMBER
   );

-- Procedure
--   restore_tree
-- Description
--   Restores the quantity tree to the point indicated by the backup_id.
--   Tree_id is not strictly needed here, but is kept for overloading and
--   error checking purposes.  Restore_tree can be called multiple times for
--   the same backup_id - a saved quantity tree is not deleted until
--   clear_quantity_cahce is called.
PROCEDURE restore_tree
  (
     x_return_status OUT NOCOPY VARCHAR2
   , p_tree_id       IN  INTEGER
   , p_backup_id     IN  NUMBER
   );


-- Procedure
--   lock_tree
-- Description
--   this function places a user lock on an item/organization
--   combination.  Once this lock is placed, no other sessions
--   can lock the same item/org combo.  Users who call lock_tree
--   do not always have to call release_lock explicitly.  The lock is
--   released automatically at commit, rollback, or session loss.
PROCEDURE lock_tree(
     p_api_version_number   IN  NUMBER
   , p_init_msg_lst         IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status        OUT NOCOPY VARCHAR2
   , x_msg_count            OUT NOCOPY NUMBER
   , x_msg_data             OUT NOCOPY VARCHAR2
   , p_organization_id      IN  NUMBER
   , p_inventory_item_id    IN  NUMBER);



-- Procedure
--   release_lock
-- Description
--   this function releases the user lock on an item/organization
--   combination created by this session.  Users who call lock_tree
--   do not always have to call release_lock explicitly.  The lock is
--   released automatically at commit, rollback, or session loss.

PROCEDURE release_lock(
     p_api_version_number   IN  NUMBER
   , p_init_msg_lst         IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status        OUT NOCOPY VARCHAR2
   , x_msg_count            OUT NOCOPY NUMBER
   , x_msg_data             OUT NOCOPY VARCHAR2
   , p_organization_id      IN  NUMBER
   , p_inventory_item_id    IN  NUMBER);

-- Procedure
--   prepare_reservation_quantities
-- Description
--	This procedure is called from the reservation form to
-- initialize the table used for the LOVs in that form.
-- The tree passed to this procedure should have been created in
-- reservation_mode.
PROCEDURE prepare_reservation_quantities(
    x_return_status        OUT NOCOPY VARCHAR2
   , p_tree_id              IN  NUMBER
   );


-- Get_Total_QOH
--   This API returns the TQOH, or total quantity on hand.
--   This value reflects any negative balances for this
--   item in the organization.  The Total QOH is the minimum
--   of the current node's QOH and all ancestor nodes' QOH.
--   For example,
--   Consider 2 locators in the EACH subinventory:
--   E.1.1 has 10 onhand
--   E.1.2 has -20 onhand
--   Thus, the subinventory Each has -10 onhand.
--
--   Where calling query_tree, qoh for E.1.1 = 10.
--   However, when calling get_total_qoh, the TQOH
--   for E.1.1 = -10, reflecting the value at the subinventory level.
--
--   This procedure is used by the inventory transaction forms.

PROCEDURE get_total_qoh
   (  x_return_status        OUT NOCOPY VARCHAR2
   ,  x_msg_count            OUT NOCOPY NUMBER
   ,  x_msg_data             OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_locator_id           IN  NUMBER
   ,  p_cost_group_id	     IN  NUMBER DEFAULT NULL
   ,  x_tqoh                 OUT NOCOPY NUMBER
   ,  p_lpn_id	             IN  NUMBER DEFAULT NULL
   );

PROCEDURE get_total_qoh
   (  x_return_status        OUT NOCOPY VARCHAR2
   ,  x_msg_count            OUT NOCOPY NUMBER
   ,  x_msg_data             OUT NOCOPY VARCHAR2
   ,  p_tree_id              IN  INTEGER
   ,  p_revision             IN  VARCHAR2
   ,  p_lot_number           IN  VARCHAR2
   ,  p_subinventory_code    IN  VARCHAR2
   ,  p_locator_id           IN  NUMBER
   ,  p_cost_group_id	     IN  NUMBER DEFAULT NULL
   ,  x_tqoh                 OUT NOCOPY NUMBER
   ,  x_stqoh                OUT NOCOPY NUMBER
   ,  p_lpn_id               IN  NUMBER DEFAULT NULL
   );

-- Procedure
--   print_tree
-- Description
--   print the information in a tree to dbms_output
PROCEDURE print_tree
  (
   p_tree_id IN INTEGER
   );


--
-- Bug 2486318. The do check does not work. Trasactions get committed
-- even if there is a node violation. Added p_check_mark_node_only to mark
-- the nodes. A new procedure was added to bve called from inldqc.ppc
-- Procedure
--   update_quantities_for_form
-- Description
--   update a quantity tree
--
--  Version
--   Current version        1.0
--   Initial version        1.0
--
-- Input parameters:
--   p_api_version_number   standard input parameter
--   p_init_msg_lst         standard input parameter
--   p_tree_id              tree_id
--   p_revision             revision
--   p_lot_number           lot_number
--   p_subinventory_code    subinventory_code
--   p_locator_id           locator_id
--   p_primary_quantity     primary_quantity
--   p_quantity_type
--   p_containerized        set to g_containerized_true if
--                           quantity is in container
--   p_call_for_form       chek if procedure called from form
-- Output parameters:
--   x_return_status       standard output parameter
--   x_msg_count           standard output parameter
--   x_msg_data            standard output parameter
--   x_tree_id             used later to refer to the same tree
--   x_qoh                 qoh   after the update
--   x_rqoh                rqoh  after the update
--   x_qr                  qr    after the update
--   x_qs                  qs    after the update
--   x_att                 att   after the update
--   x_atr                 atr   after the update
PROCEDURE update_quantities_for_form
  (  p_api_version_number    IN  NUMBER
   , p_init_msg_lst          IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
   , p_tree_id               IN  INTEGER
   , p_revision              IN  VARCHAR2 DEFAULT NULL
   , p_lot_number            IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code     IN  VARCHAR2 DEFAULT NULL
   , p_locator_id            IN  NUMBER   DEFAULT NULL
   , p_primary_quantity      IN  NUMBER
   , p_quantity_type         IN  INTEGER
   , x_qoh                   OUT NOCOPY NUMBER
   , x_rqoh                  OUT NOCOPY NUMBER
   , x_qr                    OUT NOCOPY NUMBER
   , x_qs                    OUT NOCOPY NUMBER
   , x_att                   OUT NOCOPY NUMBER
   , x_atr                   OUT NOCOPY NUMBER
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_cost_group_id         IN  NUMBER DEFAULT NULL
   , p_containerized         IN  NUMBER DEFAULT g_containerized_false
   , p_call_for_form        IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_lpn_id                IN NUMBER DEFAULT NULL  --added for bug7038890
   ) ;

PROCEDURE update_quantities_for_form
  (  p_api_version_number    IN  NUMBER
   , p_init_msg_lst          IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
   , p_tree_id               IN  INTEGER
   , p_revision              IN  VARCHAR2 DEFAULT NULL
   , p_lot_number            IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code     IN  VARCHAR2 DEFAULT NULL
   , p_locator_id            IN  NUMBER   DEFAULT NULL
   , p_primary_quantity      IN  NUMBER
   , p_secondary_quantity    IN  NUMBER
   , p_quantity_type         IN  INTEGER
   , x_qoh                   OUT NOCOPY NUMBER
   , x_rqoh                  OUT NOCOPY NUMBER
   , x_qr                    OUT NOCOPY NUMBER
   , x_qs                    OUT NOCOPY NUMBER
   , x_att                   OUT NOCOPY NUMBER
   , x_atr                   OUT NOCOPY NUMBER
   , x_sqoh                  OUT NOCOPY NUMBER
   , x_srqoh                 OUT NOCOPY NUMBER
   , x_sqr                   OUT NOCOPY NUMBER
   , x_sqs                   OUT NOCOPY NUMBER
   , x_satt                  OUT NOCOPY NUMBER
   , x_satr                  OUT NOCOPY NUMBER
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_cost_group_id         IN  NUMBER DEFAULT NULL
   , p_containerized         IN  NUMBER DEFAULT g_containerized_false
   , p_call_for_form         IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_lpn_id                IN NUMBER DEFAULT NULL  --added for bug7038890
   ) ;

function do_check_release_locks return boolean;

END inv_quantity_tree_pvt;

/
