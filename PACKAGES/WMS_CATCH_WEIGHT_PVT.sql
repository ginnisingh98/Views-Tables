--------------------------------------------------------
--  DDL for Package WMS_CATCH_WEIGHT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CATCH_WEIGHT_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVCWTS.pls 120.0.12010000.1 2008/07/28 18:37:47 appldev ship $ */

-- Constants for MTL_SYSTEM_ITEMS_B.TRACKING_QUANTITY_IND
-- Possible values are P/PS (primary/primary and secondary)
G_TRACK_PRIMARY           CONSTANT VARCHAR(30) := 'P';
G_TRACK_PRIMARY_SECONDARY CONSTANT VARCHAR(30) := 'PS';

-- Constants for MTL_SYSTEM_ITEMS_B.ONT_PRICING_QTY_SOURCE
-- Possible values are P/S (primary/secondary)
G_PRICE_PRIMARY           CONSTANT VARCHAR(30) := 'P';
G_PRICE_SECONDARY         CONSTANT VARCHAR(30) := 'S';

-- Constants for MTL_SYSTEM_ITEMS_B.SECONDARY_DEFAULT_IND
-- Possible values are F/D/N (Fixed/Default/No default)
G_SECONDARY_FIXED         CONSTANT VARCHAR(30) := 'F';
G_SECONDARY_DEFAULT       CONSTANT VARCHAR(30) := 'D';
G_SECONDARY_NO_DEFAULT    CONSTANT VARCHAR(30) := 'N';

-- Constants used for return value of Check_Lpn_Secondary_Quantity
G_CHECK_SUCCESS           CONSTANT NUMBER      := 0;
G_CHECK_ERROR             CONSTANT NUMBER      := 1;
G_CHECK_WARNING           CONSTANT NUMBER      := 2;

TYPE t_genref IS REF CURSOR;

-- Start of comments
--  API name: Get_Catch_Weight_Attributes
--  Type    : Private
--  Pre-reqs: None.
--  Function: Returns the column values from MTL_SYSTEM_ITEMS
--            concerning catch weights for a given organization
--            and inventory_item_id pair
--  Parameters:
--  IN: p_organization_id   IN NUMBER   Required
--        Item organization id. Part of the unique key
--        that uniquely identifies an item record.
--      p_inventory_item_id IN NUMBER  Required
--        Corresponds to the column INVENTORY_ITEM_ID in
--        the table MTL_SYSTEM_ITEMS, and identifies the
--        record to in which catch weigth attributes should
--        be retrieved.
--      p_quantity          IN NUMBER  Optional
--        Quantity which secondary quantity should be calculated from
--      p_uom_code          IN NUMBER  Optional
--        The UOM in which secondary quantity should be calculated from
--        If no UOM is passes, API will use the primary UOM
-- OUT: x_tracking_quantity_ind  OUT NOCOPY VARCHAR2
--        Corresponds to MTL_SYSTEM_ITEMS_B.TRACKING_QUANTITY_IND
--      x_ont_pricing_qty_source OUT NOCOPY VARCHAR2
--        Corresponds to MTL_SYSTEM_ITEMS_B.ONT_PRICING_QTY_SOURCE
--      x_secondary_default_ind  OUT NOCOPY VARCHAR2
--        Corresponds to MTL_SYSTEM_ITEMS_B.SECONDARY_DEFULAT_IND
--      x_secondary_quantity  OUT NOCOPY NUMBER
--        If item is catch weight enabled and can be defaulted, returns
--        the default secondary quantity based on the conversion of p_quantity
--        into the secondary uom.  Returns null otherwise.
--      x_secondary_uom_code     OUT NOCOPY VARCHAR2
--        Corresponds to MTL_SYSTEM_ITEMS_B.SECONDARY_UOM_CODE
--      x_uom_deviation_high     OUT NOCOPY NUMBER
--        Corresponds to MTL_SYSTEM_ITEMS_B.DUAL_UOM_DEVIATION_HIGH
--      x_uom_deviation_low      OUT NOCOPY NUMBER
--        Corresponds to MTL_SYSTEM_ITEMS_B.DUAL_UOM_DEVIATION_LOW
--  Version : Current version 1.0
-- End of comments

