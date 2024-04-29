--------------------------------------------------------
--  DDL for Package OE_VALIDATE_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_ATTR" AUTHID CURRENT_USER AS
/* $Header: OEXSVXTS.pls 120.2 2005/12/14 16:26:05 shulin noship $ */

--  Procedure Get_Attr_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  validation functions.
--
--  DO NOT MODIFY

PROCEDURE Get_Attr_Tbl;

--  Prototypes for validate functions.

--  START GEN validate

--  Generator will append new prototypes before end generate comment.

FUNCTION Desc_Flex ( p_flex_name IN VARCHAR2 )RETURN BOOLEAN;
FUNCTION Agreement(p_agreement_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Created_By(p_created_by IN NUMBER)RETURN BOOLEAN;
FUNCTION Creation_Date(p_creation_date IN DATE)RETURN BOOLEAN;
FUNCTION Discount(p_discount_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Last_Updated_By(p_last_updated_by IN NUMBER)RETURN BOOLEAN;
FUNCTION Last_Update_Date(p_last_update_date IN DATE)RETURN BOOLEAN;
FUNCTION Last_Update_Login(p_last_update_login IN NUMBER)RETURN BOOLEAN;
FUNCTION Price_List(p_price_list_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Pricing_Contract(p_pricing_contract_id IN NUMBER)RETURN BOOLEAN;

FUNCTION Accounting_Rule(p_accounting_rule_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Agreement_Contact(p_agreement_contact_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Agreement_Num(p_agreement_num IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Agreement_Type(p_agreement_type_code IN VARCHAR2)RETURN BOOLEAN;
/* FUNCTION Customer(p_customer_id IN NUMBER)RETURN BOOLEAN; */
FUNCTION Customer(p_sold_to_org_id IN NUMBER)RETURN BOOLEAN;
FUNCTION End_Date_Active(p_end_date_active IN DATE)RETURN BOOLEAN;
FUNCTION Start_Date_End_Date(p_start_date_active	IN DATE,
                             p_end_date_active		IN DATE)RETURN BOOLEAN;
FUNCTION Freight_Terms(p_freight_terms_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Invoice_Contact(p_invoice_contact_id IN NUMBER)RETURN BOOLEAN;
/* FUNCTION Invoice_To_Site_Use(p_invoice_to_site_use_id IN NUMBER)RETURN BOOLEAN;  */
FUNCTION Invoice_To_Site_Use(p_invoice_to_org_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Invoicing_Rule(p_invoicing_rule_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Name(p_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Override_Arule(p_override_arule_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Override_Irule(p_override_irule_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Purchase_Order_Num(p_purchase_order_num IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Revision(p_revision IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Revision_Date(p_revision_date IN DATE)RETURN BOOLEAN;
FUNCTION Revision_Reason(p_revision_reason_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Salesrep(p_salesrep_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Ship_Method(p_ship_method_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Signature_Date(p_signature_date IN DATE)RETURN BOOLEAN;
FUNCTION Start_Date_Active(p_start_date_active IN DATE)RETURN BOOLEAN;
FUNCTION Term(p_term_id IN NUMBER)RETURN BOOLEAN;

--Begin code added by rchellam for OKC
FUNCTION Agreement_Source(p_agreement_source_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Orig_System_Agr(p_orig_system_agr_id IN NUMBER)RETURN BOOLEAN;
--End code added by rchellam for OKC

-- Added for bug#4029589
FUNCTION Invoice_To_Customer_Id(p_invoice_to_customer_id IN NUMBER)RETURN BOOLEAN;

FUNCTION Comments(p_comments IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Currency(p_currency_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Currency ( p_currency_code IN VARCHAR2,
                    x_fmt_mask OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                    x_fmt_mask_ext OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
RETURN BOOLEAN;
FUNCTION Description(p_description IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Program_Application(p_program_application_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Program(p_program_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Program_Update_Date(p_program_update_date IN DATE)RETURN BOOLEAN;
FUNCTION Request(p_request_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Rounding_Factor(p_rounding_factor IN NUMBER)RETURN BOOLEAN;
FUNCTION Secondary_Price_List(p_secondary_price_list_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Terms(p_terms_id IN NUMBER)RETURN BOOLEAN;

FUNCTION Amount(p_amount IN NUMBER)RETURN BOOLEAN;
FUNCTION Automatic_Discount(p_automatic_discount_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Discount_Lines(p_discount_lines_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Discount_Type(p_discount_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Gsa_Indicator(p_gsa_indicator IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Manual_Discount(p_manual_discount_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Override_Allowed(p_override_allowed_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Percent(p_percent IN NUMBER)RETURN BOOLEAN;
FUNCTION Prorate(p_prorate_flag IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Customer_Item(p_customer_item_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Inventory_Item(p_inventory_item_id IN NUMBER,
                        p_organization_id IN NUMBER DEFAULT FND_API.G_MISS_NUM )RETURN BOOLEAN;
FUNCTION List_Price(p_list_price IN NUMBER)RETURN BOOLEAN;
FUNCTION Method(p_method_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Price_List_Line(p_price_list_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Pricing_Attribute1(p_pricing_attribute1 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute10(p_pricing_attribute10 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute11(p_pricing_attribute11 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute12(p_pricing_attribute12 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute13(p_pricing_attribute13 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute14(p_pricing_attribute14 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute15(p_pricing_attribute15 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute2(p_pricing_attribute2 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute3(p_pricing_attribute3 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute4(p_pricing_attribute4 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute5(p_pricing_attribute5 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute6(p_pricing_attribute6 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute7(p_pricing_attribute7 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute8(p_pricing_attribute8 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute9(p_pricing_attribute9 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Context(p_pricing_context IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Rule(p_pricing_rule_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Reprice(p_reprice_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Unit(p_unit_code IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Customer_Class(p_customer_class_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Discount_Customer(p_discount_customer_id IN NUMBER)RETURN BOOLEAN;
/* FUNCTION Site_Use(p_site_use_id IN NUMBER)RETURN BOOLEAN; */
FUNCTION Site_Use(p_site_org_id IN NUMBER)RETURN BOOLEAN;

FUNCTION Discount_Line(p_discount_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Entity(p_entity_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Entity_Value(p_entity_value IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Price(p_price IN NUMBER)RETURN BOOLEAN;

FUNCTION Method_Type(p_method_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Price_Break_High(p_price_break_high IN NUMBER)RETURN BOOLEAN;
FUNCTION Price_Break_Low(p_price_break_low IN NUMBER)RETURN BOOLEAN;

PROCEDURE getservitemflag(p_inventory_item_id IN NUMBER,
                          p_organization_id IN NUMBER,
                          x_unit_code OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                          x_service_item_flag OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

FUNCTION PRIMARY_EXISTS( p_price_list_id IN number,
                         p_inventory_item_id IN number,
                         p_customer_item_id IN number,
                         p_pricing_attribute1 IN VARCHAR2,
                         p_pricing_attribute2 IN VARCHAR2,
                         p_pricing_attribute3 IN VARCHAR2,
                         p_pricing_attribute4 IN VARCHAR2,
                         p_pricing_attribute5 IN VARCHAR2,
                         p_pricing_attribute6 IN VARCHAR2,
                         p_pricing_attribute7 IN VARCHAR2,
                         p_pricing_attribute8 IN VARCHAR2,
                         p_pricing_attribute9 IN VARCHAR2,
                         p_pricing_attribute10 IN VARCHAR2,
                         p_pricing_attribute11 IN VARCHAR2,
                         p_pricing_attribute12 IN VARCHAR2,
                         p_pricing_attribute13 IN VARCHAR2,
                         p_pricing_attribute14 IN VARCHAR2,
                         p_pricing_attribute15 IN VARCHAR2,
			 p_start_date_active IN DATE,
			 p_end_date_active IN DATE
                        ) RETURN BOOLEAN;
FUNCTION PRIMARY(p_primary IN VARCHAR2) RETURN BOOLEAN;
FUNCTION LIST_LINE_TYPE(p_list_line_type_code in VARCHAR2) RETURN BOOLEAN;
--  END GEN validate

END OE_Validate_Attr;

 

/
