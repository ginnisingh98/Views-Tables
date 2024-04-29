--------------------------------------------------------
--  DDL for Package INV_ID_TO_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ID_TO_VALUE" AUTHID CURRENT_USER AS
/* $Header: INVSIDVS.pls 120.0 2005/05/25 05:17:30 appldev noship $ */

--  Procedure Get_Attr_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  Id_To_Value functions.
--
--  DO NOT MODIFY

PROCEDURE Get_Attr_Tbl;

--  Prototypes for Id_To_Value functions.

--  START GEN Id_To_Value

--  Generator will append new prototypes before end generate comment.

FUNCTION From_Subinventory
(   p_from_subinventory_id        IN  NUMBER
) RETURN VARCHAR2;
--(   p_from_subinventory_code        IN  VARCHAR2 -- Generated
--) RETURN VARCHAR2;                               -- Generated

FUNCTION Header
(   p_header_id                     IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Organization
(   p_organization_id               IN  NUMBER
) RETURN VARCHAR2;

FUNCTION To_Organization
(   p_to_organization_id               IN  NUMBER
) RETURN VARCHAR2;

FUNCTION To_Account
(   p_to_account_id                 IN  NUMBER
) RETURN VARCHAR2;

FUNCTION To_Subinventory
(   p_to_subinventory_id          IN  NUMBER
) RETURN VARCHAR2;
--(   p_to_subinventory_code          IN  VARCHAR2 -- Generated
--) RETURN VARCHAR2;                               -- Generated

FUNCTION Transaction_Type
(   p_transaction_type_id           IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Move_Order_Type
(   p_move_order_type           IN  NUMBER
) RETURN VARCHAR2;

FUNCTION From_Locator
(   p_from_locator_id               IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Inventory_Item
(   p_inventory_item_id             IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Line
(   p_line_id                       IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Project
(   p_project_id                    IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Reason
(   p_reason_id                     IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Reference
(   p_reference_id                  IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Reference_Type
(   p_reference_type_code           IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Task
(   p_task_id                       IN  NUMBER
) RETURN VARCHAR2;

FUNCTION To_Locator
(   p_to_locator_id                 IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Transaction_Header
(   p_transaction_header_id         IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Uom
(   p_uom_code                      IN  VARCHAR2
) RETURN VARCHAR2;

--  END GEN Id_To_Value

END INV_Id_To_Value;

 

/