PROCEDURE Get_Catch_Weight_Attributes (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_organization_id        IN         NUMBER
, p_inventory_item_id      IN         NUMBER
, p_quantity               IN         NUMBER   := NULL
, p_uom_code               IN         VARCHAR2 := NULL
, x_tracking_quantity_ind  OUT NOCOPY VARCHAR2
, x_ont_pricing_qty_source OUT NOCOPY VARCHAR2
, x_secondary_default_ind  OUT NOCOPY VARCHAR2
, x_secondary_quantity     OUT NOCOPY NUMBER
, x_secondary_uom_code     OUT NOCOPY VARCHAR2
, x_uom_deviation_high     OUT NOCOPY NUMBER
, x_uom_deviation_low      OUT NOCOPY NUMBER
);


-- Start of comments
--  API name: Get_Ont_Pricing_Qty_Source
--  Type    : Private
--  Pre-reqs: None.
--  Function: Returns the column value of ONT_PRICING_QTY_SOURCE
--            from MTL_SYSTEM_ITEMS for a given organization and
--            inventory_item_id pair
--  Parameters:
--  IN: p_organization_id   IN NUMBER   Required
--        Item organization id. Part of the unique key
--        that uniquely identifies an item record.
--      p_inventory_item_id IN NUMBER  Required
--        Corresponds to the column INVENTORY_ITEM_ID in
--        the table MTL_SYSTEM_ITEMS, and identifies the
--        record to in which catch weigth attributes should
--        be retrieved.
-- OUT: returns the value of MTL_SYSTEM_ITEMS_B.ONT_PRICING_QTY_SOURCE
--
--  Version : Current version 1.0
-- End of comments
FUNCTION Get_Ont_Pricing_Qty_Source (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_organization_id        IN         NUMBER
, p_inventory_item_id      IN         NUMBER
) RETURN VARCHAR2;

-- Start of comments
--  API name: Get_Default_Secondary_Quantity
--  Type    : Private
--  Function: For the given item, org, quantity and uom passed by user for it will
--            return the ONT_PRICING_QTY_SOURCE and secondary_uom_code, from
--            MTL_SYSTEM_ITEMS and calculate the secondary quantity if the item is
--            set up to be 'defaultable'.
--  Parameters:
--  IN: p_organization_id   IN NUMBER  Required
--        Item organization id. Part of the unique key
--        that uniquely identifies an item record.
--      p_inventory_item_id IN NUMBER  Required
--        Item ID of item which secondary quantity should be calculated for.
--      p_quantity          IN NUMBER  Required
--        Quantity which secondary quantity should be calculated from
--      p_uom_code          IN NUMBER  Optional
--        The UOM in which secondary quantity should be calculated from
--        If no UOM is passes, API will use the primary UOM
--      p_secondary_uom_code IN VARCHAR2 Optional
--        value to be used to calcuate default secondary quantity.  If left null
--        will use secondary_uom_code defined in MTL_SYSTEM_ITEMS.
--      p_ont_pricing_qty_source
--        value to be used to determine catch weight enabled.  If left null will
--        use value defined in MTL_SYSTEM_ITEMS.
--      p_secondary_default_ind
--        value to be used to determine item can default catch weights.  If left null
--        will use value defined in MTL_SYSTEM_ITEMS.
-- IN OUT:
--      x_ont_pricing_qty_source
--        takes in MTL_SYSTEM_ITEMS_B.ONT_PRICING_QTY_SOURCE if user has it available
--        this reduces number of database hits if not availaible API returns table value
--        for the given item
--      x_secondary_uom_code  OUT NOCOPY VARCHAR2
--        takes in secondary uom if user has value already available.  If not API
--        returns the default secondary uom if item is catch weight is enabled
--        null otherwise
-- OUT:
--      x_secondary_quantity  OUT NOCOPY NUMBER
--        If item is catch weight enabled and can be defaulted, returns
--        the default secondary quantity based on the conversion of p_quantity
--        into the secondary uom.  Returns null otherwise.
--  Version : Current version 1.0
-- End of comments

