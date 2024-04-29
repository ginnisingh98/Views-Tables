--------------------------------------------------------
--  DDL for Package Body OE_HOLD_SOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HOLD_SOURCES_PVT" AS
/* $Header: OEXVHLSB.pls 120.2 2005/08/10 12:08:44 zbutt noship $ */

--  Global constant holding the package name

G_PKG_NAME			CONSTANT VARCHAR2(30) := 'OE_Hold_Sources_Pvt';


PROCEDURE Utilities
( p_user_id OUT NOCOPY NUMBER)

IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
p_user_id := NVL(FND_GLOBAL.USER_ID, -1);

END Utilities;

-------------------------------------------------------------------
-- ValidateHoldSource
-- Validates all the components that form a hold source
-- i.e. hold ID, hold entity code and hold entity ID.
--------------------------------------------------------------------
PROCEDURE ValidateHoldSource
( p_hold_id			IN 	NUMBER
, p_entity_code 		IN 	VARCHAR2
, p_entity_id   		IN 	NUMBER
, p_entity_code2 		IN 	VARCHAR2
, p_entity_id2   		IN 	NUMBER
, x_return_status OUT NOCOPY VARCHAR2

 )
IS
l_dummy		VARCHAR2(30) DEFAULT NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;


	 -- Validate Hold ID

    	 BEGIN

        	SELECT  'x'
        	  INTO  l_dummy
       	  FROM  OE_HOLD_DEFINITIONS
        	 WHERE  HOLD_ID = p_hold_id
        	   AND  SYSDATE
               	BETWEEN NVL(START_DATE_ACTIVE, SYSDATE )
              		    AND NVL(END_DATE_ACTIVE, SYSDATE );

   	 EXCEPTION

        	WHEN NO_DATA_FOUND THEN
        	  IF l_debug_level  > 0 THEN
        	      oe_debug_pub.add(  'INVALID HOLD ID' ) ;
        	  END IF;
	    	  FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_HOLD_ID');
	    	  FND_MESSAGE.SET_TOKEN('HOLD_ID',p_hold_id);
	    	  FND_MSG_PUB.ADD;
	    	  x_return_status := FND_API.G_RET_STS_ERROR;

         END;  -- Validate Hold ID


         -- Validate Entity Code

         IF p_entity_code NOT IN ('C','S','I','O') THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INVALID ENTITY CODE' ) ;
           END IF;
           FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CODE');
	    	 FND_MESSAGE.SET_TOKEN('ENTITY_CODE',p_entity_code);
	    	 FND_MSG_PUB.ADD;
		 x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;  -- Validate Entity Code

         -- Validate Entity ID

         BEGIN

           IF p_entity_code = 'C' THEN

         	   SELECT  'x'
        	     INTO  l_dummy
       	 	FROM  OE_SOLD_TO_ORGS_V
        	    WHERE  ORGANIZATION_ID = p_entity_id;

           ELSIF p_entity_code = 'S' THEN

         	   SELECT  'x'
        	     INTO  l_dummy
       	 	FROM  OE_SHIP_TO_ORGS_V
        	    WHERE  ORGANIZATION_ID = p_entity_id
        	    UNION
        	   SELECT  'x'
       	 	FROM  OE_INVOICE_TO_ORGS_V
        	    WHERE  ORGANIZATION_ID = p_entity_id;

           ELSIF p_entity_code = 'I' THEN

         	   SELECT 'x'
        	     INTO    l_dummy
       		FROM    MTL_SYSTEM_ITEMS
        	    WHERE   inventory_item_id = p_entity_id;

           ELSIF p_entity_code = 'O' THEN

         	   SELECT  'x'
         	     INTO  l_dummy
       	 	FROM  OE_ORDER_HEADERS
        	    WHERE  header_id = p_entity_id;

           END IF;  -- Validate Entity ID

         EXCEPTION
	 	 WHEN NO_DATA_FOUND THEN
	 	   IF l_debug_level  > 0 THEN
	 	       oe_debug_pub.add(  'INVALID ENTITY ID' ) ;
	 	   END IF;
		   FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_ID');
	    	   FND_MESSAGE.SET_TOKEN('ENTITY_ID',p_entity_id);
	    	   FND_MSG_PUB.ADD;
	    	   RAISE FND_API.G_EXC_ERROR;
	      -- too many rows maybe raised if the same entity id
		 -- e.g. an item exists in two orgs.
	    	 WHEN TOO_MANY_ROWS THEN
	    	   null;

	 END; -- Validate Entity ID
	 ----------------------------------------------

       -- Validate Second Entity Code.
	  -- Note second entity is OPTIONAL and may not be passed in
	IF p_entity_code2 is not NULL THEN

       IF p_entity_code2 NOT IN ('C','S','I','O') THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INVALID SECOND ENTITY CODE' ) ;
           END IF;
           FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CODE');
	    	 FND_MESSAGE.SET_TOKEN('ENTITY_CODE',p_entity_code2);
	    	 FND_MSG_PUB.ADD;
		 x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;  -- Validate Entity Code

         -- Validate Entity ID

         BEGIN

           IF p_entity_code2 = 'C' THEN

         	   SELECT  'x'
        	     INTO  l_dummy
       	 	FROM  OE_SOLD_TO_ORGS_V
        	    WHERE  ORGANIZATION_ID = p_entity_id2;

           ELSIF p_entity_code2 = 'S' THEN

         	   SELECT  'x'
        	     INTO  l_dummy
       	 	FROM  OE_SHIP_TO_ORGS_V
        	    WHERE  ORGANIZATION_ID = p_entity_id2
        	    UNION
        	   SELECT  'x'
       	 	FROM  OE_INVOICE_TO_ORGS_V
        	    WHERE  ORGANIZATION_ID = p_entity_id2;

           ELSIF p_entity_code2 = 'I' THEN

         	   SELECT 'x'
        	     INTO    l_dummy
       		FROM    MTL_SYSTEM_ITEMS
        	    WHERE   inventory_item_id = p_entity_id2;

           ELSIF p_entity_code2 = 'O' THEN

         	   SELECT  'x'
         	     INTO  l_dummy
       	 	FROM  OE_ORDER_HEADERS
        	    WHERE  header_id = p_entity_id2;

           END IF;  -- Validate Entity ID

         EXCEPTION
	 	 WHEN NO_DATA_FOUND THEN
	 	   IF l_debug_level  > 0 THEN
	 	       oe_debug_pub.add(  'INVALID SECOND ENTITY ID' ) ;
	 	   END IF;
		   FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_ID');
	    	   FND_MESSAGE.SET_TOKEN('ENTITY_ID',p_entity_id2);
	    	   FND_MSG_PUB.ADD;
	    	   RAISE FND_API.G_EXC_ERROR;
	        -- too many rows maybe raised if the same entity id
		   -- e.g. an item exists in two orgs.
	    	 WHEN TOO_MANY_ROWS THEN
	    	   null;

	 END; -- Validate Second Entity ID

    END IF; -- p_entity_code2 is not NULL THEN
	 ----------------------------------------------

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'ValidateHoldSource');
    	END IF;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END ValidateHoldSource;


