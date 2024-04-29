--------------------------------------------------------
--  DDL for Package Body OE_EXT_CREDIT_EXPOSURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_EXT_CREDIT_EXPOSURE_PVT" AS
-- $Header: OEXVECEB.pls 120.4 2008/02/13 10:11:41 vybhatia ship $
--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------
  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_Ext_Credit_Exposure_PVT';
  G_COMMIT_SIZE CONSTANT NUMBER       := 10000;
  G_ERROR       CONSTANT VARCHAR2(30) := 'ERROR';
  G_VALIDATED   CONSTANT VARCHAR2(30) := 'VALIDATED';
  G_PROCESSING  CONSTANT VARCHAR2(30) := 'PROCESSING';
  G_COMPLETE    CONSTANT VARCHAR2(30) := 'COMPLETE';
-------------------
-- GLOBAL VARIABLES
-------------------
  G_request_id       NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  G_appl_id          NUMBER := FND_GLOBAL.PROG_APPL_ID;
  G_program_id       NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
  G_user_id          NUMBER := FND_GLOBAL.USER_ID;
  G_login_id         NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
  G_org_id           NUMBER := mo_global.get_current_org_id; -- MOAC Changes TO_NUMBER(FND_PROFILE.value('ORG_ID'));

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------
--
--=====================================================================
--NAME:         Insert_In_Errors_Table
--TYPE:         PRIVATE
--DESCRIPTION:  This procedure insert a row in the OE_EXP_INTERFACE_ERRORS
--              table.
--Parameters:
--IN
--OUT
--=====================================================================
PROCEDURE Insert_To_Errors_Table
  ( p_exposure_source_code      IN  VARCHAR2
  , p_batch_id                  IN  NUMBER
  , p_exposure_interface_id     IN  NUMBER
  , p_error_message_name        IN  VARCHAR2
  , p_error_message_text        IN  VARCHAR2
  )
IS
BEGIN
  OE_DEBUG_PUB.Add('OEXVECEB: In Insert_To_Errors_Table');
  --
  -- Insert row into OE_EXP_INTERFACE_ERRORS table
  --
  INSERT INTO OE_EXP_INTERFACE_ERRORS (
      EXPOSURE_SOURCE_CODE
    , EXPOSURE_INTERFACE_ID
    , BATCH_ID
    , ERROR_MESSAGE_NAME
    , ERROR_MESSAGE
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATE_LOGIN
    , PROGRAM_APPLICATION_ID
    , PROGRAM_ID
    , PROGRAM_UPDATE_DATE
    , REQUEST_ID
    )
    VALUES (
      p_exposure_source_code
    , p_exposure_interface_id
    , p_batch_id
    , p_error_message_name
    , p_error_message_text
    , G_user_id
    , SYSDATE
    , G_user_id
    , SYSDATE
    , G_login_id
    , G_appl_id
    , G_program_id
    , SYSDATE
    , G_request_id
    );
  OE_DEBUG_PUB.Add('OEXVECEB: Out Insert_To_Errors_Table');
EXCEPTION
  WHEN OTHERS THEN
    OE_DEBUG_PUB.Add('Insert_To_Errors_Table: Unexpected Error');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

--=====================================================================
-- NAME: Is_Currency_Valid
-- TYPE: PRIVATE FUNCTION
-- DESCRIPTION: This function returns TRUE if the currency code is a
-- valid currency code and FALSE otherwise.
--=====================================================================
FUNCTION Is_Currency_Valid
  ( p_exposure_rec                     IN oe_exposure_interface%ROWTYPE
  )
RETURN BOOLEAN
IS
  l_return_value BOOLEAN := TRUE;
  l_curr_valid NUMBER;
  l_message_text VARCHAR2(2000);
BEGIN
  OE_DEBUG_PUB.Add('OEXVECEB: In Is_Currency_Valid');
  BEGIN
    SELECT 1
    INTO   l_curr_valid
    FROM   fnd_currencies
    WHERE  currency_code = p_exposure_rec.currency_code
    AND    enabled_flag = 'Y'
    AND    NVL(start_date_active, TO_DATE('01/01/1000','DD/MM/YYYY'))
           <= TRUNC(SYSDATE)
    AND    NVL(end_date_active, TO_DATE('31/12/9999','DD/MM/YYYY'))
             >= TRUNC(SYSDATE) ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      OE_DEBUG_PUB.Add('Validate Currency Failed - Invalid.', 5);
      FND_MESSAGE.Set_Name('ONT', 'OE_CC_IMP_CURRENCY_INVALID');
      FND_MESSAGE.SET_TOKEN ('COLUMN_NAME','CURRENCY_CODE');
      FND_MESSAGE.SET_TOKEN ('COLUMN_VALUE', p_exposure_rec.currency_code);
      l_message_text := FND_MESSAGE.GET;
      OE_DEBUG_PUB.Add('Error: Currency invalid', 5);
      Insert_To_Errors_Table(
          p_exposure_source_code    => p_exposure_rec.exposure_source_code
        , p_exposure_interface_id   => p_exposure_rec.exposure_interface_id
        , p_batch_id                => p_exposure_rec.batch_id
        , p_error_message_name      => 'OE_CC_IMP_CURRENCY_INVALID'
        , p_error_message_text      => l_message_text
        );
      l_return_value := FALSE;
  END;
  OE_DEBUG_PUB.Add('OEXVECEB: Out Is_Currency_Valid');
  RETURN l_return_value;
EXCEPTION
  WHEN OTHERS THEN
    OE_DEBUG_PUB.Add('Is_Currency_Valid: Unexpected Error');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Is_Currency_Valid;

--=====================================================================
-- NAME: Address_Value_To_ID
-- TYPE: PRIVATE FUNCTION
-- DESCRIPTION: This function returns the bill_to site use ID given the
-- bill-to address and customer information.
--=====================================================================

FUNCTION Address_Value_To_ID
  (  p_exposure_rec               IN oe_exposure_interface%ROWTYPE
  ) RETURN NUMBER
