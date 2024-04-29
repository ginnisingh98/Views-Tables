--------------------------------------------------------
--  DDL for Package Body WSH_PR_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PR_CUSTOM" AS
/* $Header: WSHPRCSB.pls 115.2 99/07/16 08:19:47 porting ship $ */

--
-- Package
--   	WSH_PR_PICKING_CUSTOM
--
-- Purpose
--      This package contains user customizable routines for
--      Pick Release:
--       - Contains mechanism to compute order value
--       - Contains mechanism to reorder picking lines
--
-- History
--      20-AUG-96    RSHIVRAM    Created
--

  --
  -- PACKAGE CONSTANTS
  --

	SUCCESS			CONSTANT  BINARY_INTEGER := 0;
	FAILURE			CONSTANT  BINARY_INTEGER := -1;
	CUSTOM_NUMBER_LINES	CONSTANT  BINARY_INTEGER := -1;



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
  --   - value of order
  --   - 0 if failure
  --
  -- Notes
  --

  FUNCTION Outstanding_Order_Value(
		p_header_id			IN	BINARY_INTEGER
  )
  RETURN BINARY_INTEGER IS

  order_value	BINARY_INTEGER;

  BEGIN

	SELECT SUM(NVL(L.ORDERED_QUANTITY,0) * NVL(L.SELLING_PRICE,0))
	INTO order_value
	FROM SO_HEADERS_ALL H,
	     SO_LINES_ALL L
	WHERE H.HEADER_ID = p_header_id
	AND   L.HEADER_ID = H.HEADER_ID;

	RETURN order_value;

	EXCEPTION
	  WHEN OTHERS THEN
	    RETURN 0;

  END Outstanding_Order_Value;

  --
  -- Name
  --   FUNCTION Process_lines
  --
  -- Purpose
  --   This functions return the maximum number of lines
  --   pick release will fetch at a time to process
  --
  -- Return Values
  --   - number of lines
  --   - -1 not specified, use default
  --
  -- Notes
  --

  FUNCTION Process_Lines
  RETURN BINARY_INTEGER IS
  BEGIN
      RETURN 20;
  END;


/* Not supported yet */
  --
  -- Name
  --   FUNCTION Reorder_Picking_Line
  --
  -- Purpose
  --   This function reorders picking lines for a given batch.
  --
  -- Return Values
  --  -1 => Failure
  --   0 => Success
  --
  -- Notes
  --

  FUNCTION Reorder_Picking_Line(
		p_batch_id			IN	BINARY_INTEGER
  )
  RETURN BINARY_INTEGER IS

  BEGIN

    null;

  END Reorder_Picking_Line;


END WSH_PR_CUSTOM;

/
