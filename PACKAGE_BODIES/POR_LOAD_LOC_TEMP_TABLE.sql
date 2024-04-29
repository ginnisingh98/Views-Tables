--------------------------------------------------------
--  DDL for Package Body POR_LOAD_LOC_TEMP_TABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_LOAD_LOC_TEMP_TABLE" as
/* $Header: PORLLCTB.pls 115.5 2001/07/12 11:41:50 pkm ship        $ */

PROCEDURE insert_update_loc_temp_table (
        x_location_code IN VARCHAR2,
	x_business_grp_name IN VARCHAR2,
        x_effective_date IN DATE,
	x_description  IN VARCHAR2,
        x_address_style IN VARCHAR2,
        x_address_line_1 IN VARCHAR2,
        x_address_line_2 IN VARCHAR2,
        x_address_line_3 IN VARCHAR2,
        x_city IN VARCHAR2,
        x_state IN VARCHAR2,
        x_county IN VARCHAR2,
        x_country IN VARCHAR2,
        x_postal_code IN VARCHAR2,
        x_telephone_number_1 IN VARCHAR2,
        x_telephone_number_2 IN VARCHAR2,
        x_shipToLocation IN VARCHAR2,
        x_ship_to_flag IN VARCHAR2,
        x_bill_to_flag IN VARCHAR2,
        x_receiving_site IN VARCHAR2,
        x_office_site_flag IN VARCHAR2,
        x_inv_org IN VARCHAR2,
        x_tax_name IN VARCHAR2)
IS
BEGIN


        IF (get_location_exists(x_location_code)) THEN

        UPDATE POR_LOCATION_LOADER_VALUES
        SET
          location_code = x_location_code,
	  business_group = x_business_grp_name,
	  effective_date = x_effective_date,
	  description = x_description,
          address_style = x_address_style,
          address_line_1 = x_address_line_1,
          address_line_2 = x_address_line_2,
          address_line_3 = x_address_line_3,
          city	= x_city,
          state = x_state,
          county = x_county,
          postal_code = x_postal_code,
          country = x_country,
          telephone = x_telephone_number_1,
          fax = x_telephone_number_2,
          ship_to_location = x_shipToLocation,
          ship_to_flag = x_ship_to_flag,
          bill_to_flag = x_bill_to_flag,
          receiving_to_flag = x_receiving_site,
          office_site = x_office_site_flag,
	  inventory_Org = x_inv_org,
          tax_name = x_tax_name,
          loader_status = 'unloaded',
          last_update_date = sysdate
        WHERE
          location_code = x_location_code;

        ELSE

        INSERT INTO POR_LOCATION_LOADER_VALUES (
         location_code,
	 business_group,
	 effective_date,
	 description,
	 address_style,
	 address_line_1,
	 address_line_2,
         address_line_3,
	 city,
         state,
         county,
	 postal_code,
	 country,
	 telephone,
	 fax,
	 ship_to_location,
	 ship_to_flag,
         bill_to_flag,
	 receiving_to_flag,
	 office_site,
	 inventory_Org,
	 tax_name,
         loader_status,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by)
         VALUES (
          x_location_code,
	x_business_grp_name,
        x_effective_date,
	x_description,
        x_address_style,
        x_address_line_1,
        x_address_line_2,
        x_address_line_3,
        x_city,
        x_state,
        x_county,
        x_postal_code,
        x_country,
        x_telephone_number_1,
        x_telephone_number_2,
        x_shipToLocation,
        x_ship_to_flag,
        x_bill_to_flag,
        x_receiving_site,
        x_office_site_flag,
        x_inv_org,
        x_tax_name,
        'unloaded',
        sysdate,
        0,
         sysdate,
         0
         );

       END IF;

       EXCEPTION
       WHEN OTHERS THEN
         RAISE;

       commit;

END insert_update_loc_temp_table;

FUNCTION get_location_exists (p_location_code IN VARCHAR2) RETURN BOOLEAN IS
  l_exists NUMBER;

BEGIN

  SELECT 1 INTO l_exists FROM por_location_loader_values
  WHERE location_code = p_location_code;

  RETURN true;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN false;

END get_location_exists;

END POR_LOAD_LOC_TEMP_TABLE;


/