IS

  CURSOR c_bill_to_site_use_id (p_bill_to_state VARCHAR2) IS
    SELECT ORGANIZATION_ID
    FROM OE_INVOICE_TO_ORGS_V
    WHERE  ADDRESS_LINE_1  = p_exposure_rec.bill_to_address1
         AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address2, fnd_api.g_miss_char)
         AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address3,fnd_api.g_miss_char)
         AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address4,fnd_api.g_miss_char)
         AND nvl(TOWN_OR_CITY,fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_city, fnd_api.g_miss_char)
         AND nvl(STATE,fnd_api.g_miss_char) =
           nvl( p_bill_to_state, fnd_api.g_miss_char)
         AND nvl(POSTAL_CODE,fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_postal_code, fnd_api.g_miss_char)
         AND nvl(COUNTRY,fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_country, fnd_api.g_miss_char)
      AND STATUS = 'A'
      AND CUSTOMER_ID = p_exposure_rec.bill_to_customer_id
      and address_status='A'; --2752321

  CURSOR C1 (p_bill_to_state VARCHAR2) IS
    SELECT /* MOAC_SQL_NO_CHANGE */ ORGANIZATION_ID
    FROM   OE_INVOICE_TO_ORGS_V
    WHERE  ADDRESS_LINE_1  = p_exposure_rec.bill_to_address1
    AND    nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address2, fnd_api.g_miss_char)
    AND    nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address3,fnd_api.g_miss_char)
    AND    nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address4,fnd_api.g_miss_char)
    AND    nvl(TOWN_OR_CITY,fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_city, fnd_api.g_miss_char)
    AND    nvl(STATE,fnd_api.g_miss_char) =
           nvl( p_bill_to_state, fnd_api.g_miss_char)
    AND    nvl(POSTAL_CODE,fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_postal_code, fnd_api.g_miss_char)
    AND    nvl(COUNTRY,fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_country, fnd_api.g_miss_char)
    AND STATUS = 'A'
    and address_status='A' --2752321
    AND CUSTOMER_ID IN
        (
         SELECT p_exposure_rec.bill_to_customer_id
         FROM DUAL
         UNION
         SELECT CUST_ACCOUNT_ID
         FROM   HZ_CUST_ACCT_RELATE
         WHERE  RELATED_CUST_ACCOUNT_ID = p_exposure_rec.bill_to_customer_id
         AND    bill_to_flag = 'Y');

  CURSOR C2 (p_bill_to_state VARCHAR2) IS
    SELECT ORGANIZATION_ID
    FROM   OE_INVOICE_TO_ORGS_V
    WHERE  ADDRESS_LINE_1  = p_exposure_rec.bill_to_address1
         AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address2, fnd_api.g_miss_char)
         AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address3,fnd_api.g_miss_char)
         AND nvl( ADDRESS_LINE_4, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address4,fnd_api.g_miss_char)
         AND nvl(TOWN_OR_CITY,fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_city, fnd_api.g_miss_char)
         AND nvl(STATE,fnd_api.g_miss_char) =
           nvl( p_bill_to_state, fnd_api.g_miss_char)
         AND nvl(POSTAL_CODE,fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_postal_code, fnd_api.g_miss_char)
         AND nvl(COUNTRY,fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_country, fnd_api.g_miss_char)
         AND STATUS = 'A'
	 and address_status='A'; --2752321

  l_bill_to_site_use_id  NUMBER;
  l_bill_to_site_use_id2 NUMBER;
  l_customer_relations   VARCHAR2(1);
  --MOAC Changes
  --l_org varchar2(100);
  l_message_text         VARCHAR2(2000);
  l_bill_to_state        VARCHAR2(60);

BEGIN
  OE_DEBUG_PUB.Add('OEXVECEB: In Address_Value_To_ID', 4);
  OE_DEBUG_PUB.Add('bill_to_customer_id: '||p_exposure_rec.bill_to_customer_id, 5);
  OE_DEBUG_PUB.Add('bill_to_address1   : '||p_exposure_rec.bill_to_address1, 5);
  OE_DEBUG_PUB.Add('bill_to_address2   : '||p_exposure_rec.bill_to_address2, 5);
  OE_DEBUG_PUB.Add('bill_to_address3   : '||p_exposure_rec.bill_to_address3, 5);
  OE_DEBUG_PUB.Add('bill_to_address4   : '||p_exposure_rec.bill_to_address4, 5);
  OE_DEBUG_PUB.Add('bill_to_state      : '||p_exposure_rec.bill_to_state,    5);
  OE_DEBUG_PUB.Add('bill_to_province   : '||p_exposure_rec.bill_to_province, 5);

  l_customer_relations:= OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');
  OE_DEBUG_PUB.Add('CUSTOMER_RELATIONSHIPS_FLAG: '||l_customer_relations, 5);
  --
  -- bug 2346992: Get province if state is NULL or G_MISS_CHAR
  --
  IF NVL(p_exposure_rec.bill_to_state, FND_API.G_MISS_CHAR) =
     FND_API.G_MISS_CHAR
  THEN
     l_bill_to_state := p_exposure_rec.bill_to_province;
  ELSE
     l_bill_to_state := p_exposure_rec.bill_to_state;
  END IF;
  OE_DEBUG_PUB.Add('l_bill_to_state    : '||l_bill_to_state, 5);

  IF l_customer_relations = 'N' THEN
    OPEN  c_bill_to_site_use_id(l_bill_to_state);
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
      SELECT ORGANIZATION_ID
      INTO   l_bill_to_site_use_id
      FROM   OE_INVOICE_TO_ORGS_V
      WHERE  ADDRESS_LINE_1  = p_exposure_rec.bill_to_address1
         AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address2, fnd_api.g_miss_char)
         AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address3,fnd_api.g_miss_char)
         AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
           NVL( p_exposure_rec.bill_to_address4, fnd_api.g_miss_char)
         AND STATUS = 'A'
         AND CUSTOMER_ID = p_exposure_rec.bill_to_customer_id
	 and address_status='A'; --2752321
    END IF;

    CLOSE c_bill_to_site_use_id;
    RETURN l_bill_to_site_use_id;

  ELSIF l_customer_relations = 'Y' THEN
    OPEN  C1(l_bill_to_state);
    FETCH C1
    INTO  l_bill_to_site_use_id;

    IF C1%FOUND then
      OE_DEBUG_PUB.Add('Found', 5);
      -- Check for more than one site use
      FETCH C1
      INTO  l_bill_to_site_use_id2;
      IF C1%FOUND THEN
        RAISE TOO_MANY_ROWS;
      END IF;
      CLOSE  C1;
      RETURN l_bill_to_site_use_id;
    ELSE
      oe_debug_pub.add('not found', 5);
      --MOAC Changes
      /*select userenv('CLIENT_INFO') into l_org from dual;
      oe_debug_pub.add('org='||l_org, 5);*/
      --MOAC Changes
      SELECT /* MOAC_SQL_NO_CHANGE */ ORGANIZATION_ID
      INTO   l_bill_to_site_use_id
      FROM   OE_INVOICE_TO_ORGS_V
      WHERE  ADDRESS_LINE_1  = p_exposure_rec.bill_to_address1
         AND nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address2, fnd_api.g_miss_char)
         AND nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
           nvl( p_exposure_rec.bill_to_address3,fnd_api.g_miss_char)
         AND DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
           nvl( p_exposure_rec.bill_to_address4, fnd_api.g_miss_char)
         AND STATUS = 'A'
	 and address_status='A' --2752321
         AND CUSTOMER_ID IN
            (SELECT p_exposure_rec.bill_to_customer_id
             FROM   DUAL
             UNION
             SELECT CUST_ACCOUNT_ID
             FROM   HZ_CUST_ACCT_RELATE
             WHERE  RELATED_CUST_ACCOUNT_ID = p_exposure_rec.bill_to_customer_id
             AND    bill_to_flag = 'Y');
      oe_debug_pub.add('after select found='||l_bill_to_site_use_id);
    END IF;

    CLOSE C1;
    oe_debug_pub.add('returning from the function', 5);
    RETURN l_bill_to_site_use_id;
  ELSIF l_customer_relations = 'A' THEN
    OPEN C2(l_bill_to_state);
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
      WHERE  ADDRESS_LINE_1  = p_exposure_rec.bill_to_address1
      AND    nvl( ADDRESS_LINE_2, fnd_api.g_miss_char) =
             nvl( p_exposure_rec.bill_to_address2, fnd_api.g_miss_char)
      AND    nvl( ADDRESS_LINE_3, fnd_api.g_miss_char) =
             nvl( p_exposure_rec.bill_to_address3,fnd_api.g_miss_char)
      AND    DECODE(TOWN_OR_CITY,NULL,NULL,TOWN_OR_CITY||', ')||
               DECODE(STATE, NULL, NULL, STATE || ', ')||
               DECODE(POSTAL_CODE, NULL, NULL, POSTAL_CODE || ', ')||
               DECODE(COUNTRY, NULL, NULL, COUNTRY) =
             NVL( p_exposure_rec.bill_to_address4, fnd_api.g_miss_char)
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

      FND_MESSAGE.SET_NAME('ONT','OE_CC_IMP_BILL_TO_ADDR_INVALID');
      l_message_text := FND_MESSAGE.Get;
      OE_DEBUG_PUB.Add('Error: No valid address found', 5);
      Insert_To_Errors_Table(
         p_exposure_source_code    => p_exposure_rec.exposure_source_code
       , p_exposure_interface_id   => p_exposure_rec.exposure_interface_id
       , p_batch_id                => p_exposure_rec.batch_id
       , p_error_message_name      => 'OE_CC_IMP_BILL_TO_ADDR_INVALID'
       , p_error_message_text      => l_message_text
       );

      OE_DEBUG_PUB.Add('No data found error in Address_Value_To_ID', 5);
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

      FND_MESSAGE.SET_NAME('ONT','OE_CC_IMP_BILL_TO_ADDR_MULTI');
      l_message_text := FND_MESSAGE.Get;
      OE_DEBUG_PUB.Add('Error: Found multiple addresses', 5);
      Insert_To_Errors_Table(
         p_exposure_source_code    => p_exposure_rec.exposure_source_code
       , p_exposure_interface_id   => p_exposure_rec.exposure_interface_id
       , p_batch_id                => p_exposure_rec.batch_id
       , p_error_message_name      => 'OE_CC_IMP_BILL_TO_ADDR_MULTI'
       , p_error_message_text      => l_message_text
       );
      OE_DEBUG_PUB.Add('Too many rows error in Address_Value_To_ID', 5);

      RETURN FND_API.G_MISS_NUM;
    WHEN OTHERS THEN
      OE_DEBUG_PUB.Add('Unexpected error in Address_Value_To_ID', 5);
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
  ( p_exposure_rec               IN oe_exposure_interface%ROWTYPE
   ,x_return_status             OUT NOCOPY VARCHAR2
   ,x_bill_to_site_use_id       OUT NOCOPY NUMBER
   ,x_org_id                    OUT NOCOPY NUMBER
   ,x_bill_to_customer_id       OUT NOCOPY NUMBER
  )
