--------------------------------------------------------
--  DDL for Package Body OE_CNCL_VALIDATE_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CNCL_VALIDATE_LINE" AS
/* $Header: OEXVCLNB.pls 120.10.12010000.2 2010/03/03 00:59:51 smusanna ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_CNCL_Validate_Line';

-- LOCAL PROCEDURES

-- Check_Book_Reqd_Attributes
-- This procedure checks for all the attributes that are required
-- on booked order lines.

PROCEDURE Check_Book_Reqd_Attributes
( p_line_rec		   IN OE_Order_PUB.Line_Rec_Type
, x_return_status      IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_proj_ref_enabled				NUMBER;
l_proj_control_level			NUMBER;
l_calculate_tax_flag			VARCHAR2(1) := 'N';
l_line_type_rec				OE_Order_Cache.Line_Type_Rec_Type;
l_item_type_code				VARCHAR2(30);
BEGIN

	OE_DEBUG_PUB.Add('Entering OE_CNCL_VALIDATE_LINE.Check_Book_Reqd_Attributes',1);
	-- Check for fields required on a booked order line

	IF p_line_rec.sold_to_org_id IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('SOLD_TO_ORG_ID'));
	     OE_MSG_PUB.ADD;
	END IF;

	IF p_line_rec.invoice_to_org_id IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('INVOICE_TO_ORG_ID'));
	     OE_MSG_PUB.ADD;
	END IF;

	IF p_line_rec.tax_exempt_flag IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('TAX_EXEMPT_FLAG'));
	     OE_MSG_PUB.ADD;
	END IF;


	-- Item, Quantity and UOM Required
	IF p_line_rec.inventory_item_id IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('INVENTORY_ITEM_ID'));
	     OE_MSG_PUB.ADD;
    	END IF;

	IF p_line_rec.order_quantity_uom IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('ORDER_QUANTITY_UOM'));
	     OE_MSG_PUB.ADD;
    	END IF;

     -- Fix bug 1277092: ordered quantity should not be = 0 on a booked line
	IF p_line_rec.ordered_quantity IS NULL
	   OR p_line_rec.ordered_quantity = 0 THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('ORDERED_QUANTITY'));
	     OE_MSG_PUB.ADD;
    	END IF;

	-- For all items that are NOT included items OR config items,
	-- price list, unit selling price and unit list price are required.

     IF p_line_rec.line_category_code = 'RETURN' THEN
		l_item_type_code := OE_Line_Util.Get_Return_Item_Type_Code
							(p_line_rec);
	ELSE
		l_item_type_code := p_line_rec.item_type_code;
     END IF;

	IF (l_item_type_code <> 'INCLUDED'
	    AND l_item_type_code <> 'CONFIG')
	THEN

	   IF p_line_rec.price_list_id IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('PRICE_LIST_ID'));
	     	OE_MSG_PUB.ADD;
        END IF;

	   IF p_line_rec.unit_list_price IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('UNIT_LIST_PRICE'));
	     	OE_MSG_PUB.ADD;
        END IF;

	   IF p_line_rec.unit_selling_price IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('UNIT_SELLING_PRICE'));
	     	OE_MSG_PUB.ADD;
        END IF;

	END IF; -- End of check for pricing attributes.


	-- Fix bug 1262790
	-- Ship To and Payment Term required on ORDER lines,
	-- NOT on RETURN lines

	IF p_line_rec.line_category_code <> OE_GLOBALS.G_RETURN_CATEGORY_CODE THEN

	  IF p_line_rec.ship_to_org_id IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('SHIP_TO_ORG_ID'));
	    	OE_MSG_PUB.ADD;
	  END IF;

	  IF p_line_rec.payment_term_id IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('PAYMENT_TERM_ID'));
	     OE_MSG_PUB.ADD;
	  END IF;

	END IF;


	-- Warehouse and schedule date required on RETURN lines

	IF p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE THEN

	   IF p_line_rec.ship_from_org_id IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_RETURN_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('SHIP_FROM_ORG_ID'));
	     	OE_MSG_PUB.ADD;
        END IF;

	   IF p_line_rec.request_date IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_RETURN_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('REQUEST_DATE'));
	     	OE_MSG_PUB.ADD;
        END IF;

	END IF;

     /* Added by Manish */

     IF p_line_rec.tax_date IS NULL
	THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_RETURN_ATTRIBUTE');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
         		OE_Order_UTIL.Get_Attribute_Name('TAX_DATE'));
         OE_MSG_PUB.ADD;
     END IF;

	-- Tax code is required under following conditions.
	-- 1. The tax hadnling is required at line level.
	--    (i.e. Tax_exempt_flag = 'R'-Required.)
	-- 2. The calculate tax flag on customer transaction type for this line
	--    type is set to Yes.

    oe_debug_pub.add('calc tax flag 2 : ' || l_line_type_rec.calculate_tax_flag );

     l_line_type_rec := OE_Order_Cache.Load_Line_Type(p_line_rec.line_type_id);

    -- fix for bug 1701388 - commented the following code
    /*

	-- Fix bug#1098412: check for calculate tax flag ONLY if receivable
	-- transaction type EXISTS on the line type
     IF l_line_type_rec.cust_trx_type_id IS NOT NULL THEN

		SELECT tax_calculation_flag
		INTO l_calculate_tax_flag
		FROM RA_CUST_TRX_TYPES
		WHERE CUST_TRX_TYPE_ID = l_line_type_rec.cust_trx_type_id;

     END IF;

     */

-- fix for bug 1701388. changed l_calculate_tax_flag to
-- l_line_type_rec.calculate_tax_flag

	-- eBTax changes
	/*  this validation no longer required
	IF (l_line_type_rec.calculate_tax_flag = 'Y' OR p_line_rec.tax_exempt_flag = 'R')
	    	 AND p_line_rec.tax_code IS NULL
	THEN
	    	x_return_status := FND_API.G_RET_STS_ERROR;
	    	FND_MESSAGE.SET_NAME('ONT','OE_VAL_TAX_CODE_REQD');
	    	OE_MSG_PUB.ADD;
    	END IF;*/

/* Added by Manish */


     -- Service Duration is required on SERVICE lines
       IF l_item_type_code = 'SERVICE' THEN
	   IF p_line_rec.service_duration IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_SERVICE_DURATION');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
		    OE_Order_UTIL.Get_Attribute_Name('SERVICE_DURATION'));
	     OE_MSG_PUB.ADD;
        END IF;
       END IF;
   ------------------------------------------------------------------------
    --Check over return
   ------------------------------------------------------------------------

    IF p_line_rec.line_category_code = 'RETURN' AND
       p_line_rec.reference_line_id is not NULL AND
       p_line_rec.cancelled_flag <> 'Y'
    THEN
        IF (OE_LINE_UTIL.Is_Over_Return(p_line_rec)) THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ONT', 'OE_RETURN_INVALID_QUANTITY');
            OE_MSG_PUB.ADD;
        END IF;
    END IF;

    OE_DEBUG_PUB.Add('Entering OE_CNCL_VALIDATE_LINE.Check_Book_Reqd_Attributes',1);

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Book_Reqd_Attributes'
            );
        END IF;
END Check_Book_Reqd_Attributes;

FUNCTION Get_Date_Type
( p_header_id      IN NUMBER)
RETURN VARCHAR2
IS
l_order_date_type_code   VARCHAR2(30) := null;
BEGIN

  SELECT order_date_type_code
  INTO   l_order_date_type_code
  FROM   oe_order_headers
  WHERE  header_id = p_header_id;

  RETURN l_order_date_type_code;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
        RETURN NULL;
  WHEN OTHERS THEN
       RETURN null;
END Get_Date_Type;

PROCEDURE Validate_Decimal_Quantity
		( p_item_id			IN NUMBER
		, p_item_type_code		IN VARCHAR2
		, p_input_quantity		IN NUMBER
		, p_uom_code			IN VARCHAR2
		, x_return_status		IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
		) IS
l_validated_quantity	NUMBER;
l_primary_quantity       NUMBER;
l_qty_return_status      VARCHAR2(1);
BEGIN
	OE_DEBUG_PUB.Add('Entering OE_CNCL_VALIDATE_LINE.Validate_Decimal_Quantity',1);
         -- validate input quantity
         IF (p_input_quantity is not null AND
             p_input_quantity <> FND_API.G_MISS_NUM) THEN

           IF trunc(p_input_quantity) <> p_input_quantity THEN
             oe_debug_pub.add('input quantity is decimal',2);

             IF p_item_type_code is not NULL THEN

               IF p_item_type_code IN ('MODEL', 'OPTION', 'KIT',
                  'CLASS','INCLUDED', 'CONFIG') THEN
                oe_debug_pub.add('item is config related with decimal qty',2);
                FND_MESSAGE.SET_NAME('ONT', 'OE_CONFIG_NO_DECIMALS');
                OE_MSG_PUB.Add;
			 x_return_status := FND_API.G_RET_STS_ERROR;

               ELSE

                 oe_debug_pub.add('before calling inv decimals api',2);
                 inv_decimals_pub.validate_quantity(
                  p_item_id          => p_item_id,
                  p_organization_id  =>
                        OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'),
                  p_input_quantity   => p_input_quantity,
                  p_uom_code         => p_uom_code,
                  x_output_quantity  => l_validated_quantity,
                  x_primary_quantity => l_primary_quantity,
                  x_return_status    => l_qty_return_status);

                  IF l_qty_return_status = 'W' or l_qty_return_status = 'E' THEN
		         oe_debug_pub.add('inv decimal api return ' || l_qty_return_status,2);
                         oe_debug_pub.add('input_qty ' || p_input_quantity,2);
		         oe_debug_pub.add('l_pri_qty ' || l_primary_quantity,2);
                         oe_debug_pub.add('l_val_qty ' || l_validated_quantity,2);
                         /* bug 2926436 */
                         IF l_qty_return_status = 'W' THEN
                            fnd_message.set_name('ONT', 'OE_DECIMAL_MAX_PRECISION');
                         END IF;

                         -- move INV error message to OE message stack
                         oe_msg_pub.add;
			 x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;

	           END IF;  -- config related item type
             END IF; -- item_type_code is null
           END IF; -- if not decimal qty
         END IF; -- quantity is null

	OE_DEBUG_PUB.Add('Exiting OE_CNCL_VALIDATE_LINE.Validate_Decimal_Quantity',1);
END Validate_Decimal_Quantity;


Procedure Validate_Line_Type(p_line_rec     IN oe_order_pub.line_rec_type)
IS
--
--		    p_old_line_rec IN oe_order_pub.line_rec_type)

lorder_type_id     NUMBER;
lexists            VARCHAR2(30);
lprocessname       VARCHAR2(80);
l_new_wf_item_type VARCHAR2(30);
--l_old_wf_item_type VARCHAR2(30);

CURSOR find_LineProcessname IS
 SELECT 'EXISTS'
 FROM  oe_workflow_assignments a
 WHERE a.line_type_id = p_line_rec.line_type_id
 AND   nvl(a.item_type_code,nvl(l_new_wf_item_type,'-99')) = nvl(l_new_wf_item_type,'-99')
 AND   a.process_name = lprocessname
 AND   a.order_type_id = lorder_type_id
 ORDER BY a.item_type_code ;

CURSOR Get_Order_Type IS
 SELECT order_type_id
 FROM   oe_order_headers
 WHERE  header_id = p_line_rec.header_id ;



Cursor find_config_assign is
 SELECT 'EXISTS'
 FROM   oe_workflow_assignments a
 WHERE  a.line_type_id = p_line_rec.line_type_id
 AND    a.item_type_code = l_new_wf_item_type
 AND	   a.order_type_id = lorder_type_id ;


BEGIN

	OE_DEBUG_PUB.Add('Entering OE_CNCL_VALIDATE_LINE.Validate_Line_Type',1);

	    IF  p_line_rec.ITEM_TYPE_CODE = OE_GLOBALS.G_ITEM_CONFIG THEN

            l_new_wf_item_type := OE_Order_WF_Util.get_wf_item_type(p_line_rec);

	       OPEN Get_Order_Type;
	       FETCH Get_Order_Type
	       INTO lorder_type_id;
	       CLOSE Get_Order_Type;

	       OPEN find_config_assign;
	       FETCH find_config_assign
	       INTO lexists;
	       CLOSE find_config_assign;

		  IF lexists IS NULL THEN
			oe_debug_pub.add('No explicit assignment exists',2);
         		FND_MESSAGE.SET_NAME('ONT','OE_EXP_ASSIGN_REQ');
         		OE_MSG_PUB.ADD;
	    		RAISE FND_API.G_EXC_ERROR;
		  END IF;

	    END IF;

	OE_DEBUG_PUB.Add('Exiting OE_CNCL_VALIDATE_LINE.Validate_Line_Type',1);
EXCEPTION
     WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('ONT','OE_FLOW_CNT_CHANGE');
         OE_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     WHEN FND_API.G_EXC_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;

     WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
       OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'Validate_Line_Type'
               );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Validate_line_type;


FUNCTION Validate_Receiving_Org
( p_inventory_item_id  IN  NUMBER
, p_ship_from_org_id   IN  NUMBER)
RETURN BOOLEAN
IS
l_validate VARCHAR2(1) := 'Y';
l_dummy    VARCHAR2(10);
BEGIN
  OE_DEBUG_PUB.Add('Entering OE_CNCL_VALIDATE_LINE.Validate_Receiving_Org',1);
   SELECT null
   INTO  l_dummy
   FROM mtl_system_items msi,
        org_organization_definitions org
   WHERE msi.inventory_item_id = p_inventory_item_id
   AND org.organization_id= msi.organization_id
   AND org.organization_id= p_ship_from_org_id
   AND org.set_of_books_id= ( SELECT fsp.set_of_books_id
                              FROM financials_system_parameters fsp)
   AND ROWNUM=1 ;

  OE_DEBUG_PUB.Add('Exiting OE_CNCL_VALIDATE_LINE.Validate_Receiving_Org',1);
   RETURN TRUE;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ITEM_WHSE');
       OE_MSG_PUB.add;
       RETURN FALSE;
   WHEN OTHERS THEN
       FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ITEM_WHSE');
       OE_MSG_PUB.add;
       RETURN FALSE;
END Validate_Receiving_Org;

FUNCTION Validate_Item_Warehouse
( p_inventory_item_id  IN  NUMBER
, p_ship_from_org_id   IN  NUMBER
, p_item_type_code     IN  VARCHAR2
, p_line_id            IN  NUMBER
, p_top_model_line_id  IN  NUMBER)
RETURN BOOLEAN
IS
l_validate VARCHAR2(1) := 'Y';
l_dummy    VARCHAR2(10);
BEGIN
   oe_debug_pub.add('Entering Validate_Item_Warehouse',1);
   -- The customer_order_enabled_flag for config item
   -- is set to 'N'

   IF p_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED OR
      p_item_type_code = OE_GLOBALS.G_ITEM_CONFIG OR
      p_item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
      p_item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
      (p_item_type_code = OE_GLOBALS.G_ITEM_KIT AND
       nvl(p_top_model_line_id, -1) <> p_line_id)
   THEN
     SELECT null
     INTO  l_dummy
     FROM  mtl_system_items msi,
           org_organization_definitions org
     WHERE msi.inventory_item_id = p_inventory_item_id
     AND   org.organization_id= msi.organization_id
     AND   org.organization_id= p_ship_from_org_id
     AND   rownum=1;
   ELSE
     SELECT null
     INTO  l_dummy
     FROM  mtl_system_items msi,
           org_organization_definitions org
     WHERE msi.inventory_item_id = p_inventory_item_id
     AND   org.organization_id= msi.organization_id
     AND   org.organization_id= p_ship_from_org_id
     AND   rownum=1;
   END IF;
   oe_debug_pub.add('Exiting Validate_Item_Warehouse',1);
   RETURN TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       oe_debug_pub.add('RR: No data found',1);

       FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ITEM_WHSE');
       OE_MSG_PUB.add;
       RETURN FALSE;

   WHEN OTHERS THEN
       oe_debug_pub.add('RR: OTHERS',1);
       FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ITEM_WHSE');
       OE_MSG_PUB.add;
       RETURN FALSE;

END Validate_Item_Warehouse;

