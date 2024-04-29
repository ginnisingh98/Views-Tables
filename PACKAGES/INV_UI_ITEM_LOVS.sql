--------------------------------------------------------
--  DDL for Package INV_UI_ITEM_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_UI_ITEM_LOVS" AUTHID CURRENT_USER AS
  /* $Header: INVITMLS.pls 120.2.12010000.2 2010/02/03 14:53:20 viiyer ship $ */

  TYPE t_genref IS REF CURSOR;

  --      Name: GET_ITEM_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_(LOVField)   which restricts LOV SQL to the user input text
  --                                e.g.  AS% for item LOV's contanenated_segment
  --       p_where_clause     different LOV beans pass in different where clause string
  --                         for their LOV SQL
  --                         The String should start with AND and conform with dynamic
  --                         SQL syntax  e.g. 'AND purchasing_enabled_flag = ''Y'''
  --
  --      Output parameters:
  --       x_Items      returns LOV rows as reference cursor
  --      Functions: This procedure uses dynamic SQL to handle different where clauses for
  --                 LOV query. To addd more columns to LOV subfield, one should append the
  --                 new columns to the end of the existing ones. Specifically, one should
  --                 modify the following local variable, l_sql_stmt, in the packge body
  --



  PROCEDURE get_item_lov(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_where_clause IN VARCHAR2);

  PROCEDURE get_item_lov_sub_loc_moqd(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_subinventory_code IN VARCHAR2, p_locator_id IN NUMBER, p_where_clause IN VARCHAR2) ;

  PROCEDURE get_transactable_items(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_transaction_action_id IN NUMBER, p_to_organization_id IN NUMBER DEFAULT NULL);

  --      Name: GET_REVISION_LOV
  --
  --      Input parameters:
  --       p_organization_id     Organization ID
  --       p_item_id             Inventory Item id
  --       p_revision            Revision
  --       p_planning_org_id     Planning Organization ID - Consignment and VMI Changes
  --       p_planning_tp_type    Planning TP Type         - Consignment and VMI Changes
  --       p_owning_org_id       Owning Organization ID   - Consignment and VMI Changes
  --       p_owning_tp_type      Owning TP Type           - Consignment and VMI Changes
  --
  --      Output parameters:
  --       x_revs                Returns LOV rows as Reference Cursor
  --
  --      Functions: This procedure returns valid Revisions after restricting it by
  --                 Org, Item, Planning and Owning criterions.
  --
  --
  PROCEDURE get_revision_lov(
    x_revs              OUT    NOCOPY t_genref
  , p_organization_id   IN     NUMBER
  , p_inventory_item_id IN     NUMBER
  , p_revision          IN     VARCHAR2
  , p_planning_org_id   IN     NUMBER DEFAULT NULL
  , p_planning_tp_type  IN     NUMBER DEFAULT NULL
  , p_owning_org_id     IN     NUMBER DEFAULT NULL
  , p_owning_tp_type    IN     NUMBER DEFAULT NULL
  );

  --      Name: GET_INV_TXN_REVISION_LOV
  --
  --      Input parameters:
  --       p_organization_id     Organization ID
  --       p_item_id             Inventory Item id
  --       p_revision            Revision
  --       p_planning_org_id     Planning Organization ID - Consignment and VMI Changes
  --       p_planning_tp_type    Planning TP Type         - Consignment and VMI Changes
  --       p_owning_org_id       Owning Organization ID   - Consignment and VMI Changes
  --       p_owning_tp_type      Owning TP Type           - Consignment and VMI Changes
  --
  --      Output parameters:
  --       x_revs                Returns LOV rows as Reference Cursor
  --
  --      Functions: This procedure returns valid Revisions after restricting it by
  --                 Org, Item, Planning and Owning criterions.
  --                 This lov is only applicable for inv transactions which restricts
  --                 unimplemented item revisions

  /* Bug# 8912324 : Added new proc get_inv_txn_revision_lov */
  PROCEDURE get_inv_txn_revision_lov(
    x_revs              OUT    NOCOPY t_genref
  , p_organization_id   IN     NUMBER
  , p_inventory_item_id IN     NUMBER
  , p_revision          IN     VARCHAR2
  , p_planning_org_id   IN     NUMBER DEFAULT NULL
  , p_planning_tp_type  IN     NUMBER DEFAULT NULL
  , p_owning_org_id     IN     NUMBER DEFAULT NULL
  , p_owning_tp_type    IN     NUMBER DEFAULT NULL
  );


  --      Name: GET_UOM_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Inventory_Item_Id restrict LOV for a given item
  --       p_UOM_code   which restricts LOV SQL to the user input text
  --                                e.g.  Ea%
  --
  --      Output parameters:
  --       x_UOMS      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text
  --


  PROCEDURE get_uom_lov(x_uoms OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_uom_code IN VARCHAR2);

  --      Name: GET_UOM_LOV_RCV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Inventory_Item_Id restrict LOV for a given item
  --       p_uom_type  restrict LOV to certain UOM type
  --       p_UOM_code   which restricts LOV SQL to the user input text
  --                                e.g.  Ea%
  --
  --      Output parameters:
  --       x_UOMS      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns UOM LOV rows for a given org, item and
  --                 user input text.
  --                 This API is for RECEIVING transaction only
  --

  PROCEDURE get_uom_lov_rcv(x_uoms OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_uom_type IN NUMBER, p_uom_code IN VARCHAR2);

  --      Name: GET_LOT_ITEMS_LOV
  --
  --      Input parameters:
  --      I/P     Parameters    OUT Cursor containing the LOV
  --                              IN Organization ID (N)
  --                              IN Lot Number (S)
  --                              IN Transaction ID (N)
  --                              IN Current Value entered (S)
  --
  --      Output parameters:
  --       x_Items      returns LOV rows as reference cursor
  --      Functions: This procedure projects item details from mtl_system_items_kfv for the
  --                 items that are valid for the given i/p lot number and org_id
  --


  PROCEDURE get_lot_items_lov(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_lot_number IN VARCHAR2, p_transaction_type_id IN VARCHAR2, p_concatenated_segments IN VARCHAR2);

  --      Name: GET_LOT_ITEM_DETAILS
  --
  --      Input parameters:
  --      I/P     Parameters    OUT Revision Control Code (N)
  --                            OUT Serial Number Control Code (N)
  --                            OUT Restrict Subinventories Code (N)
  --                            OUT Restrict Locators Code (N)
  --                            OUT Primary UOM Code (S)
  --                            OUT Shelf Life Code (N)
  --                            OUT Shelf Life Days (N)
  --                            OUT Allowed Units Lookup Code (N)
  --                            OUT Lot Status Enabled (S)
  --                            OUT Default Lot Status Id (N)
  --                            OUT Return Status (S)
  --                            OUT Message Count (N)
  --                            OUT Message Data (S)
  --                              IN Organization ID (N)
  --                              IN Lot Number (S)
  --                              IN Transaction ID (S)
  --                              IN Inventory Item ID (N)
  --
  --      Output parameters:
  --       x_revision_qty_control_code
  --       x_serial_number_control_code
  --       x_restrict_subinventories_code
  --       x_restrict_locators_code
  --       x_location_control_code
  --       x_primary_uom_code
  --       x_shelf_life_code
  --       x_shelf_life_days
  --       x_allowed_units_lookup_code
  --       x_lot_status_enabled
  --       x_default_lot_status_id
  --       x_return_status
  --       x_msg_count
  --       x_msg_data
  --
  --      Functions: This procedure projects item details from mtl_system_items_kfv for the
  --                 items that are valid for the given i/p org_id and lot number

  PROCEDURE get_lot_item_details(
    x_revision_qty_control_code    OUT    NOCOPY NUMBER
  , x_serial_number_control_code   OUT    NOCOPY NUMBER
  , x_restrict_subinventories_code OUT    NOCOPY NUMBER
  , x_restrict_locators_code       OUT    NOCOPY NUMBER
  , x_location_control_code        OUT    NOCOPY NUMBER
  , x_primary_uom_code             OUT    NOCOPY VARCHAR2
  , x_shelf_life_code              OUT    NOCOPY NUMBER
  , x_shelf_life_days              OUT    NOCOPY NUMBER
  , x_allowed_units_lookup_code    OUT    NOCOPY NUMBER
  , x_lot_status_enabled           OUT    NOCOPY VARCHAR2
  , x_default_lot_status_id        OUT    NOCOPY NUMBER
  , x_return_status                OUT    NOCOPY VARCHAR2
  , x_msg_count                    OUT    NOCOPY NUMBER
  , x_msg_data                     OUT    NOCOPY VARCHAR2
  , p_organization_id              IN     NUMBER
  , p_lot_number                   IN     VARCHAR2
  , p_transaction_type_id          IN     VARCHAR2
  , p_inventory_item_id            IN     NUMBER
  );

  --      Name: GET_LOT_ITEM_DETAILS
  --
  --      Input parameters:
  --      I/P     Parameters    OUT Revision Control Code (N)
  --                            OUT Serial Number Control Code (N)
  --                            OUT Restrict Subinventories Code (N)
  --                            OUT Restrict Locators Code (N)
  --                            OUT Primary UOM Code (S)
  --                            OUT Shelf Life Code (N)
  --                            OUT Shelf Life Days (N)
  --                            OUT Allowed Units Lookup Code (N)
  --                            OUT Lot Status Enabled (S)
  --                            OUT Default Lot Status Id (N)
  --                            OUT x_GRADE_CONTROL_FLAG (S)
  --                            OUT x_DEFAULT_GRADE (S)
  --                            OUT x_EXPIRATION_ACTION_INTERVAL (N)
  --                            OUT x_EXPIRATION_ACTION_CODE (S)
  --                            OUT x_HOLD_DAYS (N)
  --                            OUT x_MATURITY_DAYS (N)
  --                            OUT x_RETEST_INTERVAL (N)
  --                            OUT x_COPY_LOT_ATTRIBUTE_FLAG (S)
  --                            OUT x_CHILD_LOT_FLAG (S)
  --                            OUT x_CHILD_LOT_VALIDATION_FLAG (S)
  --                            OUT x_LOT_DIVISIBLE_FLAG (S)
  --                            OUT x_SECONDARY_UOM_CODE (S)
  --                            OUT x_SECONDARY_DEFAULT_IND (S)
  --                            OUT x_TRACKING_QUANTITY_IND (S)
  --                            OUT x_DUAL_UOM_DEVIATION_HIGH (N)
  --                            OUT x_DUAL_UOM_DEVIATION_LOW (N)
  --                            OUT Return Status (S)
  --                            OUT Message Count (N)
  --                            OUT Message Data (S)
  --                              IN Organization ID (N)
  --                              IN Lot Number (S)
  --                              IN Transaction ID (S)
  --                              IN Inventory Item ID (N)
  --
  --      Output parameters:
  --       x_revision_qty_control_code
  --       x_serial_number_control_code
  --       x_restrict_subinventories_code
  --       x_restrict_locators_code
  --       x_location_control_code
  --       x_primary_uom_code
  --       x_shelf_life_code
  --       x_shelf_life_days
  --       x_allowed_units_lookup_code
  --       x_lot_status_enabled
  --       x_default_lot_status_id
  --         x_GRADE_CONTROL_FLAG
  --         x_DEFAULT_GRADE
  --         x_EXPIRATION_ACTION_INTERVAL
  --         x_EXPIRATION_ACTION_CODE
  --         x_HOLD_DAYS
  --         x_MATURITY_DAYS
  --         x_RETEST_INTERVAL
  --         x_COPY_LOT_ATTRIBUTE_FLAG
  --         x_CHILD_LOT_FLAG
  --         x_CHILD_LOT_VALIDATION_FLAG
  --         x_LOT_DIVISIBLE_FLAG
  --         x_SECONDARY_UOM_CODE
  --         x_SECONDARY_DEFAULT_IND
  --         x_TRACKING_QUANTITY_IND
  --         x_DUAL_UOM_DEVIATION_HIGH
  --         x_DUAL_UOM_DEVIATION_LOW
  --       x_return_status
  --       x_msg_count
  --       x_msg_data
  --
  --      Functions: This overridden procedure projects item details including DUOM attributes
  --                 from mtl_system_items_kfv for the items that are valid for the given
  --                 i/p org_id and lot number

  PROCEDURE get_lot_item_details(
    x_revision_qty_control_code    OUT    NOCOPY NUMBER
  , x_serial_number_control_code   OUT    NOCOPY NUMBER
  , x_restrict_subinventories_code OUT    NOCOPY NUMBER
  , x_restrict_locators_code       OUT    NOCOPY NUMBER
  , x_location_control_code        OUT    NOCOPY NUMBER
  , x_primary_uom_code             OUT    NOCOPY VARCHAR2
  , x_shelf_life_code              OUT    NOCOPY NUMBER
  , x_shelf_life_days              OUT    NOCOPY NUMBER
  , x_allowed_units_lookup_code    OUT    NOCOPY NUMBER
  , x_lot_status_enabled           OUT    NOCOPY VARCHAR2
  , x_default_lot_status_id        OUT    NOCOPY NUMBER
  , x_GRADE_CONTROL_FLAG OUT    NOCOPY VARCHAR2
  , x_DEFAULT_GRADE OUT    NOCOPY VARCHAR2
  , x_EXPIRATION_ACTION_INTERVAL OUT    NOCOPY NUMBER
  , x_EXPIRATION_ACTION_CODE OUT    NOCOPY VARCHAR2
  , x_HOLD_DAYS OUT    NOCOPY NUMBER
  , x_MATURITY_DAYS OUT    NOCOPY NUMBER
  , x_RETEST_INTERVAL OUT    NOCOPY NUMBER
  , x_COPY_LOT_ATTRIBUTE_FLAG OUT    NOCOPY VARCHAR2
  , x_CHILD_LOT_FLAG OUT    NOCOPY VARCHAR2
  , x_CHILD_LOT_VALIDATION_FLAG OUT    NOCOPY VARCHAR2
  , x_LOT_DIVISIBLE_FLAG OUT    NOCOPY VARCHAR2
  , x_SECONDARY_UOM_CODE OUT    NOCOPY VARCHAR2
  , x_SECONDARY_DEFAULT_IND OUT    NOCOPY VARCHAR2
  , x_TRACKING_QUANTITY_IND OUT    NOCOPY VARCHAR2
  , x_DUAL_UOM_DEVIATION_HIGH OUT    NOCOPY NUMBER
  , x_DUAL_UOM_DEVIATION_LOW OUT    NOCOPY NUMBER
  , x_return_status                OUT    NOCOPY VARCHAR2
  , x_msg_count                    OUT    NOCOPY NUMBER
  , x_msg_data                     OUT    NOCOPY VARCHAR2
  , p_organization_id              IN     NUMBER
  , p_lot_number                   IN     VARCHAR2
  , p_transaction_type_id          IN     VARCHAR2
  , p_inventory_item_id            IN     NUMBER
  );

  --      Name: GET_STATUS_ITEMS_LOV
  --
  --      Input parameters:
  --      I/P     Parameters    OUT Cursor containing the LOV
  --                              IN Organization ID (N)
  --                              IN Current Value entered (S)
  --				  IN Subinventory Code (S)
  --                              IN Locator Id (N)
  --
  --      Output parameters:
  --       x_Items      returns LOV rows as reference cursor
  --      Functions: This procedure projects item details from mtl_system_items_kfv for the
  --                 items that are valid for the given i/p org_id and entered Concatenated_Segments
  --                 If Subinventory code is provided, then Return Item list is filtered for this subinventory
  --                 If Locator code is provided and NOT EQUAL to -1, then Return Item List is filtered for this Locator id

