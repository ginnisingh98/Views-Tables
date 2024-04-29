--------------------------------------------------------
--  DDL for Package POA_SAVINGS_SAV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_SAVINGS_SAV" AUTHID CURRENT_USER AS
/* $Header: poasvp4s.pls 115.7 2003/12/18 09:58:20 bthammin ship $ */

FUNCTION get_lowest_possible_price (p_creation_date IN DATE,
                p_quantity IN NUMBER,
                p_unit_meas_lookup_code IN VARCHAR2,
                p_currency_code IN VARCHAR2,
                p_item_id IN NUMBER,
                p_item_revision IN VARCHAR2,
                p_category_id IN NUMBER,
                p_ship_to_location_id IN NUMBER,
                p_need_by_date IN DATE,
                p_org_id IN NUMBER,
                p_ship_to_organization_id IN NUMBER,
                p_ship_to_ou IN NUMBER,
                p_rate_date IN DATE,
                p_edw_global_rate_type IN VARCHAR2,
                p_edw_global_currency_code IN VARCHAR2)
            RETURN NUMBER;

FUNCTION get_lowest_ncum_price (p_creation_date IN DATE,
                p_quantity IN NUMBER,
                p_unit_meas_lookup_code IN VARCHAR2,
                p_currency_code IN VARCHAR2,
                p_item_id IN NUMBER,
                p_item_revision IN VARCHAR2,
                p_category_id IN NUMBER,
                p_ship_to_location_id IN NUMBER,
                p_need_by_date IN DATE,
                p_org_id IN NUMBER,
                p_ship_to_organization_id IN NUMBER,
                p_ship_to_ou IN NUMBER,
                p_rate_date IN DATE,
                p_edw_global_rate_type IN VARCHAR2,
                p_edw_global_currency_code IN VARCHAR2)
            RETURN NUMBER;

FUNCTION get_lowest_cum_price (p_creation_date IN DATE,
                p_quantity IN NUMBER,
                p_unit_meas_lookup_code IN VARCHAR2,
                p_currency_code IN VARCHAR2,
                p_item_id IN NUMBER,
                p_item_revision IN VARCHAR2,
                p_category_id IN NUMBER,
                p_ship_to_location_id IN NUMBER,
                p_org_id IN NUMBER,
                p_ship_to_organization_id IN NUMBER,
                p_ship_to_ou IN NUMBER,
                p_rate_date IN DATE,
                p_edw_global_rate_type IN VARCHAR2,
                p_edw_global_currency_code IN VARCHAR2)
            RETURN NUMBER;

END poa_savings_sav;


 

/