PROCEDURE Create_Hold_Source
( p_hold_source_rec	IN  	OE_Hold_Sources_Pvt.Hold_Source_REC
, p_validation_level	IN	NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_hold_source_id OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

)
IS
l_api_name	CONSTANT VARCHAR2(30) := 'CREATE_HOLD_SOURCE';
l_user_id	     NUMBER;
l_count		NUMBER;
l_org_id       NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'IN OE_HOLD_SOURCES_PVT.CREATE_HOLD_SOURCE' ) ;
END IF;
 	SAVEPOINT Create_Hold_Source;

 	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Retrieve user id

   Utilities(l_user_id);

   -- Get the ORG ID - XXXXX Check this
   l_org_id := OE_GLOBALS.G_ORG_ID;
   if l_org_id IS NULL THEN
     OE_GLOBALS.Set_Context;
     l_org_id := OE_GLOBALS.G_ORG_ID;
   end if;

--dbms_output.put_line ('IN Create_Hold_Source');
-- VALIDATION

IF p_validation_level = FND_API.G_VALID_LEVEL_FULL THEN

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CALLING VALIDATEHOLDSOURCE' ) ;
END IF;
-- Validation of input arguments
	ValidateHoldSource
		( p_hold_id			=> p_hold_source_rec.hold_id
		, p_entity_code 		=> p_hold_source_rec.hold_entity_code
		, p_entity_id   		=> p_hold_source_rec.hold_entity_id
		, p_entity_code2 		=> p_hold_source_rec.hold_entity_code2
		, p_entity_id2   		=> p_hold_source_rec.hold_entity_id2
		, x_return_status		=> x_return_status
		);

