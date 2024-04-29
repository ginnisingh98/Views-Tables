--------------------------------------------------------
--  DDL for Package Body OE_HOLDS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HOLDS_PUB" AS
/* $Header: OEXPHLDB.pls 120.10.12010000.22 2012/01/01 18:24:28 slagiset ship $ */

--  Global constant holding the package name

G_PKG_NAME			CONSTANT VARCHAR2(30) := 'OE_Holds_PUB';

PROCEDURE Utilities
(   p_user_id OUT NOCOPY /* file.sql.39 change */ NUMBER)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
p_user_id := NVL(FND_GLOBAL.USER_ID, -1);

END Utilities;


FUNCTION Hold_Site_Code (
                 --ER#7479609 p_hold_entity_id     IN NUMBER
                 p_hold_entity_id     IN oe_hold_sources_all.hold_entity_id%TYPE  --ER#7479609
                       )
  RETURN VARCHAR2
IS
  l_site_use_code  varchar2(30);
  l_hold_site_code varchar2(1);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXPHLDB:IN PROCEDURE HOLD_SITE_CODE' , 1 ) ;
   END IF;
   -- Check to see if the Site code is Bill_to oe Ship_to
   /* Backward compatible view ra_site_uses in following sql is replaced
      by hz_cust_site_uses all for bug 1874065 */
   BEGIN
      SELECT site_use_code
        INTO l_site_use_code
        FROM hz_cust_site_uses              -- Bug 2138398
       WHERE site_use_id = p_hold_entity_id;
   EXCEPTION
        WHEN no_data_found then
             --x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_SITE_USE_ID');
             OE_MSG_PUB.ADD;
             fnd_message.set_token('SITE_USE_ID',
                     to_char(p_hold_entity_id));
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'HOLD_SITE_CODE:INVALID SITE USE ID' , 1 ) ;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
    END;
  IF l_site_use_code = 'BILL_TO' THEN
       l_hold_site_code := 'B';
  ELSE
       l_hold_site_code := 'S';
  END IF;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'HOLD_SITE_CODE , L_HOLD_SITE_CODE:' || L_HOLD_SITE_CODE , 1 ) ;
                          END IF;
 RETURN l_hold_site_code;

END HOLD_SITE_CODE;


/*

*/
PROCEDURE UPDATE_HOLD_COMMENTS (
  p_hold_source_rec     IN  OE_HOLDS_PVT.Hold_Source_Rec_Type,
  x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )

IS
l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_HOLD_COMMENTS';
--
l_org_id number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'IN UPDATE_HOLD_COMMENTS' ) ;
 END IF;

 l_org_id := MO_GLOBAL.get_current_org_id;
 IF l_org_id IS NULL THEN
         -- org_id is null, raise an error.
         oe_debug_pub.add('Org_Id is NULL',1);
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

 x_return_status := FND_API.G_RET_STS_SUCCESS;
 /* Either hold_source_id should be passed in OR
    Hold_entity_code and Hold_entity_id should be passed in */

 If p_hold_source_rec.HOLD_SOURCE_ID is NOT NULL THEN

   UPDATE OE_HOLD_SOURCES
      SET HOLD_COMMENT = p_hold_source_rec.HOLD_COMMENT,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = FND_GLOBAL.user_id
    WHERE HOLD_SOURCE_ID = p_hold_source_rec.HOLD_SOURCE_ID;

 elsif (p_hold_source_rec.HOLD_ENTITY_CODE is NOT NULL AND
        p_hold_source_rec.HOLD_ENTITY_ID is NOT NULL) THEN

   if (p_hold_source_rec.HOLD_ENTITY_CODE2 is NOT NULL AND
       p_hold_source_rec.HOLD_ENTITY_ID2 is NOT NULL) THEN
       UPDATE OE_HOLD_SOURCES
          SET HOLD_COMMENT = p_hold_source_rec.HOLD_COMMENT,
              LAST_UPDATE_DATE = SYSDATE,
              LAST_UPDATED_BY = FND_GLOBAL.user_id
        WHERE HOLD_ENTITY_CODE = p_hold_source_rec.HOLD_ENTITY_CODE
          AND HOLD_ENTITY_ID   = p_hold_source_rec.HOLD_ENTITY_ID
          AND HOLD_ENTITY_CODE2 = p_hold_source_rec.HOLD_ENTITY_CODE2
          AND HOLD_ENTITY_ID2   = p_hold_source_rec.HOLD_ENTITY_ID2
          AND HOLD_ID           = p_hold_source_rec.hold_id
          AND RELEASED_FLAG = 'N'
          AND  NVL(HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE;

   else
       /* Check to see if its a line-level hold */
       if p_hold_source_rec.line_id is not null then
         UPDATE OE_HOLD_SOURCES HS
            SET HS.HOLD_COMMENT = p_hold_source_rec.HOLD_COMMENT,
                HS.LAST_UPDATE_DATE = SYSDATE,
                HS.LAST_UPDATED_BY = FND_GLOBAL.user_id

          WHERE HS.HOLD_ENTITY_CODE = p_hold_source_rec.HOLD_ENTITY_CODE
            AND HS.HOLD_ENTITY_ID   = p_hold_source_rec.HOLD_ENTITY_ID
            AND HS.HOLD_ENTITY_CODE2 is null
            AND HS.HOLD_ENTITY_ID2 is null
            AND HS.HOLD_ID = p_hold_source_rec.hold_id
            AND HS.RELEASED_FLAG = 'N'
            AND  NVL(HS.HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE
            AND exists (SELECT 'x'
                          FROM OE_ORDER_HOLDS OH
                         WHERE OH.LINE_ID = p_hold_source_rec.line_id
                           AND OH.HOLD_SOURCE_ID =  HS.HOLD_SOURCE_ID);
       else
         UPDATE OE_HOLD_SOURCES
            SET HOLD_COMMENT = p_hold_source_rec.HOLD_COMMENT,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATED_BY = FND_GLOBAL.user_id
          WHERE HOLD_ENTITY_CODE = p_hold_source_rec.HOLD_ENTITY_CODE
            AND HOLD_ENTITY_ID   = p_hold_source_rec.HOLD_ENTITY_ID
            AND HOLD_ENTITY_CODE2 is null
            AND HOLD_ENTITY_ID2 is null
            AND HOLD_ID = p_hold_source_rec.hold_id
            AND RELEASED_FLAG = 'N'
            AND NVL(HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE;
       end if;
   end if;

 else
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OE_HOLDS_PUB.UPDATE_HOLD_COMMENTS:' || 'EITHER PASS HOLD_SOURCE_ID OR HOLD_ENTITY_CODE/HOLD_ENTITY_ID' ) ;
          END IF;
            RAISE FND_API.G_EXC_ERROR;
 end if;

EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXPECTED ERROR IN UPDATE_HOLD_COMMENTS ; ' ) ;
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXPECTED ERROR IN UPDATE_HOLD_COMMENTS ; ' ) ;
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXPECTED ERROR IN UPDATE_HOLD_COMMENTS ; ' ) ;
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);


END UPDATE_HOLD_COMMENTS;

/*
  This procedure gets called from the concurrant manager. It will release
  all the holds that have expired.
*/
PROCEDURE RELEASE_EXPIRED_HOLDS
 (
     p_dummy1            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
     p_dummy2            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
     p_org_id            IN   NUMBER
 )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'release_expired_holds';
l_api_version       CONSTANT NUMBER := 1.0;
l_hold_source_id    NUMBER    := 0;

l_hold_source_rec  OE_HOLDS_PVT.hold_source_rec_type;
l_hold_release_rec OE_HOLDS_PVT.Hold_Release_Rec_Type;

l_return_status        VARCHAR2(30);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(240);
l_org_id     number;
l_curr_org_id number;

 CURSOR expired_holds_cur IS
   select hold_source_id, ORG_ID
     from oe_hold_sources
    where HOLD_UNTIL_DATE <= sysdate
      and released_flag = 'N';
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
BEGIN
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'IN RELEASE EXPIRED HOLDS' ) ;
     oe_debug_pub.add(  'p_org_id:' || to_char(p_org_id) ) ;
 END IF;
 l_return_status := FND_API.G_RET_STS_SUCCESS;

 If p_org_id IS Not Null Then
   -- Set Single Org access
   MO_GLOBAL.SET_POLICY_CONTEXT('S', p_org_id);
   l_curr_org_id := p_org_id;
 Else
   MO_GLOBAL.set_policy_context('M', '');
 END IF;


 open expired_holds_cur;
 LOOP
   fetch expired_holds_cur into l_hold_source_id, l_org_id;
   if (expired_holds_cur%notfound) then
      oe_debug_pub.add('Exiting expired_holds_cur%notfound:') ;
      exit;
   end if;
   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('RELEASE EXPIRED HOLD FOR:' || TO_CHAR (L_HOLD_SOURCE_ID)  ||
                      ', ORG ID:' ||  TO_CHAR(l_org_id) );
   END IF;

   if l_org_id <> nvl(l_curr_org_id, -99)
   then
     oe_debug_pub.add('Setting Policy Context for:' || TO_CHAR(l_org_id) ) ;
     MO_GLOBAL.SET_POLICY_CONTEXT('S', l_org_id);
     l_curr_org_id := l_org_id;
     oe_debug_pub.add('MO_GLOBAL.get_current_org_id;:' || to_char(MO_GLOBAL.get_current_org_id));
   End if;

   l_hold_source_rec.hold_source_id    := l_hold_source_id;
   l_hold_release_rec.RELEASE_REASON_CODE := 'EXPIRE';
   l_hold_release_rec.RELEASE_COMMENT     :=
                     'Expired Hold, Automatically Released';

   oe_holds_pvt.Release_Holds(
     p_hold_source_rec     =>  l_hold_source_rec
    ,p_hold_release_rec    =>  l_hold_release_rec
    ,x_return_status       =>  l_return_status
    ,x_msg_count           =>  l_msg_count
    ,x_msg_data            =>  l_msg_data
                  );
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'X_RETURN_STATUS:' || L_RETURN_STATUS , 1 ) ;
   END IF;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'RELEASE_EXPIRED_HOLDS UNEXPECTED FAILURE' ) ;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'RELEASE_EXPIRED_HOLDS EXPECTED FAILURE' ) ;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
   END IF;

 end loop;

   l_return_status := FND_API.G_RET_STS_SUCCESS;
   --  Get message count and data
   OE_MSG_PUB.Count_And_Get
    (   p_count                       => l_msg_count
    ,   p_data                        => l_msg_data
    );

EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        l_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

 WHEN OTHERS THEN
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data);

END release_expired_holds;

----------------------------
PROCEDURE ValidateOrder
(p_header_id 		     IN	NUMBER DEFAULT NULL
, p_line_id		     IN	NUMBER DEFAULT NULL
, p_hold_entity_code 	IN	VARCHAR2
--ER#7479609 , p_hold_entity_id	     IN  	NUMBER
, p_hold_entity_id	     IN  	oe_hold_sources_all.hold_entity_id%TYPE --ER#7479609
, p_hold_entity_code2 	IN	VARCHAR2
--ER#7479609 , p_hold_entity_id2	     IN  	NUMBER
, p_hold_entity_id2	     IN  	oe_hold_sources_all.hold_entity_id2%TYPE  --ER#7479609
, x_return_status	     OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
)
IS
l_api_name 		CONSTANT VARCHAR2(30) := 'ValidateOrder';
l_dummy			VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'IN OE_HOLDS_PUB.VALIDATEORDER' ) ;
END IF;

-- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

   BEGIN

   IF p_line_id IS NOT NULL THEN

	IF p_hold_entity_code = 'O' THEN

		SELECT 'Valid Entity'
		INTO l_dummy
		FROM OE_ORDER_LINES
		WHERE LINE_ID = p_line_id
		 AND HEADER_ID = p_hold_entity_id
                 AND nvl(TRANSACTION_PHASE_CODE,'F') = 'F';

	ELSIF p_hold_entity_code = 'I' THEN

		SELECT 'Valid Entity'
		INTO l_dummy
		FROM OE_ORDER_LINES
		WHERE LINE_ID = p_line_id
		 AND INVENTORY_ITEM_ID = p_hold_entity_id
                 AND nvl(TRANSACTION_PHASE_CODE,'F') = 'F';

	--ER# 13331078 start
	ELSIF p_hold_entity_code IN('IC') THEN

		SELECT 'Valid Entity'
		INTO l_dummy
		FROM OE_ORDER_LINES l,
		     mtl_item_categories ic
		WHERE l.LINE_ID = p_line_id
		 AND ic.category_id = p_hold_entity_id
		 AND l.INVENTORY_ITEM_ID = ic.inventory_item_id
		 AND ic.organization_id = l.ship_from_org_id
         AND nvl(l.TRANSACTION_PHASE_CODE,'F') = 'F';

	--ER# 13331078 end

	--ER 12571983 start
	  ELSIF p_hold_entity_code IN('EC','EN') THEN

		SELECT 'Valid Entity'
		INTO l_dummy
		FROM OE_ORDER_LINES l
		WHERE l.LINE_ID = p_line_id
		AND l.end_customer_id =p_hold_entity_id
         AND nvl(l.TRANSACTION_PHASE_CODE,'F') = 'F';
	  --ER 12571983 end

	ELSIF p_hold_entity_code = 'S' THEN

 	-- validation data based on bill-to or ship-to site to be inserted here.
		null;

	--ELSIF p_hold_entity_code = 'C' THEN -- ER# 11824468
	ELSIF p_hold_entity_code IN ('C','CN') THEN -- ER# 11824468
	 -- XXXXvalidation data based on Customer based holds -- Not needed at the line level
	  null;
     ELSE
          -- add error message
        	RAISE FND_API.G_EXC_ERROR;
     END IF;

     -------------------------------
     --	Check the Second entity --
	-------------------------------
     IF p_hold_entity_code2 = 'O' THEN

	    SELECT 'Valid Entity'
	    INTO l_dummy
	    FROM OE_ORDER_LINES
	    WHERE LINE_ID = p_line_id
	    AND HEADER_ID = p_hold_entity_id2
            AND nvl(TRANSACTION_PHASE_CODE,'F') = 'F';

	ELSIF p_hold_entity_code2 = 'I' THEN

	    SELECT 'Valid Entity'
	    INTO l_dummy
         FROM OE_ORDER_LINES
	    WHERE LINE_ID = p_line_id
	    AND INVENTORY_ITEM_ID = p_hold_entity_id2
            AND nvl(TRANSACTION_PHASE_CODE,'F') = 'F';

	 --ER 12571983 start
	  ELSIF p_hold_entity_code2 IN('EC','EN') THEN

		SELECT 'Valid Entity'
		INTO l_dummy
		FROM OE_ORDER_LINES l
		WHERE l.LINE_ID = p_line_id
		AND l.end_customer_id =p_hold_entity_id2
         AND nvl(l.TRANSACTION_PHASE_CODE,'F') = 'F';

     ELSIF p_hold_entity_code2 IN('EL') THEN

		SELECT 'Valid Entity'
		INTO l_dummy
		FROM OE_ORDER_LINES l
		WHERE l.LINE_ID = p_line_id
		AND l.end_customer_id =p_hold_entity_id
		AND l.end_customer_site_use_id =p_hold_entity_id2
                AND nvl(l.TRANSACTION_PHASE_CODE,'F') = 'F';
	  --ER 12571983 end

     ELSIF p_hold_entity_code2 = 'S' THEN

    -- validation data based on bill-to or ship-to site to be inserted here.
        null;

     -- ELSIF p_hold_entity_code2 = 'C' THEN -- ER# 11824468
	ELSIF p_hold_entity_code2 IN( 'C','CN') THEN -- ER# 11824468
       -- XXXXvalidation data based on Customer based holds -- Not needed at the line level
	   null;
     ELSE
      -- add error message
	   RAISE FND_API.G_EXC_ERROR;
     END IF;
	------------------------------

   ELSIF p_line_id IS NULL THEN

	IF p_hold_entity_code = 'O' THEN
	     -- XXX
		IF (p_header_id <> p_hold_entity_id) THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		SELECT 'Valid Entity'
		INTO l_dummy
		FROM OE_ORDER_HEADERS
		WHERE  HEADER_ID = p_header_id
                  AND nvl(TRANSACTION_PHASE_CODE,'F') = 'F';


	-- ELSIF p_hold_entity_code = 'C' THEN -- ER# 11824468
	ELSIF p_hold_entity_code IN ('C','CN') THEN -- ER# 11824468

		SELECT 'Valid Entity'
		INTO l_dummy
		FROM OE_ORDER_HEADERS
		WHERE HEADER_ID = p_header_id
	          AND  SOLD_TO_ORG_ID = p_hold_entity_id
                  AND nvl(TRANSACTION_PHASE_CODE,'F') = 'F';

	ELSIF p_hold_entity_code = 'S' THEN
		-- XXX Confirm this code
		SELECT 'Valid Entity'
		INTO l_dummy
		FROM OE_ORDER_HEADERS
		WHERE HEADER_ID = p_header_id
	          AND  SHIP_TO_ORG_ID = p_hold_entity_id
                  AND nvl(TRANSACTION_PHASE_CODE,'F') = 'F';
     ELSE
        	RAISE FND_API.G_EXC_ERROR;
     END IF;
     ------------------------------
	-- Check the Second Entity  --
	------------------------------
    IF p_hold_entity_code2 is not null THEN
	IF p_hold_entity_code2 = 'O' THEN

		IF (p_header_id <> p_hold_entity_id2) THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		SELECT 'Valid Entity'
		INTO l_dummy
		FROM OE_ORDER_HEADERS
		WHERE  HEADER_ID = p_hold_entity_id2
                  AND nvl(TRANSACTION_PHASE_CODE,'F') = 'F';


	--ELSIF p_hold_entity_code2 = 'C' THEN -- ER# 11824468
	 ELSIF p_hold_entity_code2 IN('C','CN') THEN -- ER# 11824468

		SELECT 'Valid Entity'
		INTO l_dummy
		FROM OE_ORDER_HEADERS
		WHERE HEADER_ID = p_header_id
	          AND  SOLD_TO_ORG_ID = p_hold_entity_id2
                  AND nvl(TRANSACTION_PHASE_CODE,'F') = 'F';

	ELSIF p_hold_entity_code2 = 'S' THEN
		-- XXX Confirm this code
		SELECT 'Valid Entity'
		INTO l_dummy
		FROM OE_ORDER_HEADERS
		WHERE HEADER_ID = p_header_id
	          AND  SHIP_TO_ORG_ID = p_hold_entity_id2
                  AND nvl(TRANSACTION_PHASE_CODE,'F') = 'F';
     ELSE
        	RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
	------------------------------
    END IF;

    EXCEPTION
     	WHEN NO_DATA_FOUND THEN
     		RAISE FND_API.G_EXC_ERROR;
    END;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       FND_MESSAGE.SET_NAME('ONT', 'OE_ENTITY_NOT_ON_ORDER_OR_LINE');
       OE_MSG_PUB.ADD;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXPECTED ERROR IN VALIDATEORDER' ) ;
	END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF 	FND_MSG_PUB.Check_Msg_Level
        	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg
        		(   G_PKG_NAME
                	,   l_api_name
                	);
        END IF;
END ValidateOrder;
-- END OF LOCAL PROCEDURES


------------------
-- APPLY_HOLDS  --
------------------
-- This is and overloaded procedure that calls the new Holds API
---------------------------------------------------------------

Procedure Apply_Holds (
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level   IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
  p_order_tbl          IN  OE_HOLDS_PVT.order_tbl_type,
  p_hold_id            IN  OE_HOLD_DEFINITIONS.HOLD_ID%TYPE,
  p_hold_until_date    IN  OE_HOLD_SOURCES.HOLD_UNTIL_DATE%TYPE DEFAULT NULL,
  p_hold_comment       IN  OE_HOLD_SOURCES.HOLD_COMMENT%TYPE DEFAULT NULL,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N', -- bug 8477694
  x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count          OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data           OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Apply_Holds';
--
l_org_id number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_check_authorization_flag varchar2(1):= 'N'; -- bug 8477694
BEGIN
l_check_authorization_flag:= p_check_authorization_flag; -- 8477694
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'IN OE_HOLDS_PUB.APPLY_HOLDS' ) ;
 END IF;

 SAVEPOINT APPLY_HOLDS_PUB; -- 11803186 Adding a new SAVEPOINT to get the new Apply_Holds proc in synch with the Old

 l_org_id := MO_GLOBAL.get_current_org_id;
 IF l_org_id IS NULL THEN
         -- org_id is null, raise an error.
         oe_debug_pub.add('Org_Id is NULL',1);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

 -- Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

  oe_holds_pvt.apply_holds(
          p_order_tbl        =>  p_order_tbl,
          p_hold_id          =>  p_hold_id,
          p_hold_until_date  =>  p_hold_until_date,
          p_hold_comment     =>  p_hold_comment,
          p_check_authorization_flag => l_check_authorization_flag, -- 8477694
          x_return_status    =>  x_return_status,
          x_msg_count        =>  x_msg_count,
          x_msg_data         =>  x_msg_data
                           );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO APPLY_HOLDS_PUB;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'APPLY HOLD EXPECTED ERROR' ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO APPLY_HOLDS_PUB; --11803186
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        ROLLBACK TO APPLY_HOLDS_PUB; --11803186
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF     FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                    ,   l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );

END Apply_Holds;

Procedure Apply_Holds(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level   IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
  p_hold_source_rec     IN  OE_HOLDS_PVT.Hold_Source_Rec_Type
                        DEFAULT  OE_HOLDS_PVT.G_MISS_HOLD_SOURCE_REC,
  p_hold_existing_flg   IN  VARCHAR2 DEFAULT 'Y',
  p_hold_future_flg     IN  VARCHAR2 DEFAULT 'Y',
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N', -- bug 8477694
  x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Apply_Holds';
--
l_org_id number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_check_authorization_flag varchar2(1):= 'N'; -- bug 8477694
BEGIN
 l_check_authorization_flag:= p_check_authorization_flag; -- 8477694
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'IN OE_HOLDS_PUB.APPLY_HOLDS , CREATING HOLD SOURCE' ) ;
 END IF;
 l_org_id := MO_GLOBAL.get_current_org_id;
 IF l_org_id IS NULL THEN
         -- org_id is null, raise an error.
         oe_debug_pub.add('Org_Id is NULL',1);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

 -- Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

--dbms_output.put_line ('IN PUB.ApplyHolds'); -- delete
  oe_holds_pvt.apply_Holds(
     p_hold_source_rec     =>  p_hold_source_rec
    ,p_hold_existing_flg   =>  p_hold_existing_flg
    ,p_hold_future_flg     =>  p_hold_future_flg
    ,p_check_authorization_flag => l_check_authorization_flag -- 8477694
    ,x_return_status       =>  x_return_status
    ,x_msg_count           =>  x_msg_count
    ,x_msg_data            =>  x_msg_data
                  );
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'OE_HOLDS_PUB.APPLY_HOLDS , HOLD SOURCE:' ||X_RETURN_STATUS ) ;
 END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'APPLY HOLD EXPECTED ERROR' ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF     FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                    ,   l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );

END Apply_Holds;

---------------------------------
-- New Release Holds Spec     --
--------------------------------
Procedure Release_Holds (
  p_api_version           IN      NUMBER DEFAULT 1.0,
  p_init_msg_list         IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit                IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level      IN      NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  p_hold_source_rec       IN   OE_HOLDS_PVT.hold_source_rec_type,
  p_hold_release_rec      IN   OE_HOLDS_PVT.Hold_Release_Rec_Type,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N',   -- bug 8477694
  x_return_status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'release_holds';
--
l_org_id number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_check_authorization_flag varchar2(1):= 'N'; -- bug 8477694
BEGIN
 l_check_authorization_flag:=p_check_authorization_flag; --8477694
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'IN OE_HOLDS_PUB.RELEASE_HOLDS' ) ;
 END IF;
 l_org_id := MO_GLOBAL.get_current_org_id;
 IF l_org_id IS NULL THEN
         -- org_id is null, raise an error.
         oe_debug_pub.add('Org_Id is NULL',1);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

 -- Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

--  dbms_output.put_line ('IN RELEASE_HOLDS->'); -- delete
  oe_holds_pvt.Release_Holds(
     p_hold_source_rec     =>  p_hold_source_rec
    ,p_hold_release_rec    =>  p_hold_release_rec
    ,p_check_authorization_flag => l_check_authorization_flag -- bug 8477694
    ,x_return_status       =>  x_return_status
    ,x_msg_count           =>  x_msg_count
    ,x_msg_data            =>  x_msg_data
                  );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RELEASE HOLD EXPECTED ERROR' ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF     FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                    ,   l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );

END Release_Holds;

Procedure Release_Holds (
  p_api_version           IN      NUMBER DEFAULT 1.0,
  p_init_msg_list         IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit                IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level      IN      NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  p_order_tbl              IN   OE_HOLDS_PVT.order_tbl_type,
  p_hold_id                IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
                                 DEFAULT NULL,
  p_release_reason_code    IN   OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE,
  p_release_comment        IN   OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE
                      DEFAULT  NULL,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N',   -- bug 8477694
  x_return_status          OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count              OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data               OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Release_holds';
l_header_id             NUMBER DEFAULT NULL;
j                       NUMBER;
l_order_tbl             OE_HOLDS_PVT.order_tbl_type;
l_org_id number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_check_authorization_flag varchar2(1):= 'N'; -- bug 8477694
BEGIN
 l_check_authorization_flag :=p_check_authorization_flag; -- bug 8477694
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'IN OE_HOLDS_PUB.RELEASE_HOLDS' ) ;
 END IF;

 l_org_id := MO_GLOBAL.get_current_org_id;
 IF l_org_id IS NULL THEN
         -- org_id is null, raise an error.
         oe_debug_pub.add('Org_Id is NULL',1);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

 -- Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

  for j in 1..p_order_tbl.COUNT loop
    if p_order_tbl(j).header_id is NULL AND
       p_order_tbl(j).line_id   is NULL THEN
          FND_MESSAGE.SET_NAME('ONT', 'OE_ENTER_HEADER_OR_LINE_ID');
          OE_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
    ELSIF p_order_tbl(j).header_id is NULL THEN
          SELECT header_id
            INTO l_header_id
            FROM OE_ORDER_LINES
           WHERE LINE_ID = p_order_tbl(j).line_id;
          l_order_tbl(j).header_id := l_header_id;
          l_order_tbl(j).line_id   := p_order_tbl(j).line_id;
    ELSE
       l_order_tbl(j).header_id := p_order_tbl(j).header_id;
       l_order_tbl(j).line_id   := p_order_tbl(j).line_id;
    END IF;
  end loop;

  oe_holds_pvt.release_holds(
          p_order_tbl            =>  l_order_tbl,
          p_hold_id              =>  p_hold_id,
          p_release_reason_code  =>  p_release_reason_code,
          p_release_comment      =>  p_release_comment,
          p_check_authorization_flag => l_check_authorization_flag, -- bug 8477694
          x_return_status        =>  x_return_status,
          x_msg_count            =>  x_msg_count,
          x_msg_data             =>  x_msg_data
                           );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RELEASE HOLD EXPECTED ERROR' ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF     FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                    ,   l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );

END Release_Holds;


--------------------------------------------------------------------------
-- APPLY HOLDS
--  This procedure can be used to apply holds for the following two cases:
--  1. Hold Source has already been created. Pass just the hold source ID
--     (p_hold_source_id) and use that hold source to place the order
--     (p_header_id) or the order line (p_line_id) on hold.
--  2. Check if the hold source exists (p_hold_id, p_entity_code,
--     p_entity_id should be passed). If it exists, use that hold source to
--     place the hold . If it doesn't, create a new hold source and
--     then put the order or line on hold.
-- Note: Leaving this call for backward compatibility. AR's Customer form
--       still calls the old oe_holds (OEXOHAPB.pls) which in turns calls
--       this api.
--------------------------------------------------------------------------

PROCEDURE Apply_Holds
(   p_api_version		IN	NUMBER
,   p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_validation_level	IN	NUMBER 	 DEFAULT FND_API.G_VALID_LEVEL_FULL
,   p_header_id		IN	NUMBER 	DEFAULT NULL
,   p_line_id			IN	NUMBER 	DEFAULT NULL
,   p_hold_source_id	IN      NUMBER  DEFAULT NULL
,   p_hold_source_rec	IN	OE_Hold_Sources_Pvt.Hold_Source_REC
					  DEFAULT OE_Hold_Sources_Pvt.G_MISS_Hold_Source_REC
,   p_check_authorization_flag IN VARCHAR2 DEFAULT 'N' -- bug 8477694
,   x_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   x_msg_count		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   x_msg_data			OUT NOCOPY /* file.sql.39 change */	VARCHAR2
)
IS
l_api_version		CONSTANT NUMBER := 1.0;
l_api_name 		CONSTANT VARCHAR2(30) := 'APPLY_HOLDS';
l_user_id		     NUMBER;
l_hold_source_id	NUMBER := 0;
l_dummy			VARCHAR2(30);
l_order_holds_s	NUMBER := 0;
--ER#7479609 l_entity_code		VARCHAR2(1);
l_entity_code		oe_hold_sources_all.hold_entity_code%TYPE;  --ER#7479609
l_entity_id		NUMBER;
--
--ER#7479609 l_entity_code2		VARCHAR2(1);
l_entity_code2		oe_hold_sources_all.hold_entity_code2%TYPE;  --ER#7479609
l_entity_id2		NUMBER;
l_header_id		NUMBER DEFAULT NULL;

l_hold_source_rec   OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_site_use_code     VARCHAR2(30);
l_org_id number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_check_authorization_flag varchar2(1):= 'N'; -- bug 8477694
BEGIN
l_check_authorization_flag:= p_check_authorization_flag; -- 8477694
 l_org_id := MO_GLOBAL.get_current_org_id;
 IF l_org_id IS NULL THEN
         -- org_id is null, raise an error.
         oe_debug_pub.add('Org_Id is NULL',1);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IN OE_HOLDS_PUB.APPLY_HOLDS OLD' ) ;
  END IF;

  SAVEPOINT APPLY_HOLDS_PUB;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  Utilities(l_user_id);


  ----------------------------------------------------------------
  -- CASE I: Hold Source ID is KNOWN
  ----------------------------------------------------------------
  IF p_hold_source_id IS NOT NULL THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'USING INPUT HOLD SOURCE ID' ) ;
    END IF;
    l_hold_source_id := p_hold_source_id;

    --IF p_validation_level = FND_API.G_VALID_LEVEL_FULL THEN

    	  -- Check if the hold source ID is valid
    	  BEGIN

      	SELECT  HOLD_ENTITY_CODE, HOLD_ENTITY_ID,
			   HOLD_ENTITY_CODE2, HOLD_ENTITY_ID2
       	  INTO  l_entity_code, l_entity_id,
			   l_entity_code2, l_entity_id2
        	  FROM  OE_HOLD_SOURCES
      	 WHERE  HOLD_SOURCE_ID = p_hold_source_id
      	   AND  RELEASED_FLAG = 'N'
    		   AND  NVL(HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE;

    	  EXCEPTION
      		WHEN NO_DATA_FOUND THEN
      	            IF l_debug_level  > 0 THEN
      	                oe_debug_pub.add(  'INVALID HOLD SOURCE ID' ) ;
      	            END IF;
                    FND_MESSAGE.SET_NAME('ONT','OE_INVALID_HOLD_SOURCE_ID');
                    FND_MESSAGE.SET_TOKEN('HOLD_SOURCE_ID' , p_hold_source_id);
                    OE_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
    	  END;

    -- END IF;

  -------------------------------------------------------------
  -- CASE II: Hold Source ID is NOT AVAILABLE
  -------------------------------------------------------------
  ELSE
	--  Check for Missing Values
    	IF p_hold_source_rec.hold_id IS NULL THEN
	    FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_HOLD_ID');
	    OE_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
    	END IF;

  	IF p_hold_source_rec.hold_entity_code IS NULL THEN
	    FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_ENTITY_CODE');
	    OE_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
    	END IF;

    	IF p_hold_source_rec.hold_entity_id IS NULL THEN
	    FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_ENTITY_ID');
	    OE_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
    	END IF;
	-- NOTE: No need to check for HOLD_ENTITY_CODE2 and HOLD_ENTITY_ID2
	--       cos, its optional.
     ----------------------------------
     -- Check to see if the Site code is Bill_to OR Ship_to
     -- ONLY needed coz AR still calls the old holds api (oe_holds) with
     -- S as hold_entity_code for Bill To.
     if p_hold_source_rec.hold_entity_code = 'S' THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECKING FOR SITE CODE , BILL TO OR SHIP TO' , 1 ) ;
        END IF;
        l_entity_code := Hold_Site_Code(p_hold_source_rec.hold_entity_id);
     ELSE
        l_entity_code := p_hold_source_rec.hold_entity_code;
     END IF;
	l_entity_id    := p_hold_source_rec.hold_entity_id;

  END IF; -- END of check to see WHETHER HOLD SOURCE ID is passed.
/*
  IF p_hold_source_rec.hold_entity_code = 'O' THEN
     IF p_line_id IS NULL AND p_header_id IS NULL THEN
	    FND_MESSAGE.SET_NAME('ONT', 'OE_ENTER_HEADER_OR_LINE_ID');
	    OE_MSG_PUB.ADD;
    	    RAISE FND_API.G_EXC_ERROR;
     ELSIF p_header_id IS NULL THEN
    	    SELECT header_id
    	    INTO l_header_id
    	    FROM OE_ORDER_LINES
    	    WHERE LINE_ID = p_line_id;
     ELSE
    	    l_header_id := p_header_id;
     END IF;
  END IF; -- p_hold_source_rec.hold_entity_code = 'O'
*/

/*    IF l_hold_source_id <> 0 THEN
      -- Check for duplicate hold
      BEGIN
        SELECT 'Duplicate Hold'
    	     INTO l_dummy
    	     FROM OE_ORDER_HOLDS
    	    WHERE hold_source_id = l_hold_source_id
           AND HEADER_ID = l_header_id
           AND NVL(LINE_ID, NVL(p_line_id,0)) = NVL(p_line_id, 0)
           AND HOLD_RELEASE_ID IS NULL
           AND ROWNUM = 1;

        IF (sql%found) THEN
        	FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD');
	    	OE_MSG_PUB.ADD;
          OE_Debug_PUB.Add('Duplicate Hold');
	    	RAISE FND_API.G_EXC_ERROR;
	   END IF;
      EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		  null;
      END;
    END IF; -- l_hold_source_id <> 0
*/
/*
    IF p_hold_source_rec.hold_entity_code = 'O' THEN
    	 ValidateOrder(p_header_id 		=> p_header_id
    		      , p_line_id		     => p_line_id
    		      , p_hold_entity_code 	=> l_entity_code
    		      , p_hold_entity_id	     => l_entity_id
    		      , p_hold_entity_code2 	=> l_entity_code2
    		      , p_hold_entity_id2	=> l_entity_id2
    		      , x_return_status		=> x_return_status
    		      );

    	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    	    OE_Debug_PUB.Add('Validate Order not successful');
    	    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    	          RAISE FND_API.G_EXC_ERROR;
    	    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	    END IF;
    	  ELSE
         OE_Debug_PUB.Add('Validate Order successful');
    	  END IF;
    END IF; -- p_hold_source_rec.hold_entity_code = 'O'
*/

  l_hold_source_rec.hold_entity_code  := l_entity_code;
  l_hold_source_rec.hold_entity_id    := l_entity_id;
  l_hold_source_rec.hold_entity_code2 := p_hold_source_rec.hold_entity_code2;
  l_hold_source_rec.hold_entity_id2   := p_hold_source_rec.hold_entity_id2;
  l_hold_source_rec.hold_id           := p_hold_source_rec.hold_id;

  /* In case the p_header_id and p_line_id is not null. This will only be the case
     if the old holds api (oe_holds) is being called to apply a header or line
     level hold. These are part of hold_source_rec npw.
     REMOVE this after it has been verified.  */
  IF p_hold_source_rec.hold_entity_code = 'O' THEN
   IF p_header_id IS NOT NULL THEN
      l_hold_source_rec.header_id         := p_header_id;
   ELSIF p_line_id IS NOT NULL THEN
      l_hold_source_rec.line_id           := p_line_id;
   END IF;
  END IF;


--dbms_output.put_line ('AH-hold_id' ||to_char(p_hold_source_rec.hold_id)); -- delete
--dbms_output.put_line ('AH-B4ApplyHolds' ); -- delete
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING OE_HOLDS_PVT.APPLY_HOLDS' ) ;
  END IF;
  oe_holds_pvt.apply_Holds(
     p_hold_source_rec     =>  l_hold_source_rec
    ,p_hold_existing_flg   =>  'Y'
    ,p_hold_future_flg     =>  'Y'
    ,p_check_authorization_flag => l_check_authorization_flag -- 8477694
    ,x_return_status       =>  x_return_status
    ,x_msg_count           =>  x_msg_count
    ,x_msg_data            =>  x_msg_data
                  );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OE_HOLDS_PVT.APPLY_HOLDS STATUS:' || X_RETURN_STATUS ) ;
  END IF;
--dbms_output.put_line('AH-x_return_status' || x_return_status ); -- delete
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO APPLY_HOLDS_PUB;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'FROM DUPLICATE HOLD EXPECTED ERROR' ) ;
          END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO APPLY_HOLDS_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    WHEN OTHERS THEN
        ROLLBACK TO APPLY_HOLDS_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF 	FND_MSG_PUB.Check_Msg_Level
        	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg
        		(   G_PKG_NAME
                	,   l_api_name
                	);
        END IF;
        FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
END Apply_Holds;

/**************************************************************/

/* An additional parameter 'p_hdr_id' was passed to this procedure.
   This was to improve the performance of a query in this procedure.
   Refer Bug1920064.
*/

PROCEDURE Check_Holds_line (
    p_hdr_id             IN   NUMBER
,   p_line_id            IN   NUMBER   DEFAULT NULL
,   p_hold_id            IN   NUMBER   DEFAULT NULL
,   p_wf_item            IN   VARCHAR2 DEFAULT NULL
,   p_wf_activity        IN   VARCHAR2 DEFAULT NULL
,   p_entity_code        IN   VARCHAR2 DEFAULT NULL
--ER#7479609,   p_entity_id          IN   NUMBER   DEFAULT NULL
,   p_entity_id          IN   oe_hold_sources_all.hold_entity_id%TYPE   DEFAULT NULL  --ER#7479609
,   p_entity_code2       IN   VARCHAR2 DEFAULT NULL
--ER#7479609,   p_entity_id2         IN   NUMBER   DEFAULT NULL
,   p_entity_id2         IN   oe_hold_sources_all.hold_entity_id2%TYPE   DEFAULT NULL  --ER#7479609
,   p_chk_act_hold_only  IN   VARCHAR2 DEFAULT 'N'
,   p_ii_parent_flag     IN   VARCHAR2 DEFAULT 'N'
,   x_result_out         OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER
,   x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Check_Holds_line';
l_dummy             VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'IN OE_HOLDS_PUB.CHECK_HOLDS_LINE:' || P_LINE_ID ) ;
  END IF;
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize result to TRUE i.e. holds are found
  x_result_out := FND_API.G_TRUE;

  /*
  ** Fix Bug # 1920064
  ** The SQL below was modified. To improve the performance, the scan on
  ** the table OE_ORDER_LINES_ALL was avoided as the header_id was being
  ** passed as a parameter to this procedure. The UNION was removed and
  ** the whole SQL was re-written as below.
  ** Fix Bug # 2984023
  ** Modified the query to check for only line level holds
  */

  /*
  ** Checking for LINE level generic and activity-specific holds
  */
  BEGIN

    SELECT 'ANY_LINE_HOLD'
      INTO l_dummy
      FROM oe_order_holds_all oh
     WHERE oh.header_id = p_hdr_id
       and oh.line_id   = p_line_id
       and oh.hold_release_id is null
       AND EXISTS
          (SELECT 1
             FROM oe_hold_sources_all     hs,
                  oe_hold_definitions h
            WHERE oh.hold_source_id = hs.hold_source_id
              AND hs.hold_id = h.hold_id
              AND NVL(h.item_type,
                  DECODE(p_chk_act_hold_only,
                         'Y', 'XXXXX',
                              NVL(p_wf_item, 'NO ITEM')) ) =
                  NVL(p_wf_item, 'NO ITEM')
              AND NVL(H.ACTIVITY_NAME,
                  DECODE(p_chk_act_hold_only,
                         'Y', 'XXXXX',
                              NVL(p_wf_activity, 'NO ACT')) ) =
                  NVL(p_wf_activity,'NO ACT')
              AND DECODE(p_ii_parent_flag, 'Y',
                         nvl(h.hold_included_items_flag, 'N'), 'XXXXX') =
                  DECODE(p_ii_parent_flag, 'Y', 'Y', 'XXXXX')
              AND SYSDATE BETWEEN NVL( H.START_DATE_ACTIVE, SYSDATE )
                          AND NVL( H.END_DATE_ACTIVE, SYSDATE )
              AND HS.HOLD_ID = NVL(p_hold_id,HS.HOLD_ID)
              AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                   ROUND( SYSDATE )
              AND hs.hold_entity_code = NVL(p_entity_code, hs.hold_entity_code)
              AND hs.hold_entity_id = NVL(p_entity_id, hs.hold_entity_id)
              AND NVL(hs.hold_entity_code2, 'NO_ENTITY_CODE2') =
                  NVL(p_entity_code2, nvl(hs.hold_entity_code2,'NO_ENTITY_CODE2') )
              AND NVL(hs.hold_entity_id2, -99) =
                  nvl(p_entity_id2, NVL(hs.hold_entity_id2, -99 )) );

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_result_out := FND_API.G_FALSE;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO HOLDS FOUND FOR LINE ID: ' || P_LINE_ID ) ;
        END IF;
      WHEN TOO_MANY_ROWS THEN
        null;
  END;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_HOLDS_PUB.CHECK_HOLDS_LINE' ) ;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_result_out := FND_API.G_FALSE;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_result_out := FND_API.G_FALSE;
         FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_result_out := FND_API.G_FALSE;
        IF     FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                    ,   l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );

END CHECK_HOLDS_LINE;

/*
** Procedure to check holds on ANY line part of ATO Model.
*/
PROCEDURE Check_Holds_ATO (
    p_hdr_id             IN   NUMBER
,   p_ato_line_id        IN   NUMBER   DEFAULT NULL
,   p_top_model_line_id  IN   NUMBER   DEFAULT NULL
,   p_hold_id            IN   NUMBER   DEFAULT NULL
,   p_wf_item            IN   VARCHAR2 DEFAULT NULL
,   p_wf_activity        IN   VARCHAR2 DEFAULT NULL
,   p_entity_code        IN   VARCHAR2 DEFAULT NULL
--ER#7479609,   p_entity_id          IN   NUMBER   DEFAULT NULL
,   p_entity_id          IN   oe_hold_sources_all.hold_entity_id%TYPE   DEFAULT NULL  --ER#7479609
,   p_entity_code2       IN   VARCHAR2 DEFAULT NULL
--ER#7479609,   p_entity_id2         IN   NUMBER   DEFAULT NULL
,   p_entity_id2         IN   oe_hold_sources_all.hold_entity_id2%TYPE   DEFAULT NULL  --ER#7479609
,   p_chk_act_hold_only  IN   VARCHAR2 DEFAULT 'N'
,   x_result_out         OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER
,   x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Check_Holds_ATO';
l_dummy             VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'IN OE_HOLDS_PUB.CHECK_HOLDS_ATO' ) ;
  END IF;
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize result to TRUE i.e. holds are found
  x_result_out := FND_API.G_TRUE;

  /*
  ** Checking for ATO level generic and activity-specific holds
  */
  BEGIN

    SELECT /* MOAC_SQL_CHANGE */ 'ANY_ATO_LINE_HOLD'
      INTO l_dummy
      FROM oe_order_holds_all oh
     WHERE oh.header_id = p_hdr_id
       and oh.line_id  in (select ol.line_id from oe_order_lines_all ol
                            where ol.header_id         = oh.header_id
                              and ol.ato_line_id       = p_ato_line_id
                              and ol.top_model_line_id = p_top_model_line_id)
       and oh.hold_release_id is null
       AND EXISTS
          (SELECT 1
             FROM oe_hold_sources_all     hs,
                  oe_hold_definitions h
            WHERE oh.hold_source_id = hs.hold_source_id
              AND hs.hold_id = h.hold_id
              AND NVL(h.item_type,
                  DECODE(p_chk_act_hold_only,
                         'Y', 'XXXXX',
                              NVL(p_wf_item, 'NO ITEM')) ) =
                  NVL(p_wf_item, 'NO ITEM')
              AND NVL(H.ACTIVITY_NAME,
                  DECODE(p_chk_act_hold_only,
                         'Y', 'XXXXX',
                              NVL(p_wf_activity, 'NO ACT')) ) =
                  NVL(p_wf_activity,'NO ACT')
              AND SYSDATE BETWEEN NVL( H.START_DATE_ACTIVE, SYSDATE )
                          AND NVL( H.END_DATE_ACTIVE, SYSDATE )
              AND HS.HOLD_ID = NVL(p_hold_id,HS.HOLD_ID)
              AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                   ROUND( SYSDATE )
              AND hs.hold_entity_code = NVL(p_entity_code, hs.hold_entity_code)
              AND hs.hold_entity_id = NVL(p_entity_id, hs.hold_entity_id)
              AND NVL(hs.hold_entity_code2, 'NO_ENTITY_CODE2') =
                  NVL(p_entity_code2, nvl(hs.hold_entity_code2,'NO_ENTITY_CODE2') )
              AND NVL(hs.hold_entity_id2, -99) =
                  nvl(p_entity_id2, NVL(hs.hold_entity_id2, -99 )) );

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_result_out := FND_API.G_FALSE;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO HOLDS FOUND FOR ATO LINE ID: ' || P_ATO_LINE_ID ) ;
        END IF;
      WHEN TOO_MANY_ROWS THEN
        null;
  END;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_HOLDS_PUB.CHECK_HOLDS_ATO' ) ;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_result_out := FND_API.G_FALSE;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_result_out := FND_API.G_FALSE;
         FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_result_out := FND_API.G_FALSE;
        IF     FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                    ,   l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );

END CHECK_HOLDS_ATO;

/*
** Procedure to check holds on ANY line part of an SMC.
*/

PROCEDURE Check_Holds_SMC (
    p_hdr_id             IN   NUMBER
,   p_top_model_line_id  IN   NUMBER   DEFAULT NULL
,   p_hold_id            IN   NUMBER   DEFAULT NULL
,   p_wf_item            IN   VARCHAR2 DEFAULT NULL
,   p_wf_activity        IN   VARCHAR2 DEFAULT NULL
,   p_entity_code        IN   VARCHAR2 DEFAULT NULL
--ER#7479609,   p_entity_id          IN   NUMBER   DEFAULT NULL
,   p_entity_id          IN   oe_hold_sources_all.hold_entity_id%TYPE   DEFAULT NULL  --ER#7479609
,   p_entity_code2       IN   VARCHAR2 DEFAULT NULL
--ER#7479609,   p_entity_id2         IN   NUMBER   DEFAULT NULL
,   p_entity_id2         IN   oe_hold_sources_all.hold_entity_id2%TYPE   DEFAULT NULL  --ER#7479609
,   p_chk_act_hold_only  IN   VARCHAR2 DEFAULT 'N'
,   x_result_out         OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER
,   x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Check_Holds_SMC';
l_dummy             VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'IN OE_HOLDS_PUB.CHECK_HOLDS_SMC' ) ;
  END IF;
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize result to TRUE i.e. holds are found
  x_result_out := FND_API.G_TRUE;

  /*
  ** Checking for SMC level generic and activity-specific holds
  */
  BEGIN

    SELECT /* MOAC_SQL_CHANGE */ 'ANY_SMC_LINE_HOLD'
      INTO l_dummy
      FROM oe_order_holds_all oh
     WHERE oh.header_id = p_hdr_id
       and oh.line_id  in (select ol.line_id from oe_order_lines_all ol
                           where  ol.header_id         = oh.header_id
                             and  ol.top_model_line_id = p_top_model_line_id)
       and oh.hold_release_id is null
       AND EXISTS
          (SELECT 1
             FROM oe_hold_sources_all     hs,
                  oe_hold_definitions h
            WHERE oh.hold_source_id = hs.hold_source_id
              AND hs.hold_id = h.hold_id
              AND NVL(h.item_type,
                  DECODE(p_chk_act_hold_only,
                         'Y', 'XXXXX',
                              NVL(p_wf_item, 'NO ITEM')) ) =
                  NVL(p_wf_item, 'NO ITEM')
              AND NVL(H.ACTIVITY_NAME,
                  DECODE(p_chk_act_hold_only,
                         'Y', 'XXXXX',
                              NVL(p_wf_activity, 'NO ACT')) ) =
                  NVL(p_wf_activity,'NO ACT')
              AND SYSDATE BETWEEN NVL( H.START_DATE_ACTIVE, SYSDATE )
                          AND NVL( H.END_DATE_ACTIVE, SYSDATE )
              AND HS.HOLD_ID = NVL(p_hold_id,HS.HOLD_ID)
              AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                   ROUND( SYSDATE )
              AND hs.hold_entity_code = NVL(p_entity_code, hs.hold_entity_code)
              AND hs.hold_entity_id = NVL(p_entity_id, hs.hold_entity_id)
              AND NVL(hs.hold_entity_code2, 'NO_ENTITY_CODE2') =
                  NVL(p_entity_code2, nvl(hs.hold_entity_code2,'NO_ENTITY_CODE2') )
              AND NVL(hs.hold_entity_id2, -99) =
                  nvl(p_entity_id2, NVL(hs.hold_entity_id2, -99 )) );

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_result_out := FND_API.G_FALSE;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO HOLDS FOUND FOR TOP MODEL LINE ID: ' || P_TOP_MODEL_LINE_ID ) ;
        END IF;
      WHEN TOO_MANY_ROWS THEN
        null;
  END;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_HOLDS_PUB.CHECK_HOLDS_SMC' ) ;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_result_out := FND_API.G_FALSE;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_result_out := FND_API.G_FALSE;
         FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_result_out := FND_API.G_FALSE;
        IF     FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                    ,   l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );

END CHECK_HOLDS_SMC;

/**************************************************************************/

-- Created for bug 2673236
-- Check If any line in the order is on hold

PROCEDURE Check_Any_Line_Hold (
    x_hold_rec              IN OUT NOCOPY OE_HOLDS_PUB.Any_Line_Hold_rec
,   x_return_status         OUT  NOCOPY VARCHAR2
,   x_msg_count             OUT  NOCOPY NUMBER
,   x_msg_data              OUT  NOCOPY VARCHAR2
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Check_Any_Line_Hold';
l_dummy             VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 -- Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Initialize result to TRUE i.e. holds are found
 x_hold_rec.x_result_out := FND_API.G_TRUE;

 BEGIN

     SELECT 'ANY_LINE_HOLD'
       INTO l_dummy
       FROM oe_order_holds_all oh
      WHERE oh.header_id = x_hold_rec.header_id
        and OH.LINE_ID is not null
        and OH.HOLD_RELEASE_ID IS NULL
        and ROWNUM = 1
        AND EXISTS
            (SELECT 1
                    FROM oe_hold_sources_all     hs,
                    oe_hold_definitions h
              WHERE oh.hold_source_id = hs.hold_source_id
                AND hs.hold_id = h.hold_id
                AND NVL(h.item_type,
                    DECODE(x_hold_rec.p_chk_act_hold_only,
                           'Y', 'XXXXX',
                                NVL(x_hold_rec.wf_item_type, 'NO ITEM')) ) =
                    NVL(x_hold_rec.wf_item_type, 'NO ITEM')
                AND NVL(H.ACTIVITY_NAME,
                    DECODE(x_hold_rec.p_chk_act_hold_only,
                           'Y', 'XXXXX',
                                NVL(x_hold_rec.wf_activity_name, 'NO ACT')) ) =
                    NVL(x_hold_rec.wf_activity_name,'NO ACT')
                AND SYSDATE BETWEEN NVL( H.START_DATE_ACTIVE, SYSDATE )
                            AND NVL( H.END_DATE_ACTIVE, SYSDATE )
                AND HS.HOLD_ID = NVL(x_hold_rec.hold_id,HS.HOLD_ID)
                AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                     ROUND( SYSDATE )
                AND hs.hold_entity_code = NVL(x_hold_rec.hold_entity_code, hs.hold_entity_code)
                AND hs.hold_entity_id = NVL(x_hold_rec.hold_entity_id, hs.hold_entity_id)
                AND NVL(hs.hold_entity_code2, 'NO_ENTITY_CODE2') =
                    NVL(x_hold_rec.hold_entity_code2, NVL(hs.hold_entity_code2,'NO_ENTITY_CODE2') )
                AND NVL(hs.hold_entity_id2, -99) =
                    NVL(x_hold_rec.hold_entity_id2, NVL(hs.hold_entity_id2, -99 )) );
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
       x_hold_rec.x_result_out := FND_API.G_FALSE;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'NO HOLDS FOUND FOR ANY OF THE LINES' ) ;
       END IF;
    WHEN TOO_MANY_ROWS THEN
       null;
 END;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_hold_rec.x_result_out := FND_API.G_FALSE;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_hold_rec.x_result_out := FND_API.G_FALSE;
         FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_hold_rec.x_result_out := FND_API.G_FALSE;
        IF     FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                    ,   l_api_name
                    );
        END IF;
        FND_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );

END Check_Any_Line_Hold;