FUNCTION Validate_task
( p_project_id  IN  NUMBER
, p_task_id     IN  NUMBER)
RETURN BOOLEAN
IS
l_dummy VARCHAR2(10);
BEGIN

   oe_debug_pub.add('Entering Validate_Task',1);
    SELECT 'VALID'
    INTO   l_dummy
    FROM   mtl_task_v
    WHERE  project_id = p_project_id
    AND    task_id = p_task_id;

   oe_debug_pub.add('Exiting Validate_Task',1);
    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN
      RETURN FALSE;

END Validate_task;

FUNCTION Validate_task_reqd
( p_project_id  IN  NUMBER
 ,p_ship_from_org_id IN NUMBER)
RETURN BOOLEAN
IS
l_project_control_level NUMBER;
BEGIN
   oe_debug_pub.add('Entering Validate_task_reqd',1);

	-- If project control level in MTL_PARAMETERS for the warehouse
	-- is set to 'Task', then project references on the order must
	-- consist of both Project and Task.

		SELECT NVL(PROJECT_CONTROL_LEVEL,0)
		INTO   l_project_control_level
		FROM   MTL_PARAMETERS
		WHERE  ORGANIZATION_ID = p_ship_from_org_id;

		 IF l_project_control_level = 2 		-- control level is 'Task'
	      THEN
              oe_debug_pub.add('Exiting Validate_task_reqd',1);
			RETURN TRUE;
           ELSE
              oe_debug_pub.add('Exiting Validate_task_reqd',1);
			RETURN FALSE;
		 END IF;

EXCEPTION

   WHEN OTHERS THEN
      RETURN FALSE;

END Validate_task_reqd;

FUNCTION Validate_Item_Fields
( p_inventory_item_id    IN  NUMBER
, p_ordered_item_id      IN  NUMBER
, p_item_identifier_type IN  VARCHAR2
, p_ordered_item         IN  VARCHAR2
, p_sold_to_org_id       IN  NUMBER)
RETURN BOOLEAN
IS
l_dummy    VARCHAR2(10);
BEGIN
   oe_debug_pub.add('Entering Validate_Item_Fields',1);
   oe_debug_pub.add('p_inventory_item_id: '||p_inventory_item_id);
   oe_debug_pub.add('p_ordered_item_id: '||p_ordered_item_id);
   oe_debug_pub.add('p_item_identifier_type: '||p_item_identifier_type);
   oe_debug_pub.add('p_ordered_item: '||p_ordered_item);
   oe_debug_pub.add('p_sold_to_org_id: '||p_sold_to_org_id);
   IF nvl(p_item_identifier_type, 'INT') = 'INT' THEN
      SELECT 'valid'
      INTO  l_dummy
      FROM  mtl_system_items_vl
      WHERE inventory_item_id = p_inventory_item_id
      AND organization_id = OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID');
   ELSIF nvl(p_item_identifier_type, 'INT') = 'CUST' THEN
      SELECT 'valid'
      INTO  l_dummy
      FROM   mtl_customer_items citems
            ,mtl_customer_item_xrefs cxref
            ,mtl_system_items_vl sitems
      WHERE citems.customer_item_id = cxref.customer_item_id
        AND cxref.inventory_item_id = sitems.inventory_item_id
        AND sitems.inventory_item_id = p_inventory_item_id
        AND sitems.organization_id =
	   OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID')
        AND citems.customer_item_id = p_ordered_item_id
        AND citems.customer_id = p_sold_to_org_id
        AND rownum =1;
   ELSE
      IF p_ordered_item_id IS NOT NULL THEN
        RETURN FALSE;
      ELSE
        SELECT 'valid'
        INTO  l_dummy
        FROM  mtl_cross_reference_types types
            , mtl_cross_references items
            , mtl_system_items_vl sitems
        WHERE types.cross_reference_type = items.cross_reference_type
           AND items.inventory_item_id = sitems.inventory_item_id
           AND sitems.organization_id =
           OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID')
           AND sitems.inventory_item_id = p_inventory_item_id
           AND items.cross_reference_type = p_item_identifier_type
           AND items.cross_reference = p_ordered_item;
      END IF;
   END IF;

   oe_debug_pub.add('Exiting Validate_Item_Fields',1);
   RETURN TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       oe_debug_pub.add('Validate_Item_Fields: No data found',1);
       IF nvl(p_item_identifier_type, 'INT') = 'INT' THEN
         oe_debug_pub.add('Invalid internal item');
       ELSIF nvl(p_item_identifier_type, 'INT') = 'CUST' THEN
         oe_debug_pub.add('Invalid Customer Item');
       ELSE
         oe_debug_pub.add('Invalid Generic Item');
       END IF;
       RETURN FALSE;
   WHEN OTHERS THEN
       oe_debug_pub.add('Validate_Item_Fields: When Others',1);
       RETURN FALSE;
END Validate_Item_Fields;

FUNCTION Validate_Return_Item_Mismatch
( p_reference_line_id    IN NUMBER
, p_inventory_item_id    IN NUMBER)
RETURN BOOLEAN
IS
l_ref_inventory_item_id NUMBER;
l_profile               VARCHAR2(1);
BEGIN
   oe_debug_pub.add('Entering Validate_Return_Item_Mismatch',1);

   IF (p_reference_line_id IS NULL) THEN
     RETURN TRUE;
   END IF;

   -- Check Profile Option to see if allow item mismatch
   l_profile := FND_PROFILE.value('ONT_RETURN_ITEM_MISMATCH_ACTION');

   IF (l_profile is NULL OR l_profile = 'A') THEN
     RETURN TRUE;
   ELSE

        SELECT inventory_item_id
        INTO  l_ref_inventory_item_id
        FROM  oe_order_lines
        WHERE line_id = p_reference_line_id;

      IF (l_ref_inventory_item_id = p_inventory_item_id) THEN
        RETURN TRUE;
      ELSIF (l_profile = 'R') THEN
        RETURN FALSE;
      ELSE  -- warning
        FND_MESSAGE.SET_NAME('ONT','OE_RETURN_ITEM_MISMATCH_WARNIN');
        OE_MSG_PUB.ADD;
      END IF;

   END IF;

   oe_debug_pub.add('Exiting Validate_Return_Item_Mismatch',1);
   RETURN TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       oe_debug_pub.add('Validate_Return_Item_Mismatch: No data found',1);
       RETURN FALSE;
   WHEN OTHERS THEN
       oe_debug_pub.add('Validate_Return_Item_Mismatch: When Others',1);
       RETURN FALSE;
END Validate_Return_Item_Mismatch;

FUNCTION Validate_Return_Fulfilled_Line
(p_reference_line_id IN NUMBER
) RETURN BOOLEAN
IS
l_ref_fulfilled_quantity NUMBER;
l_ref_shippable_flag     VARCHAR2(1);
l_ref_shipped_quantity   NUMBER;
l_ref_inv_iface_status   VARCHAR2(30);
l_profile                VARCHAR2(1);
BEGIN
   oe_debug_pub.add('Entering Validate return fulfilled line',1);

   IF (p_reference_line_id IS NULL) THEN
     RETURN TRUE;
   END IF;

   -- Check Profile Option to see if allow item mismatch
   l_profile := FND_PROFILE.value('ONT_RETURN_FULFILLED_LINE_ACTION');

   IF (l_profile is NULL OR l_profile = 'A') THEN
     RETURN TRUE;

	/*
	** As per the fix for Bug # 1541972, modified the following ELSE
	** clause to return a success even if Fulfilled Quantity is null
	** and some other conditions are met.
	*/
   ELSE


        SELECT nvl(fulfilled_quantity, 0)
	   ,      nvl(shippable_flag, 'N')
	   ,      invoice_interface_status_code
	   ,      nvl(shipped_quantity, 0)
        INTO  l_ref_fulfilled_quantity
	   ,     l_ref_shippable_flag
	   ,     l_ref_inv_iface_status
	   ,     l_ref_shipped_quantity
        FROM  oe_order_lines
        WHERE line_id = p_reference_line_id;

      IF (l_ref_shippable_flag = 'N' AND l_ref_inv_iface_status = 'NOT_ELIGIBLE') THEN
	   RETURN TRUE;
      ELSIF l_ref_inv_iface_status in ('YES', 'RFR-PENDING', 'MANUAL-PENDING') THEN
	   RETURN TRUE;
      ELSIF l_ref_fulfilled_quantity > 0 THEN
        RETURN TRUE;
      ELSIF l_ref_shipped_quantity > 0 THEN
	   RETURN TRUE;
      ELSIF (l_profile = 'R') THEN
        RETURN FALSE;
      ELSE  -- warning
        FND_MESSAGE.SET_NAME('ONT','OE_UNFULFILLED_LINE_WARNING');
        OE_MSG_PUB.ADD;
      END IF;

   END IF;

   oe_debug_pub.add('Exiting Validate return fulfilled line',1);
   RETURN TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       oe_debug_pub.add('Validate_Return_Fulfilled_Line: No data found',1);
       RETURN FALSE;
   WHEN OTHERS THEN
       oe_debug_pub.add('Validate_Return_Fulfilled_Line: When Others',1);
       RETURN FALSE;
END Validate_Return_Fulfilled_Line;

FUNCTION Validate_Return_Item
(p_inventory_item_id    IN NUMBER,
 p_ship_from_org_id     IN NUMBER)
 RETURN BOOLEAN
IS
l_returnable_flag Varchar2(1);
BEGIN
  oe_debug_pub.add('Entering Validate_Return_Item',1);

  SELECT nvl(returnable_flag,'Y')
  INTO  l_returnable_flag
  FROM  mtl_system_items
  WHERE inventory_item_id = p_inventory_item_id
  and organization_id = nvl(p_ship_from_org_id,
     oe_sys_parameters.value_wnps('MASTER_ORGANIZATION_ID'));

  IF l_returnable_flag = 'Y' THEN
        RETURN TRUE;
  END IF;

  RETURN FALSE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       oe_debug_pub.add('Validate_Return_Item: No data found',1);
       RETURN FALSE;
   WHEN OTHERS THEN
       oe_debug_pub.add('Validate_Return_Item: When Others',1);
       RETURN FALSE;
END Validate_Return_Item;

FUNCTION Validate_Return_Reference
(p_reference_line_id    IN NUMBER)
 RETURN BOOLEAN
IS
l_booked_flag Varchar2(1);
BEGIN
  oe_debug_pub.add('Enter Validate_Return_Reference',1);

  SELECT nvl(booked_flag,'N')
  INTO  l_booked_flag
  FROM  oe_order_lines
  WHERE line_id = p_reference_line_id
  and line_category_code = 'ORDER';

  IF l_booked_flag = 'Y' THEN
        RETURN TRUE;
  ELSE
            fnd_message.set_name('ONT', 'OE_RETURN_UNBOOKED_ORDER');
            OE_MSG_PUB.Add;
  END IF;

  oe_debug_pub.add('Exit Validate_Return_Reference',1);
  RETURN FALSE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       oe_debug_pub.add('Validate_Return_Reference: No data found',1);
       fnd_message.set_name('ONT', 'OE_RETURN_INVALID_SO_LINE');
       OE_MSG_PUB.Add;
       RETURN FALSE;
   WHEN OTHERS THEN
       oe_debug_pub.add('Validate_Return_Reference: When Others',1);
       fnd_message.set_name('ONT', 'OE_RETURN_INVALID_SO_LINE');
       OE_MSG_PUB.Add;
       RETURN FALSE;
END Validate_Return_Reference;



FUNCTION Validate_Ship_to_Org
( p_ship_to_org_id 	IN  NUMBER
, p_sold_to_org_id	IN  NUMBER)
RETURN BOOLEAN
IS
l_dummy VARCHAR2(10);
lcustomer_relations varchar2(1);
--bug 4729536
Cursor cur_customer_relations IS
SELECT 'VALID'
	    FROM   oe_ship_to_orgs_v
	    WHERE site_use_id = p_ship_to_org_id
	    AND    status = 'A'
	    AND customer_id = p_sold_to_org_id
	    AND ROWNUM = 1

	    UNION ALL

	    SELECT /*MOAC_SQL_NO_CHANGE*/ 'VALID'
	    FROM   oe_ship_to_orgs_v osto
	    WHERE site_use_id = p_ship_to_org_id
	    AND    status = 'A'
	    AND EXISTS
	    (
		    SELECT 1 FROM
		    HZ_CUST_ACCT_RELATE hcar
		    WHERE hcar.cust_account_id = osto.customer_id AND
		    hcar.RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
		    AND hcar.ship_to_flag = 'Y'
	    )
	    AND ROWNUM = 1;

BEGIN

    oe_debug_pub.add('Entering Validate_ship_to_org',1);
    oe_debug_pub.add('ship_to_org_id :'||to_char(p_ship_to_org_id),2);

   --lcustomer_relations := FND_PROFILE.VALUE('ONT_CUSTOMER_RELATIONSHIPS');
  lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');

    IF nvl(lcustomer_relations,'N') = 'N' THEN

    Select 'VALID'
    Into   l_dummy
    From   oe_ship_to_orgs_v
    Where  customer_id = p_sold_to_org_id
    AND 	 site_use_id = p_ship_to_org_id
    AND	 status = 'A';

    oe_debug_pub.add('Exiting Validate_ship_to_org',1);
    RETURN TRUE;
    ELSIF lcustomer_relations = 'Y' THEN

    /*Select /*MOAC_SQL_NO_CHANGE 'VALID'
    Into   l_dummy
    From   oe_ship_to_orgs_v
    WHERE site_use_id = p_ship_to_org_id
    AND    status = 'A' AND
    customer_id in (
                    Select p_sold_to_org_id from dual
                    union
                    select CUST_ACCOUNT_ID from
                    HZ_CUST_ACCT_RELATE
                    where RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
/* added the following condition to fix the bug 2002486
                    and ship_to_flag = 'Y')

    and rownum = 1;*/
/* Replaced ra_customer_relationships with HZ Table to fix the bug 1888440 */

    --bug 4729536
    Open cur_customer_relations;
    Fetch cur_customer_relations into l_dummy;
    Close cur_customer_relations;
    --bug 4729536

    RETURN TRUE;

/* added the following ELSIF condition to fix the bug 2002486 */

    ELSIF nvl(lcustomer_relations,'N') = 'A' THEN
        oe_debug_pub.add
        ('Cr: A',2);

        SELECT 'VALID'
        INTO   l_dummy
        FROM   oe_ship_to_orgs_v
        WHERE  site_use_id = p_ship_to_org_id
        AND    ROWNUM = 1;

    END IF;
   RETURN TRUE;


EXCEPTION

   WHEN OTHERS THEN
      RETURN FALSE;

END Validate_Ship_To_Org;

FUNCTION Validate_Deliver_To_Org
( p_deliver_to_org_id IN  NUMBER
, p_sold_to_org_id	  IN  NUMBER)
RETURN BOOLEAN
IS
l_dummy VARCHAR2(10);
lcustomer_relations varchar2(1);

BEGIN

  oe_debug_pub.add('Entering OE_CNCL_VALIDATE_LINE.Validate_Deliver_To_Org',1);
  oe_debug_pub.add('deliver_to_org_id :'||to_char(p_deliver_to_org_id),2);
  lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');

  IF nvl(lcustomer_relations,'N') = 'N' THEN
    SELECT 'VALID'
    INTO   l_dummy
    FROM   oe_deliver_to_orgs_v
    WHERE  customer_id = p_sold_to_org_id
    AND	 site_use_id = p_deliver_to_org_id
    AND	 status = 'A';

    oe_debug_pub.add('Exiting OE_CNCL_VALIDATE_LINE.Validate_Deliver_To_Org',1);
    RETURN TRUE;

  ELSIF lcustomer_relations = 'Y' THEN
    oe_debug_pub.add('Cr: Yes Line Deliver',2);

    SELECT /* MOAC_SQL_CHANGE */ 'VALID'
      Into   l_dummy
      FROM   HZ_CUST_SITE_USES_ALL SITE,
	   HZ_CUST_ACCT_SITES ACCT_SITE
     WHERE SITE.SITE_USE_ID     = p_deliver_to_org_id
       AND SITE.SITE_USE_CODE     ='DELIVER_TO'
       AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
       AND ACCT_SITE.CUST_ACCOUNT_ID in (
                    SELECT p_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE_ALL R WHERE
                    R.ORG_ID = ACCT_SITE.ORG_ID
                    AND R.RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
			and R.ship_to_flag = 'Y')
       AND ROWNUM = 1;

    oe_debug_pub.add('Exiting OE_CNCL_VALIDATE_LINE.Validate_Deliver_To_Org',1);
    RETURN TRUE;

  ELSIF lcustomer_relations = 'A' THEN

    SELECT  'VALID'
      INTO    l_dummy
      FROM   HZ_CUST_SITE_USES SITE
     WHERE   SITE.SITE_USE_ID =p_deliver_to_org_id;

    oe_debug_pub.add('Exiting OE_CNCL_VALIDATE_LINE.Validate_Deliver_To_Org',1);
    RETURN TRUE;


  END IF;


  oe_debug_pub.add('Exiting OE_CNCL_VALIDATE_LINE.Validate_Deliver_To_Org',1);

