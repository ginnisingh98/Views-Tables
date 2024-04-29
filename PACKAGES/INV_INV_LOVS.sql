--------------------------------------------------------
--  DDL for Package INV_INV_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INV_LOVS" AUTHID CURRENT_USER AS
  /* $Header: INVINVLS.pls 120.5.12010000.5 2010/03/26 10:43:02 kjujjuru ship $ */

  TYPE t_genref IS REF CURSOR;

  --      Name: GET_LOT_LOV
  --
  --      Input parameters:
  --       p_organization_id     Organization ID
  --       p_item_id             Inventory Item id
  --       p_lot_number          Lot Number
  --       p_transaction_type_id Used for Material Status Applicability Check
  --       p_wms_installed       Used for Material Status Applicability Check
  --       p_lpn_id              LPN ID
  --       p_subinventory_code   SubInventory Code
  --       p_locator_id          Locator ID
  --       p_planning_org_id     Planning Organization ID - Consignment and VMI Changes
  --       p_planning_tp_type    Planning TP Type         - Consignment and VMI Changes
  --       p_owning_org_id       Owning Organization ID   - Consignment and VMI Changes
  --       p_owning_tp_type      Owning TP Type           - Consignment and VMI Changes
  --
  --      Output parameters:
  --       x_lot_num_lov         Returns the LOV rows as a Reference Cursor
  --
  --      Functions: This API returns Lot number for a given org and Item Id
  PROCEDURE get_lot_lov(
    x_lot_num_lov         OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_lot_number          IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_lpn_id              IN     NUMBER DEFAULT NULL
  , p_subinventory_code   IN     VARCHAR2 DEFAULT NULL
  , p_locator_id          IN     NUMBER DEFAULT NULL
  , p_planning_org_id     IN     NUMBER DEFAULT NULL
  , p_planning_tp_type    IN     NUMBER DEFAULT NULL
  , p_owning_org_id       IN     NUMBER DEFAULT NULL
  , p_owning_tp_type      IN     NUMBER DEFAULT NULL
  );

  --      Name: GET_LOT_LOV_FOR_RECEIVING
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --       p_lpn_id      which restricts LOV SQL to the given lpn
  --       p_subinventory_code which restricts LOV SQL to the given sub
  --       p_locator_id which restricts LOV SQL to the given locator
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --

  PROCEDURE get_lot_lov_for_receiving(
    x_lot_num_lov         OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_lot_number          IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_lpn_id              IN     NUMBER DEFAULT NULL
  , p_subinventory_code   IN     VARCHAR2 DEFAULT NULL
  , p_locator_id          IN     NUMBER DEFAULT NULL
  );

  --      Name: ASN_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --       p_source_header_id which restricts to the shipment
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --
  --

  PROCEDURE asn_lot_lov(
    x_lot_num_lov         OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_lot_number          IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_lpn_id              IN     NUMBER DEFAULT NULL
  , p_subinventory_code   IN     VARCHAR2 DEFAULT NULL
  , p_locator_id          IN     NUMBER DEFAULT NULL
  , p_source_header_id    IN     NUMBER DEFAULT NULL
  );

  --      Name: GET_LOT_LOV_INT_SHP_RCV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_shipment_header_id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org, lpn
  --              and Item Id
  --
  -- Added p_subinventory_code and p_locator_id parameters as part of onhand status support project
  PROCEDURE get_lot_lov_int_shp_rcv(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_shipment_header_id IN NUMBER,p_lot_number IN VARCHAR2,
                                    p_transaction_type_id IN NUMBER, p_wms_installed IN VARCHAR2 ,p_subinventory_code IN VARCHAR2 DEFAULT NULL,p_locator_id IN NUMBER DEFAULT NULL, p_from_lpn_id IN NUMBER  DEFAULT NULL); -- Bug 6908946

  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --

  PROCEDURE get_pack_lot_lov(
    x_lot_num_lov         OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_revision            IN     VARCHAR2 := NULL
  , p_subinventory_code   IN     VARCHAR2 := NULL
  , p_locator_id          IN     NUMBER := 0
  , p_lot_number          IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER := 0
  , p_wms_installed       IN     VARCHAR2 := 'TRUE'
  );

  --      Name: GET_INQ_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id without status restrictiong for inquiry purpose.
  --

  PROCEDURE get_inq_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_lot_number IN VARCHAR2);

  PROCEDURE get_from_status_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_lot_number IN VARCHAR2);

  --      Name: GET_TO_STATUS_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --       p_from_lot_number   starting lot number
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --


  PROCEDURE get_to_status_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_from_lot_number IN VARCHAR2, p_lot_number IN VARCHAR2);

  --      Name: GET_REASON_LOV
  --
  --      Input parameters:
  --       p_reason   which restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_reason_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Transaction Reasons
  --

  PROCEDURE get_reason_lov(x_reason_lov OUT NOCOPY t_genref, p_reason IN VARCHAR2);

  --      Name: GET_REASON_LOV
  --       Overloaed Procedure for Transaction Reason Security build. 4505091, nsrivast
  --      Input parameters:
  --       p_reason       restricts LOV SQL to the user input text
  --       p_txn_type_id  restricts LOV SQL specific transaction type id.
  --      Output parameters:
  --       x_reason_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Transaction Reasons
  --
  PROCEDURE get_reason_lov(x_reason_lov OUT NOCOPY t_genref, p_reason IN VARCHAR2, p_txn_type_id IN VARCHAR2 );


  PROCEDURE get_to_org_lov(x_to_org_lov OUT NOCOPY t_genref, p_from_organization_id IN NUMBER, p_to_organization_code IN VARCHAR2);

  -- used by org transfer
  PROCEDURE get_to_org(x_organizations OUT NOCOPY t_genref, p_from_organization_id IN NUMBER, p_to_organization_code IN VARCHAR2);

  PROCEDURE get_all_orgs(x_organizations OUT NOCOPY t_genref, p_organization_code IN VARCHAR2);

  PROCEDURE get_cost_group(x_cost_group_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_cost_group IN VARCHAR2);

  --      Name: GET_CGUPDATE_COST_GROUP
  --
  --      Input parameters:
  --        p_organization_id         Restricts LOV SQL to specific org
  --        p_lpn_id                  Restricts LOV SQL to specific LPN
  --        p_inventory_item_id       Restricts LOV SQL to specific item
  --        p_subinventory            Restricts LOV SQL to specific sub
  --        p_locator_id              Restricts LOV SQL to specific loc if given
  --        p_from_cost_group_id      Restricts LOV SQL to not include the
  --                                  from cost group if not null
  --        p_from_cost_group         Restricts LOV SQL to user input text
  --        p_to_cost_group           Restricts LOV SQL to user input text
  --
  --      Output parameters:
  --        x_cost_group_lov          Output reference cursor which stores
  --                                  the LOV rows for valid cost groups
  --
  --      Functions: This API returns a reference cursor for valid cost groups
  --                 in Cost Group update UI associated with the given parameters
  --
  PROCEDURE get_cgupdate_cost_group(
    x_cost_group_lov     OUT    NOCOPY t_genref
  , p_organization_id    IN     NUMBER
  , p_lpn_id             IN     NUMBER
  , p_inventory_item_id  IN     NUMBER
  , p_revision           IN     VARCHAR2
  , p_subinventory_code  IN     VARCHAR2
  , p_locator_id         IN     NUMBER
  , p_from_cost_group_id IN     NUMBER
  , p_from_cost_group    IN     VARCHAR2
  , p_to_cost_group      IN     VARCHAR2
  );

  --      Name: GET_PHYINV_COST_GROUP
  --
  --      Input parameters:
  --        p_organization_id         Restricts LOV SQL to specific org
  --        p_cost_group              Restricts LOV SQL to user inputted text
  --        p_inventory_item_id       Restricts LOV SQL to specific item
  --        p_subinventory            Restricts LOV SQL to specific sub
  --        p_locator_id              Restricts LOV SQL to specific loc if given
  --        p_dynamic_entry_flag      Indicates whether or not dynamic
  --                                  entries are allowed
  --        p_physical_inventory_id   Restricts LOV SQL to specific physical inventory
  --        p_parent_lpn_id           Restricts LOV SQL to specific parent
  --                                  LPN if given
  --
  --      Output parameters:
  --        x_cost_group_lov          Output reference cursor which stores
  --                                  the LOV rows for valid cost groups
  --
  --      Functions: This API returns a reference cursor for valid cost groups
  --                 associated with the given parameters
  --
  PROCEDURE get_phyinv_cost_group(
    x_cost_group_lov        OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_cost_group            IN     VARCHAR2
  , p_inventory_item_id     IN     NUMBER
  , p_subinventory          IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_dynamic_entry_flag    IN     NUMBER
  , p_physical_inventory_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  );

  --      Name: GET_CYC_COST_GROUP
  --
  --      Input parameters:
  --        p_organization_id         Restricts LOV SQL to specific org
  --        p_cost_group              Restricts LOV SQL to user inputted text
  --        p_inventory_item_id       Restricts LOV SQL to specific item
  --        p_subinventory            Restricts LOV SQL to specific sub
  --        p_locator_id              Restricts LOV SQL to specific loc if given
  --        p_unscheduled_entry       Indicates whether or not unscheduled
  --                                  entries are allowed
  --        p_cycle_count_header_id   Restricts LOV SQL to specific cycle count
  --        p_parent_lpn_id           Restricts LOV SQL to specific parent
  --                                  LPN if given
  --
  --      Output parameters:
  --        x_cost_group_lov          Output reference cursor which stores
  --                                  the LOV rows for valid cost groups
  --
  --      Functions: This API returns a reference cursor for valid cost groups
  --                 associated with the given parameters in a cycle count
  --
  PROCEDURE get_cyc_cost_group(
    x_cost_group_lov        OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_cost_group            IN     VARCHAR2
  , p_inventory_item_id     IN     NUMBER
  , p_subinventory          IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_unscheduled_entry     IN     NUMBER
  , p_cycle_count_header_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  );

  PROCEDURE get_txn_types(x_txntypelov OUT NOCOPY t_genref, p_transaction_action_id IN NUMBER, p_transaction_source_type_id IN NUMBER, p_transaction_type_name IN VARCHAR2);

  --      Name: GET_ITEM_LOT_LOV
  --
  --      Input parameters:
  --       p_wms_installed     which restricts LOV SQL to wms installed
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_txn_type_id       which restricts LOV SQL to txn type
  --       p_inventory_item_id which restricts LOV SQL to inventory item
  --       p_lot_number        which restricts LOV SQL to the user input text
  --       p_project_id        which restricts LOV SQL to project
  --       p_task_id           which restricts LOV SQL to task
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org
  --
