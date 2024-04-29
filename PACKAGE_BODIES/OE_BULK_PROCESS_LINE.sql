--------------------------------------------------------
--  DDL for Package Body OE_BULK_PROCESS_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_PROCESS_LINE" As
/* $Header: OEBLLINB.pls 120.14.12010000.9 2010/03/05 12:53:10 srsunkar ship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):= 'OE_BULK_PROCESS_LINE';


g_curr_top_index        NUMBER;
g_curr_ato_index        NUMBER;
-----------------------------------------------------------------------
-- LOCAL PROCEDURES/FUNCTIONS
-----------------------------------------------------------------------

FUNCTION Validate_Line_Type
( p_line_type_id          IN NUMBER
, p_ordered_date          IN DATE
)
RETURN BOOLEAN
IS
  l_c_index           NUMBER;
BEGIN
    oe_debug_pub.add(  ' Enter  Validate_Line_Type',1);
    oe_debug_pub.add(  ' Order Date :' || to_char(p_ordered_date));
    oe_debug_pub.add(  'start Date :'|| OE_BULK_CACHE.G_LINE_TYPE_TBL(p_line_type_id).start_date_active);
    oe_debug_pub.add(  'end  Date :'|| OE_BULK_CACHE.G_LINE_TYPE_TBL(p_line_type_id).end_date_active);
  l_c_index := OE_BULK_CACHE.Load_Line_Type
                   (p_key           => p_line_type_id);

  IF p_ordered_date BETWEEN
       nvl(OE_BULK_CACHE.G_LINE_TYPE_TBL(p_line_type_id).start_date_active,sysdate)
       AND nvl(OE_BULK_CACHE.G_LINE_TYPE_TBL(p_line_type_id).end_date_active,sysdate)
  THEN
     oe_debug_pub.add(  'Line Type Valid');
     RETURN TRUE;
  ELSE
     oe_debug_pub.add(  'Line Type NOT Valid');
     RETURN FALSE;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
END Validate_Line_Type;


PROCEDURE Check_Book_Reqd_Attributes
( p_line_rec              IN OE_WSH_BULK_GRP.LINE_REC_TYPE
, p_index                 IN NUMBER
, x_return_status         IN OUT NOCOPY VARCHAR2
)
IS
  l_c_index               NUMBER;
  l_rule_type             VARCHAR2(10);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check for fields required on a booked order line

  IF p_line_rec.sold_to_org_id(p_index) IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
       OE_Order_UTIL.Get_Attribute_Name('SOLD_TO_ORG_ID'));
    OE_BULK_MSG_PUB.ADD;
  END IF;

  IF p_line_rec.invoice_to_org_id(p_index) IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
       OE_Order_UTIL.Get_Attribute_Name('INVOICE_TO_ORG_ID'));
    OE_BULK_MSG_PUB.ADD;
  END IF;

  IF p_line_rec.tax_exempt_flag(p_index) IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
       OE_Order_UTIL.Get_Attribute_Name('TAX_EXEMPT_FLAG'));
    OE_BULK_MSG_PUB.ADD;
  END IF;

  -- Quantity and UOM Required

  IF p_line_rec.order_quantity_uom(p_index) IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
       OE_Order_UTIL.Get_Attribute_Name('ORDER_QUANTITY_UOM'));
    OE_BULK_MSG_PUB.ADD;
  END IF;

  -- Fix bug 1277092: ordered quantity should not be = 0 on a booked line
  IF p_line_rec.ordered_quantity(p_index) IS NULL
   OR p_line_rec.ordered_quantity(p_index) = 0 THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
       OE_Order_UTIL.Get_Attribute_Name('ORDERED_QUANTITY'));
    OE_BULK_MSG_PUB.ADD;
  END IF;

  -- Fix bug 1262790
  -- Ship To and Payment Term required on ORDER lines,
  -- NOT on RETURN lines

  IF p_line_rec.line_category_code(p_index)
       <> OE_GLOBALS.G_RETURN_CATEGORY_CODE THEN

    IF p_line_rec.ship_to_org_id(p_index) IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
         OE_Order_UTIL.Get_Attribute_Name('SHIP_TO_ORG_ID'));
      OE_BULK_MSG_PUB.ADD;
    END IF;

    IF p_line_rec.payment_term_id(p_index) IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_UTIL.Get_Attribute_Name('PAYMENT_TERM_ID'));
      OE_BULK_MSG_PUB.ADD;
    END IF;
--serla
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
       IF p_line_rec.item_type_code(p_index) <> 'SERVICE' THEN
          IF p_line_rec.accounting_rule_id(p_index) IS NOT NULL AND
             p_line_rec.accounting_rule_id(p_index) <> FND_API.G_MISS_NUM THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'GETTING ACCOUNTING RULE TYPE' ) ;
             END IF;
             SELECT type
             INTO l_rule_type
             FROM ra_rules
             WHERE rule_id = p_line_rec.accounting_rule_id(p_index);
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'RULE_TYPE IS :'||L_RULE_TYPE||': ACCOUNTING RULE DURATION IS: '||P_LINE_REC.ACCOUNTING_RULE_DURATION ( P_INDEX ) ) ;
             END IF;
             IF l_rule_type = 'ACC_DUR' THEN
                IF p_line_rec.accounting_rule_duration(p_index) IS NULL THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                   OE_Order_UTIL.Get_Attribute_Name('ACCOUNTING_RULE_DURATION'));
                   OE_BULK_MSG_PUB.ADD;
                END IF; -- end of accounting_rule_duration null
             END IF; -- end of variable accounting rule type
          END IF; -- end of accounting_rule_id not null
       END IF;  -- end of non-service line
    END IF;  -- end of code release level
--serla
  END IF;

   -- ?? Check with Manish ??
   -- Are checks for tax fields required?

   -- Commenting out as of 1/23/2003 as tax checks not req'd
/*
   IF p_line_rec.tax_date(p_index) IS NULL THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_UTIL.Get_Attribute_Name('TAX_DATE'));
     OE_BULK_MSG_PUB.ADD;
   END IF;
*/
  -- Tax field checks not required, as checks would prevent orders from
  -- being entered where transaction is taxable and tax calculation
  -- event is before invoicing.

  -- Pricing attribute checks will be done after the call to Price_Orders
  -- Bug 2765770 =>
  -- For calculate price flag of 'N', price list check should be done here
  -- as such lines are not updated in Price_Orders call.

  IF p_line_rec.calculate_price_flag(p_index) = 'N' THEN

  IF p_line_rec.price_list_id(p_index) IS NULL THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_UTIL.Get_Attribute_Name('PRICE_LIST_ID'));
     OE_BULK_MSG_PUB.ADD;
  END IF;

  END IF;

  -- Checks for service fields NOT required
  -- as BULK does not support creation of service lines.

  -- NOT REQUIRED as BULK does not support RETURN line creation:
  -- 1. Warehouse and schedule date required on RETURN lines
  -- 2. Check over return

EXCEPTION
    WHEN OTHERS THEN
      oe_debug_pub.add('Others Error, Line.Check_Book_Reqd_Attributes');
      oe_debug_pub.add(substr(sqlerrm,1,240));
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OE_BULK_MSG_PUB.Check_Msg_Level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_BULK_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
         ,   'Check_Book_Reqd_Attributes'
        );
      END IF;
END Check_Book_Reqd_Attributes;

PROCEDURE Check_Scheduling_Attributes
( p_line_rec              IN OE_WSH_BULK_GRP.LINE_REC_TYPE
, p_index                 IN NUMBER
, x_return_status         IN OUT NOCOPY VARCHAR2
)
IS
 l_debug_level CONSTANT   NUMBER := oe_debug_pub.g_debug_level;

  l_c_index                NUMBER;
  l_org_id                 NUMBER;
  l_bill_seq_id            NUMBER;
  l_make_buy               NUMBER;
  l_org_code               VARCHAR2(30);

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check for Required Scheduling Attributes

   IF p_line_rec.ordered_quantity(p_index) IS NULL THEN
      FND_MESSAGE.SET_NAME('ONT','OE_SCH_MISSING_QUANTITY');
      OE_BULK_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   -- If the quantity on the line is zero(which is different from
   -- missing)  and if the user is trying to performing scheduling,
   -- it is an error

   IF p_line_rec.ordered_quantity(p_index) = 0 THEN
      FND_MESSAGE.SET_NAME('ONT','OE_SCH_ZERO_QTY');
      OE_BULK_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   -- No need to check for following statuses: cancelled, shipped, reserved
   -- qty changes as line is being CREATED.

   -- If the order quantity uom on the line is missing or null
   -- and if the user is trying to performing scheduling,
   -- it is an error

   IF p_line_rec.order_quantity_uom(p_index) IS NULL THEN
      FND_MESSAGE.SET_NAME('ONT','OE_SCH_MISSING_UOM');
      OE_BULK_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   -- Item check not required as it is already validated for creation.

   -- If the request_date on the line is missing or null and
   -- if the user is trying to performing scheduling,
   -- it is an error

   IF p_line_rec.request_date(p_index) IS NULL THEN
      FND_MESSAGE.SET_NAME('ONT','OE_SCH_MISSING_REQUEST_DATE');
      OE_BULK_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   -- No need to check if line belongs to a set: SETs not supported in BULK mode

   -- Following steps will be post BULK insertion of lines - in OE_BULK_SCHEDULE_UTIL
   -- 1.Check for Holds
   -- 2.Check for scheduling levels - whether line should be reserved or not. Or
   -- should this be done here? If done here, how to mark sch level for each line?
   -- Solution to 2: Do Not worry - Reservations NOT supported in BULK mode.

   -- No need to do ATO validations: ATOs not supported in BULK mode
-- ADDING code
l_c_index := OE_BULK_CACHE.Load_Line_Type(p_line_rec.line_type_id(p_index));
   IF (OE_BULK_CACHE.G_LINE_TYPE_TBL(l_c_index).scheduling_level_code = 'FOUR'
       OR OE_BULK_CACHE.G_LINE_TYPE_TBL(l_c_index).scheduling_level_code = 'FIVE') AND
      (p_line_rec.item_type_code(p_index) <> 'STANDARD'
       OR p_line_rec.ato_line_id(p_index) is not null) THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CHECKING THAT IT IS A STANDARD ITEM...' , 1 ) ;
       END IF;

       FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_INACTIVE_STD_ONLY');
       FND_MESSAGE.SET_TOKEN('LTYPE',
                   nvl(Oe_Schedule_Util.sch_cached_line_type ,'0'));
       OE_BULK_MSG_PUB.Add;

       IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OE_SCH_INACTIVE_STD_ONLY' , 1 ) ;
       END IF;
       X_return_status := FND_API.G_RET_STS_ERROR;
   END IF;


   -- ATO checks for config support

   IF p_line_rec.ato_line_id(p_index) is not null AND
      NOT(p_line_rec.ato_line_id(p_index) = p_line_rec.line_id(p_index) AND
          p_line_rec.item_type_code(p_index) IN ( OE_GLOBALS.G_ITEM_OPTION,
                                         OE_GLOBALS.G_ITEM_STANDARD))
   THEN
       IF MSC_ATP_GLOBAL.GET_APS_VERSION <> 10 AND
          p_line_rec.ship_from_org_id(p_index) is NULL
       THEN
           FND_MESSAGE.SET_NAME('ONT','OE_SCH_ATO_WHSE_REQD');
           OE_BULK_MSG_PUB.Add;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'OE_SCH_ATO_WHSE_REQD' , 1 ) ;
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;

       END IF;
   END IF; -- Gop code level

   IF  p_line_rec.ato_line_id(p_index) = p_line_rec.line_id(p_index) AND
       p_line_rec.item_type_code(p_index) in ('STANDARD','OPTION') AND
       fnd_profile.value('INV_CTP') = '5'
   THEN

       l_org_id := nvl(p_line_rec.ship_from_org_id(p_index), OE_BULK_ORDER_PVT.G_ITEM_ORG);
       l_c_index := OE_BULK_CACHE.Load_Item
                    (p_key1 => p_line_rec.inventory_item_id(p_index)
                    ,p_key2 => l_org_id
                    ,p_default_attributes => 'Y');

       l_make_buy := OE_BULK_CACHE.G_ITEM_TBL(l_c_index).planning_make_buy_code;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'L_MAKE_BUY' || L_MAKE_BUY , 2 ) ;
       END IF;

       IF nvl(l_make_buy,1) <> 2 THEN
           BEGIN
               SELECT BILL_SEQUENCE_ID
               INTO   l_bill_seq_id
               FROM   BOM_BILL_OF_MATERIALS
               WHERE  ORGANIZATION_ID = l_org_id
               AND    ASSEMBLY_ITEM_ID = p_line_rec.inventory_item_id(p_index)
               AND    ALTERNATE_BOM_DESIGNATOR IS NULL;

           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'OE_BOM_NO_BILL_IN_SHP_ORG' , 2 ) ;
                   END IF;

                   FND_MESSAGE.SET_NAME('ONT','OE_BOM_NO_BILL_IN_SHP_ORG');
                   FND_MESSAGE.SET_TOKEN('ITEM',p_line_rec.ordered_item(p_index));

                   Select ORGANIZATION_CODE
                   Into l_org_code
                   From ORG_ORGANIZATION_DEFINITIONS
                   Where ORGANIZATION_ID = l_org_id;
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'ORGANIZATION CODE:'||L_ORG_CODE , 2 ) ;
                   END IF;
                   FND_MESSAGE.SET_TOKEN('ORG',l_org_code);
                   OE_MSG_PUB.Add;
                   x_return_status := FND_API.G_RET_STS_ERROR;

               WHEN OTHERS THEN
                   Null;
           END;
       END IF;
   END IF;

END Check_Scheduling_Attributes;


PROCEDURE Get_Line_Number(p_line_number IN OUT NOCOPY OE_WSH_BULK_GRP.T_NUM,
                          p_header_id IN OE_WSH_BULK_GRP.T_NUM)
IS
l_ctr         NUMBER := 1;
l_header_id   NUMBER := 1;
BEGIN
   l_header_id := p_header_id(1);
   FOR i IN 1..p_line_number.COUNT LOOP
       IF p_header_id(i) <> l_header_id THEN
           l_header_id := p_header_id(i);
           l_ctr := 1;
       END IF;
       p_line_number(i) := l_ctr;
       l_ctr := l_ctr + 1;
   END LOOP;

END Get_Line_Number;

----------------------------------------------------------------------
-- PROCEDURE Get_Item_Info
--
-- If inventory_item_id is null on the record, this procedure is called
-- to retrieve ID based on value columns passed in interface tables.
-- If item identifier type indicates that the item is a CUSTOMER item
-- or a generic cross-referenced item, it will also query against
-- relevant APIs or cross reference tables to derive the ID.
-- NOTE: assumption is that item identifier type is either passed in
-- or defaulted prior to this procedure call i.e. it cannot be null.
----------------------------------------------------------------------

PROCEDURE Get_Item_Info
( p_index                 IN NUMBER
, p_line_rec              IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE)
IS
  l_structure  fnd_flex_key_api.structure_type;
  l_flexfield  fnd_flex_key_api.flexfield_type;
  l_segment_array  fnd_flex_ext.segmentarray;
  l_n_segments  NUMBER;
  l_segments  FND_FLEX_KEY_API.SEGMENT_LIST;
  l_id  NUMBER;
  failure_message      varchar2(2000);
  l_inventory_item                 VARCHAR2(240);
  l_inventory_item_id_int          NUMBER;
  l_inventory_item_id_cust         NUMBER;
  l_inventory_item_id_gen          NUMBER;
  l_error_code                     VARCHAR2(9);
  l_error_flag                     VARCHAR2(1);
  l_error_message                  VARCHAR2(2000);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_BULK_PROCESS_LINE.Get_Item_Info' ) ;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'order_source_id: ' ||p_line_rec.order_source_id(p_index));
       oe_debug_pub.add(  'orig_sys_document_ref: ' || p_line_rec.orig_sys_document_ref(p_index));
       oe_debug_pub.add(  'orig_sys_line_ref: ' || p_line_rec.orig_sys_line_ref(p_index));
       oe_debug_pub.add(  'orig_sys_shipment_ref: ' || p_line_rec.orig_sys_shipment_ref(p_index));
       oe_debug_pub.add(  'org_id: ' || p_line_rec.org_id(p_index));
   END IF;

   SELECT INVENTORY_ITEM_SEGMENT_1
         , INVENTORY_ITEM_SEGMENT_2
         , INVENTORY_ITEM_SEGMENT_3
         , INVENTORY_ITEM_SEGMENT_4
         , INVENTORY_ITEM_SEGMENT_5
         , INVENTORY_ITEM_SEGMENT_6
         , INVENTORY_ITEM_SEGMENT_7
         , INVENTORY_ITEM_SEGMENT_8
         , INVENTORY_ITEM_SEGMENT_9
         , INVENTORY_ITEM_SEGMENT_10
         , INVENTORY_ITEM_SEGMENT_11
         , INVENTORY_ITEM_SEGMENT_12
         , INVENTORY_ITEM_SEGMENT_13
         , INVENTORY_ITEM_SEGMENT_14
         , INVENTORY_ITEM_SEGMENT_15
         , INVENTORY_ITEM_SEGMENT_16
         , INVENTORY_ITEM_SEGMENT_17
         , INVENTORY_ITEM_SEGMENT_18
         , INVENTORY_ITEM_SEGMENT_19
         , INVENTORY_ITEM_SEGMENT_20
         , INVENTORY_ITEM
   INTO  l_segment_array(1)
         , l_segment_array(2)
         , l_segment_array(3)
         , l_segment_array(4)
         , l_segment_array(5)
         , l_segment_array(6)
         , l_segment_array(7)
         , l_segment_array(8)
         , l_segment_array(9)
         , l_segment_array(10)
         , l_segment_array(11)
         , l_segment_array(12)
         , l_segment_array(13)
         , l_segment_array(14)
         , l_segment_array(15)
         , l_segment_array(16)
         , l_segment_array(17)
         , l_segment_array(18)
         , l_segment_array(19)
         , l_segment_array(20)
         , l_inventory_item
   FROM OE_LINES_IFACE_ALL
   WHERE order_source_id = p_line_rec.order_source_id(p_index)
     AND orig_sys_document_ref = p_line_rec.orig_sys_document_ref(p_index)
     AND orig_sys_line_ref = p_line_rec.orig_sys_line_ref(p_index)
     AND org_id = p_line_rec.org_id(p_index)
     AND (nvl(orig_sys_shipment_ref,fnd_api.g_miss_char)
            = nvl(p_line_rec.orig_sys_shipment_ref(p_index),fnd_api.g_miss_char)
	  OR    -- added to fix bug 5394064
	  p_line_rec.orig_sys_shipment_ref(p_index) = 'OE_ORDER_LINES_ALL'||p_line_rec.line_id(p_index)||'.'||'1')
     -- Bug 2764130 : there should be only one row for this doc/line ref
     -- combination. If there are multiple rows, it will be errored out in
     -- the duplicate check in procedure Entity.
     AND rownum = 1;

       oe_debug_pub.add(  'In Get_Item_Info 1' ) ;

   ----------------------------------------------------------------------
   --(1) Populate p_line_rec.inventory_item_id with ccid if any of the
   --segments are passed instead of inventory_item_id
   ----------------------------------------------------------------------

   IF ( (l_segment_array(1) IS NOT NULL) OR
        (l_segment_array(2) IS NOT NULL) OR
        (l_segment_array(3) IS NOT NULL) OR
        (l_segment_array(4) IS NOT NULL) OR
        (l_segment_array(5) IS NOT NULL) OR
        (l_segment_array(6) IS NOT NULL) OR
        (l_segment_array(7) IS NOT NULL) OR
        (l_segment_array(8) IS NOT NULL) OR
        (l_segment_array(9) IS NOT NULL) OR
        (l_segment_array(10) IS NOT NULL) OR
        (l_segment_array(11) IS NOT NULL) OR
        (l_segment_array(12) IS NOT NULL) OR
        (l_segment_array(13) IS NOT NULL) OR
        (l_segment_array(14) IS NOT NULL) OR
        (l_segment_array(15) IS NOT NULL) OR
        (l_segment_array(16) IS NOT NULL) OR
        (l_segment_array(17) IS NOT NULL) OR
        (l_segment_array(18) IS NOT NULL) OR
        (l_segment_array(19) IS NOT NULL) OR
        (l_segment_array(20) IS NOT NULL)
      )
   THEN
     FND_FLEX_KEY_API.SET_SESSION_MODE('customer_data');
     l_flexfield := FND_FLEX_KEY_API.FIND_FLEXFIELD('INV', 'MSTK');
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER FIND FLEXFIELD' ) ;
     END IF;
     l_structure.structure_number := 101;
     FND_FLEX_KEY_API.GET_SEGMENTS(l_flexfield, l_structure, TRUE, l_n_segments, l_segments);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SEGMENTS ENABLED = '||L_N_SEGMENTS ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'VALIDATION_ORG_ID = '||OE_BULK_ORDER_PVT.G_ITEM_ORG ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ARRAY1 = '||L_SEGMENT_ARRAY ( 1 ) ) ;
     END IF;
     IF FND_FLEX_EXT.GET_COMBINATION_ID('INV', 'MSTK', 101, SYSDATE, l_n_segments, l_segment_array, l_id, OE_BULK_ORDER_PVT.G_ITEM_ORG) THEN
       p_line_rec.inventory_item_id(p_index) := l_id;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'GET CCID = '||P_LINE_REC.INVENTORY_ITEM_ID ( P_INDEX ) ) ;
       END IF;
       RETURN;
     ELSE
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ERROR IN GETTING CCID' ) ;
       END IF;
       failure_message := fnd_flex_ext.get_message;
       OE_BULK_MSG_PUB.Add_TEXT(failure_message);
       RAISE FND_API.G_EXC_ERROR;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'FAILURE MESSAGE = ' || SUBSTR ( FAILURE_MESSAGE , 1 , 50 ) ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'FAILURE MESSAGE = ' || SUBSTR ( FAILURE_MESSAGE , 51 , 50 ) ) ;
           oe_debug_pub.add(  'FAILURE MESSAGE = ' || SUBSTR ( FAILURE_MESSAGE , 101 , 50 ) ) ;
       END IF;
     END IF;
   END IF;


   ----------------------------------------------------------------------
   -- (2) If item value is passed, get ID by matching concatenated
   -- segments with this value
   ----------------------------------------------------------------------

   IF l_inventory_item IS NOT NULL THEN

     BEGIN
       SELECT inventory_item_id
       INTO  l_inventory_item_id_int
       FROM  mtl_system_items_vl
       WHERE concatenated_segments = l_inventory_item
         AND   customer_order_enabled_flag = 'Y'
         AND   bom_item_type in (1,2,4)
         AND   organization_id = OE_BULK_ORDER_PVT.G_ITEM_ORG;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
     END;

   END IF;


   ----------------------------------------------------------------------
   -- (3) For INTERNAL items, return internal item ID
   ----------------------------------------------------------------------

   IF p_line_rec.item_identifier_type(p_index) = 'INT' THEN

      p_line_rec.inventory_item_id(p_index) := l_inventory_item_id_int;

   ----------------------------------------------------------------------
   -- (4) For CUSTOMER items, get inv item ID using INV API if ordered item
   -- or ordered item id fields are passed.
   ----------------------------------------------------------------------

   ELSIF p_line_rec.item_identifier_type(p_index) = 'CUST' THEN

     IF p_line_rec.ordered_item_id(p_index) IS NULL
        AND p_line_rec.ordered_item(p_index) IS NULL THEN
        RETURN;
     ENd IF;

     IF p_line_rec.sold_to_org_id(p_index) IS NULL THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SOLD TO ORG ID IS MISSING , CAN NOT GET CUST ITEM' ) ;
       END IF;
       FND_MESSAGE.SET_NAME('ONT','OE_INVALID_CUSTOMER_ID');
       OE_BULK_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value(
                       Z_Customer_Item_Id => p_line_rec.ordered_item_id(p_index)
                     , Z_Customer_Id => p_line_rec.sold_to_org_id(p_index)
                     , Z_Customer_Item_Number => p_line_rec.ordered_item(p_index)
                     , Z_Organization_Id => nvl(p_line_rec.ship_from_org_id(p_index)
                                                ,OE_BULK_ORDER_PVT.G_ITEM_ORG)
                     , Z_Inventory_Item_Id => NULL
                     , Attribute_Name => 'INVENTORY_ITEM_ID'
                     , Error_Code => l_error_code
                     , Error_Flag => l_error_flag
                     , Error_Message => l_error_message
                     , Attribute_Value => l_inventory_item_id_cust
                     );

     IF l_error_message IS NOT NULL THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'INV API CI_ATTR_VAL FOR INV_ITEM_ID RETURNED ERROR' ) ;
       END IF;
       FND_MESSAGE.SET_NAME('ONT','OE_INV_CUS_ITEM');
       FND_MESSAGE.SET_TOKEN('ERROR_CODE', l_error_code);
       FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE', l_error_message);
       OE_BULK_MSG_PUB.Add;
     END IF;

     INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value(
                       Z_Customer_Item_Id => p_line_rec.ordered_item_id(p_index)
                     , Z_Customer_Id => p_line_rec.sold_to_org_id(p_index)
                     , Z_Customer_Item_Number => p_line_rec.ordered_item(p_index)
                     , Z_Organization_Id => nvl(p_line_rec.ship_from_org_id(p_index)
                                                ,OE_BULK_ORDER_PVT.G_ITEM_ORG)
                     , Z_Inventory_Item_Id => NULL
                     , Attribute_Name => 'CUSTOMER_ITEM_ID'
                     , Error_Code => l_error_code
                     , Error_Flag => l_error_flag
                     , Error_Message => l_error_message
                     , Attribute_Value => p_line_rec.ordered_item_id(p_index)
                     );

     IF l_error_message IS NOT NULL THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'INV API CI_ATTR_VAL FOR ORDERED_ITEM_ID RETURNED ERROR' ) ;
       END IF;
       FND_MESSAGE.SET_NAME('ONT','OE_INV_CUS_ITEM');
       FND_MESSAGE.SET_TOKEN('ERROR_CODE', l_error_code);
       FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE', l_error_message);
       OE_BULK_MSG_PUB.Add;
     END IF;

     IF l_inventory_item_id_int <> l_inventory_item_id_cust THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INV ITEM AND CUST ITEM MISMATCH' ) ;
        END IF;
        FND_MESSAGE.SET_NAME('ONT','OE_INV_INT_CUS_ITEM_ID');
        FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',l_inventory_item_id_int);
        FND_MESSAGE.SET_TOKEN('CUST_ITEM_ID',l_inventory_item_id_cust);
        OE_BULK_MSG_PUB.Add;
     ELSIF l_inventory_item_id_int IS NOT NULL
     THEN
        p_line_rec.inventory_item_id(p_index):= l_inventory_item_id_int;
     ELSIF l_inventory_item_id_cust IS NOT NULL
     THEN
        p_line_rec.inventory_item_id(p_index):= l_inventory_item_id_cust;
     END IF;

   ----------------------------------------------------------------------
   -- (4) For other item cross references, fetch INV item ID from cross
   -- references table
   ----------------------------------------------------------------------

   ELSE

     BEGIN
       SELECT inventory_item_id
       INTO   l_inventory_item_id_gen
       FROM   mtl_cross_references
       WHERE  cross_reference_type = p_line_rec.item_identifier_type(p_index)
         AND  (organization_id = OE_BULK_ORDER_PVT.G_ITEM_ORG
               OR organization_id IS NULL)
         AND  cross_reference = p_line_rec.ordered_item(p_index)
         AND  (inventory_item_id = l_inventory_item_id_int
               OR l_inventory_item_id_int IS NULL);
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NO DATA FOUND - GENERIC CROSS REF' ) ;
         END IF;
         NULL;
       WHEN TOO_MANY_ROWS THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'TOO MANY ROWS ERROR: '||SQLERRM ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_NOT_UNIQUE_ITEM');
         FND_MESSAGE.SET_TOKEN('GENERIC_ITEM', p_line_rec.ordered_item(p_index));
         OE_BULK_MSG_PUB.Add;
     END;

     IF l_inventory_item_Id_int <> l_inventory_item_id_gen
     THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'WARNING: GENERIC AND INVENTORY ITEM ARE DIFFERENT' ) ;
       END IF;
       FND_MESSAGE.SET_NAME('ONT','OE_INV_INT_CUS_ITEM_ID');
       FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', l_inventory_item_id_int);
       FND_MESSAGE.SET_TOKEN('CUST_ITEM_ID', l_inventory_item_id_gen);
       OE_BULK_MSG_PUB.Add;
       p_line_rec.inventory_item_id(p_index):= l_inventory_item_id_gen;
     ELSIF l_inventory_item_id_int IS NOT NULL
     THEN
        p_line_rec.inventory_item_id(p_index):= l_inventory_item_id_int;
     ELSIF l_inventory_item_id_gen IS NOT NULL
     THEN
        p_line_rec.inventory_item_id(p_index):= l_inventory_item_id_gen;
     END IF;

   END IF;




EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     p_line_rec.lock_control(p_index) := -99;
   WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , LINE.GET_ITEM_INFO' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    IF OE_BULK_MSG_PUB.Check_Msg_Level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Get_Item_Info'
        );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Item_Info;

FUNCTION Validate_Subinventory
( p_subinventory                IN  VARCHAR2
, p_inventory_item_id           IN  NUMBER
, p_ship_from_org_id            IN  NUMBER
, p_source_type_code            IN  VARCHAR2
, p_order_source_id             IN  NUMBER
)
RETURN BOOLEAN
IS
  l_dummy    VARCHAR2(10);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF p_ship_from_org_id IS NOT NULL THEN

     BEGIN
       SELECT 'VALID'
       INTO  l_dummy
       FROM MTL_SUBINVENTORIES_TRK_VAL_V
       WHERE organization_id = p_ship_from_org_id
         AND secondary_inventory_name = p_subinventory;
     EXCEPTION
       WHEN OTHERS THEN
         fnd_message.set_name('ONT','OE_SUBINV_INVALID');
         OE_BULK_MSG_PUB.Add;
         RETURN FALSE;
     END;

  END IF;

  IF p_source_type_code = 'INTERNAL' THEN

     IF p_ship_from_org_id is null THEN

        fnd_message.set_name('ONT', 'OE_ATTRIBUTE_REQUIRED');
        fnd_message.set_token('ATTRIBUTE'
           ,OE_Order_UTIL.Get_Attribute_Name('SHIP_FROM_ORG_ID'));
        OE_BULK_MSG_PUB.Add;
        RETURN FALSE;

     ELSE

        -- validate the subinv is allowed (expense/asset)
        -- because defaulting can be defaulting an expense sub
        -- and the INV profile is set to No.
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ENTITY: PROFILE EXPENSE_ASSET:' || FND_PROFILE.VALUE ( 'INV:EXPENSE_TO_ASSET_TRANSFER' ) , 5 ) ;
          END IF;
        BEGIN

          select 'Y'
          into l_dummy
          from mtl_subinventories_trk_val_v sub
          where sub.organization_id = p_ship_from_org_id
            and sub.secondary_inventory_name = p_subinventory
            and (fnd_profile.value('INV:EXPENSE_TO_ASSET_TRANSFER') = 1
                    OR
                   (fnd_profile.value('INV:EXPENSE_TO_ASSET_TRANSFER') <> 1
                    and nvl(p_order_source_id, -1) <> 10
                   )
                    OR
                   (fnd_profile.value('INV:EXPENSE_TO_ASSET_TRANSFER') <> 1
                    and nvl(p_order_source_id, -1) = 10
                    and 'N' = (select inventory_asset_flag
                               from mtl_system_items
                               where inventory_item_id = p_inventory_item_id
                               and organization_id = p_ship_from_org_id
                    )
                   )
                    OR
                   (fnd_profile.value('INV:EXPENSE_TO_ASSET_TRANSFER') <> 1
                    and nvl(p_order_source_id, -1) = 10
                    and 'Y' = (select inventory_asset_flag
                               from mtl_system_items
                               where inventory_item_id = p_inventory_item_id
                               and organization_id = p_ship_from_org_id
                    )
                    and sub.asset_inventory = 1
                   )
                   );
        EXCEPTION
          WHEN OTHERS THEN
            fnd_message.set_name('ONT', 'OE_SUBINV_NON_ASSET');
            OE_BULK_MSG_PUB.ADD;
            RETURN FALSE;
        END;

     END IF; -- end if ship from is null

  END IF; -- end if source type is internal

  RETURN TRUE;

END Validate_Subinventory;


FUNCTION Validate_Item_Warehouse
( p_inventory_item_id           IN  NUMBER
, p_ship_from_org_id            IN  NUMBER
, p_item_type_code              IN  VARCHAR2
, p_line_id                     IN  NUMBER
, p_top_model_line_id           IN  NUMBER
, p_source_document_type_id     IN  NUMBER
, p_line_category_code          IN  VARCHAR2)
RETURN BOOLEAN
IS
    l_dummy    VARCHAR2(10);
BEGIN

   -- The customer_order_enabled_flag for config item
   -- is set to 'N'

   /* Bug 1741158 chhung modify BEGIN */
   IF  p_line_category_code ='ORDER' THEN

     /* for Internal Orders */
     /* Internal Orders only support standard item */
     IF p_source_document_type_id = 10 THEN
     --perf bug 5121218, replace org_organization_definitions with
     --hr_all_organization_units

     /*   SELECT null
      INTO  l_dummy
      FROM  mtl_system_items msi,
                 org_organization_definitions org
      WHERE msi.inventory_item_id = p_inventory_item_id
      AND   org.organization_id= msi.organization_id
      AND   msi.internal_order_enabled_flag = 'Y'
        AND   sysdate <= nvl( org.disable_date, sysdate)
      AND   org.organization_id= p_ship_from_org_id
      AND   rownum=1;
      */

      SELECT null
      INTO  l_dummy
      FROM  mtl_system_items msi,
            hr_all_organization_units org
      WHERE msi.inventory_item_id = p_inventory_item_id
      AND   org.organization_id= msi.organization_id
      AND   msi.internal_order_enabled_flag = 'Y'
        AND   sysdate <= nvl( org.date_to, sysdate)
      AND   org.organization_id= p_ship_from_org_id
      AND   rownum=1;

     ELSE /* other orders  except Internal*/
        IF p_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED OR
            p_item_type_code = OE_GLOBALS.G_ITEM_CONFIG OR
             p_item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
            p_item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
            (p_item_type_code = OE_GLOBALS.G_ITEM_KIT AND
               nvl(p_top_model_line_id, -1) <> p_line_id)
        THEN
     --perf bug 5121218, replace org_organization_definitions with
     --hr_all_organization_units

      /* SELECT null
       INTO  l_dummy
       FROM  mtl_system_items msi,
                        org_organization_definitions org
       WHERE msi.inventory_item_id = p_inventory_item_id
       AND   org.organization_id= msi.organization_id
       AND   sysdate <= nvl( org.disable_date, sysdate)
       AND   org.organization_id= p_ship_from_org_id
       AND   rownum=1;
       */

       SELECT null
       INTO  l_dummy
       FROM  mtl_system_items msi,
             hr_all_organization_units org
       WHERE msi.inventory_item_id = p_inventory_item_id
       AND   org.organization_id= msi.organization_id
       AND   sysdate <= nvl( org.date_to, sysdate)
       AND   org.organization_id= p_ship_from_org_id
       AND   rownum=1;

        ELSE /* item type is MODEL,STANDARD,SERVICE,KIT in top most level*/
     --perf bug 5121218, replace org_organization_definitions with
     --hr_all_organization_units

      /* SELECT null
       INTO  l_dummy
       FROM  mtl_system_items msi,
                        org_organization_definitions org
       WHERE msi.inventory_item_id = p_inventory_item_id
       AND   org.organization_id= msi.organization_id
       AND   msi.customer_order_enabled_flag = 'Y'
       AND   sysdate <= nvl( org.disable_date, sysdate)
       AND   org.organization_id= p_ship_from_org_id
       AND   rownum=1;
      */

       SELECT null
       INTO  l_dummy
       FROM  mtl_system_items msi,
             hr_all_organization_units org
       WHERE msi.inventory_item_id = p_inventory_item_id
       AND   org.organization_id= msi.organization_id
       AND   msi.customer_order_enabled_flag = 'Y'
       AND   sysdate <= nvl( org.date_to, sysdate)
       AND   org.organization_id= p_ship_from_org_id
       AND   rownum=1;

       END IF;
     END IF;

   ELSE /* p_line_category_code is 'RETURN */
   -- It's for Return group!!
null;
   END IF;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
       RETURN FALSE;

END Validate_Item_Warehouse;


PROCEDURE Validate_Decimal_Quantity
 ( p_item_id       IN NUMBER
 , p_item_type_code  IN VARCHAR2
 , p_input_quantity  IN NUMBER
 , p_uom_code   IN VARCHAR2
 , x_return_status  IN OUT NOCOPY NUMBER
 ) IS
l_validated_quantity     NUMBER;
l_primary_quantity       NUMBER;
l_qty_return_status      VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
         -- validate input quantity
    IF (p_input_quantity is not null AND
        p_input_quantity <> FND_API.G_MISS_NUM) THEN

        IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
         IF nvl(p_input_quantity, 0) < 0 -- Process HVOP  added check for negative as was missing -NB take out when support for RMAs needed

    		THEN
    		FND_MESSAGE.SET_NAME('ONT', 'SO_PR_NEGATIVE_AMOUNT');
                OE_BULK_MSG_PUB.Add('Y','ERROR');
      		x_return_status := -99;
      		IF l_debug_level  > 0 THEN
    			oe_debug_pub.add ('Validate decimal quantity - quantity negative so error ', 3);
      		END IF;
      		RETURN;
         END IF; -- IF nvl(p_input_quantity, 0) < 0

        END IF; -- IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

        IF trunc(p_input_quantity) <> p_input_quantity THEN

             IF p_item_type_code is not NULL THEN

                IF p_item_type_code IN ('MODEL', 'OPTION', 'KIT',
                  'CLASS','INCLUDED', 'CONFIG')
                THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'ITEM IS CONFIG RELATED WITH DECIMAL QTY' , 2 ) ;
                  END IF;
                    FND_MESSAGE.SET_NAME('ONT', 'OE_CONFIG_NO_DECIMALS');
                    OE_BULK_MSG_PUB.Add('Y','ERROR');
          x_return_status := -99;

                ELSE

                    inv_decimals_pub.validate_quantity(
                    p_item_id          => p_item_id,
                    p_organization_id  =>
                        OE_Bulk_Order_PVT.G_ITEM_ORG,
                    p_input_quantity   => p_input_quantity,
                    p_uom_code         => p_uom_code,
                    x_output_quantity  => l_validated_quantity,
                    x_primary_quantity => l_primary_quantity,
                    x_return_status    => l_qty_return_status);

                    IF l_qty_return_status = 'W' OR
                       l_qty_return_status = 'E' THEN
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'INV DECIMAL API RETURN ' || L_QTY_RETURN_STATUS , 2 ) ;
                            oe_debug_pub.add(  'INPUT_QTY '|| P_INPUT_QUANTITY , 2 ) ;
                            oe_debug_pub.add(  'L_PRI_QTY '|| L_PRIMARY_QUANTITY , 2 ) ;
                            oe_debug_pub.add(  'L_VAL_QTY '|| L_VALIDATED_QUANTITY , 2 ) ;
                        END IF;
                        /* bug 2926436 */
                        IF l_qty_return_status = 'W' THEN
                            fnd_message.set_name('ONT', 'OE_DECIMAL_MAX_PRECISION');
                        END IF;
                        --move INV error message to OE message stack
                        OE_BULK_MSG_PUB.Add('Y','ERROR');
                        x_return_status := -99;
                    END IF;

           END IF;  -- config related item type
           END IF; -- item_type_code is null
        END IF; -- if not decimal qty
    END IF; -- quantity is null

END Validate_Decimal_Quantity;

FUNCTION Validate_Item_Fields
( p_inventory_item_id    IN  NUMBER
, p_ordered_item_id      IN  NUMBER
, p_item_identifier_type IN  VARCHAR2
, p_ordered_item         IN  VARCHAR2
, p_sold_to_org_id       IN  NUMBER
, p_line_category_code   IN  VARCHAR2 /*Bug 1678296- chhung adds*/
, p_item_type_code      IN  VARCHAR2 /*Bug 1741158- chhung adds */
, p_line_id              IN  NUMBER  /*Bug 1741158- chhung adds */
, p_top_model_line_id    IN  NUMBER /*Bug 1741158- chhung adds */
, p_source_document_type_id  IN  NUMBER) /*Bug 1741158- chhung adds */
RETURN BOOLEAN
IS
  l_c_index              NUMBER;
  l_dummy                VARCHAR2(10);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  -- If inventory item is not assigned to the item validation org,
  -- cache api will raise no_data_found and this validation function
  -- will return FALSE.
  l_c_index := OE_Bulk_Cache.Load_Item(p_inventory_item_id,null);

  IF nvl(p_item_identifier_type, 'INT') = 'INT' THEN

      /* Bug 1741158 chhung modify BEGIN */
      IF  p_line_category_code ='ORDER' THEN

         IF p_source_document_type_id = 10
         THEN
         /* for Internal Orders */
         /* Internal Orders only support standard item */
            IF OE_Bulk_Cache.G_ITEM_TBL(l_c_index).internal_order_enabled_flag
                <> 'Y'
            THEN
               RETURN FALSE;
            END IF;
         ELSE  /* other orders  except Internal*/

           IF p_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED OR
             p_item_type_code = OE_GLOBALS.G_ITEM_CONFIG OR
             p_item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
             p_item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
             (p_item_type_code = OE_GLOBALS.G_ITEM_KIT AND
              nvl(p_top_model_line_id, -1) <> p_line_id)
           THEN
             RETURN TRUE;
           ELSE /* item type is MODEL,STANDARD,SERVICE,KIT in top most level*/
              IF OE_Bulk_Cache.G_ITEM_TBL(l_c_index).customer_order_enabled_flag
                <> 'Y'
              THEN
                 RETURN FALSE;
              END IF;
           END IF;

         END IF;

      /* Bug 1741158 chhung modify END */
     ELSE /* p_line_category_code is 'RETURN */
         -- It's for Return group!!
         null;
     END IF;

   ELSIF nvl(p_item_identifier_type, 'INT') = 'CUST' THEN
       --Bug 1678296 chhung modify BEGIN
      IF  p_line_category_code ='ORDER' THEN
      SELECT 'valid'
      INTO  l_dummy
      FROM   mtl_customer_items citems
                ,mtl_customer_item_xrefs cxref
            ,mtl_system_items_vl sitems
      WHERE citems.customer_item_id = cxref.customer_item_id
        AND cxref.inventory_item_id = sitems.inventory_item_id
        AND sitems.inventory_item_id = p_inventory_item_id
        AND sitems.organization_id =
                  OE_Bulk_Order_PVT.G_ITEM_ORG
        AND citems.customer_item_id = p_ordered_item_id
        AND citems.customer_id = p_sold_to_org_id
        AND citems.inactive_flag = 'N'
        AND cxref.inactive_flag = 'N';
      ELSE /* line_category_code is 'RETURN'*/
      SELECT 'valid'
      INTO  l_dummy
      FROM   mtl_customer_items citems
            ,mtl_customer_item_xrefs cxref
            ,mtl_system_items_vl sitems
      WHERE citems.customer_item_id = cxref.customer_item_id
        AND cxref.inventory_item_id = sitems.inventory_item_id
        AND sitems.inventory_item_id = p_inventory_item_id
        AND sitems.organization_id = OE_Bulk_Order_PVT.G_ITEM_ORG
        AND citems.customer_item_id = p_ordered_item_id
        AND citems.customer_id = p_sold_to_org_id;

      END IF;
      --Bug 1678296 chhung modify END
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
           AND sitems.organization_id = OE_Bulk_Order_PVT.G_ITEM_ORG
           AND sitems.inventory_item_id = p_inventory_item_id
           AND items.cross_reference_type = p_item_identifier_type
           AND items.cross_reference = p_ordered_item
           AND (items.organization_id = sitems.organization_id
               OR  items.org_independent_flag = 'Y'); /*Bug 1636532*/
      END IF;
   END IF;

   RETURN TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'VALIDATE_ITEM_FIELDS: NO DATA FOUND' , 1 ) ;
       END IF;
       IF nvl(p_item_identifier_type, 'INT') = 'INT' THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID INTERNAL ITEM' ) ;
         END IF;
       ELSIF nvl(p_item_identifier_type, 'INT') = 'CUST' THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID CUSTOMER ITEM' ) ;
         END IF;
       ELSE
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVALID GENERIC ITEM' ) ;
         END IF;
       END IF;
       RETURN FALSE;
   WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'VALIDATE_ITEM_FIELDS: WHEN OTHERS' , 1 ) ;
       END IF;
       RETURN FALSE;
END Validate_Item_Fields;

FUNCTION Validate_task
( p_project_id  IN  NUMBER
, p_task_id     IN  NUMBER)
RETURN BOOLEAN
IS
l_dummy VARCHAR2(10);
BEGIN
    -- Please add validation here.
    RETURN TRUE;
END Validate_task;

FUNCTION Validate_task_reqd
( p_project_id  IN  NUMBER
 ,p_ship_from_org_id IN NUMBER)
RETURN BOOLEAN
IS
l_project_control_level NUMBER;
BEGIN
    -- Please add validation here.
    RETURN TRUE;
END Validate_task_reqd;

FUNCTION Validate_User_Item_Description
( p_user_item_description  IN  VARCHAR2)

RETURN BOOLEAN
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF LENGTHB(p_user_item_description) > 240 THEN
    fnd_message.set_name('ONT','ONT_USER_ITEM_DESC_TOO_LONG');
    OE_BULK_MSG_PUB.ADD;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'THE LENGTH OF USER_ITEM_DESCRIPTION SHOULD NOT EXCEED 240 CHARA CTERS FOR DROP SHIP LINES.' , 3 ) ;
END IF;
    RETURN FALSE;
  END IF;

    RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'VALIDATE_USER_ITEM_DESCRIPTION: WHEN OTHERS' , 1 ) ;
       END IF;
       RETURN FALSE;
END Validate_User_Item_Description;


PROCEDURE Unbook_Order
          ( p_header_index       IN NUMBER
           ,p_last_line_index    IN NUMBER
           ,p_line_rec           IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE)
IS
  l_header_id                NUMBER;
  l_index                    NUMBER;
  l_ii_index                 NUMBER;
  l_last_ii_index            NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

   l_header_id := OE_Bulk_Order_PVT.g_header_rec.header_id(p_header_index);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'UNBOOK ORDER , HEADER ID:'||L_HEADER_ID ) ;
       oe_debug_pub.add(  'HEADER INDEX :'||P_HEADER_INDEX ) ;
       oe_debug_pub.add(  'LAST LINE INDEX :'||P_LAST_LINE_INDEX ) ;
   END IF;

   -- Unset booking fields on header global

   OE_Bulk_Order_PVT.g_header_rec.booked_flag(p_header_index) := 'N';

   -- Unset booking fields on line global records

   l_index := p_last_line_index;
   WHILE p_line_rec.header_id.EXISTS(l_index) LOOP

     IF p_line_rec.header_id(l_index) = l_header_id THEN
        p_line_rec.booked_flag(l_index) := 'N';
        -- Un-set the global on included item records
        IF p_line_rec.ii_start_index(l_index) IS NOT NULL THEN
           l_ii_index := p_line_rec.ii_start_index(l_index);
           l_last_ii_index := l_ii_index +
                         p_line_rec.ii_count(l_index) - 1;
           WHILE l_ii_index <= l_last_ii_index LOOP
             p_line_rec.booked_flag(l_ii_index) := 'N';
             l_ii_index := l_ii_index + 1;
           END LOOP;
        END IF;
     ELSE
        -- No more lines for this header
        EXIT;
     END IF;

     l_index := l_index - 1;

   END LOOP;

EXCEPTION
    WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , LINE.UNBOOK_ORDER' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    IF OE_BULK_MSG_PUB.Check_Msg_Level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Unbook_Order'
        );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Unbook_Order;

PROCEDURE Default_Record
     (p_line_rec        IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
     ,p_index           IN NUMBER
     ,p_header_index    IN NUMBER
     ,x_return_status   OUT NOCOPY VARCHAR2
     )
