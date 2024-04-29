--------------------------------------------------------
--  DDL for Package Body OE_CANSRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CANSRV" AS
/* $Header: OECANSVB.pls 115.4 99/07/16 08:10:37 porting shi $ */

------------------------------------------------------------------------
-- procedure  CHECK_LINE_INTERFACED
--
--	See if the line in question is interfaced to service
--	If S25 (Service Interface) is not equal to 8 (Not Applicable) or
--	18 (Eligible) then the line is interfaced.
--
-- RETURNS
--	1 -> line is service interfaced
--	0 -> line is not service interfaced.
------------------------------------------------------------------------
procedure  CHECK_LINE_INTERFACED(
   V_LINE_ID                         IN NUMBER
,  V_RESULT			     OUT NUMBER
                          )
IS
	DUMMY      NUMBER :=0;

BEGIN

 SELECT  COUNT(*)
 INTO    DUMMY
 FROM    SO_LINES
 WHERE   LINE_ID = V_LINE_ID
 AND     S25 NOT IN (8,18);

 IF DUMMY >= 1 THEN
  V_RESULT := 1;
  RETURN;
 END IF;

 V_RESULT := 0;
END CHECK_LINE_INTERFACED;

------------------------------------------------------------------------
-- procedure  CHECK_ORDER_INT_RECS_EXIST
--
--	get the concurrent_process_id from the cs_orders_interface
-- 	if a row is not found return null for the concurrent_process_id
--
-- RETURNS
--	1 -> success
--      CONCURRENT_PROCESS_ID
------------------------------------------------------------------------
procedure CHECK_ORDER_INT_RECS_EXIST(
   V_LINE_ID                      IN NUMBER
,  V_CONCURRENT_PROCESS_ID	  IN OUT NUMBER
,  V_RESULT			  OUT NUMBER
                          )
IS
	DUMMY 		NUMBER := '';

BEGIN

 SELECT CONCURRENT_PROCESS_ID
 INTO   DUMMY
 FROM   CS_ORDERS_INTERFACE
 WHERE  LINE_ID = V_LINE_ID
 AND    TRANSACTION_CODE IN ('ORDER', 'RENEW');

 IF DUMMY IS NOT NULL THEN
  V_CONCURRENT_PROCESS_ID  := DUMMY;
  V_RESULT := 1;
  RETURN;
 END IF;

 V_RESULT :=0;
END CHECK_ORDER_INT_RECS_EXIST;

------------------------------------------------------------------------
-- procedure  CHECK_ORDER_INT_NOT_IN_PROG
------------------------------------------------------------------------
procedure CHECK_ORDER_INT_NOT_IN_PROG(
   V_LINE_ID                      IN NUMBER
,  V_PRINT_ERR_MSG		  IN NUMBER
,  V_CONCURRENT_PROCESS_ID	  IN OUT NUMBER
,  V_RESULT			  OUT NUMBER
                          )
IS
	CONCURRENT_PROCESS_ID_TEMP	NUMBER :='';
	RESULT1				NUMBER :='';
	x 				BOOLEAN;
BEGIN

 OE_CANSRV.CHECK_ORDER_INT_RECS_EXIST(
 	V_LINE_ID, CONCURRENT_PROCESS_ID_TEMP, RESULT1);

 IF RESULT1 = 1 THEN
  V_RESULT := 1;
  RETURN;
 END IF;

 IF V_PRINT_ERR_MSG = 1 THEN
   x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_LINE_IN_PROCESS');
   -- This line is being processed.  Please make this change later.
 END IF;

 V_RESULT := 0;
END CHECK_ORDER_INT_NOT_IN_PROG;


------------------------------------------------------------------------
-- procedure  MAKE_DELETE_INT_RECS
------------------------------------------------------------------------
procedure MAKE_DELETE_INT_RECS(
   V_LINE_ID                      IN NUMBER
,  V_CUSTOMER_PRODUCT_ID	  IN NUMBER
,  V_CP_SERVICE_ID		  IN NUMBER
,  V_LAST_UPDATED_BY		  IN NUMBER
,  V_SERVICE_MASS_TXN_TEMP_ID	  IN NUMBER
,  V_RESULT			  OUT NUMBER
                          )
IS
	DUMMY		NUMBER :='';
        DUMMY2		NUMBER :='';

BEGIN

 V_RESULT := 0;

 SELECT COUNT(*)
 INTO   DUMMY
 FROM   SO_LINES
 WHERE  LINE_ID = V_LINE_ID
 AND    (CP_SERVICE_ID IS NOT NULL
           AND SERVICE_MASS_TXN_TEMP_ID IS NOT NULL);

 IF DUMMY >= 1 THEN

  INSERT INTO CS_ORDERS_INTERFACE
       (ORDER_INTERFACE_ID,
        CREATED_BY,
        CREATION_DATE,
        SERVICE_ITEM_FLAG,
        TRANSACTION_CODE,
        LINE_ID,
        CP_SERVICE_ID,
        MASS_RENEW_TXN_TEMP_ID)
  VALUES
       (CS_ORDERS_INTERFACE_S.NEXTVAL,
        V_LAST_UPDATED_BY,
        SYSDATE,
        'Y',
        'DELETE',
        V_LINE_ID,
        V_CP_SERVICE_ID,
        V_SERVICE_MASS_TXN_TEMP_ID);

  V_RESULT := 1;
  RETURN;
 END IF;

 SELECT COUNT(*)
 INTO   DUMMY2
 FROM   SO_LINES
 WHERE  LINE_ID = V_LINE_ID
 AND    (CUSTOMER_PRODUCT_ID IS NOT NULL
         AND SERVICE_MASS_TXN_TEMP_ID IS NOT NULL);

 IF DUMMY2 >= 1 THEN

  INSERT INTO CS_ORDERS_INTERFACE
       (ORDER_INTERFACE_ID,
        CREATED_BY,
        CREATION_DATE,
        SERVICE_ITEM_FLAG,
        TRANSACTION_CODE,
        LINE_ID,
        CANCEL_CP_ID,
        MASS_RENEW_TXN_TEMP_ID)
  VALUES
       (CS_ORDERS_INTERFACE_S.NEXTVAL,
        V_LAST_UPDATED_BY,
        SYSDATE,
        'N',
        'DELETE',
        V_LINE_ID,
        V_CUSTOMER_PRODUCT_ID,
        V_SERVICE_MASS_TXN_TEMP_ID);

  V_RESULT := 1;
  RETURN;
 END IF;