/**************************************************************/
-----------------------------------------------------------------------
-- Check_Holds
--
-- Checks if there are any holds on the order or order line. If
-- order line, then checks for holds on the order that it belongs to.
-- If ATO line, then checks for holds on other lines belonging to the
-- same ATO model. If SMC line, then checks for other lines in the SMC.
-- If included item line then checks for hold on its immediate parent
-- if included item flag is set appropriately in the hold definition.
------------------------------------------------------------------------
PROCEDURE Check_Holds
( p_api_version	      IN     NUMBER
, p_init_msg_list     IN     VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit            IN     VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level  IN     NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_header_id         IN     NUMBER   DEFAULT NULL
, p_line_id           IN     NUMBER   DEFAULT NULL
, p_hold_id           IN     NUMBER   DEFAULT NULL
, p_wf_item           IN     VARCHAR2 DEFAULT NULL
, p_wf_activity       IN     VARCHAR2 DEFAULT NULL
, p_entity_code       IN     VARCHAR2 DEFAULT NULL
--ER#7479609, p_entity_id         IN     NUMBER   DEFAULT NULL
, p_entity_id         IN     oe_hold_sources_all.hold_entity_id%TYPE   DEFAULT NULL --ER#7479609
, p_entity_code2      IN     VARCHAR2 DEFAULT NULL
--ER#7479609, p_entity_id2        IN     NUMBER   DEFAULT NULL
, p_entity_id2        IN     oe_hold_sources_all.hold_entity_id2%TYPE   DEFAULT NULL  --ER#7479609
, p_chk_act_hold_only IN     VARCHAR2 DEFAULT 'N'
, x_result_out        OUT NOCOPY /* file.sql.39 change */    VARCHAR2
, x_return_status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2
, x_msg_count         OUT NOCOPY /* file.sql.39 change */    NUMBER
, x_msg_data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2
)
IS
  l_api_name	       CONSTANT VARCHAR2(30) := 'CHECK_HOLDS';
  l_api_version	       CONSTANT NUMBER := 1.0;
  l_dummy	       VARCHAR2(30);

  l_line_id            NUMBER;
  l_ato_line_id        NUMBER;
  l_top_model_line_id  NUMBER;
  l_smc_flag           VARCHAR2(1);
  l_item_type_code     VARCHAR2(30);
  l_link_to_line_id    NUMBER;

  l_return_status      VARCHAR2(30);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  p_hdr_id             NUMBER;

  CURSOR ato_model_lines IS
  select line_id
    from oe_order_lines_all
   where ato_line_id = l_ato_line_id
     and top_model_line_id = l_top_model_line_id;

  CURSOR smc_lines IS
  select line_id
    from oe_order_lines_all
   where top_model_line_id = l_top_model_line_id;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  --7832836  l_cascade_hold_non_smc VARCHAR2(1) := NVL(OE_SYS_PARAMETERS.VALUE('ONT_CASCADE_HOLD_NONSMC_PTO'),'N'); --ER#7479609
  l_cascade_hold_non_smc VARCHAR2(1);  -- 7832836
  l_org_id NUMBER;  -- 7832836
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'IN OE_HOLDS_PUB.CHECK_HOLDS' ) ;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize result to TRUE i.e. holds are found
  x_result_out := FND_API.G_TRUE;

  -- Check for Missing Input Parameters
  IF p_header_id IS NULL AND p_line_id IS NULL THEN

    FND_MESSAGE.SET_NAME('ONT', 'OE_ENTER_HEADER_OR_LINE_ID');
    OE_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;

  END IF;

  /*
  ** Fix Bug # 1920064, 2984023
  ** The following 'if' condition was added to select the header_id
  ** into a local variable 'p_hdr_id'. This variable is passed as a
  ** parameter to the procedure CHECK_HOLDS_LINE. This ensures that
  ** header_id is always passed as a not null parameter.
  */

  IF p_header_id IS NULL THEN
    Begin
      SELECT header_id
        INTO p_hdr_id
        FROM oe_order_lines_all
       WHERE line_id = p_line_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_result_out := FND_API.G_FALSE;
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE ID DOES NOT EXISTS OR IS INVALID - 1: ' || P_LINE_ID ) ;
          END IF;
    End;
  ELSE
    p_hdr_id := p_header_id;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CHECKING HOLD ON HEADER ID: ' || P_HDR_ID ) ;
  END IF;

--7832836 start
 l_org_id := MO_GLOBAL.get_current_org_id;
 IF l_org_id IS NULL THEN
  BEGIN
   SELECT org_id
    INTO l_org_id
   FROM  oe_order_headers_all
   WHERE header_id=p_hdr_id;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    x_result_out := FND_API.G_FALSE;
  END;
 END IF;

  l_cascade_hold_non_smc := NVL(OE_SYS_PARAMETERS.VALUE('ONT_CASCADE_HOLD_NONSMC_PTO',l_org_id),'N');
--7832836  end

  /*
  ** Checking for HEADER level generic holds and activity specific holds
  */
  BEGIN

    SELECT 'ANY_HEADER_HOLD'
      INTO l_dummy
      FROM oe_order_holds_all oh
     WHERE oh.header_id = p_hdr_id
       AND oh.line_id IS NULL
       AND oh.hold_release_id IS NULL
       AND EXISTS
          (SELECT 1
             FROM oe_hold_sources_all     hs,
                  oe_hold_definitions h
            WHERE oh.hold_source_id = hs.hold_source_id
              AND hs.hold_id = h.hold_id
              AND NVL(h.item_type,
				DECODE(p_chk_act_hold_only,
					  'Y', 'XXXXX',
	                           NVL(p_wf_item, 'NO ITEM')) ) =
                    NVL(p_wf_item, 'NO ITEM')
              AND NVL(h.activity_name,
				DECODE(p_chk_act_hold_only,
                           'Y', 'XXXXX',
                                NVL(p_wf_activity, 'NO ACT')) ) =
                    NVL(p_wf_activity, 'NO ACT')
              AND SYSDATE BETWEEN NVL( H.START_DATE_ACTIVE, SYSDATE )
                            AND NVL( H.END_DATE_ACTIVE, SYSDATE )
              AND hs.hold_id = NVL(p_hold_id, hs.hold_id)
              AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                     ROUND( SYSDATE )
              AND hs.hold_entity_code = NVL(p_entity_code, hs.hold_entity_code)
              AND hs.hold_entity_id = NVL(p_entity_id, hs.hold_entity_id)
     AND NVL(hs.hold_entity_code2, 'NO_ENTITY_CODE2') =
         NVL(p_entity_code2, nvl(hs.hold_entity_code2,'NO_ENTITY_CODE2') )
     AND NVL(hs.hold_entity_id2, -99) =
         nvl(p_entity_id2, NVL(hs.hold_entity_id2, -99 )) );

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_result_out := FND_API.G_FALSE;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO HOLDS FOUND FOR HEADER ID: ' || P_HDR_ID ) ;
        END IF;
      WHEN TOO_MANY_ROWS THEN
        null;
  END;

  -- Return TRUE if Header Level Hold exists
  IF x_result_out = FND_API.G_TRUE THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'HEADER LEVEL HOLD EXISTS' ) ;
    END IF;
    RETURN;
  END IF;

  IF p_line_id IS NOT NULL THEN

    /* Check if the Line is on Hold */
    Check_Holds_line (
               p_hdr_id             => p_hdr_id
              ,p_line_id            => p_line_id
              ,p_hold_id            => p_hold_id
              ,p_wf_item            => p_wf_item
              ,p_wf_activity        => p_wf_activity
              ,p_entity_code        => p_entity_code
              ,p_entity_id          => p_entity_id
              ,p_entity_code2       => p_entity_code2
              ,p_entity_id2         => p_entity_id2
              ,p_chk_act_hold_only  => p_chk_act_hold_only
              ,x_result_out         => x_result_out
              ,x_return_status      => l_return_status
              ,x_msg_count          => l_msg_count
              ,x_msg_data           => l_msg_data
              );

    -- Raise if the l_return_status is unexpected error
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Check_Holds_line:G_RET_STS_ERROR') ;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Check_Holds_line:G_RET_STS_UNEXP_ERROR') ;
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Proceed only if there is no hold on the line */
    IF x_result_out = FND_API.G_FALSE THEN

      /* Check to see if the line is a part of ATO model, SMC, etc. */
      BEGIN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CHECKING IF LINE IS PART OF ATO MODEL , SMC' ) ;
        END IF;
        SELECT ATO_LINE_ID, TOP_MODEL_LINE_ID,
               SHIP_MODEL_COMPLETE_FLAG, ITEM_TYPE_CODE,
               LINK_TO_LINE_ID
        INTO   l_ato_line_id, l_top_model_line_id,
               l_smc_flag, l_item_type_code, l_link_to_line_id
        FROM   oe_order_lines_all
        WHERE  line_id = p_line_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_result_out := FND_API.G_FALSE;
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE ID DOES NOT EXISTS OR IS INVALID - 2: ' || P_LINE_ID ) ;
            END IF;
      END;

      IF l_debug_level  > 0 THEN
        IF l_ato_line_id IS NOT NULL OR NVL(l_smc_flag, 'N') = 'Y' THEN
          oe_debug_pub.add(  'ATO_LINE_ID: '||L_ATO_LINE_ID );
          oe_debug_pub.add(  'TOP_MODE_LINE_ID: '||L_TOP_MODEL_LINE_ID );
          oe_debug_pub.add(  'SHIP_MODEL_COMPLETE_FLAG: '||L_SMC_FLAG );
          oe_debug_pub.add(  'ITEM_TYPE_CODE: '||L_ITEM_TYPE_CODE );
          oe_debug_pub.add(  'LINK_TO_LINE_ID: '||L_LINK_TO_LINE_ID );
        ELSE
          oe_debug_pub.add(  'LINE IS NOT PART OF ATO MODEL OR SMC' ) ;
        END IF;
      END IF;

      /* If Line is part of ATO Model */
      IF l_ato_line_id is NOT NULL AND x_result_out = FND_API.G_FALSE AND
        NOT (l_ato_line_id = p_line_id AND l_item_type_code = OE_GLOBALS.G_ITEM_OPTION) THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CHECK_HOLDS:ATO MODEL LINE: ' || L_ATO_LINE_ID ) ;
        END IF;

        /*
        ** Fix Bug # 2984023
        ** Following replaced by a single call to Check_Holds_ATO

        x_result_out := FND_API.G_FALSE;

        OPEN ato_model_lines;
        loop
          FETCH ato_model_lines into l_line_id;
          exit when ato_model_lines%NOTFOUND OR
                    (x_result_out = FND_API.G_TRUE);
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK_HOLDS:CHECKING LINEID' || L_LINE_ID ) ;
          END IF;

          Check_Holds_line (
                 p_hdr_id             => p_hdr_id
                ,p_line_id            => l_line_id
                ,p_hold_id            => p_hold_id
                ,p_wf_item            => p_wf_item
                ,p_wf_activity        => p_wf_activity
                ,p_entity_code        => p_entity_code
                ,p_entity_id          => p_entity_id
                ,p_entity_code2       => p_entity_code2
                ,p_entity_id2         => p_entity_id2
                ,p_chk_act_hold_only  => p_chk_act_hold_only
                ,x_result_out         => x_result_out
                ,x_return_status      => l_return_status
                ,x_msg_count          => l_msg_count
                ,x_msg_data           => l_msg_data
                );
        end loop;
        */
          Check_Holds_ATO (
                 p_hdr_id             => p_hdr_id
                ,p_ato_line_id        => l_ato_line_id
                ,p_top_model_line_id  => l_top_model_line_id
                ,p_hold_id            => p_hold_id
                ,p_wf_item            => p_wf_item
                ,p_wf_activity        => p_wf_activity
                ,p_entity_code        => p_entity_code
                ,p_entity_id          => p_entity_id
                ,p_entity_code2       => p_entity_code2
                ,p_entity_id2         => p_entity_id2
                ,p_chk_act_hold_only  => p_chk_act_hold_only
                ,x_result_out         => x_result_out
                ,x_return_status      => l_return_status
                ,x_msg_count          => l_msg_count
                ,x_msg_data           => l_msg_data
                );
          -- Raise if the l_return_status is unexpected error
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Check_Holds_ATO:G_RET_STS_ERROR') ;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Check_Holds_ATO:G_RET_STS_UNEXP_ERROR') ;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END IF; /* l_ato_line_id is NOT NULL */

      IF NVL(l_smc_flag, 'N') = 'Y' AND x_result_out = FND_API.G_FALSE THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CHECK_HOLDS:TOP MODEL LINE ID: ' || L_TOP_MODEL_LINE_ID ) ;
        END IF;

        /*
        ** Fix Bug # 2984023
        ** Following replaced by a single call to Check_Holds_SMC

        OPEN smc_lines;
        loop

          FETCH smc_lines into l_line_id;
          exit when smc_lines%NOTFOUND OR (x_result_out = FND_API.G_TRUE);

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK_HOLDS: CHECKING SMC LINEID' || L_LINE_ID ) ;
          END IF;

          Check_Holds_line (
                 p_hdr_id             => p_hdr_id
                ,p_line_id            => l_line_id
                ,p_hold_id            => p_hold_id
                ,p_wf_item            => p_wf_item
                ,p_wf_activity        => p_wf_activity
                ,p_entity_code        => p_entity_code
                ,p_entity_id          => p_entity_id
                ,p_entity_code2       => p_entity_code2
                ,p_entity_id2         => p_entity_id2
                ,p_chk_act_hold_only  => p_chk_act_hold_only
                ,x_result_out         => x_result_out
                ,x_return_status      => l_return_status
                ,x_msg_count          => l_msg_count
                ,x_msg_data           => l_msg_data
                );
        end loop;
        */

          Check_Holds_SMC (
                 p_hdr_id             => p_hdr_id
                ,p_top_model_line_id  => l_top_model_line_id
                ,p_hold_id            => p_hold_id
                ,p_wf_item            => p_wf_item
                ,p_wf_activity        => p_wf_activity
                ,p_entity_code        => p_entity_code
                ,p_entity_id          => p_entity_id
                ,p_entity_code2       => p_entity_code2
                ,p_entity_id2         => p_entity_id2
                ,p_chk_act_hold_only  => p_chk_act_hold_only
                ,x_result_out         => x_result_out
                ,x_return_status      => l_return_status
                ,x_msg_count          => l_msg_count
                ,x_msg_data           => l_msg_data
                );
          -- Raise if the l_return_status is unexpected error
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Check_Holds_SMC:G_RET_STS_ERROR') ;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Check_Holds_SMC:G_RET_STS_UNEXP_ERROR') ;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END IF; /* l_smc_flag = 'Y' */
      --5737464
      IF NVL(l_smc_flag, 'N') = 'N' AND x_result_out = FND_API.G_FALSE  THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK_HOLDS: CHECKING FOR CONFIG VALIDATION HOLD' || L_TOP_MODEL_LINE_ID ) ;
         END IF;
       IF l_cascade_hold_non_smc <> 'Y' THEN --ER#7479609
         Check_Holds_SMC (
                 p_hdr_id             => p_hdr_id
                ,p_top_model_line_id  => l_top_model_line_id
                ,p_hold_id            => 3
                ,p_wf_item            => p_wf_item
                ,p_wf_activity        => p_wf_activity
                ,p_entity_code        => p_entity_code
                ,p_entity_id          => p_entity_id
                ,p_entity_code2       => p_entity_code2
                ,p_entity_id2         => p_entity_id2
                ,p_chk_act_hold_only  => p_chk_act_hold_only
                ,x_result_out         => x_result_out
                ,x_return_status      => l_return_status
                ,x_msg_count          => l_msg_count
                ,x_msg_data           => l_msg_data
                );
       --ER#7479609 start
       ELSE
         Check_Holds_SMC (
                 p_hdr_id             => p_hdr_id
                ,p_top_model_line_id  => l_top_model_line_id
                ,p_hold_id            => p_hold_id
                ,p_wf_item            => p_wf_item
                ,p_wf_activity        => p_wf_activity
                ,p_entity_code        => p_entity_code
                ,p_entity_id          => p_entity_id
                ,p_entity_code2       => p_entity_code2
                ,p_entity_id2         => p_entity_id2
                ,p_chk_act_hold_only  => p_chk_act_hold_only
                ,x_result_out         => x_result_out
                ,x_return_status      => l_return_status
                ,x_msg_count          => l_msg_count
                ,x_msg_data           => l_msg_data
                );
       END IF;
       --ER#7479609 end

      END IF;--NON SMC Config Validation Hold
      --5737464

      IF l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED AND x_result_out = FND_API.G_FALSE THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CHECK_HOLDS: CHECKING HOLD ON LINK TO LINE ID: ' || L_LINK_TO_LINE_ID ) ;
        END IF;

        Check_Holds_line (
                 p_hdr_id             => p_hdr_id
                ,p_line_id            => l_link_to_line_id
                ,p_hold_id            => p_hold_id
                ,p_wf_item            => p_wf_item
                ,p_wf_activity        => p_wf_activity
                ,p_entity_code        => p_entity_code
                ,p_entity_id          => p_entity_id
                ,p_entity_code2       => p_entity_code2
                ,p_entity_id2         => p_entity_id2
                ,p_chk_act_hold_only  => p_chk_act_hold_only
                ,p_ii_parent_flag     => 'Y'
                ,x_result_out         => x_result_out
                ,x_return_status      => l_return_status
                ,x_msg_count          => l_msg_count
                ,x_msg_data           => l_msg_data
                );
        -- Raise if the l_return_status is unexpected error
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Check_Holds_line:G_RET_STS_ERROR') ;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Check_Holds_line:G_RET_STS_UNEXP_ERROR') ;
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF; /* l_item_type_code = 'INCLUDED' */

    END IF; /* Proceed only if there is no hold on the line */

  END IF; /* IF LINE ID IS NOT NULL */

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_HOLDS_PUB.CHECK_HOLDS' ) ;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_result_out := FND_API.G_FALSE;
        FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_result_out := FND_API.G_FALSE;
         FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_result_out := FND_API.G_FALSE;
        IF 	FND_MSG_PUB.Check_Msg_Level
        	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg
        		(   G_PKG_NAME
                	,   l_api_name
                	);
        END IF;
        FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);

END Check_Holds;


/******************************************************************
*  CHECK HOLD_SOURCES                                             *
*  Checks if there are any holds for a Hold entity combination.   *
*  Expects at least the hold_entity_code or hold_entity_id        *
******************************************************************/
PROCEDURE Check_Hold_Sources
(   p_api_version		IN	NUMBER
,   p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_validation_level	IN	NUMBER 	 DEFAULT FND_API.G_VALID_LEVEL_FULL
,   p_hold_id			IN	NUMBER DEFAULT NULL
,   p_wf_item			IN 	VARCHAR2 DEFAULT NULL
,   p_wf_activity		IN 	VARCHAR2 DEFAULT NULL
,   p_hold_entity_code		IN      VARCHAR2 DEFAULT NULL
--ER#7479609 ,   p_hold_entity_id		IN	NUMBER DEFAULT NULL
,   p_hold_entity_id		IN	oe_hold_sources_all.hold_entity_id%TYPE DEFAULT NULL   --ER#7479609
,   p_hold_entity_code2		IN      VARCHAR2 DEFAULT NULL
--ER#7479609 ,   p_hold_entity_id2		IN	NUMBER DEFAULT NULL
,   p_hold_entity_id2		IN	oe_hold_sources_all.hold_entity_id2%TYPE DEFAULT NULL  --ER#7479609
,   p_chk_act_hold_only  IN   VARCHAR2 DEFAULT 'N'
,   x_result_out		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   x_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   x_msg_count		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   x_msg_data			OUT NOCOPY /* file.sql.39 change */	VARCHAR2
)
IS
l_api_name		CONSTANT VARCHAR2(30) := 'Check_Hold_Sources';
l_api_version		CONSTANT NUMBER := 1.0;
l_dummy			VARCHAR2(30);

 l_return_status    VARCHAR2(30);
 l_msg_count        NUMBER;
 l_msg_data         VARCHAR2(2000);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'IN OE_HOLDS_PUB.CHECK_HOLD_SOURCES' ) ;
 END IF;
 -- Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Initialize result to TRUE i.e. holds are found
 x_result_out := FND_API.G_TRUE;


 -- Check for Missing Input Parameters
 IF p_hold_entity_code IS NULL AND p_hold_entity_id IS NULL THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER HOLD_ENTITY_CODE OR HOLD_ENTITY_ID' ) ;
   END IF;
   /* TO_DO: Seed a more meaningfull message */
   FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CONBINATION');
   OE_MSG_PUB.ADD;
   RAISE FND_API.G_EXC_ERROR;

 END IF;

 /******************************/
 /* CHECKING FOR HOLDS SOURCES */
 /******************************************************************
 **  Checking for any generic holds and activity_specific holds   **
 **  Sources                                                      **
 ******************************************************************/
 BEGIN

      SELECT 'ANY_HOLD_SOURCE'
        INTO l_dummy
        FROM oe_hold_sources_all     hs,
             oe_hold_definitions h
       WHERE hs.hold_id = h.hold_id
         AND NVL(h.item_type,
                 DECODE(p_chk_act_hold_only,
                        'Y', 'XXXXX',
                             NVL(p_wf_item, 'NO ITEM')) ) =
                 NVL(p_wf_item, 'NO ITEM')
         AND NVL(h.activity_name,
                 DECODE(p_chk_act_hold_only,
                        'Y', 'XXXXX',
                             NVL(p_wf_activity, 'NO ACT')) ) =
                 NVL(p_wf_activity, 'NO ACT')
         AND hs.hold_id = NVL(p_hold_id, hs.hold_id)
         AND hs.RELEASED_FLAG = 'N'
         AND hs.hold_entity_code = NVL(p_hold_entity_code, hs.hold_entity_code)
         AND hs.hold_entity_id = NVL(p_hold_entity_id, hs.hold_entity_id)
         AND NVL(hs.hold_entity_code2, 'NO_ENTITY_CODE2') =
             NVL(p_hold_entity_code2, nvl(hs.hold_entity_code2,'NO_ENTITY_CODE2') )
         AND NVL(hs.hold_entity_id2, -99) =
             nvl(p_hold_entity_id2, NVL(hs.hold_entity_id2, -99 ) );

 EXCEPTION
      WHEN NO_DATA_FOUND THEN
            x_result_out := FND_API.G_FALSE;
      WHEN TOO_MANY_ROWS THEN
            null;
 END;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_result_out := FND_API.G_FALSE;
        FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_result_out := FND_API.G_FALSE;
         FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_result_out := FND_API.G_FALSE;
        IF 	FND_MSG_PUB.Check_Msg_Level
        	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg
        		(   G_PKG_NAME
                	,   l_api_name
                	);
        END IF;
        FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);

END Check_Hold_Sources;




--------------------------------------------------------------------------
-- RELEASE HOLDS
-- Take Release Action on a Hold.
-- Note: Leaving this call for backward compatibility. AR's Customer form
--       still calls the old oe_holds (OEXOHAPB.pls) which in turns calls
--       this api.
-- ALL NEW Callers should call the new api structure
--------------------------------------------------------------------------
PROCEDURE Release_Holds
(   p_api_version		IN	NUMBER DEFAULT 1.0
,   p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_validation_level	IN	NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
,   p_header_id		IN	NUMBER DEFAULT NULL
,   p_line_id			IN	NUMBER DEFAULT NULL
,   p_hold_id			IN	NUMBER DEFAULT NULL
,   p_entity_code		IN	VARCHAR2 DEFAULT NULL
,   p_entity_id		IN	NUMBER DEFAULT NULL
,   p_entity_code2		IN	VARCHAR2 DEFAULT NULL
,   p_entity_id2		IN	NUMBER DEFAULT NULL
,   p_hold_release_rec	IN	OE_Hold_Sources_Pvt.Hold_Release_REC
,   p_check_authorization_flag IN VARCHAR2 DEFAULT 'N'   -- bug 8477694
,   x_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   x_msg_count		OUT NOCOPY /* file.sql.39 change */ 	NUMBER
,   x_msg_data			OUT NOCOPY /* file.sql.39 change */	VARCHAR2
)
IS
l_api_name		CONSTANT VARCHAR2(30) := 'RELEASE_HOLDS';
l_api_version		CONSTANT NUMBER := 1.0;
l_user_id		NUMBER;
l_dummy			VARCHAR2(30);
l_hold_release_id	NUMBER;
l_hold_source_id	NUMBER 	:= 0;
l_order_hold_id		NUMBER := 0;
--ER#7479609 l_entity_code		VARCHAR2(1);
l_entity_code		oe_hold_sources_all.hold_entity_code%TYPE;  --ER#7479609

l_hold_source_rec  OE_HOLDS_PVT.hold_source_rec_type;
l_hold_release_rec OE_HOLDS_PVT.Hold_Release_Rec_Type;
l_org_id number;
l_check_authorization_flag varchar2(1):='N'; -- bug 8477694
--  Define Cursors
CURSOR hold_source IS
	SELECT  HS.HOLD_SOURCE_ID,OH.ORDER_HOLD_ID
	FROM	OE_HOLD_SOURCES HS, OE_ORDER_HOLDS OH
	WHERE	HS.HOLD_ID = p_hold_id
	AND	HS.RELEASED_FLAG = 'N'
	AND	NVL(HS.HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE
	AND	HS.HOLD_ENTITY_CODE = p_entity_code
	AND	HS.HOLD_ENTITY_ID = p_entity_id
	AND	nvl(HS.HOLD_ENTITY_CODE2, 'NO_ENTITY_CODE2') =
		   nvl(p_entity_code2, 'NO_ENTITY_CODE2')
	AND	nvl(HS.HOLD_ENTITY_ID2, -99) =
		   nvl(p_entity_id2, -99)
	AND	OH.HOLD_SOURCE_ID = HS.HOLD_SOURCE_ID
	AND	NVL(OH.HEADER_ID, 0) = NVL(NVL(p_header_id, OH.HEADER_ID), 0)
	AND	NVL(OH.LINE_ID, 0) = NVL(NVL(p_line_id, OH.LINE_ID), 0)
	AND     OH.HOLD_RELEASE_ID IS NULL;
CURSOR order_hold IS
        SELECT  OH.ORDER_HOLD_ID
	FROM	OE_ORDER_HOLDS OH
	WHERE	OH.HOLD_SOURCE_ID = l_hold_source_id
	AND	NVL(OH.HEADER_ID, 0) = NVL(NVL(p_header_id, OH.HEADER_ID), 0)
	AND	NVL(OH.LINE_ID, 0) = NVL(NVL(p_line_id, OH.LINE_ID), 0)
	AND     OH.HOLD_RELEASE_ID IS NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 l_check_authorization_flag := p_check_authorization_flag; -- bug 8477694
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'IN RELEASE_HOLDS , OLD' ) ;
 END IF;

 l_org_id := MO_GLOBAL.get_current_org_id;
 IF l_org_id IS NULL THEN
         -- org_id is null, raise an error.
         oe_debug_pub.add('Org_Id is NULL',1);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

 -- Standard Start of API savepoint
 SAVEPOINT Release_holds_PUB;

 -- Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;


 Utilities(l_user_id);

	-------------------------------------------------------------------
	-- Hold Source ID is KNOWN. Release the hold for this order or
	-- line that uses this hold source.
	-------------------------------------------------------------------
  	IF p_hold_release_rec.hold_source_id IS NOT NULL THEN

	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'USING HOLD SOURCE ID' ) ;
	  END IF;
       l_hold_source_id := p_hold_release_rec.hold_source_id;

  	  BEGIN
   		-- Retrieving the entity code for this hold source
		-- Checking if its a valid hold source id
          SELECT hold_entity_code
            INTO l_entity_code
            FROM OE_HOLD_SOURCES
           WHERE hold_source_id = l_hold_source_id;

   	  EXCEPTION
     		WHEN NO_DATA_FOUND THEN
         		FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_HOLD_SOURCE');
    	 		OE_MSG_PUB.ADD;
    	 		RAISE FND_API.G_EXC_ERROR;
     		WHEN OTHERS THEN
         		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	  END;

          -- Retrieving order hold information
          OPEN order_hold;
          FETCH order_hold INTO l_order_hold_id;
          IF order_hold%notfound THEN
   	 	   FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_HOLD');
   	 	   OE_MSG_PUB.ADD;
   	 	   RAISE FND_API.G_EXC_ERROR;
          END IF;
          CLOSE order_hold;

	-------------------------------------------------------------------
	-- Hold Source ID is NOT KNOWN. Query up the hold source
	-- and then release the order hold using this hold source.
	-------------------------------------------------------------------

	ELSE
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'HOLD SOURCE ID IS NOT PASSED' ) ;
       END IF;
       --  Check for Missing Values
       IF p_hold_id IS NULL THEN
	    	   FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_HOLD_ID');
	    	   OE_MSG_PUB.ADD;
	    	   RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_entity_code IS NULL THEN
	    	   FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_ENTITY_CODE');
	    	   OE_MSG_PUB.ADD;
         	   RAISE FND_API.G_EXC_ERROR;
       ELSE
    	        l_entity_code := p_entity_code;
       END IF;

       IF p_entity_id IS NULL THEN
	    	  FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_ENTITY_ID');
	    	  OE_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
       END IF;

          /*
          IF p_line_id IS NULL AND p_header_id IS NULL THEN
	    	  FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_HEADER_AND_LINE_ID');
	    	  OE_MSG_PUB.ADD;
    		  RAISE FND_API.G_EXC_ERROR;
          END IF;
          */

          -- Retrieving hold source and order hold information
