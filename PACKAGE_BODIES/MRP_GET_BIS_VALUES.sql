--------------------------------------------------------
--  DDL for Package Body MRP_GET_BIS_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_GET_BIS_VALUES" AS
/* $Header: MRPBISUB.pls 120.1 2005/09/20 13:15:28 ichoudhu noship $  */

-- ==============================================================
--   Function to calculate the forecast error
-- ==============================================================
FUNCTION forecast_error (p_forecast_qty IN NUMBER,
                        p_order_qty IN NUMBER) RETURN NUMBER IS

BEGIN

  IF (NVL(p_forecast_qty,0) = 0 AND NVL(p_order_qty,0) = 0) THEN
    RETURN 0;
  ELSIF NVL(p_forecast_qty,0) = 0 THEN
    RETURN 100;
  ELSIF NVL(p_order_qty,0) = 0 THEN
    RETURN 100;
  ELSE
    RETURN ABS(((p_forecast_qty - p_order_qty)/p_forecast_qty)*100);
  END IF;

END forecast_error;

-- ==============================================================
--   Function to determine the expected ship date of a late order
-- ==============================================================
FUNCTION expected_ship_date (p_demand_id IN NUMBER,
                                p_organization_id IN NUMBER,
                                p_compile_designator IN VARCHAR2)
RETURN NUMBER IS

  l_days        NUMBER;

  CURSOR MAX_LATE_CURSOR IS
  SELECT max(rec.new_schedule_date - peg2.demand_date)
  FROM mrp_recommendations rec,
        mrp_full_pegging peg1,
        mrp_full_pegging peg2
  WHERE peg1.demand_id = p_demand_id
    AND peg1.transaction_id = rec.transaction_id
    AND peg1.pegging_id = peg2.end_pegging_id
    AND peg2.organization_id = p_organization_id
    AND peg2.compile_designator = p_compile_designator
    AND peg1.organization_id = p_organization_id
    AND peg1.compile_designator = p_compile_designator;

BEGIN

  OPEN MAX_LATE_CURSOR;
  FETCH MAX_LATE_CURSOR INTO l_days;
  CLOSE MAX_LATE_CURSOR;

  RETURN l_days;

EXCEPTION

  WHEN OTHERS THEN

    RETURN 0;

END expected_ship_date;

END MRP_GET_BIS_VALUES;

/