END MAKE_DELETE_INT_RECS;


------------------------------------------------------------------------
-- procedure  CANCEL_SERVICE_CHILDREN
------------------------------------------------------------------------
procedure CANCEL_SERVICE_CHILDREN(
   V_LINE_ID                      IN NUMBER
,  V_HEADER_ID                    IN NUMBER
,  V_CANCEL_CODE                  IN VARCHAR2
,  V_CANCEL_COMMENT               IN LONG
,  V_FULL                         IN NUMBER
,  V_STATUS                       IN VARCHAR2
,  V_REQUESTED_CANCEL_QTY         IN NUMBER
,  V_CUSTOMER_PRODUCT_ID          IN NUMBER
,  V_CP_SERVICE_ID                IN NUMBER
,  V_LAST_UPDATED_BY              IN NUMBER
,  V_LAST_UPDATE_LOGIN		  IN NUMBER
,  V_SERVICE_MASS_TXN_TEMP_ID     IN NUMBER
,  V_PRINT_ERR_MSG                IN NUMBER
,  V_CONCURRENT_PROCESS_ID        IN OUT NUMBER
,  V_RESULT                       OUT NUMBER
			 )
IS
	CHECK_LINE_INTERFACE_RESULT  NUMBER := 0;
	CHECK_ORDER_INT_RECS_RESULT  NUMBER := 0;
	CHECK_ORDER_INT_NOT_RESULT   NUMBER := 0;
	MAKE_DELETE_INT_RECS_RESULT  NUMBER := 0;

	LOOP_LINE_ID		  	NUMBER := '';
	LOOP_REQUESTED_CANCEL_QTY	NUMBER := '';
	LOOP_CUSTOMER_PRODUCT_ID	NUMBER := '';
	LOOP_SERVICE_MASS_TXN_TEMP_ID	NUMBER := '';
	LOOP_CP_SERVICE_ID		NUMBER := '';

	CURSOR c1 IS
		SELECT  LINE_ID,
        	        ORDERED_QUANTITY - NVL(CANCELLED_QUANTITY, 0) ORDERED_QUANTITY,
                        CUSTOMER_PRODUCT_ID,
                        SERVICE_MASS_TXN_TEMP_ID,
                        CP_SERVICE_ID
		FROM    SO_LINES
		WHERE   SOURCE_LINE_ID = V_LINE_ID;


