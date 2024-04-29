--------------------------------------------------------
--  DDL for Package Body OE_LINE_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_STATUS_PUB" AS
/* $Header: OEXPLNSB.pls 120.0 2005/05/31 23:01:56 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME CONSTANT VARCHAR2(30) := 'OE_LINE_STATUS_PUB';

/*---------------------------------------------
     PROCEDURE Get_Cancelled_Status (without date)

     This procedure will take a line_id and
     and check if the line has been cancelled.
     If the line has been cancelled, it will return
     a value of 'Y' in x_result. Otherwise a value
     of 'N' will be returned.
----------------------------------------------- */

PROCEDURE Get_Cancelled_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS

l_cancel_flag	VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

SELECT cancelled_flag
INTO l_cancel_flag
FROM oe_order_lines_all
WHERE line_id = p_line_id;

-- we are returning Line_Closed_Status,
-- so we return Y when open_flag is N
-- and return N when open_flag is Y

IF l_cancel_flag = 'Y' THEN
	x_result := 'Y';
ELSE
	x_result := 'N';
END IF;

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Cancelled_Status'
	);
  END IF;
End Get_Cancelled_Status;


/*---------------------------------------------
     PROCEDURE Get_Cancelled_Status (with date)

     This is the overloaded version, it will
     not only return the Y/N, but also the date
     the WF activity happened. If the line is not
     cancelled, we will return a null result date
----------------------------------------------- */

PROCEDURE Get_Cancelled_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE)

IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

Get_Cancelled_Status(p_line_id => p_line_id, x_result => x_result);
IF x_result = 'Y' THEN
     SELECT wias.end_date
     INTO x_result_date
     FROM wf_item_activity_statuses wias,
          wf_process_activities wpa
     WHERE wias.item_type = OE_GLOBALS.G_WFI_LIN
     AND wias.item_key = to_char(p_line_id)
     AND wias.process_activity = wpa.instance_id
     AND wpa.activity_name = 'CLOSE_LINE';

ELSE
	x_result_date := null;
END IF;

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Cancelled_Status'
	);
  END IF;
END Get_Cancelled_Status;

/*---------------------------------------------
     PROCEDURE Get_Closed_Status (without date)

     This procedure will take a line_id and
     and check if the line has been closed.
     If the line has been closed, it will return
     a value of 'Y' in x_result. Otherwise a value
     of 'N' will be returned.
----------------------------------------------- */

PROCEDURE Get_Closed_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS

l_open_flag	VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

SELECT nvl(open_flag, 'Y')
INTO l_open_flag
FROM oe_order_lines_all
WHERE line_id = p_line_id;

-- we are returning Line_Closed_Status,
-- so we return Y when open_flag is N
-- and return N when open_flag is Y

IF l_open_flag = 'Y' THEN
	x_result := 'N';
ELSE
	x_result := 'Y';
END IF;

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Closed_Status'
	);
  END IF;
END Get_Closed_Status;


/*---------------------------------------------
     PROCEDURE Get_Closed_Status (with date)

     This is the overloaded version, it will
     not only return the Y/N, but also the date
     the WF activity happened. If the line is not
     closed, we will return a null result date
----------------------------------------------- */

PROCEDURE Get_Closed_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE)

IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

Get_Closed_Status(p_line_id => p_line_id, x_result => x_result);
IF x_result = 'Y' THEN
	SELECT wias.end_date
	INTO x_result_date
	FROM wf_item_activity_statuses wias,
          wf_process_activities wpa
	WHERE wias.item_type = OE_GLOBALS.G_WFI_LIN
	AND wias.item_key = to_char(p_line_id)
     AND wias.process_activity = wpa.instance_id
     AND wpa.activity_name = 'CLOSE_LINE';

ELSE
	x_result_date := null;
END IF;

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Closed_Status'
	);
  END IF;
END Get_Closed_Status;

/*----------------------------------------------------------
     PROCEDURE Get_Purchase_Release_Status (without date)

     This procedure is the overloaded version of
     Get_Purchase_Release_Status (with date). It will
     ignore the date, and return a 'Y' or 'N' showing if
     the Purchase Release activity has happened. A 'N' will
     be returned if the activity is not in your flow.
------------------------------------------------------------ */