IS
  l_bill_to_site_use_id NUMBER;
  l_bill_to_customer_id NUMBER;
  l_message_text        VARCHAR2(2000);
  l_exposure_rec        oe_exposure_interface%ROWTYPE;
BEGIN
  OE_DEBUG_PUB.Add('OEXVECEB: In Get_Bill_To_Site_Use_ID', 4);
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 /* Added the following line to fix the bug 6451056 */

      MO_GLOBAL.set_policy_context('S', p_exposure_rec.org_id);


  IF p_exposure_rec.bill_to_site_use_id IS NOT NULL THEN
    BEGIN
      --
      -- use the invoice_to_orgs_v
      --
      SELECT organization_id,
             customer_id
      INTO   l_bill_to_site_use_id,
             l_bill_to_customer_id
      FROM   oe_invoice_to_orgs_v
      WHERE  site_use_id=p_exposure_rec.bill_to_site_use_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- This same error message takes care of the case of NULL value
        -- passed in since a NULL in the select will not select any rows.
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('ONT', 'OE_CC_IMP_SITE_USE_ID_INVALID');
        FND_MESSAGE.Set_Token('COLUMN_NAME' , 'BILL_TO_SITE_USE_ID');
        FND_MESSAGE.Set_Token('COLUMN_VALUE', p_exposure_rec.bill_to_site_use_id);
        l_message_text := FND_MESSAGE.Get;
        OE_DEBUG_PUB.Add('Error: Bill-to site use ID invalid', 5);
        Insert_To_Errors_Table(
           p_exposure_source_code    => p_exposure_rec.exposure_source_code
         , p_exposure_interface_id   => p_exposure_rec.exposure_interface_id
         , p_batch_id                => p_exposure_rec.batch_id
         , p_error_message_name      => 'OE_CC_IMP_SITE_USE_ID_INVALID'
         , p_error_message_text      => l_message_text
         );
    END;
  ELSIF
    -- bill_to_site_use_id is NULL. Derive it from address and customer info.
    -- The location and customer information must be provided to derive a
    -- unique site use id.
    (p_exposure_rec.bill_to_address1     IS NOT NULL )
  THEN
    -- location information exists, now check for a valid customer.

    IF p_exposure_rec.bill_to_customer_id IS NOT NULL THEN
      l_bill_to_site_use_id := Address_Value_To_ID
        (
          p_exposure_rec => p_exposure_rec
        );
      l_bill_to_customer_id := p_exposure_rec.bill_to_customer_id;
      OE_DEBUG_PUB.Add('l_bill_to_site_use_id: '||l_bill_to_site_use_id, 5);
      OE_DEBUG_PUB.Add('l_bill_to_customer_id: '||l_bill_to_customer_id, 5);
      IF NVL(l_bill_to_site_use_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    ELSIF p_exposure_rec.bill_to_customer_name  IS NOT NULL AND
          p_exposure_rec.bill_to_customer_number IS NOT NULL THEN
      -- check for valid customer ID
     BEGIN
        SELECT hca.cust_account_id
        INTO   l_bill_to_customer_id
        FROM   hz_cust_accounts hca,
               hz_parties hp
        WHERE  hca.party_id = hp.party_id
        AND    hp.party_name = p_exposure_rec.bill_to_customer_name
        AND    hca.account_number = p_exposure_rec.bill_to_customer_number;
        --
        -- then get bill_to_site_use_id
        --
        l_exposure_rec := p_exposure_rec;
        l_exposure_rec.bill_to_customer_id := l_bill_to_customer_id;
        l_bill_to_site_use_id := Address_Value_To_ID
          (
           p_exposure_rec        => p_exposure_rec
          );

        OE_DEBUG_PUB.Add('l_bill_to_site_use_id: '||l_bill_to_site_use_id, 5);
        OE_DEBUG_PUB.Add('l_bill_to_customer_id: '||l_bill_to_customer_id, 5);
        IF NVL(l_bill_to_site_use_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('ONT', 'OE_CC_IMP_CUST_INFO_INVALID');
          FND_MESSAGE.SET_TOKEN ('CUSTOMER_NAME', 'BILL_TO_CUSTOMER_NAME' );
          FND_MESSAGE.SET_TOKEN ('CUSTOMER_NUMBER', 'BILL_TO_CUSTOMER_NUMBER' );
          l_message_text := FND_MESSAGE.Get;
          OE_DEBUG_PUB.Add('Error: Customer ID cannot be derived from customer name and number', 5);
          Insert_To_Errors_Table(
             p_exposure_source_code    => p_exposure_rec.exposure_source_code
           , p_exposure_interface_id   => p_exposure_rec.exposure_interface_id
           , p_batch_id                => p_exposure_rec.batch_id
           , p_error_message_name      => 'OE_CC_IMP_CUST_INFO_INVALID'
           , p_error_message_text      => l_message_text
           );
      END;
    ELSE
      -- customer information is missing
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('ONT', 'OE_CC_IMP_CUST_INFO_MISSING');
      FND_MESSAGE.SET_TOKEN ('CUSTOMER_NAME', 'BILL_TO_CUSTOMER_NAME' );
      FND_MESSAGE.SET_TOKEN ('CUSTOMER_NUMBER', 'BILL_TO_CUSTOMER_NUMBER' );
      FND_MESSAGE.SET_TOKEN ('CUSTOMER_ID', 'BILL_TO_CUSTOMER_ID');
      l_message_text := FND_MESSAGE.Get;
      OE_DEBUG_PUB.Add('Error: No customer information provided', 5);
      Insert_To_Errors_Table(
         p_exposure_source_code    => p_exposure_rec.exposure_source_code
       , p_exposure_interface_id   => p_exposure_rec.exposure_interface_id
       , p_batch_id                => p_exposure_rec.batch_id
       , p_error_message_name      => 'OE_CC_IMP_CUST_INFO_MISSING'
       , p_error_message_text      => l_message_text
       );

    END IF;
  ELSE
    -- insufficient information is provided to derive the invoice site use id.
    -- Either the bill_to site use ID needs to be provided or the bill-to address.
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('ONT', 'OE_CC_IMP_SITE_USE_INF_INVALID');
    l_message_text := FND_MESSAGE.Get;
    OE_DEBUG_PUB.Add('Error: Insufficient information provided to derive site use ID', 5);

    Insert_To_Errors_Table(
       p_exposure_source_code    => p_exposure_rec.exposure_source_code
     , p_exposure_interface_id   => p_exposure_rec.exposure_interface_id
     , p_batch_id                => p_exposure_rec.batch_id
     , p_error_message_name      => 'OE_CC_IMP_SITE_USE_INF_INVALID'
     , p_error_message_text      => l_message_text
     );

  END IF;

  x_bill_to_site_use_id := l_bill_to_site_use_id;
  x_bill_to_customer_id := l_bill_to_customer_id;
--  x_org_id              := G_org_id; -- MOAC
  x_org_id              := p_exposure_rec.org_id;

  OE_DEBUG_PUB.Add('OEXVECEB: Out Get_Bill_To_Site_Use_ID', 4);
EXCEPTION
  WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Bill_To_Site_Use_ID;

--=====================================================================
-- NAME: Validate_Exposure_Source
-- TYPE: PRIVATE PROCEDURE
-- DESCRIPTION: This procedure validate the exposure source within the
-- a batch.  It checks that
-- 1) the exposure source code is valid
-- 2) there is only one operation code per exposure source
-- 3) the operation code is either INSERT or UPDATE
--=====================================================================
PROCEDURE Validate_Exposure_Source
IS

  CURSOR c_exposure_source IS
    SELECT   distinct exposure_source_code
    FROM     oe_exposure_interface
    WHERE    request_id = G_request_id
    AND      import_status_code = G_PROCESSING;

  CURSOR c_multi_op_code
   (p_exposure_source_code oe_exposure_interface.exposure_source_code%TYPE) IS
    SELECT   COUNT(distinct operation_code)
    FROM     oe_exposure_interface
    WHERE    request_id = G_request_id
    AND      import_status_code = G_PROCESSING
    AND      exposure_source_code = p_exposure_source_code
    HAVING   COUNT(distinct operation_code) > 1;

  CURSOR c_invalid_op_code
   (p_exposure_source_code oe_exposure_interface.exposure_source_code%TYPE) IS
    SELECT   distinct operation_code
    FROM     oe_exposure_interface
    WHERE    request_id = G_request_id
    AND      import_status_code = G_PROCESSING
    AND      operation_code NOT IN ('INSERT', 'UPDATE');

  l_exposure_soure_code  oe_exposure_interface.exposure_source_code%TYPE;
  l_op_code_count        NUMBER := 0;
  l_operation_code       oe_exposure_interface.operation_code%TYPE;
  l_message_text         oe_exp_interface_errors.error_message%TYPE;
  l_source_valid         NUMBER;
  l_any_op_code_errors   BOOLEAN := FALSE;
