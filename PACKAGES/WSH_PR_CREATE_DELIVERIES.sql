--------------------------------------------------------
--  DDL for Package WSH_PR_CREATE_DELIVERIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PR_CREATE_DELIVERIES" AUTHID CURRENT_USER AS
/* $Header: WSHPRDLS.pls 115.0 99/07/16 08:19:56 porting ship $ */

--
-- Package
--   	WSH_PR_CREATE_DELIVERIES
--
-- Purpose
--

  --
  -- PACKAGE TYPES
  --
        TYPE delRecTyp IS RECORD (
                header_id                       BINARY_INTEGER,
		ship_to_site_use_id             BINARY_INTEGER,
		ship_method_code		VARCHAR2(30),
		customer_id			BINARY_INTEGER,
		fob_code			VARCHAR2(30),
		freight_terms_code		VARCHAR2(30),
		currency_code			VARCHAR2(15),
		delivery_id			BINARY_INTEGER
	);

	TYPE delRecTabTyp IS TABLE OF delRecTyp INDEX BY BINARY_INTEGER;

  --
  -- PUBLIC VARIABLES
  --
	delivery_table				delRecTabTyp;

  --
  -- PUBLIC FUNCTIONS/PROCEDURES
  --

  --
  -- Name
  --   FUNCTION Init
  --
  -- Purpose
  --   Initializes the package
  --
  -- Return Values
  --  -1 => Failure
  --   0 => Success
  --

  FUNCTION Init
  RETURN BINARY_INTEGER;

  --
  -- Name
  --   FUNCTION Get_Delivery
  --
  -- Purpose
  --   Gets the delivery_id to be used in autocreate deliveries when
  --   inserting picking line details
  --
  -- Arguments
  --   p_header_id		=> order header id
  --   p_ship_to_site_use_id	=> ship to site use id (ultimate ship to)
  --   p_ship_method_code	=> ship method (freight carrier)
  --
  -- Return Values
  --  -1 => Failure
  --   others => delivery_id
  --

  FUNCTION Get_Delivery(
	p_header_id		IN		BINARY_INTEGER,
	p_ship_to_site_use_id	IN		BINARY_INTEGER,
	p_ship_method_code	IN		VARCHAR2,
	p_organization_id	IN		BINARY_INTEGER
  )
  RETURN BINARY_INTEGER;

END WSH_PR_CREATE_DELIVERIES;

 

/
