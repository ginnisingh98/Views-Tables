--------------------------------------------------------
--  DDL for Package Body OE_VALUE_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALUE_TO_ID" AS
/* $Header: OEXSVIDB.pls 120.9.12010000.2 2009/08/19 05:49:13 amimukhe ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Value_To_Id';

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  conversion functions.
--
--  DO NOT REMOVE

PROCEDURE Get_Attr_Tbl
IS
	I                             NUMBER:=0;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    FND_API.g_attr_tbl.DELETE;

--  START GEN attributes

--  Generator will append new attributes before end generate comment.
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Key_Flex';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'accounting_rule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'agreement';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'conversion_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'deliver_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'deliver_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_class';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'fob_point';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'freight_carrier';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'freight_terms';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'intermed_ship_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'intermed_ship_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoice_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoice_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoicing_rule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_source';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'over_ship_reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'payment_term';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_list';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'return_reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipment_priority';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipping_method';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_from_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sold_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sold_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'source_document_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_exempt';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_exempt_reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_point';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transactional_curr';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'automatic';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_adjustment';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'dw_update_advice';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quota';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'salesrep';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sales_credit_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sales_credit';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'component';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'component_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'top_model_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'customer_dock';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'customer_trx_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_bucket_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'dep_plan_required';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'inventory_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line_category';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'link_to_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'option';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'project';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rla_schedule_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'task';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'veh_cus_item_cum_key';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'visible_demand';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lot_serial';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'appear_on_ack';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'appear_on_invoice';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'charge';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'charge_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cost_or_charge';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'departure';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'estimated';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoiced';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'parent_charge';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'returnable';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_group';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'payment_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'credit_card';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'commitment';
--  END GEN attributes

END Get_Attr_Tbl;

--  Prototypes for value_to_id Functions.

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
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_VALUE_TO_ID.KEY_FLEX' , 1 ) ;
	END IF;
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

        OE_MSG_PUB.Add;
        l_id := FND_API.G_MISS_NUM;

    END IF;

    RETURN l_id;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Key_Flex'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Key_Flex;

--  Generator will append new prototypes before end generate comment.


--  Accounting_Rule

FUNCTION Accounting_Rule
(   p_accounting_rule               IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_accounting_rule IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT RULE_ID
    INTO l_id
    FROM OE_RA_RULES_V
    WHERE NAME = p_accounting_rule;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accounting_rule_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Accounting_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Accounting_Rule;

--  Agreement

FUNCTION Agreement
(   p_agreement                     IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_agreement IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT AGREEMENT_ID
    INTO l_id
    FROM OE_AGREEMENTS_V
    WHERE NAME = p_agreement
    AND sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active, sysdate);

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Agreement'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Agreement;

--  Conversion_Type

FUNCTION Conversion_Type
(   p_conversion_type               IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_conversion_type IS NULL
    THEN
        RETURN NULL;
    END IF;

        SELECT  CONVERSION_TYPE
        INTO    l_code
        FROM    OE_GL_DAILY_CONVERSION_TYPES_V
        WHERE   USER_CONVERSION_TYPE = p_conversion_type;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','conversion_type_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Conversion_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Conversion_Type;

--  Deliver_To_Contact

FUNCTION Deliver_To_Contact
(   p_deliver_to_contact            IN  VARCHAR2
,   p_deliver_to_org_id             IN  NUMBER
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_deliver_to_contact IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT /* MOAC_SQL_CHANGE */ CON.CONTACT_ID
    INTO l_id
    FROM   OE_CONTACTS_V  CON
         , HZ_ROLE_RESPONSIBILITY ROL
         , HZ_CUST_ACCT_SITES   ADDR
         , HZ_CUST_SITE_USES_ALL   SU
    WHERE CON.NAME = p_deliver_to_contact
    AND   CON.CONTACT_ID = ROL.CUST_ACCOUNT_ROLE_ID(+)
    AND   CON.CUSTOMER_ID = ADDR.CUST_ACCOUNT_ID
    AND   ADDR.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
    AND   SU.SITE_USE_ID = p_deliver_to_org_id
    AND   NVL(ROL.RESPONSIBILITY_TYPE, 'DELIVER_TO') IN ('DELIVER_TO','SHIP_TO');
    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_contact_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Deliver_To_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Deliver_To_Contact;

--  Deliver_To_Org

FUNCTION Deliver_To_Org
(   p_deliver_to_address1           IN  VARCHAR2
,   p_deliver_to_address2           IN  VARCHAR2
,   p_deliver_to_address3           IN  VARCHAR2
,   p_deliver_to_address4           IN  VARCHAR2
,   p_deliver_to_location           IN  VARCHAR2
,   p_deliver_to_org                IN  VARCHAR2
,   p_sold_to_org_id                IN  NUMBER
,   p_deliver_to_city               IN VARCHAR2 DEFAULT NULL
,   p_deliver_to_state              IN VARCHAR2 DEFAULT NULL
,   p_deliver_to_postal_code        IN VARCHAR2 DEFAULT NULL
,   p_deliver_to_country            IN VARCHAR2 DEFAULT NULL
,   p_deliver_to_customer_id        IN number   default null
) RETURN NUMBER
IS

l_id                          NUMBER;
lcustomer_relations varchar2(1);

CURSOR c_deliver_to_org_id(in_sold_to_org_id number) IS
    SELECT ORGANIZATION_ID
    FROM OE_DELIVER_TO_ORGS_V
    WHERE ADDRESS_LINE_1  = p_deliver_to_address1
	 AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address2, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address3, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address4, fnd_api.g_miss_char)
	 AND nvl(TOWN_OR_CITY,fnd_api.g_miss_char) =
           nvl( p_deliver_to_city, fnd_api.g_miss_char)
	 AND nvl(STATE,fnd_api.g_miss_char) =
           nvl( p_deliver_to_state, fnd_api.g_miss_char)
	 AND nvl(POSTAL_CODE,fnd_api.g_miss_char) =
           nvl( p_deliver_to_postal_code, fnd_api.g_miss_char)
	 AND nvl(COUNTRY,fnd_api.g_miss_char) =
           nvl( p_deliver_to_country, fnd_api.g_miss_char)
      AND STATUS = 'A'
	AND ADDRESS_STATUS ='A' --bug 2752321
      AND CUSTOMER_ID = in_sold_to_org_id;

CURSOR C1(in_sold_to_org_id number) IS
    SELECT /*MOAC_SQL_NO_CHANGE*/ ORGANIZATION_ID
    FROM OE_DELIVER_TO_ORGS_V
    WHERE  ADDRESS_LINE_1  = p_deliver_to_address1
	 AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address2, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address3,fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address4,fnd_api.g_miss_char)
	 AND nvl(TOWN_OR_CITY,fnd_api.g_miss_char) =
           nvl( p_deliver_to_city, fnd_api.g_miss_char)
	 AND nvl(STATE,fnd_api.g_miss_char) =
           nvl( p_deliver_to_state, fnd_api.g_miss_char)
	 AND nvl(POSTAL_CODE,fnd_api.g_miss_char) =
           nvl( p_deliver_to_postal_code, fnd_api.g_miss_char)
	 AND nvl(COUNTRY,fnd_api.g_miss_char) =
           nvl( p_deliver_to_country, fnd_api.g_miss_char)
      AND STATUS = 'A'
      AND ADDRESS_STATUS ='A' --bug 2752321
      AND CUSTOMER_ID IN
  (
                    SELECT in_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE WHERE
                    RELATED_CUST_ACCOUNT_ID = in_sold_to_org_id
                        and ship_to_flag = 'Y' and status='A');