BEGIN
 FOR c1rec IN c1 LOOP

    LOOP_LINE_ID := c1rec.line_id;
    LOOP_REQUESTED_CANCEL_QTY := c1rec.ordered_quantity;
    LOOP_CUSTOMER_PRODUCT_ID := c1rec.customer_product_id;
    LOOP_SERVICE_MASS_TXN_TEMP_ID := c1rec.service_mass_txn_temp_id;
    LOOP_CP_SERVICE_ID := c1rec.cp_service_id;

    OE_CANSRV.CHECK_LINE_INTERFACED(LOOP_LINE_ID, CHECK_LINE_INTERFACE_RESULT);

    IF CHECK_LINE_INTERFACE_RESULT = 1 THEN
     OE_CANSRV.CHECK_ORDER_INT_RECS_EXIST(LOOP_LINE_ID, V_CONCURRENT_PROCESS_ID,
			CHECK_ORDER_INT_RECS_RESULT);
    END IF;

    IF CHECK_ORDER_INT_RECS_RESULT = 1 THEN
     OE_CANSRV.CHECK_ORDER_INT_NOT_IN_PROG(LOOP_LINE_ID, V_PRINT_ERR_MSG,
			V_CONCURRENT_PROCESS_ID, CHECK_ORDER_INT_NOT_RESULT);
    ELSE
     INSERT INTO CS_ORDERS_INTERFACE
	(      ORDER_INTERFACE_ID
	,      CREATED_BY
	,      SERVICE_ITEM_FLAG
	,      CREATION_DATE
	,      TRANSACTION_CODE
	,      LINE_ID
	,      CANCEL_QUANTITY
	,      CANCEL_CP_ID
	)
	VALUES
	(      CS_ORDERS_INTERFACE_S.NEXTVAL
	,      V_LAST_UPDATED_BY
	,       'Y'
	,       SYSDATE
	,      'CANCEL'
	,      LOOP_LINE_ID
	,      LOOP_REQUESTED_CANCEL_QTY
	,      LOOP_CUSTOMER_PRODUCT_ID
	);
    END IF;

    IF CHECK_ORDER_INT_NOT_RESULT = 1 THEN
     OE_CANSRV.MAKE_DELETE_INT_RECS(LOOP_LINE_ID,LOOP_CUSTOMER_PRODUCT_ID,
 	LOOP_CP_SERVICE_ID, V_LAST_UPDATED_BY, LOOP_SERVICE_MASS_TXN_TEMP_ID,
	MAKE_DELETE_INT_RECS_RESULT);

    DELETE FROM CS_ORDERS_INTERFACE
    WHERE  LINE_ID = LOOP_LINE_ID
    AND    TRANSACTION_CODE IN ('ORDER', 'RENEW');
    END IF;


 INSERT INTO SO_ORDER_CANCELLATIONS
       ( LINE_ID, HEADER_ID,
         CANCEL_CODE, CANCELLED_BY,
         CANCEL_DATE, LAST_UPDATED_BY,
         LAST_UPDATE_DATE, CANCEL_COMMENT,
         CANCELLED_QUANTITY, STATUS,
         CREATION_DATE, CREATED_BY,
         LAST_UPDATE_LOGIN )
 VALUES (
        LOOP_LINE_ID, V_HEADER_ID,
        V_CANCEL_CODE, V_LAST_UPDATED_BY,
        SYSDATE, V_LAST_UPDATED_BY,
        SYSDATE, V_CANCEL_COMMENT,
        DECODE(V_FULL, '1','',LOOP_REQUESTED_CANCEL_QTY),
        V_STATUS, SYSDATE, V_LAST_UPDATED_BY,
        V_LAST_UPDATE_LOGIN);

 END LOOP;

 UPDATE SO_LINES
 SET   CANCELLED_QUANTITY = ORDERED_QUANTITY,
      OPEN_FLAG = '',
      LAST_UPDATED_BY = V_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = V_LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE = SYSDATE,
      S1 = DECODE(OPEN_FLAG,'',DECODE(S1,18,8,S1),S1),
      S2 = DECODE(OPEN_FLAG,'',DECODE(S2,18,8,S2),S2),
      S3 = DECODE(OPEN_FLAG,'',DECODE(S3,18,8,S3),S3),
      S4 = DECODE(OPEN_FLAG,'',DECODE(S4,18,8,S4),S4),
      S5 = DECODE(OPEN_FLAG,'',DECODE(S5,18,8,S5),S5),
      S6 = DECODE(OPEN_FLAG,'',DECODE(S6,18,8,S6),S6),
      S7 = DECODE(OPEN_FLAG,'',DECODE(S7,18,8,S7),S7),
      S8 = DECODE(OPEN_FLAG,'',DECODE(S8,18,8,S8),S8),
      S9 = 11,
      S10 = DECODE(OPEN_FLAG,'',DECODE(S10,18,8,S10),S10),
      S11 = DECODE(OPEN_FLAG,'',DECODE(S11,18,8,S11),S11),
      S12 = DECODE(OPEN_FLAG,'',DECODE(S12,18,8,S12),S12),
      S13 = DECODE(OPEN_FLAG,'',DECODE(S13,18,8,S13),S13),
      S14 = DECODE(OPEN_FLAG,'',DECODE(S14,18,8,S14),S14),
      S15 = DECODE(OPEN_FLAG,'',DECODE(S15,18,8,S15),S15),
      S16 = DECODE(OPEN_FLAG,'',DECODE(S16,18,8,S16),S16),
      S17 = DECODE(OPEN_FLAG,'',DECODE(S17,18,8,S17),S17),
      S18 = DECODE(OPEN_FLAG,'',DECODE(S18,18,8,S18),S18),
      S19 = DECODE(OPEN_FLAG,'',DECODE(S19,18,8,S19),S19),
      S20 = DECODE(OPEN_FLAG,'',DECODE(S20,18,8,S20),S20),
      S21 = DECODE(OPEN_FLAG,'',DECODE(S21,18,8,S21),S21),
      S22 = DECODE(OPEN_FLAG,'',DECODE(S22,18,8,S22),S22),
      S23 = DECODE(OPEN_FLAG,'',DECODE(S23,18,8,S23),S23),
      S24 = DECODE(OPEN_FLAG,'',DECODE(S24,18,8,S24),S24),
      S25 = DECODE(OPEN_FLAG,'',DECODE(S25,18,8,S25),S25),
      S26 = DECODE(OPEN_FLAG,'',DECODE(S26,18,8,S26),S26),
      S27 = DECODE(OPEN_FLAG,'',DECODE(S27,18,8,S27),S27),
      S28 = DECODE(OPEN_FLAG,'',DECODE(S28,18,8,S28),S28),
      S29 = DECODE(OPEN_FLAG,'',DECODE(S29,18,8,S29),S29),
      S30 = DECODE(OPEN_FLAG,'',DECODE(S30,18,8,S30),S30)
 WHERE   SOURCE_LINE_ID = V_LINE_ID;

 UPDATE SO_LINES
 SET   S1_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S1,18,TO_DATE(NULL),S1_DATE),S1_DATE),
      S2_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S2,18,TO_DATE(NULL),S2_DATE),S2_DATE),
      S3_DATE = DECODE(S3,18,TO_DATE(NULL),S3_DATE),
      S4_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S4,18,TO_DATE(NULL),S4_DATE),S4_DATE),
      S5_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S5,18,TO_DATE(NULL),S5_DATE),S5_DATE),
      S6_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S6,18,TO_DATE(NULL),S6_DATE),S6_DATE),
      S7_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S7,18,TO_DATE(NULL),S7_DATE),S7_DATE),
      S8_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S8,18,TO_DATE(NULL),S8_DATE),S8_DATE),
      S9_DATE = SYSDATE,
      S10_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S10,18,TO_DATE(NULL),S10_DATE),S10_DATE),
      S11_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S11,18,TO_DATE(NULL),S11_DATE),S11_DATE),
      S12_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S12,18,TO_DATE(NULL),S12_DATE),S12_DATE),
      S13_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S13,18,TO_DATE(NULL),S13_DATE),S13_DATE),
      S14_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S14,18,TO_DATE(NULL),S14_DATE),S14_DATE),
      S15_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S15,18,TO_DATE(NULL),S15_DATE),S15_DATE),
      S16_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S16,18,TO_DATE(NULL),S16_DATE),S16_DATE),
      S17_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S17,18,TO_DATE(NULL),S17_DATE),S17_DATE),
      S18_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S18,18,TO_DATE(NULL),S18_DATE),S18_DATE),
      S19_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S19,18,TO_DATE(NULL),S19_DATE),S19_DATE),
      S20_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S20,18,TO_DATE(NULL),S20_DATE),S20_DATE),
      S21_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S21,18,TO_DATE(NULL),S21_DATE),S21_DATE),
      S22_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S22,18,TO_DATE(NULL),S22_DATE),S22_DATE),
      S23_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S23,18,TO_DATE(NULL),S23_DATE),S23_DATE),
      S24_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S24,18,TO_DATE(NULL),S24_DATE),S24_DATE),
      S25_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S25,18,TO_DATE(NULL),S25_DATE),S25_DATE),
      S26_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S26,18,TO_DATE(NULL),S26_DATE),S26_DATE),
      S27_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S27,18,TO_DATE(NULL),S27_DATE),S27_DATE),
      S28_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S28,18,TO_DATE(NULL),S28_DATE),S28_DATE),
      S29_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S29,18,TO_DATE(NULL),S29_DATE),S29_DATE),
      S30_DATE=DECODE(OPEN_FLAG,'' ,
        DECODE(S30,18,TO_DATE(NULL),S30_DATE),S30_DATE)
 WHERE   SOURCE_LINE_ID = V_LINE_ID;


 V_RESULT := 1;

