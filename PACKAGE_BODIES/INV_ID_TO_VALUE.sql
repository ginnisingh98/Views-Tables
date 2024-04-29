--------------------------------------------------------
--  DDL for Package Body INV_ID_TO_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ID_TO_VALUE" AS
/* $Header: INVSIDVB.pls 120.1 2005/07/01 13:59:13 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_Id_To_Value';

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  Id_To_Value functions.
--
--  DO NOT REMOVE

PROCEDURE Get_Attr_Tbl
IS
I                             NUMBER:=0;
BEGIN

    FND_API.g_attr_tbl.DELETE;

--  START GEN attributes

--  Generator will append new attributes before end generate comment.
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'from_subinventory';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'organization';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_subinventory';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'from_locator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'inventory_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'project';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'task';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_locator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transaction_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'uom';
--  END GEN attributes

END Get_Attr_Tbl;

--  Prototypes for Id_To_Value functions.

--  START GEN Id_To_Value

--  Generator will append new prototypes before end generate comment.


FUNCTION From_Subinventory -- yyy
(   p_from_subinventory_id        IN  NUMBER
) RETURN VARCHAR2
--(   p_from_subinventory_code        IN  VARCHAR2  -- Generated
--) RETURN VARCHAR2                                 -- Generated
IS
l_from_subinventory           VARCHAR2(240) := NULL;
BEGIN

--    IF p_from_subinventory_code IS NOT NULL THEN  -- Generated
    IF p_from_subinventory_id IS NOT NULL THEN

        --  SELECT  FROM_SUBINVENTORY
        --  INTO    l_from_subinventory
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_from_subinventory_code;

        NULL;

    END IF;

    RETURN l_from_subinventory;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','from_subinventory');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'From_Subinventory'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END From_Subinventory;

FUNCTION Header
(   p_header_id                     IN  NUMBER
) RETURN VARCHAR2
IS
l_header                      VARCHAR2(240) := NULL;
BEGIN

    IF p_header_id IS NOT NULL THEN

        --  SELECT  HEADER
        --  INTO    l_header
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_header_id;

        NULL;

    END IF;

    RETURN l_header;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Header;

FUNCTION Organization
(   p_organization_id               IN  NUMBER
) RETURN VARCHAR2
IS
l_organization                VARCHAR2(240) := NULL;
BEGIN

    IF p_organization_id IS NOT NULL THEN

        --  SELECT  ORGANIZATION
        --  INTO    l_organization
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_organization_id;

        NULL;

    END IF;

    RETURN l_organization;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization;

FUNCTION To_Organization
(   p_to_organization_id               IN  NUMBER
) RETURN VARCHAR2
IS
l_to_organization                VARCHAR2(240) := NULL;
BEGIN

    IF p_to_organization_id IS NOT NULL THEN

        --  SELECT  ORGANIZATION
        --  INTO    l_organization
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_organization_id;

        NULL;

    END IF;

    RETURN l_to_organization;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_organization');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Organization;

FUNCTION To_Account
(   p_to_account_id                 IN  NUMBER
) RETURN VARCHAR2
IS
l_to_account                  VARCHAR2(240) := NULL;
BEGIN

    IF p_to_account_id IS NOT NULL THEN

        --  SELECT  TO_ACCOUNT
        --  INTO    l_to_account
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_to_account_id;

        NULL;

    END IF;

    RETURN l_to_account;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Account;

FUNCTION To_Subinventory
(   p_to_subinventory_id          IN  NUMBER
) RETURN VARCHAR2
--(   p_to_subinventory_code          IN  VARCHAR2 -- Generated
--) RETURN VARCHAR2                                -- Generated
IS
l_to_subinventory             VARCHAR2(240) := NULL;
BEGIN

--    IF p_to_subinventory_code IS NOT NULL THEN
    IF p_to_subinventory_id IS NOT NULL THEN

        --  SELECT  TO_SUBINVENTORY
        --  INTO    l_to_subinventory
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_to_subinventory_code;

        NULL;

    END IF;

    RETURN l_to_subinventory;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_subinventory');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Subinventory'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Subinventory;

FUNCTION Transaction_Type
(   p_transaction_type_id           IN  NUMBER
) RETURN VARCHAR2
IS
l_transaction_type            VARCHAR2(240) := NULL;
BEGIN

    IF p_transaction_type_id IS NOT NULL THEN

        --  SELECT  TRANSACTION_TYPE
        --  INTO    l_transaction_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_transaction_type_id;

        NULL;

    END IF;

    RETURN l_transaction_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Type;

FUNCTION Move_Order_Type
(   p_move_order_type           IN  NUMBER
) RETURN VARCHAR2
IS
l_move_order_type            VARCHAR2(240) := NULL;
BEGIN

    IF p_move_order_type IS NOT NULL THEN

        --  SELECT  TRANSACTION_TYPE
        --  INTO    l_transaction_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_transaction_type_id;

        NULL;

    END IF;

    RETURN l_move_order_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','move_order_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Move_order_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Move_Order_Type;

FUNCTION From_Locator
(   p_from_locator_id               IN  NUMBER
) RETURN VARCHAR2
IS
l_from_locator                VARCHAR2(240) := NULL;
BEGIN

    IF p_from_locator_id IS NOT NULL THEN

        --  SELECT  FROM_LOCATOR
        --  INTO    l_from_locator
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_from_locator_id;

        NULL;

    END IF;

    RETURN l_from_locator;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','from_locator');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'From_Locator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END From_Locator;

FUNCTION Inventory_Item
(   p_inventory_item_id             IN  NUMBER
) RETURN VARCHAR2
IS
l_inventory_item              VARCHAR2(240) := NULL;
BEGIN

    IF p_inventory_item_id IS NOT NULL THEN

        --  SELECT  INVENTORY_ITEM
        --  INTO    l_inventory_item
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_inventory_item_id;

        NULL;

    END IF;

    RETURN l_inventory_item;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Inventory_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Item;

FUNCTION Line
(   p_line_id                       IN  NUMBER
) RETURN VARCHAR2
IS
l_line                        VARCHAR2(240) := NULL;
BEGIN

    IF p_line_id IS NOT NULL THEN

        --  SELECT  LINE
        --  INTO    l_line
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_line_id;

        NULL;

    END IF;

    RETURN l_line;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line;

FUNCTION Project
(   p_project_id                    IN  NUMBER
) RETURN VARCHAR2
IS
l_project                     VARCHAR2(240) := NULL;
BEGIN

    IF p_project_id IS NOT NULL THEN

        --  SELECT  PROJECT
        --  INTO    l_project
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_project_id;

        NULL;

    END IF;

    RETURN l_project;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','project');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Project'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Project;

FUNCTION Reason
(   p_reason_id                     IN  NUMBER
) RETURN VARCHAR2
IS
l_reason                      VARCHAR2(240) := NULL;
BEGIN

    IF p_reason_id IS NOT NULL THEN

        --  SELECT  REASON
        --  INTO    l_reason
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_reason_id;

        NULL;

    END IF;

    RETURN l_reason;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reason');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reason;

FUNCTION Reference
(   p_reference_id                  IN  NUMBER
) RETURN VARCHAR2
IS
l_reference                   VARCHAR2(240) := NULL;
BEGIN

    IF p_reference_id IS NOT NULL THEN

        --  SELECT  REFERENCE
        --  INTO    l_reference
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_reference_id;

        NULL;

    END IF;

    RETURN l_reference;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reference');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reference'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reference;

FUNCTION Reference_Type
(   p_reference_type_code           IN  NUMBER
) RETURN VARCHAR2
IS
l_reference_type              VARCHAR2(240) := NULL;
BEGIN

    IF p_reference_type_code IS NOT NULL THEN

        --  SELECT  REFERENCE_TYPE
        --  INTO    l_reference_type
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_reference_type_code;

        NULL;

    END IF;

    RETURN l_reference_type;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reference_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reference_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reference_Type;

FUNCTION Task
(   p_task_id                       IN  NUMBER
) RETURN VARCHAR2
IS
l_task                        VARCHAR2(240) := NULL;
BEGIN

    IF p_task_id IS NOT NULL THEN

        --  SELECT  TASK
        --  INTO    l_task
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_task_id;

        NULL;

    END IF;

    RETURN l_task;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','task');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Task'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Task;

FUNCTION To_Locator
(   p_to_locator_id                 IN  NUMBER
) RETURN VARCHAR2
IS
l_to_locator                  VARCHAR2(240) := NULL;
BEGIN

    IF p_to_locator_id IS NOT NULL THEN

        --  SELECT  TO_LOCATOR
        --  INTO    l_to_locator
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_to_locator_id;

        NULL;

    END IF;

    RETURN l_to_locator;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_locator');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Locator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Locator;

FUNCTION Transaction_Header
(   p_transaction_header_id         IN  NUMBER
) RETURN VARCHAR2
IS
l_transaction_header          VARCHAR2(240) := NULL;
BEGIN

    IF p_transaction_header_id IS NOT NULL THEN

        --  SELECT  TRANSACTION_HEADER
        --  INTO    l_transaction_header
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_transaction_header_id;

        NULL;

    END IF;

    RETURN l_transaction_header;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_header');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Header;

FUNCTION Uom
(   p_uom_code                      IN  VARCHAR2
) RETURN VARCHAR2
IS
l_uom                         VARCHAR2(240) := NULL;
BEGIN

    IF p_uom_code IS NOT NULL THEN

        --  SELECT  UOM
        --  INTO    l_uom
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_uom_code;

        NULL;

    END IF;

    RETURN l_uom;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','uom');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Uom;

--  END GEN Id_To_Value

END INV_Id_To_Value;

/
