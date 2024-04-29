--------------------------------------------------------
--  DDL for Package Body OE_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_GLOBALS" AS
/* $Header: OEXSGLBB.pls 120.6.12010000.2 2009/12/08 13:11:21 msundara ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Oe_Globals';

--  Procedure Get_Entities_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  entity constants.
--
--  DO NOT REMOVE

PROCEDURE Get_Entities_Tbl
IS
I                             NUMBER:=0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    FND_API.g_entity_tbl.DELETE;

--  START GEN entities
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'ALL';

/* Order Object Entities: Begin */

    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'HEADER';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'HEADER_ADJ';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'HEADER_SCREDIT';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'LINE';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'LINE_ADJ';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'LINE_SCREDIT';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'LOT_SERIAL';

/* Order Object Entities: End */

/* Pricing Contract Object Entities: Begin */

    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'CONTRACT';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'AGREEMENT';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'PRICE_LHEADER';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'DISCOUNT_HEADER';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'PRICE_LLINE';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'DISCOUNT_CUST';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'DISCOUNT_LINE';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'PRICE_BREAK';

/* Pricing Contract Object Entities: End */

/* Charge Object Entities: Begin */
    I := I + 1;
    FND_API.g_entity_tbl(I).name := 'CHARGE_LINE';
/* Charge Object Entities: End */

/* Customer and Item Settings Object Entities: Begin */
    I := I + 1;
    FND_API.g_entity_tbl(I).name := 'CUST_ITEM_SET';
/* Charge Object Entities: End */

--  END GEN entities

END Get_Entities_Tbl;

--  Initialize control record.

FUNCTION Init_Control_Rec
(   p_operation                     IN  VARCHAR2
,   p_control_rec                   IN  Control_Rec_Type
)RETURN Control_Rec_Type
IS
l_control_rec                 Control_Rec_Type;
BEGIN

    IF p_control_rec.controlled_operation
	 AND p_control_rec.Private_Call THEN

	l_control_rec := p_control_rec;

	-- If there are mixed operations in a single call to process order
	-- e.g. updating a header and inserting a line for this same header,
	-- then the clear_dependents should be TRUE for header but
	-- clear_dependents should be FALSE for line. Since process order
	-- accepts one control record per call, the user cannot set it
	-- based on the operation.
	-- Therefore, even if the operation is controlled, set the
	-- clear_dependents flag based on the operation
	-- NEW(03/01/2000): BUT set it only if operation is CREATE as
	-- private callers may want to set clear_dependents to FALSE even
	-- if operation is UPDATE for performance reasons
	-- From the UI (sales order form), this setting is overridden
	-- as form calls with clear_dependents TRUE even for CREATE
	-- operation as the user changes attributes (e.g. enters an item
	-- , the attributes dependent on item should be cleared) and
	-- the record is not yet posted.
	IF (p_control_rec.default_attributes) THEN

	   IF NOT (OE_GLOBALS.G_UI_FLAG) THEN

	    IF p_operation = G_OPR_CREATE THEN
		 l_control_rec.clear_dependents := FALSE;
	    END IF;

	   END IF;

	-- If the clear_dependents flag is TRUE and default_attributes is
	-- FALSE, this could result in corrupted data; dependent fields would
	-- be cleared i.e. set to missing values but since there is no
	-- defaulting, these missing values might be saved to the DB.
	-- Therefore, always set default_attributes to TRUE if clear_dependents
	-- is TRUE.
	ELSIF (p_control_rec.clear_dependents) THEN

		l_control_rec.default_attributes := TRUE;

	END IF;

	RETURN l_control_rec;

    ELSIF  p_operation = G_OPR_NONE OR p_operation IS NULL THEN

        l_control_rec.check_security:=  FALSE;
        l_control_rec.clear_dependents:=  FALSE;
        l_control_rec.default_attributes:=  FALSE;
        l_control_rec.change_attributes :=  FALSE;
        l_control_rec.validate_entity	:=  FALSE;
        l_control_rec.write_to_DB	:=  FALSE;
        l_control_rec.Process_Partial   := FALSE;
        l_control_rec.process		:=  p_control_rec.process;
        l_control_rec.process_entity	:=  p_control_rec.process_entity;
        l_control_rec.request_category	:=  p_control_rec.request_category;
        l_control_rec.request_name	:=  p_control_rec.request_name;
        l_control_rec.clear_api_cache	:=  p_control_rec.clear_api_cache;
        l_control_rec.clear_api_requests:=  p_control_rec.clear_api_requests;
        l_control_rec.org_id := FND_API.G_MISS_NUM;

    ELSIF p_operation = G_OPR_CREATE THEN

        l_control_rec.check_security:=  TRUE;
        l_control_rec.clear_dependents:=  FALSE;
        l_control_rec.default_attributes:=   TRUE;
        l_control_rec.change_attributes :=   TRUE;
        l_control_rec.validate_entity  :=   TRUE;
        l_control_rec.write_to_DB	:=   TRUE;
        l_control_rec.Process_Partial   := FALSE;
        l_control_rec.process		:=   TRUE;
        l_control_rec.process_entity	:=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	:=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;
        l_control_rec.org_id := FND_API.G_MISS_NUM;

    ELSIF p_operation = G_OPR_UPDATE THEN

        l_control_rec.check_security:=  TRUE;
        l_control_rec.clear_dependents:=  TRUE;
        l_control_rec.default_attributes:=   TRUE;
        l_control_rec.change_attributes :=   TRUE;
        l_control_rec.validate_entity	:=   TRUE;
        l_control_rec.write_to_DB	:=   TRUE;
        l_control_rec.Process_Partial   := FALSE;
        l_control_rec.process		:=   TRUE;
        l_control_rec.process_entity	:=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	:=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;
        l_control_rec.org_id := FND_API.G_MISS_NUM;

    ELSIF p_operation = G_OPR_DELETE THEN

        l_control_rec.check_security:=  TRUE;
        l_control_rec.clear_dependents:=  FALSE;
        l_control_rec.default_attributes:=   FALSE;
        l_control_rec.change_attributes :=   FALSE;
        l_control_rec.validate_entity	  :=   TRUE;
        l_control_rec.write_to_DB	  :=   TRUE;
        l_control_rec.Process_Partial   := FALSE;
        l_control_rec.process		  :=   TRUE;
        l_control_rec.process_entity	  :=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	  :=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;
        l_control_rec.org_id := FND_API.G_MISS_NUM;

    ELSE

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Init_Control_Rec'
            ,   'Invalid operation'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    IF p_control_rec.controlled_operation AND
	NOT p_control_rec.Private_Call THEN
		l_control_rec.org_id := p_control_rec.org_id;
	     l_control_rec.process_partial := p_control_rec.process_partial;
    END IF;

    RETURN l_control_rec;