PROCEDURE Get_Default_Secondary_Quantity (
  p_api_version            IN            NUMBER
, p_init_msg_list          IN            VARCHAR2 := fnd_api.g_false
, x_return_status          OUT    NOCOPY VARCHAR2
, x_msg_count              OUT    NOCOPY NUMBER
, x_msg_data               OUT    NOCOPY VARCHAR2
, p_organization_id        IN            NUMBER
, p_inventory_item_id      IN            NUMBER
, p_quantity               IN            NUMBER
, p_uom_code               IN            VARCHAR2
, p_secondary_default_ind  IN            VARCHAR2 := NULL
, x_ont_pricing_qty_source IN OUT NOCOPY VARCHAR2
, x_secondary_uom_code     IN OUT NOCOPY VARCHAR2
, x_secondary_quantity     OUT    NOCOPY NUMBER
);

-- Start of comments
--  API name: Check_Secondary_Qty_Tolerance
--  Type    : Private
--  Function: Based on the source table (MMTT or WDD) the api will retrieve the necessary
--            information from the specified record to see if the item is catch weight
--            enabled.  If so, it will return the ONT_PRICING_QTY_SOURCE and the secondary
--            UOM.  If the item is also catch weight defaltable it will try to calculate
--            the secondary quantity.
--  Parameters:
--  IN: p_organization_id    IN NUMBER  Required
--        Item organization id.
--      p_inventory_item_id  IN NUMBER  Required
--        Item ID of item which the tolerances should be checked.
--      p_quantity           IN NUMBER  Required
--        Quantity which secondary quantity should be checked for tolerance against
--      p_uom_code           IN NUMBER  Required
--        The UOM in which secondary quantity should be checked for tolerance
--        against.  If no UOM is passes, API will use the primary UOM
--      p_secondary_quantity IN NUMBER  Required
--        the secondary quantity in secondary uom
--      p_secondary_uom_code IN VARCHAR2 Optional
--        value to be used to calcuate default secondary quantity.  If left null
--        will use secondary_uom_code defined in MTL_SYSTEM_ITEMS.
--      p_ont_pricing_qty_source
--        value to be used to determine catch weight enabled.  If left null will
--        use the value defined in MTL_SYSTEM_ITEMS.
--      p_uom_deviation_high
--        value to be used to determine the upper deviation.  If left null will
--        use value defined in MTL_SYSTEM_ITEMS.
--      p_uom_deviation_low
--        value to be used to determine the lower deviation.  If left null will
--        use value defined in MTL_SYSTEM_ITEMS.
-- OUT: returns 0 if the secodnary quantity is within tolerance
--              1 if the secodnary quantity is above the upper tolerance
--             -1 if the secodnary quantity is beneath the lower tolerance
--  Version : Current version 1.0
-- End of comments

FUNCTION Check_Secondary_Qty_Tolerance (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_organization_id        IN         NUMBER
, p_inventory_item_id      IN         NUMBER
, p_quantity               IN         NUMBER
, p_uom_code               IN         VARCHAR2
, p_secondary_quantity     IN         NUMBER
, p_secondary_uom_code     IN         VARCHAR2 := NULL
, p_ont_pricing_qty_source IN         VARCHAR2 := NULL
, p_uom_deviation_high     IN         NUMBER   := NULL
, p_uom_deviation_low      IN         NUMBER   := NULL
) RETURN NUMBER;

