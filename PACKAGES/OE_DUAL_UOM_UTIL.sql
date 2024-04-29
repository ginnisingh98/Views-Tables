--------------------------------------------------------
--  DDL for Package OE_DUAL_UOM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DUAL_UOM_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUDUMS.pls 120.0.12010000.2 2013/01/11 18:43:48 gabhatia noship $ */


TYPE Inventory_Item_Rec_Type IS RECORD
(   Inventory_item_id     mtl_system_items.Inventory_item_id%TYPE ,
    Org_id                mtl_system_items.organization_id%TYPE ,
    primary_uom_code      mtl_system_items.primary_uom_code%TYPE ,
    secondary_uom_code    mtl_system_items.secondary_uom_code%TYPE  ,
    inventory_item_flag   mtl_system_items.inventory_item_flag%TYPE  ,
    shippable_item_flag   mtl_system_items.shippable_item_flag%TYPE ,
    reservable_type       mtl_system_items.reservable_type%TYPE ,
    tracking_quantity_ind mtl_system_items.tracking_quantity_ind%TYPE  ,
    ordered_uom_class     mtl_units_of_measure.uom_class%TYPE,
    primary_uom_class     mtl_units_of_measure.uom_class%TYPE,
    secondary_uom_class   mtl_units_of_measure.uom_class%TYPE,
    wms_enabled_flag      VARCHAR2(1)
);


------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------
-- Function get_fulfillment_eligible
--
-- API to determine whether fulfillment_base should be calculated or not for current line_id
-- IN parameters -
-- p_line_rec   : The function will take OE_Order_PUB.Line_Rec_Type record
--                containing line_id as input and return Boolean value Indicating, whether FB
--                on line should be calculated as per new functionality or not.
--                Boolean TRUE implies : Yes, calculate FB
--                Boolean FALSE implies : No, not eligible to calculate FB
-- OUT parameters -
-- p_inventory_item_rec :
-- A new record type structure Inventory_Item_Rec_Type is defined.
-- In get_fulfillment_eligible , we will query mtl_system_items to fetch property of a item,
-- we use thi swuery to fetch other required parameters like primary uom of item (to be used later in derive_fulfillment_base API).
---------------------------------------------------------------------

Function get_fulfillment_eligible
            (   p_line_rec  IN OE_Order_PUB.Line_Rec_Type  ,
                p_inventory_item_rec OUT NOCOPY Inventory_Item_Rec_Type
             ) RETURN BOOLEAN;
------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------
-- Function get_fulfillment_base
--
-- GROUP API to return value of fulfillment_base filed on a line.
-- IN parameters -
-- p_line_rec   : The function will take line_id as input, query oe_order_lines_all table and return value of fulfillment_base field.
---------------------------------------------------------------------
Function get_fulfillment_base
               (   p_line_id  IN NUMBER
                ) RETURN VARCHAR2;
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function derive_fulfillment_base
--
--This api will be called from oe_line_util.pre_write procedure to fetch value for
--a new database column (fulfillment_base) on the order line to store the fulfillment
--BASE which can be Primary (P) or Secondary(S) or NULL. This column gets populated
--at the time of UOM Defaulting/Change as well as change of ITEM or WAREHOUSE or Return reference line
--(only when new profile OM: Default Fulfillment Base is set to YES)
--This API will also be called from OE_Bulk_Process_Line.Populate_Internal_Fields to populate fulfillment_base
--column from HVOP flow (for dual uom items only when new profile OM: Default Fulfillment Base is set to YES).
-- IN parameters -
-- p_line_rec   : The function will take OE_Order_PUB.Line_Rec_Type record contains line_id , org_id ,ship_from_org_id ,
--                inventory_item_id etc as input and return CHAR value (Null, 'P' or 'S') .
--                'P' implies : Primary
--                'S' implies : Secondary
--                 Null implies: line not eligible for FB field.
---------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
---It is PVT API as per FDD 3.1.3.3

Function derive_fulfillment_base
(   p_line_rec                      IN OE_Order_PUB.Line_Rec_Type
) RETURN varchar2;

------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------
-- PROCEDURE validate_fulfillment_base
--
--
--This api will be called from oe_line_util.apply_attribute_changes procedure when
-- FB on a line is changing form null/P to S or vice versa. The API will validate
-- if the change should be allowed on FB field...if not it will raise error
-- IN parameters -
-- p_line_rec   : The proeudre will for validation of fulfillment_base field from OE_Order_PUB.Line_Rec_Type
---------------------------------------------------------------------
PROCEDURE validate_fulfillment_base
(   p_line_rec                    IN  OE_Order_PUB.Line_Rec_Type
);

END OE_DUAL_UOM_UTIL;

/