EXCEPTION

   WHEN OTHERS THEN
      RETURN FALSE;

END Validate_Deliver_To_Org;


/*-------------------------------------------------------------
PROCEDURE Validate_Source_Type

We use this procedure to add validations related to source_type
= EXTERNAL.
--------------------------------------------------------------*/
PROCEDURE Validate_Source_Type
( p_line_rec      IN  OE_Order_PUB.Line_Rec_Type
 ,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_purchasing_enabled_flag VARCHAR2(1);
BEGIN

  oe_debug_pub.add('entering validate_source_type', 3);

  IF OE_GLOBALS.Equal(p_line_rec.source_type_code,
                      OE_GLOBALS.G_SOURCE_EXTERNAL) THEN

    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508'
    THEN
      IF p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE OR
         p_line_rec.ship_model_complete_flag = 'Y'
      THEN
        oe_debug_pub.add('servie / part of smc model', 4);
        FND_MESSAGE.SET_NAME('ONT', 'OE_DS_NOT_VALID_ITEM');
        FND_MESSAGE.SET_TOKEN('ITEM', p_line_rec.ordered_item);
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      ELSE
        oe_debug_pub.add('validate line: pack H new logic DS', 1);
      END IF;
    ELSE
      IF (p_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_STANDARD) THEN
        oe_debug_pub.add('Cannot dropship non-standard item',2);
        FND_MESSAGE.SET_NAME('ONT', 'OE_DS_NOT_ALLOWED');
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
    END IF;


    IF p_line_rec.ship_set_id is not null OR
       p_line_rec.arrival_set_id is not null THEN

      oe_debug_pub.add('Cannot insert external line to set',2);
      FND_MESSAGE.SET_NAME('ONT', 'OE_DS_SET_INS_FAILED');
      OE_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;


   IF p_line_rec.shippable_flag = 'Y' OR
       (p_line_rec.ato_line_id = p_line_rec.line_id AND
        p_line_rec.item_type_code in ('MODEL', 'CLASS')) THEN

      SELECT purchasing_enabled_flag
      INTO   l_purchasing_enabled_flag
      FROM   mtl_system_items msi,
             org_organization_definitions org
      WHERE msi.inventory_item_id = p_line_rec.inventory_item_id
      AND org.organization_id= msi.organization_id
      AND sysdate <= nvl( org.disable_date, sysdate)
      AND org.organization_id = nvl(p_line_rec.ship_from_org_id,
                       OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'))
      AND org.set_of_books_id= ( SELECT fsp.set_of_books_id
                                 FROM financials_system_parameters fsp);

      IF l_purchasing_enabled_flag = 'N' THEN
        FND_MESSAGE.SET_NAME('ONT', 'OE_DS_NOT_ENABLED');
        FND_MESSAGE.SET_TOKEN('ITEM', nvl(p_line_rec.ship_from_org_id,
                       OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID')));
        FND_MESSAGE.SET_TOKEN('ORG', p_line_rec.ordered_item);
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END IF;

  END IF;

  oe_debug_pub.add('leaving validate_source_type', 3);

EXCEPTION
  WHEN OTHERS THEN
    oe_debug_pub.add('error in Validate_Source_Type');
    RAISE;
END Validate_Source_Type;


-- PUBLIC PROCEDURES

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
)
IS
l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_valid_line_number	  VARCHAR2(1) := 'Y';
l_dummy               VARCHAR2(10);
l_uom                 VARCHAR2(3);
l_uom_count           NUMBER;
l_agreement_name 	  VARCHAR2(240);
l_item_type_code 	  VARCHAR2(30);
l_sold_to_org		  NUMBER;
l_price_list_id	  NUMBER;
l_price_list_name	  VARCHAR2(240);
l_option_count        NUMBER;
l_is_ota_line       BOOLEAN;
l_order_quantity_uom VARCHAR2(3);
lcustomer_relations varchar2(1)  := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');
l_list_type_code	  VARCHAR2(30);

l_ret_status              BOOLEAN:=TRUE;  -- 8993157
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level; -- INVCONV
l_tracking_quantity_ind       VARCHAR2(30); -- INVCONV
l_secondary_default_ind       VARCHAR2(30); -- INVCONV
l_secondary_uom_code varchar2(3) := NULL; -- INVCONV
l_buffer   VARCHAR2(2000); -- INVCONV

CURSOR c_item ( discrete_org_id  IN NUMBER -- INVCONV
              , discrete_item_id IN NUMBER) IS
       SELECT tracking_quantity_ind,
              secondary_uom_code,
              secondary_default_ind
              FROM mtl_system_items
     		        WHERE organization_id   = discrete_org_id
         		AND   inventory_item_id = discrete_item_id;

/*OPM 02/JUN/00 BEGIN
====================*/
--l_item_rec         OE_ORDER_CACHE.item_rec_type; -- OPM INVCONV
--l_OPM_UOM           VARCHAR2(4);    --OPM 06/22
--l_status            VARCHAR2(1);    --OPM 06/22
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);
l_return            NUMBER := 0;
/*OPM 02/JUN/00 END
==================*/

-- Added for Enhanced Project Validation
result                 VARCHAR2(1) := PJM_PROJECT.G_VALIDATE_SUCCESS;
errcode                VARCHAR2 (80);
l_order_date_type_code VARCHAR2(10);
p_date                 DATE;

-- AR System Parameters
l_AR_Sys_Param_Rec    AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;
l_sob_id              NUMBER;

 -- eBTax Changes
  l_ship_to_cust_Acct_id  hz_cust_Accounts.cust_Account_id%type;
  l_ship_to_party_id      hz_cust_accounts.party_id%type;
  l_ship_to_party_site_id hz_party_sites.party_site_id%type;
  l_bill_to_cust_Acct_id  hz_cust_Accounts.cust_Account_id%type;
  l_bill_to_party_id      hz_cust_accounts.party_id%type;
  l_bill_to_party_site_id hz_party_sites.party_site_id%type;
  l_org_id                NUMBER;
  -- l_legal_entity_id       NUMBER;

     cursor partyinfo(p_site_org_id HZ_CUST_SITE_USES_ALL.SITE_USE_ID%type) is
     SELECT cust_acct.cust_account_id,
            cust_Acct.party_id,
            acct_site.party_site_id,
            site_use.org_id
      FROM
            HZ_CUST_SITE_USES_ALL       site_use,
            HZ_CUST_ACCT_SITES_ALL      acct_site,
            HZ_CUST_ACCOUNTS_ALL        cust_Acct
     WHERE  site_use.site_use_id = p_site_org_id
       AND  site_use.cust_acct_site_id  = acct_site.cust_acct_site_id
       and  acct_site.cust_account_id = cust_acct.cust_account_id;

--bug 4729536
CURSOR cur_customer_relations IS

	    Select /*MOAC_SQL_NO_CHANGE*/ 'VALID' a
	    From   oe_invoice_to_orgs_v
	    WHERE site_use_id = p_line_rec.invoice_to_org_id
	    AND    status = 'A'
	    AND customer_id = p_line_rec.sold_to_org_id
	    and rownum =1

	    UNION ALL

	    SELECT /*MOAC_SQL_NO_CHANGE*/ 'VALID' a
	    FROM   oe_invoice_to_orgs_v oito
	    WHERE  oito.site_use_id = p_line_rec.invoice_to_org_id
	    AND    oito.status = 'A' AND
		EXISTS
		(
		    select 1 from HZ_CUST_ACCT_RELATE hcar
		    where hcar.CUST_ACCOUNT_ID = oito.customer_id
		    and hcar.RELATED_CUST_ACCOUNT_ID = p_line_rec.sold_to_org_id
		    /* added the following condition to fix the bug 2002486 */
		    and hcar.bill_to_flag = 'Y'
		)
		and rownum = 1 ;

BEGIN

    oe_debug_pub.add('Enter OE_CNCL_VALIDATE_LINE.ENTITY',1);


    -----------------------------------------------------------
    --  Check required attributes.
    -----------------------------------------------------------

    oe_debug_pub.add('1 '||l_return_status, 1);

    oe_debug_pub.add('2 '||l_return_status, 1);
    IF p_line_rec.inventory_item_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('INVENTORY_ITEM_ID'));
        OE_MSG_PUB.Add;

    END IF;

    oe_debug_pub.add('3 '||l_return_status, 1);
    IF  p_line_rec.line_type_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('LINE_TYPE_ID'));
        OE_MSG_PUB.Add;

    ELSIF p_line_rec.line_type_id IS NOT NULL THEN
               Validate_line_type(p_line_rec => p_line_rec);

    END IF;

    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --------------------------------------------------------------
    --  Check conditionally required attributes here.
    --------------------------------------------------------------

    --  For return lines, Return_Reason_Code is required
    oe_debug_pub.add('5 '||l_return_status, 1);
    IF p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE
       and p_line_rec.return_reason_code is NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_UTIL.Get_Attribute_Name('RETURN_REASON_CODE'));
        OE_MSG_PUB.Add;

    END IF;


    oe_debug_pub.add('6 '||l_return_status, 1);

    -- subinventory
    oe_debug_pub.add('Entity: subinventory - ' || p_line_rec.subinventory);

    IF p_line_rec.subinventory is not null THEN
	  IF p_line_rec.source_type_code = 'INTERNAL' OR
	     p_line_rec.source_type_code is null THEN
		oe_debug_pub.add('Entity Validateion:  subinventory', 1);
            IF p_line_rec.ship_from_org_id is null THEN
                 l_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_ATTRIBUTE_REQUIRED');
                 fnd_message.set_token('ATTRIBUTE',OE_Order_UTIL.Get_Attribute_Name('SHIP_FROM_ORG_ID'));
                 OE_MSG_PUB.Add;
            END IF;
          ELSE -- external
            l_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('ONT', 'OE_SUBINV_EXTERNAL');
            OE_MSG_PUB.Add;
          END IF;
    END IF;

    -- end subinventory

    oe_debug_pub.add('Entity: done subinv validation', 1);

    --  If line is booked, then check for the attributes required on booked lines
    --  Fix bug 1277092: this check not required for fully cancelled lines
    IF p_line_rec.booked_flag = 'Y'
	  AND p_line_rec.cancelled_flag <> 'Y' THEN
       Check_Book_Reqd_Attributes( p_line_rec	=> p_line_rec
         			   , x_return_status	=> l_return_status);

    END IF;

    --  Return Error if a conditionally required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    -- OPM 02/JUN/00 START
    -- For an item with tracking in Primary and secondary , check qty1/2 both present and sync'd -- INVCONV
    -- =====================================================================
    oe_debug_pub.add('Primary and Secondary X-VAL start', 1);

    OPEN c_item(   p_line_rec.ship_from_org_id,
                   p_line_rec.inventory_item_id
                              );
               FETCH c_item
                INTO   l_tracking_quantity_ind,
                       l_secondary_uom_code ,
                       l_secondary_default_ind
	               ;


               IF c_item%NOTFOUND THEN
		    l_tracking_quantity_ind := 'P';
	            l_secondary_uom_code := NULL;
	            l_secondary_default_ind := null;

	       END IF;

    Close c_item;



    /*IF OE_Line_Util.Process_Characteristics
                    (p_line_rec.inventory_item_id
                    ,p_line_rec.ship_from_org_id
                    ,l_item_rec)
    THEN
    */
      IF l_tracking_quantity_ind = 'PS' then
      -- IF l_item_rec.dualum_ind in (1,2,3) THEN INVCONV
        oe_debug_pub.add('Primary and Secondary X-VAL -  tracking_quantity_ind PS', 2);

        IF (p_line_rec.ordered_quantity <> FND_API.G_MISS_NUM OR
            p_line_rec.ordered_quantity IS NOT NULL) AND
           (p_line_rec.ordered_quantity2 = FND_API.G_MISS_NUM OR
            p_line_rec.ordered_quantity2 IS NULL) THEN

          oe_debug_pub.add('Primary and Secondary X-VAL qty 1 not empty', 2);

            l_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ordered_Quantity2');
            OE_MSG_PUB.Add;

        ELSIF (p_line_rec.ordered_quantity2 <> FND_API.G_MISS_NUM OR
               p_line_rec.ordered_quantity2 IS NOT NULL) AND
              (p_line_rec.ordered_quantity IS NULL) THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ordered_Quantity');
            OE_MSG_PUB.Add;
        END IF; -- IF (p_line_rec.ordered_quantity <> FND_API.G_MISS_NUM OR
      END IF; -- IF l_item_rec.tracking_quantity_ind = 'PS' IF l_item_rec.dualum_ind in (1,2,3) THEN

      /* If qty1/qty2 both populated, check tolerances
      ================================================*/
      oe_debug_pub.add('Primary and Secondary X-VAL - tolerance check', 2);

      IF l_secondary_default_ind in ('N','D')  then  -- INVCONV
       -- IF l_item_rec.dualum_ind in (2,3) THEN
        IF (p_line_rec.ordered_quantity <> FND_API.G_MISS_NUM AND
            p_line_rec.ordered_quantity IS NOT NULL) AND
           (p_line_rec.ordered_quantity2 <> FND_API.G_MISS_NUM AND
            p_line_rec.ordered_quantity2 IS NOT NULL) THEN

            -- check the deviation and error out
			       l_return := INV_CONVERT.Within_Deviation  -- INVCONV
			                       ( p_organization_id   =>
			                                 p_line_rec.ship_from_org_id
			                       , p_inventory_item_id =>
			                                 p_line_rec.inventory_item_id
			                       , p_precision         => 5
			                       , p_quantity          => p_line_rec.ordered_quantity
			                       , p_uom_code1         => p_line_rec.order_quantity_uom -- INVCONV
			                       , p_quantity2         => p_line_rec.ordered_quantity2
			                       , p_uom_code2         => l_secondary_uom_code );

			      IF l_return = 0
			      	then
			      	    IF l_debug_level  > 0 THEN
			    	  	oe_debug_pub.add('Primary and Secondary X-VAL - tolerance error 1' ,1);
			    	    END IF;

			    	    l_buffer := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, -- INVCONV
			                                         p_encoded => 'F');
			            oe_msg_pub.add_text(p_message_text => l_buffer);
			            IF l_debug_level  > 0 THEN
			              oe_debug_pub.add(l_buffer,1);
			    	    END IF;
			    	    l_return_status := FND_API.G_RET_STS_ERROR;

			     else
			      	    IF l_debug_level  > 0 THEN
			    	  	oe_debug_pub.add('Primary and Secondary X-VAL  - No tolerance error  ',1);
			    	    END IF;
			     END IF; -- IF l_return = 0


            -- OPM BEGIN 06/22
            /* Get the OPM equivalent code for order_quantity_uom
            ===================================================== INVCONV
            GMI_Reservation_Util.Get_OPMUOM_from_AppsUOM
                     (p_Apps_UOM       => p_line_rec.order_quantity_uom
                     ,x_OPM_UOM        => l_OPM_UOM
                     ,x_return_status  => l_status
                     ,x_msg_count      => l_msg_count
                     ,x_msg_data       => l_msg_data);

            l_return := GMICVAL.dev_validation(l_item_rec.opm_item_id
                                  ,0
                                  ,p_line_rec.ordered_quantity
                                  ,l_OPM_UOM
                                  ,p_line_rec.ordered_quantity2
                                  ,l_item_rec.opm_item_um2
                                  ,0);
          -- OPM END 06/22
          IF(l_return = -68) THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.set_name('GMI', 'IC_DEVIATION_HI_ERR');
            OE_MSG_PUB.Add;
          ELSIF (l_return = -69) THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.set_name('GMI', 'IC_DEVIATION_LO_ERR');
            OE_MSG_PUB.Add;
          END IF;   */


        END IF; -- IF (p_line_rec.ordered_quantity <> FND_API.G_MISS_NUM AND


      END IF; -- IF l_item_rec.tracking_quantity_ind = 'PS'  IF l_item_rec.dualum_ind in (2,3) THEN INVCONV

--     END IF; -- IF OE_Line_Util.Process_Characteristics INVCONV

    --  Return Error if a required quantity validation fails
    --  ====================================================
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --  OPM 02/JUN/00 END
    --  ===================


    ---------------------------------------------------------------------
    --  Validate attribute dependencies here.
    ---------------------------------------------------------------------

    -- Validate if the warehouse, item combination is valid
    IF p_line_rec.inventory_item_id is not null AND
       p_line_rec.ship_from_org_id is not null AND
       p_line_rec.inventory_item_id <> FND_API.G_MISS_NUM AND
       p_line_rec.ship_from_org_id  <> FND_API.G_MISS_NUM THEN

    /* IF p_line_rec.inventory_item_id <>
                                    nvl(p_old_line_rec.inventory_item_id,0) OR
          p_line_rec.ship_from_org_id <> nvl(p_old_line_rec.ship_from_org_id,0)
       THEN */



          IF p_line_rec.source_type_code = OE_GLOBALS.G_SOURCE_INTERNAL
		or p_line_rec.source_type_code is null
          THEN
             oe_debug_pub.add('Source Type is Internal',1);

            IF p_line_rec.line_category_code = 'RETURN' THEN
                l_item_type_code := OE_LINE_UTIL.Get_Return_item_type_code(
							p_line_rec);
            ELSE
			l_item_type_code := p_line_rec.item_type_code;
		  END IF;


            IF NOT Validate_Item_Warehouse
                    (p_line_rec.inventory_item_id,
                     p_line_rec.ship_from_org_id,
		     l_item_type_code,
                     p_line_rec.line_id,
                     p_line_rec.top_model_line_id)
            THEN
                      l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          ELSE
             oe_debug_pub.add('Source Type is External',1);
             IF NOT Validate_Receiving_Org
                    (p_line_rec.inventory_item_id,
                     p_line_rec.ship_from_org_id)
             THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
          END IF;
       --END IF;
    END IF;

    -- subinventory

    IF p_line_rec.ship_from_org_id is not null AND
       p_line_rec.subinventory is not null AND
       p_line_rec.ship_From_org_id <> FND_API.G_MISS_NUM AND
       p_line_rec.subinventory <> FND_API.G_MISS_CHAR THEN

    /* IF p_line_rec.ship_from_org_id <> nvl(p_old_line_rec.ship_from_org_id, 0) OR
          p_line_rec.subinventory <> nvl(p_old_line_rec.subinventory, '0') THEN
    */
            BEGIN
               SELECT 'VALID'
               INTO  l_dummy
               FROM MTL_SUBINVENTORIES_TRK_VAL_V
               WHERE organization_id = p_line_rec.ship_from_org_id
               AND secondary_inventory_name = p_line_rec.subinventory;
            EXCEPTION
               WHEN OTHERS THEN
                   -- not a valid subinventory, show show a msg
                   l_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
            END;
       --END IF;
     END IF;

     -- end subinventory

    -- start decimal qty validation
    IF p_line_rec.inventory_item_id is not null THEN

       oe_debug_pub.add('decimal1',2);
       IF p_line_rec.order_quantity_uom is not null THEN

         -- validate ordered quantity
	    Validate_Decimal_Quantity
					(p_item_id	=> p_line_rec.inventory_item_id
					,p_item_type_code 	=> p_line_rec.item_type_code
					,p_input_quantity 	=> p_line_rec.ordered_quantity
					,p_uom_code		=> p_line_rec.order_quantity_uom
					,x_return_status	=> l_return_status
					);

         -- validate invoiced_quantity
	    Validate_Decimal_Quantity
					(p_item_id	=> p_line_rec.inventory_item_id
					,p_item_type_code 	=> p_line_rec.item_type_code
					,p_input_quantity 	=> p_line_rec.invoiced_quantity
					,p_uom_code		=> p_line_rec.order_quantity_uom
					,x_return_status	=> l_return_status
					);

         -- cancelled quantity
	    Validate_Decimal_Quantity
					(p_item_id	=> p_line_rec.inventory_item_id
					,p_item_type_code 	=> p_line_rec.item_type_code
					,p_input_quantity 	=> p_line_rec.cancelled_quantity
					,p_uom_code		=> p_line_rec.order_quantity_uom
					,x_return_status	=> l_return_status
					);

         -- auto_selected quantity
	    Validate_Decimal_Quantity
					(p_item_id	=> p_line_rec.inventory_item_id
					,p_item_type_code 	=> p_line_rec.item_type_code
					,p_input_quantity 	=> p_line_rec.auto_selected_quantity
					,p_uom_code		=> p_line_rec.order_quantity_uom
					,x_return_status	=> l_return_status
					);

         -- reserved quantity
	    Validate_Decimal_Quantity
					(p_item_id	=> p_line_rec.inventory_item_id
					,p_item_type_code 	=> p_line_rec.item_type_code
					,p_input_quantity 	=> p_line_rec.reserved_quantity
					,p_uom_code		=> p_line_rec.order_quantity_uom
					,x_return_status	=> l_return_status
					);

         -- fulfilled quantity, double check with Shashi
	    Validate_Decimal_Quantity
					(p_item_id	=> p_line_rec.inventory_item_id
					,p_item_type_code 	=> p_line_rec.item_type_code
					,p_input_quantity 	=> p_line_rec.fulfilled_quantity
					,p_uom_code		=> p_line_rec.order_quantity_uom
					,x_return_status	=> l_return_status
					);

	 END IF; -- order quantity uom not null

      -- validate pricing quantity starts here
      -- bug 1391668, don't need to validate pricing quantity
      /*
      IF (p_line_rec.pricing_quantity_uom is not null AND
           p_line_rec.pricing_quantity is not null) THEN

	    Validate_Decimal_Quantity
					(p_item_id	     => p_line_rec.inventory_item_id
					,p_item_type_code 	=> p_line_rec.item_type_code
					,p_input_quantity 	=> p_line_rec.pricing_quantity
					,p_uom_code		=> p_line_rec.pricing_quantity_uom
					,x_return_status	=> l_return_status
					);

       END IF; -- quantity or uom is null
       */
    END IF; -- inventory_item_id is null
    -- end decimal quantity validation


    -- Error if reserved quantity > ordered quantity
   /* IF NOT OE_GLOBALS.Equal(p_line_rec.reserved_quantity,p_old_line_rec.reserved_quantity)
    THEN

        IF (p_line_rec.reserved_quantity > p_line_rec.ordered_quantity) THEN
            fnd_message.set_name('ONT','OE_SCH_RES_MORE_ORD_QTY');
            OE_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;*/


    -- Check to see if the user has changed both the Schedule Ship Date
    -- and Schedule Arrival Date. This is not allowed. The user can change
    -- either one, but not both.

/*
     IF (NOT OE_GLOBALS.Equal(p_line_rec.schedule_ship_date,
                             p_old_line_rec.schedule_ship_date)) AND
        (NOT OE_GLOBALS.Equal(p_line_rec.schedule_arrival_date,
                             p_old_line_rec.schedule_arrival_date)) AND
        (OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING = 'Y') THEN

        -- Config item is created and passed by the CTO team. So this is
        -- is the only item type, which when gets created, already has
        -- Schedule_Ship_Date and schedule_Arrival_date. We should not
        -- error out for this item.

        IF p_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_CONFIG THEN
           FND_MESSAGE.SET_NAME('ONT','OE_SCH_INVALID_CHANGE');
           OE_MSG_PUB.Add;
           l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

     END IF;
*/

    Validate_Source_Type
    ( p_line_rec      => p_line_rec
     ,x_return_status => l_return_status);

    -- PJM validation.

    IF PJM_UNIT_EFF.ENABLED = 'Y' THEN

        IF (p_line_rec.project_id IS NOT NULL
	   AND p_line_rec.ship_from_org_id IS NULL) THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
	       FND_MESSAGE.SET_NAME('ONT', 'OE_SHIP_FROM_REQD');
		  OE_MSG_PUB.add;
         ELSIF (p_line_rec.task_id IS NOT NULL
           AND p_line_rec.project_id IS NULL)  THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('ONT', 'OE_VAL_PROJECT_REQD');
                  OE_MSG_PUB.add;

         END IF;

            -- Added Code for Enhanced Project Validation and Controls.

            l_order_date_type_code := NVL(OE_SCHEDULE_UTIL.Get_Date_Type(
                                            p_line_rec.header_id), 'SHIP');


                     IF l_order_date_type_code = 'SHIP' THEN
                        p_date := NVL(p_line_rec.schedule_ship_date,
                                            p_line_rec.request_date);
                     ELSIF l_order_date_type_code = 'ARRIVAL' THEN
                        p_date := NVL(p_line_rec.schedule_arrival_date,
                                            p_line_rec.request_date);
                     END IF;

                   OE_DEBUG_PUB.Add('Before calling Validate Proj References',1);

                     result := PJM_PROJECT.VALIDATE_PROJ_REFERENCES
                       ( X_inventory_org_id => p_line_rec.ship_from_org_id
                       , X_operating_unit   => p_line_rec.org_id
                       , X_project_id       => p_line_rec.project_id
                       , X_task_id          => p_line_rec.task_id
                       , X_date1            => p_date
                       , X_date2            => NULL
                       , X_calling_function =>'OEXVCLNB'
                       , X_error_code       => errcode
                       );
                   OE_DEBUG_PUB.Add('Validate Proj References Error:'||
                                                    errcode,1);
                   OE_DEBUG_PUB.Add('Validate Proj References Result:'||
                                                   result,1);

                          IF result <> PJM_PROJECT.G_VALIDATE_SUCCESS  THEN
                                OE_MSG_PUB.Transfer_Msg_Stack;
                                l_msg_count:=OE_MSG_PUB.COUNT_MSG;
                                   FOR I in 1..l_msg_count loop
                                      l_msg_data := OE_MSG_PUB.Get(I,'F');
                                      OE_DEBUG_PUB.add(l_msg_data,1);
                                   END LOOP;
                           END IF;

                IF result = PJM_PROJECT.G_VALIDATE_FAILURE  THEN
                   l_return_status := FND_API.G_RET_STS_ERROR;
                   OE_DEBUG_PUB.Add('PJM Validation API returned with Errors',1);
                ELSIF result = PJM_PROJECT.G_VALIDATE_WARNING  THEN
                   OE_DEBUG_PUB.Add('PJM Validation API returned with Warnings',1);
                END IF;



/*  -- Commented Code for Enhanced Project Validation and Controls

	   ELSIF ( p_line_rec.ship_from_org_id IS NOT NULL AND
	           p_line_rec.project_id IS NOT NULL) THEN

             --  Validate project/warehouse combination.
		   IF pjm_project.val_proj_idtonum
		     (p_line_rec.project_id,
		      p_line_rec.ship_from_org_id) IS NULL THEN

                 l_return_status := FND_API.G_RET_STS_ERROR;
	            FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_SHIP_FROM_PROJ');
		       OE_MSG_PUB.add;
             END IF;

        END IF;

        IF (p_line_rec.task_id IS NOT NULL
	   AND p_line_rec.project_id IS NULL)  THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
	       FND_MESSAGE.SET_NAME('ONT', 'OE_VAL_PROJECT_REQD');
		  OE_MSG_PUB.add;

	   ELSIF (p_line_rec.task_id is NOT NULL
	   AND p_line_rec.project_id IS NOT NULL) THEN

	     IF NOT Validate_task(
		       p_line_rec.project_id,
		   	  p_line_rec.task_id) THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;
                  OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TASK_ID');
		        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
						OE_Order_Util.Get_Attribute_Name('task_id'));
			   OE_MSG_PUB.Add;
			   OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

		 END IF;

	   ELSIF (p_line_rec.task_id is  NULL
	   AND p_line_rec.project_id IS NOT NULL) THEN

	      IF   Validate_task_reqd(
		       p_line_rec.project_id,
		   	  p_line_rec.ship_from_org_id) THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;
			   FND_MESSAGE.SET_NAME('ONT', 'OE_VAL_TASK_REQD');
			   OE_MSG_PUB.ADD;

		 END IF;

        END IF;
*/

        -- End Item Unit number logic.

        oe_debug_pub.add('10 '||l_return_status, 1);
        IF (p_line_rec.inventory_item_id IS NOT NULL) AND
		   (p_line_rec.ship_from_org_id IS NOT NULL) AND
		   (p_line_rec.end_item_unit_number IS NULL) THEN

              IF PJM_UNIT_EFF.UNIT_EFFECTIVE_ITEM
			(p_line_rec.inventory_item_id,p_line_rec.ship_from_org_id) = 'Y'
		    THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;
			   fnd_message.set_name('ONT', 'OE_UEFF_NUMBER_REQD');
		        OE_MSG_PUB.add;
		    END IF;

        END IF;
    ELSE -- When project manufacturing is not enabled at the site.

        IF (p_line_rec.project_id IS NOT NULL OR
		  p_line_rec.task_id    IS NOT NULL OR
		  p_line_rec.end_item_unit_number IS NOT NULL) THEN
                  l_return_status := FND_API.G_RET_STS_ERROR;
			   fnd_message.set_name('ONT', 'OE_PJM_NOT_INSTALLED');
		        OE_MSG_PUB.add;

	   END IF;


    END IF; --End if PJM_UNIT_EFF.ENABLED

    -- Donot allow to update project and task when a option/class is under ATO
    -- Model.

    oe_debug_pub.add('11 '||l_return_status, 1);

    /*IF p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

           IF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
               p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS)
               --AND p_line_rec.line_id <> p_line_rec.ato_line_id
               THEN

                   FND_MESSAGE.SET_NAME('ONT', 'OE_VAL_PROJ_UPD');
    		   OE_MSG_PUB.add;


           END IF;

    END IF;
    -- End of PJM validation.
    */

    -- Validate if item, item_identifier_type, inventory_item combination is valid
    oe_debug_pub.add('12-1 '||l_return_status, 1);
    IF p_line_rec.inventory_item_id IS NOT NULL  THEN

       IF NOT Validate_Item_Fields
              (  p_line_rec.inventory_item_id
               , p_line_rec.ordered_item_id
               , p_line_rec.item_identifier_type
               , p_line_rec.ordered_item
               , p_line_rec.sold_to_org_id)
       THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT', 'OE_ITEM_VALIDATION_FAILED');
          OE_MSG_PUB.add;
       END IF;

    END IF;

    oe_debug_pub.add('12 '||l_return_status, 1);
    -- Validate if return item and item on referenced sales order line mismatch
    IF (p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE and
        p_line_rec.reference_line_id is not null and
       p_line_rec.inventory_item_id IS NOT NULL)
    THEN
       IF NOT Validate_Return_Item_Mismatch
              (  p_line_rec.reference_line_id
               , p_line_rec.inventory_item_id
              )
       THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT', 'OE_RETURN_ITEM_MISMATCH_REJECT');
          OE_MSG_PUB.add;
       END IF;
    END IF;

    oe_debug_pub.add('13 '||l_return_status, 1);

    -- Validate if returning a fulfilled sales order line
    IF (p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE and
       p_line_rec.reference_line_id is not null)
     THEN
       IF NOT Validate_Return_Fulfilled_Line
              (  p_line_rec.reference_line_id
              )
       THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT', 'OE_UNFULFILLED_LINE_REJECT');
          OE_MSG_PUB.add;
       END IF;

    END IF;

    oe_debug_pub.add('14 '||l_return_status, 1);

    -- Validate if item on the Return is Returnable
    IF (p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE and
       p_line_rec.inventory_item_id IS NOT NULL)
    THEN
       IF NOT Validate_Return_Item(p_line_rec.inventory_item_id,
                         p_line_rec.ship_from_org_id)
       THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT', 'OE_ITEM_NOT_RETURNABLE');
          OE_MSG_PUB.add;
       END IF;
    END IF;


    oe_debug_pub.add('14_1 '||l_return_status, 1);

    -- Validate if Reference SO Line is Valid
    IF (p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE and
      p_line_rec.reference_line_id is not null)
    THEN
       IF NOT Validate_Return_Reference(p_line_rec.reference_line_id)
       THEN
          -- Message is populated in the function
          l_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;

    oe_debug_pub.add('14_2 '||l_return_status, 1);

    -- Validate the quantity = 1 on RMA for Serial Number reference
    IF (p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE and
      p_line_rec.reference_line_id is not null and
      p_line_rec.return_context = 'SERIAL' and
      NVL(p_line_rec.ordered_quantity,1) <> 1)
    THEN
       l_return_status := FND_API.G_RET_STS_ERROR;
	  fnd_message.set_name('ONT','OE_SERIAL_REFERENCED_RMA');
       OE_MSG_PUB.Add;
    END IF;


    oe_debug_pub.add('14_3 '||l_return_status, 1);

	-- Validation of Ship To Org Id.
	IF p_line_rec.ship_to_org_id IS NOT NULL

	THEN

		IF	NOT Validate_Ship_To_Org(p_line_rec.ship_to_org_id,
									 p_line_rec.sold_to_org_id
										 ) THEN
               l_return_status := FND_API.G_RET_STS_ERROR;
		     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_Util.Get_Attribute_Name('ship_to_org_id'));
			OE_MSG_PUB.Add;
		END IF;

	END IF;


     --    Ship to contact depends on Ship To Org
	IF p_line_rec.ship_to_contact_id IS NOT NULL

	THEN

        BEGIN
          oe_debug_pub.add('ship_to_contact_id :'||to_char(p_line_rec.ship_to_contact_id),2);

        SELECT  /* MOAC_SQL_CHANGE */ 'VALID'
        INTO    l_dummy
        FROM    HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
              , HZ_CUST_ACCT_SITES ACCT_SITE
              , HZ_CUST_SITE_USES_ALL   SHIP
        WHERE   ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_line_rec.ship_to_contact_id
        AND   ACCT_ROLE.CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID
        AND   ACCT_SITE.CUST_ACCT_SITE_ID = SHIP.CUST_ACCT_SITE_ID
        AND   ACCT_ROLE.ROLE_TYPE = 'CONTACT'
        AND   SHIP.SITE_USE_ID = p_line_rec.ship_to_org_id
        AND   SHIP.STATUS = 'A'
        AND   ROWNUM = 1;

