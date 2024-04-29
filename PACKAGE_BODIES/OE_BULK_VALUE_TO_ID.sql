--------------------------------------------------------
--  DDL for Package Body OE_BULK_VALUE_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_VALUE_TO_ID" AS
/* $Header: OEBSVIDB.pls 120.10 2006/10/26 23:34:35 sarsridh ship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_Bulk_Value_To_Id';


---------------------------------------------------------------------
-- FUNCTION Get_Contact_ID
-- Used to retrieve contact ID based on contact name and
-- contact organization. E.g. for ship_to_contact_id, p_site_use_id
-- should be ship_to_org_id
---------------------------------------------------------------------

FUNCTION Get_Contact_ID
  (p_contact                  IN VARCHAR2
  ,p_site_use_id              IN NUMBER
  )
RETURN NUMBER
IS
  l_id                        NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    SELECT /* MOAC_SQL_CHANGE */ CON.CONTACT_ID
    INTO l_id
    FROM   OE_CONTACTS_V  CON
         , HZ_CUST_ACCT_SITES CAS
         , HZ_CUST_SITE_USES_ALL  SITE
    WHERE CON.NAME = p_contact
    AND   CON.CUSTOMER_ID = CAS.CUST_ACCOUNT_ID
    AND   CAS.CUST_ACCT_SITE_ID = SITE.CUST_ACCT_SITE_ID
    AND   CON.STATUS = 'A'
    AND   SITE.SITE_USE_ID = p_site_use_id;

    RETURN l_id;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Get_Contact_ID;

--{ Bug 5054618
-- Function to get End Customer Site Use id

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
      oe_debug_pub.add(' end customer site address1: in HVOP '||p_end_customer_site_address1);
      oe_debug_pub.add(' address4: in HVOP '||p_end_customer_site_address4);
      oe_debug_pub.add(' end_customer_id:in HVOP '||p_end_customer_id );
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
          oe_Debug_pub.add(' q1');
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

-- Function to get end customer id

FUNCTION GET_END_CUSTOMER_CONTACT_ID
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

END GET_END_CUSTOMER_CONTACT_ID;
-- Bug 5054618}

---------------------------------------------------------------------
-- PROCEDURE Headers
--
-- Value to ID conversions on header interface table for orders in
-- this batch.
-- It sets error_flag to 'Y' and appends ATTRIBUTE_STATUS column with a
-- number identifying each attribute that fails value to ID conversion.
---------------------------------------------------------------------

PROCEDURE Headers(p_batch_id  IN NUMBER)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

--bug 5620045
subqry_too_many_rows Exception;
PRAGMA EXCEPTION_INIT(subqry_too_many_rows, -01427);
--
--
BEGIN

-- There is one update SQL per attribute value to ID conversion.
-- NOTE that the sub-query needs to join back again to interface
-- tables so that for invalid data, it retrieves at least one row
-- with a null for the value column and populates error_flag,
-- attribute_status.

-- 1. ORDER_SOURCE : Not needed as order import already assigns request_ids
-- by order_source_id. For import, there cannot be any rows here where
-- ID column for order source is not populated but value column is.

