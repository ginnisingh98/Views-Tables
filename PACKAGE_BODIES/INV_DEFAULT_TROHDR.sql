--------------------------------------------------------
--  DDL for Package Body INV_DEFAULT_TROHDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DEFAULT_TROHDR" AS
/* $Header: INVDTRHB.pls 120.1 2005/06/17 04:24:30 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_Default_Trohdr';

--  Package global used within the package.
g_trohdr_rec                  INV_Move_Order_PUB.Trohdr_Rec_Type;

--  Cached Header record
g_cache_trohdr_rec            INV_Move_Order_PUB.Trohdr_Rec_Type;

--  Get functions.

FUNCTION Load_Request_Header
(p_header_id       IN NUMBER )
RETURN INV_Move_Order_PUB.Trohdr_Rec_Type
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    /* inv_debug.message('In Load_Request_Header:'||to_char(p_header_id)); */

    IF p_header_id IS NOT NULL THEN

        IF g_cache_Trohdr_rec.header_id = FND_API.G_MISS_NUM OR
           g_cache_Trohdr_rec.header_id <> p_header_id THEN

            g_cache_Trohdr_rec := INV_Trohdr_Util.Query_Row(p_header_id);
	    INV_Globals.g_max_line_num := null;

        END IF;

    END IF;

    RETURN g_cache_Trohdr_rec;

END Load_request_Header;

FUNCTION Get_Date_Required
RETURN DATE
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    RETURN Sysdate;

END Get_Date_Required;

FUNCTION Get_Description
RETURN VARCHAR2
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    RETURN NULL;

END Get_Description;

FUNCTION Get_From_Subinventory
RETURN VARCHAR2
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    RETURN NULL;

END Get_From_Subinventory;

FUNCTION Get_Header(p_organization_id in number)
RETURN NUMBER
IS
l_header_id number := null;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

 If INV_globals.G_CALL_MODE = 'FORM'
 then
	return null;
 end if;

 l_header_id := INV_Transfer_Order_PVT.get_next_header_id(p_organization_id);

 RETURN l_header_id;

END Get_Header;

FUNCTION Get_Header_Status
RETURN NUMBER
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
 IF INV_globals.G_CALL_MODE = 'FORM'
 THEN
    RETURN 1;  /* Incomplete Status */
 ELSE
    RETURN 7;  /* PRE-APPROVED */
 END IF;
END Get_Header_Status;

FUNCTION Get_Organization
RETURN NUMBER
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    RETURN Inv_globals.g_org_id;

END Get_Organization;

FUNCTION Get_Request_Number
RETURN VARCHAR2
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    RETURN NULL;

END Get_Request_Number;

FUNCTION Get_Status_Date
RETURN DATE
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    RETURN Sysdate;

END Get_Status_Date;

FUNCTION Get_To_Account
RETURN NUMBER
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    RETURN NULL;

END Get_To_Account;

FUNCTION Get_To_Subinventory
RETURN VARCHAR2
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    RETURN NULL;

END Get_To_Subinventory;

FUNCTION Get_Move_Order_Type
RETURN NUMBER
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    RETURN 1; /* Move Order Type for Move Order Requisition */

END Get_Move_Order_Type;

FUNCTION Get_Transaction_Type_Id
RETURN NUMBER
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    RETURN 64; /* Move Order Type for Move Order Requisition */

END Get_Transaction_Type_Id;

PROCEDURE Get_Flex_Trohdr
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_trohdr_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute1        := NULL;
    END IF;

    IF g_trohdr_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute10       := NULL;
    END IF;

    IF g_trohdr_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute11       := NULL;
    END IF;

    IF g_trohdr_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute12       := NULL;
    END IF;

    IF g_trohdr_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute13       := NULL;
    END IF;

    IF g_trohdr_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute14       := NULL;
    END IF;

    IF g_trohdr_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute15       := NULL;
    END IF;

    IF g_trohdr_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute2        := NULL;
    END IF;

    IF g_trohdr_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute3        := NULL;
    END IF;

    IF g_trohdr_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute4        := NULL;
    END IF;

    IF g_trohdr_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute5        := NULL;
    END IF;

    IF g_trohdr_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute6        := NULL;
    END IF;

    IF g_trohdr_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute7        := NULL;
    END IF;

    IF g_trohdr_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute8        := NULL;
    END IF;

    IF g_trohdr_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute9        := NULL;
    END IF;

    IF g_trohdr_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.attribute_category := NULL;
    END IF;

END Get_Flex_Trohdr;

--  Procedure Attributes

