--------------------------------------------------------
--  DDL for Package WSH_PICK_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PICK_CUSTOM" AUTHID CURRENT_USER AS
/* $Header: WSHPRCUS.pls 115.1 2002/05/15 19:04:05 pkm ship    $ */

--
-- Package
--        WSH_PICK_CUSTOM
--
-- Purpose
--      This package contains user customizable routines for
--      Pick Release:
--       - Contains mechanism to compute order value
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

  FUNCTION Outstanding_Order_Value(
          p_header_id              IN   BINARY_INTEGER
  )
  RETURN BINARY_INTEGER;

PRAGMA RESTRICT_REFERENCES(Outstanding_Order_value, WNDS, WNPS);

END WSH_PICK_CUSTOM;

 

/
