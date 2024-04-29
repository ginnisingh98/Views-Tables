--------------------------------------------------------
--  DDL for Package Body OE_EXTERNAL_CREDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_EXTERNAL_CREDIT_PVT" AS
-- $Header: OEXVCECB.pls 120.2 2006/01/10 16:53:04 spooruli ship $
--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------
  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_External_Credit_PVT';
-------------------
-- PUBLIC VARIABLES
-------------------

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------
--
--=====================================================================
-- NAME: Is_Amount_Valid
-- TYPE: PRIVATE FUNCTION
-- DESCRIPTION: This function returns TRUE if the amount is a valid amount
-- and FALSE otherwise.
--=====================================================================
FUNCTION Is_Amount_Valid
  ( p_amount                     IN NUMBER
  )
RETURN BOOLEAN
IS
BEGIN
  OE_DEBUG_PUB.Add('OEXVCECB: In Is_Amount_Valid');
  IF p_amount IS NULL THEN
    FND_MESSAGE.Set_Name('ONT', 'OE_CC_PARAMETER_NULL');
    FND_MESSAGE.SET_TOKEN ('PARAMETER_NAME', 'P_TRANSACTION_AMOUNT' );
    OE_MSG_PUB.Add;
    OE_DEBUG_PUB.Add('Validate Amount Failed.');
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
  OE_DEBUG_PUB.Add('OEXVCECB: Out Is_Amount_Valid');
EXCEPTION
  WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Is_Amount_Valid;

--=====================================================================
-- NAME: Is_Currency_Valid
-- TYPE: PRIVATE FUNCTION
-- DESCRIPTION: This function returns TRUE if the currency code is a
-- valid currency code and FALSE otherwise.
--=====================================================================
FUNCTION Is_Currency_Valid
  ( p_currency_code                     IN VARCHAR2
  , p_parameter_name                    IN VARCHAR2
  )
RETURN BOOLEAN
IS
  l_return_value BOOLEAN := TRUE;
  l_curr_valid NUMBER;
BEGIN
  OE_DEBUG_PUB.Add('OEXVCECB: In Is_Currency_Valid');
  IF p_currency_code IS NULL THEN
    FND_MESSAGE.Set_Name('ONT', 'OE_CC_PARAMETER_NULL');
    FND_MESSAGE.SET_TOKEN ('PARAMETER_NAME', p_parameter_name );
    OE_MSG_PUB.Add;
    OE_DEBUG_PUB.Add('Validate Currency Failed - NULL.');
    l_return_value := FALSE;
  ELSE
    BEGIN
      SELECT 1
      INTO   l_curr_valid
      FROM   fnd_currencies
      WHERE  currency_code = p_currency_code
      AND    enabled_flag = 'Y'
      AND    NVL(start_date_active, TO_DATE('01/01/1000','DD/MM/YYYY'))
             <= TRUNC(SYSDATE)
      AND    NVL(end_date_active, TO_DATE('31/12/9999','DD/MM/YYYY'))
             >= TRUNC(SYSDATE) ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.Set_Name('ONT', 'OE_CC_CURRENCY_INVALID');
        FND_MESSAGE.SET_TOKEN ('PARAMETER_NAME', p_parameter_name);
        FND_MESSAGE.SET_TOKEN ('PARAMETER_VALUE', p_currency_code);
        OE_MSG_PUB.Add;
        OE_DEBUG_PUB.Add('Validate Currency Failed - Invalid.');
        l_return_value := FALSE;
    END;
  END IF;
  RETURN l_return_value;
  OE_DEBUG_PUB.Add('OEXVCECB: Out Is_Currency_Valid');
EXCEPTION
  WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Is_Currency_Valid;

--=====================================================================
-- NAME: Get_Operating_Unit_ID
-- TYPE: PRIVATE PROCEDURE
-- DESCRIPTION: This procedure validate the operating unit ID if provided.
-- else it validate the operating unit name and convert it to the ID.
--=====================================================================
PROCEDURE Get_Operating_Unit_ID
  (   p_org_id                     IN NUMBER
    , p_operating_unit_name        IN VARCHAR2
    , x_org_id                    OUT NOCOPY NUMBER
    , x_return_status             OUT NOCOPY VARCHAR2
  )
IS
  l_multi_org_flag fnd_product_groups.multi_org_flag%TYPE;
  l_org_id         NUMBER;