PROCEDURE Attributes
(   p_trohdr_rec                    IN  INV_Move_Order_PUB.Trohdr_Rec_Type :=
                                        INV_Move_Order_PUB.G_MISS_TROHDR_REC
,   p_iteration                     IN  NUMBER := 1
,   x_trohdr_rec                    OUT NOCOPY /* file.sql.39 change */ INV_Move_Order_PUB.Trohdr_Rec_Type
)
IS
l_org         INV_Validate.ORG;
l_fsub        INV_Validate.SUB;
l_tsub        INV_Validate.SUB;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    --  Check number of iterations.

    IF p_iteration > INV_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','OE_DEF_MAX_ITERATION');
            FND_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;
--   dbms_output.put_line('INV_Validate_default_trohdr iteration');
    --  Initialize g_trohdr_rec

    g_trohdr_rec := p_trohdr_rec;

    --  Default missing attributes.
    IF g_trohdr_rec.date_required = FND_API.G_MISS_DATE THEN
        g_trohdr_rec.date_required := Get_Date_Required;
        IF g_trohdr_rec.date_required IS NOT NULL THEN
            IF INV_Validate_Trohdr.Date_Required(g_trohdr_rec.date_required) = INV_Validate_Trohdr.T
            THEN
                INV_Trohdr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trohdr_Util.G_DATE_REQUIRED
                ,   p_trohdr_rec                  => g_trohdr_rec
                ,   x_trohdr_rec                  => g_trohdr_rec
                );
            ELSE
                g_trohdr_rec.date_required := NULL;
            END IF;
        END IF;
    END IF;

