--------------------------------------------------------
--  DDL for Package WSH_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CORE" AUTHID CURRENT_USER AS
/* $Header: WSHCORES.pls 115.0 99/07/16 08:18:11 porting ship $ */



  -- Name	 item_flex_name
  -- Purpose	 converts inventory_item_id into its name
  -- Assumption  The id parameters are valid.
  -- Arguments
  --		 inventory_item_id
  --		 warehouse_id
  --		 RETURN VARCHAR    if name not found, '?' will be returned.
  --
  FUNCTION Item_Flex_Name(inventory_item_id IN NUMBER,
			  warehouse_id	  IN NUMBER) RETURN VARCHAR2;


  -- Name	 locator_flex_name
  -- Purpose	 converts locaotr_id into its name
  -- Assumption  The id parameters are valid.
  -- Arguments
  --		 locaotr_item_id
  --		 warehouse_id
  --		 RETURN VARCHAR    if name not found, '?' will be returned.
  --
  FUNCTION Locator_Flex_Name(locator_id 	IN NUMBER,
			     warehouse_id       IN NUMBER) RETURN VARCHAR2;


  -- Name	 generic_flex_name
  -- Purpose	 converts entity_id into its name
  -- Arguments
  --		entity_id
  --		warehouse_id
  --		app_name	(short app name; e.g. 'INV')
  --		k_flex_code	(key flexfield code; e.g., 'MSTK')
  --		struct_num	(structure number; e.g., 101)
  -- Assumption  The parameters are valid.
  --		 RETURN VARCHAR2    if name not found, '?' will be returned.
  FUNCTION generic_flex_name(
			entity_id	IN NUMBER,
			warehouse_id	IN NUMBER,
			app_name	IN VARCHAR2,
			k_flex_code	IN VARCHAR2,
			struct_num	IN NUMBER)
  RETURN VARCHAR2;


  -- Name	 shipper_address
  -- Purpose	 obtain the shipper's address information for the reports.
  -- Assumption  org_id exists, and the address is available.
  -- Input Argument
  --		 org_id
  -- Output Arguments (all are VARCHAR2(30))
  --             org_name
  --             address1
  --             address2
  --             address3
  --             city
  --             region (state)
  --             postal_code (zip)
  --             country
  --
  PROCEDURE  Shipper_Address(
               org_id      in  number,
	       org_name    out varchar2,
	       address1    out varchar2,
	       address2    out varchar2,
	       address3    out varchar2,
               city        out varchar2,
               region      out varchar2,
               postal_code out varchar2,
	       country     out varchar2);

  -- Name	 city_region_postal
  -- Purpose	 concatenates the three fields for the reports
  -- Input Arguments
  --             city
  --             region (state)
  --             postal_code (zip)
  -- RETURN VARCHAR2
  --
  FUNCTION  city_region_postal(
               city        in varchar2,
               region      in varchar2,
               postal_code in varchar2)
  RETURN VARCHAR2;

  -- define pragma so function can be used in selects
  PRAGMA  RESTRICT_REFERENCES (city_region_postal, WNDS, WNPS);

END WSH_CORE;

 

/