--dbms_output.put_line ('ValidateHoldSource->x_return_status->' || x_return_status );
 	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
 		IF l_debug_level  > 0 THEN
 		    oe_debug_pub.add(  'VALIDATION NOT SUCCESSFUL' ) ;
 		END IF;
 		IF x_return_status = FND_API.G_RET_STS_ERROR THEN
 			RAISE FND_API.G_EXC_ERROR;
 		ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
 			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 		END IF;
 	END IF;

-- Check for duplicate hold source
 	  SELECT count(*)
 	  INTO l_count
 	  FROM OE_HOLD_SOURCES
 	  WHERE hold_id = p_hold_source_rec.hold_id
 	    AND hold_entity_code = p_hold_source_rec.hold_entity_code
 	    AND hold_entity_id = p_hold_source_rec.hold_entity_id
	    AND nvl(hold_entity_code2, 'NO_ENTITY_CODE2') =
		   nvl(p_hold_source_rec.hold_entity_code2, 'NO_ENTITY_CODE2')
	    AND nvl(hold_entity_id2, -99) =
		   nvl(p_hold_source_rec.hold_entity_id2, -99)
 	    AND	NVL(released_flag, 'N') = 'N';

 	  IF l_count > 0 THEN
--dbms_output.put_line ('Duplicate Hold Source');
 	  	IF l_debug_level  > 0 THEN
 	  	    oe_debug_pub.add(  'DUPLICATE HOLD SOURCE' ) ;
 	  	END IF;
 	        FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD_SOURCE');
	    	FND_MSG_PUB.ADD;
	    	RAISE FND_API.G_EXC_ERROR;
	  END IF;

END IF;  -- End of VALIDATION



-- Inserting a NEW HOLD SOURCE record

    SELECT OE_HOLD_SOURCES_S.NEXTVAL
    INTO x_hold_source_id
    FROM DUAL;


    INSERT INTO OE_HOLD_SOURCES_ALL
    (  HOLD_SOURCE_ID
	, LAST_UPDATE_DATE
 	, LAST_UPDATED_BY
	, CREATION_DATE
 	, CREATED_BY
	, LAST_UPDATE_LOGIN
 	, PROGRAM_APPLICATION_ID
 	, PROGRAM_ID
 	, PROGRAM_UPDATE_DATE
 	, REQUEST_ID
 	, HOLD_ID
 	, HOLD_ENTITY_CODE
 	, HOLD_ENTITY_ID
 	, HOLD_UNTIL_DATE
 	, RELEASED_FLAG
 	, HOLD_COMMENT
	, ORG_ID
 	, CONTEXT
 	, ATTRIBUTE1
 	, ATTRIBUTE2
 	, ATTRIBUTE3
 	, ATTRIBUTE4
 	, ATTRIBUTE5
 	, ATTRIBUTE6
 	, ATTRIBUTE7
 	, ATTRIBUTE8
 	, ATTRIBUTE9
 	, ATTRIBUTE10
 	, ATTRIBUTE11
 	, ATTRIBUTE12
 	, ATTRIBUTE13
 	, ATTRIBUTE14
 	, ATTRIBUTE15
 	, HOLD_RELEASE_ID
	,HOLD_ENTITY_CODE2
	,HOLD_ENTITY_ID2
    )
    VALUES
    (     x_hold_source_id
	, sysdate
 	, l_user_id
	, sysdate
 	, l_user_id
	, p_hold_source_rec.LAST_UPDATE_LOGIN
 	, p_hold_source_rec.PROGRAM_APPLICATION_ID
 	, p_hold_source_rec.PROGRAM_ID
 	, p_hold_source_rec.PROGRAM_UPDATE_DATE
 	, p_hold_source_rec.REQUEST_ID
 	, p_hold_source_rec.HOLD_ID
 	, p_hold_source_rec.HOLD_ENTITY_CODE
 	, p_hold_source_rec.HOLD_ENTITY_ID
 	, p_hold_source_rec.HOLD_UNTIL_DATE
 	, p_hold_source_rec.RELEASED_FLAG
 	, p_hold_source_rec.HOLD_COMMENT
	, l_org_id
 	, p_hold_source_rec.CONTEXT
 	, p_hold_source_rec.ATTRIBUTE1
 	, p_hold_source_rec.ATTRIBUTE2
 	, p_hold_source_rec.ATTRIBUTE3
 	, p_hold_source_rec.ATTRIBUTE4
 	, p_hold_source_rec.ATTRIBUTE5
 	, p_hold_source_rec.ATTRIBUTE6
 	, p_hold_source_rec.ATTRIBUTE7
 	, p_hold_source_rec.ATTRIBUTE8
 	, p_hold_source_rec.ATTRIBUTE9
 	, p_hold_source_rec.ATTRIBUTE10
 	, p_hold_source_rec.ATTRIBUTE11
 	, p_hold_source_rec.ATTRIBUTE12
 	, p_hold_source_rec.ATTRIBUTE13
 	, p_hold_source_rec.ATTRIBUTE14
 	, p_hold_source_rec.ATTRIBUTE15
 	, p_hold_source_rec.HOLD_RELEASE_ID
	,p_hold_source_rec.HOLD_ENTITY_CODE2
	,p_hold_source_rec.HOLD_ENTITY_ID2
    );

