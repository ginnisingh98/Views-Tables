--------------------------------------------------------
--  DDL for Package Body INV_DEFAULT_TROLIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DEFAULT_TROLIN" AS
/* $Header: INVDTRLB.pls 120.6.12010000.2 2009/04/29 11:59:52 asugandh ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_Default_Trolin';

--  Package global used within the package.

g_trolin_rec                  INV_Move_Order_PUB.Trolin_Rec_Type;
g_max_line_num_header_id      number := null;

--  Get functions.

FUNCTION Get_Date_Required
RETURN DATE
IS
l_trohdr_rec      INV_Move_Order_PUB.Trohdr_Rec_Type;
BEGIN
    RETURN NULL;

END Get_Date_Required;

FUNCTION Get_From_Locator
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_From_Locator;


FUNCTION Get_From_Subinventory_Id
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_From_Subinventory_Id;


FUNCTION Get_From_Subinventory
RETURN VARCHAR2
IS
l_trohdr_rec      INV_Move_Order_PUB.Trohdr_Rec_Type;
BEGIN
    RETURN NULL;

END Get_From_Subinventory;

/*
FUNCTION Get_Header
RETURN NUMBER
IS
BEGIN
-- -------------------------------------------------------
   RETURN INV_Validate.g_TRO_GlobalAttributes.header_id;
END Get_Header;
  */

FUNCTION Get_Inventory_Item
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Inventory_Item;

FUNCTION Get_Line
RETURN NUMBER
IS
l_line_id number := null;
BEGIN

        SELECT  MTL_TXN_REQUEST_LINES_S.NEXTVAL
        INTO    l_line_id
        FROM    DUAL;

	/* inv_debug.message(to_char(l_line_id)); */

    RETURN l_line_id;

END Get_Line;


FUNCTION Get_Line_Number
RETURN NUMBER
IS
  l_trohdr_rec      INV_Move_Order_PUB.Trohdr_Rec_Type;
  --Bug #4347016
  --Initialized Max Line Number to the global variable
/*Fixed for bug#7126566
  Initialization of variable l_max_line_num is done in body.
*/
  l_max_line_num    number;
BEGIN

/*Fixed for bug#7126566
   Initialization of variable l_max_line_num is made conditional.
   This is done to ensure that line number is incremented properly.
  The process to increment line number is this:
  When called by FORM
   Form will increate the line number (global variable -INV_Globals.g_max_line_num)
   by calling the inv_trnasfer_order_pvt.increment_max_line_number.
   This ensure that when user goes from one line to another it does not
   increase line number unnecessarily.

  When called by API
   Function Get_Line_Number will increase the line number and would generate
   unique line number.
*/
  if G_CALLED_BY_FORM = 'Y'  then
     l_max_line_num := 0;
   --This will ensure that variable is reset for next call . Form set this to Y before calling.
   --
   G_CALLED_BY_FORM := 'N';

  else
     l_max_line_num    := NVL(INV_Globals.g_max_line_num, 0);
  end if;


/*     inv_debug.message('In Get Line Num for header id:'||to_char(g_trolin_rec.header_id)); */
/*    inv_debug.message('Prev header id:'||to_char(g_max_line_num_header_id)); */
    IF g_trolin_rec.header_id IS NOT NULL AND
        g_trolin_rec.header_id <> FND_API.G_MISS_NUM
    THEN
/*
        l_trohdr_rec :=
        INV_default_Trohdr.Load_Request_header(g_trolin_rec.header_id );
*/


        If INV_Globals.g_max_line_num is null
        or g_max_line_num_header_id <> g_trolin_rec.header_id
        Then

		SELECT nvl(max(line_number), 0)
		INTO   l_max_line_num
		FROM   mtl_txn_request_lines_v
		WHERE  header_id = g_trolin_rec.header_id;


		g_max_line_num_header_id := g_trolin_rec.header_id;
                INV_Globals.g_max_line_num := l_max_line_num + 1;

        End If;

       IF (l_max_line_num >= nvl(INV_Globals.g_max_line_num,0)) THEN

           INV_Globals.g_max_line_num := 1 + l_max_line_num;

       END IF;

/*       inv_debug.message('D:'||to_char(INV_GLOBALS.g_max_line_num)); */
       return INV_Globals.g_max_line_num;
   end if;
/*   inv_debug.message('Returning null'); */
   return null;
END Get_Line_Number;

FUNCTION Get_Line_Status
RETURN NUMBER
IS
BEGIN
 IF INV_globals.G_CALL_MODE = 'FORM'
 THEN
    RETURN 1;  /* Incomplete Status */
 ELSE
    RETURN 7;  /* PRE-APPROVED */
 END IF;
END Get_Line_Status;

FUNCTION Get_Lot_Number
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Lot_Number;

FUNCTION Get_Organization
RETURN NUMBER
IS
BEGIN

    RETURN Inv_globals.g_org_id;

END Get_Organization;

FUNCTION Get_Project
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Project;

FUNCTION Get_Quantity
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Quantity;

FUNCTION Get_Quantity_Delivered
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Quantity_Delivered;

FUNCTION Get_Quantity_Detailed
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Quantity_Detailed;

FUNCTION Get_Reason
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Reason;

--FUNCTION Get_Reference
--RETURN VARCHAR2
--IS
--BEGIN
--
--    RETURN NULL;
--
--END Get_Reference;

