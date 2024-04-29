--------------------------------------------------------
--  DDL for Package INV_UI_ITEM_ATT_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_UI_ITEM_ATT_LOVS" AUTHID CURRENT_USER AS
  /* $Header: INVITATS.pls 120.9 2008/04/14 12:44:31 abaid noship $ */

  TYPE t_genref IS REF CURSOR;

  --      Name: GET_SERIAL_LOV_RCV
  --
  --      Input parameters:
  --       p_Organization_Id    which restricts LOV SQL to current org
  --       p_item_id            which restricts LOV SQL to current item
  --       p_serial             which restricts LOV SQL to the serial entered
  --       p_shipment_header_id which restricts LOV SQL to the shipment being received
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for receiving for PO
  -- This is equivalent to inv_serial4 in the serial entry form INVTTESR

  PROCEDURE get_serial_lov_rcv(
        x_serial_number OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_item_id IN NUMBER,
        p_serial IN VARCHAR2,
        p_transaction_type_id IN NUMBER,
        p_wms_installed IN VARCHAR2);

  --      Name: GET_SERIAL_LOV_RMA_RCV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_serial            which restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for receiving for
  --                 intransit shipments
  -- This is equivalent to inv_serial3 in the serial entry form INVTTESR

  PROCEDURE get_serial_lov_rma_rcv(
        x_serial_number OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_item_id IN NUMBER,
        p_serial IN VARCHAR2,
        p_transaction_type_id IN NUMBER,
        p_wms_installed IN VARCHAR2,
        p_oe_order_header_id IN NUMBER default NULL);

  --      Name: GET_SERIAL_LOV_INT_SHP_RCV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_serial            which restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for receiving for
  --                 intransit shipments
  -- This is equivalent to inv_serial7 in the serial entry form INVTTESR

  PROCEDURE get_serial_lov_int_shp_rcv(
    x_serial_number       OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_shipment_header_id  IN     NUMBER
  , p_lot_num             IN     VARCHAR2
  , p_serial              IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_from_lpn_id         IN     NUMBER DEFAULT NULL
  );

  --      Name: GET_SERIAL_LOV_LMT
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_subinv_code       restricts to Subinventory
  --       p_locator_id        restricts to Locator ID. If not used, set to -1
  --       p_serial            which restricts LOV SQL to the serial entered
  --       p_transaction_type_id  trx_type_id
  --       p_wms_installed     whether WMS-enabled ORG
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers limited by
  --         the specified Subinventory and Locator with status='Received';
  --
  PROCEDURE get_serial_lov_lmt(
    x_serial_number       OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_subinv_code         IN     VARCHAR2
  , p_locator_id          IN     NUMBER
  , p_serial              IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_group_mark_id       IN     NUMBER := NULL
  );

  -- Name: get_lot_info
  --
  -- Input parameters:
  --
  -- Output parameters:
  -- x_expiration_date - Expiration date to use for the lot number given. If
  -- the lot exists in the table, then the expiration date entered for that
  -- lot is returned. If that is null, then the expiration date is calculated
  -- based on the shelf life days and shelf life code and returned.
  -- Similar thing happens if no data is found in the lots table for the
  -- entered lot number
  -- x_is_new_lot - TRUE/FALSE. It is TRUE if no data exists in the
  -- lot_number table for the lots entered and FALSE otherwise
  -- x_is_valid_lot - TRUE/FALSE. It is TRUE if it satisfies the uniqueness
  -- condition, otherwise it returns false here which means that the lot
  -- number entered is not really a valid lot number.
  PROCEDURE get_lot_info(
    p_organization_id       IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_lot_number            IN     VARCHAR2
  , p_shelf_life_code       IN     NUMBER
  , p_shelf_life_days       IN     NUMBER
  , p_lot_status_enabled    IN     VARCHAR2
  , p_default_lot_status_id IN     NUMBER
  , p_wms_installed         IN     VARCHAR2
  , x_expiration_date       OUT    NOCOPY DATE
  , x_is_new_lot            OUT    NOCOPY VARCHAR2
  , x_is_valid_lot          OUT    NOCOPY VARCHAR2
  , x_lot_status            OUT    NOCOPY VARCHAR2
  );

  -- procedure to get the serial info for the lov incase it is a
  -- serial number created dynamically.
  PROCEDURE get_serial_info(
        p_item_id IN NUMBER,
        p_serial IN VARCHAR2,
        p_serial_status_enabled IN VARCHAR2,
        p_default_serial_status IN NUMBER,
        p_wms_installed IN VARCHAR2,
        x_current_status OUT NOCOPY VARCHAR2,
        x_serial_status OUT NOCOPY VARCHAR2);

  --During an issue, if it is the first serial number then
  --we can accept any serial that resides in stores
  --however, after the first serial has been scanned we must
  --make sure that all subsequent serials are from the same
  --locator and same sub.
  --Consignment and VMI Changes - Added Planning Org and TP Type and Owning Org and TP Type.
  PROCEDURE get_valid_serial_issue(
    x_rserials                  OUT    NOCOPY t_genref
  , p_current_organization_id   IN     NUMBER
  , p_revision                  IN     VARCHAR2
  , p_current_subinventory_code IN     VARCHAR2
  , p_current_locator_id        IN     NUMBER
  , p_current_lot_number        IN     VARCHAR2
  , p_inventory_item_id         IN     NUMBER
  , p_serial_number             IN     VARCHAR2
  , p_transaction_type_id       IN     NUMBER
  , p_wms_installed             IN     VARCHAR2
  , p_lpn_id                    IN     NUMBER DEFAULT NULL
  , p_planning_org_id           IN     NUMBER DEFAULT NULL
  , p_planning_tp_type          IN     NUMBER DEFAULT NULL
  , p_owning_org_id             IN     NUMBER DEFAULT NULL
  , p_owning_tp_type            IN     NUMBER DEFAULT NULL
  );

  --      Name: GET_COST_GROUP_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_inventory_item_id which restricts LOV SQL to current item
  --       p_subinventory_code restricts to Subinventory
  --       p_locator_id        restricts to Locator ID. If not used, set to -1
  --       p_cost_group        which restricts LOV SQL to the cost group entered
  --
  --      Output parameters:
  --       x_cost_group        returns LOV rows as reference cursor
  --
  --      Functions: This API is to return cost_group limited by
  --         the specified Subinventory and Locator and cost_group_type = 3;
  --
  PROCEDURE get_cost_group_lov(
        x_cost_group OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_inventory_item_id IN VARCHAR2,
        p_subinventory_code IN VARCHAR2,
        p_locator_id IN VARCHAR2,
        p_cost_group IN VARCHAR2);

  --      Name: GET_PHYINV_SERIAL_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_subinventory_code     - Restricts the LOV SQL to subinventory entered
  --       p_locator_id            - Restricts the LOV SQL to locator ID entered
  --       p_inventory_item_id     - Restricts LOV SQL to current inventory item
  --       p_serial_number         - Restricts LOV SQL to the serial entered
  --       p_lot_number            - Restricts LOV SQL to the lot number entered
  --       p_dynamic_entry_flag    - Indicates if dynamic entries are allowed
  --       p_physical_inventory_id - Restricts LOV SQL to current physical inventory
  --       p_parent_lpn_id         - Restricts LOV SQL to serial numbers
  --                                 stored within the given parent lpn ID
  --
  --      Output parameters:
  --       x_serials           - Returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for physical inventory

  PROCEDURE get_phyinv_serial_lov(
    x_serials               OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_serial_number         IN     VARCHAR2
  , p_lot_number            IN     VARCHAR2
  , p_dynamic_entry_flag    IN     NUMBER
  , p_physical_inventory_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  );

  --      Name: GET_PHYINV_TO_SERIAL_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_subinventory_code     - Restricts the LOV SQL to subinventory entered
  --       p_locator_id            - Restricts the LOV SQL to locator ID entered
  --       p_inventory_item_id     - Restricts LOV SQL to current inventory item
  --       p_to_serial_number      - Restricts LOV SQL to the serial entered
  --       p_lot_number            - Restricts LOV SQL to the lot number entered
  --       p_dynamic_entry_flag    - Indicates if dynamic entries are allowed
  --       p_physical_inventory_id - Restricts LOV SQL to current physical inventory
  --       p_from_serial_number    - The starting serial number so that it
  --                                 restricts the LOV SQL to only serial
  --                                 numbers larger than this value
  --       p_parent_lpn_id         - Restricts LOV SQL to serial numbers
  --                                 stored within the given parent lpn ID
  --
  --      Output parameters:
  --       x_serials           - Returns LOV rows as reference cursor
  --
  --      Functions: This API is to return valid to serial numbers for
  --                 physical inventory

  PROCEDURE get_phyinv_to_serial_lov(
    x_serials               OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_to_serial_number      IN     VARCHAR2
  , p_lot_number            IN     VARCHAR2
  , p_dynamic_entry_flag    IN     NUMBER
  , p_physical_inventory_id IN     NUMBER
  , p_from_serial_number    IN     VARCHAR2
  , p_parent_lpn_id         IN     NUMBER
  );

  --      Name: GET_PHYINV_SERIAL_COUNT_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_subinventory_code     - Restricts the LOV SQL to subinventory entered
  --       p_locator_id            - Restricts the LOV SQL to locator ID entered
  --       p_serial_number         - Restricts LOV SQL to the serial entered
  --       p_dynamic_entry_flag    - Indicates if dynamic entries are allowed
  --       p_physical_inventory_id - Restricts LOV SQL to current physical inventory
  --
  --      Output parameters:
  --       x_serials           - Returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for physical
  --                 inventory when performing serial triggered tag counts
  --                 Note that serials are only allowed to be counted once
  --                 for this particular type of physical tag counting

  PROCEDURE get_phyinv_serial_count_lov(
        x_serials OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_subinventory_code IN VARCHAR2,
        p_locator_id IN NUMBER,
        p_serial_number IN VARCHAR2,
        p_dynamic_entry_flag IN NUMBER,
        p_physical_inventory_id IN NUMBER);

  --      Name: GET_CYC_SERIAL_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_subinventory_code     - Restricts the LOV SQL to subinventory entered
  --       p_locator_id            - Restricts the LOV SQL to locator ID entered
  --       p_inventory_item_id     - Restricts LOV SQL to current inventory item
  --       p_serial_number         - Restricts LOV SQL to the serial entered
  --       p_lot_number            - Restricts LOV SQL to the lot number entered
  --       p_unscheduled_entry     - Indicates if unscheduled entries are allowed
  --       p_cycle_count_header_id - Restricts LOV SQL to current cycle
  --                                 count
  --       p_parent_lpn_id         - Restricts LOV SQL to serial numbers
  --                                 stored within the given parent lpn ID
  --       p_serial_count_option   - Determines which table the serial
  --                                 numbers are stored in
  --
  --      Output parameters:
  --       x_serials           - Returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for cycle count

  PROCEDURE get_cyc_serial_lov(
    x_serials               OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_serial_number         IN     VARCHAR2
  , p_lot_number            IN     VARCHAR2
  , p_unscheduled_entry     IN     NUMBER
  , p_cycle_count_header_id IN     NUMBER
  , p_parent_lpn_id         IN     NUMBER
  , p_serial_count_option   IN     NUMBER
  );

  --      Name: GET_CYC_TO_SERIAL_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_subinventory_code     - Restricts the LOV SQL to subinventory entered
  --       p_locator_id            - Restricts the LOV SQL to locator ID entered
  --       p_inventory_item_id     - Restricts LOV SQL to current inventory item
  --       p_to_serial_number      - Restricts LOV SQL to the serial entered
  --       p_lot_number            - Restricts LOV SQL to the lot number entered
  --       p_unscheduled_entry     - Indicates if unscheduled entries are allowed
  --       p_cycle_count_header_id - Restricts LOV SQL to current cycle count
  --       p_from_serial_number    - The starting serial number so that it
  --                                 restricts the LOV SQL to only serial
  --                                 numbers larger than this value
  --       p_parent_lpn_id         - Restricts LOV SQL to serial numbers
  --                                 stored within the given parent lpn ID
  --       p_serial_count_option   - Determines which table the serial
  --                                 numbers are stored in
  --
  --      Output parameters:
  --       x_serials           - Returns LOV rows as reference cursor
  --
  --      Functions: This API is to return valid to serial numbers for
  --                 cycle count

  PROCEDURE get_cyc_to_serial_lov(
    x_serials               OUT    NOCOPY t_genref
  , p_organization_id       IN     NUMBER
  , p_subinventory_code     IN     VARCHAR2
  , p_locator_id            IN     NUMBER
  , p_inventory_item_id     IN     NUMBER
  , p_to_serial_number      IN     VARCHAR2
  , p_lot_number            IN     VARCHAR2
  , p_unscheduled_entry     IN     NUMBER
  , p_cycle_count_header_id IN     NUMBER
  , p_from_serial_number    IN     VARCHAR2
  , p_parent_lpn_id         IN     NUMBER
  , p_serial_count_option   IN     NUMBER
  );

  --      Name: GET_CYC_SERIAL_COUNT_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_subinventory_code     - Restricts the LOV SQL to subinventory entered
  --       p_locator_id            - Restricts the LOV SQL to locator ID entered
  --       p_serial_number         - Restricts LOV SQL to the serial entered
  --       p_unscheduled_entry     - Indicates if unscheduled entries are allowed
  --       p_cycle_count_header_id - Restricts LOV SQL to current cycle count
  --
  --      Output parameters:
  --       x_serials           - Returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for cycle
  --                 counting when performing serial triggered cycle counts
  --                 Note that serial triggered cycle counts are only allowed
  --                 for cycle count headers which have a serial count option
  --                 = 2 which is single serial.  This is enforced in the
  --                 java mobile serial cycle counting page

  PROCEDURE get_cyc_serial_count_lov(
        x_serials OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_subinventory_code IN VARCHAR2,
        p_locator_id IN NUMBER,
        p_serial_number IN VARCHAR2,
        p_unscheduled_entry IN NUMBER,
        p_cycle_count_header_id IN NUMBER);

  --      Name: GET_SERIAL_LOV_STATUS
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_inventory_item_id     - Restricts LOV SQL to current inventory item
  --       p_serial_number      - Restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serialsLOV           - Returns LOV rows as reference cursor
  --
  --      Functions: This API is to return valid to serial numbers for
  --                 update status of from_serial_number

  PROCEDURE get_serial_lov_status(
        x_seriallov OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_inventory_item_id IN NUMBER,
        p_from_lot_number IN VARCHAR2,
        p_to_lot_number IN VARCHAR2,
        p_serial_number IN VARCHAR2);

  --      Name: GET_TO_STATUS_SERIAL_LOV
  --
  --      Input parameters:
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_inventory_item_id     - Restricts LOV SQL to current inventory item
  --       p_from_serial_number    - Starting point of serial number
  --       p_serial_number      - Restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serialsLOV           - Returns LOV rows as reference cursor
  --
  --      Functions: This API is to return valid to serial numbers for
  --                 update to serial number

  PROCEDURE get_to_status_serial_lov(
        x_seriallov OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_inventory_item_id IN NUMBER,
        p_from_lot_number IN VARCHAR2,
        p_to_lot_number IN VARCHAR2,
        p_from_serial_number IN VARCHAR2, p_serial_number IN VARCHAR2);

  --      Name: GET_SERIAL_LOV_LPN
  --
  --      Input parameters:
  --       p_LPN_Id    which restricts LOV SQL to current LPN
  --       p_org_id    organization_id
  --       p_item_id            which restricts LOV SQL to current item
  --       p_lot             which restricts LOV SQL to the lot
  --       p_shipment_header_id which restricts LOV SQL to the shipment being received
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for a given LPN

  PROCEDURE get_serial_lov_lpn(
        x_serial_number OUT NOCOPY t_genref,
        p_lpn_id IN NUMBER,
        p_organization_id IN NUMBER,
        p_item_id IN NUMBER := NULL,
        p_lot IN VARCHAR2 := NULL,
        p_serial IN VARCHAR2);

  --      Name: GET_SERIAL_INSPECT_LOV_RCV
  --
  --      Input parameters:
  --       p_Organization_Id    which restricts LOV SQL to current org
  --       p_item_id            which restricts LOV SQL to current item
  --       p_lpn_id             which restricts serial numbers to LPN that is being inspected
  --       p_serial             which restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for mobile inspection
  --
  PROCEDURE get_serial_inspect_lov_rcv(
        x_serial_number OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_item_id IN NUMBER,
        p_lpn_id IN NUMBER,
 p_serial IN VARCHAR2,
 p_lot_number IN VARCHAR2 DEFAULT NULL );

  --      Name: GET_SERIAL_LOV_SO
  --
  --      Input parameters:
  --       p_Organization_Id    which restricts LOV SQL to current org
  --       p_inventory_item_id  which restricts LOV SQL to current item
  --       p_subinventory_code  which restricts LOV SQL to current sub
  --       p_locator_id         which restricts LOV SQL to current locator
  --       p_revision           which restricts LOV SQL to current revision
  --       p_lot_number         which restricts LOV SQL to current lot
  --       p_serial_number      which restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for mobile inspection
  --
  PROCEDURE get_serial_lov_so(
    x_serial            OUT    NOCOPY t_genref
  , p_delivery_id       IN     NUMBER
  , p_inventory_item_id IN     NUMBER
  , p_organization_id   IN     NUMBER
  , p_subinventory_code IN     VARCHAR2
  , p_locator_id        IN     NUMBER
  , p_revision          IN     VARCHAR2
  , p_lot_number        IN     VARCHAR2
  , p_serial_number     IN     VARCHAR2
  );

  --      Name: GET_CONT_SERIAL_LOV
  --
  --      Input parameters:
  --      p_Organization_Id     which restricts LOV SQL to current org
  --      p_item_id     which restricts LOV SQL to current item
  --  p_lpn_id    which restricts LOV SQL to current lpn
  --      p_serial_number       which restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --      x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for mobile inspection

  PROCEDURE Get_Cont_Serial_Lov(
        x_serial_number OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_item_id IN NUMBER,
        p_lpn_id IN NUMBER,
        p_revision IN VARCHAR2,
        p_lot_number IN VARCHAR2,
        p_serial IN VARCHAR2);

  PROCEDURE Get_Split_Cont_Serial_Lov(
        x_serial_number OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_item_id IN NUMBER,
        p_lpn_id IN NUMBER,
        p_revision IN VARCHAR2,
        p_lot_number IN VARCHAR2,
        p_transaction_subtype IN NUMBER,
        p_serial IN VARCHAR2);


  PROCEDURE get_pupcont_serial_lov(
    x_serial_number   OUT    NOCOPY t_genref
  , p_organization_id IN     NUMBER
  , p_item_id         IN     NUMBER
  , p_lpn_id          IN     NUMBER
  , p_revision        IN     VARCHAR2
  , p_lot_number      IN     VARCHAR2
  , p_serial          IN     VARCHAR2
  , p_txn_type_id     IN     NUMBER := 0
  , p_wms_installed   IN     VARCHAR2 := 'TRUE'
  );

  --      Name: GET_INV_SERIAL_LOV
  --
  --      Input parameters:
  --       p_Organization_Id    which restricts LOV SQL to current org
  --       p_inventory_item_id  which restricts LOV SQL to current item
  --       p_subinventory_code  which restricts LOV SQL to current sub
  --       p_locator_id         which restricts LOV SQL to current locator
  --       p_revision           which restricts LOV SQL to current revision
  --       p_lot_number         which restricts LOV SQL to current lot
  --       p_serial_number      which restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers for mobile inspection
  --
  PROCEDURE get_inv_serial_lov(
        x_serial OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_inventory_item_id IN NUMBER,
        p_subinventory_code IN VARCHAR2,
        p_locator_id IN VARCHAR2,
        p_revision IN VARCHAR2,
        p_lot_number IN VARCHAR2,
        p_serial_number IN VARCHAR2);

  PROCEDURE get_inv_serial_lov_bulk(
    x_serial             OUT    NOCOPY t_genref
  , p_organization_id    IN     NUMBER
  , p_inventory_item_id  IN     NUMBER
  , p_subinventory_code  IN     VARCHAR2
  , p_locator_id         IN     VARCHAR2
  , p_revision           IN     VARCHAR2
  , p_lot_number         IN     VARCHAR2
  , p_from_serial_number IN     VARCHAR2
  , p_serial_number      IN     VARCHAR2
  );

  PROCEDURE get_pack_serial_lov(
    x_serial            OUT    NOCOPY t_genref
  , p_organization_id   IN     NUMBER
  , p_inventory_item_id IN     NUMBER
  , p_subinventory_code IN     VARCHAR2
  , p_locator_id        IN     VARCHAR2
  , p_revision          IN     VARCHAR2
  , p_lot_number        IN     VARCHAR2
  , p_serial_number     IN     VARCHAR2
  );

  --      Name: GET_CGUPDATE_SERIAL_LOV
  PROCEDURE get_cgupdate_serial_lov(
    x_serial            OUT    NOCOPY t_genref
  , p_organization_id   IN     NUMBER
  , p_inventory_item_id IN     NUMBER
  , p_lpn_id            IN     NUMBER
  , p_serial_number     IN     VARCHAR2
  , p_subinventory_code IN     VARCHAR2
  , p_locator_id        IN     NUMBER
  , p_revision          IN     VARCHAR2
  , p_cost_group_id     IN     NUMBER
  );

  -- added by manu gupta, copied from file from karun jain
  PROCEDURE get_lot_expiration_date(
        p_organization_id IN NUMBER,
        p_inventory_item_id IN NUMBER,
        p_lot_number IN VARCHAR2,
        p_shelf_life_code IN NUMBER,
        p_shelf_life_days IN NUMBER,
        x_expiration_date OUT NOCOPY DATE);

  PROCEDURE get_serial_lov_picking (
    x_serial_number       OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_subinv_code         IN     VARCHAR2
  , p_locator_id          IN     NUMBER
  , p_serial              IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_lpn_id              IN     NUMBER := NULL
  , p_lot_number          IN     VARCHAR2
  );


  --      Name: GET_SERIAL_LOV_ALLOC_PICKING
  --
  --      Input parameters:
  --       p_transaction_temp_id the transaction temp id from the
  --                                mtl_material_transactions_temp table
  --        p_lot_code if '1' means not lot controlled
  --                   if '2' means IS lot controlled
  --                     the caller function would have to ensure that
  --                      these are the only numbers used.
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers allocated at receipt
  --
  --

  PROCEDURE get_serial_lov_alloc_picking(
    x_serial_number       OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_subinv_code         IN     VARCHAR2
  , p_locator_id          IN     NUMBER
  , p_serial              IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_lpn_id              IN     NUMBER
  , p_transaction_temp_id IN     NUMBER
  , p_lot_code            IN     NUMBER
  , p_lot_number          IN     VARCHAR2
  );

  PROCEDURE get_serial_lov_apl_picking(
        x_serial_number       OUT    NOCOPY t_genref
      , p_organization_id     IN     NUMBER
      , p_item_id             IN     NUMBER
      , p_subinv_code         IN     VARCHAR2
      , p_locator_id          IN     NUMBER
      , p_serial              IN     VARCHAR2
      , p_transaction_type_id IN     NUMBER
      , p_lpn_id              IN     NUMBER := NULL
      , p_lot_number          IN     VARCHAR2
      , p_revision            IN     VARCHAR2
  );

  PROCEDURE get_serial_lov_apl_alloc_pick(
        x_serial_number       OUT    NOCOPY t_genref
      , p_organization_id     IN     NUMBER
      , p_item_id             IN     NUMBER
      , p_subinv_code         IN     VARCHAR2
      , p_locator_id          IN     NUMBER
      , p_serial              IN     VARCHAR2
      , p_transaction_type_id IN     NUMBER
      , p_lpn_id              IN     NUMBER
      , p_transaction_temp_id IN     NUMBER
      , p_lot_code            IN     NUMBER
      , p_lot_number          IN     VARCHAR2
      , p_revision            IN     VARCHAR2
  );


  --      Name: GET_ALL_SERIAL_LOV
  --
  --      Input parameters:
  --       p_Organization_Id    which restricts LOV SQL to current org
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return all serial numbers only by org
  --
  --
  PROCEDURE get_all_serial_lov(
        x_serial OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_serial IN VARCHAR2);

  PROCEDURE get_all_to_serial_lov(
        x_serial OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_from_serial_number IN VARCHAR2,
        p_inventory_item_id IN NUMBER,
        p_serial IN VARCHAR2);

  --"Returns"
  --      Name: GET_RETURN_SERIAL_LOV
  --
  --      Input parameters:
  --       p_org_id    which restricts LOV SQL to input org
  --       p_lpn_id    which restricts LOV SQL to input LPNID
  --       p_item_id   which restricts LOV SQL to input ITEMID
  --       p_revision  which restricts LOV SQL to input REVISION
  --       p_serial    which restricts LOV SQL to input Serial
  --       p_upd_group_id which updates the group mark id of serial so that
  --      the same serial is not selected again in any
  --      other transaction
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return all serial numbers
  --                  that are marked as 'To Return' for the Item and LPN
  --
  --
  PROCEDURE get_return_serial_lov(
        x_serial OUT NOCOPY t_genref,
        p_org_id IN NUMBER,
        p_lpn_id IN NUMBER,
        p_item_id IN NUMBER,
        p_revision IN VARCHAR2,
        p_serial IN VARCHAR2,
        p_upd_group_id IN NUMBER DEFAULT 0);

  --"Returns"



  --      Name: GET_TASK_SERIAL_LOV
  --
  --      Input parameters:
  --       p_temp_Id   transaction_temp_id in mtl_material_transactions_temp
  --       p_lot_code  1 if lolt controlled 0 if only serial controlled
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --     Functions: This API is to return serial numbers allocated
  --     for a given task

  PROCEDURE get_task_serial_lov(
        x_serial_number OUT NOCOPY t_genref,
        p_temp_id IN NUMBER,
        p_lot_code IN NUMBER DEFAULT 0);

  -- LOV query for serial triggered subinventory transfer
  PROCEDURE get_serial_subxfr_lov(
        x_serials OUT NOCOPY t_genref,
        p_current_organization_id IN NUMBER,
        p_serial_number IN VARCHAR2,
        p_transaction_type_id IN NUMBER,
        p_wms_installed IN VARCHAR2);

  --      Name: GET_SERIAL_LOV_MO
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_serial            which restricts LOV SQL to the serial entered
  --       p_transaction_type_id  trx_type_id
  --       p_wms_installed     whether WMS-enabled ORG
  --       p_move_order_line_id which include the serials allocated to the
  --                            move order line
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers limited by
  --         the specified move order line and all other avialable serial
  --         numbers and status='Received';
  --
  PROCEDURE get_serial_lov_mo(
        x_serial_number OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_item_id IN NUMBER,
        p_serial IN VARCHAR2,
        p_transaction_type_id IN NUMBER,
        p_wms_installed IN VARCHAR2,
        p_move_order_line_id IN NUMBER := NULL);

  --      Name: GET_SERIAL_LOV_WMA_NEGISS
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_serial            which restricts LOV SQL to the serial entered
  --       p_transaction_type_id  trx_type_id
  --       p_wms_installed     whether WMS-enabled ORG
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers limited to
  --         status of 'DEFINED NOT USED' and 'ISSUED OUT OF STORES' (to WIP).
  --         Used by WMA negative issue.
  --
  PROCEDURE get_serial_lov_wma_negiss(
        x_serial_number OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_item_id IN NUMBER,
        p_serial IN VARCHAR2,
        p_lot_number IN VARCHAR2 DEFAULT NULL,
        p_transaction_type_id IN NUMBER,
        p_wms_installed IN VARCHAR2);

  --      Name: GET_SERIAL_LOV_WMA_ISS
    --
    --      Input parameters:
    --       p_Organization_Id   which restricts LOV SQL to current org
    --       p_item_id           which restricts LOV SQL to current item
    --       p_serial            which restricts LOV SQL to the serial entered
    --       p_transaction_type_id  trx_type_id
    --       p_wms_installed     whether WMS-enabled ORG
    --       p_subinv            which restricts LOV SQL to the chosen subinventory
    --       p_locator           which restricts LOV SQL to the chosen locator
    --       p_revision            which restricts LOV SQL to the chosen revision
    --       p_lot               which restricts LOV SQL to the current lot
    --
    --      Output parameters:
    --       x_serial_number      returns LOV rows as reference cursor
    --
    --      Functions: This API is to return serial numbers limited to
    --         a specific lot and status of 'RESIDES IN STORES'.  Used by WMA
    --         transaction that issue out of inventory.
    --
  PROCEDURE get_serial_lov_wma_iss(
    x_serial_number       OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_serial              IN     VARCHAR2
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_subinv              IN     VARCHAR2
  , p_locator_id          IN     NUMBER
  , p_revision            IN     VARCHAR2
  , p_lot                 IN     VARCHAR2
  );

  --      Name: GET_SERIAL_LOV_WMA_RCV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_serial            which restricts LOV SQL to the serial entered
  --       p_transaction_type_id  trx_type_id
  --       p_wms_installed     whether WMS-enabled ORG
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers limited to
  --         status of 'DEFINED NOT USED'.  Used by WMA completion and negative
  --         issue transactions.
  --
  PROCEDURE get_serial_lov_wma_rcv(
    x_serial_number       OUT    NOCOPY t_genref
  , p_organization_id     IN     NUMBER
  , p_item_id             IN     NUMBER
  , p_serial              IN     VARCHAR2
  , p_lot_number          IN     VARCHAR2 DEFAULT NULL
  , p_transaction_type_id IN     NUMBER
  , p_wms_installed       IN     VARCHAR2
  , p_wip_entity_id       IN     NUMBER
  );

  --      Name: GET_SERIAL_LOV_WMA_RETCOMP
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_item_id           which restricts LOV SQL to current item
  --       p_serial            which restricts LOV SQL to the serial entered
  --       p_transaction_type_id  trx_type_id
  --       p_wms_installed     whether WMS-enabled ORG
  --
  --      Output parameters:
  --       x_serial_number      returns LOV rows as reference cursor
  --
  --      Functions: This API is to return serial numbers limited to
  --         status of 'ISSUED OUT OF STORES".  Use by WMA return transactions.
  --
  PROCEDURE get_serial_lov_wma_retcomp(
        x_serial_number OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_item_id IN NUMBER,
        p_serial IN VARCHAR2,
        p_transaction_type_id IN NUMBER,
        p_wms_installed IN VARCHAR2,
        p_wip_entity_id IN NUMBER,
        p_lot IN VARCHAR2);

  --this overloaded version of the component return lov accepts the
  --item revision as well. The above version is left alone for
  --backward compatibility and should not be used for future coding.
  PROCEDURE get_serial_lov_wma_retcomp(
        x_serial_number OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_item_id IN NUMBER,
        p_serial IN VARCHAR2,
        p_transaction_type_id IN NUMBER,
        p_wms_installed IN VARCHAR2,
        p_wip_entity_id IN NUMBER,
        p_lot IN VARCHAR2,
        p_revision IN VARCHAR2);

  PROCEDURE get_parent_serial_lov_wma(
        x_serial_number         OUT NOCOPY t_genref,
        p_organization_id       IN  NUMBER,
        p_item_id               IN  NUMBER,
        p_serial                IN  VARCHAR2,
        p_transaction_type_id   IN  NUMBER,
        p_transaction_action_id IN  NUMBER,
        p_wip_entity_id         IN  NUMBER,
        p_wip_assembly_id IN  NUMBER := NULL,
        p_wms_installed         IN VARCHAR2);

  PROCEDURE get_lot_flex_info(
    p_org_id                 IN     NUMBER
  , p_lot_number             IN     VARCHAR2
  , p_inventory_item_id      IN     NUMBER
  , x_vendor_id              OUT    NOCOPY NUMBER
  , x_grade_code             OUT    NOCOPY VARCHAR2
  , x_origination_date       OUT    NOCOPY VARCHAR2
  , x_date_code              OUT    NOCOPY VARCHAR2
  , x_status_id              OUT    NOCOPY NUMBER
  , x_change_date            OUT    NOCOPY VARCHAR2
  , x_age                    OUT    NOCOPY NUMBER
  , x_retest_date            OUT    NOCOPY VARCHAR2
  , x_maturity_date          OUT    NOCOPY VARCHAR2
  , x_lot_attribute_category OUT    NOCOPY VARCHAR2
  , x_item_size              OUT    NOCOPY NUMBER
  , x_color                  OUT    NOCOPY VARCHAR2
  , x_volume                 OUT    NOCOPY NUMBER
  , x_volume_uom             OUT    NOCOPY VARCHAR2
  , x_place_of_origin        OUT    NOCOPY VARCHAR2
  , x_best_by_date           OUT    NOCOPY VARCHAR2
  , x_length                 OUT    NOCOPY NUMBER
  , x_length_uom             OUT    NOCOPY VARCHAR2
  , x_recycled_content       OUT    NOCOPY NUMBER
  , x_thickness              OUT    NOCOPY NUMBER
  , x_thickness_uom          OUT    NOCOPY VARCHAR2
  , x_width                  OUT    NOCOPY NUMBER
  , x_width_uom              OUT    NOCOPY VARCHAR2
  , x_curl_wrinkle_fold      OUT    NOCOPY VARCHAR2
  , x_c_attribute1           OUT    NOCOPY VARCHAR2
  , x_c_attribute2           OUT    NOCOPY VARCHAR2
  , x_c_attribute3           OUT    NOCOPY VARCHAR2
  , x_c_attribute4           OUT    NOCOPY VARCHAR2
  , x_c_attribute5           OUT    NOCOPY VARCHAR2
  , x_c_attribute6           OUT    NOCOPY VARCHAR2
  , x_c_attribute7           OUT    NOCOPY VARCHAR2
  , x_c_attribute8           OUT    NOCOPY VARCHAR2
  , x_c_attribute9           OUT    NOCOPY VARCHAR2
  , x_c_attribute10          OUT    NOCOPY VARCHAR2
  , x_c_attribute11          OUT    NOCOPY VARCHAR2
  , x_c_attribute12          OUT    NOCOPY VARCHAR2
  , x_c_attribute13          OUT    NOCOPY VARCHAR2
  , x_c_attribute14          OUT    NOCOPY VARCHAR2
  , x_c_attribute15          OUT    NOCOPY VARCHAR2
  , x_c_attribute16          OUT    NOCOPY VARCHAR2
  , x_c_attribute17          OUT    NOCOPY VARCHAR2
  , x_c_attribute18          OUT    NOCOPY VARCHAR2
  , x_c_attribute19          OUT    NOCOPY VARCHAR2
  , x_c_attribute20          OUT    NOCOPY VARCHAR2
  , x_d_attribute1           OUT    NOCOPY VARCHAR2
  , x_d_attribute2           OUT    NOCOPY VARCHAR2
  , x_d_attribute3           OUT    NOCOPY VARCHAR2
  , x_d_attribute4           OUT    NOCOPY VARCHAR2
  , x_d_attribute5           OUT    NOCOPY VARCHAR2
  , x_d_attribute6           OUT    NOCOPY VARCHAR2
  , x_d_attribute7           OUT    NOCOPY VARCHAR2
  , x_d_attribute8           OUT    NOCOPY VARCHAR2
  , x_d_attribute9           OUT    NOCOPY VARCHAR2
  , x_d_attribute10          OUT    NOCOPY VARCHAR2
  , x_n_attribute1           OUT    NOCOPY NUMBER
  , x_n_attribute2           OUT    NOCOPY NUMBER
  , x_n_attribute3           OUT    NOCOPY NUMBER
  , x_n_attribute4           OUT    NOCOPY NUMBER
  , x_n_attribute5           OUT    NOCOPY NUMBER
  , x_n_attribute6           OUT    NOCOPY NUMBER
  , x_n_attribute7           OUT    NOCOPY NUMBER
  , x_n_attribute8           OUT    NOCOPY NUMBER
  , x_n_attribute9           OUT    NOCOPY NUMBER
  , x_n_attribute10          OUT    NOCOPY NUMBER
  , x_supplier_lot_number    OUT    NOCOPY VARCHAR2
  , x_territory_code         OUT    NOCOPY VARCHAR2
  , x_vendor_name            OUT    NOCOPY VARCHAR2
  , x_description            OUT    NOCOPY VARCHAR2
  );

  -- Bug# 4176656
  -- New Procedure to get the Flexfield Data for a given Serial Number
  --
  --
  PROCEDURE get_serial_flex_info(
    p_serial_number            IN     VARCHAR2
  , p_inventory_item_id      IN     NUMBER
  , x_attribute_category     OUT    NOCOPY VARCHAR2
  , x_attribute1             OUT    NOCOPY VARCHAR2
  , x_attribute2             OUT    NOCOPY VARCHAR2
  , x_attribute3             OUT    NOCOPY VARCHAR2
  , x_attribute4             OUT    NOCOPY VARCHAR2
  , x_attribute5             OUT    NOCOPY VARCHAR2
  , x_attribute6             OUT    NOCOPY VARCHAR2
  , x_attribute7             OUT    NOCOPY VARCHAR2
  , x_attribute8             OUT    NOCOPY VARCHAR2
  , x_attribute9             OUT    NOCOPY VARCHAR2
  , x_attribute10            OUT    NOCOPY VARCHAR2
  , x_attribute11            OUT    NOCOPY VARCHAR2
  , x_attribute12            OUT    NOCOPY VARCHAR2
  , x_attribute13            OUT    NOCOPY VARCHAR2
  , x_attribute14            OUT    NOCOPY VARCHAR2
  , x_attribute15            OUT    NOCOPY VARCHAR2
  , x_group_mark_id          OUT    NOCOPY NUMBER
  , x_serial_attribute_category OUT NOCOPY VARCHAR2
  , x_c_attribute1           OUT    NOCOPY VARCHAR2
  , x_c_attribute2           OUT    NOCOPY VARCHAR2
  , x_c_attribute3           OUT    NOCOPY VARCHAR2
  , x_c_attribute4           OUT    NOCOPY VARCHAR2
  , x_c_attribute5           OUT    NOCOPY VARCHAR2
  , x_c_attribute6           OUT    NOCOPY VARCHAR2
  , x_c_attribute7           OUT    NOCOPY VARCHAR2
  , x_c_attribute8           OUT    NOCOPY VARCHAR2
  , x_c_attribute9           OUT    NOCOPY VARCHAR2
  , x_c_attribute10          OUT    NOCOPY VARCHAR2
  , x_c_attribute11          OUT    NOCOPY VARCHAR2
  , x_c_attribute12          OUT    NOCOPY VARCHAR2
  , x_c_attribute13          OUT    NOCOPY VARCHAR2
  , x_c_attribute14          OUT    NOCOPY VARCHAR2
  , x_c_attribute15          OUT    NOCOPY VARCHAR2
  , x_c_attribute16          OUT    NOCOPY VARCHAR2
  , x_c_attribute17          OUT    NOCOPY VARCHAR2
  , x_c_attribute18          OUT    NOCOPY VARCHAR2
  , x_c_attribute19          OUT    NOCOPY VARCHAR2
  , x_c_attribute20          OUT    NOCOPY VARCHAR2
  , x_d_attribute1           OUT    NOCOPY VARCHAR2
  , x_d_attribute2           OUT    NOCOPY VARCHAR2
  , x_d_attribute3           OUT    NOCOPY VARCHAR2
  , x_d_attribute4           OUT    NOCOPY VARCHAR2
  , x_d_attribute5           OUT    NOCOPY VARCHAR2
  , x_d_attribute6           OUT    NOCOPY VARCHAR2
  , x_d_attribute7           OUT    NOCOPY VARCHAR2
  , x_d_attribute8           OUT    NOCOPY VARCHAR2
  , x_d_attribute9           OUT    NOCOPY VARCHAR2
  , x_d_attribute10          OUT    NOCOPY VARCHAR2
  , x_n_attribute1           OUT    NOCOPY NUMBER
  , x_n_attribute2           OUT    NOCOPY NUMBER
  , x_n_attribute3           OUT    NOCOPY NUMBER
  , x_n_attribute4           OUT    NOCOPY NUMBER
  , x_n_attribute5           OUT    NOCOPY NUMBER
  , x_n_attribute6           OUT    NOCOPY NUMBER
  , x_n_attribute7           OUT    NOCOPY NUMBER
  , x_n_attribute8           OUT    NOCOPY NUMBER
  , x_n_attribute9           OUT    NOCOPY NUMBER
  , x_n_attribute10          OUT    NOCOPY NUMBER
);

  --      Name: GET_ITEM_LOAD_SERIAL_LOV
  --
  --      Input parameters:
  --       p_lpn_id                - Restricts LOV SQL to serial numbers
  --                                 stored within the given lpn ID
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_item_id               - Restricts LOV SQL to current inventory item
  --       p_lot_number            - Restricts LOV SQL to the lot number entered
  --       p_serial_number         - Restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serial_number         - Returns LOV rows as reference cursor
  --
  --      Functions: This API will return serial numbers for Inbound Item Load
  --                 functionality introduced in patchset J.  This will
  --                 return valid serials for a given item, org, and lot
  --                 within an LPN.
  PROCEDURE get_item_load_serial_lov
    (x_serial_number        OUT NOCOPY t_genref     ,
     p_lpn_id               IN  NUMBER              ,
     p_organization_id      IN  NUMBER              ,
     p_item_id              IN  NUMBER              ,
     p_lot_number           IN  VARCHAR2 := NULL    ,
     p_serial_number        IN  VARCHAR2);


  --      Name: GET_SERIAL_LOAD_SERIAL_LOV
  --
  --      Input parameters:
  --       p_lpn_id                - Restricts LOV SQL to serial numbers
  --                                 stored within the given lpn ID
  --       p_organization_id       - Restricts LOV SQL to current org
  --       p_item_id               - Restricts LOV SQL to current inventory item
  --       p_serial_number         - Restricts LOV SQL to the serial entered
  --
  --      Output parameters:
  --       x_serial_number         - Returns LOV rows as reference cursor
  --
  --      Functions: This API will return serial numbers for Inbound Item Load
  --                 functionality for the serially counted flow introduced
  --                 in patchset J.  This will return valid serials for a
  --                 given item and org within an LPN.
  PROCEDURE get_serial_load_serial_lov
    (x_serial_number        OUT NOCOPY t_genref     ,
     p_lpn_id               IN  NUMBER              ,
     p_organization_id      IN  NUMBER              ,
     p_item_id              IN  NUMBER              ,
     p_serial_number        IN  VARCHAR2);

  /**
    *   This procedure fetches the Serial Numbers for an item
    *   inside a LPN that "Resides in Receiving". It uses the
    *   serial number in RCV_SERIALS_SUPPLY that corresponds to the
    *   parent transaction.
    *   This LOV would be called from the Item-based Putaway Drop
    *   mobile page when the user confirms a quantity lesser than
    *   the suggested quantity.
    *  @param  x_serial_number      REF cursor containing the serial numbers fetched
    *  @param  p_lpn_id             Identifer for the LPN containing the serials
    *  @param  p_organization_id    Current Organization
    *  @param  p_inventory_item_id  Inventory Item
    *  @param  p_lot_number         Lot Number
    *  @param  p_txn_header_id      Transaction Header ID. This would be used to match
    *                               with rcv_serials_supply
    *  @param  p_serial             Serial Number entered on the UI
  **/
  PROCEDURE  get_rcv_lpn_serial_lov(
      x_serial_number     OUT NOCOPY  t_genref
  , p_lpn_id            IN          NUMBER
  , p_organization_id   IN          NUMBER
  , p_inventory_item_id IN          NUMBER
  , p_lot_number        IN          VARCHAR2 DEFAULT NULL
  , p_txn_header_id     IN          NUMBER
  , p_serial            IN          VARCHAR2);


