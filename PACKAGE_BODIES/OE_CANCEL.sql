--------------------------------------------------------
--  DDL for Package Body OE_CANCEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CANCEL" AS
/* $Header: OECANCLB.pls 115.7 99/08/24 11:52:30 porting shi $ */



------------------------------------------------------------------------
-- procedure CHECK_ORDER_CANCELLABLE
--
--	If the order being checked is an RMA check to see if there
--	are are line that have been Partially Accepted (S29=16) or
--	Completely Accepted (S29=17).  If this is the fact then the
--	order is not cancellable.  Since the order lines are not
--      updated until the RMA interface concurrent program is run,
--	there is a possiblity that order lines have been received by
--	Inventory and the Order Line status is Interfaced (S29=14).
--	In this case we need to make sure that no RMA line qtys have
--	been received by INV. If qtys have been received then the
--	Order is not cancellable.
--	If the order being checked for cancellation is not an RMA,
--	there is a need to check and see if this order contains
--	ATO lines whose details are still linked.  In this case
--	the order is not cancellable.
--
-- RETURNS:
--	1 -> if order is cancellable
--	0 -> if order is not cancellable
------------------------------------------------------------------------

procedure  CHECK_ORDER_CANCELLABLE(
   V_HEADER_ID                       IN NUMBER
,  V_ORDER_CATEGORY                  IN VARCHAR2
,  V_PRINT_ERR_MSG                   IN NUMBER
,  V_RESULT			     OUT NUMBER
                          )
IS
   DUMMY		NUMBER := 0;
   RECEIVED_QUANTITY	NUMBER := 0;
   x                    BOOLEAN;
BEGIN


   IF (V_ORDER_CATEGORY = 'RMA') THEN

	SELECT COUNT(*)
	INTO DUMMY
	FROM SO_LINES
	WHERE HEADER_ID = V_HEADER_ID
	AND S29 IN (16, 17);



	IF (DUMMY >= 1) THEN
		V_RESULT := 0;
		x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_RMA_INTERFACED');
		-- "You cannot cancel this Return at this level."
	ELSE
		SELECT	NVL(SUM(NVL(MTLSRR.RECEIVED_QUANTITY,0)),0)
		INTO	RECEIVED_QUANTITY
		FROM	MTL_SO_RMA_RECEIPTS MTLSRR,
		MTL_SO_RMA_INTERFACE MTLSRI
		WHERE  MTLSRR.RMA_INTERFACE_ID = MTLSRI.RMA_INTERFACE_ID
		AND    MTLSRI.RMA_LINE_ID IN
			(SELECT LINE_ID
			FROM   SO_LINES
			WHERE  HEADER_ID = V_HEADER_ID
			AND    S29 = 14);

		IF (RECEIVED_QUANTITY > 0) THEN
			V_RESULT := 0;
			x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_RMA_INTERFACED');
	                -- "You cannot cancel this Return at this level."
 		ELSE
			V_RESULT := 1;
	        END IF;
	END IF;
    ELSE
	SELECT	COUNT(*)
	INTO 	DUMMY
	FROM 	SO_LINE_DETAILS SLD,
		SO_LINES SOL
	WHERE	SOL.HEADER_ID = V_HEADER_ID
	AND	SLD.LINE_ID = SOL.LINE_ID
	AND	SLD.SCHEDULE_STATUS_CODE = 'SUPPLY_RESERVED'
	AND	SLD.WIP_COMPLETED_QUANTITY < SLD.QUANTITY;

	IF (DUMMY >= 1) THEN
		V_RESULT := 0;
		x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_ATO_DETS_LINKED');
		-- This order contains ATO lines whose details are
		-- linked. See explanation
	ELSE
		V_RESULT := 1;
	END IF;
     END IF;

END CHECK_ORDER_CANCELLABLE; -- CHECK_ORDER_CANCELLABLE

------------------------------------------------------------------------
-- procedure UPDATE_HEADER_INFO

--	Update the SO_HEADERS table to reflect that the Order has been
--	cancelled. This is done by setting the S4 (Cancel Order) column
--	to 11 (Complete). Then the lines in the SO_LINES table are also
--	updated to reflect the order cancellation. The open_flag is set
--	to null, the cancelled_quantity is set to ordered_quantity
--	and S9 (Cancel Line) is set to 11 (Complete).
--      If the order is also an RMA any records in the interface that
--	have not been received by INV need to be modified so they
--	don't get picked by the next run of the RMA inferface program.
--	For those record found in the interface set the quantity to 0
--	and set the closed_flag to 'Y'.
--	Need to insert a record into so_order_cancellations indicating
--	the order level cancellation. We also need to detele the
--	corresponding so_line_details for the order just cancelled,
--	excluding any line details that have been released. Also
--	need to cleanup the so_line_service_details if there were any
--	lines that were of a service nature.
--
-- RETURNS:
--      1 -> order has been cancelled
------------------------------------------------------------------------

procedure UPDATE_HEADER_INFO(
	V_HEADER_ID		IN NUMBER
,	V_ORDER_CATEGORY	IN VARCHAR2
,	V_CANCEL_COMMENT	IN LONG
,	V_CANCEL_CODE		IN VARCHAR2
,	V_LAST_UPDATED_BY	IN NUMBER
,	V_LAST_UPDATE_LOGIN	IN NUMBER
,	V_SOURCE_CODE		IN VARCHAR2
,	V_PRINT_ERR_MSG		IN NUMBER
,	V_RESULT		OUT NUMBER)

is

	x               BOOLEAN;
        v_current_user  NUMBER;