-- Start of comments
--  API name: Update_Shipping_Secondary_Qty
--  Type    : Private
--  Function: Given a delivery_detail_id for a line from wsh_delivery_details
--            API will check tolerances and call a shipping API to update the
--            picked_quantity2 and requested_quantity_uom2 fields
--  Parameters:
--  IN: p_delivery_detail_id IN NUMBER   Required
--        Delivery detail ID of record from wsh_delivery_details to be updated
--      p_secondary_quantity IN NUMBER   Required
--        value to be used to update picked_quantity2.  If left null, API will
--        try to default value if item is defaultable. If value is passed as
--        FND_API.G_MISS_NUM, API will null the picked_quantity2 and
--        requested_quantity_uom2 fields for that particular delivery detail
--      p_secondary_uom_code IN VARCHAR2 Optional
--        value to be used to update requested_quantity_uom2.  If left null will
--        use secondary_uom_code defined in MTL_SYSTEM_ITEMS.  If defined, will
--        be validated against value defined in MTL_SYSTEM_ITEMS and fail if they
--        are not the same, since we currently only support one secondary UOM
--  Version : Current version 1.0
-- End of comments

PROCEDURE Update_Shipping_Secondary_Qty (
  p_api_version        IN         NUMBER
, p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
, p_commit             IN         VARCHAR2 := fnd_api.g_false
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_delivery_detail_id IN         NUMBER
, p_secondary_quantity IN         NUMBER
, p_secondary_uom_code IN         VARCHAR2 := NULL
);

-- Start of comments
--  API name: Update_Parent_Delivery_Sec_Qty
--  Type    : Private
--  Function: Given a delivery_detail_id for a License Plate Number and content item
--            information. API will use a shipping API to update the
--            picked_quantity2 and requested_quantity_uom2 fields, distributing to
--            proportionately over all child WDD lines for that item/rev/lot combination
--  Parameters:
--  IN: p_organization_id    IN NUMBER   Required
--        Organization id.
--      p_parent_del_det_id  IN NUMBER   Required
--        Delivery detail ID of License Plate Number
--      p_inventory_item_id  IN NUMBER   Required
--        Item ID of item to be update with secondary quantity and secondary quantity UOM.
--      p_revision           IN VARCHAR2 Optional
--        Revision of item to be update with secondary quantity and secondary quantity UOM.
--        required for revision controlled items.
--      p_lot_number         IN VARCHAR2 Optional
--        Lot number of item to be update with secondary quantity and secondary quantity UOM.
--        required for lot controlled items.
--      p_quantity           IN NUMBER   Required
--        Quantity which secondary quantity will use to determine proportionate distribution
--      p_uom_code           IN NUMBER   Required
--        The UOM in which secondary quantity will use to calculate proportionate distribution.
--      p_secondary_quantity IN NUMBER
--        the secondary quantity in secondary uom
--      p_secondary_uom_code IN VARCHAR2 Optional
--        value to be used to update requested_quantity_uom2.  If left null will
--        use secondary_uom_code defined in MTL_SYSTEM_ITEMS.  If defined, will
--        be validated against value defined in MTL_SYSTEM_ITEMS and fail if they
--        are not the same, since we currently only support one secondary UOM
--  Version : Current version 1.0
-- End of comments

PROCEDURE Update_Parent_Delivery_Sec_Qty (
  p_api_version        IN         NUMBER
, p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
, p_commit             IN         VARCHAR2 := fnd_api.g_false
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_organization_id    IN         NUMBER
, p_parent_del_det_id  IN         NUMBER
, p_inventory_item_id  IN         NUMBER
, p_revision           IN         VARCHAR2 := NULL
, p_lot_number         IN         VARCHAR2 := NULL
, p_quantity           IN         NUMBER
, p_uom_code           IN         VARCHAR2
, p_secondary_quantity IN         NUMBER
, p_secondary_uom_code IN         VARCHAR2
);