BEGIN
  OE_DEBUG_PUB.Add('OEXVECEB: In  Validate_Exposure_Source ');
  --l_result_out := 'PASS';
  FOR l_row IN c_exposure_source LOOP
    --
    -- Check the exposure source code
    --
    BEGIN
      SELECT 1
      INTO   l_source_valid
      FROM   oe_lookups
      WHERE  lookup_type = 'EXTERNAL_EXPOSURE_SOURCE'
      AND    lookup_code = l_row.exposure_source_code
      AND    enabled_flag = 'Y'
      AND    NVL(start_date_active, TO_DATE('01/01/1000','DD/MM/YYYY'))
             <= TRUNC(SYSDATE)
      AND    NVL(end_date_active, TO_DATE('31/12/9999','DD/MM/YYYY'))
             >= TRUNC(SYSDATE) ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- exposure source code is not valid
        FND_MESSAGE.Set_Name('ONT', 'OE_CC_IMP_SOURCE_INVALID');
        FND_MESSAGE.Set_Token ('COLUMN_NAME','EXPOSURE_SOURCE_CODE');
        FND_MESSAGE.Set_Token ('COLUMN_VALUE', l_row.exposure_source_code);
        l_message_text := FND_MESSAGE.Get;
        OE_DEBUG_PUB.Add('Error: Exposure source code is not valid', 2);
        Insert_To_Errors_Table(
            p_exposure_source_code    => l_row.exposure_source_code
          , p_exposure_interface_id   => NULL
          , p_batch_id                => NULL
          , p_error_message_name      => 'OE_CC_IMP_SOURCE_INVALID'
          , p_error_message_text      => l_message_text
          );
        UPDATE oe_exposure_interface
        SET    import_status_code = G_ERROR
        WHERE  exposure_source_code = l_row.exposure_source_code
        AND    request_id           = G_request_id;

        COMMIT;
    END;
    --
    -- Check source for multiple operation code
    --
    OPEN c_multi_op_code(l_row.exposure_source_code);
    FETCH c_multi_op_code INTO l_op_code_count;

    IF c_multi_op_code%FOUND THEN
      OE_DEBUG_PUB.Add('Exposure source code '||l_row.exposure_source_code||
                        ' contains multiple operation codes', 2);
      -- write message to errors table
      l_any_op_code_errors := TRUE;
      FND_MESSAGE.Set_Name('ONT', 'OE_CC_IMP_OP_CODE_MULTIPLE');
      l_message_text := FND_MESSAGE.Get;
      OE_DEBUG_PUB.Add('Error: Exposure source contains multiple operation codes', 2);
    ELSE
      OE_DEBUG_PUB.Add('Exposure source code '||l_row.exposure_source_code||
                       ' contains 1 operation code', 2);
      -- check for invalid operation code
      OPEN c_invalid_op_code(l_row.exposure_source_code);
      FETCH c_invalid_op_code INTO l_operation_code;
      IF c_invalid_op_code%FOUND THEN
        l_any_op_code_errors := TRUE;
        OE_DEBUG_PUB.Add('Exposure source code '||l_row.exposure_source_code||
                         ' contains an invalid operation code', 2);
        -- write message to errors table
        FND_MESSAGE.Set_Name('ONT', 'OE_CC_IMP_OP_CODE_MULTIPLE');
        l_message_text := FND_MESSAGE.Get;
      END IF;
      CLOSE c_invalid_op_code;
    END IF;
    CLOSE c_multi_op_code;

    IF l_any_op_code_errors THEN
      --
      -- Insert message to errors table
      --
      Insert_To_Errors_Table(
          p_exposure_source_code    => l_row.exposure_source_code
        , p_exposure_interface_id   => NULL
        , p_batch_id                => NULL
        , p_error_message_name      => 'OE_CC_IMP_OP_CODE_MULTIPLE'
        , p_error_message_text      => l_message_text
        );
      --
      -- update import_status_code if errors found
      --
      UPDATE oe_exposure_interface
      SET    import_status_code   = G_ERROR
      WHERE  exposure_source_code = l_row.exposure_source_code
      AND    request_id           = G_request_id;

      COMMIT;
    END IF;
  END LOOP;  -- end of check of exposure source codes
  OE_DEBUG_PUB.Add('OEXVECEB: Out Validate_Exposure_Source ');
