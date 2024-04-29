--------------------------------------------------------
--  DDL for Package Body OE_HEADER_ADJ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HEADER_ADJ_UTIL" AS
/* $Header: OEXUHADB.pls 120.4.12010000.1 2008/07/25 07:55:55 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Header_Adj_Util';

FUNCTION G_MISS_OE_AK_HEADER_ADJ_REC
RETURN OE_AK_HEADER_PRCADJS_V%ROWTYPE IS
l_rowtype_rec				OE_AK_HEADER_PRCADJS_V%ROWTYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_rowtype_rec.ATTRIBUTE1	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE10	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE11	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE12	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE13	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE14	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE15	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE2	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE3	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE4	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE5	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE6	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE7	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE8	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE9	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CONTEXT		:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.CREATED_BY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.CREATION_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.DB_FLAG		:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.HEADER_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.LAST_UPDATED_BY	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.LAST_UPDATE_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.LAST_UPDATE_LOGIN	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.LINE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.OPERATION	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.PERCENT	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.RETURN_STATUS	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AUTOMATIC_FLAG	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.DISCOUNT_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.DISCOUNT_LINE_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.PRICE_ADJUSTMENT_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.PROGRAM_APPLICATION_ID	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.PROGRAM_ID		:= FND_API.G_MISS_NUM;
    l_rowtype_rec.PROGRAM_UPDATE_DATE	:= FND_API.G_MISS_DATE;
    l_rowtype_rec.request_id		:= FND_API.G_MISS_NUM;
--    l_rowtype_rec.orig_sys_discount_ref	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.list_header_id	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.list_line_id	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.list_line_type_code	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.modifier_mechanism_type_code	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.modified_from	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.modified_to	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.updated_flag	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.update_allowed	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.applied_flag	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.change_reason_code	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.change_reason_text	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.operand	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.operand_per_pqty	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.arithmetic_operator	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.tax_code	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.tax_exempt_flag := FND_API.G_MISS_CHAR;
    l_rowtype_rec.tax_exempt_number := FND_API.G_MISS_CHAR;
    l_rowtype_rec.tax_exempt_reason_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.parent_adjustment_id := FND_API.G_MISS_NUM;
    l_rowtype_rec.invoiced_flag := FND_API.G_MISS_CHAR;
    l_rowtype_rec.estimated_flag := FND_API.G_MISS_CHAR;
    l_rowtype_rec.inc_in_sales_performance := FND_API.G_MISS_CHAR;
    l_rowtype_rec.split_action_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.charge_type_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.charge_subtype_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.adjusted_amount := FND_API.G_MISS_NUM;
    l_rowtype_rec.adjusted_amount_per_pqty := FND_API.G_MISS_NUM;
    l_rowtype_rec.pricing_phase_id := FND_API.G_MISS_NUM;
    l_rowtype_rec.list_line_no := FND_API.G_MISS_CHAR;
    l_rowtype_rec.source_system_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.benefit_qty := FND_API.G_MISS_NUM;
    l_rowtype_rec.benefit_uom_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.print_on_invoice_flag := FND_API.G_MISS_CHAR;
    l_rowtype_rec.expiration_date := FND_API.G_MISS_DATE;
    l_rowtype_rec.rebate_transaction_type_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.rebate_transaction_reference := FND_API.G_MISS_CHAR;
    l_rowtype_rec.rebate_payment_system_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.redeemed_date := FND_API.G_MISS_DATE;
    l_rowtype_rec.redeemed_flag := FND_API.G_MISS_CHAR;
    l_rowtype_rec.accrual_flag := FND_API.G_MISS_CHAR;
    l_rowtype_rec.range_break_quantity := FND_API.G_MISS_NUM;
    l_rowtype_rec.accrual_conversion_rate := FND_API.G_MISS_NUM;
    l_rowtype_rec.pricing_group_sequence := FND_API.G_MISS_NUM;
    l_rowtype_rec.modifier_level_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.price_break_type_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.substitution_attribute := FND_API.G_MISS_CHAR;
    l_rowtype_rec.proration_type_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.credit_or_charge_flag := FND_API.G_MISS_CHAR;
    l_rowtype_rec.include_on_returns_flag := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE1	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE10	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE11	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE12	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE13	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE14	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE15	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE2	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE3	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE4	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE5	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE6	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE7	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE8	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE9	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_CONTEXT		:= FND_API.G_MISS_CHAR;

    RETURN l_rowtype_rec;

END G_MISS_OE_AK_HEADER_ADJ_REC;

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_HEADER_ADJ_rec            IN  OE_Order_PUB.HEADER_ADJ_Rec_Type
,   x_rowtype_rec                   OUT nocopy OE_AK_HEADER_PRCADJS_V%ROWTYPE
) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_rowtype_rec.ATTRIBUTE1       := p_header_adj_rec.ATTRIBUTE1;
    x_rowtype_rec.ATTRIBUTE10       := p_header_adj_rec.ATTRIBUTE10;
    x_rowtype_rec.ATTRIBUTE11       := p_header_adj_rec.ATTRIBUTE11;
    x_rowtype_rec.ATTRIBUTE12       := p_header_adj_rec.ATTRIBUTE12;
    x_rowtype_rec.ATTRIBUTE13       := p_header_adj_rec.ATTRIBUTE13;
    x_rowtype_rec.ATTRIBUTE14       := p_header_adj_rec.ATTRIBUTE14;
    x_rowtype_rec.ATTRIBUTE15       := p_header_adj_rec.ATTRIBUTE15;
    x_rowtype_rec.ATTRIBUTE2       := p_header_adj_rec.ATTRIBUTE2;
    x_rowtype_rec.ATTRIBUTE3       := p_header_adj_rec.ATTRIBUTE3;
    x_rowtype_rec.ATTRIBUTE4       := p_header_adj_rec.ATTRIBUTE4;
    x_rowtype_rec.ATTRIBUTE5       := p_header_adj_rec.ATTRIBUTE5;
    x_rowtype_rec.ATTRIBUTE6       := p_header_adj_rec.ATTRIBUTE6;
    x_rowtype_rec.ATTRIBUTE7       := p_header_adj_rec.ATTRIBUTE7;
    x_rowtype_rec.ATTRIBUTE8       := p_header_adj_rec.ATTRIBUTE8;
    x_rowtype_rec.ATTRIBUTE9       := p_header_adj_rec.ATTRIBUTE9;
    x_rowtype_rec.CONTEXT       := p_header_adj_rec.CONTEXT;
    x_rowtype_rec.CREATED_BY       := p_header_adj_rec.CREATED_BY;
    x_rowtype_rec.CREATION_DATE       := p_header_adj_rec.CREATION_DATE;
    x_rowtype_rec.DB_FLAG       := p_header_adj_rec.DB_FLAG;
    x_rowtype_rec.HEADER_ID       := p_header_adj_rec.HEADER_ID;
    x_rowtype_rec.LAST_UPDATED_BY       := p_header_adj_rec.LAST_UPDATED_BY;
    x_rowtype_rec.LAST_UPDATE_DATE       := p_header_adj_rec.LAST_UPDATE_DATE;
    x_rowtype_rec.LAST_UPDATE_LOGIN       := p_header_adj_rec.LAST_UPDATE_LOGIN;
    x_rowtype_rec.LINE_ID       := p_header_adj_rec.LINE_ID;
    x_rowtype_rec.OPERATION       := p_header_adj_rec.OPERATION;
    x_rowtype_rec.PERCENT       := p_header_adj_rec.PERCENT;
    x_rowtype_rec.RETURN_STATUS       := p_header_adj_rec.RETURN_STATUS;
    x_rowtype_rec.AUTOMATIC_FLAG	:= p_header_adj_rec.AUTOMATIC_FLAG;
    x_rowtype_rec.DISCOUNT_ID	:= p_header_adj_rec.DISCOUNT_ID;
    x_rowtype_rec.DISCOUNT_LINE_ID	:= p_header_adj_rec.DISCOUNT_LINE_ID;
    x_rowtype_rec.PRICE_ADJUSTMENT_ID	:= p_header_adj_rec.PRICE_ADJUSTMENT_ID;
    x_rowtype_rec.PROGRAM_APPLICATION_ID	:= p_header_adj_rec.PROGRAM_APPLICATION_ID;
    x_rowtype_rec.PROGRAM_ID		:= p_header_adj_rec.PROGRAM_ID;
    x_rowtype_rec.PROGRAM_UPDATE_DATE	:= p_header_adj_rec.PROGRAM_UPDATE_DATE;
    x_rowtype_rec.request_id		:= p_header_adj_rec.request_id;
   x_rowtype_rec.orig_sys_discount_ref	:= p_header_adj_rec.orig_sys_discount_ref;
    x_rowtype_rec.list_header_id	:= p_header_adj_rec.list_header_id;
    x_rowtype_rec.list_line_id	:= p_header_adj_rec.list_line_id;
    x_rowtype_rec.list_line_type_code	:= p_header_adj_rec.list_line_type_code;
    x_rowtype_rec.modifier_mechanism_type_code	:= p_header_adj_rec.modifier_mechanism_type_code;
    x_rowtype_rec.modified_from	:= p_header_adj_rec.modified_from;
    x_rowtype_rec.modified_to	:= p_header_adj_rec.modified_to;
    x_rowtype_rec.updated_flag	:= p_header_adj_rec.updated_flag;
    x_rowtype_rec.update_allowed	:= p_header_adj_rec.update_allowed;
    x_rowtype_rec.applied_flag	:= p_header_adj_rec.applied_flag;
    x_rowtype_rec.change_reason_code	:= p_header_adj_rec.change_reason_code;
    x_rowtype_rec.change_reason_text	:= p_header_adj_rec.change_reason_text;
    x_rowtype_rec.operand	:= p_header_adj_rec.operand;
    x_rowtype_rec.operand_per_pqty	:= p_header_adj_rec.operand_per_pqty;
    x_rowtype_rec.arithmetic_operator	:= p_header_adj_rec.arithmetic_operator;
    x_rowtype_rec.cost_id	:= p_header_adj_rec.cost_id;
    x_rowtype_rec.tax_code	:= p_header_adj_rec.tax_code;
    x_rowtype_rec.tax_exempt_flag := p_header_adj_rec.tax_exempt_flag;
    x_rowtype_rec.tax_exempt_number := p_header_adj_rec.tax_exempt_number;
    x_rowtype_rec.tax_exempt_reason_code := p_header_adj_rec.tax_exempt_reason_code;
    x_rowtype_rec.parent_adjustment_id := p_header_adj_rec.parent_adjustment_id;
    x_rowtype_rec.invoiced_flag := p_header_adj_rec.invoiced_flag;
    x_rowtype_rec.estimated_flag := p_header_adj_rec.estimated_flag;
    x_rowtype_rec.inc_in_sales_performance := p_header_adj_rec.inc_in_sales_performance;
    x_rowtype_rec.split_action_code := p_header_adj_rec.split_action_code;
    x_rowtype_rec.charge_type_code := p_header_adj_rec.charge_type_code;
    x_rowtype_rec.charge_subtype_code := p_header_adj_rec.charge_subtype_code;

    x_rowtype_rec.adjusted_amount := p_header_adj_rec.adjusted_amount;
    x_rowtype_rec.adjusted_amount_per_pqty := p_header_adj_rec.adjusted_amount_per_pqty;
    x_rowtype_rec.pricing_phase_id := p_header_adj_rec.pricing_phase_id;
    x_rowtype_rec.list_line_no := p_header_adj_rec.list_line_no;
    x_rowtype_rec.source_system_code := p_header_adj_rec.source_system_code;
    x_rowtype_rec.benefit_qty := p_header_adj_rec.benefit_qty;
    x_rowtype_rec.benefit_uom_code := p_header_adj_rec.benefit_uom_code;
    x_rowtype_rec.print_on_invoice_flag := p_header_adj_rec.print_on_invoice_flag;
    x_rowtype_rec.expiration_date := p_header_adj_rec.expiration_date;
    x_rowtype_rec.rebate_transaction_type_code := p_header_adj_rec.rebate_transaction_type_code;
    x_rowtype_rec.rebate_transaction_reference := p_header_adj_rec.rebate_transaction_reference;
    x_rowtype_rec.rebate_payment_system_code := p_header_adj_rec.rebate_payment_system_code;
    x_rowtype_rec.redeemed_date := p_header_adj_rec.redeemed_date;
    x_rowtype_rec.redeemed_flag := p_header_adj_rec.redeemed_flag;
    x_rowtype_rec.accrual_flag := p_header_adj_rec.accrual_flag;
    x_rowtype_rec.range_break_quantity := p_header_adj_rec.range_break_quantity;
    x_rowtype_rec.accrual_conversion_rate := p_header_adj_rec.accrual_conversion_rate;
    x_rowtype_rec.pricing_group_sequence := p_header_adj_rec.pricing_group_sequence;
    x_rowtype_rec.modifier_level_code := p_header_adj_rec.modifier_level_code;
    x_rowtype_rec.price_break_type_code := p_header_adj_rec.price_break_type_code;
    x_rowtype_rec.substitution_attribute := p_header_adj_rec.substitution_attribute;
    x_rowtype_rec.proration_type_code := p_header_adj_rec.proration_type_code;
    x_rowtype_rec.credit_or_charge_flag := p_header_adj_rec.credit_or_charge_flag;
    x_rowtype_rec.include_on_returns_flag := p_header_adj_rec.include_on_returns_flag;
    x_rowtype_rec.AC_ATTRIBUTE1       := p_header_adj_rec.AC_ATTRIBUTE1;
    x_rowtype_rec.AC_ATTRIBUTE10      := p_header_adj_rec.AC_ATTRIBUTE10;
    x_rowtype_rec.AC_ATTRIBUTE11      := p_header_adj_rec.AC_ATTRIBUTE11;
    x_rowtype_rec.AC_ATTRIBUTE12      := p_header_adj_rec.AC_ATTRIBUTE12;
    x_rowtype_rec.AC_ATTRIBUTE13      := p_header_adj_rec.AC_ATTRIBUTE13;
    x_rowtype_rec.AC_ATTRIBUTE14      := p_header_adj_rec.AC_ATTRIBUTE14;
    x_rowtype_rec.AC_ATTRIBUTE15      := p_header_adj_rec.AC_ATTRIBUTE15;
    x_rowtype_rec.AC_ATTRIBUTE2       := p_header_adj_rec.AC_ATTRIBUTE2;
    x_rowtype_rec.AC_ATTRIBUTE3       := p_header_adj_rec.AC_ATTRIBUTE3;
    x_rowtype_rec.AC_ATTRIBUTE4       := p_header_adj_rec.AC_ATTRIBUTE4;
    x_rowtype_rec.AC_ATTRIBUTE5       := p_header_adj_rec.AC_ATTRIBUTE5;
    x_rowtype_rec.AC_ATTRIBUTE6       := p_header_adj_rec.AC_ATTRIBUTE6;
    x_rowtype_rec.AC_ATTRIBUTE7       := p_header_adj_rec.AC_ATTRIBUTE7;
    x_rowtype_rec.AC_ATTRIBUTE8       := p_header_adj_rec.AC_ATTRIBUTE8;
    x_rowtype_rec.AC_ATTRIBUTE9       := p_header_adj_rec.AC_ATTRIBUTE9;
    x_rowtype_rec.AC_CONTEXT          := p_header_adj_rec.AC_CONTEXT;
    x_rowtype_rec.invoiced_amount     := p_header_adj_rec.invoiced_amount;

END API_Rec_To_RowType_Rec;


PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_HEADER_PRCADJS_V%ROWTYPE
,   x_api_rec                       OUT nocopy OE_Order_PUB.HEADER_ADJ_Rec_Type
)
iS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_api_rec.ATTRIBUTE1       := p_record.ATTRIBUTE1;
    x_api_rec.ATTRIBUTE10       := p_record.ATTRIBUTE10;
    x_api_rec.ATTRIBUTE11       := p_record.ATTRIBUTE11;
    x_api_rec.ATTRIBUTE12       := p_record.ATTRIBUTE12;
    x_api_rec.ATTRIBUTE13       := p_record.ATTRIBUTE13;
    x_api_rec.ATTRIBUTE14       := p_record.ATTRIBUTE14;
    x_api_rec.ATTRIBUTE15       := p_record.ATTRIBUTE15;
    x_api_rec.ATTRIBUTE2       := p_record.ATTRIBUTE2;
    x_api_rec.ATTRIBUTE3       := p_record.ATTRIBUTE3;
    x_api_rec.ATTRIBUTE4       := p_record.ATTRIBUTE4;
    x_api_rec.ATTRIBUTE5       := p_record.ATTRIBUTE5;
    x_api_rec.ATTRIBUTE6       := p_record.ATTRIBUTE6;
    x_api_rec.ATTRIBUTE7       := p_record.ATTRIBUTE7;
    x_api_rec.ATTRIBUTE8       := p_record.ATTRIBUTE8;
    x_api_rec.ATTRIBUTE9       := p_record.ATTRIBUTE9;
    x_api_rec.CONTEXT       := p_record.CONTEXT;
    x_api_rec.CREATED_BY       := p_record.CREATED_BY;
    x_api_rec.CREATION_DATE       := p_record.CREATION_DATE;
    x_api_rec.DB_FLAG       := p_record.DB_FLAG;
    x_api_rec.HEADER_ID       := p_record.HEADER_ID;
    x_api_rec.LAST_UPDATED_BY       := p_record.LAST_UPDATED_BY;
    x_api_rec.LAST_UPDATE_DATE       := p_record.LAST_UPDATE_DATE;
    x_api_rec.LAST_UPDATE_LOGIN       := p_record.LAST_UPDATE_LOGIN;
    x_api_rec.LINE_ID       := p_record.LINE_ID;
    x_api_rec.OPERATION       := p_record.OPERATION;
    x_api_rec.PERCENT       := p_record.PERCENT;
    x_api_rec.RETURN_STATUS       := p_record.RETURN_STATUS;
    x_api_rec.AUTOMATIC_FLAG	:= p_record.AUTOMATIC_FLAG;
    x_api_rec.DISCOUNT_ID	:= p_record.DISCOUNT_ID;
    x_api_rec.DISCOUNT_LINE_ID	:= p_record.DISCOUNT_LINE_ID;
    x_api_rec.PRICE_ADJUSTMENT_ID	:= p_record.PRICE_ADJUSTMENT_ID;
    x_api_rec.PROGRAM_APPLICATION_ID	:= p_record.PROGRAM_APPLICATION_ID;
    x_api_rec.PROGRAM_ID		:= p_record.PROGRAM_ID;
    x_api_rec.PROGRAM_UPDATE_DATE	:= p_record.PROGRAM_UPDATE_DATE;
    x_api_rec.request_id		:= p_record.request_id;
    x_api_rec.orig_sys_discount_ref	:= p_record.orig_sys_discount_ref;
    x_api_rec.list_header_id	:= p_record.list_header_id;
    x_api_rec.list_line_id	:= p_record.list_line_id;
    x_api_rec.list_line_type_code	:= p_record.list_line_type_code;
    x_api_rec.modifier_mechanism_type_code	:= p_record.modifier_mechanism_type_code;
    x_api_rec.modified_from	:= p_record.modified_from;
    x_api_rec.modified_to	:= p_record.modified_to;
    x_api_rec.updated_flag	:= p_record.updated_flag;
    x_api_rec.update_allowed	:= p_record.update_allowed;
    x_api_rec.applied_flag	:= p_record.applied_flag;
    x_api_rec.change_reason_code	:= p_record.change_reason_code;
    x_api_rec.change_reason_text	:= p_record.change_reason_text;
    x_api_rec.operand	:= p_record.operand;
    x_api_rec.operand_per_pqty	:= p_record.operand_per_pqty;
    x_api_rec.arithmetic_operator	:= p_record.arithmetic_operator;
    x_api_rec.cost_id	:= p_record.cost_id;
    x_api_rec.tax_code	:= p_record.tax_code;
    x_api_rec.tax_exempt_flag := p_record.tax_exempt_flag;
    x_api_rec.tax_exempt_number := p_record.tax_exempt_number;
    x_api_rec.tax_exempt_reason_code := p_record.tax_exempt_reason_code;
    x_api_rec.parent_adjustment_id := p_record.parent_adjustment_id;
    x_api_rec.invoiced_flag := p_record.invoiced_flag;
    x_api_rec.estimated_flag := p_record.estimated_flag;
    x_api_rec.inc_in_sales_performance := p_record.inc_in_sales_performance;
    x_api_rec.split_action_code := p_record.split_action_code;
    x_api_rec.charge_type_code := p_record.charge_type_code;
    x_api_rec.charge_subtype_code := p_record.charge_subtype_code;
    x_api_rec.adjusted_amount := p_record.adjusted_amount;
    x_api_rec.adjusted_amount_per_pqty := p_record.adjusted_amount_per_pqty;
    x_api_rec.pricing_phase_id := p_record.pricing_phase_id;
    x_api_rec.list_line_no := p_record.list_line_no;
    x_api_rec.source_system_code := p_record.source_system_code;
    x_api_rec.benefit_qty := p_record.benefit_qty;
    x_api_rec.benefit_uom_code := p_record.benefit_uom_code;
    x_api_rec.print_on_invoice_flag := p_record.print_on_invoice_flag;
    x_api_rec.expiration_date := p_record.expiration_date;
    x_api_rec.rebate_transaction_type_code := p_record.rebate_transaction_type_code;
    x_api_rec.rebate_transaction_reference := p_record.rebate_transaction_reference;
    x_api_rec.rebate_payment_system_code := p_record.rebate_payment_system_code;
    x_api_rec.redeemed_date := p_record.redeemed_date;
    x_api_rec.redeemed_flag := p_record.redeemed_flag;
    x_api_rec.accrual_flag := p_record.accrual_flag;
    x_api_rec.range_break_quantity := p_record.range_break_quantity;
    x_api_rec.accrual_conversion_rate := p_record.accrual_conversion_rate;
    x_api_rec.pricing_group_sequence := p_record.pricing_group_sequence;
    x_api_rec.modifier_level_code := p_record.modifier_level_code;
    x_api_rec.price_break_type_code := p_record.price_break_type_code;
    x_api_rec.substitution_attribute := p_record.substitution_attribute;
    x_api_rec.proration_type_code := p_record.proration_type_code;
    x_api_rec.credit_or_charge_flag := p_record.credit_or_charge_flag;
    x_api_rec.include_on_returns_flag := p_record.include_on_returns_flag;
    x_api_rec.AC_ATTRIBUTE1       := p_record.AC_ATTRIBUTE1;
    x_api_rec.AC_ATTRIBUTE10      := p_record.AC_ATTRIBUTE10;
    x_api_rec.AC_ATTRIBUTE11      := p_record.AC_ATTRIBUTE11;
    x_api_rec.AC_ATTRIBUTE12      := p_record.AC_ATTRIBUTE12;
    x_api_rec.AC_ATTRIBUTE13      := p_record.AC_ATTRIBUTE13;
    x_api_rec.AC_ATTRIBUTE14      := p_record.AC_ATTRIBUTE14;
    x_api_rec.AC_ATTRIBUTE15      := p_record.AC_ATTRIBUTE15;
    x_api_rec.AC_ATTRIBUTE2       := p_record.AC_ATTRIBUTE2;
    x_api_rec.AC_ATTRIBUTE3       := p_record.AC_ATTRIBUTE3;
    x_api_rec.AC_ATTRIBUTE4       := p_record.AC_ATTRIBUTE4;
    x_api_rec.AC_ATTRIBUTE5       := p_record.AC_ATTRIBUTE5;
    x_api_rec.AC_ATTRIBUTE6       := p_record.AC_ATTRIBUTE6;
    x_api_rec.AC_ATTRIBUTE7       := p_record.AC_ATTRIBUTE7;
    x_api_rec.AC_ATTRIBUTE8       := p_record.AC_ATTRIBUTE8;
    x_api_rec.AC_ATTRIBUTE9       := p_record.AC_ATTRIBUTE9;
    x_api_rec.AC_CONTEXT          := p_record.AC_CONTEXT;
    x_api_rec.invoiced_amount     := p_record.invoiced_amount;

END Rowtype_Rec_To_API_Rec;

--  Procedure Clear_Dependent_Attr

-- Over loaded Procedure , Remember to maintain 2 code sets

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Header_Adj_rec              IN OUT NOCOPY OE_AK_HEADER_PRCADJS_V%ROWTYPE
,   p_old_Header_Adj_rec            IN  OE_AK_HEADER_PRCADJS_V%ROWTYPE :=
								G_MISS_OE_AK_HEADER_ADJ_REC
-- ,   x_Header_Adj_rec                OUT nocopy OE_AK_HEADER_PRCADJS_V%ROWTYPE
)

IS
l_index			NUMBER :=0;
l_src_attr_tbl		OE_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl		OE_GLOBALS.NUMBER_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.CLEAR_DEPENDENT_ATTR' , 1 ) ;
    END IF;

    --  Load out record

  --  x_Header_Adj_rec := p_Header_Adj_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.price_adjustment_id,p_old_Header_Adj_rec.price_adjustment_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_PRICE_ADJUSTMENT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.creation_date,p_old_Header_Adj_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.created_by,p_old_Header_Adj_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_CREATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.last_update_date,p_old_Header_Adj_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.last_updated_by,p_old_Header_Adj_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.last_update_login,p_old_Header_Adj_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.program_application_id,p_old_Header_Adj_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.program_id,p_old_Header_Adj_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_PROGRAM;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.program_update_date,p_old_Header_Adj_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.request_id,p_old_Header_Adj_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_REQUEST;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.header_id,p_old_Header_Adj_rec.header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_HEADER;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.discount_id,p_old_Header_Adj_rec.discount_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_DISCOUNT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.discount_line_id,p_old_Header_Adj_rec.discount_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_DISCOUNT_LINE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.automatic_flag,p_old_Header_Adj_rec.automatic_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AUTOMATIC;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.percent,p_old_Header_Adj_rec.percent)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_PERCENT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.line_id,p_old_Header_Adj_rec.line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_LINE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.context,p_old_Header_Adj_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute1,p_old_Header_Adj_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute2,p_old_Header_Adj_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute3,p_old_Header_Adj_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute4,p_old_Header_Adj_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute5,p_old_Header_Adj_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute6,p_old_Header_Adj_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute7,p_old_Header_Adj_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute8,p_old_Header_Adj_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute9,p_old_Header_Adj_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute10,p_old_Header_Adj_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute11,p_old_Header_Adj_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute12,p_old_Header_Adj_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute13,p_old_Header_Adj_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute14,p_old_Header_Adj_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute15,p_old_Header_Adj_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.COST_ID, p_old_Header_Adj_rec.COST_ID)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_COST_ID;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.TAX_CODE, p_old_Header_Adj_rec.TAX_CODE)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_TAX_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.TAX_EXEMPT_FLAG, p_old_Header_Adj_rec.TAX_EXEMPT_FLAG)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_TAX_EXEMPT_FLAG;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.TAX_EXEMPT_NUMBER, p_old_Header_Adj_rec.TAX_EXEMPT_NUMBER)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_TAX_EXEMPT_NUMBER;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.TAX_EXEMPT_REASON_CODE, p_old_Header_Adj_rec.TAX_EXEMPT_REASON_CODE)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_TAX_EXEMPT_REASON_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.PARENT_ADJUSTMENT_ID, p_old_Header_Adj_rec.PARENT_ADJUSTMENT_ID)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_PARENT_ADJUSTMENT_ID;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.INVOICED_FLAG, p_old_Header_Adj_rec.INVOICED_FLAG)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_INVOICED_FLAG;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ESTIMATED_FLAG, p_old_Header_Adj_rec.ESTIMATED_FLAG)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_ESTIMATED_FLAG;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.INC_IN_SALES_PERFORMANCE, p_old_Header_Adj_rec.INC_IN_SALES_PERFORMANCE)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_INC_IN_SALES_PERFORMANCE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.SPLIT_ACTION_CODE, p_old_Header_Adj_rec.SPLIT_ACTION_CODE)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_SPLIT_ACTION_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.charge_type_code, p_old_Header_Adj_rec.charge_type_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_CHARGE_TYPE_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.charge_subtype_code, p_old_Header_Adj_rec.charge_subtype_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_CHARGE_SUBTYPE_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.list_line_no, p_old_Header_Adj_rec.list_line_no)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_LIST_LINE_NO;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.source_system_code, p_old_Header_Adj_rec.source_system_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_SOURCE_SYSTEM_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.benefit_qty, p_old_Header_Adj_rec.benefit_qty)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_BENEFIT_QTY;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.benefit_uom_code, p_old_Header_Adj_rec.benefit_uom_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_BENEFIT_UOM_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.print_on_invoice_flag, p_old_Header_Adj_rec.print_on_invoice_flag)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_PRINT_ON_INVOICE_FLAG;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.expiration_date, p_old_Header_Adj_rec.expiration_date)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_EXPIRATION_DATE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.rebate_transaction_type_code, p_old_Header_Adj_rec.rebate_transaction_type_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_REBATE_TRANSACTION_TYPE_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.rebate_transaction_reference, p_old_Header_Adj_rec.rebate_transaction_reference)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_REBATE_TRANSACTION_REFERENCE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.rebate_payment_system_code, p_old_Header_Adj_rec.rebate_payment_system_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_REBATE_PAYMENT_SYSTEM_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.redeemed_date, p_old_Header_Adj_rec.redeemed_date)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_REDEEMED_DATE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.redeemed_flag, p_old_Header_Adj_rec.redeemed_flag)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_REDEEMED_FLAG;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.accrual_flag, p_old_Header_Adj_rec.accrual_flag)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_ACCRUAL_FLAG;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.range_break_quantity, p_old_Header_Adj_rec.range_break_quantity)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_range_break_quantity;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.accrual_conversion_rate, p_old_Header_Adj_rec.accrual_conversion_rate)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_accrual_conversion_rate;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.pricing_group_sequence, p_old_Header_Adj_rec.pricing_group_sequence)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_pricing_group_sequence;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.modifier_level_code, p_old_Header_Adj_rec.modifier_level_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_modifier_level_code;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.price_break_type_code, p_old_Header_Adj_rec.price_break_type_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_price_break_type_code;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.substitution_attribute, p_old_Header_Adj_rec.substitution_attribute)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_substitution_attribute;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.proration_type_code, p_old_Header_Adj_rec.proration_type_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_proration_type_code;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.credit_or_charge_flag, p_old_Header_Adj_rec.credit_or_charge_flag)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_credit_or_charge_flag;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.include_on_returns_flag, p_old_Header_Adj_rec.include_on_returns_flag)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Header_ADJ_UTIL.G_include_on_returns_flag;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_context,p_old_Header_Adj_rec.ac_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute1,p_old_Header_Adj_rec.ac_attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute2,p_old_Header_Adj_rec.ac_attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute3,p_old_Header_Adj_rec.ac_attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute4,p_old_Header_Adj_rec.ac_attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute5,p_old_Header_Adj_rec.ac_attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute6,p_old_Header_Adj_rec.ac_attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute7,p_old_Header_Adj_rec.ac_attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute8,p_old_Header_Adj_rec.ac_attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute9,p_old_Header_Adj_rec.ac_attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute10,p_old_Header_Adj_rec.ac_attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute11,p_old_Header_Adj_rec.ac_attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute12,p_old_Header_Adj_rec.ac_attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute13,p_old_Header_Adj_rec.ac_attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute14,p_old_Header_Adj_rec.ac_attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ac_attribute15,p_old_Header_Adj_rec.ac_attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE15;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.operand,
                                p_old_Header_Adj_rec.operand)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_OPERAND;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.adjusted_amount,
                                p_old_Header_Adj_rec.adjusted_amount)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ADJUSTED_AMOUNT;
        END IF;

         --uom begin
        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.operand_per_pqty,
                                p_old_Header_Adj_rec.operand_per_pqty)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_OPERAND_PER_PQTY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.adjusted_amount_per_pqty,
                                p_old_Header_Adj_rec.adjusted_amount_per_pqty)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_HEADER_ADJ_UTIL.G_ADJUSTED_AMOUNT_PER_PQTY;
        END IF;
        --uom end


    ElsE
        l_index := l_index + 1.0;
        l_src_attr_tbl(l_index) := p_attr_id;

    End If;

    If l_src_attr_tbl.COUNT <> 0 THEN

        OE_Dependencies.Mark_Dependent
        (p_entity_code     => OE_GLOBALS.G_ENTITY_HEADER_ADJ,
        p_source_attr_tbl => l_src_attr_tbl,
        p_dep_attr_tbl    => l_dep_attr_tbl);

        FOR I IN 1..l_dep_attr_tbl.COUNT LOOP
            IF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_PRICE_ADJUSTMENT THEN
                p_x_Header_Adj_rec.PRICE_ADJUSTMENT_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_CREATION_DATE THEN
                p_x_Header_Adj_rec.CREATION_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_CREATED_BY THEN
                p_x_Header_Adj_rec.CREATED_BY := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_LAST_UPDATE_DATE THEN
                p_x_Header_Adj_rec.LAST_UPDATE_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_LAST_UPDATED_BY THEN
                p_x_Header_Adj_rec.LAST_UPDATED_BY := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_LAST_UPDATE_LOGIN THEN
                p_x_Header_Adj_rec.LAST_UPDATE_LOGIN := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_PROGRAM_APPLICATION THEN
                p_x_Header_Adj_rec.PROGRAM_APPLICATION_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_PROGRAM THEN
                p_x_Header_Adj_rec.PROGRAM_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_PROGRAM_UPDATE_DATE THEN
                p_x_Header_Adj_rec.PROGRAM_UPDATE_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_REQUEST THEN
                p_x_Header_Adj_rec.REQUEST_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_HEADER THEN
                p_x_Header_Adj_rec.HEADER_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_DISCOUNT THEN
                p_x_Header_Adj_rec.DISCOUNT_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_DISCOUNT_LINE THEN
                p_x_Header_Adj_rec.DISCOUNT_LINE_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AUTOMATIC THEN
                p_x_Header_Adj_rec.AUTOMATIC_FLAG := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_PERCENT THEN
                p_x_Header_Adj_rec.PERCENT := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_LINE THEN
                p_x_Header_Adj_rec.LINE_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_CONTEXT THEN
                p_x_Header_Adj_rec.CONTEXT := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE1 THEN
                p_x_Header_Adj_rec.ATTRIBUTE1 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE2 THEN
                p_x_Header_Adj_rec.ATTRIBUTE2 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE3 THEN
                p_x_Header_Adj_rec.ATTRIBUTE3 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE4 THEN
                p_x_Header_Adj_rec.ATTRIBUTE4 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE5 THEN
                p_x_Header_Adj_rec.ATTRIBUTE5 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE6 THEN
                p_x_Header_Adj_rec.ATTRIBUTE6 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE7 THEN
                p_x_Header_Adj_rec.ATTRIBUTE7 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE8 THEN
                p_x_Header_Adj_rec.ATTRIBUTE8 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE9 THEN
                p_x_Header_Adj_rec.ATTRIBUTE9 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE10 THEN
                p_x_Header_Adj_rec.ATTRIBUTE10 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE11 THEN
                p_x_Header_Adj_rec.ATTRIBUTE11 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE12 THEN
                p_x_Header_Adj_rec.ATTRIBUTE12 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE13 THEN
                p_x_Header_Adj_rec.ATTRIBUTE13 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE14 THEN
                p_x_Header_Adj_rec.ATTRIBUTE14 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ATTRIBUTE15 THEN
                p_x_Header_Adj_rec.ATTRIBUTE15 := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_COST_ID THEN
			 p_x_Header_Adj_rec.COST_ID := FND_API.G_MISS_NUM;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_TAX_CODE THEN
			 p_x_Header_Adj_rec.TAX_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_TAX_EXEMPT_FLAG THEN
			 p_x_Header_Adj_rec.TAX_EXEMPT_FLAG := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_TAX_EXEMPT_NUMBER THEN
			 p_x_Header_Adj_rec.TAX_EXEMPT_NUMBER := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_TAX_EXEMPT_REASON_CODE THEN
			 p_x_Header_Adj_rec.TAX_EXEMPT_REASON_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_PARENT_ADJUSTMENT_ID THEN
			 p_x_Header_Adj_rec.PARENT_ADJUSTMENT_ID := FND_API.G_MISS_NUM;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_INVOICED_FLAG THEN
			 p_x_Header_Adj_rec.INVOICED_FLAG := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_ESTIMATED_FLAG THEN
			 p_x_Header_Adj_rec.ESTIMATED_FLAG := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_INC_IN_SALES_PERFORMANCE THEN
			 p_x_Header_Adj_rec.INC_IN_SALES_PERFORMANCE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_SPLIT_ACTION_CODE THEN
			 p_x_Header_Adj_rec.SPLIT_ACTION_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_CHARGE_TYPE_CODE THEN
			 p_x_Header_Adj_rec.CHARGE_TYPE_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_CHARGE_SUBTYPE_CODE THEN
			 p_x_Header_Adj_rec.CHARGE_SUBTYPE_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_LIST_LINE_NO THEN
			 p_x_Header_Adj_rec.LIST_LINE_NO := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_SOURCE_SYSTEM_CODE THEN
			 p_x_Header_Adj_rec.SOURCE_SYSTEM_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_BENEFIT_QTY THEN
			 p_x_Header_Adj_rec.BENEFIT_QTY := FND_API.G_MISS_NUM;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_BENEFIT_UOM_CODE THEN
			 p_x_Header_Adj_rec.BENEFIT_UOM_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_PRINT_ON_INVOICE_FLAG THEN
			 p_x_Header_Adj_rec.PRINT_ON_INVOICE_FLAG := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_EXPIRATION_DATE THEN
			 p_x_Header_Adj_rec.EXPIRATION_DATE := FND_API.G_MISS_DATE;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_REBATE_TRANSACTION_TYPE_CODE THEN
			 p_x_Header_Adj_rec.REBATE_TRANSACTION_TYPE_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_REBATE_TRANSACTION_REFERENCE THEN
			 p_x_Header_Adj_rec.REBATE_TRANSACTION_REFERENCE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_REBATE_PAYMENT_SYSTEM_CODE THEN
			 p_x_Header_Adj_rec.REBATE_PAYMENT_SYSTEM_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_REDEEMED_DATE THEN
			 p_x_Header_Adj_rec.REDEEMED_DATE := FND_API.G_MISS_DATE;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_REDEEMED_FLAG THEN
			 p_x_Header_Adj_rec.REDEEMED_FLAG := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_ACCRUAL_FLAG THEN
			 p_x_Header_Adj_rec.ACCRUAL_FLAG := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_range_break_quantity THEN
			 p_x_Header_Adj_rec.range_break_quantity := FND_API.G_MISS_NUM;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_accrual_conversion_rate THEN
			 p_x_Header_Adj_rec.accrual_conversion_rate := FND_API.G_MISS_NUM;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_pricing_group_sequence THEN
			 p_x_Header_Adj_rec.pricing_group_sequence := FND_API.G_MISS_NUM;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_modifier_level_code THEN
			 p_x_Header_Adj_rec.modifier_level_code := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_price_break_type_code THEN
			 p_x_Header_Adj_rec.price_break_type_code := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_substitution_attribute THEN
			 p_x_Header_Adj_rec.substitution_attribute := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_proration_type_code THEN
			 p_x_Header_Adj_rec.proration_type_code := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_credit_or_charge_flag THEN
			 p_x_Header_Adj_rec.credit_or_charge_flag := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Header_ADJ_UTIL.G_include_on_returns_flag THEN
			 p_x_Header_Adj_rec.include_on_returns_flag := FND_API.G_MISS_CHAR;

            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_CONTEXT THEN
                p_x_Header_Adj_rec.AC_CONTEXT := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE1 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE1 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE2 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE2 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE3 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE3 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE4 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE4 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE5 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE5 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE6 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE6 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE7 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE7 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE8 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE8 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE9 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE9 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE10 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE10 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE11 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE11 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE12 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE12 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE13 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE13 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE14 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE14 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_AC_ATTRIBUTE15 THEN
                p_x_Header_Adj_rec.AC_ATTRIBUTE15 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_OPERAND THEN
                p_x_Header_Adj_rec.OPERAND := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ADJUSTED_AMOUNT THEN
                p_x_Header_Adj_rec.ADJUSTED_AMOUNT:= FND_API.G_MISS_NUM
;
             --uom begin
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_OPERAND_PER_PQTY THEN

                p_x_Header_Adj_rec.OPERAND_PER_PQTY := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_HEADER_ADJ_UTIL.G_ADJUSTED_AMOUNT_PER_PQTY THEN
                p_x_Header_Adj_rec.ADJUSTED_AMOUNT_PER_PQTY:= FND_API.G_MISS_NUM
;
            --uom end

            END IF;
        END LOOP;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.CLEAR_DEPENDENT_ATTR' , 1 ) ;
    END IF;

END Clear_Dependent_Attr;


-- Procedure that has new column changes
-- maintaining 2 code sets

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Header_Adj_rec              IN  out nocopy OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_REC
--,   x_Header_Adj_rec                OUT OE_Order_PUB.Header_Adj_Rec_Type
)
IS

l_Header_Adj_rec                OE_AK_HEADER_PRCADJS_V%ROWTYPE;
l_old_Header_Adj_rec            OE_AK_HEADER_PRCADJS_V%ROWTYPE ;
l_initial_Header_Adj_rec        OE_AK_HEADER_PRCADJS_V%ROWTYPE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.CLEAR_DEPENDENT_ATTR' , 1 ) ;
    END IF;

    --  Load out record

    API_Rec_To_Rowtype_Rec(p_x_Header_Adj_rec , l_Header_Adj_rec);
    API_Rec_To_Rowtype_Rec(p_Old_Header_Adj_rec , l_Old_Header_Adj_rec);
    l_Initial_Header_Adj_rec := l_Header_Adj_rec;

	Clear_Dependent_Attr
		(   p_attr_id                  => p_attr_id
		,   p_x_Header_Adj_rec         =>l_Header_Adj_rec
		,   p_old_Header_Adj_rec       =>l_Old_Header_Adj_rec
	--	,   x_Header_Adj_rec           =>l_Header_Adj_rec
		);

	Rowtype_Rec_To_API_Rec(l_Header_Adj_rec,p_x_Header_Adj_rec);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.CLEAR_DEPENDENT_ATTR' , 1 ) ;
    END IF;

END Clear_Dependent_Attr;

--bug 4060297
Procedure log_request_for_margin(p_header_id in number)
is
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_booked_flag   varchar2(1);
l_return_status  VARCHAR2(1);
begin
   If l_debug_level > 0 Then
      oe_debug_pub.add('in log_request_for_margin');
      oe_debug_pub.add('p_header_id : '||p_header_id);
   End If;
   OE_Order_Cache.Load_Order_Header(p_header_id);
   l_booked_flag := OE_ORDER_CACHE.g_header_rec.booked_flag;
   oe_debug_pub.add('l_booked_flag : '||l_booked_flag);
/*
   select booked_flag into l_booked_flag from oe_order_headers_all
   where header_id = p_header_id;
*/
   If OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
      If l_booked_flag = 'Y' Then
         IF nvl(Oe_Sys_Parameters.Value('COMPUTE_MARGIN'),'N') <> 'N' Then
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LOGGING DELAYED REQUEST FOR MARGIN HOLD FOR BOOKED HEADER ID : '||p_header_id);
            END IF;
            oe_delayed_requests_pvt.log_request(
            p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
            p_entity_id              => p_header_id,
            p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
            p_requesting_entity_id   => p_header_id,
            p_request_type           => 'MARGIN_HOLD',
            x_return_status          => l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
      END IF;
   END IF;
END Log_request_for_margin;
--bug 4060297

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_Header_Adj_rec              IN  out nocopy OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_REC
--,   x_Header_Adj_rec              OUT OE_Order_PUB.Header_Adj_Rec_Type
)
  IS