/*
        OPEN hold_source;
        FETCH hold_source INTO l_hold_source_id, l_order_hold_id;
        IF hold_source%notfound THEN
    	      FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_HOLD');
    	 	 OE_MSG_PUB.ADD;
    	 	 RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE hold_source;
*/

	END IF;  -- End of check to see if hold source ID is passed

   -- Check to see if the Site code is Bill_to OR Ship_to
   l_hold_source_rec.hold_id := p_hold_id;
   IF p_entity_code = 'S' THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CHECKING FOR SITE CODE , BILL TO OR SHIP TO' , 1 ) ;
     END IF;
     l_hold_source_rec.hold_entity_code := Hold_Site_Code(p_entity_id);
   ELSE
     l_hold_source_rec.hold_entity_code := p_entity_code;
   END IF;

   l_hold_source_rec.hold_entity_id := p_entity_id;
   l_hold_release_rec.RELEASE_REASON_CODE :=
                               p_hold_release_rec.RELEASE_REASON_CODE;
   l_hold_release_rec.RELEASE_COMMENT  := p_hold_release_rec.RELEASE_COMMENT;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CALLING RELEASE HOLDS , OLD' ) ;
   END IF;
   oe_holds_pvt.Release_Holds(
     p_hold_source_rec     =>  l_hold_source_rec
    ,p_hold_release_rec    =>  l_hold_release_rec
    ,p_check_authorization_flag => l_check_authorization_flag -- bug 8477694
    ,x_return_status       =>  x_return_status
    ,x_msg_count           =>  x_msg_count
    ,x_msg_data            =>  x_msg_data
                  );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OE_HOLDS_PVT.RELEASE_HOLDS STATUS:' || X_RETURN_STATUS ) ;
     END IF;

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
 		IF x_return_status = FND_API.G_RET_STS_ERROR THEN
 			RAISE FND_API.G_EXC_ERROR;
 		ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
 			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 		END IF;
 	END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO RELEASE_HOLDS_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO RELEASE_HOLDS_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    WHEN OTHERS THEN
        ROLLBACK TO RELEASE_HOLDS_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF 	FND_MSG_PUB.Check_Msg_Level
        	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg
        		(   G_PKG_NAME
                	,   l_api_name
                	);
        END IF;
        FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);

END Release_Holds;


----------------------------------------------------------------------------
--  Delete Holds
--  Deletes from OE_ORDER_HOLDS all hold records for an order (p_header_id)
--  or for a line (p_line_id).
--  Also, if there are ORDER hold sources (hold_entity_code = 'O') for this
--  order, deletes hold source records from OE_HOLD_SOURCES.
--  If the hold or hold source was released and the same release record is
--  not used by an existing hold or hold source, then deletes the
--  release record also from OE_HOLD_RELEASES;
----------------------------------------------------------------------------
PROCEDURE Delete_Holds
(   p_header_id      IN	NUMBER   DEFAULT FND_API.G_MISS_NUM
   ,p_line_id        IN	NUMBER   DEFAULT FND_API.G_MISS_NUM
)
IS
l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_HOLDS';
l_api_version		CONSTANT NUMBER := 1.0;
l_order_hold_id		NUMBER;
l_hold_source_id	NUMBER;
l_hold_release_id	NUMBER := 0;
x_RETURN_STATUS   varchar2(56);
x_MSG_COUNT         number;
x_msg_data        varchar2(500);
l_org_id number;

CURSOR order_hold IS
	SELECT order_hold_id, NVL(hold_release_id,0)
	FROM OE_ORDER_HOLDS
	WHERE HEADER_ID = p_header_id;
CURSOR hold_source IS
	SELECT hold_source_id, NVL(hold_release_id,0)
	FROM OE_HOLD_SOURCES
	WHERE HOLD_ENTITY_CODE = 'O'
	  AND HOLD_ENTITY_ID = p_header_id;
CURSOR line_hold IS
	SELECT order_hold_id, NVL(hold_release_id,0)
	FROM OE_ORDER_HOLDS
	WHERE LINE_ID = p_line_id;

--ER#7479609 start
CURSOR line_hold_opt_item(p_top_model_line_id NUMBER,p_inventory_item_id NUMBER) IS
	 SELECT OH.order_hold_id, NVL(OH.hold_release_id,0)
	 FROM OE_ORDER_HOLDS OH,OE_HOLD_SOURCES HS,OE_ORDER_LINES OL
	 WHERE OH.LINE_ID = p_top_model_line_id
	   AND OH.LINE_ID = OL.LINE_ID
	   AND OH.hold_source_id=HS.hold_source_id
	   AND HS.hold_entity_id=OL.inventory_item_id
	   AND HS.hold_entity_id2=p_inventory_item_id;

l_top_model_line_id	OE_ORDER_LINES_ALL.TOP_MODEL_LINE_ID%TYPE;
l_inventory_item_id	OE_ORDER_LINES_ALL.INVENTORY_ITEM_ID%TYPE;
--ER#7479609 end

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 l_org_id := MO_GLOBAL.get_current_org_id;
 IF l_org_id IS NULL THEN
         -- org_id is null, raise an error.
         oe_debug_pub.add('Org_Id is NULL',1);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

  --SAVEPOINT DELETE_HOLDS_PUB;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Missing Input arguments

  IF (p_header_id = FND_API.G_MISS_NUM AND
      p_line_id   = FND_API.G_MISS_NUM) THEN

	FND_MESSAGE.SET_NAME('ONT', 'OE_ENTER_HEADER_OR_LINE_ID');
	OE_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;

  END IF;

  --  Delete the hold records corr. to this order or line in OE_ORDER_HOLDS
  IF p_line_id = FND_API.G_MISS_NUM THEN

    -- Delete order hold records
    OPEN order_hold;
    LOOP
      FETCH order_hold INTO l_order_hold_id, l_hold_release_id;
      IF (order_hold%notfound) THEN
          EXIT;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETING ORDER HOLD RECORD' ) ;
      END IF;

      DELETE FROM OE_ORDER_HOLDS
    	  WHERE order_hold_id = l_order_hold_id;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETING HOLD RELEASE RECORD' ) ;
      END IF;
      DELETE FROM OE_HOLD_RELEASES
       WHERE HOLD_RELEASE_ID = l_hold_release_id
         AND ORDER_HOLD_ID   = l_order_hold_id;

   /* DELETE FROM OE_HOLD_RELEASES
       WHERE HOLD_RELEASE_ID = l_hold_release_id
         AND HOLD_RELEASE_ID NOT IN (SELECT NVL(HOLD_RELEASE_ID,0)
                                       FROM OE_ORDER_HOLDS
     					       UNION
     					       SELECT NVL(HOLD_RELEASE_ID,0)
     					         FROM OE_HOLD_SOURCES
     					      ); */
    END LOOP;

    CLOSE order_hold;

    -- Delete hold source records

    OPEN hold_source;
    LOOP
      FETCH hold_source INTO l_hold_source_id, l_hold_release_id;
      IF (hold_source%notfound) THEN
         EXIT;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETING HOLD SOURCE RECORD' ) ;
      END IF;
      DELETE FROM  OE_HOLD_SOURCES
       WHERE HOLD_SOURCE_ID = l_hold_source_id;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETING HOLD RELEASE RECORD' ) ;
      END IF;
      DELETE FROM OE_HOLD_RELEASES
       WHERE HOLD_RELEASE_ID = l_hold_release_id;

    END LOOP;
    CLOSE hold_source;

  ELSE
    -- Delete line hold records

    OPEN line_hold;

    LOOP
      FETCH line_hold INTO l_order_hold_id, l_hold_release_id;
      IF (line_hold%notfound) THEN
        EXIT;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETING LINE HOLD RECORD' ) ;
      END IF;

      DELETE FROM OE_ORDER_HOLDS
       WHERE order_hold_id = l_order_hold_id;

      DELETE FROM OE_HOLD_RELEASES
       WHERE HOLD_RELEASE_ID = l_hold_release_id
         AND ORDER_HOLD_ID   = l_order_hold_id;

/*         AND HOLD_RELEASE_ID NOT IN
                       (SELECT NVL(HOLD_RELEASE_ID,0)
     	    	  		 FROM OE_ORDER_HOLDS
                        UNION
                        SELECT NVL(HOLD_RELEASE_ID,0)
     				 FROM OE_HOLD_SOURCES
                       );  */
    END LOOP;

    CLOSE line_hold;

--ER#7479609 start
    BEGIN
    select top_model_line_id,inventory_item_id
    into l_top_model_line_id,l_inventory_item_id
    from oe_order_lines
    where line_id=p_line_id
    and item_type_code in ('OPTION','CLASS','INCLUDED');

    OPEN line_hold_opt_item(l_top_model_line_id,l_inventory_item_id);

    LOOP
      FETCH line_hold_opt_item INTO l_order_hold_id, l_hold_release_id;
      IF (line_hold_opt_item%notfound) THEN
        EXIT;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETING LINE HOLD RECORD FOR TOP MODEL WHEN OPTION ITEM LINE IS DELETED' ) ;
      END IF;

      DELETE FROM OE_ORDER_HOLDS
       WHERE order_hold_id = l_order_hold_id;

      DELETE FROM OE_HOLD_RELEASES
       WHERE HOLD_RELEASE_ID = l_hold_release_id
         AND ORDER_HOLD_ID   = l_order_hold_id;
    END LOOP;

    CLOSE line_hold_opt_item;

    EXCEPTION
    WHEN OTHERS THEN
       NULL;
    END;
--ER#7479609 end

  END IF;


EXCEPTION
    	WHEN FND_API.G_EXC_ERROR THEN
    		IF (order_hold%isopen) THEN
    			CLOSE order_hold;
    		END IF;
    		IF (hold_source%isopen) THEN
    			CLOSE hold_source;
    		END IF;
    		IF (line_hold%isopen) THEN
    			CLOSE line_hold;
    		END IF;
        	--ROLLBACK TO DELETE_HOLDS_PUB;
        	x_return_status := FND_API.G_RET_STS_ERROR;
        	FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    	WHEN OTHERS THEN
    		IF (order_hold%isopen) THEN
    			CLOSE order_hold;
    		END IF;
    		IF (hold_source%isopen) THEN
    			CLOSE hold_source;
    		END IF;
    		IF (line_hold%isopen) THEN
    			CLOSE line_hold;
    		END IF;
    		--ROLLBACK TO DELETE_HOLDS_PUB;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        	THEN
        		FND_MSG_PUB.Add_Exc_Msg
        				( G_PKG_NAME
                			, l_api_name
                			);
        	END IF;
        	FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
END Delete_Holds;


-------------------------------------------------------------------
-- Procedure: EVAL_HOLD_SOURCE
-- Applies or removes holds if a hold source entity is updated
-- on the order or line.
-------------------------------------------------------------------

PROCEDURE evaluate_holds
             (    p_entity_code      IN   VARCHAR2
			,  p_entity_id        IN   NUMBER
			,  p_hold_entity_code IN   VARCHAR2
			--ER#7479609 ,  p_hold_entity_id	  IN   NUMBER
			,  p_hold_entity_id	  IN oe_hold_sources_all.hold_entity_id%TYPE  --ER#7479609
               ,  x_return_status    OUT NOCOPY /* file.sql.39 change */  VARCHAR2
               ,  x_msg_count        OUT NOCOPY /* file.sql.39 change */  NUMBER
               ,  x_msg_data         OUT NOCOPY /* file.sql.39 change */  VARCHAR2
             )
IS
  l_hold_source_id	   NUMBER	DEFAULT NULL;
  l_order_hold_id      NUMBER	DEFAULT NULL;
  l_return_status      VARCHAR2(30);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  --l_hold_release_rec   OE_Hold_Sources_Pvt.Hold_Release_REC;
  temp                 NUMBER DEFAULT NULL;
  --l_attribute          VARCHAR2(30); --ER#12571983
  l_attribute          VARCHAR2(60); --ER#12571983

  l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type;
  --ER#7479609 l_hold_entity_code   VARCHAR2(1);
  l_hold_entity_code     oe_hold_sources_all.hold_entity_code%TYPE;  --ER#7479609
  --ER#7479609 l_hold_entity_id     NUMBER;
  l_hold_entity_id     oe_hold_sources_all.hold_entity_id%TYPE;  --ER#7479609
  --ER#7479609 l_hold_entity_code2  VARCHAR2(1);
  l_hold_entity_code2  oe_hold_sources_all.hold_entity_code2%TYPE;  --ER#7479609
  --ER#7479609 l_hold_entity_id2    NUMBER;
  l_hold_entity_id2    oe_hold_sources_all.hold_entity_id2%TYPE;  --ER#7479609
  l_hold_id            NUMBER;

  l_create_order_hold_flag VARCHAR2(1) := 'Y';
  --l_line_rec                    OE_Order_PUB.Line_Rec_Type;

  l_header_id          NUMBER    DEFAULT NULL;
  l_line_id            NUMBER    DEFAULT NULL;
  l_line_number        NUMBER DEFAULT NULL;

  l_sold_to_org_id      NUMBER DEFAULT NULL;
  l_invoice_to_org_id   NUMBER DEFAULT NULL;
  l_ship_to_org_id      NUMBER DEFAULT NULL;
  l_ship_from_org_id    NUMBER DEFAULT NULL;
  l_inventory_item_id   NUMBER DEFAULT NULL;
  l_blanket_number      NUMBER DEFAULT NULL;
  l_blanket_line_number NUMBER DEFAULT NULL;

  -- ER#3667551 start
	 l_bth_entity_code VARCHAR2(10):= '';
	 l_bth_hold_id NUMBER := '';
-- ER#3667551 end

  --
--ER#7479609 CURSOR prev_hold IS
CURSOR prev_hold(l_all_del_pay VARCHAR2) IS     --ER#7479609
     --ER#7479609 SELECT HS.hold_entity_id, OH.order_hold_id
     SELECT HS.hold_entity_id, OH.order_hold_id,HS.hold_entity_code  --ER#7479609
       FROM OE_HOLD_SOURCES HS, OE_ORDER_HOLDS OH
       WHERE OH.HEADER_ID = l_header_id
         AND NVL(OH.LINE_ID,FND_API.G_MISS_NUM) =
			   NVL(l_line_id,FND_API.G_MISS_NUM)
         AND OH.HOLD_SOURCE_ID = HS.HOLD_SOURCE_ID
         AND HS.HOLD_ENTITY_ID = DECODE(l_all_del_pay,'N',p_hold_entity_id,HS.HOLD_ENTITY_ID)  --ER#7479609
		 --AND HS.HOLD_ENTITY_CODE = p_hold_entity_code -- ER#3667551
         AND HS.HOLD_ENTITY_CODE = NVL(l_bth_entity_code,p_hold_entity_code) -- ER#3667551
		 AND HS.HOLD_ID = NVL(l_bth_hold_id,HS.HOLD_ID) -- ER#3667551
         AND HS.RELEASED_FLAG = 'N';

--ER#7479609 CURSOR prev_hold_entity2 IS
CURSOR prev_hold_entity2(l_all_del_pay VARCHAR2) IS  --ER#7479609
     --ER#7479609 SELECT HS.hold_entity_id, OH.order_hold_id
     SELECT HS.hold_entity_id, OH.order_hold_id,HS.hold_entity_code2 --ER#7479609
       FROM OE_HOLD_SOURCES HS, OE_ORDER_HOLDS OH
       WHERE OH.HEADER_ID = l_header_id
         AND NVL(OH.LINE_ID,FND_API.G_MISS_NUM) =
                  NVL(l_line_id,FND_API.G_MISS_NUM)
         AND OH.HOLD_SOURCE_ID = HS.HOLD_SOURCE_ID
		 --AND HS.HOLD_ENTITY_CODE2 = p_hold_entity_code -- ER#3667551
         AND HS.HOLD_ENTITY_CODE2 = NVL(l_bth_entity_code,p_hold_entity_code) -- ER#3667551
         AND HS.HOLD_ENTITY_ID2 = DECODE(l_all_del_pay,'N',p_hold_entity_id,HS.HOLD_ENTITY_ID2)  --ER#7479609
		 AND HS.HOLD_ID = NVL(l_bth_hold_id,HS.HOLD_ID) -- ER#3667551
         AND HS.HOLD_ENTITY_CODE <> 'O'
         AND HS.RELEASED_FLAG = 'N';

CURSOR curr_hold_source IS
     SELECT HS.hold_source_id, hs.hold_id,
            hs.hold_entity_code, hs.hold_entity_id,
            hs.hold_entity_code2,hs.hold_entity_id2
       FROM OE_HOLD_SOURCES HS, OE_HOLD_definitions HLD
       --WHERE HS.HOLD_ENTITY_CODE = p_hold_entity_code -- ER#3667551
	   WHERE HS.HOLD_ENTITY_CODE = NVL(l_bth_entity_code,p_hold_entity_code) -- ER#3667551
	     AND HS.HOLD_ID = NVL(l_bth_hold_id,HS.HOLD_ID) -- ER#3667551
         AND HS.HOLD_ENTITY_ID = p_hold_entity_id
         AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                     ROUND( SYSDATE )
    	    AND HS.RELEASED_FLAG = 'N'
         AND HLD.HOLD_ID = HS.HOLD_ID
         AND SYSDATE
               BETWEEN NVL( HLD.START_DATE_ACTIVE, SYSDATE )
                   AND NVL( HLD.END_DATE_ACTIVE, SYSDATE );

CURSOR curr_hold_source_entity2 IS
     SELECT HS.hold_source_id, hs.hold_id,
            hs.hold_entity_code, hs.hold_entity_id,
            hs.hold_entity_code2,hs.hold_entity_id2
       FROM OE_HOLD_SOURCES HS, OE_HOLD_definitions HLD
       --WHERE HS.HOLD_ENTITY_CODE2 = p_hold_entity_code -- ER#3667551
	   WHERE HS.HOLD_ENTITY_CODE2 = NVL(l_bth_entity_code,p_hold_entity_code) -- ER#3667551
	     AND HS.HOLD_ID = NVL(l_bth_hold_id,HS.HOLD_ID) -- ER#3667551
         AND HS.HOLD_ENTITY_ID2 = p_hold_entity_id
         AND HS.HOLD_ENTITY_CODE <> 'O'
         AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                     ROUND( SYSDATE )
         AND HS.RELEASED_FLAG = 'N'
         AND HLD.HOLD_ID = HS.HOLD_ID
         AND SYSDATE
               BETWEEN NVL( HLD.START_DATE_ACTIVE, SYSDATE )
                   AND NVL( HLD.END_DATE_ACTIVE, SYSDATE );

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
--ER#7479609  start
l_header_rec	OE_ORDER_HEADERS_ALL%rowtype;
l_line_rec	OE_ORDER_LINES_ALL%rowtype;
TYPE entity_rec IS RECORD (entity_code	oe_hold_sources_all.hold_entity_code%TYPE,
			   entity_id	oe_hold_sources_all.hold_entity_id%TYPE);

TYPE entity_tab IS TABLE OF entity_rec INDEX BY BINARY_INTEGER;

l_entity_tab 	entity_tab;

TYPE payment_type_tab IS TABLE OF OE_PAYMENTS.PAYMENT_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
l_payment_type_tab   payment_type_tab;
pay_idx		NUMBER :=0;
l_all_del_pay   varchar2(1) := 'Y';
--ER#7479609 end
l_valid_itemcat CHAR(1) := ''; --ER#13331078

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING EVALUATE_HOLDS' , 1 ) ;
    END IF;

						 IF l_debug_level  > 0 THEN
						     oe_debug_pub.add(  'ENTITY: '|| P_ENTITY_CODE ||'/' || P_ENTITY_ID ) ;
						 END IF;
							 IF l_debug_level  > 0 THEN
							     oe_debug_pub.add(  'HOLD ENTITY: '|| P_HOLD_ENTITY_CODE ||'/' || P_HOLD_ENTITY_ID ) ;
							 END IF;
    -- ER#3667551 start
	 -- When a delayed request is logged for update of Bill To Customer Of Order header level
	 -- the code is passed as 'BTH' instead of 'C'. This is done because both Custom hold for Sold to Customer
	 -- and Credit Hold for Bill To Customer are created with hold_entity_code as 'C'.
	 -- For update of Bill To Customer we only need to re-evaluate Credit Hold and not Custom Holds.
     If p_hold_entity_code = 'BTH' AND p_entity_code = OE_Globals.G_ENTITY_HEADER then
	 l_bth_entity_code := 'C';
	 l_bth_hold_id := 1;
     ElsIf p_hold_entity_code = 'BTL' AND p_entity_code = OE_Globals.G_ENTITY_LINE then
	 l_bth_entity_code := 'C';
	 l_bth_hold_id := 1;
     Else
	 l_bth_entity_code := '';
	 l_bth_hold_id := '';
     END If;
     -- ER#3667551 end


   --ER#7479609 IF p_entity_code = OE_Globals.G_ENTITY_HEADER THEN
   IF (p_entity_code = OE_Globals.G_ENTITY_HEADER OR
   	p_entity_code = OE_GLOBALS.G_ENTITY_HEADER_PAYMENT) THEN  --ER#7479609
   -- Indicates Header Level action
      l_header_id := p_entity_id;
--ER#7479609 start
   BEGIN
      SELECT * INTO l_header_rec
      FROM oe_order_headers
      WHERE header_id=l_header_id;


    EXCEPTION
        WHEN OTHERS THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'NO HEADER EXISTS' ) ;
            END IF;
            RAISE NO_DATA_FOUND;
    END;
--ER#7479609 end
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'HEADER ID: '|| L_HEADER_ID ) ;
	 END IF;
   --ER#7479609 ELSIF p_entity_code = OE_Globals.G_ENTITY_LINE THEN
   ELSIF (p_entity_code = OE_Globals.G_ENTITY_LINE OR
   	  p_entity_code = OE_GLOBALS.G_ENTITY_LINE_PAYMENT) THEN  --ER#7479609
	l_line_id := p_entity_id;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'LINE ID: '|| L_LINE_ID ) ;
	END IF;
--ER#7479609 start
   BEGIN
      SELECT OH.* INTO l_header_rec
      FROM oe_order_headers OH,oe_order_lines OL
      WHERE OH.header_id=OL.header_id
      AND OL.line_id=l_line_id;

      l_header_id := l_header_rec.header_id;

    EXCEPTION
        WHEN OTHERS THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'NO HEADER EXISTS' ) ;
            END IF;
            RAISE NO_DATA_FOUND;
    END;
--ER#7479609 end

    BEGIN
/*ER#7479609 start
	 SELECT sold_to_org_id,
             invoice_to_org_id,
             ship_to_org_id,
             ship_from_org_id,
             inventory_item_id,
             line_number,
             Blanket_number,
             Blanket_line_number,
             header_id
        INTO l_sold_to_org_id,
             l_invoice_to_org_id,
             l_ship_to_org_id,
             l_ship_from_org_id,
             l_inventory_item_id,
             l_line_number,
             l_blanket_number,
             l_blanket_line_number,
             l_header_id
        FROM oe_order_lines
       WHERE line_id = l_line_id;
ER#7479609 end*/

--ER#7479609 start
      SELECT * INTO l_line_rec
      FROM oe_order_lines
      WHERE line_id = l_line_id;
--ER#7479609 end

        --OE_LINE_UTIL.Query_Row(p_line_id  => l_line_id,
        --                       x_line_rec => l_line_rec);

    EXCEPTION
        WHEN OTHERS THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'NO HEADER ID FOR THIS LINE' ) ;
            END IF;
            --RAISE NO_DATA_FOUND;
		  null;
    END;
    --l_header_id := l_line_rec.header_id;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'HEADER ID: '|| L_HEADER_ID ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'LINE ID: '|| L_LINE_ID ) ;
	END IF;
   END IF;

--ER#7479609 start
IF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER_PAYMENT THEN
     G_PAYMENT_HOLD_APPLIED := 'N';
     BEGIN
     l_payment_type_tab.delete;

     Select payment_type_code payment_type
     BULK COLLECT INTO l_payment_type_tab
     FROM OE_PAYMENTS
     WHERE header_id=l_header_rec.header_id
       AND line_id IS NULL;

     EXCEPTION
      WHEN OTHERS THEN
        null;
     END;

     FOR i in 1 .. l_payment_type_tab.count LOOP
     	evaluate_holds
	(p_entity_code => OE_Globals.G_ENTITY_HEADER
	,  p_entity_id  => l_header_rec.header_id
	,  p_hold_entity_code => 'P'
	,  p_hold_entity_id => l_payment_type_tab(i)
	,  x_return_status =>l_return_status
	,  x_msg_count => l_msg_count
	,  x_msg_data  => l_msg_data
	);
     END LOOP;
     l_payment_type_tab.delete;
     RETURN;