PROCEDURE Get_Purchase_Release_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS

l_result_date	DATE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

Get_Purchase_Release_Status(p_line_id => p_line_id, x_result => x_result, x_result_date => l_result_date);

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Purchase_Release_Status'
	);
  END IF;

END Get_Purchase_Release_Status;


/*----------------------------------------------------------
     PROCEDURE Get_Purchase_Release_Status (with date)

     This procedure will take a line_id and check if
     the Purchas Release workflow activity has happened.
     If it has happened, a value of 'Y' will be returned,
     otherwise a 'N' will be returned. Along with the Y/N,
     the date this activity happened will also be returned.
     If the activity doesn't exist in your workflow,
     a 'N' result and a null result date will be returned.
------------------------------------------------------------ */

PROCEDURE Get_Purchase_Release_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE)

IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

SELECT nvl(wias.activity_result_code, 'N'), wias.end_date
INTO x_result, x_result_date
FROM wf_item_activity_statuses wias,
     wf_process_activities wpa
WHERE wias.item_type = OE_GLOBALS.G_WFI_LIN
AND wias.item_key = to_char(p_line_id)
AND wias.process_activity = wpa.instance_id
AND wpa.activity_name = 'PUR_REL_THE_LINE';

IF x_result = OE_GLOBALS.G_WFR_COMPLETE THEN
	x_result := 'Y';
ELSE
 	x_result := 'N';
	x_result_date := null;
-- if activity has not complete, we will return a null end date
END IF;

EXCEPTION

-- when the activity is not in your flow
  WHEN NO_DATA_FOUND THEN
  x_result := 'N';
	  x_result_date := null;


	  WHEN OTHERS THEN
	  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
		OE_MSG_PUB.Add_Exc_Msg
		(
		G_PKG_NAME,
		'Get_Purchase_Release_Status'
		);
	  END IF;

	END Get_Purchase_Release_Status;

/*---------------------------------------------
     PROCEDURE Get_Ship_Status (without date)

     This procedure will take a line_id and
     and check if the line has been shipped.
     If the line has been shipped, it will return
     a value of 'Y' in x_result. Otherwise a value
     of 'N' will be returned.
----------------------------------------------- */

PROCEDURE Get_Ship_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS

	l_shipped_quantity	NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	SELECT nvl(shipped_quantity, 0)
	INTO l_shipped_quantity
	FROM oe_order_lines_all
	WHERE line_id = p_line_id;

-- we are returning Line_shipped_Status,
-- so we return Y when line is shipped
-- and return N when line is not shipped.

	IF l_shipped_quantity = 0 THEN
		x_result := 'N';
	ELSE
		x_result := 'Y';
	END IF;

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Ship_Status'
	);
  END IF;
END Get_Ship_Status;


/*---------------------------------------------
     PROCEDURE Get_Ship_Status (with date)

     This is the overloaded version, it will
     not only return the Y/N, but also the date
     the WF activity happened. If the line is not
     closed, we will return a null result date
----------------------------------------------- */

PROCEDURE Get_Ship_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE)

IS
	l_shipped_quantity	NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

--	Get_Ship_Status(p_line_id => p_line_id, x_result => x_result);
--	IF x_result = 'Y' THEN
--		SELECT end_date
--		INTO x_result_date
--		FROM wf_item_activity_statuses
--		WHERE item_type = OE_GLOBALS.G_WFI_LIN
--		AND item_key = p_line_id
--		AND process_activity IN (SELECT wpa.instance_id
--  	                      FROM  wf_process_activities wpa
-- 	                      WHERE wpa.activity_item_type = OE_GLOBALS.G_WFI_LIN
--	                      AND wpa.activity_name = 'SHIP_LINE');
--	ELSE
--		x_result_date := null;
--	END IF;

	SELECT nvl(shipped_quantity, 0),actual_shipment_date
	INTO l_shipped_quantity,x_result_date
	FROM oe_order_lines_all
	WHERE line_id = p_line_id;

