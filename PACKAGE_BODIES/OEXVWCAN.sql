--------------------------------------------------------
--  DDL for Package Body OEXVWCAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEXVWCAN" AS
/* $Header: OEXVWCNB.pls 115.3 99/07/16 08:17:08 porting shi $ */

------------------------------------------------------------------------
function SHIPMENT_SCHEDULE_NUMBER(
   P_PARENT_LINE_ID                       IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID               IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID            IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                          IN NUMBER DEFAULT NULL
                          )
   return NUMBER
IS
   V_SHIPMENT_SCHEDULE_LINE_ID NUMBER := NULL;  -- default is NULL
   V_PARENT_LINE_ID NUMBER := NULL;  -- default is NULL
   V_LINE_NUMBER NUMBER := NULL;  -- default is NULL
   SCHEDULE_LINE_NUMBER NUMBER := NULL;  -- default is NULL
BEGIN
   IF (  P_SERVICE_PARENT_LINE_ID IS NULL )
    THEN
       V_SHIPMENT_SCHEDULE_LINE_ID := P_SHIPMENT_SCHEDULE_LINE_ID;
       V_PARENT_LINE_ID := P_PARENT_LINE_ID;
       V_LINE_NUMBER := P_LINE_NUMBER;
    ELSE
         SELECT SHIPMENT_SCHEDULE_LINE_ID,
		PARENT_LINE_ID,
		LINE_NUMBER
         INTO   V_SHIPMENT_SCHEDULE_LINE_ID,
		V_PARENT_LINE_ID,
		V_LINE_NUMBER
         FROM   SO_LINES
         WHERE  LINE_ID = P_SERVICE_PARENT_LINE_ID;
   END IF;
   IF (V_SHIPMENT_SCHEDULE_LINE_ID IS NOT NULL) THEN
	IF (V_PARENT_LINE_ID IS NULL) THEN
		SCHEDULE_LINE_NUMBER := V_LINE_NUMBER;
        ELSE
        	SELECT	LINE_NUMBER
        	INTO	SCHEDULE_LINE_NUMBER
		FROM	SO_LINES
		WHERE	LINE_ID = V_PARENT_LINE_ID;
        END IF;
   END IF;

   RETURN(SCHEDULE_LINE_NUMBER);

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN( NULL );
END ; -- SHIPMENT_LINE_NUMBER


------------------------------------------------------------------------
 function BASE_LINE_NUMBER(
   P_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID              IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID           IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                         IN NUMBER DEFAULT NULL
                          )
   return NUMBER
IS
   V_SHIPMENT_SCHEDULE_LINE_ID NUMBER := NULL;  -- default is NULL
   V_PARENT_LINE_ID NUMBER := NULL;  -- default is NULL
   V_LINE_NUMBER NUMBER := NULL;  -- default is NULL
   BASE_LINE_NUMBER NUMBER := NULL;  -- default is NULL
BEGIN
   IF (  P_SERVICE_PARENT_LINE_ID IS NULL )
    THEN
       V_SHIPMENT_SCHEDULE_LINE_ID := P_SHIPMENT_SCHEDULE_LINE_ID;
       V_PARENT_LINE_ID := P_PARENT_LINE_ID;
       V_LINE_NUMBER := P_LINE_NUMBER;
    ELSE
         SELECT SHIPMENT_SCHEDULE_LINE_ID,
                PARENT_LINE_ID,
                LINE_NUMBER
         INTO   V_SHIPMENT_SCHEDULE_LINE_ID,
                V_PARENT_LINE_ID,
                V_LINE_NUMBER
         FROM   SO_LINES
         WHERE  LINE_ID = P_SERVICE_PARENT_LINE_ID;
   END IF;
   IF (V_SHIPMENT_SCHEDULE_LINE_ID IS NULL) THEN
        IF (V_PARENT_LINE_ID IS NULL) THEN
                BASE_LINE_NUMBER := V_LINE_NUMBER;
	ELSE
		SELECT  LINE_NUMBER
	        INTO    BASE_LINE_NUMBER
		FROM    SO_LINES
		WHERE   LINE_ID = V_PARENT_LINE_ID;
        END IF;
   ELSE
	SELECT	LINE_NUMBER
	INTO	BASE_LINE_NUMBER
	FROM	SO_LINES
	WHERE	LINE_ID = V_SHIPMENT_SCHEDULE_LINE_ID;
   END IF;

   RETURN(BASE_LINE_NUMBER);

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN( NULL );
END ; -- BASE_LINE_NUMBER

------------------------------------------------------------------------
function OPTION_LINE_NUMBER(
   P_PARENT_LINE_ID                       IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID               IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID            IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                          IN NUMBER DEFAULT NULL
                          )
   return NUMBER
IS
   V_SHIPMENT_SCHEDULE_LINE_ID NUMBER := NULL;  -- default is NULL
   V_PARENT_LINE_ID NUMBER := NULL;  -- default is NULL
   V_LINE_NUMBER NUMBER := NULL;  -- default is NULL
   OPTION_LINE_NUMBER NUMBER := NULL;  -- default is NULL