END CANCEL_SERVICE_CHILDREN;


------------------------------------------------------------------------
-- procedure  CANCEL_LINE
------------------------------------------------------------------------
procedure CANCEL_LINE(
   V_LINE_ID			  IN NUMBER
,  V_REQUESTED_CANCEL_QTY	  IN NUMBER
,  V_ORDERED_QUANTITY		  IN NUMBER
,  V_RECEIVED_QUANTITY		  IN NUMBER
,  V_S29			  IN NUMBER
,  V_SOURCE_CODE		  IN VARCHAR2
,  V_LINE_TYPE_CODE		  IN VARCHAR2
,  V_HEADER_ID			  IN  NUMBER
,  V_CANCEL_CODE		  IN VARCHAR2
,  V_CANCEL_COMMENT               IN LONG
,  V_LAST_UPDATED_BY		  IN NUMBER
,  V_LAST_UPDATE_LOGIN            IN NUMBER
,  V_FULL		          IN NUMBER
,  V_STATUS                       IN VARCHAR2
,  V_RESULT                       OUT NUMBER
			 )
IS
	V_CANCELLED_QUANTITY  NUMBER;
	DUMMY		      NUMBER := '';
	DUMMY2		      NUMBER := '';
        l_org_id              NUMBER := NULL;

BEGIN

        l_org_id := FND_PROFILE.VALUE ('SO_ORGANIZATION_ID');

 SELECT NVL(CANCELLED_QUANTITY,0)
 INTO   V_CANCELLED_QUANTITY
 FROM   SO_LINES
 WHERE  LINE_ID = V_LINE_ID;

 V_CANCELLED_QUANTITY := V_CANCELLED_QUANTITY + V_REQUESTED_CANCEL_QTY;

 IF V_LINE_TYPE_CODE = 'RETURN' THEN
  IF ((V_S29 = 14) OR (V_S29 = 16) OR (V_S29 = 17)) THEN

   UPDATE MTL_SO_RMA_INTERFACE MSRI
   SET    MSRI.QUANTITY = (MSRI.QUANTITY
        / (V_ORDERED_QUANTITY - (V_CANCELLED_QUANTITY
                                        - V_REQUESTED_CANCEL_QTY))
        * (V_ORDERED_QUANTITY - V_CANCELLED_QUANTITY))
   WHERE  MSRI.RMA_LINE_ID = V_LINE_ID
   AND    MSRI.SOURCE_CODE = V_SOURCE_CODE
   AND    MSRI.IN_USE_FLAG IS NULL;

   SELECT  COUNT(*)
   INTO    DUMMY
   FROM    SO_LINES
   WHERE   LINE_ID = V_LINE_ID
   AND     (ORDERED_QUANTITY - V_CANCELLED_QUANTITY - V_RECEIVED_QUANTITY) > 0;

   IF DUMMY < 1 THEN

    UPDATE MTL_SO_RMA_INTERFACE MSRI
    SET    CLOSED_FLAG = 'Y'
    WHERE  MSRI.RMA_LINE_ID = V_LINE_ID
    AND    MSRI.SOURCE_CODE = V_SOURCE_CODE;
   END IF;
  END IF;
 END IF;

 SELECT  COUNT(*)
 INTO 	 DUMMY2
 FROM    SO_LINES
 WHERE   LINE_ID = V_LINE_ID
 AND     (ORDERED_QUANTITY - V_CANCELLED_QUANTITY) > 0;

 IF DUMMY2 >= 1 THEN
  UPDATE SO_LINES
  SET    CANCELLED_QUANTITY = V_CANCELLED_QUANTITY,
	 S9 = 5,
         S9_DATE = SYSDATE
  WHERE  LINE_ID = V_LINE_ID;

 ELSE
  UPDATE SO_LINES
  SET    OPEN_FLAG = '',
	 CANCELLED_QUANTITY = V_CANCELLED_QUANTITY,
         S1 = DECODE(S1,18,8,S1),
	 S1_DATE = DECODE(S1,18, '', S1_DATE),
         S2 = DECODE(S2,18,8,S2),
	 S2_DATE = DECODE(S2,18, '', S2_DATE),
         S3 = DECODE(S3,18,8,S3),
	 S3_DATE = DECODE(S3,18, '', S3_DATE),
         S4 = DECODE(S4,18,8,S4),
	 S4_DATE = DECODE(S4,18, '', S4_DATE),
         S5 = DECODE(S5,18,8,S5),
	 S5_DATE = DECODE(S5,18, '', S5_DATE),
         S6 = DECODE(S6,18,8,S6),
	 S6_DATE = DECODE(S6,18, '', S6_DATE),
         S7 = DECODE(S7,18,8,S7),
	 S7_DATE = DECODE(S7,18, '', S7_DATE),
         S8 = DECODE(S8,18,8,S8),
	 S8_DATE = DECODE(S8,18, '', S8_DATE),
         S9 = 11,
	 S9_DATE = SYSDATE,
         S10 = DECODE(S10,18,8,S10),
	 S10_DATE = DECODE(S10,18, '', S10_DATE),
         S11 = DECODE(S11,18,8,S11),
	 S11_DATE = DECODE(S11,18, '', S11_DATE),
         S12 = DECODE(S12,18,8,S12),
	 S12_DATE = DECODE(S12,18, '', S12_DATE),
         S13 = DECODE(S13,18,8,S13),
	 S13_DATE = DECODE(S13,18, '', S13_DATE),
         S14 = DECODE(S14,18,8,S14),
	 S14_DATE = DECODE(S14,18, '', S14_DATE),
         S15 = DECODE(S15,18,8,S15),
	 S15_DATE = DECODE(S15,18, '', S15_DATE),
         S16 = DECODE(S16,18,8,S16),
	 S16_DATE = DECODE(S16,18, '', S16_DATE),
         S17 = DECODE(S17,18,8,S17),
	 S17_DATE = DECODE(S17,18, '', S17_DATE),
         S18 = DECODE(S18,18,8,S18),
	 S18_DATE = DECODE(S18,18, '', S18_DATE),
         S19 = DECODE(S19,18,8,S19),
	 S19_DATE = DECODE(S19,18, '', S19_DATE),
         S20 = DECODE(S20,18,8,S20),
	 S20_DATE = DECODE(S20,18, '', S20_DATE),
         S21 = DECODE(S21,18,8,S21),
	 S21_DATE = DECODE(S21,18, '', S21_DATE),
         S22 = DECODE(S22,18,8,S22),
	 S22_DATE = DECODE(S22,18, '', S22_DATE),
         S23= DECODE(S23,18,8,S23),
	 S23_DATE = DECODE(S23,18, '', S23_DATE),
         S24 = DECODE(S24,18,8,S24),
	 S24_DATE = DECODE(S24,18, '', S24_DATE),
         S25 = DECODE(S25,18,8,S25),
	 S25_DATE = DECODE(S25,18, '', S25_DATE),
         S26 = DECODE(S26,18,8,S26),
	 S26_DATE = DECODE(S26,18, '', S26_DATE),
         S27 = DECODE(S27,18,8,S27),
	 S27_DATE = DECODE(S27,18, '', S27_DATE),
         S28 = DECODE(S28,18,8,S28),
	 S28_DATE = DECODE(S28,18, '', S28_DATE),
         S29 = DECODE(S29,18,8,S29),
	 S29_DATE = DECODE(S29,18, '', S29_DATE),
         S30 = DECODE(S30,18,8,S30),
	 S30_DATE = DECODE(S30,18, '', S30_DATE)
  WHERE   LINE_ID = V_LINE_ID;

 END IF;

 INSERT INTO SO_ORDER_CANCELLATIONS
       ( LINE_ID, HEADER_ID,
         CANCEL_CODE, CANCELLED_BY,
         CANCEL_DATE, LAST_UPDATED_BY,
         LAST_UPDATE_DATE, CANCEL_COMMENT,
         CANCELLED_QUANTITY, STATUS,
         CREATION_DATE, CREATED_BY,
         LAST_UPDATE_LOGIN )
 VALUES (
        V_LINE_ID, V_HEADER_ID,
        V_CANCEL_CODE, V_LAST_UPDATED_BY,
        SYSDATE, V_LAST_UPDATED_BY,
        SYSDATE, V_CANCEL_COMMENT,
        DECODE(V_FULL, '1','',V_REQUESTED_CANCEL_QTY),
        V_STATUS, SYSDATE, V_LAST_UPDATED_BY,
        V_LAST_UPDATE_LOGIN);