-- 2. ORDER_TYPE

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (ORDER_TYPE_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.ORDER_TYPE_ID,
               DECODE(b.ORDER_TYPE_ID,NULL,'Y',NULL),
               DECODE(b.ORDER_TYPE_ID,NULL,
                      c.ATTRIBUTE_STATUS||'002',c.ATTRIBUTE_STATUS)
        FROM OE_ORDER_TYPES_V b, OE_HEADERS_IFACE_ALL d
        WHERE d.order_type = b.name(+)
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.ORDER_TYPE_ID IS NULL
    AND c.order_type IS NOT NULL;


-- 3. PRICE_LIST

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (price_list_id,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LIST_HEADER_ID,
               DECODE(b.LIST_HEADER_ID,NULL,'Y',NULL),
               DECODE(b.LIST_HEADER_ID,NULL,
                      c.ATTRIBUTE_STATUS||'003',c.ATTRIBUTE_STATUS)
        FROM qp_list_headers_vl b, OE_HEADERS_IFACE_ALL d
        WHERE d.price_list = b.name(+)
        AND NVL(b.list_type_code,'PRL') IN ('PRL', 'AGR')
          AND nvl(b.active_flag,'Y') = 'Y'
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.price_list_id IS NULL
    AND c.price_list IS NOT NULL;


-- 4. CONVERSION_TYPE

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (CONVERSION_TYPE_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.CONVERSION_TYPE,
               DECODE(b.CONVERSION_TYPE,NULL,'Y',NULL),
               DECODE(b.CONVERSION_TYPE,NULL,
                      c.ATTRIBUTE_STATUS||'004',c.ATTRIBUTE_STATUS)
        FROM OE_GL_DAILY_CONVERSION_TYPES_V b, OE_HEADERS_IFACE_ALL d
        WHERE d.CONVERSION_TYPE = b.USER_CONVERSION_TYPE(+)
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.CONVERSION_TYPE_CODE IS NULL
    AND c.CONVERSION_TYPE IS NOT NULL;


-- 5. SALESREP

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (SALESREP_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT /*+ PUSH_PRED(b) */ b.SALESREP_ID,
               DECODE(b.SALESREP_ID,NULL,'Y',NULL),
               DECODE(b.SALESREP_ID,NULL,
                      c.ATTRIBUTE_STATUS||'005',c.ATTRIBUTE_STATUS)
        FROM RA_SALESREPS b, OE_HEADERS_IFACE_ALL d
        WHERE d.SALESREP = b.NAME(+)
          AND sysdate between NVL(start_date_active,sysdate)
                       and NVL(end_date_active,sysdate)
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.SALESREP_ID IS NULL
    AND c.SALESREP IS NOT NULL;


-- 6. TAX_EXEMPT_REASON                        VARCHAR2(30)
    -- eBTax changes
/*  UPDATE OE_HEADERS_IFACE_ALL c
    SET (TAX_EXEMPT_REASON_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'006',c.ATTRIBUTE_STATUS)
        FROM OE_AR_LOOKUPS_V b, OE_HEADERS_IFACE_ALL d
        WHERE d.TAX_EXEMPT_REASON = b.MEANING(+)
          AND b.LOOKUP_TYPE(+) = 'TAX_REASON'
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.TAX_EXEMPT_REASON_CODE IS NULL
    AND c.TAX_EXEMPT_REASON IS NOT NULL;*/

	UPDATE OE_HEADERS_IFACE_ALL c
	   SET (TAX_EXEMPT_REASON_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
	       (SELECT b.LOOKUP_CODE,
	               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
	               DECODE(b.LOOKUP_CODE,NULL,
		              c.ATTRIBUTE_STATUS||'006',c.ATTRIBUTE_STATUS)
	          FROM FND_LOOKUPS  b, OE_HEADERS_IFACE_ALL d
	         WHERE d.TAX_EXEMPT_REASON = b.MEANING(+)
	           AND b.LOOKUP_TYPE(+) = 'ZX_EXEMPTION_REASON_CODE'
                   AND d.rowid = c.rowid)
	 WHERE c.batch_id = p_batch_id
	   AND c.TAX_EXEMPT_REASON_CODE IS NULL
	   AND c.TAX_EXEMPT_REASON IS NOT NULL;



-- 7. AGREEMENT                                VARCHAR2(50)

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (AGREEMENT_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.AGREEMENT_ID,
               DECODE(b.AGREEMENT_ID,NULL,'Y',NULL),
               DECODE(b.AGREEMENT_ID,NULL,
                      c.ATTRIBUTE_STATUS||'007',c.ATTRIBUTE_STATUS)
        FROM OE_AGREEMENTS_V b, OE_HEADERS_IFACE_ALL d
        WHERE d.AGREEMENT = b.NAME(+)
          AND sysdate between nvl(start_date_active, sysdate)
              and nvl(end_date_active, sysdate)
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.AGREEMENT_ID IS NULL
    AND c.AGREEMENT IS NOT NULL;



-- 8. INVOICING_RULE

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (INVOICING_RULE_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.RULE_ID,
               DECODE(b.RULE_ID,NULL,'Y',NULL),
               DECODE(b.RULE_ID,NULL,
                      c.ATTRIBUTE_STATUS||'008',c.ATTRIBUTE_STATUS)
        FROM OE_RA_RULES_V b, OE_HEADERS_IFACE_ALL d
        WHERE d.INVOICING_RULE = b.NAME(+)
          AND b.STATUS(+) = 'A'
          AND b.TYPE(+) = 'I'
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.INVOICING_RULE_ID IS NULL
    AND c.INVOICING_RULE IS NOT NULL;

-- 9. ACCOUNTING_RULE                          VARCHAR2(30)

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (ACCOUNTING_RULE_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.RULE_ID,
               DECODE(b.RULE_ID,NULL,'Y',NULL),
               DECODE(b.RULE_ID,NULL,
                      c.ATTRIBUTE_STATUS||'009',c.ATTRIBUTE_STATUS)
        FROM OE_RA_RULES_V b, OE_HEADERS_IFACE_ALL d
        WHERE d.ACCOUNTING_RULE = b.NAME(+)
          AND b.STATUS(+) = 'A'
      --  AND b.TYPE(+) = 'A' --we now allow variable accounting rules
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.ACCOUNTING_RULE_ID IS NULL
    AND c.ACCOUNTING_RULE IS NOT NULL;

-- 10 PAYMENT_TERM                             VARCHAR2(30)

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (PAYMENT_TERM_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.TERM_ID,
               DECODE(b.TERM_ID,NULL,'Y',NULL),
               DECODE(b.TERM_ID,NULL,
                      c.ATTRIBUTE_STATUS||'010',c.ATTRIBUTE_STATUS)
        FROM OE_RA_TERMS_V b, OE_HEADERS_IFACE_ALL d
        WHERE d.PAYMENT_TERM = b.NAME(+)
          AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                  AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.PAYMENT_TERM_ID IS NULL
    AND c.PAYMENT_TERM IS NOT NULL;


-- 11. FREIGHT_TERMS                            VARCHAR2(30)

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (FREIGHT_TERMS_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'011',c.ATTRIBUTE_STATUS)
        FROM OE_LOOKUPS b, OE_HEADERS_IFACE_ALL d
        WHERE d.FREIGHT_TERMS = b.MEANING(+)
          AND b.LOOKUP_TYPE(+) = 'FREIGHT_TERMS'
          AND b.enabled_flag(+) = 'Y'
          AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.FREIGHT_TERMS_CODE IS NULL
    AND c.FREIGHT_TERMS IS NOT NULL;


-- 12. FOB_POINT                                VARCHAR2(30)

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (FOB_POINT_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'012',c.ATTRIBUTE_STATUS)
        FROM OE_AR_LOOKUPS_V b, OE_HEADERS_IFACE_ALL d
        WHERE d.FOB_POINT = b.MEANING(+)
          AND b.LOOKUP_TYPE(+) = 'FOB'
          AND b.enabled_flag(+) = 'Y'
          AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.FOB_POINT_CODE IS NULL
    AND c.FOB_POINT IS NOT NULL;


-- 13. SOLD_TO_ORG
-- NOTE 1: Value to ID for sold to (customer) should be done before
-- other dependent fields like sites and contacts.
-- NOTE 2: Status field update is a union - if customer number is
-- supplied, it takes precedence over the name or sold to org value field.

--bug 5620045
--Catch subqry_too_many_rows exception
BEGIN
    UPDATE OE_HEADERS_IFACE_ALL c
    SET (SOLD_TO_ORG_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.CUST_ACCOUNT_ID,
               DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
               DECODE(b.CUST_ACCOUNT_ID,NULL,
                      c.ATTRIBUTE_STATUS||'013',c.ATTRIBUTE_STATUS)
        FROM HZ_CUST_ACCOUNTS b, OE_HEADERS_IFACE_ALL d
        WHERE d.CUSTOMER_NUMBER IS NOT NULL
          AND d.CUSTOMER_NUMBER = b.ACCOUNT_NUMBER(+)
          AND b.STATUS(+) = 'A'
          AND d.rowid = c.rowid
        UNION ALL
        SELECT b.CUST_ACCOUNT_ID,
               DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
               DECODE(b.CUST_ACCOUNT_ID,NULL,
                      c.ATTRIBUTE_STATUS||'013',c.ATTRIBUTE_STATUS)
        FROM HZ_CUST_ACCOUNTS b, HZ_PARTIES e, OE_HEADERS_IFACE_ALL d
        WHERE d.CUSTOMER_NUMBER IS NULL
          AND d.SOLD_TO_ORG = e.PARTY_NAME(+)
          AND b.STATUS(+) = 'A'
          AND b.PARTY_ID(+) = e.PARTY_ID
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.SOLD_TO_ORG_ID IS NULL
    AND (c.SOLD_TO_ORG IS NOT NULL OR
         c.CUSTOMER_NUMBER IS NOT NULL);
EXCEPTION
  WHEN subqry_too_many_rows THEN
       UPDATE OE_HEADERS_IFACE_ALL c
          SET ERROR_FLAG = 'Y',
              ATTRIBUTE_STATUS = ATTRIBUTE_STATUS||'013'
        WHERE c.batch_id = p_batch_id
          AND c.SOLD_TO_ORG_ID IS NULL
          AND c.SOLD_TO_ORG IS NOT NULL;
End;


  -- Bulk Import does NOT check for customer relationships in
  -- value to ID.
  -- If value columns are provided for ship to or bill to,
  -- 1) it would search in the addresses for ship to customer
  -- or bill to customer if supplied.
  -- 2) if ship to or bill to customer is not supplied, it will
  -- search in addresses for the sold to customer
  -- The validation to ensure that ship to and bill to customer
  -- are valid as per customer relationships parameter will be
  -- done later during bulk entity processing in OEBLHDRB/OEBLLINB.pls

  -- Ship To and Invoice To customer should be passed only if
  -- customer relationships is 'Y' or 'A'
  IF OE_Bulk_Order_Pvt.G_CUST_RELATIONS <> 'N' THEN

    -- First, value to ID conversions for ship to customer and
    -- and invoice_to_customer

    -- SHIP_TO_CUSTOMER
    --bug 5620045
    --catch subqry_too_many_rows
BEGIN
    UPDATE OE_HEADERS_IFACE_ALL c
    SET (SHIP_TO_CUSTOMER_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
        (SELECT b.CUST_ACCOUNT_ID,
               DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
               DECODE(b.CUST_ACCOUNT_ID,NULL,
                      d.ATTRIBUTE_STATUS||'014',d.ATTRIBUTE_STATUS)
        FROM HZ_CUST_ACCOUNTS b, OE_HEADERS_IFACE_ALL d
        WHERE d.SHIP_TO_CUSTOMER_NUMBER IS NOT NULL
          AND d.SHIP_TO_CUSTOMER_NUMBER = b.ACCOUNT_NUMBER(+)
          AND b.STATUS(+) = 'A'
          AND d.rowid = c.rowid
        UNION ALL
        SELECT b.CUST_ACCOUNT_ID,
               DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
               DECODE(b.CUST_ACCOUNT_ID,NULL,
                      d.ATTRIBUTE_STATUS||'014',d.ATTRIBUTE_STATUS)
        FROM HZ_CUST_ACCOUNTS b, HZ_PARTIES e, OE_HEADERS_IFACE_ALL d
        WHERE d.SHIP_TO_CUSTOMER_NUMBER IS NULL
          AND d.SHIP_TO_CUSTOMER = e.PARTY_NAME(+)
          AND b.STATUS(+) = 'A'
          AND b.PARTY_ID(+) = e.PARTY_ID
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.SHIP_TO_CUSTOMER_ID IS NULL
    AND (c.SHIP_TO_CUSTOMER IS NOT NULL OR
         c.SHIP_TO_CUSTOMER_NUMBER IS NOT NULL);
EXCEPTION
  WHEN subqry_too_many_rows THEN
       UPDATE OE_HEADERS_IFACE_ALL c
          SET ERROR_FLAG = 'Y',
              ATTRIBUTE_STATUS = ATTRIBUTE_STATUS||'014'
        WHERE c.batch_id = p_batch_id
          AND c.SHIP_TO_CUSTOMER_ID IS NULL
          AND c.SHIP_TO_CUSTOMER IS NOT NULL;
END;

    -- INVOICE_TO_CUSTOMER
    --bug 5620045
    --catch subqry_too_many_rows
BEGIN
    UPDATE OE_HEADERS_IFACE_ALL c
    SET (INVOICE_CUSTOMER_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
        (SELECT b.CUST_ACCOUNT_ID,
               DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
               DECODE(b.CUST_ACCOUNT_ID,NULL,
                      d.ATTRIBUTE_STATUS||'015',d.ATTRIBUTE_STATUS)
        FROM HZ_CUST_ACCOUNTS b, OE_HEADERS_IFACE_ALL d
        WHERE d.INVOICE_CUSTOMER_NUMBER IS NOT NULL
          AND d.INVOICE_CUSTOMER_NUMBER = b.ACCOUNT_NUMBER(+)
          AND b.STATUS(+) = 'A'
          AND d.rowid = c.rowid
        UNION ALL
        SELECT b.CUST_ACCOUNT_ID,
               DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
               DECODE(b.CUST_ACCOUNT_ID,NULL,
                      d.ATTRIBUTE_STATUS||'015',d.ATTRIBUTE_STATUS)
        FROM HZ_CUST_ACCOUNTS b, HZ_PARTIES e, OE_HEADERS_IFACE_ALL d
        WHERE d.INVOICE_CUSTOMER_NUMBER IS NULL
          AND d.INVOICE_CUSTOMER = e.PARTY_NAME(+)
          AND b.STATUS(+) = 'A'
          AND b.PARTY_ID(+) = e.PARTY_ID
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.INVOICE_CUSTOMER_ID IS NULL
    AND (c.INVOICE_CUSTOMER IS NOT NULL OR
         c.INVOICE_CUSTOMER_NUMBER IS NOT NULL);
EXCEPTION
  WHEN subqry_too_many_rows THEN
       UPDATE OE_HEADERS_IFACE_ALL c
          SET ERROR_FLAG = 'Y',
              ATTRIBUTE_STATUS = ATTRIBUTE_STATUS||'015'
        WHERE c.batch_id = p_batch_id
          AND c.INVOICE_CUSTOMER_ID IS NULL
          AND c.INVOICE_CUSTOMER IS NOT NULL ;
END;

  END IF;

  -- 14. SHIP_TO_ORG

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (SHIP_TO_ORG_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
          (SELECT  /*+ PUSH_PRED(b) */ b.ORGANIZATION_ID,
               DECODE(b.ORGANIZATION_ID,NULL,'Y',NULL),
               DECODE(b.ORGANIZATION_ID,NULL,
                      d.ATTRIBUTE_STATUS||'014',d.ATTRIBUTE_STATUS)
          FROM OE_SHIP_TO_ORGS_V b, OE_HEADERS_IFACE_ALL d
          WHERE d.ship_to_address1 = ADDRESS_LINE_1(+)
          AND nvl(d.ship_to_address2,'NIL') = NVL(ADDRESS_LINE_2(+),'NIL')
          AND nvl(d.ship_to_address3,'NIL') = nvl(ADDRESS_LINE_3(+),'NIL')
          --AND nvl(d.ship_to_address4,'NIL') = ADDRESS_LINE_4
          AND nvl(d.ship_to_city,'NIL') = nvl(town_or_city(+),'NIL')
          AND nvl(d.ship_to_state,'NIL') = nvl(state(+),'NIL')
          AND nvl(d.ship_to_postal_code,'NIL') = nvl(postal_code(+),'NIL')
          AND nvl(d.ship_to_country,'NIL') = nvl(country(+),'NIL')
          AND nvl(STATUS(+),'A') = 'A'
          AND b.CUSTOMER_ID(+) = nvl(d.SHIP_TO_CUSTOMER_ID,d.SOLD_TO_ORG_ID)
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.SHIP_TO_ORG_ID IS NULL
    AND (c.SHIP_TO_ADDRESS1 IS NOT NULL
        OR c.ship_to_address2 IS NOT NULL
        OR c.ship_to_address3 IS NOT NULL
        OR c.ship_to_address4 IS NOT NULL
        OR c.ship_to_org IS NOT NULL
        );

  -- 15. INVOICE_TO_ORG

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (INVOICE_TO_ORG_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
          (SELECT  /*+ PUSH_PRED(b) */ b.ORGANIZATION_ID,
               DECODE(b.ORGANIZATION_ID,NULL,'Y',NULL),
               DECODE(b.ORGANIZATION_ID,NULL,
                      d.ATTRIBUTE_STATUS||'015',d.ATTRIBUTE_STATUS)
          FROM OE_INVOICE_TO_ORGS_V b, OE_HEADERS_IFACE_ALL d
          WHERE d.invoice_address1 = ADDRESS_LINE_1(+)
          AND nvl(d.invoice_address2,'NIL') = NVL(ADDRESS_LINE_2(+),'NIL')
          AND nvl(d.invoice_address3,'NIL') = nvl(ADDRESS_LINE_3(+),'NIL')
          --AND nvl(d.invoice_address4,'NIL') = ADDRESS_LINE_4
          AND nvl(d.invoice_city,'NIL') = nvl(town_or_city(+),'NIL')
          AND nvl(d.invoice_state,'NIL') = nvl(state(+),'NIL')
          AND nvl(d.invoice_postal_code,'NIL') = nvl(postal_code(+),'NIL')
          AND nvl(d.invoice_country,'NIL') = nvl(country(+),'NIL')
          AND nvl(STATUS(+),'A') = 'A'
          AND b.CUSTOMER_ID(+) = nvl(d.INVOICE_CUSTOMER_ID,d.SOLD_TO_ORG_ID)
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.INVOICE_TO_ORG_ID IS NULL
    AND (c.invoice_address1 IS NOT NULL
        OR c.invoice_address2 IS NOT NULL
        OR c.invoice_address3 IS NOT NULL
        OR c.invoice_address4 IS NOT NULL
        OR c.invoice_to_org IS NOT NULL
        );


-- DELIVER_TO_ORG  No mapping columns in the interface table

-- 16. SOLD_TO_CONTACT                          VARCHAR2(30)

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (SOLD_TO_CONTACT_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT DISTINCT b.CONTACT_ID,
               DECODE(b.CONTACT_ID,NULL,'Y',NULL),
               DECODE(b.CONTACT_ID,NULL,
                      c.ATTRIBUTE_STATUS||'016',c.ATTRIBUTE_STATUS)
        FROM OE_CONTACTS_V b
        WHERE c.SOLD_TO_CONTACT = b.NAME(+)
          AND c.SOLD_TO_ORG_ID = b.CUSTOMER_ID(+)
        )
    WHERE c.batch_id = p_batch_id
    AND c.SOLD_TO_CONTACT_ID IS NULL
    AND c.SOLD_TO_CONTACT IS NOT NULL
    AND c.SOLD_TO_ORG_ID IS NOT NULL;


-- 17. SHIP_TO_CONTACT                          VARCHAR2(30)

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (SHIP_TO_CONTACT_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT Get_Contact_ID(c.SHIP_TO_CONTACT,c.SHIP_TO_ORG_ID),
               DECODE(Get_Contact_ID(c.SHIP_TO_CONTACT,c.SHIP_TO_ORG_ID),NULL,'Y',NULL),
               DECODE(Get_Contact_ID(c.SHIP_TO_CONTACT,c.SHIP_TO_ORG_ID),NULL,
                      c.ATTRIBUTE_STATUS||'017',c.ATTRIBUTE_STATUS)
        FROM DUAL
        )
    WHERE c.batch_id = p_batch_id
    AND c.SHIP_TO_CONTACT_ID IS NULL
    AND c.SHIP_TO_CONTACT IS NOT NULL;


-- 18. INVOICE_TO_CONTACT                       VARCHAR2(30)

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (INVOICE_TO_CONTACT_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT Get_Contact_ID(c.INVOICE_TO_CONTACT,c.INVOICE_TO_ORG_ID),
               DECODE(Get_Contact_ID(c.INVOICE_TO_CONTACT,c.INVOICE_TO_ORG_ID),NULL,'Y',NULL),
               DECODE(Get_Contact_ID(c.INVOICE_TO_CONTACT,c.INVOICE_TO_ORG_ID),NULL,
                      c.ATTRIBUTE_STATUS||'018',c.ATTRIBUTE_STATUS)
        FROM DUAL
        )
    WHERE c.batch_id = p_batch_id
    AND c.INVOICE_TO_CONTACT_ID IS NULL
    AND c.INVOICE_TO_CONTACT IS NOT NULL;


-- 19. DELIVER_TO_CONTACT                       VARCHAR2(30)

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (DELIVER_TO_CONTACT_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT Get_Contact_ID(c.DELIVER_TO_CONTACT,c.DELIVER_TO_ORG_ID),
               DECODE(Get_Contact_ID(c.DELIVER_TO_CONTACT,c.DELIVER_TO_ORG_ID),NULL,'Y',NULL),
               DECODE(Get_Contact_ID(c.DELIVER_TO_CONTACT,c.DELIVER_TO_ORG_ID),NULL,
                      c.ATTRIBUTE_STATUS||'019',c.ATTRIBUTE_STATUS)
        FROM DUAL
        )
    WHERE c.batch_id = p_batch_id
    AND c.DELIVER_TO_CONTACT_ID IS NULL
    AND c.DELIVER_TO_CONTACT IS NOT NULL;


-- SHIPPING_METHOD_CODE                         VARCHAR2(30)
    UPDATE OE_HEADERS_IFACE_ALL c
    SET (SHIPPING_METHOD_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'024',c.ATTRIBUTE_STATUS)
        FROM OE_SHIP_METHODS_V b, OE_HEADERS_IFACE_ALL d
        WHERE d.SHIPPING_METHOD = b.MEANING(+)
          AND b.enabled_flag(+) = 'Y'
          AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE(+), SYSDATE)
                      AND NVL(END_DATE_ACTIVE(+), SYSDATE)
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.SHIPPING_METHOD_CODE IS NULL
    AND c.SHIPPING_METHOD IS NOT NULL;

-- FREIGHT_CARRIER_CODE: value column does not exist on interface tables

-- SALES_CHANNEL_CODE

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (SALES_CHANNEL_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'022',c.ATTRIBUTE_STATUS)
        FROM OE_LOOKUPS b, OE_HEADERS_IFACE_ALL d
        WHERE d.SALES_CHANNEL = b.MEANING(+)
          AND b.LOOKUP_TYPE(+) = 'SALES_CHANNEL'
          AND b.enabled_flag(+) = 'Y'
          AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.SALES_CHANNEL_CODE IS NULL
    AND c.SALES_CHANNEL IS NOT NULL;

-- SHIPMENT_PRIORITY_CODE

    UPDATE OE_HEADERS_IFACE_ALL c
    SET (SHIPMENT_PRIORITY_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'023',c.ATTRIBUTE_STATUS)
        FROM OE_LOOKUPS b, OE_HEADERS_IFACE_ALL d
        WHERE d.SHIPMENT_PRIORITY = b.MEANING(+)
          AND b.LOOKUP_TYPE(+) = 'SHIPMENT_PRIORITY'
          AND b.enabled_flag(+) = 'Y'
          AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
        )
    WHERE c.batch_id = p_batch_id
    AND c.SHIPMENT_PRIORITY_CODE IS NULL
    AND c.SHIPMENT_PRIORITY IS NOT NULL;

-- Sold_to_site_use_id
--abghosh

IF OE_CODE_CONTROL.Code_Release_Level >='110510' THEN
  UPDATE OE_HEADERS_IFACE_ALL c
   SET (SOLD_TO_SITE_USE_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
     (SELECT SITE.SITE_USE_ID,
      DECODE(SITE.SITE_USE_ID,null,'Y',null),
     DECODE(SITE.SITE_USE_ID,null,d.ATTRIBUTE_STATUS||'014',d.ATTRIBUTE_STATUS)

 FROM      HZ_CUST_SITE_USES_ALL    SITE,
           HZ_PARTY_SITES       PARTY_SITE,
           HZ_LOCATIONS         LOC,
           HZ_CUST_ACCT_SITES_ALL   ACCT_SITE,
           OE_HEADERS_IFACE_ALL d

  WHERE   SITE.SITE_USE_CODE    ='SOLD_TO'
   AND   SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
   AND   ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
   AND   PARTY_SITE.LOCATION_ID = LOC.LOCATION_ID
   AND  d.sold_to_location_address1= LOC.ADDRESS1(+)
   AND  nvl(d.sold_to_location_address2,'NIL')=nvl(LOC.ADDRESS2(+),'NIL')
   AND  nvl(d.sold_to_location_address3,'NIL')=nvl(LOC.ADDRESS3(+),'NIL')
   AND  nvl(d.sold_to_location_address4,'NIL')=nvl(LOC.ADDRESS4(+),'NIL')
   AND  nvl(d.sold_to_location_city,'NIL')=nvl(LOC.CITY(+),'NIL')
   AND  nvl(d.sold_to_location_state,'NIL')=nvl(LOC.STATE(+),'NIL')
   AND  nvl(d.sold_to_location_postal_code,'NIL')=nvl(LOC.POSTAL_CODE(+),'NIL')
   AND  nvl(d.sold_to_location_country,'NIL')=nvl(LOC.COUNTRY(+),'NIL')
   AND nvl(SITE.STATUS,'A')='A'
   AND nvl(ACCT_SITE.STATUS,'A')='A'
   AND ACCT_SITE.CUST_ACCOUNT_ID(+)=d.SOLD_TO_ORG_ID
   AND d.rowid=c.rowid
  )
  WHERE c.batch_id=p_batch_id
   AND c.SOLD_TO_SITE_USE_ID IS NULL
   AND (c.SOLD_TO_LOCATION_ADDRESS1 IS NOT NULL
        OR c.SOLD_TO_LOCATION_ADDRESS2 IS NOT NULL
        OR c.SOLD_TO_LOCATION_ADDRESS3 IS NOT NULL
        OR c.SOLD_TO_LOCATION_ADDRESS4 IS NOT NULL
      );

 --{ Bug 5054618
--End customer changes for HVOP
--bug 5620045 catch subqry_too_many_rows
BEGIN
UPDATE OE_HEADERS_IFACE_ALL c
 SET (END_CUSTOMER_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
 (SELECT b.CUST_ACCOUNT_ID,
  DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
  DECODE(b.CUST_ACCOUNT_ID,NULL,
  d.ATTRIBUTE_STATUS||'025',d.ATTRIBUTE_STATUS)
    FROM HZ_CUST_ACCOUNTS b, OE_HEADERS_IFACE_ALL d
   WHERE d.END_CUSTOMER_NUMBER IS NOT NULL  AND d.END_CUSTOMER_NUMBER = b.ACCOUNT_NUMBER(+)
   AND b.STATUS(+) = 'A'  AND d.rowid = c.rowid
   UNION ALL
  SELECT b.CUST_ACCOUNT_ID,
   DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
   DECODE(b.CUST_ACCOUNT_ID,NULL,
   d.ATTRIBUTE_STATUS||'025',d.ATTRIBUTE_STATUS) FROM HZ_CUST_ACCOUNTS b, HZ_PARTIES e, OE_HEADERS_IFACE_ALL d
   WHERE d.END_CUSTOMER_NUMBER IS NULL AND d.END_CUSTOMER_NAME = e.PARTY_NAME(+)
     AND b.STATUS(+) = 'A'  AND b.PARTY_ID(+) = e.PARTY_ID
     AND d.rowid = c.rowid)
    WHERE c.batch_id = p_batch_id and c.END_CUSTOMER_ID IS NULL AND
    (c.END_CUSTOMER_NAME IS NOT NULL OR c.END_CUSTOMER_NUMBER IS NOT NULL);
EXCEPTION
  WHEN subqry_too_many_rows THEN
       UPDATE OE_HEADERS_IFACE_ALL c
          SET ERROR_FLAG = 'Y',
              ATTRIBUTE_STATUS = ATTRIBUTE_STATUS||'025'
        WHERE c.batch_id = p_batch_id
          AND c.END_CUSTOMER_ID IS NULL
          AND c.END_CUSTOMER_NAME IS NOT NULL ;
END;



UPDATE OE_HEADERS_IFACE_ALL c
		      SET (END_CUSTOMER_SITE_USE_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
			  (SELECT END_CUSTOMER_SITE(c.end_customer_address1,c.end_customer_address2,c.end_customer_address3,c.end_customer_address4,
						    c.end_customer_location, NULL,c.end_customer_id,c.end_customer_city,
						    c.end_customer_state,c.end_customer_postal_code,c.end_customer_country,NULL),
				DECODE(END_CUSTOMER_SITE(c.end_customer_address1,c.end_customer_address2,c.end_customer_address3,
							   c.end_customer_address4,c.end_customer_location,NULL,
							   c.end_customer_id,c.end_customer_city,c.end_customer_state,
							   c.end_customer_postal_code,c.end_customer_country,
							   NULL),NULL,'Y',NULL),
							       DECODE(END_CUSTOMER_SITE(c.end_customer_address1,
											c.end_customer_address2,
											c.end_customer_address3,
											c.end_customer_address4,
											c.end_customer_location,
											NULL,
											c.end_customer_id,
											c.end_customer_city,
											c.end_customer_state,
											c.end_customer_postal_code,
											c.end_customer_country,
											NULL),NULL,c.ATTRIBUTE_STATUS||'027',c.ATTRIBUTE_STATUS)
			FROM DUAL)
		    WHERE c.batch_id=p_batch_id
		      AND c.END_CUSTOMER_SITE_USE_ID IS NULL AND c.END_CUSTOMER_ID IS NOT NULL
		      AND (c.END_CUSTOMER_ADDRESS1 IS NOT NULL
			   OR c.END_CUSTOMER_ADDRESS2 IS NOT NULL
			   OR c.END_CUSTOMER_ADDRESS3 IS NOT NULL
			   OR c.END_CUSTOMER_ADDRESS4 IS NOT NULL);


UPDATE OE_HEADERS_IFACE_ALL c
     SET (END_CUSTOMER_CONTACT_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
	 (SELECT Get_End_customer_Contact_ID(c.END_CUSTOMER_CONTACT,c.END_CUSTOMER_ID),
		 DECODE(Get_End_customer_Contact_ID(c.END_CUSTOMER_CONTACT,c.END_CUSTOMER_ID),NULL,'Y',NULL),
		 DECODE(Get_End_customer_Contact_ID(c.END_CUSTOMER_CONTACT,c.END_CUSTOMER_ID),NULL,c.ATTRIBUTE_STATUS||'026',c.ATTRIBUTE_STATUS)
       FROM DUAL) WHERE c.batch_id = p_batch_id and c.END_CUSTOMER_CONTACT_ID IS NULL AND c.END_CUSTOMER_CONTACT IS NOT NULL;

 --Bug 5054618}

UPDATE OE_HEADERS_IFACE_ALL c
     SET (IB_OWNER_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
	 (SELECT b.LOOKUP_CODE,
		 DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
		 DECODE(b.LOOKUP_CODE,NULL,
			c.ATTRIBUTE_STATUS||'028',c.ATTRIBUTE_STATUS)
       FROM -- OE_LOOKUPS b,
	     ( select lookup_code, meaning
	       from OE_LOOKUPS
	       where lookup_type In ('ITEM_OWNER', 'ONT_INSTALL_BASE')
	       and enabled_flag = 'Y'
	       and SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
			AND NVL(END_DATE_ACTIVE, SYSDATE) )   b,
		OE_HEADERS_IFACE_ALL d
      WHERE d.IB_OWNER= b.MEANING(+)
	--AND ( b.LOOKUP_TYPE(+) = 'ITEM_OWNER'
	--OR  b.LOOKUP_TYPE(+) =  'ONT_INSTALL_BASE' )
	--AND b.enabled_flag(+) = 'Y'
	--AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
	--AND NVL(END_DATE_ACTIVE, SYSDATE)
	AND d.rowid = c.rowid
	AND rownum = 1
	    )
   WHERE c.batch_id = p_batch_id
     AND c.IB_OWNER_CODE IS NULL  AND c.IB_OWNER IS NOT NULL;

UPDATE OE_HEADERS_IFACE_ALL c
           SET (IB_INSTALLED_AT_LOCATION_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
	       (SELECT b.LOOKUP_CODE,
		       DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
		       DECODE(b.LOOKUP_CODE,NULL,
			      c.ATTRIBUTE_STATUS||'029',c.ATTRIBUTE_STATUS)
    FROM -- OE_LOOKUPS b,
 	     ( select lookup_code, meaning
	       from OE_LOOKUPS
	       where lookup_type In ('ITEM_INSTALL_LOCATION', 'ONT_INSTALL_BASE')
	       and enabled_flag = 'Y'
	       and SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
			AND NVL(END_DATE_ACTIVE, SYSDATE) )   b,
	OE_HEADERS_IFACE_ALL d
	    WHERE d.IB_INSTALLED_AT_LOCATION = b.MEANING(+)
	      --AND ( b.LOOKUP_TYPE(+) = 'ITEM_INSTALL_LOCATION'
	      --OR b.LOOKUP_TYPE(+) = 'ONT_INSTALL_BASE' )
	      --AND b.enabled_flag(+) = 'Y'
	      --AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
	      --AND NVL(END_DATE_ACTIVE, SYSDATE)
	      AND d.rowid = c.rowid
	      AND rownum = 1
		  )
   WHERE c.batch_id = p_batch_id
	  AND c.IB_INSTALLED_AT_LOCATION_CODE IS NULL
	  AND c.IB_INSTALLED_AT_LOCATION IS NOT NULL;

UPDATE OE_HEADERS_IFACE_ALL c
	  SET (IB_CURRENT_LOCATION_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
	      (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                c.ATTRIBUTE_STATUS||'030',c.ATTRIBUTE_STATUS)
	    FROM -- OE_LOOKUPS b,
	     ( select lookup_code, meaning
	       from OE_LOOKUPS
	       where lookup_type In ('ITEM_CURRENT_LOCATION', 'ONT_INSTALL_BASE')
	       and enabled_flag = 'Y'
	       and SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
			AND NVL(END_DATE_ACTIVE, SYSDATE) )   b,
		OE_HEADERS_IFACE_ALL d
	   WHERE d.IB_CURRENT_LOCATION = b.MEANING(+)
          --AND ( b.LOOKUP_TYPE(+) = 'ITEM_CURRENT_LOCATION'
          --OR b.LOOKUP_TYPE(+) = 'ONT_INSTALL_BASE' )
          --AND b.enabled_flag(+) = 'Y'
          --AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
          --            AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
	  AND rownum = 1
        )
    WHERE c.batch_id = p_batch_id
    AND c.IB_CURRENT_LOCATION_CODE IS NULL
    AND c.IB_CURRENT_LOCATION IS NOT NULL;


-- OE_debug_pub.add('talking from value to id success');

END IF;

-- SHIP_FROM_ORG_ID: No Value to ID conversion in OEXSVIDB.pls!

-- TAX_EXEMPT_FLAG: Value column does not exist on interface tables

-- TAX_POINT_CODE: Unused column

-- PAYMENT_TYPE_CODE: Value column does not exist on interface tables

-- CREDIT_CARD_CODE: Not supported for BULK!

EXCEPTION
    WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OTHERS ERROR , OE_BULK_VALUE_TO_ID.HEADERS' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
     END IF;
     OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Headers'
        );
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Headers;


---------------------------------------------------------------------
-- PROCEDURE Lines
--
-- Value to ID conversions on lines interface table.
-- It sets error_flag to 'Y' and appends ATTRIBUTE_STATUS column with a
-- number identifying each attribute that fails value to ID conversion.
---------------------------------------------------------------------

PROCEDURE Lines(p_batch_id  IN NUMBER)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

--bug 5620045
subqry_too_many_rows Exception;
PRAGMA EXCEPTION_INIT(subqry_too_many_rows, -01427);
--
BEGIN

-- LINE_TYPE

    UPDATE OE_LINES_IFACE_ALL c
    SET (LINE_TYPE_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.transaction_type_id,
               DECODE(b.transaction_type_id,NULL,'Y',NULL),
               DECODE(b.transaction_type_id,NULL,
                      c.ATTRIBUTE_STATUS||'020',c.ATTRIBUTE_STATUS)
        FROM OE_TRANSACTION_TYPES_TL b, OE_LINES_IFACE_ALL d
        WHERE d.LINE_TYPE = b.name(+)
          AND NVL(b.LANGUAGE,USERENV('LANG')) = USERENV('LANG')
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.LINE_TYPE_ID IS NULL
    AND c.LINE_TYPE IS NOT NULL;

-- PRICE_LIST

    UPDATE OE_LINES_IFACE_ALL c
    SET (price_list_id,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LIST_HEADER_ID,
               DECODE(b.LIST_HEADER_ID,NULL,'Y',NULL),
               DECODE(b.LIST_HEADER_ID,NULL,
                      c.ATTRIBUTE_STATUS||'003',c.ATTRIBUTE_STATUS)
        FROM qp_list_headers_vl b, OE_LINES_IFACE_ALL d
        WHERE d.price_list = b.name(+)
          AND NVL(b.list_type_code,'PRL') IN ('PRL', 'AGR')
          AND nvl(b.active_flag,'Y') = 'Y'
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.price_list_id IS NULL
    AND c.price_list IS NOT NULL;


-- SALESREP

    UPDATE OE_LINES_IFACE_ALL c
    SET ( SALESREP_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT  /*+ PUSH_PRED(b) */ b.SALESREP_ID,
               DECODE(b.SALESREP_ID,NULL,'Y',NULL),
               DECODE(b.SALESREP_ID,NULL,
                      c.ATTRIBUTE_STATUS||'005',c.ATTRIBUTE_STATUS)
        FROM RA_SALESREPS b, OE_LINES_IFACE_ALL d
        WHERE d.SALESREP = b.NAME(+)
          AND sysdate between NVL(start_date_active,sysdate)
                       and NVL(end_date_active,sysdate)
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.SALESREP_ID IS NULL
    AND c.SALESREP IS NOT NULL;



-- TAX_EXEMPT_REASON                        VARCHAR2(30)
    -- eBTax changes
  /*UPDATE OE_LINES_IFACE_ALL c
    SET (TAX_EXEMPT_REASON_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'006',c.ATTRIBUTE_STATUS)
        FROM OE_AR_LOOKUPS_V b, OE_LINES_IFACE_ALL d
        WHERE d.TAX_EXEMPT_REASON = b.MEANING(+)
          AND b.LOOKUP_TYPE(+) = 'TAX_REASON'
          AND b.enabled_flag(+) = 'Y'
          AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.TAX_EXEMPT_REASON_CODE IS NULL
    AND c.TAX_EXEMPT_REASON IS NOT NULL;*/

	UPDATE OE_LINES_IFACE_ALL c
	   SET (TAX_EXEMPT_REASON_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
	       (SELECT b.LOOKUP_CODE,
	               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
	               DECODE(b.LOOKUP_CODE,NULL,
	                      c.ATTRIBUTE_STATUS||'006',c.ATTRIBUTE_STATUS)
	          FROM FND_LOOKUPS  b, OE_LINES_IFACE_ALL d
	         WHERE d.TAX_EXEMPT_REASON = b.MEANING(+)
	           AND b.LOOKUP_TYPE(+) = 'ZX_EXEMPTION_REASON_CODE'
	           AND b.enabled_flag(+) = 'Y'
	           AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
	                             AND NVL(END_DATE_ACTIVE, SYSDATE)
	           AND d.rowid = c.rowid)
         WHERE (order_source_id, orig_sys_document_ref) IN
	       (SELECT order_source_id, orig_sys_document_ref
	          FROM OE_HEADERS_IFACE_ALL
	         WHERE batch_id = p_batch_id)
	   AND c.TAX_EXEMPT_REASON_CODE IS NULL
	   AND c.TAX_EXEMPT_REASON IS NOT NULL;



-- AGREEMENT                                VARCHAR2(50)

    UPDATE OE_LINES_IFACE_ALL c
    SET (AGREEMENT_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.AGREEMENT_ID,
               DECODE(b.AGREEMENT_ID,NULL,'Y',NULL),
               DECODE(b.AGREEMENT_ID,NULL,
                      c.ATTRIBUTE_STATUS||'007',c.ATTRIBUTE_STATUS)
        FROM OE_AGREEMENTS_V b, OE_LINES_IFACE_ALL d
        WHERE d.AGREEMENT = b.NAME(+)
          AND sysdate between nvl(start_date_active, sysdate)
              and nvl(end_date_active, sysdate)
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.AGREEMENT_ID IS NULL
    AND c.AGREEMENT IS NOT NULL;



-- INVOICING_RULE

    UPDATE OE_LINES_IFACE_ALL c
    SET (INVOICING_RULE_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.RULE_ID,
               DECODE(b.RULE_ID,NULL,'Y',NULL),
               DECODE(b.RULE_ID,NULL,
                      c.ATTRIBUTE_STATUS||'008',c.ATTRIBUTE_STATUS)
        FROM OE_RA_RULES_V b, OE_LINES_IFACE_ALL d
        WHERE d.INVOICING_RULE = b.NAME(+)
          AND b.STATUS(+) = 'A'
          AND b.TYPE(+) = 'I'
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.INVOICING_RULE_ID IS NULL
    AND c.INVOICING_RULE IS NOT NULL;

-- ACCOUNTING_RULE                          VARCHAR2(30)

    UPDATE OE_LINES_IFACE_ALL c
    SET (ACCOUNTING_RULE_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.RULE_ID,
               DECODE(b.RULE_ID,NULL,'Y',NULL),
               DECODE(b.RULE_ID,NULL,
                      c.ATTRIBUTE_STATUS||'009',c.ATTRIBUTE_STATUS)
        FROM OE_RA_RULES_V b, OE_LINES_IFACE_ALL d
        WHERE d.ACCOUNTING_RULE = b.NAME(+)
          AND b.STATUS(+) = 'A'
      --  AND b.TYPE(+) = 'A' --we now allow variable accounting rules
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.ACCOUNTING_RULE_ID IS NULL
    AND c.ACCOUNTING_RULE IS NOT NULL;

-- PAYMENT_TERM                             VARCHAR2(30)

    UPDATE OE_LINES_IFACE_ALL c
    SET (PAYMENT_TERM_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.TERM_ID,
               DECODE(b.TERM_ID,NULL,'Y',NULL),
               DECODE(b.TERM_ID,NULL,
                      c.ATTRIBUTE_STATUS||'010',c.ATTRIBUTE_STATUS)
        FROM OE_RA_TERMS_V b, OE_LINES_IFACE_ALL d
        WHERE d.PAYMENT_TERM = b.NAME(+)
          AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                  AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.PAYMENT_TERM_ID IS NULL
    AND c.PAYMENT_TERM IS NOT NULL;


-- FREIGHT_TERMS                            VARCHAR2(30)

    UPDATE OE_LINES_IFACE_ALL c
    SET (FREIGHT_TERMS_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'011',c.ATTRIBUTE_STATUS)
        FROM OE_LOOKUPS b, OE_LINES_IFACE_ALL d
        WHERE d.FREIGHT_TERMS = b.MEANING(+)
          AND b.LOOKUP_TYPE(+) = 'FREIGHT_TERMS'
          AND b.enabled_flag(+) = 'Y'
          AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.FREIGHT_TERMS_CODE IS NULL
    AND c.FREIGHT_TERMS IS NOT NULL;



-- FOB_POINT                                VARCHAR2(30)

    UPDATE OE_LINES_IFACE_ALL c
    SET (FOB_POINT_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'012',c.ATTRIBUTE_STATUS)
        FROM OE_AR_LOOKUPS_V b, OE_LINES_IFACE_ALL d
        WHERE d.FOB_POINT = b.MEANING(+)
          AND b.LOOKUP_TYPE(+) = 'FOB'
          AND b.enabled_flag(+) = 'Y'
          AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.FOB_POINT_CODE IS NULL
    AND c.FOB_POINT IS NOT NULL;


-- SOLD_TO_ORG -- Required as it is used later for invoice
-- and ship to org
    UPDATE OE_LINES_IFACE_ALL c
    SET SOLD_TO_ORG_ID =
         (SELECT d.SOLD_TO_ORG_ID FROM OE_HEADERS_IFACE_ALL d, OE_LINES_IFACE_ALL e
          WHERE d.order_source_id = e.order_source_id
            AND d.orig_sys_document_ref = e.orig_sys_document_ref
            AND batch_id = p_batch_id
            AND d.sold_to_org_id IS NOT NULL
            AND c.rowid = e.rowid
         )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id
)
    AND c.SOLD_TO_ORG_ID IS NULL;


-- DELIVER_TO_ORG  No mapping columns in the interface table


  -- Ship To and Invoice To customer should be passed only if
  -- customer relationships is 'Y' or 'A'
  IF OE_Bulk_Order_Pvt.G_CUST_RELATIONS <> 'N' THEN

    -- First, value to ID conversions for ship to customer and
    -- and invoice_to_customer

    -- SHIP_TO_CUSTOMER
--Enclosing the update in a block for bug 5620045
BEGIN
    UPDATE OE_LINES_IFACE_ALL c
    SET (SHIP_TO_CUSTOMER_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
        (SELECT b.CUST_ACCOUNT_ID,
               DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
               DECODE(b.CUST_ACCOUNT_ID,NULL,
                      d.ATTRIBUTE_STATUS||'014',d.ATTRIBUTE_STATUS)
        FROM HZ_CUST_ACCOUNTS b, OE_LINES_IFACE_ALL d
        WHERE d.SHIP_TO_CUSTOMER_NUMBER IS NOT NULL
          AND d.SHIP_TO_CUSTOMER_NUMBER = b.ACCOUNT_NUMBER(+)
          AND b.STATUS(+) = 'A'
          AND d.rowid = c.rowid
        UNION ALL
        SELECT b.CUST_ACCOUNT_ID,
               DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
               DECODE(b.CUST_ACCOUNT_ID,NULL,
                      d.ATTRIBUTE_STATUS||'014',d.ATTRIBUTE_STATUS)
        FROM HZ_CUST_ACCOUNTS b, HZ_PARTIES e, OE_LINES_IFACE_ALL d
        WHERE d.SHIP_TO_CUSTOMER_NUMBER IS NULL
          AND d.SHIP_TO_CUSTOMER_NAME = e.PARTY_NAME(+)
          AND b.STATUS(+) = 'A'
          AND b.PARTY_ID(+) = e.PARTY_ID
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.SHIP_TO_CUSTOMER_ID IS NULL
    AND (c.SHIP_TO_CUSTOMER_NAME IS NOT NULL OR
         c.SHIP_TO_CUSTOMER_NUMBER IS NOT NULL);
EXCEPTION
  WHEN subqry_too_many_rows THEN
    UPDATE OE_LINES_IFACE_ALL c
          SET ERROR_FLAG = 'Y',
              ATTRIBUTE_STATUS = ATTRIBUTE_STATUS||'014'
    WHERE  c.SHIP_TO_CUSTOMER_ID IS NULL
     AND   c.SHIP_TO_CUSTOMER_NAME IS NOT NULL
     AND   (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id) ;

END;

    -- INVOICE_TO_CUSTOMER
    -- Catch subqry_too_many_rows exception bug 5620045
BEGIN
    UPDATE OE_LINES_IFACE_ALL c
    SET (INVOICE_TO_CUSTOMER_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
        (SELECT b.CUST_ACCOUNT_ID,
               DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
               DECODE(b.CUST_ACCOUNT_ID,NULL,
                      d.ATTRIBUTE_STATUS||'015',d.ATTRIBUTE_STATUS)
        FROM HZ_CUST_ACCOUNTS b, OE_LINES_IFACE_ALL d
        WHERE d.INVOICE_TO_CUSTOMER_NUMBER IS NOT NULL
          AND d.INVOICE_TO_CUSTOMER_NUMBER = b.ACCOUNT_NUMBER(+)
          AND b.STATUS(+) = 'A'
          AND d.rowid = c.rowid
        UNION ALL
        SELECT b.CUST_ACCOUNT_ID,
               DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
               DECODE(b.CUST_ACCOUNT_ID,NULL,
                      d.ATTRIBUTE_STATUS||'015',d.ATTRIBUTE_STATUS)
        FROM HZ_CUST_ACCOUNTS b, HZ_PARTIES e, OE_LINES_IFACE_ALL d
        WHERE d.INVOICE_TO_CUSTOMER_NUMBER IS NULL
          AND d.INVOICE_TO_CUSTOMER_NAME = e.PARTY_NAME(+)
          AND b.STATUS(+) = 'A'
          AND b.PARTY_ID(+) = e.PARTY_ID
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.INVOICE_TO_CUSTOMER_ID IS NULL
    AND (c.INVOICE_TO_CUSTOMER_NAME IS NOT NULL OR
         c.INVOICE_TO_CUSTOMER_NUMBER IS NOT NULL);
EXCEPTION
  WHEN subqry_too_many_rows THEN
    UPDATE OE_LINES_IFACE_ALL c
          SET ERROR_FLAG = 'Y',
              ATTRIBUTE_STATUS = ATTRIBUTE_STATUS||'015'
    WHERE  (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.INVOICE_TO_CUSTOMER_ID IS NULL
    AND c.INVOICE_TO_CUSTOMER_NAME IS NOT NULL ;
END;

  END IF;

  -- SHIP_TO_ORG

    UPDATE OE_LINES_IFACE_ALL c
    SET (SHIP_TO_ORG_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
          (SELECT  /*+ PUSH_PRED(b) */ b.ORGANIZATION_ID,
               DECODE(b.ORGANIZATION_ID,NULL,'Y',NULL),
               DECODE(b.ORGANIZATION_ID,NULL,
                      d.ATTRIBUTE_STATUS||'014',d.ATTRIBUTE_STATUS)
          FROM OE_SHIP_TO_ORGS_V b, OE_LINES_IFACE_ALL d
          WHERE d.ship_to_address1 = ADDRESS_LINE_1(+)
          AND nvl(d.ship_to_address2,'NIL') = NVL(ADDRESS_LINE_2(+),'NIL')
          AND nvl(d.ship_to_address3,'NIL') = nvl(ADDRESS_LINE_3(+),'NIL')
          --AND nvl(d.ship_to_address4,'NIL') = ADDRESS_LINE_4
          AND nvl(d.ship_to_city,'NIL') = nvl(town_or_city(+),'NIL')
          AND nvl(d.ship_to_state,'NIL') = nvl(state(+),'NIL')
          AND nvl(d.ship_to_postal_code,'NIL') = nvl(postal_code(+),'NIL')
          AND nvl(d.ship_to_country,'NIL') = nvl(country(+),'NIL')
          AND nvl(STATUS(+),'A') = 'A'
          AND b.CUSTOMER_ID(+) = nvl(d.SHIP_TO_CUSTOMER_ID,d.SOLD_TO_ORG_ID)
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.SHIP_TO_ORG_ID IS NULL
    AND (c.SHIP_TO_ADDRESS1 IS NOT NULL
        OR c.ship_to_address2 IS NOT NULL
        OR c.ship_to_address3 IS NOT NULL
        OR c.ship_to_address4 IS NOT NULL
        OR c.ship_to_org IS NOT NULL
        );

  -- INVOICE_TO_ORG

    UPDATE OE_LINES_IFACE_ALL c
    SET (INVOICE_TO_ORG_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
          (SELECT  /*+ PUSH_PRED(b) */ b.ORGANIZATION_ID,
               DECODE(b.ORGANIZATION_ID,NULL,'Y',NULL),
               DECODE(b.ORGANIZATION_ID,NULL,
                      d.ATTRIBUTE_STATUS||'015',d.ATTRIBUTE_STATUS)
          FROM OE_INVOICE_TO_ORGS_V b, OE_LINES_IFACE_ALL d
          WHERE d.invoice_to_address1 = ADDRESS_LINE_1(+)
          AND nvl(d.invoice_to_address2,'NIL') = NVL(ADDRESS_LINE_2(+),'NIL')
          AND nvl(d.invoice_to_address3,'NIL') = nvl(ADDRESS_LINE_3(+),'NIL')
          --AND nvl(d.invoice_to_address4,'NIL') = ADDRESS_LINE_4
          AND nvl(d.invoice_to_city,'NIL') = nvl(town_or_city(+),'NIL')
          AND nvl(d.invoice_to_state,'NIL') = nvl(state(+),'NIL')
          AND nvl(d.invoice_to_postal_code,'NIL') = nvl(postal_code(+),'NIL')
          AND nvl(d.invoice_to_country,'NIL') = nvl(country(+),'NIL')
          AND nvl(STATUS(+),'A') = 'A'
          AND b.CUSTOMER_ID(+) = nvl(d.INVOICE_TO_CUSTOMER_ID,d.SOLD_TO_ORG_ID)
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.INVOICE_TO_ORG_ID IS NULL
    AND (c.invoice_to_address1 IS NOT NULL
        OR c.invoice_to_address2 IS NOT NULL
        OR c.invoice_to_address3 IS NOT NULL
        OR c.invoice_to_address4 IS NOT NULL
        OR c.invoice_to_org IS NOT NULL
        );


-- SHIP_TO_CONTACT                          VARCHAR2(30)

    UPDATE OE_LINES_IFACE_ALL c
    SET (SHIP_TO_CONTACT_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT Get_Contact_ID(c.SHIP_TO_CONTACT,c.SHIP_TO_ORG_ID),
               DECODE(Get_Contact_ID(c.SHIP_TO_CONTACT,c.SHIP_TO_ORG_ID),NULL,'Y',NULL),
               DECODE(Get_Contact_ID(c.SHIP_TO_CONTACT,c.SHIP_TO_ORG_ID),NULL,
                      c.ATTRIBUTE_STATUS||'017',c.ATTRIBUTE_STATUS)
        FROM DUAL
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.SHIP_TO_CONTACT_ID IS NULL
    AND c.SHIP_TO_CONTACT IS NOT NULL;


-- INVOICE_TO_CONTACT                       VARCHAR2(30)

    UPDATE OE_LINES_IFACE_ALL c
    SET (INVOICE_TO_CONTACT_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT Get_Contact_ID(c.INVOICE_TO_CONTACT,c.INVOICE_TO_ORG_ID),
               DECODE(Get_Contact_ID(c.INVOICE_TO_CONTACT,c.INVOICE_TO_ORG_ID),NULL,'Y',NULL),
               DECODE(Get_Contact_ID(c.INVOICE_TO_CONTACT,c.INVOICE_TO_ORG_ID),NULL,
                      c.ATTRIBUTE_STATUS||'018',c.ATTRIBUTE_STATUS)
        FROM DUAL
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.INVOICE_TO_CONTACT_ID IS NULL
    AND c.INVOICE_TO_CONTACT IS NOT NULL;


-- DELIVER_TO_CONTACT                       VARCHAR2(30)

    UPDATE OE_LINES_IFACE_ALL c
    SET (DELIVER_TO_CONTACT_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT Get_Contact_ID(c.DELIVER_TO_CONTACT,c.DELIVER_TO_ORG_ID),
               DECODE(Get_Contact_ID(c.DELIVER_TO_CONTACT,c.DELIVER_TO_ORG_ID),NULL,'Y',NULL),
               DECODE(Get_Contact_ID(c.DELIVER_TO_CONTACT,c.DELIVER_TO_ORG_ID),NULL,
                      c.ATTRIBUTE_STATUS||'019',c.ATTRIBUTE_STATUS)
        FROM DUAL
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.DELIVER_TO_CONTACT_ID IS NULL
    AND c.DELIVER_TO_CONTACT IS NOT NULL;

-- COMMITMENT - Not supported for BULK!


-- SHIPMENT_PRIORITY_CODE

    UPDATE OE_LINES_IFACE_ALL c
    SET (SHIPMENT_PRIORITY_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'023',c.ATTRIBUTE_STATUS)
        FROM OE_LOOKUPS b, OE_LINES_IFACE_ALL d
        WHERE d.SHIPMENT_PRIORITY = b.MEANING(+)
          AND b.LOOKUP_TYPE(+) = 'SHIPMENT_PRIORITY'
          AND b.enabled_flag(+) = 'Y'
          AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.SHIPMENT_PRIORITY_CODE IS NULL
    AND c.SHIPMENT_PRIORITY IS NOT NULL;


-- DEMAND_BUCKET_TYPE: No value to ID conversion in OEXSVIDB.pls

-- SHIPPING_METHOD_CODE                         VARCHAR2(30)
    UPDATE OE_LINES_IFACE_ALL c
    SET (SHIPPING_METHOD_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'024',c.ATTRIBUTE_STATUS)
        FROM OE_SHIP_METHODS_V b, OE_LINES_IFACE_ALL d
        WHERE d.SHIPPING_METHOD = b.MEANING(+)
          AND b.enabled_flag(+) = 'Y'
          AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.SHIPPING_METHOD_CODE IS NULL
    AND c.SHIPPING_METHOD IS NOT NULL;

-- FREIGHT_CARRIER_CODE: value column does not exist on interface tables

-- INTERMED_SHIP_TO_CONTACT_ID: no columns on interface tables

-- INTERMED_SHIP_TO_ORG_ID: no columns on interface tables

-- INVENTORY_ITEM: Value to ID conversion in OEBLLINB, Get_Item_Info

-- ITEM_TYPE_CODE: Not needed - this is an INTERNAL field!

-- OVER_SHIP_REASON: Not applicable to order creation.

-- RETURN_REASON: Not supported for BULK!

-- COMMITMENT_ID: Not supported for BULK!

-- RLA_SCHEDULE_TYPE, VEH_CUS_ITEM_CUM_KEY: No Value to ID conversion in OEXSVIDB.pls!

-- SHIP_FROM_ORG_ID: No Value to ID conversion in OEXSVIDB.pls!

-- PROJECT_ID, TASK_ID: No Value to ID conversion in OEXSVIDB.pls!

-- TAX_EXEMPT_FLAG: Value column does not exist on interface tables

-- TAX_POINT_CODE: Unused column

--{Bug 5054618
--End customer changes for HVOP
-- bug 5620045
-- Catch subqry_too_many_rows exception and add additional where clause
-- to update only the records in the current batch

BEGIN
UPDATE OE_LINES_IFACE_ALL c
 SET (END_CUSTOMER_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
 (SELECT b.CUST_ACCOUNT_ID,
  DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
  DECODE(b.CUST_ACCOUNT_ID,NULL,
  d.ATTRIBUTE_STATUS||'025',d.ATTRIBUTE_STATUS)
    FROM HZ_CUST_ACCOUNTS b, OE_LINES_IFACE_ALL d
   WHERE d.END_CUSTOMER_NUMBER IS NOT NULL
     AND d.END_CUSTOMER_NUMBER = b.ACCOUNT_NUMBER(+)
   AND b.STATUS(+) = 'A'  AND d.rowid = c.rowid
   UNION ALL
  SELECT b.CUST_ACCOUNT_ID,
   DECODE(b.CUST_ACCOUNT_ID,NULL,'Y',NULL),
   DECODE(b.CUST_ACCOUNT_ID,NULL,
   d.ATTRIBUTE_STATUS||'025',d.ATTRIBUTE_STATUS)
    FROM HZ_CUST_ACCOUNTS b, HZ_PARTIES e, OE_LINES_IFACE_ALL d
   WHERE d.END_CUSTOMER_NUMBER IS NULL
     AND d.END_CUSTOMER_NAME = e.PARTY_NAME(+)
     AND b.STATUS(+) = 'A'  AND b.PARTY_ID(+) = e.PARTY_ID
     AND d.rowid = c.rowid)
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
      AND   c.END_CUSTOMER_ID IS NULL
      AND  (c.END_CUSTOMER_NAME IS NOT NULL
         OR c.END_CUSTOMER_NUMBER IS NOT NULL);
EXCEPTION
  WHEN subqry_too_many_rows THEN
    UPDATE OE_LINES_IFACE_ALL c
          SET ERROR_FLAG = 'Y',
              ATTRIBUTE_STATUS = ATTRIBUTE_STATUS||'025'
    WHERE  (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
      AND   c.END_CUSTOMER_ID IS NULL
      AND   c.END_CUSTOMER_NAME IS NOT NULL ;

END;


--bug 5620045 added additional where clause to update records in current
--batch
UPDATE OE_LINES_IFACE_ALL c
 SET (END_CUSTOMER_CONTACT_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
      (SELECT
       Get_End_customer_Contact_ID(c.END_CUSTOMER_CONTACT,c.END_CUSTOMER_ID),
       DECODE(Get_End_customer_Contact_ID(c.END_CUSTOMER_CONTACT,
                                         c.END_CUSTOMER_ID),NULL,'Y',NULL),
       DECODE(Get_End_customer_Contact_ID(c.END_CUSTOMER_CONTACT,
                                          c.END_CUSTOMER_ID),NULL,
              c.ATTRIBUTE_STATUS||'026',c.ATTRIBUTE_STATUS)
       FROM DUAL)
WHERE  (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
   AND c.END_CUSTOMER_CONTACT_ID IS NULL
   AND c.END_CUSTOMER_CONTACT IS NOT NULL;



UPDATE OE_LINES_IFACE_ALL c
     SET (END_CUSTOMER_SITE_USE_ID,ERROR_FLAG,ATTRIBUTE_STATUS)=
	 (SELECT END_CUSTOMER_SITE(c.end_customer_address1,
                c.end_customer_address2,c.end_customer_address3,
                c.end_customer_address4,c.end_customer_location, NULL,
                c.end_customer_id,c.end_customer_city, c.end_customer_state,
                c.end_customer_postal_code,c.end_customer_country,NULL),
		DECODE(END_CUSTOMER_SITE(c.end_customer_address1,
                        c.end_customer_address2,c.end_customer_address3,
                        c.end_customer_address4,c.end_customer_location,NULL,
			c.end_customer_id,c.end_customer_city,
                        c.end_customer_state, c.end_customer_postal_code,
                        c.end_customer_country, NULL),NULL,'Y',NULL),
		DECODE(END_CUSTOMER_SITE(c.end_customer_address1,
					 c.end_customer_address2,
					 c.end_customer_address3,
					 c.end_customer_address4,
					 c.end_customer_location,
					 NULL,
					 c.end_customer_id,
					 c.end_customer_city,
					 c.end_customer_state,
					 c.end_customer_postal_code,
					 c.end_customer_country,
					 NULL),
                       NULL,c.ATTRIBUTE_STATUS||'027',c.ATTRIBUTE_STATUS)
       FROM DUAL)
   WHERE  (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
     AND  c.END_CUSTOMER_SITE_USE_ID IS NULL AND c.END_CUSTOMER_ID IS NOT NULL
     AND (c.END_CUSTOMER_ADDRESS1 IS NOT NULL
	  OR c.END_CUSTOMER_ADDRESS2 IS NOT NULL
	  OR c.END_CUSTOMER_ADDRESS3 IS NOT NULL
	  OR c.END_CUSTOMER_ADDRESS4 IS NOT NULL);



-- Bug 5054618}
UPDATE OE_LINES_IFACE_ALL c
    SET (IB_OWNER_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'028',c.ATTRIBUTE_STATUS)
        FROM -- OE_LOOKUPS b,
	     ( select lookup_code, meaning
	       from OE_LOOKUPS
	       where lookup_type In ('ITEM_OWNER', 'ONT_INSTALL_BASE')
	       and enabled_flag = 'Y'
	       and SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
			AND NVL(END_DATE_ACTIVE, SYSDATE) )   b,
	OE_LINES_IFACE_ALL d
        WHERE d.IB_OWNER = b.MEANING(+)
          --AND ( b.LOOKUP_TYPE(+) = 'ITEM_OWNER'
          --OR b.LOOKUP_TYPE(+) = 'ONT_INSTALL_BASE' )
          --AND b.enabled_flag(+) = 'Y'
          --AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
          --            AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
	  AND rownum = 1
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.IB_OWNER_CODE IS NULL
    AND c.IB_OWNER IS NOT NULL;


UPDATE OE_LINES_IFACE_ALL c
    SET (IB_INSTALLED_AT_LOCATION_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'029',c.ATTRIBUTE_STATUS)
        FROM -- OE_LOOKUPS b,
	     ( select lookup_code, meaning
	       from OE_LOOKUPS
	       where lookup_type In ('ITEM_INSTALL_LOCATION', 'ONT_INSTALL_BASE')
	       and enabled_flag = 'Y'
	       and SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
			AND NVL(END_DATE_ACTIVE, SYSDATE) )   b,
	OE_LINES_IFACE_ALL d
        WHERE d.IB_INSTALLED_AT_LOCATION = b.MEANING(+)
          --AND ( b.LOOKUP_TYPE(+) = 'ITEM_INSTALL_LOCATION'
          --OR b.LOOKUP_TYPE(+) = 'ONT_INSTALL_BASE' )
          --AND b.enabled_flag(+) = 'Y'
          --AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
          --            AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
	  AND rownum = 1
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
    AND c.IB_INSTALLED_AT_LOCATION_CODE IS NULL
    AND c.IB_INSTALLED_AT_LOCATION IS NOT NULL;

UPDATE OE_LINES_IFACE_ALL c
    SET (IB_CURRENT_LOCATION_CODE,ERROR_FLAG,ATTRIBUTE_STATUS)=
       (SELECT b.LOOKUP_CODE,
               DECODE(b.LOOKUP_CODE,NULL,'Y',NULL),
               DECODE(b.LOOKUP_CODE,NULL,
                      c.ATTRIBUTE_STATUS||'030',c.ATTRIBUTE_STATUS)
        FROM -- OE_LOOKUPS b,
	     ( select lookup_code, meaning
	       from OE_LOOKUPS
	       where lookup_type In ('ITEM_CURRENT_LOCATION', 'ONT_INSTALL_BASE')
	       and enabled_flag = 'Y'
	       and SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
			AND NVL(END_DATE_ACTIVE, SYSDATE) )   b,
		OE_LINES_IFACE_ALL d
        WHERE d.IB_CURRENT_LOCATION = b.MEANING(+)
          --AND ( b.LOOKUP_TYPE(+) = 'ITEM_CURRENT_LOCATION'
          --OR b.LOOKUP_TYPE(+) = 'ONT_INSTALL_BASE' )
          --AND b.enabled_flag(+) = 'Y'
          --AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
          --            AND NVL(END_DATE_ACTIVE, SYSDATE)
          AND d.rowid = c.rowid
	  AND rownum = 1
        )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
     AND c.IB_CURRENT_LOCATION_CODE IS NULL
    AND c.IB_CURRENT_LOCATION IS NOT NULL;


EXCEPTION
    WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OTHERS ERROR , OE_BULK_VALUE_TO_ID.LINES' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
     END IF;
     OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Lines'
        );
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Lines;


---------------------------------------------------------------------
-- PROCEDURE Adjustments
--
-- Value to ID conversions on adjustments interface table.
-- This procedure also does pre-processing/entity validation for
-- adjustments.
---------------------------------------------------------------------

PROCEDURE Adjustments(p_batch_id  IN NUMBER)
IS
l_msg_text           VARCHAR2(2000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- Value to ID conversions for adjustments
    -- List Header ID, List Line ID

    UPDATE OE_PRICE_ADJS_INTERFACE a
    SET (LIST_HEADER_ID, ERROR_FLAG) =
          (SELECT b.list_header_id
                  , decode(b.list_header_id,NULL,'Y',NULL)
           FROM QP_LIST_HEADERS_TL b
           WHERE b.NAME = a.list_name
             AND b.LANGUAGE = userenv('LANG')
             AND nvl(b.VERSION_NO,'x')  = nvl(a.version_number,'x')
           )
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
      AND a.LIST_HEADER_ID IS NULL
      AND a.LIST_NAME IS NOT NULL;

    UPDATE OE_PRICE_ADJS_INTERFACE a
    SET (LIST_LINE_ID, LIST_LINE_TYPE_CODE, ERROR_FLAG) =
          (SELECT b.list_line_id
                  , b.list_line_type_code
                  , decode(b.list_line_id,NULL,'Y',NULL)
           FROM QP_LIST_LINES b
           WHERE b.LIST_HEADER_ID = a.LIST_HEADER_ID
             AND b.LIST_LINE_NO = a.LIST_LINE_NUMBER)
    WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
      AND a.LIST_LINE_ID IS NULL
      AND a.LIST_HEADER_ID IS NOT NULL
      AND a.LIST_LINE_NUMBER IS NOT NULL;


   -- Entity Level Validations for Adjustments

   l_msg_text := FND_MESSAGE.GET_STRING('ONT','OE_BULK_NOT_SUPP_ADJ_ATTRIBS');

   INSERT INTO OE_PROCESSING_MSGS
   ( request_id ,entity_code ,entity_ref ,entity_id ,header_id
     ,line_id ,order_source_id ,original_sys_document_ref
     ,original_sys_document_line_ref ,orig_sys_shipment_ref ,change_sequence
     ,source_document_type_id ,source_document_id ,source_document_line_id
     ,attribute_code ,creation_date ,created_by ,last_update_date
     ,last_updated_by ,last_update_login ,program_application_id ,program_id
     ,program_update_date ,process_activity ,notification_flag ,type
     ,message_source_code ,language ,message_text, transaction_id
    )
    SELECT
     a.request_id,decode(orig_sys_line_ref,NULL,'HEADER_ADJ','LINE_ADJ'),NULL ,NULL ,NULL
     ,NULL, a.order_source_id ,a.orig_sys_document_ref, a.orig_sys_line_ref ,NULL
     ,a.change_sequence ,NULL ,NULL ,NULL ,'LIST_LINE_TYPE_CODE'
     ,sysdate ,FND_GLOBAL.USER_ID ,sysdate ,FND_GLOBAL.USER_ID
     ,FND_GLOBAL.CONC_LOGIN_ID ,660 ,NULL ,NULL ,NULL ,NULL ,NULL
     ,'C' ,USERENV('LANG') ,l_msg_text, OE_MSG_ID_S.NEXTVAL
    FROM OE_PRICE_ADJS_INTERFACE a, OE_HEADERS_IFACE_ALL h
    WHERE h.batch_id = p_batch_id
      AND a.order_source_id = h.order_source_id
      AND a.orig_sys_document_ref = h.orig_sys_document_ref
      AND (a.list_line_type_code NOT IN ('DIS','FREIGHT_CHARGE','SUR','PBH')
          OR (a.list_header_id IS NULL OR a.list_line_id IS NULL));

    IF OE_Bulk_Validate.g_error_count = 0 THEN
       IF SQL%ROWCOUNT > 0 THEN
          OE_Bulk_Validate.g_error_count := 1;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'THE ERROR COUNT IS SET' ) ;
          END IF;
       END IF;
    END IF;

EXCEPTION
   WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OTHERS ERROR , OE_BULK_VALUE_TO_ID.ADJUSTMENTS' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
     END IF;
     OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Adjustments'
        );
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Adjustments;


---------------------------------------------------------------------
-- PROCEDURE Insert_Error_Messages
--
-- Following procedure will check the attribute_status from the interface table
-- and will create records in OE_PROCESSING_MSGS for errored records.The
-- attribute for which the value_to_id conversion failed will be marked with a
-- specific number in attribute_status column for every record in the interface
-- tables.
---------------------------------------------------------------------

PROCEDURE INSERT_ERROR_MESSAGES(p_batch_id NUMBER)
IS

CURSOR C_ERR IS
  SELECT request_id ,
       order_source_id ,
       orig_sys_document_ref ,
       orig_sys_line_ref,
       orig_sys_shipment_ref ,
       change_sequence,
       attribute_status
  FROM OE_LINES_IFACE_ALL
  WHERE (order_source_id, orig_sys_document_ref) IN
                   ( SELECT order_source_id, orig_sys_document_ref
                     FROM OE_HEADERS_IFACE_ALL
                     WHERE batch_id = p_batch_id)
  AND attribute_status IS NOT NULL
  UNION
  SELECT request_id ,
       order_source_id ,
       orig_sys_document_ref ,
       NULL,
       NULL ,
       change_sequence,
       attribute_status
  FROM OE_HEADERS_IFACE_ALL
  WHERE batch_id = p_batch_id
  AND attribute_status IS NOT NULL;

l_counter   NUMBER :=0;
l_first     NUMBER :=0;
l_attribute VARCHAR2(30);
l_attribute_name  VARCHAR2(240);
l_substr    VARCHAR2(3);
l_msg_text  VARCHAR2(2000);
l_msg_data  VARCHAR2(2000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_msg_data := FND_MESSAGE.GET_STRING('ONT','OE_BULK_VALUE_TO_ID_ERROR');

    FOR l_err in C_ERR LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ATTR STATUS :'||L_ERR.ATTRIBUTE_STATUS ) ;
        END IF;
        l_counter := LENGTH(l_err.attribute_status)/3;
        IF l_counter < 1 THEN
            GOTO END_OF_LOOP;
        END IF;

        l_first := 1;
        FOR i IN 1..l_counter LOOP

            l_substr := SUBSTR(l_err.attribute_status,l_first,3);

            IF l_substr = '001' THEN
                l_attribute := 'ORDER_SOURCE_ID';
            ELSIF l_substr = '002' THEN
                l_attribute := 'ORDER_TYPE_ID';
            ELSIF l_substr = '003' THEN
                l_attribute := 'PRICE_LIST_ID';
            ELSIF l_substr = '004' THEN
                l_attribute := 'CONVERSION_TYPE_CODE';
            ELSIF l_substr = '005' THEN
                l_attribute := 'SALESREP_ID';
            ELSIF l_substr = '006' THEN
                l_attribute := 'TAX_EXEMPT_REASON_CODE';
            ELSIF l_substr = '007' THEN
                l_attribute := 'AGREEMENT_ID';
            ELSIF l_substr = '008' THEN
                l_attribute := 'INVOICING_RULE_ID';
            ELSIF l_substr = '009' THEN
                l_attribute := 'ACCOUNTING_RULE_ID';
            ELSIF l_substr = '010' THEN
                l_attribute := 'PAYMENT_TERM_ID';
            ELSIF l_substr = '011' THEN
                l_attribute := 'FREIGHT_TERMS_CODE';
            ELSIF l_substr = '012' THEN
                l_attribute := 'FOB_POINT_CODE';
            ELSIF l_substr = '013' THEN
                l_attribute := 'SOLD_TO_ORG_ID';
            ELSIF l_substr = '014' THEN
                l_attribute := 'SHIP_TO_ORG_ID';
            ELSIF l_substr = '015' THEN
                l_attribute := 'INVOICE_TO_ORG_ID';
            ELSIF l_substr = '016' THEN
                l_attribute := 'SOLD_TO_CONTACT_ID';
            ELSIF l_substr = '017' THEN
                l_attribute := 'SHIP_TO_CONTACT_ID';
            ELSIF l_substr = '018' THEN
                l_attribute := 'INVOICE_TO_CONTACT_ID';
            ELSIF l_substr = '019' THEN
                l_attribute := 'DELIVER_TO_CONTACT_ID';
            ELSIF l_substr = '020' THEN
                l_attribute := 'LINE_TYPE_ID';
            ELSIF l_substr = '021' THEN
                l_attribute := 'COMMITMENT_ID';
            ELSIF l_substr = '022' THEN
                l_attribute := 'SALES_CHANNEL_CODE';
            ELSIF l_substr = '023' THEN
                l_attribute := 'SHIPMENT_PRIORITY_CODE';
            ELSIF l_substr = '024' THEN
                l_attribute := 'SHIPPING_METHOD_CODE';
	    ELSIF l_substr = '025' THEN  -- end customer changes(Bug 5054618)
	       l_attribute := 'END_CUSTOMER_ID';
            ELSIF l_substr = '026' THEN
	       l_attribute := 'END_CUSTOMER_CONTACT_ID';
            ELSIF l_substr = '028' THEN
	       l_attribute := 'END_CUSTOMER_SITE_USE_ID';
            END IF;

            l_attribute_name := OE_ORDER_UTIL.Get_Attribute_Name(l_attribute);

            l_msg_text := l_msg_data|| ' '||l_attribute_name;

            INSERT INTO OE_PROCESSING_MSGS
            ( request_id ,entity_code ,entity_ref ,entity_id ,header_id
              ,line_id ,order_source_id ,original_sys_document_ref
              ,original_sys_document_line_ref ,orig_sys_shipment_ref
              ,change_sequence ,source_document_type_id ,source_document_id
              ,source_document_line_id ,attribute_code ,creation_date
              ,created_by ,last_update_date ,last_updated_by ,last_update_login
              ,program_application_id ,program_id ,program_update_date
              ,process_activity ,notification_flag ,type ,message_source_code
              ,language ,message_text, transaction_id
             )
            VALUES
            ( l_err.request_id,DECODE(l_err.ORIG_SYS_LINE_REF,NULL,'HEADER','LINE')
              , NULL ,NULL ,NULL ,NULL ,l_err.order_source_id
              , l_err.orig_sys_document_ref , l_err.ORIG_SYS_LINE_REF
              , l_err.orig_sys_shipment_ref , l_err.change_sequence ,NULL ,NULL
              , NULL ,l_attribute, sysdate ,FND_GLOBAL.USER_ID ,sysdate
              , FND_GLOBAL.USER_ID ,FND_GLOBAL.CONC_LOGIN_ID ,660 ,NULL ,NULL
              , NULL ,NULL ,NULL ,'C' ,USERENV('LANG')
              , l_msg_text, OE_MSG_ID_S.NEXTVAL
            );

            l_first := l_first + 3;

            OE_BULK_VALIDATE.G_ERROR_COUNT := 1;

        END LOOP;
        <<END_OF_LOOP>>
        NULL;
    END LOOP;

EXCEPTION
   WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OTHERS ERROR , OE_BULK_VALUE_TO_ID.INSERT_ERROR_MESSAGES' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
     END IF;
     OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'INSERT_ERROR_MESSAGES'
        );
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END INSERT_ERROR_MESSAGES;

END OE_Bulk_Value_To_Id;

/
