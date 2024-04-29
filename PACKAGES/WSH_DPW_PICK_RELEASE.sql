--------------------------------------------------------
--  DDL for Package WSH_DPW_PICK_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DPW_PICK_RELEASE" AUTHID CURRENT_USER AS
/* $Header: WSHDPPRS.pls 115.0 99/07/16 08:18:59 porting ship $ */


  --
  -- Name
  --   FUNCTION Launch_Pick_Release
  --
  -- Purpose
  --   This function launches Pick Release program from Departure
  --   Planning Workbench Form
  --   - It gets the default shipping parameters for Pick Release
  --   - Creates a Pickinmg Batch
  --   - Launches the Pick Release Concurrent Program
  --   - Places error messages in FND message stack
  --
  -- Arguments
  --   p_departure_id       - departure to release
  --   p_delivery           - delivery to release
  --   p_warehouse	    - warehouse to release from
  --   p_request_id
  --
  -- Return Values
  --   Request ID of concurrent program
  --
  --
  -- Notes
  --

  FUNCTION Launch_Pick_Release( p_departure_id IN  NUMBER,
				p_delivery_id  IN  NUMBER,
				p_warehouse_id IN  NUMBER) RETURN NUMBER;

END WSH_DPW_PICK_RELEASE;

 

/