l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_price_flag		boolean := FALSE;
l_verify_payment_flag   VARCHAR2(30) := 'N';
--bug#5961160
l_calling_action        VARCHAR2(30);
l_header_rec            OE_Order_PUB.Header_Rec_Type;
l_rule_defined          VARCHAR2(1);
l_credit_check_rule_id  NUMBER;
l_credit_check_rule_rec OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type ;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.APPLY_ATTRIBUTE_CHANGES' , 1 ) ;
    END IF;

    --  Load out record

    --x_Header_Adj_rec := p_Header_Adj_rec;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.price_adjustment_id,p_old_Header_Adj_rec.price_adjustment_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.creation_date,p_old_Header_Adj_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.created_by,p_old_Header_Adj_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.last_update_date,p_old_Header_Adj_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.last_updated_by,p_old_Header_Adj_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.last_update_login,p_old_Header_Adj_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.program_application_id,p_old_Header_Adj_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.program_id,p_old_Header_Adj_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.program_update_date,p_old_Header_Adj_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.request_id,p_old_Header_Adj_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.header_id,p_old_Header_Adj_rec.header_id)
    THEN
        NULL;
    END IF;


    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.discount_id,
			    p_old_Header_Adj_rec.discount_id)
    THEN
		Null;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.discount_line_id,p_old_Header_Adj_rec.discount_line_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.automatic_flag,p_old_Header_Adj_rec.automatic_flag)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.percent,p_old_Header_Adj_rec.percent)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.line_id,p_old_Header_Adj_rec.line_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.context,p_old_Header_Adj_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute1,p_old_Header_Adj_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute2,p_old_Header_Adj_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute3,p_old_Header_Adj_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute4,p_old_Header_Adj_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute5,p_old_Header_Adj_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute6,p_old_Header_Adj_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute7,p_old_Header_Adj_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute8,p_old_Header_Adj_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute9,p_old_Header_Adj_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute10,p_old_Header_Adj_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute11,p_old_Header_Adj_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute12,p_old_Header_Adj_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute13,p_old_Header_Adj_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute14,p_old_Header_Adj_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.attribute15,p_old_Header_Adj_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.list_header_id,p_old_Header_Adj_rec.list_header_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.list_line_id,p_old_Header_Adj_rec.list_line_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.list_line_type_code,p_old_Header_Adj_rec.list_line_type_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.modifier_mechanism_type_code,p_old_Header_Adj_rec.modifier_mechanism_type_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.update_allowed,p_old_Header_Adj_rec.update_allowed)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.updated_flag,p_old_Header_Adj_rec.updated_flag)
    THEN
	   l_price_flag := TRUE;
       IF p_x_Header_Adj_rec.estimated_flag = 'Y' AND
          p_x_Header_Adj_rec.updated_flag = 'Y'
       THEN
           p_x_Header_adj_rec.estimated_flag := 'N';
       END IF;
       IF p_x_Header_Adj_rec.estimated_flag = 'N' AND
          p_x_Header_Adj_rec.updated_flag = 'N'
       THEN
           p_x_Header_adj_rec.estimated_flag := 'Y';
       END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.applied_flag,p_old_Header_Adj_rec.applied_flag)
    THEN
	   l_price_flag := TRUE;
           --bug 4060297
           log_request_for_margin(p_x_Header_Adj_rec.header_id);
    END IF;

    -- added by lkxu: populate the change reason when manual adjustment
    -- is applied by user.
    IF p_x_Header_Adj_rec.applied_flag = 'Y'
	  AND p_x_Header_Adj_rec.automatic_flag = 'N'
	  AND p_x_Header_Adj_rec.change_reason_code IS NULL THEN
         BEGIN
	    SELECT lookup_code, meaning
	    INTO   p_x_Header_Adj_rec.change_reason_code,
		      p_x_Header_Adj_rec.change_reason_text
	    FROM   oe_lookups
	    WHERE  lookup_type = 'CHANGE_CODE'
	    AND    lookup_code = 'MANUAL';

	    EXCEPTION WHEN NO_DATA_FOUND THEN
		 null;
         END;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.operand,p_old_Header_Adj_rec.operand)
    THEN
	   l_price_flag := TRUE;
           --bug 4060297
           log_request_for_margin(p_x_Header_Adj_rec.header_id);
           -- fixed bug 3271297, to log Verify Payment delayed request
           -- when freight charge changes.
           IF p_x_Header_Adj_rec.list_line_type_code='FREIGHT_CHARGE' THEN
                l_verify_payment_flag := 'Y';
           END IF;
    END IF;


    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.operand_per_pqty,p_old_Header_Adj_rec.operand_per_pqty)
    THEN
	   l_price_flag := TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.arithmetic_operator,p_old_Header_Adj_rec.arithmetic_operator)
    THEN
	   l_price_flag := TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.modified_from,p_old_Header_Adj_rec.modified_from)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.modified_to,p_old_Header_Adj_rec.modified_to)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.adjusted_amount,p_old_Header_Adj_rec.adjusted_amount)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.adjusted_amount_per_pqty,p_old_Header_Adj_rec.adjusted_amount_per_pqty)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.pricing_phase_id,p_old_Header_Adj_rec.pricing_phase_id)
    THEN
	   l_price_flag := TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.change_reason_code,p_old_Header_Adj_rec.change_reason_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.change_reason_text,p_old_Header_Adj_rec.change_reason_text)
    THEN
        NULL;
    END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.COST_ID, p_old_Header_Adj_rec.COST_ID)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.TAX_CODE, p_old_Header_Adj_rec.TAX_CODE)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.TAX_EXEMPT_FLAG, p_old_Header_Adj_rec.TAX_EXEMPT_FLAG)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.TAX_EXEMPT_NUMBER, p_old_Header_Adj_rec.TAX_EXEMPT_NUMBER)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.TAX_EXEMPT_REASON_CODE, p_old_Header_Adj_rec.TAX_EXEMPT_REASON_CODE)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.PARENT_ADJUSTMENT_ID, p_old_Header_Adj_rec.PARENT_ADJUSTMENT_ID)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.INVOICED_FLAG, p_old_Header_Adj_rec.INVOICED_FLAG)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.ESTIMATED_FLAG, p_old_Header_Adj_rec.ESTIMATED_FLAG)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.INC_IN_SALES_PERFORMANCE, p_old_Header_Adj_rec.INC_IN_SALES_PERFORMANCE)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.SPLIT_ACTION_CODE, p_old_Header_Adj_rec.SPLIT_ACTION_CODE)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.CHARGE_TYPE_CODE, p_old_Header_Adj_rec.CHARGE_TYPE_CODE)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.CHARGE_SUBTYPE_CODE, p_old_Header_Adj_rec.CHARGE_SUBTYPE_CODE)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.list_line_no, p_old_Header_Adj_rec.list_line_no)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.source_system_code, p_old_Header_Adj_rec.source_system_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.benefit_qty, p_old_Header_Adj_rec.benefit_qty)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.benefit_uom_code, p_old_Header_Adj_rec.benefit_uom_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.print_on_invoice_flag, p_old_Header_Adj_rec.print_on_invoice_flag)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.expiration_date, p_old_Header_Adj_rec.expiration_date)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.rebate_transaction_type_code, p_old_Header_Adj_rec.rebate_transaction_type_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.rebate_transaction_reference, p_old_Header_Adj_rec.rebate_transaction_reference)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.rebate_payment_system_code, p_old_Header_Adj_rec.rebate_payment_system_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.redeemed_date, p_old_Header_Adj_rec.redeemed_date)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.redeemed_flag, p_old_Header_Adj_rec.redeemed_flag)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.accrual_flag, p_old_Header_Adj_rec.accrual_flag)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.range_break_quantity, p_old_Header_Adj_rec.range_break_quantity)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.accrual_conversion_rate, p_old_Header_Adj_rec.accrual_conversion_rate)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.pricing_group_sequence, p_old_Header_Adj_rec.pricing_group_sequence)
   THEN
	   l_price_flag := TRUE;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.modifier_level_code, p_old_Header_Adj_rec.modifier_level_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.price_break_type_code, p_old_Header_Adj_rec.price_break_type_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.substitution_attribute, p_old_Header_Adj_rec.substitution_attribute)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.proration_type_code, p_old_Header_Adj_rec.proration_type_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.credit_or_charge_flag, p_old_Header_Adj_rec.credit_or_charge_flag)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.include_on_returns_flag, p_old_Header_Adj_rec.include_on_returns_flag)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Header_Adj_rec.invoiced_amount, p_old_Header_Adj_rec.invoiced_amount)
   THEN
          NULL;
   END IF;

    	IF l_price_flag and OE_Globals.G_RECURSION_MODE <> 'Y' AND
	    p_x_Header_adj_rec.list_line_type_code NOT IN ('TAX','COST')
     THEN

	     IF nvl(OE_ORDER_COPY_UTIL.G_COPY_REC.line_price_mode,-2) <> OE_ORDER_COPY_UTIL.G_CPY_ORIG_PRICE THEN
		--no point to reprice all the line is user says copy with orig price, all lines
                --has calc price = 'N'
		oe_delayed_requests_pvt.log_request(p_entity_code     => OE_GLOBALS.G_ENTITY_ALL,
					p_entity_id              => p_x_header_adj_rec.Header_id,
					p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER_ADJ,
					p_requesting_entity_id   => p_x_header_adj_rec.HEader_id,
					p_request_type           => OE_GLOBALS.G_PRICE_ADJ,
					x_return_status          => l_return_status);
	     END IF;

		l_price_flag := FALSE;
	End If;

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

        IF (l_verify_payment_flag = 'Y') THEN
           --Start bug#5961160
           -- Query the Order Header
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'OEXUHADB: BEFORE QUERYING HEADER ID : '|| p_x_header_adj_rec.header_id ) ;
           END IF;

           OE_Header_UTIL.Query_Row
             (p_header_id               => p_x_header_adj_rec.header_id
             ,x_header_rec              => l_header_rec
              );

           IF l_debug_level  > 0
           THEN
              OE_DEBUG_PUB.ADD('after query header ');
              OE_DEBUG_PUB.ADD(' ');
              OE_DEBUG_PUB.ADD('================================================');
              OE_DEBUG_PUB.ADD('Header ID           = '|| l_header_rec.header_id );
              OE_DEBUG_PUB.ADD('order_category_code = '|| l_header_rec.order_category_code );
              OE_DEBUG_PUB.ADD('Booked flag         = '|| l_header_rec.booked_flag );
              OE_DEBUG_PUB.ADD('Order number        = '|| l_header_rec.order_number );
              OE_DEBUG_PUB.ADD('payment_term_id     = '|| l_header_rec.payment_term_id );
              OE_DEBUG_PUB.ADD('order_type_id       = '|| l_header_rec.order_type_id );
              OE_DEBUG_PUB.ADD(' ');
              OE_DEBUG_PUB.ADD('================================================');
           END IF;

           -- Call Which_Rule function to find out Which Rule to Apply
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'OEXUHADB: BEFORE CALLING WHICH RULE ' ) ;
           END IF;

           l_calling_action := OE_Verify_Payment_PUB.Which_Rule(p_header_id => p_x_header_adj_rec.header_id);

           IF l_debug_level  > 0 THEN
             oe_debug_pub.add( 'OEXUHADB: RULE TO BE USED IS : '|| l_calling_action ) ;
           END IF;

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'OEXUHADB: BEFORE CHECKING IF THE RULE IS DEFINED OR NOT' ) ;
           END IF;

           l_rule_defined := OE_Verify_Payment_PUB.Check_Rule_Defined
                                ( p_header_rec     => l_header_rec
                                , p_calling_action => l_calling_action
                                ) ;

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'OEXUHADB: OUT OF RULE DEFINED : '|| l_rule_defined);
           END IF;

           IF l_rule_defined = 'Y' THEN
              l_credit_check_rule_id := NULL ;

              -- Check the Rule to Apply
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add( 'Before L_CREDIT_CHECK_RULE_ID => '|| l_credit_check_rule_id ) ;
              END IF;

              OE_CREDIT_CHECK_UTIL.Get_Credit_Check_Rule_ID
               ( p_calling_action        => l_calling_action
               , p_order_type_id         => l_header_rec.order_type_id
               , x_credit_rule_id        => l_credit_check_rule_id
                );

              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add( 'After L_CREDIT_CHECK_RULE_ID => '|| l_credit_check_rule_id ) ;
              END IF;

              OE_CREDIT_CHECK_UTIL.GET_credit_check_rule
               ( p_credit_check_rule_id   => l_credit_check_rule_id
               , x_credit_check_rules_rec => l_credit_check_rule_rec
                );

              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add( 'OEXUHADB: INCL FREIGHT CHARGE FLAG : '|| l_credit_check_rule_rec.incl_freight_charges_flag);
              END IF;

              IF NVL(l_credit_check_rule_rec.incl_freight_charges_flag,'N') = 'Y' THEN
              -- Log a request for Verify Payment
                 oe_debug_pub.add('OEXUHADB: Logging Delayed Request for Verify Payment',3);
                 OE_delayed_requests_Pvt.log_request
                  (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                   p_entity_id              => p_x_header_adj_rec.header_id,
                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
                   p_requesting_entity_id   => p_x_header_adj_rec.header_id,
                   p_request_type           => OE_GLOBALS.G_VERIFY_PAYMENT,
                   x_return_status          => l_return_status);
              END IF;
           END IF;
           --End bug#5961160
        END IF;

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.APPLY_ATTRIBUTE_CHANGES' , 1 ) ;
    END IF;

