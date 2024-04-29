--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE" AS
/* $Header: QPXSVATB.pls 120.10.12010000.2 2008/10/15 12:56:46 jputta ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate';

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  validation functions.
--
--  DO NOT REMOVE

PROCEDURE Get_Attr_Tbl
IS
I                             NUMBER:=0;
BEGIN

    FND_API.g_attr_tbl.DELETE;

--  START GEN attributes

--  Generator will append new attributes before end generate comment.

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Desc_Flex';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'automatic';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'comments';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'created_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'creation_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount_lines';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'end_date_active';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'freight_terms';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'gsa_indicator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_updated_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_login';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_application';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'prorate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'request';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rounding_factor';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_method';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'start_date_active';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'terms';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'source_system';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pte_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'active';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'parent_list_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'start_date_active_first';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'end_date_active_first';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'active_date_first_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'start_date_active_second';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'global_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'end_date_active_second';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'active_date_second_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ask_for_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'arithmetic_operator';
--    I := I + 1;
--    FND_API.g_attr_tbl(I).name     := 'base_qty';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_phase_id';
--    I := I + 1;
--    FND_API.g_attr_tbl(I).name     := 'base_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'effective_period_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'estim_accrual_rate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'generate_using_formula';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'gl_class';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'inventory_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_line_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_price';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_price_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'modifier_level';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'new_price';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'number_effective_periods';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'operand';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'organization';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'override';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'percent_price';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_break_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_by_formula';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'primary_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'print_on_invoice';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rebate_subtype';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rebate_transaction_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'related_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'relationship_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reprice';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'revision';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'revision_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'revision_reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'substitution_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'substitution_context';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'substitution_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'accrual_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_group_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'incompatibility_grp_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_line_no';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'active_flag';
    I := I + 1;
    --mkarya for bug 1944882
    FND_API.g_attr_tbl(I).name     := 'mobile_download';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'product_precedence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'expiration_period_start_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'number_expiration_periods';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'expiration_period_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'expiration_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'estim_gl_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'benefit_price_list_line_id';
--    I := I + 1;
--    FND_API.g_attr_tbl(I).name     := 'recurring_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'benefit_limit';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'charge_type_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'charge_subtype_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'benefit_qty';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'benefit_uom_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'accrual_conversion_rate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'proration_type_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'include_on_returns_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'recurring_value'; -- block pricing
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'comparison_operator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'created_from_rule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'excluder';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_attr_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_attr_value_to';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_context';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_grouping_no';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_rule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'accumulate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'attribute_grouping_no';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute_context';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attr_value_from';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attr_value_to';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'product_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'product_attribute_context';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'product_attr_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'product_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'product_attribute_datatype';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute_datatype';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'comparison_operator_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'description';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'version_no';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_datatype';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_date_format';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_number_format';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualifier_precedence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'flex_title';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_price_attrib';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute100';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute11';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute12';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute13';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute14';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute15';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute16';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute17';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute18';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute19';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute20';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute21';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute22';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute23';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute24';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute25';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute26';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute27';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute28';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute29';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute30';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute31';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute32';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute33';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute34';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute35';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute36';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute37';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute38';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute39';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute40';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute41';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute42';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute43';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute44';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute45';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute46';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute47';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute48';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute49';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute50';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute51';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute52';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute53';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute54';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute55';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute56';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute57';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute58';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute59';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute60';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute61';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute62';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute63';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute64';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute65';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute66';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute67';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute68';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute69';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute70';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute71';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute72';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute73';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute74';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute75';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute76';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute77';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute78';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute79';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute80';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute81';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute82';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute83';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute84';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute85';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute86';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute87';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute88';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute89';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute90';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute91';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute92';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute93';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute94';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute95';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute96';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute97';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute98';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_attribute99';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'formula';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_formula';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'numeric_constant';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_formula_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_formula_line_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_list_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_modifier_list';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'step_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reqd_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'from_rltd_modifier_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_rltd_modifier_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rltd_modifier_grp_no';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rltd_modifier_grp_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'amount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'basis';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_exceed_action';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_level';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_hold';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'multival_attr1_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'multival_attr1_context';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'multival_attribute1';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'multival_attr1_datatype';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'multival_attr2_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'multival_attr2_context';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'multival_attribute2';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'multival_attr2_datatype';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_attribute_context';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_attribute_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_attr_datatype';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_attr_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limit_balance';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'available_amount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'consumed_amount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reserved_amount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'multival_attr1_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'multival_attr2_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'organization_attr_context';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'organization_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'organization_attr_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'base_currency';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'row';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'conversion_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'conversion_date_type';
    -- I := I + 1;
    -- FND_API.g_attr_tbl(I).name     := 'conversion_method';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'conversion_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'currency_detail';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'fixed_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'markup_formula';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'markup_operator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'markup_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_currency';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'enabled';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'prc_context_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'prc_context';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'prc_context_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded_description';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded_prc_context_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'user_description';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'user_prc_context_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'availability_in_basic';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded_format_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded_precedence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded_segment_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded_description';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded_valueset';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'segment_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'segment';
    -- Added Column application_id : Abhijit
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'application_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'segment_mapping_column';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'user_format_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'user_precedence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'user_segment_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'user_description';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'user_valueset';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lookup';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lookup_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'meaning';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line_level_global_struct';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line_level_view_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_level_global_struct';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_level_view_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pte';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'request_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'request_type_desc';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'application_short_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pte_source_system';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'limits_enabled';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lov_enabled';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded_sourcing_method';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'segment_level';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'segment_pte';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sourcing_enabled';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sourcing_status';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'user_sourcing_method';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'attribute_sourcing';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'attribute_sourcing_level';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded_sourcing_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'seeded_value_string';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'user_sourcing_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'user_value_string';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_source_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'orig_system_header_ref';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'net_amount_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'required_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'accum_attribute';
        I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shareable_flag';
        I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sold_to_org_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'break_uom_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'break_uom_context';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'break_uom_attribute';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'locked_from_list_header_id';
    --added for MOAC
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'org_id';
    -- Product Catalog
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'functional_area';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pte_sourcesystem_fnarea';
    --  Added for TCA
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'party_hierarchy_enabled_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'qualify_hier_descendents_flag';

--  END GEN attributes

END Get_Attr_Tbl;

--  Prototypes for validate functions.

--  START GEN validate

--  Generator will append new prototypes before end generate comment.


FUNCTION Desc_Flex ( p_flex_name IN VARCHAR2 )
RETURN BOOLEAN
IS
BEGIN

    --  Call FND validate API.


    --  This call is temporarily commented out

/*
    IF	FND_FLEX_DESCVAL.Validate_Desccols
        (   appl_short_name               => 'QP'
        ,   desc_flex_name                => p_flex_name
        )
    THEN
        RETURN TRUE;
    ELSE

        --  Prepare the encoded message by setting it on the message
        --  dictionary stack. Then, add it to the API message list.

        FND_MESSAGE.Set_Encoded(FND_FLEX_DESCVAL.Encoded_Error_Message);

        oe_msg_pub.Add;

        --  Derive return status.

        IF FND_FLEX_DESCVAL.value_error OR
            FND_FLEX_DESCVAL.unsupported_error
        THEN

            --  In case of an expected error return FALSE

            RETURN FALSE;

        ELSE

            --  In case of an unexpected error raise an exception.

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

    END IF;
*/

    RETURN TRUE;

END Desc_Flex;

