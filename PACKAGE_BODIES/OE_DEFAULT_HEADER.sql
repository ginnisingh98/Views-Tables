--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_HEADER" AS
/* $Header: OEXDHDRB.pls 120.3.12010000.2 2010/04/06 08:26:32 cpati ship $ */

--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Header';

g_header_rec			OE_AK_ORDER_HEADERS_V%ROWTYPE;

FUNCTION GET_FREIGHT_CARRIER(p_Header_rec OE_ORDER_PUB.Header_Rec_Type,
                             p_old_header_rec OE_ORDER_PUB.Header_Rec_Type)
RETURN VARCHAR2
IS
l_freight_code VARCHAR2(80);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Enter get_freight_carrier()',1);
      oe_debug_pub.add('Performance Issue 2830725 fixed',5);
   END IF;
   IF (p_header_rec.shipping_method_code IS NOT NULL AND
       p_header_rec.shipping_method_code <> FND_API.G_MISS_CHAR) AND
      (p_header_rec.ship_from_org_id  IS NOT NULL AND
       p_header_rec.ship_from_org_id<> FND_API.G_MISS_NUM) THEN

    -- 3610480 : Validate freight_carrier_code if shipping_method_code or ship_from_org_id is not null
       IF  (NOT OE_GLOBALS.EQUAL(p_header_rec.shipping_method_code
                                ,p_old_header_rec.shipping_method_code) OR
            NOT OE_GLOBALS.EQUAL(p_header_rec.ship_from_org_id
                                ,p_old_header_rec.ship_from_org_id) OR
            NOT OE_GLOBALS.EQUAL(p_header_rec.freight_carrier_code
                                ,p_old_header_rec.freight_carrier_code)) THEN

           IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509' THEN
              SELECT freight_code
              INTO   l_freight_code
              FROM   wsh_carriers wsh_ca,wsh_carrier_services wsh,
                     wsh_org_carrier_services wsh_org
              WHERE  wsh_org.organization_id      = p_header_rec.ship_from_org_id
              AND    wsh.carrier_service_id       = wsh_org.carrier_service_id
              AND    wsh_ca.carrier_id            = wsh.carrier_id
              AND    wsh.ship_method_code         = p_header_rec.shipping_method_code
              AND    wsh_org.enabled_flag         = 'Y';
           ELSE
              SELECT FREIGHT_CODE
              INTO   l_freight_code
              FROM   wsh_carrier_ship_methods
              WHERE  ship_method_code = p_header_rec.shipping_method_code
              AND    ORGANIZATION_ID = p_header_rec.ship_from_org_id;
           END IF;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Freight carrier returned is '||l_freight_code,5);
           END IF;
           RETURN l_freight_code;
        ELSE
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('into header null condition'||p_header_rec.ship_from_org_id,5);
           END IF;
           RETURN p_header_rec.freight_carrier_code;
        END IF;
    ELSE
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('SHIP FROM OR SHIP METHOD IS NULL/MISSING',5);
       END IF;
       RETURN NULL;
    END IF;

    IF (p_header_rec.shipping_method_code IS NULL OR
        p_header_rec.shipping_method_code = FND_API.G_MISS_CHAR) THEN
        RETURN NULL;
    END IF;
    RETURN p_header_rec.freight_carrier_code;

EXCEPTION

WHEN NO_DATA_FOUND THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('SQL Error : '||sqlerrm,1);
     END IF;
     RETURN NULL;
WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('SQL Other Error : '||sqlerrm,1);
     END IF;
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Get_freight_carrier'
         );
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_FREIGHT_CARRIER;


FUNCTION Get_Order_Category(p_header_rec OE_ORDER_PUB.Header_rec_Type,
					p_old_header_rec OE_ORDER_PUB.Header_rec_Type)
RETURN VARCHAR2
IS
l_category_code varchar2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
/*
 * Always default 1 as the order category
 *
 */
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTER ORDER CATEGORY' ) ;
 END IF;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTER ORDER CATEGORY'|| P_HEADER_REC.ORDER_TYPE_ID ) ;
 END IF;
     Select order_category_code
     into l_category_code
     from
     oe_order_types_v
     where
     order_type_id = p_header_rec.order_type_id;

	IF p_header_rec.operation = oe_globals.g_opr_update THEN
	IF (p_old_header_rec.order_category_code <> FND_API.G_MISS_CHAR AND
		   p_old_header_rec.order_category_code IS NOT NULL ) THEN
		IF NOT OE_GLOBALS.EQUAL(p_old_header_rec.order_category_code,
	       	l_category_code) THEN
                         FND_MESSAGE.SET_NAME('ONT','OE_ORD_CAT_CONST');
                         OE_MSG_PUB.ADD;
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'ORDER CATEGORY CONSTRAINED' ) ;
                         END IF;
                         RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;
	END IF;



    RETURN l_category_code;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          Return 'ORDER';

  --For Bug 3436556
     WHEN FND_API.G_EXC_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
  --End Of Fix

    WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Get_order_category'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Order_Category;