-- we are returning Line_shipped_Status,
-- so we return Y when line is shipped
-- and return N when line is not shipped.

	IF l_shipped_quantity = 0 THEN
		x_result := 'N';
		x_result_date := null;
	ELSE
		x_result := 'Y';
	END IF;


Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Ship_Status'
	);
  END IF;
END Get_Ship_Status;

/*---------------------------------------------
     PROCEDURE Get_Pick_Status (without date)

     This procedure will take a line_id and
     and check if the line has been picked.
     If the line has been picked, it will return
     a value of 'Y' in x_result. If the line is not picked
     it will return 'N', if the line is partially picked it will return 'P'
----------------------------------------------- */

PROCEDURE Get_Pick_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS

l_pick_status	VARCHAR2(1);
l_picked_quantity	NUMBER;
l_picked_quantity_uom	VARCHAR2(3);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


	Get_Pick_Status
	(
		p_line_id	=> p_line_id,
		x_result	=> l_pick_status,
		x_picked_quantity	=> l_picked_quantity,
		x_picked_quantity_uom	=> l_picked_quantity_uom
	);

	x_result := l_pick_status;
-- we are returning Line_Pick_Status,
-- so we return Y when line is picked
-- and return N when line is not picked and P when the line is partially picked.

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Pick_Status'
	);
  END IF;
END Get_Pick_Status;

/*---------------------------------------------
     PROCEDURE Get_Pick_Status (with quantity)

     This procedure will take a line_id and
     and check if the line has been picked.
     If the line has been picked, it will return
     a value of 'Y' in x_result and the picked quantity. Otherwise a value
     of 'N' will be returned.
----------------------------------------------- */

PROCEDURE Get_Pick_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_picked_quantity	OUT NOCOPY /* file.sql.39 change */ NUMBER,
x_picked_quantity_uom	OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS

	CURSOR	c_pick IS
	SELECT	PICK_STATUS, REQUESTED_QUANTITY, REQUESTED_QUANTITY_UOM
	FROM		WSH_DELIVERY_LINE_STATUS_V
	WHERE	SOURCE_CODE = 'OE'
	AND		SOURCE_LINE_ID = p_line_id;

	l_pick_status			VARCHAR2(1) := 'X';
	l_picked_quantity		NUMBER := 0;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	FOR l_pick_data	IN	c_pick LOOP

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'PICK STATUS/QUANTITY :'||L_PICK_DATA.PICK_STATUS||'/'||TO_CHAR ( L_PICK_DATA.REQUESTED_QUANTITY ) , 2 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'L_PICK_STATUS : '||L_PICK_STATUS , 2 ) ;
		END IF;
		IF	l_pick_data.pick_status = 'Y'  THEN
			IF	l_pick_status	= 'X' OR
				l_pick_status  = 'Y' THEN
				l_pick_status := 'Y';
			ELSE
				l_pick_status := 'P';
			END IF;
			l_picked_quantity := l_picked_quantity + l_pick_data.requested_quantity;
			x_picked_quantity_uom := l_pick_data.requested_quantity_uom;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'PICK STATUS/QUANTITY IN THE IF :'||L_PICK_STATUS||'/'||TO_CHAR ( L_PICKED_QUANTITY ) , 2 ) ;
			END IF;
		ELSIF	l_pick_data.pick_status <> 'Y' THEN
				IF 	l_pick_status = 'N' OR
					l_pick_status = 'X' THEN
					l_pick_status := 'N';
				ELSE
					l_pick_status := 'P';
				END IF;
		END IF;

	END LOOP;

-- we are returning Line_Pick_Status,
-- so we return Y when line is picked
-- and return N when line is not picked

	IF	l_pick_status = 'X' THEN
		x_result := 'N';
	ELSE
		x_result := l_pick_status;
	END IF;

	x_picked_quantity := l_picked_quantity;

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Pick_Status'
	);
  END IF;
END Get_Pick_Status;

/*---------------------------------------------
     PROCEDURE Get_Received_Status (without date)

     This procedure will take a line_id and
     check if the line has been received.
     If the line has been received, it will return a value of 'Y'
     in x_result. Otherwise a value of 'N' will be returned.
----------------------------------------------- */

