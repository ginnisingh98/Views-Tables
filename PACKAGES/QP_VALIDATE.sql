--------------------------------------------------------
--  DDL for Package QP_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: QPXSVATS.pls 120.4.12010000.1 2008/07/28 11:56:11 appldev ship $ */

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
FUNCTION Automatic(p_automatic_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Comments(p_comments IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Created_By(p_created_by IN NUMBER)RETURN BOOLEAN;
FUNCTION Creation_Date(p_creation_date IN DATE)RETURN BOOLEAN;
FUNCTION Currency(p_currency_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Discount_Lines(p_discount_lines_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION End_Date_Active(p_end_date_active IN DATE, p_start_date_active IN DATE := NULL)RETURN BOOLEAN;
FUNCTION Freight_Terms(p_freight_terms_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Gsa_Indicator(p_gsa_indicator IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Last_Updated_By(p_last_updated_by IN NUMBER)RETURN BOOLEAN;
FUNCTION Last_Update_Date(p_last_update_date IN DATE)RETURN BOOLEAN;
FUNCTION Last_Update_Login(p_last_update_login IN NUMBER)RETURN BOOLEAN;
FUNCTION List_Header(p_list_header_id IN NUMBER)RETURN BOOLEAN;
FUNCTION List_Type(p_list_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Program_Application(p_program_application_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Program(p_program_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Program_Update_Date(p_program_update_date IN DATE)RETURN BOOLEAN;
FUNCTION Prorate(p_prorate_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Request(p_request_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Rounding_Factor(p_rounding_factor IN NUMBER,
                         p_currency_code in varchar2 := NULL) RETURN BOOLEAN;
FUNCTION Ship_Method(p_ship_method_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Start_Date_Active(p_start_date_active IN DATE, p_end_date_active IN DATE := NULL)RETURN BOOLEAN;
FUNCTION Terms(p_terms_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Source_System(p_source_system_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pte_Code(p_pte_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Active(p_active_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Parent_List_header(p_parent_list_header_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Start_Date_Active_First(p_start_date_active_first IN DATE)RETURN BOOLEAN;
FUNCTION End_Date_Active_First(p_end_date_active_first IN DATE)RETURN BOOLEAN;
FUNCTION Active_Date_First_Type(p_active_date_first_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Start_Date_Active_Second(p_start_date_active_second IN DATE)RETURN BOOLEAN;
FUNCTION Global_Flag(p_global_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION End_Date_Active_Second(p_end_date_active_second IN DATE)RETURN BOOLEAN;
FUNCTION Active_Date_Second_Type(p_active_date_second_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Ask_For(p_ask_for_flag IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Arithmetic_Operator(p_arithmetic_operator IN VARCHAR2)RETURN BOOLEAN;
--FUNCTION Base_Qty(p_base_qty IN NUMBER)RETURN BOOLEAN;
FUNCTION Pricing_Phase(p_pricing_phase_id IN NUMBER)RETURN BOOLEAN;
--FUNCTION Base_Uom(p_base_uom_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Effective_Period_Uom(p_effective_period_uom IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Estim_Accrual_Rate(p_estim_accrual_rate IN NUMBER)RETURN BOOLEAN;
FUNCTION Generate_Using_Formula(p_generate_using_formula_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Gl_Class(p_gl_class_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Inventory_Item(p_inventory_item_id IN NUMBER)RETURN BOOLEAN;
FUNCTION List_Line(p_list_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION List_Line_Type(p_list_line_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION List_Price(p_list_price IN NUMBER)RETURN BOOLEAN;
FUNCTION From_Rltd_Modifier ( p_from_rltd_modifier_id IN NUMBER ) RETURN BOOLEAN;
FUNCTION To_Rltd_Modifier ( p_to_rltd_modifier_id IN NUMBER ) RETURN BOOLEAN;
FUNCTION Rltd_Modifier_Grp_No ( p_rltd_modifier_grp_no IN NUMBER ) RETURN BOOLEAN;
FUNCTION Rltd_Modifier_Grp_type ( p_rltd_modifier_grp_type IN VARCHAR2 ) RETURN BOOLEAN;
FUNCTION List_Price_Uom(p_list_price_uom_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Modifier_Level(p_modifier_level_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION New_Price(p_new_price IN NUMBER)RETURN BOOLEAN;
FUNCTION Number_Effective_Periods(p_number_effective_periods IN NUMBER)RETURN BOOLEAN;
FUNCTION Operand(p_operand IN NUMBER)RETURN BOOLEAN;
FUNCTION Organization(p_organization_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Organization(p_organization_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Override(p_override_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Percent_Price(p_percent_price IN NUMBER)RETURN BOOLEAN;
FUNCTION Price_Break_Type(p_price_break_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Price_By_Formula(p_price_by_formula_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Primary_Uom(p_primary_uom_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Print_On_Invoice(p_print_on_invoice_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Rebate_Subtype(p_rebate_subtype_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Rebate_Transaction_Type(p_rebate_trxn_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Related_Item(p_related_item_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Relationship_Type(p_relationship_type_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Reprice(p_reprice_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Revision(p_revision IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Revision_Date(p_revision_date IN DATE)RETURN BOOLEAN;
FUNCTION Revision_Reason(p_revision_reason_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Substitution_Attribute(p_substitution_attribute IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Substitution_Context(p_substitution_context IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Substitution_Value(p_substitution_value IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Accrual_Flag(p_accrual_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Group_Sequence(p_pricing_group_sequence IN NUMBER)RETURN BOOLEAN;
FUNCTION Incompatibility_Grp_Code(p_incompatibility_grp_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION List_Line_No(p_list_line_no IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Active_Flag(p_active_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Mobile_Download(p_mobile_download IN VARCHAR2)RETURN BOOLEAN; -- mkarya for bug 1944882
FUNCTION Product_Precedence(p_product_precedence IN NUMBER)RETURN BOOLEAN;
FUNCTION Exp_Period_Start_Date(p_expiration_period_start_date IN DATE)RETURN BOOLEAN;
FUNCTION Number_Expiration_Periods(p_number_expiration_periods IN NUMBER)RETURN BOOLEAN;
FUNCTION Expiration_Period_Uom(p_expiration_period_uom IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Expiration_Date(p_expiration_date IN DATE)RETURN BOOLEAN;
FUNCTION Estim_Gl_Value(p_estim_gl_value IN NUMBER)RETURN BOOLEAN;
FUNCTION Ben_Price_List_Line(p_benefit_price_list_line_id IN NUMBER)RETURN BOOLEAN;
--FUNCTION Recurring(p_recurring_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Benefit_Limit(p_benefit_limit IN NUMBER)RETURN BOOLEAN;
FUNCTION Charge_Type(p_charge_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Charge_Subtype(p_charge_subtype_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Benefit_Qty(p_benefit_qty IN NUMBER)RETURN BOOLEAN;
FUNCTION Benefit_Uom(p_benefit_uom_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Accrual_Conversion_Rate(p_accrual_conversion_rate IN NUMBER)RETURN BOOLEAN;
FUNCTION Proration_Type(p_proration_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Include_On_Returns_Flag(p_include_on_returns_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Recurring_Value(p_recurring_value IN NUMBER) RETURN BOOLEAN; -- block pricing

FUNCTION Comparison_Operator(p_comparison_operator_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Created_From_Rule(p_created_from_rule_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Excluder(p_excluder_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Qualifier_Attribute(p_qualifier_attribute IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Qualifier_Attr_Value(p_qualifier_attr_value IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Qualifier_Attr_Value_To(p_qualifier_attr_value_to IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Qualifier_Context(p_qualifier_context IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Qualifier_Grouping_No(p_qualifier_grouping_no IN NUMBER)RETURN BOOLEAN;
FUNCTION Qualifier(p_qualifier_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Qualifier_Rule(p_qualifier_rule_id IN NUMBER)RETURN BOOLEAN;

FUNCTION Accumulate(p_accumulate_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Attribute_Grouping_No(p_attribute_grouping_no IN NUMBER)RETURN BOOLEAN;
FUNCTION Pricing_Attribute(p_pricing_attribute IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute_Context(p_pricing_attribute_context IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute(p_pricing_attribute_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Pricing_Attr_Value_From(p_pricing_attr_value_from IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attr_Value_To(p_pricing_attr_value_to IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Product_Attribute(p_product_attribute IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Product_Attribute_Context(p_product_attribute_context IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Product_Attr_Value(p_product_attr_value IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Product_Uom ( p_product_uom_code IN VARCHAR2,
                       p_category_id IN NUMBER,
                       p_list_header_id IN NUMBER ) RETURN BOOLEAN; -- sfiresto bug 4753707
FUNCTION Product_Uom(p_product_uom_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Product_Attribute_Datatype(p_product_attribute_datatype IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute_Datatype(p_pricing_attribute_datatype IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Comparison_Operator_Code(p_comparison_operator_code IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Description(p_description IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Name(p_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Version(p_version_no IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Qualifier_Datatype(p_qualifier_datatype IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Qualifier_Date_Format(p_qualifier_date_format IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Qualifier_Number_Format(p_qualifier_number_format IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Qualifier_Precedence(p_qualifier_precedence IN NUMBER)RETURN BOOLEAN;

FUNCTION Flex_Title(p_flex_title IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Header(p_header_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Line(p_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Order_Price_Attrib(p_order_price_attrib_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Pricing_Attribute100(p_pricing_attribute100 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute11(p_pricing_attribute11 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute12(p_pricing_attribute12 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute13(p_pricing_attribute13 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute14(p_pricing_attribute14 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute15(p_pricing_attribute15 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute16(p_pricing_attribute16 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute17(p_pricing_attribute17 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute18(p_pricing_attribute18 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute19(p_pricing_attribute19 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute20(p_pricing_attribute20 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute21(p_pricing_attribute21 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute22(p_pricing_attribute22 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute23(p_pricing_attribute23 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute24(p_pricing_attribute24 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute25(p_pricing_attribute25 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute26(p_pricing_attribute26 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute27(p_pricing_attribute27 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute28(p_pricing_attribute28 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute29(p_pricing_attribute29 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute30(p_pricing_attribute30 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute31(p_pricing_attribute31 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute32(p_pricing_attribute32 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute33(p_pricing_attribute33 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute34(p_pricing_attribute34 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute35(p_pricing_attribute35 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute36(p_pricing_attribute36 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute37(p_pricing_attribute37 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute38(p_pricing_attribute38 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute39(p_pricing_attribute39 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute40(p_pricing_attribute40 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute41(p_pricing_attribute41 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute42(p_pricing_attribute42 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute43(p_pricing_attribute43 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute44(p_pricing_attribute44 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute45(p_pricing_attribute45 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute46(p_pricing_attribute46 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute47(p_pricing_attribute47 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute48(p_pricing_attribute48 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute49(p_pricing_attribute49 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute50(p_pricing_attribute50 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute51(p_pricing_attribute51 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute52(p_pricing_attribute52 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute53(p_pricing_attribute53 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute54(p_pricing_attribute54 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute55(p_pricing_attribute55 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute56(p_pricing_attribute56 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute57(p_pricing_attribute57 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute58(p_pricing_attribute58 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute59(p_pricing_attribute59 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute60(p_pricing_attribute60 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute61(p_pricing_attribute61 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute62(p_pricing_attribute62 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute63(p_pricing_attribute63 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute64(p_pricing_attribute64 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute65(p_pricing_attribute65 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute66(p_pricing_attribute66 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute67(p_pricing_attribute67 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute68(p_pricing_attribute68 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute69(p_pricing_attribute69 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute70(p_pricing_attribute70 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute71(p_pricing_attribute71 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute72(p_pricing_attribute72 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute73(p_pricing_attribute73 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute74(p_pricing_attribute74 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute75(p_pricing_attribute75 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute76(p_pricing_attribute76 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute77(p_pricing_attribute77 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute78(p_pricing_attribute78 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute79(p_pricing_attribute79 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute80(p_pricing_attribute80 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute81(p_pricing_attribute81 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute82(p_pricing_attribute82 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute83(p_pricing_attribute83 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute84(p_pricing_attribute84 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute85(p_pricing_attribute85 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute86(p_pricing_attribute86 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute87(p_pricing_attribute87 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute88(p_pricing_attribute88 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute89(p_pricing_attribute89 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute90(p_pricing_attribute90 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute91(p_pricing_attribute91 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute92(p_pricing_attribute92 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute93(p_pricing_attribute93 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute94(p_pricing_attribute94 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute95(p_pricing_attribute95 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute96(p_pricing_attribute96 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute97(p_pricing_attribute97 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute98(p_pricing_attribute98 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pricing_Attribute99(p_pricing_attribute99 IN VARCHAR2)RETURN BOOLEAN;


FUNCTION Formula(p_formula IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Price_Formula(p_price_formula_id IN NUMBER)RETURN BOOLEAN;

FUNCTION Numeric_Constant(p_numeric_constant IN NUMBER)RETURN BOOLEAN;
FUNCTION Reqd_Flag(p_reqd_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Price_Formula_Line(p_price_formula_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Price_Formula_Line_Type(p_formula_line_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Price_List_Line(p_price_list_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Price_Modifier_List(p_price_modifier_list_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Step_Number(p_step_number IN NUMBER)RETURN BOOLEAN;
FUNCTION Price_List_Name ( p_name IN VARCHAR2,
                           p_list_header_id in number,
                           p_version_no in varchar2 := NULL ) RETURN BOOLEAN;

FUNCTION Amount(p_amount IN NUMBER)RETURN BOOLEAN;
FUNCTION Basis(p_basis IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Limit_Exceed_Action(p_limit_exceed_action_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Limit(p_limit_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Limit_Level(p_limit_level_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Limit_Number(p_limit_number IN NUMBER)RETURN BOOLEAN;
FUNCTION Limit_Hold(p_limit_hold_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Multival_Attr1_Type(p_multival_attr1_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Multival_Attr1_Context(p_multival_attr1_context IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Multival_Attribute1(p_multival_attribute1 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Multival_Attr1_Datatype(p_multival_attr1_datatype IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Multival_Attr2_Type(p_multival_attr2_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Multival_Attr2_Context(p_multival_attr2_context IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Multival_Attribute2(p_multival_attribute2 IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Multival_Attr2_Datatype(p_multival_attr2_datatype IN VARCHAR2)RETURN BOOLEAN;


FUNCTION Limit_Attribute(p_limit_attribute IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Limit_Attribute_Context(p_limit_attribute_context IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Limit_Attribute(p_limit_attribute_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Limit_Attribute_Type(p_limit_attribute_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Limit_Attr_Datatype(p_limit_attr_datatype IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Limit_Attr_Value(p_limit_attr_value IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Limit_Balance(p_limit_balance_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Available_Amount(p_available_amount IN NUMBER)RETURN BOOLEAN;
FUNCTION Consumed_Amount(p_consumed_amount IN NUMBER)RETURN BOOLEAN;
FUNCTION Reserved_Amount(p_reserved_amount IN NUMBER)RETURN BOOLEAN;
FUNCTION Multival_Attr1_Value(p_multival_attr1_value IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Multival_Attr2_Value(p_multival_attr2_value IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Organization_Attr_Context(p_organization_attr_context IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Organization_Attribute(p_organization_attribute IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Organization_Attr_Value(p_organization_attr_value IN VARCHAR2)RETURN BOOLEAN;


FUNCTION Base_Currency(p_base_currency_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Currency_Header(p_currency_header_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Row(p_row_id IN ROWID)RETURN BOOLEAN;

FUNCTION Conversion_Date(p_conversion_date IN DATE)RETURN BOOLEAN;
FUNCTION Conversion_Date_Type(p_conversion_date_type IN VARCHAR2)RETURN BOOLEAN;
-- FUNCTION Conversion_Method(p_conversion_method IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Conversion_Type(p_conversion_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Currency_Detail(p_currency_detail_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Fixed_Value(p_fixed_value IN NUMBER)RETURN BOOLEAN;
FUNCTION Markup_Formula(p_markup_formula_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Markup_Operator(p_markup_operator IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Markup_Value(p_markup_value IN NUMBER)RETURN BOOLEAN;
FUNCTION To_Currency(p_to_currency_code IN VARCHAR2)RETURN BOOLEAN;
-- Added by Sunil Pandey 10/01/01
FUNCTION base_rounding_factor(p_base_rounding_factor IN NUMBER) RETURN BOOLEAN;
FUNCTION base_markup_formula(p_base_markup_formula_id IN NUMBER) RETURN BOOLEAN;
FUNCTION base_markup_operator(p_base_markup_operator IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Base_Markup_Value(p_Base_markup_value IN NUMBER) RETURN BOOLEAN;
-- Added by Sunil Pandey 10/01/01

FUNCTION Enabled(p_enabled_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Prc_Context_Code(p_prc_context_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Prc_Context(p_prc_context_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Prc_Context_Type(p_prc_context_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Seeded_Description(p_seeded_description IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Seeded(p_seeded_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Seeded_Prc_Context_Name(p_seeded_prc_context_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION User_Description(p_user_description IN VARCHAR2)RETURN BOOLEAN;
FUNCTION User_Prc_Context_Name(p_user_prc_context_name IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Availability_In_Basic(p_availability_in_basic IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Seeded_Format_Type(p_seeded_format_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Seeded_Precedence(p_seeded_precedence IN NUMBER)RETURN BOOLEAN;
FUNCTION Seeded_Segment_Name(p_seeded_segment_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Seeded_Valueset(p_seeded_valueset_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Seeded_Description_Seg(p_seeded_description IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Segment_Code(p_segment_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Segment(p_segment_id IN NUMBER)RETURN BOOLEAN;
-- Added new Column : Abhijit
FUNCTION application_id(p_application_id IN number)RETURN BOOLEAN;
FUNCTION Segment_Mapping_Column(p_segment_mapping_column IN VARCHAR2)RETURN BOOLEAN;
FUNCTION User_Format_Type(p_user_format_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION User_Precedence(p_user_precedence IN NUMBER)RETURN BOOLEAN;
FUNCTION User_Segment_Name(p_user_segment_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION User_Valueset(p_user_valueset_id IN NUMBER)RETURN BOOLEAN;
FUNCTION User_Description_Seg(p_user_description IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Lookup(p_lookup_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Lookup_Type(p_lookup_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Meaning(p_meaning IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Line_Level_Global_Struct(p_line_level_global_struct IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Line_Level_View_Name(p_line_level_view_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Order_Level_Global_Struct(p_order_level_global_struct IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Order_Level_View_Name(p_order_level_view_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pte(p_pte_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Request_Type(p_request_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Request_Type_Desc(p_request_type_desc IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Application_Short_Name(p_application_short_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Pte_Source_System(p_pte_source_system_id IN NUMBER)RETURN BOOLEAN;

FUNCTION Limits_Enabled(p_limits_enabled IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Lov_Enabled(p_lov_enabled IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Seeded_Sourcing_Method(p_seeded_sourcing_method IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Segment_Level(p_segment_level IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Segment_Pte(p_segment_pte_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Sourcing_Enabled(p_sourcing_enabled IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Sourcing_Status(p_sourcing_status IN VARCHAR2)RETURN BOOLEAN;
FUNCTION User_Sourcing_Method(p_user_sourcing_method IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Attribute_Sourcing(p_attribute_sourcing_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Attribute_Sourcing_Level(p_attribute_sourcing_level IN VARCHAR2)RETURN BOOLEAN;
--FUNCTION Application_Id(p_application_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Seeded_Sourcing_Type(p_seeded_sourcing_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Seeded_Value_String(p_seeded_value_string IN VARCHAR2)RETURN BOOLEAN;
FUNCTION User_Sourcing_Type(p_user_sourcing_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION User_Value_String(p_user_value_string IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Required_Flag(p_required_flag IN VARCHAR2)RETURN BOOLEAN;
--
FUNCTION Curr_Attribute_Type(p_curr_attribute_type IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Curr_Attribute_Context(p_curr_attribute_context IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Curr_Attribute(p_curr_attribute IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Curr_Attribute_Value(p_curr_attribute_value IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Precedence(p_precedence IN NUMBER) RETURN BOOLEAN;
FUNCTION List_Source_Code(p_List_Source_Code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Net_Amount(p_net_amount_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Accum_Attribute(p_accum_attribute IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Break_UOM_Code(p_break_uom_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Break_UOM_Context(p_break_uom_context IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Break_UOM_Attribute(p_break_uom_attribute IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Functional_Area(p_functional_area_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Pte_Sourcesystem_Fnarea(p_pte_sourcesystem_fnarea_id IN NUMBER)RETURN BOOLEAN;
--  END GEN validate

--Blanket Pricing
FUNCTION Orig_System_Header_Ref(p_Orig_System_Header_Ref IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Shareable_Flag(p_Shareable_Flag IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Sold_To_Org_Id(p_Sold_To_Org_Id IN NUMBER) RETURN BOOLEAN;
FUNCTION Customer_Item_Id(p_Customer_Item_Id IN NUMBER) RETURN BOOLEAN;
FUNCTION Locked_From_List_Header_Id(p_Locked_From_List_Header_Id IN NUMBER) RETURN BOOLEAN;
--added for MOAC
FUNCTION Org_Id(p_org_id IN NUMBER) RETURN BOOLEAN;
--added for TCA
FUNCTION Party_Hierarchy_Enabled_flag(p_party_hierarchy_enabled_flag IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Qualify_Hier_Descendent_Flag(p_qualify_hier_descendent_flag IN VARCHAR2) RETURN BOOLEAN;

END QP_Validate;

/