END Init_Control_Rec;


-- following constants are used to debug lock_order,
-- please do not use them for any other purpose.
-- G_LOCK_CONST and G_LOCK_TEST

--  Function Equal
--  Number comparison.

FUNCTION Equal
(   p_attribute1                    IN  NUMBER
,   p_attribute2                    IN  NUMBER
)RETURN BOOLEAN
IS
BEGIN

    IF G_LOCK_TEST = 'Y' THEN
      G_LOCK_CONST := G_LOCK_CONST + 1;

      IF NOT (( p_attribute1 IS NULL AND p_attribute2 IS NULL ) OR
        ( p_attribute1 IS NOT NULL AND
          p_attribute2 IS NOT NULL AND
          p_attribute1 = p_attribute2 )) THEN
        IF oe_debug_pub.g_debug_level  > 0 THEN
            oe_debug_pub.add(  'LOCK COMPARISON FAILED: '|| G_LOCK_CONST , 1 ) ;
        END IF;
      END IF;
      RETURN TRUE;

    ELSE
      IF p_attribute1 IS NULL THEN
         IF p_attribute2 IS NULL THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      ELSE
         IF p_attribute2 IS NULL THEN
            RETURN FALSE;
         ELSE
            RETURN (p_attribute1 = p_attribute2);
         END IF;
      END IF;
    END IF;

END Equal;

--  Varchar2 comparison.