--dbms_output.put_line ('End CreateHold_source');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Create_Hold_Source;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Create_Hold_Source;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    WHEN OTHERS THEN
        ROLLBACK TO Create_Hold_Source;
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
END Create_Hold_Source;


PROCEDURE Release_Hold_Source
( p_hold_id			IN 	NUMBER DEFAULT NULL
, p_entity_code 		IN 	VARCHAR2 DEFAULT NULL
, p_entity_id   		IN 	NUMBER DEFAULT NULL
, p_entity_code2 		IN 	VARCHAR2 DEFAULT NULL
, p_entity_id2   		IN 	NUMBER DEFAULT NULL
, p_hold_release_rec		IN	OE_Hold_Sources_Pvt.Hold_Release_REC
, p_validation_level		IN	NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

)
IS
l_user_id		NUMBER;
l_hold_source_id	NUMBER;
l_hold_release_id	NUMBER;
l_hold_release_rec	OE_Hold_Sources_Pvt.Hold_Release_REC;
CURSOR hold_source IS
	SELECT  HS.HOLD_SOURCE_ID
	FROM	OE_HOLD_SOURCES HS
	WHERE   HS.HOLD_ID = p_hold_id
	AND	HS.RELEASED_FLAG = 'N'
	AND	NVL(HS.HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE
	AND	HS.HOLD_ENTITY_CODE = p_entity_code
	AND	HS.HOLD_ENTITY_ID = p_entity_id
	AND	nvl(HS.HOLD_ENTITY_CODE2, 'NO_ENTITY_CODE2') =
		nvl(p_entity_code2, 'NO_ENTITY_CODE2')
	AND	nvl(HS.HOLD_ENTITY_ID2, -99) =
		nvl(p_entity_id2, -99);
		--
		l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
		--
BEGIN

SAVEPOINT  release_hold_source;

-- Retrieve user id

Utilities(l_user_id);

    x_return_status := FND_API.G_RET_STS_SUCCESS;


   l_hold_release_rec := p_hold_release_rec;

-- Retrieving hold source ID if not passed
  IF l_hold_release_rec.hold_source_id IS NULL THEN

    OPEN hold_source;
    FETCH hold_source INTO l_hold_release_rec.hold_source_id;
    IF (hold_source%NOTFOUND) THEN
    	FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_HOLD_SOURCE');
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE hold_source;

  END IF;


-- Inserting record into the hold releases table
    OE_Hold_Sources_Pvt.Insert_Hold_Release
    				( p_hold_release_rec    => l_hold_release_rec
    				, p_validation_level	=> p_validation_level
    				, x_hold_release_id	=> l_hold_release_id
    				, x_return_status	=> x_return_status
    				);
    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
 		IF x_return_status = FND_API.G_RET_STS_ERROR THEN
 			RAISE FND_API.G_EXC_ERROR;
 		ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
 			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 		END IF;
 	END IF;


-- Flag all orders and order line holds for this hold source
-- as released
    UPDATE oe_order_holds_all
    SET hold_release_id = l_hold_release_id
    ,	LAST_UPDATED_BY = l_user_id
    ,	LAST_UPDATE_DATE = sysdate
    WHERE hold_source_id = l_hold_source_id
      AND hold_release_id IS NULL;

-- Completing CHECK_HOLD activities in related flows
-- XXXXXX Complete this later
	Release_Hold_Source_WF
		( p_entity_code		=> p_entity_code
		, p_entity_id		=> p_entity_id
		, x_return_status	=> x_return_status
	 	);

-- Flag the hold source as released
    UPDATE oe_hold_sources
    SET hold_release_id = l_hold_release_id
    ,	released_flag = 'Y'
    ,	LAST_UPDATED_BY = l_user_id
    ,	LAST_UPDATE_DATE = sysdate
    WHERE hold_source_id = l_hold_source_id;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO release_hold_source;
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO release_hold_source;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
       ROLLBACK TO release_hold_source;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'Release_Hold_Source');
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Release_Hold_Source;