BEGIN

        v_current_user := to_number(FND_PROFILE.VALUE('USER_ID'));

 --
 -- Set the S values for the headers, specifically set S4 (Cancel Order) to
 -- 11 (Complete)
 --
 UPDATE	SO_HEADERS
 SET 	S1 = DECODE(S1,18,'',S1),
      	S1_DATE = DECODE(S1,18,'',S1_DATE),
      	S2 = DECODE(S2,18,'',S2),
      	S2_DATE = DECODE(S2,18,'',S2_DATE),
      	S3 = DECODE(S3,18,'',S3),
      	S3_DATE = DECODE(S3,18,'',S3_DATE),
      	S4 = 11,
      	S4_DATE = SYSDATE,
      	S5 = DECODE(S5,18,'',S5),
      	S5_DATE = DECODE(S5,18,'',S5_DATE),
      	S6 = DECODE(S6,18,'',S6),
      	S6_DATE = DECODE(S6,18,'',S6_DATE),
      	S7 = DECODE(S7,18,'',S7),
      	S7_DATE = DECODE(S7,18,'',S7_DATE),
      	S8 = DECODE(S8,18,'',S8),
      	S8_DATE = DECODE(S8,18,'',S8_DATE),
      	S9 = DECODE(S9,18,'',S9),
      	S9_DATE = DECODE(S9,18,'',S9_DATE),
      	S10 = DECODE(S10,18,'',S10),
      	S10_DATE = DECODE(S10,18,'',S10_DATE),
      	S11 = DECODE(S11,18,'',S11),
      	S11_DATE = DECODE(S11,18,'',S11_DATE),
      	S12 = DECODE(S12,18,'',S12),
      	S12_DATE = DECODE(S12,18,'',S12_DATE),
      	S13 = DECODE(S13,18,'',S13),
      	S13_DATE = DECODE(S13,18,'',S13_DATE),
      	S14 = DECODE(S14,18,'',S14),
      	S14_DATE = DECODE(S14,18,'',S14_DATE),
      	S15 = DECODE(S15,18,'',S15),
      	S15_DATE = DECODE(S15,18,'',S15_DATE),
      	S16 = DECODE(S16,18,'',S16),
      	S16_DATE = DECODE(S16,18,'',S16_DATE),
      	S17 = DECODE(S17,18,'',S17),
      	S17_DATE = DECODE(S17,18,'',S17_DATE),
      	S18 = DECODE(S18,18,'',S18),
      	S18_DATE = DECODE(S18,18,'',S18_DATE),
      	S19 = DECODE(S19,18,'',S19),
      	S19_DATE = DECODE(S19,18,'',S19_DATE),
      	S20 = DECODE(S20,18,'',S20),
      	S20_DATE = DECODE(S20,18,'',S20_DATE),
      	S21 = DECODE(S21,18,'',S21),
      	S21_DATE = DECODE(S21,18,'',S21_DATE),
      	S22 = DECODE(S22,18,'',S22),
      	S22_DATE = DECODE(S22,18,'',S22_DATE),
      	S23 = DECODE(S23,18,'',S23),
      	S23_DATE = DECODE(S23,18,'',S23_DATE),
      	S24 = DECODE(S24,18,'',S24),
      	S24_DATE = DECODE(S24,18,'',S24_DATE),
      	S25 = DECODE(S25,18,'',S25),
      	S25_DATE = DECODE(S25,18,'',S25_DATE),
      	S26 = DECODE(S26,18,'',S26),
      	S26_DATE = DECODE(S26,18,'',S26_DATE),
      	S27 = DECODE(S27,18,'',S27),
      	S27_DATE = DECODE(S27,18,'',S27_DATE),
      	S28 = DECODE(S28,18,'',S28),
      	S28_DATE = DECODE(S28,18,'',S28_DATE),
      	S29 = DECODE(S29,18,'',S29),
      	S29_DATE = DECODE(S29,18,'',S29_DATE),
      	S30 = DECODE(S30,18,'',S30),
      	S30_DATE = DECODE(S30,18,'',S30_DATE)
 WHERE 	HEADER_ID = V_HEADER_ID;

 --
 -- Set the S values for the lines, specifically set S9 (Cancel Line) to
 -- 11 (Complete)
 --

 UPDATE	SO_LINES
 SET 	LAST_UPDATED_BY = V_LAST_UPDATED_BY,
      	LAST_UPDATE_LOGIN = V_LAST_UPDATE_LOGIN,
      	LAST_UPDATE_DATE = SYSDATE,
	OPEN_FLAG  = NULL,
      	CANCELLED_QUANTITY = ORDERED_QUANTITY,
      	S1 = DECODE(S1,18,8,S1),
      	S1_DATE = DECODE(S1,18,sysdate,S1_DATE),
      	S2 = DECODE(S2,18,8,S2),
      	S2_DATE = DECODE(S2,18,sysdate,S2_DATE),
      	S3 = DECODE(S3,18,8,S3),
      	S3_DATE = DECODE(S3,18,sysdate,S3_DATE),
      	S4 = DECODE(S4,18,8,S4),
      	S4_DATE = DECODE(S4,18,sysdate,S4_DATE),
      	S5 = DECODE(S5,18,8,S5),
      	S5_DATE = DECODE(S5,18,sysdate,S5_DATE),
      	S6 = DECODE(S6,18,8,S6),
      	S6_DATE = DECODE(S6,18,sysdate,S6_DATE),
      	S7 = DECODE(S7,18,8,S7),
      	S7_DATE = DECODE(S7,18,sysdate,S7_DATE),
      	S8 = DECODE(S8,18,8,S8),
      	S8_DATE = DECODE(S8,18,sysdate,S8_DATE),
      	S9 = 11,
      	S9_DATE = SYSDATE,
      	S10 = DECODE(S10,18,8,S10),
      	S10_DATE = DECODE(S10,18,sysdate,S10_DATE),
      	S11 = DECODE(S11,18,8,S11),
      	S11_DATE = DECODE(S11,18,sysdate,S11_DATE),
      	S12 = DECODE(S12,18,8,S12),
      	S12_DATE = DECODE(S12,18,sysdate,S12_DATE),
      	S13 = DECODE(S13,18,8,S13),
      	S13_DATE = DECODE(S13,18,sysdate,S13_DATE),
      	S14 = DECODE(S14,18,8,S14),
      	S14_DATE = DECODE(S14,18,sysdate,S14_DATE),
      	S15 = DECODE(S15,18,8,S15),
      	S15_DATE = DECODE(S15,18,sysdate,S15_DATE),
      	S16 = DECODE(S16,18,8,S16),
      	S16_DATE = DECODE(S16,18,sysdate,S16_DATE),
      	S17 = DECODE(S17,18,8,S17),
      	S17_DATE = DECODE(S17,18,sysdate,S17_DATE),
      	S18 = DECODE(S18,18,8,S18),
      	S18_DATE = DECODE(S18,18,sysdate,S18_DATE),
      	S19 = DECODE(S19,18,8,S19),
      	S19_DATE = DECODE(S19,18,sysdate,S19_DATE),
      	S20 = DECODE(S20,18,8,S20),
      	S20_DATE = DECODE(S20,18,sysdate,S20_DATE),
      	S21 = DECODE(S21,18,8,S21),
      	S21_DATE = DECODE(S21,18,sysdate,S21_DATE),
      	S22 = DECODE(S22,18,8,S22),
      	S22_DATE = DECODE(S22,18,sysdate,S22_DATE),
      	S23 = DECODE(S23,18,8,S23),
      	S23_DATE = DECODE(S23,18,sysdate,S23_DATE),
      	S24 = DECODE(S24,18,8,S24),
      	S24_DATE = DECODE(S24,18,sysdate,S24_DATE),
      	S25 = DECODE(S25,18,8,S25),
      	S25_DATE = DECODE(S25,18,sysdate,S25_DATE),
      	S26 = DECODE(S26,18,8,S26),
      	S26_DATE = DECODE(S26,18,sysdate,S26_DATE),
      	S27 = DECODE(S27,18,8,S27),
      	S27_DATE = DECODE(S27,18,sysdate,S27_DATE),
      	S28 = DECODE(S28,18,8,S28),
      	S28_DATE = DECODE(S28,18,sysdate,S28_DATE),
      	S29 = DECODE(S29,18,8,S29),
      	S29_DATE = DECODE(S29,18,sysdate,S29_DATE),
      	S30 = DECODE(S30,18,8,S30),
      	S30_DATE = DECODE(S30,18,sysdate,S30_DATE)
 WHERE 	HEADER_ID = V_HEADER_ID;

 IF V_ORDER_CATEGORY = 'RMA' THEN
	declare
		CURSOR rma1 IS
			SELECT  LINE_ID
			FROM    SO_LINES
			WHERE   HEADER_ID = V_HEADER_ID
			AND     S29 IN (14,16,17);
	begin
		FOR rma1rec IN rma1 LOOP
			UPDATE MTL_SO_RMA_INTERFACE MSRI
			SET    MSRI.QUANTITY = 0,
			       MSRI.CLOSED_FLAG = 'Y'
			WHERE  MSRI.RMA_LINE_ID = rma1rec.LINE_ID
			AND    MSRI.SOURCE_CODE = V_SOURCE_CODE
			AND    MSRI.IN_USE_FLAG IS NULL;
		END LOOP;
	end;
 END IF;

 INSERT INTO SO_ORDER_CANCELLATIONS
        (HEADER_ID, CANCEL_CODE,
         CANCELLED_BY, CANCEL_DATE,
         LAST_UPDATED_BY, LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN, CREATION_DATE,
         CREATED_BY, CANCEL_COMMENT )
 VALUES(V_HEADER_ID, V_CANCEL_CODE,
       v_current_user, SYSDATE,
       V_LAST_UPDATED_BY, SYSDATE,
       V_LAST_UPDATE_LOGIN, SYSDATE,
       v_current_user, V_CANCEL_COMMENT );

 DELETE FROM SO_LINE_DETAILS
 WHERE  LINE_ID IN (
        SELECT LINE_ID
        FROM   SO_LINES
        WHERE  HEADER_ID = V_HEADER_ID)
 AND    RELEASED_FLAG = 'N';


 DELETE FROM SO_LINE_SERVICE_DETAILS
 WHERE  LINE_ID IN (
              SELECT LINE_ID
              FROM   SO_LINES
              WHERE  HEADER_ID = V_HEADER_ID);


 IF V_PRINT_ERR_MSG = 1 THEN
	x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_ORD_CANCLD_REQUERY');
	V_RESULT := 1;
 ELSE
	V_RESULT := 1;
 END IF;

END UPDATE_HEADER_INFO;


------------------------------------------------------------------------
-- procedure CHECK_SERVICE
--
--	This is called from oeklcn() to determine if a line can be
--	cancelled. This procedure contains the required checks that
--	are not covered by security rules.
--	Specifically it handles service checks
--
--      CS_CUSTOMER_PRODUCTS 			(products)
--		/|\
--	CS_CP_SERVICES				(service)
--		/|\
--	CS_CP_SERVICE_TRANSACTIONS		(sort of history)
--
--	Two possible situations can occur and hence the need to have
--	two separate sql checks. The first sql statement takes care
--	of the situation in which a service is associated with a product
--	and checks to see if the service is still active. This is done
--	by a join on CS_CUSTOMER_PRODUCTS and CS_CP_SERVICES.
--	The second possiblity is that service was ordered by itself,
--	a standalone service if you will. This would not have any
--	record in CS_CUSTOMER_PRODUCTS and hence the need to join
--	CS_CP_SERVICES to CS_CP_SERVICE_TRANSACTIONS.
--
-- RETURNS:
--      1 -> if order is not cancellable
--      0 -> if order is cancellable
------------------------------------------------------------------------

procedure CHECK_SERVICE(
   V_LINE_ID                      IN NUMBER
,  V_REAL_PARENT_LINE_ID          IN NUMBER
,  V_COMPONENT_CODE               IN VARCHAR2
,  V_ITEM_TYPE_CODE               IN VARCHAR2
,  V_SUBTREE_EXISTS               IN NUMBER
,  V_PRINT_ERR_MSG                IN NUMBER
,  V_RESULT                       OUT NUMBER
                          )
IS
   DUMMY                NUMBER := 0;
   DUMMY2               NUMBER := 0;
   DUMMY3               NUMBER := 0;
   x                    BOOLEAN;