IS
l_c_index      NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Validation of defaulted attributes - when to do this, within the
     -- cache for each source? YES!

     -- ASSUMPTION: The hierarchy for defaulting sources for each of the
     -- attributes can only be 1.Item 2.Ship To 3.Order Header

     -- Populate Ship To first, since it may be used to override Header defaults
    IF p_line_rec.org_id(p_index) IS NULL THEN
        p_line_rec.org_id(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.org_id(p_header_index);
     END IF;



     IF p_line_rec.ship_to_org_id(p_index) IS NULL THEN
        p_line_rec.ship_to_org_id(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.ship_to_org_id(p_header_index);
     END IF;

     -- Default attributes that have item as the first source

     IF p_line_rec.inventory_item_id(p_index) IS NOT NULL
        AND (p_line_rec.accounting_rule_id(p_index) IS NULL
             OR p_line_rec.invoicing_rule_id(p_index) IS NULL
             OR p_line_rec.ship_tolerance_above(p_index) IS NULL
             OR p_line_rec.ship_tolerance_below(p_index) IS NULL
             OR p_line_rec.order_quantity_uom(p_index) IS NULL
             OR p_line_rec.ship_from_org_id(p_index) IS NULL
             )
     THEN

        BEGIN

        l_c_index := OE_BULK_CACHE.Load_Item
                          (p_key1 => p_line_rec.inventory_item_id(p_index)
                          ,p_key2 => p_line_rec.ship_from_org_id(p_index)
                          ,p_default_attributes => 'Y');

        p_line_rec.accounting_rule_id(p_index) := nvl(p_line_rec.accounting_rule_id(p_index)
                              ,OE_BULK_CACHE.G_ITEM_TBL(l_c_index).accounting_rule_id);
        p_line_rec.invoicing_rule_id(p_index) := nvl(p_line_rec.invoicing_rule_id(p_index)
                              ,OE_BULK_CACHE.G_ITEM_TBL(l_c_index).invoicing_rule_id);
        p_line_rec.ship_tolerance_above(p_index) := nvl(p_line_rec.ship_tolerance_above(p_index)
                              ,OE_BULK_CACHE.G_ITEM_TBL(l_c_index).ship_tolerance_above);
        p_line_rec.ship_tolerance_below(p_index) := nvl(p_line_rec.ship_tolerance_below(p_index)
                              ,OE_BULK_CACHE.G_ITEM_TBL(l_c_index).ship_tolerance_below);
        p_line_rec.order_quantity_uom(p_index) := nvl(p_line_rec.order_quantity_uom(p_index)
                              ,OE_BULK_CACHE.G_ITEM_TBL(l_c_index).primary_uom_code);
        p_line_rec.ship_from_org_id(p_index) := nvl(p_line_rec.ship_from_org_id(p_index)
                              ,OE_BULK_CACHE.G_ITEM_TBL(l_c_index).default_shipping_org);

        -- Invalid item - error message populated during validation
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ITEM CACHE RETURNS NO DATA FOUND' ) ;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END;

     END IF;

     -- Default attributes that have ship to as the first source
     -- or is the next source after item.

     IF p_line_rec.ship_to_org_id(p_index) IS NOT NULL
        AND ( p_line_rec.fob_point_code(p_index) IS NULL
             OR p_line_rec.freight_terms_code(p_index) IS NULL
             OR p_line_rec.shipping_method_code(p_index) IS NULL
             OR p_line_rec.ship_tolerance_above(p_index) IS NULL
             OR p_line_rec.ship_tolerance_below(p_index) IS NULL
             OR p_line_rec.ship_from_org_id(p_index) IS NULL
             OR p_line_rec.item_identifier_type(p_index) IS NULL
             OR p_line_rec.demand_class_code(p_index) IS NULL
             )
     THEN

        BEGIN

        l_c_index := OE_BULK_CACHE.Load_Ship_To
                          (p_key => p_line_rec.ship_to_org_id(p_index)
                          ,p_default_attributes => 'Y');

        p_line_rec.fob_point_code(p_index) := nvl(p_line_rec.fob_point_code(p_index)
                              ,OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).fob_point_code);
        p_line_rec.freight_terms_code(p_index) := nvl(p_line_rec.freight_terms_code(p_index)
                              ,OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).freight_terms_code);
        p_line_rec.shipping_method_code(p_index) := nvl(p_line_rec.shipping_method_code(p_index)
                              ,OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).shipping_method_code);
        p_line_rec.ship_tolerance_above(p_index) := nvl(p_line_rec.ship_tolerance_above(p_index)
                              ,OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).ship_tolerance_above);
        p_line_rec.ship_tolerance_below(p_index) := nvl(p_line_rec.ship_tolerance_below(p_index)
                              ,OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).ship_tolerance_below);
        p_line_rec.ship_from_org_id(p_index) := nvl(p_line_rec.ship_from_org_id(p_index)
                              ,OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).ship_from_org_id);
        p_line_rec.item_identifier_type(p_index) := nvl(p_line_rec.item_identifier_type(p_index)
                              ,OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).item_identifier_type);
        p_line_rec.demand_class_code(p_index) := nvl(p_line_rec.demand_class_code(p_index)
                              ,OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).demand_class_code);

        -- Invalid ship to - error message populated during validation
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SHIP TO CACHE RETURNS NO DATA FOUND' ) ;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END;

     END IF;

     -- Default line type from order type

     IF p_line_rec.line_type_id(p_index) IS NULL THEN
        l_c_index := OE_Bulk_Cache.Load_Order_Type
          (p_key => OE_Bulk_Order_PVT.g_header_rec.order_type_id(p_header_index)
          ,p_default_attributes => 'Y'
          );
        p_line_rec.line_type_id(p_index) :=
          OE_BULK_CACHE.G_ORDER_TYPE_TBL(l_c_index).default_outbound_line_type_id;
     END IF;

     -- Default remaining attributes from Order Header

     IF p_line_rec.accounting_rule_id(p_index) IS NULL THEN
        p_line_rec.accounting_rule_id(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.accounting_rule_id(p_header_index);
     END IF;

     IF p_line_rec.demand_class_code(p_index) IS NULL THEN
        p_line_rec.demand_class_code(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.demand_class_code(p_header_index);
     END IF;

     IF p_line_rec.fob_point_code(p_index) IS NULL THEN
        p_line_rec.fob_point_code(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.fob_point_code(p_header_index);
     END IF;

     IF p_line_rec.freight_terms_code(p_index) IS NULL THEN
        p_line_rec.freight_terms_code(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.freight_terms_code(p_header_index);
     END IF;

     IF p_line_rec.invoicing_rule_id(p_index) IS NULL THEN
        p_line_rec.invoicing_rule_id(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.invoicing_rule_id(p_header_index);
     END IF;

     IF p_line_rec.payment_term_id(p_index) IS NULL THEN
        p_line_rec.payment_term_id(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.payment_term_id(p_header_index);
     END IF;

     IF p_line_rec.price_list_id(p_index) IS NULL THEN
        p_line_rec.price_list_id(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.price_list_id(p_header_index);
     END IF;

     IF p_line_rec.salesrep_id(p_index) IS NULL THEN
        p_line_rec.salesrep_id(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.salesrep_id(p_header_index);
     END IF;

     IF p_line_rec.ship_tolerance_above(p_index) IS NULL THEN
        p_line_rec.ship_tolerance_above(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.ship_tolerance_above(p_header_index);
     END IF;

     IF p_line_rec.ship_tolerance_below(p_index) IS NULL THEN
        p_line_rec.ship_tolerance_below(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.ship_tolerance_below(p_header_index);
     END IF;

     IF p_line_rec.shipping_method_code(p_index) IS NULL THEN
        p_line_rec.shipping_method_code(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.shipping_method_code(p_header_index);
     END IF;

     IF p_line_rec.shipment_priority_code(p_index) IS NULL THEN
        p_line_rec.shipment_priority_code(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.shipment_priority_code(p_header_index);
     END IF;

     IF p_line_rec.ship_from_org_id(p_index) IS NULL THEN
        p_line_rec.ship_from_org_id(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.ship_from_org_id(p_header_index);
     END IF;

     IF p_line_rec.tax_exempt_flag(p_index) IS NULL THEN
        p_line_rec.tax_exempt_flag(p_index) :=
                 OE_Bulk_Order_PVT.g_header_rec.tax_exempt_flag(p_header_index);
     END IF;


     -- Constant Value Defaults

     IF p_line_rec.pricing_date(p_index) IS NULL THEN
        p_line_rec.pricing_date(p_index) := sysdate;
     END IF;

     IF p_line_rec.request_date(p_index) IS NULL THEN
        p_line_rec.request_date(p_index) := sysdate;
     END IF;

     IF p_line_rec.tax_date(p_index) IS NULL THEN
        p_line_rec.tax_date(p_index) := sysdate;
     END IF;

     IF p_line_rec.tax_exempt_flag(p_index) IS NULL THEN
        p_line_rec.tax_exempt_flag(p_index) := 'S';      -- 'Standard'
     END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , LINE.DEFAULT_RECORD' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    IF OE_BULK_MSG_PUB.Check_Msg_Level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Default_Record'
        );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Default_Record;

PROCEDURE Populate_Internal_Fields
     (p_line_rec        IN  OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
     ,p_index           IN  NUMBER
     ,p_header_index    IN  NUMBER
     ,p_process_tax     IN VARCHAR2 DEFAULT 'N'
     ,p_process_configurations IN VARCHAR2 DEFAULT 'N'
     ,x_unsupported_feature  OUT NOCOPY VARCHAR2
     ,x_return_status   OUT NOCOPY VARCHAR2
     )
IS
  l_c_index                      NUMBER;
  l_d_index                      NUMBER;
  l_inventory_item_id            NUMBER;
  l_return_status                VARCHAR2(1);
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);
  l_inventory_item_id_cust       NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_return_code                  NUMBER; -- INVCONV
  --
BEGIN

   -- Line_ID is pre-generated and read from interface tables
   -- This is to reduce contention as sequential ids will be
   -- assigned to each parallel thread.
   -- (Refer OEBVIMNB.pls)

   -------------------------------------------------------------------
   -- Populate Fields from Header
   -------------------------------------------------------------------
oe_debug_pub.add(  'Populate_Internal_Fields  1' ) ;
   p_line_rec.header_id(p_index) :=
     OE_Bulk_Order_PVT.g_header_rec.header_id(p_header_index);

   p_line_rec.booked_flag(p_index) :=
     OE_Bulk_Order_PVT.g_header_rec.booked_flag(p_header_index);

   IF p_line_rec.sold_to_org_id(p_index) IS NULL THEN
      p_line_rec.sold_to_org_id(p_index) :=
        OE_Bulk_Order_PVT.g_header_rec.sold_to_org_id(p_header_index);
   END IF;

   IF p_line_rec.ship_to_org_id(p_index) IS NULL THEN
      p_line_rec.ship_to_org_id(p_index) :=
        OE_Bulk_Order_PVT.g_header_rec.ship_to_org_id(p_header_index);
   END IF;

   IF p_line_rec.invoice_to_org_id(p_index) IS NULL THEN
      p_line_rec.invoice_to_org_id(p_index) :=
        OE_Bulk_Order_PVT.g_header_rec.invoice_to_org_id(p_header_index);
   ELSIF p_line_rec.invoice_to_org_id(p_index) <>
           OE_Bulk_Order_PVT.g_header_rec.invoice_to_org_id(p_header_index)
   THEN
      FND_MESSAGE.SET_NAME('ONT','OE_BULK_DIFF_INVOICE_TO');
      OE_BULK_MSG_PUB.Add('Y', 'ERROR');
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;


   -------------------------------------------------------------------
   -- Constant Value Internal Defaults
   -------------------------------------------------------------------

   IF p_line_rec.calculate_price_flag(p_index) IS NULL THEN
      p_line_rec.calculate_price_flag(p_index) := 'Y';
   END IF;

--PIB
   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
     IF p_line_rec.pricing_date(p_index) IS NULL THEN
        p_line_rec.pricing_date(p_index) := sysdate;
     END IF;
   END IF;
--PIB

   IF p_line_rec.item_identifier_type(p_index) IS NULL THEN
      p_line_rec.item_identifier_type(p_index) := 'INT';
   END IF;

   IF p_line_rec.source_type_code(p_index) IS NULL THEN
      p_line_rec.source_type_code(p_index) := 'INTERNAL';
   END IF;

   IF p_line_rec.cancelled_quantity(p_index) IS NULL THEN
      p_line_rec.cancelled_quantity(p_index) := 0;
   END IF;

   IF p_line_rec.option_flag(p_index) IS NULL THEN
      IF p_line_rec.item_type_code(p_index) = 'OPTION' THEN
         p_line_rec.option_flag(p_index) := 'Y';
      ELSE p_line_rec.option_flag(p_index) := 'N';
      END IF;
   END IF;

oe_debug_pub.add(  'Populate_Internal_Fields  2' ) ;
   IF OE_Bulk_Order_PVT.G_IMPORT_SHIPMENTS = 'YES'
      AND p_line_rec.orig_sys_shipment_ref(p_index) IS NULL
      AND nvl(p_line_rec.source_document_id(p_index),0) <> 10
   THEN
      p_line_rec.orig_sys_shipment_ref(p_index)
         := 'OE_ORDER_LINES_ALL'||p_line_rec.line_id(p_index)||'.'||'1';
   END IF;

   IF p_line_rec.ship_from_org_id(p_index) IS NOT NULL THEN
      p_line_rec.re_source_flag(p_index) := 'N';
   END IF;

   -------------------------------------------------------------------
   -- Value To ID conversion for Item (includes Item Cross References)
   -------------------------------------------------------------------
   IF p_line_rec.inventory_item_id(p_index) IS NULL THEN

      Get_Item_Info(p_index => p_index
                   ,p_line_rec => p_line_rec
                   );


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INVENTORY_ITEM_ID after Get_Item_Info: ' ||
			 p_line_rec.inventory_item_id(p_index)) ;
      END IF;


   END IF;

   -- Bug 2411113 - Populate ordered item field

   IF p_line_rec.ordered_item(p_index) IS NULL
      AND p_line_rec.item_identifier_type(p_index) IN ('INT', 'CUST')
   THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALL GET_ORDERED_ITEM' ) ;
      END IF;

      Oe_Oe_Form_Line.Get_Ordered_Item
            (x_return_status       => l_return_status,
             x_msg_count => l_msg_count,
             x_msg_data => l_msg_data,
             p_item_identifier_type =>p_line_rec.item_identifier_type(p_index),
             p_inventory_item_id => p_line_rec.inventory_item_id(p_index),
             p_ordered_item_id => p_line_rec.ordered_item_id(p_index),
             p_sold_to_org_id => p_line_rec.sold_to_org_id(p_index),
             x_ordered_item => p_line_rec.ordered_item(p_index)
             );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   END IF;


   -------------------------------------------------------------------
   -- Populate Internal Fields derived from Item
   -------------------------------------------------------------------
oe_debug_pub.add(  'Populate_Internal_Fields  3' ) ;
   IF p_line_rec.inventory_item_id(p_index) IS NOT NULL THEN

      l_inventory_item_id := p_line_rec.inventory_item_id(p_index);
      l_c_index := OE_BULK_CACHE.Load_Item
                       (p_key1 => l_inventory_item_id
                       ,p_key2 => p_line_rec.ship_from_org_id(p_index)
                       );
oe_debug_pub.add(  'Populate_Internal_Fields  3a' ) ;

 -- VAlidate bom item type
      IF p_process_configurations = 'Y' THEN
        oe_debug_pub.add(  'Populate_Internal_Fields  a' ) ;
        -- Error if unsupported Item Type for Bulk Mode
        IF (OE_BULK_CACHE.G_ITEM_TBL(l_c_index).bom_item_type = 4
            AND OE_BULK_CACHE.G_ITEM_TBL(l_c_index).service_item_flag = 'Y')
        THEN  -- Service item type
          oe_debug_pub.add(  'Populate_Internal_Fields  ab' ) ;
          FND_MESSAGE.SET_NAME('ONT','OE_BULK_NOT_SUPP_ITEM_TYPE');
          OE_BULK_MSG_PUB.Add('Y', 'ERROR');
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_unsupported_feature := 'Y';
          p_line_rec.lock_control(p_index) := -98;
        ELSE
         oe_debug_pub.add(  'Populate_Internal_Fields  bc' ) ;
          --bug 3798477
          IF (OE_BULK_CACHE.G_ITEM_TBL(l_c_index).ont_pricing_qty_source = 'S' AND
             OE_BULK_CACHE.G_ITEM_TBL(l_c_index).tracking_quantity_ind = 'P' AND
             OE_BULK_CACHE.G_ITEM_TBL(l_c_index).wms_enabled_flag = 'Y' )
             OR -- 4282392
           (OE_BULK_CACHE.G_ITEM_TBL(l_c_index).tracking_quantity_ind = 'PS' AND
            OE_BULK_CACHE.G_ITEM_TBL(l_c_index).ont_pricing_qty_source = 'S')
THEN
                OE_BULK_ORDER_PVT.G_CATCHWEIGHT := TRUE;
           oe_debug_pub.add(  'Populate_Internal_Fields  b' ) ;
          END IF;
          --bug 3798477
        oe_debug_pub.add(  'Populate_Internal_Fields  bcc' ) ;
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('ITEM_TYPE_CODE = '|| p_line_rec.item_type_code(p_index), 4 );
          END IF;


          IF p_line_rec.item_type_code(p_index) IS NULL THEN

            IF OE_BULK_CACHE.G_ITEM_TBL(l_c_index).bom_item_type = 1 AND
               nvl(p_line_rec.top_model_line_id(p_index), -1)
                         = p_line_rec.line_id(p_index)
            THEN
               p_line_rec.item_type_code(p_index) := 'MODEL';
             END IF;

oe_debug_pub.add(  'Populate_Internal_Fields  aa' ) ;

            IF OE_BULK_CACHE.G_ITEM_TBL(l_c_index).bom_item_type = 1 AND
               nvl(OE_BULK_CACHE.G_Item_Tbl(l_c_index).replenish_to_order_flag, 'N') = 'Y' AND
               nvl(p_line_rec.top_model_line_id(p_index), -1) <> p_line_rec.line_id(p_index)
            THEN

               p_line_rec.item_type_code(p_index) := 'CLASS';
             END IF;

            IF OE_BULK_CACHE.G_ITEM_TBL(l_c_index).bom_item_type = 2 THEN
               p_line_rec.item_type_code(p_index) := 'CLASS';
             END IF;

          IF OE_BULK_CACHE.G_ITEM_TBL(l_c_index).bom_item_type = 4 THEN

               IF OE_BULK_CACHE.G_ITEM_TBL(l_c_index).pick_components_flag = 'Y' THEN
                  p_line_rec.item_type_code(p_index) := 'KIT';
                   ELSIF p_line_rec.top_model_line_id(p_index) IS NOT NULL THEN
                      p_line_rec.item_type_code(p_index) := 'OPTION';
                   oe_debug_pub.add(  'Populate_Internal_Fields  bb' ) ;
              ELSE
                  -- Standard Item
                  p_line_rec.item_type_code(p_index) := OE_GLOBALS.G_ITEM_STANDARD;
               END IF;
            END IF; --bom_item_type = 4

          END IF; -- item_type_code IS NULL

          -- Logic before config support change
          IF OE_BULK_CACHE.G_ITEM_TBL(l_c_index).bom_item_type = 4 AND
             OE_BULK_CACHE.G_ITEM_TBL(l_c_index).pick_components_flag = 'Y'
          THEN
             p_line_rec.component_code(p_index) := to_char(l_inventory_item_id);
             p_line_rec.top_model_line_id(p_index) := p_line_rec.line_id(p_index);
            oe_debug_pub.add(  'Populate_Internal_Fields  cc' ) ;
             --p_line_rec.ship_model_complete_flag(p_index)
             --       := OE_BULK_CACHE.G_ITEM_TBL(l_c_index).ship_model_complete_flag;
                p_line_rec.ship_tolerance_above(p_index) := 0;
                p_line_rec.ship_tolerance_below(p_index) := 0;
          END IF; --bom_item_type = 4

          -- Set ato_line_id on ato_item
          oe_debug_pub.add(  'Populate_Internal_Fields  dd' ) ;
          IF p_line_rec.item_type_code(p_index) IN ('OPTION', 'STANDARD') AND
             nvl(OE_BULK_CACHE.G_Item_Tbl(l_c_index).replenish_to_order_flag, 'N') = 'Y' AND
             nvl(OE_BULK_CACHE.G_Item_Tbl(l_c_index).build_in_wip_flag, 'N') = 'Y'
          THEN
             p_line_rec.ato_line_id(p_index) := p_line_rec.line_id(p_index);
          END IF;
           oe_debug_pub.add(  'Populate_Internal_Fields  ee' ) ;
          -- If current line is Top Model Line
          IF p_line_rec.item_type_code(p_index) IN ( 'MODEL', 'KIT') THEN
             g_curr_top_index := p_index;
             p_line_rec.top_model_line_index(p_index) := g_curr_top_index;
          END IF;
           oe_debug_pub.add(  'Populate_Internal_Fields  ff' ) ;
          -- Set top_model_line_index on child lines
          IF p_line_rec.top_model_line_id(p_index) IS NOT NULL AND
             p_line_rec.top_model_line_id(p_index)
                                      <> p_line_rec.line_id(p_index)
          THEN
              p_line_rec.top_model_line_index(p_index) := g_curr_top_index;
          END IF;
          oe_debug_pub.add(  'Populate_Internal_Fields  gg' ) ;
 -- If the current line as an ATO under PTO or ATO model
          IF p_line_rec.ato_line_id(p_index) = p_line_rec.line_id(p_index) THEN
                  g_curr_ato_index := p_index;
              p_line_rec.ato_line_index(p_index) := p_index;
          END IF;
          oe_debug_pub.add(  'Populate_Internal_Fields  hh' ) ;
          -- Set ato_line_index based on ato_line_id on a line.
          IF p_line_rec.ato_line_id(p_index) IS NOT NULL AND
             p_line_rec.ato_line_id(p_index) <> p_line_rec.line_id(p_index)
          THEN
              p_line_rec.ato_line_index(p_index) := g_curr_ato_index;
          END IF;
          oe_debug_pub.add(  'Populate_Internal_Fields  ii' ) ;
          -- set ship_model_complete_flag
          p_line_rec.ship_model_complete_flag(p_index) :=
OE_BULK_CACHE.G_ITEM_TBL(l_c_index).ship_model_complete_flag;
        END IF; -- supported items

      ELSE -- p_process_configuration = 'N'
         IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'p_process_configuration = N in populate_internal_fields ', 5 ) ;
         END IF;



        -- Error if unsupported Item Type for Bulk Mode

      IF -- Model and Class Items
         OE_BULK_CACHE.G_ITEM_TBL(l_c_index).bom_item_type IN (1,2)
         -- Service Items
         OR (OE_BULK_CACHE.G_ITEM_TBL(l_c_index).bom_item_type = 4
             AND OE_BULK_CACHE.G_ITEM_TBL(l_c_index).service_item_flag = 'Y')
         -- ATO Items
         OR (OE_BULK_CACHE.G_ITEM_TBL(l_c_index).replenish_to_order_flag = 'Y')
      THEN
        oe_debug_pub.add(  'Populate_Internal_Fields  4a' ) ;
        FND_MESSAGE.SET_NAME('ONT','OE_BULK_NOT_SUPP_ITEM_TYPE');
        OE_BULK_MSG_PUB.Add('Y', 'ERROR');
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_unsupported_feature := 'Y';
         p_line_rec.lock_control(p_index) := -98;

      ELSE
        oe_debug_pub.add(  'Populate_Internal_Fields  5a' ) ;
        --bug 3798477
        IF ( OE_BULK_CACHE.G_ITEM_TBL(l_c_index).ont_pricing_qty_source = 'S'   AND   -- INVCONV
           OE_BULK_CACHE.G_ITEM_TBL(l_c_index).tracking_quantity_ind = 'P' AND
           OE_BULK_CACHE.G_ITEM_TBL(l_c_index).wms_enabled_flag = 'Y')
           OR -- 4282392
           (OE_BULK_CACHE.G_ITEM_TBL(l_c_index).tracking_quantity_ind = 'PS' AND
            OE_BULK_CACHE.G_ITEM_TBL(l_c_index).ont_pricing_qty_source = 'S' )

	     THEN
              OE_BULK_ORDER_PVT.G_CATCHWEIGHT := TRUE;
        END IF;
        --bug 3798477
        -- Item Type can be STANDARD or KIT in BULK mode

        IF OE_BULK_CACHE.G_ITEM_TBL(l_c_index).bom_item_type = 4 THEN
 oe_debug_pub.add(  'Populate_Internal_Fields  6a' ) ;
           -- KIT Item
           IF OE_BULK_CACHE.G_ITEM_TBL(l_c_index).pick_components_flag = 'Y' THEN
oe_debug_pub.add(  'Populate_Internal_Fields  7a' ) ;
              p_line_rec.item_type_code(p_index) := OE_GLOBALS.G_ITEM_KIT;
              p_line_rec.component_code(p_index) := to_char(l_inventory_item_id);
              p_line_rec.top_model_line_id(p_index)
                := p_line_rec.line_id(p_index);
              p_line_rec.ship_model_complete_flag(p_index)
                := OE_BULK_CACHE.G_ITEM_TBL(l_c_index).ship_model_complete_flag;

              p_line_rec.ship_tolerance_above(p_index) := 0;
              p_line_rec.ship_tolerance_below(p_index) := 0;

           -- Standard Item
           ELSE
              p_line_rec.item_type_code(p_index) := OE_GLOBALS.G_ITEM_STANDARD;
           END IF;
        END IF;
     oe_debug_pub.add(  'Populate_Internal_Fields  8a' ) ;
        p_line_rec.shippable_flag(p_index)
                := OE_BULK_CACHE.G_ITEM_TBL(l_c_index).shippable_item_flag;
     oe_debug_pub.add(  'Populate_Internal_Fields  9a' ) ;
      END IF;

     oe_debug_pub.add(  'Populate_Internal_Fields  4' ) ;
      END IF; -- p_process_configuration = 'Y'
-- Process Characteristics
-- HVOP  - checks here for     1. qty2  - call function to default secondary quantity if necessary

  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
         -- INVCONV take out defaulting for grade as normal defaulting takes place.


        IF OE_BULK_CACHE.G_ITEM_TBL(l_c_index).tracking_quantity_ind = 'PS' -- INVCONV --
         THEN
          IF l_debug_level  > 0 THEN
          		oe_debug_pub.add(  'about to call CALL calculate_dual_quantity ' ) ;
      		END IF;
      		oe_debug_pub.add(  'Populate_Internal_Fields  5' ) ;
               calculate_dual_quantity(
                         p_line_rec  	     => p_line_rec
                        ,p_index	         => p_index
                        ,p_dualum_ind      => OE_BULK_CACHE.G_ITEM_TBL(l_c_index).secondary_default_ind
                        ,p_x_return_status  => l_return_code
                        );
                        IF l_debug_level  > 0 THEN
          	        	oe_debug_pub.add(  'out of calculate_dual_quantity  1 ' ) ;
      			END IF;
                	IF l_return_code < 0 THEN
                		IF l_debug_level  > 0 THEN
          				oe_debug_pub.add(  'error in calculate_dual_quantity  2 ' ) ;
      				END IF;

                		FND_MESSAGE.SET_NAME('ONT','OE_BULK_OPM_DUAL_QTY_ERROR'); -- HVOP define better OM or GMI error code
        			OE_BULK_MSG_PUB.Add('Y', 'ERROR');
        			x_return_status := FND_API.G_RET_STS_ERROR;
        		END IF;
                        oe_debug_pub.add(  'Populate_Internal_Fields  6' ) ;
			IF l_debug_level  > 0 THEN
          			oe_debug_pub.add(  'out of calculate_dual_quantity  2 ' ) ;
      			END IF;
         END IF; --  IF OE_BULK_CACHE.G_ITEM_TBL(l_c_index)..tracking_quantity_ind == 'PS' -- INVCONV


  END IF;      -- IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

 END IF;


      oe_debug_pub.add(  'Populate_Internal_Fields  7' ) ;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'out of calculate_dual_quantity  3 ' ) ;
      END IF;

   -- Checks based on line type
   BEGIN

   l_c_index := OE_BULK_CACHE.Load_Line_Type
                       (p_key => p_line_rec.line_type_id(p_index));

   l_d_index := OE_BULK_CACHE.Load_Order_Type(OE_Bulk_Order_PVT.g_header_rec.order_type_id(p_header_index));

   IF OE_BULK_CACHE.G_LINE_TYPE_TBL(l_c_index).order_category_code
      <> 'ORDER'
   THEN
      FND_MESSAGE.SET_NAME('ONT','OE_BULK_NOT_SUPP_RETURN');
      OE_BULK_MSG_PUB.Add('Y', 'ERROR');
      x_return_status := FND_API.G_RET_STS_ERROR;
   ELSE
      p_line_rec.line_category_code(p_index) := 'ORDER';
   END IF;

 IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'tax_calculation_flag = '||
                OE_BULK_CACHE.G_LINE_TYPE_TBL(l_c_index).tax_calculation_flag )
;
       oe_debug_pub.add(  'tax_calculation_event = '||
                OE_BULK_CACHE.G_ORDER_TYPE_TBL(l_d_index).tax_calculation_event
) ;
       oe_debug_pub.add(  'p_process_tax = '|| p_process_tax ) ;
   END IF;


  /*--commented for bug 7685103 .We will still import the lines ,tax shall be calculated later from UI

  IF OE_BULK_CACHE.G_LINE_TYPE_TBL(l_c_index).tax_calculation_flag = 'Y'
      AND ((OE_BULK_CACHE.G_ORDER_TYPE_TBL(l_d_index).tax_calculation_event NOT IN ( 'INVOICING' , 'SHIPPING' ))
            OR (OE_BULK_CACHE.G_ORDER_TYPE_TBL(l_d_index).tax_calculation_event IS NULL))
      AND NVL(p_process_tax,'N') <> 'Y'
   THEN
      FND_MESSAGE.SET_NAME('ONT','OE_BULK_NOT_SUPP_TAX_CAL');
      OE_BULK_MSG_PUB.Add('Y', 'ERROR');
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
 */

   -- Invalid line type - error message populated during validation
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       -- Set line category for insert to succeed
       p_line_rec.line_category_code(p_index) := 'ORDER';
       x_return_status := FND_API.G_RET_STS_ERROR;

       -- fix bug 5109227
       p_line_rec.lock_control(p_index) := -99 ;
       fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
             OE_Order_UTIL.Get_Attribute_Name('LINE_TYPE_ID'));
       OE_BULK_MSG_PUB.Add('Y','ERROR');
       -- fix bug 5109227

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO_DATA_FOUND in LOAD_LINE_TYPE' ) ;
       END IF;

   END;

oe_debug_pub.add(  'Populate_Internal_Fields  8' ) ;
   -- End of checks based on line type


   IF p_line_rec.shipping_method_code(p_index) IS NOT NULL
      AND p_line_rec.ship_from_org_id(p_index) IS NOT NULL
   THEN
      p_line_rec.freight_carrier_code(p_index) :=
          OE_BULK_PROCESS_HEADER.Get_Freight_Carrier
          (p_shipping_method_code  => p_line_rec.shipping_method_code(p_index)
           ,p_ship_from_org_id     => p_line_rec.ship_from_org_id(p_index)
          );
   END IF;

   IF p_line_rec.pricing_quantity_uom(p_index) IS NOT NULL
      AND p_line_rec.pricing_quantity(p_index) IS NOT NULL
   THEN
       p_line_rec.pricing_quantity(p_index) := OE_Order_Misc_Util.convert_uom(
                                      p_line_rec.inventory_item_id(p_index),
                                      p_line_rec.order_quantity_uom(p_index),
                                      p_line_rec.pricing_quantity_uom(p_index),
                                      p_line_rec.ordered_quantity(p_index));

   END IF;

   IF p_line_rec.request_date(p_index) IS NOT NULL AND
      p_line_rec.latest_acceptable_date(p_index) IS NULL
   THEN
       p_line_rec.latest_acceptable_date(p_index) :=
             p_line_rec.request_date(p_index) +
      OE_Bulk_Order_PVT.g_header_rec.latest_schedule_limit(p_header_index);
   END IF;

   -- Bug 2802876
   -- Item type code should not be null even for error records.
   -- As further downstream may not be executed for records AFTER
   -- the error records e.g. scheduling, WF starts etc.
   -- This is because these activities may have loops to start
   -- processing when it reaches included item records appended
   -- to end of the line tbl e.g. item_type_code <> 'INCLUDED'
   -- But for null item types, the loop may end earlier resulting
   -- in any record after not being processed.
   IF p_line_rec.item_type_code(p_index) IS NULL THEN
      p_line_rec.item_type_code(p_index) := 'STANDARD';
   END IF;

oe_debug_pub.add(  'Populate_Internal_Fields  9' ) ;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , LINE.POPULATE_INTERNAL_FIELDS' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_BULK_MSG_PUB.Check_Msg_Level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Populate_Internal_Fields'
        );
    END IF;
END Populate_Internal_Fields;


-----------------------------------------------------------------------
-- PUBLIC PROCEDURES/FUNCTIONS
-----------------------------------------------------------------------
---------------------------------------------------------------------
-- PROCEDURE Post_Process
--
-- Post_Processing from OEXVIMSB.pls
---------------------------------------------------------------------
PROCEDURE Post_Process
  ( p_line_rec             IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
  , p_header_rec           IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
  , p_line_index           IN NUMBER
  , p_header_index         IN NUMBER
  )
IS
  l_unit_selling_price     NUMBER;
  l_payment_term_id        NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  -----------------------------------------------------------------
  -- Compare price and payment term
  -----------------------------------------------------------------

  IF p_line_rec.customer_item_net_price(p_line_index) IS NOT NULL
     OR p_line_rec.customer_payment_term_id(p_line_index) IS NOT NULL
  THEN

     -- Select values against DB as pricing calls update values
     -- directly on DB.
     -- When pricing is BULK enabled, updated values should be
     -- on p_line_rec and comparisons should be against the record
     -- values then

     select unit_selling_price, payment_term_id
     into l_unit_selling_price, l_payment_term_id
     from oe_order_lines_all
     where line_id = p_line_rec.line_id(p_line_index);

     IF nvl(p_line_rec.customer_item_net_price(p_line_index)
            ,l_unit_selling_price)
        <> nvl(l_unit_selling_price,FND_API.G_MISS_NUM)
     THEN

       FND_MESSAGE.SET_NAME('ONT','OE_OI_PRICE_WARNING');
       FND_MESSAGE.SET_TOKEN('CUST_PRICE'
                   ,p_line_rec.customer_item_net_price(p_line_index));
       FND_MESSAGE.SET_TOKEN('SPLR_PRICE',l_unit_selling_price);
       OE_BULK_MSG_PUB.Add;

     END IF;

     IF nvl(p_line_rec.customer_payment_term_id(p_line_index)
            ,l_payment_term_id)
        <> nvl(l_payment_term_id,FND_API.G_MISS_NUM)
     THEN

       FND_MESSAGE.SET_NAME('ONT','OE_OI_PAYMENT_TERM_WARNING');
       FND_MESSAGE.SET_TOKEN('CUST_TERM'
                   ,p_line_rec.customer_payment_term_id(p_line_index));
       FND_MESSAGE.SET_TOKEN('SPLR_TERM',l_payment_term_id);
       OE_BULK_MSG_PUB.Add;

     END IF;

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR , LINE.POST_PROCESS' ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , LINE.POST_PROCESS' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    IF OE_BULK_MSG_PUB.Check_Msg_Level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Post_Process'
        );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Post_Process;

---------------------------------------------------------------------
-- PROCEDURE Entity
--
-- Main processing procedure used to process lines in a batch.
-- IN parameters -
-- p_header_rec : order headers in this batch
-- p_line_rec   : order lines in this batch
-- p_defaulting_mode : 'Y' if fixed defaulting is needed, 'N' if
-- defaulting is to be completely bypassed
---------------------------------------------------------------------

PROCEDURE Entity
( p_line_rec               IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
, p_header_rec             IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
, x_line_scredit_rec       IN OUT NOCOPY OE_BULK_ORDER_PVT.SCREDIT_REC_TYPE
, p_defaulting_mode        IN VARCHAR2
, p_process_configurations   IN  VARCHAR2 DEFAULT 'N'
, p_validate_configurations  IN  VARCHAR2 DEFAULT 'Y'
, p_schedule_configurations  IN  VARCHAR2 DEFAULT 'N'
, p_validate_only            IN  VARCHAR2 DEFAULT 'N'
, p_validate_desc_flex     IN VARCHAR2
, p_process_tax            IN VARCHAR2 DEFAULT 'N'
)
IS

  l_dummy                  VARCHAR2(10);
  l_count                  NUMBER;
  l_uom                    VARCHAR2(3);
  header_counter           binary_integer;
  j                        binary_integer;
  l_order_source_id        NUMBER := -99;              -- Holds info for last errored record
  l_orig_sys_document_ref  VARCHAR2(50) := '-99';  -- Holds info for last errored record
  l_error_count            NUMBER := 0;
  l_nbr_ctr                binary_integer := 1;
  l_primary_uom_code       VARCHAR2(3);

  l_unsupported_feature    VARCHAR2(1);
  l_return_status          VARCHAR2(1);
  l_index                  NUMBER;
  l_c_index                NUMBER;
  l_d_index                NUMBER;
  l_book_failed            BOOLEAN := FALSE;
  l_line_count             NUMBER := p_line_rec.line_id.COUNT;
  l_process_name           VARCHAR2(30);

  l_on_generic_hold        BOOLEAN := FALSE;
  l_on_booking_hold        BOOLEAN := FALSE;
  l_on_scheduling_hold     BOOLEAN := FALSE;
  l_ii_on_generic_hold     BOOLEAN := FALSE;
  l_is_ota_line            BOOLEAN := FALSE;
  l_last_line_index        NUMBER;
  l_scredit_index          NUMBER := 1;
  l_ret_status             BOOLEAN := TRUE;
  l_order_date_type_code   VARCHAR2(30);
  l_inventory_item_id      NUMBER; -- HVOP

 -- For AR system parameters
  l_AR_Sys_Param_Rec       AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;
  l_sob_id                 NUMBER;

-- eBTax Changes
  l_ship_to_cust_Acct_id  hz_cust_Accounts.cust_Account_id%type;
  l_ship_to_party_id      hz_cust_accounts.party_id%type;
  l_ship_to_party_site_id hz_party_sites.party_site_id%type;
  l_bill_to_cust_Acct_id  hz_cust_Accounts.cust_Account_id%type;
  l_bill_to_party_id      hz_cust_accounts.party_id%type;
  l_bill_to_party_site_id hz_party_sites.party_site_id%type;
  l_org_id                NUMBER;

  --PP Revenue Recognition
  --ER 4893057
  l_rule_type             VARCHAR2(10);
  l_line_rec_for_hold	  OE_Order_PUB.Line_Rec_Type;  --ER#7479609
  l_header_rec_for_hold   OE_Order_PUB.Header_Rec_Type;  --ER#7479609

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


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING THE ENTITY VALIDATION' ) ;
   END IF;
   header_counter := 1;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'THE LINE COUNT IS '||P_LINE_REC.LINE_ID.COUNT ) ;
   END IF;
   FOR l_index IN 1..l_line_count LOOP

      -- Set the message context for errors.
      oe_bulk_msg_pub.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => p_line_rec.line_id(l_index)
         ,p_header_id                   => p_line_rec.header_id(l_index)
         ,p_line_id                     => p_line_rec.line_id(l_index)
         ,p_orig_sys_document_ref       => p_line_rec.orig_sys_document_ref(l_index)
         ,p_orig_sys_document_line_ref  => p_line_rec.orig_sys_line_ref(l_index)
         ,p_source_document_id          => NULL
         ,p_source_document_line_id     => NULL
         ,p_order_source_id             => p_line_rec.order_source_id(l_index)
         ,p_source_document_type_id     => NULL );

      IF (p_header_rec.order_source_id(header_counter) <>
             p_line_rec.order_source_id(l_index) )
         OR (p_header_rec.orig_sys_document_ref(header_counter) <>
             p_line_rec.orig_sys_document_ref(l_index) )
      THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'HEADER COUNTER :'||HEADER_COUNTER ) ;
               oe_debug_pub.add(  'LINE ORDER SOURCE:'||P_LINE_REC.ORDER_SOURCE_ID ( L_INDEX ) ) ;
               oe_debug_pub.add(  'LINE OSR :'||P_LINE_REC.ORIG_SYS_DOCUMENT_REF ( L_INDEX ) ) ;
           END IF;
           IF l_book_failed THEN
              Unbook_Order(p_header_index    => header_counter
                          ,p_last_line_index => l_last_line_index
                          ,p_line_rec        => p_line_rec
                          );
              l_book_failed := FALSE;
           END IF;

           j := header_counter;

           WHILE j <= p_header_rec.header_id.count
           LOOP
             IF (p_header_rec.order_source_id(j) =
                 p_line_rec.order_source_id(l_index) )
               AND (p_header_rec.orig_sys_document_ref(j) =
                 p_line_rec.orig_sys_document_ref(l_index) )
             THEN
               EXIT;
             END IF;
             j := j+1;
           END LOOP;

           header_counter := j;
           l_nbr_ctr := 1; -- Reset the line number counter

	   -- added for HVOP Tax project
           -- setting start and end line index for new order bug7685103
           OE_BULK_ORDER_PVT.G_HEADER_REC.start_line_index(header_counter) := l_index;
           OE_BULK_ORDER_PVT.G_HEADER_REC.end_line_index(header_counter) := l_index;

	  oe_debug_pub.add('OE_BULK_ORDER_PVT.G_HEADER_REC.start_line_index(header_counter):'||OE_BULK_ORDER_PVT.G_HEADER_REC.start_line_index(header_counter));
	  oe_debug_pub.add('OE_BULK_ORDER_PVT.G_HEADER_REC.end_line_index(header_counter):'||OE_BULK_ORDER_PVT.G_HEADER_REC.end_line_index(header_counter));


      --------------------------------------------------------------
      -- Same order: check for duplicate reference, from OEXVIMPB.pls
      --------------------------------------------------------------
      ELSE

        IF l_last_line_index IS NOT NULL THEN

          IF OE_Bulk_Order_PVT.G_IMPORT_SHIPMENTS = 'NO' THEN
            IF (p_line_rec.orig_sys_line_ref(l_last_line_index)
                 = p_line_rec.orig_sys_line_ref(l_index))
            THEN
              FND_MESSAGE.SET_NAME('ONT','OE_OI_DUPLICATE_REF');
              FND_MESSAGE.SET_TOKEN('DUPLICATE_REF'
                          ,'orig_sys_line_ref');
              p_line_rec.lock_control(l_index) := -99;
              OE_BULK_MSG_PUB.Add;
            END IF;
          ELSIF OE_Bulk_Order_PVT.G_IMPORT_SHIPMENTS = 'YES' THEN
            IF (p_line_rec.orig_sys_line_ref(l_last_line_index)
                 = p_line_rec.orig_sys_line_ref(l_index))
                AND (p_line_rec.orig_sys_shipment_ref(l_last_line_index)
                      = p_line_rec.orig_sys_shipment_ref(l_index))
            THEN
              FND_MESSAGE.SET_NAME('ONT','OE_OI_DUPLICATE_REF');
              FND_MESSAGE.SET_TOKEN('DUPLICATE_REF'
                          ,'orig_sys_line_ref and orig_sys_shipment_ref');
              p_line_rec.lock_control(l_index) := -99;
              OE_BULK_MSG_PUB.Add;
            END IF;
          END IF;

        END IF;

      END IF;

	-- added for HVOP Tax project
        -- setting end line index for this order bug7685103
        OE_BULK_ORDER_PVT.G_HEADER_REC.end_line_index(header_counter) := l_index;


      p_line_rec.line_number(l_index)  := l_nbr_ctr;

      --PIB{
      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
       IF l_debug_level > 0 Then
         oe_debug_pub.add('before integration code');
       END IF;
--         p_line_rec.line_index.extend(1);
--         p_line_rec.header_index.extend(1);
       --  p_line_rec.currency_code.extend(1);
         p_line_rec.line_index(l_index)   := l_index;
         p_line_rec.header_index(l_index) := header_counter;
       --  p_line_rec.currency_code(l_index) := p_header_rec.transactional_curr_code(header_counter);
       IF l_debug_level > 0 Then
         oe_debug_pub.add('after integration code');
       END IF;
      END IF;
      --PIB}

      ---------------------------------------------------------
      -- CALL THE FIXED DEFAULTING PROCEDURE IF NEEDED
      ---------------------------------------------------------

      IF p_defaulting_mode = 'Y' THEN

         Default_Record
              ( p_line_rec           => p_line_rec
               ,p_index              => l_index
               ,p_header_index       => header_counter
               ,x_return_status      => l_return_status
               );

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            p_line_rec.lock_control(l_index) := -99;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      END IF;

      ---------------------------------------------------------
      -- POPULATE INTERNAL FIELDS
      -- Hardcoded Defaulting From OEXDLINB.pls
      ---------------------------------------------------------

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT LINE INDEX :'||L_INDEX ) ;
      END IF;
      Populate_Internal_Fields
        ( p_line_rec           => p_line_rec
         ,p_index              => l_index
         ,p_header_index       => header_counter
         ,p_process_tax        => p_process_tax
         ,p_process_configurations => p_process_configurations
         ,x_unsupported_feature => l_unsupported_feature
         ,x_return_status      => l_return_status
         );

      oe_debug_pub.add('after Populate_Internal_Fields');
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         p_line_rec.lock_control(l_index) := -99;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Populating calculate price flag

   --PIB
      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
        IF l_debug_level > 0 Then
           oe_debug_pub.add('before set_price_flag');
        END IF;
        oe_bulk_priceorder_pvt.set_price_flag(p_line_rec,l_index,header_counter);
        IF l_debug_level > 0 Then
           oe_debug_pub.add('after set_price_flag');
        END IF;
      END IF;
   --PIB

      ---------------------------------------------------------
      -- START ENTITY VALIDATIONS
      ---------------------------------------------------------

      -- Validate Required Attributes

      IF (p_line_rec.inventory_item_id(l_index) IS NULL) THEN

           fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                      OE_Order_UTIL.Get_Attribute_Name('INVENTORY_ITEM_ID'));
           OE_BULK_MSG_PUB.Add('Y','ERROR');
           p_line_rec.lock_control(l_index) := -99;

           -- To avoid Insert failure, populate not null column.
           -- This record will be deleted later.
           p_line_rec.inventory_item_id(l_index) := -99;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN ERROR 1 ' ) ;
           END IF;

      END IF;
      oe_debug_pub.add('after inventory_item_id');

      IF (p_line_rec.line_type_id(l_index) IS NULL) THEN

         fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
            OE_Order_UTIL.Get_Attribute_Name('LINE_TYPE_ID'));
         OE_BULK_MSG_PUB.Add('Y','ERROR');
         p_line_rec.lock_control(l_index) := -99;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN ERROR 2 ' ) ;
           END IF;

      -- To avoid Insert failure, populate not null column.
      -- This record will be deleted later.

         p_line_rec.line_type_id(l_index) := -99;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN ERROR 3 ' ) ;
           END IF;


      ELSE -- line_type_id is not null

        -- Validate line type for effective dates
        IF NOT Validate_Line_Type(p_line_rec.line_type_id(l_index),
                 p_header_rec.ordered_date(header_counter))
        THEN

          p_line_rec.lock_control(l_index) := -99 ;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
             OE_Order_UTIL.Get_Attribute_Name('LINE_TYPE_ID'));
          OE_BULK_MSG_PUB.Add('Y','ERROR');

        ELSE

          -- Validate that Order/Line Type has valid WF assignment
          -- Bug 2650317 - Do not validate WF assignment if item type,
          -- UOM or order type is null else function may return an
          -- unexpected error.
          IF p_line_rec.item_type_code(l_index) IS NOT NULL
             AND p_line_rec.order_quantity_uom(l_index) IS NOT NULL
             AND p_header_rec.order_type_id(header_counter) IS NOT NULL
             AND NOT OE_BULK_WF_UTIL.Validate_LT_WF_Assignment(
                 p_header_rec.order_type_id(header_counter)
                 ,l_index
                 ,p_line_rec
                 ,l_process_name)
          THEN
             IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'FAILURE IN OE_BULK_WF_UTIL.Validate_LT_WF_Assignment ' ) ;
            END IF;
            p_line_rec.lock_control(l_index) := -99 ;
            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
               OE_Order_UTIL.Get_Attribute_Name('LINE_TYPE_ID'));
            OE_BULK_MSG_PUB.Add('Y','ERROR');
          ELSE
            p_line_rec.wf_process_name(l_index) := l_process_name;
          END IF;

        END IF;

      END IF;


      oe_debug_pub.add('before checking for tax related attributes');
      oe_debug_pub.add(' Process Tax :' || p_process_tax );
  -- Check for Tax related attributes

      IF (p_line_rec.tax_exempt_flag(l_index) = 'E') THEN

           -- Tax exempt reason code is required
           IF (p_line_rec.tax_exempt_reason_code(l_index) IS NULL) THEN
               p_line_rec.lock_control(l_index) := -99;
               fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Tax Exempt Reason');
               OE_BULK_MSG_PUB.Add('Y','ERROR');

	   ELSIF NOT OE_BULK_PROCESS_HEADER.Valid_Tax_Exempt_Reason
                    (p_line_rec.tax_exempt_reason_code(l_index)) THEN

	       p_line_rec.lock_control(l_index) := -99;
               FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                      OE_Order_UTIL.Get_Attribute_Name('TAX_EXEMPT_REASON_CODE'));
               OE_BULK_MSG_PUB.Add('Y','ERROR');

	   END IF;

       END IF;

       IF (p_line_rec.tax_exempt_flag(l_index) = 'R') THEN

          IF (p_line_rec.tax_exempt_number(l_index) IS NOT NULL)
              OR
             (p_line_rec.tax_exempt_reason_code(l_index) IS NOT NULL) THEN
              p_line_rec.lock_control(l_index) := -99;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'IN ERROR 6 ' ) ;
              END IF;
              fnd_message.set_name('ONT','OE_TAX_EXEMPTION_NOT_ALLOWED');
              OE_BULK_MSG_PUB.Add('Y','ERROR');
          END IF;

       END IF;

	oe_debug_pub.add('tax related attributes checking completed;');