BEGIN
  OE_DEBUG_PUB.Add('OEXVCECB: In Get_Operating_Unit_ID');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --If the set is multi-org, then get the operating unit information, else
  --return NULL for the org_id.
  SELECT NVL(multi_org_flag, 'N')
  INTO   l_multi_org_flag
  FROM   fnd_product_groups;
  --
  --If both the ou name and org ID are provided, the ou name will be ignored.
  --
  IF l_multi_org_flag = 'Y' THEN
    IF p_org_id IS NOT NULL AND p_org_id<>FND_API.G_MISS_NUM THEN
      BEGIN
        SELECT organization_id
        INTO   l_org_id
        FROM   hr_operating_units
        WHERE  organization_id = p_org_id;
        x_org_id := p_org_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('ONT', 'OE_CC_ORG_ID_INVALID');
          FND_MESSAGE.SET_TOKEN ('PARAMETER_NAME', 'P_ORG_ID' );
          FND_MESSAGE.SET_TOKEN ('PARAMETER_VALUE', p_org_id);
          OE_MSG_PUB.Add;
      END;
    ELSIF p_org_id IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('ONT', 'OE_CC_ORG_PARAMETER_NULL');
      FND_MESSAGE.SET_TOKEN ('PARAMETER_NAME', 'P_ORG_ID' );
      OE_MSG_PUB.Add;
    ELSIF p_operating_unit_name IS NOT NULL AND
          p_operating_unit_name <> FND_API.G_MISS_CHAR THEN
      BEGIN
        SELECT organization_id
        INTO   l_org_id
        FROM   hr_operating_units
        WHERE  name = p_operating_unit_name;
        x_org_id := l_org_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('ONT', 'OE_CC_ORG_NAME_INVALID');
          FND_MESSAGE.SET_TOKEN ('PARAMETER_NAME', 'P_OPERATION_UNIT_NAME');
          FND_MESSAGE.SET_TOKEN ('PARAMETER_VALUE', p_operating_unit_name );
          OE_MSG_PUB.Add;
      END;
    ELSIF p_operating_unit_name IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('ONT', 'OE_CC_ORG_PARAMETER_NULL');
      FND_MESSAGE.SET_TOKEN ('PARAMETER_NAME', 'P_OPERATION_UNIT_NAME' );
      OE_MSG_PUB.Add;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('ONT', 'OE_CC_ORG_INFO_MISSING');
      FND_MESSAGE.SET_TOKEN ('P_ORG_NAME', 'P_OPERATION_UNIT_NAME' );
      FND_MESSAGE.SET_TOKEN ('P_ORG_ID',   'P_ORG_ID' );
      OE_MSG_PUB.Add;
    END IF;
  ELSE
    x_org_id := NULL;
  END IF;
  OE_DEBUG_PUB.Add('OEXVCECB: Out Get_Operating_Unit_ID');
EXCEPTION
  WHEN OTHERS THEN
    OE_DEBUG_PUB.Add('Get_Operating_Unit_ID: Unexpected Error');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Operating_Unit_ID;

--=====================================================================
-- NAME: Get_Credit_Check_Rule_ID
-- TYPE: PRIVATE PROCEDURE
-- DESCRIPTION: This procedure validate the credit check rule ID if provided.
-- else it validate the operating unit name and convert it to the ID.
--=====================================================================
PROCEDURE Get_Credit_Check_Rule_ID
  (  p_credit_check_rule_id          IN NUMBER
   , p_credit_check_rule_name        IN VARCHAR2
   , x_credit_check_rule_id         OUT NOCOPY NUMBER
   , x_return_status                OUT NOCOPY VARCHAR2
  )
IS
  l_credit_check_rule_id NUMBER := NULL;
  l_credit_check_rule_name
    oe_credit_check_rules.name%TYPE := NULL;
  l_credit_check_level_code
    oe_credit_check_rules.credit_check_level_code%TYPE := NULL;
  l_check_item_categories_flag
    oe_credit_check_rules.check_item_categories_flag%TYPE := NULL;
BEGIN
  OE_DEBUG_PUB.Add('OEXVCECB: In Get_Credit_Check_Rule_ID');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_credit_check_rule_id IS NOT NULL AND
     p_credit_check_rule_id <> FND_API.G_MISS_NUM THEN
    BEGIN
      SELECT credit_check_rule_id,
             name,
             credit_check_level_code,
             check_item_categories_flag
      INTO   l_credit_check_rule_id,
             l_credit_check_rule_name,
	     l_credit_check_level_code,
             l_check_item_categories_flag
      FROM   oe_credit_check_rules
      WHERE  credit_check_rule_id = p_credit_check_rule_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('ONT', 'OE_CC_CCR_ID_INVALID');
        FND_MESSAGE.SET_TOKEN('PARAMETER_NAME', 'P_CREDIT_CHECK_RULE_ID');
        FND_MESSAGE.SET_TOKEN('PARAMETER_VALUE', p_credit_check_rule_id );
        OE_MSG_PUB.Add;
    END;
  ELSIF p_credit_check_rule_id IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('ONT', 'OE_CC_PARAMETER_NULL');
    FND_MESSAGE.SET_TOKEN ('PARAMETER_NAME', 'P_CREDIT_CHECK_RULE_ID' );
    OE_MSG_PUB.Add;
  ELSIF p_credit_check_rule_name IS NOT NULL AND
        p_credit_check_rule_name <> FND_API.G_MISS_CHAR THEN
    BEGIN
      SELECT credit_check_rule_id,
             name,
             credit_check_level_code,
             check_item_categories_flag
      INTO   l_credit_check_rule_id,
             l_credit_check_rule_name,
             l_credit_check_level_code,
             l_check_item_categories_flag
      FROM   oe_credit_check_rules
      WHERE  name = p_credit_check_rule_name;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('ONT', 'OE_CC_CCR_NAME_INVALID');
        FND_MESSAGE.SET_TOKEN ('PARAMETER_NAME', 'P_CREDIT_CHECK_RULE_NAME');
        FND_MESSAGE.SET_TOKEN ('PARAMETER_VALUE', p_credit_check_rule_name );
        OE_MSG_PUB.Add;
    END;
  ELSIF p_credit_check_rule_name IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('ONT', 'OE_CC_PARAMETER_NULL');
    FND_MESSAGE.SET_TOKEN('PARAMETER_NAME', 'P_CREDIT_CHECK_RULE_NAME');
    OE_MSG_PUB.Add;
  ELSE
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('ONT', 'OE_CC_CCR_INFO_MISSING');
    FND_MESSAGE.SET_TOKEN ('P_CCR_NAME', 'P_CREDIT_CHECK_RULE_NAME' );
    FND_MESSAGE.SET_TOKEN ('P_CCR_ID', 'P_CREDIT_CHECK_RULE_ID' );
    OE_MSG_PUB.Add;
  END IF;
  --
  -- If the credit rule is valid, check that it has the correct flag set.
  --
  OE_DEBUG_PUB.Add('l_credit_check_rule_id: '||l_credit_check_rule_id);
  OE_DEBUG_PUB.Add('l_name : '||l_credit_check_rule_name);
  OE_DEBUG_PUB.Add('l_check_item_categories_flag: '||l_check_item_categories_flag);
  OE_DEBUG_PUB.Add('l_credit_check_level_code: '||l_credit_check_level_code);
  IF l_credit_check_rule_id IS NOT NULL THEN
    IF NVL(l_credit_check_level_code, 'ORDER') <> 'ORDER' OR
      NVL(l_check_item_categories_flag,'N') <> 'N' THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('ONT', 'OE_CC_CCR_INVALID');
      FND_MESSAGE.Set_Token('CCR_NAME', l_credit_check_rule_name);
      FND_MESSAGE.Set_Token('API_NAME', 'Check_External_Credit');
      OE_MSG_PUB.Add;
    ELSE
      x_credit_check_rule_id := l_credit_check_rule_id;
    END IF;
  END IF;
  OE_DEBUG_PUB.Add('OEXVCECB: Out Get_Credit_Check_Rule_ID');
