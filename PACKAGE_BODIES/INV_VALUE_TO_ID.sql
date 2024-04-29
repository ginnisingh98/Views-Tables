--------------------------------------------------------
--  DDL for Package Body INV_VALUE_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_VALUE_TO_ID" AS
/* $Header: INVSVIDB.pls 115.5 2004/05/27 05:52:01 cjandhya ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_Value_To_Id';

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  conversion functions.
--
--  DO NOT REMOVE

PROCEDURE Get_Attr_Tbl
IS
I                             NUMBER:=0;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    FND_API.g_attr_tbl.DELETE;

--  START GEN attributes

--  Generator will append new attributes before end generate comment.
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Key_Flex';
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

--  Prototypes for value_to_id functions.

--  START GEN value_to_id

--  Key Flex

FUNCTION Key_Flex
(   p_key_flex_code                 IN  VARCHAR2
,   p_structure_number              IN  NUMBER
,   p_appl_short_name               IN  VARCHAR2
,   p_segment_array                 IN  FND_FLEX_EXT.SegmentArray
)
RETURN NUMBER
IS
l_id                          NUMBER;
l_segment_array               FND_FLEX_EXT.SegmentArray;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    l_segment_array := p_segment_array;

    --  Convert any missing values to NULL

    FOR I IN 1..l_segment_array.COUNT LOOP

        IF l_segment_array(I) = FND_API.G_MISS_CHAR THEN
            l_segment_array(I) := NULL;
        END IF;

    END LOOP;

    --  Call Flex conversion routine

    IF NOT FND_FLEX_EXT.get_combination_id
    (   application_short_name        => p_appl_short_name
    ,   key_flex_code                 => p_key_flex_code
    ,   structure_number              => p_structure_number
    ,   validation_date               => NULL
    ,   n_segments                    => l_segment_array.COUNT
    ,   segments                      => l_segment_array
    ,   combination_id                => l_id
    )
    THEN

        --  Error getting combination id.
        --  Function has already pushed a message on the stack. Add to
        --  the API message list.

        FND_MSG_PUB.Add;
        l_id := FND_API.G_MISS_NUM;

    END IF;

    RETURN l_id;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Key_Flex'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Key_Flex;

--  Generator will append new prototypes before end generate comment.


--  From_Subinventory

FUNCTION From_Subinventory
(  p_organization_id               IN  NUMBER,
   p_from_subinventory             IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(10);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    l_code := p_from_subinventory;
    RETURN l_code;

END From_Subinventory;

--  Header

FUNCTION Header
(   p_header                        IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_header IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_header

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Organization

FUNCTION Organization
(   p_organization                  IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_organization IS NULL
       OR p_organization = FND_API.G_MISS_CHAR
    THEN
        RETURN NULL;
    END IF;

    SELECT  ORGANIZATION_ID
    INTO    l_id
    FROM    ORG_ORGANIZATION_DEFINITIONS
    WHERE   ORGANIZATION_CODE = p_organization;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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
(   p_to_organization                  IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_to_organization IS NULL
       OR p_to_organization = FND_API.G_MISS_CHAR
    THEN
        RETURN NULL;
    END IF;

    SELECT  ORGANIZATION_ID
    INTO    l_id
    FROM    ORG_ORGANIZATION_DEFINITIONS
    WHERE   ORGANIZATION_CODE = p_to_organization;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_organization_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'TO_Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Organization;

--To_Account
--Bug 3632199 fix. Removed the query to gl_code_combinations_kfv
--Now using fnd apis to get the ccid
FUNCTION To_Account
  (  p_organization_id               IN  NUMBER,
     p_to_account                    IN  VARCHAR2
     ) RETURN NUMBER
IS
   l_id       NUMBER := NULL;
   l_chart    NUMBER := NULL;
BEGIN
   IF p_to_account IS NULL
     OR p_to_account = FND_API.G_MISS_CHAR
     THEN
      RETURN NULL;
   END IF;

   SELECT gsb.chart_of_accounts_id INTO	l_chart
     FROM GL_SETS_OF_BOOKS gsb
     WHERE gsb.set_of_books_id=
     (SELECT to_number(hoi.org_information1)
      FROM HR_ORGANIZATION_INFORMATION hoi
      WHERE hoi.organization_id = p_organization_id
      AND hoi.org_information_context = 'Accounting Information'
      AND ROWNUM < 2);

   l_id := fnd_flex_ext.get_ccid
     (application_short_name	=>'SQLGL',
      key_flex_code             =>'GL#',
      structure_number        	=>l_chart,
      validation_date         	=>to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'),
      concatenated_segments   	=>p_to_account);

   IF l_id=0 then
      RAISE fnd_api.g_exc_error;
   END IF;

   RETURN l_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_account_id'|| p_to_account);
	 FND_MSG_PUB.Add;
      END IF;
      RETURN FND_API.G_MISS_NUM;
   WHEN fnd_api.g_exc_error THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_account_id'|| p_to_account);
	 FND_MSG_PUB.Add;
      END IF;
      RETURN FND_API.G_MISS_NUM;
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

--  To_Subinventory

FUNCTION To_Subinventory
(  p_organization_id               IN  NUMBER,
   p_to_subinventory               IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(10);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    l_code := p_to_subinventory;
    RETURN l_code;

END To_Subinventory;

--  Transaction_Type

FUNCTION Transaction_Type
(   p_transaction_type              IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_transaction_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_transaction_type

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_type_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Move_Order_Type

FUNCTION Move_Order_Type
(   p_move_order_type              IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_move_order_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_transaction_type

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','move_order_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Move_Order_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Move_Order_Type;

--  From_Locator

FUNCTION From_Locator
(   p_organization_id               IN  NUMBER,
    p_from_locator                  IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_from_locator IS NULL
      OR p_from_locator = FND_API.G_MISS_CHAR
    THEN
        RETURN NULL;
    END IF;

    SELECT  INVENTORY_LOCATION_ID
    INTO    l_id
    FROM    MTL_ITEM_LOCATIONS_KFV
    WHERE   ORGANIZATION_ID = p_organization_id
      AND   CONCATENATED_SEGMENTS = p_from_locator;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','from_locator_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Inventory_Item

FUNCTION Inventory_Item
(  p_organization_id               IN  NUMBER,
   p_inventory_item                IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_inventory_item IS NULL
      OR p_inventory_item = FND_API.G_MISS_CHAR
    THEN
        RETURN NULL;
    END IF;
/*    inv_debug.message('TRO: svid item: '||p_inventory_item|| ' ' || to_char(p_organization_id)); */
    SELECT  INVENTORY_ITEM_ID
    INTO    l_id
    FROM    MTL_SYSTEM_ITEMS_KFV
    WHERE   CONCATENATED_SEGMENTS = p_inventory_item
      AND   ORGANIZATION_ID = p_organization_id;
    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Line

