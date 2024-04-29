--------------------------------------------------------
--  DDL for Package Body MRP_OE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_OE" AS
/* $Header: MRPPNOEB.pls 120.0 2005/05/27 18:07:44 appldev noship $ */

FUNCTION mrp_quantity(p_demand_id IN NUMBER) RETURN NUMBER IS

  CURSOR GET_MRP_QUANTITY IS
  SELECT NVL(new_schedule_quantity,0)
  FROM mrp_sales_order_updates u
  WHERE u.sales_order_id = p_demand_id
  AND   u.process_status = 5;

  l_quantity 		NUMBER;

BEGIN

  OPEN GET_MRP_QUANTITY;

  FETCH GET_MRP_QUANTITY INTO l_quantity;

  CLOSE GET_MRP_QUANTITY;

  RETURN l_quantity;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    RETURN 0;

END mrp_quantity;

FUNCTION mrp_date(p_demand_id IN NUMBER) RETURN DATE IS

  CURSOR GET_MRP_DATE IS
  SELECT new_schedule_date
  FROM mrp_sales_order_updates u
  WHERE u.sales_order_id = p_demand_id
  AND   u.process_status = 5;

  l_date 		DATE;

BEGIN

  OPEN GET_MRP_DATE;

  FETCH GET_MRP_DATE INTO l_date;

  CLOSE GET_MRP_DATE;

  RETURN l_date;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    RETURN NULL;

END mrp_date;

FUNCTION available_to_mrp(p_demand_id IN NUMBER) RETURN NUMBER IS

  CURSOR AVAIL IS
  SELECT DECODE(visible_demand_flag,'Y',1,2)
  FROM oe_order_lines_all oe
  WHERE line_id = p_demand_id;

  l_available_to_mrp		NUMBER := 1;

BEGIN

  OPEN AVAIL;
  FETCH AVAIL into l_available_to_mrp;
  CLOSE AVAIL;
  RETURN l_available_to_mrp;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    RETURN 1;

END available_to_mrp;

FUNCTION updated_flag(p_demand_id IN NUMBER) RETURN NUMBER IS

  CURSOR GET_UPDATED_FLAG IS
  SELECT '2'
  FROM mtl_demand_om_view demand
  WHERE ((EXISTS
	(SELECT NULL
	FROM 	mrp_sales_order_updates updates
	WHERE 	updates.sales_order_id = demand.demand_id
	AND	updates.old_schedule_date = demand.requirement_date
	AND 	updates.old_schedule_quantity = demand.primary_uom_quantity
	AND 	updates.previous_customer_id = demand.customer_id
	AND 	updates.previous_ship_id = demand.ship_to_site_use_id
	AND	updates.previous_bill_id = demand.bill_to_site_use_id
	AND	NVL(updates.current_demand_class, 'A') =
			NVL(demand.demand_class, 'A')
	AND 	updates.process_status <> IN_PROCESS))
	OR	demand.demand_source_type NOT IN
			(MTL_SALES_ORDER, MTL_INT_SALES_ORDER)
	OR	demand.customer_id IS NULL
	OR	demand.ship_to_site_use_id IS NULL
	OR	demand.bill_to_site_use_id IS NULL)
	AND	demand.demand_id = p_demand_id
        AND 	demand.parent_demand_id IS NULL;

  l_updated_flag		NUMBER := 1;

BEGIN
/*
  OPEN GET_UPDATED_FLAG;

  FETCH GET_UPDATED_FLAG into l_updated_flag;

  CLOSE GET_UPDATED_FLAG;
*/
  RETURN l_updated_flag;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    RETURN 1;

END updated_flag;

FUNCTION available_to_atp(p_demand_id IN NUMBER) RETURN NUMBER IS

  CURSOR AVAIL IS
  SELECT DECODE(visible_demand_flag,'Y',1,2)
  FROM oe_order_lines_all oe
  WHERE line_id = p_demand_id;

  l_available_to_atp		NUMBER := 1;

BEGIN

  OPEN AVAIL;
  FETCH AVAIL into l_available_to_atp;
  CLOSE AVAIL;
  RETURN l_available_to_atp;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    RETURN 1;

END available_to_atp;

FUNCTION  total_reserv_qty (p_demand_id IN NUMBER) RETURN NUMBER IS
   total_reservation_quantity NUMBER := 0;
BEGIN
   SELECT SUM(NVL(MD1.PRIMARY_UOM_QUANTITY,0))
	 INTO total_reservation_quantity
	 FROM mtl_demand MD1
	 WHERE
	 MD1.DEMAND_SOURCE_LINE = to_char(p_demand_id)
	 AND NVL(MD1.DEMAND_SOURCE_TYPE,2) IN (2,8,12)
     AND NVL(MD1.RESERVATION_TYPE,2) IN (2,3);

   RETURN total_reservation_quantity;
EXCEPTION

  WHEN NO_DATA_FOUND THEN

    RETURN 0;

END total_reserv_qty;

END MRP_OE;

/