EXCEPTION
  WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Credit_Check_Rule_ID;

--=====================================================================
-- NAME: Address_Value_To_ID
-- TYPE: PRIVATE FUNCTION
-- DESCRIPTION: This function returns the bill_to site use ID given the
-- bill-to address and customer information.
--=====================================================================

FUNCTION Address_Value_To_ID
  (  p_bill_to_address1           IN  VARCHAR2
   , p_bill_to_address2           IN  VARCHAR2
   , p_bill_to_address3           IN  VARCHAR2
   , p_bill_to_address4           IN  VARCHAR2
   , p_customer_id                IN  NUMBER
   , p_bill_to_city               IN VARCHAR2 DEFAULT NULL
   , p_bill_to_state              IN VARCHAR2 DEFAULT NULL
   , p_bill_to_postal_code        IN VARCHAR2 DEFAULT NULL
   , p_bill_to_country            IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER
IS
  CURSOR c_bill_to_site_use_id IS
    SELECT /* MOAC_SQL_NO_CHANGE */ ORGANIZATION_ID
    FROM OE_INVOICE_TO_ORGS_V
    WHERE  ADDRESS_LINE_1  = p_bill_to_address1
         AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_bill_to_address2, fnd_api.g_miss_char)
         AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_bill_to_address3,fnd_api.g_miss_char)
         AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_bill_to_address4,fnd_api.g_miss_char)
         AND nvl(TOWN_OR_CITY,fnd_api.g_miss_char) =
           nvl( p_bill_to_city, fnd_api.g_miss_char)
         AND nvl(STATE,fnd_api.g_miss_char) =
           nvl( p_bill_to_state, fnd_api.g_miss_char)
         AND nvl(POSTAL_CODE,fnd_api.g_miss_char) =
           nvl( p_bill_to_postal_code, fnd_api.g_miss_char)
         AND nvl(COUNTRY,fnd_api.g_miss_char) =
           nvl( p_bill_to_country, fnd_api.g_miss_char)
      AND STATUS = 'A'
      AND CUSTOMER_ID = p_customer_id
      and address_status='A'; --2752321

  CURSOR C1 IS
    SELECT /* MOAC_SQL_NO_CHANGE */ ORGANIZATION_ID
    FROM   OE_INVOICE_TO_ORGS_V
    WHERE  ADDRESS_LINE_1  = p_bill_to_address1
    AND    nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_bill_to_address2, fnd_api.g_miss_char)
    AND    nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_bill_to_address3,fnd_api.g_miss_char)
    AND    nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_bill_to_address4,fnd_api.g_miss_char)
    AND    nvl(TOWN_OR_CITY,fnd_api.g_miss_char) =
           nvl( p_bill_to_city, fnd_api.g_miss_char)
    AND    nvl(STATE,fnd_api.g_miss_char) =
           nvl( p_bill_to_state, fnd_api.g_miss_char)
    AND    nvl(POSTAL_CODE,fnd_api.g_miss_char) =
           nvl( p_bill_to_postal_code, fnd_api.g_miss_char)
    AND    nvl(COUNTRY,fnd_api.g_miss_char) =
           nvl( p_bill_to_country, fnd_api.g_miss_char)
    AND STATUS = 'A'
    and address_status='A'  --2752321
    AND CUSTOMER_ID IN
        (
         SELECT p_customer_id
         FROM DUAL
         UNION
         SELECT CUST_ACCOUNT_ID
         FROM   HZ_CUST_ACCT_RELATE
         WHERE  RELATED_CUST_ACCOUNT_ID = p_customer_id
         AND    bill_to_flag = 'Y');

  CURSOR C2 IS
    SELECT /* MOAC_SQL_NO_CHANGE */  ORGANIZATION_ID
    FROM   OE_INVOICE_TO_ORGS_V
    WHERE  ADDRESS_LINE_1  = p_bill_to_address1
         AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_bill_to_address2, fnd_api.g_miss_char)
         AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_bill_to_address3,fnd_api.g_miss_char)
         AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_bill_to_address4,fnd_api.g_miss_char)
         AND nvl(TOWN_OR_CITY,fnd_api.g_miss_char) =
           nvl( p_bill_to_city, fnd_api.g_miss_char)
         AND nvl(STATE,fnd_api.g_miss_char) =
           nvl( p_bill_to_state, fnd_api.g_miss_char)
         AND nvl(POSTAL_CODE,fnd_api.g_miss_char) =
           nvl( p_bill_to_postal_code, fnd_api.g_miss_char)
         AND nvl(COUNTRY,fnd_api.g_miss_char) =
           nvl( p_bill_to_country, fnd_api.g_miss_char)
         AND STATUS = 'A'
	 and address_status='A'; --2752321

  l_bill_to_site_use_id  NUMBER;
  l_bill_to_site_use_id2 NUMBER;
  l_customer_relations   VARCHAR2(1);
  l_org varchar2(100);