FUNCTION Get_Reference
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Reference;

FUNCTION Get_Reference_Type
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Reference_Type;

FUNCTION Get_Revision
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Revision;

FUNCTION Get_Serial_Number_End
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Serial_Number_End;

FUNCTION Get_Serial_Number_Start
RETURN VARCHAR2
IS
BEGIN
 RETURN NULL;

END Get_Serial_Number_Start;

FUNCTION Get_Status_Date
 RETURN DATE
 IS
 BEGIN
    RETURN Sysdate;

END Get_Status_Date;

FUNCTION Get_Task
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Task;

FUNCTION Get_To_Account
RETURN NUMBER
IS
l_trohdr_rec      INV_Move_Order_PUB.Trohdr_Rec_Type;
BEGIN
/*
    IF g_trolin_rec.header_id IS NOT NULL AND
        g_trolin_rec.header_id <> FND_API.G_MISS_NUM
    THEN
        l_trohdr_rec :=
        INV_default_Trohdr.Load_Request_header(g_trolin_rec.header_id );

        IF l_trohdr_rec.to_account_id IS NOT NULL THEN
            RETURN l_trohdr_rec.to_account_id;
        END IF;

    END IF;
*/
    RETURN NULL;

END Get_To_Account;

FUNCTION Get_To_Locator
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_To_Locator;

FUNCTION Get_To_Subinventory_Id
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_To_Subinventory_Id;

FUNCTION Get_To_Subinventory
RETURN VARCHAR2
IS
l_trohdr_rec      INV_Move_Order_PUB.Trohdr_Rec_Type;
BEGIN
/*
    IF g_trolin_rec.header_id IS NOT NULL AND
        g_trolin_rec.header_id <> FND_API.G_MISS_NUM
    THEN
        l_trohdr_rec :=
        INV_default_Trohdr.Load_Request_header(g_trolin_rec.header_id );

        IF l_trohdr_rec.to_subinventory_code IS NOT NULL THEN
            RETURN l_trohdr_rec.to_subinventory_code;
        END IF;

    END IF;
*/

    RETURN NULL;

END Get_To_Subinventory;

FUNCTION Get_Transaction_Header
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Transaction_Header;

FUNCTION Get_Uom
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Uom;

FUNCTION Get_Transaction_Type_Id
RETURN NUMBER
IS
BEGIN
	RETURN 64; /* Subinventory Transfer */
END Get_Transaction_Type_Id;

FUNCTION Get_To_Organization_Id
RETURN NUMBER
IS
BEGIN
    Return Inv_globals.g_org_id;
END Get_To_Organization_Id;


FUNCTION Get_Primary_Quantity
RETURN NUMBER
IS
BEGIN
    Return NULL;
END Get_Primary_Quantity;

FUNCTION Get_Txn_Source_Id
RETURN NUMBER
IS
BEGIN
    Return NULL;
END Get_Txn_Source_Id;

FUNCTION Get_Txn_Source_Line_Id
RETURN NUMBER
IS
BEGIN
    Return NULL;
END Get_Txn_Source_Line_Id;

FUNCTION Get_Txn_Source_Line_Detail_Id
RETURN NUMBER
IS
BEGIN
    Return NULL;
END Get_Txn_Source_Line_Detail_Id;

FUNCTION Get_Transaction_Source_Type_ID(p_transaction_type_id in NUMBER)
RETURN NUMBER
IS
   l_transaction_source_type_id NUMBER;
BEGIN
    select transaction_source_type_id
    into l_transaction_source_type_id
    from mtl_transaction_types
    where transaction_type_id = p_transaction_type_id;

    Return l_transaction_source_type_id;
END Get_Transaction_Source_Type_ID;

FUNCTION Get_Pick_Strategy_ID
RETURN NUMBER
IS
BEGIN
    Return NULL;
END Get_Pick_Strategy_ID;

FUNCTION Get_Put_Away_Strategy_ID
RETURN NUMBER
IS
BEGIN
    Return NULL;
END Get_Put_Away_Strategy_ID;

FUNCTION Get_Unit_Number
RETURN Varchar2
IS
BEGIN
    Return NULL;
END Get_Unit_Number;

PROCEDURE Get_Flex_Trolin
  IS
BEGIN

   --  In the future call Flex APIs for defaults

   IF g_trolin_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      g_trolin_rec.attribute1        := NULL;
   END IF;

   IF g_trolin_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute10       := NULL;
   END IF;

   IF g_trolin_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      g_trolin_rec.attribute11       := NULL;
   END IF;

   IF g_trolin_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      g_trolin_rec.attribute12       := NULL;
   END IF;

    IF g_trolin_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute13       := NULL;
    END IF;

    IF g_trolin_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute14       := NULL;
    END IF;

    IF g_trolin_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute15       := NULL;
    END IF;

    IF g_trolin_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute2        := NULL;
    END IF;

    IF g_trolin_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute3        := NULL;
    END IF;

    IF g_trolin_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute4        := NULL;
    END IF;

    IF g_trolin_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute5        := NULL;
    END IF;

    IF g_trolin_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute6        := NULL;
    END IF;

    IF g_trolin_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute7        := NULL;
    END IF;

    IF g_trolin_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute8        := NULL;
    END IF;

    IF g_trolin_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute9        := NULL;
    END IF;

    IF g_trolin_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.attribute_category := NULL;
    END IF;