EXCEPTION
  WHEN OTHERS THEN
    IF c_multi_op_code%ISOPEN THEN
      CLOSE c_multi_op_code;
    END IF;
    IF c_invalid_op_code%ISOPEN THEN
      CLOSE c_invalid_op_code;
    END IF;
    IF c_exposure_source%ISOPEN THEN
      CLOSE c_exposure_source;
    END IF;
    OE_DEBUG_PUB.Add('Validate_Exposure_Source -- Unexpected Error');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Exposure_Source;

--=====================================================================
--NAME:         Validate_Exposure
--TYPE:         PRIVATE
--DESCRIPTION:  This procedure validate the exposure rows in the interface
--              table and derive the IDs use for loading the exposure info
--              into OM.
--Parameters:
--IN
--OUT
--=====================================================================
PROCEDURE Validate_Exposure
IS
  CURSOR c_rows_to_process IS
    SELECT *
    FROM   oe_exposure_interface
    WHERE  request_id = G_request_id
    AND    import_status_code   = G_PROCESSING;

  l_bill_to_site_use_id  NUMBER;
  l_bill_to_customer_id  NUMBER;
  l_commit_count NUMBER := 0;
  l_any_errors   BOOLEAN := FALSE;
  l_return_status        VARCHAR2(30);
  l_org_id               NUMBER;
  l_result_out           VARCHAR2(30);
BEGIN
  OE_DEBUG_PUB.Add('OEXVECEB: In Validate_Exposure');
  --
  -- Validate Operation Code. Should be the same within a given exposure source
  --
  Validate_Exposure_Source;

    -- Fetch each row and validate
    FOR l_exposure_rec IN c_rows_to_process LOOP
      --
      -- Validate each row
      --
      OE_DEBUG_PUB.Add('Validating interface ID: '||
                        l_exposure_rec.exposure_interface_id, 4);
      l_bill_to_site_use_id := l_exposure_rec.bill_to_site_use_id;

      -- Validate currency code
      IF NOT Is_Currency_Valid(p_exposure_rec => l_exposure_rec)
      THEN
        IF NOT l_any_errors THEN
           l_any_errors := TRUE;
        END IF;
        OE_DEBUG_PUB.Add('Validate Currency Failed.', 5);
      END IF;

      --
      -- Derive the bill-to site use ID, the customer ID, and the org ID
      -- The org ID is derived from the bill-to site use ID.
      -- The customer ID is either given or derived from customer name and
      -- customer number.
      --
      Get_Bill_To_Site_Use_ID
       ( p_exposure_rec               => l_exposure_rec
        ,x_return_status              => l_return_status
        ,x_bill_to_site_use_id        => l_bill_to_site_use_id
        ,x_bill_to_customer_id        => l_bill_to_customer_id
        ,x_org_id                     => l_org_id
       );

      OE_DEBUG_PUB.Add('l_bill_to_site_use_id: '||l_bill_to_site_use_id, 5);
      OE_DEBUG_PUB.Add('l_bill_to_customer_id: '||l_bill_to_customer_id, 5);
      OE_DEBUG_PUB.Add('l_org_id             : '||l_org_id, 5);
      OE_DEBUG_PUB.Add('l_return_status      : '||l_return_status, 5);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        IF NOT l_any_errors THEN
           l_any_errors := TRUE;
        END IF;
        OE_DEBUG_PUB.Add('Validate Bill-To Site Use Failed.', 5);
      END IF;

      IF l_any_errors THEN
        OE_DEBUG_PUB.Add('Validation Errors Found', 5);
        UPDATE oe_exposure_interface
        SET    import_status_code = G_ERROR
        WHERE  exposure_interface_id  = l_exposure_rec.exposure_interface_id;
      ELSE
        -- Update status code and IDs and Who Columns
        OE_DEBUG_PUB.Add(
          'No Validation Errors Found. Updating the interface table...', 5);
        UPDATE oe_exposure_interface
        SET    import_status_code     = G_VALIDATED,
               bill_to_site_use_id    = l_bill_to_site_use_id,
               bill_to_customer_id    = l_bill_to_customer_id,
               last_update_login      = G_login_id,
               program_application_id = G_appl_id,
               program_id             = G_program_id,
               program_update_date    = TRUNC(sysdate),
--               org_id                 = G_org_id -- MOAC
               org_id                 = l_org_id
        WHERE  exposure_interface_id  = l_exposure_rec.exposure_interface_id;
      END IF;
      l_commit_count := l_commit_count + 1;
      IF l_commit_count >= G_COMMIT_SIZE THEN
        COMMIT;
      END IF;
    END LOOP;
--  END IF;  -- validation
  OE_DEBUG_PUB.Add('OEXVECEB: Out Validate_Exposure');
EXCEPTION
  WHEN  FND_API.G_EXC_ERROR THEN
    OE_DEBUG_PUB.Add('OEXVECEB: Validate_Exposure -- Expected Error', 2);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    OE_DEBUG_PUB.Add('OEXVECEB: Validate_Exposure -- Unexpected Error', 2);
    RAISE;
  WHEN OTHERS THEN
    IF c_rows_to_process%ISOPEN THEN
      CLOSE c_rows_to_process;
    END IF;
    OE_DEBUG_PUB.Add('OEXVECEB: Validate_Exposure -- Other Unexpected Error', 2);
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg (
          G_PKG_NAME
        , 'Validate_Exposure');
    END IF;
    RAISE;
END Validate_Exposure;

