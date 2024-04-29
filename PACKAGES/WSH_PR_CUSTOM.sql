--------------------------------------------------------
--  DDL for Package WSH_PR_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PR_CUSTOM" AUTHID CURRENT_USER AS
/* $Header: WSHPRCSS.pls 115.1 99/07/16 08:19:50 porting ship $ */

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
  RETURN BINARY_INTEGER;


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
  RETURN BINARY_INTEGER;


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
  RETURN BINARY_INTEGER;

PRAGMA RESTRICT_REFERENCES(Outstanding_Order_value, WNDS, WNPS);

END WSH_PR_CUSTOM;

 

/