PROCEDURE Query_Hold_Source
( p_header_id			IN	NUMBER
, x_hold_source_tbl OUT NOCOPY OE_Hold_Sources_PVT.Hold_Source_TBL

, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_hold_source_REC	OE_Hold_Sources_Pvt.Hold_Source_REC;
i			BINARY_INTEGER := 0;
CURSOR hold_source_REC IS
    SELECT
          HOLD_SOURCE_ID
        , LAST_UPDATE_DATE
        , LAST_UPDATED_BY
        , CREATION_DATE
        , CREATED_BY
        , LAST_UPDATE_LOGIN
        , PROGRAM_APPLICATION_ID
        , PROGRAM_ID
        , PROGRAM_UPDATE_DATE
        , REQUEST_ID
        , HOLD_ID
        , HOLD_ENTITY_CODE
        , HOLD_ENTITY_ID
        , HOLD_UNTIL_DATE
        , RELEASED_FLAG
        , HOLD_COMMENT
        , CONTEXT
        , ATTRIBUTE1
        , ATTRIBUTE2
        , ATTRIBUTE3
        , ATTRIBUTE4
        , ATTRIBUTE5
        , ATTRIBUTE6
        , ATTRIBUTE7
        , ATTRIBUTE8
        , ATTRIBUTE9
        , ATTRIBUTE10
        , ATTRIBUTE11
        , ATTRIBUTE12
        , ATTRIBUTE13
        , ATTRIBUTE14
        , ATTRIBUTE15
        , ORG_ID
        , HOLD_RELEASE_ID
        , HOLD_ENTITY_CODE2
        , HOLD_ENTITY_ID2
    FROM OE_HOLD_SOURCES
    WHERE hold_source_id IN (SELECT hold_source_id
    			  	FROM OE_ORDER_HOLDS
    			  	WHERE header_id = p_header_id
    			  	  AND line_id IS NULL
    			  	  AND hold_release_id IS NULL
    			  	  );
    			  	  --
    			  	  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    			  	  --
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    FOR l_hold_source_REC IN hold_source_REC
    LOOP

    	i := i+1;
    	x_hold_source_tbl(i) := l_hold_source_REC;

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
     	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'Query_Hold_Source');
    	END IF;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Query_Hold_Source;