/* Replaced ra_contacts , ra_addresses and ra_site_uses with HZ Tables , to fix the bug 1888440 */


        EXCEPTION
		WHEN NO_DATA_FOUND THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              	OE_Order_Util.Get_Attribute_Name('ship_to_contact_id'));
              OE_MSG_PUB.Add;
		WHEN OTHERS THEN
            IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              OE_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME ,
                'Record - Ship To Contact validation '
              );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

     END IF;


	-- Validation of Deliver To Org Id.
	IF  p_line_rec.deliver_to_org_id IS NOT NULL

	THEN

		IF	NOT Validate_Deliver_To_Org(p_line_rec.deliver_to_org_id,
									 p_line_rec.sold_to_org_id
										 ) THEN
               l_return_status := FND_API.G_RET_STS_ERROR;
		     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('deliver_to_org_id'));
			OE_MSG_PUB.Add;
		END IF;

	END IF;

     --    Deliver to contact depends on Deliver To Org
	IF p_line_rec.deliver_to_contact_id IS NOT NULL

	THEN

        BEGIN
         oe_debug_pub.add('deliver_to_contact_id :'||to_char(p_line_rec.deliver_to_contact_id),2);

        SELECT  /* MOAC_SQL_CHANGE */ 'VALID'
        INTO    l_dummy
        FROM    HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
              , HZ_CUST_ACCT_SITES ACCT_SITE
              , HZ_CUST_SITE_USES_ALL   DELI
        WHERE   ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_line_rec.deliver_to_contact_id
        AND   ACCT_ROLE.CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID
        AND   ACCT_ROLE.ROLE_TYPE = 'CONTACT'
        AND   ACCT_SITE.CUST_ACCT_SITE_ID = DELI.CUST_ACCT_SITE_ID
        AND   DELI.SITE_USE_ID = p_line_rec.deliver_to_org_id
        AND   DELI.STATUS = 'A'
        AND   ROWNUM = 1;

