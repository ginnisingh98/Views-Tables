--------------------------------------------------------
--  DDL for Package Body WSH_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CORE" AS
/* $Header: WSHCOREB.pls 115.2 99/08/11 12:23:45 porting shi $ */


  -- Name	 item_flex_name
  -- Purpose	 converts inventory_item_id into its name
  -- Assumption  The id parameters are valid.
  -- Arguments
  --		 inventory_item_id
  --		 warehouse_id
  --		 RETURN VARCHAR    if name not found, '?' will be returned.
  FUNCTION item_flex_name(inventory_item_id IN NUMBER,
			  warehouse_id	  IN NUMBER)
  RETURN VARCHAR2
  IS
    name		VARCHAR(2000) := '?';
    result	BOOLEAN       := TRUE;
  BEGIN
    result := FND_FLEX_KEYVAL.validate_ccid(
		  appl_short_name=>'INV',
		  key_flex_code=>'MSTK',
		  structure_number=>101,
		  combination_id=>inventory_item_id,
		  data_set=>warehouse_id);
    IF result THEN
       name := FND_FLEX_KEYVAL.concatenated_values;
    END IF;
    RETURN name;
  END item_flex_name;


  -- Name	 locator_flex_name
  -- Purpose	 Converts Locator_id into its name
  -- Assumption  The id parameters are valid.
  --
  FUNCTION locator_flex_name(locator_id IN NUMBER,
			  warehouse_id	  IN NUMBER)
  RETURN VARCHAR2
  IS
    name		VARCHAR(2000) := '?';
    result	BOOLEAN       := TRUE;
  BEGIN
    result := FND_FLEX_KEYVAL.validate_ccid(
		  appl_short_name=>'INV',
		  key_flex_code=>'MTLL',
		  structure_number=>101,
		  combination_id=>locator_id,
		  data_set=>warehouse_id);
    IF result THEN
       name := FND_FLEX_KEYVAL.concatenated_values;
    END IF;
    RETURN name;
  END locator_flex_name;


  -- Name	 generic_flex_name
  -- Purpose	 converts entity_id into its name
  -- Arguments
  --		entity_id
  --		warehouse_id
  --		app_name	(short app name; e.g. 'INV')
  --		k_flex_code	(key flexfield code; e.g., 'MSTK')
  --		struct_num	(structure number; e.g., 101)
  -- Assumption  The parameters are valid.
  --		 RETURN VARCHAR2    if name not found, NULL will be returned.
  FUNCTION generic_flex_name(
			entity_id	IN NUMBER,
			warehouse_id	IN NUMBER,
			app_name	IN VARCHAR2,
			k_flex_code	IN VARCHAR2,
			struct_num	IN NUMBER)
  RETURN VARCHAR2
  IS
    name		VARCHAR(2000) := NULL;
    result	BOOLEAN       := TRUE;
  BEGIN
    result := FND_FLEX_KEYVAL.validate_ccid(
		  appl_short_name=>'INV',
		  key_flex_code=>k_flex_code,
		  structure_number=>struct_num,
		  combination_id=>entity_id,
		  data_set=>warehouse_id);
    IF result THEN
       name := FND_FLEX_KEYVAL.concatenated_values;
    END IF;
    RETURN name;
  END generic_flex_name;


  -- Name	 shipper_address
  -- Purpose	 obtain the shipper's address (ie the shipping warehouse).
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
	       country     out varchar2)
   IS

   CURSOR shipper(o_id NUMBER) IS
   select ou.name org_name,
       loc.address_line_1 ship_address1,
       loc.address_line_2 ship_address2,
       loc.address_line_3 ship_address3,
       loc.town_or_city   city,
       loc.region_2       region,
       loc.postal_code    postal_code,
       terr.territory_short_name country
    from   hr_organization_units ou,
           fnd_territories_VL terr,
           hr_locations_no_join loc
    where  ou.organization_id = o_id
    and    loc.location_id(+) = ou.location_id
    and    loc.country = terr.territory_code(+);

   BEGIN

      open shipper(org_id);
      fetch shipper into
	       org_name,
	       address1,
	       address2,
	       address3,
               city,
               region,
               postal_code,
	       country;
      close shipper;

   END;


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
  RETURN VARCHAR2
  IS
   c_r_p VARCHAR2(100);
  BEGIN

    IF    city IS NOT NULL AND region IS NOT NULL THEN
      c_r_p := city || ', ' || region || ' ' || postal_code;
    ELSIF city IS NOT NULL AND region IS     NULL THEN
      -- bug 958797 (from bug 944851): use city instead of c_r_p
      c_r_p := city ||                  ' ' || postal_code;
    ELSIF city IS     NULL AND region IS NOT NULL THEN
      c_r_p :=                 region || ' ' || postal_code;
    ELSIF city IS     NULL AND region IS     NULL THEN
      c_r_p := postal_code;
    END IF;

    RETURN c_r_p;

  END;

END WSH_CORE;

/