FUNCTION Automatic ( p_automatic_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_automatic_flag IS NULL OR
        p_automatic_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_automatic_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','automatic');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Automatic'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Automatic;

FUNCTION Comments ( p_comments IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_comments IS NULL OR
        p_comments = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_comments;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','comments');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Comments'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Comments;

FUNCTION Created_By ( p_created_by IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_created_by IS NULL OR
        p_created_by = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_created_by;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','created_by');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Created_By'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Created_By;

FUNCTION Creation_Date ( p_creation_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_creation_date IS NULL OR
        p_creation_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_creation_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','creation_date');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Creation_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Creation_Date;

FUNCTION Currency ( p_currency_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(30);
BEGIN

    IF p_currency_code IS NULL OR
        p_currency_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

     select currency_code
     into l_dummy
     from fnd_currencies_vl
     where enabled_flag = 'Y'
     and currency_flag='Y'
     and currency_code = p_currency_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency;

FUNCTION Discount_Lines ( p_discount_lines_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_discount_lines_flag IS NULL OR
        p_discount_lines_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_discount_lines_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_lines');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount_Lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount_Lines;

FUNCTION End_Date_Active ( p_end_date_active IN DATE,
                           p_start_date_active IN DATE := NULL)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF (p_end_date_active IS NULL OR
        p_end_date_active = FND_API.G_MISS_DATE)
      OR (p_start_date_active IS NULL OR
          p_start_date_active = FND_API.G_MISS_DATE)
    THEN
        RETURN TRUE;
    ELSIF (p_start_date_active > p_end_date_active ) THEN
          FND_MESSAGE.SET_NAME('QP', 'QP_STRT_DATE_BFR_END_DATE');
          OE_MSG_PUB.Add;
          RETURN FALSE;
    END IF;

    RETURN TRUE;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_date_active');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'End_Date_Active'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END End_Date_Active;

FUNCTION Freight_Terms ( p_freight_terms_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(30);
BEGIN

    IF p_freight_terms_code IS NULL OR
        p_freight_terms_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT FREIGHT_TERMS_CODE
    INTO l_dummy
    FROM OE_FRGHT_TERMS_ACTIVE_V
    WHERE FREIGHT_TERMS_CODE = p_freight_terms_code
    AND ROWNUM < 2;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Freight_Terms'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Freight_Terms;

FUNCTION Gsa_Indicator ( p_gsa_indicator IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_gsa_indicator IS NULL OR
        p_gsa_indicator = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_gsa_indicator;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','gsa_indicator');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Gsa_Indicator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Gsa_Indicator;

FUNCTION Last_Updated_By ( p_last_updated_by IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_last_updated_by IS NULL OR
        p_last_updated_by = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_updated_by;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','last_updated_by');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Updated_By'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Updated_By;

FUNCTION Last_Update_Date ( p_last_update_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_last_update_date IS NULL OR
        p_last_update_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_update_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','last_update_date');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Update_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Update_Date;

FUNCTION Last_Update_Login ( p_last_update_login IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_last_update_login IS NULL OR
        p_last_update_login = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_update_login;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','last_update_login');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Update_Login'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Update_Login;

FUNCTION List_Header ( p_list_header_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_list_header_id              NUMBER;
BEGIN

    IF p_list_header_id IS NULL OR
        p_list_header_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

--    SELECT  list_header_id
--    INTO     l_list_header_id
--    FROM     QP_LIST_HEADERS_B
--    WHERE    list_header_id = p_list_header_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Header;


FUNCTION List_Type ( p_list_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(30);
BEGIN

    IF p_list_type_code IS NULL OR
        p_list_type_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT LOOKUP_CODE
    INTO l_dummy
    FROM QP_LOOKUPS
    WHERE LOOKUP_TYPE = 'LIST_TYPE_CODE'
    AND LOOKUP_CODE = p_list_type_code
    AND ROWNUM < 2;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_type');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Type;

FUNCTION Program_Application ( p_program_application_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_program_application_id IS NULL OR
        p_program_application_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_program_application_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','program_application');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Program_Application'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Program_Application;

FUNCTION Program ( p_program_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_program_id IS NULL OR
        p_program_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_program_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','program');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Program'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Program;

FUNCTION Program_Update_Date ( p_program_update_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_program_update_date IS NULL OR
        p_program_update_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_program_update_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','program_update_date');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Program_Update_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Program_Update_Date;

FUNCTION Prorate ( p_prorate_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_prorate_flag IS NULL OR
        p_prorate_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_prorate_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prorate');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Prorate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Prorate;

FUNCTION Request ( p_request_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_request_id IS NULL OR
        p_request_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_request_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','request');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Request'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Request;

FUNCTION Rounding_Factor ( p_rounding_factor IN NUMBER,
                           p_currency_code IN VARCHAR2 := NULL )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_unit_precision_type varchar2(255) := '';
l_precision number := NULL;
l_extended_precision number := NULL;
l_price_rounding   VARCHAR2(50):='';
BEGIN
-- Modified by SunilPandey to avoid this check if the Multi-Currency profile option
-- is set to Y
-- mkarya - rounding factor precision validation must be done irrespective of multi-currency
-- installed or not
-- If NVL(UPPER(fnd_profile.value('QP_MULTI_CURRENCY_INSTALLED')), 'N') <> 'Y'
-- THEN
     l_unit_precision_type :=
              FND_PROFILE.VALUE('QP_UNIT_PRICE_PRECISION_TYPE');

     l_price_rounding := fnd_profile.value('QP_PRICE_ROUNDING');

  IF p_currency_code is not null THEN

    SELECT -1*PRECISION,
           -1*EXTENDED_PRECISION
    INTO   l_precision,
           l_extended_precision
    FROM   FND_CURRENCIES
   WHERE   CURRENCY_CODE = P_CURRENCY_CODE;

  END IF;


    IF p_rounding_factor IS NULL OR
        p_rounding_factor = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    ElSE

        IF l_unit_precision_type = 'STANDARD' THEN

           /* Added for Enhancement 1732601 */

          IF l_price_rounding = 'PRECISION' THEN
	        IF p_rounding_factor <> l_precision THEN
                     FND_MESSAGE.SET_NAME('QP', 'QP_ROUNDING_FACTOR_NO_UPDATE');
                     oe_msg_pub.add;
                     RETURN FALSE;
                END IF;
          END IF;

          IF (p_rounding_factor) < nvl((l_precision), (p_rounding_factor)) THEN

           FND_MESSAGE.SET_NAME('QP', 'OE_PRL_INVALID_ROUNDING_FACTOR');
           FND_MESSAGE.SET_TOKEN('PRECISION', l_precision);
           oe_msg_pub.add;
           RETURN FALSE;
          END IF;
       ELSE

           /* Added for Enhancement 1732601 */

          IF l_price_rounding = 'PRECISION' THEN
                IF p_rounding_factor <> l_extended_precision THEN
                     FND_MESSAGE.SET_NAME('QP', 'QP_ROUNDING_FACTOR_NO_UPDATE');
                     oe_msg_pub.add;
                     RETURN FALSE;
                END IF;
          END IF;

          IF (p_rounding_factor) < nvl((l_extended_precision),(p_rounding_factor)) THEN

           FND_MESSAGE.SET_NAME('QP', 'OE_PRL_INVALID_ROUNDING_FACTOR');
           FND_MESSAGE.SET_TOKEN('PRECISION', l_extended_precision);
           oe_msg_pub.add;
           RETURN FALSE;
          END IF;

       END IF;

   END IF;
-- End if; -- Profile option if


    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_rounding_factor;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rounding_factor');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rounding_Factor'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        RETURN FALSE;

END Rounding_Factor;

FUNCTION Ship_Method ( p_ship_method_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(30);
BEGIN

    IF p_ship_method_code IS NULL OR
        p_ship_method_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT LOOKUP_CODE
    INTO l_dummy
    FROM OE_SHIP_METHODS_V
    WHERE LOOKUP_TYPE = 'SHIP_METHOD'
    AND LOOKUP_CODE = p_ship_method_code
    AND ROWNUM < 2;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_method');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_Method;

FUNCTION Start_Date_Active ( p_start_date_active IN DATE,
                             p_end_date_active in DATE := NULL )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF (p_end_date_active IS NULL OR
        p_end_date_active = FND_API.G_MISS_DATE)
      OR (p_start_date_active IS NULL OR
          p_start_date_active = FND_API.G_MISS_DATE)
    THEN
        RETURN TRUE;
    ELSIF (p_start_date_active > p_end_date_active ) THEN
          FND_MESSAGE.SET_NAME('QP', 'QP_STRT_DATE_BFR_END_DATE');
          OE_MSG_PUB.Add;
          RETURN FALSE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','start_date_active');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Start_Date_Active'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Start_Date_Active;

FUNCTION Terms ( p_terms_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_term_id number;
BEGIN

    IF p_terms_id IS NULL OR
        p_terms_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT TERM_ID
    INTO l_term_id
    FROM RA_TERMS
    WHERE TERM_ID = p_terms_id
    AND ROWNUM < 2;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','terms');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Terms'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Terms;

FUNCTION Source_System ( p_source_system_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_source_system_code IS NULL OR
        p_source_system_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_source_system_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','source_system');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Source_System'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Source_System;

FUNCTION Pte_Code ( p_pte_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pte_code IS NULL OR
        p_pte_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pte_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pte_Code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pte_Code;

FUNCTION Active ( p_active_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_active_flag IS NULL OR
        p_active_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_active;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','active');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Active'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Active;

FUNCTION Parent_List_Header ( p_parent_list_header_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_parent_list_header_id IS NULL OR
        p_parent_list_header_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_parent_list_header_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','parent_list_header');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Parent_List_Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Parent_List_Header;

FUNCTION Start_Date_Active_First ( p_start_date_active_first IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_start_date_active_first IS NULL OR
        p_start_date_active_first = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_start_date_active_first;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','start_date_active_first');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Start_Date_Active_First'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Start_Date_Active_First;

FUNCTION End_Date_Active_First ( p_end_date_active_first IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_end_date_active_first IS NULL OR
        p_end_date_active_first = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_end_date_active_first;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_date_active_first');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'End_Date_Active_First'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END End_Date_Active_First;

FUNCTION Active_Date_First_Type ( p_active_date_first_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_active_date_first_type IS NULL OR
        p_active_date_first_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_active_date_first_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','active_date_first_type');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Active_Date_First_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Active_Date_First_Type;

FUNCTION Start_Date_Active_Second ( p_start_date_active_second IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_start_date_active_second IS NULL OR
        p_start_date_active_second = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_start_date_active_second;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','start_date_active_second');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Start_Date_Active_Second'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Start_Date_Active_Second;

FUNCTION Global_Flag ( p_global_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_global_flag IS NULL OR
        p_global_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_global_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','global_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Global_Flag'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Global_Flag;

FUNCTION End_Date_Active_Second ( p_end_date_active_second IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_end_date_active_second IS NULL OR
        p_end_date_active_second = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_end_date_active_second;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_date_active_second');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'End_Date_Active_Second'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END End_Date_Active_Second;

FUNCTION Active_Date_Second_Type ( p_active_date_second_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_active_date_second_type IS NULL OR
        p_active_date_second_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_active_date_second_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','active_date_second_type');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Active_Date_Second_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Active_Date_Second_Type;

FUNCTION Ask_For ( p_ask_for_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_ask_for_flag IS NULL OR
        p_ask_for_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ask_for_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ask_for_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ask_For'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ask_For;

FUNCTION Arithmetic_Operator ( p_arithmetic_operator IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_arithmetic_operator IS NULL OR
        p_arithmetic_operator = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_arithmetic_operator;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','arithmetic_operator');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Arithmetic_Operator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Arithmetic_Operator;

/* FUNCTION Base_Qty ( p_base_qty IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_base_qty IS NULL OR
        p_base_qty = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_base_qty;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_qty');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Base_Qty'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Base_Qty;
*/
FUNCTION Pricing_Phase ( p_pricing_phase_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_phase_id IS NULL OR
        p_pricing_phase_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_phase_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_phase');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Phase'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Phase;

/* FUNCTION Base_Uom ( p_base_uom_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_base_uom_code IS NULL OR
        p_base_uom_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_base_uom_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_uom');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Base_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Base_Uom;
*/
FUNCTION Effective_Period_Uom ( p_effective_period_uom IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_effective_period_uom IS NULL OR
        p_effective_period_uom = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_effective_period_uom;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','effective_period_uom');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Effective_Period_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Effective_Period_Uom;

FUNCTION Estim_Accrual_Rate ( p_estim_accrual_rate IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_estim_accrual_rate IS NULL OR
        p_estim_accrual_rate = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_estim_accrual_rate;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','estim_accrual_rate');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Estim_Accrual_Rate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Estim_Accrual_Rate;

FUNCTION Generate_Using_Formula ( p_generate_using_formula_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_generate_using_formula_id IS NULL OR
        p_generate_using_formula_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_generate_using_formula_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','generate_using_formula');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Generate_Using_Formula'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Generate_Using_Formula;

FUNCTION Gl_Class ( p_gl_class_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_gl_class_id IS NULL OR
        p_gl_class_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_gl_class_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','gl_class');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Gl_Class'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Gl_Class;

FUNCTION Inventory_Item ( p_inventory_item_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_inventory_item_id IS NULL OR
        p_inventory_item_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_inventory_item_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Inventory_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Item;

FUNCTION List_Line ( p_list_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_list_line_id                NUMBER;
BEGIN

    IF p_list_line_id IS NULL OR
        p_list_line_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

--    SELECT  list_line_id
--    INTO     l_list_line_id
--    FROM     QP_LIST_LINES
--    WHERE    list_line_id = p_list_line_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Line;


FUNCTION List_Line_Type ( p_list_line_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_list_line_type_code IS NULL OR
        p_list_line_type_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_list_line_type_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line_type');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Line_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Line_Type;

FUNCTION List_Price ( p_list_price IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_list_price IS NULL OR
        p_list_price = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_list_price;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_price');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Price'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Price;

FUNCTION From_Rltd_Modifier ( p_from_rltd_modifier_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_from_rltd_modifier_id IS NULL OR
        p_from_rltd_modifier_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_list_price;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','from_rltd_modifier_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'From_Rltd_Modifier_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END From_Rltd_Modifier;

FUNCTION To_Rltd_Modifier ( p_to_rltd_modifier_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_to_rltd_modifier_id IS NULL OR
        p_to_rltd_modifier_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_to_rltd_modifier_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_rltd_modifier_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Rltd_Modifier_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Rltd_Modifier;

FUNCTION Rltd_Modifier_Grp_No ( p_rltd_modifier_grp_no IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_rltd_modifier_grp_no IS NULL OR
        p_rltd_modifier_grp_no = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_list_price;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rltd_modifier_grp_no');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rltd_Modifier_Grp_No'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rltd_Modifier_Grp_No;

FUNCTION Rltd_Modifier_Grp_Type ( p_rltd_modifier_grp_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_rltd_modifier_grp_type IS NULL OR
        p_rltd_modifier_grp_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_list_price;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rltd_modifier_grp_type');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rltd_Modifier_Grp_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rltd_Modifier_Grp_Type;

FUNCTION List_Price_Uom ( p_list_price_uom_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_list_price_uom_code IS NULL OR
        p_list_price_uom_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_list_price_uom_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_price_uom');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Price_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Price_Uom;

FUNCTION Modifier_Level ( p_modifier_level_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_modifier_level_code IS NULL OR
        p_modifier_level_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_modifier_level_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','modifier_level');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Modifier_Level'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Modifier_Level;

FUNCTION New_Price ( p_new_price IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_new_price IS NULL OR
        p_new_price = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_new_price;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','new_price');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'New_Price'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END New_Price;

FUNCTION Number_Effective_Periods ( p_number_effective_periods IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_number_effective_periods IS NULL OR
        p_number_effective_periods = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_number_effective_periods;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','number_effective_periods');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Number_Effective_Periods'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Number_Effective_Periods;

FUNCTION Operand ( p_operand IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_operand IS NULL OR
        p_operand = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_operand;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operand');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Operand'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Operand;

FUNCTION Organization ( p_organization_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_organization_id IS NULL OR
        p_organization_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization;



FUNCTION Organization ( p_organization_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_organization_flag IS NULL OR
        p_organization_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    IF UPPER(p_organization_flag) = 'Y' OR
       UPPER(p_organization_flag) = 'N'
    THEN
       RETURN TRUE;
    ELSE
       FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization_flag');
       OE_MSG_PUB.Add;
       RETURN FALSE;
    END IF;

    RETURN TRUE;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization;



FUNCTION Override ( p_override_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_override_flag IS NULL OR
        p_override_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_override_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Override'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Override;

FUNCTION Percent_Price ( p_percent_price IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_percent_price IS NULL OR
        p_percent_price = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_percent_price;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','percent_price');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Percent_Price'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Percent_Price;

FUNCTION Price_Break_Type ( p_price_break_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_price_break_type_code IS NULL OR
        p_price_break_type_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_break_type_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_break_type');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Break_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Break_Type;

FUNCTION Price_By_Formula ( p_price_by_formula_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_price_by_formula_id IS NULL OR
        p_price_by_formula_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_by_formula_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_by_formula');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_By_Formula'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_By_Formula;

FUNCTION Primary_Uom ( p_primary_uom_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_primary_uom_flag IS NULL OR
        p_primary_uom_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_primary_uom_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_uom');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Primary_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Primary_Uom;

FUNCTION Print_On_Invoice ( p_print_on_invoice_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_print_on_invoice_flag IS NULL OR
        p_print_on_invoice_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_print_on_invoice_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','print_on_invoice');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Print_On_Invoice'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Print_On_Invoice;

FUNCTION Rebate_Subtype ( p_rebate_subtype_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_rebate_subtype_code IS NULL OR
        p_rebate_subtype_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_rebate_subtype_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rebate_subtype');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rebate_Subtype'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rebate_Subtype;

FUNCTION Rebate_Transaction_Type ( p_rebate_trxn_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_rebate_trxn_type_code IS NULL OR
        p_rebate_trxn_type_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_rebate_trxn_type_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rebate_transaction_type');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rebate_Transaction_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rebate_Transaction_Type;

FUNCTION Related_Item ( p_related_item_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_related_item_id IS NULL OR
        p_related_item_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_related_item_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','related_item');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Related_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Related_Item;

FUNCTION Relationship_Type ( p_relationship_type_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_relationship_type_id IS NULL OR
        p_relationship_type_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_relationship_type_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','relationship_type');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Relationship_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Relationship_Type;

FUNCTION Reprice ( p_reprice_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_reprice_flag IS NULL OR
        p_reprice_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_reprice_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reprice');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reprice'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reprice;

FUNCTION Revision ( p_revision IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_revision IS NULL OR
        p_revision = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_revision;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Revision'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Revision;

FUNCTION Revision_Date ( p_revision_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_revision_date IS NULL OR
        p_revision_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_revision_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision_date');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Revision_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Revision_Date;

FUNCTION Revision_Reason ( p_revision_reason_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_revision_reason_code IS NULL OR
        p_revision_reason_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_revision_reason_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision_reason');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Revision_Reason'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Revision_Reason;

FUNCTION Substitution_Attribute ( p_substitution_attribute IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_substitution_attribute IS NULL OR
        p_substitution_attribute = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_substitution_attribute;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','substitution_attribute');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Substitution_Attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Substitution_Attribute;

FUNCTION Substitution_Context ( p_substitution_context IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_substitution_context IS NULL OR
        p_substitution_context = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_substitution_context;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','substitution_context');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Substitution_Context'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Substitution_Context;

FUNCTION Substitution_Value ( p_substitution_value IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_substitution_value IS NULL OR
        p_substitution_value = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_substitution_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','substitution_value');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Substitution_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Substitution_Value;

FUNCTION Accrual_Flag ( p_accrual_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_accrual_flag IS NULL OR
        p_accrual_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_accrual_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accrual_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Accrual_Flag'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Accrual_Flag;

FUNCTION Pricing_Group_Sequence ( p_pricing_group_sequence IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_group_sequence IS NULL OR
        p_pricing_group_sequence = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_group_sequence;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_group_sequence');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Group_Sequence'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Group_Sequence;


FUNCTION Incompatibility_Grp_Code ( p_incompatibility_grp_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_incompatibility_grp_code IS NULL OR
        p_incompatibility_grp_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_incompatibility_grp_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','incompatibility_grp_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Incompatibility_Grp_Code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Incompatibility_Grp_Code;


FUNCTION List_Line_No ( p_list_line_no IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_list_line_no IS NULL OR
        p_list_line_no = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_list_line_no;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line_no');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Line_No'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Line_No;

FUNCTION Active_Flag ( p_active_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_active_flag IS NULL OR
        p_active_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_active_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','active_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Active_Flag'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Active_Flag;

--mkarya for bug 1944882
FUNCTION Mobile_Download ( p_mobile_download IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_mobile_download IS NULL OR
        p_mobile_download = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','mobile_download');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Mobile_Download'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Mobile_Download;

-- Multi-Currency SunilPandey
FUNCTION currency_header ( p_currency_header_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_currency_header_id IS NULL OR
        p_currency_header_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_currency_header_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_header');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'currency_header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END currency_header;

FUNCTION Product_Precedence ( p_product_precedence IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_product_precedence IS NULL OR
        p_product_precedence = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_product_precedence;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_precedence');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Product_Precedence'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Product_Precedence;

FUNCTION Exp_Period_Start_Date ( p_expiration_period_start_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_expiration_period_start_date IS NULL OR
        p_expiration_period_start_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_expiration_period_start_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','expiration_period_start_date');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Exp_Period_Start_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Exp_Period_Start_Date;

FUNCTION Number_Expiration_Periods ( p_number_expiration_periods IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_number_expiration_periods IS NULL OR
        p_number_expiration_periods = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_number_expiration_periods;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','number_expiration_periods');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Number_Expiration_Periods'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Number_Expiration_Periods;

FUNCTION Expiration_Period_Uom ( p_expiration_period_uom IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_expiration_period_uom IS NULL OR
        p_expiration_period_uom = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_expiration_period_uom;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','expiration_period_uom');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Expiration_Period_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Expiration_Period_Uom;

FUNCTION Expiration_Date ( p_expiration_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_expiration_date IS NULL OR
        p_expiration_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_expiration_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','expiration_date');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Expiration_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Expiration_Date;

FUNCTION Estim_Gl_Value ( p_estim_gl_value IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_estim_gl_value IS NULL OR
        p_estim_gl_value = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_estim_gl_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','estim_gl_value');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Estim_Gl_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Estim_Gl_Value;

FUNCTION Ben_Price_List_Line ( p_benefit_price_list_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_benefit_price_list_line_id IS NULL OR
        p_benefit_price_list_line_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_benefit_price_list_line_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','benefit_price_list_line_id');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ben_Price_List_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ben_Price_List_Line;

/* FUNCTION Recurring ( p_recurring_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_recurring_flag IS NULL OR
        p_recurring_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_recurring_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','recurring_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Recurring'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Recurring;
*/
FUNCTION Benefit_Limit ( p_benefit_limit IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_benefit_limit IS NULL OR
        p_benefit_limit = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_benefit_limit;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','benefit_limit');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Benefit_Limit'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Benefit_Limit;

FUNCTION Charge_Type ( p_charge_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_charge_type_code IS NULL OR
        p_charge_type_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_charge_type_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','charge_type_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Charge_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Charge_Type;

FUNCTION Charge_Subtype ( p_charge_subtype_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_charge_subtype_code IS NULL OR
        p_charge_subtype_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_charge_subtype_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','charge_subtype_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Charge_Subtype'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Charge_Subtype;

FUNCTION Benefit_Qty ( p_benefit_qty IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_benefit_qty IS NULL OR
        p_benefit_qty = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_benefit_qty;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','benefit_qty');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Benefit_Qty'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Benefit_Qty;

FUNCTION Benefit_Uom ( p_benefit_uom_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_benefit_uom_code IS NULL OR
        p_benefit_uom_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_benefit_uom_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','benefit_uom_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Benefit_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Benefit_Uom;

FUNCTION Accrual_Conversion_Rate ( p_accrual_conversion_rate IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_accrual_conversion_rate IS NULL OR
        p_accrual_conversion_rate = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_accrual_conversion_rate;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accrual_conversion_rate');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Accrual_Conversion_Rate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Accrual_Conversion_Rate;

FUNCTION Proration_Type ( p_proration_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_proration_type_code IS NULL OR
        p_proration_type_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_proration_type_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','proration_type_code');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Proration_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Proration_Type;

FUNCTION Include_On_Returns_Flag ( p_include_on_returns_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_include_on_returns_flag IS NULL OR
        p_include_on_returns_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_include_on_returns_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','include_on_returns_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Include_On_Returns_Flag'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Include_On_Returns_Flag;


-- block pricing
FUNCTION Recurring_Value(p_recurring_value IN NUMBER) RETURN BOOLEAN
IS
BEGIN
  IF (p_recurring_value IS NULL OR p_recurring_value = FND_API.G_MISS_NUM)
  THEN
    RETURN TRUE;
  ELSIF (p_recurring_value < 1)
  THEN
    -- recurring value cannot be zero or negative
    RETURN FALSE;
  END IF;

  RETURN TRUE; -- fall-through?
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
    THEN
      FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','recurring_value');
      oe_msg_pub.Add;
    END IF;
    RETURN FALSE;
  WHEN OTHERS THEN
    IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
            oe_msg_pub.Add_Exc_Msg(G_PKG_NAME, 'Recurring_Value');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Recurring_Value;


FUNCTION Comparison_Operator ( p_comparison_operator_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(30);
BEGIN

    IF p_comparison_operator_code IS NULL OR
        p_comparison_operator_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  lookup_code
    INTO    l_dummy
    FROM    QP_LOOKUPS
    WHERE   lookup_type = 'COMPARISON_OPERATOR'
    AND     lookup_code = p_comparison_operator_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','comparison_operator');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Comparison_Operator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Comparison_Operator;

FUNCTION Created_From_Rule ( p_created_from_rule_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_created_from_rule_id IS NULL OR
        p_created_from_rule_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

        SELECT  'VALID'
        INTO     l_dummy
        FROM     QP_QUALIFIER_RULES
        WHERE    qualifier_rule_id  = p_created_from_rule_id;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qualifier_context;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','created_from_rule');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Created_From_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Created_From_Rule;

FUNCTION Excluder ( p_excluder_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_excluder_flag IS NULL OR
        p_excluder_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_excluder_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','excluder');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Excluder'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Excluder;

FUNCTION Qualifier_Attribute ( p_qualifier_attribute IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qualifier_attribute IS NULL OR
        p_qualifier_attribute = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qualifier_attribute;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attribute');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Attribute;

FUNCTION Qualifier_Attr_Value ( p_qualifier_attr_value IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qualifier_attr_value IS NULL OR
        p_qualifier_attr_value = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qualifier_attr_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attr_value');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Attr_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Attr_Value;


FUNCTION Qualifier_Attr_Value_To ( p_qualifier_attr_value_to IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qualifier_attr_value_to IS NULL OR
        p_qualifier_attr_value_to = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qualifier_attr_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_attr_value_to');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Attr_Value_To'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Attr_Value_To;





FUNCTION Qualifier_Context ( p_qualifier_context IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qualifier_context IS NULL OR
        p_qualifier_context = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qualifier_context;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_context');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Context'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Context;

FUNCTION Qualifier_Grouping_No ( p_qualifier_grouping_no IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qualifier_grouping_no IS NULL OR
        p_qualifier_grouping_no = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;
    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qualifier_context;

    RETURN TRUE;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_grouping_no');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Grouping_No'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Grouping_No;

FUNCTION Qualifier ( p_qualifier_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qualifier_id IS NULL OR
        p_qualifier_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qualifier_context;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier;

FUNCTION Qualifier_Rule ( p_qualifier_rule_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qualifier_rule_id IS NULL OR
        p_qualifier_rule_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qualifier_context;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_rule');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Rule;


FUNCTION Accumulate ( p_accumulate_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_accumulate_flag IS NULL OR
        p_accumulate_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_accumulate_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accumulate');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Accumulate'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Accumulate;

FUNCTION Attribute_Grouping_No ( p_attribute_grouping_no IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_attribute_grouping_no IS NULL OR
        p_attribute_grouping_no = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_attribute_grouping_no;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','attribute_grouping_no');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attribute_Grouping_No'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Attribute_Grouping_No;

FUNCTION Pricing_Attribute ( p_pricing_attribute IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute IS NULL OR
        p_pricing_attribute = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute;

FUNCTION Pricing_Attribute_Context ( p_pricing_attribute_context IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute_context IS NULL OR
        p_pricing_attribute_context = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute_context;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute_context');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute_Context'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute_Context;

FUNCTION Pricing_Attribute ( p_pricing_attribute_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute_id IS NULL OR
        p_pricing_attribute_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute;

FUNCTION Pricing_Attr_Value_From ( p_pricing_attr_value_from IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attr_value_from IS NULL OR
        p_pricing_attr_value_from = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attr_value_from;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attr_value_from');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attr_Value_From'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attr_Value_From;

FUNCTION Pricing_Attr_Value_To ( p_pricing_attr_value_to IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attr_value_to IS NULL OR
        p_pricing_attr_value_to = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attr_value_to;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attr_value_to');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attr_Value_To'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attr_Value_To;

FUNCTION Product_Attribute ( p_product_attribute IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_product_attribute IS NULL OR
        p_product_attribute = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_product_attribute;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_attribute');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Product_Attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Product_Attribute;

FUNCTION Product_Attribute_Context ( p_product_attribute_context IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_product_attribute_context IS NULL OR
        p_product_attribute_context = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_product_attribute_context;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_attribute_context');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Product_Attribute_Context'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Product_Attribute_Context;

FUNCTION Product_Attr_Value ( p_product_attr_value IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_product_attr_value IS NULL OR
        p_product_attr_value = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_product_attr_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_attr_value');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Product_Attr_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Product_Attr_Value;

--- Added this function for the bug 7044510
--POSCO fix huge performance issue because of query in category validation.
-- The category UOM validation looks of no much use functionally. So decided to take it out.
-- It validates the UOM in any of the item inside a category so that means other items with differnt uom
-- in the category is also validated as pass.
-- So, to keep it simple the user would choose a valid UOM from LOV. But appropirate UOM
-- has to be provided by the user based on items inside the category and his requirement
-- and user would be always be in better position to decide the UOM.
Function product_uom ( p_product_uom_code IN VARCHAR2,
                       p_category_id IN NUMBER,
                       p_list_header_id IN NUMBER )
RETURN BOOLEAN IS
BEGIN
IF p_product_uom_code IS NULL OR
        p_product_uom_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
END IF;

RETURN TRUE;

EXCEPTION

  When OTHERS THEN

	oe_debug_Pub.add('>>>>>>>>>>>>>>>>>>>>>>>>EXCEPTION HAPPEN in procedure product_uom() ');

     RETURN FALSE;

END product_uom;

/*--- Commented out this function for the bug 7044510
Function product_uom ( p_product_uom_code IN VARCHAR2,
                       p_category_id IN NUMBER,
                       p_list_header_id IN NUMBER )
RETURN BOOLEAN IS
l_temp number := 0;
l_valid_uom number:= 0;
l_pte_code varchar2(30);
l_ss_code varchar2(30);
l_org_id number:= QP_UTIL.Get_Item_Validation_Org ;

BEGIN
oe_debug_Pub.add('>>>>>>>>>>>>>>>>>>>>>>>>In procedure QP_VALIDATE.product_uom()');
oe_debug_Pub.add('>>>>>>>>>>>>>>>>>>>>>>>>p_product_uom_code: '||p_product_uom_code);
oe_debug_Pub.add('>>>>>>>>>>>>>>>>>>>>>>>>p_category_id: '||p_category_id);
oe_debug_Pub.add('>>>>>>>>>>>>>>>>>>>>>>>>p_list_header_id: '||p_list_header_id);

   if QP_UTIL. Get_QP_Status <> 'I' then --advanced pricing
	oe_debug_Pub.add('>>>>>>>>>>>>>>>>>>>>>>>>basic pricing ');
       l_temp := 0;
   else
	select pte_code, source_system_code into l_pte_code, l_ss_code from qp_list_headers_all_b
	where list_header_id = p_list_header_id;

	for cl in (select distinct /*+ ORDERED  c.CATEGORY_SET_ID from qp_pte_source_systems B,
           	QP_SOURCESYSTEM_FNAREA_MAP A, mtl_default_category_sets c
           	where B.PTE_CODE = l_pte_code and
           	B.APPLICATION_SHORT_NAME = l_ss_code and
           	A.PTE_SOURCE_SYSTEM_ID = B.PTE_SOURCE_SYSTEM_ID and
      	c.FUNCTIONAL_AREA_ID = a.FUNCTIONAL_AREA_ID and
           	A.ENABLED_FLAG = 'Y' and B.ENABLED_FLAG = 'Y')
	loop
		oe_debug_Pub.add('>>>>>>>>>>>>>>>>>>>>>>>>inside loop cl.category_set_id: '||cl.category_set_id);
  		select count(*) into l_temp
  		from MTL_CATEGORY_SET_VALID_CATS cats,
  		MTL_CATEGORY_SETS_B d
  		where cats.category_id = p_category_id
  		and cats.category_set_id = cl.category_set_id
  		and d.category_set_id = cl.category_set_id
  		and d.HIERARCHY_ENABLED = 'Y'
  		and rownum = 1;

  		if l_temp >0  then
			oe_debug_Pub.add('>>>>>>>>>>>>>>>>>>>>>>>>l_temp > 0 for '||cl.category_set_id);
    			exit;
		else
		   l_temp := 0;
  		end if;
	end loop;
   End if;--QP_UTIL. Get_QP_Status

  oe_debug_Pub.add('>>>>>>>>>>>>>>>>>>>>>>>>l_temp: '||l_temp);
oe_debug_Pub.add('>>>>>>>>>>>>>>>>>>>>>>>>l_org_id: '||l_org_id);

  select count(*) into l_valid_uom
  from mtl_item_uoms_view
  where organization_id = l_org_id
  and inventory_item_id in ( select inventory_item_id
                            from mtl_item_categories cat
                            where organization_id = l_org_id and
                            category_id = p_category_id

                            UNION --note this select below will not be executed if basic pricing
                             --or if any of  the category_set_ids is not hierarchy enabled
                            select inventory_item_id
                            from mtl_item_categories cat
                            where organization_id = l_org_id
                            and l_temp > 0
                            and category_id in ( select child_id
                            FROM   eni_denorm_hierarchies
                            WHERE  parent_id = p_category_id)
                            )
  and uom_code =  p_product_uom_code --uom_code being validated
  and rownum = 1;

 oe_debug_Pub.add('>>>>>>>>>>>>>>>>>>>>>>>>l_valid_uom: '||l_valid_uom);
  if l_valid_uom >0  then
    RETURN TRUE;
  else
    RETURN FALSE;
  end if;--l_valid_uom

EXCEPTION
  When OTHERS THEN
	oe_debug_Pub.add('>>>>>>>>>>>>>>>>>>>>>>>>EXCEPTION HAPPEN in procedure product_uom() ');
     RETURN FALSE;
END product_uom;
*/


FUNCTION Product_Uom ( p_product_uom_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_product_uom_code IS NULL OR
        p_product_uom_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_product_uom_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_uom');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Product_Uom'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Product_Uom;

FUNCTION Product_Attribute_Datatype ( p_product_attribute_datatype IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_product_attribute_datatype IS NULL OR
        p_product_attribute_datatype = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_product_attribute_datatype;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_attribute_datatype');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Product_Attribute_Datatype'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Product_Attribute_Datatype;


FUNCTION Pricing_Attribute_Datatype ( p_pricing_attribute_datatype IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute_datatype IS NULL OR
        p_pricing_attribute_datatype = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute_datatype;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute_datatype');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute_Datatype'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute_Datatype;

FUNCTION Comparison_Operator_Code ( p_comparison_operator_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_comparison_operator_code IS NULL OR
        p_comparison_operator_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_comparison_operator_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','comparison_operator');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Comparison_Operator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Comparison_Operator_Code;

FUNCTION Description ( p_description IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_description IS NULL OR
        p_description = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_description;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','description');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Description'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Description;

FUNCTION Name ( p_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_name IS NULL OR
        p_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','name');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Name;

FUNCTION Version ( p_version_no IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_version_no IS NULL OR
        p_version_no = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_version_no;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','version_no');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Version'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Version;


FUNCTION Qualifier_Datatype ( p_qualifier_datatype IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qualifier_datatype IS NULL OR
        p_qualifier_datatype = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qualifier_datatype;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_datatype');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Datatype'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Datatype;

FUNCTION Qualifier_Date_Format ( p_qualifier_date_format IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qualifier_date_format IS NULL OR
        p_qualifier_date_format = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qualifier_date_format;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_date_format');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Date_Format'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Date_Format;

FUNCTION Qualifier_Number_Format ( p_qualifier_number_format IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qualifier_number_format IS NULL OR
        p_qualifier_number_format = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qualifier_number_format;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_number_format');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Number_Format'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Number_Format;

FUNCTION Qualifier_Precedence ( p_qualifier_precedence IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qualifier_precedence IS NULL OR
        p_qualifier_precedence = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_qualifier_precedence;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualifier_precedence');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Precedence'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Precedence;


FUNCTION Flex_Title ( p_flex_title IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_flex_title IS NULL OR
        p_flex_title = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_flex_title;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','flex_title');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Flex_Title'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Flex_Title;

FUNCTION Header ( p_header_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_header_id IS NULL OR
        p_header_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_header_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Header;

FUNCTION Line ( p_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_line_id IS NULL OR
        p_line_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_line_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line;

FUNCTION Order_Price_Attrib ( p_order_price_attrib_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_order_price_attrib_id IS NULL OR
        p_order_price_attrib_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_order_price_attrib_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_price_attrib');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Price_Attrib'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Price_Attrib;

FUNCTION Pricing_Attribute100 ( p_pricing_attribute100 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute100 IS NULL OR
        p_pricing_attribute100 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute100;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute100');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute100'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute100;

FUNCTION Pricing_Attribute11 ( p_pricing_attribute11 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute11 IS NULL OR
        p_pricing_attribute11 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute11;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute11');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute11'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute11;

FUNCTION Pricing_Attribute12 ( p_pricing_attribute12 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute12 IS NULL OR
        p_pricing_attribute12 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute12;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute12');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute12'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute12;

FUNCTION Pricing_Attribute13 ( p_pricing_attribute13 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute13 IS NULL OR
        p_pricing_attribute13 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute13;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute13');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute13'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute13;

FUNCTION Pricing_Attribute14 ( p_pricing_attribute14 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute14 IS NULL OR
        p_pricing_attribute14 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute14;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute14');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute14'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute14;

FUNCTION Pricing_Attribute15 ( p_pricing_attribute15 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute15 IS NULL OR
        p_pricing_attribute15 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute15;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute15');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute15'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute15;

FUNCTION Pricing_Attribute16 ( p_pricing_attribute16 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute16 IS NULL OR
        p_pricing_attribute16 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute16;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute16');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute16'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute16;

FUNCTION Pricing_Attribute17 ( p_pricing_attribute17 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute17 IS NULL OR
        p_pricing_attribute17 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute17;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute17');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute17'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute17;

FUNCTION Pricing_Attribute18 ( p_pricing_attribute18 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute18 IS NULL OR
        p_pricing_attribute18 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute18;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute18');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute18'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute18;

FUNCTION Pricing_Attribute19 ( p_pricing_attribute19 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute19 IS NULL OR
        p_pricing_attribute19 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute19;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute19');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute19'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute19;

FUNCTION Pricing_Attribute20 ( p_pricing_attribute20 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute20 IS NULL OR
        p_pricing_attribute20 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute20;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute20');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute20'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute20;

FUNCTION Pricing_Attribute21 ( p_pricing_attribute21 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute21 IS NULL OR
        p_pricing_attribute21 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute21;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute21');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute21'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute21;

FUNCTION Pricing_Attribute22 ( p_pricing_attribute22 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute22 IS NULL OR
        p_pricing_attribute22 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute22;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute22');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute22'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute22;

FUNCTION Pricing_Attribute23 ( p_pricing_attribute23 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute23 IS NULL OR
        p_pricing_attribute23 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute23;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute23');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute23'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute23;

FUNCTION Pricing_Attribute24 ( p_pricing_attribute24 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute24 IS NULL OR
        p_pricing_attribute24 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute24;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute24');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute24'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute24;

FUNCTION Pricing_Attribute25 ( p_pricing_attribute25 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute25 IS NULL OR
        p_pricing_attribute25 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute25;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute25');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute25'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute25;

FUNCTION Pricing_Attribute26 ( p_pricing_attribute26 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute26 IS NULL OR
        p_pricing_attribute26 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute26;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute26');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute26'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute26;

FUNCTION Pricing_Attribute27 ( p_pricing_attribute27 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute27 IS NULL OR
        p_pricing_attribute27 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute27;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute27');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute27'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute27;

FUNCTION Pricing_Attribute28 ( p_pricing_attribute28 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute28 IS NULL OR
        p_pricing_attribute28 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute28;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute28');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute28'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute28;

FUNCTION Pricing_Attribute29 ( p_pricing_attribute29 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute29 IS NULL OR
        p_pricing_attribute29 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute29;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute29');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute29'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute29;

FUNCTION Pricing_Attribute30 ( p_pricing_attribute30 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute30 IS NULL OR
        p_pricing_attribute30 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute30;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute30');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute30'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute30;

FUNCTION Pricing_Attribute31 ( p_pricing_attribute31 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute31 IS NULL OR
        p_pricing_attribute31 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute31;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute31');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute31'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute31;

FUNCTION Pricing_Attribute32 ( p_pricing_attribute32 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute32 IS NULL OR
        p_pricing_attribute32 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute32;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute32');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute32'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute32;

FUNCTION Pricing_Attribute33 ( p_pricing_attribute33 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute33 IS NULL OR
        p_pricing_attribute33 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute33;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute33');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute33'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute33;

FUNCTION Pricing_Attribute34 ( p_pricing_attribute34 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute34 IS NULL OR
        p_pricing_attribute34 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute34;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute34');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute34'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute34;

FUNCTION Pricing_Attribute35 ( p_pricing_attribute35 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute35 IS NULL OR
        p_pricing_attribute35 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute35;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute35');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute35'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute35;

FUNCTION Pricing_Attribute36 ( p_pricing_attribute36 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute36 IS NULL OR
        p_pricing_attribute36 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute36;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute36');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute36'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute36;

FUNCTION Pricing_Attribute37 ( p_pricing_attribute37 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute37 IS NULL OR
        p_pricing_attribute37 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute37;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute37');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute37'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute37;

FUNCTION Pricing_Attribute38 ( p_pricing_attribute38 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute38 IS NULL OR
        p_pricing_attribute38 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute38;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute38');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute38'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute38;

FUNCTION Pricing_Attribute39 ( p_pricing_attribute39 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute39 IS NULL OR
        p_pricing_attribute39 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute39;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute39');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute39'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute39;

FUNCTION Pricing_Attribute40 ( p_pricing_attribute40 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute40 IS NULL OR
        p_pricing_attribute40 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute40;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute40');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute40'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute40;

FUNCTION Pricing_Attribute41 ( p_pricing_attribute41 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute41 IS NULL OR
        p_pricing_attribute41 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute41;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute41');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute41'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute41;

FUNCTION Pricing_Attribute42 ( p_pricing_attribute42 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute42 IS NULL OR
        p_pricing_attribute42 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute42;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute42');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute42'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute42;

FUNCTION Pricing_Attribute43 ( p_pricing_attribute43 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute43 IS NULL OR
        p_pricing_attribute43 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute43;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute43');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute43'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute43;

FUNCTION Pricing_Attribute44 ( p_pricing_attribute44 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute44 IS NULL OR
        p_pricing_attribute44 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute44;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute44');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute44'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute44;

FUNCTION Pricing_Attribute45 ( p_pricing_attribute45 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute45 IS NULL OR
        p_pricing_attribute45 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute45;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute45');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute45'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute45;

FUNCTION Pricing_Attribute46 ( p_pricing_attribute46 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute46 IS NULL OR
        p_pricing_attribute46 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute46;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute46');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute46'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute46;

FUNCTION Pricing_Attribute47 ( p_pricing_attribute47 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute47 IS NULL OR
        p_pricing_attribute47 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute47;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute47');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute47'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute47;

FUNCTION Pricing_Attribute48 ( p_pricing_attribute48 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute48 IS NULL OR
        p_pricing_attribute48 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute48;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute48');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute48'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute48;

FUNCTION Pricing_Attribute49 ( p_pricing_attribute49 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute49 IS NULL OR
        p_pricing_attribute49 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute49;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute49');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute49'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute49;

FUNCTION Pricing_Attribute50 ( p_pricing_attribute50 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute50 IS NULL OR
        p_pricing_attribute50 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute50;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute50');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute50'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute50;

FUNCTION Pricing_Attribute51 ( p_pricing_attribute51 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute51 IS NULL OR
        p_pricing_attribute51 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute51;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute51');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute51'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute51;

FUNCTION Pricing_Attribute52 ( p_pricing_attribute52 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute52 IS NULL OR
        p_pricing_attribute52 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute52;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute52');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute52'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute52;

FUNCTION Pricing_Attribute53 ( p_pricing_attribute53 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute53 IS NULL OR
        p_pricing_attribute53 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute53;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute53');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute53'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute53;

FUNCTION Pricing_Attribute54 ( p_pricing_attribute54 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute54 IS NULL OR
        p_pricing_attribute54 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute54;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute54');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute54'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute54;

FUNCTION Pricing_Attribute55 ( p_pricing_attribute55 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute55 IS NULL OR
        p_pricing_attribute55 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute55;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute55');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute55'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute55;

FUNCTION Pricing_Attribute56 ( p_pricing_attribute56 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute56 IS NULL OR
        p_pricing_attribute56 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute56;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute56');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute56'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute56;

FUNCTION Pricing_Attribute57 ( p_pricing_attribute57 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute57 IS NULL OR
        p_pricing_attribute57 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute57;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute57');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute57'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute57;

FUNCTION Pricing_Attribute58 ( p_pricing_attribute58 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute58 IS NULL OR
        p_pricing_attribute58 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute58;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute58');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute58'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute58;

FUNCTION Pricing_Attribute59 ( p_pricing_attribute59 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute59 IS NULL OR
        p_pricing_attribute59 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute59;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute59');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute59'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute59;

FUNCTION Pricing_Attribute60 ( p_pricing_attribute60 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute60 IS NULL OR
        p_pricing_attribute60 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute60;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute60');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute60'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute60;

FUNCTION Pricing_Attribute61 ( p_pricing_attribute61 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute61 IS NULL OR
        p_pricing_attribute61 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute61;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute61');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute61'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute61;

FUNCTION Pricing_Attribute62 ( p_pricing_attribute62 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute62 IS NULL OR
        p_pricing_attribute62 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute62;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute62');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute62'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute62;

FUNCTION Pricing_Attribute63 ( p_pricing_attribute63 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute63 IS NULL OR
        p_pricing_attribute63 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute63;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute63');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute63'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute63;

FUNCTION Pricing_Attribute64 ( p_pricing_attribute64 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute64 IS NULL OR
        p_pricing_attribute64 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute64;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute64');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute64'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute64;

FUNCTION Pricing_Attribute65 ( p_pricing_attribute65 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute65 IS NULL OR
        p_pricing_attribute65 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute65;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute65');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute65'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute65;

FUNCTION Pricing_Attribute66 ( p_pricing_attribute66 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute66 IS NULL OR
        p_pricing_attribute66 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute66;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute66');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute66'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute66;

FUNCTION Pricing_Attribute67 ( p_pricing_attribute67 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute67 IS NULL OR
        p_pricing_attribute67 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute67;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute67');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute67'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute67;

FUNCTION Pricing_Attribute68 ( p_pricing_attribute68 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute68 IS NULL OR
        p_pricing_attribute68 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute68;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute68');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute68'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute68;

FUNCTION Pricing_Attribute69 ( p_pricing_attribute69 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute69 IS NULL OR
        p_pricing_attribute69 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute69;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute69');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute69'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute69;

FUNCTION Pricing_Attribute70 ( p_pricing_attribute70 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute70 IS NULL OR
        p_pricing_attribute70 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute70;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute70');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute70'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute70;

FUNCTION Pricing_Attribute71 ( p_pricing_attribute71 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute71 IS NULL OR
        p_pricing_attribute71 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute71;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute71');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute71'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute71;

FUNCTION Pricing_Attribute72 ( p_pricing_attribute72 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute72 IS NULL OR
        p_pricing_attribute72 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute72;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute72');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute72'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute72;

FUNCTION Pricing_Attribute73 ( p_pricing_attribute73 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute73 IS NULL OR
        p_pricing_attribute73 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute73;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute73');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute73'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute73;

FUNCTION Pricing_Attribute74 ( p_pricing_attribute74 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute74 IS NULL OR
        p_pricing_attribute74 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute74;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute74');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute74'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute74;

FUNCTION Pricing_Attribute75 ( p_pricing_attribute75 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute75 IS NULL OR
        p_pricing_attribute75 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute75;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute75');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute75'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute75;

FUNCTION Pricing_Attribute76 ( p_pricing_attribute76 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute76 IS NULL OR
        p_pricing_attribute76 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute76;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute76');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute76'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute76;

FUNCTION Pricing_Attribute77 ( p_pricing_attribute77 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute77 IS NULL OR
        p_pricing_attribute77 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute77;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute77');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute77'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute77;

FUNCTION Pricing_Attribute78 ( p_pricing_attribute78 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute78 IS NULL OR
        p_pricing_attribute78 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute78;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute78');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute78'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute78;

FUNCTION Pricing_Attribute79 ( p_pricing_attribute79 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute79 IS NULL OR
        p_pricing_attribute79 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute79;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute79');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute79'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute79;

FUNCTION Pricing_Attribute80 ( p_pricing_attribute80 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute80 IS NULL OR
        p_pricing_attribute80 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute80;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute80');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute80'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute80;

FUNCTION Pricing_Attribute81 ( p_pricing_attribute81 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute81 IS NULL OR
        p_pricing_attribute81 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute81;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute81');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute81'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute81;

FUNCTION Pricing_Attribute82 ( p_pricing_attribute82 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute82 IS NULL OR
        p_pricing_attribute82 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute82;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute82');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute82'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute82;

FUNCTION Pricing_Attribute83 ( p_pricing_attribute83 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute83 IS NULL OR
        p_pricing_attribute83 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute83;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute83');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute83'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute83;

FUNCTION Pricing_Attribute84 ( p_pricing_attribute84 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute84 IS NULL OR
        p_pricing_attribute84 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute84;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute84');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute84'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute84;

FUNCTION Pricing_Attribute85 ( p_pricing_attribute85 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute85 IS NULL OR
        p_pricing_attribute85 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute85;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute85');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute85'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute85;

FUNCTION Pricing_Attribute86 ( p_pricing_attribute86 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute86 IS NULL OR
        p_pricing_attribute86 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute86;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute86');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute86'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute86;

FUNCTION Pricing_Attribute87 ( p_pricing_attribute87 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute87 IS NULL OR
        p_pricing_attribute87 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute87;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute87');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute87'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute87;

FUNCTION Pricing_Attribute88 ( p_pricing_attribute88 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute88 IS NULL OR
        p_pricing_attribute88 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute88;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute88');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute88'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute88;

FUNCTION Pricing_Attribute89 ( p_pricing_attribute89 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute89 IS NULL OR
        p_pricing_attribute89 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute89;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute89');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute89'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute89;

FUNCTION Pricing_Attribute90 ( p_pricing_attribute90 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute90 IS NULL OR
        p_pricing_attribute90 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute90;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute90');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute90'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute90;

FUNCTION Pricing_Attribute91 ( p_pricing_attribute91 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute91 IS NULL OR
        p_pricing_attribute91 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute91;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute91');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute91'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute91;

FUNCTION Pricing_Attribute92 ( p_pricing_attribute92 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute92 IS NULL OR
        p_pricing_attribute92 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute92;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute92');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute92'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute92;

FUNCTION Pricing_Attribute93 ( p_pricing_attribute93 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute93 IS NULL OR
        p_pricing_attribute93 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute93;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute93');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute93'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute93;

FUNCTION Pricing_Attribute94 ( p_pricing_attribute94 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute94 IS NULL OR
        p_pricing_attribute94 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute94;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute94');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute94'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute94;

FUNCTION Pricing_Attribute95 ( p_pricing_attribute95 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute95 IS NULL OR
        p_pricing_attribute95 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute95;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute95');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute95'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute95;

FUNCTION Pricing_Attribute96 ( p_pricing_attribute96 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute96 IS NULL OR
        p_pricing_attribute96 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute96;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute96');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute96'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute96;

FUNCTION Pricing_Attribute97 ( p_pricing_attribute97 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute97 IS NULL OR
        p_pricing_attribute97 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute97;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute97');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute97'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute97;

FUNCTION Pricing_Attribute98 ( p_pricing_attribute98 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute98 IS NULL OR
        p_pricing_attribute98 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute98;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute98');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute98'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute98;

FUNCTION Pricing_Attribute99 ( p_pricing_attribute99 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pricing_attribute99 IS NULL OR
        p_pricing_attribute99 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_attribute99;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute99');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attribute99'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attribute99;


FUNCTION Formula ( p_formula IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_formula IS NULL OR
        p_formula = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_formula;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','formula');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Formula'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Formula;

FUNCTION Price_Formula ( p_price_formula_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_price_formula_id IS NULL OR
        p_price_formula_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_formula_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Formula'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Formula;


FUNCTION Numeric_Constant ( p_numeric_constant IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_numeric_constant IS NULL OR
        p_numeric_constant = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_numeric_constant;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','numeric_constant');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Numeric_Constant'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Numeric_Constant;

--POSCO Change.
FUNCTION Reqd_Flag ( p_reqd_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
BEGIN
    IF p_reqd_flag IS NULL OR
        p_reqd_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    IF UPPER(p_reqd_flag) = 'Y' OR
       UPPER(p_reqd_flag) = 'N'
    THEN
       RETURN TRUE;
    ELSE
       FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reqd_flag');
       OE_MSG_PUB.Add;
       RETURN FALSE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reqd_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

END Reqd_Flag;

FUNCTION Price_Formula_Line ( p_price_formula_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_price_formula_line_id IS NULL OR
        p_price_formula_line_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_formula_line_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula_line');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Formula_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Formula_Line;

FUNCTION Price_Formula_Line_Type ( p_formula_line_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_formula_line_type_code IS NULL OR
        p_formula_line_type_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_formula_line_type_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula_line_type');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Formula_Line_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Formula_Line_Type;

FUNCTION Price_List_Line ( p_price_list_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_price_list_line_id IS NULL OR
        p_price_list_line_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_list_line_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list_line');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List_Line;

FUNCTION Price_Modifier_List ( p_price_modifier_list_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_price_modifier_list_id IS NULL OR
        p_price_modifier_list_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_modifier_list_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_modifier_list');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Modifier_List'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Modifier_List;

FUNCTION Step_Number ( p_step_number IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_step_number IS NULL OR
        p_step_number = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_step_number;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','step_number');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Step_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Step_Number;

FUNCTION Price_List_Name ( p_name IN VARCHAR2,
                           p_list_header_id in number,
                           p_version_no in varchar2 := NULL)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
v_count number;
BEGIN

    IF p_name IS NULL OR
        p_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT   COUNT(*) INTO V_COUNT
     FROM   QP_LIST_HEADERS_TL
     WHERE  ( p_list_header_id IS NULL
                    OR LIST_HEADER_ID <> p_list_header_id )
     AND    NAME = p_name
     AND    LANGUAGE = userenv('LANG')
     AND    nvl(VERSION_NO, '-1') = nvl(p_version_no, '-1');

    IF V_COUNT >0 THEN
      FND_MESSAGE.SET_NAME('QP','SO_OTHER_NAME_ALREADY_IN_USE');
      oe_msg_pub.ADD;
      RETURN FALSE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List_Name;


FUNCTION Amount ( p_amount IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_amount IS NULL OR
        p_amount = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_amount;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','amount');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Amount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Amount;

FUNCTION Basis ( p_basis IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(30);
BEGIN

    IF p_basis IS NULL OR
        p_basis = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  lookup_code
    INTO    l_dummy
    FROM    QP_LOOKUPS
    WHERE   lookup_type = 'QP_LIMIT_BASIS'
    AND     lookup_code = p_basis;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','basis');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Basis'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Basis;


FUNCTION Limit_Exceed_Action ( p_limit_exceed_action_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(30);
BEGIN

    IF p_limit_exceed_action_code IS NULL OR
        p_limit_exceed_action_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  lookup_code
    INTO    l_dummy
    FROM    QP_LOOKUPS
    WHERE   lookup_type = 'LIMIT_EXCEED_ACTION'
    AND     lookup_code = p_limit_exceed_action_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_exceed_action');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Exceed_Action'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Exceed_Action;

FUNCTION Limit_Hold ( p_limit_hold_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_limit_hold_flag IS NULL OR
        p_limit_hold_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    IF UPPER(p_limit_hold_flag) = 'Y' OR
       UPPER(p_limit_hold_flag) = 'N'
    THEN
       RETURN TRUE;
    ELSE
       FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_hold_flag');
       OE_MSG_PUB.Add;
       RETURN FALSE;
    END IF;

    RETURN TRUE;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_hold_flag');
            oe_msg_pub.Add;

        END IF;

        RETURN FALSE;
    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Hold;


FUNCTION Limit ( p_limit_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_limit_id                    NUMBER;
BEGIN

    IF p_limit_id IS NULL OR
        p_limit_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

--    SELECT   limit_id
--    INTO     l_limit_id
--    FROM     qp_limits
--    WHERE    limit_id = p_limit_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit;


FUNCTION Limit_Level ( p_limit_level_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(30);
BEGIN

    IF p_limit_level_code IS NULL OR
        p_limit_level_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  lookup_code
    INTO    l_dummy
    FROM    QP_LOOKUPS
    WHERE   lookup_type = 'LIMIT_LEVEL'
    AND     lookup_code = p_limit_level_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_level');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Level'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Level;


FUNCTION Limit_Number ( p_limit_number IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_limit_number IS NULL OR
        p_limit_number = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_limit_number;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_number');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Number;

FUNCTION Multival_Attr1_Type ( p_multival_attr1_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_multival_attr1_type IS NULL OR
        p_multival_attr1_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_multival_attr1_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','multival_attr1_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Multival_Attr1_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Multival_Attr1_Type;

FUNCTION Multival_Attr1_Context ( p_multival_attr1_context IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_multival_attr1_context IS NULL OR
        p_multival_attr1_context = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_multival_attr1_context;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','multival_attr1_context');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Multival_Attr1_Context'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Multival_Attr1_Context;

FUNCTION Multival_Attribute1 ( p_multival_attribute1 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_multival_attribute1 IS NULL OR
        p_multival_attribute1 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_multival_attribute1;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','multival_attribute1');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Multival_Attribute1'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Multival_Attribute1;

FUNCTION Multival_Attr1_Datatype ( p_multival_attr1_datatype IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_multival_attr1_datatype IS NULL OR
        p_multival_attr1_datatype = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_multival_attr1_datatype;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','multival_attr1_datatype');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Multival_Attr1_Datatype'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Multival_Attr1_Datatype;

FUNCTION Multival_Attr2_Type ( p_multival_attr2_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_multival_attr2_type IS NULL OR
        p_multival_attr2_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_multival_attr2_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','multival_attr2_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Multival_Attr2_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Multival_Attr2_Type;

FUNCTION Multival_Attr2_Context ( p_multival_attr2_context IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_multival_attr2_context IS NULL OR
        p_multival_attr2_context = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_multival_attr2_context;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','multival_attr2_context');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Multival_Attr2_Context'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Multival_Attr2_Context;

FUNCTION Multival_Attribute2 ( p_multival_attribute2 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_multival_attribute2 IS NULL OR
        p_multival_attribute2 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_multival_attribute2;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','multival_attribute2');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Multival_Attribute2'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Multival_Attribute2;

FUNCTION Multival_Attr2_Datatype ( p_multival_attr2_datatype IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_multival_attr2_datatype IS NULL OR
        p_multival_attr2_datatype = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_multival_attr2_datatype;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','multival_attr2_datatype');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Multival_Attr2_Datatype'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Multival_Attr2_Datatype;


FUNCTION Limit_Attribute ( p_limit_attribute IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_limit_attribute IS NULL OR
        p_limit_attribute = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_limit_attribute;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_attribute');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Attribute;

FUNCTION Limit_Attribute_Context ( p_limit_attribute_context IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_limit_attribute_context IS NULL OR
        p_limit_attribute_context = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_limit_attribute_context;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_attribute_context');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Attribute_Context'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Attribute_Context;

FUNCTION Limit_Attribute ( p_limit_attribute_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_limit_attribute_id IS NULL OR
        p_limit_attribute_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_limit_attribute_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_attribute');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Attribute;

FUNCTION Limit_Attribute_Type ( p_limit_attribute_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(30);
BEGIN

    IF p_limit_attribute_type IS NULL OR
        p_limit_attribute_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  lookup_code
    INTO    l_dummy
    FROM    QP_LOOKUPS
    WHERE   lookup_type = 'LIMIT_ATTRIBUTE_TYPE'
    AND     lookup_code = p_limit_attribute_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_attribute_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Attribute_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Attribute_Type;


FUNCTION Limit_Attr_Datatype ( p_limit_attr_datatype IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_limit_attr_datatype IS NULL OR
        p_limit_attr_datatype = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_limit_attr_datatype;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_attr_datatype');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Attr_Datatype'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Attr_Datatype;

FUNCTION Limit_Attr_Value ( p_limit_attr_value IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_limit_attr_value IS NULL OR
        p_limit_attr_value = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_limit_attr_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_attr_value');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Attr_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Attr_Value;

FUNCTION Limit_Balance ( p_limit_balance_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_limit_balance_id            NUMBER;
BEGIN

    IF p_limit_balance_id IS NULL OR
        p_limit_balance_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

--    SELECT   limit_balance_id
--    INTO     l_limit_balance_id
--    FROM     qp_limit_balances
--    WHERE    limit_balance_id = p_limit_balance_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit_balance');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limit_Balance'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Balance;


FUNCTION Available_Amount ( p_available_amount IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_available_amount IS NULL OR
        p_available_amount = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_available_amount;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','available_amount');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Available_Amount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Available_Amount;

FUNCTION Consumed_Amount ( p_consumed_amount IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_consumed_amount IS NULL OR
        p_consumed_amount = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_consumed_amount;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','consumed_amount');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Consumed_Amount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Consumed_Amount;

FUNCTION Reserved_Amount ( p_reserved_amount IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_reserved_amount IS NULL OR
        p_reserved_amount = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_reserved_amount;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reserved_amount');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reserved_Amount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reserved_Amount;

FUNCTION Multival_Attr1_Value ( p_multival_attr1_value IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_multival_attr1_value IS NULL OR
        p_multival_attr1_value = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_multival_attr1_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','multival_attr1_value');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Multival_Attr1_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Multival_Attr1_Value;

FUNCTION Multival_Attr2_Value ( p_multival_attr2_value IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_multival_attr2_value IS NULL OR
        p_multival_attr2_value = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_multival_attr2_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','multival_attr2_value');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Multival_Attr2_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Multival_Attr2_Value;

FUNCTION Organization_Attr_Context ( p_organization_attr_context IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_organization_attr_context IS NULL OR
        p_organization_attr_context = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_organization_attr_context;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization_attr_context');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization_Attr_Context'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization_Attr_Context;

FUNCTION Organization_Attribute ( p_organization_attribute IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_organization_attribute IS NULL OR
        p_organization_attribute = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_organization_attribute;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization_attribute');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization_Attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization_Attribute;

FUNCTION Organization_Attr_Value ( p_organization_attr_value IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_organization_attr_value IS NULL OR
        p_organization_attr_value = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_organization_attr_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization_attr_value');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization_Attr_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization_Attr_Value;



FUNCTION Base_Currency ( p_base_currency_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_base_currency_code IS NULL OR
        p_base_currency_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_base_currency_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_currency');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Base_Currency'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Base_Currency;

FUNCTION Row ( p_row_id IN ROWID )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_row_id IS NULL OR
        p_row_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_row_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','row');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Row;


FUNCTION Conversion_Date ( p_conversion_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_conversion_date IS NULL OR
        p_conversion_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_conversion_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','conversion_date');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Conversion_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Conversion_Date;

FUNCTION Conversion_Date_Type ( p_conversion_date_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_conversion_date_type IS NULL OR
        p_conversion_date_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_conversion_date_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','conversion_date_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Conversion_Date_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Conversion_Date_Type;

/*
FUNCTION Conversion_Method ( p_conversion_method IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_conversion_method IS NULL OR
        p_conversion_method = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_conversion_method;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','conversion_method');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Conversion_Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Conversion_Method;
*/

FUNCTION Conversion_Type ( p_conversion_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_conversion_type IS NULL OR
        p_conversion_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_conversion_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','conversion_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Conversion_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Conversion_Type;

FUNCTION Currency_Detail ( p_currency_detail_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_currency_detail_id IS NULL OR
        p_currency_detail_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_currency_detail_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_detail');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency_Detail'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency_Detail;

FUNCTION Fixed_Value ( p_fixed_value IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_fixed_value IS NULL OR
        p_fixed_value = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_fixed_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fixed_value');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Fixed_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fixed_Value;

FUNCTION Markup_Formula ( p_markup_formula_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_markup_formula_id IS NULL OR
        p_markup_formula_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_markup_formula_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','markup_formula');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Markup_Formula'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Markup_Formula;

FUNCTION Markup_Operator ( p_markup_operator IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_markup_operator IS NULL OR
        p_markup_operator = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_markup_operator;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','markup_operator');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Markup_Operator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Markup_Operator;

FUNCTION Markup_Value ( p_markup_value IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_markup_value IS NULL OR
        p_markup_value = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_markup_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','markup_value');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Markup_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Markup_Value;

FUNCTION To_Currency ( p_to_currency_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_to_currency_code IS NULL OR
        p_to_currency_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_to_currency_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_currency');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Currency'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Currency;

-- Added by Sunil Pandey
FUNCTION base_rounding_factor ( p_base_rounding_factor IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_base_rounding_factor IS NULL OR
        p_base_rounding_factor = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_base_rounding_factor;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_rounding_factor');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'base_rounding_factor'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END base_rounding_factor;

FUNCTION base_markup_formula ( p_base_markup_formula_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_base_markup_formula_id IS NULL OR
        p_base_markup_formula_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_base_markup_formula_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_markup_formula');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'base_markup_formula'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END base_markup_formula;

FUNCTION base_markup_operator ( p_base_markup_operator IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_base_markup_operator IS NULL OR
        p_base_markup_operator = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_base_markup_operator;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_markup_operator');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'base_markup_operator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END base_markup_operator;

FUNCTION Base_Markup_Value ( p_Base_markup_value IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Base_markup_value IS NULL OR
        p_Base_markup_value = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Base_markup_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Base_markup_value');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Base_Markup_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Base_Markup_Value;
-- Added by Sunil Pandey

-- For Abhijit
-- New attribute fields added in currency details table; Added by Sunil Pandey

FUNCTION curr_attribute_type ( p_curr_attribute_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_curr_attribute_type IS NULL OR
        p_curr_attribute_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_curr_attribute_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','curr_attribute_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'curr_attribute_type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END curr_attribute_type;

FUNCTION curr_attribute_context ( p_curr_attribute_context IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_curr_attribute_context IS NULL OR
        p_curr_attribute_context = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_curr_attribute_context;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','curr_attribute_context');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'curr_attribute_context'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END curr_attribute_context;

FUNCTION curr_attribute ( p_curr_attribute IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_curr_attribute IS NULL OR
        p_curr_attribute = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_curr_attribute;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','curr_attribute');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'curr_attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END curr_attribute;

FUNCTION curr_attribute_value ( p_curr_attribute_value IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_curr_attribute_value IS NULL OR
        p_curr_attribute_value = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_curr_attribute_value;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','curr_attribute_value');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'curr_attribute_value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END curr_attribute_value;

FUNCTION precedence ( p_precedence IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_precedence IS NULL OR
        p_precedence = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_precedence;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','precedence');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'precedence'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END precedence;
-- New attribute fields added in currency details table; Added by Sunil Pandey
-- For Abhijit



FUNCTION Enabled ( p_enabled_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_enabled_flag IS NULL OR
        p_enabled_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_enabled_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','enabled');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Enabled'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Enabled;

FUNCTION Prc_Context_Code ( p_prc_context_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_prc_context_code IS NULL OR
        p_prc_context_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_prc_context_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prc_context_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Prc_Context_Code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Prc_Context_Code;

FUNCTION Prc_Context ( p_prc_context_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_prc_context_id IS NULL OR
        p_prc_context_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_prc_context_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prc_context');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Prc_Context'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Prc_Context;

FUNCTION Prc_Context_Type ( p_prc_context_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_prc_context_type IS NULL OR
        p_prc_context_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_prc_context_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prc_context_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Prc_Context_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Prc_Context_Type;

FUNCTION Seeded_Description ( p_seeded_description IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_seeded_description IS NULL OR
        p_seeded_description = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_seeded_description;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_description');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Seeded_Description'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded_Description;

FUNCTION Seeded ( p_seeded_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_seeded_flag IS NULL OR
        p_seeded_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_seeded_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Seeded'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded;

FUNCTION Seeded_Prc_Context_Name ( p_seeded_prc_context_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_seeded_prc_context_name IS NULL OR
        p_seeded_prc_context_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_seeded_prc_context_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_prc_context_name');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Seeded_Prc_Context_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded_Prc_Context_Name;

FUNCTION User_Description ( p_user_description IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_user_description IS NULL OR
        p_user_description = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_user_description;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_description');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'User_Description'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Description;

FUNCTION User_Prc_Context_Name ( p_user_prc_context_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_user_prc_context_name IS NULL OR
        p_user_prc_context_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_user_prc_context_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_prc_context_name');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'User_Prc_Context_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Prc_Context_Name;


FUNCTION Availability_In_Basic ( p_availability_in_basic IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_availability_in_basic IS NULL OR
        p_availability_in_basic = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_availability_in_basic;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','availability_in_basic');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Availability_In_Basic'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Availability_In_Basic;

FUNCTION Seeded_Format_Type ( p_seeded_format_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_seeded_format_type IS NULL OR
        p_seeded_format_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_seeded_format_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_format_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Seeded_Format_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded_Format_Type;

FUNCTION Seeded_Precedence ( p_seeded_precedence IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_seeded_precedence IS NULL OR
        p_seeded_precedence = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_seeded_precedence;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_precedence');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Seeded_Precedence'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded_Precedence;

FUNCTION Seeded_Segment_Name ( p_seeded_segment_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_seeded_segment_name IS NULL OR
        p_seeded_segment_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_seeded_segment_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_segment_name');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Seeded_Segment_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded_Segment_Name;

Function Seeded_Description_Seg (p_seeded_description IN VARCHAR2)
 Return Boolean
 IS


l_dummy                       VARCHAR2(10);
BEGIN

    IF p_seeded_description IS NULL OR
        p_seeded_description = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_seeded_description;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(
                                                         OE_MSG_PUB.G_MSG_LVL_ERROR
                                                                     )
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_description');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(
                                        OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                                                                     )
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'seeded_description'
              );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded_Description_Seg;

 Function User_Description_Seg (p_user_description IN VARCHAR2)
 Return Boolean
 IS


l_dummy                       VARCHAR2(10);
BEGIN

    IF p_user_description IS NULL OR
        p_user_description = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_user_description;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(
                                                         OE_MSG_PUB.G_MSG_LVL_ERROR
                                                                     )
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_description');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(
                                        OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                                                                     )
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'user_description'
              );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Description_Seg;

FUNCTION Seeded_Valueset ( p_seeded_valueset_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_seeded_valueset_id IS NULL OR
        p_seeded_valueset_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_seeded_valueset_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_valueset');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Seeded_Valueset'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded_Valueset;

FUNCTION Segment_Code ( p_segment_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_segment_code IS NULL OR
        p_segment_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_segment_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Segment_Code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Segment_Code;

FUNCTION Segment ( p_segment_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_segment_id IS NULL OR
        p_segment_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_segment_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Segment'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Segment;

FUNCTION application_id ( p_application_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_application_id IS NULL OR
        p_application_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_application_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','application_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Application_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Application_Id;

FUNCTION Segment_Mapping_Column ( p_segment_mapping_column IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_segment_mapping_column IS NULL OR
        p_segment_mapping_column = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_segment_mapping_column;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment_mapping_column');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Segment_Mapping_Column'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Segment_Mapping_Column;

FUNCTION User_Format_Type ( p_user_format_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_user_format_type IS NULL OR
        p_user_format_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_user_format_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_format_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'User_Format_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Format_Type;

FUNCTION User_Precedence ( p_user_precedence IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_user_precedence IS NULL OR
        p_user_precedence = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_user_precedence;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_precedence');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'User_Precedence'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Precedence;

FUNCTION User_Segment_Name ( p_user_segment_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_user_segment_name IS NULL OR
        p_user_segment_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_user_segment_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_segment_name');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'User_Segment_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Segment_Name;

FUNCTION User_Valueset ( p_user_valueset_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_user_valueset_id IS NULL OR
        p_user_valueset_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_user_valueset_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_valueset');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'User_Valueset'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Valueset;


FUNCTION Lookup ( p_lookup_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_lookup_code IS NULL OR
        p_lookup_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_lookup_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lookup');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lookup'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lookup;

FUNCTION Lookup_Type ( p_lookup_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_lookup_type IS NULL OR
        p_lookup_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_lookup_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lookup_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lookup_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lookup_Type;

FUNCTION Meaning ( p_meaning IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_meaning IS NULL OR
        p_meaning = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_meaning;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','meaning');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Meaning'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Meaning;


FUNCTION Line_Level_Global_Struct ( p_line_level_global_struct IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_line_level_global_struct IS NULL OR
        p_line_level_global_struct = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_line_level_global_struct;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_level_global_struct');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Level_Global_Struct'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line_Level_Global_Struct;

FUNCTION Line_Level_View_Name ( p_line_level_view_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_line_level_view_name IS NULL OR
        p_line_level_view_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_line_level_view_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_level_view_name');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Level_View_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line_Level_View_Name;

FUNCTION Order_Level_Global_Struct ( p_order_level_global_struct IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_order_level_global_struct IS NULL OR
        p_order_level_global_struct = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_order_level_global_struct;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_level_global_struct');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Level_Global_Struct'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Level_Global_Struct;

FUNCTION Order_Level_View_Name ( p_order_level_view_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_order_level_view_name IS NULL OR
        p_order_level_view_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_order_level_view_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_level_view_name');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Level_View_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Level_View_Name;

FUNCTION Pte ( p_pte_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pte_code IS NULL OR
        p_pte_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pte_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pte'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pte;

FUNCTION Request_Type ( p_request_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_request_type_code IS NULL OR
        p_request_type_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_request_type_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','request_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Request_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Request_Type;

FUNCTION Request_Type_Desc ( p_request_type_desc IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_request_type_desc IS NULL OR
        p_request_type_desc = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_request_type_desc;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','request_type_desc');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Request_Type_Desc'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Request_Type_Desc;


FUNCTION Application_Short_Name ( p_application_short_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_application_short_name IS NULL OR
        p_application_short_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_application_short_name;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','application_short_name');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Application_Short_Name'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Application_Short_Name;

FUNCTION Pte_Source_System ( p_pte_source_system_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pte_source_system_id IS NULL OR
        p_pte_source_system_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pte_source_system_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte_source_system');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pte_Source_System'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pte_Source_System;


FUNCTION Limits_Enabled ( p_limits_enabled IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_limits_enabled IS NULL OR
        p_limits_enabled = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_limits_enabled;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limits_enabled');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limits_Enabled'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limits_Enabled;

FUNCTION Lov_Enabled ( p_lov_enabled IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_lov_enabled IS NULL OR
        p_lov_enabled = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_lov_enabled;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','lov_enabled');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lov_Enabled'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lov_Enabled;

FUNCTION Seeded_Sourcing_Method ( p_seeded_sourcing_method IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_seeded_sourcing_method IS NULL OR
        p_seeded_sourcing_method = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_seeded_sourcing_method;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_sourcing_method');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Seeded_Sourcing_Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded_Sourcing_Method;

FUNCTION Segment_Level ( p_segment_level IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_segment_level IS NULL OR
        p_segment_level = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_segment_level;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment_level');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Segment_Level'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Segment_Level;

FUNCTION Segment_Pte ( p_segment_pte_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_segment_pte_id IS NULL OR
        p_segment_pte_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_segment_pte_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','segment_pte');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Segment_Pte'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Segment_Pte;

FUNCTION Sourcing_Enabled ( p_sourcing_enabled IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_sourcing_enabled IS NULL OR
        p_sourcing_enabled = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_sourcing_enabled;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sourcing_enabled');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sourcing_Enabled'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sourcing_Enabled;

FUNCTION Sourcing_Status ( p_sourcing_status IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_sourcing_status IS NULL OR
        p_sourcing_status = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_sourcing_status;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sourcing_status');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sourcing_Status'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sourcing_Status;

FUNCTION User_Sourcing_Method ( p_user_sourcing_method IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_user_sourcing_method IS NULL OR
        p_user_sourcing_method = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_user_sourcing_method;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_sourcing_method');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'User_Sourcing_Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Sourcing_Method;


FUNCTION Attribute_Sourcing ( p_attribute_sourcing_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_attribute_sourcing_id IS NULL OR
        p_attribute_sourcing_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_attribute_sourcing_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','attribute_sourcing');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attribute_Sourcing'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Attribute_Sourcing;

FUNCTION Attribute_Sourcing_Level ( p_attribute_sourcing_level IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_attribute_sourcing_level IS NULL OR
        p_attribute_sourcing_level = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_attribute_sourcing_level;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','attribute_sourcing_level');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attribute_Sourcing_Level'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Attribute_Sourcing_Level;

FUNCTION Seeded_Sourcing_Type ( p_seeded_sourcing_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_seeded_sourcing_type IS NULL OR
        p_seeded_sourcing_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_seeded_sourcing_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_sourcing_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Seeded_Sourcing_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded_Sourcing_Type;

FUNCTION Seeded_Value_String ( p_seeded_value_string IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_seeded_value_string IS NULL OR
        p_seeded_value_string = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_seeded_value_string;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','seeded_value_string');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Seeded_Value_String'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Seeded_Value_String;

FUNCTION User_Sourcing_Type ( p_user_sourcing_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_user_sourcing_type IS NULL OR
        p_user_sourcing_type = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_user_sourcing_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_sourcing_type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'User_Sourcing_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Sourcing_Type;

FUNCTION User_Value_String ( p_user_value_string IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_user_value_string IS NULL OR
        p_user_value_string = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_user_value_string;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','user_value_string');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'User_Value_String'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Value_String;


FUNCTION List_Source_Code ( p_list_source_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_list_source_code IS NULL OR
        p_list_source_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_list_source_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_source_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Source_Code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Source_Code;

FUNCTION Required_Flag ( p_required_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Required_Flag IS NULL OR
        p_Required_Flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Required_Flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Required_Flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Required_Flag'
	     );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Required_Flag;


FUNCTION  Net_Amount( p_net_amount_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_net_amount_flag IS NULL OR
        p_net_amount_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_net_amount_flag;

    RETURN TRUE;
 EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','net_amount_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Net_Amount_Flag'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END Net_Amount;

FUNCTION  Accum_Attribute(p_accum_attribute IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_accum_attribute IS NULL OR
        p_accum_attribute = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_accum_attribute;

    RETURN TRUE;
 EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accum_attribute');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Accum_Attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Accum_Attribute;


FUNCTION Functional_Area ( p_functional_area_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_functional_area_id IS NULL OR
        p_functional_area_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_functional_area_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','functional_area');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Functional_Area'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Functional_Area;

FUNCTION Pte_Sourcesystem_Fnarea ( p_pte_sourcesystem_fnarea_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_pte_sourcesystem_fnarea_id IS NULL OR
        p_pte_sourcesystem_fnarea_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pte_sourcesystem_fnarea_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte_sourcesystem_fnarea');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pte_Sourcesystem_Fnarea'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pte_Sourcesystem_Fnarea;

--  END GEN validate

-- Blanket Pricing

FUNCTION Orig_System_Header_Ref(p_Orig_System_Header_Ref IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF P_orig_system_header_ref IS NULL OR
        P_orig_system_header_ref = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = P_orig_system_header_ref;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','orig_system_header_ref');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Orig_System_Header_Ref'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Orig_System_Header_Ref;

FUNCTION Shareable_Flag( p_shareable_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_shareable_flag IS NULL OR
        p_shareable_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shareable_flag;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','shareable_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shareable_Flag'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shareable_Flag;

FUNCTION Sold_To_Org_Id(p_Sold_To_Org_Id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_sold_to_org_id IS NULL OR
        p_sold_to_org_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_sold_to_org_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_org_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sold_To_Org_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sold_To_Org_Id;

FUNCTION Customer_Item_Id(p_customer_item_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_customer_item_id IS NULL OR
        p_customer_item_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_customer_item_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Customer_Item_Id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer_Item_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_Item_Id;

FUNCTION  break_uom_code( p_break_uom_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_break_uom_code IS NULL OR
        p_break_uom_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_break_uom_code;

    RETURN TRUE;
 EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','break_uom_code');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'break_uom_code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END break_uom_code;

FUNCTION  break_uom_context( p_break_uom_context IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_break_uom_context IS NULL OR
        p_break_uom_context = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_break_uom_context;

    RETURN TRUE;
 EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','break_uom_context');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'break_uom_context'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END break_uom_context;


FUNCTION  break_uom_attribute( p_break_uom_attribute IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_break_uom_attribute IS NULL OR
        p_break_uom_attribute = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_break_uom_attribute;

    RETURN TRUE;
 EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','break_uom_attribute');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'break_uom_attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END break_uom_attribute;


FUNCTION Locked_From_List_Header_Id(p_Locked_From_List_Header_Id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_locked_from_list_header_id IS NULL OR
        p_locked_from_list_header_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_locked_from_list_header_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','locked_from_list_header_id');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Locked_From_List_Header_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Locked_From_List_Header_Id;

--added for MOAC
FUNCTION Org_id( p_org_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_org_id IS NULL OR
        p_org_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;


    l_dummy := QP_UTIL.Validate_Org_Id(p_org_id);

    IF l_dummy = 'Y' THEN
        RETURN TRUE;
    ELSIF l_dummy = 'N' THEN
        FND_MESSAGE.SET_NAME('FND','FND_MO_ORG_INVALID');
--        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Org_id');
        OE_MSG_PUB.Add;

        RETURN FALSE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shareable_flag;

    RETURN TRUE;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Org_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Org_Id;

-- added for TCA
FUNCTION Party_Hierarchy_Enabled_Flag( p_party_hierarchy_enabled_flag IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_party_hierarchy_enabled_flag IS NULL OR
        p_party_hierarchy_enabled_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shareable_flag;

    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','party_hierarchy_enabled_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Party_Hierarchy_Enabled_Flag'
            );
        END IF;

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Party_Hierarchy_Enabled_Flag;



FUNCTION Qualify_Hier_Descendent_Flag( p_qualify_hier_descendent_flag IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_qualify_hier_descendent_flag IS NULL OR
        p_qualify_hier_descendent_flag = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shareable_flag;

    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','qualify_hier_descendents_flag');
            OE_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME
            ,   'Qualify_Hier_Descendent_Flag'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualify_Hier_Descendent_Flag;

END QP_Validate;

/
