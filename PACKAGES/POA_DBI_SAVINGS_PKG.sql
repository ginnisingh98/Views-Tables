--------------------------------------------------------
--  DDL for Package POA_DBI_SAVINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_SAVINGS_PKG" AUTHID CURRENT_USER AS
/* $Header: poadbipodsvgs.pls 115.4 2004/01/23 23:50:51 mangupta noship $ */
g_hit_count number := 0;

FUNCTION get_lowest_possible_price (p_creation_date IN DATE,
                p_org_id IN NUMBER,
                p_need_by_date IN DATE,
                p_quantity IN NUMBER,
                p_unit_meas_lookup_code IN VARCHAR2,
                p_currency_code IN VARCHAR2,
                p_item_id IN NUMBER,
                p_item_revision IN VARCHAR2,
                p_category_id IN NUMBER,
                p_ship_to_location_id IN NUMBER,
                p_func_cur_code IN VARCHAR2,
                p_rate_date IN DATE,
                p_ship_to_ou_id IN NUMBER,
                p_ship_to_organization_id IN NUMBER,
                p_po_distribution_id IN NUMBER,
                p_type IN VARCHAR2)
            RETURN NUMBER;


END poa_dbi_savings_pkg;


 

/