FUNCTION Equal
(   p_attribute1                    IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
)RETURN BOOLEAN
IS
BEGIN

    IF G_LOCK_TEST = 'Y' THEN
      G_LOCK_CONST := G_LOCK_CONST + 1;

      IF NOT (( p_attribute1 IS NULL AND p_attribute2 IS NULL ) OR
        ( p_attribute1 IS NOT NULL AND
          p_attribute2 IS NOT NULL AND
          p_attribute1 = p_attribute2 )) THEN
        IF oe_debug_pub.g_debug_level  > 0 THEN
            oe_debug_pub.add(  'LOCK COMPARISON FAILED: '|| G_LOCK_CONST , 1 ) ;
        END IF;
      END IF;
      RETURN TRUE;

    ELSE
      IF p_attribute1 IS NULL THEN
         IF p_attribute2 IS NULL THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      ELSE
         IF p_attribute2 IS NULL THEN
            RETURN FALSE;
         ELSE
            RETURN (p_attribute1 = p_attribute2);
         END IF;
      END IF;
    END IF;

END Equal;

--  Date comparison.

FUNCTION Equal
(   p_attribute1                    IN  DATE
,   p_attribute2                    IN  DATE
)RETURN BOOLEAN
IS
BEGIN

    IF G_LOCK_TEST = 'Y' THEN
      G_LOCK_CONST := G_LOCK_CONST + 1;

      IF NOT (( p_attribute1 IS NULL AND p_attribute2 IS NULL ) OR
        ( p_attribute1 IS NOT NULL AND
          p_attribute2 IS NOT NULL AND
          p_attribute1 = p_attribute2 )) THEN
        IF oe_debug_pub.g_debug_level  > 0 THEN
            oe_debug_pub.add(  'LOCK COMPARISON FAILED: '|| G_LOCK_CONST , 1 ) ;
        END IF;
      END IF;
      RETURN TRUE;

    ELSE
      IF p_attribute1 IS NULL THEN
         IF p_attribute2 IS NULL THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      ELSE
         IF p_attribute2 IS NULL THEN
            RETURN FALSE;
         ELSE
            RETURN (p_attribute1 = p_attribute2);
         END IF;
      END IF;
    END IF;

END Equal;

PROCEDURE Set_Context IS
l_org_id NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

/*SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
 SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99) INTO
  l_org_id FROM DUAL;*/

-- MOAC changes
--   l_org_id := to_number(FND_PROFILE.VALUE('ORG_ID'));
  l_org_id := MO_GLOBAL.Get_Current_Org_Id;

  IF l_org_id IS NOT NULL THEN
     OE_GLOBALS.G_ORG_ID :=  l_org_id;
  ELSE
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('OEXSGLBB.pls- Org ID could not be fetched from MO API',5);
     END IF;
     fnd_message.set_name('FND', 'MO_ORG_REQUIRED');
     OE_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
-- MOAC ends

EXCEPTION

	WHEN NO_DATA_FOUND THEN
			-- Not required since dual always returns - Rajeev
			OE_GLOBALS.G_ORG_ID := NULL;

END Set_Context;

FUNCTION CHECK_PRODUCT_INSTALLED
(   p_application_id                IN  NUMBER
)RETURN VARCHAR2
IS
l_status		VARCHAR2(1);
l_industry	VARCHAR2(1);
l_return_val	VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF (fnd_installation.get(p_application_id,p_application_id
                         ,l_status,l_industry)) THEN
	 IF l_status IN ('I', 'S') THEN
	   l_return_val := 'Y';

           /* Fix 1857901: Return iPayment(673) Not Installed for a SHARED Install */
           IF  (p_application_id = 673 and l_status = 'S' )
           or  (p_application_id = 550 and l_status = 'S' )   -- OPM 2547940  Return OPM (550) Not Installed for a SHARED Install
           or  (p_application_id = 603 and l_status = 'S' )   -- Return XDO (603) Not Installed for a SHARED Install
           THEN
             l_return_val := 'N';
           END IF;
      ELSE
	   l_return_val := 'N';
      END IF;
   ELSE
	   l_return_val := 'N';
   END IF;
   RETURN l_return_val;

END CHECK_PRODUCT_INSTALLED;

FUNCTION GET_APPLICATION_ID (p_resp_id IN NUMBER) RETURN NUMBER
IS

l_default_appl_id NUMBER := 660;
l_appl_id NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   SELECT APPLICATION_ID
   INTO   l_appl_id
   FROM   FND_RESPONSIBILITY
   WHERE  RESPONSIBILITY_ID = p_resp_id;

   RETURN l_appl_id;

EXCEPTION

   WHEN OTHERS THEN
        RETURN l_default_appl_id;

END;

FUNCTION GET_FORCE_CLEAR_UI_BLOCK RETURN VARCHAR2 IS
BEGIN
   RETURN OE_GLOBALS.G_FORCE_CLEAR_UI_BLOCK;