/*
** Fix for Bug # 654734
** Update quantity_to_invoice for non-shippable items on line Cancellation.
*/
UPDATE SO_LINES
SET    QUANTITY_TO_INVOICE =
       DECODE(NVL(QUANTITY_TO_INVOICE,0),
              0, QUANTITY_TO_INVOICE,
              DECODE(NVL(SHIPPED_QUANTITY,0),
                     0,(ORDERED_QUANTITY - NVL(CANCELLED_QUANTITY,0)),
                     SHIPPED_QUANTITY))
WHERE (LINE_ID        = V_LINE_ID
 OR    PARENT_LINE_ID = V_LINE_ID)
AND   (S4 + 0 IN (5, 7, 22, 8)
 OR    S29 + 0 IN (14, 16, 8))
AND   EXISTS
     (SELECT 'NON SHIPPABLE ITEM'
      FROM   MTL_SYSTEM_ITEMS MSI
      WHERE  MSI.ORGANIZATION_ID     = l_org_id
      AND    MSI.INVENTORY_ITEM_ID   = SO_LINES.INVENTORY_ITEM_ID
      AND    MSI.SHIPPABLE_ITEM_FLAG = 'N');

 V_RESULT := 1;

END CANCEL_LINE;

------------------------------------------------------------------------
-- procedure  CANCEL_SERVICE
------------------------------------------------------------------------
procedure CANCEL_SERVICE(
   V_LINE_ID			  IN NUMBER
,  V_REQUESTED_CANCEL_QTY	  IN NUMBER
,  V_ORDERED_QUANTITY             IN NUMBER
,  V_RECEIVED_QUANTITY            IN NUMBER
,  V_S29                          IN NUMBER
,  V_HEADER_ID                    IN NUMBER
,  V_CANCEL_CODE                  IN VARCHAR2
,  V_CANCEL_COMMENT               IN LONG
,  V_LAST_UPDATE_LOGIN            IN NUMBER
,  V_FULL                         IN NUMBER
,  V_STATUS                       IN VARCHAR2
,  V_CUSTOMER_PRODUCT_ID          IN NUMBER
,  V_CP_SERVICE_ID                IN NUMBER
,  V_LAST_UPDATED_BY              IN NUMBER
,  V_SERVICE_MASS_TXN_TEMP_ID     IN NUMBER
,  V_SOURCE_CODE		  IN VARCHAR2
,  V_LINE_TYPE_CODE		  IN VARCHAR2
,  V_PRINT_ERR_MSG                IN NUMBER
,  V_CONCURRENT_PROCESS_ID        IN OUT NUMBER
,  V_RESULT                       OUT NUMBER
			 )