-- added for HVOP Tax project
       IF p_process_tax = 'Y' THEN
          OE_Bulk_Process_Line.Load_Cust_Trx_Type_Id(p_line_index   => l_index,
                                                     p_line_rec     => p_line_rec,
                                                     p_header_index => header_counter,
                                                     p_header_rec   => p_header_rec);
       END IF;
       -- Subinventory Validation
       IF p_line_rec.subinventory(l_index) IS NOT NULL THEN
            -- Error messages in Validate_Subinventory
            IF NOT Validate_Subinventory
                    (p_line_rec.subinventory(l_index)
                    ,p_line_rec.inventory_item_id(l_index)
                    ,p_line_rec.ship_from_org_id(l_index)
                    ,p_line_rec.source_type_code(l_index)
                    ,p_line_rec.order_source_id(l_index)
                    )
            THEN
                p_line_rec.lock_control(l_index) := -99;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'SUBINV VALIDATION FAILED' ) ;
                END IF;
            END IF;
       END IF;


       -- Item-Warehouse Validation
       IF nvl(p_line_rec.inventory_item_id(l_index),-99) <> -99 AND
          p_line_rec.ship_from_org_id(l_index)  IS NOT NULL
       THEN

            IF NOT Validate_Item_Warehouse
                    (p_line_rec.inventory_item_id(l_index),
                     p_line_rec.ship_from_org_id(l_index),
                     p_line_rec.item_type_code(l_index),
                     p_line_rec.line_id(l_index),
                     p_line_rec.top_model_line_id(l_index),
                     NULL ,--p_line_rec.source_document_type_id(l_index),
                     'ORDER')
            THEN
                p_line_rec.lock_control(l_index) := -99;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'IN ERROR 7 ' ) ;
                END IF;
                FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ITEM_WHSE');
                OE_BULK_MSG_PUB.add('Y','ERROR');
            END IF;

       END IF;

       -- Shipping Method-Warehouse validation
       IF (p_line_rec.line_category_code(l_index) <> 'RETURN' AND
           p_line_rec.shipping_method_code(l_index) IS NOT NULL AND
           p_line_rec.ship_from_org_id(l_index) IS NOT NULL) THEN

                      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509' THEN
                         SELECT count(*)
                         INTO   l_count
                         FROM   wsh_carrier_services wsh,
                                wsh_org_carrier_services wsh_org
                         WHERE  wsh_org.organization_id      = p_line_rec.ship_from_org_id(l_index)
                           AND  wsh.carrier_service_id       = wsh_org.carrier_service_id
                           AND  wsh.ship_method_code         = p_line_rec.shipping_method_code(l_index)
                           AND  wsh_org.enabled_flag         = 'Y';
                      ELSE

                         SELECT count(*)
                	   INTO	l_count
                           FROM    wsh_carrier_ship_methods
                          WHERE   ship_method_code = p_line_rec.shipping_method_code(l_index)
   	                    AND   organization_id = p_line_rec.ship_from_org_id(l_index);
                     END IF;
	   	--  Valid Shipping Method Code.

	   	IF l_count  = 0 THEN
                   p_line_rec.shipping_method_code(l_index) := NULL;

                   OE_BULK_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPING_METHOD');
                   fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                      OE_Order_UTIL.Get_Attribute_Name('SHIPPING_METHOD_CODE'));
                   OE_BULK_MSG_PUB.Add;
                   OE_BULK_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
                END IF;

       END IF;

