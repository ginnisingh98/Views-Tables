--------------------------------------------------------
--  DDL for Package OE_SCH_FIRM_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SCH_FIRM_CONC" AUTHID CURRENT_USER AS
/* $Header: OEXCFDPS.pls 120.1 2005/06/12 02:15:00 appldev  $ */

-- Results for Workflow

Procedure Request
(ERRBUF                     OUT NOCOPY VARCHAR2,
 RETCODE                    OUT NOCOPY VARCHAR2,
 -- Moac
 p_org_id		    IN NUMBER,
 p_order_number_low         IN NUMBER,
 p_order_number_high        IN NUMBER,
 p_customer_id              IN VARCHAR2,
 p_order_type               IN VARCHAR2,
 p_line_type_id             IN VARCHAR2,
 p_warehouse                IN VARCHAR2,
 p_inventory_item_id        IN VARCHAR2,
 p_request_date_low         IN VARCHAR2,
 p_request_date_high        IN VARCHAR2,
 p_schedule_ship_date_low   IN VARCHAR2,
 p_schedule_ship_date_high  IN VARCHAR2,
 p_schedule_arrival_date_low    IN VARCHAR2,
 p_schedule_arrival_date_high   IN VARCHAR2,
 p_ordered_date_low         IN VARCHAR2,
 p_ordered_date_high        IN VARCHAR2,
 p_demand_class_code        IN VARCHAR2,
 p_planning_priority        IN NUMBER,
 p_shipment_priority        IN VARCHAR2,
 p_schedule_status          IN VARCHAR2
);

END OE_SCH_FIRM_CONC;

 

/