CURSOR C2 IS
    SELECT ORGANIZATION_ID
    FROM OE_DELIVER_TO_ORGS_V
    WHERE  ADDRESS_LINE_1  = p_deliver_to_address1
	 AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address2, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address3,fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address4,fnd_api.g_miss_char)
	 AND nvl(TOWN_OR_CITY,fnd_api.g_miss_char) =
           nvl( p_deliver_to_city, fnd_api.g_miss_char)
	 AND nvl(STATE,fnd_api.g_miss_char) =
           nvl( p_deliver_to_state, fnd_api.g_miss_char)
	 AND nvl(POSTAL_CODE,fnd_api.g_miss_char) =
           nvl( p_deliver_to_postal_code, fnd_api.g_miss_char)
	 AND nvl(COUNTRY,fnd_api.g_miss_char) =
           nvl( p_deliver_to_country, fnd_api.g_miss_char)
      AND STATUS = 'A'
	  AND ADDRESS_STATUS ='A';--bug 2752321

   l_org varchar2(100);
   l_deliver_to_customer_id number;
   l_sold_to_org_id number;
   l_dummy number;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DELIVER_TO_ADDRESS1='||P_DELIVER_TO_ADDRESS1||' ADDRESS4='||P_DELIVER_TO_ADDRESS4||' DELIVER_TO_CUST_ID='||P_DELIVER_TO_CUSTOMER_ID ) ;
    END IF;
    IF  nvl( p_deliver_to_address1,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_deliver_to_address2,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_deliver_to_address3,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_deliver_to_address4,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_deliver_to_customer_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
    AND nvl( p_sold_to_org_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
    THEN
        RETURN NULL;
    END IF;

  lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER RELATIONS='||LCUSTOMER_RELATIONS ) ;
  END IF;
  l_sold_to_org_id := p_sold_to_org_id;


   IF nvl(p_deliver_to_Customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'DELIVER_TO_CUST_ID IS NULL' ) ;
     END IF;
     l_deliver_to_customer_id := null;
   ELSE
     l_deliver_to_customer_id := p_deliver_to_customer_id;
   END IF;

   -- checking if the deliver_to_customer_id is sent.
   -- If the customer relationship is on, then the customers should be related
   IF l_deliver_to_customer_id is not null then
     IF lcustomer_relations = 'N' AND
       nvl(l_deliver_to_customer_id,FND_API.G_MISS_NUM) <> nvl(p_sold_to_org_id,FND_API.G_MISS_NUM) then

                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'CUSTOMER RELATION IS NOT ON , BUT THE SOLD_TO_ORG '|| 'AND DELIVER_TO_CUSTOMER ARE NOT SAME' ) ;
                          END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;


        -- checking if the deliver_to_customer_id is sent.
        -- If the customer rel is on, then the customers should be related
     ELSIF lcustomer_relations = 'Y' AND
      nvl(l_deliver_to_customer_id,FND_API.G_MISS_NUM) <> nvl(p_sold_to_org_id,FND_API.G_MISS_NUM) then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUST REL IS ON , BUT DIFF CUST IDS' ) ;
      END IF;

        BEGIN
          SELECT 1
            INTO l_dummy
           FROM hz_cust_acct_relate
          WHERE cust_account_id = l_deliver_to_customer_id
           AND  related_cust_account_id = l_sold_to_org_id
			and ship_to_flag = 'Y' and status='A';
        EXCEPTION

          WHEN NO_DATA_FOUND THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'CUSTOMER RELATION IS ON , BUT THE '|| 'SOLD_TO_ORG AND DELIVER_TO_CUSTOMER ARE NOT RELATED' ) ;
                    END IF;
                fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_org_id');
                OE_MSG_PUB.Add;

            END IF;

            RETURN FND_API.G_MISS_NUM;
        END;

     END IF; -- type of cust rel

   END IF; -- check for diff deliver_cust_id

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_SOLD_TO_ORG_ID 0='||L_SOLD_TO_ORG_ID ) ;
       oe_debug_pub.add(  'L_DELIVER_TO_CUST_ID ='||L_DELIVER_TO_CUSTOMER_ID ) ;
   END IF;

   IF l_deliver_to_customer_id is not null then
     l_sold_to_org_id := l_deliver_to_Customer_id;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_DELIVER_TO_CUSTOMER_ID IS NOT NULL' ) ;
     END IF;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_SOLD_TO_ORG_ID ='||L_SOLD_TO_ORG_ID ) ;
   END IF;

   -- the second condition is added to make sure that if the user passes the
   -- deliver_to_customer information , it should be used to validate the
   -- even if the  customer relationship is on

   IF lcustomer_relations = 'N'  OR
      (lcustomer_relations = 'Y' and l_deliver_to_customer_id is not null ) OR
      (lcustomer_relations = 'A' and l_deliver_to_customer_id is not null )THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IF REL = N OR .. Y AND INV_CUST_ID NOT NULL' ) ;
    END IF;

    OPEN c_deliver_to_org_id(l_sold_to_org_id);
    FETCH c_deliver_to_org_id
     INTO l_id;
    IF c_deliver_to_org_id%FOUND then
        CLOSE c_deliver_to_org_id;
        return l_id;
    ELSE
        SELECT ORGANIZATION_ID
        INTO l_id
        FROM OE_DELIVER_TO_ORGS_V
        WHERE ADDRESS_LINE_1  = p_deliver_to_address1
	 AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address2, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address3, fnd_api.g_miss_char)
	 AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
           nvl( p_deliver_to_address4, fnd_api.g_miss_char)
         AND STATUS = 'A'
	  AND ADDRESS_STATUS ='A' --bug 2752321
         AND CUSTOMER_ID = l_sold_to_org_id;
    END IF;

    CLOSE c_deliver_to_org_id;
    RETURN l_id;

  ELSIF lcustomer_relations = 'Y' THEN

    OPEN C1(l_sold_to_org_id);
    FETCH C1
     INTO l_id;

    IF C1%FOUND then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'FOUND' ) ;
        END IF;
        CLOSE C1;
        return l_id;
    ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NOT FOUND' ) ;
        END IF;
        l_org :=mo_global.get_current_org_id ;  --MOAC
        --select userenv('CLIENT_INFO') into l_org from dual;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ORG='||L_ORG ) ;
        END IF;

        SELECT /*MOAC_SQL_NO_CHANGE*/ ORGANIZATION_ID
        INTO l_id
        FROM OE_DELIVER_TO_ORGS_V
        WHERE  ADDRESS_LINE_1  = p_deliver_to_address1
	 AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address2, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address3,fnd_api.g_miss_char)
	 AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
          NVL( p_deliver_to_address4, fnd_api.g_miss_char)
          AND STATUS = 'A'
	   AND ADDRESS_STATUS ='A' --bug 2752321
          AND CUSTOMER_ID IN
                    (SELECT l_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE WHERE
                    RELATED_CUST_ACCOUNT_ID = l_sold_to_org_id
                        and ship_to_flag = 'Y' and status='A');
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER SELECT FOUND='||L_ID ) ;
        END IF;
    END IF;

    CLOSE C1;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURNING FROM THE FUNCTION' ) ;
    END IF;
    RETURN l_id;


  ELSIF lcustomer_relations = 'A' THEN

    OPEN C2;
    FETCH C2
     INTO l_id;

    IF C2%FOUND then
        CLOSE C2;
        return l_id;
    ELSE
        SELECT ORGANIZATION_ID
        INTO l_id
        FROM OE_DELIVER_TO_ORGS_V
        WHERE  ADDRESS_LINE_1  = p_deliver_to_address1
	 AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address2, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_deliver_to_address3,fnd_api.g_miss_char)
	 AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
          NVL( p_deliver_to_address4, fnd_api.g_miss_char)
          AND STATUS = 'A'
	  AND ADDRESS_STATUS ='A'; --bug 2752321
    END IF;

    CLOSE C2;
    RETURN l_id;

   END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF c_deliver_to_org_id%ISOPEN then
            CLOSE c_deliver_to_org_id;
        END IF;

        IF C1%ISOPEN then
            CLOSE C1;
        END IF;

        IF C2%ISOPEN then
            CLOSE C2;
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF c_deliver_to_org_id%ISOPEN then
            CLOSE c_deliver_to_org_id;
        END IF;

        IF C1%ISOPEN then
            CLOSE C1;
        END IF;

        IF C2%ISOPEN then
            CLOSE C2;
        END IF;


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Deliver_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Deliver_To_Org;

--  Fob_Point