BEGIN

 V_RESULT := 0;

 SELECT	COUNT(*)
 INTO   DUMMY
 FROM	CS_CP_SERVICES SER,
       	CS_CUSTOMER_PRODUCTS CPS
 WHERE 	SER.CUSTOMER_PRODUCT_ID = CPS.CUSTOMER_PRODUCT_ID
 AND 	CPS.ORIGINAL_ORDER_LINE_ID IN
		(SELECT LINE_ID FROM SO_LINES
		WHERE PARENT_LINE_ID = V_REAL_PARENT_LINE_ID
		AND NVL(COMPONENT_CODE,'0') LIKE V_COMPONENT_CODE ||'%'
		AND V_SUBTREE_EXISTS = 1
		UNION
		SELECT LINE_ID
		FROM SO_LINES
		WHERE LINE_ID = V_LINE_ID)
 AND	SYSDATE BETWEEN SER.START_DATE_ACTIVE AND SER.END_DATE_ACTIVE;

 IF (DUMMY >= 1) THEN
  IF V_PRINT_ERR_MSG = 1 THEN
	x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_SERVICE_ACTIVE');
	-- "You cannot cancel an order that has active service lines."
  END IF;
  V_RESULT := 1;
 ELSE
  IF V_ITEM_TYPE_CODE = 'SERVICE' THEN

    SELECT COUNT(*)
    INTO   DUMMY2
    FROM   CS_CP_SERVICES SER,
           CS_CP_SERVICE_TRANSACTIONS TRX
    WHERE  TRX.SERVICE_ORDER_LINE_ID = V_LINE_ID
    AND    TRX.CP_SERVICE_ID = SER.CP_SERVICE_ID
    AND    SYSDATE BETWEEN SER.START_DATE_ACTIVE AND SER.END_DATE_ACTIVE;

    IF (DUMMY2 >= 1) THEN
     IF V_PRINT_ERR_MSG = 1 THEN
	x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_SERVICE_ACTIVE');
     END IF;
     V_RESULT := 1;
    END IF;

  END IF;
 END IF;

 SELECT  COUNT(*)
 INTO    DUMMY3
 FROM    SO_LINES
 WHERE   LINE_ID = V_LINE_ID
 AND     ATO_FLAG = 'Y'
 AND     ATO_LINE_ID IS NOT NULL
 AND     ITEM_TYPE_CODE <> 'SERVICE'
 AND     LINE_TYPE_CODE <> 'RETURN'
 AND     NVL(S2,18) <> 18;

 IF (DUMMY3 >= 1) THEN
     IF V_PRINT_ERR_MSG = 1 THEN
        x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_NO_ATO_AFTER_PICK');
     END IF;
     V_RESULT := 1;
 END IF;


END CHECK_SERVICE;


------------------------------------------------------------------------
-- procedure CHECK_IF_CONFIG
--
--	This procedure checks to see if the line being operated on
--	has a configuration item associated with it.
--
-- RETURNS:
--      1 -> if there is a configuration item associated with the line
--      0 -> if there is no configuration item associated with the line
------------------------------------------------------------------------

procedure CHECK_IF_CONFIG(
   V_LOOP_LINE_ID               IN NUMBER
,  V_RESULT			OUT NUMBER
                          )
IS
  DUMMY           NUMBER;

BEGIN
 SELECT COUNT(*)
 INTO   DUMMY
 FROM   SO_LINE_DETAILS
 WHERE  LINE_ID = V_LOOP_LINE_ID
 AND    CONFIGURATION_ITEM_FLAG = 'Y';

 IF (DUMMY >= 1) THEN
  V_RESULT := 1;
 ELSE
  V_RESULT := 0;
 END IF;

END CHECK_IF_CONFIG;

------------------------------------------------------------------------
-- procedure CALCULATE_RMA_QTY
--
--	This procedure retrieves that allowable RMA cancel qty and the
--	received qty into INV.  If the line has RMA interface (S29) status
--	of Eligible (18) or Not Applicable (8) then the RMA cancel qty is
--	is simply the ordered_quantity less the cancelled_quantity. If
--	on the other hand the RMA interface (S29) status is Interfaced (14),
--	Partially Accepted (16) or Completely Accepted (17) then we get
--	the received qty into INV and then calculate the RMA cancel qty.
--	Hence the allowable RMA cancel qty would then be the ordered_quantity
--	less the cancelled_quantity less the received qty.  If we allowed
--	an over receipt then the allowable RMA cancel qty is 0.
--
-- RETURNS
--	1 -> successful
--	RMA_ALLOWABLE_CANCEL_QTY
--	RECEIVED_QTY
------------------------------------------------------------------------

procedure CALCULATE_RMA_QTY(
   V_LINE_ID                    IN NUMBER
,  V_S29                        IN NUMBER
,  V_ORDER_QTY			IN NUMBER
,  V_CANCELLED_QTY		IN NUMBER
,  V_RECEIVED_QTY		OUT NUMBER
,  V_ALLOWABLE_CANCEL_QTY       OUT NUMBER
,  V_PRINT_ERR_MSG              IN NUMBER
,  V_RESULT			OUT NUMBER
                          )
IS

  RECEIVED_QTY         NUMBER :=0;
  TEMP_QTY             NUMBER :=0;
  ALLOWABLE_CANCEL_QTY_TEMP NUMBER :=0;
  x                    BOOLEAN;

BEGIN

 IF ((V_S29=8) OR (V_S29=18) OR (nvl(V_S29,0) = 0 )) THEN
  RECEIVED_QTY := 0;
  GOTO do_calculation;

 ELSIF ((V_S29=14) OR (V_S29=16) OR (V_S29=17)) THEN

   SELECT CEIL(NVL(MAX(SUM(NVL(MTLSRR.RECEIVED_QUANTITY,0)) *
          ((V_ORDER_QTY - NVL(V_CANCELLED_QTY,0))
          / MAX(MTLSRI.QUANTITY))),0))
   INTO   RECEIVED_QTY
   FROM   MTL_SO_RMA_RECEIPTS MTLSRR,
          MTL_SO_RMA_INTERFACE MTLSRI
   WHERE  MTLSRR.RMA_INTERFACE_ID = MTLSRI.RMA_INTERFACE_ID
   AND    MTLSRI.RMA_LINE_ID = V_LINE_ID
   GROUP BY MTLSRI.INVENTORY_ITEM_ID,
            MTLSRI.COMPONENT_SEQUENCE_ID;

   GOTO do_calculation;

 ELSE
	IF V_PRINT_ERR_MSG = 1 THEN
        	x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_INVALID_S29');
        	V_RESULT := 0;
 	ELSE
        	V_RESULT := 0;
 	END IF;
	RETURN;
 END IF;

 <<do_calculation>>
 SELECT  ORDERED_QUANTITY - NVL(CANCELLED_QUANTITY,0)
 INTO    TEMP_QTY
 FROM    SO_LINES
 WHERE   LINE_ID = V_LINE_ID;

 V_ALLOWABLE_CANCEL_QTY := TEMP_QTY - RECEIVED_QTY;
 ALLOWABLE_CANCEL_QTY_TEMP := TEMP_QTY - RECEIVED_QTY;

 IF (ALLOWABLE_CANCEL_QTY_TEMP < 0) THEN
  V_ALLOWABLE_CANCEL_QTY := 0;
 END IF;

 V_RECEIVED_QTY := RECEIVED_QTY;
 V_RESULT := 1;

END CALCULATE_RMA_QTY;


------------------------------------------------------------------------
-- procedure SET_SERVICE_QTY
--
--	This procedure will called from oekclq to retrieve the
--	allowable cancel qty for a service item. It is simply
--	the ordered_quantity less the cancelled_quantity on the line.
--
-- RETURNS
--	1 -> successful
--	ALLOWABLE_CANCEL_QTY
------------------------------------------------------------------------

procedure SET_SERVICE_QTY(
   V_LINE_ID                    IN NUMBER
,  V_ALLOWABLE_CANCEL_QTY       OUT NUMBER
,  V_RESULT			OUT NUMBER
                          )
IS
     TEMP_QTY       NUMBER :=0;

BEGIN
 SELECT (ORDERED_QUANTITY - NVL(CANCELLED_QUANTITY,0))
 INTO    TEMP_QTY
 FROM    SO_LINES
 WHERE   LINE_ID = V_LINE_ID;

 V_ALLOWABLE_CANCEL_QTY := TEMP_QTY;
 V_RESULT := 1;

END SET_SERVICE_QTY;

------------------------------------------------------------------------
-- procedure NONCONFIG_QTY
--
--	Get the total quantity from the details for the selected line
--	that are not included items and not released. For the
--	picking line details we sum also over backordered picking lines.
--	picking_header_id = 0
--	This quantity is used in determining the allowable cancel qty
--	for the line selected.
--
-- RETURNS
--	1 -> successful
--	NONCONFIG_QTY
------------------------------------------------------------------------

procedure NONCONFIG_QTY(
   V_LOOP_LINE_ID               IN NUMBER
,  V_LOOP_RATIO_DEN		IN NUMBER
,  V_LOOP_RATIO_NUM		IN NUMBER
,  V_S2				IN NUMBER
,  V_NONCONFIG_QTY		OUT NUMBER
,  V_RESULT			OUT NUMBER
                          )
IS
  DUMMY             NUMBER;
  LD_QTY            NUMBER := 0;
  PD_QTY            NUMBER := 0;

BEGIN

-- statement tells us if we are dealing with an included item


 SELECT COUNT(*)
 INTO   DUMMY
 FROM   SO_LINE_DETAILS
 WHERE  LINE_ID = V_LOOP_LINE_ID
 AND    SHIPPABLE_FLAG = 'Y'
 AND    INCLUDED_ITEM_FLAG = 'N';

 IF (DUMMY >= 1) THEN

	IF ( V_S2 <> 4) then

	   select nvl(sum(quantity),0)
	   into   LD_QTY
	   from   so_line_details
	   where  nvl(released_flag,'N') = 'N'
	   and    line_id = V_LOOP_LINE_ID
	   and    included_item_flag = 'N'
	   and    nvl(schedule_status_code,'NULL') <> 'SUPPLY RESERVED';

	ELSE
		LD_QTY := 0;
	END IF;

	IF (V_S2 = 4 or V_S2 = 5) then

	   select nvl(sum(pld.requested_quantity),0)
	   into   PD_QTY
	   from   so_picking_lines pl, so_picking_line_details pld
	   where  pl.picking_line_id = pld.picking_line_id
	   and    pl.picking_header_id = 0
	   and    pl.order_line_id = V_LOOP_LINE_ID
	   and    nvl(pld.released_flag,'N') = 'N'
	   and    pl.included_item_flag = 'N'
	   and    nvl(pld.schedule_status_code,'NULL') <> 'SUPPLY RESERVED';

	ELSE
		PD_QTY := 0;
	END IF;

   V_NONCONFIG_QTY := FLOOR((LD_QTY + PD_QTY) *
                              V_LOOP_RATIO_NUM / V_LOOP_RATIO_DEN);

 END IF;

 V_RESULT := 1;

