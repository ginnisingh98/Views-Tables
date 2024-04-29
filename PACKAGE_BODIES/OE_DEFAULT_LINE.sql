--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_LINE" AS
/* $Header: OEXDLINB.pls 120.24.12010000.12 2009/10/28 08:28:17 cpati ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Line';


g_line_rec				OE_Order_PUB.Line_Rec_Type;

--9040537 /*8319535 start
FUNCTION Get_Def_Invoice_Line_Int
(p_return_context IN VARCHAR2,
p_return_attribute1 IN VARCHAR2,
p_return_attribute2 IN VARCHAR2,
p_sold_to_org_id    IN NUMBER,
p_curr_code     IN VARCHAR2,
p_ref_line_id OUT NOCOPY NUMBER

) RETURN NUMBER;
--9040537 8319535 end*/

/* Added procedure default_active_agr_revision for Bug 2154960 */

procedure Default_Active_Agr_Revision
(   p_x_line_rec                    IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type,
    p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
);

/* Added blanket values defaulting
  --Made this procedure public
  --By Srini


PROCEDURE Default_Blanket_Values
(  p_blanket_number IN NUMBER,
   p_cust_po_number IN VARCHAR2,
   p_ordered_item IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_item_identifier_type IN VARCHAR2,
   p_request_date IN DATE,
   p_sold_to_org_id IN NUMBER,
   x_blanket_number OUT NOCOPY NUMBER,
   x_blanket_line_number OUT NOCOPY NUMBER,
   x_blanket_version_number OUT NOCOPY NUMBER,
   x_blanket_request_date OUT NOCOPY DATE
);
*/

-- bug 4668200
PROCEDURE Set_Header_Def_Hdlr_Rec (p_header_id IN NUMBER) ;

FUNCTION Get_Sold_To
RETURN NUMBER
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   OE_ORDER_CACHE.Load_Order_Header(g_line_rec.header_id);
   RETURN (OE_ORDER_CACHE.g_header_rec.SOLD_TO_ORG_ID);

EXCEPTION
WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         ( G_PKG_NAME,
           'Get_Sold_To'
         );
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Sold_To;

FUNCTION Get_Order_Source_Id
RETURN NUMBER
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   --For Bug#7592137
   IF OE_GLOBALS.G_UI_FLAG then
   RETURN 0;
   ELSE
   OE_ORDER_CACHE.Load_Order_Header(g_line_rec.header_id);
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SOURCE ID ='||OE_ORDER_CACHE.G_HEADER_REC.ORDER_SOURCE_ID ) ;
   END IF;
   RETURN (OE_ORDER_CACHE.g_header_rec.order_source_id);
   END IF; --End of Bug#7592137

EXCEPTION
  WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         ( G_PKG_NAME,
           'Get_Order_Source_Id'
         );
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Order_Source_Id;

FUNCTION GET_FREIGHT_CARRIER(p_line_rec OE_ORDER_PUB.Line_Rec_Type,
					    p_old_line_rec OE_ORDER_PUB.Line_Rec_Type)
RETURN VARCHAR2
IS
l_freight_code VARCHAR2(80);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTER GET FREIGHT CARRIER' ) ;
   END IF;


   IF (p_line_rec.shipping_method_code IS NOT NULL AND
       p_line_rec.shipping_method_code <> FND_API.G_MISS_CHAR) AND
      (p_line_rec.ship_from_org_id  IS NOT NULL AND
       p_line_rec.ship_from_org_id<> FND_API.G_MISS_NUM) THEN

       -- 3610480 : Validate freight_carrier_code if shipping_method_code or ship_from_org_id is not null
      IF (NOT OE_GLOBALS.EQUAL(p_line_rec.shipping_method_code
          	              ,p_old_line_rec.shipping_method_code) OR
          NOT OE_GLOBALS.EQUAL(p_line_rec.ship_from_org_id
                              ,p_old_line_rec.ship_from_org_id) OR
	  NOT OE_GLOBALS.EQUAL(p_line_rec.freight_carrier_code
			      ,p_old_line_rec.freight_carrier_code)) THEN

          IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509' THEN

             SELECT freight_code
             INTO   l_freight_code
             FROM   wsh_carriers wsh_ca,wsh_carrier_services wsh,
                    wsh_org_carrier_services wsh_org
             WHERE  wsh_org.organization_id   = p_line_rec.ship_from_org_id
             AND  wsh.carrier_service_id    = wsh_org.carrier_service_id
             AND  wsh_ca.carrier_id         = wsh.carrier_id
             AND  wsh.ship_method_code      = p_line_rec.shipping_method_code
             AND  wsh_org.enabled_flag      = 'Y';
          ELSE
             Select freight_code
             into l_freight_code
             from wsh_carrier_ship_methods
             where ship_method_code = p_line_rec.shipping_method_code
             and ORGANIZATION_ID = p_line_rec.ship_from_org_id;
          END IF;

          IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'EXIT GET FREIGHT CARRIER' || L_FREIGHT_CODE ) ;
  	  END IF;
          RETURN l_freight_code;

       ELSE
   	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'INTO NULL CONDITION' || P_LINE_REC.SHIP_FROM_ORG_ID ) ;
  	  END IF;
          RETURN p_line_rec.freight_carrier_code;

       END IF;
    ELSE
       IF l_debug_level  > 0 THEN
	  oe_debug_pub.add(  'SHIP FROM OR SHIP METHOD IS  NULL/MISSING',1 ) ;
       END IF;
       RETURN NULL;
    END IF;

    IF (p_line_rec.shipping_method_code IS NULL OR
       p_line_rec.shipping_method_code = FND_API.G_MISS_CHAR) THEN
       RETURN NULL;
    END IF;


    RETURN p_line_rec.freight_carrier_code;

EXCEPTION

WHEN NO_DATA_FOUND THEN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'NO DATA FOUND GET FREIGHT CARRIER' ) ;
	END IF;
RETURN NULL;

WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Get_freight_carrier'
         );
     END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OTHERS IN GET_FREIGHT_CARRIER' , 1 ) ;
        END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END GET_FREIGHT_CARRIER;

FUNCTION Get_Booked
RETURN VARCHAR2
IS
l_booked_flag      VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF NOT oe_globals.G_HTML_FLAG THEN

   -- use order_header cache instead of sql : bug 4200055
	if ( OE_Order_Cache.g_header_rec.header_id <> FND_API.G_MISS_NUM
	     and OE_Order_Cache.g_header_rec.header_id IS NOT NULL
	     and OE_Order_Cache.g_header_rec.header_id = g_line_rec.header_id ) then
            		l_booked_flag := OE_Order_Cache.g_header_rec.booked_flag ;
        else
               OE_ORDER_CACHE.Load_Order_Header(g_line_rec.header_id);
               l_booked_flag := OE_Order_Cache.g_header_rec.booked_flag ;
        end if ;

    /*SELECT booked_flag
    INTO l_booked_flag
    FROM oe_order_headers_all
    WHERE header_id = g_line_rec.header_id; */
ELSE
 l_booked_flag := 'N';
END IF;

    RETURN l_booked_flag;

END Get_Booked;

FUNCTION Get_Cancelled
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    RETURN 'N';

END Get_Cancelled;

FUNCTION Get_Open
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    RETURN 'Y';

END Get_Open;

FUNCTION Get_Cancelled_Quantity
RETURN NUMBER
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	RETURN 0;

END Get_Cancelled_Quantity;


/*---------------------------------------------------------
Following procedures are mainly related to lines which are
model/class/option/config/ato_item/kit/included/

1) get_component
2) get_top_model_line
3) model_option_defaulting
4) get_ato_line
----------------------------------------------------------*/
FUNCTION Get_Component
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' COMP_CODE , ITEM_TYPE_CODE ' || G_LINE_REC.ITEM_TYPE_CODE ) ;
   END IF;
   IF (g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL) OR
      (g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT AND
       g_line_rec.line_id = g_line_rec.top_model_line_id)
   THEN
     g_line_rec.component_code := to_char(g_line_rec.inventory_item_id);
     RETURN g_line_rec.component_code;
   END IF;

   RETURN NULL;

END Get_Component;


/*----------------------------------------------------------------
FUNCTION Get_Top_Model_Line
-----------------------------------------------------------------*/

FUNCTION Get_Top_Model_Line
RETURN NUMBER
IS
l_top_model_line_id      NUMBER;
l_pick_components_flag   VARCHAR2(1);
l_item_type              NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- If top_model_line_id is not null, you do not want to clear it
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN PKG OE_DEFAULT_LINE : PROCEDURE GET_TOP_MODEL_LINE' ) ;
    END IF;

    IF ( g_line_rec.inventory_item_id is NULL  OR
       g_line_rec.inventory_item_id = FND_API.G_MISS_NUM)
    THEN
       RETURN NULL;
    END IF;

    IF g_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE THEN
       RETURN NULL;
    ELSE
      -- class/option, avoid setting value to null by the last return.
      IF g_line_rec.top_model_line_id <> FND_API.G_MISS_NUM THEN
        RETURN g_line_rec.top_model_line_id;
      END IF;

    END IF;

    OE_ORDER_CACHE.Load_Item
            (p_key1 => g_line_rec.inventory_item_id
            ,p_key2 => g_line_rec.ship_from_org_id);
    l_item_type := OE_ORDER_CACHE.g_item_rec.bom_item_type;
    l_pick_components_flag := OE_ORDER_CACHE.g_item_rec.pick_components_flag;

    IF (l_item_type = 4 AND
       l_pick_components_flag = 'Y') OR    -- KIT
        l_item_type = 1                                -- MODEL
    THEN
       IF (g_line_rec.line_id is NOT NULL AND
           g_line_rec.line_id <> FND_API.G_MISS_NUM)
       THEN
          l_top_model_line_id := g_line_rec.line_id;
          RETURN (l_top_model_line_id);
       ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    ELSE
       RETURN NULL;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_ITEM_NOT_FOUND');
       IF ( g_line_rec.ordered_item is NULL  OR    --  This IF added for 1722670
            g_line_rec.ordered_item = FND_API.G_MISS_CHAR) THEN
         FND_MESSAGE.Set_TOKEN('ITEM',
                   'Item with inventory_item_id='||to_char(g_line_rec.inventory_item_id));
       ELSE
         FND_MESSAGE.Set_TOKEN('ITEM', nvl(g_line_rec.ordered_item,g_line_rec.inventory_item_id));
       END IF;
       -- FND_MESSAGE.Set_TOKEN('ITEM', g_line_rec.ordered_item);  Replaced with the above IF for 1722670
       FND_MESSAGE.Set_TOKEN
       ('ORG',OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID'));
       -- oe_organization_id is drpped,
       -- hence need to call OE_SYS_PARAMETERS.Value('MASTER_ORGANIZATION_ID');

       OE_Msg_Pub.Add;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'NO DATA FOUND IN GET_TOP_MODEL IN DEFAULTING' , 1 ) ;
       END IF;

       RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_Top_Model_Line'
	    );
    	END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OTHERS IN GET_TOP_MODEL IN DEFAULTING' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Top_Model_Line;

-- forward declaration
FUNCTION GET_ATO_LINE
RETURN NUMBER;

/* This procedure defaults Active Agreement Revision and
   calls process order again to default Dependent Attributes based
   on new Agreement_Id - Bug 2154960 */

procedure Default_Active_Agr_Revision
(   p_x_line_rec                    IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type,
    p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
)
IS
L_RETURN_STATUS                 VARCHAR2(1);

l_x_line_Tbl                    OE_Order_PUB.Line_Tbl_Type;

l_old_line_tbl                 OE_Order_PUB.Line_Tbl_Type;
l_line_tbl                     OE_Order_PUB.Line_Tbl_Type;
l_control_rec                  OE_GLOBALS.Control_Rec_Type;
l_agreement_name varchar2(240);
l_agreement_id number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INSIDE DEFAULT_ACTIVE_AGR_REVISION' , 3 ) ;
              oe_debug_pub.add(  'AGREEMENT_ID '||P_X_LINE_REC.AGREEMENT_ID , 3 ) ;
          END IF;

          SELECT  agreement_id
          INTO    l_agreement_id
                FROM   oe_agreements_vl
                WHERE  name = (select name from oe_agreements_vl
                               where
                               agreement_id = p_x_line_rec.agreement_id)
                AND    trunc(nvl(p_x_line_rec.pricing_date,sysdate)) BETWEEN
                       trunc(nvl(START_DATE_ACTIVE,add_months(sysdate,-10000)))
                AND    trunc(nvl(END_DATE_ACTIVE,add_months(sysdate,+10000)));

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ACTIVE AGREEMENT REVISION :'||L_AGREEMENT_ID , 3 ) ;
            END IF;

            If p_x_line_rec.agreement_id <> l_agreement_id Then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ACTIVE AGREEMENT REVISION IS FOUND - CALLING PROCESS ORDER TO DEFAULT DEPENDENT ATTRIBUTES' , 3 ) ;
            END IF;

             l_control_rec.controlled_operation    := TRUE;
             l_control_rec.check_security          := TRUE;
             l_control_rec.clear_dependents        := TRUE;
             l_control_rec.default_attributes      := TRUE;
             l_control_rec.change_attributes       := FALSE;
             l_control_rec.validate_entity         := FALSE;
             l_control_rec.write_to_DB             := FALSE;
             l_control_rec.process                 := FALSE;


             l_old_line_tbl(1)                      := p_x_line_rec;
             p_x_line_rec.agreement_id              := l_agreement_id;
             l_line_tbl(1)                          := p_x_line_rec;

          Oe_Order_Pvt.Lines
             ( p_validation_level       => FND_API.G_VALID_LEVEL_NONE
          , p_control_rec               => l_control_rec
          , p_x_line_tbl                        => l_line_tbl
          , p_x_old_line_tbl            => l_old_line_tbl
             , x_return_status        => l_return_status
             );

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          p_x_line_rec := l_line_tbl(1);

         End If;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NO ACTIVE REVISION EXISTS FOR THE AGREEMENT ID :'||P_X_LINE_REC.AGREEMENT_ID , 2 ) ;
             oe_debug_pub.add(  'ERROR WILL BE RAISED IN ENTITY LEVEL VALIDATION' , 3 ) ;
         END IF;

         WHEN FND_API.G_EXC_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         WHEN OTHERS THEN
         IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME          ,
                'Default_Active_Agr_Revision'
            );
         END IF;

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Default_Active_Agr_Revision;
/* End of Bug-2154960 */

-- BEGIN: Blankets Code Merge

PROCEDURE Clear_And_Re_Default
(p_blanket_number         IN NUMBER
,p_blanket_line_number    IN NUMBER
,p_blanket_version_number IN NUMBER
,p_x_line_rec             IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
,p_old_line_rec           IN OE_AK_ORDER_LINES_V%ROWTYPE
,p_default_record         IN VARCHAR2
)
IS
  l_line_rec              OE_AK_ORDER_LINES_V%ROWTYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('ENTER Clear_And_Re_Default') ;
     oe_debug_pub.add('Old blanket num :'
                          ||p_x_line_rec.blanket_number) ;
     oe_debug_pub.add('Old blanket line num :'
                          ||p_x_line_rec.blanket_line_number) ;
     oe_debug_pub.add('Old blanket version num :'
                          ||p_x_line_rec.blanket_version_number) ;
     oe_debug_pub.add('New blanket num : '||p_blanket_number) ;
     oe_debug_pub.add('New blanket line num : '||p_blanket_line_number);
     oe_debug_pub.add('New blanket version num : '||p_blanket_version_number);
  END IF;

  -- Copy source attribute values from IN parameters
  -- to the new record
  IF p_blanket_number IS NOT NULL
  THEN
     IF NOT OE_GLOBALS.EQUAL(p_x_line_rec.blanket_number
                             ,p_blanket_number)
     THEN
        p_x_line_rec.blanket_number := p_blanket_number;
        l_line_rec := p_x_line_rec;
        -- Clear dependents based on blanket number
        OE_Line_Util_Ext.Clear_Dependent_Attr
          (p_attr_id                    => OE_LINE_UTIL.G_BLANKET_NUMBER
          ,p_x_line_rec                 => p_x_line_rec
          ,p_initial_line_rec           => l_line_rec
          ,p_old_line_rec               => p_old_line_rec
          );
     END IF;
  END IF;

  IF p_blanket_line_number IS NOT NULL
  THEN
     IF NOT OE_GLOBALS.EQUAL(p_x_line_rec.blanket_line_number
                             ,p_blanket_line_number)
     THEN
        p_x_line_rec.blanket_line_number := p_blanket_line_number;
        l_line_rec := p_x_line_rec;
        -- Clear dependents based on blanket number
        OE_Line_Util_Ext.Clear_Dependent_Attr
          (p_attr_id                    => OE_LINE_UTIL.G_BLANKET_LINE_NUMBER
          ,p_x_line_rec                 => p_x_line_rec
          ,p_initial_line_rec           => l_line_rec
          ,p_old_line_rec               => p_old_line_rec
          );
     END IF;
  END IF;

  IF p_blanket_version_number IS NOT NULL
  THEN
     IF NOT OE_GLOBALS.EQUAL(p_x_line_rec.blanket_version_number
                             ,p_blanket_version_number)
     THEN
       p_x_line_rec.blanket_version_number := p_blanket_version_number;
       -- No dependent attributes exist for blanket version number
     END IF;
  END IF;

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Final blanket num :'
                          ||p_x_line_rec.blanket_number) ;
     oe_debug_pub.add('Final blanket line num :'
                          ||p_x_line_rec.blanket_line_number) ;
     oe_debug_pub.add('Final blanket version num :'
                          ||p_x_line_rec.blanket_version_number) ;
  END IF;

  IF p_default_record = 'Y' THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('RE-CALLING ONT_LINE_DEF_HDLR.DEFAULT_RECORD') ;
     END IF;
     ONT_LINE_Def_Hdlr.Default_Record
        (p_x_rec	        => p_x_line_rec
        ,p_initial_rec	        => l_line_rec
        ,p_in_old_rec		=> p_old_line_rec
        );
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('EXIT Clear_And_Re_Default') ;
  END IF;

END Clear_And_Re_Default;

PROCEDURE Default_Blanket_Values
(  p_blanket_number IN NUMBER,
   p_cust_po_number IN VARCHAR2,
   p_ordered_item_id IN NUMBER DEFAULT NULL,--bug6826787
   p_ordered_item    IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_item_identifier_type IN VARCHAR2,
   p_request_date IN DATE,
   p_sold_to_org_id IN NUMBER,
   x_blanket_number OUT NOCOPY NUMBER,
   x_blanket_line_number OUT NOCOPY NUMBER,
   x_blanket_version_number OUT NOCOPY NUMBER,
   x_blanket_request_date OUT NOCOPY DATE
)
IS
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_blanket_number       NUMBER;
  --
  l_item_validation_org    NUMBER :=
                           OE_Sys_Parameters.Value('MASTER_ORGANIZATION_ID');
BEGIN

IF p_request_date IS NOT NULL AND
   p_request_date <> FND_API.G_MISS_DATE  THEN
    x_blanket_request_date := p_request_date;
ELSE
    x_blanket_request_date := sysdate;
END IF;

IF p_blanket_number = FND_API.G_MISS_NUM THEN
   l_blanket_number := NULL;
ELSE
   l_blanket_number := p_blanket_number;
END IF;

if l_debug_level > 0 then
   oe_debug_pub.add('Enter Default_Blanket_Values');
   oe_debug_pub.add('Request Date :'||x_blanket_request_date);
end if;

      --derive bl line # and bl revis #
      --first sorts by inventory_item_id, then by ordered_item_id (category)
      --to select most specific of effective blanket lines

-- added for bug 4246913
if l_blanket_number is null AND
   (p_cust_po_number = FND_API.G_MISS_CHAR OR
    p_cust_po_number IS NULL) then

    if l_debug_level > 0 then
       oe_debug_pub.add('No blanket or customer po number on line, returning');
    end if;

    RETURN;
end if;

 --bug6826787 First look for an exact match (inventory_item_id,item_identifier_type,ordered_item_id)
  --If not found then look for atleast inventory_item_id match,if not found then look for category level match,
  --if not found look for ALL Items level

BEGIN  --bug6826787  Exact match
IF l_blanket_number is null THEN

SELECT /* MOAC_SQL_CHANGE */ BH.ORDER_NUMBER, BH.VERSION_NUMBER, BL.LINE_NUMBER
INTO   x_blanket_number,
       x_blanket_version_number,
       x_blanket_line_number
FROM  OE_BLANKET_HEADERS_ALL BH, OE_BLANKET_LINES BL,
      OE_BLANKET_HEADERS_EXT BHE,OE_BLANKET_LINES_EXT BLE
WHERE BH.HEADER_ID = BL.HEADER_ID
AND   BL.CUST_PO_NUMBER = p_cust_po_number
AND   BH.SOLD_TO_ORG_ID = p_sold_to_org_id
AND   BHE.ON_HOLD_FLAG = 'N'
AND   trunc(x_blanket_request_date)
BETWEEN trunc(BLE.START_DATE_ACTIVE)
AND   trunc(nvl(BLE.END_DATE_ACTIVE, x_blanket_request_date))
AND   BL.INVENTORY_ITEM_ID = p_inventory_item_id
AND   BL.item_identifier_type = p_item_identifier_type
AND   decode(BL.item_identifier_type,'INT',to_char(BL.inventory_item_id),
                                     'CUST',to_char(ordered_item_id),
				     NVL(BL.ordered_item,'XXXX') )= decode ( p_item_identifier_type,'INT', to_char(p_inventory_item_id)
										       , 'CUST', to_char(p_ordered_item_id)
										       , NVL(p_ordered_item,'XXXX') )
AND   BL.ITEM_IDENTIFIER_TYPE NOT IN ('CAT','ALL')
AND   BH.ORDER_NUMBER = BHE.ORDER_NUMBER
AND   BL.LINE_ID   = BLE.LINE_ID
AND   BH.SALES_DOCUMENT_TYPE_CODE ='B';

ELSE

SELECT /* MOAC_SQL_CHANGE */ BH.ORDER_NUMBER, BH.VERSION_NUMBER, BL.LINE_NUMBER
INTO   x_blanket_number,
       x_blanket_version_number,
       x_blanket_line_number
FROM  OE_BLANKET_HEADERS_ALL BH, OE_BLANKET_LINES BL,
      OE_BLANKET_HEADERS_EXT BHE,OE_BLANKET_LINES_EXT BLE
WHERE BH.HEADER_ID = BL.HEADER_ID
AND   BH.ORDER_NUMBER = l_blanket_number
-- Do not match customer if blanket number is supplied
-- With 11.5.10, customer on blanket could be
-- related customer or it could be a null customer
-- AND   BH.SOLD_TO_ORG_ID = p_sold_to_org_id
AND   BHE.ON_HOLD_FLAG = 'N'
AND   trunc(x_blanket_request_date)
BETWEEN trunc(BLE.START_DATE_ACTIVE)
AND   trunc(nvl(BLE.END_DATE_ACTIVE, x_blanket_request_date))
AND   BL.INVENTORY_ITEM_ID = p_inventory_item_id
AND   BL.item_identifier_type = p_item_identifier_type
AND   decode(BL.item_identifier_type,'INT',to_char(BL.inventory_item_id),
                                     'CUST',to_char(ordered_item_id),
				     NVL(BL.ordered_item,'XXXX') )= decode ( p_item_identifier_type,'INT', to_char(p_inventory_item_id)
										       , 'CUST', to_char(p_ordered_item_id)
										       , NVL(p_ordered_item,'XXXX') )
AND   BL.ITEM_IDENTIFIER_TYPE NOT IN ('CAT','ALL')
AND   BH.ORDER_NUMBER = BHE.ORDER_NUMBER
AND   BL.LINE_ID   = BLE.LINE_ID
AND   BH.SALES_DOCUMENT_TYPE_CODE ='B';

END IF;

Exception

WHEN TOO_MANY_ROWS THEN

       x_blanket_number := p_blanket_number;
       x_blanket_version_number := NULL;
       x_blanket_line_number := NULL;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Multiple blankets exist for customer po number--no defaulting of blanket values');
        END IF;
        RETURN;

WHEN NO_DATA_FOUND THEN

BEGIN --internal items
IF l_blanket_number is null THEN

SELECT /* MOAC_SQL_CHANGE */ BH.ORDER_NUMBER, BH.VERSION_NUMBER, BL.LINE_NUMBER
INTO   x_blanket_number,
       x_blanket_version_number,
       x_blanket_line_number
FROM  OE_BLANKET_HEADERS_ALL BH, OE_BLANKET_LINES BL,
      OE_BLANKET_HEADERS_EXT BHE,OE_BLANKET_LINES_EXT BLE
WHERE BH.HEADER_ID = BL.HEADER_ID
AND   BL.CUST_PO_NUMBER = p_cust_po_number
AND   BH.SOLD_TO_ORG_ID = p_sold_to_org_id
AND   BHE.ON_HOLD_FLAG = 'N'
AND   trunc(x_blanket_request_date)
BETWEEN trunc(BLE.START_DATE_ACTIVE)
AND   trunc(nvl(BLE.END_DATE_ACTIVE, x_blanket_request_date))
AND   BL.INVENTORY_ITEM_ID = p_inventory_item_id
AND   BL.ITEM_IDENTIFIER_TYPE ='INT' --bug6826787
AND   BH.ORDER_NUMBER = BHE.ORDER_NUMBER
AND   BL.LINE_ID   = BLE.LINE_ID
AND   BH.SALES_DOCUMENT_TYPE_CODE ='B';

ELSE

SELECT /* MOAC_SQL_CHANGE */ BH.ORDER_NUMBER, BH.VERSION_NUMBER, BL.LINE_NUMBER
INTO   x_blanket_number,
       x_blanket_version_number,
       x_blanket_line_number
FROM  OE_BLANKET_HEADERS_ALL BH, OE_BLANKET_LINES BL,
      OE_BLANKET_HEADERS_EXT BHE,OE_BLANKET_LINES_EXT BLE
WHERE BH.HEADER_ID = BL.HEADER_ID
AND   BH.ORDER_NUMBER = l_blanket_number
-- Do not match customer if blanket number is supplied
-- With 11.5.10, customer on blanket could be
-- related customer or it could be a null customer
-- AND   BH.SOLD_TO_ORG_ID = p_sold_to_org_id
AND   BHE.ON_HOLD_FLAG = 'N'
AND   trunc(x_blanket_request_date)
BETWEEN trunc(BLE.START_DATE_ACTIVE)
AND   trunc(nvl(BLE.END_DATE_ACTIVE, x_blanket_request_date))
AND   BL.INVENTORY_ITEM_ID = p_inventory_item_id
AND   BL.ITEM_IDENTIFIER_TYPE ='INT' --bug6826787
AND   BH.ORDER_NUMBER = BHE.ORDER_NUMBER
AND   BL.LINE_ID   = BLE.LINE_ID
AND   BH.SALES_DOCUMENT_TYPE_CODE ='B';

