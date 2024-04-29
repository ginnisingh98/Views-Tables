--------------------------------------------------------
--  DDL for Package Body POR_LOAD_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_LOAD_LOCATION" as
/* $Header: PORLLOCB.pls 115.10 2004/05/25 23:31:34 rwidjaja ship $ */

PROCEDURE insert_update_location_info (
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

l_location_id NUMBER;
l_object_version_number NUMBER;
l_business_grp_id NUMBER;
l_inventory_org_id NUMBER;
l_operating_unit_id NUMBER;
l_ship_to_loc_id NUMBER;
l_address_style_code VARCHAR2(7);
l_country_code VARCHAR2(30);

BEGIN

    l_business_grp_id := get_business_group_id(x_business_grp_name);

    IF (x_shipToLocation IS NOT NULL) THEN

          l_ship_to_loc_id := get_location_id(x_shipToLocation);

    END IF;

    l_inventory_org_id := get_organization_id(x_inv_org);

    l_address_style_code := get_address_style_code( x_address_style);

    l_country_code := get_country_code(x_country);

    select org_id into l_operating_unit_id from financials_system_parameters;

    IF (NOT (get_location_exists(x_location_code,l_business_grp_id))) THEN

	hr_location_api.create_location(
        	p_location_code => x_location_code,
	        p_effective_date => x_effective_date,
	        p_description => x_description,
	        p_address_line_1 => x_address_line_1,
                p_address_line_2 => x_address_line_2,
                p_address_line_3 => x_address_line_3,
                p_country => l_country_code,
                p_town_or_city => x_city,
                p_region_2 => x_state,
                p_region_1 => x_county,
                p_postal_code => x_postal_code,
                p_telephone_number_1 => x_telephone_number_1,
                p_telephone_number_2 => x_telephone_number_2,
	        p_style => l_address_style_code,
        	p_ship_to_site_flag => x_ship_to_flag,
	        p_ship_to_location_id => l_ship_to_loc_id,
	        p_bill_to_site_flag => x_bill_to_flag,
        	p_receiving_site_flag => x_receiving_site,
	        p_office_site_flag => x_office_site_flag,
	        p_inventory_organization_id => l_inventory_org_id,
                p_operating_unit_id => l_operating_unit_id,
        	p_tax_name => x_tax_name,
	        p_location_id => l_location_id,
                p_business_group_id =>  l_business_grp_id,
        	p_object_version_number => l_object_version_number) ;

ELSE
       get_location_information (x_location_code, l_location_id, l_object_version_number);

       hr_location_api.update_location(
        	p_location_code => x_location_code,
	        p_effective_date => x_effective_date,
	        p_description => x_description,
	        p_address_line_1 => x_address_line_1,
                p_address_line_2 => x_address_line_2,
                p_address_line_3 => x_address_line_3,
                p_country => l_country_code,
                p_town_or_city => x_city,
                p_region_2 => x_state,
                p_region_1 => x_county,
                p_postal_code => x_postal_code,
                p_telephone_number_1 => x_telephone_number_1,
                p_telephone_number_2 => x_telephone_number_2,
	        p_style => l_address_style_code,
        	p_ship_to_site_flag => x_ship_to_flag,
	        p_ship_to_location_id => l_ship_to_loc_id,
	        p_bill_to_site_flag => x_bill_to_flag,
        	p_receiving_site_flag => x_receiving_site,
	        p_office_site_flag => x_office_site_flag,
	        p_inventory_organization_id => l_inventory_org_id,
                p_operating_unit_id => l_operating_unit_id,
        	p_tax_name => x_tax_name,
	        p_location_id => l_location_id,
        	p_object_version_number => l_object_version_number) ;
END IF;

COMMIT;

EXCEPTION

	WHEN OTHERS THEN

            RAISE;
END insert_update_location_info;

FUNCTION get_location_exists (p_location_code IN VARCHAR2, l_business_grp_id IN NUMBER) RETURN BOOLEAN IS
  l_count NUMBER;

BEGIN


  SELECT 1 INTO l_count
  FROM hr_locations_all
  WHERE location_code = p_location_code AND business_group_id = l_business_grp_id;


  RETURN true;

  EXCEPTION
    WHEN OTHERS THEN
     RETURN false;

END get_location_exists;

FUNCTION get_business_group_id (p_business_group_name IN VARCHAR2) RETURN NUMBER IS
  l_business_group_id NUMBER;
BEGIN

  SELECT business_group_id INTO l_business_group_id
  FROM per_business_groups
  WHERE name = p_business_group_name;

  RETURN l_business_group_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN -1;

END get_business_group_id;

PROCEDURE get_location_information (p_location_code IN VARCHAR2, p_location_id OUT NOCOPY NUMBER, p_object_version_number OUT NOCOPY NUMBER) IS

BEGIN

  SELECT location_id, object_version_number
  INTO p_location_id, p_object_version_number
  FROM hr_locations_all
  WHERE location_code = p_location_code;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	 RAISE;

END get_location_information;

FUNCTION get_organization_id (p_organization_name IN VARCHAR2) RETURN NUMBER IS
  l_organization_id NUMBER;
BEGIN

-- this query is written to replace the org_organization_definitions view, which
-- causing a performance issue.
  SELECT HOU.organization_id
  INTO l_organization_id
  FROM HR_ORGANIZATION_UNITS HOU,
       HR_ORGANIZATION_INFORMATION HOI1,
       HR_ORGANIZATION_INFORMATION HOI2,
       MTL_PARAMETERS MP,
       GL_SETS_OF_BOOKS GSOB
  WHERE HOU.ORGANIZATION_ID = HOI1.ORGANIZATION_ID
    AND HOU.ORGANIZATION_ID = HOI2.ORGANIZATION_ID
    AND HOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
    AND HOI1.ORG_INFORMATION1 = 'INV'
    AND HOI1.ORG_INFORMATION2 = 'Y'
    AND ( HOI1.ORG_INFORMATION_CONTEXT || '')  = 'CLASS'
    AND ( HOI2.ORG_INFORMATION_CONTEXT || '') ='Accounting Information'
    AND HOI2.ORG_INFORMATION1 = TO_CHAR(GSOB.SET_OF_BOOKS_ID)
    AND HOU.NAME = p_organization_name;

  RETURN l_organization_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END get_organization_id;

FUNCTION get_location_id (p_location_code IN VARCHAR2) RETURN NUMBER IS
  l_location_id NUMBER;
BEGIN

  SELECT location_id INTO l_location_id
  FROM hr_locations_all
  WHERE location_code = p_location_code;

  RETURN l_location_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END get_location_id;


FUNCTION get_address_style_code (p_address_style IN VARCHAR2) RETURN VARCHAR2 IS
l_address_style_code VARCHAR2(7);
BEGIN

   SELECT descriptive_flex_context_code INTO l_address_style_code
   FROM fnd_descr_flex_contexts_vl
   WHERE descriptive_flexfield_name = 'Address Location'
   AND enabled_flag = 'Y'
   AND descriptive_flex_context_code not in ('Global Data Elements')
   AND (hr_general.chk_geocodes_installed = 'Y' or
   descriptive_flex_context_code not in ('CA','US'))
   AND descriptive_flex_context_name = p_address_style;

   RETURN l_address_style_code;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END get_address_style_code;


FUNCTION get_country_code (p_country_name IN VARCHAR2) RETURN VARCHAR2 IS
l_country_code VARCHAR2(30);
BEGIN

   SELECT territory_code  INTO l_country_code
   FROM fnd_territories_vl
   WHERE territory_short_name = p_country_name;

   RETURN l_country_code;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END get_country_code;

END POR_LOAD_LOCATION;

/
