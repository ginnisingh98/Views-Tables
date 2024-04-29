--------------------------------------------------------
--  DDL for Package Body WSH_PICK_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PICK_CUSTOM" AS
/* $Header: WSHPRCUB.pls 115.2 2002/08/13 22:43:25 nparikh ship $ */

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

  --
  -- Name
  --   FUNCTION Outstanding_Order_Value
  --
  -- Purpose
  --   This functions calculates the value of the order, which
  --   is used in the order by clause for releasing lines.
  --
  -- Arguments
  --   p_header_id
  --
  -- Return Values
  --   x_return_status
  --   -  value of order
  --   - 0 if failure
  --
  -- Notes
  --

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_PICK_CUSTOM';
  --
  FUNCTION Outstanding_Order_Value(
          p_header_id              IN   BINARY_INTEGER
  )
  RETURN BINARY_INTEGER IS

     l_order_value  BINARY_INTEGER;

--
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'OUTSTANDING_ORDER_VALUE';
--
  BEGIN

     --
     SELECT SUM(NVL(L.ORDERED_QUANTITY,0) * NVL(L.UNIT_SELLING_PRICE,0))
     INTO l_order_value
     FROM OE_ORDER_HEADERS_ALL H,
          OE_ORDER_LINES_ALL L
     WHERE H.HEADER_ID = p_header_id
     AND   L.HEADER_ID = H.HEADER_ID;

     --
     RETURN l_order_value;

     EXCEPTION
       WHEN OTHERS THEN
         --
         RETURN 0;

--
  END Outstanding_Order_Value;

END WSH_PICK_CUSTOM;

/