END Get_Flex_Trolin;
--INVCONV Added for Convergence
FUNCTION Get_Sec_Quantity
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Sec_Quantity;

FUNCTION Get_Sec_Quantity_Delivered
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Sec_Quantity_Delivered;

FUNCTION Get_Sec_Quantity_Detailed
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Sec_Quantity_Detailed;

FUNCTION Get_Secondary_Uom
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Secondary_Uom;

FUNCTION Get_Grade_Code
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Grade_Code;


PROCEDURE convert_quantity
(   x_return_status OUT NOCOPY VARCHAR2,
    p_trolin_rec IN OUT NOCOPY inv_move_order_pub.trolin_rec_type) IS
    l_return_status              VARCHAR2(1):= fnd_api.g_ret_sts_success;
    l_primary_uom_code           VARCHAR2(3);
    l_tmp_secondary_quantity     NUMBER     := NULL; -- INVCONV
    l_tmp_quantity               NUMBER     := NULL;
    l_tracking_quantity_ind      MTL_SYSTEM_ITEMS.tracking_quantity_ind%TYPE;   --INVCONV
    l_secondary_default_ind      MTL_SYSTEM_ITEMS.secondary_default_ind%TYPE;   --INVCONV
  BEGIN
    l_return_status := 'S';
    -- INVCONV - Retrieve secondary uom
    IF p_trolin_rec.uom_code IS NULL or p_trolin_rec.secondary_uom IS NULL THEN
       SELECT primary_uom_code, secondary_uom_code,tracking_quantity_ind, secondary_default_ind
         INTO p_trolin_rec.uom_code,
              p_trolin_rec.secondary_uom,
              l_tracking_quantity_ind,
              l_secondary_default_ind
         FROM mtl_system_items
        WHERE inventory_item_id = p_trolin_rec.inventory_item_id
          AND organization_id = p_trolin_rec.organization_id;
    END IF;

    /* it's possible that Secondary UOM is defined for the item but the item is tracked only in Primary */
    IF(l_tracking_quantity_ind <> 'PS')  THEN --INVCONV
      p_trolin_rec.secondary_uom := NULL;
    END IF;

    -- INVCONV BEGIN
         -- If dual control and secondary quantity is missing, calculate it
         IF p_trolin_rec.secondary_uom IS NOT NULL AND
           nvl(p_trolin_rec.secondary_quantity,0) = 0 AND ( l_secondary_default_ind in('F','D') ) THEN
           l_tmp_secondary_quantity  := inv_convert.inv_um_convert(
                                         item_id                      => p_trolin_rec.inventory_item_id
                                       , lot_number                => p_trolin_rec.lot_number
                                       , organization_id          => p_trolin_rec.organization_id
                                       , PRECISION              => NULL -- use default precision
                                       , from_quantity            => p_trolin_rec.quantity
                                      , from_unit                   => p_trolin_rec.uom_code
                                      , to_unit                       => p_trolin_rec.secondary_uom
                                      , from_name                 => NULL -- from uom name
                                       , to_name                   => NULL -- to uom name
                                       );

          IF l_tmp_secondary_quantity = -99999 THEN
               -- conversion failed
               fnd_message.set_name('INV', 'CAN-NOT-CONVERT-TO-SECOND-UOM'); -- INVCONV NEW MESSAGE
               fnd_msg_pub.ADD;
               l_return_status  := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
           END IF;
           p_trolin_rec.secondary_quantity  := l_tmp_secondary_quantity; -- INVCONV
         END IF;

         -- INVCONV END
    x_return_status  := l_return_status;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
    --
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      --
/*      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Convert_Quantity');
      END IF; */
  END convert_quantity;


--INVCONV Added for Convergence

--  Procedure Attributes

