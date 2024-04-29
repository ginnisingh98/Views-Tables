--------------------------------------------------------
--  DDL for Package Body OE_CNCL_VALUE_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CNCL_VALUE_TO_ID" AS
/* $Header: OEXVCIDB.pls 120.4.12000000.2 2007/04/20 12:31:26 smanian ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_CNCL_Value_To_Id';


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
	    oe_debug_pub.add(  'ENTERING OE_CNCL_VALUE_TO_ID.KEY_FLEX' , 1 ) ;
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


--  Accounting_Rule (Done aksingh)

FUNCTION Accounting_Rule
(   p_accounting_rule               IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
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

--  Agreement (Done aksingh)

FUNCTION Agreement
(   p_agreement                     IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
BEGIN

    IF  p_agreement IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT AGREEMENT_ID
    INTO l_id
    FROM OE_AGREEMENTS_V
    WHERE NAME = p_agreement;

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

--  Conversion_Type (Done aksingh)

FUNCTION Conversion_Type
(   p_conversion_type               IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
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

--  Deliver_To_Contact (Done aksingh)

FUNCTION Deliver_To_Contact
(   p_deliver_to_contact            IN  VARCHAR2
,   p_deliver_to_org_id             IN  NUMBER
) RETURN NUMBER
IS
	l_id                          NUMBER;
BEGIN

    IF  p_deliver_to_contact IS NULL
    THEN
        RETURN NULL;
    END IF;

   SELECT /* MOAC_SQL_CHANGE */ CON.CONTACT_ID
    INTO l_id
    FROM  OE_CONTACTS_V      CON
        , HZ_CUST_ACCT_SITES ACCT_SITE
        , HZ_CUST_SITE_USES_ALL  SITE
    WHERE CON.NAME = p_deliver_to_contact
    AND  CON.CUSTOMER_ID = ACCT_SITE.CUST_ACCOUNT_ID
    AND  ACCT_SITE.CUST_ACCT_SITE_ID = SITE.CUST_ACCT_SITE_ID
    AND  SITE.SITE_USE_ID = p_deliver_to_org_id;

-- Replaced ra_addresses and ra_site_uses with HZ Tables , to fix the bug 1888440

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

--  Deliver_To_Org (Done aksingh)

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
) RETURN NUMBER
IS

l_id                          NUMBER;
lcustomer_relations varchar2(1);

CURSOR c_deliver_to_org_id IS
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
      --AND STATUS = 'A'
      AND CUSTOMER_ID = p_sold_to_org_id;

CURSOR C1 IS
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
      --AND STATUS = 'A'
      AND CUSTOMER_ID IN
  (
                    SELECT p_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE WHERE
                    RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
                        and ship_to_flag = 'Y');
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
           nvl( p_deliver_to_country, fnd_api.g_miss_char);
      --AND STATUS = 'A';

   l_org varchar2(100);
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

    IF  nvl( p_deliver_to_address1,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_deliver_to_address2,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_deliver_to_address3,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_deliver_to_address4,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_deliver_to_location,fnd_api.g_miss_char) = fnd_api.g_miss_char
    AND nvl( p_deliver_to_org, fnd_api.g_miss_char) = fnd_api.g_miss_char
    THEN
        RETURN NULL;
    END IF;


  lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER RELATIONS='||LCUSTOMER_RELATIONS ) ;
  END IF;

  IF lcustomer_relations = 'N' THEN

    OPEN c_deliver_to_org_id;
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
        -- AND STATUS = 'A'
         AND CUSTOMER_ID = p_sold_to_org_id;
    END IF;

    CLOSE c_deliver_to_org_id;

    RETURN l_id;

  ELSIF lcustomer_relations = 'Y' THEN

    OPEN C1;
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
       -- select userenv('CLIENT_INFO') into l_org from dual;
        l_org :=  MO_GLOBAL.Get_Current_Org_Id; --moac
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
          -- AND STATUS = 'A'
          AND CUSTOMER_ID IN
                    (SELECT p_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE WHERE
                    RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
                        and ship_to_flag = 'Y');
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
          NVL( p_deliver_to_address4, fnd_api.g_miss_char);
          -- AND STATUS = 'A';
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

--  Fob_Point (Done aksingh)