END Apply_Attribute_Changes;

--  Procedure Complete_Record

PROCEDURE Complete_Record
(   p_x_Header_Adj_rec              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type
)
IS
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type := p_x_Header_Adj_rec;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.COMPLETE_RECORD' , 1 ) ;
    END IF;

    IF l_Header_Adj_rec.price_adjustment_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.price_adjustment_id := p_old_Header_Adj_rec.price_adjustment_id;
    END IF;

    IF l_Header_Adj_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Header_Adj_rec.creation_date := p_old_Header_Adj_rec.creation_date;
    END IF;

    IF l_Header_Adj_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.created_by := p_old_Header_Adj_rec.created_by;
    END IF;

    IF l_Header_Adj_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Header_Adj_rec.last_update_date := p_old_Header_Adj_rec.last_update_date;
    END IF;

    IF l_Header_Adj_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.last_updated_by := p_old_Header_Adj_rec.last_updated_by;
    END IF;

    IF l_Header_Adj_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.last_update_login := p_old_Header_Adj_rec.last_update_login;
    END IF;

    IF l_Header_Adj_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.program_application_id := p_old_Header_Adj_rec.program_application_id;
    END IF;

    IF l_Header_Adj_rec.program_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.program_id := p_old_Header_Adj_rec.program_id;
    END IF;

    IF l_Header_Adj_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_Header_Adj_rec.program_update_date := p_old_Header_Adj_rec.program_update_date;
    END IF;

    IF l_Header_Adj_rec.request_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.request_id := p_old_Header_Adj_rec.request_id;
    END IF;

    IF l_Header_Adj_rec.header_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.header_id := p_old_Header_Adj_rec.header_id;
    END IF;

    IF l_Header_Adj_rec.discount_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.discount_id := p_old_Header_Adj_rec.discount_id;
    END IF;

    IF l_Header_Adj_rec.discount_line_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.discount_line_id := p_old_Header_Adj_rec.discount_line_id;
    END IF;

    IF l_Header_Adj_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.automatic_flag := p_old_Header_Adj_rec.automatic_flag;
    END IF;

    IF l_Header_Adj_rec.percent = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.percent := p_old_Header_Adj_rec.percent;
    END IF;

    IF l_Header_Adj_rec.line_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.line_id := p_old_Header_Adj_rec.line_id;
    END IF;

    IF l_Header_Adj_rec.context = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.context := p_old_Header_Adj_rec.context;
    END IF;

    IF l_Header_Adj_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute1 := p_old_Header_Adj_rec.attribute1;
    END IF;

    IF l_Header_Adj_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute2 := p_old_Header_Adj_rec.attribute2;
    END IF;

    IF l_Header_Adj_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute3 := p_old_Header_Adj_rec.attribute3;
    END IF;

    IF l_Header_Adj_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute4 := p_old_Header_Adj_rec.attribute4;
    END IF;

    IF l_Header_Adj_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute5 := p_old_Header_Adj_rec.attribute5;
    END IF;

    IF l_Header_Adj_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute6 := p_old_Header_Adj_rec.attribute6;
    END IF;

    IF l_Header_Adj_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute7 := p_old_Header_Adj_rec.attribute7;
    END IF;

    IF l_Header_Adj_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute8 := p_old_Header_Adj_rec.attribute8;
    END IF;

    IF l_Header_Adj_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute9 := p_old_Header_Adj_rec.attribute9;
    END IF;

    IF l_Header_Adj_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute10 := p_old_Header_Adj_rec.attribute10;
    END IF;

    IF l_Header_Adj_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute11 := p_old_Header_Adj_rec.attribute11;
    END IF;

    IF l_Header_Adj_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute12 := p_old_Header_Adj_rec.attribute12;
    END IF;

    IF l_Header_Adj_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute13 := p_old_Header_Adj_rec.attribute13;
    END IF;

    IF l_Header_Adj_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute14 := p_old_Header_Adj_rec.attribute14;
    END IF;

    IF l_Header_Adj_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute15 := p_old_Header_Adj_rec.attribute15;
    END IF;

    IF l_Header_Adj_rec.adjusted_amount = FND_API.G_MISS_NUM THEN
      l_Header_Adj_rec.adjusted_amount := p_old_Header_Adj_rec.adjusted_amount;
    END IF;

    IF l_Header_Adj_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN
    l_Header_Adj_rec.pricing_phase_id := p_old_Header_Adj_rec.pricing_phase_id;
    END IF;

    IF l_Header_Adj_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.list_header_id := p_old_Header_Adj_rec.list_header_id;
    END IF;

    IF l_Header_Adj_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.list_line_id := p_old_Header_Adj_rec.list_line_id;
    END IF;
    IF l_Header_Adj_rec.modified_from = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.modified_from := p_old_Header_Adj_rec.modified_from;
    END IF;
    IF l_Header_Adj_rec.modified_to = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.modified_to := p_old_Header_Adj_rec.modified_from;
    END IF;

    IF l_Header_Adj_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.list_line_type_code := p_old_Header_Adj_rec.list_line_type_code;
    END IF;

    IF l_Header_Adj_rec.updated_flag = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.updated_flag := p_old_Header_Adj_rec.updated_flag;
    END IF;

    IF l_Header_Adj_rec.update_allowed = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.update_allowed := p_old_Header_Adj_rec.update_allowed;
    END IF;

    IF l_Header_Adj_rec.applied_flag = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.applied_flag := p_old_Header_Adj_rec.applied_flag;
    END IF;

    IF l_Header_Adj_rec.modifier_mechanism_type_code = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.modifier_mechanism_type_code := p_old_Header_Adj_rec.modifier_mechanism_type_code;
    END IF;

    IF l_Header_Adj_rec.change_reason_code = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.change_reason_code := p_old_Header_Adj_rec.change_reason_code;
    END IF;

    IF l_Header_Adj_rec.change_reason_text = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.change_reason_text := p_old_Header_Adj_rec.change_reason_text;
    END IF;

    IF l_Header_Adj_rec.arithmetic_operator = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.arithmetic_operator := p_old_Header_Adj_rec.arithmetic_operator;
    END IF;

    IF l_Header_Adj_rec.operand = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.operand := p_old_Header_Adj_rec.operand;
    END IF;

	IF l_Header_Adj_rec.cost_id = FND_API.G_MISS_NUM THEN
	    l_Header_Adj_rec.cost_id :=  p_old_Header_Adj_rec.cost_id;
	END IF;

	IF l_Header_Adj_rec.tax_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.tax_code := p_old_Header_Adj_rec.tax_code;
	END IF;

	IF l_Header_Adj_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.tax_exempt_flag :=
	    p_old_Header_Adj_rec.tax_exempt_flag;
	END IF;

	IF l_Header_Adj_rec.tax_exempt_number = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.tax_exempt_number :=
	    p_old_Header_Adj_rec.tax_exempt_number;
	END IF;

	IF l_Header_Adj_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.tax_exempt_reason_code :=
	    p_old_Header_Adj_rec.tax_exempt_reason_code;
	END IF;

	IF l_Header_Adj_rec.parent_adjustment_id = FND_API.G_MISS_NUM THEN
	    l_Header_Adj_rec.parent_adjustment_id :=
	    p_old_Header_Adj_rec.parent_adjustment_id;
	END IF;

	IF l_Header_Adj_rec.invoiced_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.invoiced_flag :=
	    p_old_Header_Adj_rec.invoiced_flag;
	END IF;

	IF l_Header_Adj_rec.estimated_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.estimated_flag :=
	    p_old_Header_Adj_rec.estimated_flag;
	END IF;

	IF l_Header_Adj_rec.inc_in_sales_performance = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.inc_in_sales_performance :=
	    p_old_Header_Adj_rec.inc_in_sales_performance;
	END IF;

	IF l_Header_Adj_rec.split_action_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.split_action_code :=
	    p_old_Header_Adj_rec.split_action_code;
	END IF;

	IF l_Header_Adj_rec.charge_type_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.charge_type_code :=
	    p_old_Header_Adj_rec.charge_type_code;
	END IF;

	IF l_Header_Adj_rec.charge_subtype_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.charge_subtype_code :=
	    p_old_Header_Adj_rec.charge_subtype_code;
	END IF;

	IF l_Header_Adj_rec.list_line_no = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.list_line_no :=
	    p_old_Header_Adj_rec.list_line_no;
	END IF;

	IF l_Header_Adj_rec.source_system_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.source_system_code :=
	    p_old_Header_Adj_rec.source_system_code;
	END IF;

	IF l_Header_Adj_rec.benefit_qty = FND_API.G_MISS_NUM THEN
	    l_Header_Adj_rec.benefit_qty :=
	    p_old_Header_Adj_rec.benefit_qty;
	END IF;

	IF l_Header_Adj_rec.benefit_uom_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.benefit_uom_code :=
	    p_old_Header_Adj_rec.benefit_uom_code;
	END IF;

	IF l_Header_Adj_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.print_on_invoice_flag :=
	    p_old_Header_Adj_rec.print_on_invoice_flag;
	END IF;

	IF l_Header_Adj_rec.expiration_date = FND_API.G_MISS_DATE THEN
	    l_Header_Adj_rec.expiration_date :=
	    p_old_Header_Adj_rec.expiration_date;
	END IF;

	IF l_Header_Adj_rec.rebate_transaction_type_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.rebate_transaction_type_code :=
	    p_old_Header_Adj_rec.rebate_transaction_type_code;
	END IF;

	IF l_Header_Adj_rec.rebate_transaction_reference = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.rebate_transaction_reference :=
	    p_old_Header_Adj_rec.rebate_transaction_reference;
	END IF;

	IF l_Header_Adj_rec.rebate_payment_system_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.rebate_payment_system_code :=
	    p_old_Header_Adj_rec.rebate_payment_system_code;
	END IF;

	IF l_Header_Adj_rec.redeemed_date = FND_API.G_MISS_DATE THEN
	    l_Header_Adj_rec.redeemed_date :=
	    p_old_Header_Adj_rec.redeemed_date;
	END IF;

	IF l_Header_Adj_rec.redeemed_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.redeemed_flag :=
	    p_old_Header_Adj_rec.redeemed_flag;
	END IF;

	IF l_Header_Adj_rec.accrual_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.accrual_flag :=
	    p_old_Header_Adj_rec.accrual_flag;
	END IF;

	IF l_Header_Adj_rec.range_break_quantity = FND_API.G_MISS_NUM THEN
	    l_Header_Adj_rec.range_break_quantity :=
	    p_old_Header_Adj_rec.range_break_quantity;
	END IF;

	IF l_Header_Adj_rec.accrual_conversion_rate = FND_API.G_MISS_NUM THEN
	    l_Header_Adj_rec.accrual_conversion_rate :=
	    p_old_Header_Adj_rec.accrual_conversion_rate;
	END IF;

	IF l_Header_Adj_rec.pricing_group_sequence = FND_API.G_MISS_NUM THEN
	    l_Header_Adj_rec.pricing_group_sequence :=
	    p_old_Header_Adj_rec.pricing_group_sequence;
	END IF;

	IF l_Header_Adj_rec.modifier_level_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.modifier_level_code :=
	    p_old_Header_Adj_rec.modifier_level_code;
	END IF;

	IF l_Header_Adj_rec.price_break_type_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.price_break_type_code :=
	    p_old_Header_Adj_rec.price_break_type_code;
	END IF;

	IF l_Header_Adj_rec.substitution_attribute = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.substitution_attribute :=
	    p_old_Header_Adj_rec.substitution_attribute;
	END IF;

	IF l_Header_Adj_rec.proration_type_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.proration_type_code :=
	    p_old_Header_Adj_rec.proration_type_code;
	END IF;

	IF l_Header_Adj_rec.credit_or_charge_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.credit_or_charge_flag :=
	    p_old_Header_Adj_rec.credit_or_charge_flag;
	END IF;

	IF l_Header_Adj_rec.include_on_returns_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.include_on_returns_flag :=
	    p_old_Header_Adj_rec.include_on_returns_flag;
	END IF;


    IF l_Header_Adj_rec.ac_context = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_context := p_old_Header_Adj_rec.ac_context;
    END IF;

    IF l_Header_Adj_rec.ac_attribute1 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute1 := p_old_Header_Adj_rec.ac_attribute1;
    END IF;

    IF l_Header_Adj_rec.ac_attribute2 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute2 := p_old_Header_Adj_rec.ac_attribute2;
    END IF;

    IF l_Header_Adj_rec.ac_attribute3 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute3 := p_old_Header_Adj_rec.ac_attribute3;
    END IF;

    IF l_Header_Adj_rec.ac_attribute4 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute4 := p_old_Header_Adj_rec.ac_attribute4;
    END IF;

    IF l_Header_Adj_rec.ac_attribute5 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute5 := p_old_Header_Adj_rec.ac_attribute5;
    END IF;

    IF l_Header_Adj_rec.ac_attribute6 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute6 := p_old_Header_Adj_rec.ac_attribute6;
    END IF;

    IF l_Header_Adj_rec.ac_attribute7 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute7 := p_old_Header_Adj_rec.ac_attribute7;
    END IF;

    IF l_Header_Adj_rec.ac_attribute8 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute8 := p_old_Header_Adj_rec.ac_attribute8;
    END IF;

    IF l_Header_Adj_rec.ac_attribute9 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute9 := p_old_Header_Adj_rec.ac_attribute9;
    END IF;

    IF l_Header_Adj_rec.ac_attribute10 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute10 := p_old_Header_Adj_rec.ac_attribute10;
    END IF;

    IF l_Header_Adj_rec.ac_attribute11 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute11 := p_old_Header_Adj_rec.ac_attribute11;
    END IF;

    IF l_Header_Adj_rec.ac_attribute12 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute12 := p_old_Header_Adj_rec.ac_attribute12;
    END IF;

    IF l_Header_Adj_rec.ac_attribute13 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute13 := p_old_Header_Adj_rec.ac_attribute13;
    END IF;

    IF l_Header_Adj_rec.ac_attribute14 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute14 := p_old_Header_Adj_rec.ac_attribute14;
    END IF;

    IF l_Header_Adj_rec.ac_attribute15 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute15 := p_old_Header_Adj_rec.ac_attribute15;
    END IF;
    --uom begin
     IF l_Header_Adj_rec.OPERAND_PER_PQTY = FND_API.G_MISS_NUM THEN
 --bug 3063549
 --l_Header_Adj_rec.OPERAND_PER_PQTY := p_old_Header_Adj_rec.OPERAND_PER_PQTY;
   l_Header_Adj_rec.OPERAND_PER_PQTY := NULL;
     END IF;

     IF l_Header_Adj_rec.ADJUSTED_AMOUNT_PER_PQTY = FND_API.G_MISS_NUM THEN
       l_Header_Adj_rec.ADJUSTED_AMOUNT_PER_PQTY := p_old_Header_Adj_rec.ADJUSTED_AMOUNT_PER_PQTY;
     END IF;
    --uom end

     IF l_Header_Adj_rec.INVOICED_AMOUNT = FND_API.G_MISS_NUM THEN
       l_Header_Adj_rec.INVOICED_AMOUNT := p_old_Header_Adj_rec.INVOICED_AMOUNT;
     END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.COMPLETE_RECORD' , 1 ) ;
    END IF;

    -- RETURN l_Header_Adj_rec;
    p_x_Header_Adj_rec := l_Header_Adj_rec;