END IF;

 EXCEPTION
    WHEN TOO_MANY_ROWS THEN

       x_blanket_number := p_blanket_number;
       x_blanket_version_number := NULL;
       x_blanket_line_number := NULL;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Multiple blankets exist for customer po number--no defaulting of blanket values');
        END IF;
        RETURN;

    WHEN NO_DATA_FOUND THEN

    BEGIN --item categories

    IF l_blanket_number is null THEN

    SELECT /* MOAC_SQL_CHANGE */ BH.ORDER_NUMBER, BH.VERSION_NUMBER, BL.LINE_NUMBER
    INTO   x_blanket_number,
           x_blanket_version_number,
           x_blanket_line_number
    FROM  OE_BLANKET_HEADERS_ALL BH, OE_BLANKET_LINES BL, MTL_ITEM_CATEGORIES IC,
          OE_BLANKET_HEADERS_EXT BHE,OE_BLANKET_LINES_EXT BLE
    WHERE BH.HEADER_ID = BL.HEADER_ID
    AND   BL.CUST_PO_NUMBER = p_cust_po_number
    AND   BH.SOLD_TO_ORG_ID = p_sold_to_org_id
    AND   BHE.ON_HOLD_FLAG = 'N'
    AND   trunc(x_blanket_request_date)
    BETWEEN trunc(BLE.START_DATE_ACTIVE)
    AND   trunc(nvl(BLE.END_DATE_ACTIVE, x_blanket_request_date))
    AND   BL.ITEM_IDENTIFIER_TYPE = 'CAT'
    AND   IC.ORGANIZATION_ID = l_item_validation_org
    AND   IC.INVENTORY_ITEM_ID = p_inventory_item_id
    AND   BL.INVENTORY_ITEM_ID = IC.CATEGORY_ID
    AND   BH.ORDER_NUMBER = BHE.ORDER_NUMBER
    AND   BL.LINE_ID   = BLE.LINE_ID
    AND   BH.SALES_DOCUMENT_TYPE_CODE ='B';

    ELSE

    SELECT /* MOAC_SQL_CHANGE */  BH.ORDER_NUMBER, BH.VERSION_NUMBER, BL.LINE_NUMBER
    INTO   x_blanket_number,
           x_blanket_version_number,
           x_blanket_line_number
    FROM  OE_BLANKET_HEADERS_ALL BH, OE_BLANKET_LINES BL, MTL_ITEM_CATEGORIES IC
          ,OE_BLANKET_HEADERS_EXT BHE,OE_BLANKET_LINES_EXT BLE
    WHERE BH.HEADER_ID = BL.HEADER_ID
    AND   BH.ORDER_NUMBER = l_blanket_number
    -- Do not match customer if blanket number is supplied
    -- With 11.5.10, customer on blanket could be
    -- related customer or it could be a null customer
    -- AND   BH.SOLD_TO_ORG_ID = p_sold_to_org_id
    AND   BHE.ON_HOLD_FLAG = 'N'
    AND   trunc(x_blanket_request_date)
    BETWEEN trunc(BLE.START_DATE_ACTIVE)
    AND   trunc(nvl(BLE.END_DATE_ACTIVE, x_blanket_request_date))
    AND   BL.ITEM_IDENTIFIER_TYPE = 'CAT'
    AND   IC.ORGANIZATION_ID = l_item_validation_org
    AND   IC.INVENTORY_ITEM_ID = p_inventory_item_id
    AND   BL.INVENTORY_ITEM_ID = IC.CATEGORY_ID
    AND   BH.ORDER_NUMBER = BHE.ORDER_NUMBER
    AND   BL.LINE_ID   = BLE.LINE_ID
    AND   BH.SALES_DOCUMENT_TYPE_CODE ='B';

    END IF;

    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          x_blanket_number := p_blanket_number;
          x_blanket_version_number := NULL;
          x_blanket_line_number := NULL;

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Multiple blankets exist for customer po number--no defaulting of blanket values');
          END IF;
          RETURN;

        WHEN NO_DATA_FOUND THEN

        BEGIN --all items

        IF l_blanket_number is null THEN

        SELECT /* MOAC_SQL_CHANGE */ BH.ORDER_NUMBER, BH.VERSION_NUMBER, BL.LINE_NUMBER
        INTO   x_blanket_number,
               x_blanket_version_number,
               x_blanket_line_number
        FROM  OE_BLANKET_HEADERS BH, OE_BLANKET_LINES_ALL BL,
              OE_BLANKET_HEADERS_EXT BHE,OE_BLANKET_LINES_EXT BLE
        WHERE BH.HEADER_ID = BL.HEADER_ID
        AND   BL.CUST_PO_NUMBER = p_cust_po_number
        AND   BH.SOLD_TO_ORG_ID = p_sold_to_org_id
        AND   BHE.ON_HOLD_FLAG = 'N'
        AND   trunc(x_blanket_request_date)
        BETWEEN trunc(BLE.START_DATE_ACTIVE)
        AND   trunc(nvl(BLE.END_DATE_ACTIVE, x_blanket_request_date))
        AND   BL.ITEM_IDENTIFIER_TYPE = 'ALL'
        AND   BH.ORDER_NUMBER = BHE.ORDER_NUMBER
        AND   BL.LINE_ID   = BLE.LINE_ID
        AND   BH.SALES_DOCUMENT_TYPE_CODE ='B';

        ELSE

        SELECT /* MOAC_SQL_CHANGE */ BH.ORDER_NUMBER, BH.VERSION_NUMBER, BL.LINE_NUMBER
        INTO   x_blanket_number,
               x_blanket_version_number,
               x_blanket_line_number
        FROM  OE_BLANKET_HEADERS_ALL BH, OE_BLANKET_LINES BL,
              OE_BLANKET_HEADERS_EXT BHE,OE_BLANKET_LINES_EXT BLE
        WHERE BH.HEADER_ID = BL.HEADER_ID
        AND   BH.ORDER_NUMBER = l_blanket_number
        -- Do not match customer if blanket number is supplied
        -- With 11.5.10, customer on blanket could be
        -- related customer or it could be a null customer
        -- AND   BH.SOLD_TO_ORG_ID = p_sold_to_org_id
        AND   BHE.ON_HOLD_FLAG = 'N'
        AND   trunc(x_blanket_request_date)
        BETWEEN trunc(BLE.START_DATE_ACTIVE)
        AND   trunc(nvl(BLE.END_DATE_ACTIVE, x_blanket_request_date))
        AND   BL.ITEM_IDENTIFIER_TYPE = 'ALL'
        AND   BH.ORDER_NUMBER = BHE.ORDER_NUMBER
        AND   BL.LINE_ID   = BLE.LINE_ID
        AND   BH.SALES_DOCUMENT_TYPE_CODE ='B';

        END IF;

        EXCEPTION
            WHEN TOO_MANY_ROWS THEN
              x_blanket_number := p_blanket_number;
              x_blanket_version_number := NULL;
              x_blanket_line_number := NULL;

              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('Multiple blankets exist for customer po number--no defaulting of blanket values');
              END IF;
              RETURN;
            WHEN NO_DATA_FOUND THEN
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('No Blanket Number exists for this customer,item :'||p_sold_to_org_id,2);
                     oe_debug_pub.add('Error will be raised in Entity level validation',3);
                  END IF;
        END; --all items
    END; --item categories
END; --internal, customer, generic items
END;  --bug6826787 Exact match

EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (  G_PKG_NAME        ,
        'Default_Blanket_Values'
      );
    END IF;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('others in default_blanket_values', 1);
  END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Default_Blanket_Values;


PROCEDURE Perform_Blanket_Functions
   (p_x_line_rec              IN OUT NOCOPY OE_AK_ORDER_LINES_V%ROWTYPE
   ,p_old_line_rec            IN OE_AK_ORDER_LINES_V%ROWTYPE
   ,p_default_record          IN VARCHAR2 DEFAULT 'N'
   ,x_blanket_request_date    OUT NOCOPY /* file.sql.39 change */ DATE
   )
IS
  l_blanket_number            NUMBER;
  l_blanket_line_number       NUMBER;
  l_blanket_version_number    NUMBER;
  l_blanket_request_date      DATE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF (p_x_line_rec.blanket_number IS NOT NULL
    AND p_x_line_rec.blanket_number <> FND_API.G_MISS_NUM)
 OR ( p_x_line_rec.cust_po_number IS NOT NULL
      AND p_x_line_rec.cust_po_number <> FND_API.G_MISS_CHAR
      -- Bug 2818494
      -- Default blanket from customer PO only if either
      -- customer PO or item is updated on order line.
      AND (NOT OE_GLOBALS.EQUAL(p_x_line_rec.cust_po_number
                                ,p_old_line_rec.cust_po_number)
           OR NOT OE_GLOBALS.EQUAL(p_x_line_rec.inventory_item_id
                                ,p_old_line_rec.inventory_item_id)
           )
     )
THEN

   if l_debug_level > 0 then
      oe_debug_pub.add('ENTER Perform_Blanket_Functions');
      oe_debug_pub.add('Blanket Num :'||
                            p_x_line_rec.blanket_number);
      oe_debug_pub.add('Blanket Line Num :'||
                            p_x_line_rec.blanket_line_number);
      oe_debug_pub.add('Cust PO :'||
                            p_x_line_rec.cust_po_number);
      oe_debug_pub.add('Old Blanket Num :'||
                            p_old_line_rec.blanket_number);
      oe_debug_pub.add('Old Blanket Line Num :'||
                            p_old_line_rec.blanket_line_number);
      oe_debug_pub.add('Old Cust PO :'||
                            p_old_line_rec.cust_po_number);
   end if;

   -- Bug 2737082 => If blanket line number exists, removed the
   -- AND clause for operation and version number check and moved
   -- it inside the IF.
   -- Otherwise, the ELSE part of this IF statement was being
   -- executed for all release lines even if there was a blanket
   -- line number which could result in over-riding an existing
   -- blanket line number value.
   IF p_x_line_rec.blanket_line_number IS NOT NULL
      AND p_x_line_rec.blanket_line_number <> FND_API.G_MISS_NUM
   THEN


  --Redefault the blanket_line_number even when the blanket_line_number is NOT NULL
  --on the line if the request_date/ordered item is changed
  --This would fix the bug 6368131 also

  IF ( (trunc(p_x_line_rec.request_date) <> trunc(p_old_line_rec.request_date))
        OR (p_x_line_rec.inventory_item_id <> p_old_line_rec.inventory_item_id )
	OR (p_x_line_rec.ordered_item_id   <> p_old_line_rec.ordered_item_id)
	OR (p_x_line_rec.ordered_item      <> p_old_line_rec.ordered_item)) THEN


	IF ( p_x_line_rec.sold_to_org_id IS NOT NULL
	    AND p_x_line_rec.sold_to_org_id <> FND_API.G_MISS_NUM
            AND p_x_line_rec.inventory_item_id IS NOT NULL
            AND p_x_line_rec.inventory_item_id <> FND_API.G_MISS_NUM
            AND (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD
                 OR (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT
                     AND p_x_line_rec.top_model_line_id = p_x_line_rec.line_id))) THEN

		Default_Blanket_Values
		(  p_blanket_number => p_x_line_rec.blanket_number,
		   p_cust_po_number => p_x_line_rec.cust_po_number,
		   p_ordered_item_id =>p_x_line_rec.ordered_item_id,
		   p_ordered_item =>p_x_line_rec.ordered_item, --bug6826787
		   p_inventory_item_id => p_x_line_rec.inventory_item_id,
		   p_item_identifier_type => p_x_line_rec.item_identifier_type,
		   p_request_date => p_x_line_rec.request_date,
		   p_sold_to_org_id => p_x_line_rec.sold_to_org_id,
		   x_blanket_number => l_blanket_number,
		   x_blanket_line_number => l_blanket_line_number,
		   x_blanket_version_number => l_blanket_version_number,
		   x_blanket_request_date => x_blanket_request_date
		);

	      IF (l_blanket_number IS NOT NULL
		  AND NOT OE_GLOBALS.EQUAL(l_blanket_number
			  ,p_x_line_rec.blanket_number))
		 OR (l_blanket_line_number IS NOT NULL
		    AND NOT OE_GLOBALS.EQUAL(l_blanket_line_number
			    ,p_x_line_rec.blanket_line_number))
	      THEN
		 Clear_And_Re_Default
		     (p_blanket_number            => l_blanket_number
		     ,p_blanket_line_number       => l_blanket_line_number
		     ,p_blanket_version_number    => l_blanket_version_number
		     ,p_x_line_rec                => p_x_line_rec
		     ,p_old_line_rec              => p_old_line_rec
		     ,p_default_record            => p_default_record
		     );
	      END IF;



	  END IF;


    END IF;


      IF (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
           OR p_x_line_rec.blanket_version_number = FND_API.G_MISS_NUM)
      THEN

        if l_debug_level > 0 then
           oe_debug_pub.add('Default Blanket Version Number');
        end if;

      -- Derive blanket_version_number if blanket number
      -- ,line number are provided

      BEGIN

        SELECT /* MOAC_SQL_CHANGE */ BH.VERSION_NUMBER
          INTO l_blanket_version_number
          FROM OE_BLANKET_LINES_ALL BL,OE_BLANKET_LINES_EXT BLE,
               OE_BLANKET_HEADERS BH
         WHERE BLE.ORDER_NUMBER = p_x_line_rec.blanket_number
           AND BLE.LINE_NUMBER  = p_x_line_rec.blanket_line_number
           AND BL.LINE_ID       = BLE.LINE_ID
           AND BH.HEADER_ID     = BL.HEADER_ID
           AND BL.SALES_DOCUMENT_TYPE_CODE = 'B';

        p_x_line_rec.blanket_version_number := l_blanket_version_number;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        oe_debug_pub.add('Blanket Values combination is not valid: Blanket #:'||p_x_line_rec.blanket_number || ', Blanket Line #:'||p_x_line_rec.blanket_line_number, 2);
        FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_INVALID_BLANKET');
        fnd_message.set_token('BLANKET_NUMBER',p_x_line_rec.blanket_number);
        fnd_message.set_token('BLANKET_LINE_NUMBER',p_x_line_rec.blanket_line_number);
        OE_MSG_PUB.Add;
      END;

      END IF; -- default version number

   -- Bug 2737082 => Only if blanket line number is null or missing,
   -- then default if required fields are available.
   ELSIF (p_x_line_rec.sold_to_org_id IS NOT NULL
         AND p_x_line_rec.sold_to_org_id <> FND_API.G_MISS_NUM
         AND p_x_line_rec.inventory_item_id IS NOT NULL
         AND p_x_line_rec.inventory_item_id <> FND_API.G_MISS_NUM
         AND (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD
              OR (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT
                  AND p_x_line_rec.top_model_line_id = p_x_line_rec.line_id)
              )
         -- Bug 2769562 => If blanket line number is being cleared by user
         -- (value for blanket line number existed in old rec), blanket
         -- fields should NOT be re-defaulted.
         AND (p_old_line_rec.blanket_line_number IS NULL
              OR p_old_line_rec.blanket_line_number = FND_API.G_MISS_NUM
              )) OR (p_x_line_rec.sold_to_org_id IS NOT NULL
         --Bug 3228828
         --Defaulting of the Blanket Line Number for Config and Service Items.
         AND p_x_line_rec.sold_to_org_id <> FND_API.G_MISS_NUM
         AND p_x_line_rec.inventory_item_id IS NOT NULL
         AND p_x_line_rec.inventory_item_id <> FND_API.G_MISS_NUM
         AND oe_code_control.get_code_release_level >= '110510'
         -- Bug 2769562 => If blanket line number is being cleared by user
         -- (value for blanket line number existed in old rec), blanket
         -- fields should NOT be re-defaulted.
         AND (p_old_line_rec.blanket_line_number IS NULL
              OR p_old_line_rec.blanket_line_number = FND_API.G_MISS_NUM
              ) OR p_x_line_rec.blanket_line_number <> p_old_line_rec.blanket_line_number
                --OR (p_x_line_rec.blanket_line_number IS NOT NULL    --6368131
                  --AND trunc(p_x_line_rec.request_date) <>
                            --trunc(p_old_line_rec.request_date))
)--bug6497015
   THEN

      if l_debug_level > 0 then
         oe_debug_pub.add('Blkt Number : '||p_x_line_rec.blanket_number);
         oe_debug_pub.add('Cust PO : '||p_x_line_rec.cust_po_number);
         oe_debug_pub.add('Item : '||p_x_line_rec.inventory_item_id);
         oe_debug_pub.add('Item Type : '||p_x_line_rec.item_type_code);
      end if;

      -- Default Blanket Fields
      Default_Blanket_Values
        (  p_blanket_number => p_x_line_rec.blanket_number,
           p_cust_po_number => p_x_line_rec.cust_po_number,
           p_ordered_item_id =>p_x_line_rec.ordered_item_id,--bug8344368
           p_ordered_item =>p_x_line_rec.ordered_item,
           p_inventory_item_id => p_x_line_rec.inventory_item_id,
           p_item_identifier_type => p_x_line_rec.item_identifier_type,
           p_request_date => p_x_line_rec.request_date,
           p_sold_to_org_id => p_x_line_rec.sold_to_org_id,
           x_blanket_number => l_blanket_number,
           x_blanket_line_number => l_blanket_line_number,
           x_blanket_version_number => l_blanket_version_number,
           x_blanket_request_date => x_blanket_request_date
        );

      IF (l_blanket_number IS NOT NULL
          AND NOT OE_GLOBALS.EQUAL(l_blanket_number
                  ,p_x_line_rec.blanket_number))
         OR (l_blanket_line_number IS NOT NULL
            AND NOT OE_GLOBALS.EQUAL(l_blanket_line_number
                    ,p_x_line_rec.blanket_line_number))
      THEN
         Clear_And_Re_Default
             (p_blanket_number            => l_blanket_number
             ,p_blanket_line_number       => l_blanket_line_number
             ,p_blanket_version_number    => l_blanket_version_number
             ,p_x_line_rec                => p_x_line_rec
             ,p_old_line_rec              => p_old_line_rec
             ,p_default_record            => p_default_record
             );
      END IF;

   END IF;

   if l_debug_level > 0 then
      oe_debug_pub.add('EXIT Perform_Blanket_Functions');
   end if;

END IF; -- if blanket number or cust po exists

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (   G_PKG_NAME         ,
             'Perform_Blanket_Functions'
         );
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Perform_Blanket_Functions;

  --- Added for 11510 pack J to get the BSA Line Number and Version Number
  --- For given CONFIG and SERVICE items. srini
Procedure Get_Blanket_number_svc_config
(   p_blanket_number            IN  OUT NOCOPY /* file.sql.39 change */ NUMBER
   ,p_inventory_item_id         IN          NUMBER
   ,x_blanket_line_number       OUT NOCOPY  NUMBER
   ,x_blanket_version_number    OUT NOCOPY  NUMBER
) is
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BSA: ENTERING Get_Blanket_Number API' ) ;
      oe_debug_pub.add(  'BSA: Blanket Number in Get_Blanket_Number: '||p_blanket_number ) ;
      oe_debug_pub.add(  'BSA: Inventory Item Id in Get_Blanket_Number : '||p_INVENTORY_ITEM_ID ) ;
  END IF;

      SELECT /* MOAC_SQL_CHANGE */
              BL.LINE_NUMBER,
              BH.VERSION_NUMBER
      INTO
              x_blanket_line_number,
              x_blanket_version_number

      FROM    OE_BLANKET_LINES BL,
              OE_BLANKET_HEADERS_ALL BH,
              OE_BLANKET_HEADERS_EXT BHE,
              OE_BLANKET_LINES_EXT BLE
      WHERE   BH.ORDER_NUMBER  = p_blanket_number
      AND     BL.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID
      AND     BH.HEADER_ID  = BL.HEADER_ID
      AND     BH.ORDER_NUMBER = BHE.ORDER_NUMBER
      AND     BL.LINE_ID   = BLE.LINE_ID
      AND     BHE.ON_HOLD_FLAG = 'N'
      AND     trunc(sysdate) BETWEEN trunc(BLE.START_DATE_ACTIVE)
                             AND   trunc(nvl(BLE.END_DATE_ACTIVE, sysdate))
      AND     BL.ITEM_IDENTIFIER_TYPE NOT IN ('ALL')
      AND     p_blanket_number is not null
      AND     BL.SALES_DOCUMENT_TYPE_CODE = 'B';


      IF (x_blanket_line_number is null and x_blanket_version_number is null) then

          SELECT /* MOAC_SQL_CHANGE */
                  BL.LINE_NUMBER,
                  BH.VERSION_NUMBER
          INTO
                  x_blanket_line_number,
                  x_blanket_version_number

          FROM    OE_BLANKET_LINES BL,
                  OE_BLANKET_HEADERS_ALL BH,
                  OE_BLANKET_HEADERS_EXT BHE,
                  OE_BLANKET_LINES_EXT BLE
          WHERE   BH.ORDER_NUMBER  = p_blanket_number
          AND     BH.HEADER_ID  = BL.HEADER_ID
          AND     BH.ORDER_NUMBER = BHE.ORDER_NUMBER
          AND     BL.LINE_ID   = BLE.LINE_ID
          AND     BHE.ON_HOLD_FLAG = 'N'
          AND     trunc(sysdate) BETWEEN trunc(BLE.START_DATE_ACTIVE)
                                            AND   trunc(nvl(BLE.END_DATE_ACTIVE, sysdate))
          AND     BL.ITEM_IDENTIFIER_TYPE = 'ALL'
          AND     p_blanket_number is not null
          AND     BL.SALES_DOCUMENT_TYPE_CODE = 'B';


      END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BSA: LEAVING Get_Blanket_Number API' ) ;
      oe_debug_pub.add(  'BSA: Blanket line Number in Get_Blanket_Number: '||p_blanket_number ) ;
      oe_debug_pub.add(  'BSA: Blanket line Number in Get_Blanket_Number: '||x_blanket_line_number ) ;
      oe_debug_pub.add(  'BSA: Blanket Version Number in Get_Blanket_Number : '||x_blanket_version_number
) ;
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
      x_blanket_line_number    := null;
      x_blanket_version_number := null;
      p_blanket_number         := null;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BSA:LEAVING Get_Blanket_Number API: NO_DATA_FOUND' ) ;
      END IF;
  WHEN TOO_MANY_ROWS THEN
      x_blanket_line_number    := null;
      x_blanket_version_number := null;
      p_blanket_number         := null;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BSA:LEAVING Get_Blanket_Number API: TOO_MANY_ROWS' ) ;
      END IF;
  WHEN OTHERS THEN
      x_blanket_line_number    := null;
      x_blanket_version_number := null;
      p_blanket_number         := null;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BSA:LEAVING Get_Blanket_Number API: OTEHRS' ) ;
      END IF;

End Get_Blanket_number_svc_config;

-- END: Blankets Code Merge

/*----------------------------------------------------------------
This procedure is used to default certain columns of children of
top level model i.e ATO model, PTO model, SMC-PTO Model. and
ato_line_id for top parent as well as oprion/class/config etc.
shippable_flag??
Before the control comes here, g_line_rec should have following
attributes :

1) line_id,
2) top_model_line_id,
3) item_type_code,
4) ship_model_complete_flag of top parent

ONT's item_type_code of ato under pto or ato under ato is 'CLASS'
even though its bom_item_type is 1.

Change Record:
2150536 : moved the ato/smc/set specific defaulting to
default_child_line.
-----------------------------------------------------------------*/
PROCEDURE Model_Option_Defaulting
IS
  l_top_model_line_rec         OE_ORDER_PUB.line_rec_type;
  l_parent_line_id             NUMBER;
  l_return_status              VARCHAR2(1);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  l_top_container              VARCHAR2(1);
  l_part_of_container          VARCHAR2(1);
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING MODEL_OPTION_DEFAULTING' , 1 ) ;
      oe_debug_pub.add(  'LINE_ID TO DEFAULT: '|| G_LINE_REC.LINE_ID , 1 ) ;
  END IF;

  /* If the top model is in a fulfillment set then we must push all its
     children into same fulfillment set. We exclude service item and the
     top model itself*/
  -- 4118431
  IF (g_line_rec.line_id <> g_line_rec.top_model_line_id AND
      g_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_SERVICE AND
      g_line_rec.top_modeL_line_id IS NOT NULL AND
      g_line_rec.line_id > 0 ) THEN

     Insert_into_set
     (p_line_id        => g_line_rec.top_model_line_id,
      p_child_line_id  => g_line_rec.line_id,
      x_return_status  => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;


  /* We do not do any defaulting for service items and kits.
   * We also do not default anything special for included items,
   * since user dose not enter them.They are created in the
   * process_included_items procedure and all the fields to be populated
   * from the parent line, are populated there. */

  IF g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE OR
     g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED OR
     (g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT AND
      g_line_rec.line_id = g_line_rec.top_modeL_line_id)
  THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURNING FOR SERVICE , INCLUDED , TOP LEVEL KITS' , 1 ) ;
    END IF;
    RETURN;
  END IF;


  IF g_line_rec.ato_line_id = FND_API.G_MISS_NUM THEN
    g_line_rec.ato_line_id  := Get_ATO_Line;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'GET_ATO_LINE SUCCESSFUL' , 1 ) ;
    END IF;
  END IF;


  /* After getting ato_line_id, for top level parents and ato items,
   * we don't default any other columns for lines with item_type MODEL
   * and STANDARD */

  IF g_line_rec.item_type_code =  OE_GLOBALS.G_ITEM_MODEL OR
     g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD
  THEN
     --{ bug3601544 starts
     IF l_debug_level > 0 THEN
	OE_DEBUG_PUB.Add('IB Owner: '||g_line_rec.ib_owner,3);
	OE_DEBUG_PUB.Add('IB Install: '||g_line_rec.ib_installed_at_location,3);
	OE_DEBUG_PUB.Add('IB Current: '||g_line_rec.ib_current_location,3);
     END IF;

     OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
     (  p_line_id             => g_line_rec.line_id
       ,p_top_model_line_id   => g_line_rec.top_model_line_id
       ,p_ato_line_id         => g_line_rec.ato_line_id
       ,p_inventory_item_id   => g_line_rec.inventory_item_id
       ,x_top_container_model => l_top_container
       ,x_part_of_container   => l_part_of_container  );

     IF l_top_container = 'Y' THEN
        g_line_rec.ib_owner := NULL;
	g_line_rec.ib_installed_at_location := NULL;
	g_line_rec.ib_current_location := NULL;

	IF l_debug_level > 0 THEN
	   OE_DEBUG_PUB.Add('IB Fields set to NULL for Top Container Line',3);
	END IF;
     END IF;
     -- bug3601544 ends }

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURNING FOR ITEM TYPE MODEL AND STANDARD' , 1 ) ;
     END IF;
     RETURN;
  END IF;



  /* If we are here, it means item_type_code is CLASS, OPTION, KIT under
   * a model,or CONFIG. Load top parent, so that we know if it is ato,
   * smc pto or nonsmc pto */

  IF g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN
     l_parent_line_id := g_line_rec.ato_line_id;
  ELSE
     l_parent_line_id := g_line_rec.top_model_line_id;
  END IF;
  --2605065 : commented. This has been added in procedure Attributes.
  --OE_Order_Cache.clear_top_model_line(l_parent_line_id);

  l_top_model_line_rec :=     OE_Order_Cache.Load_Top_Model_Line
                              (l_parent_line_id );


  /* We are introducing a new procedure Default_Child_Line in oe_config_util
   * to default all appropriate values from top model to its children.
   * In future if you need to copy anything from parent to children,
   * add code in oe_config_util */

   oe_config_util.default_child_line
  (p_parent_line_rec  => l_top_model_line_rec,
   p_x_child_line_rec => g_line_rec,
   x_return_status    => l_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURN STATUS || ' || L_RETURN_STATUS , 3 ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING MODEL_OPTION_DEFAULTING' , 1 ) ;
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NO DATA FOUND IN MODEL_OPTION_DEFAULTING' , 1 ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;

  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (  G_PKG_NAME        ,
        'Model_Option_Defaulting'
      );
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS IN MODEL_OPTION_DEFAULTING' , 1 ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Model_Option_Defaulting;