--=====================================================================
--NAME:         Insert_Exposure
--TYPE:         PRIVATE
--DESCRIPTION:  This procedure delete/insert row into OE_CREDIT_SUMMARIES
--              table.
--Parameters:
--IN
--OUT
--=====================================================================
PROCEDURE Insert_Exposure
  ( p_exposure_rec              IN  oe_exposure_interface%ROWTYPE
  )
IS
  CURSOR c_summary_row IS
    SELECT rowid
    FROM   oe_credit_summaries
    WHERE  cust_account_id = p_exposure_rec.bill_to_customer_id
    AND    org_id          = p_exposure_rec.org_id
    AND    site_use_id     = p_exposure_rec.bill_to_site_use_id
    AND    currency_code   = p_exposure_rec.currency_code
    AND    exposure_source_code = p_exposure_rec.exposure_source_code
    AND    balance_type    = 18;

  l_row_id VARCHAR2(30);
BEGIN
  OE_DEBUG_PUB.Add('OEXVECEB: In  Insert_Exposure', 4);
  OPEN c_summary_row;
  FETCH c_summary_row INTO l_row_id;

  IF c_summary_row%FOUND THEN
    -- Delete any rows first, then insert.
    OE_DEBUG_PUB.Add('Row exist. Delete existing row', 5);
    oe_credit_summaries_pkg.Delete_Row(
        p_row_id           => l_row_id
      );
  END IF;

  IF p_exposure_rec.exposure_amount <> 0 THEN
    -- Insert row only if amount <> 0
    OE_DEBUG_PUB.Add('Insert the new exposure row', 5);
    oe_credit_summaries_pkg.insert_row(
        p_cust_account_id            => p_exposure_rec.bill_to_customer_id
      , p_org_id                     => p_exposure_rec.org_id
      , p_site_use_id                => p_exposure_rec.bill_to_site_use_id
      , p_currency_code              => p_exposure_rec.currency_code
      , p_balance_type               => 18
      , p_balance                    => p_exposure_rec.exposure_amount
      , p_creation_date              => p_exposure_rec.creation_date
      , p_created_by                 => p_exposure_rec.created_by
      , p_last_update_date           => p_exposure_rec.last_update_date
      , p_last_updated_by            => p_exposure_rec.last_updated_by
      , p_last_update_login          => p_exposure_rec.last_update_login
      , p_program_application_id     => p_exposure_rec.program_application_id
      , p_program_id                 => p_exposure_rec.program_id
      , p_program_update_date        => p_exposure_rec.program_update_date
      , p_request_id                 => p_exposure_rec.request_id
      , p_exposure_source_code       => p_exposure_rec.exposure_source_code
      );
  END IF;
  CLOSE c_summary_row;
  OE_DEBUG_PUB.Add('OEXVECEB: Out Insert_Exposure', 4);
EXCEPTION
  WHEN OTHERS THEN
    IF c_summary_row%ISOPEN THEN
      CLOSE c_summary_row;
    END IF;
    RAISE;
END Insert_Exposure;

--=====================================================================
--NAME:         Update_Exposure
--TYPE:         PRIVATE
--DESCRIPTION:  This procedure insert/update row into OE_CREDIT_SUMMARIES
--              table.
--Parameters:
--IN
--OUT
--=====================================================================
PROCEDURE Update_Exposure
  ( p_exposure_rec              IN  oe_exposure_interface%ROWTYPE
  )
IS
  CURSOR c_summary_exposure IS
    SELECT rowid, balance
    FROM   oe_credit_summaries
    WHERE  cust_account_id = p_exposure_rec.bill_to_customer_id
    AND    org_id          = p_exposure_rec.org_id
    AND    site_use_id     = p_exposure_rec.bill_to_site_use_id
    AND    currency_code   = p_exposure_rec.currency_code
    AND    exposure_source_code = p_exposure_rec.exposure_source_code
    AND    balance_type    = 18;

    l_row_id  VARCHAR2(30);
    l_balance NUMBER;
BEGIN
  OE_DEBUG_PUB.Add('OEXVECEB: In  Update_Exposure', 4);
  -- Check if exposure exist in the summary table
  OPEN c_summary_exposure;
  FETCH c_summary_exposure INTO l_row_id, l_balance;

  IF p_exposure_rec.exposure_amount <> 0 THEN
    IF c_summary_exposure%FOUND THEN
      OE_DEBUG_PUB.Add('Updating exposure row', 5);
      oe_credit_summaries_pkg.Update_Row(
          p_row_id                     => l_row_id
        , p_balance                    => p_exposure_rec.exposure_amount + l_balance
        , p_last_update_date           => p_exposure_rec.last_update_date
        , p_last_updated_by            => p_exposure_rec.last_updated_by
        , p_last_update_login          => p_exposure_rec.last_update_login
        , p_program_application_id     => p_exposure_rec.program_application_id
        , p_program_id                 => p_exposure_rec.program_id
        , p_program_update_date        => p_exposure_rec.program_update_date
        , p_request_id                 => p_exposure_rec.request_id
        );
    ELSE
      OE_DEBUG_PUB.Add('Inserting exposure row', 5);
      oe_credit_summaries_pkg.Insert_Row(
          p_cust_account_id            => p_exposure_rec.bill_to_customer_id
        , p_org_id                     => p_exposure_rec.org_id
        , p_site_use_id                => p_exposure_rec.bill_to_site_use_id
        , p_currency_code              => p_exposure_rec.currency_code
        , p_balance_type               => 18
        , p_balance                    => p_exposure_rec.exposure_amount
        , p_creation_date              => p_exposure_rec.creation_date
        , p_created_by                 => p_exposure_rec.created_by
        , p_last_update_date           => p_exposure_rec.last_update_date
        , p_last_updated_by            => p_exposure_rec.last_updated_by
        , p_last_update_login          => p_exposure_rec.last_update_login
        , p_program_application_id     => p_exposure_rec.program_application_id
        , p_program_id                 => p_exposure_rec.program_id
        , p_program_update_date        => p_exposure_rec.program_update_date
        , p_request_id                 => p_exposure_rec.request_id
        , p_exposure_source_code       => p_exposure_rec.exposure_source_code
        );
    END IF;
  END IF;
  CLOSE c_summary_exposure;
  OE_DEBUG_PUB.Add('OEXVECEB: Out Update_Exposure', 4);
EXCEPTION
  WHEN OTHERS THEN
    IF c_summary_exposure%ISOPEN THEN
      CLOSE c_summary_exposure;
    END IF;
    RAISE;
END Update_Exposure;

--=====================================================================
--NAME:         Import_Exposure
--TYPE:         PRIVATE
--DESCRIPTION:  This procedure load the exposure rows in the interface
--              table into the OM credit summary table.
--Parameters:
--IN
--OUT
--=====================================================================
PROCEDURE Import_Exposure
IS
  CURSOR c_valid_exposures IS
    SELECT *
    FROM   oe_exposure_interface
    WHERE  request_id = G_request_id
    AND    import_status_code   = G_VALIDATED
    ORDER BY exposure_source_code;

  l_commitsize_count            NUMBER := 0;
