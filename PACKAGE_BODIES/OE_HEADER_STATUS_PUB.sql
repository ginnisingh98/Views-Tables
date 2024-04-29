--------------------------------------------------------
--  DDL for Package Body OE_HEADER_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HEADER_STATUS_PUB" AS
/* $Header: OEXPHDSB.pls 120.0 2005/06/01 02:50:05 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME CONSTANT VARCHAR2(30) := 'OE_HEADER_STATUS_PUB';

/*---------------------------------------------
     PROCEDURE Get_Cancelled_Status (without date)

     This procedure will take a header_id and
     and check if the Order has been cancelled.
     If the order has been cancelled, it will return
     a value of 'Y' in x_result. Otherwise a value
     of 'N' will be returned.
----------------------------------------------- */

PROCEDURE Get_Cancelled_Status(
p_header_id IN NUMBER,
x_result  OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS

l_cancel_flag  VARCHAR2(1);

BEGIN

SELECT cancelled_flag
INTO l_cancel_flag
FROM oe_order_headers_all
WHERE header_id = p_header_id;

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
     the WF activity happened. If the order is not
     cancelled, we will return a null result date
----------------------------------------------- */

PROCEDURE Get_Cancelled_Status(
p_header_id IN NUMBER,
x_result  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date  OUT NOCOPY /* file.sql.39 change */ DATE)

IS

BEGIN

Get_Cancelled_Status(p_header_id => p_header_id, x_result => x_result);
IF x_result = 'Y' THEN
     SELECT end_date
     INTO x_result_date
     FROM wf_item_activity_statuses wias, wf_process_activities wpa
     WHERE wias.item_type = OE_GLOBALS.G_WFI_HDR
     AND wias.item_key = to_char(p_header_id)
     AND wias.process_activity = wpa.instance_id
	AND wpa.activity_name = 'CLOSE_HEADER';
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
     PROCEDURE Get_Booked_Status (without date)

     This procedure will take a header_id and return
     a 'Y' if the order has been booked, and return
     a 'N' if the order has not been booked.
----------------------------------------------- */

PROCEDURE Get_Booked_Status(
p_header_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
BEGIN

SELECT nvl(booked_flag, 'N')
INTO x_result
FROM oe_order_headers_all
WHERE header_id = p_header_id;

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Booked_Status'
	);
  END IF;
END Get_Booked_Status;


/*---------------------------------------------
     PROCEDURE Get_Booked_Status (with date)

     This is the overloaded version of Get_Booked_Status
     (without date). In addition to return a 'Y' or
     'N' for the booking status, it will also return
     the date the activity happened. If the activity
     has not happened, a null date will be returned.
----------------------------------------------- */

PROCEDURE Get_Booked_Status(
p_header_id	IN NUMBER,
x_result	OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date	OUT NOCOPY /* file.sql.39 change */ DATE)

IS
BEGIN

SELECT nvl(booked_flag, 'N'), booked_date
INTO x_result, x_result_date
FROM oe_order_headers_all
WHERE header_id = p_header_id;

Exception
  when others then
  IF OE_MSG_PUB.CHeck_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
	OE_MSG_PUB.Add_Exc_Msg
	(
	G_PKG_NAME,
	'Get_Booked_Status'
	);
  END IF;
END Get_Booked_Status;


/*---------------------------------------------
     PROCEDURE Get_Closed_Status (without date)

     This procedure will take a header_id and
     return a 'Y' if the header/order has been
     closed, and a 'N' if not.
----------------------------------------------- */

PROCEDURE Get_Closed_Status(
p_header_id IN NUMBER,
x_result  OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS

l_open_flag    VARCHAR2(1);

BEGIN

SELECT nvl(open_flag, 'Y')
INTO l_open_flag
FROM oe_order_headers_all
WHERE header_id = p_header_id;

-- we are returning Closed Status,
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

     This is the overloaded version of Get_Closed_Status
     (without date). In addition to return a 'Y' or 'N' for
     the header closure status, it will also return the
     date the activity happened. If the activity hasn't
     happened, a null result date will be returned.
----------------------------------------------- */

PROCEDURE Get_Closed_Status(
p_header_id IN NUMBER,
x_result  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
x_result_date  OUT NOCOPY /* file.sql.39 change */ DATE)

IS

BEGIN

Get_Closed_Status(p_header_id => p_header_id, x_result => x_result);
IF x_result = 'Y' THEN
     SELECT end_date
     INTO x_result_date
     FROM wf_item_activity_statuses wias, wf_process_activities wpa
     WHERE wias.item_type = OE_GLOBALS.G_WFI_HDR
     AND wias.item_key = to_char(p_header_id)
     AND wias.process_activity = wpa.instance_id
     AND wpa.activity_name = 'CLOSE_HEADER';
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
     'Get_Closed_Status'
     );
  END IF;
END Get_Closed_Status;


END OE_HEADER_STATUS_PUB;

/