END;

PROCEDURE SET_FORCE_CLEAR_UI_BLOCK (ui_block IN VARCHAR2) IS
BEGIN
   OE_GLOBALS.G_FORCE_CLEAR_UI_BLOCK:=ui_block;
END;

FUNCTION Is_Same_Credit_Card
(   p_cc_num_old                    IN  VARCHAR2 DEFAULT NULL
,   p_cc_num_new                    IN  VARCHAR2 DEFAULT NULL
,   p_instrument_id_old              IN  NUMBER DEFAULT NULL
,   p_instrument_id_new              IN  NUMBER DEFAULT NULL
) RETURN BOOLEAN IS

l_exists	VARCHAR2(1) := 'N';
l_hash1_old	VARCHAR2(30);
l_hash2_old	VARCHAR2(30);
l_hash1_new	VARCHAR2(30);
l_hash2_new	VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

	IF l_debug_level > 0 THEN
	    oe_debug_pub.add('Entering Is_Same_Credit_Card Function...');
	    --oe_debug_pub.add('Old card number'||p_cc_num_old);
	    --oe_debug_pub.add('New card number'||p_cc_num_new);
	    oe_debug_pub.add('Old instrument id'||p_instrument_id_old);
	    oe_debug_pub.add('New instrument id2'||p_instrument_id_new);
	END IF;

	IF p_instrument_id_old IS NOT NULL AND p_instrument_id_new IS NOT NULL THEN

	  BEGIN
	    SELECT 'Y'
	    INTO   l_exists
            FROM   iby_creditcard ic1
	    WHERE  ic1.INSTRID = p_instrument_id_new
 	    AND    ic1.cc_number_hash1 = (SELECT cc_number_hash1
				      FROM   iby_creditcard ic2
 				      WHERE  ic2.INSTRID = p_instrument_id_old)
            AND    ic1.cc_number_hash2 = (SELECT cc_number_hash2
                                      FROM   iby_creditcard ic3
                                      WHERE  ic3.INSTRID = p_instrument_id_old);
	    EXCEPTION WHEN NO_DATA_FOUND THEN
	      null;
	  END;

          IF l_exists = 'Y' THEN
     	    RETURN TRUE;
	  ELSE
	    RETURN FALSE;
	  END IF;

	ELSIF p_instrument_id_old IS NOT NULL AND p_instrument_id_new IS NULL THEN
	  IF p_cc_num_new IS NULL THEN
	    RETURN FALSE;

	  ELSE

	    BEGIN
	      SELECT cc_number_hash1, cc_number_hash2
	      INTO   l_hash1_old, l_hash2_old
              FROM   iby_creditcard
	      WHERE  INSTRID = p_instrument_id_old;
	      EXCEPTION WHEN NO_DATA_FOUND THEN
	        null;
	      END;

	      l_hash1_new := iby_security_pkg.get_hash(p_cc_num_new, 'F');
	      l_hash2_new := iby_security_pkg.get_hash(p_cc_num_new, 'T');

	      IF l_hash1_old = l_hash1_new AND l_hash2_old = l_hash2_new THEN
		RETURN TRUE;
	      ELSE
  		RETURN FALSE;
 	      END IF;
	   END IF;

	ELSIF p_instrument_id_old IS NULL AND p_instrument_id_new IS NOT NULL THEN
	  IF p_cc_num_old IS NULL THEN
	    RETURN FALSE;
          ELSE
            BEGIN
            SELECT cc_number_hash1, cc_number_hash2
            INTO   l_hash1_new, l_hash2_new
            FROM   iby_creditcard
            WHERE  INSTRID = p_instrument_id_new;
            EXCEPTION WHEN NO_DATA_FOUND THEN
              null;
            END;

            l_hash1_old := iby_security_pkg.get_hash(p_cc_num_old, 'F');
            l_hash2_old := iby_security_pkg.get_hash(p_cc_num_old, 'T');

            IF l_hash1_old = l_hash1_new AND l_hash2_old = l_hash2_new THEN
              RETURN TRUE;
            ELSE
              RETURN FALSE;
            END IF;
          END IF;

	ELSE
          -- both old and new values are full numbers.
          RETURN Equal(p_cc_num_old, p_cc_num_new);

	END IF;


END Is_Same_Credit_Card;


END Oe_Globals;

/
