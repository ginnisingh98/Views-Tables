--------------------------------------------------------
--  DDL for Package QP_VALUE_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALUE_TO_ID" AUTHID CURRENT_USER AS
/* $Header: QPXSVIDS.pls 120.2 2005/07/15 15:52:27 appldev ship $ */

--  Procedure Get_Attr_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  conversion functions.
--
--  DO NOT MODIFY

PROCEDURE Get_Attr_Tbl;

--  Prototypes for Value_To_Id functions.

--  START GEN value_to_id

--  Generator will append new prototypes before end generate comment.
FUNCTION Key_Flex
(   p_key_flex_code                 IN  VARCHAR2
,   p_structure_number              IN  NUMBER
,   p_appl_short_name               IN  VARCHAR2
,   p_segment_array                 IN  FND_FLEX_EXT.SegmentArray
) RETURN NUMBER;

--  Automatic

FUNCTION Automatic
(   p_automatic                     IN  VARCHAR2
) RETURN VARCHAR2;

--  Currency

FUNCTION Currency
(   p_currency                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Discount_Lines

FUNCTION Discount_Lines
(   p_discount_lines                IN  VARCHAR2
) RETURN VARCHAR2;

--  Freight_Terms

FUNCTION Freight_Terms
(   p_freight_terms                 IN  VARCHAR2
) RETURN VARCHAR2;

--  List_Header

FUNCTION List_Header
(   p_list_header                   IN  VARCHAR2
) RETURN NUMBER;

--  List_Type

FUNCTION List_Type
(   p_list_type                     IN  VARCHAR2
) RETURN VARCHAR2;

--  Prorate

FUNCTION Prorate
(   p_prorate                       IN  VARCHAR2
) RETURN VARCHAR2;

--  Ship_Method

FUNCTION Ship_Method
(   p_ship_method                   IN  VARCHAR2
) RETURN VARCHAR2;

--Begin code added by rchellam for OKC
--Agreement_Source

FUNCTION Agreement_Source
(   p_agreement_source              IN  VARCHAR2
) RETURN VARCHAR2;
--End code added by rchellam for OKC

--  Terms

FUNCTION Terms
(   p_terms                         IN  VARCHAR2
) RETURN NUMBER;

--  Base_Uom

FUNCTION Base_Uom
(   p_base_uom                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Generate_Using_Formula

FUNCTION Generate_Using_Formula
(   p_generate_using_formula        IN  VARCHAR2
) RETURN NUMBER;

--  Gl_Class

/* FUNCTION Gl_Class
(   p_gl_class                      IN  VARCHAR2
) RETURN NUMBER;  */

--  Inventory_Item

FUNCTION Inventory_Item
(   p_inventory_item                IN  VARCHAR2
) RETURN NUMBER;

--  List_Line

FUNCTION List_Line
(   p_list_line                     IN  VARCHAR2
) RETURN NUMBER;

--  List_Line_Type

FUNCTION List_Line_Type
(   p_list_line_type                IN  VARCHAR2
) RETURN VARCHAR2;

--  List_Price_Uom

FUNCTION List_Price_Uom
(   p_list_price_uom                IN  VARCHAR2
) RETURN VARCHAR2;

--  Modifier_Level

FUNCTION Modifier_Level
(   p_modifier_level                IN  VARCHAR2
) RETURN VARCHAR2;

--  Organization

FUNCTION Organization
(   p_organization                  IN  VARCHAR2
) RETURN NUMBER;

--  Override

FUNCTION Override
(   p_override                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Price_Break_Type

FUNCTION Price_Break_Type
(   p_price_break_type              IN  VARCHAR2
) RETURN VARCHAR2;

--  Price_By_Formula

FUNCTION Price_By_Formula
(   p_price_by_formula              IN  VARCHAR2
) RETURN NUMBER;

--  Primary_Uom

FUNCTION Primary_Uom
(   p_primary_uom                   IN  VARCHAR2
) RETURN VARCHAR2;

--  Print_On_Invoice

FUNCTION Print_On_Invoice
(   p_print_on_invoice              IN  VARCHAR2
) RETURN VARCHAR2;

--  Rebate_Subtype

/* FUNCTION Rebate_Subtype
(   p_rebate_subtype                IN  VARCHAR2
) RETURN VARCHAR2;  */

--  Rebate_Transaction_Type

FUNCTION Rebate_Transaction_Type
(   p_rebate_transaction_type       IN  VARCHAR2
) RETURN VARCHAR2;

--  Related_Item

FUNCTION Related_Item
(   p_related_item                  IN  VARCHAR2
) RETURN NUMBER;

--  Relationship_Type

FUNCTION Relationship_Type
(   p_relationship_type             IN  VARCHAR2
) RETURN NUMBER;

--  Reprice

FUNCTION Reprice
(   p_reprice                       IN  VARCHAR2
) RETURN VARCHAR2;

--  Revision_Reason

--  Comparison_Operator

/*FUNCTION Comparison_Operator
(   p_comparison_operator           IN  VARCHAR2
) RETURN VARCHAR2;*/

--  Created_From_Rule

FUNCTION Created_From_Rule
(   p_created_from_rule             IN  VARCHAR2
) RETURN NUMBER;

--  Excluder

FUNCTION Excluder
(   p_excluder                      IN  VARCHAR2
) RETURN VARCHAR2;

--  Qualifier

/*FUNCTION Qualifier
(   p_qualifier                     IN  VARCHAR2
) RETURN NUMBER;*/

--  Qualifier_Rule

FUNCTION Qualifier_Rule
(   p_qualifier_rule                IN  VARCHAR2
) RETURN NUMBER;

--  Accumulate

FUNCTION Accumulate
(   p_accumulate                    IN  VARCHAR2
) RETURN VARCHAR2;

--  Pricing_Attribute

FUNCTION Pricing_Attribute
(   p_pricing_attribute_desc        IN  VARCHAR2,
    p_context                       IN  VARCHAR2
) RETURN VARCHAR2;

--  Pricing_Attr_Value_From

FUNCTION Pricing_Attr_Value_From
(   p_pricing_attr_value_from_desc  IN  VARCHAR2,
    p_context                       IN  VARCHAR2,
    p_attribute                     IN  VARCHAR2
) RETURN VARCHAR2;

--  Pricing_Attr_Value_To

FUNCTION Pricing_Attr_Value_To
(   p_pricing_attr_value_to_desc    IN  VARCHAR2,
    p_context                       IN  VARCHAR2,
    p_attribute                     IN  VARCHAR2
) RETURN VARCHAR2;

--  Qualifier_Attribute

FUNCTION Qualifier_Attribute
(   p_qualifier_attribute_desc      IN  VARCHAR2,
    p_context                       IN  VARCHAR2
) RETURN VARCHAR2;

--  Qualifier_Attr_Value

FUNCTION Qualifier_Attr_Value
(   p_qualifier_attr_value_desc     IN  VARCHAR2,
    p_context                       IN  VARCHAR2,
    p_attribute                     IN  VARCHAR2
) RETURN VARCHAR2;

--  Qualifier_Attr_Value_To

FUNCTION Qualifier_Attr_Value_To
(   p_qualifier_attr_value_to_desc     IN  VARCHAR2,
    p_context                       IN  VARCHAR2,
    p_attribute                     IN  VARCHAR2
) RETURN VARCHAR2;

--  Product_Uom

FUNCTION Product_Uom
(   p_product_uom                   IN  VARCHAR2
) RETURN VARCHAR2;

--  Header

FUNCTION Header
(   p_header                        IN  VARCHAR2
) RETURN NUMBER;

--  Line

FUNCTION Line
(   p_line                          IN  VARCHAR2
) RETURN NUMBER;

--  Order_Price_Attrib

FUNCTION Order_Price_Attrib
(   p_order_price_attrib            IN  VARCHAR2
) RETURN NUMBER;



--  Price_Formula

FUNCTION Price_Formula
(   p_price_formula                 IN  VARCHAR2
) RETURN NUMBER;

--  Price_Formula_Line

FUNCTION Price_Formula_Line
(   p_price_formula_line            IN  VARCHAR2
) RETURN NUMBER;

--  Price_Formula_Line_Type

FUNCTION Price_Formula_Line_Type
(   p_price_formula_line_type       IN  VARCHAR2
) RETURN VARCHAR2;

--  Price_List_Line

FUNCTION Price_List_Line
(   p_price_list_line               IN  VARCHAR2
) RETURN NUMBER;

--  Price_Modifier_List

FUNCTION Price_Modifier_List
(   p_price_modifier_list           IN  VARCHAR2
) RETURN NUMBER;

--  Limit_Exceed_Action

FUNCTION Limit_Exceed_Action
(   p_limit_exceed_action           IN  VARCHAR2
) RETURN VARCHAR2;

--  Limit

FUNCTION Limit
(   p_limit                         IN  VARCHAR2
) RETURN NUMBER;

--  Limit_Level

FUNCTION Limit_Level
(   p_limit_level                   IN  VARCHAR2
) RETURN VARCHAR2;

--  Comparison_Operator

FUNCTION Comparison_Operator
(   p_comparison_operator           IN  VARCHAR2
) RETURN VARCHAR2;

--  Limit_Attribute

FUNCTION Limit_Attribute
(   p_limit_attribute               IN  VARCHAR2
) RETURN NUMBER;

--  Limit_Balance

FUNCTION Limit_Balance
(   p_limit_balance                 IN  VARCHAR2
) RETURN NUMBER;

--  Base_Currency

FUNCTION Base_Currency
(   p_base_currency                 IN  VARCHAR2
) RETURN VARCHAR2;

--  Currency_Header

FUNCTION Currency_Header
(   p_currency_header               IN  VARCHAR2
) RETURN NUMBER;

--  Row

/* Commented by Sunil
FUNCTION Row
(   p_row                           IN  VARCHAR2
) RETURN ROWID;
   Commented by Sunil */

--  Currency_Detail

FUNCTION Currency_Detail
(   p_currency_detail               IN  VARCHAR2
) RETURN NUMBER;

--  Markup_Formula

FUNCTION Markup_Formula
(   p_markup_formula                IN  VARCHAR2
) RETURN NUMBER;

--  Base Markup_Formula

FUNCTION Base_Markup_Formula
(   p_base_markup_formula                IN  VARCHAR2
) RETURN NUMBER;

--  To_Currency

FUNCTION To_Currency
(   p_to_currency                   IN  VARCHAR2
) RETURN VARCHAR2;

--  Enabled

FUNCTION Enabled
(   p_enabled                       IN  VARCHAR2
) RETURN VARCHAR2;

--  Prc_Context

FUNCTION Prc_Context
(   p_prc_context                   IN  VARCHAR2
) RETURN NUMBER;

--  Seeded

FUNCTION Seeded
(   p_seeded                        IN  VARCHAR2
) RETURN VARCHAR2;

--  Seeded_Valueset

FUNCTION Seeded_Valueset
(   p_seeded_valueset               IN  VARCHAR2
) RETURN NUMBER;

--  Segment

FUNCTION Segment
(   p_segment                       IN  VARCHAR2
) RETURN NUMBER;

--  User_Valueset

FUNCTION User_Valueset
(   p_user_valueset                 IN  VARCHAR2
) RETURN NUMBER;

--  Lookup

FUNCTION Lookup
(   p_lookup                        IN  VARCHAR2
) RETURN VARCHAR2;

--  Pte

FUNCTION Pte
(   p_pte                           IN  VARCHAR2
) RETURN VARCHAR2;

--  Request_Type

FUNCTION Request_Type
(   p_request_type                  IN  VARCHAR2
) RETURN VARCHAR2;

--  Pte_Source_System

FUNCTION Pte_Source_System
(   p_pte_source_system             IN  VARCHAR2
) RETURN NUMBER;

--  Segment_Pte

FUNCTION Segment_Pte
(   p_segment_pte                   IN  VARCHAR2
) RETURN NUMBER;

--  Attribute_Sourcing

FUNCTION Attribute_Sourcing
(   p_attribute_sourcing            IN  VARCHAR2
) RETURN NUMBER;

--  Functional_Area

FUNCTION Functional_Area
(   p_functional_area               IN  VARCHAR2
) RETURN NUMBER;

--  Pte_Sourcesystem_Fnarea

FUNCTION Pte_Sourcesystem_Fnarea
(   p_pte_sourcesystem_fnarea       IN  VARCHAR2
) RETURN NUMBER;
--  END GEN value_to_id

FUNCTION Accounting_Rule
(   p_accounting_rule               IN  VARCHAR2
) RETURN NUMBER;



FUNCTION Agreement_Contact
(   p_Agreement_Contact                      IN  VARCHAR2
) RETURN VARCHAR2;


FUNCTION Agreement
(   p_agreement                     IN  VARCHAR2
) RETURN NUMBER;


FUNCTION Agreement_Type
(   p_Agreement_Type                      IN  VARCHAR2
) RETURN VARCHAR2;




FUNCTION Customer
(   p_Customer                      IN  VARCHAR2
) RETURN VARCHAR2;



FUNCTION Invoice_Contact
(   p_Invoice_Contact                      IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Invoice_To_Site_Use
(   p_Invoice_To_Site_Use                      IN  VARCHAR2
) RETURN VARCHAR2;


FUNCTION Invoicing_Rule
(   p_invoicing_rule                IN  VARCHAR2
) RETURN NUMBER;

FUNCTION override_arule
(   p_override_arule                      IN  VARCHAR2
) RETURN VARCHAR2;



FUNCTION override_irule
(   p_override_irule                      IN  VARCHAR2
) RETURN VARCHAR2;



FUNCTION Price_List
(   p_price_list                    IN  VARCHAR2
) RETURN NUMBER;



FUNCTION Revision_Reason
(   p_Revision_Reason                      IN  VARCHAR2
) RETURN VARCHAR2;



FUNCTION Salesrep
(   p_salesrep                      IN  VARCHAR2
) RETURN NUMBER;



FUNCTION Term
(   p_Term                      IN  VARCHAR2
) RETURN VARCHAR2;


PROCEDURE Flex_Meaning_To_Value_Id (p_flexfield_name IN VARCHAR2,
    p_context        IN VARCHAR2,
    p_segment        IN VARCHAR2,
    p_meaning        IN VARCHAR2,
    x_value         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    x_id            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    x_format_type   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


END QP_Value_To_Id;

 

/