-- Added p_subinventory_code and p_locator_id parameters as part of onhand status support project
  PROCEDURE get_item_lot_lov(
    x_lot_num_lov       OUT    NOCOPY t_genref
  , p_wms_installed     IN     VARCHAR2
  , p_organization_id   IN     NUMBER
  , p_txn_type_id       IN     NUMBER
  , p_inventory_item_id IN     VARCHAR2
  , p_lot_number        IN     VARCHAR2
  , p_project_id        IN     NUMBER DEFAULT NULL
  , p_task_id           IN     NUMBER DEFAULT NULL
  , p_subinventory_code IN     VARCHAR2 DEFAULT NULL
  , p_locator_id        IN     NUMBER   DEFAULT NULL
  );

    --      Name: GET_ITEM_LOT_LOV, overloaded with lot status id
  --
  --      Input parameters:
  --       p_wms_installed     which restricts LOV SQL to wms installed
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_txn_type_id       which restricts LOV SQL to txn type
  --       p_inventory_item_id which restricts LOV SQL to inventory item
  --       p_lot_number        which restricts LOV SQL to the user input text
  --       p_project_id        which restricts LOV SQL to project
  --       p_task_id           which restricts LOV SQL to task
  --	   p_status_id	       which restricts LOV SQL to lot_status
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org
  --

  PROCEDURE get_item_lot_lov(
    x_lot_num_lov       OUT    NOCOPY t_genref
  , p_wms_installed     IN     VARCHAR2
  , p_organization_id   IN     NUMBER
  , p_txn_type_id       IN     NUMBER
  , p_inventory_item_id IN     VARCHAR2
  , p_lot_number        IN     VARCHAR2
  , p_project_id        IN     NUMBER DEFAULT NULL
  , p_task_id           IN     NUMBER DEFAULT NULL
  , p_status_id		IN     NUMBER
  );

  PROCEDURE get_account_alias(x_accounts_info OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_description IN VARCHAR2);

  PROCEDURE get_accounts(x_accounts OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_concatenated_segments IN VARCHAR2);

  --
  --  Get accounts specific to a Move Order
  --
  PROCEDURE get_mo_accounts(x_accounts OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_moheader_id IN NUMBER, p_concatenated_segments IN VARCHAR2);

  --      Name: GET_PHYINV_LOT_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_subinventory_code     - Restricts LOV SQL to current subinventory
  --       p_locator_id            - Restricts LOV SQL to current locator
  --       p_inventory_item_id     - Restricts LOV SQL to current inventory item
  --       p_lot_number            - Restricts LOV SQL to the user input text
  --       p_dynamic_entry_flag    - Indicates if dynamic entries are allowed
  --       p_physical_inventory_id - Restricts LOV SQL to current physical inventory
  --       p_parent_lpn_id         - Restricts LOV SQL to lot numbers within
  --                                 the given parent lpn ID
  --
  --      Output parameters:
  --       x_lots      - returns LOV rows as reference cursor
  --
  --      Functions: This API returns lot number for a given org and inventory
  --                 item within a particular physical inventory
  --

  PROCEDURE get_phyinv_lot_lov(
    x_lots                  OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_lot_number            IN     VARCHAR2
  , p_dynamic_entry_flag    IN     NUMBER
  , p_physical_inventory_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  );

  --      Name: GET_CYC_LOT_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_subinventory_code     - Restricts LOV SQL to current subinventory
  --       p_locator_id            - Restricts LOV SQL to current locator
  --       p_inventory_item_id     - Restricts LOV SQL to current inventory item
  --       p_lot_number            - Restricts LOV SQL to the user input text
  --       p_unscheduled_entry     - Indicates if unscheduled entries are allowed
  --       p_cycle_count_header_id - Restricts LOV SQL to current cycle count
  --       p_parent_lpn_id         - Restricts LOV SQL to lot numbers within
  --                                 the given parent lpn ID
  --
  --      Output parameters:
  --       x_lots      - returns LOV rows as reference cursor
  --
  --      Functions: This API returns lot number for a given org and inventory
  --                 item within a particular cycle count
  --

  PROCEDURE get_cyc_lot_lov(
    x_lots                  OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_lot_number            IN     VARCHAR2
  , p_unscheduled_entry     IN     NUMBER
  , p_cycle_count_header_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  );

  --      Name: GET_CGUPDATE_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   restricts LOV SQL to current org
  --       p_lpn_id
  --       p_inventory_item_id restricts LOV SQL to Inventory Item id
  --       p_revision
  --       p_subinventory_code
  --       p_locator_id
  --       p_from_cost_Group_id
  --       p_lot_number        restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --

  PROCEDURE get_cgupdate_lot_lov(
    x_lot_num_lov        OUT    NOCOPY t_genref
  , p_organization_id    IN     NUMBER
  , p_lpn_id             IN     NUMBER
  , p_inventory_item_id  IN     NUMBER
  , p_revision           IN     VARCHAR2
  , p_subinventory_code  IN     VARCHAR2
  , p_locator_id         IN     NUMBER
  , p_from_cost_group_id IN     NUMBER
  , p_lot_number         IN     VARCHAR2
  );

  --      Name: GET_INSPECT_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lpn_id            LPN that is being inspected
  --       p_lot_number   which restricts LOV SQL to the user input text
  --       p_uom_code     the uom the user has chosen from the uom lov
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --

  PROCEDURE get_inspect_lot_lov(x_lot_num_lov OUT NOCOPY t_genref,
    p_organization_id IN NUMBER,
    p_item_id IN NUMBER,
    p_lpn_id IN NUMBER,
    p_lot_number IN VARCHAR2,
    p_uom_code IN VARCHAR2 DEFAULT NULL);

  --      Name: GET_CONT_LOT_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_inventory_item_id     - Restricts LOV SQL to current inventory item
  --       p_parent_lpn_id         - Restricts LOV SQL to lot numbers within
  --           the given parent lpn ID
  --       p_lot_number            - Restricts LOV SQL to the user input text
  --
  --
  --      Functions: This API returns lot number for a given org and inventory
  --                 item within a particular lpn
  -- Added p_subinventory_code and p_locator_id parameters as part of onhand status support project
  PROCEDURE get_cont_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_lpn_id IN NUMBER,p_lot_number IN VARCHAR2,p_subinventory_code IN VARCHAR2 DEFAULT NULL,p_locator_id IN NUMBER DEFAULT NULL);