/*	        -- checks: Warehouse/Process  combinations  process HVOP
      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
        IF OE_Bulk_Order_PVT.G_PROCESS_INSTALLED_FLAG = 'Y' THEN

	-- first check  if warehouse is NULL, do not supply process attributes  INVCONV - NOT NEEDED NOW

	IF (p_line_rec.ship_from_org_id(l_index)IS NULL) THEN

          IF (p_line_rec.ordered_quantity_uom2(l_index)IS NOT NULL
         -- AND p_line_rec.context(l_index) = FND_API.G_MISS_CHAR
          )
              OR
             (p_line_rec.ordered_quantity2(l_index) IS NOT NULL)
             OR
              (p_line_rec.preferred_grade (l_index) IS NOT NULL) THEN

              p_line_rec.lock_control(l_index) := -99;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'error 1 ' ) ;
              END IF;
              fnd_message.set_name('ONT','OE_BULK_OPM_NOT_PROCESS');
              OE_BULK_MSG_PUB.Add('Y','ERROR');
          END IF;

       END IF;    */



      -- second process check  if cached opm_item_id is NULL OR warehouse is discrete , do not supply process attributes
 /*      IF p_line_rec.inventory_item_id(l_index) IS NOT NULL THEN

        l_inventory_item_id := p_line_rec.inventory_item_id(l_index);
        l_c_index := OE_BULK_CACHE.Load_Item
                       (p_key1 => l_inventory_item_id
                       ,p_key2 => p_line_rec.ship_from_org_id(l_index)
                       );
           IF  ( OE_BULK_CACHE.G_ITEM_TBL(l_c_index).opm_item_id IS NULL
            OR OE_BULK_CACHE.G_ITEM_TBL(l_c_index).process_warehouse_flag <> 'Y' )
           THEN
	     IF (p_line_rec.ordered_quantity_uom2(l_index) IS NOT NULL)
              OR
              (p_line_rec.ordered_quantity2(l_index) IS NOT NULL)
              OR
               (p_line_rec.preferred_grade (l_index) IS NOT NULL) THEN

              p_line_rec.lock_control(l_index) := -99;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'error 2 ' ) ;
              END IF;
              fnd_message.set_name('ONT','OE_BULK_OPM_NOT_PROCESS');
              OE_BULK_MSG_PUB.Add('Y','ERROR');
            END IF;
          END IF; -- OE_BULK_CACHE.G_ITEM_TBL(l_c_index).opm_item_id IS NULL THEN

       END IF; --  p_line_rec.inventory_item_id(p_index) IS NOT NULL THEN

       END IF; -- IF OE_Bulk_Order_PVT.G_PROCESS_INSTALLED_FLAG = 'Y' THEN

     END IF; -- IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN   */






       -- Start decimal qty validation
       IF nvl(p_line_rec.inventory_item_id(l_index),-99) <> -99 THEN

          IF p_line_rec.order_quantity_uom(l_index) is not null THEN

             -- validate ordered quantity
              Validate_Decimal_Quantity
              (p_item_id  => p_line_rec.inventory_item_id(l_index)
              ,p_item_type_code   => p_line_rec.item_type_code(l_index)
              ,p_input_quantity   => p_line_rec.ordered_quantity(l_index)
              ,p_uom_code     => p_line_rec.order_quantity_uom(l_index)
              ,x_return_status  => p_line_rec.lock_control(l_index)
              );

             -- Validate UOM
             IF ( p_line_rec.item_type_code(l_index) = OE_GLOBALS.G_ITEM_MODEL OR
                    p_line_rec.item_type_code(l_index) = OE_GLOBALS.G_ITEM_CLASS OR
                    p_line_rec.item_type_code(l_index) = OE_GLOBALS.G_ITEM_OPTION OR
                    p_line_rec.item_type_code(l_index) = OE_GLOBALS.G_ITEM_KIT OR
                    p_line_rec.item_type_code(l_index) = OE_GLOBALS.G_ITEM_INCLUDED OR
                    p_line_rec.item_type_code(l_index) = OE_GLOBALS.G_ITEM_CONFIG)
             THEN

               BEGIN
                  SELECT primary_uom_code
                  INTO   l_uom
                  FROM   mtl_system_items
                  WHERE  inventory_item_id=p_line_rec.inventory_item_id(l_index)
                  AND organization_id=nvl(p_line_rec.ship_from_org_id(l_index),
                  OE_Bulk_Order_PVT.G_ITEM_ORG);

                  IF l_uom <> p_line_rec.order_quantity_uom(l_index) THEN
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'UOM OTHER THAN PRIMARY UOM IS ENTERED' , 1 ) ;
                   END IF;

                    fnd_message.set_name('ONT','OE_INVALID_ORDER_QUANTITY_UOM');
                    fnd_message.set_token('ITEM',p_line_rec.ordered_item(l_index) );
                    fnd_message.set_token('UOM', l_uom);
                    OE_BULK_MSG_PUB.Add('Y','ERROR');
                    --RAISE FND_API.G_EXC_ERROR;
                  END IF;
               EXCEPTION
                   when no_data_found then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'OEXLLINB , NO_DATA_FOUND IN UOM VALIDATION' , 1 ) ;
            END IF;
                    p_line_rec.lock_control(l_index) := -99;
                    fnd_message.set_name('ONT','OE_INVALID_ORDER_QUANTITY_UOM');
                    fnd_message.set_token('ITEM',p_line_rec.ordered_item(l_index) );
                    fnd_message.set_token('UOM', l_uom);
                    OE_BULK_MSG_PUB.Add('Y','ERROR');
               END;

            ELSE

                 -- Bug 1544265
                 -- For other item types, validate uom using inv_convert api
                 l_ret_status := inv_convert.validate_item_uom
                                     (p_line_rec.order_quantity_uom(l_index)
                                      ,p_line_rec.inventory_item_id(l_index)
                                      ,nvl(p_line_rec.ship_from_org_id(l_index)
                                           ,OE_Bulk_Order_PVT.G_ITEM_ORG )
                                      );
                 IF NOT l_ret_status THEN
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'UOM/ITEM COMBINATION INVALID' , 2 ) ;
                        oe_debug_pub.add(  'UOM :'||P_LINE_REC.ORDER_QUANTITY_UOM ( L_INDEX ) ) ;
                        oe_debug_pub.add(  'ITEM ID :'||P_LINE_REC.INVENTORY_ITEM_ID ( L_INDEX ) ) ;
                    END IF;
                    p_line_rec.lock_control(l_index) := -99;
                    fnd_message.set_name('ONT', 'OE_INVALID_ITEM_UOM');
                    OE_BULK_MSG_PUB.Add('Y','ERROR');
                 END IF;

             END IF; -- uom validation based on item type

           END IF; -- order quantity uom not null

       END IF; -- inventory_item_id is null


       -- Validate if the source_type, item combination is valid
       -- Validate if the source_type, ship_set_id, arrival_set_id is valid
       -- Not needed as BULK does not support externally sourced items
       -- or lines in sets


       -- PJM validation.

       IF PJM_UNIT_EFF.ENABLED = 'Y' THEN

          IF (p_line_rec.project_id(l_index) IS NOT NULL AND
              p_line_rec.ship_from_org_id(l_index) IS NULL)
          THEN
              FND_MESSAGE.SET_NAME('ONT', 'OE_SHIP_FROM_REQD');
              OE_BULK_MSG_PUB.Add('Y','ERROR');
              p_line_rec.lock_control(l_index) := -99;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN ERROR 11 ' ) ;
           END IF;
          END IF;

          IF (p_line_rec.project_id(l_index) IS NOT NULL AND
              p_line_rec.ship_from_org_id(l_index) IS NOT NULL)
          THEN
          --  Validate project/warehouse combination.
              IF pjm_project.val_proj_idtonum(p_line_rec.project_id(l_index),
              p_line_rec.ship_from_org_id(l_index)) IS NULL
              THEN
                  FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_SHIP_FROM_PROJ');
                  OE_BULK_MSG_PUB.Add('Y','ERROR');
                  p_line_rec.lock_control(l_index) := -99;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN ERROR 12 ' ) ;
           END IF;
              END IF;
          END IF;

          IF (p_line_rec.task_id(l_index) IS NOT NULL
          AND p_line_rec.project_id(l_index) IS NULL)  THEN
              FND_MESSAGE.SET_NAME('ONT', 'OE_VAL_PROJECT_REQD');
              OE_BULK_MSG_PUB.Add('Y','ERROR');
              p_line_rec.lock_control(l_index) := -99;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN ERROR 13 ' ) ;
           END IF;

          ELSIF (p_line_rec.task_id(l_index) is NOT NULL
          AND p_line_rec.project_id(l_index) IS NOT NULL) THEN

              IF NOT Validate_task(p_line_rec.project_id(l_index),
                                   p_line_rec.task_id(l_index)) THEN
                  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                       OE_Order_Util.Get_Attribute_Name('task_id'));
                  OE_BULK_MSG_PUB.Add('Y','ERROR');
                  p_line_rec.lock_control(l_index) := -99;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN ERROR 14 ' ) ;
           END IF;

              END IF;

          ELSIF (p_line_rec.task_id(l_index) is  NULL
          AND p_line_rec.project_id(l_index) IS NOT NULL) THEN

              IF Validate_task_reqd(p_line_rec.project_id(l_index),
                 p_line_rec.ship_from_org_id(l_index)) THEN
                  FND_MESSAGE.SET_NAME('ONT', 'OE_VAL_TASK_REQD');
                  OE_BULK_MSG_PUB.Add('Y','ERROR');
                  p_line_rec.lock_control(l_index) := -99;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN ERROR 15 ' ) ;
           END IF;
              END IF;
          END IF;

          IF nvl(p_line_rec.inventory_item_id(l_index),-99) <> -99 AND
             (p_line_rec.ship_from_org_id(l_index) IS NOT NULL) AND
             (p_line_rec.end_item_unit_number(l_index) IS NULL) THEN

              IF PJM_UNIT_EFF.UNIT_EFFECTIVE_ITEM
                (p_line_rec.inventory_item_id(l_index),
                 p_line_rec.ship_from_org_id(l_index)) = 'Y'
              THEN
                  fnd_message.set_name('ONT', 'OE_UEFF_NUMBER_REQD');
                  OE_BULK_MSG_PUB.Add('Y','ERROR');
                  p_line_rec.lock_control(l_index) := -99;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN ERROR 16 ' ) ;
           END IF;
              END IF;
          END IF;
       ELSE -- When project manufacturing is not enabled at the site.

          IF (p_line_rec.project_id(l_index) IS NOT NULL OR
              p_line_rec.task_id(l_index)    IS NOT NULL OR
              p_line_rec.end_item_unit_number(l_index) IS NOT NULL)
          THEN
              fnd_message.set_name('ONT', 'OE_PJM_NOT_INSTALLED');
              OE_BULK_MSG_PUB.Add('Y','ERROR');
              p_line_rec.lock_control(l_index) := -99;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN ERROR 17 ' ) ;
           END IF;
          END IF;

       END IF; --End if PJM_UNIT_EFF.ENABLED


       -- Validate if item, item_identifier_type, inventory_item combination
       -- is valid

       IF p_line_rec.inventory_item_id(l_index) IS NOT NULL THEN

          IF NOT Validate_Item_Fields
              (  p_line_rec.inventory_item_id(l_index)
               , p_line_rec.ordered_item_id(l_index)
               , p_line_rec.item_identifier_type(l_index)
               , p_line_rec.ordered_item(l_index)
               , p_line_rec.sold_to_org_id(l_index)
               , 'ORDER'
               , p_line_rec.item_type_code(l_index)
               , p_line_rec.line_id(l_index)
               , NULL --p_line_rec.top_model_line_id(l_index)
               , NULL --p_line_rec.source_document_type_id(l_index)
               )
          THEN
              p_line_rec.lock_control(l_index) := -99;
              fnd_message.set_name('ONT', 'OE_ITEM_VALIDATION_FAILED');
              OE_BULK_MSG_PUB.Add('Y','ERROR');
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'IN ERROR 18 ' ) ;
              END IF;
          END IF;

	  --Item Orderability
	  --Validate Item Orderability Rules
	  IF  (  NVL( p_line_rec.item_type_code(l_index),OE_GLOBALS.G_ITEM_STANDARD) = OE_GLOBALS.G_ITEM_STANDARD
                OR ( p_line_rec.item_type_code(l_index) =  OE_GLOBALS.G_ITEM_MODEL )
              ) then

            oe_debug_pub.add(' Checking Validate_item_orderability ');
--oe_debug_pub.add(' org id :' || p_line_rec.org_id(l_index));


		 IF NOT OE_ITORD_UTIL.Validate_item_orderability
		      (
			p_line_rec.org_id(l_index)
		      , p_line_rec.line_id(l_index)
		      , p_line_rec.header_id(l_index)
		      , p_line_rec.inventory_item_id(l_index)
		      , p_line_rec.sold_to_org_id(l_index)
		      , p_line_rec.ship_to_org_id(l_index)
		      , p_line_rec.salesrep_id(l_index)
		      , p_line_rec.end_customer_id(l_index)
		      , p_line_rec.invoice_to_org_id(l_index)
		      , p_line_rec.deliver_to_org_id(l_index)
		      )
		  THEN
		      p_line_rec.lock_control(l_index) := -99;
		      fnd_message.set_name('ONT', 'OE_ITORD_VALIDATION_FAILED');
		      fnd_message.set_token('ITEM',OE_ITORD_UTIL.get_item_name(p_line_rec.inventory_item_id(l_index)));
		      fnd_message.set_token('CATEGORY',OE_ITORD_UTIL.get_item_category_name(p_line_rec.inventory_item_id(l_index)));
		      OE_BULK_MSG_PUB.Add('Y','ERROR');
		      IF l_debug_level  > 0 THEN
			  oe_debug_pub.add(  'IN ERROR 19 ' ) ;
		      END IF;
		  END IF;
	 END IF;

       END IF;

       -- User Item Description related validation,
       -- to make sure length not exceed 240 characters for
       -- EXTERNAL orders.
       IF p_line_rec.user_item_description(l_index) IS NOT NULL
          AND p_line_rec.source_type_code(l_index) = 'EXTERNAL'
       THEN

          IF NOT Validate_User_Item_Description
              (  p_line_rec.user_item_description(l_index))
          THEN
              p_line_rec.lock_control(l_index) := -99;
              fnd_message.set_name('ONT', 'ONT_USER_ITEM_DESC_TOO_LONG');
              OE_BULK_MSG_PUB.Add('Y','ERROR');
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'LENGTH OF USER ITEM DESC EXCEEDS LIMIT FOR EXTERNAL ORDERS. ' ) ;
              END IF;
          END IF;

       END IF;


       -- Agreement related validation
       IF p_line_rec.agreement_id(l_index) IS NOT NULL
          AND (NOT OE_GLOBALS.Equal(p_line_rec.agreement_id(l_index),
                    p_header_rec.agreement_id(header_counter))
               OR NOT OE_GLOBALS.Equal(p_line_rec.pricing_date(l_index),
                       p_header_rec.pricing_date(header_counter))
               OR NOT OE_GLOBALS.Equal(p_line_rec.price_list_id(l_index),
                       p_header_rec.price_list_id(header_counter))
               )
       THEN

          -- Error messages are populated in Validate_Agreement

          IF NOT OE_BULK_PROCESS_HEADER.Validate_Agreement
                         (p_line_rec.agreement_id(l_index)
                         ,p_line_rec.pricing_date(l_index)
                         ,p_line_rec.price_list_id(l_index)
                         ,p_line_rec.sold_to_org_id(l_index)
                         )
          THEN

             p_line_rec.lock_control(l_index) := -99;

          END IF;

       END IF; -- If Agreement is NOT NULL

       -- Price List related validations

       IF p_line_rec.price_list_id(l_index) IS NOT NULL
          AND NOT OE_GLOBALS.Equal(p_line_rec.price_list_id(l_index),
                    p_header_rec.price_list_id(header_counter))
       THEN

          -- Error messages are populated in Validate_Price_List

          IF NOT OE_BULK_PROCESS_HEADER.Validate_Price_List
                         (p_line_rec.price_list_id(l_index)
                         ,p_header_rec.transactional_curr_code(header_counter)
                         ,p_line_rec.pricing_date(l_index)
                         ,p_line_rec.calculate_price_flag(l_index)
                         )
          THEN

             p_line_rec.lock_control(l_index) := -99;

          END IF;

       END IF;

       -- Validate Customer , customer contact and Sites
       -- Validate Bill-to for customer
       IF p_line_rec.invoice_to_org_id(l_index) IS NOT NULL
          AND NOT OE_GLOBALS.Equal(p_line_rec.invoice_to_org_id(l_index),
              p_header_rec.invoice_to_org_id(header_counter))
       THEN

           IF NOT OE_BULK_PROCESS_HEADER.Validate_Bill_To
                  (p_line_rec.sold_to_org_id(l_index)
                  ,p_line_rec.invoice_to_org_id(l_index)
                  )
           THEN
             p_line_rec.lock_control(l_index) := -99;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'IN ERROR 22 ' ) ;
             END IF;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                 OE_Order_Util.Get_Attribute_Name('INVOICE_TO_ORG_ID'));
             OE_BULK_MSG_PUB.Add('Y','ERROR');
            END IF;

        END IF; -- Invoice to is not null

       -- Validate ship-to for customer
       IF p_line_rec.ship_to_org_id(l_index) IS NOT NULL
          AND NOT OE_GLOBALS.Equal(p_line_rec.ship_to_org_id(l_index),
              p_header_rec.ship_to_org_id(header_counter))
       THEN

           IF NOT OE_BULK_PROCESS_HEADER.Validate_Ship_To
                  (p_line_rec.sold_to_org_id(l_index)
                  ,p_line_rec.ship_to_org_id(l_index)
                  )
           THEN
             p_line_rec.lock_control(l_index) := -99;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'IN ERROR 22 ' ) ;
             END IF;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                 OE_Order_Util.Get_Attribute_Name('ship_to_org_id'));
             OE_BULK_MSG_PUB.Add('Y','ERROR');
            END IF;

       END IF; -- ship to is not null

       IF p_line_rec.deliver_to_org_id(l_index) IS NOT NULL
          AND NOT OE_GLOBALS.Equal(p_line_rec.deliver_to_org_id(l_index),
              p_header_rec.deliver_to_org_id(header_counter))
       THEN

           IF NOT OE_BULK_PROCESS_HEADER.Validate_Deliver_To
                  (p_line_rec.sold_to_org_id(l_index)
                  ,p_line_rec.deliver_to_org_id(l_index)
                  )
           THEN
             p_line_rec.lock_control(l_index) := -99;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'IN ERROR 22 ' ) ;
             END IF;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                 OE_Order_Util.Get_Attribute_Name('DELIVER_TO_ORG_ID'));
             OE_BULK_MSG_PUB.Add('Y','ERROR');
            END IF;

       END IF; -- deliver to is not null

       -- Validate Various Site Contacts
       -- Cannot put this in above IF, since you may have a site and contact
       -- without a customer.??

       -- Validate Bill to contact
       IF p_line_rec.invoice_to_contact_id(l_index) IS NOT NULL
       THEN

            IF NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_org_id(l_index),
               p_header_rec.invoice_to_org_id(
               header_counter))
               OR
               NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_contact_id(l_index),
               p_header_rec.invoice_to_contact_id(
               header_counter))
            THEN


               IF NOT OE_BULK_PROCESS_HEADER.Validate_Site_Contact(
                  p_line_rec.invoice_to_org_id(l_index),
                  p_line_rec.invoice_to_contact_id(l_index)
                  )
               THEN
                   p_line_rec.lock_control(l_index) := -99;
                  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Entity: Bill To Contact ');
                  OE_BULK_MSG_PUB.Add('Y','ERROR');
               END IF;

            END IF;

       END IF;

       -- Validate Ship to contact
       IF p_line_rec.Ship_to_contact_id(l_index) IS NOT NULL
       THEN

            IF NOT OE_GLOBALS.EQUAL(p_line_rec.Ship_to_org_id(l_index),
               p_header_rec.Ship_to_org_id(
               header_counter)) OR
               NOT OE_GLOBALS.EQUAL(p_line_rec.Ship_to_contact_id(l_index),
               p_header_rec.Ship_to_contact_id(
               header_counter))
            THEN

               IF NOT OE_BULK_PROCESS_HEADER.Validate_Site_Contact(
                  p_line_rec.Ship_to_org_id(l_index),
                  p_line_rec.Ship_to_contact_id(l_index)
                  )
               THEN
                  p_line_rec.lock_control(l_index) := -99;
                  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Entity: SHIP To Contact ');
                  OE_BULK_MSG_PUB.Add('Y','ERROR');
               END IF;

            END IF;

       END IF;

       -- Validate Deliver to contact
       IF p_line_rec.Deliver_to_contact_id(l_index) IS NOT NULL
       THEN

            IF NOT OE_GLOBALS.EQUAL(p_line_rec.Deliver_to_org_id(l_index),
               p_header_rec.Deliver_to_org_id(
               header_counter)) OR
               NOT OE_GLOBALS.EQUAL(p_line_rec.Deliver_to_contact_id(l_index),
               p_header_rec.Deliver_to_contact_id(
               header_counter))
            THEN

               IF NOT OE_BULK_PROCESS_HEADER.Validate_Site_Contact(
                  p_line_rec.Deliver_to_org_id(l_index),
                  p_line_rec.Deliver_to_contact_id(l_index)
                  )
               THEN
                  p_line_rec.lock_control(l_index) := -99;
                  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Entity: DeliverToContact');
                  OE_BULK_MSG_PUB.Add('Y','ERROR');
               END IF;

            END IF;

       END IF;

	--{Bug 5054618
	--End customer changes
       IF p_line_rec.end_Customer_id(l_index) IS NOT NULL
	    AND NOT OE_GLOBALS.Equal(p_line_rec.end_Customer_id(l_index),p_header_rec.end_customer_id(header_counter))THEN
	  IF NOT OE_BULK_PROCESS_HEADER.Validate_End_Customer(p_line_rec.end_customer_id(l_index))  THEN
	     p_line_rec.lock_control(l_index) := -99;
	     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('end_customer_id'));
	    OE_BULK_MSG_PUB.Add('Y','ERROR');
	 END IF;
	 END IF;

	 IF p_line_rec.end_Customer_Contact_id(l_index) IS NOT NULL AND
	      NOT OE_GLOBALS.Equal(p_line_rec.end_Customer_Contact_id(l_index),p_header_rec.end_customer_Contact_id(header_counter)) THEN
	    IF NOT OE_BULK_PROCESS_HEADER.Validate_End_Customer_Contact(p_line_rec.end_customer_contact_id(l_index))  THEN
	       p_line_rec.lock_control(l_index) := -99;
	       fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('end_customer_contact_id'));
	       OE_BULK_MSG_PUB.Add('Y','ERROR');
	    END IF;
	 END IF;


	 IF p_line_rec.end_Customer_site_use_id(l_index) IS NOT NULL AND NOT
	    OE_GLOBALS.Equal(p_line_rec.end_Customer_site_use_id(l_index),p_header_rec.end_customer_site_use_id(header_counter)) THEN
	    IF NOT OE_BULK_PROCESS_HEADER.Validate_End_Customer_site_use(p_line_rec.end_customer_site_use_id(l_index),
									 p_line_rec.end_customer_id(l_index))  THEN
	       p_line_rec.lock_control(l_index) := -99;
	       fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('end_customer_site_use_id'));
	       OE_BULK_MSG_PUB.Add('Y','ERROR');
	    END IF;
	 END IF;

	 IF p_line_rec.IB_owner(l_index) IS NOT NULL AND NOT
	    OE_GLOBALS.Equal(p_line_rec.IB_owner(l_index),p_header_rec.IB_owner(header_counter))THEN
	    IF NOT OE_BULK_PROCESS_HEADER.Validate_IB_Owner(p_line_rec.IB_owner(l_index))  THEN
	       p_line_rec.lock_control(l_index) := -99;
	       fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('IB_owner'));
	       OE_BULK_MSG_PUB.Add('Y','ERROR');
	    END IF;
	 END IF;

     IF p_line_rec.IB_current_location(l_index) IS NOT NULL AND NOT
	OE_GLOBALS.Equal(p_line_rec.IB_current_location(l_index),p_header_rec.IB_current_location(header_counter)) THEN
	IF NOT OE_BULK_PROCESS_HEADER.Validate_IB_current_Location (p_line_rec.IB_current_location(l_index))  THEN
	   p_line_rec.lock_control(l_index) := -99;
	   fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('IB_location'));
	   OE_BULK_MSG_PUB.Add('Y','ERROR');
	END IF;
     END IF;

     IF p_line_rec.IB_Installed_at_location(l_index) IS NOT NULL AND NOT
	OE_GLOBALS.Equal(p_line_rec.IB_Installed_at_location(l_index),p_header_rec.IB_Installed_at_location(header_counter)) THEN
	IF NOT OE_BULK_PROCESS_HEADER.Validate_IB_Inst_loc(p_line_rec.IB_Installed_at_location(l_index))  THEN
	   p_line_rec.lock_control(l_index) := -99;
	   fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name('Installed_at_location'));
	   OE_BULK_MSG_PUB.Add('Y','ERROR');
	END IF;
     END IF;
	--Bug 5054618}

       --PP Revenue Recognition
       --ER 4893057
       --Need to validate whether any order line with items other than
       --service items have the partial period accounting rules attached
       --to them.
       IF p_line_rec.item_type_code(l_index) <> 'SERVICE' THEN
          IF p_line_rec.accounting_rule_id(l_index) IS NOT NULL AND
             p_line_rec.accounting_rule_id(l_index) <> FND_API.G_MISS_NUM THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'GETTING ACCOUNTING RULE TYPE' ) ;
             END IF;
             SELECT type
             INTO l_rule_type
             FROM ra_rules
             WHERE rule_id = p_line_rec.accounting_rule_id(l_index);
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'RULE_TYPE IS :'||L_RULE_TYPE) ;
             END IF;
             IF l_rule_type = 'PP_DR_ALL' OR l_rule_type = 'PP_DR_PP' THEN
                  p_line_rec.lock_control(l_index) := -99 ;
                  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_Attribute_Name('ACCOUNTING_RULE_ID'));
                  OE_BULK_MSG_PUB.Add('Y','ERROR');
             END IF; -- end of accounting rule type
          END IF; -- end of accounting_rule_id not null
       END IF;  -- end of non-service line

       -- Validate Tax Exempt # and reason for this customer and site

       -- --bug7685103 No need to validate tax exemption numbers
       /* IF ((p_line_rec.tax_exempt_flag(l_index) = 'S') AND
--          (p_line_rec.tax_code(l_index) IS NOT NULL) AND
            (p_line_rec.tax_exempt_number(l_index) IS NOT NULL) AND
            (p_line_rec.tax_exempt_reason_code(l_index) IS NOT NULL) AND
            (p_line_rec.invoice_to_org_id(l_index) IS NOT NULL) AND
            (p_line_rec.ship_to_org_id(l_index) IS NOT NULL)) THEN

            BEGIN

-- eBtax changes

              open partyinfo(p_line_rec.invoice_to_org_id(l_index));
              fetch partyinfo into l_bill_to_cust_Acct_id,
                                   l_bill_to_party_id,
                                   l_bill_to_party_site_id,
                                   l_org_id;
              close partyinfo;

              if p_line_rec.ship_to_org_id(l_index) = p_line_rec.invoice_to_org_id(l_index) then
                 l_ship_to_cust_Acct_id    :=  l_bill_to_cust_Acct_id;
                 l_ship_to_party_id        :=  l_bill_to_party_id;
                 l_ship_to_party_site_id   :=  l_bill_to_party_site_id ;
              else
                 open partyinfo(p_line_rec.ship_to_org_id(l_index));
                 fetch partyinfo into l_ship_to_cust_Acct_id,
                                   l_ship_to_party_id,
                                   l_ship_to_party_site_id,
                                   l_org_id;
                 close partyinfo;
              end if;

		if l_debug_level>0 then
			oe_debug_pub.add('tax_exempt_number '|| p_line_rec.tax_exempt_number(l_index));
			oe_debug_pub.add('reason code'||p_line_rec.tax_exempt_reason_code(l_index));
			oe_debug_pub.add('ship to org_id'||p_line_rec.ship_to_org_id(l_index));
			oe_debug_pub.add('invoice to org_id'||p_line_rec.invoice_to_org_id(l_index));
			oe_debug_pub.add('l_shiop to party site id '||l_ship_to_party_site_id);
			oe_debug_pub.add('l_bill_to_party site_id '||l_bill_to_party_site_id);
			oe_debug_pub.add('l_org_id '||l_org_id);
			oe_debug_pub.add('l_bill to party id'||l_bill_to_party_id);
			oe_debug_pub.add('request_date'||p_line_rec.request_date(l_index));
		end if;
              SELECT 'VALID'
                INTO l_dummy
                FROM ZX_EXEMPTIONS_V
               WHERE EXEMPT_CERTIFICATE_NUMBER  = p_line_rec.tax_exempt_number(l_index)
                 AND EXEMPT_REASON_CODE = p_line_rec.tax_exempt_reason_code(l_index)
                 AND nvl(site_use_id,nvl(p_line_rec.ship_to_org_id(l_index),p_line_rec.invoice_to_org_id(l_index))) =
                           nvl(p_line_rec.ship_to_org_id(l_index),p_line_rec.invoice_to_org_id(l_index))
                 AND nvl(cust_account_id, l_bill_to_cust_acct_id) = l_bill_to_cust_acct_id
                 AND nvl(PARTY_SITE_ID,nvl(l_ship_to_party_site_id, l_bill_to_party_site_id))=
                            nvl(l_ship_to_party_site_id, l_bill_to_party_site_id)
                and  org_id = l_org_id
                and  party_id = l_bill_to_party_id
                 AND EXEMPTION_STATUS_CODE = 'PRIMARY'
                 AND TRUNC(NVL(p_line_rec.request_date(l_index),sysdate))
                      BETWEEN TRUNC(EFFECTIVE_FROM)
                           AND TRUNC(NVL(EFFECTIVE_TO,NVL(p_line_rec.request_date(l_index),sysdate)))
                 AND ROWNUM = 1;



               SELECT 'VALID'
               INTO l_dummy
               FROM TAX_EXEMPTIONS_V
               WHERE TAX_EXEMPT_NUMBER = p_line_rec.tax_exempt_number(l_index)
               AND TAX_EXEMPT_REASON_CODE=p_line_rec.tax_exempt_reason_code(l_index)
               AND SHIP_TO_SITE_USE_ID = nvl(p_line_rec.ship_to_org_id(l_index),
                                   p_line_rec.invoice_to_org_id(l_index))
               AND BILL_TO_CUSTOMER_ID = p_line_rec.sold_to_org_id(l_index)
               AND STATUS_CODE = 'PRIMARY'
               AND TAX_CODE = p_line_rec.tax_code(l_index)
               AND TRUNC(NVL(p_line_rec.request_date(l_index),sysdate))
               BETWEEN TRUNC(START_DATE)
               AND TRUNC(NVL(END_DATE,NVL(p_line_rec.request_date(l_index),sysdate)))
               AND ROWNUM = 1;


            EXCEPTION

               WHEN NO_DATA_FOUND THEN
                    p_line_rec.lock_control(l_index) := -99;
                  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Entity: Tax Exemptions');
                  OE_BULK_MSG_PUB.Add('Y','ERROR');


            END;
       END IF;
*/  --bug7685103 No need to validate the tax exemption number irrespective of tax handling


       -- Validating Tax Information
       IF p_line_rec.tax_code(l_index) IS NOT NULL AND
          p_line_rec.tax_date(l_index) IS NOT NULL
       THEN
            BEGIN