PROCEDURE get_status_items_lov(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_subinventory_code IN VARCHAR2, p_locator_id IN NUMBER);

  --      Name: GET_SHIP_ITEMS_LOV
  --
  --      Input parameters:
  --      I/P     Parameters    OUT Cursor containing the LOV
  --                              IN Organization ID (N)
  --                              IN Delivery ID (N)
  --                              IN Current Value entered (S)
  --
  --      Output parameters:
  --       x_Items      returns LOV rows as reference cursor
  --      Functions: This procedure projects item details from mtl_system_items_kfv for the
  --                 items that are valid for the given i/p org_id and entered
  --                 Concatenated_Segments and within the given delivery id
  --

  PROCEDURE get_ship_items_lov(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_delivery_id IN NUMBER, p_concatenated_segments IN VARCHAR2);

  --      Name: GET_PHYINV_ITEM_LOV
  --
  --      Input parameters:
  --
  --        p_concatenated_segments - User inputted value
  --        p_organization_id     -  Organization ID
  --        p_subinventory_code   -  Subinventory
  --        p_locator_id          -  Locator ID
  --        p_dynamic_entry_flag  -  Indicates if dynamic entries are allowed
  --        p_physical_inventory_id - Restricts output to the given physical inventory
  --        p_parent_lpn_id       -  Restricts output to only items with the
  --                                 given parent lpn ID
  --
  --      Output parameters:
  --       x_items    -  returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns valid items that are associated
  --                 with the given physical inventory
  --

  PROCEDURE get_phyinv_item_lov(
    x_items                 OUT    NOCOPY t_genref
  , p_concatenated_segments IN     VARCHAR2
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_dynamic_entry_flag    IN     NUMBER
  , p_physical_inventory_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  );

  --      Name: GET_PHYINV_REV_LOV
  --
  --      Input parameters:
  --       p_organization_id    - restricts LOV SQL to current org
  --       p_inventory_item_id  - restrict LOV for a given item
  --       p_revision           - restricts LOV SQL to the user input text
  --                                e.g.  A101%
  --       p_dynamic_entry_flag - Indicates if dynamic entries are allowed
  --       p_physical_inventory_id - restricts LOV SQL to current physical inventory
  --       p_parent_lpn_id      -  Restricts output to only items with the
  --                               given parent lpn ID
  --
  --      Output parameters:
  --       x_revs      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text for a given physical inventory
  --

  PROCEDURE get_phyinv_rev_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_revision IN VARCHAR2, p_dynamic_entry_flag IN NUMBER, p_physical_inventory_id IN NUMBER, p_parent_lpn_id IN NUMBER);

  --      Name: GET_PHYINV_UOM_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_inventory_item_id     - Restricts LOV for a given item
  --       p_uom_code              - Restricts LOV SQL to the user input text
  --                                   e.g.  Ea%
  --       p_dynamic_entry_flag    - Indicates if dynamic entries are allowed
  --       p_physical_inventory_id - Restricts LOV SQL to current physical inventory
  --
  --      Output parameters:
  --       x_uoms      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user inputted text for valid UOM's for a particular
  --                 physical inventory
  --

  PROCEDURE get_phyinv_uom_lov(x_uoms OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_uom_code IN VARCHAR2);

  --      Name: GET_CONTAINER_ITEM_LOV
  --
  --      Input parameters:
  --
  --        p_concatenated_segments - Restricts output to user inputted value
  --        p_organization_id     -  Organization ID
  --
  --      Output parameters:
  --       x_items    -  returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns valid container items
  --                 within the given org
  --

  PROCEDURE get_container_item_lov(x_items OUT NOCOPY t_genref, p_concatenated_segments IN VARCHAR2, p_organization_id IN NUMBER);

  --      Name: GET_CYC_ITEM_LOV
  --
  --      Input parameters:
  --
  --        p_concatenated_segments - User inputted value
  --        p_organization_id     -  Organization ID
  --        p_subinventory_code   -  Subinventory
  --        p_locator_id          -  Locator ID
  --        p_unscheduled_entry   -  Indicates if unscheduled entries are allowed
  --        p_cycle_count_header_id - Restricts output to the given cycle count
  --        p_parent_lpn_id       -  Restricts output to only items with the
  --                                 given parent lpn ID
  --
  --      Output parameters:
  --       x_items    -  returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns valid items that are associated
  --                 with the given cycle count
  --

  PROCEDURE get_cyc_item_lov(
    x_items                 OUT    NOCOPY t_genref
  , p_concatenated_segments IN     VARCHAR2
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_unscheduled_entry     IN     NUMBER
  , p_cycle_count_header_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  );

  --      Name: GET_CYC_REV_LOV
  --
  --      Input parameters:
  --       p_organization_id    - restricts LOV SQL to current org
  --       p_inventory_item_id  - restrict LOV for a given item
  --       p_revision           - restricts LOV SQL to the user input text
  --                                e.g.  A101%
  --       p_unscheduled_entry  - Indicates if unscheduled entries are allowed
  --       p_cycle_count_header_id - restricts LOV SQL to current cycle count
  --       p_parent_lpn_id      -  Restricts output to only items with the
  --                               given parent lpn ID
  --
  --      Output parameters:
  --       x_revs      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text for a given cycle count
  --

  PROCEDURE get_cyc_rev_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_revision IN VARCHAR2, p_unscheduled_entry IN NUMBER, p_cycle_count_header_id IN NUMBER, p_parent_lpn_id IN NUMBER);

  --      Name: GET_CYC_UOM_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_inventory_item_id     - Restricts LOV for a given item
  --       p_uom_code              - Restricts LOV SQL to the user input text
  --                                   e.g.  Ea%
  --       p_unscheduled_entry     - Indicates if unscheduled entries are allowed
  --       p_cycle_count_header_id - Restricts LOV SQL to current cycle count
  --
  --      Output parameters:
  --       x_uoms      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user inputted text for valid UOM's for a particular
  --                 cycle count
  --

  PROCEDURE get_cyc_uom_lov(x_uoms OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_uom_code IN VARCHAR2);

  --      Name: GET_INSPECT_ITEM_LOV
  --
  --      Input parameters:
  --       p_organization_id         organization where the inspection occurs
  --       p_concatenated_segments   restricts output to user entered search pattern for item
  --       p_lpn_id                  id of lpn that contains items to be inspected
  --
  --      Output parameters:
  --       x_items      returns LOV rows as reference cursor
  --
  --      Functions:
  --      This procedure returns the items that need inspection
  --

  PROCEDURE get_inspect_item_lov(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_lpn_id IN NUMBER);

  --      Name: GET_INSPECT_REVISION_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Inventory_Item_Id restrict LOV for a given item
  --       p_lpn_id            restricts items to lpn that is being inspected
  --       p_Revision          which restricts LOV SQL to the user input text
  --                                e.g.  A101%
  --
  --      Output parameters:
  --       x_Revs      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text
  --
  --
  --

  PROCEDURE get_inspect_revision_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_lpn_id IN NUMBER, p_revision IN VARCHAR2);

  --      Name: GET_OH_ITEM_LOV
  --
  --      Input parameters:
  --       p_org_id             which restricts LOV SQL to current org
  --       p_subinventory_code    Subinventory
  --       p_locator_id           Locator ID
  --       p_lpn_id             restricts items to lpn that is being inspected
  --   p_container_item_flag  container or content item 'Y' = container item
  --       p_item_id            which restricts LOV SQL to the user input text
  --                              e.g.  A101%
  --
  --      Output parameters:
  --       x_Items      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text
  --
  --
  --
  PROCEDURE get_oh_item_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_subinventory_code VARCHAR2 DEFAULT NULL, p_locator_id VARCHAR2 DEFAULT NULL, p_container_item_flag VARCHAR2 DEFAULT NULL, p_item IN VARCHAR2);

  --      Name: GET_CONT_ITEM_LOV
  --
  --      Input parameters:
  --       p_org_id             which restricts LOV SQL to current org
  --       p_lpn_id             lpn in which items are contained inside
  --       p_item_id            which restricts LOV SQL to the user input text
  --                              e.g.  A101%
  --
  --      Output parameters:
  --       x_Items      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text
  --
  --
  --
  PROCEDURE get_cont_item_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_lpn_id IN VARCHAR2, p_item IN VARCHAR2);

  --      Name: GET_BP_ITEM_LOV
  --
  --      Input parameters:
  --       p_org_id             which restricts LOV SQL to current org
  --       p_subinventory_code    Subinventory
  --       p_locator_id           Locator ID
  --   p_container_item_flag  container or content item 'Y' = container item
  --       p_source             item source 1,2,3 (inventory/wip/rec)
  --       p_item_id            which restricts LOV SQL to the user input text
  --                              e.g.  A101%
  --
  --      Output parameters:
  --       x_Items      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text
  --
  --
  --
  PROCEDURE get_bp_item_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_subinventory_code VARCHAR2 DEFAULT NULL, p_locator_id VARCHAR2 DEFAULT NULL, p_container_item_flag VARCHAR2 DEFAULT NULL, p_source VARCHAR2 DEFAULT NULL, p_item VARCHAR2);

  --      Name: GET_CONT_UOM_LOV
  --
  --      Input parameters:
  --       p_organization_id      which restricts LOV SQL to current org
  --       p_Inventory_Item_Id    restrict LOV for a given item
  --   p_lpn_id   lpn in which items reside
  --       p_UOM_code           which restricts LOV SQL to the user input text
  --                              e.g.  A101%
  --
  --      Output parameters:
  --       x_UOMS      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text
  --
  --
  --
  PROCEDURE get_cont_uom_lov(x_uoms OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_lpn_id IN NUMBER, p_uom_code IN VARCHAR2);

  --      Name: GET_ALL_UOM_LOV
  --
  --      Input parameters:
  --       p_UOM_code           which restricts LOV SQL to the user input text
  --                              e.g.  A101%
  --
  --      Output parameters:
  --       x_UOMS      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text
  --
  --
  --
  PROCEDURE get_all_uom_lov(x_uoms OUT NOCOPY t_genref, p_uom_code IN VARCHAR2);

  --      Name: GET_INV_INSPECT_ITEM_LOV
  --
  --      Input parameters:
  --       p_organization_id         organization where the inspection occurs
  --       p_concatenated_segments   restricts output to user entered search pattern for item
  --       p_source                  document source type being inspected
  --           PO, INTSHIP, RMA, RECEIPT
  --       p_source_id               relevant document id based on p_source
  --           po_header_id, shipment_header_id, oe_order_header_id,
  --           receipt_num
  --
  --      Output parameters:
  --       x_items      returns LOV rows as reference cursor
  --
  --      Functions:
  --                      This procedure returns the items that need inspection
  --

  PROCEDURE get_inv_inspect_item_lov(x_items OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2, p_source IN VARCHAR2, p_source_id IN NUMBER);

  --      Name: GET_INV_INSPECT_REVISION_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_Inventory_Item_Id restrict LOV for a given item
  --       p_source                  document source type being inspected
  --           PO, INTSHIP, RMA, RECEIPT
  --       p_source_id               relevant document id based on p_source
  --           po_header_id, shipment_header_id, oe_order_header_id,
  --           receipt_num
  --       p_Revision          which restricts LOV SQL to the user input text
  --                                e.g.  A101%
  --
  --      Output parameters:
  --       x_Revs      returns LOV rows as reference cursor
  --
  --      Functions: This procedure returns LOV rows for a given org, item and
  --                 user input text
  --
  --
  --

  PROCEDURE get_inv_inspect_revision_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_source IN VARCHAR2, p_source_id IN NUMBER, p_revision IN VARCHAR2);

  --      Name: GET_CGUPDATE_ITEM_LOV
  --
  --      Input parameters:
  --       p_org_id        - restricts LOV SQL to current org
  --       p_lpn_id        - restricts LOV SQL to given lpn
  --       p_item          - which restricts LOV SQL to the user input text
  --                                e.g.  A101%
  --
  --      Output parameters:
  --       x_items         - returns item LOV rows as reference cursor
  --
  --      Functions: This procedure returns item LOV rows for a given org and
  --                 user input text for the item
  PROCEDURE get_cgupdate_item_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_lpn_id IN NUMBER, p_item IN VARCHAR2);

  --      Name: GET_CONTENT_REVISION_LOV
  --
  --      Input parameters:
  --       p_organization_id          - restricts LOV SQL to current org
  --       p_inventory_item_id          - restricts LOV SQL to given item
  --     p_lpn_id     - restricts LOV SQL to given lpn
  --       p_revision             - which restricts LOV SQL to the user input text
  --                                  e.g.  A101%
  --
  --      Output parameters:
  --       x_items         - returns item LOV rows as reference cursor
  --
  --      Functions: This procedure returns item LOV rows for a given org and
  --                 user input text for the item
  PROCEDURE get_content_revision_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN VARCHAR2, p_lpn_id IN VARCHAR2, p_revision IN VARCHAR2);

  --      Name: GET_SYSTEM_ITEM_LOV
  --
  --      Input parameters:
  --       p_organization_id          - restricts LOV SQL to current org
  --       p_item_id                  - restricts LOV SQL to given item
  --      Output parameters:
  --       x_items         - returns item LOV rows as reference cursor
  --
  --      Functions: This procedure returns item LOV rows for a given org and
  --                 user input text for the item
  PROCEDURE get_system_item_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_item IN VARCHAR2);

  --      Name: GET_SERIAL_ITEM_LOV
  --
  --      Input parameters:
  --       p_organization_id          - restricts LOV SQL to current org
  --       p_serial                   - restricts LOV SQL to specific serial number
  --       p_item_id                  - restricts LOV SQL to given item
  --      Output parameters:
  --       x_items         - returns item LOV rows as reference cursor
  --
  --      Functions: This procedure returns item LOV rows for a given org, sn ,and
  --                 user input text for the item
  PROCEDURE get_serial_item_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_serial IN VARCHAR2, p_item IN VARCHAR2);

  --"Returns"
  --      Name: GET_RETURN_ITEMS_LOV
  --
  --      Input parameters:
  --       p_org_id              - restricts LOV SQL to current org
  --       p_lpn_id              - restricts LOV SQL to given lpn
  --       p_item_id             - restricts LOV SQL to given item
  --
  --      Output parameters:
  --       x_Items         - returns item LOV rows as reference cursor
  --
  --      Functions: This procedure returns item LOV rows for a given org, lpn and
  --                 user input text for the item

  PROCEDURE get_return_items_lov(x_items OUT NOCOPY t_genref, p_org_id IN NUMBER, p_lpn_id IN NUMBER, p_item IN VARCHAR2);

  --      Name: GET_RETURN_REVISION_LOV
  --
  --      Input parameters:
  --       p_organization_id        - restricts LOV SQL to current org
  --       p_inventory_item_id      - restricts LOV SQL to given item
  --       p_lpn_id                 - restricts LOV SQL to given lpn
  --       p_revision               - which restricts LOV SQL to the user input text
  --                                      e.g.  A101%
  --
  --      Output parameters:
  --       x_Revs         - returns Revision LOV rows as reference cursor
  --
  --      Functions: This procedure returns Revision LOV rows for a given org,
  --       inventory item id, lpn id and user input revision text
  PROCEDURE get_return_revision_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN VARCHAR2, p_lpn_id IN VARCHAR2, p_revision IN VARCHAR2);

  --"Returns"

  /* Direct Shipping */

  PROCEDURE get_vehicle_lov(x_vehicle OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2);

  --Bug#2310308
  PROCEDURE get_direct_ship_uom_lov(x_uom OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_lpn_id IN NUMBER, p_uom_text IN VARCHAR2);

  --Bug#2310308
  /* Direct Shipping */

  --Bug#2252193
  PROCEDURE get_deliver_revision_lov(x_revs OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER, p_po_header_id IN NUMBER, p_shipment_header_id IN NUMBER, p_revision IN VARCHAR2);