END IF;
--ER#7479609 end

     --ER#7479609 start
     l_all_del_pay := 'Y';
     IF G_HDR_PAYMENT = 'Y' and p_hold_entity_code = 'P' THEN
     	l_all_del_pay := 'N';
     END IF;
     --ER#7479609 end

   --ER#7479609 OPEN prev_hold;
   OPEN prev_hold(l_all_del_pay);  --ER#7479609
   LOOP
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETRIEVING PREV. HOLD RECORD' , 1 ) ;
       END IF;

       -- FETCH prev_hold INTO l_hold_entity_id, l_hold_source_id;
       --ER#7479609 FETCH prev_hold INTO l_hold_entity_id, l_order_hold_id;
       FETCH prev_hold INTO l_hold_entity_id, l_order_hold_id,l_hold_entity_code;  --ER#7479609

       IF (prev_hold%notfound) THEN
		   IF l_debug_level  > 0 THEN
		       oe_debug_pub.add(  'PREV_HOLD NOT FOUND , EXITING.' , 1 ) ;
		   END IF;
       		EXIT;
       END IF;

       IF l_hold_entity_id = p_hold_entity_id THEN
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'SAME ENTITY ID: NEITHER APPLY NOR REMOVE' ) ;
	    END IF;
         --RETURN;
	    exit;
       END IF;

--ER#7479609 start
      IF (l_hold_entity_code='P' and G_PAYMENT_HOLD_APPLIED = 'Y' and p_entity_code = OE_GLOBALS.G_ENTITY_HEADER) THEN
	       IF l_debug_level  > 0 THEN
	           oe_debug_pub.add(  'NOT DELETING HOLD' , 1 ) ;
	       END IF;
      ELSE
--ER#7479609 end
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'DELETING HOLD' , 1 ) ;
       END IF;
       DELETE FROM OE_ORDER_HOLDS
	     WHERE ORDER_HOLD_ID = l_order_hold_id;

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'L_HOLD_ENTITY_ID/P_HOLD_ENTITY_ID/L_ORDER_HOLD_ID:' || L_HOLD_ENTITY_ID || '/' || P_HOLD_ENTITY_ID || '/' || L_ORDER_HOLD_ID ) ;
                 END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'HOLD REMOVED' ) ;
       END IF;
     END IF;  --ER#7479609
       --fnd_message.set_name('ONT','OE_HOLD_REMOVED');
       --OE_MSG_PUB.ADD;
   END LOOP;
   CLOSE prev_hold;

-- prev_hold_entity2

   -- Check for previous hold if the second entity is ('C','S','B','W','H','L')
   --ER#7479609 if p_hold_entity_code in ('C','S','B','W','H','L') then
   --9927494 if p_hold_entity_code in ('B','CD','C','I','O','OT','P','PL','PR','H','SC','S','SM','TM','W','D') then  --ER#7479609
   if p_hold_entity_code in ('B','CB','C','D','LT','OI','OT','PT','P','PL','PR','L','H','SC','SM','S','ST','T','TC','W','CN','EC','EN','EL') then  --9927494 -- ER# 11824468, added 'CN' --ER# 12571983 added 'EC' 'EN'
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CHECKING PREV HOLD SOURCES FOR SECOND ENTITY' ) ;
      END IF;

     --ER#7479609 start
     l_all_del_pay := 'Y';
     IF G_HDR_PAYMENT = 'Y' and p_hold_entity_code = 'P' THEN
     	l_all_del_pay := 'N';
     END IF;
     --ER#7479609 end
     --ER#7479609 OPEN prev_hold_entity2;
     OPEN prev_hold_entity2(l_all_del_pay);  --ER#7479609
     LOOP
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'RETRIEVING PREV. HOLD RECORD FOR ENTITY2' , 1 ) ;
         END IF;

         -- FETCH prev_hold INTO l_hold_entity_id, l_hold_source_id;
         --ER#7479609 FETCH prev_hold_entity2 INTO l_hold_entity_id, l_order_hold_id;
         FETCH prev_hold_entity2 INTO l_hold_entity_id, l_order_hold_id,l_hold_entity_code;  --ER#7479609

         IF (prev_hold_entity2%notfound) THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'PREV_HOLD_ENTITY2 NOT FOUND , EXITING' , 1 ) ;
            END IF;
            EXIT;
         END IF;

         IF l_hold_entity_id = p_hold_entity_id THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'SAME ENTITY ID2: NEITHER APPLY NOR REMOVE' ) ;
           END IF;
           --RETURN;
           EXIT;
         END IF;

--ER#7479609 start
      IF (l_hold_entity_code = 'P' and G_PAYMENT_HOLD_APPLIED = 'Y' and p_entity_code = OE_GLOBALS.G_ENTITY_HEADER) THEN
	       IF l_debug_level  > 0 THEN
	           oe_debug_pub.add(  'NOT DELETING HOLD' , 1 ) ;
	       END IF;
      ELSE
--ER#7479609 end
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'DELETING HOLD' , 1 ) ;
         END IF;
         DELETE FROM OE_ORDER_HOLDS
            WHERE ORDER_HOLD_ID = l_order_hold_id;

                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'L_HOLD_ENTITY_ID/P_HOLD_ENTITY_ID/L_ORDER_HOLD_ID:' || L_HOLD_ENTITY_ID || '/' || P_HOLD_ENTITY_ID || '/' || L_ORDER_HOLD_ID ) ;
                   END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HOLD REMOVED FOR SECOND ENTITY' ) ;
         END IF;
      END IF;  --ER#7479609
         --fnd_message.set_name('ONT','OE_HOLD_REMOVED');
         --OE_MSG_PUB.ADD;
     END LOOP;
     CLOSE prev_hold_entity2;

   end if; -- p_hold_entity_code in ('C','S','B','W')

   G_HDR_PAYMENT := 'N';  --ER#7479609

   OPEN curr_hold_source;
   LOOP
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETRIEVING NEW HOLD SOURCE RECORD' , 1 ) ;
       END IF;
       FETCH curr_hold_source INTO l_hold_source_id, l_hold_id,
                                       l_hold_entity_code,l_hold_entity_id,
                                       l_hold_entity_code2,l_hold_entity_id2;

       IF (curr_hold_source%notfound) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'HOLD SOURCE RECORD NOT FOUND , EXITING' , 1 ) ;
          END IF;
          EXIT;
       END IF;

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'L_HOLD_ENTITY_CODE/L_HOLD_ENTITY_ID/' || 'L_HOLD_ENTITY_CODE2/L_HOLD_ENTITY_ID2/L_HOLD_SOURCE_ID:');
                            oe_debug_pub.add(  ' ' || L_HOLD_ENTITY_CODE || '/' || L_HOLD_ENTITY_ID || '/' || L_HOLD_ENTITY_CODE2 || '/' || L_HOLD_ENTITY_ID2 || '/' || L_HOLD_SOURCE_ID , 1 ) ;
                        END IF;
   -- If second entity is not null, check if order/line is eligible for hold
   l_create_order_hold_flag := 'Y';
   IF l_hold_entity_code2 is not null THEN
     l_create_order_hold_flag := 'N';
/*ER#7479609 start
     IF l_hold_entity_code2 = 'C' THEN
       IF l_sold_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code2 = 'B' THEN
       IF l_invoice_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code2 = 'S' THEN
       IF l_ship_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code2 = 'W' THEN
       IF l_ship_from_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code2 = 'H' THEN
       IF l_blanket_number = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code2 = 'L' THEN
       IF l_blanket_line_number = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     END IF;
ER#7479609 end*/

--ER#7479609 start
     IF p_entity_code = OE_Globals.G_ENTITY_HEADER THEN

     BEGIN
     l_payment_type_tab.delete;

     SELECT V.payment_type
     BULK COLLECT INTO l_payment_type_tab
     FROM
     (Select payment_type_code payment_type
     FROM OE_PAYMENTS
     WHERE header_id=l_header_rec.header_id
       AND line_id IS NULL
     UNION
     SELECT payment_type_code payment_type
     FROM OE_ORDER_HEADERS_ALL
     WHERE header_id=l_header_rec.header_id) V;

     EXCEPTION
      WHEN OTHERS THEN
        null;
     END;

      IF l_hold_entity_code2 = 'OT' THEN
       IF l_header_rec.order_type_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      /*9927494 start
      ELSIF l_hold_entity_code2 = 'PT' THEN
       -- IF l_header_rec.payment_type_code = l_hold_entity_id2 THEN -- commneted for bug 9927494
       IF l_header_rec.payment_term_id = l_hold_entity_id2 THEN -- Added for bug 9927494
         l_create_order_hold_flag := 'Y';
       END IF;
      9927494 end*/
      ELSIF l_hold_entity_code2 = 'TC' THEN
       IF l_header_rec.transactional_curr_code  = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'SC' THEN
       IF l_header_rec.sales_channel_code = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'P' THEN
       FOR pay_idx in 1 .. l_payment_type_tab.count LOOP
        IF (l_payment_type_tab(pay_idx) = l_hold_entity_id2) THEN
          l_create_order_hold_flag := 'Y';
          EXIT;
        END IF;
       END LOOP;
     END IF;

     --ER#7479609 ELSIF p_entity_code = OE_Globals.G_ENTITY_LINE THEN
   ELSIF (p_entity_code = OE_Globals.G_ENTITY_LINE OR
   	  p_entity_code = OE_GLOBALS.G_ENTITY_LINE_PAYMENT) THEN  --ER#7479609

     BEGIN
     l_payment_type_tab.delete;

     Select payment_type_code payment_type
     BULK COLLECT INTO l_payment_type_tab
     FROM OE_PAYMENTS
     WHERE header_id=l_header_rec.header_id
       AND line_id IS NOT NULL;

     EXCEPTION
      WHEN OTHERS THEN
        null;
     END;

      IF l_hold_entity_code2 = 'C' THEN
       IF l_line_rec.sold_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
	   --ER# 11824468 start
	   ELSIF l_hold_entity_code2 = 'CN' THEN
       IF l_line_rec.sold_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
	   --ER# 11824468 end
	   --ER#12571983 start 'EC' 'EN'
	    ELSIF l_hold_entity_code2 IN ('EC','EN') THEN
       IF l_line_rec.end_customer_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
       ELSIF l_hold_entity_code2 ='EL' THEN
       IF l_line_rec.end_customer_site_use_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
	   --ER#12571983 end 'EC' 'EN'
      ELSIF l_hold_entity_code2 = 'B' THEN
       IF l_line_rec.invoice_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'S' THEN
       IF l_line_rec.ship_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'W' THEN
       IF l_line_rec.ship_from_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'O' THEN
       IF l_line_rec.header_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'H' THEN
        IF l_line_rec.blanket_number = l_hold_entity_id2 THEN
          l_create_order_hold_flag := 'Y';
        END IF;
      ELSIF l_hold_entity_code2 = 'L' THEN
        IF l_line_rec.blanket_line_number = l_hold_entity_id2 THEN
          l_create_order_hold_flag := 'Y';
        END IF;

      ELSIF l_hold_entity_code2 = 'LT' THEN
       IF l_line_rec.line_type_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'SM' THEN
       IF l_line_rec.shipping_method_code = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'D' THEN
       IF l_line_rec.deliver_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'ST' THEN
       IF l_line_rec.source_type_code = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'PL' THEN
       IF l_line_rec.price_list_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'PR' THEN
        IF l_line_rec.project_id = l_hold_entity_id2 THEN
          l_create_order_hold_flag := 'Y';
        END IF;
      ELSIF l_hold_entity_code2 = 'PT' THEN
        IF l_line_rec.payment_term_id = l_hold_entity_id2 THEN
          l_create_order_hold_flag := 'Y';
        END IF;

      ELSIF l_hold_entity_code2 = 'OI' THEN
       IF l_line_rec.inventory_item_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'T' THEN
       IF l_line_rec.task_id  = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'CB' THEN
       IF l_line_rec.created_by = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'P' and p_entity_code = OE_GLOBALS.G_ENTITY_LINE_PAYMENT THEN      --ER#7479609
       FOR pay_idx in 1 .. l_payment_type_tab.count LOOP
        IF (l_payment_type_tab(pay_idx) = l_hold_entity_id2) THEN
          l_create_order_hold_flag := 'Y';
          EXIT;
        END IF;
       END LOOP;
      END IF;

     END IF;
--ER#7479609 end
    END IF; -- l_hold_entity_code2 is not null
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_CREATE_ORDER_HOLD_FLAG:' || L_CREATE_ORDER_HOLD_FLAG , 1 ) ;
    END IF;

--ER#7479609 start
    IF p_entity_code = OE_Globals.G_ENTITY_LINE THEN
       -- IF l_hold_entity_code = 'C' and --ER# 11824468
	     IF l_hold_entity_code IN('C','CN') and --ER# 11824468 added 'CN',
      		(l_hold_entity_code2 IS NULL OR
      		 l_hold_entity_code2 = 'OT' OR
      		 --9927494 l_hold_entity_code2 = 'PT' OR
      		 l_hold_entity_code2 = 'P' OR  --9927494
      		 l_hold_entity_code2 = 'TC' OR
      		 l_hold_entity_code2 = 'SC'
      		)  THEN
        l_create_order_hold_flag := 'N';
	--ER 3667551 start
	     If p_hold_entity_code = 'BTL' and l_hold_entity_code ='C' THEN
		l_create_order_hold_flag := 'Y';
	     End If;
	--ER 3667551 end
      END IF;

      IF l_hold_entity_code = 'OT' and (l_hold_entity_code2 = 'TC' OR l_hold_entity_code2 IS NULL)
      THEN
        l_create_order_hold_flag := 'N';
      END IF;

    END IF;
--ER#7479609 end


    IF l_create_order_hold_flag = 'Y' THEN
       l_hold_source_rec.HOLD_ENTITY_CODE  := l_hold_entity_code;
       l_hold_source_rec.HOLD_ENTITY_ID    := l_hold_entity_id;
       l_hold_source_rec.HOLD_ENTITY_CODE2 := l_hold_entity_code2;
       l_hold_source_rec.HOLD_ENTITY_ID2   := l_hold_entity_id2;
       l_hold_source_rec.HOLD_ID           := l_hold_id;
       l_hold_source_rec.hold_source_id    := l_hold_source_id;
       l_hold_source_rec.header_id         := l_header_id;
       l_hold_source_rec.line_id           := l_line_id;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING OE_HOLDS_PVT.CREATE_ORDER_HOLDS' ) ;
       END IF;
       oe_holds_pvt.Create_Order_Holds (
      	  p_hold_source_rec     =>  l_hold_source_rec
      	   ,x_return_status       =>  x_return_status
           ,x_msg_count           =>  x_msg_count
           ,x_msg_data            =>  x_msg_data
                  );

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'X_RETURN_STATUS:' || X_RETURN_STATUS , 1 ) ;
       END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'ERROR AFTER OE_HOLDS_PVT.CREATE_ORDER_HOLDS' ) ;
	     END IF;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       --ER#7479609 start
         IF x_return_status = '0' THEN
       	  G_PAYMENT_HOLD_APPLIED := 'Y';
       	 END IF;
       --ER#7479609 end
       ELSE

 	    IF l_debug_level  > 0 THEN
 	        oe_debug_pub.add(  'HOLD APPLIED' ) ;
 	    END IF;

	    IF p_hold_entity_code = 'C' THEN
	      l_attribute := 'Customer';
	    --ER# 11824468 start
		ELSIF p_hold_entity_code ='CN' THEN
	      l_attribute := 'Customer';
        --ER# 11824468 end
	--ER# 3667551 start
	    ELSIF p_hold_entity_code ='BTH' THEN
	      l_attribute := 'Header Level Bill To Customer';
	    ELSIF p_hold_entity_code ='BTL' THEN
	    l_attribute := 'Line Level Bill To Customer';
	--ER# 3667551 end
        --ER#12571983 added 'EC' 'EN'
	    ELSIF p_hold_entity_code IN ('EC','EN') THEN
	      l_attribute := 'End Customer';
		--ER#12571983 added 'EC' 'EN'
	    ELSIF p_hold_entity_code = 'I' THEN
	      l_attribute := 'Item';
		--ER# 13331078 start
	    ELSIF p_hold_entity_code = 'IC' THEN
	      l_attribute := 'Item Category';
		--ER# 13331078 end
	    ELSIF p_hold_entity_code = 'S' THEN
	      l_attribute := 'Ship to Site';
            ELSIF p_hold_entity_code = 'B' THEN
              l_attribute := 'Bill to Site';
            ELSIF p_hold_entity_code = 'O' then
              l_attribute := 'Order';
            ELSIF p_hold_entity_code = 'W' then
              l_attribute := 'Warehouse';
            ELSIF p_hold_entity_code = 'H' then
              l_attribute := 'Blanket Number';
--ER#7479609 start
            ELSIF l_hold_entity_code = 'TM' THEN
              l_attribute := 'Top Model';
            ELSIF l_hold_entity_code = 'PR' then
              l_attribute := 'Project Number';
            ELSIF l_hold_entity_code = 'PL' then
              l_attribute := 'Price List';
            ELSIF l_hold_entity_code = 'OT' then
                l_attribute := 'Order Type';
            ELSIF l_hold_entity_code = 'CD' THEN
              l_attribute := 'Creation Date';
            ELSIF l_hold_entity_code = 'SC' then
              l_attribute := 'Sales Channel Code';
            ELSIF l_hold_entity_code = 'P' then
              G_PAYMENT_HOLD_APPLIED := 'Y';
              l_attribute := 'Payment Type';
            ELSIF l_hold_entity_code = 'SM' then
              l_attribute := 'Shipping Method Code';
--8254521 start
            ELSIF l_hold_entity_code = 'D' then
              l_attribute := 'Deliver to Site';
--8254521 end
--ER#7479609 end
	    END IF;
         IF l_hold_entity_code2 is not null then
           IF l_hold_entity_code2 = 'C' THEN
             l_attribute := l_attribute || '/' || 'Customer';
           --ER# 11824468 start
			ELSIF l_hold_entity_code2 = 'CN' THEN
             l_attribute := l_attribute || '/' || 'Customer';
            --ER# 11824468 end
            --ER#12571983 added 'EC' 'EN'
	    ELSIF l_hold_entity_code2 IN ('EC','EN') THEN
		l_attribute := l_attribute || '/' || 'End Customer';
	    ELSIF l_hold_entity_code2 ='EL' THEN
		l_attribute := l_attribute || '/' || 'End Customer Location';
	    --ER#12571983 added 'EC' 'EN'
           ELSIF l_hold_entity_code2 = 'S' THEN
               l_attribute := l_attribute || '/' || 'Ship to Site';
             ELSIF l_hold_entity_code2 = 'B' THEN
               l_attribute := l_attribute || '/' || 'Bill to Site';
           ELSIF l_hold_entity_code2 = 'W' then
             l_attribute := l_attribute || '/' || 'Warehouse';
           ELSIF l_hold_entity_code2 = 'H' THEN
                l_attribute := l_attribute || '/' || 'Blanket Number';
           ELSIF l_hold_entity_code2 = 'L' THEN
                l_attribute := l_attribute || '/' || 'Bl Line Number';
--ER#7479609 start
           ELSIF l_hold_entity_code2 = 'LT' THEN
               l_attribute := l_attribute || '/' || 'Line Type';
           ELSIF l_hold_entity_code2 = 'SM' THEN
               l_attribute := l_attribute || '/' || 'Shipping Method Code';
           ELSIF l_hold_entity_code2 = 'D' then
             l_attribute := l_attribute || '/' || 'Deliver to Site';
           ELSIF l_hold_entity_code2 = 'ST' then
             l_attribute := l_attribute || '/' || 'Source Type Code';
           ELSIF l_hold_entity_code2 = 'PL' THEN
             l_attribute := l_attribute || '/' || 'Price List';
           ELSIF l_hold_entity_code2 = 'PR' THEN
             l_attribute := l_attribute || '/' || 'Project Number';
           ELSIF l_hold_entity_code2 = 'PT' THEN
               l_attribute := l_attribute || '/' || 'Payment Term';
           ELSIF l_hold_entity_code2 = 'OI' THEN
               l_attribute := l_attribute || '/' || 'Option Item';
           ELSIF l_hold_entity_code2 = 'T' then
             l_attribute := l_attribute || '/' || 'Task Number';
           ELSIF l_hold_entity_code2 = 'OT' then
             l_attribute := l_attribute || '/' || 'Order Type';
           ELSIF l_hold_entity_code2 = 'P' THEN
             G_PAYMENT_HOLD_APPLIED := 'Y';
             l_attribute := l_attribute || '/' || 'Payment Type';
           ELSIF l_hold_entity_code2 = 'TC' THEN
             l_attribute := l_attribute || '/' || 'Currency';
           ELSIF l_hold_entity_code2 = 'SC' then
             l_attribute := l_attribute || '/' || 'Sales Channel Code';
           ELSIF l_hold_entity_code2 = 'CB' THEN
             l_attribute := l_attribute || '/' || 'Created By';
--ER#7479609 end
           END IF;
         end if;

         IF p_entity_code = OE_Globals.G_ENTITY_HEADER THEN
  		fnd_message.set_name('ONT','OE_HLD_APPLIED');
  		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute);
		OE_MSG_PUB.ADD;
	    --ER#7479609 ELSIF p_entity_code = OE_Globals.G_ENTITY_LINE THEN
	       ELSIF (p_entity_code = OE_Globals.G_ENTITY_LINE OR
   	              p_entity_code = OE_GLOBALS.G_ENTITY_LINE_PAYMENT) THEN
		fnd_message.set_name('ONT','OE_HLD_APPLIED_LINE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute);
	        -- Get the line number from the line record
		--SELECT line_number
		--  INTO l_line_number
		--  FROM OE_ORDER_LINES
		-- WHERE LINE_ID = p_entity_id;
		--FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_number);
		FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_rec.line_number); --8254521
		OE_MSG_PUB.ADD;
 	    END IF;
	  END IF; -- if create_order_hold was successful
    END IF; -- l_create_order_hold_flag = 'Y'
   END LOOP;
   CLOSE curr_hold_source;

  -- Check for Current second entity hold if the entity is ('C','S','B','W','H')
  --ER#7479609 if p_hold_entity_code in ('C','S','B','W','H') then
  if p_hold_entity_code in ('B','CB','C','D','LT','OI','OT','PT','P','PL','PR','L','H','SC','SM','S','ST','T','TC','W','CN','EC','EN','EL') then  --ER#7479609 ----ER# 11824468, added 'CN' --ER#12571983 added 'EC' 'EN'
        -- ADD and p_entity_code = G_ENTITY_LINE ????
   OPEN curr_hold_source_entity2;
   LOOP
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETRIEVING NEW HOLD SOURCE RECORD FOR ENTITY2' , 1 ) ;
       END IF;
       FETCH curr_hold_source_entity2 INTO l_hold_source_id, l_hold_id,
                                       l_hold_entity_code,l_hold_entity_id,
                                       l_hold_entity_code2,l_hold_entity_id2;

       IF (curr_hold_source_entity2%notfound) THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NO HOLD SOURCE FOUND , EXISTING' , 1 ) ;
         END IF;
   		EXIT;
       END IF;

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'L_HOLD_ENTITY_CODE/L_HOLD_ENTITY_ID/' || 'L_HOLD_ENTITY_CODE2/L_HOLD_ENTITY_ID2/L_HOLD_SOURCE_ID:');
                            oe_debug_pub.add(  ' '||L_HOLD_ENTITY_CODE || '/' || L_HOLD_ENTITY_ID || '/' || L_HOLD_ENTITY_CODE2 || '/' || L_HOLD_ENTITY_ID2 || '/' || L_HOLD_SOURCE_ID , 1 ) ;
                        END IF;

   -- If second entity is not null, The First entity can only be I or W
   -- Check if order/line is eligible for hold
     l_create_order_hold_flag := 'N';
/*ER#7479609 start
     IF l_hold_entity_code = 'I' THEN
       IF l_inventory_item_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'W' THEN
       IF l_ship_from_org_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'H' THEN
       IF l_blanket_number = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     END IF;
ER#7479609 end*/

--ER#7479609 start
  IF p_entity_code = OE_Globals.G_ENTITY_HEADER THEN
     IF l_hold_entity_code = 'C' THEN
       IF l_header_rec.sold_to_org_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
	  --ER# 11824468 start
	  ELSIF l_hold_entity_code = 'CN' THEN
       IF l_header_rec.sold_to_org_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      --ER# 11824468 end
     ELSIF l_hold_entity_code = 'PL' THEN
       IF l_header_rec.price_list_id  = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'OT' THEN
       IF l_header_rec.order_type_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
    END IF;

  ELSIF (p_entity_code = OE_Globals.G_ENTITY_LINE OR
   	              p_entity_code = OE_GLOBALS.G_ENTITY_LINE_PAYMENT) THEN
--ER#7479609 end
     IF l_hold_entity_code = 'B' THEN
       IF l_line_rec.invoice_to_org_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'CD' THEN
       IF l_line_rec.creation_date  = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'C' THEN
       IF l_line_rec.sold_to_org_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
	 --ER# 11824468 start
	 ELSIF l_hold_entity_code = 'CN' THEN
       IF l_line_rec.sold_to_org_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     --ER# 11824468 end
	 --ER#12571983 start 'EC' 'EN'
	 ELSIF l_hold_entity_code in( 'EC','EN') THEN
       IF l_line_rec.end_customer_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     --ER#12571983 end 'EC' 'EN'
     ELSIF l_hold_entity_code = 'I' THEN
       IF l_line_rec.inventory_item_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
	   --ER# 13331078 start
	 ELSIF l_hold_entity_code = 'IC' THEN
	   BEGIN
	   select 'Y' into l_valid_itemcat
	   from mtl_item_categories mic,
	   mtl_default_category_sets  mdc
	   where mic.inventory_item_id = l_line_rec.inventory_item_id
	   and mic.organization_id = l_line_rec.ship_from_org_id
	   and mic.category_id = l_hold_entity_id
	   AND mdc.functional_area_id=7
	   AND mdc.category_set_id = mic.category_set_id;
	   EXCEPTION WHEN OTHERS THEN
	   l_valid_itemcat := 'N';
	   END;
	   oe_debug_pub.add('IC- '||l_hold_entity_id||' Item- '||l_line_rec.inventory_item_id||' -Org- '||l_line_rec.ship_from_org_id||' valid-'||l_valid_itemcat);
       IF l_valid_itemcat = 'Y' THEN
         l_create_order_hold_flag := 'Y';
       END IF;
	   --ER# 13331078 end
     ELSIF l_hold_entity_code = 'OT' THEN
       IF l_header_rec.order_type_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'PL' THEN
       IF l_line_rec.price_list_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'PR' THEN
       IF l_line_rec.project_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'H' THEN
       IF l_line_rec.blanket_number = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'S' THEN
       IF l_line_rec.ship_to_org_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'TM' THEN
       IF l_line_rec.inventory_item_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'W' THEN
       IF l_line_rec.ship_from_org_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'D' THEN
       IF l_line_rec.deliver_to_org_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     END IF;
  END IF;
