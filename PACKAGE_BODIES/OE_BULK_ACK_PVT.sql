--------------------------------------------------------
--  DDL for Package Body OE_BULK_ACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_ACK_PVT" AS
/* $Header: OEBVACKB.pls 120.2.12010000.2 2008/11/18 13:18:04 smusanna ship $ */


G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_BULK_ACK_PVT';

PROCEDURE Insert_Rejected_Lines_Ack(p_batch_id  IN NUMBER,
                                    p_order_source_id IN NUMBER,
                                    p_orig_sys_document_ref IN VARCHAR2);

FUNCTION Get_Address_ID(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN NUMBER
IS
  l_c_index            NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).ADDRESS_ID;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).ADDRESS_ID;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).ADDRESS_ID;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).ADDRESS_ID;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_Site(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).ADDRESS_ID;

  END IF;

END Get_Address_ID;

FUNCTION Get_Address1(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2
IS
  l_c_index           NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).ADDRESS1;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).ADDRESS1;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).ADDRESS1;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).ADDRESS1;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_Site(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).ADDRESS1;

  END IF;

END Get_ADDRESS1;

FUNCTION Get_Address2(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2
IS
  l_c_index           NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).ADDRESS2;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).ADDRESS2;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).ADDRESS2;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).ADDRESS2;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_SITE(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).ADDRESS2;

  END IF;

END Get_ADDRESS2;

FUNCTION Get_Address3(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2
IS
  l_c_index           NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).ADDRESS3;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).ADDRESS3;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).ADDRESS3;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).ADDRESS3;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_Site(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).ADDRESS3;

  END IF;

END Get_ADDRESS3;

FUNCTION Get_Address4(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2
IS
  l_c_index           NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).ADDRESS4;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).ADDRESS4;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).ADDRESS4;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).ADDRESS4;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_Site(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).ADDRESS4;

  END IF;

END Get_ADDRESS4;

FUNCTION Get_State(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2
IS
  l_c_index           NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).STATE;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).STATE;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).STATE;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).STATE;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_Site(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).STATE;

  END IF;

END Get_STATE;

FUNCTION Get_City(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2
IS
  l_c_index           NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).CITY;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).CITY;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).CITY;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).CITY;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_Site(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).CITY;

  END IF;

END Get_CITY;

FUNCTION Get_Zip(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2
IS
  l_c_index           NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).ZIP;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).ZIP;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).ZIP;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).ZIP;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_Site(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).ZIP;

  END IF;

END Get_ZIP;

FUNCTION Get_Country(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2
IS
  l_c_index           NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).COUNTRY;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).COUNTRY;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).COUNTRY;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).COUNTRY;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_Site(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).COUNTRY;

  END IF;

END Get_COUNTRY;

FUNCTION Get_County(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2
IS
  l_c_index           NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).COUNTY;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).COUNTY;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).COUNTY;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).COUNTY;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_Site(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).COUNTY;

  END IF;

END Get_COUNTY;

FUNCTION Get_Province(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2
IS
  l_c_index           NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).PROVINCE;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).PROVINCE;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).PROVINCE;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).PROVINCE;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_Site(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).PROVINCE;

  END IF;

END Get_PROVINCE;

FUNCTION Get_Location(p_key          IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2
IS
  l_c_index           NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).LOCATION;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).LOCATION;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).LOCATION;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).LOCATION;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_Site(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).LOCATION;
  END IF;

END Get_LOCATION;