--   dbms_output.put_line('INV_Validate_default_trohdr date required');

    IF g_trohdr_rec.description = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.description := Get_Description;
        IF g_trohdr_rec.description IS NOT NULL THEN
            IF INV_Validate.Description(g_trohdr_rec.description)= INV_Validate.T
            THEN
                INV_Trohdr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trohdr_Util.G_DESCRIPTION
                ,   p_trohdr_rec                  => g_trohdr_rec
                ,   x_trohdr_rec                  => g_trohdr_rec
                );
            ELSE
                g_trohdr_rec.description := NULL;
            END IF;
        END IF;
    END IF;
   -- dbms_output.put_line('INV_Validate_default_trohdr description');

    IF g_trohdr_rec.organization_id = FND_API.G_MISS_NUM THEN

        g_trohdr_rec.organization_id := Get_Organization;
        l_org.organization_id := g_trohdr_rec.organization_id;
        IF g_trohdr_rec.organization_id IS NOT NULL THEN

            IF INV_Validate.Organization(l_org) = INV_Validate.T
            THEN
                INV_Trohdr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trohdr_Util.G_ORGANIZATION
                ,   p_trohdr_rec                  => g_trohdr_rec
                ,   x_trohdr_rec                  => g_trohdr_rec
                );
            ELSE
                g_trohdr_rec.organization_id := NULL;
            END IF;

        END IF;

    END IF;
   -- dbms_output.put_line('INV_Validate_default_trohdr organization');


    IF g_trohdr_rec.from_subinventory_code = FND_API.G_MISS_CHAR THEN

        g_trohdr_rec.from_subinventory_code := Get_From_Subinventory;
        l_fsub.secondary_inventory_name := g_trohdr_rec.from_subinventory_code;
        IF g_trohdr_rec.from_subinventory_code IS NOT NULL THEN

            IF INV_Validate.subinventory(l_fsub,l_org) = INV_Validate.T
            THEN
                INV_Trohdr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trohdr_Util.G_FROM_SUBINVENTORY
                ,   p_trohdr_rec                  => g_trohdr_rec
                ,   x_trohdr_rec                  => g_trohdr_rec
                );
            ELSE
                g_trohdr_rec.from_subinventory_code := NULL;
            END IF;

        END IF;

    END IF;
   -- dbms_output.put_line('INV_Validate_default_trohdr from subinventory');

    IF g_trohdr_rec.header_id = FND_API.G_MISS_NUM THEN
        g_trohdr_rec.header_id := Get_Header(g_trohdr_rec.organization_id);
        IF g_trohdr_rec.header_id IS NOT NULL THEN
            IF INV_Validate_Trohdr.Header(g_trohdr_rec.header_id) = INV_Validate_Trohdr.T
            THEN
                INV_Trohdr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trohdr_Util.G_HEADER
                ,   p_trohdr_rec                  => g_trohdr_rec
                ,   x_trohdr_rec                  => g_trohdr_rec
                );
            ELSE
                g_trohdr_rec.header_id := NULL;
            END IF;
            IF g_trohdr_rec.request_number = FND_API.G_MISS_CHAR THEN
	      g_trohdr_rec.request_number  := to_char(g_trohdr_rec.header_id);
            END IF;
        END IF;
    END IF;
   -- dbms_output.put_line('INV_Validate_default_trohdr header');

    IF g_trohdr_rec.header_status = FND_API.G_MISS_NUM THEN
        g_trohdr_rec.header_status := Get_Header_Status;
        IF g_trohdr_rec.header_status IS NOT NULL THEN
            IF INV_Validate_Trohdr.Header_Status(g_trohdr_rec.header_status) = INV_Validate_Trohdr.T
            THEN
                INV_Trohdr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trohdr_Util.G_HEADER_STATUS
                ,   p_trohdr_rec                  => g_trohdr_rec
                ,   x_trohdr_rec                  => g_trohdr_rec
                );
            ELSE
                g_trohdr_rec.header_status := NULL;
            END IF;
        END IF;
    END IF;
   -- dbms_output.put_line('INV_Validate_default_trohdr header status');

    IF g_trohdr_rec.request_number = FND_API.G_MISS_CHAR THEN
        g_trohdr_rec.request_number := Get_Request_Number;
        IF g_trohdr_rec.request_number IS NOT NULL THEN
            IF INV_Validate_Trohdr.Request_Number(g_trohdr_rec.request_number,
                            l_org) = INV_Validate_Trohdr.T
            THEN
                INV_Trohdr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trohdr_Util.G_REQUEST_NUMBER
                ,   p_trohdr_rec                  => g_trohdr_rec
                ,   x_trohdr_rec                  => g_trohdr_rec
                );
            ELSE
                g_trohdr_rec.request_number := NULL;
            END IF;
        END IF;
    END IF;
   -- dbms_output.put_line('INV_Validate_default_trohdr request number');

    IF g_trohdr_rec.status_date = FND_API.G_MISS_DATE THEN

        g_trohdr_rec.status_date := Get_Status_Date;

        IF g_trohdr_rec.status_date IS NOT NULL THEN

            IF INV_Validate_Trohdr.Status_Date(g_trohdr_rec.status_date) = INV_Validate_Trohdr.T
            THEN
                INV_Trohdr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trohdr_Util.G_STATUS_DATE
                ,   p_trohdr_rec                  => g_trohdr_rec
                ,   x_trohdr_rec                  => g_trohdr_rec
                );
            ELSE
                g_trohdr_rec.status_date := NULL;
            END IF;

        END IF;

    END IF;
   -- dbms_output.put_line('INV_Validate_default_trohdr status date');

    IF g_trohdr_rec.to_account_id = FND_API.G_MISS_NUM THEN

        g_trohdr_rec.to_account_id := Get_To_Account;

        IF g_trohdr_rec.to_account_id IS NOT NULL THEN

            IF INV_Validate.To_Account(g_trohdr_rec.to_account_id) = INV_Validate.T
            THEN
                INV_Trohdr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trohdr_Util.G_TO_ACCOUNT
                ,   p_trohdr_rec                  => g_trohdr_rec
                ,   x_trohdr_rec                  => g_trohdr_rec
                );
            ELSE
                g_trohdr_rec.to_account_id := NULL;
            END IF;

        END IF;

    END IF;
   -- dbms_output.put_line('INV_Validate_default_trohdr to account');

    IF g_trohdr_rec.to_subinventory_code = FND_API.G_MISS_CHAR THEN

        g_trohdr_rec.to_subinventory_code := Get_To_Subinventory;
        l_tsub.secondary_inventory_name := g_trohdr_rec.to_subinventory_code;
        IF g_trohdr_rec.to_subinventory_code IS NOT NULL THEN

            IF INV_Validate.subinventory(l_tsub,l_org) = INV_Validate.T
            THEN
                INV_Trohdr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trohdr_Util.G_TO_SUBINVENTORY
                ,   p_trohdr_rec                  => g_trohdr_rec
                ,   x_trohdr_rec                  => g_trohdr_rec
                );
            ELSE
                g_trohdr_rec.to_subinventory_code := NULL;
            END IF;

        END IF;

    END IF;
   -- dbms_output.put_line('INV_Validate_default_trohdr to subinventory');

    IF g_trohdr_rec.move_order_type = FND_API.G_MISS_NUM THEN

        g_trohdr_rec.move_order_type := Get_Move_Order_Type;

        IF g_trohdr_rec.move_order_type IS NOT NULL THEN

            /*IF INV_Validate.Move_Order_Type(g_trohdr_rec.move_order_type)
            THEN*/
                INV_Trohdr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trohdr_Util.G_MOVE_ORDER_TYPE
                ,   p_trohdr_rec                  => g_trohdr_rec
                ,   x_trohdr_rec                  => g_trohdr_rec
                );
            --ELSE
            --    g_trohdr_rec.move_order_type := NULL;
           -- END IF;
        END IF;
    END IF;
   -- dbms_output.put_line('INV_Validate_default_trohdr move oreders');

    IF g_trohdr_rec.transaction_type_id = FND_API.G_MISS_NUM THEN

        g_trohdr_rec.transaction_type_id := Get_Transaction_type_id;

        IF g_trohdr_rec.transaction_type_id IS NOT NULL THEN

            /*IF INV_Validate.Move_Order_Type(g_trohdr_rec.move_order_type)
            THEN*/
                INV_Trohdr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trohdr_Util.G_TRANSACTION_TYPE
                ,   p_trohdr_rec                  => g_trohdr_rec
                ,   x_trohdr_rec                  => g_trohdr_rec
                );
            --ELSE
            --    g_trohdr_rec.move_order_type := NULL;
           -- END IF;
        END IF;
    END IF;

    IF g_trohdr_rec.ship_to_location_id = FND_API.G_MISS_NUM THEN
       g_trohdr_rec.ship_to_location_id := NULL; --  nothing to default;
    END IF;


   -- dbms_output.put_line('INV_Validate_default_trohdr transaction type');

    IF g_trohdr_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute_category = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Trohdr;

    END IF;

    IF g_trohdr_rec.created_by = FND_API.G_MISS_NUM THEN

       g_trohdr_rec.created_by := NULL;
       -- dbms_output.put_line('INV_Validate_default_trohdr created by null');

    END IF;

    IF g_trohdr_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_trohdr_rec.creation_date := NULL;
       -- dbms_output.put_line('INV_Validate_default_trohdr creation date null');

    END IF;

    IF g_trohdr_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_trohdr_rec.last_updated_by := NULL;
       -- dbms_output.put_line('INV_Validate_default_trohdr updated by null');

    END IF;

    IF g_trohdr_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_trohdr_rec.last_update_date := NULL;
       -- dbms_output.put_line('INV_Validate_default_trohdr update date null');

    END IF;

    IF g_trohdr_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_trohdr_rec.last_update_login := NULL;
       -- dbms_output.put_line('INV_Validate_default_trohdr last update login null');

    END IF;

    IF g_trohdr_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_trohdr_rec.program_application_id := NULL;
       -- dbms_output.put_line('INV_Validate_default_trohdr application id null');

    END IF;

    IF g_trohdr_rec.program_id = FND_API.G_MISS_NUM THEN

        g_trohdr_rec.program_id := NULL;
       -- dbms_output.put_line('INV_Validate_default_trohdr program id null');

    END IF;

    IF g_trohdr_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_trohdr_rec.program_update_date := NULL;
       -- dbms_output.put_line('INV_Validate_default_trohdr program update null');

    END IF;

    IF g_trohdr_rec.request_id = FND_API.G_MISS_NUM THEN

        g_trohdr_rec.request_id := NULL;
       -- dbms_output.put_line('INV_Validate_default_trohdr request null');

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_trohdr_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.attribute_category = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.created_by = FND_API.G_MISS_NUM
    OR  g_trohdr_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_trohdr_rec.date_required = FND_API.G_MISS_DATE
    OR  g_trohdr_rec.description = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.from_subinventory_code = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.header_id = FND_API.G_MISS_NUM
    OR  g_trohdr_rec.header_status = FND_API.G_MISS_NUM
    OR  g_trohdr_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_trohdr_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_trohdr_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_trohdr_rec.organization_id = FND_API.G_MISS_NUM
    OR  g_trohdr_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_trohdr_rec.program_id = FND_API.G_MISS_NUM
    OR  g_trohdr_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_trohdr_rec.request_id = FND_API.G_MISS_NUM
    OR  g_trohdr_rec.request_number = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.status_date = FND_API.G_MISS_DATE
    OR  g_trohdr_rec.to_account_id = FND_API.G_MISS_NUM
    OR  g_trohdr_rec.to_subinventory_code = FND_API.G_MISS_CHAR
    OR  g_trohdr_rec.move_order_type = FND_API.G_MISS_NUM
    OR  g_trohdr_rec.transaction_type_id = FND_API.G_MISS_NUM
    THEN
       -- dbms_output.put_line('INV_Validate_default_trohdr big null');

        INV_Default_Trohdr.Attributes
        (   p_trohdr_rec                  => g_trohdr_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_trohdr_rec                  => x_trohdr_rec
        );

    ELSE

        --  Done defaulting attributes

        x_trohdr_rec := g_trohdr_rec;

    END IF;

END Attributes;

END INV_Default_Trohdr;

/