PROCEDURE Query_Line__Hold_Source
( p_line_id                     IN      NUMBER
, x_hold_source_tbl OUT NOCOPY OE_Hold_Sources_PVT.Hold_Source_TBL
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_hold_source_REC       OE_Hold_Sources_Pvt.Hold_Source_REC;
i                       BINARY_INTEGER := 0;
CURSOR hold_source_REC IS
    SELECT
          HOLD_SOURCE_ID
        , LAST_UPDATE_DATE
        , LAST_UPDATED_BY
        , CREATION_DATE
        , CREATED_BY
        , LAST_UPDATE_LOGIN
        , PROGRAM_APPLICATION_ID
        , PROGRAM_ID
        , PROGRAM_UPDATE_DATE
        , REQUEST_ID
        , HOLD_ID
        , HOLD_ENTITY_CODE
        , HOLD_ENTITY_ID
        , HOLD_UNTIL_DATE
        , RELEASED_FLAG
        , HOLD_COMMENT
        , CONTEXT
        , ATTRIBUTE1
        , ATTRIBUTE2
        , ATTRIBUTE3
        , ATTRIBUTE4
        , ATTRIBUTE5
        , ATTRIBUTE6
        , ATTRIBUTE7
        , ATTRIBUTE8
        , ATTRIBUTE9
        , ATTRIBUTE10
        , ATTRIBUTE11
        , ATTRIBUTE12
        , ATTRIBUTE13
        , ATTRIBUTE14
        , ATTRIBUTE15
        , ORG_ID
        , HOLD_RELEASE_ID
        , HOLD_ENTITY_CODE2
        , HOLD_ENTITY_ID2
    FROM OE_HOLD_SOURCES
    WHERE hold_source_id IN (SELECT hold_source_id
                                FROM OE_ORDER_HOLDS
                                WHERE line_id = p_line_id
                                  AND hold_release_id IS NULL
                                  );

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    FOR l_hold_source_REC IN hold_source_REC
    LOOP

        i := i+1;
        x_hold_source_tbl(i) := l_hold_source_REC;

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'Query_Hold_Source');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Query_Line__Hold_Source;



PROCEDURE Insert_Hold_Release
( p_hold_release_rec		IN	OE_Hold_Sources_Pvt.Hold_Release_Rec
, p_validation_level		IN	VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_hold_release_id OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2

 )
IS
--l_hold_entity_id	NUMBER;
--l_hold_entity_code	VARCHAR2(1);
l_dummy			VARCHAR2(30);
l_user_id		NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN INSERT_HOLD_RELEASE' ) ;
    END IF;

    SAVEPOINT insert_hold_release;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Utilities(l_user_id);