FUNCTION Get_EDI_Location(p_key          IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2
IS
  l_c_index           NUMBER;
BEGIN

  IF p_key IS NULL THEN
     RETURN NULL;
  END IF;

  IF p_site_use_code = 'SHIP_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SHIP_TO_TBL(l_c_index).EDI_LOCATION_CODE;

  ELSIF p_site_use_code = 'BILL_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Invoice_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_INVOICE_TO_TBL(l_c_index).EDI_LOCATION_CODE;

  ELSIF p_site_use_code = 'SHIP_FROM' THEN

    l_c_index := OE_BULK_CACHE.Load_Ship_From(p_key);
    RETURN OE_BULK_CACHE.G_SHIP_FROM_TBL(l_c_index).EDI_LOCATION_CODE;

  ELSIF p_site_use_code = 'SOLD_TO' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_TBL(l_c_index).EDI_LOCATION_CODE;

  ELSIF p_site_use_code = 'SOLD_TO_SITE' THEN

    l_c_index := OE_BULK_CACHE.Load_Sold_To_Site(p_key,'N','Y');
    RETURN OE_BULK_CACHE.G_SOLD_TO_SITE_TBL(l_c_index).EDI_LOCATION_CODE;
  END IF;

END Get_EDI_LOCATION;

PROCEDURE Insert_Header_Acks
        (p_header_id            IN NUMBER
        )
IS
BEGIN

      INSERT INTO OE_HEADER_ACKS
     (ACCOUNTING_RULE
      ,ACCOUNTING_RULE_ID
      ,ACCOUNTING_RULE_DURATION
      ,ACKNOWLEDGMENT_FLAG
      ,AGREEMENT
      ,AGREEMENT_ID
      ,AGREEMENT_NAME
      ,ATTRIBUTE1
      ,ATTRIBUTE2
      ,ATTRIBUTE3
      ,ATTRIBUTE4
      ,ATTRIBUTE5
      ,ATTRIBUTE6
      ,ATTRIBUTE7
      ,ATTRIBUTE8
      ,ATTRIBUTE9
      ,ATTRIBUTE10
      ,ATTRIBUTE11
      ,ATTRIBUTE12
      ,ATTRIBUTE13
      ,ATTRIBUTE14
      ,ATTRIBUTE15
      ,ATTRIBUTE16      --For bug 2184255
      ,ATTRIBUTE17
      ,ATTRIBUTE18
      ,ATTRIBUTE19
      ,ATTRIBUTE20
      ,FIRST_ACK_CODE
      ,LAST_ACK_CODE
      ,FIRST_ACK_DATE
      ,LAST_ACK_DATE
      ,BUYER_SELLER_FLAG
      ,BOOKED_FLAG
      ,CANCELLED_FLAG
--      ,CLOSED_FLAG
      ,CHANGE_DATE
      ,CHANGE_SEQUENCE
      ,CONTEXT
      ,CONVERSION_RATE
      ,CONVERSION_RATE_DATE
      ,CONVERSION_TYPE
      ,CONVERSION_TYPE_CODE
      ,CREATED_BY
      ,CREATION_DATE
      ,CUST_PO_NUMBER
--        ,CUSTOMER_ID
      ,CUSTOMER_NAME
        ,CUSTOMER_NUMBER
--      ,DELIVER_TO_CONTACT
      ,DELIVER_TO_CONTACT_ID
      ,DELIVER_TO_CUSTOMER
      ,DELIVER_TO_CUSTOMER_NUMBER
--      ,DELIVER_TO_ORG
      ,DELIVER_TO_ORG_ID
--      ,DEMAND_CLASS
      ,DEMAND_CLASS_CODE
      ,EARLIEST_SCHEDULE_LIMIT
--      ,ERROR_FLAG
      ,EXPIRATION_DATE
      ,FOB_POINT
      ,FOB_POINT_CODE
      ,FREIGHT_CARRIER_CODE
      ,FREIGHT_TERMS
      ,FREIGHT_TERMS_CODE
      ,GLOBAL_ATTRIBUTE_CATEGORY
      ,GLOBAL_ATTRIBUTE1
      ,GLOBAL_ATTRIBUTE10
      ,GLOBAL_ATTRIBUTE11
      ,GLOBAL_ATTRIBUTE12
      ,GLOBAL_ATTRIBUTE13
      ,GLOBAL_ATTRIBUTE14
      ,GLOBAL_ATTRIBUTE15
      ,GLOBAL_ATTRIBUTE16
      ,GLOBAL_ATTRIBUTE17
      ,GLOBAL_ATTRIBUTE18
      ,GLOBAL_ATTRIBUTE19
      ,GLOBAL_ATTRIBUTE2
      ,GLOBAL_ATTRIBUTE20
      ,GLOBAL_ATTRIBUTE3
      ,GLOBAL_ATTRIBUTE4
      ,GLOBAL_ATTRIBUTE5
      ,GLOBAL_ATTRIBUTE6
      ,GLOBAL_ATTRIBUTE7
      ,GLOBAL_ATTRIBUTE8
      ,GLOBAL_ATTRIBUTE9
        -- ,TP_CONTEXT
        -- ,TP_ATTRIBUTE1
        -- ,TP_ATTRIBUTE2
        -- ,TP_ATTRIBUTE3
        -- ,TP_ATTRIBUTE4
        -- ,TP_ATTRIBUTE5
        -- ,TP_ATTRIBUTE6
        -- ,TP_ATTRIBUTE7
        -- ,TP_ATTRIBUTE8
        -- ,TP_ATTRIBUTE9
        -- ,TP_ATTRIBUTE10
        -- ,TP_ATTRIBUTE11
        -- ,TP_ATTRIBUTE12
        -- ,TP_ATTRIBUTE13
        -- ,TP_ATTRIBUTE14
        -- ,TP_ATTRIBUTE15
      ,HEADER_ID
--      ,HEADER_PO_CONTEXT
--      ,INTERFACE_STATUS
      ,INVOICE_ADDRESS_1
      ,INVOICE_ADDRESS_2
      ,INVOICE_ADDRESS_3
      ,INVOICE_ADDRESS_4
      ,INVOICE_CITY
      ,INVOICE_COUNTRY
      ,INVOICE_COUNTY
      ,INVOICE_POSTAL_CODE
      ,INVOICE_PROVINCE_INT
--      ,INVOICE_SITE
      ,INVOICE_SITE_CODE
      ,INVOICE_STATE
--      ,INVOICE_TO_CONTACT
      ,INVOICE_TO_CONTACT_FIRST_NAME
      ,INVOICE_TO_CONTACT_ID
      ,INVOICE_TO_CONTACT_LAST_NAME
      ,INVOICE_TO_ORG
      ,INVOICE_TO_ORG_ID
--      ,INVOICE_TOLERANCE_ABOVE
--      ,INVOICE_TOLERANCE_BELOW
      ,INVOICING_RULE
      ,INVOICING_RULE_ID
      ,LAST_UPDATE_DATE
      ,LAST_UPDATE_LOGIN
      ,LAST_UPDATED_BY
      ,LATEST_SCHEDULE_LIMIT
      ,OPEN_FLAG
--      ,OPERATION_CODE
      ,ORDER_DATE_TYPE_CODE
      ,ORDER_NUMBER
      ,ORDER_SOURCE
      ,ORDER_SOURCE_ID
      ,ORDER_TYPE
      ,ORDER_TYPE_ID
--      ,ORDERED_BY_CONTACT_FIRST_NAME
--      ,ORDERED_BY_CONTACT_LAST_NAME
      ,ORDERED_DATE
      ,ORG_ID
      ,ORIG_SYS_DOCUMENT_REF
        ,PACKING_INSTRUCTIONS
      ,PARTIAL_SHIPMENTS_ALLOWED
      ,PAYMENT_TERM
      ,PAYMENT_TERM_ID
--      ,PO_ATTRIBUTE_1
--      ,PO_ATTRIBUTE_2
--      ,PO_ATTRIBUTE_3
--      ,PO_ATTRIBUTE_4
--      ,PO_ATTRIBUTE_5
--      ,PO_ATTRIBUTE_6
--      ,PO_ATTRIBUTE_7
--      ,PO_ATTRIBUTE_8
--      ,PO_ATTRIBUTE_9
--      ,PO_ATTRIBUTE_10
--      ,PO_ATTRIBUTE_11
--      ,PO_ATTRIBUTE_12
--      ,PO_ATTRIBUTE_13
--      ,PO_ATTRIBUTE_14
--      ,PO_ATTRIBUTE_15
--      ,PO_REVISION_DATE
      ,PRICE_LIST
      ,PRICE_LIST_ID
      ,PRICING_DATE
      ,PROGRAM
      ,PROGRAM_APPLICATION
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_ID
      ,PROGRAM_UPDATE_DATE
--      ,RELATED_PO_NUMBER
--      ,REMAINDER_ORDERS_ALLOWED
      ,REQUEST_DATE
      ,REQUEST_ID
      ,RETURN_REASON_CODE
      ,SALESREP
      ,SALESREP_ID
      ,SHIP_FROM_ORG
      ,SHIP_FROM_ORG_ID
      ,SHIP_TO_ADDRESS_1
      ,SHIP_TO_ADDRESS_2
      ,SHIP_TO_ADDRESS_3
      ,SHIP_TO_ADDRESS_4
      ,SHIP_TO_CITY
     ,SHIP_TO_CONTACT
      ,SHIP_TO_CONTACT_FIRST_NAME
      ,SHIP_TO_CONTACT_ID
      ,SHIP_TO_CONTACT_LAST_NAME
      ,SHIP_TO_COUNTRY
      ,SHIP_TO_COUNTY
--      ,SHIP_TO_CUSTOMER
--      ,SHIP_TO_CUSTOMER_NUMBER
      ,SHIP_TO_ORG
      ,SHIP_TO_ORG_ID
      ,SHIP_TO_POSTAL_CODE
      ,SHIP_TO_PROVINCE
--      ,SHIP_TO_SITE_INT
      ,SHIP_TO_STATE
      ,SHIP_TOLERANCE_ABOVE
      ,SHIP_TOLERANCE_BELOW
--      ,SHIPMENT_PRIORITY
      ,SHIPMENT_PRIORITY_CODE
--      ,SHIPMENT_PRIORITY_CODE_INT
        ,SHIPPING_INSTRUCTIONS
--      ,SHIPPING_METHOD
      ,SHIPPING_METHOD_CODE
      ,SOLD_FROM_ORG
      ,SOLD_FROM_ORG_ID
      ,SOLD_TO_CONTACT
      ,SOLD_TO_CONTACT_ID
      ,SOLD_TO_ORG
      ,SOLD_TO_ORG_ID
      ,SOURCE_DOCUMENT_ID
      ,SOURCE_DOCUMENT_TYPE_ID
--      ,SUBMISSION_DATETIME
      ,TAX_EXEMPT_FLAG
      ,TAX_EXEMPT_NUMBER
      ,TAX_EXEMPT_REASON
      ,TAX_EXEMPT_REASON_CODE
      ,TAX_POINT
      ,TAX_POINT_CODE
--      ,TRANSACTIONAL_CURR
      ,TRANSACTIONAL_CURR_CODE
      ,VERSION_NUMBER
        ,ship_to_edi_location_code
        ,sold_to_edi_location_code
        ,BILL_TO_EDI_LOCATION_CODE
        ,Customer_payment_term
        ,SOLD_TO_ADDRESS1
        ,SOLD_TO_ADDRESS2
        ,SOLD_TO_ADDRESS3
        ,SOLD_TO_ADDRESS4
        ,SOLD_TO_CITY
        ,SOLD_TO_POSTAL_CODE
        ,SOLD_TO_COUNTRY
        ,SOLD_TO_STATE
        ,SOLD_TO_COUNTY
        ,SOLD_TO_PROVINCE
        ,SOLD_TO_CONTACT_LAST_NAME
        ,SOLD_TO_CONTACT_FIRST_NAME
        ,ORDER_CATEGORY_CODE
        ,ship_from_edi_location_code
        ,SHIP_FROM_ADDRESS_1
        ,SHIP_FROM_ADDRESS_2
        ,SHIP_FROM_ADDRESS_3
        ,SHIP_FROM_CITY
        ,SHIP_FROM_POSTAL_CODE
        ,SHIP_FROM_COUNTRY
        ,SHIP_FROM_REGION1
        ,SHIP_FROM_REGION2
        ,SHIP_FROM_REGION3
        ,SHIP_FROM_ADDRESS_ID
        ,SOLD_TO_ADDRESS_ID
        ,SHIP_TO_ADDRESS_ID
        ,INVOICE_ADDRESS_ID
        ,SHIP_TO_ADDRESS_CODE
        ,XML_MESSAGE_ID
	,SOLD_TO_SITE_USE_ID
	,SOLD_TO_LOCATION_ADDRESS1
	,SOLD_TO_LOCATION_ADDRESS2
	,SOLD_TO_LOCATION_ADDRESS3
	,SOLD_TO_LOCATION_ADDRESS4
	,SOLD_TO_LOCATION_CITY
	,SOLD_TO_LOCATION_POSTAL_CODE
	,SOLD_TO_LOCATION_COUNTRY
	,SOLD_TO_LOCATION_STATE
	,SOLD_TO_LOCATION_COUNTY
	,SOLD_TO_LOCATION_PROVINCE
      )
      SELECT /*+ PUSH_PRED(salesrep) */
        accrule.NAME                  -- ACCOUNTING_RULE
      , h.ACCOUNTING_RULE_ID
      , h.ACCOUNTING_RULE_DURATION
      ,''                           -- acknowledgment_flag
      , agr.NAME                    -- AGREEMENT
      , h.AGREEMENT_ID
      ,''                           -- AGREEMENT_NAME
      , h.ATTRIBUTE1
      , h.ATTRIBUTE2
      , h.ATTRIBUTE3
      , h.ATTRIBUTE4
      , h.ATTRIBUTE5
      , h.ATTRIBUTE6
      , h.ATTRIBUTE7
      , h.ATTRIBUTE8
      , h.ATTRIBUTE9
      , h.ATTRIBUTE10
      , h.ATTRIBUTE11
      , h.ATTRIBUTE12
      , h.ATTRIBUTE13
      , h.ATTRIBUTE14
      , h.ATTRIBUTE15
      , h.ATTRIBUTE16  -- for bug 2184255
      , h.ATTRIBUTE17
      , h.ATTRIBUTE18
      , h.ATTRIBUTE19
      , h.ATTRIBUTE20
      , decode(h.order_source_id,20,'0','AT')  -- FIRST_ACK_CODE
      , h.LAST_ACK_CODE
      , h.FIRST_ACK_DATE
      , h.LAST_ACK_DATE
      , 'B'		-- BUYER_SELLER_FLAG
      , h.BOOKED_FLAG
      , h.CANCELLED_FLAG
      , ''		-- CHANGE_DATE
      , h.CHANGE_SEQUENCE
      , h.CONTEXT
      , h.CONVERSION_RATE
      , h.CONVERSION_RATE_DATE
      , conv_type.USER_CONVERSION_TYPE   -- CONVERSION_TYPE
      , h.CONVERSION_TYPE_CODE
      , h.CREATED_BY
      , h.CREATION_DATE
      , h.CUST_PO_NUMBER
        , NULL -- INVOICE_TO_CUSTOMER_NAME
        , NULL -- INVOICE_TO_CUSTOMER_NUMBER
      , h.DELIVER_TO_CONTACT_ID
        , NULL -- l_header_val_rec.DELIVER_TO_CUSTOMER_NAME
        , NULL -- l_header_val_rec.DELIVER_TO_CUSTOMER_NUMBER
      , h.DELIVER_TO_ORG_ID
      , h.DEMAND_CLASS_CODE
      , h.EARLIEST_SCHEDULE_LIMIT
      , h.EXPIRATION_DATE
      , fob.MEANING                     -- FOB_POINT
      , h.FOB_POINT_CODE
      , h.FREIGHT_CARRIER_CODE
      , ft.MEANING                      -- FREIGHT_TERMS
      , h.FREIGHT_TERMS_CODE
      , h.GLOBAL_ATTRIBUTE_CATEGORY
      , h.GLOBAL_ATTRIBUTE1
      , h.GLOBAL_ATTRIBUTE10
      , h.GLOBAL_ATTRIBUTE11
      , h.GLOBAL_ATTRIBUTE12
      , h.GLOBAL_ATTRIBUTE13
      , h.GLOBAL_ATTRIBUTE14
      , h.GLOBAL_ATTRIBUTE15
      , h.GLOBAL_ATTRIBUTE16
      , h.GLOBAL_ATTRIBUTE17
      , h.GLOBAL_ATTRIBUTE18
      , h.GLOBAL_ATTRIBUTE19
      , h.GLOBAL_ATTRIBUTE2
      , h.GLOBAL_ATTRIBUTE20
      , h.GLOBAL_ATTRIBUTE3
      , h.GLOBAL_ATTRIBUTE4
      , h.GLOBAL_ATTRIBUTE5
      , h.GLOBAL_ATTRIBUTE6
      , h.GLOBAL_ATTRIBUTE7
      , h.GLOBAL_ATTRIBUTE8
      , h.GLOBAL_ATTRIBUTE9
        -- h.TP_CONTEXT
        -- h.TP_ATTRIBUTE1
        -- h.TP_ATTRIBUTE2
        -- h.TP_ATTRIBUTE3
        -- h.TP_ATTRIBUTE4
        -- h.TP_ATTRIBUTE5
        -- h.TP_ATTRIBUTE6
        -- h.TP_ATTRIBUTE7
        -- h.TP_ATTRIBUTE8
        -- h.TP_ATTRIBUTE9
        -- h.TP_ATTRIBUTE10
        -- h.TP_ATTRIBUTE11
        -- h.TP_ATTRIBUTE12
        -- h.TP_ATTRIBUTE13
        -- h.TP_ATTRIBUTE14
        -- h.TP_ATTRIBUTE15
      , h.HEADER_ID--number
      , Get_Address1(h.invoice_to_org_id,'BILL_TO') -- INVOICE_TO_ADDRESS1
      , Get_Address2(h.invoice_to_org_id,'BILL_TO') -- INVOICE_TO_ADDRESS2
      , Get_Address3(h.invoice_to_org_id,'BILL_TO') -- INVOICE_TO_ADDRESS3
      , Get_Address4(h.invoice_to_org_id,'BILL_TO') -- INVOICE_TO_ADDRESS4
      , Get_City(h.invoice_to_org_id,'BILL_TO') -- INVOICE_to_city
      , Get_Country(h.invoice_to_org_id,'BILL_TO') -- INVOICE_to_country
      , Get_Country(h.invoice_to_org_id,'BILL_TO') -- INVOICE_to_county
      , Get_Zip(h.invoice_to_org_id,'BILL_TO') -- INVOICE_to_zip
      , Get_Province(h.invoice_to_org_id,'BILL_TO') -- INVOICE_to_province
      , Get_Location(h.invoice_to_org_id,'BILL_TO') -- INVOICE_to_location
      , Get_State(h.invoice_to_org_id,'BILL_TO') -- INVOICE_to_state
      , inv_party.PERSON_first_name          -- invoice_to_contact_first_name
      , h.INVOICE_TO_CONTACT_ID
      , inv_party.PERSON_last_name           -- invoice_to_contact_last_name
      , Get_Location(h.invoice_to_org_id,'BILL_TO') -- INVOICE_TO_ORG
      , h.INVOICE_TO_ORG_ID
      , invrule.NAME                      -- INVOICING_RULE
      , h.INVOICING_RULE_ID
      , h.LAST_UPDATE_DATE
      , h.LAST_UPDATE_LOGIN
      , h.LAST_UPDATED_BY
      , h.LATEST_SCHEDULE_LIMIT
      , h.OPEN_FLAG
      , h.ORDER_DATE_TYPE_CODE
      , h.ORDER_NUMBER
      , os.NAME                          -- ORDER_SOURCE
      , h.ORDER_SOURCE_ID
      , ot.NAME                          -- ORDER_TYPE
      , h.ORDER_TYPE_ID
      , h.ORDERED_DATE
      , h.ORG_ID
      , h.ORIG_SYS_DOCUMENT_REF
        , h.PACKING_INSTRUCTIONS
      , h.PARTIAL_SHIPMENTS_ALLOWED
      , term.NAME                        -- PAYMENT_TERM
      , h.PAYMENT_TERM_ID
      , pl.NAME                          -- PRICE_LIST
      , h.PRICE_LIST_ID
      , h.PRICING_DATE
      , ''		-- PROGRAM
      , ''		-- PROGRAM_APPLICATION
      , h.PROGRAM_APPLICATION_ID
      , h.PROGRAM_ID
      , h.PROGRAM_UPDATE_DATE
      , h.REQUEST_DATE
      , h.REQUEST_ID
      , h.RETURN_REASON_CODE
      , salesrep.NAME               -- SALESREP
      , h.SALESREP_ID
      , Get_Location(h.ship_from_org_id,'SHIP_FROM') -- SHIP_FROM_ORG
      , h.SHIP_FROM_ORG_ID
      , Get_Address1(h.ship_to_org_id,'SHIP_TO') -- SHIP_to_address1
      , Get_Address2(h.ship_to_org_id,'SHIP_TO') -- SHIP_to_address2
      , Get_Address3(h.ship_to_org_id,'SHIP_TO') -- SHIP_to_address3
      , Get_Address4(h.ship_to_org_id,'SHIP_TO') -- SHIP_to_address4
      , Get_City(h.ship_to_org_id,'SHIP_TO') -- SHIP_to_city
      , Get_Address1(h.ship_to_org_id,'SHIP_TO') -- SHIP_TO_CONTACT
      , ship_party.PERSON_FIRST_NAME            -- SHIP_TO_CONTACT_FIRST_NAME
      , h.SHIP_TO_CONTACT_ID
      , ship_party.PERSON_LAST_NAME             -- SHIP_TO_CONTACT_LAST_NAME
      , Get_Country(h.ship_to_org_id,'SHIP_TO') -- SHIP_to_country
      , Get_County(h.ship_to_org_id,'SHIP_TO') -- SHIP_to_county
      , Get_Location(h.ship_to_org_id,'SHIP_TO') -- SHIP_TO_ORG
      , h.SHIP_TO_ORG_ID
      , Get_Zip(h.ship_to_org_id,'SHIP_TO') -- SHIP_to_zip
      , Get_Province(h.ship_to_org_id,'SHIP_TO') -- SHIP_to_province
      , Get_State(h.ship_to_org_id,'SHIP_TO') -- SHIP_to_state
      , h.SHIP_TOLERANCE_ABOVE
      , h.SHIP_TOLERANCE_BELOW
      , h.SHIPMENT_PRIORITY_CODE
        , h.SHIPPING_INSTRUCTIONS
      , h.SHIPPING_METHOD_CODE
      , ''		-- SOLD_FROM_ORG
      , '' 		-- SOLD_FROM_ORG_ID
      , Get_Address1(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_CONTACT
      , h.SOLD_TO_CONTACT_ID
      , Get_Address1(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_ORG
      , h.SOLD_TO_ORG_ID
      , h.SOURCE_DOCUMENT_ID
      , h.SOURCE_DOCUMENT_TYPE_ID
      , h.TAX_EXEMPT_FLAG
      , h.TAX_EXEMPT_NUMBER
      , tax_exempt_reason.MEANING    -- TAX_EXEMPT_REASON
      , h.TAX_EXEMPT_REASON_CODE
      , tax_point.MEANING            -- TAX_POINT
      , h.TAX_POINT_CODE
      , h.TRANSACTIONAL_CURR_CODE
      , h.VERSION_NUMBER
      , Get_EDI_Location(h.ship_to_org_id,'SHIP_TO') -- SHIP_to_edi_location_code
      , Get_EDI_Location(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_EDI_LOCATION_CODE
      , Get_EDI_Location(h.invoice_to_org_id,'BILL_TO') -- BILL_TO_EDI_LOCATION_CODE
      , null                         -- CUSTOMER_PAYMENT_TERM
      , Get_Address1(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_ADDRESS1
      , Get_Address2(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_ADDRESS2
      , Get_Address3(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_ADDRESS3
      , Get_Address4(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_ADDRESS4
      , Get_City(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_CITY
      , Get_Zip(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_ZIP
      , Get_Country(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_COUNTRY
      , Get_State(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_STATE
      , Get_County(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_COUNTY
      , Get_Province(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_PROVINCE
      , sold_party.PERSON_LAST_NAME            -- SOLD_TO_CONTACT_LAST_NAME
      , sold_party.PERSON_FIRST_NAME           -- SOLD_TO_CONTACT_FIRST_NAME
      , h.ORDER_CATEGORY_CODE
      , Get_EDI_Location(h.ship_from_org_id,'SHIP_FROM') -- SHIP_FROM_edi_location_code
      , Get_Address1(h.ship_from_org_id,'SHIP_FROM') -- SHIP_FROM_ADDRESS1
      , Get_Address2(h.ship_from_org_id,'SHIP_FROM') -- SHIP_FROM_ADDRESS2
      , Get_Address3(h.ship_from_org_id,'SHIP_FROM') -- SHIP_FROM_ADDRESS3
      , Get_City(h.ship_from_org_id,'SHIP_FROM') -- SHIP_FROM_CITY
      , Get_Zip(h.ship_from_org_id,'SHIP_FROM') -- SHIP_FROM_POSTAL_CODE
      , Get_Country(h.ship_from_org_id,'SHIP_FROM') -- SHIP_FROM_COUNTRY
      , NULL                                        -- SHIP_FROM_REGION1
      , NULL                                        -- SHIP_FROM_REGION2
      , NULL                                        -- SHIP_FROM_REGION3
      , Get_Address_ID(h.ship_from_org_id,'SHIP_FROM') -- SHIP_FROM_ADDRESS_ID
      , Get_Address_ID(h.sold_to_org_id,'SOLD_TO') -- SOLD_TO_ADDRESS_ID
      , Get_Address_ID(h.ship_to_org_id,'SHIP_TO') -- SHIP_TO_ADDRESS_ID
      , Get_Address_ID(h.invoice_to_org_id,'BILL_TO') -- INVOICE_ADDRESS_ID
      , Get_Location(h.ship_to_org_id,'SHIP_TO') -- SHIP_TO_LOCATION
      , h.XML_MESSAGE_ID
      , h.SOLD_TO_SITE_USE_ID
      , Get_Address1(h.sold_to_site_use_id, 'SOLD_TO_SITE')
      , Get_Address2(h.sold_to_site_use_id, 'SOLD_TO_SITE')
      , Get_Address3(h.sold_to_site_use_id, 'SOLD_TO_SITE')
      , Get_Address4(h.sold_to_site_use_id, 'SOLD_TO_SITE')
      , Get_City(h.sold_to_site_use_id, 'SOLD_TO_SITE')
      , Get_Zip(h.sold_to_site_use_id, 'SOLD_TO_SITE')
      , Get_Country(h.sold_to_site_use_id, 'SOLD_TO_SITE')
      , Get_State(h.sold_to_site_use_id, 'SOLD_TO_SITE')
      , Get_County(h.sold_to_site_use_id, 'SOLD_TO_SITE')
      , Get_Province(h.sold_to_site_use_id, 'SOLD_TO_SITE')
     FROM OE_ORDER_HEADERS_ALL       h
            , OE_ORDER_SOURCES      os
            , OE_AGREEMENTS_V       agr
            , OE_AR_LOOKUPS_V       fob
            , OE_LOOKUPS            ft
            , HZ_PARTIES            sold_party
            , HZ_RELATIONSHIPS      sold_rel
            , HZ_CUST_ACCOUNT_ROLES sold_role
            , HZ_CUST_ACCOUNTS      sold_acct
            , HZ_PARTIES            ship_party
            , HZ_RELATIONSHIPS      ship_rel
            , HZ_CUST_ACCOUNT_ROLES ship_role
            , HZ_CUST_ACCOUNTS      ship_acct
            , HZ_PARTIES            inv_party
            , HZ_RELATIONSHIPS      inv_rel
            , HZ_CUST_ACCOUNT_ROLES inv_role
            , HZ_CUST_ACCOUNTS      inv_acct
            , RA_SALESREPS          salesrep
            , OE_TRANSACTION_TYPES_TL ot
            , QP_LIST_HEADERS_TL    pl
            , RA_TERMS_TL           term
            , RA_RULES              accrule
            , RA_RULES              invrule
            , OE_AR_LOOKUPS_V       tax_exempt_reason
            , OE_LOOKUPS            tax_point
            , OE_GL_DAILY_CONVERSION_TYPES_V conv_type
        WHERE header_id = p_header_id
          AND os.order_source_id(+) = h.order_source_id
          AND agr.agreement_id(+) = h.agreement_id
          AND fob.lookup_type(+) = 'FOB'
          AND fob.lookup_code(+) = h.fob_point_code
          AND ft.lookup_type(+) = 'FREIGHT_TERMS'
          AND ft.lookup_code(+) = h.freight_terms_code
          AND salesrep.salesrep_id(+) = h.salesrep_id
          AND ot.transaction_type_id = h.order_type_id
          AND ot.language = userenv('LANG')
          AND pl.list_header_id(+) = h.price_list_id
          AND pl.language(+) = userenv('LANG')
          AND term.term_id(+) = h.payment_term_id
          AND term.language(+) = userenv('LANG')
          AND sold_role.cust_account_role_id(+) = h.sold_to_contact_id
          AND sold_role.role_type(+) = 'CONTACT'
          AND sold_role.cust_account_id(+) = h.sold_to_org_id
          AND sold_rel.party_id(+) = sold_role.party_id
          AND sold_party.party_id(+) = sold_rel.subject_id
          AND sold_acct.cust_account_id(+) = sold_role.cust_account_id
          AND nvl(sold_acct.party_id,1) = nvl(sold_rel.object_id,1)
          AND ship_role.cust_account_role_id(+) = h.ship_to_contact_id
          AND ship_role.role_type(+) = 'CONTACT'
          AND ship_role.cust_account_id(+) = h.ship_to_org_id
          AND ship_rel.party_id(+) = ship_role.party_id
          AND ship_party.party_id(+) = ship_rel.subject_id
          AND ship_acct.cust_account_id(+) = ship_role.cust_account_id
          AND nvl(ship_acct.party_id,1) = nvl(ship_rel.object_id,1)
          AND inv_role.cust_account_role_id(+) = h.invoice_to_contact_id
          AND inv_role.role_type(+) = 'CONTACT'
          AND inv_role.cust_account_id(+) = h.invoice_to_org_id
          AND inv_rel.party_id(+) = inv_role.party_id
          AND inv_party.party_id(+) = inv_rel.subject_id
          AND inv_acct.cust_account_id(+) = inv_role.cust_account_id
          AND nvl(inv_acct.party_id,1) = nvl(inv_rel.object_id,1)
          AND accrule.rule_id(+) = h.accounting_rule_id
          AND invrule.rule_id(+) = h.invoicing_rule_id
          AND tax_exempt_reason.lookup_type(+) = 'TAX_EXEMPT_REASON'
          AND tax_exempt_reason.lookup_code(+) = h.tax_exempt_reason_code
          AND tax_point.lookup_type(+) = 'TAX_POINT'
          AND tax_point.lookup_code(+) = h.tax_point_code
          AND conv_type.conversion_type(+) = h.conversion_type_code
          ;

END Insert_Header_Acks;

PROCEDURE Insert_Line_Acks
        (p_header_id            IN NUMBER
        )
IS
BEGIN

      INSERT INTO OE_LINE_ACKS
         (
          ACCOUNTING_RULE
         ,ACCOUNTING_RULE_ID
         ,ACCOUNTING_RULE_DURATION
         ,ACKNOWLEDGMENT_FLAG
         ,ACTUAL_ARRIVAL_DATE
         ,ACTUAL_SHIPMENT_DATE
         ,AGREEMENT
         ,AGREEMENT_ID
         ,ARRIVAL_SET_ID
--       ,ARRIVAL_SET_NAME
         ,ATO_LINE_ID
         ,ATTRIBUTE1
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,ATTRIBUTE16    --For bug 2184255
         ,ATTRIBUTE17
         ,ATTRIBUTE18
         ,ATTRIBUTE19
         ,ATTRIBUTE2
         ,ATTRIBUTE20
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,AUTHORIZED_TO_SHIP_FLAG
         ,BUYER_SELLER_FLAG
         ,BOOKED_FLAG
--       ,CALCULATE_PRICE_FLAG
         ,CANCELLED_FLAG
         ,CANCELLED_QUANTITY
         ,CHANGE_DATE
         ,CHANGE_SEQUENCE
--       ,CLOSED_FLAG
         ,COMPONENT_CODE
         ,COMPONENT_NUMBER
         ,COMPONENT_SEQUENCE_ID
         ,CONFIG_DISPLAY_SEQUENCE
--       ,CONFIG_LINE_REF
         ,CONFIGURATION_ID
         ,TOP_MODEL_LINE_ID
         ,CONTEXT
         ,CREATED_BY
         ,CREATION_DATE
         ,CUST_MODEL_SERIAL_NUMBER
         ,CUST_PO_NUMBER
         ,CUST_PRODUCTION_SEQ_NUM
         ,CUSTOMER_DOCK_CODE
         ,CUSTOMER_ITEM
         ,CUSTOMER_ITEM_ID 	-- Bug 4776870
--       ,CUSTOMER_ITEM_REVISION     11/03
         , CUSTOMER_JOB
         ,CUSTOMER_PRODUCTION_LINE
         ,CUSTOMER_TRX_LINE_ID
--       ,DELIVER_TO_CONTACT
         ,DELIVER_TO_CONTACT_ID
         ,DELIVER_TO_ORG
         ,DELIVER_TO_ORG_ID
         ,DELIVERY_LEAD_TIME
         ,DEMAND_BUCKET_TYPE
         ,DEMAND_BUCKET_TYPE_CODE
--       ,DEMAND_CLASS
         ,DEMAND_CLASS_CODE
--       ,DEMAND_STREAM
         ,DEP_PLAN_REQUIRED_FLAG
--       ,DPW_ASSIGNED_FLAG
         ,EARLIEST_ACCEPTABLE_DATE
         ,EXPLOSION_DATE
         ,FIRST_ACK_CODE
         ,FIRST_ACK_DATE
         ,FOB_POINT
         ,FOB_POINT_CODE
         ,FREIGHT_CARRIER_CODE
         ,FREIGHT_TERMS
         ,FREIGHT_TERMS_CODE
         ,FULFILLED_QUANTITY
--       ,FULFILLMENT_SET_ID
--       ,FULFILLMENT_SET_NAME
         ,GLOBAL_ATTRIBUTE_CATEGORY
         ,GLOBAL_ATTRIBUTE1
         ,GLOBAL_ATTRIBUTE10
         ,GLOBAL_ATTRIBUTE11
         ,GLOBAL_ATTRIBUTE12
         ,GLOBAL_ATTRIBUTE13
         ,GLOBAL_ATTRIBUTE14
         ,GLOBAL_ATTRIBUTE15
         ,GLOBAL_ATTRIBUTE16
         ,GLOBAL_ATTRIBUTE17
         ,GLOBAL_ATTRIBUTE18
         ,GLOBAL_ATTRIBUTE19
         ,GLOBAL_ATTRIBUTE2
         ,GLOBAL_ATTRIBUTE20
         ,GLOBAL_ATTRIBUTE3
         ,GLOBAL_ATTRIBUTE4
         ,GLOBAL_ATTRIBUTE5
         ,GLOBAL_ATTRIBUTE6
         ,GLOBAL_ATTRIBUTE7
         ,GLOBAL_ATTRIBUTE8
         ,GLOBAL_ATTRIBUTE9
         ,HEADER_ID
         ,INDUSTRY_ATTRIBUTE1
         ,INDUSTRY_ATTRIBUTE10
         ,INDUSTRY_ATTRIBUTE11
         ,INDUSTRY_ATTRIBUTE12
         ,INDUSTRY_ATTRIBUTE13
         ,INDUSTRY_ATTRIBUTE14
         ,INDUSTRY_ATTRIBUTE15
         ,INDUSTRY_ATTRIBUTE16
         ,INDUSTRY_ATTRIBUTE17
         ,INDUSTRY_ATTRIBUTE18
         ,INDUSTRY_ATTRIBUTE19
         ,INDUSTRY_ATTRIBUTE2
         ,INDUSTRY_ATTRIBUTE20
         ,INDUSTRY_ATTRIBUTE21
         ,INDUSTRY_ATTRIBUTE22
         ,INDUSTRY_ATTRIBUTE23
         ,INDUSTRY_ATTRIBUTE24
         ,INDUSTRY_ATTRIBUTE25
         ,INDUSTRY_ATTRIBUTE26
         ,INDUSTRY_ATTRIBUTE27
         ,INDUSTRY_ATTRIBUTE28
         ,INDUSTRY_ATTRIBUTE29
         ,INDUSTRY_ATTRIBUTE3
         ,INDUSTRY_ATTRIBUTE30
         ,INDUSTRY_ATTRIBUTE4
         ,INDUSTRY_ATTRIBUTE5
         ,INDUSTRY_ATTRIBUTE6
         ,INDUSTRY_ATTRIBUTE7
         ,INDUSTRY_ATTRIBUTE8
         ,INDUSTRY_ATTRIBUTE9
         ,INDUSTRY_CONTEXT
         ,TP_CONTEXT
         ,TP_ATTRIBUTE1
         ,TP_ATTRIBUTE2
         ,TP_ATTRIBUTE3
         ,TP_ATTRIBUTE4
         ,TP_ATTRIBUTE5
         ,TP_ATTRIBUTE6
         ,TP_ATTRIBUTE7
         ,TP_ATTRIBUTE8
         ,TP_ATTRIBUTE9
         ,TP_ATTRIBUTE10
         ,TP_ATTRIBUTE11
         ,TP_ATTRIBUTE12
         ,TP_ATTRIBUTE13
         ,TP_ATTRIBUTE14
         ,TP_ATTRIBUTE15
         ,INTMED_SHIP_TO_CONTACT_ID
         ,INTMED_SHIP_TO_ORG_ID
         ,INVENTORY_ITEM
         ,INVENTORY_ITEM_ID
--       ,INVOICE_COMPLETE_FLAG    11/03
--       ,INVOICE_SET_ID
--       ,INVOICE_SET_NAME
--       ,INVOICE_NUMBER
         ,INVOICE_TO_CONTACT
         ,INVOICE_TO_CONTACT_ID
         ,INVOICE_TO_ORG
         ,INVOICE_TO_ORG_ID
--       ,INVOICE_TOLERANCE_ABOVE
--       ,INVOICE_TOLERANCE_BELOW
         ,INVOICING_RULE
         ,INVOICING_RULE_ID
         ,ITEM_INPUT
         ,ITEM_REVISION
         ,ITEM_TYPE_CODE
  ,LAST_ACK_CODE
  ,LAST_ACK_DATE
         ,LAST_UPDATE_DATE
         ,LAST_UPDATE_LOGIN
         ,LAST_UPDATED_BY
         ,LATEST_ACCEPTABLE_DATE
         ,LINE_CATEGORY_CODE
         ,LINE_ID
         ,LINE_NUMBER
--       ,LINE_PO_CONTEXT
         ,LINE_TYPE
         ,LINE_TYPE_ID
         ,LINK_TO_LINE_ID
--       ,LINK_TO_LINE_REF
--       ,LOT
         ,MODEL_GROUP_NUMBER
         ,OPEN_FLAG
--       ,OPERATION_CODE
         ,OPTION_FLAG
         ,OPTION_NUMBER
         ,ORDER_QUANTITY_UOM
         ,ORDER_SOURCE_ID
         ,ORDERED_QUANTITY
         ,ORG_ID
         ,ORIG_SYS_DOCUMENT_REF
         ,ORIG_SYS_LINE_REF
         ,ORIG_SYS_SHIPMENT_REF
         ,OVER_SHIP_REASON_CODE
         ,OVER_SHIP_RESOLVED_FLAG
         ,PAYMENT_TERM
         ,PAYMENT_TERM_ID
         ,PRICE_LIST
         ,PRICE_LIST_ID
         ,PRICING_ATTRIBUTE1
         ,PRICING_ATTRIBUTE10
         ,PRICING_ATTRIBUTE2
         ,PRICING_ATTRIBUTE3
         ,PRICING_ATTRIBUTE4
         ,PRICING_ATTRIBUTE5
         ,PRICING_ATTRIBUTE6
         ,PRICING_ATTRIBUTE7
         ,PRICING_ATTRIBUTE8
         ,PRICING_ATTRIBUTE9
         ,PRICING_CONTEXT
         ,PRICING_DATE
         ,PRICING_QUANTITY
         ,PRICING_QUANTITY_UOM
--       ,PROGRAM
--       ,PROGRAM_APPLICATION
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,PROJECT
         ,PROJECT_ID
         ,PROMISE_DATE
--       ,REFERENCE_HEADER
         ,REFERENCE_HEADER_ID
--       ,REFERENCE_LINE
         ,REFERENCE_LINE_ID
         ,REFERENCE_TYPE
--       ,RELATED_PO_NUMBER
         ,REQUEST_DATE
         ,REQUEST_ID
--         ,RESERVED_QUANTITY
         ,RETURN_ATTRIBUTE1
         ,RETURN_ATTRIBUTE10
         ,RETURN_ATTRIBUTE11
         ,RETURN_ATTRIBUTE12
         ,RETURN_ATTRIBUTE13
         ,RETURN_ATTRIBUTE14
         ,RETURN_ATTRIBUTE15
         ,RETURN_ATTRIBUTE2
         ,RETURN_ATTRIBUTE3
         ,RETURN_ATTRIBUTE4
         ,RETURN_ATTRIBUTE5
         ,RETURN_ATTRIBUTE6
         ,RETURN_ATTRIBUTE7
         ,RETURN_ATTRIBUTE8
         ,RETURN_ATTRIBUTE9
         ,RETURN_CONTEXT
         ,RETURN_REASON_CODE
         ,RLA_SCHEDULE_TYPE_CODE
         ,SALESREP_ID
         ,SALESREP
         ,SCHEDULE_ARRIVAL_DATE
         ,SCHEDULE_SHIP_DATE
--       ,SCHEDULE_ITEM_DETAIL
         ,SCHEDULE_STATUS_CODE
         ,SHIP_FROM_ORG
         ,SHIP_FROM_ORG_ID
         ,SHIP_MODEL_COMPLETE_FLAG
         ,SHIP_SET_ID
--       ,SHIP_SET_NAME
         ,SHIP_TO_ADDRESS1
         ,SHIP_TO_ADDRESS2
         ,SHIP_TO_ADDRESS3
         ,SHIP_TO_ADDRESS4
         ,SHIP_TO_CITY
         ,SHIP_TO_CONTACT
--       ,SHIP_TO_CONTACT_AREA_CODE1
--       ,SHIP_TO_CONTACT_AREA_CODE2
--       ,SHIP_TO_CONTACT_AREA_CODE3
         ,SHIP_TO_CONTACT_FIRST_NAME
         ,SHIP_TO_CONTACT_ID
--       ,SHIP_TO_CONTACT_JOB_TITLE
         ,SHIP_TO_CONTACT_LAST_NAME
         ,SHIP_TO_COUNTRY
         ,SHIP_TO_COUNTY
         ,SHIP_TO_ORG
         ,SHIP_TO_ORG_ID
         ,SHIP_TO_POSTAL_CODE
         ,SHIP_TO_STATE
         ,SHIP_TOLERANCE_ABOVE
         ,SHIP_TOLERANCE_BELOW
         ,SHIPMENT_NUMBER
         ,SHIPMENT_PRIORITY
         ,SHIPMENT_PRIORITY_CODE
         ,SHIPPED_QUANTITY
--       ,SHIPPING_METHOD
         ,SHIPPING_METHOD_CODE
         ,SHIPPING_QUANTITY
         ,SHIPPING_QUANTITY_UOM
--       ,SOLD_FROM_ORG
--       ,SOLD_FROM_ORG_ID
         ,SOLD_TO_ORG
         ,SOLD_TO_ORG_ID
         ,SORT_ORDER
         ,SOURCE_DOCUMENT_ID
         ,SOURCE_DOCUMENT_LINE_ID
         ,SOURCE_DOCUMENT_TYPE_ID
         ,SOURCE_TYPE_CODE
         ,SPLIT_FROM_LINE_ID
--       ,SUBINVENTORY
--       ,SUBMISSION_DATETIME
         ,TASK
         ,TASK_ID
--       ,TAX
         ,TAX_CODE
         ,TAX_DATE
         ,TAX_EXEMPT_FLAG
         ,TAX_EXEMPT_NUMBER
         ,TAX_EXEMPT_REASON
         ,TAX_EXEMPT_REASON_CODE
         ,TAX_POINT
         ,TAX_POINT_CODE
         ,TAX_RATE
         ,TAX_VALUE
         ,UNIT_LIST_PRICE
         ,UNIT_SELLING_PRICE
         ,VEH_CUS_ITEM_CUM_KEY_ID
         ,VISIBLE_DEMAND_FLAG
         ,split_from_line_ref
         ,SHIP_TO_EDI_LOCATION_CODE
         ,Service_Txn_Reason_Code
         ,Service_Txn_Comments
         ,Service_Duration
         ,Service_Start_Date
         ,Service_End_Date
         ,Service_Coterminate_Flag
         ,Service_Number
         ,Service_Period
         ,Service_Reference_Type_Code
         ,Service_Reference_Line_Id
         ,Service_Reference_System_Id
         ,Credit_Invoice_Line_Id
         ,Ship_to_Province
         ,Invoice_Province
         ,Bill_to_Edi_Location_Code
         ,Invoice_City
         ,ship_from_edi_location_code
         ,SHIP_FROM_ADDRESS_1
         ,SHIP_FROM_ADDRESS_2
         ,SHIP_FROM_ADDRESS_3
         ,SHIP_FROM_CITY
         ,SHIP_FROM_POSTAL_CODE
         ,SHIP_FROM_COUNTRY
         ,SHIP_FROM_REGION1
         ,SHIP_FROM_REGION2
         ,SHIP_FROM_REGION3
         ,SHIP_FROM_ADDRESS_ID
         ,SHIP_TO_ADDRESS_ID
         ,SHIP_TO_ADDRESS_CODE
         ,service_reference_line
         ,service_reference_order
         ,service_reference_system
--         ,order_source
         ,customer_line_number
         ,user_item_description
         )
         SELECT /*+ PUSH_PRED(salesrep) */
          accrule.NAME         -- ACCOUNTING_RULE
         , L.ACCOUNTING_RULE_ID
         , L.ACCOUNTING_RULE_DURATION
         , ''  	 -- ACKNOWLEDGMENT_FLAG
         , L.ACTUAL_ARRIVAL_DATE
         , L.ACTUAL_SHIPMENT_DATE
         , agr.NAME            -- AGREEMENT
         , L.AGREEMENT_ID
         , L.ARRIVAL_SET_ID
--       , L.ARRIVAL_SET_NAME
         , L.ATO_LINE_ID
         , L.ATTRIBUTE1
         , L.ATTRIBUTE10
         , L.ATTRIBUTE11
         , L.ATTRIBUTE12
         , L.ATTRIBUTE13
         , L.ATTRIBUTE14
         , L.ATTRIBUTE15
         , L.ATTRIBUTE16    --For bug 2184255
         , L.ATTRIBUTE17
         , L.ATTRIBUTE18
         , L.ATTRIBUTE19
         , L.ATTRIBUTE2
         , L.ATTRIBUTE20
         , L.ATTRIBUTE3
         , L.ATTRIBUTE4
         , L.ATTRIBUTE5
         , L.ATTRIBUTE6
         , L.ATTRIBUTE7
         , L.ATTRIBUTE8
         , L.ATTRIBUTE9
         , L.AUTHORIZED_TO_SHIP_FLAG
         , 'B'                    -- p_buyer_seller_flag
         , L.BOOKED_FLAG
--       , L.CALCULATE_PRICE_FLAG
         , L.CANCELLED_FLAG
         , L.CANCELLED_QUANTITY
         , '' -- CHANGE_DATE
         , L.CHANGE_SEQUENCE
--       , L.CLOSED_FLAG
         , L.COMPONENT_CODE
         , L.COMPONENT_NUMBER
         , L.COMPONENT_SEQUENCE_ID
         , L.CONFIG_DISPLAY_SEQUENCE
--       , L.CONFIG_LINE_REF
         , L.CONFIGURATION_ID
         , L.TOP_MODEL_LINE_ID
         , L.CONTEXT
         , L.CREATED_BY
         , L.CREATION_DATE
         , L.CUST_MODEL_SERIAL_NUMBER
         , L.CUST_PO_NUMBER
         , L.CUST_PRODUCTION_SEQ_NUM
         , L.CUSTOMER_DOCK_CODE
         , L.ORDERED_ITEM
         , L.ORDERED_ITEM_ID    -- Bug 4776870
--       , L.CUSTOMER_ITEM_REVISION
         , L.CUSTOMER_JOB
         , L.CUSTOMER_PRODUCTION_LINE
         , L.CUSTOMER_TRX_LINE_ID
--       , L.DELIVER_TO_CONTACT
         , L.DELIVER_TO_CONTACT_ID
         , NULL                           -- DELIVER_TO_ORG
         , L.DELIVER_TO_ORG_ID
         , L.DELIVERY_LEAD_TIME
         , NULL                           -- DEMAND_BUCKET_TYPE
         , L.DEMAND_BUCKET_TYPE_CODE
--       , L.DEMAND_CLASS
         , L.DEMAND_CLASS_CODE
--       , L.DEMAND_STREAM
         , L.DEP_PLAN_REQUIRED_FLAG
         , L.EARLIEST_ACCEPTABLE_DATE
         , L.EXPLOSION_DATE
--       , decode(L.order_source_id,20,'0','IA')  -- FIRST_ACK_CODE
         , decode(L.order_source_id,20,'0',
		decode ( L.customer_item_net_price, NULL, 'IA',
			 FND_API.G_MISS_NUM, 'IA',
			 L.unit_selling_price, 'IA',
			 'IP')	)  -- bug 4767509
         , L.FIRST_ACK_DATE
         , substr(ft.MEANING,1,30)        -- FOB_POINT
         , L.FOB_POINT_CODE
         , L.FREIGHT_CARRIER_CODE
         , ft.MEANING                     -- FREIGHT_TERMS
         , L.FREIGHT_TERMS_CODE
         , L.FULFILLED_QUANTITY
--       , L.FULFILLMENT_SET_ID
--       , L.FULFILLMENT_SET_NAME
         , L.GLOBAL_ATTRIBUTE_CATEGORY
         , L.GLOBAL_ATTRIBUTE1
         , L.GLOBAL_ATTRIBUTE10
         , L.GLOBAL_ATTRIBUTE11
         , L.GLOBAL_ATTRIBUTE12
         , L.GLOBAL_ATTRIBUTE13
         , L.GLOBAL_ATTRIBUTE14
         , L.GLOBAL_ATTRIBUTE15
         , L.GLOBAL_ATTRIBUTE16
         , L.GLOBAL_ATTRIBUTE17
         , L.GLOBAL_ATTRIBUTE18
         , L.GLOBAL_ATTRIBUTE19
         , L.GLOBAL_ATTRIBUTE2
         , L.GLOBAL_ATTRIBUTE20
         , L.GLOBAL_ATTRIBUTE3
         , L.GLOBAL_ATTRIBUTE4
         , L.GLOBAL_ATTRIBUTE5
         , L.GLOBAL_ATTRIBUTE6
         , L.GLOBAL_ATTRIBUTE7
         , L.GLOBAL_ATTRIBUTE8
         , L.GLOBAL_ATTRIBUTE9
         , L.HEADER_ID
         , L.INDUSTRY_ATTRIBUTE1
         , L.INDUSTRY_ATTRIBUTE10
         , L.INDUSTRY_ATTRIBUTE11
         , L.INDUSTRY_ATTRIBUTE12
         , L.INDUSTRY_ATTRIBUTE13
         , L.INDUSTRY_ATTRIBUTE14
         , L.INDUSTRY_ATTRIBUTE15
         , L.INDUSTRY_ATTRIBUTE16
         , L.INDUSTRY_ATTRIBUTE17
         , L.INDUSTRY_ATTRIBUTE18
         , L.INDUSTRY_ATTRIBUTE19
         , L.INDUSTRY_ATTRIBUTE2
         , L.INDUSTRY_ATTRIBUTE20
         , L.INDUSTRY_ATTRIBUTE21
         , L.INDUSTRY_ATTRIBUTE22
         , L.INDUSTRY_ATTRIBUTE23
         , L.INDUSTRY_ATTRIBUTE24
         , L.INDUSTRY_ATTRIBUTE25
         , L.INDUSTRY_ATTRIBUTE26
         , L.INDUSTRY_ATTRIBUTE27
         , L.INDUSTRY_ATTRIBUTE28
         , L.INDUSTRY_ATTRIBUTE29
         , L.INDUSTRY_ATTRIBUTE3
         , L.INDUSTRY_ATTRIBUTE30
         , L.INDUSTRY_ATTRIBUTE4
         , L.INDUSTRY_ATTRIBUTE5
         , L.INDUSTRY_ATTRIBUTE6
         , L.INDUSTRY_ATTRIBUTE7
         , L.INDUSTRY_ATTRIBUTE8
         , L.INDUSTRY_ATTRIBUTE9
         , L.INDUSTRY_CONTEXT
         , L.TP_CONTEXT
         , L.TP_ATTRIBUTE1
         , L.TP_ATTRIBUTE2
         , L.TP_ATTRIBUTE3
         , L.TP_ATTRIBUTE4
         , L.TP_ATTRIBUTE5
         , L.TP_ATTRIBUTE6
         , L.TP_ATTRIBUTE7
         , L.TP_ATTRIBUTE8
         , L.TP_ATTRIBUTE9
         , L.TP_ATTRIBUTE10
         , L.TP_ATTRIBUTE11
         , L.TP_ATTRIBUTE12
         , L.TP_ATTRIBUTE13
         , L.TP_ATTRIBUTE14
         , L.TP_ATTRIBUTE15
         , L.INTMED_SHIP_TO_CONTACT_ID
         , L.INTMED_SHIP_TO_ORG_ID
         , item.CONCATENATED_SEGMENTS           -- INVENTORY_ITEM
         , L.INVENTORY_ITEM_ID
--       , L.INVOICE_COMPLETE_FLAG    11/03
--       , L.INVOICE_SET_ID
--       , L.INVOICE_SET_NAME
--       , L.INVOICE_NUMBER
         , NULL                                 -- INVOICE_TO_CONTACT
         , L.INVOICE_TO_CONTACT_ID
         , Get_Location(l.invoice_to_org_id,'BILL_TO') -- INVOICE_TO_ORG
         , L.INVOICE_TO_ORG_ID
--       , ???().INVOICE_TOLERANCE_ABOVE
--       , ???().INVOICE_TOLERANCE_BELOW
         , invrule.NAME                       -- INVOICING_RULE
         , L.INVOICING_RULE_ID
         , L.ORDERED_ITEM
         , L.ITEM_REVISION
         , L.item_identifier_type             -- ITEM_TYPE_CODE
         , L.LAST_ACK_CODE
         , L.LAST_ACK_DATE
         , L.LAST_UPDATE_DATE
         , L.LAST_UPDATE_LOGIN
         , L.LAST_UPDATED_BY
         , L.LATEST_ACCEPTABLE_DATE
         , L.LINE_CATEGORY_CODE
         , L.LINE_ID
         , L.LINE_NUMBER
--       , L.LINE_PO_CONTEXT
         , lt.NAME                            -- LINE_TYPE
         , L.LINE_TYPE_ID
         , L.LINK_TO_LINE_ID
--       , L.LINK_TO_LINE_REF
--       , ???().LOT
         , L.MODEL_GROUP_NUMBER
         , L.OPEN_FLAG
--       , L.OPERATION
         , L.OPTION_FLAG
         , L.OPTION_NUMBER
         , L.ORDER_QUANTITY_UOM
         , L.ORDER_SOURCE_ID
         , L.ORDERED_QUANTITY
         , L.ORG_ID
         , L.ORIG_SYS_DOCUMENT_REF
         , L.ORIG_SYS_LINE_REF
         , L.ORIG_SYS_SHIPMENT_REF
         , L.OVER_SHIP_REASON_CODE
         , L.OVER_SHIP_RESOLVED_FLAG
         , term.NAME                     -- PAYMENT_TERM
         , L.PAYMENT_TERM_ID
         , pl.NAME                       -- PRICE_LIST
         , L.PRICE_LIST_ID
         , L.PRICING_ATTRIBUTE1
         , L.PRICING_ATTRIBUTE10
         , L.PRICING_ATTRIBUTE2
         , L.PRICING_ATTRIBUTE3
         , L.PRICING_ATTRIBUTE4
         , L.PRICING_ATTRIBUTE5
         , L.PRICING_ATTRIBUTE6
         , L.PRICING_ATTRIBUTE7
         , L.PRICING_ATTRIBUTE8
         , L.PRICING_ATTRIBUTE9
         , L.PRICING_CONTEXT
         , L.PRICING_DATE
         , L.PRICING_QUANTITY
         , L.PRICING_QUANTITY_UOM
--       , ???().PROGRAM
--       , ???().PROGRAM_APPLICATION
         , L.PROGRAM_APPLICATION_ID
         , L.PROGRAM_ID
         , L.PROGRAM_UPDATE_DATE
         , PJM_PROJECT.ALL_PROJ_IDTONUM(l.project_id)  -- PROJECT
         , L.PROJECT_ID
         , L.PROMISE_DATE
--       , L.REFERENCE_HEADER
         , L.REFERENCE_HEADER_ID
--       , L.REFERENCE_LINE
         , L.REFERENCE_LINE_ID
         , L.REFERENCE_TYPE
         , L.REQUEST_DATE
         , L.REQUEST_ID
-- BULK Import does not reserve lines therefore not setting
-- reserved quantity on lines acknowledgments
--         , L.RESERVED_QUANTITY
         , L.RETURN_ATTRIBUTE1
         , L.RETURN_ATTRIBUTE10
         , L.RETURN_ATTRIBUTE11
         , L.RETURN_ATTRIBUTE12
         , L.RETURN_ATTRIBUTE13
         , L.RETURN_ATTRIBUTE14
         , L.RETURN_ATTRIBUTE15
         , L.RETURN_ATTRIBUTE2
         , L.RETURN_ATTRIBUTE3
         , L.RETURN_ATTRIBUTE4
         , L.RETURN_ATTRIBUTE5
         , L.RETURN_ATTRIBUTE6
         , L.RETURN_ATTRIBUTE7
         , L.RETURN_ATTRIBUTE8
         , L.RETURN_ATTRIBUTE9
         , L.RETURN_CONTEXT
         , L.RETURN_REASON_CODE
         , L.RLA_SCHEDULE_TYPE_CODE
         , L.SALESREP_ID
         , salesrep.NAME                 -- SALESREP
         , L.SCHEDULE_ARRIVAL_DATE
         , L.SCHEDULE_SHIP_DATE
--       , L.SCHEDULE_ITEM_DETAIL
         , L.SCHEDULE_STATUS_CODE
         , Get_Location(l.ship_from_org_id,'SHIP_FROM') -- SHIP_FROM_ORG
         , L.SHIP_FROM_ORG_ID
         , L.SHIP_MODEL_COMPLETE_FLAG
         , L.SHIP_SET_ID
--       , L.SHIP_SET_NAME
         , Get_Address1(l.ship_to_org_id,'SHIP_TO')    -- SHIP_TO_ADDRESS1
         , Get_Address2(l.ship_to_org_id,'SHIP_TO')    -- SHIP_TO_ADDRESS2
         , Get_Address3(l.ship_to_org_id,'SHIP_TO')    -- SHIP_TO_ADDRESS3
         , Get_Address4(l.ship_to_org_id,'SHIP_TO')    -- SHIP_TO_ADDRESS4
         , Get_City(l.ship_to_org_id,'SHIP_TO')    -- SHIP_TO_CITY
         , NULL                                    -- SHIP_TO_CONTACT
--       , L.SHIP_TO_CONTACT_AREA_CODE1
--       , L.SHIP_TO_CONTACT_AREA_CODE2
--       , L.SHIP_TO_CONTACT_AREA_CODE3
         , ship_party.PERSON_FIRST_NAME            -- SHIP_TO_CONTACT_FIRST_NAME
         , L.SHIP_TO_CONTACT_ID
--       , L.SHIP_TO_CONTACT_JOB_TITLE
         , ship_party.PERSON_LAST_NAME             -- SHIP_TO_CONTACT_LAST_NAME
         , Get_Country(l.ship_to_org_id,'SHIP_TO')   -- SHIP_TO_COUNTRY
         , Get_County(l.ship_to_org_id,'SHIP_TO')    -- SHIP_TO_COUNTY
         , Get_Location(l.ship_to_org_id,'SHIP_TO')  -- SHIP_TO_ORG
         , L.SHIP_TO_ORG_ID
         , Get_Zip(l.ship_to_org_id,'SHIP_TO')       -- SHIP_TO_zip
         , Get_State(l.ship_to_org_id,'SHIP_TO')     -- SHIP_TO_STATE
         , L.SHIP_TOLERANCE_ABOVE
         , L.SHIP_TOLERANCE_BELOW
         , L.SHIPMENT_NUMBER
         , sp.MEANING                                -- SHIPMENT_PRIORITY
         , L.SHIPMENT_PRIORITY_CODE
         , L.SHIPPED_QUANTITY
--       , L.SHIPPING_METHOD
         , L.SHIPPING_METHOD_CODE
         , L.SHIPPING_QUANTITY
         , L.SHIPPING_QUANTITY_UOM
--       , ???().SOLD_FROM_ORG
--       , ???().SOLD_FROM_ORG_ID
         , NULL                                      -- SOLD_TO_ORG
         , L.SOLD_TO_ORG_ID
         , L.SORT_ORDER
         , L.SOURCE_DOCUMENT_ID
         , L.SOURCE_DOCUMENT_LINE_ID
         , L.SOURCE_DOCUMENT_TYPE_ID
         , L.SOURCE_TYPE_CODE
         , L.SPLIT_FROM_LINE_ID
--       , ???.SUBINVENTORY
--       , ???.SUBMISSION_DATETIME
         , PJM_PROJECT.ALL_TASK_IDTONUM(l.task_id)  -- TASK
         , L.TASK_ID
--       , L.TAX
         , L.TAX_CODE
         , L.TAX_DATE
         , L.TAX_EXEMPT_FLAG
         , L.TAX_EXEMPT_NUMBER
         , tax_exempt_reason.MEANING                 -- TAX_EXEMPT_REASON
         , L.TAX_EXEMPT_REASON_CODE
         , tax_point.MEANING                         -- TAX_POINT
         , L.TAX_POINT_CODE
         , L.TAX_RATE
         , L.TAX_VALUE
         , L.UNIT_LIST_PRICE
         , L.UNIT_SELLING_PRICE
         , L.VEH_CUS_ITEM_CUM_KEY_ID
         , L.VISIBLE_DEMAND_FLAG
         -- BULK Import is only for creates of complete orders, splits
         -- is NOT supported!
         , NULL                            -- L.split_from_line_ref
         , Get_EDI_Location(L.ship_to_org_id,'SHIP_TO') -- SHIP_TO_EDI_LOCATION_CODE
              , L.Service_Txn_Reason_Code
              , L.Service_Txn_Comments
         , L.Service_Duration
         , L.Service_Start_Date
         , L.Service_End_Date
         , L.Service_Coterminate_Flag
         , L.Service_Number
         , L.Service_Period
         , L.Service_Reference_Type_Code
         , L.Service_Reference_Line_Id
         , L.Service_Reference_System_Id
         , L.Credit_Invoice_Line_Id
         , Get_Province(l.ship_to_org_id,'SHIP_TO')         -- SHIP_TO_Province
         , Get_Province(l.invoice_to_org_id,'BILL_TO')      -- INVOICE_TO_Province
         , Get_EDI_Location(l.invoice_to_org_id,'BILL_TO')  -- Bill_to_Edi_Location_Code
         , Get_City(l.invoice_to_org_id,'BILL_TO')          -- INVOICE_TO_City
         , Get_EDI_Location(l.ship_from_org_id,'SHIP_FROM') -- ship_from_edi_location_code
         , Get_Address1(l.ship_from_org_id,'SHIP_FROM')
         , Get_Address2(l.ship_from_org_id,'SHIP_FROM')
         , Get_Address3(l.ship_from_org_id,'SHIP_FROM')
         , Get_City(l.ship_from_org_id,'SHIP_FROM')
         , Get_Zip(l.ship_from_org_id,'SHIP_FROM')  -- POSTAL_CODE
         , Get_Country(l.ship_from_org_id,'SHIP_FROM')
         , NULL         -- SHIP_FROM_REGION1
         , NULL         -- SHIP_FROM_REGION2
         , NULL         -- SHIP_FROM_REGION3
         , Get_Address_ID(l.ship_from_org_id,'SHIP_FROM') -- SHIP_FROM_ADDRESS_ID
         , Get_Address_ID(l.ship_to_org_id,'SHIP_TO')     -- SHIP_TO_ADDRESS_ID
         , Get_Location(l.ship_to_org_id,'SHIP_TO')       -- SHIP_TO_LOCATION
         -- BULK Import does not support service lines therefore pass
         -- NULL in these service value fields!
         , NULL         -- L.Service_reference_line
         , NULL         -- L.Service_reference_order
         , NULL         -- L.Service_reference_system
--         , l_line_val_rec.order_source
         , L.customer_line_number
         , L.user_item_description
    FROM OE_ORDER_LINES     L
            , OE_ORDER_SOURCES      os
            , OE_AGREEMENTS_V       agr
            , OE_AR_LOOKUPS_V       fob
            , OE_LOOKUPS            ft
            , OE_LOOKUPS            sp
            , HZ_PARTIES            ship_party
            , HZ_RELATIONSHIPS      ship_rel
            , HZ_CUST_ACCOUNT_ROLES ship_role
            , HZ_CUST_ACCOUNTS      ship_acct
            , RA_SALESREPS          salesrep
            , OE_TRANSACTION_TYPES_TL lt
            , QP_LIST_HEADERS_TL    pl
            , RA_TERMS_TL           term
            , RA_RULES              accrule
            , RA_RULES              invrule
            , OE_AR_LOOKUPS_V       tax_exempt_reason
            , OE_LOOKUPS            tax_point
            , MTL_SYSTEM_ITEMS_VL   item
        WHERE L.header_id = p_header_id
          AND os.order_source_id(+) = l.order_source_id
          AND agr.agreement_id(+) = l.agreement_id
          AND fob.lookup_type(+) = 'FOB'
          AND fob.lookup_code(+) = l.fob_point_code
          AND ft.lookup_type(+) = 'FREIGHT_TERMS'
          AND ft.lookup_code(+) = l.freight_terms_code
          AND sp.lookup_type(+) = 'SHIPMENT_PRIORITY'
          AND sp.lookup_code(+) = l.shipment_priority_code
          AND salesrep.salesrep_id(+) = l.salesrep_id
          AND lt.transaction_type_id = l.line_type_id
          AND lt.language = userenv('LANG')
          AND pl.list_header_id(+) = l.price_list_id
          AND pl.language(+) = userenv('LANG')
          AND term.term_id(+) = l.payment_term_id
          AND term.language(+) = userenv('LANG')
          AND ship_role.cust_account_role_id(+) = L.ship_to_contact_id
          AND ship_role.role_type(+) = 'CONTACT'
          AND ship_role.cust_account_id(+) = L.ship_to_org_id
          AND ship_rel.party_id(+) = ship_role.party_id
          AND ship_party.party_id(+) = ship_rel.subject_id
          AND ship_acct.cust_account_id(+) = ship_role.cust_account_id
          AND nvl(ship_acct.party_id,1) = nvl(ship_rel.object_id,1)
          AND accrule.rule_id(+) = L.accounting_rule_id
          AND invrule.rule_id(+) = L.invoicing_rule_id
          AND tax_exempt_reason.lookup_type(+) = 'TAX_EXEMPT_REASON'
          AND tax_exempt_reason.lookup_code(+) = L.tax_exempt_reason_code
          AND tax_point.lookup_type(+) = 'TAX_POINT'
          AND tax_point.lookup_code(+) = L.tax_point_code
          AND item.inventory_item_id = L.inventory_item_id
          AND item.organization_id = OE_BULK_ORDER_PVT.G_ITEM_ORG
          ;

END Insert_Line_Acks;

PROCEDURE Process_Acknowledgments
        (p_batch_id            IN NUMBER
        ,x_return_status       OUT NOCOPY VARCHAR2)
IS
  l_header_count     NUMBER;
  l_header_id        NUMBER;
BEGIN

   IF OE_GLOBALS.G_EC_INSTALLED <> 'Y' THEN
      oe_debug_pub.add('EC not installed - No ACK required',1);
      RETURN;
   END IF;

   -- Can we somehow mark those orders during entity validation
   -- where customers are EDI enabled?
   -- maybe, use first_ack_code to identify such orders

   -- For such orders, do not process acks IF:
   -- 1. Any one line in the order exists that is NOT scheduled
   -- (schedule_ship_date IS NULL)

  l_header_count := OE_BULK_ORDER_PVT.G_HEADER_REC.HEADER_ID.COUNT;

  FOR I IN 1..l_header_count LOOP

    IF OE_BULK_ORDER_PVT.G_HEADER_REC.first_ack_code(i) = 'X'
       AND nvl(OE_BULK_ORDER_PVT.G_HEADER_REC.lock_control(i), 0) NOT IN (-99, -98, -97)
       AND OE_BULK_ORDER_PVT.G_HEADER_REC.booked_flag(i) = 'Y'
    THEN

      l_header_id := OE_BULK_ORDER_PVT.G_HEADER_REC.HEADER_ID(i);

      Insert_Header_Acks(l_header_id);

      Insert_Line_Acks(l_header_id);

      -- Check to see if there are any Rejected lines for the
      -- processed headers
      Insert_Rejected_Lines_Ack(p_batch_id,
                      OE_BULK_ORDER_PVT.G_HEADER_REC.order_source_id(i),
                      OE_BULK_ORDER_PVT.G_HEADER_REC.orig_sys_document_ref(i));

    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
        , 'Process_Acknowledgments'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Process_Acknowledgments;

PROCEDURE Insert_Rejected_Lines_Ack(p_batch_id  IN NUMBER,
                                    p_order_source_id IN NUMBER,
                                    p_orig_sys_document_ref IN VARCHAR2)
IS
BEGIN

      INSERT INTO OE_LINE_ACKS
         (
          ACCOUNTING_RULE
         ,ACCOUNTING_RULE_ID
         ,ACCOUNTING_RULE_DURATION
         ,ACKNOWLEDGMENT_FLAG
         ,ACTUAL_ARRIVAL_DATE
         ,ACTUAL_SHIPMENT_DATE
         ,AGREEMENT
         ,AGREEMENT_ID
         ,ARRIVAL_SET_ID
         ,ATO_LINE_ID
         ,ATTRIBUTE1
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,ATTRIBUTE16    --For bug 2184255
         ,ATTRIBUTE17
         ,ATTRIBUTE18
         ,ATTRIBUTE19
         ,ATTRIBUTE2
         ,ATTRIBUTE20
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,AUTHORIZED_TO_SHIP_FLAG
         ,BUYER_SELLER_FLAG
         ,BOOKED_FLAG
         ,CANCELLED_FLAG
         ,CANCELLED_QUANTITY
         ,CHANGE_DATE
         ,CHANGE_SEQUENCE
         ,COMPONENT_CODE
         ,COMPONENT_NUMBER
         ,COMPONENT_SEQUENCE_ID
         ,CONFIG_DISPLAY_SEQUENCE
         ,CONFIGURATION_ID
         ,TOP_MODEL_LINE_ID
         ,CONTEXT
         ,CREATED_BY
         ,CREATION_DATE
         ,CUST_MODEL_SERIAL_NUMBER
         ,CUST_PO_NUMBER
         ,CUST_PRODUCTION_SEQ_NUM
         ,CUSTOMER_DOCK_CODE
         ,CUSTOMER_ITEM
         , CUSTOMER_JOB
         ,CUSTOMER_PRODUCTION_LINE
         ,CUSTOMER_TRX_LINE_ID
         ,DELIVER_TO_CONTACT_ID
         ,DELIVER_TO_ORG
         ,DELIVER_TO_ORG_ID
         ,DELIVERY_LEAD_TIME
         ,DEMAND_BUCKET_TYPE
         ,DEMAND_BUCKET_TYPE_CODE
         ,DEMAND_CLASS_CODE
         ,DEP_PLAN_REQUIRED_FLAG
         ,EARLIEST_ACCEPTABLE_DATE
         ,EXPLOSION_DATE
	 ,FIRST_ACK_CODE
	 ,FIRST_ACK_DATE
         ,FOB_POINT
         ,FOB_POINT_CODE
         ,FREIGHT_CARRIER_CODE
         ,FREIGHT_TERMS
         ,FREIGHT_TERMS_CODE
         ,FULFILLED_QUANTITY
         ,GLOBAL_ATTRIBUTE_CATEGORY
         ,GLOBAL_ATTRIBUTE1
         ,GLOBAL_ATTRIBUTE10
         ,GLOBAL_ATTRIBUTE11
         ,GLOBAL_ATTRIBUTE12
         ,GLOBAL_ATTRIBUTE13
         ,GLOBAL_ATTRIBUTE14
         ,GLOBAL_ATTRIBUTE15
         ,GLOBAL_ATTRIBUTE16
         ,GLOBAL_ATTRIBUTE17
         ,GLOBAL_ATTRIBUTE18
         ,GLOBAL_ATTRIBUTE19
         ,GLOBAL_ATTRIBUTE2
         ,GLOBAL_ATTRIBUTE20
         ,GLOBAL_ATTRIBUTE3
         ,GLOBAL_ATTRIBUTE4
         ,GLOBAL_ATTRIBUTE5
         ,GLOBAL_ATTRIBUTE6
         ,GLOBAL_ATTRIBUTE7
         ,GLOBAL_ATTRIBUTE8
         ,GLOBAL_ATTRIBUTE9
         ,HEADER_ID
         ,INDUSTRY_ATTRIBUTE1
         ,INDUSTRY_ATTRIBUTE10
         ,INDUSTRY_ATTRIBUTE11
         ,INDUSTRY_ATTRIBUTE12
         ,INDUSTRY_ATTRIBUTE13
         ,INDUSTRY_ATTRIBUTE14
         ,INDUSTRY_ATTRIBUTE15
         ,INDUSTRY_ATTRIBUTE16
         ,INDUSTRY_ATTRIBUTE17
         ,INDUSTRY_ATTRIBUTE18
         ,INDUSTRY_ATTRIBUTE19
         ,INDUSTRY_ATTRIBUTE2
         ,INDUSTRY_ATTRIBUTE20
         ,INDUSTRY_ATTRIBUTE21
         ,INDUSTRY_ATTRIBUTE22
         ,INDUSTRY_ATTRIBUTE23
         ,INDUSTRY_ATTRIBUTE24
         ,INDUSTRY_ATTRIBUTE25
         ,INDUSTRY_ATTRIBUTE26
         ,INDUSTRY_ATTRIBUTE27
         ,INDUSTRY_ATTRIBUTE28
         ,INDUSTRY_ATTRIBUTE29
         ,INDUSTRY_ATTRIBUTE3
         ,INDUSTRY_ATTRIBUTE30
         ,INDUSTRY_ATTRIBUTE4
         ,INDUSTRY_ATTRIBUTE5
         ,INDUSTRY_ATTRIBUTE6
         ,INDUSTRY_ATTRIBUTE7
         ,INDUSTRY_ATTRIBUTE8
         ,INDUSTRY_ATTRIBUTE9
         ,INDUSTRY_CONTEXT
         ,TP_CONTEXT
         ,TP_ATTRIBUTE1
         ,TP_ATTRIBUTE2
         ,TP_ATTRIBUTE3
         ,TP_ATTRIBUTE4
         ,TP_ATTRIBUTE5
         ,TP_ATTRIBUTE6
         ,TP_ATTRIBUTE7
         ,TP_ATTRIBUTE8
         ,TP_ATTRIBUTE9
         ,TP_ATTRIBUTE10
         ,TP_ATTRIBUTE11
         ,TP_ATTRIBUTE12
         ,TP_ATTRIBUTE13
         ,TP_ATTRIBUTE14
         ,TP_ATTRIBUTE15
         ,INTMED_SHIP_TO_CONTACT_ID
         ,INTMED_SHIP_TO_ORG_ID
         ,INVENTORY_ITEM
         ,INVENTORY_ITEM_ID
         ,INVOICE_TO_CONTACT
         ,INVOICE_TO_CONTACT_ID
         ,INVOICE_TO_ORG
         ,INVOICE_TO_ORG_ID
         ,INVOICING_RULE
         ,INVOICING_RULE_ID
         ,ITEM_INPUT
         ,ITEM_REVISION
         ,ITEM_TYPE_CODE
	 ,LAST_ACK_CODE
	 ,LAST_ACK_DATE
         ,LAST_UPDATE_DATE
         ,LAST_UPDATE_LOGIN
         ,LAST_UPDATED_BY
         ,LATEST_ACCEPTABLE_DATE
         ,LINE_CATEGORY_CODE
         ,LINE_ID
         ,LINE_NUMBER
         ,LINE_TYPE
         ,LINE_TYPE_ID
         ,LINK_TO_LINE_ID
         ,MODEL_GROUP_NUMBER
         ,OPEN_FLAG
         ,OPERATION_CODE
         ,OPTION_FLAG
         ,OPTION_NUMBER
         ,ORDER_QUANTITY_UOM
         ,ORDER_SOURCE_ID
         ,ORDERED_QUANTITY
         ,ORG_ID
         ,ORIG_SYS_DOCUMENT_REF
         ,ORIG_SYS_LINE_REF
         ,ORIG_SYS_SHIPMENT_REF
         ,OVER_SHIP_REASON_CODE
         ,OVER_SHIP_RESOLVED_FLAG
         ,PAYMENT_TERM
         ,PAYMENT_TERM_ID
         ,PRICE_LIST
         ,PRICE_LIST_ID
         ,PRICING_ATTRIBUTE1
         ,PRICING_ATTRIBUTE10
         ,PRICING_ATTRIBUTE2
         ,PRICING_ATTRIBUTE3
         ,PRICING_ATTRIBUTE4
         ,PRICING_ATTRIBUTE5
         ,PRICING_ATTRIBUTE6
         ,PRICING_ATTRIBUTE7
         ,PRICING_ATTRIBUTE8
         ,PRICING_ATTRIBUTE9
         ,PRICING_CONTEXT
         ,PRICING_DATE
         ,PRICING_QUANTITY
         ,PRICING_QUANTITY_UOM
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,PROJECT
         ,PROJECT_ID
         ,PROMISE_DATE
         ,REFERENCE_HEADER_ID
         ,REFERENCE_LINE_ID
         ,REFERENCE_TYPE
         ,REQUEST_DATE
         ,REQUEST_ID
         ,RESERVED_QUANTITY
         ,RETURN_ATTRIBUTE1
         ,RETURN_ATTRIBUTE10
         ,RETURN_ATTRIBUTE11
         ,RETURN_ATTRIBUTE12
         ,RETURN_ATTRIBUTE13
         ,RETURN_ATTRIBUTE14
         ,RETURN_ATTRIBUTE15
         ,RETURN_ATTRIBUTE2
         ,RETURN_ATTRIBUTE3
         ,RETURN_ATTRIBUTE4
         ,RETURN_ATTRIBUTE5
         ,RETURN_ATTRIBUTE6
         ,RETURN_ATTRIBUTE7
         ,RETURN_ATTRIBUTE8
         ,RETURN_ATTRIBUTE9
         ,RETURN_CONTEXT
         ,RETURN_REASON_CODE
         ,RLA_SCHEDULE_TYPE_CODE
         ,SALESREP_ID
         ,SALESREP
         ,SCHEDULE_ARRIVAL_DATE
         ,SCHEDULE_SHIP_DATE
         ,SCHEDULE_STATUS_CODE
         ,SHIP_FROM_ORG
         ,SHIP_FROM_ORG_ID
         ,SHIP_MODEL_COMPLETE_FLAG
         ,SHIP_SET_ID
         ,SHIP_TO_ADDRESS1
         ,SHIP_TO_ADDRESS2
         ,SHIP_TO_ADDRESS3
         ,SHIP_TO_ADDRESS4
         ,SHIP_TO_CITY
         ,SHIP_TO_CONTACT
         ,SHIP_TO_CONTACT_FIRST_NAME
         ,SHIP_TO_CONTACT_ID
         ,SHIP_TO_CONTACT_LAST_NAME
         ,SHIP_TO_COUNTRY
         ,SHIP_TO_COUNTY
         ,SHIP_TO_ORG
         ,SHIP_TO_ORG_ID
         ,SHIP_TO_POSTAL_CODE
         ,SHIP_TO_STATE
         ,SHIP_TOLERANCE_ABOVE
         ,SHIP_TOLERANCE_BELOW
         ,SHIPMENT_NUMBER
         ,SHIPMENT_PRIORITY
         ,SHIPMENT_PRIORITY_CODE
         ,SHIPPED_QUANTITY
         ,SHIPPING_METHOD_CODE
         ,SHIPPING_QUANTITY
         ,SHIPPING_QUANTITY_UOM
         ,SOLD_TO_ORG
         ,SOLD_TO_ORG_ID
         ,SORT_ORDER
         ,SOURCE_DOCUMENT_ID
         ,SOURCE_DOCUMENT_LINE_ID
         ,SOURCE_DOCUMENT_TYPE_ID
         ,SOURCE_TYPE_CODE
         ,SPLIT_FROM_LINE_ID
         ,TASK
         ,TASK_ID
         ,TAX_CODE
         ,TAX_DATE
         ,TAX_EXEMPT_FLAG
         ,TAX_EXEMPT_NUMBER
         ,TAX_EXEMPT_REASON
         ,TAX_EXEMPT_REASON_CODE
         ,TAX_POINT
         ,TAX_POINT_CODE
         ,TAX_RATE
         ,TAX_VALUE
         ,UNIT_LIST_PRICE
         ,UNIT_SELLING_PRICE
         ,VEH_CUS_ITEM_CUM_KEY_ID
         ,VISIBLE_DEMAND_FLAG
         ,split_from_line_ref
         ,SHIP_TO_EDI_LOCATION_CODE
         ,Service_Txn_Reason_Code
	 ,Service_Txn_Comments
	 ,Service_Duration
	 ,Service_Start_Date
	 ,Service_End_Date
	 ,Service_Coterminate_Flag
	 ,Service_Number
	 ,Service_Period
	 ,Service_Reference_Type_Code
	 ,Service_Reference_Line_Id
	 ,Service_Reference_System_Id
	 ,Credit_Invoice_Line_Id
	 ,Ship_to_Province
	 ,Invoice_Province
	 ,Bill_to_Edi_Location_Code
	 ,Invoice_City
         ,ship_from_edi_location_code
         ,SHIP_FROM_ADDRESS_1
         ,SHIP_FROM_ADDRESS_2
         ,SHIP_FROM_ADDRESS_3
         ,SHIP_FROM_CITY
         ,SHIP_FROM_POSTAL_CODE
         ,SHIP_FROM_COUNTRY
         ,SHIP_FROM_REGION1
         ,SHIP_FROM_REGION2
         ,SHIP_FROM_REGION3
         ,SHIP_FROM_ADDRESS_ID
         ,SHIP_TO_ADDRESS_ID
         ,SHIP_TO_ADDRESS_CODE
         ,service_reference_line
         ,service_reference_order
         ,service_reference_system
         ,customer_line_number
         ,user_item_description
         )
    SELECT  l.accounting_rule,
	 l.accounting_rule_id,
	 l.accounting_rule_duration,
         '',  -- ACKNOWLEDGMENT_FLAG
	 l.actual_arrival_date,
         NULL, -- ACTUAL_SHIPMENT_DATE
	 l.agreement,
	 l.agreement_id,
         NULL, -- ARRIVAL_SET_ID
	 l.ato_line_id,
	 l.attribute1,
	 l.attribute10,
	 l.attribute11,
	 l.attribute12,
	 l.attribute13,
	 l.attribute14,
	 l.attribute15,
	 l.attribute16,			   --For bug 2184255
	 l.attribute17,
	 l.attribute18,
	 l.attribute19,
	 l.attribute2,
	 l.attribute20,
	 l.attribute3,
	 l.attribute4,
	 l.attribute5,
	 l.attribute6,
	 l.attribute7,
	 l.attribute8,
	 l.attribute9,
         NULL, -- AUTHORIZED_TO_SHIP_FLAG
         'B', -- BUYER_SELLER_FLAG
         NULL, -- BOOKED_FLAG
	 l.cancelled_flag,
	 l.cancelled_quantity,
         '', -- CHANGE_DATE
         NULL, -- CHANGE_SEQUENCE
	 l.component_code,
         NULL, -- COMPONENT_NUMBER
	 l.component_sequence_id,
         NULL, -- CONFIG_DISPLAY_SEQUENCE
         NULL, -- CONFIGURATION_ID
         NULL, -- TOP_MODEL_LINE_ID
	 l.CONTEXT,
         NULL,  -- CREATED_BY
         NULL,  -- CREATION_DATE
	 l.cust_model_serial_number,
         NULL,  -- CUST_PO_NUMBER
         NULL,  -- CUST_PRODUCTION_SEQ_NUM
	 l.customer_dock_code,
         NULL, -- CUSTOMER_ITEM
	 l.customer_job,
	 l.customer_production_line,
         NULL,  -- CUSTOMER_TRX_LINE_ID
	 l.deliver_to_contact_id,
	 l.deliver_to_org,
	 l.deliver_to_org_id,
	 l.delivery_lead_time,
	 l.demand_bucket_type,
	 l.demand_bucket_type_code,
	 l.demand_class_code,
         NULL, -- DEP_PLAN_REQUIRED_FLAG
         l.earliest_acceptable_date,
	 l.explosion_date,
         'IR', -- FIRST_ACK_CODE
         NULL, -- FIRST_ACK_DATE
	 l.fob_point,
	 l.fob_point_code,
	 l.freight_carrier_code,
	 l.freight_terms,
	 l.freight_terms_code,
	 l.fulfilled_quantity,
	 l.global_attribute_category,
	 l.global_attribute1,
	 l.global_attribute10,
	 l.global_attribute11,
	 l.global_attribute12,
	 l.global_attribute13,
	 l.global_attribute14,
	 l.global_attribute15,
	 l.global_attribute16,
	 l.global_attribute17,
	 l.global_attribute18,
	 l.global_attribute19,
	 l.global_attribute20,
	 l.global_attribute2,
	 l.global_attribute3,
	 l.global_attribute4,
	 l.global_attribute5,
	 l.global_attribute6,
	 l.global_attribute7,
	 l.global_attribute8,
	 l.global_attribute9,
         NULL, -- header_id
	 l.industry_attribute1,
	 l.industry_attribute10,
	 l.industry_attribute11,
	 l.industry_attribute12,
	 l.industry_attribute13,
	 l.industry_attribute14,
	 l.industry_attribute15,
	 l.industry_attribute16,
	 l.industry_attribute17,
	 l.industry_attribute18,
	 l.industry_attribute19,
	 l.industry_attribute2,
	 l.industry_attribute20,
	 l.industry_attribute21,
	 l.industry_attribute22,
	 l.industry_attribute23,
	 l.industry_attribute24,
	 l.industry_attribute25,
	 l.industry_attribute26,
	 l.industry_attribute27,
	 l.industry_attribute28,
	 l.industry_attribute29,
	 l.industry_attribute3,
	 l.industry_attribute30,
	 l.industry_attribute4,
	 l.industry_attribute5,
	 l.industry_attribute6,
	 l.industry_attribute7,
	 l.industry_attribute8,
	 l.industry_attribute9,
	 l.industry_context,
         l.TP_CONTEXT,
         l.TP_ATTRIBUTE1,
         l.TP_ATTRIBUTE2,
         l.TP_ATTRIBUTE3,
         l.TP_ATTRIBUTE4,
         l.TP_ATTRIBUTE5,
         l.TP_ATTRIBUTE6,
         l.TP_ATTRIBUTE7,
         l.TP_ATTRIBUTE8,
         l.TP_ATTRIBUTE9,
         l.TP_ATTRIBUTE10,
         l.TP_ATTRIBUTE11,
         l.TP_ATTRIBUTE12,
         l.TP_ATTRIBUTE13,
         l.TP_ATTRIBUTE14,
         l.TP_ATTRIBUTE15,
         NULL, -- INTMED_SHIP_TO_CONTACT_ID
         NULL, -- INTMED_SHIP_TO_ORG_ID
	 l.inventory_item,
	 l.inventory_item_id,
	 l.invoice_to_contact,
	 l.invoice_to_contact_id,
	 l.invoice_to_org,
	 l.invoice_to_org_id,
	 l.invoicing_rule,
	 l.invoicing_rule_id,
         NULL, -- ITEM_INPUT
	 l.item_revision,
         NULL, -- ITEM_TYPE_CODE
         NULL, -- LAST_ACK_CODE
         NULL, -- LAST_ACK_DATE
         sysdate, -- LAST_UPDATE_DATE
         1, -- LAST_UPDATE_LOGIN
         1, -- LAST_UPDATED_BY
         l.latest_acceptable_date,
         NULL, -- LINE_CATEGORY_CODE
         NULL, -- LINE_ID
	 l.line_number,
	 l.line_type,
	 l.line_type_id,
         NULL, -- LINK_TO_LINE_ID
	 l.model_group_number,
         NULL, -- OPEN_FLAG
	 nvl(l.operation_code,OE_GLOBALS.G_OPR_CREATE),
	 l.option_flag,
	 l.option_number,
	 l.order_quantity_uom ,
         l.order_source_id,
	 l.ordered_quantity,
	 l.org_id,
	 l.orig_sys_document_ref,
	 l.orig_sys_line_ref,
	 l.orig_sys_shipment_ref,
         NULL, -- OVER_SHIP_REASON_CODE
         NULL, -- OVER_SHIP_RESOLVED_FLAG
	 l.payment_term,
	 l.payment_term_id,
	 l.price_list,
	 l.price_list_id,
	 l.pricing_attribute1,
	 l.pricing_attribute10,
	 l.pricing_attribute2,
	 l.pricing_attribute3,
	 l.pricing_attribute4,
	 l.pricing_attribute5,
	 l.pricing_attribute6,
	 l.pricing_attribute7,
	 l.pricing_attribute8,
	 l.pricing_attribute9,
	 l.pricing_context,
	 l.pricing_date,
	 l.pricing_quantity,
	 l.pricing_quantity_uom,
         NULL, -- PROGRAM_APPLICATION_ID
         NULL, -- PROGRAM_ID
         sysdate, -- PROGRAM_UPDATE_DATE
	 l.project,
	 l.project_id,
	 l.promise_date,
  	 l.reference_header_id,
	 l.reference_line_id,
	 l.reference_type,
         NULL, -- REQUEST_DATE
         l.request_id,
         NULL, -- RESERVED_QUANTITY
	 l.return_attribute1,
	 l.return_attribute10,
	 l.return_attribute11,
	 l.return_attribute12,
	 l.return_attribute13,
	 l.return_attribute14,
	 l.return_attribute15,
	 l.return_attribute2,
	 l.return_attribute3,
	 l.return_attribute4,
	 l.return_attribute5,
	 l.return_attribute6,
	 l.return_attribute7,
	 l.return_attribute8,
	 l.return_attribute9,
	 l.return_context,
         l.RETURN_REASON_CODE,
         NULL,  -- RLA_SCHEDULE_TYPE_CODE
         l.SALESREP_ID,
         l.SALESREP,
	 l.schedule_arrival_date,
	 l.schedule_date,
	 l.schedule_status_code,
	 l.ship_from_org,
	 l.ship_from_org_id,
	 l.ship_model_complete_flag,
         NULL, -- SHIP_SET_ID
	 l.ship_to_address1,
	 l.ship_to_address2,
	 l.ship_to_address3,
	 l.ship_to_address4,
         l.SHIP_TO_CITY,
	 l.ship_to_contact,
         l.SHIP_TO_CONTACT_FIRST_NAME,
	 l.ship_to_contact_id,
         l.SHIP_TO_CONTACT_LAST_NAME,
         l.SHIP_TO_COUNTRY,
         l.SHIP_TO_COUNTY,
	 l.sold_to_org,
	 l.ship_to_org_id ,
         l.SHIP_TO_POSTAL_CODE,
         l.SHIP_TO_STATE,
	 l.ship_tolerance_above,
	 l.ship_tolerance_below,
	 l.shipment_number,
	 l.shipment_priority,
	 l.shipment_priority_code,
	 l.shipped_quantity,
	 l.shipping_method_code,
	 l.shipping_quantity,
	 l.shipping_quantity_uom,
	 l.sold_to_org,
	 l.sold_to_org_id ,
	 l.sort_order,
         NULL, -- SOURCE_DOCUMENT_ID
         NULL, -- SOURCE_DOCUMENT_LINE_ID
         NULL, -- SOURCE_DOCUMENT_TYPE_ID
	 l.source_type_code,
         NULL, -- SPLIT_FROM_LINE_ID
	 l.task,
	 l.task_id,
	 l.tax_code,
	 l.tax_date,
	 l.tax_exempt_flag,
	 l.tax_exempt_number,
	 l.tax_exempt_reason,
	 l.tax_exempt_reason_code,
	 l.tax_point,
	 l.tax_point_code,
	 NULL, -- TAX_RATE
	 l.tax_value,
	 l.unit_list_price,
	 l.unit_selling_price,
         l.VEH_CUS_ITEM_CUM_KEY_ID,
         NULL, -- VISIBLE_DEMAND_FLAG
         l.split_from_line_ref,
         NULL, -- SHIP_TO_EDI_LOCATION_CODE
	 l.SERVICE_TXN_REASON_CODE,
	 l.SERVICE_TXN_COMMENTS,
	 l.Service_Duration,
	 l.Service_Start_Date,
	 l.Service_end_Date,
	 l.Service_Coterminate_Flag,
	 l.Service_Number,
	 l.Service_Period,
	 l.Service_Reference_Type_Code,
         NULL, -- SERVICE_REFERENCE_LINE_ID
         NULL, -- Service_Reference_System_Id
	 l.Credit_Invoice_Line_Id,
         NULL, -- Ship_to_Province
         NULL, -- Invoice_Province
         NULL, -- Bill_to_Edi_Location_Code
         NULL, -- Invoice_City
         NULL, -- ship_from_edi_location_code
         NULL, -- SHIP_FROM_ADDRESS_1
         NULL, -- SHIP_FROM_ADDRESS_2
         NULL, -- SHIP_FROM_ADDRESS_3
         NULL, -- SHIP_FROM_CITY
         NULL, -- SHIP_FROM_POSTAL_CODE
         NULL, -- SHIP_FROM_COUNTRY
         NULL, -- SHIP_FROM_REGION1
         NULL, -- SHIP_FROM_REGION2
         NULL, -- SHIP_FROM_REGION3
         NULL, -- SHIP_FROM_ADDRESS_ID
         NULL, -- SHIP_TO_ADDRESS_ID
         NULL, -- SHIP_TO_ADDRESS_CODE
         l.service_reference_line,
         l.service_reference_order,
         l.service_reference_system,
         l.customer_line_number,
         l.user_item_description
   FROM OE_LINES_IFACE_ALL l, OE_HEADERS_IFACE_ALL h
   WHERE h.batch_id   = p_batch_id
   AND h.order_source_id = p_order_source_id
   AND h.orig_sys_document_ref = p_orig_sys_document_ref
   AND h.order_source_id = l.order_source_id
   AND h.orig_sys_document_ref = l.orig_sys_document_ref
   AND nvl(l.rejected_flag, 'N') = 'Y';

EXCEPTION
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
        , 'Insert_Rejected_Lines_Ack'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Insert_Rejected_Lines_Ack;


END OE_BULK_ACK_PVT;

/