END Complete_Record;

--  Procedure Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_Header_Adj_rec                IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
)
IS
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type := p_x_Header_Adj_rec;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.CONVERT_MISS_TO_NULL' , 1 ) ;
    END IF;

    IF l_Header_Adj_rec.price_adjustment_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.price_adjustment_id := NULL;
    END IF;

    IF l_Header_Adj_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Header_Adj_rec.creation_date := NULL;
    END IF;

    IF l_Header_Adj_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.created_by := NULL;
    END IF;

    IF l_Header_Adj_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Header_Adj_rec.last_update_date := NULL;
    END IF;

    IF l_Header_Adj_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.last_updated_by := NULL;
    END IF;

    IF l_Header_Adj_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.last_update_login := NULL;
    END IF;

    IF l_Header_Adj_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.program_application_id := NULL;
    END IF;

    IF l_Header_Adj_rec.program_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.program_id := NULL;
    END IF;

    IF l_Header_Adj_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_Header_Adj_rec.program_update_date := NULL;
    END IF;

    IF l_Header_Adj_rec.request_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.request_id := NULL;
    END IF;

    IF l_Header_Adj_rec.header_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.header_id := NULL;
    END IF;

    IF l_Header_Adj_rec.discount_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.discount_id := NULL;
    END IF;

    IF l_Header_Adj_rec.discount_line_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.discount_line_id := NULL;
    END IF;

    IF l_Header_Adj_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.automatic_flag := NULL;
    END IF;

    IF l_Header_Adj_rec.percent = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.percent := NULL;
    END IF;

    IF l_Header_Adj_rec.line_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.line_id := NULL;
    END IF;

    IF l_Header_Adj_rec.context = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.context := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute1 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute2 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute3 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute4 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute5 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute6 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute7 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute8 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute9 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute10 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute11 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute12 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute13 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute14 := NULL;
    END IF;

    IF l_Header_Adj_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.attribute15 := NULL;
    END IF;

    IF l_Header_Adj_rec.adjusted_amount = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.adjusted_amount := NULL;
    END IF;

    IF l_Header_Adj_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.pricing_phase_id := NULL;
    END IF;

    IF l_Header_Adj_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.list_header_id := NULL;
    END IF;

    IF l_Header_Adj_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.list_line_id := NULL;
    END IF;
    IF l_Header_Adj_rec.modified_from = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.modified_from := NULL;
    END IF;

    IF l_Header_Adj_rec.modified_to = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.modified_to := NULL;
    END IF;

    IF l_Header_Adj_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.list_line_type_code := NULL;
    END IF;

    IF l_Header_Adj_rec.updated_flag = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.updated_flag := NULL;
    END IF;

    IF l_Header_Adj_rec.update_allowed = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.update_allowed := NULL;
    END IF;

    IF l_Header_Adj_rec.applied_flag = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.applied_flag := NULL;
    END IF;

    IF l_Header_Adj_rec.modifier_mechanism_type_code = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.modifier_mechanism_type_code := NULL;
    END IF;

    IF l_Header_Adj_rec.change_reason_code = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.change_reason_code := NULL;
    END IF;

    IF l_Header_Adj_rec.change_reason_text = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.change_reason_text := NULL ;
    END IF;

    IF l_Header_Adj_rec.arithmetic_operator = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.arithmetic_operator := NULL ;
    END IF;

    IF l_Header_Adj_rec.operand = FND_API.G_MISS_NUM THEN
        l_Header_Adj_rec.operand := NULL ;
    END IF;

	IF l_Header_Adj_rec.cost_id = FND_API.G_MISS_NUM THEN
	    l_Header_Adj_rec.cost_id := NULL ;
	END IF;

	IF l_Header_Adj_rec.tax_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.tax_code := NULL ;
	END IF;

	IF l_Header_Adj_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.tax_exempt_flag := NULL ;
	END IF;

	IF l_Header_Adj_rec.tax_exempt_number = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.tax_exempt_number := NULL ;
	END IF;

	IF l_Header_Adj_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.tax_exempt_reason_code := NULL ;
	END IF;

	IF l_Header_Adj_rec.parent_adjustment_id = FND_API.G_MISS_NUM THEN
	    l_Header_Adj_rec.parent_adjustment_id := NULL ;
	END IF;

	IF l_Header_Adj_rec.invoiced_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.invoiced_flag := NULL ;
	END IF;

	IF l_Header_Adj_rec.estimated_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.estimated_flag := NULL ;
	END IF;

	IF l_Header_Adj_rec.inc_in_sales_performance = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.inc_in_sales_performance := NULL ;
	END IF;

	IF l_Header_Adj_rec.split_action_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.split_action_code := NULL ;
	END IF;

	IF l_Header_Adj_rec.charge_type_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.charge_type_code := NULL ;
	END IF;

	IF l_Header_Adj_rec.charge_subtype_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.charge_subtype_code := NULL ;
	END IF;

	IF l_Header_Adj_rec.list_line_no = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.list_line_no := NULL ;
	END IF;

	IF l_Header_Adj_rec.source_system_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.source_system_code := NULL ;
	END IF;

	IF l_Header_Adj_rec.benefit_qty = FND_API.G_MISS_NUM THEN
	    l_Header_Adj_rec.benefit_qty := NULL ;
	END IF;

	IF l_Header_Adj_rec.benefit_uom_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.benefit_uom_code := NULL ;
	END IF;

	IF l_Header_Adj_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.print_on_invoice_flag := NULL ;
	END IF;

	IF l_Header_Adj_rec.expiration_date = FND_API.G_MISS_DATE THEN
	    l_Header_Adj_rec.expiration_date := NULL ;
	END IF;

	IF l_Header_Adj_rec.rebate_transaction_type_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.rebate_transaction_type_code := NULL ;
	END IF;

	IF l_Header_Adj_rec.rebate_transaction_reference = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.rebate_transaction_reference := NULL ;
	END IF;

	IF l_Header_Adj_rec.rebate_payment_system_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.rebate_payment_system_code := NULL ;
	END IF;

	IF l_Header_Adj_rec.redeemed_date = FND_API.G_MISS_DATE THEN
	    l_Header_Adj_rec.redeemed_date := NULL ;
	END IF;

	IF l_Header_Adj_rec.redeemed_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.redeemed_flag := NULL ;
	END IF;

	IF l_Header_Adj_rec.accrual_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.accrual_flag := NULL ;
	END IF;

	IF l_Header_Adj_rec.range_break_quantity = FND_API.G_MISS_NUM THEN
	    l_Header_Adj_rec.range_break_quantity := NULL ;
	END IF;

	IF l_Header_Adj_rec.accrual_conversion_rate = FND_API.G_MISS_NUM THEN
	    l_Header_Adj_rec.accrual_conversion_rate := NULL ;
	END IF;

	IF l_Header_Adj_rec.pricing_group_sequence = FND_API.G_MISS_NUM THEN
	    l_Header_Adj_rec.pricing_group_sequence := NULL ;
	END IF;

	IF l_Header_Adj_rec.modifier_level_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.modifier_level_code := NULL ;
	END IF;

	IF l_Header_Adj_rec.price_break_type_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.price_break_type_code := NULL ;
	END IF;

	IF l_Header_Adj_rec.substitution_attribute = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.substitution_attribute := NULL ;
	END IF;

	IF l_Header_Adj_rec.proration_type_code = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.proration_type_code := NULL ;
	END IF;

	IF l_Header_Adj_rec.credit_or_charge_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.credit_or_charge_flag := NULL ;
	END IF;

	IF l_Header_Adj_rec.include_on_returns_flag = FND_API.G_MISS_CHAR THEN
	    l_Header_Adj_rec.include_on_returns_flag := NULL ;
	END IF;

    IF l_Header_Adj_rec.ac_context = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_context := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute1 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute1 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute2 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute2 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute3 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute3 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute4 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute4 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute5 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute5 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute6 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute6 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute7 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute7 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute8 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute8 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute9 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute9 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute10 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute10 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute11 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute11 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute12 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute12 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute13 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute13 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute14 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute14 := NULL;
    END IF;

    IF l_Header_Adj_rec.ac_attribute15 = FND_API.G_MISS_CHAR THEN
        l_Header_Adj_rec.ac_attribute15 := NULL;
    END IF;
    --uom begin
    If l_Header_Adj_rec.operand_per_pqty = FND_API.G_MISS_NUM THEN
       l_Header_Adj_rec.operand_per_pqty:=NULL;
    END IF;

    If l_Header_Adj_rec.adjusted_amount_per_pqty = FND_API.G_MISS_NUM THEN
       l_Header_Adj_rec.adjusted_amount_per_pqty:=NULL;
    END IF;
    --uom end

    If l_Header_Adj_rec.invoiced_amount = FND_API.G_MISS_NUM THEN
       l_Header_Adj_rec.invoiced_amount := NULL;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.CONVERT_MISS_TO_NULL' , 1 ) ;
    END IF;

    -- RETURN l_Header_Adj_rec;
    p_x_Header_Adj_rec := l_Header_Adj_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row