-- Start of comments
--  API name: Update_LPN_Secondary_Quantity
--  Type    : Private
--  Function: Given a lpn_id for a License Plate Number and content item information, and
--            table source, API will update the picked_quantity2 and requested_quantity_uom2
--            fields if source is 'WDD', or secondary quantity and UOM fields in
--            MTL_MATERIAL_TRANSACTIONS_TEMP and MTL_TRANSACTION_LOTS_TEMP if source is 'MMTT'.
--            The secondary quantity will be distributed proportionately over all child lines
--            for that item/rev/lot combination
--  Parameters:
--  IN: p_record_source      IN VARCHAR2 Required
--        Determines the source table where the record should be updated
--        'MMTT' = MTL_MATERIAL_TRANSACTIONS_TEMP/MTL_TRANSACTION_LOTS_TEMP
--        'WDD'  = WSH_DELIVERY_DETAILS
--      p_organization_id    IN NUMBER   Required
--        Organization id.
--      p_lpn_id             IN NUMBER   Required
--        LPN ID of License Plate Number
--      p_inventory_item_id  IN NUMBER   Required
--        Item ID of item to be update with secondary quantity and secondary quantity UOM.
--      p_revision           IN VARCHAR2 Optional
--        Revision of item to be update with secondary quantity and secondary quantity UOM.
--        required for revision controlled items.
--      p_lot_number         IN VARCHAR2 Optional
--        Lot number of item to be update with secondary quantity and secondary quantity UOM.
--        required for lot controlled items.
--      p_quantity           IN NUMBER   Required
--        Quantity which secondary quantity will use to determine proportionate distribution
--      p_uom_code           IN NUMBER   Required
--        The UOM in which secondary quantity will use to calculate proportionate distribution.
--      p_secondary_quantity IN NUMBER
--        the secondary quantity in secondary uom
--      p_secondary_uom_code IN VARCHAR2 Optional
--        value to be used to update requested_quantity_uom2.  If left null will
--        use secondary_uom_code defined in MTL_SYSTEM_ITEMS.  If defined, will
--        be validated against value defined in MTL_SYSTEM_ITEMS and fail if they
--        are not the same, since we currently only support one secondary UOM
--  Version : Current version 1.0
-- End of comments

PROCEDURE Update_LPN_Secondary_Quantity (
  p_api_version        IN         NUMBER
, p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
, p_commit             IN         VARCHAR2 := fnd_api.g_false
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_record_source      IN         VARCHAR2
, p_organization_id    IN         NUMBER
, p_lpn_id             IN         NUMBER
, p_inventory_item_id  IN         NUMBER
, p_revision           IN         VARCHAR2 := NULL
, p_lot_number         IN         VARCHAR2 := NULL
, p_quantity           IN         NUMBER
, p_uom_code           IN         VARCHAR2
, p_secondary_quantity IN         NUMBER
, p_secondary_uom_code IN         VARCHAR2
);


-- Start of comments
--  API name: Check_LPN_Secondary_Quantity
--  Type    : Private
--  Function: Given a lpn_id for a outermost license plate number and organization ID,
--            API will iterate through all it's content items and nested LPNs.  Checking
--            if the item is catch weight enabled, and if so, check to see if secondary
--            quantity and secondary UOM values have been defined for them.
--  Parameters:
--  IN: p_organization_id    IN NUMBER   Required
--        Organization ID.
--      p_outermost_lpn_id   IN NUMBER   Required
--        LPN ID of outermoste license plate number
-- OUT: returns:
--      0 (G_CHECK_SUCCESS) if all items in outermost LPN and nested LPNs that are catch
--        weight enabled have catch weight values defined.
--      1 (G_CHECK_ERROR) if an item was found in the outermost or nested LPNs that requires
--        catch weights but could not be defaulted, either due to setup or invalid uom
--        conversion
--      2 (G_CHECK_WARNING) if an item was found in the outermost or nested LPNs that do
--        not have catch weight values defined, but can and will be defaulted
--  Version : Current version 1.0
-- End of comments

FUNCTION Check_LPN_Secondary_Quantity (
  p_api_version      IN         NUMBER
, p_init_msg_list    IN         VARCHAR2 := fnd_api.g_false
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
, p_organization_id  IN         NUMBER
, p_outermost_lpn_id IN         NUMBER
) RETURN NUMBER;

