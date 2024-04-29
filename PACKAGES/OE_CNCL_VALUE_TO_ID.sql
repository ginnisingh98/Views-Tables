--------------------------------------------------------
--  DDL for Package OE_CNCL_VALUE_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CNCL_VALUE_TO_ID" AUTHID CURRENT_USER AS
/* $Header: OEXVCIDS.pls 120.1.12000000.1 2007/01/16 22:08:15 appldev ship $ */


--  Prototypes for Value_To_Id functions.

--  START GEN value_to_id

--  Generator will append new prototypes before end generate comment.
FUNCTION Key_Flex
(   p_key_flex_code                 IN  VARCHAR2
,   p_structure_number              IN  NUMBER
,   p_appl_short_name               IN  VARCHAR2
,   p_segment_array                 IN  FND_FLEX_EXT.SegmentArray
) RETURN NUMBER;

--  Accounting_Rule

FUNCTION Accounting_Rule
(   p_accounting_rule               IN  VARCHAR2
) RETURN NUMBER;

--  Agreement

FUNCTION Agreement
(   p_agreement                     IN  VARCHAR2
) RETURN NUMBER;

--  Conversion_Type

FUNCTION Conversion_Type
(   p_conversion_type               IN  VARCHAR2
) RETURN VARCHAR2;

--  Deliver_To_Contact

FUNCTION Deliver_To_Contact
(   p_deliver_to_contact            IN  VARCHAR2
,   p_deliver_to_org_id             IN  NUMBER
) RETURN NUMBER;

--  Deliver_To_Org