END NONCONFIG_QTY;

------------------------------------------------------------------------
-- procedure INCLUDE_QTY
--
--	A loop is setup to get the total quantity from the details.
--	The minimum qty is the quantity returned from the loop will be
--	returned. First get the total quantity from the details for the
--	selected line where there are included items that are required for
--	revenue and not released. For the picking line details we sum also
--	over backordered picking lines. We sum the quantity for both the
--	line details and picking line details. Finally the quantity is
--	adjusted for any ratio differences. This quantity is compared
--	to the quantity found in the details for the line and the
--	minimum qty is returned.
--      picking_header_id = 0
--      This quantity is used in determining the allowable cancel qty
--      for the line selected.
--
-- RETURNS
--	1 -> successful
--	INCLUDE_QTY

------------------------------------------------------------------------

procedure INCLUDE_QTY(
   V_LOOP_LINE_ID               IN NUMBER
,  V_TOTAL_QTY_FINAL		IN NUMBER
,  V_LOOP_RATIO_DEN		IN NUMBER
,  V_LOOP_RATIO_NUM		IN NUMBER
,  V_S2				IN NUMBER
,  V_INCLUDE_QTY		OUT NUMBER
,  V_RESULT			OUT NUMBER
                          )
IS

  LD_QTY            NUMBER := 0;
  PD_QTY            NUMBER := 0;
  TEMP_ITEM_ID      NUMBER;
  TOTAL_QTY	    NUMBER := 0;
  TEMP_QTY_FINAL    NUMBER := V_TOTAL_QTY_FINAL;
  RATIO	            NUMBER;


  CURSOR c1 IS
    select distinct inventory_item_id, component_ratio
    from   so_line_details
    where  line_id = V_LOOP_LINE_ID
    and    included_item_flag = 'Y'
    order by inventory_item_id;

BEGIN

  FOR c1rec IN c1 LOOP
   RATIO := c1rec.component_ratio;
   TEMP_ITEM_ID := c1rec.inventory_item_id;

	IF ( V_S2 <> 4) then

	   select nvl(sum(sld.quantity),0)
	   into   LD_QTY
	   from   so_line_details sld
	   where  nvl(sld.released_flag,'N') = 'N'
	   and    sld.line_id = V_LOOP_LINE_ID
	   and    sld.inventory_item_id = TEMP_ITEM_ID
	   and    nvl(sld.schedule_status_code,'NULL') <> 'SUPPLY RESERVED';

	ELSE
		LD_QTY := 0;
	END IF;

	IF ( V_S2 = 4 or V_S2 = 5) then

	   select nvl(sum(pld.requested_quantity),0)
	   into   PD_QTY
	   from   so_picking_lines pl,
	          so_picking_line_details pld
	   where  pl.picking_line_id = pld.picking_line_id
	   and    pl.picking_header_id = 0
	   and    pl.order_line_id = V_LOOP_LINE_ID
	   and    pl.inventory_item_id = TEMP_ITEM_ID
	   and    nvl(pld.released_flag,'N') = 'N'
	   and    nvl(pld.schedule_status_code,'NULL') <> 'SUPPLY RESERVED';

           /*
           ** Fix for Bug # 800989
           ** Following select added to calculate Qty for Non Shippable
           ** Included Items as above query will give PD_QTY=0 for such
           ** cases.
           */
           select nvl(sum(sld.quantity),0) + PD_QTY
           into   PD_QTY
           from   so_line_details sld
           where  nvl(sld.released_flag,'N')  = 'Y'
           and    nvl(sld.shippable_flag,'N') = 'N'
           and    sld.line_id = V_LOOP_LINE_ID
           and    sld.inventory_item_id = TEMP_ITEM_ID
           and    nvl(sld.schedule_status_code,'NULL') <> 'SUPPLY RESERVED';

	ELSE
		PD_QTY := 0;
	END IF;

   TOTAL_QTY := FLOOR((LD_QTY + PD_QTY) / RATIO *
                              V_LOOP_RATIO_NUM / V_LOOP_RATIO_DEN);
   TEMP_QTY_FINAL := LEAST(TEMP_QTY_FINAL, TOTAL_QTY);
  END LOOP;

  V_INCLUDE_QTY :=  TEMP_QTY_FINAL;
  V_RESULT := 1;

END INCLUDE_QTY;

------------------------------------------------------------------------
-- procedure CONFIG_QTY
--
--	Get the sum of the line details and picking line detail where
--	there exists a configuration item that is not released, but
--	possibly backordered.  Then adjust it for any ratio differences
--	that might exist between the parent and its child.
--
-- RETURNS
--	1 -> successful
--	CONFIG_QTY
------------------------------------------------------------------------

procedure CONFIG_QTY(
   V_ATO_LOOP_LINE_ID           IN NUMBER
,  V_LOOP_LINE_ID               IN NUMBER
,  V_LOOP_RATIO_DEN		IN NUMBER
,  V_LOOP_RATIO_NUM		IN NUMBER
,  V_S2				IN NUMBER
,  V_CONFIG_QTY 		OUT NUMBER
,  V_RESULT			OUT NUMBER
                          )
IS
        LD_QTY             NUMBER := 0;
        PD_QTY             NUMBER := 0;
        TOTAL_UNRELEASED   NUMBER := 0;

BEGIN

IF (V_S2 <> 4) then

 SELECT NVL(SUM(QUANTITY),0)
 INTO   LD_QTY
 FROM   SO_LINE_DETAILS
 WHERE  LINE_ID = V_ATO_LOOP_LINE_ID
 AND    CONFIGURATION_ITEM_FLAG = 'Y'
 AND    RELEASED_FLAG = 'N'
 AND    NVL(SCHEDULE_STATUS_CODE,'NULL') <> 'SUPPLY RESERVED';

ELSE
	LD_QTY := 0;
END IF;

IF (V_S2 = 4 or V_S2 = 5) then

 SELECT NVL(SUM(PLD.REQUESTED_QUANTITY),0)
 INTO   PD_QTY
 FROM   SO_PICKING_LINE_DETAILS PLD, SO_PICKING_LINES PL
 WHERE  PL.ORDER_LINE_ID = V_ATO_LOOP_LINE_ID
 AND    PL.PICKING_HEADER_ID = 0
 AND    PL.PICKING_LINE_ID = PLD.PICKING_LINE_ID
 AND    PLD.RELEASED_FLAG = 'N'
 AND    NVL(PLD.SCHEDULE_STATUS_CODE,'NULL') <> 'SUPPLY RESERVED';

ELSE
	PD_QTY := 0;
END IF;

 SELECT (L.ordered_quantity - nvl(L.cancelled_quantity,0)) /
        (M.ordered_quantity - nvl(M.cancelled_quantity,0))
 INTO   TOTAL_UNRELEASED
 FROM   SO_LINES L, SO_LINES M
 WHERE  L.LINE_ID = V_LOOP_LINE_ID
 AND    M.LINE_ID = V_ATO_LOOP_LINE_ID;

 V_CONFIG_QTY := FLOOR((LD_QTY + PD_QTY) * TOTAL_UNRELEASED *
                              V_LOOP_RATIO_NUM / V_LOOP_RATIO_DEN);
 V_RESULT := 1;

END CONFIG_QTY;


------------------------------------------------------------------------
-- procedure UPDATE_LINE_INFO
--
--	If a full cancellation is begin performed then update so_lines
--	by setting the cancelled_quantity equal to the ordered_quantity
--	less the greatest quantity between what was shipped and what was
--	invoiced.
--	If the line begin update is a child of a shipment schedule,
--	update the quantity on the parent shipment line.
--	If we have a detail shipment line, and it's an option,
--	once we cancel, we need to disassociate it from it's
--	source since we've changed the configuration.
--	Update the cancelled_quantity in so_lines adjusted by any
--	ratio differences if were have a model.
--	Insert a record into so_order_cancellations
--	Update the open_flag in so_lines, if ordered_quantity less
--	the cancelled_quantity is 0 then set the open_flag =  ''
--	Set the S9 (Cancel Line) column based on the open flag.
--	If open_flag is null then set the S9 to 11 (Complete) otherwise
--	set S9 to 5 (Partial).
--	Also set S3 which is Backorder Release. Check to see if no
--	picking lines exist where the original requested quantity is
--	greater than the cancelled quantity. If this is TRUE and
--	S3 is 18 (Eligible) then set S3 to 8 (Not Applicable).
--
-- RETURNS
--	1 -> success
------------------------------------------------------------------------

procedure UPDATE_LINE_INFO(
   V_LINE_ID                    IN NUMBER
,  V_REQUESTED_CANCEL_QTY       IN NUMBER
,  V_CANCEL_COMMENT             IN LONG
,  V_CANCEL_CODE                IN VARCHAR2
,  V_FULL                       IN NUMBER
,  V_OPTION_FLAG                IN NUMBER
,  V_PARENT_LINE_ID             IN NUMBER
,  V_LINE_TYPE_CODE             IN VARCHAR2
,  V_SHIPMENT_SCHEDULE_LINE_ID  IN NUMBER
,  V_SUBTREE_EXISTS             IN NUMBER
,  V_COMPONENT_CODE             IN VARCHAR2
,  V_REAL_PARENT_LINE_ID        IN NUMBER
,  V_LAST_UPDATED_BY            IN NUMBER
,  V_LAST_UPDATE_LOGIN          IN NUMBER
,  V_STATUS                     IN VARCHAR2
,  V_RESULT			OUT NUMBER
                          )