FUNCTION Get_Customer_Preference_set(p_header_rec OE_ORDER_PUB.Header_rec_Type,
					p_old_header_rec OE_ORDER_PUB.Header_rec_Type)
RETURN VARCHAR2
IS
lshipset varchar2(30);
larrivalset varchar2(30);
lsiteuseid number;

Cursor C1 IS
Select  SHIP_SETS_INCLUDE_LINES_FLAG,
ARRIVALSETS_INCLUDE_LINES_FLAG
from hz_cust_accounts
where
cust_account_id = p_header_rec.sold_to_org_id;
Cursor C2 IS
Select  SHIP_SETS_INCLUDE_LINES_FLAG,
ARRIVALSETS_INCLUDE_LINES_FLAG
from hz_cust_site_uses
where
site_use_id = lsiteuseid;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

--IF p_header_rec.operation = oe_globals.g_opr_create THEN

IF NOT OE_GLOBALS.EQUAL(p_header_rec.ship_to_org_id,
                           p_old_header_rec.ship_to_org_id) THEN

lsiteuseid := p_header_rec.ship_to_org_id;
OPEN C2;
FETCH C2 INTO
lshipset,
larrivalset;
CLOSE C2;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ENTER - CUST PREF SET IN SHIP TO' , 1 ) ;
		END IF;
                IF nvl(lshipset,'N') = 'Y' THEN
                        RETURN 'SHIP';
                ELSIF nvl(larrivalset,'N') = 'Y' THEN
                        RETURN 'ARRIVAL';
                END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXIT - CUST PREF SET IN SHIP TO' , 1 ) ;
		END IF;

END IF;

IF NOT OE_GLOBALS.EQUAL(p_header_rec.invoice_to_org_id,
                           p_old_header_rec.invoice_to_org_id) THEN

lsiteuseid := p_header_rec.invoice_to_org_id;
OPEN C2;
FETCH C2 INTO
lshipset,
larrivalset;
CLOSE C2;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ENTER - CUST PREF SET IN BILL TO' , 1 ) ;
		END IF;
                IF nvl(lshipset,'N') = 'Y' THEN
                        RETURN 'SHIP';
                ELSIF nvl(larrivalset,'N') = 'Y' THEN
                        RETURN 'ARRIVAL';
                END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXIT - CUST PREF SET IN BILL TO' , 1 ) ;
		END IF;

END IF;

IF NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id,
			   p_old_header_rec.sold_to_org_id) THEN

/*OPEN C2;
FETCH C2 INTO
lshipset,
larrivalset;
CLOSE C2;
		IF nvl(lshipset,'N') = 'Y' THEN
			RETURN 'SHIP';
		ELSIF nvl(larrivalset,'N') = 'Y' THEN
			RETURN 'ARRIVAL';
		END IF;
*/

OPEN C1;
FETCH C1 INTO
lshipset,
larrivalset;
CLOSE C1;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ENTER - CUST PREF SET IN SOLD TO' , 1 ) ;
		END IF;

		IF nvl(lshipset,'N') = 'Y' THEN
			RETURN 'SHIP';
		ELSIF nvl(larrivalset,'N') = 'Y' THEN
			RETURN 'ARRIVAL';
		END IF;

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SET CODE'|| P_HEADER_REC.CUSTOMER_PREFERENCE_SET_CODE , 1 ) ;
END IF;
		RETURN p_header_rec.customer_preference_set_code;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXIT - CUST PREF SET IN SOLD TO' , 1 ) ;
		END IF;
END IF;



--END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SET CODE'|| P_HEADER_REC.CUSTOMER_PREFERENCE_SET_CODE , 1 ) ;
END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXIT - ' , 1 ) ;
	END IF;

RETURN p_header_rec.customer_preference_set_code;
EXCEPTION

    WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Get_customer_preference_set'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_customer_preference_set;




FUNCTION Get_Booked
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    RETURN 'N';

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

FUNCTION Get_Header
RETURN NUMBER
IS
l_hdr_id	NUMBER := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
/*
 * Select from the sequence
 *
 */
    SELECT  OE_ORDER_HEADERS_S.NEXTVAL
    INTO    l_hdr_id
    FROM    DUAL;

    RETURN l_hdr_id;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_Header'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Header;