IS

	CHK_LINE_INT_RESULT		NUMBER :='';
	CANCEL_SRV_CHILD_RESULT		NUMBER :='';
        CHK_ORD_INT_RESULT		NUMBER :='';
        CHK_ORD_INT_NOT_RESULT 		NUMBER :='';
	MAKE_DELETE_INT_RESULT		NUMBER :='';
	CANCEL_LINE_RESULT		NUMBER :='';

BEGIN

 OE_CANSRV.CHECK_LINE_INTERFACED(	V_LINE_ID,
					CHK_LINE_INT_RESULT
					);

 IF CHK_LINE_INT_RESULT = 0 THEN
  GOTO cancel_line;
 END IF;

 OE_CANSRV.CHECK_ORDER_INT_RECS_EXIST(	V_LINE_ID,
					V_CONCURRENT_PROCESS_ID,
					CHK_ORD_INT_RESULT
					);
 IF CHK_ORD_INT_RESULT = 0 THEN

  INSERT INTO CS_ORDERS_INTERFACE
  (      ORDER_INTERFACE_ID
  ,      CREATED_BY
  ,      SERVICE_ITEM_FLAG
  ,      CREATION_DATE
  ,      TRANSACTION_CODE
  ,      LINE_ID
  ,      CANCEL_QUANTITY
  ,      CANCEL_CP_ID
  )
  VALUES
  (      CS_ORDERS_INTERFACE_S.NEXTVAL
  ,      V_LAST_UPDATED_BY
  ,       'Y'
  ,       SYSDATE
  ,      'CANCEL'
  ,      V_LINE_ID
  ,      V_REQUESTED_CANCEL_QTY
  ,      V_CUSTOMER_PRODUCT_ID);

  GOTO cancel_line;
 END IF;


 OE_CANSRV.CHECK_ORDER_INT_NOT_IN_PROG(	V_LINE_ID,
					V_PRINT_ERR_MSG,
					V_CONCURRENT_PROCESS_ID,
					CHK_ORD_INT_NOT_RESULT
					);
 IF CHK_ORD_INT_NOT_RESULT = 1 THEN
  OE_CANSRV.MAKE_DELETE_INT_RECS(	V_LINE_ID,
					V_CUSTOMER_PRODUCT_ID,
					V_CP_SERVICE_ID,
					V_LAST_UPDATED_BY,
					V_SERVICE_MASS_TXN_TEMP_ID,
					MAKE_DELETE_INT_RESULT
					);

  DELETE FROM CS_ORDERS_INTERFACE
  WHERE  LINE_ID = V_LINE_ID
  AND    TRANSACTION_CODE IN ('ORDER', 'RENEW');

  GOTO cancel_line;
 END IF;

 <<cancel_line>>
 OE_CANSRV.CANCEL_SERVICE_CHILDREN(	V_LINE_ID,
					V_HEADER_ID,
					V_CANCEL_CODE,
					V_CANCEL_COMMENT,
					V_FULL,
					V_STATUS,
					V_REQUESTED_CANCEL_QTY,
					V_CUSTOMER_PRODUCT_ID,
					V_CP_SERVICE_ID,
					V_LAST_UPDATED_BY,
					V_LAST_UPDATE_LOGIN,
					V_SERVICE_MASS_TXN_TEMP_ID,
					V_PRINT_ERR_MSG,
					V_CONCURRENT_PROCESS_ID,
					CANCEL_SRV_CHILD_RESULT
					);

 OE_CANSRV.CANCEL_LINE(			V_LINE_ID,
					V_REQUESTED_CANCEL_QTY,
					V_ORDERED_QUANTITY,
					V_RECEIVED_QUANTITY,
					V_S29,
					V_SOURCE_CODE,
					V_LINE_TYPE_CODE,
					V_HEADER_ID,
					V_CANCEL_CODE,
					V_CANCEL_COMMENT,
					V_LAST_UPDATED_BY,
					V_LAST_UPDATE_LOGIN,
					V_FULL,
					V_STATUS,
					CANCEL_LINE_RESULT
					);

 IF ((CANCEL_SRV_CHILD_RESULT = 1) AND (CANCEL_LINE_RESULT = 1)) THEN
  V_RESULT := 1;
 ELSE
  V_RESULT := 0;
 END IF;