IS

	CANCEL_QTY_TMP	 	NUMBER := 0;
	L_CURRENT_ORDERED_QTY	NUMBER := 0;
	L_CURRENT_CANCELLED_QTY	NUMBER := 0;
        v_current_user          NUMBER ;
        l_org_id                NUMBER := NULL;

BEGIN

        v_current_user := to_number(FND_PROFILE.VALUE('USER_ID'));

        l_org_id := FND_PROFILE.VALUE ('SO_ORGANIZATION_ID');

 IF (V_OPTION_FLAG = 1) THEN
  -- Need a sql statement here to mark records as changed after the
  -- commit whose allowed quantity *may* have been affected by this
  -- commit.  The sql must make a *logical* change to the database
  -- in order to actually mark the record.
  -- Here we have chosen to cycle among the users profile_value, 0, and 1

  UPDATE SO_LINES
  SET    LAST_UPDATED_BY = DECODE(LAST_UPDATED_BY, 0, 1, 1,
                           DECODE(V_LAST_UPDATED_BY,1,0,V_LAST_UPDATED_BY),
                           V_LAST_UPDATED_BY, 0, V_LAST_UPDATED_BY)
  WHERE  (LINE_ID = V_PARENT_LINE_ID
          OR  PARENT_LINE_ID = V_PARENT_LINE_ID);
 END IF;

 IF (V_FULL = 1) THEN

		IF (V_LINE_TYPE_CODE = 'DETAIL') THEN
			IF (V_PARENT_LINE_ID IS NULL OR V_PARENT_LINE_ID = 0) THEN

	                        SELECT  (ORDERED_QUANTITY - NVL(CANCELLED_QUANTITY,0)
        	                           - GREATEST (NVL(SHIPPED_QUANTITY,0),
						NVL(INVOICED_QUANTITY,0)))
				INTO    CANCEL_QTY_TMP
                	        FROM    SO_LINES
                	        WHERE   LINE_ID = V_LINE_ID;


				UPDATE SO_LINES  L
			    	SET    CANCELLED_QUANTITY =
        		        		(SELECT NVL(L.CANCELLED_QUANTITY,0) +
               		   		      		(CANCEL_QTY_TMP *
               		         			(L.ORDERED_QUANTITY-NVL(L.CANCELLED_QUANTITY,0))/
                    		    			(L2.ORDERED_QUANTITY-NVL(L2.CANCELLED_QUANTITY,0)))
         		         		FROM   SO_LINES L2
    			         		WHERE  L2.LINE_ID = V_SHIPMENT_SCHEDULE_LINE_ID)
			    	WHERE  L.LINE_ID IN
		           		(select line_id
		            		 from   so_lines
		            		 where  parent_line_id = V_SHIPMENT_SCHEDULE_LINE_ID
		            		 and    nvl(component_code,'0') like V_COMPONENT_CODE || '%'
		            		 and    V_SUBTREE_EXISTS = 1
		            		union
		            		 select line_id
		            		 from   so_lines
		            		 where  line_id = V_SHIPMENT_SCHEDULE_LINE_ID);
		   	ELSE
				UPDATE SO_LINES
			    	SET    SOURCE_LINE_ID = NULL
			    	WHERE  LINE_ID = V_LINE_ID;
		   	END IF;
		END IF;


        declare
                CURSOR full1 IS
                        SELECT  LINE_ID, HEADER_ID, ORDERED_QUANTITY, CANCELLED_QUANTITY
                                ,SHIPPED_QUANTITY,INVOICED_QUANTITY
                        FROM    SO_LINES
                        WHERE	LINE_ID IN
		           (select line_id
        		    from   so_lines
    			    where  parent_line_id = V_REAL_PARENT_LINE_ID
            		    and    (nvl(component_code,'0') like V_COMPONENT_CODE || '%'
				    OR COMPONENT_CODE IS NULL)
           		    and    V_SUBTREE_EXISTS = 1
           		    union
            		    select line_id
            		    from   so_lines
            		    where  line_id = V_LINE_ID
                            or     service_parent_line_id = V_LINE_ID);


        begin


                FOR full1rec IN full1 LOOP
                        UPDATE SO_LINES SOL
                        SET    CANCELLED_QUANTITY = ORDERED_QUANTITY
			           - GREATEST (NVL(SHIPPED_QUANTITY,0),
				NVL(INVOICED_QUANTITY,0))
                        WHERE  SOL.LINE_ID = full1rec.LINE_ID;

			INSERT INTO SO_ORDER_CANCELLATIONS
      				 (LINE_ID, HEADER_ID, CANCEL_CODE, CANCELLED_BY,
         			 CANCEL_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
				 CANCEL_COMMENT, CANCELLED_QUANTITY, STATUS,
         			 CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN )
			VALUES
			         (full1rec.LINE_ID, full1rec.HEADER_ID, V_CANCEL_CODE,
				  v_current_user,
			          SYSDATE, V_LAST_UPDATED_BY, SYSDATE, V_CANCEL_COMMENT,
			          (full1rec.ORDERED_QUANTITY -
					NVL(full1rec.CANCELLED_QUANTITY,0) - GREATEST
					(NVL(full1rec.SHIPPED_QUANTITY,0),
					 NVL(full1rec.INVOICED_QUANTITY,0))), V_STATUS,
				  SYSDATE,
				  v_current_user, V_LAST_UPDATE_LOGIN);

                END LOOP;

        end;


 ELSE
  IF (V_LINE_TYPE_CODE = 'DETAIL') THEN
   IF (V_PARENT_LINE_ID IS NULL OR V_PARENT_LINE_ID = 0) THEN

    UPDATE SO_LINES  L
    SET    CANCELLED_QUANTITY =
                (SELECT NVL(L.CANCELLED_QUANTITY,0) +
                        (V_REQUESTED_CANCEL_QTY *
                        (L.ORDERED_QUANTITY-NVL(L.CANCELLED_QUANTITY,0))/
                        (L2.ORDERED_QUANTITY-NVL(L2.CANCELLED_QUANTITY,0)))
                 FROM   SO_LINES L2
                 WHERE  L2.LINE_ID = V_SHIPMENT_SCHEDULE_LINE_ID)
    WHERE  L.LINE_ID IN
           (select line_id
            from   so_lines
            where  parent_line_id = V_SHIPMENT_SCHEDULE_LINE_ID
            and    nvl(component_code,'0') like V_COMPONENT_CODE || '%'
            and    V_SUBTREE_EXISTS = 1
            union
            select line_id
            from   so_lines
            where  line_id = V_SHIPMENT_SCHEDULE_LINE_ID);
   ELSE
    UPDATE SO_LINES
    SET    SOURCE_LINE_ID = NULL
    WHERE  LINE_ID = V_LINE_ID;
   END IF;
 END IF;

 SELECT ORDERED_QUANTITY, CANCELLED_QUANTITY
 INTO   L_CURRENT_ORDERED_QTY, L_CURRENT_CANCELLED_QTY
 FROM   SO_LINES
 WHERE  LINE_ID = V_LINE_ID;

 DECLARE
	CURSOR not_full IS
		SELECT LINE_ID, HEADER_ID, ORDERED_QUANTITY
		       ,CANCELLED_QUANTITY
		FROM   SO_LINES
		WHERE  LINE_ID IN
                     (SELECT LINE_ID
                      FROM   SO_LINES
                      WHERE  PARENT_LINE_ID = V_REAL_PARENT_LINE_ID
                      AND   (NVL(COMPONENT_CODE,'0') LIKE V_COMPONENT_CODE || '%'
                             OR COMPONENT_CODE IS NULL)
                      AND    V_SUBTREE_EXISTS = 1
                      UNION
                      SELECT LINE_ID
                      FROM   SO_LINES
                      WHERE  LINE_ID = V_LINE_ID
                      OR     SERVICE_PARENT_LINE_ID = V_LINE_ID);

 BEGIN
	FOR not_full_rec IN not_full LOOP
		UPDATE SO_LINES L
		SET    CANCELLED_QUANTITY =
			NVL(not_full_rec.CANCELLED_QUANTITY,0)+(V_REQUESTED_CANCEL_QTY *
			(not_full_rec.ORDERED_QUANTITY - NVL(not_full_rec.CANCELLED_QUANTITY,0))/
			(L_CURRENT_ORDERED_QTY - NVL(L_CURRENT_CANCELLED_QTY,0)))
		WHERE  L.LINE_ID = not_full_rec.LINE_ID;
	END LOOP;
 END;

 INSERT INTO SO_ORDER_CANCELLATIONS
           ( LINE_ID, HEADER_ID,
             CANCEL_CODE, CANCELLED_BY,
             CANCEL_DATE, LAST_UPDATED_BY,
             LAST_UPDATE_DATE, CANCEL_COMMENT,
             CANCELLED_QUANTITY, STATUS,
             CREATION_DATE, CREATED_BY,
             LAST_UPDATE_LOGIN )
 SELECT L.LINE_ID, L.HEADER_ID,
	V_CANCEL_CODE, v_current_user,
        SYSDATE, V_LAST_UPDATED_BY,
        SYSDATE, V_CANCEL_COMMENT,
        NVL(L.CANCELLED_QUANTITY,0) - NVL(SUM (SOC.CANCELLED_QUANTITY),0),
        V_STATUS, SYSDATE, v_current_user,
        V_LAST_UPDATE_LOGIN
 FROM   SO_LINES L, SO_ORDER_CANCELLATIONS SOC
 WHERE 	L.LINE_ID IN
       (SELECT LINE_ID
        FROM   SO_LINES
        WHERE  PARENT_LINE_ID = V_REAL_PARENT_LINE_ID
        AND   (NVL(COMPONENT_CODE,'0') LIKE V_COMPONENT_CODE || '%'
               OR COMPONENT_CODE IS NULL)
        AND    V_SUBTREE_EXISTS = 1
        UNION
        SELECT LINE_ID
        FROM   SO_LINES
        WHERE  LINE_ID = V_LINE_ID
        OR     SERVICE_PARENT_LINE_ID = V_LINE_ID)
 AND    L.LINE_ID = SOC.LINE_ID(+)
 HAVING NVL(L.CANCELLED_QUANTITY,0) <> NVL(SUM (SOC.CANCELLED_QUANTITY),0)
 GROUP BY L.LINE_ID, L.HEADER_ID, L.CANCELLED_QUANTITY;