FUNCTION Fob_Point
(   p_fob_point                     IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
        l_lookup_type      	      VARCHAR2(80) := 'FOB';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_fob_point IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LOOKUP_CODE
    INTO    l_code
    FROM    OE_AR_LOOKUPS_V
    WHERE   MEANING = p_fob_point
    AND     LOOKUP_TYPE = l_lookup_type;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fob_point_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Fob_Point'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fob_Point;

--  Freight_Terms

FUNCTION Freight_Terms
(   p_freight_terms                 IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
        l_lookup_type      	      VARCHAR2(80) := 'FREIGHT_TERMS';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_freight_terms IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LOOKUP_CODE
    INTO    l_code
    FROM    OE_LOOKUPS
    WHERE   MEANING = p_freight_terms
    AND     LOOKUP_TYPE = l_lookup_type;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Freight_Terms'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Freight_Terms;

--  Intermediate_Ship_To_Contact

FUNCTION Intermed_Ship_To_Contact
(   p_intermed_ship_to_contact               IN  VARCHAR2
,   p_intermed_ship_to_org_id                IN  NUMBER
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_intermed_ship_to_contact IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_intermed_ship_to_contact

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','intermed_ship_to_contact_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Intermed_Ship_To_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Intermed_Ship_To_Contact;

--  Intermed_Ship_To_Org

FUNCTION Intermed_Ship_To_Org
(   p_intermed_ship_to_address1              IN  VARCHAR2
,   p_intermed_ship_to_address2              IN  VARCHAR2
,   p_intermed_ship_to_address3              IN  VARCHAR2
,   p_intermed_ship_to_address4              IN  VARCHAR2
,   p_intermed_ship_to_location              IN  VARCHAR2
,   p_intermed_ship_to_org                   IN  VARCHAR2
,   p_sold_to_org_id                         IN  NUMBER
,   p_intermed_ship_to_city                  IN VARCHAR2 DEFAULT NULL
,   p_intermed_ship_to_state                 IN VARCHAR2 DEFAULT NULL
,   p_intermed_ship_to_postal_code           IN VARCHAR2 DEFAULT NULL
,   p_intermed_ship_to_country               IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN
    l_id := Ship_To_Org
               ( p_ship_to_address1=>p_intermed_ship_to_address1
               , p_ship_to_address2=>p_intermed_ship_to_address2
               , p_ship_to_address3=>p_intermed_ship_to_address3
               , p_ship_to_address4=>p_intermed_ship_to_address4
               , p_ship_to_location=>p_intermed_ship_to_location
               , p_ship_to_org=>p_intermed_ship_to_org
               , p_sold_to_org_id=>p_sold_to_org_id
               , p_ship_to_city=>p_intermed_ship_to_city
               , p_ship_to_state=>p_intermed_ship_to_state
               , p_ship_to_postal_code=>p_intermed_ship_to_postal_code
               , p_ship_to_country=>p_intermed_ship_to_country
               );
    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','intermed_ship_to_org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Intermed_Ship_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Intermed_Ship_To_Org;

-- Invoice_To_Contact

FUNCTION Invoice_To_Contact
(   p_invoice_to_contact            IN  VARCHAR2
,   p_invoice_to_org_id             IN  NUMBER
) RETURN NUMBER
IS
	l_id                          NUMBER;
        l_usage     VARCHAR2(30);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_invoice_to_contact IS NULL
    THEN
        RETURN NULL;
    END IF;

    l_usage := 'BILL_TO';

    SELECT /* MOAC_SQL_CHANGE */ CON.CONTACT_ID
    INTO l_id
    FROM   OE_CONTACTS_V  CON
         , HZ_ROLE_RESPONSIBILITY ROL
         , HZ_CUST_ACCT_SITES   ADDR
         , HZ_CUST_SITE_USES_ALL   SU
    WHERE CON.NAME = p_invoice_to_contact
    AND   CON.CONTACT_ID = ROL.CUST_ACCOUNT_ROLE_ID(+)
    AND   CON.CUSTOMER_ID = ADDR.CUST_ACCOUNT_ID
    AND   ADDR.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
    AND   SU.SITE_USE_ID = p_invoice_to_org_id
    AND   NVL(ROL.RESPONSIBILITY_TYPE, l_usage) = l_usage;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_contact_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_To_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_To_Contact;

--  Invoice_To_Org

FUNCTION Invoice_To_Org
(   p_invoice_to_address1           IN  VARCHAR2
,   p_invoice_to_address2           IN  VARCHAR2
,   p_invoice_to_address3           IN  VARCHAR2
,   p_invoice_to_address4           IN  VARCHAR2
,   p_invoice_to_location           IN  VARCHAR2
,   p_invoice_to_org                IN  VARCHAR2
,   p_sold_to_org_id                IN  NUMBER
,   p_invoice_to_city               IN VARCHAR2 DEFAULT NULL
,   p_invoice_to_state              IN VARCHAR2 DEFAULT NULL
,   p_invoice_to_postal_code        IN VARCHAR2 DEFAULT NULL
,   p_invoice_to_country            IN VARCHAR2 DEFAULT NULL
,   p_invoice_to_customer_id        IN number   default null
) RETURN NUMBER
IS

l_id                          NUMBER;
lcustomer_relations varchar2(1);

CURSOR c_invoice_to_org_id(in_sold_to_org_id number) IS
    SELECT ORGANIZATION_ID
    FROM OE_INVOICE_TO_ORGS_V
    WHERE  ADDRESS_LINE_1  = p_invoice_to_address1
	 AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address2, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address3,fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address4,fnd_api.g_miss_char)
	 AND nvl(TOWN_OR_CITY,fnd_api.g_miss_char) =
           nvl( p_invoice_to_city, fnd_api.g_miss_char)
	 AND nvl(STATE,fnd_api.g_miss_char) =
           nvl( p_invoice_to_state, fnd_api.g_miss_char)
	 AND nvl(POSTAL_CODE,fnd_api.g_miss_char) =
           nvl( p_invoice_to_postal_code, fnd_api.g_miss_char)
	 AND nvl(COUNTRY,fnd_api.g_miss_char) =
           nvl( p_invoice_to_country, fnd_api.g_miss_char)
      AND STATUS = 'A'
	 AND ADDRESS_STATUS ='A' --bug 2752321
      AND CUSTOMER_ID = in_sold_to_org_id;

CURSOR C1(in_sold_to_org_id in number) IS
    SELECT /*MOAC_SQL_NO_CHANGE*/ ORGANIZATION_ID
    FROM OE_INVOICE_TO_ORGS_V
    WHERE  ADDRESS_LINE_1  = p_invoice_to_address1
	 AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address2, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address3,fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address4,fnd_api.g_miss_char)
	 AND nvl(TOWN_OR_CITY,fnd_api.g_miss_char) =
           nvl( p_invoice_to_city, fnd_api.g_miss_char)
	 AND nvl(STATE,fnd_api.g_miss_char) =
           nvl( p_invoice_to_state, fnd_api.g_miss_char)
	 AND nvl(POSTAL_CODE,fnd_api.g_miss_char) =
           nvl( p_invoice_to_postal_code, fnd_api.g_miss_char)
	 AND nvl(COUNTRY,fnd_api.g_miss_char) =
           nvl( p_invoice_to_country, fnd_api.g_miss_char)
      AND STATUS = 'A'
      AND ADDRESS_STATUS ='A' --bug 2752321
      AND CUSTOMER_ID IN
  (
                    SELECT in_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE WHERE
                    RELATED_CUST_ACCOUNT_ID = in_sold_to_org_id
                        and bill_to_flag = 'Y' and status='A');
CURSOR C2 IS
    SELECT ORGANIZATION_ID
    FROM OE_INVOICE_TO_ORGS_V
    WHERE  ADDRESS_LINE_1  = p_invoice_to_address1
	 AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address2, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address3,fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address4,fnd_api.g_miss_char)
	 AND nvl(TOWN_OR_CITY,fnd_api.g_miss_char) =
           nvl( p_invoice_to_city, fnd_api.g_miss_char)
	 AND nvl(STATE,fnd_api.g_miss_char) =
           nvl( p_invoice_to_state, fnd_api.g_miss_char)
	 AND nvl(POSTAL_CODE,fnd_api.g_miss_char) =
           nvl( p_invoice_to_postal_code, fnd_api.g_miss_char)
	 AND nvl(COUNTRY,fnd_api.g_miss_char) =
           nvl( p_invoice_to_country, fnd_api.g_miss_char)
      AND STATUS = 'A'
	AND ADDRESS_STATUS ='A';--bug 2752321

   l_org varchar2(100);
   l_invoice_to_customer_id number;
   l_sold_to_org_id number;
   l_dummy number;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INVOICE_TO_ORG VALUES ARE SOLD_TO_ORG_ID='||P_SOLD_TO_ORG_ID||' ADDRESS1='||P_INVOICE_TO_ADDRESS1||' ADDRESS4='||P_INVOICE_TO_ADDRESS4||' INVOICE_TO_CUST_ID='||P_INVOICE_TO_CUSTOMER_ID ) ;
    END IF;

    IF  nvl( p_invoice_to_address1,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_invoice_to_address2,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_invoice_to_address3,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_invoice_to_address4,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_invoice_to_customer_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
    AND nvl( p_sold_to_org_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
    THEN
        RETURN NULL;
    END IF;

 lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CUSTOMER RELATIONS='||LCUSTOMER_RELATIONS ) ;
    END IF;
    l_sold_to_org_id := p_sold_to_org_id;


   IF nvl(p_invoice_to_Customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INVOICE_TO_CUST_ID IS NULL' ) ;
     END IF;
     l_invoice_to_customer_id := null;
   ELSE
     l_invoice_to_customer_id := p_invoice_To_customer_id;
   END IF;

   -- checking if the invoice_to_customer_id is sent.
   -- If the customer relationship is on, then the customers should be related
   IF l_invoice_to_customer_id is not null then
     IF lcustomer_relations = 'N' AND
       nvl(l_invoice_to_customer_id,FND_API.G_MISS_NUM) <> nvl(p_sold_to_org_id,FND_API.G_MISS_NUM) then

                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'CUSTOMER RELATION IS NOT ON , BUT THE SOLD_TO_ORG '|| 'AND INVOICE_TO_CUSTOMER ARE NOT SAME' ) ;
                          END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;


        -- checking if the invoice_to_customer_id is sent.
        -- If the customer rel is on, then the customers should be related
     ELSIF lcustomer_relations = 'Y' AND
      nvl(l_invoice_to_customer_id,FND_API.G_MISS_NUM) <> nvl(p_sold_to_org_id,FND_API.G_MISS_NUM) then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUST REL IS ON , BUT DIFF CUST IDS' ) ;
      END IF;

        BEGIN
          SELECT 1
            INTO l_dummy
           FROM hz_cust_acct_relate
          WHERE cust_account_id = l_invoice_to_customer_id
           AND  related_cust_account_id = l_sold_to_org_id and
			bill_to_flag ='Y' and status='A';

        EXCEPTION

          WHEN NO_DATA_FOUND THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'CUSTOMER RELATION IS ON , BUT THE '|| 'SOLD_TO_ORG AND INVOICE_TO_CUSTOMER ARE NOT RELATED' ) ;
                    END IF;
                fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_org_id');
                OE_MSG_PUB.Add;

            END IF;

            RETURN FND_API.G_MISS_NUM;
        END;

     END IF; -- type of cust rel

   END IF; -- check for diff inv_cust_id

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_SOLD_TO_ORG_ID 0='||L_SOLD_TO_ORG_ID ) ;
       oe_debug_pub.add(  'L_INVOICE_TO_CUST_ID ='||L_INVOICE_TO_CUSTOMER_ID ) ;
   END IF;

   IF l_invoice_to_customer_id is not null then
     l_sold_to_org_id := l_invoice_to_Customer_id;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_INVOICE_TO_CUSTOMER_ID IS NOT NULL' ) ;
     END IF;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_SOLD_TO_ORG_ID ='||L_SOLD_TO_ORG_ID ) ;
   END IF;

   -- the second condition is added to make sure that if the user passes the
   -- invoice_to_customer information , it should be used to validate the
   -- even if the  customer relationship is on

   IF lcustomer_relations = 'N'  OR
      (lcustomer_relations = 'Y' and l_invoice_to_customer_id is not null ) OR
      (lcustomer_relations = 'A' and l_invoice_to_customer_id is not null )THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IF REL = N OR .. Y AND INV_CUST_ID NOT NULL' ) ;
    END IF;

    OPEN c_invoice_to_org_id(l_sold_to_org_id);
    FETCH c_invoice_to_org_id
     INTO l_id;

    IF c_invoice_to_org_id%FOUND then
        CLOSE c_invoice_to_org_id;
        return l_id;
    ELSE
        SELECT ORGANIZATION_ID
        INTO l_id
        FROM OE_INVOICE_TO_ORGS_V
        WHERE  ADDRESS_LINE_1  = p_invoice_to_address1
	 AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address2, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address3,fnd_api.g_miss_char)
	 AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
          NVL( p_invoice_to_address4, fnd_api.g_miss_char)
          AND STATUS = 'A'
	      AND ADDRESS_STATUS ='A' --bug 2752321
          AND CUSTOMER_ID = l_sold_to_org_id;
    END IF;

    CLOSE c_invoice_to_org_id;
    RETURN l_id;

   ELSIF lcustomer_relations = 'Y' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CUST REL = Y INV_CUST_ID='||L_INVOICE_TO_CUSTOMER_ID ) ;
    END IF;
    OPEN C1(l_sold_to_org_id);
    FETCH C1
     INTO l_id;

    IF C1%FOUND then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'FOUND' ) ;
        END IF;
        CLOSE C1;
        return l_id;
    ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NOT FOUND' ) ;
        END IF;
	l_org :=mo_global.get_current_org_id ; --MOAC
        --select userenv('CLIENT_INFO') into l_org from dual;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ORG='||L_ORG ) ;
        END IF;
        SELECT /*MOAC_SQL_NO_CHANGE*/ ORGANIZATION_ID
        INTO l_id
        FROM OE_INVOICE_TO_ORGS_V
        WHERE  ADDRESS_LINE_1  = p_invoice_to_address1
	 AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address2, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address3,fnd_api.g_miss_char)
	 AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
          NVL( p_invoice_to_address4, fnd_api.g_miss_char)
          AND STATUS = 'A'
	    AND ADDRESS_STATUS ='A' --bug 2752321
          AND CUSTOMER_ID IN
                    (SELECT l_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE WHERE
                    RELATED_CUST_ACCOUNT_ID = l_sold_to_org_id
                        and bill_to_flag = 'Y' and status='A');
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER SELECT FOUND='||L_ID ) ;
        END IF;
    END IF;

    CLOSE C1;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURNING FROM THE FUNCTION' ) ;
    END IF;
    RETURN l_id;

		null;

   ELSIF lcustomer_relations = 'A' THEN

    OPEN C2;
    FETCH C2
     INTO l_id;

    IF C2%FOUND then
        CLOSE C2;
        return l_id;
    ELSE
        SELECT ORGANIZATION_ID
        INTO l_id
        FROM OE_INVOICE_TO_ORGS_V
        WHERE  ADDRESS_LINE_1  = p_invoice_to_address1
	 AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address2, fnd_api.g_miss_char)
	 AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_invoice_to_address3,fnd_api.g_miss_char)
	 AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
          NVL( p_invoice_to_address4, fnd_api.g_miss_char)
          AND STATUS = 'A'
	  AND ADDRESS_STATUS ='A';--bug 2752321
    END IF;

    CLOSE C2;
    RETURN l_id;

   END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF c_invoice_to_org_id%ISOPEN then
            CLOSE c_invoice_to_org_id;
        END IF;

        IF C1%ISOPEN then
            CLOSE C1;
        END IF;

        IF C2%ISOPEN then
            CLOSE C2;
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF c_invoice_to_org_id%ISOPEN then
            CLOSE c_invoice_to_org_id;
        END IF;

        IF C1%ISOPEN then
            CLOSE C1;
        END IF;

        IF C2%ISOPEN then
            CLOSE C2;
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_To_Org;

--  Invoicing_Rule