FUNCTION Fob_Point
(   p_fob_point                     IN  VARCHAR2
) RETURN VARCHAR2
IS
l_lookup_type      	      VARCHAR2(80) :='FOB';
	l_code                        VARCHAR2(30);
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

--  Freight_Terms (Done aksingh)

FUNCTION Freight_Terms
(   p_freight_terms                 IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	l_lookup_type      	      VARCHAR2(80) :='FREIGHT_TERMS';
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

--  Intermediate_Ship_To_Contact (Done aksingh)

FUNCTION Intermed_Ship_To_Contact
(   p_intermed_ship_to_contact               IN  VARCHAR2
,   p_intermed_ship_to_org_id                IN  NUMBER
) RETURN NUMBER
IS
	l_id                          NUMBER;
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

--  Intermed_Ship_To_Org (Done aksingh)

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

-- Invoice_To_Contact (Done aksingh)

FUNCTION Invoice_To_Contact
(   p_invoice_to_contact            IN  VARCHAR2
,   p_invoice_to_org_id             IN  NUMBER
) RETURN NUMBER
IS
	l_id                          NUMBER;
BEGIN

    IF  p_invoice_to_contact IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT /* MOAC_SQL_CHANGE */ CON.CONTACT_ID
    INTO l_id
    FROM  OE_CONTACTS_V      CON
        , HZ_CUST_ACCT_SITES ACCT_SITE
        , HZ_CUST_SITE_USES_ALL  SITE
    WHERE CON.NAME = p_invoice_to_contact
    AND  CON.CUSTOMER_ID = ACCT_SITE.CUST_ACCOUNT_ID
    AND  ACCT_SITE.CUST_ACCT_SITE_ID = SITE.CUST_ACCT_SITE_ID
    AND  SITE.SITE_USE_ID = p_invoice_to_org_id;

-- Replaced ra_addresses and ra_site_uses with HZ Tables , to fix the bug 1888440

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

--  Invoice_To_Org (Done aksingh)

/* Commented the following definition of the function invoice_to_org and added a new one to fix the bug 2002486
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
) RETURN NUMBER
IS

l_id                          NUMBER;

CURSOR c_invoice_to_org_id IS
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
      AND CUSTOMER_ID = p_sold_to_org_id;

BEGIN

    IF  p_invoice_to_address1 IS NULL
    OR  p_invoice_to_address2 IS NULL
    OR  p_invoice_to_address3 IS NULL
    OR  p_invoice_to_address4 IS NULL
    OR  p_invoice_to_location IS NULL
    OR  p_invoice_to_org IS NULL
    THEN
        RETURN NULL;
    END IF;


    OPEN c_invoice_to_org_id;
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
          AND CUSTOMER_ID = p_sold_to_org_id;
    END IF;

    CLOSE c_invoice_to_org_id;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF c_invoice_to_org_id%ISOPEN then
            CLOSE c_invoice_to_org_id;
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

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_To_Org;
*/
/* Added the new definition of the finction invoice_to_org to fix the bug 2002486 */
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
) RETURN NUMBER
IS

l_id                          NUMBER;
lcustomer_relations varchar2(1);

CURSOR c_invoice_to_org_id IS
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
      AND CUSTOMER_ID = p_sold_to_org_id;

CURSOR C1 IS
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
      AND CUSTOMER_ID IN
  (
                    SELECT p_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE WHERE
                    RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
                        and bill_to_flag = 'Y');
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
      AND STATUS = 'A';
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INVOICE_TO_ORG VALUES ARE SOLD_TO_ORG_ID='||P_SOLD_TO_ORG_ID||' ADDRESS1='||P_INVOICE_TO_ADDRESS1||' ADDRESS4='||P_INVOICE_TO_ADDRESS4 ) ;
    END IF;
    IF  p_invoice_to_address1 IS NULL
    OR  p_invoice_to_address2 IS NULL
    OR  p_invoice_to_address3 IS NULL
    OR  p_invoice_to_address4 IS NULL
    OR  p_invoice_to_location IS NULL
    OR  p_invoice_to_org IS NULL
    THEN
        RETURN NULL;
    END IF;
 lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');

   IF lcustomer_relations = 'N' THEN

    OPEN c_invoice_to_org_id;
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
          AND CUSTOMER_ID = p_sold_to_org_id;
    END IF;

    CLOSE c_invoice_to_org_id;
    RETURN l_id;

   ELSIF lcustomer_relations = 'Y' THEN

    OPEN C1;
    FETCH C1
     INTO l_id;

    IF C1%FOUND then
        CLOSE C1;
        return l_id;
    ELSE
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
          AND CUSTOMER_ID IN
                    (SELECT p_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE WHERE
                    RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
                        and bill_to_flag = 'Y');
    END IF;

    CLOSE C1;
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
          AND STATUS = 'A';
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