/* -------------------------------------------------------------
This procedure will be used to default data from their model
in case of updates
----------------------------------------------------------------*/

PROCEDURE Model_Option_update
(p_x_line_rec IN OUT NOCOPY OE_ORDER_PUB.line_rec_type)
IS
l_top_model_line_rec         OE_ORDER_PUB.line_rec_type;
l_parent_line_id             NUMBER;
l_return_status              VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING MODEL_OPTION_UPDATE' , 1 ) ;
      oe_debug_pub.add(  'LINE_ID TO DEFAULT: '|| P_X_LINE_REC.LINE_ID , 1 ) ;
  END IF;

 /* These updates are valid only for Options/clasees/included items */

  IF p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE OR
     p_x_line_rec.item_type_code =  OE_GLOBALS.G_ITEM_MODEL OR
     p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD OR
     (p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT AND
      p_x_line_rec.line_id = p_x_line_rec.top_modeL_line_id)
  THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURNING FOR ITEM TYPE SERVICE , MODEL , STANDARD AND TOP LEVEL KITS' , 1 ) ;
     END IF;

     RETURN;
  END IF;

  IF p_x_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN
     l_parent_line_id := p_x_line_rec.ato_line_id;
  ELSE
     l_parent_line_id := p_x_line_rec.top_model_line_id;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'TOP MODEL LINE ID FOR TOP MODEL' || L_PARENT_LINE_ID , 1 ) ;
  END IF;
  -- 2605065 : Commented. This has been done in procedure Attributes.
  --OE_Order_Cache.clear_top_model_line(l_parent_line_id);
  l_top_model_line_rec :=     OE_Order_Cache.Load_Top_Model_Line
                              (l_parent_line_id );

  p_x_line_rec.ship_tolerance_above := l_top_model_line_rec.ship_tolerance_above;
  p_x_line_rec.ship_tolerance_below := l_top_model_line_rec.ship_tolerance_below;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING MODEL_OPTION_UPDATE' , 1 ) ;
  END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'NO DATA FOUND IN MODEL_OPTION_UPDATE' , 1 ) ;
       END IF;

       RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Model_Option_update'
         );
     END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OTHERS IN MODEL_OPTION_UPDATE' , 1 ) ;
        END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Model_Option_Update;

/*-------------------------------------------------------------
this procedure gets ato_line_id for top level ato model,
ato_item and all children top ato model. It requires
1) item_type_code
2) line_id
3) top_model_line_id

Change Record:
bug 1894331
  the select statement for getting ato_line_id in case of
  pto+ato case is modified. look at the bug for more details.
  also made same change in OEXVCFGB.pls:update_ato_line_attribs.
Bug 2513840
   Added Code to handle TOO_MANY_ROWS in Exception
--------------------------------------------------------------*/
FUNCTION Get_ATO_Line
RETURN NUMBER
IS
l_ato_line_id                  NUMBER;
l_temp_ato_line_id             NUMBER;
l_replenish_to_order_flag      VARCHAR2(1);
l_build_in_wip_flag            VARCHAR2(1);
l_bom_item_type                NUMBER;
l_ato_config_item_id           NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IN GET_ATO_LINE , ITEM_TYPE_CODE :' || G_LINE_REC.ITEM_TYPE_CODE , 1 ) ;
  END IF;

  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' AND
     g_line_rec.item_type_code = 'CONFIG' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PACK H MI , CONFIG LINE '|| G_LINE_REC.ATO_LINE_ID ) ;
    END IF;
    RETURN g_line_rec.ato_line_id;
  END IF;

  IF ( g_line_rec.inventory_item_id is NULL  OR
       g_line_rec.inventory_item_id = FND_API.G_MISS_NUM)
  THEN
     RETURN NULL;
  END IF;

  IF g_line_rec.line_category_code =
                  OE_GLOBALS.G_RETURN_CATEGORY_CODE THEN
     RETURN NULL;
  END IF;

  OE_ORDER_CACHE.Load_Item
          (p_key1 => g_line_rec.inventory_item_id
          ,p_key2 => g_line_rec.ship_from_org_id);

  l_replenish_to_order_flag :=
                  OE_ORDER_CACHE.g_item_rec.replenish_to_order_flag;
  l_build_in_wip_flag := OE_ORDER_CACHE.g_item_rec.build_in_wip_flag;
  l_bom_item_type := OE_ORDER_CACHE.g_item_rec.bom_item_type;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GET_ATO_LINE: '||L_REPLENISH_TO_ORDER_FLAG||L_BUILD_IN_WIP_FLAG , 1 ) ;
  END IF;

  -- top level ATO model and ato item.
  -- build in wip flag, see if req?

  IF (g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL AND
      l_replenish_to_order_flag = 'Y') OR
     (g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD AND
      l_replenish_to_order_flag = 'Y' AND
      l_build_in_wip_flag = 'Y')
  THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '1. ATO_LINE_ID: '||G_LINE_REC.LINE_ID , 1 ) ;
    END IF;
    l_ato_line_id := g_line_rec.line_id;
    RETURN (l_ato_line_id);

  ELSE
   /* we have to set ato_line_id for all options
    * classes, config item which are under top ato model
    * ato model (ont: item_type_code is CLASS, bom_item_type = 1)
    * under top ato model will have ato_line_id = line_id
    * of top ato parent. kit can not be under an ATO */

    IF g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
       g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
       g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN

      OE_Order_Cache.Load_Top_Model_Line
                      (g_line_rec.top_model_line_id );
      l_ato_line_id := OE_Order_Cache.g_top_model_line_rec.ato_line_id;

      IF l_ato_line_id is NULL THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'TOP MODEL IS PTO' , 3 ) ;
        END IF;

        IF (g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS AND
            l_replenish_to_order_flag = 'Y' AND
            l_bom_item_type = 1) THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'MAYBE ATO LINE '||G_LINE_REC.LINE_ID , 3 ) ;
          END IF;
          l_temp_ato_line_id := g_line_rec.line_id;
        END IF;


        BEGIN

          IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' AND
             g_line_rec.config_header_id is not NULL AND
             g_line_rec.config_header_id <> FND_API.G_MISS_NUM AND
             g_line_rec.configuration_id is not NULL AND
             g_line_rec.configuration_id <> FND_API.G_MISS_NUM
          THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'GET_ATO: PACK H NEW LOGIC MI ' || G_LINE_REC.CONFIG_HEADER_ID , 1 ) ;
                oe_debug_pub.add(  'CONFIGN ID ' || G_LINE_REC.CONFIGURATION_ID , 1 ) ;
            END IF;

            SELECT ato_config_item_id
            INTO   l_ato_config_item_id
            FROM   cz_config_details_v
            WHERE  config_hdr_id  = g_line_rec.config_header_id
            AND    config_rev_nbr = g_line_rec.config_rev_nbr
            AND    config_item_id = g_line_rec.configuration_id
            AND    inventory_item_id = g_line_rec.inventory_item_id;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'GET_ATO: MI ' || L_ATO_CONFIG_ITEM_ID , 1 ) ;
            END IF;

            IF l_ato_config_item_id is NOT NULL THEN
              SELECT line_id
              INTO   l_ato_line_id
              FROM   OE_ORDER_LINES_ALL OEOPT
              WHERE  line_id =
                     (SELECT line_id
                      FROM   oe_order_lines OEATO
                      WHERE  OEOPT.top_model_line_id = OEATO.top_model_line_id
                      AND    OEATO.configuration_id  = l_ato_config_item_id
                      AND    OEATO.open_flag = 'Y')
              AND    top_model_line_id = g_line_rec.top_model_line_id;

             ELSE
               IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('CONFIG_ITEM_ID NOT RETURNED FROM CZ');
               END IF;
              IF  g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION
                 AND
                 l_replenish_to_order_flag = 'Y' AND
                 l_build_in_wip_flag = 'Y'
                THEN
                IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'ATO ITEM UNDER PTO MODEL' , 1 ) ;
                END IF;
               RETURN g_line_rec.line_id;
              END IF;
            END IF;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'PTO+ATO SELECT '||L_ATO_LINE_ID , 1 ) ;
            END IF;

          ELSE

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'USE OE_ORDER_LINES' , 3 ) ;
            END IF;

            SELECT line_id
            INTO   l_ato_line_id
            FROM   OE_ORDER_LINES_ALL
            WHERE  top_model_line_id = g_line_rec.top_model_line_id
            AND    item_type_code = 'CLASS'
            AND    component_code =
                       SUBSTR( g_line_rec.component_code, 1,
                               LENGTH(component_code))
            AND    ato_line_id is not null
            AND    open_flag = 'Y'
            AND    component_code =
                         ( SELECT MIN(OEMIN.component_code)
                           FROM   OE_ORDER_LINES_ALL OEMIN
                           WHERE  OEMIN.top_model_line_id
                                  = g_line_rec.top_model_line_id
                           AND    OEMIN.component_code =
                                  SUBSTR( g_line_rec.component_code, 1,
                                          LENGTH( OEMIN.component_code))
                           AND OEMIN.ato_line_id is not null
                           AND OEMIN.open_flag = 'Y')
            AND (SUBSTR(g_line_rec.component_code,
                       LENGTH(component_code) + 1, 1) = '-' OR
                 SUBSTR(g_line_rec.component_code,
                       LENGTH(component_code) + 1, 1) is NULL);


            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'PTO+ATO SELECT '||L_ATO_LINE_ID , 1 ) ;
            END IF;
          END IF;

        EXCEPTION
          WHEN no_data_found THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'NO DATA FOUND PTO CASE '|| L_TEMP_ATO_LINE_ID , 3 ) ;
            END IF;

            -- ## 1820608 ato item under a top pto model
            -- should have line_id = ato_line_id, if ato_item is
            -- under a ato sub config, its ato_line_id = line_id
            -- of the ato sub config.

            IF  g_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION
                AND
                l_replenish_to_order_flag = 'Y' AND
                l_build_in_wip_flag = 'Y'
            THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'ATO ITEM UNDER PTO MODEL' , 1 ) ;
              END IF;
              RETURN g_line_rec.line_id;
            ELSE
              RETURN l_temp_ato_line_id;
            END IF;

          WHEN too_many_rows THEN
             -- Added for Bug-2367800
             FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_DUPLICATE_COMPONENT');
             FND_MESSAGE.Set_Token('ITEM', nvl(g_line_rec.ordered_item,g_line_rec.inventory_item_id));
             OE_Msg_Pub.Add;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'TOO MANY ROWS CASE '|| G_LINE_REC.INVENTORY_ITEM_ID , 1 ) ;
            END IF;
            RAISE;

          WHEN OTHERS THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ATO LINE EXCEPTION ' , 3 ) ;
            END IF;
            RAISE;
        END;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  '2. ATO LINE ID : '|| L_ATO_LINE_ID , 3 ) ;
      END IF;

      RETURN l_ato_line_id;

    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN ATO_LINE_ID AS NULL' , 1 ) ;
      END IF;
      RETURN null;
    END IF;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GG:LINE_ID : ' || G_LINE_REC.LINE_ID , 1 ) ;
      oe_debug_pub.add(  'GG:ATO LINE ID : ' || G_LINE_REC.ATO_LINE_ID , 1 ) ;
  END IF;

EXCEPTION

    WHEN TOO_MANY_ROWS THEN
	RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME     ,
    	        'Get_ATO_Line'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_ATO_line;

/*---------------------------------------------------------------------
 PROCEDURE Insert_into_set
 This procedure will insert children of model into fulfillment
 set id if the parent is part of a set.
 Parent might exists in multiple fulfillment sets,
 so get all the set_id's that
 parent belong to and insert the children in all sets.
---------------------------------------------------------------------*/
PROCEDURE Insert_Into_set
( p_line_id        IN   NUMBER
 ,p_child_line_id       IN   NUMBER
,x_return_status OUT NOCOPY VARCHAR2)

IS

 CURSOR parent_sets IS
 Select set_id
 From   oe_line_sets
 Where  line_id = p_line_id;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING INTO INSERT_INTO_SET' , 1 ) ;
      oe_debug_pub.add(  'TOP MODEL IS ' || P_LINE_ID , 1 ) ;
      oe_debug_pub.add(  'CHILD LINE IS ' || P_CHILD_LINE_ID , 1 ) ;
  END IF;
  FOR i IN parent_sets LOOP
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING INTO LOOP -SET' ||I.SET_ID , 1 ) ;
  END IF;



         OE_SET_UTIL.Create_Fulfillment_set
               (p_line_id => p_child_line_id,
                p_set_id  => i.set_id);



  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING FROM INSERT_INTO_SET' , 1 ) ;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_Into_set;


FUNCTION Get_Fulfilled_Quantity
RETURN NUMBER
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	RETURN NULL;

END Get_Fulfilled_Quantity;

 --Procedure to check change in item_type_code
PROCEDURE Check_Item_Type(p_line_rec OE_ORDER_PUB.Line_Rec_Type,
					 p_old_line_rec OE_ORDER_PUB.Line_Rec_Type,
					 p_item_type_code VARCHAR2)
					 IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING CHECK ITEM TYPE' ) ;
        oe_debug_pub.add(  'ITEM TYPE '|| P_ITEM_TYPE_CODE ) ;
    END IF;
   IF p_line_rec.operation = oe_globals.g_opr_update THEN
    IF (p_old_line_rec.item_type_code <> FND_API.G_MISS_CHAR AND
	   p_old_line_rec.item_type_code IS NOT NULL) THEN

	    IF NOT OE_GLOBALS.EQUAL(p_old_line_rec.item_type_code,
						   p_item_type_code) THEN

			 FND_MESSAGE.SET_NAME('ONT','OE_ITEM_TYPE_CONST');
			 OE_MSG_PUB.ADD;
			 IF l_debug_level  > 0 THEN
			     oe_debug_pub.add(  'ITEM_TYPE_CODE CONSTRAINED' ) ;
			 END IF;
			 RAISE FND_API.G_EXC_ERROR;

	    END IF;
     END IF;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ITEM_TYPE_CODE : OPERATION IS CREATE ' ) ;
   END IF;

END Check_Item_Type;

FUNCTION Get_Item_Type(p_line_rec OE_ORDER_PUB.Line_Rec_Type,
				   p_old_line_rec OE_ORDER_PUB.Line_Rec_Type)
RETURN VARCHAR2
IS
l_item_type_code   VARCHAR2(30) := NULL;
l_bom_item_type    VARCHAR2(30);
l_service_item_flag  VARCHAR2(1);
l_pick_components_flag VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN DEFAULTING: FUNCTION GET_ITEM_TYPE' , 1 ) ;
        oe_debug_pub.add(  'THE INV ITEM IS'||TO_CHAR ( G_LINE_REC.INVENTORY_ITEM_ID ) , 1 ) ;
--6933507
        oe_debug_pub.add(  '    line_category_code = '|| p_line_rec.line_category_code , 1 ) ;
        oe_debug_pub.add(  '    retrobill_request_id = '|| p_line_rec.retrobill_request_id , 1 ) ;
        oe_debug_pub.add(  '    item_type_code = '|| p_line_rec.item_type_code , 1 ) ;
--6933507
    END IF;

    IF ( g_line_rec.inventory_item_id is NULL  OR
       g_line_rec.inventory_item_id = FND_API.G_MISS_NUM  )
    THEN
	-- Bug 4721305 condition added to ignore when inventory item is nulled
	 IF p_line_rec.ITEM_TYPE_CODE IS NOT NULL AND
		p_line_rec.ITEM_TYPE_CODE <> FND_API.G_MISS_CHAR THEN
	  Check_Item_Type(p_line_rec,
				   p_old_line_rec,
				   NULL);
         END IF;
       RETURN NULL;
    END IF;


    IF p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE THEN
          RETURN OE_GLOBALS.G_ITEM_STANDARD;
    --- BUG#6933507 : retrun STANDARD in case of retrobill SO (type = ORDER)
    ELSIF  p_line_rec.line_category_code =  'ORDER'
            and p_line_rec.retrobill_request_id is NOT NULL
            and p_line_rec.retrobill_request_id <> FND_API.G_MISS_NUM THEN

          RETURN OE_GLOBALS.G_ITEM_STANDARD;
    --- BUG#6933507
    ELSIF p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG OR
          p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED THEN
          RETURN p_line_rec.item_type_code;
    END IF;


    OE_Order_Cache.Load_Item (g_line_rec.inventory_item_id
                                      ,g_line_rec.ship_from_org_id);
    l_bom_item_type := OE_ORDER_CACHE.g_item_rec.bom_item_type;
    l_service_item_flag := OE_ORDER_CACHE.g_item_rec.service_item_flag;
    l_pick_components_flag := OE_ORDER_CACHE.g_item_rec.pick_components_flag;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BOM ITEM TYPE IS ' || L_BOM_ITEM_TYPE ) ;
    END IF;

    IF l_bom_item_type = 1
    -- MODEL items and ato's under pto have bom_item_type = 1
    THEN

    IF nvl(g_line_rec.top_model_line_id, 0) <> nvl(g_line_rec.line_id, 0)
        -- OR
        -- nvl(g_line_rec.top_model_line_index, 0) <> nvl(g_line_rec.line_index,0)
        -- line_rec dose not have line_index
    THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETURNING CLASS AS THE ITEM TYPE FOR ATO SUBCONFIG' , 1 ) ;
       END IF;
        --Procedure to check change in item_type_code
	  Check_Item_Type(p_line_rec,
				   p_old_line_rec,
				   OE_GLOBALS.G_ITEM_CLASS);
        RETURN OE_GLOBALS.G_ITEM_CLASS;
    END IF;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETURNING MODEL AS THE ITEM TYPE' , 1 ) ;
       END IF;
        --Procedure to check change in item_type_code
       Check_Item_Type(p_line_rec,
				   p_old_line_rec,
				   OE_GLOBALS.G_ITEM_MODEL);
    RETURN OE_GLOBALS.G_ITEM_MODEL;

    ELSIF l_bom_item_type = 2
    THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'RETURNING CLASS AS THE ITEM TYPE' , 1 ) ;
	   END IF;
        -- Only CLASS items have bom_item_type = 2
        --Procedure to check change in item_type_code
	  Check_Item_Type(p_line_rec,
				   p_old_line_rec,
        			   OE_GLOBALS.G_ITEM_CLASS);
        RETURN OE_GLOBALS.G_ITEM_CLASS;

    ELSIF l_bom_item_type = 4 and
		l_service_item_flag = 'N'
    THEN

	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'BOM 4 AND FLAG = N' ) ;
	   END IF;
       -- Following 3 items can have bom_item_type = 4 :
       -- STANDARD item, OPTION item and a KIT
       -- We will distinguish an item to be a kit by seeing if
       -- it has a record in bom_bill_of_materials.
       -- All options MUST have the top_model_line_id populated
       -- before they come to defaulting. Thus we use it to distinguish
       -- between a standard and an option item.
       -- ato_item's item_type_code will be standard

         IF l_pick_components_flag = 'Y' THEN
            l_item_type_code := OE_GLOBALS.G_ITEM_KIT;
         ELSIF (g_line_rec.top_model_line_id is not null AND
                   g_line_rec.top_model_line_id <> FND_API.G_MISS_NUM)
         THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'GET_ITEM_TYPE NO DATA FOUND , BOM_ITEM_TYPE : 4' , 1 ) ;
             END IF;
             l_item_type_code := OE_GLOBALS.G_ITEM_OPTION;
         ELSE
             l_item_type_code := OE_GLOBALS.G_ITEM_STANDARD;
         END IF;

	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' BEFORE CALLING CHECK 1' ) ;
	 END IF;
        --Procedure to check change in item_type_code
	  Check_Item_Type(p_line_rec,
				   p_old_line_rec,
				   l_item_type_code);
         RETURN l_item_type_code;

    ELSIF l_service_item_flag = 'Y' and
		   l_bom_item_type = 4
    THEN
		 IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  'SERVICE ITEM FLAG IS: ' || L_SERVICE_ITEM_FLAG ) ;
		 END IF;
        --Procedure to check change in item_type_code
	  	Check_Item_Type(p_line_rec,
					 p_old_line_rec,
					 OE_GLOBALS.G_ITEM_SERVICE);
       RETURN OE_GLOBALS.G_ITEM_SERVICE;

    END IF;

    RETURN null;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING DEFAULTING: FUNCTION GET_ITEM_TYPE' ) ;
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  ' BEFORE CALLING CHECK 4' ) ;
	   END IF;
         l_item_type_code := OE_GLOBALS.G_ITEM_STANDARD;
        --Procedure to check change in item_type_code
	  	Check_Item_Type(p_line_rec,
					 p_old_line_rec,
					 l_item_type_code);
         RETURN l_item_type_code;

    WHEN OTHERS THEN

        -- 4594675
        /*
    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME ,
    	        'Get_Item_Type'
	    );
    	END IF;
        */

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Item_Type;


FUNCTION Get_Line
RETURN NUMBER
IS
l_line_id	NUMBER := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    SELECT  OE_ORDER_LINES_S.NEXTVAL
    INTO    l_line_id
    FROM    DUAL;

    RETURN l_line_id;

END Get_Line;

FUNCTION Get_Orig_Sys_Doc_Ref
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   OE_ORDER_CACHE.Load_Order_Header(g_line_rec.header_id);
   RETURN (OE_ORDER_CACHE.g_header_rec.Orig_Sys_Document_Ref);

END Get_Orig_Sys_Doc_Ref;


FUNCTION Get_Org
RETURN NUMBER
IS
l_Org_id	NUMBER := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  OE_GLOBALS.Set_Context;
  l_org_id := OE_GLOBALS.G_ORG_ID;

  RETURN l_Org_Id;

END Get_Org;

FUNCTION Get_Line_Category(p_line_rec OE_ORDER_PUB.Line_Rec_Type,
					  p_old_line_rec OE_ORDER_PUB.Line_Rec_Type)
RETURN VARCHAR2
IS
l_order_category varchar2(30);
l_category varchar2(30) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN DEFAULTING: FUNCTION GET_LINE_CATEGORY' , 1 ) ;
    END IF;

  /*  replaced with the following IF for 2421909
  IF (p_line_rec.operation = oe_globals.g_opr_create) and
     (p_line_rec.line_type_id IS NULL OR
      p_line_rec.line_type_id = FND_API.G_MISS_NUM) THEN
  */

  IF (p_line_rec.line_type_id IS NULL OR  -- 2421909
      p_line_rec.line_type_id = FND_API.G_MISS_NUM) THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AK IN DEFAULTING: WHEN LINE_TYPE_ID IS NULL' , 1 ) ;
        oe_debug_pub.add(  'AK IN DEFAULTING:' || P_LINE_REC.HEADER_ID , 1 ) ;
    END IF;

    /* Replaced with the following IF statement for 2421909
    OE_ORDER_CACHE.Load_Order_Header(p_line_rec.header_id);
    l_order_category := OE_ORDER_CACHE.g_header_rec.ORDER_CATEGORY_CODE;
    */

    IF (p_line_rec.operation = oe_globals.g_opr_create)
              THEN  -- 2421909ND

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AK IN DEFAULTING: OPERATION IS CREATE' , 1 ) ;
      END IF;
      OE_ORDER_CACHE.Load_Order_Header(p_line_rec.header_id);
      l_order_category := OE_ORDER_CACHE.g_header_rec.ORDER_CATEGORY_CODE;
    ELSE
      l_order_category := p_old_line_rec.line_category_code;
    END IF;

  ELSE

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AK IN DEFAULTING: WHEN LINE_TYPE_ID IS NOT NULL' , 1 ) ;
    END IF;
    OE_ORDER_CACHE.Load_Line_Type(p_line_rec.line_type_id);
    l_order_category := OE_ORDER_CACHE.g_line_type_rec.ORDER_CATEGORY_CODE;

  END IF;

    IF l_order_category = 'RETURN' THEN
	l_category := 'RETURN';
    ELSE
	l_category := 'ORDER';
    END IF;
        --retro{In the case of price increase for original line, the initial
        --retrobill line will be created with line_category return and has to be
        --updated to order
        IF (p_line_rec.operation = oe_globals.g_opr_update AND
            p_old_line_rec.line_category_code = 'RETURN' AND
            p_line_rec.line_category_code = 'ORDER' AND
            p_line_rec.order_source_id = 27 ) THEN
           l_category := 'ORDER';
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'Retrobill price increase Line Category ' || L_CATEGORY ) ;
           END IF;
        END IF;
      --retro}
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE CATEGORY: ' || L_CATEGORY ) ;
    END IF;

    IF p_line_rec.operation = oe_globals.g_opr_update THEN

	IF (p_old_line_rec.line_category_code <> FND_API.G_MISS_CHAR AND
	   p_old_line_rec.line_category_code IS NOT NULL) THEN

	   IF NOT OE_GLOBALS.EQUAL(p_old_line_rec.line_category_code,
						  l_category) THEN
        --retro{In the case of price increase for original line, the initial
        --retrobill line will be created with line_category return and has to be
        --updated to order.The original flow doesn't allow and raises exception,To
        --prevent the exception a if loop is added in the case of retrobilling
          IF (p_line_rec.operation = oe_globals.g_opr_update AND
            p_old_line_rec.line_category_code = 'RETURN' AND
            p_line_rec.line_category_code = 'ORDER' AND
            p_line_rec.order_source_id = 27 AND
            p_line_rec.retrobill_request_id is not null) THEN
                      null;
        else
			FND_MESSAGE.SET_NAME('ONT', 'OE_LINE_CAT_CONST');
			OE_MSG_PUB.ADD;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'LINE CATEGORY CONSTRINED' ) ;
			END IF;
			RAISE FND_API.G_EXC_ERROR;
        END IF;
        END IF;

     END IF;

    END IF;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN DEFAULTING: RETURNLINECATEROY' , 1 ) ;
    END IF;
    RETURN l_category;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN DEFAULTING: NO DATAFOUND' , 1 ) ;
    END IF;
         l_category := 'ORDER';
    	    IF p_line_rec.operation = oe_globals.g_opr_update THEN

	       IF (p_old_line_rec.line_category_code <> FND_API.G_MISS_CHAR AND
	           p_old_line_rec.line_category_code IS NOT NULL) THEN

	           IF NOT OE_GLOBALS.EQUAL(p_old_line_rec.line_category_code,
						  l_category) THEN
		        	FND_MESSAGE.SET_NAME('ONT', 'OE_LINE_CAT_CONST');
			        OE_MSG_PUB.ADD;
		        	IF l_debug_level  > 0 THEN
		        	    oe_debug_pub.add(  'LINE CATEGORY CONSTRINED' ) ;
		        	END IF;
		        	RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;
         END IF;
         RETURN l_category;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME ,
    	        'Line_Category'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Line_Category;



