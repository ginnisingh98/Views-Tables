--------------------------------------------------------
--  DDL for Package Body OE_SO_ATO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SO_ATO" AS
/* $Header: oesoatob.pls 115.5 99/07/16 08:28:09 porting ship  $ */


PROCEDURE QUERY_ATTRIBUTES(
			x_header_id 			IN 	NUMBER,
			x_line_id 			IN 	NUMBER,
			x_warehouse_id			IN	NUMBER,
			x_inventory_item_id		IN	NUMBER,
			x_organization_id		IN	NUMBER,
			x_order_number			IN	NUMBER,
			x_order_type			IN	VARCHAR2,
			x_s27				IN OUT	NUMBER,
			x_schato_allowed		OUT	VARCHAR2,
			x_configuration_item_id 	IN OUT	NUMBER,
			x_config_item_description	OUT	VARCHAR2,
			x_config_line_detail_id		OUT	NUMBER,
			x_configured_quantity		OUT	NUMBER,
			x_demand_source_header_id	OUT	NUMBER,
			x_demand_source_delivery	OUT	NUMBER,
			x_user_delivery			OUT	VARCHAR2,
			x_reserved_quantity		OUT	NUMBER,
			x_mfg_action			OUT 	VARCHAR2,
			x_mfg_result			OUT	VARCHAR2,
			x_action_date			OUT	VARCHAR2,
			x_creation_date_time		OUT	VARCHAR2) IS
l_number_of_config_details 	NUMBER := 0;
l_reserved_quantity	 	NUMBER := 0;
l_supply_reserved_quantity 	NUMBER := 0;
l_schato_eligible		NUMBER := 0;
l_configured_quantity		NUMBER := 0;
l_demand_source_header_id	NUMBER := 0;
LINE_UNDEMANDED			EXCEPTION;
SCHATO_NOT_ALLOWED		EXCEPTION;

BEGIN


SELECT COUNT(1),
       SUM(DECODE(SCHEDULE_STATUS_CODE, 'RESERVED', QUANTITY, 0)),
       SUM(DECODE(SCHEDULE_STATUS_CODE, 'SUPPLY RESERVED', QUANTITY, 0)),
       SUM(Quantity)
INTO   l_number_of_config_details,
       l_reserved_quantity,
       l_supply_reserved_quantity,
       l_configured_quantity
FROM   SO_LINE_DETAILS
WHERE  LINE_ID = x_line_id
AND    CONFIGURATION_ITEM_FLAG = 'Y';




IF l_number_of_config_details = 0 THEN

  x_s27 := 4;

  SELECT DECODE(COUNT(1), 0, 0, 4)
  INTO x_s27
  FROM SO_LINE_DETAILS
  WHERE LINE_ID = x_line_id
  AND SCHEDULE_STATUS_CODE = 'DEMANDED';

ELSIF l_reserved_quantity = 0 THEN

  IF l_supply_reserved_quantity = 0 THEN
    x_s27 := 23;
  ELSE
    x_s27 := 21;
  END IF;

ELSE
  x_s27 := 20;
END IF;


BEGIN

  SELECT sales_order_id
  INTO   l_demand_source_header_id
  FROM   mtl_sales_orders mso
  WHERE  segment1 = To_Char(x_order_number)
  AND    segment2 = x_order_type
  AND    segment3 = FND_PROFILE.Value_Specific('SO_SOURCE_CODE');

EXCEPTION
	When NO_DATA_FOUND then NULL;
	When OTHERS then
	NULL;
END;


  x_demand_source_header_id := l_demand_source_header_id;



BEGIN

  SELECT INVENTORY_ITEM_ID, MIN(LINE_DETAIL_ID)
  INTO   x_configuration_item_id, x_config_line_detail_id
  FROM   SO_LINE_DETAILS S
  WHERE  S.LINE_ID = x_line_id
  AND  CONFIGURATION_ITEM_FLAG = 'Y'
  GROUP BY INVENTORY_ITEM_ID;

  SELECT DESCRIPTION
  INTO  x_config_item_description
  FROM   MTL_SYSTEM_ITEMS M
  WHERE  M.INVENTORY_ITEM_ID = x_configuration_item_id
  AND    M.ORGANIZATION_ID = NVL(x_warehouse_id, x_organization_id);

EXCEPTION
  When NO_DATA_FOUND then
	NULL;
  When OTHERS then
	NULL;
END;

SELECT DEMAND_SOURCE_DELIVERY, USER_DELIVERY
INTO   x_demand_source_delivery,
       x_user_delivery
FROM   MTL_DEMAND
WHERE  INVENTORY_ITEM_ID = x_inventory_item_id
AND    DEMAND_SOURCE_TYPE = 2
AND    DEMAND_SOURCE_HEADER_ID = l_demand_source_header_id
AND    DEMAND_SOURCE_LINE = x_line_id
AND    ORGANIZATION_ID = NVL(x_warehouse_id, x_organization_id)
AND    ROWNUM = 1;
/* Added the above line to fix the bug 891551/700134 */

BEGIN
  SELECT sum(wip_completed_quantity)
  into x_reserved_quantity
  from so_line_details
  where line_id = x_line_id
  and   inventory_item_id = x_configuration_item_id;
EXCEPTION
  When NO_DATA_FOUND then
	NULL;
  When OTHERS then
	NULL;
END;

SELECT TO_CHAR(CREATION_DATE,'YYYY/MM/DD HH24:MI')
INTO x_creation_date_time
FROM SO_LINES
WHERE LINE_ID = x_line_id;


SELECT 	a.name, r.name, to_char(l.s27_date, 'YYYY/MM/DD HH24:MI')
INTO	x_mfg_action, x_mfg_result, x_action_date
FROM	SO_ACTIONS A,
	SO_RESULTS R,
	SO_LINES   L
WHERE
	L.LINE_ID	= x_line_id
AND	A.RESULT_TABLE  = 'SO_LINES'
AND	R.RESULT_ID     = L.S27
AND	A.RESULT_COLUMN = 'S27';

IF x_s27 = 0 THEN
  x_schato_allowed := 'NO_DEMAND';
  Raise LINE_UNDEMANDED;
END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  NULL;
	WHEN LINE_UNDEMANDED THEN
	  FND_MESSAGE.set_name('OE', 'SO_ATO_LINE_UNDEMANDED');
	  APP_EXCEPTION.Raise_Exception;
	WHEN SCHATO_NOT_ALLOWED THEN
	  FND_MESSAGE.set_name ('OE', 'SO_ATO_LINE_UNDEMANDED');
	  APP_EXCEPTION.Raise_Exception;
	WHEN OTHERS THEN raise;

END QUERY_ATTRIBUTES;

END OE_SO_ATO;

/