BEGIN
   IF (  P_SERVICE_PARENT_LINE_ID IS NULL )
    THEN
       V_SHIPMENT_SCHEDULE_LINE_ID := P_SHIPMENT_SCHEDULE_LINE_ID;
       V_PARENT_LINE_ID := P_PARENT_LINE_ID;
       V_LINE_NUMBER := P_LINE_NUMBER;
    ELSE
         SELECT SHIPMENT_SCHEDULE_LINE_ID,
		PARENT_LINE_ID,
		LINE_NUMBER
         INTO   V_SHIPMENT_SCHEDULE_LINE_ID,
		V_PARENT_LINE_ID,
		V_LINE_NUMBER
         FROM   SO_LINES
         WHERE  LINE_ID = P_SERVICE_PARENT_LINE_ID;
   END IF;
   IF (V_SHIPMENT_SCHEDULE_LINE_ID IS NULL) THEN
	IF (V_PARENT_LINE_ID IS NOT NULL) THEN
		OPTION_LINE_NUMBER := V_LINE_NUMBER;
	END IF;
   ELSE
	IF (V_SHIPMENT_SCHEDULE_LINE_ID IS NOT NULL) THEN
           IF (V_PARENT_LINE_ID IS NOT NULL) THEN
                OPTION_LINE_NUMBER := V_LINE_NUMBER;
           END IF;
	END IF;
   END IF;

   RETURN(OPTION_LINE_NUMBER);


EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN( NULL );
END ; -- OPTION_LINE_NUMBER

----------------------------------------------------------------
 function SUBTREE_EXISTS(
   V_LINE_ID				IN NUMBER
,  V_REAL_PARENT_LINE_ID		IN NUMBER
                          )
   return VARCHAR2
IS
	V_SUBTREE_EXISTS	VARCHAR2(1);
BEGIN

	SELECT	'Y'
	INTO	V_SUBTREE_EXISTS
	FROM	SO_LINES
	WHERE	LINK_TO_LINE_ID = V_LINE_ID
	AND	PARENT_LINE_ID = V_REAL_PARENT_LINE_ID
	AND	ITEM_TYPE_CODE <> 'SERVICE'
	AND	LINE_TYPE_CODE <> 'RETURN'
	AND     ROWNUM = 1;


RETURN(V_SUBTREE_EXISTS);

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN('N');
END ; -- SUBTREE_EXISTS

----------------------------------------------------------------
 function IN_CONFIGURATION(
   V_PARENT_LINE_ID			IN NUMBER
,  V_ITEM_TYPE_CODE			IN VARCHAR2
,  V_SERVICE_PARENT_LINE_ID		IN NUMBER
                          )
   return VARCHAR2
IS
	RESULT VARCHAR2(1);
	TEMP_ITEM_TYPE_CODE VARCHAR2(30);
BEGIN
	IF (V_PARENT_LINE_ID IS NOT NULL) THEN
-- If parent_line_id is not null, we know this line is in a configuration
		RESULT := 'Y';
	ELSE
		IF (V_ITEM_TYPE_CODE = 'MODEL') THEN
-- Top model line is also in a configuration
			RESULT := 'Y';
		ELSIF (V_ITEM_TYPE_CODE = 'SERVICE') THEN
-- Because there is no way that you can tell if a service line is attached
-- to a top model line, in which case it is in a configuration,
-- or if the service line is attached to a standard line, in which case it
-- is not in a congifuration, we have to detect item_type_code of the line
-- the service line is attached to.
			IF (V_SERVICE_PARENT_LINE_ID IS NULL) THEN
-- A service line may have a NULL SERVICE_PARENT_LINE_ID, yet is not part of
-- a configuration.
				RESULT := 'N';
			ELSE
				SELECT ITEM_TYPE_CODE
				INTO TEMP_ITEM_TYPE_CODE
				FROM SO_LINES
				WHERE LINE_ID = V_SERVICE_PARENT_LINE_ID;

				IF (TEMP_ITEM_TYPE_CODE = 'MODEL') THEN
					RESULT := 'Y';
				ELSE
					RESULT := 'N';
				END IF;
			END IF;
		ELSE
			RESULT := 'N';
		END IF;
	END IF;
	RETURN (RESULT);

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN('N');
END ; -- IN_CONFIGURATION

----------------------------------------------------------------
 function OPEN_PICKING_SLIPS(
   V_LINE_ID                            IN NUMBER
,  V_REAL_PARENT_LINE_ID                IN NUMBER
,  V_COMPONENT_CODE                     IN VARCHAR2
                          )
   return VARCHAR2
IS
	V_OPEN_PICKING_SLIPS	VARCHAR2(1);
	V_SUBTREE_EXISTS	VARCHAR2(1);