FUNCTION Get_Line_Number
RETURN NUMBER
IS
l_line_number	NUMBER := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN PKG OE_DEFAULT_LINE: FUNCTION GET_LINE_NUMBER' ) ;
    END IF;

    IF g_line_rec.top_model_line_id IS NULL
        OR g_line_rec.top_model_line_id = FND_API.G_MISS_NUM
        OR g_line_rec.line_id = g_line_rec.top_model_line_id
    THEN

       SELECT  NVL(MAX(LINE_NUMBER)+1,1)
       INTO    l_line_number
       FROM    OE_ORDER_LINES_ALL
       WHERE   HEADER_ID = g_line_rec.header_id;

       RETURN (l_line_number);

    ELSE

				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'LOADING TOP_MODEL_LINE_ID: ' || G_LINE_REC.TOP_MODEL_LINE_ID ) ;
				END IF;
    	OE_Order_Cache.Load_top_model_line
			(g_line_rec.top_model_line_id );
        l_line_number := OE_Order_Cache.g_top_model_line_rec.line_number;

        RETURN (l_line_number);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LOADDED TOP_MODEL_LINE_ID ' ) ;
    END IF;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_Line_Number'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Line_Number;

FUNCTION Get_Latest_Acceptable_Date(p_request_date IN DATE)
RETURN DATE
IS
l_latest_acceptable_date  DATE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   OE_ORDER_CACHE.Load_Order_Header(g_line_rec.header_id);

   l_latest_acceptable_date := p_request_date +
             OE_ORDER_CACHE.g_header_rec.latest_schedule_limit;

   RETURN l_latest_acceptable_date;

EXCEPTION
   WHEN OTHERS THEN
      l_latest_acceptable_date := null;
      RETURN l_latest_acceptable_date;
END Get_Latest_Acceptable_Date;

FUNCTION Get_Pricing_Quantity
RETURN NUMBER
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF g_line_rec.ordered_quantity = FND_API.G_MISS_NUM then
	RETURN NULL;
    ELSE
	IF g_line_rec.pricing_quantity_uom is not null
          AND g_line_rec.pricing_quantity_uom <> FND_API.G_MISS_CHAR
        THEN
	  RETURN (OE_Order_Misc_Util.convert_uom(g_line_rec.inventory_item_id,
				g_line_rec.order_quantity_uom,
				g_line_rec.pricing_quantity_uom,
				g_line_rec.ordered_quantity));
	ELSE
	  RETURN NULL;
	END IF;
    END IF;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_Pricing_Quantity'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Pricing_Quantity;

FUNCTION Get_Shipment_Number
RETURN NUMBER
IS
l_ship_number 	NUMBER := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN PKG OE_DEFAULT_LINE: FUNCTION GET_SHIPMENT_NUMBER' ) ;
    END IF;

    IF g_line_rec.top_model_line_id IS NULL
    OR g_line_rec.top_model_line_id = FND_API.G_MISS_NUM
    OR g_line_rec.line_id = g_line_rec.top_model_line_id
    THEN

      -- Bug 1929163: shipment number is 1 for non-split lines
      IF g_line_rec.split_from_line_id IS NULL
         OR g_line_rec.split_from_line_id = FND_API.G_MISS_NUM THEN

         l_ship_number := 1;

      ELSE

       SELECT  NVL(MAX(SHIPMENT_NUMBER)+1,1)
       INTO    l_ship_number
       FROM    OE_ORDER_LINES
       WHERE   HEADER_ID = g_line_rec.header_id
       AND     LINE_NUMBER = g_line_rec.line_number;

      END IF;

      RETURN l_ship_number;

    ELSE

    	OE_Order_Cache.Load_Top_Model_Line(g_line_rec.top_model_line_id );
        l_ship_number := OE_ORDER_CACHE.g_top_model_line_rec.shipment_number;
        RETURN l_ship_number;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_Shipment_Number'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Shipment_Number;

FUNCTION Get_Shipping_Interfaced
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    RETURN 'N';

END Get_Shipping_Interfaced;

FUNCTION Get_Source_Type(p_source_type       IN VARCHAR2,
					p_line_type_id      IN NUMBER)
RETURN VARCHAR2
IS
l_source_type  VARCHAR2(30) := OE_GLOBALS.G_SOURCE_INTERNAL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'DEFAULTING SOURCE TYPE' ) ;
   END IF;

   IF p_line_type_id is not null AND
      p_line_type_id <> FND_API.G_MISS_NUM THEN

      BEGIN

        OE_ORDER_CACHE.Load_Line_Type(p_line_type_id);
        l_source_type := OE_ORDER_CACHE.g_line_type_rec.ship_source_type_code;

        IF l_source_type is null THEN
           RETURN p_source_type;
        END IF;

        IF l_source_type <> OE_GLOBALS.G_SOURCE_EXTERNAL AND
           l_source_type <> OE_GLOBALS.G_SOURCE_INTERNAL THEN
           l_source_type := p_source_type;
        END IF;

      EXCEPTION
         WHEN OTHERS THEN
              l_source_type := p_source_type;
      END;
   END IF;


   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'DEFAULTING SOURCE TYPE AS || L_SOURCE_TYPE' ) ;
   END IF;

   IF l_source_type <> p_source_type THEN
       RETURN l_source_type;
   ELSE
       RETURN p_source_type;
   END IF;

END Get_Source_Type;


FUNCTION Get_Shippable
( p_line_id            IN   NUMBER
 ,p_inventory_item_id  IN   NUMBER
 ,p_ship_from_org_id   IN   NUMBER
 ,p_ato_line_id        IN   NUMBER
 ,p_item_type_code     IN   VARCHAR2)
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF ( p_inventory_item_id is NULL  OR
       p_inventory_item_id = FND_API.G_MISS_NUM  )
   THEN
       RETURN NULL;
   END IF;

   IF (p_item_type_code = OE_GLOBALS.G_ITEM_CONFIG) THEN
       RETURN 'Y';
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '1 , ATO_LINE_ID: '|| P_ATO_LINE_ID , 1 ) ;
   END IF;


   IF (p_ato_line_id is not null) AND
      (p_ato_line_id <> FND_API.G_MISS_NUM)
   THEN

      -- ##1820608, ato_item can be under a pto model.
      IF NOT OE_GLOBALS.Equal(p_item_type_code,
                              OE_GLOBALS.G_ITEM_STANDARD) AND
         NOT (p_item_type_code = OE_GLOBALS.G_ITEM_OPTION AND
              p_line_id = p_ato_line_id )
      THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ATO MODEL OR OPTION' , 1 ) ;
       END IF;
       RETURN 'N';

      END IF;

   END IF;


   OE_Order_Cache.Load_Item (p_inventory_item_id
                            ,p_ship_from_org_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SHIPPABLE FLAG: ' || OE_ORDER_CACHE.G_ITEM_REC.SHIPPABLE_ITEM_FLAG , 1 ) ;
   END IF;

   RETURN OE_ORDER_CACHE.g_item_rec.shippable_item_flag;

END Get_Shippable;



FUNCTION Get_SMC_Flag
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'DEFAULTING SMC FLAG ' , 1 ) ;
   END IF;

   IF ( g_line_rec.inventory_item_id is NULL  OR
       g_line_rec.inventory_item_id = FND_API.G_MISS_NUM  )
   THEN
       RETURN NULL;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SMC1 FLAG VALUE IS NULL' , 1 ) ;
       END IF;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'GET SMC: TOP MODEL LINE ID :' || G_LINE_REC.TOP_MODEL_LINE_ID , 1 ) ;
   END IF;

   -- SMC PTO flag is only for PTO's and Kits

   IF (g_line_rec.top_model_line_id  = g_line_rec.line_id) AND
      (g_line_rec.top_model_line_id <> nvl(g_line_rec.ato_line_id,0)) THEN
    	OE_Order_Cache.Load_Item (g_line_rec.inventory_item_id
                                 ,g_line_rec.ship_from_org_id);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SMC FLAG ' || OE_ORDER_CACHE.G_ITEM_REC.SHIP_MODEL_COMPLETE_FLAG , 3 ) ;
        END IF;
       RETURN OE_ORDER_CACHE.g_item_rec.ship_model_complete_flag;

   ELSIF
     g_line_rec.ship_model_complete_flag is not null AND
     g_line_rec.ship_model_complete_flag <> FND_API.G_MISS_CHAR AND
     g_line_rec.top_model_line_id is not NULL
   THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SMC4 FLAG ' || G_LINE_REC.SHIP_MODEL_COMPLETE_FLAG , 3 ) ;
     END IF;
     return g_line_rec.ship_model_complete_flag;
   ELSE
       RETURN null;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SMC5 FLAG VALUE IS NULL' , 3 ) ;
       END IF;
   END IF;

END Get_SMC_Flag;



FUNCTION Get_Defaulting_Invoice_Line
(p_return_context IN VARCHAR2,
p_return_attribute1 IN VARCHAR2,
p_return_attribute2 IN VARCHAR2
) RETURN NUMBER
IS
l_invoice_line_id NUMBER := NULL;
l_order_line_id NUMBER := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF (p_return_context = 'INVOICE') THEN

     RETURN to_number(p_return_attribute2);

  ELSIF p_return_context in ('SERIAL') THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ATTR1 ' || P_RETURN_ATTRIBUTE1 , 1 ) ;
         oe_debug_pub.add(  'ATTR2 ' || P_RETURN_ATTRIBUTE2 , 1 ) ;
     END IF;
     BEGIN

         SELECT l.line_id
         INTO   l_order_line_id
         FROM   oe_order_lines l,
                mtl_unit_transactions_all_v u,
                mtl_material_transactions m
         WHERE  l.Inventory_item_id = to_number(p_return_attribute1)
         AND    m.transaction_source_type_id=2
         AND    m.trx_source_line_id=l.line_id
         AND    m.transaction_id = u.transaction_id
         AND    u.serial_number = p_return_attribute2
         AND    u.inventory_item_id = to_number(p_return_attribute1)
         AND    rownum = 1;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LINE ' || TO_CHAR ( L_ORDER_LINE_ID ) , 1 ) ;
         END IF;

         IF l_order_line_id IS NOT NULL THEN
             SELECT /* MOAC_SQL_CHANGE */  rctl.customer_trx_line_id
             INTO   l_invoice_line_id
             FROM   ra_customer_trx_lines_all rctl,
                    ra_customer_trx rct,
                    ar_lookups arlup
             WHERE  rct.status_trx = arlup.lookup_code
             AND    arlup.lookup_type = 'INVOICE_TRX_STATUS'
             AND    rct.customer_trx_id = rctl.customer_trx_id
             AND    rctl.interface_line_context='ORDER ENTRY'
             AND    rctl.interface_line_attribute6 = to_char(l_order_line_id)
             AND    rctl.line_type = 'LINE'
             AND    rctl.interface_line_attribute11 = '0' --Bug2721441
	     AND    rctl.org_id=rct.org_id
             AND    rownum = 1;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'INV LINE ' || TO_CHAR ( L_INVOICE_LINE_ID ) , 1 ) ;
             END IF;
         END IF;
         RETURN l_invoice_line_id;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
          -- not invoiced yet, return NULL
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN NO DATA ' , 1 ) ;
         END IF;
         RETURN NULL;
     END;

  ELSIF p_return_context in ('PO','ORDER') THEN

    BEGIN
       SELECT /* MOAC_SQL_CHANGE */ rctl.customer_trx_line_id
       INTO   l_invoice_line_id
       FROM   ra_customer_trx_lines_all rctl,
              ra_customer_trx rct,
              ar_lookups arlup
       WHERE  rct.status_trx = arlup.lookup_code
       AND    arlup.lookup_type = 'INVOICE_TRX_STATUS'
       AND    rct.customer_trx_id = rctl.customer_trx_id
       AND    rctl.interface_line_context='ORDER ENTRY'
       AND    rctl.interface_line_attribute6 = p_return_attribute2
       AND    rctl.line_type = 'LINE'
       AND    rctl.interface_line_attribute11 = '0' --Bug2721441
       AND    rctl.org_id=rct.org_id
       AND    rownum = 1;
       RETURN l_invoice_line_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
          -- not invoiced yet, return NULL
          RETURN NULL;
    END;

  END IF;
  RETURN NULL;
END Get_Defaulting_Invoice_Line;

FUNCTION Get_Def_Invoice_Line_Int
(p_return_context IN VARCHAR2,
p_return_attribute1 IN VARCHAR2,
p_return_attribute2 IN VARCHAR2,
p_sold_to_org_id    IN NUMBER,
p_curr_code     IN VARCHAR2,
p_ref_line_id OUT NOCOPY NUMBER

) RETURN NUMBER
IS
l_invoice_line_id NUMBER := NULL;
l_order_line_id NUMBER := NULL;
l_order_number   NUMBER;
l_trxn_type_name VARCHAR2(30);
l_lot_control_flag VARCHAR2(1);
l_inventory_item_id NUMBER := TO_NUMBER(p_return_attribute1);

CURSOR C_REF_LINE(attr1 VARCHAR2, attr2 VARCHAR2) IS
SELECT /* MOAC_SQL_CHANGE */ DISTINCT l.line_id line_id
FROM oe_order_lines_all l,
     mtl_unit_transactions_all_v u,
     mtl_material_transactions m,
     oe_order_headers h
WHERE l.Inventory_item_id = to_number(attr1)
AND m.transaction_source_type_id=2
AND m.trx_source_line_id=l.line_id
AND m.transaction_id = u.transaction_id
AND m.transaction_type_id IN (33,34,50,62)
AND u.serial_number = attr2
AND u.inventory_item_id = to_number(attr1)
AND l.ship_from_org_id = m.organization_id
AND l.inventory_item_id = m.inventory_item_id
AND l.header_id = h.header_id
AND h.sold_to_org_id = p_sold_to_org_id
-- 6916542 AND h.transactional_curr_code = p_curr_code
AND l.cancelled_flag <> 'Y'
order by l.line_id;

CURSOR C_LOT_REF_LINE(attr1 VARCHAR2, attr2 VARCHAR2) IS
SELECT /* MOAC_SQL_CHANGE */ DISTINCT l.line_id line_id
FROM mtl_material_transactions m,
        mtl_transaction_lot_val_v t,
        mtl_unit_transactions_all_v u,
        oe_order_lines_all l,
        oe_order_headers h
WHERE u.Inventory_item_id = to_number(attr1)
AND u.ORGANIZATION_ID = t.ORGANIZATION_ID
AND u.serial_number = attr2
AND t.serial_transaction_id = u.transaction_id
AND m.transaction_id = t.transaction_id
AND t.ORGANIZATION_ID = u.ORGANIZATION_ID
AND t.inventory_item_id = u.inventory_item_id
AND m.INVENTORY_ITEM_ID = l.inventory_item_id
AND m.ORGANIZATION_ID = l.ship_from_org_id
AND m.trx_source_line_id=l.line_id
AND m.transaction_source_type_id = 2
AND m.transaction_type_id IN (33,34,50,62)
AND l.cancelled_flag <> 'Y'
AND l.header_id = h.header_id
AND h.sold_to_org_id = p_sold_to_org_id
-- 6916542 AND h.transactional_curr_code = p_curr_code
order by l.line_id;

-- bug#5452691:
-- Adding cancelled_flag condition to filter out all the cancelled lines.
-- otherwise no-data-found error will be thrown when the cursor is iterated
-- and removed it from query when cursor is opened.

CURSOR C_LOT_SERIAL(p_serial_num VARCHAR2) IS
SELECT ls.line_id,ls.line_set_id,ls.from_serial_number,ls.to_serial_number
FROM   oe_lot_serial_numbers ls, oe_order_lines ol
WHERE  ls.line_id = ol.line_id
AND    nvl(ol.cancelled_flag,'N') <> 'Y'
AND    (ls.from_serial_number = p_serial_num OR ls.to_serial_number = p_serial_num );
/*
CURSOR C_LOT_SERIAL(p_serial_num VARCHAR2) IS
SELECT line_id,line_set_id,from_serial_number,to_serial_number
FROM oe_lot_serial_numbers
WHERE from_serial_number = p_serial_num
OR to_serial_number = p_serial_num;
*/
-- bug#5452691

CURSOR C_ORDER_INFO(ord_line_id NUMBER) IS
SELECT /* MOAC_SQL_CHANGE */ ooh.order_number, ott.name
FROM   oe_order_lines_all ool,
       oe_order_headers ooh,
       oe_transaction_types_tl ott
WHERE  ool.line_id             = ord_line_id
AND    ooh.header_id           = ool.header_id
AND    ott.transaction_type_id = ooh.order_type_id
-- 6916542 AND    ooh.transactional_curr_code = p_curr_code
AND    ooh.sold_to_org_id = p_sold_to_org_id
AND    ott.language            =
      (select language_code
       from   fnd_languages
       where  installed_flag = 'B');

-- With the addition of logic to support lot-serial controlled item
-- we are adding this new code to figure out the line_id for the
-- specified item and serial number combination.

CURSOR control_codes IS
SELECT decode(msi.lot_control_code,2,'Y','N')
  FROM mtl_system_items msi
 WHERE msi.inventory_item_id = l_inventory_item_id
   AND msi.organization_id =
              OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID');

TYPE line_tbl_type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
l_line_tbl line_tbl_type;
l_ref_line_tbl line_tbl_type;
l_index1  NUMBER;
l_index2  NUMBER;
l_match  VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ATTR1 ' || P_RETURN_ATTRIBUTE1 , 1 ) ;
      oe_debug_pub.add(  'ATTR2 ' || P_RETURN_ATTRIBUTE2 , 1 ) ;
  END IF;

  IF (p_return_context = 'INVOICE') THEN
    BEGIN
/* Modified the following query to put the ivoice currency check for the bug  6916542 */

       SELECT /* MOAC_SQL_CHANGE */ to_number(rctl.interface_line_attribute6)
       INTO p_ref_line_id
       FROM ra_customer_trx_lines_all rctl,
            ra_customer_trx_all rct,
            oe_order_lines_all l,
            oe_order_headers h
       WHERE  to_number(p_return_attribute2) = rctl.customer_trx_line_id
       and   rctl.customer_trx_id           = rct.customer_trx_id
       AND l.line_id = rctl.interface_line_attribute6
       AND l.header_id = h.header_id
       AND p_curr_code = rct.invoice_currency_code
       AND h.sold_to_org_id = p_sold_to_org_id
       -- 6916542 AND h.transactional_curr_code = p_curr_code
       and rctl.org_id=h.org_id;

    EXCEPTION

       WHEN OTHERS THEN
          -- this should not be possible
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ERROR WHILE GETTING THE REFERENCE LINE FOR THE INVOICE LINE' , 2 ) ;
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME          ,
                'Get_Def_Invoice_Line_Int'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;

    RETURN to_number(p_return_attribute2);

  ELSIF p_return_context in ('SERIAL') THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN SERIAL ' ) ;
      END IF;
      -- Check to find whether the item is LOT-SERIAL controlled

      OPEN control_codes;
      FETCH control_codes INTO l_lot_control_flag;
      IF control_codes%notfound THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      CLOSE control_codes;

     BEGIN
         IF l_lot_control_flag = 'Y' THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN LOT-SERIAL ' ) ;
         END IF;

         -- If the item is LOT-SERIAL Controlled

             l_index2:=1;
             FOR C_LINE IN C_LOT_REF_LINE(p_return_attribute1,
                                          p_return_attribute2)
             LOOP
                 l_line_tbl(l_index2) := C_LINE.line_id;
                 l_index2:= l_index2+1;
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'IN LOT-SERIAL12 ' ) ;
                 END IF;

                 -- Check to see if any referenced return exists for the line.
                 l_index1 := 0;
                 SELECT count(*)
                 INTO   l_index1
                 FROM OE_ORDER_LINES
                 WHERE reference_line_id = C_LINE.line_id
                 AND line_category_code = 'RETURN'
                 AND cancelled_flag <> 'Y';

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'IN LOT-SERIAL2 '||TO_CHAR ( L_INDEX1 ) ) ;
                 END IF;
                 -- If there is no referenced return for this line then return
                 -- this line as a referenced_line_id.

                 IF l_index1 = 0 THEN
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'IN SERIAL3 '||TO_CHAR ( L_INDEX1 ) ) ;
                    END IF;
                     l_order_line_id := C_LINE.line_id;
                     GOTO GET_INVOICE_LINE;
                 END IF;
             END LOOP;

         ELSE
             -- If the item is LOT Controlled
             l_index2:=1;
             FOR C_LINE IN C_REF_LINE(p_return_attribute1, p_return_attribute2)LOOP
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'IN SERIAL1 ' ) ;
             END IF;
                 l_line_tbl(l_index2) := C_LINE.line_id;
                 l_index2:= l_index2+1;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'IN SERIAL12 ' ) ;
             END IF;

                 -- Check to see if any referenced return exists for the line.
                 l_index1 := 0;
                 SELECT count(*)
                 INTO   l_index1
                 FROM OE_ORDER_LINES
                 WHERE reference_line_id = C_LINE.line_id
                 AND line_category_code = 'RETURN'
                 AND cancelled_flag <> 'Y';

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'IN SERIAL2 '||TO_CHAR ( L_INDEX1 ) ) ;
             END IF;
             -- If there is no referenced return for this line then return
             -- this line as a referenced_line_id.

                 IF l_index1 = 0 THEN
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'IN SERIAL3 '||TO_CHAR ( L_INDEX1 ) ) ;
                 END IF;
                     l_order_line_id := C_LINE.line_id;
                     GOTO GET_INVOICE_LINE;
                 END IF;
             END LOOP;
         END IF; -- IF item is LOT-SERIAL controlled.

         -- If there are no outbound lines which refers the entered Serial
         -- Number then raise error with message.

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN SERIAL4 '||TO_CHAR ( L_LINE_TBL.COUNT ) ) ;
         END IF;
         IF l_line_tbl.count = 0 THEN
             FND_Message.Set_Name('ONT', 'OE_NO_LINES_FOR_SERIAL_NUMBER');
             oe_msg_pub.add;
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- For all outbound lines which are referring to this serial number,
         -- one or more referenced RMA exists.

         l_index2 := 1;

         -- Check the OE_LOT_SERIAL_NUMBERS table for the entered Serial Number.

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN SERIAL5 ' ) ;
         END IF;
         FOR C2 IN C_LOT_SERIAL(p_return_attribute2) LOOP

         -- If record exists in oe_lot_serial_numbers for the entered SN,
         -- check the line_set_id on it. There will be a value for line_set_id
         -- if the RMA line has got split. Get the reference line_id from the
         -- following queries.

             IF C2.line_set_id is not null THEN
                 select distinct reference_line_id
                 into l_ref_line_tbl(l_index2)
                 from oe_line_sets a,
                      oe_order_lines b
                 where a.set_id = C2.line_set_id
                 and a.line_id = b.line_id
                 and b.cancelled_flag <> 'Y';
             ELSE
                 select reference_line_id
                 into l_ref_line_tbl(l_index2)
                 from oe_order_lines
                 where line_id = C2.line_id;