FUNCTION Get_Open
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    RETURN 'Y';

END Get_Open;

FUNCTION Get_Org
RETURN NUMBER
IS
l_org_id NUMBER := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

 OE_GLOBALS.Set_Context;
 l_org_id := OE_GLOBALS.G_ORG_ID;

 RETURN l_org_id;

END Get_Org;

FUNCTION Get_Ordered_Date
RETURN DATE
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

/*
 * Always default today as the date ordered
 *
 */

    RETURN SYSDATE;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_Ordered_Date'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Ordered_Date;

FUNCTION Get_Version_Number
RETURN NUMBER
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
/*
 * Always default 1 as the version number prior to 11i10.
 *
 */

    -- QUOTING changes
    IF OE_Code_Control.Code_Release_Level >= '110510' THEN
       RETURN 0;
    ELSE
       RETURN 1;
    END IF;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_Version_Number'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Version_Number;

FUNCTION Get_Order_Source_Id
RETURN NUMBER
IS
--l_order_source_id  NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
/*
  SELECT  ORDER_SOURCE_ID
    INTO  l_order_source_id
    FROM  OE_ORDER_SOURCES
   WHERE name = 'Online';
*/
  RETURN 0;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME          ,
                'Get_Order_Source'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Order_Source_Id;

FUNCTION Get_EM_Message_Id
RETURN NUMBER
IS
l_em_message_id  NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   SELECT OE_XML_MESSAGE_SEQ_S.NEXTVAL
     INTO l_em_message_id
     FROM DUAL;
     RETURN l_em_message_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_EM_Message_Id;

FUNCTION  Get_Contract_Template_Id(p_header_rec OE_ORDER_PUB.Header_rec_Type,
                                     p_old_header_rec OE_ORDER_PUB.Header_rec_Type)
RETURN NUMBER
IS

  l_contract_template_id    NUMBER := NULL;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_result VARCHAR2(1) := 'Y';
BEGIN

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER GET CONTRACT TEMPLATE' ) ;
    END IF;

    BEGIN
      select contract_template_id
      into l_contract_template_id
      from oe_order_types_v
      where order_type_id = p_header_rec.order_type_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_contract_template_id := NULL;
    END;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'l_contract_template_id'|| l_contract_template_id ) ;
       oe_debug_pub.add(  'p_header_rec.order_type_id'|| p_header_rec.order_type_id ) ;
    END IF;

    -- call is_terms_template_valid
    -- check for result and put msg on stack based if N
    -- and set value of l_contract_template_id to NULL

      l_result := OE_CONTRACTS_UTIL.Is_Terms_Template_Valid
		(p_api_version        	=> 1.0,
   	 	 p_init_msg_list      	=> FND_API.G_FALSE,
   	 	 x_return_status       	=> l_return_status,
   	 	 x_msg_count            => l_msg_count,
   	 	 x_msg_data             => l_msg_data,
  	 	 p_doc_type             => 'O',
  	 	 p_template_id          => l_contract_template_id,
  	 	 p_org_id           	=> p_header_rec.org_id
	 	 );

      IF l_contract_template_id IS NOT NULL AND l_result = 'N' THEN

	l_contract_template_id := NULL;

        IF p_header_rec.transaction_phase_code = 'N' THEN
          fnd_message.set_name('ONT','ONT_QUOTE_EXPIRED_TEMPLATE');
          fnd_message.set_token('TEXT1',
			OE_Order_UTIL.Get_Attribute_Name('ORDER_TYPE'));
        ELSE
          fnd_message.set_name('ONT','ONT_ORDER_EXPIRED_TEMPLATE');
          fnd_message.set_token('TEXT1',
			OE_Order_UTIL.Get_Attribute_Name('ORDER_TYPE'));
        END IF;

        OE_MSG_PUB.Add;

      END IF;

    RETURN l_contract_template_id;

EXCEPTION

     WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Get_contract_template_id'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Contract_Template_ID;



--BEGIN Blankets Code Merge