PROCEDURE Attributes
(   p_trolin_rec                    IN  INV_Move_Order_PUB.Trolin_Rec_Type :=
                                        INV_Move_Order_PUB.G_MISS_TROLIN_REC
,   p_iteration                     IN  NUMBER := 1
,   x_trolin_rec                    OUT NOCOPY INV_Move_Order_PUB.Trolin_Rec_Type
)
  IS
     l_org      inv_validate.org;
     l_item     inv_validate.item;
     l_fsub     inv_validate.sub;
     l_tsub     inv_validate.sub;
     l_floc     inv_validate.locator;
     l_tloc     inv_validate.locator;
     l_lot      inv_validate.lot;
     l_serial   inv_validate.serial;
     l_trans    inv_validate.transaction;
     l_acct_txn NUMBER;

     l_mov_order_type                   NUMBER;
     l_return_status                    VARCHAR2(1) := fnd_api.g_ret_sts_success;

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

    --  Initialize g_trolin_rec

    g_trolin_rec := p_trolin_rec;

    --  Default missing attributes.

    -- Changes for bug 6441724
    IF (g_trolin_rec.operation = inv_globals.g_opr_create)
     AND (g_trolin_rec.project_id = FND_API.G_MISS_NUM )
     AND (g_trolin_rec.to_locator_id IS NOT NULL)
     AND (g_trolin_rec.to_locator_id <> FND_API.G_MISS_NUM)
      THEN
	select project_id,task_id
	into g_trolin_rec.project_id,g_trolin_rec.task_id
	from mtl_item_locations
	where inventory_location_id = g_trolin_rec.to_locator_id;
	IF g_trolin_rec.project_id IS NULL THEN
    		g_trolin_rec.project_id := FND_API.G_MISS_NUM;
   		g_trolin_rec.task_id := FND_API.G_MISS_NUM;
   	END IF;
    END IF;


    IF g_trolin_rec.organization_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.organization_id := Get_Organization;

        IF g_trolin_rec.organization_id IS NOT NULL THEN

	   l_org.organization_id := g_trolin_rec.organization_id;
            IF INV_Validate.Organization(l_org) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_ORGANIZATION
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.organization_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.inventory_item_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.inventory_item_id := Get_Inventory_Item;

        IF g_trolin_rec.inventory_item_id IS NOT NULL THEN

	   l_item.inventory_item_id := g_trolin_rec.inventory_item_id;
            IF INV_Validate.Inventory_Item(l_item, l_org)
	     = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_INVENTORY_ITEM
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.inventory_item_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.transaction_type_id = FND_API.G_MISS_NUM THEN
       g_trolin_rec.transaction_type_id := Get_Transaction_Type_Id;
    END IF;
    IF g_trolin_rec.transaction_type_id IS NOT NULL THEN
       l_trans.transaction_type_id := g_trolin_rec.transaction_type_id;
       IF INV_Validate.Transaction_Type(l_trans) = inv_validate.T
       THEN
         INV_Trolin_Util.Clear_Dependent_Attr
	 (   p_attr_id               => INV_Trolin_Util.G_TRANSACTION_TYPE_ID
	  ,   p_trolin_rec           => g_trolin_rec
	  ,   x_trolin_rec           => g_trolin_rec
	  );
       ELSE
         g_trolin_rec.transaction_type_id := NULL;
       END IF;
       INV_Validate_Trolin.g_transaction_l := l_trans;
    END IF;

    IF l_trans.transaction_action_id = 1 THEN
       l_acct_txn := 1;
    ELSE
       l_acct_txn := 0;
    END IF;

    IF g_trolin_rec.date_required = FND_API.G_MISS_DATE THEN

        g_trolin_rec.date_required := Get_Date_Required;

        IF g_trolin_rec.date_required IS NOT NULL THEN

            IF INV_Validate_Trohdr.Date_Required(g_trolin_rec.date_required) = INV_Validate_Trohdr.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_DATE_REQUIRED
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.date_required := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.from_subinventory_code = FND_API.G_MISS_CHAR THEN

        g_trolin_rec.from_subinventory_code := Get_From_Subinventory;

        IF g_trolin_rec.from_subinventory_code IS NOT NULL THEN
	   l_fsub.secondary_inventory_name := g_trolin_rec.from_subinventory_code;
            IF
	      INV_Validate.From_Subinventory(l_fsub,l_org,l_item,l_acct_txn) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_FROM_SUBINVENTORY
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );

            ELSE
                g_trolin_rec.from_subinventory_code := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.from_subinventory_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.from_subinventory_id := Get_From_Subinventory_Id;

        IF g_trolin_rec.from_subinventory_id IS NOT NULL THEN
	   l_fsub.secondary_inventory_name := g_trolin_rec.from_subinventory_code;
	   IF
	     INV_Validate.From_Subinventory(l_fsub,l_org,l_item,l_acct_txn) = inv_validate.T

            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_FROM_SUBINVENTORY
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.from_subinventory_id := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.from_locator_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.from_locator_id := Get_From_Locator;

        IF g_trolin_rec.from_locator_id IS NOT NULL THEN

	   l_floc.inventory_location_id := g_trolin_rec.from_locator_id;
            IF INV_Validate.From_Locator(l_floc,l_org,l_item,l_fsub,g_trolin_rec.project_id,g_trolin_rec.task_id,l_trans.transaction_action_id) =
	      inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_FROM_LOCATOR
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.from_locator_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.line_id = FND_API.G_MISS_NUM THEN

        /* inv_debug.message('Calling Get Line'); */
        g_trolin_rec.line_id := Get_Line;

        IF g_trolin_rec.line_id IS NOT NULL THEN

            IF INV_Validate_trolin.Line(g_trolin_rec.line_id) = inv_validate_trolin.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_LINE
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.line_number = FND_API.G_MISS_NUM THEN

        g_trolin_rec.line_number := Get_Line_Number;

        IF g_trolin_rec.line_number IS NOT NULL THEN

	   IF INV_Validate_trolin.Line_Number(g_trolin_rec.line_number,
					      g_trolin_rec.header_id,
					      l_org) = inv_validate_trolin.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_LINE_NUMBER
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.line_number := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.line_status = FND_API.G_MISS_NUM THEN

        g_trolin_rec.line_status := Get_Line_Status;

        IF g_trolin_rec.line_status IS NOT NULL THEN

            IF INV_Validate_trolin.Line_Status(g_trolin_rec.line_status) = inv_validate_trolin.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_LINE_STATUS
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.line_status := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.lot_number = FND_API.G_MISS_CHAR THEN

        g_trolin_rec.lot_number := Get_Lot_Number;

        IF g_trolin_rec.lot_number IS NOT NULL THEN

	   l_lot.lot_number := g_trolin_rec.lot_number;
	   --Added to call new lot number function if putaway move order
	   -- this is because on hand might not have this lot already
	   -- in the case of a putaway move order

	   SELECT move_order_type INTO l_mov_order_type
	     FROM   mtl_txn_request_headers
	     WHERE header_id=g_trolin_rec.header_id;

	   IF l_mov_order_type=INV_GLOBALS.g_move_order_put_away
	     THEN

	      IF INV_Validate.Lot_Number(l_lot, l_org, l_item) = inv_validate.T THEN
		 INV_Trolin_Util.Clear_Dependent_Attr
		   (   p_attr_id                     => INV_Trolin_Util.G_LOT_NUMBER
		   ,   p_trolin_rec                  => g_trolin_rec
		   ,   x_trolin_rec                  => g_trolin_rec
		   );
	       ELSE
		 g_trolin_rec.lot_number := NULL;
	      END IF;

	    ELSE

	      IF INV_Validate.Lot_Number(l_lot,l_org,l_item,l_fsub,l_floc,g_trolin_rec.revision) = inv_validate.T
		THEN
		 INV_Trolin_Util.Clear_Dependent_Attr
		   (   p_attr_id                     => INV_Trolin_Util.G_LOT_NUMBER
		   ,   p_trolin_rec                  => g_trolin_rec
		   ,   x_trolin_rec                  => g_trolin_rec
		   );
	       ELSE
		 g_trolin_rec.lot_number := NULL;
	      END IF;
	   END IF;
        END IF;

    END IF;

    IF g_trolin_rec.project_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.project_id := Get_Project;

        IF g_trolin_rec.project_id IS NOT NULL THEN

            IF INV_Validate.Project(g_trolin_rec.project_id) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_PROJECT
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.project_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.quantity = FND_API.G_MISS_NUM THEN

        g_trolin_rec.quantity := Get_Quantity;

        IF g_trolin_rec.quantity IS NOT NULL THEN

            IF INV_Validate.Quantity(g_trolin_rec.quantity) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_QUANTITY
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.quantity := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.quantity_delivered = FND_API.G_MISS_NUM THEN

        g_trolin_rec.quantity_delivered := Get_Quantity_Delivered;

        IF g_trolin_rec.quantity_delivered IS NOT NULL THEN

            IF
	      INV_Validate_trolin.Quantity_Delivered(g_trolin_rec.quantity_delivered) = inv_validate_trolin.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_QUANTITY_DELIVERED
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.quantity_delivered := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.quantity_detailed = FND_API.G_MISS_NUM THEN

        g_trolin_rec.quantity_detailed := Get_Quantity_Detailed;

        IF g_trolin_rec.quantity_detailed IS NOT NULL THEN

            IF
	      INV_Validate_trolin.Quantity_Detailed(g_trolin_rec.quantity_detailed) = inv_validate_trolin.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_QUANTITY_DETAILED
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.quantity_detailed := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.reason_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.reason_id := Get_Reason;

        IF g_trolin_rec.reason_id IS NOT NULL THEN

            IF INV_Validate.Reason(g_trolin_rec.reason_id) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_REASON
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.reason_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.reference = FND_API.G_MISS_CHAR THEN

        g_trolin_rec.reference := Get_Reference;

        IF g_trolin_rec.reference IS NOT NULL THEN

            IF INV_Validate.Reference(g_trolin_rec.reference) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_REFERENCE
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.reference := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.reference_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.reference_id := Get_Reference;

        IF g_trolin_rec.reference_id IS NOT NULL THEN

            IF INV_Validate.Reference(g_trolin_rec.reference_id,g_trolin_rec.reference_type_code) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_REFERENCE
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.reference_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.reference_type_code = FND_API.G_MISS_NUM THEN

        g_trolin_rec.reference_type_code := Get_Reference_Type;

        IF g_trolin_rec.reference_type_code IS NOT NULL THEN

            IF
	      INV_Validate.Reference_Type(g_trolin_rec.reference_type_code)
	      = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_REFERENCE_TYPE
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.reference_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.revision = FND_API.G_MISS_CHAR THEN

        g_trolin_rec.revision := Get_Revision;

        IF g_trolin_rec.revision IS NOT NULL THEN

            IF INV_Validate.Revision(g_trolin_rec.revision,l_org,l_item) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_REVISION
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.revision := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.serial_number_end = FND_API.G_MISS_CHAR THEN

        g_trolin_rec.serial_number_end := Get_Serial_Number_End;

        IF g_trolin_rec.serial_number_end IS NOT NULL THEN

	   l_serial.serial_number := g_trolin_rec.serial_number_end;
            IF
	      INV_Validate.Serial_Number_End(l_serial,l_org,l_item,l_fsub,l_lot,l_floc,g_trolin_rec.revision) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_SERIAL_NUMBER_END
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.serial_number_end := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.serial_number_start = FND_API.G_MISS_CHAR THEN

        g_trolin_rec.serial_number_start := Get_Serial_Number_Start;

        IF g_trolin_rec.serial_number_start IS NOT NULL THEN

	   l_serial.serial_number := g_trolin_rec.serial_number_start;
            IF
	      INV_Validate.Serial_Number_Start(l_serial,l_org,l_item,l_fsub,l_lot,l_floc,g_trolin_rec.revision) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_SERIAL_NUMBER_START
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.serial_number_start := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.status_date = FND_API.G_MISS_DATE THEN

        g_trolin_rec.status_date := Get_Status_Date;

        IF g_trolin_rec.status_date IS NOT NULL THEN

            IF INV_Validate_Trohdr.Status_Date(g_trolin_rec.status_date) = inv_validate_trohdr.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_STATUS_DATE
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.status_date := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.task_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.task_id := Get_Task;

        IF g_trolin_rec.task_id IS NOT NULL THEN

            IF INV_Validate.Task(g_trolin_rec.task_id,g_trolin_rec.project_id) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_TASK
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.task_id := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.to_account_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.to_account_id := Get_To_Account;

        IF g_trolin_rec.to_account_id IS NOT NULL THEN

            IF INV_Validate.To_Account(g_trolin_rec.to_account_id) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_TO_ACCOUNT
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.to_account_id := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.to_locator_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.to_locator_id := Get_To_Locator;

        IF g_trolin_rec.to_locator_id IS NOT NULL THEN
	   l_tloc.inventory_location_id := g_trolin_rec.to_locator_id;
            IF
	      INV_Validate.To_Locator(l_tloc,l_org,l_item,l_tsub,g_trolin_rec.project_id, g_trolin_rec.task_id,l_trans.transaction_action_id) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_TO_LOCATOR
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.to_locator_id := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.to_subinventory_code = FND_API.G_MISS_CHAR THEN

        g_trolin_rec.to_subinventory_code := Get_To_Subinventory;

        IF g_trolin_rec.to_subinventory_code IS NOT NULL THEN

	   l_tsub.secondary_inventory_name := g_trolin_rec.to_subinventory_code;
	   IF
	      INV_Validate.To_Subinventory(l_tsub,l_org,l_item,l_fsub,l_acct_txn) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_TO_SUBINVENTORY
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.to_subinventory_code := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.to_subinventory_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.to_subinventory_id := Get_To_Subinventory_Id;

        IF g_trolin_rec.to_subinventory_id IS NOT NULL THEN
	   l_tsub.secondary_inventory_name := g_trolin_rec.to_subinventory_code;
	   IF
	      INV_Validate.To_Subinventory(l_tsub,l_org,l_item,l_fsub,l_acct_txn) = inv_validate.T

            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_TO_SUBINVENTORY
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.to_subinventory_id := NULL;
            END IF;

        END IF;

    END IF;


    IF g_trolin_rec.transaction_header_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.transaction_header_id := Get_Transaction_Header;

        IF g_trolin_rec.transaction_header_id IS NOT NULL THEN

            IF
	      INV_Validate.Transaction_Header(g_trolin_rec.transaction_header_id) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_TRANSACTION_HEADER
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.transaction_header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.uom_code = FND_API.G_MISS_CHAR THEN

        g_trolin_rec.uom_code := Get_Uom;

        IF g_trolin_rec.uom_code IS NOT NULL THEN

            IF INV_Validate.Uom(g_trolin_rec.uom_code, l_org, l_item) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_UOM
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.uom_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.unit_number = FND_API.G_MISS_CHAR THEN
        g_trolin_rec.unit_number := Get_Unit_number;
    END IF;

    IF g_trolin_rec.transaction_source_type_id = FND_API.G_MISS_NUM THEN
        g_trolin_rec.transaction_source_type_id := Get_Transaction_Source_Type_ID(g_trolin_rec.transaction_Type_id);
        IF g_trolin_rec.transaction_source_type_id IS NOT NULL THEN
            --IF INV_Validate.Transaction_Source_Type(g_trolin_rec.transaction_source_type_id)
            --THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_TRANSACTION_SOURCE_TYPE_ID
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            --ELSE
            --    g_trolin_rec.transaction_source_type_id := NULL;
            --END IF;
        END IF;
    END IF;

    IF g_trolin_rec.txn_source_id = FND_API.G_MISS_NUM THEN
        g_trolin_rec.txn_source_id := Get_Txn_Source_ID;
        IF g_trolin_rec.txn_source_id IS NOT NULL THEN
            --IF INV_Validate.Txn_Source(g_trolin_rec.txn_source_id)
            --THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_TXN_SOURCE_ID
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            --ELSE
            --    g_trolin_rec.txn_source_id := NULL;
            --END IF;
        END IF;
    END IF;

    IF g_trolin_rec.txn_source_line_id = FND_API.G_MISS_NUM THEN
        g_trolin_rec.txn_source_line_id := Get_Txn_Source_Line_ID;
        IF g_trolin_rec.txn_source_line_id IS NOT NULL THEN
            --IF INV_Validate.Txn_Source_Line(g_trolin_rec.txn_source_line_id)
            --THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_TXN_SOURCE_LINE_ID
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            --ELSE
            --    g_trolin_rec.txn_source_line_id := NULL;
            --END IF;
        END IF;
    END IF;

    IF g_trolin_rec.txn_source_line_detail_id = FND_API.G_MISS_NUM THEN
        g_trolin_rec.txn_source_line_detail_id := Get_Txn_Source_Line_Detail_ID;
        IF g_trolin_rec.txn_source_line_detail_id IS NOT NULL THEN
            --IF INV_Validate.Txn_Source_Line_Detail(g_trolin_rec.txn_source_line_detail_id)
            --THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_TXN_SOURCE_LINE_DETAIL_ID
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            --ELSE
            --    g_trolin_rec.txn_source_line_detail_id := NULL;
            --END IF;
        END IF;
    END IF;

    IF g_trolin_rec.primary_quantity = FND_API.G_MISS_NUM THEN
        g_trolin_rec.primary_quantity := Get_Primary_Quantity;
        IF g_trolin_rec.primary_quantity IS NOT NULL THEN
            --IF INV_Validate.Primary_Quantity(g_trolin_rec.primary_quantity)
            --THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_PRIMARY_QUANTITY
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            --ELSE
            --    g_trolin_rec.primary_quantity := NULL;
            --END IF;
        END IF;
    END IF;

    IF g_trolin_rec.to_organization_id = FND_API.G_MISS_NUM THEN
        g_trolin_rec.to_organization_id := Get_To_Organization_Id;
        IF g_trolin_rec.to_organization_id IS NOT NULL THEN
            --IF INV_Validate.To_Organization(g_trolin_rec.to_organization_id)
            --THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_TO_ORGANIZATION_ID
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            --ELSE
            --    g_trolin_rec.to_organization_id := NULL;
            --END IF;
        END IF;
    END IF;

    IF g_trolin_rec.pick_strategy_id = FND_API.G_MISS_NUM THEN
        g_trolin_rec.pick_strategy_id := Get_Pick_Strategy_Id;
        IF g_trolin_rec.pick_strategy_id IS NOT NULL THEN
            --IF INV_Validate.Pick_Strategy(g_trolin_rec.pick_strategy_id)
            --THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_PICK_STRATEGY_ID
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            --ELSE
            --    g_trolin_rec.pick_strategy_id := NULL;
            --END IF;
        END IF;
    END IF;

    IF g_trolin_rec.put_away_strategy_id = FND_API.G_MISS_NUM THEN
        g_trolin_rec.put_away_strategy_id := Get_Put_Away_Strategy_ID;
        IF g_trolin_rec.put_away_strategy_id IS NOT NULL THEN
            --IF INV_Validate.Put_Away_Strategy(g_trolin_rec.put_away_strategy_id)
            --THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_PUT_AWAY_STRATEGY_ID
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            --ELSE
            --    g_trolin_rec.put_away_strategy_id := NULL;
            --END IF;
        END IF;
    END IF;
