--------------------------------------------------------
--  DDL for Package INV_VALUE_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_VALUE_TO_ID" AUTHID CURRENT_USER AS
/* $Header: INVSVIDS.pls 115.4 2004/05/27 06:04:22 cjandhya ship $ */

--  Procedure Get_Attr_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  conversion functions.
--
--  DO NOT MODIFY

PROCEDURE Get_Attr_Tbl;

--  Prototypes for Value_To_Id functions.

--  START GEN value_to_id

--  Generator will append new prototypes before end generate comment.
FUNCTION Key_Flex
(   p_key_flex_code                 IN  VARCHAR2
,   p_structure_number              IN  NUMBER
,   p_appl_short_name               IN  VARCHAR2
,   p_segment_array                 IN  FND_FLEX_EXT.SegmentArray
) RETURN NUMBER;

--  From_Subinventory

FUNCTION From_Subinventory
(  p_organization_id               IN  NUMBER,
   p_from_subinventory             IN  VARCHAR2
) RETURN VARCHAR2;

--  Header

FUNCTION Header
(   p_header                        IN  VARCHAR2
) RETURN NUMBER;

--  Organization

FUNCTION Organization
(   p_organization                  IN  VARCHAR2
) RETURN NUMBER;

--  To_ORGANIZATION
FUNCTION To_Organization
(   p_to_organization                  IN  VARCHAR2
) RETURN NUMBER;


--  To_Account
FUNCTION To_Account
(  p_organization_id               IN  NUMBER,
   p_to_account                    IN  VARCHAR2
) RETURN NUMBER;

--  To_Subinventory

FUNCTION To_Subinventory
(  p_organization_id               IN  NUMBER,
   p_to_subinventory               IN  VARCHAR2
) RETURN VARCHAR2;

--  Transaction_Type

FUNCTION Transaction_Type
(   p_transaction_type              IN  VARCHAR2
) RETURN NUMBER;

--  Move_Order_Type

FUNCTION Move_Order_Type
(   p_move_order_type              IN  VARCHAR2
) RETURN NUMBER;

--  From_Locator

FUNCTION From_Locator
(  p_organization_id               IN  NUMBER,
   p_from_locator                  IN  VARCHAR2
) RETURN NUMBER;

--  Inventory_Item

FUNCTION Inventory_Item
(   p_organization_id               IN  NUMBER,
    p_inventory_item                IN  VARCHAR2
) RETURN NUMBER;

--  Line

FUNCTION Line
(   p_line                          IN  VARCHAR2
) RETURN NUMBER;

--  Project

FUNCTION Project
(   p_project                       IN  VARCHAR2
) RETURN NUMBER;

--  Reason

FUNCTION Reason
(   p_reason                        IN  VARCHAR2
) RETURN NUMBER;

--  Reference

FUNCTION Reference
(   p_reference                     IN  VARCHAR2
) RETURN NUMBER;

--  Reference_Type

FUNCTION Reference_Type
(   p_reference_type                IN  VARCHAR2
) RETURN NUMBER;

--  Task

FUNCTION Task
(   p_task                          IN  VARCHAR2
) RETURN NUMBER;

--  To_Locator

FUNCTION To_Locator
(  p_organization_id               IN  NUMBER,
   p_to_locator                    IN  VARCHAR2
) RETURN NUMBER;

--  Transaction_Header

FUNCTION Transaction_Header
(   p_transaction_header            IN  VARCHAR2
) RETURN NUMBER;

--  Uom

FUNCTION Uom
(   p_uom                           IN  VARCHAR2
) RETURN VARCHAR2;

--  Uom

--FUNCTION Uom
--(   p_uom                           IN  VARCHAR2
--) RETURN NUMBER;
--  END GEN value_to_id

END INV_Value_To_Id;

 

/
