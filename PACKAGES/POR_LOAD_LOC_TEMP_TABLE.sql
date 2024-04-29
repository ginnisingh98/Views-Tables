--------------------------------------------------------
--  DDL for Package POR_LOAD_LOC_TEMP_TABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_LOAD_LOC_TEMP_TABLE" AUTHID CURRENT_USER as
/* $Header: PORLLCTS.pls 115.1 2001/05/04 09:50:03 pkm ship        $ */

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
        x_tax_name IN VARCHAR2);

FUNCTION get_location_exists (p_location_code IN VARCHAR2) RETURN BOOLEAN;

END POR_LOAD_LOC_TEMP_TABLE;


 

/