END IF;

/*
** Fix for Bug # 532221
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

UPDATE SO_LINES SET OPEN_FLAG =
       DECODE(nvl(ORDERED_QUANTITY,0) - NVL(CANCELLED_QUANTITY,0)
                                        ,0,'',OPEN_FLAG)
WHERE LINE_ID IN
      (select line_id
       from   so_lines
       where  parent_line_id = V_REAL_PARENT_LINE_ID
       and    (nvl(component_code,'0') like V_COMPONENT_CODE || '%'
	       or component_code is null)
       and     V_SUBTREE_EXISTS = 1
       union
       select line_id
       from   so_lines
       where  line_id = V_LINE_ID
       or     service_parent_line_id = V_LINE_ID);

UPDATE SO_LINES
SET   LAST_UPDATED_BY = V_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = V_LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE = SYSDATE,
      S1      = DECODE(OPEN_FLAG,'',DECODE(S1,18,8,S1),S1),
      S1_DATE = DECODE(OPEN_FLAG,'',DECODE(S1,18,sysdate,S1_DATE),S1_DATE),
      S2      = DECODE(OPEN_FLAG,'',DECODE(S2,18,8,S2),S2),
      S2_DATE = DECODE(OPEN_FLAG,'',DECODE(S2,18,sysdate,S2_DATE),S2_DATE),
      S3      = DECODE(OPEN_FLAG,'',DECODE(S3,18,8,S3),S3),
      S3_DATE = DECODE(OPEN_FLAG,'',DECODE(S3,18,sysdate,S3_DATE),S3_DATE),
      S4      = DECODE(OPEN_FLAG,'',DECODE(S4,18,8,S4),S4),
      S4_DATE = DECODE(OPEN_FLAG,'',DECODE(S4,18,sysdate,S4_DATE),S4_DATE),
      S5      = DECODE(OPEN_FLAG,'',DECODE(S5,18,8,S5),S5),
      S5_DATE = DECODE(OPEN_FLAG,'',DECODE(S5,18,sysdate,S5_DATE),S5_DATE),
      S6      = DECODE(OPEN_FLAG,'',DECODE(S6,18,8,S6),S6),
      S6_DATE = DECODE(OPEN_FLAG,'',DECODE(S6,18,sysdate,S6_DATE),S6_DATE),
      S7      = DECODE(OPEN_FLAG,'',DECODE(S7,18,8,S7),S7),
      S7_DATE = DECODE(OPEN_FLAG,'',DECODE(S7,18,sysdate,S7_DATE),S7_DATE),
      S8      = DECODE(OPEN_FLAG,'',DECODE(S8,18,8,S8),S8),
      S8_DATE = DECODE(OPEN_FLAG,'',DECODE(S8,18,sysdate,S8_DATE),S8_DATE),
      S9      = DECODE(OPEN_FLAG,'',11,5),
      S9_DATE = sysdate,
      S10     = DECODE(OPEN_FLAG,'',DECODE(S10,18,8,S10),S10),
      S10_DATE= DECODE(OPEN_FLAG,'',DECODE(S10,18,sysdate,S10_DATE),S10_DATE),
      S11     = DECODE(OPEN_FLAG,'',DECODE(S11,18,8,S11),S11),
      S11_DATE= DECODE(OPEN_FLAG,'',DECODE(S11,18,sysdate,S11_DATE),S11_DATE),
      S12     = DECODE(OPEN_FLAG,'',DECODE(S12,18,8,S12),S12),
      S12_DATE= DECODE(OPEN_FLAG,'',DECODE(S12,18,sysdate,S12_DATE),S12_DATE),
      S13     = DECODE(OPEN_FLAG,'',DECODE(S13,18,8,S13),S13),
      S13_DATE= DECODE(OPEN_FLAG,'',DECODE(S13,18,sysdate,S13_DATE),S13_DATE),
      S14     = DECODE(OPEN_FLAG,'',DECODE(S14,18,8,S14),S14),
      S14_DATE= DECODE(OPEN_FLAG,'',DECODE(S14,18,sysdate,S14_DATE),S14_DATE),
      S15     = DECODE(OPEN_FLAG,'',DECODE(S15,18,8,S15),S15),
      S15_DATE= DECODE(OPEN_FLAG,'',DECODE(S15,18,sysdate,S15_DATE),S15_DATE),
      S16     = DECODE(OPEN_FLAG,'',DECODE(S16,18,8,S16),S16),
      S16_DATE= DECODE(OPEN_FLAG,'',DECODE(S16,18,sysdate,S16_DATE),S16_DATE),
      S17     = DECODE(OPEN_FLAG,'',DECODE(S17,18,8,S17),S17),
      S17_DATE= DECODE(OPEN_FLAG,'',DECODE(S17,18,sysdate,S17_DATE),S17_DATE),
      S18     = DECODE(OPEN_FLAG,'',DECODE(S18,18,8,S18),S18),
      S18_DATE= DECODE(OPEN_FLAG,'',DECODE(S18,18,sysdate,S18_DATE),S18_DATE),
      S19     = DECODE(OPEN_FLAG,'',DECODE(S19,18,8,S19),S19),
      S19_DATE= DECODE(OPEN_FLAG,'',DECODE(S19,18,sysdate,S19_DATE),S19_DATE),
      S20     = DECODE(OPEN_FLAG,'',DECODE(S20,18,8,S20),S20),
      S20_DATE= DECODE(OPEN_FLAG,'',DECODE(S20,18,sysdate,S20_DATE),S20_DATE),
      S21     = DECODE(OPEN_FLAG,'',DECODE(S21,18,8,S21),S21),
      S21_DATE= DECODE(OPEN_FLAG,'',DECODE(S21,18,sysdate,S21_DATE),S21_DATE),
      S22     = DECODE(OPEN_FLAG,'',DECODE(S22,18,8,S22),S22),
      S22_DATE= DECODE(OPEN_FLAG,'',DECODE(S22,18,sysdate,S22_DATE),S22_DATE),
      S23     = DECODE(OPEN_FLAG,'',DECODE(S23,18,8,S23),S23),
      S23_DATE= DECODE(OPEN_FLAG,'',DECODE(S23,18,sysdate,S23_DATE),S23_DATE),
      S24     = DECODE(OPEN_FLAG,'',DECODE(S24,18,8,S24),S24),
      S24_DATE= DECODE(OPEN_FLAG,'',DECODE(S24,18,sysdate,S24_DATE),S24_DATE),
      S25     = DECODE(OPEN_FLAG,'',DECODE(S25,18,8,S25),S25),
      S25_DATE= DECODE(OPEN_FLAG,'',DECODE(S25,18,sysdate,S25_DATE),S25_DATE),
      S26     = DECODE(OPEN_FLAG,'',DECODE(S26,18,8,S26),S26),
      S26_DATE= DECODE(OPEN_FLAG,'',DECODE(S26,18,sysdate,S26_DATE),S26_DATE),
      S27     = DECODE(OPEN_FLAG,'',DECODE(S27,18,8,S27),S27),
      S27_DATE= DECODE(OPEN_FLAG,'',DECODE(S27,18,sysdate,S27_DATE),S27_DATE),
      S28     = DECODE(OPEN_FLAG,'',DECODE(S28,18,8,S28),S28),
      S28_DATE= DECODE(OPEN_FLAG,'',DECODE(S28,18,sysdate,S28_DATE),S28_DATE),
      S29     = DECODE(OPEN_FLAG,'',DECODE(S29,18,8,S29),S29),
      S29_DATE= DECODE(OPEN_FLAG,'',DECODE(S29,18,sysdate,S29_DATE),S29_DATE),
      S30     = DECODE(OPEN_FLAG,'',DECODE(S30,18,8,S30),S30),
      S30_DATE= DECODE(OPEN_FLAG,'',DECODE(S30,18,sysdate,S30_DATE),S30_DATE)
WHERE LINE_ID IN
      (select line_id from so_lines
       where parent_line_id = V_REAL_PARENT_LINE_ID
       and (nvl(component_code,'0') like V_COMPONENT_CODE || '%'
	    or component_code is null)
       and V_SUBTREE_EXISTS = 1
       union
       select line_id
       from   so_lines
       where  line_id = V_LINE_ID
       or     service_parent_line_id = V_LINE_ID);

UPDATE SO_LINES
SET    S3 = DECODE(S3,18,8,S3)
WHERE  LINE_ID IN
       (select line_id from so_lines
        where parent_line_id = V_REAL_PARENT_LINE_ID
        and (nvl(component_code,'0') like V_COMPONENT_CODE || '%'
	        or component_code is null)
        and V_SUBTREE_EXISTS = 1
        union
        select line_id
        from   so_lines
        where  line_id = V_LINE_ID
        or     service_parent_line_id = V_LINE_ID)
AND    NOT EXISTS
        (SELECT 'BACKORDERED PICKING LINES'
         FROM SO_PICKING_LINES
         WHERE ORDER_LINE_ID = SO_LINES.LINE_ID
         AND PICKING_HEADER_ID = 0
         AND ORIGINAL_REQUESTED_QUANTITY > NVL(CANCELLED_QUANTITY,0));

V_RESULT := 1;

END UPDATE_LINE_INFO;

------------------------------------------------------------------------
-- procedure UPDATE_MODEL_INFO
--
--	Update so_lines  by setting the cancelled_quantity = the
--	requested quantity and previous cancelled_quantity. Also set the
--	open_flag to '' if ordered_quantity equals cancelled_quantity.
--	If no backordered picking lines exist where the original requested
--	quantity is greater than the cancelled quantity then set S3
--	(Backorder Release) to 8 (Not Applicable) if it was 18 (Eligible).
--	Insert a record into so_order_cancellations.
--
-- RETURNS
--	1 -> success
------------------------------------------------------------------------

procedure UPDATE_MODEL_INFO(
   V_LINE_ID                    IN NUMBER
,  V_REQUESTED_CANCEL_QTY       IN NUMBER
,  V_CANCEL_COMMENT             IN LONG
,  V_CANCEL_CODE                IN VARCHAR2
,  V_STATUS			IN VARCHAR2
,  V_LAST_UPDATED_BY		IN NUMBER
,  V_LAST_UPDATE_LOGIN		IN NUMBER
,  V_HEADER_ID                  IN NUMBER
,  V_FULL                       IN NUMBER
,  V_RESULT			OUT NUMBER
                          )
IS

	DUMMY		NUMBER;
	TEMP 		BOOLEAN;
        v_current_user  NUMBER;

BEGIN

        v_current_user := to_number(FND_PROFILE.VALUE('USER_ID'));

-- If there are open pick slips against this line (or its included items),
-- we fail the whole 'Clean empty classes' process and issue an error message.

 SELECT COUNT(*)
 INTO   DUMMY
 FROM   SO_PICKING_LINES L,
	SO_PICKING_HEADERS H
 WHERE  L.ORDER_LINE_ID = V_LINE_ID
 AND 	L.PICKING_HEADER_ID = H.PICKING_HEADER_ID
 AND	H.STATUS_CODE IN ('OPEN' ,'PENDING', 'IN PROGRESS');

 IF (DUMMY >= 1) THEN
    TEMP := OE_MSG.SET_MESSAGE_NAME ('OE_CANCEL_CLASS_OPENSLP');
    V_RESULT := 0;
    RETURN;
 END IF;

 UPDATE SO_LINES SET
      CANCELLED_QUANTITY =
         V_REQUESTED_CANCEL_QTY + NVL(CANCELLED_QUANTITY,0)
 WHERE LINE_ID = V_LINE_ID;

 UPDATE SO_LINES SET
      OPEN_FLAG =
         DECODE ((nvl(ORDERED_QUANTITY,0) - NVL(CANCELLED_QUANTITY,0)),
             0, '', OPEN_FLAG)
 WHERE LINE_ID = V_LINE_ID;

 UPDATE SO_LINES SET
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
      S9 = DECODE(OPEN_FLAG,'',11,5),
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
 WHERE LINE_ID = V_LINE_ID;

 -- BACKORDERED PICKING LINES EXIST

 SELECT COUNT(*)
 INTO   DUMMY
 FROM   SO_PICKING_LINES
 WHERE  PICKING_HEADER_ID = 0
 AND    ORIGINAL_REQUESTED_QUANTITY > NVL(CANCELLED_QUANTITY,0)
 AND    ORDER_LINE_ID = V_LINE_ID;

 IF (DUMMY >= 1) THEN
    NULL;
 ELSE
   UPDATE SO_LINES
   SET    S3 = DECODE(S3,18,8,S3)
   WHERE  LINE_ID = V_LINE_ID;
 END IF;

UPDATE SO_LINES
SET   S1_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S1,8,SYSDATE,S1_DATE),S1_DATE),
      S2_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S2,8,SYSDATE,S2_DATE),S2_DATE),
      S3_DATE = DECODE(S3,8,SYSDATE,S3_DATE),
      S4_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S4,8,SYSDATE,S4_DATE),S4_DATE),
      S5_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S5,8,SYSDATE,S5_DATE),S5_DATE),
      S6_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S6,8,SYSDATE,S6_DATE),S6_DATE),
      S7_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S7,8,SYSDATE,S7_DATE),S7_DATE),
      S8_DATE = DECODE(OPEN_FLAG,'',
        DECODE(S8,8,SYSDATE,S8_DATE),S8_DATE),
      S9_DATE = SYSDATE,
      S10_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S10,8,SYSDATE,S10_DATE),S10_DATE),
      S11_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S11,8,SYSDATE,S11_DATE),S11_DATE),
      S12_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S12,8,SYSDATE,S12_DATE),S12_DATE),
      S13_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S13,8,SYSDATE,S13_DATE),S13_DATE),
      S14_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S14,8,SYSDATE,S14_DATE),S14_DATE),
      S15_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S15,8,SYSDATE,S15_DATE),S15_DATE),
      S16_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S16,8,SYSDATE,S16_DATE),S16_DATE),
      S17_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S17,8,SYSDATE,S17_DATE),S17_DATE),
      S18_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S18,8,SYSDATE,S18_DATE),S18_DATE),
      S19_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S19,8,SYSDATE,S19_DATE),S19_DATE),
      S20_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S20,8,SYSDATE,S20_DATE),S20_DATE),
      S21_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S21,8,SYSDATE,S21_DATE),S21_DATE),
      S22_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S22,8,SYSDATE,S22_DATE),S22_DATE),
      S23_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S23,8,SYSDATE,S23_DATE),S23_DATE),
      S24_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S24,8,SYSDATE,S24_DATE),S24_DATE),
      S25_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S25,8,SYSDATE,S25_DATE),S25_DATE),
      S26_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S26,8,SYSDATE,S26_DATE),S26_DATE),
      S27_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S27,8,SYSDATE,S27_DATE),S27_DATE),
      S28_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S28,8,SYSDATE,S28_DATE),S28_DATE),
      S29_DATE=DECODE(OPEN_FLAG,'',
        DECODE(S29,8,SYSDATE,S29_DATE),S29_DATE),
      S30_DATE=DECODE(OPEN_FLAG,'' ,
        DECODE(S30,8,SYSDATE,S30_DATE),S30_DATE)
WHERE LINE_ID = V_LINE_ID;

INSERT INTO SO_ORDER_CANCELLATIONS
       ( LINE_ID, HEADER_ID,
         CANCEL_CODE, CANCELLED_BY,
         CANCEL_DATE, LAST_UPDATED_BY,
         LAST_UPDATE_DATE, CANCEL_COMMENT,
         CANCELLED_QUANTITY, STATUS,
         CREATION_DATE, CREATED_BY,
         LAST_UPDATE_LOGIN )
VALUES( V_LINE_ID, V_HEADER_ID,
        V_CANCEL_CODE, v_current_user,
        SYSDATE, V_LAST_UPDATED_BY,
        SYSDATE, V_CANCEL_COMMENT,
        V_REQUESTED_CANCEL_QTY,
        V_STATUS, SYSDATE, v_current_user,
        V_LAST_UPDATE_LOGIN );

V_RESULT := 1;

END UPDATE_MODEL_INFO;

------------------------------------------------------------------------
-- procedure LOAD_BOM
--
--	call the bom exploder
--
-- RETURNS
--	1 -> successful
--	0 -> unsuccessful
------------------------------------------------------------------------

procedure LOAD_BOM(
   V_SO_ORGANIZATION_ID         IN NUMBER
,  V_TOP_INVENTORY_ITEM_ID	IN NUMBER
,  V_TOP_COMPONENT_CODE		IN VARCHAR2
,  V_CREATION_DATE_TIME		IN VARCHAR2
,  V_LAST_UPDATED_BY		IN NUMBER
,  V_RESULT			OUT NUMBER
                          )
IS
	X_BOM_MESSAGE		VARCHAR2(500) := '';
	X_BOM_RESULT		NUMBER;
	V_BOM_EXPLOSION_GROUP_ID NUMBER;
        x                    BOOLEAN;

BEGIN

 V_RESULT := 0;

   BOMPNORD.BMXPORDER_EXPLODE_FOR_ORDER
   ( ORG_ID => V_SO_ORGANIZATION_ID
   , COPY_FLAG => 2
   , EXPL_TYPE => 'OPTIONAL'
   , ORDER_BY => 2
   , GRP_ID => V_BOM_EXPLOSION_GROUP_ID
   , SESSION_ID => 0
   , LEVELS_TO_EXPLODE => 60
   , ITEM_ID => V_TOP_INVENTORY_ITEM_ID
   , COMP_CODE => V_TOP_COMPONENT_CODE
/* The foll. line has been commented and changed to the line below it.
*  This has been done to fix bug# 912073.
*/
--   , REV_DATE => substr(V_CREATION_DATE_TIME, 1, 15)
   , REV_DATE => substr(V_CREATION_DATE_TIME, 1, 16)
   , USER_ID => V_LAST_UPDATED_BY
   , ERR_MSG => X_BOM_MESSAGE
   , ERROR_CODE => X_BOM_RESULT);

   IF (X_BOM_RESULT = 0) THEN
      V_RESULT := 1;
   ELSE
    x :=OE_MSG.SET_BUFFER_MESSAGE('OE_BOM_EXPLOSION_FAILED', 'REASON', X_BOM_RESULT);
      -- issue message 'OE_BOM_EXPLOSION_FAILED'
      -- REASON=:WORLD.BOM_MESSAGE
      V_RESULT := 0;
   END IF;