END CANCEL_SERVICE;


------------------------------------------------------------------------
-- procedure  HISTORY
------------------------------------------------------------------------

procedure HISTORY(
   V_LINE_ID                      IN NUMBER
,  V_ITEM                         OUT VARCHAR2
,  V_BASE_LINE_NUMBER             OUT NUMBER
,  V_SHIPMENT_SCHEDULE_NUMBER     OUT NUMBER
,  V_OPTION_LINE_NUMBER           OUT NUMBER
                          )

IS

BEGIN
	SELECT	ITEM,
		BASE_LINE_NUMBER,
		SHIPMENT_SCHEDULE_NUMBER,
		OPTION_LINE_NUMBER
	INTO	V_ITEM,
		V_BASE_LINE_NUMBER,
		V_SHIPMENT_SCHEDULE_NUMBER,
		V_OPTION_LINE_NUMBER
	FROM	SO_LINES_CANCEL_V
	WHERE 	LINE_ID	= V_LINE_ID;


END HISTORY;

------------------------------------------------------------------------
-- procedure  HOLDS
--
-- Loop over all holds in the order, for each, check for full
-- cancellation of that line.
-- If it's completely cancelled, release the hold found.
--
------------------------------------------------------------------------

procedure HOLDS(
   V_HEADER_ID                    IN NUMBER
,  V_LOGIN_ID		          IN NUMBER
,  V_USER_ID     	          IN NUMBER
                          )
IS

	V_HOLD_RELEASE_ID		NUMBER := '';

	LOOP_HOLD_LINE_ID		NUMBER := '';
        LOOP_HOLD_SOURCE_ID		NUMBER := '';
        LOOP_HOLD_ENTITY_ID		NUMBER := '';
        LOOP_HOLD_ENTITY_CODE		VARCHAR2(50);
        LOOP_ORDER_HOLD_ID		NUMBER := '';


	CURSOR c1 IS
		SELECT	OESOH.LINE_ID LINE_ID,
        		OESRC.HOLD_SOURCE_ID HOLD_SOURCE_ID,
        		OESRC.HOLD_ENTITY_ID HOLD_ENTITY_ID,
        		OESRC.HOLD_ENTITY_CODE HOLD_ENTITY_CODE,
        		OESOH.ORDER_HOLD_ID ORDER_HOLD_ID
		FROM    SO_HOLD_SOURCES OESRC,
        		SO_ORDER_HOLDS OESOH
		WHERE   OESRC.HOLD_SOURCE_ID = OESOH.HOLD_SOURCE_ID
		AND     OESRC.RELEASED_FLAG = 'N'
		AND     OESOH.HOLD_RELEASE_ID IS NULL
		AND     OESOH.LINE_ID IS NOT NULL
		AND     OESOH.HEADER_ID = V_HEADER_ID
		AND     EXISTS (
        		SELECT  'NONE_LEFT'
        		FROM    SO_LINES
        		WHERE   LINE_ID = OESOH.LINE_ID
        		AND     ORDERED_QUANTITY = NVL(CANCELLED_QUANTITY,0) +
                 		GREATEST (NVL(SHIPPED_QUANTITY,0), NVL(INVOICED_QUANTITY,0)));


BEGIN

	FOR c1rec IN c1 LOOP

		LOOP_HOLD_LINE_ID := c1rec.line_id;
		LOOP_HOLD_SOURCE_ID := c1rec.hold_source_id;
		LOOP_HOLD_ENTITY_ID := c1rec.hold_entity_id;
		LOOP_HOLD_ENTITY_CODE := c1rec.hold_entity_code;
		LOOP_ORDER_HOLD_ID := c1rec.order_hold_id;

		SELECT SO_HOLD_RELEASES_S.NEXTVAL
		INTO   V_HOLD_RELEASE_ID
		FROM   DUAL;

		INSERT INTO SO_HOLD_RELEASES
		      (HOLD_RELEASE_ID,
		       HOLD_SOURCE_ID,
		       LAST_UPDATE_DATE,
		       LAST_UPDATED_BY,
		       LAST_UPDATE_LOGIN,
		       CREATION_DATE,
		       CREATED_BY,
		       HOLD_ENTITY_ID,
		       HOLD_ENTITY_CODE,
		       RELEASE_REASON_CODE)
		VALUES (V_HOLD_RELEASE_ID,
		        LOOP_HOLD_SOURCE_ID,
		        SYSDATE,
		        V_USER_ID,
		        V_LOGIN_ID,
		        SYSDATE,
		        V_USER_ID,
		        LOOP_HOLD_ENTITY_ID,
		        LOOP_HOLD_ENTITY_CODE,
 		        'CANCELLATION');

		UPDATE SO_ORDER_HOLDS
		SET    HOLD_RELEASE_ID = V_HOLD_RELEASE_ID,
		       LAST_UPDATE_DATE = SYSDATE,
		       LAST_UPDATED_BY = V_USER_ID,
		       LAST_UPDATE_LOGIN = V_LOGIN_ID
		WHERE  HOLD_RELEASE_ID IS NULL
		AND    ORDER_HOLD_ID = LOOP_ORDER_HOLD_ID;

	END LOOP;