/* Bug 4574714 -Added the procedure to call insert into temp table */

   PROCEDURE insert_temp_table_for_serials(
    p_organization_id IN NUMBER,
    p_item_id IN NUMBER,
    p_wms_installed IN VARCHAR2,
    p_oe_order_header_id IN NUMBER,
    x_returnSerialVal OUT NOCOPY VARCHAR2,
    x_return_status OUT  NOCOPY VARCHAR2,
    x_errorcode     OUT  NOCOPY NUMBER );

/* Bug 4574714 -Added the procedure for the lov query */

    PROCEDURE get_serial_lov_rma_restrict(
    x_serial_number OUT NOCOPY t_genref,
    p_organization_id IN NUMBER,
    p_item_id IN NUMBER,
    p_serial IN VARCHAR2,
    p_transaction_type_id IN NUMBER,
    p_wms_installed IN VARCHAR2,
    p_oe_order_header_id IN NUMBER,
    p_restrict IN VARCHAR2) ;

/* End of fix for Bug 4574714 */

/* Bug 5577789 (FP of bug 5520678)-Added the procedure to call insert into temp table for deliver */

   PROCEDURE insert_RMA_serials_for_deliver(
    p_organization_id IN NUMBER,
    p_item_id IN NUMBER,
    p_wms_installed IN VARCHAR2,
    p_oe_order_header_id IN NUMBER,
    x_returnSerialVal OUT NOCOPY VARCHAR2,
    x_return_status OUT  NOCOPY VARCHAR2,
    x_errorcode     OUT  NOCOPY NUMBER );