END LOAD_BOM;

------------------------------------------------------------------------
-- procedure CHECK_MODEL_RATIOS
--
--	If this is a FULL cancellation, don't check the ratios.
--	If this is a return line, don't check the ratios.
--	If this is an option line, make sure the user only cancels in
-- 	multiples of the model if it's not a full cancellation.
--	Check to make sure that the quantity selected is a multiple of
--	parent quantity.
--	If it is a multiple of parent quantity check to see if we are
--	dealing with a ATO model and if so call the bom exploder.
--	Make sure that we are not cancelling the last option a mandatory class.
--	Make sure that we are not cancelling a mandatory class.
--	Also make sure that we have not gone below the minimum required
--	quantity for the option selected.
--
-- RETURNS
--	1 -> successful
------------------------------------------------------------------------

procedure CHECK_MODEL_RATIOS(
   V_LINE_ID			IN NUMBER
,  V_REQUESTED_CANCEL_QTY       IN NUMBER
,  V_LINE_TYPE_CODE		IN VARCHAR2
,  V_OPTION_FLAG		IN NUMBER
,  V_LINK_TO_LINE_ID		IN NUMBER
,  V_ORDER_QTY			IN NUMBER
,  V_CANCELLED_QTY		IN NUMBER
,  V_FULL			IN NUMBER
,  V_ATO_FLAG			IN NUMBER
,  V_SO_ORGANIZATION_ID         IN NUMBER
,  V_TOP_BILL_SEQUENCE_ID 	IN NUMBER
,  V_PARENT_COMPONENT_SEQUENCE_ID IN NUMBER
,  V_COMPONENT_SEQUENCE_ID      IN NUMBER
,  V_TOP_INVENTORY_ITEM_ID	IN NUMBER
,  V_TOP_COMPONENT_CODE		IN VARCHAR2
,  V_CREATION_DATE_TIME		IN VARCHAR2
,  V_LAST_UPDATED_BY            IN NUMBER
,  V_RESULT			OUT NUMBER
                          )