--Bug# 2647045
FUNCTION conversion_order(p_uom_string VARCHAR2) RETURN NUMBER;

--Bug# 2647045
FUNCTION get_conversion_rate(p_from_uom_code   varchar2,
			     p_organization_id NUMBER,
			     p_item_id         NUMBER)
RETURN VARCHAR2;


--      Name: GET_MO_ITEM_LOV
--
--      Input parameters:
--       p_Organization_Id       which restricts LOV SQL to current org
--       p_Concatenated_segments which resticts the LOV to the Item that user has enteredA
--       p_header_id             HeaderId from mtl_txn_request_lines
--      Output parameters:
--       x_Items      returns LOV rows as reference cursor
--
--      Functions: This procedure returns LOV rows for a given org, item and
--                 header_id
--
--
--
PROCEDURE get_mo_item_lov
  (x_Items OUT NOCOPY t_genref,
   p_Organization_Id IN NUMBER,
   p_Concatenated_Segments IN VARCHAR2,
   p_header_id IN VARCHAR2);

--added the procedure for handling lpn and loose in update status page for LPN status project
PROCEDURE get_ostatus_items_lov(x_items OUT NOCOPY t_genref,
                               p_organization_id IN NUMBER,
                               p_lpn IN VARCHAR2,
                               p_concatenated_segments IN VARCHAR2,
                               p_subinventory_code IN VARCHAR2,
                               p_locator_id IN NUMBER);



END inv_ui_item_lovs;

/
