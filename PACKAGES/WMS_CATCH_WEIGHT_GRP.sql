--------------------------------------------------------
--  DDL for Package WMS_CATCH_WEIGHT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CATCH_WEIGHT_GRP" AUTHID CURRENT_USER as
/* $Header: WMSGCWTS.pls 115.4 2004/04/09 00:04:34 jsheu noship $ */

-- Constants for MTL_SYSTEM_ITEMS_B.ONT_PRICING_QTY_SOURCE
-- Possible values are P/S (primary/secondary)
G_PRICE_PRIMARY   CONSTANT VARCHAR(30) := WMS_CATCH_WEIGHT_PVT.G_PRICE_PRIMARY;
G_PRICE_SECONDARY CONSTANT VARCHAR(30) := WMS_CATCH_WEIGHT_PVT.G_PRICE_SECONDARY;

-- Start of comments
--  API name: Get_Default_Secondary_Quantity
--  Type    : Group
--  Function: For the given item, org, quantity and uom passed by user for it will
--            return the ONT_PRICING_QTY_SOURCE, from MTL_SYSTEM_ITEMS and it will
--            also return secondary_uom_code and calculate the secondary quantity if
--            the item is set up to be priced on secondary.  Unlike the private API this
--            API will calculate secondary quantity for secondary priced items regardless
--            to whether the the secondary quantity is 'defaultable' or not.
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
-- OUT:
--      return
--        returns table value in MTL_SYSTEM_ITEMS.ONT_PRICING_QTY_SOURCE
--        Possible values are G_PRICE_PRIMARY = primary G_PRICE_SECONDARY = secondary
--      x_secondary_quantity  OUT NOCOPY NUMBER
--        If item is catch weight enabled and can be defaulted, returns
--        the default secondary quantity based on the conversion of p_quantity
--        into the secondary uom.  Returns null otherwise.
--      x_secondary_uom_code  OUT NOCOPY VARCHAR2
--        returns the default secondary uom if item is catch weight is enabled
--        null otherwise
--  Version : Current version 1.0
-- End of comments

FUNCTION Get_Default_Secondary_Quantity (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_organization_id        IN         NUMBER
, p_inventory_item_id      IN         NUMBER
, p_quantity               IN         NUMBER
, p_uom_code               IN         VARCHAR2
, x_secondary_quantity     OUT NOCOPY NUMBER
, x_secondary_uom_code     OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;

END WMS_CATCH_WEIGHT_GRP;

 

/