-- Release automatically applied source holds(with hold_id < 1000) when
-- all the underline order holds have been released.

	UPDATE 	SO_HOLD_SOURCES SHS
	SET	RELEASED_FLAG = 'Y',
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = V_USER_ID,
		LAST_UPDATE_LOGIN = V_LOGIN_ID
	WHERE	HOLD_ENTITY_CODE = 'O'
	AND	RELEASED_FLAG = 'N'
	AND	HOLD_ENTITY_ID = V_HEADER_ID
	AND	HOLD_ID < 1000
	AND	NOT EXISTS
	       (SELECT 'EXISTS'
		FROM   SO_ORDER_HOLDS SOH
		WHERE  HOLD_RELEASE_ID IS NULL
		AND    SOH.HOLD_SOURCE_ID = SHS.HOLD_SOURCE_ID);
END HOLDS;

------------------------------------------------------------------------
-- procedure  ALL_HOLDS
--
-- Loop over all holds in the order(both Order Level and Line Level)
-- Release the holds found.
--
------------------------------------------------------------------------

procedure ALL_HOLDS(
   V_HEADER_ID                    IN NUMBER
,  V_LOGIN_ID		          IN NUMBER
,  V_USER_ID     	          IN NUMBER
                          )
IS

	V_HOLD_RELEASE_ID		NUMBER := '';

	LOOP_HOLD_LINE_ID		NUMBER := '';
        LOOP_HOLD_SOURCE_ID		NUMBER := '';
        LOOP_HOLD_ENTITY_ID		NUMBER := '';
        LOOP_HOLD_ENTITY_CODE		VARCHAR2(50);
        LOOP_ORDER_HOLD_ID		NUMBER := '';


	CURSOR c1 IS
		SELECT	OESOH.LINE_ID LINE_ID,
        		OESRC.HOLD_SOURCE_ID HOLD_SOURCE_ID,
        		OESRC.HOLD_ENTITY_ID HOLD_ENTITY_ID,
        		OESRC.HOLD_ENTITY_CODE HOLD_ENTITY_CODE,
        		OESOH.ORDER_HOLD_ID ORDER_HOLD_ID
		FROM    SO_HOLD_SOURCES OESRC,
        		SO_ORDER_HOLDS OESOH
		WHERE   OESRC.HOLD_SOURCE_ID = OESOH.HOLD_SOURCE_ID
		AND     OESRC.RELEASED_FLAG  = 'N'
		AND     OESOH.HOLD_RELEASE_ID IS NULL
		AND     OESOH.HEADER_ID      = V_HEADER_ID;

BEGIN

	FOR c1rec IN c1 LOOP

		LOOP_HOLD_LINE_ID     := c1rec.line_id;
		LOOP_HOLD_SOURCE_ID   := c1rec.hold_source_id;
		LOOP_HOLD_ENTITY_ID   := c1rec.hold_entity_id;
		LOOP_HOLD_ENTITY_CODE := c1rec.hold_entity_code;
		LOOP_ORDER_HOLD_ID    := c1rec.order_hold_id;

		SELECT SO_HOLD_RELEASES_S.NEXTVAL
		INTO   V_HOLD_RELEASE_ID
		FROM   DUAL;

		INSERT INTO SO_HOLD_RELEASES
		      (HOLD_RELEASE_ID,
		       HOLD_SOURCE_ID,
		       LAST_UPDATE_DATE,
		       LAST_UPDATED_BY,
		       LAST_UPDATE_LOGIN,
		       CREATION_DATE,
		       CREATED_BY,
		       HOLD_ENTITY_ID,
		       HOLD_ENTITY_CODE,
		       RELEASE_REASON_CODE)
		VALUES (V_HOLD_RELEASE_ID,
		        LOOP_HOLD_SOURCE_ID,
		        SYSDATE,
		        V_USER_ID,
		        V_LOGIN_ID,
		        SYSDATE,
		        V_USER_ID,
		        LOOP_HOLD_ENTITY_ID,
		        LOOP_HOLD_ENTITY_CODE,
 		        'CANCELLATION');

		UPDATE SO_ORDER_HOLDS
		SET    HOLD_RELEASE_ID  = V_HOLD_RELEASE_ID,
		       LAST_UPDATE_DATE = SYSDATE,
		       LAST_UPDATED_BY  = V_USER_ID,
		       LAST_UPDATE_LOGIN= V_LOGIN_ID
		WHERE  HOLD_RELEASE_ID IS NULL
		AND    ORDER_HOLD_ID = LOOP_ORDER_HOLD_ID;

	END LOOP;

-- Release automatically applied source holds(with hold_id < 1000) when
-- all the underline order holds have been released.

	UPDATE 	SO_HOLD_SOURCES SHS
	SET	RELEASED_FLAG    = 'Y',
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY  = V_USER_ID,
		LAST_UPDATE_LOGIN= V_LOGIN_ID
	WHERE	HOLD_ENTITY_CODE = 'O'
	AND	RELEASED_FLAG = 'N'
	AND	HOLD_ENTITY_ID = V_HEADER_ID
	AND	HOLD_ID < 1000
	AND	NOT EXISTS
	       (SELECT 'EXISTS'
		FROM   SO_ORDER_HOLDS SOH
		WHERE  HOLD_RELEASE_ID IS NULL
		AND    SOH.HOLD_SOURCE_ID = SHS.HOLD_SOURCE_ID);
END ALL_HOLDS;

END OE_CANSRV;

/
