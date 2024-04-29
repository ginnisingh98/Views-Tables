--------------------------------------------------------
--  DDL for Package WSH_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PARAMETERS_PVT" AUTHID CURRENT_USER as
/* $Header: WSHUPRMS.pls 115.0 99/07/16 08:23:26 porting ship $ */
--
-- Package
--   WSH_PARAMETERS_PVT
-- Purpose
--   Contains common routines to fetch and store parameter values
--   from wsh_parameters table
-- History
--   10-SEP-96	ANEOGI	Created
--

  --
  -- PUBLIC VARIABLES
  --

  --
  -- PUBLIC FUNCTIONS
  --

  -- Name
  --   get_param_value
  -- Purpose
  --   Optionally fetches row from wsh_parameters table and pass
  --   value of the given parameter
  -- Arguments
  --   organization_id (Oraginization_ID in wsh_parameters table)
  --   param_name IN VARCHAR2
  --   param_value OUT VARCHAR2/NUMBER

  PROCEDURE get_param_value( x_organization_id IN NUMBER,
			     param_name IN VARCHAR2,
			     param_value OUT VARCHAR2 );

  PROCEDURE get_param_value_num( x_organization_id IN NUMBER,
			         param_name IN VARCHAR2,
			         param_value OUT NUMBER );


END WSH_PARAMETERS_PVT;

 

/
