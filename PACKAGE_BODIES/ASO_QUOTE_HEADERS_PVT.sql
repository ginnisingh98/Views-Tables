--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_HEADERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_HEADERS_PVT" as
/* $Header: asovqhdb.pls 120.45.12010000.63 2016/10/10 11:01:29 akushwah ship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_HEADERS_PVT
-- Purpose         :
-- History         :
--			    10/18/2002 hyang - 2633507, performance fix
--			    12/06/2002 hyang - 2686076, changed definition of lx_contract_number
--							   to VARCHAR2(120)
--                 08/19/04  skulkarn - In new BC4J implementation, the primary key for
--                                    for all input parameters in Create_Quote, Update_Quote APIs
--                                    will be passed. In order to honor the primary key passed
--                                    the primary key will not be set to null before calling the
--                                    table handler. Hence, commented OUT the code where
--                                    primary key is being set to null before calling table handler.
-- NOTE       :
-- End of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'ASO_QUOTE_HEADERS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovqhdb.pls';

G_QUOTE_DURATION  CONSTANT NUMBER := 30;


FUNCTION  Shipment_Rec_Exists( p_shipment_rec IN  ASO_QUOTE_PUB.Shipment_Rec_Type ) RETURN BOOLEAN
IS

BEGIN
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Begin Shipment_Rec_Exists function.', 1, 'Y');
	END IF;

     IF ( p_shipment_rec.SHIPMENT_ID             <> FND_API.G_MISS_NUM   OR
          p_shipment_rec.PROMISE_DATE            <> FND_API.G_MISS_DATE  OR
          p_shipment_rec.REQUEST_DATE            <> FND_API.G_MISS_DATE  OR
          p_shipment_rec.SCHEDULE_SHIP_DATE      <> FND_API.G_MISS_DATE  OR
          p_shipment_rec.SHIP_TO_PARTY_SITE_ID   <> FND_API.G_MISS_NUM   OR
          p_shipment_rec.SHIP_TO_PARTY_ID        <> FND_API.G_MISS_NUM   OR
          p_shipment_rec.SHIP_PARTIAL_FLAG       <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.SHIP_SET_ID             <> FND_API.G_MISS_NUM   OR
          p_shipment_rec.SHIP_METHOD_CODE        <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.FREIGHT_TERMS_CODE      <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.FREIGHT_CARRIER_CODE    <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.FOB_CODE                <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.SHIPPING_INSTRUCTIONS   <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.PACKING_INSTRUCTIONS    <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.QUANTITY                <> FND_API.G_MISS_NUM   OR
          p_shipment_rec.RESERVED_QUANTITY       <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.RESERVATION_ID          <> FND_API.G_MISS_NUM   OR
          p_shipment_rec.ORDER_LINE_ID           <> FND_API.G_MISS_NUM   OR
          p_shipment_rec.ATTRIBUTE_CATEGORY      <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE1              <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE2              <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE3              <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE4              <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE5              <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE6              <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE7              <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE8              <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE9              <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE10             <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE11             <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE12             <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE13             <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE14             <> FND_API.G_MISS_CHAR  OR
          p_shipment_rec.ATTRIBUTE15             <> FND_API.G_MISS_CHAR  OR
	     p_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID <> FND_API.G_MISS_NUM   OR
	     p_shipment_rec.SHIP_FROM_ORG_ID        <> FND_API.G_MISS_NUM   OR
		p_shipment_rec.ship_to_cust_party_id   <> FND_API.G_MISS_NUM) THEN

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
		    aso_debug_pub.add('Shipment_Rec_Exists function returning TRUE');
		    END IF;

              return TRUE;

     ELSE

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
		    aso_debug_pub.add('Shipment_Rec_Exists function returning FALSE');
		    END IF;

	         return FALSE;

     END IF;

END Shipment_Rec_Exists;

-- hyang defaulting framework
FUNCTION  Shipment_Null_Rec_Exists(
  p_shipment_rec          IN  ASO_QUOTE_PUB.Shipment_Rec_Type,
  p_database_object_name  IN VARCHAR2
) RETURN BOOLEAN
IS

BEGIN
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Begin Shipment_Null_Rec_Exists function.', 1, 'Y');
  END IF;

  IF (
      (
        p_database_object_name = 'ASO_AK_QUOTE_HEADER_V'
        AND (
          p_shipment_rec.SHIP_TO_PARTY_SITE_ID        IS NOT NULL OR
          p_shipment_rec.SHIP_TO_PARTY_ID             IS NOT NULL OR
          p_shipment_rec.SHIP_TO_CUST_PARTY_ID        IS NOT NULL OR
          p_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID      IS NOT NULL OR
          p_shipment_rec.REQUEST_DATE_TYPE            IS NOT NULL OR
          p_shipment_rec.REQUEST_DATE                 IS NOT NULL OR
          p_shipment_rec.SHIP_METHOD_CODE             IS NOT NULL OR
          p_shipment_rec.SHIPMENT_PRIORITY_CODE       IS NOT NULL OR
          p_shipment_rec.FREIGHT_TERMS_CODE           IS NOT NULL OR
          p_shipment_rec.FOB_CODE                     IS NOT NULL OR
          p_shipment_rec.SHIPPING_INSTRUCTIONS        IS NOT NULL OR
          p_shipment_rec.PACKING_INSTRUCTIONS         IS NOT NULL OR
          p_shipment_rec.DEMAND_CLASS_CODE            IS NOT NULL
        )
      ) OR (
        p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V'
        AND (
          p_shipment_rec.SHIP_TO_PARTY_SITE_ID        IS NOT NULL OR
          p_shipment_rec.SHIP_TO_PARTY_ID             IS NOT NULL OR
          p_shipment_rec.SHIP_TO_CUST_PARTY_ID        IS NOT NULL OR
          p_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID      IS NOT NULL OR
          p_shipment_rec.REQUEST_DATE_TYPE            IS NOT NULL OR
          p_shipment_rec.REQUEST_DATE                 IS NOT NULL OR
          p_shipment_rec.SHIP_METHOD_CODE             IS NOT NULL OR
          p_shipment_rec.SHIPMENT_PRIORITY_CODE       IS NOT NULL OR
          p_shipment_rec.FREIGHT_TERMS_CODE           IS NOT NULL OR
          p_shipment_rec.FOB_CODE                     IS NOT NULL OR
          p_shipment_rec.SHIPPING_INSTRUCTIONS        IS NOT NULL OR
          p_shipment_rec.PACKING_INSTRUCTIONS         IS NOT NULL OR
          p_shipment_rec.DEMAND_CLASS_CODE            IS NOT NULL
        )
      ) OR (
        p_database_object_name = 'ASO_AK_QUOTE_LINE_V'
        AND (
          p_shipment_rec.SHIP_TO_PARTY_SITE_ID        IS NOT NULL OR
          p_shipment_rec.SHIP_TO_PARTY_ID             IS NOT NULL OR
          p_shipment_rec.SHIP_TO_CUST_PARTY_ID        IS NOT NULL OR
          p_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID      IS NOT NULL OR
          p_shipment_rec.REQUEST_DATE                 IS NOT NULL OR
          p_shipment_rec.SHIP_METHOD_CODE             IS NOT NULL OR
          p_shipment_rec.SHIPMENT_PRIORITY_CODE       IS NOT NULL OR
          p_shipment_rec.FREIGHT_TERMS_CODE           IS NOT NULL OR
          p_shipment_rec.FOB_CODE                     IS NOT NULL OR
          p_shipment_rec.SHIPPING_INSTRUCTIONS        IS NOT NULL OR
          p_shipment_rec.PACKING_INSTRUCTIONS         IS NOT NULL OR
          p_shipment_rec.DEMAND_CLASS_CODE            IS NOT NULL OR
	  p_shipment_rec.SHIP_FROM_ORG_ID             IS NOT NULL    -- Added for Bug 10112949
        )
      ) OR (
        p_database_object_name = 'ASO_AK_STORE_CART_HEADER_V'
        AND (
          p_shipment_rec.SHIP_TO_PARTY_SITE_ID        IS NOT NULL OR
          p_shipment_rec.SHIP_TO_PARTY_ID             IS NOT NULL OR
          p_shipment_rec.SHIP_TO_CUST_PARTY_ID        IS NOT NULL OR
          p_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID      IS NOT NULL OR
          p_shipment_rec.REQUEST_DATE_TYPE            IS NOT NULL OR
          p_shipment_rec.REQUEST_DATE                 IS NOT NULL OR
          p_shipment_rec.SHIP_METHOD_CODE             IS NOT NULL OR
          p_shipment_rec.SHIPMENT_PRIORITY_CODE       IS NOT NULL OR
          p_shipment_rec.FREIGHT_TERMS_CODE           IS NOT NULL OR
          p_shipment_rec.FOB_CODE                     IS NOT NULL OR
          p_shipment_rec.SHIPPING_INSTRUCTIONS        IS NOT NULL OR
          p_shipment_rec.PACKING_INSTRUCTIONS         IS NOT NULL OR
          p_shipment_rec.DEMAND_CLASS_CODE            IS NOT NULL
        )
      ) OR (
        p_database_object_name = 'ASO_AK_STORE_CART_LINES_V'
        AND (
          p_shipment_rec.SHIP_TO_PARTY_SITE_ID        IS NOT NULL OR
          p_shipment_rec.SHIP_TO_PARTY_ID             IS NOT NULL OR
          p_shipment_rec.SHIP_TO_CUST_PARTY_ID        IS NOT NULL OR
          p_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID      IS NOT NULL OR
          p_shipment_rec.REQUEST_DATE                 IS NOT NULL OR
          p_shipment_rec.SHIP_METHOD_CODE             IS NOT NULL OR
          p_shipment_rec.SHIPMENT_PRIORITY_CODE       IS NOT NULL OR
          p_shipment_rec.FREIGHT_TERMS_CODE           IS NOT NULL OR
          p_shipment_rec.FOB_CODE                     IS NOT NULL OR
          p_shipment_rec.SHIPPING_INSTRUCTIONS        IS NOT NULL OR
          p_shipment_rec.PACKING_INSTRUCTIONS         IS NOT NULL OR
          p_shipment_rec.DEMAND_CLASS_CODE            IS NOT NULL
        )
      )

  ) THEN

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Defaulting Engine returns values in shipment_rec.');
    END IF;

    return TRUE;

  ELSE

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Defaulting Engine doesn''t default any attribute in shipment_rec.');
    END IF;

    return FALSE;

  END IF;

END Shipment_Null_Rec_Exists;


FUNCTION  Payment_NULL_Rec_Exists(
  p_payment_rec           IN  ASO_QUOTE_PUB.Payment_Rec_Type,
  p_database_object_name  IN  VARCHAR2
) RETURN BOOLEAN
IS

BEGIN
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('Begin Payment_Rec_Exists function.', 1, 'Y');
	END IF;

 IF (
      (
        p_database_object_name = 'ASO_AK_QUOTE_HEADER_V'
        AND (
          p_payment_rec.PAYMENT_TERM_ID             IS NOT NULL  OR
          p_payment_rec.CUST_PO_NUMBER              IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_CODE            IS NOT NULL  OR
          p_payment_rec.PAYMENT_REF_NUMBER          IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_HOLDER_NAME     IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_EXPIRATION_DATE IS NOT NULL  OR
          p_payment_rec.PAYMENT_TYPE_CODE           IS NOT NULL
        )
      ) OR (
        p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V'
        AND (
          p_payment_rec.PAYMENT_TERM_ID             IS NOT NULL  OR
          p_payment_rec.CUST_PO_NUMBER              IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_CODE            IS NOT NULL  OR
          p_payment_rec.PAYMENT_REF_NUMBER          IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_HOLDER_NAME     IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_EXPIRATION_DATE IS NOT NULL  OR
          p_payment_rec.PAYMENT_TYPE_CODE           IS NOT NULL
        )
      ) OR (
        p_database_object_name = 'ASO_AK_QUOTE_LINE_V'
        AND (
          p_payment_rec.CREDIT_CARD_CODE            IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_EXPIRATION_DATE IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_HOLDER_NAME     IS NOT NULL  OR
          p_payment_rec.CUST_PO_NUMBER              IS NOT NULL  OR
          p_payment_rec.CUST_PO_LINE_NUMBER         IS NOT NULL  OR
          p_payment_rec.PAYMENT_REF_NUMBER          IS NOT NULL  OR
          p_payment_rec.PAYMENT_TERM_ID             IS NOT NULL  OR
          p_payment_rec.PAYMENT_TYPE_CODE           IS NOT NULL
        )
      ) OR (
        p_database_object_name = 'ASO_AK_STORE_CART_HEADER_V'
        AND (
          p_payment_rec.PAYMENT_TERM_ID             IS NOT NULL  OR
          p_payment_rec.CUST_PO_NUMBER              IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_CODE            IS NOT NULL  OR
          p_payment_rec.PAYMENT_REF_NUMBER          IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_HOLDER_NAME     IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_EXPIRATION_DATE IS NOT NULL  OR
          p_payment_rec.PAYMENT_TYPE_CODE           IS NOT NULL
        )
      ) OR (
        p_database_object_name = 'ASO_AK_STORE_CART_LINES_V'
        AND (
          p_payment_rec.CREDIT_CARD_CODE            IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_EXPIRATION_DATE IS NOT NULL  OR
          p_payment_rec.CREDIT_CARD_HOLDER_NAME     IS NOT NULL  OR
          p_payment_rec.CUST_PO_NUMBER              IS NOT NULL  OR
          p_payment_rec.CUST_PO_LINE_NUMBER         IS NOT NULL  OR
          p_payment_rec.PAYMENT_REF_NUMBER          IS NOT NULL  OR
          p_payment_rec.PAYMENT_TERM_ID             IS NOT NULL  OR
          p_payment_rec.PAYMENT_TYPE_CODE           IS NOT NULL
        )
      )
  ) THEN

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.add('Defaulting Engine returns values in payment_rec.');
		END IF;

    return TRUE;

  ELSE

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Defaulting Engine doesn''t default any attribute in payment_rec.');
    END IF;

	  RETURN FALSE;

  END IF;

END Payment_NULL_Rec_Exists;


FUNCTION  Tax_Detail_Null_Rec_Exists(
  p_tax_detail_rec        IN  ASO_QUOTE_PUB.Tax_Detail_Rec_Type,
  p_database_object_name  IN VARCHAR2
) RETURN BOOLEAN
IS

BEGIN
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('Begin Tax_Detail_Null_Rec_Exists function.', 1, 'Y');
	END IF;

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Defaulting Engine doesn''t default any attribute in tax_detail_rec.');
  END IF;

  RETURN FALSE;

END Tax_Detail_Null_Rec_Exists;

-- hyang defaulting framework end


PROCEDURE Populate_Qte_Header (
    p_qte_header_rec		IN   ASO_QUOTE_PUB.qte_header_rec_Type,
    p_Control_Rec		    IN   ASO_QUOTE_PUB.Control_Rec_Type,
    x_qte_header_rec	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.qte_header_rec_Type
    )
IS

        l_valid_org_id number;   --New variable to store org_id Yogeshwar (MOAC)

    CURSOR C_Qte_Number IS
	SELECT ASO_QUOTE_NUMBER_S.nextval
	FROM dual;

    CURSOR C_Qte_Version (X_qte_number NUMBER) IS
	SELECT quote_version
	FROM ASO_QUOTE_HEADERS_ALL
	WHERE quote_number = X_qte_number;

    CURSOR C_Qte_Status_Id (c_status_code VARCHAR2) IS
	SELECT quote_status_id
	FROM ASO_QUOTE_STATUSES_VL
	WHERE status_code = c_status_code;

    CURSOR c_price_list (c_order_type_id NUMBEr) IS
        SELECT price_list_id
        FROM OE_ORDER_TYPES_V
        WHERE order_type_id = c_order_type_id;

    CURSOR c_currency_code (c_price_list_id NUMBER) IS
        SELECT currency_code
        FROM qp_price_lists_v
        WHERE price_list_id = c_price_list_id;


    CURSOR c_resource IS
   	SELECT resource_id FROM JTF_RS_SRP_VL
   	WHERE person_id =  p_qte_header_rec.employee_person_id;

    -- Change START
    -- Release 12 MOAC Changes : Bug 4500739
    -- Changes Done by : Girish
    -- Comments : Using HR EIT in place of org striped profile

    --l_order_type_id	NUMBER := to_number(fnd_profile.value('ASO_ORDER_TYPE_ID'));
    l_order_type_id	NUMBER := to_number(ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_ORDER_TYPE));

    -- Change END

    l_price_list_id	NUMBER;
    l_currency_code	VARCHAR2(15);
    l_resource_id NUMBER;
    l_default_status_profile  VARCHAR2(30);

    l_defaulting_fwk_flag     VARCHAR2(1) := p_control_rec.defaulting_fwk_flag;

    x_return_status VARCHAR2(1);
    l_org_id	    NUMBER;    --Yogeshwar (MOAC)

BEGIN

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Begin Populate_Qte_Header procedure', 1, 'Y');
        aso_debug_pub.add('Defaulting Framework Flag - '||l_defaulting_fwk_flag, 1, 'Y');
    END IF;


    x_qte_header_rec := p_qte_header_rec;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Populate_Qte_Header: x_qte_header_rec.quote_number: '||x_qte_header_rec.quote_number, 1, 'N');
    END IF;

    IF (x_qte_header_rec.quote_number IS NULL OR
		x_qte_header_rec.quote_number = FND_API.G_MISS_NUM) THEN

	   IF nvl( FND_PROFILE.Value('ASO_AUTO_NUMBERING'), 'Y') = 'Y' THEN

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.add('Populate_Qte_Header: Inside IF cond ASO_AUTO_NUMBERING = Y', 1, 'N');
		  END IF;

	       OPEN  C_Qte_Number;
	       FETCH C_Qte_Number INTO x_qte_header_rec.quote_number;
	       CLOSE C_Qte_Number;

  	       x_qte_header_rec.quote_version := 1;

	       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.add('x_qte_header_rec.quote_number : '||x_qte_header_rec.quote_number);
	           aso_debug_pub.add('x_qte_header_rec.quote_version: '||x_qte_header_rec.quote_version);
	       END IF;

        ELSIF x_qte_header_rec.quote_type = 'T' then

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
	         aso_debug_pub.add('Populate_Qte_Header: ELSIF cond quote_type = T');
	       END IF;

	       OPEN  C_Qte_Number;
	       FETCH C_Qte_Number INTO x_qte_header_rec.quote_number;
	       CLOSE C_Qte_Number;

  	       x_qte_header_rec.quote_version := 1;

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
		      aso_debug_pub.add('x_qte_header_rec.quote_number : '||x_qte_header_rec.quote_number);
		      aso_debug_pub.add('x_qte_header_rec.quote_version: '||x_qte_header_rec.quote_version);
	   	  END IF;

        ELSE

	       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	          aso_debug_pub.add('Populate_Qte_Header: ASO_AUTO_NUMBERING is off and quote_number is passed as G_MISS_NUM or NULL', 1, 'N');

	       END IF;

	       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
                FND_MESSAGE.Set_Token('COLUMN', 'QUOTE_NUMBER', FALSE);
                FND_MSG_PUB.ADD;
	       END IF;

	       RAISE FND_API.G_EXC_ERROR;

	   END IF;

    ELSE

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.add('Populate_Qte_Header: Inside ELSE cond quote_number is not null and not G_MISS_NUM',1, 'N');
	   END IF;

        OPEN C_Qte_Version(x_qte_header_rec.quote_number);
        FETCH C_Qte_Version into x_qte_header_rec.quote_version;

	   --Changed for Bug # 2365955
        --IF x_qte_header_rec.quote_version IS NOT NULL AND x_qte_header_rec.quote_version <> FND_API.G_MISS_NUM THEN

	   IF C_Qte_Version%FOUND THEN

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.add('Inside else: C_Qte_Version%FOUND', 1, 'N');
		  END IF;

            CLOSE C_Qte_Version;

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_API_DUPLICATE_QTE_NUM');
                FND_MESSAGE.Set_Token('QTE_NUM', x_qte_header_rec.quote_number, FALSE);
                FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		      aso_debug_pub.add('Inside else: C_Qte_Version%NOTFOUND', 1, 'N');
		  END IF;
            x_qte_header_rec.quote_version := 1;
            CLOSE C_Qte_Version;
        END IF;
--	  x_qte_header_rec.quote_version := nvl(x_qte_header_rec.quote_version, 0) + 1;
    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Populate_Qte_Header: x_qte_header_rec.quote_number : '||x_qte_header_rec.quote_number, 1, 'N');
        aso_debug_pub.add('Populate_Qte_Header: x_qte_header_rec.quote_version: '||x_qte_header_rec.quote_version,1, 'N');
    END IF;

    IF (x_qte_header_rec.quote_status_id IS NULL OR
		x_qte_header_rec.quote_status_id = FND_API.G_MISS_NUM) THEN
	  --OPEN c_qte_status_id ('DRAFT');
	  -- hyang 2269617
	  l_default_status_profile := fnd_profile.value( 'ASO_DEFAULT_STATUS_CODE');
	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('Populate_Qte_Header: Profile ASO_DEFAULT_STATUS_CODE is ' || l_default_status_profile, 1, 'Y');
	  END IF;
	  OPEN c_qte_status_id ( l_default_status_profile );
	  FETCH c_qte_status_id INTO x_qte_header_rec.quote_status_id;
	  CLOSE c_qte_status_id;
    END IF;

    IF (l_defaulting_fwk_flag = 'N')
    THEN

       --Commented Code Yogeshwar (MOAC)
    /*  IF (x_qte_header_rec.org_id IS NULL OR
        x_qte_header_rec.org_id = FND_API.G_MISS_NUM) THEN
        IF SUBSTRB(USERENV('CLIENT_INFO'),1,1) <> ' ' THEN
          x_qte_header_rec.org_id := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10));
        END IF;
      END IF;
    */
    --Commented Code End Yogeshwar (MOAC)

    --New Code Start Yogeshwar (MOAC)
	If x_qte_header_rec.org_id  IS NULL THEN
		l_org_id := FND_API.G_MISS_NUM;
	Else
		l_org_id := x_qte_header_rec.org_id;
	End if;
	 l_valid_org_id:= MO_GLOBAL.get_valid_org(l_org_id);
	if l_valid_org_id is NULL then
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
        else
		 x_qte_header_rec.org_id := l_valid_org_id;
	End if;
    --New Code End Yogeshwar (MOAC)

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Before OM Defaulting - Populate Qte header', 1, 'N');
        aso_debug_pub.add('Before OM Defaulting Value of  ASO_OM_DEFAULTING '||FND_PROFILE.Value('ASO_OM_DEFAULTING'), 1, 'N');
      END IF;
      -- IF (NVL(FND_PROFILE.Value('ASO_OM_DEFAULTING'), 'N') = 'N') THEN
      IF (x_qte_header_rec.order_type_id IS NULL OR
        x_qte_header_rec.order_type_id = FND_API.G_MISS_NUM) THEN
        x_qte_header_rec.order_type_id := l_order_type_id;
      END IF;
      --END IF;

      -- New code for Bug # 2317961

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Populate_qte_header: order_type_id: ||x_qte_header_rec.order_type_id ',1,'N');
        aso_debug_pub.add('Populate_qte_header: price_list_id: ||x_qte_header_rec.price_list_id ',1,'N');
      END IF;

      IF x_qte_header_rec.price_list_id = FND_API.G_MISS_NUM THEN

        OPEN  c_price_list(x_qte_header_rec.order_type_id);
        FETCH c_price_list INTO x_qte_header_rec.price_list_id;
        CLOSE c_price_list;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Populate_qte_header: After c_price_list cursor: price_list_id: ||x_qte_header_rec.price_list_id ',1,'N');
        END IF;

      ELSIF (x_qte_header_rec.price_list_id IS NULL) AND
            (x_qte_header_rec.currency_code IS NULL OR
             x_qte_header_rec.currency_code = FND_API.G_MISS_CHAR) THEN

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Populate_qte_header: Currency_code can not be passed as NULL or G_MISS_CHAR when price_list_id is NULL',1,'N');
        END IF;

        FND_MESSAGE.Set_Name('ASO', 'ASO_PRICE_LIST_CURRENCY_CODE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

      END IF;

      -- End new code for Bug # 2317961

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('After price_list_id - Populate Qte header', 1, 'N');
      END IF;

      IF (x_qte_header_rec.currency_code IS NULL OR
        x_qte_header_rec.currency_code = FND_API.G_MISS_CHAR) THEN
        OPEN c_currency_code(x_qte_header_rec.price_list_id);
        FETCH c_currency_code INTO x_qte_header_rec.currency_code;
        CLOSE c_currency_code;
      END IF;

      IF (--x_qte_header_rec.quote_expiration_date IS NULL OR
        x_qte_header_rec.quote_expiration_date = FND_API.G_MISS_DATE) THEN
        x_qte_header_rec.quote_expiration_date := sysdate +
      	  NVL(FND_PROFILE.value('ASO_QUOTE_DURATION'), G_QUOTE_DURATION);
      END IF;

      IF (x_qte_header_rec.resource_id IS NULL OR
          x_qte_header_rec.resource_id = FND_API.G_MISS_NUM)
          AND  (x_qte_header_rec.EMPLOYEE_PERSON_ID IS NOT NULL AND
          x_qte_header_rec.EMPLOYEE_PERSON_ID <> FND_API.G_MISS_NUM) THEN

          OPEN c_resource;
          FETCH c_resource INTO l_resource_id;
          IF c_resource%NOTFOUND OR  l_resource_id IS NULL OR l_resource_id= FND_API.G_MISS_NUM THEN
            CLOSE c_resource;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
            FND_MESSAGE.Set_Token('COLUMN', 'RESOURCE ID', FALSE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          CLOSE c_resource;
          x_qte_header_rec.resource_id := l_resource_id;
          IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Inside  Populate Qte header resource Id'||l_resource_id, 1, 'N');
          END IF;

      END IF;

    END IF; -- defaulting_fwk_flag


    IF x_qte_header_rec.max_version_flag is NULL OR  x_qte_header_rec.max_version_flag = FND_API.G_MISS_CHAR THEN
      x_qte_header_rec.max_version_flag := 'Y';
    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Inside  Populate Qte header x_qte_header_rec.max_version_flag'||x_qte_header_rec.max_version_flag,1,'N');
      aso_debug_pub.add('End Populate Qte header', 1, 'Y');
    END IF;

END Populate_Qte_Header;

PROCEDURE Insert_Rows (
    P_qte_Header_Rec        IN       ASO_QUOTE_PUB.qte_header_rec_Type,
    p_Price_Attributes_Tbl  IN       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    P_Price_Adjustment_Tbl  IN       ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    P_Price_Adj_Attr_Tbl	   IN       ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    P_Payment_Tbl		   IN       ASO_QUOTE_PUB.Payment_Tbl_Type,
    P_Shipment_Tbl		   IN       ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Freight_Charge_Tbl	   IN       ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_Tax_Detail_Tbl        IN       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_hd_Attr_Ext_Tbl       IN       ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    P_Sales_Credit_Tbl      IN       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    P_Quote_Party_Tbl       IN       ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    P_Qte_Access_Tbl        IN       ASO_QUOTE_PUB.Qte_Access_Tbl_Type,
    X_qte_Header_Rec        OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.qte_header_rec_Type,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    X_Price_Adjustment_Tbl  OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    x_Price_Adj_Attr_Tbl	   OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Payment_Tbl		   OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_Shipment_Rec		   OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Shipment_Rec_Type,
    X_Freight_Charge_Tbl	   OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl       OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    X_Qte_Access_Tbl        OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Qte_Access_Tbl_Type,
    X_Return_Status		   OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    X_Msg_Count 		   OUT NOCOPY /* file.sql.39 change */      NUMBER,
    X_Msg_Data			   OUT NOCOPY /* file.sql.39 change */      VARCHAR2
    )
IS
    l_price_adj_rec		ASO_QUOTE_PUB.Price_Adj_Rec_Type;
    l_payment_rec		ASO_QUOTE_PUB.Payment_Rec_Type;
    l_shipment_rec		ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_freight_charge_rec	ASO_QUOTE_PUB.Freight_Charge_Rec_Type;
    l_tax_detail_rec		ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
    lx_qte_header_id		NUMBER;
    lx_shipment_id		NUMBER;
    l_Sales_Credit_Tbl          ASO_QUOTE_PUB.Sales_Credit_Tbl_Type ;
    l_Quote_Party_Tbl           ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
    l_Sales_Credit_rec          ASO_QUOTE_PUB.Sales_Credit_rec_Type ;
    l_Quote_Party_rec           ASO_QUOTE_PUB.Quote_Party_rec_Type;
    l_line_attribs_rec          ASO_QUOTE_PUB.Line_Attribs_Ext_REC_type;
    l_sysdate           DATE;
    l_price_adj_attr_tbl	ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    l_price_attributes_rec      ASO_QUOTE_PUB.Price_Attributes_Rec_Type;

G_USER_ID	  NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID	  NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

    l_org_id NUMBER;
    l_valid_org_id number;  --New variable to store ORG_ID Yogeshwar (MOAC)

    l_qte_access_tbl    ASO_QUOTE_PUB.Qte_Access_Tbl_Type := p_qte_access_tbl;
    --l_qte_access_tbl    ASO_SECURITY_INT.Qte_Access_Tbl_Type := p_qte_access_tbl;
    --lx_qte_access_tbl   ASO_SECURITY_INT.Qte_Access_Tbl_Type;
    lx_price_attr_tbl          ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;

BEGIN
    x_qte_header_rec := p_qte_header_rec;
    l_sysdate := sysdate;

    --Commented Code Start Yogeshwar (MOAC)
    /* IF p_qte_header_rec.ORG_ID IS NULL OR p_qte_header_rec.ORG_ID = FND_API.G_MISS_NUM THEN

       IF SUBSTRB(USERENV('CLIENT_INFO'),1 ,1) = ' ' THEN
           l_org_id := NULL;
       ELSE
           l_org_id := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1,10));
       END IF;

    ELSIF p_qte_header_rec.ORG_ID IS NOT NULL AND p_qte_header_rec.ORG_ID <> FND_API.G_MISS_NUM THEN
         l_org_id :=  p_qte_header_rec.ORG_ID;
    END IF;
    */ --Commented Code End Yogeshwar (MOAC)

    --New Code Start Yogeshwar (MOAC)
       If p_qte_header_rec.org_id  IS NULL THEN
		l_org_id := FND_API.G_MISS_NUM;
	Else
		l_org_id := p_qte_header_rec.org_id;
	End if;
	l_valid_org_id:= MO_GLOBAL.get_valid_org(l_org_id);
	if l_valid_org_id is NULL then
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	else
		l_org_id := l_valid_org_id ;
	End if;
   --New Code End Yogeshwar (MOAC)

    lx_qte_header_id := p_qte_header_rec.quote_header_id;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Begin Insert Rows', 1, 'Y');
    END IF;

    ASO_QUOTE_HEADERS_PKG.Insert_Row(
	  px_QUOTE_HEADER_ID  => lx_qte_header_id,
	  p_CREATION_DATE  => l_SYSDATE,
	  p_CREATED_BY	=> G_USER_ID,
	  p_LAST_UPDATE_DATE  => l_sysdate,
	  p_LAST_UPDATED_BY  => G_USER_ID,
	  p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	  p_REQUEST_ID	=> p_qte_header_rec.REQUEST_ID,
	  p_PROGRAM_APPLICATION_ID  => p_qte_header_rec.PROGRAM_APPLICATION_ID,
	  p_PROGRAM_ID	=> p_qte_header_rec.PROGRAM_ID,
	  p_PROGRAM_UPDATE_DATE  => p_qte_header_rec.PROGRAM_UPDATE_DATE,
	  p_ORG_ID  => l_org_id,
	  p_QUOTE_NAME	=> p_qte_header_rec.QUOTE_NAME,
	  p_QUOTE_NUMBER  => p_qte_header_rec.QUOTE_NUMBER,
	  p_QUOTE_VERSION  => p_qte_header_rec.QUOTE_VERSION,
	  p_QUOTE_STATUS_ID  => p_qte_header_rec.QUOTE_STATUS_ID,
	  p_QUOTE_SOURCE_CODE  => p_qte_header_rec.QUOTE_SOURCE_CODE,
	  p_QUOTE_EXPIRATION_DATE  => trunc(p_qte_header_rec.QUOTE_EXPIRATION_DATE),
	  p_PRICE_FROZEN_DATE  => p_qte_header_rec.PRICE_FROZEN_DATE,
	  p_QUOTE_PASSWORD  => p_qte_header_rec.QUOTE_PASSWORD,
	  p_ORIGINAL_SYSTEM_REFERENCE  => p_qte_header_rec.ORIGINAL_SYSTEM_REFERENCE,
	  p_PARTY_ID  => p_qte_header_rec.PARTY_ID,
	  p_CUST_ACCOUNT_ID  => p_qte_header_rec.CUST_ACCOUNT_ID,
	  p_ORG_CONTACT_ID  => p_qte_header_rec.ORG_CONTACT_ID,
	  p_PHONE_ID  => p_QTE_header_rec.PHONE_ID,
	  p_INVOICE_TO_PARTY_SITE_ID  => p_qte_header_rec.INVOICE_TO_PARTY_SITE_ID,
	  p_INVOICE_TO_PARTY_ID  => p_qte_header_rec.INVOICE_TO_PARTY_ID,
          p_Invoice_to_CUST_ACCOUNT_ID  => p_qte_header_rec.Invoice_to_CUST_ACCOUNT_ID,
	  p_ORIG_MKTG_SOURCE_CODE_ID  => p_qte_header_rec.ORIG_MKTG_SOURCE_CODE_ID,
	  p_MARKETING_SOURCE_CODE_ID  => p_qte_header_rec.MARKETING_SOURCE_CODE_ID,
	  p_ORDER_TYPE_ID  => p_qte_header_rec.ORDER_TYPE_ID,
	  p_QUOTE_CATEGORY_CODE  => p_qte_header_rec.QUOTE_CATEGORY_CODE,
	  p_ORDERED_DATE  => p_qte_header_rec.ORDERED_DATE,
	  p_ACCOUNTING_RULE_ID	=> p_qte_header_rec.ACCOUNTING_RULE_ID,
	  p_INVOICING_RULE_ID  => p_qte_header_rec.INVOICING_RULE_ID,
	  p_EMPLOYEE_PERSON_ID	=> p_qte_header_rec.EMPLOYEE_PERSON_ID,
	  p_PRICE_LIST_ID  => p_qte_header_rec.PRICE_LIST_ID,
	  p_CURRENCY_CODE  => p_qte_header_rec.CURRENCY_CODE,
	  p_TOTAL_LIST_PRICE  => p_qte_header_rec.TOTAL_LIST_PRICE,
	  p_TOTAL_ADJUSTED_AMOUNT  => p_qte_header_rec.TOTAL_ADJUSTED_AMOUNT,
	  p_TOTAL_ADJUSTED_PERCENT  => p_qte_header_rec.TOTAL_ADJUSTED_PERCENT,
	  p_TOTAL_TAX  => p_qte_header_rec.TOTAL_TAX,
	  p_TOTAL_SHIPPING_CHARGE  => p_qte_header_rec.TOTAL_SHIPPING_CHARGE,
	  p_SURCHARGE  => p_qte_header_rec.SURCHARGE,
	  p_TOTAL_QUOTE_PRICE  => p_qte_header_rec.TOTAL_QUOTE_PRICE,
	  p_PAYMENT_AMOUNT  => p_qte_header_rec.PAYMENT_AMOUNT,
	  p_EXCHANGE_RATE  => p_qte_header_rec.EXCHANGE_RATE,
	  p_EXCHANGE_TYPE_CODE	=> p_qte_header_rec.EXCHANGE_TYPE_CODE,
	  p_EXCHANGE_RATE_DATE	=> p_qte_header_rec.EXCHANGE_RATE_DATE,
	  p_CONTRACT_ID  => p_qte_header_rec.CONTRACT_ID,
	  p_SALES_CHANNEL_CODE	=> p_qte_header_rec.SALES_CHANNEL_CODE,
	  p_ORDER_ID  => p_QTE_header_rec.ORDER_ID,
	  p_RESOURCE_ID =>  p_qte_header_rec.RESOURCE_ID,
	  p_ATTRIBUTE_CATEGORY	=> p_qte_header_rec.ATTRIBUTE_CATEGORY,
	  p_ATTRIBUTE1	=> p_qte_header_rec.ATTRIBUTE1,
	  p_ATTRIBUTE2	=> p_qte_header_rec.ATTRIBUTE2,
	  p_ATTRIBUTE3	=> p_qte_header_rec.ATTRIBUTE3,
	  p_ATTRIBUTE4	=> p_qte_header_rec.ATTRIBUTE4,
	  p_ATTRIBUTE5	=> p_qte_header_rec.ATTRIBUTE5,
	  p_ATTRIBUTE6	=> p_qte_header_rec.ATTRIBUTE6,
	  p_ATTRIBUTE7	=> p_qte_header_rec.ATTRIBUTE7,
	  p_ATTRIBUTE8	=> p_qte_header_rec.ATTRIBUTE8,
	  p_ATTRIBUTE9	=> p_qte_header_rec.ATTRIBUTE9,
	  p_ATTRIBUTE10  => p_qte_header_rec.ATTRIBUTE10,
	  p_ATTRIBUTE11  => p_qte_header_rec.ATTRIBUTE11,
	  p_ATTRIBUTE12  => p_qte_header_rec.ATTRIBUTE12,
	  p_ATTRIBUTE13  => p_qte_header_rec.ATTRIBUTE13,
	  p_ATTRIBUTE14  => p_qte_header_rec.ATTRIBUTE14,
	  p_ATTRIBUTE15  => p_qte_header_rec.ATTRIBUTE15,
       p_ATTRIBUTE16  => p_qte_header_rec.ATTRIBUTE16,
       p_ATTRIBUTE17  => p_qte_header_rec.ATTRIBUTE17,
       p_ATTRIBUTE18  => p_qte_header_rec.ATTRIBUTE18,
       p_ATTRIBUTE19  => p_qte_header_rec.ATTRIBUTE19,
       p_ATTRIBUTE20  => p_qte_header_rec.ATTRIBUTE20,
-- hyang new okc
	  p_CONTRACT_TEMPLATE_ID  => FND_API.G_MISS_NUM,
	  p_CONTRACT_TEMPLATE_MAJOR_VER  => FND_API.G_MISS_NUM,
	  p_CONTRACT_REQUESTER_ID   => FND_API.G_MISS_NUM,
	  p_CONTRACT_APPROVAL_LEVEL => FND_API.G_MISS_CHAR,
-- end of hyang new okc
	  p_PUBLISH_FLAG            => p_qte_header_rec.PUBLISH_FLAG,
	  p_RESOURCE_GRP_ID         => p_qte_header_rec.RESOURCE_GRP_ID,
          p_SOLD_TO_PARTY_SITE_ID   => p_qte_header_rec.SOLD_TO_PARTY_SITE_ID,
          p_DISPLAY_ARITHMETIC_OPERATOR => p_qte_header_rec.DISPLAY_ARITHMETIC_OPERATOR,
          p_MAX_VERSION_FLAG        => p_qte_header_rec.max_version_flag,
          p_QUOTE_TYPE              => p_qte_header_rec.QUOTE_TYPE,
          p_QUOTE_DESCRIPTION       => p_qte_header_rec.QUOTE_DESCRIPTION,
          p_MINISITE_ID             => p_qte_header_rec.MINISITE_ID,
	  p_CUST_PARTY_ID          => p_qte_header_rec.CUST_PARTY_ID,
	  p_INVOICE_TO_CUST_PARTY_ID => p_qte_header_rec.INVOICE_TO_CUST_PARTY_ID,
	  p_Pricing_Status_indicator  	     =>  p_qte_header_rec.Pricing_Status_indicator,
	  p_Tax_status_Indicator	     =>  p_qte_header_rec.Tax_status_Indicator,
	  p_Price_updated_date	     	     =>  p_qte_header_rec.Price_updated_date,
	  p_Tax_updated_date		     =>  p_qte_header_rec.Tax_updated_date,
	  p_Recalculate_flag		     =>  p_qte_header_rec.Recalculate_flag,
	  p_price_request_id		     => p_qte_header_rec.price_request_id,
	  p_credit_update_date		     => p_qte_header_rec.credit_update_date,
-- hyang new okc
    P_Customer_Name_And_Title       =>  p_qte_header_rec.Customer_Name_And_Title,
    P_Customer_Signature_Date       =>  p_qte_header_rec.Customer_Signature_Date,
    P_Supplier_Name_And_Title       =>  p_qte_header_rec.Supplier_Name_And_Title,
    P_Supplier_Signature_Date       =>  p_qte_header_rec.Supplier_Signature_Date,
-- end of hyang new okc
    p_END_CUSTOMER_PARTY_ID         =>  p_qte_header_rec.END_CUSTOMER_PARTY_ID,
    p_END_CUSTOMER_CUST_PARTY_ID    =>  p_qte_header_rec.END_CUSTOMER_CUST_PARTY_ID,
    p_END_CUSTOMER_PARTY_SITE_ID    =>  p_qte_header_rec.END_CUSTOMER_PARTY_SITE_ID,
    p_END_CUSTOMER_CUST_ACCOUNT_ID  =>  p_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID,
    P_OBJECT_VERSION_NUMBER         =>  p_qte_header_rec.OBJECT_VERSION_NUMBER,
    p_assistance_requested          =>  p_qte_header_rec.assistance_requested,
    p_assistance_reason_code        =>  p_qte_header_rec.assistance_reason_code,
    p_automatic_price_flag          =>  p_qte_header_rec.automatic_price_flag,
    p_automatic_tax_flag            =>  p_qte_header_rec.automatic_tax_flag,
    p_header_paynow_charges         =>  p_qte_header_rec.header_paynow_charges,
      -- ER 12879412
    P_PRODUCT_FISC_CLASSIFICATION => p_qte_header_rec.PRODUCT_FISC_CLASSIFICATION,
    P_TRX_BUSINESS_CATEGORY =>   p_qte_header_rec.TRX_BUSINESS_CATEGORY,
     -- ER 21158830
    P_TOTAL_UNIT_COST => p_qte_header_rec.TOTAL_UNIT_COST,
    P_TOTAL_MARGIN_AMOUNT =>   p_qte_header_rec.TOTAL_MARGIN_AMOUNT      ,
    P_TOTAL_MARGIN_PERCENT  =>       p_qte_header_rec.TOTAL_MARGIN_PERCENT
);

    x_qte_header_rec.QUOTE_HEADER_ID := lx_qte_header_id;
    x_qte_header_rec.LAST_UPDATE_DATE := l_sysdate;
     x_qte_header_rec.CREATION_DATE := l_sysdate;
	x_qte_header_rec.max_version_flag := 'Y';
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('After quote headers.insert rows - Insert Rows', 1, 'Y');
	END IF;

    x_price_adjustment_tbl := p_price_adjustment_tbl;
    l_price_adj_attr_tbl := p_price_adj_attr_tbl;
    FOR i IN 1..P_Price_Adjustment_Tbl.count LOOP
	l_price_adj_rec := p_price_adjustment_tbl(i);
     -- BC4J Fix
	--x_price_adjustment_tbl(i).PRICE_ADJUSTMENT_ID := NULL;
    l_sysdate := sysdate;
	ASO_PRICE_ADJUSTMENTS_PKG.Insert_Row(
	    px_PRICE_ADJUSTMENT_ID  => x_price_adjustment_tbl(i).PRICE_ADJUSTMENT_ID,
	    p_CREATION_DATE  => SYSDATE,
	    p_CREATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_DATE	=> l_sysdate,
	    p_LAST_UPDATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	    p_PROGRAM_APPLICATION_ID  => l_price_adj_rec.PROGRAM_APPLICATION_ID,
	    p_PROGRAM_ID  => l_price_adj_rec.PROGRAM_ID,
	    p_PROGRAM_UPDATE_DATE  => l_price_adj_rec.PROGRAM_UPDATE_DATE,
	    p_REQUEST_ID  => l_price_adj_rec.REQUEST_ID,
	    p_QUOTE_HEADER_ID  => lx_QTE_HEADER_ID,
	    p_QUOTE_LINE_ID  => NULL,
	    p_MODIFIER_HEADER_ID  => l_price_adj_rec.MODIFIER_HEADER_ID,
	    p_MODIFIER_LINE_ID	=> l_price_adj_rec.MODIFIER_LINE_ID,
	    p_MODIFIER_LINE_TYPE_CODE  => l_price_adj_rec.MODIFIER_LINE_TYPE_CODE,
	    p_MODIFIER_MECHANISM_TYPE_CODE  => l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE,
	    p_MODIFIED_FROM  => l_price_adj_rec.MODIFIED_FROM,
	    p_MODIFIED_TO  => l_price_adj_rec.MODIFIED_TO,
	    p_OPERAND  => l_price_adj_rec.OPERAND,
	    p_ARITHMETIC_OPERATOR  => l_price_adj_rec.ARITHMETIC_OPERATOR,
	    p_AUTOMATIC_FLAG  => l_price_adj_rec.AUTOMATIC_FLAG,
	    p_UPDATE_ALLOWABLE_FLAG  => l_price_adj_rec.UPDATE_ALLOWABLE_FLAG,
	    p_UPDATED_FLAG  => l_price_adj_rec.UPDATED_FLAG,
	    p_APPLIED_FLAG  => l_price_adj_rec.APPLIED_FLAG,
	    p_ON_INVOICE_FLAG  => l_price_adj_rec.ON_INVOICE_FLAG,
	    p_PRICING_PHASE_ID	=> l_price_adj_rec.PRICING_PHASE_ID,
	    p_ATTRIBUTE_CATEGORY  => l_price_adj_rec.ATTRIBUTE_CATEGORY,
	    p_ATTRIBUTE1  => l_price_adj_rec.ATTRIBUTE1,
	    p_ATTRIBUTE2  => l_price_adj_rec.ATTRIBUTE2,
	    p_ATTRIBUTE3  => l_price_adj_rec.ATTRIBUTE3,
	    p_ATTRIBUTE4  => l_price_adj_rec.ATTRIBUTE4,
	    p_ATTRIBUTE5  => l_price_adj_rec.ATTRIBUTE5,
	    p_ATTRIBUTE6  => l_price_adj_rec.ATTRIBUTE6,
	    p_ATTRIBUTE7  => l_price_adj_rec.ATTRIBUTE7,
	    p_ATTRIBUTE8  => l_price_adj_rec.ATTRIBUTE8,
	    p_ATTRIBUTE9  => l_price_adj_rec.ATTRIBUTE9,
	    p_ATTRIBUTE10  => l_price_adj_rec.ATTRIBUTE10,
	    p_ATTRIBUTE11  => l_price_adj_rec.ATTRIBUTE11,
	    p_ATTRIBUTE12  => l_price_adj_rec.ATTRIBUTE12,
	    p_ATTRIBUTE13  => l_price_adj_rec.ATTRIBUTE13,
	    p_ATTRIBUTE14  => l_price_adj_rec.ATTRIBUTE14,
	    p_ATTRIBUTE15  => l_price_adj_rec.ATTRIBUTE15,
         p_ATTRIBUTE16  => l_price_adj_rec.ATTRIBUTE16,
	    p_ATTRIBUTE17  => l_price_adj_rec.ATTRIBUTE17,
	    p_ATTRIBUTE18  => l_price_adj_rec.ATTRIBUTE18,
	    p_ATTRIBUTE19  => l_price_adj_rec.ATTRIBUTE19,
	    p_ATTRIBUTE20  => l_price_adj_rec.ATTRIBUTE20,
  p_ORIG_SYS_DISCOUNT_REF                    => l_price_adj_rec.ORIG_SYS_DISCOUNT_REF ,
          p_CHANGE_SEQUENCE                           => l_price_adj_rec.CHANGE_SEQUENCE ,
          -- p_LIST_HEADER_ID                            => l_price_adj_rec. ,
          -- p_LIST_LINE_ID                              => l_price_adj_rec. ,
          -- p_LIST_LINE_TYPE_CODE                       => l_price_adj_rec.,
          p_UPDATE_ALLOWED                            => l_price_adj_rec.UPDATE_ALLOWED,
          p_CHANGE_REASON_CODE                        => l_price_adj_rec.CHANGE_REASON_CODE,
          p_CHANGE_REASON_TEXT                        => l_price_adj_rec.CHANGE_REASON_TEXT,
          p_COST_ID                                   => l_price_adj_rec.COST_ID ,
          p_TAX_CODE                                  => l_price_adj_rec.TAX_CODE,
          p_TAX_EXEMPT_FLAG                           => l_price_adj_rec.TAX_EXEMPT_FLAG,
          p_TAX_EXEMPT_NUMBER                         => l_price_adj_rec.TAX_EXEMPT_NUMBER,
          p_TAX_EXEMPT_REASON_CODE                    => l_price_adj_rec.TAX_EXEMPT_REASON_CODE,
          p_PARENT_ADJUSTMENT_ID                      => l_price_adj_rec.PARENT_ADJUSTMENT_ID,
          p_INVOICED_FLAG                             => l_price_adj_rec.INVOICED_FLAG,
          p_ESTIMATED_FLAG                            => l_price_adj_rec.ESTIMATED_FLAG,
          p_INC_IN_SALES_PERFORMANCE                  => l_price_adj_rec.INC_IN_SALES_PERFORMANCE,
          p_SPLIT_ACTION_CODE                         => l_price_adj_rec.SPLIT_ACTION_CODE,
          p_ADJUSTED_AMOUNT                           => l_price_adj_rec.ADJUSTED_AMOUNT ,
          p_CHARGE_TYPE_CODE                          => l_price_adj_rec.CHARGE_TYPE_CODE,
          p_CHARGE_SUBTYPE_CODE                       => l_price_adj_rec.CHARGE_SUBTYPE_CODE,
          p_RANGE_BREAK_QUANTITY                      => l_price_adj_rec.RANGE_BREAK_QUANTITY,
          p_ACCRUAL_CONVERSION_RATE                   => l_price_adj_rec.ACCRUAL_CONVERSION_RATE ,
          p_PRICING_GROUP_SEQUENCE                    => l_price_adj_rec.PRICING_GROUP_SEQUENCE,
          p_ACCRUAL_FLAG                              => l_price_adj_rec.ACCRUAL_FLAG,
          p_LIST_LINE_NO                              => l_price_adj_rec.LIST_LINE_NO,
          p_SOURCE_SYSTEM_CODE                        => l_price_adj_rec.SOURCE_SYSTEM_CODE ,
          p_BENEFIT_QTY                               => l_price_adj_rec.BENEFIT_QTY,
          p_BENEFIT_UOM_CODE                          => l_price_adj_rec.BENEFIT_UOM_CODE,
          p_PRINT_ON_INVOICE_FLAG                     => l_price_adj_rec.PRINT_ON_INVOICE_FLAG,
          p_EXPIRATION_DATE                           => l_price_adj_rec.EXPIRATION_DATE,
          p_REBATE_TRANSACTION_TYPE_CODE              => l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE,
          p_REBATE_TRANSACTION_REFERENCE              => l_price_adj_rec.REBATE_TRANSACTION_REFERENCE,
          p_REBATE_PAYMENT_SYSTEM_CODE                => l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE,
          p_REDEEMED_DATE                             => l_price_adj_rec.REDEEMED_DATE,
          p_REDEEMED_FLAG                             => l_price_adj_rec.REDEEMED_FLAG,
          p_MODIFIER_LEVEL_CODE                       => l_price_adj_rec.MODIFIER_LEVEL_CODE,
          p_PRICE_BREAK_TYPE_CODE                     => l_price_adj_rec.PRICE_BREAK_TYPE_CODE ,
          p_SUBSTITUTION_ATTRIBUTE                    => l_price_adj_rec.SUBSTITUTION_ATTRIBUTE,
          p_PRORATION_TYPE_CODE                       => l_price_adj_rec.PRORATION_TYPE_CODE ,
          p_INCLUDE_ON_RETURNS_FLAG                   => l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG,
          p_CREDIT_OR_CHARGE_FLAG                     => l_price_adj_rec.CREDIT_OR_CHARGE_FLAG,
		p_quote_shipment_id                          => l_price_adj_rec.quote_shipment_id,
		p_OPERAND_PER_PQTY                          => l_price_adj_rec.OPERAND_PER_PQTY,
	     p_ADJUSTED_AMOUNT_PER_PQTY                  => l_price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY,
		P_OBJECT_VERSION_NUMBER                     => l_price_adj_rec.OBJECT_VERSION_NUMBER
        );
        x_price_adjustment_tbl(i).LAST_UPDATE_DATE := l_sysdate;
	FOR j in 1..l_price_adj_attr_tbl.count LOOP
	    IF l_price_adj_attr_tbl(j).price_adj_index = i THEN
		l_price_adj_attr_tbl(j).price_adjustment_id := x_price_adjustment_tbl(i).PRICE_ADJUSTMENT_ID;
	    END IF;
	END LOOP;
    END LOOP;

    x_price_adj_attr_tbl := l_price_adj_attr_tbl;
    FOR i in 1..l_price_adj_attr_tbl.count LOOP
     -- BC4J Fix
	--x_price_adj_attr_tbl(i).PRICE_ADJ_ATTRIB_ID := NULL;
     l_sysdate := sysdate;
	ASO_PRICE_ADJ_ATTRIBS_PKG.Insert_Row(
		px_PRICE_ADJ_ATTRIB_ID	 => x_price_adj_attr_tbl(i).PRICE_ADJ_ATTRIB_ID,
		p_CREATION_DATE  => SYSDATE,
		p_CREATED_BY  => G_USER_ID,
		p_LAST_UPDATE_DATE  => l_sysdate,
		p_LAST_UPDATED_BY  => G_USER_ID,
		p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
		p_PROGRAM_APPLICATION_ID  =>l_price_adj_attr_tbl(i).PROGRAM_APPLICATION_ID,
		p_PROGRAM_ID  => l_price_adj_attr_tbl(i).PROGRAM_ID,
		p_PROGRAM_UPDATE_DATE  => l_price_adj_attr_tbl(i).PROGRAM_UPDATE_DATE,
		p_REQUEST_ID  => l_price_adj_attr_tbl(i).REQUEST_ID,
		p_PRICE_ADJUSTMENT_ID => l_price_adj_attr_tbl(i).PRICE_ADJUSTMENT_ID,
		p_PRICING_CONTEXT  => l_price_adj_attr_tbl(i).PRICING_CONTEXT,
		p_PRICING_ATTRIBUTE => l_price_adj_attr_tbl(i).PRICING_ATTRIBUTE,
		p_PRICING_ATTR_VALUE_FROM => l_price_adj_attr_tbl(i).PRICING_ATTR_VALUE_FROM,
		p_PRICING_ATTR_VALUE_TO  => l_price_adj_attr_tbl(i).PRICING_ATTR_VALUE_TO,
		p_COMPARISON_OPERATOR	=> l_price_adj_attr_tbl(i).COMPARISON_OPERATOR,
		p_FLEX_TITLE   => l_price_adj_attr_tbl(i).FLEX_TITLE,
		P_OBJECT_VERSION_NUMBER => l_price_adj_attr_tbl(i).OBJECT_VERSION_NUMBER);
        x_price_adj_attr_tbl(i).LAST_UPDATE_DATE := l_sysdate;
    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('After Price_adj.insert_rows - Insert Rows', 1, 'Y');
    END IF;

    x_payment_tbl := p_payment_tbl;

    FOR i IN 1..P_Payment_Tbl.count LOOP

	l_payment_rec := p_payment_tbl(i);
	l_payment_rec.payment_term_id_from := p_payment_tbl(i).payment_term_id;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Inside ASO_PAYMENTS_PKG - Insert Rows p_payment_tbl(i).payment_term_id'||p_payment_tbl(i).payment_term_id, 1, 'Y');
       aso_debug_pub.add('Inside ASO_PAYMENTS_PKG - Insert Rows l_payment_rec.PAYMENT_TERM_ID_FROM'||l_payment_rec.PAYMENT_TERM_ID_FROM, 1, 'Y');
    END IF;

     -- BC4J Fix
	--x_payment_tbl(i).payment_id := null;
	x_payment_tbl(i).payment_term_id_from := l_payment_rec.payment_term_id_from;
        l_sysdate := sysdate;


     --  Payments Changes

	    l_payment_rec.quote_header_id := lx_qte_header_id;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Insert_Rows: Before  call to create_payment_row ', 1, 'Y');
           END IF;

         aso_payment_int.create_payment_row(p_payment_rec => l_payment_rec  ,
                                             x_payment_rec   => x_payment_tbl(i),
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Insert_Rows: After call to create_payment_row: x_return_status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;

	x_payment_tbl(i).payment_term_id_from := l_payment_rec.payment_term_id_from;

	-- End Payment Changes
     x_payment_tbl(i).LAST_UPDATE_DATE := l_sysdate;

    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('After Payments.insert_rows - Insert Rows', 1, 'Y');
    END IF;

    x_shipment_rec := ASO_QUOTE_PUB.G_Miss_Shipment_Rec;

    IF p_shipment_tbl.count > 0 THEN

	x_shipment_rec := p_shipment_tbl(1);
        x_shipment_rec.ship_method_code_from   := p_shipment_tbl(1).ship_method_code;
        x_shipment_rec.freight_terms_code_from := p_shipment_tbl(1).freight_terms_code;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Before ASO_SHIPMENTS_PKG.insert_rows - p_shipment_tbl(1).ship_method_code'||p_shipment_tbl(1).ship_method_code, 1, 'Y');
      aso_debug_pub.add('Before ASO_SHIPMENTS_PKG.insert_rows - p_shipment_tbl(1).freight_terms_code'||p_shipment_tbl(1).freight_terms_code, 1, 'Y');
     END IF;

        l_sysdate := sysdate;
     -- BC4J Fix
     lx_shipment_id := p_shipment_tbl(1).shipment_id;

	ASO_SHIPMENTS_PKG.Insert_Row(
	    px_SHIPMENT_ID  => lx_shipment_id,
	    p_CREATION_DATE  => SYSDATE,
	    p_CREATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_DATE	=> l_sysdate,
	    p_LAST_UPDATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	    p_REQUEST_ID  => x_shipment_rec.REQUEST_ID,
	    p_PROGRAM_APPLICATION_ID  => x_shipment_rec.PROGRAM_APPLICATION_ID,
	    p_PROGRAM_ID  => x_shipment_rec.PROGRAM_ID,
	    p_PROGRAM_UPDATE_DATE  => x_shipment_rec.PROGRAM_UPDATE_DATE,
	    p_QUOTE_HEADER_ID  => lx_Qte_HEADER_ID,
	    p_QUOTE_LINE_ID  => NULL,
	    p_PROMISE_DATE  => x_shipment_rec.PROMISE_DATE,
	    p_REQUEST_DATE  => x_shipment_rec.REQUEST_DATE,
	    p_SCHEDULE_SHIP_DATE  => x_shipment_rec.SCHEDULE_SHIP_DATE,
	    p_SHIP_TO_PARTY_SITE_ID  => x_shipment_rec.SHIP_TO_PARTY_SITE_ID,
	    p_SHIP_TO_PARTY_ID	=> x_shipment_rec.SHIP_TO_PARTY_ID,
         p_SHIP_TO_CUST_ACCOUNT_ID  => x_Shipment_rec.SHIP_TO_CUST_ACCOUNT_ID,
	    p_SHIP_PARTIAL_FLAG  => x_shipment_rec.SHIP_PARTIAL_FLAG,
	    p_SHIP_SET_ID  => x_shipment_rec.SHIP_SET_ID,
	    p_SHIP_METHOD_CODE	=> x_shipment_rec.SHIP_METHOD_CODE,
	    p_FREIGHT_TERMS_CODE  => x_shipment_rec.FREIGHT_TERMS_CODE,
	    p_FREIGHT_CARRIER_CODE  => x_shipment_rec.FREIGHT_CARRIER_CODE,
	    p_FOB_CODE	=> x_shipment_rec.FOB_CODE,
	    p_SHIPPING_INSTRUCTIONS  => x_shipment_rec.SHIPPING_INSTRUCTIONS,
	    p_PACKING_INSTRUCTIONS  => x_shipment_rec.PACKING_INSTRUCTIONS,
	    p_QUANTITY	=> x_shipment_rec.QUANTITY,
	    p_RESERVED_QUANTITY  => x_shipment_rec.RESERVED_QUANTITY,
	    p_RESERVATION_ID  => x_shipment_rec.RESERVATION_ID,
	    p_ORDER_LINE_ID  => x_shipment_rec.ORDER_LINE_ID,
	    p_ATTRIBUTE_CATEGORY  => x_SHIPMENT_rec.ATTRIBUTE_CATEGORY,
	    p_ATTRIBUTE1  => x_shipment_rec.ATTRIBUTE1,
	    p_ATTRIBUTE2  => x_shipment_rec.ATTRIBUTE2,
	    p_ATTRIBUTE3  => x_shipment_rec.ATTRIBUTE3,
	    p_ATTRIBUTE4  => x_shipment_rec.ATTRIBUTE4,
	    p_ATTRIBUTE5  => x_shipment_rec.ATTRIBUTE5,
	    p_ATTRIBUTE6  => x_shipment_rec.ATTRIBUTE6,
	    p_ATTRIBUTE7  => x_shipment_rec.ATTRIBUTE7,
	    p_ATTRIBUTE8  => x_shipment_rec.ATTRIBUTE8,
	    p_ATTRIBUTE9  => x_shipment_rec.ATTRIBUTE9,
	    p_ATTRIBUTE10  => x_shipment_rec.ATTRIBUTE10,
	    p_ATTRIBUTE11  => x_shipment_rec.ATTRIBUTE11,
	    p_ATTRIBUTE12  => x_shipment_rec.ATTRIBUTE12,
	    p_ATTRIBUTE13  => x_shipment_rec.ATTRIBUTE13,
	    p_ATTRIBUTE14  => x_shipment_rec.ATTRIBUTE14,
	    p_ATTRIBUTE15  => x_shipment_rec.ATTRIBUTE15,
         p_ATTRIBUTE16  => x_shipment_rec.ATTRIBUTE16,
	    p_ATTRIBUTE17  => x_shipment_rec.ATTRIBUTE17,
	    p_ATTRIBUTE18  => x_shipment_rec.ATTRIBUTE18,
	    p_ATTRIBUTE19  => x_shipment_rec.ATTRIBUTE19,
	    p_ATTRIBUTE20  => x_shipment_rec.ATTRIBUTE20,
	    p_SHIPMENT_PRIORITY_CODE => x_shipment_rec.SHIPMENT_PRIORITY_CODE,
         p_SHIP_QUOTE_PRICE => x_shipment_rec.SHIP_QUOTE_PRICE,
	    p_SHIP_FROM_ORG_ID => x_shipment_rec.SHIP_FROM_ORG_ID,
	    p_SHIP_TO_CUST_PARTY_ID => x_shipment_rec.SHIP_TO_CUST_PARTY_ID,
         p_SHIP_METHOD_CODE_FROM     => x_shipment_rec.SHIP_METHOD_CODE_FROM,
         p_FREIGHT_TERMS_CODE_FROM  => x_shipment_rec.FREIGHT_TERMS_CODE_FROM,
	    P_OBJECT_VERSION_NUMBER => x_shipment_rec.OBJECT_VERSION_NUMBER,
         p_REQUEST_DATE_TYPE => x_shipment_rec.REQUEST_DATE_TYPE,
	    p_demand_class_code => x_shipment_rec.demand_class_code
);
	x_shipment_rec.SHIPMENT_ID := lx_shipment_id;
        x_shipment_rec.LAST_UPDATE_DATE := l_sysdate;

    END IF;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('After shipments.insert_rows - Insert Rows', 1, 'Y');
    END IF;

    IF lx_shipment_id IS NOT NULL and lx_shipment_id <> FND_API.G_MISS_NUM THEN
      x_freight_charge_tbl := p_freight_charge_tbl;
      FOR i IN 1..P_Freight_Charge_Tbl.count LOOP
	l_freight_charge_rec := p_freight_charge_tbl(i);
     -- BC4J Fix
	--x_FREIGHT_CHARGE_tbl(i).freight_charge_id := NULL;
    l_sysdate := sysdate;
	ASO_FREIGHT_CHARGES_PKG.Insert_Row(
	    px_FREIGHT_CHARGE_ID  => x_FREIGHT_CHARGE_tbl(i).freight_charge_id,
	    p_CREATION_DATE  => SYSDATE,
	    p_CREATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_DATE	=> l_sysdate,
	    p_LAST_UPDATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	    p_REQUEST_ID  => l_freight_charge_rec.REQUEST_ID,
	    p_PROGRAM_APPLICATION_ID  => l_freight_charge_rec.PROGRAM_APPLICATION_ID,
	    p_PROGRAM_ID  => l_freight_charge_rec.PROGRAM_ID,
	    p_PROGRAM_UPDATE_DATE  => l_freight_charge_rec.PROGRAM_UPDATE_DATE,
	    p_QUOTE_SHIPMENT_ID  => lx_SHIPMENT_ID,
	    p_FREIGHT_CHARGE_TYPE_ID  => l_freight_charge_rec.FREIGHT_CHARGE_TYPE_ID,
	    p_CHARGE_AMOUNT  => l_freight_charge_rec.CHARGE_AMOUNT,
	    p_ATTRIBUTE_CATEGORY  => l_freight_charge_rec.ATTRIBUTE_CATEGORY,
	    p_ATTRIBUTE1  => l_freight_charge_rec.ATTRIBUTE1,
	    p_ATTRIBUTE2  => l_freight_charge_rec.ATTRIBUTE2,
	    p_ATTRIBUTE3  => l_freight_charge_rec.ATTRIBUTE3,
	    p_ATTRIBUTE4  => l_freight_charge_rec.ATTRIBUTE4,
	    p_ATTRIBUTE5  => l_freight_charge_rec.ATTRIBUTE5,
	    p_ATTRIBUTE6  => l_freight_charge_rec.ATTRIBUTE6,
	    p_ATTRIBUTE7  => l_freight_charge_rec.ATTRIBUTE7,
	    p_ATTRIBUTE8  => l_freight_charge_rec.ATTRIBUTE8,
	    p_ATTRIBUTE9  => l_freight_charge_rec.ATTRIBUTE9,
	    p_ATTRIBUTE10  => l_freight_charge_rec.ATTRIBUTE10,
	    p_ATTRIBUTE11  => l_freight_charge_rec.ATTRIBUTE11,
	    p_ATTRIBUTE12  => l_freight_charge_rec.ATTRIBUTE12,
	    p_ATTRIBUTE13  => l_freight_charge_rec.ATTRIBUTE13,
	    p_ATTRIBUTE14  => l_freight_charge_rec.ATTRIBUTE14,
	    p_ATTRIBUTE15  => l_freight_charge_rec.ATTRIBUTE15);
	x_freight_charge_tbl(i).quote_shipment_id := lx_shipment_id;
    x_FREIGHT_CHARGE_tbl(i).LAST_UPDATE_DATE := l_sysdate;
      END LOOP;
    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('After Freight_charges.insert_rows - Insert Rows', 1, 'Y');
    END IF;

    x_tax_detail_tbl := p_tax_detail_tbl;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Insert Rows - tax.count: '||to_char(P_tax_detail_Tbl.count), 1, 'N');
    END IF;

    FOR i IN 1..P_tax_detail_Tbl.count LOOP
	l_tax_detail_rec := x_tax_detail_tbl(i);
     -- BC4J Fix
	--x_tax_detail_tbl(i).TAX_DETAIL_ID := NULL;
    l_sysdate := sysdate;
	ASO_TAX_DETAILS_PKG.Insert_Row(
	    px_TAX_DETAIL_ID  => x_tax_detail_tbl(i).TAX_DETAIL_ID,
	    p_CREATION_DATE  => SYSDATE,
	    p_CREATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_DATE	=> l_sysdate,
	    p_LAST_UPDATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	    p_REQUEST_ID  => l_tax_detail_rec.REQUEST_ID,
	    p_PROGRAM_APPLICATION_ID  => l_tax_detail_rec.PROGRAM_APPLICATION_ID,
	    p_PROGRAM_ID  => l_tax_detail_rec.PROGRAM_ID,
	    p_PROGRAM_UPDATE_DATE  => l_tax_detail_rec.PROGRAM_UPDATE_DATE,
	    p_QUOTE_HEADER_ID  => lx_Qte_HEADER_ID,
	    p_QUOTE_LINE_ID  => NULL,
	    p_QUOTE_SHIPMENT_ID  => lx_SHIPMENT_ID,
	    p_ORIG_TAX_CODE  => l_tax_detail_rec.ORIG_TAX_CODE,
	    p_TAX_CODE	=> l_tax_detail_rec.TAX_CODE,
	    p_TAX_RATE	=> l_tax_detail_rec.TAX_RATE,
	    p_TAX_DATE	=> l_tax_detail_rec.TAX_DATE,
	    p_TAX_AMOUNT  => l_tax_detail_rec.TAX_AMOUNT,
	    p_TAX_EXEMPT_FLAG  => l_tax_detail_rec.TAX_EXEMPT_FLAG,
	    p_TAX_EXEMPT_NUMBER  => l_tax_detail_rec.TAX_EXEMPT_NUMBER,
	    p_TAX_EXEMPT_REASON_CODE  => l_tax_detail_rec.TAX_EXEMPT_REASON_CODE,
	    p_ATTRIBUTE_CATEGORY  => l_tax_detail_rec.ATTRIBUTE_CATEGORY,
	    p_ATTRIBUTE1  => l_tax_detail_rec.ATTRIBUTE1,
	    p_ATTRIBUTE2  => l_tax_detail_rec.ATTRIBUTE2,
	    p_ATTRIBUTE3  => l_tax_detail_rec.ATTRIBUTE3,
	    p_ATTRIBUTE4  => l_tax_detail_rec.ATTRIBUTE4,
	    p_ATTRIBUTE5  => l_tax_detail_rec.ATTRIBUTE5,
	    p_ATTRIBUTE6  => l_tax_detail_rec.ATTRIBUTE6,
	    p_ATTRIBUTE7  => l_tax_detail_rec.ATTRIBUTE7,
	    p_ATTRIBUTE8  => l_tax_detail_rec.ATTRIBUTE8,
	    p_ATTRIBUTE9  => l_tax_detail_rec.ATTRIBUTE9,
	    p_ATTRIBUTE10  => l_tax_detail_rec.ATTRIBUTE10,
	    p_ATTRIBUTE11  => l_tax_detail_rec.ATTRIBUTE11,
	    p_ATTRIBUTE12  => l_tax_detail_rec.ATTRIBUTE12,
	    p_ATTRIBUTE13  => l_tax_detail_rec.ATTRIBUTE13,
	    p_ATTRIBUTE14  => l_tax_detail_rec.ATTRIBUTE14,
	    p_ATTRIBUTE15  => l_tax_detail_rec.ATTRIBUTE15,
	    p_ATTRIBUTE16  => l_tax_detail_rec.ATTRIBUTE16,
	    p_ATTRIBUTE17  => l_tax_detail_rec.ATTRIBUTE17,
	    p_ATTRIBUTE18  => l_tax_detail_rec.ATTRIBUTE18,
	    p_ATTRIBUTE19  => l_tax_detail_rec.ATTRIBUTE19,
	    p_ATTRIBUTE20  => l_tax_detail_rec.ATTRIBUTE20,
	    p_TAX_INCLUSIVE_FLAG  => l_tax_detail_rec.TAX_INCLUSIVE_FLAG,
	    p_OBJECT_VERSION_NUMBER => l_tax_detail_rec.OBJECT_VERSION_NUMBER,
	    p_TAX_RATE_ID => l_tax_detail_rec.TAX_RATE_ID
	    );
        x_tax_detail_tbl(i).LAST_UPDATE_DATE := l_sysdate;
    END LOOP;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('After tax_details.insert_rows - Insert Rows', 1, 'Y');
    END IF;

      FOR i in 1..p_Sales_Credit_Tbl.count LOOP

     l_Sales_Credit_rec := p_sales_credit_tbl(i);
     l_sales_credit_rec.quote_header_id := x_qte_header_rec.quote_header_id;
     x_sales_credit_tbl(i) := l_sales_credit_rec;
     -- BC4J Fix
     --x_sales_credit_tbl(i).sales_credit_id := NULL;
       ASO_SALES_CREDITS_PKG.Insert_Row(
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REQUEST_ID  => l_sales_CREDIT_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_sales_CREDIT_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_sales_CREDIT_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_sales_CREDIT_rec.PROGRAM_UPDATE_DATE,
          px_SALES_CREDIT_ID  => x_SALES_CREDIT_tbl(i).SALES_CREDIT_ID,
          p_QUOTE_HEADER_ID  => l_sales_CREDIT_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => l_sales_CREDIT_rec.QUOTE_LINE_ID,
          p_PERCENT  => l_sales_CREDIT_rec.PERCENT,
          p_RESOURCE_ID  => l_sales_CREDIT_rec.RESOURCE_ID,
          p_RESOURCE_GROUP_ID  => l_sales_CREDIT_rec.RESOURCE_GROUP_ID,
          p_EMPLOYEE_PERSON_ID  => l_sales_CREDIT_rec.EMPLOYEE_PERSON_ID,
          p_SALES_CREDIT_TYPE_ID  => l_sales_CREDIT_rec.SALES_CREDIT_TYPE_ID,
--          p_SECURITY_GROUP_ID  => l_sales_CREDIT_rec.SECURITY_GROUP_ID,
          p_ATTRIBUTE_CATEGORY_CODE  => l_sales_CREDIT_rec.ATTRIBUTE_CATEGORY_CODE,
          p_ATTRIBUTE1  => l_sales_CREDIT_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_sales_CREDIT_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_sales_CREDIT_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_sales_CREDIT_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_sales_CREDIT_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_sales_CREDIT_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_sales_CREDIT_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_sales_CREDIT_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_sales_CREDIT_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_sales_CREDIT_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_sales_CREDIT_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_sales_CREDIT_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_sales_CREDIT_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_sales_CREDIT_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_sales_CREDIT_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  => l_sales_CREDIT_rec.ATTRIBUTE16,
		p_ATTRIBUTE17  => l_sales_CREDIT_rec.ATTRIBUTE17,
		p_ATTRIBUTE18  => l_sales_CREDIT_rec.ATTRIBUTE18,
		p_ATTRIBUTE19  => l_sales_CREDIT_rec.ATTRIBUTE19,
		p_ATTRIBUTE20  => l_sales_CREDIT_rec.ATTRIBUTE20,
		p_SYSTEM_ASSIGNED_FLAG  => 'N',
          p_CREDIT_RULE_ID  => l_sales_CREDIT_rec.CREDIT_RULE_ID,
          p_OBJECT_VERSION_NUMBER  => l_sales_CREDIT_rec.OBJECT_VERSION_NUMBER);

END LOOP;


-- insert into quote party table
 IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('Insert Rows - Quote_party.count: ' || p_quote_party_Tbl.count, 1, 'N');
 aso_debug_pub.add('Insert Rows - Quote_party header: '|| x_qte_header_rec.quote_header_id, 1, 'N');
 END IF;

 FOR i IN 1..p_quote_party_Tbl.count LOOP
	l_quote_party_rec := p_quote_party_tbl(i);
       -- l_quote_party_rec.quote_line_id :=  x_qte_line_rec.QUOTE_LINE_ID;
        l_quote_party_rec.quote_header_id := x_qte_header_rec.quote_header_id;
        x_quote_party_tbl(i) := l_quote_party_rec;
        -- BC4J Fix
        --x_quote_party_tbl(i).QUOTE_PARTY_ID := NULL;

           ASO_QUOTE_PARTIES_PKG.Insert_Row(
          px_QUOTE_PARTY_ID  => x_quote_party_tbl(i).QUOTE_PARTY_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_REQUEST_ID  => l_QUOTE_PARTY_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  =>l_QUOTE_PARTY_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_QUOTE_PARTY_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_QUOTE_PARTY_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID  => l_QUOTE_PARTY_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => l_QUOTE_PARTY_rec.QUOTE_LINE_ID,
          p_QUOTE_SHIPMENT_ID  => l_QUOTE_PARTY_rec.QUOTE_SHIPMENT_ID,
          p_PARTY_TYPE  => l_QUOTE_PARTY_rec.PARTY_TYPE,
          p_PARTY_ID  => l_QUOTE_PARTY_rec.PARTY_ID,
          p_PARTY_OBJECT_TYPE  => l_QUOTE_PARTY_rec.PARTY_OBJECT_TYPE,
          p_PARTY_OBJECT_ID  => l_QUOTE_PARTY_rec.PARTY_OBJECT_ID,
          p_ATTRIBUTE_CATEGORY  => l_QUOTE_PARTY_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_QUOTE_PARTY_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_QUOTE_PARTY_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_QUOTE_PARTY_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_QUOTE_PARTY_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_QUOTE_PARTY_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_QUOTE_PARTY_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_QUOTE_PARTY_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_QUOTE_PARTY_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_QUOTE_PARTY_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_QUOTE_PARTY_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_QUOTE_PARTY_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_QUOTE_PARTY_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_QUOTE_PARTY_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_QUOTE_PARTY_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_QUOTE_PARTY_rec.ATTRIBUTE15,
  --          p_SECURITY_GROUP_ID  => p_QUOTE_PARTY_rec.SECURITY_GROUP_ID);
        p_OBJECT_VERSION_NUMBER  => l_QUOTE_PARTY_rec.OBJECT_VERSION_NUMBER);

 END LOOP;


    FOR i IN 1..P_hd_Attr_Ext_tbl.count LOOP
	l_line_attribs_rec := P_hd_Attr_Ext_Tbl(i);
        l_line_attribs_rec.quote_header_id :=  x_qte_header_rec.QUOTE_HEADER_ID;
        X_hd_Attr_Ext_Tbl(i) := l_line_attribs_rec;
        -- BC4J Fix
	   --X_hd_Attr_Ext_Tbl(i).LINE_ATTRIBUTE_ID := NULL;

 ASO_QUOTE_LINE_ATTRIBS_EXT_PKG.Insert_Row(
          px_LINE_ATTRIBUTE_ID  => x_hd_Attr_Ext_Tbl(i).LINE_ATTRIBUTE_ID,
          p_CREATION_DATE          => SYSDATE,
          p_CREATED_BY             => G_USER_ID,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_LAST_UPDATED_BY        => G_USER_ID,
          p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
          p_REQUEST_ID             => l_LINE_ATTRIBS_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID =>l_LINE_ATTRIBS_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID             => l_LINE_ATTRIBS_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE    => l_LINE_ATTRIBS_rec.PROGRAM_UPDATE_DATE,
           p_APPLICATION_ID         => l_LINE_ATTRIBS_rec.APPLICATION_ID,
          p_STATUS                 => l_LINE_ATTRIBS_rec.STATUS,
          p_QUOTE_HEADER_ID        => l_LINE_ATTRIBS_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID          => l_LINE_ATTRIBS_rec.QUOTE_LINE_ID,
          p_QUOTE_SHIPMENT_ID      => l_LINE_ATTRIBS_rec.QUOTE_SHIPMENT_ID,
          p_ATTRIBUTE_TYPE_CODE    => l_LINE_ATTRIBS_rec.ATTRIBUTE_TYPE_CODE,
          p_NAME                   => l_LINE_ATTRIBS_rec.NAME,
          p_VALUE                  => l_LINE_ATTRIBS_rec.VALUE,
           p_VALUE_TYPE             => l_LINE_ATTRIBS_rec.VALUE_TYPE,
          p_START_DATE_ACTIVE      => l_LINE_ATTRIBS_rec.START_DATE_ACTIVE,
          p_END_DATE_ACTIVE        => l_LINE_ATTRIBS_rec.END_DATE_ACTIVE,
		p_OBJECT_VERSION_NUMBER  => l_LINE_ATTRIBS_rec.OBJECT_VERSION_NUMBER);
END LOOP;



 -- check for duplicate promotions, see bug 4521799
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Before  calling Validate_Promotion price_attr_tbl.count: '|| p_price_attributes_tbl.count, 1, 'Y');
  END IF;

  ASO_VALIDATE_PVT.Validate_Promotion (
     P_Api_Version_Number       => 1.0,
     P_Init_Msg_List            => FND_API.G_FALSE,
     P_Commit                   => FND_API.G_FALSE,
     p_price_attr_tbl           => p_price_attributes_tbl,
     x_price_attr_tbl           => lx_price_attr_tbl,
     x_return_status            => x_return_status,
     x_msg_count                => x_msg_count,
     x_msg_data                 => x_msg_data);

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('after calling Validate_Promotion ', 1, 'Y');
      aso_debug_pub.add('Validate_Promotion  Return Status: '||x_return_status, 1, 'Y');
   END IF;

   if x_return_status <> fnd_api.g_ret_sts_success then
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   end if;


 -- end of check for duplicate promotions



-- added by hagrawal

FOR i in 1..p_price_attributes_tbl.count LOOP

     l_price_attributes_rec := p_price_attributes_tbl(i);
      l_price_attributes_rec.quote_header_id := x_qte_header_rec.quote_header_id;
     x_price_attributes_tbl(i) := l_price_attributes_rec;
     -- BC4J Fix
--x_price_attributes_tbl(i).price_attribute_id := NULL;
ASO_PRICE_ATTRIBUTES_PKG.Insert_Row(
          px_PRICE_ATTRIBUTE_ID   => x_price_attributes_tbl(i).price_attribute_id,
          p_CREATION_DATE         => SYSDATE,
          p_CREATED_BY            => G_USER_ID,
          p_LAST_UPDATE_DATE      => SYSDATE,
          p_LAST_UPDATED_BY       => G_USER_ID,
          p_LAST_UPDATE_LOGIN     => G_LOGIN_ID,
          p_REQUEST_ID            => l_price_attributes_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_price_attributes_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID           => l_price_attributes_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_price_attributes_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID      => l_price_attributes_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID        => l_price_attributes_rec.quote_line_id,
          p_FLEX_TITLE           => l_price_attributes_rec.flex_title,
          p_PRICING_CONTEXT      => l_price_attributes_rec.pricing_context,
          p_PRICING_ATTRIBUTE1    => l_price_attributes_rec.PRICING_ATTRIBUTE1,
          p_PRICING_ATTRIBUTE2    => l_price_attributes_rec.PRICING_ATTRIBUTE2,
          p_PRICING_ATTRIBUTE3    => l_price_attributes_rec.PRICING_ATTRIBUTE3,
          p_PRICING_ATTRIBUTE4    => l_price_attributes_rec.PRICING_ATTRIBUTE4,
          p_PRICING_ATTRIBUTE5    => l_price_attributes_rec.PRICING_ATTRIBUTE5,
          p_PRICING_ATTRIBUTE6    => l_price_attributes_rec.PRICING_ATTRIBUTE6,
          p_PRICING_ATTRIBUTE7    => l_price_attributes_rec.PRICING_ATTRIBUTE7,
          p_PRICING_ATTRIBUTE8    => l_price_attributes_rec.PRICING_ATTRIBUTE8,
          p_PRICING_ATTRIBUTE9    => l_price_attributes_rec.PRICING_ATTRIBUTE9,
        p_PRICING_ATTRIBUTE10    => l_price_attributes_rec.PRICING_ATTRIBUTE10,
        p_PRICING_ATTRIBUTE11    => l_price_attributes_rec.PRICING_ATTRIBUTE11,
        p_PRICING_ATTRIBUTE12    => l_price_attributes_rec.PRICING_ATTRIBUTE12,
        p_PRICING_ATTRIBUTE13    => l_price_attributes_rec.PRICING_ATTRIBUTE13,
        p_PRICING_ATTRIBUTE14    => l_price_attributes_rec.PRICING_ATTRIBUTE14,
        p_PRICING_ATTRIBUTE15    => l_price_attributes_rec.PRICING_ATTRIBUTE15,
        p_PRICING_ATTRIBUTE16    => l_price_attributes_rec.PRICING_ATTRIBUTE16,
        p_PRICING_ATTRIBUTE17    => l_price_attributes_rec.PRICING_ATTRIBUTE17,
        p_PRICING_ATTRIBUTE18    => l_price_attributes_rec.PRICING_ATTRIBUTE18,
        p_PRICING_ATTRIBUTE19    => l_price_attributes_rec.PRICING_ATTRIBUTE19,
        p_PRICING_ATTRIBUTE20    => l_price_attributes_rec.PRICING_ATTRIBUTE20,
        p_PRICING_ATTRIBUTE21    => l_price_attributes_rec.PRICING_ATTRIBUTE21,
        p_PRICING_ATTRIBUTE22    => l_price_attributes_rec.PRICING_ATTRIBUTE22,
        p_PRICING_ATTRIBUTE23    => l_price_attributes_rec.PRICING_ATTRIBUTE23,
        p_PRICING_ATTRIBUTE24    => l_price_attributes_rec.PRICING_ATTRIBUTE24,
        p_PRICING_ATTRIBUTE25    => l_price_attributes_rec.PRICING_ATTRIBUTE25,
        p_PRICING_ATTRIBUTE26    => l_price_attributes_rec.PRICING_ATTRIBUTE26,
        p_PRICING_ATTRIBUTE27    => l_price_attributes_rec.PRICING_ATTRIBUTE27,
        p_PRICING_ATTRIBUTE28    => l_price_attributes_rec.PRICING_ATTRIBUTE28,
        p_PRICING_ATTRIBUTE29    => l_price_attributes_rec.PRICING_ATTRIBUTE29,
        p_PRICING_ATTRIBUTE30    => l_price_attributes_rec.PRICING_ATTRIBUTE30,
        p_PRICING_ATTRIBUTE31    => l_price_attributes_rec.PRICING_ATTRIBUTE31,
        p_PRICING_ATTRIBUTE32    => l_price_attributes_rec.PRICING_ATTRIBUTE32,
        p_PRICING_ATTRIBUTE33    => l_price_attributes_rec.PRICING_ATTRIBUTE33,
        p_PRICING_ATTRIBUTE34    => l_price_attributes_rec.PRICING_ATTRIBUTE34,
        p_PRICING_ATTRIBUTE35    => l_price_attributes_rec.PRICING_ATTRIBUTE35,
        p_PRICING_ATTRIBUTE36    => l_price_attributes_rec.PRICING_ATTRIBUTE36,
        p_PRICING_ATTRIBUTE37    => l_price_attributes_rec.PRICING_ATTRIBUTE37,
        p_PRICING_ATTRIBUTE38    => l_price_attributes_rec.PRICING_ATTRIBUTE38,
        p_PRICING_ATTRIBUTE39    => l_price_attributes_rec.PRICING_ATTRIBUTE39,
        p_PRICING_ATTRIBUTE40    => l_price_attributes_rec.PRICING_ATTRIBUTE40,
        p_PRICING_ATTRIBUTE41    => l_price_attributes_rec.PRICING_ATTRIBUTE41,
        p_PRICING_ATTRIBUTE42    => l_price_attributes_rec.PRICING_ATTRIBUTE42,
        p_PRICING_ATTRIBUTE43    => l_price_attributes_rec.PRICING_ATTRIBUTE43,
        p_PRICING_ATTRIBUTE44    => l_price_attributes_rec.PRICING_ATTRIBUTE44,
        p_PRICING_ATTRIBUTE45    => l_price_attributes_rec.PRICING_ATTRIBUTE45,
        p_PRICING_ATTRIBUTE46    => l_price_attributes_rec.PRICING_ATTRIBUTE46,
        p_PRICING_ATTRIBUTE47    => l_price_attributes_rec.PRICING_ATTRIBUTE47,
        p_PRICING_ATTRIBUTE48    => l_price_attributes_rec.PRICING_ATTRIBUTE48,
        p_PRICING_ATTRIBUTE49    => l_price_attributes_rec.PRICING_ATTRIBUTE49,
        p_PRICING_ATTRIBUTE50    => l_price_attributes_rec.PRICING_ATTRIBUTE50,
        p_PRICING_ATTRIBUTE51    => l_price_attributes_rec.PRICING_ATTRIBUTE51,
        p_PRICING_ATTRIBUTE52    => l_price_attributes_rec.PRICING_ATTRIBUTE52,
        p_PRICING_ATTRIBUTE53    => l_price_attributes_rec.PRICING_ATTRIBUTE53,
        p_PRICING_ATTRIBUTE54    => l_price_attributes_rec.PRICING_ATTRIBUTE54,
        p_PRICING_ATTRIBUTE55    => l_price_attributes_rec.PRICING_ATTRIBUTE55,
        p_PRICING_ATTRIBUTE56    => l_price_attributes_rec.PRICING_ATTRIBUTE56,
        p_PRICING_ATTRIBUTE57    => l_price_attributes_rec.PRICING_ATTRIBUTE57,
        p_PRICING_ATTRIBUTE58    => l_price_attributes_rec.PRICING_ATTRIBUTE58,
        p_PRICING_ATTRIBUTE59    => l_price_attributes_rec.PRICING_ATTRIBUTE59,
        p_PRICING_ATTRIBUTE60    => l_price_attributes_rec.PRICING_ATTRIBUTE60,
        p_PRICING_ATTRIBUTE61    => l_price_attributes_rec.PRICING_ATTRIBUTE61,
        p_PRICING_ATTRIBUTE62    => l_price_attributes_rec.PRICING_ATTRIBUTE62,
        p_PRICING_ATTRIBUTE63    => l_price_attributes_rec.PRICING_ATTRIBUTE63,
        p_PRICING_ATTRIBUTE64    => l_price_attributes_rec.PRICING_ATTRIBUTE64,
        p_PRICING_ATTRIBUTE65    => l_price_attributes_rec.PRICING_ATTRIBUTE65,
        p_PRICING_ATTRIBUTE66    => l_price_attributes_rec.PRICING_ATTRIBUTE66,
        p_PRICING_ATTRIBUTE67    => l_price_attributes_rec.PRICING_ATTRIBUTE67,
        p_PRICING_ATTRIBUTE68    => l_price_attributes_rec.PRICING_ATTRIBUTE68,
        p_PRICING_ATTRIBUTE69    => l_price_attributes_rec.PRICING_ATTRIBUTE69,
        p_PRICING_ATTRIBUTE70    => l_price_attributes_rec.PRICING_ATTRIBUTE70,
        p_PRICING_ATTRIBUTE71    => l_price_attributes_rec.PRICING_ATTRIBUTE71,
        p_PRICING_ATTRIBUTE72    => l_price_attributes_rec.PRICING_ATTRIBUTE72,
        p_PRICING_ATTRIBUTE73    => l_price_attributes_rec.PRICING_ATTRIBUTE73,
        p_PRICING_ATTRIBUTE74    => l_price_attributes_rec.PRICING_ATTRIBUTE74,
        p_PRICING_ATTRIBUTE75    => l_price_attributes_rec.PRICING_ATTRIBUTE75,
        p_PRICING_ATTRIBUTE76    => l_price_attributes_rec.PRICING_ATTRIBUTE76,
        p_PRICING_ATTRIBUTE77    => l_price_attributes_rec.PRICING_ATTRIBUTE77,
        p_PRICING_ATTRIBUTE78    => l_price_attributes_rec.PRICING_ATTRIBUTE78,
        p_PRICING_ATTRIBUTE79    => l_price_attributes_rec.PRICING_ATTRIBUTE79,
        p_PRICING_ATTRIBUTE80    => l_price_attributes_rec.PRICING_ATTRIBUTE80,
        p_PRICING_ATTRIBUTE81    => l_price_attributes_rec.PRICING_ATTRIBUTE81,
        p_PRICING_ATTRIBUTE82    => l_price_attributes_rec.PRICING_ATTRIBUTE82,
        p_PRICING_ATTRIBUTE83    => l_price_attributes_rec.PRICING_ATTRIBUTE83,
        p_PRICING_ATTRIBUTE84    => l_price_attributes_rec.PRICING_ATTRIBUTE84,
        p_PRICING_ATTRIBUTE85    => l_price_attributes_rec.PRICING_ATTRIBUTE85,
        p_PRICING_ATTRIBUTE86    => l_price_attributes_rec.PRICING_ATTRIBUTE86,
        p_PRICING_ATTRIBUTE87    => l_price_attributes_rec.PRICING_ATTRIBUTE87,
        p_PRICING_ATTRIBUTE88    => l_price_attributes_rec.PRICING_ATTRIBUTE88,
        p_PRICING_ATTRIBUTE89    => l_price_attributes_rec.PRICING_ATTRIBUTE89,
        p_PRICING_ATTRIBUTE90    => l_price_attributes_rec.PRICING_ATTRIBUTE90,
        p_PRICING_ATTRIBUTE91    => l_price_attributes_rec.PRICING_ATTRIBUTE91,
        p_PRICING_ATTRIBUTE92    => l_price_attributes_rec.PRICING_ATTRIBUTE92,
        p_PRICING_ATTRIBUTE93    => l_price_attributes_rec.PRICING_ATTRIBUTE93,
        p_PRICING_ATTRIBUTE94    => l_price_attributes_rec.PRICING_ATTRIBUTE94,
        p_PRICING_ATTRIBUTE95    => l_price_attributes_rec.PRICING_ATTRIBUTE95,
        p_PRICING_ATTRIBUTE96    => l_price_attributes_rec.PRICING_ATTRIBUTE96,
        p_PRICING_ATTRIBUTE97    => l_price_attributes_rec.PRICING_ATTRIBUTE97,
        p_PRICING_ATTRIBUTE98    => l_price_attributes_rec.PRICING_ATTRIBUTE98,
        p_PRICING_ATTRIBUTE99    => l_price_attributes_rec.PRICING_ATTRIBUTE99,
        p_PRICING_ATTRIBUTE100  => l_price_attributes_rec.PRICING_ATTRIBUTE100,
          p_CONTEXT    => l_price_attributes_rec.CONTEXT,
          p_ATTRIBUTE1    => l_price_attributes_rec.ATTRIBUTE1,
          p_ATTRIBUTE2    => l_price_attributes_rec.ATTRIBUTE2,
          p_ATTRIBUTE3    => l_price_attributes_rec.ATTRIBUTE3,
          p_ATTRIBUTE4    => l_price_attributes_rec.ATTRIBUTE4,
          p_ATTRIBUTE5    => l_price_attributes_rec.ATTRIBUTE5,
          p_ATTRIBUTE6    => l_price_attributes_rec.ATTRIBUTE6,
          p_ATTRIBUTE7    => l_price_attributes_rec.ATTRIBUTE7,
          p_ATTRIBUTE8    => l_price_attributes_rec.ATTRIBUTE8,
          p_ATTRIBUTE9    => l_price_attributes_rec.ATTRIBUTE9,
          p_ATTRIBUTE10    => l_price_attributes_rec.ATTRIBUTE10,
          p_ATTRIBUTE11    => l_price_attributes_rec.ATTRIBUTE11,
          p_ATTRIBUTE12    => l_price_attributes_rec.ATTRIBUTE12,
          p_ATTRIBUTE13    => l_price_attributes_rec.ATTRIBUTE13,
          p_ATTRIBUTE14    => l_price_attributes_rec.ATTRIBUTE14,
          p_ATTRIBUTE15    => l_price_attributes_rec.ATTRIBUTE15,
	     p_ATTRIBUTE16    => l_price_attributes_rec.ATTRIBUTE16,
		p_ATTRIBUTE17    => l_price_attributes_rec.ATTRIBUTE17,
		p_ATTRIBUTE18    => l_price_attributes_rec.ATTRIBUTE18,
		p_ATTRIBUTE19    => l_price_attributes_rec.ATTRIBUTE19,
		p_ATTRIBUTE20    => l_price_attributes_rec.ATTRIBUTE20,
		p_OBJECT_VERSION_NUMBER => l_price_attributes_rec.OBJECT_VERSION_NUMBER
);

END LOOP;

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Insert_Rows: l_qte_access_tbl.count: '||l_qte_access_tbl.count, 1, 'Y');
       END IF;

       for i in 1 .. l_qte_access_tbl.count loop
           l_qte_access_tbl(i).quote_number     := p_qte_header_rec.quote_number;
           l_qte_access_tbl(i).batch_price_flag := fnd_api.g_false;
       end loop;

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Insert_Rows: Before call to Add_Resource', 1, 'Y');
       END IF;

	  if l_qte_access_tbl.count > 0 then

           ASO_SECURITY_INT.Add_Resource(
                   P_INIT_MSG_LIST              => FND_API.G_FALSE,
                   P_COMMIT                     => FND_API.G_FALSE,
                   P_Qte_Access_tbl             => l_qte_access_tbl,
			    p_call_from_oafwk_flag       => FND_API.G_TRUE,
                   X_Qte_Access_tbl             => x_qte_access_tbl,
                   X_RETURN_STATUS              => x_return_status,
                   X_msg_count                  => X_msg_count,
                   X_msg_data                   => X_msg_data );

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Insert_Rows: After call to Add_Resource: x_return_status: '||x_return_status, 1, 'Y');
           END IF;

	  end if;

END Insert_Rows;


PROCEDURE Update_Rows (
    P_qte_Header_Rec        IN   ASO_QUOTE_PUB.qte_header_rec_Type,
    p_Price_Attributes_Tbl  IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    P_Price_Adjustment_Tbl  IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    P_Price_Adj_Attr_Tbl    IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    P_Payment_Tbl           IN   ASO_QUOTE_PUB.Payment_Tbl_Type,
    P_Shipment_Tbl          IN   ASO_QUOTE_PUB.Shipment_Tbl_Type,
    P_Freight_Charge_Tbl    IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    P_Tax_Detail_Tbl        IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    P_hd_Attr_Ext_Tbl       IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    P_Sales_Credit_Tbl      IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    P_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    P_Qte_Access_Tbl        IN   ASO_QUOTE_PUB.Qte_Access_Tbl_Type,
    X_qte_Header_Rec        OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.qte_header_rec_Type,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    X_Price_Adjustment_Tbl  OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    x_Price_Adj_Attr_Tbl	   OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Payment_Tbl		   OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_Shipment_Tbl		   OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_Freight_Charge_Tbl	   OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl       OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    X_Qte_Access_Tbl        OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Access_Tbl_Type,
    X_Return_Status	        OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data	             OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
    l_price_adj_rec		   ASO_QUOTE_PUB.Price_Adj_Rec_Type;
    l_payment_rec		   ASO_QUOTE_PUB.Payment_Rec_Type;
    l_shipment_rec		   ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_freight_charge_rec	   ASO_QUOTE_PUB.Freight_Charge_Rec_Type;
    l_tax_detail_rec        ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
    l_price_adj_attr_rec	   ASO_QUOTE_PUB.Price_Adj_Attr_Rec_Type;
    l_price_adj_attr_tbl	   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    l_freight_charge_tbl	   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    l_Sales_Credit_Tbl      ASO_QUOTE_PUB.Sales_Credit_Tbl_Type ;
    l_Quote_Party_Tbl       ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
    l_Sales_Credit_rec      ASO_QUOTE_PUB.Sales_Credit_rec_Type ;
    l_Quote_Party_rec       ASO_QUOTE_PUB.Quote_Party_rec_Type;
    l_price_attributes_rec  ASO_QUOTE_PUB.Price_Attributes_Rec_Type;
    l_line_attribs_rec      ASO_QUOTE_PUB.Line_Attribs_Ext_rec_Type;
    l_qte_access_tbl        ASO_QUOTE_PUB.Qte_Access_Tbl_Type;
    lx_qte_access_tbl       ASO_QUOTE_PUB.Qte_Access_Tbl_Type;

    l_sysdate DATE ;
    l_qte_header_id		   NUMBER  := p_qte_header_rec.quote_header_id;
   l_payment_tbl            ASO_QUOTE_PUB.Payment_Tbl_Type;
    G_USER_ID	             NUMBER  := FND_GLOBAL.USER_ID;
    G_LOGIN_ID	             NUMBER  := FND_GLOBAL.CONC_LOGIN_ID;
    l_qte_hdr_rec           ASO_QUOTE_PUB.qte_header_rec_Type;
    lx_price_attr_tbl       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;


-- The following cursor is needed for Payment From column Maintenance.
    CURSOR c_db_payment_terms(p_payment_id  NUMBER) IS
    SELECT payment_term_id_from,payment_term_id
    FROM   ASO_PAYMENTS
    WHERE  payment_id = p_payment_id;

-- The following cursors is needed for ship_method_code and Freight Terms Code From column Maintenance.
    CURSOR c_db_ship_freight_terms(p_shipment_id  NUMBER) IS
    SELECT ship_method_code_from,ship_method_code,
    Freight_terms_code_from,Freight_terms_code
    FROM   ASO_SHIPMENTS
    WHERE  shipment_id = p_shipment_id;

    cursor c_quote_number is
    select quote_number from aso_quote_headers_all
    where quote_header_id = p_qte_header_rec.quote_header_id;

    cursor get_payment_type_code( l_payment_id Number) is
    select payment_type_code
    from aso_payments
    where payment_id = l_payment_id;

    cursor get_bill_to_party( l_qte_hdr_id Number) is
    select invoice_to_cust_party_id
    from aso_quote_headers_all
    where quote_header_id = l_qte_hdr_id;

    -- Refer bug 10217258
     ct               NUMBER;
    p_price_req_code VARCHAR2(100);

BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    x_qte_header_rec := p_qte_header_rec;
    l_sysdate := sysdate;
    x_qte_header_rec.last_update_date := l_sysdate;
	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add('Begin Update Rows', 1, 'Y');
	 END IF;

    -- Validate the invoice to cust party id and payment info, if any
     IF p_payment_tbl.count = 0  then
       l_payment_tbl := aso_utility_pvt.Query_Payment_Rows( p_qte_header_rec.QUOTE_HEADER_ID,null);
	Else
	  l_payment_tbl := p_payment_tbl;
	  -- check to see if the value has been changed, if not get orig value from db
	  if l_payment_tbl(1).payment_type_code = fnd_api.g_miss_char then
	   open get_payment_type_code(l_payment_tbl(1).payment_id);
	   fetch get_payment_type_code into l_payment_tbl(1).payment_type_code;
	   close get_payment_type_code;
	  end if;
	End if;
	-- bill to customer may not have been changed, if so get orig value from db
	l_qte_hdr_rec := p_qte_header_rec;
	if l_qte_hdr_rec.invoice_to_cust_party_id = fnd_api.g_miss_num then
	 open get_bill_to_party(l_qte_hdr_rec.quote_header_id);
	 fetch get_bill_to_party into l_qte_hdr_rec.invoice_to_cust_party_id;
	 close get_bill_to_party;
	end if;

	IF l_payment_tbl.count > 0 then
          l_payment_rec := l_payment_tbl(1);
        IF l_payment_rec.payment_type_code = 'CREDIT_CARD' THEN
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before  calling Validate_cc_info ', 1, 'Y');
           END IF;
           aso_validate_pvt.Validate_cc_info
            (
                p_init_msg_list     =>  fnd_api.g_false,
                p_payment_rec       =>  l_payment_rec,
                p_qte_header_rec    =>  l_qte_hdr_rec,
                P_Qte_Line_rec      =>  ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC,
                x_return_status     =>  x_return_status,
                x_msg_count         =>  x_msg_count,
                x_msg_data          =>  x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('after calling Validate_cc_info ', 1, 'Y');
              aso_debug_pub.add('Validate_cc_info  Return Status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;
        END IF;

	 End if;


    ASO_QUOTE_HEADERS_PKG.Update_Row(
	  p_QUOTE_HEADER_ID  => p_qte_header_rec.QUOTE_HEADER_ID,
	  p_CREATION_DATE  => p_qte_header_rec.creation_date,
	  p_CREATED_BY	=> G_USER_ID,
	  p_LAST_UPDATE_DATE  => l_sysdate,
	  p_LAST_UPDATED_BY  => G_USER_ID,
	  p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	  p_REQUEST_ID	=> p_qte_header_rec.REQUEST_ID,
	  p_PROGRAM_APPLICATION_ID  => p_qte_header_rec.PROGRAM_APPLICATION_ID,
	  p_PROGRAM_ID	=> p_qte_header_rec.PROGRAM_ID,
	  p_PROGRAM_UPDATE_DATE  => p_qte_header_rec.PROGRAM_UPDATE_DATE,
	  p_ORG_ID  => p_qte_header_rec.ORG_ID,
	  p_QUOTE_NAME	=> p_qte_header_rec.QUOTE_NAME,
	  p_QUOTE_NUMBER  => p_qte_header_rec.QUOTE_NUMBER,
	  p_QUOTE_VERSION  => p_qte_header_rec.QUOTE_VERSION,
	  p_QUOTE_STATUS_ID  => p_qte_header_rec.QUOTE_STATUS_ID,
	  p_QUOTE_SOURCE_CODE  => p_qte_header_rec.QUOTE_SOURCE_CODE,
	  p_QUOTE_EXPIRATION_DATE  => trunc(p_qte_header_rec.QUOTE_EXPIRATION_DATE),
	  p_PRICE_FROZEN_DATE  => p_qte_header_rec.PRICE_FROZEN_DATE,
	  p_QUOTE_PASSWORD  => p_qte_header_rec.QUOTE_PASSWORD,
	  p_ORIGINAL_SYSTEM_REFERENCE  => p_qte_header_rec.ORIGINAL_SYSTEM_REFERENCE,
	  p_PARTY_ID  => p_qte_header_rec.PARTY_ID,
	  p_CUST_ACCOUNT_ID  => p_qte_header_rec.CUST_ACCOUNT_ID,
	  p_ORG_CONTACT_ID  => p_qte_header_rec.ORG_CONTACT_ID,
	  p_PHONE_ID  => p_QTE_header_rec.PHONE_ID,
	  p_INVOICE_TO_PARTY_SITE_ID  => p_qte_header_rec.INVOICE_TO_PARTY_SITE_ID,
	  p_INVOICE_TO_PARTY_ID  => p_qte_header_rec.INVOICE_TO_PARTY_ID,
       p_Invoice_to_CUST_ACCOUNT_ID  => p_qte_header_rec.Invoice_to_CUST_ACCOUNT_ID,
	  p_ORIG_MKTG_SOURCE_CODE_ID  => p_qte_header_rec.ORIG_MKTG_SOURCE_CODE_ID,
	  p_MARKETING_SOURCE_CODE_ID  => p_qte_header_rec.MARKETING_SOURCE_CODE_ID,
	  p_ORDER_TYPE_ID  => p_qte_header_rec.ORDER_TYPE_ID,
	  p_QUOTE_CATEGORY_CODE  => p_qte_header_rec.QUOTE_CATEGORY_CODE,
	  p_ORDERED_DATE  => p_qte_header_rec.ORDERED_DATE,
	  p_ACCOUNTING_RULE_ID	=> p_qte_header_rec.ACCOUNTING_RULE_ID,
	  p_INVOICING_RULE_ID  => p_qte_header_rec.INVOICING_RULE_ID,
	  p_EMPLOYEE_PERSON_ID	=> p_qte_header_rec.EMPLOYEE_PERSON_ID,
	  p_PRICE_LIST_ID  => p_qte_header_rec.PRICE_LIST_ID,
	  p_CURRENCY_CODE  => p_qte_header_rec.CURRENCY_CODE,
	  p_TOTAL_LIST_PRICE  => p_qte_header_rec.TOTAL_LIST_PRICE,
	  p_TOTAL_ADJUSTED_AMOUNT  => p_qte_header_rec.TOTAL_ADJUSTED_AMOUNT,
	  p_TOTAL_ADJUSTED_PERCENT  => p_qte_header_rec.TOTAL_ADJUSTED_PERCENT,
	  p_TOTAL_TAX  => p_qte_header_rec.TOTAL_TAX,
	  p_TOTAL_SHIPPING_CHARGE  => p_qte_header_rec.TOTAL_SHIPPING_CHARGE,
	  p_SURCHARGE  => p_qte_header_rec.SURCHARGE,
	  p_TOTAL_QUOTE_PRICE  => p_qte_header_rec.TOTAL_QUOTE_PRICE,
	  p_PAYMENT_AMOUNT  => p_qte_header_rec.PAYMENT_AMOUNT,
	  p_EXCHANGE_RATE  => p_qte_header_rec.EXCHANGE_RATE,
	  p_EXCHANGE_TYPE_CODE	=> p_qte_header_rec.EXCHANGE_TYPE_CODE,
	  p_EXCHANGE_RATE_DATE	=> p_qte_header_rec.EXCHANGE_RATE_DATE,
	  p_CONTRACT_ID  => p_qte_header_rec.CONTRACT_ID,
	  p_SALES_CHANNEL_CODE	=> p_qte_header_rec.SALES_CHANNEL_CODE,
	  p_ORDER_ID  => p_QTE_header_rec.ORDER_ID,
	  p_RESOURCE_ID => p_qte_header_rec.RESOURCE_ID,
	  p_ATTRIBUTE_CATEGORY	=> p_qte_header_rec.ATTRIBUTE_CATEGORY,
	  p_ATTRIBUTE1	=> p_qte_header_rec.ATTRIBUTE1,
	  p_ATTRIBUTE2	=> p_qte_header_rec.ATTRIBUTE2,
	  p_ATTRIBUTE3	=> p_qte_header_rec.ATTRIBUTE3,
	  p_ATTRIBUTE4	=> p_qte_header_rec.ATTRIBUTE4,
	  p_ATTRIBUTE5	=> p_qte_header_rec.ATTRIBUTE5,
	  p_ATTRIBUTE6	=> p_qte_header_rec.ATTRIBUTE6,
	  p_ATTRIBUTE7	=> p_qte_header_rec.ATTRIBUTE7,
	  p_ATTRIBUTE8	=> p_qte_header_rec.ATTRIBUTE8,
	  p_ATTRIBUTE9	=> p_qte_header_rec.ATTRIBUTE9,
	  p_ATTRIBUTE10  => p_qte_header_rec.ATTRIBUTE10,
	  p_ATTRIBUTE11  => p_qte_header_rec.ATTRIBUTE11,
	  p_ATTRIBUTE12  => p_qte_header_rec.ATTRIBUTE12,
	  p_ATTRIBUTE13  => p_qte_header_rec.ATTRIBUTE13,
	  p_ATTRIBUTE14  => p_qte_header_rec.ATTRIBUTE14,
	  p_ATTRIBUTE15  => p_qte_header_rec.ATTRIBUTE15,
       p_ATTRIBUTE16  => p_qte_header_rec.ATTRIBUTE16,
       p_ATTRIBUTE17  => p_qte_header_rec.ATTRIBUTE17,
       p_ATTRIBUTE18  => p_qte_header_rec.ATTRIBUTE18,
       p_ATTRIBUTE19  => p_qte_header_rec.ATTRIBUTE19,
       p_ATTRIBUTE20  => p_qte_header_rec.ATTRIBUTE20,
-- hyang new okc
	  p_CONTRACT_TEMPLATE_ID  => FND_API.G_MISS_NUM,
	  p_CONTRACT_TEMPLATE_MAJOR_VER  => FND_API.G_MISS_NUM,
	  p_CONTRACT_REQUESTER_ID   => FND_API.G_MISS_NUM,
	  p_CONTRACT_APPROVAL_LEVEL => FND_API.G_MISS_CHAR,
-- end of hyang new okc
	  p_PUBLISH_FLAG            => p_qte_header_rec.PUBLISH_FLAG,
	  p_RESOURCE_GRP_ID         => p_qte_header_rec.RESOURCE_GRP_ID,
       p_SOLD_TO_PARTY_SITE_ID   => p_qte_header_rec.SOLD_TO_PARTY_SITE_ID,
	  p_DISPLAY_ARITHMETIC_OPERATOR => p_qte_header_rec.DISPLAY_ARITHMETIC_OPERATOR,
	  p_MAX_VERSION_FLAG     => p_qte_header_rec.MAX_VERSION_FLAG,
	  p_QUOTE_TYPE           => p_qte_header_rec.QUOTE_TYPE,
	  p_QUOTE_DESCRIPTION    => p_qte_header_rec.QUOTE_DESCRIPTION,
	  p_MINISITE_ID          => p_qte_header_rec.MINISITE_ID,
	  p_CUST_PARTY_ID          => p_qte_header_rec.CUST_PARTY_ID,
	  p_INVOICE_TO_CUST_PARTY_ID => p_qte_header_rec.INVOICE_TO_CUST_PARTY_ID,
       p_Pricing_Status_indicator        =>  p_qte_header_rec.Pricing_Status_indicator,
       p_Tax_status_Indicator      =>  p_qte_header_rec.Tax_status_Indicator,
       p_Price_updated_date                  =>  p_qte_header_rec.Price_updated_date,
       p_Tax_updated_date               =>  p_qte_header_rec.Tax_updated_date,
       p_Recalculate_flag               =>  p_qte_header_rec.Recalculate_flag,
       p_price_request_id               => p_qte_header_rec.price_request_id,
       p_credit_update_date             => p_qte_header_rec.credit_update_date,
-- hyang new okc
    P_Customer_Name_And_Title       =>  p_qte_header_rec.Customer_Name_And_Title,
    P_Customer_Signature_Date       =>  p_qte_header_rec.Customer_Signature_Date,
    P_Supplier_Name_And_Title       =>  p_qte_header_rec.Supplier_Name_And_Title,
    P_Supplier_Signature_Date       =>  p_qte_header_rec.Supplier_Signature_Date,
-- end of hyang new okc
    p_END_CUSTOMER_PARTY_ID         =>  p_qte_header_rec.END_CUSTOMER_PARTY_ID,
    p_END_CUSTOMER_CUST_PARTY_ID    =>  p_qte_header_rec.END_CUSTOMER_CUST_PARTY_ID,
    p_END_CUSTOMER_PARTY_SITE_ID    =>  p_qte_header_rec.END_CUSTOMER_PARTY_SITE_ID,
    p_END_CUSTOMER_CUST_ACCOUNT_ID  =>  p_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID,
    p_OBJECT_VERSION_NUMBER         =>  p_qte_header_rec.OBJECT_VERSION_NUMBER,
    p_assistance_requested          =>  p_qte_header_rec.assistance_requested,
    p_assistance_reason_code        =>  p_qte_header_rec.assistance_reason_code,
    p_automatic_price_flag          =>  p_qte_header_rec.automatic_price_flag,
    p_automatic_tax_flag            =>  p_qte_header_rec.automatic_tax_flag,
    p_header_paynow_charges         =>  p_qte_header_rec.header_paynow_charges,
          -- ER 12879412
    P_PRODUCT_FISC_CLASSIFICATION => p_qte_header_rec.PRODUCT_FISC_CLASSIFICATION,
    P_TRX_BUSINESS_CATEGORY =>   p_qte_header_rec.TRX_BUSINESS_CATEGORY,

     -- ER 21158830
    P_TOTAL_UNIT_COST => p_qte_header_rec.TOTAL_UNIT_COST,
    P_TOTAL_MARGIN_AMOUNT =>   p_qte_header_rec.TOTAL_MARGIN_AMOUNT      ,
    P_TOTAL_MARGIN_PERCENT  =>       p_qte_header_rec.TOTAL_MARGIN_PERCENT

);


--Refer bug 10217258



  --  Start bug fix 10217258 For limits reversal
IF NVL(FND_PROFILE.VALUE('QP_LIMITS_INSTALLED'),'N') = 'Y' THEN
   select count(*) into ct
   from aso_quote_statuses_vl
   where status_code = 'INACTIVE'
   and quote_status_id = p_qte_header_rec.QUOTE_STATUS_ID;

   if ct >0 then
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add('Begin Update Rows limit count '||ct, 1, 'Y');
	 END IF;

    p_price_req_code:='ASO-'||p_qte_header_rec.QUOTE_HEADER_ID||'%';
    for  c_limit in
       (SELECT  price_request_code, amount
	FROM   qp_limit_transactions
	WHERE  price_request_code like p_price_req_code
	and price_request_type_code='ASO')
    loop
      if c_limit.amount>0 then
        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add('Begin Update Rows limit price_request_code '||c_limit.price_request_code, 1, 'Y');
	 END IF;
         QP_UTIL_PUB.Reverse_Limits (p_action_code   => 'CANCEL',
                                p_cons_price_request_code    => c_limit.price_request_code,
                                p_orig_ordered_qty           => c_limit.amount,
                                p_amended_qty                => NULL,
                                p_ret_price_request_code     => NULL,
                                p_returned_qty               => NULL,
                                x_return_status              => x_return_status,
                                x_return_message             => x_msg_data
                               );


     end if;
   end loop;

end if;
end if;
-- end bug fix 10217258

    x_price_adjustment_tbl := p_price_adjustment_tbl;
    l_price_adj_attr_tbl := p_price_adj_attr_tbl;
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Update Rows - price_adj.count: '||x_price_adjustment_tbl.counT, 1, 'N');
	END IF;

    FOR i IN 1..P_Price_Adjustment_Tbl.count LOOP
      IF P_Price_Adjustment_Tbl(i).operation_code = 'CREATE' THEN
	l_price_adj_rec := p_price_adjustment_tbl(i);
     l_sysdate := sysdate;
     x_price_adjustment_tbl(i).last_update_date := l_sysdate;
     -- BC4J Fix
	--x_price_adjustment_tbl(i).PRICE_ADJUSTMENT_ID := NULL;
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Before price_adj.update_rows - Update Rows', 1, 'Y');
	END IF;

	ASO_PRICE_ADJUSTMENTS_PKG.Insert_Row(
	    px_PRICE_ADJUSTMENT_ID  => x_price_adjustment_tbl(i).PRICE_ADJUSTMENT_ID,
	    p_CREATION_DATE  => SYSDATE,
	    p_CREATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_DATE	=> l_sysdate,
	    p_LAST_UPDATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	    p_PROGRAM_APPLICATION_ID  => l_price_adj_rec.PROGRAM_APPLICATION_ID,
	    p_PROGRAM_ID  => l_price_adj_rec.PROGRAM_ID,
	    p_PROGRAM_UPDATE_DATE  => l_price_adj_rec.PROGRAM_UPDATE_DATE,
	    p_REQUEST_ID  => l_price_adj_rec.REQUEST_ID,
	    p_QUOTE_HEADER_ID  => l_qte_header_id,
	    p_QUOTE_LINE_ID  => NULL,
	    p_MODIFIER_HEADER_ID  => l_price_adj_rec.MODIFIER_HEADER_ID,
	    p_MODIFIER_LINE_ID	=> l_price_adj_rec.MODIFIER_LINE_ID,
	    p_MODIFIER_LINE_TYPE_CODE  => l_price_adj_rec.MODIFIER_LINE_TYPE_CODE,
	    p_MODIFIER_MECHANISM_TYPE_CODE  => l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE,
	    p_MODIFIED_FROM  => l_price_adj_rec.MODIFIED_FROM,
	    p_MODIFIED_TO  => l_price_adj_rec.MODIFIED_TO,
	    p_OPERAND  => l_price_adj_rec.OPERAND,
	    p_ARITHMETIC_OPERATOR  => l_price_adj_rec.ARITHMETIC_OPERATOR,
	    p_AUTOMATIC_FLAG  => l_price_adj_rec.AUTOMATIC_FLAG,
	    p_UPDATE_ALLOWABLE_FLAG  => l_price_adj_rec.UPDATE_ALLOWABLE_FLAG,
	    p_UPDATED_FLAG  => l_price_adj_rec.UPDATED_FLAG,
	    p_APPLIED_FLAG  => l_price_adj_rec.APPLIED_FLAG,
	    p_ON_INVOICE_FLAG  => l_price_adj_rec.ON_INVOICE_FLAG,
	    p_PRICING_PHASE_ID	=> l_price_adj_rec.PRICING_PHASE_ID,
	    p_ATTRIBUTE_CATEGORY  => l_price_adj_rec.ATTRIBUTE_CATEGORY,
	    p_ATTRIBUTE1  => l_price_adj_rec.ATTRIBUTE1,
	    p_ATTRIBUTE2  => l_price_adj_rec.ATTRIBUTE2,
	    p_ATTRIBUTE3  => l_price_adj_rec.ATTRIBUTE3,
	    p_ATTRIBUTE4  => l_price_adj_rec.ATTRIBUTE4,
	    p_ATTRIBUTE5  => l_price_adj_rec.ATTRIBUTE5,
	    p_ATTRIBUTE6  => l_price_adj_rec.ATTRIBUTE6,
	    p_ATTRIBUTE7  => l_price_adj_rec.ATTRIBUTE7,
	    p_ATTRIBUTE8  => l_price_adj_rec.ATTRIBUTE8,
	    p_ATTRIBUTE9  => l_price_adj_rec.ATTRIBUTE9,
	    p_ATTRIBUTE10  => l_price_adj_rec.ATTRIBUTE10,
	    p_ATTRIBUTE11  => l_price_adj_rec.ATTRIBUTE11,
	    p_ATTRIBUTE12  => l_price_adj_rec.ATTRIBUTE12,
	    p_ATTRIBUTE13  => l_price_adj_rec.ATTRIBUTE13,
	    p_ATTRIBUTE14  => l_price_adj_rec.ATTRIBUTE14,
	    p_ATTRIBUTE15  => l_price_adj_rec.ATTRIBUTE15,
           p_ATTRIBUTE16  => l_price_adj_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  => l_price_adj_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  => l_price_adj_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  => l_price_adj_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  => l_price_adj_rec.ATTRIBUTE20,
          p_ORIG_SYS_DISCOUNT_REF                    => l_price_adj_rec.ORIG_SYS_DISCOUNT_REF ,
          p_CHANGE_SEQUENCE                           => l_price_adj_rec.CHANGE_SEQUENCE ,
          -- p_LIST_HEADER_ID                            => l_price_adj_rec. ,
          -- p_LIST_LINE_ID                              => l_price_adj_rec. ,
          -- p_LIST_LINE_TYPE_CODE                       => l_price_adj_rec.,
          p_UPDATE_ALLOWED                            => l_price_adj_rec.UPDATE_ALLOWED,
          p_CHANGE_REASON_CODE                        => l_price_adj_rec.CHANGE_REASON_CODE,
          p_CHANGE_REASON_TEXT                        => l_price_adj_rec.CHANGE_REASON_TEXT,
          p_COST_ID                                   => l_price_adj_rec.COST_ID ,
          p_TAX_CODE                                  => l_price_adj_rec.TAX_CODE,
          p_TAX_EXEMPT_FLAG                           => l_price_adj_rec.TAX_EXEMPT_FLAG,
          p_TAX_EXEMPT_NUMBER                         => l_price_adj_rec.TAX_EXEMPT_NUMBER,
          p_TAX_EXEMPT_REASON_CODE                    => l_price_adj_rec.TAX_EXEMPT_REASON_CODE,
          p_PARENT_ADJUSTMENT_ID                      => l_price_adj_rec.PARENT_ADJUSTMENT_ID,
          p_INVOICED_FLAG                             => l_price_adj_rec.INVOICED_FLAG,
          p_ESTIMATED_FLAG                            => l_price_adj_rec.ESTIMATED_FLAG,
          p_INC_IN_SALES_PERFORMANCE                  => l_price_adj_rec.INC_IN_SALES_PERFORMANCE,
          p_SPLIT_ACTION_CODE                         => l_price_adj_rec.SPLIT_ACTION_CODE,
          p_ADJUSTED_AMOUNT                           => l_price_adj_rec.ADJUSTED_AMOUNT ,
          p_CHARGE_TYPE_CODE                          => l_price_adj_rec.CHARGE_TYPE_CODE,
          p_CHARGE_SUBTYPE_CODE                       => l_price_adj_rec.CHARGE_SUBTYPE_CODE,
          p_RANGE_BREAK_QUANTITY                      => l_price_adj_rec.RANGE_BREAK_QUANTITY,
          p_ACCRUAL_CONVERSION_RATE                   => l_price_adj_rec.ACCRUAL_CONVERSION_RATE ,
          p_PRICING_GROUP_SEQUENCE                    => l_price_adj_rec.PRICING_GROUP_SEQUENCE,
          p_ACCRUAL_FLAG                              => l_price_adj_rec.ACCRUAL_FLAG,
          p_LIST_LINE_NO                              => l_price_adj_rec.LIST_LINE_NO,
          p_SOURCE_SYSTEM_CODE                        => l_price_adj_rec.SOURCE_SYSTEM_CODE ,
          p_BENEFIT_QTY                               => l_price_adj_rec.BENEFIT_QTY,
          p_BENEFIT_UOM_CODE                          => l_price_adj_rec.BENEFIT_UOM_CODE,
          p_PRINT_ON_INVOICE_FLAG                     => l_price_adj_rec.PRINT_ON_INVOICE_FLAG,
          p_EXPIRATION_DATE                           => l_price_adj_rec.EXPIRATION_DATE,
          p_REBATE_TRANSACTION_TYPE_CODE              => l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE,
          p_REBATE_TRANSACTION_REFERENCE              => l_price_adj_rec.REBATE_TRANSACTION_REFERENCE,
          p_REBATE_PAYMENT_SYSTEM_CODE                => l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE,
          p_REDEEMED_DATE                             => l_price_adj_rec.REDEEMED_DATE,
          p_REDEEMED_FLAG                             => l_price_adj_rec.REDEEMED_FLAG,
          p_MODIFIER_LEVEL_CODE                       => l_price_adj_rec.MODIFIER_LEVEL_CODE,
          p_PRICE_BREAK_TYPE_CODE                     => l_price_adj_rec.PRICE_BREAK_TYPE_CODE ,
          p_SUBSTITUTION_ATTRIBUTE                    => l_price_adj_rec.SUBSTITUTION_ATTRIBUTE,
          p_PRORATION_TYPE_CODE                       => l_price_adj_rec.PRORATION_TYPE_CODE ,
          p_INCLUDE_ON_RETURNS_FLAG                   => l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG,
          p_CREDIT_OR_CHARGE_FLAG                     => l_price_adj_rec.CREDIT_OR_CHARGE_FLAG,
		p_quote_shipment_id                          => l_price_adj_rec.quote_shipment_id,
		p_OPERAND_PER_PQTY                          => l_price_adj_rec.OPERAND_PER_PQTY,
		p_ADJUSTED_AMOUNT_PER_PQTY                  => l_price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY,
		p_OBJECT_VERSION_NUMBER                     => l_price_adj_rec.OBJECT_VERSION_NUMBER
        );
	FOR j in 1..l_price_adj_attr_tbl.count LOOP
	    IF l_price_adj_attr_tbl(j).price_adj_index = i THEN
		l_price_adj_attr_tbl(j).price_adjustment_id := x_price_adjustment_tbl(i).PRICE_ADJUSTMENT_ID;
	    END IF;
	END LOOP;
      ELSIF P_Price_Adjustment_Tbl(i).operation_code = 'UPDATE' THEN

	l_price_adj_rec := p_price_adjustment_tbl(i);
    l_sysdate := sysdate;
    x_price_adjustment_tbl(i).last_update_date := l_sysdate;
	ASO_PRICE_ADJUSTMENTS_PKG.Update_Row(
	    p_PRICE_ADJUSTMENT_ID  => l_price_adj_rec.PRICE_ADJUSTMENT_ID,
	    p_CREATION_DATE  => l_price_adj_rec.creation_date,
	    p_CREATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_DATE	=> l_sysdate,
	    p_LAST_UPDATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	    p_PROGRAM_APPLICATION_ID  => l_price_adj_rec.PROGRAM_APPLICATION_ID,
	    p_PROGRAM_ID  => l_price_adj_rec.PROGRAM_ID,
	    p_PROGRAM_UPDATE_DATE  => l_price_adj_rec.PROGRAM_UPDATE_DATE,
	    p_REQUEST_ID  => l_price_adj_rec.REQUEST_ID,
	    p_QUOTE_HEADER_ID  => l_qte_header_id,
	    p_QUOTE_LINE_ID  => NULL,
	    p_MODIFIER_HEADER_ID  => l_price_adj_rec.MODIFIER_HEADER_ID,
	    p_MODIFIER_LINE_ID	=> l_price_adj_rec.MODIFIER_LINE_ID,
	    p_MODIFIER_LINE_TYPE_CODE  => l_price_adj_rec.MODIFIER_LINE_TYPE_CODE,
	    p_MODIFIER_MECHANISM_TYPE_CODE  => l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE,
	    p_MODIFIED_FROM  => l_price_adj_rec.MODIFIED_FROM,
	    p_MODIFIED_TO  => l_price_adj_rec.MODIFIED_TO,
	    p_OPERAND  => l_price_adj_rec.OPERAND,
	    p_ARITHMETIC_OPERATOR  => l_price_adj_rec.ARITHMETIC_OPERATOR,
	    p_AUTOMATIC_FLAG  => l_price_adj_rec.AUTOMATIC_FLAG,
	    p_UPDATE_ALLOWABLE_FLAG  => l_price_adj_rec.UPDATE_ALLOWABLE_FLAG,
	    p_UPDATED_FLAG  => l_price_adj_rec.UPDATED_FLAG,
	    p_APPLIED_FLAG  => l_price_adj_rec.APPLIED_FLAG,
	    p_ON_INVOICE_FLAG  => l_price_adj_rec.ON_INVOICE_FLAG,
	    p_PRICING_PHASE_ID	=> l_price_adj_rec.PRICING_PHASE_ID,
	    p_ATTRIBUTE_CATEGORY  => l_price_adj_rec.ATTRIBUTE_CATEGORY,
	    p_ATTRIBUTE1  => l_price_adj_rec.ATTRIBUTE1,
	    p_ATTRIBUTE2  => l_price_adj_rec.ATTRIBUTE2,
	    p_ATTRIBUTE3  => l_price_adj_rec.ATTRIBUTE3,
	    p_ATTRIBUTE4  => l_price_adj_rec.ATTRIBUTE4,
	    p_ATTRIBUTE5  => l_price_adj_rec.ATTRIBUTE5,
	    p_ATTRIBUTE6  => l_price_adj_rec.ATTRIBUTE6,
	    p_ATTRIBUTE7  => l_price_adj_rec.ATTRIBUTE7,
	    p_ATTRIBUTE8  => l_price_adj_rec.ATTRIBUTE8,
	    p_ATTRIBUTE9  => l_price_adj_rec.ATTRIBUTE9,
	    p_ATTRIBUTE10  => l_price_adj_rec.ATTRIBUTE10,
	    p_ATTRIBUTE11  => l_price_adj_rec.ATTRIBUTE11,
	    p_ATTRIBUTE12  => l_price_adj_rec.ATTRIBUTE12,
	    p_ATTRIBUTE13  => l_price_adj_rec.ATTRIBUTE13,
	    p_ATTRIBUTE14  => l_price_adj_rec.ATTRIBUTE14,
	    p_ATTRIBUTE15  => l_price_adj_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  => l_price_adj_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  => l_price_adj_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  => l_price_adj_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  => l_price_adj_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  => l_price_adj_rec.ATTRIBUTE20,
		   p_ORIG_SYS_DISCOUNT_REF                    => l_price_adj_rec.ORIG_SYS_DISCOUNT_REF ,
          p_CHANGE_SEQUENCE                           => l_price_adj_rec.CHANGE_SEQUENCE ,
          -- p_LIST_HEADER_ID                            => l_price_adj_rec. ,
          -- p_LIST_LINE_ID                              => l_price_adj_rec. ,
          -- p_LIST_LINE_TYPE_CODE                       => l_price_adj_rec.,
          p_UPDATE_ALLOWED                            => l_price_adj_rec.UPDATE_ALLOWED,
          p_CHANGE_REASON_CODE                        => l_price_adj_rec.CHANGE_REASON_CODE,
          p_CHANGE_REASON_TEXT                        => l_price_adj_rec.CHANGE_REASON_TEXT,
          p_COST_ID                                   => l_price_adj_rec.COST_ID ,
          p_TAX_CODE                                  => l_price_adj_rec.TAX_CODE,
          p_TAX_EXEMPT_FLAG                           => l_price_adj_rec.TAX_EXEMPT_FLAG,
          p_TAX_EXEMPT_NUMBER                         => l_price_adj_rec.TAX_EXEMPT_NUMBER,
          p_TAX_EXEMPT_REASON_CODE                    => l_price_adj_rec.TAX_EXEMPT_REASON_CODE,
          p_PARENT_ADJUSTMENT_ID                      => l_price_adj_rec.PARENT_ADJUSTMENT_ID,
          p_INVOICED_FLAG                             => l_price_adj_rec.INVOICED_FLAG,
          p_ESTIMATED_FLAG                            => l_price_adj_rec.ESTIMATED_FLAG,
          p_INC_IN_SALES_PERFORMANCE                  => l_price_adj_rec.INC_IN_SALES_PERFORMANCE,
          p_SPLIT_ACTION_CODE                         => l_price_adj_rec.SPLIT_ACTION_CODE,
          p_ADJUSTED_AMOUNT                           => l_price_adj_rec.ADJUSTED_AMOUNT ,
          p_CHARGE_TYPE_CODE                          => l_price_adj_rec.CHARGE_TYPE_CODE,
          p_CHARGE_SUBTYPE_CODE                       => l_price_adj_rec.CHARGE_SUBTYPE_CODE,
          p_RANGE_BREAK_QUANTITY                      => l_price_adj_rec.RANGE_BREAK_QUANTITY,
          p_ACCRUAL_CONVERSION_RATE                   => l_price_adj_rec.ACCRUAL_CONVERSION_RATE ,
          p_PRICING_GROUP_SEQUENCE                    => l_price_adj_rec.PRICING_GROUP_SEQUENCE,
          p_ACCRUAL_FLAG                              => l_price_adj_rec.ACCRUAL_FLAG,
          p_LIST_LINE_NO                              => l_price_adj_rec.LIST_LINE_NO,
          p_SOURCE_SYSTEM_CODE                        => l_price_adj_rec.SOURCE_SYSTEM_CODE ,
          p_BENEFIT_QTY                               => l_price_adj_rec.BENEFIT_QTY,
          p_BENEFIT_UOM_CODE                          => l_price_adj_rec.BENEFIT_UOM_CODE,
          p_PRINT_ON_INVOICE_FLAG                     => l_price_adj_rec.PRINT_ON_INVOICE_FLAG,
          p_EXPIRATION_DATE                           => l_price_adj_rec.EXPIRATION_DATE,
          p_REBATE_TRANSACTION_TYPE_CODE              => l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE,
          p_REBATE_TRANSACTION_REFERENCE              => l_price_adj_rec.REBATE_TRANSACTION_REFERENCE,
          p_REBATE_PAYMENT_SYSTEM_CODE                => l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE,
          p_REDEEMED_DATE                             => l_price_adj_rec.REDEEMED_DATE,
          p_REDEEMED_FLAG                             => l_price_adj_rec.REDEEMED_FLAG,
          p_MODIFIER_LEVEL_CODE                       => l_price_adj_rec.MODIFIER_LEVEL_CODE,
          p_PRICE_BREAK_TYPE_CODE                     => l_price_adj_rec.PRICE_BREAK_TYPE_CODE ,
          p_SUBSTITUTION_ATTRIBUTE                    => l_price_adj_rec.SUBSTITUTION_ATTRIBUTE,
          p_PRORATION_TYPE_CODE                       => l_price_adj_rec.PRORATION_TYPE_CODE ,
          p_INCLUDE_ON_RETURNS_FLAG                   => l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG,
          p_CREDIT_OR_CHARGE_FLAG                     => l_price_adj_rec.CREDIT_OR_CHARGE_FLAG,
		p_quote_shipment_id                          => l_price_adj_rec.quote_shipment_id,
		p_OPERAND_PER_PQTY                          => l_price_adj_rec.OPERAND_PER_PQTY,
		p_ADJUSTED_AMOUNT_PER_PQTY                  => l_price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY,
		p_OBJECT_VERSION_NUMBER                     => l_price_adj_rec.OBJECT_VERSION_NUMBER
        );
      ELSIF P_Price_Adjustment_Tbl(i).operation_code = 'DELETE' THEN
	ASO_PRICE_ADJUSTMENTS_PKG.Delete_Row(
	    p_PRICE_ADJUSTMENT_ID  => p_price_adjustment_tbl(i).PRICE_ADJUSTMENT_ID);
      END IF;
    END LOOP;

    FOR i IN 1..l_Price_Adj_Attr_Tbl.count LOOP

      l_sysdate := sysdate;

      IF l_price_adj_attr_tbl(i).operation_code = 'CREATE'  and
	    l_price_adj_attr_tbl(i).price_adjustment_id is not null and
	    l_price_adj_attr_tbl(i).price_adjustment_id <> fnd_api.g_miss_num THEN


	 x_price_adj_attr_tbl(i) := l_price_adj_attr_tbl(i);

	 --l_price_adj_attr_rec := l_price_adj_attr_tbl(i);
	 -- BC4J Fix
	 --x_price_adj_attr_tbl(i).PRICE_ADJ_ATTRIB_ID := NULL;
      x_price_adj_attr_tbl(i).LAST_UPDATE_DATE := l_sysdate;

	ASO_PRICE_ADJ_ATTRIBS_PKG.Insert_Row(
		px_PRICE_ADJ_ATTRIB_ID	 => x_price_adj_attr_tbl(i).PRICE_ADJ_ATTRIB_ID,
		p_CREATION_DATE  => SYSDATE,
		p_CREATED_BY  => G_USER_ID,
		p_LAST_UPDATE_DATE  => l_sysdate,
		p_LAST_UPDATED_BY  => G_USER_ID,
		p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
		p_PROGRAM_APPLICATION_ID  =>l_price_adj_attr_tbl(i).PROGRAM_APPLICATION_ID,
		p_PROGRAM_ID  => l_price_adj_attr_tbl(i).PROGRAM_ID,
		p_PROGRAM_UPDATE_DATE  => l_price_adj_attr_tbl(i).PROGRAM_UPDATE_DATE,
		p_REQUEST_ID  => l_price_adj_attr_tbl(i).REQUEST_ID,
		p_PRICE_ADJUSTMENT_ID => l_price_adj_attr_tbl(i).PRICE_ADJUSTMENT_ID,
		p_PRICING_CONTEXT  => l_price_adj_attr_tbl(i).PRICING_CONTEXT,
		p_PRICING_ATTRIBUTE => l_price_adj_attr_tbl(i).PRICING_ATTRIBUTE,
		p_PRICING_ATTR_VALUE_FROM => l_price_adj_attr_tbl(i).PRICING_ATTR_VALUE_FROM,
		p_PRICING_ATTR_VALUE_TO  => l_price_adj_attr_tbl(i).PRICING_ATTR_VALUE_TO,
		p_COMPARISON_OPERATOR	=> l_price_adj_attr_tbl(i).COMPARISON_OPERATOR,
		p_FLEX_TITLE   => l_price_adj_attr_tbl(i).FLEX_TITLE,
		p_OBJECT_VERSION_NUMBER  => l_price_adj_attr_tbl(i).OBJECT_VERSION_NUMBER
		);

      ELSIF l_Price_Adj_Attr_Tbl(i).operation_code = 'UPDATE' THEN

	 x_price_adj_attr_tbl(i) := l_price_adj_attr_tbl(i);
	 --l_price_adj_attr_rec := l_price_adj_attr_tbl(i);
      x_price_adj_attr_tbl(i).LAST_UPDATE_DATE := l_sysdate;

	ASO_PRICE_ADJ_ATTRIBS_PKG.Update_Row(
		p_PRICE_ADJ_ATTRIB_ID	=> x_price_adj_attr_tbl(i).PRICE_ADJ_ATTRIB_ID,
		p_CREATION_DATE  => l_price_adj_attr_tbl(i).creation_date,
		p_CREATED_BY  => G_USER_ID,
		p_LAST_UPDATE_DATE  => l_sysdate,
		p_LAST_UPDATED_BY  => G_USER_ID,
		p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
		p_PROGRAM_APPLICATION_ID  =>l_price_adj_attr_tbl(i).PROGRAM_APPLICATION_ID,
		p_PROGRAM_ID  => l_price_adj_attr_tbl(i).PROGRAM_ID,
		p_PROGRAM_UPDATE_DATE  => l_price_adj_attr_tbl(i).PROGRAM_UPDATE_DATE,
		p_REQUEST_ID  => l_price_adj_attr_tbl(i).REQUEST_ID,
		p_PRICE_ADJUSTMENT_ID => l_price_adj_attr_tbl(i).PRICE_ADJUSTMENT_ID,
		p_PRICING_CONTEXT  => l_price_adj_attr_tbl(i).PRICING_CONTEXT,
		p_PRICING_ATTRIBUTE => l_price_adj_attr_tbl(i).PRICING_ATTRIBUTE,
		p_PRICING_ATTR_VALUE_FROM => l_price_adj_attr_tbl(i).PRICING_ATTR_VALUE_FROM,
		p_PRICING_ATTR_VALUE_TO  => l_price_adj_attr_tbl(i).PRICING_ATTR_VALUE_TO,
		p_COMPARISON_OPERATOR	=> l_price_adj_attr_tbl(i).COMPARISON_OPERATOR,
		p_FLEX_TITLE   => l_price_adj_attr_tbl(i).FLEX_TITLE,
		p_OBJECT_VERSION_NUMBER  => l_price_adj_attr_tbl(i).OBJECT_VERSION_NUMBER);
      ELSIF l_Price_Adj_Attr_Tbl(i).operation_code = 'DELETE' THEN
	ASO_PRICE_ADJ_ATTRIBS_PKG.Delete_Row(
	    p_PRICE_ADJ_ATTRIB_ID  => l_price_adj_attr_tbl(i).PRICE_ADJUSTMENT_ID);
      END IF;
    END LOOP;

    x_payment_tbl := p_payment_tbl;

    FOR i IN 1..P_Payment_Tbl.count LOOP
      IF P_Payment_Tbl(i).operation_code = 'CREATE' THEN

          l_sysdate := sysdate;
	  l_payment_rec := p_payment_tbl(i);
	  l_payment_rec.PAYMENT_TERM_ID_FROM := p_payment_tbl(i).payment_term_id;

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Inside ASO_PAYMENTS_PKG - Insert Rows p_payment_tbl(i).payment_term_id'||p_payment_tbl(i).payment_term_id, 1, 'Y');
        aso_debug_pub.add('Inside ASO_PAYMENTS_PKG - Insert Rows l_payment_rec.PAYMENT_TERM_ID_FROM'||l_payment_rec.PAYMENT_TERM_ID_FROM, 1, 'Y');
       END IF;
        -- BC4J Fix
	   --x_payment_tbl(i).PAYMENT_ID := NULL;
           x_payment_tbl(i).LAST_UPDATE_DATE := l_sysdate;
	   x_payment_tbl(i).PAYMENT_TERM_ID_FROM := l_payment_rec.PAYMENT_TERM_ID_FROM;


     --  Payments Changes

	      l_payment_rec.quote_header_id := l_qte_header_id;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Rows: Before  call to create_payment_row ', 1, 'Y');
           END IF;

         aso_payment_int.create_payment_row(p_payment_rec => l_payment_rec  ,
                                             x_payment_rec   => x_payment_tbl(i),
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Rows: After call to create_payment_row: x_return_status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;

           x_payment_tbl(i).LAST_UPDATE_DATE := l_sysdate;
           x_payment_tbl(i).PAYMENT_TERM_ID_FROM := l_payment_rec.PAYMENT_TERM_ID_FROM;

     -- End Payment Changes

      ELSIF P_Payment_Tbl(i).operation_code = 'UPDATE' THEN

          l_payment_rec := p_payment_tbl(i);
          l_sysdate     := sysdate;

          IF l_payment_rec.payment_term_id = FND_API.G_MISS_NUM THEN

     	    FOR l_payment_db_rec IN c_db_payment_terms(p_payment_tbl(i).PAYMENT_ID) LOOP

                  IF l_payment_db_rec.payment_term_id_from IS NULL THEN
                      l_payment_rec.payment_term_id_from := l_payment_db_rec.payment_term_id;
                  END IF;

     	    END LOOP;

          ELSE
              l_payment_rec.payment_term_id_from := l_payment_rec.payment_term_id;

          END IF;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Inside ASO_PAYMENTS_PKG - Update Rows l_payment_rec.payment_term_id'||l_payment_rec.payment_term_id, 1, 'Y');
        aso_debug_pub.add('Inside ASO_PAYMENTS_PKG - Update Rows l_payment_rec.PAYMENT_TERM_ID_FROM'||l_payment_rec.PAYMENT_TERM_ID_FROM, 1, 'Y');
        END IF;

        x_payment_tbl(i).last_update_date     := l_sysdate;
        x_payment_tbl(i).payment_term_id_from := l_payment_rec.payment_term_id_from;

     -- Payments Changes

           l_payment_rec.quote_header_id := l_qte_header_id;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Rows: Before  call to update_payment_row ', 1, 'Y');
           END IF;

         aso_payment_int.update_payment_row(p_payment_rec => l_payment_rec  ,
                                             x_payment_rec   => x_payment_tbl(i),
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Rows: After call to update_payment_row: x_return_status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;

           x_payment_tbl(i).LAST_UPDATE_DATE := l_sysdate;
           x_payment_tbl(i).PAYMENT_TERM_ID_FROM := l_payment_rec.PAYMENT_TERM_ID_FROM;

     -- End Payment Changes

      ELSIF P_Payment_Tbl(i).operation_code = 'DELETE' THEN

     -- Payments Changes
          l_payment_rec := P_Payment_Tbl(i);
          l_payment_rec.quote_header_id := l_qte_header_id;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Rows: Before  call to delete_payment_row ', 1, 'Y');
           END IF;

         aso_payment_int.delete_payment_row(p_payment_rec => l_payment_rec  ,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Rows: After call to delete_payment_row: x_return_status: '||x_return_status, 1, 'Y');
           END IF;
            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;

     -- End Payment Changes

      END IF;
    END LOOP;


    x_shipment_tbl       := p_shipment_tbl;
    l_freight_charge_tbl := p_freight_charge_tbl;

    FOR i IN 1..P_Shipment_Tbl.count LOOP

      IF P_Shipment_Tbl(i).operation_code = 'CREATE' THEN

          l_shipment_rec                         :=  x_shipment_tbl(i);
          l_shipment_rec.ship_method_code_from   :=  p_shipment_tbl(1).ship_method_code;
          l_shipment_rec.freight_terms_code_from :=  p_shipment_tbl(1).freight_terms_code;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Before ASO_SHIPMENTS_PKG.insert_rows - p_shipment_tbl(1).ship_method_code'||p_shipment_tbl(1).ship_method_code, 1, 'Y');
      aso_debug_pub.add('Before ASO_SHIPMENTS_PKG.insert_rows - p_shipment_tbl(1).freight_terms_code'||p_shipment_tbl(1).freight_terms_code, 1, 'Y');
     END IF;

       l_sysdate                                 := sysdate;
       -- BC4J Fix
       x_shipment_tbl(i).shipment_id           :=  p_shipment_tbl(1).shipment_id;
	  --x_shipment_tbl(i).shipment_id             := null;
       x_shipment_tbl(i).last_update_date        := l_sysdate;
       x_shipment_tbl(i).ship_method_code_from   := l_shipment_rec.ship_method_code_from;
       x_shipment_tbl(i).freight_terms_code_from := l_shipment_rec.freight_terms_code_from;

	ASO_SHIPMENTS_PKG.Insert_Row(
	    px_SHIPMENT_ID  => x_shipment_tbl(i).SHIPMENT_ID,
	    p_CREATION_DATE  => SYSDATE,
	    p_CREATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_DATE	=> l_sysdate,
	    p_LAST_UPDATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	    p_REQUEST_ID  => l_shipment_rec.REQUEST_ID,
	    p_PROGRAM_APPLICATION_ID  => l_shipment_rec.PROGRAM_APPLICATION_ID,
	    p_PROGRAM_ID  => l_shipment_rec.PROGRAM_ID,
	    p_PROGRAM_UPDATE_DATE  => l_shipment_rec.PROGRAM_UPDATE_DATE,
	    p_QUOTE_HEADER_ID  => l_qte_HEADER_ID,
	    p_QUOTE_LINE_ID  => NULL,
	    p_PROMISE_DATE  => l_shipment_rec.PROMISE_DATE,
	    p_REQUEST_DATE  => l_shipment_rec.REQUEST_DATE,
	    p_SCHEDULE_SHIP_DATE  => l_shipment_rec.SCHEDULE_SHIP_DATE,
	    p_SHIP_TO_PARTY_SITE_ID  => l_shipment_rec.SHIP_TO_PARTY_SITE_ID,
	    p_SHIP_TO_PARTY_ID	=> l_shipment_rec.SHIP_TO_PARTY_ID,
            p_ship_to_CUST_ACCOUNT_ID  => l_shipment_rec.ship_to_CUST_ACCOUNT_ID,
	    p_SHIP_PARTIAL_FLAG  => l_shipment_rec.SHIP_PARTIAL_FLAG,
	    p_SHIP_SET_ID  => l_shipment_rec.SHIP_SET_ID,
	    p_SHIP_METHOD_CODE	=> l_shipment_rec.SHIP_METHOD_CODE,
	    p_FREIGHT_TERMS_CODE  => l_shipment_rec.FREIGHT_TERMS_CODE,
	    p_FREIGHT_CARRIER_CODE  => l_shipment_rec.FREIGHT_CARRIER_CODE,
	    p_FOB_CODE	=> l_shipment_rec.FOB_CODE,
	    p_SHIPPING_INSTRUCTIONS  => l_shipment_rec.SHIPPING_INSTRUCTIONS,
	    p_PACKING_INSTRUCTIONS  => l_shipment_rec.PACKING_INSTRUCTIONS,
	    p_QUANTITY	=> l_shipment_rec.QUANTITY,
	    p_RESERVED_QUANTITY  => l_shipment_rec.RESERVED_QUANTITY,
	    p_RESERVATION_ID  => l_shipment_rec.RESERVATION_ID,
	    p_ORDER_LINE_ID  => l_shipment_rec.ORDER_LINE_ID,
	    p_ATTRIBUTE_CATEGORY  => l_shipment_rec.ATTRIBUTE_CATEGORY,
	    p_ATTRIBUTE1  => l_shipment_rec.ATTRIBUTE1,
	    p_ATTRIBUTE2  => l_shipment_rec.ATTRIBUTE2,
	    p_ATTRIBUTE3  => l_shipment_rec.ATTRIBUTE3,
	    p_ATTRIBUTE4  => l_shipment_rec.ATTRIBUTE4,
	    p_ATTRIBUTE5  => l_shipment_rec.ATTRIBUTE5,
	    p_ATTRIBUTE6  => l_shipment_rec.ATTRIBUTE6,
	    p_ATTRIBUTE7  => l_shipment_rec.ATTRIBUTE7,
	    p_ATTRIBUTE8  => l_shipment_rec.ATTRIBUTE8,
	    p_ATTRIBUTE9  => l_shipment_rec.ATTRIBUTE9,
	    p_ATTRIBUTE10  => l_shipment_rec.ATTRIBUTE10,
	    p_ATTRIBUTE11  => l_shipment_rec.ATTRIBUTE11,
	    p_ATTRIBUTE12  => l_shipment_rec.ATTRIBUTE12,
	    p_ATTRIBUTE13  => l_shipment_rec.ATTRIBUTE13,
	    p_ATTRIBUTE14  => l_shipment_rec.ATTRIBUTE14,
	    p_ATTRIBUTE15  => l_shipment_rec.ATTRIBUTE15,
         p_ATTRIBUTE16  =>  l_shipment_rec.ATTRIBUTE16,
         p_ATTRIBUTE17  =>  l_shipment_rec.ATTRIBUTE17,
         p_ATTRIBUTE18  =>  l_shipment_rec.ATTRIBUTE18,
         p_ATTRIBUTE19  =>  l_shipment_rec.ATTRIBUTE19,
         p_ATTRIBUTE20  =>  l_shipment_rec.ATTRIBUTE20,
		p_SHIPMENT_PRIORITY_CODE => l_shipment_rec.SHIPMENT_PRIORITY_CODE,
          p_SHIP_QUOTE_PRICE => l_shipment_rec.SHIP_QUOTE_PRICE,
	    p_SHIP_FROM_ORG_ID => l_shipment_rec.SHIP_FROM_ORG_ID,
	    p_SHIP_TO_CUST_PARTY_ID => l_shipment_rec.SHIP_TO_CUST_PARTY_ID,
         p_SHIP_METHOD_CODE_FROM   => l_shipment_rec.SHIP_METHOD_CODE_FROM,
         p_FREIGHT_TERMS_CODE_FROM  => l_shipment_rec.FREIGHT_TERMS_CODE_FROM,
	    p_OBJECT_VERSION_NUMBER  => l_shipment_rec.OBJECT_VERSION_NUMBER,
	    p_REQUEST_DATE_TYPE => l_shipment_rec.REQUEST_DATE_TYPE,
         p_demand_class_code => l_shipment_rec.demand_class_code
	    );

	FOR j IN 1..l_Freight_Charge_Tbl.count LOOP
	  IF l_Freight_Charge_Tbl(j).shipment_index = i THEN
	     l_freight_charge_tbl(j).QUOTE_SHIPMENT_ID := x_shipment_tbl(i).SHIPMENT_ID;
	  END IF;
	END LOOP;


     ELSIF P_Shipment_Tbl(i).operation_code = 'UPDATE' THEN

          l_sysdate                          := sysdate;
          x_shipment_tbl(i).last_update_date := l_sysdate;
          l_shipment_rec                     := x_shipment_tbl(i);

          IF l_shipment_rec.ship_method_code = fnd_api.g_miss_char THEN

            FOR l_ship_db_rec IN c_db_ship_freight_terms(l_shipment_rec.shipment_id) LOOP

		    IF l_ship_db_rec.ship_method_code_from is null THEN
                  l_shipment_rec.ship_method_code_from := l_ship_db_rec.ship_method_code;
		    END IF;

            END LOOP;

          ELSE
              l_shipment_rec.ship_method_code_from := l_shipment_rec.ship_method_code;

          END IF;


          IF l_shipment_rec.freight_terms_code = fnd_api.g_miss_char THEN

            FOR l_ship_db_rec IN c_db_ship_freight_terms(l_shipment_rec.shipment_id) LOOP

		    IF l_ship_db_rec.freight_terms_code_from is null THEN
                  l_shipment_rec.freight_terms_code_from := l_ship_db_rec.freight_terms_code;
		    END IF;

            END LOOP;

          ELSE
              l_shipment_rec.freight_terms_code_from := l_shipment_rec.freight_terms_code;

          END IF;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Before ASO_SHIPMENTS_PKG.update_rows - l_shipment_rec.ship_method_code'||l_shipment_rec.ship_method_code, 1, 'Y');
      aso_debug_pub.add('Before ASO_SHIPMENTS_PKG.update_rows - l_shipment_rec.freight_terms_code'||l_shipment_rec.freight_terms_code, 1, 'Y');
          END IF;

          x_shipment_tbl(i).ship_method_code_from   := l_shipment_rec.ship_method_code_from;
          x_shipment_tbl(i).freight_terms_code_from := l_shipment_rec.freight_terms_code_from;

	ASO_SHIPMENTS_PKG.Update_Row(
	    p_SHIPMENT_ID  => l_shipment_rec.SHIPMENT_ID,
	    p_CREATION_DATE  => l_shipment_rec.creation_date,
	    p_CREATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_DATE	=> l_sysdate,
	    p_LAST_UPDATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	    p_REQUEST_ID  => l_shipment_rec.REQUEST_ID,
	    p_PROGRAM_APPLICATION_ID  => l_shipment_rec.PROGRAM_APPLICATION_ID,
	    p_PROGRAM_ID  => l_shipment_rec.PROGRAM_ID,
	    p_PROGRAM_UPDATE_DATE  => l_shipment_rec.PROGRAM_UPDATE_DATE,
	    p_QUOTE_HEADER_ID  => l_qte_HEADER_ID,
	    p_QUOTE_LINE_ID  => NULL,
	    p_PROMISE_DATE  => l_shipment_rec.PROMISE_DATE,
	    p_REQUEST_DATE  => l_shipment_rec.REQUEST_DATE,
	    p_SCHEDULE_SHIP_DATE  => l_shipment_rec.SCHEDULE_SHIP_DATE,
	    p_SHIP_TO_PARTY_SITE_ID  => l_shipment_rec.SHIP_TO_PARTY_SITE_ID,
	    p_SHIP_TO_PARTY_ID	=> l_shipment_rec.SHIP_TO_PARTY_ID,
            p_ship_to_CUST_ACCOUNT_ID  => l_shipment_rec.ship_to_CUST_ACCOUNT_ID,
	    p_SHIP_PARTIAL_FLAG  => l_shipment_rec.SHIP_PARTIAL_FLAG,
	    p_SHIP_SET_ID  => l_shipment_rec.SHIP_SET_ID,
	    p_SHIP_METHOD_CODE	=> l_shipment_rec.SHIP_METHOD_CODE,
	    p_FREIGHT_TERMS_CODE  => l_shipment_rec.FREIGHT_TERMS_CODE,
	    p_FREIGHT_CARRIER_CODE  => l_shipment_rec.FREIGHT_CARRIER_CODE,
	    p_FOB_CODE	=> l_shipment_rec.FOB_CODE,
	    p_SHIPPING_INSTRUCTIONS  => l_shipment_rec.SHIPPING_INSTRUCTIONS,
	    p_PACKING_INSTRUCTIONS  => l_shipment_rec.PACKING_INSTRUCTIONS,
	    p_QUANTITY	=> l_shipment_rec.QUANTITY,
	    p_RESERVED_QUANTITY  => l_shipment_rec.RESERVED_QUANTITY,
	    p_RESERVATION_ID  => l_shipment_rec.RESERVATION_ID,
	    p_ORDER_LINE_ID  => l_shipment_rec.ORDER_LINE_ID,
	    p_ATTRIBUTE_CATEGORY  => l_shipment_rec.ATTRIBUTE_CATEGORY,
	    p_ATTRIBUTE1  => l_shipment_rec.ATTRIBUTE1,
	    p_ATTRIBUTE2  => l_shipment_rec.ATTRIBUTE2,
	    p_ATTRIBUTE3  => l_shipment_rec.ATTRIBUTE3,
	    p_ATTRIBUTE4  => l_shipment_rec.ATTRIBUTE4,
	    p_ATTRIBUTE5  => l_shipment_rec.ATTRIBUTE5,
	    p_ATTRIBUTE6  => l_shipment_rec.ATTRIBUTE6,
	    p_ATTRIBUTE7  => l_shipment_rec.ATTRIBUTE7,
	    p_ATTRIBUTE8  => l_shipment_rec.ATTRIBUTE8,
	    p_ATTRIBUTE9  => l_shipment_rec.ATTRIBUTE9,
	    p_ATTRIBUTE10  => l_shipment_rec.ATTRIBUTE10,
	    p_ATTRIBUTE11  => l_shipment_rec.ATTRIBUTE11,
	    p_ATTRIBUTE12  => l_shipment_rec.ATTRIBUTE12,
	    p_ATTRIBUTE13  => l_shipment_rec.ATTRIBUTE13,
	    p_ATTRIBUTE14  => l_shipment_rec.ATTRIBUTE14,
	    p_ATTRIBUTE15  => l_shipment_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  =>  l_shipment_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  =>  l_shipment_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  =>  l_shipment_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  =>  l_shipment_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  =>  l_shipment_rec.ATTRIBUTE20,
		p_SHIPMENT_PRIORITY_CODE => l_shipment_rec.SHIPMENT_PRIORITY_CODE,
          p_SHIP_QUOTE_PRICE => l_shipment_rec.SHIP_QUOTE_PRICE,
	    p_SHIP_FROM_ORG_ID => l_shipment_rec.SHIP_FROM_ORG_ID,
	    p_SHIP_TO_CUST_PARTY_ID => l_shipment_rec.SHIP_TO_CUST_PARTY_ID,
         p_SHIP_METHOD_CODE_FROM   => l_shipment_rec.SHIP_METHOD_CODE_FROM,
         p_FREIGHT_TERMS_CODE_FROM  => l_shipment_rec.FREIGHT_TERMS_CODE_FROM,
	    p_OBJECT_VERSION_NUMBER  => l_shipment_rec.OBJECT_VERSION_NUMBER,
         p_REQUEST_DATE_TYPE => l_shipment_rec.REQUEST_DATE_TYPE,
         p_demand_class_code => l_shipment_rec.demand_class_code
         );
      ELSIF P_Shipment_Tbl(i).operation_code = 'DELETE' THEN
	ASO_SHIPMENTS_PKG.Delete_Row(
	    p_SHIPMENT_ID  => P_Shipment_Tbl(i).SHIPMENT_ID);
      END IF;
    END LOOP;

    x_freight_charge_tbl := l_freight_charge_tbl;
    FOR i IN 1..l_Freight_Charge_Tbl.count LOOP
	 IF l_Freight_Charge_Tbl(i).operation_code = 'CREATE' THEN
     l_sysdate := sysdate;
	    l_freight_charge_rec := l_freight_charge_tbl(i);
        x_FREIGHT_CHARGE_tbl(i).last_update_date := l_sysdate;
	    -- BC4J Fix
	    --x_FREIGHT_CHARGE_tbl(i).freight_charge_id := NULL;
	    ASO_FREIGHT_CHARGES_PKG.Insert_Row(
		px_FREIGHT_CHARGE_ID  => x_FREIGHT_CHARGE_tbl(i).freight_charge_id,
		p_CREATION_DATE  => SYSDATE,
	    	p_CREATED_BY  => G_USER_ID,
	    	p_LAST_UPDATE_DATE  => l_sysdate,
	    	p_LAST_UPDATED_BY  => G_USER_ID,
	    	p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	    	p_REQUEST_ID  => l_freight_charge_rec.REQUEST_ID,
	    	p_PROGRAM_APPLICATION_ID  => l_freight_charge_rec.PROGRAM_APPLICATION_ID,
	    	p_PROGRAM_ID  => l_freight_charge_rec.PROGRAM_ID,
	    	p_PROGRAM_UPDATE_DATE  => l_freight_charge_rec.PROGRAM_UPDATE_DATE,
	    	p_QUOTE_SHIPMENT_ID  => l_freight_charge_rec.Quote_SHIPMENT_ID,
	    	p_FREIGHT_CHARGE_TYPE_ID  => l_freight_charge_rec.FREIGHT_CHARGE_TYPE_ID,
	    	p_CHARGE_AMOUNT  => l_freight_charge_rec.CHARGE_AMOUNT,
	    	p_ATTRIBUTE_CATEGORY  => l_freight_charge_rec.ATTRIBUTE_CATEGORY,
	    	p_ATTRIBUTE1  => l_freight_charge_rec.ATTRIBUTE1,
	    	p_ATTRIBUTE2  => l_freight_charge_rec.ATTRIBUTE2,
	    	p_ATTRIBUTE3  => l_freight_charge_rec.ATTRIBUTE3,
	    	p_ATTRIBUTE4  => l_freight_charge_rec.ATTRIBUTE4,
	    	p_ATTRIBUTE5  => l_freight_charge_rec.ATTRIBUTE5,
	    	p_ATTRIBUTE6  => l_freight_charge_rec.ATTRIBUTE6,
	    	p_ATTRIBUTE7  => l_freight_charge_rec.ATTRIBUTE7,
	    	p_ATTRIBUTE8  => l_freight_charge_rec.ATTRIBUTE8,
	    	p_ATTRIBUTE9  => l_freight_charge_rec.ATTRIBUTE9,
	    	p_ATTRIBUTE10  => l_freight_charge_rec.ATTRIBUTE10,
	    	p_ATTRIBUTE11  => l_freight_charge_rec.ATTRIBUTE11,
	    	p_ATTRIBUTE12  => l_freight_charge_rec.ATTRIBUTE12,
	    	p_ATTRIBUTE13  => l_freight_charge_rec.ATTRIBUTE13,
	    	p_ATTRIBUTE14  => l_freight_charge_rec.ATTRIBUTE14,
	    	p_ATTRIBUTE15  => l_freight_charge_rec.ATTRIBUTE15);
	 ELSIF l_Freight_Charge_Tbl(i).operation_code = 'UPDATE' THEN
        l_sysdate := sysdate;
	    l_freight_charge_rec := l_freight_charge_tbl(i);
        x_FREIGHT_CHARGE_tbl(i).last_update_date := l_sysdate;
	    ASO_FREIGHT_CHARGES_PKG.Update_Row(
		p_FREIGHT_CHARGE_ID  => l_freight_charge_rec.freight_charge_id,
		p_CREATION_DATE  => l_freight_charge_rec.creation_date,
	    	p_CREATED_BY  => G_USER_ID,
	    	p_LAST_UPDATE_DATE  => l_sysdate,
	    	p_LAST_UPDATED_BY  => G_USER_ID,
	    	p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	    	p_REQUEST_ID  => l_freight_charge_rec.REQUEST_ID,
	    	p_PROGRAM_APPLICATION_ID  => l_freight_charge_rec.PROGRAM_APPLICATION_ID,
	    	p_PROGRAM_ID  => l_freight_charge_rec.PROGRAM_ID,
	    	p_PROGRAM_UPDATE_DATE  => l_freight_charge_rec.PROGRAM_UPDATE_DATE,
	    	p_QUOTE_SHIPMENT_ID  => l_freight_charge_rec.Quote_SHIPMENT_ID,
	    	p_FREIGHT_CHARGE_TYPE_ID  => l_freight_charge_rec.FREIGHT_CHARGE_TYPE_ID,
	    	p_CHARGE_AMOUNT  => l_freight_charge_rec.CHARGE_AMOUNT,
	    	p_ATTRIBUTE_CATEGORY  => l_freight_charge_rec.ATTRIBUTE_CATEGORY,
	    	p_ATTRIBUTE1  => l_freight_charge_rec.ATTRIBUTE1,
	    	p_ATTRIBUTE2  => l_freight_charge_rec.ATTRIBUTE2,
	    	p_ATTRIBUTE3  => l_freight_charge_rec.ATTRIBUTE3,
	    	p_ATTRIBUTE4  => l_freight_charge_rec.ATTRIBUTE4,
	    	p_ATTRIBUTE5  => l_freight_charge_rec.ATTRIBUTE5,
	    	p_ATTRIBUTE6  => l_freight_charge_rec.ATTRIBUTE6,
	    	p_ATTRIBUTE7  => l_freight_charge_rec.ATTRIBUTE7,
	    	p_ATTRIBUTE8  => l_freight_charge_rec.ATTRIBUTE8,
	    	p_ATTRIBUTE9  => l_freight_charge_rec.ATTRIBUTE9,
	    	p_ATTRIBUTE10  => l_freight_charge_rec.ATTRIBUTE10,
	    	p_ATTRIBUTE11  => l_freight_charge_rec.ATTRIBUTE11,
	    	p_ATTRIBUTE12  => l_freight_charge_rec.ATTRIBUTE12,
	    	p_ATTRIBUTE13  => l_freight_charge_rec.ATTRIBUTE13,
	    	p_ATTRIBUTE14  => l_freight_charge_rec.ATTRIBUTE14,
	    	p_ATTRIBUTE15  => l_freight_charge_rec.ATTRIBUTE15);
	 ELSIF l_Freight_Charge_Tbl(i).operation_code = 'DELETE' THEN
	     ASO_FREIGHT_CHARGES_PKG.Delete_Row(
		p_FREIGHT_CHARGE_ID  => l_freight_charge_tbl(i).freight_charge_id);
	 END IF;
    END LOOP;

    x_tax_detail_tbl := p_tax_detail_tbl;
    FOR i IN 1..P_Tax_Detail_Tbl.count LOOP
      IF P_Tax_Detail_Tbl(i).operation_code = 'CREATE' THEN
      l_sysdate := sysdate;
	l_tax_detail_rec := x_tax_detail_tbl(i);
     -- BC4J Fix
	--x_tax_detail_tbl(i).TAX_DETAIL_ID := NULL;
    x_tax_detail_tbl(i).LAST_UPDATE_DATE := l_sysdate;
	ASO_TAX_DETAILS_PKG.Insert_Row(
	    px_TAX_DETAIL_ID  => x_tax_detail_tbl(i).TAX_DETAIL_ID,
	    p_CREATION_DATE  => SYSDATE,
	    p_CREATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_DATE	=> l_sysdate,
	    p_LAST_UPDATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	    p_REQUEST_ID  => l_tax_detail_rec.REQUEST_ID,
	    p_PROGRAM_APPLICATION_ID  => l_tax_detail_rec.PROGRAM_APPLICATION_ID,
	    p_PROGRAM_ID  => l_tax_detail_rec.PROGRAM_ID,
	    p_PROGRAM_UPDATE_DATE  => l_tax_detail_rec.PROGRAM_UPDATE_DATE,
	    p_QUOTE_HEADER_ID  => l_qte_HEADER_ID,
	    p_QUOTE_LINE_ID  => NULL,
	    p_QUOTE_SHIPMENT_ID  => l_tax_detail_rec.quote_shipment_id,
	    p_ORIG_TAX_CODE  => l_tax_detail_rec.ORIG_TAX_CODE,
	    p_TAX_CODE	=> l_tax_detail_rec.TAX_CODE,
	    p_TAX_RATE	=> l_tax_detail_rec.TAX_RATE,
	    p_TAX_DATE	=> l_tax_detail_rec.TAX_DATE,
	    p_TAX_AMOUNT  => l_tax_detail_rec.TAX_AMOUNT,
	    p_TAX_EXEMPT_FLAG  => l_tax_detail_rec.TAX_EXEMPT_FLAG,
	    p_TAX_EXEMPT_NUMBER  => l_tax_detail_rec.TAX_EXEMPT_NUMBER,
	    p_TAX_EXEMPT_REASON_CODE  => l_tax_detail_rec.TAX_EXEMPT_REASON_CODE,
	    p_ATTRIBUTE_CATEGORY  => l_tax_detail_rec.ATTRIBUTE_CATEGORY,
	    p_ATTRIBUTE1  => l_tax_detail_rec.ATTRIBUTE1,
	    p_ATTRIBUTE2  => l_tax_detail_rec.ATTRIBUTE2,
	    p_ATTRIBUTE3  => l_tax_detail_rec.ATTRIBUTE3,
	    p_ATTRIBUTE4  => l_tax_detail_rec.ATTRIBUTE4,
	    p_ATTRIBUTE5  => l_tax_detail_rec.ATTRIBUTE5,
	    p_ATTRIBUTE6  => l_tax_detail_rec.ATTRIBUTE6,
	    p_ATTRIBUTE7  => l_tax_detail_rec.ATTRIBUTE7,
	    p_ATTRIBUTE8  => l_tax_detail_rec.ATTRIBUTE8,
	    p_ATTRIBUTE9  => l_tax_detail_rec.ATTRIBUTE9,
	    p_ATTRIBUTE10  => l_tax_detail_rec.ATTRIBUTE10,
	    p_ATTRIBUTE11  => l_tax_detail_rec.ATTRIBUTE11,
	    p_ATTRIBUTE12  => l_tax_detail_rec.ATTRIBUTE12,
	    p_ATTRIBUTE13  => l_tax_detail_rec.ATTRIBUTE13,
	    p_ATTRIBUTE14  => l_tax_detail_rec.ATTRIBUTE14,
	    p_ATTRIBUTE15  => l_tax_detail_rec.ATTRIBUTE15,
	     p_ATTRIBUTE16  =>  l_tax_detail_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  =>  l_tax_detail_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  =>  l_tax_detail_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  =>  l_tax_detail_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  =>  l_tax_detail_rec.ATTRIBUTE20,
	    p_TAX_INCLUSIVE_FLAG  => l_tax_detail_rec.TAX_INCLUSIVE_FLAG,
	    p_OBJECT_VERSION_NUMBER  => l_tax_detail_rec.OBJECT_VERSION_NUMBER,
	    p_TAX_RATE_ID => l_tax_detail_rec.TAX_RATE_ID
	    );

      ELSIF P_Tax_Detail_Tbl(i).operation_code = 'UPDATE' THEN
      l_sysdate := sysdate;
	l_tax_detail_rec := x_tax_detail_tbl(i);
    x_tax_detail_tbl(i).LAST_UPDATE_DATE := l_sysdate;
	ASO_TAX_DETAILS_PKG.update_Row(
	    p_TAX_DETAIL_ID  => l_tax_detail_rec.TAX_DETAIL_ID,
	    p_CREATION_DATE  => l_tax_detail_rec.creation_date,
	    p_CREATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_DATE	=> l_sysdate,
	    p_LAST_UPDATED_BY  => G_USER_ID,
	    p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	    p_REQUEST_ID  => l_tax_detail_rec.REQUEST_ID,
	    p_PROGRAM_APPLICATION_ID  => l_tax_detail_rec.PROGRAM_APPLICATION_ID,
	    p_PROGRAM_ID  => l_tax_detail_rec.PROGRAM_ID,
	    p_PROGRAM_UPDATE_DATE  => l_tax_detail_rec.PROGRAM_UPDATE_DATE,
	    p_QUOTE_HEADER_ID  => l_Qte_HEADER_ID,
	    p_QUOTE_LINE_ID  => NULL,
	    p_QUOTE_SHIPMENT_ID  => l_tax_detail_rec.quote_shipment_id,
	    p_ORIG_TAX_CODE  => l_tax_detail_rec.ORIG_TAX_CODE,
	    p_TAX_CODE	=> l_tax_detail_rec.TAX_CODE,
	    p_TAX_RATE	=> l_tax_detail_rec.TAX_RATE,
	    p_TAX_DATE	=> l_tax_detail_rec.TAX_DATE,
	    p_TAX_AMOUNT  => l_tax_detail_rec.TAX_AMOUNT,
	    p_TAX_EXEMPT_FLAG  => l_tax_detail_rec.TAX_EXEMPT_FLAG,
	    p_TAX_EXEMPT_NUMBER  => l_tax_detail_rec.TAX_EXEMPT_NUMBER,
	    p_TAX_EXEMPT_REASON_CODE  => l_tax_detail_rec.TAX_EXEMPT_REASON_CODE,
	    p_ATTRIBUTE_CATEGORY  => l_tax_detail_rec.ATTRIBUTE_CATEGORY,
	    p_ATTRIBUTE1  => l_tax_detail_rec.ATTRIBUTE1,
	    p_ATTRIBUTE2  => l_tax_detail_rec.ATTRIBUTE2,
	    p_ATTRIBUTE3  => l_tax_detail_rec.ATTRIBUTE3,
	    p_ATTRIBUTE4  => l_tax_detail_rec.ATTRIBUTE4,
	    p_ATTRIBUTE5  => l_tax_detail_rec.ATTRIBUTE5,
	    p_ATTRIBUTE6  => l_tax_detail_rec.ATTRIBUTE6,
	    p_ATTRIBUTE7  => l_tax_detail_rec.ATTRIBUTE7,
	    p_ATTRIBUTE8  => l_tax_detail_rec.ATTRIBUTE8,
	    p_ATTRIBUTE9  => l_tax_detail_rec.ATTRIBUTE9,
	    p_ATTRIBUTE10  => l_tax_detail_rec.ATTRIBUTE10,
	    p_ATTRIBUTE11  => l_tax_detail_rec.ATTRIBUTE11,
	    p_ATTRIBUTE12  => l_tax_detail_rec.ATTRIBUTE12,
	    p_ATTRIBUTE13  => l_tax_detail_rec.ATTRIBUTE13,
	    p_ATTRIBUTE14  => l_tax_detail_rec.ATTRIBUTE14,
	    p_ATTRIBUTE15  => l_tax_detail_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  => l_tax_detail_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  => l_tax_detail_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  => l_tax_detail_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  => l_tax_detail_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  => l_tax_detail_rec.ATTRIBUTE20,
	    p_TAX_INCLUSIVE_FLAG  => l_tax_detail_rec.TAX_INCLUSIVE_FLAG,
	    p_OBJECT_VERSION_NUMBER  => l_tax_detail_rec.OBJECT_VERSION_NUMBER,
	    p_TAX_RATE_ID => l_tax_detail_rec.TAX_RATE_ID
	    );
      ELSIF P_Tax_Detail_Tbl(i).operation_code = 'DELETE' THEN
	ASO_TAX_DETAILS_PKG.Delete_Row(
	    p_TAX_DETAIL_ID  => P_Tax_Detail_Tbl(i).TAX_DETAIL_ID);
      END IF;
    END LOOP;


   -- check for duplicate promotions, see bug 4521799
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Before  calling Validate_Promotion price_attr_tbl.count: '|| p_price_attributes_tbl.count, 1, 'Y');
  END IF;

  ASO_VALIDATE_PVT.Validate_Promotion (
     P_Api_Version_Number       => 1.0,
     P_Init_Msg_List            => FND_API.G_FALSE,
     P_Commit                   => FND_API.G_FALSE,
     p_price_attr_tbl           => p_price_attributes_tbl,
     x_price_attr_tbl           => lx_price_attr_tbl,
     x_return_status            => x_return_status,
     x_msg_count                => x_msg_count,
     x_msg_data                 => x_msg_data);

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('after calling Validate_Promotion ', 1, 'Y');
      aso_debug_pub.add('Validate_Promotion  Return Status: '||x_return_status, 1, 'Y');
   END IF;

   if x_return_status <> fnd_api.g_ret_sts_success then
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   end if;


 -- end of check for duplicate promotions



   -- Added to support the pricing attributes at header level


    FOR i in 1..p_Price_Attributes_Tbl.count LOOP

     l_price_attributes_rec := p_Price_Attributes_Tbl(i);
    -- l_price_attributes_rec.quote_line_id := p_qte_line_rec.quote_line_id;
     x_price_attributes_tbl(i) := l_price_attributes_rec;

     IF l_price_attributes_rec.operation_code = 'CREATE' THEN

      l_price_attributes_rec.quote_header_id := l_qte_header_id;
        -- BC4J Fix
	   --x_price_attributes_tbl(1).price_attribute_id := NULL;

   ASO_PRICE_ATTRIBUTES_PKG.Insert_Row(
          px_PRICE_ATTRIBUTE_ID   => x_price_attributes_tbl(i).price_attribute_id,
          p_CREATION_DATE  	=> SYSDATE,
          p_CREATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_DATE  	=> SYSDATE,
          p_LAST_UPDATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_LOGIN  	=> G_LOGIN_ID,
          p_REQUEST_ID  	=> l_price_attributes_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_price_attributes_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  	=> l_price_attributes_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_price_attributes_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID      => l_price_attributes_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID        => null,
          p_FLEX_TITLE           => l_price_attributes_rec.flex_title,
          p_PRICING_CONTEXT      => l_price_attributes_rec.pricing_context,
          p_PRICING_ATTRIBUTE1    => l_price_attributes_rec.PRICING_ATTRIBUTE1,
          p_PRICING_ATTRIBUTE2    => l_price_attributes_rec.PRICING_ATTRIBUTE2,
          p_PRICING_ATTRIBUTE3    => l_price_attributes_rec.PRICING_ATTRIBUTE3,
          p_PRICING_ATTRIBUTE4    => l_price_attributes_rec.PRICING_ATTRIBUTE4,
          p_PRICING_ATTRIBUTE5    => l_price_attributes_rec.PRICING_ATTRIBUTE5,
          p_PRICING_ATTRIBUTE6    => l_price_attributes_rec.PRICING_ATTRIBUTE6,
          p_PRICING_ATTRIBUTE7    => l_price_attributes_rec.PRICING_ATTRIBUTE7,
          p_PRICING_ATTRIBUTE8    => l_price_attributes_rec.PRICING_ATTRIBUTE8,
          p_PRICING_ATTRIBUTE9    => l_price_attributes_rec.PRICING_ATTRIBUTE9,
        p_PRICING_ATTRIBUTE10    => l_price_attributes_rec.PRICING_ATTRIBUTE10,
        p_PRICING_ATTRIBUTE11    => l_price_attributes_rec.PRICING_ATTRIBUTE11,
        p_PRICING_ATTRIBUTE12    => l_price_attributes_rec.PRICING_ATTRIBUTE12,
        p_PRICING_ATTRIBUTE13    => l_price_attributes_rec.PRICING_ATTRIBUTE13,
        p_PRICING_ATTRIBUTE14    => l_price_attributes_rec.PRICING_ATTRIBUTE14,
        p_PRICING_ATTRIBUTE15    => l_price_attributes_rec.PRICING_ATTRIBUTE15,
        p_PRICING_ATTRIBUTE16    => l_price_attributes_rec.PRICING_ATTRIBUTE16,
        p_PRICING_ATTRIBUTE17    => l_price_attributes_rec.PRICING_ATTRIBUTE17,
        p_PRICING_ATTRIBUTE18    => l_price_attributes_rec.PRICING_ATTRIBUTE18,
        p_PRICING_ATTRIBUTE19    => l_price_attributes_rec.PRICING_ATTRIBUTE19,
        p_PRICING_ATTRIBUTE20    => l_price_attributes_rec.PRICING_ATTRIBUTE20,
        p_PRICING_ATTRIBUTE21    => l_price_attributes_rec.PRICING_ATTRIBUTE21,
        p_PRICING_ATTRIBUTE22    => l_price_attributes_rec.PRICING_ATTRIBUTE22,
        p_PRICING_ATTRIBUTE23    => l_price_attributes_rec.PRICING_ATTRIBUTE23,
        p_PRICING_ATTRIBUTE24    => l_price_attributes_rec.PRICING_ATTRIBUTE24,
        p_PRICING_ATTRIBUTE25    => l_price_attributes_rec.PRICING_ATTRIBUTE25,
        p_PRICING_ATTRIBUTE26    => l_price_attributes_rec.PRICING_ATTRIBUTE26,
        p_PRICING_ATTRIBUTE27    => l_price_attributes_rec.PRICING_ATTRIBUTE27,
        p_PRICING_ATTRIBUTE28    => l_price_attributes_rec.PRICING_ATTRIBUTE28,
        p_PRICING_ATTRIBUTE29    => l_price_attributes_rec.PRICING_ATTRIBUTE29,
        p_PRICING_ATTRIBUTE30    => l_price_attributes_rec.PRICING_ATTRIBUTE30,
        p_PRICING_ATTRIBUTE31    => l_price_attributes_rec.PRICING_ATTRIBUTE31,
        p_PRICING_ATTRIBUTE32    => l_price_attributes_rec.PRICING_ATTRIBUTE32,
        p_PRICING_ATTRIBUTE33    => l_price_attributes_rec.PRICING_ATTRIBUTE33,
        p_PRICING_ATTRIBUTE34    => l_price_attributes_rec.PRICING_ATTRIBUTE34,
        p_PRICING_ATTRIBUTE35    => l_price_attributes_rec.PRICING_ATTRIBUTE35,
        p_PRICING_ATTRIBUTE36    => l_price_attributes_rec.PRICING_ATTRIBUTE36,
        p_PRICING_ATTRIBUTE37    => l_price_attributes_rec.PRICING_ATTRIBUTE37,
        p_PRICING_ATTRIBUTE38    => l_price_attributes_rec.PRICING_ATTRIBUTE38,
        p_PRICING_ATTRIBUTE39    => l_price_attributes_rec.PRICING_ATTRIBUTE39,
        p_PRICING_ATTRIBUTE40    => l_price_attributes_rec.PRICING_ATTRIBUTE40,
        p_PRICING_ATTRIBUTE41    => l_price_attributes_rec.PRICING_ATTRIBUTE41,
        p_PRICING_ATTRIBUTE42    => l_price_attributes_rec.PRICING_ATTRIBUTE42,
        p_PRICING_ATTRIBUTE43    => l_price_attributes_rec.PRICING_ATTRIBUTE43,
        p_PRICING_ATTRIBUTE44    => l_price_attributes_rec.PRICING_ATTRIBUTE44,
        p_PRICING_ATTRIBUTE45    => l_price_attributes_rec.PRICING_ATTRIBUTE45,
        p_PRICING_ATTRIBUTE46    => l_price_attributes_rec.PRICING_ATTRIBUTE46,
        p_PRICING_ATTRIBUTE47    => l_price_attributes_rec.PRICING_ATTRIBUTE47,
        p_PRICING_ATTRIBUTE48    => l_price_attributes_rec.PRICING_ATTRIBUTE48,
        p_PRICING_ATTRIBUTE49    => l_price_attributes_rec.PRICING_ATTRIBUTE49,
        p_PRICING_ATTRIBUTE50    => l_price_attributes_rec.PRICING_ATTRIBUTE50,
        p_PRICING_ATTRIBUTE51    => l_price_attributes_rec.PRICING_ATTRIBUTE51,
        p_PRICING_ATTRIBUTE52    => l_price_attributes_rec.PRICING_ATTRIBUTE52,
        p_PRICING_ATTRIBUTE53    => l_price_attributes_rec.PRICING_ATTRIBUTE53,
        p_PRICING_ATTRIBUTE54    => l_price_attributes_rec.PRICING_ATTRIBUTE54,
        p_PRICING_ATTRIBUTE55    => l_price_attributes_rec.PRICING_ATTRIBUTE55,
        p_PRICING_ATTRIBUTE56    => l_price_attributes_rec.PRICING_ATTRIBUTE56,
        p_PRICING_ATTRIBUTE57    => l_price_attributes_rec.PRICING_ATTRIBUTE57,
        p_PRICING_ATTRIBUTE58    => l_price_attributes_rec.PRICING_ATTRIBUTE58,
        p_PRICING_ATTRIBUTE59    => l_price_attributes_rec.PRICING_ATTRIBUTE59,
        p_PRICING_ATTRIBUTE60    => l_price_attributes_rec.PRICING_ATTRIBUTE60,
        p_PRICING_ATTRIBUTE61    => l_price_attributes_rec.PRICING_ATTRIBUTE61,
        p_PRICING_ATTRIBUTE62    => l_price_attributes_rec.PRICING_ATTRIBUTE62,
        p_PRICING_ATTRIBUTE63    => l_price_attributes_rec.PRICING_ATTRIBUTE63,
        p_PRICING_ATTRIBUTE64    => l_price_attributes_rec.PRICING_ATTRIBUTE64,
        p_PRICING_ATTRIBUTE65    => l_price_attributes_rec.PRICING_ATTRIBUTE65,
        p_PRICING_ATTRIBUTE66    => l_price_attributes_rec.PRICING_ATTRIBUTE66,
        p_PRICING_ATTRIBUTE67    => l_price_attributes_rec.PRICING_ATTRIBUTE67,
        p_PRICING_ATTRIBUTE68    => l_price_attributes_rec.PRICING_ATTRIBUTE68,
        p_PRICING_ATTRIBUTE69    => l_price_attributes_rec.PRICING_ATTRIBUTE69,
        p_PRICING_ATTRIBUTE70    => l_price_attributes_rec.PRICING_ATTRIBUTE70,
        p_PRICING_ATTRIBUTE71    => l_price_attributes_rec.PRICING_ATTRIBUTE71,
        p_PRICING_ATTRIBUTE72    => l_price_attributes_rec.PRICING_ATTRIBUTE72,
        p_PRICING_ATTRIBUTE73    => l_price_attributes_rec.PRICING_ATTRIBUTE73,
        p_PRICING_ATTRIBUTE74    => l_price_attributes_rec.PRICING_ATTRIBUTE74,
        p_PRICING_ATTRIBUTE75    => l_price_attributes_rec.PRICING_ATTRIBUTE75,
        p_PRICING_ATTRIBUTE76    => l_price_attributes_rec.PRICING_ATTRIBUTE76,
        p_PRICING_ATTRIBUTE77    => l_price_attributes_rec.PRICING_ATTRIBUTE77,
        p_PRICING_ATTRIBUTE78    => l_price_attributes_rec.PRICING_ATTRIBUTE78,
        p_PRICING_ATTRIBUTE79    => l_price_attributes_rec.PRICING_ATTRIBUTE79,
        p_PRICING_ATTRIBUTE80    => l_price_attributes_rec.PRICING_ATTRIBUTE80,
        p_PRICING_ATTRIBUTE81    => l_price_attributes_rec.PRICING_ATTRIBUTE81,
        p_PRICING_ATTRIBUTE82    => l_price_attributes_rec.PRICING_ATTRIBUTE82,
        p_PRICING_ATTRIBUTE83    => l_price_attributes_rec.PRICING_ATTRIBUTE83,
        p_PRICING_ATTRIBUTE84    => l_price_attributes_rec.PRICING_ATTRIBUTE84,
        p_PRICING_ATTRIBUTE85    => l_price_attributes_rec.PRICING_ATTRIBUTE85,
        p_PRICING_ATTRIBUTE86    => l_price_attributes_rec.PRICING_ATTRIBUTE86,
        p_PRICING_ATTRIBUTE87    => l_price_attributes_rec.PRICING_ATTRIBUTE87,
        p_PRICING_ATTRIBUTE88    => l_price_attributes_rec.PRICING_ATTRIBUTE88,
        p_PRICING_ATTRIBUTE89    => l_price_attributes_rec.PRICING_ATTRIBUTE89,
        p_PRICING_ATTRIBUTE90    => l_price_attributes_rec.PRICING_ATTRIBUTE90,
        p_PRICING_ATTRIBUTE91    => l_price_attributes_rec.PRICING_ATTRIBUTE91,
        p_PRICING_ATTRIBUTE92    => l_price_attributes_rec.PRICING_ATTRIBUTE92,
        p_PRICING_ATTRIBUTE93    => l_price_attributes_rec.PRICING_ATTRIBUTE93,
        p_PRICING_ATTRIBUTE94    => l_price_attributes_rec.PRICING_ATTRIBUTE94,
        p_PRICING_ATTRIBUTE95    => l_price_attributes_rec.PRICING_ATTRIBUTE95,
        p_PRICING_ATTRIBUTE96    => l_price_attributes_rec.PRICING_ATTRIBUTE96,
        p_PRICING_ATTRIBUTE97    => l_price_attributes_rec.PRICING_ATTRIBUTE97,
        p_PRICING_ATTRIBUTE98    => l_price_attributes_rec.PRICING_ATTRIBUTE98,
        p_PRICING_ATTRIBUTE99    => l_price_attributes_rec.PRICING_ATTRIBUTE99,
        p_PRICING_ATTRIBUTE100  => l_price_attributes_rec.PRICING_ATTRIBUTE100,
          p_CONTEXT    => l_price_attributes_rec.CONTEXT,
          p_ATTRIBUTE1    => l_price_attributes_rec.ATTRIBUTE1,
          p_ATTRIBUTE2    => l_price_attributes_rec.ATTRIBUTE2,
          p_ATTRIBUTE3    => l_price_attributes_rec.ATTRIBUTE3,
          p_ATTRIBUTE4    => l_price_attributes_rec.ATTRIBUTE4,
          p_ATTRIBUTE5    => l_price_attributes_rec.ATTRIBUTE5,
          p_ATTRIBUTE6    => l_price_attributes_rec.ATTRIBUTE6,
          p_ATTRIBUTE7    => l_price_attributes_rec.ATTRIBUTE7,
          p_ATTRIBUTE8    => l_price_attributes_rec.ATTRIBUTE8,
          p_ATTRIBUTE9    => l_price_attributes_rec.ATTRIBUTE9,
          p_ATTRIBUTE10    => l_price_attributes_rec.ATTRIBUTE10,
          p_ATTRIBUTE11    => l_price_attributes_rec.ATTRIBUTE11,
          p_ATTRIBUTE12    => l_price_attributes_rec.ATTRIBUTE12,
          p_ATTRIBUTE13    => l_price_attributes_rec.ATTRIBUTE13,
          p_ATTRIBUTE14    => l_price_attributes_rec.ATTRIBUTE14,
          p_ATTRIBUTE15    => l_price_attributes_rec.ATTRIBUTE15,
	     p_ATTRIBUTE16    => l_price_attributes_rec.ATTRIBUTE16,
          p_ATTRIBUTE17    => l_price_attributes_rec.ATTRIBUTE17,
          p_ATTRIBUTE18    => l_price_attributes_rec.ATTRIBUTE18,
          p_ATTRIBUTE19    => l_price_attributes_rec.ATTRIBUTE19,
          p_ATTRIBUTE20    => l_price_attributes_rec.ATTRIBUTE20,
	    p_OBJECT_VERSION_NUMBER  => l_price_attributes_rec.OBJECT_VERSION_NUMBER
);


   ELSIF l_price_attributes_rec.operation_code = 'UPDATE' THEN

ASO_PRICE_ATTRIBUTES_PKG.Update_Row(
          p_PRICE_ATTRIBUTE_ID  => l_price_attributes_rec.price_attribute_id,
          p_CREATION_DATE  	=> l_price_attributes_rec.creation_date,
          p_CREATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_DATE  	=> SYSDATE,
          p_LAST_UPDATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_LOGIN  	=> G_LOGIN_ID,
          p_REQUEST_ID  	=> l_price_attributes_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_price_attributes_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  	 => l_price_attributes_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_price_attributes_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID      => l_price_attributes_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID        => l_price_attributes_rec.quote_line_id,
          p_FLEX_TITLE           => l_price_attributes_rec.flex_title,
          p_PRICING_CONTEXT      => l_price_attributes_rec.pricing_context,
          p_PRICING_ATTRIBUTE1    => l_price_attributes_rec.PRICING_ATTRIBUTE1,
          p_PRICING_ATTRIBUTE2    => l_price_attributes_rec.PRICING_ATTRIBUTE2,
          p_PRICING_ATTRIBUTE3    => l_price_attributes_rec.PRICING_ATTRIBUTE3,
          p_PRICING_ATTRIBUTE4    => l_price_attributes_rec.PRICING_ATTRIBUTE4,
          p_PRICING_ATTRIBUTE5    => l_price_attributes_rec.PRICING_ATTRIBUTE5,
          p_PRICING_ATTRIBUTE6    => l_price_attributes_rec.PRICING_ATTRIBUTE6,
          p_PRICING_ATTRIBUTE7    => l_price_attributes_rec.PRICING_ATTRIBUTE7,
          p_PRICING_ATTRIBUTE8    => l_price_attributes_rec.PRICING_ATTRIBUTE8,
          p_PRICING_ATTRIBUTE9    => l_price_attributes_rec.PRICING_ATTRIBUTE9,
        p_PRICING_ATTRIBUTE10    => l_price_attributes_rec.PRICING_ATTRIBUTE10,
        p_PRICING_ATTRIBUTE11    => l_price_attributes_rec.PRICING_ATTRIBUTE11,
        p_PRICING_ATTRIBUTE12    => l_price_attributes_rec.PRICING_ATTRIBUTE12,
        p_PRICING_ATTRIBUTE13    => l_price_attributes_rec.PRICING_ATTRIBUTE13,
        p_PRICING_ATTRIBUTE14    => l_price_attributes_rec.PRICING_ATTRIBUTE14,
        p_PRICING_ATTRIBUTE15    => l_price_attributes_rec.PRICING_ATTRIBUTE15,
        p_PRICING_ATTRIBUTE16    => l_price_attributes_rec.PRICING_ATTRIBUTE16,
        p_PRICING_ATTRIBUTE17    => l_price_attributes_rec.PRICING_ATTRIBUTE17,
        p_PRICING_ATTRIBUTE18    => l_price_attributes_rec.PRICING_ATTRIBUTE18,
        p_PRICING_ATTRIBUTE19    => l_price_attributes_rec.PRICING_ATTRIBUTE19,
        p_PRICING_ATTRIBUTE20    => l_price_attributes_rec.PRICING_ATTRIBUTE20,
        p_PRICING_ATTRIBUTE21    => l_price_attributes_rec.PRICING_ATTRIBUTE21,
        p_PRICING_ATTRIBUTE22    => l_price_attributes_rec.PRICING_ATTRIBUTE22,
        p_PRICING_ATTRIBUTE23    => l_price_attributes_rec.PRICING_ATTRIBUTE23,
        p_PRICING_ATTRIBUTE24    => l_price_attributes_rec.PRICING_ATTRIBUTE24,
        p_PRICING_ATTRIBUTE25    => l_price_attributes_rec.PRICING_ATTRIBUTE25,
        p_PRICING_ATTRIBUTE26    => l_price_attributes_rec.PRICING_ATTRIBUTE26,
        p_PRICING_ATTRIBUTE27    => l_price_attributes_rec.PRICING_ATTRIBUTE27,
        p_PRICING_ATTRIBUTE28    => l_price_attributes_rec.PRICING_ATTRIBUTE28,
        p_PRICING_ATTRIBUTE29    => l_price_attributes_rec.PRICING_ATTRIBUTE29,
        p_PRICING_ATTRIBUTE30    => l_price_attributes_rec.PRICING_ATTRIBUTE30,
        p_PRICING_ATTRIBUTE31    => l_price_attributes_rec.PRICING_ATTRIBUTE31,
        p_PRICING_ATTRIBUTE32    => l_price_attributes_rec.PRICING_ATTRIBUTE32,
        p_PRICING_ATTRIBUTE33    => l_price_attributes_rec.PRICING_ATTRIBUTE33,
        p_PRICING_ATTRIBUTE34    => l_price_attributes_rec.PRICING_ATTRIBUTE34,
        p_PRICING_ATTRIBUTE35    => l_price_attributes_rec.PRICING_ATTRIBUTE35,
        p_PRICING_ATTRIBUTE36    => l_price_attributes_rec.PRICING_ATTRIBUTE36,
        p_PRICING_ATTRIBUTE37    => l_price_attributes_rec.PRICING_ATTRIBUTE37,
        p_PRICING_ATTRIBUTE38    => l_price_attributes_rec.PRICING_ATTRIBUTE38,
        p_PRICING_ATTRIBUTE39    => l_price_attributes_rec.PRICING_ATTRIBUTE39,
        p_PRICING_ATTRIBUTE40    => l_price_attributes_rec.PRICING_ATTRIBUTE40,
        p_PRICING_ATTRIBUTE41    => l_price_attributes_rec.PRICING_ATTRIBUTE41,
        p_PRICING_ATTRIBUTE42    => l_price_attributes_rec.PRICING_ATTRIBUTE42,
        p_PRICING_ATTRIBUTE43    => l_price_attributes_rec.PRICING_ATTRIBUTE43,
        p_PRICING_ATTRIBUTE44    => l_price_attributes_rec.PRICING_ATTRIBUTE44,
        p_PRICING_ATTRIBUTE45    => l_price_attributes_rec.PRICING_ATTRIBUTE45,
        p_PRICING_ATTRIBUTE46    => l_price_attributes_rec.PRICING_ATTRIBUTE46,
        p_PRICING_ATTRIBUTE47    => l_price_attributes_rec.PRICING_ATTRIBUTE47,
        p_PRICING_ATTRIBUTE48    => l_price_attributes_rec.PRICING_ATTRIBUTE48,
        p_PRICING_ATTRIBUTE49    => l_price_attributes_rec.PRICING_ATTRIBUTE49,
        p_PRICING_ATTRIBUTE50    => l_price_attributes_rec.PRICING_ATTRIBUTE50,
        p_PRICING_ATTRIBUTE51    => l_price_attributes_rec.PRICING_ATTRIBUTE51,
        p_PRICING_ATTRIBUTE52    => l_price_attributes_rec.PRICING_ATTRIBUTE52,
        p_PRICING_ATTRIBUTE53    => l_price_attributes_rec.PRICING_ATTRIBUTE53,
        p_PRICING_ATTRIBUTE54    => l_price_attributes_rec.PRICING_ATTRIBUTE54,
        p_PRICING_ATTRIBUTE55    => l_price_attributes_rec.PRICING_ATTRIBUTE55,
        p_PRICING_ATTRIBUTE56    => l_price_attributes_rec.PRICING_ATTRIBUTE56,
        p_PRICING_ATTRIBUTE57    => l_price_attributes_rec.PRICING_ATTRIBUTE57,
        p_PRICING_ATTRIBUTE58    => l_price_attributes_rec.PRICING_ATTRIBUTE58,
        p_PRICING_ATTRIBUTE59    => l_price_attributes_rec.PRICING_ATTRIBUTE59,
        p_PRICING_ATTRIBUTE60    => l_price_attributes_rec.PRICING_ATTRIBUTE60,
        p_PRICING_ATTRIBUTE61    => l_price_attributes_rec.PRICING_ATTRIBUTE61,
        p_PRICING_ATTRIBUTE62    => l_price_attributes_rec.PRICING_ATTRIBUTE62,
        p_PRICING_ATTRIBUTE63    => l_price_attributes_rec.PRICING_ATTRIBUTE63,
        p_PRICING_ATTRIBUTE64    => l_price_attributes_rec.PRICING_ATTRIBUTE64,
        p_PRICING_ATTRIBUTE65    => l_price_attributes_rec.PRICING_ATTRIBUTE65,
        p_PRICING_ATTRIBUTE66    => l_price_attributes_rec.PRICING_ATTRIBUTE66,
        p_PRICING_ATTRIBUTE67    => l_price_attributes_rec.PRICING_ATTRIBUTE67,
        p_PRICING_ATTRIBUTE68    => l_price_attributes_rec.PRICING_ATTRIBUTE68,
        p_PRICING_ATTRIBUTE69    => l_price_attributes_rec.PRICING_ATTRIBUTE69,
        p_PRICING_ATTRIBUTE70    => l_price_attributes_rec.PRICING_ATTRIBUTE70,
        p_PRICING_ATTRIBUTE71    => l_price_attributes_rec.PRICING_ATTRIBUTE71,
        p_PRICING_ATTRIBUTE72    => l_price_attributes_rec.PRICING_ATTRIBUTE72,
        p_PRICING_ATTRIBUTE73    => l_price_attributes_rec.PRICING_ATTRIBUTE73,
        p_PRICING_ATTRIBUTE74    => l_price_attributes_rec.PRICING_ATTRIBUTE74,
        p_PRICING_ATTRIBUTE75    => l_price_attributes_rec.PRICING_ATTRIBUTE75,
        p_PRICING_ATTRIBUTE76    => l_price_attributes_rec.PRICING_ATTRIBUTE76,
        p_PRICING_ATTRIBUTE77    => l_price_attributes_rec.PRICING_ATTRIBUTE77,
        p_PRICING_ATTRIBUTE78    => l_price_attributes_rec.PRICING_ATTRIBUTE78,
        p_PRICING_ATTRIBUTE79    => l_price_attributes_rec.PRICING_ATTRIBUTE79,
        p_PRICING_ATTRIBUTE80    => l_price_attributes_rec.PRICING_ATTRIBUTE80,
        p_PRICING_ATTRIBUTE81    => l_price_attributes_rec.PRICING_ATTRIBUTE81,
        p_PRICING_ATTRIBUTE82    => l_price_attributes_rec.PRICING_ATTRIBUTE82,
        p_PRICING_ATTRIBUTE83    => l_price_attributes_rec.PRICING_ATTRIBUTE83,
        p_PRICING_ATTRIBUTE84    => l_price_attributes_rec.PRICING_ATTRIBUTE84,
        p_PRICING_ATTRIBUTE85    => l_price_attributes_rec.PRICING_ATTRIBUTE85,
        p_PRICING_ATTRIBUTE86    => l_price_attributes_rec.PRICING_ATTRIBUTE86,
        p_PRICING_ATTRIBUTE87    => l_price_attributes_rec.PRICING_ATTRIBUTE87,
        p_PRICING_ATTRIBUTE88    => l_price_attributes_rec.PRICING_ATTRIBUTE88,
        p_PRICING_ATTRIBUTE89    => l_price_attributes_rec.PRICING_ATTRIBUTE89,
        p_PRICING_ATTRIBUTE90    => l_price_attributes_rec.PRICING_ATTRIBUTE90,
        p_PRICING_ATTRIBUTE91    => l_price_attributes_rec.PRICING_ATTRIBUTE91,
        p_PRICING_ATTRIBUTE92    => l_price_attributes_rec.PRICING_ATTRIBUTE92,
        p_PRICING_ATTRIBUTE93    => l_price_attributes_rec.PRICING_ATTRIBUTE93,
        p_PRICING_ATTRIBUTE94    => l_price_attributes_rec.PRICING_ATTRIBUTE94,
        p_PRICING_ATTRIBUTE95    => l_price_attributes_rec.PRICING_ATTRIBUTE95,
        p_PRICING_ATTRIBUTE96    => l_price_attributes_rec.PRICING_ATTRIBUTE96,
        p_PRICING_ATTRIBUTE97    => l_price_attributes_rec.PRICING_ATTRIBUTE97,
        p_PRICING_ATTRIBUTE98    => l_price_attributes_rec.PRICING_ATTRIBUTE98,
        p_PRICING_ATTRIBUTE99    => l_price_attributes_rec.PRICING_ATTRIBUTE99,
        p_PRICING_ATTRIBUTE100  => l_price_attributes_rec.PRICING_ATTRIBUTE100,
          p_CONTEXT    => l_price_attributes_rec.CONTEXT,
          p_ATTRIBUTE1    => l_price_attributes_rec.ATTRIBUTE1,
          p_ATTRIBUTE2    => l_price_attributes_rec.ATTRIBUTE2,
          p_ATTRIBUTE3    => l_price_attributes_rec.ATTRIBUTE3,
          p_ATTRIBUTE4    => l_price_attributes_rec.ATTRIBUTE4,
          p_ATTRIBUTE5    => l_price_attributes_rec.ATTRIBUTE5,
          p_ATTRIBUTE6    => l_price_attributes_rec.ATTRIBUTE6,
          p_ATTRIBUTE7    => l_price_attributes_rec.ATTRIBUTE7,
          p_ATTRIBUTE8    => l_price_attributes_rec.ATTRIBUTE8,
          p_ATTRIBUTE9    => l_price_attributes_rec.ATTRIBUTE9,
          p_ATTRIBUTE10    => l_price_attributes_rec.ATTRIBUTE10,
          p_ATTRIBUTE11    => l_price_attributes_rec.ATTRIBUTE11,
          p_ATTRIBUTE12    => l_price_attributes_rec.ATTRIBUTE12,
          p_ATTRIBUTE13    => l_price_attributes_rec.ATTRIBUTE13,
          p_ATTRIBUTE14    => l_price_attributes_rec.ATTRIBUTE14,
          p_ATTRIBUTE15    => l_price_attributes_rec.ATTRIBUTE15,
	     p_ATTRIBUTE16    => l_price_attributes_rec.ATTRIBUTE16,
          p_ATTRIBUTE17    => l_price_attributes_rec.ATTRIBUTE17,
          p_ATTRIBUTE18    => l_price_attributes_rec.ATTRIBUTE18,
          p_ATTRIBUTE19    => l_price_attributes_rec.ATTRIBUTE19,
          p_ATTRIBUTE20    => l_price_attributes_rec.ATTRIBUTE20,
	    p_OBJECT_VERSION_NUMBER  => l_price_attributes_rec.OBJECT_VERSION_NUMBER
);

/* Commented the following code to call new api aso_pricing_int.delete_promotion 07/22/02

  ELSIF l_price_attributes_rec.operation_code = 'DELETE' THEN
  ASO_PRICE_ATTRIBUTES_PKG.Delete_Row(
       p_PRICE_ATTRIBUTE_ID   => l_price_attributes_rec.price_attribute_id);

*/

  END IF;

END LOOP;

-- New code to call aso_pricing_int.delete_promotion 07/22/02

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Update_Rows: p_Price_Attributes_Tbl.count: '||p_Price_Attributes_Tbl.count,1, 'N');
   aso_debug_pub.add('Update_Rows: Before call to aso_pricing_int.Delete_Promotion',1, 'N');
   END IF;

   IF p_Price_Attributes_Tbl.count > 0 THEN

        aso_pricing_int.Delete_Promotion (
                           P_Api_Version_Number =>  1.0,
                           P_Init_Msg_List      =>  FND_API.G_FALSE,
                           P_Commit             =>  FND_API.G_FALSE,
                           p_price_attr_tbl     =>  p_Price_Attributes_Tbl,
                           x_return_status      =>  x_return_status,
                           x_msg_count          =>  x_msg_count,
                           x_msg_data           =>  x_msg_data
                                   );

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.add('Update_Rows: After call to Delete_Promotion: x_return_status: '||x_return_status,1, 'N');
	   END IF;

   END IF;

-- End of New code to call aso_pricing_int.delete_promotion 07/22/02


-- sales credits
   FOR i in 1..p_Sales_Credit_Tbl.count LOOP

     l_Sales_Credit_rec := p_sales_credit_tbl(i);
     x_sales_credit_tbl(i) := l_sales_credit_rec;

     IF l_sales_credit_rec.operation_code = 'CREATE' THEN
       l_sales_credit_rec.quote_header_id := l_qte_header_id;
     -- BC4J Fix
	--x_sales_credit_tbl(i).sales_credit_id := NULL;
       ASO_SALES_CREDITS_PKG.Insert_Row(
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REQUEST_ID  => l_sales_CREDIT_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_sales_CREDIT_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_sales_CREDIT_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_sales_CREDIT_rec.PROGRAM_UPDATE_DATE,
          px_SALES_CREDIT_ID  => x_SALES_CREDIT_tbl(i).SALES_CREDIT_ID,
          p_QUOTE_HEADER_ID  => l_sales_CREDIT_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => l_sales_CREDIT_rec.QUOTE_LINE_ID,
          p_PERCENT  => l_sales_CREDIT_rec.PERCENT,
          p_RESOURCE_ID  => l_sales_CREDIT_rec.RESOURCE_ID,
          p_RESOURCE_GROUP_ID  => l_sales_CREDIT_rec.RESOURCE_GROUP_ID,
          p_EMPLOYEE_PERSON_ID  => l_sales_CREDIT_rec.EMPLOYEE_PERSON_ID,
          p_SALES_CREDIT_TYPE_ID  => l_sales_CREDIT_rec.SALES_CREDIT_TYPE_ID,
--          p_SECURITY_GROUP_ID  => l_sales_CREDIT_rec.SECURITY_GROUP_ID,
          p_ATTRIBUTE_CATEGORY_CODE  => l_sales_CREDIT_rec.ATTRIBUTE_CATEGORY_CODE,
          p_ATTRIBUTE1  => l_sales_CREDIT_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_sales_CREDIT_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_sales_CREDIT_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_sales_CREDIT_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_sales_CREDIT_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_sales_CREDIT_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_sales_CREDIT_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_sales_CREDIT_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_sales_CREDIT_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_sales_CREDIT_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_sales_CREDIT_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_sales_CREDIT_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_sales_CREDIT_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_sales_CREDIT_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_sales_CREDIT_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  => l_sales_CREDIT_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  => l_sales_CREDIT_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  => l_sales_CREDIT_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  => l_sales_CREDIT_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  => l_sales_CREDIT_rec.ATTRIBUTE20,
		p_SYSTEM_ASSIGNED_FLAG  => 'N',
          p_CREDIT_RULE_ID  => l_sales_CREDIT_rec.CREDIT_RULE_ID,
          p_OBJECT_VERSION_NUMBER  => l_sales_CREDIT_rec.OBJECT_VERSION_NUMBER);

        ELSIF l_sales_credit_rec.operation_code = 'UPDATE' THEN
               ASO_SALES_CREDITS_PKG.Update_Row(
          p_CREATION_DATE  => l_sales_CREDIT_rec.creation_date,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REQUEST_ID  => l_sales_CREDIT_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID=> l_sales_CREDIT_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_sales_CREDIT_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_sales_CREDIT_rec.PROGRAM_UPDATE_DATE,
          p_SALES_CREDIT_ID  => l_SALES_CREDIT_rec.SALES_CREDIT_ID,
          p_QUOTE_HEADER_ID  => l_sales_CREDIT_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => l_sales_CREDIT_rec.QUOTE_LINE_ID,
          p_PERCENT  => l_sales_CREDIT_rec.PERCENT,
          p_RESOURCE_ID  => l_sales_CREDIT_rec.RESOURCE_ID,
          p_RESOURCE_GROUP_ID  => l_sales_CREDIT_rec.RESOURCE_GROUP_ID,
          p_EMPLOYEE_PERSON_ID  => l_sales_CREDIT_rec.EMPLOYEE_PERSON_ID,
          p_SALES_CREDIT_TYPE_ID  => l_sales_CREDIT_rec.SALES_CREDIT_TYPE_ID,
--          p_SECURITY_GROUP_ID  => l_sales_CREDIT_rec.SECURITY_GROUP_ID,
          p_ATTRIBUTE_CATEGORY_CODE  => l_sales_CREDIT_rec.ATTRIBUTE_CATEGORY_CODE,
          p_ATTRIBUTE1  => l_sales_CREDIT_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_sales_CREDIT_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_sales_CREDIT_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_sales_CREDIT_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_sales_CREDIT_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_sales_CREDIT_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_sales_CREDIT_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_sales_CREDIT_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_sales_CREDIT_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_sales_CREDIT_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_sales_CREDIT_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_sales_CREDIT_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_sales_CREDIT_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_sales_CREDIT_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_sales_CREDIT_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  => l_sales_CREDIT_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  => l_sales_CREDIT_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  => l_sales_CREDIT_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  => l_sales_CREDIT_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  => l_sales_CREDIT_rec.ATTRIBUTE20,
		p_SYSTEM_ASSIGNED_FLAG  => 'N',
          p_CREDIT_RULE_ID  => l_sales_CREDIT_rec.CREDIT_RULE_ID,
          p_OBJECT_VERSION_NUMBER  => l_sales_CREDIT_rec.OBJECT_VERSION_NUMBER);
         ELSIF l_sales_credit_rec.operation_code = 'DELETE' THEN
                 ASO_SALES_CREDITS_PKG.Delete_Row(
          p_SALES_CREDIT_ID  => l_SALES_CREDIT_rec.SALES_CREDIT_ID);

         END IF;
END LOOP;
-- Quote Party
    FOR i IN 1..p_quote_party_Tbl.count LOOP
	l_quote_party_rec := p_quote_party_tbl(i);
        x_quote_party_tbl(i) := l_quote_party_rec;

       IF l_quote_party_rec.operation_code = 'CREATE' THEN
             l_quote_party_rec.quote_header_id := l_qte_header_id;
        -- BC4J Fix
	   --x_quote_party_tbl(i).QUOTE_PARTY_ID := NULL;

           ASO_QUOTE_PARTIES_PKG.Insert_Row(
          px_QUOTE_PARTY_ID  => x_quote_party_tbl(i).QUOTE_PARTY_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_REQUEST_ID  => l_QUOTE_PARTY_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  =>l_QUOTE_PARTY_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_QUOTE_PARTY_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_QUOTE_PARTY_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID  => l_QUOTE_PARTY_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => l_QUOTE_PARTY_rec.QUOTE_LINE_ID,
          p_QUOTE_SHIPMENT_ID  => l_QUOTE_PARTY_rec.QUOTE_SHIPMENT_ID,
          p_PARTY_TYPE  => l_QUOTE_PARTY_rec.PARTY_TYPE,
          p_PARTY_ID  => l_QUOTE_PARTY_rec.PARTY_ID,
          p_PARTY_OBJECT_TYPE  => l_QUOTE_PARTY_rec.PARTY_OBJECT_TYPE,
          p_PARTY_OBJECT_ID  => l_QUOTE_PARTY_rec.PARTY_OBJECT_ID,
          p_ATTRIBUTE_CATEGORY  => l_QUOTE_PARTY_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_QUOTE_PARTY_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_QUOTE_PARTY_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_QUOTE_PARTY_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_QUOTE_PARTY_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_QUOTE_PARTY_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_QUOTE_PARTY_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_QUOTE_PARTY_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_QUOTE_PARTY_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_QUOTE_PARTY_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_QUOTE_PARTY_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_QUOTE_PARTY_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_QUOTE_PARTY_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_QUOTE_PARTY_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_QUOTE_PARTY_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_QUOTE_PARTY_rec.ATTRIBUTE15,
  --          p_SECURITY_GROUP_ID  => p_QUOTE_PARTY_rec.SECURITY_GROUP_ID);
        p_OBJECT_VERSION_NUMBER  => l_QUOTE_PARTY_rec.OBJECT_VERSION_NUMBER);

        ELSIF  l_quote_party_rec.operation_code = 'UPDATE' THEN
            ASO_QUOTE_PARTIES_PKG.Update_Row(
          p_QUOTE_PARTY_ID  => l_quote_party_rec.QUOTE_PARTY_ID,
          p_CREATION_DATE  => l_quote_party_rec.creation_date,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_REQUEST_ID  => l_QUOTE_PARTY_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  =>l_QUOTE_PARTY_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_QUOTE_PARTY_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_QUOTE_PARTY_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID  => l_QUOTE_PARTY_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => l_QUOTE_PARTY_rec.QUOTE_LINE_ID,
          p_QUOTE_SHIPMENT_ID  => l_QUOTE_PARTY_rec.QUOTE_SHIPMENT_ID,
          p_PARTY_TYPE  => l_QUOTE_PARTY_rec.PARTY_TYPE,
          p_PARTY_ID  => l_QUOTE_PARTY_rec.PARTY_ID,
          p_PARTY_OBJECT_TYPE  => l_QUOTE_PARTY_rec.PARTY_OBJECT_TYPE,
          p_PARTY_OBJECT_ID  => l_QUOTE_PARTY_rec.PARTY_OBJECT_ID,
          p_ATTRIBUTE_CATEGORY  => l_QUOTE_PARTY_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_QUOTE_PARTY_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_QUOTE_PARTY_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_QUOTE_PARTY_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_QUOTE_PARTY_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_QUOTE_PARTY_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_QUOTE_PARTY_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_QUOTE_PARTY_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_QUOTE_PARTY_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_QUOTE_PARTY_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_QUOTE_PARTY_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_QUOTE_PARTY_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_QUOTE_PARTY_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_QUOTE_PARTY_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_QUOTE_PARTY_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_QUOTE_PARTY_rec.ATTRIBUTE15,
        p_OBJECT_VERSION_NUMBER  => l_QUOTE_PARTY_rec.OBJECT_VERSION_NUMBER);

        ELSIF  l_quote_party_rec.operation_code = 'DELETE' THEN
            ASO_QUOTE_PARTIES_PKG.Delete_Row(
          p_QUOTE_PARTY_ID  => l_QUOTE_PARTY_rec.QUOTE_PARTY_ID);

        END IF;
 END LOOP;
    FOR i IN 1..P_hd_Attr_Ext_Tbl.count LOOP
	l_line_attribs_rec := P_hd_Attr_Ext_Tbl(i);
     l_line_attribs_rec.quote_header_id := l_qte_header_id ;
        x_hd_Attr_Ext_Tbl(i) := l_line_attribs_rec;

     IF l_line_attribs_rec.operation_code = 'CREATE' THEN
     -- BC4J Fix
      --x_hd_Attr_Ext_Tbl(i).LINE_ATTRIBUTE_ID := null;

 ASO_QUOTE_LINE_ATTRIBS_EXT_PKG.Insert_Row(
          px_LINE_ATTRIBUTE_ID  => x_hd_Attr_Ext_Tbl(i).LINE_ATTRIBUTE_ID,
          p_CREATION_DATE          => SYSDATE,
          p_CREATED_BY             => G_USER_ID,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_LAST_UPDATED_BY        => G_USER_ID,
          p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
          p_REQUEST_ID             => l_LINE_ATTRIBS_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID =>l_LINE_ATTRIBS_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID             => l_LINE_ATTRIBS_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE    => l_LINE_ATTRIBS_rec.PROGRAM_UPDATE_DATE,
           p_APPLICATION_ID         => l_LINE_ATTRIBS_rec.APPLICATION_ID,
           p_STATUS                 => l_LINE_ATTRIBS_rec.STATUS,
          p_QUOTE_HEADER_ID          => l_LINE_ATTRIBS_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID          => l_LINE_ATTRIBS_rec.QUOTE_LINE_ID,
          p_QUOTE_SHIPMENT_ID          => l_LINE_ATTRIBS_rec.QUOTE_SHIPMENT_ID,
          p_ATTRIBUTE_TYPE_CODE    => l_LINE_ATTRIBS_rec.ATTRIBUTE_TYPE_CODE,
          p_NAME                   => l_LINE_ATTRIBS_rec.NAME,
          p_VALUE                  => l_LINE_ATTRIBS_rec.VALUE,
           p_VALUE_TYPE             => l_LINE_ATTRIBS_rec.VALUE_TYPE,
          p_START_DATE_ACTIVE      => l_LINE_ATTRIBS_rec.START_DATE_ACTIVE,
          p_END_DATE_ACTIVE        => l_LINE_ATTRIBS_rec.END_DATE_ACTIVE,
        p_OBJECT_VERSION_NUMBER  => l_LINE_ATTRIBS_rec.OBJECT_VERSION_NUMBER);

      ELSIF l_line_attribs_rec.operation_code = 'UPDATE' THEN
      ASO_QUOTE_LINE_ATTRIBS_EXT_PKG.Update_Row(
          p_LINE_ATTRIBUTE_ID  => l_LINE_ATTRIBS_REC.LINE_ATTRIBUTE_ID,
          p_CREATION_DATE          => l_LINE_ATTRIBS_REC.creation_date,
          p_CREATED_BY             => G_USER_ID,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_LAST_UPDATED_BY        => G_USER_ID,
          p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
          p_REQUEST_ID             => l_LINE_ATTRIBS_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID =>l_LINE_ATTRIBS_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID             => l_LINE_ATTRIBS_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE    => l_LINE_ATTRIBS_rec.PROGRAM_UPDATE_DATE,
           p_APPLICATION_ID         => l_LINE_ATTRIBS_rec.APPLICATION_ID,
          p_STATUS                 => l_LINE_ATTRIBS_rec.STATUS,
          p_QUOTE_HEADER_ID        => l_LINE_ATTRIBS_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID          => l_LINE_ATTRIBS_rec.QUOTE_LINE_ID,
          p_QUOTE_SHIPMENT_ID      => l_LINE_ATTRIBS_rec.QUOTE_SHIPMENT_ID,
          p_ATTRIBUTE_TYPE_CODE    => l_LINE_ATTRIBS_rec.ATTRIBUTE_TYPE_CODE,
          p_NAME                   => l_LINE_ATTRIBS_rec.NAME,
          p_VALUE                  => l_LINE_ATTRIBS_rec.VALUE,
          p_VALUE_TYPE             => l_LINE_ATTRIBS_rec.VALUE_TYPE,
          p_START_DATE_ACTIVE      => l_LINE_ATTRIBS_rec.START_DATE_ACTIVE,
          p_END_DATE_ACTIVE        => l_LINE_ATTRIBS_rec.END_DATE_ACTIVE,
        p_OBJECT_VERSION_NUMBER  => l_LINE_ATTRIBS_rec.OBJECT_VERSION_NUMBER);

     ELSIF l_line_attribs_rec.operation_code = 'DELETE' THEN
     ASO_QUOTE_LINE_ATTRIBS_EXT_PKG.delete_Row(
          p_LINE_ATTRIB_ID  => l_LINE_ATTRIBS_rec.LINE_ATTRIBUTE_ID);
     END IF;
END LOOP;      -- line attribs


       IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Update_Rows: l_qte_access_tbl.count: '||l_qte_access_tbl.count, 1, 'Y');
       END IF;

       for i in 1 .. p_qte_access_tbl.count loop

		 if p_qte_access_tbl(i).operation_code = 'CREATE' then

			 l_qte_access_tbl(1)                  := p_qte_access_tbl(i);
                l_qte_access_tbl(1).batch_price_flag := fnd_api.g_false;

			 if l_qte_access_tbl(1).quote_number is null or l_qte_access_tbl(1).quote_number = fnd_api.g_miss_num then

			    open c_quote_number;
			    fetch c_quote_number into l_qte_access_tbl(1).quote_number;
			    close c_quote_number;

                end if;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Update_Rows: Before call to Add_Resource', 1, 'Y');
                END IF;

                ASO_SECURITY_INT.Add_Resource(
                     P_INIT_MSG_LIST              => FND_API.G_FALSE,
                     P_COMMIT                     => FND_API.G_FALSE,
                     P_Qte_Access_tbl             => l_qte_access_tbl,
			      p_call_from_oafwk_flag       => FND_API.G_TRUE,
                     X_Qte_Access_tbl             => lx_qte_access_tbl,
                     X_RETURN_STATUS              => x_return_status,
                     X_msg_count                  => X_msg_count,
                     X_msg_data                   => X_msg_data );

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Update_Rows: After call to Add_Resource: x_return_status: '|| x_return_status, 1, 'Y');
                    aso_debug_pub.add('Update_Rows: lx_Qte_Access_tbl.count: '|| lx_Qte_Access_tbl.count, 1, 'Y');
                END IF;

			 for i in 1 .. lx_qte_access_tbl.count loop
			     X_Qte_Access_tbl(X_Qte_Access_tbl.count + 1) := lx_qte_access_tbl(i);
			 end loop;

		 elsif p_qte_access_tbl(i).operation_code = 'UPDATE' then

			 l_qte_access_tbl(1)                  := p_qte_access_tbl(i);
                l_qte_access_tbl(1).batch_price_flag := fnd_api.g_false;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Update_Rows: Before call to Add_Resource to update access', 1, 'Y');
                END IF;

                ASO_SECURITY_INT.Add_Resource(
                     P_INIT_MSG_LIST              => FND_API.G_FALSE,
                     P_COMMIT                     => FND_API.G_FALSE,
                     P_Qte_Access_tbl             => l_qte_access_tbl,
			      p_call_from_oafwk_flag       => FND_API.G_TRUE,
                     X_Qte_Access_tbl             => lx_qte_access_tbl,
                     X_RETURN_STATUS              => x_return_status,
                     X_msg_count                  => X_msg_count,
                     X_msg_data                   => X_msg_data );

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Update_Rows: After call to Add_Resource: x_return_status: '||x_return_status, 1, 'Y');
                    aso_debug_pub.add('Update_Rows: lx_Qte_Access_tbl.count: '|| lx_Qte_Access_tbl.count, 1, 'Y');
                END IF;

			 for i in 1 .. lx_qte_access_tbl.count loop
			     X_Qte_Access_tbl(X_Qte_Access_tbl.count + 1) := lx_qte_access_tbl(i);
			 end loop;

		 elsif p_qte_access_tbl(i).operation_code = 'DELETE' then

			 l_qte_access_tbl(1)                  := p_qte_access_tbl(i);
                l_qte_access_tbl(1).batch_price_flag := fnd_api.g_false;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Update_Rows: Before call to Add_Resource', 1, 'Y');
                END IF;

                ASO_SECURITY_INT.Delete_Resource(
                     P_INIT_MSG_LIST              => FND_API.G_FALSE,
                     P_COMMIT                     => FND_API.G_FALSE,
                     P_Qte_Access_tbl             => l_qte_access_tbl,
                     X_RETURN_STATUS              => x_return_status,
                     X_msg_count                  => X_msg_count,
                     X_msg_data                   => X_msg_data );

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Update_Rows: After call to Add_Resource: x_return_status: '||x_return_status, 1, 'Y');
                END IF;

			 X_Qte_Access_tbl(X_Qte_Access_tbl.count + 1) := p_qte_access_tbl(i);

           end if;

       end loop;

END Update_Rows;



-- Update Quote total info (do summation to get TOTAL_LIST_PRICE,
-- TOTAL_ADJUSTED_AMOUNT, TOTAL_TAX, TOTAL_SHIPPING_CHARGE, SURCHARGE,
-- TOTAL_QUOTE_PRICE, PAYMENT_AMOUNT)
-- IF calculate_tax_flag = 'N', no summation on line level tax,
-- just take the value of p_qte_header_rec.total_tax as the total_tax
-- IF calculate_Freight_Charge_Flag = 'N', not summation on line level freight charge,
-- just take the value of p_qte_header_rec.total_freight_charge



PROCEDURE Update_Quote_Total ( P_Qte_Header_id             IN   NUMBER,
                               P_Calculate_Tax             IN   VARCHAR2,
                               P_Calculate_Freight_Charge  IN   VARCHAR2,
                               P_Control_Rec               IN   ASO_QUOTE_PUB.CONTROL_REC_TYPE
                                                                :=  ASO_QUOTE_PUB.G_MISS_CONTROL_REC,
                               P_Call_Ar_Api_Flag          IN   VARCHAR2 := FND_API.G_FALSE,
                               X_Return_Status             OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
                               X_Msg_Count                 OUT NOCOPY /* file.sql.39 change */      NUMBER,
                               X_Msg_Data                  OUT NOCOPY /* file.sql.39 change */      VARCHAR2
                             )
IS

   l_precision              NUMBER;
   -- start of bug14015509 added ln_selling_price
--Bug 21909637 rewrite the below cursor to make a check based on precision
/*
     CURSOR c_qte_sum IS
   SELECT quote_line_id, line_category_code, round(nvl(line_list_price * quantity, 0),l_precision) total_list_price,
          round(nvl(line_adjusted_amount * quantity,
              nvl(line_adjusted_percent * line_list_price * quantity, 0)),l_precision) ln_total_discount,
	       round( nvl(line_quote_price * quantity, 0),l_precision) ln_selling_price
   FROM   ASO_QUOTE_LINES_ALL
   WHERE  quote_header_id = p_qte_header_id
   and    charge_periodicity_code is null; -- Recurring charges Change*/

   CURSOR c_qte_sum IS
   SELECT quote_line_id, line_category_code, round(nvl(line_list_price * quantity, 0),l_precision) total_list_price,
          round(nvl(line_adjusted_amount * quantity,nvl(line_adjusted_percent * line_list_price * quantity, 0)),l_precision) ln_total_discount,
	       round( nvl(line_quote_price * quantity, 0),l_precision) ln_selling_price
   FROM   ASO_QUOTE_LINES_ALL
   WHERE  quote_header_id = p_qte_header_id
   and    charge_periodicity_code is null
   and l_precision<> 0
   union
   SELECT quote_line_id, line_category_code, nvl(line_list_price * quantity, 0) total_list_price,
          nvl(line_adjusted_amount * quantity,nvl(line_adjusted_percent * line_list_price * quantity, 0)) ln_total_discount,
	       nvl(line_quote_price * quantity, 0) ln_selling_price
   FROM   ASO_QUOTE_LINES_ALL
   WHERE  quote_header_id = p_qte_header_id
   and    charge_periodicity_code is null
   and l_precision= 0;

--Bug 21909637 rewrite the  cursor to make a check based on precision

   CURSOR c_tax_line(p_quote_line_id  NUMBER) IS
   SELECT round(nvl(sum(decode(tax_inclusive_flag, 'Y', 0,nvl(tax_amount,0))),0),l_precision) tax_amt_for_qte_total,
		round(nvl(sum(nvl(tax_amount, 0)),0),l_precision) tax_amount
   FROM   ASO_TAX_DETAILS
   WHERE  quote_header_id              =   p_qte_header_id
   and    quote_line_id                =   p_quote_line_id;

   CURSOR c_tax IS
   SELECT round(nvl(sum(nvl(tax_amount, 0)),0),l_precision)
   FROM   ASO_TAX_DETAILS
   WHERE  quote_header_id = p_qte_header_id
   and    quote_line_id is null;

   CURSOR c_tax_rec_cnt IS
   select count(tax_detail_id)
   from aso_tax_details
   where quote_header_id = p_qte_header_id
   and tax_amount is not null;


   CURSOR c_old_shipping_charge IS
   SELECT round(total_shipping_charge,l_precision)
   FROM   aso_quote_headers_all
   WHERE  quote_header_id = p_qte_header_id;


   CURSOR c_hd_discount IS
   SELECT	total_adjusted_percent
   FROM   aso_quote_headers_all
   WHERE  quote_header_id = p_qte_header_id;


  Cursor get_hdr_payment_term IS
  SELECT payment_term_id
  FROM aso_payments
  WHERE  quote_header_id = p_qte_header_id
  and    quote_line_id is null;

  Cursor get_hdr_curr_code IS
  SELECT currency_code
  FROM aso_quote_headers_all
  WHERE  quote_header_id = p_qte_header_id;

  Cursor c_org_id IS
  Select org_id,quote_type
  from aso_quote_headers_all
  where quote_header_id = p_qte_header_id;

  Cursor get_total_payment_amount( l_qte_hdr_id number) is
  select sum(payment_amount)
  from aso_payments
  where quote_header_id = l_qte_hdr_id
  and quote_line_id is not null;

   l_total_list_price         NUMBER := 0;
   l_ln_total_discount        NUMBER := 0;
   l_total_quote_price        NUMBER := 0;
   l_total_adjusted_amount    NUMBER := 0;
   l_hd_discount_percent      NUMBER := 0;
   l_total_tax                NUMBER := 0;
   l_total_tax_for_qte_total  NUMBER := 0;
   l_header_tax               NUMBER := 0;
   l_total_shipping_charge    NUMBER := 0;
   l_line_shipping_charge     NUMBER := 0;
   l_header_shipping_charge   NUMBER := 0;
   l_count                    NUMBER;

   l_installment_option     VARCHAR2(240);
   l_hdr_currency_code    varchar2(15);
   l_hdr_term_id           NUMBER;
   l_paynow_amount          NUMBER;
   l_paynow_tax             NUMBER;
   l_paynow_charges         NUMBER:= null;
   l_paynow_total           NUMBER;
   l_org_id                 NUMBER;
   l_quote_type             varchar2(1);
   l_total_payment_amount   NUMBER :=0;
   l_ext_precision            NUMBER;
   l_min_acct_unit            NUMBER;
   l_total_selling_price      NUMBER := 0; -- bug 8584380

    -- cost_er
   l_total_unit_cost number;
   l_total_margin_amt number;
   l_total_margin_per number;

   --end cost_er

BEGIN

     --Initialize API return status to SUCCESS

     x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- get the currency code id for the header
          open get_hdr_curr_code;
          fetch get_hdr_curr_code into l_hdr_currency_code;
          close get_hdr_curr_code;
	  FND_CURRENCY.GET_INFO(l_hdr_currency_code,l_precision,l_ext_precision,l_min_acct_unit);
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('Begin update_quote_total procedure.', 1, 'Y');
         aso_debug_pub.add('Update_quote_total: Input parameters value.');
         aso_debug_pub.add('Update_quote_total: p_qte_header_id:            '|| p_qte_header_id);
         aso_debug_pub.add('Update_quote_total: p_calculate_tax:            '|| p_calculate_tax);
         aso_debug_pub.add('Update_quote_total: p_calculate_freight_charge: '|| p_calculate_freight_charge);
         aso_debug_pub.add('p_control_rec.header_pricing_event: '|| p_control_rec.header_pricing_event);
         aso_debug_pub.add('p_control_rec.line_pricing_event:   '|| p_control_rec.header_pricing_event);
	END IF;



     FOR qte_rec IN c_qte_sum LOOP

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	        aso_debug_pub.add('Update_quote_total: l_total_quote_price:        '|| l_total_quote_price);
             aso_debug_pub.add('qte_rec.line_category_code: '|| qte_rec.line_category_code);
	    END IF;

         IF qte_rec.line_category_code = 'RETURN' THEN

              l_total_list_price  := l_total_list_price  - qte_rec.total_list_price;
              l_ln_total_discount := l_ln_total_discount - qte_rec.ln_total_discount;
	      l_total_selling_price := l_total_selling_price - qte_rec.ln_selling_price; -- bug 8584380

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
		        aso_debug_pub.add('Update_quote_total: l_total_list_price:  '|| l_total_list_price);
                  aso_debug_pub.add('Update_quote_total: l_ln_total_discount: '|| l_ln_total_discount);
		  aso_debug_pub.add('Update_quote_total: l_total_selling_price '|| l_total_selling_price); -- bug 8584380
		    END IF;

              FOR tax_line_rec IN c_tax_line(qte_rec.quote_line_id) LOOP

                   l_total_tax               := l_total_tax - tax_line_rec.tax_amount;
                   l_total_tax_for_qte_total := l_total_tax_for_qte_total - tax_line_rec.tax_amt_for_qte_total;

              END LOOP;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
		        aso_debug_pub.add('Update_quote_total: l_total_tax (-): '|| l_total_tax);
		    END IF;

              IF p_calculate_freight_charge = 'Y' then

                   l_line_shipping_charge := aso_shipping_int.get_line_freight_charges( p_qte_header_id,
                                                                                  qte_rec.quote_line_id );

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
			        aso_debug_pub.add('Update_quote_total: After call to get_line_freight_charges');
                       aso_debug_pub.add('l_line_shipping_charge: '|| l_line_shipping_charge);
			    END IF;

                   l_total_shipping_charge := l_total_shipping_charge - l_line_shipping_charge;

              END IF;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
		        aso_debug_pub.add('l_total_shipping_charge: '|| l_total_shipping_charge );
		    END IF;

         ELSE

              l_total_list_price  := l_total_list_price + qte_rec.total_list_price;
              l_ln_total_discount := l_ln_total_discount + qte_rec.ln_total_discount;
              l_total_selling_price := l_total_selling_price + qte_rec.ln_selling_price; -- bug 8584380
              IF aso_debug_pub.g_debug_flag = 'Y' THEN
		        aso_debug_pub.add('Update_quote_total: l_total_list_price:  '|| l_total_list_price);
                  aso_debug_pub.add('Update_quote_total: l_ln_total_discount: '|| l_ln_total_discount);
		  aso_debug_pub.add('Update_quote_total: l_total_selling_price '|| l_total_selling_price); -- bug 8584380
		    END IF;

              FOR tax_line_rec IN c_tax_line(qte_rec.quote_line_id) LOOP

                   l_total_tax               := l_total_tax + tax_line_rec.tax_amount;
                   l_total_tax_for_qte_total := l_total_tax_for_qte_total + tax_line_rec.tax_amt_for_qte_total;

              END LOOP;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
		        aso_debug_pub.add('Update_quote_total: l_total_tax (+): '|| l_total_tax);
		    END IF;

              IF p_calculate_freight_charge = 'Y' then

                   l_line_shipping_charge := aso_shipping_int.get_line_freight_charges( p_qte_header_id,
                                                                                  qte_rec.quote_line_id );

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
			        aso_debug_pub.add('Update_quote_total: After call to get_line_freight_charges');
                       aso_debug_pub.add('l_line_shipping_charge: '|| l_line_shipping_charge);
			    END IF;

                   l_total_shipping_charge := l_total_shipping_charge + l_line_shipping_charge;

              END IF;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
		        aso_debug_pub.add('l_total_shipping_charge: '|| l_total_shipping_charge );
		    END IF;

         END IF;

     END LOOP;

     --Get the header level tax amount and add it to the total tax

	OPEN  c_tax;
	FETCH c_tax INTO l_header_tax;
	CLOSE c_tax;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('Update_quote_total: l_header_tax: '|| l_header_tax);
         aso_debug_pub.add('Update_Quote_Total: p_control_rec.price_mode: '|| p_control_rec.price_mode);
	END IF;

     IF (p_calculate_tax = 'N')                          OR
	   (p_control_rec.price_mode  = 'QUOTE_LINE')       OR
	   ((p_control_rec.price_mode = 'ENTIRE_QUOTE')     AND
         (p_control_rec.header_pricing_event = 'ORDER')) OR
	   ((p_control_rec.price_mode = 'ENTIRE_QUOTE')     AND
         (p_control_rec.header_pricing_event = 'PRICE')) THEN

         OPEN  c_tax_rec_cnt;
         FETCH c_tax_rec_cnt INTO l_count;
         CLOSE c_tax_rec_cnt;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Update_quote_total: l_count: '|| l_count);
         END IF;

         IF l_count = 0 THEN
             l_total_tax               := null;
             l_total_tax_for_qte_total := null;
         ELSE
             l_total_tax               := l_total_tax + nvl(l_header_tax,0);
             l_total_tax_for_qte_total := l_total_tax_for_qte_total + nvl(l_header_tax,0);
         END IF;

     ELSE

         l_total_tax               := l_total_tax + nvl(l_header_tax,0);
         l_total_tax_for_qte_total := l_total_tax_for_qte_total + nvl(l_header_tax,0);

     END IF;


     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('Update_quote_total: l_total_tax:               '|| l_total_tax);
	    aso_debug_pub.add('Update_quote_total: l_total_tax_for_qte_total: '|| l_total_tax_for_qte_total);
	END IF;


     IF P_calculate_Freight_Charge = 'Y' THEN

         l_header_shipping_charge := ASO_SHIPPING_INT.get_Header_freight_charges(p_qte_header_id);

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	        aso_debug_pub.add('Update_quote_total: l_header_shipping_charge: '|| l_header_shipping_charge);
	    END IF;

         l_total_shipping_charge := l_total_shipping_charge + l_header_shipping_charge;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	        aso_debug_pub.add('Update_quote_total: l_total_shipping_charge:  '|| l_total_shipping_charge);
	    END IF;

     ELSE

	    open  c_old_shipping_charge;
	    fetch c_old_shipping_charge into l_total_shipping_charge;
	    close c_old_shipping_charge;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	        aso_debug_pub.add('Update_quote_total: l_total_shipping_charge:  '|| l_total_shipping_charge);
	    END IF;

     END IF;

     -- bug 8584380. Using selling price to display quote total to avoid rounding issues for fractional quantities
     -- back calculating the total adjustments using total selling price and total list price
     /*l_total_quote_price := l_total_list_price + l_ln_total_discount + nvl(l_total_tax_for_qte_total,0) +
                            nvl(l_total_shipping_charge,0);*/
     l_total_quote_price := l_total_selling_price + nvl(l_total_tax_for_qte_total,0) +
                            nvl(l_total_shipping_charge,0);

     l_ln_total_discount:= l_total_selling_price - l_total_list_price;
     -- end bug 8584380
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('Update_quote_total: l_total_quote_price: '|| l_total_quote_price);
	    aso_debug_pub.add('Update_quote_total: l_ln_total_discount: '|| l_ln_total_discount);
	END IF;

	/* commented for ER 24514580
          -- removed the if condition for pricing event check as per bug 5237393
          IF ( l_total_quote_price < 0 ) THEN

               x_return_status := FND_API.G_RET_STS_ERROR;

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			    aso_debug_pub.add('Inside price check: x_return_status: '|| x_return_status );
			END IF;

               IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

                   FND_MESSAGE.Set_Name('ASO', 'ASO_NEGATIVE_QUOTE_TOTAL');
                   FND_MSG_PUB.ADD;

               END IF;

			RAISE FND_API.G_EXC_ERROR;

          END IF; */

     -- Start of PNPL Changes
      Open c_org_id;
	 fetch c_org_id into l_org_id,l_quote_type;
	 Close c_org_id;

      l_installment_option := oe_sys_parameters.value(param_name => 'INSTALLMENT_OPTIONS',
                                                                     p_org_id =>l_org_id);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote_Total - Value of Installment Option Param: '||l_installment_option, 1, 'Y');
      END IF;

       IF  ( (l_installment_option = 'ENABLE_PAY_NOW') and (nvl(l_quote_type,'X') <>  'T')
	       and ((p_control_rec.header_pricing_event <> FND_API.G_MISS_CHAR and p_control_rec.header_pricing_event is not null)
	         or (p_control_rec.calculate_tax_flag = 'Y'))   ) then

         l_header_shipping_charge := ASO_SHIPPING_INT.get_Header_freight_charges(p_qte_header_id);

       -- get the payment term id for the header
          open get_hdr_payment_term;
          fetch get_hdr_payment_term into l_hdr_term_id;
          close get_hdr_payment_term;

       -- get the currency code id for the header
          open get_hdr_curr_code;
          fetch get_hdr_curr_code into l_hdr_currency_code;
          close get_hdr_curr_code;


      IF aso_debug_pub.g_debug_flag = 'Y' THEN

          aso_debug_pub.add('Update_Quote_Total- Input to AR_VIEW_TERM_GRP.pay_now_amounts follows:  ', 1, 'Y');
          aso_debug_pub.add('Update_Quote_Total- l_header_shipping_charge:    '||l_header_shipping_charge, 1, 'Y');
          aso_debug_pub.add('Update_Quote_Total- l_hdr_currency_code:         '||l_hdr_currency_code, 1, 'Y');
          aso_debug_pub.add('Update_Quote_Total- l_hdr_term_id:               '||l_hdr_term_id, 1, 'Y');
		aso_debug_pub.add('Update_Quote_Total- P_Call_Ar_Api_Flag:          '||P_Call_Ar_Api_Flag,1,'Y');
      END IF;

      IF ((l_hdr_term_id is not null and l_hdr_term_id <> fnd_api.g_miss_num) and (P_Call_Ar_Api_Flag = fnd_api.g_true))  then

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote_Total: before call to AR_VIEW_TERM_GRP.pay_now_amounts', 1, 'Y');
      END IF;

       -- Call the AR API to get the amounts
             AR_VIEW_TERM_GRP.pay_now_amounts(
                    p_api_version              => 1.0,
                    p_init_msg_list            => FND_API.G_FALSE,
                    p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
                    p_term_id                  => l_hdr_term_id,
                    p_currency_code            => l_hdr_currency_code,
                    p_line_amount              => 0,
                    p_tax_amount               => 0,
                    p_freight_amount           => l_header_shipping_charge ,
                    x_pay_now_line_amount      => l_paynow_amount,
                    x_pay_now_tax_amount       => l_paynow_tax,
                    x_pay_now_freight_amount   => l_paynow_charges,
                    x_pay_now_total_amount     => l_paynow_total,
                    X_Return_Status            => x_return_status ,
                    X_Msg_Count                => x_msg_count     ,
                    X_Msg_Data                 => x_msg_data      );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Update_Quote_Total: After call to AR_VIEW_TERM_GRP.pay_now_amounts: x_return_status: '
                                 || x_return_status, 1, 'Y');
          END IF;

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                  FND_MESSAGE.Set_Token('API', 'AR_PayNow_Amounts', FALSE);
                  FND_MSG_PUB.ADD;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote_Total- Output from AR_VIEW_TERM_GRP.pay_now_amounts follows: ', 1, 'Y');
          aso_debug_pub.add('Update_Quote_Total- l_paynow_amount:     '||l_paynow_amount, 1, 'Y');
          aso_debug_pub.add('Update_Quote_Total- l_paynow_charges:    '||l_paynow_charges, 1, 'Y');
          aso_debug_pub.add('Update_Quote_Total- l_paynow_tax:        '||l_paynow_tax, 1, 'Y');
          aso_debug_pub.add('Update_Quote_Total- l_paynow_total:      '||l_paynow_total, 1, 'Y');
      END IF;


          -- Update the corresponding columns in the header table
          -- this update has been commented out as the update for this column is done below
		/*update aso_quote_headers_all
          set header_paynow_charges    = l_paynow_charges,
              last_updated_by        =  fnd_global.user_id,
              last_update_login      =  fnd_global.conc_login_id
          where quote_header_id = P_Qte_Header_id; */


        END IF; -- end if for payment trm id null check

       END IF;

     -- End of PNPL Changes

      -- Cost_ER rassharm
     BEGIN

     ASO_MARGIN_PVT.Get_Quote_Margin(p_qte_header_id   => p_qte_header_id ,
	         		     p_org_id =>  l_org_id,
				     x_quote_unit_cost => l_total_unit_cost,
                                     x_quote_margin_percent => l_total_margin_per,
                                     x_quote_margin_amount => l_total_margin_amt);

    exception
       when no_data_found then
         l_total_unit_cost:=null;
         l_total_margin_per:=null;
         l_total_margin_amt:=null;
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Error after calling  ASO_MARGIN_PVT.Get_Quote_Margin NO_DATA_FOUND');
	 end if;
       when others then
         l_total_unit_cost:=null;
         l_total_margin_per:=null;
         l_total_margin_amt:=null;
          IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Error after calling  ASO_MARGIN_PVT.Get_Quote_Margin OTHERS');
	 end if;
     END;


     IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote_Total l_total_unit_cost'||l_total_unit_cost);
  	  aso_debug_pub.add('Update_Quote_Total l_total_margin_per'||l_total_margin_per);
  	  aso_debug_pub.add('Update_Quote_Total l_total_margin_amt'||l_total_margin_amt);
	end if;
     -- End cost_er

     UPDATE ASO_QUOTE_HEADERS_ALL
     SET total_list_price       =  l_total_list_price,
         total_shipping_charge  =  l_total_shipping_charge,
         total_adjusted_amount  =  l_ln_total_discount,
         total_adjusted_percent =  decode( l_total_list_price, 0, NULL,
                                          (l_ln_total_discount/l_total_list_price) * 100 ),
         total_quote_price      =  l_total_quote_price,
         total_tax              =  l_total_tax,
	    header_paynow_charges  =  nvl(l_paynow_charges,header_paynow_charges),
                 -- cost_er
	 total_unit_cost = round(l_total_unit_cost,l_precision),
         total_margin_amount = round(l_total_margin_amt,l_precision),
	 total_margin_percent = round(l_total_margin_per,l_precision),
	 -- end cost_er
         last_update_date       =  sysdate,
         last_updated_by        =  fnd_global.user_id,
         last_update_login      =  fnd_global.conc_login_id
     WHERE quote_header_id = p_qte_header_id;

     IF SQL%ROWCOUNT = 0  THEN

         x_return_status := fnd_api.g_ret_sts_error;

     END IF;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('Update_quote_total: l_total_quote_price: '|| l_total_quote_price);
	    aso_debug_pub.add('End of Update_quote_total');
	END IF;

END Update_Quote_Total;




-- Hint: Primary key needs to be returned.
PROCEDURE Create_quote(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2                                 := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER                                   := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec              IN   ASO_QUOTE_PUB.Control_Rec_Type           := ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type        := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type  := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Rec		 IN   ASO_QUOTE_PUB.Shipment_Rec_Type          := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC,
    P_hd_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type    := ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type  := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl      IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl		      IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		 IN   ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type  := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		 IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type         := ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	      IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type    := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type := ASO_QUOTE_PUB.G_Miss_Price_Adj_Rltship_Tbl,
    P_ln_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type  := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
    P_ln_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
    P_ln_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
    P_ln_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type    := ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl,
    P_ln_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl      IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Qte_Access_Tbl           IN   ASO_QUOTE_PUB.Qte_Access_Tbl_Type        := ASO_QUOTE_PUB.G_MISS_QTE_ACCESS_TBL,
    P_Template_Tbl             IN   ASO_QUOTE_PUB.Template_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_TEMPLATE_TBL,
    P_Related_Obj_Tbl          IN   ASO_QUOTE_PUB.Related_Obj_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_RELATED_OBJ_TBL,
    x_Qte_Header_Rec		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Line_Tbl             OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    X_hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    X_hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_hd_Shipment_Rec		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Shipment_Rec_Type,
    X_hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    X_ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    X_ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    X_Qte_Access_Tbl           OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Access_Tbl_Type,
    X_Template_Tbl             OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Template_Tbl_Type,
    X_Related_Obj_Tbl          OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Related_Obj_Tbl_Type,
    X_Return_Status            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS

l_api_name		      CONSTANT VARCHAR2(30) := 'Create_quote';
l_api_version_number	 CONSTANT NUMBER   := 1.0;
l_return_status_full	 VARCHAR2(1);
l_return_status 	      VARCHAR2(1);
l_qte_header_rec	      ASO_QUOTE_PUB.Qte_Header_Rec_Type;
lx_out_qte_header_rec	 ASO_QUOTE_PUB.Qte_Header_Rec_Type; --Nocopy changes
l_qte_line_rec		      ASO_QUOTE_PUB.Qte_Line_Rec_Type;
l_qte_line_rec_out		 ASO_QUOTE_PUB.Qte_Line_Rec_Type;
l_qte_line_dtl_tbl	      ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
l_qte_line_dtl_tbl_out	 ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
l_Line_Attr_Ext_Tbl	      ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
l_Line_Attr_Ext_Tbl_out   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
l_hd_shipment_tbl	      ASO_QUOTE_PUB.Shipment_Tbl_Type;
l_ln_shipment_tbl	      ASO_QUOTE_PUB.Shipment_Tbl_Type;
l_ln_shipment_tbl_out	 ASO_QUOTE_PUB.Shipment_Tbl_Type;
l_payment_tbl	           ASO_QUOTE_PUB.Payment_Tbl_Type;
l_payment_tbl_out	      ASO_QUOTE_PUB.Payment_Tbl_Type;
l_freight_charge_tbl	 ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
l_freight_charge_tbl_out	 ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
l_tax_detail_rec	      ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
l_tax_detail_tbl	      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
l_tax_detail_tbl_out	 ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
l_Price_Attr_Tbl	      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
l_Price_Attr_Tbl_out	 ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
l_Price_Adj_Tbl	      ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
l_Price_Adj_Tbl_out	      ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
l_Price_Adj_Attr_Tbl	 ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
l_Price_Adj_Attr_Tbl_out  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
l_Price_Adjustment_Tbl    ASO_QUOTE_PUB.Price_Adj_Tbl_Type          :=p_Price_Adjustment_Tbl;
l_line_rltship_rec        ASO_QUOTE_PUB.Line_Rltship_Rec_Type;
l_price_adj_rltship_rec	 ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type;
l_pricing_control_rec	 ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE;
--bug8235510
lx_line_relationship_id number;
l_shipment_id		       NUMBER;
l_payment_id		       NUMBER;
l_found			       VARCHAR2(1);
l_calculate_freight_charge VARCHAR2(1) := 'Y';
l_calculate_tax		  VARCHAR2(1) := 'Y';
l_index			       NUMBER;
l_index_2		            NUMBER;
line_index		       NUMBER;
l_shp_index_link	       Index_Link_Tbl_Type;
l_prc_index_link	       Index_Link_Tbl_Type;
l_prc_index_link_rev	  Index_Link_Tbl_Type;
l_quote_party_tbl          ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
l_quote_party_tbl_out      ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
l_sales_credit_tbl         ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
l_sales_credit_tbl_out     ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
l_control_rec              ASO_QUOTE_PUB.Control_rec_type := p_control_rec;
l_Tax_Control_Rec          ASO_TAX_INT.Tax_Control_Rec_Type;
x_tax_amount               NUMBER;
l_shipment_rec             ASO_QUOTE_PUB.Shipment_Rec_Type := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC;

G_USER_ID	                 NUMBER      := FND_GLOBAL.USER_ID;
G_LOGIN_ID	            NUMBER      := FND_GLOBAL.CONC_LOGIN_ID;

l_price_updated_date_flag  VARCHAR2(1) := fnd_api.g_false;

cursor c_last_update_date( p_qte_hdr_id  number ) is
select last_update_date
from aso_quote_headers_all
where quote_header_id = p_qte_hdr_id;

-- Code for Sales Team Assignment Changes
CURSOR C_Check_Qte_Status (l_qte_hdr NUMBER) IS
SELECT 'Y'
FROM ASO_QUOTE_HEADERS_ALL A, ASO_QUOTE_STATUSES_B B
WHERE A.Quote_Header_Id = l_qte_hdr
AND A.Quote_Status_Id = B.Quote_Status_Id
AND B.Status_Code = 'STORE DRAFT';

CURSOR C_Get_Quota_Credit_Type IS
 SELECT Sales_Credit_Type_Id
 FROM OE_SALES_CREDIT_TYPES
 WHERE Quota_Flag = 'Y';

Cursor c_obj_id(p_qte_header_id Number) IS
Select object_id
from aso_quote_related_objects
where quote_object_id = p_qte_header_id
and quote_object_type_code = 'HEADER'
and relationship_type_code = 'OPP_QUOTE';

CURSOR c_tax_line(p_qte_header_id NUMBER, p_quote_line_id  NUMBER) IS
select nvl(sum(nvl(tax_amount, 0)),0) tax_amount
FROM   ASO_TAX_DETAILS
WHERE  quote_header_id              =   p_qte_header_id
and    quote_line_id                =   p_quote_line_id;

Cursor get_line_payment_term(p_qte_header_id NUMBER, p_quote_line_id  NUMBER) IS
SELECT payment_term_id
FROM aso_payments
WHERE  quote_header_id              =   p_qte_header_id
and    quote_line_id                =   p_quote_line_id;

Cursor get_hdr_payment_term(p_qte_header_id NUMBER) IS
SELECT payment_term_id
FROM aso_payments
WHERE  quote_header_id              =   p_qte_header_id
and    quote_line_id                IS NULL ;

Cursor get_line_qte_price( p_quote_line_id  NUMBER) IS
select line_quote_price,quantity
from   aso_quote_lines_all
where  quote_line_id = p_quote_line_id;

Cursor  c_inv_org_id(l_main_org_id Number) IS
select  master_organization_id
from    oe_system_parameters
where   org_id = l_main_org_id;

Cursor c_market_source_id  (p_MARKETING_SOURCE_CODE varchar2, p_MARKETING_SOURCE_NAME varchar2)
    is
  Select SOURCE_CODE_ID
    From ASO_SOURCE_NAME_V
    Where NVL(SOURCE_CODE,'X') = decode(NVL(p_MARKETING_SOURCE_CODE ,fnd_api.g_miss_char ), fnd_api.g_miss_char,NVL(source_code,'X'),p_MARKETING_SOURCE_CODE ) AND
    NVL(NAME,'X') = decode(NVL(p_MARKETING_SOURCE_NAME,fnd_api.g_miss_char),fnd_api.g_miss_char,NVL(NAME,'X'),p_MARKETING_SOURCE_NAME);

  Cursor c_sales_rep_id ( p_SALESREP_FIRST_NAME varchar2 , p_SALESREP_LAST_NAME varchar2 , p_ORG_ID number)
  is
  SELECT jreb.resource_id
    FROM jtf_rs_resource_extns_vl jreb, JTF_RS_SALESREPS sls
    WHERE NVL(sls.status, 'A') = 'A' AND
        TRUNC(NVL(jreb.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)   AND
        TRUNC(NVL(jreb.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)    AND
        TRUNC(NVL(sls.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)   AND
        TRUNC(NVL(sls.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)    AND
        jreb.resource_id = sls.resource_id AND
        NVL(jreb.source_first_name,'X') = decode(NVL(p_SALESREP_FIRST_NAME,fnd_api.g_miss_char),fnd_api.g_miss_char, NVL(source_first_name,'X'),p_SALESREP_FIRST_NAME)  AND
        NVL(jreb.source_last_name,'X') =  decode(NVL( p_SALESREP_LAST_NAME,fnd_api.g_miss_char),fnd_api.g_miss_char,NVL(source_last_name,'X'), p_SALESREP_LAST_NAME)  AND
        sls.org_id = p_ORG_ID ;

  Cursor c_party_id (p_party_name varchar2 , p_PERSON_FIRST_NAME varchar2 , p_PERSON_MIDDLE_NAME varchar2 , p_person_last_name varchar2 ,  l_CUST_PARTY_ID number)
  is
  Select
         hp_rltn.party_id
           FROM HZ_PARTIES hp_contact,
                         HZ_RELATIONSHIPS hp_rltn,
                         HZ_PARTY_SITES ps
                    WHERE hp_rltn.object_id = l_CUST_PARTY_ID
                    AND hp_contact.party_id = hp_rltn.subject_id
                    AND hp_contact.party_type = 'PERSON'
                    AND hp_rltn.party_id = ps.party_id(+)
                    AND hp_rltn.relationship_code IN ( Select distinct reltype.forward_rel_code
                                                                                     From HZ_RELATIONSHIP_TYPES reltype, HZ_CODE_ASSIGNMENTS code
                                                                                     Where code.class_category =   'RELATIONSHIP_TYPE_GROUP'
                                                                                     and code.class_code =    'PARTY_REL_GRP_CONTACTS'
                                                                                     and code.owner_table_name =   'HZ_RELATIONSHIP_TYPES'
                                                                                     and code.owner_table_id =  reltype.relationship_type_id
                                                                                     and code.status =   'A'
                                                                                     and code.start_date_active <= sysdate
                                                                                     and nvl(code.end_date_active,sysdate) >= sysdate
                                                                                     and reltype.subject_type =   'PERSON'
                                                                                     and reltype.object_type =   'ORGANIZATION'
                                                                                    )
                                                     AND hp_contact.status =   'A'
                                                     AND hp_rltn.status =   'A'
                                                     AND trunc(hp_rltn.start_date) <= trunc(sysdate)
                                                     AND trunc(nvl(hp_rltn.end_date,sysdate)) >= trunc(sysdate)
                                                     AND ps.identifying_address_flag (+) =   'Y'
                                                     AND ps.status (+) =   'A'
                                                     AND NVL(hp_contact.party_name,'X') =  decode(NVL(p_party_name ,fnd_api.g_miss_char ), fnd_api.g_miss_char,NVL(hp_contact.party_name,'X'),p_party_name )
    AND nvl(hp_contact.PERSON_FIRST_NAME,'X') = decode(NVL(p_PERSON_FIRST_NAME ,fnd_api.g_miss_char ), fnd_api.g_miss_char,nvl(hp_contact.PERSON_FIRST_NAME,'X'),p_PERSON_FIRST_NAME )
    AND nvl(hp_contact.PERSON_MIDDLE_NAME , 'X') =  decode(NVL(p_PERSON_MIDDLE_NAME ,fnd_api.g_miss_char ), fnd_api.g_miss_char,nvl(hp_contact.PERSON_MIDDLE_NAME,'X'),p_PERSON_MIDDLE_NAME )
    AND nvl(hp_contact.PERSON_LAST_NAME , 'X') =  decode(NVL(p_PERSON_LAST_NAME ,fnd_api.g_miss_char ), fnd_api.g_miss_char,nvl(hp_contact.PERSON_LAST_NAME,'X'),p_PERSON_LAST_NAME );

/* For BUG 22547462 */

cursor c_sales_credit_resource_id (p_hd_sales_credit_FIRST_NAME varchar2 , p_hd_sales_credit_LAST_NAME varchar2 , p_ORG_ID number)
is
    SELECT jreb.resource_id
    FROM jtf_rs_resource_extns_vl jreb, JTF_RS_SALESREPS sls
    WHERE NVL(sls.status, 'A') = 'A' AND
        TRUNC(NVL(jreb.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)   AND
        TRUNC(NVL(jreb.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)    AND
        TRUNC(NVL(sls.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)   AND
        TRUNC(NVL(sls.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)    AND
        jreb.resource_id = sls.resource_id AND
        NVL(jreb.source_first_name,'X') = decode(NVL(p_hd_sales_credit_FIRST_NAME,fnd_api.g_miss_char),fnd_api.g_miss_char, NVL(source_first_name,'X'),p_hd_sales_credit_FIRST_NAME)  AND
        NVL(jreb.source_last_name,'X') =  decode(NVL( p_hd_sales_credit_LAST_NAME,fnd_api.g_miss_char),fnd_api.g_miss_char,NVL(source_last_name,'X'), p_hd_sales_credit_LAST_NAME)  AND
        sls.org_id = p_ORG_ID;

  p_hd_sales_credit_rec ASO_quote_PUB.sales_credit_rec_type := ASO_quote_PUB.G_MISS_SALES_CREDIT_REC;

/*** Bug 22565150 ***/
  L_SALES_RESOURCE_GROUP_ID Number;
  L_SALES_RESOURCE_GROUP_NAME Varchar2(60);

    Cursor c_SALES_RESOURCE_GROUP_ID (p_hd_sales_credit_RESOURCE_ID Number,p_RESOURCE_GROUP_NAME Varchar2)
  is
  SELECT distinct jrgm.group_id,jrgt.GROUP_NAME
   FROM     JTF_RS_GROUP_MEMBERS jrgm,
            JTF_RS_GROUPS_tl jrgt,
            JTF_RS_GROUP_USAGES jrgu
    WHERE   jrgm.group_id =jrgt.group_id
    AND     jrgt.language= userenv('LANG')
    AND     jrgu.group_id = jrgm.group_id
    AND     jrgu.usage = 'SALES'
    AND    nvl(jrgm.delete_flag, 'N') <> 'Y'
    AND    exists (SELECT 1 FROM
                jtf_rs_role_relations jrrr
            WHERE jrrr.role_resource_id= jrgm.group_member_id
            AND    nvl(jrrr.start_date_active, SYSDATE) <= SYSDATE
            AND    nvl(jrrr.end_date_active, SYSDATE) >= SYSDATE
            AND    jrrr.role_resource_type='RS_GROUP_MEMBER'
            AND     nvl(jrrr.delete_flag, 'N') <> 'Y'
            AND     ROWNUM= 1)
   AND    jrgm.resource_id = p_hd_sales_credit_RESOURCE_ID
AND jrgt.GROUP_NAME = NVL(p_RESOURCE_GROUP_NAME,jrgt.GROUP_NAME);

/*** Bug 22565150 ***/

l_quota_id                 NUMBER;

l_istore_source            VARCHAR2(1)  := 'N';
l_sales_team_prof          VARCHAR2(30) := FND_PROFILE.value('ASO_AUTO_TEAM_ASSIGN');

--New Code for to call overload pricing_order
lv_qte_header_rec          ASO_QUOTE_PUB.Qte_Header_Rec_Type;
lx_qte_header_rec          ASO_QUOTE_PUB.Qte_Header_Rec_Type;
lx_qte_line_tbl            ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
lv_hd_shipment_rec         ASO_QUOTE_PUB.Shipment_Rec_Type;
lv_hd_shipment_tbl         ASO_QUOTE_PUB.Shipment_Tbl_Type;
lv_hd_price_attr_tbl       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
lx_price_adj_rltship_tbl   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

-- hyang defaulting framework
l_hd_Sales_Credit_Tbl  ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
l_def_control_rec          ASO_DEFAULTING_INT.Control_Rec_Type     := ASO_DEFAULTING_INT.G_MISS_CONTROL_REC;
l_db_object_name           VARCHAR2(30);
l_hd_shipment_rec          ASO_QUOTE_PUB.Shipment_Rec_Type         := ASO_QUOTE_PUB.G_MISS_Shipment_REC;
l_hd_payment_rec           ASO_QUOTE_PUB.Payment_Rec_Type          := ASO_QUOTE_PUB.G_MISS_Payment_REC;
l_hd_tax_detail_rec        ASO_QUOTE_PUB.Tax_Detail_Rec_Type       := ASO_QUOTE_PUB.G_MISS_Tax_Detail_REC;
l_hd_misc_rec              ASO_DEFAULTING_INT.Header_Misc_Rec_Type := ASO_DEFAULTING_INT.G_MISS_HEADER_MISC_REC;
lx_hd_shipment_rec         ASO_QUOTE_PUB.Shipment_Rec_Type;
lx_hd_payment_rec          ASO_QUOTE_PUB.Payment_Rec_Type;
lx_hd_tax_detail_rec       ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
lx_hd_misc_rec             ASO_DEFAULTING_INT.Header_Misc_Rec_Type;
lx_quote_line_rec          ASO_QUOTE_PUB.Qte_Line_Rec_Type;
lx_ln_misc_rec             ASO_DEFAULTING_INT.Line_Misc_Rec_Type;
lx_ln_shipment_rec         ASO_QUOTE_PUB.Shipment_Rec_Type;
lx_ln_payment_rec          ASO_QUOTE_PUB.Payment_Rec_Type;
lx_ln_tax_detail_rec       ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
lx_changed_flag            VARCHAR2(1);
l_hd_payment_tbl	       ASO_QUOTE_PUB.Payment_Tbl_Type;
l_hd_tax_detail_tbl	       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

--Template changes
l_template_tbl             aso_quote_tmpl_int.list_template_tbl_type;
l_qte_line_tbl             aso_quote_pub.qte_line_tbl_type  := p_qte_line_tbl;
lx_qte_line_dtl_tbl        ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type := p_qte_line_dtl_tbl;
l_count                    number;

l_related_obj_rec          ASO_quote_PUB.RELATED_OBJ_Rec_Type  := ASO_quote_PUB.G_MISS_RELATED_OBJ_REC;
l_related_obj_id           number;
x_related_obj_rec          ASO_quote_PUB.RELATED_OBJ_Rec_Type  := ASO_quote_PUB.G_MISS_RELATED_OBJ_REC;
l_obj_id                   number;

l_installment_option     VARCHAR2(240);
l_line_shipping_charge   NUMBER;
l_line_tax               NUMBER;
l_line_amount            NUMBER;
l_line_term_id           NUMBER := NULL;
l_paynow_amount          NUMBER;
l_paynow_tax             NUMBER;
l_paynow_charges         NUMBER;
l_paynow_total           NUMBER;
l_call_ar_api            varchar2(1);
l_line_quote_price       NUMBER;
l_quantity               NUMBER;
l_master_organization_id NUMBER;

-- bug 10261431
  l_top_model_line_id  number;
  l_ato_line_id                number;
  l_line_dtl_tbl_exist BOOLEAN := FALSE;  -- added for Bug 19796851

   -- cost_er
  l_unit_cost number;
  l_margin_amount number;
  l_margin_percent number;
  -- end cost_er




BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_quote_PVT;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('******************************************************', 1, 'Y');
	     aso_debug_pub.add('Begin Create_Quote Procedure', 1, 'Y');
	     aso_debug_pub.add('******************************************************', 1, 'Y');
	 END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME) THEN

           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
	     FND_MSG_PUB.initialize;
      END IF;

      --Procedure added by Anoop Rajan on 30/09/2005 to print login details
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Before call to printing login info details', 1, 'Y');
		ASO_UTILITY_PVT.print_login_info;
		aso_debug_pub.add('After call to printing login info details', 1, 'Y');
      END IF;

      -- Change Done By Girish
      -- Procedure added to validate the operating unit
      ASO_VALIDATE_PVT.VALIDATE_OU(P_Qte_Header_Rec);

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      l_control_rec.line_pricing_event := NULL;
      l_control_rec.calculate_tax_flag := NULL;

      -- Validate Environment

      IF FND_GLOBAL.User_Id IS NULL THEN

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- create Quote Header

      l_index := 1;

      FOR i IN 1..p_price_adjustment_tbl.count LOOP

	      IF p_price_adjustment_tbl(i).qte_line_index IS NULL OR
		     p_price_adjustment_tbl(i).qte_line_index = FND_API.G_MISS_NUM THEN

	           l_price_adj_tbl(l_index)  := p_price_adjustment_tbl(i);
	           l_prc_index_link(l_index) := i;
	           l_prc_index_link_rev(i)   := l_index;
	           l_index                   := l_index + 1;

	      END IF;

      END LOOP;

      l_index := 1;

      FOR i IN 1..p_price_adj_attr_tbl.count LOOP

	      IF p_price_adj_attr_tbl(i).price_adj_index <> FND_API.G_MISS_NUM
              AND l_prc_index_link_rev.exists(p_price_adj_attr_tbl(i).price_adj_index) THEN

                l_price_adj_attr_tbl(l_index)                 := p_price_adj_attr_tbl(i);
                l_price_adj_attr_tbl(l_index).price_adj_index := l_prc_index_link_rev(l_price_adj_attr_tbl(l_index).price_adj_index);
                l_index                                       := l_index + 1;

	      END IF;

      END LOOP;

      IF Shipment_Rec_Exists(p_hd_shipment_rec) THEN
          l_hd_shipment_tbl(1) := p_hd_shipment_rec;
      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote: Before call to aso_input_param_debug.print_quote_input procedure', 1, 'Y');

      ASO_INPUT_PARAM_DEBUG.Print_quote_input(
                    P_Quote_Header_Rec         => p_qte_header_rec
                  , P_hd_Price_Attributes_Tbl  => P_hd_Price_Attributes_Tbl
                  , P_hd_Payment_Tbl           => P_hd_Payment_Tbl
                  , P_hd_Shipment_tbl          => l_hd_Shipment_tbl
                  , P_hd_Tax_Detail_Tbl        => P_hd_Tax_Detail_Tbl
                  , P_hd_Sales_Credit_Tbl      => P_hd_Sales_Credit_Tbl
                  , P_Qte_Line_Tbl             => P_Qte_Line_Tbl
                  , P_Qte_Line_Dtl_Tbl         => P_Qte_Line_Dtl_Tbl
                  , P_Price_Adjustment_Tbl     => P_Price_Adjustment_Tbl
                  , P_Ln_Price_Attributes_Tbl  => P_Ln_Price_Attributes_Tbl
                  , P_Ln_Payment_Tbl           => P_Ln_Payment_Tbl
                  , P_Ln_Shipment_Tbl          => P_Ln_Shipment_Tbl
                  , P_Ln_Tax_Detail_Tbl        => P_Ln_Tax_Detail_Tbl
                  , P_ln_Sales_Credit_Tbl      => P_ln_Sales_Credit_Tbl
			   , P_Qte_Access_Tbl           => P_Qte_Access_Tbl);

          aso_debug_pub.add('Create_Quote: After call to aso_input_param_debug.print_quote_input procedure', 1, 'Y');
      END IF ;

      -- hyang defaulting framework begin

      l_qte_header_rec := P_Qte_Header_Rec;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote - before defaulting framework', 1, 'Y');
          aso_debug_pub.add('Create_Quote - populate defaulting control record from the header control record', 1, 'Y');
      END IF ;

      l_def_control_rec.Dependency_Flag       := FND_API.G_FALSE;
      l_def_control_rec.Defaulting_Flag       := l_control_rec.Defaulting_Flag;
      l_def_control_rec.Application_Type_Code := l_control_rec.Application_Type_Code;
      l_def_control_rec.Defaulting_Flow_Code  := 'CREATE';

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Defaulting_Fwk_Flag - '||l_control_rec.Defaulting_Fwk_Flag, 1, 'Y');
          aso_debug_pub.add('Dependency_Flag - '||l_def_control_rec.Dependency_Flag, 1, 'Y');
          aso_debug_pub.add('Defaulting_Flag - '||l_def_control_rec.Defaulting_Flag, 1, 'Y');
          aso_debug_pub.add('Application_Type_Code - '||l_def_control_rec.Application_Type_Code, 1, 'Y');
          aso_debug_pub.add('Defaulting_Flow_Code - '||l_def_control_rec.Defaulting_Flow_Code, 1, 'Y');
      END IF ;

      IF l_def_control_rec.application_type_code = 'QUOTING HTML' OR  l_def_control_rec.application_type_code = 'QUOTING FORM' THEN

          l_db_object_name := G_QUOTE_HEADER_DB_NAME;

      ELSIF l_def_control_rec.application_type_code = 'ISTORE' THEN
          l_db_object_name := G_STORE_CART_HEADER_DB_NAME;

      ELSE
          l_control_rec.Defaulting_Fwk_Flag := 'N';
      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote - Pick '||l_db_object_name ||' based on calling application '||l_def_control_rec.application_type_code, 1, 'Y');
      END IF ;

      IF l_hd_shipment_tbl.count > 0 THEN
          l_hd_shipment_rec := l_hd_shipment_tbl(1);
      END IF;

      IF p_hd_payment_tbl.count > 0 THEN
          l_hd_payment_rec := p_hd_payment_tbl(1);
      END IF;

      IF p_hd_tax_detail_tbl.count > 0 THEN
          l_hd_tax_detail_rec := p_hd_tax_detail_tbl(1);
      END IF;

      l_hd_payment_tbl    := p_hd_payment_tbl;
      l_hd_tax_detail_tbl := p_hd_tax_detail_tbl;

      -- In create quote, it never deaults any line level records.
/* Removing Call for defaulting from create_quote
      IF l_control_rec.defaulting_fwk_flag = 'Y' THEN

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote - Calling default_entity', 1, 'Y');
          END IF ;

          ASO_DEFAULTING_INT.Default_Entity (
                      p_api_version           =>  1.0
                    , p_control_rec           =>  l_def_control_rec
                    , p_database_object_name  =>  l_db_object_name
                    , p_quote_header_rec      =>  P_Qte_Header_Rec
                    , p_header_misc_rec       =>  l_hd_misc_rec
                    , p_header_shipment_rec   =>  l_hd_shipment_rec
                    , p_header_payment_rec    =>  l_hd_payment_rec
                    , p_header_tax_detail_rec =>  l_hd_tax_detail_rec
                    , x_quote_header_rec      =>  l_qte_header_rec
                    , x_header_misc_rec       =>  lx_hd_misc_rec
                    , x_header_shipment_rec   =>  lx_hd_shipment_rec
                    , x_header_payment_rec    =>  lx_hd_payment_rec
                    , x_header_tax_detail_rec =>  lx_hd_tax_detail_rec
                    , x_quote_line_rec        =>  lx_quote_line_rec
                    , x_line_misc_rec         =>  lx_ln_misc_rec
                    , x_line_shipment_rec     =>  lx_ln_shipment_rec
                    , x_line_payment_rec      =>  lx_ln_payment_rec
                    , x_line_tax_detail_rec   =>  lx_ln_tax_detail_rec
                    , x_changed_flag          =>  lx_changed_flag
                    , x_return_status	      =>  x_return_status
                    , x_msg_count		      =>  x_msg_count
                    , x_msg_data		      =>  x_msg_data);

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_DEFAULTING');
                   FND_MSG_PUB.ADD;
               END IF;

               IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
               END IF;

          END IF;

          IF Shipment_Null_Rec_Exists(lx_hd_shipment_rec, l_db_object_name) THEN
              l_hd_shipment_tbl(1) := lx_hd_shipment_rec;
          END IF;

          IF Payment_Null_Rec_Exists(lx_hd_payment_rec, l_db_object_name) THEN
              l_hd_payment_tbl(1) := lx_hd_payment_rec;
          END IF;

          IF Tax_Detail_Null_Rec_Exists(lx_hd_tax_detail_rec, l_db_object_name) THEN
              l_hd_tax_detail_tbl(1) := lx_hd_tax_detail_rec;
          END IF;

      END IF;
 */
      -- hyang defaulting framework end


      -- validate header information

	 if aso_debug_pub.g_debug_flag = 'Y' then
	     aso_debug_pub.add('Create_Quote: p_validation_level: ' || p_validation_level, 1, 'Y');
	 end if;

      IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN

	       ASO_PARTY_INT.Validate_CustAccount (
                            p_init_msg_list   => FND_API.G_FALSE,
                            p_party_id        => l_qte_header_rec.party_id,
                            p_cust_account_id => l_qte_header_rec.cust_account_id,
                            x_return_status   => x_return_status,
                            x_msg_count	      => x_msg_count,
                            x_msg_data        => x_msg_data );

            if aso_debug_pub.g_debug_flag = 'Y' then
                aso_debug_pub.add('Create_Quote: After call to validate_custaccount: x_return_status: ' || x_return_status, 1, 'Y');
            end if;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   	           RAISE FND_API.G_EXC_ERROR;
            END IF;

            ASO_VALIDATE_PVT.Validate_Quote_Exp_date(
                            p_init_msg_list         => FND_API.G_FALSE,
                            p_quote_expiration_date => p_qte_header_rec.quote_expiration_date,
                            x_return_status         => x_return_status,
                            x_msg_count	            => x_msg_count,
                            x_msg_data              => x_msg_data );

            if aso_debug_pub.g_debug_flag = 'Y' then
                aso_debug_pub.add('Create_Quote: After call to Validate_Quote_Exp_date: x_return_status: ' || x_return_status, 1, 'Y');
            end if;

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_EXPIRATION_DATE');
                    FND_MSG_PUB.ADD;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- price list must exist and be active in OE_PRICE_LISTS
            ASO_VALIDATE_PVT.Validate_PriceList (
                            p_init_msg_list	=> FND_API.G_FALSE,
                            p_price_list_id	=> l_qte_header_rec.price_list_id,
                            x_return_status  => x_return_status,
                            x_msg_count	     => x_msg_count,
                            x_msg_data	     => x_msg_data);

            if aso_debug_pub.g_debug_flag = 'Y' then
                aso_debug_pub.add('Create_Quote: After call to Validate_PriceList: x_return_status: ' || x_return_status, 1, 'Y');
            end if;

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                    FND_MESSAGE.Set_Token('COLUMN', 'PRICE_LIST_ID', FALSE);
                    FND_MSG_PUB.ADD;
                END IF;
	           RAISE FND_API.G_EXC_ERROR;
	       END IF;

            ASO_VALIDATE_PVT.Validate_Quote_Price_Exp(
  	                      p_init_msg_list         => FND_API.G_FALSE,
                           p_price_list_id         => l_qte_header_rec.price_list_id,
                           p_quote_expiration_date => l_qte_header_rec.quote_expiration_date,
                           x_return_status         => x_return_status,
	                      x_msg_count             => x_msg_count,
	                      x_msg_data              => x_msg_data);

            if aso_debug_pub.g_debug_flag = 'Y' then
                aso_debug_pub.add('Create_Quote: After call to Validate_Quote_Price_Exp: x_return_status: ' || x_return_status, 1, 'Y');
            end if;

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
				FND_MESSAGE.Set_Token('COLUMN', 'Price List Expires Before Quote', FALSE);
                    FND_MSG_PUB.ADD;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF l_qte_header_rec.quote_status_id IS NOT NULL AND l_qte_header_rec.quote_status_id <> FND_API.G_MISS_NUM THEN

  	           -- status must exist and be active in ASO_QUOTE_STATUSES
  	           ASO_VALIDATE_PVT.Validate_Quote_Status (
  		                 p_init_msg_list    => FND_API.G_FALSE,
                           p_quote_status_id  => l_qte_header_rec.quote_status_id,
                           x_return_status    => x_return_status,
                           x_msg_count        => x_msg_count,
                           x_msg_data         => x_msg_data);

                if aso_debug_pub.g_debug_flag = 'Y' then
                    aso_debug_pub.add('Create_Quote: After call to Validate_Quote_Status: x_return_status: ' || x_return_status, 1, 'Y');
                end if;

  	           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  	                   FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                        FND_MESSAGE.Set_Token('COLUMN', 'QUOTE_STATUS_ID', FALSE);
                        FND_MSG_PUB.ADD;
  	               END IF;
  	               RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

            if aso_debug_pub.g_debug_flag = 'Y' then
                aso_debug_pub.add('Create_Quote: p_hd_sales_credit_tbl.count: ' || p_hd_sales_credit_tbl.count, 1, 'Y');
            end if;

            FOR i in 1..p_hd_sales_credit_tbl.count LOOP

                if aso_debug_pub.g_debug_flag = 'Y' then
                    aso_debug_pub.add('p_hd_sales_credit_tbl('||i||').operation_code: '|| p_hd_sales_credit_tbl(i).operation_code,1,'Y');
                end if;

                if (p_hd_sales_credit_tbl(i).operation_code = 'CREATE' or p_hd_sales_credit_tbl(i).operation_code = 'UPDATE') then

                    ASO_VALIDATE_PVT.Validate_Resource_id(
                              p_init_msg_list => FND_API.G_FALSE,
                              p_resource_id	 => p_hd_sales_credit_tbl(i).resource_id  ,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data);

                    if aso_debug_pub.g_debug_flag = 'Y' then
                        aso_debug_pub.add('Create_Quote: After call to Validate_Resource_id: x_return_status: ' || x_return_status, 1, 'Y');
                    end if;

                    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_SALES_REP_ID');
                            FND_MSG_PUB.ADD;
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    ASO_VALIDATE_PVT.Validate_Resource_group_id(
                              p_init_msg_list     => FND_API.G_FALSE,
                              p_resource_group_id => p_hd_sales_credit_tbl(i).resource_group_id,
                              x_return_status     => x_return_status,
                              x_msg_count         => x_msg_count,
                              x_msg_data          => x_msg_data);

                     if aso_debug_pub.g_debug_flag = 'Y' then
                         aso_debug_pub.add('Create_Quote: After call to Validate_Resource_group_id: x_return_status: ' || x_return_status, 1, 'Y');
                     end if;

                     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                         RAISE FND_API.G_EXC_ERROR;
                     END IF;

                     ASO_VALIDATE_PVT.Validate_Salescredit_Type(
                              p_init_msg_list        => FND_API.G_FALSE,
                              p_salescredit_type_id  => p_hd_sales_credit_tbl(i).sales_credit_type_id,
                              x_return_status        => x_return_status,
                              x_msg_count            => x_msg_count,
                              x_msg_data             => x_msg_data);

                     if aso_debug_pub.g_debug_flag = 'Y' then
                         aso_debug_pub.add('Create_Quote: After call to Validate_Salescredit_Type: x_return_status: ' || x_return_status, 1, 'Y');
                     end if;

                     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                         RAISE FND_API.G_EXC_ERROR;
                     END IF;

                     ASO_VALIDATE_PVT.Validate_EmployPerson(
                              p_init_msg_list => FND_API.G_FALSE,
                              p_employee_id   => p_hd_sales_credit_tbl(i).employee_person_id,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data);

                     if aso_debug_pub.g_debug_flag = 'Y' then
                         aso_debug_pub.add('Create_Quote: After call to Validate_EmployPerson: x_return_status: ' || x_return_status, 1, 'Y');
                     end if;

                     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                         RAISE FND_API.G_EXC_ERROR;
                     END IF;

                end if;

            END LOOP;

            if aso_debug_pub.g_debug_flag = 'Y' then
                aso_debug_pub.add('Create_Quote: p_hd_quote_party_tbl.count: ' || p_hd_quote_party_tbl.count, 1, 'Y');
            end if;

            FOR i in 1..p_hd_quote_party_tbl.count LOOP

                 ASO_VALIDATE_PVT.Validate_Party_Type(
		                p_init_msg_list => FND_API.G_FALSE,
		                p_party_type    => p_hd_quote_party_tbl(i).party_type,
        	                x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data);

                 if aso_debug_pub.g_debug_flag = 'Y' then
                     aso_debug_pub.add('Create_Quote: After call to Validate_Party_Type: x_return_status: ' || x_return_status, 1, 'Y');
                 end if;

                 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                     RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 ASO_VALIDATE_PVT.Validate_Party(
                          p_init_msg_list => FND_API.G_FALSE,
                          p_party_id      => p_hd_quote_party_tbl(i).party_id,
                          p_party_usage	  => null,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data);

                 if aso_debug_pub.g_debug_flag = 'Y' then
                     aso_debug_pub.add('Create_Quote: After call to Validate_Party: x_return_status: ' || x_return_status, 1, 'Y');
                 end if;

                 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                     RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 ASO_VALIDATE_PVT.Validate_Party_Object_Type(
                          p_init_msg_list     => FND_API.G_FALSE,
                          p_party_object_type => p_hd_quote_party_tbl(i).party_object_type,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count,
                          x_msg_data          => x_msg_data);

                 if aso_debug_pub.g_debug_flag = 'Y' then
                     aso_debug_pub.add('Create_Quote: After call to Validate_Party_Object_Type: x_return_status: ' || x_return_status, 1, 'Y');
                 end if;

                 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                     RAISE FND_API.G_EXC_ERROR;
                 END IF;

            END LOOP;


            ASO_VALIDATE_PVT.Validate_item_tca_bsc(
                          p_init_msg_list    => FND_API.G_FALSE,
                          p_qte_header_rec   => l_qte_header_rec,
                          p_shipment_rec     => p_hd_shipment_rec,  -- Added for Bug 17654969
                          p_operation_code   => 'CREATE',
                          p_application_type_code   => l_control_rec.application_type_code,
                          x_return_status    => x_return_status,
                          x_msg_count        => x_msg_count,
                          x_msg_data         => x_msg_data);

            if aso_debug_pub.g_debug_flag = 'Y' then
                aso_debug_pub.add('Create_Quote: After call to Validate_item_tca_bsc: x_return_status: ' || x_return_status, 1, 'Y');
            end if;

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            ASO_VALIDATE_PVT.Validate_Resource_id(
                          p_init_msg_list    => FND_API.G_FALSE,
                          p_resource_id      => l_qte_header_rec.resource_id,
                          x_return_status    => x_return_status,
                          x_msg_count        => x_msg_count,
                          x_msg_data         => x_msg_data);

            if aso_debug_pub.g_debug_flag = 'Y' then
                aso_debug_pub.add('Create_Quote: After call to Validate_Resource_id: x_return_status: ' || x_return_status, 1, 'Y');
            end if;

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

     END IF;  --IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN


     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Create_Quote: Before call to Populate_Qte_Header', 1, 'Y');
     END IF;


     Populate_Qte_Header( p_qte_header_rec => l_qte_header_rec,
	                     p_Control_Rec    => l_control_rec,
					 x_qte_header_rec => lx_out_qte_header_rec);

				l_qte_header_rec	:=  lx_out_qte_header_rec;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Create_Quote: After call to Populate_Qte_Header', 1, 'Y');
	END IF;


     IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN

            IF l_hd_shipment_tbl.count > 0 THEN
                l_shipment_rec := l_hd_shipment_tbl(1);
            END IF;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Create_Quote: Before call to Validate_record_tca_crs', 1, 'N');
            END IF;

            ASO_VALIDATE_PVT.Validate_record_tca_crs(
    	                     p_init_msg_list   => FND_API.G_FALSE,
    	                     p_qte_header_rec  => l_qte_header_rec,
    	                     p_shipment_rec    => l_shipment_rec,
    	                     p_operation_code  => 'CREATE',
    	                     p_application_type_code  => l_control_rec.application_type_code,
    	                     x_return_status   => x_return_status,
                          x_msg_count       => x_msg_count,
                          x_msg_data        => x_msg_data);

            if aso_debug_pub.g_debug_flag = 'Y' then
                aso_debug_pub.add('Create_Quote: After call to Validate_record_tca_crs: x_return_status: ' || x_return_status, 1, 'Y');
            end if;

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

       -- bug 5196952 validate the ship method code
       IF (l_shipment_rec.ship_method_code is not null and l_shipment_rec.ship_method_code <> fnd_api.g_miss_char and l_shipment_rec.operation_code = 'CREATE') then

          -- get the master org id from the quote hdr org id
          OPEN c_inv_org_id(l_qte_header_rec.org_id);
          FETCH c_inv_org_id into l_master_organization_id;
          CLOSE c_inv_org_id;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Create_Quote - l_master_organization_id:  '|| l_master_organization_id, 1, 'N');
           aso_debug_pub.add('Create_Quote - l_qte_header_rec.org_id:   '|| l_qte_header_rec.org_id, 1, 'N');
           aso_debug_pub.add('Create_Quote - before validate ship_method_code ', 1, 'N');
          end if;
         ASO_VALIDATE_PVT.validate_ship_method_code
         (
          p_init_msg_list          => fnd_api.g_false,
          p_qte_header_id          => l_qte_header_rec.quote_header_id,
          p_qte_line_id            => fnd_api.g_miss_num,
          p_organization_id        => l_master_organization_id,
          p_ship_method_code       => l_shipment_rec.ship_method_code,
          p_operation_code         => 'CREATE',
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data);

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Create_Quote - After validate ship_method_code ', 1, 'N');
          end if;

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
        end if;  -- end if for ship method code check

     END IF;  --IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN


     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Create_Quote: Before call to check_tca', 1, 'N');
     END IF;

     ASO_CHECK_TCA_PVT.check_tca( p_api_version         => 1.0,
                                  p_init_msg_list       => FND_API.G_FALSE,
                                  P_Qte_Rec             => l_qte_header_rec,
    		                        p_Header_Shipment_Tbl => l_hd_Shipment_Tbl,
                                  P_Operation_Code      => 'CREATE',
                                  p_application_type_code      => l_control_rec.application_type_code,
                                  x_return_status       => x_return_status,
                                  x_msg_count           => x_msg_count,
                                  x_msg_data            => x_msg_data);

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Create_Quote: After call to check_tca: x_return_status: ' || x_return_status, 1, 'Y');
	END IF;

    	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
    	    RAISE FND_API.G_EXC_ERROR;
    	END IF;

	-- order_type must exist and be active in OE_ORDER_TYPES
     ASO_TRADEIN_PVT.OrderType( p_init_msg_list         => FND_API.G_FALSE,
                                p_qte_header_rec        => l_qte_header_rec,
                                x_return_status 		 => x_return_status,
                                x_msg_count     		 => x_msg_count,
                                x_msg_data      		 => x_msg_data);

	 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR;
	 END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote: After call to OrderType: x_return_status: ' || x_return_status, 1, 'Y');
	 END IF;

      IF p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_INTER_RECORD THEN


           ASO_VALIDATE_PVT.Validate_NotNULL_VARCHAR2 (
                      p_init_msg_list   => FND_API.G_FALSE,
                      p_column_name     => 'CURRENCY_CODE',
                      p_notnull_column  => l_qte_header_rec.currency_code,
                      x_return_status   => x_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Create_Quote: After call to Validate_NotNULL_VARCHAR2: x_return_status: ' || x_return_status, 1, 'Y');
	      END IF;

           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           ASO_VALIDATE_PVT.Validate_NotNULL_VARCHAR2 (
                      p_init_msg_list  => FND_API.G_FALSE,
                      p_column_name    => 'SOURCE_CODE',
                      p_notnull_column => l_qte_header_rec.quote_source_code,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data );

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Create_Quote: After call to Validate_NotNULL_VARCHAR2: x_return_status: ' || x_return_status, 1, 'Y');
	      END IF;

           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
                   FND_MESSAGE.Set_Token('COLUMN', 'SOURCE_CODE', FALSE);
                   FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Create_Quote: Before validate_tax_exemption ', 1, 'N');
           END IF;

	      -- tax_exempt_flag must be in 'E', 'R' and 'S'
	      -- and tax_exempt_reason_code must exist if tax_exempt_flag is 'E'.

           FOR i IN 1..l_hd_tax_detail_tbl.count LOOP

                ASO_VALIDATE_PVT.Validate_Tax_Exemption (
                             p_init_msg_list          => FND_API.G_FALSE,
                             p_tax_exempt_flag        => l_hd_tax_detail_tbl(i).tax_exempt_flag,
                             p_tax_exempt_reason_code => l_hd_tax_detail_tbl(i).tax_exempt_reason_code,
                             x_return_status          => x_return_status,
                             x_msg_count              => x_msg_count,
                             x_msg_data               => x_msg_data );

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Create_Quote: After call to Validate_Tax_Exemption: x_return_status: ' || x_return_status, 1, 'Y');
	           END IF;

	           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
                        FND_MESSAGE.Set_Token('COLUMN', 'TAX_EXEMPT_REASON', FALSE);
                        FND_MSG_PUB.ADD;
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

	      END LOOP;

           FOR i IN 1..p_ln_tax_detail_tbl.count LOOP

                ASO_VALIDATE_PVT.Validate_Tax_Exemption (
                             p_init_msg_list          => FND_API.G_FALSE,
                             p_tax_exempt_flag        => p_ln_tax_detail_tbl(i).tax_exempt_flag,
                             p_tax_exempt_reason_code => p_ln_tax_detail_tbl(i).tax_exempt_reason_code,
                             x_return_status          => x_return_status,
                             x_msg_count              => x_msg_count,
                             x_msg_data               => x_msg_data );

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Create_Quote: After call to Validate_Tax_Exemption: x_return_status: ' || x_return_status, 1, 'Y');
	           END IF;

	           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
                        FND_MESSAGE.Set_Token('COLUMN', 'TAX_EXEMPT_REASON', FALSE);
                        FND_MSG_PUB.ADD;
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
	           END IF;

           END LOOP;

           FOR i in 1..p_hd_quote_party_tbl.count LOOP

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('Create_Quote: Before call to Validate_Party_Object_Id', 1, 'N');
                 END IF;

                 ASO_VALIDATE_PVT.Validate_Party_Object_Id(
                             p_init_msg_list     => FND_API.G_FALSE,
                             p_party_id          => p_hd_quote_party_tbl(i).party_id,
                             p_party_object_type => p_hd_quote_party_tbl(i).party_object_type,
                             p_party_object_id   => p_hd_quote_party_tbl(i).party_object_id,
                             x_return_status     => x_return_status,
                             x_msg_count         => x_msg_count,
                             x_msg_data          => x_msg_data);

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('Create_Quote: After call to Validate_Party_Object_Id: x_return_status: ' || x_return_status, 1, 'Y');
	            END IF;

                 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                    FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
                         FND_MESSAGE.Set_Token('INFO', 'PARTY OBJECT ID', FALSE);
	                    FND_MSG_PUB.ADD;
                     END IF;
                     RAISE FND_API.G_EXC_ERROR;
                 END IF;

           END LOOP;

           ASO_VALIDATE_PVT.Validate_Emp_Res_id(
                             p_init_msg_list       => FND_API.G_FALSE,
                             p_resource_id         =>  p_qte_header_rec.resource_id,
                             p_employee_person_id  =>  p_qte_header_rec.employee_person_id ,
                             x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data  );

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Create_Quote: After call to Validate_Emp_Res_id: x_return_status: ' || x_return_status, 1, 'Y');
	      END IF;

           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

      END IF;  --IF p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_INTER_RECORD THEN


      IF (FND_PROFILE.Value('ASO_ENABLE_SPLIT_PAYMENT') = 'N') THEN

           IF l_hd_payment_tbl.count > 1 THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_API_SPLIT_PAYMENT');
                   FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_ERROR;

           ELSIF l_hd_payment_tbl.count = 1 THEN

               IF l_hd_payment_tbl(1).payment_option = 'SPLIT' THEN

                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       FND_MESSAGE.Set_Name('ASO', 'ASO_API_SPLIT_PAYMENT');
                       FND_MSG_PUB.ADD;
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

           END IF;

      END IF;

      IF (FND_PROFILE.Value('ASO_ENABLE_SPLIT_PAYMENT') = 'Y') THEN

           IF l_hd_payment_tbl.count > 1 THEN

               FOR i IN 1..l_hd_payment_tbl.count LOOP

                    IF l_hd_payment_tbl(i).payment_option <> 'SPLIT' THEN

                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            FND_MESSAGE.Set_Name('ASO', 'ASO_API_TOO_MANY_PAYMENTS');
                            FND_MSG_PUB.ADD;
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;

               END LOOP;
           END IF;
      END IF;

	 IF l_hd_tax_detail_tbl.count > 1 THEN

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_API_TOO_MANY_TAX_RECORDS');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote: Before Validate_Agreement:l_qte_header_rec.contract_id: '||l_qte_header_rec.contract_id, 1, 'N');
      END IF;

      IF (l_qte_header_rec.contract_id IS NOT NULL AND
          l_qte_header_rec.contract_id <> FND_API.G_MISS_NUM) THEN

          ASO_VALIDATE_PVT.Validate_Agreement(
               p_init_msg_list             => FND_API.G_FALSE,
               P_Agreement_Id              => l_qte_header_rec.contract_id,
               x_return_status             => x_return_status,
               x_msg_count                 => x_msg_count,
               x_msg_data                  => x_msg_data);

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
		    aso_debug_pub.add('Create_Quote: After call to Validate_Agreement: x_return_status: '||x_return_status, 1, 'N');
		END IF;

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote: p_qte_header_rec.minisite_id: '|| p_qte_header_rec.minisite_id);
      END IF;

      IF (p_qte_header_rec.minisite_id IS NOT NULL AND
          p_qte_header_rec.minisite_id <> FND_API.G_MISS_NUM) THEN

          ASO_VALIDATE_PVT.Validate_MiniSite( p_init_msg_list => FND_API.G_FALSE,
                                              p_minisite_id   => p_qte_header_rec.minisite_id,
                                              x_return_status => x_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data);

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
		    aso_debug_pub.add('Create_Quote: After call to ASO_VALIDATE_PVT.Validate_MiniSite');
	         aso_debug_pub.add('Create_Quote: x_return_status: '|| x_return_status);
		END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Create_Quote: Before populating the ID for Salesrep,Marketing code and contact Name', 1, 'Y');
      END IF;

If (nvl(l_qte_header_rec.MARKETING_SOURCE_CODE_ID,fnd_api.g_miss_num) = fnd_api.g_miss_num) AND
 (nvl(l_qte_header_rec.MARKETING_SOURCE_CODE,fnd_api.g_miss_char) <> fnd_api.g_miss_char OR
 nvl(l_qte_header_rec.MARKETING_SOURCE_NAME,fnd_api.g_miss_char) <> fnd_api.g_miss_char) THEN
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.MARKETING_SOURCE_CODE: '|| l_qte_header_rec.MARKETING_SOURCE_CODE, 1, 'N');
        aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.MARKETING_SOURCE_NAME: '|| l_qte_header_rec.MARKETING_SOURCE_NAME, 1, 'N');
     END IF;

     OPEN c_market_source_id(l_qte_header_rec.MARKETING_SOURCE_CODE,l_qte_header_rec.MARKETING_SOURCE_NAME );
        FETCH c_market_source_id INTO l_qte_header_rec.MARKETING_SOURCE_CODE_ID;
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Create_Quote  Web Service: l_qte_header_rec.MARKETING_SOURCE_CODE_ID: '|| l_qte_header_rec.MARKETING_SOURCE_CODE_ID, 1, 'N');
         END IF;

      If (c_market_source_id %rowcount ) > 1 OR (c_market_source_id %rowcount )=0 Then
          x_return_status := FND_API.G_RET_STS_ERROR;
           aso_debug_pub.add('Create_Quote Web Service Market_source_code is not unique', 1, 'N');

         fnd_message.set_name( 'ASO', 'ASO_NO_UNIQUE_MARKT_SOUR_NAME' ) ;
         FND_MESSAGE.SET_TOKEN('MARKET_SOURCE_COUNT',c_market_source_id%rowcount);
         fnd_message.set_token( 'MARKETING_SOURCE_CODE', l_qte_header_rec.MARKETING_SOURCE_CODE,TRUE) ;
         fnd_message.set_token( 'MARKETING_SOURCE_NAME', l_qte_header_rec.MARKETING_SOURCE_NAME,TRUE) ;
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
        CLOSE c_market_source_id;
   End if;


   If (nvl(l_qte_header_rec.RESOURCE_ID ,fnd_api.g_miss_num) = fnd_api.g_miss_num)  AND
  nvl(l_qte_header_rec.SALESREP_FIRST_NAME ,fnd_api.g_miss_char) <> fnd_api.g_miss_char  OR nvl(l_qte_header_rec.SALESREP_LAST_NAME,fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.SALESREP_FIRST_NAME: '|| l_qte_header_rec.SALESREP_FIRST_NAME, 1, 'N');
    aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.SALESREP_LAST_NAME : '|| l_qte_header_rec.SALESREP_LAST_NAME, 1, 'N');
    aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.ORG_ID: '|| l_qte_header_rec.ORG_ID, 1, 'N');
     END IF;

       OPEN c_sales_rep_id(l_qte_header_rec.SALESREP_FIRST_NAME ,l_qte_header_rec.SALESREP_LAST_NAME  , l_qte_header_rec.ORG_ID );
       FETCH c_sales_rep_id INTO l_qte_header_rec.RESOURCE_ID;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote  Web Service:l_qte_header_rec.RESOURCE_ID: '|| l_qte_header_rec.RESOURCE_ID, 1, 'N');
      END IF;

       If (c_sales_rep_id %rowcount ) > 1 OR (c_sales_rep_id %rowcount ) = 0 Then
          x_return_status := FND_API.G_RET_STS_ERROR;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote Web Service sales_rep_name  is not unique', 1, 'N');
        End if;

          fnd_message.set_name( 'ASO', 'ASO_NO_UNIQUE_SALES_REP_NAME' ) ;
          FND_MESSAGE.SET_TOKEN('SALESREP_COUNT',c_sales_rep_id%rowcount);
          fnd_message.set_token( 'SALESREP_FIRST_NAME',l_qte_header_rec.SALESREP_FIRST_NAME,TRUE) ;
          fnd_message.set_token( 'SALESREP_LAST_NAME', l_qte_header_rec.SALESREP_LAST_NAME,TRUE) ;
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  close c_sales_rep_id;
End If;


If (nvl(l_qte_header_rec.PARTY_ID ,fnd_api.g_miss_num) = fnd_api.g_miss_num)  AND
  nvl(l_qte_header_rec.PARTY_NAME ,fnd_api.g_miss_char) <> fnd_api.g_miss_char  OR
  nvl(l_qte_header_rec.PERSON_FIRST_NAME ,fnd_api.g_miss_char) <> fnd_api.g_miss_char
  OR  nvl(l_qte_header_rec.PERSON_MIDDLE_NAME ,fnd_api.g_miss_char) <> fnd_api.g_miss_char OR
 nvl(l_qte_header_rec.PERSON_LAST_NAME, fnd_api.g_miss_char) <> fnd_api.g_miss_char then

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.PARTY_NAME: '|| l_qte_header_rec.PARTY_NAME, 1, 'N');
    aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.PERSON_FIRST_NAME: '|| l_qte_header_rec.PERSON_FIRST_NAME, 1, 'N');
    aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.PERSON_MIDDLE_NAME: '|| l_qte_header_rec.PERSON_MIDDLE_NAME, 1, 'N');
    aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.PERSON_LAST_NAME: '|| l_qte_header_rec.PERSON_LAST_NAME, 1, 'N');
    aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.CUST_PARTY_ID: '|| l_qte_header_rec.CUST_PARTY_ID, 1, 'N');

     END IF;

 OPEN  c_party_id (l_qte_header_rec.PARTY_NAME, l_qte_header_rec.PERSON_FIRST_NAME ,l_qte_header_rec.PERSON_MIDDLE_NAME , l_qte_header_rec.PERSON_LAST_NAME , l_qte_header_rec.CUST_PARTY_ID);
    FETCH c_party_id into l_qte_header_rec.Party_id;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote  Web Service :l_qte_header_rec.Party_id: '|| L_qte_header_rec.Party_id, 1, 'N');
      END IF;

       If (c_party_id %rowcount ) > 1 OR (c_party_id %rowcount ) =0 Then
          x_return_status := FND_API.G_RET_STS_ERROR;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Create_Quote Web Service Sold_to_party_name  is not unique', 1, 'N');
           End if;

          	fnd_message.set_name( 'ASO', 'ASO_NO_UNIQUE_QOT_CONTACT_NAME' ) ;
         FND_MESSAGE.SET_TOKEN('QOT_CONT_COUNT',c_party_id%rowcount);
         fnd_message.set_token( 'CONTACT_PARTY_NAME',l_qte_header_rec.PARTY_NAME,TRUE) ;
         fnd_message.set_token( 'CONTACT_FIRST_NAME', l_qte_header_rec.PERSON_FIRST_NAME ,TRUE) ;
         fnd_message.set_token( 'CONTACT_MIDDLE_NAME', l_qte_header_rec.PERSON_MIDDLE_NAME,TRUE) ;
        fnd_message.set_token( 'CONTACT_LAST_NAME', l_qte_header_rec.PERSON_LAST_NAME,TRUE) ;
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
Close c_party_id;
End If;

If (nvl(l_qte_header_rec.invoice_to_PARTY_ID ,fnd_api.g_miss_num) = fnd_api.g_miss_num) AND
 nvl(l_qte_header_rec.INVOICE_TO_PARTY_NAME ,fnd_api.g_miss_char)<> fnd_api.g_miss_char  OR
 nvl(l_qte_header_rec.INVOICE_TO_CONTACT_FIRST_NAME ,fnd_api.g_miss_char)<> fnd_api.g_miss_char OR
 nvl(l_qte_header_rec.INVOICE_TO_CONTACT_MIDDLE_NAME ,fnd_api.g_miss_char)<> fnd_api.g_miss_char OR
 nvl(l_qte_header_rec.INVOICE_TO_CONTACT_LAST_NAME ,fnd_api.g_miss_char )<> fnd_api.g_miss_char then

 IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.INVOICE_TO_PARTY_NAME: '|| l_qte_header_rec.INVOICE_TO_PARTY_NAME, 1, 'N');
    aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.INVOICE_TO_CONTACT_FIRST_NAME: '|| l_qte_header_rec.INVOICE_TO_CONTACT_FIRST_NAME, 1, 'N');
    aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.INVOICE_TO_CONTACT_MIDDLE_NAME: '|| l_qte_header_rec.INVOICE_TO_CONTACT_MIDDLE_NAME, 1, 'N');
    aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.INVOICE_TO_CONTACT_LAST_NAME: '|| l_qte_header_rec.INVOICE_TO_CONTACT_LAST_NAME, 1, 'N');
     aso_debug_pub.add('Create_Quote Web Service l_qte_header_rec.INVOICE_TO_CUST_PARTY_ID : '|| l_qte_header_rec.INVOICE_TO_CUST_PARTY_ID , 1, 'N');
  END IF;
 OPEN  c_party_id (l_qte_header_rec.INVOICE_TO_PARTY_NAME , l_qte_header_rec.INVOICE_TO_CONTACT_FIRST_NAME ,
l_qte_header_rec.INVOICE_TO_CONTACT_MIDDLE_NAME ,
 l_qte_header_rec.INVOICE_TO_CONTACT_LAST_NAME ,
 nvl(l_qte_header_rec.INVOICE_TO_CUST_PARTY_ID ,
 l_qte_header_rec.CUST_PARTY_ID));

FETCH c_party_id into l_qte_header_rec.invoice_to_party_id;
 IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('Create_Quote  Web Service :l_qte_header_rec.invoice_to_party_id: '|| l_qte_header_rec.invoice_to_party_id, 1, 'N');
 End If;

 If (c_party_id %rowcount ) > 1 OR (c_party_id %rowcount ) =0 Then
          x_return_status := FND_API.G_RET_STS_ERROR;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Create_Quote Web Service Invoice_to_party_name  is not unique', 1, 'N');
        End if;

          	fnd_message.set_name( 'ASO', 'ASO_NO_UNIQUE_INV_CONT_NAME' ) ;
         FND_MESSAGE.SET_TOKEN('INV_CONT_COUNT',c_party_id%rowcount);
         fnd_message.set_token( 'CONTACT_PARTY_NAME',l_qte_header_rec.INVOICE_TO_PARTY_NAME,TRUE) ;
         fnd_message.set_token( 'CONTACT_FIRST_NAME',l_qte_header_rec.INVOICE_TO_CONTACT_FIRST_NAME,TRUE) ;
         fnd_message.set_token( 'CONTACT_MIDDLE_NAME', l_qte_header_rec.INVOICE_TO_CONTACT_MIDDLE_NAME,TRUE) ;
        fnd_message.set_token( 'CONTACT_LAST_NAME', l_qte_header_rec.INVOICE_TO_CONTACT_LAST_NAME,TRUE) ;
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
Close c_party_id;
End If;


If (nvl(p_hd_shipment_rec.ship_to_PARTY_ID ,fnd_api.g_miss_num )= fnd_api.g_miss_num)
AND  (nvl( p_hd_shipment_rec.ship_to_PARTY_NAME ,fnd_api.g_miss_char)<> fnd_api.g_miss_char)
OR   (nvl(p_hd_shipment_rec.SHIP_TO_CONTACT_FIRST_NAME ,fnd_api.g_miss_char) <> fnd_api.g_miss_char )
OR  (nvl(p_hd_shipment_rec.SHIP_TO_CONTACT_MIDDLE_NAME ,fnd_api.g_miss_char) <> fnd_api.g_miss_char)  OR
 nvl(p_hd_shipment_rec.SHIP_TO_CONTACT_LAST_NAME  ,fnd_api.g_miss_char)<> fnd_api.g_miss_char  then

 IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Create_Quote Web Service l_hd_shipment_rec.ship_to_PARTY_NAME: '|| p_hd_shipment_rec.ship_to_PARTY_NAME, 1, 'N');
    aso_debug_pub.add('Create_Quote Web Service l_hd_shipment_rec.SHIP_TO_CONTACT_FIRST_NAME: '|| p_hd_shipment_rec.SHIP_TO_CONTACT_FIRST_NAME, 1, 'N');
    aso_debug_pub.add('Create_Quote Web Service l_hd_shipment_rec.SHIP_TO_CONTACT_MIDDLE_NAME: '|| p_hd_shipment_rec.SHIP_TO_CONTACT_MIDDLE_NAME, 1, 'N');
    aso_debug_pub.add('Create_Quote Web Service l_hd_shipment_rec.SHIP_TO_CONTACT_LAST_NAME : '|| p_hd_shipment_rec.SHIP_TO_CONTACT_LAST_NAME , 1, 'N');
     aso_debug_pub.add('Create_Quote Web Service l_hd_shipment_rec.SHIP_TO_CUST_PARTY_ID: '|| p_hd_shipment_rec.SHIP_TO_CUST_PARTY_ID , 1, 'N');
  END IF;

 OPEN  c_party_id (p_hd_shipment_rec.ship_to_PARTY_NAME ,p_hd_shipment_rec.SHIP_TO_CONTACT_FIRST_NAME ,
p_hd_shipment_rec.SHIP_TO_CONTACT_MIDDLE_NAME , p_hd_shipment_rec.SHIP_TO_CONTACT_LAST_NAME ,
 nvl(p_hd_shipment_rec.SHIP_TO_CUST_PARTY_ID , l_qte_header_rec.CUST_PARTY_ID));

 FETCH c_party_id into l_hd_shipment_rec.ship_to_Party_id;
 l_hd_shipment_tbl(1) := l_hd_shipment_rec ;
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Create_Quote  Web Service :l_hd_shipment_rec.ship_to_Party_id: '|| l_hd_shipment_rec.ship_to_Party_id, 1, 'N');
 End If;

 If (c_party_id %rowcount ) > 1 OR (c_party_id %rowcount ) = 0 Then
          x_return_status := FND_API.G_RET_STS_ERROR;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Create_Quote Web Service Ship_to_party_name  is not unique', 1, 'N');
        End if;

         fnd_message.set_name( 'ASO', 'ASO_NO_UNIQUE_SHIP_CONT_NAME' ) ;
         FND_MESSAGE.SET_TOKEN('SHIP_CONT_COUNT',c_party_id%rowcount);
         fnd_message.set_token( 'CONTACT_PARTY_NAME',l_hd_shipment_rec.ship_to_PARTY_NAME,TRUE) ;
         fnd_message.set_token( 'CONTACT_FIRST_NAME',l_hd_shipment_rec.SHIP_TO_CONTACT_FIRST_NAME,TRUE) ;
         fnd_message.set_token( 'CONTACT_MIDDLE_NAME', l_hd_shipment_rec.SHIP_TO_CONTACT_MIDDLE_NAME,TRUE) ;
        fnd_message.set_token( 'CONTACT_LAST_NAME', l_hd_shipment_rec.SHIP_TO_CONTACT_LAST_NAME,TRUE) ;
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
Close c_party_id;
End If;

/* For BUG 22547462 */
 l_hd_sales_credit_tbl := p_hd_sales_credit_tbl;
 IF p_hd_sales_credit_tbl.count > 0 THEN
 FOR i in 1..p_hd_sales_credit_tbl.count
LOOP

    If (nvl(p_hd_sales_credit_tbl(i).RESOURCE_ID,fnd_api.g_miss_num) = fnd_api.g_miss_num) AND
        nvl(p_hd_sales_credit_tbl(i).FIRST_NAME ,fnd_api.g_miss_char) <> fnd_api.g_miss_char OR
        nvl(p_hd_sales_credit_tbl(i).LAST_NAME,fnd_api.g_miss_char) <> fnd_api.g_miss_char
    THEN

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Create_Quote Web Service p_hd_sales_credit_tbl(i).FIRST_NAME : '|| p_hd_sales_credit_tbl(i).FIRST_NAME, 1, 'N');
        aso_debug_pub.add('Create_Quote Web Service p_hd_sales_credit_tbl(i).LAST_NAME : '|| p_hd_sales_credit_tbl(i).LAST_NAME, 1, 'N');
    END IF;

    p_hd_sales_credit_rec := p_hd_sales_credit_tbl(i);

    Open c_sales_credit_resource_id(p_hd_sales_credit_rec.FIRST_NAME, p_hd_sales_credit_rec.LAST_NAME,l_qte_header_rec.ORG_ID);
    Loop
        FETCH c_sales_credit_resource_id into p_hd_sales_credit_REC.RESOURCE_ID;
        EXIT WHEN c_sales_credit_resource_id%NOTFOUND;

        l_hd_sales_credit_tbl(i).RESOURCE_ID := p_hd_sales_credit_rec.RESOURCE_ID;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote  Web Service:l_hd_sales_credit_tbl(i).RESOURCE_ID: '|| l_hd_sales_credit_tbl(i).RESOURCE_ID, 1, 'N');
        END IF;

       If (c_sales_credit_resource_id%rowcount = 0) OR (c_sales_credit_resource_id%rowcount > 1) Then
          x_return_status := FND_API.G_RET_STS_ERROR;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Create_Quote Web Service sales_credit_person_name  is not unique', 1, 'N');
         End if;

          fnd_message.set_name( 'ASO', 'ASO_NO_UNIQUE_SALES_REP_NAME' ) ;
          FND_MESSAGE.SET_TOKEN('SALESREP_COUNT',c_sales_credit_resource_id%rowcount);
          fnd_message.set_token( 'SALESREP_FIRST_NAME',p_hd_sales_credit_rec.FIRST_NAME,TRUE) ;
          fnd_message.set_token( 'SALESREP_LAST_NAME', p_hd_sales_credit_rec.LAST_NAME,TRUE) ;
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     End loop;

   /*** Bug 22565150 ***/
    Open c_SALES_RESOURCE_GROUP_ID (p_hd_sales_credit_rec.RESOURCE_ID,p_hd_sales_credit_rec.RESOURCE_GROUP_NAME);
    Loop
        FETCH c_SALES_RESOURCE_GROUP_ID into L_SALES_RESOURCE_GROUP_ID, L_SALES_RESOURCE_GROUP_NAME;


        EXIT WHEN c_SALES_RESOURCE_GROUP_ID%NOTFOUND;

        l_hd_sales_credit_tbl(i).RESOURCE_GROUP_ID := L_SALES_RESOURCE_GROUP_ID;
        l_hd_sales_credit_tbl(i).RESOURCE_GROUP_NAME := L_SALES_RESOURCE_GROUP_NAME;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote Web Service:l_hd_sales_credit_tbl(i).RESOURCE_GROUP_ID : '|| l_hd_sales_credit_tbl(i).RESOURCE_GROUP_ID, 1, 'N');
          aso_debug_pub.add('Create_Quote Web Service:l_hd_sales_credit_tbl(i).RESOURCE_GROUP_NAME : '|| l_hd_sales_credit_tbl(i).RESOURCE_GROUP_NAME, 1, 'N');
        END IF;

       If (c_SALES_RESOURCE_GROUP_ID%rowcount = 0) OR (c_SALES_RESOURCE_GROUP_ID%rowcount > 1)Then

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Create_Quote Web Service sales_credit_Group_name is not available or not unique', 1, 'N');
         End if;

          x_return_status := FND_API.G_RET_STS_ERROR;

          fnd_message.set_name( 'ASO', 'ASO_NO_UNIQUE_SALES_GROUP_NAME' ) ;
          FND_MESSAGE.SET_TOKEN('SALESGROUP_COUNT',c_SALES_RESOURCE_GROUP_ID%rowcount);
          fnd_message.set_token( 'SALESREP_FIRST_NAME',p_hd_sales_credit_rec.FIRST_NAME,TRUE) ;
          fnd_message.set_token( 'SALESREP_LAST_NAME', p_hd_sales_credit_rec.LAST_NAME,TRUE) ;
          fnd_message.set_token( 'SALES_GROUP_NAME', L_SALES_RESOURCE_GROUP_NAME,TRUE) ;

          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    End loop;
   /*** Bug 22565150 ***/

    End if;
End loop;
  End If;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote: Before call to insert_rows', 1, 'Y');
      END IF;

      Insert_Rows (
			p_qte_header_rec        => l_qte_header_rec,
			p_Price_Attributes_Tbl  => p_hd_price_attributes_tbl,
			P_Price_Adjustment_Tbl  => l_price_adj_tbl,
			P_Price_Adj_Attr_Tbl    => l_price_adj_attr_tbl,
			P_Payment_Tbl	         => l_hd_payment_tbl,
			P_Shipment_tbl	         => l_hd_shipment_tbl,
			P_Freight_Charge_Tbl    => p_hd_freight_charge_tbl,
			P_Tax_Detail_Tbl        => l_hd_tax_detail_tbl,
               P_hd_Attr_Ext_Tbl       => P_hd_Attr_Ext_Tbl,
               P_sales_credit_tbl      => l_hd_sales_credit_tbl,
               P_quote_party_tbl       => p_hd_quote_party_tbl,
               P_Qte_Access_Tbl        => P_Qte_Access_Tbl,
			x_qte_header_rec        => x_qte_header_rec,
			x_Price_Attributes_Tbl  => x_hd_price_attributes_tbl,
			x_Price_Adjustment_Tbl  => l_price_adj_tbl_out,
			x_Price_Adj_Attr_Tbl    => l_price_adj_attr_tbl_out,
			x_Payment_Tbl           => x_hd_payment_tbl,
			x_Shipment_rec	         => x_hd_shipment_rec,
			x_Freight_Charge_Tbl    => x_hd_freight_charge_tbl,
			x_Tax_Detail_Tbl        => x_hd_tax_detail_tbl,
               x_hd_Attr_Ext_Tbl       => x_hd_Attr_Ext_Tbl,
               x_sales_credit_tbl      => x_hd_sales_credit_tbl,
               x_quote_party_tbl       => x_hd_quote_party_tbl,
               x_Qte_Access_Tbl        => x_Qte_Access_Tbl,
			X_Return_Status 	    => l_return_status,
			X_Msg_Count		    => x_msg_count,
			X_Msg_Data		    => x_msg_data);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote: After call to Insert_Rows: x_return_status: '||x_return_status, 1, 'N');
      END IF;

      l_price_adj_tbl       :=  l_price_adj_tbl_out;
      l_price_adj_attr_tbl  :=  l_price_adj_attr_tbl_out;


      -- Add template rows to p_qte_line_tbl and p_qte_line_dtl tbales

      if aso_debug_pub.g_debug_flag = 'Y' then
          aso_debug_pub.add('Create_Quote: p_template_tbl.count: ' || p_template_tbl.count, 1, 'Y');
      end if;

      if p_template_tbl.count > 0 then

	    for i in 1..p_template_tbl.count loop
	        l_template_tbl(i) := p_template_tbl(i).template_id;
	    end loop;

         if aso_debug_pub.g_debug_flag = 'Y' then
             aso_debug_pub.add('Create_Quote: l_template_tbl.count:           ' || l_template_tbl.count, 1, 'Y');
             aso_debug_pub.add('Create_Quote: x_qte_header_rec.currency_code: ' || x_qte_header_rec.currency_code, 1, 'Y');
             aso_debug_pub.add('Create_Quote: x_qte_header_rec.price_list_id: ' || x_qte_header_rec.price_list_id, 1, 'Y');
             aso_debug_pub.add('Create_Quote: Before call to aso_quote_templ_pvt.add_template_to_quote procedure', 1, 'Y');
         end if;

	    aso_quote_tmpl_pvt.add_template_to_quote(
                   p_api_version_number => 1.0,
                   p_init_msg_list      => fnd_api.g_false,
                   p_commit             => fnd_api.g_false,
                   p_validation_level	=> p_validation_level,
                   p_update_flag        => 'N',
                   p_template_id_tbl    => l_template_tbl,
                   p_qte_header_rec     => x_qte_header_rec,
                   p_control_rec        => p_control_rec,
                   x_qte_line_tbl       => lx_qte_line_tbl,
                   x_qte_line_dtl_tbl   => x_qte_line_dtl_tbl,
                   x_return_status      => x_return_status,
                   x_msg_count          => x_msg_count,
                   x_msg_data           => x_msg_data
                   );


         if aso_debug_pub.g_debug_flag = 'Y' then

	        aso_debug_pub.add('Create_Quote: After call to aso_quote_templ_pvt.add_template_to_quote: x_return_status: '|| x_return_status, 1, 'Y');
	        aso_debug_pub.add('Create_Quote: lx_qte_line_tbl.count:    ' || lx_qte_line_tbl.count, 1, 'Y');
	        aso_debug_pub.add('Create_Quote: x_qte_line_dtl_tbl.count: ' || x_qte_line_dtl_tbl.count, 1, 'Y');

	        for i in 1 .. lx_qte_line_tbl.count loop
	             aso_debug_pub.add('Create_Quote: lx_qte_line_tbl('||i||').inventory_item_id: '|| lx_qte_line_tbl(i).inventory_item_id, 1, 'N');
	             aso_debug_pub.add('Create_Quote: lx_qte_line_tbl('||i||').uom_code:          '|| lx_qte_line_tbl(i).uom_code, 1, 'N');
	             aso_debug_pub.add('Create_Quote: lx_qte_line_tbl('||i||').quantity:          '|| lx_qte_line_tbl(i).quantity, 1, 'N');
	        end loop;

             for i in 1 .. x_qte_line_dtl_tbl.count loop

	             aso_debug_pub.add('Create_Quote: x_qte_line_dtl_tbl('||i||').qte_line_index:             '|| x_qte_line_dtl_tbl(i).qte_line_index, 1, 'N');
	             aso_debug_pub.add('Create_Quote: x_qte_line_dtl_tbl('||i||').ref_line_index:             '|| x_qte_line_dtl_tbl(i).ref_line_index, 1, 'N');
	             aso_debug_pub.add('Create_Quote: x_qte_line_dtl_tbl('||i||').service_ref_qte_line_index: '|| x_qte_line_dtl_tbl(i).service_ref_qte_line_index, 1, 'N');
	             aso_debug_pub.add('Create_Quote: x_qte_line_dtl_tbl('||i||').service_ref_line_id:        '|| x_qte_line_dtl_tbl(i).service_ref_line_id, 1, 'N');

		   end loop;

         end if;


	    if lx_qte_line_tbl.count > 0 then

	           l_qte_line_dtl_tbl_out := x_qte_line_dtl_tbl;

                for i in 1 .. lx_qte_line_tbl.count loop

                     l_count  :=  l_qte_line_tbl.count;

                     l_qte_line_tbl(l_count + 1) := lx_qte_line_tbl(i);

                     for j in 1 .. x_qte_line_dtl_tbl.count loop

                          if x_qte_line_dtl_tbl(j).qte_line_index = i then
                              l_qte_line_dtl_tbl_out(j).qte_line_index := l_count + 1;
                          end if;

                          if x_qte_line_dtl_tbl(j).ref_line_index = i then
                              l_qte_line_dtl_tbl_out(j).ref_line_index := l_count + 1;
                          end if;

                          if x_qte_line_dtl_tbl(j).service_ref_qte_line_index = i then
                              l_qte_line_dtl_tbl_out(j).service_ref_qte_line_index := l_count + 1;
                          end if;

                          if x_qte_line_dtl_tbl(j).top_model_line_index = i then
                              l_qte_line_dtl_tbl_out(j).top_model_line_index := l_count + 1;
                          end if;

                          if x_qte_line_dtl_tbl(j).ato_line_index = i then
                              l_qte_line_dtl_tbl_out(j).ato_line_index := l_count + 1;
                          end if;

                     end loop;

                end loop;

                if l_qte_line_dtl_tbl_out.count > 0 then

                     for i in 1 .. l_qte_line_dtl_tbl_out.count loop
                          lx_qte_line_dtl_tbl(lx_qte_line_dtl_tbl.count + 1) := l_qte_line_dtl_tbl_out(i);
                     end loop;

                end if;

	    end if; -- if lx_qte_line_tbl.count > 0 then

      end if; --if p_template_tbl.count > 0 then


	 if aso_debug_pub.g_debug_flag = 'Y' then

	     aso_debug_pub.add('Create_Quote: l_qte_line_tbl.count:      ' || l_qte_line_tbl.count, 1, 'Y');
	     aso_debug_pub.add('Create_Quote: lx_qte_line_dtl_tbl.count: ' || lx_qte_line_dtl_tbl.count, 1, 'Y');

	     for i in 1 .. l_qte_line_tbl.count loop
	          aso_debug_pub.add('Create_Quote: l_qte_line_tbl('||i||').inventory_item_id: '|| l_qte_line_tbl(i).inventory_item_id, 1, 'N');
	          aso_debug_pub.add('Create_Quote: l_qte_line_tbl('||i||').uom_code:          '|| l_qte_line_tbl(i).uom_code, 1, 'N');
	          aso_debug_pub.add('Create_Quote: l_qte_line_tbl('||i||').quantity:          '|| l_qte_line_tbl(i).quantity, 1, 'N');
	     end loop;

          for i in 1 .. lx_qte_line_dtl_tbl.count loop

	          aso_debug_pub.add('Create_Quote: lx_qte_line_dtl_tbl('||i||').qte_line_index:             '|| lx_qte_line_dtl_tbl(i).qte_line_index, 1, 'N');
	          aso_debug_pub.add('Create_Quote: lx_qte_line_dtl_tbl('||i||').ref_line_index:             '|| lx_qte_line_dtl_tbl(i).ref_line_index, 1, 'N');
	          aso_debug_pub.add('Create_Quote: lx_qte_line_dtl_tbl('||i||').service_ref_qte_line_index: '|| lx_qte_line_dtl_tbl(i).service_ref_qte_line_index, 1, 'N');
	          aso_debug_pub.add('Create_Quote: lx_qte_line_dtl_tbl('||i||').service_ref_line_id:        '|| lx_qte_line_dtl_tbl(i).service_ref_line_id, 1, 'N');
	          aso_debug_pub.add('Create_Quote: lx_qte_line_dtl_tbl('||i||').ato_line_index:             '|| lx_qte_line_dtl_tbl(i).ato_line_index, 1, 'N');
	          aso_debug_pub.add('Create_Quote: lx_qte_line_dtl_tbl('||i||').ato_line_id:                '|| lx_qte_line_dtl_tbl(i).ato_line_id, 1, 'N');
	          aso_debug_pub.add('Create_Quote: lx_qte_line_dtl_tbl('||i||').top_model_line_index:       '|| lx_qte_line_dtl_tbl(i).top_model_line_index, 1, 'N');
	          aso_debug_pub.add('Create_Quote: lx_qte_line_dtl_tbl('||i||').top_model_line_id:          '|| lx_qte_line_dtl_tbl(i).top_model_line_id, 1, 'N');

		end loop;

	 end if;

      -- End of Add template rows


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote: value of ASO_API_ENABLE_SECURITY: ' || FND_PROFILE.Value('ASO_API_ENABLE_SECURITY'), 1, 'Y');
          aso_debug_pub.add('Create_Quote: Before Assign_Team: l_sales_team_prof: ' || l_sales_team_prof, 1, 'Y');
          aso_debug_pub.add('Create_Quote: value of p_qte_header_rec.quote_type: ' || p_qte_header_rec.quote_type, 1, 'Y');
	 END IF;

      IF (NVL(FND_PROFILE.Value('ASO_API_ENABLE_SECURITY'),'N') = 'Y' AND NVL(p_qte_header_rec.quote_type, 'X') <> 'T') THEN

          lx_qte_header_rec := x_qte_header_rec;

          OPEN C_Check_Qte_Status (x_qte_header_rec.quote_header_id);
          FETCH C_Check_Qte_Status INTO l_istore_source;
          CLOSE C_Check_Qte_Status;

          IF l_sales_team_prof = 'FULL' OR l_sales_team_prof = 'PARTIAL' THEN

              IF p_control_rec.quote_source <> 'OPP_QUOTE' THEN

                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                      aso_debug_pub.add('Create_Quote: Before Assign_Team: p_control_rec.quote_source: ' || p_control_rec.quote_source, 1, 'Y');
                      aso_debug_pub.add('Create_Quote: Before Assign_Team: l_istore_source: ' || l_istore_source, 1, 'Y');
                  END IF;

                  IF l_istore_source <> 'Y' THEN

                      ASO_SALES_TEAM_PVT.Assign_Sales_Team (
                                    P_Init_Msg_List         => FND_API.G_FALSE,
                                    P_Commit                => FND_API.G_FALSE,
                                    p_Qte_Header_Rec        => x_qte_header_rec,
                                    P_Operation             => 'CREATE',
                                    x_Qte_Header_Rec        => lx_qte_header_rec,
                                    x_return_status         => x_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data );

                      IF aso_debug_pub.g_debug_flag = 'Y' THEN
                          aso_debug_pub.add('Create_Quote: After call to Assign_Sales_Team: x_return_status: '||x_return_status, 1, 'N');
                      END IF;

                      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                          RAISE FND_API.G_EXC_ERROR;
                      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;

                  END IF; --istore

              ELSE -- opp_quote

                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                      aso_debug_pub.add('Create_Quote: Before Opp_Quote_Primary_SalesRep: p_control_rec.quote_source: ' || p_control_rec.quote_source, 1, 'Y');
                  END IF;

                  ASO_SALES_TEAM_PVT.Opp_Quote_Primary_SalesRep (
                                  P_Init_Msg_List         => FND_API.G_FALSE,
                                  p_Qte_Header_Rec        => x_qte_header_rec,
                                  x_Qte_Header_Rec        => lx_qte_header_rec,
                                  x_return_status         => x_return_status,
                                  x_msg_count             => x_msg_count,
                                  x_msg_data              => x_msg_data );

                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                      aso_debug_pub.add('Create_Quote: After call to Opp_Quote_Primary_SalesRep: x_return_status: '||x_return_status, 1, 'N');
                  END IF;

                  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
                  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

              END IF; -- opp_quote

          ELSE -- prof = NONE

              ASO_SECURITY_INT.Add_SalesRep_QuoteCreator (
                          p_init_msg_list              => FND_API.G_FALSE,
                          p_commit                     => FND_API.G_FALSE,
                          p_Qte_Header_Rec             => x_qte_header_rec,
                          x_return_status              => x_return_status,
                          x_msg_count                  => x_msg_count,
                          x_msg_data                   => x_msg_data );

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Create_Quote: After call to Add_SalesRep_QuoteCreator: x_return_status: '||x_return_status, 1, 'N');
              END IF;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

	         open  c_last_update_date(x_qte_header_rec.quote_header_id);
	         fetch c_last_update_date into x_qte_header_rec.last_update_date;
	         close c_last_update_date;

              l_control_rec.last_update_date  :=  x_qte_header_rec.last_update_date;

	         IF aso_debug_pub.g_debug_flag = 'Y' THEN
		        aso_debug_pub.add('Create_Quote: After call to Add_SalesRep_QuoteCreator');
                  aso_debug_pub.add('x_qte_header_rec.last_update_date: '|| x_qte_header_rec.last_update_date);
                  aso_debug_pub.add('l_control_rec.last_update_date:    '|| l_control_rec.last_update_date);
              END IF;

          END IF; -- prof

          if aso_debug_pub.g_debug_flag = 'Y' then
              aso_debug_pub.add('Create_Quote: x_hd_sales_credit_tbl.count: '|| x_hd_sales_credit_tbl.count);
		end if;

          IF x_hd_sales_credit_tbl.count < 1 AND l_istore_source <> 'Y' THEN

              OPEN C_Get_Quota_Credit_Type;
              FETCH C_Get_Quota_Credit_Type INTO l_quota_id;
              CLOSE C_Get_Quota_Credit_Type;

              if aso_debug_pub.g_debug_flag = 'Y' then
                  aso_debug_pub.add('Create_Quote: l_quota_id: '|| l_quota_id);
		    end if;

              x_hd_sales_credit_tbl(1) := ASO_QUOTE_PUB.G_MISS_SALES_CREDIT_REC;

              if aso_debug_pub.g_debug_flag = 'Y' then
                  aso_debug_pub.add('Create_Quote: After assigning x_hd_sales_credit_tbl.count: '|| x_hd_sales_credit_tbl.count);
              end if;

              ASO_SALES_CREDITS_PKG.Insert_Row(
                              p_CREATION_DATE            => SYSDATE,
                              p_CREATED_BY               => G_USER_ID,
                              p_LAST_UPDATED_BY          => G_USER_ID,
                              p_LAST_UPDATE_DATE         => SYSDATE,
                              p_LAST_UPDATE_LOGIN        => G_LOGIN_ID,
                              p_REQUEST_ID               => FND_API.G_MISS_NUM,
                              p_PROGRAM_APPLICATION_ID   => FND_API.G_MISS_NUM,
                              p_PROGRAM_ID               => FND_API.G_MISS_NUM,
                              p_PROGRAM_UPDATE_DATE      => FND_API.G_MISS_DATE,
                              px_SALES_CREDIT_ID         => x_hd_sales_credit_tbl(1).Sales_Credit_Id,
                              p_QUOTE_HEADER_ID          => lx_qte_header_rec.QUOTE_HEADER_ID,
                              p_QUOTE_LINE_ID            => FND_API.G_MISS_NUM,
                              p_PERCENT                  => 100,
                              p_RESOURCE_ID              => lx_qte_header_rec.RESOURCE_ID,
                              p_RESOURCE_GROUP_ID        => lx_qte_header_rec.RESOURCE_GRP_ID,
                              p_EMPLOYEE_PERSON_ID       => FND_API.G_MISS_NUM,
                              p_SALES_CREDIT_TYPE_ID     => l_quota_id,
                              p_ATTRIBUTE_CATEGORY_CODE  => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE1               => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE2               => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE3               => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE4               => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE5               => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE6               => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE7               => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE8               => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE9               => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE10              => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE11              => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE12              => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE13              => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE14              => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE15              => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE16              => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE17              => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE18              => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE19              => FND_API.G_MISS_CHAR,
                              p_ATTRIBUTE20              => FND_API.G_MISS_CHAR,
                              p_SYSTEM_ASSIGNED_FLAG     => 'N',
                              p_CREDIT_RULE_ID           => FND_API.G_MISS_NUM,
                              p_OBJECT_VERSION_NUMBER    => FND_API.G_MISS_NUM );

              if aso_debug_pub.g_debug_flag = 'Y' then
                  aso_debug_pub.add('Create_Quote: After call to Insert_Row Sales_Credit_Id: '|| x_hd_sales_credit_tbl(1).Sales_Credit_Id);
              end if;

          END IF; -- sales_cred_tbl.count

      END IF;  -- Enable API Security Prof

      -- end security changes

      --  changes for quote related objects

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Before creating object relationship ', 1, 'Y');
      END IF;

      IF P_Related_Obj_Tbl.count > 0 THEN

        For i in 1..P_Related_Obj_Tbl.count LOOP

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Inside the related object loop ', 1, 'Y');
      END IF;

          l_related_obj_rec := P_Related_Obj_Tbl(i);

          -- logic to populate the operation code
		Open c_obj_id(x_qte_header_rec.quote_header_id);
	     Fetch c_obj_id INTO l_obj_id;
		IF c_obj_id%NOTFOUND THEN
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add(' Setting the operation code for rel obj tbl ', 1, 'Y');
                  aso_debug_pub.add(' Obj id in rel obj rec is : '|| to_char(l_related_obj_rec.object_id), 1, 'Y');
			END IF;
            IF l_related_obj_rec.object_id IS NOT NULL THEN
		    l_related_obj_rec.operation_code := 'CREATE';
		  END IF;
		END IF;
          Close c_obj_id;

         IF l_related_obj_rec.operation_code = 'CREATE' THEN
          l_related_obj_rec.quote_object_id  := x_qte_header_rec.quote_header_id;
          x_related_obj_rec := l_related_obj_rec;

            ASO_RLTSHIP_PUB.Create_Object_Relationship(
              P_Api_Version_Number         => 1.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              p_validation_level           => p_validation_level,
              P_RELATED_OBJ_Rec            => l_related_obj_rec,
              X_related_object_id          => x_related_obj_rec.related_object_id,
              X_Return_Status              => X_Return_Status,
              X_Msg_Count                  => X_Msg_Count,
              X_Msg_Data                   => X_Msg_Data);

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('Create_Quote: After call to Create_Object_Relationship: x_return_status: '||x_return_status, 1, 'N');
              END IF;

              X_Related_Obj_Tbl(i) := x_related_obj_rec;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
        END IF;

	   END LOOP;


	 END IF;

	 -- end of Rel Obj  changes


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Before validate quote percent: p_validation_level: '|| p_validation_level, 1, 'Y');
      END IF;

      IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN

            IF x_hd_sales_credit_tbl.count > 0 THEN

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Setting the qte hdr id in x_hd_sales_credit_tbl to : '|| x_qte_header_rec.QUOTE_HEADER_ID, 1, 'Y');
                    END IF;

			     x_hd_sales_credit_tbl(1).quote_header_id := x_qte_header_rec.QUOTE_HEADER_ID;

                ASO_VALIDATE_PVT.Validate_Quote_Percent(
                        p_init_msg_list             => FND_API.G_FALSE,
                        p_sales_credit_tbl          => x_hd_sales_credit_tbl,
                        x_return_status             => x_return_status,
                        x_msg_count                 => x_msg_count,
                        x_msg_data                  => x_msg_data);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Create_Quote: After call to Validate_Quote_Percent: x_return_status: '|| x_return_status, 1, 'N');
                END IF;

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;

      END IF;

      l_index := X_Price_Adjustment_tbl.count + 1;

      FOR i IN 1.. l_Price_Adj_tbl.count LOOP
           x_Price_Adjustment_tbl(l_index) := l_Price_Adj_tbl(i);
           l_index := l_index + 1;
      END LOOP;

      FOR j IN 1..l_prc_index_link.count LOOP
           l_price_adjustment_tbl(l_prc_index_link(j)).price_adjustment_id := l_price_adj_tbl(j).price_adjustment_id;
      END LOOP;

      l_index := X_Price_Adj_Attr_tbl.count + 1;

      FOR i IN 1.. l_Price_Adj_Attr_tbl.count LOOP
           x_Price_Adj_Attr_tbl(l_index) := l_Price_Adj_Attr_tbl(i);
           l_index := l_index + 1;
      END LOOP;

      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
               FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER AFTER INSERT ROW', TRUE);
               FND_MSG_PUB.ADD;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('Create_Quote - l_qte_line_tbl.count: '||l_qte_line_tbl.count, 1, 'N');
	 END IF;

      FOR i IN 1 .. l_qte_line_tbl.count LOOP

          l_qte_line_dtl_tbl := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;
          l_index := 1;

          FOR j IN 1..lx_qte_line_dtl_tbl.count LOOP

               IF lx_qte_line_dtl_tbl(j).qte_line_index = i THEN

                    l_qte_line_dtl_tbl(l_index) := lx_qte_line_dtl_tbl(j);
                    l_index := l_index + 1;
               END IF;
          END LOOP;

          l_price_attr_tbl := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl;
          l_index := 1;

          FOR j IN 1..p_ln_price_attributes_tbl.count LOOP

               IF p_ln_price_attributes_tbl(j).qte_line_index = i THEN
                   l_price_attr_tbl(l_index) := p_ln_price_attributes_tbl(j);
               END IF;

          END LOOP;

          l_ln_shipment_tbl := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL;
          l_shp_index_link  := G_Miss_Link_Tbl;
          l_index := 1;

          FOR j IN 1..p_ln_shipment_tbl.count LOOP

               IF p_ln_shipment_tbl(j).qte_line_index = i THEN
                   l_ln_shipment_tbl(l_index) := p_ln_shipment_tbl(j);
                   l_shp_index_link(j) := l_index;
                   l_index := l_index+1;
               END IF;

          END LOOP;

          l_freight_charge_tbl := ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl;
          l_index := 1;

          FOR j IN 1..p_ln_freight_charge_tbl.count LOOP

               IF p_ln_freight_charge_tbl(j).shipment_index <> FND_API.G_MISS_NUM AND
                   p_ln_freight_charge_tbl(j).shipment_index IS NOT NULL AND
                   l_shp_index_link.EXISTS(p_ln_freight_charge_tbl(j).shipment_index) THEN

                    l_freight_charge_tbl(l_index) := p_ln_freight_charge_tbl(j);
                    l_freight_charge_tbl(l_index).shipment_index :=
                    l_shp_index_link(p_ln_freight_charge_tbl(j).shipment_index);
                    l_index := l_index+1;
               END IF;
          END LOOP;

	     l_line_attr_ext_tbl := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL;
	     l_index := 1;

          FOR j IN 1..p_line_attr_ext_tbl.count LOOP

               IF p_line_attr_ext_tbl(j).qte_line_index = i THEN

                   l_line_attr_ext_tbl(l_index) := p_line_attr_ext_tbl(j);
                   l_line_attr_ext_tbl(l_index).quote_header_id := x_qte_header_rec.quote_header_id;

                   IF p_line_attr_ext_tbl(j).shipment_index <> FND_API.G_MISS_NUM AND
                       p_line_attr_ext_tbl(j).shipment_index IS NOT NULL AND
                       l_shp_index_link.EXISTS(p_line_attr_ext_tbl(j).shipment_index) THEN

                        l_line_attr_ext_tbl(l_index).shipment_index := l_shp_index_link(p_line_attr_ext_tbl(j).shipment_index);
                   END IF;

                   l_index := l_index + 1;
               END IF;

          END LOOP;

	     l_payment_tbl := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;
	     l_index := 1;

          FOR j IN 1..p_ln_payment_tbl.count LOOP

               IF p_ln_payment_tbl(j).qte_line_index = i THEN

                   l_payment_tbl(l_index) := p_ln_payment_tbl(j);

                   IF p_ln_payment_tbl(j).shipment_index <> FND_API.G_MISS_NUM AND
                       p_ln_payment_tbl(j).shipment_index  IS NOT NULL AND
                       l_shp_index_link.EXISTS(p_ln_payment_tbl(j).shipment_index) THEN

                        l_payment_tbl(l_index).shipment_index := l_shp_index_link(p_ln_payment_tbl(j).shipment_index);
                   END IF;

                   l_index := l_index +1;
               END IF;

          END LOOP;

          l_price_adj_tbl      := ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl;
          l_prc_index_link     := G_Miss_Link_Tbl;
          l_prc_index_link_rev := G_Miss_Link_Tbl;
          l_index := 1;

          FOR j IN 1..p_price_adjustment_tbl.count LOOP

               IF p_price_adjustment_tbl(j).qte_line_index = i THEN

                   l_price_adj_tbl(l_index)  := p_price_adjustment_tbl(j);
                   l_prc_index_link(l_index) := j;
                   l_prc_index_link_rev(i)   := l_index;

                   IF p_price_adjustment_tbl(j).shipment_index <> FND_API.G_MISS_NUM AND
                       p_price_adjustment_tbl(j).shipment_index IS NOT NULL AND
                       l_shp_index_link.EXISTS(p_price_adjustment_tbl(j).shipment_index) THEN

                        l_price_adj_tbl(l_index).shipment_index := l_shp_index_link(p_price_adjustment_tbl(j).shipment_index);
                   END IF;
                   l_index := l_index + 1;
               END IF;
          END LOOP;

          l_price_adj_attr_tbl :=  ASO_QUOTE_PUB.G_Miss_Price_Adj_Attr_Tbl;
          l_index := 1;

          FOR j IN 1..p_price_adj_attr_tbl.count LOOP

               IF p_price_adj_attr_tbl(j).price_adj_index <> FND_API.G_MISS_NUM AND
                   l_prc_index_link_rev.exists(p_price_adj_attr_tbl(j).price_adj_index) THEN

                   l_price_adj_attr_tbl(l_index) := p_price_adj_attr_tbl(j);
                   l_price_adj_attr_tbl(l_index).price_adj_index :=
                   l_prc_index_link_rev(l_price_adj_attr_tbl(l_index).price_adj_index);
                   l_index := l_index + 1;
               END IF;

          END LOOP;

          l_tax_detail_tbl := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl;
          l_index := 1;

          FOR j IN 1..p_ln_tax_detail_tbl.count LOOP

               IF p_ln_tax_detail_tbl(j).qte_line_index = i THEN

                   l_tax_detail_tbl(l_index) := p_ln_tax_detail_tbl(j);

                   IF p_ln_tax_detail_tbl(j).shipment_index <> FND_API.G_MISS_NUM
                       AND l_shp_index_link.EXISTS(p_ln_tax_detail_tbl(j).shipment_index)
                       AND p_ln_tax_detail_tbl(l_index).shipment_index IS NOT NULL THEN

                          l_tax_detail_tbl(l_index).shipment_index := l_shp_index_link(p_ln_tax_detail_tbl(j).shipment_index);
                   END IF;
                   l_index := l_index+1;
               END IF;

          END LOOP;

          l_sales_credit_tbl := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl;

          l_index := 1;
          FOR j IN 1..p_ln_sales_credit_tbl.count LOOP

               IF p_ln_sales_credit_tbl(j).qte_line_index = i THEN

                   l_sales_credit_tbl(l_index) := p_ln_sales_credit_tbl(j);
                   l_index := l_index +1;
               END IF;

          END LOOP;

          l_quote_party_tbl := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl;
	     l_index := 1;

          FOR j IN 1..p_ln_quote_party_tbl.count LOOP

              IF p_ln_quote_party_tbl(j).qte_line_index = i THEN

                   l_quote_party_tbl(l_index) := p_ln_quote_party_tbl(j);

                   IF p_ln_quote_party_tbl(j).shipment_index <> FND_API.G_MISS_NUM AND
                       p_ln_quote_party_tbl(j).shipment_index  IS NOT NULL AND
                       l_shp_index_link.EXISTS(p_ln_quote_party_tbl(j).shipment_index) THEN

                         l_quote_party_tbl(l_index).shipment_index := l_shp_index_link(p_ln_quote_party_tbl(j).shipment_index);
                   END IF;

                   l_index := l_index +1;

              END IF;
          END LOOP;

	     l_qte_line_rec := l_qte_line_tbl(i);
	     l_qte_line_rec.quote_header_id := x_qte_header_rec.quote_header_id;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote - before Validate_Commitment ', 1, 'N');
          END IF;

          ASO_VALIDATE_PVT.Validate_Commitment(
                      P_Init_Msg_List          => FND_API.G_FALSE,
                      P_Qte_Header_Rec         => x_qte_header_rec,
                      P_Qte_Line_Rec           => l_qte_line_rec,
                      X_Return_Status          => l_return_status,
                      X_Msg_Count              => x_msg_count,
                      X_Msg_Data               => x_msg_data);

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote - after Validate_Commitment: l_return_status: '||l_return_status, 1, 'N');
          END IF;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          open  c_last_update_date(x_qte_header_rec.quote_header_id);
          fetch c_last_update_date into l_control_rec.last_update_date;
          close c_last_update_date;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('l_control_rec.last_update_date: '|| l_control_rec.last_update_date);
              aso_debug_pub.add('Create_Quote: Before call to create_quote_lines', 1, 'Y');
          END IF;

          ASO_QUOTE_LINES_PVT.Create_Quote_Lines (
                          P_Api_Version_Number   => 1.0,
                          p_validation_level     => p_validation_level,
                          p_control_rec          => l_control_rec,
                          p_update_header_flag   => FND_API.G_FALSE,
                          p_qte_header_rec       => p_qte_header_rec,
                          P_qte_Line_Rec	    => l_qte_line_rec,
                          P_qte_line_dtl_tbl     => l_qte_line_dtl_tbl,
                          P_Line_Attribs_Ext_Tbl => l_line_attr_Ext_Tbl,
                          P_price_attributes_tbl => l_price_attr_tbl,
                          P_Price_Adj_Tbl        => l_price_adj_tbl,
                          P_Price_Adj_Attr_Tbl   => l_Price_Adj_Attr_Tbl,
                          P_Payment_Tbl          => l_payment_tbl,
                          P_Shipment_Tbl         => l_ln_shipment_tbl,
                          P_Freight_Charge_Tbl   => l_freight_charge_tbl,
                          P_Tax_Detail_Tbl       => l_tax_detail_tbl,
                          P_quote_party_tbl      => l_quote_party_tbl ,
                          P_sales_Credit_tbl     => l_sales_Credit_tbl ,
                          x_qte_Line_Rec	    => l_qte_line_rec_out,
                          x_qte_line_dtl_tbl     => l_qte_line_dtl_tbl_out,
                          x_Line_Attribs_Ext_Tbl => l_line_attr_Ext_Tbl_out,
                          x_price_attributes_tbl => l_price_attr_tbl_out,
                          x_Price_Adj_Tbl        => l_price_adj_tbl_out,
                          x_Price_Adj_Attr_Tbl   => l_Price_Adj_Attr_Tbl_out,
                          x_Payment_Tbl          => l_payment_tbl_out,
                          x_Shipment_Tbl	    => l_ln_shipment_tbl_out,
                          x_Freight_Charge_Tbl   => l_freight_charge_tbl_out,
                          x_Tax_Detail_Tbl       => l_tax_detail_tbl_out,
                          X_quote_party_tbl      => l_quote_party_tbl_out ,
                          X_sales_Credit_tbl     => l_sales_Credit_tbl_out ,
                          X_Return_Status        => l_return_status,
                          X_Msg_Count            => x_msg_count,
                          X_Msg_Data             => x_msg_data );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote: After call to create_quote_lines: l_return_status: '|| l_return_status, 1, 'Y');
          END IF;

          l_qte_line_rec        :=  l_qte_line_rec_out;
	     l_qte_line_dtl_tbl    :=  l_qte_line_dtl_tbl_out;
	     l_line_attr_Ext_Tbl   :=  l_line_attr_Ext_Tbl_out;
	     l_price_attr_tbl      :=  l_price_attr_tbl_out;
	     l_price_adj_tbl       :=  l_price_adj_tbl_out;
	     l_Price_Adj_Attr_Tbl  :=  l_Price_Adj_Attr_Tbl_out;
	     l_payment_tbl         :=  l_payment_tbl_out;
	     l_ln_shipment_tbl     :=  l_ln_shipment_tbl_out;
	     l_freight_charge_tbl  :=  l_freight_charge_tbl_out;
	     l_tax_detail_tbl      :=  l_tax_detail_tbl_out;
	     l_quote_party_tbl     :=  l_quote_party_tbl_out;
	     l_sales_Credit_tbl    :=  l_sales_Credit_tbl_out;

          IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
                   FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER AFTER CREATE LINES', FALSE);
                   FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN

	          x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
          END IF;

          open  c_last_update_date(x_qte_header_rec.quote_header_id);
          fetch c_last_update_date into x_qte_header_rec.last_update_date;
          close c_last_update_date;

          l_control_rec.last_update_date  :=  x_qte_header_rec.last_update_date;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote: After call to Create_Quote_Lines');
              aso_debug_pub.add('x_qte_header_rec.last_update_date: '|| x_qte_header_rec.last_update_date);
              aso_debug_pub.add('l_control_rec.last_update_date:    '|| l_control_rec.last_update_date);
          END IF;

          For j IN 1..lx_qte_line_dtl_tbl.count LOOP
             IF lx_qte_line_dtl_tbl(j).SERVICE_REF_QTE_LINE_INDEX = i THEN
                lx_qte_line_dtl_tbl(j).SERVICE_REF_LINE_ID := l_qte_line_rec.quote_line_id;
             END IF;
          END LOOP;

          FOR j IN 1..lx_qte_line_dtl_tbl.count LOOP
             IF lx_qte_line_dtl_tbl(j).REF_LINE_INDEX = i THEN
                 lx_qte_line_dtl_tbl(j).REF_LINE_ID := l_qte_line_rec.quote_line_id;
             END IF;
          END LOOP;

	   --  P1 bug 10261431
	  FOR j IN 1..lx_qte_line_dtl_tbl.count LOOP
              IF lx_qte_line_dtl_tbl(j).TOP_MODEL_LINE_INDEX = i THEN
                  lx_qte_line_dtl_tbl(j).TOP_MODEL_LINE_ID := l_qte_line_rec.quote_line_id;
		  l_top_model_line_id:= l_qte_line_rec.quote_line_id;
		  -- Start : Code change done for Bug 19796851
		  l_line_dtl_tbl_exist:= TRUE;
		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                      aso_debug_pub.add('Create_Quote: inside lx_qte_line_dtl_tble l_top_model_line_id : '||l_top_model_line_id);
                  end if;
		  -- End : Code change done for Bug 19796851
              END IF;
          END LOOP;

          FOR j IN 1..lx_qte_line_dtl_tbl.count LOOP
             IF lx_qte_line_dtl_tbl(j).ATO_LINE_INDEX = i THEN
                 lx_qte_line_dtl_tbl(j).ATO_LINE_ID := l_qte_line_rec.quote_line_id;
		 l_ato_line_id:= l_qte_line_rec.quote_line_id; --  P1 bug 10261431
             END IF;
          END LOOP;

          --  P1 bug 10261431
	   if (l_qte_line_rec.item_type_code='MDL')  -- and (i=1) then
	       and (i>=1) then  -- code change done for Bug 19002028
		 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                      aso_debug_pub.add('Create_Quote: After call to Create_Quote_Lines updating the data for MDL line');
                 end if;
		     update aso_quote_line_details
		     set top_model_line_id=l_top_model_line_id,ato_line_id=l_ato_line_id
		     where quote_line_id=l_qte_line_rec.quote_line_id;
          end if;

	  -- Start : Code change done for Bug 19796851
	   If Not l_line_dtl_tbl_exist Then

	     If l_qte_line_rec.item_type_code = 'MDL' Then
	        l_top_model_line_id := l_qte_line_rec.quote_line_id;
             End If;

	     If aso_debug_pub.g_debug_flag = 'Y' Then
		aso_debug_pub.add('Create_Quote: l_line_dtl_tbl_exist false l_top_model_line_id : '||l_top_model_line_id);
             End If;

	     update aso_quote_line_details
	     set top_model_line_id=l_top_model_line_id,ato_line_id=l_ato_line_id
	     where quote_line_id=l_qte_line_rec.quote_line_id;
	  End If;
	  -- End : Code change done for Bug 19796851

          X_Qte_Line_Tbl(x_qte_line_tbl.count+1) := l_qte_line_rec;
          l_index := X_Qte_Line_Dtl_Tbl.count+1;

          FOR j IN 1.. l_qte_line_dtl_tbl.count LOOP
               x_qte_line_dtl_tbl(l_index) := l_qte_line_dtl_tbl(j);
               l_index := l_index+1;
          END LOOP;

          l_index := X_Line_Attr_Ext_Tbl.count+1;

          FOR j IN 1.. l_Line_Attr_Ext_tbl.count LOOP
               x_Line_Attr_Ext_tbl(l_index) := l_Line_Attr_Ext_tbl(j);
               l_index := l_index+1;
          END LOOP;

          l_index := X_LN_Price_Attributes_Tbl.count+1;

          FOR j IN 1.. l_Price_Attr_tbl.count LOOP
               x_ln_Price_Attributes_tbl(l_index) := l_Price_Attr_tbl(j);
               l_index := l_index+1;
          END LOOP;

          l_index := X_Price_Adjustment_tbl.count+1;

          FOR j IN 1.. l_Price_Adj_tbl.count LOOP
               x_Price_Adjustment_tbl(l_index) := l_Price_Adj_tbl(j);
               l_index := l_index+1;
          END LOOP;

          l_index := X_LN_payment_Tbl.count+1;

          FOR j IN 1.. l_payment_tbl.count LOOP
               x_ln_payment_tbl(l_index) := l_payment_tbl(j);
               l_index := l_index+1;
          END LOOP;

          l_index := X_LN_shipment_Tbl.count+1;

          FOR j IN 1.. l_ln_shipment_tbl.count LOOP
               x_ln_shipment_tbl(l_index) := l_ln_shipment_tbl(j);
               l_index := l_index+1;
          END LOOP;

          l_index := X_LN_freight_charge_Tbl.count+1;
          FOR j IN 1.. l_freight_charge_tbl.count LOOP
               x_ln_freight_charge_tbl(l_index) := l_freight_charge_tbl(j);
               l_index := l_index+1;
          END LOOP;

          l_index := X_LN_tax_detail_Tbl.count+1;
          FOR j IN 1.. l_tax_detail_tbl.count LOOP
               x_ln_tax_detail_tbl(l_index) := l_tax_detail_tbl(j);
               l_index := l_index+1;
          END LOOP;

          l_index := X_ln_sales_Credit_Tbl.count+1;

		FOR j IN 1.. l_sales_Credit_tbl.count LOOP
               x_ln_sales_Credit_tbl(l_index) := l_sales_Credit_tbl(j);
               l_index := l_index+1;
          END LOOP;

          l_index := X_ln_quote_party_Tbl.count+1;

          FOR j IN 1.. l_quote_party_tbl.count LOOP
               x_ln_quote_party_tbl(l_index) := l_quote_party_tbl(j);
               l_index := l_index+1;
          END LOOP;

	     FOR j IN 1..l_prc_index_link.count LOOP
	          l_price_adjustment_tbl(l_prc_index_link(j)).price_adjustment_id := l_price_adj_tbl(j).price_adjustment_id;
	     END LOOP;

          IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
                   FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER', TRUE);
                   FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      END LOOP;

      -- create price adj relationships.
      FOR i IN 1..p_price_adj_rltship_tbl.count LOOP

           l_price_adj_rltship_rec := p_price_adj_rltship_tbl(i);
           l_index := p_price_adj_rltship_tbl(i).qte_line_index;
           l_price_adj_rltship_rec.quote_line_id := x_qte_line_tbl(l_index).quote_line_id;
           l_index := p_price_adj_rltship_tbl(i).price_adj_index;
           l_price_adj_rltship_rec.price_adjustment_id := l_price_adjustment_tbl(l_index).price_adjustment_id;
           l_index := p_price_adj_rltship_tbl(i).rltd_price_adj_index;
           l_price_adj_rltship_rec.rltd_price_adj_id := l_price_adjustment_tbl(l_index).price_adjustment_id;

           ASO_PRICE_RLTSHIPS_PKG.Insert_Row(
                        px_ADJ_RELATIONSHIP_ID   => l_price_adj_rltship_rec.ADJ_RELATIONSHIP_ID,
                        p_creation_date          => sysdate,
                        p_CREATED_BY             => G_USER_ID,
                        p_LAST_UPDATE_DATE       => sysdate,
                        p_LAST_UPDATED_BY        => G_USER_ID,
                        p_LAST_UPDATE_LOGIN      => G_USER_ID,
                        p_PROGRAM_APPLICATION_ID => l_price_adj_rltship_rec.PROGRAM_APPLICATION_ID,
                        p_PROGRAM_ID             => l_price_adj_rltship_rec.PROGRAM_ID,
                        p_PROGRAM_UPDATE_DATE    => l_price_adj_rltship_rec.PROGRAM_UPDATE_DATE,
                        p_REQUEST_ID             => l_price_adj_rltship_rec.REQUEST_ID,
                        p_QUOTE_LINE_ID          => l_price_adj_rltship_rec.quote_line_id,
                        p_PRICE_ADJUSTMENT_ID    => l_price_adj_rltship_rec.price_adjustment_id,
                        p_RLTD_PRICE_ADJ_ID      => l_price_adj_rltship_rec.rltd_price_adj_id,
                        p_QUOTE_SHIPMENT_ID      => l_price_adj_rltship_rec.quote_shipment_id,
                        p_OBJECT_VERSION_NUMBER  => l_price_adj_rltship_rec.OBJECT_VERSION_NUMBER );

           X_Price_Adj_Rltship_Tbl(i) := l_price_adj_rltship_rec;

      END LOOP;
 --bug8235510 starts here
for i in 1 ..x_qte_line_dtl_tbl.count
loop
aso_debug_pub.add('x_qte_line_dtl_tbl.quot_line_id' || x_qte_line_dtl_tbl(i).quote_line_id);
aso_debug_pub.add('x_qte_line_dtl_tbl.quot_line_detail_id' || x_qte_line_dtl_tbl(i).quote_line_detail_id);
aso_debug_pub.add('x_qte_line_dtl_tbl.ref_line_id' || x_qte_line_dtl_tbl(i).ref_line_id);
end loop;
--vidya
FOR i in 1..x_qte_line_tbl.count LOOP
l_line_rltship_rec := ASO_QUOTE_PUB.G_Miss_Line_Rltship_Rec;
x_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(x_qte_line_tbl(i).quote_line_id);
IF x_qte_line_dtl_tbl.count > 0 THEN
IF x_qte_line_dtl_tbl(1).ref_line_id IS NOT NULL AND x_qte_line_dtl_tbl(1).ref_line_id <> FND_API.G_MISS_NUM THEN
                		l_line_rltship_rec.OPERATION_CODE         := 'CREATE';
                		l_line_rltship_rec.QUOTE_LINE_ID          := x_qte_line_dtl_tbl(1).ref_line_id;
                		l_line_rltship_rec.RELATED_QUOTE_LINE_ID  := x_qte_line_dtl_tbl(1).quote_line_id;
                		l_line_rltship_rec.RELATIONSHIP_TYPE_CODE := 'CONFIG';

ASO_LINE_RLTSHIP_PVT.Create_Line_Rltship(
                    P_Api_Version_Number   => 1.0,
                    P_Init_Msg_List        => FND_API.G_FALSE,
                    P_Commit               => FND_API.G_FALSE,
                    P_Validation_Level     => p_validation_level,
                    P_Line_Rltship_Rec     => l_line_rltship_rec,
                    X_LINE_RELATIONSHIP_ID => lx_line_relationship_id,
                    X_Return_Status        => x_return_status,
                    X_Msg_Count            => x_msg_count,
                    X_Msg_Data             => x_msg_data
                );
end if;
end if;
end loop;
--ends bug8235510 starts here
      -- create line relationships
      FOR i IN 1..p_line_rltship_tbl.count LOOP

	      l_line_rltship_rec := p_line_rltship_tbl(i);
	      l_index := l_line_rltship_rec.qte_line_index;

	      IF l_index IS NOT NULL AND l_index >=1 AND l_index <= x_qte_line_tbl.count THEN
	          l_line_rltship_rec.quote_line_id := x_qte_line_tbl(l_index).quote_line_id;
	      END IF;

           l_index := l_line_rltship_rec.related_qte_line_index;

           IF l_index IS NOT NULL AND l_index >=1 AND l_index <= x_qte_line_tbl.count THEN
               l_line_rltship_rec.related_quote_line_id := x_qte_line_tbl(l_index).quote_line_id;
           END IF;

           ASO_LINE_RELATIONSHIPS_PKG.Insert_Row(
                        px_LINE_RELATIONSHIP_ID   => l_line_rltship_rec.LINE_RELATIONSHIP_ID,
                        p_CREATION_DATE           => SYSDATE,
                        p_CREATED_BY              => G_USER_ID,
                        p_LAST_UPDATED_BY         => G_USER_ID,
                        p_LAST_UPDATE_DATE        => SYSDATE,
                        p_LAST_UPDATE_LOGIN       => G_LOGIN_ID,
                        p_REQUEST_ID              => l_line_rltship_rec.REQUEST_ID,
                        p_PROGRAM_APPLICATION_ID  => l_line_rltship_rec.PROGRAM_APPLICATION_ID,
                        p_PROGRAM_ID              => l_line_rltship_rec.PROGRAM_ID,
                        p_PROGRAM_UPDATE_DATE     => l_line_rltship_rec.PROGRAM_UPDATE_DATE,
                        p_QUOTE_LINE_ID           => l_line_rltship_rec.quote_line_id,
                        p_RELATED_QUOTE_LINE_ID   => l_line_rltship_rec.RELATED_QUOTE_LINE_ID,
                        p_RECIPROCAL_FLAG         => l_line_rltship_rec.RECIPROCAL_FLAG,
                        P_RELATIONSHIP_TYPE_CODE  => l_line_rltship_rec.RELATIONSHIP_TYPE_CODE,
                        p_OBJECT_VERSION_NUMBER   => l_price_adj_rltship_rec.OBJECT_VERSION_NUMBER);

	      X_line_Rltship_Tbl(i) := l_line_rltship_rec;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
	          aso_debug_pub.add('Create_Quote: l_line_rltship_rec.quote_line_id:         '||l_line_rltship_rec.quote_line_id);
               aso_debug_pub.add('Create_Quote: l_line_rltship_rec.related_quote_line_id: '||l_line_rltship_rec.related_quote_line_id);
           END IF;

           if l_line_rltship_rec.relationship_type_code = 'CONFIG' then

               update aso_quote_line_details
               set ref_type_code          =  'CONFIG',
                   ref_line_id            =  l_line_rltship_rec.quote_line_id,
                   last_update_date       =  sysdate,
                   last_updated_by        =  fnd_global.user_id,
                   last_update_login      =  fnd_global.conc_login_id
               where quote_line_id = l_line_rltship_rec.related_quote_line_id;

           end if;

      END LOOP;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote: x_qte_header_rec.quote_header_id: '|| x_qte_header_rec.quote_header_id);
      END IF;

      update aso_quote_line_details
      set ref_type_code     = 'CONFIG',
          last_update_date  = sysdate,
          last_updated_by   = fnd_global.user_id,
          last_update_login = fnd_global.conc_login_id
      where config_header_id is not null
      and config_revision_num is not null
      and ref_type_code is null
      and quote_line_id in (select quote_line_id from aso_quote_lines_all
                            where item_type_code = 'MDL'
                            and quote_header_id  = x_qte_header_rec.quote_header_id);


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('Create_Quote - before header pricing ', 1, 'Y');
	 END IF;

      IF l_control_rec.header_pricing_event IS NOT NULL AND l_control_rec.header_pricing_event <> FND_API.G_MISS_CHAR THEN

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
	         aso_debug_pub.add('Create_Quote - inside header pricing ', 1, 'N');
	     END IF;

	     l_pricing_control_rec.request_type  := p_control_rec.pricing_request_type;
	     l_pricing_control_rec.pricing_event := p_control_rec.header_pricing_event;
	     l_pricing_control_rec.price_mode    := p_control_rec.price_mode;

          --New Code for to call overload pricing_order

          lv_qte_header_rec    := aso_utility_pvt.query_header_row(x_qte_header_rec.quote_header_id);
          lv_hd_price_attr_tbl := aso_utility_pvt.query_price_attr_rows(x_qte_header_rec.quote_header_id,null);
          lv_hd_shipment_tbl   := aso_utility_pvt.query_shipment_rows(x_qte_header_rec.quote_header_id,null);

          if lv_hd_shipment_tbl.count = 1 then
              lv_hd_shipment_rec := lv_hd_shipment_tbl(1);
          end if;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote: Before call to ASO_PRICING_INT.Pricing_Order');
              aso_debug_pub.add('Create_Quote: x_qte_line_tbl.count: ' || x_qte_line_tbl.count);
          END IF;

          ASO_PRICING_INT.Pricing_Order(
                    P_Api_Version_Number     => 1.0,
                    P_Init_Msg_List          => fnd_api.g_false,
                    P_Commit                 => fnd_api.g_false,
                    p_control_rec            => l_pricing_control_rec,
                    p_qte_header_rec         => lv_qte_header_rec,
                    p_hd_shipment_rec        => lv_hd_shipment_rec,
                    p_hd_price_attr_tbl      => lv_hd_price_attr_tbl,
                    p_qte_line_tbl           => x_qte_line_tbl,
                    --p_line_rltship_tbl     => l_line_rltship_tbl,
                    --p_qte_line_dtl_tbl     => l_qte_line_dtl_tbl,
                    --p_ln_shipment_tbl      => ln_shipment_tbl,
                    --p_ln_price_attr_tbl    => l_ln_price_attr_tbl,
                    x_qte_header_rec         => lx_qte_header_rec,
                    x_qte_line_tbl           => lx_qte_line_tbl,
                    x_qte_line_dtl_tbl       => lx_qte_line_dtl_tbl,
                    x_price_adj_tbl          => l_price_adj_tbl_out,
                    x_price_adj_attr_tbl     => l_Price_Adj_Attr_Tbl_out,
                    x_price_adj_rltship_tbl  => lx_price_adj_rltship_tbl,
                    x_return_status          => l_return_status,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data );


          x_qte_line_tbl := lx_qte_line_tbl;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote: After call to ASO_PRICING_INT.Pricing_Order');
              aso_debug_pub.add('Create_Quote: l_return_status:       ' || l_return_status);
              aso_debug_pub.add('Create_Quote: lx_qte_line_tbl.count: ' || lx_qte_line_tbl.count);
              aso_debug_pub.add('Create_Quote: x_qte_line_tbl.count:  ' || x_qte_line_tbl.count);
          END IF;

	     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

	          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		         FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
		         FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER AFTER PRICING', TRUE);
		         FND_MSG_PUB.ADD;
	          END IF;

	          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	     ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN

	          x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE   FND_API.G_EXC_ERROR;
	     END IF;

      END IF;  --IF l_control_rec.header_pricing_event IS NOT NULL AND l_control_rec.header_pricing_event <> FND_API.G_MISS_CHAR THEN

      /*New Pricing Changes to update the date*/

	 IF p_control_rec.header_pricing_event ='BATCH' AND p_control_rec.price_mode='ENTIRE_QUOTE' THEN

	 	l_price_updated_date_flag := fnd_api.g_true;
	 END IF;

      /*IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote: Before call to ASO_TAX_INT.Calculate_Tax', 1, 'Y');
          aso_debug_pub.add('Create_Quote: p_control_rec.calculate_tax_flag: ' || p_control_rec.calculate_tax_flag);
      END IF;*/

       --Changed the call to tax API as a part of etax By Anoop Rajan on 9 August 2005

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote: Before call to ASO_TAX_INT.CALCULATE_TAX_WITH_GTT', 1, 'Y');
          aso_debug_pub.add('Create_Quote: p_control_rec.calculate_tax_flag: ' || p_control_rec.calculate_tax_flag);
      END IF;

      IF p_control_rec.calculate_tax_flag = 'Y' THEN

         /* l_tax_control_rec.tax_level := 'SHIPPING';
          l_tax_control_rec.update_DB := 'Y';*/
	  --Commented the above 2 lines by Anoop on 15th August
	  --Added the IF Condition below to facilitate TAX changes .
	  if lx_qte_line_tbl.count > 0 then
		ASO_TAX_INT.CALCULATE_TAX_WITH_GTT(p_API_VERSION_NUMBER => 1.0,
					     p_qte_header_id => x_qte_header_rec.quote_header_id,
					     x_return_status => x_return_status,
					     X_Msg_Count =>  x_msg_count,
					     X_Msg_Data =>  x_msg_data      );

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('Create_Quote: After call to ASO_TAX_INT.CALCULATE_TAX_WITH_GTT: x_return_status: '|| x_return_status, 1, 'Y');
		END IF;
	  ELSE
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('Create_Quote: NO LINE RECORDS.SO TAX NOT CALCULATED : x_return_status: '|| x_return_status, 1, 'Y');
		END IF;
	  END IF;

          /*ASO_TAX_INT.Calculate_Tax( P_Api_Version_Number => 1.0,
                                     p_quote_header_id    => x_qte_header_rec.quote_header_id,
                                     P_Tax_Control_Rec    => l_tax_control_rec,
                                     x_tax_amount	        => x_tax_amount    ,
                                     x_tax_detail_tbl     => l_tax_detail_tbl,
                                     X_Return_Status      => x_return_status ,
                                     X_Msg_Count          => x_msg_count     ,
                                     X_Msg_Data           => x_msg_data      );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote: After call to ASO_TAX_INT.Calculate_Tax: x_return_status: '|| x_return_status, 1, 'Y');
          END IF;
	    */
          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
	             FND_MESSAGE.Set_Token('API', 'Calculate_tax_with_GTT', FALSE);
	             FND_MSG_PUB.ADD;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;

      END IF;

      /*New Tax Changes to update the date*/

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN

		aso_debug_pub.add('Create_Quote: control record parameter values');
	     aso_debug_pub.add('l_qte_header_rec.pricing_status_indicator: ' || l_qte_header_rec.pricing_status_indicator);
	     aso_debug_pub.add('l_qte_header_rec.tax_status_indicator:     ' || l_qte_header_rec.tax_status_indicator);
	     aso_debug_pub.add('p_control_rec.header_pricing_event:        ' || p_control_rec.header_pricing_event);
	     aso_debug_pub.add('p_control_rec.price_mode:                  ' || p_control_rec.price_mode);
	     aso_debug_pub.add('p_control_rec.calculate_tax_flag:          ' || p_control_rec.calculate_tax_flag);
	     aso_debug_pub.add('l_price_updated_date_flag:                 ' || l_price_updated_date_flag);

	 END IF;

      IF p_control_rec.calculate_tax_flag = 'Y' THEN

          IF l_price_updated_date_flag = fnd_api.g_true THEN

              update aso_quote_headers_all
              set tax_updated_date   = sysdate,
                  price_updated_date = sysdate
              where quote_header_id = x_qte_header_rec.quote_header_id;

          ELSE

              update aso_quote_headers_all
              set tax_updated_date   = sysdate
              where quote_header_id = x_qte_header_rec.quote_header_id;

          END IF;

      ELSIF l_price_updated_date_flag = fnd_api.g_true THEN

          update aso_quote_headers_all
          set price_updated_date = sysdate
          where quote_header_id = x_qte_header_rec.quote_header_id;

      END IF;


      -- Update Quote total info (do summation to get TOTAL_LIST_PRICE,
      -- TOTAL_ADJUSTED_AMOUNT, TOTAL_TAX, TOTAL_SHIPPING_CHARGE, SURCHARGE,
      -- TOTAL_QUOTE_PRICE, PAYMENT_AMOUNT)
      -- IF calculate_tax_flag = 'N', not summation on line level tax,
      -- just take the value of p_qte_header_rec.total_tax as the total_tax
      -- IF calculate_Freight_Charge = 'N', not summation on line level freight charge,
      -- just take the value of p_qte_header_rec.total_freight_charge
      -- (or l_hd_shipment_tbl(1).total_freight_charge???) as the TOTAL_SHIPPING_CHARGE


      IF p_control_rec.calculate_tax_flag = 'N' AND
          p_qte_header_rec.total_tax IS NOT NULL THEN
          l_calculate_tax := 'N';
      END IF;

      IF p_control_rec.calculate_freight_charge_flag = 'N' AND
          p_qte_header_rec.total_shipping_charge IS NOT NULL THEN
          l_calculate_freight_charge := 'N';
      END IF;


      -- Start of PNPL Changes
      x_qte_header_rec := aso_utility_pvt.query_header_row(x_qte_header_rec.quote_header_id);

      l_installment_option := oe_sys_parameters.value(param_name => 'INSTALLMENT_OPTIONS',
			  		                                            p_org_id =>x_qte_header_rec.org_id);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote - Value of Installment Option Param: '||l_installment_option, 1, 'Y');
      END IF;

       IF  ( (l_installment_option = 'ENABLE_PAY_NOW') and (nvl(P_Qte_Header_Rec.quote_type,'X') <> 'T' )
            and ((p_control_rec.header_pricing_event <> FND_API.G_MISS_CHAR and p_control_rec.header_pricing_event is not null)
              or (p_control_rec.calculate_tax_flag = 'Y'))   ) then

           l_call_ar_api :=  fnd_api.g_true;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Create_Quote - p_control_rec.header_pricing_event: '||p_control_rec.header_pricing_event, 1, 'Y');
             aso_debug_pub.add('Create_Quote - p_control_rec.price_mode          : '||p_control_rec.price_mode, 1, 'Y');
             aso_debug_pub.add('Create_Quote - l_qte_line_tbl.count              : '||l_qte_line_tbl.count, 1, 'Y');
           END IF;

         -- check if price_mode is change_line, if so then call ar api only if some lines are being created or updated
         IF (p_control_rec.header_pricing_event = 'BATCH' and p_control_rec.price_mode = 'CHANGE_LINE') THEN
               if (l_qte_line_tbl.count > 0) then
                  l_call_ar_api :=  fnd_api.g_false;
                  for i in 1..l_qte_line_tbl.count loop
                   if (l_qte_line_tbl(i).operation_code = 'CREATE' or l_qte_line_tbl(i).operation_code = 'UPDATE')  then
                    l_call_ar_api :=  fnd_api.g_true;
                    exit;
                   end if;
                  end loop;
               else
                l_call_ar_api :=  fnd_api.g_false;
               end if;
         END IF;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote - l_call_ar_api:  '|| l_call_ar_api, 1, 'Y');
           END IF;

     IF (l_call_ar_api = fnd_api.g_true ) then

       For i in 1..X_Qte_Line_Tbl.count loop

          -- resetting the line term id variable
          l_line_term_id := null;
          l_line_quote_price := null;
          l_quantity := null;

       -- get the line freight charges
	     l_line_shipping_charge := aso_shipping_int.get_line_freight_charges( x_qte_header_rec.quote_header_id,
					                                                      X_Qte_Line_Tbl(i).quote_line_id );

       -- get the line tax
          open c_tax_line(x_qte_header_rec.quote_header_id,X_Qte_Line_Tbl(i).quote_line_id);
          fetch c_tax_line into l_line_tax;
          close c_tax_line;

       -- get the payment term id for the line
          open get_line_payment_term(x_qte_header_rec.quote_header_id,X_Qte_Line_Tbl(i).quote_line_id);
          fetch get_line_payment_term into l_line_term_id;
          close get_line_payment_term;

           -- if line term id is null then get it from header
		 If l_line_term_id is null THEN
               open get_hdr_payment_term(x_qte_header_rec.quote_header_id);
               fetch get_hdr_payment_term into l_line_term_id;
               close get_hdr_payment_term;
		 END IF;

           -- bug 4923355
		 open get_line_qte_price(X_Qte_Line_Tbl(i).quote_line_id);
		 fetch get_line_qte_price into l_line_quote_price,l_quantity;
		 close get_line_qte_price;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote - l_line_quote_price:  '|| l_line_quote_price, 1, 'Y');
              aso_debug_pub.add('Create_Quote - l_quantity:          '|| l_quantity, 1, 'Y');
           END IF;

           l_line_amount := l_line_quote_price * l_quantity;

           -- l_line_amount := X_Qte_Line_Tbl(i).line_quote_price * X_Qte_Line_Tbl(i).quantity;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote - ********* Input to AR_VIEW_TERM_GRP.pay_now_amounts follows *********** ', 1, 'Y');
          aso_debug_pub.add('Create_Quote - X_Qte_Line_Tbl('||i||').quote_line_id: '||X_Qte_Line_Tbl(i).quote_line_id, 1, 'Y');
          aso_debug_pub.add('Create_Quote - l_line_amount:              '||l_line_amount, 1, 'Y');
          aso_debug_pub.add('Create_Quote - l_line_shipping_charge:     '||l_line_shipping_charge, 1, 'Y');
          aso_debug_pub.add('Create_Quote - l_line_tax:                 '||l_line_tax, 1, 'Y');
          aso_debug_pub.add('Create_Quote - l_line_term_id:             '||l_line_term_id, 1, 'Y');
	 END IF;

      IF (l_line_term_id is not null and l_line_term_id <> fnd_api.g_miss_num) then

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote: before call to AR_VIEW_TERM_GRP.pay_now_amounts', 1, 'Y');
      END IF;

       -- Call the AR API to get the amounts
             AR_VIEW_TERM_GRP.pay_now_amounts(
               	p_api_version      	       => 1.0,
             	     p_init_msg_list    	       => p_init_msg_list,
              	     p_validation_level 	       => FND_API.G_VALID_LEVEL_FULL,
		          p_term_id 		       => l_line_term_id,
		          p_currency_code 	       => x_qte_header_rec.currency_code,
		          p_line_amount		       => l_line_amount,
		          p_tax_amount		       => l_line_tax,
                    p_freight_amount	       => l_line_shipping_charge,
		          x_pay_now_line_amount      => l_paynow_amount,
		          x_pay_now_tax_amount       => l_paynow_tax,
		          x_pay_now_freight_amount   => l_paynow_charges,
		          x_pay_now_total_amount	  => l_paynow_total,
                    X_Return_Status            => x_return_status ,
                    X_Msg_Count                => x_msg_count     ,
                    X_Msg_Data                 => x_msg_data      );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote: After call to AR_VIEW_TERM_GRP.pay_now_amounts: x_return_status: '|| x_return_status, 1, 'Y');
          END IF;

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                  FND_MESSAGE.Set_Token('API', 'AR_PayNow_Amounts', FALSE);
                  FND_MSG_PUB.ADD;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote - Output from AR_VIEW_TERM_GRP.pay_now_amounts follows:', 1, 'Y');
          aso_debug_pub.add('Create_Quote - l_paynow_amount:        '||l_paynow_amount, 1, 'Y');
		aso_debug_pub.add('Create_Quote - l_paynow_charges:       '||l_paynow_charges, 1, 'Y');
          aso_debug_pub.add('Create_Quote - l_paynow_tax:           '||l_paynow_tax, 1, 'Y');
	     aso_debug_pub.add('Create_Quote - l_paynow_total:         '||l_paynow_total, 1, 'Y');
	     aso_debug_pub.add('Create_Quote - ********** End PNPL Processing ************'  , 1, 'Y');
      END IF;


          -- Update the corresponding columns in the line table
          update aso_quote_lines_all
          set line_paynow_charges    = l_paynow_charges,
              line_paynow_tax        = l_paynow_tax,
              line_paynow_subtotal   = l_paynow_amount,
              last_update_date       =  sysdate,
              last_updated_by        =  fnd_global.user_id,
              last_update_login      =  fnd_global.conc_login_id
          where quote_line_id = X_Qte_Line_Tbl(i).quote_line_id;

        end if; -- end if for term id null check
	  end loop;
   END IF; -- end if for call ar api flag
  END IF;

	 -- End of PNPL Changes

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote - before update_quote_total ', 1, 'Y');
      END IF;

      -- cost_er rassharm

    For i in 1..X_Qte_Line_Tbl.count loop
      BEGIN
           ASO_MARGIN_PVT.Get_Line_Margin(p_qte_line_id => X_Qte_Line_Tbl(i).quote_line_id,
                          x_unit_cost => l_unit_cost,
                          x_unit_margin_amount => l_margin_amount,
                          x_margin_percent => l_margin_percent);


     exception
        when no_data_found then
	  l_unit_cost:=null;
	  l_margin_amount:=null;
          l_margin_percent:=null;
	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('Error No data found in ASO_MARGIN_PVT.Get_Line_Margin');
	  end if;
        when others then
	  l_unit_cost:=null;
	  l_margin_amount:=null;
          l_margin_percent:=null;
	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('Error When Others in ASO_MARGIN_PVT.Get_Line_Margin');
	  end if;


      END;

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote quote_line_id'||X_Qte_Line_Tbl(i).quote_line_id);
	  aso_debug_pub.add('Create_Quote l_unit_cost'||l_unit_cost);
  	  aso_debug_pub.add('Create_Quote l_margin_amount'||l_margin_amount);
  	  aso_debug_pub.add('Create_Quote l_margin_percent'||l_margin_percent);
	end if;

	  -- Update the corresponding columns in the line table
          update aso_quote_lines_all
          set LINE_UNIT_COST    = l_unit_cost,
              LINE_MARGIN_AMOUNT    = l_margin_amount,
              LINE_MARGIN_PERCENT   = l_margin_percent,
              last_update_date       =  sysdate,
              last_updated_by        =  fnd_global.user_id,
              last_update_login      =  fnd_global.conc_login_id
          where quote_line_id = X_Qte_Line_Tbl(i).quote_line_id;


    end loop;


-- end cost_er rassharm


      Update_Quote_Total ( P_Qte_Header_id            => x_Qte_Header_rec.quote_header_id,
			            P_Calculate_Tax            => p_control_rec.calculate_tax_flag,
			            P_calculate_Freight_Charge => p_control_rec.calculate_freight_charge_flag,
                           p_control_rec              => p_control_rec,
			            P_Call_Ar_Api_Flag         => l_call_ar_api,
					  X_Return_Status            => x_return_status,
			            X_Msg_Count                => x_msg_count,
			            X_Msg_Data                 => x_msg_data);

      x_qte_header_rec := aso_utility_pvt.query_header_row(x_qte_header_rec.quote_header_id);

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	          FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
	          FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER AFTER UPDATETOTAL', TRUE);
	          FND_MSG_PUB.ADD;
	      END IF;

	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN

	      RAISE FND_API.G_EXC_ERROR;

      END IF;


      IF ( p_qte_header_rec.contract_template_id IS NOT NULL
          AND p_qte_header_rec.contract_template_id <> FND_API.G_MISS_NUM)
          AND NVL(FND_PROFILE.Value('OKC_ENABLE_SALES_CONTRACTS'),'N') = 'Y' THEN

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.add( 'Create_Quote - before instantiating contract terms. ', 1, 'Y');
	           aso_debug_pub.add( 'Create_Quote - template id: ' || p_qte_header_rec.contract_template_id, 1, 'Y');
	           aso_debug_pub.add( 'Create_Quote - target_doc_id: ' || x_Qte_Header_rec.quote_header_id, 1, 'Y');
	           aso_debug_pub.add( 'Create_Quote - p_validation_string: ' || TO_CHAR(x_Qte_Header_rec.LAST_UPDATE_DATE), 1, 'Y');
	       END IF;

            OKC_TERMS_COPY_GRP.Copy_Terms ( P_Api_Version		    => 1.0,
                                            P_Template_ID		    => p_qte_header_rec.contract_template_id,
      	                                  P_Target_Doc_ID		    => x_Qte_Header_rec.quote_header_id,
      	                                  P_Target_Doc_Type	    => 'QUOTE',
      	                                  P_Article_Effective_Date => NULL,
      	                                  P_Retain_Deliverable	    => 'N',
      	                                  p_validation_string      => TO_CHAR(x_Qte_Header_rec.LAST_UPDATE_DATE),
                                            X_Return_Status          => X_Return_Status,
                                            X_Msg_Count              => X_Msg_Count,
                                            X_Msg_Data               => X_Msg_Data );

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_COPY_TERMS');
                    FND_MSG_PUB.ADD;
                END IF;

                IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                     RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;

      END IF;
      -- end of hyang new okc

      -- Change START
      -- Release 12 TAP Changes
      -- Girish Sachdeva 8/30/2005
      -- Adding the call to insert record in the ASO_CHANGED_QUOTES
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('ASO_QUOTE_HEADERS_PVT.CREATE_QUOTE : Calling ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES, quote number : ' || x_qte_header_rec.quote_number, 1, 'Y');
      END IF;


      -- Call to insert record in ASO_CHANGED_QUOTES
      ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES(x_qte_header_rec.quote_number);

      -- Change END


      --
      -- End of API body
      --

      -- Standard check for p_commit

      IF FND_API.to_Boolean( p_commit ) THEN
	     COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('******************************************************', 1, 'Y');
	     aso_debug_pub.add('End Create_Quote Procedure', 1, 'Y');
	     aso_debug_pub.add('******************************************************', 1, 'Y');
	 END IF;


      EXCEPTION

	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME        => L_API_NAME
		  ,P_PKG_NAME        => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE         => SQLCODE
		  ,P_SQLERRM         => SQLERRM
		  ,X_MSG_COUNT       => X_MSG_COUNT
		  ,X_MSG_DATA        => X_MSG_DATA
		  ,X_RETURN_STATUS   => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME        => L_API_NAME
		  ,P_PKG_NAME        => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE         => SQLCODE
		  ,P_SQLERRM         => SQLERRM
		  ,X_MSG_COUNT       => X_MSG_COUNT
		  ,X_MSG_DATA        => X_MSG_DATA
		  ,X_RETURN_STATUS   => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME        => L_API_NAME
		  ,P_PKG_NAME        => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE         => SQLCODE
		  ,P_SQLERRM         => SQLERRM
		  ,X_MSG_COUNT       => X_MSG_COUNT
		  ,X_MSG_DATA        => X_MSG_DATA
		  ,X_RETURN_STATUS   => X_RETURN_STATUS);

End Create_quote;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_quote(
    P_Api_Version_Number	      IN   NUMBER,
    P_Init_Msg_List		      IN   VARCHAR2	                                := FND_API.G_FALSE,
    P_Commit			      IN   VARCHAR2	                                := FND_API.G_FALSE,
    p_validation_level		 IN   NUMBER	                                := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec		      IN   ASO_QUOTE_PUB.Control_Rec_Type           := ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec		 IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type        := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type  := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
    P_hd_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type    := ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type  := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl      IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl		      IN   ASO_QUOTE_PUB.Qte_Line_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		 IN   ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		 IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type  := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		 IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type         := ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	      IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type    := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type := ASO_QUOTE_PUB.G_Miss_Price_Adj_Rltship_Tbl,
    P_ln_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type  := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
    P_ln_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
    P_ln_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL,
    P_ln_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type    := ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl,
    P_ln_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl      IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Qte_Access_Tbl           IN   ASO_QUOTE_PUB.Qte_Access_Tbl_Type        := ASO_QUOTE_PUB.G_MISS_QTE_ACCESS_TBL,
    P_Template_Tbl             IN   ASO_QUOTE_PUB.Template_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_TEMPLATE_TBL,
    P_Related_Obj_Tbl          IN   ASO_QUOTE_PUB.Related_Obj_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_RELATED_OBJ_TBL,
    x_Qte_Header_Rec		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Line_Tbl		      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    X_hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    X_hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_hd_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    X_ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    X_ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type,
    X_ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    X_Qte_Access_Tbl           OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Access_Tbl_Type,
    X_Template_Tbl             OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Template_Tbl_Type,
    X_Related_Obj_Tbl          OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Related_Obj_Tbl_Type,
    X_Return_Status		      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count 		      OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data			      OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
lx_line_relationship_id number;
    --ovn
    Cursor C_Get_quote(c_QUOTE_HEADER_ID Number) IS
    Select LAST_UPDATE_DATE, QUOTE_STATUS_ID, quote_number, party_id, cust_account_id,
           order_type_id, order_id, object_version_number, currency_code, price_list_id, PRODUCT_FISC_CLASSIFICATION, TRX_BUSINESS_CATEGORY  -- bug 13597269
    From  ASO_QUOTE_HEADERS_ALL
    Where QUOTE_HEADER_ID = c_QUOTE_HEADER_ID;

    CURSOR C_Qte_Status(c_qte_status_id NUMBER) IS
    SELECT  AUTO_VERSION_FLAG
    FROM    ASO_QUOTE_STATUSES_B
    WHERE   quote_status_id = c_qte_status_id;

    CURSOR C_Qte_Version (X_qte_number NUMBER) IS
    SELECT max(quote_version)
    FROM ASO_QUOTE_HEADERS_ALL
    WHERE quote_number = X_qte_number;

    CURSOR c_payment_rec IS
    SELECT payment_id, payment_option FROM ASO_PAYMENTS
    WHERE quote_header_id = P_Qte_Header_Rec.quote_header_id
    AND quote_line_id IS NULL;

    CURSOR c_shipment_rec IS
    SELECT shipment_id FROM ASO_SHIPMENTS
    WHERE quote_header_id = P_Qte_Header_Rec.quote_header_id
    AND quote_line_id IS NULL;

    CURSOR c_tax_rec IS
    SELECT tax_detail_id FROM ASO_TAX_DETAILS
    WHERE quote_header_id = P_Qte_Header_Rec.quote_header_id
    AND quote_line_id IS NULL
    AND ORIG_TAX_CODE IS NOT NULL;

    CURSOR c_qte_line(l_d_qte_line NUMBER) IS
    SELECT quote_line_id  FROM ASO_QUOTE_LINES_ALL
    where quote_line_id= l_d_qte_line;

    --ovn
    cursor c_last_update_date( p_qte_hdr_id  number) is
    select last_update_date
    from aso_quote_headers_all
    where quote_header_id = p_qte_hdr_id;

    cursor c_quote_lines( p_qte_hdr_id  number) is
    select quote_line_id,order_line_type_id,line_category_code,price_list_id,line_quote_price,quantity
    from aso_quote_lines_all
    where quote_header_id = p_qte_hdr_id;

    cursor c_related_obj_id (p_qte_hdr_id number) is
    select related_object_id,last_update_date
    from aso_quote_related_objects
    where quote_object_id = p_qte_hdr_id
    and quote_object_type_code = 'HEADER'
    and relationship_type_code = 'OPP_QUOTE';

    Cursor c_obj_id(p_qte_header_id Number) IS
    Select object_id
    from aso_quote_related_objects
    where quote_object_id = p_qte_header_id
    and quote_object_type_code = 'HEADER'
    and relationship_type_code = 'OPP_QUOTE';

    G_LOGIN_ID	                 NUMBER                := FND_GLOBAL.CONC_LOGIN_ID;
    G_USER_ID	                 NUMBER                := FND_GLOBAL.USER_ID;
    payment_rec	            c_payment_rec%rowtype;
    l_payment_db_tbl		  varchar_tbl_type;
    shipment_rec	            c_shipment_rec%ROWTYPE;
    l_shipment_db_tbl		  VARCHAR_TBL_TYPE;
    l_qln_id                    NUMBER;
    l_tax_db_tbl                VARCHAR_TBL_TYPE;
    l_qte_status_id             NUMBER;
    l_qte_number                NUMBER;
    l_last_update_date          DATE;
    -- bug 13597269
   l_prod_fisc_class        varchar2(240);
   l_trx_business_category varchar2(240);

    --ovn
    l_object_version_number     NUMBER;
    l_update_allowed		  VARCHAR2(1);
    l_party_id			       NUMBER;
    l_cust_account_id		  NUMBER;
    l_auto_version		       VARCHAR2(1);
    l_api_name			       CONSTANT VARCHAR2(30) := 'Update_quote';
    l_api_version_number	       CONSTANT NUMBER       := 1.0;
    l_return_status		       VARCHAR2(1);
    l_found			       VARCHAR2(1);
    l_calculate_freight_charge  VARCHAR2(1) := 'Y';
    l_calculate_tax		       VARCHAR2(1) := 'Y';
    x_tax_amount                NUMBER;

    l_qte_header_id		       NUMBER;
    l_qte_line_id		       NUMBER;
    l_index			       NUMBER;
    l_index_2			       NUMBER;
    x_status 				  VARCHAR2(1);
    l_order_type_id             NUMBER;
    l_qte_line_rec              ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_qte_line_rec_out          ASO_QUOTE_PUB.Qte_Line_Rec_Type;
   -- l_qte_header_rec		  ASO_QUOTE_PUB.Qte_Header_Rec_Type          := p_qte_header_rec;
    l_qte_header_rec		  ASO_QUOTE_PUB.Qte_Header_Rec_Type; -- Code change for Quoting Usability Sun ER
    l_old_header_rec		  ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_qte_line_dtl_tbl		  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_qte_line_dtl_tbl_out	  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_Line_Attr_Ext_Tbl		  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
    l_Line_Attr_Ext_Tbl_out	  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
    l_shipment_tbl		       ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_shipment_tbl_out		  ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_payment_tbl               ASO_QUOTE_PUB.Payment_Tbl_Type;
    l_payment_tbl_out           ASO_QUOTE_PUB.Payment_Tbl_Type;
    l_freight_charge_tbl        ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    l_freight_charge_tbl_out	  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    l_tax_detail_tbl		  ASO_QUOTE_PUB.Tax_Detail_tbl_Type;
    l_tax_detail_tbl_out		  ASO_QUOTE_PUB.Tax_Detail_tbl_Type;
    l_Price_Attr_Tbl		  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_Price_Attr_Tbl_out		  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    l_Price_Adj_Tbl             ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    l_Price_Adj_Tbl_out		  ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    l_Price_Adj_Attr_Tbl	       ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    l_Price_Adj_Attr_Tbl_out	  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    l_pricing_control_rec	  ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE;
    l_Price_Adjustment_Tbl	  ASO_QUOTE_PUB.Price_Adj_Tbl_Type           := p_Price_Adjustment_Tbl;
    l_line_rltship_rec		  ASO_QUOTE_PUB.Line_Rltship_Rec_Type;
    l_price_adj_rltship_rec	  ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type;
    l_Tax_Control_Rec           ASO_TAX_INT.Tax_Control_Rec_Type;
    l_tax_detail_rec            ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
    l_hd_shipment_tbl           ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_shp_index_link		  Index_Link_Tbl_Type;
    l_prc_index_link		  Index_Link_Tbl_Type;
    l_prc_index_link_rev	       Index_Link_Tbl_Type;
    l_quote_party_tbl           ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
    l_quote_party_tbl_out       ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
    l_sales_credit_tbl          ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
    l_sales_credit_tbl_out      ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
    l_control_rec               ASO_QUOTE_PUB.Control_Rec_Type             := p_control_rec;
    l_control_rec_bv            ASO_QUOTE_PUB.Control_Rec_Type             := p_control_rec;
    l_qte_access_rec            ASO_SECURITY_INT.Qte_Access_Rec_Type       := ASO_SECURITY_INT.G_MISS_QTE_ACCESS_REC;
    l_qte_access_tbl            ASO_SECURITY_INT.Qte_Access_Tbl_Type       := ASO_SECURITY_INT.G_MISS_QTE_ACCESS_TBL;
    l_qte_access_tbl_out        ASO_SECURITY_INT.Qte_Access_Tbl_Type;
    l_ln_rec                    ASO_QUOTE_PUB.Qte_Line_Rec_Type            := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC;


    -- Begin Variable declaration for Batch Validation 05/24/2002

    l_batch_qte_line_rec        aso_quote_pub.qte_line_rec_type     := aso_quote_pub.g_miss_qte_line_rec;
    l_p_batch_qte_line_tbl      aso_quote_pub.qte_line_tbl_type     := aso_quote_pub.g_miss_qte_line_tbl;
    l_send_qte_line_tbl         aso_quote_pub.qte_line_tbl_type     := aso_quote_pub.g_miss_qte_line_tbl;
    l_send_qte_line_dtl_tbl     aso_quote_pub.qte_line_dtl_tbl_type := aso_quote_pub.g_miss_qte_line_dtl_tbl;
    l_batch_qte_line_dtl_tbl    aso_quote_pub.qte_line_dtl_tbl_type := aso_quote_pub.g_miss_qte_line_dtl_tbl;
    l_search_qte_line_tbl       aso_quote_pub.qte_line_tbl_type     := aso_quote_pub.g_miss_qte_line_tbl;
    l_delete_qte_line_tbl       aso_quote_pub.qte_line_tbl_type     := aso_quote_pub.g_miss_qte_line_tbl;
    l_p_batch_qte_line_dtl_tbl  aso_quote_pub.qte_line_dtl_tbl_type := aso_quote_pub.g_miss_qte_line_dtl_tbl;
    l_model_qte_line_tbl        aso_quote_pub.qte_line_tbl_type;
    l_model_qte_line_dtl_tbl    aso_quote_pub.qte_line_dtl_tbl_type;

    l_batch_index     number       :=  0;  --should not be initialized inside line loop code
    l_model_index     number       :=  0;  --should not be initialized inside line loop code
    l_add_line        varchar2(1)  :=  fnd_api.g_false;
    l_add_model_line  varchar2(1)  :=  fnd_api.g_false;
    l_send_index      NUMBER       :=  0;
    l_model_line_id   NUMBER;
    l_lines	      NUMBER:=0;
    l_complete_configuration_flag  VARCHAR2(1);
    l_valid_configuration_flag     VARCHAR2(1);
    l_qte_lines_tbl_count Number;
    l_config_header_id number;
    l_config_revision_num number;
    l_new_config_hdr_id number;

    cursor c_model_line (p_config_header_id NUMBER, p_config_revision_num NUMBER)is
    select quote_line_id from aso_quote_line_details
    where config_header_id = p_config_header_id
    and   config_revision_num = p_config_revision_num
    and   ref_type_code = 'CONFIG'
    and   ref_line_id is NULL;

    CURSOR c_config_exist_in_cz (p_config_hdr_id number, p_config_rev_nbr number) IS
    select config_hdr_id
    from cz_config_details_v
    where config_hdr_id = p_config_hdr_id
    and config_rev_nbr = p_config_rev_nbr;

    l_deactivate_qte_header_rec aso_quote_pub.qte_header_rec_type;
    l_deactivate_quote_line_tbl aso_quote_pub.qte_line_tbl_type     := aso_quote_pub.g_miss_qte_line_tbl;
    l_deactivate_instance_tbl aso_quote_headers_pvt.Instance_Tbl_Type := aso_quote_headers_pvt.G_MISS_Instance_Tbl;
    l_deactivate_counter number := 0;

    -- End Variable declaration for Batch Validation 05/24/2002

    l_order_id number;
    l_shipment_rec           ASO_QUOTE_PUB.Shipment_Rec_Type := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC;

    l_copy_quote_control_rec  aso_copy_quote_pub.copy_quote_control_rec_type;
    l_copy_quote_header_rec   aso_copy_quote_pub.copy_quote_header_rec_type;
    l_quote_number            number;

    l_price_updated_date_flag  VARCHAR2(1) := fnd_api.g_false;

    --New Code for to call overload pricing_order
    lv_qte_header_rec               ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    lx_qte_header_rec               ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    lx_qte_line_tbl                 ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    lv_hd_shipment_rec              ASO_QUOTE_PUB.Shipment_Rec_Type;
    lv_hd_shipment_tbl              ASO_QUOTE_PUB.Shipment_Tbl_Type;
    lv_hd_price_attr_tbl            ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    lx_price_adj_rltship_tbl        ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

    CURSOR C_Check_Store_Status (l_old_stat NUMBER, l_new_stat NUMBER) IS
    SELECT 'Y'
    FROM ASO_QUOTE_STATUSES_B A, ASO_QUOTE_STATUSES_B B
    WHERE A.Quote_Status_Id = l_old_stat
    AND A.Status_Code = 'STORE DRAFT'
    AND B.Quote_Status_Id = l_new_stat
    AND B.Status_Code = 'DRAFT';

    CURSOR C_Get_Quota_Credit_Type IS
    SELECT Sales_Credit_Type_Id
    FROM OE_SALES_CREDIT_TYPES
    WHERE Quota_Flag = 'Y';

    CURSOR C_Get_SCredit_Exists(l_qte_hdr_id NUMBER) IS
    SELECT 'Y'
    FROM ASO_SALES_CREDITS
    WHERE quote_header_id = l_qte_hdr_id;

    CURSOR c_tax_line(p_qte_header_id NUMBER, p_quote_line_id  NUMBER) IS
    select nvl(sum(nvl(tax_amount, 0)),0) tax_amount
    FROM   ASO_TAX_DETAILS
    WHERE  quote_header_id              =   p_qte_header_id
    and    quote_line_id                =   p_quote_line_id;

    Cursor get_line_payment_term(p_qte_header_id NUMBER, p_quote_line_id  NUMBER) IS
    SELECT payment_term_id
    FROM aso_payments
    WHERE  quote_header_id              =   p_qte_header_id
    and    quote_line_id                =   p_quote_line_id;

    Cursor get_hdr_payment_term(p_qte_header_id NUMBER) IS
    SELECT payment_term_id
    FROM aso_payments
    WHERE  quote_header_id              =   p_qte_header_id
    and    quote_line_id                IS NULL;

    CURSOR C_Get_Hdr_Resource_Id(lc_qte_header_id NUMBER) IS
    SELECT resource_id
    FROM Aso_Quote_Headers_All
    WHERE quote_header_id = lc_qte_header_id;

    CURSOR  c_inv_org_id(l_main_org_id Number) IS
    SELECT  master_organization_id
    FROM    oe_system_parameters
    WHERE   org_id = l_main_org_id;

    CURSOR  c_org_id(p_qte_header_id Number) IS
    SELECT  org_id
    FROM    aso_quote_headers_all
    WHERE   quote_header_id = p_qte_header_id;

    l_master_organization_id        NUMBER;
    l_quote_org_id                  NUMBER;
    l_scredit_exists                VARCHAR2(1)  := 'N';
    l_quota_id                      NUMBER;
    l_store_trans                   VARCHAR2(1)  := 'N';
    l_sales_team_prof               VARCHAR2(30) := FND_PROFILE.value('ASO_AUTO_TEAM_ASSIGN');

    -- hyang defaulting framework
    l_def_control_rec               ASO_DEFAULTING_INT.Control_Rec_Type     := ASO_DEFAULTING_INT.G_MISS_CONTROL_REC;
    l_db_object_name                VARCHAR2(30);
    l_hd_shipment_rec               ASO_QUOTE_PUB.Shipment_Rec_Type         := ASO_QUOTE_PUB.G_MISS_Shipment_REC;
    l_hd_payment_rec                ASO_QUOTE_PUB.Payment_Rec_Type          := ASO_QUOTE_PUB.G_MISS_Payment_REC;
    l_hd_tax_detail_rec             ASO_QUOTE_PUB.Tax_Detail_Rec_Type       := ASO_QUOTE_PUB.G_MISS_Tax_Detail_REC;
    l_hd_misc_rec                   ASO_DEFAULTING_INT.Header_Misc_Rec_Type := ASO_DEFAULTING_INT.G_MISS_HEADER_MISC_REC;
    lx_hd_shipment_rec              ASO_QUOTE_PUB.Shipment_Rec_Type;
    lx_hd_payment_rec               ASO_QUOTE_PUB.Payment_Rec_Type;
    lx_hd_tax_detail_rec            ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
    lx_hd_misc_rec                  ASO_DEFAULTING_INT.Header_Misc_Rec_Type;
    lx_quote_line_rec               ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    lx_ln_misc_rec                  ASO_DEFAULTING_INT.Line_Misc_Rec_Type;
    lx_ln_shipment_rec              ASO_QUOTE_PUB.Shipment_Rec_Type;
    lx_ln_payment_rec               ASO_QUOTE_PUB.Payment_Rec_Type;
    lx_ln_tax_detail_rec            ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
    lx_changed_flag                 VARCHAR2(1);
    l_hd_payment_tbl	           ASO_QUOTE_PUB.Payment_Tbl_Type;
    l_hd_tax_detail_tbl	           ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

    --Template changes
    l_template_tbl                  aso_quote_tmpl_int.list_template_tbl_type;
    l_qte_line_tbl                  aso_quote_pub.qte_line_tbl_type         := p_qte_line_tbl;
    lx_qte_line_dtl_tbl             ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type     := p_qte_line_dtl_tbl;
    l_count                         number;
    l_currency_code                 varchar2(15);
    l_price_list_id                 number;
    l_related_obj_rec               ASO_quote_PUB.RELATED_OBJ_Rec_Type  := ASO_quote_PUB.G_MISS_RELATED_OBJ_REC;
    l_related_obj_id                number;
    x_related_obj_rec               ASO_quote_PUB.RELATED_OBJ_Rec_Type  := ASO_quote_PUB.G_MISS_RELATED_OBJ_REC;
    l_obj_id                        number;

    l_installment_option     VARCHAR2(240);
    l_line_shipping_charge   NUMBER;
    l_line_tax               NUMBER;
    l_line_term_id           NUMBER := null;
    l_line_amount            NUMBER;
    l_paynow_amount          NUMBER;
    l_paynow_tax             NUMBER;
    l_paynow_charges         NUMBER;
    l_paynow_total           NUMBER;
    l_call_ar_api            varchar2(1);

  /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/

  l_check_service_rec ASO_SERVICE_CONTRACTS_INT.CHECK_SERVICE_REC_TYPE;

  CURSOR C_get_cust( p_qte_hdr_id  number) IS
            SELECT END_CUSTOMER_CUST_ACCOUNT_ID,cust_account_id
  	     FROM aso_quote_headers_all
	     WHERE quote_header_id= p_qte_hdr_id;

   CURSOR c_serv( p_qte_hdr_id  number) IS
      SELECT a1.quote_line_id,
	SERVICE_REF_LINE_ID   ,
	service_ref_type_code ,
	a2.inventory_item_id
   FROM aso_quote_line_details a1,
	aso_quote_lines_all a2
  WHERE a2.quote_header_id = p_qte_hdr_id
	AND a1.quote_line_id       = a2.quote_line_id
	AND SERVICE_REF_TYPE_CODE IN ('CUSTOMER_PRODUCT','PRODUCT_CATALOG');


  l_inventory_item_id NUMBER ;
  ls_count            NUMBER;
  ls_service_inventory_item_id NUMBER ;
  ls_cust_account_id   NUMBER;
  ls_end_cust_account_id   NUMBER;
  -- For IB
  ls_ib_cust_account_id_orig NUMBER;
  ls_ib_cust_account_id NUMBER;
  -- For PC
  ls_pc_cust_account_id_orig NUMBER;
  ls_pc_cust_account_id NUMBER;
  l_Available_YN VARCHAR2(1);

  found       number:=0;
  ls_qte_line_tbl         aso_quote_pub.qte_line_tbl_type     := aso_quote_pub.g_miss_qte_line_tbl;

/*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/

  /* Code change for Quoting Usability Sun ER Start */

       CURSOR C_AGREEMENT(P_AGREEMENT_ID IN NUMBER,P_INVOICE_TO_CUSTOMER_ID IN NUMBER) IS
       SELECT 'x'
       FROM OE_AGREEMENTS_VL
       WHERE AGREEMENT_ID = P_AGREEMENT_ID
       AND  INVOICE_TO_CUSTOMER_ID = P_INVOICE_TO_CUSTOMER_ID;

       l_var varchar2(1);

       l_appl_param_rec CZ_API_PUB.appl_param_rec_type;
       l_return_value Varchar2(1);

       cursor c_service_ref_quote (P_Quote_line_id number) is
       select service_ref_line_id
       from aso_quote_line_Details
       where quote_line_id=  P_Quote_line_id
       and service_ref_type_code ='QUOTE';

       l_line_dtl_tbl aso_quote_pub.qte_line_dtl_tbl_type := aso_quote_pub.g_miss_qte_line_dtl_tbl;

  /* Code change for Quoting Usability Sun ER End */

  /* Start : Code change for Bug 9847694 */

  Cursor C_ITEM_TYPE_CODE(P_Quote_line_id Number) Is
  select item_type_code
  from aso_quote_lines_all
  where quote_line_id = P_Quote_line_id;

  l_item_type_code aso_quote_lines_all.item_type_code%Type;

  Cursor C_SERVICE_REF_TYPE_CODE(P_Quote_line_id Number) Is
  select service_ref_type_code
  from aso_quote_line_details
  where quote_line_id = P_Quote_line_id;

  l_service_ref_type_code aso_quote_line_details.service_ref_type_code%Type;

  /* End : Code change for Bug 9847694 */

-- bug 10261431
  l_top_model_line_id  number;
  l_ato_line_id                number;

  -- bug 10217258
    l_qty                           number;     -- rassharm

    CURSOR c_qte_line_type(l_d_qte_line NUMBER) IS
    select item_type_code
     from aso_quote_lines_all
    where quote_line_id= l_d_qte_line;

   l_item_type_code1  varchar2(30); -- rassharm

   /*** Start : Code change done for Bug 11076978 ***/

   Cursor C_cust_account_id(p_quote_header_id Number) IS
   Select cust_account_id
   From aso_quote_headers_all
   Where quote_header_id = p_quote_header_id;

   CURSOR c_pay_term_acct(p_cust_account_id IN Number) IS
   SELECT hcp.standard_terms
   FROM   hz_cust_accounts hca,hz_customer_profiles hcp
   WHERE  hca.cust_account_id = p_cust_account_id
   AND    hcp.cust_account_id = hca.cust_account_id
   AND    nvl(hcp.status,'A') = 'A';

   l_cust_account_id_db  NUMBER;

   /*** End : Code change done for Bug 11076978 ***/

   ct_rel    number; -- bug 12608111

   /* Start : Code change done for Bug 13064273 */

      CURSOR C_Agreement_PL(p_agreement_id Number) Is
      Select pri.list_header_id, pri.currency_code
      from OE_AGREEMENTS_B agr, qp_list_headers_vl pri
      where agr.agreement_id = p_agreement_id
      and pri.list_header_id = agr.price_list_id
      and pri.list_type_code in ('PRL','AGR')
      and pri.active_flag = 'Y'
      and trunc(nvl(pri.start_date_active, sysdate)) <= trunc(sysdate)
      and trunc(nvl(pri.end_date_active, sysdate)) >= trunc(sysdate);

      CURSOR C_Customer_PL(p_cust_acct_id Number) Is
      Select pri.list_header_id , pri.currency_code
      from HZ_CUST_ACCOUNTS cust, qp_list_headers_vl pri
      where cust.cust_account_id = p_cust_acct_id
      and cust.price_list_id = pri.list_header_id
      and pri.list_type_code in ('PRL','AGR')
      and pri.active_flag = 'Y'
      and trunc(nvl(pri.start_date_active, sysdate)) <= trunc(sysdate)
      and trunc(nvl(pri.end_date_active, sysdate)) >= trunc(sysdate);

      CURSOR C_Order_Type_PL(p_order_type_id Number) Is
      Select pri.list_header_id, pri.currency_code
      from OE_TRANSACTION_TYPES_ALL ord, qp_list_headers_vl pri
      where ord.TRANSACTION_TYPE_ID = p_order_type_id
      and ord.price_list_id = pri.list_header_id
      and pri.list_type_code in ('PRL','AGR')
      and pri.active_flag = 'Y'
      and trunc(nvl(pri.start_date_active, sysdate)) <= trunc(sysdate)
      and trunc(nvl(pri.end_date_active, sysdate)) >= trunc(sysdate);

      /* End : Code change done for Bug 13064273 */

      -- bug 13597269
      cursor c_quote_line_tax_det (P_Quote_line_id number) is
       select PRODUCT_FISC_CLASSIFICATION, TRX_BUSINESS_CATEGORY
       from aso_quote_lines_all
       where quote_line_id=  P_Quote_line_id;

       /*** Start : Code change done for Bug 13926015  ***/
       Cursor C_Expire_Date(P_Quote_header_id number) Is
       -- Select to_char(quote_expiration_date,'DD-MON-RRRR') commented for bug 14099184
       Select quote_expiration_date
       From aso_quote_headers_all
       Where Quote_header_id = P_Quote_header_id;

       l_expire_date Date;

       /*** End : Code change done for Bug 13926015  ***/

              -- cost_er
   l_unit_cost number;
   l_margin_amount number;
   l_margin_percent number;

   --end cost_er

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_quote_PVT;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('******************************************************', 1, 'Y');
	     aso_debug_pub.add('Begin Update_Quote Procedure', 1, 'Y');
	     aso_debug_pub.add('******************************************************', 1, 'Y');
	 END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
			 		                  p_api_version_number,
					                  l_api_name,
					                  G_PKG_NAME) THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
	     FND_MSG_PUB.initialize;
      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('Update_Quote - Begin ', 1, 'Y');
	 END IF;
      --Procedure added by Anoop Rajan on 30/09/2005 to print login details
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Before call to printing login info details', 1, 'Y');
		ASO_UTILITY_PVT.print_login_info;
		aso_debug_pub.add('After call to printing login info details', 1, 'Y');
      END IF;

      -- Change Done By Girish
      -- Procedure added to validate the operating unit
      ASO_VALIDATE_PVT.VALIDATE_OU(P_Qte_Header_Rec);

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Api body
      l_control_rec.line_pricing_event  := NULL;
      l_control_rec.calculate_tax_flag  := NULL;

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL THEN

	     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	         FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
	         FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
	         FND_MSG_PUB.ADD;
	     END IF;
	     RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote: Before call to aso_input_param_debug.print_quote_input procedure', 1, 'Y');

      ASO_INPUT_PARAM_DEBUG.Print_quote_input(
                       P_Quote_Header_Rec            => p_qte_header_rec
                     , P_hd_Price_Attributes_Tbl     => P_hd_Price_Attributes_Tbl
                     , P_hd_Payment_Tbl              => P_hd_Payment_Tbl
                     , P_hd_Shipment_tbl             => P_hd_Shipment_tbl
                     , P_hd_Tax_Detail_Tbl           => P_hd_Tax_Detail_Tbl
                     , P_hd_Sales_Credit_Tbl         => P_hd_Sales_Credit_Tbl
                     , P_Qte_Line_Tbl                => P_Qte_Line_Tbl
                     , P_Qte_Line_Dtl_Tbl            => P_Qte_Line_Dtl_Tbl
                     , P_Price_Adjustment_Tbl        => P_Price_Adjustment_Tbl
                     , P_Ln_Price_Attributes_Tbl     => P_Ln_Price_Attributes_Tbl
                     , P_Ln_Payment_Tbl              => P_Ln_Payment_Tbl
                     , P_Ln_Shipment_Tbl             => P_Ln_Shipment_Tbl
                     , P_Ln_Tax_Detail_Tbl           => P_Ln_Tax_Detail_Tbl
                     , P_ln_Sales_Credit_Tbl         => P_ln_Sales_Credit_Tbl
                     , P_Qte_Access_Tbl              => P_Qte_Access_Tbl);

          aso_debug_pub.add('Update_Quote: After call to aso_input_param_debug.print_quote_input procedure', 1, 'Y');
	 END IF;

      Open C_Get_quote( p_qte_header_rec.QUOTE_HEADER_ID);
      Fetch C_Get_quote into l_LAST_UPDATE_DATE, l_qte_status_id, l_qte_number,l_party_id, l_cust_account_id,
	                        l_order_type_id,l_order_id,l_object_version_number, l_currency_code, l_price_list_id,l_prod_fisc_class,l_trx_business_category; -- bug 13597269

      If ( C_Get_quote%NOTFOUND) Then

	     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	         FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_UPDATE_TARGET');
	         FND_MESSAGE.Set_Token ('INFO', 'quote', FALSE);
	         FND_MSG_PUB.Add;
          END IF;
          raise FND_API.G_EXC_ERROR;

      END IF;
      Close C_Get_quote;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote: quote_header_id:         '|| p_qte_header_rec.quote_header_id, 1, 'Y');
          aso_debug_pub.add('Update_Quote: l_LAST_UPDATE_DATE:      '|| l_LAST_UPDATE_DATE, 1, 'Y');
          aso_debug_pub.add('Update_Quote: l_qte_status_id:         '|| l_qte_status_id, 1, 'Y');
          aso_debug_pub.add('Update_Quote: l_qte_number:            '|| l_qte_number, 1, 'Y');
          aso_debug_pub.add('Update_Quote: l_order_type_id:         '|| l_order_type_id, 1, 'Y');
          aso_debug_pub.add('Update_Quote: l_order_id:              '|| l_order_id, 1, 'Y');
		aso_debug_pub.add('Update_Quote: l_object_version_number: '|| l_object_version_number,1,'Y');
		aso_debug_pub.add('Update_Quote: l_currency_code:         '|| l_currency_code,1,'Y');
		aso_debug_pub.add('Update_Quote: l_price_list_id:         '|| l_price_list_id,1,'Y');
		aso_debug_pub.add('Update_Quote:Header  product fiscal classification:         '|| l_prod_fisc_class,1,'Y');
		aso_debug_pub.add('Update_Quote:Header transaction business category:         '|| l_trx_business_category,1,'Y');
      END IF;

      If (l_last_update_date is NULL or l_last_update_date = FND_API.G_MISS_Date ) Then

	     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	         FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
	         FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
	         FND_MSG_PUB.ADD;
	     END IF;
	     raise FND_API.G_EXC_ERROR;

      End if;

      -- Check Whether record has been changed by someone else
      If (l_last_update_date <> p_qte_header_rec.last_update_date) Then

	     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	         FND_MESSAGE.Set_Name('ASO', 'ASO_API_RECORD_CHANGED');
	         FND_MESSAGE.Set_Token('INFO', 'quote', FALSE);
	         FND_MSG_PUB.ADD;
	     END IF;
	     raise FND_API.G_EXC_ERROR;

      End if;

       ls_qte_line_tbl := p_qte_line_tbl; -- BugNo 8647883




	 --ovn
	 If (p_qte_header_rec.object_version_number is not null) AND (p_qte_header_rec.object_version_number <> FND_API.G_MISS_NUM) then

	    --Compare the passed value to the db value
	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Update_Quote - p_qte_header_rec.object_version_number:' ||p_qte_header_rec.object_version_number,1,'Y');
	    END IF;

	    If (l_object_version_number <> p_qte_header_rec.object_version_number) then

	        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		       FND_MESSAGE.Set_Name('ASO', 'ASO_API_RECORD_CHANGED');
		       FND_MESSAGE.Set_Token('INFO', 'quote', FALSE);
		       FND_MSG_PUB.ADD;
		   END IF;
		   raise FND_API.G_EXC_ERROR;

	    End If;

      End If;  --(l_object_version_number is not null) or (l_object_version_number <> FND_API.G_MISS_NUM)

	 If ((p_qte_header_rec.BATCH_PRICE_FLAG <> FND_API.G_FALSE) or (p_qte_header_rec.BATCH_PRICE_FLAG = FND_API.G_MISS_CHAR)) then -- bug 16089119

	      ASO_CONC_REQ_INT.Lock_Exists( p_quote_header_id => p_qte_header_rec.quote_header_id,
	                                    x_status          => x_status);

		 if (x_status = FND_API.G_TRUE) then

			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
                   FND_MSG_PUB.ADD;
			end if;
               raise FND_API.G_EXC_ERROR;

		 end if;
	 end if;

      IF l_order_id is NOT NULL and l_order_id <> FND_API.G_MISS_NUM THEN

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_API_UPDATE_QUOTE_SUBMITTED');
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;

      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('Update_Quote - quote_number: '||to_char(l_qte_number), 1, 'N');
	 END IF;



      If p_qte_header_rec.QUOTE_SOURCE_CODE <> 'IStore Account' Then -- added for Bug 13473812

         /*** Start : Code change done for Bug 11076978 ***/

         If (p_qte_header_rec.cust_account_id IS NOT NULL AND
	     p_qte_header_rec.cust_account_id <> FND_API.G_MISS_NUM ) Then
             Open C_cust_account_id(p_qte_header_rec.Quote_Header_Id);
             Fetch C_cust_account_id Into l_cust_account_id_db;
             Close C_cust_account_id;
         End If;

         If l_cust_account_id_db <> p_qte_header_rec.cust_account_id Then
            l_control_rec.Change_Customer_flag := FND_API.G_TRUE;
         End If;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Update_Quote - l_control_rec.Change_Customer_flag : ' ||l_control_rec.Change_Customer_flag,1,'Y');
         END IF;

         /*** End : Code change done for Bug 11076978 ***/

      End If;

      /* Code change for Quoting Usability Sun ER Start */

     If l_control_rec.Change_Customer_flag = FND_API.G_FALSE Then    -- Code change done for Bug 11076978

	 l_qte_header_rec    := p_qte_header_rec;
	 l_hd_shipment_tbl   := p_hd_shipment_tbl;
         l_hd_payment_tbl    := p_hd_payment_tbl;
         l_hd_tax_detail_tbl := p_hd_tax_detail_tbl;

     ElsIf l_control_rec.Change_Customer_flag = FND_API.G_TRUE Then    -- Code change done for Bug 11076978

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Update_Quote - Change Customer Flow starts', 1, 'Y');
         END IF ;

         l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row ( p_qte_header_rec.Quote_Header_Id );

	 l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows ( p_qte_header_id => p_qte_header_rec.Quote_Header_Id,
                                                                 p_qte_line_id   => NULL );

         l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows(p_qte_header_id =>p_qte_header_rec.Quote_Header_Id,p_qte_line_id =>NULL);

	 l_tax_detail_tbl := ASO_UTILITY_PVT.Query_Tax_Detail_Rows ( p_qte_header_id => p_qte_header_rec.Quote_Header_Id,
                                                                     p_qte_line_id   => NULL,
                                                                     p_shipment_tbl  => ASO_QUOTE_PUB.g_miss_shipment_tbl );

	 l_qte_header_rec.BATCH_PRICE_FLAG               := FND_API.G_FALSE;

     l_qte_header_rec.CUST_ACCOUNT_ID                := P_Qte_Header_Rec.CUST_ACCOUNT_ID;
	 l_qte_header_rec.CUST_PARTY_ID                  := P_Qte_Header_Rec.CUST_PARTY_ID;
	 l_qte_header_rec.PARTY_ID                       := P_Qte_Header_Rec.CUST_PARTY_ID;
	 l_qte_header_rec.SOLD_TO_PARTY_SITE_ID          := P_Qte_Header_Rec.SOLD_TO_PARTY_SITE_ID;

	 l_qte_header_rec.PHONE_ID                       := FND_API.G_MISS_NUM;

	 l_qte_header_rec.INVOICE_TO_CUST_ACCOUNT_ID     := P_Qte_Header_Rec.CUST_ACCOUNT_ID;
	 l_qte_header_rec.INVOICE_TO_CUST_PARTY_ID       := P_Qte_Header_Rec.CUST_PARTY_ID;
	 l_qte_header_rec.INVOICE_TO_PARTY_ID            := FND_API.G_MISS_NUM;
	 l_qte_header_rec.INVOICE_TO_PARTY_SITE_ID       := P_Qte_Header_Rec.SOLD_TO_PARTY_SITE_ID;
	 l_qte_header_rec.INVOICE_TO_PARTY_NAME          := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_CONTACT_FIRST_NAME  := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_CONTACT_MIDDLE_NAME := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_CONTACT_LAST_NAME   := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_ADDRESS1            := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_ADDRESS2            := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_ADDRESS3            := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_ADDRESS4            := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_COUNTRY_CODE        := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_COUNTRY             := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_CITY                := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_POSTAL_CODE         := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_STATE               := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_PROVINCE            := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_COUNTY              := FND_API.G_MISS_CHAR;

	 l_qte_header_rec.END_CUSTOMER_PARTY_ID          := FND_API.G_MISS_NUM;
	 l_qte_header_rec.END_CUSTOMER_PARTY_SITE_ID     := FND_API.G_MISS_NUM;
	 l_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID   := FND_API.G_MISS_NUM;
	 l_qte_header_rec.END_CUSTOMER_CUST_PARTY_ID     := FND_API.G_MISS_NUM;

	 l_qte_header_rec.MARKETING_SOURCE_CODE_ID       := FND_API.G_MISS_NUM;
	 l_qte_header_rec.MARKETING_SOURCE_NAME          := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.MARKETING_SOURCE_CODE          := FND_API.G_MISS_CHAR;

	 /* commented for bug Bug 13064273
	 l_qte_header_rec.PRICE_LIST_ID                  := P_Qte_Header_Rec.PRICE_LIST_ID;
     l_qte_header_rec.CURRENCY_CODE                  := P_Qte_Header_Rec.CURRENCY_CODE;
	 */

         -- Check for Pricing Agreement
	 IF (l_qte_header_rec.contract_id IS NOT NULL AND
	     l_qte_header_rec.contract_id <> FND_API.G_MISS_NUM) THEN
             Open C_AGREEMENT(l_qte_header_rec.CONTRACT_ID,l_qte_header_rec.INVOICE_TO_CUST_ACCOUNT_ID);
	     Fetch C_AGREEMENT Into l_var;

	     If C_AGREEMENT%Found Then
	        l_qte_header_rec.CONTRACT_ID := FND_API.G_MISS_NUM;
	     End If;
	     Close C_AGREEMENT;
         End If;

	 /* Start : Code change done for Bug 13064273 */

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Update_Quote , Change Customer Flow - Price List defaulting starting', 1 , 'N' );
	    aso_debug_pub.ADD ( 'Update_Quote , Change Customer Flow - Agreement Id : '||l_qte_header_rec.CONTRACT_ID, 1 , 'N' );
	    aso_debug_pub.ADD ( 'Update_Quote , Change Customer Flow - Customer Account Id : '||l_qte_header_rec.CUST_ACCOUNT_ID, 1 , 'N' );
            aso_debug_pub.ADD ( 'Update_Quote , Change Customer Flow - Order Type Id : '||l_qte_header_rec.ORDER_TYPE_ID, 1 , 'N' );
         END IF;

         Open C_Agreement_PL(l_qte_header_rec.CONTRACT_ID);
         Fetch C_Agreement_PL Into l_qte_header_rec.PRICE_LIST_ID,l_qte_header_rec.CURRENCY_CODE;

	 If C_Agreement_PL%FOUND then

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.ADD ( 'Update_Quote , Change Customer Flow - Price List is defaulted based on Agreement', 1 , 'N' );
            END IF;

	 ElsIf C_Agreement_PL%NOTFOUND then

	    Open C_Customer_PL(l_qte_header_rec.CUST_ACCOUNT_ID);
            Fetch C_Customer_PL Into l_qte_header_rec.PRICE_LIST_ID,l_qte_header_rec.CURRENCY_CODE;

            If C_Customer_PL%FOUND then

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
	          aso_debug_pub.ADD ( 'Update_Quote , Change Customer Flow - Price List is defaulted based on Customer Account', 1 , 'N' );
               END IF;

	    ElsIf C_Customer_PL%NOTFOUND then

	       Open C_Order_Type_PL(l_qte_header_rec.ORDER_TYPE_ID);
	       Fetch C_Order_Type_PL Into l_qte_header_rec.PRICE_LIST_ID,l_qte_header_rec.CURRENCY_CODE;

               If C_Order_Type_PL%FOUND then
		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	             aso_debug_pub.ADD ( 'Update_Quote , Change Customer Flow - Price List is defaulted based on Order Type', 1 , 'N' );
                  END IF;
	       End If;
	       Close C_Order_Type_PL;

            End If;
	    Close C_Customer_PL;

         End If;
	 Close C_Agreement_PL;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Update_Quote , Change Customer Flow - l_qte_header_rec.PRICE_LIST_ID : '||l_qte_header_rec.PRICE_LIST_ID, 1 , 'N' );
	    aso_debug_pub.ADD ( 'Update_Quote , Change Customer Flow - l_qte_header_rec.CURRENCY_CODE : '||l_qte_header_rec.CURRENCY_CODE, 1 , 'N' );
         END IF;

	 /* End : Code change done for Bug 13064273 */

	 -- replaced Null with G_MISS in below assinments for Bug 24010778

	 l_shipment_tbl(1).SHIP_TO_CUST_ACCOUNT_ID       := P_Qte_Header_Rec.CUST_ACCOUNT_ID;
	 l_shipment_tbl(1).SHIP_TO_CUST_PARTY_ID         := P_Qte_Header_Rec.CUST_PARTY_ID;
	 l_shipment_tbl(1).SHIP_TO_PARTY_ID              := FND_API.G_MISS_NUM;
	 l_shipment_tbl(1).SHIP_TO_PARTY_SITE_ID         := P_Qte_Header_Rec.SOLD_TO_PARTY_SITE_ID;
	 l_shipment_tbl(1).SHIP_TO_PARTY_NAME            := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_CONTACT_FIRST_NAME    := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_CONTACT_MIDDLE_NAME   := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_CONTACT_LAST_NAME     := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_ADDRESS1              := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_ADDRESS2              := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_ADDRESS3              := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_ADDRESS4              := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_COUNTRY_CODE          := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_COUNTRY               := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_CITY                  := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_POSTAL_CODE           := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_STATE                 := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_PROVINCE              := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_TO_COUNTY                := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIP_METHOD_CODE              := FND_API.G_MISS_CHAR;
     l_shipment_tbl(1).FREIGHT_TERMS_CODE            := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).FOB_CODE                      := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).DEMAND_CLASS_CODE             := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).REQUEST_DATE_TYPE             := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).REQUEST_DATE                  := FND_API.G_MISS_DATE;
	 l_shipment_tbl(1).SHIPMENT_PRIORITY_CODE        := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).SHIPPING_INSTRUCTIONS         := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).PACKING_INSTRUCTIONS          := FND_API.G_MISS_CHAR;
	 l_shipment_tbl(1).OPERATION_CODE                := 'UPDATE';

	 aso_debug_pub.add('Update_Quote - Change Customer Flow , Profile ASO_API_ENABLE_SECURITY : ' ||FND_PROFILE.VALUE ('ASO_API_ENABLE_SECURITY' ),1,'Y');
	 aso_debug_pub.add('Update_Quote - Change Customer Flow , l_sales_team_prof : ' ||l_sales_team_prof,1,'Y');

	 If NVL ( FND_PROFILE.VALUE ('ASO_API_ENABLE_SECURITY' ), 'N' ) = 'Y' Then
            If (l_sales_team_prof = 'FULL' OR l_sales_team_prof = 'PARTIAL') Then

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.ADD ( 'Update_Quote - Change Customer Flow , Before calling ASO_SALES_TEAM_PVT.Assign_Sales_Team ' , 1 , 'N' );
                END IF;

		l_qte_header_rec.RESOURCE_ID     := FND_API.G_MISS_NUM;
        l_qte_header_rec.RESOURCE_GRP_ID := FND_API.G_MISS_NUM;

	        ASO_SALES_TEAM_PVT.Assign_Sales_Team (
                                   P_Init_Msg_List   => FND_API.G_FALSE,
                                   P_Commit          => FND_API.G_FALSE,
                                   p_Qte_Header_Rec  => l_qte_header_rec,
                                   P_Operation       => 'UPDATE',
                                   x_Qte_Header_Rec  => lx_qte_header_rec,
                                   x_return_status   => x_return_status,
                                   x_msg_count       => x_msg_count,
                                   x_msg_data        => x_msg_data );

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Update_Quote -  Change Customer Flow , After calling ASO_SALES_TEAM_PVT.Assign_Sales_Team , x_return_status: '||x_return_status, 1, 'N');
                END IF;

                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                l_qte_header_rec := lx_qte_header_rec;
	    End If;
	 End If;

	 If l_payment_tbl.Count > 0 Then
	    If l_payment_tbl(1).PAYMENT_TYPE_CODE In ('CHECK','CREDIT_CARD') Then
               If l_payment_tbl(1).PAYMENT_TYPE_CODE = 'CREDIT_CARD' Then
	          l_payment_tbl(1).CREDIT_CARD_CODE            := FND_API.G_MISS_CHAR;
	          l_payment_tbl(1).CREDIT_CARD_HOLDER_NAME     := FND_API.G_MISS_CHAR;
	          l_payment_tbl(1).CREDIT_CARD_EXPIRATION_DATE := FND_API.G_MISS_DATE;
	       End If;
	       l_payment_tbl(1).PAYMENT_TYPE_CODE  := FND_API.G_MISS_CHAR;
	       l_payment_tbl(1).PAYMENT_REF_NUMBER := FND_API.G_MISS_CHAR;
            End If;

            OPEN c_pay_term_acct(P_Qte_Header_Rec.CUST_ACCOUNT_ID);
            FETCH c_pay_term_acct INTO l_payment_tbl(1).PAYMENT_TERM_ID;
            close c_pay_term_acct;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.add('Update_Quote -  Change Customer Flow, l_payment_tbl(1).PAYMENT_TERM_ID : '||l_payment_tbl(1).PAYMENT_TERM_ID, 1, 'N');
	    END IF;

	    l_payment_tbl(1).CUST_PO_NUMBER  := FND_API.G_MISS_CHAR;
	    l_payment_tbl(1).cvv2            := FND_API.G_MISS_CHAR;
	    l_payment_tbl(1).OPERATION_CODE  := 'UPDATE';
	 End If;

	 If l_tax_detail_tbl.Count > 0 Then
	    If l_tax_detail_tbl(1).TAX_EXEMPT_FLAG = 'E' Then
	       l_tax_detail_tbl(1).TAX_EXEMPT_FLAG        := FND_API.G_MISS_CHAR;
	       l_tax_detail_tbl(1).TAX_EXEMPT_NUMBER      := FND_API.G_MISS_CHAR;
	       l_tax_detail_tbl(1).TAX_EXEMPT_REASON_CODE := FND_API.G_MISS_CHAR;
            End If;
	    l_tax_detail_tbl(1).OPERATION_CODE  := 'UPDATE';
	 End If;

         l_qte_header_rec.Customer_Name_And_Title := FND_API.G_MISS_CHAR;
         l_qte_header_rec.Customer_Signature_Date := FND_API.G_MISS_DATE;
         l_qte_header_rec.Supplier_Name_And_Title := FND_API.G_MISS_CHAR;
         l_qte_header_rec.Supplier_Signature_Date := FND_API.G_MISS_DATE;

         /*** Start : Code change done for Bug 11076978 ***/
	 -- hyang defaulting framework begin
	 IF l_control_rec.defaulting_fwk_flag = 'Y' THEN

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Quote - Before defaulting framework', 1, 'Y');
               aso_debug_pub.add('Update_Quote - Populate defaulting control record from the header control record', 1, 'Y');
            END IF ;

            l_def_control_rec.Dependency_Flag := l_control_rec.Dependency_Flag;
            l_def_control_rec.Defaulting_Flag := l_control_rec.Defaulting_Flag;
            l_def_control_rec.Application_Type_Code := l_control_rec.Application_Type_Code;
            l_def_control_rec.Defaulting_Flow_Code := 'UPDATE';
            l_def_control_rec.Last_Update_Date := P_Qte_Header_Rec.Last_Update_Date;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Defaulting_Fwk_Flag - '||l_control_rec.Defaulting_Fwk_Flag, 1, 'Y');
               aso_debug_pub.add('Dependency_Flag - '||l_def_control_rec.Dependency_Flag, 1, 'Y');
               aso_debug_pub.add('Defaulting_Flag - '||l_def_control_rec.Defaulting_Flag, 1, 'Y');
               aso_debug_pub.add('Application_Type_Code - '||l_def_control_rec.Application_Type_Code, 1, 'Y');
               aso_debug_pub.add('Defaulting_Flow_Code - '||l_def_control_rec.Defaulting_Flow_Code, 1, 'Y');
               aso_debug_pub.add('Last_Update_Date - '||l_def_control_rec.Last_Update_Date, 1, 'Y');
            END IF ;

            IF l_def_control_rec.application_type_code = 'QUOTING HTML'
               OR l_def_control_rec.application_type_code = 'QUOTING FORM' THEN
               l_db_object_name := G_QUOTE_HEADER_DB_NAME;
            ELSE
               l_control_rec.Defaulting_Fwk_Flag := 'N';
            END IF;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Quote - Pick '||l_db_object_name ||' based on calling application '||l_def_control_rec.application_type_code, 1, 'Y');
            END IF ;

            IF l_shipment_tbl.count > 0 THEN
               l_hd_shipment_rec := l_shipment_tbl(1);
            END IF;

            IF l_payment_tbl.count > 0 THEN
               l_hd_payment_rec := l_payment_tbl(1);
            END IF;

            IF l_tax_detail_tbl.count > 0 THEN
               l_hd_tax_detail_rec := l_tax_detail_tbl(1);
            END IF;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Quote - Change Customer Flow , Before Call to Default_Entity', 1, 'Y');
            END IF ;

            ASO_DEFAULTING_INT.Default_Entity (
                               p_api_version           =>  1.0
                             , p_control_rec           =>  l_def_control_rec
                             , p_database_object_name  =>  l_db_object_name
                             , p_quote_header_rec      =>  l_qte_header_rec
                             , p_header_misc_rec       =>  l_hd_misc_rec
                             , p_header_shipment_rec   =>  l_hd_shipment_rec
                             , p_header_payment_rec    =>  l_hd_payment_rec
                             , p_header_tax_detail_rec =>  l_hd_tax_detail_rec
                             , x_quote_header_rec      =>  lx_qte_header_rec    -- code change done for Bug 12874975
                             , x_header_misc_rec       =>  lx_hd_misc_rec
                             , x_header_shipment_rec   =>  lx_hd_shipment_rec
                             , x_header_payment_rec    =>  lx_hd_payment_rec
                             , x_header_tax_detail_rec =>  lx_hd_tax_detail_rec
                             , x_quote_line_rec        =>  lx_quote_line_rec
                             , x_line_misc_rec         =>  lx_ln_misc_rec
                             , x_line_shipment_rec     =>  lx_ln_shipment_rec
                             , x_line_payment_rec      =>  lx_ln_payment_rec
                             , x_line_tax_detail_rec   =>  lx_ln_tax_detail_rec
                             , x_changed_flag          =>  lx_changed_flag
                             , x_return_status	       =>  x_return_status
                             , x_msg_count	       =>  x_msg_count
                             , x_msg_data	       =>  x_msg_data);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Quote - Change Customer Flow , After Call to Default_Entity , x_return_status : '||x_return_status, 1, 'Y');
            END IF ;

	    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_DEFAULTING');
                  FND_MSG_PUB.ADD;
               END IF;

               IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

            END IF;

	    l_qte_header_rec := lx_qte_header_rec;  -- code change done for Bug 12874975

            IF Shipment_Null_Rec_Exists(lx_hd_shipment_rec, l_db_object_name) THEN
               l_hd_shipment_tbl(1) := lx_hd_shipment_rec;
            END IF;

            IF Payment_Null_Rec_Exists(lx_hd_payment_rec, l_db_object_name) THEN
               l_hd_payment_tbl(1) := lx_hd_payment_rec;
            END IF;

            IF Tax_Detail_Null_Rec_Exists(lx_hd_tax_detail_rec, l_db_object_name) THEN
               l_hd_tax_detail_tbl(1) := lx_hd_tax_detail_rec;
            END IF;

         ELSE
	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Update_Quote - Change Customer Flow , l_control_rec.defaulting_fwk_flag : N', 1, 'Y');
             END IF ;

             l_hd_shipment_tbl   := l_shipment_tbl;
             l_hd_payment_tbl    := l_payment_tbl;
             l_hd_tax_detail_tbl := l_tax_detail_tbl;

         END IF;
         -- hyang defaulting framework end
	/*** End : Code change done for Bug 11076978 ***/

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Update_Quote: Before call to aso_input_param_debug.print_quote_input procedure for change customer flow', 1, 'Y');

            ASO_INPUT_PARAM_DEBUG.Print_quote_input(
                       P_Quote_Header_Rec            => l_qte_header_rec
                     , P_hd_Price_Attributes_Tbl     => ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl
                     , P_hd_Payment_Tbl              => l_hd_payment_tbl
                     , P_hd_Shipment_tbl             => l_hd_shipment_tbl
                     , P_hd_Tax_Detail_Tbl           => l_hd_tax_detail_tbl
                     , P_hd_Sales_Credit_Tbl         => ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl
                     , P_Qte_Line_Tbl                => ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL
                     , P_Qte_Line_Dtl_Tbl            => ASO_QUOTE_PUB.G_MISS_Qte_Line_Dtl_TBL
                     , P_Price_Adjustment_Tbl        => ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl
                     , P_Ln_Price_Attributes_Tbl     => ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl
                     , P_Ln_Payment_Tbl              => ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL
                     , P_Ln_Shipment_Tbl             => ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL
                     , P_Ln_Tax_Detail_Tbl           => ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl
                     , P_ln_Sales_Credit_Tbl         => ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl
                     , P_Qte_Access_Tbl              => ASO_QUOTE_PUB.G_MISS_QTE_ACCESS_TBL);

            aso_debug_pub.add('Update_Quote: After call to aso_input_param_debug.print_quote_input procedure for change customer flow', 1, 'Y');
	 END IF;
     End If;
     /* Code change for Quoting Usability Sun ER End */

    If P_Qte_Header_Rec.quote_number Is Not Null And P_Qte_Header_Rec.quote_number <> FND_API.G_MISS_NUM Then -- code change done for Bug 17758573

      OPEN c_qte_status (l_qte_status_id);
      FETCH C_qte_status INTO l_auto_version;
      CLOSE c_qte_status;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('Update_Quote - auto_version: '||l_auto_version, 1, 'N');
	 END IF;

      -- auto version check should be done only if the control rec is set

      IF NVL(l_auto_version, 'Y') = 'Y' AND p_control_rec.auto_version_flag = FND_API.G_TRUE THEN

	     OPEN C_Qte_Version(l_qte_number);
	     FETCH C_Qte_Version into l_qte_header_rec.quote_version;
	     CLOSE C_Qte_Version;

	     l_qte_header_rec.quote_version := nvl(l_qte_header_rec.quote_version, 0) + 1;

      ELSE
          l_auto_version := 'N';

      END IF;

    End if;

      IF l_control_rec.defaulting_fwk_flag = 'N' THEN

          /* Updating of Order type */
          IF aso_debug_pub.g_debug_flag = 'Y' THEN
	         aso_debug_pub.add('Update_Quote - p_qte_header_rec.order_type_id '||p_qte_header_rec.order_type_id, 1, 'N');

	       -- Change START
               -- Release 12 MOAC Changes : Bug 4500739
               -- Changes Done by : Girish
               -- Comments : Using HR EIT in place of org striped profile

               -- aso_debug_pub.add('Update_Quote - Value of Order Type Profile'||to_number(fnd_profile.value('ASO_ORDER_TYPE_ID')), 1, 'N');
	       aso_debug_pub.add('Update_Quote - Value of Order Type Profile'||to_number(ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_ORDER_TYPE)), 1, 'N');

	       -- Change END

              aso_debug_pub.add('Update_Quote - order_type_id from database '||l_order_type_id, 1, 'N');
	     END IF;

          IF  p_qte_header_rec.order_type_id is null OR p_qte_header_rec.order_type_id = FND_API.G_MISS_NUM THEN
               IF l_order_type_id is NULL OR l_order_type_id = FND_API.G_MISS_NUM THEN

	           -- Change START
                   -- Release 12 MOAC Changes : Bug 4500739
                   -- Changes Done by : Girish
                   -- Comments : Using HR EIT in place of org striped profile

                   --l_qte_header_rec.order_type_id := to_number(fnd_profile.value('ASO_ORDER_TYPE_ID'));
		   l_qte_header_rec.order_type_id := to_number(ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_ORDER_TYPE));

		   -- Change END

               END IF;
          END IF;

      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote - l_qte_header_rec.publish_flag '||l_qte_header_rec.publish_flag, 1, 'N');
      END IF;

      IF l_qte_header_rec.publish_flag = 'Y' THEN

          -- check for missing customer accounts in the quote
          ASO_CHECK_TCA_PVT.Check_Customer_Accounts (
                        p_init_msg_list        => fnd_api.g_false,
                        p_qte_header_id        => l_qte_header_rec.quote_header_id,
                        x_return_status        => x_return_status,
                        x_msg_count            => x_msg_count,
                        x_msg_data             => x_msg_data );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Update_Quote - chk_cust_accts: x_return_status: '||x_return_status, 1, 'N');
          END IF;

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF; -- end check_customer_accounts

          -- assign the missing customer accounts to the quote
          ASO_CHECK_TCA_PVT.Assign_Customer_Accounts (
                        p_init_msg_list        => fnd_api.g_false,
                        p_qte_header_id        => l_qte_header_rec.quote_header_id,
                        p_calling_api_flag     => 1,
                        x_return_status        => x_return_status,
                        x_msg_count            => x_msg_count,
                        x_msg_data             => x_msg_data );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Update_Quote - assign_cust_accts: x_return_status: '||x_return_status, 1, 'N');
          END IF;

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

      END IF;  --l_qte_header_rec.publish_flag = 'Y' THEN


      IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN

	       -- party_id must exist and be active in HZ_PARTIES
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.add('Update_Quote - before validate_party: ', 1, 'N');
	       END IF;

	       ASO_VALIDATE_PVT.Validate_Party (
		              p_init_msg_list	       => FND_API.G_FALSE,
		              p_party_id	            => l_qte_header_rec.party_id,
		              p_party_usage	       => 'QUOTE_PARTY',
		              x_return_status        => x_return_status,
		              x_msg_count	       => x_msg_count,
		              x_msg_data	            => x_msg_data);

	       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	               FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                    FND_MESSAGE.Set_Token('COLUMN', 'PARTY_ID', FALSE);
                    FND_MSG_PUB.ADD;
	           END IF;
	           RAISE FND_API.G_EXC_ERROR;

	       END IF;

	       -- org_contact_id must be exist and active in HZ_ORG_CONTACTS
	       ASO_VALIDATE_PVT.Validate_Contact (
		              p_init_msg_list	       => FND_API.G_FALSE,
		              p_contact_id	       => l_qte_header_rec.org_contact_id,
		              p_contact_usage	       => 'ORG_CONTACT',
		              x_return_status        => x_return_status,
		              x_msg_count	       => x_msg_count,
		              x_msg_data	            => x_msg_data);

	       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	               FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                    FND_MESSAGE.Set_Token('COLUMN', 'ORG_CONTACT_ID', FALSE);
                    FND_MSG_PUB.ADD;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

	       -- invoice_to_party_id must exist and be active in HZ_PARTIES and have the usage INVOICE.

	       ASO_VALIDATE_PVT.Validate_Party (
		              p_init_msg_list	       => FND_API.G_FALSE,
		              p_party_id	            => l_qte_header_rec.invoice_to_party_id,
		              p_party_usage	       => 'INVOICE_TO_PARTY',
		              x_return_status        => x_return_status,
		              x_msg_count	       => x_msg_count,
		              x_msg_data	            => x_msg_data);

	       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	               FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                    FND_MESSAGE.Set_Token('COLUMN', 'INVOICE_TO_PARTY_ID', FALSE);
                    FND_MSG_PUB.ADD;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

	       IF l_qte_header_rec.cust_account_id <> FND_API.G_MISS_NUM  OR  l_qte_header_rec.party_id <> FND_API.G_MISS_NUM THEN

	           IF l_qte_header_rec.cust_account_id <> FND_API.G_MISS_NUM THEN
		          l_cust_account_id := l_qte_header_rec.cust_account_id;
	           END IF;

	           IF l_qte_header_rec.party_id <> FND_API.G_MISS_NUM THEN
				l_party_id := l_qte_header_rec.party_id;
	           END IF;

	           ASO_PARTY_INT.Validate_CustAccount (
		              p_init_msg_list	       => FND_API.G_FALSE,
                        p_party_id	            => l_party_id,
                        p_cust_account_id      => l_cust_account_id,
                        x_return_status        => x_return_status,
                        x_msg_count	       => x_msg_count,
                        x_msg_data	            => x_msg_data );

            END IF;

	       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	           RAISE FND_API.G_EXC_ERROR;
	       END IF;


/*** Start BugNo 8647883: R12.1.2 Service reference SUN ER ***/

-- Checking if lines table has service reference CUSTOMER_PRODUCT,PRODUCT_CATALOG

      SELECT count(*)
      INTO ls_count
      FROM aso_quote_line_details a1,
	aso_quote_lines_all a2
      WHERE a2.quote_header_id = l_qte_header_rec.quote_header_id
	AND a1.quote_line_id       = a2.quote_line_id
	AND SERVICE_REF_TYPE_CODE IN ('CUSTOMER_PRODUCT','PRODUCT_CATALOG');

IF ls_count > 0 then
     -- Fetching the value from DB for end customer and sold to for validation
     OPEN C_get_cust(l_qte_header_rec.quote_header_id);
     FETCH C_get_cust INTO ls_end_cust_account_id,ls_cust_account_id;
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_QUOTE_HEADERS_PVT UPDATE_QUOTE: header_id'||l_qte_header_rec.quote_header_id);
	aso_debug_pub.add('ASO_QUOTE_HEADERS_PVT UPDATE_QUOTE:  cust Acct id'||ls_cust_account_id);
	aso_debug_pub.add('ASO_QUOTE_HEADERS_PVT UPDATE_QUOTE: end cust Acct id'||ls_end_cust_account_id);
	aso_debug_pub.add('ASO_QUOTE_HEADERS_PVT UPDATE_QUOTE: record end cust Acct id'||p_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID);
	aso_debug_pub.add('ASO_QUOTE_HEADERS_PVT UPDATE_QUOTE: record end LAST_UPDATED_BY'||p_qte_header_rec.LAST_UPDATED_BY);
     END IF;
     IF C_get_cust%NOTFOUND THEN
        IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_QUOTE_HEADERS_PVT END CUST NOT FOUND');
	END IF;
	ls_cust_account_id := NULL;
	ls_end_cust_account_id:= NULL;
     END IF;
     CLOSE C_get_cust;


-- Fetching the value from record structure of end customer for validation
     ls_ib_cust_account_id:=NULL;
     ls_ib_cust_account_id_orig:=NULL;
     ls_pc_cust_account_id:=NULL;
     ls_pc_cust_account_id_orig:=NULL;

 IF ( (p_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID is NULL) or ((p_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID=FND_API.G_MISS_NUM) and (p_qte_header_rec.LAST_UPDATED_BY <> FND_API.G_MISS_NUM)) ) -- end customer is cleared
   OR
   ((p_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID is NOT NULL ) and (p_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID <> FND_API.G_MISS_NUM)) -- end customer is changed

   THEN
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('UPDATE_QUOTE: End customer is changed');
    END IF;

    IF (p_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID is NULL) or (p_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID=FND_API.G_MISS_NUM) -- Fetching sold to
    THEN
        ls_ib_cust_account_id:=NULL;
        IF p_qte_header_rec.CUST_ACCOUNT_ID <> FND_API.G_MISS_NUM THEN
          ls_pc_cust_account_id := p_qte_header_rec.CUST_ACCOUNT_ID;
        ELSE
          ls_pc_cust_account_id := ls_cust_account_id;
        END IF;
    ELSE -- Fetching end customer
       ls_ib_cust_account_id := p_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID;
       ls_pc_cust_account_id :=  ls_ib_cust_account_id;
    END IF;

    ls_pc_cust_account_id_orig := nvl(ls_end_cust_account_id, ls_cust_account_id);  -- DB value of cust account, in case end customer is null use sold to customer
    ls_ib_cust_account_id_orig:= ls_end_cust_account_id;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('UPDATE_QUOTE: new ib cust: '|| ls_ib_cust_account_id);
      aso_debug_pub.add('UPDATE_QUOTE: original ib cust: '|| ls_ib_cust_account_id_orig);
       aso_debug_pub.add('UPDATE_QUOTE: new pc cust: '|| ls_pc_cust_account_id);
      aso_debug_pub.add('UPDATE_QUOTE: original pc cust: '|| ls_pc_cust_account_id_orig);
    END IF;
 END IF;

-- Install base validation
-- Deleting the lines in case end customer is changed or cleared
 IF (ls_ib_cust_account_id is not NULL and ls_ib_cust_account_id_orig is not NULL and ls_ib_cust_account_id <> ls_ib_cust_account_id_orig )
         or (ls_ib_cust_account_id is null and ls_ib_cust_account_id_orig is not NULL)
         or (ls_ib_cust_account_id is not NULL and ls_ib_cust_account_id_orig is NULL)

  THEN
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('UPDATE_QUOTE:install base validation');

        END IF;
        for c1 in c_serv(l_qte_header_rec.quote_header_id)
           loop
     	     IF (c1.SERVICE_REF_TYPE_CODE = 'CUSTOMER_PRODUCT' ) THEN
                found:=0;
		FOR i IN 1..ls_qte_line_tbl.count LOOP
                 if ls_qte_line_tbl(i).quote_line_id=c1.quote_line_id and
		 ((ls_qte_line_tbl(i).END_CUSTOMER_CUST_ACCOUNT_ID = FND_API.G_MISS_NUM) or (ls_qte_line_tbl(i).END_CUSTOMER_CUST_ACCOUNT_ID is null)) then
		 -- end customer is not there at line level
			    ls_qte_line_tbl(i).operation_code:='DELETE';
		            exit;
			    found:=1;
	          END IF;
		end loop;
		 IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('UPDATE_QUOTE:install base validation found'||found);

                 END IF;
		if found=0 then
                  l_qte_line_rec := aso_quote_pub.g_miss_qte_line_rec;
 	          l_qte_line_rec:=ASO_UTILITY_PVT.Query_Qte_Line_Row(c1.quote_line_id);
		  if (l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID = FND_API.G_MISS_NUM) or (l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID is null) then
			l_qte_line_rec.operation_code:='DELETE';
			ls_qte_line_tbl(ls_qte_line_tbl.count+1):=l_qte_line_rec;
                  end if;
		end if;
            END IF; -- customer product
         end loop;
    END IF;



-- Product Catalog validation
 -- Validating the lines as per service rules and deleting in case service validation fails for end customer
   --   IF (ls_cust_account_id is not null) or (ls_end_cust_account_id is not null )THEN
    IF ((ls_pc_cust_account_id is not NULL) and (ls_pc_cust_account_id_orig is not NULL) and (ls_pc_cust_account_id <> ls_pc_cust_account_id_orig ) )
         or (ls_pc_cust_account_id is null and ls_pc_cust_account_id_orig is not NULL)
         or (ls_pc_cust_account_id is not NULL and ls_pc_cust_account_id_orig is NULL)
    then
         for c1 in c_serv(l_qte_header_rec.quote_header_id)
           loop
     	     IF (c1.SERVICE_REF_TYPE_CODE = 'PRODUCT_CATALOG' ) THEN
               l_inventory_item_id:= c1.SERVICE_REF_LINE_ID;
	       ls_service_inventory_item_id:=c1.inventory_item_id;


	       IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('UPDATE_QUOTE:SERVICE_REF_TYPE_CODE '||c1.SERVICE_REF_TYPE_CODE);
			aso_debug_pub.add('UPDATE_QUOTE: PRODUCT_CATALOG service ref line id'||c1.SERVICE_REF_LINE_ID, 1, 'Y');
			aso_debug_pub.add('UPDATE_QUOTE: PRODUCT_CATALOG Servicable product'||l_inventory_item_id, 1, 'Y');
			aso_debug_pub.add('UPDATE_QUOTE: PRODUCT_CATALOG service item id'||ls_service_inventory_item_id, 1, 'Y');
			aso_debug_pub.add('UPDATE_QUOTE: PRODUCT_CATALOG DB customer id'||ls_cust_account_id, 1, 'Y');
			aso_debug_pub.add('UPDATE_QUOTE: PRODUCT_CATALOG DB end customer id'||ls_end_cust_account_id, 1, 'Y');
			aso_debug_pub.add('UPDATE_QUOTE: PRODUCT_CATALOG record structure end customer id'||ls_pc_cust_account_id, 1, 'Y');
               END IF;

	       l_check_service_rec.product_item_id := l_inventory_item_id;
	       l_check_service_rec.service_item_id := c1.inventory_item_id;
	       l_check_service_rec.customer_id :=  ls_pc_cust_account_id; --nvl(ls_end_cust_account_id,ls_cust_account_id);
	       ASO_SERVICE_CONTRACTS_INT.Is_Service_Available(
        					P_Api_Version_Number	=> 1.0 ,
        					P_init_msg_list	=> p_init_msg_list,
						X_msg_Count     => X_msg_count ,
        					X_msg_Data	=> X_msg_data	 ,
        					X_Return_Status	=> X_return_status  ,
						p_check_service_rec => l_check_service_rec,
						X_Available_YN	    => l_Available_YN
					       );
	      IF l_Available_YN = 'N' THEN
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('UPDATE_QUOTE:SERVICE_not available');
		END IF;

		found:=0;
		FOR i IN 1..ls_qte_line_tbl.count LOOP
                 if ls_qte_line_tbl(i).quote_line_id=c1.quote_line_id and
		 ((ls_qte_line_tbl(i).END_CUSTOMER_CUST_ACCOUNT_ID = FND_API.G_MISS_NUM) or (ls_qte_line_tbl(i).END_CUSTOMER_CUST_ACCOUNT_ID is null)) then
		 -- end customer is not there at line level
			    ls_qte_line_tbl(i).operation_code:='DELETE';
		            exit;
			    found:=1;
	          END IF;
		end loop;
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('UPDATE_QUOTE:product base validation found'||found);

                 END IF;
		if found=0 then
                  l_qte_line_rec := aso_quote_pub.g_miss_qte_line_rec;
 	          l_qte_line_rec:=ASO_UTILITY_PVT.Query_Qte_Line_Row(c1.quote_line_id);
                  if (l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID = FND_API.G_MISS_NUM) or (l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID is null) then
			l_qte_line_rec.operation_code:='DELETE';
			ls_qte_line_tbl(ls_qte_line_tbl.count+1):=l_qte_line_rec;
                  end if;
		end if;
	      END IF;  -- service not available
         END IF;  -- Product Catalog
     END LOOP; -- c_serv
   END IF; -- customer id not null

 END IF; -- ls_count greater than 0

/*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/

/** Start Code fix for bug 13597269 **/
if  p_qte_header_rec.product_fisc_classification = FND_API.G_MISS_CHAR then
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('rassharm UPDATE_QUOTE:product_fisc_classification not modified');
	aso_debug_pub.add('rassharm UPDATE_QUOTE:product_fisc_classification from DB'||l_prod_fisc_class);
   END IF;
       l_qte_header_rec.product_fisc_classification:=l_prod_fisc_class;
  end if ;

if  p_qte_header_rec.trx_business_category = FND_API.G_MISS_CHAR then
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('rassharm UPDATE_QUOTE:trx_business_category not modified');
	aso_debug_pub.add('rassharm UPDATE_QUOTE:trx_business_category from DB'||l_trx_business_category);

   END IF;
          l_qte_header_rec.trx_business_category:=l_trx_business_category;
  end if ;
/** End Code fix for bug 13597269 **/


	       -- order_type must exist and be active in OE_ORDER_TYPES

            ASO_TRADEIN_PVT.OrderType(
                        p_init_msg_list        => FND_API.G_FALSE,
                        p_qte_header_rec       => l_qte_header_rec,
                        x_return_status        => x_return_status,
                        x_msg_count            => x_msg_count,
                        x_msg_data             => x_msg_data);

	       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	           RAISE FND_API.G_EXC_ERROR;
	       END IF;

            /*** Code for cursor C_Expire_Date and If condition added for Bug 13926015 ***/

	    Open C_Expire_Date(p_qte_header_rec.quote_header_id);
	    Fetch C_Expire_Date Into l_Expire_Date;
	    Close C_Expire_Date;

	    -- If l_Expire_Date <> to_char(p_qte_header_rec.quote_expiration_date,'DD-MON-RRRR') Then    ,commented for bug 14099184
	    If TRUNC(l_Expire_Date) <> TRUNC(p_qte_header_rec.quote_expiration_date) Then

	       ASO_VALIDATE_PVT.Validate_Quote_Exp_date(
                            p_init_msg_list         => FND_API.G_FALSE,
                            p_quote_expiration_date => l_qte_header_rec.quote_expiration_date,
                            x_return_status         => x_return_status,
                            x_msg_count             => x_msg_count,
                            x_msg_data              => x_msg_data);

               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.Set_Name('ASO', 'ASO_API_UPD_EXPIRATION_DATE');
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

            End If;

	       -- price list must exist and be active in OE_PRICE_LISTS
	       ASO_VALIDATE_PVT.Validate_PriceList (
		              p_init_msg_list	        => FND_API.G_FALSE,
		              p_price_list_id	        => l_qte_header_rec.price_list_id,
		              x_return_status         => x_return_status,
		              x_msg_count	        => x_msg_count,
		              x_msg_data	             => x_msg_data);

	       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	               FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                    FND_MESSAGE.Set_Token('COLUMN', 'PRICE_LIST_ID', FALSE);
                    FND_MSG_PUB.ADD;
	           END IF;
	           RAISE FND_API.G_EXC_ERROR;
            END IF;

            ASO_VALIDATE_PVT.Validate_Quote_Price_Exp(
  	                   p_init_msg_list	        => FND_API.G_FALSE,
                        p_price_list_id	        => l_qte_header_rec.price_list_id,
                        p_quote_expiration_date => l_qte_header_rec.quote_expiration_date,
                        x_return_status         => x_return_status,
	                   x_msg_count             => x_msg_count,
	                   x_msg_data	             => x_msg_data);

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                     FND_MESSAGE.Set_Token('COLUMN', 'Price List Expires Before Quote', FALSE);
                     FND_MSG_PUB.ADD;
                 END IF;
                 RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- if status is to be changed, a valid transition should exist.
            IF (l_qte_header_rec.quote_status_id IS NOT NULL
                AND l_qte_header_rec.quote_status_id <> FND_API.G_MISS_NUM
                AND l_qte_header_rec.quote_status_id <> l_qte_status_id) THEN

  	             ASO_VALIDATE_PVT.Validate_Status_Transition(
    		                    p_init_msg_list	=> FND_API.G_FALSE,
    		                    p_source_status_id  => l_qte_status_id,
    		                    p_dest_status_id    => l_qte_header_rec.quote_status_id,
    		                    x_return_status     => x_return_status,
    		                    x_msg_count	     => x_msg_count,
    		                    x_msg_data	     => x_msg_data);

  	             IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  	                     FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_STATUS_TRANS');
                          FND_MSG_PUB.ADD;
  	                 END IF;
 	                 RAISE FND_API.G_EXC_ERROR;
  	             END IF;
  	       END IF;


            FOR i in 1..p_hd_sales_credit_tbl.count LOOP

                if aso_debug_pub.g_debug_flag = 'Y' then
                    aso_debug_pub.add('p_hd_sales_credit_tbl('||i||').operation_code: '|| p_hd_sales_credit_tbl(i).operation_code,1,'Y');
                end if;

                if (p_hd_sales_credit_tbl(i).operation_code = 'CREATE' or p_hd_sales_credit_tbl(i).operation_code = 'UPDATE') then

                    ASO_VALIDATE_PVT.Validate_Resource_id(
                                p_init_msg_list => FND_API.G_FALSE,
                                p_resource_id   => p_hd_sales_credit_tbl(i).resource_id  ,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data);

                    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		                  FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_SALES_REP_ID');
		                  FND_MSG_PUB.ADD;
	                   END IF;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;


                    ASO_VALIDATE_PVT.Validate_Resource_group_id(
                                p_init_msg_list     => FND_API.G_FALSE,
                                p_resource_group_id => p_hd_sales_credit_tbl(i).resource_group_id,
                                x_return_status     => x_return_status,
                                x_msg_count         => x_msg_count,
                                x_msg_data          => x_msg_data);

                    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;


                    ASO_VALIDATE_PVT.Validate_Salescredit_Type(
                                p_init_msg_list       => FND_API.G_FALSE,
                                p_salescredit_type_id => p_hd_sales_credit_tbl(i).sales_credit_type_id,
                                x_return_status       => x_return_status,
                                x_msg_count           => x_msg_count,
                                x_msg_data            => x_msg_data);

                    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;


                    ASO_VALIDATE_PVT.Validate_EmployPerson(
                                p_init_msg_list => FND_API.G_FALSE,
                                p_employee_id   => p_hd_sales_credit_tbl(i).employee_person_id,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data);

                    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;

                end if;

            END LOOP;

            FOR i in 1..p_hd_quote_party_tbl.count LOOP

                ASO_VALIDATE_PVT.Validate_Party_Type(
				        p_init_msg_list => FND_API.G_FALSE,
                            p_party_type    => p_hd_quote_party_tbl(i).party_type,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data);

                IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                ASO_VALIDATE_PVT.Validate_Party(
                            p_init_msg_list => FND_API.G_FALSE,
                            p_party_id      => p_hd_quote_party_tbl(i).party_id,
                            p_party_usage   => null,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data);

                IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                ASO_VALIDATE_PVT.Validate_Party_Object_Type(
                            p_init_msg_list	  => FND_API.G_FALSE,
                            p_party_object_type => p_hd_quote_party_tbl(i).party_object_type,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data);

                IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END LOOP;

            IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN

                IF l_hd_Shipment_tbl.count > 0 THEN
                    l_shipment_rec := l_hd_Shipment_tbl(1);
                END IF;

                ASO_VALIDATE_PVT.Validate_item_tca_bsc(
	                       p_init_msg_list	   => FND_API.G_FALSE,
                            p_qte_header_rec   => l_qte_header_rec,
                            p_shipment_rec     =>   l_shipment_rec,
                            p_operation_code   =>   'UPDATE',
                            p_application_type_code   =>   l_control_rec.application_type_code,
                            x_return_status	   => x_return_status,
                            x_msg_count		=> x_msg_count,
                            x_msg_data		=> 	x_msg_data);

                IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

      END IF;

      IF p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_INTER_RECORD THEN

          IF l_qte_header_rec.currency_code IS NULL THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
                  FND_MESSAGE.Set_Token('COLUMN', 'CURRENCY_CODE', FALSE);
                  FND_MSG_PUB.ADD;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

	     -- tax_exempt_flag must be in 'E', 'R' and 'S'
	     -- and tax_exempt_reason_code must exist if tax_exempt_flag is 'E'.

          FOR i IN 1..l_hd_tax_detail_tbl.count LOOP

              ASO_VALIDATE_PVT.Validate_Tax_Exemption (
                          p_init_msg_list	      => FND_API.G_FALSE,
                          p_tax_exempt_flag	      => l_hd_tax_detail_tbl(i).tax_exempt_flag,
                          p_tax_exempt_reason_code => l_hd_tax_detail_tbl(i).tax_exempt_reason_code,
                          x_return_status          => x_return_status,
                          x_msg_count	           => x_msg_count,
                          x_msg_data	           => x_msg_data);

              IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                      FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
                      FND_MESSAGE.Set_Token('COLUMN', 'TAX_EXEMPT_REASON', FALSE);
                      FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

          END LOOP;

          FOR i IN 1..p_ln_tax_detail_tbl.count LOOP

              ASO_VALIDATE_PVT.Validate_Tax_Exemption (
                          p_init_msg_list	      => FND_API.G_FALSE,
                          p_tax_exempt_flag	      => p_ln_tax_detail_tbl(i).tax_exempt_flag,
                          p_tax_exempt_reason_code => p_ln_tax_detail_tbl(i).tax_exempt_reason_code,
                          x_return_status          => x_return_status,
                          x_msg_count	           => x_msg_count,
                          x_msg_data	           => x_msg_data);

              IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                      FND_MESSAGE.Set_Name('ASO', 'API_MISSING_COLUMN');
                      FND_MESSAGE.Set_Token('COLUMN', 'TAX_EXEMPT_REASON', FALSE);
                      FND_MSG_PUB.ADD;
                  END IF;

                  RAISE FND_API.G_EXC_ERROR;
              END IF;

          END LOOP;

          FOR i in 1..p_hd_quote_party_tbl.count LOOP

              ASO_VALIDATE_PVT.Validate_Party_Object_Id(
                          p_init_msg_list     => FND_API.G_FALSE,
                          p_party_id          => p_hd_quote_party_tbl(i).party_id,
                          p_party_object_type => p_hd_quote_party_tbl(i).party_object_type,
                          p_party_object_id   => p_hd_quote_party_tbl(i).party_object_id,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count,
                          x_msg_data          => x_msg_data);

              IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                      FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
                      FND_MESSAGE.Set_Token('INFO', 'PARTY OBJECT ID', FALSE);
                      FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

          END LOOP;


          IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN

               IF l_hd_Shipment_tbl.count > 0 THEN
                   l_shipment_rec := l_hd_Shipment_tbl(1);
               END IF;

               ASO_VALIDATE_PVT.Validate_record_tca_crs(
                           p_init_msg_list	=> FND_API.G_FALSE,
                           p_qte_header_rec  => l_qte_header_rec,
                           p_shipment_rec    => l_shipment_rec,
                           p_operation_code  => 'UPDATE',
                           p_application_type_code  => l_control_rec.application_type_code,
                           x_return_status	=> x_return_status,
                           x_msg_count		=> x_msg_count,
                           x_msg_data		=> x_msg_data);

               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
               END IF;
          END IF;

      END IF;

      IF l_hd_payment_tbl.count > 0 THEN

          FOR payment_rec IN c_payment_rec LOOP
               l_payment_db_tbl(payment_rec.payment_id) := payment_rec.payment_option;
          END LOOP;

          FOR i IN 1..l_hd_payment_tbl.count LOOP

              IF l_hd_payment_tbl(i).operation_code = 'CREATE' THEN

                  l_payment_db_tbl(NVL(l_payment_db_tbl.last, 0)+1) := l_hd_payment_tbl(i).payment_option;

              ELSIF l_hd_payment_tbl(i).operation_code = 'UPDATE' THEN

                  IF l_hd_payment_tbl(i).payment_id <> FND_API.G_MISS_NUM AND
                      l_payment_db_tbl.exists(l_hd_payment_tbl(i).payment_id) AND
                      l_hd_payment_tbl(i).payment_option <> FND_API.G_MISS_CHAR THEN

                         l_payment_db_tbl(l_hd_payment_tbl(i).payment_id) := l_hd_payment_tbl(i).payment_option;
                  END IF;

              ELSIF l_hd_payment_tbl(i).operation_code = 'DELETE' THEN

                  IF l_hd_payment_tbl(i).payment_id <> FND_API.G_MISS_NUM AND
                      l_payment_db_tbl.exists(l_hd_payment_tbl(i).payment_id) THEN

                        l_payment_db_tbl.DELETE(l_hd_payment_tbl(i).payment_id);
                  END IF;

              END IF;

          END LOOP;

          IF (FND_PROFILE.Value('ASO_ENABLE_SPLIT_PAYMENT') = 'N') THEN

        	     IF l_hd_payment_tbl.count > 1 THEN

                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		    	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_SPLIT_PAYMENT');
		    	        FND_MSG_PUB.ADD;
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;

               ELSIF l_hd_payment_tbl.count = 1 THEN

                   IF l_hd_payment_tbl(1).payment_option = 'SPLIT' THEN

                       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			            FND_MESSAGE.Set_Name('ASO', 'ASO_API_TOO_MANY_PAYMENTS');
			            FND_MSG_PUB.ADD;
		             END IF;
		             RAISE FND_API.G_EXC_ERROR;
                   END IF;

               END IF;-- l_payment_db_tbl

          END IF;-- FND_PROFILE.Value


          IF (FND_PROFILE.Value('ASO_ENABLE_SPLIT_PAYMENT') = 'Y') THEN

               IF l_hd_payment_tbl.count > 1 THEN

	              l_index := l_payment_db_tbl.first;

                   WHILE l_index IS NOT NULL LOOP

                        IF l_payment_db_tbl(l_index) <> 'SPLIT' THEN

		                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			                 FND_MESSAGE.Set_Name('ASO', 'ASO_API_TOO_MANY_PAYMENTS');
			                 FND_MSG_PUB.ADD;
		                  END IF;
		                  RAISE FND_API.G_EXC_ERROR;
		              END IF;
		              l_index := l_payment_db_tbl.next(l_index);
	              END LOOP;

	          END IF;
          END IF; ---- FND_PROFILE.Value

	 END IF;


      IF l_hd_shipment_tbl.count > 0 THEN

          FOR shipment_rec IN c_shipment_rec LOOP
	         l_shipment_db_tbl(shipment_rec.shipment_id) := NULL;
	     END LOOP;

	     FOR i IN 1..l_hd_shipment_tbl.count LOOP

               IF l_hd_shipment_tbl(i).operation_code = 'CREATE' THEN

                   l_shipment_db_tbl(NVL(l_shipment_db_tbl.last,0)+1) := NULL;
               ELSIF l_hd_shipment_tbl(i).operation_code = 'DELETE' THEN

                   IF l_hd_shipment_tbl(i).shipment_id <> FND_API.G_MISS_NUM AND
                      l_shipment_db_tbl.exists(l_hd_shipment_tbl(i).shipment_id) THEN

                       l_shipment_db_tbl.DELETE(l_hd_shipment_tbl(i).shipment_id);
                   END IF;
               END IF;

	     END LOOP;

	     IF l_shipment_db_tbl.count > 1 THEN

		    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			   FND_MESSAGE.Set_Name('ASO', 'ASO_API_TOO_MANY_SHIPMENTS');
			   FND_MSG_PUB.ADD;
		    END IF;
		    RAISE FND_API.G_EXC_ERROR;
	     END IF;

	 END IF;

	 --   Validate Tax; ( there should be only one rec having NOT NULL orig_tax_code)
	 IF l_hd_tax_detail_tbl.count > 0 THEN

          FOR tax_rec IN c_tax_rec LOOP
              l_tax_db_tbl(tax_rec.tax_detail_id) := NULL;
          END LOOP;

          FOR i IN 1..l_hd_tax_detail_tbl.count LOOP

               IF l_hd_tax_detail_tbl(i).operation_code ='CREATE' THEN

                       l_tax_db_tbl(NVL(l_tax_db_tbl.last,0)+1) := NULL;

               ELSIF l_hd_tax_detail_tbl(i).operation_code ='DELETE' AND
                     l_hd_tax_detail_tbl(i).tax_detail_id <> FND_API.G_MISS_NUM AND
                     l_tax_db_tbl.exists(l_hd_tax_detail_tbl(i).tax_detail_id) THEN

                       l_tax_db_tbl.delete(l_hd_tax_detail_tbl(i).tax_detail_id);
               END IF;

          END LOOP;

	     IF l_tax_db_tbl.count > 1 THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'ASO_API_TOO_MANY_TAX_RECORDS');
                  FND_MSG_PUB.ADD;
              END IF;
              RAISE FND_API.G_EXC_ERROR;

          END IF;

      END IF;

   If P_Qte_Header_Rec.quote_number Is Not Null And P_Qte_Header_Rec.quote_number <> FND_API.G_MISS_NUM Then -- code change done for Bug 17758573

      IF l_auto_version = 'Y' THEN

	       l_old_header_rec := ASO_UTILITY_PVT.Query_Header_Row(l_qte_header_rec.QUOTE_HEADER_ID);

            -- updating the existing version to a higher version
            -- this is done here because copy quote will fail to
            -- insert duplicate quote number/version

            l_copy_quote_control_rec.new_version     :=  FND_API.G_TRUE;
            l_copy_quote_header_rec.quote_header_id  :=  l_old_header_rec.quote_header_id;

            aso_copy_quote_pvt.copy_quote( P_Api_Version_Number      =>  1.0,
                                           P_Init_Msg_List           =>  FND_API.G_FALSE,
                                           P_Commit                  =>  FND_API.G_FALSE,
                                           P_Copy_Quote_Header_Rec   =>  l_copy_quote_header_rec,
                                           P_Copy_Quote_Control_Rec  =>  l_copy_quote_control_rec,
                                           X_Qte_Header_Id           =>  l_qte_header_id,
                                           X_Qte_Number              =>  l_quote_number,
                                           X_Return_Status           =>  l_return_status,
                                           X_Msg_Count               =>  x_msg_count,
                                           X_Msg_Data                =>  x_msg_data
                                          );

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		      aso_debug_pub.add('Update_Quote: After copy_quote l_return_status: ' || l_return_status);
                aso_debug_pub.add('Update_Quote: After copy_quote l_qte_header_id: ' || l_qte_header_id);
                aso_debug_pub.add('Update_Quote: After copy_quote l_quote_number:  ' || l_quote_number);
		  END IF;

            update aso_quote_headers_all
            set quote_version      =  l_qte_header_rec.quote_version + 1,
                max_version_flag   =  'Y',
                creation_date      =  sysdate
            where quote_header_id = l_qte_header_rec.quote_header_id;

            update aso_quote_headers_all
            set max_version_flag      =  'N',
                quote_version         =  l_old_header_rec.quote_version,
                quote_status_id       =  l_old_header_rec.quote_status_id,
                creation_date         =  l_old_header_rec.creation_date,
			 created_by            =  l_old_header_rec.created_by,
			 last_update_date      =  sysdate,
                last_updated_by       =  g_user_id,
                last_update_login     =  g_login_id
            where quote_header_id = l_qte_header_id;

            update aso_quote_headers_all
            set quote_version         =  l_qte_header_rec.quote_version,
                last_update_date      =  sysdate,
			 created_by            =  g_user_id,
			 last_updated_by       =  g_user_id,
                last_update_login     =  g_login_id
            where quote_header_id = l_qte_header_rec.quote_header_id;

            open  c_last_update_date(l_qte_header_rec.quote_header_id);
            fetch c_last_update_date into l_qte_header_rec.last_update_date;
            close c_last_update_date;

            l_control_rec.last_update_date  :=  l_qte_header_rec.last_update_date;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Update_Quote: After updating aso_quote_headers_all table for auto versioning.');
                aso_debug_pub.add('l_qte_header_rec.last_update_date: '|| l_qte_header_rec.last_update_date);
                aso_debug_pub.add('l_control_rec.last_update_date:    '|| l_control_rec.last_update_date);
            END IF;

      END IF;

   End If;

      l_index := 1;

      FOR i IN 1..p_price_adjustment_tbl.count LOOP

	      IF (p_price_adjustment_tbl(i).qte_line_index IS NULL OR
		     p_price_adjustment_tbl(i).qte_line_index = FND_API.G_MISS_NUM) AND
	         (p_price_adjustment_tbl(i).quote_line_id IS NULL OR
		     p_price_adjustment_tbl(i).quote_line_id = FND_API.G_MISS_NUM) THEN

		       l_price_adj_tbl(l_index)  := p_price_adjustment_tbl(i);
		       l_prc_index_link(l_index) := i;
		       l_prc_index_link_rev(i)   := l_index;
		       l_index                   := l_index + 1;
	      END IF;

      END LOOP;

      FOR i IN 1..p_price_adj_attr_tbl.count LOOP

           IF (p_price_adj_attr_tbl(i).qte_line_index IS NULL OR
		     p_price_adj_attr_tbl(i).qte_line_index = FND_API.G_MISS_NUM) THEN

	            l_price_adj_attr_tbl(l_index) := p_price_adj_attr_tbl(i);

	            IF p_price_adj_attr_tbl(i).price_adj_index <> FND_API.G_MISS_NUM AND
		          l_prc_index_link_rev.exists(p_price_adj_attr_tbl(i).price_adj_index) THEN

		             l_price_adj_attr_tbl(l_index).price_adj_index := l_prc_index_link_rev(l_price_adj_attr_tbl(l_index).price_adj_index);
	            END IF;

                 l_index := l_index + 1;
	      END IF;

      END LOOP;


      IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN

           IF l_hd_shipment_tbl.count > 0 THEN
                l_hd_shipment_tbl(1) := l_hd_shipment_tbl(1);
                l_shipment_rec       := l_hd_shipment_tbl(1);
           END IF;

           ASO_VALIDATE_PVT.Validate_record_tca_crs(
        	             p_init_msg_list	 => FND_API.G_FALSE,
        	             p_qte_header_rec  => l_qte_header_rec,
        	             p_shipment_rec    => l_shipment_rec,
        	             p_operation_code  => 'UPDATE',
        	             p_application_type_code  => l_control_rec.application_type_code,
        	             x_return_status	 => x_return_status,
                       x_msg_count		 => x_msg_count,
                       x_msg_data		 => x_msg_data);

           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

       -- bug 5196952 validate the ship method code if the ship method gets updated or the org gets updated
       IF ((l_shipment_rec.ship_method_code is not null and l_shipment_rec.ship_method_code <> fnd_api.g_miss_char and l_shipment_rec.operation_code = 'UPDATE')
          or (P_Qte_Header_Rec.org_id is not null and P_Qte_Header_Rec.org_id <> fnd_api.g_miss_num)) THEN

          -- get the value from db if not passed in
         IF (P_Qte_Header_Rec.org_id is null or P_Qte_Header_Rec.org_id = fnd_api.g_miss_num ) THEN
          OPEN c_org_id(l_qte_header_rec.quote_header_id);
          FETCH c_org_id into l_quote_org_id;
          CLOSE c_org_id;
	    ELSE
	      l_quote_org_id := P_Qte_Header_Rec.org_id;
         END IF;

          -- get the master org id from the quote hdr org id
          OPEN c_inv_org_id(l_quote_org_id);
          FETCH c_inv_org_id into l_master_organization_id;
          CLOSE c_inv_org_id;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Update_Quote - l_shipment_rec.ship_method_code:  '|| l_shipment_rec.ship_method_code, 1, 'N');
           aso_debug_pub.add('Update_Quote - P_Qte_Header_Rec.org_id:   '|| P_Qte_Header_Rec.org_id, 1, 'N');
           aso_debug_pub.add('Update_Quote - l_master_organization_id:  '|| l_master_organization_id, 1, 'N');
           aso_debug_pub.add('Update_Quote - l_quote_org_id         :   '|| l_quote_org_id, 1, 'N');
           aso_debug_pub.add('Update_Quote - before validate ship_method_code ', 1, 'N');
          end if;
         ASO_VALIDATE_PVT.validate_ship_method_code
         (
          p_init_msg_list          => fnd_api.g_false,
          p_qte_header_id          => l_qte_header_rec.quote_header_id,
          p_qte_line_id            => fnd_api.g_miss_num,
          p_organization_id        => l_master_organization_id,
          p_ship_method_code       => l_shipment_rec.ship_method_code,
          p_operation_code         => l_shipment_rec.operation_code,
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data);

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Update_Quote - After validate ship_method_code ', 1, 'N');
          end if;

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
        end if;  -- end if for ship method code check

      END IF;

      ASO_CHECK_TCA_PVT.check_tca(
                   p_api_version         => 1.0,
                   p_init_msg_list       => FND_API.G_FALSE,
                   P_Qte_Rec             => l_qte_header_rec,
    		         p_Header_Shipment_Tbl => l_hd_Shipment_Tbl,
                   P_Operation_Code      => 'UPDATE',
                   p_application_type_code      => l_control_rec.application_type_code,
                   x_return_status       => x_return_status,
                   x_msg_count           => x_msg_count,
                   x_msg_data            => x_msg_data);

    	 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
    	     RAISE FND_API.G_EXC_ERROR;
    	 END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote - before Validate_Agreement:l_qte_header_rec.contract_id: '||l_qte_header_rec.contract_id, 1, 'N');
      END IF;

      IF (l_qte_header_rec.contract_id IS NOT NULL AND
          l_qte_header_rec.contract_id <> FND_API.G_MISS_NUM) THEN

           ASO_VALIDATE_PVT.Validate_Agreement(
                      p_init_msg_list    => FND_API.G_FALSE,
                      P_Agreement_Id     => l_qte_header_rec.contract_id,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Quote - after Validate_Agreement:x_return_status: '||x_return_status, 1, 'N');
		 END IF;

           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('Update_Quote: l_qte_header_rec.minisite_id: '|| l_qte_header_rec.minisite_id);
	 END IF;

      IF (l_qte_header_rec.minisite_id IS NOT NULL AND
          l_qte_header_rec.minisite_id <> FND_API.G_MISS_NUM) THEN

           ASO_VALIDATE_PVT.Validate_MiniSite( p_init_msg_list => FND_API.G_FALSE,
                                               p_minisite_id   => l_qte_header_rec.minisite_id,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
		     aso_debug_pub.add('Update_Quote: After call to ASO_VALIDATE_PVT.Validate_MiniSite');
               aso_debug_pub.add('Update_Quote: x_return_status: '|| x_return_status);
		 END IF;

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('Update_Quote: Before call to update_rows procedures', 1, 'Y');
	 END IF;

      Update_Rows (
			p_qte_header_rec	    => l_qte_header_rec,
			p_Price_Attributes_Tbl  => p_hd_price_attributes_tbl,
			P_Price_Adjustment_Tbl  => l_price_adj_tbl,
			P_Price_Adj_Attr_Tbl    => l_price_adj_attr_tbl,
			P_Payment_Tbl		    => l_hd_payment_tbl,
			P_Shipment_Tbl		    => l_hd_shipment_tbl,
			P_Freight_Charge_Tbl    => p_hd_freight_charge_tbl,
			P_Tax_Detail_Tbl	    => l_hd_tax_detail_tbl,
               P_hd_Attr_Ext_Tbl	    => P_hd_Attr_Ext_Tbl,
               P_sales_credit_tbl      => p_hd_sales_credit_tbl,
               P_quote_party_tbl       => p_hd_quote_party_tbl,
               P_Qte_Access_Tbl        => P_Qte_Access_Tbl,
			x_qte_header_rec        => x_qte_header_rec,
			x_Price_Attributes_Tbl  => x_hd_price_attributes_tbl,
			x_Price_Adjustment_Tbl  => l_price_adj_tbl_out,
			x_Price_Adj_Attr_Tbl    => l_price_adj_attr_tbl_out,
			x_Payment_Tbl		    => x_hd_payment_tbl,
			x_Shipment_Tbl		    => x_hd_shipment_tbl,
			x_Freight_Charge_Tbl    => x_hd_freight_charge_tbl,
			x_Tax_Detail_Tbl        => x_hd_tax_detail_tbl,
               x_hd_Attr_Ext_Tbl       => x_hd_Attr_Ext_Tbl,
               x_sales_credit_tbl      => x_hd_sales_credit_tbl,
               x_quote_party_tbl       => x_hd_quote_party_tbl,
               x_Qte_Access_Tbl        => x_Qte_Access_Tbl,
			X_Return_Status 	    => l_return_status,
			X_Msg_Count		    => x_msg_count,
			X_Msg_Data		    => x_msg_data);

      l_price_adj_tbl       :=  l_price_adj_tbl_out;
      l_price_adj_attr_tbl  :=  l_price_adj_attr_tbl_out;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote: After call to update_rows: l_return_status: ' || l_return_status, 1, 'Y');
          aso_debug_pub.add('Update_Quote: value of ASO_API_ENABLE_SECURITY: ' || FND_PROFILE.value('ASO_API_ENABLE_SECURITY'), 1, 'Y');
      END IF;

      -- Add template rows to p_qte_line_tbl and p_qte_line_dtl tbales

      if aso_debug_pub.g_debug_flag = 'Y' then
          aso_debug_pub.add('Update_Quote: p_template_tbl.count: ' || p_template_tbl.count, 1, 'Y');
      end if;

      if p_template_tbl.count > 0 then

	    for i in 1..p_template_tbl.count loop
	        l_template_tbl(i) := p_template_tbl(i).template_id;
	    end loop;

	    if x_qte_header_rec.currency_code is null or x_qte_header_rec.currency_code = fnd_api.g_miss_char then
	        x_qte_header_rec.currency_code := l_currency_code;
         end if;

	    if x_qte_header_rec.price_list_id is null or x_qte_header_rec.price_list_id = fnd_api.g_miss_num then
	        x_qte_header_rec.price_list_id := l_price_list_id;
         end if;


	    if x_qte_header_rec.cust_account_id is null or x_qte_header_rec.cust_account_id = fnd_api.g_miss_num then
	       x_qte_header_rec.cust_account_id := l_cust_account_id;
	    end if;

         if aso_debug_pub.g_debug_flag = 'Y' then
             aso_debug_pub.add('Update_Quote: l_template_tbl.count: ' || l_template_tbl.count, 1, 'Y');
             aso_debug_pub.add('Update_Quote: Before call to aso_quote_templ_pvt.add_template_to_quote procedure', 1, 'Y');
         end if;

	    aso_quote_tmpl_pvt.add_template_to_quote(
                   p_api_version_number => 1.0,
                   p_init_msg_list      => fnd_api.g_false,
                   p_commit             => fnd_api.g_false,
                   p_validation_level	=> p_validation_level,
                   p_update_flag        => 'N',
                   p_template_id_tbl    => l_template_tbl,
                   p_qte_header_rec     => x_qte_header_rec,
                   p_control_rec        => p_control_rec,
                   x_qte_line_tbl       => lx_qte_line_tbl,
                   x_qte_line_dtl_tbl   => x_qte_line_dtl_tbl,
                   x_return_status      => x_return_status,
                   x_msg_count          => x_msg_count,
                   x_msg_data           => x_msg_data
                   );


         if aso_debug_pub.g_debug_flag = 'Y' then

	        aso_debug_pub.add('Update_Quote: After call to aso_quote_templ_pvt.add_template_to_quote: x_return_status: '|| x_return_status, 1, 'Y');
	        aso_debug_pub.add('Update_Quote: lx_qte_line_tbl.count:    ' || lx_qte_line_tbl.count, 1, 'Y');
	        aso_debug_pub.add('Update_Quote: x_qte_line_dtl_tbl.count: ' || x_qte_line_dtl_tbl.count, 1, 'Y');

	        for i in 1 .. lx_qte_line_tbl.count loop
	             aso_debug_pub.add('Update_Quote: lx_qte_line_tbl('||i||').inventory_item_id: '|| lx_qte_line_tbl(i).inventory_item_id, 1, 'N');
	             aso_debug_pub.add('Update_Quote: lx_qte_line_tbl('||i||').uom_code:          '|| lx_qte_line_tbl(i).uom_code, 1, 'N');
	             aso_debug_pub.add('Update_Quote: lx_qte_line_tbl('||i||').quantity:          '|| lx_qte_line_tbl(i).quantity, 1, 'N');
	        end loop;

             for i in 1 .. x_qte_line_dtl_tbl.count loop

	             aso_debug_pub.add('Update_Quote: x_qte_line_dtl_tbl('||i||').qte_line_index:             '|| x_qte_line_dtl_tbl(i).qte_line_index, 1, 'N');
	             aso_debug_pub.add('Update_Quote: x_qte_line_dtl_tbl('||i||').ref_line_index:             '|| x_qte_line_dtl_tbl(i).ref_line_index, 1, 'N');
	             aso_debug_pub.add('Update_Quote: x_qte_line_dtl_tbl('||i||').service_ref_qte_line_index: '|| x_qte_line_dtl_tbl(i).service_ref_qte_line_index, 1, 'N');
	             aso_debug_pub.add('Update_Quote: x_qte_line_dtl_tbl('||i||').service_ref_line_id:        '|| x_qte_line_dtl_tbl(i).service_ref_line_id, 1, 'N');

		   end loop;

         end if;


	    if lx_qte_line_tbl.count > 0 then

	         l_qte_line_dtl_tbl_out := x_qte_line_dtl_tbl;

              for i in 1 .. lx_qte_line_tbl.count loop

                   l_count  :=  ls_qte_line_tbl.count;   -- bug 9433340

                   ls_qte_line_tbl(l_count + 1) := lx_qte_line_tbl(i); -- bug  9433340

                   for j in 1 .. x_qte_line_dtl_tbl.count loop

                        if x_qte_line_dtl_tbl(j).qte_line_index = i then
                            l_qte_line_dtl_tbl_out(j).qte_line_index := l_count + 1;
                        end if;

                        if x_qte_line_dtl_tbl(j).ref_line_index = i then
                            l_qte_line_dtl_tbl_out(j).ref_line_index := l_count + 1;
                        end if;

                        if x_qte_line_dtl_tbl(j).service_ref_qte_line_index = i then
                            l_qte_line_dtl_tbl_out(j).service_ref_qte_line_index := l_count + 1;
                        end if;

                        if x_qte_line_dtl_tbl(j).top_model_line_index = i then
                            l_qte_line_dtl_tbl_out(j).top_model_line_index := l_count + 1;
                        end if;

                        if x_qte_line_dtl_tbl(j).ato_line_index = i then
                            l_qte_line_dtl_tbl_out(j).ato_line_index := l_count + 1;
                        end if;

                   end loop;

              end loop;

              if l_qte_line_dtl_tbl_out.count > 0 then

                   for i in 1 .. l_qte_line_dtl_tbl_out.count loop
                        lx_qte_line_dtl_tbl(lx_qte_line_dtl_tbl.count + 1) := l_qte_line_dtl_tbl_out(i);
                   end loop;

              end if;

         end if; -- if lx_qte_line_tbl.count > 0 then

      end if; --if p_template_tbl.count > 0 then


	 if aso_debug_pub.g_debug_flag = 'Y' then

	     aso_debug_pub.add('Update_Quote: ls_qte_line_tbl.count:      ' || ls_qte_line_tbl.count, 1, 'Y');  -- bug 9433340
	     aso_debug_pub.add('Update_Quote: lx_qte_line_dtl_tbl.count: ' || lx_qte_line_dtl_tbl.count, 1, 'Y');

	     for i in 1 .. ls_qte_line_tbl.count loop -- bug 9433340
	          aso_debug_pub.add('Update_Quote: ls_qte_line_tbl('||i||').inventory_item_id: '|| ls_qte_line_tbl(i).inventory_item_id, 1, 'N');
	          aso_debug_pub.add('Update_Quote: ls_qte_line_tbl('||i||').uom_code:          '|| ls_qte_line_tbl(i).uom_code, 1, 'N');
	          aso_debug_pub.add('Update_Quote: ls_qte_line_tbl('||i||').quantity:          '|| ls_qte_line_tbl(i).quantity, 1, 'N');
	     end loop;

          for i in 1 .. lx_qte_line_dtl_tbl.count loop

	          aso_debug_pub.add('Update_Quote: lx_qte_line_dtl_tbl('||i||').qte_line_index:             '|| lx_qte_line_dtl_tbl(i).qte_line_index, 1, 'N');
	          aso_debug_pub.add('Update_Quote: lx_qte_line_dtl_tbl('||i||').ref_line_index:             '|| lx_qte_line_dtl_tbl(i).ref_line_index, 1, 'N');
	          aso_debug_pub.add('Update_Quote: lx_qte_line_dtl_tbl('||i||').service_ref_qte_line_index: '|| lx_qte_line_dtl_tbl(i).service_ref_qte_line_index, 1, 'N');
	          aso_debug_pub.add('Update_Quote: lx_qte_line_dtl_tbl('||i||').service_ref_line_id:        '|| lx_qte_line_dtl_tbl(i).service_ref_line_id, 1, 'N');
	          aso_debug_pub.add('Update_Quote: lx_qte_line_dtl_tbl('||i||').ato_line_index:             '|| lx_qte_line_dtl_tbl(i).ato_line_index, 1, 'N');
	          aso_debug_pub.add('Update_Quote: lx_qte_line_dtl_tbl('||i||').ato_line_id:                '|| lx_qte_line_dtl_tbl(i).ato_line_id, 1, 'N');
	          aso_debug_pub.add('Update_Quote: lx_qte_line_dtl_tbl('||i||').top_model_line_index:       '|| lx_qte_line_dtl_tbl(i).top_model_line_index, 1, 'N');
	          aso_debug_pub.add('Update_Quote: lx_qte_line_dtl_tbl('||i||').top_model_line_id:          '|| lx_qte_line_dtl_tbl(i).top_model_line_id, 1, 'N');

		end loop;

	 end if;

      -- End of Add template rows
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			 aso_debug_pub.add('Update_Quote: value of p_qte_header_rec.quote_type: ' || p_qte_header_rec.quote_type, 1, 'Y');
			 aso_debug_pub.add('Update_Quote: value of l_qte_header_rec.resource_id: ' || l_qte_header_rec.resource_id, 1, 'Y');
			 aso_debug_pub.add('Update_Quote: value of l_qte_header_rec.resource_grp_id: ' || l_qte_header_rec.resource_grp_id, 1, 'Y');
			END IF;

      IF (NVL(FND_PROFILE.value('ASO_API_ENABLE_SECURITY'),'N') = 'Y' AND NVL(p_qte_header_rec.quote_type, 'X') <> 'T')  THEN

            /* Bug4869321,4600313 */
		  IF  (l_qte_header_rec.resource_id IS NULL OR l_qte_header_rec.resource_id = FND_API.G_MISS_NUM) THEN

               OPEN C_Get_Hdr_Resource_Id(l_qte_header_rec.quote_header_id);
               FETCH C_Get_Hdr_Resource_Id INTO l_qte_header_rec.resource_id;
               CLOSE C_Get_Hdr_Resource_Id;

           END IF;

           IF l_qte_header_rec.resource_id IS NOT NULL AND l_qte_header_rec.resource_id <> FND_API.G_MISS_NUM THEN

               OPEN C_Check_Store_Status(l_qte_status_id, l_qte_header_rec.quote_status_id);
               FETCH C_Check_Store_Status INTO l_store_trans;
               CLOSE C_Check_Store_Status;

               lx_qte_header_rec := x_qte_header_rec;

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Update_Quote - before assign_sales_team l_store_trans: '||l_store_trans, 1, 'Y');
                   aso_debug_pub.add('Update_Quote - before assign_sales_team l_sales_team_prof: '||l_sales_team_prof, 1, 'Y');
               END IF;

               IF (l_store_trans IS NOT NULL AND l_store_trans = 'Y') AND
                  (l_sales_team_prof = 'FULL' OR l_sales_team_prof = 'PARTIAL') THEN


                    ASO_SALES_TEAM_PVT.Assign_Sales_Team (
                                  P_Init_Msg_List    => FND_API.G_FALSE,
                                  P_Commit           => FND_API.G_FALSE,
                                  p_Qte_Header_Rec   => x_qte_header_rec,
                                  P_Operation        => 'UPDATE',
                                  x_Qte_Header_Rec   => lx_qte_header_rec,
                                  x_return_status    => x_return_status,
                                  x_msg_count        => x_msg_count,
                                  x_msg_data         => x_msg_data);

                    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

               ELSE -- store_trans, sales_team_prof

                    l_qte_access_rec                          := ASO_SECURITY_INT.G_MISS_QTE_ACCESS_REC;
                    -- l_qte_access_rec.QUOTE_NUMBER          := l_qte_header_rec.quote_number;
                    l_qte_access_rec.QUOTE_NUMBER             := l_qte_number;
                    l_qte_access_rec.RESOURCE_ID              := l_qte_header_rec.resource_id;
                    l_qte_access_rec.RESOURCE_GRP_ID          := l_qte_header_rec.resource_grp_id;
                    l_qte_access_rec.CREATED_BY               := G_USER_ID;
                    l_qte_access_rec.CREATION_DATE            := SYSDATE;
                    l_qte_access_rec.LAST_UPDATED_BY          := G_USER_ID;
                    l_qte_access_rec.LAST_UPDATE_LOGIN        := G_LOGIN_ID;
                    l_qte_access_rec.LAST_UPDATE_DATE         := SYSDATE;
                    l_qte_access_rec.REQUEST_ID               := l_qte_header_rec.request_id;
                    l_qte_access_rec.PROGRAM_APPLICATION_ID   := l_qte_header_rec.program_application_id;
                    l_qte_access_rec.PROGRAM_ID               := l_qte_header_rec.program_id;
                    l_qte_access_rec.PROGRAM_UPDATE_DATE      := l_qte_header_rec.program_update_date;

                    IF (l_store_trans IS NOT NULL AND l_store_trans = 'Y') THEN
                         l_qte_access_rec.KEEP_FLAG                := 'N';
                    END IF;

                    -- bug 4867690 if primary salesrep is changed then new prim salesrep should have full access
                    l_qte_access_rec.UPDATE_ACCESS_FLAG       := 'Y';
                    -- bug 4923573
                    l_qte_access_rec.batch_price_flag         := FND_API.G_FALSE;
                    l_qte_access_tbl(1)                       := l_qte_access_rec;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
		              aso_debug_pub.add('Update_Quote: before Add_Resource: l_qte_header_rec.resource_id:    ' || l_qte_header_rec.resource_id, 1, 'Y');
                        aso_debug_pub.add('Update_Quote: before Add_Resource', 1, 'Y');
		          END IF;

                    ASO_SECURITY_INT.Add_Resource(
                                P_INIT_MSG_LIST              => FND_API.G_FALSE,
                                P_COMMIT                     => FND_API.G_FALSE,
                                P_Qte_Access_tbl             => l_qte_access_tbl,
                                X_Qte_Access_tbl             => l_qte_access_tbl_out,
                                X_RETURN_STATUS              => x_return_status,
                                X_msg_count                  => X_msg_count,
                                X_msg_data                   => X_msg_data);

                    l_qte_access_tbl  :=  l_qte_access_tbl_out;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
		              aso_debug_pub.add('Update_Quote: after Add_Resource: x_return_status: ' || x_return_status, 1, 'Y');
		          END IF;

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    open  c_last_update_date(x_qte_header_rec.quote_header_id);
                    fetch c_last_update_date into x_qte_header_rec.last_update_date;
                    close c_last_update_date;

                    l_control_rec.last_update_date  :=  x_qte_header_rec.last_update_date;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Update_Quote: After call to Add_Resource.');
                        aso_debug_pub.add('x_qte_header_rec.last_update_date: '|| x_qte_header_rec.last_update_date);
                        aso_debug_pub.add('l_control_rec.last_update_date:    '|| l_control_rec.last_update_date);
                    END IF;

               END IF; -- steam_prof, store_trans

               OPEN C_Get_SCredit_Exists(x_qte_header_rec.quote_header_id);
               FETCH C_Get_SCredit_Exists INTO l_scredit_exists;
               CLOSE C_Get_SCredit_Exists;

       aso_debug_pub.add('l_scredit_exists: '||l_scredit_exists);

         IF x_hd_sales_credit_tbl.count < 1 AND (l_scredit_exists = 'N' OR l_scredit_exists IS NULL) THEN

          OPEN C_Get_Quota_Credit_Type;
          FETCH C_Get_Quota_Credit_Type INTO l_quota_id;
          CLOSE C_Get_Quota_Credit_Type;

       aso_debug_pub.add('l_quota_id: '||l_quota_id);
       x_hd_sales_credit_tbl(1) := ASO_QUOTE_PUB.G_MISS_SALES_CREDIT_REC;
       aso_debug_pub.add('after assign x_hd_sales_credit_tbl.count: '||x_hd_sales_credit_tbl.count);

          ASO_SALES_CREDITS_PKG.Insert_Row(
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REQUEST_ID  => FND_API.G_MISS_NUM,
          p_PROGRAM_APPLICATION_ID  => FND_API.G_MISS_NUM,
          p_PROGRAM_ID  => FND_API.G_MISS_NUM,
          p_PROGRAM_UPDATE_DATE  => FND_API.G_MISS_DATE,
          px_SALES_CREDIT_ID  => x_hd_sales_credit_tbl(1).Sales_Credit_Id,
          p_QUOTE_HEADER_ID  => l_qte_header_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => FND_API.G_MISS_NUM,
          p_PERCENT  => 100,
          p_RESOURCE_ID  => l_qte_header_rec.RESOURCE_ID,
          p_RESOURCE_GROUP_ID  => l_qte_header_rec.RESOURCE_GRP_ID,
          p_EMPLOYEE_PERSON_ID  => FND_API.G_MISS_NUM,
          p_SALES_CREDIT_TYPE_ID  => l_quota_id,
          p_ATTRIBUTE_CATEGORY_CODE  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE16  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE17  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE18  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE19  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE20  => FND_API.G_MISS_CHAR,
          p_SYSTEM_ASSIGNED_FLAG  => 'N',
          p_CREDIT_RULE_ID  => FND_API.G_MISS_NUM,
          p_OBJECT_VERSION_NUMBER  => FND_API.G_MISS_NUM);

       aso_debug_pub.add('After Insert SCred ');
         END IF; -- sales_cred_tbl.count

        END IF; -- resource_id

    END IF;

    -- end security changes

    --  Related Quote Objects Changes
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Before processing  object relationship ', 1, 'Y');
      END IF;

      IF P_Related_Obj_Tbl.count > 0 THEN

        For i in 1..P_Related_Obj_Tbl.count LOOP

          l_related_obj_rec := P_Related_Obj_Tbl(i);


          -- logic to populate the operation code
          Open c_obj_id(l_qte_header_rec.quote_header_id);
          Fetch c_obj_id INTO l_obj_id;
          IF c_obj_id%NOTFOUND THEN
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add(' Setting the operation code for rel obj tbl ', 1, 'Y');
               aso_debug_pub.add(' Obj id in rel obj rec is : '|| to_char(l_related_obj_rec.object_id), 1, 'Y');
            END IF;
            IF l_related_obj_rec.object_id IS NOT NULL THEN
              l_related_obj_rec.operation_code := 'CREATE';
            END IF;


           ELSE
             IF ((l_obj_id IS NOT NULL) AND (l_obj_id <> l_related_obj_rec.object_id)
		     AND (l_related_obj_rec.object_id IS NOT NULL)  ) THEN
                l_related_obj_rec.operation_code := 'UPDATE';
             END IF;

             IF (( l_obj_id is NOT NULL) AND (l_related_obj_rec.object_id IS NULL) ) THEN
                l_related_obj_rec.operation_code := 'DELETE';
             END IF;

             IF ( l_obj_id = l_related_obj_rec.object_id) then
                l_related_obj_rec.operation_code := null;
             END IF;

          END IF;
          Close c_obj_id;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add(' the operation code for rel obj tbl '||l_related_obj_rec.operation_code, 1, 'Y');
            END IF;



         IF l_related_obj_rec.operation_code = 'CREATE' THEN

          l_related_obj_rec.quote_object_id  :=  l_qte_header_rec.quote_header_id;
          x_related_obj_rec := l_related_obj_rec;


            ASO_RLTSHIP_PUB.Create_Object_Relationship(
              P_Api_Version_Number         => 1.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              p_validation_level           => p_validation_level,
              P_RELATED_OBJ_Rec            => l_related_obj_rec,
              X_related_object_id          => x_related_obj_rec.related_object_id,
              X_Return_Status              => X_Return_Status,
              X_Msg_Count                  => X_Msg_Count,
              X_Msg_Data                   => X_Msg_Data);

              X_Related_Obj_Tbl(i) := x_related_obj_rec;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('Update_Quote: After call to Create_Object_Relationship: x_return_status: '||x_return_status, 1, 'N');
              END IF;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

        ELSIF l_related_obj_rec.operation_code = 'UPDATE' THEN

          IF ((l_related_obj_rec.related_object_id = NULL OR l_related_obj_rec.related_object_id = FND_API.G_MISS_NUM)
		   OR (l_related_obj_rec.last_update_date = null or l_related_obj_rec.last_update_date = FND_API.G_MISS_DATE))THEN
		   Open c_related_obj_id(l_qte_header_rec.quote_header_id);
		   Fetch c_related_obj_id INTO l_related_obj_rec.related_object_id,l_related_obj_rec.last_update_date;
		   Close c_related_obj_id;
	     END IF;
		IF (l_related_obj_rec.quote_object_id = null or l_related_obj_rec.quote_object_id = FND_API.G_MISS_NUM) THEN
             l_related_obj_rec.quote_object_id  :=  l_qte_header_rec.quote_header_id;
		END IF;
            ASO_RLTSHIP_PUB.Update_Object_Relationship(
              P_Api_Version_Number         => 1.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              p_validation_level           => p_validation_level,
              P_RELATED_OBJ_Rec            => l_related_obj_rec,
              X_Return_Status              => X_Return_Status,
              X_Msg_Count                  => X_Msg_Count,
              X_Msg_Data                   => X_Msg_Data);

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('Update_Quote: After call to Update_Object_Relationship: x_return_status: '||x_return_status, 1, 'N');
              END IF;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

        ELSIF l_related_obj_rec.operation_code = 'DELETE' THEN

          IF l_related_obj_rec.related_object_id = NULL OR l_related_obj_rec.related_object_id = FND_API.G_MISS_NUM THEN
             Open c_related_obj_id(l_qte_header_rec.quote_header_id);
             Fetch c_related_obj_id INTO l_related_obj_rec.related_object_id,l_related_obj_rec.last_update_date;
             Close c_related_obj_id;
          END IF;
		l_related_obj_rec.quote_object_id  :=  l_qte_header_rec.quote_header_id;

            ASO_RLTSHIP_PUB.Delete_Object_Relationship(
              P_Api_Version_Number         => 1.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              p_validation_level           => p_validation_level,
              P_RELATED_OBJ_Rec            => l_related_obj_rec,
              X_Return_Status              => X_Return_Status,
              X_Msg_Count                  => X_Msg_Count,
              X_Msg_Data                   => X_Msg_Data);

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('Update_Quote: After call to Delete_Object_Relationship: x_return_status: '||x_return_status, 1, 'N');
              END IF;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

        END IF;
       END LOOP;


      END IF;  -- end if for P_Related_Obj_Tbl.count


    -- end  Related Quote Object Changes

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('before validate quote percent: validation level: '||P_validation_level, 1, 'Y');
		END IF;


-- sales credits

             IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN
                 IF x_hd_sales_credit_tbl.count > 0 THEN
                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Setting the qte hdr id in x_hd_sales_credit_tbl to : '|| x_qte_header_rec.QUOTE_HEADER_ID, 1, 'Y');
                    END IF;

                    x_hd_sales_credit_tbl(1).quote_header_id := x_qte_header_rec.QUOTE_HEADER_ID;

                     ASO_VALIDATE_PVT.Validate_Quote_Percent(
                         p_init_msg_list             => FND_API.G_FALSE,
                         p_sales_credit_tbl          => x_hd_sales_credit_tbl,
                         x_return_status             => x_return_status,
                         x_msg_count                 => x_msg_count,
                         x_msg_data                  => x_msg_data
                     );
                     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                         RAISE FND_API.G_EXC_ERROR;
                     END IF;
                 END IF;
             END IF;

-- end sales credits


      l_index := X_Price_Adjustment_tbl.count+1;
      FOR i IN 1.. l_Price_Adj_tbl.count LOOP
	  x_Price_Adjustment_tbl(l_index) := l_Price_Adj_tbl(i);
	  l_index := l_index+1;
      END LOOP;
      FOR j IN 1..l_prc_index_link.count LOOP
	  l_price_adjustment_tbl(l_prc_index_link(j)).price_adjustment_id
			:= l_price_adj_tbl(j).price_adjustment_id;
      END LOOP;
      l_index := X_Price_Adj_Attr_tbl.count+1;
      FOR i IN 1.. l_Price_Adj_Attr_tbl.count LOOP
	  x_Price_Adj_Attr_tbl(l_index) := l_Price_Adj_Attr_tbl(i);
	  l_index := l_index+1;
      END LOOP;


      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
	      FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER AFTER UPDATE ROW', TRUE);
	      FND_MSG_PUB.ADD;
	  END IF;
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
      END IF;

	  -- Start : code added for Bug 22582573
	  For quote_lines_rec IN c_quote_lines(l_qte_header_rec.quote_header_id) LOOP

	      FOR i IN 1 .. ls_qte_line_tbl.count LOOP

		      --l_qte_line_rec := ls_qte_line_tbl(i);

              If quote_lines_rec.quote_line_id = ls_qte_line_tbl(i).quote_line_id
			     and ls_qte_line_tbl(i).operation_code = 'UPDATE' Then
		         If (quote_lines_rec.quantity <> ls_qte_line_tbl(i).quantity) and (ls_qte_line_tbl(i).quantity<>FND_API.G_MISS_NUM) Then
	                ls_qte_line_tbl(i).QUANTITY_UOM_CHANGE := 'Y';
			IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('Modified QUANTITY_UOM_CHANGE to Y',1,'Y');
			END IF;
                 Else
 		            ls_qte_line_tbl(i).QUANTITY_UOM_CHANGE := 'N';
				 End If;
              End If;
	      End Loop;
		  --ls_qte_line_tbl(ls_qte_line_tbl.count+1) := l_qte_line_rec;
	  End Loop;
	  -- End : code added for Bug 22582573

  -- Update Quote Lines

  FOR i IN 1 .. ls_qte_line_tbl.count LOOP

     l_qte_line_rec := ls_qte_line_tbl(i);

     /* Start : Code change for Bug 9847694
        Added validation like - If service line is having reference with Install Base
	then End Customer will not be allowed at Service Line
     */
     If nvl(fnd_profile.value('ASO_FILTER_SERVICE_RF_END_CUST'),'N')= 'Y' Then

        If (l_qte_line_rec.end_customer_cust_account_id Is Not Null And
	    l_qte_line_rec.end_customer_cust_account_id <> FND_API.G_MISS_NUM) Then

            If (l_qte_line_rec.item_type_code Is Not Null And
	        l_qte_line_rec.item_type_code <> fnd_api.g_miss_char) Then
                l_item_type_code := l_qte_line_rec.item_type_code;
            Else
	        Open c_item_type_code(l_qte_line_rec.quote_line_id);
	        Fetch c_item_type_code Into l_item_type_code;
	        Close c_item_type_code;
	    End if;

	    If l_item_type_code = 'SRV' Then

               Open c_service_ref_type_code(l_qte_line_rec.quote_line_id);
               Fetch c_service_ref_type_code Into l_service_ref_type_code;
	       Close c_service_ref_type_code;

	       If l_service_ref_type_code = 'CUSTOMER_PRODUCT' Then
	          FND_MESSAGE.Set_Name('ASO', 'ASO_IB_END_CUST_CHG_NA');
		  FND_MSG_PUB.ADD;
	          RAISE FND_API.G_EXC_ERROR;
               End If;
	    End If;
	End If;
     End If;
     /* End : Code change for Bug 9847694 */

     /* Code change for Quoting Usability Sun ER Start */

     -- Validation check for Trade in product
     If l_control_rec.Change_Customer_flag = FND_API.G_TRUE Then   -- Code change done for Bug 11076978

        l_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(l_qte_line_rec.quote_line_id);

        IF (l_qte_line_rec.item_type_code = 'STD' ) and (l_qte_line_rec.line_category_code = 'RETURN' )THEN
	    IF (l_line_dtl_tbl(1).INSTANCE_ID IS NOT NULL) Then
                l_qte_line_rec.operation_code:='DELETE';
	        IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.ADD ('Update_Quote:Trade in from install Base Check Failed' , 1, 'N' );
	        END IF;
	    End IF;
        End IF;  -- Trade in

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Copy_Line_Rows:Call TO CZ_NETWORK_API_PUB.Is_Container ');
        END IF;

        -- Validation check for Container Model
	cz_network_api_pub.is_container(p_api_version  => 1.0
                                       ,p_inventory_item_id  => ls_qte_line_tbl( i ).inventory_item_id
                                       ,p_organization_id    => ls_qte_line_tbl( i ).organization_id
                                       ,p_appl_param_rec     => l_appl_param_rec
                                       ,x_return_value       => l_return_value
                                       ,x_return_status      => l_return_status
                                       ,x_msg_count          => x_msg_count
                                       ,x_msg_data           => x_msg_data );

        IF ( l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
             IF l_return_value = 'Y' THEN
                l_qte_line_rec.operation_code:='DELETE';
	        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.ADD ('Update_Quote : Container Model Check Failed' , 1, 'N' );
	        END IF;
             END IF;
        ELSE
            x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
               FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_CONFIG_COPY' , TRUE );
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        If l_qte_line_rec.service_item_flag = 'Y' Then

	   --  Validation check for service reference - Install Base and Pending Order
	   If (l_line_dtl_tbl(1).service_ref_type_code = 'CUSTOMER_PRODUCT') Or
	      (l_line_dtl_tbl(1).service_ref_type_code = 'PENDING_ORDER') Then
	       l_qte_line_rec.operation_code:='DELETE';

	   --  Validation check for service reference - Product Catalog
	   ElsIf l_line_dtl_tbl(1).service_ref_type_code = 'PRODUCT_CATALOG' Then

	       l_check_service_rec.product_item_id := l_line_dtl_tbl(1).SERVICE_REF_LINE_ID;
	       l_check_service_rec.customer_id     := P_Qte_Header_Rec.CUST_ACCOUNT_ID;
               l_check_service_rec.service_item_id := l_qte_line_rec.INVENTORY_ITEM_ID;

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.ADD( 'Update_Quote:Before calling ASO_SERVICE_CONTRACTS_INT.Is_Service_Available for IB', 1 , 'N' );
		END IF;

                ASO_SERVICE_CONTRACTS_INT.is_service_available (
       		  	P_Api_Version_Number	=> 1.0 ,
       			P_init_msg_list		=> p_init_msg_list ,
		    	X_msg_Count     	=> x_msg_count ,
       			X_msg_Data		=> x_msg_data	 ,
       			X_Return_Status		=> x_return_status  ,
			p_check_service_rec 	=> l_check_service_rec,
			X_Available_YN	    	=> l_Available_YN );

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.ADD( 'Update_Quote:After calling ASO_SERVICE_CONTRACTS_INT.Is_Service_Available for IB', 1 , 'N' );
		END IF;

                If nvl(l_Available_YN, 'N') = 'N' Then
		   l_qte_line_rec.operation_code:='DELETE';
		   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		      aso_debug_pub.add('Update_Quote: PC SERVICE not available');
		   END IF;
                End If;

	   --  Validation check for service reference - Quote
	   ElsIf l_line_dtl_tbl(1).service_ref_type_code = 'QUOTE' Then

	        open c_service_ref_quote(l_qte_line_rec.quote_line_id);
	        fetch c_service_ref_quote into l_check_service_rec.product_item_id;
	        close c_service_ref_quote;

	        l_check_service_rec.customer_id     := P_Qte_Header_Rec.CUST_ACCOUNT_ID;
                l_check_service_rec.service_item_id := l_qte_line_rec.INVENTORY_ITEM_ID;

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.ADD( 'Update_Quote:Before calling ASO_SERVICE_CONTRACTS_INT.Is_Service_Available for Quote', 1 , 'N' );
		END IF;

                ASO_SERVICE_CONTRACTS_INT.is_service_available (
       		   	 P_Api_Version_Number	=> 1.0 ,
       			 P_init_msg_list	=> p_init_msg_list ,
		    	 X_msg_Count     	=> x_msg_count ,
       			 X_msg_Data		=> x_msg_data	 ,
       			 X_Return_Status	=> x_return_status  ,
			 p_check_service_rec 	=> l_check_service_rec,
			 X_Available_YN	    	=> l_Available_YN );

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.ADD( 'Update_Quote:After calling ASO_SERVICE_CONTRACTS_INT.Is_Service_Available for Quote', 1 , 'N' );
		END IF;

                If nvl(l_Available_YN, 'N') = 'N' Then
		   l_qte_line_rec.operation_code:='DELETE';
		   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		      aso_debug_pub.add('Update_Quote: Quote SERVICE Not Available');
		   END IF;
                End If;
	   End If;
        END IF;
     End If; -- Change_Customer_flag is TRUE
     /* Code change for Quoting Usability Sun ER End */

/** Start Code fix for bug 13597269  **/
 IF l_qte_line_rec.operation_code = 'UPDATE' then
      open c_quote_line_tax_det(l_qte_line_rec.quote_line_id);
      fetch c_quote_line_tax_det into l_prod_fisc_class, l_trx_business_category;
      close c_quote_line_tax_det;

    if  l_qte_line_rec.product_fisc_classification = FND_API.G_MISS_CHAR then
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('rassharm UPDATE_QUOTE:line product_fisc_classification not modified');
	    aso_debug_pub.add('rassharm UPDATE_QUOTE:product_fisc_classification from DB'||l_prod_fisc_class);
        END IF;
         l_qte_line_rec.product_fisc_classification:=l_prod_fisc_class;
    end if ;

if  l_qte_line_rec.trx_business_category = FND_API.G_MISS_CHAR then
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('rassharm UPDATE_QUOTE:Line trx_business_category not modified');
	aso_debug_pub.add('rassharm UPDATE_QUOTE:trx_business_category from DB'||l_trx_business_category);

   END IF;
          l_qte_line_rec.trx_business_category:=l_trx_business_category;
  end if ;

 end if;
/** End Code fix for bug 13597269  **/

 -- New code for Batch Validation 05/24/2002

 IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('UPDATE_QUOTE: l_qte_header_rec.Call_batch_validation_flag: '|| l_qte_header_rec.Call_batch_validation_flag,1,'N');
 END IF;

 IF l_qte_header_rec.Call_batch_validation_flag = FND_API.G_TRUE THEN

   IF l_qte_line_rec.operation_code IN ('UPDATE','DELETE') THEN

      OPEN c_qte_line(l_qte_line_rec.quote_line_id);
      FETCH c_qte_line into l_qln_id;
      IF c_qte_line%FOUND THEN

        l_batch_qte_line_rec := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC;
        l_batch_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row(l_qte_line_rec.quote_line_id);

        l_add_line       := FND_API.G_FALSE;
        l_add_model_line := FND_API.G_FALSE;

        IF l_batch_qte_line_rec.item_type_code IN ('MDL','CFG') THEN

           l_batch_qte_line_dtl_tbl := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;
           l_batch_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(l_qte_line_rec.quote_line_id);
           IF l_batch_qte_line_dtl_tbl.count > 0 THEN
               IF l_batch_qte_line_dtl_tbl(1).config_header_id IS NOT NULL AND
                           l_batch_qte_line_dtl_tbl(1).config_revision_num IS NOT NULL THEN

                   --l_add_line := FND_API.G_TRUE;

                   IF l_batch_qte_line_rec.item_type_code = 'MDL' THEN
                       -- If user wants to delete the model line itself then no need to call batch validation
                       -- becuase deletion model line will delete the all other configuration lines and
                       -- the configuration from CZ
                       IF (l_qte_line_rec.operation_code = 'UPDATE') AND
					 (l_qte_line_rec.quantity <> FND_API.G_MISS_NUM) AND
                          (l_batch_qte_line_rec.quantity <> l_qte_line_rec.quantity) THEN

                           IF l_search_qte_line_tbl.EXISTS(l_qte_line_rec.quote_line_id) THEN
                               IF aso_debug_pub.g_debug_flag = 'Y' THEN
						 aso_debug_pub.add('UPDATE_QUOTE: Model line exist in the l_search_qte_line_tbl, no need to add again',1,'N');
						 END IF;
                               l_add_line       := FND_API.G_TRUE;
                           ELSE
                               --Add root model line of this configured line to the pl/sql table
                               IF aso_debug_pub.g_debug_flag = 'Y' THEN
						 aso_debug_pub.add('UPDATE_QUOTE: Model line does not exist in the l_search_qte_line_tbl, need to add into it',1,'N');
						 END IF;
                               l_search_qte_line_tbl(l_qte_line_rec.quote_line_id).quote_line_id
                                                               := l_qte_line_rec.quote_line_id;
                               l_add_line       := FND_API.G_TRUE;
                               l_add_model_line := FND_API.G_TRUE;
                               l_model_line_id  := l_qte_line_rec.quote_line_id;
                               IF aso_debug_pub.g_debug_flag = 'Y' THEN
						 aso_debug_pub.add('UPDATE_QUOTE: Model line does not exist: l_model_line_id: '|| l_model_line_id,1,'N');
						 END IF;

                           END IF;

                       ELSIF l_qte_line_rec.operation_code = 'DELETE' THEN

                            l_delete_qte_line_tbl(l_qte_line_rec.quote_line_id).quote_line_id
                                                    := l_qte_line_rec.quote_line_id;
                       END IF;

                   ELSE -- Children line l_batch_qte_line_rec.item_type_code = 'CFG'

			        if l_qte_line_rec.operation_code = 'DELETE'  and l_batch_qte_line_rec.config_model_type = 'N'
				      and  l_batch_qte_line_dtl_tbl(1).config_delta = 0 THEN

                           l_deactivate_counter := l_deactivate_counter + 1;
				       l_deactivate_quote_line_tbl(l_deactivate_counter).quote_line_id   := l_qte_line_rec.quote_line_id;
				       l_deactivate_quote_line_tbl(l_deactivate_counter).quote_header_id := l_batch_qte_line_rec.quote_header_id;

                        else

                            -- Get the root model line for this children line

                            OPEN c_model_line( l_batch_qte_line_dtl_tbl(1).config_header_id,
                                               l_batch_qte_line_dtl_tbl(1).config_revision_num );
                            FETCH c_model_line INTO l_model_line_id;

                            IF aso_debug_pub.g_debug_flag = 'Y' THEN
				             aso_debug_pub.add('UPDATE_QUOTE: c_model_line: l_model_line_id: '||l_model_line_id,1,'N');
				        END IF;

                            IF c_model_line%FOUND AND l_model_line_id is NOT NULL THEN

                                IF (l_qte_line_rec.operation_code = 'UPDATE') AND
                                   (l_qte_line_rec.quantity <> FND_API.G_MISS_NUM) AND
                                   (l_batch_qte_line_rec.quantity <> l_qte_line_rec.quantity) THEN

                                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
							     aso_debug_pub.add('UPDATE_QUOTE: Children line having operation_code = UPDATE',1,'N');
							END IF;
                                   l_add_line := FND_API.G_TRUE;
                                   IF l_search_qte_line_tbl.EXISTS(l_model_line_id) THEN
                                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
							    aso_debug_pub.add('UPDATE_QUOTE: Model line exist in the l_model_qte_line_tbl, no need to add again',1,'N');
							    END IF;
                                   ELSE
                                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
							    aso_debug_pub.add('UPDATE_QUOTE: Model line does not exist in the l_model_qte_line_tbl, need to add again',1,'N');
							    END IF;
                                       --Add root model line of this configured line to the pl/sql table
                                       l_add_model_line := FND_API.G_TRUE;
                                       l_search_qte_line_tbl(l_model_line_id).quote_line_id := l_model_line_id;
                                   END IF;

                                ELSIF l_qte_line_rec.operation_code = 'DELETE' THEN

                                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
							aso_debug_pub.add('UPDATE_QUOTE: Children line having operation_code = DELETE',1,'N');
							END IF;

                                   l_add_line := FND_API.G_TRUE;

                                   IF l_search_qte_line_tbl.EXISTS(l_model_line_id) THEN
                                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
							    aso_debug_pub.add('UPDATE_QUOTE: Model line exist in the l_model_qte_line_tbl, no need to add again',1,'N');
							    END IF;
                                   ELSE
                                       --Add root model line of this configured line to the pl/sql table
                                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
							    aso_debug_pub.add('UPDATE_QUOTE: Model line does not exist in the l_model_qte_line_tbl, need to add into it',1,'N');
							    END IF;
                                       l_add_model_line := FND_API.G_TRUE;
                                       l_search_qte_line_tbl(l_model_line_id).quote_line_id := l_model_line_id;
                                   END IF;

                                END IF;

                            ELSE
                                IF aso_debug_pub.g_debug_flag = 'Y' THEN
					           aso_debug_pub.add('UPDATE_QUOTE: c_model_line: Model line does not exist for this config line',1,'N');
					       END IF;
                            END IF; --c_model_line%FOUND AND l_model_line_id is NOT NULL
                            CLOSE c_model_line;

				    end if; --l_qte_line_rec.operation_code = 'DELETE' and l_batch_qte_line_rec.config_model_type = 'N' and l_batch_qte_line_dtl_tbl(1).config_delta = 0 THEN

                   END IF; --l_batch_qte_line_rec.item_type_code = 'MDL'

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
			    aso_debug_pub.add('UPDATE_QUOTE: Before Adding line to l_model_qte_line_tbl',1,'N');
                   aso_debug_pub.add('UPDATE_QUOTE: Before Adding line to l_model_qte_line_tbl: l_add_model_line: '||l_add_model_line,1,'N');
			    END IF;

                   IF l_add_model_line = FND_API.G_TRUE THEN

                       l_model_index := l_model_index + 1;
                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
				   aso_debug_pub.add('UPDATE_QUOTE: Inside IF l_add_model_line = FND_API.G_TRUE: l_model_index: '||l_model_index,1,'N');
				   END IF;
                       l_model_qte_line_tbl(l_model_index).quote_line_id := l_model_line_id;
                       l_model_qte_line_dtl_tbl(l_model_index).config_header_id
                                                         := l_batch_qte_line_dtl_tbl(1).config_header_id;
                       l_model_qte_line_dtl_tbl(l_model_index).config_revision_num
                                                         := l_batch_qte_line_dtl_tbl(1).config_revision_num;
                   END IF;

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
			    aso_debug_pub.add('UPDATE_QUOTE: Before Adding line to l_p_batch_qte_line_tbl',1,'N');
                   aso_debug_pub.add('UPDATE_QUOTE: Before Adding line to l_p_batch_qte_line_tbl: l_add_line: '||l_add_line,1,'N');
			    END IF;
                   IF l_add_line = FND_API.G_TRUE THEN
                       l_batch_index := l_batch_index + 1;
                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
				   aso_debug_pub.add('UPDATE_QUOTE: Inside IF l_add_line = FND_API.G_TRUE: l_batch_index: '||l_batch_index,1,'N');
				   END IF;
                       l_p_batch_qte_line_tbl(l_batch_index)                := l_batch_qte_line_rec;
                       l_p_batch_qte_line_tbl(l_batch_index).operation_code := l_qte_line_rec.operation_code;
                       l_p_batch_qte_line_tbl(l_batch_index).quantity       := l_qte_line_rec.quantity;
                       l_p_batch_qte_line_dtl_tbl(l_batch_index)            := l_batch_qte_line_dtl_tbl(1);
                   END IF;

               END IF; --config_header_id and config_revision_num IS NOT NULL

           END IF;--l_batch_qte_line_dtl_tbl.count > 0

        END IF; --l_batch_qte_line_rec.item_type_code IN ('MDL','CFG')

      END IF; --c_qte_line%FOUND
      CLOSE c_qte_line;

    END IF;--l_qte_line_rec.operation_code IN ('UPDATE','DELETE')

END IF; --l_qte_header_rec.Call_batch_validation_flag = FND_API.G_TRUE


--End New code for Batch Validation 05/24/2002


	IF l_qte_line_rec.operation_code = 'CREATE' THEN
	  -- line detail info
	  l_qte_line_dtl_tbl := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;
	  l_index := 1;
	  FOR j IN 1..lx_qte_line_dtl_tbl.count LOOP
	    IF lx_qte_line_dtl_tbl(j).qte_line_index = i THEN
	      l_qte_line_dtl_tbl(l_index) := lx_qte_line_dtl_tbl(j);
	      l_index := l_index + 1;
	    END IF;
	  END LOOP;

	  -- line attributes ext
	  l_line_attr_ext_tbl := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL;
	  l_index := 1;
	  FOR j IN 1..p_line_attr_ext_tbl.count LOOP
	      IF p_line_attr_ext_tbl(j).qte_line_index = i THEN
		  l_line_attr_ext_tbl(l_index) := p_line_attr_ext_tbl(j);
		  l_index := l_index + 1;
	      END IF;
	  END LOOP;

	  -- price attr info
	  l_index := 1;
	  l_price_attr_tbl := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl;
	  FOR j IN 1..p_ln_price_attributes_tbl.count LOOP
	    IF p_ln_price_attributes_tbl(j).qte_line_index = i THEN
	      l_price_attr_tbl(l_index) := p_ln_price_attributes_tbl(j);
	      l_index := l_index + 1;
	    END IF;
	  END LOOP;

	  -- modifier info
	  l_price_adj_tbl := ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl;
	  l_prc_index_link := G_Miss_Link_Tbl;
	  l_prc_index_link_rev := G_Miss_Link_Tbl;
	  l_index := 1;
	  FOR j IN 1..p_price_adjustment_tbl.count LOOP
	      IF p_price_adjustment_tbl(j).qte_line_index = i THEN
		  l_price_adj_tbl(l_index) := p_price_adjustment_tbl(j);
		  l_prc_index_link(l_index) := j;
		  l_prc_index_link_rev(j) := l_index;
		  l_index := l_index + 1;
	      END IF;
	  END LOOP;
       -- BC4J Fix
	  l_price_adj_attr_tbl:= ASO_QUOTE_PUB.G_Miss_Price_Adj_Attr_Tbl;
	  l_index := 1;
	  FOR j IN 1..p_price_adj_attr_tbl.count LOOP
	      IF p_price_adj_attr_tbl(j).price_adj_index <> FND_API.G_MISS_NUM
		AND l_prc_index_link_rev.exists(p_price_adj_attr_tbl(j).price_adj_index) THEN
		  l_price_adj_attr_tbl(l_index) := p_price_adj_attr_tbl(j);
		  l_price_adj_attr_tbl(l_index).price_adj_index :=
		  l_prc_index_link_rev(l_price_adj_attr_tbl(l_index).price_adj_index);
		  l_index := l_index + 1;
	      END IF;
	  END LOOP;

	  -- payment info
	  l_payment_tbl := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;
	  l_index := 1;
	  FOR j IN 1..p_ln_payment_tbl.count LOOP
	    IF p_ln_payment_tbl(j).qte_line_index = i THEN
	      l_payment_tbl(l_index) := p_ln_payment_tbl(j);
	      l_index := l_index +1;
	    END IF;
	  END LOOP;
	  -- only when payment_option is SPLIT, there can be more than one record
	  -- for line payment.
	  IF l_index > 2 AND l_payment_tbl(1).payment_option <> 'SPLIT' THEN
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;


	  -- shipment info
	  l_shipment_tbl := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL;
	  l_shp_index_link := G_Miss_Link_Tbl;
	  l_index := 1;
	  FOR j IN 1..p_ln_shipment_tbl.count LOOP
	      IF p_ln_shipment_tbl(j).qte_line_index = i THEN
		  l_shipment_tbl(l_index) := p_ln_shipment_tbl(j);
		  l_shp_index_link(j) := l_index;
          	  l_index := l_index+1;
	      END IF;
	  END LOOP;


	  -- freight charge info
	  l_freight_charge_tbl := ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl;
	  l_index := 1;
	  FOR j IN 1..p_ln_freight_charge_tbl.count LOOP
	      IF p_ln_freight_charge_tbl(j).qte_line_index = i THEN
		  l_freight_charge_tbl(l_index) := p_ln_freight_charge_tbl(j);
		  IF p_ln_freight_charge_tbl(j).shipment_index <> FND_API.G_MISS_NUM
			AND l_shp_index_link.EXISTS(p_ln_freight_charge_tbl(j).shipment_index) THEN
		      l_freight_charge_tbl(l_index).shipment_index :=
				l_shp_index_link(p_ln_freight_charge_tbl(j).shipment_index);
		  ELSE
		      null;
		  END IF;
		  l_index := l_index+1;
	      END IF;
	  END LOOP;


	  -- tax info
	  l_tax_detail_tbl := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl;
	  l_index := 1;
	  FOR j IN 1..p_ln_tax_detail_tbl.count LOOP
	      IF p_ln_tax_detail_tbl(j).qte_line_index = i THEN
		  l_tax_detail_tbl(l_index) := p_ln_tax_detail_tbl(j);
		      IF p_ln_tax_detail_tbl(j).shipment_index <> FND_API.G_MISS_NUM AND
			l_shp_index_link.EXISTS(p_ln_tax_detail_tbl(j).shipment_index) THEN
			  l_tax_detail_tbl(l_index).shipment_index :=
				l_shp_index_link(p_ln_tax_detail_tbl(j).shipment_index);
		      ELSE
			  null;
		      END IF;
		  l_index := l_index+1;
	      END IF;
	  END LOOP;
l_sales_credit_tbl := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl;

	  l_index := 1;
	  FOR j IN 1..p_ln_sales_credit_tbl.count LOOP
      IF p_ln_sales_credit_tbl(j).qte_line_index = i THEN
        l_sales_credit_tbl(l_index) := p_ln_sales_credit_tbl(j);
		  l_index := l_index +1;
	  END IF;
	  END LOOP;


l_quote_party_tbl := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl;

	  l_index := 1;
	  FOR j IN 1..p_ln_quote_party_tbl.count LOOP
      IF p_ln_quote_party_tbl(j).qte_line_index = i THEN
        l_quote_party_tbl(l_index) := p_ln_quote_party_tbl(j);
         IF p_ln_quote_party_tbl(j).shipment_index <> FND_API.G_MISS_NUM AND
            p_ln_quote_party_tbl(j).shipment_index  IS NOT NULL AND
		   l_shp_index_link.EXISTS(p_ln_quote_party_tbl(j).shipment_index) THEN
	       l_quote_party_tbl(l_index).shipment_index := l_shp_index_link(p_ln_quote_party_tbl(j).shipment_index);
         END IF;
		  l_index := l_index +1;
	  END IF;
	  END LOOP;

-- EDU
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Update_Quote (create_quote_lines) - before Validate_Commitment ', 1, 'N');
END IF;
     ASO_VALIDATE_PVT.Validate_Commitment(
          P_Init_Msg_List          => FND_API.G_FALSE,
          P_Qte_Header_Rec         => x_qte_header_rec,
          P_Qte_Line_Rec           => l_qte_line_rec,
          X_Return_Status          => l_return_status,
          X_Msg_Count              => x_msg_count,
          X_Msg_Data               => x_msg_data);
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Update_Quote - after Validate_Commitment: l_return_status: '||l_return_status, 1, 'N');
END IF;
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
     END IF;
-- EDU


	   open  c_last_update_date(x_qte_header_rec.quote_header_id);
	   fetch c_last_update_date into l_control_rec.last_update_date;
	   close c_last_update_date;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.add('Update_Quote: Before call to Create_Quote_Lines');
            aso_debug_pub.add('l_control_rec.last_update_date:    '|| l_control_rec.last_update_date);
        END IF;

	  -- create quote line
      ASO_QUOTE_LINES_PVT.Create_Quote_Lines (
			P_Api_Version_Number	=> 1.0,
			p_validation_level	=> p_validation_level,
			p_control_rec		=> l_control_rec,
			p_update_header_flag	=> FND_API.G_FALSE,
                  p_qte_header_rec        =>  l_qte_header_rec,
			P_qte_Line_Rec		=> l_qte_line_rec,
			P_qte_line_dtl_tbl	=> l_qte_line_dtl_tbl,
			P_Line_Attribs_Ext_Tbl	=> l_line_attr_Ext_Tbl,
			P_price_attributes_tbl	=> l_price_attr_tbl,
			P_Price_Adj_Tbl		=> l_price_adj_tbl,
			P_Price_Adj_Attr_Tbl	=> l_Price_Adj_Attr_Tbl,
			P_Payment_Tbl		=> l_payment_tbl,
			P_Shipment_Tbl		=> l_shipment_tbl,
			P_Freight_Charge_Tbl	=> l_freight_charge_tbl,
			P_Tax_Detail_Tbl	=> l_tax_detail_tbl,
            P_quote_party_tbl       => l_quote_party_tbl ,
            P_sales_Credit_tbl      => l_sales_Credit_tbl ,
			x_qte_Line_Rec		=> l_qte_line_rec_out,
			x_qte_line_dtl_tbl	=> l_qte_line_dtl_tbl_out,
			x_Line_Attribs_Ext_Tbl	=> l_line_attr_Ext_Tbl_out,
			x_price_attributes_tbl	=> l_price_attr_tbl_out,
			x_Price_Adj_Tbl		=> l_price_adj_tbl_out,
			x_Price_Adj_Attr_Tbl	=> l_Price_Adj_Attr_Tbl_out,
			x_Payment_Tbl		=> l_payment_tbl_out,
			x_Shipment_Tbl		=> l_shipment_tbl_out,
			x_Freight_Charge_Tbl	=> l_freight_charge_tbl_out,
			x_Tax_Detail_Tbl	=> l_tax_detail_tbl_out,
               X_quote_party_tbl       => l_quote_party_tbl_out ,
               X_sales_Credit_tbl      => l_sales_Credit_tbl_out ,
			X_Return_Status 	=> l_return_status,
			X_Msg_Count		=> x_msg_count,
			X_Msg_Data		=> x_msg_data);

        l_qte_line_rec        :=  l_qte_line_rec_out;
        l_qte_line_dtl_tbl    :=  l_qte_line_dtl_tbl_out;
        l_line_attr_Ext_Tbl   :=  l_line_attr_Ext_Tbl_out;
        l_price_attr_tbl      :=  l_price_attr_tbl_out;
        l_price_adj_tbl       :=  l_price_adj_tbl_out;
        l_Price_Adj_Attr_Tbl  :=  l_Price_Adj_Attr_Tbl_out;
        l_payment_tbl         :=  l_payment_tbl_out;
        l_shipment_tbl        :=  l_shipment_tbl_out;
        l_freight_charge_tbl  :=  l_freight_charge_tbl_out;
        l_tax_detail_tbl      :=  l_tax_detail_tbl_out;
        l_quote_party_tbl     :=  l_quote_party_tbl_out;
        l_sales_Credit_tbl    :=  l_sales_Credit_tbl_out;



		   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.add('Update_Quote - after create_quote_lines return_status: '||l_return_status, 1, 'Y');
		   END IF;

                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
	      FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER', TRUE);
	      FND_MSG_PUB.ADD;
	  END IF;
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;


        open  c_last_update_date(x_qte_header_rec.quote_header_id);
        fetch c_last_update_date into x_qte_header_rec.last_update_date;
        close c_last_update_date;

        l_control_rec.last_update_date  :=  x_qte_header_rec.last_update_date;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Update_Quote: After call to Create_Quote_Lines');
            aso_debug_pub.add('x_qte_header_rec.last_update_date: '|| x_qte_header_rec.last_update_date);
            aso_debug_pub.add('l_control_rec.last_update_date:    '|| l_control_rec.last_update_date);
        END IF;


          For j IN 1..lx_qte_line_dtl_tbl.count LOOP
             IF lx_qte_line_dtl_tbl(j).SERVICE_REF_QTE_LINE_INDEX = i THEN
                lx_qte_line_dtl_tbl(j).SERVICE_REF_LINE_ID := l_qte_line_rec.quote_line_id;
             END IF;
          END LOOP;

          -- For bundle configurator Changes Added 02/18/02
          FOR j IN 1..lx_qte_line_dtl_tbl.count LOOP
              IF lx_qte_line_dtl_tbl(j).REF_LINE_INDEX = i THEN
                  lx_qte_line_dtl_tbl(j).REF_LINE_ID := l_qte_line_rec.quote_line_id;
              END IF;
          END LOOP;
          -- End  bundle configurator Changes 02/18/02

	   --  P1 bug 10261431
	  FOR j IN 1..lx_qte_line_dtl_tbl.count LOOP
              IF lx_qte_line_dtl_tbl(j).TOP_MODEL_LINE_INDEX = i THEN
                  lx_qte_line_dtl_tbl(j).TOP_MODEL_LINE_ID := l_qte_line_rec.quote_line_id;
		  l_top_model_line_id:= l_qte_line_rec.quote_line_id;
              END IF;
          END LOOP;

	    FOR j IN 1..lx_qte_line_dtl_tbl.count LOOP
              IF lx_qte_line_dtl_tbl(j).ATO_LINE_INDEX = i THEN
                  lx_qte_line_dtl_tbl(j).ATO_LINE_ID := l_qte_line_rec.quote_line_id;
		  l_ato_line_id:= l_qte_line_rec.quote_line_id;
              END IF;
          END LOOP;

	  if (l_qte_line_rec.item_type_code='MDL') -- and (i=1) then
	      and (i>=1) then  -- code change done for Bug 19002028
		 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                      aso_debug_pub.add('Update_Quote: After call to Create_Quote_Lines updating the data for MDL line');
                 end if;
		     update aso_quote_line_details
		     set top_model_line_id=l_top_model_line_id,ato_line_id=l_ato_line_id
		     where quote_line_id=l_qte_line_rec.quote_line_id;
          end if;
	  --  P1 bug 10261431


 X_Qte_Line_Tbl(x_qte_line_tbl.count+1) := l_qte_line_rec;
	  l_index := X_Qte_Line_Dtl_Tbl.count+1;
	  FOR j IN 1.. l_qte_line_dtl_tbl.count LOOP
	      x_qte_line_dtl_tbl(l_index) := l_qte_line_dtl_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_Line_Attr_Ext_Tbl.count+1;
	  FOR j IN 1.. l_Line_Attr_Ext_tbl.count LOOP
	      x_Line_Attr_Ext_tbl(l_index) := l_Line_Attr_Ext_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_ln_Price_Attributes_Tbl.count+1;
	  FOR j IN 1.. l_Price_Attr_tbl.count LOOP
	      x_ln_Price_Attributes_tbl(l_index) := l_Price_Attr_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_Price_Adjustment_tbl.count+1;
	  FOR j IN 1.. l_Price_Adj_tbl.count LOOP
	      x_Price_Adjustment_tbl(l_index) := l_Price_Adj_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_Price_Adj_Attr_tbl.count+1;
	  FOR i IN 1.. l_Price_Adj_Attr_tbl.count LOOP
	      x_Price_Adj_Attr_tbl(l_index) := l_Price_Adj_Attr_tbl(i);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_LN_payment_Tbl.count+1;
	  FOR j IN 1.. l_payment_tbl.count LOOP
	      x_ln_payment_tbl(l_index) := l_payment_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_LN_shipment_Tbl.count+1;
	  FOR j IN 1.. l_shipment_tbl.count LOOP
	      x_ln_shipment_tbl(l_index) := l_shipment_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_LN_freight_charge_Tbl.count+1;
	  FOR j IN 1.. l_freight_charge_tbl.count LOOP
	      x_ln_freight_charge_tbl(l_index) := l_freight_charge_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_LN_tax_detail_Tbl.count+1;
	  FOR j IN 1.. l_tax_detail_tbl.count LOOP
	      x_ln_tax_detail_tbl(l_index) := l_tax_detail_tbl(j);
	      l_index := l_index+1;
	  END LOOP;

      l_index := X_ln_sales_Credit_Tbl.count+1;
	  FOR j IN 1.. l_sales_Credit_tbl.count LOOP
	      x_ln_sales_Credit_tbl(l_index) := l_sales_Credit_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
          l_index := X_ln_quote_party_Tbl.count+1;
	  FOR j IN 1.. l_quote_party_tbl.count LOOP
	      x_ln_quote_party_tbl(l_index) := l_quote_party_tbl(j);
	      l_index := l_index+1;
	  END LOOP;

	  FOR j IN 1..l_prc_index_link.count LOOP
	      l_price_adjustment_tbl(l_prc_index_link(j)).price_adjustment_id
			:= l_price_adj_tbl(j).price_adjustment_id;
	  END LOOP;
	  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
	      FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER', TRUE);
	      FND_MSG_PUB.ADD;
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
              RAISE FND_API.G_EXC_ERROR;
	  END IF;


	ELSIF l_qte_line_rec.operation_code = 'UPDATE' THEN


     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Update_Quote - if operation_code is update ', 1, 'N');
	END IF;

	  l_qte_line_id := l_qte_line_rec.quote_line_id;
	  -- line detail info
	  l_qte_line_dtl_tbl := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;
	  l_index := 1;
	  FOR j IN 1 .. lx_qte_line_dtl_tbl.count LOOP
	    IF lx_qte_line_dtl_tbl(j).quote_line_id  = l_qte_line_id THEN
	      l_qte_line_dtl_tbl(l_index) := lx_qte_line_dtl_tbl(j);
	      l_index := l_index + 1;
	    END IF;
	  END LOOP;

	  -- line attributes ext
	  l_line_attr_ext_tbl := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL;
	  l_index := 1;
	  FOR j IN 1..p_line_attr_ext_tbl.count LOOP
	      IF p_line_attr_ext_tbl(j).quote_line_id = l_qte_line_id THEN
		  l_line_attr_ext_tbl(l_index) := p_line_attr_ext_tbl(j);
		  l_index := l_index + 1;
	      END IF;
	  END LOOP;

	  -- price attr info
	  l_price_attr_tbl := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl;
	  l_index := 1;
	  FOR j IN 1..p_ln_price_attributes_tbl.count LOOP
	    IF p_ln_price_attributes_tbl(j).quote_line_id  = l_qte_line_id THEN
	      l_price_attr_tbl(l_index) := p_ln_price_attributes_tbl(j);
		 l_index := l_index + 1;
	    END IF;
	  END LOOP;

	  -- modifier info
	  l_price_adj_tbl := ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl;
	  l_prc_index_link := G_Miss_Link_Tbl;
	  l_prc_index_link_rev := G_Miss_Link_Tbl;
	  l_index := 1;
	  FOR j IN 1..p_price_adjustment_tbl.count LOOP
	    IF p_price_adjustment_tbl(j).quote_line_id	= l_qte_line_id THEN
	      l_price_adj_tbl(l_index) := p_price_adjustment_tbl(j);
	      l_prc_index_link(l_index) := j;
	      l_prc_index_link_rev(j) := l_index;
	      l_index := l_index + 1;
	    END IF;
	  END LOOP;
	  l_index := 1;

       -- BC4J Fix
	  l_price_adj_attr_tbl:= ASO_QUOTE_PUB.G_Miss_Price_Adj_Attr_Tbl;

	  FOR j IN 1..p_price_adj_attr_tbl.count LOOP
	    IF p_price_adj_attr_tbl(j).qte_line_index = i THEN
	      l_price_adj_attr_tbl(l_index) := p_price_adj_attr_tbl(j);
	      IF p_price_adj_attr_tbl(j).price_adj_index <> FND_API.G_MISS_NUM
		AND l_prc_index_link_rev.exists(p_price_adj_attr_tbl(j).price_adj_index) THEN
		  l_price_adj_attr_tbl(l_index).price_adj_index :=
			l_prc_index_link_rev(l_price_adj_attr_tbl(l_index).price_adj_index);
	      END IF;
	      l_index := l_index + 1;
	    END IF;
	  END LOOP;


	  -- payment info
	  l_payment_tbl := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;
	  l_index := 1;
	  FOR j IN 1..p_ln_payment_tbl.count LOOP
	    IF p_ln_payment_tbl(j).quote_line_id  = l_qte_line_id THEN
	      l_payment_tbl(l_index) := p_ln_payment_tbl(j);
	      l_index := l_index +1;
	    END IF;
	  END LOOP;

	  -- shipment info
	  l_shipment_tbl := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL;
	  l_shp_index_link := G_Miss_Link_Tbl;
	  l_index := 1;
	  FOR j IN 1..p_ln_shipment_tbl.count LOOP
	    IF p_ln_shipment_tbl(j).quote_line_id  = l_qte_line_id THEN
	      l_shipment_tbl(l_index) := p_ln_shipment_tbl(j);
	      l_shp_index_link(j) := l_index;
          l_index := l_index +1;
	    END IF;
	  END LOOP;

l_sales_credit_tbl := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl;

	  l_index := 1;
	  FOR j IN 1..p_ln_sales_credit_tbl.count LOOP
      IF p_ln_sales_credit_tbl(j).qte_line_index = i
	    OR p_ln_sales_credit_tbl(j).quote_line_id = l_qte_line_id THEN
        l_sales_credit_tbl(l_index) := p_ln_sales_credit_tbl(j);
		  l_index := l_index +1;
	  END IF;
	  END LOOP;


l_quote_party_tbl := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl;

	  l_index := 1;
	  FOR j IN 1..p_ln_quote_party_tbl.count LOOP
      IF p_ln_quote_party_tbl(j).qte_line_index = i THEN
        l_quote_party_tbl(l_index) := p_ln_quote_party_tbl(j);
         IF p_ln_quote_party_tbl(j).shipment_index <> FND_API.G_MISS_NUM AND
            p_ln_quote_party_tbl(j).shipment_index  IS NOT NULL AND
		   l_shp_index_link.EXISTS(p_ln_quote_party_tbl(j).shipment_index) THEN
	       l_quote_party_tbl(l_index).shipment_index := l_shp_index_link(p_ln_quote_party_tbl(j).shipment_index);
         END IF;
		  l_index := l_index +1;
	  END IF;
	  END LOOP;
	  -- freight charge info
	  l_freight_charge_tbl := ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl;
	  l_index := 1;
	  FOR j IN 1..p_ln_freight_charge_tbl.count LOOP
	      IF p_ln_freight_charge_tbl(j).quote_line_id = l_qte_line_id THEN
		  l_freight_charge_tbl(l_index) := p_ln_freight_charge_tbl(j);
		  IF l_freight_charge_tbl(l_index).shipment_index IS NOT NULL AND
			l_freight_charge_tbl(l_index).shipment_index <> FND_API.G_MISS_NUM THEN
		      IF p_ln_freight_charge_tbl(j).shipment_index <> FND_API.G_MISS_NUM AND
			l_shp_index_link.EXISTS(p_ln_freight_charge_tbl(j).shipment_index) THEN
			  l_freight_charge_tbl(l_index).shipment_index :=
				l_shp_index_link(p_ln_freight_charge_tbl(j).shipment_index);
		      ELSE
			  null;
		      END IF;
		  END IF;
		  l_index := l_index+1;
	      END IF;
	  END LOOP;


	  -- tax info
	  l_tax_detail_tbl := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl;
	  l_index := 1;
	  FOR j IN 1..p_ln_tax_detail_tbl.count LOOP
	      IF p_ln_tax_detail_tbl(j).quote_line_id = l_qte_line_id THEN
		  l_tax_detail_tbl(l_index) := p_ln_tax_detail_tbl(j);
		  IF l_tax_detail_tbl(l_index).shipment_index IS NOT NULL AND
			l_tax_detail_tbl(l_index).shipment_index <> FND_API.G_MISS_NUM THEN
		      IF p_ln_tax_detail_tbl(j).shipment_index <> FND_API.G_MISS_NUM AND
			l_shp_index_link.EXISTS(p_ln_tax_detail_tbl(j).shipment_index) THEN
			  l_tax_detail_tbl(l_index).shipment_index :=
				l_shp_index_link(p_ln_tax_detail_tbl(j).shipment_index);
		      ELSE
			  null;
		      END IF;
		  END IF;
		  l_index := l_index+1;
	      END IF;
	  END LOOP;

-- EDU
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Update_Quote (update_quote_lines) - before Validate_Commitment ', 1, 'N');
END IF;
     ASO_VALIDATE_PVT.Validate_Commitment(
          P_Init_Msg_List          => FND_API.G_FALSE,
          P_Qte_Header_Rec         => x_qte_header_rec,
          P_Qte_Line_Rec           => l_qte_line_rec,
          X_Return_Status          => l_return_status,
          X_Msg_Count              => x_msg_count,
          X_Msg_Data               => x_msg_data);
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Update_Quote (upd_qte_ln)- after Validate_Commitment: l_return_status: '||l_return_status, 1, 'N');
END IF;
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
     END IF;
-- EDU

	  -- update quote line (need to do the following validation:
	  -- 1. each line has at least one shipment rec
	  -- 2. each line has only one tax_detail rec in which to set the tax
	  --	exempt info.

	   open  c_last_update_date(x_qte_header_rec.quote_header_id);
	   fetch c_last_update_date into l_control_rec.last_update_date;
	   close c_last_update_date;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.add('Update_Quote: Before call to Update_Quote_Line');
            aso_debug_pub.add('l_control_rec.last_update_date:    '|| l_control_rec.last_update_date);
        END IF;


	   ASO_QUOTE_LINES_PVT.Update_Quote_Line (
			P_Api_Version_Number	=> 1.0,
			p_validation_level	=> p_validation_level,
			p_control_rec		=> l_control_rec,
			p_update_header_flag	=> FND_API.G_FALSE,
                  p_qte_header_rec        => l_qte_header_rec,
			P_qte_Line_Rec		=> l_qte_line_rec,
			P_qte_line_dtl_tbl	=> l_qte_line_dtl_tbl,
			P_Line_Attribs_Ext_Tbl	=> l_line_attr_Ext_Tbl,
			P_price_attributes_tbl	=> l_price_attr_tbl,
			P_Price_Adj_Tbl		=> l_price_adj_tbl,
			P_Price_Adj_Attr_Tbl	=> l_Price_Adj_Attr_Tbl,
			P_Payment_Tbl		=> l_payment_tbl,
			P_Shipment_Tbl		=> l_shipment_tbl,
			P_Freight_Charge_Tbl	=> l_freight_charge_tbl,
			P_Tax_Detail_Tbl	=> l_tax_detail_tbl,
            P_quote_party_tbl       => l_quote_party_tbl ,
            P_sales_Credit_tbl      => l_sales_Credit_tbl ,
			x_qte_Line_Rec		=> l_qte_line_rec_out,
			x_qte_line_dtl_tbl	=> l_qte_line_dtl_tbl_out,
			x_Line_Attribs_Ext_Tbl	=> l_line_attr_Ext_Tbl_out,
			x_price_attributes_tbl	=> l_price_attr_tbl_out,
			x_Price_Adj_Tbl		=> l_price_adj_tbl_out,
			x_Price_Adj_Attr_Tbl	=> l_Price_Adj_Attr_Tbl_out,
			x_Payment_Tbl		=> l_payment_tbl_out,
			x_Shipment_Tbl		=> l_shipment_tbl_out,
			x_Freight_Charge_Tbl	=> l_freight_charge_tbl_out,
			x_Tax_Detail_Tbl	=> l_tax_detail_tbl_out,
            X_quote_party_tbl       => l_quote_party_tbl_out ,
            X_sales_Credit_tbl      => l_sales_Credit_tbl_out ,
			X_Return_Status 	=> l_return_status,
			X_Msg_Count		=> x_msg_count,
			X_Msg_Data		=> x_msg_data);


        l_qte_line_rec        :=  l_qte_line_rec_out;
        l_qte_line_dtl_tbl    :=  l_qte_line_dtl_tbl_out;
        l_line_attr_Ext_Tbl   :=  l_line_attr_Ext_Tbl_out;
        l_price_attr_tbl      :=  l_price_attr_tbl_out;
        l_price_adj_tbl       :=  l_price_adj_tbl_out;
        l_Price_Adj_Attr_Tbl  :=  l_Price_Adj_Attr_Tbl_out;
        l_payment_tbl         :=  l_payment_tbl_out;
        l_shipment_tbl        :=  l_shipment_tbl_out;
        l_freight_charge_tbl  :=  l_freight_charge_tbl_out;
        l_tax_detail_tbl      :=  l_tax_detail_tbl_out;
        l_quote_party_tbl     :=  l_quote_party_tbl_out;
        l_sales_Credit_tbl    :=  l_sales_Credit_tbl_out;


        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	        aso_debug_pub.add('Update_Quote: after update_quote_line: l_return_status: '||l_return_status);
	   END IF;

        open  c_last_update_date(x_qte_header_rec.quote_header_id);
        fetch c_last_update_date into x_qte_header_rec.last_update_date;
        close c_last_update_date;

        l_control_rec.last_update_date  :=  x_qte_header_rec.last_update_date;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Update_Quote: After call to Update_Quote_Line');
            aso_debug_pub.add('x_qte_header_rec.last_update_date: '|| x_qte_header_rec.last_update_date);
            aso_debug_pub.add('l_control_rec.last_update_date:    '|| l_control_rec.last_update_date);
        END IF;


	  X_Qte_Line_Tbl(x_qte_line_tbl.count+1) := l_qte_line_rec;
	  l_index := X_Qte_Line_Dtl_Tbl.count+1;

	  FOR j IN 1.. l_qte_line_dtl_tbl.count LOOP
	      x_qte_line_dtl_tbl(l_index) := l_qte_line_dtl_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_Line_Attr_Ext_Tbl.count+1;
	  FOR j IN 1.. l_Line_Attr_Ext_tbl.count LOOP
	      x_Line_Attr_Ext_tbl(l_index) := l_Line_Attr_Ext_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_ln_Price_Attributes_Tbl.count+1;
	  FOR j IN 1.. l_Price_Attr_tbl.count LOOP
	      x_ln_Price_Attributes_tbl(l_index) := l_Price_Attr_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_Price_Adjustment_tbl.count+1;
	  FOR j IN 1.. l_Price_Adj_tbl.count LOOP
	      x_Price_Adjustment_tbl(l_index) := l_Price_Adj_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_Price_Adj_Attr_tbl.count+1;
	  FOR i IN 1.. l_Price_Adj_Attr_tbl.count LOOP
	      x_Price_Adj_Attr_tbl(l_index) := l_Price_Adj_Attr_tbl(i);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_LN_payment_Tbl.count+1;
	  FOR j IN 1.. l_payment_tbl.count LOOP
	      x_ln_payment_tbl(l_index) := l_payment_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_Ln_shipment_Tbl.count+1;
	  FOR j IN 1.. l_shipment_tbl.count LOOP
	      x_ln_shipment_tbl(l_index) := l_shipment_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_LN_freight_charge_Tbl.count+1;
	  FOR j IN 1.. l_freight_charge_tbl.count LOOP
	      x_ln_freight_charge_tbl(l_index) := l_freight_charge_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
	  l_index := X_LN_tax_detail_Tbl.count+1;
	  FOR j IN 1.. l_tax_detail_tbl.count LOOP
	      x_ln_tax_detail_tbl(l_index) := l_tax_detail_tbl(j);
	      l_index := l_index+1;
	  END LOOP;

      l_index := X_ln_sales_Credit_Tbl.count+1;
	  FOR j IN 1.. l_sales_Credit_tbl.count LOOP
	      x_ln_sales_Credit_tbl(l_index) := l_sales_Credit_tbl(j);
	      l_index := l_index+1;
	  END LOOP;
          l_index := X_ln_quote_party_Tbl.count+1;
	  FOR j IN 1.. l_quote_party_tbl.count LOOP
	      x_ln_quote_party_tbl(l_index) := l_quote_party_tbl(j);
	      l_index := l_index+1;
	  END LOOP;



	  FOR j IN 1..l_prc_index_link.count LOOP
	      l_price_adjustment_tbl(l_prc_index_link(j)).price_adjustment_id
			:= l_price_adj_tbl(j).price_adjustment_id;
	  END LOOP;
	  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
	      FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER AFTER UPDATE  QLN', TRUE);
	      FND_MSG_PUB.ADD;
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
              RAISE FND_API.G_EXC_ERROR;
	  END IF;


	ELSIF l_qte_line_rec.operation_code = 'DELETE' THEN


            OPEN c_qte_line(l_qte_line_rec.quote_line_id);
            FETCH c_qte_line into l_qln_id;

            IF c_qte_line%FOUND and l_qln_id <>FND_API.G_MISS_NUM THEN

	          open  c_last_update_date(x_qte_header_rec.quote_header_id);
	          fetch c_last_update_date into l_control_rec.last_update_date;
	          close c_last_update_date;

	          IF aso_debug_pub.g_debug_flag = 'Y' THEN
		         aso_debug_pub.add('Update_Quote: Before call to Delete_Quote_Line');
                   aso_debug_pub.add('l_control_rec.last_update_date:    '|| l_control_rec.last_update_date);
               END IF;

	        -- Refer bug 10217258   rassharm
		--bugrassharm
               IF NVL(FND_PROFILE.VALUE('QP_LIMITS_INSTALLED'),'N') = 'Y' THEN

	            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		            aso_debug_pub.add('Update_Quote: Reverse Limits limit installed'||l_qte_line_rec.quote_line_id||'item type'||l_qte_line_rec.item_type_code);
			aso_debug_pub.add('Update_Quote RASSHARM: Reverse Limits for handling l_qln_id'||l_qln_id);
		END IF;


		QP_UTIL_PUB.Reverse_Limits (p_action_code   => 'CANCEL',
                                p_cons_price_request_code    => 'ASO-'||l_qte_line_rec.quote_header_id||'-'||l_qte_line_rec.quote_line_id,
                                p_orig_ordered_qty           => l_qte_line_rec.quantity,
                                p_amended_qty                => NULL,
                                p_ret_price_request_code     => NULL,
                                p_returned_qty               => NULL,
                                x_return_status              => l_return_status,
                                x_return_message             => x_msg_data
                               );


              open c_qte_line_type(l_qte_line_rec.quote_line_id);
		          fetch c_qte_line_type into l_item_type_code1;
		          close c_qte_line_type;

              aso_debug_pub.add('Update_Quote RASSHARM: Reverse Limits for handling CFG items'||l_item_type_code1);

              if  (l_item_type_code1='MDL')  or (l_item_type_code1='CFG') then

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		                   aso_debug_pub.add('Update_Quote: Reverse Limits for handling CFG items');
                   END IF;
		         for c1 in
		         (
              /* Commented following cursor for Bug 14346477 , added Union clause in the query
	      select quote_line_id from aso_quote_line_Details
                where ref_type_code='CONFIG'
                and (top_model_line_id=l_qln_id or ref_line_id=l_qln_id)
                and top_model_line_id<>quote_line_id */

              SELECT QUOTE_LINE_ID
                FROM ASO_QUOTE_LINE_DETAILS
               WHERE REF_TYPE_CODE     =  'CONFIG'
                 AND TOP_MODEL_LINE_ID =  l_qln_id
                 AND TOP_MODEL_LINE_ID <> QUOTE_LINE_ID
               UNION
              SELECT QUOTE_LINE_ID
                FROM ASO_QUOTE_LINE_DETAILS
               WHERE REF_TYPE_CODE     =  'CONFIG'
                 AND REF_LINE_ID       =  l_qln_id
                 AND TOP_MODEL_LINE_ID <> QUOTE_LINE_ID
              )
            loop
		        select nvl(quantity,0) into l_qty from aso_Quote_lines_all where quote_line_id=c1.quote_line_id;
		        aso_debug_pub.add('rassharm Update_Quote: Reverse Limits for handling CFG items quote_line_id'||c1.quote_line_id||' *** qty'||l_qty);
            QP_UTIL_PUB.Reverse_Limits (p_action_code   => 'CANCEL',
                                p_cons_price_request_code    => 'ASO-'||l_qte_line_rec.quote_header_id||'-'||c1.quote_line_id,
                                p_orig_ordered_qty           => l_qty,
                                p_amended_qty                => NULL,
                                p_ret_price_request_code     => NULL,
                                p_returned_qty               => NULL,
                                x_return_status              => l_return_status,
                                x_return_message             => x_msg_data
                               );

             end loop;
	         end if;  -- MDL

           end if; -- profile if limit installed


	          ASO_QUOTE_LINES_PVT.Delete_Quote_Line (
			P_Api_Version_Number	=> 1.0,
			p_control_rec		=> l_control_rec,
			p_update_header_flag	=> FND_API.G_FALSE,
			P_qte_Line_Rec		=> l_qte_line_rec,
			X_Return_Status 	=> l_return_status,
			X_Msg_Count		=> x_msg_count,
			X_Msg_Data		=> x_msg_data);


            END IF;
            CLOSE c_qte_line;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.add('Update_Quote: after Delete_Quote_Line: l_return_status: '||l_return_status);
	       END IF;

            IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

	           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                 FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
	                 FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER AFTER DELETE QLN', TRUE);
	                 FND_MSG_PUB.ADD;
	           END IF;
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN

                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;

	       END IF;

            open  c_last_update_date(x_qte_header_rec.quote_header_id);
            fetch c_last_update_date into x_qte_header_rec.last_update_date;
            close c_last_update_date;

            l_control_rec.last_update_date  :=  x_qte_header_rec.last_update_date;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Update_Quote: After call to Update_Quote_Line');
                aso_debug_pub.add('x_qte_header_rec.last_update_date: '|| x_qte_header_rec.last_update_date);
                aso_debug_pub.add('l_control_rec.last_update_date:    '|| l_control_rec.last_update_date);
            END IF;

	END IF;

   END LOOP;


    --New code for Batch Validate 05/24/2002

    -- Now call batch validate for each configuration at the end quote_line_tbl LOOP

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('UPDATE_QUOTE: l_qte_header_rec.Call_batch_validation_flag: '||l_qte_header_rec.Call_batch_validation_flag,1,'N');
END IF;

IF l_qte_header_rec.Call_batch_validation_flag = FND_API.G_TRUE THEN

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('UPDATE_QUOTE: l_model_qte_line_tbl.count: '||l_model_qte_line_tbl.count,1,'N');
   aso_debug_pub.add('UPDATE_QUOTE: l_p_batch_qte_line_tbl.count: '||l_p_batch_qte_line_tbl.count,1,'N');
   aso_debug_pub.add('UPDATE_QUOTE: l_p_batch_qte_line_dtl_tbl.count: '||l_p_batch_qte_line_dtl_tbl.count,1,'N');
   END IF;


   FOR i IN 1..l_model_qte_line_tbl.count LOOP
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('UPDATE_QUOTE: l_model_qte_line_tbl('||i||').quote_line_id: '||l_model_qte_line_tbl(i).quote_line_id,1,'N');
       aso_debug_pub.add('UPDATE_QUOTE: l_model_qte_line_dtl_tbl('||i||').config_header_id: '||l_model_qte_line_dtl_tbl(i).config_header_id,1,'N');
       aso_debug_pub.add('UPDATE_QUOTE: l_model_qte_line_dtl_tbl('||i||').config_revision_num: '||l_model_qte_line_dtl_tbl(i).config_revision_num,1,'N');
	  END IF;

       l_send_qte_line_tbl     := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;
	  l_send_qte_line_dtl_tbl := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;
       l_send_index            := 0;

       IF l_delete_qte_line_tbl.EXISTS(l_model_qte_line_tbl(i).quote_line_id) THEN

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
		 aso_debug_pub.add('UPDATE_QUOTE: Model line exist in l_delete_qte_line_tbl so it is already deleted along with children lines');
		 END IF;

       ELSE

           FOR j IN 1..l_p_batch_qte_line_dtl_tbl.count LOOP
               IF l_p_batch_qte_line_dtl_tbl(j).config_header_id = l_model_qte_line_dtl_tbl(i).config_header_id AND
                  l_p_batch_qte_line_dtl_tbl(j).config_revision_num = l_model_qte_line_dtl_tbl(i).config_revision_num THEN

                     l_send_index := l_send_index + 1;
                     l_send_qte_line_tbl(l_send_index)     := l_p_batch_qte_line_tbl(j);
                     l_send_qte_line_dtl_tbl(l_send_index) := l_p_batch_qte_line_dtl_tbl(j);

                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
				 aso_debug_pub.add('UPDATE_QUOTE: l_p_batch_qte_line_tbl('||j||').quote_line_id: '||l_p_batch_qte_line_tbl(j).quote_line_id,1,'N');
                     aso_debug_pub.add('UPDATE_QUOTE: l_p_batch_qte_line_tbl('||j||').quantity: '||l_p_batch_qte_line_tbl(j).quantity,1,'N');
                     aso_debug_pub.add('UPDATE_QUOTE: l_p_batch_qte_line_dtl_tbl('||j||').component_code: '||l_p_batch_qte_line_dtl_tbl(j).component_code,1,'N');
				 END IF;
               END IF;
           END LOOP;

		 l_control_rec_bv.header_pricing_event  :=  null;
		 l_control_rec_bv.calculate_tax_flag    :=  'N';
		 l_control_rec_bv.defaulting_fwk_flag   :=  'N';

           -- Call Batch Validation procedure
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
		 aso_debug_pub.add('UPDATE_QUOTE: Before call to Validate_Configuration',1,'N');
		 END IF;

           ASO_CFG_INT.Validate_Configuration
               ( P_Api_Version_Number           =>  1.0,
                 P_Init_Msg_List                =>  FND_API.G_FALSE,
                 P_Commit                       =>  FND_API.G_FALSE,
                 p_control_rec                  =>  l_control_rec_bv,
                 P_model_line_id                =>  l_model_qte_line_tbl(i).quote_line_id,
                 P_Qte_Line_Tbl                 =>  l_send_qte_line_tbl,
                 P_Qte_Line_Dtl_Tbl             =>  l_send_qte_line_dtl_tbl,
                 X_config_header_id             =>  l_config_header_id,
                 X_config_revision_num          =>  l_config_revision_num,
                 X_valid_configuration_flag     =>  l_valid_configuration_flag,
                 X_complete_configuration_flag  =>  l_complete_configuration_flag,
                 X_return_status                =>  l_return_status,
                 X_msg_count                    =>  x_msg_count,
                 X_msg_data                     =>  x_msg_data
                );

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
		     aso_debug_pub.add('UPDATE_QUOTE: After call to Validate_Configuration: l_return_status: '||l_return_status,1,'Y');
		     aso_debug_pub.add('UPDATE_QUOTE: l_config_header_id:            '|| l_config_header_id,1,'N');
		     aso_debug_pub.add('UPDATE_QUOTE: l_config_revision_num:         '|| l_config_revision_num,1,'N');
		     aso_debug_pub.add('UPDATE_QUOTE: l_valid_configuration_flag:    '|| l_valid_configuration_flag,1,'N');
		     aso_debug_pub.add('UPDATE_QUOTE: l_complete_configuration_flag: '|| l_complete_configuration_flag,1,'N');
		 END IF;

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

               open c_config_exist_in_cz(l_config_header_id, l_config_revision_num);
               fetch c_config_exist_in_cz into l_new_config_hdr_id;

               if c_config_exist_in_cz%found then

                   close c_config_exist_in_cz;

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('Update Quote: A higher version exist for this configuration so deleting it from CZ');
                   END IF;

                   ASO_CFG_INT.DELETE_CONFIGURATION_AUTO( P_API_VERSION_NUMBER  => 1.0,
                                                          P_INIT_MSG_LIST       => FND_API.G_FALSE,
                                                          P_CONFIG_HDR_ID       => l_config_header_id,
                                                          P_CONFIG_REV_NBR      => l_config_revision_num,
                                                          X_RETURN_STATUS       => x_return_status,
                                                          X_MSG_COUNT           => x_msg_count,
                                                          X_MSG_DATA            => x_msg_data);

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('After call to ASO_CFG_INT.DELETE_CONFIGURATION_AUTO: x_Return_Status: ' || x_Return_Status);
                   END IF;

                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                          FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
                          FND_MESSAGE.Set_Token('OBJECT', 'CONFIGURATION', FALSE);
                          FND_MSG_PUB.ADD;
                       END IF;

                       RAISE FND_API.G_EXC_ERROR;

                   END IF;

               else
                   close c_config_exist_in_cz;
               end if;

           END IF;

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
           END IF;

       END IF; --l_delete_qte_line_tbl.EXISTS
   END LOOP; --l_model_qte_line_tbl.count

   --call Aso_Config_Operations_Int.Config_Operations procedure
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Update_Quote: l_deactivate_quote_line_tbl.count: ' || l_deactivate_quote_line_tbl.count);
   END IF;

   if l_deactivate_quote_line_tbl.count > 0 then

	  l_control_rec_bv.header_pricing_event  :=  null;
	  l_control_rec_bv.calculate_tax_flag    :=  'N';
	  l_control_rec_bv.defaulting_fwk_flag   :=  'N';

       l_deactivate_qte_header_rec := x_qte_header_rec;

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Before call to  Aso_Config_Operations_Int.Config_Operations.', 1, 'Y');
       END IF;

       Aso_Config_Operations_Int.Config_Operations(
              p_api_version_number => 1.0,
              p_init_msg_list      => FND_API.G_FALSE,
              p_commit             => FND_API.G_FALSE,
              p_validation_level   => p_validation_level,
              p_control_rec        => l_control_rec_bv,
              p_qte_header_rec     => l_deactivate_qte_header_rec,
              p_qte_line_tbl       => l_deactivate_quote_line_tbl,
              p_instance_tbl       => l_deactivate_instance_tbl,
              p_operation_code     => aso_quote_pub.g_deactivate,
              p_delete_flag        => fnd_api.g_false,
              x_Qte_Header_Rec     => x_Qte_Header_Rec,
              x_return_status      => x_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data);
/*

       ASO_CONFIG_OPERATIONS_PVT.Deactivate_from_quote(
              P_Api_Version_Number     => 1.0,
              P_Init_Msg_List           => FND_API.G_FALSE,
              P_Commit                 => FND_API.G_FALSE,
              p_validation_level       => p_validation_level,
              P_Control_Rec            => l_control_rec_bv,
              P_Qte_Header_Rec          => l_deactivate_qte_header_rec,
              P_Qte_line_tbl           => l_deactivate_quote_line_tbl,
              p_delete_flag            => fnd_api.g_false,
              X_qte_header_rec        => x_Qte_Header_Rec,
              X_Return_Status           => X_Return_Status,
              X_Msg_Count              => X_Msg_Count,
              X_Msg_Data               => X_Msg_Data );
*/

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('After call to Aso_Config_Operations_Int.Config_Operations: x_Return_Status: ' || x_Return_Status, 1, 'Y');
        END IF;

   end if;

   --End of call to Aso_Config_Operations_Int.Config_Operations procedure

END IF; -- l_qte_header_rec.Call_batch_validation_flag = FND_API.G_TRUE

--End of New code for Batch Validate 05/24/2002


      -- update price adj relationships
      FOR i IN 1..p_price_adj_rltship_tbl.count LOOP
	l_price_adj_rltship_rec := p_price_adj_rltship_tbl(i);
	l_index := l_price_adj_rltship_rec.qte_line_index;
	IF l_index IS NOT NULL AND l_index >=1 AND
		l_index <= x_qte_line_tbl.count THEN
	  l_price_adj_rltship_rec.quote_line_id := x_qte_line_tbl(l_index).quote_line_id;
	END IF;
	l_index := l_price_adj_rltship_rec.price_adj_index;
	IF l_index IS NOT NULL AND l_index >=1 AND
		l_index <= x_price_adjustment_tbl.count THEN
	  l_price_adj_rltship_rec.price_adjustment_id :=
		l_price_adjustment_tbl(l_index).price_adjustment_id;
	END IF;
	l_index := l_price_adj_rltship_rec.RLTD_PRICE_ADJ_INDEX;
	IF l_index IS NOT NULL AND l_index >=1 AND
		l_index <= x_price_adjustment_tbl.count THEN
	  l_price_adj_rltship_rec.rltd_price_adj_id :=
		l_price_adjustment_tbl(l_index).price_adjustment_id;
	END IF;
	IF l_price_adj_rltship_rec.operation_code = 'CREATE' THEN
	    -- BC4J Fix
	    --l_price_adj_rltship_rec.ADJ_RELATIONSHIP_ID := NULL;
	    ASO_PRICE_RLTSHIPS_PKG.Insert_Row(
		px_ADJ_RELATIONSHIP_ID	=> l_price_adj_rltship_rec.ADJ_RELATIONSHIP_ID,
		p_creation_date		=> sysdate,
		p_CREATED_BY		=> G_USER_ID,
		p_LAST_UPDATE_DATE	=> sysdate,
		p_LAST_UPDATED_BY	=> G_USER_ID,
		p_LAST_UPDATE_LOGIN	=> G_USER_ID,
		p_PROGRAM_APPLICATION_ID=> l_price_adj_rltship_rec.PROGRAM_APPLICATION_ID,
		p_PROGRAM_ID		=> l_price_adj_rltship_rec.PROGRAM_ID,
		p_PROGRAM_UPDATE_DATE	=> l_price_adj_rltship_rec.PROGRAM_UPDATE_DATE,
		p_REQUEST_ID		=> l_price_adj_rltship_rec.REQUEST_ID,
		p_QUOTE_LINE_ID		=> l_price_adj_rltship_rec.quote_line_id,
		p_PRICE_ADJUSTMENT_ID	=> l_price_adj_rltship_rec.price_adjustment_id,
		p_RLTD_PRICE_ADJ_ID	=> l_price_adj_rltship_rec.rltd_price_adj_id,
		p_QUOTE_SHIPMENT_ID	=> l_price_adj_rltship_rec.quote_shipment_id,
		p_OBJECT_VERSION_NUMBER => l_price_adj_rltship_rec.OBJECT_VERSION_NUMBER
		);
	ELSIF l_price_adj_rltship_rec.operation_code = 'UPDATE' THEN
	    ASO_PRICE_RLTSHIPS_PKG.Update_Row(
		p_ADJ_RELATIONSHIP_ID  => l_price_adj_rltship_rec.ADJ_RELATIONSHIP_ID,
		p_creation_date		=> l_price_adj_rltship_rec.creation_date,
		p_CREATED_BY		=> G_USER_ID,
		p_LAST_UPDATE_DATE	=> sysdate,
		p_LAST_UPDATED_BY	=> G_USER_ID,
		p_LAST_UPDATE_LOGIN	=> G_USER_ID,
		p_PROGRAM_APPLICATION_ID=> l_price_adj_rltship_rec.PROGRAM_APPLICATION_ID,
		p_PROGRAM_ID		=> l_price_adj_rltship_rec.PROGRAM_ID,
		p_PROGRAM_UPDATE_DATE	=> l_price_adj_rltship_rec.PROGRAM_UPDATE_DATE,
		p_REQUEST_ID		=> l_price_adj_rltship_rec.REQUEST_ID,
		p_QUOTE_LINE_ID		=> l_price_adj_rltship_rec.quote_line_id,
		p_PRICE_ADJUSTMENT_ID	=> l_price_adj_rltship_rec.price_adjustment_id,
		p_RLTD_PRICE_ADJ_ID	=> l_price_adj_rltship_rec.rltd_price_adj_id,
		p_QUOTE_SHIPMENT_ID	=> l_price_adj_rltship_rec.quote_shipment_id,
		p_OBJECT_VERSION_NUMBER => l_price_adj_rltship_rec.OBJECT_VERSION_NUMBER
		);
	ELSIF l_price_adj_rltship_rec.operation_code = 'DELETE' THEN
	    ASO_PRICE_RLTSHIPS_PKG.Delete_Row(
		p_ADJ_RELATIONSHIP_ID  => l_price_adj_rltship_rec.ADJ_RELATIONSHIP_ID);

	END IF;
	X_Price_Adj_Rltship_Tbl(i) := l_price_adj_rltship_rec;


      END LOOP;

--start bug8235510
for i in 1 ..x_qte_line_dtl_tbl.count
loop
aso_debug_pub.ADD('x_qte_line_dtl_tbl.quot_line_id' || x_qte_line_dtl_tbl(i).quote_line_id);
aso_debug_pub.ADD('x_qte_line_dtl_tbl.quot_line_detail_id' || x_qte_line_dtl_tbl(i).quote_line_detail_id);
aso_debug_pub.ADD('x_qte_line_dtl_tbl.ref_line_id' || x_qte_line_dtl_tbl(i).ref_line_id);
end loop;
FOR i in 1..x_qte_line_tbl.count LOOP
l_line_rltship_rec := ASO_QUOTE_PUB.G_Miss_Line_Rltship_Rec;
x_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(x_qte_line_tbl(i).quote_line_id);
IF x_qte_line_dtl_tbl.count > 0 THEN
IF x_qte_line_dtl_tbl(1).ref_line_id IS NOT NULL AND x_qte_line_dtl_tbl(1).ref_line_id <> FND_API.G_MISS_NUM THEN
   -- Adding a check to find if find line relationship already exists bug 12608111 to avoid data corruption in aso_line_relationships
     select count(*) into  ct_rel
     from aso_line_relationships
     where quote_line_id = x_qte_line_dtl_tbl(1).ref_line_id
     and related_quote_line_id = x_qte_line_dtl_tbl(1).quote_line_id
     and relationship_type_code='CONFIG';
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('before l_line_rltship_rec Create_Line_Rltship ct_rel'||ct_rel);
     end if;
     if ct_rel=0 then
                		l_line_rltship_rec.OPERATION_CODE         := 'CREATE';
                		l_line_rltship_rec.QUOTE_LINE_ID          := x_qte_line_dtl_tbl(1).ref_line_id;
                		l_line_rltship_rec.RELATED_QUOTE_LINE_ID  := x_qte_line_dtl_tbl(1).quote_line_id;
                		l_line_rltship_rec.RELATIONSHIP_TYPE_CODE := 'CONFIG';

		ASO_LINE_RLTSHIP_PVT.Create_Line_Rltship(
                    P_Api_Version_Number   => 1.0,
                    P_Init_Msg_List        => FND_API.G_FALSE,
                    P_Commit               => FND_API.G_FALSE,
                    P_Validation_Level     => p_validation_level,
                    P_Line_Rltship_Rec     => l_line_rltship_rec,
                    X_LINE_RELATIONSHIP_ID => lx_line_relationship_id,
                    X_Return_Status        => x_return_status,
                    X_Msg_Count            => x_msg_count,
                    X_Msg_Data             => x_msg_data
                );
 end if; -- ct_rel=0
end if;
end if;
end loop;
--end bug8235510
      -- update line relationships
      FOR i IN 1..p_line_rltship_tbl.count LOOP
	l_line_rltship_rec := p_line_rltship_tbl(i);
	l_index := l_line_rltship_rec.qte_line_index;
	IF l_index IS NOT NULL AND l_index >=1 AND
		l_index <= x_qte_line_tbl.count THEN
	  l_line_rltship_rec.quote_line_id := x_qte_line_tbl(l_index).quote_line_id;
	END IF;
	l_index := l_line_rltship_rec.related_qte_line_index;
	IF l_index IS NOT NULL AND l_index >=1 AND
		l_index <= x_qte_line_tbl.count THEN
	  l_line_rltship_rec.related_quote_line_id := x_qte_line_tbl(l_index).quote_line_id;
	END IF;
	IF l_line_rltship_rec.operation_code = 'CREATE' THEN
	    -- BC4J Fix
	    --l_line_rltship_rec.LINE_RELATIONSHIP_ID := NULL;
	    ASO_LINE_RELATIONSHIPS_PKG.Insert_Row(
		px_LINE_RELATIONSHIP_ID  => l_line_rltship_rec.LINE_RELATIONSHIP_ID,
		p_CREATION_DATE  => SYSDATE,
		p_CREATED_BY  => G_USER_ID,
		p_LAST_UPDATED_BY  => G_USER_ID,
		p_LAST_UPDATE_DATE  => SYSDATE,
		p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
		p_REQUEST_ID  => l_line_rltship_rec.REQUEST_ID,
		p_PROGRAM_APPLICATION_ID  => l_line_rltship_rec.PROGRAM_APPLICATION_ID,
		p_PROGRAM_ID  => l_line_rltship_rec.PROGRAM_ID,
		p_PROGRAM_UPDATE_DATE  =>l_line_rltship_rec.PROGRAM_UPDATE_DATE,
		p_QUOTE_LINE_ID  => l_line_rltship_rec.quote_line_id,
		p_RELATED_QUOTE_LINE_ID  => l_line_rltship_rec.RELATED_QUOTE_LINE_ID,
		p_RECIPROCAL_FLAG  => l_line_rltship_rec.RECIPROCAL_FLAG,
		P_RELATIONSHIP_TYPE_CODE =>l_line_rltship_rec.RELATIONSHIP_TYPE_CODE,
		p_OBJECT_VERSION_NUMBER => l_line_rltship_rec.OBJECT_VERSION_NUMBER
		);
	ELSIF l_line_rltship_rec.operation_code = 'UPDATE' THEN
	    ASO_LINE_RELATIONSHIPS_PKG.Update_Row(
		p_LINE_RELATIONSHIP_ID	=> l_line_rltship_rec.LINE_RELATIONSHIP_ID,
		p_CREATION_DATE  => l_line_rltship_rec.creation_date,
		p_CREATED_BY  => G_USER_ID,
		p_LAST_UPDATED_BY  => G_USER_ID,
		p_LAST_UPDATE_DATE  => SYSDATE,
		p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
		p_REQUEST_ID  => l_line_rltship_rec.REQUEST_ID,
		p_PROGRAM_APPLICATION_ID  => l_line_rltship_rec.PROGRAM_APPLICATION_ID,
		p_PROGRAM_ID  => l_line_rltship_rec.PROGRAM_ID,
		p_PROGRAM_UPDATE_DATE  =>l_line_rltship_rec.PROGRAM_UPDATE_DATE,
		p_QUOTE_LINE_ID  => l_line_rltship_rec.quote_line_id,
		p_RELATED_QUOTE_LINE_ID  => l_line_rltship_rec.RELATED_QUOTE_LINE_ID,
		p_RECIPROCAL_FLAG  => l_line_rltship_rec.RECIPROCAL_FLAG,
		P_RELATIONSHIP_TYPE_CODE =>l_line_rltship_rec.RELATIONSHIP_TYPE_CODE,
		p_OBJECT_VERSION_NUMBER => l_line_rltship_rec.OBJECT_VERSION_NUMBER
		);
	ELSIF l_line_rltship_rec.operation_code = 'DELETE' THEN
	    ASO_LINE_RELATIONSHIPS_PKG.delete_Row(
		p_LINE_RELATIONSHIP_ID	=> l_line_rltship_rec.LINE_RELATIONSHIP_ID);
	END IF;
	X_line_Rltship_Tbl(i) := l_line_rltship_rec;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
 	   aso_debug_pub.add('Update_Quote: l_line_rltship_rec.quote_line_id:         '||l_line_rltship_rec.quote_line_id);
        aso_debug_pub.add('Update_Quote: l_line_rltship_rec.related_quote_line_id: '||l_line_rltship_rec.related_quote_line_id);
     END IF;

     if l_line_rltship_rec.relationship_type_code = 'CONFIG' and
        (l_line_rltship_rec.operation_code = 'CREATE' or
         l_line_rltship_rec.operation_code = 'UPDATE') then

          update aso_quote_line_details
          set ref_type_code      =  'CONFIG',
              ref_line_id        =  l_line_rltship_rec.quote_line_id,
              last_update_date   =  sysdate,
              last_updated_by    =  g_user_id,
              last_update_login  =  g_login_id
          where quote_line_id = l_line_rltship_rec.related_quote_line_id;

     end if;

     END LOOP;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.add('Update_Quote: x_qte_header_rec.quote_header_id: '|| x_qte_header_rec.quote_header_id);
     END IF;

     update aso_quote_line_details
     set ref_type_code      =  'CONFIG',
         last_update_date   =  sysdate,
         last_updated_by    =  g_user_id,
         last_update_login  =  g_login_id
     where config_header_id is not null
     and config_revision_num is not null
     and ref_type_code is null
     and quote_line_id in (select quote_line_id from aso_quote_lines_all
                           where item_type_code = 'MDL'
                           and quote_header_id  = x_qte_header_rec.quote_header_id);

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.add('Update_Quote: Validating line type if Order type has changed');
       aso_debug_pub.add('Update_Quote: l_qte_header_rec.order_type_id: '||l_qte_header_rec.order_type_id);
    END IF;


     IF ((l_order_type_id <> l_qte_header_rec.order_type_id) AND (l_qte_header_rec.order_type_id <> FND_API.G_MISS_NUM)) then

          For quote_lines_rec IN c_quote_lines(l_qte_header_rec.quote_header_id) LOOP

                l_ln_rec.quote_line_id      :=  quote_lines_rec.quote_line_id;
                l_ln_rec.order_line_type_id :=  quote_lines_rec.order_line_type_id;
                l_ln_rec.line_category_code :=  quote_lines_rec.line_category_code;


                    --Validate_ln_type_for_ord_type

                    ASO_validate_PVT.Validate_ln_type_for_ord_type(
                        p_init_msg_list     =>   FND_API.G_FALSE,
                        p_qte_header_rec    =>   l_qte_header_rec,
                        P_Qte_Line_rec      =>   l_ln_rec,
                        x_return_status     =>   x_return_status,
                        x_msg_count         =>   x_msg_count,
                        x_msg_data          =>   x_msg_data);

                    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    --Validate_ln_category_code

                    ASO_validate_PVT.Validate_ln_category_code(
                        p_init_msg_list     =>   FND_API.G_FALSE,
                        p_qte_header_rec    =>   l_qte_header_rec,
                        P_Qte_Line_rec      =>   l_ln_rec,
                        x_return_status     =>   x_return_status,
                        x_msg_count         =>   x_msg_count,
                        x_msg_data          =>   x_msg_data);

                    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;


       END LOOP;
   End if;


      	aso_validate_pvt.Validate_po_line_number
		(
			p_init_msg_list	  => fnd_api.g_false,
			p_qte_header_rec    => l_qte_header_rec,
			x_return_status     => x_return_status,
			x_msg_count         => x_msg_count,
			x_msg_data          => x_msg_data);

		IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
            END IF;



	IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('Update_Quote - before header_pricing ', 1, 'N');
	END IF;

     IF l_control_rec.header_pricing_event IS NOT NULL AND
	   l_control_rec.header_pricing_event <> FND_API.G_MISS_CHAR THEN

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.add('Update_Quote - in header_pricing ', 1, 'N');
	   END IF;

	   l_pricing_control_rec.request_type  := p_control_rec.pricing_request_type;
	   l_pricing_control_rec.pricing_event := p_control_rec.header_pricing_event;
	   l_pricing_control_rec.price_mode    := p_control_rec.price_mode;

        --New Code for to call overload pricing_order

        lv_qte_header_rec    := aso_utility_pvt.query_header_row(x_qte_header_rec.quote_header_id);
        lv_hd_price_attr_tbl := aso_utility_pvt.query_price_attr_rows(x_qte_header_rec.quote_header_id,null);
        lv_hd_shipment_tbl   := aso_utility_pvt.query_shipment_rows(x_qte_header_rec.quote_header_id,null);

        if lv_hd_shipment_tbl.count = 1 then
            lv_hd_shipment_rec := lv_hd_shipment_tbl(1);
        end if;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Update_Quote: Before call to ASO_PRICING_INT.Pricing_Order');
            aso_debug_pub.add('Update_Quote: x_qte_line_tbl.count:  ' || x_qte_line_tbl.count);
        END IF;

        ASO_PRICING_INT.Pricing_Order(
                    P_Api_Version_Number     => 1.0,
                    P_Init_Msg_List          => fnd_api.g_false,
                    P_Commit                 => fnd_api.g_false,
                    p_control_rec            => l_pricing_control_rec,
                    p_qte_header_rec         => lv_qte_header_rec,
                    p_hd_shipment_rec        => lv_hd_shipment_rec,
                    p_hd_price_attr_tbl      => lv_hd_price_attr_tbl,
                    p_qte_line_tbl           => x_qte_line_tbl,
                    --p_line_rltship_tbl     => l_line_rltship_tbl,
                    --p_qte_line_dtl_tbl     => l_qte_line_dtl_tbl,
                    --p_ln_shipment_tbl      => ln_shipment_tbl,
                    --p_ln_price_attr_tbl    => l_ln_price_attr_tbl,
                    x_qte_header_rec         => lx_qte_header_rec,
                    x_qte_line_tbl           => lx_qte_line_tbl,
                    x_qte_line_dtl_tbl       => lx_qte_line_dtl_tbl,
                    x_price_adj_tbl          => l_price_adj_tbl_out,
                    x_price_adj_attr_tbl     => l_Price_Adj_Attr_Tbl_out,
                    x_price_adj_rltship_tbl  => lx_price_adj_rltship_tbl,
                    x_return_status          => l_return_status,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data );


        x_qte_line_tbl := lx_qte_line_tbl;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Update_Quote: After call to ASO_PRICING_INT.Pricing_Order');
	       aso_debug_pub.add('Update_Quote: l_return_status:       ' || l_return_status);
            aso_debug_pub.add('Update_Quote: lx_qte_line_tbl.count: ' || lx_qte_line_tbl.count);
            aso_debug_pub.add('Update_Quote: x_qte_line_tbl.count:  ' || x_qte_line_tbl.count);
        END IF;

	   IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

	         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

	   	        FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
	 	        FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER', TRUE);
		        FND_MSG_PUB.ADD;

	         END IF;

	         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	   ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN

	         x_return_status := FND_API.G_RET_STS_ERROR;
              RAISE FND_API.G_EXC_ERROR;

	   END IF;

     END IF;


     /*New Pricing Changes to update the date*/


     IF p_control_rec.header_pricing_event = 'BATCH' and
        p_control_rec.price_mode='ENTIRE_QUOTE' THEN

          l_price_updated_date_flag := fnd_api.g_true;

     END IF;


             -- kchervel calculating tax for the whole quote
      IF p_control_rec.calculate_tax_flag = 'Y' THEN

	 --Added the IF Condition below to facilitate TAX calculation changes .
       	IF l_qte_line_tbl.count >0 then
		l_lines:=1;
	else
		SELECT
			COUNT(QUOTE_HEADER_ID)
		INTO
			l_lines
		FROM
			ASO_QUOTE_LINES_ALL
		WHERE
			QUOTE_HEADER_ID=x_qte_header_rec.quote_header_id;
	END IF;

	--Commented the Below lines by Anoop on 15th August
	/*  l_tax_control_rec.tax_level := 'SHIPPING';
         l_tax_control_rec.update_DB := 'Y';
	ASO_TAX_INT.Calculate_Tax(
		P_Api_Version_Number => 1.0,
		p_quote_header_id    => x_qte_header_rec.quote_header_id,
		P_Tax_Control_Rec    => l_tax_control_rec,
		x_tax_amount	     => x_tax_amount    ,
		x_tax_detail_tbl    => l_tax_detail_tbl,
		X_Return_Status     => x_return_status ,
		X_Msg_Count         => x_msg_count     ,
		X_Msg_Data           => x_msg_data      );
	*/


--Changed the call to Tax API as a part of eTAX  by Anoop Rajan on August 9 2005
IF l_lines>0 then
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('Update_Quote: Before call to tax engine');

    	    aso_debug_pub.add('Calculate Tax Flag : '|| p_control_rec.calculate_tax_flag);
	END IF;
	ASO_TAX_INT.CALCULATE_TAX_WITH_GTT (	p_API_VERSION_NUMBER => 1.0,
						p_qte_header_id => x_qte_header_rec.quote_header_id,
						x_return_status =>   x_return_status ,
						X_Msg_Count =>	x_msg_count     ,
						X_Msg_Data =>  x_msg_data      );

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('Update_Quote: After call to tax engine');
	END IF;
else
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Update_Quote: NO LINE RECORDS.SO TAX NOT CALCULATED : x_return_status: '|| x_return_status, 1, 'Y');
	END IF;
end if;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
	       FND_MESSAGE.Set_Token('API', 'CALCULATE_TAX_WITH_GTT', FALSE);
	       FND_MSG_PUB.ADD;
       END IF;

       IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

      END IF;

      END IF; -- tax flag set


      /*New Tax Changes to update the date*/

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN

	    aso_debug_pub.add('Update_Quote: control record parameter values');
	    aso_debug_pub.add('p_control_rec.header_pricing_event: ' || p_control_rec.header_pricing_event);
	    aso_debug_pub.add('p_control_rec.price_mode:           ' || p_control_rec.price_mode);
	    aso_debug_pub.add('p_control_rec.calculate_tax_flag:   ' || p_control_rec.calculate_tax_flag);
	    aso_debug_pub.add('l_price_updated_date_flag:          ' || l_price_updated_date_flag);

	 END IF;

      IF p_control_rec.calculate_tax_flag = 'Y' THEN

          IF l_price_updated_date_flag = fnd_api.g_true THEN

              update aso_quote_headers_all
              set tax_updated_date   = sysdate,
                  price_updated_date = sysdate,
			   recalculate_flag   = 'N'
              where quote_header_id = x_qte_header_rec.quote_header_id;

          ELSE

              update aso_quote_headers_all
              set tax_updated_date   = sysdate
              where quote_header_id = x_qte_header_rec.quote_header_id;

          END IF;

      ELSIF l_price_updated_date_flag = fnd_api.g_true THEN

          update aso_quote_headers_all
          set price_updated_date = sysdate,
		    recalculate_flag   = 'N'
          where quote_header_id = x_qte_header_rec.quote_header_id;

      END IF;



      -- Update Quote total info (do summation to get TOTAL_LIST_PRICE,
      -- TOTAL_ADJUSTED_AMOUNT, TOTAL_TAX, TOTAL_SHIPPING_CHARGE, SURCHARGE,
      -- TOTAL_QUOTE_PRICE, PAYMENT_AMOUNT)
      -- IF calculate_tax_flag = 'N', not summation on line level tax,
      -- just take the value of l_qte_header_rec.total_tax as the total_tax
      -- IF calculate_Freight_Charge = 'N', not summation on line level freight charge,
      -- just take the value of l_qte_header_rec.total_freight_charge
      -- (or l_hd_shipment_tbl(1).total_freight_charge???) as the TOTAL_SHIPPING_CHARGE


      IF p_control_rec.calculate_tax_flag = 'N' AND
		 l_qte_header_rec.total_tax IS NOT NULL THEN
	  l_calculate_tax := 'N';
      END IF;
      IF p_control_rec.calculate_freight_charge_flag = 'N' AND
		l_qte_header_rec.total_shipping_charge IS NOT NULL THEN
	  l_calculate_freight_charge := 'N';
      END IF;


      -- Start of PNPL Changes
      x_qte_header_rec := aso_utility_pvt.query_header_row(x_qte_header_rec.quote_header_id);

      l_installment_option := oe_sys_parameters.value(param_name => 'INSTALLMENT_OPTIONS',
                                                                     p_org_id =>x_qte_header_rec.org_id);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote - Value of Installment Option Param: '||l_installment_option, 1, 'Y');
      END IF;

       IF (  (l_installment_option = 'ENABLE_PAY_NOW') and (nvl(x_qte_header_rec.quote_type,'X') <>  'T')
            and ((p_control_rec.header_pricing_event <> FND_API.G_MISS_CHAR and p_control_rec.header_pricing_event is not null)
              or (p_control_rec.calculate_tax_flag = 'Y'))   ) then

           l_call_ar_api :=  fnd_api.g_true;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Update_Quote - p_control_rec.header_pricing_event: '||p_control_rec.header_pricing_event, 1, 'Y');
             aso_debug_pub.add('Update_Quote - p_control_rec.price_mode          : '||p_control_rec.price_mode, 1, 'Y');
             aso_debug_pub.add('Update_Quote - l_qte_line_tbl.count              : '||l_qte_line_tbl.count, 1, 'Y');
           END IF;

         -- check if price_mode is change_line, if so then call ar api only if some lines are being created or updated
	    IF (p_control_rec.header_pricing_event = 'BATCH' and p_control_rec.price_mode = 'CHANGE_LINE') THEN
               if (l_qte_line_tbl.count > 0) then
                  l_call_ar_api :=  fnd_api.g_false;
                  for i in 1..l_qte_line_tbl.count loop
			    if (l_qte_line_tbl(i).operation_code = 'CREATE' or l_qte_line_tbl(i).operation_code = 'UPDATE')  then
			     l_call_ar_api :=  fnd_api.g_true;
				exit;
			    end if;
			   end loop;
			else
			 l_call_ar_api :=  fnd_api.g_false;
			end if;
	    END IF;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Update_Quote - l_call_ar_api: '|| l_call_ar_api, 1, 'Y');
           END IF;

     IF (l_call_ar_api = fnd_api.g_true ) then

       For quote_lines_rec IN c_quote_lines(x_qte_header_rec.quote_header_id) LOOP

          -- resetting the line term id variable
          l_line_term_id := null;

       -- get the line freight charges
          l_line_shipping_charge := aso_shipping_int.get_line_freight_charges( x_qte_header_rec.quote_header_id,
                                                                               quote_lines_rec.quote_line_id );

       -- get the line tax
          open c_tax_line(x_qte_header_rec.quote_header_id,quote_lines_rec.quote_line_id);
          fetch c_tax_line into l_line_tax;
          close c_tax_line;

       -- get the payment term id for the line
          open get_line_payment_term(x_qte_header_rec.quote_header_id,quote_lines_rec.quote_line_id);
          fetch get_line_payment_term into l_line_term_id;
          close get_line_payment_term;

           -- if line term id is null then get it from header
           If l_line_term_id is null  THEN
               open get_hdr_payment_term(x_qte_header_rec.quote_header_id);
               fetch get_hdr_payment_term into l_line_term_id;
               close get_hdr_payment_term;
           END IF;

      l_line_amount := quote_lines_rec.line_quote_price * quote_lines_rec.quantity;


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Update_Quote - ********** Input to AR_VIEW_TERM_GRP.pay_now_amounts follows ********** ', 1, 'Y');
		aso_debug_pub.add('Update_Quote - quote_lines_rec.quote_line_id: '||quote_lines_rec.quote_line_id, 1, 'Y');
          aso_debug_pub.add('Update_Quote - l_line_amount:                 '||l_line_amount, 1, 'Y');
          aso_debug_pub.add('Update_Quote - l_line_shipping_charge:        '||l_line_shipping_charge, 1, 'Y');
          aso_debug_pub.add('Update_Quote - l_line_tax:                    '||l_line_tax, 1, 'Y');
          aso_debug_pub.add('Update_Quote - l_line_term_id:                '||l_line_term_id, 1, 'Y');
	 END IF;

      IF (l_line_term_id is not null and l_line_term_id <> fnd_api.g_miss_num) then

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote: before call to AR_VIEW_TERM_GRP.pay_now_amounts', 1, 'Y');
      END IF;

       -- Call the AR API to get the amounts
             AR_VIEW_TERM_GRP.pay_now_amounts(
                    p_api_version              => 1.0,
                    p_init_msg_list            => p_init_msg_list,
                    p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
                    p_term_id                  => l_line_term_id,
                    p_currency_code            => x_qte_header_rec.currency_code,
                    p_line_amount              => l_line_amount,
                    p_tax_amount               => l_line_tax,
                    p_freight_amount           => l_line_shipping_charge,
                    x_pay_now_line_amount      => l_paynow_amount,
                    x_pay_now_tax_amount       => l_paynow_tax,
                    x_pay_now_freight_amount   => l_paynow_charges,
                    x_pay_now_total_amount     => l_paynow_total,
                    X_Return_Status            => x_return_status ,
                    X_Msg_Count                => x_msg_count     ,
                    X_Msg_Data                 => x_msg_data      );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
		    aso_debug_pub.add('Update_Quote: After call to AR_VIEW_TERM_GRP.pay_now_amounts: x_return_status: '|| x_return_status, 1, 'Y');          END IF;

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                  FND_MESSAGE.Set_Token('API', 'AR_PayNow_Amounts', FALSE);
                  FND_MSG_PUB.ADD;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Update_Quote - Output from AR_VIEW_TERM_GRP.pay_now_amounts follows:', 1, 'Y');
        aso_debug_pub.add('Update_Quote - l_paynow_amount:         '||l_paynow_amount, 1, 'Y');
        aso_debug_pub.add('Update_Quote - l_paynow_charges:        '||l_paynow_charges, 1, 'Y');
        aso_debug_pub.add('Update_Quote - l_paynow_tax:            '||l_paynow_tax, 1, 'Y');
        aso_debug_pub.add('Update_Quote - l_paynow_total:          '||l_paynow_total, 1, 'Y');
        aso_debug_pub.add('Update_Quote - ************  End  PNPL Processing ************ ', 1, 'Y');
      END IF;


          -- Update the corresponding columns in the line table
          update aso_quote_lines_all
          set line_paynow_charges    = l_paynow_charges,
              line_paynow_tax        = l_paynow_tax,
              line_paynow_subtotal   = l_paynow_amount,
              last_update_date       =  sysdate,
              last_updated_by        =  fnd_global.user_id,
              last_update_login      =  fnd_global.conc_login_id
          where quote_line_id = quote_lines_rec.quote_line_id;

        end if; -- check for term id null
       end loop;

    END IF; -- end if for call ar api flag
   END IF;

      -- End of PNPL Changes

            -- cost ER
    For line_cur in (select quote_line_id
                   from aso_quote_lines_all
		   where quote_header_id=x_Qte_Header_rec.quote_header_id) loop
      BEGIN
           ASO_MARGIN_PVT.Get_Line_Margin(p_qte_line_id => line_cur.quote_line_id,
                          x_unit_cost => l_unit_cost,
                          x_unit_margin_amount => l_margin_amount,
                          x_margin_percent => l_margin_percent);

       exception
        when no_data_found then
	  l_unit_cost:=null;
          l_margin_amount:=null;
          l_margin_percent:=null;
	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('Error NO Data Found in ASO_MARGIN_PVT.Get_Line_Margin');
	  end if;
        when others then
	   l_unit_cost:=null;
          l_margin_amount:=null;
          l_margin_percent:=null;
	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('Error When others in ASO_MARGIN_PVT.Get_Line_Margin');
	  end if;


      END;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update Quote quote_line_id'||line_cur.quote_line_id);
	  aso_debug_pub.add('Update Quote l_unit_cost'||l_unit_cost);
  	  aso_debug_pub.add('Update Quote l_margin_amount'||l_margin_amount);
  	  aso_debug_pub.add('Update Quote l_margin_percent'||l_margin_percent);
	end if;

         -- Update the corresponding columns in the line table
          update aso_quote_lines_all
          set LINE_UNIT_COST    = l_unit_cost,
              LINE_MARGIN_AMOUNT    = l_margin_amount,
              LINE_MARGIN_PERCENT   = l_margin_percent,
              last_update_date       =  sysdate,
              last_updated_by        =  fnd_global.user_id,
              last_update_login      =  fnd_global.conc_login_id
          where quote_line_id = line_cur.quote_line_id;



         end loop;

-- end cost ER

      Update_Quote_Total (
			P_Qte_Header_id		  => x_Qte_Header_rec.quote_header_id,
			P_Calculate_Tax		  => p_control_rec.calculate_tax_flag,
			P_calculate_Freight_Charge => p_control_rec.calculate_freight_charge_flag,
               p_control_rec		       =>  p_control_rec,
               P_Call_Ar_Api_Flag         => l_call_ar_api,
			X_Return_Status 	       => x_return_status,
			X_Msg_Count		       => x_msg_count,
			X_Msg_Data		       => x_msg_data);

      x_qte_header_rec := aso_utility_pvt.query_header_row(x_qte_header_rec.quote_header_id);

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN


	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	          FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
	          FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER AFTER UPDT TOTAL', TRUE);
	          FND_MSG_PUB.ADD;
	      END IF;

	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN

	      RAISE FND_API.G_EXC_ERROR;

      END IF;

      --
      -- End of API body.
      --

      -- Change START
      -- Release 12 TAP Changes
      -- Girish Sachdeva 8/30/2005
      -- Adding the call to insert record in the ASO_CHANGED_QUOTES

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_QUOTE_HEADERS_PVT.UPDATE_QUOTE : Calling ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES, quote number : ' || x_qte_header_rec.quote_number, 1, 'Y');
      END IF;

      -- Call to insert record in ASO_CHANGED_QUOTES
      ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES(x_qte_header_rec.quote_number);

      -- Change END


      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
	     COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count	  =>   x_msg_count,
  	 p_data 	  =>   x_msg_data
      );

      EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_quote;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--	 The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_quote(
    P_Api_Version_Number	 IN   NUMBER,
    P_Init_Msg_List		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_Commit			 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_qte_Header_Id		 IN   NUMBER,
    X_Return_Status		 OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    X_Msg_Count 		 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    X_Msg_Data			 OUT NOCOPY /* file.sql.39 change */      VARCHAR2
    )

IS
    l_api_name		      CONSTANT VARCHAR2(30) := 'Delete_quote';
    l_api_version_number      CONSTANT NUMBER	:= 1.0;
     l_qln_id NUMBER;
    CURSOR c_qte_lines IS
	SELECT quote_line_id FROM ASO_QUOTE_LINES_ALL
	WHERE quote_header_id = p_qte_header_id;

    l_qte_line_rec		ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    CURSOR c_qte_line(l_d_qte_line NUMBER) IS
    SELECT quote_line_id  FROM ASO_QUOTE_LINES_ALL
    where quote_line_id= l_qte_line_rec.quote_line_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_quote_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
			 		     p_api_version_number,
					   l_api_name,
					   G_PKG_NAME)
      THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
	  FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Invoke table handler(ASO_QUOTE_HEADERS_PKG.Delete_Row)
	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add('Delete_Quote - Begin ', 1, 'Y');
	 END IF;

      ASO_QUOTE_HEADERS_PKG.Delete_Row(
	  p_QUOTE_HEADER_ID  => p_qte_header_id);

      FOR line_rec IN c_qte_lines LOOP
	  l_qte_line_rec.quote_line_id := line_rec.quote_line_id;
	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add('Delete_Quote - before delete_line- quote_line_id: '|| l_qte_line_rec.quote_line_id, 1, 'N');
	 END IF;

               OPEN c_qte_line(l_qte_line_rec.quote_line_id);
         FETCH c_qte_line into l_qln_id;
         IF c_qte_line%FOUND AND l_qln_id <> FND_API.G_MISS_NUM  THEN
	  ASO_QUOTE_LINES_PVT.Delete_Quote_Line(
		P_Api_Version_Number	=> 1.0,
		P_qte_line_Rec		=> l_qte_line_rec,
		P_Update_Header_Flag	=> FND_API.G_FALSE,
		X_Return_Status 	=> X_Return_Status,
		X_Msg_Count		=> X_Msg_Count,
		X_Msg_Data		=> X_Msg_Data);
          END IF;
          CLOSE c_qte_line;
	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	  END IF;
      END LOOP;


      --New code for Delete_Promotion 07/22/02

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add('Delete_Quote: Before deleting ASO_PRICE_ADJUSTMENTS table data',1,'N');
	 END IF;

      DELETE FROM ASO_PRICE_ADJUSTMENTS
      WHERE QUOTE_HEADER_ID = p_qte_header_id;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add('Delete_Quote: Before deleting ASO_PRICE_ADJ_ATTRIBS table data',1,'N');
	 END IF;

      DELETE FROM aso_price_adj_attribs
      WHERE price_adjustment_id IN (select price_adjustment_id
                                   from aso_price_adjustments
                                   where quote_header_id = p_qte_header_id
                                   and quote_line_id is NULL);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add('Delete_Quote: Before deleting ASO_PRICE_ATTRIBUTES table data',1,'N');
	 END IF;

      DELETE FROM ASO_PRICE_ATTRIBUTES
      WHERE QUOTE_HEADER_ID = p_qte_header_id
            and quote_line_id is NULL;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.add('Delete_Quote: After deleting ASO_PRICE_ATTRIBUTES table data',1,'N');
	 END IF;


      --End of New code for Delete_Promotion 07/22/02


      DELETE FROM ASO_PAYMENTS
	 WHERE QUOTE_HEADER_ID = p_qte_header_id;

      DELETE FROM ASO_FREIGHT_CHARGES
	 WHERE quote_shipment_id in
		(select shipment_id from  ASO_SHIPMENTS
		  where QUOTE_HEADER_ID = p_qte_header_id);

      DELETE FROM ASO_SHIPMENTS
	 WHERE QUOTE_HEADER_ID = p_qte_header_id;

      DELETE FROM ASO_TAX_DETAILS
	 WHERE QUOTE_HEADER_ID = p_qte_header_id;

      DELETE FROM ASO_SALES_CREDITS
	 WHERE QUOTE_HEADER_ID = p_qte_header_id;


      DELETE FROM ASO_QUOTE_PARTIES
	 WHERE QUOTE_HEADER_ID = p_qte_header_id;

      DELETE FROM ASO_QUOTE_LINE_ATTRIBS_EXT
    	 WHERE QUOTE_HEADER_ID = p_qte_header_id;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
	  COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count	  =>   x_msg_count,
	 p_data 	  =>   x_msg_data
      );

      EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_quote;

-- NAME
--   Copy_Quote
--
-- PURPOSE
--   Copy the quote (with quote_id = p_original_quote_id) to a new quote
--   (set original_quote_id = p_original_quote_id).
--   If p_header_only is FALSE, also copy all the associated quote lines
--   to new quote lines and create expected purchases for each line.
--

PROCEDURE Copy_Quote
(
    P_Api_Version_Number	 IN   NUMBER,
    P_Init_Msg_List		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_Commit			 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_control_rec         IN  ASO_QUOTE_PUB.control_rec_type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    p_validation_level		 IN   NUMBER	   := FND_API.G_VALID_LEVEL_FULL,
    P_Qte_Header_Id		 IN   NUMBER,
    P_Last_Update_Date		 IN   DATE,
    P_Copy_Only_Header		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_New_Version		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_Qte_Status_Id		 IN   NUMBER	   := NULL,
    P_Qte_Number		 IN   NUMBER	   := NULL,
    X_Qte_Header_Id		 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    X_Return_Status		 OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    X_Msg_Count 		 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    X_Msg_Data			 OUT NOCOPY /* file.sql.39 change */      VARCHAR2
) IS
/*  -- original cpy_qte
    CURSOR C_Validate_Quote (x_qte_header_id NUMBER) IS
	SELECT 'X'
	FROM ASO_QUOTE_HEADERS_ALL
	WHERE quote_header_id = x_qte_header_id;



    CURSOR c_line_relation (x_quote_header_id NUMBER) IS
	SELECT LINE_RELATIONSHIP_ID,
CREATION_DATE,
CREATED_BY,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
REQUEST_ID,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
QUOTE_LINE_ID,
RELATED_QUOTE_LINE_ID,
RELATIONSHIP_TYPE_CODE,
RECIPROCAL_FLAG FROM ASO_LINE_RELATIONSHIPS
	WHERE quote_line_id IN
		(SELECT quote_line_id FROM aso_quote_lines_all
		 WHERE quote_header_id = x_quote_header_id)
	  AND related_quote_line_id IN
		(SELECT quote_line_id FROM aso_quote_lines_all
		 WHERE quote_header_id = x_quote_header_id);
*/ -- original copy_qte

/* Commented by Biplabi Mishra to change the EXISTS to IN 07/09/01


    CURSOR c_line_relation (x_quote_header_id NUMBER) IS
	SELECT LINE_RELATIONSHIP_ID,
CREATION_DATE,
CREATED_BY,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
REQUEST_ID,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
QUOTE_LINE_ID,
RELATED_QUOTE_LINE_ID,
RELATIONSHIP_TYPE_CODE,
RECIPROCAL_FLAG FROM ASO_LINE_RELATIONSHIPS
	WHERE EXISTS
		(SELECT 'x' FROM aso_quote_lines_all aql
		 WHERE aql.quote_header_id = x_quote_header_id
                 AND aql.quote_line_id = aso_line_relationships.quote_line_id)
	  AND EXISTS
                (SELECT 'x' FROM aso_quote_lines_all aql
		 WHERE aql.quote_header_id = x_quote_header_id
                 AND aql.quote_line_id = aso_line_relationships.related_quote_line_id);

*/


/* Commented by Biplabi Mishra to change the IN to EXISTS 04/30/01

    CURSOR c_price_adj_rel (x_quote_header_id NUMBER) IS
	SELECT
    QUOTE_SHIPMENT_ID,
SECURITY_GROUP_ID,
OBJECT_VERSION_NUMBER,
ADJ_RELATIONSHIP_ID,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
REQUEST_ID,
QUOTE_LINE_ID,
PRICE_ADJUSTMENT_ID,
RLTD_PRICE_ADJ_ID
 FROM ASO_PRICE_ADJ_RELATIONSHIPS
	WHERE price_adjustment_id IN
		(SELECT price_adjustment_id FROM aso_price_adjustments
		 WHERE quote_header_id = x_quote_header_id)
	  AND quote_line_id IN
		(SELECT quote_line_id FROM aso_quote_lines_all
		 WHERE quote_header_id = x_quote_header_id);
*/
/*
CURSOR c_price_adj_rel (x_quote_header_id NUMBER) IS
        SELECT
apr.QUOTE_SHIPMENT_ID,
--apr.SECURITY_GROUP_ID,
apr.OBJECT_VERSION_NUMBER,
apr.ADJ_RELATIONSHIP_ID,
apr.CREATION_DATE,
apr.CREATED_BY,
apr.LAST_UPDATE_DATE,
apr.LAST_UPDATED_BY,
apr.LAST_UPDATE_LOGIN,
apr.PROGRAM_APPLICATION_ID,
apr.PROGRAM_ID,
apr.PROGRAM_UPDATE_DATE,
apr.REQUEST_ID,
apr.QUOTE_LINE_ID,
apr.PRICE_ADJUSTMENT_ID,
apr.RLTD_PRICE_ADJ_ID
FROM ASO_PRICE_ADJ_RELATIONSHIPS apr,
     ASO_PRICE_ADJUSTMENTS apa
WHERE apr.price_adjustment_id = apa.price_adjustment_id
AND apa.quote_header_id = x_quote_header_id
AND EXISTS (select 'x' from aso_quote_lines_all aql
            where aql.quote_header_id = x_quote_header_id
            and aql.quote_line_id = apr.quote_line_id);
*/

/*  -- original cpy_qte
    CURSOR C_Qte_Number IS
	SELECT ASO_QUOTE_NUMBER_S.nextval
	FROM sys.dual;

    CURSOR C_Qte_Version (X_qte_number NUMBER) IS
	SELECT max(quote_version)
	FROM ASO_QUOTE_HEADERS_ALL
	WHERE quote_number = X_qte_number;

    CURSOR C_Qte_Status_Id (c_status_code VARCHAR2) IS
	SELECT quote_status_id
	FROM ASO_QUOTE_STATUSES_B
	WHERE status_code = c_status_code;
	--WHERE status_code = 'DRAFT';

    CURSOR C_Qte_Status_Trans (from_id NUMBER, to_id NUMBER) IS
	SELECT enabled_flag
	FROM ASO_QUOTE_STATUS_TRANSITIONS
	WHERE from_status_id = from_id AND to_status_id = to_id;

    CURSOR C_Qte_Number_exists (X_qte_number NUMBER) IS
     SELECT quote_number
     FROM ASO_QUOTE_HEADERS_ALL
     WHERE quote_number = X_qte_number;

    l_api_name		CONSTANT VARCHAR2(30) := 'Copy_quote';
    l_api_version_number	CONSTANT NUMBER 	:= 1.0;
    l_return_status		VARCHAR2(1);
    l_first_version		VARCHAR2(1)	:= FND_API.G_TRUE;
    l_val			  VARCHAR2(1);
    l_enabled_flag		  VARCHAR2(1);
    l_qte_header_rec	ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_HEADER_RELATIONSHIP_ID	NUMBER;
    l_New_Version   VARCHAR2(1)	   := p_New_Version;
    l_qte_num                 NUMBER;
*/  -- original cpy_qte

    CURSOR C_Get_Hdr_Info(qte_hdr_id NUMBER) IS
     SELECT Quote_Expiration_Date, Resource_Id, Resource_Grp_Id
     FROM ASO_QUOTE_HEADERS_ALL
     WHERE Quote_Header_Id = qte_hdr_id;

    l_api_name      	    CONSTANT VARCHAR2(30) := 'Copy_quote';
    l_api_version_number     CONSTANT NUMBER     := 1.0;

    lx_qte_number            NUMBER;
    l_Copy_Quote_Header_Rec  ASO_COPY_QUOTE_PUB.Copy_Quote_Header_Rec_Type
                              := ASO_COPY_QUOTE_PUB.G_MISS_Copy_Quote_Header_Rec;
    l_Copy_Quote_Control_Rec ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type
                              := ASO_COPY_QUOTE_PUB.G_MISS_Copy_Quote_Control_Rec;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT	COPY_QUOTE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					   p_api_version_number,
    	    	    	    	    	   l_api_name,
			    	    	   G_PKG_NAME) THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
	  FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
	  FND_MESSAGE.Set_Name('ASO', 'Copy Quote API: Start');
	  FND_MSG_PUB.Add;
      END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('p_qte_header_id: '||p_qte_header_id,1,'N');
aso_debug_pub.add('p_qte_number: '||p_qte_number,1,'N');
aso_debug_pub.add('p_copy_only_header: '||p_copy_only_header,1,'N');
aso_debug_pub.add('p_new_version: '||p_new_version,1,'N');
aso_debug_pub.add('p_control_rec.copy_att_flag: '||p_control_rec.copy_att_flag,1,'N');
aso_debug_pub.add('p_control_rec.copy_notes_flag: '||p_control_rec.copy_notes_flag,1,'N');
aso_debug_pub.add('p_control_rec.copy_task_flag: '||p_control_rec.copy_task_flag,1,'N');
END IF;

    OPEN C_Get_Hdr_Info(p_qte_header_id);
    FETCH C_Get_Hdr_Info INTO l_Copy_Quote_Header_Rec.Quote_Expiration_Date,
                         l_Copy_Quote_Header_Rec.Resource_id, l_Copy_Quote_Header_Rec.Resource_Grp_Id;
    CLOSE C_Get_Hdr_Info;

    IF l_Copy_Quote_Header_Rec.Quote_Expiration_Date IS NULL THEN
        l_Copy_Quote_Header_Rec.Quote_Expiration_Date := FND_API.G_MISS_DATE;
    END IF;

    IF l_Copy_Quote_Header_Rec.Resource_Id IS NULL THEN
        l_Copy_Quote_Header_Rec.Resource_Id := FND_API.G_MISS_NUM;
    END IF;

    IF l_Copy_Quote_Header_Rec.Resource_Grp_Id IS NULL THEN
        l_Copy_Quote_Header_Rec.Resource_Grp_Id := FND_API.G_MISS_NUM;
    END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_Copy_Quote_Header_Rec.Quote_Expiration_Date: '||l_Copy_Quote_Header_Rec.Quote_Expiration_Date,1,'N');
aso_debug_pub.add('l_Copy_Quote_Header_Rec.Resource_Id: '||l_Copy_Quote_Header_Rec.Resource_Id,1,'N');
aso_debug_pub.add('l_Copy_Quote_Header_Rec.Resource_Grp_Id: '||l_Copy_Quote_Header_Rec.Resource_Grp_Id,1,'N');
END IF;

	l_Copy_Quote_Header_Rec.quote_header_id := p_qte_header_id;
	l_Copy_Quote_Header_Rec.quote_number := p_qte_number;

	l_Copy_Quote_Control_Rec.copy_header_only := p_copy_only_header;
	l_Copy_Quote_Control_Rec.New_Version := p_new_version;
	IF p_control_rec.copy_att_flag = 'Y' THEN
		l_Copy_Quote_Control_Rec.Copy_Attachment := FND_API.G_TRUE;
	ELSIF p_control_rec.copy_att_flag = 'N' THEN
		l_Copy_Quote_Control_Rec.Copy_Attachment := FND_API.G_FALSE;
	END IF;

     IF p_control_rec.copy_notes_flag = 'Y' THEN
          l_Copy_Quote_Control_Rec.Copy_Note := FND_API.G_TRUE;
     ELSIF p_control_rec.copy_notes_flag = 'N' THEN
          l_Copy_Quote_Control_Rec.Copy_Note := FND_API.G_FALSE;
     END IF;

     IF p_control_rec.copy_task_flag = 'Y' THEN
          l_Copy_Quote_Control_Rec.Copy_Task := FND_API.G_TRUE;
     ELSIF p_control_rec.copy_task_flag = 'N' THEN
          l_Copy_Quote_Control_Rec.Copy_Task := FND_API.G_FALSE;
     END IF;

	ASO_COPY_QUOTE_PVT.Copy_Quote(
    	 	P_Api_Version_Number          =>   p_api_version_number,
     	P_Init_Msg_List               =>   p_init_msg_list,
     	P_Commit                      =>   p_commit,
     	P_Copy_Quote_Header_Rec       =>   l_Copy_Quote_Header_Rec,
     	P_Copy_Quote_Control_Rec      =>   l_Copy_Quote_Control_Rec,
     	X_Qte_Header_Id               =>   X_Qte_Header_Id,
     	X_Qte_Number                  =>   lX_Qte_Number,
     	X_Return_Status               =>   X_Return_Status,
     	X_Msg_Count                   =>   X_Msg_Count,
     	X_Msg_Data                    =>   X_Msg_Data );


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('After Copy_Qte:X_Return_Status: '||X_Return_Status,1,'N');
aso_debug_pub.add('After Copy_Qte:X_Qte_Header_Id: '||X_Qte_Header_Id,1,'N');
END IF;

/*  -- original cpy_qte

      --  Initialize API return status to success
      l_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL THEN
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'UT_CANNOT_GET_PROFILE_VALUE');
    	      FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
	      FND_MSG_PUB.ADD;
	  END IF;
	  RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- ******************************************************************
      IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN
	  OPEN C_Validate_Quote (p_qte_header_id);
	  FETCH C_Validate_Quote into l_val;
	  IF C_Validate_Quote%NOTFOUND THEN
	     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
		  FND_MESSAGE.Set_Token('COLUMN', 'ORIGINAL_QUOTE_ID', FALSE);
		  FND_MESSAGE.Set_Token('VALUE', TO_CHAR(p_qte_header_id), FALSE);
		  FND_MSG_PUB.ADD;
	      END IF;
	      CLOSE C_Validate_Quote;
	      RAISE FND_API.G_EXC_ERROR;
	  END IF;
	  CLOSE C_Validate_Quote;
      END IF;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Copy_Quote - Begin- before copy_rows ', 1, 'Y');
	aso_debug_pub.add('Copy_Quote - P_Qte_Header_Id: '||P_Qte_Header_Id, 1, 'N');
	aso_debug_pub.add('Copy_Quote - P_Last_Update_Date '||P_Last_Update_Date, 1, 'N');
	aso_debug_pub.add('Copy_Quote - P_Copy_Only_Header '||P_Copy_Only_Header, 1, 'N');
	aso_debug_pub.add('Copy_Quote - P_New_Version '||P_New_Version, 1, 'N');
	aso_debug_pub.add('Copy_Quote - P_Qte_Status_Id '||P_Qte_Status_Id, 1, 'N');
	aso_debug_pub.add('Copy_Quote - P_Qte_Number '||P_Qte_Number, 1, 'N');
	END IF;

      l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row(p_qte_header_id);
   	 IF (p_new_version = FND_API.G_TRUE AND
			l_qte_header_rec.quote_number = p_qte_number) THEN
        l_new_version := FND_API.G_TRUE;
      END IF;
      IF (l_new_version = FND_API.G_FALSE) THEN
           IF (p_qte_number IS NULL OR p_qte_number = FND_API.G_MISS_NUM) THEN
	           IF (NVL(FND_PROFILE.Value('ASO_AUTO_NUMBERING'), 'Y') = 'Y') THEN
	               OPEN C_Qte_Number;
	               FETCH C_Qte_Number INTO l_qte_header_rec.quote_number;
	               CLOSE C_Qte_Number;
  	               l_qte_header_rec.quote_version := 1;
                   l_first_version	:= FND_API.G_TRUE;
	           ELSE
	               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		              FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
		              FND_MESSAGE.Set_Token('COLUMN', 'QUOTE_NUMBER', FALSE);
		              FND_MSG_PUB.ADD;
	               END IF;
	               RAISE FND_API.G_EXC_ERROR;
	           END IF;  -- profile auto numbering
            ELSE
		     OPEN C_Qte_Number_Exists(p_qte_number);
               FETCH C_Qte_Number_Exists into l_qte_num;
		     CLOSE C_Qte_Number_Exists;
		     IF (FND_PROFILE.Value('ASO_AUTO_NUMBERING') = 'N'
		                   AND l_qte_num = p_qte_number) THEN
		         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		         THEN
*/  -- original cpy_qte
/*		             FND_MESSAGE.Set_Name('ASO', 'CANNOT COPY TO EXISTING QUOTE');
                       FND_MESSAGE.Set_Token('COLUMN', 'QUOTE_NUMBER', FALSE);
*/
/*  -- original cpy_qte
				   FND_MESSAGE.Set_Name('ASO', 'ASO_CANNOT_COPY_QTE');
                       FND_MSG_PUB.ADD;
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
			 ELSE
  	             l_qte_header_rec.quote_number := p_qte_number;
                      l_qte_header_rec.quote_version := 1;
                 l_first_version	:= FND_API.G_TRUE;
		    END IF;
            END IF;  -- p_qte_number is null
      ELSE  -- p_new_version

           IF P_Qte_Number IS NOT NULL AND P_Qte_Number <> FND_API.G_MISS_NUM THEN

                OPEN C_Qte_Number_Exists(p_qte_number);
                FETCH C_Qte_Number_Exists into l_qte_num;

                IF C_Qte_Number_Exists%NOTFOUND THEN

        		  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		              FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
		              FND_MESSAGE.Set_Token('COLUMN', 'QUOTE_NUMBER', FALSE);
		              FND_MSG_PUB.ADD;
		          END IF;

		          CLOSE C_Qte_Number_Exists;
		          RAISE FND_API.G_EXC_ERROR;

                ELSE
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Copy_Quote - P_Qte_Number Exists', 1, 'N');
END IF;
                  	l_qte_header_rec.quote_number := P_Qte_Number;
		          CLOSE C_Qte_Number_Exists;

                END IF;

           END IF;

	       OPEN C_Qte_Version(l_qte_header_rec.quote_number);
	       FETCH C_Qte_Version into l_qte_header_rec.quote_version;

	       l_qte_header_rec.quote_version := nvl(l_qte_header_rec.quote_version, 0) + 1;
	       CLOSE C_Qte_Version;
	       l_first_version	:= FND_API.G_FALSE;
      END IF;

      IF (p_qte_status_id IS NULL OR p_qte_status_id = FND_API.G_MISS_NUM) THEN
	  --OPEN c_qte_status_id ('DRAFT');
	  OPEN c_qte_status_id ( fnd_profile.value( 'ASO_DEFAULT_STATUS_CODE' )  );
	  FETCH c_qte_status_id INTO l_qte_header_rec.quote_status_id;
	  CLOSE c_qte_status_id;
      ELSE
	  IF l_first_version = FND_API.G_FALSE THEN
	      OPEN c_qte_status_trans (l_qte_header_rec.quote_status_id, p_qte_status_id);
	      FETCH c_qte_status_trans INTO l_enabled_flag;
	      IF c_qte_status_trans%NOTFOUND OR l_enabled_flag = 'N' THEN
		  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		      FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_STATUS_TRANS');
		      FND_MSG_PUB.ADD;
		  END IF;
		  CLOSE c_qte_status_trans;
		  RAISE FND_API.G_EXC_ERROR;
	      END IF;
	      CLOSE c_qte_status_trans;
	  END IF;
	  l_qte_header_rec.quote_status_id := p_qte_status_id;
      END IF;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('Copy_Quote - Begin- before copy_rows ', 1, 'Y');
	END IF;

      Copy_Rows(
		P_qte_Header_Rec	 => l_qte_header_rec,
		P_Header_Only		 => P_Copy_Only_Header,
	     P_control_rec        => P_control_rec,
		X_Qte_Header_id		 => x_qte_header_id,
		X_Return_Status 	 => l_return_status,
		X_Msg_Count		 => x_msg_count,
		X_Msg_Data		 => x_msg_data);
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Copy_Quote - After  copy_rows '||l_return_status, 1, 'Y');
END IF;
      -- create header relationship

      ASO_HEADER_RELATIONSHIPS_PKG.Insert_Row(
	  px_HEADER_RELATIONSHIP_ID  => l_HEADER_RELATIONSHIP_ID,
	  p_CREATION_DATE  => SYSDATE,
	  p_CREATED_BY	=> G_USER_ID,
	  p_LAST_UPDATE_DATE  => SYSDATE,
	  p_LAST_UPDATED_BY  => G_USER_ID,
	  p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
	  p_REQUEST_ID	=> NULL,
	  p_PROGRAM_APPLICATION_ID  => NULL,
	  p_PROGRAM_ID	=> NULL,
	  p_PROGRAM_UPDATE_DATE  => NULL,
	  p_QUOTE_HEADER_ID  => p_qte_header_id,
	  p_RELATED_HEADER_ID  => x_qte_header_id,
	  p_RELATIONSHIP_TYPE_CODE  => 'COPY',
	  p_RECIPROCAL_FLAG  => NULL,
	  P_OBJECT_VERSION_NUMBER => FND_API.G_MISS_NUM
	  );


      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
	      FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER', TRUE);
	      FND_MSG_PUB.ADD;
	  END IF;
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
*/  -- original cpy_qte
/*	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('ASO', 'ASO_API_EXP_ERROR');
	      FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER', TRUE);
	      FND_MSG_PUB.ADD;
	  END IF; */
/*  -- original cpy_qte
	  RAISE FND_API.G_EXC_ERROR;
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- End of API body
      --
*/  -- original cpy_qte
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
	  COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count	  =>   x_msg_count,
	 p_data 	  =>   x_msg_data
      );

      EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
                  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Copy_Quote;

-- This procudure defines the columns for the Dynamic SQL.
PROCEDURE Define_Columns(
    P_Qte_Header_Rec   IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_cur_get_QTE   IN	 NUMBER
)
IS
BEGIN

      -- define all columns for ASO_QUOTE_HEADERS_V view
      ----dbms_sql.define_column(p_cur_get_QTE, 1, P_Qte_Header_Rec.QUOTE_HEADER_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 2, P_Qte_Header_Rec.ORG_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 3, P_Qte_Header_Rec.REQUEST_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 4, P_Qte_Header_Rec.ORIGINAL_SYSTEM_REFERENCE, 240);
      ----dbms_sql.define_column(p_cur_get_QTE, 5, P_Qte_Header_Rec.EMPLOYEE_PERSON_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 6, P_Qte_Header_Rec.SALESREP_FIRST_NAME, 20);
      ----dbms_sql.define_column(p_cur_get_QTE, 7, P_Qte_Header_Rec.SALESREP_LAST_NAME, 40);
      ----dbms_sql.define_column(p_cur_get_QTE, 8, P_Qte_Header_Rec.PRICE_LIST_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 9, P_Qte_Header_Rec.PRICE_LIST_NAME, 0);
      ----dbms_sql.define_column(p_cur_get_QTE, 10, P_Qte_Header_Rec.QUOTE_STATUS_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 11, P_Qte_Header_Rec.QUOTE_STATUS_CODE, 30);
      ----dbms_sql.define_column(p_cur_get_QTE, 12, P_Qte_Header_Rec.QUOTE_STATUS, 240);
      ----dbms_sql.define_column(p_cur_get_QTE, 15, P_Qte_Header_Rec.QUOTE_SOURCE_CODE, 15);
      ----dbms_sql.define_column(p_cur_get_QTE, 16, P_Qte_Header_Rec.PARTY_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 17, P_Qte_Header_Rec.PARTY_NAME, 255);
      ----dbms_sql.define_column(p_cur_get_QTE, 18, P_Qte_Header_Rec.PARTY_TYPE, 30);
      ----dbms_sql.define_column(p_cur_get_QTE, 19, P_Qte_Header_Rec.PERSON_FIRST_NAME, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 20, P_Qte_Header_Rec.PERSON_MIDDLE_NAME, 60);
      ----dbms_sql.define_column(p_cur_get_QTE, 21, P_Qte_Header_Rec.PERSON_LAST_NAME, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 22, P_Qte_Header_Rec.ORG_CONTACT_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 26, P_Qte_Header_Rec.QUOTE_NAME, 50);
      ----dbms_sql.define_column(p_cur_get_QTE, 27, P_Qte_Header_Rec.QUOTE_NUMBER);
      ----dbms_sql.define_column(p_cur_get_QTE, 28, P_Qte_Header_Rec.QUOTE_VERSION);
      ----dbms_sql.define_column(p_cur_get_QTE, 29, P_Qte_Header_Rec.QUOTE_EXPIRATION_DATE);
      ----dbms_sql.define_column(p_cur_get_QTE, 30, P_Qte_Header_Rec.QUOTE_CATEGORY_CODE, 30);
      ----dbms_sql.define_column(p_cur_get_QTE, 31, P_Qte_Header_Rec.CURRENCY_CODE, 15);
      ----dbms_sql.define_column(p_cur_get_QTE, 32, P_Qte_Header_Rec.EXCHANGE_RATE);
      ----dbms_sql.define_column(p_cur_get_QTE, 33, P_Qte_Header_Rec.EXCHANGE_TYPE_CODE, 15);
      ----dbms_sql.define_column(p_cur_get_QTE, 34, P_Qte_Header_Rec.EXCHANGE_RATE_DATE);
      ----dbms_sql.define_column(p_cur_get_QTE, 39, P_Qte_Header_Rec.ORDERED_DATE);
      ----dbms_sql.define_column(p_cur_get_QTE, 40, P_Qte_Header_Rec.ORDER_TYPE_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 41, P_Qte_Header_Rec.ORDER_TYPE_NAME, 80);
      ----dbms_sql.define_column(p_cur_get_QTE, 45, P_Qte_Header_Rec.TOTAL_LIST_PRICE);
      ----dbms_sql.define_column(p_cur_get_QTE, 46, P_Qte_Header_Rec.TOTAL_ADJUSTED_AMOUNT);
      ----dbms_sql.define_column(p_cur_get_QTE, 47, P_Qte_Header_Rec.TOTAL_ADJUSTED_PERCENT);
      ----dbms_sql.define_column(p_cur_get_QTE, 48, P_Qte_Header_Rec.TOTAL_TAX);
      ----dbms_sql.define_column(p_cur_get_QTE, 49, P_Qte_Header_Rec.SURCHARGE);
      ----dbms_sql.define_column(p_cur_get_QTE, 50, P_Qte_Header_Rec.TOTAL_SHIPPING_CHARGE);
      ----dbms_sql.define_column(p_cur_get_QTE, 51, P_Qte_Header_Rec.TOTAL_QUOTE_PRICE);
      ----dbms_sql.define_column(p_cur_get_QTE, 52, P_Qte_Header_Rec.ACCOUNTING_RULE_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 53, P_Qte_Header_Rec.INVOICING_RULE_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 73, P_Qte_Header_Rec.INVOICE_TO_PARTY_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 74, P_Qte_Header_Rec.INVOICE_TO_PARTY_SITE_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 75, P_Qte_Header_Rec.INVOICE_TO_PARTY_NAME, 255);
      ----dbms_sql.define_column(p_cur_get_QTE, 76, P_Qte_Header_Rec.INVOICE_TO_CONTACT_FIRST_NAME, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 77, P_Qte_Header_Rec.INVOICE_TO_CONTACT_MIDDLE_NAME, 60);
      ----dbms_sql.define_column(p_cur_get_QTE, 78, P_Qte_Header_Rec.INVOICE_TO_CONTACT_LAST_NAME, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 79, P_Qte_Header_Rec.INVOICE_TO_ADDRESS1, 240);
      ----dbms_sql.define_column(p_cur_get_QTE, 80, P_Qte_Header_Rec.INVOICE_TO_ADDRESS2, 240);
      ----dbms_sql.define_column(p_cur_get_QTE, 81, P_Qte_Header_Rec.INVOICE_TO_ADDRESS3, 240);
      ----dbms_sql.define_column(p_cur_get_QTE, 82, P_Qte_Header_Rec.INVOICE_TO_ADDRESS4, 240);
      ----dbms_sql.define_column(p_cur_get_QTE, 83, P_Qte_Header_Rec.INVOICE_TO_COUNTRY_CODE, 60);
      ----dbms_sql.define_column(p_cur_get_QTE, 84, P_Qte_Header_Rec.INVOICE_TO_COUNTRY, 80);
      ----dbms_sql.define_column(p_cur_get_QTE, 85, P_Qte_Header_Rec.INVOICE_TO_CITY, 60);
      ----dbms_sql.define_column(p_cur_get_QTE, 86, P_Qte_Header_Rec.INVOICE_TO_POSTAL_CODE, 60);
      ----dbms_sql.define_column(p_cur_get_QTE, 87, P_Qte_Header_Rec.INVOICE_TO_STATE, 60);
      ----dbms_sql.define_column(p_cur_get_QTE, 88, P_Qte_Header_Rec.INVOICE_TO_PROVINCE, 60);
      ----dbms_sql.define_column(p_cur_get_QTE, 89, P_Qte_Header_Rec.INVOICE_TO_COUNTY, 60);
      ----dbms_sql.define_column(p_cur_get_QTE, 92, P_Qte_Header_Rec.CONTRACT_ID);
      ----dbms_sql.define_column(p_cur_get_QTE, 93, P_Qte_Header_Rec.ATTRIBUTE_CATEGORY, 30);
      ----dbms_sql.define_column(p_cur_get_QTE, 94, P_Qte_Header_Rec.ATTRIBUTE1, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 95, P_Qte_Header_Rec.ATTRIBUTE2, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 96, P_Qte_Header_Rec.ATTRIBUTE3, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 97, P_Qte_Header_Rec.ATTRIBUTE4, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 98, P_Qte_Header_Rec.ATTRIBUTE5, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 99, P_Qte_Header_Rec.ATTRIBUTE6, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 100, P_Qte_Header_Rec.ATTRIBUTE7, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 101, P_Qte_Header_Rec.ATTRIBUTE8, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 102, P_Qte_Header_Rec.ATTRIBUTE9, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 103, P_Qte_Header_Rec.ATTRIBUTE10, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 104, P_Qte_Header_Rec.ATTRIBUTE11, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 105, P_Qte_Header_Rec.ATTRIBUTE12, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 106, P_Qte_Header_Rec.ATTRIBUTE13, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 107, P_Qte_Header_Rec.ATTRIBUTE14, 150);
      ----dbms_sql.define_column(p_cur_get_QTE, 108, P_Qte_Header_Rec.ATTRIBUTE15, 150);

	 null;

END Define_Columns;

-- This procudure gets column values by the Dynamic SQL.
PROCEDURE Get_Column_Values(
    p_cur_get_QTE   IN	 NUMBER,
    X_Qte_Header_Rec   OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Qte_Header_Rec_Type
)
IS
BEGIN

      -- get all column values for ASO_QUOTE_HEADERS_V table
      ----dbms_sql.column_value(p_cur_get_QTE, 2, X_Qte_Header_Rec.QUOTE_HEADER_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 3, X_Qte_Header_Rec.ORG_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 4, X_Qte_Header_Rec.REQUEST_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 5, X_Qte_Header_Rec.ORIGINAL_SYSTEM_REFERENCE);
      ----dbms_sql.column_value(p_cur_get_QTE, 6, X_Qte_Header_Rec.EMPLOYEE_PERSON_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 7, X_Qte_Header_Rec.SALESREP_FIRST_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 8, X_Qte_Header_Rec.SALESREP_LAST_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 9, X_Qte_Header_Rec.PRICE_LIST_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 10, X_Qte_Header_Rec.PRICE_LIST_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 11, X_Qte_Header_Rec.QUOTE_STATUS_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 12, X_Qte_Header_Rec.QUOTE_STATUS_CODE);
      ----dbms_sql.column_value(p_cur_get_QTE, 13, X_Qte_Header_Rec.QUOTE_STATUS);
      ----dbms_sql.column_value(p_cur_get_QTE, 16, X_Qte_Header_Rec.QUOTE_SOURCE_CODE);
      ----dbms_sql.column_value(p_cur_get_QTE, 17, X_Qte_Header_Rec.PARTY_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 18, X_Qte_Header_Rec.PARTY_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 19, X_Qte_Header_Rec.PARTY_TYPE);
      ----dbms_sql.column_value(p_cur_get_QTE, 20, X_Qte_Header_Rec.PERSON_FIRST_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 21, X_Qte_Header_Rec.PERSON_MIDDLE_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 22, X_Qte_Header_Rec.PERSON_LAST_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 23, X_Qte_Header_Rec.ORG_CONTACT_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 27, X_Qte_Header_Rec.QUOTE_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 28, X_Qte_Header_Rec.QUOTE_NUMBER);
      ----dbms_sql.column_value(p_cur_get_QTE, 29, X_Qte_Header_Rec.QUOTE_VERSION);
      ----dbms_sql.column_value(p_cur_get_QTE, 30, X_Qte_Header_Rec.QUOTE_EXPIRATION_DATE);
      ----dbms_sql.column_value(p_cur_get_QTE, 31, X_Qte_Header_Rec.QUOTE_CATEGORY_CODE);
      ----dbms_sql.column_value(p_cur_get_QTE, 32, X_Qte_Header_Rec.CURRENCY_CODE);
      ----dbms_sql.column_value(p_cur_get_QTE, 33, X_Qte_Header_Rec.EXCHANGE_RATE);
      ----dbms_sql.column_value(p_cur_get_QTE, 34, X_Qte_Header_Rec.EXCHANGE_TYPE_CODE);
      ----dbms_sql.column_value(p_cur_get_QTE, 35, X_Qte_Header_Rec.EXCHANGE_RATE_DATE);
      ----dbms_sql.column_value(p_cur_get_QTE, 40, X_Qte_Header_Rec.ORDERED_DATE);
      ----dbms_sql.column_value(p_cur_get_QTE, 41, X_Qte_Header_Rec.ORDER_TYPE_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 42, X_Qte_Header_Rec.ORDER_TYPE_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 46, X_Qte_Header_Rec.TOTAL_LIST_PRICE);
      ----dbms_sql.column_value(p_cur_get_QTE, 47, X_Qte_Header_Rec.TOTAL_ADJUSTED_AMOUNT);
      ----dbms_sql.column_value(p_cur_get_QTE, 48, X_Qte_Header_Rec.TOTAL_ADJUSTED_PERCENT);
      ----dbms_sql.column_value(p_cur_get_QTE, 49, X_Qte_Header_Rec.TOTAL_TAX);
      ----dbms_sql.column_value(p_cur_get_QTE, 50, X_Qte_Header_Rec.SURCHARGE);
      ----dbms_sql.column_value(p_cur_get_QTE, 51, X_Qte_Header_Rec.TOTAL_SHIPPING_CHARGE);
      ----dbms_sql.column_value(p_cur_get_QTE, 52, X_Qte_Header_Rec.TOTAL_QUOTE_PRICE);
      ----dbms_sql.column_value(p_cur_get_QTE, 53, X_Qte_Header_Rec.ACCOUNTING_RULE_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 54, X_Qte_Header_Rec.INVOICING_RULE_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 74, X_Qte_Header_Rec.INVOICE_TO_PARTY_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 75, X_Qte_Header_Rec.INVOICE_TO_PARTY_SITE_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 76, X_Qte_Header_Rec.INVOICE_TO_PARTY_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 77, X_Qte_Header_Rec.INVOICE_TO_CONTACT_FIRST_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 78, X_Qte_Header_Rec.INVOICE_TO_CONTACT_MIDDLE_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 79, X_Qte_Header_Rec.INVOICE_TO_CONTACT_LAST_NAME);
      ----dbms_sql.column_value(p_cur_get_QTE, 80, X_Qte_Header_Rec.INVOICE_TO_ADDRESS1);
      ----dbms_sql.column_value(p_cur_get_QTE, 81, X_Qte_Header_Rec.INVOICE_TO_ADDRESS2);
      ----dbms_sql.column_value(p_cur_get_QTE, 82, X_Qte_Header_Rec.INVOICE_TO_ADDRESS3);
      ----dbms_sql.column_value(p_cur_get_QTE, 83, X_Qte_Header_Rec.INVOICE_TO_ADDRESS4);
      ----dbms_sql.column_value(p_cur_get_QTE, 84, X_Qte_Header_Rec.INVOICE_TO_COUNTRY_CODE);
      ----dbms_sql.column_value(p_cur_get_QTE, 85, X_Qte_Header_Rec.INVOICE_TO_COUNTRY);
      ----dbms_sql.column_value(p_cur_get_QTE, 86, X_Qte_Header_Rec.INVOICE_TO_CITY);
      ----dbms_sql.column_value(p_cur_get_QTE, 87, X_Qte_Header_Rec.INVOICE_TO_POSTAL_CODE);
      ----dbms_sql.column_value(p_cur_get_QTE, 88, X_Qte_Header_Rec.INVOICE_TO_STATE);
      ----dbms_sql.column_value(p_cur_get_QTE, 89, X_Qte_Header_Rec.INVOICE_TO_PROVINCE);
      ----dbms_sql.column_value(p_cur_get_QTE, 90, X_Qte_Header_Rec.INVOICE_TO_COUNTY);
      ----dbms_sql.column_value(p_cur_get_QTE, 93, X_Qte_Header_Rec.CONTRACT_ID);
      ----dbms_sql.column_value(p_cur_get_QTE, 94, X_Qte_Header_Rec.ATTRIBUTE_CATEGORY);
      ----dbms_sql.column_value(p_cur_get_QTE, 95, X_Qte_Header_Rec.ATTRIBUTE1);
      ----dbms_sql.column_value(p_cur_get_QTE, 96, X_Qte_Header_Rec.ATTRIBUTE2);
      ----dbms_sql.column_value(p_cur_get_QTE, 97, X_Qte_Header_Rec.ATTRIBUTE3);
      ----dbms_sql.column_value(p_cur_get_QTE, 98, X_Qte_Header_Rec.ATTRIBUTE4);
      ----dbms_sql.column_value(p_cur_get_QTE, 99, X_Qte_Header_Rec.ATTRIBUTE5);
      ----dbms_sql.column_value(p_cur_get_QTE, 100, X_Qte_Header_Rec.ATTRIBUTE6);
      ----dbms_sql.column_value(p_cur_get_QTE, 101, X_Qte_Header_Rec.ATTRIBUTE7);
      ----dbms_sql.column_value(p_cur_get_QTE, 102, X_Qte_Header_Rec.ATTRIBUTE8);
      ----dbms_sql.column_value(p_cur_get_QTE, 103, X_Qte_Header_Rec.ATTRIBUTE9);
      ----dbms_sql.column_value(p_cur_get_QTE, 104, X_Qte_Header_Rec.ATTRIBUTE10);
      ----dbms_sql.column_value(p_cur_get_QTE, 105, X_Qte_Header_Rec.ATTRIBUTE11);
      ----dbms_sql.column_value(p_cur_get_QTE, 106, X_Qte_Header_Rec.ATTRIBUTE12);
      ----dbms_sql.column_value(p_cur_get_QTE, 107, X_Qte_Header_Rec.ATTRIBUTE13);
      ----dbms_sql.column_value(p_cur_get_QTE, 108, X_Qte_Header_Rec.ATTRIBUTE14);
      ----dbms_sql.column_value(p_cur_get_QTE, 109, X_Qte_Header_Rec.ATTRIBUTE15);
	 null;

END Get_Column_Values;

PROCEDURE Gen_QTE_order_cl(
    p_order_by_rec   IN   ASO_QUOTE_PUB.QTE_sort_rec_type,
    x_order_by_cl    OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_return_status  OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count      OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data	     OUT NOCOPY /* file.sql.39 change */      VARCHAR2
)
IS
l_order_by_cl	     VARCHAR2(1000)   := NULL;
l_util_order_by_tbl  ASO_UTILITY_PVT.Util_order_by_tbl_type;
BEGIN

      -- Hint: Developer should add more statements according to ASO_sort_rec_type
      -- Ex:
      -- l_util_order_by_tbl(1).col_choice := p_order_by_rec.customer_name;
      -- l_util_order_by_tbl(1).col_name := 'Customer_Name';


      ASO_UTILITY_PVT.Translate_OrderBy(
	  p_api_version_number	 =>   1.0
	 ,p_init_msg_list	 =>   FND_API.G_FALSE
	 ,p_validation_level	 =>   FND_API.G_VALID_LEVEL_FULL
	 ,p_order_by_tbl	 =>   l_util_order_by_tbl
	 ,x_order_by_clause	 =>   l_order_by_cl
	 ,x_return_status	 =>   x_return_status
	 ,x_msg_count		 =>   x_msg_count
	 ,x_msg_data		 =>   x_msg_data);

      IF(l_order_by_cl IS NOT NULL) THEN
	  x_order_by_cl := 'order by' || l_order_by_cl;
      ELSE
	  x_order_by_cl := NULL;
      END IF;

END Gen_QTE_order_cl;

-- This procedure bind the variables for the Dynamic SQL
PROCEDURE Bind(
    P_Qte_Header_Rec   IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    -- Hint: Add more binding variables here
    p_cur_get_QTE   IN	 NUMBER
)
IS
BEGIN
      -- Bind variables
      -- Only those that are not NULL

      -- The following example applies to all columns,
      -- developers can copy and paste them.
      IF( (P_Qte_Header_Rec.QUOTE_HEADER_ID IS NOT NULL) AND (P_Qte_Header_Rec.QUOTE_HEADER_ID <> FND_API.G_MISS_NUM) )
      THEN
	  dbms_SQL.BIND_VARIABLE(p_cur_get_QTE, ':p_QUOTE_HEADER_ID', P_Qte_Header_Rec.QUOTE_HEADER_ID);
      END IF;

END Bind;

PROCEDURE Gen_Select(
    x_select_cl   OUT NOCOPY /* file.sql.39 change */    	VARCHAR2
)
IS
BEGIN

      x_select_cl := 'Select ' ||
		'ASO_QUOTE_HEADERS_V.ROW_ID,' ||
		'ASO_QUOTE_HEADERS_V.QUOTE_HEADER_ID,' ||
		'ASO_QUOTE_HEADERS_V.ORG_ID,' ||
		'ASO_QUOTE_HEADERS_V.LAST_UPDATE_DATE,' ||
		'ASO_QUOTE_HEADERS_V.LAST_UPDATED_BY,' ||
		'ASO_QUOTE_HEADERS_V.CREATION_DATE,' ||
		'ASO_QUOTE_HEADERS_V.CREATED_BY,' ||
		'ASO_QUOTE_HEADERS_V.LAST_UPDATE_LOGIN,' ||
		'ASO_QUOTE_HEADERS_V.REQUEST_ID,' ||
		'ASO_QUOTE_HEADERS_V.PROGRAM_APPLICATION_ID,' ||
		'ASO_QUOTE_HEADERS_V.PROGRAM_ID,' ||
		'ASO_QUOTE_HEADERS_V.PROGRAM_UPDATE_DATE,' ||
		'ASO_QUOTE_HEADERS_V.ORIGINAL_SYSTEM_REFERENCE,' ||
		'ASO_QUOTE_HEADERS_V.EMPLOYEE_PERSON_ID,' ||
		'ASO_QUOTE_HEADERS_V.SALESREP_FIRST_NAME,' ||
		'ASO_QUOTE_HEADERS_V.SALESREP_LAST_NAME,' ||
		'ASO_QUOTE_HEADERS_V.PRICE_LIST_ID,' ||
		'ASO_QUOTE_HEADERS_V.PRICE_LIST_NAME,' ||
		'ASO_QUOTE_HEADERS_V.QUOTE_STATUS_ID,' ||
		'ASO_QUOTE_HEADERS_V.QUOTE_STATUS_CODE,' ||
		'ASO_QUOTE_HEADERS_V.QUOTE_STATUS,' ||
		'ASO_QUOTE_HEADERS_V.UPDATE_ALLOWED_FLAG,' ||
		'ASO_QUOTE_HEADERS_V.AUTO_VERSION_FLAG,' ||
		'ASO_QUOTE_HEADERS_V.QUOTE_SOURCE_CODE,' ||
		'ASO_QUOTE_HEADERS_V.PARTY_ID,' ||
		'ASO_QUOTE_HEADERS_V.PARTY_NAME,' ||
		'ASO_QUOTE_HEADERS_V.PARTY_TYPE,' ||
		'ASO_QUOTE_HEADERS_V.PERSON_FIRST_NAME,' ||
		'ASO_QUOTE_HEADERS_V.PERSON_MIDDLE_NAME,' ||
		'ASO_QUOTE_HEADERS_V.PERSON_LAST_NAME,' ||
		'ASO_QUOTE_HEADERS_V.ORG_CONTACT_ID,' ||
		'ASO_QUOTE_HEADERS_V.CONTACT_FIRST_NAME,' ||
		'ASO_QUOTE_HEADERS_V.CONTACT_MIDDLE_NAME,' ||
		'ASO_QUOTE_HEADERS_V.CONTACT_LAST_NAME,' ||
		'ASO_QUOTE_HEADERS_V.QUOTE_NAME,' ||
		'ASO_QUOTE_HEADERS_V.QUOTE_NUMBER,' ||
		'ASO_QUOTE_HEADERS_V.QUOTE_VERSION,' ||
		'ASO_QUOTE_HEADERS_V.QUOTE_EXPIRATION_DATE,' ||
		'ASO_QUOTE_HEADERS_V.QUOTE_CATEGORY_CODE,' ||
		'ASO_QUOTE_HEADERS_V.CURRENCY_CODE,' ||
		'ASO_QUOTE_HEADERS_V.EXCHANGE_RATE,' ||
		'ASO_QUOTE_HEADERS_V.EXCHANGE_TYPE_CODE,' ||
		'ASO_QUOTE_HEADERS_V.EXCHANGE_RATE_DATE,' ||
		'ASO_QUOTE_HEADERS_V.SOURCE_CAMPAIGN_ID,' ||
		'ASO_QUOTE_HEADERS_V.CAMPAIGN_ID,' ||
		'ASO_QUOTE_HEADERS_V.CAMPAIGN_NAME,' ||
		'ASO_QUOTE_HEADERS_V.CAMPAIGN_SOURCE_CODE,' ||
		'ASO_QUOTE_HEADERS_V.ORDERED_DATE,' ||
		'ASO_QUOTE_HEADERS_V.ORDER_TYPE_ID,' ||
		'ASO_QUOTE_HEADERS_V.ORDER_TYPE_NAME,' ||
		'ASO_QUOTE_HEADERS_V.TAX_EXEMPT_NUMBER,' ||
		'ASO_QUOTE_HEADERS_V.TAX_EXEMPT_REASON_CODE,' ||
		'ASO_QUOTE_HEADERS_V.TAX_EXEMPT_FLAG,' ||
		'ASO_QUOTE_HEADERS_V.TOTAL_LIST_PRICE,' ||
		'ASO_QUOTE_HEADERS_V.TOTAL_ADJUSTED_AMOUNT,' ||
		'ASO_QUOTE_HEADERS_V.TOTAL_ADJUSTED_PERCENT,' ||
		'ASO_QUOTE_HEADERS_V.TOTAL_TAX,' ||
		'ASO_QUOTE_HEADERS_V.SURCHARGE,' ||
		'ASO_QUOTE_HEADERS_V.TOTAL_SHIPPING_CHARGE,' ||
		'ASO_QUOTE_HEADERS_V.TOTAL_QUOTE_PRICE,' ||
		'ASO_QUOTE_HEADERS_V.ACCOUNTING_RULE_ID,' ||
		'ASO_QUOTE_HEADERS_V.INVOICING_RULE_ID,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_METHOD_CODE,' ||
		'ASO_QUOTE_HEADERS_V.FREIGHT_TERMS_CODE,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_PARTY_ID,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_PARTY_SITE_ID,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_PARTY_NAME,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_CONTACT_FIRST_NAME,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_CONTACT_MIDDLE_NAME,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_CONTACT_LAST_NAME,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_ADDRESS1,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_ADDRESS2,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_ADDRESS3,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_ADDRESS4,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_COUNTRY_CODE,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_COUNTRY,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_CITY,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_POSTAL_CODE,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_STATE,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_PROVINCE,' ||
		'ASO_QUOTE_HEADERS_V.SHIP_TO_COUNTY,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_PARTY_ID,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_PARTY_SITE_ID,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_PARTY_NAME,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_CONTACT_FIRST_NAME,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_CONTACT_MIDDLE_NAME,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_CONTACT_LAST_NAME,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_ADDRESS1,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_ADDRESS2,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_ADDRESS3,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_ADDRESS4,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_COUNTRY_CODE,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_COUNTRY,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_CITY,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_POSTAL_CODE,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_STATE,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_PROVINCE,' ||
		'ASO_QUOTE_HEADERS_V.INVOICE_TO_COUNTY,' ||
		'ASO_QUOTE_HEADERS_V.SHIPPING_INSTRUCTIONS,' ||
		'ASO_QUOTE_HEADERS_V.PACKING_INSTRUCTIONS,' ||
		'ASO_QUOTE_HEADERS_V.CONTRACT_ID,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE_CATEGORY,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE1,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE2,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE3,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE4,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE5,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE6,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE7,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE8,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE9,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE10,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE11,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE12,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE13,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE14,' ||
		'ASO_QUOTE_HEADERS_V.ATTRIBUTE15,' ||
		'from ASO_QUOTE_HEADERS_V';

END Gen_Select;

PROCEDURE Gen_QTE_Where(
    P_Qte_Header_Rec	 IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    x_QTE_where   OUT NOCOPY /* file.sql.39 change */    	VARCHAR2
)
IS
-- cursors to check if wildcard values '%' and '_' have been passed
-- as item values
/*
CURSOR c_chk_str1(p_rec_item VARCHAR2) IS
    SELECT INSTR(p_rec_item, '%', 1, 1)
    FROM DUAL;
CURSOR c_chk_str2(p_rec_item VARCHAR2) IS
    SELECT INSTR(p_rec_item, '_', 1, 1)
    FROM DUAL;
*/
-- return values from cursors
str_csr1   NUMBER;
str_csr2   NUMBER;
l_operator VARCHAR2(10);
BEGIN

      -- There are three example for each kind of datatype:
      -- NUMBER, DATE, VARCHAR2.
      -- Developer can copy and paste the following codes for your own record.

      -- example for NUMBER datatype
      IF( (P_Qte_Header_Rec.QUOTE_HEADER_ID IS NOT NULL) AND (P_Qte_Header_Rec.QUOTE_HEADER_ID <> FND_API.G_MISS_NUM) )
      THEN
	  IF(x_QTE_where IS NULL) THEN
	      x_QTE_where := 'Where';
	  ELSE
	      x_QTE_where := x_QTE_where || ' AND ';
	  END IF;
	  x_QTE_where := x_QTE_where || 'P_Qte_Header_Rec.QUOTE_HEADER_ID = :p_QUOTE_HEADER_ID';
      END IF;

      -- example for DATE datatype
      IF( (P_Qte_Header_Rec.CREATION_DATE IS NOT NULL) AND (P_Qte_Header_Rec.CREATION_DATE <> FND_API.G_MISS_DATE) )
      THEN
	  -- check if item value contains '%' wildcard
/*	  OPEN c_chk_str1(P_Qte_Header_Rec.CREATION_DATE);
	  FETCH c_chk_str1 INTO str_csr1;
	  CLOSE c_chk_str1;
*/
	  str_csr1 := INSTR(P_Qte_Header_Rec.CREATION_DATE, '%', 1, 1);

	  IF(str_csr1 <> 0) THEN
	      l_operator := ' LIKE ';
	  ELSE
	      l_operator := ' = ';
	  END IF;

	  -- check if item value contains '_' wildcard
/*
	  OPEN c_chk_str2(P_Qte_Header_Rec.CREATION_DATE);
	  FETCH c_chk_str2 INTO str_csr2;
	  CLOSE c_chk_str2;
*/
	  str_csr2 := INSTR(P_Qte_Header_Rec.CREATION_DATE, '_', 1, 1);

	  IF(str_csr2 <> 0) THEN
	      l_operator := ' LIKE ';
	  ELSE
	      l_operator := ' = ';
	  END IF;

	  IF(x_QTE_where IS NULL) THEN
	      x_QTE_where := 'Where ';
	  ELSE
	      x_QTE_where := x_QTE_where || ' AND ';
	  END IF;
	  x_QTE_where := x_QTE_where || 'P_Qte_Header_Rec.CREATION_DATE ' || l_operator || ' :p_CREATION_DATE';
      END IF;

      -- example for VARCHAR2 datatype
      IF( (P_Qte_Header_Rec.QUOTE_NAME IS NOT NULL) AND (P_Qte_Header_Rec.QUOTE_NAME <> FND_API.G_MISS_CHAR) )
      THEN
	  -- check if item value contains '%' wildcard
/*
	  OPEN c_chk_str1(P_Qte_Header_Rec.QUOTE_NAME);
	  FETCH c_chk_str1 INTO str_csr1;
	  CLOSE c_chk_str1;
*/
	  str_csr1 := INSTR(P_Qte_Header_Rec.QUOTE_NAME, '%', 1, 1);

	  IF(str_csr1 <> 0) THEN
	      l_operator := ' LIKE ';
	  ELSE
	      l_operator := ' = ';
	  END IF;

	  -- check if item value contains '_' wildcard
/*
	  OPEN c_chk_str2(P_Qte_Header_Rec.QUOTE_NAME);
	  FETCH c_chk_str2 INTO str_csr2;
	  CLOSE c_chk_str2;
*/
       str_csr2 := INSTR(P_Qte_Header_Rec.QUOTE_NAME, '_', 1, 1);

	  IF(str_csr2 <> 0) THEN
	      l_operator := ' LIKE ';
	  ELSE
	      l_operator := ' = ';
	  END IF;

	  IF(x_QTE_where IS NULL) THEN
	      x_QTE_where := 'Where ';
	  ELSE
	      x_QTE_where := x_QTE_where || ' AND ';
	  END IF;
	  x_QTE_where := x_QTE_where || 'P_Qte_Header_Rec.QUOTE_NAME ' || l_operator || ' :p_QUOTE_NAME';
      END IF;

      -- Add more IF statements for each column below


END Gen_QTE_Where;

PROCEDURE Get_quote(
    P_Api_Version_Number	 IN   NUMBER,
    P_Init_Msg_List		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_Qte_Header_Rec		 IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested		 IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt		 IN   NUMBER  := 1,
    p_return_tot_count		 IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec		 IN   ASO_QUOTE_PUB.QTE_sort_rec_type,
    x_return_status		 OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count 		 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data			 OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    X_Qte_Header_Tbl		 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Qte_Header_Tbl_Type,
    x_returned_rec_count	 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_next_rec_ptr		 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_tot_rec_count		 OUT NOCOPY /* file.sql.39 change */      NUMBER)
IS
l_api_name		  CONSTANT VARCHAR2(30) := 'Get_quote';
l_api_version_number	  CONSTANT NUMBER   := 1.0;

-- Local record counters
l_returned_rec_count	 NUMBER := 0; -- number of records returned in x_X_Qte_Header_Rec
l_next_record_ptr	 NUMBER := 1;
l_ignore		 NUMBER;

-- total number of records accessable by caller
l_tot_rec_count 	 NUMBER := 0;
l_tot_rec_amount	 NUMBER := 0;

-- Status local variables
l_return_status 	 VARCHAR2(1); -- Return value from procedures
l_return_status_full	 VARCHAR2(1); -- Calculated return status from

-- Dynamic SQL statement elements
l_cur_get_qte		 NUMBER;
l_select_cl		 VARCHAR2(2000) := '';
l_order_by_cl		 VARCHAR2(2000);
l_QTE_where    VARCHAR2(2000) := '';

-- For flex field query
l_flex_where_tbl_type	 ASO_UTILITY_PVT.flex_where_tbl_type;
l_flex_where		 VARCHAR2(2000) := NULL;
l_counter		 NUMBER;

-- Local scratch record
l_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type;
l_crit_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_QUOTE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
			 		     p_api_version_number,
					   l_api_name,
					   G_PKG_NAME)
      THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
	  FND_MSG_PUB.initialize;
      END IF;




      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- *************************************************
      -- Generate Dynamic SQL based on criteria passed in.
      -- Doing this for performance. Indexes are disabled when using NVL within static SQL statement.
      -- Ignore condition when criteria is NULL
      -- Generate Select clause and From clause
      -- Hint: Developer should modify Gen_Select procedure.
      Gen_Select(l_select_cl);

      -- Hint: Developer should modify and implement Gen_Where precedure.
      Gen_QTE_Where(l_crit_qte_header_rec, l_QTE_where);

      -- Generate Where clause for flex fields
      -- Hint: Developer can use table/view alias in the From clause generated in Gen_Select procedure

      FOR l_counter IN 1..15 LOOP
	  l_flex_where_tbl_type(l_counter).name := 'ASO_QUOTE_HEADERS_V.attribute' || l_counter;
      END LOOP;

      l_flex_where_tbl_type(16).name := 'ASO_QUOTE_HEADERS_V.attribute_category';
      l_flex_where_tbl_type(1).value := P_Qte_Header_Rec.attribute1;
      l_flex_where_tbl_type(2).value := P_Qte_Header_Rec.attribute2;
      l_flex_where_tbl_type(3).value := P_Qte_Header_Rec.attribute3;
      l_flex_where_tbl_type(4).value := P_Qte_Header_Rec.attribute4;
      l_flex_where_tbl_type(5).value := P_Qte_Header_Rec.attribute5;
      l_flex_where_tbl_type(6).value := P_Qte_Header_Rec.attribute6;
      l_flex_where_tbl_type(7).value := P_Qte_Header_Rec.attribute7;
      l_flex_where_tbl_type(8).value := P_Qte_Header_Rec.attribute8;
      l_flex_where_tbl_type(9).value := P_Qte_Header_Rec.attribute9;
      l_flex_where_tbl_type(10).value := P_Qte_Header_Rec.attribute10;
      l_flex_where_tbl_type(11).value := P_Qte_Header_Rec.attribute11;
      l_flex_where_tbl_type(12).value := P_Qte_Header_Rec.attribute12;
      l_flex_where_tbl_type(13).value := P_Qte_Header_Rec.attribute13;
      l_flex_where_tbl_type(14).value := P_Qte_Header_Rec.attribute14;
      l_flex_where_tbl_type(15).value := P_Qte_Header_Rec.attribute15;
      l_flex_where_tbl_type(16).value := P_Qte_Header_Rec.attribute_category;

      ASO_UTILITY_PVT.Gen_Flexfield_Where(
	  p_flex_where_tbl_type   => l_flex_where_tbl_type,
	  x_flex_where_clause	  => l_flex_where);

      -- Hint: if master/detail relationship, generate Where clause for lines level criteria
      -- Generate order by clause
      Gen_QTE_order_cl(p_order_by_rec, l_order_by_cl, l_return_status, x_msg_count, x_msg_data);


      l_cur_get_qte := dbms_sql.open_cursor;

      -- Hint: concatenate all where clause (include flex field/line level if any applies)
      --    dbms_sql.parse(l_cur_get_QTE, l_select_cl || l_head_where || l_flex_where || l_lines_where
      --    || l_steam_where || l_order_by_cl, dbms_sql.native);

      -- Hint: Developer should implement Bind Variables procedure according to bind variables in the parameter list
      -- Bind(l_crit_qte_header_rec, l_crit_exp_purchase_rec, p_start_date, p_end_date,
      --      p_crit_exp_salesforce_id, p_crit_ptr_salesforce_id,
      --      p_crit_salesgroup_id, p_crit_ptr_manager_person_id,
      --      p_win_prob_ceiling, p_win_prob_floor,
      --      p_total_amt_ceiling, p_total_amt_floor,
      --      l_cur_get_QTE);

      -- Bind flexfield variables
      ASO_UTILITY_PVT.Bind_Flexfield_Where(
	  p_cursor_id	=>   l_cur_get_QTE,
	  p_flex_where_tbl_type => l_flex_where_tbl_type);

      -- Define all Select Columns
      Define_Columns(l_crit_qte_header_rec, l_cur_get_QTE);

      -- Execute

      l_ignore := dbms_sql.execute(l_cur_get_QTE);


      -- This loop is here to avoid calling a function in the main
      -- cursor. Basically, calling this function seems to disable
      -- index, but verification is needed. This is a good
      -- place to optimize the code if required.

      LOOP
      -- 1. There are more rows in the cursor.
      -- 2. User does not care about total records, and we need to return more.
      -- 3. Or user cares about total number of records.
      IF((dbms_sql.fetch_rows(l_cur_get_QTE)>0) AND ((p_return_tot_count = FND_API.G_TRUE)
	OR (l_returned_rec_count<p_rec_requested) OR (p_rec_requested=FND_API.G_MISS_NUM)))
      THEN

	  -- Hint: Developer need to implement this part
	  --	  dbms_sql.column_value(l_cur_get_opp, 1, l_opp_rec.lead_id);
	  --	  dbms_sql.column_value(l_cur_get_opp, 7, l_opp_rec.customer_id);
	  --	  dbms_sql.column_value(l_cur_get_opp, 8, l_opp_rec.address_id);

	  -- Hint: Check access for this record (e.x. ASO_ACCESS_PVT.Haso_OpportunityAccess)
	  -- Return this particular record if
	  -- 1. The caller has access to record.
	  -- 2. The number of records returned < number of records caller requested in this run.
	  -- 3. The record comes AFTER or Equal to the start index the caller requested.

	  -- Developer should check whether there is access privilege here
--	    IF(l_qte_header_rec.member_access <> 'N' OR l_qte_header_rec.member_role <> 'N') THEN
	      Get_Column_Values(l_cur_get_QTE, l_qte_header_rec);
	      l_tot_rec_count := l_tot_rec_count + 1;
	      IF(l_returned_rec_count < p_rec_requested) AND (l_tot_rec_count >= p_start_rec_prt) THEN
		  l_returned_rec_count := l_returned_rec_count + 1;
		  -- insert into resultant tables
		  X_Qte_Header_Tbl(l_returned_rec_count) := l_qte_header_rec;
	      END IF;
--	    END IF;
      ELSE
	  EXIT;
      END IF;
      END LOOP;
      --
      -- End of API body
      --



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count	  =>   x_msg_count,
	 p_data 	  =>   x_msg_data
      );

      EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Get_quote;

PROCEDURE Validate_Quote
(
    P_Api_Version_Number	 IN   NUMBER,
    P_Init_Msg_List		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_Qte_Header_Id		 IN   NUMBER,
    X_Return_Status		 OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    X_Msg_Count 		 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    X_Msg_Data			 OUT NOCOPY /* file.sql.39 change */      VARCHAR2)
IS
BEGIN
	null;
END Validate_Quote;


-- NAME
--   Submit_Quote
--
-- PURPOSE
--   Validate the quote and quote lines, where quote_id = p_quote_id.
--   If validation is successful, insert the quote and quote lines
--   to OE's interface tables.	Submit a concurrent request to order
--   the quote.
--

PROCEDURE Submit_Quote
(
    P_Api_Version_Number	 IN   NUMBER,
    P_Init_Msg_List		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_Commit			 IN   VARCHAR2	   := FND_API.G_FALSE,
    p_validation_level	 IN   NUMBER	   := FND_API.G_VALID_LEVEL_FULL,
    p_control_rec		 IN   ASO_QUOTE_PUB.SUBMIT_Control_Rec_Type
						:=  ASO_QUOTE_PUB.G_MISS_SUBMIT_CONTROL_REC,
    P_Qte_Header_Id		 IN   NUMBER,
    X_Order_Header_Rec	 OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Order_Header_Rec_Type,
    X_Return_Status		 OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    X_Msg_Count 		 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    X_Msg_Data			 OUT NOCOPY /* file.sql.39 change */      VARCHAR2)

IS

l_qte_header_rec	 ASO_QUOTE_PUB.Qte_Header_Rec_Type
                              := ASO_QUOTE_PUB.G_MISS_Qte_Header_Rec;

BEGIN

-- Calling New Submit_Quote API

	 l_qte_header_rec.quote_header_id := P_Qte_Header_Id;

      ASO_SUBMIT_QUOTE_PVT.Submit_Quote(
          P_Api_Version_Number => 1.0,
          P_Init_Msg_List      => p_init_msg_list,
          P_Commit             => p_commit,
          P_validation_level   => p_validation_level,
          P_Control_Rec        => p_control_rec,
          P_Qte_Header_Rec     => l_qte_header_rec,
          x_order_header_rec   => x_Order_Header_Rec,
          X_Return_Status      => x_return_status,
          X_Msg_Count          => x_msg_count,
          X_Msg_Data           => x_msg_data);


END Submit_Quote;


PROCEDURE config_copy(
   p_qte_line_id   IN   NUMBER,
   p_old_config_header_id IN NUMBER,
   p_old_config_revision_num IN NUMBER,
   p_config_header_id IN NUMBER,
   p_config_revision_num IN NUMBER,
   x_qte_header_id IN NUMBER,
   qte_header_id IN NUMBER,
   p_qte_line_rec IN ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    P_control_rec         IN  ASO_QUOTE_PUB.control_rec_type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
  l_line_index_link_tbl  IN OUT NOCOPY  ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
  l_price_index_link_tbl  IN OUT NOCOPY  ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
  X_Return_Status              OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
  X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */      NUMBER,
  X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */      VARCHAR2
)
IS

CURSOR line_id_from_config IS
 SELECT ASO_Quote_Line_Details.QUOTE_LINE_ID
  FROM ASO_Quote_Line_Details, ASO_Quote_Lines_all
  WHERE ASO_Quote_Line_Details.config_header_id = p_old_config_header_id
  AND ASO_Quote_Line_Details.config_revision_num = p_old_config_revision_num
   AND ASO_quote_line_details.quote_line_id = ASO_Quote_Lines_all.quote_line_id
    AND ASO_Quote_Lines_all.item_type_code <> 'MDL'
    AND aso_quote_lines_all.quote_header_id = qte_header_id;

   l_payment_tbl     ASO_QUOTE_PUB.Payment_Tbl_Type;
   l_payment_tbl_out     ASO_QUOTE_PUB.Payment_Tbl_Type;
   l_shipment_tbl    ASO_QUOTE_PUB.Shipment_Tbl_Type;
   l_shipment_tbl_out    ASO_QUOTE_PUB.Shipment_Tbl_Type;
   l_shipment_rec    ASO_QUOTE_PUB.Shipment_Rec_Type;
   l_freight_charge_tbl   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
   l_freight_charge_tbl_out   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
   l_tax_detail_tbl       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
   l_tax_detail_tbl_out       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

   l_Price_Attr_Tbl       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
   l_Price_Attr_Tbl_out       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
   l_Price_Adj_Tbl   ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
   l_Price_Adj_Attr_Tbl   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
   l_Price_Adj_Attr_Tbl_out   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
   l_qte_line_dtl_tbl     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
   l_qte_line_dtl_tbl_out     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
   l_qte_line_rec     ASO_QUOTE_PUB.Qte_Line_Rec_Type;
   l_Line_Attr_Ext_Tbl    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
   l_Line_Attr_Ext_Tbl_out    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
   lx_ln_Price_Adj_Tbl    ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
   lx_qte_line_rec             ASO_QUOTE_PUB.Qte_Line_Rec_Type;
   l_control_rec    ASO_QUOTE_PUB.Control_Rec_Type;

     LX_PRICE_ADJ_RLTSHIP_ID     NUMBER;
     LX_LINE_RELATIONSHIP_ID     NUMBER;

     X_hd_Attr_Ext_Tbl           ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
     X_Sales_Credit_Tbl        ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
     X_Quote_Party_Tbl         ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
     l_hd_Attr_Ext_Tbl         ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
     l_quote_party_tbl         ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
     l_quote_party_tbl_out         ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
     l_quote_party_rec         ASO_QUOTE_PUB.Quote_Party_rec_Type;
     l_sales_credit_tbl        ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
     l_sales_credit_tbl_out        ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
     l_sales_credit_rec        ASO_QUOTE_PUB.Sales_Credit_rec_Type;

     l_return_status     varchar2(1);
     qte_line_id  NUMBER;
     i NUMBER;
     j NUMBER;
     k NUMBER;

     CURSOR C_Serviceable_Product(l_organization_id NUMBER, l_inv_item_id NUMBER) IS
     SELECT serviceable_product_flag FROM MTL_SYSTEM_ITEMS_VL
     WHERE inventory_item_id = l_inv_item_id
	 AND organization_id = l_organization_id;

    l_quote_line_id number;
    l_serviceable_product_flag  VARCHAR2(1);

l_api_version	CONSTANT NUMBER 	:= 1.0;

BEGIN

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Copy_Config - Begin ', 1, 'Y');
    aso_debug_pub.add('Copy_Config - x_qte_header_id '||x_qte_header_id, 1, 'Y');
    aso_debug_pub.add('Copy_Config - qte_header_id '||qte_header_id, 1, 'Y');
    aso_debug_pub.add('Copy_Config - p_qte_line_id '|| p_qte_line_id, 1, 'Y');
    END IF;

   OPEN line_id_from_config;
   LOOP
    FETCH line_id_from_config INTO qte_line_id;
    EXIT WHEN line_id_from_config%NOTFOUND;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Copy_Config - inside cursor qte_line_id '|| qte_line_id, 1, 'Y');
    END IF;
  l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row(qte_line_id);

  l_qte_line_rec.quote_header_id := x_qte_header_id;

  l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(qte_line_id);

  FOR k IN 1..l_qte_line_dtl_tbl.count LOOP
    l_qte_line_dtl_tbl(k).config_header_id := p_config_header_id;
    l_qte_line_dtl_tbl(k).config_revision_num := p_config_revision_num;
  END LOOP;


   l_line_attr_Ext_Tbl := ASO_UTILITY_PVT.Query_Line_Attribs_Ext_Rows(qte_line_id);
   l_price_adj_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Rows(qte_header_id,qte_line_id);

   FOR j IN 1..l_price_adj_tbl.count LOOP
         l_price_adj_tbl(j).QUOTE_HEADER_ID := x_qte_header_id;
   END LOOP;

   l_price_adj_attr_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Attr_Rows(p_price_adj_tbl => l_price_adj_tbl);
   l_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows(qte_header_id, qte_line_id);

   FOR j IN 1..l_price_attr_tbl.count LOOP
      l_price_attr_tbl(j).QUOTE_HEADER_ID := x_qte_header_id;
   END LOOP;

   l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows(qte_header_id, QTE_LINE_ID);

   FOR j IN 1..l_payment_tbl.count LOOP
         l_payment_tbl(j).QUOTE_HEADER_ID := x_qte_header_id;
         l_payment_tbl(j).CREDIT_CARD_APPROVAL_CODE := NULL;
         l_payment_tbl(j).CREDIT_CARD_APPROVAL_DATE := NULL;
         l_payment_tbl(j).PAYMENT_AMOUNT := NULL;
   END LOOP;

   l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(qte_header_id, QTE_LINE_ID);
   FOR j IN 1..l_shipment_tbl.count LOOP
        l_shipment_tbl(j).QUOTE_HEADER_ID := x_qte_header_id;
   END LOOP;

   l_sales_credit_tbl := ASO_UTILITY_PVT.Query_Sales_Credit_Row(qte_header_id,QTE_LINE_ID);
   FOR j IN 1..l_sales_credit_tbl.count LOOP
       l_sales_credit_tbl(j).QUOTE_HEADER_ID := x_qte_header_id;
   END LOOP;

   l_quote_party_tbl :=  ASO_UTILITY_PVT.Query_Quote_Party_Row(qte_header_id,QTE_LINE_ID);
    FOR j IN 1..l_quote_party_tbl.count LOOP
         l_quote_party_tbl(j).QUOTE_HEADER_ID := x_qte_header_id;
    END LOOP;

    l_freight_charge_tbl := ASO_UTILITY_PVT.Query_Freight_Charge_Rows(l_shipment_tbl);
    l_tax_detail_tbl := ASO_UTILITY_PVT.Query_Tax_Detail_Rows(qte_header_id,QTE_LINE_ID, l_shipment_tbl);

    OPEN C_Serviceable_Product(l_qte_line_rec.organization_id, l_qte_line_rec.inventory_item_id);
    FETCH C_Serviceable_Product INTO l_serviceable_product_flag;
    CLOSE C_Serviceable_Product;
    l_quote_line_id := l_qte_line_rec.quote_line_id;
    -- BC4J Fix
    --l_qte_line_rec.quote_line_id := null;

    ASO_QUOTE_LINES_PVT.Insert_Quote_Line_Rows (
              p_control_rec       => l_control_rec,
              P_qte_Line_Rec      => l_qte_line_rec,
              P_qte_line_dtl_tbl  => l_qte_line_dtl_tbl,
              P_Line_Attribs_Ext_Tbl   => l_line_attr_ext_tbl,
              P_price_attributes_tbl   => l_price_attr_tbl,
              P_Price_Adj_Tbl          => l_price_adj_tbl,
              P_Price_Adj_Attr_Tbl     => l_Price_Adj_Attr_Tbl,
              P_Payment_Tbl       => l_payment_tbl,
              P_Shipment_Tbl      => l_shipment_tbl,
              P_Freight_Charge_Tbl     => l_freight_charge_tbl,
              P_Tax_Detail_Tbl    => l_tax_detail_tbl,
              P_Sales_Credit_Tbl   => l_sales_credit_tbl,
              P_Quote_Party_Tbl   => l_quote_party_tbl,
              x_qte_Line_Rec      => lx_qte_line_rec,
              x_qte_line_dtl_tbl  => l_qte_line_dtl_tbl_out,
               x_Line_Attribs_Ext_Tbl   => l_line_attr_Ext_Tbl_out,
               x_price_attributes_tbl   => l_price_attr_tbl_out,
               x_Price_Adj_Tbl          => lx_ln_price_adj_tbl,
               x_Price_Adj_Attr_Tbl     => l_Price_Adj_Attr_Tbl_out,
               x_Payment_Tbl       => l_payment_tbl_out,
               x_Shipment_Tbl      => l_shipment_tbl_out,
               x_Freight_Charge_Tbl     => l_freight_charge_tbl_out,
               x_Tax_Detail_Tbl    => l_tax_detail_tbl_out,
               X_Sales_Credit_Tbl  => l_sales_credit_tbl_out,
               X_Quote_Party_Tbl   => l_quote_party_tbl_out,
               X_Return_Status     => l_return_status,
               X_Msg_Count         => x_msg_count,
               X_Msg_Data          => x_msg_data);

      l_qte_line_dtl_tbl    :=  l_qte_line_dtl_tbl_out;
      l_line_attr_Ext_Tbl   :=  l_line_attr_Ext_Tbl_out;
      l_price_attr_tbl      :=  l_price_attr_tbl_out;
      l_Price_Adj_Attr_Tbl  :=  l_Price_Adj_Attr_Tbl_out;
      l_payment_tbl         :=  l_payment_tbl_out;
      l_shipment_tbl        :=  l_shipment_tbl_out;
      l_freight_charge_tbl  :=  l_freight_charge_tbl_out;
      l_tax_detail_tbl      :=  l_tax_detail_tbl_out;
      l_sales_credit_tbl    :=  l_sales_credit_tbl_out;
      l_quote_party_tbl     :=  l_quote_party_tbl_out;


	IF p_control_rec.copy_att_flag = 'Y' THEN
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Copy_Rows - Begin- before config  line copy_attch  ', 1, 'Y');
    END IF;

    ASO_ATTACHMENT_INT.Copy_Attachments(
       p_api_version       =>  l_api_version,
       p_old_object_code   => 'ASO_QUOTE_LINES_ALL',
       p_new_object_code   => 'ASO_QUOTE_LINES_ALL',
       p_old_object_id     =>  qte_line_id,
       p_new_object_id     =>  lx_qte_line_rec.quote_line_id,
       x_return_status     =>  x_return_status ,
       x_msg_count         =>  x_msg_count,
       x_msg_data          =>  x_msg_data
    );

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Copy_Rows -After config line copy_attch '||x_return_status, 1, 'Y');
   END IF;

	  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
		  FND_MESSAGE.Set_Token('ROW', 'ASO_COPYQUOTE_ AFTER_ATTACHMENTS', TRUE);
		  FND_MSG_PUB.ADD;
	      END IF;
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	      x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE   FND_API.G_EXC_ERROR;
	  END IF ;
  	END IF;

    FOR j IN 1..l_price_adj_tbl.count LOOP
         l_price_index_link_tbl(l_price_adj_tbl(j).price_adjustment_id) :=
                   lx_ln_price_adj_tbl(j).price_adjustment_id;
   END LOOP;
   l_line_index_link_tbl(qte_line_id) := lx_qte_line_rec.quote_line_id;

-- CLOSE line_id_from_config;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Copy_Config - l_qte_line_tbl(i).item_type_code '|| l_qte_line_rec.item_type_code, 1, 'Y');
aso_debug_pub.add('Copy - l_qte_line_tbl(i).inventory_item_id '|| l_qte_line_rec.inventory_item_id, 1, 'Y');
aso_debug_pub.add('Copy - l_serviceable_product_flag '|| l_serviceable_product_flag, 1, 'Y');
END IF;
    IF l_serviceable_product_flag = 'Y' THEN
			ASO_QUOTE_HEADERS_PVT.service_copy(
                      p_qte_line_id     => l_quote_line_id,
                      p_control_rec     => p_control_rec,
                      x_qte_header_id   => x_qte_header_id,
                      qte_header_id     => qte_header_id,
                      p_qte_line_rec    => l_qte_line_rec,
                      l_line_index_link_tbl   => l_line_index_link_tbl,
                      l_price_index_link_tbl  => l_price_index_link_tbl,
         	          X_Return_Status         => l_return_status,
                      X_Msg_Count             => x_msg_count,
                      X_Msg_Data              => x_msg_data
		      );
          END IF;

	    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		    FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
		    FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER', TRUE);
		    FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;

    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
             FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER', TRUE);
             FND_MSG_PUB.ADD;
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

 END LOOP;

 CLOSE line_id_from_config;

END config_copy;


PROCEDURE service_copy(
   p_qte_line_id        IN   NUMBER,
   x_qte_header_id      IN NUMBER,
   qte_header_id        IN NUMBER,
   p_qte_line_rec       IN ASO_QUOTE_PUB.Qte_Line_Rec_Type,
   P_control_rec        IN  ASO_QUOTE_PUB.control_rec_type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
   l_line_index_link_tbl    IN OUT NOCOPY  ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
   l_price_index_link_tbl   IN OUT NOCOPY  ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type,
   X_Return_Status             OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
   X_Msg_Count                 OUT NOCOPY /* file.sql.39 change */      NUMBER,
   X_Msg_Data                  OUT NOCOPY /* file.sql.39 change */      VARCHAR2
)
IS

CURSOR line_id_from_service IS
 SELECT related_quote_line_id
  FROM aso_line_relationships
  WHERE quote_line_id = p_qte_line_id
  AND relationship_type_code = 'SERVICE';

   l_payment_tbl     ASO_QUOTE_PUB.Payment_Tbl_Type;
   l_payment_tbl_out     ASO_QUOTE_PUB.Payment_Tbl_Type;
   l_shipment_tbl    ASO_QUOTE_PUB.Shipment_Tbl_Type;
   l_shipment_tbl_out    ASO_QUOTE_PUB.Shipment_Tbl_Type;
   l_shipment_rec    ASO_QUOTE_PUB.Shipment_Rec_Type;
   l_freight_charge_tbl   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
   l_freight_charge_tbl_out   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
   l_tax_detail_tbl       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
   l_tax_detail_tbl_out       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

   l_Price_Attr_Tbl       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
   l_Price_Attr_Tbl_out       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
   l_Price_Adj_Tbl   ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
   l_Price_Adj_Attr_Tbl   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
   l_Price_Adj_Attr_Tbl_out   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
   l_qte_line_dtl_tbl     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
   l_qte_line_dtl_tbl_out     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
   l_qte_line_rec     ASO_QUOTE_PUB.Qte_Line_Rec_Type;
   l_Line_Attr_Ext_Tbl    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
   l_Line_Attr_Ext_Tbl_out    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
   lx_ln_Price_Adj_Tbl    ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
   lx_qte_line_rec             ASO_QUOTE_PUB.Qte_Line_Rec_Type;
   l_control_rec    ASO_QUOTE_PUB.Control_Rec_Type;

     LX_PRICE_ADJ_RLTSHIP_ID     NUMBER;
     LX_LINE_RELATIONSHIP_ID     NUMBER;

     X_hd_Attr_Ext_Tbl           ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
     X_Sales_Credit_Tbl        ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
     X_Quote_Party_Tbl         ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
     l_hd_Attr_Ext_Tbl         ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
     l_quote_party_tbl         ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
     l_quote_party_tbl_out         ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
     l_quote_party_rec         ASO_QUOTE_PUB.Quote_Party_rec_Type;
     l_sales_credit_tbl        ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
     l_sales_credit_tbl_out        ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
     l_sales_credit_rec        ASO_QUOTE_PUB.Sales_Credit_rec_Type;

     l_service_ref_line_id  NUMBER;

     l_return_status     varchar2(1);
     qte_line_id  NUMBER;
     i NUMBER;
     j NUMBER;
     k NUMBER;
l_api_version	CONSTANT NUMBER 	:= 1.0;

BEGIN
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Copy_Service - Begin ', 1, 'Y');
    aso_debug_pub.add('Copy_Service - x_qte_header_id '||x_qte_header_id, 1, 'Y');
    aso_debug_pub.add('Copy_Service - qte_header_id '||qte_header_id, 1, 'Y');
    aso_debug_pub.add('Copy_Service - p_qte_line_id '|| p_qte_line_id, 1, 'Y');
    END IF;

   OPEN line_id_from_service;
   LOOP
    FETCH line_id_from_service INTO qte_line_id;
    EXIT WHEN line_id_from_service%NOTFOUND;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Copy_Service - inside cursor qte_line_id '|| qte_line_id, 1, 'Y');
    END IF;
  l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row(qte_line_id);

  l_qte_line_rec.quote_header_id := x_qte_header_id;

  l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(qte_line_id);


         IF l_qte_line_dtl_tbl.count > 0 THEN
	      FOR k IN 1..l_qte_line_dtl_tbl.count LOOP
	        IF l_qte_line_dtl_tbl(k).service_ref_type_code = 'QUOTE' THEN
	          IF l_qte_line_dtl_tbl(k).service_ref_line_id is NOT NULL THEN
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Copy_Service - l_qte_line_dtl_tbl(k).service_ref_line_id '|| l_qte_line_dtl_tbl(k).service_ref_line_id, 1, 'Y');
    END IF;
		    l_service_ref_line_id  :=
		     l_line_index_link_tbl(l_qte_line_dtl_tbl(k).service_ref_line_id);
		    l_qte_line_dtl_tbl(k).service_ref_line_id := l_service_ref_line_id;
		     END IF;
	        END IF;
            END LOOP;
	    END IF;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Copy_Service - 2 l_service_ref_line_id '|| l_service_ref_line_id, 1, 'Y');
    END IF;
/*
  FOR k IN 1..l_qte_line_dtl_tbl.count LOOP
    l_qte_line_dtl_tbl(k).config_header_id := p_config_header_id;
    l_qte_line_dtl_tbl(k).config_revision_num := p_config_revision_num;
  END LOOP;
*/

   l_line_attr_Ext_Tbl := ASO_UTILITY_PVT.Query_Line_Attribs_Ext_Rows(qte_line_id);
   l_price_adj_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Rows(qte_header_id,qte_line_id);

   FOR j IN 1..l_price_adj_tbl.count LOOP
         l_price_adj_tbl(j).QUOTE_HEADER_ID := x_qte_header_id;
   END LOOP;

   l_price_adj_attr_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Attr_Rows(p_price_adj_tbl => l_price_adj_tbl);
   l_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows(qte_header_id, qte_line_id);

   FOR j IN 1..l_price_attr_tbl.count LOOP
      l_price_attr_tbl(j).QUOTE_HEADER_ID := x_qte_header_id;
   END LOOP;

   l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows(qte_header_id, QTE_LINE_ID);

   FOR j IN 1..l_payment_tbl.count LOOP
         l_payment_tbl(j).QUOTE_HEADER_ID := x_qte_header_id;
         l_payment_tbl(j).CREDIT_CARD_APPROVAL_CODE := NULL;
         l_payment_tbl(j).CREDIT_CARD_APPROVAL_DATE := NULL;
         l_payment_tbl(j).PAYMENT_AMOUNT := NULL;
   END LOOP;

   l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(qte_header_id, QTE_LINE_ID);
   FOR j IN 1..l_shipment_tbl.count LOOP
        l_shipment_tbl(j).QUOTE_HEADER_ID := x_qte_header_id;
   END LOOP;

   l_sales_credit_tbl := ASO_UTILITY_PVT.Query_Sales_Credit_Row(qte_header_id,QTE_LINE_ID);
   FOR j IN 1..l_sales_credit_tbl.count LOOP
       l_sales_credit_tbl(j).QUOTE_HEADER_ID := x_qte_header_id;
   END LOOP;

   l_quote_party_tbl :=  ASO_UTILITY_PVT.Query_Quote_Party_Row(qte_header_id,QTE_LINE_ID);
    FOR j IN 1..l_quote_party_tbl.count LOOP
         l_quote_party_tbl(j).QUOTE_HEADER_ID := x_qte_header_id;
    END LOOP;

    l_freight_charge_tbl := ASO_UTILITY_PVT.Query_Freight_Charge_Rows(l_shipment_tbl);
    l_tax_detail_tbl := ASO_UTILITY_PVT.Query_Tax_Detail_Rows(qte_header_id,QTE_LINE_ID, l_shipment_tbl);
    -- BC4J Fix
    --l_qte_line_rec.quote_line_id := null;
    ASO_QUOTE_LINES_PVT.Insert_Quote_Line_Rows (
              p_control_rec       => l_control_rec,
              P_qte_Line_Rec      => l_qte_line_rec,
              P_qte_line_dtl_tbl  => l_qte_line_dtl_tbl,
              P_Line_Attribs_Ext_Tbl   => l_line_attr_ext_tbl,
              P_price_attributes_tbl   => l_price_attr_tbl,
              P_Price_Adj_Tbl          => l_price_adj_tbl,
              P_Price_Adj_Attr_Tbl     => l_Price_Adj_Attr_Tbl,
              P_Payment_Tbl       => l_payment_tbl,
              P_Shipment_Tbl      => l_shipment_tbl,
              P_Freight_Charge_Tbl     => l_freight_charge_tbl,
              P_Tax_Detail_Tbl    => l_tax_detail_tbl,
              P_Sales_Credit_Tbl   => l_sales_credit_tbl,
              P_Quote_Party_Tbl   => l_quote_party_tbl,
              x_qte_Line_Rec      => lx_qte_line_rec,
              x_qte_line_dtl_tbl  => l_qte_line_dtl_tbl_out,
               x_Line_Attribs_Ext_Tbl   => l_line_attr_Ext_Tbl_out,
               x_price_attributes_tbl   => l_price_attr_tbl_out,
               x_Price_Adj_Tbl          => lx_ln_price_adj_tbl,
               x_Price_Adj_Attr_Tbl     => l_Price_Adj_Attr_Tbl_out,
               x_Payment_Tbl       => l_payment_tbl_out,
               x_Shipment_Tbl      => l_shipment_tbl_out,
               x_Freight_Charge_Tbl     => l_freight_charge_tbl_out,
               x_Tax_Detail_Tbl    => l_tax_detail_tbl_out,
               X_Sales_Credit_Tbl  => l_sales_credit_tbl_out,
               X_Quote_Party_Tbl   => l_quote_party_tbl_out,
               X_Return_Status     => l_return_status,
               X_Msg_Count         => x_msg_count,
               X_Msg_Data          => x_msg_data);


      l_qte_line_dtl_tbl    :=  l_qte_line_dtl_tbl_out;
      l_line_attr_Ext_Tbl   :=  l_line_attr_Ext_Tbl_out;
      l_price_attr_tbl      :=  l_price_attr_tbl_out;
      l_Price_Adj_Attr_Tbl  :=  l_Price_Adj_Attr_Tbl_out;
      l_payment_tbl         :=  l_payment_tbl_out;
      l_shipment_tbl        :=  l_shipment_tbl_out;
      l_freight_charge_tbl  :=  l_freight_charge_tbl_out;
      l_tax_detail_tbl      :=  l_tax_detail_tbl_out;
      l_sales_credit_tbl    :=  l_sales_credit_tbl_out;
      l_quote_party_tbl     :=  l_quote_party_tbl_out;


	IF p_control_rec.copy_att_flag = 'Y' THEN
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Copy_Rows - Begin- before config  line copy_attch  ', 1, 'Y');
    END IF;

    ASO_ATTACHMENT_INT.Copy_Attachments(
       p_api_version       =>  l_api_version,
       p_old_object_code   => 'ASO_QUOTE_LINES_ALL',
       p_new_object_code   => 'ASO_QUOTE_LINES_ALL',
       p_old_object_id     =>  qte_line_id,
       p_new_object_id     =>  lx_qte_line_rec.quote_line_id,
       x_return_status     =>  x_return_status ,
       x_msg_count         =>  x_msg_count,
       x_msg_data          =>  x_msg_data
);

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Copy_Rows -After config line copy_attch '||x_return_status, 1, 'Y');
   END IF;

	  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
		  FND_MESSAGE.Set_Token('ROW', 'ASO_COPYQUOTE_ AFTER_ATTACHMENTS', TRUE);
		  FND_MSG_PUB.ADD;
	      END IF;
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	      x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE   FND_API.G_EXC_ERROR;
	  END IF ;
  	END IF;

    FOR j IN 1..l_price_adj_tbl.count LOOP
         l_price_index_link_tbl(l_price_adj_tbl(j).price_adjustment_id) :=
                   lx_ln_price_adj_tbl(j).price_adjustment_id;
   END LOOP;
   l_line_index_link_tbl(qte_line_id) := lx_qte_line_rec.quote_line_id;

-- CLOSE line_id_from_config;

    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
             FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER', TRUE);
             FND_MSG_PUB.ADD;
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;


 END LOOP;

 CLOSE line_id_from_service;

END service_copy;

PROCEDURE Quote_Security_Check(
    P_Api_Version_Number         IN      NUMBER,
    P_Init_Msg_List              IN      VARCHAR2     := FND_API.G_FALSE,
    P_User_Id                    IN      NUMBER,
    X_Resource_Id                OUT NOCOPY /* file.sql.39 change */         NUMBER,
    X_Security_Flag              OUT NOCOPY /* file.sql.39 change */         VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */         VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */         NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */         VARCHAR2
)
IS

    l_role_type               VARCHAR2(240) := NULL;
    l_mgr_flag                VARCHAR2(1)   := NULL;
    l_api_name                CONSTANT VARCHAR2(30) := 'QUOTE_SECURITY_CHECK';
    l_api_version_number      CONSTANT NUMBER   := 1.0;

    Cursor C_salesrep (X_User_Id NUMBER) IS
    SELECT j.resource_id
    /* FROM jtf_rs_srp_vl srp, jtf_rs_resource_extns j  */  --Commented Code Yogeshwar (MOAC)
    FROM jtf_rs_salesreps_mo_v srp, jtf_rs_resource_extns j --New Code Yogeshwar (MOAC)
    WHERE j.user_id = X_User_Id
      AND j.resource_id = srp.resource_id
      AND srp.status = 'A'
      AND nvl(trunc(srp.start_date_active), trunc(sysdate)) <= trunc(sysdate)
      AND nvl(trunc(srp.end_date_active), trunc(sysdate)) >= trunc(sysdate);
      /*  --Commented Code Start Yogeshwar (MOAC)
      AND NVL(srp.org_id,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
     */   --Commented Code End yogeshwar (MOAC)


    Cursor C_role (X_Resource_Id NUMBER, X_Profile_Role_Type VARCHAR2) IS
    SELECT role.role_type_code, role.manager_flag
    FROM JTF_RS_DEFRESROLES_VL role, JTF_RS_DEFRESOURCES_VL res
    WHERE role.role_resource_id = res.resource_id
      AND res.resource_id = X_resource_id
      AND nvl(trunc(role.res_rl_start_date), trunc(sysdate)) <= trunc(sysdate)
      AND nvl(trunc(role.res_rl_end_date), trunc(sysdate)) >= trunc(sysdate)
      AND role.ROLE_TYPE_CODE = X_profile_role_type
      AND role.delete_flag = 'N';

BEGIN

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;


    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    X_Resource_Id := NULL;
    X_Security_Flag := 'N';

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Quote_Security_Check(): before main logic', 1, 'Y');
    END IF;

    FOR c_sv IN C_salesrep(p_user_id) LOOP
        X_Resource_Id := c_sv.resource_id;
        IF X_Resource_Id IS NOT NULL THEN
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.add('Quote_Security_Check(): Resource_Id IS NOT NULL', 1, 'Y');
		  END IF;
            IF (FND_PROFILE.Value('ASO_ROLE_TYPE')) IS NOT NULL THEN
                IF aso_debug_pub.g_debug_flag = 'Y' THEN
			 aso_debug_pub.add('Quote_Security_Check(): ASO_ROLE_TYPE NOT NULL', 1, 'Y');
			 END IF;
                FOR c_r IN C_role(X_Resource_Id, FND_PROFILE.Value('ASO_ROLE_TYPE')) LOOP
                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
				aso_debug_pub.add('Quote_Security_Check(): C_Role FOUND', 1, 'Y');
				END IF;
                    l_mgr_flag := c_r.manager_flag;
                    IF l_mgr_flag ='Y' THEN
                        X_Security_Flag := 'Y';
                    END IF;
                END LOOP;
                IF l_mgr_flag IS NULL THEN
                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
				aso_debug_pub.add('Quote_Security_Check(): C_Role NOTFOUND', 1, 'Y');
				END IF;
                    X_Security_Flag := 'Y';
                END IF;
            ELSE
                IF aso_debug_pub.g_debug_flag = 'Y' THEN
			 aso_debug_pub.add('Quote_Security_Check(): ASO_ROLE_TYPE IS NULL', 1, 'Y');
			 END IF;
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.set_name('ASO','ASO_ERR_ROLE_TYPE_NULL');
                    FND_MSG_PUB.ADD;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
            END IF;
        END IF;
    END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Quote_Security_Check(): after main logic', 1, 'Y');
    aso_debug_pub.add('Quote_Security_Check(): End:   Resource_Id:   '||X_Resource_Id, 1, 'Y');
    aso_debug_pub.add('Quote_Security_Check(): End:   Security_Flag: '||X_Security_Flag, 1, 'Y');
    END IF;


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

End Quote_Security_Check;


End ASO_QUOTE_HEADERS_PVT;

/