------------------------------------------------------------------
-- Validate Input Parameters
------------------------------------------------------------------

   IF p_validation_level = FND_API.G_VALID_LEVEL_FULL THEN

	-- Validate Reason Code

    	BEGIN

        	SELECT  'x'
        	INTO    l_dummy
       	 	FROM    OE_LOOKUPS
        	WHERE   LOOKUP_TYPE = 'RELEASE_REASON'
        	AND     LOOKUP_CODE = p_hold_release_rec.release_reason_code;

   	 EXCEPTION

        	WHEN NO_DATA_FOUND THEN
	    	FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_REASON_CODE');
	    	FND_MESSAGE.SET_TOKEN('REASON_CODE',p_hold_release_rec.release_reason_code);
	    	FND_MSG_PUB.ADD;
	    	RAISE FND_API.G_EXC_ERROR;

         END;  -- Validate Reason Code

   END IF; -- End of Validation

   -- To_do : Remove the following code when the redundant columns hold_entity_id
   -- and hold_entity_code are removed from OE_HOLD_RELEASES.
   --SELECT hold_entity_id, hold_entity_code
   --INTO l_hold_entity_id, l_hold_entity_code
   --FROM oe_hold_sources
   --WHERE hold_source_id = p_hold_release_rec.hold_source_id;


 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'BEFORE INSERT' ) ;
 END IF;


    SELECT	OE_HOLD_RELEASES_S.NEXTVAL
    INTO	x_hold_release_id
    FROM	DUAL;

    INSERT INTO OE_HOLD_RELEASES
 	( HOLD_RELEASE_ID
 	, CREATION_DATE
 	, CREATED_BY
 	, LAST_UPDATE_DATE
 	, LAST_UPDATED_BY
 	, LAST_UPDATE_LOGIN
 	, PROGRAM_APPLICATION_ID
 	, PROGRAM_ID
 	, PROGRAM_UPDATE_DATE
 	, REQUEST_ID
 	, HOLD_SOURCE_ID
-- 	, HOLD_ENTITY_ID
-- 	, HOLD_ENTITY_CODE
 	, RELEASE_REASON_CODE
 	, RELEASE_COMMENT
 	, CONTEXT
 	, ATTRIBUTE1
 	, ATTRIBUTE2
	, ATTRIBUTE3
 	, ATTRIBUTE4
 	, ATTRIBUTE5
 	, ATTRIBUTE6
 	, ATTRIBUTE7
 	, ATTRIBUTE8
 	, ATTRIBUTE9
 	, ATTRIBUTE10
 	, ATTRIBUTE11
 	, ATTRIBUTE12
 	, ATTRIBUTE13
 	, ATTRIBUTE14
 	, ATTRIBUTE15
 	)
   VALUES
   	( x_hold_release_id
 	, sysdate
 	, l_user_id
 	, sysdate
 	, l_user_id
 	, p_hold_release_rec.LAST_UPDATE_LOGIN
 	, p_hold_release_rec.PROGRAM_APPLICATION_ID
 	, p_hold_release_rec.PROGRAM_ID
 	, p_hold_release_rec.PROGRAM_UPDATE_DATE
 	, p_hold_release_rec.REQUEST_ID
 	, p_hold_release_rec.HOLD_SOURCE_ID
 	 -- To_do : Remove the following code when the redundant columns hold_entity_id
  	 -- and hold_entity_code are removed from OE_HOLD_RELEASES.
 --	, l_hold_entity_id
 --	, l_hold_entity_code
 	, p_hold_release_rec.RELEASE_REASON_CODE
 	, p_hold_release_rec.RELEASE_COMMENT
 	, p_hold_release_rec.CONTEXT
 	, p_hold_release_rec.ATTRIBUTE1
 	, p_hold_release_rec.ATTRIBUTE2
	, p_hold_release_rec.ATTRIBUTE3
 	, p_hold_release_rec.ATTRIBUTE4
 	, p_hold_release_rec.ATTRIBUTE5
 	, p_hold_release_rec.ATTRIBUTE6
 	, p_hold_release_rec.ATTRIBUTE7
 	, p_hold_release_rec.ATTRIBUTE8
 	, p_hold_release_rec.ATTRIBUTE9
 	, p_hold_release_rec.ATTRIBUTE10
 	, p_hold_release_rec.ATTRIBUTE11
 	, p_hold_release_rec.ATTRIBUTE12
 	, p_hold_release_rec.ATTRIBUTE13
 	, p_hold_release_rec.ATTRIBUTE14
 	, p_hold_release_rec.ATTRIBUTE15
 	);

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'AFTER INSERT' ) ;
	END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        ROLLBACK TO insert_hold_release;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO insert_hold_release;
    WHEN OTHERS THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'Insert_Hold_Release');
       END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO insert_hold_release;
END Insert_Hold_Release;