PROCEDURE Update_Row
(   p_Header_Adj_rec            IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
)
IS
l_lock_control			NUMBER;
--added for notification framework
l_index    NUMBER;
l_return_status VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.UPDATE_ROW' , 1 ) ;
    END IF;

    -- increment lock_control by 1 whenever the record is updated
    SELECT lock_control
    INTO   l_lock_control
    FROM   oe_price_adjustments
    WHERE  price_adjustment_id = p_Header_Adj_rec.price_adjustment_id;

    l_lock_control := l_lock_control + 1;


  -- calling notification framework to update global picture
  -- check code release level first. Notification framework is at Pack H level

   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'HDR_ADJ_ID= ' || P_HEADER_ADJ_REC.PRICE_ADJUSTMENT_ID ) ;
      END IF;
      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Hdr_adj_rec =>p_header_adj_rec,
                    p_hdr_adj_id => p_header_adj_rec.price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_HEADER_ADJ_UTIL.UPDATE_ROE IS: ' || L_RETURN_STATUS ) ;
      END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.UPDATE_ROW' , 1 ) ;
           END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_HEADER_ADJ_UTIL.UPDATE_ROW' ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.UPDATE_ROW' , 1 ) ;
           END IF;
	   RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF;  /*code_release_level*/
 -- notification framework end


    UPDATE  OE_PRICE_ADJUSTMENTS
    SET     PRICE_ADJUSTMENT_ID    = p_Header_Adj_rec.price_adjustment_id
    ,       CREATION_DATE          = p_Header_Adj_rec.creation_date
    ,       CREATED_BY             = p_Header_Adj_rec.created_by
    ,       LAST_UPDATE_DATE       = p_Header_Adj_rec.last_update_date
    ,       LAST_UPDATED_BY        = p_Header_Adj_rec.last_updated_by
    ,       LAST_UPDATE_LOGIN      = p_Header_Adj_rec.last_update_login
    ,       PROGRAM_APPLICATION_ID = p_Header_Adj_rec.program_application_id
    ,       PROGRAM_ID             = p_Header_Adj_rec.program_id
    ,       PROGRAM_UPDATE_DATE    = p_Header_Adj_rec.program_update_date
    ,       REQUEST_ID             = p_Header_Adj_rec.request_id
    ,       HEADER_ID              = p_Header_Adj_rec.header_id
    ,       DISCOUNT_ID            = p_Header_Adj_rec.discount_id
    ,       DISCOUNT_LINE_ID       = p_Header_Adj_rec.discount_line_id
    ,       AUTOMATIC_FLAG         = p_Header_Adj_rec.automatic_flag
    ,       PERCENT                = p_Header_Adj_rec.percent
    ,       LINE_ID                = p_Header_Adj_rec.line_id
    ,       CONTEXT                = p_Header_Adj_rec.context
    ,       ATTRIBUTE1             = p_Header_Adj_rec.attribute1
    ,       ATTRIBUTE2             = p_Header_Adj_rec.attribute2
    ,       ATTRIBUTE3             = p_Header_Adj_rec.attribute3
    ,       ATTRIBUTE4             = p_Header_Adj_rec.attribute4
    ,       ATTRIBUTE5             = p_Header_Adj_rec.attribute5
    ,       ATTRIBUTE6             = p_Header_Adj_rec.attribute6
    ,       ATTRIBUTE7             = p_Header_Adj_rec.attribute7
    ,       ATTRIBUTE8             = p_Header_Adj_rec.attribute8
    ,       ATTRIBUTE9             = p_Header_Adj_rec.attribute9
    ,       ATTRIBUTE10            = p_Header_Adj_rec.attribute10
    ,       ATTRIBUTE11            = p_Header_Adj_rec.attribute11
    ,       ATTRIBUTE12            = p_Header_Adj_rec.attribute12
    ,       ATTRIBUTE13            = p_Header_Adj_rec.attribute13
    ,       ATTRIBUTE14            = p_Header_Adj_rec.attribute14
    ,       ATTRIBUTE15            = p_Header_Adj_rec.attribute15
    ,       ORIG_SYS_DISCOUNT_REF  = p_Header_Adj_rec.orig_sys_discount_ref
    ,	  LIST_HEADER_ID		= p_Header_Adj_rec.list_header_id
    ,	  LIST_LINE_ID			= p_Header_Adj_rec.list_line_id
    ,	  LIST_LINE_TYPE_CODE	= p_Header_Adj_rec.list_line_type_code
    ,	  MODIFIER_MECHANISM_TYPE_CODE = p_Header_Adj_rec.list_header_id
    ,	  MODIFIED_FROM 		= p_Header_Adj_rec.modified_from
    ,	  MODIFIED_TO			= p_Header_Adj_rec.modified_to
    ,	  UPDATED_FLAG			= p_Header_Adj_rec.updated_flag
    ,	  UPDATE_ALLOWED		= p_Header_Adj_rec.update_allowed
    ,	  APPLIED_FLAG			= p_Header_Adj_rec.applied_flag
    ,	  CHANGE_REASON_CODE	= p_Header_Adj_rec.change_reason_code
    ,	  CHANGE_REASON_TEXT	= p_Header_Adj_rec.change_reason_text
    ,	  operand				= p_Header_Adj_rec.operand
    ,	  arithmetic_operator	= p_Header_Adj_rec.arithmetic_operator
    ,	  COST_ID                = p_Header_Adj_rec.cost_id
    ,	  TAX_CODE               = p_Header_Adj_rec.tax_code
    ,	  TAX_EXEMPT_FLAG        = p_Header_Adj_rec.tax_exempt_flag
    ,	  TAX_EXEMPT_NUMBER      = p_Header_Adj_rec.tax_exempt_number
    ,	  TAX_EXEMPT_REASON_CODE = p_Header_Adj_rec.tax_exempt_reason_code
    ,	  PARENT_ADJUSTMENT_ID   = p_Header_Adj_rec.parent_adjustment_id
    ,	  INVOICED_FLAG          = p_Header_Adj_rec.invoiced_flag
    ,	  ESTIMATED_FLAG         = p_Header_Adj_rec.estimated_flag
    ,	  INC_IN_SALES_PERFORMANCE = p_Header_Adj_rec.inc_in_sales_performance
    ,	  SPLIT_ACTION_CODE      = p_Header_Adj_rec.split_action_code
    ,	  ADJUSTED_AMOUNT		= p_Header_Adj_rec.adjusted_amount
    ,	  PRICING_PHASE_ID		= p_Header_Adj_rec.pricing_phase_id
    ,	  CHARGE_TYPE_CODE		= p_Header_Adj_rec.charge_type_code
    ,	  CHARGE_SUBTYPE_CODE	= p_Header_Adj_rec.charge_subtype_code
    ,       LIST_LINE_NO          = p_Header_Adj_rec.list_line_no
    ,       SOURCE_SYSTEM_CODE     = p_Header_Adj_rec.source_system_code
    ,       BENEFIT_QTY           = p_Header_Adj_rec.benefit_qty
    ,       BENEFIT_UOM_CODE      = p_Header_Adj_rec.benefit_uom_code
    ,       PRINT_ON_INVOICE_FLAG = p_Header_Adj_rec.print_on_invoice_flag
    ,       EXPIRATION_DATE       = p_Header_Adj_rec.expiration_date
    ,       REBATE_TRANSACTION_TYPE_CODE  = p_Header_Adj_rec.rebate_transaction_type_code
    ,       REBATE_TRANSACTION_REFERENCE  = p_Header_Adj_rec.rebate_transaction_reference
    ,       REBATE_PAYMENT_SYSTEM_CODE    = p_Header_Adj_rec.rebate_payment_system_code
    ,       REDEEMED_DATE         = p_Header_Adj_rec.redeemed_date
    ,       REDEEMED_FLAG         = p_Header_Adj_rec.redeemed_flag
    ,       ACCRUAL_FLAG          = p_Header_Adj_rec.accrual_flag
    ,       RANGE_BREAK_QUANTITY  = p_Header_Adj_rec.range_break_quantity
    ,       ACCRUAL_CONVERSION_RATE = p_Header_Adj_rec.accrual_conversion_rate
    ,       PRICING_GROUP_SEQUENCE  = p_Header_Adj_rec.pricing_group_sequence
    ,       MODIFIER_LEVEL_CODE     = p_Header_Adj_rec.modifier_level_code
    ,       PRICE_BREAK_TYPE_CODE   = p_Header_Adj_rec.price_break_type_code
    ,       SUBSTITUTION_ATTRIBUTE  = p_Header_Adj_rec.substitution_attribute
    ,       PRORATION_TYPE_CODE     = p_Header_Adj_rec.proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG   = p_Header_Adj_rec.credit_or_charge_flag
    ,       INCLUDE_ON_RETURNS_FLAG = p_Header_Adj_rec.include_on_returns_flag
    ,       AC_CONTEXT              = p_Header_Adj_rec.ac_context
    ,       AC_ATTRIBUTE1           = p_Header_Adj_rec.ac_attribute1
    ,       AC_ATTRIBUTE2           = p_Header_Adj_rec.ac_attribute2
    ,       AC_ATTRIBUTE3           = p_Header_Adj_rec.ac_attribute3
    ,       AC_ATTRIBUTE4           = p_Header_Adj_rec.ac_attribute4
    ,       AC_ATTRIBUTE5           = p_Header_Adj_rec.ac_attribute5
    ,       AC_ATTRIBUTE6           = p_Header_Adj_rec.ac_attribute6
    ,       AC_ATTRIBUTE7           = p_Header_Adj_rec.ac_attribute7
    ,       AC_ATTRIBUTE8           = p_Header_Adj_rec.ac_attribute8
    ,       AC_ATTRIBUTE9           = p_Header_Adj_rec.ac_attribute9
    ,       AC_ATTRIBUTE10          = p_Header_Adj_rec.ac_attribute10
    ,       AC_ATTRIBUTE11          = p_Header_Adj_rec.ac_attribute11
    ,       AC_ATTRIBUTE12          = p_Header_Adj_rec.ac_attribute12
    ,       AC_ATTRIBUTE13          = p_Header_Adj_rec.ac_attribute13
    ,       AC_ATTRIBUTE14          = p_Header_Adj_rec.ac_attribute14
    ,       AC_ATTRIBUTE15          = p_Header_Adj_rec.ac_attribute15
--uom begin
    ,       OPERAND_PER_PQTY         = p_Header_Adj_rec.operand_per_pqty
    ,       ADJUSTED_AMOUNT_PER_PQTY = p_Header_Adj_rec.adjusted_amount_per_pqty
--uom end
    ,       INVOICED_AMOUNT         = p_Header_Adj_rec.invoiced_amount
    ,	  LOCK_CONTROL			 = l_lock_control
    WHERE   PRICE_ADJUSTMENT_ID    = p_Header_Adj_rec.price_adjustment_id
    ;

    p_Header_Adj_rec.lock_control := l_lock_control;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.UPDATE_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Header_Adj_rec                IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
)
IS
l_lock_control		NUMBER := 1;
--added for notification framework
l_index                NUMBER;
l_return_status        VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.INSERT_ROW' , 1 ) ;
    END IF;

    INSERT  INTO OE_PRICE_ADJUSTMENTS
    (       PRICE_ADJUSTMENT_ID
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       HEADER_ID
    ,       DISCOUNT_ID
    ,       DISCOUNT_LINE_ID
    ,       AUTOMATIC_FLAG
    ,       PERCENT
    ,       LINE_ID
    ,       CONTEXT
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ORIG_SYS_DISCOUNT_REF
    ,	  LIST_HEADER_ID
    ,	  LIST_LINE_ID
    ,	  LIST_LINE_TYPE_CODE
    ,	  MODIFIER_MECHANISM_TYPE_CODE
    ,	  MODIFIED_FROM
    ,	  MODIFIED_TO
    ,	  UPDATED_FLAG
    ,	  UPDATE_ALLOWED
    ,	  APPLIED_FLAG
    ,	  CHANGE_REASON_CODE
    ,	  CHANGE_REASON_TEXT
    ,	  operand
    ,	  arithmetic_operator
    ,	  COST_ID
    ,	  TAX_CODE
    ,	  TAX_EXEMPT_FLAG
    ,	  TAX_EXEMPT_NUMBER
    ,	  TAX_EXEMPT_REASON_CODE
    ,	  PARENT_ADJUSTMENT_ID
    ,	  INVOICED_FLAG
    ,	  ESTIMATED_FLAG
    ,	  INC_IN_SALES_PERFORMANCE
    ,	  SPLIT_ACTION_CODE
    ,	  ADJUSTED_AMOUNT
    ,	  PRICING_PHASE_ID
    ,	  CHARGE_TYPE_CODE
    ,	  CHARGE_SUBTYPE_CODE
    ,     list_line_no
    ,     source_system_code
    ,     benefit_qty
    ,     benefit_uom_code
    ,     print_on_invoice_flag
    ,     expiration_date
    ,     rebate_transaction_type_code
    ,     rebate_transaction_reference
    ,     rebate_payment_system_code
    ,     redeemed_date
    ,     redeemed_flag
    ,     accrual_flag
    ,     range_break_quantity
    ,     accrual_conversion_rate
    ,     pricing_group_sequence
    ,     modifier_level_code
    ,     price_break_type_code
    ,     substitution_attribute
    ,     proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       AC_CONTEXT
    ,       AC_ATTRIBUTE1
    ,       AC_ATTRIBUTE2
    ,       AC_ATTRIBUTE3
    ,       AC_ATTRIBUTE4
    ,       AC_ATTRIBUTE5
    ,       AC_ATTRIBUTE6
    ,       AC_ATTRIBUTE7
    ,       AC_ATTRIBUTE8
    ,       AC_ATTRIBUTE9
    ,       AC_ATTRIBUTE10
    ,       AC_ATTRIBUTE11
    ,       AC_ATTRIBUTE12
    ,       AC_ATTRIBUTE13
    ,       AC_ATTRIBUTE14
    ,       AC_ATTRIBUTE15
 --uom begin
    ,       OPERAND_PER_PQTY
    ,       ADJUSTED_AMOUNT_PER_PQTY
    --uom end
    ,       INVOICED_AMOUNT
    ,	  lock_control
    )
    VALUES
    (       p_Header_Adj_rec.price_adjustment_id
    ,       p_Header_Adj_rec.creation_date
    ,       p_Header_Adj_rec.created_by
    ,       p_Header_Adj_rec.last_update_date
    ,       p_Header_Adj_rec.last_updated_by
    ,       p_Header_Adj_rec.last_update_login
    ,       p_Header_Adj_rec.program_application_id
    ,       p_Header_Adj_rec.program_id
    ,       p_Header_Adj_rec.program_update_date
    ,       p_Header_Adj_rec.request_id
    ,       p_Header_Adj_rec.header_id
    ,       p_Header_Adj_rec.discount_id
    ,       p_Header_Adj_rec.discount_line_id
    ,       p_Header_Adj_rec.automatic_flag
    ,       p_Header_Adj_rec.percent
    ,       p_Header_Adj_rec.line_id
    ,       p_Header_Adj_rec.context
    ,       p_Header_Adj_rec.attribute1
    ,       p_Header_Adj_rec.attribute2
    ,       p_Header_Adj_rec.attribute3
    ,       p_Header_Adj_rec.attribute4
    ,       p_Header_Adj_rec.attribute5
    ,       p_Header_Adj_rec.attribute6
    ,       p_Header_Adj_rec.attribute7
    ,       p_Header_Adj_rec.attribute8
    ,       p_Header_Adj_rec.attribute9
    ,       p_Header_Adj_rec.attribute10
    ,       p_Header_Adj_rec.attribute11
    ,       p_Header_Adj_rec.attribute12
    ,       p_Header_Adj_rec.attribute13
    ,       p_Header_Adj_rec.attribute14
    ,       p_Header_Adj_rec.attribute15
    ,       p_Header_Adj_rec.orig_sys_discount_ref
    ,	  p_Header_Adj_rec.list_header_id
    ,	  p_Header_Adj_rec.list_line_id
    ,	  p_Header_Adj_rec.list_line_type_code
    ,	  p_Header_Adj_rec.modifier_mechanism_type_code
    ,	  p_Header_Adj_rec.modified_from
    ,	  p_Header_Adj_rec.modified_to
    ,	  p_Header_Adj_rec.updated_flag
    ,	  p_Header_Adj_rec.update_allowed
    ,	  p_Header_Adj_rec.applied_flag
    ,	  p_Header_Adj_rec.change_reason_code
    ,	  p_Header_Adj_rec.change_reason_text
    ,	  p_Header_Adj_rec.operand
    ,	  p_Header_Adj_rec.arithmetic_operator
    ,	  p_Header_Adj_rec.COST_ID
    ,	  p_Header_Adj_rec.TAX_CODE
    ,	  p_Header_Adj_rec.TAX_EXEMPT_FLAG
    ,	  p_Header_Adj_rec.TAX_EXEMPT_NUMBER
    ,	  p_Header_Adj_rec.TAX_EXEMPT_REASON_CODE
    ,	  p_Header_Adj_rec.PARENT_ADJUSTMENT_ID
    ,	  p_Header_Adj_rec.INVOICED_FLAG
    ,	  p_Header_Adj_rec.ESTIMATED_FLAG
    ,	  p_Header_Adj_rec.INC_IN_SALES_PERFORMANCE
    ,	  p_Header_Adj_rec.SPLIT_ACTION_CODE
    ,	  p_Header_Adj_rec.adjusted_amount
    ,	  p_Header_Adj_rec.pricing_phase_id
    ,	  p_Header_Adj_rec.charge_type_code
    ,	  p_Header_Adj_rec.charge_subtype_code
    ,     p_Header_Adj_rec.list_line_no
    ,     p_Header_Adj_rec.source_system_code
    ,     p_Header_Adj_rec.benefit_qty
    ,     p_Header_Adj_rec.benefit_uom_code
    ,     p_Header_Adj_rec.print_on_invoice_flag
    ,     p_Header_Adj_rec.expiration_date
    ,     p_Header_Adj_rec.rebate_transaction_type_code
    ,     p_Header_Adj_rec.rebate_transaction_reference
    ,     p_Header_Adj_rec.rebate_payment_system_code
    ,     p_Header_Adj_rec.redeemed_date
    ,     p_Header_Adj_rec.redeemed_flag
    ,     p_Header_Adj_rec.accrual_flag
    ,     p_Header_Adj_rec.range_break_quantity
    ,     p_Header_Adj_rec.accrual_conversion_rate
    ,     p_Header_Adj_rec.pricing_group_sequence
    ,     p_Header_Adj_rec.modifier_level_code
    ,     p_Header_Adj_rec.price_break_type_code
    ,     p_Header_Adj_rec.substitution_attribute
    ,     p_Header_Adj_rec.proration_type_code
    ,       p_Header_Adj_rec.credit_or_charge_flag
    ,       p_Header_Adj_rec.include_on_returns_flag
    ,       p_Header_Adj_rec.ac_context
    ,       p_Header_Adj_rec.ac_attribute1
    ,       p_Header_Adj_rec.ac_attribute2
    ,       p_Header_Adj_rec.ac_attribute3
    ,       p_Header_Adj_rec.ac_attribute4
    ,       p_Header_Adj_rec.ac_attribute5
    ,       p_Header_Adj_rec.ac_attribute6
    ,       p_Header_Adj_rec.ac_attribute7
    ,       p_Header_Adj_rec.ac_attribute8
    ,       p_Header_Adj_rec.ac_attribute9
    ,       p_Header_Adj_rec.ac_attribute10
    ,       p_Header_Adj_rec.ac_attribute11
    ,       p_Header_Adj_rec.ac_attribute12
    ,       p_Header_Adj_rec.ac_attribute13
    ,       p_Header_Adj_rec.ac_attribute14
    ,       p_Header_Adj_rec.ac_attribute15
    --uom begin
    ,       p_Header_Adj_rec.OPERAND_PER_PQTY
    ,         p_Header_Adj_rec.ADJUSTED_AMOUNT_PER_PQTY
    --uom end
    ,       p_Header_Adj_rec.INVOICED_AMOUNT
    ,	  l_lock_control
    );

    p_header_Adj_rec.lock_control := l_lock_control;

    -- calling notification framework to update global picture
  -- check code release level first. Notification framework is at Pack H level
   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
       OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_old_hdr_adj_rec => NULL,
                    p_Hdr_adj_rec =>p_header_adj_rec,
                    p_hdr_adj_id => p_header_adj_rec.price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_HEADER_ADJ_UTIL.INSERT_ROW IS: ' || L_RETURN_STATUS ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURNED INDEX IS: ' || L_INDEX , 1 ) ;
      END IF;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.INSERT_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_HEADER_ADJ_UTIL.INSERT_ROW' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.INSERT_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF; /* code_release_level*/
  -- notification framework end

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.INSERT_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

-- Procedure Delete_Header_Charges

Procedure Delete_Header_Charges
(
  p_header_id     IN Number
)
IS
l_return_status         VARCHAR2(30);

begin


    DELETE  FROM OE_PRICE_ADJUSTMENTS
    WHERE   HEADER_ID = p_header_id
      AND   LINE_ID  IS NULL
      AND   LIST_LINE_TYPE_CODE = 'FREIGHT_CHARGE';


EXCEPTION

WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Delete_Row'
                );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Header_Charges;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_price_adjustment_id           IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
)
IS
l_return_status		VARCHAR2(30);
CURSOR price_adj IS
	SELECT price_adjustment_id
	FROM OE_PRICE_ADJUSTMENTS
	WHERE   HEADER_ID = p_header_id;

 -- added for notification framework