/* End of change for bug 5577789 (FP of bug 5520678) */


/* Bug 4703782 (FP of BUG 4639427) - Added the procedure for the serial
   lov query for ASN receipts. */

 PROCEDURE get_serial_lov_asn_rcv
 (x_serial_number OUT NOCOPY t_genref,
  p_organization_id IN NUMBER,
  p_item_id IN NUMBER,
  p_shipment_header_id  IN     NUMBER,
  p_serial IN VARCHAR2,
  p_transaction_type_id IN NUMBER,
  p_wms_installed IN VARCHAR2,
  p_from_lpn_id         IN     NUMBER DEFAULT NULL);

/* End of fix for Bug 4703782 */
--bug 6928897
PROCEDURE get_to_ostatus_serial_lov(
    x_seriallov OUT NOCOPY t_genref
  , p_organization_id IN NUMBER
  , p_inventory_item_id IN NUMBER
  , p_from_lot_number IN VARCHAR2
  , p_to_lot_number IN VARCHAR2
  , p_from_serial_number IN VARCHAR2
  , p_serial_number IN VARCHAR2
  );

   PROCEDURE get_serial_lov_ostatus
             (x_seriallov OUT NOCOPY t_genref,
             p_organization_id IN NUMBER,
             p_inventory_item_id IN NUMBER,
             p_from_lot_number IN VARCHAR2,
             p_to_lot_number IN VARCHAR2,
             p_serial_number IN VARCHAR2
             );
  --end of fix for bug 6928897

--bug 6952533
   PROCEDURE GET_TO_LPN_SERIAL_LOV_OSTATUS(x_seriallov OUT NOCOPY t_genref
                                           , p_organization_id IN NUMBER
                                           , p_inventory_item_id IN NUMBER
                                           ,p_lpn_id NUMBER
                                           , p_lot_number IN VARCHAR2
                                           , p_from_serial_number IN VARCHAR2
                                           , p_serial_number IN VARCHAR2);

   PROCEDURE GET_LPN_STATUS_SERIAL_LOV(x_seriallov OUT NOCOPY t_genref,
                                      p_organization_id IN NUMBER,
                                      p_inventory_item_id IN NUMBER,
                                      p_lpn_id IN NUMBER,
                                      p_lot_number IN VARCHAR2,
                                      p_serial_number IN VARCHAR2);
 --bug 6952533

END inv_ui_item_att_lovs;

/