-- bug#5452691
--                 and cancelled_flag <> 'Y';
             END IF;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'IN SERIAL6 THE REF LINE IS '|| TO_CHAR ( L_REF_LINE_TBL ( L_INDEX2 ) ) ) ;
             END IF;
             l_index2 := l_index2+1;
         END LOOP;

         -- There can not be more than one outbound line referring the entered
         -- SN and no RMA referring it.

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN SERIAL7 ' ) ;
         END IF;
         IF l_ref_line_tbl.COUNT = 0 AND
            l_line_tbl.count > 1 THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN SERIAL71 ' ) ;
         END IF;
             FND_Message.Set_Name('ONT', 'OE_DUPLICATE_LINES_FOR_SAME_SN');
             oe_msg_pub.add;
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN SERIAL8 ' ) ;
         END IF;
         IF l_ref_line_tbl.COUNT = 0 AND
            l_line_tbl.count = 1 THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN SERIAL81 ' ) ;
         END IF;
             l_order_line_id := l_line_tbl(1);
         END IF;

         -- Check for the outbound line referring the entered SN and
         -- which is not returned yet

         l_index1 := 0;
         l_index2 := 0;

         IF l_ref_line_tbl.COUNT > 0 THEN
             l_index1 := l_line_tbl.FIRST;
             WHILE l_index1 IS NOT NULL LOOP
                 l_match := 'N';
                 l_index2 := l_ref_line_tbl.FIRST;
                 WHILE l_index2 IS NOT NULL LOOP
                     IF l_line_tbl(l_index1) = l_ref_line_tbl(l_index2)
                     THEN
                         l_match := 'Y';
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'MATCH FOUND ' ) ;
                         END IF;
                         GOTO END_OF_INDEX1_LOOP;
                     END IF;
                     l_index2 := l_ref_line_tbl.NEXT(l_index2);
                 END LOOP;
                 IF l_match = 'N' THEN
                     l_order_line_id := l_line_tbl(l_index1);
                     GOTO GET_INVOICE_LINE;
                 END IF;
                 << END_OF_INDEX1_LOOP >>
                 l_index1 := l_line_tbl.NEXT(l_index1);
             END LOOP;
         END IF;

         << GET_INVOICE_LINE >>
         -- oe_debug_pub.add('Line ' || to_char(l_order_line_id),1);

         -- If there is no valid outbound line to be referenced for the entered
         -- SN then raise error.

         IF l_order_line_id IS NULL THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'NO LINES AVAILABLE FOR RETURN' ) ;
             END IF;
             FND_Message.Set_Name('ONT', 'OE_NO_LINES_FOR_SERIAL_NUMBER');
             oe_msg_pub.add;
             RAISE FND_API.G_EXC_ERROR;
         ELSE
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('LINE ' || TO_CHAR(L_ORDER_LINE_ID),1);
             END IF;
         END IF;

         FOR c_info_rec1 in C_ORDER_INFO(l_order_line_id) LOOP
           l_order_number  := c_info_rec1.order_number;
           l_trxn_type_name:= c_info_rec1.name;
         END LOOP;

         p_ref_line_id := l_order_line_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN SERIAL9 ' ) ;
         END IF;
         BEGIN
             SELECT /* MOAC_SQL_CHANGE */  rctl.customer_trx_line_id
             INTO l_invoice_line_id
             FROM ra_customer_trx_lines_all rctl,
                  ra_customer_trx rct,
                  ar_lookups arlup
             WHERE rct.status_trx = arlup.lookup_code
             AND arlup.lookup_type = 'INVOICE_TRX_STATUS'
             AND rct.customer_trx_id = rctl.customer_trx_id
             AND rctl.interface_line_context    = 'ORDER ENTRY'
             AND rctl.interface_line_attribute1 = to_char(l_order_number)
             AND rctl.interface_line_attribute2 = l_trxn_type_name
             AND rctl.interface_line_attribute6 = to_char(l_order_line_id)
             AND rctl.line_type = 'LINE'
             AND rctl.interface_line_attribute11 = '0' --Bug2721441
	     AND rctl.org_id=rct.org_id
	         AND rownum = 1;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INVOICE LINE ' || TO_CHAR ( L_INVOICE_LINE_ID ) , 1 ) ;
         END IF;

         EXCEPTION

             WHEN OTHERS THEN
              -- not invoiced yet, return NULL
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'NOT INVOICED YET' , 1 ) ;
                 END IF;
                 RETURN NULL;

         END;
         RETURN l_invoice_line_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN SERIAL10' ) ;
         END IF;

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          WHEN OTHERS THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'IN OTHERS EXCEPTION FOR SERIAL' , 2 ) ;
              END IF;
              IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                  OE_MSG_PUB.Add_Exc_Msg
                  (    G_PKG_NAME ,
                       'OE_Default_Line.Get_Def_Invoice_Line_Int'
                  );
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END;

  ELSIF p_return_context in ('PO','ORDER') THEN

    FOR c_info_rec2 in C_ORDER_INFO(p_return_attribute2) LOOP
      l_order_number  := c_info_rec2.order_number;
      l_trxn_type_name:= c_info_rec2.name;
    END LOOP;

    IF l_order_number IS NULL THEN
       oe_debug_pub.add('Invalid Return Reference',1);
       fnd_message.set_name('ONT', 'OE_RETURN_INVALID_SO_LINE');
       OE_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    BEGIN

       SELECT /* MOAC_SQL_CHANGE */ rctl.customer_trx_line_id
       INTO l_invoice_line_id
       FROM ra_customer_trx_lines_all rctl,
            ra_customer_trx rct,
            ar_lookups arlup
       WHERE rct.status_trx = arlup.lookup_code
        AND arlup.lookup_type = 'INVOICE_TRX_STATUS'
        AND rct.customer_trx_id = rctl.customer_trx_id
        AND p_return_attribute2 = rctl.interface_line_attribute6
        AND rctl.interface_line_context    = 'ORDER ENTRY'
        AND rctl.interface_line_attribute1 = to_char(l_order_number)
        AND rctl.interface_line_attribute2 = l_trxn_type_name
        AND rctl.line_type = 'LINE'
        AND rctl.interface_line_attribute11 = '0' --Bug2721441
        and rctl.org_id=rct.org_id
	    AND rownum = 1;

        p_ref_line_id := p_return_attribute2;
        RETURN l_invoice_line_id;

    EXCEPTION

       WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'IN OTHERS EXCEPTION FOR CONTEXT OF PO/ORDER' , 2 ) ;
          END IF;
          -- not invoiced yet, return NULL
          p_ref_line_id := p_return_attribute2;
          RETURN NULL;

    END;

  END IF;
  p_ref_line_id := p_return_attribute2;
  RETURN NULL;
END Get_Def_Invoice_Line_Int;


FUNCTION Get_Defaulting_Order_Line
(p_return_context VARCHAR2,
p_return_attribute1 VARCHAR2,
p_return_attribute2 VARCHAR2
) RETURN NUMBER
IS
l_order_line_id NUMBER := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING GET_DEFAULTING_ORDER_LINE' ) ;
  END IF;

  IF (p_return_context = 'ORDER') THEN

     RETURN to_number(p_return_attribute2);

  ELSIF (p_return_context = 'PO') THEN

     RETURN to_number(p_return_attribute2);

  ELSIF (p_return_context = 'SERIAL') THEN

    BEGIN

     SELECT l.line_id
     INTO l_order_line_id
     FROM oe_order_lines l,
          mtl_unit_transactions_all_v u,
          mtl_material_transactions m
     WHERE L.Inventory_item_id = to_number(p_return_attribute1)
     AND m.transaction_id = u.transaction_id
     AND l.line_category_code = 'ORDER'
     AND m.transaction_source_type_id=2
     AND m.trx_source_line_id=l.line_id
     AND u.serial_number = p_return_attribute2
     AND u.inventory_item_id = to_number(p_return_attribute1)
     AND rownum = 1;

       RETURN l_order_line_id;

    EXCEPTION


      WHEN NO_DATA_FOUND THEN

          -- this should not be possible
    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_Defaulting_Order_Line'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;

  ELSE

    BEGIN

       SELECT to_number(rctl.interface_line_attribute6)
       INTO l_order_line_id
       FROM ra_customer_trx_lines rctl
       WHERE  to_number(p_return_attribute2) = rctl.customer_trx_line_id;

       RETURN l_order_line_id;

    EXCEPTION

       WHEN NO_DATA_FOUND THEN
          -- this should not be possible
    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_Defaulting_Order_Line'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;

  END IF;-- return context

END Get_Defaulting_Order_Line;

Procedure Attributes_From_Invoice_Line
(   p_invoice_line_id 	IN NUMBER
,   p_x_line_rec  		IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
)
IS
l_quantity NUMBER;
l_uom_code        VARCHAR2(3);
l_tax_exempt_flag VARCHAR2(1);
l_tax_exempt_reason_code VARCHAR2(30);
l_tax_exempt_number VARCHAR2(80);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF (p_invoice_line_id IS NOT NULL) THEN
    -- get attributes from invoice line
    BEGIN
      SELECT /* MOAC_SQL_CHANGE */ rctl.quantity_invoiced,
             rctl.tax_exempt_flag,
             rctl.tax_exempt_reason_code,
             rctl.tax_exempt_number,
             rctl.uom_code
      INTO l_quantity,
           l_tax_exempt_flag,
           l_tax_exempt_reason_code,
           l_tax_exempt_number,
           l_uom_code
      FROM ra_customer_trx_lines_all rctl,
           oe_order_lines l
      WHERE rctl.customer_trx_line_id = p_invoice_line_id
      AND to_number(rctl.interface_line_attribute6) = l.line_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          -- this should not be possible
    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Attributes_From_Invoice_Line'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    -- use this attributes as default if not overriden
    /* We can not copy the invoiced_quantity to ordered_quantity */
    /*
    IF (p_x_line_rec.ordered_quantity IS NULL OR
        p_x_line_rec.ordered_quantity = FND_API.G_MISS_NUM) THEN
        p_x_line_rec.ordered_quantity := l_quantity;
        p_x_line_rec.order_quantity_uom := l_uom_code;
    ELSE
        NULL;
    END IF;
    */


    IF (p_x_line_rec.tax_exempt_flag IS NULL OR
        p_x_line_rec.tax_exempt_flag = FND_API.G_MISS_CHAR) THEN
      p_x_line_rec.tax_exempt_flag := l_tax_exempt_flag;
    END IF;

    IF (p_x_line_rec.tax_exempt_reason_code IS NULL OR
        p_x_line_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR) THEN
      p_x_line_rec.tax_exempt_reason_code := l_tax_exempt_reason_code;
    END IF;

    IF (p_x_line_rec.tax_exempt_number IS NULL OR
        p_x_line_rec.tax_exempt_number = FND_API.G_MISS_CHAR) THEN
      p_x_line_rec.tax_exempt_number := l_tax_exempt_number;
    END IF;

    IF (p_x_line_rec.reference_customer_trx_line_id IS NULL OR
        p_x_line_rec.reference_customer_trx_line_id = FND_API.G_MISS_NUM) THEN
      p_x_line_rec.reference_customer_trx_line_id := p_invoice_line_id;
    END IF;

    IF (p_x_line_rec.credit_invoice_line_id IS NULL OR
        p_x_line_rec.credit_invoice_line_id = FND_API.G_MISS_NUM) THEN
      p_x_line_rec.credit_invoice_line_id := p_invoice_line_id;
    END IF;

  END IF; -- exists invoice line

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING ATTRIBUTES_FROM_INVOICE_LINE' , 1 ) ;
  END IF;

END Attributes_From_Invoice_Line;

Procedure Attributes_From_Order_Line
(   p_order_line_id 		IN NUMBER
,   p_x_line_rec  			IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
)
IS
l_ref_line_rec OE_ORDER_PUB.Line_Rec_Type;
l_revision_controlled	VARCHAR2(1);
x_item_rec          OE_Order_Cache.Item_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_overship_invoice_basis    varchar2(30) := null; --- bug# 6617423

BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING ATTRIBUTES_FROM_ORDER_LINE  with p_order_line_id = ' ||p_order_line_id , 1 ) ;
  END IF;

   IF (p_order_line_id IS NOT NULL AND
      p_order_line_id<>FND_API.G_MISS_NUM) THEN

	 oe_line_util.query_row
		(p_line_id	=> p_order_line_id
		,x_line_rec	=> l_ref_line_rec
		);

      /* assign the referenced fields */
      IF ((p_x_line_rec.ordered_item IS NULL OR
          p_x_line_rec.ordered_item = FND_API.G_MISS_CHAR)
        AND (p_x_line_rec.inventory_item_id IS NULL OR
             p_x_line_rec.inventory_item_id = FND_API.G_MISS_NUM)
        AND (p_x_line_rec.ordered_item_id IS NULL OR
             p_x_line_rec.ordered_item_id = FND_API.G_MISS_NUM)) THEN
        p_x_line_rec.ordered_item := l_ref_line_rec.ordered_item ;
        p_x_line_rec.inventory_item_id := l_ref_line_rec.inventory_item_id;
        p_x_line_rec.item_identifier_type := l_ref_line_rec.item_identifier_type;
        p_x_line_rec.ordered_item_id := l_ref_line_rec.ordered_item_id;
        p_x_line_rec.item_type_code := OE_GLOBALS.G_ITEM_STANDARD;
      ELSE
        NULL;
      END IF;

      IF (p_x_line_rec.return_context = 'SERIAL') THEN
           p_x_line_rec.ordered_quantity := 1;
           p_x_line_rec.order_quantity_uom := l_ref_line_rec.order_quantity_uom;
      END IF;

      IF (p_x_line_rec.ordered_quantity IS NULL OR
          p_x_line_rec.ordered_quantity = fnd_api.g_miss_num) THEN

--         p_x_line_rec.ordered_quantity := l_ref_line_rec.ordered_quantity;  -- bug# 6617423
            -- bug# 6617423 : Start  ---------
           oe_debug_pub.add(  '  p_x_line_rec.org_id = '||p_x_line_rec.org_id ,5);
           IF p_x_line_rec.org_id = FND_API.G_MISS_NUM THEN
               l_overship_invoice_basis := oe_sys_parameters.value('OE_OVERSHIP_INVOICE_BASIS',NULL);
           ELSE
               l_overship_invoice_basis := oe_sys_parameters.value('OE_OVERSHIP_INVOICE_BASIS',p_x_line_rec.org_id);
           END IF;
           oe_debug_pub.add(  ' l_overship_invoice_basis = '|| l_overship_invoice_basis ,5 ) ;
           oe_debug_pub.add(  ' l_ref_line_rec.invoiced_quantity  = '|| l_ref_line_rec.invoiced_quantity ,5 ) ;
           oe_debug_pub.add(  ' l_ref_line_rec.ordered_quantity = '|| l_ref_line_rec.ordered_quantity,5 ) ;

           IF l_overship_invoice_basis = 'SHIPPED' then
               p_x_line_rec.ordered_quantity := nvl(l_ref_line_rec.shipped_quantity, l_ref_line_rec.ordered_quantity);
           ELSE
               p_x_line_rec.ordered_quantity := l_ref_line_rec.ordered_quantity;
           end if;
           oe_debug_pub.add(  ' p_x_line_rec.ordered_quantity = '|| p_x_line_rec.ordered_quantity, 5 ) ;
            -- bug# 6617423 : End

         p_x_line_rec.order_quantity_uom := l_ref_line_rec.order_quantity_uom;

      ELSE
        NULL;
      END IF;


       IF (p_x_line_rec.unit_cost IS NULL OR
          p_x_line_rec.unit_cost = fnd_api.g_miss_num) THEN
         p_x_line_rec.unit_cost := l_ref_line_rec.unit_cost;
      END IF;

      IF (p_x_line_rec.order_quantity_uom IS NULL OR
          p_x_line_rec.order_quantity_uom = fnd_api.g_miss_char) THEN
          p_x_line_rec.order_quantity_uom := l_ref_line_rec.order_quantity_uom;
      END IF;

      -- 09/07/2001 OPM BEGIN - Default process attributes as appropriate from an order line ref
      -- ===============================================================
     IF (p_x_line_rec.ordered_quantity_uom2 = FND_API.G_MISS_CHAR)
      OR (p_x_line_rec.ordered_quantity_uom2 IS NULL) THEN
       p_x_line_rec.ordered_quantity_uom2 :=
         l_ref_line_rec.ordered_quantity_uom2 ;
     END IF;

     IF (p_x_line_rec.preferred_grade = FND_API.G_MISS_CHAR)
      OR (p_x_line_rec.preferred_grade IS NULL) THEN
       p_x_line_rec.preferred_grade :=
         l_ref_line_rec.preferred_grade ;
     END IF;

     IF (p_x_line_rec.ordered_quantity2 = FND_API.G_MISS_NUM) THEN
          p_x_line_rec.ordered_quantity2 := l_ref_line_rec.ordered_quantity2;
     END IF;

     -- 09/07/2001 OPM END
     -- =====================

      IF (p_x_line_rec.reference_line_id IS NULL OR
          p_x_line_rec.reference_line_id = FND_API.G_MISS_NUM) THEN
	      p_x_line_rec.reference_header_id := l_ref_line_rec.header_id;
	      p_x_line_rec.reference_line_id := l_ref_line_rec.line_id;
      END IF;

/* Start : Tax Reference Info */
      IF (p_x_line_rec.tax_code IS NULL OR
          p_x_line_rec.tax_code = FND_API.G_MISS_CHAR)
      THEN
          p_x_line_rec.tax_code := l_ref_line_rec.tax_code;
          p_x_line_rec.tax_date := l_ref_line_rec.tax_date;
      END IF;

      IF (p_x_line_rec.tax_exempt_flag IS NULL OR
          p_x_line_rec.tax_exempt_flag = FND_API.G_MISS_CHAR)
      THEN
          p_x_line_rec.tax_exempt_flag := l_ref_line_rec.tax_exempt_flag;
      END IF;

      IF (p_x_line_rec.tax_exempt_number IS NULL OR
          p_x_line_rec.tax_exempt_number = FND_API.G_MISS_CHAR)
      THEN
          p_x_line_rec.tax_exempt_number := l_ref_line_rec.tax_exempt_number;
      END IF;

      IF (p_x_line_rec.tax_exempt_reason_code IS NULL OR
          p_x_line_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR)
      THEN
          p_x_line_rec.tax_exempt_reason_code :=
							    l_ref_line_rec.tax_exempt_reason_code;
      END IF;

