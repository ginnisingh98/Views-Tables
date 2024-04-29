--------------------------------------------------------
--  DDL for Package MSC_X_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_UTIL" AUTHID CURRENT_USER AS
/* $Header: MSCXUTLS.pls 115.18 2004/03/19 01:48:23 pshah ship $  */

G_COMPANY_MAPPING  CONSTANT NUMBER := 1;
G_ORGANIZATION_MAPPING  CONSTANT NUMBER := 2;
G_COMPANY_SITE_MAPPING  CONSTANT NUMBER := 3;

G_SUPPLIER CONSTANT NUMBER := 1;
G_CUSTOMER CONSTANT NUMBER := 2;
G_ORGANIZATION CONSTANT NUMBER := 3;
G_SUPPLIER_SITE CONSTANT NUMBER := 5;
G_CUSTOMER_SITE CONSTANT NUMBER := 6;

OEM_COMPANY_ID  CONSTANT NUMBER := 1;

G_COMPANY_SITE CONSTANT NUMBER := 3;

-- function get_party_name takes in party_id and returns the party
-- name from HZ_PARTIES
FUNCTION GET_PARTY_NAME (p_party_id IN NUMBER)
RETURN VARCHAR2;

-- function get_xref_party_name takes in party_id s of a trading partner
-- and a cross referenced trading partner and returns the xref name of the
-- cross referenced trading partner
FUNCTION GET_XREF_PARTY_NAME (p_party_id IN NUMBER, p_xref_party_id IN NUMBER)
RETURN VARCHAR2;

-- function get_buyer_code takes in inventory_item_id of an item
-- and returns the buyer code for that item.
FUNCTION GET_BUYER_CODE(p_inventory_item_id IN NUMBER,
			p_publisher_id IN NUMBER,
			p_publisher_site_id IN NUMBER,
			p_customer_id IN NUMBER,
			p_customer_site_id IN NUMBER,
			p_supplier_id IN NUMBER,
			p_supplier_site_id IN NUMBER)
RETURN VARCHAR2;


-- function get_category_code takes in inventory_item_id of an item,
-- customer and supplier info and returns the category name of the
-- item defined in the OEM's org.
FUNCTION GET_CATEGORY_CODE(p_inventory_item_id IN NUMBER,
			p_publisher_id IN NUMBER,
			p_publisher_site_id IN NUMBER,
			p_customer_id IN NUMBER,
			p_customer_site_id IN NUMBER,
			p_supplier_id IN NUMBER,
			p_supplier_site_id IN NUMBER)
RETURN VARCHAR2;

--- Procedure to create partitions if they have not already been
-- created. Called from plan creation script.
PROCEDURE CREATE_EXCH_PARTITIONS(p_status OUT  NOCOPY NUMBER);

PROCEDURE GET_UOM_CONVERSION_RATES(p_uom_code IN VARCHAR2,
                           p_dest_uom_code IN VARCHAR2,
                           p_inventory_item_id IN NUMBER DEFAULT 0,
                           p_conv_found OUT NOCOPY BOOLEAN,
                           p_conv_rate OUT NOCOPY NUMBER);

FUNCTION UPDATE_SHIP_RCPT_DATES (
                          p_customer_id IN NUMBER,
                          p_customer_site_id IN NUMBER,
                          p_supplier_id IN NUMBER,
                          p_supplier_site_id IN NUMBER,
                          p_order_type IN NUMBER,
                          p_item_id IN NUMBER,
                          p_ship_date IN DATE,
                          p_rcpt_date IN DATE) RETURN DATE;

FUNCTION GET_CUSTOMER_TRANSIT_TIME(p_publisher_id IN NUMBER,
                           p_publisher_site_id IN NUMBER,
                           p_customer_id IN NUMBER,
                           p_customer_site_id IN NUMBER) RETURN NUMBER;

FUNCTION GET_LOOKUP_MEANING(p_lookup_type in varchar2,
			    p_order_type_code in Number)
RETURN varchar2;

PROCEDURE SCE_TO_APS(
                        p_map_type            IN  NUMBER,
                        p_sce_company_id      IN  NUMBER,
                        p_sce_company_site_id IN  NUMBER,
                        p_relationship_type   IN  NUMBER,
			aps_partner_id        OUT NOCOPY NUMBER,
			aps_partner_site_id   OUT NOCOPY NUMBER,
			aps_sr_instance_id    OUT NOCOPY NUMBER
			);

PROCEDURE GET_CALENDAR_CODE(
			    p_supplier_id      in number,
			    p_supplier_site_id in number,
			    p_customer_id      in number,
			    p_customer_site_id in number,
		            p_calendar_code    out nocopy varchar2,
			    p_sr_instance_id   out nocopy number,
			    p_tp_ids           in  number default 1,
			    p_tp_instance_id   in  number default 99999,
			    p_oem_ident        in  number default 3);

FUNCTION GET_SHIPPING_CONTROL(p_customer_name      IN VARCHAR2,
                              p_customer_site_name IN VARCHAR2,
                              p_supplier_name      IN VARCHAR2,
                              p_supplier_site_name IN VARCHAR2)
RETURN NUMBER;

FUNCTION GET_SHIPPING_CONTROL_ID(l_customer_id      IN NUMBER,
                                 l_customer_site_id IN NUMBER,
                                 l_supplier_id      IN NUMBER,
                                 l_supplier_site_id IN NUMBER)
RETURN NUMBER;


FUNCTION GET_BUYER_CODE(p_inventory_item_id IN NUMBER,
            p_organization_id IN NUMBER,
            p_sr_instance_id IN NUMBER
            )
RETURN VARCHAR2;

END MSC_X_UTIL;

 

/