FUNCTION Deliver_To_Org
(   p_deliver_to_address1           IN  VARCHAR2
,   p_deliver_to_address2           IN  VARCHAR2
,   p_deliver_to_address3           IN  VARCHAR2
,   p_deliver_to_address4           IN  VARCHAR2
,   p_deliver_to_location           IN  VARCHAR2
,   p_deliver_to_org                IN  VARCHAR2
,   p_sold_to_org_id                IN  NUMBER
,   p_deliver_to_city               IN VARCHAR2 DEFAULT NULL
,   p_deliver_to_state              IN VARCHAR2 DEFAULT NULL
,   p_deliver_to_postal_code        IN VARCHAR2 DEFAULT NULL
,   p_deliver_to_country            IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

--  Fob_Point

FUNCTION Fob_Point
(   p_fob_point                     IN  VARCHAR2
) RETURN VARCHAR2;

--  Freight_Terms

FUNCTION Freight_Terms
(   p_freight_terms                 IN  VARCHAR2
) RETURN VARCHAR2;

--  Invoice_To_Contact

FUNCTION Invoice_To_Contact
(   p_invoice_to_contact            IN  VARCHAR2
,   p_invoice_to_org_id             IN  NUMBER
) RETURN NUMBER;

--  Invoice_To_Org

FUNCTION Invoice_To_Org
(   p_invoice_to_address1           IN  VARCHAR2
,   p_invoice_to_address2           IN  VARCHAR2
,   p_invoice_to_address3           IN  VARCHAR2
,   p_invoice_to_address4           IN  VARCHAR2
,   p_invoice_to_location           IN  VARCHAR2
,   p_invoice_to_org                IN  VARCHAR2
,   p_sold_to_org_id                IN  NUMBER
,   p_invoice_to_city               IN VARCHAR2 DEFAULT NULL
,   p_invoice_to_state              IN VARCHAR2 DEFAULT NULL
,   p_invoice_to_postal_code        IN VARCHAR2 DEFAULT NULL
,   p_invoice_to_country            IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

--  Invoicing_Rule

FUNCTION Invoicing_Rule
(   p_invoicing_rule                IN  VARCHAR2
) RETURN NUMBER;

--  Order_Source

FUNCTION Order_Source
(   p_order_source                  IN  VARCHAR2
) RETURN NUMBER;

--  Order_Type

FUNCTION Order_Type
(   p_order_type                    IN  VARCHAR2
) RETURN NUMBER;

--  Payment_Term

FUNCTION Payment_Term
(   p_payment_term                  IN  VARCHAR2
) RETURN NUMBER;

--  Price_List

FUNCTION Price_List
(   p_price_list                    IN  VARCHAR2
) RETURN NUMBER;

--  Shipment_Priority

FUNCTION Shipment_Priority
(   p_shipment_priority             IN  VARCHAR2
) RETURN VARCHAR2;

--  Ship_From_Org

FUNCTION Ship_From_Org
(   p_ship_from_address1            IN  VARCHAR2
,   p_ship_from_address2            IN  VARCHAR2
,   p_ship_from_address3            IN  VARCHAR2
,   p_ship_from_address4            IN  VARCHAR2
,   p_ship_from_location            IN  VARCHAR2
,   p_ship_from_org                 IN  VARCHAR2
) RETURN NUMBER;

--  Ship_To_Contact

FUNCTION Ship_To_Contact
(   p_ship_to_contact               IN  VARCHAR2
,   p_ship_to_org_id                IN  NUMBER
) RETURN NUMBER;

FUNCTION Inventory_Org
(   p_inventory_org               IN  VARCHAR2
) RETURN NUMBER;

--  Ship_To_Org

FUNCTION Ship_To_Org
(   p_ship_to_address1              IN  VARCHAR2
,   p_ship_to_address2              IN  VARCHAR2
,   p_ship_to_address3              IN  VARCHAR2
,   p_ship_to_address4              IN  VARCHAR2
,   p_ship_to_location              IN  VARCHAR2
,   p_ship_to_org                   IN  VARCHAR2
,   p_sold_to_org_id                IN  NUMBER
,   p_ship_to_city                  IN VARCHAR2 DEFAULT NULL
,   p_ship_to_state                 IN VARCHAR2 DEFAULT NULL
,   p_ship_to_postal_code           IN VARCHAR2 DEFAULT NULL
,   p_ship_to_country               IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER;


--  Intermediate_Ship_To_Contact

FUNCTION Intermed_Ship_To_Contact
(   p_intermed_ship_to_contact               IN  VARCHAR2
,   p_intermed_ship_to_org_id                IN  NUMBER
) RETURN NUMBER;

--  Intermediate_Ship_To_Org

FUNCTION Intermed_Ship_To_Org
(   p_intermed_ship_to_address1              IN  VARCHAR2
,   p_intermed_ship_to_address2              IN  VARCHAR2
,   p_intermed_ship_to_address3              IN  VARCHAR2
,   p_intermed_ship_to_address4              IN  VARCHAR2
,   p_intermed_ship_to_location              IN  VARCHAR2
,   p_intermed_ship_to_org                   IN  VARCHAR2
,   p_sold_to_org_id                         IN  NUMBER
,   p_intermed_ship_to_city                  IN VARCHAR2 DEFAULT NULL
,   p_intermed_ship_to_state                 IN VARCHAR2 DEFAULT NULL
,   p_intermed_ship_to_postal_code           IN VARCHAR2 DEFAULT NULL
,   p_intermed_ship_to_country               IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

--  Sold_To_Contact

FUNCTION Sold_To_Contact
(   p_sold_to_contact               IN  VARCHAR2
,   p_sold_to_org_id                IN  NUMBER
) RETURN NUMBER;

--  Sold_To_Org

FUNCTION Sold_To_Org
(   p_sold_to_org                   IN  VARCHAR2
,   p_customer_number               IN  VARCHAR2
) RETURN NUMBER;

--  Tax_Exempt

FUNCTION Tax_Exempt
(   p_tax_exempt                    IN  VARCHAR2
) RETURN VARCHAR2;

--  Tax_Exempt_Reason

FUNCTION Tax_Exempt_Reason
(   p_tax_exempt_reason             IN  VARCHAR2
) RETURN VARCHAR2;

--  Tax_Point

FUNCTION Tax_Point
(   p_tax_point                     IN  VARCHAR2
) RETURN VARCHAR2;

--  Discount

FUNCTION Discount
(   p_discount                      IN  VARCHAR2
) RETURN NUMBER;

--  Salesrep

FUNCTION Salesrep
(   p_salesrep                      IN  VARCHAR2
) RETURN NUMBER;

FUNCTION sales_credit_type
(   p_sales_credit_type            IN  VARCHAR2
) RETURN NUMBER;

--  Demand_Bucket_Type

FUNCTION Demand_Bucket_Type
(   p_demand_bucket_type            IN  VARCHAR2
) RETURN VARCHAR2;

--  Inventory_Item

FUNCTION Inventory_Item
(   p_inventory_item                IN  VARCHAR2
) RETURN NUMBER;

--  Item_Type

FUNCTION Item_Type
(   p_item_type                     IN  VARCHAR2
) RETURN VARCHAR2;

--  Line_Type

FUNCTION Line_Type
(   p_line_type                     IN  VARCHAR2
) RETURN NUMBER;

--  Project

FUNCTION Project
(   p_project                       IN  VARCHAR2
) RETURN NUMBER;

--  Rla_Schedule_Type

FUNCTION Rla_Schedule_Type
(   p_rla_schedule_type             IN  VARCHAR2
) RETURN VARCHAR2;

--  Task

FUNCTION Task
(   p_task                          IN  VARCHAR2
) RETURN NUMBER;

--  Over_Ship_Reason

FUNCTION Over_Ship_Reason
(   p_over_ship_reason              IN  VARCHAR2
) RETURN VARCHAR2;

--  Return_Reason

FUNCTION Return_Reason
(   p_return_reason                 IN  VARCHAR2
) RETURN VARCHAR2;

--  Veh_Cus_Item_cum_key

FUNCTION Veh_Cus_Item_cum_Key
(   p_veh_cus_item_cum_key          IN  VARCHAR2
) RETURN NUMBER;

--  Payment_Type

FUNCTION Payment_Type
(   p_payment_type                  IN  VARCHAR2
) RETURN VARCHAR2;

--  Credit_Card

FUNCTION Credit_Card
(   p_credit_card                   IN  VARCHAR2
) RETURN VARCHAR2;

-- Commitment

FUNCTION Commitment
(   p_commitment                   IN  VARCHAR2
) RETURN NUMBER;



/* Pricing Contract Functions: Begin */

--  Currency

FUNCTION Currency
(   p_currency                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Agreement_Contact

FUNCTION Agreement_Contact
(   p_Agreement_Contact                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Agreement_Type

FUNCTION Agreement_Type
(   p_Agreement_Type                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Customer

FUNCTION Customer
(   p_Customer                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Invoice_Contact

FUNCTION Invoice_Contact
(   p_Invoice_Contact                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Invoice_To_Site_Use

FUNCTION Invoice_To_Site_Use
(   p_Invoice_To_Site_Use                      IN  VARCHAR2
) RETURN VARCHAR2;

--  override_arule

FUNCTION override_arule
(   p_override_arule                      IN  VARCHAR2
) RETURN VARCHAR2;

--  override_irule

FUNCTION override_irule
(   p_override_irule                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Revision_Reason

FUNCTION Revision_Reason
(   p_Revision_Reason                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Ship_Method

FUNCTION Ship_Method
(   p_Ship_Method                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Term

FUNCTION Term
(   p_Term                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Secondary_Price_List

FUNCTION Secondary_Price_List
(   p_secondary_price_list          IN  VARCHAR2
) RETURN NUMBER;

--  Terms

FUNCTION Terms
(   p_terms                         IN  VARCHAR2
) RETURN NUMBER;

--  Automatic_Discount

FUNCTION Automatic_Discount
(   p_automatic_discount            IN  VARCHAR2
) RETURN VARCHAR2;

--  Discount_Lines

FUNCTION Discount_Lines
(   p_discount_lines                IN  VARCHAR2
) RETURN VARCHAR2;

--  Discount_Type

FUNCTION Discount_Type
(   p_discount_type                 IN  VARCHAR2
) RETURN VARCHAR2;

--  Manual_Discount

FUNCTION Manual_Discount
(   p_manual_discount               IN  VARCHAR2
) RETURN VARCHAR2;

--  Override_Allowed

FUNCTION Override_Allowed
(   p_override_allowed              IN  VARCHAR2
) RETURN VARCHAR2;

--  Prorate

FUNCTION Prorate
(   p_prorate                       IN  VARCHAR2
) RETURN VARCHAR2;

--  Method

FUNCTION Method
(   p_method                        IN  VARCHAR2
) RETURN VARCHAR2;

--  Price_List_Line

FUNCTION Price_List_Line
(   p_price_list_line               IN  VARCHAR2
) RETURN NUMBER;

--  Pricing_Rule

FUNCTION Pricing_Rule
(   p_pricing_rule                  IN  VARCHAR2
) RETURN NUMBER;

--  Reprice

FUNCTION Reprice
(   p_reprice                       IN  VARCHAR2
) RETURN VARCHAR2;

--  Unit

FUNCTION Unit
(   p_unit                          IN  VARCHAR2
) RETURN VARCHAR2;

--  Customer_Class

FUNCTION Customer_Class
(   p_customer_class                IN  VARCHAR2
) RETURN VARCHAR2;

--  Discount_Customer

FUNCTION Discount_Customer
(   p_discount_customer             IN  VARCHAR2
) RETURN NUMBER;

--  Site_Use

FUNCTION Site_Use
(   p_site_use                      IN  VARCHAR2
) RETURN NUMBER;

--  Entity

FUNCTION Entity
(   p_entity                        IN  VARCHAR2
) RETURN NUMBER;

--  Method_Type

FUNCTION Method_Type
(   p_method_type                   IN  VARCHAR2
) RETURN VARCHAR2;

/* Pricing Contract Functions: End */

--  Lot_Serial

FUNCTION Lot_Serial
(   p_lot_serial                    IN  VARCHAR2
) RETURN NUMBER;

--  Appear_On_Ack

FUNCTION Appear_On_Ack
(   p_appear_on_ack                 IN  VARCHAR2
) RETURN VARCHAR2;

--  Appear_On_Invoice

FUNCTION Appear_On_Invoice
(   p_appear_on_invoice             IN  VARCHAR2
) RETURN VARCHAR2;

--  Charge

FUNCTION Charge
(   p_charge                        IN  VARCHAR2
) RETURN NUMBER;

--  Charge_Type

FUNCTION Charge_Type
(   p_charge_type                   IN  VARCHAR2
) RETURN NUMBER;

--  Cost_Or_Charge

FUNCTION Cost_Or_Charge
(   p_cost_or_charge                IN  VARCHAR2
) RETURN VARCHAR2;

--  Departure

FUNCTION Departure
(   p_departure                     IN  VARCHAR2
) RETURN NUMBER;

--  Estimated

FUNCTION Estimated
(   p_estimated                     IN  VARCHAR2
) RETURN VARCHAR2;

--  Invoiced

FUNCTION Invoiced
(   p_invoiced                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Parent_Charge

FUNCTION Parent_Charge
(   p_parent_charge                 IN  VARCHAR2
) RETURN NUMBER;

--  Returnable

FUNCTION Returnable
(   p_returnable                    IN  VARCHAR2
) RETURN VARCHAR2;

--  Tax_Group

FUNCTION Tax_Group
(   p_tax_group                     IN  VARCHAR2
) RETURN VARCHAR2;


FUNCTION Flow_Status
(  p_flow_status	IN	VARCHAR2
) RETURN VARCHAR2;

FUNCTION Freight_Carrier
(  p_freight_carrier	IN	VARCHAR2
,  p_ship_from_org_id    IN	NUMBER
) RETURN VARCHAR2;

FUNCTION Sales_Channel
(  p_sales_channel	IN	VARCHAR2
) RETURN VARCHAR2;


--  END GEN value_to_id

FUNCTION Customer_Location
(   p_sold_to_location_address1              IN  VARCHAR2
,   p_sold_to_location_address2              IN  VARCHAR2
,   p_sold_to_location_address3              IN  VARCHAR2
,   p_sold_to_location_address4              IN  VARCHAR2
,   p_sold_to_location                       IN  VARCHAR2
,   p_sold_to_org_id                         IN  NUMBER
,   p_sold_to_location_city                  IN VARCHAR2 DEFAULT NULL
,   p_sold_to_location_state                 IN VARCHAR2 DEFAULT NULL
,   p_sold_to_location_postal                IN VARCHAR2 DEFAULT NULL
,   p_sold_to_location_country               IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

FUNCTION END_CUSTOMER
(  p_end_customer        IN VARCHAR2
,  p_end_customer_number IN VARCHAR2
) RETURN NUMBER;

FUNCTION END_CUSTOMER_CONTACT
(  p_end_customer_contact IN VARCHAR2
,  p_end_customer_id      IN NUMBER
) RETURN NUMBER;

FUNCTION END_CUSTOMER_SITE
(   p_end_customer_site_address1              IN  VARCHAR2
,   p_end_customer_site_address2              IN  VARCHAR2
,   p_end_customer_site_address3              IN  VARCHAR2
,   p_end_customer_site_address4              IN  VARCHAR2
,   p_end_customer_site_location              IN  VARCHAR2
,   p_end_customer_site_org                   IN  VARCHAR2
,   p_end_customer_id                         IN  NUMBER
,   p_end_customer_site_city                  IN  VARCHAR2 DEFAULT NULL
,   p_end_customer_site_state                 IN  VARCHAR2 DEFAULT NULL
,   p_end_customer_site_postalcode            IN  VARCHAR2 DEFAULT NULL
,   p_end_customer_site_country               IN  VARCHAR2 DEFAULT NULL
,   p_end_customer_site_use_code              IN  VARCHAR2 DEFAULT NULL
) RETURN NUMBER;

FUNCTION IB_Owner
(   p_ib_owner                      IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION IB_Installed_At_Location
(   p_ib_installed_at_location  IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION IB_Current_Location
(   p_ib_current_location  IN  VARCHAR2
) RETURN VARCHAR2;

END OE_CNCL_Value_To_Id;

 

/
