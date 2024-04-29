--------------------------------------------------------
--  DDL for Package OE_VALIDATE_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VALIDATE_ADJ" AUTHID CURRENT_USER AS
/* $Header: OEXSVADS.pls 120.0 2005/06/01 02:40:20 appldev noship $ */

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

FUNCTION Adjusted_Amount(p_Adjusted_Amount IN NUMBER)RETURN BOOLEAN;
FUNCTION Pricing_Phase_id(p_Pricing_Phase_id IN NUMBER)RETURN BOOLEAN;

FUNCTION Desc_Flex ( p_appl_short_name varchar2,p_flex_name IN VARCHAR2 )RETURN BOOLEAN;
FUNCTION Created_By(p_created_by IN NUMBER)RETURN BOOLEAN;
FUNCTION Creation_Date(p_creation_date IN DATE)RETURN BOOLEAN;
FUNCTION Header(p_header_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Last_Update_Date(p_last_update_date IN DATE)RETURN BOOLEAN;
FUNCTION Last_Update_Login(p_last_update_login IN NUMBER)RETURN BOOLEAN;
FUNCTION Last_Updated_By(p_last_updated_by IN NUMBER)RETURN BOOLEAN;
FUNCTION Line(p_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Percent(p_percent IN NUMBER)RETURN BOOLEAN;
FUNCTION Program_Application(p_program_application_id IN NUMBER)RETURN BOOLEAN;
FUNCTION program(p_program_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Program_Update_Date(p_program_update_date IN DATE)RETURN BOOLEAN;
FUNCTION Request(p_request_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Request_Date(p_request_date IN DATE)RETURN BOOLEAN;
FUNCTION Applied_Flag(p_Applied_Flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Automatic(p_automatic_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Change_Reason_Code(p_Change_Reason_Code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Change_Reason_Text(p_Change_Reason_Text IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Discount(p_discount_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Discount_Line(p_discount_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION List_Header_id(p_List_Header_id IN NUMBER)RETURN BOOLEAN;
FUNCTION List_Line_id(p_List_Line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION List_Line_Type_code(p_List_Line_Type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Modified_From(p_Modified_From IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Modified_To(p_Modified_To IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Modifier_mechanism_type_code(p_Modifier_mechanism_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Price_Adjustment(p_price_adjustment_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Updated_Flag(p_Updated_Flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Update_Allowed(p_Update_Allowed IN VARCHAR2)RETURN BOOLEAN;
FUNCTION operand(p_operand IN number)RETURN BOOLEAN;
FUNCTION arithmetic_operator(p_arithmetic_operator IN varchar2)RETURN BOOLEAN;
FUNCTION LIST_LINE_NO(p_list_line_no IN VARCHAR2) RETURN BOOLEAN;
FUNCTION SOURCE_SYSTEM_CODE(p_source_system_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION BENEFIT_QTY(p_benefit_qty IN NUMBER) RETURN BOOLEAN;
FUNCTION BENEFIT_UOM_CODE(p_benefit_uom_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION PRINT_ON_INVOICE_FLAG(p_print_on_invoice_flag IN VARCHAR2) RETURN BOOLEAN;
FUNCTION EXPIRATION_DATE(p_expiration_date IN DATE) RETURN BOOLEAN;
FUNCTION REBATE_TRANSACTION_TYPE_CODE(p_rebate_transaction_type_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION REBATE_TRANSACTION_REFERENCE(p_rebate_transaction_reference IN VARCHAR2) RETURN BOOLEAN;
FUNCTION REBATE_PAYMENT_SYSTEM_CODE(p_rebate_payment_system_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION REDEEMED_DATE(p_redeemed_date IN DATE) RETURN BOOLEAN;
FUNCTION REDEEMED_FLAG(p_redeemed_flag IN VARCHAR2) RETURN BOOLEAN;
FUNCTION ACCRUAL_FLAG(p_accrual_flag IN VARCHAR2) RETURN BOOLEAN;
FUNCTION range_break_quantity(p_range_break_quantity IN NUMBER) RETURN BOOLEAN;
FUNCTION accrual_conversion_rate(p_accrual_conversion_rate IN NUMBER) RETURN BOOLEAN;
FUNCTION pricing_group_sequence(p_pricing_group_sequence IN NUMBER) RETURN BOOLEAN;
FUNCTION modifier_level_code(p_modifier_level_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION price_break_type_code(p_price_break_type_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION substitution_attribute(p_substitution_attribute IN VARCHAR2) RETURN BOOLEAN;
FUNCTION proration_type_code(p_proration_type_code IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Price_Adj_Desc_Flex (p_context IN VARCHAR2,
			   p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2)

RETURN BOOLEAN;




FUNCTION Flex_Title(p_flex_title IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Override_Flag(p_override_flag IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Order_Price_Attrib(p_order_price_attrib_id IN NUMBER)RETURN BOOLEAN;
/*
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
*/

END OE_Validate_adj;

 

/