PROCEDURE Clear_And_Re_Default
(p_blanket_number         IN NUMBER
,p_x_header_rec           IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
,p_old_header_rec         IN OE_AK_ORDER_HEADERS_V%ROWTYPE
,p_default_record         IN VARCHAR2
)
IS
  l_header_rec            OE_AK_ORDER_HEADERS_V%ROWTYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('ENTER Clear_And_Re_Default') ;
  END IF;

  -- Identify source attributes
  -- And copy source attribute values from IN parameters
  -- to the new record e.g. blanket number value is copied
  -- to p_x_header_rec.
  IF p_blanket_number IS NOT NULL
     AND NOT OE_GLOBALS.EQUAL(p_blanket_number,
                              p_x_header_rec.blanket_number)
  THEN
     p_x_header_rec.blanket_number := p_blanket_number;
     l_header_rec := p_x_header_rec;
     -- Clear dependents based on this source attribute tbl
     OE_Header_Util.Clear_Dependent_Attr
       (p_attr_id                      => OE_Header_Util.G_BLANKET_NUMBER
       ,p_x_header_rec                 => p_x_header_rec
       ,p_initial_header_rec           => l_header_rec
       ,p_old_header_rec               => p_old_header_rec
       );
  END IF;

  IF p_default_record = 'Y' THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('RE-CALLING ONT_HEADER_DEF_HDLR.DEFAULT_RECORD') ;
     END IF;
     ONT_HEADER_Def_Hdlr.Default_Record
        (p_x_rec	        => p_x_header_rec
        ,p_initial_rec	        => l_header_rec
        ,p_in_old_rec		=> p_old_header_rec
        );
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('EXIT Clear_And_Re_Default') ;
  END IF;

END Clear_And_Re_Default;

FUNCTION Default_Blanket_Number (
   p_sold_to_org_id IN NUMBER,
   p_request_date IN DATE,
   p_cust_po_number IN VARCHAR2
)
RETURN NUMBER
IS
l_blanket_number NUMBER := NULL;
l_request_date   DATE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    if l_debug_level > 0 then
       oe_debug_pub.add('Enter Default_Blanket_Number');
       oe_debug_pub.add('Request Date :'||p_request_date);
    end if;

    if p_request_date = fnd_api.g_miss_date then
       l_request_date := null;
    else
       l_request_date := p_request_date;
    end if;

    SELECT BH.ORDER_NUMBER
    INTO l_blanket_number
    FROM OE_BLANKET_HEADERS BH,OE_BLANKET_HEADERS_EXT BHE
    WHERE     BH.CUST_PO_NUMBER = p_cust_po_number
        AND   BH.SOLD_TO_ORG_ID = p_sold_to_org_id
        AND   BHE.ON_HOLD_FLAG = 'N'
        AND   trunc(nvl(l_request_date,sysdate))
        BETWEEN trunc(BHE.START_DATE_ACTIVE)
        AND   trunc(nvl(BHE.END_DATE_ACTIVE, nvl(l_request_date,sysdate)))
        AND   BH.ORDER_NUMBER = BHE.ORDER_NUMBER
        AND   BH.SALES_DOCUMENT_TYPE_CODE = 'B';

    if l_debug_level > 0 then
       oe_debug_pub.add('Exit Default_Blanket_Number, default :'||l_blanket_number);
    end if;

    RETURN l_blanket_number;

EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    RETURN NULL;
  WHEN NO_DATA_FOUND THEN
    IF l_debug_level  > 0 THEN
         oe_debug_pub.add('No Blanket Number exists for this customer and  po number :'||p_sold_to_org_id || ', ' || p_cust_po_number,2);
    END IF;
  RETURN NULL;
END Default_Blanket_Number;

--END Blankets Code Merge

PROCEDURE Attributes
(   p_x_Header_rec                  IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
,   p_old_Header_rec                IN  OE_Order_PUB.Header_Rec_Type
,   p_iteration                     IN  NUMBER := 1
)
IS

    l_old_header_rec     	OE_AK_ORDER_HEADERS_V%ROWTYPE;
    l_record     	          OE_AK_ORDER_HEADERS_V%ROWTYPE;
    l_operation		     VARCHAR2(30);
    l_set_of_books_rec        OE_Order_Cache.Set_Of_Books_Rec_Type;
    l_Is_Fixed_Rate           Varchar2(1);
    l_cust_pref_set_code varchar2(240)
		:= p_x_Header_rec.customer_preference_Set_code;

    l_blanket_number          NUMBER := NULL;

    l_exists            VARCHAR2(1);
    l_party_type        VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTER OE_DEFAULT_HEADER.ATTRIBUTES' ) ;
    END IF;

    --  Due to incompatibilities in the record type structure
    --  copy the data to a rowtype record format

    OE_Header_UTIL.API_Rec_To_Rowtype_Rec
			(p_header_rec => p_x_header_rec
               ,x_rowtype_rec => g_header_rec);
    OE_Header_UTIL.API_Rec_To_Rowtype_Rec
			(p_header_rec => p_old_header_rec
               ,x_rowtype_rec => l_old_header_rec);

    --  For some fields, get hardcoded defaults based on the operation
    l_operation := p_x_header_rec.operation;

    --  IMPORTANT: For defaulting to work correctly, none of these fields should be
    --  dependent on any other field (Refer OEXUDEPB.pls for the list of dependencies)
    IF l_operation = OE_GLOBALS.G_OPR_CREATE THEN

	   g_header_rec.org_id := Get_Org;

        IF g_header_rec.created_by = FND_API.G_MISS_NUM THEN
		g_header_rec.created_by := FND_GLOBAL.USER_ID;
	   END IF;