BEGIN
  OE_DEBUG_PUB.Add('OEXVCECB: In Address_Value_To_ID');
  OE_DEBUG_PUB.Add('p_customer_id:      '||p_customer_id);
  OE_DEBUG_PUB.Add('p_bill_to_address1: '||p_bill_to_address1);
  OE_DEBUG_PUB.Add('p_bill_to_address2: '||p_bill_to_address2);
  OE_DEBUG_PUB.Add('p_bill_to_address3: '||p_bill_to_address3);
  OE_DEBUG_PUB.Add('p_bill_to_address4: '||p_bill_to_address4);
  -- Comment out this part as this is not needed for this API
  --IF p_bill_to_address1 IS NULL
  --  OR p_bill_to_address2 IS NULL
  --  OR p_bill_to_address3 IS NULL
  --  OR p_bill_to_address4 IS NULL
  --THEN
  --  RETURN NULL;
  --END IF;

  l_customer_relations:= OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');
  OE_DEBUG_PUB.Add('CUSTOMER_RELATIONSHIPS_FLAG: '||l_customer_relations);

  IF l_customer_relations = 'N' THEN
    OPEN  c_bill_to_site_use_id;
    FETCH c_bill_to_site_use_id
    INTO  l_bill_to_site_use_id;

    IF c_bill_to_site_use_id%FOUND THEN
      -- Check for more than one site use
      FETCH c_bill_to_site_use_id
      INTO  l_bill_to_site_use_id2;
      IF c_bill_to_site_use_id%FOUND THEN
        RAISE TOO_MANY_ROWS;
      END IF;
      CLOSE c_bill_to_site_use_id;
      RETURN l_bill_to_site_use_id;
    ELSE
      SELECT /* MOAC_SQL_NO_CHANGE */ ORGANIZATION_ID
      INTO   l_bill_to_site_use_id
      FROM   OE_INVOICE_TO_ORGS_V
      WHERE  ADDRESS_LINE_1  = p_bill_to_address1
         AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_bill_to_address2, fnd_api.g_miss_char)
         AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_bill_to_address3,fnd_api.g_miss_char)
         AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
           NVL( p_bill_to_address4, fnd_api.g_miss_char)
         AND STATUS = 'A'
         AND CUSTOMER_ID = p_customer_id
	 and address_status='A'; --2752321;
    END IF;

    CLOSE c_bill_to_site_use_id;
    RETURN l_bill_to_site_use_id;

  ELSIF l_customer_relations = 'Y' THEN
    OPEN  C1;
    FETCH C1
    INTO  l_bill_to_site_use_id;

    IF C1%FOUND then
      OE_DEBUG_PUB.Add('Found');
      -- Check for more than one site use
      FETCH C1
      INTO  l_bill_to_site_use_id2;
      IF C1%FOUND THEN
        RAISE TOO_MANY_ROWS;
      END IF;
      CLOSE  C1;
      RETURN l_bill_to_site_use_id;
    ELSE
      oe_debug_pub.add('not found');
      -- comment out the following call for MOAC
      -- select userenv('CLIENT_INFO') into l_org from dual;
      -- oe_debug_pub.add('org='||l_org);

      SELECT /* MOAC_SQL_NO_CHANGE */ ORGANIZATION_ID
      INTO   l_bill_to_site_use_id
      FROM   OE_INVOICE_TO_ORGS_V
      WHERE  ADDRESS_LINE_1  = p_bill_to_address1
         AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_bill_to_address2, fnd_api.g_miss_char)
         AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_bill_to_address3,fnd_api.g_miss_char)
         AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
           nvl( p_bill_to_address4, fnd_api.g_miss_char)
         AND STATUS = 'A'
	 and address_status='A' --2752321
         AND CUSTOMER_ID IN
            (SELECT p_customer_id
             FROM   DUAL
             UNION
             SELECT CUST_ACCOUNT_ID
             FROM   HZ_CUST_ACCT_RELATE
             WHERE  RELATED_CUST_ACCOUNT_ID = p_customer_id
             AND    bill_to_flag = 'Y');
      oe_debug_pub.add('after select found='||l_bill_to_site_use_id);
    END IF;

    CLOSE C1;
    oe_debug_pub.add('returning from the function');
    RETURN l_bill_to_site_use_id;
  ELSIF l_customer_relations = 'A' THEN
    OPEN C2;
    FETCH C2
    INTO l_bill_to_site_use_id;

    IF C2%FOUND then
      -- Check for more than one site use
      FETCH C2
      INTO  l_bill_to_site_use_id2;
      IF C2%FOUND THEN
        RAISE TOO_MANY_ROWS;
      END IF;
      CLOSE C2;
      RETURN l_bill_to_site_use_id;
    ELSE
      SELECT ORGANIZATION_ID
      INTO   l_bill_to_site_use_id
      FROM   OE_INVOICE_TO_ORGS_V
      WHERE  ADDRESS_LINE_1  = p_bill_to_address1
      AND    nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
             nvl( p_bill_to_address2, fnd_api.g_miss_char)
      AND    nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
             nvl( p_bill_to_address3,fnd_api.g_miss_char)
      AND    DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
             NVL( p_bill_to_address4, fnd_api.g_miss_char)
      AND    STATUS = 'A'
      and address_status='A'; --2752321
    END IF;

    CLOSE C2;
    RETURN l_bill_to_site_use_id;
  END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF c_bill_to_site_use_id%ISOPEN then
        CLOSE c_bill_to_site_use_id;
      END IF;

      IF C1%ISOPEN then
        CLOSE C1;
      END IF;

      IF C2%ISOPEN then
        CLOSE C2;
      END IF;

      FND_MESSAGE.SET_NAME('ONT','OE_CC_BILL_TO_ADDRESS_INVALID');
      OE_MSG_PUB.Add;
      OE_DEBUG_PUB.Add('No data found error in Address_Value_To_ID');
      RETURN FND_API.G_MISS_NUM;
    WHEN TOO_MANY_ROWS THEN
      IF c_bill_to_site_use_id%ISOPEN then
        CLOSE c_bill_to_site_use_id;
      END IF;

      IF C1%ISOPEN then
        CLOSE C1;
      END IF;

      IF C2%ISOPEN then
        CLOSE C2;
      END IF;

      FND_MESSAGE.SET_NAME('ONT','OE_CC_BILL_TO_ADDRESS_MULTI');
      OE_MSG_PUB.Add;
      OE_DEBUG_PUB.Add('Too many rows error in Address_Value_To_ID');
      RETURN FND_API.G_MISS_NUM;
    WHEN OTHERS THEN
      OE_DEBUG_PUB.Add('Unexpected error in Address_Value_To_ID');
      IF c_bill_to_site_use_id%ISOPEN then
        CLOSE c_bill_to_site_use_id;
      END IF;

      IF C1%ISOPEN then
        CLOSE C1;
      END IF;

      IF C2%ISOPEN then
        CLOSE C2;
      END IF;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME
          ,   'Address_Value_To_ID'
          );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Address_Value_To_ID;