-- Start of comments
--  API name: GET_OUTER_CATCH_WT_LPN
--  Type    : Private
--  Pre-reqs: None.
--  Function: LOV Query, Returns the list of valid Outer LPN
--  Parameters:
--  IN: p_org_id   IN NUMBER   Required
--        Item organization id. Part of the unique key
--        that uniquely identifies an item record.
--      p_lpn IN VARCHAR2  Required
--        LPN which user might enter.
--      p_entry_type IN VARCHAR2 Required
--        Could be ALL, NEW, based on the update or New mode user
--        selects from the menu
-- OUT: x_lpn_lov  OUT NOCOPY t_genref
--        List of valid outer lpns.


PROCEDURE GET_OUTER_CATCH_WT_LPN
 (x_lpn_lov    OUT NOCOPY t_genref,
  p_org_id     IN  NUMBER,
  p_lpn        IN  VARCHAR2,
  p_entry_type IN  VARCHAR2);

-- Start of comments
--  API name: GET_INNER_CATCH_WT_LPN
--  Type    : Private
--  Pre-reqs: None.
--  Function: LOV Query, Returns the list of valid Inner LPN
--  Parameters:
--  IN: p_org_id   IN NUMBER   Required
--        Item organization id. Part of the unique key
--        that uniquely identifies an item record.
--      p_outer_lpn_id IN NUMBER  Required
--        LPN Id of the outer lpn.
--      p_entry_type IN VARCHAR2 Required
--        Could be ALL, NEW, based on the update or New mode user
--        selects from the menu
--      p_lpn_context IN NUMBER
--        lpn context of the outer lpn
--      p_inner_lpn IN VARCHAR2
--        Partial value of inner lpn user might enter
-- OUT: x_lpn_lov  OUT NOCOPY t_genref
--        List of valid inner lpns.

PROCEDURE GET_INNER_CATCH_WT_LPN
 (x_lpn_lov OUT NOCOPY t_genref,
  p_org_id        IN  NUMBER,
  p_outer_lpn_id  IN  NUMBER,
  p_entry_type    IN  VARCHAR2,
  p_lpn_context   IN  NUMBER,
  p_inner_lpn     IN  VARCHAR2);

-- Start of comments
--  API name: GET_CATCH_WT_ITEMS
--  Type    : Private
--  Pre-reqs: None.
--  Function: LOV Query, Returns the list of valid Item in the inner LPN
--  Parameters:
--  IN: p_org_id   IN NUMBER   Required
--        Item organization id. Part of the unique key
--        that uniquely identifies an item record.
--      p_lpn_id IN NUMBER  Required
--        LPN Id of the Inner lpn.
--      p_entry_type IN VARCHAR2 Required
--        Could be ALL, NEW, based on the update or New mode user
--        selects from the menu
--      p_lpn_context IN NUMBER Required
--        lpn context of the outer lpn
--      p_concat_item_segment IN VARCHAR2 not Required
--        Partial/Full value of the Item
-- OUT: x_item_lov  OUT NOCOPY t_genref
--        List of valid items in inner lpn.

PROCEDURE GET_CATCH_WT_ITEMS
  (x_item_lov OUT NOCOPY t_genref,
   p_org_id              IN NUMBER,
   p_lpn_id              IN NUMBER,
   p_entry_type          IN VARCHAR2,
   p_lpn_context         IN NUMBER,
   p_concat_item_segment IN VARCHAR2);