--key Transaction Dates
	IF g_header_rec.creation_date = FND_API.G_MISS_DATE THEN
		g_header_rec.creation_date := sysdate ;
	END IF ;
--end

	   IF g_header_rec.header_id = FND_API.G_MISS_NUM THEN
		g_header_rec.header_id	:= Get_Header;
	   END IF;

	   IF g_header_rec.booked_flag = FND_API.G_MISS_CHAR THEN
		g_header_rec.booked_flag	:= Get_Booked;
	   END IF;

	   IF g_header_rec.cancelled_flag = FND_API.G_MISS_CHAR THEN
		g_header_rec.cancelled_flag	:= Get_Cancelled;
	   END IF;

	   IF g_header_rec.open_flag = FND_API.G_MISS_CHAR THEN
		g_header_rec.open_flag	:= Get_Open;
	   END IF;

	   IF g_header_rec.version_number = FND_API.G_MISS_NUM THEN
		g_header_rec.version_number	:= Get_Version_Number;
	   END IF;
           --bug3664313 FP start: added NULL check
           IF ((g_header_rec.orig_sys_document_ref = FND_API.G_MISS_CHAR OR
	        g_header_rec.orig_sys_document_ref IS NULL) AND
               g_header_rec.source_document_id <> 10) THEN
              g_header_rec.orig_sys_document_ref := 'OE_ORDER_HEADERS_ALL'||g_header_rec.header_id;
           END IF;

           IF g_header_rec.order_source_id = FND_API.G_MISS_NUM THEN
             IF g_header_rec.source_document_type_id = FND_API.G_MISS_NUM THEN	  --2991163
               g_header_rec.order_source_id := Get_Order_Source_Id;
	     ELSE
               g_header_rec.order_source_id := g_header_rec.source_document_type_id ; --2991163
             END IF; --2991163
           END IF;


	END IF;

      --BEGIN Blankets Code Merge
      --Blanket Header Hardcoded Defaulting
      --defaults blanket_number based on sold_to_org and customer_po:
      IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN

        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Blanket Number :'||g_header_rec.blanket_number);
           oe_debug_pub.add('Sold To :'||g_header_rec.sold_to_org_id);
           oe_debug_pub.add('Cust PO :'||g_header_rec.cust_po_number);
           oe_debug_pub.add('Old Cust PO :'||l_old_header_rec.cust_po_number);
        END IF;

        IF (g_header_rec.blanket_number IS NULL OR
            g_header_rec.blanket_number = FND_API.G_MISS_NUM) AND
            -- Re-default only if old record does not have a blanket
            -- value either, as defaulting should not over-ride
            -- existing blanket value.
           (l_old_header_rec.blanket_number IS NULL OR
             l_old_header_rec.blanket_number = FND_API.G_MISS_NUM ) AND
            g_header_rec.sold_to_org_id IS NOT NULL AND
            g_header_rec.sold_to_org_id <> FND_API.G_MISS_NUM AND
            (g_header_rec.cust_po_number IS NOT NULL AND
             g_header_rec.cust_po_number <> FND_API.G_MISS_CHAR
             -- Re-default blanket number only if cust PO
             -- OR customer is updated
             AND (NOT OE_GLOBALS.EQUAL(g_header_rec.cust_po_number
                                      ,l_old_header_rec.cust_po_number)
                  OR NOT OE_GLOBALS.EQUAL(g_header_rec.sold_to_org_id
                                      ,l_old_header_rec.sold_to_org_id))
             )
        THEN

           l_blanket_number := Default_Blanket_Number(
                                    g_header_rec.sold_to_org_id,
                                    g_header_rec.request_date,
                                    g_header_rec.cust_po_number);

           IF l_blanket_number IS NOT NULL THEN
              Clear_And_Re_Default
                 (p_blanket_number        => l_blanket_number
                 ,p_x_header_rec          => g_header_rec
                 ,p_old_header_rec        => l_old_header_rec
                 ,p_default_record        => 'N'
                 );
           END IF;

        END IF;

      END IF;
      --END Blankets Code Merge

     --  call the default handler framework to default the missing attributes
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'CALLING ONT_HEADER_DEF_HDLR.DEFAULT_RECORD ' ) ;
	END IF;
	l_record	:= g_header_rec;

        -- add the code below to populate party_type if pay now is enabled and
    -- there exists any defaulting condition template using party_type.
    -- the check here is to avoid performace overhead, so that party_type
    -- information is only loaded when needed.
    IF OE_Prepayment_Util.Get_Installment_Options = 'ENABLE_PAY_NOW'
    AND g_header_rec.sold_to_org_id IS NOT NULL
    AND g_header_rec.sold_to_org_id <> FND_API.G_MISS_NUM
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
          AND    cust_acct.cust_account_id = g_header_rec.sold_to_org_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          null;
        END;

        l_record.party_type := l_party_type;
        g_header_rec.party_type := l_party_type;
        l_old_header_rec.party_type := l_party_type;

        IF l_debug_level > 0 then
           oe_debug_pub.add('party type in defaulting is: '||l_party_type, 3);
        END IF;
      END IF;
    END IF;

        ONT_HEADER_Def_Hdlr.Default_Record
		(p_x_rec	        => l_record
		, p_initial_rec	        => g_header_rec
		, p_in_old_rec		=> l_old_header_rec
		, p_iteration		=> p_iteration
		);
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURNING FROM ONT_HEADER_DEF_HDLR.DEFAULT_RECORD ' ) ;
	END IF;

      --BEGIN Blankets Code Merge
      --Blanket Header Hardcoded Defaulting
      --defaults blanket_number based on sold_to_org and customer_po:
      IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN

        IF l_record.cust_po_number IS NOT NULL
           AND l_record.blanket_number IS NULL
            -- Re-default only if old record does not have a blanket
            -- value either, as defaulting should not over-ride
            -- existing blanket value.
           AND (l_old_header_rec.blanket_number IS NULL OR
                l_old_header_rec.blanket_number = FND_API.G_MISS_NUM )
           AND l_record.sold_to_org_id IS NOT NULL
           AND NOT OE_GLOBALS.EQUAL(l_record.cust_po_number
                                    ,g_header_rec.cust_po_number)
        THEN

           if l_debug_level > 0 then
              oe_debug_pub.add('cust po changed and blkt num is null');
           end if;

           l_blanket_number := Default_Blanket_Number(
                                    l_record.sold_to_org_id,
                                    l_record.request_date,
                                    l_record.cust_po_number);

           IF l_blanket_number IS NOT NULL THEN
              Clear_And_Re_Default
                 (p_blanket_number        => l_blanket_number
                 ,p_x_header_rec          => l_record
                 ,p_old_header_rec        => l_old_header_rec
                 ,p_default_record        => 'Y'
                 );
           END IF;

         END IF;

      END IF;
      --END Blankets Code Merge

     --  copy the data back to a format that is compatible with the API architecture
     OE_Header_UTIL.RowType_Rec_to_API_Rec
			(p_record	=> l_record
			,x_api_rec => p_x_header_rec);

        IF p_x_header_rec.blanket_number = FND_API.G_MISS_NUM THEN
           p_x_header_rec.blanket_number := NULL;
        END IF;