BEGIN
  OE_DEBUG_PUB.Add('OEXVECEB: In Import_Exposure');
  FOR l_exposure_rec IN c_valid_exposures LOOP
    IF l_exposure_rec.operation_code = 'INSERT' THEN
      Insert_Exposure(l_exposure_rec);
    ELSE
      Update_Exposure(l_exposure_rec);
    END IF;

    --
    -- Set status to complete after updating/inserting
    --
    UPDATE oe_exposure_interface
    SET    import_status_code = 'COMPLETE'
    WHERE  exposure_interface_id = l_exposure_rec.exposure_interface_id;

    l_commitsize_count := l_commitsize_count + 1;
    IF l_commitsize_count >= G_COMMIT_SIZE THEN
      COMMIT;
      l_commitsize_count := 0;
    END IF;
  END LOOP;
  COMMIT;
  OE_DEBUG_PUB.Add('OEXVECEB: Out Import_Exposure');
EXCEPTION
  WHEN OTHERS THEN
    OE_DEBUG_PUB.Add('OEXECEB: Import_Exposure -- Unexpected Error');
    RAISE;
END Import_Exposure;

--=====================================================================
--API NAME:     Import_Credit_Exposure
--TYPE:         PRIVATE
--DESCRIPTION:  This procedure validate the exposure rows in the interface
--              table and load them into the OM credit summary table when
--              appropriate.
--Parameters:
--IN
--OUT
--Version:  	Current Version   	1.0
--              Previous Version  	1.0
--=====================================================================
PROCEDURE Import_Credit_Exposure
  ( p_api_version                IN  NUMBER
  , p_org_id                     IN  NUMBER
  , p_exposure_source_code       IN  VARCHAR2
  , p_batch_id                   IN  NUMBER
  , p_validate_only              IN  VARCHAR2
  , x_num_rows_to_process        OUT NOCOPY NUMBER
  , x_num_rows_validated         OUT NOCOPY NUMBER
  , x_num_rows_failed            OUT NOCOPY NUMBER
  , x_num_rows_imported          OUT NOCOPY NUMBER
  )
IS
  l_api_name 	CONSTANT VARCHAR2(30) := 'Import Credit Exposure';
  l_api_version	CONSTANT NUMBER       := 1.0;
  l_any_errors           BOOLEAN      := FALSE;
  l_org_id               NUMBER;
  l_return_status        VARCHAR2(30);

  l_num_rows_to_process  NUMBER := 0;
  l_num_rows_failed      NUMBER := 0;
  l_num_rows_imported    NUMBER := 0;
  l_num_rows_validated   NUMBER := 0;
  l_validated            BOOLEAN := FALSE;
  l_commit_count         NUMBER := 0;
  l_message_text         VARCHAR2(2000);

-- MOAC start
CURSOR l_secured_ou_cur IS
  SELECT ou.organization_id
    FROM hr_operating_units ou
   WHERE mo_global.check_access(ou.organization_id) = 'Y';

l_debug_level    CONSTANT NUMBER := oe_debug_pub.g_debug_level;
-- MOAC end

BEGIN
  IF l_debug_level  > 0 THEN
     OE_DEBUG_PUB.Add('OEXVECEB: In Import_Credit_Exposure');
  END IF;
  --
  -- Show input parameters
  --
  OE_DEBUG_PUB.Add('***** Input Parameters*****');
  OE_DEBUG_PUB.Add('p_api_version:           '||p_api_version);
  OE_DEBUG_PUB.Add('p_org_id:                '||p_org_id);
  OE_DEBUG_PUB.Add('p_exposure_source_code:  '||p_exposure_source_code);
  OE_DEBUG_PUB.Add('p_batch_id:              '||p_batch_id);
  OE_DEBUG_PUB.Add('p_validate_only:         '||p_validate_only);
  --
  -- Check the version and issue an error if the given version does not
  -- match the one in this package.
  --
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
    OE_DEBUG_PUB.Add('l_api_version: '||l_api_version);
    OE_DEBUG_PUB.Add('p_api_version: '||p_api_version);
    OE_DEBUG_PUB.Add('API Version Check Failed.');
    l_message_text := FND_MESSAGE.GET;
    OE_DEBUG_PUB.Add('message text: '||SUBSTRB(l_message_text, 1, 200));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- MOAC start
  l_org_id := p_org_id;

  IF l_org_id IS NOT NULL THEN
     MO_GLOBAL.set_policy_context('S', l_org_id);

     UPDATE oe_exposure_interface
        SET exposure_interface_id = OE_EXPOSURE_INTERFACE_S.NextVal,
            import_status_code    = G_PROCESSING,
            request_id            = G_request_id
      WHERE exposure_source_code  = NVL(p_exposure_source_code, exposure_source_code)
        AND NVL(batch_id, -99)    = NVL(p_batch_id, NVL(batch_id,-99))
        AND NVL(org_id, -99)      = NVL(l_org_id, -99)
        AND import_status_code IS NULL;

     IF l_debug_level  > 0 THEN
        OE_DEBUG_PUB.Add('org_id    : ' || l_org_id);
        OE_DEBUG_PUB.Add(TO_CHAR(SQL%ROWCOUNT)||' rows updated');
     END IF;
  ELSE
     OPEN l_secured_ou_cur;

     LOOP
       FETCH l_secured_ou_cur
        into l_org_id;
       EXIT WHEN l_secured_ou_cur%NOTFOUND;

       IF l_org_id IS NULL THEN
          l_org_id :=  mo_global.get_current_org_id;
       END IF;

       MO_GLOBAL.set_policy_context('S', l_org_id);

       UPDATE oe_exposure_interface
          SET exposure_interface_id = OE_EXPOSURE_INTERFACE_S.NextVal,
              import_status_code    = G_PROCESSING,
              request_id            = G_request_id
        WHERE exposure_source_code  = NVL(p_exposure_source_code, exposure_source_code)
          AND NVL(batch_id, -99)    = NVL(p_batch_id, NVL(batch_id,-99))
          AND NVL(org_id, -99)      = NVL(l_org_id, -99)
          AND import_status_code IS NULL;

       IF l_debug_level  > 0 THEN
          OE_DEBUG_PUB.Add('org_id    : ' || l_org_id);
          OE_DEBUG_PUB.Add(TO_CHAR(SQL%ROWCOUNT)||' rows updated');
       END IF;
     END LOOP;

     CLOSE l_secured_ou_cur;
   END IF;
-- MOAC End

  --
  -- Select exposure rows for processing and assign an exposure_interface_id
  --