/* End:  Tax Reference Info */

      IF (p_x_line_rec.pricing_quantity IS NULL OR
          p_x_line_rec.pricing_quantity = FND_API.G_MISS_NUM) THEN
		IF p_x_line_rec.return_context = 'SERIAL' OR
           OE_GLOBALS.G_RETURN_CHILDREN_MODE = 'Y' THEN
	         p_x_line_rec.pricing_quantity_uom :=
							  l_ref_line_rec.pricing_quantity_uom;
              p_x_line_rec.pricing_quantity := OE_Order_Misc_Util.convert_uom(
                                     p_x_line_rec.inventory_item_id,
                                     p_x_line_rec.order_quantity_uom,
                                     p_x_line_rec.pricing_quantity_uom,
                                     p_x_line_rec.ordered_quantity
                                     );
		ELSE
	         p_x_line_rec.pricing_quantity := l_ref_line_rec.pricing_quantity;
	         p_x_line_rec.pricing_quantity_uom :=
							  l_ref_line_rec.pricing_quantity_uom;
		END IF;
      ELSE
         NULL;
      END IF;

      IF (p_x_line_rec.pricing_date IS NULL OR
          p_x_line_rec.pricing_date = fnd_api.g_miss_date) THEN
	 p_x_line_rec.pricing_date := l_ref_line_rec.pricing_date ;
      ELSE
        NULL;
      END IF;

      IF (p_x_line_rec.unit_selling_price IS NULL OR
          p_x_line_rec.unit_selling_price = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.unit_selling_price := l_ref_line_rec.unit_selling_price ;
         IF (l_ref_line_rec.pricing_context IS NOT NULL) THEN
           p_x_line_rec.pricing_context := l_ref_line_rec.pricing_context;
            p_x_line_rec.pricing_attribute1 := l_ref_line_rec.pricing_attribute1;
            p_x_line_rec.pricing_attribute2 := l_ref_line_rec.pricing_attribute2;
            p_x_line_rec.pricing_attribute3 := l_ref_line_rec.pricing_attribute3;
            p_x_line_rec.pricing_attribute4 := l_ref_line_rec.pricing_attribute4;
            p_x_line_rec.pricing_attribute5 := l_ref_line_rec.pricing_attribute5;
            p_x_line_rec.pricing_attribute6 := l_ref_line_rec.pricing_attribute6;
            p_x_line_rec.pricing_attribute7 := l_ref_line_rec.pricing_attribute7;
            p_x_line_rec.pricing_attribute8 := l_ref_line_rec.pricing_attribute8;
            p_x_line_rec.pricing_attribute9 := l_ref_line_rec.pricing_attribute9;
            p_x_line_rec.pricing_attribute10 := l_ref_line_rec.pricing_attribute10;
         END IF;
      ELSE
        NULL;
      END IF;

      IF (p_x_line_rec.unit_percent_base_price IS NULL OR
          p_x_line_rec.unit_percent_base_price = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.unit_percent_base_price := l_ref_line_rec.unit_percent_base_price ;
      ELSE
        NULL;
      END IF;

      IF (p_x_line_rec.unit_list_price IS NULL OR
          p_x_line_rec.unit_list_price = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.unit_list_price := l_ref_line_rec.unit_list_price ;
      END IF;

   --RT{
      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
        oe_debug_pub.add('Retro:ref_head_id:'||l_ref_line_rec.header_id||' line_id:'||l_ref_line_rec.line_id);
        Oe_Retrobill_Pvt.Get_Return_Price(p_header_id=> l_ref_line_rec.header_id,
                                          p_line_id  => l_ref_line_rec.line_id,
					  p_ordered_qty => p_x_line_rec.ordered_quantity, --bug3540728
					  p_pricing_qty => p_x_line_rec.pricing_quantity, --bug3540728
                                          p_usp      => l_ref_line_rec.unit_selling_price,
                                          p_ulp      => l_ref_line_rec.unit_list_price,
                                          x_usp =>     p_x_line_rec.unit_selling_price,
                                          x_ulp =>    p_x_line_rec.unit_list_price,
					  x_ulp_ppqty => p_x_line_rec.unit_list_price_per_pqty, --bug3540728
					  x_usp_ppqty => p_x_line_rec.unit_selling_price_per_pqty); --bug3540728
        p_x_line_rec.retrobill_request_id:=NULL;
      END IF;
     --RT}

      -- Start: bug 1769612
      IF (p_x_line_rec.unit_list_price_per_pqty IS NULL OR
          p_x_line_rec.unit_list_price_per_pqty = FND_API.G_MISS_NUM) THEN
     p_x_line_rec.unit_list_price_per_pqty := l_ref_line_rec.unit_list_price_per_pqty ;
      END IF;

      IF (p_x_line_rec.unit_selling_price_per_pqty IS NULL OR
          p_x_line_rec.unit_selling_price_per_pqty = FND_API.G_MISS_NUM) THEN

     p_x_line_rec.unit_selling_price_per_pqty := l_ref_line_rec.unit_selling_price_per_pqty;
      END IF;
      -- end of bug 1769612

      IF (p_x_line_rec.price_list_id IS NULL OR
          p_x_line_rec.price_list_id = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.price_list_id := l_ref_line_rec.price_list_id ;
      ELSE
        NULL;
      END IF;

      IF (p_x_line_rec.invoice_to_org_id IS NULL OR
          p_x_line_rec.invoice_to_org_id = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.invoice_to_org_id := l_ref_line_rec.invoice_to_org_id ;
      END IF;

      IF (p_x_line_rec.ship_to_contact_id IS NULL OR
          p_x_line_rec.ship_to_contact_id = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.ship_to_contact_id := l_ref_line_rec.ship_to_contact_id ;
      END IF;

      IF (p_x_line_rec.intermed_ship_to_org_id IS NULL OR
	  p_x_line_rec.intermed_ship_to_org_id = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.intermed_ship_to_org_id := l_ref_line_rec.intermed_ship_to_org_id ;
      END IF;

      IF (p_x_line_rec.intermed_ship_to_contact_id IS NULL OR
          p_x_line_rec.intermed_ship_to_contact_id = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.intermed_ship_to_contact_id
               := l_ref_line_rec.intermed_ship_to_contact_id ;
      END IF;

      IF (p_x_line_rec.deliver_to_contact_id IS NULL OR
          p_x_line_rec.deliver_to_contact_id = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.deliver_to_contact_id
             := l_ref_line_rec.deliver_to_contact_id ;
      END IF;

      IF (p_x_line_rec.invoice_to_contact_id IS NULL OR
          p_x_line_rec.invoice_to_contact_id = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.invoice_to_contact_id := l_ref_line_rec.invoice_to_contact_id ;
      END IF;

      IF (p_x_line_rec.sold_to_org_id IS NULL OR
          p_x_line_rec.sold_to_org_id = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.sold_to_org_id := l_ref_line_rec.sold_to_org_id ;
      ELSE
        NULL;
      END IF;

      IF (p_x_line_rec.ship_from_org_id IS NULL OR
          p_x_line_rec.ship_from_org_id = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.ship_from_org_id := l_ref_line_rec.ship_from_org_id ;
      ELSE
        NULL;
      END IF;

  -- Pack J catchweight
      IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' AND
	 --bug3420941
	 (l_ref_line_rec.source_type_code <> 'EXTERNAL')  AND
         (p_x_line_rec. ordered_quantity2 IS NULL OR
         p_x_line_rec. ordered_quantity2 = FND_API.G_MISS_NUM) AND
         (p_x_line_rec. ordered_quantity_uom2 IS NULL OR
         --p_x_line_rec. ordered_quantity_uom2 = FND_API.G_MISS_NUM)  THEN -- Deleted for Bug# 6521073
         p_x_line_rec. ordered_quantity_uom2 = FND_API.G_MISS_CHAR)  THEN -- Added for Bug# 6521073

         IF (p_x_line_rec.inventory_item_id IS NOT NULL AND
            p_x_line_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
            (p_x_line_rec.ship_from_org_id  IS NOT NULL AND
            p_x_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM) THEN
              x_item_rec := OE_Order_Cache.Load_Item (p_x_line_rec.inventory_item_id
                            ,p_x_line_rec.ship_from_org_id);
              -- IF  x_item_rec.ont_pricing_qty_source = 1   THEN INVCONV
              IF x_item_rec.ont_pricing_qty_source = 'S' THEN  -- INVCONV
                  -- x_item_rec.tracking_quantity_ind = 'P' AND -- INVCONV - TAKE OUT AS OPENED UP TO ANY ITEM AND ORG
                  -- x_item_rec.wms_enabled_flag = 'Y' THEN
                  IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'Discrete Catchweight enabled. l_ref_line_rec.shipped_quantity2: '|| l_ref_line_rec.shipped_quantity2||
   ': l_ref_line_rec.ordered_quantity:'|| l_ref_line_rec.ordered_quantity||': l_ref_line_rec.pricing_quantity_uom:'|| l_ref_line_rec.pricing_quantity_uom);
                  END IF;
                  p_x_line_rec.ordered_quantity2 := l_ref_line_rec.shipped_quantity2/ l_ref_line_rec.ordered_quantity * p_x_line_rec.ordered_quantity;
                  p_x_line_rec.ordered_quantity_uom2 := x_item_rec.secondary_uom_code;
                  IF l_ref_line_rec.pricing_quantity_uom = l_ref_line_rec.ordered_quantity_uom2   THEN
                        p_x_line_rec.pricing_quantity := p_x_line_rec.ordered_quantity2;
                  ELSE
                         p_x_line_rec.pricing_quantity := OE_Order_Misc_Util.convert_uom(
                                     p_x_line_rec.inventory_item_id,
                                     p_x_line_rec.ordered_quantity_uom2,
                                     p_x_line_rec.pricing_quantity_uom,
                                     p_x_line_rec.ordered_quantity2
                                     );
                          IF l_debug_level  > 0 THEN
                               oe_debug_pub.add(  'p_x_line_rec.pricing_quantity:'|| p_x_line_rec.pricing_quantity);
                          END IF;
                   END IF; -- end check for pricing uom, shipping uom2
              END IF; -- check for discrete catchweight
         END IF; -- end checks for item org existence
      END IF; -- end checks for qty2/uom2 existence
  -- Pack J catchweight

      IF (p_x_line_rec.ship_to_org_id IS NULL OR
          p_x_line_rec.ship_to_org_id = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.ship_to_org_id := l_ref_line_rec.ship_to_org_id ;
      ELSE
        NULL;
      END IF;

      IF (p_x_line_rec.deliver_to_org_id IS NULL OR
          p_x_line_rec.deliver_to_org_id = FND_API.G_MISS_NUM) THEN
	 p_x_line_rec.deliver_to_org_id := l_ref_line_rec.deliver_to_org_id;
      ELSE
        NULL;
      END IF;


      IF (p_x_line_rec.project_id IS NULL OR
          p_x_line_rec.project_id = FND_API.G_MISS_NUM) THEN
          p_x_line_rec.project_id := l_ref_line_rec.project_id;
      END IF;

      IF (p_x_line_rec.task_id IS NULL OR
          p_x_line_rec.task_id = FND_API.G_MISS_NUM) THEN
          p_x_line_rec.task_id := l_ref_line_rec.task_id;
      END IF;

      IF (p_x_line_rec.end_item_unit_number IS NULL OR
          p_x_line_rec.end_item_unit_number = FND_API.G_MISS_CHAR) THEN
          p_x_line_rec.end_item_unit_number := l_ref_line_rec.end_item_unit_number;
      END IF;

      /* Added for the bug fix 1720066 */
      IF (p_x_line_rec.shippable_flag IS NULL OR
          p_x_line_rec.shippable_flag = FND_API.G_MISS_CHAR)
      THEN
          p_x_line_rec.shippable_flag := l_ref_line_rec.shippable_flag;
      END IF;

      -- bug 2509121
      IF (p_x_line_rec.user_item_description IS NULL OR
          p_x_line_rec.user_item_description = FND_API.G_MISS_CHAR)
      THEN
          p_x_line_rec.user_item_description := l_ref_line_rec.user_item_description;
      END IF;


      /* Fix Bug 2429989: Returning Revision Controlled Items */

      IF p_x_line_rec.inventory_item_id IS NOT NULL AND
         p_x_line_rec.inventory_item_id <> FND_API.G_MISS_NUM THEN

        Begin
          select decode(revision_qty_control_code, 2, 'Y', 'N')
          into   l_revision_controlled
          from   mtl_system_items
          where  inventory_item_id = p_x_line_rec.inventory_item_id
          and    organization_id   = OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID');
          Exception
            When NO_DATA_FOUND Then
              l_revision_controlled := 'N';
        End;

        IF l_revision_controlled = 'Y' THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'THE ITEM IS REVISION CONTROLLED' ) ;
          END IF;

          Begin
            select distinct revision
            into   p_x_line_rec.item_revision
            from   mtl_material_transactions
            where  transaction_source_type_id = 2
            and    transaction_type_id = 33
            and    trx_source_line_id = p_x_line_rec.reference_line_id
            and    inventory_item_id  = p_x_line_rec.inventory_item_id
            and    organization_id    = (select ship_from_org_id
                                         from   oe_order_lines_all
                                         where  line_id = p_x_line_rec.reference_line_id);
            Exception
              When No_Data_Found Then
                Null;
              When Too_Many_Rows Then
                 p_x_line_rec.item_revision := NULL;
          End;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'THE ITEM REVISION IS: '|| P_X_LINE_REC.ITEM_REVISION ) ;
          END IF;
        END IF;

      END IF;

   END IF;

   -- Bug 2849656 => Copy blanket fields from referenced order line
   -- to RMA line.

   IF (p_x_line_rec.blanket_number IS NULL OR
       p_x_line_rec.blanket_number = FND_API.G_MISS_NUM) THEN
       p_x_line_rec.blanket_number := l_ref_line_rec.blanket_number;
   END IF;

   IF (p_x_line_rec.blanket_line_number IS NULL OR
       p_x_line_rec.blanket_line_number = FND_API.G_MISS_NUM) THEN
       p_x_line_rec.blanket_line_number := l_ref_line_rec.blanket_line_number;
   END IF;

   -- End fix for Bug 2849656

   -- Override List Price
   IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
      IF OE_ORDER_COPY_UTIL.G_LINE_PRICE_MODE = OE_ORDER_COPY_UTIL.G_CPY_REPRICE THEN
         p_x_line_rec.original_list_price := NULL;
      ELSE
         IF (p_x_line_rec.original_list_price IS NULL OR
             p_x_line_rec.original_list_price = FND_API.G_MISS_NUM) THEN
             p_x_line_rec.original_list_price := l_ref_line_rec.original_list_price;
         END IF;
      END IF;

   END IF;
   -- Override List Price

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING ATTRIBUTES_FROM_ORDER_LINE' , 1 ) ;
  END IF;

END Attributes_From_Order_Line;

Procedure Return_Attributes
	    (   p_x_line_rec      	IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
            ,   p_old_line_rec  	IN  OE_Order_PUB.Line_Rec_Type
            )
IS
l_defaulting_invoice_line_id NUMBER := NULL;
l_defaulting_order_line_id NUMBER := NULL;
l_line_rec                 oe_order_pub.line_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status VARCHAR2(1);
l_sold_to_org_id        NUMBER;
l_currency_code         VARCHAR2(15);

l_overship_invoice_basis  VARCHAR2(30):= NULL; -- bug#6617423

BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INSIDE DEFAULTING RMA' , 1 ) ;
      oe_debug_pub.add(  'RMA OPERATION IS'||P_X_LINE_REC.OPERATION , 1 ) ;
  END IF;
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.return_attribute2,
					p_old_line_rec.return_attribute2)
    THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CLEARING RMA_ATTRIBUTES' , 1 ) ;
      oe_debug_pub.add(  ' OLD P_OLD_LINE_REC.RETURN_CONTEXT = '||P_OLD_LINE_REC.RETURN_CONTEXT , 1 ) ;
      oe_debug_pub.add(  ' OLD P_OLD_LINE_REC.RETURN_ATTRIBUTE1 = '||P_OLD_LINE_REC.RETURN_ATTRIBUTE1 , 1 ) ;
      oe_debug_pub.add(  ' OLD P_OLD_LINE_REC.RETURN_ATTRIBUTE2 = '||P_OLD_LINE_REC.RETURN_ATTRIBUTE2 , 1 ) ;
      oe_debug_pub.add(  ' OLD P_OLD_LINE_REC.RETURN_ATTRIBUTE3 = '||P_OLD_LINE_REC.RETURN_ATTRIBUTE3 , 1 ) ;

      oe_debug_pub.add(  ' NEW P_X_LINE_REC.RETURN_CONTEXT = '||P_X_LINE_REC.RETURN_CONTEXT , 1 ) ;
      oe_debug_pub.add(  ' NEW P_X_LINE_REC.RETURN_ATTRIBUTE1 = '||P_X_LINE_REC.RETURN_ATTRIBUTE1 , 1 ) ;
      oe_debug_pub.add(  ' NEW P_X_LINE_REC.RETURN_ATTRIBUTE2 = '||P_X_LINE_REC.RETURN_ATTRIBUTE2 , 1 ) ;
      oe_debug_pub.add(  ' NEW P_X_LINE_REC.RETURN_ATTRIBUTE2 = '||P_X_LINE_REC.RETURN_ATTRIBUTE3 , 1 ) ;

      oe_debug_pub.add(  ' NEW p_x_line_rec.source_document_id = '|| p_x_line_rec.source_document_id , 1 ) ;
      oe_debug_pub.add(  ' NEW p_x_line_rec.source_document_line_id = '|| p_x_line_rec.source_document_line_id , 1 ) ;
      oe_debug_pub.add(  ' NEW p_x_line_rec.orig_sys_document_ref = '|| p_x_line_rec.orig_sys_document_ref , 1 ) ;
      oe_debug_pub.add(  ' NEW p_x_line_rec.orig_sys_line_ref = '||p_x_line_rec.orig_sys_line_ref , 1 ) ;
  END IF;

        -- Backup the passed in record.
        l_line_rec := p_x_line_rec;

        -- Set the line rec to MISSING so that all attributes are redefaulted
        p_x_line_rec := OE_Order_PUB.G_MISS_LINE_REC;

        -- Reset the pre-defaulted values from backup
        p_x_line_rec.line_id := l_line_rec.line_id;
        p_x_line_rec.customer_line_number :=l_line_rec.customer_line_number; --added for bug 5569557
        p_x_line_rec.ship_from_org_id := l_line_rec.ship_from_org_id; --Added for bug 5649747
        p_x_line_rec.line_number := l_line_rec.line_number;
        p_x_line_rec.header_id := l_line_rec.header_id;
        p_x_line_rec.item_type_code := l_line_rec.item_type_code;
        p_x_line_rec.line_type_id := l_line_rec.line_type_id;
        p_x_line_rec.line_category_code := l_line_rec.line_category_code;
        p_x_line_rec.return_reason_code := l_line_rec.return_reason_code;
        p_x_line_rec.org_id := l_line_rec.org_id;
        p_x_line_rec.sold_to_org_id := l_line_rec.sold_to_org_id;
        p_x_line_rec.CUST_PO_NUMBER := l_line_rec.CUST_PO_NUMBER;
        p_x_line_rec.return_context := l_line_rec.return_context;
        p_x_line_rec.return_attribute1 := l_line_rec.return_attribute1;
        p_x_line_rec.return_attribute2 := l_line_rec.return_attribute2;
        p_x_line_rec.shipment_number := l_line_rec.shipment_number;
        p_x_line_rec.creation_date := l_line_rec.creation_date;
        p_x_line_rec.created_by := l_line_rec.created_by;
        p_x_line_rec.operation := l_line_rec.operation;
        p_x_line_rec.db_flag := l_line_rec.db_flag;
        p_x_line_rec.source_document_type_id :=
                                  l_line_rec.source_document_type_id;
        p_x_line_rec.context := l_line_rec.context;    --Bug#7380336
        /*Bug2816576*/
        p_x_line_rec.source_document_id := l_line_rec.source_document_id;
        p_x_line_rec.source_document_line_id := l_line_rec.source_document_line_id;
        /*Bug2816576*/
        p_x_line_rec.orig_sys_document_ref := l_line_rec.orig_sys_document_ref;
        p_x_line_rec.orig_sys_line_ref := l_line_rec.orig_sys_line_ref;
        p_x_line_rec.orig_sys_shipment_ref := l_line_rec.orig_sys_shipment_ref;
        p_x_line_rec.change_sequence := l_line_rec.change_sequence;

        /* Fix Bug # 2605825:
        ** Need to preserve Booked Flag and Flow Status Code, which might have
        ** already been defaulted based on the header level booking status.
        */
        p_x_line_rec.booked_flag := l_line_rec.booked_flag;
        p_x_line_rec.flow_status_code := l_line_rec.flow_status_code;

        /* Bug # 2834750 : Need to preserve Fulfillment Set */
        p_x_line_rec.fulfillment_set := l_line_rec.fulfillment_set;

        /* Need to preserve the sold_from_org_id */
        p_x_line_rec.sold_from_org_id := l_line_rec.sold_from_org_id;
        /* Need to preserve request_date */
        p_x_line_rec.request_date := l_line_rec.request_date;

        -- Quoting Changes Start
        -- Copy transaction phase from order header to return line
        OE_Order_Cache.Load_Order_Header(p_x_line_rec.header_id);
        p_x_line_rec.transaction_phase_code :=
                     OE_Order_Cache.g_header_rec.transaction_phase_code;
        -- Quoting Changes End

        /* Fix for the bug 1777243
        ** Copy the Ordered Quantity from the set value in
        ** Insert_Rma_Options_Included and derive the pricing quantity
        */


        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  ' l_line_rec.ordered_quantity = '||l_line_rec.ordered_quantity,5 ) ;
            oe_debug_pub.add(  ' l_line_rec.invoiced_quantity = '||l_line_rec.invoiced_quantity,5 ) ;
            oe_debug_pub.add(  ' p_x_line_rec.org_id = '||p_x_line_rec.org_id ,5) ;
            oe_debug_pub.add(  ' p_x_line_rec.ordered_quantity = '|| p_x_line_rec.ordered_quantity,5 ) ;
        END IF;


        IF OE_GLOBALS.G_RETURN_CHILDREN_MODE = 'Y' OR NOT (OE_GLOBALS.G_UI_FLAG)  THEN
           --p_x_line_rec.ordered_quantity := l_line_rec.ordered_quantity; -- bug# 6617423

              -- bug# 6617423 : start
           oe_debug_pub.add(  ' <in Return_Attributes>  p_x_line_rec.org_id = '|| p_x_line_rec.org_id , 5 ) ;
           IF p_x_line_rec.org_id = FND_API.G_MISS_NUM THEN
               l_overship_invoice_basis := oe_sys_parameters.value('OE_OVERSHIP_INVOICE_BASIS',NULL);
           ELSE
               l_overship_invoice_basis := oe_sys_parameters.value('OE_OVERSHIP_INVOICE_BASIS',p_x_line_rec.org_id);
           END IF;
           oe_debug_pub.add(  ' <in Return_Attributes>  l_overship_invoice_basis = '|| l_overship_invoice_basis ,5) ;

           IF l_overship_invoice_basis = 'SHIPPED' then
               p_x_line_rec.ordered_quantity := nvl(l_line_rec.shipped_quantity, l_line_rec.ordered_quantity);
           ELSE
               p_x_line_rec.ordered_quantity := l_line_rec.ordered_quantity;
           end if;
          oe_debug_pub.add(  ' p_x_line_rec.ordered_quantity = '|| p_x_line_rec.ordered_quantity , 5 ) ;
            -- bug# 6617423 : End

           p_x_line_rec.order_quantity_uom := l_line_rec.order_quantity_uom;
           p_x_line_rec.pricing_quantity := l_line_rec.pricing_quantity;
           p_x_line_rec.pricing_quantity_uom := l_line_rec.pricing_quantity_uom;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'THE ORDERED QTY IS SET' ) ;
           END IF;
        END IF;

	    IF p_x_line_rec.source_document_type_id = 2
        THEN
            p_x_line_rec.order_source_id := 2;
        END IF;

	    IF p_x_line_rec.source_document_type_id = 2 OR
           OE_GLOBALS.G_RETURN_CHILDREN_MODE = 'Y'
        THEN
           p_x_line_rec.calculate_price_flag := l_line_rec.calculate_price_flag;
           p_x_line_rec.pricing_date := l_line_rec.pricing_date;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'CALCULATE PRICE FLAG : '||P_X_LINE_REC.CALCULATE_PRICE_FLAG ) ;
               oe_debug_pub.add(  'PRICING DATE : '||P_X_LINE_REC.PRICING_DATE ) ;
           END IF;

        END IF;

        -- Fix for the issue 2347377. Retain the flex values if sent in
        -- by NON-UI call like (OrderImport) / COPY.

        IF NOT (OE_GLOBALS.G_UI_FLAG)
        THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Context is' ||P_X_LINE_REC.context);
               oe_debug_pub.add('Attribute 1 is : '||P_X_LINE_REC.attribute1);
           END IF;

            -- Retain the Line DFF info
            p_x_line_rec.context := l_line_rec.context;
            p_x_line_rec.attribute1 := l_line_rec.attribute1;
            p_x_line_rec.attribute2 := l_line_rec.attribute2;
            p_x_line_rec.attribute3 := l_line_rec.attribute3;
            p_x_line_rec.attribute4 := l_line_rec.attribute4;
            p_x_line_rec.attribute5 := l_line_rec.attribute5;
            p_x_line_rec.attribute6 := l_line_rec.attribute6;
            p_x_line_rec.attribute7 := l_line_rec.attribute7;
            p_x_line_rec.attribute8 := l_line_rec.attribute8;
            p_x_line_rec.attribute9 := l_line_rec.attribute9;
            p_x_line_rec.attribute10 := l_line_rec.attribute10;
            p_x_line_rec.attribute11 := l_line_rec.attribute11;
            p_x_line_rec.attribute12 := l_line_rec.attribute12;
            p_x_line_rec.attribute13 := l_line_rec.attribute13;
            p_x_line_rec.attribute14 := l_line_rec.attribute14;
            p_x_line_rec.attribute15 := l_line_rec.attribute15;
            p_x_line_rec.attribute16 := l_line_rec.attribute16;
            p_x_line_rec.attribute17 := l_line_rec.attribute17;
            p_x_line_rec.attribute18 := l_line_rec.attribute18;
            p_x_line_rec.attribute19 := l_line_rec.attribute19;
            p_x_line_rec.attribute20 := l_line_rec.attribute20;

            -- Retain the Global DFF Info
            p_x_line_rec.global_attribute_category
                                    := l_line_rec.global_attribute_category;
            p_x_line_rec.global_attribute1 := l_line_rec.global_attribute1;
            p_x_line_rec.global_attribute2 := l_line_rec.global_attribute2;
            p_x_line_rec.global_attribute3 := l_line_rec.global_attribute3;
            p_x_line_rec.global_attribute4 := l_line_rec.global_attribute4;
            p_x_line_rec.global_attribute5 := l_line_rec.global_attribute5;
            p_x_line_rec.global_attribute6 := l_line_rec.global_attribute6;
            p_x_line_rec.global_attribute7 := l_line_rec.global_attribute7;
            p_x_line_rec.global_attribute8 := l_line_rec.global_attribute8;
            p_x_line_rec.global_attribute9 := l_line_rec.global_attribute9;
            p_x_line_rec.global_attribute10 := l_line_rec.global_attribute10;
            p_x_line_rec.global_attribute11 := l_line_rec.global_attribute11;
            p_x_line_rec.global_attribute12 := l_line_rec.global_attribute12;
            p_x_line_rec.global_attribute13 := l_line_rec.global_attribute13;
            p_x_line_rec.global_attribute14 := l_line_rec.global_attribute14;
            p_x_line_rec.global_attribute15 := l_line_rec.global_attribute15;
            p_x_line_rec.global_attribute16 := l_line_rec.global_attribute16;
            p_x_line_rec.global_attribute17 := l_line_rec.global_attribute17;
            p_x_line_rec.global_attribute18 := l_line_rec.global_attribute18;
            p_x_line_rec.global_attribute19 := l_line_rec.global_attribute19;
            p_x_line_rec.global_attribute20 := l_line_rec.global_attribute20;

            -- Retain the Industry DFF Info
            p_x_line_rec.industry_context    := l_line_rec.industry_context;
            p_x_line_rec.industry_attribute1 := l_line_rec.industry_attribute1;
            p_x_line_rec.industry_attribute2 := l_line_rec.industry_attribute2;
            p_x_line_rec.industry_attribute3 := l_line_rec.industry_attribute3;
            p_x_line_rec.industry_attribute4 := l_line_rec.industry_attribute4;
            p_x_line_rec.industry_attribute5 := l_line_rec.industry_attribute5;
            p_x_line_rec.industry_attribute6 := l_line_rec.industry_attribute6;
            p_x_line_rec.industry_attribute7 := l_line_rec.industry_attribute7;
            p_x_line_rec.industry_attribute8 := l_line_rec.industry_attribute8;
            p_x_line_rec.industry_attribute9 := l_line_rec.industry_attribute9;
            p_x_line_rec.industry_attribute10 := l_line_rec.industry_attribute10;
	    --Begin of Bug Fix 6626305
            p_x_line_rec.industry_attribute11 := l_line_rec.industry_attribute11;
            p_x_line_rec.industry_attribute12 := l_line_rec.industry_attribute12;
            p_x_line_rec.industry_attribute13 := l_line_rec.industry_attribute13;
            p_x_line_rec.industry_attribute14 := l_line_rec.industry_attribute14;
            p_x_line_rec.industry_attribute15 := l_line_rec.industry_attribute15;
            p_x_line_rec.industry_attribute16 := l_line_rec.industry_attribute16;
            p_x_line_rec.industry_attribute17 := l_line_rec.industry_attribute17;
            p_x_line_rec.industry_attribute18 := l_line_rec.industry_attribute18;
            p_x_line_rec.industry_attribute19 := l_line_rec.industry_attribute19;
            p_x_line_rec.industry_attribute20 := l_line_rec.industry_attribute20;
            p_x_line_rec.industry_attribute21 := l_line_rec.industry_attribute21;
            p_x_line_rec.industry_attribute22 := l_line_rec.industry_attribute22;
            p_x_line_rec.industry_attribute23 := l_line_rec.industry_attribute23;
            p_x_line_rec.industry_attribute24 := l_line_rec.industry_attribute24;
            p_x_line_rec.industry_attribute25 := l_line_rec.industry_attribute25;
            p_x_line_rec.industry_attribute26 := l_line_rec.industry_attribute26;
            p_x_line_rec.industry_attribute27 := l_line_rec.industry_attribute27;
            p_x_line_rec.industry_attribute28 := l_line_rec.industry_attribute28;
            p_x_line_rec.industry_attribute29 := l_line_rec.industry_attribute29;
            p_x_line_rec.industry_attribute30 := l_line_rec.industry_attribute30;


            p_x_line_rec.return_attribute3 := l_line_rec.return_attribute3;
	    p_x_line_rec.return_attribute4 := l_line_rec.return_attribute4;
            p_x_line_rec.return_attribute5 := l_line_rec.return_attribute5;
	    p_x_line_rec.return_attribute6 := l_line_rec.return_attribute6;
            p_x_line_rec.return_attribute7 := l_line_rec.return_attribute7;
	    p_x_line_rec.return_attribute8 := l_line_rec.return_attribute8;
            p_x_line_rec.return_attribute9 := l_line_rec.return_attribute9;
	    p_x_line_rec.return_attribute10 := l_line_rec.return_attribute10;
	    p_x_line_rec.return_attribute11 := l_line_rec.return_attribute11;
	    p_x_line_rec.return_attribute12 := l_line_rec.return_attribute12;
	    p_x_line_rec.return_attribute13 := l_line_rec.return_attribute13;
	    p_x_line_rec.return_attribute14 := l_line_rec.return_attribute14;
	    p_x_line_rec.return_attribute15 := l_line_rec.return_attribute15;
	    --End of Bug Fix 6626305


            -- Retain the Trading Partner DFF Info
            p_x_line_rec.tp_context    := l_line_rec.tp_context;
            p_x_line_rec.tp_attribute1 := l_line_rec.tp_attribute1;
            p_x_line_rec.tp_attribute2 := l_line_rec.tp_attribute2;
            p_x_line_rec.tp_attribute3 := l_line_rec.tp_attribute3;
            p_x_line_rec.tp_attribute4 := l_line_rec.tp_attribute4;
            p_x_line_rec.tp_attribute5 := l_line_rec.tp_attribute5;
            p_x_line_rec.tp_attribute6 := l_line_rec.tp_attribute6;
            p_x_line_rec.tp_attribute7 := l_line_rec.tp_attribute7;
            p_x_line_rec.tp_attribute8 := l_line_rec.tp_attribute8;
            p_x_line_rec.tp_attribute9 := l_line_rec.tp_attribute9;
            p_x_line_rec.tp_attribute10 := l_line_rec.tp_attribute10;
            p_x_line_rec.tp_attribute11 := l_line_rec.tp_attribute11;
            p_x_line_rec.tp_attribute12 := l_line_rec.tp_attribute12;
            p_x_line_rec.tp_attribute13 := l_line_rec.tp_attribute13;
            p_x_line_rec.tp_attribute14 := l_line_rec.tp_attribute14;
            p_x_line_rec.tp_attribute15 := l_line_rec.tp_attribute15;

        END IF;

   END IF;

   IF p_x_line_rec.return_attribute2 is NOT NULL AND
      p_x_line_rec.return_attribute2 <> FND_API.G_MISS_CHAR
   THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN DEFAULT RETURN ATTRIBUTES' , 1 ) ;
      END IF;

      -- reprice when pricing attributes change
      -- also if the flag is passed in, keep the original flag
      IF (p_x_line_rec.calculate_price_flag IS NULL OR
          p_x_line_rec.calculate_price_flag = FND_API.G_MISS_CHAR)
      THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SETTING CALCULATE PRICE FLAG' , 1 ) ;
      END IF;
        p_x_line_rec.calculate_price_flag := 'N';

      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN DEFAULT RETURN ATTRIBUTES -1' , 1 ) ;
      END IF;
	 IF NOT OE_GLOBALS.Equal(p_x_line_rec.return_attribute2,
						p_old_line_rec.return_attribute2)
	 THEN

      -- Get the values of l_currency_code and l_sold_to_org_id
      OE_ORDER_CACHE.Load_Order_Header(p_x_line_rec.header_id);
      l_sold_to_org_id := OE_ORDER_CACHE.g_header_rec.SOLD_TO_ORG_ID;
      l_currency_code := OE_ORDER_CACHE.g_header_rec.transactional_curr_code;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN DEFAULT RETURN ATTRIBUTES 0' , 1 ) ;
          oe_debug_pub.add('Sold To Org Id IS '|| l_sold_to_org_id , 1 ) ;
          oe_debug_pub.add('Header Currency IS '||l_currency_code , 1 ) ;
      END IF;
          -- default attributes from invoice line
          l_defaulting_invoice_line_id := Get_Def_Invoice_Line_Int
            (p_x_line_rec.return_context,
             p_x_line_rec.return_attribute1,
             p_x_line_rec.return_attribute2,
             l_sold_to_org_id,
             l_currency_code,
             l_defaulting_order_line_id);
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN DEFAULT RETURN ATTRIBUTES 1' , 1 ) ;
      END IF;

          -- Since only one serial number can be entered from the reference
          -- set the Ordered_quantity to 1.

          /*
          ** Fix for Bug # 1686920
          ** Commented following as it's being taken care of at a later stage.
          IF p_x_line_rec.return_context = 'SERIAL' THEN
              p_x_line_rec.ordered_quantity := 1;
          END IF;
          */

          IF l_defaulting_invoice_line_id IS NOT NULL THEN
              Attributes_From_Invoice_Line
              (p_invoice_line_id => l_defaulting_invoice_line_id,
               p_x_line_rec => p_x_line_rec);
          END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN DEFAULT RETURN ATTRIBUTES 2' , 1 ) ;
      END IF;

          Attributes_From_Order_Line
             (p_order_line_id => l_defaulting_order_line_id,
              p_x_line_rec => p_x_line_rec);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN DEFAULT RETURN ATTRIBUTES 4' , 1 ) ;
      END IF;

          -- Clear attributes that do not make sense to returns
          p_x_line_rec.shipped_quantity := NULL;
          p_x_line_rec.reserved_quantity := NULL;
          p_x_line_rec.shipping_quantity := NULL;
          p_x_line_rec.shipping_quantity_uom := NULL;

          -- INVCONV
          p_x_line_rec.shipped_quantity2 := NULL;
          p_x_line_rec.reserved_quantity2 := NULL;
          p_x_line_rec.shipping_quantity2 := NULL;
          p_x_line_rec.shipping_quantity_uom2 := NULL;
          p_x_line_rec.fulfilled_quantity2 := NULL;

          /* Need to copy shippable_flag from the reference line */
          --p_x_line_rec.shippable_flag := NULL;
          p_x_line_rec.actual_shipment_date := NULL;
          -- source type code for RMA lines will always be set to internal. If
          -- in future we plan to change the design then please comment out the
          -- following code.
          p_x_line_rec.source_type_code := OE_GLOBALS.G_SOURCE_INTERNAL;

          p_x_line_rec.over_ship_reason_code := NULL;
          p_x_line_rec.over_ship_resolved_flag := NULL;
          p_x_line_rec.shipping_interfaced_flag := NULL;
          p_x_line_rec.top_model_line_id := NULL;
          -- Commented following stmt to fix Bug # 1580182.
       -- p_x_line_rec.booked_flag := 'N';
          p_x_line_rec.fulfilled_quantity := NULL;
          p_x_line_rec.option_number := NULL;

       -- For bug3327250
       -- CAll OE_Validate_Line.Attributes
          OE_Validate_Line.Attributes(
            x_return_status    => l_return_status
          , p_x_line_rec       => p_x_line_rec
          , p_validation_level => OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'THE ORDERED QTY IS '||P_X_LINE_REC.ORDERED_QUANTITY ) ;
      oe_debug_pub.add(  'THE PRICING QTY IS '||P_X_LINE_REC.PRICING_QUANTITY ) ;
  END IF;
      END IF;

  END IF;

END Return_Attributes;

--  Procedure Attributes

PROCEDURE Attributes
(   p_x_Line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_old_Line_rec                  IN  OE_Order_PUB.Line_Rec_Type
,   p_iteration                     IN  NUMBER := 1
)

IS
    l_in_old_rec     OE_AK_ORDER_LINES_V%ROWTYPE;
    l_in_rec		 OE_AK_ORDER_LINES_V%ROWTYPE;
    l_rec            OE_AK_ORDER_LINES_V%ROWTYPE;
    g_multiple_shipments VARCHAR2(3);
    l_set_tolerance_below VARCHAR2(1) := 'N';
    l_set_tolerance_above VARCHAR2(1) := 'N';

    l_blanket_number NUMBER := NULL;
    l_blanket_version_number NUMBER := NULL;
    l_blanket_line_number NUMBER := NULL;
    l_blanket_request_date DATE;

    l_exists		VARCHAR2(1);
    l_party_type	VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTER OE_DEFAULT_LINE.ATTRIBUTES' , 1 ) ;
    END IF;
    fnd_profile.get('ONT_IMP_MULTIPLE_SHIPMENTS', g_multiple_shipments);
    g_multiple_shipments := nvl(g_multiple_shipments, 'NO');

    /* IF (p_x_line_rec.operation = oe_globals.g_opr_create and */
    IF  p_x_line_rec.return_context is NOT NULL AND
        p_x_line_rec.return_context <> FND_API.G_MISS_CHAR THEN
        Return_Attributes
        (   p_x_line_rec                    => p_x_line_rec
            ,   p_old_line_rec            => p_old_line_rec
         );
    END IF;
    g_line_rec := p_x_line_rec;

    -- bug 4668200
    IF (g_line_rec.header_id IS NOT NULL AND
	g_line_rec.header_id <> FND_API.G_MISS_NUM) THEN
            Set_Header_Def_Hdlr_Rec (g_line_rec.header_id);
    END IF ;
    -- end

    IF p_x_line_rec.unit_cost = FND_API.G_MISS_NUM THEN
       p_x_line_rec.unit_cost := p_old_line_rec.unit_cost;
    END IF;

    --  For some fields, get hardcoded defaults

    --  IMPORTANT: For defaulting to work correctly, these fields should
    --  A) Not be dependent on any other field (Refer OEXUDEPB.pls for the
    --     list of dependencies)
    --  B) Not be enabled for security constraints as there is no security
    --     check for these fields from here.

    -- ***************IMPORTANT ********************
    -- get item_type is dependent on get_top_model
    -- get ato_line , get_shippbale etc are dependent on get_item_type
    -- please do not changes their sequence.

    IF g_line_rec.operation = oe_globals.g_opr_create THEN
        g_line_rec.org_id :=  Get_Org;

        -- QUOTING change
        -- Initialize flow status to DRAFT for lines in negotiation phase
        IF g_line_rec.transaction_phase_code = 'N' THEN
           g_line_rec.flow_status_code := 'DRAFT';
        END IF;

    END IF;

    IF g_line_rec.created_by = FND_API.G_MISS_NUM THEN
        g_line_rec.created_by := FND_GLOBAL.USER_ID;
    END IF;

--key Transaction Dates
   IF g_line_rec.creation_date = FND_API.G_MISS_DATE THEN
	g_line_rec.creation_date := sysdate;
   END IF;
--end

    IF g_line_rec.line_id = FND_API.G_MISS_NUM THEN
	   g_line_rec.line_id	:= Get_Line;
    END IF;
    -- Fix for 2362210
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE ID = '||G_LINE_REC.LINE_ID ) ;
        oe_debug_pub.add(  'LINE SYS = '||G_LINE_REC.ORIG_SYS_LINE_REF ) ;
        oe_debug_pub.add(  'SOURCE_DOCUMENT_ID = '|| G_LINE_REC.SOURCE_DOCUMENT_ID ) ;
    END IF;
    IF ((g_line_rec.orig_sys_line_ref = FND_API.G_MISS_CHAR
        OR g_line_rec.orig_sys_line_ref IS NULL)
     AND
        nvl(g_line_rec.source_document_id,-999) <> 10) THEN
       g_line_rec.orig_sys_line_ref := 'OE_ORDER_LINES_ALL'||g_line_rec.line_id;
    END IF;

    --{ bug3664313 FP  start: added NULL check
    IF (g_line_rec.orig_sys_document_ref = FND_API.G_MISS_CHAR OR
        g_line_rec.orig_sys_document_ref IS NULL) THEN
       g_line_rec.orig_sys_document_ref := Get_Orig_Sys_Doc_Ref;
    END IF;

    IF g_line_rec.line_category_code = FND_API.G_MISS_CHAR THEN
        g_line_rec.line_category_code	:=
		Get_line_category(g_line_rec,p_old_line_rec);
			  IF l_debug_level  > 0 THEN
			      oe_debug_pub.add(  'AFTER CALLING LINE CATEGORY1' || G_LINE_REC.LINE_CATEGORY_CODE ) ;
			  END IF;

    /* Added for the BUG #3257965.
       For update operation need to raise an error for line_category_code. */

    ELSIF g_line_rec.operation = oe_globals.g_opr_update
          AND NOT OE_GLOBALS.EQUAL(g_line_rec.line_category_code
                               ,p_old_line_rec.line_category_code)
    THEN
      --3365705For retrobill we change the order type from return to order
      -- and the exception shouldn't be raised

      IF (
          g_line_rec.order_source_id = 27 AND
          g_line_rec.retrobill_request_id is NOT NULL ) THEN
         null;
      ELSE
        FND_MESSAGE.SET_NAME('ONT', 'OE_LINE_CAT_CONST');
        OE_MSG_PUB.ADD;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE CATEGORY CONSTRINED' ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- BUG 3646340: Return_reason is a defaultable field and it needs to be
    -- defaulted if the line category changes to RETURN.

    IF g_line_rec.operation = oe_globals.g_opr_create AND
       g_line_rec.line_category_code = 'RETURN' AND
       g_line_rec.return_reason_code IS NULL AND
       NOT OE_GLOBALS.Equal(g_line_rec.line_category_code,
                            p_old_line_rec.line_category_code)
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('LINE CATEGORY CHANGED - REASON set to miss') ;
        END IF;
        g_line_rec.return_reason_code :=  FND_API.G_MISS_CHAR;
    END IF;

    IF g_line_rec.top_model_line_id = FND_API.G_MISS_NUM OR
           NOT OE_GLOBALS.Equal(g_line_rec.line_category_code,
                                p_old_line_rec.line_category_code)
    THEN
       g_line_rec.top_model_line_id    := Get_Top_Model_Line;
    END IF;
    -- 2605065
    IF g_line_rec.top_model_line_id IS NOT NULL THEN
       OE_Order_Cache.clear_top_model_line(g_line_rec.top_model_line_id);
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE ITEM_TYPE' ) ;
    END IF;
    IF g_line_rec.item_type_code = FND_API.G_MISS_CHAR
     or NOT OE_GLOBALS.Equal(g_line_rec.line_category_code,
          p_old_line_rec.line_category_code)
    THEN
         g_line_rec.item_type_code :=
                     Get_Item_Type(g_line_rec, p_old_line_rec);
    END IF;

    -- smc flag defaulting is dependent on get_item_type.
    -- we are not checking for miss_char, because there is
    -- no clear_dep for smc_flag. and we don ot want to
    -- do that because of the way options defaulting work.

    IF NOT OE_GLOBALS.Equal(p_old_line_rec.inventory_item_id,
                                g_line_rec.inventory_item_id) THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING GET_SMC' , 3 ) ;
       END IF;
       g_line_rec.ship_model_complete_flag := Get_SMC_Flag;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING GET_ATO' , 3 ) ;
       END IF;
       g_line_rec.ato_line_id              := Get_Ato_Line;
    END IF;

    IF g_line_rec.ship_model_complete_flag = FND_API.G_MISS_CHAR THEN
        g_line_rec.ship_model_complete_flag	:= Get_SMC_Flag;
    END IF;

    -- model_option_defaulting is dependent on get_top_model_line
    -- get_item_type and get_smc_flag

    IF (g_line_rec.item_type_code <> FND_API.G_MISS_CHAR OR
            g_line_rec.item_type_code is not null) AND
            g_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
    THEN
           model_option_defaulting;
    END IF;

    IF (g_line_rec.line_id = FND_API.G_MISS_NUM)  OR
	 (g_line_rec.line_id IS NULL) THEN
       g_line_rec.org_id :=  OE_GLOBALS.G_ORG_ID;
    END IF;

    IF g_line_rec.booked_flag = FND_API.G_MISS_CHAR THEN
        g_line_rec.booked_flag	:= Get_Booked;
    END IF;

    IF  g_line_rec.model_remnant_flag = FND_API.G_MISS_CHAR THEN
        g_line_rec.model_remnant_flag	:= NULL;
    END IF;

    IF g_line_rec.cancelled_flag = FND_API.G_MISS_CHAR THEN
        g_line_rec.cancelled_flag	:= Get_Cancelled;
    END IF;

    IF g_line_rec.cancelled_quantity = FND_API.G_MISS_NUM THEN
        g_line_rec.cancelled_quantity	:= Get_Cancelled_Quantity;
    END IF;

    IF g_line_rec.component_code = FND_API.G_MISS_CHAR THEN
        g_line_rec.component_code	:= Get_Component;
    END IF;

    IF g_line_rec.fulfilled_quantity = FND_API.G_MISS_NUM THEN
        g_line_rec.fulfilled_quantity	:= Get_Fulfilled_Quantity;
    END IF;

    IF g_line_rec.line_number = FND_API.G_MISS_NUM THEN
        g_line_rec.line_number	:= Get_Line_Number;
    END IF;

    IF g_line_rec.open_flag = FND_API.G_MISS_CHAR THEN
        g_line_rec.open_flag	:= Get_Open;
    END IF;

    /* Added the following lines to fix the bug 2823553 */

    IF g_line_rec.unit_list_price_per_pqty = FND_API.G_MISS_NUM THEN
         g_line_rec.unit_list_price_per_pqty := NULL;
    END IF;

    IF g_line_rec.unit_selling_price_per_pqty = FND_API.G_MISS_NUM THEN
         g_line_rec.unit_selling_price_per_pqty := NULL;
    END IF;

    -- Bug 3737773
    -- Moved the below code after call to defaulting FrameWork.
    -- Start of Code change for Bug 3671715

    --IF g_line_rec.pricing_quantity = FND_API.G_MISS_NUM THEN
    --    g_line_rec.pricing_quantity	:= Get_Pricing_Quantity;
    --END IF;

    IF g_line_rec.shipment_number = FND_API.G_MISS_NUM THEN
        g_line_rec.shipment_number	:= Get_Shipment_Number;
    END IF;

    IF g_line_rec.shipping_interfaced_flag = FND_API.G_MISS_CHAR THEN
        g_line_rec.shipping_interfaced_flag	:= Get_Shipping_Interfaced;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AK BEFORE LINE CATEGORY1' ) ;
    END IF;

/*    IF g_line_rec.line_category_code = FND_API.G_MISS_CHAR THEN
        g_line_rec.line_category_code	:=
		Get_line_category(g_line_rec,p_old_line_rec);
    END IF;*/

/* btea begin This code is commented out to fix bug 1821024 Value should not get
 set before
   calling defaulting frame work.  This value will be set after the defaulting f
ramework

    IF g_line_rec.calculate_price_flag = FND_API.G_MISS_CHAR THEN
        g_line_rec.calculate_price_flag	:= 'Y';
    END IF;
  btea end
*/


    -- Fixed bug 1206047: if user provides a value for the customer (sold_to)
    -- then override it with the value of sold_to from the header
    -- For the initial release, customer should be common on all lines of
    -- an order.
    IF NOT OE_GLOBALS.EQUAL( g_line_rec.sold_to_org_id
						  ,p_old_line_rec.sold_to_org_id )
    THEN
	  g_line_rec.sold_to_org_id := Get_Sold_To;
    END IF;

/* Start Fix for 2420456*/

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'TOLERANCE BELOW : '||G_LINE_REC.SHIP_TOLERANCE_BELOW , 3 ) ;
        oe_debug_pub.add(  'TOLERANCE BELOW : '||P_OLD_LINE_REC.SHIP_TOLERANCE_BELOW , 3 ) ;
    END IF;

    IF nvl(g_line_rec.top_model_line_id,0) <> nvl(g_line_rec.ato_line_id,0) AND
       g_line_rec.top_model_line_id IS NOT NULL THEN

       /* Change for bug 2276993 */
       --p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

       IF  g_line_rec.ship_tolerance_below IS NULL OR
           g_line_rec.ship_tolerance_below = FND_API.G_MISS_NUM OR
           g_line_rec.ship_tolerance_below = p_old_Line_rec.ship_tolerance_below THEN
           g_line_rec.ship_tolerance_below := 0;
           l_set_tolerance_below := 'Y';
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'SET THE TOLERANCES BELOW TO 0 ' , 3 ) ;
           END IF;

       END IF;

       IF  g_line_rec.ship_tolerance_above IS NULL OR
           g_line_rec.ship_tolerance_above = FND_API.G_MISS_NUM OR
           g_line_rec.ship_tolerance_above = p_old_Line_rec.ship_tolerance_above THEN
           g_line_rec.ship_tolerance_above := 0;
           l_set_tolerance_above := 'Y';
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'SET THE TOLERANCES ABOVE TO 0 ' , 3 ) ;
           END IF;

       END IF;

    END IF;

    IF  (nvl(g_line_rec.top_model_line_id,-1) <> nvl(g_line_rec.ato_line_id,-1) AND
        g_line_rec.top_model_line_id IS NOT NULL) AND
        (nvl(g_line_rec.ship_tolerance_below,0) <> 0 OR
        nvl(g_line_rec.ship_tolerance_above,0) <> 0 )THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SHIP TOLERANCES CAN NOT BE SPECIFIED ON PTOS' , 3 ) ;
        END IF;
        fnd_message.set_name('ONT','OE_NO_TOL_FOR_PTO');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

/* END Fix for 2420456*/

    --  Due to incompatibilities in the record type structure
    --  copy the data to a rowtype record format

    OE_LINE_UTIL_EXT.API_Rec_To_Rowtype_Rec
			(p_line_rec => g_line_rec
               ,x_rowtype_rec => l_in_rec);
    OE_LINE_UTIL_EXT.API_Rec_To_Rowtype_Rec
			(p_line_rec => p_old_line_rec
               ,x_rowtype_rec => l_in_old_rec);

    --Perform blanket defaulting
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN

    IF ( l_in_rec.operation =  OE_GLOBALS.G_OPR_CREATE    -- 7152122
       AND trunc( l_in_rec.request_date ) <> trunc(l_in_old_rec.request_date)
       AND l_in_rec.blanket_line_number IS NOT NULL )THEN
        l_in_rec.blanket_line_number := FND_API.G_MISS_NUM;
     END IF;

       Perform_Blanket_Functions
           (p_x_line_rec             => l_in_rec
           ,p_old_line_rec           => l_in_old_rec
           ,p_default_record         => 'N'
           ,x_blanket_request_date   => l_blanket_request_date
           );

    END IF; --pack i

    --  Call the default handler framework to default the missing attributes

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN2 LINE NUMBER :'||L_IN_REC.LINE_NUMBER ) ;
    END IF;

    l_rec := l_in_rec;

    -- add the code below to populate party_type if pay now is enabled and
    -- there exists any defaulting condition template using party_type.
    -- the check here is to avoid performace overhead, so that party_type
    -- information is only loaded when needed.
    IF OE_Prepayment_Util.Get_Installment_Options = 'ENABLE_PAY_NOW'
    AND l_in_rec.sold_to_org_id IS NOT NULL
    AND l_in_rec.sold_to_org_id <> FND_API.G_MISS_NUM
    THEN
      BEGIN
        SELECT 'Y'
        INTO   l_exists
        FROM   oe_def_condn_elems
        WHERE  value_string = 'ORGANIZATION'
        AND    attribute_code = 'PARTY_TYPE'
        AND    rownum = 1;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        null;
      END;

      IF l_exists = 'Y' THEN
	BEGIN
	  SELECT party.party_type
          INTO   l_party_type
          FROM   hz_cust_accounts cust_acct,
	         hz_parties party
          WHERE  party.party_id = cust_acct.party_id
          AND    cust_acct.cust_account_id = l_in_rec.sold_to_org_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          null;
        END;

        l_rec.party_type := l_party_type;

        IF l_debug_level > 0 then
           oe_debug_pub.add('party type in defaulting is: '||l_party_type, 3);
        END IF;
      END IF;
    END IF;


    ONT_LINE_Def_Hdlr.Default_Record
		(p_x_rec	=> l_rec
		, p_initial_rec	=> l_in_rec
		, p_in_old_rec  => l_in_old_rec
		);

    -- More blanket defaulting
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN

       IF l_rec.blanket_number IS NOT NULL
        AND (NOT OE_GLOBALS.EQUAL(l_in_rec.blanket_number,l_rec.blanket_number)
             OR trunc(l_blanket_request_date) <> trunc(l_rec.request_date)
             )
       THEN

          if l_debug_level > 0 then
             oe_debug_pub.add('Blkt Num or Request Date changed');
          end if;

          Perform_Blanket_Functions
           (p_x_line_rec             => l_rec
           ,p_old_line_rec           => l_in_old_rec
           ,p_default_record         => 'Y'
           ,x_blanket_request_date   => l_blanket_request_date
           );

       END IF; --If Blanket Number is not null and changed after defaulting

    END IF; --pack I or greater

    --  copy the data back to a format that is compatible with the API architecture

    OE_LINE_UTIL_EXT.RowType_Rec_to_API_Rec
			(p_record	=> l_rec
			,x_api_rec => p_x_line_rec);

    -- 2707939 --
    IF g_line_rec.override_atp_date_code <> FND_API.G_MISS_CHAR  THEN
       p_x_line_rec.override_atp_date_code := g_line_rec.override_atp_date_code;
    END IF;
    IF g_line_rec.firm_demand_flag <> FND_API.G_MISS_CHAR  THEN
       p_x_line_rec.firm_demand_flag := g_line_rec.firm_demand_flag;
    END IF;

/* Bug 2154960 Added call to default_active_agr_revision() to default
   active Agreement Revision. This API will call process order for Line entity
   again after defaulting Active Agreement Revision to default dependent attributes. */

   IF p_x_line_rec.agreement_id IS NOT NULL AND
       p_x_line_rec.agreement_id <> FND_API.G_MISS_NUM THEN

         IF NOT oe_globals.equal(p_x_line_rec.pricing_date,
                                 p_old_line_rec.pricing_date)
                 OR
                not oe_globals.equal(p_x_line_rec.agreement_id,
                                   p_old_line_rec.agreement_id) THEN

	        IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
                   Default_Active_Agr_Revision
                      ( p_x_line_rec    =>  p_x_line_rec,
                        p_old_line_rec            => p_old_line_rec);
		END IF;

         End If;
    End If;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER DEFAULTING LINE CATEGORY1' || P_X_LINE_REC.LINE_CATEGORY_CODE ) ;
    END IF;

    IF p_x_line_rec.line_category_code = FND_API.G_MISS_CHAR OR  -- added for 2421909
       p_x_line_rec.line_category_code IS NULL  THEN
        p_x_line_rec.line_category_code := Get_line_category(p_x_line_rec,p_old_line_rec);
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER CALLING LINE CATEGORY2' || P_X_LINE_REC.LINE_CATEGORY_CODE , 1 ) ;
        END IF;
    END IF;

    -- Copy the value back to the out record for marketing source code.
    -- These columns are not enabled in the AK tables

    if (p_x_line_rec.marketing_source_code_id = FND_API.G_MISS_NUM) then
	   p_x_line_rec.marketing_source_code_id := NULL;
    else
	   p_x_line_rec.marketing_source_code_id := p_x_line_rec.marketing_source_code_id;
    end if;


    --Code moved for bug 3737773 -starts here
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' Before Defaulting P_Qty and P_Qty_Uom Values:' , 1 ) ;
       oe_debug_pub.add(' Pricing Qty: '|| p_x_line_rec.pricing_quantity ,1);
       oe_debug_pub.add(' Pricing UOM: '|| p_x_line_rec.pricing_quantity_uom,1 );
       oe_debug_pub.add(' Ordered Qty: '|| p_x_line_rec.ordered_quantity ,1);
       oe_debug_pub.add(' Ordered UOM: '|| p_x_line_rec.order_quantity_uom,1);
    END IF;

    -- The code below is not required when order created from UI, but is required for the orders created/update othe sources like Process Order
    -- and Order Import. The Pricing Quantity and UOM is anyways returned by Pricing Engine in case UI. Added condition accordingly for bug 7675652.

    IF NOT (oe_globals.g_ui_flag) THEN -- added for bug 7675652
    IF (p_x_line_rec.pricing_quantity = FND_API.G_MISS_NUM
        OR p_x_line_rec.pricing_quantity is NULL
	OR p_x_line_rec.pricing_quantity = -99999) THEN
       IF (p_x_line_rec.pricing_quantity_uom = FND_API.G_MISS_CHAR
           OR p_x_line_rec.pricing_quantity_uom is NULL) THEN
           p_x_line_rec.pricing_quantity := p_x_line_rec.ordered_quantity;
           p_x_line_rec.pricing_quantity_uom := p_x_line_rec.order_quantity_uom;
       ELSE --Pricing UOM has value but P_QTY is not populated
           p_x_line_rec.pricing_quantity        := Get_Pricing_Quantity;
           --Added the message after review. May be value -99999 is returned when no conversion exists.
           if(p_x_line_rec.pricing_quantity = -99999) Then
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(' Pricing Qty '|| p_x_line_rec.pricing_quantity ,1);
                   oe_debug_pub.add(' Pricing UOM '|| p_x_line_rec.pricing_quantity_uom,1 );
                   oe_debug_pub.add(' Ordered Qty '|| p_x_line_rec.ordered_quantity ,1);
                   oe_debug_pub.add(' Ordered UOM '|| p_x_line_rec.order_quantity_uom,1);
                   oe_debug_pub.add(  ' Conversion does not exists' , 1 ) ;
                END IF;

                FND_MESSAGE.SET_NAME('ONT', 'ONT_PRC_INVALID_UOM_CONVERSION');
                fnd_message.set_token('UOM_TEXT',p_x_line_rec.pricing_quantity_uom);
                OE_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
           END IF;
           -- End of code addition after review.
       END IF; -- End of Pricing UOM check
    ELSE  -- Pricing Quantity has a valid Value
        IF (p_x_line_rec.pricing_quantity_uom = FND_API.G_MISS_CHAR
           OR p_x_line_rec.pricing_quantity_uom is NULL) THEN
           IF (p_x_line_rec.pricing_quantity = p_x_line_rec.ordered_quantity) THEN
              p_x_line_rec.pricing_quantity_uom := p_x_line_rec.order_quantity_uom;
           ELSE --P_QTY is not equal to O_QTY and P_UOM is Not Populated
              --RAISE ERROR
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(' Pricing Qty '|| p_x_line_rec.pricing_quantity ,1);
                   oe_debug_pub.add(' Pricing UOM '|| p_x_line_rec.pricing_quantity_uom,1 );
                   oe_debug_pub.add(' Ordered Qty '|| p_x_line_rec.ordered_quantity ,1);
                   oe_debug_pub.add(' Ordered UOM '|| p_x_line_rec.order_quantity_uom,1);
                   oe_debug_pub.add(  ' Pricing Qty is not equal to Ord Qty and P_UOM is not populated' , 1 ) ;
                END IF;

		IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
                    --Added the message after review.
                    FND_MESSAGE.SET_NAME('ONT', 'ONT_INVALID_ORD_QTY_PRC_QTY');
                    OE_MSG_PUB.Add;
                    RAISE FND_API.G_EXC_ERROR;
 		ELSE  --BUG 4135361
 		   p_x_line_rec.pricing_quantity := p_x_line_rec.ordered_quantity;
 		   p_x_line_rec.pricing_quantity_uom := p_x_line_rec.order_quantity_uom;
 		END IF;
           END IF;
        ELSE -- BOTH P_UOM and P_QTY has valid values Do Nothing
          NULL;
        END IF;
    END IF;
    -- end bug fix 3737773
    END IF; -- added for bug 7675652

     --Btea begin fix bug 1821024,
    if (p_x_line_rec.calculate_price_flag = FND_API.G_MISS_CHAR or
        p_x_line_rec.calculate_price_flag is Null) Then
        p_x_line_rec.calculate_price_flag := 'Y';
    End If;
    --Btea end

    -- Copy the value back to the out record for order source id.
    if (p_x_line_rec.order_source_id = FND_API.G_MISS_NUM) then
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'OEXDLINB - AKSINGH - CHECK FOR G_MISS_NUM' ) ;
	END IF;
            p_x_line_rec.order_source_id := Get_Order_Source_Id;
    else
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'OEXDLINB - AKSINGH - CHECK FOR ELSE' ) ;
	END IF;
	   p_x_line_rec.order_source_id := p_x_line_rec.order_source_id;
    end if;

    -- Copy the value back to the out record for Commitment_Id.
    if (p_x_line_rec.commitment_id = FND_API.G_MISS_NUM) then
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'OEXDLINB - COMMITMENT_ID - CHECK FOR G_MISS_NUM' ) ;
	END IF;
	   p_x_line_rec.commitment_id := NULL;
    else
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'OEXDLINB - COMMITMENT_ID - CHECK FOR ELSE' ) ;
	END IF;
	   p_x_line_rec.commitment_id := p_x_line_rec.commitment_id;
    end if;

    /* 1581620 start */

     IF (p_x_line_rec.tp_context  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_context := NULL;
	END IF;
     IF (p_x_line_rec.tp_attribute1  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute1 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute2  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute2 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute3  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute3 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute4  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute4 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute5  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute5 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute6  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute6 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute7  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute7 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute8  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute8 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute9  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute9 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute10  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute10 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute11  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute11 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute12  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute12 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute13  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute13 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute14  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute14 := NULL;
	END IF;

     IF (p_x_line_rec.tp_attribute15  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.tp_attribute15 := NULL;
	END IF;

-- Commented for bug 8626559
/*
     IF (p_x_line_rec.flow_status_code  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.flow_status_code := NULL;
	END IF;
*/
    -- Bug 8626559: Start
    IF (p_x_line_rec.flow_status_code = Fnd_Api.G_Miss_Char) THEN
      IF (p_x_line_rec.operation = Oe_Globals.G_Opr_Create) THEN
        IF p_x_line_rec.transaction_phase_code = 'N' THEN
          p_x_line_rec.flow_status_code :=  'DRAFT';
        ELSE
          p_x_line_rec.flow_status_code :=  'ENTERED';
        END IF; -- check on p_x_line_rec.transaction_phase_code
      ELSE
        p_x_line_rec.flow_status_code :=  NULL;
      END IF; -- check on p_x_line_rec.operation
    END IF;
    -- Bug 8626559: End


     IF (p_x_line_rec.drop_ship_flag  = FND_API.G_MISS_CHAR) THEN
	   p_x_line_rec.drop_ship_flag := NULL;
	END IF;

    -- OR condition added for 3200019 so orig_sys_shipment_ref
    -- would not get defaulted incorrectly when entering multiple
    -- lines due to caching in SO UI like bug 2362210
    IF (p_x_line_rec.orig_sys_shipment_ref = FND_API.G_MISS_CHAR
        OR p_x_line_rec.orig_sys_shipment_ref IS NULL) AND
       (nvl(p_x_line_rec.source_document_id,0) <> 10) THEN
      IF (OE_CODE_CONTROL.Get_Code_Release_Level >= '110508') AND
         (g_multiple_shipments = 'YES') THEN
        p_x_line_rec.orig_sys_shipment_ref := 'OE_ORDER_LINES_ALL'||p_x_line_rec.line_id||'.'||'1';
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SHIP SYS = '||P_X_LINE_REC.ORIG_SYS_SHIPMENT_REF ) ;
        END IF;
      ELSE
	   p_x_line_rec.orig_sys_shipment_ref := NULL;
      END IF;
    END IF;

    if (p_x_line_rec.change_sequence = FND_API.G_MISS_CHAR) then
	   p_x_line_rec.change_sequence := NULL;
    end if;

    if (p_x_line_rec.customer_line_number = FND_API.G_MISS_CHAR) then
	   p_x_line_rec.customer_line_number := NULL;
    end if;

    if (p_x_line_rec.customer_shipment_number = FND_API.G_MISS_CHAR) then
	   p_x_line_rec.customer_shipment_number := NULL;
    end if;

    if (p_x_line_rec.customer_item_net_price = FND_API.G_MISS_NUM) then
	   p_x_line_rec.customer_item_net_price := NULL;
    end if;

    if (p_x_line_rec.customer_payment_term_id = FND_API.G_MISS_NUM) then
	   p_x_line_rec.customer_payment_term_id := NULL;
    end if;

    if (p_x_line_rec.reference_customer_trx_line_id = FND_API.G_MISS_NUM) then
	   p_x_line_rec.reference_customer_trx_line_id := NULL;
    end if;

    if (p_x_line_rec.sold_from_org_id = FND_API.G_MISS_NUM) then
	   p_x_line_rec.sold_from_org_id := NULL;
    end if;

    if (p_x_line_rec.mfg_lead_time = FND_API.G_MISS_NUM) then
	   p_x_line_rec.mfg_lead_time := NULL;
    end if;

    if (p_x_line_rec.lock_control = FND_API.G_MISS_NUM) then
	   p_x_line_rec.lock_control := NULL;
    end if;

    if (p_x_line_rec.re_source_flag = FND_API.G_MISS_CHAR) then
	   p_x_line_rec.re_source_flag := NULL;
    end if;

    if (p_x_line_rec.model_remnant_flag = FND_API.G_MISS_CHAR) then
	   p_x_line_rec.model_remnant_flag := NULL;
    end if;

    if (p_x_line_rec.shippable_flag = FND_API.G_MISS_CHAR) then
	   p_x_line_rec.shippable_flag := NULL;
    end if;

    /* 1581620 end */

   -- Bug # 5490345

    if (p_x_line_rec.minisite_id = FND_API.G_MISS_NUM) then
	   p_x_line_rec.minisite_id := NULL;
    end if;


--Distributor Orders
   if (p_x_line_rec.End_Customer_ID = FND_API.G_MISS_NUM) then
	   p_x_line_rec.End_Customer_id := NULL;
    end if;
   if (p_x_line_rec.End_Customer_Contact_ID = FND_API.G_MISS_NUM) then
	   p_x_line_rec.End_Customer_Contact_id := NULL;
    end if;
   if (p_x_line_rec.End_Customer_Site_Use_ID = FND_API.G_MISS_NUM) then
	   p_x_line_rec.End_Customer_site_use_id := NULL;
    end if;
    if (p_x_line_rec.IB_OWNER = FND_API.G_MISS_CHAR) then
	   p_x_line_rec.IB_OWNER := NULL;
    end if;
    if (p_x_line_rec.IB_CURRENT_LOCATION = FND_API.G_MISS_CHAR) then
	   p_x_line_rec.IB_CURRENT_LOCATION := NULL;
    end if;
    if (p_x_line_rec.IB_INSTALLED_AT_LOCATION = FND_API.G_MISS_CHAR) then
	   p_x_line_rec.IB_INSTALLED_AT_LOCATION := NULL;
    end if;
--
    if (p_x_line_rec.blanket_number = FND_API.G_MISS_NUM) then
	   p_x_line_rec.blanket_number := NULL;
    end if;

    if (p_x_line_rec.blanket_line_number = FND_API.G_MISS_NUM) then
	   p_x_line_rec.blanket_line_number := NULL;
    end if;

    if (p_x_line_rec.blanket_version_number = FND_API.G_MISS_NUM) then
	   p_x_line_rec.blanket_version_number := NULL;
    end if;

    /* 1783766 start */

    if (p_x_line_rec.fulfillment_set = FND_API.G_MISS_CHAR) then
	   p_x_line_rec.fulfillment_set := NULL;
    end if;

    if (p_x_line_rec.fulfillment_set_id = FND_API.G_MISS_NUM) then
	   p_x_line_rec.fulfillment_set_id := NULL;
    end if;

    /* 1783766 end */

     -- OPM 02/JUN/00 BEGIN - Default process attributes as appropriate
     -- ===============================================================
     IF (p_x_line_rec.ordered_quantity_uom2 = FND_API.G_MISS_CHAR)
      OR (p_x_line_rec.ordered_quantity_uom2 IS NULL) THEN
       p_x_line_rec.ordered_quantity_uom2 :=
         Get_Dual_Uom(p_line_rec => p_x_line_rec); -- INVCONV
     END IF;
-- INVCONV  -- NORMAL DEFAULTING IS USED NOW  SO TAKE OUT
/* -- OPM bug 2553805 do not re-default the preferred_grade if this is a copied order
     IF  ( (p_x_line_rec.preferred_grade = FND_API.G_MISS_CHAR)
      OR (p_x_line_rec.preferred_grade IS NULL) )
      and
         (nvl( p_x_line_rec.source_document_type_id, 0 )  <> 2 )  -- added line for 2553805
      THEN
       p_x_line_rec.preferred_grade :=
         OE_Line_Util.Get_Preferred_Grade(p_line_rec => p_x_line_rec,
                                        p_old_line_rec => p_old_line_rec);
     END IF;    */

     IF (p_x_line_rec.ordered_quantity2 = FND_API.G_MISS_NUM) THEN
          p_x_line_rec.ordered_quantity2 := NULL;
     END IF;

--bug 8563297 kbanddyo FP for 12.1.1 for bug 4065790
/* yannamal Begin OPM Bug 4065790 14/12/04  */
     -- For Dual Uom Item, If ordered_quantity2 is null and ordered_quantity_uom2 is not null and ordered_quantity is not null
     -- after clearing, then at this point of re-defaulting, Added call to routine Oe_Line_Util.Calculate Ordered quantity2 to populate ordered_quantity2.

     IF (p_x_line_rec.ordered_quantity2 IS NULL AND p_x_line_rec.ordered_quantity_uom2 IS NOT NULL AND
          p_x_line_rec.ordered_quantity_uom2 <> FND_API.G_MISS_CHAR AND
          p_x_line_rec.ordered_quantity IS NOT NULL AND  p_x_line_rec.ordered_quantity <> FND_API.G_MISS_NUM) THEN
         -- p_x_line_rec.ordered_quantity2  := OE_LINE_UTIL.Calculate_ordered_quantity2(p_line_rec => p_x_line_rec) ;
        OE_LINE_UTIL.sync_dual_qty(P_X_LINE_REC => p_x_line_rec,P_OLD_LINE_REC=>p_old_line_rec);
     END IF ;

     /* yannamal End OPM Bug 4065790 14/12/04   */


     -- OPM 03/MAY/00 END
     -- =================

    -- Since we are moving to ship method we allways default freight carrier
    -- from ship method and make sure to overide whatever user sends in

    p_x_line_rec.freight_carrier_code :=
		Get_Freight_Carrier(p_line_rec => p_x_line_rec,
					p_old_line_rec => p_old_line_rec);

    -- when order import do not pass item_identifier_type, default to INT

    IF ((p_x_line_rec.item_identifier_type = FND_API.G_MISS_CHAR
        OR p_x_line_rec.item_identifier_type is null) AND
           p_x_line_rec.inventory_item_id is not null AND
           p_x_line_rec.inventory_item_id <> FND_API.G_MISS_NUM)
    THEN
       -- Re-default to INT only if item_identifier_type was previously null
       -- otherwise retain the old value. For example: If item identifier was
       -- CUST and now became null due to dependency on sold_to we should keep the
       -- value as CUST (should not over-write to INT)

           IF p_old_line_rec.item_identifier_type IS NULL THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ITEM_IDENTIFIER_TYPE IS NULL , DEFAULT TO INT' ) ;
             END IF;
             p_x_line_rec.item_identifier_type := 'INT';
           ELSE
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ASSIGNING ITEM_IDENTIFIER_TYPE FROM P_OLD_LINE_REC: '||P_OLD_LINE_REC.ITEM_IDENTIFIER_TYPE ) ;
             END IF;
             p_x_line_rec.item_identifier_type := p_old_line_rec.item_identifier_type;
           END IF;
    END IF;

    IF  p_x_line_rec.source_type_code is null OR
        p_x_line_rec.source_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.source_type_code := OE_GLOBALS.G_SOURCE_INTERNAL;
    END IF;

-- Bug 5708174
     IF p_x_line_rec.source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL  THEN
        p_x_line_rec.subinventory := NULL;
     END IF;
    -- Added to fix the issue in bug 2894486
    IF  p_x_line_rec.line_category_code = 'RETURN' THEN
        p_x_line_rec.source_type_code := OE_GLOBALS.G_SOURCE_INTERNAL;
        p_x_line_rec.ato_line_id := NULL;
    END IF;

    -- Bug 5331971, internal orders shall not be externally sourced
    IF  p_x_line_rec.order_source_id = 10 THEN
        p_x_line_rec.source_type_code := OE_GLOBALS.G_SOURCE_INTERNAL;
    END IF;

   -- This is the new condition aksingh changed on 04/22/01
    IF  NOT OE_GLOBALS.Equal(p_x_line_rec.request_date,
                             p_old_line_rec.request_date)
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXDLINB -1- CHECK FOR G_MISS_DATE FOR REQUEST ' ) ;
        END IF;
        IF p_x_line_rec.request_date <> FND_API.G_MISS_DATE THEN
          -- aksingh added this if for the bug 1745501
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXDLINB -2- CHECK FOR G_MISS_DATE FOR LATEST ' ) ;
        END IF;
          IF OE_GLOBALS.Equal(p_x_line_rec.latest_acceptable_date,
                              p_old_line_rec.latest_acceptable_date)
             OR p_x_line_rec.latest_acceptable_date = FND_API.G_MISS_DATE
          THEN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'OEXDLINB -3- AFTER CHECK FOR G_MISS_DATE FOR LATEST ' ) ;
END IF;
           p_x_line_rec.latest_acceptable_date :=
                    Get_Latest_Acceptable_Date(p_x_line_rec.request_date);
          END IF;
        END IF;
    END IF;

     -- Item Substitution
   IF p_x_line_rec.Original_Inventory_Item_Id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Original_Inventory_Item_Id := Null;
   END IF;

   IF p_x_line_rec.Original_item_identifier_Type = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Original_item_identifier_Type := Null;
   END IF;

   IF p_x_line_rec.Original_ordered_item_id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Original_ordered_item_id := Null;
   END IF;

   IF p_x_line_rec.Original_ordered_item = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Original_ordered_item := Null;
   END IF;

   IF p_x_line_rec.Item_relationship_type = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Item_relationship_type := Null;
   END IF;

   IF p_x_line_rec.Item_substitution_type_code = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Item_substitution_type_code := Null;
   END IF;

   IF p_x_line_rec.Late_Demand_Penalty_Factor = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Late_Demand_Penalty_Factor := Null;
   END IF;

   IF p_x_line_rec.Override_atp_date_code = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Override_atp_date_code := Null;
   END IF;

   IF p_x_line_rec.firm_demand_flag = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.firm_demand_flag := Null;
   END IF;
   --retro{
   IF (p_x_line_rec.retrobill_request_id = FND_API.G_MISS_NUM) THEN
           p_x_line_rec.retrobill_request_id := NULL;
   END IF;
   --retro}

   --Customer Acceptance
     IF p_x_line_rec.CONTINGENCY_ID  = FND_API.G_MISS_NUM THEN
        p_x_line_rec.CONTINGENCY_ID  := NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_EVENT_CODE = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_EVENT_CODE:= NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_EXPIRATION_DAYS = FND_API.G_MISS_NUM THEN
        p_x_line_rec.REVREC_EXPIRATION_DAYS:= NULL  ;
    END IF;
     IF p_x_line_rec.ACCEPTED_QUANTITY = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ACCEPTED_QUANTITY:= NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_COMMENTS = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_COMMENTS:= NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_SIGNATURE = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_SIGNATURE:= NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_SIGNATURE_DATE = FND_API.G_MISS_DATE THEN
        p_x_line_rec.REVREC_SIGNATURE_DATE:= NULL  ;
    END IF;
     IF p_x_line_rec.ACCEPTED_BY = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ACCEPTED_BY:= NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_REFERENCE_DOCUMENT = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_REFERENCE_DOCUMENT:= NULL  ;
    END IF;
     IF p_x_line_rec.REVREC_IMPLICIT_FLAG = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.REVREC_IMPLICIT_FLAG := NULL  ;
    END IF;
  --Customer Acceptance
    -- bug 4203691  recurring charges
    IF p_x_line_rec.charge_periodicity_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.charge_periodicity_code := NULL  ;
    END IF;

    /* The following lines are commented to fix the bug 1409036 */
/*
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.line_type_id,
                            p_old_line_rec.line_type_id)
    THEN
         p_x_line_rec.source_type_code :=
                Get_Source_Type(p_source_type  => p_x_line_rec.source_type_code,
                                p_line_type_id => p_x_line_rec.line_type_id);
    END IF;
*/

    -- get shippable is dependent on model_option_defaulting.
    -- ## bug fix: 1609895, shippable flag from warehouse

    IF p_x_line_rec.shippable_flag is NULL OR
	  p_x_line_rec.shippable_flag = FND_API.G_MISS_CHAR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING GET SHIPPABLE_FLAG ' , 1 ) ;
        END IF;

        p_x_line_rec.shippable_flag	:=
         Get_Shippable( p_line_id            =>  p_x_line_rec.line_id
                       ,p_inventory_item_id  => p_x_line_rec.inventory_item_id
                       ,p_ship_from_org_id   => p_x_line_rec.ship_from_org_id
                       ,p_ato_line_id        => p_x_line_rec.ato_line_id
                       ,p_item_type_code     => p_x_line_rec.item_type_code );
    END IF;

    IF p_x_line_rec.schedule_status_code is null
    AND NOT OE_GLOBALS.Equal(p_old_line_rec.ship_from_org_id,
                             p_x_line_rec.ship_from_org_id) THEN
     IF p_x_line_rec.ship_from_org_id is not null
     THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SETTING RE_SOURCE_FLAG TO N' , 1 ) ;
         END IF;
         p_x_line_rec.re_source_flag := 'N';
     ELSE
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  '1.SETTING RE_SOURCE_FLAG TO NULL' , 1 ) ;
         END IF;
         p_x_line_rec.re_source_flag := '';
     END IF;
    END IF;

/* With the new set and scheduling functionality the set id is created when a
  line is requested into a set and also gets cascaded if the operation is update
 and the children of the model has been already created
  this logic fires only when the scheduling branch profiel is set to Yes */
      -- 4118431

      --IF NVL(FND_PROFILE.VALUE('ONT_BRANCH_SCHEDULING'),'N') = 'Y'--Bug4504362
      IF  p_x_line_rec.line_id > 0  THEN

             oe_Set_util.Default_line_set
             (p_x_line_rec   => p_x_line_rec,
              p_old_line_rec => p_old_line_rec);

         IF p_x_line_rec.line_category_code = 'RETURN'
         OR p_x_line_rec.source_type_code = 'EXTERNAL' THEN

            p_x_line_rec.ship_set_id := NULL;
            p_x_line_rec.ship_set := NULL;
            p_x_line_rec.arrival_set_id := NULL;
            p_x_line_rec.arrival_set := NULL;

         END IF;
      END IF;


    IF  p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    THEN
        model_option_update (p_x_line_rec => p_x_line_rec);
    END IF;

/* Please do not put any code after the following IF fix for 2116098*/

    IF nvl(p_x_line_rec.top_model_line_id,0) <> nvl(p_x_line_rec.ato_line_id,0) AND
       p_x_line_rec.top_model_line_id IS NOT NULL THEN

       /* Change for bug 2276993 */
       --p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

       /* Fix for bug 2420456 */
       IF  l_set_tolerance_below = 'Y' THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'TOLERANCE BELOW : '||P_X_LINE_REC.SHIP_TOLERANCE_BELOW , 3 ) ;
           END IF;
           p_x_line_rec.ship_tolerance_below := 0;
           l_set_tolerance_below := 'N';
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'SET THE TOLERANCES BELOW TO 0 ' , 3 ) ;
           END IF;

       END IF;

       IF  l_set_tolerance_above = 'Y' THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'TOLERANCE BELOW : '||P_X_LINE_REC.SHIP_TOLERANCE_ABOVE , 3 ) ;
           END IF;
           p_x_line_rec.ship_tolerance_above := 0;
           l_set_tolerance_above := 'N';
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'SET THE TOLERANCES ABOVE TO 0 ' , 3 ) ;
           END IF;

       END IF;

    END IF;

    IF p_x_line_rec.user_item_description = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.user_item_description := Null;
    END IF;

    -- to clear out user_item_description if item changes
    -- and user_item_description is not changing.
    IF  NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,
                             p_old_line_rec.inventory_item_id)
        AND OE_GLOBALS.Equal(p_x_line_rec.user_item_description,
                             p_old_line_rec.user_item_description)
        AND p_old_line_rec.user_item_description IS NOT NULL THEN

        p_x_line_rec.user_item_description := NULL;
        FND_MESSAGE.Set_Name('ONT', 'ONT_USER_ITEM_DESC_CLEARED');
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CLEAR OUT USER_ITEM_DESCRIPTION WHEN ITEM CHANGES.' , 3 ) ;
        END IF;

    END IF;

    -- Override List Price
    IF (OE_CODE_CONTROL.Get_Code_Release_Level >= '110510') THEN
       IF p_x_line_rec.original_list_price = FND_API.G_MISS_NUM THEN
          p_x_line_rec.original_list_price := NULL;
       END IF;
    END IF;
    -- Override List Price

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT OE_DEFAULT_LINE.ATTRIBUTES' , 1 ) ;
    END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Attributes'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Attributes;