--=====================================================================
-- NAME: Get_Bill_To_Site_Use_ID
-- TYPE: PRIVATE PROCEDURE
-- DESCRIPTION: This procedure validate the bill-to site use ID if provided.
-- else it validate the other parameters and derive the site use ID.
--=====================================================================
PROCEDURE Get_Bill_To_Site_Use_ID
  ( p_bill_to_site_use_id        IN NUMBER
   ,p_customer_name              IN VARCHAR2
   ,p_customer_number            IN VARCHAR2
   ,p_customer_id                IN NUMBER
   ,p_bill_to_address1           IN VARCHAR2
   ,p_bill_to_address2           IN VARCHAR2
   ,p_bill_to_address3           IN VARCHAR2
   ,p_bill_to_address4           IN VARCHAR2
   ,p_bill_to_city               IN VARCHAR2
   ,p_bill_to_country            IN VARCHAR2
   ,p_bill_to_postal_code        IN VARCHAR2
   ,p_bill_to_state              IN VARCHAR2
   ,p_bill_to_county             IN VARCHAR2
   ,p_bill_to_province           IN VARCHAR2
   ,p_org_id                     IN NUMBER
   ,x_return_status             OUT NOCOPY VARCHAR2
   ,x_bill_to_site_use_id       OUT NOCOPY NUMBER
  )
IS
  l_bill_to_site_use_id NUMBER;
  l_customer_id         NUMBER;
  l_bill_to_state       VARCHAR2(60);