l_new_header_adj_rec     OE_Order_PUB.Header_Adj_Rec_Type;
l_index                  NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.DELETE_ROW' , 1 ) ;
    END IF;

  IF p_header_id <> FND_API.G_MISS_NUM
  THEN
    FOR l_adj IN price_adj LOOP

   --added for notification framework
   --check code release level first. Notification framework is at Pack H level
     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'JFC: IN DELETE ROW , PRICE_ADJUSTMENT_ID= '|| L_ADJ.PRICE_ADJUSTMENT_ID ) ;
        END IF;

     /* Set the operation on the record so that globals are updated as well */
      l_new_header_adj_rec.operation := OE_GLOBALS.G_OPR_DELETE;
      l_new_header_adj_rec.price_adjustment_id := l_adj.price_adjustment_id;

      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Hdr_adj_rec =>l_new_header_adj_rec,
                    p_hdr_adj_id => l_adj.price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_HEADER_ADJ_UTIL.DELETE_ROW IS: ' || L_RETURN_STATUS ) ;
     END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_HEADER_ADJ_UTIL.DELETE_ROW' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF; /*code_release_level*/
   -- notification framework end


      OE_Delayed_Requests_Pvt.Delete_Reqs_for_deleted_entity(
        p_entity_code  => OE_GLOBALS.G_ENTITY_HEADER_ADJ,
        p_entity_id     => l_adj.price_adjustment_id,
        x_return_status => l_return_status
        );

	  OE_Line_Price_Aattr_Util.delete_row(
			p_price_adjustment_id=>l_adj.price_adjustment_id);

	  OE_Line_Adj_Assocs_Util.delete_row(
			p_price_adjustment_id=>l_adj.price_adjustment_id);
    END LOOP;
    /* Start Audit Trail */
    DELETE  FROM OE_PRICE_ADJS_HISTORY
    WHERE   HEADER_ID = p_header_id;
    /* End Audit Trail */

    DELETE  FROM OE_PRICE_ADJUSTMENTS
    WHERE   HEADER_ID = p_header_id;
  ELSE

   --added for notification framework
   --check code release level first. Notification framework is at Pack H level
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'JFC:IN DELETE ROW , HEADER_ID IS G_MISS_NUM , PRICE_ADJUSTMENT_ID= '|| P_PRICE_ADJUSTMENT_ID , 1 ) ;
       END IF;

      /* Set the operation on the record so that globals are updated as well */
       l_new_header_adj_rec.operation := OE_GLOBALS.G_OPR_DELETE;
       l_new_header_adj_rec.price_adjustment_id := p_price_adjustment_id;
       OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Hdr_adj_rec =>l_new_header_adj_rec,
                    p_hdr_adj_id => p_price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_HEADER_ADJ_UTIL.DELETE_ROW IS: ' || L_RETURN_STATUS ) ;
       END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.DELETE_ROW' , 1 ) ;
            END IF;
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_HEADER_ADJ_UTIL.DELETE_ROW' ) ;
            END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
	  RAISE FND_API.G_EXC_ERROR;
        END IF;
   END IF; /*code_release_level*/
   -- notification framework end

      OE_Delayed_Requests_Pvt.Delete_Reqs_for_deleted_entity
        (p_entity_code  => OE_GLOBALS.G_ENTITY_HEADER_ADJ,
        p_entity_id     => p_price_adjustment_id,
        x_return_status => l_return_status
        );

	  OE_Line_Price_Aattr_Util.delete_row(
			p_price_adjustment_id=>p_price_adjustment_id);

	  OE_Line_Adj_Assocs_Util.delete_row(
			p_price_adjustment_id=>p_price_adjustment_id);

    /* Start Audit Trail (modified for 11.5.10) */
    DELETE  FROM OE_PRICE_ADJS_HISTORY
    WHERE   PRICE_ADJUSTMENT_ID = p_price_adjustment_id
    AND     NVL(AUDIT_FLAG, 'Y') = 'Y'
    AND     NVL(VERSION_FLAG, 'N') = 'N'
    AND     NVL(PHASE_CHANGE_FLAG, 'N') = 'N';

    UPDATE  OE_PRICE_ADJS_HISTORY
    SET     AUDIT_FLAG = 'N'
    WHERE   PRICE_ADJUSTMENT_ID = p_price_adjustment_id
    AND     NVL(AUDIT_FLAG, 'Y') = 'Y'
    AND    (NVL(VERSION_FLAG, 'N') = 'Y'
    OR      NVL(PHASE_CHANGE_FLAG, 'N') = 'Y');
    /* End Audit Trail */

    DELETE  FROM OE_PRICE_ADJUSTMENTS
    WHERE   PRICE_ADJUSTMENT_ID = p_price_adjustment_id
    ;
  END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.DELETE_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Procedure Query_Row


PROCEDURE Query_Row
(   p_price_adjustment_id     IN  NUMBER
,   x_Header_Adj_Rec 		IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
)
IS
  l_Header_Adj_Tbl			OE_Order_PUB.Header_Adj_Tbl_Type;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.QUERY_ROW' , 1 ) ;
    END IF;

    Query_Rows
        (   p_price_adjustment_id         => p_price_adjustment_id
	   ,   x_Header_Adj_Tbl			  => l_Header_Adj_Tbl
	   );
    x_Header_Adj_Rec := l_Header_Adj_Tbl(1);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.QUERY_ROW' , 1 ) ;
    END IF;

END Query_Row;

--  Procedure Query_Rows

PROCEDURE Query_Rows
(   p_price_adjustment_id     IN  NUMBER :=
                                  FND_API.G_MISS_NUM
,   p_header_id               IN  NUMBER :=
                                  FND_API.G_MISS_NUM
,   x_Header_Adj_Tbl		IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
)
IS
l_count			NUMBER;

CURSOR l_Header_Adj_csr_p IS
    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTOMATIC_FLAG
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DISCOUNT_ID
    ,       DISCOUNT_LINE_ID
    ,       HEADER_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       PRICE_ADJUSTMENT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,	  LIST_HEADER_ID
    ,	  LIST_LINE_ID
    ,	  LIST_LINE_TYPE_CODE
    ,	  MODIFIER_MECHANISM_TYPE_CODE
    ,	  MODIFIED_FROM
    ,	  MODIFIED_TO
    ,	  UPDATED_FLAG
    ,	  UPDATE_ALLOWED
    ,	  APPLIED_FLAG
    ,	  CHANGE_REASON_CODE
    ,	  CHANGE_REASON_TEXT
    ,	  operand
    ,       arithmetic_operator
    ,	  COST_ID
    ,	  TAX_CODE
    ,	  TAX_EXEMPT_FLAG
    ,	  TAX_EXEMPT_NUMBER
    ,	  TAX_EXEMPT_REASON_CODE
    ,	  PARENT_ADJUSTMENT_ID
    ,	  INVOICED_FLAG
    ,	  ESTIMATED_FLAG
    ,	  INC_IN_SALES_PERFORMANCE
    ,	  SPLIT_ACTION_CODE
    ,	  ADJUSTED_AMOUNT
    ,	  PRICING_PHASE_ID
    ,	  CHARGE_TYPE_CODE
    ,	  CHARGE_SUBTYPE_CODE
    ,     list_line_no
    ,     source_system_code
    ,     benefit_qty
    ,     benefit_uom_code
    ,     print_on_invoice_flag
    ,     expiration_date
    ,     rebate_transaction_type_code
    ,     rebate_transaction_reference
    ,     rebate_payment_system_code
    ,     redeemed_date
    ,     redeemed_flag
    ,     accrual_flag
    ,     range_break_quantity
    ,     accrual_conversion_rate
    ,     pricing_group_sequence
    ,     modifier_level_code
    ,     price_break_type_code
    ,     substitution_attribute
    ,     proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       AC_ATTRIBUTE1
    ,       AC_ATTRIBUTE10
    ,       AC_ATTRIBUTE11
    ,       AC_ATTRIBUTE12
    ,       AC_ATTRIBUTE13
    ,       AC_ATTRIBUTE14
    ,       AC_ATTRIBUTE15
    ,       AC_ATTRIBUTE2
    ,       AC_ATTRIBUTE3
    ,       AC_ATTRIBUTE4
    ,       AC_ATTRIBUTE5
    ,       AC_ATTRIBUTE6
    ,       AC_ATTRIBUTE7
    ,       AC_ATTRIBUTE8
    ,       AC_ATTRIBUTE9
    ,       AC_CONTEXT
    ,       orig_sys_discount_ref
 --uom begin
    ,       OPERAND_PER_PQTY
    ,         ADJUSTED_AMOUNT_PER_PQTY
    ,       INVOICED_AMOUNT
    --uom end
    ,	  LOCK_CONTROL
    FROM    OE_PRICE_ADJUSTMENTS
    WHERE   PRICE_ADJUSTMENT_ID = p_price_adjustment_id;