/*----------------------------------------------------------
FUNCTION Get_Dual_Uom
----------------------------------------------------------- INVCONV REMOVEd from OE_line_util
*/

FUNCTION Get_Dual_Uom(p_line_rec OE_ORDER_PUB.Line_Rec_Type)
RETURN VARCHAR2
IS
-- l_APPS_UOM2  VARCHAR2(3) := NULL; INVCONV
l_status     VARCHAR2(1);
l_msg_count  NUMBER;
l_msg_data   VARCHAR2(2000);
l_item_rec   OE_ORDER_CACHE.item_rec_type;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
       if l_debug_level > 0 then
	oe_debug_pub.add('Enter Get dual uom');
       end if;

IF oe_line_util.dual_uom_control   -- INVCONV  Process_Characteristics
  (p_line_rec.inventory_item_id,p_line_rec.ship_from_org_id,l_item_rec) THEN
  IF l_item_rec.tracking_quantity_ind = 'PS' THEN -- INVCONV
       if l_debug_level > 0 then
					oe_debug_pub.add('Get dual uom - tracking in P and S ');
       end if;
      /* convert 4 digit apps OPM codes to equivalent 3 byte APPS codes */
      /* Primary UM
      GMI_Reservation_Util.Get_AppsUOM_from_OPMUOM
					 (p_OPM_UOM        => l_item_rec.opm_item_um2
					 ,x_Apps_UOM       => l_APPS_UOM2
					 ,x_return_status  => l_status
					 ,x_msg_count      => l_msg_count
					 ,x_msg_data       => l_msg_data);     */
			RETURN l_item_rec.secondary_uom_code;



  else  -- INVCONV
   return NULL;
  END IF;  -- IF l_item_rec.tracking_quantity_ind = 'PS' THEN -- INVCONV


