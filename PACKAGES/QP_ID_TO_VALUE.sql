--------------------------------------------------------
--  DDL for Package QP_ID_TO_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_ID_TO_VALUE" AUTHID CURRENT_USER AS
/* $Header: QPXSIDVS.pls 120.1 2005/07/15 15:43:13 appldev ship $ */

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

FUNCTION Automatic
(   p_automatic_flag                IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Currency
(   p_currency_code                 IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Discount_Lines
(   p_discount_lines_flag           IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Freight_Terms
(   p_freight_terms_code            IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION List_Header
(   p_list_header_id                IN  NUMBER
) RETURN VARCHAR2;

FUNCTION List_Type
(   p_list_type_code                IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Prorate
(   p_prorate_flag                  IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Ship_Method
(   p_ship_method_code              IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Terms
(   p_terms_id                      IN  NUMBER
) RETURN VARCHAR2;

--Begin code added by rchellam for OKC
FUNCTION Agreement_Source
(   p_agreement_source_code         IN  VARCHAR2
) RETURN VARCHAR2;
--End code added by rchellam for OKC

FUNCTION Base_Uom
(   p_base_uom_code                 IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Generate_Using_Formula
(   p_generate_using_formula_id     IN  NUMBER
) RETURN VARCHAR2;

/* FUNCTION Gl_Class
(   p_gl_class_id                   IN  NUMBER
) RETURN VARCHAR2; */

FUNCTION Inventory_Item
(   p_inventory_item_id             IN  NUMBER
) RETURN VARCHAR2;

FUNCTION List_Line
(   p_list_line_id                  IN  NUMBER
) RETURN VARCHAR2;

FUNCTION List_Line_Type
(   p_list_line_type_code           IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION List_Price_Uom
(   p_list_price_uom_code           IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Modifier_Level
(   p_modifier_level_code           IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Organization
(   p_organization_id               IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Organization
(   p_organization_flag               IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Override
(   p_override_flag                 IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Price_Break_Type
(   p_price_break_type_code         IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Price_By_Formula
(   p_price_by_formula_id           IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Primary_Uom
(   p_primary_uom_flag              IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Print_On_Invoice
(   p_print_on_invoice_flag         IN  VARCHAR2
) RETURN VARCHAR2;

/*FUNCTION Rebate_Subtype
(   p_rebate_subtype_code           IN  VARCHAR2
) RETURN VARCHAR2; */

FUNCTION Rebate_Transaction_Type
(   p_rebate_trxn_type_code         IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Related_Item
(   p_related_item_id               IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Relationship_Type
(   p_relationship_type_id          IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Reprice
(   p_reprice_flag                  IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Revision_Reason
(   p_revision_reason_code          IN  VARCHAR2
) RETURN VARCHAR2;

/*FUNCTION Comparison_Operator
(   p_comparison_operator_code      IN  VARCHAR2
) RETURN VARCHAR2;*/

FUNCTION Created_From_Rule
(   p_created_from_rule_id          IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Excluder
(   p_excluder_flag                 IN  VARCHAR2
) RETURN VARCHAR2;

/*FUNCTION Qualifier
(   p_qualifier_id                  IN  NUMBER
) RETURN VARCHAR2;*/

FUNCTION Qualifier_Rule
(   p_qualifier_rule_id             IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Accumulate
(   p_accumulate_flag               IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Pricing_Attribute
(   p_pricing_attribute_id          IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Product_Uom
(   p_product_uom_code              IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Header
(   p_header_id                     IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Line
(   p_line_id                       IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Order_Price_Attrib
(   p_order_price_attrib_id         IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Price_Formula
(   p_price_formula_id              IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Price_Formula_Line
(   p_price_formula_line_id         IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Price_Formula_Line_Type
(   p_formula_line_type_code        IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Price_List_Line
(   p_price_list_line_id            IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Price_Modifier_List
(   p_price_modifier_list_id        IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Arithmetic_Operator
(   p_arithmetic_operator        IN VARCHAR2
) RETURN VARCHAR2;

-- Agreement Related functions
FUNCTION Accounting_Rule
(   p_accounting_rule_id            IN  NUMBER
) RETURN VARCHAR2;


FUNCTION Agreement_Contact
(   p_agreement_contact_id          IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Agreement
(   p_agreement_id                  IN  NUMBER
) RETURN VARCHAR2;



FUNCTION Agreement_Type
(   p_agreement_type_code           IN  VARCHAR2
) RETURN VARCHAR2;


FUNCTION Customer
(   p_sold_to_org_id                   IN  NUMBER
) RETURN VARCHAR2;

/* FUNCTION Freight_Terms
(   p_freight_terms_code            IN  VARCHAR2
) RETURN VARCHAR2; */


FUNCTION Invoice_Contact
(   p_invoice_contact_id            IN  NUMBER
) RETURN VARCHAR2;

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



FUNCTION Override_Irule
(   p_override_irule_flag           IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Price_List
(   p_price_list_id                 IN  NUMBER
) RETURN VARCHAR2;

/* FUNCTION Override_Irule
(   p_override_irule_flag           IN  VARCHAR2
) RETURN VARCHAR2; */

/* FUNCTION Revision_Reason
(   p_revision_reason_code          IN  VARCHAR2
) RETURN VARCHAR2; */

FUNCTION Salesrep
(   p_salesrep_id                   IN  NUMBER
) RETURN VARCHAR2;


/* FUNCTION Ship_Method
(   p_ship_method_code              IN  VARCHAR2
) RETURN VARCHAR2; */

---**

FUNCTION Term
(   p_term_id                       IN  NUMBER
) RETURN VARCHAR2;








FUNCTION Limit_Exceed_Action
(   p_limit_exceed_action_code      IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Limit
(   p_limit_id                      IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Limit_Level
(   p_limit_level_code              IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Comparison_Operator
(   p_comparison_operator_code      IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Limit_Attribute
(   p_limit_attribute_id            IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Limit_Balance
(   p_limit_balance_id              IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Base_Currency
(   p_base_currency_code            IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Currency_Header
(   p_currency_header_id            IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Base_Markup_Formula
(   p_base_markup_formula_id        IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Row
(   p_row_id                        IN  ROWID
) RETURN VARCHAR2;

FUNCTION Currency_Detail
(   p_currency_detail_id            IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Markup_Formula
(   p_markup_formula_id             IN  NUMBER
) RETURN VARCHAR2;

FUNCTION To_Currency
(   p_to_currency_code              IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Enabled
(   p_enabled_flag                  IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Prc_Context
(   p_prc_context_id                IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Seeded
(   p_seeded_flag                   IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Seeded_Valueset
(   p_seeded_valueset_id            IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Segment
(   p_segment_id                    IN  NUMBER
) RETURN VARCHAR2;

FUNCTION User_Valueset
(   p_user_valueset_id              IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Lookup
(   p_lookup_code                   IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Pte
(   p_pte_code                      IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Request_Type
(   p_request_type_code             IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Pte_Source_System
(   p_pte_source_system_id          IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Segment_Pte
(   p_segment_pte_id                IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Attribute_Sourcing
(   p_attribute_sourcing_id         IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Functional_Area
(   p_functional_area_id            IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Pte_Sourcesystem_Fnarea
(   p_pte_sourcesystem_fnarea_id    IN  NUMBER
) RETURN VARCHAR2;
--  END GEN Id_To_Value

END QP_Id_To_Value;

 

/
