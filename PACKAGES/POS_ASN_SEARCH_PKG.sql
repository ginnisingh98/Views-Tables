--------------------------------------------------------
--  DDL for Package POS_ASN_SEARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ASN_SEARCH_PKG" AUTHID CURRENT_USER AS
/* $Header: POSASNSS.pls 115.2 99/10/01 09:14:54 porting ship $ */

TYPE t_text_table is table of varchar2(240) index by binary_integer;

g_dummy    t_text_table;

PROCEDURE search_page(p_query                      IN VARCHAR2 DEFAULT 'N',
                      p_msg                        IN VARCHAR2 DEFAULT NULL,
                      p_start_row                  IN NUMBER   DEFAULT 0);

PROCEDURE criteria_frame(pos_vendor_site_id      IN VARCHAR2 DEFAULT NULL,
                      pos_vendor_site_name       IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location_id    IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location       IN VARCHAR2 DEFAULT NULL,
                      pos_supplier_item_number   IN VARCHAR2 DEFAULT NULL,
                      pos_item_description       IN VARCHAR2 DEFAULT NULL,
                      pos_po_number              IN VARCHAR2 DEFAULT NULL,
                      pos_item_number            IN VARCHAR2 DEFAULT NULL,
                      pos_date_start             IN VARCHAR2 DEFAULT NULL,
                      pos_date_end               IN VARCHAR2 DEFAULT NULL,
                      p_advance_flag             IN VARCHAR2 DEFAULT 'N'
);

PROCEDURE result_frame(pos_vendor_site_id        IN VARCHAR2 DEFAULT NULL,
                      pos_vendor_site_name       IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location_id    IN VARCHAR2 DEFAULT NULL,
                      pos_ship_to_location       IN VARCHAR2 DEFAULT NULL,
                      pos_supplier_item_number   IN VARCHAR2 DEFAULT NULL,
                      pos_item_description       IN VARCHAR2 DEFAULT NULL,
                      pos_po_number              IN VARCHAR2 DEFAULT NULL,
                      pos_item_number            IN VARCHAR2 DEFAULT NULL,
                      pos_date_start             IN VARCHAR2 DEFAULT NULL,
                      pos_date_end               IN VARCHAR2 DEFAULT NULL,
                      p_query                    IN VARCHAR2 DEFAULT 'Y',
                      p_msg                      IN VARCHAR2 DEFAULT NULL,
                      p_start_row                IN NUMBER   DEFAULT 1
);

PROCEDURE counter_frame(p_first IN NUMBER DEFAULT 0,
                        p_last  IN NUMBER DEFAULT 0,
                        p_total IN NUMBER DEFAULT 0,
                        p_msg   IN VARCHAR2 DEFAULT NULL);

PROCEDURE add_frame;

PROCEDURE SwitchResultPage(p_start_row    IN VARCHAR2 DEFAULT '1');

PROCEDURE add_shipments_to_cart(pos_po_shipment_id   IN t_text_table DEFAULT g_dummy,
                                pos_select           IN t_text_table DEFAULT g_dummy,
                                pos_start_row        IN VARCHAR2     DEFAULT '1',
                                pos_submit           IN VARCHAR2     DEFAULT 'STAY');

END pos_asn_search_pkg;

 

/
