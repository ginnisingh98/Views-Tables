--------------------------------------------------------
--  DDL for Package POR_LOAD_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_LOAD_LOCATION" AUTHID CURRENT_USER as
/* $Header: PORLLOCS.pls 115.3 2001/07/16 14:51:08 pkm ship        $ */

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
        x_tax_name IN VARCHAR2);

FUNCTION get_location_exists (p_location_code IN VARCHAR2, l_business_grp_id IN NUMBER) RETURN BOOLEAN;

FUNCTION get_business_group_id (p_business_group_name IN VARCHAR2) RETURN NUMBER;

PROCEDURE get_location_information (p_location_code IN VARCHAR2, p_location_id OUT NUMBER, p_object_version_number OUT NUMBER);

FUNCTION get_organization_id (p_organization_name IN VARCHAR2) RETURN NUMBER;

FUNCTION get_location_id (p_location_code IN VARCHAR2) RETURN NUMBER;

FUNCTION get_address_style_code (p_address_style IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_country_code (p_country_name IN VARCHAR2) RETURN VARCHAR2;

END POR_LOAD_LOCATION;

 

/