FUNCTION Line
(   p_line                          IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_line IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_line

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Project

FUNCTION Project
(   p_project                       IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_project IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_project

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','project_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Reason

FUNCTION Reason
(   p_reason                        IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_reason IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_reason

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reason_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Reference

FUNCTION Reference
(   p_reference                     IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_reference IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_reference

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reference_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Reference_Type

FUNCTION Reference_Type
(   p_reference_type                IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_reference_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_reference_type

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reference_type_code');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Task

FUNCTION Task
(   p_task                          IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_task IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_task

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','task_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  To_Locator

FUNCTION To_Locator
(  p_organization_id               IN  NUMBER,
   p_to_locator                    IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_to_locator IS NULL
      OR p_to_locator = FND_API.G_MISS_CHAR
    THEN
        RETURN NULL;
    END IF;

    SELECT  INVENTORY_LOCATION_ID
    INTO    l_id
    FROM    MTL_ITEM_LOCATIONS_KFV
    WHERE   ORGANIZATION_ID = p_organization_id
      AND   CONCATENATED_SEGMENTS = p_to_locator;
    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_locator_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Transaction_Header

FUNCTION Transaction_Header
(   p_transaction_header            IN  VARCHAR2
) RETURN NUMBER
IS
l_id                          NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_transaction_header IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_transaction_header

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_header_id');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

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

--  Uom

FUNCTION Uom
(   p_uom                           IN  VARCHAR2
) RETURN VARCHAR2
IS
l_code                        VARCHAR2(3);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_uom IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_uom

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','uom_code');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

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

--  END GEN value_to_id

END INV_Value_To_Id;

/