-- Added p_subinventory_code and p_locator_id parameters as part of onhand status support project
  PROCEDURE get_split_cont_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_lpn_id IN NUMBER,p_lot_number IN VARCHAR2,p_subinventory_code IN VARCHAR2 DEFAULT NULL,p_locator_id IN NUMBER DEFAULT NULL);

  --      Name: GET_ALL_LOT_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_lot_number            - Restricts LOV SQL to the user input text
  --
  --
  --      Functions: This API returns all lot numbers for a given org
  --
  PROCEDURE get_all_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_lot_number IN VARCHAR2);

  --      Name: GET_OH_COST_GROUP_LOV
  --
  --      Input parameters:
  --      p_organization_id       - Restricts LOV SQL to current org
  --  p_inventory_item_id   - Restricts LOV SQL to current item id
  --  p_subinventory_code - Restricts LOV SQL to current sub
  --  p_locator_id    - Restricts LOV SQL to current loc
  --  p_cost_group    - Restricts LOV SQL to the user input text
  --
  --      Functions: This API returns all lot numbers for a given org
  --
  PROCEDURE get_oh_cost_group_lov(x_cost_group OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_inventory_item_id IN VARCHAR2, p_subinventory_code IN VARCHAR2, p_locator_id IN VARCHAR2, p_cost_group IN VARCHAR2);

  PROCEDURE tdatechk(p_org_id IN INTEGER, p_transaction_date IN DATE, x_period_id OUT NOCOPY INTEGER);

  --      Name: GET_LABEL_TYPE_LOV
  --
  --      Input parameters:
  --      p_wms_installed   true/false if wms is installed
  --      p_lookup_type     partial completion on lookup type
  --      Functions: This API returns all label types
  PROCEDURE get_label_type_lov(x_source_lov OUT NOCOPY t_genref, p_wms_installed IN VARCHAR2, p_lookup_type IN VARCHAR2);

  --      Name: GET_BUSINESSFLOW_TYPE_LOV
  --
  --      Input parameters:
  --      p_wms_installed   TRUE/FALSE if WMS is installed
  --              p_lookup_type     Partial completion on lookup type
  --      Functions: This API returns all label types
  PROCEDURE get_businessflow_type_lov(x_source_lov OUT NOCOPY t_genref, p_wms_installed IN VARCHAR2, p_lookup_type IN VARCHAR2);

  --      Name: GET_LABEL_TYPE_REPRINT_LOV
  --
  --      Input parameters:
  --      p_wms_installed   TRUE/FALSE if WMS is installed
  --              p_lookup_type     Partial completion on lookup type
  --      Functions: This API returns all label types


  PROCEDURE get_label_type_reprint_lov(x_source_lov OUT NOCOPY t_genref, p_wms_installed IN VARCHAR2, p_lookup_type IN VARCHAR2);

  --      Name: GET_NOTRX_ITEM_LOT_LOV
  --
  --      Input parameters:
  --      p_organization_id       - Restricts LOV SQL to current org
  --  p_inventory_item_id   - Restricts LOV SQL to current item id
  --      Functions: This API returns all lot numbers for a given org
  --      for items without transaction type
  PROCEDURE get_notrx_item_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_item_id IN NUMBER, p_lot_number IN VARCHAR2);

  --      Name: GET_TD_LOT_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           Inventory Item id
  --       p_lot_number   which restricts LOV SQL to the user input text
  --       p_lpn_id      which restricts LOV SQL to the given lpn
  --       p_subinventory_code which restricts LOV SQL to the given sub
  --       p_locator_id which restricts LOV SQL to the given locator
  --       p_txn_temp_id which restricts LOV SQL to the Allocated Lots
  --
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot number for a given org and
  --              and Item Id
  --

  --      Name: GET_ALL_LABEL_TYPE_LOV
  --
  --      Input parameters:
  --   p_wms_installed   true/false if wms is installed
  --   p_all_label_str   translated string for all label types
  --     p_lookup_type   partial completion on lookup type
  --      Functions: This API returns all label types

  PROCEDURE GET_ALL_LABEL_TYPE_LOV(
    x_source_lov  OUT  NOCOPY t_genref,
    p_wms_installed IN VARCHAR2,
    p_all_label_str IN VARCHAR2,
    p_lookup_type IN   VARCHAR2
  );

  PROCEDURE get_td_lot_lov(
    x_lot_num_lov         OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_lot_number          IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_lpn_id              IN     NUMBER DEFAULT NULL
  , p_subinventory_code   IN     VARCHAR2 DEFAULT NULL
  , p_locator_id          IN     NUMBER DEFAULT NULL
  , p_txn_temp_id         IN     NUMBER
  );


  PROCEDURE get_apl_lot_lov(
        x_lot_num_lov         OUT    NOCOPY t_genref
      , p_organization_id     IN     NUMBER
      , p_item_id             IN     NUMBER
      , p_lot_number          IN     VARCHAR2
      , p_transaction_type_id IN     NUMBER
      , p_wms_installed       IN     VARCHAR2
      , p_lpn_id              IN     NUMBER
      , p_subinventory_code   IN     VARCHAR2
      , p_locator_id          IN     NUMBER
      , p_txn_temp_id         IN     NUMBER
      , p_isLotSubtitution    IN     VARCHAR2 DEFAULT NULL --/* Bug 9448490 Lot Substitution Project */

    );

  --"Returns"
  --      Name: GET_RETURN_LOT_LOV
  --
  --      Input parameters:
  --      p_org_id                - Restricts LOV SQL to input org
  --      p_lpn_id                - Restricts LOV SQL to input LPN_ID
  --      p_item_id               - Restricts LOV SQL to input item id
  --      p_revision              - Restricts LOV SQL to input Revision
  --      p_lot_number            - Restricts LOV SQL to input Lot with %

  --      Functions: This API returns all lot numbers for a given LPN
  --                      and item that are marked for Return in LPN Contents
  PROCEDURE get_return_lot_lov(x_lot_num_lov OUT NOCOPY t_genref, p_org_id IN NUMBER, p_lpn_id IN NUMBER, p_item_id IN NUMBER, p_revision IN VARCHAR2, p_lot_number IN VARCHAR2);

  --"Returns"

  --      Name: GET_LOT_LOV_FOR_UNLOAD
  --
  --      Input parameters:
  --       p_temp_id  transaction_temp_id
  --      Output parameters:
  --       x_lot_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns Lot numbers allocated for a given task

  PROCEDURE get_lot_lov_for_unload(x_lot_num_lov OUT NOCOPY t_genref, p_temp_id IN NUMBER);

  --      Name: GET_FLOW_SCHEDULE_LOV
  --      Added by joabraha for jsheu
  --      Input parameters:
  --       p_organization_id  p_schedule_number
  --      Output parameters:
  --       x_flow_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns flow schedule numbers
  PROCEDURE get_flow_schedule_lov(x_flow_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER DEFAULT NULL, p_from_schedule_number IN VARCHAR2 DEFAULT NULL, p_schedule_number IN VARCHAR2);

  PROCEDURE get_lot_control_from_org(x_lot_control_code OUT NOCOPY NUMBER, x_from_org_id OUT NOCOPY NUMBER, p_organization_id IN NUMBER, p_shipment_header_id IN NUMBER, p_item_id IN NUMBER);

  --      Name: GET_FORMAT_LOV
  --
  --      Input parameters:
  --      p_label_type_id SELECTED label type.
  --      Functions: This API returns all formats for a specific label type.
  PROCEDURE get_format_lov(x_format_lov OUT NOCOPY t_genref, p_label_type_id IN NUMBER, p_format_name IN VARCHAR2);

  --      Name: GET_USER_PRINTERS_LOV
  --      Added by joabraha
  --      Input parameters:
  --      p_printer_name  partial completion on printer_name
  --      Functions: This API returns all printers
  PROCEDURE get_user_printers_lov(x_printer_lov OUT NOCOPY t_genref, p_printer_name IN VARCHAR2);

  --      Name: GET_ITEM_LOAD_LOT_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_inventory_item_id     - Restricts LOV SQL to current inventory item
  --       p_lpn_id                - Restricts LOV SQL to lot numbers within
  --                                 the given lpn ID
  --       p_lot_number            - Restricts LOV SQL to the user input text
  --
  --      Output parameters:
  --       x_lot_num_lov      - returns LOV rows as reference cursor
  --
  --      Functions: This API returns lot number for a given org and inventory
  --                 item within a particular LPN used for Inbound Item
  --                 Load functionality in patchset J.
    -- Added p_subinventory_code and p_locator_id parameters as part of onhand status support project

  PROCEDURE get_item_load_lot_lov
    (x_lot_num_lov          OUT NOCOPY t_genref     ,
     p_organization_id      IN  NUMBER              ,
     p_item_id              IN  NUMBER              ,
     p_lpn_id               IN  NUMBER              ,
     p_lot_number           IN  VARCHAR2            ,
     p_subinventory_code IN VARCHAR2 DEFAULT NULL   ,
     p_locator_id IN NUMBER DEFAULT NULL
     );


  FUNCTION validate_account_segments(
                                      p_segments VARCHAR2,
                                      p_data_set NUMBER
                                    ) RETURN VARCHAR2;

 --added for lpn status project to handle lot in lpn and loose
  PROCEDURE get_from_onstatus_lot_lov(x_lot_num_lov OUT NOCOPY t_genref,
                                       p_organization_id IN NUMBER,
                                       p_lpn VARCHAR2 ,
                                       p_item_id IN NUMBER,
                                       p_lot_number IN VARCHAR2);

  PROCEDURE get_to_onstatus_lot_lov(x_lot_num_lov OUT NOCOPY t_genref,
                                   p_organization_id IN NUMBER,
                                   p_lpn varchar2,
                                   p_item_id IN NUMBER,
                                   p_from_lot_number IN VARCHAR2,
                                   p_lot_number IN VARCHAR2);



END inv_inv_lovs;

/
