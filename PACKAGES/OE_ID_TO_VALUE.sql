--------------------------------------------------------
--  DDL for Package OE_ID_TO_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ID_TO_VALUE" AUTHID CURRENT_USER AS
/* $Header: OEXSIDVS.pls 120.3.12010000.1 2008/07/25 07:54:23 appldev ship $ */

--  Procedure Get_Attr_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  Id_To_Value functions.
--
--  DO NOT MODIFY

PROCEDURE Get_Attr_Tbl;

--  Prototypes for Id_To_Value functions.

--  START GEN Id_To_Value

--  Generator will append new prototypes before end generate comment.

/* Process Order Functions: Begin */

FUNCTION Conversion_Type
(   p_conversion_type_code          IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Deliver_To_Contact
(   p_deliver_to_contact_id         IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Inventory_Org
(   p_inventory_org_id         IN  NUMBER
) RETURN VARCHAR2;

PROCEDURE Deliver_To_Org
(   p_deliver_to_org_id             IN  NUMBER
,   x_deliver_to_address1           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_deliver_to_address2           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_deliver_to_address3           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_deliver_to_address4           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_deliver_to_location           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_deliver_to_org                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_deliver_to_city               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_deliver_to_state              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_deliver_to_postal_code        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_deliver_to_country            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

FUNCTION Fob_Point
(   p_fob_point_code                IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Invoice_To_Contact
(   p_invoice_to_contact_id         IN  NUMBER
) RETURN VARCHAR2;

PROCEDURE Invoice_To_Org
(   p_invoice_to_org_id             IN  NUMBER
,   x_invoice_to_address1           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_address2           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_address3           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_address4           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_location           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_org                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_city               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_state              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_postal_code        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_invoice_to_country            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

FUNCTION Order_Source
(   p_order_source_id               IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Order_Type
(   p_order_type_id                 IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Payment_Term
(   p_payment_term_id               IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Shipment_Priority
(   p_shipment_priority_code        IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Demand_Class
(   p_demand_class_code        IN  VARCHAR2
) RETURN VARCHAR2;

PROCEDURE Ship_From_Org
(   p_ship_from_org_id              IN  NUMBER
,   x_ship_from_address1            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_address2            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_address3            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_address4            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_location            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_org                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

FUNCTION Ship_To_Contact
(   p_ship_to_contact_id            IN  NUMBER
) RETURN VARCHAR2;

PROCEDURE Ship_To_Org
(   p_ship_to_org_id                IN  NUMBER
,   x_ship_to_address1              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_address2              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_address3              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_address4              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_location              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_org                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_city                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_state                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_postal_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_country               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


FUNCTION Intermed_Ship_To_Contact
(   p_intermed_ship_to_contact_id    IN  NUMBER
) RETURN VARCHAR2;


PROCEDURE Intermed_Ship_To_Org
(   p_intermed_ship_to_org_id       IN  NUMBER
,   x_intermed_ship_to_address1     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_intermed_ship_to_address2     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_intermed_ship_to_address3     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_intermed_ship_to_address4     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_intermed_ship_to_location     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_intermed_ship_to_org          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_intermed_ship_to_city         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_intermed_ship_to_state        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_intermed_ship_to_postal_code  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_intermed_ship_to_country      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


FUNCTION Sold_To_Contact
(   p_sold_to_contact_id            IN  NUMBER
) RETURN VARCHAR2;

PROCEDURE    Sold_To_Org
(   p_sold_to_org_id	IN  NUMBER
,   x_org		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_number	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--Overloded procedure added for Ac. Desc, Registry ID Project
PROCEDURE    Sold_To_Org
(   p_sold_to_org_id	IN  NUMBER  	,
x_org OUT NOCOPY VARCHAR2 ,
x_customer_number OUT NOCOPY VARCHAR2 ,
x_account_description OUT NOCOPY VARCHAR2,
x_registry_id OUT NOCOPY VARCHAR2
);
	--added for Ac. Desc, Registry ID Project

FUNCTION Tax_Exempt
(   p_tax_exempt_flag               IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Tax_Exempt_Reason
(   p_tax_exempt_reason_code        IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Tax_Point
(   p_tax_point_code                IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Demand_Bucket_Type
(   p_demand_bucket_type_code       IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Item_Type
(   p_item_type_code                IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Line_Type
(   p_line_type_id                  IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Project
(   p_project_id                    IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Rla_Schedule_Type
(   p_rla_schedule_type_code        IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Task
(   p_task_id                       IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Over_Ship_Reason
(   p_over_ship_reason_code                  IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Order_Date_Type
(   p_order_date_type_code               IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE Reference_Line
(   p_reference_Line_id       IN NUMBER
,   x_ref_order_number        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ref_line_number         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ref_shipment_number     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ref_option_number       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ref_component_number    OUT NOCOPY /* file.sql.39 change */ NUMBER
);

PROCEDURE Reference_Cust_Trx_Line
(   p_reference_cust_trx_line_id         IN NUMBER
,   x_ref_invoice_number                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ref_invoice_line_number            OUT NOCOPY /* file.sql.39 change */ NUMBER
);

FUNCTION Credit_Invoice_Line
(   p_credit_invoice_line_id             IN NUMBER
) RETURN VARCHAR2;

FUNCTION Source_Type
(   p_source_type_code                   IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Return_Reason
(   p_return_reason_code                  IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Veh_Cus_Item_Cum_Key
(   p_veh_cus_item_cum_key_id                  IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Payment_Type
(   p_payment_type_code            IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Credit_Card
(   p_credit_card_code            IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Commitment
(   p_commitment_id            IN NUMBER
) RETURN VARCHAR2;

FUNCTION Delivery
(   p_delivery_id                  IN  NUMBER
) RETURN VARCHAR2;

/* Process Order Functions: End */

/* Pricing Contract Functions: Begin */

FUNCTION Agreement
(   p_agreement_id                  IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Discount
(   p_discount_id                   IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Price_List
(   p_price_list_id                 IN  NUMBER
) RETURN VARCHAR2;

FUNCTION New_Modifier_List
(   p_new_modifier_list_id                 IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Accounting_Rule
(   p_accounting_rule_id            IN  NUMBER
) RETURN VARCHAR2;


FUNCTION Calculate_Price_Flag
(   p_calculate_price_flag            IN  VARCHAR2
) RETURN VARCHAR2;


---**

FUNCTION Agreement_Contact
(   p_agreement_contact_id          IN  NUMBER
) RETURN VARCHAR2;

---**

FUNCTION Agreement_Type
(   p_agreement_type_code           IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Customer
(   p_sold_to_org_id                   IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Freight_Terms
(   p_freight_terms_code            IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Invoice_Contact
(   p_invoice_contact_id            IN  NUMBER
) RETURN VARCHAR2;

---**

FUNCTION Invoice_To_Site_Use
(   p_invoice_to_org_id        IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Invoicing_Rule
(   p_invoicing_rule_id             IN  NUMBER
) RETURN VARCHAR2;

---**

FUNCTION Override_Arule
(   p_override_arule_flag           IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Override_Irule
(   p_override_irule_flag           IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Revision_Reason
(   p_revision_reason_code          IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Salesrep
(   p_salesrep_id                   IN  NUMBER
) RETURN VARCHAR2;

FUNCTION sales_credit_type
(   p_sales_credit_type_id         IN  NUMBER
) RETURN VARCHAR2;

---**

FUNCTION Ship_Method
(   p_ship_method_code              IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Term
(   p_term_id                       IN  NUMBER
) RETURN VARCHAR2;

---**

FUNCTION Currency
(   p_currency_code                 IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Secondary_Price_List
(   p_secondary_price_list_id       IN  NUMBER
) RETURN VARCHAR2;

---**

FUNCTION Terms
(   p_terms_id                      IN  NUMBER
) RETURN VARCHAR2;

---**

FUNCTION Automatic_Discount
(   p_automatic_discount_flag       IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Discount_Lines
(   p_discount_lines_flag           IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Discount_Type
(   p_discount_type_code            IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Manual_Discount
(   p_manual_discount_flag          IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Override_Allowed
(   p_override_allowed_flag         IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Prorate
(   p_prorate_flag                  IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Customer_Item
(   p_customer_item_id              IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Inventory_Item
(   p_inventory_item_id             IN  NUMBER
) RETURN VARCHAR2;

---**

FUNCTION Method
(   p_method_code                   IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Price_List_Line
(   p_price_list_line_id            IN  NUMBER
) RETURN VARCHAR2;

---**

FUNCTION Pricing_Rule
(   p_pricing_rule_id               IN  NUMBER
) RETURN VARCHAR2;

---**

FUNCTION Reprice
(   p_reprice_flag                  IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Unit
(   p_unit_code                     IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Customer_Class
(   p_customer_class_code           IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Discount_Customer
(   p_discount_customer_id          IN  NUMBER
) RETURN VARCHAR2;

---**

FUNCTION Site_Use
(   p_site_use_id                   IN  NUMBER
) RETURN VARCHAR2;
 ---**

FUNCTION Entity
(   p_entity_id                     IN  NUMBER
) RETURN VARCHAR2;

---**

FUNCTION Method_Type
(   p_method_type_code              IN  VARCHAR2
) RETURN VARCHAR2;

---**

FUNCTION Charge_Type
(   p_charge_type_id                IN  NUMBER
) RETURN VARCHAR2;

/*FUNCTION Tax_Group
(   p_tax_code                      IN  VARCHAR2
) RETURN VARCHAR2;*/


FUNCTION Flow_Status
( p_flow_status_code	IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Freight_Carrier
( p_freight_carrier_code	IN 	VARCHAR2
, p_ship_from_org_id 	IN	NUMBER
) RETURN VARCHAR2;

FUNCTION Sales_Channel
( p_sales_channel_code	IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE Ship_To_Customer_Name
(   p_ship_to_org_id                IN  NUMBER
,   x_ship_to_customer_name         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE Invoice_To_Customer_Name
(   p_invoice_to_org_id                IN  NUMBER
,   x_invoice_to_customer_name         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE  Item_Identifier
( p_Item_Identifier_type IN  VARCHAR2
, x_Item_Identifier      OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE  Ordered_Item
( p_Item_Identifier_type IN VARCHAR2
, p_inventory_item_id    IN NUMBER
, p_organization_id      IN NUMBER
, p_ordered_item_id      IN NUMBER
, p_sold_to_org_id       IN NUMBER
, p_ordered_item         IN VARCHAR2
, x_ordered_item         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_inventory_item       OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE  Item_relationship_type
( p_Item_relationship_type IN  NUMBER
, x_Item_relationship_type_dsp      OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

FUNCTION Transaction_Phase
(   p_Transaction_Phase_code            IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION User_Status
(   p_user_status_code            IN  VARCHAR2
) RETURN VARCHAR2;

PROCEDURE Customer_Location
(   p_sold_to_site_use_id                     IN  NUMBER
,   x_sold_to_location_address1              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_location_address2              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_location_address3              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_location_address4              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_location                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_location_city                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_location_state                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_location_postal                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_location_country               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE Get_Contact_Details
( p_contact_id          IN NUMBER
 ,x_contact_name        OUT NOCOPY VARCHAR2
 ,x_phone_line_type     OUT NOCOPY VARCHAR2
 ,x_phone_number        OUT NOCOPY VARCHAR2
 ,x_email_address       OUT NOCOPY VARCHAR2);

--serla begin
FUNCTION payment_collection_event_name
(   p_payment_collection_event            IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Receipt_Method
(   p_receipt_method            IN  NUMBER
) RETURN VARCHAR2;

--SG{
FUNCTION get_sales_group_name
(p_sales_group_id IN NUMBER
)RETURN VARCHAR2;
--SG}

--distributed orders
PROCEDURE End_Customer
(   p_end_customer_id 	        IN  NUMBER
,   x_end_customer_name	        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_number	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

FUNCTION end_customer_Contact
(   p_end_customer_contact_id            IN  NUMBER
) RETURN VARCHAR2;

PROCEDURE end_customer_site_use
(   p_end_customer_site_use_id           IN  NUMBER
,   x_end_customer_address1              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_address2              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_address3              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_address4              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_location              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_city                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_state                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_postal_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_customer_country               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

FUNCTION IB_OWNER
(   p_ib_owner                     IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION IB_INSTALLED_AT_LOCATION
(   p_ib_installed_at_location     IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION IB_CURRENT_LOCATION
(   p_ib_current_location          IN  VARCHAR2
) RETURN VARCHAR2;

--Recurring Charges
FUNCTION Charge_Periodicity
(   p_charge_periodicity_code          IN  VARCHAR2
) RETURN VARCHAR2;

/*3605052*/
FUNCTION  SERVICE_PERIOD
(   p_service_period            IN    VARCHAR2
    ,p_inventory_item_id         IN    NUMBER
) RETURN VARCHAR2;

FUNCTION  SERVICE_REFERENCE_TYPE        -- added for bug 5701246
(   p_service_reference_type_code            IN    VARCHAR2
) RETURN VARCHAR2;


FUNCTION CHANGE_REASON
(   p_change_reason_code                     IN  VARCHAR2
) RETURN VARCHAR2;

--Customer Acceptance
Procedure Get_Contingency_Attributes
(   p_contingency_id                 IN  NUMBER
   , x_contingency_name              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , x_contingency_description       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , x_expiration_event_attribute    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

Function Revrec_Event
(p_revrec_event_code  IN VARCHAR2) RETURN VARCHAR2;

Function Accepted_By
(p_accepted_by  IN NUMBER) RETURN VARCHAR2;


END OE_Id_To_Value;

/