--INVCONV
    IF g_trolin_rec.secondary_quantity = FND_API.G_MISS_NUM THEN

        g_trolin_rec.secondary_quantity := Get_Quantity;

        IF g_trolin_rec.secondary_quantity IS NOT NULL THEN

            IF INV_Validate.Secondary_Quantity(g_trolin_rec.quantity) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_SECONDARY_QUANTITY
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.secondary_quantity := NULL;
            END IF;
        END IF;

    END IF;

    IF g_trolin_rec.secondary_quantity_delivered = FND_API.G_MISS_NUM THEN

        g_trolin_rec.secondary_quantity_delivered := Get_Quantity_Delivered;

        IF g_trolin_rec.secondary_quantity_delivered IS NOT NULL THEN

            IF
	      INV_Validate_trolin.Secondary_Quantity_Delivered(g_trolin_rec.secondary_quantity_delivered) = inv_validate_trolin.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_SECONDARY_QUANTITY_DELIVERED
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.secondary_quantity_delivered := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.secondary_quantity_detailed = FND_API.G_MISS_NUM THEN

        g_trolin_rec.secondary_quantity_detailed := Get_Quantity_Detailed;

        IF g_trolin_rec.secondary_quantity_detailed IS NOT NULL THEN

            IF
	      INV_Validate_trolin.Secondary_Quantity_Detailed(g_trolin_rec.secondary_quantity_detailed) = inv_validate_trolin.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_SECONDARY_QUANTITY_DETAILED
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.secondary_quantity_detailed := NULL;
            END IF;

        END IF;

    END IF;

    IF g_trolin_rec.secondary_uom = FND_API.G_MISS_CHAR THEN

        g_trolin_rec.secondary_uom := Get_Secondary_Uom;