IS
	DUMMY		NUMBER;
        DUMMY2		NUMBER;
        DUMMY3		NUMBER;
        DUMMY4		NUMBER;
	LOAD_BOM_RESULT NUMBER := 0;
	TEMP_QTY        NUMBER := 0;
	x               BOOLEAN;

BEGIN

 V_RESULT := 0;

 IF (V_FULL = 1) THEN
  V_RESULT := 1;
  RETURN;
 END IF;

 IF (V_LINE_TYPE_CODE = 'RETURN') THEN
  V_RESULT := 1;
  RETURN;
 END IF;

 IF (V_OPTION_FLAG = 0) THEN
  V_RESULT := 1;
  RETURN;
 END IF;

 SELECT  COUNT(*)
 INTO    DUMMY
 FROM    SO_LINES M
 WHERE   M.LINE_ID = V_LINK_TO_LINE_ID
 AND     MOD((V_ORDER_QTY
            - NVL(V_CANCELLED_QTY,0) - V_REQUESTED_CANCEL_QTY),
            (M.ORDERED_QUANTITY - nvl(M.CANCELLED_QUANTITY,0))) = 0;

 IF (DUMMY >= 1) THEN
  IF (V_ATO_FLAG = 1) THEN
   IF (V_TOP_COMPONENT_CODE is NULL) THEN
    V_RESULT := 1;
    RETURN;
   ELSE
    OE_CANCEL.LOAD_BOM(
	V_SO_ORGANIZATION_ID,
	V_TOP_INVENTORY_ITEM_ID,
	V_TOP_COMPONENT_CODE,
	V_CREATION_DATE_TIME,
	V_LAST_UPDATED_BY,
	LOAD_BOM_RESULT);
    END IF;
  ELSE
   V_RESULT := 1;
    RETURN;
  END IF;
 ELSE
  -- You must select a quantity that is a multiple of the parent quantity.
  x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_OPN_NOT_RATIO');
  V_RESULT := 0;
  RETURN;
 END IF;

 IF (LOAD_BOM_RESULT = 1) THEN

  	SELECT 	COUNT(*)
  	INTO   	DUMMY2
	FROM 	BOM_EXPLOSIONS
	WHERE  	TOP_BILL_SEQUENCE_ID = V_TOP_BILL_SEQUENCE_ID
	AND    	EXPLOSION_TYPE = 'OPTIONAL'
	AND    	PLAN_LEVEL >= 0
	AND    	EFFECTIVITY_DATE <= TO_DATE(
				    NVL(substr(V_CREATION_DATE_TIME, 1, 16),
				        TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI')),
				        'YYYY/MM/DD HH24:MI')
	AND    	DISABLE_DATE > TO_DATE(NVL(substr(V_CREATION_DATE_TIME, 1, 16),
				       TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI')),
				       'YYYY/MM/DD HH24:MI')
	AND 	COMPONENT_SEQUENCE_ID  = V_PARENT_COMPONENT_SEQUENCE_ID
	AND 	OPTIONAL = 2
	AND 	(V_ORDER_QTY - NVL(V_CANCELLED_QTY,0) - V_REQUESTED_CANCEL_QTY) = 0
	AND NOT EXISTS
		(SELECT	'X'
		FROM	SO_LINES
		WHERE 	LINK_TO_LINE_ID = V_LINK_TO_LINE_ID
		AND 	LINE_ID <> V_LINE_ID
		AND 	ORDERED_QUANTITY - NVL(CANCELLED_QUANTITY,0) > 0);

  IF (DUMMY2 >= 1) THEN
    -- You may not cancel the last option in this mandatory class.
   x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_LAST_OPT');
   V_RESULT := 0;
   RETURN;
  END IF;

  SELECT COUNT(*)
  INTO   DUMMY3
  FROM   BOM_EXPLOSIONS
  WHERE  TOP_BILL_SEQUENCE_ID = V_TOP_BILL_SEQUENCE_ID
  AND    EXPLOSION_TYPE = 'OPTIONAL'
  AND    PLAN_LEVEL >= 0
  AND    EFFECTIVITY_DATE <= TO_DATE(NVL(substr(V_CREATION_DATE_TIME, 1, 16),
				     TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI')),
				     'YYYY/MM/DD HH24:MI')
  AND    DISABLE_DATE > TO_DATE(NVL(substr(V_CREATION_DATE_TIME, 1, 16),
				    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI')),
				    'YYYY/MM/DD HH24:MI')
  AND    COMPONENT_SEQUENCE_ID  = V_COMPONENT_SEQUENCE_ID
  AND    OPTIONAL = 2
  AND    (V_ORDER_QTY - NVL(V_CANCELLED_QTY,0) - V_REQUESTED_CANCEL_QTY) = 0;


  IF ( DUMMY3 >= 1) THEN
   -- You may not cancel a mandatory class.
   x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_MAND_CLASS');
   V_RESULT := 0;
   RETURN;
  END IF;

  TEMP_QTY := V_ORDER_QTY - nvl(V_CANCELLED_QTY,0) - V_REQUESTED_CANCEL_QTY;

  IF(TEMP_QTY = 0) THEN
    V_RESULT := 1;
    RETURN;
  END IF;

  -- 'ORDERED QUANTITY OUT OF BOM RANGE'

  SELECT COUNT(*)
  INTO   DUMMY4
  FROM   BOM_EXPLOSIONS
  WHERE  TOP_BILL_SEQUENCE_ID = V_TOP_BILL_SEQUENCE_ID
  AND    EXPLOSION_TYPE = 'OPTIONAL'
  AND    PLAN_LEVEL >= 0
  AND    EFFECTIVITY_DATE <= TO_DATE(NVL(substr(V_CREATION_DATE_TIME, 1, 16),
				     TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI')),
				     'YYYY/MM/DD HH24:MI')
  AND    DISABLE_DATE > TO_DATE(NVL(substr(V_CREATION_DATE_TIME, 1, 16),
				    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI')),
				    'YYYY/MM/DD HH24:MI')
  AND    COMPONENT_SEQUENCE_ID = V_COMPONENT_SEQUENCE_ID
  AND    NVL(LOW_QUANTITY,0) <=
	(SELECT (V_ORDER_QTY - NVL(V_CANCELLED_QTY,0) - V_REQUESTED_CANCEL_QTY) /
        	(P.ORDERED_QUANTITY - NVL(P.CANCELLED_QUANTITY,0))
	FROM 	SO_LINES P
	WHERE 	P.LINE_ID = V_LINK_TO_LINE_ID);


  IF (DUMMY4 = 0) THEN
   -- You have gone below the minimum required quantity for this option.
   x :=OE_MSG.SET_MESSAGE_NAME('OE_CAN_ATO_LOW');
   V_RESULT := 0;
   RETURN;
  ELSE
   V_RESULT := 1;
   RETURN;
  END IF;
 ELSE
  V_RESULT := 0;
  RETURN;
 END IF;
END CHECK_MODEL_RATIOS;


END OE_CANCEL;

/