FUNCTION Invoicing_Rule
(   p_invoicing_rule                IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_invoicing_rule IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT RULE_ID
    INTO l_id
    FROM OE_RA_RULES_V
    WHERE NAME = p_invoicing_rule;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoicing_rule_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoicing_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoicing_Rule;

--  Order_Source

FUNCTION Order_Source
(   p_order_source                  IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_order_source IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  ORDER_SOURCE_ID
    INTO    l_id
    FROM    OE_ORDER_SOURCES
    WHERE   NAME = p_order_source;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_order_source

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_source_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Source'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Source;

--  Order_Type

FUNCTION Order_Type
(   p_order_type                    IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_order_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  ORDER_TYPE_ID
    INTO    l_id
    FROM    OE_ORDER_TYPES_v
    WHERE   NAME = p_order_type;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_type_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Type;

--  Payment_Term

FUNCTION Payment_Term
(   p_payment_term                  IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_payment_term IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  TERM_ID
    INTO    l_id
    FROM    OE_RA_TERMS_V
    WHERE   NAME = p_payment_term;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_term_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Term'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Term;

--  Price_List

FUNCTION Price_List
(   p_price_list                    IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_price_list IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LIST_HEADER_ID
    INTO    l_id
    FROM    qp_list_headers_vl
    WHERE   NAME = p_price_list
       AND  list_type_code in ('PRL', 'AGR');

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List;

--  Shipment_Priority

FUNCTION Shipment_Priority
(   p_shipment_priority             IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
        l_lookup_type      	      VARCHAR2(80) := 'SHIPMENT_PRIORITY';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_shipment_priority IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LOOKUP_CODE
    INTO    l_code
    FROM    OE_LOOKUPS
    WHERE   MEANING = p_shipment_priority
    AND     LOOKUP_TYPE =l_lookup_type;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','shipment_priority_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipment_Priority'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipment_Priority;

--  Ship_From_Org

FUNCTION Ship_From_Org
(   p_ship_from_address1            IN  VARCHAR2
,   p_ship_from_address2            IN  VARCHAR2
,   p_ship_from_address3            IN  VARCHAR2
,   p_ship_from_address4            IN  VARCHAR2
,   p_ship_from_location            IN  VARCHAR2
,   p_ship_from_org                 IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_ship_from_address1 IS NULL
    OR  p_ship_from_address2 IS NULL
    OR  p_ship_from_address3 IS NULL
    OR  p_ship_from_address4 IS NULL
    OR  p_ship_from_location IS NULL
    OR  p_ship_from_org IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_ship_from_address1
    --  AND     XXXX_val_column = p_ship_from_address2
    --  AND     XXXX_val_column = p_ship_from_address3
    --  AND     XXXX_val_column = p_ship_from_address4
    --  AND     XXXX_val_column = p_ship_from_location
    --  AND     XXXX_val_column = p_ship_from_org

--bug#4287327
       BEGIN
        select distinct organization_id INTO l_id from oe_ship_from_orgs_v
        where organization_code= p_ship_from_org;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                select distinct organization_id INTO l_id from oe_ship_from_orgs_v
                where name= p_ship_from_org;
        WHEN TOO_MANY_ROWS THEN
        l_id := fnd_api.g_miss_num;
        END;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_from_org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_From_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_From_Org;

--  Ship_To_Contact

FUNCTION Ship_To_Contact
(   p_ship_to_contact               IN  VARCHAR2
,   p_ship_to_org_id                IN  NUMBER
) RETURN NUMBER
IS
	l_id                          NUMBER;
        l_usage     VARCHAR2(30);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_ship_to_contact IS NULL
    THEN
        RETURN NULL;
    END IF;

    l_usage := 'SHIP_TO';

    SELECT /* MOAC_SQL_CHANGE */ CON.CONTACT_ID
    INTO l_id
    FROM   OE_CONTACTS_V  CON
         , HZ_ROLE_RESPONSIBILITY ROL
         , HZ_CUST_ACCT_SITES   ADDR
         , HZ_CUST_SITE_USES_ALL   SU
    WHERE CON.NAME = p_ship_to_contact
    AND   CON.CONTACT_ID = ROL.CUST_ACCOUNT_ROLE_ID(+)
    AND   CON.CUSTOMER_ID = ADDR.CUST_ACCOUNT_ID
    AND   ADDR.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
    AND   SU.SITE_USE_ID = p_ship_to_org_id
    AND   NVL(ROL.RESPONSIBILITY_TYPE, l_usage) = l_usage;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_contact_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_To_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_To_Contact;

FUNCTION Inventory_Org
(   p_inventory_org               IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_inventory_org IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  organization_id
    INTO    l_id
    FROM    org_organization_definitions
    WHERE   organization_name = p_inventory_org;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'inventory_org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Org;

--  Ship_To_Org

FUNCTION Ship_To_Org
(   p_ship_to_address1              IN  VARCHAR2
,   p_ship_to_address2              IN  VARCHAR2
,   p_ship_to_address3              IN  VARCHAR2
,   p_ship_to_address4              IN  VARCHAR2
,   p_ship_to_location              IN  VARCHAR2
,   p_ship_to_org                   IN  VARCHAR2
,   p_sold_to_org_id                IN  NUMBER
,   p_ship_to_city                  IN VARCHAR2 DEFAULT NULL
,   p_ship_to_state                 IN VARCHAR2 DEFAULT NULL
,   p_ship_to_postal_code           IN VARCHAR2 DEFAULT NULL
,   p_ship_to_country               IN VARCHAR2 DEFAULT NULL
,   p_ship_to_customer_id        IN number   default null
) RETURN NUMBER
IS

l_id                          NUMBER;
lcustomer_relations varchar2(1);


CURSOR c_ship_to_org_id(in_sold_to_org_id number) IS
    SELECT ORGANIZATION_ID
    FROM OE_SHIP_TO_ORGS_V
    WHERE ADDRESS_LINE_1  = p_ship_to_address1
	    AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_ship_to_address2, fnd_api.g_miss_char)
	    AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_ship_to_address3, fnd_api.g_miss_char)
	    AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_ship_to_address4, fnd_api.g_miss_char)
	    AND nvl( town_or_city, fnd_api.g_miss_char) =
           nvl( p_ship_to_city, fnd_api.g_miss_char)
	    AND nvl( state, fnd_api.g_miss_char) =
           nvl( p_ship_to_state, fnd_api.g_miss_char)
	    AND nvl( postal_code, fnd_api.g_miss_char) =
           nvl( p_ship_to_postal_code, fnd_api.g_miss_char)
	    AND nvl( country, fnd_api.g_miss_char) =
           nvl( p_ship_to_country, fnd_api.g_miss_char)
      AND STATUS = 'A'
      AND ADDRESS_STATUS ='A' --bug 2752321
      AND CUSTOMER_ID = in_sold_to_org_id;

CURSOR C1(in_sold_to_org_id number) IS
    SELECT /*MOAC_SQL_NO_CHANGE*/ ORGANIZATION_ID
    FROM OE_SHIP_TO_ORGS_V
    WHERE ADDRESS_LINE_1  = p_ship_to_address1
	    AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_ship_to_address2, fnd_api.g_miss_char)
	    AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_ship_to_address3, fnd_api.g_miss_char)
	    AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_ship_to_address4, fnd_api.g_miss_char)
	    AND nvl( town_or_city, fnd_api.g_miss_char) =
           nvl( p_ship_to_city, fnd_api.g_miss_char)
	    AND nvl( state, fnd_api.g_miss_char) =
           nvl( p_ship_to_state, fnd_api.g_miss_char)
	    AND nvl( postal_code, fnd_api.g_miss_char) =
           nvl( p_ship_to_postal_code, fnd_api.g_miss_char)
	    AND nvl( country, fnd_api.g_miss_char) =
           nvl( p_ship_to_country, fnd_api.g_miss_char)
      AND STATUS = 'A'
      AND ADDRESS_STATUS ='A' --bug 2752321
      AND CUSTOMER_ID in(
                    SELECT in_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE WHERE
                    RELATED_CUST_ACCOUNT_ID = in_sold_to_org_id
                        and ship_to_flag = 'Y' and status='A');

CURSOR C2 IS
    SELECT ORGANIZATION_ID
    FROM OE_SHIP_TO_ORGS_V
    WHERE ADDRESS_LINE_1  = p_ship_to_address1
	    AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_ship_to_address2, fnd_api.g_miss_char)
	    AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_ship_to_address3, fnd_api.g_miss_char)
	    AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_ship_to_address4, fnd_api.g_miss_char)
	    AND nvl( town_or_city, fnd_api.g_miss_char) =
           nvl( p_ship_to_city, fnd_api.g_miss_char)
	    AND nvl( state, fnd_api.g_miss_char) =
           nvl( p_ship_to_state, fnd_api.g_miss_char)
	    AND nvl( postal_code, fnd_api.g_miss_char) =
           nvl( p_ship_to_postal_code, fnd_api.g_miss_char)
	    AND nvl( country, fnd_api.g_miss_char) =
           nvl( p_ship_to_country, fnd_api.g_miss_char)
      AND STATUS = 'A'
	AND ADDRESS_STATUS ='A';

   l_ship_to_customer_id number;
   l_sold_to_org_id number;
   l_dummy number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP_TO_ADDRESS1='||P_SHIP_TO_ADDRESS1||' ADDRESS4='||P_SHIP_TO_ADDRESS4||' SHIP_TO_CUST_ID='||P_SHIP_TO_CUSTOMER_ID||' sold_to_org_id='||p_sold_to_org_id ) ;
    END IF;

    IF  nvl( p_ship_to_address1,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_ship_to_address2,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_ship_to_address3,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_ship_to_address4,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_ship_to_customer_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
    AND nvl( p_sold_to_org_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
    THEN
        RETURN NULL;
    END IF;


 lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CUSTOMER RELATIONS='||LCUSTOMER_RELATIONS ) ;
    END IF;
    l_sold_to_org_id := p_sold_to_org_id;


   IF nvl(p_ship_to_Customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP_TO_CUST_ID IS NULL' ) ;
     END IF;
     l_ship_to_customer_id := null;
   ELSE
     l_ship_to_customer_id := p_ship_To_customer_id;
   END IF;

   -- checking if the ship_to_customer_id is sent.
   -- If the customer relationship is on, then the customers should be related
   IF l_ship_to_customer_id is not null then
     IF lcustomer_relations = 'N' AND
       nvl(l_ship_to_customer_id,FND_API.G_MISS_NUM) <> nvl(p_sold_to_org_id,FND_API.G_MISS_NUM) then

                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'CUSTOMER RELATION IS NOT ON , BUT THE SOLD_TO_ORG '|| 'AND SHIP_TO_CUSTOMER ARE NOT SAME' ) ;
                          END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;


        -- checking if the ship_to_customer_id is sent.
        -- If the customer rel is on, then the customers should be related
     ELSIF lcustomer_relations = 'Y' AND
      nvl(l_ship_to_customer_id,FND_API.G_MISS_NUM) <> nvl(p_sold_to_org_id,FND_API.G_MISS_NUM) then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUST REL IS ON , BUT DIFF CUST IDS' ) ;
      END IF;

        BEGIN
          SELECT 1
            INTO l_dummy
           FROM hz_cust_acct_relate
          WHERE cust_account_id = l_ship_to_customer_id
           AND  related_cust_account_id = l_sold_to_org_id
		and ship_to_flag='Y' and status='A';
        EXCEPTION

          WHEN NO_DATA_FOUND THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'CUSTOMER RELATION IS ON , BUT THE '|| 'SOLD_TO_ORG AND SHIP_TO_CUSTOMER ARE NOT RELATED' ) ;
                    END IF;
                fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_org_id');
                OE_MSG_PUB.Add;

            END IF;

            RETURN FND_API.G_MISS_NUM;
        END;

     END IF; -- type of cust rel

   END IF; -- check for diff ship_cust_id

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_SOLD_TO_ORG_ID 0='||L_SOLD_TO_ORG_ID ) ;
       oe_debug_pub.add(  'L_SHIP_TO_CUST_ID ='||L_SHIP_TO_CUSTOMER_ID ) ;
   END IF;

   IF l_ship_to_customer_id is not null then
     l_sold_to_org_id := l_ship_to_Customer_id;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_SHIP_TO_CUSTOMER_ID IS NOT NULL' ) ;
     END IF;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_SOLD_TO_ORG_ID ='||L_SOLD_TO_ORG_ID ) ;
   END IF;

   -- the second condition is added to make sure that if the user passes the
   -- ship_to_customer information , it should be used to validate the
   -- even if the  customer relationship is on

   IF lcustomer_relations = 'N'  OR
      (lcustomer_relations = 'Y' and l_ship_to_customer_id is not null ) OR
      (lcustomer_relations = 'A' and l_ship_to_customer_id is not null )THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IF REL = N OR .. Y AND INV_CUST_ID NOT NULL' ) ;
    END IF;

    OPEN c_ship_to_org_id(l_sold_to_org_id);
    FETCH c_ship_to_org_id
     INTO l_id;
    IF c_ship_to_org_id%FOUND then
        CLOSE c_ship_to_org_id;
        return l_id;
    ELSE

        SELECT ORGANIZATION_ID
        INTO l_id
        FROM OE_SHIP_TO_ORGS_V
        WHERE ADDRESS_LINE_1  = p_ship_to_address1
	    AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_ship_to_address2, fnd_api.g_miss_char)
	    AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_ship_to_address3, fnd_api.g_miss_char)
	    AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
           nvl( p_ship_to_address4, fnd_api.g_miss_char)
          AND STATUS = 'A'
	  AND ADDRESS_STATUS ='A' --bug 2752321
          AND CUSTOMER_ID = l_sold_to_org_id;
    END IF;
    CLOSE c_ship_to_org_id;

    RETURN l_id;