/*
        IF g_trolin_rec.secondary_uom IS NOT NULL THEN

            IF INV_Validate.Secondary_Uom(g_trolin_rec.secondary_uom, l_org, l_item) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_SECONDARY_UOM
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.secondary_uom := NULL;
            END IF;

        END IF;
*/
    ELSIF g_trolin_rec.secondary_uom IS NULL AND g_trolin_rec.secondary_quantity = 0 THEN
        convert_quantity(x_return_status => l_return_status, p_trolin_rec => g_trolin_rec);
        IF l_return_status = fnd_api.g_ret_sts_error THEN
           g_trolin_rec.secondary_quantity := NULL;
        END IF;
    END IF;

    IF g_trolin_rec.grade_code = FND_API.G_MISS_CHAR THEN

        g_trolin_rec.grade_code := Get_Grade_Code;
/*
        IF g_trolin_rec.grade_code IS NOT NULL THEN

            IF INV_Validate.Grade_Code(g_trolin_rec.grade_code, l_org, l_item) = inv_validate.T
            THEN
                INV_Trolin_Util.Clear_Dependent_Attr
                (   p_attr_id                     => INV_Trolin_Util.G_GRADE_CODE
                ,   p_trolin_rec                  => g_trolin_rec
                ,   x_trolin_rec                  => g_trolin_rec
                );
            ELSE
                g_trolin_rec.grade_code := NULL;
            END IF;
        END IF;
*/

    END IF;