CURSOR l_Header_Adj_csr_h IS
    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTOMATIC_FLAG
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DISCOUNT_ID
    ,       DISCOUNT_LINE_ID
    ,       HEADER_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       PRICE_ADJUSTMENT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,	  LIST_HEADER_ID
    ,	  LIST_LINE_ID
    ,	  LIST_LINE_TYPE_CODE
    ,	  MODIFIER_MECHANISM_TYPE_CODE
    ,	  MODIFIED_FROM
    ,	  MODIFIED_TO
    ,	  UPDATED_FLAG
    ,	  UPDATE_ALLOWED
    ,	  APPLIED_FLAG
    ,	  CHANGE_REASON_CODE
    ,	  CHANGE_REASON_TEXT
    ,	  operand
    ,       arithmetic_operator
    ,	  COST_ID
    ,	  TAX_CODE
    ,	  TAX_EXEMPT_FLAG
    ,	  TAX_EXEMPT_NUMBER
    ,	  TAX_EXEMPT_REASON_CODE
    ,	  PARENT_ADJUSTMENT_ID
    ,	  INVOICED_FLAG
    ,	  ESTIMATED_FLAG
    ,	  INC_IN_SALES_PERFORMANCE
    ,	  SPLIT_ACTION_CODE
    ,	  ADJUSTED_AMOUNT
    ,	  PRICING_PHASE_ID
    ,	  CHARGE_TYPE_CODE
    ,	  CHARGE_SUBTYPE_CODE
    ,     list_line_no
    ,     source_system_code
    ,     benefit_qty
    ,     benefit_uom_code
    ,     print_on_invoice_flag
    ,     expiration_date
    ,     rebate_transaction_type_code
    ,     rebate_transaction_reference
    ,     rebate_payment_system_code
    ,     redeemed_date
    ,     redeemed_flag
    ,     accrual_flag
    ,     range_break_quantity
    ,     accrual_conversion_rate
    ,     pricing_group_sequence
    ,     modifier_level_code
    ,     price_break_type_code
    ,     substitution_attribute
    ,     proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       AC_ATTRIBUTE1
    ,       AC_ATTRIBUTE10
    ,       AC_ATTRIBUTE11
    ,       AC_ATTRIBUTE12
    ,       AC_ATTRIBUTE13
    ,       AC_ATTRIBUTE14
    ,       AC_ATTRIBUTE15
    ,       AC_ATTRIBUTE2
    ,       AC_ATTRIBUTE3
    ,       AC_ATTRIBUTE4
    ,       AC_ATTRIBUTE5
    ,       AC_ATTRIBUTE6
    ,       AC_ATTRIBUTE7
    ,       AC_ATTRIBUTE8
    ,       AC_ATTRIBUTE9
    ,       AC_CONTEXT
    ,       orig_sys_discount_ref
 --uom begin
    ,       OPERAND_PER_PQTY
    ,         ADJUSTED_AMOUNT_PER_PQTY
    ,       INVOICED_AMOUNT
    --uom end
    ,	  LOCK_CONTROL
    FROM    OE_PRICE_ADJUSTMENTS
    WHERE   HEADER_ID = p_header_id AND LINE_ID IS NULL;

  l_implicit_rec l_header_adj_csr_p%ROWTYPE;
  l_entity NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF
    (p_price_adjustment_id IS NOT NULL
     AND
     p_price_adjustment_id <> FND_API.G_MISS_NUM)
    AND
    (p_header_id IS NOT NULL
     AND
     p_header_id <> FND_API.G_MISS_NUM)
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: price_adjustment_id = '|| p_price_adjustment_id || ', header_id = '|| p_header_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    IF nvl(p_price_adjustment_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	   l_entity := 1;
           OPEN l_header_adj_csr_p;
    ELSIF nvl(p_header_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	   l_entity := 2;
           OPEN l_header_adj_csr_h;
    END IF;

    --  Loop over fetched records
    l_count := 1;
    LOOP
        IF l_entity = 1 THEN
             FETCH l_header_adj_csr_p INTO l_implicit_rec;
             EXIT WHEN l_header_adj_csr_p%NOTFOUND;
        ELSIF l_entity = 2 THEN
             FETCH l_header_adj_csr_h INTO l_implicit_rec;
             EXIT WHEN l_header_adj_csr_h%NOTFOUND;
        ELSE
          EXIT;
        END IF;

        x_Header_Adj_tbl(l_count).attribute1    := l_implicit_rec.ATTRIBUTE1;
        x_Header_Adj_tbl(l_count).attribute10   := l_implicit_rec.ATTRIBUTE10;
        x_Header_Adj_tbl(l_count).attribute11   := l_implicit_rec.ATTRIBUTE11;
        x_Header_Adj_tbl(l_count).attribute12   := l_implicit_rec.ATTRIBUTE12;
        x_Header_Adj_tbl(l_count).attribute13   := l_implicit_rec.ATTRIBUTE13;
        x_Header_Adj_tbl(l_count).attribute14   := l_implicit_rec.ATTRIBUTE14;
        x_Header_Adj_tbl(l_count).attribute15   := l_implicit_rec.ATTRIBUTE15;
        x_Header_Adj_tbl(l_count).attribute2    := l_implicit_rec.ATTRIBUTE2;
        x_Header_Adj_tbl(l_count).attribute3    := l_implicit_rec.ATTRIBUTE3;
        x_Header_Adj_tbl(l_count).attribute4    := l_implicit_rec.ATTRIBUTE4;
        x_Header_Adj_tbl(l_count).attribute5    := l_implicit_rec.ATTRIBUTE5;
        x_Header_Adj_tbl(l_count).attribute6    := l_implicit_rec.ATTRIBUTE6;
        x_Header_Adj_tbl(l_count).attribute7    := l_implicit_rec.ATTRIBUTE7;
        x_Header_Adj_tbl(l_count).attribute8    := l_implicit_rec.ATTRIBUTE8;
        x_Header_Adj_tbl(l_count).attribute9    := l_implicit_rec.ATTRIBUTE9;
        x_Header_Adj_tbl(l_count).automatic_flag := l_implicit_rec.AUTOMATIC_FLAG;
        x_Header_Adj_tbl(l_count).context       := l_implicit_rec.CONTEXT;
        x_Header_Adj_tbl(l_count).created_by    := l_implicit_rec.CREATED_BY;
        x_Header_Adj_tbl(l_count).creation_date := l_implicit_rec.CREATION_DATE;
        x_Header_Adj_tbl(l_count).discount_id   := l_implicit_rec.DISCOUNT_ID;
        x_Header_Adj_tbl(l_count).discount_line_id := l_implicit_rec.DISCOUNT_LINE_ID;
        x_Header_Adj_tbl(l_count).header_id     := l_implicit_rec.HEADER_ID;
        x_Header_Adj_tbl(l_count).last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        x_Header_Adj_tbl(l_count).last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        x_Header_Adj_tbl(l_count).last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        x_Header_Adj_tbl(l_count).line_id       := l_implicit_rec.LINE_ID;
        x_Header_Adj_tbl(l_count).percent       := l_implicit_rec.PERCENT;
        x_Header_Adj_tbl(l_count).price_adjustment_id := l_implicit_rec.PRICE_ADJUSTMENT_ID;
        x_Header_Adj_tbl(l_count).program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        x_Header_Adj_tbl(l_count).program_id    := l_implicit_rec.PROGRAM_ID;
        x_Header_Adj_tbl(l_count).program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        x_Header_Adj_tbl(l_count).adjusted_amount   := l_implicit_rec.adjusted_amount;
        x_Header_Adj_tbl(l_count).pricing_phase_id  := l_implicit_rec.pricing_phase_id;
        x_Header_Adj_tbl(l_count).list_header_id    := l_implicit_rec.list_header_id;
        x_Header_Adj_tbl(l_count).list_line_id    := l_implicit_rec.list_line_id;
        x_Header_Adj_tbl(l_count).list_line_type_code    := l_implicit_rec.list_line_type_code;
        x_Header_Adj_tbl(l_count).modifier_mechanism_type_code :=
					 l_implicit_rec.modifier_mechanism_type_code;
     x_Header_Adj_tbl(l_count).modified_from    := l_implicit_rec.modified_from;
     x_Header_Adj_tbl(l_count).modified_to    := l_implicit_rec.modified_to;
     x_Header_Adj_tbl(l_count).updated_flag    := l_implicit_rec.updated_flag;
     x_Header_Adj_tbl(l_count).update_allowed    := l_implicit_rec.update_allowed;
     x_Header_Adj_tbl(l_count).applied_flag    := l_implicit_rec.applied_flag;
     x_Header_Adj_tbl(l_count).change_reason_code := l_implicit_rec.change_reason_code;
     x_Header_Adj_tbl(l_count).change_reason_text  := l_implicit_rec.change_reason_text;
     x_Header_Adj_tbl(l_count).operand  := l_implicit_rec.operand;
     x_Header_Adj_tbl(l_count).arithmetic_operator  :=
							l_implicit_rec.arithmetic_operator;

        x_Header_Adj_tbl(l_count).request_id    := l_implicit_rec.REQUEST_ID;

     x_Header_Adj_tbl(l_count).cost_id := l_implicit_rec.cost_id;
     x_Header_Adj_tbl(l_count).tax_code := l_implicit_rec.tax_code;
     x_Header_Adj_tbl(l_count).tax_exempt_flag := l_implicit_rec.tax_exempt_flag;
     x_Header_Adj_tbl(l_count).tax_exempt_number := l_implicit_rec.tax_exempt_number;
     x_Header_Adj_tbl(l_count).tax_exempt_reason_code := l_implicit_rec.tax_exempt_reason_code;
     x_Header_Adj_tbl(l_count).parent_adjustment_id := l_implicit_rec.parent_adjustment_id;
     x_Header_Adj_tbl(l_count).invoiced_flag := l_implicit_rec.invoiced_flag;
     x_Header_Adj_tbl(l_count).estimated_flag := l_implicit_rec.estimated_flag;
     x_Header_Adj_tbl(l_count).inc_in_sales_performance := l_implicit_rec.inc_in_sales_performance;
     x_Header_Adj_tbl(l_count).split_action_code := l_implicit_rec.split_action_code;
     x_Header_Adj_tbl(l_count).charge_type_code := l_implicit_rec.charge_type_code;
     x_Header_Adj_tbl(l_count).charge_subtype_code := l_implicit_rec.charge_subtype_code;
     x_Header_Adj_tbl(l_count).list_line_no := l_implicit_rec.list_line_no;
     x_Header_Adj_tbl(l_count).source_system_code := l_implicit_rec.source_system_code;
     x_Header_Adj_tbl(l_count).benefit_qty := l_implicit_rec.benefit_qty;
     x_Header_Adj_tbl(l_count).benefit_uom_code := l_implicit_rec.benefit_uom_code;
     x_Header_Adj_tbl(l_count).print_on_invoice_flag := l_implicit_rec.print_on_invoice_flag;
     x_Header_Adj_tbl(l_count).expiration_date := l_implicit_rec.expiration_date;
     x_Header_Adj_tbl(l_count).rebate_transaction_type_code := l_implicit_rec.rebate_transaction_type_code;
     x_Header_Adj_tbl(l_count).rebate_transaction_reference := l_implicit_rec.rebate_transaction_reference;
     x_Header_Adj_tbl(l_count).rebate_payment_system_code := l_implicit_rec.rebate_payment_system_code;
     x_Header_Adj_tbl(l_count).redeemed_date := l_implicit_rec.redeemed_date;
     x_Header_Adj_tbl(l_count).redeemed_flag := l_implicit_rec.redeemed_flag;
     x_Header_Adj_tbl(l_count).accrual_flag := l_implicit_rec.accrual_flag;
     x_Header_Adj_tbl(l_count).range_break_quantity := l_implicit_rec.range_break_quantity;
     x_Header_Adj_tbl(l_count).accrual_conversion_rate := l_implicit_rec.accrual_conversion_rate;
     x_Header_Adj_tbl(l_count).pricing_group_sequence := l_implicit_rec.pricing_group_sequence;
     x_Header_Adj_tbl(l_count).modifier_level_code := l_implicit_rec.modifier_level_code;
     x_Header_Adj_tbl(l_count).price_break_type_code := l_implicit_rec.price_break_type_code;
     x_Header_Adj_tbl(l_count).substitution_attribute := l_implicit_rec.substitution_attribute;
     x_Header_Adj_tbl(l_count).proration_type_code := l_implicit_rec.proration_type_code;
     x_Header_Adj_tbl(l_count).credit_or_charge_flag := l_implicit_rec.credit_or_charge_flag;
     x_Header_Adj_tbl(l_count).include_on_returns_flag := l_implicit_rec.include_on_returns_flag;
        x_Header_Adj_tbl(l_count).ac_attribute1    := l_implicit_rec.AC_ATTRIBUTE1;
        x_Header_Adj_tbl(l_count).ac_attribute10   := l_implicit_rec.AC_ATTRIBUTE10;
        x_Header_Adj_tbl(l_count).ac_attribute11   := l_implicit_rec.AC_ATTRIBUTE11;
        x_Header_Adj_tbl(l_count).ac_attribute12   := l_implicit_rec.AC_ATTRIBUTE12;
        x_Header_Adj_tbl(l_count).ac_attribute13   := l_implicit_rec.AC_ATTRIBUTE13;
        x_Header_Adj_tbl(l_count).ac_attribute14   := l_implicit_rec.AC_ATTRIBUTE14;
        x_Header_Adj_tbl(l_count).ac_attribute15   := l_implicit_rec.AC_ATTRIBUTE15;
        x_Header_Adj_tbl(l_count).ac_attribute2    := l_implicit_rec.AC_ATTRIBUTE2;
        x_Header_Adj_tbl(l_count).ac_attribute3    := l_implicit_rec.AC_ATTRIBUTE3;
        x_Header_Adj_tbl(l_count).ac_attribute4    := l_implicit_rec.AC_ATTRIBUTE4;
        x_Header_Adj_tbl(l_count).ac_attribute5    := l_implicit_rec.AC_ATTRIBUTE5;
        x_Header_Adj_tbl(l_count).ac_attribute6    := l_implicit_rec.AC_ATTRIBUTE6;
        x_Header_Adj_tbl(l_count).ac_attribute7    := l_implicit_rec.AC_ATTRIBUTE7;
        x_Header_Adj_tbl(l_count).ac_attribute8    := l_implicit_rec.AC_ATTRIBUTE8;
        x_Header_Adj_tbl(l_count).ac_attribute9    := l_implicit_rec.AC_ATTRIBUTE9;
        x_Header_Adj_tbl(l_count).ac_context       := l_implicit_rec.AC_CONTEXT;
        x_Header_Adj_tbl(l_count).orig_sys_discount_ref  := l_implicit_rec.orig_sys_discount_ref;
        --uom begin
        x_Header_Adj_tbl(l_count).OPERAND_PER_PQTY      :=l_implicit_rec.operand_per_pqty;
     x_Header_Adj_tbl(l_count).ADJUSTED_AMOUNT_PER_PQTY :=l_implicit_rec.adjusted_amount_per_pqty;
        --uom end
        x_Header_Adj_tbl(l_count).invoiced_amount   := l_implicit_rec.invoiced_amount;
        x_Header_Adj_tbl(l_count).lock_control      := l_implicit_rec.LOCK_CONTROL;

        -- set values for non-DB fields
        x_Header_Adj_tbl(l_count).db_flag          := FND_API.G_TRUE;
        x_Header_Adj_tbl(l_count).operation        := FND_API.G_MISS_CHAR;
        x_Header_Adj_tbl(l_count).return_status    := FND_API.G_MISS_CHAR;

        l_count := l_count + 1;
    END LOOP;

    IF l_entity = 1 THEN
        CLOSE l_header_adj_csr_p;
    ELSIF l_entity = 2 THEN
        CLOSE l_header_adj_csr_h;
    END IF;

    --  PK sent and no rows found

    IF
    (p_price_adjustment_id IS NOT NULL
     AND
     p_price_adjustment_id <> FND_API.G_MISS_NUM)
    AND
    (x_Header_Adj_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

--  Procedure       lock_Row
--
-- lock by ID or value will be decided by, if lock_control is passed or not.
-- we are doing this so that other products, can still call lock_order API
-- which does not take only primary key and takes only entire records. However
-- if they do not set lokc_control on rec, we will still lock by ID
-- that way they do not need to query up the records before sending them in.
-- OM calls can directly fo to util.lock row, thus can send only PK.

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_Header_Adj_rec              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
--                                      := OE_Order_PUB.G_MISS_HEADER_ADJ_REC
,   p_price_adjustment_id           IN  NUMBER
                                        := FND_API.G_MISS_NUM
-- ,   x_Header_Adj_rec                OUT OE_Order_PUB.Header_Adj_Rec_Type
)
IS
l_price_adjustment_id         NUMBER;
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type;
l_lock_control				NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.LOCK_ROW' , 1 ) ;
    END IF;

    SAVEPOINT Lock_Row;

    l_lock_control := NULL;

    -- Retrieve the primary key.
    IF p_price_adjustment_id <> FND_API.G_MISS_NUM THEN
        l_price_adjustment_id := p_price_adjustment_id;
    ELSE
        l_price_adjustment_id := p_x_header_adj_rec.price_adjustment_id;
        l_lock_control 		:= p_x_header_adj_rec.lock_control;
    END IF;

    -- added for performance change
    SELECT price_adjustment_id
    INTO   l_price_adjustment_id
    FROM   oe_price_adjustments
    WHERE  price_adjustment_id = l_price_adjustment_id
    FOR UPDATE NOWAIT;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SELECTING FOR UPDATE.' , 1 ) ;
    END IF;

    OE_Header_Adj_Util.Query_Row
    (p_price_adjustment_id	=> l_price_adjustment_id
    ,x_Header_Adj_rec 		=> p_x_Header_Adj_rec
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'QUERIED LOCK_CONTROL: '|| P_X_HEADER_ADJ_REC.LOCK_CONTROL , 1 ) ;
    END IF;

    -- If lock_control is not passed(is null or missing), then return the locked record.


    IF l_lock_control is null OR
       l_lock_control = FND_API.G_MISS_NUM
    THEN

        --  Set return status
        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_header_adj_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

        -- return for lock by ID.
	RETURN;

    END IF;

    --  Row locked. If the whole record is passed, then
    --  Compare lock_control.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COMPARE ' , 1 ) ;
    END IF;

    IF      OE_GLOBALS.Equal(p_x_header_adj_rec.lock_control,
                             l_lock_control)
    THEN

        --  Row has not changed. Set out parameter.

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LOCKED ROW' , 1 ) ;
        END IF;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_header_adj_rec.return_status       := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ROW CHANGED BY OTHER USER' , 1 ) ;
        END IF;

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_header_adj_rec.return_status       := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            -- Release the lock
            ROLLBACK TO Lock_Row;

            fnd_message.set_name('ONT','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.LOCK_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Header_Adj_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Header_Adj_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_Header_Adj_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

PROCEDURE Lock_Rows
(   p_price_adjustment_id          IN  NUMBER
                                       := FND_API.G_MISS_NUM
,   p_header_id           		IN  NUMBER
                                       := FND_API.G_MISS_NUM
,   x_Header_Adj_tbl               OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

)
IS

  CURSOR lock_adj_hdr(p_header_id IN NUMBER) IS
  SELECT price_adjustment_id
  FROM   oe_price_adjustments
  WHERE  header_id = p_header_id
  FOR UPDATE NOWAIT;

l_price_adjustment_id         NUMBER;
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_lock_control				NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.LOCK_ROWS.' , 1 ) ;
  END IF;

  IF (p_price_adjustment_id IS NOT NULL AND
	 p_price_adjustment_id <> FND_API.G_MISS_NUM) AND
     (p_header_id IS NOT NULL AND
	 p_header_id <> FND_API.G_MISS_NUM)
  THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 OE_MSG_PUB.Add_Exc_Msg
	 (  G_PKG_NAME
	 ,  'Lock_Rows'
	 ,  'Keys are mutually exclusive: price_adjustment_id = ' ||
	    p_price_adjustment_id || ', header_id = ' || p_header_id );
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_price_adjustment_id <> FND_API.G_MISS_NUM THEN

    SELECT price_adjustment_id
    INTO   l_price_adjustment_id
    FROM   oe_price_adjustments
    WHERE  price_adjustment_id = p_price_adjustment_id
    FOR UPDATE NOWAIT;
  END IF;

  -- null header_id shouldn't be passed in unnecessarily if
  -- price_adjustment_id is passed in already.
  BEGIN
    IF p_header_id <> FND_API.G_MISS_NUM THEN
	 SAVEPOINT LOCK_ROWS;
	 OPEN lock_adj_hdr(p_header_id);

	 LOOP
	   FETCH lock_adj_hdr INTO l_price_adjustment_id;
	   EXIT WHEN lock_adj_hdr%NOTFOUND;
      END LOOP;
      CLOSE lock_adj_hdr;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
	 ROLLBACK TO LOCK_ROWS;

	 IF lock_adj_hdr%ISOPEN THEN
        CLOSE lock_adj_hdr;
      END IF;

	 RAISE;
  END;

  OE_Header_Adj_Util.Query_Rows
  ( p_price_adjustment_id	=> p_price_adjustment_id
  , p_header_id			=> p_header_id
  , x_Header_Adj_tbl		=> x_Header_Adj_tbl
  );

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status                := FND_API.G_RET_STS_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        fnd_message.set_name('ONT','OE_LOCK_ROW_DELETED');
        OE_MSG_PUB.Add;
      END IF;

     WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
       x_return_status                := FND_API.G_RET_STS_ERROR;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
         fnd_message.set_name('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
         OE_MSG_PUB.Add;
       END IF;

     WHEN OTHERS THEN
        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         OE_MSG_PUB.Add_Exc_Msg
         (   G_PKG_NAME
          ,   'Lock_Row'
         );
       END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.LOCK_ROWS.' , 1 ) ;
  END IF;

END Lock_Rows;

PROCEDURE Log_Adj_Requests
( x_return_status OUT NOCOPY VARCHAR2

, p_adj_rec		IN	OE_order_pub.Header_Adj_Rec_Type
, p_old_adj_rec		IN	OE_order_pub.Header_Adj_Rec_Type
, p_delete_flag		IN	BOOLEAN DEFAULT FALSE
  )  IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- if the adjustment_id changed or the percent changed
    -- or discount or discount_line has changed

    IF (  (p_adj_rec.price_adjustment_id <> p_old_adj_rec.price_adjustment_id
	   OR
	   p_old_adj_rec.price_adjustment_id IS NULL)
	OR
	  (p_adj_rec.percent <> p_old_adj_rec.percent
	   OR
	   p_old_adj_rec.percent IS NULL)
	OR
	  (p_adj_rec.discount_id <> p_old_adj_rec.discount_id
	   OR
	   p_old_adj_rec.discount_id IS NULL)
	OR
	  (p_adj_rec.discount_line_id <> p_old_adj_rec.discount_line_id
	   OR
	   p_old_adj_rec.discount_line_id IS NULL)
	OR
	  p_delete_flag)
      THEN

	  /*
       oe_delayed_requests_pvt.log_request(p_entity_code	=> OE_GLOBALS.G_ENTITY_HEADER_ADJ,
		   p_entity_id		=> p_adj_rec.header_id,
                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER_ADJ,
                   p_requesting_entity_id   => p_adj_rec.
                                                        price_adjustment_id,
		   p_request_type	=> OE_GLOBALS.G_PRICE_ADJ,
		   x_return_status	=> x_return_status);
		   */
		   null;
    END IF;

END Log_Adj_Requests;

--  Function Get_Values

FUNCTION Get_Values
(   p_Header_Adj_rec                IN  OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_REC
) RETURN OE_Order_PUB.Header_Adj_Val_Rec_Type
IS
l_Header_Adj_val_rec          OE_Order_PUB.Header_Adj_Val_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF (p_Header_Adj_rec.discount_id IS NULL OR
        p_Header_Adj_rec.discount_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_Header_Adj_rec.discount_id,
        p_old_Header_Adj_rec.discount_id)
    THEN
        l_Header_Adj_val_rec.discount := OE_Id_To_Value.Discount
        (   p_discount_id                 => p_Header_Adj_rec.discount_id
        );
    END IF;

    RETURN l_Header_Adj_val_rec;

END Get_Values;

--  Procedure Get_Ids

PROCEDURE Get_Ids
(   p_x_Header_Adj_rec              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
,   p_Header_Adj_val_rec            IN  OE_Order_PUB.Header_Adj_Val_Rec_Type
)
IS
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  initialize  return_status.

    l_Header_Adj_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_Header_Adj_rec.

    l_Header_Adj_rec := p_x_Header_Adj_rec;

    IF  p_Header_Adj_val_rec.discount <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Header_Adj_rec.discount_id <> FND_API.G_MISS_NUM THEN

            l_Header_Adj_rec.discount_id := p_x_Header_Adj_rec.discount_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_Header_Adj_rec.discount_id := OE_Value_To_Id.discount
            (   p_discount                    => p_Header_Adj_val_rec.discount
            );

            IF l_Header_Adj_rec.discount_id = FND_API.G_MISS_NUM THEN
                l_Header_Adj_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


  --  RETURN l_Header_Adj_rec;
    p_x_Header_Adj_rec := l_Header_Adj_rec;

END Get_Ids;


FUNCTION  get_adj_total
( p_header_id       IN   NUMBER := null
, p_line_id       IN   NUMBER :=null
)
		RETURN NUMBER
is
l_adj_total NUMBER := 0;
Is_fmt Boolean;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.GET_ADJ_TOTAL' , 1 ) ;
    END IF;

    IF (p_header_id IS NOT NULL AND
       NVL(p_header_id,-1)<>NVL(OE_ORDER_UTIL.G_Header_id,-10))
    OR  OE_ORDER_UTIL.G_Precision IS NULL THEN
      Is_fmt:=   OE_ORDER_UTIL.Get_Precision(
                p_header_id=>p_header_id
               );
    END IF;

    IF (p_line_id IS NOT NULL AND
    NVL(p_Line_id,-1)<>NVL(OE_ORDER_UTIL.G_Line_id,-10))
    OR  OE_ORDER_UTIL.G_Precision IS NULL THEN
      Is_fmt:=   OE_ORDER_UTIL.Get_Precision(
                p_line_id=>p_line_id
               );
    END IF;

    IF OE_ORDER_UTIL.G_Precision IS NULL THEN
      OE_ORDER_UTIL.G_Precision:=2;
    END IF;


    --	Query total.
    --  Separating into two separate SQLs for bug 3090569 --jvicenti

    IF p_header_id IS NOT NULL THEN
        SELECT  sum(ROUND(((unit_selling_price - unit_list_price)*
                          ordered_quantity) ,OE_ORDER_UTIL.G_Precision))
        INTO    l_adj_total
        FROM    oe_order_lines_all
        WHERE   HEADER_ID = p_header_id
        AND     charge_periodicity_code IS NULL -- addded for recurring charges
        AND	nvl(cancelled_flag,'N') ='N';
    ELSE
        SELECT  sum(ROUND(((unit_selling_price - unit_list_price)*
                          ordered_quantity) ,OE_ORDER_UTIL.G_Precision))
        INTO    l_adj_total
        FROM    oe_order_lines_all
        WHERE   line_id = p_line_id
        AND	nvl(cancelled_flag,'N') ='N';
    END IF;

    IF l_adj_total IS NULL THEN

		l_adj_total := 0;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.GET_ADJ_TOTAL' , 1 ) ;
    END IF;

    RETURN l_adj_total;

EXCEPTION

    WHEN OTHERS THEN

        -- Unexpected error
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
    	        'Price_Utilities - Get_Adj_Total'
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Adj_Total;

 procedure get_line_adjustments
 (p_header_id			number
 ,p_line_id			number
,x_line_adjustments out nocopy line_adjustments_tab_type

 )
is
l_index		number := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.GET_LINE_ADJUSTMENTS' , 1 ) ;
    END IF;

    for adj_cur in
    ( SELECT   opa.price_adjustment_id
			,opa.adjustment_name
                        ,opa.adjustment_description  --Enhancement 3816014
                        ,opa.list_line_no
			,opa.adjustment_type_code
			,opa.operand
			,opa.arithmetic_operator
--Bug 3340636 Starts
			,decode(list_line_type_code,'SUR',
				-1 * (decode(opa.arithmetic_operator,
				null,0,
				'%', opa.operand*ool.unit_list_price/100,
				'AMT',opa.operand,
				'NEWPRICE',ool.unit_list_price - opa.operand)),
			decode(opa.arithmetic_operator,null,0,'%',
			opa.operand*ool.unit_list_price/100,
				'AMT',opa.operand,
			'NEWPRICE',ool.unit_list_price-opa.operand))
					unit_discount_amount
--Bug 3340636 Ends
			 FROM oe_price_adjustments_v opa
			, oe_order_lines_all ool
      WHERE   	opa.HEADER_ID = p_header_id
			and opa.line_id is null
		   	and ool.line_id = p_line_id
		   	and ool.header_id = p_header_id
		   	and nvl(opa.applied_flag,'N') = 'Y'
			and nvl(opa.accrual_flag,'N') = 'N'
		   	and list_line_type_code in ('DIS','SUR','PBH')
     UNION
	  -- get line adjustments
     SELECT   	opa.price_adjustment_id
			,opa.adjustment_name
                        ,opa.adjustment_description  --Enhancement 3816014
                        ,opa.list_line_no
			,opa.adjustment_type_code
			,opa.operand
			,opa.arithmetic_operator
			,opa.adjusted_amount*(-1)	unit_discount_amount
      FROM    	oe_price_adjustments_v opa
			, oe_order_lines_all ool
      WHERE  	opa.line_id =p_line_id
		   	and ool.line_id = p_line_id
		   	and ool.header_id = p_header_id
		   	and nvl(opa.applied_flag,'N') = 'Y'
			and nvl(opa.accrual_flag,'N') = 'N'
		   	and list_line_type_code in ('DIS','SUR','PBH')
     )
	loop

	l_index:= l_index+1;
	x_line_adjustments(l_index).price_adjustment_id := adj_cur.price_adjustment_id;
 	x_line_adjustments(l_index).adjustment_name := adj_cur.adjustment_name;
        x_line_adjustments(l_index).adjustment_description := adj_cur.adjustment_description;  --Enhancement 3816014
        x_line_adjustments(l_index).list_line_no := adj_cur.list_line_no;
 	x_line_adjustments(l_index).adjustment_type_code:= adj_cur.adjustment_type_code;
 	x_line_adjustments(l_index).operand:= adj_cur.operand;
 	x_line_adjustments(l_index).arithmetic_operator:= adj_cur.arithmetic_operator;
 	x_line_adjustments(l_index).unit_discount_amount := adj_cur.unit_discount_amount;

     end loop;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.GET_LINE_ADJUSTMENTS' , 1 ) ;
    END IF;


EXCEPTION

    WHEN OTHERS THEN

        -- Unexpected error
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
    	        'Header_utilities - get_line_adjustments'
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_line_adjustments;

/* Start AuditTrail */
PROCEDURE Pre_Write_Process
          (p_x_header_adj_rec IN OUT NOCOPY /* file.sql.39 change */ OE_ORDER_PUB.header_adj_rec_type,
           p_old_header_adj_rec IN OE_ORDER_PUB.header_adj_rec_type := OE_ORDER_PUB.G_MISS_HEADER_ADJ_REC) IS
/*local */
l_return_status     varchar2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

       --11.5.10 Versioning/Audit Trail updates
     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' AND
         OE_GLOBALS.G_ROLL_VERSION <> 'N' AND
         NOT OE_GLOBALS.G_HEADER_CREATED THEN
       IF OE_GLOBALS.G_REASON_CODE IS NULL AND
           OE_GLOBALS.G_CAPTURED_REASON IN ('V','A') THEN
         IF p_x_header_adj_rec.change_reason_code <> FND_API.G_MISS_CHAR THEN
              OE_GLOBALS.G_REASON_TYPE := 'CHANGE_CODE';
              OE_GLOBALS.G_REASON_CODE := p_x_header_adj_rec.change_reason_code;
              OE_GLOBALS.G_REASON_COMMENTS := p_x_header_adj_rec.change_reason_text;
              OE_GLOBALS.G_CAPTURED_REASON := 'Y';
         ELSE
              IF l_debug_level  > 0 THEN
                 OE_DEBUG_PUB.add('Reason code for versioning is missing', 1);
              END IF;
              IF OE_GLOBALS.G_UI_FLAG THEN
                 raise FND_API.G_EXC_ERROR;
              END IF;
         END IF;
       END IF;

       --log delayed request
        oe_debug_pub.add('log versioning request',1);
          OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_x_header_adj_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER_ADJ,
                                   p_requesting_entity_id => p_x_header_adj_rec.price_adjustment_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   x_return_status => l_return_status);
     END IF;

if (p_x_header_adj_rec.operation  = OE_GLOBALS.G_OPR_UPDATE) then

   IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' OR
	 OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG = 'Y' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALL TO RECORD HEADER PRICE ADJ HISTORY' , 5 ) ;
      END IF;
     --11.5.10 Versioning/Audit Trail updates
     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
          OE_Versioning_Util.Capture_Audit_Info(p_entity_code => OE_GLOBALS.G_ENTITY_HEADER_ADJ,
                                           p_entity_id => p_x_header_adj_rec.price_adjustment_id,
                                           p_hist_type_code =>  'UPDATE');
           --log delayed request
             OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_x_header_adj_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
                                   p_requesting_entity_id => p_x_header_adj_rec.header_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   x_return_status => l_return_status);
          OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
     ELSE
      OE_CHG_ORDER_PVT.RecordHPAdjHist
      ( p_header_adj_id => p_x_header_adj_rec.price_adjustment_id,
        p_header_adj_rec => null,
        p_hist_type_code => 'UPDATE',
        p_reason_code => p_x_header_adj_rec.change_reason_code,
        p_comments => p_x_header_adj_rec.change_reason_text,
        p_wf_activity_code => null,
        p_wf_result_code => null,
        x_return_status => l_return_status );
     END IF;

   END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'INSERT INTO HEADER PRICE ADJUSTMENTS AUDIT HISTORY CAUSED ERROR' , 1 ) ;
	  END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
       ELSE
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;
END IF;

END Pre_Write_Process;
/* End AuditTrail */