ELSIF lcustomer_relations = 'Y' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CUST REL = Y SHIP_CUST_ID='||L_SHIP_TO_CUSTOMER_ID ) ;
    END IF;
    OPEN C1(l_sold_To_org_id);
    FETCH C1
     INTO l_id;
    IF C1%FOUND then
        CLOSE C1;
        return l_id;
    ELSE

        SELECT /*MOAC_SQL_NO_CHANGE*/ ORGANIZATION_ID
        INTO l_id
        FROM OE_SHIP_TO_ORGS_V
        WHERE ADDRESS_LINE_1  = p_ship_to_address1
	    AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_ship_to_address2, fnd_api.g_miss_char)
	    AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_ship_to_address3, fnd_api.g_miss_char)
	    AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
           nvl( p_ship_to_address4, fnd_api.g_miss_char)
          AND STATUS = 'A'
	  AND ADDRESS_STATUS ='A' --bug 2752321
          AND CUSTOMER_ID
 in (
                    SELECT l_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE WHERE
                    RELATED_CUST_ACCOUNT_ID = l_sold_to_org_id
                        and ship_to_flag = 'Y' and status='A');

    END IF;
    CLOSE C1;

    RETURN l_id;

ELSIF lcustomer_relations = 'A' THEN
    OPEN C2;
    FETCH C2
     INTO l_id;
    IF C2%FOUND then
        CLOSE C2 ;
        return l_id;
    ELSE

        SELECT ORGANIZATION_ID
        INTO l_id
        FROM OE_SHIP_TO_ORGS_V
        WHERE ADDRESS_LINE_1  = p_ship_to_address1
	    AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_ship_to_address2, fnd_api.g_miss_char)
	    AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_ship_to_address3, fnd_api.g_miss_char)
	    AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
           nvl( p_ship_to_address4, fnd_api.g_miss_char)
          AND STATUS = 'A'
	  AND ADDRESS_STATUS ='A';
    END IF;
	CLOSE C2;

    RETURN l_id;
END IF;
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF c_ship_to_org_id%ISOPEN then
            CLOSE c_ship_to_org_id;
        END IF;

        IF C1%ISOPEN then
            CLOSE C1;
        END IF;

        IF C2%ISOPEN then
            CLOSE C2;
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF c_ship_to_org_id%ISOPEN then
            CLOSE c_ship_to_org_id;
        END IF;

        IF C1%ISOPEN then
            CLOSE C1;
        END IF;

        IF C2%ISOPEN then
            CLOSE C2;
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_To_Org;

--  Sold_To_Contact