--ER#7479609 end

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_CREATE_ORDER_HOLD_FLAG:' || L_CREATE_ORDER_HOLD_FLAG , 1 ) ;
    END IF;

    IF l_create_order_hold_flag = 'Y' THEN
       l_hold_source_rec.HOLD_ENTITY_CODE  := l_hold_entity_code;
       l_hold_source_rec.HOLD_ENTITY_ID    := l_hold_entity_id;
       l_hold_source_rec.HOLD_ENTITY_CODE2 := l_hold_entity_code2;
       l_hold_source_rec.HOLD_ENTITY_ID2   := l_hold_entity_id2;
       l_hold_source_rec.HOLD_ID           := l_hold_id;
       l_hold_source_rec.hold_source_id    := l_hold_source_id;
       l_hold_source_rec.header_id         := l_header_id;
       l_hold_source_rec.line_id           := l_line_id;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING OE_HOLDS_PVT.CREATE_ORDER_HOLDS' ) ;
       END IF;
       oe_holds_pvt.Create_Order_Holds (
      	  p_hold_source_rec     =>  l_hold_source_rec
      	   ,x_return_status       =>  x_return_status
           ,x_msg_count           =>  x_msg_count
           ,x_msg_data            =>  x_msg_data
                  );

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'X_RETURN_STATUS:' || X_RETURN_STATUS , 1 ) ;
       END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'ERROR AFTER OE_HOLDS_PVT.CREATE_ORDER_HOLDS' ) ;
	    END IF;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

       --ER#7479609 start
         IF x_return_status = '0' THEN
       	  G_PAYMENT_HOLD_APPLIED := 'Y';
       	 END IF;
       --ER#7479609 end

       ELSE
 	    IF l_debug_level  > 0 THEN
 	        oe_debug_pub.add(  'HOLD APPLIED' ) ;
 	    END IF;

	  IF l_hold_entity_code = 'C' THEN
	    l_attribute := 'Customer';
	  --ER# 11824468 start
	ELSIF l_hold_entity_code = 'CN' THEN
	    l_attribute := 'Customer';
    --ER# 11824468 end
	ELSIF l_hold_entity_code = 'I' THEN
	    l_attribute := 'Item';
		--ER# 13331078 start
		ELSIF l_hold_entity_code = 'IC' THEN
	    l_attribute := 'Item Category';
		--ER# 13331078 end
		--ER#12571983 start
		ELSIF l_hold_entity_code IN('EC','EN') THEN
	    l_attribute := 'End Customer';
		--ER#12571983 end
	  ELSIF l_hold_entity_code = 'S' THEN
	    l_attribute := 'Site Use';
          ELSIF l_hold_entity_code = 'B' THEN
            l_attribute := 'Bill to Site';
          ELSIF l_hold_entity_code = 'O' then
            l_attribute := 'Order';
          ELSIF l_hold_entity_code = 'W' then
            l_attribute := 'Warehouse';
          ELSIF l_hold_entity_code = 'H' then
            l_attribute := 'Blanket Number';
--ER#7479609 start
         ELSIF l_hold_entity_code = 'TM' THEN
           l_attribute := 'Top Model';
         ELSIF l_hold_entity_code = 'PR' then
              l_attribute := 'Project Number';
         ELSIF l_hold_entity_code = 'PL' then
              l_attribute := 'Price List';
         ELSIF l_hold_entity_code = 'OT' then
                l_attribute := 'Order Type';
         ELSIF l_hold_entity_code = 'CD' THEN
           l_attribute := 'Creation Date';
         ELSIF l_hold_entity_code = 'SC' then
              l_attribute := 'Sales Channel Code';
         ELSIF l_hold_entity_code = 'P' then
              G_PAYMENT_HOLD_APPLIED := 'Y';
              l_attribute := 'Payment Type';
         ELSIF l_hold_entity_code = 'SM' then
                l_attribute := 'Shipping Method Code';
--8254521 start
         ELSIF l_hold_entity_code = 'D' then
                l_attribute := 'Deliver to Site';
--8254521 end
--ER#7479609 end
	  END IF;

       IF l_hold_entity_code2 is not null then
         IF l_hold_entity_code2 = 'C' THEN
           l_attribute := l_attribute || '/' || 'Customer';
		 --ER# 11824468 start
		 ELSIF l_hold_entity_code2 = 'CN' THEN
           l_attribute := l_attribute || '/' || 'Customer';
         --ER# 11824468 end
        --ER#12571983 start
	 ELSIF l_hold_entity_code2 in ('EC','EN') THEN
           l_attribute := l_attribute || '/' || 'End Customer';
	 ELSIF l_hold_entity_code2 in ('EL') THEN
           l_attribute := l_attribute || '/' || 'End Customer Location';
        --ER#12571983 end
         ELSIF l_hold_entity_code2 = 'S' THEN
           l_attribute := l_attribute || '/' || 'Ship to Site';
           ELSIF l_hold_entity_code2 = 'B' THEN
           l_attribute := l_attribute || '/' || 'Bill to Site';
         ELSIF l_hold_entity_code2 = 'W' then
           l_attribute := l_attribute || '/' || 'Warehouse';
         ELSIF l_hold_entity_code2 = 'H' then
           l_attribute := l_attribute || '/' || 'Blanket Number';
         ELSIF l_hold_entity_code2 = 'L' then
           l_attribute := l_attribute || '/' || 'Bl Line Number';
--ER#7479609 start
           ELSIF l_hold_entity_code2 = 'LT' THEN
               l_attribute := l_attribute || '/' || 'Line Type';
           ELSIF l_hold_entity_code2 = 'SM' THEN
               l_attribute := l_attribute || '/' || 'Shipping Method Code';
           ELSIF l_hold_entity_code2 = 'D' then
             l_attribute := l_attribute || '/' || 'Deliver to Site';
           ELSIF l_hold_entity_code2 = 'ST' then
             l_attribute := l_attribute || '/' || 'Source Type Code';
           ELSIF l_hold_entity_code2 = 'PL' THEN
             l_attribute := l_attribute || '/' || 'Price List';
           ELSIF l_hold_entity_code2 = 'PR' THEN
             l_attribute := l_attribute || '/' || 'Project Number';
           ELSIF l_hold_entity_code2 = 'PT' THEN
               l_attribute := l_attribute || '/' || 'Payment Term';
           ELSIF l_hold_entity_code2 = 'OI' THEN
               l_attribute := l_attribute || '/' || 'Option Item';
           ELSIF l_hold_entity_code2 = 'T' then
             l_attribute := l_attribute || '/' || 'Task Number';
           ELSIF l_hold_entity_code2 = 'OT' then
             l_attribute := l_attribute || '/' || 'Order Type';
           ELSIF l_hold_entity_code2 = 'P' THEN
             G_PAYMENT_HOLD_APPLIED := 'Y';
             l_attribute := l_attribute || '/' || 'Payment Type';
           ELSIF l_hold_entity_code2 = 'TC' THEN
             l_attribute := l_attribute || '/' || 'Currency';
           ELSIF l_hold_entity_code2 = 'SC' then
             l_attribute := l_attribute || '/' || 'Sales Channel Code';
           ELSIF l_hold_entity_code2 = 'CB' THEN
             l_attribute := l_attribute || '/' || 'Created By';
--ER#7479609 end
         END IF;
       end if;

       IF p_entity_code = OE_Globals.G_ENTITY_HEADER THEN
		fnd_message.set_name('ONT','OE_HLD_APPLIED');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute);
		OE_MSG_PUB.ADD;
	  --ER#7479609 ELSIF p_entity_code = OE_Globals.G_ENTITY_LINE THEN
	  ELSIF (p_entity_code = OE_Globals.G_ENTITY_LINE OR
   	          p_entity_code = OE_GLOBALS.G_ENTITY_LINE_PAYMENT) THEN  --ER#7479609
		fnd_message.set_name('ONT','OE_HLD_APPLIED_LINE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute);
	        -- Get the line number from the line record
		--SELECT line_number
		--  INTO l_line_number
		--  FROM OE_ORDER_LINES
		-- WHERE LINE_ID = p_entity_id;
		--FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_number);
		FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_rec.line_number); --8254521
		OE_MSG_PUB.ADD;
 	  END IF;
	END IF; -- if apply hold was successful
    END IF; -- l_create_order_hold_flag = 'Y'
   END LOOP;
   CLOSE curr_hold_source_entity2;
  end if;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING EVALUATE_HOLDS' , 1 ) ;
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      IF (prev_hold%isopen) THEN
      	CLOSE prev_hold;
      END IF;
      IF (curr_hold_source%isopen) THEN
      	CLOSE curr_hold_source;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (prev_hold%isopen) THEN
      	CLOSE prev_hold;
      END IF;
      IF (curr_hold_source%isopen) THEN
      	CLOSE curr_hold_source;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   WHEN OTHERS THEN
      IF (prev_hold%isopen) THEN
      	CLOSE prev_hold;
      END IF;
      IF (curr_hold_source%isopen) THEN
      	CLOSE curr_hold_source;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'evaluate_holds'
            );
      END IF;

END evaluate_holds;



/********************************/
/* EVALUATE_HOLDS_POST_WRITE    */
/********************************/
PROCEDURE eval_post_write_header
             ( p_entity_code       IN  VARCHAR2
             , p_entity_id         IN  NUMBER
             , p_hold_entity_code  IN  VARCHAR2
             --ER#7479609 , p_hold_entity_id    IN  NUMBER
             , p_hold_entity_id    IN  oe_hold_sources_all.hold_entity_id%TYPE --ER#7479609
             , x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
             , x_msg_count         OUT NOCOPY /* file.sql.39 change */ NUMBER
             , x_msg_data          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
             )
IS
     l_header_id         NUMBER    DEFAULT NULL;
     l_line_id           NUMBER    DEFAULT NULL;
     l_hold_source_id         NUMBER    DEFAULT NULL;
     l_order_hold_id          NUMBER    DEFAULT NULL;
     l_line_number       NUMBER  DEFAULT NULL;
     l_return_status          VARCHAR2(30);
     l_msg_count         NUMBER;
     l_msg_data               VARCHAR2(2000);
     l_attribute         VARCHAR2(30);
     l_hold_source_rec OE_HOLDS_PVT.Hold_Source_Rec_Type;
  l_hold_entity_code       VARCHAR2(1);
  --ER#7479609 l_hold_entity_id         NUMBER;
  l_hold_entity_id         oe_hold_sources_all.hold_entity_id%TYPE;  --ER#7479609
  --ER#7479609 l_hold_entity_code2      VARCHAR2(1);
  l_hold_entity_code2      oe_hold_sources_all.hold_entity_code%TYPE;  --ER#7479609
  --ER#7479609 l_hold_entity_id2        NUMBER;
  l_hold_entity_id2        oe_hold_sources_all.hold_entity_id2%TYPE;  --ER#7479609
  l_hold_id           NUMBER;

  --ER#7479609 m_hold_entity_code       VARCHAR2(1);
  m_hold_entity_code       oe_hold_sources_all.hold_entity_code%TYPE;  --ER#7479609
  --ER#7479609 m_hold_entity_id         NUMBER;
  m_hold_entity_id         oe_hold_sources_all.hold_entity_id%TYPE;  --ER#7479609
  --ER#7479609 m_hold_entity_code2      VARCHAR2(1);
  m_hold_entity_code2      oe_hold_sources_all.hold_entity_code2%TYPE;  --ER#7479609
    --ER#7479609 m_hold_entity_id2        NUMBER;
  m_hold_entity_id2        oe_hold_sources_all.hold_entity_id2%TYPE;  --ER#7479609
  m_counter                NUMBER;


  l_create_order_hold_flag VARCHAR2(1) := 'Y';
  --
CURSOR curr_hold_source(p_hold_entity_code VARCHAR2,
                        p_hold_entity_id   oe_hold_sources_all.hold_entity_id%TYPE) IS  --ER#7479609
                        --ER#7479609 p_hold_entity_id   NUMBER) IS
     SELECT HS.hold_source_id, hs.hold_id,
            hs.hold_entity_code, hs.hold_entity_id,
            hs.hold_entity_code2,hs.hold_entity_id2
       FROM OE_HOLD_SOURCES HS, OE_HOLD_definitions HLD
       WHERE HLD.HOLD_ID = HS.HOLD_ID
         AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                     ROUND( SYSDATE )
         AND HS.RELEASED_FLAG = 'N'
         AND SYSDATE
               BETWEEN NVL( HLD.START_DATE_ACTIVE, SYSDATE )
                   AND NVL( HLD.END_DATE_ACTIVE, SYSDATE )
         AND HS.HOLD_ENTITY_CODE = p_hold_entity_code
         AND HS.HOLD_ENTITY_ID = p_hold_entity_id;
         --6766981 AND rownum=1;  --5999405


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING EVAL_POST_WRITE_HEADER' , 1 ) ;
    END IF;


                               IF l_debug_level  > 0 THEN
                                   oe_debug_pub.add(  'ENTITY: '|| P_ENTITY_CODE ||'/' || P_ENTITY_ID ) ;
                               END IF;

    l_header_id := p_entity_id;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HEADER ID: '|| L_HEADER_ID ) ;
    END IF;

    m_hold_entity_code := p_hold_entity_code;
    m_hold_entity_id   := p_hold_entity_id;

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'M_HOLD_ENTITY_CODE/M_HOLD_ENTITY_ID:' || M_HOLD_ENTITY_CODE || '/' || M_HOLD_ENTITY_ID , 1 ) ;
                     END IF;
   IF m_hold_entity_id IS NOT NULL THEN
   OPEN curr_hold_source(m_hold_entity_code, m_hold_entity_id);
   LOOP
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETRIEVING NEW HOLD SOURCE RECORD' , 1 ) ;
       END IF;
       FETCH curr_hold_source INTO l_hold_source_id, l_hold_id,
                                       l_hold_entity_code,l_hold_entity_id,
                                       l_hold_entity_code2,l_hold_entity_id2;

       IF (curr_hold_source%notfound) THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'HOLD SOURCE RECORD NOT FOUND , EXITING' , 1 ) ;
          END IF;
          EXIT;
       END IF;

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'L_HOLD_ENTITY_CODE/L_HOLD_ENTITY_ID/' || 'L_HOLD_ENTITY_CODE2/L_HOLD_ENTITY_ID2/L_HOLD_SOURCE_ID:');
                            oe_debug_pub.add(  ' ' || L_HOLD_ENTITY_CODE || '/' || L_HOLD_ENTITY_ID || '/' || L_HOLD_ENTITY_CODE2 || '/' || L_HOLD_ENTITY_ID2 || '/' || L_HOLD_SOURCE_ID , 1 ) ;
                        END IF;

       l_hold_source_rec.HOLD_ENTITY_CODE  := l_hold_entity_code;
       l_hold_source_rec.HOLD_ENTITY_ID    := l_hold_entity_id;
       l_hold_source_rec.HOLD_ENTITY_CODE2 := l_hold_entity_code2;
       l_hold_source_rec.HOLD_ENTITY_ID2   := l_hold_entity_id2;
       l_hold_source_rec.HOLD_ID           := l_hold_id;
       l_hold_source_rec.hold_source_id    := l_hold_source_id;
       l_hold_source_rec.header_id         := l_header_id;
       l_hold_source_rec.line_id           := l_line_id;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING OE_HOLDS_PVT.CREATE_ORDER_HOLDS' ) ;
       END IF;
       oe_holds_pvt.Create_Order_Holds (
            p_hold_source_rec     =>  l_hold_source_rec
            ,x_return_status       =>  x_return_status
           ,x_msg_count           =>  x_msg_count
           ,x_msg_data            =>  x_msg_data
                  );


       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'X_RETURN_STATUS:' || X_RETURN_STATUS , 1 ) ;
       END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ERROR AFTER OE_HOLDS_PVT.CREATE_ORDER_HOLDS' ) ;
          END IF;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       ELSE
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HOLD APPLIED' ) ;
         END IF;

           l_attribute := 'Customer';


          fnd_message.set_name('ONT','OE_HLD_APPLIED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute);
          OE_MSG_PUB.ADD;
       END IF; -- if create_order_hold was successful
   END LOOP;
   CLOSE curr_hold_source;
   END IF; /* IF m_hold_entity_id IS NOT NULL THEN */

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING EVAL_POST_WRITE_HEADER' , 1 ) ;
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      IF (curr_hold_source%isopen) THEN
          CLOSE curr_hold_source;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (curr_hold_source%isopen) THEN
          CLOSE curr_hold_source;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   WHEN OTHERS THEN
      IF (curr_hold_source%isopen) THEN
          CLOSE curr_hold_source;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'eval_post_write_header'
            );
      END IF;

END eval_post_write_header;



/********************************/
/* EVALUATE_HOLDS_POST_WRITE    */
/********************************/

PROCEDURE evaluate_holds_post_write
             (  p_entity_code     IN   VARCHAR2
             ,  p_entity_id       IN   NUMBER
             ,  x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
             ,  x_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER
             ,  x_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2
             )
IS
     l_header_id         NUMBER    DEFAULT NULL;
     l_line_id           NUMBER    DEFAULT NULL;
     l_hold_source_id         NUMBER    DEFAULT NULL;
     l_order_hold_id          NUMBER    DEFAULT NULL;
     l_line_number       NUMBER  DEFAULT NULL;
     l_return_status          VARCHAR2(30);
     l_msg_count         NUMBER;
     l_msg_data               VARCHAR2(2000);
     temp           NUMBER DEFAULT NULL;
     l_attribute         VARCHAR2(50);
  --
     l_hold_source_rec OE_HOLDS_PVT.Hold_Source_Rec_Type;
  --ER#7479609 l_hold_entity_code       VARCHAR2(1);
  l_hold_entity_code       oe_hold_sources_all.hold_entity_code%TYPE;  --ER#7479609
  --ER#7479609 l_hold_entity_id         NUMBER;
  l_hold_entity_id         oe_hold_sources_all.hold_entity_id%TYPE;  --ER#7479609
  --ER#7479609
  l_hold_entity_code2      oe_hold_sources_all.hold_entity_code2%TYPE;  --ER#7479609

  --ER#7479609 l_hold_entity_id2        NUMBER;
  l_hold_entity_id2        oe_hold_sources_all.hold_entity_id2%TYPE;  --ER#7479609
  l_hold_id           NUMBER;
     l_inventory_item_id              NUMBER;
     l_sold_to_org_id                 NUMBER;
     l_invoice_to_org_id              NUMBER;
     l_ship_to_org_id                 NUMBER;
     l_ship_from_org_id               NUMBER;

  --ER#7479609 m_hold_entity_code       VARCHAR2(1);
  m_hold_entity_code	oe_hold_sources_all.hold_entity_code%TYPE;  --ER#7479609
  --ER#7479609 m_hold_entity_id         NUMBER;
  m_hold_entity_id         oe_hold_sources_all.hold_entity_id%TYPE;  --ER#7479609
  --ER#7479609 m_hold_entity_code2      VARCHAR2(1);
  m_hold_entity_code2	oe_hold_sources_all.hold_entity_code%TYPE;  --ER#7479609
  --ER#7479609 m_hold_entity_id2        NUMBER;
  m_hold_entity_id2        oe_hold_sources_all.hold_entity_id2%TYPE;  --ER#7479609
  m_counter                NUMBER;
  l_blanket_number         NUMBER;
  l_blanket_line_number    NUMBER;



  l_create_order_hold_flag VARCHAR2(1) := 'Y';
  --
  /*8602364 start
CURSOR curr_hold_source(p_hold_entity_code VARCHAR2,
                        p_hold_entity_id oe_hold_sources_all.hold_entity_id%TYPE) IS  --ER#7479609
                        --ER#7479609 p_hold_entity_id   NUMBER) IS
     SELECT HS.hold_source_id, hs.hold_id,
            hs.hold_entity_code, hs.hold_entity_id,
            hs.hold_entity_code2,hs.hold_entity_id2
       FROM OE_HOLD_SOURCES HS, OE_HOLD_definitions HLD
       WHERE HLD.HOLD_ID = HS.HOLD_ID
         AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                     ROUND( SYSDATE )
         AND HS.RELEASED_FLAG = 'N'
         AND SYSDATE
               BETWEEN NVL( HLD.START_DATE_ACTIVE, SYSDATE )
                   AND NVL( HLD.END_DATE_ACTIVE, SYSDATE )
--ER#7479609 start
         AND DECODE(p_hold_entity_code,'OI',HS.HOLD_ENTITY_CODE2,HS.HOLD_ENTITY_CODE) = p_hold_entity_code
         AND DECODE(p_hold_entity_code,'OI',HS.HOLD_ENTITY_ID2,HS.HOLD_ENTITY_ID) = p_hold_entity_id;
--ER#7479609 end
8602364 end*/
         /*ER#7479609 start
         AND HS.HOLD_ENTITY_CODE = p_hold_entity_code
         AND HS.HOLD_ENTITY_ID = p_hold_entity_id;
         ER#7479609 end*/

--8602364 start
CURSOR curr_hold_source(p_hold_entity_code VARCHAR2,
                        p_hold_entity_id oe_hold_sources_all.hold_entity_id%TYPE) IS
     SELECT HS.hold_source_id, hs.hold_id,
            hs.hold_entity_code, hs.hold_entity_id,
            hs.hold_entity_code2,hs.hold_entity_id2
       FROM OE_HOLD_SOURCES HS, OE_HOLD_definitions HLD
       WHERE HLD.HOLD_ID = HS.HOLD_ID
         AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                     ROUND( SYSDATE )
         AND HS.RELEASED_FLAG = 'N'
         AND SYSDATE
               BETWEEN NVL( HLD.START_DATE_ACTIVE, SYSDATE )
                   AND NVL( HLD.END_DATE_ACTIVE, SYSDATE )
         AND HS.HOLD_ENTITY_CODE = p_hold_entity_code
         AND HS.HOLD_ENTITY_ID = p_hold_entity_id;


CURSOR curr_hold_source_2(p_hold_entity_code VARCHAR2,
                        p_hold_entity_id oe_hold_sources_all.hold_entity_id%TYPE) IS
     SELECT HS.hold_source_id, hs.hold_id,
            hs.hold_entity_code, hs.hold_entity_id,
            hs.hold_entity_code2,hs.hold_entity_id2
       FROM OE_HOLD_SOURCES HS, OE_HOLD_definitions HLD
       WHERE HLD.HOLD_ID = HS.HOLD_ID
         AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                     ROUND( SYSDATE )
         AND HS.RELEASED_FLAG = 'N'
         AND SYSDATE
               BETWEEN NVL( HLD.START_DATE_ACTIVE, SYSDATE )
                   AND NVL( HLD.END_DATE_ACTIVE, SYSDATE )
         AND HS.HOLD_ENTITY_CODE2 = p_hold_entity_code
         AND HS.HOLD_ENTITY_ID2 = p_hold_entity_id;

--8602364 end


/****************************************************************************
 Valid Entity Combination
 ^^^^^^^^^^^^^^^^^^^^^^^^
 > Item - Customer
 > Item - Customer Ship to Site
 > Item - Customer Bill to Site
 > Item - Warehouse
 > Warehouse - Customer
 > Warehouse - Customer Ship to Site
 > Warehouse - Customer Bill to Site
 > Order - Site (Bill To) (Used by Line level Credit Checking only)

 > Item - Blanket Number
 > Blanket Number
 > Blanket Number - Customer Ship to Site
 > Blanket Number - Customer Bill to Site
 > Blanket Number - Warehouse
 > Blanket Number - Blanket Line Number

***************************************************************************/
/*
CURSOR curr_hold_source_entity2(p_hold_entity_code2 VARCHAR2,
                                p_hold_entity_id2   NUMBER) IS
     SELECT HS.hold_source_id, hs.hold_id,
            hs.hold_entity_code, hs.hold_entity_id,
            hs.hold_entity_code2,hs.hold_entity_id2
       FROM OE_HOLD_SOURCES HS, OE_HOLD_definitions HLD
      WHERE HLD.HOLD_ID = HS.HOLD_ID
         AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                     ROUND( SYSDATE )
         AND HS.RELEASED_FLAG = 'N'
         AND SYSDATE
               BETWEEN NVL( HLD.START_DATE_ACTIVE, SYSDATE )
                   AND NVL( HLD.END_DATE_ACTIVE, SYSDATE )
         AND HS.HOLD_ENTITY_CODE2 = p_hold_entity_code2
         AND HS.HOLD_ENTITY_ID2 = p_hold_entity_id2
         AND HS.HOLD_ENTITY_CODE <> 'O';
*/
--ER#7479609 start
l_header_rec	OE_ORDER_HEADERS_ALL%rowtype;
l_line_rec	OE_ORDER_LINES_ALL%rowtype;
TYPE entity_rec IS RECORD (entity_code	oe_hold_sources_all.hold_entity_code%TYPE,
			   entity_id	oe_hold_sources_all.hold_entity_id%TYPE);

TYPE entity_tab IS TABLE OF entity_rec INDEX BY BINARY_INTEGER;

l_entity_tab 	entity_tab;

TYPE payment_type_tab IS TABLE OF OE_PAYMENTS.PAYMENT_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
l_payment_type_tab   payment_type_tab;
pay_idx		NUMBER :=0;

--ER#7479609 end
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
-- ER#3667551 START to hold System Parameter value
l_credithold_cust VARCHAR2(10) := NVL(OE_SYS_PARAMETERS.value('ONT_CREDITHOLD_TYPE'),'S') ;
l_new_tbl_entry CHAR:='';
l_bill_to_orgid NUMBER := 0;
l_ch_level varchar2(10) := '';
--ER# 3667551 END
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING EVALUATE_HOLDS_POST_WRITE' , 1 ) ;
    END IF;
                               IF l_debug_level  > 0 THEN
                                   oe_debug_pub.add(  'ENTITY: '|| P_ENTITY_CODE ||'/' || P_ENTITY_ID ) ;
                               END IF;


   IF p_entity_code = OE_Globals.G_ENTITY_HEADER THEN
   -- Indicates Header Level action
      l_header_id := p_entity_id;

   --ER#7479609 start
   BEGIN
      SELECT * INTO l_header_rec
      FROM oe_order_headers
      WHERE header_id=l_header_id;

    EXCEPTION
        WHEN OTHERS THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'NO HEADER EXISTS' ) ;
            END IF;
            RAISE NO_DATA_FOUND;
    END;
    --ER#7479609 end
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'HEADER ID: '|| L_HEADER_ID ) ;
      END IF;


   ELSIF p_entity_code = OE_Globals.G_ENTITY_LINE THEN
     l_line_id := p_entity_id;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE ID: '|| L_LINE_ID ) ;
     END IF;

   --ER#7479609 start
   BEGIN
      SELECT OH.* INTO l_header_rec
      FROM oe_order_headers OH,oe_order_lines OL
      WHERE OH.header_id=OL.header_id
      AND OL.line_id=l_line_id;

    EXCEPTION
        WHEN OTHERS THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'NO HEADER EXISTS' ) ;
            END IF;
            RAISE NO_DATA_FOUND;
    END;
    --ER#7479609 end

    BEGIN
    /*ER#7479609 start
      SELECT sold_to_org_id,
             invoice_to_org_id,
             ship_to_org_id,
             ship_from_org_id,
             inventory_item_id,
             line_number,
             blanket_number,
             blanket_line_number,
             header_id
        INTO l_sold_to_org_id,
             l_invoice_to_org_id,
             l_ship_to_org_id,
             l_ship_from_org_id,
             l_inventory_item_id,
             l_line_number,
             l_blanket_number,
             l_blanket_line_number,
             l_header_id
        FROM oe_order_lines
       WHERE line_id = l_line_id;
       ER#7479609 end*/
      --ER#7479609 start
      SELECT * INTO l_line_rec
      FROM oe_order_lines
      WHERE line_id = l_line_id;
      --ER#7479609 end

    EXCEPTION
        WHEN OTHERS THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'NO HEADER ID FOR THIS LINE' ) ;
            END IF;
            RAISE NO_DATA_FOUND;
    END;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'HEADER ID: '|| L_HEADER_ID ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE ID: '|| L_LINE_ID ) ;
     END IF;
   END IF;