PROCEDURE Get_Received_Status(
p_line_id IN NUMBER,
x_result  OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS
l_received_quantity NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


	SELECT nvl(shipped_quantity, 0)
	INTO l_received_quantity
	FROM oe_order_lines_all
	WHERE line_id = p_line_id;

-- we are returning Line_Receive_Status,
-- so we return Y when line is received
-- and return N when line is not received

	IF l_received_quantity = 0 THEN
		x_result := 'N';
	ELSE
		x_result := 'Y';
	END IF;

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
     OE_MSG_PUB.Add_Exc_Msg
     (
     G_PKG_NAME,
     'Get_Received_Status'
     );
  END IF;
END Get_Received_Status;


/*---------------------------------------------
     PROCEDURE Get_Received_Status (with date)

     This is the overloaded version of Get_Received_Status
     (without date). In addition to return a 'Y' or 'N' for
     the line received status, it will also return the
     date the activity happened. If the activity hasn't
     happened, a null result date will be returned.
----------------------------------------------- */

PROCEDURE Get_Received_Status(
p_line_id IN NUMBER,
x_result  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date  OUT NOCOPY /* file.sql.39 change */ DATE)

IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

Get_Received_Status(p_line_id => p_line_id, x_result => x_result);
IF x_result = 'Y' THEN
     SELECT wias.end_date
     INTO x_result_date
     FROM wf_item_activity_statuses wias,
          wf_process_activities wpa
     WHERE wias.item_type = OE_GLOBALS.G_WFI_LIN
     AND wias.item_key = to_char(p_line_id)
     AND wias.process_activity = wpa.instance_id
     AND wpa.activity_name = 'RMA_WAIT_FOR_RECEIVING';
ELSE
     x_result_date := null;
END IF;

Exception
  when others then
  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
     OE_MSG_PUB.Add_Exc_Msg
     (
     G_PKG_NAME,
     'Get_Received_Status'
     );
  END IF;
END Get_Received_Status;

/*---------------------------------------------
     PROCEDURE Get_invoiced_Status (without date)

     This procedure will take a line_id and
     and check if the line has been invoiced.
     If the line has been invoiced, it will return
     a value of 'Y' in x_result. Otherwise a value
     of 'N' will be returned.
----------------------------------------------- */

PROCEDURE Get_Invoiced_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS

l_invoice_interface_status	VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

SELECT invoice_interface_status_code
INTO l_invoice_interface_status
FROM oe_order_lines_all
WHERE line_id = p_line_id;

-- return Y when invoice_interface_status_code is YES
-- and return N otherwise (for 'NO', 'PARTIAL' and 'NOT_ELIGIBLE')

IF l_invoice_interface_status = 'YES' THEN
	x_result := 'Y';
ELSE
	x_result := 'N';
END IF;

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Invoiced_Status'
	);
  END IF;
End Get_Invoiced_Status;


/*---------------------------------------------
     PROCEDURE Get_Invoiced_Status (with date)

     This is the overloaded version, it will
     not only return the Y/N, but also the date
     the WF activity happened. If the line is not
     invoiced, we will return a null result date
----------------------------------------------- */

PROCEDURE Get_Invoiced_Status(
p_line_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE)

IS
l_count NUMBER;
l_header_id NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

Get_Invoiced_Status(p_line_id => p_line_id, x_result => x_result);
IF x_result = 'Y' THEN

  BEGIN
     SELECT wias.end_date
     INTO x_result_date
     FROM wf_item_activity_statuses wias,
          wf_process_activities wpa
     WHERE wias.item_type = OE_GLOBALS.G_WFI_LIN
     AND wias.item_key = to_char(p_line_id)
     AND wias.process_activity = wpa.instance_id
     AND wpa.activity_name = 'INVOICE_INTERFACE';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      SELECT header_id
      INTO l_header_id
      FROM oe_order_lines_all
      WHERE line_id = p_line_id;

      SELECT wias.end_date
      INTO x_result_date
      FROM wf_item_activity_statuses wias,
           wf_process_activities wpa
      WHERE wias.item_type = OE_GLOBALS.G_WFI_HDR
        AND wias.item_key = l_header_id
        AND wias.process_activity = wpa.instance_id
        AND wpa.activity_name = 'HEADER_INVOICE_INTERFACE';
  END;