--  Invoicing_Rule (Done aksingh)

FUNCTION Invoicing_Rule
(   p_invoicing_rule                IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
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

--  Order_Source (Done aksingh)

FUNCTION Order_Source
(   p_order_source                  IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
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

--  Order_Type (Done aksingh)

FUNCTION Order_Type
(   p_order_type                    IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
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

--  Payment_Term (Done aksingh)

FUNCTION Payment_Term
(   p_payment_term                  IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
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

--  Price_List (Done aksingh)

FUNCTION Price_List
(   p_price_list                    IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
BEGIN

    IF  p_price_list IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LIST_HEADER_ID
    INTO    l_id
    FROM    qp_list_headers_vl
    WHERE   NAME = p_price_list
       AND  list_type_code='PRL';

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

--  Shipment_Priority (Done aksingh)

FUNCTION Shipment_Priority
(   p_shipment_priority             IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	l_lookup_type      	      VARCHAR2(80) :='SHIPMENT_PRIORITY';
BEGIN

    IF  p_shipment_priority IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LOOKUP_CODE
    INTO    l_code
    FROM    OE_LOOKUPS
    WHERE   MEANING = p_shipment_priority
    AND     LOOKUP_TYPE = l_lookup_type;

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

--  Ship_From_Org (Done aksingh)

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

--  Ship_To_Contact (Done aksingh)

FUNCTION Ship_To_Contact
(   p_ship_to_contact               IN  VARCHAR2
,   p_ship_to_org_id                IN  NUMBER
) RETURN NUMBER
IS
	l_id                          NUMBER;
BEGIN

    IF  p_ship_to_contact IS NULL
    THEN
        RETURN NULL;
    END IF;


    SELECT /* MOAC_SQL_CHANGE */ CON.CONTACT_ID
    INTO l_id
    FROM  OE_CONTACTS_V      CON
        , HZ_CUST_ACCT_SITES ACCT_SITE
        , HZ_CUST_SITE_USES_ALL  SITE
    WHERE CON.NAME = p_ship_to_contact
    AND  CON.CUSTOMER_ID = ACCT_SITE.CUST_ACCOUNT_ID
    AND  ACCT_SITE.CUST_ACCT_SITE_ID = SITE.CUST_ACCT_SITE_ID
    AND  SITE.SITE_USE_ID = p_ship_to_org_id;

-- Replaced ra_addresses and ra_site_uses with HZ Tables , to fix the bug 1888440

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

--  Ship_To_Org (Done aksingh)

/* Commented the function ship_to_org and added the new definition of this function to fix the bug 2002486
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
) RETURN NUMBER
IS

l_id               NUMBER;

CURSOR c_ship_to_org_id IS
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
      AND CUSTOMER_ID = p_sold_to_org_id;

BEGIN

    IF  p_ship_to_address1 IS NULL
    OR  p_ship_to_address2 IS NULL
    OR  p_ship_to_address3 IS NULL
    OR  p_ship_to_address4 IS NULL
    OR  p_ship_to_location IS NULL
    OR  p_ship_to_org IS NULL
    THEN
        RETURN NULL;
    END IF;


    OPEN c_ship_to_org_id;
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
          AND CUSTOMER_ID = p_sold_to_org_id;
    END IF;
    CLOSE c_ship_to_org_id;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF c_ship_to_org_id%ISOPEN then
            CLOSE c_ship_to_org_id;
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

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_To_Org;
*/

/* Added the new definition of the function ship_to_org to fix the bug 2002486  */
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
) RETURN NUMBER
IS

l_id                          NUMBER;
lcustomer_relations varchar2(1);


CURSOR c_ship_to_org_id IS
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
      AND CUSTOMER_ID = p_sold_to_org_id;

CURSOR C1 IS
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
      AND CUSTOMER_ID in(
                    SELECT p_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE WHERE
                    RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
                        and ship_to_flag = 'Y');

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
      AND STATUS = 'A';
BEGIN

    IF  p_ship_to_address1 IS NULL
    OR  p_ship_to_address2 IS NULL
    OR  p_ship_to_address3 IS NULL
    OR  p_ship_to_address4 IS NULL
    OR  p_ship_to_location IS NULL
    OR  p_ship_to_org IS NULL
    THEN
        RETURN NULL;
    END IF;

 lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');

IF lcustomer_relations = 'N' THEN
    OPEN c_ship_to_org_id;
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
          AND CUSTOMER_ID = p_sold_to_org_id;
    END IF;
    CLOSE c_ship_to_org_id;

    RETURN l_id;

ELSIF lcustomer_relations = 'Y' THEN
    OPEN C1;
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
          AND CUSTOMER_ID
 in (
                    SELECT p_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE WHERE
                    RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
                        and ship_to_flag = 'Y');

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
          AND STATUS = 'A';
    END IF;
	CLOSE C2;

    RETURN l_id;
END IF;
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF c_ship_to_org_id%ISOPEN then
            CLOSE c_ship_to_org_id;
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

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_To_Org;

--  Sold_To_Contact (Done aksingh)

FUNCTION Sold_To_Contact
(   p_sold_to_contact               IN  VARCHAR2
,   p_sold_to_org_id                IN  NUMBER
) RETURN NUMBER
IS
	l_id                          NUMBER;
BEGIN

    IF  p_sold_to_contact IS NULL
    THEN
        RETURN NULL;
    END IF;


    SELECT /* MOAC_SQL_CHANGE */ CON.CONTACT_ID
    INTO l_id
    FROM  OE_CONTACTS_V      CON
        , HZ_CUST_ACCT_SITES ACCT_SITE
        , HZ_CUST_SITE_USES_ALL  SITE
    WHERE CON.NAME = p_sold_to_contact
    AND  CON.CUSTOMER_ID = ACCT_SITE.CUST_ACCOUNT_ID
    AND  ACCT_SITE.CUST_ACCT_SITE_ID = SITE.CUST_ACCT_SITE_ID
    AND  SITE.SITE_USE_ID = p_sold_to_org_id;

-- Modified the above query to fix the bug 1888440

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

--  Sold_To_Org (Done aksingh)

FUNCTION Sold_To_Org
(   p_sold_to_org                   IN  VARCHAR2
,   p_customer_number               IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
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
      WHERE CUSTOMER_NUMBER = p_customer_number;

    ELSE

     /* SELECT ORGANIZATION_ID
      INTO l_id
      FROM OE_SOLD_TO_ORGS_V
      WHERE NAME = p_sold_to_org;*/

	 Select  Cust_Acct.Cust_account_id into l_id  from HZ_CUST_ACCOUNTS  Cust_Acct,
    HZ_PARTIES Party where Cust_Acct.Party_id = Party.party_id and
    Party.Party_name = p_sold_to_org;


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

--  Tax_Exempt (Done aksingh)

FUNCTION Tax_Exempt
(   p_tax_exempt                    IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	-- eBTax changes
 	l_lookup_type      	      VARCHAR2(80) :='ZX_EXEMPTION_CONTROL';
BEGIN

    IF  p_tax_exempt IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT LOOKUP_CODE
    INTO    l_code
    FROM    fnd_lookups
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

--  Tax_Exempt_Reason (Done aksingh)

FUNCTION Tax_Exempt_Reason
(   p_tax_exempt_reason             IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	-- eBTax changes
	l_lookup_type      	      VARCHAR2(80) :='ZX_EXEMPTION_REASON_CODE';
BEGIN

    IF  p_tax_exempt_reason IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT LOOKUP_CODE
    INTO    l_code
    FROM    fnd_lookups
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

--  Tax_Point (Done aksingh)

FUNCTION Tax_Point
(   p_tax_point                     IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	l_lookup_type      	      VARCHAR2(80) :='TAX_POINT_TYPE';
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

--  Discount (Done aksingh)

FUNCTION Discount
(   p_discount                      IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
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

--  Sales_Credit_type (Done aksingh)
FUNCTION sales_credit_type
(   p_sales_credit_type             IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
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

--  Salesrep (Done aksingh)

FUNCTION Salesrep
(   p_salesrep                      IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
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

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep_id');
            OE_MSG_PUB.Add;

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

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Salesrep;

--  Demand_Bucket_Type (Done aksingh)

FUNCTION Demand_Bucket_Type
(   p_demand_bucket_type            IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
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
BEGIN

    IF  p_inventory_item IS NULL
    THEN
        RETURN NULL;
    END IF;

        --bug5603389
	SELECT inventory_item_id
	INTO    l_id
	FROM  mtl_system_items_vl
	WHERE concatenated_segments =p_inventory_item
	AND   customer_order_enabled_flag = 'Y'
	AND   bom_item_type in (1,2,4)
	AND   organization_id = OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

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

--  Item_Type (Done aksingh)

FUNCTION Item_Type
(   p_item_type                     IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
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

--  Line_Type (Done aksingh)

FUNCTION Line_Type
(   p_line_type                     IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
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

--  Project (Done aksingh -- no code)

FUNCTION Project
(   p_project                       IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
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

--  Rla_Schedule_Type (Done aksingh)

FUNCTION Rla_Schedule_Type
(   p_rla_schedule_type             IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
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

--  Task (Done aksingh -- no code)

FUNCTION Task
(   p_task                          IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
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

-- Over_Ship_Reason (Done aksingh)
FUNCTION Over_Ship_Reason
(   p_over_ship_reason                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
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

-- (Done aksingh)
FUNCTION Return_Reason
(   p_return_reason                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
	l_lookup_type      	      VARCHAR2(80) :='CREDIT_MEMO_REASON';
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

-- (Done aksingh)
FUNCTION Veh_Cus_Item_Cum_Key
(   p_veh_cus_item_cum_Key                      IN  VARCHAR2
) RETURN NUMBER
IS
	l_id                        NUMBER;
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

--  Payment_Type (Done aksingh)

FUNCTION Payment_Type
(   p_payment_type                 IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	l_lookup_type      	      VARCHAR2(80) :='PAYMENT TYPE';
BEGIN

    IF  p_payment_type IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT LOOKUP_CODE
    INTO    l_code
    FROM    OE_LOOKUPS
    WHERE   MEANING = p_payment_type
    AND     LOOKUP_TYPE = l_lookup_type;

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

--  Credit_Card (Done aksingh)

FUNCTION Credit_Card
(   p_credit_card                 IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	l_lookup_type      	      VARCHAR2(80) :='CREDIT_CARD';
BEGIN

    IF  p_credit_card IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT LOOKUP_CODE
    INTO    l_code
    FROM    OE_LOOKUPS
    WHERE   MEANING = p_credit_card
    AND     LOOKUP_TYPE = l_lookup_type;

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
	l_code                        VARCHAR2(30);
BEGIN

	RETURN NULL;

END Commitment;


/* Pricing Contract Functions : Begin */

FUNCTION Currency
(   p_currency                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(15);
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

--  Ship_Method (Done aksingh)

FUNCTION Ship_Method
(   p_Ship_Method                      IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(80);
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

FUNCTION Tax_Group
(   p_tax_group                     IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
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

END Tax_Group;


FUNCTION Flow_Status
(   p_flow_status                     IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
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


-- (Done aksingh -- disable_date missing)
FUNCTION freight_Carrier
(   p_freight_carrier                 IN  VARCHAR2
,   p_ship_from_org_id			   IN  NUMBER
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	l_ship_from_org_id			NUMBER;
BEGIN

    IF  p_freight_carrier IS NULL
    THEN
        RETURN NULL;
    END IF;

    IF p_ship_from_org_id = FND_API.G_MISS_NUM THEN
	  l_ship_from_org_id := NULL;
    ELSE
	  l_ship_from_org_id := p_ship_from_org_id;
    END IF;

        SELECT  freight_code
        INTO    l_code
        FROM    ORG_FREIGHT
        WHERE   DESCRIPTION = p_freight_carrier
	   AND	 ORGANIZATION_ID = nvl(l_ship_from_org_id,Organization_id);

    RETURN l_code;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_carrier_code');
            OE_MSG_PUB.Add;

        END IF;

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

-- (Done aksingh)
FUNCTION Sales_Channel
(   p_sales_channel                     IN  VARCHAR2
) RETURN VARCHAR2
IS
	l_code                        VARCHAR2(30);
	l_lookup_type      	      VARCHAR2(80) :='SALES_CHANNEL';
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
,   p_sold_to_location_postal                IN VARCHAR2 DEFAULT NULL
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

    SELECT /* MOAC_SQL_CHANGE */ SITE.SITE_USE_ID
    INTO l_id
    FROM
                HZ_CUST_SITE_USES_ALL       SITE,
                HZ_PARTY_SITES          PARTY_SITE,
                HZ_LOCATIONS            LOC,
                HZ_CUST_ACCT_SITES      ACCT_SITE
    WHERE
             SITE.SITE_USE_CODE         = 'SOLD_TO'
       AND   SITE.CUST_ACCT_SITE_ID     = ACCT_SITE.CUST_ACCT_SITE_ID
       AND   ACCT_SITE.PARTY_SITE_ID    = PARTY_SITE.PARTY_SITE_ID
       AND   PARTY_SITE.LOCATION_ID     = LOC.LOCATION_ID
       AND   SITE.ORG_ID = ACCT_SITE.ORG_ID
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
           nvl( p_sold_to_location_postal, fnd_api.g_miss_char)
	    AND nvl( LOC.country, fnd_api.g_miss_char) =
           nvl( p_sold_to_location_country, fnd_api.g_miss_char)
      AND ACCT_SITE.CUST_ACCOUNT_ID = p_sold_to_org_id  ;

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

FUNCTION END_CUSTOMER
(  p_end_customer        IN VARCHAR2
,  p_end_customer_number IN VARCHAR2
) RETURN NUMBER
IS

   l_id NUMBER;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
    oe_Debug_pub.add('entereing end customer value to id in cancel order'||p_end_customer||p_end_customer_number);
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
    oe_Debug_pub.add('End custoemr id is'||l_id);

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
   CURSOR c_site_use_id(in_end_customer_id number,in_end_customer_site_use_code varchar2) IS
      SELECT site_use.site_use_id
      FROM hz_locations loc,
      hz_party_sites site,
      hz_cust_acct_sites acct_site,
      hz_cust_site_uses site_use
      WHERE
        site_use.cust_acct_site_id=acct_site.cust_acct_site_id
        and acct_site.party_site_id=site.party_site_id
        and site.location_id=loc.location_id
	and site_use.status='A'
	and acct_site.status='A' --bug 2752321
	and acct_site.cust_account_id=in_end_customer_id
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

      CURSOR c_site_use_id2(in_end_customer_id number,in_end_customer_site_use_code varchar2) IS
	 SELECT site_use.site_use_id
	 FROM hz_locations loc,
	 hz_party_sites site,
	 hz_cust_acct_sites acct_site,
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
	 and site.location_id=loc.location_id;


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
	l_lookup_type2      	      VARCHAR2(80) :='ONT_INSTALL_BASE';

	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN
   oe_Debug_pub.add('owner');
    IF  p_ib_owner IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LOOKUP_CODE
    INTO    l_code
    FROM    OE_LOOKUPS
    WHERE   MEANING = p_ib_owner
    AND     LOOKUP_TYPE = l_lookup_type1;-- or LOOKUP_TYPE = l_lookup_type1);
 oe_Debug_pub.add('Code value found is'||l_code);
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

    IF  p_ib_installed_at_location IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  LOOKUP_CODE
    INTO    l_code
    FROM    OE_LOOKUPS
    WHERE   MEANING = p_ib_installed_at_location
    AND     LOOKUP_TYPE = l_lookup_type1;-- or LOOKUP_TYPE = l_lookup_type1);

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
    AND     LOOKUP_TYPE = l_lookup_type1;-- or LOOKUP_TYPE = l_lookup_type1);

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

END OE_CNCL_Value_To_Id;

/