PROCEDURE Release_Hold_Source_WF
( p_entity_code		IN VARCHAR2
, p_entity_id		IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_site_code	VARCHAR2(30);
--CURSOR customer_wf IS
--        SELECT wf.item_type item_type, wf.item_key item_key
--  	FROM wf_item_activity_statuses_v wf, oe_order_headers h,
--  	     oe_order_lines_all l
--  	WHERE activity_name = 'CHECK_HOLDS'
--  		 AND activity_status_code = 'NOTIFIED'
-- 	         AND (  (item_type = 'OEOH'
--                        AND item_key = to_char(h.header_id))
--                     OR (item_type = 'OEOL'
--                        AND item_key = to_char(l.line_id)
--                        AND l.header_id = h.header_id)
--                     )
-- 	         AND h.sold_to_org_id = p_entity_id;
--CURSOR bill_to_site_wf IS
--        SELECT wf.item_type item_type, wf.item_key item_key
--  	FROM wf_item_activity_statuses_v wf,
--  	     oe_order_lines_all l
--  	WHERE activity_name = 'CHECK_HOLDS'
--  		 AND activity_status_code = 'NOTIFIED'
-- 	         AND item_type = 'OEOL'
--                 AND item_key = to_char(l.line_id)
-- 	         AND l.invoice_to_org_id = p_entity_id;
--CURSOR ship_to_site_wf IS
--        SELECT wf.item_type item_type, wf.item_key item_key
--  	FROM wf_item_activity_statuses_v wf,
--  	     oe_order_lines_all l
--  	WHERE activity_name = 'CHECK_HOLDS'
--  		 AND activity_status_code = 'NOTIFIED'
-- 	         AND item_type = 'OEOL'
--                 AND item_key = to_char(l.line_id)
-- 	         AND l.ship_to_org_id = p_entity_id;
--CURSOR item_wf IS
--        SELECT wf.item_type item_type, wf.item_key item_key
--  	FROM wf_item_activity_statuses_v wf,
--  	     oe_order_lines_all l
--  	WHERE activity_name = 'CHECK_HOLDS'
--  		 AND activity_status_code = 'NOTIFIED'
-- 	         AND item_type = 'OEOL'
--                 AND item_key = to_char(l.line_id)
-- 	         AND l.inventory_item_id = p_entity_id;
--CURSOR order_wf IS
--        SELECT wf.item_type item_type, wf.item_key item_key
--  	FROM wf_item_activity_statuses_v wf, oe_order_headers h,
--	     oe_order_lines_all l
--  	WHERE activity_name = 'CHECK_HOLDS'
--  		 AND activity_status_code = 'NOTIFIED'
-- 	         AND (  (item_type = 'OEOH'
-- 	         	AND item_key = to_char(p_entity_id))
--                     OR (item_type = 'OEOL'
--                         AND item_key = to_char(l.line_id)
--			 AND l.header_id = p_entity_id)
--                     );
--                     --
                     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
                     --
BEGIN

--    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- CUSTOMER HOLD SOURCE
/*     IF p_entity_code = 'C' THEN

       FOR curr_wf IN customer_wf LOOP

           WF_ENGINE.CompleteActivity( curr_wf.item_type
                                      , curr_wf.item_key
                                      , 'CHECK_HOLDS'
                                      , 'HOLD_RELEASED'
                                      );
       END LOOP;
*/
-- SITE HOLD SOURCE
/*     ELSIF p_entity_code = 'S' THEN

	SELECT 	SITE.SITE_USE_CODE
	INTO 	l_site_code
	FROM 	HZ_CUST_SITE_USES SITE,    -- Bug 2138398
		HR_ORGANIZATION_INFORMATION INFO
	WHERE	INFO.ORGANIZATION_ID = p_entity_id
	AND	INFO.ORG_INFORMATION_CONTEXT = 'Customer/Supplier Association'
	AND	SITE.SITE_USE_ID = TO_NUMBER ( INFO.ORG_INFORMATION2 );
*/
     -- Bill-to site hold source
/*     	IF l_site_code = 'BILL_TO' THEN

		FOR curr_wf IN bill_to_site_wf LOOP

           	WF_ENGINE.CompleteActivity( curr_wf.item_type
                                      	, curr_wf.item_key
                                      	, 'CHECK_HOLDS'
                                      	, 'HOLD_RELEASED'
                                      	);
       		END LOOP;
*/
     -- Ship-to site hold source
/*	ELSIF l_site_code = 'SHIP_TO' THEN

		FOR curr_wf IN ship_to_site_wf LOOP

           	WF_ENGINE.CompleteActivity( curr_wf.item_type
                                      	, curr_wf.item_key
                                      	, 'CHECK_HOLDS'
                                      	, 'HOLD_RELEASED'
                                      	);
       		END LOOP;

         END IF;

*/
-- ITEM HOLD SOURCE
/*     ELSIF p_entity_code = 'I' THEN

		FOR curr_wf IN item_wf LOOP

           	WF_ENGINE.CompleteActivity( curr_wf.item_type
                                      	, curr_wf.item_key
                                      	, 'CHECK_HOLDS'
                                      	, 'HOLD_RELEASED'
                                      	);
       		END LOOP;
*/
-- ORDER HOLD SOURCE
/*     ELSIF p_entity_code = 'O' THEN

       FOR curr_wf IN order_wf LOOP

           WF_ENGINE.CompleteActivity( curr_wf.item_type
                                      , curr_wf.item_key
                                      , 'CHECK_HOLDS'
                                      , 'HOLD_RELEASED'
                                      );
       END LOOP;

     END IF;
*/
null;

EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO release_hold_source_wf;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'Release_Hold_Source_WF');
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Release_Hold_Source_WF;


END OE_Hold_Sources_Pvt;

/