--End Blankets Code Merge

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER DEFAULT CATEGORY'|| P_X_HEADER_REC.ORDER_TYPE_ID ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER DEFAULT CATEGORY'|| P_X_HEADER_REC.ORDER_CATEGORY_CODE ) ;
     END IF;
     IF (p_x_header_rec.order_category_code  = FND_API.G_MISS_CHAR OR
		 p_x_header_rec.order_category_code  IS NULL) THEN

        IF (p_x_header_rec.order_type_id  <> FND_API.G_MISS_NUM AND
            p_x_header_rec.order_type_id  IS NOT NULL )THEN
          	p_x_header_rec.order_category_code :=
			Get_order_category(p_x_header_rec,
					    		p_old_header_rec);
        END IF;

     END IF;

   /* Get Contract template */
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'
       AND p_x_header_rec.order_type_id IS NOT NULL
       AND p_x_header_rec.order_type_id  <> FND_API.G_MISS_NUM
       AND  p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
       AND OE_Contracts_util.check_license = 'Y'
    THEN
       p_x_header_rec.contract_template_id :=
	 Get_contract_template_id(p_x_header_rec,
				  p_old_header_rec);
    END IF;

     -- Get customer preferece
	IF (l_cust_pref_set_code <> FND_API.G_MISS_CHAR AND
	     l_cust_pref_set_code IS NOT NULL) THEN
	p_x_header_rec.customer_preference_set_code := l_cust_pref_set_code;
	END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SET CODE'|| P_X_HEADER_REC.CUSTOMER_PREFERENCE_SET_CODE , 1 ) ;
