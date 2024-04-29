--------------------------------------------------------
--  DDL for Package POA_SUPPERF_POPULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_SUPPERF_POPULATE_PKG" AUTHID CURRENT_USER AS
/* $Header: POASPPPS.pls 115.3 2003/12/09 12:12:17 bthammin ship $: */

   PROCEDURE populate_fact_table(p_start_date IN DATE, p_end_date IN DATE);
   PROCEDURE delete_row(p_line_location_id NUMBER);
   PROCEDURE insert_row(p_shipment_id              NUMBER,
                        p_ship_to_location_id      NUMBER,
                        p_ship_to_organization_id  NUMBER,
                        p_org_id                   NUMBER,
                        p_item_id                  NUMBER,
                        p_category_id              NUMBER,
                        p_supplier_id              NUMBER,
                        p_supplier_site_id         NUMBER,
                        p_buyer_id                 NUMBER,
                        p_date_dimension           DATE,
                        p_quantity_purchased       NUMBER,
                        p_purchase_price           NUMBER,
                        p_primary_uom              VARCHAR2,
                        p_currency_code            VARCHAR2,
                        p_rate_type                VARCHAR2,
                        p_rate_date                DATE,
                        p_rate                     NUMBER,
                        p_quantity_ordered         NUMBER,
                        p_quantity_received        NUMBER,
                        p_quantity_rejected        NUMBER,
                        p_amount                   NUMBER,
                        p_number_of_receipts       NUMBER,
                        p_quantity_received_late   NUMBER,
                        p_quantity_received_early  NUMBER,
                        p_quantity_past_due        NUMBER,
                        p_first_receipt_date       DATE,
                        p_shipment_expected_date   DATE,
                        p_month_bucket             DATE,
                        p_quarter_bucket           DATE,
                        p_year_bucket              DATE,
                        p_created_by               NUMBER,
                        p_creation_date            DATE,
                        p_last_update_date         DATE,
                        p_last_updated_by          NUMBER,
                        p_last_update_login        NUMBER,
                        p_request_id               NUMBER,
                        p_program_application_id   NUMBER,
                        p_program_id               NUMBER,
                        p_program_update_date      DATE);

END POA_SUPPERF_POPULATE_PKG;


 

/