-- Start of comments
--  API name: SHOW_CT_WT_FOR_SPLIT
--  Type    : Private
--  Pre-reqs: None.
--  Function: This procedure holds the logic to show the catch weight
--            entry fields on the MObile UI or DeskTop form
--            If fromLPN has catchweight enabled item and ctwt qty has been
--            entered + TOLPN has the same item and ctwt qty is present
--            then show the ctwt fields.
--            If fromLPN has ctwt item and ctwt qty is 0 + TOLPN has same
--            item and ctwt qty = 0
--            then show the ctwt fields
--            Else dont show the fields
--  Parameters:
--  IN: p_org_id   IN NUMBER   Required
--        Item organization id. Part of the unique key
--        that uniquely identifies an item record.
--      p_from_delivery_id IN NUMBER  Required
--        Delivery Detail Id of the LPN entered by user .
--      p_from_item_id IN NUMBER Required
--        Item id of the fromlpn item to be split
--      p_to_lpn_id IN NUMBER Required
--        To lpn id
--  OUT: x_show_ct_wt OUT NUMBER
--       Valid values are 1 = "YES" OR 0 = "NO"

PROCEDURE SHOW_CT_WT_FOR_SPLIT (
  p_org_id           IN         NUMBER
, p_from_lpn_id      IN         NUMBER
, p_from_item_id     IN         NUMBER
, p_from_item_revision   IN     VARCHAR2
, p_from_item_lot_number IN     VARCHAR2
, p_to_lpn_id        IN         NUMBER
, x_show_ct_wt       OUT NOCOPY NUMBER
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_data         OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER

);


-- Start of comments
--  API name: IS_CT_WT_SPLIT_VALID
--  Type    : Private
--  Pre-reqs: None.
--  Function: This function holds the logic to validate the split of ctwt item
--            Based on the fm lpn, fm item, item pri qty and item sec qty
--            it determines if the left over ct wt is also within tolerances
--  Parameters:
--  IN: p_org_id   IN NUMBER   Required
--        Item organization id. Part of the unique key
--        that uniquely identifies an item record.
--      p_from_lpn_id IN NUMBER  Required
--        lpn id of the from lpn entered by user .
--      p_from_item_id IN NUMBER Required
--        Item id of the fromlpn item to be split
--      p_from_item_revision IN VARCHAR2
--      p_from_item_lot_number IN VARCHAR2
--      p_from_item_pri_qty IN NUMBER Required
--        primary qty that needs to be split
--      p_from_item_sec_qty IN NUMBER Required
--        sec qty for this item/rev/lot
--  OUT: RETURN NUMBER
--       Valid values are 1 = "YES" OR 0 = "NO"

FUNCTION IS_CT_WT_SPLIT_VALID (
  p_org_id               IN         NUMBER
, p_from_lpn_id          IN         NUMBER
, p_from_item_id         IN         NUMBER
, p_from_item_revision   IN         VARCHAR2
, p_from_item_lot_number IN         VARCHAR2
, p_from_item_pri_qty    IN         NUMBER
, p_from_item_pri_uom    IN         VARCHAR2
, p_from_item_sec_qty    IN         NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_data             OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
) RETURN NUMBER;


-- Start of comments
--  API name: VALIDATE_CT_WT_FOR_DELIVERYNUM
--  Type    : Private
--  Pre-reqs: None.
--  Function: This procedure holds the logic to validate catch weight
--             with in delivery number.
--            With the delivery number, find out all lpn (including
--            inner lpn's) which has ct wt enabled item and
--            ct wt is null. If the item attribute secondary_default_ind
--            for that item has
--            default set to NO, return error, else try to derive
--            sec qty for that item if it is <0 then return error
--            else return warning.
--  Parameters:
--  IN: p_org_id   IN NUMBER   Required
--        Item organization id. Part of the unique key
--        that uniquely identifies an item record.
--      p_delivery_number IN VARCHAR2 Required
--  OUT x_return_status: success, failure
--        RETURN 1 --> Error
--               2 --> Warning

FUNCTION VALIDATE_CT_WT_FOR_DELIVERYNUM (
  p_api_version      IN         NUMBER
, p_init_msg_list    IN         VARCHAR2 := fnd_api.g_false
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
, p_org_id           IN         NUMBER
, p_delivery_name    IN         VARCHAR2
)RETURN NUMBER;

END WMS_CATCH_WEIGHT_PVT;

/