--INVCONV


    IF g_trolin_rec.ship_to_location_id = FND_API.G_MISS_NUM THEN
       g_trolin_rec.ship_to_location_id := NULL; --  nothing to default;
    END IF;

    IF g_trolin_rec.from_cost_group_id = FND_API.G_MISS_NUM THEN
       g_trolin_rec.from_cost_group_id := NULL; --  nothing to default;
    END IF;

    IF g_trolin_rec.to_cost_group_id = FND_API.G_MISS_NUM THEN
       g_trolin_rec.to_cost_group_id := NULL; --  nothing to default;
    END IF;

    IF g_trolin_rec.lpn_id = FND_API.G_MISS_NUM THEN
       g_trolin_rec.lpn_id := NULL; --  nothing to default;
    END IF;

    IF g_trolin_rec.to_lpn_id = FND_API.G_MISS_NUM THEN
       g_trolin_rec.to_lpn_id := NULL; --  nothing to default;
    END IF;

    IF g_trolin_rec.pick_methodology_id = FND_API.G_MISS_NUM THEN
       g_trolin_rec.pick_methodology_id := NULL; --  nothing to default;
    END IF;

    IF g_trolin_rec.container_item_id = FND_API.G_MISS_NUM THEN
       g_trolin_rec.container_item_id := NULL; --  nothing to default;
    END IF;

    IF g_trolin_rec.carton_grouping_id = FND_API.G_MISS_NUM THEN
       g_trolin_rec.carton_grouping_id := NULL; --  nothing to default;
    END IF;


    IF g_trolin_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute_category = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Trolin;

    END IF;

    IF g_trolin_rec.created_by = FND_API.G_MISS_NUM THEN

        g_trolin_rec.created_by := NULL;

    END IF;

    IF g_trolin_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_trolin_rec.creation_date := NULL;

    END IF;

    IF g_trolin_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_trolin_rec.last_updated_by := NULL;

    END IF;

    IF g_trolin_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_trolin_rec.last_update_date := NULL;

    END IF;

    IF g_trolin_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_trolin_rec.last_update_login := NULL;

    END IF;

    IF g_trolin_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.program_application_id := NULL;

    END IF;

    IF g_trolin_rec.program_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.program_id := NULL;

    END IF;

    IF g_trolin_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_trolin_rec.program_update_date := NULL;

    END IF;

    IF g_trolin_rec.request_id = FND_API.G_MISS_NUM THEN

        g_trolin_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_trolin_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.attribute_category = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.created_by = FND_API.G_MISS_NUM
    OR  g_trolin_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_trolin_rec.date_required = FND_API.G_MISS_DATE
    OR  g_trolin_rec.from_locator_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.from_subinventory_code = FND_API.g_miss_char
    OR  g_trolin_rec.from_subinventory_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.header_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.inventory_item_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_trolin_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_trolin_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_trolin_rec.line_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.line_number = FND_API.G_MISS_NUM
    OR  g_trolin_rec.line_status = FND_API.G_MISS_NUM
    OR  g_trolin_rec.lot_number = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.organization_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.program_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_trolin_rec.project_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.quantity = FND_API.G_MISS_NUM
    OR  g_trolin_rec.quantity_delivered = FND_API.G_MISS_NUM
    OR  g_trolin_rec.quantity_detailed = FND_API.G_MISS_NUM
    OR  g_trolin_rec.reason_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.reference = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.reference_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.reference_type_code = FND_API.G_MISS_NUM
    OR  g_trolin_rec.request_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.revision = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.serial_number_end = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.serial_number_start = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.status_date = FND_API.G_MISS_DATE
    OR  g_trolin_rec.task_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.to_account_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.to_locator_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.to_subinventory_code = FND_API.g_miss_char
    OR  g_trolin_rec.to_subinventory_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.transaction_header_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.uom_code = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.transaction_type_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.transaction_source_type_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.txn_source_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.txn_source_line_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.txn_source_line_detail_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.primary_quantity = FND_API.G_MISS_NUM
    OR  g_trolin_rec.to_organization_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.pick_strategy_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.put_away_strategy_id = FND_API.G_MISS_NUM
    OR  g_trolin_Rec.unit_number = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.from_cost_group_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.to_cost_group_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.lpn_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.to_lpn_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.pick_methodology_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.container_item_id = FND_API.G_MISS_NUM
    OR  g_trolin_rec.carton_grouping_id = FND_API.G_MISS_NUM
--INVCONV
    OR  g_trolin_rec.secondary_uom = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.grade_code = FND_API.G_MISS_CHAR
    OR  g_trolin_rec.secondary_quantity = FND_API.G_MISS_NUM
    OR  g_trolin_rec.secondary_quantity_delivered = FND_API.G_MISS_NUM
    OR  g_trolin_rec.secondary_quantity_detailed = FND_API.G_MISS_NUM
--INVCONV
    THEN

        INV_Default_Trolin.Attributes
        (   p_trolin_rec                  => g_trolin_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_trolin_rec                  => x_trolin_rec
        );

    ELSE

        --  Done defaulting attributes

        x_trolin_rec := g_trolin_rec;

    END IF;
END Attributes;

/*Fixed for bug#7126566
  Added procedure to set gloabl variable
  This is called by form. In form package variables
  can not be accessed directly.
*/
PROCEDURE Set_CALLED_BY_FORM(P_CALLED_BY_FORM in varchar2 )
Is
begin
     G_CALLED_BY_FORM := P_CALLED_BY_FORM;
end;

END INV_Default_Trolin;

/