-- FOR m_hold_entity_code IN ('B', 'S', 'W', 'I','H') LOOP
--ER#7479609 start
   IF p_entity_code = OE_Globals.G_ENTITY_HEADER THEN

   BEGIN
     l_payment_type_tab.delete;

     SELECT V.payment_type
     BULK COLLECT INTO l_payment_type_tab
     FROM
     (Select payment_type_code payment_type
     FROM OE_PAYMENTS
     WHERE header_id=l_header_rec.header_id
       AND line_id IS NULL
     UNION
     SELECT payment_type_code payment_type
     FROM OE_ORDER_HEADERS_ALL
     WHERE header_id=l_header_rec.header_id) V;
   EXCEPTION
   WHEN OTHERS THEN
      null;
   END;
    --FOR m_counter IN 1..4 LOOP --ER11824468
	FOR m_counter IN 1..6 LOOP --ER#11824468,-- ER#3667551
      IF m_counter = 1 THEN
         l_entity_tab(m_counter).entity_code := 'C';
         l_entity_tab(m_counter).entity_id   := l_header_rec.sold_to_org_id;
      ELSIF m_counter = 2 THEN
         l_entity_tab(m_counter).entity_code  := 'PL';
         l_entity_tab(m_counter).entity_id   := l_header_rec.price_list_id;
      ELSIF m_counter = 3 THEN
         l_entity_tab(m_counter).entity_code  := 'OT';
         l_entity_tab(m_counter).entity_id   := l_header_rec.order_type_id;
      ELSIF m_counter = 4 THEN
         l_entity_tab(m_counter).entity_code  := 'SC';
         l_entity_tab(m_counter).entity_id   := l_header_rec.sales_channel_code;
	  --ER# 11824468 start
	  ELSIF m_counter = 5 THEN
         l_entity_tab(m_counter).entity_code  := 'CN';
         l_entity_tab(m_counter).entity_id   := l_header_rec.sold_to_org_id;
	--ER# 11824468 end
	-- ER#3667551 start
	-- IMP: This has to be the last entry, as the table entry  might not be created
	--- based on the system parameter and this might lead to index miss if not kept as last entry
	-- If header Bill To ORg not equals Sold to org, (it is possible for Bill to Org
	-- Hold Source Enabled).. this is required due to 'BTH'
	 ELSIF m_counter = 6 THEN
	 l_bill_to_orgid:=OE_Bulk_Holds_PVT.CustAcctID_func(p_in_site_id => l_header_rec.invoice_to_org_id,
                                          p_out_IDfound=> l_new_tbl_entry);
	 If(l_credithold_cust='BTH' AND l_header_rec.sold_to_org_id <> l_bill_to_orgid) then
         l_entity_tab(m_counter).entity_code  := 'C';
         l_entity_tab(m_counter).entity_id:= l_bill_to_orgid;
	 ELSE
         l_new_tbl_entry:='N';
         END IF;
    -- ER#3667551 end
      END IF;
    END LOOP;
       -- m_counter := 4; --ER11824468
	  m_counter := l_entity_tab.count; --ER11824468, -- ER#3667551
    FOR pay_idx in 1 .. l_payment_type_tab.count LOOP
         m_counter := m_counter + 1;
         l_entity_tab(m_counter).entity_code  := 'P';
         l_entity_tab(m_counter).entity_id   := l_payment_type_tab(pay_idx);
    END LOOP;

   ELSIF p_entity_code = OE_Globals.G_ENTITY_LINE THEN
--ER#7479609 end

   BEGIN
     l_payment_type_tab.delete;

     Select payment_type_code payment_type
     BULK COLLECT INTO l_payment_type_tab
     FROM OE_PAYMENTS
     WHERE header_id=l_header_rec.header_id
       AND line_id IS NOT NULL;
   EXCEPTION
   WHEN OTHERS THEN
      null;
   END;


    -- FOR m_counter IN 1..13 LOOP --ER# 11824468
   FOR m_counter IN 1..19 LOOP --ER# 11824468  --ER# 13331078 --ER#12571983
      IF m_counter = 1 THEN
         l_entity_tab(m_counter).entity_code  := 'B';
         l_entity_tab(m_counter).entity_id   := l_line_rec.invoice_to_org_id;
      ELSIF m_counter = 2 THEN
         l_entity_tab(m_counter).entity_code  := 'S';
         l_entity_tab(m_counter).entity_id   := l_line_rec.ship_to_org_id;
      ELSIF m_counter = 3 THEN
         l_entity_tab(m_counter).entity_code  := 'W';
         l_entity_tab(m_counter).entity_id   := l_line_rec.ship_from_org_id;
      ELSIF m_counter = 4 THEN
         l_entity_tab(m_counter).entity_code  := 'I';
         l_entity_tab(m_counter).entity_id   := l_line_rec.inventory_item_id;
      ELSIF m_counter = 5 THEN
         l_entity_tab(m_counter).entity_code  := 'H';
         l_entity_tab(m_counter).entity_id   := l_line_rec.blanket_number;
--ER#7479609 start
      ELSIF m_counter = 6 THEN
         l_entity_tab(m_counter).entity_code  := 'C';
         l_entity_tab(m_counter).entity_id   := l_header_rec.sold_to_org_id;
      ELSIF m_counter = 7 THEN
         l_entity_tab(m_counter).entity_code  := 'TM';
         l_entity_tab(m_counter).entity_id   := l_line_rec.inventory_item_id;
      ELSIF m_counter = 8 THEN
         l_entity_tab(m_counter).entity_code  := 'PR';
         l_entity_tab(m_counter).entity_id   := l_line_rec.project_id;
      ELSIF m_counter = 9 THEN
         l_entity_tab(m_counter).entity_code  := 'OT';
         l_entity_tab(m_counter).entity_id   := l_header_rec.order_type_id;
      ELSIF m_counter = 10 THEN
         l_entity_tab(m_counter).entity_code  := 'CD';
         l_entity_tab(m_counter).entity_id   := to_char(l_line_rec.creation_date,'DD-MON-RRRR');
      ELSIF m_counter = 11 THEN
         l_entity_tab(m_counter).entity_code  := 'SM';
         l_entity_tab(m_counter).entity_id   := l_line_rec.shipping_method_code;
      ELSIF m_counter = 12 THEN
         l_entity_tab(m_counter).entity_code  := 'OI';
         l_entity_tab(m_counter).entity_id   := l_line_rec.inventory_item_id;
--8254521 start
      ELSIF m_counter = 13 THEN
         l_entity_tab(m_counter).entity_code  := 'D';
         l_entity_tab(m_counter).entity_id   := l_line_rec.deliver_to_org_id;
--8254521 end

   --ER# 11824468 	start
      ELSIF m_counter = 14 THEN
         l_entity_tab(m_counter).entity_code  := 'CN';
         l_entity_tab(m_counter).entity_id   := l_header_rec.sold_to_org_id;
	--ER# 11824468 	end

	--ER# 13331078 start
	  ELSIF m_counter = 15 THEN
			 l_entity_tab(m_counter).entity_code  := 'IC';
		select mic.category_id
			into l_entity_tab(m_counter).entity_id
		from mtl_item_categories mic,
		     mtl_default_category_sets  mdc
		 where mic.inventory_item_id = l_line_rec.inventory_item_id
		   AND mic.organization_id = l_line_rec.ship_from_org_id
		   AND mdc.functional_area_id=7
		   AND mdc.category_set_id = mic.category_set_id;
	--ER# 13331078 end

	--ER#12571983 start
	  ELSIF m_counter = 16 THEN
         l_entity_tab(m_counter).entity_code  := 'EC';
         l_entity_tab(m_counter).entity_id   := l_line_rec.end_customer_id;
	  ELSIF m_counter = 17 THEN
         l_entity_tab(m_counter).entity_code  := 'EN';
         l_entity_tab(m_counter).entity_id   := l_line_rec.end_customer_id;
	  ELSIF m_counter = 18 THEN
         l_entity_tab(m_counter).entity_code  := 'EL';
         l_entity_tab(m_counter).entity_id   := l_line_rec.end_customer_site_use_id;
	--ER#12571983 end

	-- ER#3667551 start
	-- IMP: This has to be the last entry, as the table entry  might not be created
	--- based on the system parameter and this might lead to index miss if not kept as last entry
	-- If line Bill To ORg not equals Sold to org, (it is possible for Bill to Org
	-- Hold Source Enabled).. this is required due to 'BTL'
	 ELSIF m_counter = 19 THEN
	 l_bill_to_orgid:=OE_Bulk_Holds_PVT.CustAcctID_func(p_in_site_id => l_line_rec.invoice_to_org_id,
                                          p_out_IDfound=> l_new_tbl_entry);
	 If(l_credithold_cust='BTL' AND l_header_rec.sold_to_org_id <> l_bill_to_orgid) then
         l_entity_tab(m_counter).entity_code  := 'C';
         l_entity_tab(m_counter).entity_id:= l_bill_to_orgid;
	 ELSE
         l_new_tbl_entry:='N';
         END IF;
    -- ER#3667551 end

      END IF;
     END LOOP;

    -- m_counter := 13; --ER# 11824468
      m_counter := l_entity_tab.count; --ER# 11824468 --ER# 13331078,-- ER#3667551
    FOR pay_idx in 1 .. l_payment_type_tab.count LOOP
         m_counter := m_counter + 1;
         l_entity_tab(m_counter).entity_code  := 'P';
         l_entity_tab(m_counter).entity_id   := l_payment_type_tab(pay_idx);
    END LOOP;
--ER#7479609 end
    END IF;  --ER#7479609

  FOR i  IN l_entity_tab.first .. l_entity_tab.last LOOP  --ER#7479609
    IF l_debug_level  > 0 THEN
     -- oe_debug_pub.add(  'M_HOLD_ENTITY_CODE/M_HOLD_ENTITY_ID:' || M_HOLD_ENTITY_CODE || '/' || M_HOLD_ENTITY_ID , 1 ) ;
     oe_debug_pub.add(  'HOLD_ENTITY_CODE/HOLD_ENTITY_ID:' || l_entity_tab(i).entity_code || '/' || l_entity_tab(i).entity_id , 1 ) ;
    END IF;

   --ER#7479609 IF m_hold_entity_id IS NOT NULL THEN
   IF l_entity_tab(i).entity_id IS NOT NULL THEN  --ER#7479609
   --ER#7479609 OPEN curr_hold_source(m_hold_entity_code, m_hold_entity_id);
   --8602364  start
   IF l_entity_tab(i).entity_code = 'OI' THEN
   	OPEN curr_hold_source_2(l_entity_tab(i).entity_code, l_entity_tab(i).entity_id);
   ELSE
   --8602364 end
   	OPEN curr_hold_source(l_entity_tab(i).entity_code, l_entity_tab(i).entity_id);		--ER#7479609
   END IF;  --8602364
   LOOP
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETRIEVING NEW HOLD SOURCE RECORD' , 1 ) ;
     END IF;

     --8602364  start
     IF l_entity_tab(i).entity_code = 'OI' THEN
        FETCH curr_hold_source_2 INTO l_hold_source_id, l_hold_id,
                                      l_hold_entity_code,l_hold_entity_id,
                                      l_hold_entity_code2,l_hold_entity_id2;
        IF (curr_hold_source_2%notfound) THEN
          IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'HOLD SOURCE RECORD NOT FOUND , EXITING' , 1 ) ;
          END IF;

          EXIT;
        END IF;
     ELSE
     --8602364 end
        FETCH curr_hold_source INTO l_hold_source_id, l_hold_id,
                                    l_hold_entity_code,l_hold_entity_id,
                                    l_hold_entity_code2,l_hold_entity_id2;
        IF (curr_hold_source%notfound) THEN
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HOLD SOURCE RECORD NOT FOUND , EXITING' , 1 ) ;
           END IF;

           EXIT;
        END IF;
     END IF;  --8602364

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_HOLD_ENTITY_CODE/L_HOLD_ENTITY_ID/' || 'L_HOLD_ENTITY_CODE2/L_HOLD_ENTITY_ID2/L_HOLD_SOURCE_ID:');
       oe_debug_pub.add(  ' ' || L_HOLD_ENTITY_CODE || '/' || L_HOLD_ENTITY_ID || '/' || L_HOLD_ENTITY_CODE2 || '/' || L_HOLD_ENTITY_ID2 || '/' || L_HOLD_SOURCE_ID , 1 ) ;
     END IF;

   -- If second entity is not null, check if order/line is eligible for hold

     l_create_order_hold_flag := 'Y';

	 -- ER#3667551 start
	 -- If System parameter "Apply Credit Hold Based On" is set to 'Bill To Customer Line'
	 -- and if this flow is for Credit Hold (hold id 1) with Entity Code 'C' (Account Level Credit Hold)
	 -- then Line Level hold has to be applied for the Bill To Customer
	 l_ch_level := '';
	 If(l_hold_entity_code2 is null and p_entity_code = OE_Globals.G_ENTITY_HEADER
	    and l_hold_entity_code = 'C' and l_hold_id=1 ) then
		oe_debug_pub.add(  'l_bill_to_orgid='||l_bill_to_orgid||'l_hold_entity_id'||l_hold_entity_id
	 ||'STO-'||l_header_rec.sold_to_org_id);
		If (l_credithold_cust='BTL') then
	    l_create_order_hold_flag := 'N';
		oe_debug_pub.add(  'Do not Create order hold , system parameter is set Bill To Line');
		-- Do Not Create Hold for the iteration where Bill To Customer not equals Sold to Customer
		-- but the hold entity id holds the Sold to Customer for a BTH case
		-- because hold should be created only for Bill To Customer not equals Sold To
	    elsIf (l_credithold_cust='BTH' and l_bill_to_orgid <>  l_header_rec.sold_to_org_id
	            and  l_hold_entity_id = l_header_rec.sold_to_org_id) then
		l_create_order_hold_flag := 'N';
		oe_debug_pub.add(  'Do not Create Sold To Customer order hold , system parameter is set Bill To Header');
		--
		-- If it is a Bill to Header Level Credit Hold update the level so that
		-- appropriate message can be displayed
        elsif (l_credithold_cust='BTH' and  l_hold_entity_id = l_bill_to_orgid) then
		l_ch_level := 'BTH';
		end if;
		-- If there is a Customer level hold active for the BTC of the order,
		-- then due to m_counter =6 in l_entity_tab the hold message will be displayed,
		--  even though the hold would not be applied. But to stop the message this is required
	  ElsIf(l_hold_entity_code2 is null and p_entity_code = OE_Globals.G_ENTITY_HEADER
	    and l_hold_entity_code = 'C' and l_hold_id<>1 and l_hold_entity_id <> l_header_rec.sold_to_org_id) then
	  l_create_order_hold_flag := 'N';
	  end if;
	  -- ER#3667551 end

     IF l_hold_entity_code2 is not null THEN
      l_create_order_hold_flag := 'N';
  --ER#7479609 start
     IF p_entity_code = OE_Globals.G_ENTITY_HEADER THEN

      IF l_hold_entity_code2 = 'OT' THEN
       IF l_header_rec.order_type_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      /*9927494 start
      ELSIF l_hold_entity_code2 = 'PT' THEN
       IF l_header_rec.payment_type_code = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      9927494 end*/
      ELSIF l_hold_entity_code2 = 'TC' THEN
       IF l_header_rec.transactional_curr_code  = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'SC' THEN
       IF l_header_rec.sales_channel_code = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'P' THEN
         FOR pay_idx in 1 .. l_payment_type_tab.count LOOP
           IF l_payment_type_tab(pay_idx) = l_hold_entity_id2 THEN
              l_create_order_hold_flag := 'Y';
              EXIT;
           END IF;
         END LOOP;
     END IF;

     ELSIF p_entity_code = OE_Globals.G_ENTITY_LINE THEN
--ER#7479609 end
      IF l_hold_entity_code2 = 'C' THEN
       IF l_line_rec.sold_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;

	   --ER# 11824468 start
	   ELSIF l_hold_entity_code2 = 'CN' THEN
       IF l_line_rec.sold_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
	   --ER# 11824468 end

	   --ER#12571983 start
	   ELSIF l_hold_entity_code2 = 'EL' THEN
       IF l_line_rec.end_customer_site_use_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
	   ELSIF l_hold_entity_code2 in('EC','EN') THEN
       IF l_line_rec.end_customer_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
	   ELSIF l_hold_entity_code in('EC','EN') and l_line_rec.end_customer_id = l_hold_entity_id THEN
	    IF l_hold_entity_code2 ='SC' AND l_header_rec.sales_channel_code = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
		ELSIF l_hold_entity_code2 = 'TC' AND  l_header_rec.transactional_curr_code  = l_hold_entity_id2 THEN
		 l_create_order_hold_flag := 'Y';
		ELSIF l_hold_entity_code2 = 'OT' AND l_header_rec.order_type_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
		ELSIF l_hold_entity_code2 = 'P' THEN
         FOR pay_idx in 1 .. l_payment_type_tab.count
		 LOOP
           IF l_payment_type_tab(pay_idx) = l_hold_entity_id2 THEN
              l_create_order_hold_flag := 'Y';
              EXIT;
           END IF;
         END LOOP;
        END IF;-- end if of entity code 2 check
	   --ER#12571983 end

      ELSIF l_hold_entity_code2 = 'B' THEN
       IF l_line_rec.invoice_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'S' THEN
       IF l_line_rec.ship_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'W' THEN
       IF l_line_rec.ship_from_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'O' THEN
       IF l_line_rec.header_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'H' THEN
        IF l_line_rec.blanket_number = l_hold_entity_id2 THEN
          l_create_order_hold_flag := 'Y';
        END IF;
      ELSIF l_hold_entity_code2 = 'L' THEN
        IF l_line_rec.blanket_line_number = l_hold_entity_id2 THEN
          l_create_order_hold_flag := 'Y';
        END IF;

      ELSIF l_hold_entity_code2 = 'LT' THEN
       IF l_line_rec.line_type_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'SM' THEN
       IF l_line_rec.shipping_method_code = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'D' THEN
       IF l_line_rec.deliver_to_org_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'ST' THEN
       IF l_line_rec.source_type_code = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'PL' THEN
       IF l_line_rec.price_list_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'PR' THEN
        IF l_line_rec.project_id = l_hold_entity_id2 THEN
          l_create_order_hold_flag := 'Y';
        END IF;
      ELSIF l_hold_entity_code2 = 'PT' THEN
        IF l_line_rec.payment_term_id = l_hold_entity_id2 THEN
          l_create_order_hold_flag := 'Y';
        END IF;

      ELSIF l_hold_entity_code2 = 'OI' THEN
       IF l_line_rec.inventory_item_id = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'T' THEN
       IF l_line_rec.task_id  = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      ELSIF l_hold_entity_code2 = 'CB' THEN
       IF l_line_rec.created_by = l_hold_entity_id2 THEN
         l_create_order_hold_flag := 'Y';
       END IF;
      END IF;
     END IF;	--ER#7479609

    END IF; -- l_hold_entity_code2 is not null

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_CREATE_ORDER_HOLD_FLAG:' || L_CREATE_ORDER_HOLD_FLAG , 1 ) ;
    END IF;

--ER#7479609 start
    IF p_entity_code = OE_Globals.G_ENTITY_LINE THEN
      -- IF l_hold_entity_code = 'C' and --ER# 11824468
	    IF l_hold_entity_code IN('C','CN') and --ER# 11824468
      		(l_hold_entity_code2 IS NULL OR
      		 l_hold_entity_code2 = 'OT' OR
      		 --9927494 l_hold_entity_code2 = 'PT' OR
      		 l_hold_entity_code2 = 'P' OR  --9927494
      		 l_hold_entity_code2 = 'TC' OR
      		 l_hold_entity_code2 = 'SC'
      		)  THEN
			-- ER#3667551, start
			-- For Entity Line, based on System parameter "Apply Credit Hold Based On" set to 'Bill To Customer Line'
			-- credit check failure hold(hold id 1) should be created at line level
			If (l_hold_id=1 and l_credithold_cust='BTL'and l_hold_entity_code = 'C' and l_bill_to_orgid = l_hold_entity_id) then
			l_create_order_hold_flag := 'Y';
			l_ch_level := 'BTL'; --set the level for proper message to be displayed
			else
			-- ER#3667551, end
			l_create_order_hold_flag := 'N';
		end if;-- ER#3667551, added end if;
      END IF;

      IF l_hold_entity_code = 'OT' and (l_hold_entity_code2 = 'TC' OR l_hold_entity_code2 IS NULL)
      THEN
        l_create_order_hold_flag := 'N';
      END IF;

    END IF;
--ER#7479609 end

    IF l_create_order_hold_flag = 'Y' THEN
       l_hold_source_rec.HOLD_ENTITY_CODE  := l_hold_entity_code;
       l_hold_source_rec.HOLD_ENTITY_ID    := l_hold_entity_id;
       l_hold_source_rec.HOLD_ENTITY_CODE2 := l_hold_entity_code2;
       l_hold_source_rec.HOLD_ENTITY_ID2   := l_hold_entity_id2;
       l_hold_source_rec.HOLD_ID           := l_hold_id;
       l_hold_source_rec.hold_source_id    := l_hold_source_id;
       l_hold_source_rec.header_id         := l_header_id;
       l_hold_source_rec.line_id           := l_line_id;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING OE_HOLDS_PVT.CREATE_ORDER_HOLDS' ) ;
       END IF;
       oe_holds_pvt.Create_Order_Holds (
            p_hold_source_rec     =>  l_hold_source_rec
            ,x_return_status       =>  x_return_status
           ,x_msg_count           =>  x_msg_count
           ,x_msg_data            =>  x_msg_data
                  );


       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'X_RETURN_STATUS:' || X_RETURN_STATUS , 1 ) ;
       END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ERROR AFTER OE_HOLDS_PVT.CREATE_ORDER_HOLDS' ) ;
          END IF;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       ELSE
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'HOLD APPLIED' ) ;
         END IF;

         IF l_hold_entity_code = 'C' THEN
           l_attribute := 'Customer';
	   -- ER#3667551, start
	   If( l_ch_level = 'BTL') then
	     l_attribute := 'Line Level Bill To Customer';
	   elsif( l_ch_level = 'BTH')then
	     l_attribute := 'Header Level Bill To Customer';
	   end if;
	   -- ER#3667551, end
	 --ER# 11824468 start
	 ELSIF l_hold_entity_code = 'CN' THEN
           l_attribute := 'Customer';
         --ER# 11824468 end
         ELSIF l_hold_entity_code = 'I' THEN
           l_attribute := 'Item';
		   --ER# 13331078 start
		 ELSIF l_hold_entity_code = 'IC' THEN
           l_attribute := 'Item Category';
		   --ER# 13331078 end
		   --ER#12571983 start
		 ELSIF l_hold_entity_code IN('EC', 'EN') THEN
           l_attribute := 'End Customer';
		   --ER#12571983 end
         ELSIF l_hold_entity_code = 'S' THEN
           l_attribute := 'Ship to Site';
         ELSIF l_hold_entity_code = 'B' THEN
           l_attribute := 'Bill to Site';
         ELSIF l_hold_entity_code = 'O' then
              l_attribute := 'Order';
         ELSIF l_hold_entity_code = 'W' then
              l_attribute := 'Warehouse';
         ELSIF l_hold_entity_code = 'H' then
                l_attribute := 'Blanket Number';
--ER#7479609 start
         ELSIF l_hold_entity_code = 'TM' THEN
           l_attribute := 'Top Model';
         ELSIF l_hold_entity_code = 'PR' then
              l_attribute := 'Project Number';
         ELSIF l_hold_entity_code = 'PL' then
              l_attribute := 'Price List';
         ELSIF l_hold_entity_code = 'OT' then
                l_attribute := 'Order Type';
         ELSIF l_hold_entity_code = 'CD' THEN
           l_attribute := 'Creation Date';
         ELSIF l_hold_entity_code = 'SC' then
              l_attribute := 'Sales Channel Code';
         ELSIF l_hold_entity_code = 'P' then
              l_attribute := 'Payment Type';
         ELSIF l_hold_entity_code = 'SM' then
                l_attribute := 'Shipping Method Code';
--8254521 start
         ELSIF l_hold_entity_code = 'D' THEN
           l_attribute := 'Deliver to Site';
--8254521 end
--ER#7479609 end
         END IF;
         IF l_hold_entity_code2 is not null then
           IF l_hold_entity_code2 = 'C' THEN
             l_attribute := l_attribute || '/' || 'Customer';
			--ER# 11824468 start
		  ELSIF l_hold_entity_code2 = 'CN' THEN
             l_attribute := l_attribute || '/' || 'Customer';
            --ER# 11824468 end
            --ER#12571983 start
		   ELSIF l_hold_entity_code2 IN('EC', 'EN') THEN
           l_attribute := l_attribute || '/' ||'End Customer';
	   ELSIF l_hold_entity_code2 ='EL' THEN
           l_attribute := l_attribute || '/' ||'End Customer Location';
		   --ER#12571983 end
           ELSIF l_hold_entity_code2 = 'S' THEN
               l_attribute := l_attribute || '/' || 'Ship to Site';
           ELSIF l_hold_entity_code2 = 'B' THEN
               l_attribute := l_attribute || '/' || 'Bill to Site';
           ELSIF l_hold_entity_code2 = 'W' then
             l_attribute := l_attribute || '/' || 'Warehouse';
           ELSIF l_hold_entity_code2 = 'O' then
             l_attribute := l_attribute || '/' || 'Order';
           ELSIF l_hold_entity_code2 = 'H' THEN
             l_attribute := l_attribute || '/' || 'Blanket Number';
           ELSIF l_hold_entity_code2 = 'L' THEN
             l_attribute := l_attribute || '/' || 'Blanket Line Number';
--ER#7479609 start
           ELSIF l_hold_entity_code2 = 'LT' THEN
               l_attribute := l_attribute || '/' || 'Line Type';
           ELSIF l_hold_entity_code2 = 'SM' THEN
               l_attribute := l_attribute || '/' || 'Shipping Method Code';
           ELSIF l_hold_entity_code2 = 'D' then
             l_attribute := l_attribute || '/' || 'Deliver to Site';
           ELSIF l_hold_entity_code2 = 'ST' then
             l_attribute := l_attribute || '/' || 'Source Type Code';
           ELSIF l_hold_entity_code2 = 'PL' THEN
             l_attribute := l_attribute || '/' || 'Price List';
           ELSIF l_hold_entity_code2 = 'PR' THEN
             l_attribute := l_attribute || '/' || 'Project Number';
           ELSIF l_hold_entity_code2 = 'PT' THEN
               l_attribute := l_attribute || '/' || 'Payment Term';
           ELSIF l_hold_entity_code2 = 'OI' THEN
               l_attribute := l_attribute || '/' || 'Option Item';
           ELSIF l_hold_entity_code2 = 'T' then
             l_attribute := l_attribute || '/' || 'Task Number';
           ELSIF l_hold_entity_code2 = 'OT' then
             l_attribute := l_attribute || '/' || 'Order Type';
           ELSIF l_hold_entity_code2 = 'P' THEN
             l_attribute := l_attribute || '/' || 'Payment Type';
           ELSIF l_hold_entity_code2 = 'TC' THEN
             l_attribute := l_attribute || '/' || 'Currency';
           ELSIF l_hold_entity_code2 = 'SC' then
             l_attribute := l_attribute || '/' || 'Sales Channel Code';
           ELSIF l_hold_entity_code2 = 'CB' THEN
             l_attribute := l_attribute || '/' || 'Created By';