ELSE
	x_result_date := null;
END IF;

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Invoiced_Status'
	);
  END IF;
END Get_Invoiced_Status;


FUNCTION Get_Line_Status(
 p_line_id               IN      NUMBER
,p_flow_status_code      IN      VARCHAR2)
RETURN VARCHAR2
IS
  l_flow_status_code       VARCHAR2(80);
  l_flow_meaning           VARCHAR2(80);
  released_count           NUMBER;
  total_count              NUMBER;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN


    IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add('Entering OE_LINE_STATUS_PUB.Get_Line_Status...',1);
       OE_DEBUG_PUB.Add('Flow Status Code:'||p_flow_status_code,1);
    END IF;

    l_flow_status_code  :=  p_flow_status_code;

    IF p_flow_status_code is null THEN
       SELECT  flow_status_code
         INTO  l_flow_status_code
         FROM  oe_order_lines
        WHERE  line_id=p_line_id;
    END IF;

         IF l_flow_status_code <> 'AWAITING_SHIPPING' AND
            l_flow_status_code <> 'PRODUCTION_COMPLETE' AND
            l_flow_status_code <> 'PICKED' AND
            l_flow_status_code <> 'PICKED_PARTIAL' AND
            l_flow_status_code <> 'PO_RECEIVED'
         THEN
            SELECT meaning
            INTO l_flow_meaning
            FROM fnd_lookup_values lv
            WHERE lookup_type = 'LINE_FLOW_STATUS'
            AND lookup_code = l_flow_status_code
            AND LANGUAGE = userenv('LANG')
            AND VIEW_APPLICATION_ID = 660
            AND SECURITY_GROUP_ID =
                fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                 lv.view_application_id);

         /* status is AWAITING_SHIPPING or PRODUCTION_COMPLETE etc.
            get value from shipping table */
         ELSE

            -- fix for 3696124 begins
            --SELECT sum(decode(released_status, 'Y', 1, 0)), sum(1)
            SELECT sum(decode(released_status, 'Y', 1, 'C', 1, 0)), sum(1)
            -- fix for 3696124 ends
            INTO released_count, total_count
            FROM wsh_delivery_details
            WHERE source_line_id   =  p_line_id
            AND   source_code      = 'OE'
            AND   released_status  <> 'D';

            IF released_count = total_count THEN
             SELECT meaning
             INTO l_flow_meaning
             FROM fnd_lookup_values lv
             WHERE lookup_type = 'LINE_FLOW_STATUS'
             AND lookup_code = 'PICKED'
             AND LANGUAGE = userenv('LANG')
             AND VIEW_APPLICATION_ID = 660
             AND SECURITY_GROUP_ID =
                  fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                   lv.view_application_id);

            ELSIF released_count < total_count and released_count <> 0 THEN
             SELECT meaning
             INTO l_flow_meaning
             FROM fnd_lookup_values lv
             WHERE lookup_type = 'LINE_FLOW_STATUS'
             AND lookup_code = 'PICKED_PARTIAL'
             AND LANGUAGE = userenv('LANG')
             AND VIEW_APPLICATION_ID = 660
             AND SECURITY_GROUP_ID =
                  fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                   lv.view_application_id);
            ELSE
             SELECT meaning
             INTO l_flow_meaning
             FROM fnd_lookup_values lv
             WHERE lookup_type = 'LINE_FLOW_STATUS'
             AND lookup_code = l_flow_status_code
             AND LANGUAGE = userenv('LANG')
             AND VIEW_APPLICATION_ID = 660
             AND SECURITY_GROUP_ID =
                  fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                   lv.view_application_id);
            END IF;
         END IF;

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Exiting Get_Line_Status:'||l_flow_meaning,1);
         END IF;

       RETURN l_flow_meaning;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
        Null;
   WHEN TOO_MANY_ROWS THEN
        Null;
   WHEN OTHERS THEN
        Null;
END Get_Line_Status;

END OE_LINE_STATUS_PUB;

/