END IF;

      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL <= '110509' THEN
	p_x_header_rec.customer_preference_set_code
		:= get_customer_preference_set(p_header_rec => p_x_header_rec,
								p_old_header_rec => p_old_header_rec);
      END IF;

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'AFTER SET CODE'|| P_X_HEADER_REC.CUSTOMER_PREFERENCE_SET_CODE , 1 ) ;
END IF;

     -- Assign the marketing_source_code_id value back to the out record. This
     -- done because the column in not enabled in the AK tables for defaulting.

     if p_x_header_rec.marketing_source_code_id = FND_API.G_MISS_NUM then
	   p_x_header_rec.marketing_source_code_id := NULL;
     else
	   p_x_header_rec.marketing_source_code_id := p_x_header_rec.marketing_source_code_id;
     end if;

	p_x_header_rec.freight_carrier_code :=
          Get_Freight_Carrier(p_header_rec => p_x_header_rec,
                         p_old_header_rec => p_old_header_rec);


     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'JPN: MARKETING SOURCE CODE IS:' || P_X_HEADER_REC.MARKETING_SOURCE_CODE_ID ) ;
     END IF;

     --If order currency is different than SOB currency and
     --fixed_rate is detected as Yes, then both of them are
     --Euro or Euro dependent currencies, so default the
     --conversion type to 'EMU FIXED'.

     l_set_of_books_rec :=  OE_Order_Cache.Load_Set_Of_Books;

     IF p_x_header_rec.transactional_curr_code <> l_set_of_books_rec.currency_code
     THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'WHEN CURR CODE IS NOT SAME' ) ;
        END IF;
	   l_Is_Fixed_Rate :=
	      GL_CURRENCY_API.IS_FIXED_RATE(
						 p_x_header_rec.transactional_curr_code,
						 l_set_of_books_rec.currency_code,
						 Nvl(p_x_header_rec.Ordered_Date,Sysdate));

	   IF  (L_Is_Fixed_Rate = 'Y')
	-- AND (p_x_header_rec.Conversion_Type_Code <> 'EMU FIXED')
	   THEN

	      p_x_header_rec.Conversion_Type_Code := 'EMU FIXED';

        END IF;

      END IF;

     /* 1581620 start */

     IF (p_x_header_rec.tp_context  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_context := NULL;
	END IF;
     IF (p_x_header_rec.tp_attribute1  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute1 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute2  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute2 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute3  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute3 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute4  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute4 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute5  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute5 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute6  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute6 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute7  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute7 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute8  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute8 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute9  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute9 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute10  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute10 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute11  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute11 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute12  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute12 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute13  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute13 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute14  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute14 := NULL;
	END IF;

     IF (p_x_header_rec.tp_attribute15  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.tp_attribute15 := NULL;
	END IF;
--Distributor Orders
	IF (p_x_header_rec.IB_OWNER  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.IB_OWNER := NULL;
	END IF;
	IF (p_x_header_rec.IB_INSTALLED_AT_LOCATION  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.IB_INSTALLED_AT_LOCATION := NULL;
	END IF;
	IF (p_x_header_rec.IB_CURRENT_LOCATION  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.IB_CURRENT_LOCATION := NULL;
	END IF;
      IF (p_x_header_rec.END_CUSTOMER_ID  = FND_API.G_MISS_NUM) THEN
	   p_x_header_rec.END_CUSTOMER_ID := NULL;
	END IF;
      IF (p_x_header_rec.END_CUSTOMER_SITE_USE_ID  = FND_API.G_MISS_NUM) THEN
	   p_x_header_rec.END_CUSTOMER_SITE_USE_ID := NULL;
	END IF;
      IF (p_x_header_rec.END_CUSTOMER_CONTACT_ID  = FND_API.G_MISS_NUM) THEN
	   p_x_header_rec.END_CUSTOMER_CONTACT_ID := NULL;
	END IF;
--
	IF (p_x_header_rec.Contract_template_id  = FND_API.G_MISS_NUM) THEN
	   p_x_header_rec.contract_template_id := NULL;
	END IF;

     IF (p_x_header_rec.customer_preference_set_code  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.customer_preference_set_code := NULL;
	END IF;

     IF (p_x_header_rec.credit_card_approval_date  = FND_API.G_MISS_DATE) THEN
	   p_x_header_rec.credit_card_approval_date := NULL;
	END IF;

     IF (p_x_header_rec.flow_status_code  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.flow_status_code := NULL;
	END IF;

     IF (p_x_header_rec.customer_payment_term_id  = FND_API.G_MISS_NUM) THEN
	   p_x_header_rec.customer_payment_term_id := NULL;
	END IF;

     IF (p_x_header_rec.drop_ship_flag  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.drop_ship_flag := NULL;
	END IF;

     IF (p_x_header_rec.change_sequence  = FND_API.G_MISS_CHAR) THEN
	   p_x_header_rec.change_sequence := NULL;
	END IF;

     IF (p_x_header_rec.lock_control  = FND_API.G_MISS_NUM) THEN
	   p_x_header_rec.lock_control := NULL;
     END IF;

     IF (p_x_header_rec.sold_to_phone_id  = FND_API.G_MISS_NUM) THEN
           p_x_header_rec.sold_to_phone_id := NULL;
     END IF;

     IF (p_x_header_rec.contract_source_doc_type_code  = FND_API.G_MISS_CHAR) THEN
           p_x_header_rec.contract_source_doc_type_code := NULL;
     END IF;

     IF (p_x_header_rec.contract_source_document_id  = FND_API.G_MISS_NUM) THEN
           p_x_header_rec.contract_source_document_id := NULL;
     END IF;

     -- Bug 9367257 starts
     IF (p_x_header_rec.cc_instrument_id = FND_API.G_MISS_NUM) THEN
           p_x_header_rec.cc_instrument_id := NULL;
     END IF;
     -- Bug 9367257 ends

     /* 1581620 end */


    -- Bug # 5490345

    IF (p_x_header_rec.minisite_id  = FND_API.G_MISS_NUM) THEN
           p_x_header_rec.minisite_id := NULL;
    END IF;

     -- QUOTING changes

     IF l_debug_level > 0 THEN
        oe_debug_pub.add('Transaction phase after defaulting fwk :'
              ||p_x_header_rec.transaction_phase_code);
     END IF;

     IF oe_code_control.code_release_level >= '110510' THEN

        IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

           IF p_x_header_rec.transaction_phase_code is null then
              p_x_header_rec.transaction_phase_code := 'F';
           ELSIF p_x_header_rec.transaction_phase_code = 'N' THEN
              p_x_header_rec.ordered_date := null;
              -- Default initial flow status to 'Draft' for negotiation orders
              IF p_x_header_rec.flow_status_code = 'ENTERED' OR
                 p_x_header_rec.flow_status_code = FND_API.G_MISS_CHAR
              THEN
                 p_x_header_rec.flow_status_code := 'DRAFT';
              END IF;
 -- bug 3854887
          ELSIF p_x_header_rec.transaction_phase_code = 'F' THEN
              p_x_header_rec.quote_date := null;
              -- Default initial flow status to 'Entered' for fulfillment orders
              IF p_x_header_rec.flow_status_code = 'DRAFT' OR
                 p_x_header_rec.flow_status_code = FND_API.G_MISS_CHAR
              THEN
                 p_x_header_rec.flow_status_code := 'ENTERED';
              END IF;
           END IF;

	END IF;

	-- If expiration date is changing, update time component to midnight
        -- i.e. to 23:59:59
        IF NOT OE_GLOBALS.EQUAL(p_x_header_rec.expiration_date
                           ,p_old_header_rec.expiration_date)
	THEN
	   p_x_header_rec.expiration_date :=
	        trunc(p_x_header_rec.expiration_date,'DD') +
                                          ((24*60*60)-1)/(24*60*60);
	END IF;

     END IF;

     IF l_debug_level > 0 THEN
        oe_debug_pub.add('Transaction phase at end :'
              ||p_x_header_rec.transaction_phase_code);
     END IF;

     -- QUOTING changes END
     IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
        -- bug 3417786
        IF (nvl(p_x_header_rec.xml_message_id, FND_API.G_MISS_NUM)= FND_API.G_MISS_NUM AND
           p_x_header_rec.order_source_id = 0) THEN
               p_x_header_rec.xml_message_id := Get_EM_Message_Id;
        END IF;
     END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXIT OE_DEFAULT_HEADER.ATTRIBUTES' ) ;
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
    	    ( G_PKG_NAME,
    	      'Attributes'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Attributes;

END OE_Default_Header  ;

/
