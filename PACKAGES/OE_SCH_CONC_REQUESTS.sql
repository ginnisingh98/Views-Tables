--------------------------------------------------------
--  DDL for Package OE_SCH_CONC_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SCH_CONC_REQUESTS" AUTHID CURRENT_USER AS
/* $Header: OEXCSCHS.pls 120.5.12010000.3 2009/09/02 10:38:57 nshah ship $ */

g_process_records NUMBER;
g_failed_records  NUMBER;
g_conc_program    VARCHAR2(1) := 'N';
g_recorded        VARCHAR2(1) := 'N'; --5166476

TYPE id_arr IS TABLE OF number INDEX BY BINARY_INTEGER;
OE_model_id_Tbl id_arr;
OE_set_id_Tbl id_arr;
oe_included_id_tbl id_arr;
--5166476
TYPE status_arr IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
OE_line_status_Tbl status_arr;

PROCEDURE Request (ERRBUF                   OUT NOCOPY VARCHAR2,
                   RETCODE                  OUT NOCOPY VARCHAR2,
                   /* Moac */
                   p_org_id                 IN NUMBER,
                   p_order_number_low       IN NUMBER,
                   p_order_number_high      IN NUMBER,
                   p_request_date_low       IN VARCHAR2,
                   p_request_date_high      IN VARCHAR2,
                   p_customer_po_number     IN VARCHAR2,
                   p_ship_to_location       IN VARCHAR2,
                   p_order_type             IN VARCHAR2,
                   p_customer               IN VARCHAR2,
                   p_ordered_date_low       IN VARCHAR2,
                   p_ordered_date_high      IN VARCHAR2,
                   p_warehouse              IN VARCHAR2,
                   p_item                   IN VARCHAR2,
                   p_demand_class           IN VARCHAR2,
                   p_planning_priority      IN VARCHAR2,
                   p_shipment_priority      IN VARCHAR2,
                   p_line_type              IN VARCHAR2,
                   p_line_request_date_low  IN VARCHAR2,
                   p_line_request_date_high IN VARCHAR2,
                   p_line_ship_to_location  IN VARCHAR2,
                   p_sch_ship_date_low      IN VARCHAR2,
                   p_sch_ship_date_high     IN VARCHAR2,
                   p_sch_arrival_date_low   IN VARCHAR2,
                   p_sch_arrival_date_high  IN VARCHAR2,
                   p_booked                 IN VARCHAR2,
                   p_sch_mode               IN VARCHAR2,
                   p_dummy1                 IN VARCHAR2,
                   p_dummy2                 IN VARCHAR2,
                   p_apply_warehouse        IN VARCHAR2,
                   p_apply_sch_date         IN VARCHAR2,
                   p_order_by_first         IN VARCHAR2,
                   p_order_by_sec           IN VARCHAR2,
                   p_picked                 IN VARCHAR2 DEFAULT NULL --Bug 8813015
                   );

FUNCTION included_processed(p_inc_item_id  IN NUMBER)
RETURN BOOLEAN;

END OE_SCH_CONC_REQUESTS;

/