FUNCTION Sold_To_Contact
(   p_sold_to_contact               IN  VARCHAR2
,   p_sold_to_org_id                IN  NUMBER
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_sold_to_contact IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT CONTACT_ID
    INTO l_id
    FROM OE_CONTACTS_V
    WHERE NAME = p_sold_to_contact
      AND CUSTOMER_ID = p_sold_to_org_id
     AND STATUS ='A'    /*bug 6711184*/
     AND ROWNUM=1;      /*bug 6711184*/

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_contact_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sold_To_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sold_To_Contact;


--  site Customer
FUNCTION site_customer
(   p_site_customer                   IN  VARCHAR2
,   p_site_customer_number               IN  VARCHAR2
,   p_type                            in varchar2
) RETURN NUMBER IS

	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'SITE CUSTOMER = '||P_SITE_CUSTOMER|| ' NUMBER='||P_SITE_CUSTOMER_NUMBER|| ' TYPE='||P_TYPE ) ;
                    END IF;

    IF  nvl(p_site_customer,fnd_api.g_miss_char) = fnd_api.g_miss_char
	   AND nvl(p_site_customer_number,fnd_api.g_miss_char) = fnd_api.g_miss_char
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SITE CUSTOMER RETURNING NULL' ) ;
        END IF;
        RETURN NULL;
    END IF;

    IF nvl(p_site_customer_number,fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SITE CUSTOMER SELECTING CUST NUM='||P_SITE_CUSTOMER_NUMBER ) ;
      END IF;


      SELECT ORGANIZATION_ID
      INTO l_id
      FROM OE_SOLD_TO_ORGS_V
      WHERE CUSTOMER_NUMBER = p_site_customer_number
	     AND status='A'; -- added for bug 3651505

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER SELECTING SITE_CUSTOMER' ) ;
      END IF;

    ELSE

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SITE CUSTOMER SELECTING CUST='||P_SITE_CUSTOMER ) ;
      END IF;

      --Bug 3631191
      /* SELECT ORGANIZATION_ID
      INTO l_id
      FROM OE_SOLD_TO_ORGS_V
      WHERE NAME = p_site_customer;*/

      SELECT CUST_ACCT.CUST_ACCOUNT_ID INTO l_id
      FROM HZ_PARTIES PARTY,
           HZ_CUST_ACCOUNTS CUST_ACCT
      WHERE CUST_ACCT.PARTY_ID=PARTY.PARTY_ID
      AND PARTY.PARTY_NAME = p_site_customer
	  AND CUST_ACCT.status ='A'; -- added for bug 3651505

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER SELECTING SITE_CUSTOMER' ) ;
      END IF;

    END IF;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Site_customer'||p_type);
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Site_customer'||p_type
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Site_Customer;



--  Sold_To_Org

FUNCTION Sold_To_Org
(   p_sold_to_org                   IN  VARCHAR2
,   p_customer_number               IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  nvl(p_sold_to_org,fnd_api.g_miss_char) = fnd_api.g_miss_char
	   AND nvl(p_customer_number,fnd_api.g_miss_char) = fnd_api.g_miss_char
    THEN
        RETURN NULL;
    END IF;

    IF nvl(p_customer_number,fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
      SELECT ORGANIZATION_ID
      INTO l_id
      FROM OE_SOLD_TO_ORGS_V
      WHERE CUSTOMER_NUMBER = p_customer_number --added for 3651505
    AND status = 'A';
    ELSE

	 /*SELECT ORGANIZATION_ID
      INTO l_id
      FROM OE_SOLD_TO_ORGS_V
      WHERE NAME = p_sold_to_org;*/
	    Select  Cust_Acct.Cust_account_id into l_id  from HZ_CUST_ACCOUNTS  Cust_Acct,
    HZ_PARTIES Party where Cust_Acct.Party_id = Party.party_id and
    Party.Party_name = p_sold_to_org
	     AND cust_acct.status='A'; -- added for 3651505

    END IF;


    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN TOO_MANY_ROWS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sold_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sold_To_Org;

--  Tax_Exempt

FUNCTION Tax_Exempt
(   p_tax_exempt                    IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
 -- eBTax Changes
        l_lookup_type      	      VARCHAR2(80) := 'ZX_EXEMPTION_CONTROL';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_tax_exempt IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT LOOKUP_CODE
    INTO    l_code
    FROM    FND_LOOKUPS
    WHERE   MEANING = p_tax_exempt
    AND     LOOKUP_TYPE = l_lookup_type;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_exempt_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Exempt'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Exempt;

--  Tax_Exempt_Reason

FUNCTION Tax_Exempt_Reason
(   p_tax_exempt_reason             IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
  -- eBTax changes
        l_lookup_type      	      VARCHAR2(80) :=  'ZX_EXEMPTION_REASON_CODE';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_tax_exempt_reason IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT LOOKUP_CODE
    INTO    l_code
    FROM    FND_LOOKUPS
    WHERE   MEANING = p_tax_exempt_reason
    AND     LOOKUP_TYPE = l_lookup_type;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_exempt_reason_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Exempt_Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Exempt_Reason;

--  Tax_Point

FUNCTION Tax_Point
(   p_tax_point                     IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
        l_lookup_type      	      VARCHAR2(80) := 'TAX_POINT_TYPE';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_tax_point IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT LOOKUP_CODE
    INTO    l_code
    FROM    OE_AR_LOOKUPS_V
    WHERE   MEANING = p_tax_point
    AND     LOOKUP_TYPE = l_lookup_type;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_point_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Point'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Point;

--  Discount

FUNCTION Discount
(   p_discount                      IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_discount IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_discount

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount;

FUNCTION sales_credit_type
(   p_sales_credit_type             IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_sales_credit_type IS NULL
    THEN
        RETURN NULL;
    END IF;

      SELECT  sales_credit_type_id
      INTO    l_id
     FROM    oe_sales_credit_types
     WHERE   Name = p_sales_credit_type;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_credit_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'sales_credit_type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END sales_credit_type;

--  Salesrep

FUNCTION Salesrep
(   p_salesrep                      IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_salesrep IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT SALESREP_ID
    INTO l_id
    FROM RA_SALESREPS
    WHERE NAME = p_salesrep;

    RETURN l_id;

EXCEPTION

   WHEN TOO_MANY_ROWS THEN
        oe_debug_pub.add(' Conversion returns to many rows, need to consider end date active');

    BEGIN
     SELECT SALESREP_ID
     INTO l_id
     FROM RA_SALESREPS
     WHERE NAME = p_salesrep
     AND  trunc(NVL(start_date_active, sysdate)) <= trunc(sysdate)
     AND  trunc(NVL(end_date_active, sysdate)) >= trunc(sysdate);
     RETURN l_id;
    EXCEPTION
     WHEN TOO_MANY_ROWS THEN
       fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep_id');
       OE_MSG_PUB.Add;
       oe_debug_pub.add('Multiple active salesrep with same name');
       RETURN FND_API.G_MISS_NUM;

    END;

   WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep_id');
            OE_MSG_PUB.Add;
            oe_debug_pub.add(' Value to ID conversion no data found on salesrep_id');

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Salesrep'
            );
        END IF;

        oe_debug_pub.add(' Value to ID conversion--salesrep_id:'||SQLERRM);

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Salesrep;

--  Demand_Bucket_Type

FUNCTION Demand_Bucket_Type
(   p_demand_bucket_type            IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_demand_bucket_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_demand_bucket_type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','demand_bucket_type_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Bucket_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Bucket_Type;

--  Inventory_Item

FUNCTION Inventory_Item
(   p_inventory_item                IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_inventory_item IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_inventory_item

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Inventory_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Item;

--  Item_Type

FUNCTION Item_Type
(   p_item_type                     IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_item_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_item_type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_type_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Type;

--  Line_Type

FUNCTION Line_Type
(   p_line_type                     IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_line_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LINE_TYPE_ID
    INTO    l_id
    FROM    OE_LINE_TYPES_V
    WHERE   NAME = p_line_type;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_type_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line_Type;

--  Project

FUNCTION Project
(   p_project                       IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
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

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','project_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Project'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Project;

--  Rla_Schedule_Type

FUNCTION Rla_Schedule_Type
(   p_rla_schedule_type             IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_rla_schedule_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_rla_schedule_type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rla_schedule_type_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rla_Schedule_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rla_Schedule_Type;

--  Task

FUNCTION Task
(   p_task                          IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
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

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','task_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Task'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Task;

FUNCTION Over_Ship_Reason
(   p_over_ship_reason                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_over_ship_reason IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_currency

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','over_ship_reason_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Over_Ship_reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Over_Ship_reason;

FUNCTION Return_Reason
(   p_return_reason                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
        l_lookup_type      	      VARCHAR2(80) :='CREDIT_MEMO_REASON';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_return_reason IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LOOKUP_CODE
    INTO    l_code
    FROM    OE_AR_LOOKUPS_V
    WHERE   MEANING = p_return_reason
    AND     LOOKUP_TYPE = l_lookup_type;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','return_reason_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Return_Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Return_Reason;

FUNCTION Veh_Cus_Item_Cum_Key
(   p_veh_cus_item_cum_Key                      IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                        NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_veh_cus_item_cum_Key IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_currency

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','veh_cus_item_cum_Key_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Veh_Cus_Item_cum_Key'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Veh_Cus_Item_cum_Key;

--  Payment_Type

FUNCTION Payment_Type
(   p_payment_type                 IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
        l_lookup_type      	      VARCHAR2(80) := 'PAYMENT TYPE';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
l_org_id number := NULL;

BEGIN

    IF  p_payment_type IS NULL
    THEN
        RETURN NULL;
    END IF;

   l_org_id := OE_GLOBALS.G_ORG_ID;

   IF l_org_id is null then
       OE_GLOBALS.Set_Context;
       l_org_id := OE_GLOBALS.G_ORG_ID;
   END IF;

--serla begin
    IF OE_PrePayment_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED THEN

      IF l_org_id is not null then

          SELECT PAYMENT_TYPE_CODE
          INTO    l_code
          FROM    OE_PAYMENT_TYPES_TL
          WHERE   ORG_ID = l_org_id
          AND LANGUAGE = USERENV('LANG')
          AND NAME = p_payment_type;

      Else

         SELECT PAYMENT_TYPE_CODE
         INTO l_code
         FROM OE_PAYMENT_TYPES_TL
         WHERE NAME = p_payment_type
         AND LANGUAGE = USERENV('LANG')
         AND ORG_ID is null;

      End IF;

    ELSE
       SELECT LOOKUP_CODE
       INTO    l_code
       FROM    OE_LOOKUPS
       WHERE   MEANING = p_payment_type
       AND     LOOKUP_TYPE =   l_lookup_type;
    END IF;
--serla end

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_type_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Type;

--  Credit_Card

FUNCTION Credit_Card
(   p_credit_card                 IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
        l_lookup_type      	      VARCHAR2(80) := 'CREDIT_CARD';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_credit_card IS NULL
    THEN
        RETURN NULL;
    END IF;

    select CARD_ISSUER_CODE into l_code
    from iby_creditcard_issuers_v
    where description = p_credit_card
    and rownum = 1;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','credit_card_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Credit_Card'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Credit_Card;


FUNCTION Commitment
(   p_commitment                 IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                     NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    -- bug 1851006
    IF  p_commitment IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT customer_trx_id
    INTO   l_id
    FROM   ra_customer_trx
    WHERE  trx_number = p_commitment;

    RETURN l_id;

    -- RETURN NULL;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','commitment_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Veh_Cus_Item_cum_Key'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Commitment;


/* Pricing Contract Functions : Begin */

FUNCTION Currency
(   p_currency                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_currency IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_currency

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency;


--  Agreement_Contact

FUNCTION Agreement_Contact
(   p_Agreement_Contact                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_Agreement_Contact IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Agreement_Contact

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Agreement_Contact_Id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Agreement_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Agreement_Contact;

--  Agreement_Type

FUNCTION Agreement_Type
(   p_Agreement_Type                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_Agreement_Type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Agreement_Type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Agreement_Type_Code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Agreement_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Agreement_Type;

--  Customer

FUNCTION Customer
(   p_Customer                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_Customer IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Customer

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Customer_Id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer;

--  Invoice_Contact

FUNCTION Invoice_Contact
(   p_Invoice_Contact                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_Invoice_Contact IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Invoice_Contact

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Invoice_Contact_Id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_Contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_Contact;

--  Invoice_To_Site_Use

FUNCTION Invoice_To_Site_Use
(   p_Invoice_To_Site_Use                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_Invoice_To_Site_Use IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Invoice_To_Site_Use

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Invoice_To_Site_Use_Id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_To_Site_Use'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_To_Site_Use;

--  Override_Arule

FUNCTION Override_Arule
(   p_Override_Arule                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_Override_Arule IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Override_Arule

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Override_Arule_Flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Override_Arule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Override_Arule;

--  Override_Irule

FUNCTION Override_Irule
(   p_Override_Irule                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_Override_Irule IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Override_Irule

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Override_Irule_Flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Override_Irule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Override_Irule;

--  Revision_Reason

FUNCTION Revision_Reason
(   p_Revision_Reason                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_Revision_Reason IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Revision_Reason

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Revision_Reason_Code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Revision_Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Revision_Reason;

--  Ship_Method

FUNCTION Ship_Method
(   p_Ship_Method                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(80);

	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_Ship_Method IS NULL
    THEN
        RETURN NULL;
    END IF;

      SELECT  lookup_code
      INTO    l_code
      FROM    oe_ship_methods_v
      WHERE   meaning = p_Ship_Method and
	 rownum = 1 ;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ship_Method_Code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_Method;

--  Term

FUNCTION Term
(   p_Term                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_Term IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_Term

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Term_Id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Term'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Term;

--  Secondary_Price_List

FUNCTION Secondary_Price_List
(   p_secondary_price_list          IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_secondary_price_list IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_secondary_price_list

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','secondary_price_list_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Secondary_Price_List'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Secondary_Price_List;

--  Terms

FUNCTION Terms
(   p_terms                         IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_terms IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_terms

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','terms_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Terms'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Terms;

--  Automatic_Discount

FUNCTION Automatic_Discount
(   p_automatic_discount            IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(1);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_automatic_discount IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_automatic_discount

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','automatic_discount_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Automatic_Discount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Automatic_Discount;

--  Discount_Lines

FUNCTION Discount_Lines
(   p_discount_lines                IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(1);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_discount_lines IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_discount_lines

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_lines_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount_Lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount_Lines;

--  Discount_Type

FUNCTION Discount_Type
(   p_discount_type                 IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_discount_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_discount_type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_type_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount_Type;

--  Manual_Discount

FUNCTION Manual_Discount
(   p_manual_discount               IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(1);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_manual_discount IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_manual_discount

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','manual_discount_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Manual_Discount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Manual_Discount;

--  Override_Allowed

FUNCTION Override_Allowed
(   p_override_allowed              IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(1);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_override_allowed IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_override_allowed

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override_allowed_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Override_Allowed'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Override_Allowed;

--  Prorate

FUNCTION Prorate
(   p_prorate                       IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_prorate IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_prorate

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prorate_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Prorate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Prorate;


--  Method

FUNCTION Method
(   p_method                        IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(4);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_method IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_method

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','method_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Method;

--  Price_List_Line

FUNCTION Price_List_Line
(   p_price_list_line               IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_price_list_line IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_price_list_line

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list_line_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List_Line;

--  Pricing_Rule

FUNCTION Pricing_Rule
(   p_pricing_rule                  IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_pricing_rule IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_pricing_rule

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_rule_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Rule;

--  Reprice

FUNCTION Reprice
(   p_reprice                       IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(1);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_reprice IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_reprice

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reprice_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reprice'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reprice;

--  Unit

FUNCTION Unit
(   p_unit                          IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(3);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_unit IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_unit

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','unit_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Unit'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Unit;

--  Customer_Class

FUNCTION Customer_Class
(   p_customer_class                IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_customer_class IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_customer_class

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','customer_class_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer_Class'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_Class;

--  Discount_Customer

FUNCTION Discount_Customer
(   p_discount_customer             IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_discount_customer IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_discount_customer

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_customer_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount_Customer'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount_Customer;

--  Site_Use

FUNCTION Site_Use
(   p_site_use                      IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_site_use IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_site_use

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','site_use_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Site_Use'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Site_Use;

--  Entity

FUNCTION Entity
(   p_entity                        IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_entity IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_entity

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','entity_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Entity;

--  Method_Type

FUNCTION Method_Type
(   p_method_type                   IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_method_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_method_type

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','method_type_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Method_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Method_Type;

/* Pricing Contract Functions : End */

--  Lot_Serial

FUNCTION Lot_Serial
(   p_lot_serial                    IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_lot_serial IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_lot_serial

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lot_serial_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lot_Serial'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lot_Serial;

--  Appear_On_Ack

FUNCTION Appear_On_Ack
(   p_appear_on_ack                 IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(1);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_appear_on_ack IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_appear_on_ack

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','appear_on_ack_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Appear_On_Ack'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Appear_On_Ack;

--  Appear_On_Invoice

FUNCTION Appear_On_Invoice
(   p_appear_on_invoice             IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(1);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_appear_on_invoice IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_appear_on_invoice

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','appear_on_invoice_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Appear_On_Invoice'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Appear_On_Invoice;

--  Charge

FUNCTION Charge
(   p_charge                        IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_charge IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_charge

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','charge_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Charge'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Charge;

--  Charge_Type

FUNCTION Charge_Type
(   p_charge_type                   IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_charge_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_charge_type

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','charge_type_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Charge_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Charge_Type;

--  Cost_Or_Charge

FUNCTION Cost_Or_Charge
(   p_cost_or_charge                IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(1);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_cost_or_charge IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_cost_or_charge

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','cost_or_charge_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Cost_Or_Charge'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cost_Or_Charge;

--  Departure

FUNCTION Departure
(   p_departure                     IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_departure IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_departure

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','departure_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Departure'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Departure;

--  Estimated

FUNCTION Estimated
(   p_estimated                     IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(1);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_estimated IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_estimated

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','estimated_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Estimated'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Estimated;

--  Invoiced

FUNCTION Invoiced
(   p_invoiced                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(1);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_invoiced IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_invoiced

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoiced_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoiced'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoiced;

--  Parent_Charge

FUNCTION Parent_Charge
(   p_parent_charge                 IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_parent_charge IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_id
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_parent_charge

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','parent_charge_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Parent_Charge'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Parent_Charge;

--  Returnable

FUNCTION Returnable
(   p_returnable                    IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(1);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_returnable IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_returnable

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','returnable_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Returnable'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Returnable;

--  Tax_Group
/* eBTax changes
FUNCTION Tax_Group
(   p_tax_group                     IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_tax_group IS NULL
    THEN
        RETURN NULL;
    END IF;

    --  SELECT  XXXX_id
    --  INTO    l_code
    --  FROM    XXXX_table
    --  WHERE   XXXX_val_column = p_tax_group

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_group_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Group'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Group;*/


FUNCTION Flow_Status
(   p_flow_status                     IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_flow_status IS NULL
    THEN
        RETURN NULL;
    END IF;

      SELECT  distinct LOOKUP_CODE
      INTO    l_code
      FROM    OE_LOOKUPS
      WHERE   (lookup_type = 'FLOW_STATUS'
		   OR lookup_type = 'LINE_FLOW_STATUS')
      AND     meaning = p_flow_status;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','flow_status_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Flow_Status'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Flow_Status;

FUNCTION Freight_Carrier
(   p_freight_carrier                 IN  VARCHAR2
,   p_ship_from_org_id			   IN  NUMBER
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	l_ship_from_org_id			NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    RETURN NULL;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_carrier_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN TOO_MANY_ROWS THEN

       fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_carrier_code');
       OE_MSG_PUB.Add;
       RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Freight_Carrier'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Freight_Carrier;

FUNCTION Sales_Channel
(   p_sales_channel                     IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
        l_lookup_type      	      VARCHAR2(80) := 'SALES_CHANNEL';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_sales_channel IS NULL
    THEN
        RETURN NULL;
    END IF;

      SELECT  LOOKUP_CODE
      INTO    l_code
      FROM    OE_LOOKUPS
      WHERE   LOOKUP_TYPE = l_lookup_type
        AND   MEANING = p_sales_channel;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_channel_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sales_Channel'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sales_Channel;

FUNCTION Customer_Location
(   p_sold_to_location_address1              IN  VARCHAR2
,   p_sold_to_location_address2              IN  VARCHAR2
,   p_sold_to_location_address3              IN  VARCHAR2
,   p_sold_to_location_address4              IN  VARCHAR2
,   p_sold_to_location                       IN  VARCHAR2
,   p_sold_to_org_id                         IN  NUMBER
,   p_sold_to_location_city                  IN VARCHAR2 DEFAULT NULL
,   p_sold_to_location_state                 IN VARCHAR2 DEFAULT NULL
,   p_sold_to_location_postal_code           IN VARCHAR2 DEFAULT NULL
,   p_sold_to_location_country               IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SOLD_TO_LOCATION_ADDRESS1='||P_SOLD_TO_LOCATION_ADDRESS1||' ADDRESS4='||P_SOLD_TO_LOCATION_ADDRESS4||' sold_to_org_id='||p_sold_to_org_id ) ;
        oe_debug_pub.add(  'SOLD_TO_LOCATION_ADDRESS2='||P_SOLD_TO_LOCATION_ADDRESS2||' ADDRESS3='||P_SOLD_TO_LOCATION_ADDRESS3);
    END IF;


    IF  nvl( p_sold_to_location_address1,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_sold_to_location_address2,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_sold_to_location_address3,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_sold_to_location_address4,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_sold_to_org_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
    THEN
        RETURN NULL;
    END IF;

    SELECT /* MOAC_SQL_CHANGE */  SITE.SITE_USE_ID
    INTO l_id
    FROM
                HZ_CUST_SITE_USES       SITE,
                HZ_PARTY_SITES          PARTY_SITE,
                HZ_LOCATIONS            LOC,
                HZ_CUST_ACCT_SITES_ALL      ACCT_SITE
    WHERE
             SITE.SITE_USE_CODE         = 'SOLD_TO'
       AND   SITE.CUST_ACCT_SITE_ID     = ACCT_SITE.CUST_ACCT_SITE_ID
       AND   ACCT_SITE.PARTY_SITE_ID    = PARTY_SITE.PARTY_SITE_ID
       AND   PARTY_SITE.LOCATION_ID     = LOC.LOCATION_ID
       AND   LOC.ADDRESS1  = p_sold_to_location_address1
	    AND nvl( LOC.ADDRESS2, fnd_api.g_miss_char) =
           nvl( p_sold_to_location_address2, fnd_api.g_miss_char)
	    AND nvl( LOC.ADDRESS3, fnd_api.g_miss_char) =
           nvl( p_sold_to_location_address3, fnd_api.g_miss_char)
	    AND nvl( LOC.ADDRESS4, fnd_api.g_miss_char) =
           nvl( p_sold_to_location_address4, fnd_api.g_miss_char)
	    AND nvl( LOC.city, fnd_api.g_miss_char) =
           nvl( p_sold_to_location_city, fnd_api.g_miss_char)
	    AND nvl( LOC.state, fnd_api.g_miss_char) =
           nvl( p_sold_to_location_state, fnd_api.g_miss_char)
	    AND nvl( LOC.postal_code, fnd_api.g_miss_char) =
           nvl( p_sold_to_location_postal_code, fnd_api.g_miss_char)
	    AND nvl( LOC.country, fnd_api.g_miss_char) =
           nvl( p_sold_to_location_country, fnd_api.g_miss_char)
      AND SITE.STATUS = 'A'
      AND ACCT_SITE.STATUS = 'A'
      and acct_site.org_id=site.org_id
      AND ACCT_SITE.CUST_ACCOUNT_ID = p_sold_to_org_id;


  IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'jerome- sold to site use id: ' || l_id);
    END IF;

  RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_site_use_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer_Location'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_Location;

--serla begin
FUNCTION Payment_Collection_Event_Name
(  p_payment_collection_event      IN      VARCHAR2
) RETURN VARCHAR2
IS
l_code VARCHAR2(30);
        l_lookup_type      	      VARCHAR2(80) :='OE_PAYMENT_COLLECTION_TYPE';
BEGIN
    IF  p_payment_collection_event IS NULL
    THEN
        RETURN NULL;
    END IF;

      SELECT  LOOKUP_CODE
      INTO    l_code
      FROM    OE_LOOKUPS
      WHERE   LOOKUP_TYPE = l_lookup_type
        AND   MEANING = p_payment_collection_event;

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Payment_Collection_Event');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Collection_Event_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Collection_Event_Name;

FUNCTION Receipt_Method
(  p_receipt_method      IN      VARCHAR2
) RETURN NUMBER
IS
l_id    NUMBER;
BEGIN
    IF  p_receipt_method IS NULL
    THEN
        RETURN NULL;
    END IF;

      SELECT  receipt_method_id
      INTO    l_id
      FROM    AR_RECEIPT_METHODS
      WHERE   NAME = p_receipt_method;

    RETURN l_id;
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','receipt_method_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Receipt_Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Receipt_Method;
--serla end


--distributed orders

FUNCTION END_CUSTOMER
(  p_end_customer        IN VARCHAR2
,  p_end_customer_number IN VARCHAR2
) RETURN NUMBER
IS

   l_id NUMBER;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF  nvl(p_end_customer,fnd_api.g_miss_char) = fnd_api.g_miss_char
      AND nvl(p_end_customer_number,fnd_api.g_miss_char) = fnd_api.g_miss_char
   THEN
      RETURN NULL;
    END IF;

    IF nvl(p_end_customer_number,fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
      SELECT ORGANIZATION_ID
      INTO l_id
      FROM OE_SOLD_TO_ORGS_V
      WHERE CUSTOMER_NUMBER = p_end_customer_number;
    ELSE
       Select  Cust_Acct.Cust_account_id
	  into l_id
	  from HZ_CUST_ACCOUNTS  Cust_Acct,
	  HZ_PARTIES Party
	  where Cust_Acct.Party_id = Party.party_id
	  and Party.Party_name = p_end_customer;

    END IF;


    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

   WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'End_customer'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END END_CUSTOMER;

FUNCTION END_CUSTOMER_CONTACT
(  p_end_customer_contact IN VARCHAR2
,  p_end_customer_id      IN NUMBER
) RETURN NUMBER IS

l_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   IF p_end_customer_contact IS NULL
   THEN
      RETURN NULL;
   END IF;

   SELECT CONTACT_ID
      INTO l_id
      FROM OE_CONTACTS_V
      WHERE NAME = p_end_customer_contact
      AND CUSTOMER_ID = p_end_customer_id;

   RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer_contact_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'End_customer_contact'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END END_CUSTOMER_CONTACT;


FUNCTION END_CUSTOMER_SITE
(   p_end_customer_site_address1              IN  VARCHAR2
,   p_end_customer_site_address2              IN  VARCHAR2
,   p_end_customer_site_address3              IN  VARCHAR2
,   p_end_customer_site_address4              IN  VARCHAR2
,   p_end_customer_site_location              IN  VARCHAR2
,   p_end_customer_site_org                   IN  VARCHAR2
,   p_end_customer_id                         IN  NUMBER
,   p_end_customer_site_city                  IN  VARCHAR2 DEFAULT NULL
,   p_end_customer_site_state                 IN  VARCHAR2 DEFAULT NULL
,   p_end_customer_site_postalcode            IN  VARCHAR2 DEFAULT NULL
,   p_end_customer_site_country               IN  VARCHAR2 DEFAULT NULL
,   p_end_customer_site_use_code              IN  VARCHAR2 DEFAULT NULL
) RETURN NUMBER
IS

   -- cursor to get the site_id for end_customer
   CURSOR c_site_use_id(in_end_customer_id number,in_end_customer_site_use_code number) IS
      SELECT /* MOAC_SQL_CHANGE */ site_use.site_use_id
      FROM hz_locations loc,
      hz_party_sites site,
      hz_cust_acct_sites_all acct_site,
      hz_cust_site_uses site_use
      WHERE
        site_use.cust_acct_site_id=acct_site.cust_acct_site_id
        and acct_site.party_site_id=site.party_site_id
        and site.location_id=loc.location_id
	and site_use.status='A'
	and acct_site.status='A' --bug 2752321
	and acct_site.cust_account_id=in_end_customer_id
	and acct_site.org_id=site_use.org_id
	and loc.address1  = p_end_customer_site_address1
	and nvl( loc.address2, fnd_api.g_miss_char) =
	    nvl( p_end_customer_site_address2, fnd_api.g_miss_char)
	and nvl( loc.address3, fnd_api.g_miss_char) =
	    nvl( p_end_customer_site_address3, fnd_api.g_miss_char)
	and nvl( loc.address4, fnd_api.g_miss_char) =
	    nvl( p_end_customer_site_address4, fnd_api.g_miss_char)
	and nvl( loc.city, fnd_api.g_miss_char) =
	    nvl( p_end_customer_site_city, fnd_api.g_miss_char)
	and nvl( loc.state, fnd_api.g_miss_char) =
	    nvl( p_end_customer_site_state, fnd_api.g_miss_char)
	and nvl( loc.postal_code, fnd_api.g_miss_char) =
	    nvl( p_end_customer_site_postalcode, fnd_api.g_miss_char)
	and nvl( loc.country, fnd_api.g_miss_char) =
	    nvl( p_end_customer_site_country, fnd_api.g_miss_char)
      and site_use.site_use_code = in_end_customer_site_use_code;

      CURSOR c_site_use_id2(in_end_customer_id number,in_end_customer_site_use_code number) IS
	 SELECT /* MOAC_SQL_CHANGE */ site_use.site_use_id
	 FROM hz_locations loc,
	 hz_party_sites site,
	 hz_cust_acct_sites_all acct_site,
	 hz_cust_site_uses site_use
	 WHERE loc.ADDRESS1  = p_end_customer_site_address1
	 AND nvl( loc.ADDRESS2, fnd_api.g_miss_char) =
	 nvl( p_end_customer_site_address2, fnd_api.g_miss_char)
	 AND nvl( loc.ADDRESS3, fnd_api.g_miss_char) =
	 nvl( p_end_customer_site_address3, fnd_api.g_miss_char)
	 AND DECODE(loc.CITY,NULL,NULL,loc.CITY||', ')||
	 DECODE(loc.STATE, NULL, NULL, loc.STATE || ', ')||
	 DECODE(POSTAL_CODE, NULL, NULL, loc.POSTAL_CODE || ', ')||
	 DECODE(loc.COUNTRY, NULL, NULL, loc.COUNTRY) =
	 nvl( p_end_customer_site_address4, fnd_api.g_miss_char)
	 AND site_use.status = 'A'
	 AND acct_site.status ='A' --bug 2752321
	 AND acct_site.cust_account_id = p_end_customer_id
	 and site_use.site_use_code=in_end_customer_site_use_code
	 and site_use.cust_acct_site_id=acct_site.cust_acct_site_id
	 and site.party_site_id=acct_site.party_site_id
	 and site.location_id=loc.location_id
	 and acct_site.org_id=site_use.org_id;


l_id number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' end customer site address1: '||p_end_customer_site_address1);
      oe_debug_pub.add(' address4: '||p_end_customer_site_address4);
      oe_debug_pub.add(' end_customer_id: '||p_end_customer_id );
   END IF;

   IF  nvl( p_end_customer_site_address1,fnd_api.g_miss_char) = fnd_api.g_miss_char
      AND nvl( p_end_customer_site_address2,fnd_api.g_miss_char) = fnd_api.g_miss_char
      AND nvl( p_end_customer_site_address3,fnd_api.g_miss_char) = fnd_api.g_miss_char
      AND nvl( p_end_customer_site_address4,fnd_api.g_miss_char) = fnd_api.g_miss_char
      AND nvl( p_end_customer_id,fnd_api.g_miss_num) = fnd_api.g_miss_num
   THEN
      RETURN NULL;
   END IF;

   -- if no site_use_code passed in
   -- try getting sites in the following preference
   -- SOLD_TO, SHIP_TO, DELIVER_TO, BILL_TO
   IF p_end_customer_site_use_code is null THEN

      -- try for SOLD_TO
      OPEN c_site_use_id(p_end_customer_id,'SOLD_TO');
      FETCH c_site_use_id
	 INTO l_id;
      IF c_site_use_id%FOUND then
	 CLOSE c_site_use_id;
	 return l_id;
      ELSE
	 CLOSE c_site_use_id;

	 OPEN c_site_use_id2(p_end_customer_id,'SOLD_TO');
	 FETCH c_site_use_id2
	    INTO l_id;
	 IF c_site_use_id2%FOUND then
	    CLOSE c_site_use_id2;
	    return l_id;
	 END IF;
	 CLOSE c_site_use_id2;
      END IF;

       -- try for SHIP_TO
      OPEN c_site_use_id(p_end_customer_id,'SHIP_TO');
      FETCH c_site_use_id
	 INTO l_id;
      IF c_site_use_id%FOUND then
	 CLOSE c_site_use_id;
	 return l_id;
      ELSE
	 CLOSE c_site_use_id;

	 OPEN c_site_use_id2(p_end_customer_id,'SHIP_TO');
	 FETCH c_site_use_id2
	    INTO l_id;
	 IF c_site_use_id2%FOUND then
	    CLOSE c_site_use_id2;
	    return l_id;
	 END IF;
	 CLOSE c_site_use_id2;
      END IF;

      -- try for DELIVER_TO
      OPEN c_site_use_id(p_end_customer_id,'DELIVER_TO');
      FETCH c_site_use_id
	 INTO l_id;
      IF c_site_use_id%FOUND then
	 CLOSE c_site_use_id;
	 return l_id;
      ELSE
	 CLOSE c_site_use_id;

	 OPEN c_site_use_id2(p_end_customer_id,'DELIVER_TO');
	 FETCH c_site_use_id2
	    INTO l_id;
	 IF c_site_use_id2%FOUND then
	    CLOSE c_site_use_id2;
	    return l_id;
	 END IF;
	 CLOSE c_site_use_id2;
      END IF;

      -- try for BILL_TO
      OPEN c_site_use_id(p_end_customer_id,'BILL_TO');
      FETCH c_site_use_id
	 INTO l_id;
      IF c_site_use_id%FOUND then
	 CLOSE c_site_use_id;
	 return l_id;
      ELSE
	 CLOSE c_site_use_id;

	 OPEN c_site_use_id2(p_end_customer_id,'BILL_TO');
	 FETCH c_site_use_id2
	    INTO l_id;
	 IF c_site_use_id2%FOUND then
	    CLOSE c_site_use_id2;
	    return l_id;
	 END IF;
	 CLOSE c_site_use_id2;
      END IF;

      -- nothing found, raise an error
      raise NO_DATA_FOUND;

   ELSE
      -- site_use_code was passed in

      OPEN c_site_use_id(p_end_customer_id,p_end_customer_site_use_code);
      FETCH c_site_use_id
	 INTO l_id;
      IF c_site_use_id%FOUND then
	 CLOSE c_site_use_id;
	 return l_id;
      ELSE
	 CLOSE c_site_use_id;

	 OPEN c_site_use_id2(p_end_customer_id,p_end_customer_site_use_code);
	 FETCH c_site_use_id2
	    INTO l_id;
	 IF c_site_use_id2%FOUND then
	    CLOSE c_site_use_id2;
	    return l_id;
	 END IF;
	 CLOSE c_site_use_id2;
      END IF;

      -- no data found here, raise an error
      raise NO_DATA_FOUND;

   END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF c_site_use_id%ISOPEN then
            CLOSE c_site_use_id;
        END IF;

	IF c_site_use_id2%ISOPEN then
            CLOSE c_site_use_id2;
        END IF;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	   fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer_site_id');
	   OE_MSG_PUB.Add;

        END IF;
	RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF c_site_use_id%ISOPEN then
            CLOSE c_site_use_id;
        END IF;

	IF c_site_use_id2%ISOPEN then
            CLOSE c_site_use_id2;
        END IF;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'end_cstomer_site_id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END END_CUSTOMER_SITE;

FUNCTION IB_Owner
(   p_ib_owner                 IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	l_lookup_type1      	      VARCHAR2(80) :='ITEM_OWNER';
--	l_lookup_type2      	      VARCHAR2(80) :='ONT_INSTALL_BASE';

	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_ib_owner IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LOOKUP_CODE
    INTO    l_code
    FROM    OE_LOOKUPS
    WHERE   MEANING = p_ib_owner
    AND     LOOKUP_TYPE = l_lookup_type1 ;--or LOOKUP_TYPE = l_lookup_type1);

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ib_owner');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'IB_Owner'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IB_Owner;

FUNCTION IB_Installed_At_Location
(   p_ib_installed_at_location                 IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	l_lookup_type1      	      VARCHAR2(80) :='ITEM_INSTALL_LOCATION';
	l_lookup_type2      	      VARCHAR2(80) :='ONT_INSTALL_BASE';

	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN
     oe_Debug_pub.add('entering v to id of installed at location');
    IF  p_ib_installed_at_location IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LOOKUP_CODE
    INTO    l_code
    FROM    OE_LOOKUPS
    WHERE   MEANING = p_ib_installed_at_location
    AND     LOOKUP_TYPE = l_lookup_type1; -- or LOOKUP_TYPE = l_lookup_type1);
  oe_Debug_pub.add('ib inst code'||l_code);
    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ib_installed_at_location');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'ib_installed_at_location'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IB_Installed_At_Location;

FUNCTION IB_Current_Location
(   p_ib_current_location                 IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	l_lookup_type1      	      VARCHAR2(80) :='ITEM_CURRENT_LOCATION';
	l_lookup_type2      	      VARCHAR2(80) :='ONT_INSTALL_BASE';

	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  p_ib_current_location IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LOOKUP_CODE
    INTO    l_code
    FROM    OE_LOOKUPS
    WHERE   MEANING = p_ib_current_location
    AND     LOOKUP_TYPE = l_lookup_type1 ;--or LOOKUP_TYPE = l_lookup_type1);

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ib_current_location');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_CHAR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'ib_current_location'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IB_Current_Location;

-- Added for bug 8478559
FUNCTION Payment_Percentage
(  p_payment_percentage IN NUMBER
) RETURN NUMBER
IS
BEGIN
   RETURN p_payment_percentage;
END Payment_Percentage;
-- End of bug 8478559

--MOAC change
FUNCTION OPERATING_UNIT
(  p_operating_unit                    IN  VARCHAR2
) RETURN NUMBER
IS

l_org_id     	NUMBER;
l_debug_level 	CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

    IF  p_operating_unit IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  organization_id
    INTO    l_org_id
    FROM    hr_operating_units
    WHERE   NAME = p_operating_unit;

    RETURN l_org_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Operating_Unit'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END OPERATING_UNIT;

END OE_Value_To_Id;

/