/* Replaced ra_contacts , ra_addresses and ra_site_uses with HZ Tables , to fix the bug 1888440 */


        EXCEPTION
		WHEN NO_DATA_FOUND THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              	OE_Order_Util.Get_Attribute_Name('deliver_to_contact_id'));
              OE_MSG_PUB.Add;
		WHEN OTHERS THEN
            IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              OE_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME ,
                'Record - Deliver To Contact validation '
              );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

     END IF;

	-- Validation of Invoice To Org Id.
	IF p_line_rec.invoice_to_org_id IS NOT NULL

	THEN

        BEGIN
            oe_debug_pub.add('invoice_to_org_id :'||to_char(p_line_rec.invoice_to_org_id),2);
  --lcustomer_relations := FND_PROFILE.VALUE('ONT_CUSTOMER_RELATIONSHIPS');

    IF nvl(lcustomer_relations,'N') = 'N' THEN

            Select 'VALID'
            Into   l_dummy
            From   oe_invoice_to_orgs_v
            Where  customer_id = p_line_rec.sold_to_org_id
            And    site_use_id = p_line_rec.invoice_to_org_id;

    ELSIF lcustomer_relations = 'Y' THEN

    /*Select MOAC_SQL_NO_CHANGE 'VALID'
    Into   l_dummy
    From   oe_invoice_to_orgs_v
    WHERE site_use_id = p_line_rec.invoice_to_org_id
    AND    status = 'A' AND
    customer_id in (
                    Select p_line_rec.sold_to_org_id from dual
                    union
                    select CUST_ACCOUNT_ID from
                    HZ_CUST_ACCT_RELATE
                    where RELATED_CUST_ACCOUNT_ID = p_line_rec.sold_to_org_id
/* added the following condition to fix the bug 2002486
                    and bill_to_flag = 'Y')
    and rownum = 1;*/

    --bug 4729536
    OPEN cur_customer_relations;
    FETCH cur_customer_relations INTO l_dummy ;
    CLOSE cur_customer_relations;

/* Replaced ra_customer_relationships with HZ Table , to fix the bug 1888440 */


/* added the following ELSIF condition to fix the bug 2002486 */

    ELSIF nvl(lcustomer_relations,'N') = 'A' THEN
        oe_debug_pub.add
        ('Cr: A',2);

        SELECT 'VALID'
        INTO   l_dummy
        From   oe_invoice_to_orgs_v
        WHERE  site_use_id = p_line_rec.invoice_to_org_id
        AND    ROWNUM = 1;


    END IF;

        EXCEPTION
		WHEN NO_DATA_FOUND THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              		OE_Order_Util.Get_Attribute_Name('invoice_to_org_id'));
              OE_MSG_PUB.Add;
		WHEN OTHERS THEN
            IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              OE_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME ,
                'Record - Invoice To Org validation '
              );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

     END IF;

	-- Validation of Invoice To Contact Id.
	IF  p_line_rec.invoice_to_contact_id IS NOT NULL

	THEN

        BEGIN
         oe_debug_pub.add('invoice_to_contact_id :'||to_char(p_line_rec.invoice_to_contact_id),2);

          SELECT  /* MOAC_SQL_CHANGE */ 'VALID'
          INTO    l_dummy
          FROM    HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
                , HZ_CUST_ACCT_SITES ACCT_SITE
                , HZ_CUST_SITE_USES_ALL   INV
          WHERE   ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_line_rec.invoice_to_contact_id
          AND   ACCT_ROLE.CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID
          AND   ACCT_ROLE.ROLE_TYPE = 'CONTACT'
          AND   ACCT_SITE.CUST_ACCT_SITE_ID = INV.CUST_ACCT_SITE_ID
          AND   INV.SITE_USE_ID = p_line_rec.invoice_to_org_id
          AND   ROWNUM = 1;

/* Replaced ra_contacts , ra_addresses and ra_site_uses with HZ Tables , to fix the bug 1888440 */


        EXCEPTION
		WHEN NO_DATA_FOUND THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              	OE_Order_Util.Get_Attribute_Name('invoice_to_contact_id'));
              OE_MSG_PUB.Add;
		WHEN OTHERS THEN
            IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              OE_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME ,
                'Record - Invoice To Contact validation '
              );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

     END IF;


   /* Added by Manish */

    -- Validating Tax Information
    IF p_line_rec.tax_code IS NOT NULL AND
       p_line_rec.tax_date IS NOT NULL

    THEN
       BEGIN
	-- eBTax changes