/* Added the following procedure to fix the bug 2170086 */
PROCEDURE copy_header_adjustments
( p_from_header_id    IN   NUMBER
, p_to_header_id      IN   NUMBER
, p_to_order_category IN   VARCHAR2
, x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
is
l_copy_freight_charge      VARCHAR2(1);
l_from_order_category      VARCHAR2(30);
l_from_header_adj_tbl      OE_Order_PUB.Header_Adj_Tbl_Type;
l_from_header_adj_att_tbl  OE_Order_Pub.Header_Adj_Att_Tbl_Type;
l_header_adj_tbl           OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_adj_att_tbl       OE_Order_Pub.Header_Adj_Att_Tbl_Type;
i                          pls_integer;
j                          pls_integer;
l_control_rec              OE_Globals.Control_rec_type;
l_header_rec               OE_Order_PUB.Header_Rec_Type;
l_x_Header_price_Att_tbl   OE_Order_PUB.Header_price_Att_tbl_type;
l_x_Header_Adj_Assoc_tbl   OE_Order_PUB.Header_Adj_Assoc_tbl_type;
l_x_Header_Scredit_tbl     OE_Order_PUB.Header_Scredit_Tbl_Type;
l_line_tbl                 OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_tbl           OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Adj_Att_tbl       OE_Order_PUB.Line_Adj_Att_tbl_type;
l_x_Line_price_Att_tbl     OE_Order_PUB.Line_price_Att_tbl_type;
l_x_Line_Adj_Assoc_tbl     OE_Order_PUB.Line_Adj_Assoc_tbl_type;
l_x_Line_Scredit_tbl       OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_lot_serial_tbl         OE_Order_PUB.lot_serial_tbl_type;
l_x_action_request_tbl     OE_Order_PUB.request_tbl_type;
l_x_msg_count              NUMBER;
l_x_msg_data               VARCHAR2(2000);

cursor c1
is
select order_category_code
from   oe_order_headers
where  header_id = p_from_header_id;

BEGIN

  oe_debug_pub.add('Entering OE_Header_Adj_Util.copy_header_adjustments ', 1);

  /* Get Order category of the order FROM which adjustments are being copied. */
  for c1_rec in c1 loop
    l_from_order_category := c1_rec.order_category_code;
  end loop;

  /* Header Level adjustment for FROM Header */
  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
      OE_Version_History_Util.Query_Rows
           (  p_header_id => p_from_header_id
            , p_version_number => OE_ORDER_COPY_UTIL.G_HDR_VER_NUMBER
            , p_phase_change_flag => OE_ORDER_COPY_UTIL.G_HDR_PHASE_CHANGE_FLAG
            , x_Header_Adj_Tbl => l_from_header_adj_tbl);
  ELSE
      OE_Header_Adj_Util.Query_Rows( p_header_Id      => p_from_header_id
                               , x_Header_Adj_Tbl => l_from_header_adj_tbl
                               );
  END IF;

  i := l_from_header_adj_tbl.First;
  While i is not null Loop

    oe_debug_pub.add('inside copy header adj '||l_from_header_adj_tbl(i).list_line_type_code);

    /* If it's a Freight Charge then ... */
    If l_from_header_adj_tbl(i).list_line_type_code <> 'FREIGHT_CHARGE' and
       l_from_header_adj_tbl(i).list_line_type_code <> 'OM_CALLED_FREIGHT_RATES' and -- bug 4304163
       l_from_header_adj_tbl(i).list_line_type_code <> 'OM_CALLED_CHOOSE_SHIP_METHOD' then --Bug3322938

      /* Copy Freight Charge only if the flag was set to 'Y' */

        oe_header_price_aattr_util.Query_Rows(
                p_price_adjustment_id => l_from_header_adj_tbl(i).price_adjustment_id,
                x_header_adj_att_tbl  => l_from_header_adj_att_tbl
			 );

        j := l_from_header_adj_att_tbl.First;
        While j is not null Loop

          l_from_header_adj_att_tbl(j).operation           := OE_GLOBALS.G_OPR_CREATE;
          l_from_header_adj_att_tbl(j).price_adjustment_id := fnd_api.g_miss_num;
          l_from_header_adj_att_tbl(j).adj_index           := l_header_adj_tbl.count+1;
          l_from_header_adj_att_tbl(j).price_adj_attrib_id := fnd_api.g_miss_num;

          l_header_adj_att_tbl(l_header_adj_att_tbl.count+1) := l_from_header_adj_att_tbl(j);

          j := l_from_header_adj_att_tbl.Next(j);

        End Loop;

        l_from_header_adj_tbl(i).operation           := OE_GLOBALS.G_OPR_CREATE;
        l_from_header_adj_tbl(i).header_id           := p_to_header_id;
        l_from_header_adj_tbl(i).invoiced_flag       := 'N';
        l_from_header_adj_tbl(i).price_adjustment_id := fnd_api.g_miss_num;

        l_header_adj_tbl(l_header_adj_tbl.count+1)   := l_from_header_adj_tbl(i);


    End if; -- List Line Type <> Freight Charge

    i:= l_from_header_adj_tbl.Next(i);
  End Loop;

  If l_header_adj_tbl.count > 0 or l_header_adj_att_tbl.count > 0 Then

    -- set control record
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.write_to_DB          := TRUE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.clear_dependents     := TRUE;

    l_control_rec.process              := FALSE;
    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    oe_debug_pub.add('Before OE_Order_PVT.Process_order',3);

    -- OE_Globals.G_RECURSION_MODE := 'Y';

    -- Call OE_Order_PVT.Process_order
    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => l_x_msg_count
    ,   x_msg_data                    => l_x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => l_header_rec
    ,   p_x_Header_Adj_tbl            => l_Header_Adj_Tbl
    ,   p_x_Header_Adj_att_tbl        => l_Header_Adj_Att_Tbl
    ,   p_x_Header_Price_Att_Tbl      => l_x_Header_Price_Att_Tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
    ,   p_x_line_tbl                  => l_line_tbl
    ,   p_x_Line_Adj_tbl              => l_x_Line_Adj_tbl
    ,   p_x_Line_Adj_att_tbl          => l_x_Line_Adj_att_tbl
    ,   p_x_Line_Price_att_tbl        => l_x_Line_Price_att_tbl
    ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_Tbl
    ,   p_x_action_request_tbl        => l_x_Action_Request_tbl
    );

    -- OE_Globals.G_RECURSION_MODE := 'N';

    If x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    Elsif x_return_status = FND_API.G_RET_STS_ERROR Then
      RAISE FND_API.G_EXC_ERROR;
    End If;

  End If;

  oe_debug_pub.add('Exiting OE_Header_Adj_Util.copy_header_adjustments ', 1);

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      oe_debug_pub.add(G_PKG_NAME||':copy_header_adjuetments :'||SQLERRM);

    WHEN OTHERS THEN
      If FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) Then
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Copy_header_adjustments '
            );
      End If;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END copy_header_adjustments ;

/* End of the procedure added to fix the bug 2170086 */

/* Fix for 1559906: New Procedure to Copy Freight Charges */

PROCEDURE copy_freight_charges
( p_from_header_id    IN   NUMBER
, p_to_header_id      IN   NUMBER
, p_to_order_category IN   VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

)
is
l_copy_freight_charge      VARCHAR2(1);
l_from_order_category      VARCHAR2(30);
l_from_header_adj_tbl      OE_Order_PUB.Header_Adj_Tbl_Type;
l_from_header_adj_att_tbl  OE_Order_Pub.Header_Adj_Att_Tbl_Type;
l_header_adj_tbl           OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_adj_att_tbl       OE_Order_Pub.Header_Adj_Att_Tbl_Type;
i                          pls_integer;
j                          pls_integer;
l_control_rec              OE_Globals.Control_rec_type;
l_header_rec               OE_Order_PUB.Header_Rec_Type;
l_x_Header_price_Att_tbl   OE_Order_PUB.Header_price_Att_tbl_type;
l_x_Header_Adj_Assoc_tbl   OE_Order_PUB.Header_Adj_Assoc_tbl_type;
l_x_Header_Scredit_tbl     OE_Order_PUB.Header_Scredit_Tbl_Type;
l_line_tbl                 OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_tbl           OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Adj_Att_tbl       OE_Order_PUB.Line_Adj_Att_tbl_type;
l_x_Line_price_Att_tbl     OE_Order_PUB.Line_price_Att_tbl_type;
l_x_Line_Adj_Assoc_tbl     OE_Order_PUB.Line_Adj_Assoc_tbl_type;
l_x_Line_Scredit_tbl       OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_lot_serial_tbl         OE_Order_PUB.lot_serial_tbl_type;
l_x_action_request_tbl     OE_Order_PUB.request_tbl_type;
l_x_msg_count              NUMBER;
l_x_msg_data               VARCHAR2(2000);

cursor c1
is
select order_category_code
from   oe_order_headers
where  header_id = p_from_header_id;
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.COPY_FREIGHT_CHARGES' , 1 ) ;
  END IF;

  /* Get Order category of the order FROM which charges are being copied. */
  for c1_rec in c1 loop
    l_from_order_category := c1_rec.order_category_code;
  end loop;

  /* Header Level Charges for FROM Header */
  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
      OE_Version_History_Util.Query_Rows
           (  p_header_id => p_from_header_id
            , p_version_number => OE_ORDER_COPY_UTIL.G_HDR_VER_NUMBER
            , p_phase_change_flag => OE_ORDER_COPY_UTIL.G_HDR_PHASE_CHANGE_FLAG
            , x_Header_Adj_Tbl => l_from_header_adj_tbl);
  ELSE
      OE_Header_Adj_Util.Query_Rows( p_header_Id      => p_from_header_id
                               , x_Header_Adj_Tbl => l_from_header_adj_tbl);
  END IF;

  i := l_from_header_adj_tbl.First;
  While i is not null Loop

    oe_debug_pub.add('Inside copy frieght charges .. '||l_from_header_adj_tbl(i).list_line_type_code);

    l_copy_freight_charge := 'N';

    /* If it's a Freight Charge then ... */
    If l_from_header_adj_tbl(i).list_line_type_code = 'FREIGHT_CHARGE' then

      /* If copying from Order to Return then ... */
      If l_from_order_category = 'ORDER' and p_to_order_category = 'RETURN' then

	   If (NVL(l_from_header_Adj_Tbl(i).include_on_returns_flag,'Y') = 'Y' and
            NVL(l_from_header_Adj_Tbl(i).applied_flag,'N') = 'Y') then

          l_copy_freight_charge := 'Y';

          if l_from_header_adj_tbl(i).credit_or_charge_flag = 'C' then
            l_from_header_adj_tbl(i).credit_or_charge_flag := 'D';
          else
            l_from_header_adj_tbl(i).credit_or_charge_flag := 'C';
          end if;

          l_from_header_adj_tbl(i).updated_flag          := 'Y';
          l_from_header_adj_tbl(i).change_reason_code    := 'MISC';
          l_from_header_adj_tbl(i).change_reason_text    := 'Reversing Credit';

        End if;

      /* If copying from Return to Order then ... */
      Elsif l_from_order_category = 'RETURN' and p_to_order_category = 'ORDER' then

        l_copy_freight_charge := 'Y';

        if l_from_header_adj_tbl(i).credit_or_charge_flag = 'C' then
          l_from_header_adj_tbl(i).credit_or_charge_flag := 'D';
        else
          l_from_header_adj_tbl(i).credit_or_charge_flag := 'C';
        end if;

        l_from_header_adj_tbl(i).updated_flag          := 'N';
        l_from_header_adj_tbl(i).change_reason_code    := NULL;
        l_from_header_adj_tbl(i).change_reason_text    := NULL;

      /*
      ** Else copying from:
      ** Order-> Order, Return-> Return, Mixed-> Mixed, Order-> Mixed, Return-> Mixed.
      */
      Else

        /* Copy the charge as it is */
           l_copy_freight_charge := 'Y';

      End if; -- Order Category

      /* Copy Freight Charge only if the flag was set to 'Y' */
	 If l_copy_freight_charge = 'Y' Then

        oe_header_price_aattr_util.Query_Rows(
                p_price_adjustment_id => l_from_header_adj_tbl(i).price_adjustment_id,
                x_header_adj_att_tbl  => l_from_header_adj_att_tbl
			 );

        j := l_from_header_adj_att_tbl.First;
        While j is not null Loop

          l_from_header_adj_att_tbl(j).operation           := OE_GLOBALS.G_OPR_CREATE;
          l_from_header_adj_att_tbl(j).price_adjustment_id := fnd_api.g_miss_num;
          l_from_header_adj_att_tbl(j).adj_index           := l_header_adj_tbl.count+1;
          l_from_header_adj_att_tbl(j).price_adj_attrib_id := fnd_api.g_miss_num;

          l_header_adj_att_tbl(l_header_adj_att_tbl.count+1) := l_from_header_adj_att_tbl(j);

          j := l_from_header_adj_att_tbl.Next(j);

        End Loop;

        l_from_header_adj_tbl(i).operation           := OE_GLOBALS.G_OPR_CREATE;
        l_from_header_adj_tbl(i).header_id           := p_to_header_id;
        l_from_header_adj_tbl(i).invoiced_flag       := 'N';
	l_from_header_adj_tbl(i).invoiced_amount     := NULL;
        l_from_header_adj_tbl(i).price_adjustment_id := fnd_api.g_miss_num;

        l_header_adj_tbl(l_header_adj_tbl.count+1)   := l_from_header_adj_tbl(i);

      End If;

    End if; -- List Line Type = Freight Charge

    i:= l_from_header_adj_tbl.Next(i);
  End Loop;

  If l_header_adj_tbl.count > 0 or l_header_adj_att_tbl.count > 0 Then

    -- set control record
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.write_to_DB          := TRUE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.clear_dependents     := TRUE;

    l_control_rec.process              := FALSE;
    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE OE_ORDER_PVT.PROCESS_ORDER' , 3 ) ;
    END IF;

    -- OE_Globals.G_RECURSION_MODE := 'Y';

    -- Call OE_Order_PVT.Process_order
    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => l_x_msg_count
    ,   x_msg_data                    => l_x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => l_header_rec
    ,   p_x_Header_Adj_tbl            => l_Header_Adj_Tbl
    ,   p_x_Header_Adj_att_tbl        => l_Header_Adj_Att_Tbl
    ,   p_x_Header_Price_Att_Tbl      => l_x_Header_Price_Att_Tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
--serla begin
    ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
--serla end
    ,   p_x_line_tbl                  => l_line_tbl
    ,   p_x_Line_Adj_tbl              => l_x_Line_Adj_tbl
    ,   p_x_Line_Adj_att_tbl          => l_x_Line_Adj_att_tbl
    ,   p_x_Line_Price_att_tbl        => l_x_Line_Price_att_tbl
    ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
--serla begin
    ,   p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
--serla end
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_Tbl
    ,   p_x_action_request_tbl        => l_x_Action_Request_tbl
    );

    -- OE_Globals.G_RECURSION_MODE := 'N';

    If x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    Elsif x_return_status = FND_API.G_RET_STS_ERROR Then
      RAISE FND_API.G_EXC_ERROR;
    End If;

  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.COPY_FREIGHT_CHARGES' , 1 ) ;
  END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  G_PKG_NAME||':COPY_FREIGHT_CHARGES:'||SQLERRM ) ;
      END IF;

    WHEN OTHERS THEN
      If FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) Then
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Copy_Freight_Charges'
            );
      End If;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END copy_freight_charges;

--Recurring Charges
FUNCTION  get_rec_adj_total
( p_header_id       IN   NUMBER := null
, p_line_id       IN   NUMBER :=null
, p_charge_periodicity_code       IN    VARCHAR2
)
		RETURN NUMBER
is
l_adj_total NUMBER := 0;
Is_fmt Boolean;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.GET_ADJ_TOTAL' , 1 ) ;
    END IF;

    IF (p_header_id IS NOT NULL AND
       NVL(p_header_id,-1)<>NVL(OE_ORDER_UTIL.G_Header_id,-10))
    OR  OE_ORDER_UTIL.G_Precision IS NULL THEN
      Is_fmt:=   OE_ORDER_UTIL.Get_Precision(
                p_header_id=>p_header_id
               );
    END IF;

    IF (p_line_id IS NOT NULL AND
    NVL(p_Line_id,-1)<>NVL(OE_ORDER_UTIL.G_Line_id,-10))
    OR  OE_ORDER_UTIL.G_Precision IS NULL THEN
      Is_fmt:=   OE_ORDER_UTIL.Get_Precision(
                p_line_id=>p_line_id
               );
    END IF;

    IF OE_ORDER_UTIL.G_Precision IS NULL THEN
      OE_ORDER_UTIL.G_Precision:=2;
    END IF;


    --	Query total.
    --  Separating into two separate SQLs for bug 3090569 --jvicenti

    IF p_header_id IS NOT NULL THEN
        SELECT  sum(ROUND(((unit_selling_price - unit_list_price)*
                          ordered_quantity) ,OE_ORDER_UTIL.G_Precision))
        INTO    l_adj_total
        FROM    oe_order_lines_all
        WHERE   HEADER_ID = p_header_id
        AND     nvl(charge_periodicity_code,'ONE') = p_charge_periodicity_code
        AND	nvl(cancelled_flag,'N') ='N';
    END IF;

    IF l_adj_total IS NULL THEN

		l_adj_total := 0;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.GET_ADJ_TOTAL' , 1 ) ;
    END IF;

    RETURN l_adj_total;

EXCEPTION

    WHEN OTHERS THEN

        -- Unexpected error
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

	    OE_MSG_PUB.Add_Exc_Msg
	    (   G_PKG_NAME  	    ,
    	        'Price_Utilities - Get_Adj_Total'
	    );
	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Rec_Adj_Total;
-- Recurring CHarges

--rc
-- New function added to return the recurring amount given the order level modifier and periodicity
FUNCTION  get_rec_order_adj_total
   ( p_header_id       IN   NUMBER DEFAULT NULL
     , p_price_adjustment_id IN NUMBER DEFAULT NULL
     , p_charge_periodicity_code       IN    VARCHAR2 DEFAULT NULL
     )
   RETURN NUMBER
Is
   l_rec_list_price_total NUMBER := 0;
   l_operand NUMBER :=0;
   l_order_adj_total NUMBER := 0;
   l_status_code       VARCHAR2(30);
   l_price_list_id     NUMBER;
   l_currency_code     VARCHAR2(15);
   l_pricing_date      DATE;
   l_header_id         NUMBER;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('ENTERING OE_HEADER_ADJ_UTIL.GET_REC_ORDER_ADJ_TOTAL');
   END IF;

   IF p_price_adjustment_id IS NULL OR
      p_charge_periodicity_code IS NULL THEN
         RETURN NULL;
   ELSE
      IF p_header_id IS NULL THEN
	 BEGIN
	    SELECT header_id INTO l_header_id
	    FROM oe_price_adjustments
	    WHERE price_adjustment_id = p_price_adjustment_id;

	    IF l_header_id IS NULL THEN
	       RETURN NULL;
	    END IF;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF l_debug_level > 0 THEN
		  oe_debug_pub.add('Exception while querying for the adjustment record : ' || SQLERRM);
	       END IF;
	       RETURN NULL;
	 END;
      ELSE
        l_header_id := p_header_id;
      END IF;
   END IF;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('l_header_id : ' || l_header_id);
      oe_debug_pub.add('p_price_adjustment_id : ' || p_price_adjustment_id);
      oe_debug_pub.add('p_charge_periodicity_code : ' || p_charge_periodicity_code);
   END IF;


   SELECT  nvl(sum(unit_list_price * ordered_quantity), 0) --bug5354658
   INTO    l_rec_list_price_total
   FROM    oe_order_lines_all
   WHERE   HEADER_ID = l_header_id
   AND     charge_periodicity_code = p_charge_periodicity_code
   AND     nvl(cancelled_flag,'N') ='N';

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('l_rec_list_price_total : ' || l_rec_list_price_total);
   END IF;

   SELECT nvl(operand,0) * decode(list_line_type_code, 'DIS', -1, 'SUR', 1)
   INTO l_operand
   FROM oe_price_adjustments
   WHERE price_adjustment_id = p_price_adjustment_id
   AND line_id IS NULL
   AND arithmetic_operator = '%';

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('l_operand : ' || l_operand);
   END IF;

   l_order_adj_total := l_rec_list_price_total * (l_operand / 100);

   IF l_order_adj_total <> 0 THEN
      BEGIN
	 SELECT price_list_id,
	        transactional_curr_code,
	        nvl(pricing_date,ordered_date)
	 INTO l_price_list_id,l_currency_code,l_pricing_date
	 FROM   Oe_Order_Headers_All
	 WHERE  header_id = p_header_id;

	 QP_UTIL_PUB.round_price
	    (p_operand                => l_order_adj_total,
	     p_rounding_factor        => NULL,
	     p_use_multi_currency     => 'Y',
	     p_price_list_id          => l_price_list_id,
	     p_currency_code          => l_currency_code,
	     p_pricing_effective_date => l_pricing_date,
	     x_rounded_operand        => l_order_adj_total,
	     x_status_code            => l_status_code,
	     p_operand_type           => 'A'
	     );

	 IF l_order_adj_total IS NULL Then
	    IF l_debug_level > 0 THEN
	       oe_debug_pub.add('Error in QP_UTIL_PUB.round_price. Unable to perform rounding');
	    END IF;
	    --pricing has some errors retore the old adjusted_amount
	    l_order_adj_total := l_rec_list_price_total * (l_operand / 100);
	 END IF;
      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    IF l_debug_level > 0 THEN
	       oe_debug_pub.add('Unable to query header to perform rounding:'||p_header_id);
	    END IF;
	       l_order_adj_total := 0;
	 WHEN OTHERS THEN
	    IF l_debug_level > 0 THEN
	       oe_debug_pub.add('OEXUHADB.pls'||SQLERRM);
	    END IF;

	    l_order_adj_total := l_rec_list_price_total * (l_operand / 100);
      END;

  END IF;

  IF l_debug_level > 0 THEN
      oe_debug_pub.add('l_order_adj_total : ' || l_order_adj_total);
      oe_debug_pub.add('EXITING OE_HEADER_ADJ_UTIL.GET_REC_ORDER_ADJ_TOTAL');
  END IF;

  Return l_order_adj_total;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
END get_rec_order_adj_total;

END OE_Header_Adj_Util;

/