BEGIN
  OE_DEBUG_PUB.Add('OEXVCECB: In Get_Bill_To_Site_Use_ID');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --bug4933291
  OE_DEBUG_PUB.Add('p_org_id:                   '||p_org_id);
  OE_DEBUG_PUB.Add('p_bill_to_site_use_id:      '||p_bill_to_site_use_id);

  IF p_bill_to_site_use_id IS NOT NULL AND
     p_bill_to_site_use_id <> FND_API.G_MISS_NUM THEN
    BEGIN
      SELECT site_use_id
      INTO   l_bill_to_site_use_id
      FROM   hz_cust_site_uses_all
      WHERE  site_use_id = p_bill_to_site_use_id
      AND    site_use_code = 'BILL_TO'
      AND    NVL(org_id, -99) = NVL(p_org_id, -99);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- This same error message takes care of the case of NULL value
        -- passed in since a NULL in the select will not select any rows.
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('ONT', 'OE_CC_SITE_USE_ID_INVALID');
        FND_MESSAGE.Set_Token('PARAMETER_NAME', 'P_BILL_TO_SITE_USE_ID');
        FND_MESSAGE.Set_Token('PARAMETER_VALUE', p_bill_to_site_use_id );
        OE_MSG_PUB.Add;
    END;
  ELSIF p_bill_to_site_use_id IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('ONT', 'OE_CC_PARAMETER_NULL');
    FND_MESSAGE.SET_TOKEN ('PARAMETER_NAME', 'P_BILL_TO_SITE_USE_ID' );
    OE_MSG_PUB.Add;

  ELSIF
    -- The location and customer information must be provided to derive a
    -- unique site use id.
    -- Note that county is not used for ID derivation since it is not used
    -- by order import either.
    (p_bill_to_address1     <> FND_API.G_MISS_CHAR OR
     p_bill_to_address2     <> FND_API.G_MISS_CHAR OR
     p_bill_to_address3     <> FND_API.G_MISS_CHAR OR
     p_bill_to_address4     <> FND_API.G_MISS_CHAR OR
     p_bill_to_city         <> FND_API.G_MISS_CHAR OR
     p_bill_to_country      <> FND_API.G_MISS_CHAR OR
     p_bill_to_postal_code  <> FND_API.G_MISS_CHAR OR
     p_bill_to_state        <> FND_API.G_MISS_CHAR OR
     p_bill_to_province     <> FND_API.G_MISS_CHAR)
  THEN
    -- Determine the l_bill_to_state value to pass to Address_Value_To_ID
    -- function.  If the state parameter is provided, pass it, else pass the
    -- province information (bug 2346992).
    IF NVL(p_bill_to_state,FND_API.G_MISS_CHAR)=FND_API.G_MISS_CHAR THEN
      l_bill_to_state := p_bill_to_province;
    ELSE
      l_bill_to_state := p_bill_to_state;
    END IF;

    -- location information exists, now check for a valid customer.
    IF p_customer_id IS NOT NULL AND p_customer_id <> FND_API.G_MISS_NUM THEN
      l_bill_to_site_use_id := Address_Value_To_ID(
         p_bill_to_address1 => p_bill_to_address1,
         p_bill_to_address2 => p_bill_to_address2,
         p_bill_to_address3 => p_bill_to_address3,
         p_bill_to_address4 => p_bill_to_address4,
         p_customer_id      => p_customer_id,
         p_bill_to_city     => p_bill_to_city,
         p_bill_to_state    => l_bill_to_state,
         p_bill_to_postal_code => p_bill_to_postal_code,
         p_bill_to_country  => p_bill_to_country
         );
      OE_DEBUG_PUB.Add('l_bill_to_site_use_id: '||l_bill_to_site_use_id);
      IF NVL(l_bill_to_site_use_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    ELSIF p_customer_id IS NULL THEN
      -- set error message
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('ONT', 'OE_CC_PARAMETER_NULL');
      FND_MESSAGE.SET_TOKEN ('PARAMETER_NAME', 'P_CUSTOMER_ID' );
      OE_MSG_PUB.Add;
    ELSIF p_customer_name   <> FND_API.G_MISS_CHAR AND
         p_customer_number <> FND_API.G_MISS_CHAR THEN
      -- check for valid customer_id
      BEGIN
        SELECT hca.cust_account_id
        INTO   l_customer_id
        FROM   hz_cust_accounts hca,
               hz_parties hp
        WHERE  hca.party_id = hp.party_id
        AND    hp.party_name = p_customer_name
        AND    hca.account_number = p_customer_number;
        --
        -- then get bill_to_site_use_id
        --
        l_bill_to_site_use_id := Address_Value_To_ID(
           p_bill_to_address1 => p_bill_to_address1,
           p_bill_to_address2 => p_bill_to_address2,
           p_bill_to_address3 => p_bill_to_address3,
           p_bill_to_address4 => p_bill_to_address4,
           p_customer_id      => l_customer_id,
           p_bill_to_city     => p_bill_to_city,
           p_bill_to_state    => l_bill_to_state,
           p_bill_to_postal_code => p_bill_to_postal_code,
           p_bill_to_country  => p_bill_to_country
           );
        OE_DEBUG_PUB.Add('l_bill_to_site_use_id: '||l_bill_to_site_use_id);
        IF NVL(l_bill_to_site_use_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('ONT', 'OE_CC_CUSTOMER_INFO_INVALID');
          FND_MESSAGE.SET_TOKEN ('P_CUSTOMER_NAME', 'P_CUSTOMER_NAME' );
          FND_MESSAGE.SET_TOKEN ('P_CUSTOMER_NUMBER', 'P_CUSTOMER_NUMBER' );
          OE_MSG_PUB.Add;
      END;
    ELSE
      -- customer information is missing
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('ONT', 'OE_CC_CUSTOMER_INFO_MISSING');
      FND_MESSAGE.SET_TOKEN ('P_CUSTOMER_NAME', 'P_CUSTOMER_NAME' );
      FND_MESSAGE.SET_TOKEN ('P_CUSTOMER_NUMBER', 'P_CUSTOMER_NUMBER' );
      FND_MESSAGE.SET_TOKEN ('P_CUSTOMER_ID', 'P_CUSTOMER_ID');
      OE_MSG_PUB.Add;
    END IF;
  ELSE
    -- insufficient information is provided to derive the invoice site use id.
    -- refer use to API documentation. Either the bill_to site use ID needs
    -- to be provided or the bill-to address.
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('ONT', 'OE_CC_SITE_USE_INFO_INVALID');
    OE_MSG_PUB.Add;
  END IF;
  x_bill_to_site_use_id := l_bill_to_site_use_id;
  OE_DEBUG_PUB.Add('OEXVCECB: Out Get_Bill_To_Site_Use_ID');
EXCEPTION
  WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Bill_To_Site_Use_ID;

--=====================================================================
--API NAME:     Check_External_Credit
--TYPE:         PRIVATE
--DESCRIPTION:  This procedure validate the input parameters given to the
--              Check External Credit API and calls the credit check engine.
--Parameters:
--IN
--OUT
--Version:  	Current Version   	1.0
--              Previous Version  	1.0
--=====================================================================
PROCEDURE Check_External_Credit
  ( p_api_version                IN NUMBER
  , p_init_msg_list              IN VARCHAR2 	:= FND_API.G_FALSE
  , x_return_status             OUT NOCOPY VARCHAR2
  , x_msg_count                 OUT NOCOPY NUMBER
  , x_msg_data                  OUT NOCOPY VARCHAR2
  , p_customer_name	         IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_customer_number            IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_customer_id                IN NUMBER      := FND_API.G_MISS_NUM
  , p_bill_to_site_use_id        IN NUMBER      := FND_API.G_MISS_NUM
  , p_bill_to_address1           IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_address2           IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_address3           IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_address4           IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_city               IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_country            IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_postal_code        IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_state              IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_county             IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_bill_to_province           IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_credit_check_rule_name     IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_credit_check_rule_id       IN NUMBER      := FND_API.G_MISS_NUM
  , p_functional_currency_code   IN VARCHAR2
  , p_transaction_currency_code  IN VARCHAR2
  , p_transaction_amount         IN NUMBER
  , p_operating_unit_name        IN VARCHAR2    := FND_API.G_MISS_CHAR
  , p_org_id                     IN NUMBER      := FND_API.G_MISS_NUM
  , x_result_out                OUT NOCOPY VARCHAR2
  , x_cc_hold_comment           OUT NOCOPY VARCHAR2
  )
IS
  l_api_name 	CONSTANT VARCHAR2(30) := 'Check_External_Credit';
  l_api_version	CONSTANT NUMBER       := 1.0;
  l_any_errors  BOOLEAN := FALSE;
  l_return_status        VARCHAR2(30);
  l_org_id               NUMBER;
  l_bill_to_site_use_id  NUMBER;
  l_credit_check_rule_id NUMBER;
BEGIN
  OE_DEBUG_PUB.Add('OEXVCECB: In Check_External_Credit');
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check the API version and issue an error if the given API version does not
  -- match the one in this package.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    FND_MSG_PUB.Delete_Msg;
    FND_MESSAGE.Set_Name('ONT', 'OE_CC_API_VERSION_MISMATCH');
    FND_MESSAGE.SET_TOKEN ('API_NAME', l_api_name );
    FND_MESSAGE.SET_TOKEN ('P_API_VERSION', p_api_version );
    FND_MESSAGE.SET_TOKEN ('CURR_VER_NUM',l_api_version);
    FND_MESSAGE.SET_TOKEN ('CALLER_VER_NUM',p_api_version);
    OE_MSG_PUB.Add;
    OE_DEBUG_PUB.Add('l_api_version: '||l_api_version);
    OE_DEBUG_PUB.Add('p_api_version: '||p_api_version);
    OE_DEBUG_PUB.Add('API Versin Check Failed.');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --
  -- Show input parameters
  --
  OE_DEBUG_PUB.Add('*****API Input Parameters*****');
  OE_DEBUG_PUB.Add('p_credit_check_rule_name:   '||p_credit_check_rule_name);
  OE_DEBUG_PUB.Add('p_credit_check_rule_id:     '||p_credit_check_rule_id);
  OE_DEBUG_PUB.Add('p_operating_unit_name:      '||p_operating_unit_name);
  OE_DEBUG_PUB.Add('p_org_id:                   '||p_org_id);
  OE_DEBUG_PUB.Add('p_functional_currency_code: '||p_functional_currency_code);
  OE_DEBUG_PUB.Add('p_transaction_currency_code: '||p_transaction_currency_code);
  OE_DEBUG_PUB.Add('p_transaction_amount:       '||p_transaction_amount);
  OE_DEBUG_PUB.Add('p_customer_name:            '||p_customer_name);
  OE_DEBUG_PUB.Add('p_customer_number:          '||p_customer_number);
  OE_DEBUG_PUB.Add('p_customer_id:              '||p_customer_id);
  OE_DEBUG_PUB.Add('p_bill_to_site_use_id:      '||p_bill_to_site_use_id);
  OE_DEBUG_PUB.Add('p_bill_to_address1:         '||p_bill_to_address1);
  OE_DEBUG_PUB.Add('p_bill_to_address2:         '||p_bill_to_address2);
  OE_DEBUG_PUB.Add('p_bill_to_address3:         '||p_bill_to_address3);
  OE_DEBUG_PUB.Add('p_bill_to_address4:         '||p_bill_to_address4);
  OE_DEBUG_PUB.Add('p_bill_to_city:             '||p_bill_to_city);
  OE_DEBUG_PUB.Add('p_bill_to_state:            '||p_bill_to_state);
  OE_DEBUG_PUB.Add('p_bill_to_postal_code:      '||p_bill_to_postal_code);
  OE_DEBUG_PUB.Add('p_bill_to_country:          '||p_bill_to_country);
  OE_DEBUG_PUB.Add('p_bill_to_county:           '||p_bill_to_county);
  OE_DEBUG_PUB.Add('p_bill_to_province:         '||p_bill_to_province);


  -- Validate the transaction amount parameter
  IF NOT Is_Amount_Valid(p_amount => p_transaction_amount) AND
     NOT l_any_errors THEN
    l_any_errors := TRUE;
    OE_DEBUG_PUB.Add('Validate Amount Failed.');
  END IF;

  -- Validate the currency parameters
  IF NOT Is_Currency_Valid(p_currency_code  => p_transaction_currency_code,
                           p_parameter_name => 'P_TRANSACTION_CURRENCY_CODE')
    AND
    NOT l_any_errors THEN
    l_any_errors := TRUE;
    OE_DEBUG_PUB.Add('Validate Transaction Currency Failed.');
  END IF;

  IF NOT Is_Currency_Valid(p_currency_code  => p_functional_currency_code,
                           p_parameter_name => 'P_FUNCTIONAL_CURRENCY_CODE')
    AND
    NOT l_any_errors THEN
    l_any_errors := TRUE;
    OE_DEBUG_PUB.Add('Validate Functional Currency Failed.');
  END IF;

  -- Validate the credit check rule parameters
  Get_Credit_Check_Rule_ID(
      p_credit_check_rule_id   => p_credit_check_rule_id
    , p_credit_check_rule_name => p_credit_check_rule_name
    , x_credit_check_rule_id   => l_credit_check_rule_id
    , x_return_status          => l_return_status
    );
  OE_DEBUG_PUB.Add('l_credit_check_rule_id: '||l_credit_check_rule_id);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS AND
    NOT l_any_errors THEN
    l_any_errors := TRUE;
    OE_DEBUG_PUB.Add('Validate Credit Check Rule Failed.');
  END IF;

  -- Validate the operating unit parameters
  -- MOAC related changes, comment out the code per discussion
  -- with Sam
/*
  Get_Operating_Unit_ID(
      p_org_id              => p_org_id
    , p_operating_unit_name => p_operating_unit_name
    , x_org_id              => l_org_id
    , x_return_status       => l_return_status
    );
  OE_DEBUG_PUB.Add('l_return_status: '||l_return_status);
  OE_DEBUG_PUB.Add('l_org_id: '|| l_org_id);
*/

  -- dbms_application_info.set_client_info(l_org_id);
--  MO_GLOBAL.set_policy_context ('S', p_org_id);   --bug4933291

  --bug4933291
  IF p_org_id IS NOT NULL THEN
     MO_GLOBAL.Set_Policy_Context('S',p_org_id);
     l_org_id := p_org_id;
     OE_DEBUG_PUB.Add('Context is set for org_id : '|| l_org_id);
  ELSE
     l_return_status := FND_API.G_RET_STS_ERROR;
     OE_DEBUG_PUB.Add('Could not set org context');
  END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS AND
     NOT l_any_errors THEN
    l_any_errors := TRUE;
    OE_DEBUG_PUB.Add('Validate Operating Unit Failed.');
  END IF;

  -- Validate the location parameters
  Get_Bill_To_Site_Use_ID
  ( p_bill_to_site_use_id        => p_bill_to_site_use_id
   ,p_customer_name              => p_customer_name
   ,p_customer_number            => p_customer_number
   ,p_customer_id                => p_customer_id
   ,p_bill_to_address1           => p_bill_to_address1
   ,p_bill_to_address2           => p_bill_to_address2
   ,p_bill_to_address3           => p_bill_to_address3
   ,p_bill_to_address4           => p_bill_to_address4
   ,p_bill_to_city               => p_bill_to_city
   ,p_bill_to_country            => p_bill_to_country
   ,p_bill_to_postal_code        => p_bill_to_postal_code
   ,p_bill_to_state              => p_bill_to_state
   ,p_bill_to_county             => p_bill_to_county
   ,p_bill_to_province           => p_bill_to_province
   ,p_org_id                     => l_org_id
   ,x_return_status              => l_return_status
   ,x_bill_to_site_use_id        => l_bill_to_site_use_id
  );

  OE_DEBUG_PUB.Add('l_bill_to_site_use_id: '|| l_bill_to_site_use_id);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS AND
    NOT l_any_errors THEN
    l_any_errors := TRUE;
    OE_DEBUG_PUB.Add('Validate Bill-To Site Use Failed.');
  END IF;

  --
  -- If the are any errors encountered during validation of the parameters
  -- raise error and error messages and do not continue with credit checking.
  --
  IF l_any_errors THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  -- Call the OM credit check engine to perform credit checking

  OE_Credit_Engine_GRP.Check_Credit (
      x_return_status		=> x_return_status
    , x_msg_count 		=> x_msg_count
    , x_msg_data           	=> x_msg_data
    , p_header_id               => NULL
    , p_calling_action          => 'EXTERNAL'
    , p_bill_to_site_use_id  	=> l_bill_to_site_use_id
    , p_credit_check_rule_id    => l_credit_check_rule_id
    , p_functional_currency_code  => p_functional_currency_code
    , p_transaction_currency_code => p_transaction_currency_code
    , p_transaction_amount  	=> p_transaction_amount
    , p_org_id  		=> l_org_id
    , x_result_out		=> x_result_out
    , x_cc_hold_comment 	=> x_cc_hold_comment
  );

  OE_DEBUG_PUB.Add('Check_Credit Results');
  OE_DEBUG_PUB.Add('x_return_status:   '|| x_return_status);
  OE_DEBUG_PUB.Add('x_result_out:      '|| x_result_out);
  OE_DEBUG_PUB.Add('x_cc_hold_comment: '|| x_cc_hold_comment);
  OE_DEBUG_PUB.Add('OEXVCECB: Out Check_External_Credit');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_and_Get (
       p_count	=> x_msg_count
      ,p_data	=> x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    OE_MSG_PUB.Count_and_Get (
       p_count  => x_msg_count
      ,p_data   => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg (
          G_PKG_NAME
        , l_api_name);
    END IF;
    OE_MSG_PUB.Count_and_Get(
       p_count  => x_msg_count
      ,p_data   => x_msg_data);
  END Check_External_Credit;
END OE_EXTERNAL_CREDIT_PVT;

/