/*       IF oe_code_control.code_release_level < '110510' THEN
            SELECT 'VALID'
            INTO   l_dummy
            FROM   AR_VAT_TAX V,
                   AR_SYSTEM_PARAMETERS P
            WHERE  V.TAX_CODE = p_line_rec.tax_code
            AND V.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
            AND NVL(V.TAX_CLASS,'O')='O'
            AND NVL(V.DISPLAYED_FLAG,'Y')='Y'
            AND ROWNUM = 1;
       ELSE
           l_AR_Sys_Param_Rec := OE_Sys_Parameters_Pvt.Get_AR_Sys_Params(p_line_rec.org_id);
           l_sob_id           := l_AR_Sys_Param_Rec.set_of_books_id;
             SELECT 'VALID'
             INTO   l_dummy
             FROM   AR_VAT_TAX V
             WHERE  V.TAX_CODE = p_line_rec.tax_code
             AND V.SET_OF_BOOKS_ID = l_sob_id
             AND NVL(V.TAX_CLASS,'O')='O'
             AND NVL(V.DISPLAYED_FLAG,'Y')='Y'
             AND ROWNUM = 1;
       END IF;*/

       SELECT 'VALID'
         INTO l_dummy
         FROM ZX_OUTPUT_CLASSIFICATIONS_V lk
        WHERE lk.lookup_code = p_line_rec.tax_code
          --AND lk.lookup_type = 'ZX_OUTPUT_CLASSIFICATIONS'
          AND lk.ENABLED_FLAG ='Y'
          AND lk.ORG_ID IN (p_line_rec.org_id, -99)
          AND TRUNC(p_line_rec.tax_date) BETWEEN TRUNC(lk.START_DATE_ACTIVE)
       		AND   TRUNC(NVL(lk.END_DATE_ACTIVE, p_line_rec.tax_date))
          AND ROWNUM = 1;


        EXCEPTION

		WHEN NO_DATA_FOUND THEN
		    l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              		OE_Order_Util.Get_Attribute_Name('TAX_CODE'));
              OE_MSG_PUB.Add;

		WHEN OTHERS THEN
		    IF OE_MSG_PUB.Check_Msg_Level (
			OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		    THEN
			OE_MSG_PUB.Add_Exc_Msg
			(	G_PKG_NAME ,
				'Record - Tax Code validation '
			);
		    END IF;
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END; -- BEGIN
    END IF;

    -- If the Tax handling is "Exempt"

    IF p_line_rec.tax_exempt_flag = 'E'
    THEN
	   -- Check for Tax exempt reason
	   IF p_line_rec.tax_exempt_reason_code IS NULL
	   THEN
	       l_return_status := FND_API.G_RET_STS_ERROR;
	       IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
	       THEN
                fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
	           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              		OE_Order_Util.Get_Attribute_Name('TAX_EXEMPT_REASON_CODE'));
	           OE_MSG_PUB.Add;
	       END IF;
        END IF;
    END IF; -- If Tax handling is exempt

    -- If the TAX handling is STANDARD THEN we can not validate for
    -- exemption number because it can be a NULL value.


    -- If the Tax handling is "Required" then Tax Exempt Number and
    -- Tax Exempt Reason should be NULL.

    IF p_line_rec.tax_exempt_flag = 'R' AND
	  (p_line_rec.tax_exempt_number IS NOT NULL OR
	   p_line_rec.tax_exempt_reason_code IS NOT NULL)
    THEN
	   l_return_status := FND_API.G_RET_STS_ERROR;
	   IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
		  fnd_message.set_name('ONT','OE_TAX_EXEMPTION_NOT_ALLOWED');
            OE_MSG_PUB.Add;
	   END IF;

    END IF; -- If Tax handling is Required

    --	Check for Tax Exempt number/ Tax Exempt reason code depends on
    --    following attributes if the Tax_exempt_flag = 'S' (Standard)

    IF p_line_rec.tax_exempt_flag IS NOT NULL

    THEN

	   BEGIN
		-- eBtax changes
		  IF p_line_rec.tax_exempt_flag = 'S' and  --* recheck (for 'E' ??)
			p_line_rec.tax_exempt_number IS NOT NULL and
			p_line_rec.tax_exempt_reason_code IS NOT NULL and
			p_line_rec.tax_code IS NOT NULL
		  THEN

		   /*  SELECT 'VALID'
		       INTO l_dummy
		       FROM OE_TAX_EXEMPTIONS_QP_V
		       WHERE TAX_EXEMPT_NUMBER = p_line_rec.tax_exempt_number
		       AND TAX_EXEMPT_REASON_CODE=p_line_rec.tax_exempt_reason_code
		       AND SHIP_TO_ORG_ID = nvl(p_line_rec.ship_to_org_id,
                 p_line_rec.invoice_to_org_id)
		       AND BILL_TO_CUSTOMER_ID = p_line_rec.sold_to_org_id
		       AND TAX_CODE = p_line_rec.tax_code
		       AND STATUS_CODE = 'PRIMARY'
		       AND ROWNUM = 1;*/


	       open partyinfo(p_line_rec.invoice_to_org_id);
               fetch partyinfo into l_bill_to_cust_Acct_id,
                                    l_bill_to_party_id,
                                    l_bill_to_party_site_id,
                                    l_org_id;
               close partyinfo;

               if p_line_rec.ship_to_org_id = p_line_rec.invoice_to_org_id then
                  l_ship_to_cust_Acct_id    :=  l_bill_to_cust_Acct_id;
                  l_ship_to_party_id        :=  l_bill_to_party_id;
                  l_ship_to_party_site_id   :=  l_bill_to_party_site_id ;
               else
                  open partyinfo(p_line_rec.ship_to_org_id);
                  fetch partyinfo into l_ship_to_cust_Acct_id,
                                    l_ship_to_party_id,
                                    l_ship_to_party_site_id,
                                    l_org_id;
                  close partyinfo;
               end if;


               SELECT 'VALID'
                 INTO l_dummy
                 FROM ZX_EXEMPTIONS_V
                WHERE EXEMPT_CERTIFICATE_NUMBER = p_line_rec.tax_exempt_number
                  AND EXEMPT_REASON_CODE = p_line_rec.tax_exempt_reason_code
                  AND nvl(site_use_id,nvl(p_line_rec.ship_to_org_id,
                                        p_line_rec.invoice_to_org_id))
                      =  nvl(p_line_rec.ship_to_org_id,
                                        p_line_rec.invoice_to_org_id)
                  AND nvl(cust_account_id, l_bill_to_cust_acct_id) = l_bill_to_cust_acct_id
                  AND nvl(PARTY_SITE_ID,nvl(l_ship_to_party_site_id, l_bill_to_party_site_id))=
                                    nvl(l_ship_to_party_site_id, l_bill_to_party_site_id)
                  AND  org_id = l_org_id
                  AND  party_id = l_bill_to_party_id
     --           AND nvl(LEGAL_ENTITY_ID,-99) IN (nvl(l_legal_entity_id, legal_entity_id), -99)
                  AND EXEMPTION_STATUS_CODE = 'PRIMARY'

     -- **** Check with OM team whether the join based on date is required or not ****
     --             AND TRUNC(NVL(p_line_rec.request_date,sysdate))
     --                   BETWEEN TRUNC(EFFECTIVE_FROM)
     --                           AND TRUNC(NVL(EFFECTIVE_TO,NVL(p_line_rec.request_date,sysdate)))
                  AND ROWNUM = 1;

            END IF;

		--  Valid Tax Exempt Number.

	  EXCEPTION

		WHEN NO_DATA_FOUND THEN

		    l_return_status := FND_API.G_RET_STS_ERROR;

		    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
		    THEN
	          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              		OE_Order_Util.Get_Attribute_Name('TAX_EXEMPT_NUMBER'));
			OE_MSG_PUB.Add;
		    END IF;

		WHEN OTHERS THEN
		    IF OE_MSG_PUB.Check_Msg_Level (
			OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		    THEN
			OE_MSG_PUB.Add_Exc_Msg
			(	G_PKG_NAME ,
				'Record - Tax Exemptions '
			);
		    END IF;
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END; -- BEGIN

    END IF; -- Tax exempton info validation.
 /* Added by Manish */

   -- order_quantity_uom should be primary uom for model/class/option.
     IF  p_line_rec.order_quantity_uom is not null

     THEN

     IF ( p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION ) THEN
      BEGIN
         SELECT primary_uom_code
         INTO   l_uom
         FROM   mtl_system_items
         WHERE  inventory_item_id = p_line_rec.inventory_item_id
         AND    organization_id   = nvl(p_line_rec.ship_from_org_id,
                                    OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID'));


         oe_debug_pub.add('primary uom: '|| l_uom, 1);
         oe_debug_pub.add('uom entered: '||p_line_rec.order_quantity_uom , 1);

         IF l_uom <> p_line_rec.order_quantity_uom
         THEN
            oe_debug_pub.add('uom other than primary uom is entered', 1);

            fnd_message.set_name('ONT','OE_INVALID_ORDER_QUANTITY_UOM');
            fnd_message.set_token('ITEM',p_line_rec.ordered_item );
            fnd_message.set_token('UOM', l_uom);
            OE_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      EXCEPTION
         when no_data_found then
            oe_debug_pub.add('OEXLLINB, no_data_found in uom validation', 1);
            RAISE FND_API.G_EXC_ERROR;
      END;

     ELSE -- not ato related, validate item, uom combination
     /*  commenting for 8993157
        SELECT count(*)
        INTO l_uom_count
        FROM mtl_item_uoms_view
        WHERE inventory_item_id = p_line_rec.inventory_item_id
        AND uom_code = p_line_rec.order_quantity_uom
	   AND organization_id = nvl(p_line_rec.ship_from_org_id,
                                 OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID'));


        IF l_uom_count = 0 THEN
            oe_debug_pub.add('uom/item combination invalid',2);
            fnd_message.set_name('ONT', 'OE_INVALID_ITEM_UOM');
            OE_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
   */

  l_ret_status :=
                   inv_convert.validate_item_uom(p_line_rec.order_quantity_uom,
                                                 p_line_rec.inventory_item_id,
                                                 nvl(p_line_rec.ship_from_org_id,
                                                 OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID')));
        IF NOT l_ret_status THEN
             if l_debug_level > 0 then
                oe_debug_pub.add('uom/item combination invalid',2);
             end if;

            fnd_message.set_name('ONT', 'OE_INVALID_ITEM_UOM');
            OE_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;


     END IF;
   END IF;

    If p_line_rec.agreement_id is not null and
	  NOT OE_GLOBALS.EQUAL(p_line_rec.agreement_id, fnd_api.g_miss_num) then
	 If not oe_globals.equal(p_line_rec.agreement_id,null) then

	-- Check for Agreement +sold_org_id

	-- Where cluase added to check start and end date for agreements
	-- Geresh

		BEGIN
		  BEGIN
              select list_type_code
		    into l_list_type_code
		    from qp_list_headers_vl
		    where list_header_id = p_line_rec.price_list_id;
		  EXCEPTION WHEN NO_DATA_FOUND THEN
		    null;
            END;

          BEGIN
			SELECT name ,sold_to_org_id , price_list_id
			INTO   l_agreement_name,l_sold_to_org,l_price_list_id
			FROM   oe_agreements_v
			WHERE  agreement_id = p_line_rec.agreement_id;
		  EXCEPTION WHEN NO_DATA_FOUND THEN
		    null;
            END;


          IF NOT OE_GLOBALS.EQUAL(l_list_type_code,'PRL') THEN
		-- any price list with 'PRL' type should be allowed to
		-- be associated with any agreement according to bug 1386406.
	  		IF NOT OE_GLOBALS.EQUAL(l_price_list_id, p_line_rec.price_list_id) THEN
          		fnd_message.set_name('ONT', 'OE_INVALID_AGREEMENT_PLIST');
          		fnd_message.set_Token('AGREEMENT_NAME', l_agreement_name);
				BEGIN
					SELECT name
                         INTO   l_price_list_name
					FROM   qp_List_headers_vl
					WHERE  list_header_id = p_line_rec.price_list_id;

					Exception when no_data_found then
						l_price_list_name := p_line_rec.price_list_id;
				END;
          		fnd_message.set_Token('PRICE_LIST1', l_price_list_name);
				BEGIN

					SELECT name
                         INTO   l_price_list_name
					FROM   QP_List_headers_vl
					WHERE  list_header_id = l_price_list_id;
				EXCEPTION
                       WHEN NO_DATA_FOUND THEN
						l_price_list_name := l_price_list_id;
				END;
          		fnd_message.set_Token('PRICE_LIST2', l_price_list_name);
          		OE_MSG_PUB.Add;
				oe_debug_pub.add('Invalid Agreement +price_list_id combination',2);
	  			raise FND_API.G_EXC_ERROR;
			END IF;
            END IF;    -- end of if l_list_type_code <> 'PRL'


		-- modified by lkxu, to check for customer relationships.
        IF l_sold_to_org IS NOT NULL AND l_sold_to_org <> -1
	 	AND NOT OE_GLOBALS.EQUAL(l_sold_to_org,p_line_rec.sold_to_org_id) THEN
    		IF nvl(lcustomer_relations,'N') = 'N' THEN
          		fnd_message.set_name('ONT', 'OE_INVALID_AGREEMENT');
          		fnd_message.set_Token('AGREEMENT_ID', p_line_rec.agreement_id);
          		fnd_message.set_Token('AGREEMENT_NAME', l_agreement_name);
          		fnd_message.set_Token('CUSTOMER_ID', p_line_rec.sold_to_org_id);
          		OE_MSG_PUB.Add;
				oe_debug_pub.add('Invalid Agreement +sold_org_id combination',2);
	  			RAISE FND_API.G_EXC_ERROR;
      	ELSIF lcustomer_relations = 'Y' THEN

			BEGIN
			  SELECT 	'VALID'
			  INTO 	l_dummy
			  FROM 	dual
			  WHERE 	exists(
                        select 'x' from
                        HZ_CUST_ACCT_RELATE
                        where RELATED_CUST_ACCOUNT_ID = p_line_rec.sold_to_org_id
                        AND CUST_ACCOUNT_ID = l_sold_to_org

					);

				oe_debug_pub.add('Linda -- l_dummy is: '||l_dummy,2);
/* Replaced ra_customer_relationships with HZ Table to fix the bug 1888440 */

	  		EXCEPTION
                 WHEN NO_DATA_FOUND THEN
          		fnd_message.set_name('ONT', 'OE_INVALID_AGREEMENT');
          		fnd_message.set_Token('AGREEMENT_ID', p_line_rec.agreement_id);
          		fnd_message.set_Token('AGREEMENT_NAME', l_agreement_name);
          		fnd_message.set_Token('CUSTOMER_ID', p_line_rec.sold_to_org_id);
          		OE_MSG_PUB.Add;
				oe_debug_pub.add('Invalid Agreement +sold_org_id combination',2);
	  			RAISE FND_API.G_EXC_ERROR;
			END;
           END IF;
         END IF;


	  	EXCEPTION
               WHEN NO_DATA_FOUND THEN
          	fnd_message.set_name('ONT', 'OE_INVALID_AGREEMENT');
          	fnd_message.set_Token('AGREEMENT_ID', p_line_rec.agreement_id);
          	fnd_message.set_Token('AGREEMENT_NAME', l_agreement_name);
          	fnd_message.set_Token('CUSTOMER_ID', l_sold_to_org);
          	OE_MSG_PUB.Add;
			oe_debug_pub.add('Invalid Agreement +sold_org_id combination',2);
	  		RAISE FND_API.G_EXC_ERROR;
	 	END;
	 END IF; -- Agreement has changed

    ELSE

	/*IF NOT oe_globals.equal(p_line_rec.pricing_date,p_old_line_rec.pricing_date) OR
		not oe_globals.equal(p_line_rec.price_list_id,p_old_line_rec.price_list_id) THEN*/


	-- Allow only the non agreement price_lists
	  BEGIN
		oe_debug_pub.add('Pricing date is '||p_line_rec.pricing_date,2);
		-- modified by lkxu: to select from qp_list_headers_vl instead
		-- of from qp_price_lists_v to select only PRL type list headers.

		SELECT name
          INTO   l_price_list_name
		FROM   qp_list_headers_vl
		WHERE  list_header_id = p_line_rec.price_list_id
		AND    list_type_code = 'PRL';

 	 EXCEPTION
         WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('ONT', 'OE_INVALID_NONAGR_PLIST');
          fnd_message.set_Token('PRICE_LIST1', p_line_rec.price_list_id);
          fnd_message.set_Token('PRICING_DATE', p_line_rec.pricing_date);
          OE_MSG_PUB.Add;
		oe_debug_pub.add('Invalid non agreement price list ',2);
	  	RAISE FND_API.G_EXC_ERROR;
	  END;

	--END IF; -- Price list or pricing date has changed
    END IF;

    oe_debug_pub.add('15 '||l_return_status ,1);

    -- Line number validation.
    -- Allow line number updates only on Model, Standard, Kit,
    --and stand alone service line.

    /*IF p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

           IF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION) OR
              (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS)  OR
              (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT)    OR
              (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE AND
		     p_line_rec.service_reference_line_id IS NOT NULL      AND
			p_line_rec.service_reference_line_id <> FND_API.G_MISS_NUM)

		 THEN

              IF (NOT OE_GLOBALS.EQUAL(p_line_rec.line_number,null)) THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;
			   fnd_message.set_name('ONT', 'OE_LINE_NUMBER_UPD');
		        OE_MSG_PUB.add;

		    END IF;
		 END IF;

    END IF;
    */

    oe_debug_pub.add('16 '||l_return_status ,1);

  /*IF p_line_rec.top_model_line_id is not null AND
        p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
        p_line_rec.ordered_quantity = 0
    THEN
    oe_debug_pub.add
    ('qty of a configuration related line 0'|| p_line_rec.item_type_code, 1);
  END IF;
  */

    oe_debug_pub.add('OEXLLINB, RR:T2',1);
    oe_debug_pub.add('17 '||l_return_status ,1);

    -- Validate ordered quantity for OTA lines. OTA Lines are
    -- identified by item_type_code of training. The ordered
    -- quantity cannot be greater than 1 for OTA lines.

    l_order_quantity_uom := p_line_rec.order_quantity_uom;
    l_is_ota_line := OE_OTA_UTIL.Is_OTA_Line(l_order_quantity_uom);

    IF (l_is_ota_line) AND
        p_line_rec.ordered_quantity > 1 then

         oe_debug_pub.add('Ordered Qty cannot be greater than 1 for OTA lines',
1);
         l_return_status := FND_API.G_RET_STS_ERROR;
         FND_Message.Set_Name('ONT', 'OE_OTA_INVALID_QTY');
         oe_msg_pub.add;
    END IF;

    /* End of validation for OTA */


    -- Fix bug 1162304: issue a warning message if the PO number
    -- is being referenced by another order
    IF p_line_rec.cust_po_number IS NOT NULL

    THEN

      IF OE_CNCL_Validate_Header.Is_Duplicate_PO_Number
           (p_line_rec.cust_po_number
           ,p_line_rec.sold_to_org_id
           ,p_line_rec.header_id )
      THEN
          FND_MESSAGE.SET_NAME('ONT','OE_VAL_DUP_PO_NUMBER');
          OE_MSG_PUB.ADD;
      END IF;

    END IF;
    -- End of check for duplicate PO number


    -- Fix for bug#1411346:
    -- SERVICE end date must be after service start date.

    IF (p_line_rec.service_end_date <> FND_API.G_MISS_DATE OR
        p_line_rec.service_end_date IS NOT NULL) AND
       (p_line_rec.service_start_date <> FND_API.G_MISS_DATE OR
        p_line_rec.service_start_date IS NOT NULL) THEN

	  IF (p_line_rec.service_end_date <= p_line_rec.service_start_date)
	  THEN
         l_return_status := FND_API.G_RET_STS_ERROR;
         fnd_message.set_name('ONT','OE_SERV_END_DATE');
         OE_MSG_PUB.Add;
       END IF;

    END IF;

    oe_debug_pub.add('18 '||l_return_status ,1);
    x_return_status := l_return_status;

    --  Done validating entity
    oe_debug_pub.add('Exit OE_CNCL_VALIDATE_LINE.ENTITY',1);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_x_line_rec        IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_validation_level  IN NUMBER := FND_API.G_VALID_LEVEL_FULL
)
IS
l_return_status   VARCHAR2(1);
l_line_rec        OE_Order_PUB.Line_Rec_Type := OE_Order_PUB.G_MISS_LINE_REC;
l_type_code       VARCHAR2(30);
BEGIN
    oe_debug_pub.add('Enter procedure OE_CNCL_VALIDATE_line.Attributes',1);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- validate Sales Agreements Attributes
    IF  p_x_line_rec.blanket_number IS NOT NULL
    and p_x_line_rec.blanket_line_number is NOT NULL
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT', 'OE_BLKT_DISALLOW_CLOSE_REL');
        OE_MSG_PUB.add;
    END IF;

    --  Validate line attributes

    IF  p_x_line_rec.accounting_rule_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Accounting_Rule(p_x_line_rec.accounting_rule_id) THEN
          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
	        p_x_line_rec.accounting_rule_id := NULL;
          ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
	        p_x_line_rec.accounting_rule_id := FND_API.G_MISS_NUM;
	     ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
	     END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.agreement_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Agreement(p_x_line_rec.agreement_id) THEN
          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
       	   p_x_line_rec.agreement_id := NULL;
          ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
       	   p_x_line_rec.agreement_id := FND_API.G_MISS_NUM;
	     ELSE
    		   x_return_status := FND_API.G_RET_STS_ERROR;
	     END IF;
        END IF;
    END IF;


    IF  p_x_line_rec.deliver_to_contact_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Deliver_To_Contact(p_x_line_rec.deliver_to_contact_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.deliver_to_contact_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.deliver_to_contact_id := FND_API.G_MISS_NUM;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
  	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.deliver_to_org_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Deliver_To_Org(p_x_line_rec.deliver_to_org_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.deliver_to_org_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.deliver_to_org_id := FND_API.G_MISS_NUM;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.demand_class_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Demand_Class(p_x_line_rec.demand_class_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.demand_class_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.demand_class_code := FND_API.G_MISS_CHAR;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.dep_plan_required_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Dep_Plan_Required(p_x_line_rec.dep_plan_required_flag) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.dep_plan_required_flag := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.dep_plan_required_flag := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.end_item_unit_number IS NOT NULL
    THEN
      IF NOT OE_CNCL_Validate.End_Item_Unit_Number(p_x_line_rec.end_item_unit_number) THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
           p_x_line_rec.end_item_unit_number := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
           p_x_line_rec.end_item_unit_number := FND_API.G_MISS_CHAR;
	   ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	   END IF;
      END IF;
    END IF;

    IF  p_x_line_rec.fob_point_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Fob_Point(p_x_line_rec.fob_point_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.fob_point_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.fob_point_code := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
   	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.freight_terms_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Freight_Terms(p_x_line_rec.freight_terms_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.freight_terms_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.freight_terms_code := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.invoice_to_contact_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Invoice_To_Contact(p_x_line_rec.invoice_to_contact_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.invoice_to_contact_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.invoice_to_contact_id := FND_API.G_MISS_NUM;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.invoice_to_org_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Invoice_To_Org(p_x_line_rec.invoice_to_org_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.invoice_to_org_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.invoice_to_org_id := FND_API.G_MISS_NUM;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.invoicing_rule_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Invoicing_Rule(p_x_line_rec.invoicing_rule_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.invoicing_rule_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.invoicing_rule_id := FND_API.G_MISS_NUM;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

    --{added for bug 4240715
    IF  p_x_line_rec.Ib_owner IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.IB_OWNER(p_x_line_rec.Ib_owner) THEN

         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
	    p_x_line_rec.Ib_owner := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
             THEN
            p_x_line_rec.Ib_Owner := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
     END IF;

    IF  p_x_line_rec.Ib_installed_at_location IS NOT NULL
           THEN
         IF NOT OE_CNCL_Validate.IB_INSTALLED_AT_LOCATION(p_x_line_rec.Ib_installed_at_location) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL
             THEN
            p_x_line_rec.Ib_installed_at_location := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
             THEN
            p_x_line_rec.Ib_installed_at_location := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;

     END IF;

    IF  p_x_line_rec.Ib_current_location IS NOT NULL
    THEN

       IF NOT OE_CNCL_Validate.IB_CURRENT_LOCATION(p_x_line_rec.ib_current_location) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL
             THEN
            p_x_line_rec.Ib_current_location := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
            THEN
            p_x_line_rec.Ib_current_location := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
     END IF;


    IF  p_x_line_rec.End_customer_id IS NOT NULL THEN

       IF NOT OE_CNCL_Validate.END_CUSTOMER(p_x_line_rec.End_customer_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL
	      THEN
            p_x_line_rec.End_customer_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
             THEN
            p_x_line_rec.End_customer_id := FND_API.G_MISS_NUM;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;

     END IF;



    IF  p_x_line_rec.End_customer_contact_id IS NOT NULL THEN

       IF NOT OE_CNCL_Validate.END_CUSTOMER_CONTACT(p_x_line_rec.End_customer_contact_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL
             THEN
            p_x_line_rec.End_customer_contact_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
             THEN
            p_x_line_rec.End_customer_contact_id := FND_API.G_MISS_NUM;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
     END IF;

    IF  p_x_line_rec.End_customer_site_use_id IS NOT NULL
    THEN
       IF NOT OE_CNCL_Validate.END_CUSTOMER_SITE_USE(p_x_line_rec.End_customer_site_use_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL
             THEN
            p_x_line_rec.End_customer_site_use_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
           THEN
            p_x_line_rec.End_customer_site_use_id := FND_API.G_MISS_NUM;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
     END IF;
	-- bug 4240715}

    IF  p_x_line_rec.item_type_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Item_Type(p_x_line_rec.item_type_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.item_type_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.item_type_code := FND_API.G_MISS_CHAR;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.payment_term_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Payment_Term(p_x_line_rec.payment_term_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.payment_term_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.payment_term_id := FND_API.G_MISS_NUM;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.price_list_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Price_List(p_x_line_rec.price_list_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.price_list_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.price_list_id := FND_API.G_MISS_NUM;
  	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.project_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Project(p_x_line_rec.project_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.project_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.project_id := FND_API.G_MISS_NUM;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
  	 END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.shipment_priority_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Shipment_Priority(p_x_line_rec.shipment_priority_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.shipment_priority_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.shipment_priority_code := FND_API.G_MISS_CHAR;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.shipping_method_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Shipping_Method(p_x_line_rec.shipping_method_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.shipping_method_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.shipping_method_code := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.ship_from_org_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Ship_From_Org(p_x_line_rec.ship_from_org_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.ship_from_org_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.ship_from_org_id := FND_API.G_MISS_NUM;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.shipping_interfaced_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Shipping_Interfaced(p_x_line_rec.shipping_interfaced_flag) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.shipping_interfaced_flag := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.shipping_interfaced_flag := FND_API.G_MISS_CHAR;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.shippable_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.shippable(p_x_line_rec.shippable_flag) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.shippable_flag := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.shippable_flag := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
   	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.ship_to_contact_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Ship_To_Contact(p_x_line_rec.ship_to_contact_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.ship_to_contact_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.ship_to_contact_id := FND_API.G_MISS_NUM;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
 	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.ship_to_org_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Ship_To_Org(p_x_line_rec.ship_to_org_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.ship_to_org_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.ship_to_org_id := FND_API.G_MISS_NUM;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.sold_to_org_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Sold_To_Org(p_x_line_rec.sold_to_org_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.sold_to_org_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.sold_to_org_id := FND_API.G_MISS_NUM;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.source_type_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Source_Type(p_x_line_rec.source_type_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.source_type_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.source_type_code := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.tax_exempt_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Tax_Exempt(p_x_line_rec.tax_exempt_flag) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.tax_exempt_flag := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.tax_exempt_flag := FND_API.G_MISS_CHAR;
	   ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.tax_exempt_reason_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Tax_Exempt_Reason(p_x_line_rec.tax_exempt_reason_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.tax_exempt_reason_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.tax_exempt_reason_code := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.tax_point_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Tax_Point(p_x_line_rec.tax_point_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.tax_point_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.tax_point_code := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.fulfilled_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.fulfilled(p_x_line_rec.fulfilled_flag) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.fulfilled_flag := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.fulfilled_flag := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.flow_status_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.Line_Flow_Status(p_x_line_rec.flow_status_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.flow_status_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.flow_status_code := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

      oe_debug_pub.add('before flex: '||x_return_status,2);
    IF  p_x_line_rec.attribute1 IS NOT NULL
    OR  p_x_line_rec.attribute10 IS NOT NULL
    OR  p_x_line_rec.attribute11 IS NOT NULL
    OR  p_x_line_rec.attribute12 IS NOT NULL
    OR  p_x_line_rec.attribute13 IS NOT NULL
    OR  p_x_line_rec.attribute14 IS NOT NULL
    OR  p_x_line_rec.attribute15 IS NOT NULL
    OR  p_x_line_rec.attribute16 IS NOT NULL   --For bug 2184255
    OR  p_x_line_rec.attribute17 IS NOT NULL
    OR  p_x_line_rec.attribute18 IS NOT NULL
    OR  p_x_line_rec.attribute19 IS NOT NULL
    OR  p_x_line_rec.attribute2 IS NOT NULL
    OR  p_x_line_rec.attribute20 IS NOT NULL
    OR  p_x_line_rec.attribute3 IS NOT NULL
    OR  p_x_line_rec.attribute4 IS NOT NULL
    OR  p_x_line_rec.attribute5 IS NOT NULL
    OR  p_x_line_rec.attribute6 IS NOT NULL
    OR  p_x_line_rec.attribute7 IS NOT NULL
    OR  p_x_line_rec.attribute8 IS NOT NULL
    OR  p_x_line_rec.attribute9 IS NOT NULL
    OR  p_x_line_rec.context IS NOT NULL
    THEN

         oe_debug_pub.add('Before calling line_desc_flex',2);
         IF NOT OE_CNCL_Validate.Line_Desc_Flex
          (p_context            => p_x_line_rec.context
          ,p_attribute1         => p_x_line_rec.attribute1
          ,p_attribute2         => p_x_line_rec.attribute2
          ,p_attribute3         => p_x_line_rec.attribute3
          ,p_attribute4         => p_x_line_rec.attribute4
          ,p_attribute5         => p_x_line_rec.attribute5
          ,p_attribute6         => p_x_line_rec.attribute6
          ,p_attribute7         => p_x_line_rec.attribute7
          ,p_attribute8         => p_x_line_rec.attribute8
          ,p_attribute9         => p_x_line_rec.attribute9
          ,p_attribute10        => p_x_line_rec.attribute10
          ,p_attribute11        => p_x_line_rec.attribute11
          ,p_attribute12        => p_x_line_rec.attribute12
          ,p_attribute13        => p_x_line_rec.attribute13
          ,p_attribute14        => p_x_line_rec.attribute14
          ,p_attribute15        => p_x_line_rec.attribute15
          ,p_attribute16        => p_x_line_rec.attribute16  -- for bug 2184255
          ,p_attribute17        => p_x_line_rec.attribute17
          ,p_attribute18        => p_x_line_rec.attribute18
          ,p_attribute19        => p_x_line_rec.attribute19
          ,p_attribute20        => p_x_line_rec.attribute20) THEN

          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN


                p_x_line_rec.context    := null;
                p_x_line_rec.attribute1 := null;
                p_x_line_rec.attribute2 := null;
                p_x_line_rec.attribute3 := null;
                p_x_line_rec.attribute4 := null;
                p_x_line_rec.attribute5 := null;
                p_x_line_rec.attribute6 := null;
                p_x_line_rec.attribute7 := null;
                p_x_line_rec.attribute8 := null;
                p_x_line_rec.attribute9 := null;
                p_x_line_rec.attribute10 := null;
                p_x_line_rec.attribute11 := null;
                p_x_line_rec.attribute12 := null;
                p_x_line_rec.attribute13 := null;
                p_x_line_rec.attribute14 := null;
                p_x_line_rec.attribute15 := null;
                p_x_line_rec.attribute16 := null;  -- for bug 2184255
                p_x_line_rec.attribute17 := null;
                p_x_line_rec.attribute18 := null;
                p_x_line_rec.attribute19 := null;
                p_x_line_rec.attribute20 := null;

        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
                p_x_line_rec.context    := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute1 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute2 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute3 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute4 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute5 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute6 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute7 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute8 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute9 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute10 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute11 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute12 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute13 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute14 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute15 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute16 := FND_API.G_MISS_CHAR;  -- for bug 2184255
                p_x_line_rec.attribute17 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute18 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute19 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute20 := FND_API.G_MISS_CHAR;
          ELSE

                x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
         END IF;

         oe_debug_pub.add('After line_desc_flex  ' || x_return_status,2);



    END IF;


    IF  p_x_line_rec.global_attribute1 IS NOT NULL
    OR  p_x_line_rec.global_attribute10 IS NOT NULL
    OR  p_x_line_rec.global_attribute11 IS NOT NULL
    OR  p_x_line_rec.global_attribute12 IS NOT NULL
    OR  p_x_line_rec.global_attribute13 IS NOT NULL
    OR  p_x_line_rec.global_attribute14 IS NOT NULL
    OR  p_x_line_rec.global_attribute15 IS NOT NULL
    OR  p_x_line_rec.global_attribute16 IS NOT NULL
    OR  p_x_line_rec.global_attribute17 IS NOT NULL
    OR  p_x_line_rec.global_attribute18 IS NOT NULL
    OR  p_x_line_rec.global_attribute19 IS NOT NULL
    OR  p_x_line_rec.global_attribute2 IS NOT NULL
    OR  p_x_line_rec.global_attribute20 IS NOT NULL
    OR  p_x_line_rec.global_attribute3 IS NOT NULL
    OR  p_x_line_rec.global_attribute4 IS NOT NULL
    OR  p_x_line_rec.global_attribute5 IS NOT NULL
    OR  p_x_line_rec.global_attribute6 IS NOT NULL
    OR  p_x_line_rec.global_attribute7 IS NOT NULL
    OR  p_x_line_rec.global_attribute8 IS NOT NULL
    OR  p_x_line_rec.global_attribute9 IS NOT NULL
    OR  p_x_line_rec.global_attribute_category IS NOT NULL
    THEN



          OE_DEBUG_PUB.ADD('Before G_line_desc_flex',2);
          IF NOT OE_CNCL_Validate.G_Line_Desc_Flex
          (p_context            => p_x_line_rec.global_attribute_category
          ,p_attribute1         => p_x_line_rec.global_attribute1
          ,p_attribute2         => p_x_line_rec.global_attribute2
          ,p_attribute3         => p_x_line_rec.global_attribute3
          ,p_attribute4         => p_x_line_rec.global_attribute4
          ,p_attribute5         => p_x_line_rec.global_attribute5
          ,p_attribute6         => p_x_line_rec.global_attribute6
          ,p_attribute7         => p_x_line_rec.global_attribute7
          ,p_attribute8         => p_x_line_rec.global_attribute8
          ,p_attribute9         => p_x_line_rec.global_attribute9
          ,p_attribute10        => p_x_line_rec.global_attribute10
          ,p_attribute11        => p_x_line_rec.global_attribute11
          ,p_attribute12        => p_x_line_rec.global_attribute12
          ,p_attribute13        => p_x_line_rec.global_attribute13
          ,p_attribute14        => p_x_line_rec.global_attribute13
          ,p_attribute15        => p_x_line_rec.global_attribute14
          ,p_attribute16        => p_x_line_rec.global_attribute16
          ,p_attribute17        => p_x_line_rec.global_attribute17
          ,p_attribute18        => p_x_line_rec.global_attribute18
          ,p_attribute19        => p_x_line_rec.global_attribute19
          ,p_attribute20        => p_x_line_rec.global_attribute20) THEN

          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN

                p_x_line_rec.global_attribute_category    := null;
                p_x_line_rec.global_attribute1 := null;
                p_x_line_rec.global_attribute2 := null;
                p_x_line_rec.global_attribute3 := null;
                p_x_line_rec.global_attribute4 := null;
                p_x_line_rec.global_attribute5 := null;
                p_x_line_rec.global_attribute6 := null;
                p_x_line_rec.global_attribute7 := null;
                p_x_line_rec.global_attribute8 := null;
                p_x_line_rec.global_attribute9 := null;
                p_x_line_rec.global_attribute11 := null;
                p_x_line_rec.global_attribute12 := null;
                p_x_line_rec.global_attribute13 := null;
                p_x_line_rec.global_attribute14 := null;
                p_x_line_rec.global_attribute15 := null;
                p_x_line_rec.global_attribute16 := null;
                p_x_line_rec.global_attribute17 := null;
                p_x_line_rec.global_attribute18 := null;
                p_x_line_rec.global_attribute19 := null;
                p_x_line_rec.global_attribute20 := null;

        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
                p_x_line_rec.global_attribute_category    := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute1 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute2 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute3 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute4 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute5 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute6 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute7 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute8 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute9 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute11 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute12 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute13 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute14 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute15 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute16 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute17 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute18 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute19 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute20 := FND_API.G_MISS_CHAR;

          ELSE

                x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
         END IF;

          OE_DEBUG_PUB.ADD('After G_Line_desc_flex ' || x_return_status,2);

    END IF;

    IF  p_x_line_rec.industry_attribute1 IS NOT NULL
    OR  p_x_line_rec.industry_attribute10 IS NOT NULL
    OR  p_x_line_rec.industry_attribute11 IS NOT NULL
    OR  p_x_line_rec.industry_attribute12 IS NOT NULL
    OR  p_x_line_rec.industry_attribute13 IS NOT NULL
    OR  p_x_line_rec.industry_attribute14 IS NOT NULL
    OR  p_x_line_rec.industry_attribute15 IS NOT NULL
    OR  p_x_line_rec.industry_attribute16 IS NOT NULL
    OR  p_x_line_rec.industry_attribute17 IS NOT NULL
    OR  p_x_line_rec.industry_attribute18 IS NOT NULL
    OR  p_x_line_rec.industry_attribute19 IS NOT NULL
    OR  p_x_line_rec.industry_attribute2 IS NOT NULL
    OR  p_x_line_rec.industry_attribute20 IS NOT NULL
    OR  p_x_line_rec.industry_attribute21 IS NOT NULL
    OR  p_x_line_rec.industry_attribute22 IS NOT NULL
    OR  p_x_line_rec.industry_attribute23 IS NOT NULL
    OR  p_x_line_rec.industry_attribute24 IS NOT NULL
    OR  p_x_line_rec.industry_attribute25 IS NOT NULL
    OR  p_x_line_rec.industry_attribute26 IS NOT NULL
    OR  p_x_line_rec.industry_attribute27 IS NOT NULL
    OR  p_x_line_rec.industry_attribute28 IS NOT NULL
    OR  p_x_line_rec.industry_attribute29 IS NOT NULL
    OR  p_x_line_rec.industry_attribute3 IS NOT NULL
    OR  p_x_line_rec.industry_attribute30 IS NOT NULL
    OR  p_x_line_rec.industry_attribute4 IS NOT NULL
    OR  p_x_line_rec.industry_attribute5 IS NOT NULL
    OR  p_x_line_rec.industry_attribute6 IS NOT NULL
    OR  p_x_line_rec.industry_attribute7 IS NOT NULL
    OR  p_x_line_rec.industry_attribute8 IS NOT NULL
    OR  p_x_line_rec.industry_attribute9 IS NOT NULL
    OR  p_x_line_rec.industry_context IS NOT NULL
    THEN


         IF NOT OE_CNCL_Validate.I_Line_Desc_Flex
          (p_context            => p_x_line_rec.Industry_context
          ,p_attribute1         => p_x_line_rec.Industry_attribute1
          ,p_attribute2         => p_x_line_rec.Industry_attribute2
          ,p_attribute3         => p_x_line_rec.Industry_attribute3
          ,p_attribute4         => p_x_line_rec.Industry_attribute4
          ,p_attribute5         => p_x_line_rec.Industry_attribute5
          ,p_attribute6         => p_x_line_rec.Industry_attribute6
          ,p_attribute7         => p_x_line_rec.Industry_attribute7
          ,p_attribute8         => p_x_line_rec.Industry_attribute8
          ,p_attribute9         => p_x_line_rec.Industry_attribute9
          ,p_attribute10        => p_x_line_rec.Industry_attribute10
          ,p_attribute11        => p_x_line_rec.Industry_attribute11
          ,p_attribute12        => p_x_line_rec.Industry_attribute12
          ,p_attribute13        => p_x_line_rec.Industry_attribute13
          ,p_attribute14        => p_x_line_rec.Industry_attribute14
          ,p_attribute15        => p_x_line_rec.Industry_attribute15
          ,p_attribute16         => p_x_line_rec.Industry_attribute16
          ,p_attribute17         => p_x_line_rec.Industry_attribute17
          ,p_attribute18         => p_x_line_rec.Industry_attribute18
          ,p_attribute19         => p_x_line_rec.Industry_attribute19
          ,p_attribute20         => p_x_line_rec.Industry_attribute20
          ,p_attribute21         => p_x_line_rec.Industry_attribute21
          ,p_attribute22         => p_x_line_rec.Industry_attribute22
          ,p_attribute23         => p_x_line_rec.Industry_attribute23
          ,p_attribute24         => p_x_line_rec.Industry_attribute24
          ,p_attribute25        => p_x_line_rec.Industry_attribute25
          ,p_attribute26        => p_x_line_rec.Industry_attribute26
          ,p_attribute27        => p_x_line_rec.Industry_attribute27
          ,p_attribute28        => p_x_line_rec.Industry_attribute28
          ,p_attribute29        => p_x_line_rec.Industry_attribute29
          ,p_attribute30        => p_x_line_rec.Industry_attribute30) THEN

          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN


                p_x_line_rec.Industry_context    := null;
                p_x_line_rec.Industry_attribute1 := null;
                p_x_line_rec.Industry_attribute2 := null;
                p_x_line_rec.Industry_attribute3 := null;
                p_x_line_rec.Industry_attribute4 := null;
                p_x_line_rec.Industry_attribute5 := null;
                p_x_line_rec.Industry_attribute6 := null;
                p_x_line_rec.Industry_attribute7 := null;
                p_x_line_rec.Industry_attribute8 := null;
                p_x_line_rec.Industry_attribute9 := null;
                p_x_line_rec.Industry_attribute10 := null;
                p_x_line_rec.Industry_attribute11 := null;
                p_x_line_rec.Industry_attribute12 := null;
                p_x_line_rec.Industry_attribute13 := null;
                p_x_line_rec.Industry_attribute14 := null;
                p_x_line_rec.Industry_attribute15 := null;
                p_x_line_rec.Industry_attribute16 := null;
                p_x_line_rec.Industry_attribute17 := null;
                p_x_line_rec.Industry_attribute18 := null;
                p_x_line_rec.Industry_attribute19 := null;
                p_x_line_rec.Industry_attribute20 := null;
                p_x_line_rec.Industry_attribute21 := null;
                p_x_line_rec.Industry_attribute22 := null;
                p_x_line_rec.Industry_attribute23 := null;
                p_x_line_rec.Industry_attribute24 := null;
                p_x_line_rec.Industry_attribute25 := null;
                p_x_line_rec.Industry_attribute26 := null;
                p_x_line_rec.Industry_attribute27 := null;
                p_x_line_rec.Industry_attribute28 := null;
                p_x_line_rec.Industry_attribute29 := null;
                p_x_line_rec.Industry_attribute30 := null;

        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN

                p_x_line_rec.Industry_context    := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute1 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute2 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute3 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute4 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute5 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute6 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute7 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute8 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute9 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute10 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute11 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute12 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute13 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute14 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute15 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute16 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute17 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute18 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute19 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute20 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute21 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute22 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute23 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute24 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute25 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute26 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute27 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute28 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute29 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute30 := FND_API.G_MISS_CHAR;
          ELSE

                x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
         END IF;

         oe_debug_pub.add('After I_line_desc_flex  ' || x_return_status,2);

    END IF;

    /* Trading Partner Attributes */
    IF  p_x_line_rec.tp_attribute1 IS NOT NULL
    OR  p_x_line_rec.tp_attribute2 IS NOT NULL
    OR  p_x_line_rec.tp_attribute3 IS NOT NULL
    OR  p_x_line_rec.tp_attribute4 IS NOT NULL
    OR  p_x_line_rec.tp_attribute5 IS NOT NULL
    OR  p_x_line_rec.tp_attribute6 IS NOT NULL
    OR  p_x_line_rec.tp_attribute7 IS NOT NULL
    OR  p_x_line_rec.tp_attribute8 IS NOT NULL
    OR  p_x_line_rec.tp_attribute9 IS NOT NULL
    OR  p_x_line_rec.tp_attribute10 IS NOT NULL
    OR  p_x_line_rec.tp_attribute11 IS NOT NULL
    OR  p_x_line_rec.tp_attribute12 IS NOT NULL
    OR  p_x_line_rec.tp_attribute13 IS NOT NULL
    OR  p_x_line_rec.tp_attribute14 IS NOT NULL
    OR  p_x_line_rec.tp_attribute15 IS NOT NULL

    THEN


         IF NOT OE_CNCL_Validate.TP_Line_Desc_Flex
          (p_context            => p_x_line_rec.tp_context
          ,p_attribute1         => p_x_line_rec.tp_attribute1
          ,p_attribute2         => p_x_line_rec.tp_attribute2
          ,p_attribute3         => p_x_line_rec.tp_attribute3
          ,p_attribute4         => p_x_line_rec.tp_attribute4
          ,p_attribute5         => p_x_line_rec.tp_attribute5
          ,p_attribute6         => p_x_line_rec.tp_attribute6
          ,p_attribute7         => p_x_line_rec.tp_attribute7
          ,p_attribute8         => p_x_line_rec.tp_attribute8
          ,p_attribute9         => p_x_line_rec.tp_attribute9
          ,p_attribute10        => p_x_line_rec.tp_attribute10
          ,p_attribute11        => p_x_line_rec.tp_attribute11
          ,p_attribute12        => p_x_line_rec.tp_attribute12
          ,p_attribute13        => p_x_line_rec.tp_attribute13
          ,p_attribute14        => p_x_line_rec.tp_attribute14
          ,p_attribute15        => p_x_line_rec.tp_attribute15) THEN

          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN


                p_x_line_rec.tp_context    := null;
                p_x_line_rec.tp_attribute1 := null;
                p_x_line_rec.tp_attribute2 := null;
                p_x_line_rec.tp_attribute3 := null;
                p_x_line_rec.tp_attribute4 := null;
                p_x_line_rec.tp_attribute5 := null;
                p_x_line_rec.tp_attribute6 := null;
                p_x_line_rec.tp_attribute7 := null;
                p_x_line_rec.tp_attribute8 := null;
                p_x_line_rec.tp_attribute9 := null;
                p_x_line_rec.tp_attribute10 := null;
                p_x_line_rec.tp_attribute11 := null;
                p_x_line_rec.tp_attribute12 := null;
                p_x_line_rec.tp_attribute13 := null;
                p_x_line_rec.tp_attribute14 := null;
                p_x_line_rec.tp_attribute15 := null;

        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN

                p_x_line_rec.tp_context    := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute1 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute2 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute3 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute4 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute5 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute6 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute7 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute8 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute9 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute10 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute11 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute12 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute13 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute14 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute15 := FND_API.G_MISS_CHAR;
          ELSE

                x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
         END IF;

         --oe_debug_pub.add('After TP_line_desc_flex  ' || x_return_status);

    END IF;
    /* Trading Partner */


    IF  p_x_line_rec.return_attribute1 IS NOT NULL
    OR  p_x_line_rec.return_attribute10 IS NOT NULL
    OR  p_x_line_rec.return_attribute11 IS NOT NULL
    OR  p_x_line_rec.return_attribute12 IS NOT NULL
    OR  p_x_line_rec.return_attribute13 IS NOT NULL
    OR  p_x_line_rec.return_attribute14 IS NOT NULL
    OR  p_x_line_rec.return_attribute15 IS NOT NULL
    OR  p_x_line_rec.return_attribute2 IS NOT NULL
    OR  p_x_line_rec.return_attribute3 IS NOT NULL
    OR  p_x_line_rec.return_attribute4 IS NOT NULL
    OR  p_x_line_rec.return_attribute5 IS NOT NULL
    OR  p_x_line_rec.return_attribute6 IS NOT NULL
    OR  p_x_line_rec.return_attribute7 IS NOT NULL
    OR  p_x_line_rec.return_attribute8 IS NOT NULL
    OR  p_x_line_rec.return_attribute9 IS NOT NULL
    OR  p_x_line_rec.return_context IS NOT NULL
    THEN


         oe_debug_pub.add('Before calling Return line_desc_flex',2);
         IF NOT OE_CNCL_Validate.R_Line_Desc_Flex
          (p_context            => p_x_line_rec.Return_context
          ,p_attribute1         => p_x_line_rec.Return_attribute1
          ,p_attribute2         => p_x_line_rec.Return_attribute2
          ,p_attribute3         => p_x_line_rec.Return_attribute3
          ,p_attribute4         => p_x_line_rec.Return_attribute4
          ,p_attribute5         => p_x_line_rec.Return_attribute5
          ,p_attribute6         => p_x_line_rec.Return_attribute6
          ,p_attribute7         => p_x_line_rec.Return_attribute7
          ,p_attribute8         => p_x_line_rec.Return_attribute8
          ,p_attribute9         => p_x_line_rec.Return_attribute9
          ,p_attribute10        => p_x_line_rec.Return_attribute10
          ,p_attribute11        => p_x_line_rec.Return_attribute11
          ,p_attribute12        => p_x_line_rec.Return_attribute12
          ,p_attribute13        => p_x_line_rec.Return_attribute13
          ,p_attribute14        => p_x_line_rec.Return_attribute14
          ,p_attribute15        => p_x_line_rec.Return_attribute15) THEN

          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN


                p_x_line_rec.Return_context    := null;
                p_x_line_rec.Return_attribute1 := null;
                p_x_line_rec.Return_attribute2 := null;
                p_x_line_rec.Return_attribute3 := null;
                p_x_line_rec.Return_attribute4 := null;
                p_x_line_rec.Return_attribute5 := null;
                p_x_line_rec.Return_attribute6 := null;
                p_x_line_rec.Return_attribute7 := null;
                p_x_line_rec.Return_attribute8 := null;
                p_x_line_rec.Return_attribute9 := null;
                p_x_line_rec.Return_attribute11 := null;
                p_x_line_rec.Return_attribute12 := null;
                p_x_line_rec.Return_attribute13 := null;
                p_x_line_rec.Return_attribute14 := null;
                p_x_line_rec.Return_attribute15 := null;
                p_x_line_rec.Return_attribute10 := null;

        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
                p_x_line_rec.Return_context    := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute1 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute2 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute3 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute4 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute5 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute6 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute7 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute8 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute9 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute11 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute12 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute13 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute14 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute15 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute10 := FND_API.G_MISS_CHAR;
          ELSE

                x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
         END IF;

         oe_debug_pub.add('After Return line_desc_flex  ' || x_return_status,2);



    END IF;

    --  Done validating attributes

    IF  p_x_line_rec.salesrep_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.salesrep(p_x_line_rec.salesrep_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.salesrep_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.salesrep_id := FND_API.G_MISS_NUM;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.return_reason_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.return_reason(p_x_line_rec.return_reason_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            p_x_line_rec.return_reason_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            p_x_line_rec.return_reason_code := FND_API.G_MISS_CHAR;
	    ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
        END IF;
    END IF;

   -- Validate Commitment
   IF  (p_x_line_rec.commitment_id IS NOT NULL)
   THEN
      IF NOT OE_CNCL_Validate.commitment(p_x_line_rec.commitment_id) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   END IF;
    oe_debug_pub.add('Exiting procedure OE_CNCL_VALIDATE_line.Attributes',1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

FUNCTION Get_Item_Type(p_line_rec OE_ORDER_PUB.Line_Rec_Type)

RETURN VARCHAR2
IS
l_item_type_code   VARCHAR2(30) := NULL;
l_item_rec         OE_ORDER_CACHE.item_rec_type;
BEGIN

    oe_debug_pub.add('In OEXVCLINB: Function Get_Item_Type',1);
    oe_debug_pub.add('The INV Item is'||to_char(p_line_rec.inventory_item_id),1);

    IF p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE THEN
          RETURN OE_GLOBALS.G_ITEM_STANDARD;
    ELSIF p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG OR
          p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED THEN
          RETURN p_line_rec.item_type_code;
    END IF;


    l_item_rec :=
    	     OE_Order_Cache.Load_Item (p_line_rec.inventory_item_id
                                      ,p_line_rec.ship_from_org_id);

    oe_debug_pub.add('Bom Item Type is ' || l_item_rec.bom_item_type);

    IF l_item_rec.bom_item_type = 1
    -- MODEL items and ato's under pto have bom_item_type = 1
    THEN

    IF nvl(p_line_rec.top_model_line_ref, 0) <>
               nvl(p_line_rec.orig_sys_line_ref, 0)
    THEN
       oe_debug_pub.add
       ('Returning CLASS as the Item Type for ato subconfig',1);
        --Procedure to check change in item_type_code
        RETURN OE_GLOBALS.G_ITEM_CLASS;
    END IF;

       oe_debug_pub.add('Returning MODEL as the Item Type',1);
       --Procedure to check change in item_type_code
       RETURN OE_GLOBALS.G_ITEM_MODEL;

    ELSIF l_item_rec.bom_item_type = 2
    THEN
	   oe_debug_pub.add('Returning CLASS as the Item Type',1);
        -- Only CLASS items have bom_item_type = 2
        --Procedure to check change in item_type_code
        RETURN OE_GLOBALS.G_ITEM_CLASS;
    ELSIF l_item_rec.bom_item_type = 4 and
		l_item_rec.service_item_flag = 'N'
    THEN

	   oe_debug_pub.add('Bom 4 and flag = N');
       -- Following 3 items can have bom_item_type = 4 :
       -- STANDARD item, OPTION item and a KIT
       -- We will distinguish an item to be a kit by seeing if
       -- it has a record in bom_bill_of_materials.
       -- All options MUST have the top_model_line_ref populated
       -- before they come to defaulting. Thus we use it to distinguish
       -- between a standard and an option item.
       -- ato_item's item_type_code will be standard

	   oe_debug_pub.add
          ('item Org ' || OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID'));
	   oe_debug_pub.add('inventory_item_id ' || p_line_rec.inventory_item_id);
       BEGIN
         SELECT OE_GLOBALS.G_ITEM_KIT
         INTO l_item_type_code
         FROM mtl_system_items
         WHERE organization_id
         = OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID')
         AND inventory_item_id = p_line_rec.inventory_item_id
         AND pick_components_flag = 'Y';

	   oe_debug_pub.add(' Before calling check 1');
        --Procedure to check change in item_type_code
         RETURN l_item_type_code;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               oe_debug_pub.add('get_item_type no data found, bom_item_type : 4', 1);
               IF (p_line_rec.top_model_line_ref is not null AND
                   p_line_rec.top_model_line_ref <> FND_API.G_MISS_CHAR)
                  OR
                  (p_line_rec.top_model_line_index is not null AND
                   p_line_rec.top_model_line_index <> FND_API.G_MISS_NUM)

               THEN
	          oe_debug_pub.add(' Before calling check 2');
                  RETURN OE_GLOBALS.G_ITEM_OPTION;
               ELSE
	          oe_debug_pub.add(' Before calling check 3');
                  RETURN OE_GLOBALS.G_ITEM_STANDARD;
               END IF;
       END;

	  ELSIF l_item_rec.service_item_flag = 'Y' and
		   l_item_rec.bom_item_type = 4
       THEN
		 oe_debug_pub.add('Service item flag is: ' || l_item_rec.service_item_flag);
                 RETURN OE_GLOBALS.G_ITEM_SERVICE;

    END IF;

    RETURN null;

    oe_debug_pub.add('Exiting OEXVCLNB: Function Get_Item_Type');

EXCEPTION

    WHEN NO_DATA_FOUND THEN
	   oe_debug_pub.add(' Before calling check 4');
         l_item_type_code := OE_GLOBALS.G_ITEM_STANDARD;
         RETURN l_item_type_code;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME ,
    	        'Get_Item_Type'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Item_Type;

END OE_CNCL_Validate_Line;

/