-- EBTax Changes
/*
               IF oe_code_control.code_release_level >= '110510' THEN

                 l_AR_Sys_Param_Rec := OE_Sys_Parameters_Pvt.Get_AR_Sys_Params(OE_GLOBALS.G_ORG_ID);
                 l_sob_id := l_AR_Sys_Param_Rec.set_of_books_id;

                 SELECT 'VALID'
                 INTO   l_dummy
                 FROM   AR_VAT_TAX V
                 WHERE  V.TAX_CODE = p_line_rec.tax_code(l_index)
                 AND V.SET_OF_BOOKS_ID = l_sob_id
                 AND NVL(V.ENABLED_FLAG,'Y')='Y'
                 AND NVL(V.TAX_CLASS,'O')='O'
                 AND NVL(V.DISPLAYED_FLAG,'Y')='Y'
                 AND TRUNC(p_line_rec.tax_date(l_index))
                 BETWEEN TRUNC(V.START_DATE) AND
                 TRUNC(NVL(V.END_DATE, p_line_rec.tax_date(l_index)))
                 AND ROWNUM = 1;

               ELSE

                 SELECT 'VALID'
                 INTO   l_dummy
                 FROM   AR_VAT_TAX V,
                        AR_SYSTEM_PARAMETERS P
                 WHERE  V.TAX_CODE = p_line_rec.tax_code(l_index)
                 AND V.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
                 AND NVL(V.ENABLED_FLAG,'Y')='Y'
                 AND NVL(V.TAX_CLASS,'O')='O'
                 AND NVL(V.DISPLAYED_FLAG,'Y')='Y'
                 AND TRUNC(p_line_rec.tax_date(l_index))
                 BETWEEN TRUNC(V.START_DATE) AND
                 TRUNC(NVL(V.END_DATE, p_line_rec.tax_date(l_index)))
                 AND ROWNUM = 1;

               END IF;

*/
              SELECT 'VALID'
                INTO l_dummy
                FROM ZX_OUTPUT_CLASSIFICATIONS_V
               WHERE LOOKUP_CODE = p_line_rec.tax_code(l_index)
                -- AND LOOKUP_TYPE = 'ZX_OUTPUT_CLASSIFICATIONS'
                 AND ENABLED_FLAG ='Y'
                 AND ORG_ID IN (p_line_rec.org_id(l_index), -99)
                 AND TRUNC(p_line_rec.tax_date(l_index)) BETWEEN
	                TRUNC(START_DATE_ACTIVE) AND
	                TRUNC(NVL(END_DATE_ACTIVE, p_line_rec.tax_date(l_index)))
                 AND ROWNUM = 1;
            EXCEPTION
                 WHEN OTHERS THEN
                     p_line_rec.lock_control(l_index) := -99;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN ERROR 29 ' ) ;
           END IF;
                  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Entity: Tax Code');
                  OE_BULK_MSG_PUB.Add('Y','ERROR');
            END; -- BEGIN
       END IF;


       -- Validate ordered quantity for OTA lines. OTA Lines are
       -- identified by item_type_code of training. The ordered
       -- quantity cannot be greater than 1 for OTA lines.

       l_is_ota_line := OE_OTA_UTIL.Is_OTA_Line
                            (p_line_rec.order_quantity_uom(l_index));

       IF (l_is_ota_line)
          AND p_line_rec.ordered_quantity(l_index) > 1 THEN

            p_line_rec.lock_control(l_index) := -99;
            FND_Message.Set_Name('ONT', 'OE_OTA_INVALID_QTY');
            OE_BULK_MSG_PUB.Add('Y','ERROR');

       END IF;

       -- issue a warning message if the PO number
       -- is being referenced by another order

       IF p_line_rec.cust_po_number(l_index) IS NOT NULL
         AND p_line_rec.sold_to_org_id(l_index) IS NOT NULL
       THEN
             IF OE_Validate_Header.Is_Duplicate_PO_Number
                (p_line_rec.cust_po_number(l_index)
                ,p_line_rec.sold_to_org_id(l_index)
                ,p_line_rec.header_id(l_index) )
             THEN
                 FND_MESSAGE.SET_NAME('ONT','OE_VAL_DUP_PO_NUMBER');
                 OE_BULK_MSG_PUB.Add('Y','ERROR');
             END IF;
       END IF;
       IF p_line_rec.service_end_date(l_index) IS NOT NULL
         AND p_line_rec.service_start_date(l_index) IS NOT NULL
       THEN
             IF p_line_rec.service_start_date(l_index) >=
                p_line_rec.service_end_date(l_index)
             THEN
                 fnd_message.set_name('ONT','OE_SERV_END_DATE');
                 OE_BULK_MSG_PUB.Add('Y','ERROR');
                 p_line_rec.lock_control(l_index) := -99;
             END IF;
       END IF;

       -- BEGIN: Validate Desc Flex

       IF p_validate_desc_flex = 'Y' THEN

       IF OE_Bulk_Order_PVT.G_OE_LINE_ATTRIBUTES = 'Y' THEN
          IF NOT OE_VALIDATE.Line_Desc_Flex
          (p_context            => p_line_rec.context(l_index)
          ,p_attribute1         => p_line_rec.attribute1(l_index)
          ,p_attribute2         => p_line_rec.attribute2(l_index)
          ,p_attribute3         => p_line_rec.attribute3(l_index)
          ,p_attribute4         => p_line_rec.attribute4(l_index)
          ,p_attribute5         => p_line_rec.attribute5(l_index)
          ,p_attribute6         => p_line_rec.attribute6(l_index)
          ,p_attribute7         => p_line_rec.attribute7(l_index)
          ,p_attribute8         => p_line_rec.attribute8(l_index)
          ,p_attribute9         => p_line_rec.attribute9(l_index)
          ,p_attribute10        => p_line_rec.attribute10(l_index)
          ,p_attribute11        => p_line_rec.attribute11(l_index)
          ,p_attribute12        => p_line_rec.attribute12(l_index)
          ,p_attribute13        => p_line_rec.attribute13(l_index)
          ,p_attribute14        => p_line_rec.attribute14(l_index)
          ,p_attribute15        => p_line_rec.attribute15(l_index)
          ,p_attribute16        => p_line_rec.attribute16(l_index)  -- for bug 2184255
          ,p_attribute17        => p_line_rec.attribute17(l_index)
          ,p_attribute18        => p_line_rec.attribute18(l_index)
          ,p_attribute19        => p_line_rec.attribute19(l_index)
          ,p_attribute20        => p_line_rec.attribute20(l_index))
         THEN
             p_line_rec.lock_control(l_index) := -99;
             FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
             'Entity:Flexfield:Line_Desc_Flex');
             OE_BULK_MSG_PUB.Add('Y', 'ERROR');

	   ELSE -- if the flex validation is successfull
	     -- For bug 2511313
	     IF p_line_rec.context(l_index) IS NULL
	       OR p_line_rec.context(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.context(l_index)    := oe_validate.g_context;
	     END IF;

	     IF p_line_rec.attribute1(l_index) IS NULL
	       OR p_line_rec.attribute1(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute1(l_index) := oe_validate.g_attribute1;
	     END IF;

	     IF p_line_rec.attribute2(l_index) IS NULL
	       OR p_line_rec.attribute2(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute2(l_index) := oe_validate.g_attribute2;
	     END IF;

	     IF p_line_rec.attribute3(l_index) IS NULL
	       OR p_line_rec.attribute3(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute3(l_index) := oe_validate.g_attribute3;
	     END IF;

	     IF p_line_rec.attribute4(l_index) IS NULL
	       OR p_line_rec.attribute4(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute4(l_index) := oe_validate.g_attribute4;
	     END IF;

	     IF p_line_rec.attribute5(l_index) IS NULL
	       OR p_line_rec.attribute5(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute5(l_index) := oe_validate.g_attribute5;
	     END IF;

	     IF p_line_rec.attribute6(l_index) IS NULL
	       OR p_line_rec.attribute6(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute6(l_index) := oe_validate.g_attribute6;
	     END IF;

	     IF p_line_rec.attribute7(l_index) IS NULL
	       OR p_line_rec.attribute7(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute7(l_index) := oe_validate.g_attribute7;
	     END IF;

	     IF p_line_rec.attribute8(l_index) IS NULL
	       OR p_line_rec.attribute8(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute8(l_index) := oe_validate.g_attribute8;
	     END IF;

	     IF p_line_rec.attribute9(l_index) IS NULL
	       OR p_line_rec.attribute9(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute9(l_index) := oe_validate.g_attribute9;
	     END IF;

	     IF p_line_rec.attribute10(l_index) IS NULL
	       OR p_line_rec.attribute10(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute10(l_index) := Oe_validate.G_attribute10;
	     End IF;

	     IF p_line_rec.attribute11(l_index) IS NULL
	       OR p_line_rec.attribute11(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute11(l_index) := oe_validate.g_attribute11;
	     END IF;

	     IF p_line_rec.attribute12(l_index) IS NULL
	       OR p_line_rec.attribute12(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute12(l_index) := oe_validate.g_attribute12;
	     END IF;

	     IF p_line_rec.attribute13(l_index) IS NULL
	       OR p_line_rec.attribute13(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute13(l_index) := oe_validate.g_attribute13;
	     END IF;

	     IF p_line_rec.attribute14(l_index) IS NULL
	       OR p_line_rec.attribute14(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute14(l_index) := oe_validate.g_attribute14;
	     END IF;

	     IF p_line_rec.attribute15(l_index) IS NULL
	       OR p_line_rec.attribute15(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute15(l_index) := oe_validate.g_attribute15;
	     END IF;

	     IF p_line_rec.attribute16(l_index) IS NULL
	       OR p_line_rec.attribute16(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute16(l_index) := oe_validate.g_attribute16;
	     END IF;

	     IF p_line_rec.attribute17(l_index) IS NULL
	       OR p_line_rec.attribute17(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute17(l_index) := oe_validate.g_attribute17;
	     END IF;

	     IF p_line_rec.attribute18(l_index) IS NULL
	       OR p_line_rec.attribute18(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute18(l_index) := oe_validate.g_attribute18;
	     END IF;

	     IF p_line_rec.attribute19(l_index) IS NULL
	       OR p_line_rec.attribute19(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute19(l_index) := oe_validate.g_attribute19;
	     END IF;

	     IF p_line_rec.attribute20(l_index) IS NULL
	       OR p_line_rec.attribute20(l_index) = FND_API.G_MISS_CHAR THEN
		p_line_rec.attribute20(l_index) := oe_validate.g_attribute20;
	     END IF;
	    -- end of assignments, bug 2511313

         END IF;
       END IF;

       IF OE_Bulk_Order_PVT.G_OE_LINE_INDUSTRY_ATTRIBUTE = 'Y' THEN
           IF NOT OE_VALIDATE.I_Line_Desc_Flex
           (p_context            => p_line_rec.Industry_context(l_index)
            ,p_attribute1         => p_line_rec.Industry_attribute1(l_index)
            ,p_attribute2         => p_line_rec.Industry_attribute2(l_index)
            ,p_attribute3         => p_line_rec.Industry_attribute3(l_index)
            ,p_attribute4         => p_line_rec.Industry_attribute4(l_index)
            ,p_attribute5         => p_line_rec.Industry_attribute5(l_index)
            ,p_attribute6         => p_line_rec.Industry_attribute6(l_index)
            ,p_attribute7         => p_line_rec.Industry_attribute7(l_index)
            ,p_attribute8         => p_line_rec.Industry_attribute8(l_index)
            ,p_attribute9         => p_line_rec.Industry_attribute9(l_index)
            ,p_attribute10        => p_line_rec.Industry_attribute10(l_index)
            ,p_attribute11        => p_line_rec.Industry_attribute11(l_index)
            ,p_attribute12        => p_line_rec.Industry_attribute12(l_index)
            ,p_attribute13        => p_line_rec.Industry_attribute13(l_index)
            ,p_attribute14        => p_line_rec.Industry_attribute14(l_index)
            ,p_attribute15        => p_line_rec.Industry_attribute15(l_index)
            ,p_attribute16         => p_line_rec.Industry_attribute16(l_index)
            ,p_attribute17         => p_line_rec.Industry_attribute17(l_index)
            ,p_attribute18         => p_line_rec.Industry_attribute18(l_index)
            ,p_attribute19         => p_line_rec.Industry_attribute19(l_index)
            ,p_attribute20         => p_line_rec.Industry_attribute20(l_index)
            ,p_attribute21         => p_line_rec.Industry_attribute21(l_index)
            ,p_attribute22         => p_line_rec.Industry_attribute22(l_index)
            ,p_attribute23         => p_line_rec.Industry_attribute23(l_index)
            ,p_attribute24         => p_line_rec.Industry_attribute24(l_index)
            ,p_attribute25        => p_line_rec.Industry_attribute25(l_index)
            ,p_attribute26        => p_line_rec.Industry_attribute26(l_index)
            ,p_attribute27        => p_line_rec.Industry_attribute27(l_index)
            ,p_attribute28        => p_line_rec.Industry_attribute28(l_index)
            ,p_attribute29        => p_line_rec.Industry_attribute29(l_index)
            ,p_attribute30        => p_line_rec.Industry_attribute30(l_index))
          THEN
             p_line_rec.lock_control(l_index) := -99;
             FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
             'Entity:Flexfield:Industry Line_Desc_Flex');
             OE_BULK_MSG_PUB.Add('Y', 'ERROR');

	    ELSE -- for bug 2511313

	      IF p_line_rec.industry_context(l_index) IS NULL
		OR p_line_rec.industry_context(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_context(l_index) := oe_validate.g_context;
	      END IF;

	      IF p_line_rec.industry_attribute1(l_index) IS NULL
		OR p_line_rec.industry_attribute1(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute1(l_index) := oe_validate.g_attribute1;
	      END IF;

	      IF p_line_rec.industry_attribute2(l_index) IS NULL
		OR p_line_rec.industry_attribute2(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute2(l_index) := oe_validate.g_attribute2;
	      END IF;

	      IF p_line_rec.industry_attribute3(l_index) IS NULL
		OR p_line_rec.industry_attribute3(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute3(l_index) := oe_validate.g_attribute3;
	      END IF;

	      IF p_line_rec.industry_attribute4(l_index) IS NULL
		OR p_line_rec.industry_attribute4(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute4(l_index) := oe_validate.g_attribute4;
	      END IF;

	      IF p_line_rec.industry_attribute5(l_index) IS NULL
		OR p_line_rec.industry_attribute5(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute5(l_index) := oe_validate.g_attribute5;
	      END IF;

	      IF p_line_rec.industry_attribute6(l_index) IS NULL
		OR p_line_rec.industry_attribute6(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute6(l_index) := oe_validate.g_attribute6;
	      END IF;

	      IF p_line_rec.industry_attribute7(l_index) IS NULL
		OR p_line_rec.industry_attribute7(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute7(l_index) := oe_validate.g_attribute7;
	      END IF;

	      IF p_line_rec.industry_attribute8(l_index) IS NULL
		OR p_line_rec.industry_attribute8(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute8(l_index) := oe_validate.g_attribute8;
	      END IF;

	      IF p_line_rec.industry_attribute9(l_index) IS NULL
		OR p_line_rec.industry_attribute9(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute9(l_index) := oe_validate.g_attribute9;
	      END IF;

	      IF p_line_rec.industry_attribute10(l_index) IS NULL
		OR p_line_rec.industry_attribute10(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute10(l_index) := oe_validate.g_attribute10;
	      END IF;

	      IF p_line_rec.industry_attribute11(l_index) IS NULL
		OR p_line_rec.industry_attribute11(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute11(l_index) := oe_validate.g_attribute11;
	      END IF;

	      IF p_line_rec.industry_attribute12(l_index) IS NULL
		OR p_line_rec.industry_attribute12(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute12(l_index) := oe_validate.g_attribute12;
	      END IF;

	      IF p_line_rec.industry_attribute13(l_index) IS NULL
		OR p_line_rec.industry_attribute13(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute13(l_index) := oe_validate.g_attribute13;
	      END IF;

	      IF p_line_rec.industry_attribute14(l_index) IS NULL
		OR p_line_rec.industry_attribute14(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute14(l_index) := oe_validate.g_attribute14;
	      END IF;

	      IF p_line_rec.industry_attribute15(l_index) IS NULL
		OR p_line_rec.industry_attribute15(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute15(l_index) := oe_validate.g_attribute15;
	      END IF;

	      IF p_line_rec.industry_attribute16(l_index) IS NULL
		OR p_line_rec.industry_attribute16(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute16(l_index) := oe_validate.g_attribute16;
	      END IF;

	      IF p_line_rec.industry_attribute17(l_index) IS NULL
		OR p_line_rec.industry_attribute17(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute17(l_index) := oe_validate.g_attribute17;
	      END IF;

	      IF p_line_rec.industry_attribute18(l_index) IS NULL
		OR p_line_rec.industry_attribute18(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute18(l_index) := oe_validate.g_attribute18;
	      END IF;

	      IF p_line_rec.industry_attribute19(l_index) IS NULL
		OR p_line_rec.industry_attribute19(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute19(l_index) := oe_validate.g_attribute19;
	      END IF;

	      IF p_line_rec.industry_attribute20(l_index) IS NULL
		OR p_line_rec.industry_attribute20(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute20(l_index) := oe_validate.g_attribute20;
	      END IF;

	      IF p_line_rec.industry_attribute21(l_index) IS NULL
		OR p_line_rec.industry_attribute21(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute21(l_index) := oe_validate.g_attribute21;
	      END IF;

	      IF p_line_rec.industry_attribute22(l_index) IS NULL
		OR p_line_rec.industry_attribute22(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute22(l_index) := oe_validate.g_attribute22;
	      END IF;

	      IF p_line_rec.industry_attribute23(l_index) IS NULL
		OR p_line_rec.industry_attribute23(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute23(l_index) := oe_validate.g_attribute23;
	      END IF;

	      IF p_line_rec.industry_attribute24(l_index) IS NULL
		OR p_line_rec.industry_attribute24(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute24(l_index) := oe_validate.g_attribute24;
	      END IF;

	      IF p_line_rec.industry_attribute25(l_index) IS NULL
		OR p_line_rec.industry_attribute25(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute25(l_index) := oe_validate.g_attribute25;
	      END IF;

	      IF p_line_rec.industry_attribute26(l_index) IS NULL
		OR p_line_rec.industry_attribute26(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute26(l_index) := oe_validate.g_attribute26;
	      END IF;

	      IF p_line_rec.industry_attribute27(l_index) IS NULL
		OR p_line_rec.industry_attribute27(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute27(l_index) := oe_validate.g_attribute27;
	      END IF;

	      IF p_line_rec.industry_attribute28(l_index) IS NULL
		OR p_line_rec.industry_attribute28(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute28(l_index) := oe_validate.g_attribute28;
	      END IF;

	      IF p_line_rec.industry_attribute29(l_index) IS NULL
		OR p_line_rec.industry_attribute29(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute29(l_index) := oe_validate.g_attribute29;
	      END IF;

	      IF p_line_rec.industry_attribute30(l_index) IS NULL
		OR p_line_rec.industry_attribute30(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.industry_attribute30(l_index) := oe_validate.g_attribute30;
	      END IF;

	      -- end of bug 2511313
          END IF;

       END IF;

       IF OE_Bulk_Order_PVT.G_OE_LINE_TP_ATTRIBUTES = 'Y' THEN
           IF NOT OE_VALIDATE.TP_Line_Desc_Flex
            (p_context            => p_line_rec.tp_context(l_index)
            ,p_attribute1         => p_line_rec.tp_attribute1(l_index)
            ,p_attribute2         => p_line_rec.tp_attribute2(l_index)
            ,p_attribute3         => p_line_rec.tp_attribute3(l_index)
            ,p_attribute4         => p_line_rec.tp_attribute4(l_index)
            ,p_attribute5         => p_line_rec.tp_attribute5(l_index)
            ,p_attribute6         => p_line_rec.tp_attribute6(l_index)
            ,p_attribute7         => p_line_rec.tp_attribute7(l_index)
            ,p_attribute8         => p_line_rec.tp_attribute8(l_index)
            ,p_attribute9         => p_line_rec.tp_attribute9(l_index)
            ,p_attribute10        => p_line_rec.tp_attribute10(l_index)
            ,p_attribute11        => p_line_rec.tp_attribute11(l_index)
            ,p_attribute12        => p_line_rec.tp_attribute12(l_index)
            ,p_attribute13        => p_line_rec.tp_attribute13(l_index)
            ,p_attribute14        => p_line_rec.tp_attribute14(l_index)
            ,p_attribute15        => p_line_rec.tp_attribute15(l_index))
          THEN
             p_line_rec.lock_control(l_index) := -99;
             FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
             'Entity:Flexfield:TP Line_Desc_Flex');
             OE_BULK_MSG_PUB.Add('Y', 'ERROR');

	    ELSE -- if the flex validation is successfull
	      -- For bug 2511313
	      IF p_line_rec.tp_context(l_index) IS NULL
		OR p_line_rec.tp_context(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_context(l_index)    := oe_validate.g_context;
	      END IF;

	      IF p_line_rec.tp_attribute1(l_index) IS NULL
		OR p_line_rec.tp_attribute1(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute1(l_index) := oe_validate.g_attribute1;
	      END IF;

	      IF p_line_rec.tp_attribute2(l_index) IS NULL
		OR p_line_rec.tp_attribute2(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute2(l_index) := oe_validate.g_attribute2;
	      END IF;

	      IF p_line_rec.tp_attribute3(l_index) IS NULL
		OR p_line_rec.tp_attribute3(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute3(l_index) := oe_validate.g_attribute3;
	      END IF;

	      IF p_line_rec.tp_attribute4(l_index) IS NULL
		OR p_line_rec.tp_attribute4(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute4(l_index) := oe_validate.g_attribute4;
	      END IF;

	      IF p_line_rec.tp_attribute5(l_index) IS NULL
		OR p_line_rec.tp_attribute5(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute5(l_index) := oe_validate.g_attribute5;
	      END IF;

	      IF p_line_rec.tp_attribute6(l_index) IS NULL
		OR p_line_rec.tp_attribute6(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute6(l_index) := oe_validate.g_attribute6;
	      END IF;

	      IF p_line_rec.tp_attribute7(l_index) IS NULL
		OR p_line_rec.tp_attribute7(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute7(l_index) := oe_validate.g_attribute7;
	      END IF;

	      IF p_line_rec.tp_attribute8(l_index) IS NULL
		OR p_line_rec.tp_attribute8(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute8(l_index) := oe_validate.g_attribute8;
	      END IF;

	      IF p_line_rec.tp_attribute9(l_index) IS NULL
		OR p_line_rec.tp_attribute9(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute9(l_index) := oe_validate.g_attribute9;
	      END IF;

	      IF p_line_rec.tp_attribute10(l_index) IS NULL
		OR p_line_rec.tp_attribute10(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute10(l_index) := Oe_validate.G_attribute10;
	      End IF;

	      IF p_line_rec.tp_attribute11(l_index) IS NULL
		OR p_line_rec.tp_attribute11(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute11(l_index) := oe_validate.g_attribute11;
	      END IF;

	      IF p_line_rec.tp_attribute12(l_index) IS NULL
		OR p_line_rec.tp_attribute12(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute12(l_index) := oe_validate.g_attribute12;
	      END IF;

	      IF p_line_rec.tp_attribute13(l_index) IS NULL
		OR p_line_rec.tp_attribute13(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute13(l_index) := oe_validate.g_attribute13;
	      END IF;

	      IF p_line_rec.tp_attribute14(l_index) IS NULL
		OR p_line_rec.tp_attribute14(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute14(l_index) := oe_validate.g_attribute14;
	      END IF;

	      IF p_line_rec.tp_attribute15(l_index) IS NULL
		OR p_line_rec.tp_attribute15(l_index) = FND_API.G_MISS_CHAR THEN
		 p_line_rec.tp_attribute15(l_index) := oe_validate.g_attribute15;
	      END IF;
	    -- end of assignments, bug 2511313

          END IF;

       END IF;

       END IF; --End if p_validate_desc_flex is 'Y'

       -- END: Desc Flex Validations


       -- Calculate Price Validations from OEXVIMSB.pls

       IF p_line_rec.calculate_price_flag(l_index) = 'N' THEN

          IF (p_line_rec.unit_list_price(l_index) IS NULL
               OR p_line_rec.unit_selling_price(l_index) IS NULL)
          THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LIST PRICE OR SELLING PRICE IS NULL... ' ) ;
            END IF;
            p_line_rec.lock_control(l_index) := -99;
            FND_MESSAGE.SET_NAME('ONT','OE_OI_PRICE');
            OE_BULK_MSG_PUB.Add;
          ELSIF p_line_rec.pricing_quantity(l_index) IS NULL
          THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'PRICING QUANTITY IS NULL...RESETTING' ) ;
            END IF;
            p_line_rec.pricing_quantity(l_index) :=
                     p_line_rec.ordered_quantity(l_index);
            p_line_rec.pricing_quantity_uom(l_index) :=
                     p_line_rec.order_quantity_uom(l_index);
          END IF;

       ELSE

          OE_BULK_ORDER_PVT.G_PRICING_NEEDED := 'Y';

       END IF;

       ---------------------------------------------------------------
       -- Add a 100% default sales credit record for this salesperson
       -- if different from salesperson on header
       ---------------------------------------------------------------
 oe_debug_pub.add(' salesrep_id ');

       IF p_line_rec.salesrep_id(l_index) IS NOT NULL AND
          p_header_rec.salesrep_id(header_counter) IS NOT NULL THEN

           --If salesrep on line is different than salesrep on header
           IF p_line_rec.salesrep_id(l_index) <>
              p_header_rec.salesrep_id(header_counter) THEN

             x_line_scredit_rec.header_id.extend(1);
             x_line_scredit_rec.line_id.extend(1);
             x_line_scredit_rec.salesrep_id.extend(1);
             x_line_scredit_rec.sales_credit_type_id.extend(1);

             l_c_index := OE_Bulk_Cache.Load_Salesrep
                             (p_key => p_line_rec.salesrep_id(l_index));

             x_line_scredit_rec.header_id(l_scredit_index)
                     := p_line_rec.header_id(l_index);
             x_line_scredit_rec.line_id(l_scredit_index)
                     := p_line_rec.line_id(l_index);
             x_line_scredit_rec.salesrep_id(l_scredit_index)
                     := p_line_rec.salesrep_id(l_index);
             x_line_scredit_rec.sales_credit_type_id(l_scredit_index)
                     := OE_Bulk_Cache.G_SALESREP_TBL(l_c_index).sales_credit_type_id;

             l_scredit_index := l_scredit_index + 1;

           END IF;

       END IF;

       ---------------------------------------------------------------
       -- Evaluate Holds For the line
       ---------------------------------------------------------------

       IF NOT (p_line_rec.lock_control(l_index) = -99 ) THEN
           -- Check for holds
           /*ER#7479609 start
           OE_Bulk_Holds_PVT.Evaluate_Holds(
           p_header_id          => p_line_rec.header_id(l_index),
           p_line_id            => p_line_rec.line_id(l_index),
           p_line_number        => p_line_rec.line_number(l_index),
           p_sold_to_org_id     => p_line_rec.sold_to_org_id(l_index),
           p_inventory_item_id  => p_line_rec.inventory_item_id(l_index),
           p_ship_from_org_id   => p_line_rec.ship_from_org_id(l_index),
           p_invoice_to_org_id  => p_line_rec.invoice_to_org_id(l_index),
           p_ship_to_org_id     => p_line_rec.ship_to_org_id(l_index),
           p_top_model_line_id  => p_line_rec.top_model_line_id(l_index),
           p_ship_set_name      => NULL,
           p_arrival_set_name   => NULL,
           p_on_generic_hold    => l_on_generic_hold,
           p_on_booking_hold    => l_on_booking_hold,
           p_on_scheduling_hold => l_on_scheduling_hold
           );
           ER#7479609 end*/

            --ER#7479609 start
            --7671422  l_header_rec_for_hold.order_type_id := p_header_rec.order_type_id(l_index);
            l_header_rec_for_hold.order_type_id := p_header_rec.order_type_id(header_counter);  --7671422
            l_line_rec_for_hold.header_id := p_line_rec.header_id(l_index);
            l_line_rec_for_hold.line_id := p_line_rec.line_id(l_index);
            l_line_rec_for_hold.line_number := p_line_rec.line_number(l_index);
            l_line_rec_for_hold.sold_to_org_id := p_line_rec.sold_to_org_id(l_index);
            l_line_rec_for_hold.inventory_item_id := p_line_rec.inventory_item_id(l_index);
            l_line_rec_for_hold.ship_from_org_id := p_line_rec.ship_from_org_id(l_index);
            l_line_rec_for_hold.invoice_to_org_id := p_line_rec.invoice_to_org_id(l_index);
            l_line_rec_for_hold.ship_to_org_id := p_line_rec.ship_to_org_id(l_index);
            l_line_rec_for_hold.top_model_line_id := p_line_rec.top_model_line_id(l_index);
            l_line_rec_for_hold.price_list_id := p_line_rec.price_list_id(l_index);
            l_line_rec_for_hold.creation_date := to_char(sysdate,'DD-MON-RRRR');
            l_line_rec_for_hold.shipping_method_code := p_line_rec.shipping_method_code(l_index);
            l_line_rec_for_hold.deliver_to_org_id := p_line_rec.deliver_to_org_id(l_index);
            l_line_rec_for_hold.source_type_code := p_line_rec.source_type_code(l_index);
            l_line_rec_for_hold.line_type_id := p_line_rec.line_type_id(l_index);
            l_line_rec_for_hold.payment_term_id := p_line_rec.payment_term_id(l_index);
            l_line_rec_for_hold.created_by := NVL(FND_GLOBAL.USER_ID, -1);

oe_debug_pub.add(' Evaluate_Holds ');

             OE_Bulk_Holds_PVT.Evaluate_Holds(
		p_header_rec  => NULL,
		p_line_rec    => l_line_rec_for_hold,
		p_on_generic_hold  => l_on_generic_hold,
		p_on_booking_hold  => l_on_booking_hold,
		p_on_scheduling_hold => l_on_scheduling_hold
		);
            --ER#7479609 end

           -- If the line is on Generic/Booking/Scheduling hold, add it to
           -- the Global.

         IF l_on_generic_hold THEN
          OE_Bulk_Holds_PVT.G_Line_Holds_Tbl(l_index).On_Generic_Hold := 'Y';
         END IF;

         IF l_on_scheduling_hold THEN
          OE_Bulk_Holds_PVT.G_Line_Holds_Tbl(l_index).On_Scheduling_Hold := 'Y';
         END IF;

       END IF;


       ---------------------------------------------------------------
       -- BOOKING VALIDATIONS
       ---------------------------------------------------------------
oe_debug_pub.add('booked_flag ');

       IF p_line_rec.booked_flag(l_index) = 'Y' THEN

          Check_Book_Reqd_Attributes(p_line_rec => p_line_rec
                                     ,p_index   => l_index
                                     ,x_return_status => l_return_status);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             l_book_failed := TRUE;
          END IF;

       END IF;


       ---------------------------------------------------------------
       -- SCHEDULING VALIDATIONS
       ---------------------------------------------------------------
   oe_debug_pub.add(' SCHEDULING :');
       l_c_index := OE_BULK_CACHE.Load_Order_Type(p_header_rec.order_type_id(header_counter));

       IF (OE_BULK_ORDER_PVT.G_AUTO_SCHEDULE = 'Y'
          OR  OE_BULK_CACHE.G_ORDER_TYPE_TBL(l_c_index).auto_scheduling_flag = 'Y'
          OR  p_line_rec.schedule_ship_date(l_index) IS NOT NULL
          OR  p_line_rec.schedule_arrival_date(l_index) IS NOT NULL)
          AND p_line_rec.source_type_code(l_index) = 'INTERNAL'
          AND p_line_rec.lock_control(l_index) <> -99
          AND nvl(p_line_rec.lock_control(l_index), 0) <> -98
          AND nvl(p_line_rec.lock_control(l_index), 0) <> -97
          AND NOT ( p_schedule_configurations = 'N' AND
                    p_line_rec.item_type_code(l_index) IN ('MODEL', 'CLASS',
'OPTION'))
       THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SCHEDULING VALIDATIONS - ato scheduling') ;
         END IF;

         l_d_index := OE_BULK_CACHE.Load_Line_Type(p_line_rec.line_type_id(l_index));
         IF ( OE_BULK_ORDER_PVT.G_SCHEDULE_LINE_ON_HOLD = 'N'
              AND l_on_generic_hold )
         THEN
            -- Add scheduling on hold message
            FND_MESSAGE.SET_NAME('ONT','OE_SCH_LINE_ON_HOLD');
            OE_BULK_MSG_PUB.Add;
         ELSE
            IF OE_BULK_CACHE.G_LINE_TYPE_TBL(l_d_index).scheduling_level_code = 'ONE'
               OR (OE_BULK_CACHE.G_LINE_TYPE_TBL(l_d_index).scheduling_level_code IS NULL
                   AND OE_BULK_CACHE.G_ORDER_TYPE_TBL(l_c_index).scheduling_level_code = 'ONE')
            THEN
              -- Add ATP Only message
              FND_MESSAGE.SET_NAME('ONT','OE_ATP_ONLY');
              OE_BULK_MSG_PUB.Add;
            ELSE
              Check_Scheduling_Attributes(p_line_rec => p_line_rec
                                       ,p_index    =>l_index
                                       ,x_return_status => l_return_status);

              IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

                IF OE_BULK_CACHE.G_LINE_TYPE_TBL(l_d_index).scheduling_level_code = 'FOUR'
                OR OE_BULK_CACHE.G_LINE_TYPE_TBL(l_d_index).scheduling_level_code = 'FIVE'
                THEN

                  IF p_line_rec.ship_from_org_id(l_index) IS NOT NULL THEN
                    IF p_line_rec.schedule_ship_date(l_index) IS NOT NULL THEN
                       p_line_rec.schedule_arrival_date(l_index) :=
                                             p_line_rec.schedule_ship_date(l_index);
                    ELSIF  p_line_rec.schedule_arrival_date(l_index) IS NOT NULL THEN
                       p_line_rec.schedule_ship_date(l_index) :=
                                             p_line_rec.schedule_arrival_date(l_index);
                    ELSE

                       p_line_rec.schedule_ship_date(l_index) :=
                                            p_line_rec.request_date(l_index);
                       p_line_rec.schedule_arrival_date(l_index) :=
                                            p_line_rec.request_date(l_index);
                    END IF;
                    p_line_rec.schedule_status_code(l_index) := 'SCHEDULED';
                    p_line_rec.visible_demand_flag(l_index) := 'N';
                  ELSE
                    FND_MESSAGE.SET_NAME('ONT','OE_INV_NO_WAREHOUSE');
                    OE_BULK_MSG_PUB.Add;
                    IF p_line_rec.schedule_ship_date(l_index) IS NOT NULL
                    OR p_line_rec.schedule_arrival_date(l_index) IS NOT NULL THEN
                       p_line_rec.lock_control(l_index) := -99;
                    END IF;
                  END IF; -- ship from not null.

                ELSE -- four/five
                  p_line_rec.schedule_status_code(l_index) := 'TO_BE_SCHEDULED';
                  OE_BULK_ORDER_PVT.G_SCH_COUNT := OE_BULK_ORDER_PVT.G_SCH_COUNT + 1;
                END IF;
              ELSE
                IF p_line_rec.schedule_ship_date(l_index) IS NOT NULL
                OR p_line_rec.schedule_arrival_date(l_index) IS NOT NULL THEN
                   p_line_rec.lock_control(l_index) := -99;
                END IF;
              END IF; -- return status
            END IF;
         END IF;
         -- Pack J
         -- Latest Acceptable date violation check when flag is set to 'Honor'
         -- 3940632 : dates truncated before comparison.
         IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
          AND OE_SYS_PARAMETERS.value('LATEST_ACCEPTABLE_DATE_FLAG') ='H' THEN
            l_order_date_type_code :=
                        NVL(OE_BULK_SCHEDULE_UTIL.Get_Date_Type(p_line_rec.header_id(l_index)),'SHIP');
            IF trunc(NVL(p_line_rec.latest_acceptable_date(l_index),p_line_rec.request_date(l_index)))
                                   < trunc(p_line_rec.request_date(l_index)) THEN -- LAD less than request date
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'Request date exceeds Latest Acceptable Date ',1 ) ;
               END IF;
               FND_MESSAGE.SET_NAME('ONT','ONT_SCH_REQUEST_EXCEED_LAD');
               OE_BULK_MSG_PUB.Add;
            ELSIF ((l_order_date_type_code = 'SHIP'
               AND trunc(NVL(p_line_rec.schedule_ship_date(l_index),p_line_rec.request_date(l_index)))
                          > trunc(NVL(p_line_rec.latest_acceptable_date(l_index),p_line_rec.request_date(l_index))))
                OR (l_order_date_type_code = 'ARRIVAL'
               AND trunc(NVL(p_line_rec.schedule_arrival_date(l_index),p_line_rec.request_date(l_index)))
                          > trunc(NVL(p_line_rec.latest_acceptable_date(l_index),p_line_rec.request_date(l_index))))) THEN
              FND_MESSAGE.SET_NAME('ONT','ONT_SCH_LAD_SCH_FAILED');
              OE_BULK_MSG_PUB.Add;
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SCHEDULE DATE EXCEEDS LAD ',1 ) ;
              END IF;

           END IF;
         END IF;

       END IF;


       ---------------------------------------------------------------
       -- INCLUDED ITEM PROCESSING
       ---------------------------------------------------------------
 oe_debug_pub.add(' NCLUDED ITEM PROCESSING ');

       IF p_line_rec.lock_control(l_index) <> - 99
          AND p_line_rec.item_type_code(l_index) = 'KIT'
       THEN

          OE_BULK_LINE_UTIL.Append_Included_Items
                 (p_parent_index        => l_index
                 ,p_line_rec            => p_line_rec
                 ,p_header_index        => header_counter
                 ,p_header_rec          => p_header_rec
                 ,x_ii_count            => p_line_rec.ii_count(l_index)
                 ,x_ii_start_index      => p_line_rec.ii_start_index(l_index)
                 ,x_ii_on_generic_hold  => l_ii_on_generic_hold
                 );

          -- Logic to mark kits and included item scheduling fields
          -- if ii is on hold and schedule lines on hold is 'No'
          -- has moved to OEBULINB, Assign_Included_Items

       END IF;

       ---------------------------------------------------------------
       -- Cache EDI attributes if order requires acknowledgments
       ---------------------------------------------------------------
       IF p_header_rec.first_ack_code(header_counter) = 'X'
          AND nvl(p_line_rec.lock_control(l_index),0) <> - 99
       THEN

          IF p_line_rec.ship_to_org_id(l_index) IS NOT NULL THEN
             l_c_index := OE_Bulk_Cache.Load_Ship_To
                            (p_key => p_line_rec.ship_to_org_id(l_index)
                            ,p_edi_attributes => 'Y'
                            );
          END IF;

          IF p_line_rec.invoice_to_org_id(l_index) IS NOT NULL THEN
             l_c_index := OE_Bulk_Cache.Load_Invoice_To
                            (p_key => p_line_rec.invoice_to_org_id(l_index)
                            ,p_edi_attributes => 'Y'
                            );
          END IF;

          IF p_line_rec.ship_from_org_id(l_index) IS NOT NULL THEN
             l_c_index := OE_Bulk_Cache.Load_Ship_From
                            (p_key => p_line_rec.ship_from_org_id(l_index)
                            );
          END IF;
	  --{Bug 5054618
	   -- added for endcustomer changes
	   IF p_line_rec.end_customer_id(l_index) IS NOT NULL THEN
               l_c_index := OE_Bulk_Cache.Load_End_customer
                        (p_key => p_line_rec.end_customer_id(l_index)
                        ,p_edi_attributes => 'Y'
                        );
            END IF;

	    IF p_line_rec.End_customer_site_use_id(l_index) IS NOT NULL THEN
               l_c_index := OE_Bulk_Cache.Load_end_customer_site
                        (p_key => p_line_rec.end_customer_site_use_id(l_index)
                        ,p_edi_attributes => 'Y'
                        );
            END IF;
	  --Bug 5054618}

       END IF;


       ---------------------------------------------------------------
       -- LAST STEP: ERROR PROCESSING
       ---------------------------------------------------------------
  oe_debug_pub.add(' ERROR PROCESSING ');
       -- Set Global Error Record If we have had any validation failures

       IF (p_line_rec.lock_control(l_index) = -99 ) THEN

         --ER 9060917
         If NVL (Fnd_Profile.Value('ONT_HVOP_DROP_INVALID_LINES'), 'N')='Y' then

            If p_line_rec.item_type_code(l_index) ='STANDARD' then

                 UPDATE OE_LINES_IFACE_ALL
		 SET ERROR_FLAG = 'Y'
		 WHERE ORDER_SOURCE_ID = p_line_rec.order_source_id(l_index)
                 AND ORIG_SYS_DOCUMENT_REF = p_line_rec.orig_sys_document_ref(l_index)
                 AND ORIG_SYS_LINE_REF = p_line_rec.orig_sys_line_Ref(l_index);

            else

                  UPDATE OE_LINES_IFACE_ALL
	          SET ERROR_FLAG = 'Y'
	          WHERE ORDER_SOURCE_ID = p_line_rec.order_source_id(l_index)
	          AND ORIG_SYS_DOCUMENT_REF = p_line_rec.orig_sys_document_ref(l_index)
                  AND top_model_line_ref = p_line_rec.top_model_line_ref(l_index);

            end if;

            IF ((p_line_rec.order_source_id(l_index) <> l_order_source_id) OR
	        (p_line_rec.orig_sys_document_ref(l_index) <> l_orig_sys_document_ref)) THEN

	         l_error_count := l_error_count + 1;

	         OE_Bulk_Order_PVT.G_ERROR_REC.order_source_id.EXTEND(1);
	         OE_Bulk_Order_PVT.G_ERROR_REC.order_source_id(l_error_count)
	         := p_line_rec.order_source_id(l_index);
	         l_order_source_id := p_line_rec.order_source_id(l_index);

	         OE_Bulk_Order_PVT.G_ERROR_REC.orig_sys_document_ref.EXTEND(1);
	         OE_Bulk_Order_PVT.G_ERROR_REC.orig_sys_document_ref(l_error_count)
	         := p_line_rec.orig_sys_document_ref(l_index);
	         l_orig_sys_document_ref := p_line_rec.orig_sys_document_ref(l_index);
	         OE_Bulk_Order_PVT.G_ERROR_REC.header_id.EXTEND(1);
	         OE_Bulk_Order_PVT.G_ERROR_REC.header_id(l_error_count)
	         := p_line_rec.header_id(l_index);

            END IF;  --  new order source/orig sys combination

         else
         -- We update the error table only once for a combination of
         -- order_source_id

          IF ((p_line_rec.order_source_id(l_index) <> l_order_source_id) OR
              (p_line_rec.orig_sys_document_ref(l_index) <> l_orig_sys_document_ref))
          THEN

              l_error_count := l_error_count + 1;

              OE_Bulk_Order_PVT.G_ERROR_REC.order_source_id.EXTEND(1);
              OE_Bulk_Order_PVT.G_ERROR_REC.order_source_id(l_error_count)
                  := p_line_rec.order_source_id(l_index);
              l_order_source_id := p_line_rec.order_source_id(l_index);

              OE_Bulk_Order_PVT.G_ERROR_REC.orig_sys_document_ref.EXTEND(1);
              OE_Bulk_Order_PVT.G_ERROR_REC.orig_sys_document_ref(l_error_count)
                  := p_line_rec.orig_sys_document_ref(l_index);
              l_orig_sys_document_ref := p_line_rec.orig_sys_document_ref(l_index);
              OE_Bulk_Order_PVT.G_ERROR_REC.header_id.EXTEND(1);
              OE_Bulk_Order_PVT.G_ERROR_REC.header_id(l_error_count)
                  := p_line_rec.header_id(l_index);

              -- Mark Corresponding Header Record as invalid as well
              p_header_rec.lock_control(header_counter) := -99;

          END IF;  --  new order source/orig sys combination
        END IF; --ER 9060917

       END IF;  -- Line has errors

       -- Next Line
       l_nbr_ctr := l_nbr_ctr + 1;

       l_last_line_index := l_index;

   END LOOP;

   -- Populate header calculate_price_flag

    --PIB
      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
         Oe_bulk_priceorder_pvt.set_hdr_price_flag(p_header_rec);
      END IF;
    --PIB

   -- Check if booking failed for the last order in the batch
   IF l_book_failed THEN
     Unbook_Order(p_header_index    => header_counter
                 ,p_last_line_index => l_last_line_index
                 ,p_line_rec        => p_line_rec
                 );
     l_book_failed := FALSE;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR , LINE.ENTITY' ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , LINE.ENTITY' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    IF OE_BULK_MSG_PUB.Check_Msg_Level(OE_BULK_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Entity'
        );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Entity;

-- HVOP below routine is for Dual control items support    INVCONV

PROCEDURE calculate_dual_quantity
(
   p_line_rec         IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
  ,p_index       	    IN NUMBER
  ,p_dualum_ind 	    IN VARCHAR2
  ,p_x_return_status	    OUT NOCOPY NUMBER
)

IS

l_converted_qty        NUMBER(19,9);         -- INVCONV
l_return               NUMBER;
l_status               VARCHAR2(1);
l_msg_count            NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
UOM_CONVERSION_FAILED  EXCEPTION;

l_buffer                  VARCHAR2(2000); -- INVCONV
TOLERANCE_ERROR EXCEPTION;             -- INVCONV




BEGIN


IF l_debug_level  > 0 THEN
            oe_debug_pub.add ('In calculate_dual_quantity', 3);
END IF;

/* If neither quantity is present, then error as only called for a process type 1,2,or 3 ite m */

  IF (p_line_rec.ordered_quantity(p_index)  IS NULL OR
    p_line_rec.ordered_quantity(p_index)  = FND_API.G_MISS_NUM ) AND
   (p_line_rec.ordered_quantity2(p_index) IS NULL OR
    p_line_rec.ordered_quantity2(p_index) = FND_API.G_MISS_NUM ) THEN
      p_x_return_status := -1;
      IF l_debug_level  > 0 THEN
    	oe_debug_pub.add ('calculate_dual_qty-  both quantities empty so error ', 3);
      END IF;
      RETURN;
  END IF;


/* If quantity2 is present and negative,  then error */

  IF nvl(p_line_rec.ordered_quantity2(p_index), 0) < 0
    THEN
      FND_MESSAGE.SET_NAME('ONT','SO_PR_NEGATIVE_AMOUNT'); -- HVOP define better OM or GMI error code
      OE_BULK_MSG_PUB.Add('Y', 'ERROR');
      p_x_return_status := -1;
      IF l_debug_level  > 0 THEN
    	oe_debug_pub.add ('calculate_dual_qty-  quantity2 negative so error ', 3);
      END IF;
      RETURN;
  END IF;
  -- INVCONV check for valid warehouse/item combo  PAL
  IF nvl(p_line_rec.inventory_item_id(p_index),-99) <> -99 AND
          p_line_rec.ship_from_org_id(p_index)  IS NOT NULL
       THEN

            IF NOT Validate_Item_Warehouse
                    (p_line_rec.inventory_item_id(p_index),
                     p_line_rec.ship_from_org_id(p_index),
                     p_line_rec.item_type_code(p_index),
                     p_line_rec.line_id(p_index),
                     p_line_rec.top_model_line_id(p_index),
                     NULL ,--p_line_rec.source_document_type_id(p_index),
                     'ORDER')
            THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'calculate_dual_qty -  invalid warehouse/item combo' ) ;
                END IF;
                p_x_return_status := -1;
                FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ITEM_WHSE');
                OE_BULK_MSG_PUB.add('Y','ERROR');
                RETURN;
            END IF;

  END IF;





/*IF l_debug_level  > 0 THEN
	oe_debug_pub.add('cached dualum_ind  is ' || p_dualum_ind ,3 );
	oe_debug_pub.add('input qty is          ' || p_line_rec.ordered_quantity(p_index) , 3 );
	oe_debug_pub.add('input qty2 is         ' || p_line_rec.ordered_quantity2(p_index), 3 );
	oe_debug_pub.add('input uom is          ' || p_line_rec.order_quantity_uom(p_index), 3);
	oe_debug_pub.add('input uom2 is         ' || p_line_rec.ordered_quantity_uom2(p_index) , 3);
	END IF; */


IF p_dualum_ind = 'F' THEN
  IF (NVL(p_line_rec.ordered_quantity2(p_index),0) = 0 ) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Calculate_dual_quantity : quantity2 is null and type 1 (D)  so calculate it', 3);
      END IF;

      /*p_line_rec.ordered_quantity2(p_index) := GMI_Reservation_Util.get_opm_converted_qty(
              p_apps_item_id    => p_line_rec.inventory_item_id(p_index),
              p_organization_id => p_line_rec.ship_from_org_id(p_index),
              p_apps_from_uom   => p_line_rec.order_quantity_uom(p_index) ,
              p_apps_to_uom     => p_line_rec.ordered_quantity_uom2(p_index) ,
              p_original_qty    => p_line_rec.ordered_quantity(p_index) );  */

       l_converted_qty := INV_CONVERT.INV_UM_CONVERT(p_line_rec.inventory_item_id(p_index)-- INVCONV
						      ,NULL   --   p_lot_number     -- INVCONV
						      ,p_line_rec.ship_from_org_id(p_index) -- INVCONV
		 				      ,5 --NULL
                                                      ,p_line_rec.ordered_quantity(p_index)
                                                      ,p_line_rec.order_quantity_uom(p_index)
                                                      ,p_line_rec.ordered_quantity_uom2(p_index)
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
						  );
      IF l_debug_level  > 0 THEN
      	oe_debug_pub.add('Calculate_dual_quantity : quantity2 '|| l_converted_qty ,3 );
      END IF;

      p_line_rec.ordered_quantity2(p_index) := l_converted_qty;

      IF (p_line_rec.ordered_quantity2(p_index) < 0) THEN
    	raise UOM_CONVERSION_FAILED;
      END IF;


  ELSIF (NVL(p_line_rec.ordered_quantity(p_index) ,0) = 0 )   THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Calculate_dual_quantity : quantity is null and type 1(F)  so calculate it', 3);
      END IF;

      /* p_line_rec.ordered_quantity(p_index)  := GMI_Reservation_Util.get_opm_converted_qty(
              p_apps_item_id    => p_line_rec.inventory_item_id(p_index),
              p_organization_id => p_line_rec.ship_from_org_id(p_index),
              p_apps_from_uom   => p_line_rec.ordered_quantity_uom2(p_index),
              p_apps_to_uom     => p_line_rec.order_quantity_uom(p_index),
              p_original_qty    => p_line_rec.ordered_quantity2(p_index)); */

        l_converted_qty := INV_CONVERT.INV_UM_CONVERT(p_line_rec.inventory_item_id(p_index)-- INVCONV
						      ,NULL   --   p_lot_number     -- INVCONV
						      ,p_line_rec.ship_from_org_id(p_index) -- INVCONV
						      ,5 --NULL
                                                      ,p_line_rec.ordered_quantity2(p_index)
                                                      ,p_line_rec.ordered_quantity_uom2(p_index)
                                                      ,p_line_rec.order_quantity_uom(p_index)
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
							  );

      p_line_rec.ordered_quantity(p_index) := l_converted_qty;
      IF l_debug_level  > 0 THEN
      	oe_debug_pub.add('Calculate_dual_quantity : quantity '||p_line_rec.ordered_quantity(p_index), 3);
      END IF;
      IF (p_line_rec.ordered_quantity(p_index) < 0) THEN
    		raise UOM_CONVERSION_FAILED;
      END IF;

 END IF; --(NVL(p_line_rec.ordered_quantity2(p_index),0) = 0




ELSIF ( p_dualum_ind = 'D')   THEN

  IF   (NVL(p_line_rec.ordered_quantity2(p_index),0) <> 0 )
          AND (NVL(p_line_rec.ordered_quantity(p_index),0) <> 0 ) THEN
         /* check the deviation and error out */
         IF l_debug_level  > 0 THEN
         	 oe_debug_pub.add('Calculate_dual_quantity : check the deviation 1 and error out if necc ', 3);
      	 END IF;
         l_return := INV_CONVERT.Within_Deviation  -- INVCONV
                       ( p_organization_id   =>
                                 p_line_rec.ship_from_org_id(p_index)
                       , p_inventory_item_id =>
                                 p_line_rec.inventory_item_id(p_index)
                       , p_lot_number  => NULL --  p_lot_number -- INVCONV
                       , p_precision         => 5
                       , p_quantity          => p_line_rec.ordered_quantity(p_index)
                       , p_uom_code1         => p_line_rec.order_quantity_uom(p_index)
                       , p_quantity2         => p_line_rec.ordered_quantity2(p_index)
                       , p_uom_code2         => p_line_rec.ordered_quantity_uom2(p_index)
                       );

       IF l_return = 0
      	then
      	    IF l_debug_level  > 0 THEN
    	  	oe_debug_pub.add('Calculate_dual_quantity - tolerance error 3' ,1);
    	    END IF;

    	   l_buffer := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, -- INVCONV
                                         p_encoded => 'F');
           p_x_return_status := -1;
           oe_msg_pub.add_text(p_message_text => l_buffer);
           --fnd_message.set_name('ONT',l_buffer); -- PAL
           OE_BULK_MSG_PUB.Add('Y', 'ERROR');
           /*IF l_debug_level  > 0 THEN
              oe_debug_pub.add(l_buffer,1);
    	   END IF; */
    	   RAISE TOLERANCE_ERROR;
	else
      	 	IF l_debug_level  > 0 THEN
    	  		oe_debug_pub.add('Calculate_dual_quantity - No tolerance error ',1);
    		END IF;
      END IF; -- IF l_return = 0


  	    /*l_return := GMICVAL.dev_validation(p_opm_item_id
                                      ,0
                                      ,p_line_rec.ordered_quantity(p_index)
                                      ,p_opm_item_um
                                      ,p_line_rec.ordered_quantity2(p_index)
                                      ,p_opm_item_um2
                                      ,0);
      	    IF (l_return = -68 ) THEN
         	p_x_return_status := -1;
         	FND_MESSAGE.set_name('GMI','IC_DEVIATION_HI_ERR');
            	OE_BULK_MSG_PUB.Add('Y', 'ERROR');
            ELSIF(l_return = -69 ) THEN
         	p_x_return_status := -1;
         	FND_MESSAGE.set_name('GMI','IC_DEVIATION_HI_ERR');
		OE_BULK_MSG_PUB.Add('Y', 'ERROR');
      	    END IF; */

  END IF;  --  (NVL(p_line_rec.ordered_quantity2(p_index),0) <> 0 )

  IF   (NVL(p_line_rec.ordered_quantity2(p_index),0) = 0 )
        AND (NVL(p_line_rec.ordered_quantity(p_index),0) <> 0 ) THEN
           IF l_debug_level  > 0 THEN
          	oe_debug_pub.add('Calculate_dual_quantity : quantity2 is null and type 2(D default)  so calculate it', 3);
      	   END IF;
           l_converted_qty := INV_CONVERT.INV_UM_CONVERT(p_line_rec.inventory_item_id(p_index)-- INVCONV
	  					      ,NULL   --   p_lot_number     -- INVCONV
						      ,p_line_rec.ship_from_org_id(p_index) -- INVCONV
						      ,5 --NULL
                                                      ,p_line_rec.ordered_quantity(p_index)
                                                      ,p_line_rec.order_quantity_uom(p_index)
                                                      ,p_line_rec.ordered_quantity_uom2(p_index)
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
        					  );
			      IF l_debug_level  > 0 THEN
			      	oe_debug_pub.add('Calculate_dual_quantity : quantity2 '|| l_converted_qty ,3 );
			      END IF;

			      p_line_rec.ordered_quantity2(p_index) := l_converted_qty;

			      IF (p_line_rec.ordered_quantity2(p_index) < 0) THEN
			    	raise UOM_CONVERSION_FAILED;
			      END IF;

      	/*p_line_rec.ordered_quantity2(p_index) := GMI_Reservation_Util.get_opm_converted_qty(
              p_apps_item_id    => p_line_rec.inventory_item_id(p_index),
              p_organization_id => p_line_rec.ship_from_org_id(p_index),
              p_apps_from_uom   => p_line_rec.order_quantity_uom(p_index) ,
              p_apps_to_uom     => p_line_rec.ordered_quantity_uom2(p_index) ,
              p_original_qty    => p_line_rec.ordered_quantity(p_index) );
      	IF l_debug_level  > 0 THEN
      		oe_debug_pub.add('OPM Calculate_dual_quantity : quantity2 '||p_line_rec.ordered_quantity2(p_index),3 );
      	END IF;
      	IF (p_line_rec.ordered_quantity2(p_index) < 0) THEN
    		raise UOM_CONVERSION_FAILED;
      	END IF;      */

  ELSIF (NVL(p_line_rec.ordered_quantity(p_index) ,0) = 0 )   THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Calculate_dual_quantity : quantity is null and type 2 (D)  so calculate it', 3);
      END IF;


      l_converted_qty := INV_CONVERT.INV_UM_CONVERT(p_line_rec.inventory_item_id(p_index)-- INVCONV
						      ,NULL   --   p_lot_number     -- INVCONV
 			 		              ,p_line_rec.ship_from_org_id(p_index) -- INVCONV
  						      ,5 --NULL
                                                      ,p_line_rec.ordered_quantity2(p_index)
                                                      ,p_line_rec.ordered_quantity_uom2(p_index)
                                                      ,p_line_rec.order_quantity_uom(p_index)
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
              					 );

      p_line_rec.ordered_quantity(p_index) := l_converted_qty;
      IF l_debug_level  > 0 THEN
      	oe_debug_pub.add('Calculate_dual_quantity : quantity '||p_line_rec.ordered_quantity(p_index), 3);
      END IF;
      IF (p_line_rec.ordered_quantity(p_index) < 0) THEN
    		raise UOM_CONVERSION_FAILED;
      END IF;

      /*p_line_rec.ordered_quantity(p_index)  := GMI_Reservation_Util.get_opm_converted_qty(
              p_apps_item_id    => p_line_rec.inventory_item_id(p_index),
              p_organization_id => p_line_rec.ship_from_org_id(p_index),
              p_apps_from_uom   => p_line_rec.ordered_quantity_uom2(p_index),
              p_apps_to_uom     => p_line_rec.order_quantity_uom(p_index),
              p_original_qty    => p_line_rec.ordered_quantity2(p_index));
      IF l_debug_level  > 0 THEN
      	oe_debug_pub.add('OPM Calculate_dual_quantity : quantity '||p_line_rec.ordered_quantity(p_index), 3);
      END IF;
      IF (p_line_rec.ordered_quantity(p_index) < 0) THEN
    	raise UOM_CONVERSION_FAILED;
      END IF;   */



  END IF; -- (NVL(p_line_rec.ordered_quantity2(p_index),0) = 0 )

-- No default
ELSIF ( p_dualum_ind = 'N')   THEN

  IF   (NVL(p_line_rec.ordered_quantity2(p_index),0) <> 0 )
          AND (NVL(p_line_rec.ordered_quantity(p_index),0) <> 0 ) THEN
         /* check the deviation and error out */
         /*l_return := GMICVAL.dev_validation(p_opm_item_id  INVCONV
                                      ,0
                                      ,p_line_rec.ordered_quantity(p_index)
                                      ,p_opm_item_um
                                      ,p_line_rec.ordered_quantity2(p_index)
                                      ,p_opm_item_um2
                                      ,0);
      	    IF (l_return = -68 ) THEN
         	p_x_return_status := -1;
         	FND_MESSAGE.set_name('GMI','IC_DEVIATION_HI_ERR');
                OE_BULK_MSG_PUB.Add('Y', 'ERROR');
            ELSIF(l_return = -69 ) THEN
         	p_x_return_status := -1;
              	FND_MESSAGE.set_name('GMI','IC_DEVIATION_HI_ERR');
              	OE_BULK_MSG_PUB.Add('Y', 'ERROR');
            END IF;   */

         IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Calculate_dual_quantity : check the deviation 2 and error out if necc ', 3);
      	 END IF;
         l_return := INV_CONVERT.Within_Deviation  -- INVCONV
                       ( p_organization_id   =>
                                 p_line_rec.ship_from_org_id(p_index)
                       , p_inventory_item_id =>
                                 p_line_rec.inventory_item_id(p_index)
                       , p_lot_number  => NULL --  p_lot_number -- INVCONV
                       , p_precision         => 5
                       , p_quantity          => p_line_rec.ordered_quantity(p_index)
                       , p_uom_code1         => p_line_rec.order_quantity_uom(p_index)
                       , p_quantity2         => p_line_rec.ordered_quantity2(p_index)
                       , p_uom_code2         => p_line_rec.ordered_quantity_uom2(p_index)
                       );

        IF l_return = 0
      	 then
      	         IF l_debug_level  > 0 THEN
    	  		oe_debug_pub.add('Calculate_dual_quantity - tolerance error 3' ,1);
    		 END IF;

    		 l_buffer := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, -- INVCONV
                                         p_encoded => 'F');
                 p_x_return_status := -1;
         	 oe_msg_pub.add_text(p_message_text => l_buffer);
         	 --fnd_message.set_name('ONT',l_buffer);
         	 OE_BULK_MSG_PUB.Add('Y', 'ERROR');

           	IF l_debug_level  > 0 THEN
              		oe_debug_pub.add(l_buffer,1);
    		END IF;
		RAISE TOLERANCE_ERROR;
   	else
      		IF l_debug_level  > 0 THEN
    	  		oe_debug_pub.add('Calculate_dual_quantity - No tolerance error ',1);
    		END IF;
       END IF; -- IF l_return = 0


  END IF;  --  (NVL(p_line_rec.ordered_quantity2(p_index),0) <> 0 )

  IF  (NVL(p_line_rec.ordered_quantity2(p_index),0) = 0 )
          OR (NVL(p_line_rec.ordered_quantity(p_index),0) = 0 ) THEN
         	p_x_return_status := -1;
         	FND_MESSAGE.set_name('ONT','OE_BULK_OPM_NULL_QTY'); --PROCESS HVOP
         	OE_BULK_MSG_PUB.Add;

  END IF;


END IF; -- IF p_dualum_ind = 1

IF l_debug_level  > 0 THEN
             oe_debug_pub.add ('end of calculate_dual_quantity', 3);
END IF;


EXCEPTION

WHEN UOM_CONVERSION_FAILED THEN
     oe_debug_pub.add('Exception handling: UOM_CONVERSION_FAILED in calculate_dual_qauntity', 1);
     FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR'); -- INVCONV
     OE_BULK_MSG_PUB.Add('Y', 'ERROR');

     RAISE FND_API.G_EXC_ERROR;

WHEN TOLERANCE_ERROR THEN -- INVCONV
	oe_debug_pub.add('Exception handling: TOLERANCE_ERROR in calculate_dual_qty', 1);
 	p_x_return_status := -1;
         --RAISE -- FND_API.G_EXC_ERROR; -- INVCONV


WHEN OTHERS THEN

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Calculate_dual_quantity'
         );
     END IF;
     oe_debug_pub.add('Exception handling: others in calculate_dual_qty', 1);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;



END calculate_dual_quantity;

/*----------------------------------------------------------
FUNCTION Get_Preferred_Grade for HVOP                                  REMOVED FOR INVCONV
-----------------------------------------------------------*/

/*FUNCTION Get_Preferred_Grade
(
	 p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
  	,p_index   IN NUMBER
  	,p_opm_item_id IN NUMBER
)

RETURN VARCHAR2
IS
l_preferred_grade VARCHAR2(4) := NULL;


CURSOR C_GRADE1 IS
SELECT alot.prefqc_grade
FROM op_alot_prm alot, ic_item_mst item, op_cust_mst cust
WHERE item.item_id = p_opm_item_id
          and alot.cust_id = cust.cust_id
		  and item.alloc_class = alot.alloc_class
		  and alot.delete_mark = 0
		  and cust.of_ship_to_site_use_id = p_line_rec.ship_to_org_id(p_index);

CURSOR C_GRADE2 IS
SELECT alot.prefqc_grade
FROM op_alot_prm alot, ic_item_mst item
WHERE item.item_id = p_opm_item_id
	       and alot.cust_id IS NULL
		  and item.alloc_class = alot.alloc_class
		  and alot.delete_mark = 0;
BEGIN

  OPEN C_GRADE1;
  FETCH C_GRADE1 into l_preferred_grade;
  IF (C_GRADE1%NOTFOUND) THEN
    CLOSE C_GRADE1;
    OPEN C_GRADE2;
    FETCH C_GRADE2 into l_preferred_grade;
    IF (C_GRADE2%NOTFOUND) THEN
      CLOSE C_GRADE2;
	 RETURN NULL;
    END IF;
  END IF;

RETURN l_preferred_grade;

EXCEPTION


WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Get_Preferred_Grade'
         );
     END IF;
        oe_debug_pub.add('others in get_preferred_grade', 1);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Preferred_Grade; */

PROCEDURE Load_Cust_Trx_Type_Id
  ( p_line_index       IN NUMBER
   ,p_line_rec           IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
   ,p_header_index   IN NUMBER
   ,p_header_rec     IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE)
IS
l_index NUMBER;
BEGIN

    l_index :=
OE_BULK_CACHE.Load_Line_Type(p_line_rec.line_type_id(p_line_index));

    IF OE_BULK_CACHE.G_LINE_TYPE_TBL(l_index).cust_trx_type_id IS NULL THEN
        -- Line type is null so get value from order type

        l_index := OE_BULK_CACHE.Load_Order_Type(p_header_rec.order_type_id(p_header_index));


        IF OE_BULK_CACHE.G_ORDER_TYPE_TBL(l_index).cust_trx_type_id IS NULL THEN
            -- Get info from profile value

            IF G_INV_TRN_TYPE_ID IS NULL THEN
                G_INV_TRN_TYPE_ID := FND_PROFILE.VALUE('OE_INVOICE_TRANSACTION_TYPE_ID');

                SELECT tax_calculation_flag
                INTO G_INV_TAX_CALC_FLAG
                FROM ra_cust_trx_types
                WHERE cust_trx_type_id = G_INV_TRN_TYPE_ID;

            ELSE
                p_line_rec.cust_trx_type_id(p_line_index)     := G_INV_TRN_TYPE_ID;
                p_line_rec.tax_calculation_flag(p_line_index) := G_INV_TAX_CALC_FLAG;
            END IF;
        ELSE
            p_line_rec.cust_trx_type_id(p_line_index)     := OE_BULK_CACHE.G_ORDER_TYPE_TBL(l_index).cust_trx_type_id;
            p_line_rec.tax_calculation_flag(p_line_index) := OE_BULK_CACHE.G_ORDER_TYPE_TBL(l_index).tax_calculation_flag;
        END IF;

    ELSE

        -- Take values from line type
        p_line_rec.cust_trx_type_id(p_line_index)     := OE_BULK_CACHE.G_LINE_TYPE_TBL(l_index).cust_trx_type_id;
        p_line_rec.tax_calculation_flag(p_line_index) := OE_BULK_CACHE.G_LINE_TYPE_TBL(l_index).tax_calculation_flag;

    END IF;

EXCEPTION


WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Load_Cust_Trx_Type_Id'
         );
     END IF;
        oe_debug_pub.add('others in Load_Cust_Trx_type_Id', 1);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_Cust_Trx_Type_Id;

END OE_BULK_PROCESS_LINE;

/