--  UPDATE oe_exposure_interface
--  SET    exposure_interface_id = OE_EXPOSURE_INTERFACE_S.NextVal,
--         import_status_code    = G_PROCESSING,
--         request_id            = G_request_id
--  WHERE  exposure_source_code = NVL(p_exposure_source_code, exposure_source_code)
--  AND    NVL(batch_id, -99)   = NVL(p_batch_id, NVL(batch_id,-99))
--  AND    import_status_code IS NULL;

  OE_DEBUG_PUB.Add('Selected rows for processing',2);

  --
  -- Count the number of rows selected for processing
  --
  SELECT count(1)
  INTO   l_num_rows_to_process
  FROM   oe_exposure_interface
  WHERE  request_id           = G_request_id
  AND    import_status_code   = G_PROCESSING;

  --
  -- Delete any existing error messages for the selected exposure source and batch
  --
  DELETE FROM oe_exp_interface_errors
  WHERE  exposure_source_code = NVL(p_exposure_source_code, exposure_source_code)
  AND    NVL(batch_id, -99)   = NVL(p_batch_id, NVL(batch_id,-99));

  --
  -- Call Validate_Exposure to validate the exposure rows in the
  -- interface table and derive the necessary IDs use for loading
  -- the exposure data into the summary table.
  --
  Validate_Exposure;

  --
  -- Determine if all rows passed validation.  If so, then set the
  -- l_validated to TRUE.
  --
  SELECT count(1)
  INTO   l_num_rows_validated
  FROM   oe_exposure_interface
  WHERE  request_id           = G_request_id
  AND    import_status_code   = G_VALIDATED;

  --
  -- Set the validated flag to TRUE when all rows for the batch are validated.
  -- else get the number of rows that failed validation.
  --
  -- on second thought, why need to do this if we don't really perform a all
  -- or nothing approach since we commit every batchsize.
  --
  IF l_num_rows_validated < l_num_rows_to_process THEN
    SELECT count(1)
    INTO   l_num_rows_failed
    FROM   oe_exposure_interface
    WHERE  request_id           = G_request_id
    AND    import_status_code   = G_ERROR;
  END IF;

  IF p_validate_only = 'Y' THEN
    -- bug 234505. Reset the import_status_code to NULL
    -- since only status of NULL records will be selected
    -- for processing in next import run.
    UPDATE oe_exposure_interface
    SET    import_status_code = NULL
    WHERE  request_id           = G_request_id
    AND    import_status_code   = G_VALIDATED;

  ELSE
    -- Load the credit exposure into the summary table
    Import_Exposure;
    --
    -- Count the number of exposure rows loaded. Default is 0.
    --
    SELECT count(1)
    INTO   l_num_rows_imported
    FROM   oe_exposure_interface
    WHERE  request_id           = G_request_id
    AND    import_status_code   = G_COMPLETE;

    --
    -- Delete exposure from the interface table after they are imported.
    --
    DELETE
    FROM   oe_exposure_interface
    WHERE  request_id           = G_request_id
    AND    import_status_code   = G_COMPLETE;
  END IF;
  --
  -- Set the values for the output variables
  --
  x_num_rows_to_process  := l_num_rows_to_process;
  x_num_rows_validated   := l_num_rows_validated;
  x_num_rows_failed      := l_num_rows_failed;
  x_num_rows_imported    := l_num_rows_imported;

  OE_DEBUG_PUB.Add('***** Output Parameters *****');
  OE_DEBUG_PUB.Add('x_num_rows_to_process = '||x_num_rows_to_process);
  OE_DEBUG_PUB.Add('x_num_rows_validated  = '||x_num_rows_validated);
  OE_DEBUG_PUB.Add('x_num_rows_failed     = '||x_num_rows_failed);
  OE_DEBUG_PUB.Add('x_num_rows_imported   = '||x_num_rows_imported);
  OE_DEBUG_PUB.Add('*****************************');

  COMMIT;

  OE_DEBUG_PUB.Add('OEXVECEB: Out Import_Credit_Exposure');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    OE_DEBUG_PUB.ADD('OEXVECEB: Import_Credit_Exposure - Expected Error',1);
    OE_DEBUG_PUB.ADD('EXCEPTION: '||SUBSTR(sqlerrm,1,200),1);
    ROLLBACK;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    OE_DEBUG_PUB.ADD('OEXVECEB: Import_Credit_Exposure - Unexpected Error',1);
    OE_DEBUG_PUB.ADD('EXCEPTION: '||SUBSTR(sqlerrm,1,200),1);
    ROLLBACK;
    RAISE;
  WHEN OTHERS THEN
    OE_DEBUG_PUB.ADD('OEXVECEB: Import_Credit_Exposure - Unexpected Other Error',1);
    OE_DEBUG_PUB.ADD('EXCEPTION: '||SUBSTR(sqlerrm,1,200),1);
    ROLLBACK;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Import_Credit_Exposure');
    END IF;
    RAISE;
END Import_Credit_Exposure;

--=====================================================================
--NAME:         Purge
--TYPE:         PRIVATE
--DESCRIPTION:  This procedure delete external exposure from the summary
--              table.
--Parameters:
--IN
--OUT
--=====================================================================
PROCEDURE Purge
  ( p_org_id                  IN  NUMBER
  , p_exposure_source_code    IN  VARCHAR2
  )
IS
CURSOR l_secured_ou_cur IS
    SELECT ou.organization_id
      FROM hr_operating_units ou
     WHERE mo_global.check_access(ou.organization_id) = 'Y';

l_org_id                  NUMBER;
l_debug_level    CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
-- MOAC Start
  l_org_id := p_org_id;

  IF l_debug_level  > 0 THEN
     OE_DEBUG_PUB.Add('OEXVECEB: In  Purge');
  END IF;

  IF l_org_id IS NOT NULL THEN
     MO_GLOBAL.set_policy_context('S', l_org_id);

     DELETE FROM oe_credit_summaries
      WHERE exposure_source_code = NVL(p_exposure_source_code, exposure_source_code)
        AND balance_type         = 18
        AND NVL(org_id, -99)     = NVL(l_org_id, -99);

     IF l_debug_level  > 0 THEN
        OE_DEBUG_PUB.Add('org_id    : ' || l_org_id);
        OE_DEBUG_PUB.Add(TO_CHAR(SQL%ROWCOUNT)||' rows purged');
     END IF;
  ELSE
     OPEN l_secured_ou_cur;

     LOOP
       FETCH l_secured_ou_cur
        into l_org_id;
       EXIT WHEN l_secured_ou_cur%NOTFOUND;

       IF l_org_id IS NULL THEN
          l_org_id :=  mo_global.get_current_org_id;
       END IF;

       MO_GLOBAL.set_policy_context('S', l_org_id);

       DELETE FROM oe_credit_summaries
        WHERE exposure_source_code = NVL(p_exposure_source_code, exposure_source_code)
          AND balance_type         = 18
          AND NVL(org_id, -99)     = NVL(l_org_id, -99);

       IF l_debug_level  > 0 THEN
          OE_DEBUG_PUB.Add('org_id    : ' || l_org_id);
          OE_DEBUG_PUB.Add(TO_CHAR(SQL%ROWCOUNT)||' rows purged');
       END IF;
     END LOOP;

     CLOSE l_secured_ou_cur;

   END IF;
-- MOAC End

   IF l_debug_level  > 0 THEN
      OE_DEBUG_PUB.Add('OEXVECEB: Out Purge');
   END IF;

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF l_debug_level  > 0 THEN
       OE_DEBUG_PUB.ADD('OEXVECEB: Purge - Unexpected Error');
       OE_DEBUG_PUB.ADD('EXCEPTION: '||SUBSTR(sqlerrm,1,200));
    END IF;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Purge');
    END IF;
    RAISE;
END Purge;
END OE_EXT_CREDIT_EXPOSURE_PVT;

/