--ER#7479609 end
           END IF;
         end if;


         IF p_entity_code = OE_Globals.G_ENTITY_HEADER THEN
          fnd_message.set_name('ONT','OE_HLD_APPLIED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute);
          OE_MSG_PUB.ADD;
         ELSIF p_entity_code = OE_Globals.G_ENTITY_LINE THEN
          fnd_message.set_name('ONT','OE_HLD_APPLIED_LINE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute);
          --ER#7479609 FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_number);
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_rec.line_number);  --ER#7479609
          OE_MSG_PUB.ADD;
         END IF;

       END IF; -- if create_order_hold was successful
    END IF; -- l_create_order_hold_flag = 'Y'
   END LOOP;
   --8602364  start
   IF l_entity_tab(i).entity_code = 'OI' THEN
   	CLOSE curr_hold_source_2;
   ELSE
   --8602364 end
   	CLOSE curr_hold_source;
   END IF;  --8602364
  END IF; -- IF m_hold_entity_id IS NOT NULL THEN
 END LOOP;

  -- Check for Current second entity hold if the entity is ('C','B','S','W')
/*
 FOR m_counter IN 1..4 LOOP
   IF m_counter = 1 THEN
       m_hold_entity_code2 := 'C';
       m_hold_entity_id2   := l_sold_to_org_id;
   ELSIF m_counter = 2 THEN
       m_hold_entity_code2 := 'B';
       m_hold_entity_id2   := l_invoice_to_org_id;
   ELSIF m_counter = 3 THEN
       m_hold_entity_code2 := 'S';
       m_hold_entity_id2   := l_ship_to_org_id;
   ELSIF m_counter = 4 THEN
       m_hold_entity_code2 := 'W';
       m_hold_entity_id2   := l_ship_from_org_id;
   END IF;
   OE_Debug_PUB.Add('m_hold_entity_code2/m_hold_entity_id2:' ||
                     m_hold_entity_code2 || '/' || m_hold_entity_id2, 1);
   IF m_hold_entity_id2 IS NOT NULL THEN

   OPEN curr_hold_source_entity2(m_hold_entity_code2,m_hold_entity_id2);
   LOOP
       OE_Debug_PUB.Add('Retrieving new hold source record for Entity2', 1);
       FETCH curr_hold_source_entity2 INTO l_hold_source_id, l_hold_id,
                                       l_hold_entity_code,l_hold_entity_id,
                                       l_hold_entity_code2,l_hold_entity_id2;

       IF (curr_hold_source_entity2%notfound) THEN
         OE_Debug_PUB.Add('No Hold Source found, existing', 1);
          EXIT;
       END IF;

       OE_Debug_PUB.Add('l_hold_entity_code/l_hold_entity_id/' ||
             'l_hold_entity_code2/l_hold_entity_id2/l_hold_source_id:' ||
                        l_hold_entity_code || '/' ||
                        l_hold_entity_id   || '/' ||
                        l_hold_entity_code2 || '/' ||
                        l_hold_entity_id2   || '/' ||
                        l_hold_source_id, 1);

   -- If second entity is not null, The First entity can only be I or W
   -- Check if order/line is eligible for hold
     l_create_order_hold_flag := 'N';
     IF l_hold_entity_code = 'I' THEN
       IF l_inventory_item_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     ELSIF l_hold_entity_code = 'W' THEN
       IF l_ship_from_org_id = l_hold_entity_id THEN
         l_create_order_hold_flag := 'Y';
       END IF;
     END IF;
    OE_DEBUG_PUB.Add('l_create_order_hold_flag:' || l_create_order_hold_flag,1);

    IF l_create_order_hold_flag = 'Y' THEN
       l_hold_source_rec.HOLD_ENTITY_CODE  := l_hold_entity_code;
       l_hold_source_rec.HOLD_ENTITY_ID    := l_hold_entity_id;
       l_hold_source_rec.HOLD_ENTITY_CODE2 := l_hold_entity_code2;
       l_hold_source_rec.HOLD_ENTITY_ID2   := l_hold_entity_id2;
       l_hold_source_rec.HOLD_ID           := l_hold_id;
       l_hold_source_rec.hold_source_id    := l_hold_source_id;
       l_hold_source_rec.header_id         := l_header_id;
       l_hold_source_rec.line_id           := l_line_id;

       oe_debug_pub.add('Calling oe_holds_pvt.create_order_holds');
       oe_holds_pvt.Create_Order_Holds (
            p_hold_source_rec     =>  l_hold_source_rec
            ,x_return_status       =>  x_return_status
           ,x_msg_count           =>  x_msg_count
           ,x_msg_data            =>  x_msg_data
                  );

       OE_DEBUG_PUB.Add('x_return_status:' || x_return_status,1);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         OE_Debug_PUB.Add('Error After oe_holds_pvt.Create_Order_Holds');
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       ELSE
         OE_Debug_PUB.Add('Hold applied');

       IF l_hold_entity_code = 'C' THEN
         l_attribute := 'Customer';
       ELSIF l_hold_entity_code = 'I' THEN
         l_attribute := 'Item';
       ELSIF l_hold_entity_code = 'S' THEN
         l_attribute := 'Site Use';
       ELSIF l_hold_entity_code = 'B' THEN
         l_attribute := 'Bill to Site';
       ELSIF l_hold_entity_code = 'O' then
            l_attribute := 'Order';
       ELSIF l_hold_entity_code = 'W' then
            l_attribute := 'Warehouse';
       END IF;
       IF l_hold_entity_code2 is not null then
         IF l_hold_entity_code2 = 'C' THEN
           l_attribute := l_attribute || '/' || 'Customer';
         ELSIF l_hold_entity_code2 = 'S' THEN
           l_attribute := l_attribute || '/' || 'Ship to Site';
           ELSIF l_hold_entity_code2 = 'B' THEN
           l_attribute := l_attribute || '/' || 'Bill to Site';
         ELSIF l_hold_entity_code2 = 'W' then
           l_attribute := l_attribute || '/' || 'Warehouse';
         END IF;
       end if;

       IF p_entity_code = OE_Globals.G_ENTITY_HEADER THEN
          fnd_message.set_name('ONT','OE_HLD_APPLIED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute);
          OE_MSG_PUB.ADD;
       ELSIF p_entity_code = OE_Globals.G_ENTITY_LINE THEN
          fnd_message.set_name('ONT','OE_HLD_APPLIED_LINE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute);
             -- Get the line number from the line record
          --SELECT line_number
          --  INTO l_line_number
          --  FROM OE_ORDER_LINES
          -- WHERE LINE_ID = p_entity_id;
          --FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_number);
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_rec.line_number); --8254521
          OE_MSG_PUB.ADD;
       END IF;
     END IF; -- if apply hold was successful
    END IF; -- l_create_order_hold_flag = 'Y'
   END LOOP;
   CLOSE curr_hold_source_entity2;
   END IF;
  END LOOP;
*/
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING EVALUATE_HOLDS_POST_WRITE' , 1 ) ;
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      IF (curr_hold_source%isopen) THEN
          CLOSE curr_hold_source;
      END IF;
--8602364 start
      IF (curr_hold_source_2%isopen) THEN
          CLOSE curr_hold_source_2;
      END IF;
--8602364 end
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (curr_hold_source%isopen) THEN
          CLOSE curr_hold_source;
      END IF;
--8602364 start
      IF (curr_hold_source_2%isopen) THEN
          CLOSE curr_hold_source_2;
      END IF;
--8602364 end
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   WHEN OTHERS THEN
      IF (curr_hold_source%isopen) THEN
          CLOSE curr_hold_source;
      END IF;
--8602364 start
      IF (curr_hold_source_2%isopen) THEN
          CLOSE curr_hold_source_2;
      END IF;
--8602364 end
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'evaluate_holds_post_write'
            );
      END IF;

END evaluate_holds_post_write;
/*******************************/

FUNCTION Hold_exists
(   p_hold_entity_code		IN	VARCHAR2
--ER#7479609 ,   p_hold_entity_id		IN	NUMBER
,   p_hold_entity_id		IN	oe_hold_sources_all.hold_entity_id%TYPE --ER#7479609
,   p_hold_id		        IN	NUMBER DEFAULT 1
,   p_org_id                    IN      NUMBER DEFAULT NULL
) RETURN boolean IS

 l_hold_exists VARCHAR2(1) := 'N';

 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ENTERED OE_HOLDS_PUB.Hold_Exists',1 ) ;
        END IF;
   IF p_org_id IS NULL THEN

      SELECT 'Y'
        INTO l_hold_exists
        FROM OE_HOLD_SOURCES_ALL
       WHERE hold_entity_code = p_hold_entity_code
         AND HOLD_ENTITY_ID = p_hold_entity_id
         AND hold_id = p_hold_id
         AND nvl(RELEASED_FLAG, 'N') = 'N'
         AND ORG_ID is null;
   ELSE

      SELECT 'Y'
        INTO l_hold_exists
        FROM OE_HOLD_SOURCES_ALL
       WHERE hold_entity_code = p_hold_entity_code
         AND HOLD_ENTITY_ID = p_hold_entity_id
         AND hold_id = p_hold_id
         AND nvl(RELEASED_FLAG, 'N') = 'N'
         AND ORG_ID = p_org_id;

   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_HOLDS_PUB.Hold_Exists',1 ) ;
   END IF;

   IF l_hold_exists = 'Y' THEN
       return true;
   ELSE
       return false;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      return false;
   WHEN TOO_MANY_ROWS THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'TOO_MANY_ROWS exception in OE_HOLDS_PUB.Hold_Exists' ) ;
        END IF;
        return true;
   WHEN others THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'Exception in OE_HOLDS_PUB.Hold_Exists' ) ;
        END IF;
        return false;
END Hold_exists;

 /* This processes the holds (apply,release) on a customer account.
    Called from process_holds procedure in this package

    */
PROCEDURE Process_Holds_Customer
(   p_hold_entity_code		IN	VARCHAR2
--ER#7479609 ,   p_hold_entity_id		IN	NUMBER
,   p_hold_entity_id		IN	oe_hold_sources_all.hold_entity_id%TYPE --ER#7479609
,   p_hold_id		        IN	NUMBER DEFAULT 1
,   p_release_reason_code	IN      VARCHAR2 DEFAULT NULL
,   p_action             	IN      VARCHAR2
,   x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS

  l_hold_source_rec  OE_HOLDS_PVT.hold_source_rec_type;
  l_hold_release_rec OE_HOLDS_PVT.Hold_Release_Rec_Type;

  l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_org_id NUMBER := null;
  l_hold_source_id NUMBER := null;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  CURSOR c_hold_orgs IS
    SELECT DISTINCT org_id
      FROM HZ_CUST_ACCT_SITES_ALL acct
     WHERE acct.cust_account_id = p_hold_entity_id
       AND NOT EXISTS (SELECT 1
                         FROM OE_HOLD_SOURCES_ALL src
                        WHERE acct.cust_account_id = src.hold_entity_id
                          AND src.hold_entity_code = 'C'
                          AND acct.org_id = src.org_id
                          AND src.hold_id = p_hold_id
                          AND nvl(src.released_flag, 'N') = 'N')
    UNION

    SELECT DISTINCT org_id
      FROM OE_ORDER_HEADERS_ALL hdr
     WHERE sold_to_org_id = p_hold_entity_id
       AND NOT EXISTS (select 1
                         from oe_hold_sources_all
                        where hold_entity_id = p_hold_entity_id
                          and hold_entity_code = 'C'
                          and hold_id = p_hold_id
                          and nvl(RELEASED_FLAG, 'N')  = 'N')
       AND NOT EXISTS (select 1
                         from HZ_CUST_ACCT_SITES_ALL  hzcas
                        where hzcas.cust_account_id = p_hold_entity_id
                          and hzcas.cust_account_id = hdr.sold_to_org_id);


  CURSOR c_cust_holds IS
    SELECT org_id, hold_source_id
      FROM OE_HOLD_SOURCES_ALL
     WHERE hold_entity_id = p_hold_entity_id
       AND hold_entity_code = 'C'
       AND nvl(released_flag,'N') = 'N';

BEGIN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERED OE_HOLDS_PUB.Process_Holds_Customer' , 1 ) ;
         oe_debug_pub.add('EntityCode: ' || p_hold_entity_code||' EntityID:'|| p_hold_entity_id||' HoldId: ' || p_hold_id||' p_Action: ' || p_action, 1);
      END IF;
      l_hold_source_rec.hold_entity_code := p_hold_entity_code;
      l_hold_source_rec.hold_entity_id := p_hold_entity_id;
      l_hold_source_rec.hold_id := p_hold_id;

      IF p_action = 'APPLY' THEN

         OPEN c_hold_orgs;
         LOOP
             FETCH c_hold_orgs into l_org_id;
             EXIT WHEN c_hold_orgs%NOTFOUND OR l_return_status <> FND_API.G_RET_STS_SUCCESS;
             -- can l_org_id be null??? No.

             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Applying Hold in ORG_ID ' || l_org_id, 1);
             END IF;

             MO_GLOBAL.set_policy_context('S',l_org_id);

             oe_holds_pvt.apply_Holds(
                p_hold_source_rec     =>  l_hold_source_rec
               ,p_hold_existing_flg   =>  'Y'
               ,p_hold_future_flg     =>  'Y'
               ,x_return_status       =>  x_return_status
               ,x_msg_count           =>  x_msg_count
               ,x_msg_data            =>  x_msg_data );

             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('oe_holds_pvt.apply_Holds:x_return_status ' || x_return_status, 1);
             END IF;

             l_return_status := x_return_status;

         END LOOP;
         CLOSE c_hold_orgs;

      ELSIF p_action = 'RELEASE' THEN

            l_hold_release_rec.release_reason_code := p_release_reason_code;
            OPEN c_cust_holds;
            LOOP

               FETCH c_cust_holds into l_org_id,l_hold_source_id;
               EXIT WHEN c_cust_holds%NOTFOUND OR l_return_status <> FND_API.G_RET_STS_SUCCESS;

               IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('Releasing Hold in ORG_ID ' || l_org_id, 1);
               END IF;

               l_hold_source_rec.hold_source_id := l_hold_source_id;

               MO_GLOBAL.set_policy_context('S',l_org_id);

               oe_holds_pvt.Release_Holds(
                 p_hold_source_rec     =>  l_hold_source_rec
                ,p_hold_release_rec    =>  l_hold_release_rec
                ,x_return_status       =>  x_return_status
                ,x_msg_count           =>  x_msg_count
                ,x_msg_data            =>  x_msg_data);

               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('oe_holds_pvt.Release_Holds:x_return_status ' || x_return_status, 1);
               END IF;

               l_return_status := x_return_status;

            END LOOP;
       END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING OE_HOLDS_PUB.Process_Holds_Customer' , 1 ) ;
      END IF;

EXCEPTION
    	WHEN FND_API.G_EXC_ERROR THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'API EXECUTION ERROR IN OE_HOLDS_PUB.Process_Holds_Customer' , 1 ) ;
             END IF;
             IF x_msg_count is not null then
                OE_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                        p_data  => x_msg_data);
             end if;
             RAISE FND_API.G_EXC_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'API UNEXPECTED ERROR IN OE_HOLDS_PUB.Process_Holds_Customer' , 1 ) ;
             END IF;
             IF x_msg_count is not null then
                OE_MSG_PUB.Count_And_Get
                   (   p_count    =>   x_msg_count
                   ,   p_data     =>   x_msg_data
                 );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    	WHEN OTHERS THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ERROR in oe_holds_pub.Process_Holds_Customer' , 1 ) ;
             END IF;
             RAISE;

END Process_Holds_Customer;

/* This processes the holds (apply,release) on a site.
    Called from process_holds procedure in this package

    */
PROCEDURE Process_Holds_Site
(   p_hold_entity_code		IN	VARCHAR2
--ER#7479609 ,   p_hold_entity_id		IN	NUMBER
,   p_hold_entity_id		IN	oe_hold_sources_all.hold_entity_id%TYPE --ER#7479609
,   p_hold_id		        IN	NUMBER DEFAULT 1
,   p_release_reason_code	IN      VARCHAR2 DEFAULT NULL
,   p_action             	IN      VARCHAR2
,   x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS

  l_hold_source_rec  OE_HOLDS_PVT.hold_source_rec_type;
  l_hold_release_rec OE_HOLDS_PVT.Hold_Release_Rec_Type;
  l_hold_entity_code varchar2(1);
  l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_hold_exists VARCHAR2(1) := 'N';
  l_org_id NUMBER := null;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERED OE_HOLDS_PUB.Process_Holds_Site' , 1 ) ;
         oe_debug_pub.add('EntityCode: ' || p_hold_entity_code||'::EntityID: ' || p_hold_entity_id||'::HoldId: ' || p_hold_id||'::p_Action: ' || p_action, 1);
      END IF;

	-- Fetch the org_id of the site that is being sent to put on hold
        -- The reason, the caller may not have set the correct org

     BEGIN

        SELECT org_id into l_org_id
          FROM hz_cust_site_uses_all
         WHERE site_use_id = p_hold_entity_id;

         IF l_org_id is null then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ORG_ID for the site is null. Invalid site  ||p_hold_entity_id' , 1 ) ;
             END IF;
            raise no_data_found; -- Should not occur at all
         END IF;
     EXCEPTION
        WHEN no_data_found then
             --x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_SITE_USE_ID');
             OE_MSG_PUB.ADD;
             fnd_message.set_token('SITE_USE_ID', to_char(p_hold_entity_id));

             RAISE FND_API.G_EXC_ERROR;
     END;

     IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Process_Holds_Site:ORG_ID: ' || l_org_id, 1);
     END IF;

     MO_GLOBAL.set_policy_context('S',l_org_id);

   -- Validate hold entity (site) and get correct code for Ship To, Bill To
   l_hold_entity_code := Hold_Site_Code(p_hold_entity_id);

   l_hold_source_rec.hold_entity_code := l_hold_entity_code;
   l_hold_source_rec.hold_entity_id := p_hold_entity_id;
   l_hold_source_rec.hold_id := p_hold_id;
   l_hold_release_rec.release_reason_code := p_release_reason_code;

   IF p_action = 'APPLY' THEN

        /* APPLY the hold iff there is no hold already. But if there is a hold already existing,
           should we give a message  to the user? Right now, the API does nothing.

        */
	IF NOT Hold_exists(p_hold_entity_code,p_hold_entity_id,p_hold_id,l_org_id) THEN
          oe_holds_pvt.apply_Holds(
             p_hold_source_rec     =>  l_hold_source_rec
            ,p_hold_existing_flg   =>  'Y'   -- Hold all existing orders
            ,p_hold_future_flg     =>  'Y'   -- hold new orders also
            ,x_return_status       =>  x_return_status
            ,x_msg_count           =>  x_msg_count
            ,x_msg_data            =>  x_msg_data );

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('oe_holds_pvt.apply:x_return_status: ' || x_return_status, 1);
          END IF;

       -- Exceptions and return status are checked in process_holds
	END IF; -- hold not exists
    ELSIF p_action = 'RELEASE' THEN

	oe_holds_pvt.Release_Holds(
               p_hold_source_rec     =>  l_hold_source_rec
              ,p_hold_release_rec    =>  l_hold_release_rec
              ,x_return_status       =>  x_return_status
              ,x_msg_count           =>  x_msg_count
              ,x_msg_data            =>  x_msg_data);


          IF l_debug_level  > 0 THEN
           oe_debug_pub.add('oe_holds_pvt.Release_Holds:x_return_status: ' || x_return_status, 1);
          END IF;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING OE_HOLDS_PUB.Process_Holds_Site' , 1 ) ;
      END IF;
   END IF; -- APPLY OR RELEASE
EXCEPTION
    	WHEN FND_API.G_EXC_ERROR THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'API EXECUTION ERROR IN OE_HOLDS_PUB.PROCESS_HOLDS' , 1 ) ;
             END IF;

             IF x_msg_count is not null then
                OE_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                        p_data  => x_msg_data);
             end if;

             RAISE FND_API.G_EXC_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'API G_EXC_UNEXPECTED_ERROR IN OE_HOLDS_PUB.PROCESS_HOLDS' , 1 ) ;
             END IF;

             FND_MSG_PUB.Count_And_Get
                (   p_count    =>   x_msg_count
                ,   p_data     =>   x_msg_data
             );

             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    	WHEN OTHERS THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ERROR in oe_holds_pub.process_holds' , 1 ) ;
             END IF;
             RAISE;
END Process_Holds_Site;

/* This procedure is called by AR/TCA/IEX to put a Hold on the customer/site

   Note: This procedure as opposed to the previous API called by AR/TCA/IEX.
   Oe_Holds.Hold_API is a function and returns a number as return status. This new API Process_Holds
   doesn't pass back any arguments, return status etc. is this OK with the calling programs??
   This API throws exceptions

   Need to fix the appropriate error messages

   Validate the commit process

   continue to process remaining holds or throw API error if an occurs when processing the holds in a loop??

*/
PROCEDURE Process_Holds
(   p_api_version		IN	NUMBER
,   p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_hold_entity_code		IN	VARCHAR2
--ER#7479609 ,   p_hold_entity_id		IN	NUMBER
,   p_hold_entity_id		IN	oe_hold_sources_all.hold_entity_id%TYPE --ER#7479609
,   p_hold_id		        IN	NUMBER DEFAULT 1
,   p_release_reason_code	IN      VARCHAR2 DEFAULT NULL
,   p_action             	IN      VARCHAR2
,   x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS

l_orig_org NUMBER := null;

l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count NUMBER := null;
l_msg_data VARCHAR2(2000) := null;
l_valid_acct VARCHAR2(1) := 'N';

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

CURSOR c_valid_acct IS
  SELECT 'Y'
    FROM HZ_CUST_ACCOUNTS_ALL
   WHERE cust_account_id = p_hold_entity_id;

BEGIN

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERED OE_HOLDS_PUB.PROCESS_HOLDS' , 1 ) ;
      END IF;

      SAVEPOINT oe_process_holds;

       IF p_action IS NULL OR p_action NOT IN ('APPLY','RELEASE') THEN
	  FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ACTION'); -- message taken from oe_holds
	  fnd_message.set_token('ACTION',p_action);
	  OE_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_hold_entity_code IS NULL OR p_hold_entity_code NOT IN ('S','C') THEN
	  FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_HOLD_ENTITY_CODE'); -- message need to be seeded or use any existing one
	  OE_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- hold the original org id being used by programs when calling process_holds.
       -- set the org org context to this original org when leaving process_holds.
       -- sHOULD IT BE SET EVEN WHEN EXITING WITH AN EXCEPTION??

       l_orig_org := MO_GLOBAL.get_current_org_id;

       IF p_hold_entity_code = 'S' THEN

           Process_Holds_Site
                   (   p_hold_entity_code => p_hold_entity_code
                   ,   p_hold_entity_id	=> p_hold_entity_id
                   ,   p_hold_id => p_hold_id
                   ,   p_release_reason_code => p_release_reason_code
                   ,   p_action => p_action
                   ,   x_return_status  => l_return_status
                   ,   x_msg_count => l_msg_count
                   ,   x_msg_data => l_msg_data
                   );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

             IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ERROR AFTER PROCESS_HOLDS_SITE IN OE_HOLDS_PUB.PROCESS_HOLDS' ) ;
             END IF;

             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    	        RAISE FND_API.G_EXC_ERROR;
    	     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	     END IF;
    	  END IF;

       ELSIF p_hold_entity_code = 'C' THEN
           -- validate the account
          OPEN c_valid_acct;
          FETCH c_valid_acct into l_valid_acct;
          CLOSE c_valid_acct;

          IF l_valid_acct <> 'Y' THEN
	     FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_CUST_ACCOUNT'); -- get the correct message new or existing??
	     -- fnd_message.set_token('',p_action);
	     OE_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

           -- call process_holds_customer

           Process_Holds_Customer
                   (   p_hold_entity_code => p_hold_entity_code
                   ,   p_hold_entity_id	=> p_hold_entity_id
                   ,   p_hold_id => p_hold_id
                   ,   p_release_reason_code => p_release_reason_code
                   ,   p_action => p_action
                   ,   x_return_status  => l_return_status
                   ,   x_msg_count => l_msg_count
                   ,   x_msg_data => l_msg_data
                   );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

             IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ERROR AFTER PROCESS_HOLDS_SITE IN OE_HOLDS_PUB.PROCESS_HOLDS' ) ;
             END IF;

             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    	        RAISE FND_API.G_EXC_ERROR;
    	     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	     END IF;
    	  END IF;

       END IF;

       IF l_orig_org IS NULL THEN
          MO_GLOBAL.set_policy_context('M',null);
       ELSE
          MO_GLOBAL.set_policy_context('S',l_orig_org);
       END IF;

      x_return_status := l_return_status;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING OE_HOLDS_PUB.PROCESS_HOLDS' , 1 ) ;
      END IF;
EXCEPTION
    	WHEN FND_API.G_EXC_ERROR THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'API EXECUTION ERROR IN OE_HOLDS_PUB.PROCESS_HOLDS' , 1 ) ;
             END IF;
             x_return_status := l_return_status;
             x_msg_count     := l_msg_count;
             x_msg_data       := l_msg_data;
             IF l_msg_count is not null then
                OE_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                        p_data  => l_msg_data);
             end if;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'Error Message: '||l_msg_data , 1 ) ;
             END IF;
             ROLLBACK TO SAVEPOINT oe_process_holds;
             RAISE FND_API.G_EXC_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'API G_EXC_UNEXPECTED_ERROR IN OE_HOLDS_PUB.PROCESS_HOLDS' , 1 ) ;
             END IF;
             x_return_status := l_return_status;
             x_msg_count     := l_msg_count;
             x_msg_data       := l_msg_data;
             FND_MSG_PUB.Count_And_Get
                (   p_count    =>   l_msg_count
                ,   p_data     =>   l_msg_data
             );
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'Error Message: '||l_msg_data , 1 ) ;
             END IF;
             ROLLBACK TO SAVEPOINT oe_process_holds;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    	WHEN OTHERS THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ERROR in oe_holds_pub.process_holds' , 1 ) ;
             END IF;
             x_return_status := l_return_status;
             x_msg_count     := l_msg_count;
             x_msg_data       := l_msg_data;
             ROLLBACK TO SAVEPOINT oe_process_holds;
             RAISE;
END Process_Holds;

END OE_Holds_PUB;

/
