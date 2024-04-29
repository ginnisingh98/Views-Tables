--------------------------------------------------------
--  DDL for Package MSC_X_VMI_UTIL_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_VMI_UTIL_NEW" AUTHID CURRENT_USER AS
/* $Header: MSCXVMIS.pls 120.1 2005/06/20 04:09:46 appldev ship $ */

delim          constant varchar2(1)  :=  '#';
dformat                 varchar2(20) :=  'dd-mon-rrrr';
empty_string   constant varchar2(33) :=  '#################################';

-- CP Order Types
REPLENISHMENT CONSTANT NUMBER := 19;
REQUISITION CONSTANT NUMBER := 20;
SUPPLY_SCHEDULE CONSTANT NUMBER := 2;
ALLOCATED_ONHAND CONSTANT NUMBER := 9;
UNALLOCATED_ONHAND CONSTANT NUMBER := 10;
ASN CONSTANT NUMBER := 15;
SHIPMENT_RECEIPT CONSTANT NUMBER := 16;
PO CONSTANT NUMBER := 13;
SALES_ORDER CONSTANT NUMBER := 14;
SAFETY_STOCK CONSTANT NUMBER := 7;
ORDER_FORECAST     CONSTANT NUMBER := 2;
SALES_FORECAST     CONSTANT NUMBER := 1;
HISTORICAL_SALES   CONSTANT NUMBER := 4;

-- constants used for replenishment status
UNRELEASED CONSTANT NUMBER := 0;
RELEASED CONSTANT NUMBER := 1;
REJECTED CONSTANT NUMBER := 2;

-- constant used for source org status




ASN_AUTO_EXPIRE_YES CONSTANT NUMBER := 1;
ASN_AUTO_EXPIRE_NO  CONSTANT NUMBER := 2;

-- table for Calculating avg daily demand
 TYPE t_table_add_data IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
 t_table_avg_daily_demand t_table_add_data;


   FUNCTION  vmi_details_supplier (p_sr_instance_id         in number default null
                          , p_inventory_item_id       in number default null
                          , p_customer_id             in number default null
                          , p_customer_site_id             in number default null
                          , p_supplier_id             in number default null
                          , p_supplier_site_id             in number default null
                          , p_organization_id             in number default null
                          , p_tp_supplier_id             in number default null
                          , p_tp_supplier_site_id             in number default null
                          ) return varchar2;

   FUNCTION  vmi_details_customer(
                            p_inventory_item_id   in number
                          , p_organization_id      IN NUMBER
                          , p_sr_instance_id      IN NUMBER
                          , p_customer_id         in number default null
                          , p_customer_site_id    in number default null
                          , p_supplier_id         in number default null
                          , p_supplier_site_id    in number default null
                          ) RETURN VARCHAR2;


   PROCEDURE  vmiCustomerGraphCreate
      (  p_inventory_item_id IN NUMBER
       , p_organization_id   IN NUMBER
       , p_sr_instance_id    IN NUMBER
       , p_customer_id       IN NUMBER
       , p_customer_site_id  IN NUMBER
       , p_supplier_id       IN NUMBER
       , p_supplier_site_id  IN NUMBER
       , p_query_id          OUT NOCOPY NUMBER
       );

   Procedure      VmiSupplierGraphOnhand
   ( p_inventory_item_id	IN NUMBER,
     p_customer_id		IN NUMBER,
     p_customer_site_id		IN NUMBER,
     p_supplier_id		IN NUMBER,
     p_supplier_site_id IN NUMBER,
     p_organization_id  IN NUMBER,
     p_tp_supplier_id    IN NUMBER,
     p_tp_supplier_site_id IN NUMBER,
     p_sr_instance_id   IN NUMBER,
     p_plan_id			IN NUMBER,
      p_return_code      OUT NOCOPY NUMBER,
     p_err_msg          OUT  NOCOPY VARCHAR2
     );

     FUNCTION  AVG_DAILY_DEMAND
     (p_inventory_item_id IN NUMBER,
     p_customer_id  IN NUMBER,
     p_customer_site_id  IN NUMBER,
     p_supplier_id  IN NUMBER,
     p_supplier_site_id IN NUMBER,
     p_plan_id   IN NUMBER,
     p_forecast_horizon  IN NUMBER)
     return t_table_add_data ;

     FUNCTION  INTRANSIT_LEAD_TIME
     (p_source_org_id IN NUMBER,
      p_modeled_org_id IN NUMBER,
     p_customer_id  IN NUMBER,
     p_customer_site_id  IN NUMBER,
     p_supplier_id  IN NUMBER,
     p_sr_instance_id   IN NUMBER,
     p_consigned_flag  IN NUMBER)
     return NUMBER;

     PROCEDURE vmiCustomerGraphTest;


      FUNCTION  supplier_avg_daily_usage(
                            p_inventory_item_id   in number
                          , p_organization_id     in number
                          , p_sr_instance_id      in number
                          , p_tp_supplier_id      in number default null
                          , p_tp_supplier_site_id in number default null
                          ) return number;

     FUNCTION  customer_avg_daily_usage(
                            p_inventory_item_id   in number
                          , p_organization_id      in number
                          , p_sr_instance_id      in number
                           ) return number;





END MSC_X_VMI_UTIL_NEW;


 

/