BEGIN

	V_SUBTREE_EXISTS := OEXVWCAN.SUBTREE_EXISTS(V_LINE_ID,
		V_REAL_PARENT_LINE_ID);

	SELECT	'Y'
	INTO 	V_OPEN_PICKING_SLIPS
	FROM 	SO_PICKING_LINES SOL,
		SO_PICKING_HEADERS SPH
	WHERE 	SOL.PICKING_HEADER_ID = SPH.PICKING_HEADER_ID
	AND 	SOL.ORDER_LINE_ID in
		(SELECT	LINE_ID
		FROM	SO_LINES
		WHERE 	PARENT_LINE_ID = V_REAL_PARENT_LINE_ID
		AND	NVL(COMPONENT_CODE,'0') LIKE V_COMPONENT_CODE || '%'
		AND	V_SUBTREE_EXISTS = 'Y'
		UNION
		SELECT	LINE_ID
		FROM	SO_LINES
		WHERE	LINE_ID = V_LINE_ID)
	AND 	SPH.STATUS_CODE IN ('OPEN' ,'PENDING', 'IN PROGRESS')
        AND     ROWNUM = 1;

RETURN(V_OPEN_PICKING_SLIPS);

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN('N');
END ; -- OPEN_PICKING_SLIPS

----------------------------------------------------------------
 function PRICE_ADJUST_EXISTS(
   V_HEADER_ID                          IN NUMBER
,  V_LINE_ID                            IN NUMBER
                          )
   return VARCHAR2
IS
	V_PRICE_ADJUST_EXISTS	VARCHAR2(1);
        V_PRICE_ADJUST_COUNT    NUMBER := NULL;  -- default is NULL
BEGIN

	SELECT 	COUNT(0)
	INTO	V_PRICE_ADJUST_COUNT
	FROM 	SO_PRICE_ADJUSTMENTS PA,
		SO_DISCOUNT_LINES DL
	WHERE 	PA.HEADER_ID = V_HEADER_ID
	AND   	PA.LINE_ID = V_LINE_ID
	AND   	PA.DISCOUNT_LINE_ID = DL.DISCOUNT_LINE_ID
	AND   	DL.PERCENT IS NULL
	AND  	DL.AMOUNT IS NULL
	AND  	DL.PRICE IS NULL;

        IF V_PRICE_ADJUST_COUNT = 0
        THEN
          V_PRICE_ADJUST_EXISTS := 'N';
        ELSE
          V_PRICE_ADJUST_EXISTS := 'Y';
        END IF;

RETURN(V_PRICE_ADJUST_EXISTS);
END ; -- PRICE_ADJUST_EXISTS


----------------------------------------------------------------
 function TOP_BILL_SEQUENCE_ID(
   V_LINE_ID	                       IN NUMBER DEFAULT NULL
,  V_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
                          )
   return NUMBER
IS
	V_TOP_BILL_SEQUENCE_ID		NUMBER;
BEGIN

	SELECT COMPONENT_SEQUENCE_ID
	INTO   V_TOP_BILL_SEQUENCE_ID
	FROM   SO_LINES
	WHERE  LINE_ID = NVL(V_PARENT_LINE_ID,V_LINE_ID);

RETURN(V_TOP_BILL_SEQUENCE_ID);

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN(NULL);
END ; -- TOP_BILL_SEQUENCE_ID

----------------------------------------------------------------
 function SECURITY_OBJECT(
   V_PARENT_LINE_ID                     IN NUMBER
,  V_SHIPMENT_SCHEDULE_LINE_ID          IN NUMBER
,  V_SERVICE_PARENT_LINE_ID             IN NUMBER
,  V_LINE_TYPE_CODE                     IN VARCHAR2
                          )
   return VARCHAR2
IS
	V_SECURITY_OBJECT	VARCHAR(30);
BEGIN

	if (V_LINE_TYPE_CODE = 'RETURN') then
		V_SECURITY_OBJECT := 'RETURN_LINE';
		RETURN(V_SECURITY_OBJECT);
	end if;

	if (V_SERVICE_PARENT_LINE_ID is NULL) then
		if (V_SHIPMENT_SCHEDULE_LINE_ID is NULL) then
			if (V_PARENT_LINE_ID is NULL) then
				V_SECURITY_OBJECT := 'LINE';
			else
				V_SECURITY_OBJECT := 'OPTION';
			end if;
		else
                        if (V_PARENT_LINE_ID is NULL) then
                                V_SECURITY_OBJECT := 'SHIPMENT';
                        else
                                V_SECURITY_OBJECT := 'SHIP_OPTION';
                        end if;
		end if;
	else
		if (V_SHIPMENT_SCHEDULE_LINE_ID is NULL) then
                        if (V_PARENT_LINE_ID is NULL) then
                                V_SECURITY_OBJECT := 'SERVICE';
                        else
                                V_SECURITY_OBJECT := 'OPTION_SERVICE';
                        end if;
                else
                        if (V_PARENT_LINE_ID is NULL) then
                                V_SECURITY_OBJECT := 'SHIPMENT_SERVICE';
                        else
                                V_SECURITY_OBJECT := 'SHIP_OPTION_SERVICE';
                        end if;
                end if;
	end if;

RETURN(V_SECURITY_OBJECT);

END ; -- SECURITY_OBJECT


END OEXVWCAN;

/
