--------------------------------------------------------
--  DDL for Package MRP_GET_BIS_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_GET_BIS_VALUES" AUTHID CURRENT_USER AS
/* $Header: MRPBISUS.pls 120.1 2005/09/20 13:15:07 ichoudhu noship $  */

FUNCTION forecast_error(p_forecast_qty IN NUMBER,
                        p_order_qty IN NUMBER) RETURN NUMBER;

FUNCTION expected_ship_date(p_demand_id IN NUMBER,
                                p_organization_id IN NUMBER,
                                p_compile_designator IN VARCHAR2) RETURN NUMBER;

END MRP_GET_BIS_VALUES;

 

/