else

	return null;

END IF; -- IF oe_line_util.dual_uom_control   -- INVCONV  Process_Characteristics


       if l_debug_level > 0 then
					oe_debug_pub.add('Get  Dual Uom returns dual UM of ' || l_item_rec.secondary_uom_code);
       end if;

EXCEPTION

WHEN NO_DATA_FOUND THEN

       if l_debug_level > 0 then
	oe_debug_pub.add('No Data Found Get Dual Uom' );
       end if;
RETURN NULL;

WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Get_Dual_Uom'
         );
     END IF;
       if l_debug_level > 0 then
        oe_debug_pub.add('others in get_dual uom', 1);
       end if;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Dual_Uom;

-- Added  Set_Header_Def_Hdlr_rec for bug 4668200
-- This procedure will set the ONT_Header_Def_Hdlr.g_record with the information in header record.
-- An attribute on line can be defaulted based on a PL/SQL API
-- The API can also refer to ONT_Header_Def_Hdlr.g_record
PROCEDURE Set_Header_Def_Hdlr_Rec (p_header_id IN NUMBER)
IS
l_header_rec          OE_Order_PUB.Header_Rec_Type ;
l_rowtype_header_rec  OE_AK_ORDER_HEADERS_V%ROWTYPE;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   if l_debug_level >0 then
      oe_debug_pub.add(' Entering in OE_Default_Test.Set_Header_Def_Hdlr_Rec with Header Id: '|| p_header_id);
   end if ;

IF ( ONT_Header_Def_Hdlr.g_record.header_id IS NULL  OR
     ONT_Header_Def_Hdlr.g_record.header_id <> p_header_id)
THEN
    if OE_ORDER_CACHE.g_header_rec.header_id = p_header_id then
         l_header_rec := OE_ORDER_CACHE.g_header_rec ;
    else
         OE_Header_Util.Query_Row
            (   p_header_id  => p_header_id
	      , x_header_rec => l_header_rec );
    end if ;

    OE_Header_UTIL.API_Rec_To_Rowtype_Rec
	    (  p_header_rec   => l_header_rec
              ,x_rowtype_rec => l_rowtype_header_rec);

    ONT_Header_Def_Hdlr.g_record := l_rowtype_header_rec  ;

    if l_debug_level >0 then
       oe_debug_pub.add('ONT_Header_Def_Hdlr.g_record.Header_id: '||ONT_Header_Def_Hdlr.g_record.Header_id);
    end if ;

END IF ;

   if l_debug_level >0 then
      oe_debug_pub.add(' Exiting OE_Default_Test.Set_Header_Def_Hdlr_Rec ');
   end if ;
EXCEPTION
    When Others Then
	if l_debug_level >0 then
	   oe_debug_pub.add(' Exception in OE_Default_Test.Set_Header_Def_Hdlr_Rec ');
	end if ;
END Set_Header_Def_Hdlr_Rec ;

END OE_Default_Line;

/
